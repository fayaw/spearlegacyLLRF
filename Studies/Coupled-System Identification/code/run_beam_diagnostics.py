"""Diagnostics after the joint fits: (1) the effective linear model with alpha_c free, warm-started from the
effective model's solution (its first run stopped in a worse local minimum); (2) what the beam band needs:
alpha_c (synchrotron frequency and beam coupling together) against the beam coupling alone (kappa_scale).
Updates results/joint_fits.json (J_lin_eff_ac, J_wl_group_ac_ks) and writes beam_diagnostics.log.
"""
from __future__ import annotations

import json
import math

import numpy as np

import csi_data as cd
import csi_families as fam
import csi_model as cm
from run_global import summarize


def main():
    recs = fam.select()
    J = json.loads((cd.RESULTS / "joint_fits.json").read_text())
    R = J["results"]
    jobs = []
    st_eff = R["J_lin_eff"]["start"]
    eff = {r["tag"]: r for r in R["J_lin_eff"]["records"]}
    base_eff = dict(theta=[eff[r.tag]["theta"] for r in recs], G=[eff[r.tag]["G"] for r in recs],
                    tau=[eff[r.tag]["tau"] for r in recs], Q_L=[eff[r.tag]["Q_L"] for r in recs],
                    df_group=st_eff.get("df_group"), mc1r=eff[recs[0].tag]["mc1r"], mc2r=eff[recs[0].tag]["mc2r"],
                    mc2i=eff[recs[0].tag]["mc2i"])
    dg = fam.dgroup_index(recs)
    base_eff["df_group"] = [float(np.mean([eff[r.tag]["df"] for r, g in zip(recs, dg) if g == k])) for k in range(max(dg) + 1)]
    for ac in (1.18e-3, 1.30e-3, 1.42e-3):
        jobs.append(("J_lin_eff_ac", dict(base_eff, alpha_c=ac), {}))
    sel = R["J_wl_group_ac"]
    # warm start for the coupling diagnostic from the selected solution
    s = {r["tag"]: r for r in sel["records"]}
    gr = fam.group_index(recs)
    mean = lambda key, groups, k: float(np.mean([s[r.tag][key] for r, g in zip(recs, groups) if g == k]))
    st_sel = dict(theta=[s[r.tag]["theta"] for r in recs], df_group=[mean("df", dg, k) for k in range(max(dg) + 1)],
                  G=s[recs[0].tag]["G"] / 10 ** ((recs[0].counts_db - fam.REF_DB) / 20), tau=s[recs[0].tag]["tau"],
                  Q_L=s[recs[0].tag]["Q_L"], g_A=[mean("g_A", gr, k) for k in range(max(gr) + 1)],
                  k_AP=[mean("k_AP", gr, k) for k in range(max(gr) + 1)],
                  alpha=[mean("alpha", gr, k) for k in range(max(gr) + 1)], mc1r=s[recs[0].tag]["mc1r"],
                  mc2r=s[recs[0].tag]["mc2r"], mc2i=s[recs[0].tag]["mc2i"])
    for ac, ks in ((1.416e-3, 1.0), (1.18e-3, 1.2), (1.18e-3, 1.0), (1.6e-3, 0.8)):
        jobs.append(("J_wl_group_ac_ks", dict(st_sel, alpha_c=ac, kappa_scale=ks), {}))
    out = fam.run_jobs(jobs, workers=len(jobs))
    log = []
    best = {}
    for name, start, fixed, q, chi2, dof in out:
        log.append(f"{name}: start alpha_c {start['alpha_c']*1e3:.3f}e-3 kappa_scale {start.get('kappa_scale', 1):.2f}"
                   f" -> chi2r {chi2/dof:.4f}")
        if name not in best or chi2 < best[name][4]:
            best[name] = (name, start, fixed, q, chi2, dof)
    for name, b in best.items():
        res = fam.rebuild(*b[:4], recs)
        R[name] = summarize(name, res, recs)
        R[name]["start"] = b[1]
        st0 = res.stations[0]
        ws = st0.w_s / 2 / math.pi
        log.append(f"== {name}: chi2r {res.chi2_red:.4f} AIC {res.aic:.0f}; alpha_c {st0.alpha_c*1e3:.4f}e-3"
                   f" kappa_scale {st0.kappa_scale:.3f}; f_s {ws/1e3:.3f} kHz; total coupling scale"
                   f" {st0.kappa_scale * st0.alpha_c / cm.ALPHA_C:.3f}")
    print("\n".join(log))
    (cd.RESULTS / "joint_fits.json").write_text(json.dumps(J, indent=1, default=float))
    (cd.RESULTS / "beam_diagnostics.log").write_text("\n".join(log))


if __name__ == "__main__":
    main()
