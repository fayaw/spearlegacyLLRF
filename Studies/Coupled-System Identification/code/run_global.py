"""Multi-condition fits of the 2026 closed-loop records, every model family, run in parallel.

Stage 1: per-record complex-linear fits give starting loop phases and detunings.
Stage 2: every family from several starts (noise angle, AM/PM sign, loop-phase offset), in parallel.
Stage 3: the widely-linear families refined group by group (noise angle shifted by +-60 and +-120 deg).
Writes results/<tag>.json, <tag>.log.
usage: python run_global.py [--families a,b,...] [--tag wide_fits] [--workers 14]
"""
from __future__ import annotations

import argparse
import json
import math
import time

import numpy as np

import csi_data as cd
import csi_families as fam
import csi_fit as cf
import csi_model as cm


def linear_starts(recs, specs):
    th, df = [], []
    for r, sps in zip(recs, specs):
        pars = [cf.Par("G", 0.6, lo=0.05, hi=5, scale=0.1), cf.Par("theta", 0.0, lo=-90, hi=90, scale=5),
                cf.Par("tau", 650e-9, lo=400e-9, hi=900e-9, scale=10e-9), cf.Par("Q_L", 6000, lo=2000, hi=15000, scale=200),
                cf.Par("df", -36e3 * r.mA / 500, lo=-80e3, hi=40e3, scale=1e3)]
        res = cf.run(cf.Fit([sps], [cm.Station(I_b=r.mA / 1e3)], pars), starts=[{"theta": t} for t in (-30, 0, 30)])
        th.append(res.stations[0].theta)
        df.append(res.stations[0].df)
    return th, df


def summarize(name, res, recs):
    out = dict(family=name, chi2=res.chi2, dof=res.dof, chi2_red=res.chi2_red, aic=res.aic, bic=res.bic,
               n_free=res.fit.n_free, n_data=res.fit.n_data, rms=res.per_record_rms(), records=[], globals={})
    for n in ("G", "tau", "Q_L", "g_A", "k_AP", "mc1r", "mc2r", "mc2i", "alpha_c", "kappa_scale"):
        try:
            v, e = res.value(n)
            out["globals"][n] = [v, e]
        except ValueError:
            pass
    bands = []
    for st, sps in zip(res.stations, res.fit.specs):
        bands.append([float(np.sum(np.abs((cf.model_on(st, sp) - sp.H) / sp.sigma) ** 2)) for sp in sps]
                     + [2 * sp.n for sp in sps])
    out["band_chi2"] = bands
    for r, s in zip(recs, res.stations):
        out["records"].append(dict(tag=r.tag, label=r.label, mA=r.mA, counts_db=r.counts_db, phase_c=r.phase_c,
                                   G=s.G, theta=s.theta, tau=s.tau, Q_L=s.Q_L, df=s.df, df_spread=s.df_spread,
                                   g_A=s.g_A, k_AP=s.k_AP, alpha=s.alpha, beam=s.beam, mc1r=s.mc1r, mc1i=s.mc1i,
                                   mc2r=s.mc2r, mc2i=s.mc2i, alpha_c=s.alpha_c, kappa_scale=s.kappa_scale,
                                   theta_g=math.degrees(s.steady()["theta_g"])))
    names = res.fit.names()
    out["free"] = {n: [float(res.q[i] * res.fit._layout[i][0].scale),
                       float(math.sqrt(max(res.cov[i, i], 0)) * res.fit._layout[i][0].scale)] for i, n in enumerate(names)}
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--families", default=",".join(fam.FAMILIES))
    ap.add_argument("--tag", default="wide_fits")
    ap.add_argument("--workers", type=int, default=14)
    ap.add_argument("--refine", default=None, help="families refined in stage 3 (default: all widely-linear)")
    ap.add_argument("--shifts", default="-120,-60,60,120")
    a = ap.parse_args()
    shifts = [float(x) for x in a.shifts.split(",")]
    t0 = time.time()
    recs = fam.select()
    specs = fam.wide_specs(recs)
    groups, dgroups = fam.group_index(recs), fam.dgroup_index(recs)
    ng, nd = max(groups) + 1, max(dgroups) + 1
    print(f"{len(recs)} records; operating-point groups {fam.group_labels(recs)}; detuning groups {dgroups}", flush=True)
    th0, df0 = linear_starts(recs, specs)
    dfg = [float(np.mean([d for d, g in zip(df0, dgroups) if g == k])) for k in range(nd)]
    print(f"starting values {time.time() - t0:.0f} s", flush=True)
    names = a.families.split(",")
    jobs = []
    for name in names:
        F = fam.FAMILIES[name]
        base = dict(theta=th0, df=df0, df_group=dfg, alpha_c=1.36e-3 if F.get("alpha_c") else 1.18e-3)
        if not F.get("kly"):
            for dth in (0.0, -10.0):
                jobs.append((name, dict(base, theta=[t + dth for t in th0]), {}))
        else:
            hi = [r.mA > 200 for r in recs]
            for a0 in (-90.0, -45.0, 0.0, 45.0):
                for k0 in (-0.4, 0.4):
                    for dth in (0.0, 25.0):
                        jobs.append((name, dict(base, theta=[t + (dth if h else 0.0) for t, h in zip(th0, hi)],
                                                alpha=[a0] * ng, g_A=0.4, k_AP=k0, G=1.2), {}))
    print(f"stage 2: {len(jobs)} jobs", flush=True)
    out = fam.run_jobs(jobs, workers=a.workers)
    best = {}
    for name_, start, fixed, q, chi2, dof in out:
        if name_ not in best or chi2 < best[name_][4]:
            best[name_] = (name_, start, fixed, q, chi2, dof)
    print(f"stage 2 done {time.time() - t0:.0f} s: " + ", ".join(f"{k} {v[4]/v[5]:.4f}" for k, v in best.items()), flush=True)
    refine = names if a.refine is None else a.refine.split(",")
    for it in range(2):
        jobs = []
        for name in names:
            if not fam.FAMILIES[name].get("kly") or name not in refine:
                continue
            res = fam.rebuild(*best[name][:4], recs)
            st = fam.start_from(res, recs)
            for gi in range(ng):
                for da in shifts:
                    al = list(st["alpha"])
                    al[gi] += da
                    for ksign in (1, -1):
                        kap = list(st["k_AP"])
                        if fam.FAMILIES[name]["kly"] == "group" and not fam.FAMILIES[name].get("kap0"):
                            kap[gi] *= ksign
                        elif ksign < 0:
                            continue
                        jobs.append((name, dict(st, alpha=al, k_AP=kap), {}))
        if not jobs:
            break
        print(f"stage 3.{it}: {len(jobs)} jobs", flush=True)
        improved = False
        for name_, start, fixed, q, chi2, dof in fam.run_jobs(jobs, workers=a.workers):
            if chi2 < best[name_][4] - 0.5:
                best[name_] = (name_, start, fixed, q, chi2, dof)
                improved = True
        print(f"stage 3.{it} done {time.time() - t0:.0f} s: " + ", ".join(f"{k} {v[4]/v[5]:.4f}" for k, v in best.items()), flush=True)
        if not improved:
            break
    results, log = {}, []
    for name in names:
        res = fam.rebuild(*best[name][:4], recs)
        results[name] = summarize(name, res, recs)
        results[name]["start"] = best[name][1]
        txt = (f"\n== {name}: chi2 {res.chi2:.0f} dof {res.dof} chi2r {res.chi2_red:.4f} AIC {res.aic:.0f} BIC {res.bic:.0f}"
               f" n_free {res.fit.n_free}\n" + fam.table(res, recs))
        for n_, (v, e) in results[name]["globals"].items():
            txt += f"\n   {n_}: {v:.5g} +- {e:.2g}"
        print(txt, flush=True)
        log.append(txt)
    (cd.RESULTS / f"{a.tag}.json").write_text(json.dumps(dict(groups=groups, dgroups=dgroups,
                                                               group_labels=fam.group_labels(recs), results=results),
                                                          indent=1, default=float))
    (cd.RESULTS / f"{a.tag}.log").write_text("\n".join(log))
    print(f"done {time.time() - t0:.0f} s", flush=True)


if __name__ == "__main__":
    main()
