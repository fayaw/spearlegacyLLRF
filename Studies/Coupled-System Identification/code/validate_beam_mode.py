"""Out-of-band validation: the coupled beam-loop mode predicted from the wideband (15-400 kHz) identification.

For every record with beam (>= 200 mA) and every model family of wide_fits.json:
  * the closed-loop pole of the coupled mode, from csi_model.coupled_mode() of the fitted station;
  * the response predicted on the 3-16 kHz bins (2^15-point estimate, window smearing), chi^2/bin against
    the data, with no parameter adjusted;
and the model-free pole of csi_beam.pole_fit for comparison.
Writes results/beam_mode_validation.json and .log.
"""
from __future__ import annotations

import json
import math
import sys

import numpy as np

import csi_beam as cb
import csi_data as cd
import csi_fit as cf
import csi_model as cm

FIELDS = ("G", "theta", "tau", "Q_L", "df", "df_spread", "g_A", "k_AP", "alpha")


def station_from(rec_json: dict) -> cm.Station:
    return cm.Station(I_b=rec_json["mA"] / 1e3, **{k: rec_json[k] for k in FIELDS})


def main(tag="wide_fits"):
    G = json.loads((cd.RESULTS / f"{tag}.json").read_text())
    recs = {r.tag: r for r in cd.records()}
    out, log = {}, []
    free = {}
    for t, r in recs.items():
        if r.mA < 200 or r.date == "20251110":
            continue
        sp = cb.beam_spectrum(r)
        pf = cb.pole_fit(sp)
        free[t] = dict(f=pf["f"], sigma=pf["sigma"], df=pf["df"], dsigma=pf["dsigma"], chi2_red=pf["chi2_red"])
    for fam_name, res in G["results"].items():
        rows = []
        for rj in res["records"]:
            t = rj["tag"]
            if t not in free:
                continue
            st = station_from(rj)
            try:
                s = cm.coupled_mode(st)
                f_p, sig_p = s.imag / 2 / math.pi, -s.real
            except RuntimeError:
                f_p, sig_p = float("nan"), float("nan")
            sp = cb.beam_spectrum(recs[t])
            r = (cf.model_on(st, sp) - sp.H) / sp.sigma
            chi = float(np.mean(np.abs(r) ** 2) / 2)
            rows.append(dict(tag=t, label=rj["label"], mA=rj["mA"], counts_db=rj["counts_db"], phase_c=rj["phase_c"],
                             f_pred=f_p, sigma_pred=sig_p, chi2_band=chi, **{f"{k}_free": v for k, v in free[t].items()}))
        out[fam_name] = rows
        e_f = np.array([x["f_pred"] - x["f_free"] for x in rows])
        e_s = np.array([x["sigma_pred"] - x["sigma_free"] for x in rows])
        z_s = np.array([(x["sigma_pred"] - x["sigma_free"]) / x["dsigma_free"] for x in rows])
        txt = (f"== {fam_name}: out-of-band mode prediction over {len(rows)} records: frequency error mean {e_f.mean():+.0f} Hz"
               f" rms {np.sqrt(np.mean(e_f**2)):.0f} Hz; damping error mean {e_s.mean():+.0f} rms {np.sqrt(np.mean(e_s**2)):.0f} /s"
               f" (rms z {np.sqrt(np.mean(z_s**2)):.2f}); chi2/bin in 3-16 kHz median {np.median([x['chi2_band'] for x in rows]):.2f}")
        for x in rows:
            txt += (f"\n  {x['label']} {x['mA']:4.0f} mA {x['counts_db']:+.1f} dB {x['phase_c']:+5.0f}: predicted {x['f_pred']/1e3:6.3f} kHz"
                    f" {x['sigma_pred']:7.0f}/s | model-free {x['f_free']/1e3:6.3f}+-{x['df_free']/1e3:.3f} kHz"
                    f" {x['sigma_free']:5.0f}+-{x['dsigma_free']:4.0f}/s | band chi2/bin {x['chi2_band']:.2f}")
        print(txt, flush=True)
        log.append(txt)
    (cd.RESULTS / "beam_mode_validation.json").write_text(json.dumps(out, indent=1))
    (cd.RESULTS / "beam_mode_validation.log").write_text("\n".join(log))


if __name__ == "__main__":
    main(*sys.argv[1:])
