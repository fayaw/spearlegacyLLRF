"""Cross-condition prediction: train each model without some operating conditions, predict them.

Models (joint wideband + beam band, synchrotron frequency identified in training):
  J_lin_eff_ac          complex-linear, effective G, tau, Q_L per record            (local black-box parameters)
  J_lin_shared_ac       complex-linear, one station                                (physics without the klystron)
  J_wl_group_ac         compressed klystron per operating point, AM/PM free, one station
  J_wl_group_ac_ktrip   compressed klystron per operating point, AM/PM from the trip records
  J_wl_global_ac_ktrip  one compressed klystron for every current, AM/PM from the trip records
Every model refits only nuisance parameters of a held-out record; everything else comes from training:
  A  gain transfer      hold out the four 3 Nov records at COUNTS.A = -0.2, 0.0, +0.3, +0.3 dB (497 mA); refit theta.
                        Effective model: G_eff of the +1.3 dB, PHASE.C -35 records scaled by 10^(dB/20), their mean
                        tau_eff, Q_eff. Station models: G scaled by the setting.
  B  phase transfer     hold out the 22 mA records at PHASE.C = -14 and -23 deg (09:33, 09:49); refit theta.
                        Effective model: mean G_eff, tau_eff, Q_eff of the remaining 22 mA records.
  C  current transfer   hold out 242, 363, 395 mA one at a time; refit theta and df (and the noise angle for the
                        klystron models). Effective model: G_eff, tau_eff, Q_eff interpolated in beam current;
                        klystron per operating point: g_A, k_AP interpolated in beam current; one klystron: as trained.
Metric: chi^2/dof of the held-out record (both bands) after the nuisance refit; the in-sample value of the same
record in the full fit for reference.
Writes results/crossval.json (merged with families not rerun) and crossval.log.
usage: python run_crossval.py [--families a,b,...]
"""
from __future__ import annotations

import json
import os
import time
from concurrent.futures import ProcessPoolExecutor

import numpy as np

import csi_data as cd
import csi_families as fam
import csi_fit as cf
import csi_model as cm

FAMS = ("J_lin_eff_ac", "J_lin_shared_ac", "J_wl_group_ac", "J_wl_group_ac_ktrip", "J_wl_global_ac_ktrip")


def tests():
    allrecs = fam.select()
    by = {r.label: r for r in allrecs}
    return {
        "A gain transfer (497 mA)": [by[k] for k in ("11/03 17:28:53", "11/03 17:29:32", "11/03 17:30:07", "11/03 17:31:27")],
        "B phase transfer (22 mA)": [by[k] for k in ("10/02 09:33:31", "10/02 09:49:48")],
        "C current transfer 242 mA": [by["11/03 17:07:42"]],
        "C current transfer 363 mA": [by["10/02 13:44:49"]],
        "C current transfer 395 mA": [by["10/02 17:20:30"]],
    }


def solution(name):
    J = json.loads((cd.RESULTS / "joint_fits.json").read_text())["results"][name]
    return {r["tag"]: r for r in J["records"]}, J


def start_for(recs, sol):
    dg, gr = fam.dgroup_index(recs), fam.group_index(recs)
    mean = lambda key, groups, k: float(np.mean([sol[r.tag][key] for r, g in zip(recs, groups) if g == k]))
    r0 = sol[recs[0].tag]
    return dict(theta=[sol[r.tag]["theta"] for r in recs], df_group=[mean("df", dg, k) for k in range(max(dg) + 1)],
                G=[sol[r.tag]["G"] / 10 ** ((r.counts_db - fam.REF_DB) / 20) for r in recs],
                tau=[sol[r.tag]["tau"] for r in recs], Q_L=[sol[r.tag]["Q_L"] for r in recs],
                g_A=[mean("g_A", gr, k) for k in range(max(gr) + 1)], k_AP=[mean("k_AP", gr, k) for k in range(max(gr) + 1)],
                alpha=[mean("alpha", gr, k) for k in range(max(gr) + 1)], mc1r=r0["mc1r"], mc2r=r0["mc2r"],
                mc2i=r0["mc2i"], alpha_c=r0["alpha_c"])


def train_job(args):
    tname, name = args
    os.environ.setdefault("OMP_NUM_THREADS", "1")
    held = tests()[tname]
    recs = [r for r in fam.select() if r not in held]
    sol, _ = solution(name)
    st = start_for(recs, sol)
    if name == "J_lin_eff_ac":
        st["G"] = [sol[r.tag]["G"] for r in recs]
    fit = fam.build(recs, fam.specs_for(recs, name), fam.FAMILIES[name], st)
    res = cf.run(fit, max_nfev=600)
    return tname, name, {r.tag: dict(s.__dict__) for r, s in zip(recs, res.stations)}


def interp(xs, ys, x):
    o = np.argsort(xs)
    return float(np.interp(x, np.asarray(xs)[o], np.asarray(ys)[o]))


def refit(st, r, free):
    sp = fam.joint_specs([r])
    best = None
    for dth in (0.0, -20.0, 20.0):
        for dal in ((0.0, 60.0, -60.0) if "alpha" in free else (0.0,)):
            pars = [cf.Par("theta", st.theta + dth, lo=-180, hi=180, scale=5)]
            if "df" in free:
                pars.append(cf.Par("df", st.df, lo=-90e3, hi=40e3, scale=1e3))
            if "alpha" in free:
                pars.append(cf.Par("alpha", st.alpha + dal, lo=-360, hi=360, scale=10))
            res = cf.run(cf.Fit(sp, [st], pars), sparse=False)
            if best is None or res.chi2 < best.chi2:
                best = res
    bands = [float(np.mean(np.abs((cf.model_on(best.stations[0], s) - s.H) / s.sigma) ** 2) / 2) for s in sp[0]]
    return best.chi2, best.dof, bands


def predict_job(args):
    tname, name, trained = args
    os.environ.setdefault("OMP_NUM_THREADS", "1")
    held = tests()[tname]
    recs = [r for r in fam.select() if r not in held]
    tr = {t: cm.Station(**d) for t, d in trained.items()}
    sol, full = solution(name)
    any_st = next(iter(tr.values()))
    out = []
    for r in held:
        ref = sol[r.tag]
        base = cm.Station(I_b=r.mA / 1e3, mc1r=any_st.mc1r, mc2r=any_st.mc2r, mc2i=any_st.mc2i, alpha_c=any_st.alpha_c,
                          theta=ref["theta"], df=ref["df"])
        same = [t for t in recs if t.date == r.date and abs(t.mA - r.mA) < 25]
        if name == "J_lin_eff_ac":
            if tname.startswith("A"):
                src = [tr[t.tag] for t in same if t.counts_db == 1.3 and t.phase_c == -35.0]
                st = base.with_(G=float(np.mean([s.G for s in src])) * 10 ** ((r.counts_db - 1.3) / 20),
                                tau=float(np.mean([s.tau for s in src])), Q_L=float(np.mean([s.Q_L for s in src])),
                                df=float(np.mean([s.df for s in src])))
            elif tname.startswith("B"):
                src = [tr[t.tag] for t in same]
                st = base.with_(G=float(np.mean([s.G for s in src])), tau=float(np.mean([s.tau for s in src])),
                                Q_L=float(np.mean([s.Q_L for s in src])), df=float(np.mean([s.df for s in src])))
            else:
                xs = [t.mA for t in recs]
                st = base.with_(G=interp(xs, [tr[t.tag].G * 10 ** ((r.counts_db - t.counts_db) / 20) for t in recs], r.mA),
                                tau=interp(xs, [tr[t.tag].tau for t in recs], r.mA),
                                Q_L=interp(xs, [tr[t.tag].Q_L for t in recs], r.mA))
            free = ("theta",) if tname[0] in "AB" else ("theta", "df")
        else:
            t0 = recs[0]
            st = base.with_(G=tr[t0.tag].G * 10 ** ((r.counts_db - t0.counts_db) / 20), tau=tr[t0.tag].tau,
                            Q_L=tr[t0.tag].Q_L)
            kly = fam.FAMILIES[name].get("kly")
            if tname[0] in "AB":
                src = [tr[t.tag] for t in same]
                st = st.with_(df=float(np.mean([s.df for s in src])), g_A=src[0].g_A, k_AP=src[0].k_AP, alpha=src[0].alpha)
                free = ("theta",)
            elif kly == "group":
                xs = [t.mA for t in recs]
                st = st.with_(g_A=interp(xs, [tr[t.tag].g_A for t in recs], r.mA),
                              k_AP=interp(xs, [tr[t.tag].k_AP for t in recs], r.mA), alpha=ref["alpha"])
                free = ("theta", "df", "alpha")
            elif kly == "global":
                st = st.with_(g_A=tr[t0.tag].g_A, k_AP=tr[t0.tag].k_AP, alpha=ref["alpha"])
                free = ("theta", "df", "alpha")
            else:
                free = ("theta", "df")
        chi2, dof, bands = refit(st, r, free)
        i = [x["tag"] for x in full["records"]].index(r.tag)
        ins = full["band_chi2"][i]
        out.append(dict(tag=r.tag, label=r.label, chi2_red=chi2 / dof, wide=bands[0], beam=bands[1],
                        insample=(ins[0] + ins[1]) / (ins[2] + ins[3]), insample_wide=ins[0] / ins[2],
                        insample_beam=ins[1] / ins[3], free=list(free)))
    return tname, name, out


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--families", default=",".join(FAMS), help="families to (re)run; others are kept from crossval.json")
    names = ap.parse_args().families.split(",")
    t0 = time.time()
    jobs = [(t, n) for t in tests() for n in names]
    with ProcessPoolExecutor(max_workers=15) as ex:
        trained = list(ex.map(train_job, jobs))
    print(f"trained {len(trained)} models in {time.time() - t0:.0f} s", flush=True)
    with ProcessPoolExecutor(max_workers=15) as ex:
        preds = list(ex.map(predict_job, trained))
    path = cd.RESULTS / "crossval.json"
    out = json.loads(path.read_text()) if path.exists() else {}
    for tname, name, rows in preds:
        out.setdefault(tname, {})[name] = rows
    log = []
    for tname, per in out.items():
        for name, rows in per.items():
            txt = (f"{tname:28s} {name:22s}: held-out chi2/bin " + " ".join(f"{x['chi2_red']:.3f}" for x in rows)
                   + " (wide " + " ".join(f"{x['wide']:.2f}" for x in rows) + "; beam " + " ".join(f"{x['beam']:.2f}" for x in rows)
                   + ") | in-sample " + " ".join(f"{x['insample']:.3f}" for x in rows))
            print(txt, flush=True)
            log.append(txt)
    path.write_text(json.dumps(out, indent=1))
    (cd.RESULTS / "crossval.log").write_text("\n".join(log))
    print(f"done {time.time() - t0:.0f} s")


if __name__ == "__main__":
    main()
