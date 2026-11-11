"""Refit every model family used in the paper on the full-band LPM estimates (csi_lpm), warm-started.

Seeds are the solutions of the earlier multi-start searches (run_global.py, run_trip_constrained.py) on the same
records, kept in results/seeds/{wide,joint}_fits.json. Stage 1 refits each family from its seed (and, where the AM/PM
conversion is free, from the seed with its sign flipped); stage 2 shifts the noise angle of each operating point by
+-90 deg, the local minimum that a one-dimensional excitation leaves, and keeps any improvement.
Writes results/wide_fits.json, results/joint_fits.json and results/refit.log.
usage: python run_refit.py [--workers 15]
"""
from __future__ import annotations

import argparse
import json
import time

import csi_data as cd
import csi_families as fam
from run_global import summarize

JOINT = ["J_lin_eff", "J_lin_eff_ac", "J_lin_shared_ac", "J_spread_ac", "J_wl_global_ac", "J_wl_group_ac",
         "J_wl_group_ac_kap0", "J_wl_group_ac_ktrip", "J_wl_global_ac_ktrip", "J_wl_trip_ac", "J_wl_group_ktrip",
         "J_wl_group_ac_ktrip_nobeam", "J_wl_group_ac_ktrip_ks"]
WIDE = ["lin_eff", "lin_shared", "wl_group_ktrip"]


def seed(R: dict, recs, fam_name: str) -> dict:
    """Starting dictionary from a stored solution (records matched by tag)."""
    by_tag = {s["tag"]: s for s in R["records"]}
    st = [by_tag[r.tag] for r in recs]
    groups, dgroups = fam.group_index(recs), fam.dgroup_index(recs)
    per_record = fam.FAMILIES[fam_name]["hw"] == "record"
    g0 = [s["G"] if per_record else s["G"] / 10 ** ((r.counts_db - fam.REF_DB) / 20) for s, r in zip(st, recs)]
    pick = lambda key, idx, k: st[idx.index(k)].get(key, 0.0)
    return dict(theta=[s["theta"] for s in st], df=[s["df"] for s in st],
                df_group=[pick("df", dgroups, k) for k in range(max(dgroups) + 1)],
                G=g0 if per_record else g0[0], tau=[s["tau"] for s in st], Q_L=[s["Q_L"] for s in st],
                g_A=[pick("g_A", groups, k) for k in range(max(groups) + 1)],
                k_AP=[pick("k_AP", groups, k) for k in range(max(groups) + 1)],
                alpha=[pick("alpha", groups, k) for k in range(max(groups) + 1)],
                df_spread=[pick("df_spread", dgroups, k) for k in range(max(dgroups) + 1)],
                mc1r=st[0]["mc1r"], mc2r=st[0]["mc2r"], mc2i=st[0]["mc2i"],
                alpha_c=st[0].get("alpha_c", 1.18e-3), kappa_scale=st[0].get("kappa_scale", 1.0))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--workers", type=int, default=15)
    a = ap.parse_args()
    t0 = time.time()
    recs = fam.select()
    ng = max(fam.group_index(recs)) + 1
    seeds = {}
    for tag, names in (("wide_fits", WIDE), ("joint_fits", JOINT)):
        S = json.loads((cd.RESULTS / "seeds" / f"{tag}.json").read_text())["results"]
        for n in names:
            seeds[n] = seed(S[n], recs, n)
    jobs = []
    for n, s in seeds.items():
        jobs.append((n, s, {}))
        F = fam.FAMILIES[n]
        if F.get("kly") and F.get("kap_fixed") is None and not F.get("kap0"):
            jobs.append((n, dict(s, k_AP=[-k for k in s["k_AP"]]), {}))
    print(f"stage 1: {len(jobs)} jobs", flush=True)
    best = {}
    for out in fam.run_jobs(jobs, workers=a.workers):
        if out[0] not in best or out[4] < best[out[0]][4]:
            best[out[0]] = out
    print(f"stage 1 done {time.time() - t0:.0f} s: " + ", ".join(f"{k} {v[4] / v[5]:.4f}" for k, v in best.items()),
          flush=True)
    jobs = []
    for n in seeds:
        if not fam.FAMILIES[n].get("kly"):
            continue
        st = fam.start_from(fam.rebuild(*best[n][:4], recs), recs)
        st["kappa_scale"] = best[n][1].get("kappa_scale", 1.0)
        for gi in range(ng):
            for da in (-90.0, 90.0):
                al = list(st["alpha"])
                al[gi] += da
                jobs.append((n, dict(st, alpha=al), {}))
    print(f"stage 2: {len(jobs)} jobs", flush=True)
    for out in fam.run_jobs(jobs, workers=a.workers):
        if out[4] < best[out[0]][4] - 0.5:
            best[out[0]] = out
    print(f"stage 2 done {time.time() - t0:.0f} s: " + ", ".join(f"{k} {v[4] / v[5]:.4f}" for k, v in best.items()),
          flush=True)
    log = []
    for tag, names in (("wide_fits", WIDE), ("joint_fits", JOINT)):
        results = {}
        for n in names:
            res = fam.rebuild(*best[n][:4], recs)
            results[n] = summarize(n, res, recs)
            results[n]["start"] = best[n][1]
            txt = (f"\n== {n}: chi2 {res.chi2:.0f} dof {res.dof} chi2r {res.chi2_red:.4f} AIC {res.aic:.0f} BIC {res.bic:.0f}"
                   f" n_free {res.fit.n_free}\n" + fam.table(res, recs))
            for k, (v, e) in results[n]["globals"].items():
                txt += f"\n   {k}: {v:.5g} +- {e:.2g}"
            print(txt, flush=True)
            log.append(txt)
        (cd.RESULTS / f"{tag}.json").write_text(json.dumps(dict(groups=fam.group_index(recs), dgroups=fam.dgroup_index(recs),
                                                               group_labels=fam.group_labels(recs), results=results),
                                                          indent=1, default=float))
    (cd.RESULTS / "refit.log").write_text("\n".join(log) + "\n")
    print(f"done {time.time() - t0:.0f} s", flush=True)


if __name__ == "__main__":
    main()
