"""Shared model and analysis helpers for the SPEAR3 direct-loop optimization study (Studies/optLLRF).

The physics lives in the spear3rf package (repository root, spear3rf/src): RFSystem (beam
loading, cavity impedances, the field loop), stability (characteristic equation, coherent
modes), quadrature (two-quadrature model: klystron amplitude/phase anisotropy and the noise
drive of the dipole mode), timedomain (independent simulation).  Doc P sections 8.1 and
8.7-8.10 and Appendix C give the equations.  This module only fixes the station models the
study compares and the primitives that the prediction and analysis scripts share.

Models (see MODELS):
  eff   linear klystron and a shared-phase integral path with the effective 1 kHz corner; it
        reproduces the measured damping at 500 mA (Doc P, tab:robinson-today)
  lag   the installed RFP lag network (corner 2.93 kHz, leak 0.26 kHz) with the klystron measured
        in normal operation (amplitude gain 0.40, AM/PM 0.10 rad); it also reproduces 500 mA
  prop  proportional loop only, linear klystron (reference)
The two realistic models agree at 500 mA and differ at 100-350 mA: the study measures which
one describes the station.
"""
from __future__ import annotations

import json
import math
import sys
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
STUDY = HERE.parents[1]                 # Studies/optLLRF
ROOT = HERE.parents[3]                  # repository root
RESULTS = STUDY / "results"
sys.path.insert(0, str(ROOT / "spear3rf" / "src"))

from spear3rf import live  # noqa: E402
from spear3rf.params import Loop  # noqa: E402
from spear3rf.quadrature import Quadrature, frequency_grid, sidebands  # noqa: E402
from spear3rf.stability import count_rhp_zeros  # noqa: E402
from spear3rf.system import RFSystem  # noqa: E402

TAU_LEGACY = 625e-9                     # total loop delay, measured (Doc P sec:delay-budget)
F_AMP = 2.5e6                           # drive amplifier + klystron, one pole
LAG_ZERO = 1 / (2 * math.pi * 499 * 0.1e-6)            # RFP lag network (RFgui loop models), 3.19 kHz
LAG_POLE = 1 / (2 * math.pi * (499 + 5620) * 0.1e-6)   # 0.26 kHz
F_I_EFF = 1.0e3                         # effective integral corner that reproduces the 500 mA damping
COUNTS_NOW_DB = 1.3                     # COUNTS.A in operation (Oct 2026)
G_NOW = 1.0                             # loop gain at COUNTS.A = 1.3 dB: the scale of Doc P's 500 mA tables
                                        # (MeasDirCls reference 0.957 at 0.9 dB); fits allow 0.9-1.4
KLY_MEASURED = (0.40, 0.10)             # klystron amplitude gain g_A and AM/PM k_AP, normal operation
ENBW = 1.065                            # noise bandwidth of the FSW resolution filter / RBW
SOURCES = ("klystron_PM", "klystron_AM", "measurement_PM", "measurement_AM")
SOURCE_LABEL = {"klystron_PM": "klystron output, phase", "klystron_AM": "klystron output, amplitude",
                "measurement_PM": "measurement or reference, phase",
                "measurement_AM": "measurement or reference, amplitude"}
MODELS = {
    "eff": "linear klystron, shared-phase integral path, effective corner 1 kHz",
    "lag": "installed lag network, klystron g_A 0.40 and k_AP 0.10 (normal operation)",
    "prop": "proportional loop only, linear klystron",
}
_trapz = getattr(np, "trapezoid", None) or np.trapz


# ----------------------------------------------------------------------------- models
def loop_gain(counts_db: float) -> float:
    """Direct-loop gain for a COUNTS.A setting (dB steps of COUNTS.A scale the gain in dB)."""
    return G_NOW * 10 ** ((counts_db - COUNTS_NOW_DB) / 20)


def make_loop(model: str, counts_db: float = COUNTS_NOW_DB, theta_deg: float = 0.0,
              delay: float = TAU_LEGACY) -> Loop:
    """Direct loop of ``model``; the integral path shares the loop phase, as in the legacy RFP."""
    g = loop_gain(counts_db)
    kw = dict(gain=g, phase_deg=theta_deg, delay=delay, f_amp_hz=F_AMP)
    if model == "eff":
        kw.update(gi=g, fi_hz=F_I_EFF, phase_i_deg=theta_deg)
    elif model == "lag":
        kw.update(gi=g, fi_hz=LAG_ZERO - LAG_POLE, f_leak_hz=LAG_POLE, phase_i_deg=theta_deg)
    elif model != "prop":
        raise ValueError(f"unknown model {model!r}; known: {', '.join(MODELS)}")
    return Loop(**kw)


def klystron(model: str, amp_gain: float | None = None, am_pm: float | None = None) -> tuple[float, float]:
    base = KLY_MEASURED if model == "lag" else (1.0, 0.0)
    return (base[0] if amp_gain is None else amp_gain, base[1] if am_pm is None else am_pm)


def station(I_mA: float, model: str = "eff", counts_db: float = COUNTS_NOW_DB, theta_deg: float = 0.0,
            detune_frac: float = 1.0, V_MV: float = 2.85, amp_gain: float | None = None,
            am_pm: float | None = None) -> Quadrature:
    """Station at I_mA with the tuners at ``detune_frac`` of the optimum detuning (Doc P eq:df-opt)."""
    s0 = RFSystem(I0=I_mA / 1e3, V_total=V_MV * 1e6)
    sy = s0.with_(detuning_hz=s0.optimum_detuning_hz() * detune_frac,
                  loop=make_loop(model, counts_db, theta_deg))
    return Quadrature(sy, *klystron(model, amp_gain, am_pm))


def station_from_snapshot(snapshot, model: str = "eff", counts_db: float | None = None,
                          theta_deg: float = 0.0, amp_gain: float | None = None,
                          am_pm: float | None = None) -> Quadrature:
    """Station at a recorded operating point (spear3rf.live snapshot: current, voltages, detuning).

    The loop gain follows the snapshot's COUNTS.A unless ``counts_db`` is given."""
    snap = snapshot if isinstance(snapshot, live.Snapshot) else live.Snapshot.load(snapshot)
    st = live.analyze(snap)
    if counts_db is None:
        counts_db = snap.get("direct_counts_A", COUNTS_NOW_DB)
    sy = st.to_system(loop=make_loop(model, float(counts_db), theta_deg))
    return Quadrature(sy, *klystron(model, amp_gain, am_pm))


def mode_or_none(q: Quadrature):
    """Coherent mode, or None where the field loop itself is unstable or the root tracking fails."""
    sy = q.system
    if sy.loop.active and count_rhp_zeros(lambda z: 1.0 + sy.open_loop(z)):
        return None
    try:
        return q.mode()
    except RuntimeError:
        return None


def jitter(q: Quadrature, f: np.ndarray | None = None) -> dict:
    """Beam jitter per unit one-sided white spectral density of each source.

    Returns {source: (<dphi^2>, <(dE/E0)^2>)}; phase sources in rad^2/Hz, amplitude sources in
    1/Hz of relative amplitude, so both entries have the unit Hz."""
    f = frequency_grid() if f is None else f
    r = q.response(f)
    ring = q.system.ring
    w2 = (2 * np.pi * f / (ring.alpha_c * ring.w_rf)) ** 2
    out = {}
    for src in SOURCES:
        y = np.abs(r.chi * r.drive[src]) ** 2
        out[src] = (float(_trapz(y, f)), float(_trapz(y * w2, f)))
    return out


def drive_at(q: Quadrature, f_hz: float) -> dict:
    """|h_x(j 2 pi f)|^2: spectral density of the drive n_eff per unit spectral density of each source."""
    r = q.response(np.array([f_hz]))
    return {src: float(abs(r.drive[src][0]) ** 2) for src in SOURCES}


def chi_at(q: Quadrature, f_hz: float) -> float:
    """|chi| = |w_s^2 / D0| at f_hz: beam phase per unit drive (Doc P eq:rob-response)."""
    return float(abs(q.response(np.array([f_hz])).chi[0]))


def probe_power_per_rad2(q: Quadrature, f_hz: float) -> tuple[float, float]:
    """Power in the upper and lower sideband of the probed cavity, relative to its carrier, per rad^2
    of beam phase variance at f_hz: P_+-/P_c = factor * <dphi^2> (Doc P eq:rob-line-area)."""
    r = q.response(np.array([f_hz]))
    usb, lsb = sidebands(r.beam_to_probe)
    va2 = abs(q.V_k0[q.probe]) ** 2
    return float(usb[0] / (2 * va2)), float(lsb[0] / (2 * va2))


def drive_from_variance(q: Quadrature, f_coh: float, sigma: float, var_phi: float) -> float:
    """Invert Doc P eq:rob-var: drive spectral density S_n(f_coh) that produces var_phi."""
    return 8 * (2 * math.pi * f_coh) ** 2 * sigma * var_phi / q.system.w_s ** 4


# ----------------------------------------------------------------------------- spectra
def load_fsw(path, setup: str = "robinson") -> dict:
    """Swept FSW record (spear3rf/scripts/fsw_matrix.py format, or the older single-trace format).

    Returns offsets from the carrier [Hz], level [dBc/Hz] (valid for noise with the RMS detector),
    the trace in dBc per resolution bandwidth (valid for discrete lines), the RBW and metadata."""
    d = json.load(open(path, encoding="utf-8"))
    if "setups" in d:
        s = d["setups"][setup]
        tr = np.array(s["trace_dBm"], float)
        f = np.linspace(float(s["start_Hz"]), float(s["stop_Hz"]), tr.size)
        rbw, det = float(s["rbw_Hz"]), s.get("detector", "")
    else:
        tr = np.array(d["trace_avg_dBm"], float)
        f = np.linspace(float(d["start_Hz"]), float(d["stop_Hz"]), tr.size)
        rbw, det = float(d["rbw_Hz"]), d.get("detector", "")
    ic = int(np.argmax(tr))
    rel = tr - tr[ic]
    meta = {k: v for k, v in d.items() if k not in ("setups", "trace_avg_dBm")}
    return dict(off=f - f[ic], dbc_rbw=rel, dbc_hz=rel - 10 * math.log10(rbw * ENBW), rbw=rbw,
                detector=det, carrier_dBm=float(tr[ic]), meta=meta)


def line_mask(off: np.ndarray, rbw: float, spacing: float = 60.0) -> np.ndarray:
    """True away from the n x 60 Hz harmonics: drops bins within 0.6 RBW of a line, which keeps the
    bins between lines even when the RBW is half the line spacing."""
    return np.abs(np.abs(off) - spacing * np.round(np.abs(off) / spacing)) > max(0.6 * rbw, 4.0)


def lorentz_fit(off: np.ndarray, dbc_hz: np.ndarray, side: int, rbw: float, window=(6000.0, 9990.0),
                mask_lines: bool = True, floor_dbc_hz: float | None = None) -> dict:
    """Robust Lorentzian plus a flat floor, fitted in log space to one synchrotron sideband.

    side = +1 (upper) or -1 (lower).  With mask_lines the n x 60 Hz harmonics are excluded and the
    result describes the broadband part of the line.  ``floor_dbc_hz`` holds the floor (for a
    refit within a few HWHM of a first fit).  Returns f [Hz], HWHM [Hz], sigma [1/s], Q, peak and
    floor [dBc/Hz] and the broadband line power ``area`` relative to the carrier."""
    from scipy.optimize import least_squares

    x = side * off
    m = (x > window[0]) & (x < window[1])
    if mask_lines:
        m &= line_mask(off, rbw)
    x, y = x[m], 10 ** (dbc_hz[m] / 10)
    k = int(np.argmax(np.convolve(y, np.ones(51) / 51, mode="same")))
    q0 = np.array([y[k], x[k], 200.0, np.median(np.sort(y)[: max(10, y.size // 5)])])
    fixed = floor_dbc_hz is not None
    if fixed:
        q0 = np.array([max(y[k] - 10 ** (floor_dbc_hz / 10), 1e-30), x[k], 200.0, 10 ** (floor_dbc_hz / 10)])
    sc = np.array([q0[0], 1.0, 1.0, q0[3]])
    n = 3 if fixed else 4

    def lor(p, xx):
        a, x0, g = p[:3]
        b = q0[3] if fixed else p[3]
        return a * g ** 2 / ((xx - x0) ** 2 + g ** 2) + b

    r = least_squares(lambda p: np.log(lor(p * sc[:n], x)) - np.log(y), q0[:n] / sc[:n], loss="soft_l1",
                      f_scale=0.3, bounds=([0, window[0], 10, 0][:n], [np.inf, window[1], 3000, np.inf][:n]))
    a, x0, g = (r.x * sc[:n])[:3]
    b = q0[3] if fixed else r.x[3] * sc[3]
    return dict(f=float(x0), hwhm=float(g), sigma=float(2 * math.pi * g), Q=float(x0 / (2 * g)),
                peak_dbc_hz=float(10 * math.log10(a + b)), floor_dbc_hz=float(10 * math.log10(b)),
                area=float(math.pi * g * a), area_dbc=float(10 * math.log10(math.pi * g * a)))


def line_cross_checks(off: np.ndarray, dbc_hz: np.ndarray, rbw: float, fits: dict, k: float = 3.0) -> dict:
    """Pole of each sideband from a Lorentzian refitted within +/- k HWHM (floor held) and from the
    Fano profile over 6-10 kHz.  The probe line is a pure Lorentzian only for some sources, so the
    spread of the three fits measures the systematic error of sigma and f_coh."""
    out = {}
    for s in (+1, -1):
        f0, g0 = fits[s]["f"], fits[s]["hwhm"]
        nar = lorentz_fit(off, dbc_hz, s, rbw, window=(f0 - k * g0, f0 + k * g0),
                          floor_dbc_hz=fits[s]["floor_dbc_hz"])
        x = s * off
        m = line_mask(off, rbw) & (x > 6000.0) & (x < 9990.0)
        start = dict(f=f0, hwhm=g0, peak=10 ** (fits[s]["peak_dbc_hz"] / 10), floor=10 ** (fits[s]["floor_dbc_hz"] / 10))
        fano = fano_fit(x[m], 10 ** (dbc_hz[m] / 10), start)
        out[s] = dict(narrow=nar, fano=fano)
    return out


def find_lines(off: np.ndarray, dbc_rbw: np.ndarray, fmin: float, fmax: float,
               min_excess_db: float = 3.0, spacing: float = 60.0) -> list[dict]:
    """Discrete lines on the n x spacing grid between |offset| fmin and fmax (both sidebands).

    A line's power is the peak of the RBW trace [dBc]; its excess is over a running median of the
    trace over 240 Hz (the local floor, including any broadband synchrotron line)."""
    from scipy.ndimage import median_filter

    df = off[1] - off[0]
    base = median_filter(dbc_rbw, size=max(21, int(round(240.0 / df)) | 1), mode="nearest")
    half = max(1, int(round(2.0 / df)))
    out = []
    for i in range(half, off.size - half):
        a = abs(off[i])
        n = round(a / spacing)
        if not (fmin <= a <= fmax) or abs(a - n * spacing) > max(2.0, df):
            continue
        if dbc_rbw[i] < dbc_rbw[i - half:i + half + 1].max() or dbc_rbw[i] - base[i] < min_excess_db:
            continue
        out.append(dict(offset=float(off[i]), harmonic=int(n), power_dbc=float(dbc_rbw[i]),
                        excess_db=float(dbc_rbw[i] - base[i])))
    return out


SNAPSHOTS = ROOT / "spear3rf" / "data" / "snapshots"


def beam_share(q: Quadrature, f_hz: float, side: int, src: str) -> float:
    """Fraction of the probe sideband power at f_hz that is the beam's response to source ``src``
    (beam motion and field modulation add coherently, so the fraction can exceed one)."""
    r = q.response(np.array([f_hz]))
    beam = r.beam_to_probe * (r.chi * r.drive[src])[:, None]
    ub, lb = sidebands(beam)
    ut, lt = sidebands(r.probe[src] + beam)
    return float((ub / ut)[0] if side > 0 else (lb / lt)[0])


def resolve_snapshot(name) -> Path | None:
    if not name:
        return None
    p = Path(name)
    for cand in (p, SNAPSHOTS / p.name, SNAPSHOTS / f"{p.name}.json"):
        if cand.is_file():
            return cand
    return None


def analyze_capture(capture, snapshot=None, models=("eff", "lag"), fmin: float = 2000.0,
                    fmax: float = 9990.0, beam_dominated: float = 0.5) -> dict:
    """Beam motion from one swept cavity-probe capture (Doc P eq:rob-line-area, sec:robinson-legacy).

    * broadband line: Lorentzian fit per sideband with the n x 60 Hz harmonics masked; the pole is
      cross-checked by a Lorentzian within +/- 3 HWHM and by the Fano profile (``checks``)
    * discrete lines: every n x 60 Hz line between fmin and fmax
    * per model (at the snapshot's operating point): the probe conversion factor, the beam share
      of each line (klystron AM and PM hypotheses), the beam phase of the broadband line and of the
      lines whose beam share exceeds ``beam_dominated`` under both hypotheses, the energy motion
      and the broadband drive S_n(f_coh) implied by eq:rob-var.
    The snapshot defaults to the capture's paired EPICS snapshot."""
    capture = Path(capture)
    d = load_fsw(capture)
    off, dbc_hz, dbc_rbw, rbw = d["off"], d["dbc_hz"], d["dbc_rbw"], d["rbw"]
    fits = {s: lorentz_fit(off, dbc_hz, s, rbw) for s in (+1, -1)}
    f_coh = 0.5 * (fits[1]["f"] + fits[-1]["f"])
    sigma = 0.5 * (fits[1]["sigma"] + fits[-1]["sigma"])
    lines = find_lines(off, dbc_rbw, fmin, fmax)
    snap = resolve_snapshot(snapshot or d["meta"].get("paired_epics_snapshot", ""))
    out = dict(capture=capture.name, snapshot=snap.name if snap else None, detector=d["detector"], rbw=rbw,
               fits=fits, checks=line_cross_checks(off, dbc_hz, rbw, fits), f_coh=f_coh, sigma=sigma,
               Q=math.pi * f_coh / sigma, lines=lines, models={})
    if snap is None:
        return out
    floor = sum(10 ** (fits[s]["floor_dbc_hz"] / 10) for s in (+1, -1))
    for m in models:
        q = station_from_snapshot(snap, m)
        ring = q.system.ring
        acw = ring.alpha_c * ring.w_rf
        var_bb = sum(0.5 * fits[s]["area"] / probe_power_per_rad2(q, fits[s]["f"])[0 if s > 0 else 1]
                     for s in (+1, -1))
        var_ln, var_e = 0.0, var_bb * (2 * math.pi * f_coh / acw) ** 2
        per_line = []
        for ln in lines:
            side = 1 if ln["offset"] > 0 else -1
            fl = abs(ln["offset"])
            sh = (beam_share(q, fl, side, "klystron_AM"), beam_share(q, fl, side, "klystron_PM"))
            fac = probe_power_per_rad2(q, fl)[0 if side > 0 else 1]
            v = 10 ** (ln["power_dbc"] / 10) * min(sh) / fac
            dominated = min(sh) > beam_dominated
            if dominated:
                var_ln += v
                var_e += v * (2 * math.pi * fl / acw) ** 2
            per_line.append(dict(offset=ln["offset"], share_AM=sh[0], share_PM=sh[1],
                                 dphi_deg=math.degrees(math.sqrt(v)), beam_dominated=dominated))
        mo = mode_or_none(q)
        out["models"][m] = dict(
            var_broadband=var_bb, var_lines=var_ln, var_total=var_bb + var_ln,
            dphi_broadband_deg=math.degrees(math.sqrt(var_bb)), dphi_lines_deg=math.degrees(math.sqrt(var_ln)),
            dphi_total_deg=math.degrees(math.sqrt(var_bb + var_ln)),
            timing_total_ps=math.sqrt(var_bb + var_ln) / ring.w_rf * 1e12, dE_total=math.sqrt(var_e),
            S_n_broadband=drive_from_variance(q, f_coh, sigma, var_bb),
            S_n_floor=floor / (2 * math.sin(q.system.phi_s) ** 2),
            model_f_coh=mo.frequency if mo else float("nan"), model_sigma=mo.damping if mo else float("nan"),
            lines=per_line)
    return out


def fano_fit(x: np.ndarray, S: np.ndarray, start: dict, window=(6000.0, 9990.0)) -> dict:
    """Asymmetric (Fano) line for one sideband: S = |p + r/(x - x0 + i g)|^2 + b.

    Near f_coh a probe sideband is the coherent sum of the field noise (p) and the beam's resonant
    response (pole at x0 + i g), so the line is a Fano profile rather than a Lorentzian whenever the
    two are comparable.  ``start`` is a Lorentzian fit (lorentz_fit-style dict, linear units
    a = peak - floor, b = floor) used to initialize."""
    from scipy.optimize import least_squares

    m = (x > window[0]) & (x < window[1])
    x, y = x[m], S[m]
    b0, g0, x00 = start["floor"], start["hwhm"], start["f"]
    a0 = max(start["peak"] - b0, b0)
    p0 = np.array([0.3 * math.sqrt(b0), math.sqrt(a0) * g0, 0.0, x00, g0, 0.9 * b0])
    sc = np.array([math.sqrt(b0), math.sqrt(a0) * g0, math.sqrt(a0) * g0, 1.0, 1.0, b0])

    def model(par, xx):
        p, rr, ri, x0, g, b = par
        return np.abs(p + (rr + 1j * ri) / (xx - x0 + 1j * g)) ** 2 + b

    r = least_squares(lambda q: np.log(model(q * sc, x)) - np.log(y), p0 / sc, loss="soft_l1", f_scale=0.3,
                      bounds=([0, -np.inf, -np.inf, window[0], 5, 0], [np.inf, np.inf, np.inf, window[1], 3000, np.inf]))
    p, rr, ri, x0, g, b = r.x * sc
    return dict(f=float(x0), hwhm=float(g), sigma=float(2 * math.pi * g), Q=float(x0 / (2 * g)),
                asymmetry=float(math.atan2(ri, rr)), direct=float(p ** 2), floor=float(b))


def save_csv(path: Path, header: list[str], rows: list[list]) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(",".join(header) + "\n")
        for r in rows:
            fh.write(",".join(_fmt(v) for v in r) + "\n")
    return path


def _fmt(v) -> str:
    if isinstance(v, str):
        return v
    if v is None or (isinstance(v, float) and not math.isfinite(v)):
        return "nan"
    return f"{v:.6g}"
