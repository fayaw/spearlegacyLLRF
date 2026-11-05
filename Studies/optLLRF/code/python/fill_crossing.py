"""HVPS harmonics and the beam's dipole motion along the 0-500 mA fill (study plan sec. 4.5, sec. 5a).

The probe spectrum of 8 Oct 2026, 15:35 (492 mA) lists the 60 Hz harmonics between 5.5 and 10 kHz.  For each
harmonic the script infers the ripple at the klystron output, u_L, by inverting the station model's full
probe response (field modulation plus the beam's response; optllrf), under two hypotheses: the HVPS
modulates the klystron's phase, or its amplitude.  Holding u_L fixed, it then follows the fill:
  * the beam phase driven by each harmonic, |chi(f_L) h(f_L)| u_L, and the broadband part (scaled with the
    jitter tables of predict_ramp.py), against beam current for both station models
  * the crossings: the current at which f_coh passes each harmonic, and the motion there
  * the probe signature E1 will see: each harmonic's sideband level against current (a resonance peak)
  * sensitivity at the crossings: loop-phase lag (lower damping) and a larger ripple
  * what the motion means: energy deviation, the cavity-field modulation it induces, and the amplitude
    factors needed to reach a given beam phase
Writes results/fill_crossing_<model>.csv, fill_crossing_harmonics.csv, fill_crossing_sensitivity.csv and
fill_crossing.png.

usage: python fill_crossing.py [--capture FSW_cavA_matrix_20261008T153523]
"""
import argparse
import csv
import math

import numpy as np

import optllrf as ol

CAPTURE = "FSW_cavA_matrix_20261008T153523"
I_REF = 492.0                                   # beam current of the capture
CURRENTS = np.arange(50.0, 500.1, 5.0)
BAND = (5500.0, 10000.0)                        # harmonics measured on both sides of the line at 500 mA
HYP = ("klystron_PM", "klystron_AM")
THETAS = (0.0, -10.0, -20.0, -25.0, -30.0)


def load_lines(capture):
    rows = list(csv.DictReader(open(ol.RESULTS / f"lines_{capture}.csv", encoding="utf-8")))
    out = {}
    for r in rows:
        f = abs(float(r["offset_Hz"]))
        if BAND[0] <= f <= BAND[1] and float(r["excess_dB"]) > 3.0:
            side = 1 if float(r["offset_Hz"]) > 0 else -1
            out.setdefault(int(r["harmonic"]), {})[side] = 10 ** (float(r["power_dBc"]) / 10)
    return out


def full_response(q, f, src):
    """(I, Q) probe envelope per unit source, beam included; and the beam phase per unit source."""
    r = q.response(np.atleast_1d(f))
    w = r.probe[src] + r.beam_to_probe * (r.chi * r.drive[src])[:, None]
    return w, r.chi * r.drive[src]


def infer_ripple(lines, model, src):
    """Source variance u_L^2/2 at the klystron output for each harmonic, from both sidebands at I_REF."""
    q = ol.station(I_REF, model)
    va2 = abs(q.V_k0[q.probe]) ** 2
    hs = sorted(lines)
    w, _ = full_response(q, 60.0 * np.array(hs), src)
    usb, lsb = ol.sidebands(w)
    out = {}
    for k, n in enumerate(hs):
        est = [2 * va2 * p / (usb[k] if s > 0 else lsb[k]) for s, p in lines[n].items()]
        out[n] = float(np.mean(est))
    return out


def follow(model, src, var_u, theta=0.0, scale=1.0, currents=CURRENTS):
    hs = np.array(sorted(var_u))
    f_l = 60.0 * hs
    vu = np.array([var_u[n] for n in hs]) * scale ** 2
    rows = []
    for I in currents:
        q = ol.station(float(I), model, theta_deg=theta)
        m = ol.mode_or_none(q)
        if m is None:
            rows.append(dict(I=float(I), f=float("nan"), sigma=float("nan"), var=np.full(hs.size, np.nan),
                             probe=np.full(hs.size, np.nan)))
            continue
        w, bp = full_response(q, f_l, src)
        usb, _ = ol.sidebands(w)
        va2 = abs(q.V_k0[q.probe]) ** 2
        rows.append(dict(I=float(I), f=m.frequency, sigma=m.damping, var=np.abs(bp) ** 2 * vu,
                         probe=usb * vu / (2 * va2)))
    return hs, rows


def broadband(model, src, rows, _cache={}):
    """Broadband beam-phase variance along the fill: the 500 mA value of analyze_capture, scaled with the
    jitter per unit source spectral density of predict_ramp.py for the same source."""
    if model not in _cache:
        cap = ol.analyze_capture(ol.ROOT / "spear3rf" / "data" / "spectra" / f"{CAPTURE}.json", models=(model,))
        _cache[model] = cap["models"][model]["var_broadband"]
    v500 = _cache[model]
    tab = list(csv.DictReader(open(ol.RESULTS / f"ramp_{model}.csv", encoding="utf-8")))
    I_t = np.array([float(r["I_mA"]) for r in tab])
    J = np.array([float(r[f"t_{src}"]) for r in tab])
    ref = np.interp(I_REF, I_t, J)
    return np.array([v500 * np.interp(r["I"], I_t, J) / ref for r in rows])


def crossings(hs, rows):
    I = np.array([r["I"] for r in rows])
    f = np.array([r["f"] for r in rows])
    out = []
    for k, n in enumerate(hs):
        fl = 60.0 * n
        d = f - fl
        idx = np.nonzero(np.sign(d[:-1]) * np.sign(d[1:]) < 0)[0]
        v = np.array([r["var"][k] for r in rows])
        p = np.array([r["probe"][k] for r in rows])
        for i in idx:
            Ic = I[i] + (I[i + 1] - I[i]) * d[i] / (d[i] - d[i + 1])
            j = int(np.nanargmax(v))
            jp = int(np.nanargmax(p))
            out.append(dict(n=int(n), f=fl, I_cross=float(Ic), I_peak_motion=float(I[j]),
                            dphi_peak_deg=math.degrees(math.sqrt(v[j])), I_peak_probe=float(I[jp]),
                            probe_gain_dB=10 * math.log10(np.nanmax(p) / p[-1])))
    return out


def per_unit_response(model, n, theta, currents):
    """Beam phase per unit klystron-output ripple at harmonic n (PM: per rad, AM: per unit relative amplitude),
    the probe level per unit ripple variance, f_coh and sigma, at each current."""
    fl = 60.0 * n
    out = []
    for I in currents:
        q = ol.station(float(I), model, theta_deg=theta)
        m = ol.mode_or_none(q)
        if m is None:
            out.append((float(I), float("nan"), float("nan"), {s: float("nan") for s in HYP}))
            continue
        r = q.response(np.array([fl]))
        out.append((float(I), m.frequency, m.damping, {s: float(abs(r.chi[0] * r.drive[s][0])) for s in HYP}))
    return out


def peak_response(model, n, theta):
    """Largest beam response per unit ripple at harmonic n along the fill: 10 mA scan, then 1 mA refinement."""
    coarse = per_unit_response(model, n, theta, np.arange(100.0, 480.1, 10.0))
    res = {}
    for s in HYP:
        v = np.array([c[3][s] for c in coarse])
        if not np.isfinite(v).any():
            res[s] = (float("nan"),) * 4
            continue
        I0 = coarse[int(np.nanargmax(v))][0]
        fine = per_unit_response(model, n, theta, np.arange(max(50.0, I0 - 10), min(500.0, I0 + 10) + 0.1, 1.0))
        fine = [c for c in fine if np.isfinite(c[3][s])]
        best = max(fine, key=lambda c: c[3][s])
        res[s] = (best[0], best[1], best[2], best[3][s])
    return res


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--capture", default=CAPTURE)
    a = ap.parse_args()
    lines = load_lines(a.capture)
    print(f"{len(lines)} harmonics between {BAND[0]:.0f} and {BAND[1]:.0f} Hz in {a.capture}")
    ring = ol.RFSystem().ring
    acw = ring.alpha_c * ring.w_rf
    results, cross_rows, sens_rows = {}, [], []
    for model in ("eff", "lag"):
        out_rows = []
        for src in HYP:
            var_u = infer_ripple(lines, model, src)
            hs, rows = follow(model, src, var_u)
            vbb = broadband(model, src, rows)
            vl = np.array([np.nansum(r["var"]) for r in rows])
            results[(model, src)] = (hs, rows, vbb, vl)
            top = sorted(var_u, key=lambda n: -var_u[n])[:4]
            print(f"== {model}, ripple as {src}: largest inferred ripple at"
                  + ", ".join(f" {60 * n} Hz {math.sqrt(2 * var_u[n]) * (1e4 if src.endswith('AM') else 180 / math.pi * 1e3):.2f}"
                              for n in top) + (" (1e-4 rel.)" if src.endswith("AM") else " (mdeg)"))
            j500 = int(np.argmin(np.abs(CURRENTS - 490)))
            tot = np.sqrt(vl + vbb)
            jmax = int(np.nanargmax(tot[CURRENTS <= 450]))
            print(f"   motion at 490 mA: harmonics {math.degrees(math.sqrt(vl[j500])):.2f}, broadband"
                  f" {math.degrees(math.sqrt(vbb[j500])):.2f}, total {math.degrees(tot[j500]):.2f} deg; maximum below 450 mA:"
                  f" {math.degrees(tot[jmax]):.2f} deg at {CURRENTS[jmax]:.0f} mA (harmonics"
                  f" {math.degrees(math.sqrt(vl[jmax])):.2f}, f_coh {rows[jmax]['f']:.0f} Hz)")
            for c in crossings(hs, rows):
                cross_rows.append([model, src, c["n"], c["f"], c["I_cross"], c["I_peak_motion"], c["dphi_peak_deg"],
                                   c["I_peak_probe"], c["probe_gain_dB"]])
            for k, r in enumerate(rows):
                out_rows.append([src, r["I"], r["f"], r["sigma"], math.degrees(math.sqrt(vl[k])),
                                 math.degrees(math.sqrt(vbb[k])), math.degrees(tot[k]),
                                 60 * int(hs[int(np.nanargmax(r["var"]))]) if np.isfinite(r["var"]).any() else float("nan"),
                                 2 * math.pi * r["f"] / acw * tot[k] if np.isfinite(r["f"]) else float("nan")])
        ol.save_csv(ol.RESULTS / f"fill_crossing_{model}.csv",
                    ["hypothesis", "I_mA", "f_coh_Hz", "sigma_per_s", "dphi_harmonics_deg", "dphi_broadband_deg",
                     "dphi_total_deg", "dominant_harmonic_Hz", "dE_over_E_rms"], out_rows)
    ol.save_csv(ol.RESULTS / "fill_crossing_harmonics.csv",
                ["model", "hypothesis", "harmonic", "f_Hz", "I_cross_mA", "I_peak_motion_mA", "dphi_peak_deg",
                 "I_peak_probe_mA", "probe_rise_dB_vs_500mA"], cross_rows)
    print("== crossings of the 360 Hz family (klystron PM hypothesis): current, beam phase from that harmonic at its peak")
    for r in cross_rows:
        if r[1] == "klystron_PM" and r[2] % 6 == 0:
            print(f"   {r[0]}: {r[3]:.0f} Hz crossed at {r[4]:.0f} mA; that harmonic alone drives {r[6]:.2f} deg (peak at"
                  f" {r[5]:.0f} mA); its probe level peaks at {r[7]:.0f} mA, {r[8]:+.1f} dB above the 500 mA level")

    # sensitivity at the crossings: beam phase per unit klystron ripple at the peak of each 360 Hz-family
    # harmonic's passage, against a loop-phase lag; scaled with the ripple inferred at 492 mA
    print("== sensitivity at the crossings: loop-phase lag (lower damping); response per unit ripple at the peak")
    rip = {(m_, s): infer_ripple(lines, m_, s) for m_ in ("eff", "lag") for s in HYP}
    for model, harmonics in (("eff", (162, 156, 150)), ("lag", (162, 156, 150, 144))):
        for n in harmonics:
            for th in THETAS:
                pk = peak_response(model, n, th)
                for s in HYP:
                    I_pk, f_pk, sg, g = pk[s]
                    u = math.sqrt(2 * rip[(model, s)].get(n, float("nan")))
                    d1 = math.degrees(g * u / math.sqrt(2)) if np.isfinite(g) else float("nan")
                    unit = math.radians(1e-3) if s.endswith("PM") else 1e-4
                    per_unit = math.degrees(g * unit)
                    sens_rows.append([model, s, 60 * n, th, I_pk, f_pk, sg, per_unit, d1,
                                      10.0 / d1 if d1 > 0 else float("nan")])
                    if s == "klystron_PM" or th == 0.0:
                        print(f"   {model} {60 * n} Hz, {s}, theta {th:+.0f}: peak at {I_pk:.0f} mA (f_coh {f_pk:.0f},"
                              f" sigma {sg:.0f}/s); {per_unit:.3f} deg per {'mdeg' if s.endswith('PM') else '1e-4'} of"
                              f" klystron ripple; with the 492 mA ripple {d1:.2f} deg rms (x{10.0 / d1:.0f} for 10 deg)")
    ol.save_csv(ol.RESULTS / "fill_crossing_sensitivity.csv",
                ["model", "hypothesis", "harmonic_Hz", "theta_deg", "I_peak_mA", "f_coh_Hz", "sigma_per_s",
                 "dphi_deg_per_unit_ripple", "dphi_deg_with_492mA_ripple", "ripple_factor_for_10deg"], sens_rows)

    # what one degree means at 250 mA
    q = ol.station(250.0, "eff")
    m = q.mode()
    r = q.response(np.array([m.frequency]))
    usb, lsb = ol.sidebands(r.beam_to_probe)
    va = abs(q.V_k0[q.probe])
    print(f"== 1 deg of beam phase at 250 mA (eff, f_coh {m.frequency:.0f} Hz): dE/E {2 * math.pi * m.frequency / acw * math.radians(1):.2e},"
          f" probe sidebands {10 * math.log10(usb[0] * math.radians(1) ** 2 / (4 * va ** 2)):.1f} /"
          f" {10 * math.log10(lsb[0] * math.radians(1) ** 2 / (4 * va ** 2)):.1f} dBc"
          f" (field modulation {100 * math.sqrt((usb[0] + lsb[0]) / 2) * math.radians(1) / va:.2f}% of the cavity voltage)")
    plot(results)


def plot(results):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(2, 2, figsize=(13, 8.5))
    for c, model in enumerate(("eff", "lag")):
        for src, ls in zip(HYP, ("-", "--")):
            hs, rows, vbb, vl = results[(model, src)]
            I = np.array([r["I"] for r in rows])
            ax[0, c].plot(I, np.degrees(np.sqrt(vl + vbb)), "k", ls=ls, lw=1.6,
                          label=f"total, ripple as {src.replace('klystron_', 'klystron ')}")
            ax[0, c].plot(I, np.degrees(np.sqrt(vbb)), color="0.6", ls=ls, lw=1.0, label=f"broadband ({src[-2:]})")
            if src == "klystron_PM":
                for n in (162, 156, 150, 144, 138):
                    if n in hs:
                        k = int(np.nonzero(hs == n)[0][0])
                        ax[0, c].plot(I, np.degrees(np.sqrt([r["var"][k] for r in rows])), lw=0.9, label=f"{60 * n} Hz (PM)")
                        ax[1, c].plot(I, 10 * np.log10([r["probe"][k] for r in rows]), lw=1.0, label=f"{60 * n} Hz")
        f = np.array([r["f"] for r in results[(model, "klystron_PM")][1]])
        tw = ax[0, c].twinx()
        tw.plot(I, f / 1e3, color="tab:red", lw=0.8, ls=":")
        tw.set_ylabel("f_coh (kHz, dotted)", color="tab:red")
        for n in (162, 156, 150, 144):
            tw.axhline(60 * n / 1e3, color="tab:red", lw=0.4, alpha=0.5)
        ax[0, c].set_title(f"model {model}: beam phase driven by the 500 mA harmonics, along the fill", fontsize=9)
        ax[0, c].set_ylabel("beam phase (deg rms)")
        ax[0, c].legend(fontsize=6.5, loc="upper right")
        ax[0, c].grid(alpha=0.3)
        ax[1, c].set_title(f"model {model}: what the probe shows (upper sideband of each harmonic)", fontsize=9)
        ax[1, c].set_ylabel("probe level (dBc)")
        ax[1, c].set_xlabel("beam current (mA)")
        ax[1, c].legend(fontsize=7)
        ax[1, c].grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(ol.RESULTS / "fill_crossing.png", dpi=130)
    print("wrote", ol.RESULTS / "fill_crossing.png")


if __name__ == "__main__":
    main()
