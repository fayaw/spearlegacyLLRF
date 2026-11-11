"""Full-band transfer-function estimate of a closed-loop record: local polynomial method (LPM) on the full-length DFT.

For a known excitation x and output y of one record (2^18 samples, 39.1 Hz bins), the DFT obeys at every bin k
    Y_k = G_k X_k + T_k + V_k,
with G the frequency response, T the transient (the record is not periodic, so the initial and final conditions
leak into every bin) and V the output noise. Around a bin, T is a smooth function of the bin offset r = -n..n and is
fitted as a quadratic together with G (Pintelon and Schoukens, System Identification, 2nd ed., ch. 7).

  * Noise level: G is fitted as a quadratic too (2 x 3 complex unknowns, 9 bins, 3 degrees of freedom); the residual
    variance, averaged over about 1 kHz, is the output-noise level. Interference lines raise it locally.
  * Estimate: G is held constant over the 9 bins (4 unknowns), which costs no variance. Its expectation is then not
    G at the centre bin but an exactly known weighted sum of G over the 9 bins, c = e_0' (K'K)^-1 K' diag(X), set by
    the excitation itself (the weights sum to one and annihilate any quadratic transient). A model is compared with
    the same weighted sum of its own response, so the estimate is unbiased at any resolution.

Neighbourhoods that do not overlap give independent estimates (352 Hz apart); they tile the spectrum outward from
the carrier, and the one centred on it leaves out the carrier bin, which holds the operating point (the record's
mean) rather than the response. Near the carrier (|f| < F_EXACT) each estimate is one data point with its exact
weights; further out, where the response is smooth, several are averaged with inverse-variance weights into one cell
and the model is evaluated at the cell's mean frequency. The estimate is returned in the convention of the
closed-loop routine (complex conjugate of Y/X), the physical envelope convention.

Offline only: reads the records and the noise reference from the repository.
"""
from __future__ import annotations

import numpy as np
import scipy.sparse as sps
from scipy.ndimage import uniform_filter1d

import csi_data as cd

N_HALF = 4             # neighbourhood half-width: 9 bins = 352 Hz
SMOOTH = 27            # bins over which the noise level is averaged (about 1 kHz)
F_EXACT = 25e3         # below this |offset| the model is averaged with the exact weights of each estimate
# estimates per cell by |offset from the carrier|: (upper edge in Hz, estimates per cell)
CELLS = ((F_EXACT, 1), (100e3, 4), (np.inf, 8))

_CACHE: dict = {}
_SRC_MTIME = __import__("os").path.getmtime(__file__)       # a changed estimator invalidates the disk cache


def _design(Xn: np.ndarray, n: int, r_g: int, r_t: int) -> np.ndarray:
    r = np.arange(-n, n + 1) / n
    Pg, Pt = np.vander(r, r_g + 1, increasing=True), np.vander(r, r_t + 1, increasing=True)
    return np.concatenate([Xn[:, :, None] * Pg[None], np.broadcast_to(Pt, Xn.shape + (r_t + 1,))], axis=2)


def _ls(K: np.ndarray, Yn: np.ndarray):
    A = np.einsum("mri,mrj->mij", K.conj(), K)
    Ainv = np.linalg.inv(A)
    theta = np.einsum("mij,mrj,mr->mi", Ainv, K.conj(), Yn)
    E = Yn - np.einsum("mri,mi->mr", K, theta)
    return theta, Ainv, E


def estimate(rec: cd.Record, fmin: float = 0.0, fmax: float = 550e3, n: int = N_HALF) -> dict:
    """LPM of one record for |f| <= fmax (cached); estimates below fmin are dropped. The neighbourhoods tile the
    spectrum outward from the carrier, one of them centred on it. The carrier bin holds the operating point (the
    record's mean, removed), not the response, and is left out of every fit. Returns, for the independent estimates
    (centres of the neighbourhoods): f, H (routine convention), var (complex variance), the bins of each neighbourhood
    and the exact expectation weights; and, for every bin, the noise level before and after smoothing."""
    key = (rec.tag, fmin, fmax, n)
    if key in _CACHE:
        return _CACHE[key]
    disk = cd.RESULTS / "cache" / f"lpm_{rec.tag}_{fmin:.0f}_{fmax:.0f}_{n}.npz"
    if disk.exists() and disk.stat().st_mtime > max(rec.path_i.stat().st_mtime, _SRC_MTIME):
        z = np.load(disk)
        _CACHE[key] = {k: z[k] for k in z.files} | dict(df=float(z["df"]), n=int(z["n"]))
        return _CACHE[key]
    y = cd.closed_loop_dump(rec)
    x = cd.noise_reference("testdata", y.size)
    N = y.size
    df = cd.FS / N
    Y, X = np.fft.fft(y), np.fft.fft(x)
    kmax = int(np.floor(fmax / df))
    r = np.arange(-n, n + 1)

    def neighbourhoods(centres, r_g):
        idx = centres[:, None] + r[None, :]
        use = (idx != 0).astype(float)                       # the carrier bin is left out
        return idx, use, _design(X[idx % N] * use, n, r_g, 2) * use[..., None]

    # noise level at every bin from the quadratic-G fit, smoothed across the carrier
    ks = np.arange(-kmax, kmax + 1)
    ks = ks[ks != 0]
    idx, use, K = neighbourhoods(ks, 2)
    _, _, E = _ls(K, Y[idx % N] * use)
    s2 = np.sum(np.abs(E) ** 2, axis=1) / (use.sum(axis=1) - K.shape[2])
    s2s = uniform_filter1d(s2, size=SMOOTH, mode="nearest")
    level = dict(zip(ks.tolist(), s2s.tolist()))
    level[0] = 0.5 * (level[-1] + level[1])
    # estimates with G constant over non-overlapping neighbourhoods
    step = 2 * n + 1
    m = (kmax - n) // step
    cen = np.arange(-m, m + 1) * step
    cen = cen[np.abs(cen) * df >= fmin]
    idx, use, K = neighbourhoods(cen, 0)
    theta, Ainv, _ = _ls(K, Y[idx % N] * use)
    weights = np.einsum("mj,mrj->mr", Ainv[:, 0, :], K.conj()) * X[idx % N] * use     # E[G_hat] = sum_r w_r G_{k+r}
    var = np.array([level[int(k)] for k in cen]) * np.real(Ainv[:, 0, 0])
    # conjugate (routine convention): H(f) = conj(G); the expectation of conj(G_hat) uses conj weights
    _CACHE[key] = dict(f=cen * df, H=np.conj(theta[:, 0]), var=var, bins_f=(cen[:, None] + r[None, :]) * df,
                       w=np.conj(weights), df=df, n=n, k_all=ks, s2=s2, s2s=s2s)
    disk.parent.mkdir(parents=True, exist_ok=True)
    np.savez(disk, **_CACHE[key])
    return _CACHE[key]


def cells(est: dict, fmin: float, fmax: float, sizes=CELLS, f_exact: float = F_EXACT) -> dict:
    """Independent estimates in fmin <= |f| < fmax grouped into cells (inverse-variance weights). Returns f (mean
    frequency), H, sigma (std of the complex cell estimate), m (estimates per cell) and the evaluation map: the model
    at the frequencies f_eval, multiplied by the sparse matrix M, gives the expectation of each cell."""
    out_f, out_H, out_s, out_m, rows = [], [], [], [], []
    f_eval: list = []
    for sgn in (-1, 0, 1):                     # 0: the estimate centred on the carrier
        sel = np.nonzero((np.sign(est["f"]) == sgn) & (np.abs(est["f"]) >= fmin) & (np.abs(est["f"]) < fmax))[0]
        sel = sel[np.argsort(np.abs(est["f"][sel]))]
        af = np.abs(est["f"][sel])
        i = 0
        while i < sel.size:
            m = next(sz for edge, sz in sizes if af[i] < edge)
            j = sel[i:i + m]
            w = 1.0 / est["var"][j]
            wn = w / w.sum()
            fc = float(np.sum(wn * est["f"][j]))
            out_f.append(fc)
            out_H.append(np.sum(wn * est["H"][j]))
            out_s.append(np.sqrt(1.0 / w.sum()))
            out_m.append(j.size)
            if abs(fc) < f_exact:
                wv = (wn[:, None] * est["w"][j]).ravel()
                fv = est["bins_f"][j].ravel()
                keep = wv != 0                 # the carrier bin carries no weight
                cols = list(range(len(f_eval), len(f_eval) + int(keep.sum())))
                f_eval.extend(fv[keep].tolist())
                rows.append((cols, wv[keep]))
            else:
                rows.append(([len(f_eval)], np.array([1.0 + 0j])))
                f_eval.append(fc)
            i += m
    o = np.argsort(out_f)
    data, ri, ci = [], [], []
    for new, old in enumerate(o):
        cols, vals = rows[old]
        ri.extend([new] * len(cols))
        ci.extend(cols)
        data.extend(vals.tolist())
    M = sps.csr_matrix((np.array(data), (ri, ci)), shape=(len(o), len(f_eval)))
    return dict(f=np.array(out_f)[o], H=np.array(out_H)[o], sigma=np.array(out_s)[o], m=np.array(out_m)[o],
                f_eval=np.array(f_eval), M=M)
