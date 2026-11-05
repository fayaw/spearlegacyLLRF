"""Spectra, weighting and least-squares machinery for single-record and multi-condition fits.

A Spectrum holds one record's transfer function in one band at one resolution, with the variance of each bin
from the coherence (H1 random error), smoothed over neighbouring bins so that the weights do not follow the
noise of their own estimate. Narrow-band models are convolved with the Hann window's power kernel, which is
what the Welch H1 estimate measures for a flat excitation spectrum.

A Fit maps one parameter vector to a list of Station objects (one per record). Each parameter is either
global (one value), per record, or per group of records (for example, one noise angle per operating current),
optionally fixed. The residuals are (model - data)/sigma for real and imaginary parts, so the cost is chi^2/2.
"""
from __future__ import annotations

import math
from dataclasses import dataclass, field

import numpy as np
from scipy.ndimage import median_filter
from scipy.optimize import least_squares

import csi_data as cd
import csi_model as cm


@dataclass
class Spectrum:
    rec: cd.Record
    f: np.ndarray
    H: np.ndarray
    sigma: np.ndarray        # std of the complex estimate, sqrt(E|H_hat - H|^2)
    coh: np.ndarray
    nfft: int
    smear: bool
    kern_off: np.ndarray | None = None
    kern_w: np.ndarray | None = None

    @property
    def n(self) -> int:
        return self.f.size


def window_kernel(nfft: int, os: int = 4, half_bins: int = 4):
    """Offsets [Hz] and weights of the normalised |W(f)|^2 of a Hann window of length nfft."""
    w = cd.hann(nfft)
    W = np.abs(np.fft.fft(w, os * nfft)) ** 2
    k = np.arange(-half_bins * os, half_bins * os + 1)
    wk = W[k % W.size]
    return k * cd.FS / (nfft * os), wk / wk.sum()


_CACHE: dict = {}


def spectrum(rec: cd.Record, nfft: int, fmin: float, fmax: float, smear: bool = False, smooth: int = 9,
             exclude: tuple = ()) -> Spectrum:
    key = (rec.tag, nfft)
    if key not in _CACHE:
        y = cd.closed_loop_dump(rec)
        x = cd.noise_reference("testdata", y.size)
        _CACHE[key] = cd.welch_tf(y, x, nfft)
    tf = _CACHE[key]
    snn = median_filter(tf.Syy * (1 - tf.coh), size=smooth, mode="nearest")
    sxx = median_filter(tf.Sxx, size=smooth, mode="nearest")
    var = snn / (sxx * tf.n_avg)
    a = np.abs(tf.f)
    sel = (a >= fmin) & (a <= fmax)
    for lo, hi in exclude:
        sel &= ~((tf.f >= lo) & (tf.f <= hi))
    sp = Spectrum(rec, tf.f[sel], tf.H[sel], np.sqrt(var[sel]), tf.coh[sel], nfft, smear)
    if smear:
        sp.kern_off, sp.kern_w = window_kernel(nfft)
    return sp


def model_on(st: cm.Station, sp: Spectrum) -> np.ndarray:
    if not sp.smear:
        return cm.measured_tf(st, sp.f)
    fine = (sp.f[:, None] + sp.kern_off[None, :]).ravel()
    return (cm.measured_tf(st, fine).reshape(sp.f.size, -1) @ sp.kern_w)


# ------------------------------------------------------------------ parameter maps
@dataclass
class Par:
    name: str                     # Station field
    value: float | list           # initial value(s): scalar, or list per group
    scope: str = "global"         # "global", "record" or "group"
    lo: float = -np.inf
    hi: float = np.inf
    scale: float = 1.0
    fixed: bool = False
    groups: list | None = None    # for scope "group": group index of each record


@dataclass
class Fit:
    specs: list                   # list of lists: specs[r] = spectra of record r (bands)
    base: list                    # Station per record with the known conditions (I_b, ...)
    pars: list
    derived: callable | None = None   # f(station, record_index) -> station, applied last (e.g. G from COUNTS.A)
    _layout: list = field(default_factory=list)

    def __post_init__(self):
        self._layout = []
        n_rec = len(self.base)
        for p in self.pars:
            if p.fixed:
                continue
            if p.scope == "global":
                self._layout.append((p, None))
            elif p.scope == "record":
                for r in range(n_rec):
                    self._layout.append((p, r))
            else:
                for g in sorted(set(p.groups)):
                    self._layout.append((p, ("g", g)))

    # vector <-> stations
    def x0(self) -> np.ndarray:
        out = []
        for p, idx in self._layout:
            v = p.value
            if isinstance(v, (list, tuple, np.ndarray)):
                v = v[idx] if isinstance(idx, int) else v[idx[1]] if idx is not None else v[0]
            out.append(v / p.scale)
        return np.array(out, float)

    def bounds(self):
        lo = [p.lo / p.scale for p, _ in self._layout]
        hi = [p.hi / p.scale for p, _ in self._layout]
        return np.array(lo), np.array(hi)

    def stations(self, q) -> list:
        vals = [dict() for _ in self.base]
        for p in self.pars:
            if p.fixed:
                for r in range(len(self.base)):
                    v = p.value
                    if isinstance(v, (list, tuple, np.ndarray)):
                        v = v[r] if p.scope == "record" else v[p.groups[r]] if p.scope == "group" else v[0]
                    vals[r][p.name] = v
        for (p, idx), qi in zip(self._layout, q):
            v = qi * p.scale
            if idx is None:
                for r in range(len(self.base)):
                    vals[r][p.name] = v
            elif isinstance(idx, int):
                vals[idx][p.name] = v
            else:
                for r in range(len(self.base)):
                    if p.groups[r] == idx[1]:
                        vals[r][p.name] = v
        out = [b.with_(**v) for b, v in zip(self.base, vals)]
        if self.derived is not None:
            out = [self.derived(st, r) for r, st in enumerate(out)]
        return out

    def residuals(self, q) -> np.ndarray:
        res = []
        for st, sps in zip(self.stations(q), self.specs):
            for sp in sps:
                d = (model_on(st, sp) - sp.H) / sp.sigma
                res.append(d.real)
                res.append(d.imag)
        return np.concatenate(res)

    def sparsity(self):
        """Residual rows each free parameter can change (records it applies to)."""
        from scipy.sparse import lil_matrix
        sizes = [2 * sum(sp.n for sp in sps) for sps in self.specs]
        edges = np.concatenate([[0], np.cumsum(sizes)])
        S = lil_matrix((int(edges[-1]), self.n_free), dtype=int)
        for j, (p, idx) in enumerate(self._layout):
            if idx is None:
                recs = range(len(self.base))
            elif isinstance(idx, int):
                recs = [idx]
            else:
                recs = [r for r in range(len(self.base)) if p.groups[r] == idx[1]]
            for r in recs:
                S[edges[r]:edges[r + 1], j] = 1
        return S

    @property
    def n_data(self) -> int:
        return 2 * sum(sp.n for sps in self.specs for sp in sps)

    @property
    def n_free(self) -> int:
        return len(self._layout)

    def names(self) -> list:
        out = []
        for p, idx in self._layout:
            out.append(p.name if idx is None else f"{p.name}[{idx}]" if isinstance(idx, int) else f"{p.name}[g{idx[1]}]")
        return out


@dataclass
class Result:
    fit: Fit
    q: np.ndarray
    chi2: float
    dof: int
    cov: np.ndarray
    stations: list
    jac: np.ndarray

    @property
    def chi2_red(self) -> float:
        return self.chi2 / self.dof

    @property
    def aic(self) -> float:
        return self.chi2 + 2 * self.fit.n_free

    @property
    def bic(self) -> float:
        return self.chi2 + self.fit.n_free * math.log(self.fit.n_data)

    def value(self, name: str, idx=None) -> tuple:
        names = self.fit.names()
        key = name if idx is None else f"{name}[{idx}]"
        i = names.index(key)
        p = self.fit._layout[i][0]
        return self.q[i] * p.scale, math.sqrt(max(self.cov[i, i], 0.0)) * p.scale

    def per_record_rms(self) -> list:
        out = []
        for st, sps in zip(self.stations, self.fit.specs):
            r = np.concatenate([(model_on(st, sp) - sp.H) / sp.sigma for sp in sps])
            out.append(float(np.sqrt(np.mean(np.abs(r) ** 2) / 2)))
        return out


def run(fit: Fit, starts: list | None = None, max_nfev: int = 400, verbose: int = 0, sparse: bool | None = None) -> Result:
    """Least squares from each start (dicts name -> value overriding x0 entries); keeps the best."""
    lo, hi = fit.bounds()
    names = fit.names()
    sparse = (len(fit.base) > 2) if sparse is None else sparse
    jsp = fit.sparsity() if sparse else None
    best = None
    for st in (starts or [{}]):
        q0 = fit.x0()
        for k, v in st.items():
            for i, n in enumerate(names):
                if n == k or n.split("[")[0] == k:
                    q0[i] = v / fit._layout[i][0].scale
        q0 = np.clip(q0, lo + 1e-9 * (hi - lo), hi - 1e-9 * (hi - lo))
        r = least_squares(fit.residuals, q0, bounds=(lo, hi), max_nfev=max_nfev, verbose=verbose, x_scale="jac",
                          jac_sparsity=jsp, tr_solver="exact" if jsp is None else "lsmr")
        if best is None or r.cost < best.cost:
            best = r
    J = best.jac.toarray() if hasattr(best.jac, "toarray") else best.jac
    dof = fit.n_data - fit.n_free
    chi2 = 2 * best.cost
    try:
        cov = np.linalg.pinv(J.T @ J) * max(chi2 / dof, 1.0)
    except np.linalg.LinAlgError:
        cov = np.full((J.shape[1], J.shape[1]), np.nan)
    return Result(fit, best.x, chi2, dof, cov, fit.stations(best.x), J)
