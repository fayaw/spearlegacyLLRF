"""Identifiability of the klystron's quadrature asymmetry from one-dimensional closed-loop excitation.

Profile likelihood of g_A (and k_AP) of the 497 mA operating point (3 Nov) for nested data sets, with the selected
model (J_wl_group_ac: joint wideband + beam band, klystron per operating point, synchrotron frequency identified):
  1  one record (3 Nov 17:27, 497 mA, +1.3 dB, PHASE.C -35)
  2  the 3 Nov 497 mA gain/phase scan (7 records)
  3  all 18 records of 2026
At each grid value g_A (or k_AP) of that group is held, every other parameter re-optimised from the final solution
(two starts: AM/PM as fitted and sign-flipped). Delta chi^2 = 1 / 3.84: 68 / 95 % intervals. The Fisher information
J^T J at the optimum gives the normalised condition number of the free parameters.
Writes results/identifiability.json and identifiability.log.
"""
from __future__ import annotations

import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

import csi_data as cd
import csi_families as fam
import csi_fit as cf

FAMILY = "J_wl_group_ac"
G_GRID = [0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.6, 0.8, 1.0]
K_GRID = [-1.0, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 1.0]
TARGET = "11/03 17:27:29"


def subsets():
    recs = fam.select()
    lab = {r.label: r for r in recs}
    return {"one record": [lab[TARGET]],
            "500 mA scan (7)": [r for r in recs if r.date == "20261103" and r.mA > 400],
            "all records (18)": recs}


def full_start(recs):
    J = json.loads((cd.RESULTS / "joint_fits.json").read_text())["results"][FAMILY]
    sol = {r["tag"]: r for r in J["records"]}
    gr, dg = fam.group_index(recs), fam.dgroup_index(recs)
    pick = lambda key, groups, k: float(np.mean([sol[r.tag][key] for r, g in zip(recs, groups) if g == k]))
    return dict(theta=[sol[r.tag]["theta"] for r in recs],
                df_group=[pick("df", dg, k) for k in range(max(dg) + 1)],
                G=sol[recs[0].tag]["G"] / 10 ** ((recs[0].counts_db - fam.REF_DB) / 20),
                tau=sol[recs[0].tag]["tau"], Q_L=sol[recs[0].tag]["Q_L"],
                g_A=[pick("g_A", gr, k) for k in range(max(gr) + 1)],
                k_AP=[pick("k_AP", gr, k) for k in range(max(gr) + 1)],
                alpha=[pick("alpha", gr, k) for k in range(max(gr) + 1)],
                mc1r=sol[recs[0].tag]["mc1r"], mc2r=sol[recs[0].tag]["mc2r"], mc2i=sol[recs[0].tag]["mc2i"],
                alpha_c=sol[recs[0].tag]["alpha_c"])


def target_group(recs):
    gr = fam.group_index(recs)
    return gr[[r.label for r in recs].index(TARGET)]


def job(args):
    name, which, value, flip = args
    os.environ.setdefault("OMP_NUM_THREADS", "1")
    recs = subsets()[name]
    specs = fam.joint_specs(recs)
    st = full_start(recs)
    tg = target_group(recs)
    if flip:
        st["k_AP"] = [-k for k in st["k_AP"]]
    fit = fam.build(recs, specs, fam.FAMILIES[FAMILY], st)
    if which is not None:
        # hold the target group's value: set it in the base stations and remove it from the free layout
        gr = fam.group_index(recs)
        fit.base = [b.with_(**{which: value}) if g == tg else b for b, g in zip(fit.base, gr)]
        fit.__post_init__()
        fit._layout = [(p, idx) for p, idx in fit._layout if not (p.name == which and idx == ("g", tg))]
    res = cf.run(fit, max_nfev=800)
    out = dict(name=name, which=which, value=value, flip=flip, chi2=res.chi2, dof=res.dof,
               g_A=res.stations[[r.label for r in recs].index(TARGET)].g_A,
               k_AP=res.stations[[r.label for r in recs].index(TARGET)].k_AP)
    if which is None:
        J = res.jac
        F = J.T @ J
        d = np.sqrt(np.diag(F))
        w = np.linalg.eigvalsh(F / np.outer(d, d))
        out["cond"] = float(w.max() / max(w.min(), 1e-300))
        cov = np.linalg.pinv(F) * max(res.chi2 / res.dof, 1.0)
        names = fit.names()
        out["sd"] = {n: float(np.sqrt(max(cov[i, i], 0)) * fit._layout[i][0].scale) for i, n in enumerate(names)
                     if n.split("[")[0] in ("G", "tau", "Q_L", "g_A", "k_AP", "alpha", "alpha_c")}
    return out


def main():
    jobs = []
    for name in subsets():
        big = name.startswith("all")
        jobs += [(name, None, None, False), (name, None, None, True)]
        jobs += [(name, "g_A", g, f) for g in G_GRID for f in ((False,) if big else (False, True))]
        kg = [-1.0, -0.6, -0.3, 0.0, 0.3, 0.6, 1.0] if big else K_GRID
        jobs += [(name, "k_AP", k, f) for k in kg for f in ((False,) if big else (False, True))]
    # the slow (18-record) jobs first
    jobs.sort(key=lambda j: 0 if j[0].startswith("all") else 1)
    with ProcessPoolExecutor(max_workers=15) as ex:
        res = list(ex.map(job, jobs))
    out, log = {}, []
    for name in subsets():
        free = min([r for r in res if r["name"] == name and r["which"] is None], key=lambda r: r["chi2"])
        prof = {}
        for which in ("g_A", "k_AP"):
            vals = sorted(set(r["value"] for r in res if r["name"] == name and r["which"] == which))
            pts = []
            for v in vals:
                best = min([r for r in res if r["name"] == name and r["which"] == which and r["value"] == v],
                           key=lambda r: r["chi2"])
                pts.append([v, best["chi2"]])
            prof[which] = pts
        chi_min = min([free["chi2"]] + [p[1] for w in prof.values() for p in w])
        txt = (f"== {name}: free optimum g_A {free['g_A']:.3f} k_AP {free['k_AP']:+.3f}, chi2r {free['chi2']/free['dof']:.4f},"
               f" normalised Fisher condition {free['cond']:.3g}; sd " + ", ".join(f"{k} {v:.3g}" for k, v in free['sd'].items()
                                                                              if 'g' in k or 'k_AP' in k)
               + "\n   g_A profile: " + " ".join(f"{v:.2f}:{c - chi_min:.1f}" for v, c in prof["g_A"])
               + "\n   k_AP profile: " + " ".join(f"{v:+.1f}:{c - chi_min:.1f}" for v, c in prof["k_AP"]))
        print(txt, flush=True)
        log.append(txt)
        out[name] = dict(free=free, chi_min=chi_min, profile=prof)
    (cd.RESULTS / "identifiability.json").write_text(json.dumps(out, indent=1, default=float))
    (cd.RESULTS / "identifiability.log").write_text("\n".join(log))


if __name__ == "__main__":
    sys.exit(main())
