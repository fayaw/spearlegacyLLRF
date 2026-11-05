"""Separate upstream (klystron) and measurement/reference noise from a gain scan.

Model (Doc P eq:rob-drive, two-quadrature transfers h_x of App. C): at scan point k the broadband
drive of the dipole mode is

    S_n,k = c_kly,k * S_kly + c_meas,k * S_meas,      c_g,k = |h_gPM,k|^2 + r_g |h_gAM,k|^2,

where S_kly, S_meas are the phase-noise spectral densities of the two groups near f_coh and r_g
their amplitude-to-phase noise ratio.  The gain scan determines the two group levels well
(condition number ~4, predict_scan.py) but not the AM/PM split inside a group, so r_g is a
hypothesis (phase only, equal, amplitude only) and the fit reports each.  Points are grouped by
current; the transfers are evaluated at each point's settings and measured f_coh.

usage: python fit_sources.py results/runlog_<tag>.csv [--model eff|lag] [--theta DEG]
       python fit_sources.py --synthetic [--model eff|lag] [--current 500]
"""
import argparse
import csv
import math

import numpy as np
from scipy.optimize import nnls

import optllrf as ol

RATIOS = {"phase only": 0.0, "equal": 1.0, "amplitude only": math.inf}


def columns(h: dict, r_kly: float, r_meas: float) -> tuple[float, float]:
    def grp(pm, am, r):
        return h[am] if math.isinf(r) else h[pm] + r * h[am]
    return grp("klystron_PM", "klystron_AM", r_kly), grp("measurement_PM", "measurement_AM", r_meas)


def fit_group(H: list[dict], S: np.ndarray, n_boot: int = 300, seed: int = 0) -> list[dict]:
    """NNLS in log-weighted form for every pair of AM/PM hypotheses; bootstrap over points."""
    rng = np.random.default_rng(seed)
    out = []
    for nk, rk in RATIOS.items():
        for nm, rm in RATIOS.items():
            A = np.array([columns(h, rk, rm) for h in H])
            W = 1.0 / S                                     # relative errors: weight each point by 1/S
            x, _ = nnls(A * W[:, None], np.ones_like(S))
            pred = A @ x
            rms = float(np.sqrt(np.mean(np.log(pred / S) ** 2))) if np.all(pred > 0) else math.inf
            boots = []
            for _ in range(n_boot):
                i = rng.integers(0, len(S), len(S))
                xb, _ = nnls(A[i] * W[i, None], np.ones(len(i)))
                boots.append(xb)
            boots = np.array(boots)
            out.append(dict(kly=nk, meas=nm, S_kly=x[0], S_meas=x[1], rms_log=rms,
                            S_kly_ci=np.percentile(boots[:, 0], [16, 84]), S_meas_ci=np.percentile(boots[:, 1], [16, 84]),
                            cond=float(np.linalg.cond(A / np.linalg.norm(A, axis=0)))))
    return sorted(out, key=lambda d: d["rms_log"])


def report(I, res, npts):
    print(f"== {I:.0f} mA, {npts} points: hypotheses ranked by the rms log residual of S_n")
    for d in res[:5]:
        print(f"  klystron {d['kly']:15s} measurement {d['meas']:15s}: rms {d['rms_log']:.3f};"
              f" S_kly {d['S_kly']:.2e} [{d['S_kly_ci'][0]:.1e}, {d['S_kly_ci'][1]:.1e}],"
              f" S_meas {d['S_meas']:.2e} [{d['S_meas_ci'][0]:.1e}, {d['S_meas_ci'][1]:.1e}] rad^2/Hz; cond {d['cond']:.1f}")


def from_runlog(path, model, theta, tol_mA=15.0):
    rows = list(csv.DictReader(open(path, encoding="utf-8")))
    groups = {}
    for r in rows:
        I = float(r["I_mA"])
        key = next((k for k in groups if abs(k - I) <= tol_mA), I)
        groups.setdefault(key, []).append(r)
    for I, rs in sorted(groups.items()):
        H, S = [], []
        for r in rs:
            snap = ol.resolve_snapshot(r["snapshot"])
            if snap is None or not math.isfinite(float(r[f"{model}_S_n_bb"])):
                continue
            q = ol.station_from_snapshot(snap, model, counts_db=float(r["counts_A_dB"]), theta_deg=theta)
            f = 0.5 * (float(r["f_upper_Hz"]) + float(r["f_lower_Hz"]))
            H.append(ol.drive_at(q, f))
            S.append(float(r[f"{model}_S_n_bb"]))
        if len(S) < 3:
            print(f"== {I:.0f} mA: {len(S)} usable points; at least 3 gains are needed")
            continue
        report(I, fit_group(H, np.array(S)), len(S))


def synthetic(model, I, s_kly=(3e-12, 3e-11), s_meas=(1e-11, 1e-12), scatter=0.15, seed=1):
    """Scan points from known sources (phase, amplitude PSD per group), with lognormal scatter."""
    rng = np.random.default_rng(seed)
    H, S = [], []
    print(f"synthetic scan, model {model}, {I} mA: klystron PM/AM {s_kly}, measurement PM/AM {s_meas},"
          f" scatter {scatter:.0%}")
    for dg in (0.0, -1.5, -3.0, 0.0, 1.5, 3.0, 0.0):
        q = ol.station(I, model, counts_db=ol.COUNTS_NOW_DB + dg)
        m = ol.mode_or_none(q)
        h = ol.drive_at(q, m.frequency)
        true = (h["klystron_PM"] * s_kly[0] + h["klystron_AM"] * s_kly[1] + h["measurement_PM"] * s_meas[0]
                + h["measurement_AM"] * s_meas[1])
        H.append(h)
        S.append(true * math.exp(rng.normal(0, scatter)))
        print(f"  COUNTS.A {ol.COUNTS_NOW_DB + dg:4.1f} dB: f {m.frequency:5.0f} Hz sigma {m.damping:5.0f};"
              f" S_n {S[-1]:.2e} (true {true:.2e})")
    res = fit_group(H, np.array(S))
    report(I, res, len(S))
    kly_eff = s_kly[0] + s_kly[1]
    print(f"  truth: klystron group {kly_eff:.1e} (mostly {'amplitude' if s_kly[1] > s_kly[0] else 'phase'}),"
          f" measurement group {s_meas[0] + s_meas[1]:.1e} (mostly {'amplitude' if s_meas[1] > s_meas[0] else 'phase'})")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("runlog", nargs="?")
    ap.add_argument("--model", default="eff", choices=sorted(ol.MODELS))
    ap.add_argument("--theta", type=float, default=0.0, help="loop phase error assumed for the model (deg)")
    ap.add_argument("--synthetic", action="store_true")
    ap.add_argument("--current", type=float, default=500.0)
    a = ap.parse_args()
    if a.synthetic:
        synthetic(a.model, a.current)
    elif a.runlog:
        from_runlog(a.runlog, a.model, a.theta)
    else:
        ap.error("give a run log or --synthetic")


if __name__ == "__main__":
    main()
