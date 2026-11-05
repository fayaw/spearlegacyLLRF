"""Historical SRF1 data in matlab_operations_prod/Measurement/OldData, for Doc P and the performance study.

  ../ClosedLoopTF/2020-05-04/measureDirect...fig   closed-loop TF, 4 May 2020, no beam, COUNTS.A 5.1 dB, PHASE.C -33 deg
  feedback/CAVITY_[IQ]*, DRIVE_[IQ]*  cavity-1 probe and klystron drive RAM dumps, 2 June 2020, six loop configurations
  klystron/gainCurves/20130311/*.mat  klystron transfer curves, 11 March 2013 (a tube replaced since)
  SRF1/savedata*.sav*                 saved IOC settings, December 2003
  ../FaultFiles/2021/FAULT*_<n>       trip records of 2021 (present tube; moved from OldData/SRF1, copied there
                                      13 Nov 2025): RFP drive I/Q (signal RAM, FBSIG 3), RFP cavity-RAM probe I/Q
                                      (mux code 3), IQA1 klystron-output amplitude, frozen together at the trip
The klystron failed on 3 September 2020 and was replaced on 7 September 2020: the 2013 and 2020 data are from
earlier tubes than the present one.
"""
import io
import math
import sys
from pathlib import Path

import numpy as np
import scipy.io as sio
from scipy.io.matlab._mio5 import MatFile5Reader

sys.path.insert(0, str(Path(__file__).resolve().parent))
import analyze_measure_direct as amd  # noqa: E402

OLD = amd.MEAS / "OldData"
TRIPS = amd.MEAS / "FaultFiles" / "2021"
CONF = {"all loops on": "AllOn", "ripple loop off": "DirectOnRippleOff", "integral path off": "DirectOnRippleOnIntegralOff",
        "lead network off": "DirectOnRippleOnLeadOff", "direct loop off": "DirectOffRippleOn",
        "direct and ripple off": "DirectOffRippleOff"}


def may2020_closed_loop():
    path = amd.MEAS / "ClosedLoopTF" / "2020-05-04" / "measureDirect000mA2850gp051pm33020200504.fig"
    # this older figure has one line per side, so all lines are read here rather than with amd.fig_tf
    data = sio.loadmat(path)["__function_workspace__"].tobytes()
    header = b"MATLAB 5.0 MAT-file, subsystem".ljust(116, b" ") + b"\x00" * 8 + data[0:4]
    stream = io.BytesIO(header + data[8:])
    rdr = MatFile5Reader(stream, struct_as_record=False, squeeze_me=False)
    rdr.initialize_read()
    stream.seek(128)
    hdr, _ = rdr.read_var_header()
    flat = []

    def walk(o, depth=0):
        if depth > 14:
            return
        if isinstance(o, np.ndarray):
            if o.dtype.names:
                for n in o.dtype.names:
                    for x in o[n].flat:
                        walk(x, depth + 1)
            elif o.dtype == object:
                for x in o.flat:
                    walk(x, depth + 1)
            elif o.dtype.kind == "f":
                flat.append(np.asarray(o, float).ravel())
        elif hasattr(o, "_fieldnames"):
            for n in o._fieldnames:
                walk(getattr(o, n), depth + 1)

    walk(rdr.read_var_array(hdr, process=True))
    lines = [(x, y) for x, y in zip(flat[:-1], flat[1:]) if x.size >= 100 and x.size == y.size and np.all(np.diff(x) > 0)]
    mag = [ln for ln in lines if np.nanmax(ln[1]) < 10 and np.ptp(ln[1]) < 60]
    ph = [ln for ln in lines if not (np.nanmax(ln[1]) < 10 and np.ptp(ln[1]) < 60)]
    f, H = [], []
    for x, y in mag:
        p = next(q for q in ph if q[0].size == x.size and np.allclose(q[0], x))
        f.append(x * 1e3)
        H.append(10 ** (y / 20) * np.exp(1j * np.radians(p[1])))
    f, H = np.concatenate(f), np.concatenate(H)
    o = np.argsort(f)
    f, H = f[o], H[o]
    print(f"== closed-loop TF, 4 May 2020 (no beam, COUNTS.A 5.1 dB, PHASE.C -33 deg): {f.size} points, "
          f"{f.min()/1e3:.0f}..{f.max()/1e3:.0f} kHz, bins {np.median(np.diff(f[f > 0]))/1e3:.2f} kHz")
    for hi in (400e3, 800e3):
        sel = (np.abs(f) >= 15e3) & (np.abs(f) <= hi)
        for integral in (False, True):
            p, rms = amd.fit_cl(f[sel], H[sel], 0, integral)
            print(f"  |f| 15-{hi/1e3:.0f} kHz, {'with integral path' if integral else 'proportional only '}: G {p[0]:.3f} theta {p[1]:+5.1f}"
                  f" tau {p[2]:4.0f} ns Q_L {p[3]:5.0f} df {p[4]:+5.1f} kHz rms {rms:.4f}")


def june2020_lines():
    """Cavity-1 field and klystron drive at the 60 Hz harmonics, least-squares fit over each 25.6 ms record.
    (Band-averaged spectra are not used: below 3 kHz the 312 Hz bins are dominated by the line harmonics, which the
    ripple loop also acts on, and cavity 1 is not the loop's own sensor, so its broadband floor is not suppressed.)"""
    harm, dec = np.arange(1, 49), 64
    show = (360, 720, 1080, 1440)

    def lines(kind, suf):
        v = amd.ram(OLD / "feedback" / f"{kind}_I{suf}") + 1j * amd.ram(OLD / "feedback" / f"{kind}_Q{suf}")
        v = v[: v.size // dec * dec].reshape(-1, dec).mean(1)
        t = np.arange(v.size) * dec / amd.FS
        rel = v / v.mean()
        A = np.column_stack([np.ones_like(t), t - t.mean()]
                            + [g(2 * np.pi * 60 * k * t) for k in harm for g in (np.cos, np.sin)])
        out = {}
        for tag, y in (("amp", np.abs(rel) - 1), ("ph", np.unwrap(np.angle(rel)))):
            c = np.linalg.lstsq(A, y, rcond=None)[0]
            out[tag] = dict(zip(60 * harm, np.hypot(c[2::2], c[3::2])))
            out[tag + "_floor"] = np.std(y - A @ c) * math.sqrt(2 / y.size)     # one tone's amplitude uncertainty
        return out

    data = {(kind, suf): lines(kind, suf) for suf in CONF.values() for kind in ("CAVITY", "DRIVE")}
    print("\n== HVPS lines, 2 June 2020: cavity-1 field and klystron drive (phase in mdeg, amplitude in 1e-4)")
    print("  configuration          | cavity phase " + " ".join(f"{f:>5d}" for f in show) + " | cavity amplitude "
          + " ".join(f"{f:>5d}" for f in show) + " | drive phase " + " ".join(f"{f:>5d}" for f in show)
          + " | drive amplitude " + " ".join(f"{f:>5d}" for f in show))
    for lab, suf in CONF.items():
        c, d = data[("CAVITY", suf)], data[("DRIVE", suf)]
        print(f"  {lab:22s} | {'':12s} " + " ".join(f"{c['ph'][f]*180e3/math.pi:5.0f}" for f in show)
              + f" | {'':16s} " + " ".join(f"{c['amp'][f]*1e4:5.1f}" for f in show)
              + f" | {'':11s} " + " ".join(f"{d['ph'][f]*180e3/math.pi:5.0f}" for f in show)
              + f" | {'':15s} " + " ".join(f"{d['amp'][f]*1e4:5.1f}" for f in show))
    print("  reduction of the cavity lines (dB, phase / amplitude):")
    for lab, a, b in (("direct loop alone", "DirectOffRippleOff", "DirectOnRippleOff"),
                      ("ripple loop alone", "DirectOffRippleOff", "DirectOffRippleOn"),
                      ("both loops", "DirectOffRippleOff", "AllOn"),
                      ("integral path (ripple on)", "DirectOnRippleOnIntegralOff", "AllOn")):
        ca, cb = data[("CAVITY", a)], data[("CAVITY", b)]
        print(f"    {lab:26s}" + "".join(f"  {f} Hz {20*math.log10(ca['ph'][f]/cb['ph'][f]):+5.1f}/{20*math.log10(ca['amp'][f]/cb['amp'][f]):+5.1f}"
                                         for f in show))
    # controller gain at the lines, direct loop alone: drive over cavity error, amplitude (relative) and phase (rad)
    # taken as the two quadratures of one error (an I/Q controller acts on both alike)
    c, d = data[("CAVITY", "DirectOnRippleOff")], data[("DRIVE", "DirectOnRippleOff")]
    fc, fd = math.hypot(c["amp_floor"], c["ph_floor"]), math.hypot(d["amp_floor"], d["ph_floor"])
    ff = [f for f in sorted(c["ph"]) if f >= 300 and math.hypot(c["amp"][f], c["ph"][f]) > 5 * fc
          and math.hypot(d["amp"][f], d["ph"][f]) > 5 * fd]
    ratio = np.array([math.hypot(d["amp"][f], d["ph"][f]) / math.hypot(c["amp"][f], c["ph"][f]) for f in ff])
    print(f"  direct loop alone, controller gain |u|/|e| at {len(ff)} lines of 0.3-2.9 kHz, divided by each network shape:")
    for lab, shape in (("lag network", lambda f: abs(1 + amd.LAG[0] / (amd.LAG[1] + 1j * f))),
                       ("ideal integrator, f_i 2.93 kHz", lambda f: abs(1 + amd.LAG[0] / (1j * f))),
                       ("proportional only", lambda f: 1.0)):
        lg = np.log(ratio / np.array([shape(f) for f in ff]))
        print(f"    {lab:31s}: G {math.exp(lg.mean()):.2f}, rms log residual {lg.std():.3f}")


def klystron_2013():
    print("\n== klystron transfer curves, 11 March 2013 (previous tube): s = d ln P_out / d ln P_drive at the top of each curve")
    for p in sorted((OLD / "klystron" / "gainCurves" / "20130311").glob("*.mat"), key=lambda q: (int(q.name[17:19]), q.name)):
        d = sio.loadmat(p, squeeze_me=True)["d"].astype(float)
        d[d == 0] = np.nan
        m = np.nanmean(d, axis=2)
        vk, pin, pout, cur = m[:, 0], m[:, 1], m[:, 2], m[:, 13]
        ok = np.isfinite(pin) & np.isfinite(pout)
        o = np.argsort(pin[ok])
        lp, lo = np.log(pin[ok][o]), np.log(pout[ok][o])
        n = max(3, lp.size // 3)
        top = np.polyfit(lp[-n:], lo[-n:], 1)[0] if np.ptp(lp[-n:]) > 0.02 else float("nan")
        print(f"  {np.nanmean(vk):5.1f} kV, {np.nanmean(cur) if np.isfinite(np.nanmean(cur)) else 0:4.0f} mA: drive {np.exp(lp[0]):5.1f}-{np.exp(lp[-1]):5.1f} W,"
              f" output {np.exp(lo[0]):4.0f}-{np.exp(lo[-1]):4.0f} kW, s {top:.2f}")


def fault_rfp(prefix, n):
    """RFP fault RAM (signal or cavity), oldest sample first; the low two bits of the first word give the mux."""
    parts = []
    for q in ("I", "Q"):
        w = np.frombuffer((TRIPS / f"{prefix}{q}_{n}").read_bytes()[16:], dtype=">i2").astype(np.int64)
        parts.append((int(w[0] & 3), np.fix(w / 16) / 2048))
    return parts[0][0], (parts[0][1] + 1j * parts[1][1])[::-1]


def fault_iqa(module, n):
    """IQA amplitude history (newest sample first in the file); the low three bits give the mux channel."""
    w = np.frombuffer((TRIPS / f"FAULTIqa{module}Amp_{n}").read_bytes()[21:], dtype=">u2").astype(np.int64)
    return int(w[0] & 7) + 1, (np.fix((w - 32768) / 16) / 2048)[::-1]


def klystron_from_fault_records(nseg=2048):
    """Klystron small-signal response from the normal operation before each trip (about 4.9 ms per record).

    s: klystron-output relative amplitude regressed on the drive's relative amplitude and phase (50-200 kHz,
       above the HVPS line harmonics).  kappa, s again: drive -> cavity-probe response, c = A a_d + B phi_d with
       A/B = kappa - j s for a memoryless klystron, whatever the cavity and beam (60-250 kHz)."""
    f = np.fft.fftfreq(nseg, 1 / amd.FS)
    w = np.hanning(nseg)

    def cross(sig):
        st = range(0, sig[0].size - nseg + 1, nseg // 2)
        X = np.array([[np.fft.fft(w * (s[i:i + nseg] - s[i:i + nseg].mean())) for i in st] for s in sig])
        return np.einsum("csf,dsf->cdf", X, np.conj(X)) / X.shape[1]

    def regress(S, lo, hi):
        h, coh = [], []
        for i in np.nonzero((np.abs(f) >= lo) & (np.abs(f) < hi))[0]:
            Syy, Sxy = S[1:, 1:, i], S[0, 1:, i]
            h.append(np.linalg.solve(Syy.T, Sxy))
            coh.append((Sxy @ np.linalg.solve(Syy, np.conj(Sxy))).real / S[0, 0, i].real)
        return np.array(h), np.median(coh), np.nonzero((np.abs(f) >= lo) & (np.abs(f) < hi))[0]

    print("\n== klystron small-signal response from the fault records (pre-trip normal operation)")
    print("  record  output (FS)  s (output/drive, 50-200 kHz) [coh]   kappa, s (drive->probe, 60-250 kHz) [coh]")
    res = []
    for n in range(1, 16):
        ms, drv = fault_rfp("FAULTRfpS", n)
        _, cav = fault_rfp("FAULTRfpC", n)
        mk, kly = fault_iqa(1, n)
        if ms != 3 or mk != 1 or np.median(np.abs(drv[:4000])) < 0.1 or np.median(kly[:4000]) < 0.1:
            continue
        end = drv.size - 5120                                    # stop before the trip
        for x in (np.abs(drv), kly, np.abs(cav)):
            blocks = np.array([x[i:i + 512].std() for i in range(0, x.size - 511, 512)])
            jump = np.nonzero(blocks > 4 * np.median(blocks))[0]
            if jump.size:
                end = min(end, int(jump[0]) * 512 - 512)
        d, c, k = drv[:end], cav[:end], kly[:end]
        a_d, p_d = np.abs(d) / abs(d.mean()) - 1, np.unwrap(np.angle(d / d.mean()))
        S1 = cross([k / k.mean() - 1, a_d, p_d])
        h1, c1, idx = regress(S1, 50e3, 200e3)
        s_out = np.median(np.abs(h1[:, 0]))          # magnitude: the inter-module delay only rotates the phase
        h2, c2, _ = regress(cross([c / c.mean() - 1, a_d.astype(complex), p_d.astype(complex)]), 60e3, 250e3)
        r = np.median((h2[:, 0] / h2[:, 1]).real), -np.median((h2[:, 0] / h2[:, 1]).imag)
        res.append((s_out, *r))
        print(f"  {n:4d}    {k.mean():.3f}       {s_out:.3f} [{c1:.2f}]                          {r[0]:+.2f}, {r[1]:.2f} [{c2:.2f}]")
    v = np.array(res)
    print(f"  s = {v[:, 0].mean():.2f} +- {v[:, 0].std(ddof=1):.2f} (output/drive); drive->probe: kappa {v[:, 1].mean():+.2f} +- "
          f"{v[:, 1].std(ddof=1):.2f}, s {v[:, 2].mean():.2f} (biased towards 1 by the loop's own correlation)")


def settings_2003():
    print("\n== saved direct-loop settings, SRF1 December 2003")
    for name in ("savedata.sav20031218", "savedata.savB"):
        lines = (OLD / "SRF1" / name).read_text(errors="replace").splitlines()
        keep = {l.split()[0].split(":")[-1]: l.split()[-1] for l in lines
                if l.startswith("SRF1:STNDIRECT:LOOP:") and l.split()[0].split(":")[-1] in ("COUNTS.A", "COUNTS.E", "PHASE.B", "PHASE.C")}
        print(f"  {name}: " + ", ".join(f"{k} {v}" for k, v in keep.items()))


if __name__ == "__main__":
    may2020_closed_loop()
    june2020_lines()
    klystron_2013()
    settings_2003()
    klystron_from_fault_records()
