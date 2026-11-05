"""Theory for the 0-500 mA ramp: damping, coherent frequency, phase margins and noise response.

For each station model of optllrf.MODELS (tuners at the optimum detuning, loop at today's
COUNTS.A = 1.3 dB, theta = 0 unless stated) the script computes along the fill:
  * coherent frequency f_coh, damping rate sigma, line Q and peak response |chi|max
  * beam jitter per unit white spectral density of each noise source (timing and energy)
  * the lag-side loop-phase error at which sigma falls to 2 alpha_rad and to 0 (beam loss)
  * for the lag network, sigma(I) versus the klystron's amplitude gain g_A
  * the currents where f_coh crosses the 360 Hz family of HVPS line harmonics
Writes results/ramp_*.csv and results/ramp_*.png and prints a summary.

usage: python predict_ramp.py [--fast]     (--fast: coarser current grid, about 1 min)
"""
import math
import sys

import numpy as np

import optllrf as ol

FAST = "--fast" in sys.argv
CURRENTS = np.arange(10, 501, 20 if FAST else 10, dtype=float)
TOL_CURRENTS = (25, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500)
A_RAD = ol.RFSystem().ring.alpha_rad


def ramp_table(model: str) -> list[list]:
    rows = []
    for I in CURRENTS:
        q = ol.station(I, model)
        m = ol.mode_or_none(q)
        if m is None:
            rows.append([I] + [float("nan")] * 12)
            continue
        ws, wc = q.system.w_s, m.s.imag
        j = ol.jitter(q)
        rows.append([I, m.frequency, m.damping, m.Q, m.Q * (ws / wc) ** 2]
                    + [j[s][0] for s in ol.SOURCES] + [j[s][1] for s in ol.SOURCES])
    return rows


def sigma_at(I, model, theta, **kw):
    m = ol.mode_or_none(ol.station(I, model, theta_deg=theta, **kw))
    return float("nan") if m is None else m.damping


def lag_limit(I, model, level, step=2.0):
    """Most negative theta (lag) before sigma drops below ``level``; NaN if it never does by -90 deg."""
    prev_t, prev_s = 0.0, sigma_at(I, model, 0.0)
    if not prev_s > level:
        return 0.0
    for t in np.arange(-step, -90.0 - 1e-9, -step):
        s = sigma_at(I, model, t)
        if not np.isfinite(s) or s <= level:
            if not np.isfinite(s):
                return t
            return prev_t + (level - prev_s) * (t - prev_t) / (s - prev_s)
        prev_t, prev_s = t, s
    return float("nan")


def crossings(Is, fc, grid=360.0):
    out = []
    for k in range(int(np.nanmin(fc) // grid), int(np.nanmax(fc) // grid) + 2):
        fl = grid * k
        idx = np.nonzero(np.diff(np.sign(fc - fl)))[0]
        for i in idx:
            if np.isfinite(fc[i]) and np.isfinite(fc[i + 1]):
                out.append((fl, Is[i] + (fl - fc[i]) / (fc[i + 1] - fc[i]) * (Is[i + 1] - Is[i])))
    return out


def main():
    ol.RESULTS.mkdir(parents=True, exist_ok=True)
    hdr = (["I_mA", "f_coh_Hz", "sigma_per_s", "Q", "chi_max"]
           + [f"t_{s}" for s in ol.SOURCES] + [f"e_{s}" for s in ol.SOURCES])
    tables = {}
    for model in ("eff", "lag", "prop"):
        rows = ramp_table(model)
        tables[model] = np.array(rows, float)
        ol.save_csv(ol.RESULTS / f"ramp_{model}.csv", hdr, rows)
        t = tables[model]
        print(f"== {model}: {ol.MODELS[model]}")
        for I in (10, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500):
            i = int(np.argmin(np.abs(t[:, 0] - I)))
            if abs(t[i, 0] - I) > 1:
                continue
            print(f"  {t[i,0]:4.0f} mA: f_coh {t[i,1]:6.0f} Hz  sigma {t[i,2]:6.0f}/s  Q {t[i,3]:5.1f}  |chi|max {t[i,4]:5.1f}"
                  f"  jitter/unit PSD (timing) kPM {t[i,5]:8.3g} kAM {t[i,6]:8.3g} mPM {t[i,7]:8.3g} mAM {t[i,8]:8.3g}")

    print("== lag-side phase margins (theta at sigma = 2 alpha_rad, sigma = 0)")
    tol_rows = []
    for I in TOL_CURRENTS:
        row = [I]
        for model in ("eff", "lag", "prop"):
            row += [lag_limit(I, model, 2 * A_RAD), lag_limit(I, model, 0.0)]
        tol_rows.append(row)
        print(f"  {I:4d} mA: eff {row[1]:6.1f}/{row[2]:6.1f}  lag {row[3]:6.1f}/{row[4]:6.1f}  prop {row[5]:6.1f}/{row[6]:6.1f}")
    ol.save_csv(ol.RESULTS / "ramp_phase_tolerance.csv",
                ["I_mA", "eff_2arad", "eff_zero", "lag_2arad", "lag_zero", "prop_2arad", "prop_zero"], tol_rows)

    print("== lag network: sigma(I) [1/s] versus klystron amplitude gain g_A (k_AP 0.1; g_A = 1: linear)")
    gas = (1.0, 0.8, 0.6, 0.4)
    k_rows = []
    for I in CURRENTS:
        row = [I]
        for ga in gas:
            row.append(sigma_at(I, "lag", 0.0, amp_gain=ga, am_pm=0.0 if ga == 1.0 else 0.10))
        k_rows.append(row)
    ol.save_csv(ol.RESULTS / "ramp_klystron.csv", ["I_mA"] + [f"sigma_gA_{g:.1f}" for g in gas], k_rows)
    k_arr = np.array(k_rows)
    for I in (100, 200, 300, 400, 500):
        i = int(np.argmin(np.abs(k_arr[:, 0] - I)))
        print(f"  {I:4d} mA: " + "  ".join(f"g_A {g:.1f}: {k_arr[i, 1 + n]:6.0f}" for n, g in enumerate(gas)))
    for n, g in enumerate(gas):
        bad = k_arr[k_arr[:, 1 + n] < 0, 0]
        low = k_arr[k_arr[:, 1 + n] < A_RAD, 0]
        print(f"  g_A {g:.1f}: unstable above {bad.min():.0f} mA" if bad.size else f"  g_A {g:.1f}: stable to 500 mA",
              f"; cavities anti-damp (sigma < alpha_rad) from {low.min():.0f} mA" if low.size else "")

    print("== tuner lag: detuning as a fraction of the optimum (f_coh, sigma)")
    fracs = (0.6, 0.8, 1.0, 1.2)
    t_rows = []
    for model in ("eff", "lag"):
        for I in (100, 200, 300, 500):
            row = [model, I]
            for fr in fracs:
                m = ol.mode_or_none(ol.station(I, model, detune_frac=fr))
                row += [m.frequency, m.damping] if m else [float("nan")] * 2
            t_rows.append(row)
            print(f"  {model} {I:3d} mA: " + "  ".join(f"{fr:.1f}: {row[2 + 2 * n]:5.0f} Hz/{row[3 + 2 * n]:5.0f}"
                                                     for n, fr in enumerate(fracs)))
    ol.save_csv(ol.RESULTS / "ramp_tuner.csv",
                ["model", "I_mA"] + [f"{q}_{fr:.1f}" for fr in fracs for q in ("f_coh", "sigma")], t_rows)

    print("== f_coh crossings of the 360 Hz family (6-pulse HVPS harmonics)")
    c_rows = []
    for model in ("eff", "lag"):
        t = tables[model]
        Is, fc, sg = t[:, 0], t[:, 1], t[:, 2]
        slope = np.gradient(fc, Is)
        for fl, Ic in crossings(Is, fc):
            gam = np.interp(Ic, Is, sg) / (2 * math.pi)
            width = gam / abs(np.interp(Ic, Is, slope))
            c_rows.append([model, fl, Ic, gam, width])
            print(f"  {model}: f_coh = {fl:5.0f} Hz at {Ic:5.0f} mA (line HWHM {gam:4.0f} Hz -> +/-{width:3.0f} mA)")
    ol.save_csv(ol.RESULTS / "ramp_crossings.csv", ["model", "line_Hz", "I_mA", "hwhm_Hz", "halfwidth_mA"], c_rows)

    plot(tables, np.array(tol_rows, float), k_arr, gas)


def plot(tables, tol, k_arr, gas):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    col = {"eff": "tab:blue", "lag": "tab:red", "prop": "0.5"}
    lab = {"eff": "eff: effective 1 kHz integral, linear klystron", "lag": "lag: lag network, measured klystron",
           "prop": "prop: proportional only"}

    fig, ax = plt.subplots(2, 1, figsize=(8, 7.5), sharex=True)
    for m in ("eff", "lag", "prop"):
        t = tables[m]
        ax[0].plot(t[:, 0], t[:, 1] / 1e3, color=col[m], lw=2, label=lab[m])
        ax[1].plot(t[:, 0], t[:, 2], color=col[m], lw=2)
    for k in range(20, 29):
        if 7.5 <= 0.36 * k <= 10.2:
            ax[0].axhline(0.36 * k, color="k", lw=0.5, alpha=0.35)
            ax[0].text(505, 0.36 * k, f"{360 * k} Hz", fontsize=7, va="center")
    ax[0].set_ylabel("coherent frequency (kHz)")
    ax[0].set_ylim(7.5, 10.2)
    ax[0].legend(fontsize=8, loc="lower left")
    ax[0].set_title("f_coh crosses the 6-pulse HVPS harmonics (horizontal lines) during the fill", fontsize=9)
    ax[1].axhline(A_RAD, color="k", ls="--", lw=1)
    ax[1].axhline(2 * A_RAD, color="k", ls=":", lw=1)
    ax[1].text(15, A_RAD * 1.03, "radiation damping", fontsize=8)
    ax[1].text(15, 2 * A_RAD * 1.03, "2 x radiation damping (acceptance)", fontsize=8)
    ax[1].set_ylabel("damping rate sigma (1/s)")
    ax[1].set_xlabel("beam current (mA)")
    for a in ax:
        a.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(ol.RESULTS / "ramp_sigma_fcoh.png", dpi=130)

    fig, ax = plt.subplots(figsize=(8, 4.2))
    for n, m in enumerate(("eff", "lag", "prop")):
        ax.plot(tol[:, 0], tol[:, 1 + 2 * n], color=col[m], ls=":", lw=1.5)
        ax.plot(tol[:, 0], tol[:, 2 + 2 * n], color=col[m], lw=2, label=lab[m])
    ax.set_xlabel("beam current (mA)")
    ax.set_ylabel("loop phase error theta (deg, negative = lag)")
    ax.set_title("Lag that brings sigma to 2 x radiation damping (dotted) and to zero, beam loss (solid)", fontsize=9)
    ax.set_ylim(-95, 5)
    ax.grid(alpha=0.3)
    ax.legend(fontsize=8, loc="lower right")
    fig.tight_layout()
    fig.savefig(ol.RESULTS / "ramp_phase_tolerance.png", dpi=130)

    fig, ax = plt.subplots(1, 2, figsize=(10, 4.2), sharex=True)
    sty = {"klystron_PM": "-", "klystron_AM": "--", "measurement_PM": "-.", "measurement_AM": ":"}
    for m in ("eff", "lag"):
        t = tables[m]
        for n, s in enumerate(ol.SOURCES):
            ax[0].semilogy(t[:, 0], t[:, 5 + n], color=col[m], ls=sty[s], lw=1.6,
                           label=f"{m}: {ol.SOURCE_LABEL[s]}")
            ax[1].semilogy(t[:, 0], t[:, 9 + n], color=col[m], ls=sty[s], lw=1.6)
    ax[0].set_ylabel("<dphi^2> per unit source PSD (Hz)")
    ax[1].set_ylabel("<(dE/E0)^2> per unit source PSD (Hz)")
    for a in ax:
        a.set_xlabel("beam current (mA)")
        a.grid(alpha=0.3, which="both")
    ax[0].legend(fontsize=6.5, loc="upper right")
    fig.suptitle("Beam jitter from white noise of each source along the fill (timing left, energy right)", fontsize=9)
    fig.tight_layout()
    fig.savefig(ol.RESULTS / "ramp_jitter.png", dpi=130)

    fig, ax = plt.subplots(figsize=(8, 4.2))
    for n, g in enumerate(gas):
        ax.plot(k_arr[:, 0], k_arr[:, 1 + n], lw=2, label=f"g_A = {g:.1f}" + (" (linear klystron)" if g == 1 else ""))
    ax.axhline(0, color="k", lw=1)
    ax.axhline(A_RAD, color="k", ls="--", lw=1)
    ax.axhline(2 * A_RAD, color="k", ls=":", lw=1)
    ax.set_xlabel("beam current (mA)")
    ax.set_ylabel("damping rate sigma (1/s)")
    ax.set_title("Lag network: the damping depends on the klystron's amplitude compression", fontsize=9)
    ax.grid(alpha=0.3)
    ax.legend(fontsize=8)
    fig.tight_layout()
    fig.savefig(ol.RESULTS / "ramp_klystron.png", dpi=130)
    print("figures written to", ol.RESULTS)


if __name__ == "__main__":
    main()
