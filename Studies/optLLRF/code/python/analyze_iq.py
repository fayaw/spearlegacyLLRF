"""I/Q capture of a cavity probe: amplitude and phase spectra, the synchrotron line, and the line comb.

A complex-baseband record of the probe (carrier near 0 Hz) separates what a swept spectrum
cannot: the relative amplitude a(t) and the phase phi(t) of the field, their cross-spectrum and,
for every n x 60 Hz harmonic, its AM and PM content.  The script
  * centres the carrier, normalizes the envelope and forms a(t), phi(t)
  * computes one-sided spectral densities S_a, S_phi and their coherence (Welch, Hann)
  * fits the two synchrotron sidebands of the complex envelope (Lorentzian and Fano, harmonics
    masked) over 6-10 kHz and again within +/- 3 HWHM; use these, not the lines in S_phi or S_a,
    for sigma and f_coh (the synthetic test shows why)
  * lists the 60 Hz harmonics between fmin and fmax with their AM and PM levels
Input: .npz or .mat with the complex samples ``iq`` and the sample rate ``fs`` [Hz]
(fsw_iq_capture.py writes this format).  Writes results/iq_<name>.csv/.png.

usage: python analyze_iq.py <record.npz|.mat> [--fmin 6000] [--fmax 10000]
       python analyze_iq.py --synthetic [--source klystron_AM]
           model probe records, one noise source each (all four by default): fit errors against the
           model's pole for the noisy record and for the exact spectrum -> results/iq_synthetic_bias.csv
"""
import argparse
import math
from pathlib import Path

import numpy as np
from scipy.optimize import least_squares
from scipy.signal import csd, welch

import optllrf as ol


def load(path: Path):
    if path.suffix == ".mat":
        from scipy.io import loadmat
        d = loadmat(path)
        return np.ravel(d["iq"]).astype(complex), float(np.ravel(d["fs"])[0])
    d = np.load(path)
    return d["iq"].astype(complex), float(d["fs"])


def envelope(iq: np.ndarray, fs: float):
    """Remove the carrier's residual frequency offset and return relative amplitude and phase [rad]."""
    n = iq.size
    spec = np.abs(np.fft.fft(iq * np.hanning(n)))
    f = np.fft.fftfreq(n, 1 / fs)
    near = np.abs(f) < 50.0
    f0 = f[near][np.argmax(spec[near])]
    t = np.arange(n) / fs
    z = iq * np.exp(-2j * np.pi * f0 * t)
    z = z / np.mean(z)
    a = np.abs(z) - 1.0
    ph = np.unwrap(np.angle(z))
    ph -= np.polyval(np.polyfit(t, ph, 1), t)
    return a, ph, f0


def spectra(a, ph, fs, seg_s=2.0):
    nper = int(seg_s * fs)
    f, Sa = welch(a, fs, window="hann", nperseg=nper, detrend="constant")
    _, Sp = welch(ph, fs, window="hann", nperseg=nper, detrend="constant")
    _, Sap = csd(a, ph, fs, window="hann", nperseg=nper, detrend="constant")
    coh = np.abs(Sap) ** 2 / (Sa * Sp)
    return f, Sa, Sp, coh


def fit_line(f, S, window=(6000.0, 9990.0)):
    m = (f > window[0]) & (f < window[1])
    m &= np.abs(f - 60 * np.round(f / 60)) > 3.0
    x, y = f[m], S[m]
    k = int(np.argmax(np.convolve(y, np.ones(9) / 9, mode="same")))
    q0 = np.array([y[k], x[k], 150.0, np.median(np.sort(y)[: max(10, y.size // 5)])])
    sc = np.array([q0[0], 1.0, 1.0, q0[3]])

    def lor(p, xx):
        a_, x0, g, b = p
        return a_ * g ** 2 / ((xx - x0) ** 2 + g ** 2) + b

    r = least_squares(lambda p: np.log(lor(p * sc, x)) - np.log(y), q0 / sc, loss="soft_l1", f_scale=0.3,
                      bounds=([0, window[0], 5, 0], [np.inf, window[1], 3000, np.inf]))
    a_, x0, g, b = r.x * sc
    return dict(f=float(x0), hwhm=float(g), sigma=float(2 * math.pi * g), Q=float(x0 / (2 * g)),
                peak=float(a_ + b), floor=float(b))


def refine_line(f, S, first, k=3.0):
    """Second pass within +/- k HWHM of a first fit, floor held at the first-pass value: the
    probe line is not an exact Lorentzian far from its peak, so a wide window biases the pole."""
    lo, hi = first["f"] - k * first["hwhm"], first["f"] + k * first["hwhm"]
    m = (f > lo) & (f < hi) & (np.abs(f - 60 * np.round(f / 60)) > 3.0)
    x, y, b = f[m], S[m], first["floor"]
    q0 = np.array([max(first["peak"] - b, 1e-30), first["f"], first["hwhm"]])
    sc = np.array([q0[0], 1.0, 1.0])

    def lor(p, xx):
        a_, x0, g = p
        return a_ * g ** 2 / ((xx - x0) ** 2 + g ** 2) + b

    r = least_squares(lambda p: np.log(lor(p * sc, x)) - np.log(y), q0 / sc, loss="soft_l1", f_scale=0.3,
                      bounds=([0, lo, 5], [np.inf, hi, 3000]))
    a_, x0, g = r.x * sc
    return dict(f=float(x0), hwhm=float(g), sigma=float(2 * math.pi * g), Q=float(x0 / (2 * g)),
                peak=float(a_ + b), floor=float(b), window=(float(lo), float(hi)))


def harmonics(f, Sa, Sp, fmin, fmax, df):
    """AM and PM power [dBc-equivalent, i.e. mean-square of a and phi] of each 60 Hz harmonic."""
    out = []
    for n in range(int(math.ceil(fmin / 60)), int(fmax // 60) + 1):
        fl = 60.0 * n
        m = np.abs(f - fl) <= 1.5 * df
        if not m.any():
            continue
        pa, pp = float(np.sum(Sa[m]) * df), float(np.sum(Sp[m]) * df)
        side = (np.abs(f - fl) > 4 * df) & (np.abs(f - fl) < 25.0)
        fa, fp = float(np.median(Sa[side]) * 3 * df), float(np.median(Sp[side]) * 3 * df)
        out.append(dict(f=fl, n=n, am_ms=pa, pm_ms=pp, am_excess_db=10 * math.log10(pa / fa),
                        pm_excess_db=10 * math.log10(pp / fp)))
    return out


def fit_sideband(x, S):
    """Lorentzian and Fano fits of one sideband: over 6-10 kHz, and refined within +/- 3 HWHM."""
    keep = np.abs(x - 60 * np.round(x / 60)) > 3.0
    lor = fit_line(x, S)
    fano = ol.fano_fit(x[keep], S[keep], lor)
    nar = refine_line(x, S, lor)
    fano_n = ol.fano_fit(x[keep], S[keep], nar, window=nar["window"])
    return dict(lorentz=lor, fano=fano, lorentz_narrow=nar, fano_narrow=fano_n)


def sideband_lines(z: np.ndarray, fs: float, seg_s=2.0):
    """Two-sided spectrum of the normalized complex envelope: upper (f > 0) and lower (f < 0)
    sidebands, each fitted with a Lorentzian and with the Fano profile (harmonics masked)."""
    nper = int(seg_s * fs)
    f2, S2 = welch(z - np.mean(z), fs, window="hann", nperseg=nper, detrend="constant", return_onesided=False)
    out = {}
    for side, sel in (("upper", f2 > 0), ("lower", f2 < 0)):
        x, S = np.abs(f2[sel]), S2[sel]
        o = np.argsort(x)
        out[side] = fit_sideband(x[o], S[o])
    return out


def analyze(iq, fs, name, fmin=6000.0, fmax=10000.0, plot=True, save=True):
    a, ph, f0 = envelope(iq, fs)
    f, Sa, Sp, coh = spectra(a, ph, fs)
    df = f[1] - f[0]
    line_p, line_a = fit_line(f, Sp), fit_line(f, Sa)
    z = (1.0 + a) * np.exp(1j * ph)
    sb = sideband_lines(z, fs)
    print(f"{name}: {iq.size / fs:.1f} s at {fs / 1e3:.0f} kS/s, carrier offset {f0:+.2f} Hz, resolution {df:.2f} Hz")
    print(f"  rms amplitude {np.std(a):.2e}, rms phase {math.degrees(np.std(ph)):.3f} deg (whole band)")
    for side in ("upper", "lower"):
        r_ = sb[side]
        print(f"  {side} sideband, 6-10 kHz | +/-3 HWHM: Lorentzian f {r_['lorentz']['f']:7.1f} | "
              f"{r_['lorentz_narrow']['f']:7.1f} Hz, sigma {r_['lorentz']['sigma']:5.0f} | "
              f"{r_['lorentz_narrow']['sigma']:5.0f}/s; Fano f {r_['fano']['f']:7.1f} | {r_['fano_narrow']['f']:7.1f} Hz,"
              f" sigma {r_['fano']['sigma']:5.0f} | {r_['fano_narrow']['sigma']:5.0f}/s"
              f" (asymmetry {math.degrees(r_['fano']['asymmetry']):+.0f} deg)")
    for tag, ln in (("phase", line_p), ("amplitude", line_a)):
        print(f"  line in the {tag:9s} spectrum (Lorentzian): f {ln['f']:7.1f} Hz, sigma {ln['sigma']:6.0f}/s,"
              f" peak/floor {10 * math.log10(ln['peak'] / ln['floor']):5.1f} dB")
    hs = [h for h in harmonics(f, Sa, Sp, fmin, fmax, df) if max(h["am_excess_db"], h["pm_excess_db"]) > 6.0]
    if hs:
        print("  harmonics above the local floor (AM and PM rms, deg-equivalent for PM):")
        for h in sorted(hs, key=lambda h: -(h["am_ms"] + h["pm_ms"]))[:15]:
            print(f"    {h['f']:7.0f} Hz (n {h['n']:3d}{', 6-pulse' if h['n'] % 6 == 0 else ''}): AM {math.sqrt(h['am_ms']):.2e}"
                  f" (+{h['am_excess_db']:4.1f} dB), PM {math.degrees(math.sqrt(h['pm_ms'])):.4f} deg"
                  f" (+{h['pm_excess_db']:4.1f} dB)")
    rows = [[h["f"], h["n"], h["am_ms"], h["pm_ms"], h["am_excess_db"], h["pm_excess_db"]] for h in hs]
    if save:
        ol.save_csv(ol.RESULTS / f"iq_{name}.csv", ["f_Hz", "harmonic", "am_ms", "pm_ms", "am_excess_dB", "pm_excess_dB"],
                    rows)
    if plot:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        m = (f > 2000) & (f < 12000)
        fig, ax = plt.subplots(2, 1, figsize=(9, 6.5), sharex=True)
        ax[0].semilogy(f[m] / 1e3, Sp[m], lw=0.6, label="phase S_phi (rad^2/Hz)")
        ax[0].semilogy(f[m] / 1e3, Sa[m], lw=0.6, label="relative amplitude S_a (1/Hz)")
        ax[0].legend(fontsize=8)
        ax[0].set_ylabel("one-sided spectral density")
        ax[0].grid(alpha=0.3, which="both")
        ax[1].plot(f[m] / 1e3, coh[m], lw=0.6)
        ax[1].set_ylabel("AM-PM coherence")
        ax[1].set_xlabel("offset from the carrier (kHz)")
        ax[1].grid(alpha=0.3)
        fig.suptitle(f"{name}: probe amplitude and phase", fontsize=10)
        fig.tight_layout()
        fig.savefig(ol.RESULTS / f"iq_{name}.png", dpi=130)
    return dict(phase=line_p, amplitude=line_a, sidebands=sb, harmonics=hs)


def synthetic(model="eff", I=500.0, seconds=16.0, fs=50e3, seed=2, source="klystron_AM"):
    """Probe envelope of cavity A from broadband noise of one source and two discrete lines of the
    same source, through the full beam-cavity-loop response of the model (beam motion included).
    Returns the line-fit errors against the model's pole, for the noisy record and for the exact
    (noise-free) probe spectrum, so that statistical and systematic errors can be told apart."""
    from spear3rf.quadrature import sidebands

    rng = np.random.default_rng(seed)
    q = ol.station(I, model)
    m = q.mode()
    n = int(seconds * fs)
    fpos = np.fft.rfftfreq(n, 1 / fs)
    r = q.response(np.maximum(fpos, 1e-3))
    W = r.probe[source] + r.beam_to_probe * (r.chi * r.drive[source])[:, None]   # (I,Q) per unit source
    psd = 3e-11                                                            # one-sided, per Hz
    U = (rng.normal(size=fpos.size) + 1j * rng.normal(size=fpos.size)) * math.sqrt(psd * fs * n / 4)
    for fl, amp in ((8640.0, 4e-5), (9000.0, 6e-5)):                       # discrete lines (peak)
        k = int(round(fl * n / fs))
        U[k] += amp * n / 2 * np.exp(2j * np.pi * rng.random())
    U[0] = 0.0
    E = np.zeros(n, complex)
    E[: fpos.size] = (W[:, 0] + 1j * W[:, 1]) * U
    neg = np.arange(1, n - fpos.size + 1)
    E[-neg] = (np.conj(W[neg, 0]) + 1j * np.conj(W[neg, 1])) * np.conj(U[neg])
    e = np.fft.ifft(E)
    va = q.V_k0[q.probe]
    iq = va + e
    print(f"synthetic probe, model {model}, {I:.0f} mA, source {source}: model line f {m.frequency:.0f} Hz,"
          f" sigma {m.damping:.0f}/s, Q {m.Q:.1f}")
    default = source == "klystron_AM"
    tag = f"synthetic_{model}_{int(I)}mA" + ("" if default else f"_{source}")
    res = analyze(iq, fs, tag, plot=default, save=default)
    usb, lsb = sidebands(W)
    band = (fpos > 5000) & (fpos < 11000)
    exact = {"upper": fit_sideband(fpos[band], psd * usb[band]), "lower": fit_sideband(fpos[band], psd * lsb[band])}
    peak = {s: float(fpos[band][np.argmax(v[band])]) for s, v in (("upper", usb), ("lower", lsb))}
    rows = []
    print(f"  recovered relative to the model pole (frequency offset, damping error); exact-spectrum peak at"
          f" {peak['upper'] - m.frequency:+.0f} / {peak['lower'] - m.frequency:+.0f} Hz (upper/lower)")
    for data, fits in (("noisy", res["sidebands"]), ("exact", exact)):
        for side in ("upper", "lower"):
            for kind in ("lorentz", "lorentz_narrow", "fano", "fano_narrow"):
                ln = fits[side][kind]
                dfr, dsg = ln["f"] - m.frequency, 100 * (ln["sigma"] / m.damping - 1)
                rows.append([model, I, source, data, side, kind, dfr, dsg])
                print(f"    {data:5s} {side} sideband, {kind:14s}: {dfr:+5.0f} Hz, {dsg:+4.0f}%")
    for kind in ("phase", "amplitude"):
        ln = res[kind]
        dfr, dsg = ln["f"] - m.frequency, 100 * (ln["sigma"] / m.damping - 1)
        rows.append([model, I, source, "noisy", kind + " spectrum", "lorentz", dfr, dsg])
        print(f"    noisy {kind} spectrum, lorentz: {dfr:+5.0f} Hz, {dsg:+4.0f}%")
    return rows


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("record", nargs="?")
    ap.add_argument("--fmin", type=float, default=6000.0)
    ap.add_argument("--fmax", type=float, default=10000.0)
    ap.add_argument("--synthetic", action="store_true")
    ap.add_argument("--model", default="eff", choices=sorted(ol.MODELS))
    ap.add_argument("--source", default=None, choices=ol.SOURCES,
                    help="synthetic: one source only (default: all four; writes iq_synthetic_bias.csv)")
    a = ap.parse_args()
    if a.synthetic:
        rows = []
        for src in ([a.source] if a.source else ol.SOURCES):
            rows += synthetic(a.model, source=src)
        if not a.source:
            p = ol.save_csv(ol.RESULTS / "iq_synthetic_bias.csv",
                            ["model", "I_mA", "source", "data", "spectrum", "fit", "df_Hz", "dsigma_pct"], rows)
            print("wrote", p)
    elif a.record:
        p = Path(a.record)
        iq, fs = load(p)
        analyze(iq, fs, p.stem, a.fmin, a.fmax)
    else:
        ap.error("give a record or --synthetic")


if __name__ == "__main__":
    main()
