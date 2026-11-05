"""Post-mortem of RF trips: was the beam's dipole mode oscillating, or growing, before the trip?

At every trip the RFP freezes about 5 ms of the drive I/Q (signal RAM, FBSIG 3), one cavity probe I/Q (cavity
RAM) and the klystron output amplitude (IQ&A history) (Doc P sec:robinson-open; spear3rf/scripts/
analyze_old_rf_data.py).  For each record the script takes the normal operation before the trip and reports,
for the probe and the drive:
  * the field modulation in the band of the synchrotron line (5-11 kHz), rms, and its excess over the floor
    at 15-25 kHz; the frequency of the strongest component
  * the beam phase this would be if it were all beam motion, with the probe's beam factor of the station model
    at an assumed current (default 250 mA, model eff): an upper bound, since field noise is included
  * growth: the band-passed envelope in the last millisecond before the trip against the first two
A coherent oscillation at f_coh that grows into the trip points to the dipole mode; none points elsewhere.
Writes results/fault_postmortem_<folder>.csv.

usage: python fault_postmortem.py [FOLDER] [--current 250] [--model eff]
       (FOLDER holds FAULTRfpSI_<n>, FAULTRfpSQ_<n>, FAULTRfpCI_<n>, FAULTRfpCQ_<n>, FAULTIqa1Amp_<n>;
        default: matlab_operations_prod/Measurement/FaultFiles/2021, the trip records of 2021, present tube)
"""
import argparse
import math
from pathlib import Path

import numpy as np
from scipy.signal import decimate

import optllrf as ol

FS = 8 * 476.3039e6 / 372
DEFAULT = ol.ROOT / "matlab_operations_prod" / "Measurement" / "FaultFiles" / "2021"
BAND, FLOOR = (5e3, 11e3), (15e3, 25e3)


def rfp(folder, prefix, n):
    parts = []
    for q in ("I", "Q"):
        w = np.frombuffer((folder / f"{prefix}{q}_{n}").read_bytes()[16:], dtype=">i2").astype(np.int64)
        parts.append((int(w[0] & 3), np.fix(w / 16) / 2048))
    return parts[0][0], (parts[0][1] + 1j * parts[1][1])[::-1]


def iqa(folder, module, n):
    w = np.frombuffer((folder / f"FAULTIqa{module}Amp_{n}").read_bytes()[21:], dtype=">u2").astype(np.int64)
    return int(w[0] & 7) + 1, (np.fix((w - 32768) / 16) / 2048)[::-1]


def pre_trip_end(*signals, block=512):
    end = signals[0].size - 5120
    for x in signals:
        b = np.array([x[i:i + block].std() for i in range(0, x.size - block + 1, block)])
        jump = np.nonzero(b > 4 * np.median(b))[0]
        if jump.size:
            end = min(end, int(jump[0]) * block - block)
    return end


def band_stats(v, fs_dec=51.2e3):
    z = v / v.mean() - 1.0
    for q in (10, 20):
        z = decimate(z, q, ftype="fir", zero_phase=True)
    n = z.size
    f = np.fft.fftfreq(n, 1 / fs_dec)
    Z = np.fft.fft((z - z.mean()) * np.hanning(n))
    S = np.abs(Z) ** 2 / (fs_dec * np.sum(np.hanning(n) ** 2))
    df = fs_dec / n
    inb = (np.abs(f) >= BAND[0]) & (np.abs(f) <= BAND[1])
    flo = (np.abs(f) >= FLOOR[0]) & (np.abs(f) <= FLOOR[1])
    p_band = float(np.sum(S[inb]) * df)
    p_floor = float(np.median(S[flo]) * inb.sum() * df)
    k = np.argmax(np.where(inb, S, 0))
    zb = np.fft.ifft(np.where(inb, np.fft.fft(z - z.mean()), 0))
    env = np.abs(zb)
    m = int(1e-3 * fs_dec)
    growth = float(np.sqrt(np.mean(env[-m:] ** 2) / np.mean(env[: 2 * m] ** 2))) if n > 3 * m else float("nan")
    return dict(rms_band=math.sqrt(p_band), excess_db=10 * math.log10(p_band / p_floor), f_peak=float(f[k]),
                growth=growth, ms=n / fs_dec * 1e3)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("folder", nargs="?", default=str(DEFAULT))
    ap.add_argument("--current", type=float, default=250.0)
    ap.add_argument("--model", default="eff", choices=sorted(ol.MODELS))
    a = ap.parse_args()
    folder = Path(a.folder)
    q = ol.station(a.current, a.model)
    m = q.mode()
    up, lo = ol.probe_power_per_rad2(q, m.frequency)
    per_rad = math.sqrt(up + lo)            # rms field modulation (both sidebands) per radian of beam phase
    ns = sorted(int(p.name.split("_")[-1]) for p in folder.glob("FAULTRfpCI_*"))
    print(f"{folder}: {len(ns)} fault records; beam factor at {a.current:.0f} mA ({a.model}): 1 deg of beam phase ="
          f" {100 * per_rad * math.radians(1):.2f}% rms field modulation at f_coh {m.frequency:.0f} Hz")
    rows = []
    for n in ns:
        ms, drv = rfp(folder, "FAULTRfpS", n)
        mc, cav = rfp(folder, "FAULTRfpC", n)
        mk, kly = iqa(folder, 1, n)
        end = pre_trip_end(np.abs(drv), kly, np.abs(cav))
        if end < 20000 or abs(cav[:end].mean()) < 0.05:
            print(f"  #{n:2d}: no usable pre-trip record with RF on (probe level {abs(cav[:max(end, 1)].mean()):.3f})")
            rows.append([n, ms, mc, end / FS * 1e3, abs(cav[:max(end, 1)].mean())] + [float("nan")] * 9)
            continue
        pc, pd = band_stats(cav[:end]), band_stats(drv[:end])
        dphi = math.degrees(pc["rms_band"] / per_rad)
        print(f"  #{n:2d}: {pc['ms']:.1f} ms before the trip, klystron {np.median(kly[:end]):.2f}; probe 5-11 kHz"
              f" {100 * pc['rms_band']:.3f}% rms ({pc['excess_db']:+.1f} dB over the floor, peak {pc['f_peak']:+.0f} Hz,"
              f" last ms / first 2 ms x{pc['growth']:.2f}) -> at most {dphi:.2f} deg of beam phase; drive"
              f" {100 * pd['rms_band']:.3f}% ({pd['excess_db']:+.1f} dB, x{pd['growth']:.2f})")
        rows.append([n, ms, mc, pc["ms"], abs(cav[:end].mean()), np.median(kly[:end]), pc["rms_band"], pc["excess_db"],
                     pc["f_peak"], pc["growth"], dphi, pd["rms_band"], pd["excess_db"], pd["growth"]])
    p = ol.save_csv(ol.RESULTS / f"fault_postmortem_{folder.name}.csv",
                    ["record", "mux_signal", "mux_cavity", "pre_trip_ms", "probe_level", "klystron_amp",
                     "probe_band_rms", "probe_band_excess_dB", "probe_peak_Hz", "probe_growth", "beam_phase_max_deg",
                     "drive_band_rms", "drive_band_excess_dB", "drive_growth"], rows)
    print("wrote", p)


if __name__ == "__main__":
    main()
