"""Discrete HVPS line harmonics near the synchrotron line, and where a fill crosses them.

From a cavity-probe capture (default: 8 Oct 2026 15:35, RMS detector [Doc P R40]) the script
  * fits the broadband synchrotron line (n x 60 Hz harmonics masked) on both sidebands
  * lists the discrete n x 60 Hz lines between 2 and 10 kHz
  * computes from the station model at the paired snapshot how much of each line on the probe is
    the beam's response rather than field modulation (klystron amplitude and phase hypotheses)
  * converts the broadband line and the beam-dominated lines into beam phase and energy motion
  * maps the 360 Hz family onto the currents at which f_coh crosses it during a fill
Writes results/lines_<capture>.csv and results/lines_<capture>.png.

usage: python lines_near_fcoh.py [capture.json] [snapshot.json]
"""
import sys
from pathlib import Path

import numpy as np

import optllrf as ol

DEFAULT = ol.ROOT / "spear3rf" / "data" / "spectra" / "FSW_cavA_matrix_20261008T153523.json"


def fcoh_vs_current(model, Is):
    out = []
    for I in Is:
        m = ol.mode_or_none(ol.station(I, model))
        out.append(np.nan if m is None else m.frequency)
    return np.array(out)


def main():
    cap = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT
    res = ol.analyze_capture(cap, sys.argv[2] if len(sys.argv) > 2 else None)
    if res["detector"].upper() != "RMS":
        print(f"warning: detector {res['detector']} -- noise levels are biased; use RMS-detector captures")
    for s, f in res["fits"].items():
        print(f"{'upper' if s > 0 else 'lower'} sideband, broadband part: f {f['f']:.0f} Hz, sigma {f['sigma']:.0f}/s,"
              f" Q {f['Q']:.1f}, peak {f['peak_dbc_hz']:.1f} dBc/Hz, floor {f['floor_dbc_hz']:.1f} dBc/Hz,"
              f" line {f['area_dbc']:.1f} dBc")
    print(f"{len(res['lines'])} discrete lines on the 60 Hz grid between 2 and 10 kHz")
    if not res["models"]:
        print("no paired snapshot found: spectral results only")
        return
    rows = []
    for k, ln in enumerate(res["lines"]):
        row = [ln["offset"], ln["harmonic"], ln["harmonic"] % 6 == 0, ln["power_dbc"], ln["excess_db"]]
        for m in ("eff", "lag"):
            pl = res["models"][m]["lines"][k]
            row += [pl["share_AM"], pl["share_PM"], pl["dphi_deg"]]
        rows.append(row)
    hdr = ["offset_Hz", "harmonic", "six_pulse", "power_dBc", "excess_dB",
           "eff_beam_share_AM", "eff_beam_share_PM", "eff_dphi_deg", "lag_beam_share_AM", "lag_beam_share_PM",
           "lag_dphi_deg"]
    out_csv = ol.save_csv(ol.RESULTS / f"lines_{cap.stem}.csv", hdr, rows)
    f_coh = res["f_coh"]
    print("strongest lines within 1.5 kHz of f_coh (power, beam share AM/PM in model eff, beam phase):")
    for r in sorted([r for r in rows if abs(abs(r[0]) - f_coh) < 1500], key=lambda r: -r[3])[:12]:
        print(f"  {r[0]:+7.0f} Hz (n {r[1]:3d}{', 6-pulse' if r[2] else ''}): {r[3]:6.1f} dBc, +{r[4]:4.1f} dB;"
              f" beam share {r[5]:.2f}/{r[6]:.2f}; dphi {r[7]:.3f} deg")
    print("beam motion at the operating point (broadband line | beam-dominated lines | together):")
    for m, v in res["models"].items():
        print(f"  {m}: {v['dphi_broadband_deg']:.3f} | {v['dphi_lines_deg']:.3f} | {v['dphi_total_deg']:.3f} deg rms"
              f" ({v['timing_total_ps']:.2f} ps); dE/E {v['dE_total']:.2e} rms; broadband drive S_n"
              f" {v['S_n_broadband']:.2e} rad^2/Hz against {v['S_n_floor']:.2e} from the floor")

    Is = np.arange(10, 501, 10, dtype=float)
    fc = {m: fcoh_vs_current(m, Is) for m in ("eff", "lag")}
    family = {}
    for r in rows:
        if r[2] and 7100 <= abs(r[0]) <= 10100:
            k = int(round(abs(r[0])))
            family[k] = max(family.get(k, -200.0), r[3])
    print("360 Hz-family lines (probe level at 500 mA) and the currents at which f_coh crosses them:")
    for fl, lvl in sorted(family.items()):
        txt = []
        for m in fc:
            idx = np.nonzero(np.diff(np.sign(fc[m] - fl)))[0]
            cr = [Is[i] + (fl - fc[m][i]) / (fc[m][i + 1] - fc[m][i]) * 10 for i in idx]
            txt.append(f"{m}: " + (", ".join(f"{c:.0f} mA" for c in cr) if cr else "none"))
        print(f"  {fl:5d} Hz ({lvl:5.1f} dBc): " + "; ".join(txt))
    plot(cap, res, Is, fc, family)
    print("wrote", out_csv)


def plot(cap, res, Is, fc, family):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    d = ol.load_fsw(cap)
    off, dbc_hz = d["off"], d["dbc_hz"]
    fig, ax = plt.subplots(2, 1, figsize=(9, 8))
    for s, c in ((1, "tab:red"), (-1, "tab:blue")):
        m = (s * off > 5500) & (s * off < 9995)
        ax[0].plot(s * off[m] / 1e3, dbc_hz[m], color=c, lw=0.6, label="upper sideband" if s > 0 else "lower sideband")
        f = res["fits"][s]
        x = np.linspace(5500, 9995, 600)
        a = 10 ** (f["peak_dbc_hz"] / 10) - 10 ** (f["floor_dbc_hz"] / 10)
        ax[0].plot(x / 1e3, 10 * np.log10(a * f["hwhm"] ** 2 / ((x - f["f"]) ** 2 + f["hwhm"] ** 2)
                                          + 10 ** (f["floor_dbc_hz"] / 10)), color=c, lw=1.5, ls="--")
    for k in range(16, 28):
        ax[0].axvline(0.36 * k, color="k", lw=0.5, alpha=0.3)
    ax[0].set_xlim(5.5, 10.0)
    ax[0].set_xlabel("offset from the carrier (kHz), both sidebands folded")
    ax[0].set_ylabel("cavity-A probe (dBc/Hz)")
    ax[0].set_title(f"{cap.stem}: broadband line (dashed fit, harmonics masked) and n x 60 Hz harmonics;"
                    " grey: 360 Hz family", fontsize=9)
    ax[0].legend(fontsize=8)
    ax[0].grid(alpha=0.3)
    for m, c in (("eff", "tab:blue"), ("lag", "tab:red")):
        ax[1].plot(Is, fc[m] / 1e3, color=c, lw=2, label=f"f_coh(I), model {m}")
    for fl, lvl in family.items():
        ax[1].axhline(fl / 1e3, color="k", lw=0.8, ls="--", alpha=0.6)
        ax[1].text(503, fl / 1e3, f"{fl} Hz ({lvl:.0f} dBc)", fontsize=7, va="center")
    f0, hw = res["f_coh"], np.mean([res["fits"][s]["hwhm"] for s in (+1, -1)])
    ax[1].axhspan((f0 - hw) / 1e3, (f0 + hw) / 1e3, color="0.85", zorder=0)
    ax[1].set_xlim(0, 500)
    ax[1].set_xlabel("beam current (mA)")
    ax[1].set_ylabel("coherent frequency (kHz)")
    ax[1].set_title("360 Hz-family lines (dashed, probe level at 500 mA) crossed by f_coh during a fill;"
                    " grey band: measured line +/- HWHM", fontsize=9)
    ax[1].set_ylim(7.5, 10.2)
    ax[1].legend(fontsize=8, loc="lower left")
    ax[1].grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(ol.RESULTS / f"lines_{cap.stem}.png", dpi=130)


if __name__ == "__main__":
    main()
