"""Per-point analysis of the scan: one probe capture -> one row of the run log.

For each capture (spear3rf/scripts/fsw_matrix.py format, RMS detector) and its paired EPICS
snapshot (spear3rf.live), the script records the loop settings and the operating point, the
broadband synchrotron line (sigma, f_coh, Q per sideband, n x 60 Hz harmonics masked; the pole
cross-checked within +/- 3 HWHM and with the Fano profile), the beam
motion of the broadband line and of the beam-dominated discrete lines (both station models), the
broadband drive S_n(f_coh), the model predictions at the recorded settings, and the levels of
the 360 Hz-family lines.  Rows are appended to results/runlog_<tag>.csv; fit_sources.py reads it.

usage: python analyze_line.py <capture.json> [--snapshot SNAP.json] [--tag NAME] [--note TEXT]
       python analyze_line.py --demo        (the two captures of 8 Oct 2026)
"""
import argparse
import math
from pathlib import Path

import optllrf as ol

COLUMNS = ["capture", "snapshot", "time", "note", "I_mA", "counts_A_dB", "phase_C_deg", "phase_L_deg", "tracking",
           "intcomp", "leadcomp", "ripple", "kly_drive_W", "kly_fwd_kW", "hvps_kV",
           "f_upper_Hz", "f_lower_Hz", "sigma_upper", "sigma_lower", "Q_mean", "area_upper_dBc", "area_lower_dBc",
           "floor_upper_dBc_Hz", "floor_lower_dBc_Hz",
           "eff_dphi_bb_deg", "eff_dphi_lines_deg", "eff_dphi_total_deg", "eff_dE_total", "eff_S_n_bb",
           "eff_model_f_Hz", "eff_model_sigma",
           "lag_dphi_bb_deg", "lag_dphi_lines_deg", "lag_dphi_total_deg", "lag_dE_total", "lag_S_n_bb",
           "lag_model_f_Hz", "lag_model_sigma",
           "line_8280_dBc", "line_8640_dBc", "line_9000_dBc", "line_9360_dBc", "line_9720_dBc", "line_10080_dBc",
           "f_narrow_Hz", "sigma_narrow", "f_fano_Hz", "sigma_fano"]
FAMILY = (8280, 8640, 9000, 9360, 9720, 10080)


def row_for(capture, snapshot=None, note=""):
    res = ol.analyze_capture(capture, snapshot)
    snap = ol.live.Snapshot.load(ol.resolve_snapshot(res["snapshot"])) if res["snapshot"] else None
    g = (lambda k: snap.get(k, float("nan"))) if snap else (lambda k: float("nan"))
    fits, chk = res["fits"], res["checks"]
    lvl = {fl: max([ln["power_dbc"] for ln in res["lines"] if abs(abs(ln["offset"]) - fl) < 3] or [float("nan")])
           for fl in FAMILY}
    r = [res["capture"], res["snapshot"] or "", snap.time if snap else "", note, g("beam_current_mA"),
         g("direct_counts_A"), g("direct_phase_C"), g("direct_phase_L"), g("direct_track"), g("intcomp"),
         g("leadcomp"), g("rfp_ripple"), g("kly_drive_W"), g("kly_fwd_kW"), g("hvps_kV"),
         fits[1]["f"], fits[-1]["f"], fits[1]["sigma"], fits[-1]["sigma"], res["Q"], fits[1]["area_dbc"],
         fits[-1]["area_dbc"], fits[1]["floor_dbc_hz"], fits[-1]["floor_dbc_hz"]]
    for m in ("eff", "lag"):
        v = res["models"].get(m)
        r += ([v["dphi_broadband_deg"], v["dphi_lines_deg"], v["dphi_total_deg"], v["dE_total"], v["S_n_broadband"],
               v["model_f_coh"], v["model_sigma"]] if v else [float("nan")] * 7)
    r += [lvl[fl] for fl in FAMILY]
    r += [0.5 * (chk[1][k]["f"] + chk[-1][k]["f"]) if j == 0 else 0.5 * (chk[1][k]["sigma"] + chk[-1][k]["sigma"])
          for k in ("narrow", "fano") for j in (0, 1)]
    return r, res


def append(path: Path, row):
    new = not path.exists()
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "a", encoding="utf-8") as fh:
        if new:
            fh.write(",".join(COLUMNS) + "\n")
        fh.write(",".join(ol._fmt(v) if not isinstance(v, str) else v.replace(",", ";") for v in row) + "\n")


def report(row, res):
    d = dict(zip(COLUMNS, row))
    print(f"{d['capture']}  ({d['snapshot'] or 'no snapshot'})")
    print(f"  {d['I_mA']:.0f} mA, COUNTS.A {d['counts_A_dB']} dB, PHASE.C {d['phase_C_deg']} deg, PHASE.L"
          f" {d['phase_L_deg']} deg, tracking {d['tracking']}")
    print(f"  line: f {d['f_upper_Hz']:.0f}/{d['f_lower_Hz']:.0f} Hz, sigma {d['sigma_upper']:.0f}/{d['sigma_lower']:.0f}"
          f" 1/s, Q {d['Q_mean']:.1f}; broadband {d['area_upper_dBc']:.1f}/{d['area_lower_dBc']:.1f} dBc")
    print(f"  pole cross-checks (mean of the sidebands): +/-3 HWHM f {d['f_narrow_Hz']:.0f} Hz sigma"
          f" {d['sigma_narrow']:.0f}; Fano f {d['f_fano_Hz']:.0f} Hz sigma {d['sigma_fano']:.0f}")
    for m in ("eff", "lag"):
        if res["models"].get(m):
            print(f"  {m}: beam phase broadband {d[f'{m}_dphi_bb_deg']:.3f}, lines {d[f'{m}_dphi_lines_deg']:.3f},"
                  f" total {d[f'{m}_dphi_total_deg']:.3f} deg; dE/E {d[f'{m}_dE_total']:.2e}; S_n {d[f'{m}_S_n_bb']:.2e};"
                  f" model f {d[f'{m}_model_f_Hz']:.0f} Hz sigma {d[f'{m}_model_sigma']:.0f}")
    print("  360 Hz family (dBc): " + ", ".join(f"{fl}: {d[f'line_{fl}_dBc']:.1f}" for fl in FAMILY))
    if math.isfinite(d["Q_mean"]) and res["detector"].upper() != "RMS":
        print(f"  warning: detector {res['detector']}; noise levels biased")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("capture", nargs="?")
    ap.add_argument("--snapshot", default=None)
    ap.add_argument("--tag", default="study")
    ap.add_argument("--note", default="")
    ap.add_argument("--demo", action="store_true")
    a = ap.parse_args()
    spectra = ol.ROOT / "spear3rf" / "data" / "spectra"
    caps = ([spectra / "FSW_cavA_20261008T133059.json", spectra / "FSW_cavA_matrix_20261008T153523.json"]
            if a.demo else [Path(a.capture)])
    tag = "demo_20261008" if a.demo else a.tag
    out = ol.RESULTS / f"runlog_{tag}.csv"
    if a.demo and out.exists():
        out.unlink()
    for c in caps:
        row, res = row_for(c, a.snapshot, a.note or ("8 Oct 2026, Doc P R40" if a.demo else ""))
        report(row, res)
        append(out, row)
    print("appended to", out)


if __name__ == "__main__":
    main()
