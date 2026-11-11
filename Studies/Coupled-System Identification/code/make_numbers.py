"""Numbers and generated tables quoted in the paper (writes paper/numbers.tex, paper/table_*.tex).

Every number in the text that comes from data is defined here as a macro, computed from the measurement files and
the result files, so that text and results cannot drift apart. Missing result files leave a visible placeholder.
"""
from __future__ import annotations

import glob
import json
import math
from pathlib import Path

import numpy as np

import csi_data as cd
import csi_families as fam
import csi_model as cm

PAPER = cd.STUDY / "paper"
SELECTED = "J_wl_group_ac_ktrip"      # compression per operating point, AM/PM from the trip records
ONE_KLY = "J_wl_global_ac_ktrip"      # one klystron for every current, AM/PM from the trip records
OP_GAIN_DB, OP_PHASE_DEG = 1.3, -20.0  # the station's operating loop-gain and loop-phase settings
G_TO_OP = 10 ** ((OP_GAIN_DB - fam.REF_DB) / 20)   # loop gain at the operating setting / at the fit's reference
TAU_MEASURED_NS = 625.0     # loop delay measured on the station by J. Sebek (private communication, 2026)
MACROS: dict[str, str] = {}


def define(name, value):
    s = str(value)
    if s.startswith("-") and s[1:2].isdigit():
        s = r"\ensuremath{-}" + s[1:]
    MACROS[name] = s


def fmt(x, nd=2):
    return f"{x:.{nd}f}"


def load(name):
    p = cd.RESULTS / name
    return json.loads(p.read_text()) if p.exists() else None


def gain_tracking():
    hi, lo = [], []
    for p in sorted(glob.glob(str(cd.ROOT / "spear3rf" / "data" / "snapshots" / "*.json"))):
        v = json.loads(Path(p).read_text())["values"]
        if v.get("ripple_dc_coef") is None:
            continue
        prod = v["ripple_dc_coef"] * 10 ** (v["kly_gain_dB"] / 20)
        (hi if v["beam_current_mA"] > 400 else lo).append(prod)
    define("gaintrackHigh", f"{np.mean(hi):.1f}")
    define("gaintrackLow", f"{np.mean(lo):.1f}")


def _snapshots():
    """Station snapshots of 2026 with klystron data: (with beam > 400 mA, without beam)."""
    hi, lo = [], []
    for p in sorted(glob.glob(str(cd.ROOT / "spear3rf" / "data" / "snapshots" / "*.json"))):
        v = json.loads(Path(p).read_text())["values"]
        if v.get("kly_drive_W") is None or v.get("hvps_kV") is None:
            continue
        (hi if v["beam_current_mA"] > 400 else lo if v["beam_current_mA"] < 1 else []).append(v)
    return hi, lo


def station_cavities():
    """From the station snapshots and the cavities' R/Q and Q0 (csi_model): U0 from the power balance at 500 mA,
    sum_k (P_fwd - P_refl - V_k^2/(2 R/Q Q0)) / I_b; coupling and loaded Q of each cavity from its reflection without
    beam, on tune, |rho| = (beta - 1)/(beta + 1); and the wall-power check (P_fwd - P_refl)/P_wall without beam."""
    hi, lo = _snapshots()
    r_s = cm.R_OVER_Q * cm.Q0_CAV
    u0 = []
    for v in hi:
        pb = sum((v[f"cav{k}_fwd_kW"] - v[f"cav{k}_refl_kW"]) * 1e3 - (v[f"cav{k}_volt_kV"] * 1e3) ** 2 / (2 * r_s)
                 for k in range(1, 5))
        u0.append(pb / (v["beam_current_mA"] * 1e-3))
    beta = np.array([[(1 + math.sqrt(v[f"cav{k}_refl_kW"] / v[f"cav{k}_fwd_kW"]))
                      / (1 - math.sqrt(v[f"cav{k}_refl_kW"] / v[f"cav{k}_fwd_kW"])) for k in range(1, 5)] for v in lo])
    wall = np.array([[(v[f"cav{k}_fwd_kW"] - v[f"cav{k}_refl_kW"]) * 1e3 / ((v[f"cav{k}_volt_kV"] * 1e3) ** 2 / (2 * r_s))
                      for k in range(1, 5)] for v in lo])
    b_k = beta.mean(axis=0)
    q_k = cm.Q0_CAV / (1 + b_k)
    return dict(u0=np.array(u0), beta=b_k, q_l=q_k, q_eff=1 / np.mean(1 / q_k), wall=wall.mean(axis=0), r_s=r_s)


def _p_forward(i_amp):
    """Forward power the station needs at beam current i_amp: cavity wall losses plus beam power over
    1 - |reflection|^2, the cavities detuned to cancel the reactive beam loading (mean coupling from the snapshots)."""
    beta = float(station_cavities()["beta"].mean())
    p_wall = cm.Station().V_total ** 2 / (2 * cm.N_CAV * cm.R_OVER_Q * cm.Q0_CAV)
    p_beam = cm.U0_EV * i_amp
    b = p_beam / p_wall
    rho = (beta - 1 - b) / (beta + 1 + b)
    return (p_wall + p_beam) / (1 - rho ** 2)


def cathode_voltage():
    """Estimated HVPS voltage at a beam current (mA), which no closed-loop or trip record carries: the forward power
    of _p_forward, scaled to the snapshots, interpolated as a power law between the voltages measured without beam
    and at 500 mA (the HVPS loop holds the drive fixed, so the voltage follows the power the station needs)."""
    hi, lo = _snapshots()
    pts = [(v["beam_current_mA"] / 1e3, v["kly_fwd_kW"] * 1e3) for v in hi + lo]
    scale_p = float(np.mean([p / _p_forward(i) for i, p in pts]))
    (p0, v0), (p1, v1) = [(np.mean([v["kly_fwd_kW"] for v in g]) * 1e3, np.mean([v["hvps_kV"] for v in g])) for g in (lo, hi)]
    n = math.log(v1 / v0) / math.log(p1 / p0)
    return (lambda mA: v0 * (scale_p * _p_forward(mA / 1e3) / p0) ** n), scale_p


def klystron_operating_point():
    """Klystron drive and HVPS voltage in the station snapshots of 2026, with beam (> 400 mA) and without; the ring and
    cavity constants of Table I with their derivation from the snapshots."""
    c = station_cavities()
    define("UzeroMeas", f"{c['u0'].mean()/1e6:.2f}")
    define("UzeroLo", f"{c['u0'].min()/1e6:.2f}")
    define("UzeroHi", f"{c['u0'].max()/1e6:.2f}")
    define("Uzero", f"{cm.U0_EV/1e6:.2f}")
    define("UzeroDip", f"{cm.U0_DIPOLES_EV/1e6:.3f}")
    define("Js", f"{cm.J_S:.2f}")
    define("alphaRad", f"{cm.ALPHA_RAD:.0f}")
    define("phiS", f"{math.degrees(cm.Station().phi_s):.1f}")
    define("RoverQ", f"{cm.R_OVER_Q:.1f}")
    define("Qzero", f"{cm.Q0_CAV:,.0f}".replace(",", "{,}"))
    define("Rshunt", f"{c['r_s']/1e6:.2f}")
    define("betaLo", f"{c['beta'].min():.1f}")
    define("betaHi", f"{c['beta'].max():.1f}")
    define("betaMean", f"{c['beta'].mean():.1f}")
    define("QLrefl", f"{c['q_eff']:.0f}")
    define("QLreflLo", f"{c['q_l'].min():.0f}")
    define("QLreflHi", f"{c['q_l'].max():.0f}")
    define("wallLo", f"{c['wall'].min():.2f}")
    define("wallHi", f"{c['wall'].max():.2f}")
    define("wallMean", f"{c['wall'].mean():.2f}")
    define("halfBW", f"{cm.F_RF / (2 * c['q_eff']) / 1e3:.0f}")
    hi, lo = _snapshots()
    mean = lambda rows, k: float(np.mean([v[k] for v in rows]))
    define("driveSet", f"{hi[0]['kly_drive_set_W']:.0f}")
    define("driveSat", f"{hi[0]['kly_drive_sat_W']:.0f}")
    define("driveHigh", f"{mean(hi, 'kly_drive_W'):.0f}")
    define("driveLow", f"{mean(lo, 'kly_drive_W'):.0f}")
    define("hvpsHigh", f"{mean(hi, 'hvps_kV'):.0f}")
    define("hvpsLow", f"{mean(lo, 'hvps_kV'):.0f}")
    define("hvpsAHigh", f"{mean(hi, 'hvps_A'):.1f}")
    define("hvpsALow", f"{mean(lo, 'hvps_A'):.1f}")
    define("klyEffHigh", f"{mean(hi, 'kly_eff_pct'):.0f}")
    define("klyEffLow", f"{mean(lo, 'kly_eff_pct'):.0f}")
    define("klyFwdHigh", f"{mean(hi, 'kly_fwd_kW'):.0f}")
    define("klyFwdLow", f"{mean(lo, 'kly_fwd_kW'):.0f}")
    define("klyFwdRatio", f"{100 * mean(lo, 'kly_fwd_kW') / mean(hi, 'kly_fwd_kW'):.0f}")
    define("klyGainHigh", f"{mean(hi, 'kly_gain_dB'):.1f}")
    define("klyGainLow", f"{mean(lo, 'kly_gain_dB'):.1f}")
    define("klyGainDiff", f"{round(mean(hi, 'kly_gain_dB'), 1) - round(mean(lo, 'kly_gain_dB'), 1):.1f}")
    define("driveMargin", f"{10 * math.log10(hi[0]['kly_drive_sat_W'] / mean(hi, 'kly_drive_W')):.1f}")
    define("nSnapHigh", f"{len(hi)}")
    define("nSnapLow", f"{len(lo)}")


def noise():
    x = cd.noise_reference("testdata")
    define("noiseCorr", f"{np.corrcoef(x.real, x.imag)[0, 1]:.4f}")


def wide_numbers():
    W = load("wide_fits.json")
    if W is None:
        return
    lin = W["results"]["lin_eff"]
    rms = [e for e, r in zip(lin["rms"], lin["records"]) if r["mA"] < 30]
    define("lowcurChi", f"{min(e**2 for e in rms):.2f}--{max(e**2 for e in rms):.2f}")
    define("chiLoopLinEff", f"{lin['chi2_red']:.2f}")
    # statistical errors of a single record's complex-linear fit (22 mA, operating phase setting)
    recs = lin["records"]
    i = next(k for k, x in enumerate(recs) if x["mA"] < 30 and x["phase_c"] == -20.0)
    free = lin["free"]
    define("sdG", f"{free[f'G[{i}]'][1]:.3f}")
    define("sdTheta", f"{free[f'theta[{i}]'][1]:.1f}")
    define("sdTau", f"{free[f'tau[{i}]'][1]*1e9:.0f}")
    define("sdQL", f"{free[f'Q_L[{i}]'][1]:.0f}")
    dkey = next(k for k in free if k.startswith("df["))
    define("sdDf", f"{free[dkey][1]/1e3:.2f}")


def settings_numbers():
    """The loop settings of the records relative to the operating settings (loop gain 1.3 dB, loop phase -20 deg)."""
    recs = fam.select()
    s1 = [r for r in recs if r.date == "20261002"]
    s2 = [r for r in recs if r.date == "20261103"]
    define("gainSessionOne", f"{s1[0].counts_db - OP_GAIN_DB:+.1f}")
    low = [r.phase_c for r in s1 if r.mA < 30]
    define("phaseScanLow", f"{max(low) - min(low):.0f}")
    hi = sorted({OP_PHASE_DEG - r.phase_c for r in s2 if r.mA > 400})
    define("phaseShiftsHigh", " and ".join(f"{x:.0f}" for x in hi))
    define("gainDropMax", f"{OP_GAIN_DB - min(r.counts_db for r in s2):.1f}")


def lpm_calibration():
    """Calibration of the LPM variance: within each loop-band cell (eight independent estimates over 2.8 kHz), the
    scatter about a linear trend relative to the predicted variance; expected 1. Also the estimator's dimensions."""
    import csi_fit as cf
    import csi_lpm as lp
    ratios, coh = [], []
    for r in fam.select():
        e = lp.estimate(r, cf.F_LO, cf.F_HI)
        f, H, var = e["f"], e["H"], e["var"]
        num = den = 0.0
        for sgn in (-1, 1):
            s = np.nonzero((np.sign(f) == sgn) & (np.abs(f) >= 100e3) & (np.abs(f) < cf.F_HI))[0]
            s = s[np.argsort(np.abs(f[s]))]
            for i in range(0, s.size - 7, 8):
                j = s[i:i + 8]
                w = 1 / var[j]
                A = np.vstack([np.ones(8), (f[j] - f[j].mean()) / 1e3]).T
                c = np.linalg.solve(A.T @ (w[:, None] * A), A.T @ (w * H[j]))
                num += float(np.sum(w * np.abs(H[j] - A @ c) ** 2))
                den += 6
        ratios.append(num / den)
    define("calibMedian", f"{np.median(ratios):.2f}")
    define("calibLo", f"{min(ratios):.2f}")
    define("calibHi", f"{max(ratios):.2f}")
    e = lp.estimate(fam.select()[0], cf.F_LO, cf.F_HI)
    define("lpmBin", f"{e['df']:.1f}")
    define("lpmWidth", f"{(2 * e['n'] + 1) * e['df']:.0f}")
    define("lpmBins", f"{2 * e['n'] + 1}")
    define("lpmSmooth", f"{lp.SMOOTH * e['df'] / 1e3:.0f}")
    define("fSplit", f"{cf.F_SPLIT / 1e3:.0f}")
    define("fHi", f"{cf.F_HI / 1e3:.0f}")
    sp = [cf.lpm_spectrum(r, cf.F_LO, cf.F_HI) for r in fam.select()[:1]][0]
    define("nCellsRecord", f"{sp.n}")
    snr_numbers()


def snr_numbers():
    """Why the near band is noisy: per record, the output-noise level within 6 kHz of the carrier relative to the loop
    band (25-150 kHz), and the median signal-to-noise ratio |H|^2/var of a single estimate in each band (dB)."""
    import csi_fit as cf
    import csi_lpm as lp
    rise, near, loop = [], [], []
    for r in fam.select():
        e = lp.estimate(r, cf.F_LO, cf.F_HI)
        fb = e["k_all"] * e["df"]
        s2 = e["s2"]
        lo_band = (np.abs(fb) >= cf.F_SPLIT) & (np.abs(fb) < 150e3)
        rise.append(10 * np.log10(np.median(s2[np.abs(fb) < 6e3]) / np.median(s2[lo_band])))
        snr = 10 * np.log10(np.abs(e["H"]) ** 2 / e["var"])
        near.append(np.median(snr[np.abs(e["f"]) < cf.F_SPLIT]))
        loop.append(np.median(snr[(np.abs(e["f"]) >= cf.F_SPLIT) & (np.abs(e["f"]) < 150e3)]))
    define("noiseRiseLo", f"{min(rise):.0f}")
    define("noiseRiseHi", f"{max(rise):.0f}")
    define("snrNearLo", f"{min(near):.0f}")
    define("snrNearHi", f"{max(near):.0f}")
    define("snrLoopLo", f"{min(loop):.0f}")
    define("snrLoopHi", f"{max(loop):.0f}")


def joint_numbers():
    J = load("joint_fits.json")
    if J is None:
        return
    R = J["results"]
    sel = R[SELECTED]
    g = sel["globals"]
    define("Gzero", f"{g['G'][0] * G_TO_OP:.2f}")
    define("GzeroErr", f"{max(g['G'][1] * G_TO_OP, 0.005):.2f}")
    define("tauFit", f"{g['tau'][0]*1e9:.0f}")
    define("tauMeas", f"{TAU_MEASURED_NS:.0f}")
    define("tauDiff", f"{g['tau'][0]*1e9 - TAU_MEASURED_NS:.0f}")
    define("tauFitErr", f"{max(g['tau'][1]*1e9, 0.5):.0f}")
    define("QLFit", f"{g['Q_L'][0]:.0f}")
    define("QLFitErr", f"{g['Q_L'][1]:.0f}")
    ac, ace = g["alpha_c"]
    define("alphacFit", f"{ac*1e3:.3f}")
    define("alphacFitErr", f"{ace*1e3:.3f}")
    st = cm.Station(alpha_c=ac)
    fs = st.w_s / 2 / math.pi
    fs_nom = cm.Station().w_s / 2 / math.pi
    define("fsFit", f"{fs/1e3:.2f}")
    define("fsFitErr", f"{fs/1e3 * 0.5 * ace / ac:.2f}")
    define("fsNom", f"{fs_nom/1e3:.2f}")
    define("fsRatio", f"{100 * (fs / fs_nom - 1):.0f}")
    # alpha_c over the compressed-klystron models with alpha_c free: the systematic spread
    acs = [R[n]["globals"]["alpha_c"][0] for n in ("J_wl_group_ac", SELECTED, ONE_KLY, "J_wl_trip_ac",
                                                     "J_wl_global_ac") if n in R]
    define("alphacLo", f"{min(acs)*1e3:.2f}")
    define("alphacHi", f"{max(acs)*1e3:.2f}")
    fsl = [cm.Station(alpha_c=a).w_s / 2 / math.pi for a in acs]
    define("fsLo", f"{min(fsl)/1e3:.1f}")
    define("fsHi", f"{max(fsl)/1e3:.1f}")
    define("alphacAboveLo", f"{100 * (ac / 1.18e-3 - 1):.0f}")
    define("alphacAboveHi", f"{100 * (ac / 1.13e-3 - 1):.0f}")
    if "J_wl_group_ktrip" in R:
        gn = R["J_wl_group_ktrip"]["globals"]
        define("QLSelNom", f"{gn['Q_L'][0]:.0f}")
        define("tauSelNom", f"{gn['tau'][0]*1e9:.0f}")
    define("chainOdd", f"{20 * g['mc1r'][0] / math.log(10):.2f}")
    define("chainEvenPh", f"{math.degrees(g['mc2i'][0]):.1f}")
    for name, key in ((SELECTED, "Sel"), ("J_wl_group_ktrip", "SelNom"), ("J_lin_eff", "Eff"),
                      ("J_lin_eff_ac", "EffAc"), ("J_lin_shared_ac", "Shared"), ("J_spread_ac", "Spread"),
                      ("J_wl_global_ac", "GlobalFree"), (ONE_KLY, "One"), ("J_wl_trip_ac", "Trip"),
                      ("J_wl_group_ac", "Free"), ("J_wl_group_ac_ktrip_nobeam", "Nobeam")):
        if name not in R:
            continue
        r = R[name]
        b = np.array(r["band_chi2"])
        define(f"chi{key}", f"{r['chi2_red']:.3f}")
        define(f"chiWide{key}", f"{b[:, 0].sum() / b[:, 2].sum():.2f}")
        define(f"chiBeam{key}", f"{b[:, 1].sum() / b[:, 3].sum():.2f}")
        define(f"npar{key}", f"{r['n_free']}")
        define(f"daic{key}", f"{r['aic'] - sel['aic']:.0f}")
        define(f"dbic{key}", f"{r['bic'] - sel['bic']:.0f}")
        define(f"dchi{key}", f"{r['chi2'] - sel['chi2']:.0f}")
    define("ndata", f"{sel['n_data']}")
    define("nPoints", f"{sel['n_data']:,}".replace(",", "{,}"))
    recs = sel["records"]
    gr = J["groups"]
    labels = J["group_labels"]
    vk, scale_p = cathode_voltage()
    define("pfwdScale", f"{scale_p:.2f}")
    fmt_range = lambda vals, nd: (f"${vals[0]:+.{nd}f}$" if len(vals) == 1 or max(vals) - min(vals) < 1e-9
                                  else f"${min(vals):+.{nd}f}$ to ${max(vals):+.{nd}f}$")
    rows, ga = [], {}
    order = sorted(range(len(labels)), key=lambda k: (labels[k][:5] != "10/02", float(labels[k].split()[1])))
    for k in order:
        lab = labels[k]
        idx = [i for i, x in enumerate(gr) if x == k]
        r0 = recs[idx[0]]
        e_g = sel["free"].get(f"g_A[g{k}]", [r0["g_A"], float("nan")])[1]
        mA_k = float(np.mean([recs[i]["mA"] for i in idx]))
        ga[k] = (mA_k, r0["g_A"], vk(mA_k))
        dfs = sorted(set(round(recs[i]["df"] / 1e3, 1) for i in idx))
        dg = sorted({round(recs[i]["counts_db"] - OP_GAIN_DB, 1) for i in idx})
        dp = sorted({round(recs[i]["phase_c"] - OP_PHASE_DEG, 0) for i in idx})
        session = "I" if lab.startswith("10/02") else "II"
        rows.append(f"{session} & {mA_k:.0f} & {len(idx)} & {fmt_range(dg, 1)} & {fmt_range(dp, 0)} & {vk(mA_k):.0f} & "
                    f"${r0['g_A']:.2f}\\pm{max(e_g, 0.005):.2f}$ & ${r0['alpha']:+.0f}$ & "
                    f"{', '.join(f'${d:+.1f}$' for d in dfs)}")
    # rows separated by \\ but no break after the last one: a trailing \\ in an \input file adds an empty row
    (PAPER / "table_groups.tex").write_text(" \\\\\n".join(rows) + "\n")
    lowk = min(ga, key=lambda k: ga[k][0])
    define("gaSelLow", f"{ga[lowk][1]:.2f}")
    define("vkLow", f"{ga[lowk][2]:.0f}")
    hiv = [v for m, v, _ in ga.values() if m > 450]
    define("gaSelHighLo", f"{min(hiv):.2f}")
    define("gaSelHighHi", f"{max(hiv):.2f}")
    define("vkHigh", f"{np.mean([u for m, _, u in ga.values() if m > 450]):.0f}")
    mid = sorted((m, v, u) for m, v, u in ga.values() if 100 < m < 450)
    define("gaSelMid", ", ".join(f"{v:.2f}" for m, v, u in mid))
    define("vkMid", ", ".join(f"{u:.0f}" for m, v, u in mid))
    define("kapTrip", f"{fam.K_TRIP:+.2f}")
    define("gaTrip", f"{fam.G_TRIP:.2f}")
    # one klystron: its compression, and where it loses against the selected model
    if ONE_KLY in R:
        one = R[ONE_KLY]
        define("gaOneKly", f"{one['globals']['g_A'][0]:.2f}")
        define("gaOneKlyErr", f"{max(one['globals']['g_A'][1], 0.005):.2f}")
        bo, bs = np.array(one["band_chi2"]), np.array(sel["band_chi2"])
        d = (bo[:, 0] + bo[:, 1]) - (bs[:, 0] + bs[:, 1])
        mA = np.array([x["mA"] for x in recs])
        define("dchiOneLow", f"{d[mA < 30].sum():.0f}")
        define("dchiOneMid", f"{d[(mA > 200) & (mA < 450)].sum():.0f}")
        define("dchiOneHigh", f"{d[mA > 450].sum():.0f}")
    if "J_wl_group_ac" in R:
        kf = [v for k, (v, e) in R["J_wl_group_ac"]["free"].items() if k.startswith("k_AP")]
        define("kapFreeLo", f"{min(kf):+.2f}")
        define("kapFreeHi", f"{max(kf):+.2f}")
        gf = [v for k, (v, e) in R["J_wl_group_ac"]["free"].items() if k.startswith("g_A")]
        define("gaFreeLo", f"{min(gf):.2f}")
        define("gaFreeHi", f"{max(gf):.2f}")
        define("chiCostKap", f"{sel['chi2'] - R['J_wl_group_ac']['chi2']:.0f}")
        define("chiCostKapPct", f"{100 * (sel['chi2'] - R['J_wl_group_ac']['chi2']) / sel['chi2']:.1f}")
        fr = R["J_wl_group_ac"]["records"]
        shifts = [abs(fr[gr.index(k)]["g_A"] - recs[gr.index(k)]["g_A"]) for k in range(len(labels))
                  if recs[gr.index(k)]["mA"] > 450]
        define("gaShiftHigh", f"{max(shifts):.2f}")
        define("gaFreeHigh", f"{np.mean([fr[gr.index(k)]['g_A'] for k in range(len(labels)) if fr[gr.index(k)]['mA'] > 450]):.2f}")
    define("ampLoopHigh", f"{np.mean(hiv) * g['G'][0] * G_TO_OP:.2f}")
    al = [recs[gr.index(k)]["alpha"] for k in range(len(labels))]
    define("alphaSpread", f"{max(al) - min(al):.0f}")
    if "J_wl_group_ac" in R:
        fr = R["J_wl_group_ac"]["records"]
        alf = [fr[gr.index(k)]["alpha"] for k in range(len(labels))]
        define("alphaSpreadFree", f"{max(alf) - min(alf):.0f}")
    # the worst records of the selected model: the extreme settings of the low-current phase scan
    b = np.array(sel["band_chi2"])
    per = (b[:, 0] + b[:, 1]) / (b[:, 2] + b[:, 3])
    is_ext = [x["mA"] < 30 and x["label"].startswith("10/02 09") and x["phase_c"] in (-14.0, -23.0) for x in recs]
    low = [p for p, e in zip(per, is_ext) if e]
    define("chiRecLowLo", f"{min(low):.1f}")
    define("chiRecLowHi", f"{max(low):.1f}")
    define("chiRecOthersMedian", f"{np.median([p for p, e in zip(per, is_ext) if not e]):.2f}")
    define("chiRecOthersHi", f"{max(p for p, e in zip(per, is_ext) if not e):.1f}")
    nb = b[:, 1] / b[:, 3]
    define("chiRecNearLo", f"{nb.min():.2f}")
    define("chiRecNearHi", f"{nb.max():.2f}")
    # effective parameters of the record-by-record complex-linear fits, gain at the operating setting
    if "J_lin_eff_ac" in R:
        eff = R["J_lin_eff_ac"]["records"]
        gop = lambda x: x["G"] / 10 ** ((x["counts_db"] - OP_GAIN_DB) / 20)
        lo = [x for x in eff if x["mA"] < 30]
        hi = [x for x in eff if x["mA"] > 450]
        mid_hi = [x for x in eff if x["mA"] > 300]
        define("effGLow", f"{np.mean([gop(x) for x in lo]):.2f}")
        define("effGHigh", f"{np.mean([gop(x) for x in hi]):.2f}")
        define("effTauLow", f"{np.mean([x['tau'] for x in lo])*1e9:.0f}")
        define("effTauHighLo", f"{min(x['tau'] for x in mid_hi)*1e9:.0f}")
        define("effTauHighHi", f"{max(x['tau'] for x in mid_hi)*1e9:.0f}")
        define("effQLow", f"{np.mean([x['Q_L'] for x in lo]):.0f}")
        define("effQHighLo", f"{min(x['Q_L'] for x in mid_hi):.0f}")
        define("effQHighHi", f"{max(x['Q_L'] for x in mid_hi):.0f}")
        scan = sorted([x for x in lo if x["label"].startswith("10/02 09")], key=lambda x: -x["phase_c"])
        define("effGPhaseA", f"{gop(scan[0]):.2f}")
        define("effGPhaseB", f"{gop(scan[-1]):.2f}")
    # loop phase against the loop-phase setting at 22 mA and in the high-current scan
    for key, sel_fn in (("Low", lambda x: x["mA"] < 30 and x["label"].startswith("10/02 09")),
                        ("Nov", lambda x: x["label"].startswith("11/03") and x["mA"] > 400 and x["counts_db"] == 1.3)):
        xs = [x["phase_c"] for x in recs if sel_fn(x)]
        ys = [x["theta"] for x in recs if sel_fn(x)]
        if len(set(xs)) > 1:
            b = np.polyfit(xs, ys, 1)[0]
            define(f"thetaSlope{key}", f"{-b:.2f}")


def model_checks_numbers():
    M = load("model_checks.json")
    J = load("joint_fits.json")
    if M is None or J is None:
        return
    ref = next(x for x in M if x["label"] == "reference")
    uq = next(x for x in M if x["label"] == "unequal Q")
    fa = [x for x in M if x["f_A"] > 0]
    define("dchiFAmin", f"{min(x['chi2'] for x in fa) - ref['chi2']:.0f}")
    define("fAlo", f"{min(x['f_A'] for x in fa)/1e6:.2f}")
    define("fAhi", f"{max(x['f_A'] for x in fa)/1e6:.0f}")
    define("dchiQrel", f"{uq['chi2'] - ref['chi2']:+.0f}")
    q = np.array(uq["q_rel"])
    define("qSpread", f"{100 * (q.max() - q.min()):.0f}")


def _rec_station(rj):
    keys = ("G", "theta", "tau", "Q_L", "df", "df_spread", "g_A", "k_AP", "alpha", "mc1r", "mc1i", "mc2r", "mc2i", "alpha_c")
    return cm.Station(I_b=rj["mA"] / 1e3, beam=rj.get("beam", True), **{k: rj[k] for k in keys if k in rj})


def subband_numbers():
    """Model-free check of the noise level in the near band (scatter of groups of four neighbouring estimates about
    a linear trend, relative to the predicted variance; pooled over the records), and the residuals of the selected
    and the effective model by sub-band (chi^2 per real component)."""
    import csi_fit as cf
    import csi_lpm as lp
    J = load("joint_fits.json")
    if J is None:
        return
    recs = fam.select()
    ratios = []
    for lo, hi in ((cf.F_LO, 5e3), (15e3, cf.F_SPLIT)):
        num = den = 0.0
        for r in recs:
            e = lp.estimate(r, cf.F_LO, cf.F_HI)
            f, H, var = e["f"], e["H"], e["var"]
            for sgn in (-1, 1):
                s = np.nonzero((np.sign(f) == sgn) & (np.abs(f) >= lo) & (np.abs(f) < hi))[0]
                s = s[np.argsort(np.abs(f[s]))]
                for i in range(0, s.size - 3, 4):
                    j = s[i:i + 4]
                    w = 1 / var[j]
                    A = np.vstack([np.ones(4), (f[j] - f[j].mean()) / 1e3]).T
                    c = np.linalg.solve(A.T @ (w[:, None] * A), A.T @ (w * H[j]))
                    num += float(np.sum(w * np.abs(H[j] - A @ c) ** 2))
                    den += 2
        ratios.append(num / den)
    define("calibNearLo", f"{min(ratios):.1f}")
    define("calibNearHi", f"{max(ratios):.1f}")
    bands = {"Mode": (5e3, 15e3), "LoopLow": (cf.F_SPLIT, 150e3), "LoopHigh": (150e3, cf.F_HI)}
    by_label = {r.label: r for r in recs}
    for name, key in ((SELECTED, "Sel"), ("J_lin_eff_ac", "Eff")):
        acc = {b: [0.0, 0] for b in bands}
        near_z = []
        for rj in J["results"][name]["records"]:
            r, st = by_label[rj["label"]], _rec_station(rj)
            for sp in (cf.lpm_spectrum(r, cf.F_LO, cf.F_SPLIT), cf.lpm_spectrum(r, cf.F_SPLIT, cf.F_HI)):
                res = np.abs((cf.model_on(st, sp) - sp.H) / sp.sigma) ** 2
                fa = np.abs(sp.f)
                for b, (lo, hi) in bands.items():
                    m = (fa >= lo) & (fa < hi)
                    acc[b][0] += float(res[m].sum())
                    acc[b][1] += 2 * int(m.sum())
                if sp.f.min() < 0 < sp.f.max() and fa.min() == 0:
                    near_z.append(np.sqrt(res[fa < 3e3] / 2))
        for b, (s, n) in acc.items():
            define(f"chi{key}{b}", f"{s / n:.2f}" if s / n < 10 else f"{s / n:.1f}")
        if key == "Sel":
            # within 3 kHz of the carrier: median |residual| of each estimate over the records relative to its
            # predicted standard deviation (median of |z| for a complex Gaussian: sqrt(ln 2))
            rel = np.median(np.array(near_z), axis=0) / math.sqrt(math.log(2))
            define("nearCalLo", f"{rel.min():.1f}")
            define("nearCalHi", f"{rel.max():.1f}")


def _mode_errors(R, rows):
    sel = {r["tag"]: r for r in R["records"]}
    ef, es = [], []
    for x in rows:
        rj = sel[x["tag"]]
        st = cm.Station(I_b=rj["mA"] / 1e3, **{k: rj[k] for k in ("G", "theta", "tau", "Q_L", "df", "g_A", "k_AP",
                                                                  "alpha", "alpha_c")})
        s = cm.coupled_mode(st)
        ef.append(s.imag / 2 / math.pi - x["f_free"])
        es.append(-s.real - x["sigma_free"])
    return np.array(ef), np.array(es)


def validation_numbers():
    V = load("beam_mode_validation.json")
    if V is not None:
        wl = "wl_group_ktrip" if "wl_group_ktrip" in V else "wl_group"
        for fam_name, key in (("lin_eff", "Eff"), (wl, "Wl"), ("lin_shared", "Shared")):
            rows = V.get(fam_name)
            if not rows:
                continue
            ef = np.array([x["f_pred"] - x["f_free"] for x in rows])
            es = np.array([x["sigma_pred"] - x["sigma_free"] for x in rows])
            define(f"oob{key}Df", f"{ef.mean():+.0f}")
            define(f"oob{key}DfAbs", f"{abs(ef.mean()):.0f}")
            define(f"oob{key}DfRms", f"{np.sqrt(np.mean(ef**2)):.0f}")
            define(f"oob{key}Ds", f"{es.mean():+.0f}")
            define(f"oob{key}DsAbs", f"{abs(es.mean()):.0f}")
            define(f"oob{key}DsRms", f"{np.sqrt(np.mean(es**2)):.0f}")
            define(f"oob{key}Band", f"{np.median([x['chi2_band'] for x in rows]):.1f}")
        rows = V[wl]
        define("nModeRecs", f"{len(rows)}")
        define("modeFreeFLo", f"{min(x['f_free'] for x in rows)/1e3:.2f}")
        define("modeFreeFHi", f"{max(x['f_free'] for x in rows)/1e3:.2f}")
        define("modeFreeSLo", f"{min(x['sigma_free'] for x in rows):.0f}")
        define("modeFreeSHi", f"{max(x['sigma_free'] for x in rows):.0f}")
        define("modeFreeDf", f"{np.median([x['df_free'] for x in rows]):.0f}")
        define("modeFreeDs", f"{np.median([x['dsigma_free'] for x in rows]):.0f}")
        J = load("joint_fits.json")
        if J is not None:
            for name, key in ((SELECTED, "joint"), (ONE_KLY, "jointOne")):
                if name not in J["results"]:
                    continue
                ef, es = _mode_errors(J["results"][name], rows)
                define(f"{key}Df", f"{ef.mean():+.0f}")
                define(f"{key}DfRms", f"{np.sqrt(np.mean(ef**2)):.0f}")
                define(f"{key}Ds", f"{es.mean():+.0f}")
                define(f"{key}DsAbs", f"{abs(es.mean()):.0f}")
                define(f"{key}DsRms", f"{np.sqrt(np.mean(es**2)):.0f}")
            # damping across the 3 Nov gain scan at 497 mA: measured and selected model
            ef, es = _mode_errors(J["results"][SELECTED], rows)
            nov = [i for i, x in enumerate(rows) if x["label"].startswith("11/03") and x["mA"] > 400]
            hi_g = [i for i in nov if rows[i]["counts_db"] == 1.3]
            lo_g = [i for i in nov if rows[i]["counts_db"] == -0.2]
            sig_free = lambda idx: float(np.mean([rows[i]["sigma_free"] for i in idx]))
            sig_mod = lambda idx: float(np.mean([rows[i]["sigma_free"] + es[i] for i in idx]))
            define("dampHighGainFree", f"{sig_free(hi_g)/1e3:.1f}e3")
            define("dampLowGainFree", f"{sig_free(lo_g)/1e3:.1f}e3")
            define("dampHighGainModel", f"{sig_mod(hi_g)/1e3:.1f}e3")
            define("dampLowGainModel", f"{sig_mod(lo_g)/1e3:.1f}e3")
            define("dampChangePct", f"{100 * (sig_mod(lo_g) - sig_mod(hi_g)) / (sig_free(lo_g) - sig_free(hi_g)):.0f}")
            over = sig_mod(hi_g) - sig_free(hi_g)
            err = float(np.mean([rows[i]['dsigma_free'] for i in hi_g]))
            define("dampHighGainOver", f"{over:.0f}")
            define("dampErrHighGain", f"{err:.0f}")
            define("dampOverRatio", f"{over / err:.1f}")
    J = load("joint_fits.json")
    ks = "J_wl_group_ac_ktrip_ks"
    if J is not None and ks in J["results"]:
        g = J["results"][ks]["globals"]
        define("kscale", f"{g['kappa_scale'][0]:.2f}")
        define("kscaleErr", f"{max(g['kappa_scale'][1], 0.005):.2f}")
        define("alphacKs", f"{g['alpha_c'][0]*1e3:.2f}")
        define("chiKs", f"{J['results'][ks]['chi2_red']:.4f}")


def trip_numbers():
    T = load("trip_klystron.json")
    if T is None:
        return
    s = T["summary"]
    define("tripN", f"{s['n_records']}")
    define("tripUsed", f"{s['n_used']}")
    define("tripFull", f"{s['n_full']}")
    define("tripReduced", f"{s['n_reduced']}")
    define("tripPower", f"{100 * s['power_ratio']:.0f}")
    define("tripDriveDiff", f"{100 * abs(s['drive_full'][0] / s['drive_reduced'][0] - 1):.0f}")
    for key, k in (("tripGA", "g_A"), ("tripGAFull", "g_A_full"), ("tripGARed", "g_A_reduced"),
                   ("tripGAHigh", "g_A_high"), ("tripGALow", "g_A_low"), ("tripGARatio", "g_A_ratio")):
        define(key, f"{s[k][0]:.2f}")
        define(key + "Err", f"{s[k][1]:.2f}")
    define("tripGAHtwo", f"{s['g_A_h2'][0]:.2f}")
    define("tripCohLo", f"{s['coh'][0]:.2f}")
    define("tripCohHi", f"{s['coh'][1]:.2f}")
    define("tripKAP", f"{s['k_AP'][0]:+.2f}")
    define("tripKAPErr", f"{s['k_AP'][1]:.2f}")
    define("tripRatioCohLo", f"{s['ratio_coh'][0]:.2f}")
    define("tripRatioCohHi", f"{s['ratio_coh'][1]:.2f}")
    define("tripAsymLo", f"{s['asym'][0]:.1f}")
    define("tripAsymHi", f"{s['asym'][1]:.1f}")
    define("tripDelay", f"{s['delay_ns'][0]:.0f}")
    used = [r for r in T["records"] if "gain" in r]
    ga = [r["gain"]["bands"][2]["h1"] for r in used]
    define("tripGAmin", f"{min(ga):.2f}")
    define("tripGAmax", f"{max(ga):.2f}")


def _interval(pts, chi_min, opt, level=3.84):
    """Where the profile (grid points and the free optimum) stays below chi_min + level. sqrt(Delta chi^2) is
    interpolated linearly, which is exact for a quadratic profile and so needs no dense grid near the optimum; an end
    of the grid inside the region is returned as it is (the bound is then open)."""
    p = np.array(sorted(list(map(tuple, pts)) + [(opt, chi_min)]))
    x = np.linspace(p[0, 0], p[-1, 0], 20001)
    r = np.interp(x, p[:, 0], np.sqrt(np.maximum(p[:, 1] - chi_min, 0.0)))
    inside = x[r <= math.sqrt(level)]
    return (inside.min(), inside.max()) if inside.size else (float("nan"), float("nan"))


def ident_numbers():
    I = load("identifiability.json")
    if I is None:
        return
    for name, key in (("one record, wideband only", "OneW"), ("one record", "One"), ("500 mA scan (7)", "Scan"),
                      ("all records (18)", "All")):
        d = I.get(name)
        if d is None:
            continue
        for which, w in (("g_A", "ga"), ("k_AP", "kap")):
            pts = np.array(d["profile"][which])
            lo, hi = _interval(pts, d["chi_min"], d["free"][which])
            sgn = "+" if w == "kap" else ""
            define(f"{w}{key}Lo", f"{lo:{sgn}.2f}")
            define(f"{w}{key}Hi", f"{hi:{sgn}.2f}")
            define(f"{w}{key}Opt", f"{d['free'][which]:{sgn}.2f}")
            at = 1.0 if w == "ga" else 0.0
            define(f"{w}{key}At", f"{np.interp(at, pts[:, 0], pts[:, 1]) - d['chi_min']:.0f}")
        c = f"{d['free']['cond']:.1e}"
        mant, ex = c.split("e")
        define(f"cond{key}", f"{mant}\\times10^{{{int(ex)}}}")


def crossval_numbers():
    C = load("crossval.json")
    if C is None:
        return
    for t, key in (("A gain transfer (497 mA)", "Gain"), ("B phase transfer (22 mA)", "Phase"),
                   ("C current transfer 242 mA", "Ia"), ("C current transfer 363 mA", "Ib"),
                   ("C current transfer 395 mA", "Ic")):
        if t not in C:
            continue
        for name, m in (("J_lin_eff_ac", "Eff"), ("J_lin_shared_ac", "Shared"), ("J_wl_group_ac", "Free"),
                        (ONE_KLY, "One"), (SELECTED, "Sel")):
            rows = C[t].get(name)
            if rows:
                define(f"cv{key}{m}", f"{np.mean([x['chi2_red'] for x in rows]):.2f}")
                define(f"cv{key}Near{m}", f"{min(x['beam'] for x in rows):.1f}--{max(x['beam'] for x in rows):.1f}")
        rows = C[t][SELECTED]
        define(f"cv{key}In", f"{np.mean([x['insample'] for x in rows]):.2f}")


def main():
    gain_tracking()
    klystron_operating_point()
    noise()
    settings_numbers()
    wide_numbers()
    lpm_calibration()
    joint_numbers()
    model_checks_numbers()
    subband_numbers()
    validation_numbers()
    trip_numbers()
    ident_numbers()
    crossval_numbers()
    lines = [f"\\newcommand{{\\{k}}}{{{v}}}" for k, v in sorted(MACROS.items())]
    (PAPER / "numbers.tex").write_text("% generated by code/make_numbers.py\n" + "\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
