"""Expected values for the gain/phase scan, source signatures and identifiability.

For the scan matrix of the study plan (currents 100, 200, 350, 500 mA; COUNTS.A = 1.3 dB plus
0, -1.5, -3, +1.5, +3 dB; phase set A theta = 0 and set B theta = +5 deg at 200 and 500 mA) and
for both station models the script tabulates at every point:
  * f_coh, sigma, Q, |chi|max, sigma relative to the baseline and the stop threshold of the study
    plan (sec. 11: stop if the measured ratio falls below 0.7 x the smaller of the two models'
    ratios), with flags for Q > 35 at 350-500 mA and for sigma below radiation damping
  * the drive transfer |h_x(f_coh)|^2 of each noise source (Doc P eq:rob-drive)
  * the variance of the broadband motion per unit source spectral density, relative to the
    baseline step (the signature that identifies the dominant source)
  * the response |chi| at the 360 Hz-family lines near f_coh (discrete-line drive)
  * the probe conversion factor P/P_c per rad^2 (Doc P eq:rob-line-area)
and, per current, the conditioning of the source fit S_n,k = sum_x |h_x,k|^2 S_x.
Writes results/scan_expected.csv, results/scan_identifiability.csv and results/scan_signatures.png.

usage: python predict_scan.py
"""
import math

import numpy as np

import optllrf as ol

CURRENTS = (100, 200, 350, 500)
STEPS = (0.0, -1.5, -3.0, 1.5, 3.0)
PHASE_B = {200: (0.0, -3.0, 1.5), 500: (0.0, -3.0, 1.5)}
LINES = (7920, 8280, 8640, 9000, 9360, 9720, 10080)
A_RAD = ol.RFSystem().ring.alpha_rad
STOP_FACTOR = 0.7               # plan sec. 11: measured sigma ratio below 0.7 x the smaller predicted ratio
Q_LIMIT_FROM_MA = 350           # Q <= 35 applies where both models start below it


def point(I, model, dg, theta):
    q = ol.station(I, model, counts_db=ol.COUNTS_NOW_DB + dg, theta_deg=theta)
    m = ol.mode_or_none(q)
    if m is None:
        return None
    ws, wc, sig = q.system.w_s, m.s.imag, m.damping
    h = ol.drive_at(q, m.frequency)
    res = {s: ws ** 4 * h[s] / (8 * wc ** 2 * sig) for s in ol.SOURCES}       # <dphi^2> per unit PSD
    chi_l = {fl: ol.chi_at(q, fl) for fl in LINES}
    pu, pl = ol.probe_power_per_rad2(q, m.frequency)
    return dict(f=m.frequency, sigma=sig, Q=m.Q, chi_max=m.Q * (ws / wc) ** 2, h=h, res=res, chi_l=chi_l,
                probe_u=pu, probe_l=pl)


def main():
    rows, ident, sig_plot, ratios = [], [], {}, {}
    for model in ("eff", "lag"):
        print(f"== model {model}: {ol.MODELS[model]}")
        for I in CURRENTS:
            sets = [("A", 0.0, STEPS)] + ([("B", 5.0, PHASE_B[I])] if I in PHASE_B else [])
            base = point(I, model, 0.0, 0.0)
            hmat = []
            for tag, th, steps in sets:
                for dg in steps:
                    p = point(I, model, dg, th)
                    if p is None:
                        print(f"  {I} mA set {tag} {dg:+.1f} dB: field loop unstable or no root")
                        continue
                    ratio = {s: p["res"][s] / base["res"][s] for s in ol.SOURCES}
                    rs = p["sigma"] / base["sigma"]
                    ratios.setdefault((I, tag, dg), []).append(rs)
                    near = min(LINES, key=lambda fl: abs(fl - p["f"]))
                    flags = (["Q > 35"] if I >= Q_LIMIT_FROM_MA and p["Q"] > 35 else []) + (
                        ["sigma < alpha_rad"] if p["sigma"] < A_RAD else [])
                    flag = "; ".join(flags)
                    rows.append([model, I, tag, th, ol.COUNTS_NOW_DB + dg, p["f"], p["sigma"], p["Q"], p["chi_max"]]
                                + [p["h"][s] for s in ol.SOURCES] + [ratio[s] for s in ol.SOURCES]
                                + [p["chi_l"][fl] for fl in LINES] + [p["probe_u"], p["probe_l"], near, rs,
                                                                       (I, tag, dg), flag])
                    hmat.append([p["h"][s] for s in ol.SOURCES])
                    if tag == "A":
                        sig_plot.setdefault((model, I), []).append((dg, p["f"], p["sigma"], ratio))
                    print(f"  {I:3d} mA set {tag} G {ol.COUNTS_NOW_DB + dg:4.1f} dB: f {p['f']:5.0f} Hz sigma {p['sigma']:5.0f}"
                          f" Q {p['Q']:5.1f}  motion vs baseline kPM {ratio['klystron_PM']:4.2f} kAM {ratio['klystron_AM']:4.2f}"
                          f" mPM {ratio['measurement_PM']:4.2f} mAM {ratio['measurement_AM']:4.2f};"
                          f" |chi| at {near} Hz {p['chi_l'][near]:5.1f} {flag}")
            A = np.array(hmat)
            An = A / np.linalg.norm(A, axis=0)
            subsets = {"all four": [0, 1, 2, 3], "klystron PM+AM": [0, 1], "PM: klystron+measurement": [0, 2],
                       "AM: klystron+measurement": [1, 3], "klystron PM + measurement AM": [0, 3]}
            for name, cols in subsets.items():
                sv = np.linalg.svd(An[:, cols], compute_uv=False)
                cond = sv[0] / sv[-1] if sv[-1] > 0 else math.inf
                ident.append([model, I, name, len(A), cond])
            conds = ", ".join(f"{r[2]} {r[4]:.0f}" for r in ident[-len(subsets):])
            print(f"  {I} mA: condition numbers of the source fit ({len(A)} points): {conds}")
    for r in rows:                         # the threshold needs both models
        r[-2] = STOP_FACTOR * min(ratios[r[-2]])
    hdr = (["model", "I_mA", "phase_set", "theta_deg", "counts_dB", "f_coh_Hz", "sigma_per_s", "Q", "chi_max"]
           + [f"h2_{s}" for s in ol.SOURCES] + [f"motion_ratio_{s}" for s in ol.SOURCES]
           + [f"chi_at_{fl}" for fl in LINES] + ["probe_upper_per_rad2", "probe_lower_per_rad2", "nearest_line_Hz",
                                                 "sigma_ratio", "stop_below_ratio", "flag"])
    ol.save_csv(ol.RESULTS / "scan_expected.csv", hdr, rows)
    ol.save_csv(ol.RESULTS / "scan_identifiability.csv", ["model", "I_mA", "sources", "points", "condition"], ident)
    plot(sig_plot)


def plot(sig_plot):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(2, 4, figsize=(13, 6), sharex=True, sharey="row")
    sty = {"klystron_PM": ("tab:brown", "-"), "klystron_AM": ("tab:brown", "--"),
           "measurement_PM": ("tab:blue", "-"), "measurement_AM": ("tab:blue", "--")}
    for c, I in enumerate(CURRENTS):
        for r, model in enumerate(("eff", "lag")):
            pts = sorted(sig_plot.get((model, I), []))
            g = [ol.COUNTS_NOW_DB + p[0] for p in pts]
            for s in ol.SOURCES:
                ax[r, c].semilogy(g, [p[3][s] for p in pts], color=sty[s][0], ls=sty[s][1], marker="o", ms=3,
                                  label=ol.SOURCE_LABEL[s])
            ax[r, c].axhline(1, color="k", lw=0.8)
            ax[r, c].set_title(f"{I} mA, model {model}", fontsize=9)
            ax[r, c].grid(alpha=0.3, which="both")
            if r == 1:
                ax[r, c].set_xlabel("COUNTS.A (dB)")
        ax[0, 0].set_ylabel("motion variance / baseline")
        ax[1, 0].set_ylabel("motion variance / baseline")
    ax[0, 0].legend(fontsize=7)
    fig.suptitle("Source signatures: variance of the broadband beam motion versus gain, relative to the 1.3 dB baseline,"
                 " if one source dominates", fontsize=10)
    fig.tight_layout()
    fig.savefig(ol.RESULTS / "scan_signatures.png", dpi=130)
    print("wrote", ol.RESULTS / "scan_expected.csv", "and scan_signatures.png")


if __name__ == "__main__":
    main()
