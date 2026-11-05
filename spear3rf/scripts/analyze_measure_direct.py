"""RFgui Measure Direct Closed runs (2 Oct 2026, 10 Nov 2025) and the Configure Direct open-loop record:
transfer functions from the RFP signal-RAM dumps, fits, and the numbers and figure data quoted in Doc P.

Data (matlab_operations_prod/Measurement):
  ClosedLoopTF/2026-10-02/DIRECT_[IQ]_CLOSED<tag>, measureDirect<tag>.fig   ten runs, 2 October 2026
  ClosedLoopTF/2025-11-10/DIRECT_[IQ]_CLOSED<tag>                          one run, 10 November 2025
  OldData/testdata/NOISE_[IQ]_BL.out                            station noise reference (copy of 13 Nov 2025)
  OldData/testdata/DIRECT_[IQ]_OPEN_SP, NOISE_[IQ]_BL_SMALL.out  Configure Direct open-loop record, its reference
  tag = v<kV>i<mA>gp<COUNTS.A x10>pm<-PHASE.C x10>d<yyyymmddhhmmss>

The dumps have a 16-byte header ("RFP Signal I RAM") and int16 big-endian samples, scaled ((x/16)*2+1)/4095.
A closed-loop dump holds the TOTAL feedback signal (FBSIG 0) during noise injection: 2^18 samples at 8 samples
per turn (10.24 MHz).  The routine's TF is conj(tfestimate(reference/10, dump)) with 8192-point Hann windows
(MATLAB's Hsum' is a conjugate transpose); it is reproduced here from the dumps, and extended inside the
+-18.8 kHz the routine blanks.  Closed-loop model: H = -L/(1+L) with
  L = G e^{j theta} (1 + w_i/(s + w_l)) lead(s) w_a/(s + w_a) e^{-s tau} w/(s + w - j dw),  w = w_RF/(2 Q_L),
lead = RFP lead network and (w_i, w_l) = RFP lag network of the RFgui loop models, w_a = 2 pi 2.5 MHz.
At high current the klystron is also modelled with a small-signal response that differs for amplitude and
phase (amplitude gain s, AM/PM kappa), which makes the loop widely linear (closed_loop_wl).
"""
import io
import math
import re
import sys
from pathlib import Path

import numpy as np
import scipy.io as sio
from scipy.io.matlab._mio5 import MatFile5Reader
from scipy.optimize import least_squares

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "spear3rf" / "src"))
from spear3rf.params import Cavity, Loop, Ring  # noqa: E402
from spear3rf.stability import char_fn  # noqa: E402
from spear3rf.system import RFSystem  # noqa: E402

MEAS = ROOT / "matlab_operations_prod" / "Measurement"
RUNS = MEAS / "ClosedLoopTF" / "2026-10-02"
RUNS_2025 = MEAS / "ClosedLoopTF" / "2025-11-10"
TEST = MEAS / "OldData" / "testdata"
OUT = ROOT / "Designs" / "tex" / "docP-rf-physics" / "data"
F_RF = 476.3039e6
W_RF = 2 * math.pi * F_RF
FS = 8 * F_RF / 372                     # signal-RAM rate, 8 samples per turn
FZ, FP = 1 / (2 * math.pi * 301 * 560e-12), 1 / (2 * math.pi * (196 * 301 / 497) * 560e-12)   # lead network
LAG_ZERO, LAG_POLE = 1 / (2 * math.pi * 499 * 0.1e-6), 1 / (2 * math.pi * (499 + 5620) * 0.1e-6)
LAG = (LAG_ZERO - LAG_POLE, LAG_POLE)   # (f_i, f_leak) of the lag network
FA = 2.5e6
NAMES = ("G", "theta", "tau", "Q_L", "df")
SCALE = np.array([0.1, 10, 100, 100, 1])


# ------------------------------------------------------------------ data
def ram(path):
    return np.frombuffer(Path(path).read_bytes()[16:], dtype=">i2").astype(float)


def scale(x):
    return ((x / 16) * 2.0 + 1.0) / 4095


def dump(path_i):
    y = scale(ram(path_i)) + 1j * scale(ram(str(path_i).replace("DIRECT_I_", "DIRECT_Q_")))
    return y - y.mean()


def parse_tag(tag):
    v, i, g, p, day, tod = re.match(r"v(\d+)i(\d+)gp(\d+)pm(\d+)d(\d{8})(\d{6})", tag).groups()
    return dict(mA=int(i), counts_db=int(g) / 10, phase_c=-int(p) / 10, date=day, time=f"{tod[:2]}:{tod[2:4]}")


def hann(n):
    return 0.5 * (1 - np.cos(2 * np.pi * np.arange(1, n + 1) / (n + 1)))      # MATLAB hanning(n)


def tfestimate(y, x, nfft):
    """Routine's TF: conj of the H1 estimate, Hann windows, 50 % overlap; also coherence."""
    w = hann(nfft)
    st = range(0, y.size - nfft + 1, nfft // 2)
    X = np.array([np.fft.fft(w * x[s:s + nfft]) for s in st])
    Y = np.array([np.fft.fft(w * y[s:s + nfft]) for s in st])
    sxx, syy = np.mean(np.abs(X) ** 2, 0), np.mean(np.abs(Y) ** 2, 0)
    sxy = np.mean(Y * np.conj(X), 0)
    return np.fft.fftfreq(nfft, 1 / FS), np.conj(sxy / sxx), np.abs(sxy) ** 2 / (sxx * syy), w


def fig_tf(path):
    """Measured TF as plotted in an RFgui .fig (HG2 figure; the data live in the MCOS subsystem)."""
    data = sio.loadmat(path)["__function_workspace__"].tobytes()
    header = b"MATLAB 5.0 MAT-file, subsystem".ljust(116, b" ") + b"\x00" * 8 + data[0:4]
    stream = io.BytesIO(header + data[8:])
    rdr = MatFile5Reader(stream, struct_as_record=False, squeeze_me=False)
    rdr.initialize_read()
    stream.seek(128)
    hdr, _ = rdr.read_var_header()
    flat = []

    def walk(o, depth=0):
        if depth > 14:
            return
        if isinstance(o, np.ndarray):
            if o.dtype.names:
                for n in o.dtype.names:
                    for x in o[n].flat:
                        walk(x, depth + 1)
            elif o.dtype == object:
                for x in o.flat:
                    walk(x, depth + 1)
            elif o.dtype.kind == "f":
                flat.append(np.asarray(o, float).ravel())
        elif hasattr(o, "_fieldnames"):
            for n in o._fieldnames:
                walk(getattr(o, n), depth + 1)

    walk(rdr.read_var_array(hdr, process=True))
    lines = [(x, y) for x, y in zip(flat[:-1], flat[1:])
             if x.size >= 100 and x.size == y.size and np.all(np.diff(x) > 0) and x.min() < -300 and x.max() > 300]
    n_fit = max(x.size for x, _ in lines)
    data = [ln for ln in lines if ln[0].size < n_fit]          # the fitted curve has more points
    mag = next(ln for ln in data if np.nanmax(ln[1]) < 10 and np.ptp(ln[1]) < 60)
    ph = next(ln for ln in data if ln is not mag)
    return mag[0] * 1e3, 10 ** (mag[1] / 20) * np.exp(1j * np.radians(ph[1]))


# ------------------------------------------------------------------ models and fits
def closed_loop(p, f, fi=0.0, fl=0.0):
    G, th, tau, QL, df = p
    s = 2j * np.pi * f
    w = W_RF / (2 * QL)
    C = G * np.exp(1j * np.radians(th)) * (1 + 2 * np.pi * fi / (s + 2 * np.pi * fl))
    L = (C * np.exp(-s * tau * 1e-9) * FA / (s / (2 * np.pi) + FA) * w / (s + w - 2j * np.pi * df * 1e3)
         * (1 + s / (2 * np.pi * FZ)) / (1 + s / (2 * np.pi * FP)))
    return -L / (1 + L)


def fit(model, f, H, p0, sc, phase_index, fixed=None, **kw):
    fixed = fixed or {}
    free = [k for k in range(len(p0)) if k not in fixed]

    def full(q):
        p = np.array(p0, float)
        p[free] = q * sc[free]
        for k, v in fixed.items():
            p[k] = v
        return p

    def res(q):
        m = model(full(q), f, **kw) - H
        return np.concatenate([m.real, m.imag])
    best = None
    for ph0 in (-40.0, 0.0, 40.0, 180.0):
        q0 = (np.array(p0, float) / sc)[free]
        if phase_index in free:
            q0[free.index(phase_index)] = ph0 / sc[phase_index]
        r = least_squares(res, q0, max_nfev=20000)
        best = r if best is None or r.cost < best.cost else best
    p = full(best.x)
    p[phase_index] = (p[phase_index] + 180) % 360 - 180
    return p, float(np.sqrt(np.mean(np.abs(model(p, f, **kw) - H) ** 2)))


def fit_cl(f, H, I, integral, fixed=None):
    fi, fl = LAG if integral else (0.0, 0.0)
    return fit(closed_loop, f, H, [1.0, 0.0, 625.0, 6700.0, -36.0 * I / 500], SCALE, 1, fixed=fixed, fi=fi, fl=fl)


def loop_chain(f, G, th, tau, QL, df):
    """Everything in the loop after the klystron: cavity, delay, amplifier pole, controller with lead and lag."""
    s = 2j * np.pi * f
    w = W_RF / (2 * QL)
    C = G * np.exp(1j * np.radians(th)) * (1 + 2 * np.pi * LAG[0] / (s + 2 * np.pi * LAG[1]))
    return (C * np.exp(-s * tau * 1e-9) * FA / (s / (2 * np.pi) + FA) * w / (s + w - 2j * np.pi * df * 1e3)
            * (1 + s / (2 * np.pi * FZ)) / (1 + s / (2 * np.pi * FP)))


def closed_loop_wl(f, G, th, tau, QL, df, s_amp, kappa, phi_u, alpha=45.0):
    """TOTAL/noise with a klystron of amplitude gain s_amp and AM/PM kappa, for noise injected along alpha.

    Klystron: out = k_d u + k_i e^{2j phi_u} conj(u), k_d = (1+s)/2 + j kappa/2, k_i = (s-1)/2 + j kappa/2, with
    phi_u the drive phase in the RFP frame.  One-dimensional noise gives conj(n(-f)) = e^{-2j alpha} n(f).
    """
    A, At = loop_chain(f, G, th, tau, QL, df), np.conj(loop_chain(-f, G, th, tau, QL, df))
    kd = (1 + s_amp) / 2 + 0.5j * kappa
    ki = ((s_amp - 1) / 2 + 0.5j * kappa) * np.exp(2j * np.radians(phi_u))
    nt = np.exp(-2j * np.radians(alpha))
    a11, a12, a21, a22 = 1 + A * kd, A * ki, At * np.conj(ki), 1 + At * np.conj(kd)
    b1, b2 = -A * (kd + ki * nt), -At * (np.conj(kd) * nt + np.conj(ki))
    return (b1 * a22 - a12 * b2) / (a11 * a22 - a12 * a21)


def fit_wl(f, H, I, held, s_fix=None, k_fix=None):
    """Widely-linear fit with (G, tau, Q_L) = held (or free if held is None); free theta, df, phi_u and the
    klystron's s and kappa unless fixed."""
    names = [n for n, v in (("theta", None), ("df", None), ("s", s_fix), ("kappa", k_fix), ("phi_u", None)) if v is None]
    names += [] if held else ["G", "tau", "QL"]
    # theta within +-30 deg of the low-current calibration: the fit has a mirror solution (kappa -> -kappa) near +70 deg
    lo = dict(theta=-30, df=-80, s=0.0, kappa=-2.5, phi_u=-180, G=0.2, tau=450, QL=3000)
    hi = dict(theta=30, df=20, s=1.5, kappa=2.5, phi_u=180, G=3.0, tau=800, QL=12000)
    sc = dict(theta=10, df=5, s=0.2, kappa=0.2, phi_u=30, G=0.1, tau=20, QL=300)

    def args(q):
        d = dict(zip(names, q))
        G, tau, QL = held if held else (d["G"], d["tau"], d["QL"])
        return (G, d["theta"], tau, QL, d["df"], d.get("s", s_fix), d.get("kappa", k_fix), d["phi_u"])

    def res(q):
        m = closed_loop_wl(f, *args(q)) - H
        return np.concatenate([m.real, m.imag])
    best = None
    for s0 in (0.3, 0.8):
        for ph0 in (-135, -45, 45, 135):
            for k0 in (-0.8, 0.8):
                q0 = dict(theta=0.0, df=-36.0 * I / 500, s=s0, kappa=k0, phi_u=ph0, G=1.0 if held else 1.2, tau=624.0,
                          QL=6800.0)
                r = least_squares(res, [q0[n] for n in names], bounds=([lo[n] for n in names], [hi[n] for n in names]),
                                  x_scale=[sc[n] for n in names], max_nfev=3000)
                best = r if best is None or r.cost < best.cost else best
    return args(best.x), float(np.sqrt(np.mean(np.abs(closed_loop_wl(f, *args(best.x)) - H) ** 2)))


def resonator(p, f):
    """cavityfit form: A e^{j phi} w/(s - j 2 pi f0 + w) e^{-s tau}."""
    A, QL, tau, phi, f0 = p
    w = W_RF / (2 * QL)
    s = 2j * np.pi * f
    return A * np.exp(1j * np.radians(phi)) * w / (s - 2j * np.pi * f0 + w) * np.exp(-s * tau * 1e-9)


def open_loop(p, f):
    G, th, tau, QL, df = p
    s = 2j * np.pi * f
    w = W_RF / (2 * QL)
    return -(G * np.exp(1j * np.radians(th)) * np.exp(-s * tau * 1e-9) * FA / (s / (2 * np.pi) + FA)
             * w / (s + w - 2j * np.pi * df * 1e3) * (1 + s / (2 * np.pi * FZ)) / (1 + s / (2 * np.pi * FP)))


def sideband_pole(f, H, coh, win, sgn, os=8):
    """Pole near the synchrotron sideband, model convolved with the window's power kernel:
    H = (b0 + b1 (f - fc)) (1 + a/(j 2 pi (f - fc) + sigma)) on 4.5-14 kHz of one side."""
    K = np.abs(np.fft.fft(win, os * win.size)) ** 2
    half = 6 * os
    K = np.r_[K[-half:], K[:half + 1]]
    K /= K.sum()
    sel = np.where((sgn * f > 4.5e3) & (sgn * f < 14e3))[0]
    fs_, Hs, w = f[sel], H[sel], np.sqrt(np.clip(coh[sel], 0.05, 1))
    fine = fs_[:, None] + np.arange(-half, half + 1)[None, :] * (FS / win.size) / os

    def res(q):
        fc = sgn * q[0] * 1e3
        m = (((q[4] + 1j * q[5]) + (q[6] + 1j * q[7]) * (fine - fc) / 1e4)
             * (1 + (q[2] + 1j * q[3]) * 1e3 / (2j * np.pi * (fine - fc) + q[1]))) @ K
        d = (m - Hs) * w
        return np.concatenate([d.real, d.imag])
    best = None
    for fc0 in (8.3, 8.8, 9.4):
        for a0 in ((1, 0), (0, 1), (-1, 0), (0, -1)):
            r = least_squares(res, [fc0, 600, a0[0], a0[1], Hs.mean().real, Hs.mean().imag, 0, 0],
                              bounds=([6, 30, -80, -80, -5, -5, -5, -5], [12, 6000, 80, 80, 5, 5, 5, 5]), max_nfev=3000)
            best = r if best is None or r.cost < best.cost else best
    return best.x[0], best.x[1]


# ------------------------------------------------------------------ analysis
def main():
    ni, nq = ram(TEST / "NOISE_I_BL.out"), ram(TEST / "NOISE_Q_BL.out")
    print(f"noise reference NOISE_[IQ]_BL.out: {ni.size} samples; corr(I, Q) = {np.corrcoef(ni, nq)[0, 1]:+.4f}"
          f" (identical records: one-dimensional injection)")
    caps = [(p.name.replace("DIRECT_I_CLOSED", ""), p) for p in sorted(RUNS.glob("DIRECT_I_CLOSED*"))]
    caps += [(p.name.replace("DIRECT_I_CLOSED", ""), p) for p in sorted(RUNS_2025.glob("DIRECT_I_CLOSED*"))]
    caps.sort(key=lambda c: c[0][-14:])
    runs = []
    print("\n== TF from the dumps vs the routine's figure (8192-point windows, 1.25 kHz bins)")
    for tag, p in caps:
        m = parse_tag(tag)
        y = dump(p)
        x = (scale(ni[:y.size]) + 1j * scale(nq[:y.size])) / 10.0
        f, H, coh, win = tfestimate(y, x, 8192)
        figp = RUNS / f"measureDirect{tag}.fig"
        if figp.exists():
            ff, Hf = fig_tf(figp)
            r = H[np.round(ff / (FS / 8192)).astype(int) % 8192] / Hf
            print(f"  {m['date']} {m['time']} {m['mA']:3d} mA: |H/Hfig| median {np.median(np.abs(r)):.4f},"
                  f" phase rms {np.degrees(np.std(np.angle(r))):.2f} deg; coherence {np.median(coh[(np.abs(f) > 18.8e3) & (np.abs(f) < 382e3)]):.2f}")
        runs.append((tag, m, y, x, f, H, coh))

    print("\n== closed-loop fits, 18.8-382 kHz (integral path: lag network of the RFgui loop models)")
    print("  date      time  I/mA PHASE.C | proportional only: G theta tau Q_L df rms | with integral path: G theta tau Q_L df rms")
    table = {}
    for tag, m, y, x, f, H, coh in runs:
        sel = (np.abs(f) > 18.8e3) & (np.abs(f) < 382e3)
        p0, r0 = fit_cl(f[sel], H[sel], m["mA"], False)
        p1, r1 = fit_cl(f[sel], H[sel], m["mA"], True)
        table[tag] = (p0, p1)
        print(f"  {m['date']} {m['time']} {m['mA']:4d} {m['phase_c']:+6.1f} | {p0[0]:.3f} {p0[1]:+6.1f} {p0[2]:4.0f} {p0[3]:5.0f} {p0[4]:+6.1f}"
              f" {r0:.4f} | {p1[0]:.3f} {p1[1]:+6.1f} {p1[2]:4.0f} {p1[3]:5.0f} {p1[4]:+6.1f} {r1:.4f}")
    low = [t for t, m, *_ in runs if m["mA"] < 30]
    for k, lab in ((0, "proportional only"), (1, "with integral path")):
        v = np.array([table[t][k] for t in low])
        print(f"  low current, {lab}: G {v[:, 0].mean():.3f} +- {v[:, 0].std(ddof=1):.3f}, tau {v[:, 2].mean():.0f} +- {v[:, 2].std(ddof=1):.0f} ns,"
              f" Q_L {v[:, 3].mean():.0f} +- {v[:, 3].std(ddof=1):.0f} ({v[:, 3].min():.0f}..{v[:, 3].max():.0f})")
    xs = np.array([m["phase_c"] for t, m, *_ in runs if m["mA"] < 30])
    ys = np.array([table[t][1][1] for t in low])
    b, a = np.polyfit(xs, ys, 1)
    print(f"  loop phase (with integral path): theta = {a:+.1f} {b:+.3f} PHASE.C; zero at {-a/b:+.1f} deg;"
          f" residual rms {np.std(ys - (a + b * xs), ddof=2):.1f} deg")

    v = np.array([table[t][1] for t in low])
    held = (v[:, 0].mean(), v[:, 2].mean(), v[:, 3].mean())
    print(f"\n== high current with the klystron's amplitude gain s and AM/PM kappa free; G, tau, Q_L held at the"
          f" low-current values ({held[0]:.3f}, {held[1]:.0f} ns, {held[2]:.0f})")
    wl = {}
    for tag, m, y, x, f, H, coh in runs:
        if m["mA"] < 300:
            continue
        sel = (np.abs(f) > 18.8e3) & (np.abs(f) < 382e3)
        p_h, r_h = fit(closed_loop, f[sel], H[sel], [held[0], 0.0, held[1], held[2], -36.0 * m["mA"] / 500], SCALE, 1,
                       fixed={0: held[0], 2: held[1], 3: held[2]}, fi=LAG[0], fl=LAG[1])
        p_w, r_w = fit_wl(f[sel], H[sel], m["mA"], held)
        _, r_k0 = fit_wl(f[sel], H[sel], m["mA"], held, k_fix=0.0)
        _, r_s1 = fit_wl(f[sel], H[sel], m["mA"], held, s_fix=1.0)
        wl[tag] = p_w
        r_free = np.sqrt(np.mean(np.abs(closed_loop(table[tag][1], f[sel], *LAG) - H[sel]) ** 2))
        print(f"  {m['date']} {m['time']} {m['mA']:3d} mA: rms complex-linear free {r_free:.4f},"
              f" complex-linear held {r_h:.4f}, widely linear held {r_w:.4f} (s {p_w[5]:.2f}, kappa {p_w[6]:+.2f},"
              f" phi_u {(p_w[7] + 90) % 180 - 90:+.0f}, theta {p_w[1]:+.1f}, df {p_w[4]:+.1f} kHz);"
              f" kappa = 0: {r_k0:.4f}; s = 1: {r_s1:.4f}")

    S_NO, K_NO = 0.40, 0.10           # klystron measured in normal operation (analyze_old_rf_data.py, fault records)
    print(f"\n== with the klystron measured in normal operation (s {S_NO}, kappa {K_NO}): low current with G, tau, Q_L free,"
          f" high current with them held")
    lows = []
    for tag, m, y, x, f, H, coh in runs:
        if m["mA"] > 30:
            continue
        sel = (np.abs(f) > 18.8e3) & (np.abs(f) < 382e3)
        p, r = fit_wl(f[sel], H[sel], m["mA"], None, s_fix=S_NO, k_fix=K_NO)
        lows.append(p)
        print(f"  {m['date']} {m['time']} {m['mA']:3d} mA: G {p[0]:.3f} theta {p[1]:+5.1f} tau {p[2]:4.0f} Q_L {p[3]:5.0f}"
              f" df {p[4]:+5.1f} rms {r:.4f}")
    lv = np.array(lows)
    held_no = (lv[:, 0].mean(), lv[:, 2].mean(), lv[:, 3].mean())
    print(f"  low current: phase-path G {held_no[0]:.2f} +- {lv[:, 0].std(ddof=1):.2f}, tau {held_no[1]:.0f} ns, Q_L {held_no[2]:.0f}")
    for tag, m, y, x, f, H, coh in runs:
        if m["mA"] < 300:
            continue
        sel = (np.abs(f) > 18.8e3) & (np.abs(f) < 382e3)
        p, r = fit_wl(f[sel], H[sel], m["mA"], held_no, s_fix=S_NO, k_fix=K_NO)
        print(f"  {m['date']} {m['time']} {m['mA']:3d} mA, G/tau/Q_L held: theta {p[1]:+5.1f} df {p[4]:+5.1f} kHz rms {r:.4f}")

    print("\n== output impropriety (independent I and Q noise would give ~0.1)")
    for tag, m, y, *_ in runs:
        nfft = 8192
        w = hann(nfft)
        Y = np.array([np.fft.fft(w * y[s:s + nfft]) for s in range(0, y.size - nfft + 1, nfft // 2)])
        neg = (-np.arange(nfft)) % nfft
        pw = np.mean(np.abs(Y) ** 2, 0)
        rho = np.abs(np.mean(Y * Y[:, neg], 0)) / np.sqrt(pw * pw[neg])
        f = np.fft.fftfreq(nfft, 1 / FS)
        print(f"  {m['date']} {m['time']} {m['mA']:3d} mA: median rho 20-80 kHz {np.median(rho[(np.abs(f) > 20e3) & (np.abs(f) < 80e3)]):.2f}")

    print("\n== Robinson mode in the closed-loop TF (pole fit near +-f_s, 131072-point windows, window smearing modelled)")
    for tag, m, y, x, *_ in runs:
        if m["mA"] < 300:
            continue
        f, H, coh, win = tfestimate(y, x, 2 ** 17)
        sides = [sideband_pole(f, H, coh, win, s) for s in (+1, -1)]
        fc, sg = np.mean([s[0] for s in sides]), np.mean([s[1] for s in sides])
        print(f"  {m['date']} {m['time']} {m['mA']:3d} mA, PHASE.C {m['phase_c']:+.0f}: f {fc:.2f} kHz"
              f" (sides {sides[0][0]:.2f}/{sides[1][0]:.2f}), sigma {sg:.0f} /s (sides {sides[0][1]:.0f}/{sides[1][1]:.0f})")

    print("\n== Configure Direct open-loop record (DIRECT_[IQ]_OPEN_SP): injected noise is the BL_SMALL Q sequence on both DACs")
    yo = dump(TEST / "DIRECT_I_OPEN_SP")
    qs = ram(TEST / "NOISE_Q_BL_SMALL.out")
    xo = (1 + 1j) * scale(qs[:yo.size]) / 10.0
    f, H, coh, _ = tfestimate(yo, xo, 8192)
    sel = (np.abs(f) > 7.5e3) & (np.abs(f) < 433e3)
    pr, rr = fit(resonator, f[sel], H[sel], [abs(H[sel]).max(), 6500, 700, 0, 0], np.array([1, 100, 100, 10, 1e3]), 3)
    po, ro = fit(open_loop, f[sel], H[sel], [abs(H[sel]).max(), 0, 700, 6500, 0], SCALE * np.array([100, 1, 1, 1, 1]), 1)
    print(f"  coherence {np.median(coh[sel]):.2f}; resonator x delay: Q_L {pr[1]:.0f}, delay {pr[2]:.0f} ns, f0 {pr[4]/1e3:+.2f} kHz"
          f" (rel. rms {rr/abs(pr[0]):.3f}); full model with lead: Q_L {po[3]:.0f}, delay {po[2]:.0f} ns (rel. rms {ro/abs(po[0]):.3f})")

    print("\n== synchrotron motion in the measured response, 497 mA (beam factor F = 1 + j kappa Z_b / D)")
    p497 = table[next(t for t, m, *_ in runs if m["mA"] == 497)][0]
    ring = Ring(f_rf=F_RF, U0_eV=1.099e6)
    sy = RFSystem(ring=ring, cavity=Cavity(beta=32000 / 6700 - 1), I0=0.497, V_total=2.85e6, detuning_hz=p497[4] * 1e3,
                  loop=Loop(gain=p497[0], phase_deg=p497[1], delay=p497[2] * 1e-9, f_amp_hz=FA, lead_hz=(FZ, FP)))
    ff = np.concatenate([np.linspace(-400e3, -18e3, 400), np.linspace(18e3, 400e3, 400)])
    s = 2j * np.pi * ff
    F = 1 + 1j * sy.K * sy.z_beam(s) / char_fn(sy, s)
    L = sy.open_loop(s)
    q, _ = fit_cl(ff, -L / (1 + L) * F, 497, False)
    print(f"  max |F-1| {np.abs(F-1).max():.3f} (|f| >= 18 kHz), {np.abs(F[np.abs(ff) >= 40e3]-1).max():.3f} (|f| >= 40 kHz);"
          f" beam-free refit G {q[0]:.3f} (model {p497[0]:.3f}), Q_L {q[3]:.0f} (6700)")

    print("\n== figure data (T = -H, 18.8 <= |f| <= 300 kHz)")
    for tag, m, y, x, *_ in runs:
        if (m["date"], m["time"]) in (("20261002", "09:47"), ("20261002", "13:51")):
            f, H, coh, _ = tfestimate(y, x, 8192)
            k = (np.abs(f) >= 18.7e3) & (np.abs(f) <= 300e3)
            o = np.argsort(f[k])
            T = -H[k][o]
            name = OUT / f"closed_loop_meas_{m['mA']:03d}.dat"
            with open(name, "w") as fo:
                fo.write("f db ph\n")
                for a, b, c in zip(f[k][o] / 1e3, 20 * np.log10(np.abs(T)), np.degrees(np.angle(T))):
                    fo.write(f"{a:.4f} {b:.4f} {c:.3f}\n")
            print(f"  wrote {name.name}: {k.sum()} points")
            if m["mA"] == 497:
                ff = np.concatenate([np.arange(-300e3, -18.7e3, 1e3), [np.nan], np.arange(19e3, 300.1e3, 1e3)])
                T = -closed_loop_wl(np.nan_to_num(ff), *wl[tag])
                with open(OUT / "closed_loop_wl_497.dat", "w") as fo:
                    fo.write("f db ph\n")
                    for a, t in zip(ff / 1e3, T):
                        fo.write("nan nan nan\n" if not np.isfinite(a) else f"{a:.1f} {20*np.log10(abs(t)):.4f} {np.degrees(np.angle(t)):.3f}\n")
                print(f"  wrote closed_loop_wl_497.dat: widely linear model of the 497 mA run, {ff.size - 1} points")


if __name__ == "__main__":
    main()
