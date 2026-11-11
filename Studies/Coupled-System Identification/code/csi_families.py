"""Model families for the multi-condition (global) fits, with explicit parameter scopes, run in parallel.

Scopes of each parameter class:
  hardware   G (at COUNTS.A = 0.9 dB, scaled to each record by 10^((COUNTS.A - 0.9)/20): gain tracking holds the
             forward-path gain constant), tau, Q_L, measurement chain: 'global', or 'record' (effective values)
  detuning   df: 'record', or 'dgroup' (records at one current taken within minutes, tuners holding the load angle)
  klystron   g_A, k_AP: None (linear), 'global', or 'group' (one operating point = date and current)
  noise      alpha: per operating-point group (it depends on the klystron insertion phase, not on the loop settings)
  loop phase theta: always per record (PHASE.C steps and the drifting frequency-offset tracking)

Families of the paper:
  E1  lin_eff     hardware per record                      complex-linear, effective parameters
  E0  lin_shared  hardware global                          complex-linear, one station
  E3  spread      E0 + detuning spread per dgroup          unequal cavity detunings
  E4a wl_global   E0 + klystron global                     compressed klystron, one operating point
  E4  wl_group    E0 + klystron per group                  compressed klystron per operating point (selected)
"""
from __future__ import annotations

import json
import math
import os
from concurrent.futures import ProcessPoolExecutor

import numpy as np

import csi_data as cd
import csi_fit as cf
import csi_model as cm

REF_DB = 0.9


def _trip_klystron() -> tuple[float, float]:
    """(g_A, k_AP) of the present klystron measured in the trip records of 2021 (csi_trips.py), to two decimals."""
    p = cd.RESULTS / "trip_klystron.json"
    if not p.exists():
        return 0.40, -0.10
    s = json.loads(p.read_text())["summary"]
    return round(s["g_A"][0], 2), round(s["k_AP"][0], 2)


G_TRIP, K_TRIP = _trip_klystron()

FAMILIES = {
    "lin_eff": dict(hw="record", df="dgroup", kly=None, chain=True),
    "lin_shared": dict(hw="global", df="dgroup", kly=None, chain=True),
    "spread": dict(hw="global", df="dgroup", kly=None, chain=True, spread=True),
    "wl_global": dict(hw="global", df="dgroup", kly="global", chain=True),
    "wl_group": dict(hw="global", df="dgroup", kly="group", chain=True),
    "wl_group_kap0": dict(hw="global", df="dgroup", kly="group", chain=True, kap0=True),
    "wl_group_nobeam": dict(hw="global", df="dgroup", kly="group", chain=True, beam=False),
    "wl_group_dfrec": dict(hw="global", df="record", kly="group", chain=True),
    "lin_shared_nochain": dict(hw="global", df="dgroup", kly=None, chain=False),
    "wl_group_nochain": dict(hw="global", df="dgroup", kly="group", chain=False),
    # joint wideband + beam-band families; '_ac': momentum compaction (synchrotron frequency) identified
    "J_lin_eff": dict(hw="record", df="dgroup", kly=None, chain=True, joint=True),
    "J_lin_eff_ac": dict(hw="record", df="dgroup", kly=None, chain=True, joint=True, alpha_c=True),
    "J_lin_shared_ac": dict(hw="global", df="dgroup", kly=None, chain=True, joint=True, alpha_c=True),
    "J_spread_ac": dict(hw="global", df="dgroup", kly=None, chain=True, joint=True, alpha_c=True, spread=True),
    "J_wl_global_ac": dict(hw="global", df="dgroup", kly="global", chain=True, joint=True, alpha_c=True),
    "J_wl_group": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True),
    "J_wl_group_ac": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True, alpha_c=True),
    "J_wl_group_ac_kap0": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True, alpha_c=True, kap0=True),
    "J_wl_group_ac_nobeam": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True, alpha_c=True,
                                 beam=False),
    "J_wl_group_ac_ks": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True, alpha_c=True, kscale=True),
    # the klystron constrained by the trip records of 2021: AM/PM fixed, compression per operating point or one value,
    # or both fixed (the klystron predicted, not fitted)
    "J_wl_group_ac_ktrip": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True, alpha_c=True,
                                kap_fixed=K_TRIP),
    "J_wl_global_ac_ktrip": dict(hw="global", df="dgroup", kly="global", chain=True, joint=True, alpha_c=True,
                                 kap_fixed=K_TRIP),
    "J_wl_trip_ac": dict(hw="global", df="dgroup", kly="global", chain=True, joint=True, alpha_c=True, kap_fixed=K_TRIP,
                         gA_fixed=G_TRIP),
    # variants of the selected model (AM/PM from the trip records): design synchrotron focusing, no beam motion,
    # beam coupling free besides alpha_c; and the wideband-only fit for the out-of-band test
    "J_wl_group_ktrip": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True, kap_fixed=K_TRIP),
    "J_wl_group_ac_ktrip_nobeam": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True, alpha_c=True,
                                       kap_fixed=K_TRIP, beam=False),
    "J_wl_group_ac_ktrip_ks": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True, alpha_c=True,
                                   kap_fixed=K_TRIP, kscale=True),
    "wl_group_ktrip": dict(hw="global", df="dgroup", kly="group", chain=True, kap_fixed=K_TRIP),
    # the klystron's amplitude response with a finite bandwidth (one global f_A)
    "J_wl_group_ac_ktrip_fA": dict(hw="global", df="dgroup", kly="group", chain=True, joint=True, alpha_c=True,
                                   kap_fixed=K_TRIP, kly_bw=True),
    "J_lin_eff_fA": dict(hw="record", df="dgroup", kly=None, chain=True, joint=True),
}


def select(include_2025: bool = False, only=None) -> list:
    recs = [r for r in cd.records() if include_2025 or r.date != "20251110"]
    return [r for r in recs if only is None or only(r)]


def group_index(recs) -> list:
    """Operating point: date and current (to 50 mA)."""
    keys = [(r.date, int(round(r.mA / 50.0))) for r in recs]
    uniq = sorted(set(keys))
    return [uniq.index(k) for k in keys]


def dgroup_index(recs) -> list:
    """Detuning group: same date and current, taken within 30 minutes of each other."""
    out, keys = [], []
    for r in recs:
        t = int(r.time[:2]) * 60 + int(r.time[3:5])
        for i, (d, mA, t0) in enumerate(keys):
            if d == r.date and abs(mA - r.mA) < 10 and abs(t - t0) <= 30:
                out.append(i)
                break
        else:
            keys.append((r.date, r.mA, t))
            out.append(len(keys) - 1)
    return out


def group_labels(recs, groups=None) -> list:
    g = group_index(recs) if groups is None else groups
    out = {}
    for r, gi in zip(recs, g):
        out.setdefault(gi, f"{r.date[4:6]}/{r.date[6:]} {r.mA:.0f} mA")
    return [out[k] for k in sorted(out)]


def wide_specs(recs):
    """Loop band only (25-550 kHz), the identification that the out-of-band test of the coupled mode starts from."""
    return [[cf.lpm_spectrum(r, cf.F_SPLIT, cf.F_HI)] for r in recs]


BEAM_BAND = (3e3, 16e3)


def joint_specs(recs):
    """The full band of every record (0.3-550 kHz), in two contiguous regions: loop band 25-550 kHz (index 0) and
    near-carrier band 0.3-25 kHz (index 1), which holds the coupled beam mode."""
    return [[cf.lpm_spectrum(r, cf.F_SPLIT, cf.F_HI), cf.lpm_spectrum(r, cf.F_LO, cf.F_SPLIT)] for r in recs]


def specs_for(recs, fam_name):
    return joint_specs(recs) if FAMILIES[fam_name].get("joint") else wide_specs(recs)


class GainScaled:
    """Picklable 'derived' hook: G of each record = G at COUNTS.A = REF_DB times 10^((COUNTS.A - REF_DB)/20)."""

    def __init__(self, counts_db, scale_g=True):
        self.counts_db, self.scale_g = list(counts_db), scale_g

    def __call__(self, st, i):
        return st.with_(G=st.G * 10 ** ((self.counts_db[i] - REF_DB) / 20)) if self.scale_g else st


def _per(v, n):
    return list(v) if isinstance(v, (list, tuple, np.ndarray)) else [v] * n


def build(recs, specs, fam: dict, start: dict) -> cf.Fit:
    n = len(recs)
    groups, dgroups = group_index(recs), dgroup_index(recs)
    ng, nd = max(groups) + 1, max(dgroups) + 1
    beam = fam.get("beam", True)
    base = [cm.Station(I_b=r.mA / 1e3, beam=beam) for r in recs]
    pars = [cf.Par("theta", _per(start.get("theta", 0.0), n), "record", -180, 180, 5)]
    if fam["df"] == "record":
        pars.append(cf.Par("df", _per(start.get("df", 0.0), n), "record", -90e3, 40e3, 1e3))
    else:
        dfv = start.get("df_group")
        if dfv is None:
            dfv = [-36e3 * np.mean([r.mA for r, g in zip(recs, dgroups) if g == k]) / 500 for k in range(nd)]
        pars.append(cf.Par("df", list(dfv), "group", -90e3, 40e3, 1e3, groups=dgroups))
    hw = fam["hw"]
    for name, v0, lo, hi, sc in (("G", 1.0, 0.05, 6.0, 0.1), ("tau", 630e-9, 400e-9, 900e-9, 10e-9),
                                 ("Q_L", 6800.0, 2000.0, 15000.0, 200.0)):
        v = start.get(name, v0)
        pars.append(cf.Par(name, _per(v, n) if hw == "record" else (v if np.isscalar(v) else float(np.mean(v))),
                           "record" if hw == "record" else "global", lo, hi, sc))
    if fam.get("spread"):
        pars.append(cf.Par("df_spread", _per(start.get("df_spread", 5e3), nd), "group", 0.0, 80e3, 1e3, groups=dgroups))
    if fam.get("kly"):
        scope = fam["kly"]
        for name, v0, lo, hi in (("g_A", 0.4, 0.0, 2.0), ("k_AP", 0.3, -3.0, 3.0)):
            v = start.get(name, v0)
            if scope == "group":
                pars.append(cf.Par(name, _per(v, ng), "group", lo, hi, 0.1, groups=groups))
            else:
                pars.append(cf.Par(name, v if np.isscalar(v) else float(np.mean(v)), "global", lo, hi, 0.1))
        if fam.get("kap0"):
            pars[-1].value, pars[-1].fixed, pars[-1].scope = 0.0, True, "global"
        for p in pars[-2:]:
            v = fam.get({"g_A": "gA_fixed", "k_AP": "kap_fixed"}[p.name])
            if v is not None:
                p.value, p.fixed, p.scope = float(v), True, "global"
        pars.append(cf.Par("alpha", _per(start.get("alpha", 0.0), ng), "group", -360.0, 360.0, 10.0, groups=groups))
    if fam.get("chain", True):
        for name in ("mc1r", "mc2r", "mc2i"):
            pars.append(cf.Par(name, start.get(name, 0.0), lo=-2, hi=2, scale=0.05))
    if fam.get("alpha_c"):
        pars.append(cf.Par("alpha_c", start.get("alpha_c", 1.30e-3), lo=0.8e-3, hi=2.2e-3, scale=0.05e-3))
    if fam.get("kscale"):
        pars.append(cf.Par("kappa_scale", start.get("kappa_scale", 1.0), lo=0.3, hi=3.0, scale=0.05))
    if fam.get("kly_bw"):
        pars.append(cf.Par("f_A", start.get("f_A", 1e6), lo=5e4, hi=5e7, scale=1e5))
    return cf.Fit(specs, base, pars, derived=GainScaled([r.counts_db for r in recs], scale_g=(hw != "record")))


def start_from(res: cf.Result, recs) -> dict:
    """Starting dictionary that reproduces a fitted solution (for warm starts and refinements)."""
    st = res.stations
    groups, dgroups = group_index(recs), dgroup_index(recs)
    g0 = [s.G / 10 ** ((r.counts_db - REF_DB) / 20) for s, r in zip(st, recs)]
    if any(p.name == "G" and p.scope == "record" for p in res.fit.pars):
        g0 = [s.G for s in st]
    return dict(theta=[s.theta for s in st], df=[s.df for s in st],
                df_group=[st[dgroups.index(k)].df for k in range(max(dgroups) + 1)],
                G=g0, tau=[s.tau for s in st], Q_L=[s.Q_L for s in st],
                g_A=[st[groups.index(k)].g_A for k in range(max(groups) + 1)],
                k_AP=[st[groups.index(k)].k_AP for k in range(max(groups) + 1)],
                alpha=[st[groups.index(k)].alpha for k in range(max(groups) + 1)],
                df_spread=[st[dgroups.index(k)].df_spread for k in range(max(dgroups) + 1)],
                mc1r=st[0].mc1r, mc2r=st[0].mc2r, mc2i=st[0].mc2i, alpha_c=st[0].alpha_c)


def apply_fixed(fit: cf.Fit, fixed: dict) -> cf.Fit:
    for p in fit.pars:
        if p.name in fixed:
            p.value, p.fixed = fixed[p.name], True
            if not isinstance(fixed[p.name], (list, tuple, np.ndarray)):
                p.scope = "global"
    fit.__post_init__()
    return fit


# ------------------------------------------------------------------ parallel execution
_WORK = {}


def _init(selector_args):
    os.environ.setdefault("OMP_NUM_THREADS", "1")
    recs = select(**selector_args)
    _WORK["recs"] = recs
    _WORK["specs"] = {False: wide_specs(recs), True: joint_specs(recs)}


def _job(args):
    fam_name, start, fixed = args
    recs = _WORK["recs"]
    specs = _WORK["specs"][bool(FAMILIES[fam_name].get("joint"))]
    fit = apply_fixed(build(recs, specs, FAMILIES[fam_name], start), fixed)
    res = cf.run(fit, max_nfev=600)
    return fam_name, start, fixed, res.q, res.chi2, res.dof


def run_jobs(jobs, selector_args=None, workers=14):
    """jobs: list of (family, start dict, fixed dict). Returns list of (family, start, fixed, q, chi2, dof)."""
    selector_args = selector_args or {}
    with ProcessPoolExecutor(max_workers=min(workers, len(jobs)), initializer=_init, initargs=(selector_args,)) as ex:
        return list(ex.map(_job, jobs))


def rebuild(fam_name, start, fixed, q, recs, specs=None) -> cf.Result:
    """Recreate the Result of a parallel job in the parent process (Jacobian recomputed for the covariance)."""
    from scipy.optimize._numdiff import approx_derivative
    specs = specs_for(recs, fam_name) if specs is None else specs
    fit = apply_fixed(build(recs, specs, FAMILIES[fam_name], start), fixed)
    q = np.asarray(q)
    res = fit.residuals(q)
    lo, hi = fit.bounds()
    J = approx_derivative(fit.residuals, q, method="2-point", sparsity=fit.sparsity(), bounds=(lo, hi))
    J = J.toarray() if hasattr(J, "toarray") else J
    chi2 = float(np.sum(res ** 2))
    dof = fit.n_data - fit.n_free
    cov = np.linalg.pinv(J.T @ J) * max(chi2 / dof, 1.0)
    return cf.Result(fit, q, chi2, dof, cov, fit.stations(q), J)


def table(res: cf.Result, recs) -> str:
    lines = []
    for r, st, e in zip(recs, res.stations, res.per_record_rms()):
        lines.append(f"  {r.label} {r.mA:4.0f} mA {r.counts_db:+.1f} dB {r.phase_c:+5.0f}: G {st.G:.3f} th {st.theta:+6.1f}"
                     f" tau {st.tau*1e9:4.0f} QL {st.Q_L:5.0f} df {st.df/1e3:+6.1f} spr {st.df_spread/1e3:4.1f}"
                     f" gA {st.g_A:.2f} kAP {st.k_AP:+.2f} al {st.alpha:+7.1f} thg {math.degrees(st.steady()['theta_g']):+5.1f}"
                     f" | rms {e:.2f}")
    return "\n".join(lines)
