"""Joint fit of the wideband (15-400 kHz) and beam-mode band (3-16 kHz) responses, one operating-point group.

Exploration of whether one physical model explains both bands, and which parameters the beam band needs:
the loop-phase / AM-PM branch, the momentum compaction (synchrotron frequency), or neither.
usage: python explore_joint.py [group] [--alpha-c-free]
"""
from __future__ import annotations

import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

import csi_beam as cb
import csi_data as cd
import csi_families as fam
import csi_fit as cf
import csi_model as cm

SELECT = {
    "nov500": lambda r: r.date == "20261103" and r.mA > 400,
    "oct_high": lambda r: r.date == "20261002" and r.mA > 300,
    "all_beam": lambda r: r.mA > 200,
}


def specs_for(recs):
    return [[cf.spectrum(r, 8192, 15e3, 400e3), cb.beam_spectrum(r)] for r in recs]


def band_chi2(res):
    out = []
    for st, sps in zip(res.stations, res.fit.specs):
        out.append([float(np.mean(np.abs((cf.model_on(st, sp) - sp.H) / sp.sigma) ** 2) / 2) for sp in sps])
    return np.array(out)


def job(args):
    group, start, alpha_c_free, joint = args
    os.environ.setdefault("OMP_NUM_THREADS", "1")
    recs = fam.select(only=SELECT[group])
    specs = specs_for(recs) if joint else [[s[0]] for s in specs_for(recs)]
    fit = fam.build(recs, specs, fam.FAMILIES["wl_group"], start)
    if alpha_c_free:
        fit.pars.append(cf.Par("alpha_c", 1.18e-3, lo=0.8e-3, hi=2.0e-3, scale=0.05e-3))
        fit.__post_init__()
    res = cf.run(fit, max_nfev=800)
    return start, alpha_c_free, joint, res.q, res.chi2, res.dof


def main():
    group = sys.argv[1] if len(sys.argv) > 1 else "nov500"
    quick = "--quick" in sys.argv
    recs = fam.select(only=SELECT[group])
    n = len(recs)
    ng = max(fam.group_index(recs)) + 1
    jobs = []
    for joint in (False, True):
        for acf in ((False, True) if joint else (False,)):
            for th0 in ((0.0, 40.0) if quick else (0.0, 25.0, 50.0)):
                for k0 in (-0.5, 0.5):
                    for a0 in ((-30.0, 30.0) if quick else (-60.0, 0.0, 45.0)):
                        jobs.append((group, dict(theta=[th0] * n, alpha=[a0] * ng, k_AP=[k0] * ng, g_A=[0.35] * ng,
                                                 G=1.3), acf, joint))
    with ProcessPoolExecutor(max_workers=15) as ex:
        out = list(ex.map(job, jobs))
    specs_j = specs_for(recs)
    for joint in (False, True):
        for acf in ((False, True) if joint else (False,)):
            sel = sorted([o for o in out if o[2] == joint and o[1] == acf], key=lambda o: o[4])
            print(f"\n=== {group}: {'joint wide+beam' if joint else 'wideband only'}, alpha_c {'free' if acf else 'fixed'}:"
                  f" best chi2r {sel[0][4]/sel[0][5]:.4f}; distinct optima:")
            seen = []
            for o in sel[:12]:
                fit = fam.build(recs, specs_j if joint else [[s[0]] for s in specs_j], fam.FAMILIES["wl_group"], o[0])
                if acf:
                    fit.pars.append(cf.Par("alpha_c", 1.18e-3, lo=0.8e-3, hi=2.0e-3, scale=0.05e-3))
                    fit.__post_init__()
                st = fit.stations(o[3])
                key = (round(st[0].theta), round(st[0].k_AP, 1))
                if key in seen:
                    continue
                seen.append(key)
                # evaluate both bands for every solution
                full = cf.Fit(specs_j, [s for s in st], [])
                bc = np.array([[float(np.mean(np.abs((cf.model_on(s, sp) - sp.H) / sp.sigma) ** 2) / 2) for sp in sps]
                               for s, sps in zip(st, specs_j)])
                modes = [cm.coupled_mode(s) for s in st]
                print(f"  chi2r {o[4]/o[5]:.4f} | G0 {st[0].G/10**((recs[0].counts_db-0.9)/20):.3f} tau {st[0].tau*1e9:.0f}"
                      f" QL {st[0].Q_L:.0f} gA {st[0].g_A:.3f} kAP {st[0].k_AP:+.3f} alpha {st[0].alpha:+.1f}"
                      f" alpha_c {st[0].alpha_c*1e3:.3f}e-3 df {st[0].df/1e3:+.1f} theta " + " ".join(f"{s.theta:+.1f}" for s in st)
                      + f"\n     chi2/bin wide {bc[:,0].mean():.3f} beam {bc[:,1].mean():.3f}; modes "
                      + " ".join(f"{m.imag/2/np.pi/1e3:.2f}/{-m.real:.0f}" for m in modes))


if __name__ == "__main__":
    main()
