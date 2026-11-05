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
Q0_CAV, BETA = 32000.0, 3.8           # unloaded Q and coupling of each cavity (Doc P); Q_L = Q0/(1 + beta) = 6670
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


def _p_forward(i_amp):
    """Forward power the station needs at beam current i_amp: cavity wall losses plus beam power over
    1 - |reflection|^2, the cavities detuned to cancel the reactive beam loading (coupling BETA)."""
    p_wall = cm.Station().V_total ** 2 / (2 * cm.N_CAV * cm.R_OVER_Q * Q0_CAV)
    p_beam = cm.U0_EV * i_amp
    b = p_beam / p_wall
    rho = (BETA - 1 - b) / (BETA + 1 + b)
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
    """Klystron drive and HVPS voltage in the station snapshots of 2026, with beam (> 400 mA) and without."""
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


def table_data():
    recs = fam.select()
    groups = fam.group_index(recs)
    rows = []
    for r, g in zip(recs, groups):
        d = f"{int(r.date[6:])} {'Oct' if r.date[4:6] == '10' else 'Nov'}, {r.time[:5]}"
        rows.append(f"{d} & {r.mA:.0f} & ${r.counts_db:+.1f}$ & ${r.phase_c:.0f}$ & {g + 1} \\\\")
    (PAPER / "table_data.tex").write_text("\n".join(rows) + "\n")


def wide_numbers():
    W = load("wide_fits.json")
    if W is None:
        return
    lin = W["results"]["lin_eff"]
    rms = [e for e, r in zip(lin["rms"], lin["records"]) if r["mA"] < 30]
    define("lowcurChi", f"{min(e**2 for e in rms):.2f}--{max(e**2 for e in rms):.2f}")


def half_split():
    """Calibration of the H1 variance: two half-record estimates against the predicted variance (median ratio)."""
    from scipy.ndimage import median_filter
    meds = []
    x = cd.noise_reference("testdata")
    for r in fam.select():
        y = cd.closed_loop_dump(r)
        n = y.size // 2
        a, b = (cd.welch_tf(y[i * n:(i + 1) * n], x[i * n:(i + 1) * n], 8192) for i in (0, 1))
        full = cd.welch_tf(y, x[:y.size], 8192)
        snn = median_filter(full.Syy * (1 - full.coh), size=9, mode="nearest")
        sxx = median_filter(full.Sxx, size=9, mode="nearest")
        pred = 2 * snn / (sxx * full.n_avg)
        sel = (np.abs(full.f) > 15e3) & (np.abs(full.f) < 400e3)
        meds.append(float(np.median((np.abs(a.H - b.H) ** 2 / 2)[sel] / pred[sel])))
    define("halfMedian", f"{np.median(meds):.2f} (range {min(meds):.2f}--{max(meds):.2f})")


def joint_numbers():
    J = load("joint_fits.json")
    if J is None:
        return
    R = J["results"]
    sel = R[SELECTED]
    g = sel["globals"]
    define("Gzero", f"{g['G'][0]:.2f}")
    define("GzeroErr", f"{max(g['G'][1], 0.005):.2f}")
    define("tauFit", f"{g['tau'][0]*1e9:.0f}")
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
    define("alphacAboveHi", f"{100 * (ac / 1.10e-3 - 1):.0f}")
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
    recs = sel["records"]
    gr = J["groups"]
    labels = J["group_labels"]
    vk, scale_p = cathode_voltage()
    define("pfwdScale", f"{scale_p:.2f}")
    rows, ga = [], {}
    for k, lab in enumerate(labels):
        idx = [i for i, x in enumerate(gr) if x == k]
        r0 = recs[idx[0]]
        e_g = sel["free"].get(f"g_A[g{k}]", [r0["g_A"], float("nan")])[1]
        mA_k = float(np.mean([recs[i]["mA"] for i in idx]))
        ga[k] = (mA_k, r0["g_A"], vk(mA_k))
        dfs = sorted(set(round(recs[i]["df"] / 1e3, 1) for i in idx))
        rows.append(f"{lab.replace('10/02', '2 Oct').replace('11/03', '3 Nov')} & {len(idx)} & {vk(mA_k):.0f} & "
                    f"${r0['g_A']:.2f}\\pm{max(e_g, 0.005):.2f}$ & ${r0['alpha']:+.0f}$ & "
                    f"{', '.join(f'${d:+.1f}$' for d in dfs)} \\\\")
    (PAPER / "table_groups.tex").write_text("\n".join(rows) + "\n")
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
    define("ampLoopHigh", f"{np.mean(hiv) * g['G'][0]:.2f}")
    al = [recs[gr.index(k)]["alpha"] for k in range(len(labels))]
    define("alphaSpread", f"{max(al) - min(al):.0f}")
    if "J_wl_group_ac" in R:
        fr = R["J_wl_group_ac"]["records"]
        alf = [fr[gr.index(k)]["alpha"] for k in range(len(labels))]
        define("alphaSpreadFree", f"{max(alf) - min(alf):.0f}")
    # loop phase against PHASE.C at 22 mA and in the 3 Nov scan
    for key, sel_fn in (("Low", lambda x: x["mA"] < 30 and x["label"].startswith("10/02 09")),
                        ("Nov", lambda x: x["label"].startswith("11/03") and x["mA"] > 400 and x["counts_db"] == 1.3)):
        xs = [x["phase_c"] for x in recs if sel_fn(x)]
        ys = [x["theta"] for x in recs if sel_fn(x)]
        if len(set(xs)) > 1:
            b = np.polyfit(xs, ys, 1)[0]
            define(f"thetaSlope{key}", f"{-b:.2f}")


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
            define(f"oob{key}DfRms", f"{np.sqrt(np.mean(ef**2)):.0f}")
            define(f"oob{key}Ds", f"{es.mean():+.0f}")
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
    """Where the piecewise-linear profile (with the free optimum added) stays below chi_min + level."""
    p = np.array(sorted(list(map(tuple, pts)) + [(opt, chi_min)]))
    x = np.linspace(p[0, 0], p[-1, 0], 4001)
    y = np.interp(x, p[:, 0], p[:, 1]) - chi_min
    inside = x[y <= level]
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
        rows = C[t][SELECTED]
        define(f"cv{key}In", f"{np.mean([x['insample'] for x in rows]):.2f}")


def main():
    gain_tracking()
    klystron_operating_point()
    noise()
    table_data()
    wide_numbers()
    half_split()
    joint_numbers()
    validation_numbers()
    trip_numbers()
    ident_numbers()
    crossval_numbers()
    lines = [f"\\newcommand{{\\{k}}}{{{v}}}" for k, v in sorted(MACROS.items())]
    (PAPER / "numbers.tex").write_text("% generated by code/make_numbers.py\n" + "\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
