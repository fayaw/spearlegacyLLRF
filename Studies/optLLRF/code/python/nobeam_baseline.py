"""No-beam baseline of 3 November 2026 against the 500 mA capture of 8 October 2026 (cavity-A probe).

Reproduces the numbers and figures of ../../SPEAR3_Synchrotron_Oscillation_Review.md from stored data:
  spear3rf/data/spectra/FSW_cavA_nobeam_20261103T093904.json  swept, five set-ups, no beam (fsw_nobeam_capture.py)
  spear3rf/data/spectra/FSW_cavA_matrix_20261008T153523.json  swept, 492 mA (spear3rf/scripts/fsw_matrix.py)
  data/iq/FSW_IQ_20261103T094550.npz                          I/Q, 16 s at 50 kS/s, no beam (fsw_iq_capture_guarded.py)
  data/epics/SRF1_loop_tuner_60s_20261103T094714.csv          loop phase and tuner readbacks, 60 s (caget only)
  results/lines_FSW_cavA_matrix_20261008T153523.csv           500 mA line table (lines_near_fcoh.py)
  spear3rf/data/snapshots/SRF1_20261103T*.json                EPICS snapshots (spear3rf.live, caget only)

usage: python nobeam_baseline.py      (about 1 min)
outputs: results/nobeam_20261103.log, results/nobeam_20261103_lines.csv,
         results/nobeam_20261103_spectra.png, results/nobeam_20261103_iq.png
"""
from __future__ import annotations

import csv
import json
import math

import numpy as np
from scipy.ndimage import median_filter
from scipy.signal import find_peaks, welch
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

import optllrf as O  # noqa: E402
import probe_sysid as P  # noqa: E402

SPEC = O.ROOT / "spear3rf" / "data" / "spectra"
SNAPS = O.ROOT / "spear3rf" / "data" / "snapshots"
NOBEAM = SPEC / "FSW_cavA_nobeam_20261103T093904.json"
BEAM = SPEC / "FSW_cavA_matrix_20261008T153523.json"
IQ = O.STUDY / "data" / "iq" / "FSW_IQ_20261103T094550.npz"
LINES500 = O.RESULTS / "lines_FSW_cavA_matrix_20261008T153523.csv"
TAG = "nobeam_20261103"
COT = 1 / math.tan(math.radians(67.5))     # cot(phi_s): n_eff = eps_A cot(phi_s) - eps_phi (Doc P eq:rob-driven)
F_S = 10.03e3                             # incoherent synchrotron frequency at 500 mA (Doc P)
F_COH, SIGMA = 8810.0, 1120.0             # measured line at 492-497 mA, 8 Oct 2026 (Doc P tab:robinson-today)
# lines processed by the DSP ripple loop (spear-rf-code-legacy/iocBoot/tbl/Sp3PhsCoefs.tbl, rev 1.2)
RIPPLE_LINES = (60, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1080, 1200, 1380,
                1440, 1680, 1800, 1920, 2040, 2160, 2280, 2400, 2520, 2760, 2880)
# study plan, Appendix A, 500 mA: COUNTS.A [dB], f_coh [Hz], sigma [1/s]
APP_A = {"eff": [(-1.7, 8358, 1682), (-0.2, 8550, 1363), (1.3, 8741, 1074), (2.8, 8925, 824), (4.3, 9098, 620)],
         "lag": [(-1.7, 7474, 1839), (-0.2, 7621, 1465), (1.3, 7778, 1101), (2.8, 7944, 759), (4.3, 8116, 449)]}
LOG: list[str] = []


def log(*a):
    s = " ".join(str(x) for x in a)
    print(s)
    LOG.append(s)


def db(x):
    return 10 * np.log10(np.maximum(x, 1e-300))


def axis(s):
    tr = np.array(s["trace_dBm"], float)
    return np.linspace(float(s["start_Hz"]), float(s["stop_Hz"]), tr.size), tr


def band_floor(c, lo, hi, side):
    """Median of the bins between the 60 Hz harmonics in lo < side*offset < hi [dBc/Hz]."""
    x = side * c["off"]
    m = (x > lo) & (x < hi) & O.line_mask(c["off"], c["rbw"])
    return float(db(np.median(10 ** (c["dbc_hz"][m] / 10))))


def interline_profile(path, lo=1500, hi=5000, step=100):
    c = O.load_fsw(path, "robinson")
    return np.array([(f0 + step / 2, band_floor(c, f0, f0 + step, +1), band_floor(c, f0, f0 + step, -1))
                     for f0 in range(lo, hi, step)])


def block_mains(z, fs, f_nom, L, ns=(126, 138, 150, 162, 174)):
    """Mains frequency per block of L samples from strong high harmonics (zero-padded Hann peak, parabolic fit)."""
    nfft = 1 << 20
    df = fs / nfft
    w = np.hanning(L)
    out = []
    for b in range(z.size // L):
        seg = z[b * L:(b + 1) * L]
        Z = np.abs(np.fft.fft((seg - seg.mean()) * w, nfft)) ** 2
        est = []
        for n in ns:
            for sgn in (+1, -1):
                k0, k1 = int((sgn * n * f_nom - 4) / df), int((sgn * n * f_nom + 4) / df)
                idx = np.arange(k0, k1 + 1) % nfft
                kp = int(np.argmax(Z[idx]))
                y0, y1, y2 = np.log(Z[idx[kp - 1]]), np.log(Z[idx[kp]]), np.log(Z[idx[kp + 1]])
                d = 0.5 * (y0 - y2) / (y0 - 2 * y1 + y2)
                est.append(abs((k0 + kp + d) * df) / n)
        out.append(float(np.median(est)))
    return np.array(out)


def tracked_lines(z, fs, fm_blocks, L, nmax):
    """Both sidebands of every mains harmonic per block, at the block's own mains frequency: AM, PM, drive, and
    the residual with all harmonics removed (harmonic regression that follows the mains wander).

    z = a + j p with a = Re(A e^{jwt}), p = Re(Pm e^{jwt}):  A = u + conj(l),  Pm = -j (u - conj(l))."""
    w = np.hanning(L)
    t = np.arange(L) / fs
    nb = len(fm_blocks)
    U = np.zeros((nmax + 1, nb), complex)
    Lo = np.zeros((nmax + 1, nb), complex)
    resid = z[:nb * L].copy()
    for b, fm in enumerate(fm_blocks):
        zb = z[b * L:(b + 1) * L]
        base = np.exp(2j * np.pi * fm * t)
        cur = np.ones(L, complex)
        model = np.zeros(L, complex)
        for n in range(1, nmax + 1):
            cur *= base
            U[n, b] = np.sum(w * zb * np.conj(cur)) / w.sum()
            Lo[n, b] = np.sum(w * zb * cur) / w.sum()
            model += U[n, b] * cur + Lo[n, b] * np.conj(cur)
        resid[b * L:(b + 1) * L] = zb - model
    rows = {}
    fmean = float(np.mean(fm_blocks))
    for n in range(1, nmax + 1):
        u, l = U[n], Lo[n]
        A, Pm = u + np.conj(l), -1j * (u - np.conj(l))
        a, p = math.sqrt(np.mean(np.abs(A) ** 2) / 2), math.sqrt(np.mean(np.abs(Pm) ** 2) / 2)
        rows[n] = dict(n=n, f=n * fmean, six=n % 6 == 0, ripple=60 * n in RIPPLE_LINES,
                       usb=float(db(np.mean(np.abs(u) ** 2))), lsb=float(db(np.mean(np.abs(l) ** 2))),
                       am=a, pm=p, drive=math.hypot(COT * a, p))
    return rows, resid


def loop_nobeam(f, G=0.88, tau=625e-9, ql=6800, fi=2.93e3, fl=0.26e3):
    """Direct loop without beam, cavities on tune: gain and delay fitted at 20-22 mA (Doc P tab:mdc-fits),
    RFP lead (944 kHz / 2.39 MHz) and lag (2.93 kHz, leak 0.26 kHz) networks, 2.5 MHz amplifier pole."""
    s = 2j * np.pi * np.asarray(f, float)
    w12 = 2 * np.pi * 476.3e6 / (2 * ql)
    lead = (1 + s / (2 * np.pi * 944e3)) / (1 + s / (2 * np.pi * 2.39e6))
    lag = 1 + 2 * np.pi * fi / (s + 2 * np.pi * fl)
    amp = 2 * np.pi * 2.5e6 / (s + 2 * np.pi * 2.5e6)
    return G * lead * lag * amp * w12 / (s + w12) * np.exp(-s * tau)


def chi(f, f_coh=F_COH, sigma=SIGMA):
    """Beam response |Delta phi / n_eff| of the dipole mode as a second-order resonance (Doc P eq:rob-response)."""
    ws, wc, w = 2 * np.pi * F_S, 2 * np.pi * f_coh, 2 * np.pi * np.asarray(f, float)
    return ws ** 2 / np.sqrt((wc ** 2 + sigma ** 2 - w ** 2) ** 2 + 4 * sigma ** 2 * w ** 2)


def section_state():
    log("=" * 110)
    log("1. Station state, 3 Nov 2026 (EPICS snapshots, caget only)")
    snaps = sorted(SNAPS.glob("SRF1_20261103T*.json"))
    log("   time    beam  PHASE.C PHASE.K PHASE.L  avg FREQ:OFFS | FREQ:OFFS cav1-4 (kHz)     | tuner RBV cav1-4 (mm)       |"
        " load-angle err (deg)")
    for p in snaps:
        v = json.load(open(p, encoding="utf-8"))["values"]
        log(f"   {p.stem[-6:]}  {v['beam_current_mA']:4.1f}  {v['direct_phase_C']:6.1f} {v['direct_phase_K']:+6.2f} "
            f"{v['direct_phase_L']:7.2f}  {v['direct_phase_J']:8.2f}     | "
            + " ".join(f"{v[f'cav{n}_freq_offs_kHz']:6.1f}" for n in range(1, 5)) + " | "
            + " ".join(f"{v[f'cav{n}_tuner_mm']:6.3f}" for n in range(1, 5)) + " | "
            + " ".join(f"{v[f'cav{n}_load_angle_err_deg']:+5.2f}" for n in range(1, 5)))
    v = json.load(open(snaps[-1], encoding="utf-8"))["values"]
    log(f"   f_RF {v['f_rf_MHz']:.6f} MHz ({(v['f_rf_MHz'] - 476.303964) * 1e6:+.0f} Hz since 7 Oct 2026, set by the ring); "
        f"station {v['stn_volt_kV']:.0f} kV; klystron {v['kly_fwd_kW']:.0f} kW, drive {v['kly_drive_W']:.1f} W "
        f"({10 * math.log10(v['kly_drive_sat_W'] / v['kly_drive_W']):.1f} dB below SAT {v['kly_drive_sat_W']:.0f} W); "
        f"HVPS {v['hvps_kV']:.1f} kV {v['hvps_A']:.1f} A")
    log(f"   loop: COUNTS.A {v['direct_counts_A']} dB (L {v['direct_counts_L']:.3f}), PHASE.C {v['direct_phase_C']:.1f}, "
        f"PHASE.B {v['direct_phase_B']:.1f} ns, PHASE.F {v['direct_phase_F']:.2f}; tracking {v['direct_track']:.0f}, "
        f"INTCOMP {v['intcomp']:.0f}, LEADCOMP {v['leadcomp']:.0f}, DSP ripple {v['rfp_ripple']:.0f} "
        f"(DC coef {v['ripple_dc_coef']:.2f}, gain tracking {v['ripple_track']:.0f})")
    log("   reflection check without beam: |G|^2 = ((b-1)^2 + t^2) / ((b+1)^2 + t^2), t = 2 Q0 df / f0, b = 3.8, Q0 = 32000")
    log("   cav  |G|^2 meas  |G|^2 on tune  |df| from |G|^2 (kHz)  FREQ:OFFS (kHz)  |G|^2 at FREQ:OFFS")
    b, q0, f0 = 3.8, 32000.0, 476.3e6
    g2_at = lambda df: ((b - 1) ** 2 + (2 * q0 * df / f0) ** 2) / ((b + 1) ** 2 + (2 * q0 * df / f0) ** 2)  # noqa: E731
    for n in range(1, 5):
        g2 = v[f"cav{n}_refl_kW"] / v[f"cav{n}_fwd_kW"]
        t2 = (g2 * (b + 1) ** 2 - (b - 1) ** 2) / (1 - g2)
        dfm = math.sqrt(max(t2, 0.0)) * f0 / (2 * q0) / 1e3
        fo = v[f"cav{n}_freq_offs_kHz"]
        log(f"    {n}     {g2:6.3f}       {g2_at(0.0):6.3f}            {dfm:5.1f}               {fo:7.1f}           "
            f"{g2_at(fo * 1e3):6.3f}")
    rec = sorted((O.STUDY / "data" / "epics").glob("SRF1_loop_tuner_60s_*.csv"))
    if rec:
        a = np.genfromtxt(rec[-1], delimiter=",", names=True, skip_header=1)
        cols = a.dtype.names
        get = lambda key: np.asarray(a[[c for c in cols if key in c][0]], float)  # noqa: E731
        log(f"   60 s record {rec[-1].name}: PHASE.L {get('PHASEL').mean():.2f} +/- {get('PHASEL').std():.3f}, "
            f"PHASE.K {get('PHASEK').mean():+.2f} +/- {get('PHASEK').std():.3f} deg")
        for n in range(1, 5):
            posn, rbv = get(f"CAV{n}TUNRPOSN"), get(f"CAV{n}TUNRSTEPMOTORRBV")
            fo = get(f"CAV{n}FREQOFFS")
            log(f"     cav{n}: TUNR:POSN {posn.mean():7.3f} mm, motor RBV {rbv.mean():7.3f} mm (difference "
                f"{posn.mean() - rbv.mean():+.3f} mm), FREQ:OFFS {fo.mean():7.2f} +/- {fo.std():.2f} kHz")
    ks = [json.load(open(p, encoding="utf-8"))["values"]["direct_phase_K"] for p in snaps]
    log(f"   tracking correction PHASE.K in the snapshots: {', '.join(f'{k:+.2f}' for k in ks)} deg")
    return v


def section_swept():
    log("=" * 110)
    log("2. Swept spectra of the cavity-A probe: no beam (3 Nov 2026) against 492 mA (8 Oct 2026)")
    nb, bm = json.load(open(NOBEAM, encoding="utf-8")), json.load(open(BEAM, encoding="utf-8"))
    log(f"   {NOBEAM.name}: beam {nb['beam_current_mA']} mA, errors before/during/after {nb['errors_before']} | "
        f"{nb['errors_during']} | {nb['errors_after']}; restore differences {nb['restore_differences'] or 'none'}; "
        f"remote {nb['remote_session_s']} s")
    f, tr = axis(nb["setups"]["lines"])
    ic = int(np.argmax(tr))
    log(f"   carrier: no beam {tr[ic]:.2f} dBm, {f[ic] - nb['f_rf_Hz']:+.1f} Hz from SPEAR:RFFreq on the analyzer "
        f"(its time base is not the master oscillator); 492 mA {max(bm['setups']['lines']['trace_dBm']):.2f} dBm")
    cap = {"nb": O.load_fsw(NOBEAM, "robinson"), "bm": O.load_fsw(BEAM, "robinson")}
    log("   broadband level between the 60 Hz lines (30 Hz RBW, RMS, median, dBc/Hz): no beam USB/LSB | 492 mA USB/LSB")
    bands = {}
    for lo, hi in ((2000, 4000), (4000, 6000), (6000, 7500), (7500, 8500), (8500, 9200), (9200, 9990)):
        r = [band_floor(cap[k], lo, hi, s) for k in ("nb", "bm") for s in (+1, -1)]
        bands[(lo, hi)] = r
        log(f"     {lo:5d}-{hi:<5d} Hz   {r[0]:7.1f} / {r[1]:7.1f}   |   {r[2]:7.1f} / {r[3]:7.1f}")
    prof = {"nb": interline_profile(NOBEAM), "bm": interline_profile(BEAM)}
    log("   peak between 2.0 and 3.5 kHz in the 100 Hz medians, relative to the 3.6-5 kHz level:")
    for k, name in (("nb", "no beam"), ("bm", "492 mA")):
        arr = prof[k]
        for j, side in ((1, "USB"), (2, "LSB")):
            m = (arr[:, 0] > 2000) & (arr[:, 0] < 3500)
            i = int(np.argmax(np.where(m, arr[:, j], -999)))
            base = float(np.median(arr[(arr[:, 0] > 3600) & (arr[:, 0] < 5000), j]))
            log(f"     {name:7s} {side}: {arr[i, j]:6.1f} dBc/Hz at {arr[i, 0]:.0f} Hz, {arr[i, j] - base:+5.1f} dB")
    lf = {}
    for k, d in (("nb", nb), ("bm", bm)):
        f, tr = axis(d["setups"]["lines"])
        i0 = int(np.argmax(tr))
        found = O.find_lines(f - f[i0], tr - tr[i0], 50, 1090, min_excess_db=3.0)
        lf[k] = {(1 if x["offset"] > 0 else -1, x["harmonic"]): x["power_dbc"] for x in found}
    log("   line harmonics 60-1080 Hz (3 Hz RBW, dBc): f | no beam USB/LSB | 492 mA USB/LSB")
    for n in (1, 2, 4, 6, 7, 12, 18):
        g = lambda k, s: lf[k].get((s, n), float("nan"))  # noqa: E731
        log(f"     {60 * n:5d} Hz  {g('nb', 1):6.1f} / {g('nb', -1):6.1f}  |  {g('bm', 1):6.1f} / {g('bm', -1):6.1f}")
    for k, name in (("nb", "no beam"), ("bm", "492 mA")):
        log(f"     total of the detected lines, {name}: {db(sum(10 ** (x / 10) for x in lf[k].values())):.1f} dBc")
    wide = {"nb": O.load_fsw(NOBEAM, "wide"), "bm": O.load_fsw(BEAM, "wide")}
    log("   wideband floor (1 kHz RBW, median, dBc/Hz): no beam USB/LSB | 492 mA USB/LSB")
    for lo, hi in ((10e3, 30e3), (30e3, 120e3), (120e3, 500e3), (500e3, 1.4e6)):
        r = []
        for k in ("nb", "bm"):
            for s in (+1, -1):
                x = s * wide[k]["off"]
                r.append(float(np.median(wide[k]["dbc_hz"][(x > lo) & (x < hi)])))
        log(f"     {lo / 1e3:5.0f}-{hi / 1e3:<5.0f} kHz  {r[0]:7.1f} / {r[1]:7.1f}  |  {r[2]:7.1f} / {r[3]:7.1f}")
    return dict(nb=nb, bm=bm, cap=cap, prof=prof, bands=bands)


def section_iq():
    log("=" * 110)
    log("3. I/Q record of the cavity-A probe without beam")
    meta = json.loads(str(np.load(IQ)["meta"]))
    iq, fs = P.load(IQ)
    z, f_off = P.relative_envelope(iq, fs)
    log(f"   {IQ.name}: {iq.size} samples at {fs:.0f} S/s ({iq.size / fs:.1f} s), beam {meta['beam_current_mA']} mA; "
        f"errors before/during/after {meta['errors_before']} | {meta['errors_during']} | {meta['errors_after']}; "
        f"restore differences {meta['restore_differences'] or 'none'}; remote {meta['remote_session_s']} s")
    log(f"   total rms within +/-{fs / 2e3:.0f} kHz: amplitude {100 * z.real.std():.3f} %, phase {math.degrees(z.imag.std()):.3f} deg")
    fa_, Pa_ = welch(z.real, fs, nperseg=int(2 * fs), detrend="linear")
    _, Pp_ = welch(z.imag, fs, nperseg=int(2 * fs), detrend="linear")
    dfa = fa_[1] - fa_[0]
    log("   band-limited rms, lines included: band | amplitude | phase")
    for lo, hi in ((0.5, 55.0), (55.0, 2000.0), (2000.0, 12000.0), (12000.0, 25000.0)):
        m = (fa_ >= lo) & (fa_ < hi)
        log(f"     {lo:7.1f}-{hi:<7.0f} Hz: {100 * math.sqrt(np.sum(Pa_[m]) * dfa):.4f} %, "
            f"{math.degrees(math.sqrt(np.sum(Pp_[m]) * dfa)):.4f} deg")
    L = int(fs)
    fm_nom = P.mains_frequency(z, fs)
    fmb = block_mains(z, fs, fm_nom, L)
    log(f"   mains frequency per 1 s block: {fmb.min():.4f} to {fmb.max():.4f} Hz (one value for the record: {fm_nom:.4f} Hz)")
    rows, resid = tracked_lines(z, fs, fmb, L, nmax=199)
    _, _, tab = P.harmonic_regression(z, fs, fmax=12000.0)
    log("   line level with one mains frequency per record (probe_sysid.harmonic_regression) and tracked per 1 s block:")
    for n in (12, 126, 150, 162):
        log(f"     n {n:3d} ({rows[n]['f']:7.1f} Hz) USB {db(np.mean(np.abs(tab[(n, +1)]) ** 2)):6.1f} dBc fixed, "
            f"{rows[n]['usb']:6.1f} dBc tracked")
    seg = int(2 * fs)
    f1, Sa = welch(resid.real, fs, nperseg=seg, detrend="linear")
    _, Sp = welch(resid.imag, fs, nperseg=seg, detrend="linear")
    f2, Sz = welch(resid, fs, nperseg=seg, detrend="linear", return_onesided=False)
    f2, Sz = np.fft.fftshift(f2), np.fft.fftshift(Sz)
    med = lambda fr, S, lo, hi: float(np.median(S[(fr > lo) & (fr < hi)]))  # noqa: E731
    log("   broadband, harmonics removed (median): band | AM dB re 1/Hz | PM dB re rad^2/Hz | USB / LSB dBc/Hz | "
        "drive S_n = cot^2 S_A + S_phi (rad^2/Hz)")
    for lo, hi in ((300, 1000), (1000, 2000), (3000, 6000), (6000, 7500), (7500, 8500), (8500, 9200), (9200, 10000),
                   (10000, 12000)):
        sa, sp = med(f1, Sa, lo, hi), med(f1, Sp, lo, hi)
        log(f"     {lo / 1e3:4.1f}-{hi / 1e3:<5.1f} kHz  {db(sa):7.1f}   {db(sp):7.1f}   {db(med(f2, Sz, lo, hi)):7.1f} / "
            f"{db(med(f2, Sz, -hi, -lo)):7.1f}   {COT ** 2 * sa + sp:.2e}")
    log("   peak near 2.75 kHz (residual, 30 Hz running median, against the 3.6-5 kHz level):")
    Sm = median_filter(Sz, size=61)
    df = f2[1] - f2[0]
    for side in (+1, -1):
        x = side * f2
        base = float(np.median(Sm[(x > 3600) & (x < 5000)]))
        m = (x > 2000) & (x < 3500)
        i = int(np.argmax(np.where(m, Sm, 0.0)))
        fwhm = np.count_nonzero(m & (Sm > base + 0.5 * (Sm[i] - base))) * df
        exc = float(np.sum(np.clip(Sm[m] - base, 0, None)) * df)
        log(f"     {'USB' if side > 0 else 'LSB'}: {db(Sm[i]):6.1f} dBc/Hz at {abs(f2[i]):.0f} Hz, FWHM {fwhm:.0f} Hz, "
            f"{db(Sm[i]) - db(base):+.1f} dB over {db(base):.1f} dBc/Hz, excess power {db(exc):.1f} dBc")
    for name, S in (("AM", Sa), ("PM", Sp)):
        Sf = median_filter(S, size=61)
        base = float(np.median(Sf[(f1 > 3600) & (f1 < 5000)]))
        v = float(np.sum(np.clip(Sf[(f1 > 2000) & (f1 < 3500)] - base, 0, None)) * (f1[1] - f1[0]))
        log(f"     {name} in the peak: " + (f"{100 * math.sqrt(v):.3f} % rms" if name == "AM"
                                             else f"{math.degrees(math.sqrt(v)):.3f} deg rms"))
    log("   mains lines in the field, by band: AM rms | PM rms | AM share of a^2 + p^2 | drive n_eff rms "
        "| phase share of the drive")
    for lo, hi in ((50, 1100), (1100, 2000), (2000, 3000), (3000, 7500), (7500, 10500), (10500, 12000)):
        sel = [r for r in rows.values() if lo < r["f"] < hi]
        a2, p2 = sum(r["am"] ** 2 for r in sel), sum(r["pm"] ** 2 for r in sel)
        log(f"     {lo / 1e3:5.2f}-{hi / 1e3:<5.1f} kHz: AM {100 * math.sqrt(a2):.4f} %, PM {1e3 * math.degrees(math.sqrt(p2)):6.1f} "
            f"mdeg, AM share {a2 / (a2 + p2):.2f}, drive {1e3 * math.degrees(math.sqrt(COT ** 2 * a2 + p2)):6.1f} mdeg, "
            f"phase share {p2 / (COT ** 2 * a2 + p2):.2f}")
    log("   lines 2.4-3.0 kHz (* = processed by the DSP ripple loop):")
    for n in range(40, 51):
        r = rows[n]
        log(f"     {'*' if r['ripple'] else ' '} {r['f']:7.1f} Hz  USB {r['usb']:6.1f}  LSB {r['lsb']:6.1f} dBc  "
            f"AM {1e4 * r['am']:5.2f}e-4  PM {1e3 * math.degrees(r['pm']):6.2f} mdeg")
    return dict(rows=rows, f1=f1, Sa=Sa, Sp=Sp, fmb=fmb)


def beam_lines(rows, f_coh, sigma, fmin=2000.0, fmax=12000.0):
    sel = [r for r in rows.values() if fmin < r["f"] < fmax]
    f = np.array([r["f"] for r in sel])
    return f, chi(f, f_coh, sigma) * np.array([r["drive"] for r in sel])


def by_band(f, x, bands=((2000, 3000), (3000, 7500), (7500, 10500), (10500, 12000))):
    acw = 1.18e-3 * 2 * np.pi * 476.3e6     # alpha_c omega_RF: dE/E = (omega / alpha_c omega_RF) dphi
    out = {}
    for lo, hi in bands:
        m = (f > lo) & (f < hi)
        out[(lo, hi)] = (math.degrees(math.sqrt(np.sum(x[m] ** 2))), math.sqrt(np.sum((2 * np.pi * f[m] / acw * x[m]) ** 2)))
    out["all"] = (math.degrees(math.sqrt(np.sum(x ** 2))), math.sqrt(np.sum((2 * np.pi * f / acw * x) ** 2)))
    return out


def section_beam(iq):
    log("=" * 110)
    log("4. Loop rejection, klystron ripple and the motion these lines drive at 500 mA")
    rows = iq["rows"]
    log("   direct loop without beam (G 0.88, on tune, lead and lag networks, 625 ns):")
    for f in (720.0, 2760.0, 2880.0, 8640.0, 9000.0, 9720.0):
        Lf = complex(loop_nobeam(f))
        S = 1 / (1 + Lf)
        log(f"     {f:6.0f} Hz: |L| {abs(Lf):.2f} at {math.degrees(np.angle(Lf)):+6.1f} deg; 1/(1+L) {abs(S):.2f} at "
            f"{math.degrees(np.angle(S)):+5.1f} deg ({20 * math.log10(abs(1 + Lf)):.1f} dB)")
    sel = [r for r in rows.values() if 7900 < r["f"] < 10500 and r["six"]]
    log("   klystron-output phase ripple estimated as field PM x |1+L| (360 Hz family): " + ", ".join(
        f"{r['f']:.0f} Hz {1e3 * math.degrees(r['pm']) * abs(1 + complex(loop_nobeam(r['f']))):.0f} mdeg" for r in sel))
    l500 = {}
    for r in csv.DictReader(open(LINES500, encoding="utf-8")):
        off = float(r["offset_Hz"])
        l500[(1 if off > 0 else -1, int(r["harmonic"]))] = r
    log("   360 Hz family near f_coh, level in dBc: no beam (I/Q, tracked) USB/LSB | 492 mA (swept 30 Hz RBW) | difference")
    for n in range(120, 168, 6):
        r = rows[n]
        a5 = [float(l500[(s, n)]["power_dBc"]) if (s, n) in l500 else float("nan") for s in (1, -1)]
        log(f"     {r['f']:7.0f} Hz  {r['usb']:6.1f} / {r['lsb']:6.1f}  |  {a5[0]:6.1f} / {a5[1]:6.1f}  |  "
            f"{a5[0] - r['usb']:+5.1f} / {a5[1] - r['lsb']:+5.1f} dB   (AM share {r['am'] ** 2 / (r['am'] ** 2 + r['pm'] ** 2):.2f}, "
            f"PM {1e3 * math.degrees(r['pm']):5.1f} mdeg)")
    log("   360 Hz family at 2.9-7.6 kHz, 492 mA minus no beam (dB, mean of both sidebands): odd multiples of 360 Hz "
        "(6-pulse residual) | multiples of 720 Hz (12-pulse)")
    for name, odd in (("odd x 360 Hz", True), ("x 720 Hz    ", False)):
        d = []
        for n in range(48, 128, 6):
            if ((n // 6) % 2 == 1) != odd or not all((s, n) in l500 for s in (1, -1)):
                continue
            d.append((rows[n]["f"], np.mean([float(l500[(1, n)]["power_dBc"]) - rows[n]["usb"],
                                             float(l500[(-1, n)]["power_dBc"]) - rows[n]["lsb"]])))
        log(f"     {name}: " + ", ".join(f"{fr:.0f} {v:+.1f}" for fr, v in d) + f"  -> mean {np.mean([v for _, v in d]):+.1f} dB")
    f, x = beam_lines(rows, F_COH, SIGMA)
    log(f"   beam phase at 500 mA = no-beam drive x |chi| of the 8 Oct line ({F_COH:.0f} Hz, {SIGMA:.0f} /s): band | phase | dE/E")
    for k, (ph, de) in by_band(f, x).items():
        log(f"     {k if k == 'all' else f'{k[0] / 1e3:4.1f}-{k[1] / 1e3:<4.1f} kHz'}: {ph:.3f} deg rms, dE/E {de:.2e}")
    for n, ref in ((144, 0.215), (150, 0.257)):
        r = rows[n]
        log(f"     check: {r['f']:.0f} Hz drive {1e3 * math.degrees(r['drive']):.1f} mdeg -> "
            f"{math.degrees(chi(r['f']) * r['drive']):.3f} deg; Doc P from the 492 mA probe (eff): {ref:.3f} deg")
    order = np.argsort(x)[::-1][:10]
    tot = float(np.sum(x ** 2))
    log("     largest contributors: " + ", ".join(
        f"{f[i]:.0f} Hz{'*' if round(f[i] / iq['fmb'].mean()) % 6 == 0 else ''} {math.degrees(x[i]):.3f} deg "
        f"({100 * x[i] ** 2 / tot:.0f} %)" for i in order) + "   (* 360 Hz family)")
    six = np.array([round(fi / iq["fmb"].mean()) % 6 == 0 for fi in f])
    for lo, hi in ((3000, 7500), (7500, 10500)):
        m = (f > lo) & (f < hi)
        log(f"     share of the 360 Hz family in {lo / 1e3:.1f}-{hi / 1e3:.1f} kHz: "
            f"{np.sum(x[m & six] ** 2) / np.sum(x[m] ** 2):.2f} of the variance")
    x2 = np.where(six, 0.0, x)
    x3 = np.where(np.abs(f - 148 * iq["fmb"].mean()) < 1.0, 0.0, x2)
    log(f"     line-driven motion (2-12 kHz) without the 360 Hz family: {math.degrees(math.sqrt(np.sum(x2 ** 2))):.3f} deg; "
        f"also without the 8880 Hz line: {math.degrees(math.sqrt(np.sum(x3 ** 2))):.3f} deg (all lines: "
        f"{math.degrees(math.sqrt(np.sum(x ** 2))):.3f} deg)")
    low = [r for r in rows.values() if r["f"] < 2000]
    dl = math.degrees(math.sqrt(sum(r["drive"] ** 2 for r in low)))
    log(f"   lines below 2 kHz: drive {dl:.3f} deg rms; the beam follows with chi = 1.0 (integral path) to 1.3, "
        f"i.e. {dl:.3f}-{1.3 * dl:.3f} deg of timing")
    log("   Doc P line budget from the 492 mA capture: counted lines (beam share > 0.5 under both hypotheses) against "
        "all lines under the phase hypothesis")
    pm_tot = {}
    for m in ("eff", "lag"):
        doc, pm = 0.0, {}
        for r in l500.values():
            fl = abs(float(r["offset_Hz"]))
            sa, sp = float(r[f"{m}_beam_share_AM"]), float(r[f"{m}_beam_share_PM"])
            v = math.radians(float(r[f"{m}_dphi_deg"])) ** 2
            doc += v if min(sa, sp) > 0.5 else 0.0
            band = "2.0-2.9" if fl < 2900 else "2.9-7.0" if fl < 7000 else "7.0-10"
            pm[band] = pm.get(band, 0.0) + v * sp / min(sa, sp)
        pm_tot[m] = math.degrees(math.sqrt(sum(pm.values())))
        log(f"     {m}: counted {math.degrees(math.sqrt(doc)):.3f} deg | phase hypothesis " + ", ".join(
            f"{k} kHz {math.degrees(math.sqrt(v)):.3f}" for k, v in sorted(pm.items())) + f", total {pm_tot[m]:.3f} deg")
    bb_doc = {"eff": 0.186, "lag": 0.143}      # broadband line at 492 mA, deg rms (Doc P; results/lines_near_fcoh.log)
    log("   timing budget at 500 mA, deg rms (lines 2-10/12 kHz, broadband line, lines below 2 kHz at chi 1.0-1.3):")
    for m in ("eff", "lag"):
        for tag, ln in (("492 mA lines, phase hypothesis", pm_tot[m]), ("no-beam drive x chi", by_band(f, x)["all"][0])):
            tots = [math.sqrt(ln ** 2 + bb_doc[m] ** 2 + (c * dl) ** 2) for c in (1.0, 1.3)]
            log(f"     {m}, {tag:31s}: lines {ln:.3f}, broadband {bb_doc[m]:.3f}, low {dl:.3f}-{1.3 * dl:.3f} -> "
                f"{tots[0]:.3f}-{tots[1]:.3f} deg ({tots[0] / 0.1 * 0.58:.1f}-{tots[1] / 0.1 * 0.58:.1f} ps)")
    log("   gain scan at 500 mA (model shifts of the study plan, Appendix A, applied to the measured line); line-driven "
        "beam phase from the no-beam drive, deg rms")
    log("     shape COUNTS.A  f_coh  sigma   Q | 2-3 kHz  3-7.5 kHz  7.5-10.5 kHz  all 2-12 kHz | dE/E all")
    curves = {}
    for m, pts in APP_A.items():
        b0 = [p for p in pts if p[0] == 1.3][0]
        curves[m] = []
        for g, fc0, s0 in pts:
            fc, sg = F_COH + fc0 - b0[1], SIGMA * s0 / b0[2]
            bb = by_band(*beam_lines(rows, fc, sg))
            curves[m].append((g, bb["all"][0], bb[(7500, 10500)][0]))
            log(f"     {m:4s}  {g:+5.1f} dB  {fc:6.0f} {sg:6.0f} {math.pi * fc / sg:3.0f} | {bb[(2000, 3000)][0]:6.3f}  "
                f"{bb[(3000, 7500)][0]:8.3f}  {bb[(7500, 10500)][0]:10.3f}  {bb['all'][0]:12.3f}   | {bb['all'][1]:.2e}")
    log("   loop-phase lead at 1.3 dB, 500 mA (study plan 6.1: per degree, f_coh -14 to -16 Hz, sigma +1.1 to +1.6 %):")
    for th in (0, 5, 10):
        res = []
        for dfd, dsd in ((-14.0, 0.011), (-16.0, 0.016)):
            bb = by_band(*beam_lines(rows, F_COH + dfd * th, SIGMA * (1 + dsd * th)))
            res.append((bb[(7500, 10500)][0], bb["all"][0]))
        log(f"     +{th:2d} deg: f_coh {F_COH - 14 * th:.0f}-{F_COH - 16 * th:.0f} Hz, sigma {SIGMA * (1 + 0.011 * th):.0f}-"
            f"{SIGMA * (1 + 0.016 * th):.0f} /s | 7.5-10.5 kHz {min(r[0] for r in res):.3f}-{max(r[0] for r in res):.3f} | "
            f"all {min(r[1] for r in res):.3f}-{max(r[1] for r in res):.3f} deg")
    out = O.RESULTS / f"{TAG}_lines.csv"
    with open(out, "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["n", "f_Hz", "six_pulse", "dsp_ripple_line", "usb_dBc", "lsb_dBc", "am_rms", "pm_rms_mdeg",
                    "am_power_share", "drive_rms_mdeg", "abs_1_plus_L", "kly_pm_equiv_mdeg", "chi_500mA",
                    "beam_500mA_deg", "usb_492mA_dBc", "lsb_492mA_dBc"])
        for n, r in rows.items():
            opl = abs(1 + complex(loop_nobeam(r["f"])))
            c = float(chi(r["f"])) if r["f"] > 2000 else float("nan")
            w.writerow([n, f"{r['f']:.2f}", int(r["six"]), int(r["ripple"]), f"{r['usb']:.2f}", f"{r['lsb']:.2f}",
                        f"{r['am']:.4e}", f"{1e3 * math.degrees(r['pm']):.3f}",
                        f"{r['am'] ** 2 / (r['am'] ** 2 + r['pm'] ** 2):.3f}", f"{1e3 * math.degrees(r['drive']):.3f}",
                        f"{opl:.3f}", f"{1e3 * math.degrees(r['pm']) * opl:.2f}", f"{c:.3f}",
                        f"{math.degrees(c * r['drive']):.4f}" if c == c else "",
                        l500.get((1, n), {}).get("power_dBc", ""), l500.get((-1, n), {}).get("power_dBc", "")])
    log(f"   line table -> {out}")
    return dict(f=f, x=x, curves=curves)


def figures(sw, iq, bm):
    fig, ax = plt.subplots(3, 1, figsize=(11, 11.5))
    for k, col, lab in (("bm", "C3", "492 mA, 8 Oct 2026"), ("nb", "C0", "no beam, 3 Nov 2026")):
        c = sw["cap"][k]
        ax[0].plot(c["off"] / 1e3, c["dbc_hz"], col, lw=0.6, label=lab)
    ax[0].set(xlim=(-10, 10), ylim=(-135, -60), xlabel="offset from the carrier (kHz)", ylabel="dBc/Hz (30 Hz RBW)",
              title="(a) Cavity-A probe, 20 kHz span, RMS detector, 100 power averages")
    ax[0].legend(loc="upper right")
    nb = sw["nb"]
    f, tr = axis(nb["setups"]["lines"])
    fc, car = f[int(np.argmax(tr))], float(tr.max())
    for name, col, lab in (("comb_usb", "C0", "no beam, upper sideband"), ("comb_lsb", "C2", "no beam, lower sideband")):
        f, tr = axis(nb["setups"][name])
        ax[1].plot(np.abs(f - fc) / 1e3, tr - car, col, lw=0.6, label=lab + " (3 Hz RBW)")
    xs, ys = [], []
    for r in csv.DictReader(open(LINES500, encoding="utf-8")):
        xs.append(abs(float(r["offset_Hz"])) / 1e3)
        ys.append(float(r["power_dBc"]))
    ax[1].plot(xs, ys, "rv", ms=4, label="492 mA line peaks (30 Hz RBW), both sidebands")
    for n in range(120, 184, 6):
        ax[1].axvline(n * 0.06, color="0.85", lw=0.5, zorder=0)
    ax[1].axvline(F_COH / 1e3, color="k", ls=":", lw=0.8)
    ax[1].set(xlim=(7, 11), ylim=(-125, -50), xlabel="|offset| (kHz); grey: 360 Hz family; dotted: f_coh at 500 mA",
              ylabel="dBc per RBW", title="(b) Mains harmonics around f_coh: field alone (no beam) and with 492 mA")
    ax[1].legend(loc="upper right", fontsize=8)
    for k, col, lab in (("nb", "C0", "no beam"), ("bm", "C3", "492 mA")):
        arr = sw["prof"][k]
        ax[2].plot(arr[:, 0], arr[:, 1], col + "-", label=lab + " USB")
        ax[2].plot(arr[:, 0], arr[:, 2], col + "--", label=lab + " LSB")
    for fr in RIPPLE_LINES:
        if fr >= 1500:
            ax[2].axvline(fr, color="0.8", lw=0.6, zorder=0)
    ax[2].set(xlabel="offset (Hz); grey: lines processed by the DSP ripple loop (to 2880 Hz)",
              ylabel="median between lines (dBc/Hz)", title="(c) Noise peak at the top of the ripple-loop band")
    ax[2].legend(fontsize=8)
    fig.tight_layout()
    fig.savefig(O.RESULTS / f"{TAG}_spectra.png", dpi=120)
    plt.close(fig)

    rows = iq["rows"]
    fig, ax = plt.subplots(2, 2, figsize=(13, 8.5))
    ax[0, 0].semilogy(iq["f1"] / 1e3, iq["Sa"], "C1", lw=0.5, label="amplitude (1/Hz)")
    ax[0, 0].semilogy(iq["f1"] / 1e3, iq["Sp"], "C0", lw=0.5, label="phase (rad$^2$/Hz)")
    ax[0, 0].set(xlim=(0, 12), ylim=(1e-14, 1e-8), xlabel="frequency (kHz)", ylabel="one-sided PSD",
                 title="(a) Field noise without beam, mains harmonics removed")
    ax[0, 0].legend()
    fl = np.array([r["f"] for r in rows.values()]) / 1e3
    ax[0, 1].semilogy(fl, [1e4 * r["am"] for r in rows.values()], "C1o", ms=3, label="AM rms ($10^{-4}$)")
    ax[0, 1].semilogy(fl, [1e3 * math.degrees(r["pm"]) for r in rows.values()], "C0s", ms=3, label="PM rms (mdeg)")
    ax[0, 1].set(xlim=(0, 12), xlabel="mains harmonic (kHz)", ylabel="line amplitude",
                 title="(b) Mains harmonics without beam: AM and PM")
    ax[0, 1].legend()
    ax[1, 0].vlines(bm["f"] / 1e3, 0, np.degrees(bm["x"]) * 1e3, color="C0", lw=1.2)
    ax[1, 0].set(xlim=(2, 12), xlabel="mains harmonic (kHz)", ylabel="beam phase per line (mdeg rms)",
                 title="(c) Beam motion at 500 mA per line: no-beam drive x |chi| (8 Oct line)")
    t = ax[1, 0].twinx()
    ff = np.linspace(2e3, 12e3, 1000)
    t.plot(ff / 1e3, chi(ff), "k:", lw=0.8)
    t.set_ylabel("|chi| (dotted)")
    for m, c in (("eff", "C0"), ("lag", "C1")):
        g = [p[0] for p in bm["curves"][m]]
        ax[1, 1].plot(g, [p[1] for p in bm["curves"][m]], c + "o-", label=f"{m} shifts: all lines 2-12 kHz")
        ax[1, 1].plot(g, [p[2] for p in bm["curves"][m]], c + "s--", label=f"{m} shifts: lines 7.5-10.5 kHz")
    ax[1, 1].axvline(1.3, color="0.6", lw=0.8)
    ax[1, 1].set(xlabel="COUNTS.A (dB); grey: today", ylabel="line-driven beam phase (deg rms)",
                 title="(d) 500 mA: line-driven motion against loop gain")
    ax[1, 1].legend(fontsize=8)
    fig.tight_layout()
    fig.savefig(O.RESULTS / f"{TAG}_iq.png", dpi=120)
    plt.close(fig)
    log(f"figures -> {O.RESULTS / (TAG + '_spectra.png')}, {O.RESULTS / (TAG + '_iq.png')}")


def main():
    section_state()
    sw = section_swept()
    iq = section_iq()
    bm = section_beam(iq)
    figures(sw, iq, bm)
    out = O.RESULTS / f"{TAG}.log"
    out.write_text("\n".join(LOG) + "\n", encoding="utf-8")
    print("log ->", out)


if __name__ == "__main__":
    main()
