import json, os, numpy as np
from concurrent.futures import ProcessPoolExecutor
import csi_data as cd, csi_families as fam, csi_fit as cf
import run_identifiability as ri

def job(args):
    which, value, flip = args
    os.environ.setdefault("OMP_NUM_THREADS", "1")
    recs = ri.subsets()["one record"]
    specs = fam.wide_specs(recs)
    st = ri.full_start(recs)
    if flip: st["k_AP"] = [-k for k in st["k_AP"]]
    F = dict(fam.FAMILIES["J_wl_group_ac"]); F["joint"] = False
    fit = fam.build(recs, specs, F, st)
    # alpha_c is not identifiable from the wideband: hold it at the joint value
    for p in fit.pars:
        if p.name == "alpha_c": p.fixed = True; p.value = st["alpha_c"]; p.scope = "global"
    fit.__post_init__()
    if which is not None:
        fit.base = [b.with_(**{which: value}) for b in fit.base]
        fit._layout = [(p, idx) for p, idx in fit._layout if p.name != which]
    res = cf.run(fit, max_nfev=800)
    out = dict(which=which, value=value, chi2=res.chi2, dof=res.dof, g_A=res.stations[0].g_A, k_AP=res.stations[0].k_AP)
    if which is None:
        J = res.jac; F2 = J.T @ J; d = np.sqrt(np.diag(F2)); w = np.linalg.eigvalsh(F2 / np.outer(d, d))
        out["cond"] = float(w.max() / max(w.min(), 1e-300))
    return out

if __name__ == "__main__":
    jobs = [(None, None, False), (None, None, True)] + [("g_A", g, f) for g in ri.G_GRID for f in (False, True)] + [("k_AP", k, f) for k in ri.K_GRID for f in (False, True)]
    with ProcessPoolExecutor(max_workers=15) as ex:
        res = list(ex.map(job, jobs))
    free = min([r for r in res if r["which"] is None], key=lambda r: r["chi2"])
    prof = {}
    for w in ("g_A", "k_AP"):
        vals = sorted(set(r["value"] for r in res if r["which"] == w))
        prof[w] = [[v, min(r["chi2"] for r in res if r["which"] == w and r["value"] == v)] for v in vals]
    chi_min = min([free["chi2"]] + [p[1] for w in prof.values() for p in w])
    print(f"one record, wideband only: g_A {free['g_A']:.3f} k_AP {free['k_AP']:+.3f} chi2r {free['chi2']/free['dof']:.4f} cond {free['cond']:.3g}")
    for w in prof: print(f"  {w}: " + " ".join(f"{v:+.2f}:{c - chi_min:.1f}" for v, c in prof[w]))
    I = json.loads((cd.RESULTS / "identifiability.json").read_text())
    I["one record, wideband only"] = dict(free=free, chi_min=chi_min, profile=prof)
    (cd.RESULTS / "identifiability.json").write_text(json.dumps(I, indent=1, default=float))
