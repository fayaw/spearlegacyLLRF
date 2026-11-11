"""Two checks of the selected model's klystron and cavity assumptions, every other parameter refitted each time:
  * a finite bandwidth f_A of the klystron's amplitude response (K's amplitude path through w_A/(s + w_A)), held at
    each value of a grid -- the trip records show g_A falling above 200 kHz;
  * unequal loaded Q of the four cavities, as measured from their reflection without beam (make_numbers.station_cavities).
Writes results/model_checks.json and model_checks.log.
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

import csi_data as cd
import csi_families as fam
import csi_fit as cf
from run_refit import seed

SELECTED = "J_wl_group_ac_ktrip"
F_GRID = [0.25e6, 0.4e6, 0.6e6, 0.9e6, 1.4e6, 2.5e6, 5e6]
EDGES = [cf.F_LO, cf.F_SPLIT, cf.F_HI]


def q_measured():
    from make_numbers import station_cavities
    q = station_cavities()["q_l"]
    return tuple(float(x) for x in q / np.mean(q))


def job(args):
    label, q_rel, f_a = args
    os.environ.setdefault("OMP_NUM_THREADS", "1")
    recs = fam.select()
    J = json.loads((cd.RESULTS / "joint_fits.json").read_text())["results"]
    fit = fam.build(recs, fam.joint_specs(recs), fam.FAMILIES[SELECTED], seed(J[SELECTED], recs, SELECTED))
    fit.base = [b.with_(q_rel=q_rel, f_A=f_a) for b in fit.base]
    fit.__post_init__()
    res = cf.run(fit, max_nfev=200)
    acc = np.zeros((len(EDGES) - 1, 2))
    for st, sps in zip(res.stations, fit.specs):
        for sp in sps:
            r2 = np.abs((cf.model_on(st, sp) - sp.H) / sp.sigma) ** 2
            for b in range(len(EDGES) - 1):
                s = (np.abs(sp.f) >= EDGES[b]) & (np.abs(sp.f) < EDGES[b + 1])
                acc[b] += [r2[s].sum(), 2 * s.sum()]
    return dict(label=label, q_rel=list(q_rel), f_A=f_a, chi2=res.chi2, dof=res.dof, Q_L=res.value("Q_L")[0],
                alpha_c=res.value("alpha_c")[0], band_chi2_red=(acc[:, 0] / acc[:, 1]).tolist())


if __name__ == "__main__":
    qm = q_measured()
    cases = [("reference", (1.0,) * 4, 0.0), ("unequal Q", qm, 0.0)] + [(f"f_A {f:.0f}", (1.0,) * 4, f) for f in F_GRID]
    with ProcessPoolExecutor(max_workers=len(cases)) as ex:
        out = list(ex.map(job, cases))
    log = []
    for o in out:
        log.append(f"{o['label']:14s}: chi2 {o['chi2']:.0f} chi2r {o['chi2']/o['dof']:.4f} Q_L {o['Q_L']:.0f} alpha_c "
                   f"{o['alpha_c']*1e3:.3f} | near {o['band_chi2_red'][0]:.2f} loop {o['band_chi2_red'][1]:.2f}")
        print(log[-1], flush=True)
    (cd.RESULTS / "model_checks.json").write_text(json.dumps(out, indent=1))
    (cd.RESULTS / "model_checks.log").write_text("\n".join(log) + "\n")
    sys.exit(0)
