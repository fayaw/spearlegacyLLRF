"""Analyse a fsw_matrix.py capture: Lorentzian fit of each synchrotron sideband (log-space, robust
loss), line-harmonic levels at 3 Hz RBW, revolution harmonics and coupled-bunch sidebands.

usage: python scripts/fsw_matrix_analyze.py data/spectra/FSW_cavA_matrix_<start>.json outprefix
       (writes outprefix_near.png, outprefix_wide.png, outprefix_results.json)
"""
import json
import sys

import numpy as np
from scipy.optimize import least_squares

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

d = json.load(open(sys.argv[1], encoding="utf-8"))
pre = sys.argv[2]
res = {}


def axis(s):
    p = np.array(s["trace_dBm"])
    f = np.linspace(float(s["start_Hz"]), float(s["stop_Hz"]), p.size)
    return f, p


# ---------------------------------------------------------------- Robinson line
f, p = axis(d["setups"]["robinson"])
ic = np.argmax(p)
car, fcar = p[ic], f[ic]
off = f - fcar
rel = 10 ** ((p - car) / 10)


def lor(q, x):
    a, x0, g, b = q
    return a * g**2 / ((x - x0) ** 2 + g**2) + b


fits = {}
for side, sg in (("upper", 1), ("lower", -1)):
    m = (sg * off > 6000) & (sg * off < 9990)
    x, y = sg * off[m], rel[m]
    k = np.argmax(np.convolve(y, np.ones(51) / 51, mode="same"))
    q0 = np.array([y[k], x[k], 300.0, np.median(y[-200:])])
    sc = np.array([q0[0], 1, 1, q0[3]])
    r = least_squares(lambda qs: np.log(lor(qs * sc, x)) - np.log(y), q0 / sc, loss="soft_l1", f_scale=0.3,
                      bounds=([0, 6000, 20, 0], [np.inf, 9990, 3000, np.inf]))
    a, x0, g, b = r.x * sc
    fits[side] = dict(f_Hz=x0, hwhm_Hz=g, sigma=2 * np.pi * g, Q=x0 / (2 * g),
                      peak_dBc=10 * np.log10(a + b), floor_dBc=10 * np.log10(b), start_g=300.0)
    print(f"Robinson {side}: f {x0:.0f} Hz, HWHM {g:.0f} Hz, sigma {2 * np.pi * g:.0f}/s, Q {x0 / (2 * g):.1f}, "
          f"peak {10 * np.log10(a + b):.1f} dBc, floor {10 * np.log10(b):.1f} dBc")
res["robinson"] = fits
res["carrier_dBm_30Hz"] = float(car)

fig, ax = plt.subplots(2, 1, figsize=(10, 7.5))
ax[0].plot(off / 1e3, p - car, lw=0.6, color="k")
for side, sg in (("upper", 1), ("lower", -1)):
    r = fits[side]
    xx = np.linspace(6000, 9990, 300)
    a = 10 ** (r["peak_dBc"] / 10) - 10 ** (r["floor_dBc"] / 10)
    ax[0].plot(sg * xx / 1e3, 10 * np.log10(lor([a, r["f_Hz"], r["hwhm_Hz"], 10 ** (r["floor_dBc"] / 10)], xx)),
               color="tab:red", lw=1.4)
ax[0].set_title("Robinson line: 20 kHz span, RBW 30 Hz, RMS, 100 power averages")
ax[0].set_xlabel("offset (kHz)")
ax[0].set_ylabel("dBc")
ax[0].set_ylim(-110, 5)
ax[0].grid(alpha=0.3)

# ---------------------------------------------------------------- line harmonics
f, p = axis(d["setups"]["lines"])
ic = np.argmax(p)
off = f - f[ic]
car3 = p[ic]
lines = {}
for k in range(1, 19):
    for sg in (1, -1):
        m = np.abs(off - sg * 60 * k) <= 2.0
        if m.any():
            lines[sg * 60 * k] = float(p[m].max() - car3)
res["lines_dBc_3Hz"] = lines
floor3 = float(np.median(p[(np.abs(off) > 100)]) - car3)
res["median_floor_dBc_3Hz"] = floor3
print("line harmonics (RBW 3 Hz): " + ", ".join(f"{k:+d}: {v:.1f}" for k, v in sorted(lines.items(), key=lambda t: abs(t[0]))[:14]))
print(f"median level beyond 100 Hz: {floor3:.1f} dBc in 3 Hz")
ax[1].plot(off, p - car3, lw=0.6, color="k")
for k in range(1, 19):
    for sg in (1, -1):
        ax[1].axvline(sg * 60 * k, color="tab:blue", lw=0.4, alpha=0.3)
ax[1].set_title("Line harmonics: 2.2 kHz span, RBW 3 Hz, RMS, 20 power averages (blue: n x 60 Hz)")
ax[1].set_xlabel("offset (Hz)")
ax[1].set_ylabel("dBc")
ax[1].set_ylim(-110, 5)
ax[1].grid(alpha=0.3)
fig.tight_layout()
fig.savefig(pre + "_near.png", dpi=110)

# ---------------------------------------------------------------- wide span
f, p = axis(d["setups"]["wide"])
ic = np.argmax(p)
off = f - f[ic]
carw = p[ic]
frev = 476.3039e6 / 372
fig, ax = plt.subplots(figsize=(10, 4.2))
ax.plot(off / 1e3, p - carw, lw=0.6, color="k")
for sg in (1, -1):
    ax.axvline(sg * frev / 1e3, color="tab:blue", lw=0.6, alpha=0.5)
ax.set_title("Wide span: 3 MHz, RBW 1 kHz, RMS, 50 power averages (blue: f_rev)")
ax.set_xlabel("offset (kHz)")
ax.set_ylabel("dBc")
ax.grid(alpha=0.3)
fig.tight_layout()
fig.savefig(pre + "_wide.png", dpi=110)
for sg in (1, -1):
    m = np.abs(off - sg * frev) <= 3e3
    res[f"rev_harmonic_{'+' if sg > 0 else '-'}_dBc"] = float(p[m].max() - carw)
    for n_s in (1, -1):
        m2 = np.abs(off - (sg * frev + n_s * 8.8e3)) <= 1.5e3
        res[f"rev{'+' if sg > 0 else '-'}_sync{'+' if n_s > 0 else '-'}_dBc"] = float(p[m2].max() - carw)
band = {}
for lo_, hi_ in ((20e3, 50e3), (50e3, 100e3), (100e3, 200e3), (200e3, 400e3), (400e3, 600e3), (600e3, 1.0e6)):
    for sg, tag in ((1, "+"), (-1, "-")):
        m = (sg * off >= lo_) & (sg * off < hi_)
        band[f"{tag}{lo_/1e3:.0f}-{hi_/1e3:.0f}kHz"] = float(np.median(p[m]) - carw)
res["wide_median_dBc_1kHz"] = band
print("wide: rev harmonics", {k: round(v, 1) for k, v in res.items() if k.startswith("rev")})
print("wide: median level by band (dBc in 1 kHz):", {k: round(v, 1) for k, v in band.items()})
json.dump(res, open(pre + "_results.json", "w"), indent=1)
