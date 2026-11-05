"""Trip records of the present klystron (2021): its small-signal response from the normal operation before each trip.

Offline analysis of matlab_operations_prod/Measurement/FaultFiles/2021: fifteen records of station trips in 2021, all
of the present tube (installed 7 September 2020). Nothing here touches the station.

Record contents (frozen at the fault and written by the IOC's fault-file state set; Doc I sec. aim-snl-files):
  FAULTRfpS[IQ]_n   RFP signal RAM, mux code 3 (FBSIG 3): klystron drive I/Q, 10.24 MS/s, 51 200 samples (5.0 ms)
                    ending at the fault, newest sample first
  FAULTRfpC[IQ]_n   RFP cavity RAM, mux code 3 (CAVSEL 3, cavity 4): probe I/Q, same module and time base
  FAULTIqa1Amp_n    IQ&A-1 amplitude history, a single channel (0, klystron output forward) at the same rate and
                    length; A = sqrt(I^2 + Q^2) is linear in the RF amplitude (Doc L sec. iqa-map)
  FAULTIqa2Amp_n, FAULTIqa3Amp_n   channel 1 of IQ&A-2/-3 (cavity 1 and cavity 3 reflected); not used
  FAULTGvf_n, FAULTCmb[IQ]_n       PEP-II modules, inactive at SPEAR3; not used
The stored I/Q are the complex conjugate of the physical envelope, as for the closed-loop RAM records (csi_data):
conjugated, the drive-to-probe response places the cavities below f_RF, as the beam loading requires (checked below).

Klystron, memoryless about its operating point (paper Sec. III C): relative output amplitude a_k = g_A a_d and
output phase phi_k = phi_d + k_AP a_d for relative drive amplitude a_d and drive phase phi_d.
  * g_A from the IQ&A-1 output amplitude against the RFP drive amplitude. The H1 and H2 estimates bracket the bias
    of noise on either signal; 50-200 kHz lies above the HVPS lines and inside the flat part of both chains.
  * k_AP (and a second, biased g_A) from the probe's response to drive amplitude and phase,
    c = P [(g_A + j k_AP) a_d + j phi_d], so that A/B = k_AP - j g_A for any complex-linear plant P (the cavities;
    the beam acts only near f_s). The loop's own correlation pulls this ratio towards a linear klystron
    (k_AP -> 0, g_A -> 1), so |k_AP| is if anything underestimated.
Writes results/trip_klystron.json and .log.
"""
from __future__ import annotations

import json

import numpy as np

import csi_data as cd

TRIP_DIR = cd.FAULT_DIR
BANDS = ((2e3, 10e3), (10e3, 50e3), (50e3, 200e3), (200e3, 500e3), (500e3, 1.5e6))
GAIN_BAND = (50e3, 200e3)
RATIO_BAND = (60e3, 250e3)
FULL_POWER = 0.45                     # IQ&A-1 output amplitude separating full-power from reduced-power records


def numbers() -> list[int]:
    return cd.fault_numbers()


def load(n: int) -> dict:
    """One trip record, oldest sample first, I/Q in the physical convention."""
    ms, drv = cd.fault_rfp("S", n, TRIP_DIR)
    mc, cav = cd.fault_rfp("C", n, TRIP_DIR)
    ch, kly = cd.fault_iqa(1, n, TRIP_DIR)
    return dict(n=n, mux_drive=ms, mux_probe=mc, iqa_channel=ch - 1, drive=np.conj(drv), probe=np.conj(cav), kly=kly)


def classify(rec: dict) -> str:
    d, c, k = np.abs(rec["drive"]).mean(), np.abs(rec["probe"]).mean(), rec["kly"].mean()
    if k < 0.05:
        return "rf-off"
    if d < 0.05 or c < 0.05:
        return "rfp-empty"
    return "full" if k >= FULL_POWER else "reduced"


def pre_trip_end(rec: dict, block: int = 512, margin: int = 5120) -> int:
    """Last sample of normal operation: 0.5 ms before the end of the record, earlier if any signal departs first."""
    end = rec["drive"].size - margin
    for x in (np.abs(rec["drive"]), rec["kly"], np.abs(rec["probe"])):
        m = np.array([x[i:i + block].mean() for i in range(0, x.size - block + 1, block)])
        base = np.median(m[: len(m) * 4 // 5])
        spread = 1.4826 * np.median(np.abs(m[: len(m) * 4 // 5] - base))
        bad = np.nonzero(np.abs(m - base) > max(8 * spread, 0.03 * abs(base)))[0]
        bad = bad[bad * block > x.size // 2]
        if bad.size:
            end = min(end, int(bad[0]) * block - block)
    return end


def cross(sig, nseg: int):
    """Averaged cross-spectral matrix S[c, d, f] of the signals (Hann, 50 % overlap, each segment mean-removed)."""
    w = np.hanning(nseg)
    st = range(0, sig[0].size - nseg + 1, nseg // 2)
    X = np.array([[np.fft.fft(w * (s[i:i + nseg] - s[i:i + nseg].mean())) for i in st] for s in sig])
    return np.fft.fftfreq(nseg, 1 / cd.FS), np.einsum("csf,dsf->cdf", X, np.conj(X)) / X.shape[1], X.shape[1]


def klystron_gain(rec: dict, end: int, nseg: int = 2048) -> dict:
    """Output amplitude against drive amplitude: |H1|, |H2| and coherence by band, spectra, inter-module delay."""
    a_d = np.abs(rec["drive"][:end])
    k = rec["kly"][:end]
    x, y = a_d / a_d.mean() - 1, k / k.mean() - 1
    f, S, nav = cross([y, x], nseg)
    H1 = S[0, 1] / S[1, 1].real
    H2 = S[0, 0].real / np.conj(S[0, 1])
    coh = np.abs(S[0, 1]) ** 2 / (S[0, 0].real * S[1, 1].real)
    out = dict(nav=nav, bands=[])
    for lo, hi in BANDS:
        sel = (f >= lo) & (f < hi)
        out["bands"].append(dict(lo=lo, hi=hi, h1=float(np.median(np.abs(H1[sel]))), h2=float(np.median(np.abs(H2[sel]))),
                                 coh=float(np.median(coh[sel]))))
    sel = (f >= 50e3) & (f < 500e3)
    out["delay_ns"] = float(-np.polyfit(2 * np.pi * f[sel], np.unwrap(np.angle(H1[sel])), 1)[0] * 1e9)
    pos = f > 0
    out["spectrum"] = dict(f=f[pos].tolist(), h1=np.abs(H1[pos]).tolist(), h2=np.abs(H2[pos]).tolist(), coh=coh[pos].tolist())
    return out


def drive_to_probe(rec: dict, end: int, nseg: int = 1024) -> dict:
    """Probe response to drive amplitude (A) and phase (B); A/B = k_AP - j g_A; asymmetry of |B| (detuning side)."""
    d, c = rec["drive"][:end], rec["probe"][:end]
    dm = d.mean()
    a_d = np.abs(d) / abs(dm) - 1
    p_d = np.unwrap(np.angle(d / dm))
    cc = c / c.mean() - 1
    f, S, _ = cross([cc, a_d.astype(complex), p_d.astype(complex)], nseg)
    A, B, coh = np.zeros(f.size, complex), np.zeros(f.size, complex), np.zeros(f.size)
    for i in range(f.size):
        Syy, Sxy = S[1:, 1:, i], S[0, 1:, i]
        A[i], B[i] = np.linalg.solve(Syy.T, Sxy)
        coh[i] = (Sxy @ np.linalg.solve(Syy, np.conj(Sxy))).real / S[0, 0, i].real
    sel = (np.abs(f) >= RATIO_BAND[0]) & (np.abs(f) < RATIO_BAND[1])
    r = A[sel] / B[sel]
    side = lambda lo, hi, s: float(np.median(np.abs(B[(np.abs(f) >= lo) & (np.abs(f) < hi) & (np.sign(f) == s)])))
    return dict(k_AP=float(np.median(r.real)), g_A=float(-np.median(r.imag)), coh=float(np.median(coh[sel])),
                asym=side(20e3, 45e3, -1) / side(20e3, 45e3, +1))


def mean_sd(v) -> list[float]:
    v = np.asarray(v, float)
    return [float(v.mean()), float(v.std(ddof=1)) if v.size > 1 else float("nan")]


def main():
    rows, log = [], []
    log.append("record class   drive  output  probe  end(ms) | g_A = |H1|/|H2| [coh] by band: 2-10k 10-50k 50-200k "
               "200-500k 0.5-1.5M | delay | drive->probe 60-250 kHz: k_AP, g_A [coh]  |B(-f)|/|B(+f)| 20-45 kHz")
    for n in numbers():
        rec = load(n)
        kind = classify(rec)
        row = dict(n=n, kind=kind, mux_drive=rec["mux_drive"], mux_probe=rec["mux_probe"], iqa_channel=rec["iqa_channel"],
                   drive=float(np.abs(rec["drive"]).mean()), output=float(rec["kly"].mean()),
                   probe=float(np.abs(rec["probe"]).mean()))
        line = f"{n:4d}   {kind:9s} {row['drive']:.3f}  {row['output']:.3f}  {row['probe']:.3f}"
        if kind in ("full", "reduced"):
            end = pre_trip_end(rec)
            g = klystron_gain(rec, end)
            r = drive_to_probe(rec, end)
            row.update(end_ms=end / cd.FS * 1e3, gain=g, ratio=r)
            line += (f"  {row['end_ms']:.2f}  | " + " ".join(f"{b['h1']:.3f}/{b['h2']:.3f}[{b['coh']:.2f}]" for b in g["bands"])
                     + f" | {g['delay_ns']:+.0f} ns | {r['k_AP']:+.3f}, {r['g_A']:.3f} [{r['coh']:.2f}]  {r['asym']:.2f}")
        else:
            line += "  (not used: " + ("RF off in every module" if kind == "rf-off" else "RFP memories hold no RF") + ")"
        rows.append(row)
        log.append(line)
    used = [r for r in rows if "gain" in r]
    ib = BANDS.index(GAIN_BAND)
    g_band = lambda rs, i=ib: [r["gain"]["bands"][i]["h1"] for r in rs]
    hi = [r for r in used if r["kind"] == "full"]
    lo = [r for r in used if r["kind"] == "reduced"]
    summary = dict(
        n_records=len(rows), n_used=len(used), n_full=len(hi), n_reduced=len(lo),
        power_ratio=float(np.mean([r["output"] for r in lo]) ** 2 / np.mean([r["output"] for r in hi]) ** 2),
        drive_full=mean_sd([r["drive"] for r in hi]), drive_reduced=mean_sd([r["drive"] for r in lo]),
        g_A=mean_sd(g_band(used)), g_A_full=mean_sd(g_band(hi)), g_A_reduced=mean_sd(g_band(lo)),
        g_A_h2=mean_sd([r["gain"]["bands"][ib]["h2"] for r in used]),
        g_A_high=mean_sd([np.mean([r["gain"]["bands"][i]["h1"] for i in (3, 4)]) for r in used]),
        g_A_low=mean_sd([r["gain"]["bands"][0]["h2"] for r in hi]),
        coh=[float(min(r["gain"]["bands"][ib]["coh"] for r in used)), float(max(r["gain"]["bands"][ib]["coh"] for r in used))],
        delay_ns=mean_sd([r["gain"]["delay_ns"] for r in used]),
        k_AP=mean_sd([r["ratio"]["k_AP"] for r in used]), g_A_ratio=mean_sd([r["ratio"]["g_A"] for r in used]),
        ratio_coh=[float(min(r["ratio"]["coh"] for r in used)), float(max(r["ratio"]["coh"] for r in used))],
        asym=[float(min(r["ratio"]["asym"] for r in used)), float(max(r["ratio"]["asym"] for r in used))])
    s = summary
    log += ["", f"{s['n_used']} of {s['n_records']} records usable: {s['n_full']} at full output, {s['n_reduced']} at "
                f"{100 * s['power_ratio']:.0f}% of that power; drive {s['drive_full'][0]:.3f} and {s['drive_reduced'][0]:.3f}",
            f"g_A (50-200 kHz, H1): all {s['g_A'][0]:.3f} +- {s['g_A'][1]:.3f}; full {s['g_A_full'][0]:.3f} +- "
            f"{s['g_A_full'][1]:.3f}; reduced {s['g_A_reduced'][0]:.3f} +- {s['g_A_reduced'][1]:.3f}; H2 {s['g_A_h2'][0]:.3f};"
            f" coherence {s['coh'][0]:.2f}-{s['coh'][1]:.2f}",
            f"g_A above 200 kHz {s['g_A_high'][0]:.3f} +- {s['g_A_high'][1]:.3f}; 2-10 kHz (H2, full power) "
            f"{s['g_A_low'][0]:.3f} +- {s['g_A_low'][1]:.3f}; inter-module delay {s['delay_ns'][0]:.0f} ns",
            f"drive->probe: k_AP {s['k_AP'][0]:+.3f} +- {s['k_AP'][1]:.3f}, g_A {s['g_A_ratio'][0]:.3f} +- "
            f"{s['g_A_ratio'][1]:.3f} (biased towards 1); coherence {s['ratio_coh'][0]:.2f}-{s['ratio_coh'][1]:.2f}; "
            f"|B(-f)|/|B(+f)| {s['asym'][0]:.2f}-{s['asym'][1]:.2f} (> 1: cavities below f_RF, physical convention)"]
    print("\n".join(log))
    (cd.RESULTS / "trip_klystron.json").write_text(json.dumps(dict(summary=summary, records=rows), indent=1))
    (cd.RESULTS / "trip_klystron.log").write_text("\n".join(log) + "\n")


if __name__ == "__main__":
    main()
