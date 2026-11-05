"""Closed-loop response of one Measure Direct Closed run, and the fits the study plan uses (sec. 10, per point).

The run is a pair of RFP signal-RAM dumps DIRECT_[IQ]_CLOSED<tag> written by the RFgui routine (MeasDirCls) or
by optllrf_measure_closed_safe.m, with the noise reference that was played (NOISE_[IQ]_*.out).  The script
forms the transfer function as the routine does (8192-point Hann windows, 1.25 kHz bins) and fits
  1. 18.8-382 kHz, the band the routine fits: G, theta, tau, Q_L and detuning, with the lead network and the
     installed lag network (Doc P tab:mdc-fits)
  2. at low current (<= 100 mA, where the loop is linear), within +-25 kHz of the carrier, which the routine
     blanks (first draft, sec. 7.2): the integral corner f_i (leak held at the lag network's 0.26 kHz), G and
     theta, with tau, Q_L and detuning held from fit 1.  At high current the compressed klystron makes the
     response widely linear and this fit meaningless (at 497 mA it returns f_i = 11 kHz at rms 0.17)
  3. above 100 mA, the beam's pole pair near +-f_s (131072-point windows): sigma and f_coh, independent of
     the probe spectrum
  4. with --klystron, above 300 mA: the widely linear model with the klystron measured in normal operation
     (g_A 0.40, k_AP 0.10) and G, tau, Q_L held at low-current values (--held, or the demo's 22 mA run)
The models and fits are those of Doc P (spear3rf/scripts/analyze_measure_direct.py).  Rows are appended to
results/closed_loop_<tag>.csv.

usage: python analyze_closed_loop.py <path/DIRECT_I_CLOSED...> [--noise path/NOISE_I_BL.out] [--current MA]
                                     [--klystron [--held G,TAU_NS,QL]] [--tag NAME]
       python analyze_closed_loop.py --demo     (2 Oct 2026: 22 mA at PHASE.C -20 and 497 mA)
"""
import argparse
import math
import sys
from pathlib import Path

import numpy as np
from scipy.optimize import least_squares

import optllrf as ol

sys.path.insert(0, str(ol.ROOT / "spear3rf" / "scripts"))
import analyze_measure_direct as amd  # noqa: E402

DEFAULT_NOISE = amd.TEST / "NOISE_I_BL.out"
KLY = (0.40, 0.10)
COLUMNS = ["tag", "I_mA", "counts_A_dB", "phase_C_deg", "G", "theta_deg", "tau_ns", "Q_L", "df_kHz", "rms_wide",
           "G_near", "theta_near_deg", "f_i_kHz", "rms_near", "f_pole_kHz", "sigma_pole", "theta_kly_deg",
           "df_kly_kHz", "rms_kly"]


def load(path_i: Path, noise_i: Path):
    y = amd.dump(path_i)
    ni = amd.ram(noise_i)
    nq = amd.ram(str(noise_i).replace("NOISE_I", "NOISE_Q"))
    x = (amd.scale(ni[:y.size]) + 1j * amd.scale(nq[:y.size])) / 10.0
    return y, x


def fit_near(f, H, wide, half=25e3):
    """Fit 2: G, theta and the integral corner within +-half of the carrier, tau, Q_L, df held from fit 1."""
    sel = (np.abs(f) > 0) & (np.abs(f) < half)
    ff, HH = f[sel], H[sel]
    tau, QL, df = wide[2], wide[3], wide[4]

    def res(q):
        m = amd.closed_loop([q[0], q[1], tau, QL, df], ff, fi=q[2] * 1e3, fl=amd.LAG[1]) - HH
        return np.concatenate([m.real, m.imag])
    best = None
    for fi0 in (1.0, 3.0, 6.0):
        r = least_squares(res, [wide[0], wide[1], fi0], bounds=([0.05, -90.0, 0.05], [5.0, 90.0, 30.0]),
                          x_scale=[0.1, 5.0, 0.5], max_nfev=4000)
        best = r if best is None or r.cost < best.cost else best
    G, th, fi = best.x
    return (G, th, fi), float(np.sqrt(np.mean(np.abs(amd.closed_loop([G, th, tau, QL, df], ff, fi=fi * 1e3,
                                                                       fl=amd.LAG[1]) - HH) ** 2))), int(sel.sum())


def analyze(path_i: Path, noise_i: Path, current=None, klystron=False, held=None):
    tag = path_i.name.replace("DIRECT_I_CLOSED", "")
    try:
        meta = amd.parse_tag(tag)
    except AttributeError:
        meta = dict(mA=float("nan"), counts_db=float("nan"), phase_c=float("nan"), date="", time="")
    I = current if current is not None else meta["mA"]
    if not math.isfinite(I):
        raise SystemExit("beam current unknown: give --current")
    y, x = load(path_i, noise_i)
    f, H, coh, _ = amd.tfestimate(y, x, 8192)
    sel = (np.abs(f) > 18.8e3) & (np.abs(f) < 382e3)
    wide, r_wide = amd.fit_cl(f[sel], H[sel], I, True)
    print(f"{tag}: {I:.0f} mA, COUNTS.A {meta['counts_db']} dB, PHASE.C {meta['phase_c']} deg;"
          f" coherence {np.median(coh[sel]):.2f}")
    print(f"  18.8-382 kHz: G {wide[0]:.3f} theta {wide[1]:+.1f} deg tau {wide[2]:.0f} ns Q_L {wide[3]:.0f}"
          f" df {wide[4]:+.1f} kHz (rms {r_wide:.4f})")
    near, r_near = (float("nan"),) * 3, float("nan")
    if I <= 100:
        near, r_near, n_near = fit_near(f, H, wide)
        print(f"  +-25 kHz ({n_near} bins): integral corner f_i {near[2]:.2f} kHz (leak {amd.LAG[1] / 1e3:.2f} kHz held;"
              f" lag network {amd.LAG[0] / 1e3:.2f} kHz), G {near[0]:.3f}, theta {near[1]:+.1f} deg (rms {r_near:.4f})")
    else:
        print("  +-25 kHz: not fitted above 100 mA (the compressed klystron makes the response widely linear)")
    pole = (float("nan"), float("nan"))
    if I > 100:
        f17, H17, coh17, win17 = amd.tfestimate(y, x, 2 ** 17)
        sides = [amd.sideband_pole(f17, H17, coh17, win17, s) for s in (+1, -1)]
        pole = (float(np.mean([s[0] for s in sides])), float(np.mean([s[1] for s in sides])))
        print(f"  beam pole near +-f_s: f {pole[0]:.2f} kHz (sides {sides[0][0]:.2f}/{sides[1][0]:.2f}),"
              f" sigma {pole[1]:.0f}/s (sides {sides[0][1]:.0f}/{sides[1][1]:.0f})")
    kly = (float("nan"), float("nan"), float("nan"))
    if klystron and I > 300:
        if held is None:
            raise SystemExit("--klystron needs --held G,TAU_NS,QL (low-current values with the same klystron)")
        p, r = amd.fit_wl(f[sel], H[sel], I, held, s_fix=KLY[0], k_fix=KLY[1])
        kly = (p[1], p[4], r)
        print(f"  klystron g_A {KLY[0]}, k_AP {KLY[1]}, G/tau/Q_L held at {held[0]:.2f}/{held[1]:.0f}/{held[2]:.0f}:"
              f" theta {p[1]:+.1f} deg, df {p[4]:+.1f} kHz (rms {r:.4f})")
    return [tag, I, meta["counts_db"], meta["phase_c"], *wide, r_wide, *near, r_near, *pole, *kly]


def low_current_held(path_i: Path, noise_i: Path):
    """Phase-path gain, delay and Q_L at low current with the klystron of normal operation (Doc P sec:robinson-open)."""
    y, x = load(path_i, noise_i)
    f, H, _, _ = amd.tfestimate(y, x, 8192)
    sel = (np.abs(f) > 18.8e3) & (np.abs(f) < 382e3)
    p, r = amd.fit_wl(f[sel], H[sel], 22, None, s_fix=KLY[0], k_fix=KLY[1])
    print(f"  low current with g_A {KLY[0]}, k_AP {KLY[1]}: G {p[0]:.3f}, tau {p[2]:.0f} ns, Q_L {p[3]:.0f} (rms {r:.4f})")
    return p[0], p[2], p[3]


def save(rows, tag):
    out = ol.RESULTS / f"closed_loop_{tag}.csv"
    new = not out.exists()
    with open(out, "a", encoding="utf-8") as fh:
        if new:
            fh.write(",".join(COLUMNS) + "\n")
        for r in rows:
            fh.write(",".join(ol._fmt(v) if not isinstance(v, str) else v for v in r) + "\n")
    print("appended to", out)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("run", nargs="?", help="path of the DIRECT_I_CLOSED<tag> dump (the Q dump is found by name)")
    ap.add_argument("--noise", default=str(DEFAULT_NOISE), help="noise reference that was played (I file)")
    ap.add_argument("--current", type=float, default=None, help="beam current [mA] if the tag does not carry it")
    ap.add_argument("--klystron", action="store_true")
    ap.add_argument("--held", default=None, help="G,TAU_NS,QL at low current with the same klystron")
    ap.add_argument("--tag", default="study")
    ap.add_argument("--demo", action="store_true")
    a = ap.parse_args()
    noise = Path(a.noise)
    if a.demo:
        low = amd.RUNS / "DIRECT_I_CLOSEDv2850i022gp009pm0200d20261002094700"
        high = amd.RUNS / "DIRECT_I_CLOSEDv2850i497gp009pm0200d20261002135153"
        out = ol.RESULTS / "closed_loop_demo_20261002.csv"
        if out.exists():
            out.unlink()
        rows = [analyze(low, noise)]
        held = low_current_held(low, noise)
        rows.append(analyze(high, noise, klystron=True, held=held))
        save(rows, "demo_20261002")
    elif a.run:
        held = tuple(float(v) for v in a.held.split(",")) if a.held else None
        save([analyze(Path(a.run), noise, a.current, a.klystron, held)], a.tag)
    else:
        ap.error("give a run or --demo")


if __name__ == "__main__":
    main()
