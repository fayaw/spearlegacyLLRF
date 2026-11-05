"""Probe-only measurement of the dipole mode: harmonic regression, subspace identification, joint sideband fit.

All methods use only the complex envelope of a cavity probe (I/Q), from the FSW I/Q analyzer
(fsw_iq_capture.py) or from the RFP cavity RAM (optllrf_probe_ram.m, 25.6 ms per shot).

  harmonic regression   the mains frequency is tracked from the phase drift of the strongest harmonics, and
                        both sidebands of every 60 Hz harmonic are estimated block by block and subtracted;
                        the residual is the broadband process, without the skirts of the comb
  SSI-COV               covariance-driven stochastic subspace identification of the two real channels (I, Q)
                        of the residual: the poles of the station, whatever drives it.  The beam's mode is
                        the lightly damped pole pair near +-f_coh; it is picked from a stabilization diagram
                        over model orders.  Covariances of many short records (RFP RAM) can be averaged.
  joint sideband fit    Fano profile on both sidebands of the two-sided residual spectrum with one common
                        pole (f_coh, sigma) and separate numerators
Validation (--synthetic): model probe records (optllrf station models, beam included) driven by one
broadband source at a time plus the HVPS comb inferred at 492 mA (fill_crossing.infer_ripple), with an
analyzer floor; the pole estimates are compared with the model's pole and with the fits used so far
(Lorentzian and Fano per sideband, harmonics masked).  --ram repeats the SSI check for N records of 25.6 ms
with the RFP RAM's noise floor.  Writes results/probe_sysid_synthetic.csv, probe_sysid_ram.csv and
probe_sysid_<name>.png.

usage: python probe_sysid.py <record.npz|.mat> [--band 6000 11000]      analyze a record
       python probe_sysid.py --synthetic [--seeds 3]                   validation against the model
       python probe_sysid.py --ram [--records 10 40]                   RFP-RAM-length records
"""
import argparse
import math
from pathlib import Path

import numpy as np
from scipy.optimize import least_squares
from scipy.signal import decimate, welch

import optllrf as ol

F_MAINS = 60.0
BAND = (6000.0, 11000.0)
SOURCES_BB = ("klystron_PM", "klystron_AM", "measurement_PM", "measurement_AM")


# ----------------------------------------------------------------------------- record handling
def load(path: Path):
    if path.suffix == ".mat":
        from scipy.io import loadmat
        d = loadmat(path)
        return np.ravel(d["iq"]).astype(complex), float(np.ravel(d["fs"])[0])
    d = np.load(path)
    return d["iq"].astype(complex), float(d["fs"])


def relative_envelope(iq: np.ndarray, fs: float):
    """Complex envelope relative to the carrier, z = iq / <iq> - 1, after removing a residual carrier offset."""
    n = iq.size
    t = np.arange(n) / fs
    ph = np.unwrap(np.angle(iq))
    slope = np.polyfit(t, ph, 1)[0]
    z = iq * np.exp(-1j * slope * t)
    return z / np.mean(z) - 1.0, slope / (2 * np.pi)


# ----------------------------------------------------------------------------- harmonic regression
def _project(z, t, f, w):
    return np.sum(w * z * np.exp(-2j * np.pi * f * t)) / np.sum(w)


def mains_frequency(z, fs, fmax=12000.0, f_nom=F_MAINS, max_dev=0.08):
    """Mains frequency from the strongest harmonics in the whole record: each harmonic's peak in a zero-padded
    Hann spectrum, interpolated (parabola on log power), divided by its order; weighted median, weight n x SNR."""
    n = z.size
    nfft = 1 << int(math.ceil(math.log2(4 * n)))
    Z = np.abs(np.fft.fft((z - z.mean()) * np.hanning(n), nfft)) ** 2
    df = fs / nfft
    est, wts = [], []
    for h in range(1, int(fmax // f_nom) + 1):
        for sgn in (+1, -1):
            fc = sgn * h * f_nom
            half = h * max_dev + 2 * fs / n
            k0, k1 = int(math.floor((fc - half) / df)), int(math.ceil((fc + half) / df))
            idx = np.arange(k0, k1 + 1) % nfft
            seg = Z[idx]
            kp = int(np.argmax(seg))
            ring = Z[(np.arange(k0 - 400, k0 - 50)) % nfft]
            snr = seg[kp] / max(np.median(ring), 1e-300)
            if snr < 30 or kp == 0 or kp == seg.size - 1:
                continue
            y0, y1, y2 = np.log(seg[kp - 1]), np.log(seg[kp]), np.log(seg[kp + 1])
            d = 0.5 * (y0 - y2) / (y0 - 2 * y1 + y2)
            fpk = (k0 + kp + d) * df
            est.append(abs(fpk) / h)
            wts.append(h * math.log10(snr))
    if not est:
        return f_nom
    o = np.argsort(est)
    est, wts = np.array(est)[o], np.array(wts)[o]
    c = np.cumsum(wts)
    return float(est[np.searchsorted(c, 0.5 * c[-1])])


def harmonic_regression(z, fs, fmax=12000.0, block_s=2.0, f_nom=F_MAINS):
    """Estimate and subtract both sidebands of every mains harmonic up to fmax.

    The mains frequency comes from the strongest harmonics (mains_frequency).  Within each block (Hann weights)
    each sideband's complex amplitude is a windowed projection; harmonics 60 Hz apart leak into each other by
    less than -100 dB at 0.5 Hz resolution.  Returns the residual, the mains frequency and a table
    {(n, +1/-1): complex amplitude per block}."""
    n_blk = max(1, int(round(z.size / (block_s * fs))))
    L = z.size // n_blk
    w = np.hanning(L)
    f_m = mains_frequency(z, fs, fmax, f_nom)
    nmax = int(fmax // f_m)
    tab = {}
    model = np.zeros_like(z)
    wsum = np.sum(w)
    for b in range(n_blk):
        seg = slice(b * L, (b + 1) * L)
        zb, tt = z[seg] * w, np.arange(L) / fs + b * L / fs
        base = np.exp(2j * np.pi * f_m * tt)
        cur = np.ones(L, complex)
        acc = np.zeros(L, complex)
        for n in range(1, nmax + 1):
            cur *= base
            a_up = np.sum(zb * np.conj(cur)) / wsum
            a_lo = np.sum(zb * cur) / wsum
            tab.setdefault((n, +1), []).append(a_up)
            tab.setdefault((n, -1), []).append(a_lo)
            acc += a_up * cur + a_lo * np.conj(cur)
        model[seg] = acc
    return z - model, f_m, {k: np.array(v) for k, v in tab.items()}


# ----------------------------------------------------------------------------- SSI-COV
def output_covariances(y: np.ndarray, nlag: int):
    """R_i = E[y_{k+i} y_k^T], i = 0..nlag, for real channels y (N x m)."""
    N = y.shape[0]
    return np.array([y[i:].T @ y[:N - i] / (N - i) for i in range(nlag + 1)])


def ssi_poles(R: np.ndarray, fs: float, p: int, orders):
    """Covariance-driven SSI: block Hankel of R_1..R_{2p-1}, observability matrix, shift invariance."""
    m = R.shape[1]
    H = np.block([[R[i + j + 1] for j in range(p)] for i in range(p)])
    U, S, _ = np.linalg.svd(H)
    out = {}
    for n in orders:
        O = U[:, :n] * np.sqrt(S[:n])
        A = np.linalg.lstsq(O[:-m], O[m:], rcond=None)[0]
        lam = np.linalg.eigvals(A)
        lam = lam[np.abs(lam) > 1e-9]
        out[n] = np.log(lam) * fs
    return out, S


def beam_pole(poles: dict, band=BAND, sig_range=(30.0, 6000.0), df_rel=0.01, ds_rel=0.08):
    """The beam's pole from a stabilization diagram: poles in the band with positive frequency, kept when a pole
    within df_rel in frequency and ds_rel in damping exists at the previous order; the answer is the median of
    the largest cluster of stable poles."""
    orders = sorted(poles)
    cand = []
    prev = None
    for n in orders:
        s = poles[n]
        f, sg = s.imag / (2 * np.pi), -s.real
        k = (f > band[0]) & (f < band[1]) & (sg > sig_range[0]) & (sg < sig_range[1])
        cur = list(zip(f[k], sg[k]))
        if prev is not None:
            for fc, sc in cur:
                if any(abs(fc - fp) < df_rel * fc and abs(sc - sp) < ds_rel * sc for fp, sp in prev):
                    cand.append((n, fc, sc))
        prev = cur
    if not cand:
        return dict(f=float("nan"), sigma=float("nan"), n_stable=0, f_spread=float("nan"), sigma_spread=float("nan"))
    c = np.array(cand)
    bins = np.round(c[:, 1] / 50.0)
    vals, counts = np.unique(bins, return_counts=True)
    best = vals[np.argmax(counts)]
    sel = c[np.abs(bins - best) <= 1]
    return dict(f=float(np.median(sel[:, 1])), sigma=float(np.median(sel[:, 2])), n_stable=int(sel.shape[0]),
                f_spread=float(np.std(sel[:, 1])), sigma_spread=float(np.std(sel[:, 2])))


def ssi_record(z, fs, fs_dec=50e3, p=60, orders=range(8, 61, 2), band=BAND, covs=None):
    """Decimate the residual envelope to fs_dec, form (I, Q), and identify the beam's pole.  ``covs`` lets the
    caller pass averaged covariances of many short records instead."""
    if covs is None:
        y = to_channels(z, fs, fs_dec)
        covs = output_covariances(y, 2 * p)
    poles, S = ssi_poles(covs, fs_dec, p, orders)
    return beam_pole(poles, band), poles


def to_channels(z, fs, fs_dec):
    q = int(round(fs / fs_dec))
    zz = z
    while q > 1:
        k = min(q, 10)
        while q % k:
            k -= 1
        zz = decimate(zz, k, ftype="fir", zero_phase=True)
        q //= k
    y = np.column_stack([zz.real, zz.imag])
    return y - y.mean(0)


# ----------------------------------------------------------------------------- spectra and fits
def two_sided(z, fs, seg_s=1.0):
    nper = int(seg_s * fs)
    f, S = welch(z - z.mean(), fs, window="hann", nperseg=nper, detrend="constant", return_onesided=False)
    o = np.argsort(f)
    return f[o], S[o]


def joint_sideband_fit(f, S, start, window=(6000.0, 10500.0), mask_harmonics=False, f_mains=F_MAINS):
    """Fano profile on both sidebands with a common pole: S_side(x) = |p + r/(x - x0 + i g)|^2 + b, x = |f|."""
    sides = []
    for sgn in (+1, -1):
        x = sgn * f
        m = (x > window[0]) & (x < window[1])
        if mask_harmonics:
            m &= np.abs(x - f_mains * np.round(x / f_mains)) > 3.0
        sides.append((x[m], S[m]))
    b0 = [float(np.median(np.sort(s)[: max(10, s.size // 5)])) for _, s in sides]
    a0 = [max(float(np.max(np.convolve(s, np.ones(9) / 9, "same"))) - b, b) for (_, s), b in zip(sides, b0)]
    g0, x00 = start["hwhm"], start["f"]
    p0 = [x00, g0]
    sc = [1.0, 1.0]
    for a, b in zip(a0, b0):
        p0 += [0.3 * math.sqrt(b), math.sqrt(a) * g0, 0.0, 0.9 * b]
        sc += [math.sqrt(b), math.sqrt(a) * g0, math.sqrt(a) * g0, b]
    p0, sc = np.array(p0), np.array(sc)

    def model(par, x, k):
        x0, g = par[0], par[1]
        p, rr, ri, b = par[2 + 4 * k: 6 + 4 * k]
        return np.abs(p + (rr + 1j * ri) / (x - x0 + 1j * g)) ** 2 + b

    def res(q):
        par = q * sc
        return np.concatenate([np.log(model(par, x, k)) - np.log(s) for k, (x, s) in enumerate(sides)])
    lo = [window[0], 5.0] + [0, -np.inf, -np.inf, 0] * 2
    hi = [window[1], 3000.0] + [np.inf, np.inf, np.inf, np.inf] * 2
    r = least_squares(res, p0 / sc, loss="soft_l1", f_scale=0.3, bounds=(np.array(lo) / sc, np.array(hi) / sc))
    x0, g = r.x[0] * sc[0], r.x[1] * sc[1]
    return dict(f=float(x0), hwhm=float(g), sigma=float(2 * math.pi * g), Q=float(x0 / (2 * g)))


def per_side_fits(f, S, mask_harmonics, f_mains=F_MAINS):
    """Lorentzian and Fano per sideband over 6-10 kHz, as used so far (analyze_iq.fit_sideband)."""
    import analyze_iq as aiq
    out = {}
    for name, sgn in (("upper", 1), ("lower", -1)):
        sel = sgn * f > 0
        x, s = sgn * f[sel], S[sel]
        o = np.argsort(x)
        x, s = x[o], s[o]
        if mask_harmonics:
            keep = np.abs(x - f_mains * np.round(x / f_mains)) > 3.0
            x, s = x[keep], s[keep]
        out[name] = aiq.fit_sideband(x, s)
    return out


def analyze_record(iq, fs, name, band=BAND, plot=True):
    z, f_off = relative_envelope(iq, fs)
    resid, f_m, tab = harmonic_regression(z, fs)
    f, S = two_sided(z, fs)
    fr, Sr = two_sided(resid, fs)
    ssi, poles = ssi_record(resid, fs, band=band)
    lor = per_side_fits(fr, Sr, mask_harmonics=False)
    start = dict(f=0.5 * (lor["upper"]["lorentz"]["f"] + lor["lower"]["lorentz"]["f"]),
                 hwhm=0.5 * (lor["upper"]["lorentz"]["hwhm"] + lor["lower"]["lorentz"]["hwhm"]))
    joint = joint_sideband_fit(fr, Sr, start)
    amps = {k: float(np.mean(np.abs(v))) for k, v in tab.items()}
    print(f"{name}: {iq.size / fs:.1f} s at {fs / 1e3:.0f} kS/s; mains {f_m:.4f} Hz; carrier offset {f_off:+.2f} Hz")
    print(f"  SSI (harmonics removed): f_coh {ssi['f']:.0f} Hz, sigma {ssi['sigma']:.0f}/s"
          f" (spread {ssi['f_spread']:.0f} Hz, {ssi['sigma_spread']:.0f}/s over {ssi['n_stable']} stable poles)")
    print(f"  joint sideband fit: f_coh {joint['f']:.0f} Hz, sigma {joint['sigma']:.0f}/s, Q {joint['Q']:.1f}")
    for side in ("upper", "lower"):
        print(f"  {side} sideband, Lorentzian {lor[side]['lorentz']['f']:.0f} Hz / {lor[side]['lorentz']['sigma']:.0f};"
              f" Fano {lor[side]['fano']['f']:.0f} Hz / {lor[side]['fano']['sigma']:.0f}")
    top = sorted(amps, key=lambda k: -amps[k])[:8]
    print("  strongest harmonics (sideband, rms amplitude relative to the carrier): "
          + ", ".join(f"{'+' if k[1] > 0 else '-'}{k[0] * f_m:.0f} Hz {20 * math.log10(amps[k] / math.sqrt(2)):.1f} dBc" for k in top))
    if plot:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        fig, ax = plt.subplots(1, 2, figsize=(12, 4.5))
        m = np.abs(f) < 15e3
        ax[0].semilogy(f[m] / 1e3, S[m], lw=0.5, color="0.6", label="record")
        ax[0].semilogy(fr[m] / 1e3, Sr[m], lw=0.8, color="k", label="harmonics removed")
        ax[0].set_xlabel("offset from the carrier (kHz)")
        ax[0].set_ylabel("two-sided spectral density (1/Hz)")
        ax[0].legend(fontsize=8)
        ax[0].grid(alpha=0.3, which="both")
        for n, s in poles.items():
            k = (s.imag > 0) & (s.imag / (2 * np.pi) < 15e3) & (-s.real < 8000)
            ax[1].plot(s.imag[k] / (2 * np.pi * 1e3), np.full(k.sum(), n), "k.", ms=3)
        ax[1].axvline(ssi["f"] / 1e3, color="tab:red", lw=0.8)
        ax[1].set_xlabel("pole frequency (kHz)")
        ax[1].set_ylabel("model order")
        ax[1].set_title(f"stabilization diagram: f_coh {ssi['f']:.0f} Hz, sigma {ssi['sigma']:.0f}/s", fontsize=9)
        ax[1].grid(alpha=0.3)
        fig.tight_layout()
        fig.savefig(ol.RESULTS / f"probe_sysid_{name}.png", dpi=120)
    return dict(ssi=ssi, joint=joint, per_side=lor, f_mains=f_m, harmonics=amps)


# ----------------------------------------------------------------------------- synthetic records
def synth_iq(model, I, broadband, comb=None, fs=50e3, seconds=16.0, f_mains=60.012, floor_dbc_hz=-125.0, seed=1):
    """Probe envelope (relative to the carrier) of the station model at I mA.

    broadband: {source: one-sided spectral density per Hz}; comb: {source: {n: rms amplitude}} for mains
    harmonics at n * f_mains (random phases); floor: white analyzer noise.  Beam motion included."""
    rng = np.random.default_rng(seed)
    q = ol.station(I, model)
    va = q.V_k0[q.probe]
    n = int(seconds * fs)
    fpos = np.fft.rfftfreq(n, 1 / fs)
    r = q.response(np.maximum(fpos, 1e-3))
    E = np.zeros(n, complex)
    neg = np.arange(1, n - fpos.size + 1)
    for src, psd in broadband.items():
        W = (r.probe[src] + r.beam_to_probe * (r.chi * r.drive[src])[:, None]) / va
        U = (rng.normal(size=fpos.size) + 1j * rng.normal(size=fpos.size)) * math.sqrt(psd * fs * n / 4)
        U[0] = 0.0
        E[: fpos.size] += (W[:, 0] + 1j * W[:, 1]) * U
        E[-neg] += (np.conj(W[neg, 0]) + 1j * np.conj(W[neg, 1])) * np.conj(U[neg])
    z = np.fft.ifft(E)
    t = np.arange(n) / fs
    for src, lines in (comb or {}).items():
        hs = np.array(sorted(lines))
        rr = q.response(hs * f_mains)
        W = (rr.probe[src] + rr.beam_to_probe * (rr.chi * rr.drive[src])[:, None]) / va
        for k, h in enumerate(hs):
            amp = math.sqrt(2) * lines[h]
            ph = 2 * np.pi * rng.random()
            c = np.exp(1j * (2 * np.pi * h * f_mains * t + ph))
            zi = W[k, 0] * amp * c
            zq = W[k, 1] * amp * c
            z += 0.5 * ((zi + np.conj(zi)) + 1j * (zq + np.conj(zq)))
    sig = math.sqrt(10 ** (floor_dbc_hz / 10) * fs / 2)
    z += sig * (rng.normal(size=n) + 1j * rng.normal(size=n))
    m = ol.mode_or_none(q)
    return 1.0 + z, m


def calibrated_psd(model, I, src, peak_dbc_hz=-86.0):
    """Source spectral density that puts the upper synchrotron sideband of the probe at peak_dbc_hz."""
    q = ol.station(I, model)
    m = q.mode()
    f = np.linspace(m.frequency - 600, m.frequency + 600, 241)
    r = q.response(f)
    W = (r.probe[src] + r.beam_to_probe * (r.chi * r.drive[src])[:, None]) / q.V_k0[q.probe]
    up = np.abs(W[:, 0] + 1j * W[:, 1]) ** 2
    return 2 * 10 ** (peak_dbc_hz / 10) / up.max()


def comb_492(model="eff", src="klystron_PM"):
    import fill_crossing as fc
    lines = fc.load_lines(fc.CAPTURE)
    vu = fc.infer_ripple(lines, model, src)
    return {n: math.sqrt(v) for n, v in vu.items()}


def synthetic(seeds=3, model="eff", I=492.0):
    rows = []
    comb = {"klystron_PM": comb_492(model)}
    print(f"synthetic probe records, model {model}, {I:.0f} mA: 16 s at 50 kS/s, line peak -86 dBc/Hz,"
          f" {len(comb['klystron_PM'])} HVPS harmonics (5.5-10 kHz, 492 mA levels, as klystron phase), floor -125 dBc/Hz")
    for src in SOURCES_BB:
        psd = calibrated_psd(model, I, src)
        for seed in range(1, seeds + 1):
            iq, m = synth_iq(model, I, {src: psd}, comb, seed=seed)
            z, _ = relative_envelope(iq, 50e3)
            f, S = two_sided(z, 50e3)
            masked = per_side_fits(f, S, mask_harmonics=True)
            resid, f_m, _ = harmonic_regression(z, 50e3)
            fr, Sr = two_sided(resid, 50e3)
            clean = per_side_fits(fr, Sr, mask_harmonics=False)
            start = dict(f=0.5 * (clean["upper"]["lorentz"]["f"] + clean["lower"]["lorentz"]["f"]),
                         hwhm=0.5 * (clean["upper"]["lorentz"]["hwhm"] + clean["lower"]["lorentz"]["hwhm"]))
            joint = joint_sideband_fit(fr, Sr, start)
            ssi, _ = ssi_record(resid, 50e3)
            est = {"Lorentzian per side, comb masked": _mean_side(masked, "lorentz"),
                   "Fano per side, comb masked": _mean_side(masked, "fano"),
                   "Lorentzian per side, comb removed": _mean_side(clean, "lorentz"),
                   "Fano per side, comb removed": _mean_side(clean, "fano"),
                   "joint sidebands, common pole": (joint["f"], joint["sigma"]),
                   "SSI, comb removed": (ssi["f"], ssi["sigma"])}
            for meth, (fe, se) in est.items():
                rows.append([model, I, src, seed, meth, fe - m.frequency, 100 * (se / m.damping - 1), f_m])
    ol.save_csv(ol.RESULTS / "probe_sysid_synthetic.csv",
                ["model", "I_mA", "source", "seed", "method", "df_Hz", "dsigma_pct", "f_mains_est"], rows)
    print(f"  model pole: f_coh {m.frequency:.0f} Hz, sigma {m.damping:.0f}/s; mains estimated"
          f" {np.mean([r[7] for r in rows]):.4f} Hz (true 60.012)")
    meths = list(dict.fromkeys(r[4] for r in rows))
    print(f"  {'method':36s} " + " ".join(f"{s:>22s}" for s in SOURCES_BB))
    for meth in meths:
        cells = []
        for src in SOURCES_BB:
            v = np.array([(r[5], r[6]) for r in rows if r[4] == meth and r[2] == src])
            cells.append(f"{v[:, 0].mean():+5.0f}+-{v[:, 0].std():3.0f}Hz {v[:, 1].mean():+4.0f}+-{v[:, 1].std():2.0f}%")
        print(f"  {meth:36s} " + " ".join(f"{c:>22s}" for c in cells))
    print("wrote", ol.RESULTS / "probe_sysid_synthetic.csv")


def _mean_side(fits, kind):
    return (0.5 * (fits["upper"][kind]["f"] + fits["lower"][kind]["f"]),
            0.5 * (fits["upper"][kind]["sigma"] + fits["lower"][kind]["sigma"]))


def remove_lines_lsq(z, fs, freqs):
    """Least-squares removal of complex exponentials at the given (signed) frequencies from a short record."""
    t = np.arange(z.size) / fs
    A = np.exp(2j * np.pi * np.outer(t, np.asarray(freqs)))
    c = np.linalg.lstsq(A, z, rcond=None)[0]
    return z - A @ c


def ram_study(counts=(10, 40), model="eff", currents=(100.0, 250.0, 492.0), src="klystron_PM", seeds=3, comb=True,
              n_lines=24):
    """SSI on N records of 25.6 ms (the RFP cavity RAM), covariances averaged over the records, with the RAM's
    measured noise floor (-117 dBc/Hz).  With comb, the HVPS harmonics of 492 mA are added and each record's
    n_lines strongest harmonics (both sidebands, at a known mains frequency) are removed by least squares."""
    fs, fs_dec, p = 50e3, 25e3, 40
    rows = []
    psd = calibrated_psd(model, 492.0, src)
    lines = comb_492(model) if comb else None
    strongest = []
    if comb:
        q492 = ol.station(492.0, model)
        hs = np.array(sorted(lines))
        rr = q492.response(hs * 60.012)
        W = rr.probe[src] + rr.beam_to_probe * (rr.chi * rr.drive[src])[:, None]
        up, lo = ol.sidebands(W)
        lev = [(up[k] * lines[h] ** 2, h, +1) for k, h in enumerate(hs)] + [(lo[k] * lines[h] ** 2, h, -1) for k, h in enumerate(hs)]
        strongest = [s * h * 60.012 for _, h, s in sorted(lev, reverse=True)[:n_lines]]
    print(f"RFP-RAM-length records: 25.6 ms each, floor -117 dBc/Hz, source {src} at the level that gives -86 dBc/Hz"
          f" at 492 mA, model {model}" + (f"; HVPS comb of 492 mA, {n_lines} strongest sidebands removed per record" if comb
                                          else "; no HVPS comb"))
    for I in currents:
        q = ol.station(I, model)
        m = q.mode()
        for N in counts:
            for seed in range(1, seeds + 1):
                iq, _ = synth_iq(model, I, {src: psd}, {src: lines} if comb else None, fs=fs, seconds=0.0256 * N,
                                 floor_dbc_hz=-117.0, seed=seed)
                z, _ = relative_envelope(iq, fs)
                L = int(0.0256 * fs)
                covs = {"raw": None, "removed": None}
                for k in range(N):
                    seg = z[k * L:(k + 1) * L]
                    for tag, s in (("raw", seg), ("removed", remove_lines_lsq(seg, fs, strongest) if comb else seg)):
                        y = to_channels(s - s.mean(), fs, fs_dec)
                        c = output_covariances(y, 2 * p)
                        covs[tag] = c if covs[tag] is None else covs[tag] + c
                for tag in (("raw", "removed") if comb else ("raw",)):
                    est, _ = ssi_record(None, fs_dec, fs_dec=fs_dec, p=p, covs=covs[tag] / N)
                    label = ("comb " + tag) if comb else "no comb"
                    rows.append([model, I, src, N, seed, label, est["f"] - m.frequency, 100 * (est["sigma"] / m.damping - 1)])
            for tag in (("raw", "removed") if comb else ("raw",)):
                label = ("comb " + tag) if comb else "no comb"
                v = np.array([r[6:8] for r in rows if r[1] == I and r[3] == N and r[5] == label])
                print(f"  {I:5.0f} mA (model f_coh {m.frequency:.0f} Hz, sigma {m.damping:.0f}/s), {N:3d} records, {label:12s}:"
                      f" df {np.nanmean(v[:, 0]):+.0f} +- {np.nanstd(v[:, 0]):.0f} Hz, dsigma {np.nanmean(v[:, 1]):+.0f}"
                      f" +- {np.nanstd(v[:, 1]):.0f}%")
    return rows


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("record", nargs="?")
    ap.add_argument("--band", type=float, nargs=2, default=BAND)
    ap.add_argument("--synthetic", action="store_true")
    ap.add_argument("--seeds", type=int, default=3)
    ap.add_argument("--ram", action="store_true")
    ap.add_argument("--records", type=int, nargs="+", default=[10, 40])
    a = ap.parse_args()
    if a.synthetic:
        synthetic(a.seeds)
    if a.ram:
        rows = ram_study(tuple(a.records), seeds=a.seeds, comb=False) + ram_study(tuple(a.records), seeds=a.seeds, comb=True)
        ol.save_csv(ol.RESULTS / "probe_sysid_ram.csv",
                    ["model", "I_mA", "source", "records", "seed", "comb", "df_Hz", "dsigma_pct"], rows)
        print("wrote", ol.RESULTS / "probe_sysid_ram.csv")
    if a.record:
        p = Path(a.record)
        iq, fs = load(p)
        analyze_record(iq, fs, p.stem, tuple(a.band))
    if not (a.synthetic or a.ram or a.record):
        ap.error("give a record, --synthetic or --ram")


if __name__ == "__main__":
    main()
