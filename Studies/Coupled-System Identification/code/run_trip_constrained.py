"""Closed-loop fits with the klystron constrained by the trip records of 2021 (csi_trips.py).

Phase 1 (merged into joint_fits.json):
  J_wl_group_ac_ktrip   AM/PM fixed at the trip-record value, compression per operating point (selected)
  J_wl_global_ac_ktrip  AM/PM fixed, one compression for every operating point (the station holds the drive at its
                        28 W set point at every current and moves the HVPS voltage instead)
  J_wl_trip_ac          both fixed at the trip-record values: the klystron predicted, not fitted
Phase 2, seeded from the selected solution:
  J_wl_group_ktrip, J_wl_group_ac_ktrip_nobeam, J_wl_group_ac_ktrip_ks   design alpha_c / no beam motion / beam
                        coupling free besides alpha_c (merged into joint_fits.json)
  wl_group_ktrip        the selected structure fitted to the wideband alone, for the out-of-band test of
                        validate_beam_mode.py (merged into wide_fits.json)
Each family is warm-started from related solutions, then the noise angle of each operating point is shifted by
+-90 deg (the H2 term changes sign), the local minimum that the one-dimensional excitation leaves.
usage: python run_trip_constrained.py [--phase 1|2|all] [--workers 15]
"""
from __future__ import annotations

import argparse
import json
import time

import csi_data as cd
import csi_families as fam
from run_global import summarize

PHASE1 = ("J_wl_group_ac_ktrip", "J_wl_global_ac_ktrip", "J_wl_trip_ac")
PHASE2 = ("J_wl_group_ktrip", "J_wl_group_ac_ktrip_nobeam", "J_wl_group_ac_ktrip_ks", "wl_group_ktrip")


def start_from_records(R: dict, recs) -> dict:
    """Starting dictionary from a stored solution (records matched by tag)."""
    by_tag = {s["tag"]: s for s in R["records"]}
    st = [by_tag[r.tag] for r in recs]
    groups, dgroups = fam.group_index(recs), fam.dgroup_index(recs)
    g0 = [s["G"] / 10 ** ((r.counts_db - fam.REF_DB) / 20) for s, r in zip(st, recs)]
    pick = lambda key, idx, k: st[idx.index(k)][key]
    return dict(theta=[s["theta"] for s in st], df=[s["df"] for s in st],
                df_group=[pick("df", dgroups, k) for k in range(max(dgroups) + 1)],
                G=g0, tau=[s["tau"] for s in st], Q_L=[s["Q_L"] for s in st],
                g_A=[pick("g_A", groups, k) for k in range(max(groups) + 1)],
                k_AP=[pick("k_AP", groups, k) for k in range(max(groups) + 1)],
                alpha=[pick("alpha", groups, k) for k in range(max(groups) + 1)],
                mc1r=st[0]["mc1r"], mc2r=st[0]["mc2r"], mc2i=st[0]["mc2i"], alpha_c=st[0].get("alpha_c", 1.18e-3),
                kappa_scale=st[0].get("kappa_scale", 1.0))


def fit_families(names, seeds, recs, workers, t0):
    """seeds: {family: [start dicts]}. Stage 1 from the seeds, stage 2 noise-angle shifts. Returns {family: best}."""
    ng = max(fam.group_index(recs)) + 1
    jobs = [(name, dict(s), {}) for name in names for s in seeds[name]]
    print(f"stage 1: {len(jobs)} jobs", flush=True)
    best = {}
    for out in fam.run_jobs(jobs, workers=workers):
        if out[0] not in best or out[4] < best[out[0]][4]:
            best[out[0]] = out
    print(f"stage 1 done {time.time() - t0:.0f} s: " + ", ".join(f"{k} {v[4] / v[5]:.4f}" for k, v in best.items()), flush=True)
    jobs = []
    for name in names:
        res = fam.rebuild(*best[name][:4], recs)
        st = fam.start_from(res, recs)
        st["kappa_scale"] = res.stations[0].kappa_scale
        for gi in range(ng):
            for da in (-90.0, 90.0):
                al = list(st["alpha"])
                al[gi] += da
                jobs.append((name, dict(st, alpha=al), {}))
    print(f"stage 2: {len(jobs)} jobs", flush=True)
    for out in fam.run_jobs(jobs, workers=workers):
        if out[4] < best[out[0]][4] - 0.5:
            best[out[0]] = out
    print(f"stage 2 done {time.time() - t0:.0f} s: " + ", ".join(f"{k} {v[4] / v[5]:.4f}" for k, v in best.items()), flush=True)
    return best


def store(best, names, recs, tag, log):
    path = cd.RESULTS / f"{tag}.json"
    J = json.loads(path.read_text())
    for name in names:
        res = fam.rebuild(*best[name][:4], recs)
        J["results"][name] = summarize(name, res, recs)
        J["results"][name]["start"] = best[name][1]
        txt = (f"\n== {name}: chi2 {res.chi2:.0f} dof {res.dof} chi2r {res.chi2_red:.4f} AIC {res.aic:.0f} BIC {res.bic:.0f}"
               f" n_free {res.fit.n_free}\n" + fam.table(res, recs))
        for n_, (v, e) in J["results"][name]["globals"].items():
            txt += f"\n   {n_}: {v:.5g} +- {e:.2g}"
        print(txt, flush=True)
        log.append(txt)
    path.write_text(json.dumps(J, indent=1, default=float))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--phase", default="all", choices=("1", "2", "all"))
    ap.add_argument("--workers", type=int, default=15)
    a = ap.parse_args()
    t0 = time.time()
    recs = fam.select()
    logp = cd.RESULTS / "trip_constrained.log"
    log = logp.read_text().splitlines() if (a.phase == "2" and logp.exists()) else []
    log.append(f"trip-record klystron (csi_trips.py): g_A {fam.G_TRIP}, k_AP {fam.K_TRIP}")
    print(log[-1], flush=True)
    if a.phase in ("1", "all"):
        J = json.loads((cd.RESULTS / "joint_fits.json").read_text())["results"]
        base = {k: start_from_records(J[k], recs) for k in ("J_wl_group_ac_kap0", "J_wl_group_ac", "J_wl_global_ac")}
        s0 = base["J_wl_group_ac_kap0"]
        seeds = {name: list(base.values()) + [dict(s0, alpha=[x + 45.0 for x in s0["alpha"]])] for name in PHASE1}
        store(fit_families(PHASE1, seeds, recs, a.workers, t0), PHASE1, recs, "joint_fits", log)
    if a.phase in ("2", "all"):
        J = json.loads((cd.RESULTS / "joint_fits.json").read_text())["results"]
        W = json.loads((cd.RESULTS / "wide_fits.json").read_text())["results"]
        sel = start_from_records(J["J_wl_group_ac_ktrip"], recs)
        shift = lambda s, d: dict(s, alpha=[x + d for x in s["alpha"]])
        seeds = {"J_wl_group_ktrip": [sel, start_from_records(J["J_wl_group"], recs), shift(sel, 45.0)],
                 "J_wl_group_ac_ktrip_nobeam": [sel, start_from_records(J["J_wl_group_ac_nobeam"], recs), shift(sel, 45.0)],
                 "J_wl_group_ac_ktrip_ks": [dict(sel, kappa_scale=k, alpha_c=ac)
                                            for ac, k in ((sel["alpha_c"], 1.0), (1.18e-3, 1.2), (1.6e-3, 0.8))],
                 "wl_group_ktrip": [start_from_records(W["wl_group"], recs), dict(sel, alpha_c=1.18e-3),
                                    shift(start_from_records(W["wl_group"], recs), 45.0)]}
        best = fit_families(PHASE2, seeds, recs, a.workers, t0)
        store(best, PHASE2[:3], recs, "joint_fits", log)
        store(best, PHASE2[3:], recs, "wide_fits", log)
    logp.write_text("\n".join(log) + "\n")
    print(f"done {time.time() - t0:.0f} s", flush=True)


if __name__ == "__main__":
    main()
