"""Read-only view of the live SPEAR3 legacy RF station (EPICS Channel Access).

Only ``epics.caget_many`` is ever called: this module cannot write a PV.  A
``Snapshot`` can be saved to JSON so every analysis can be re-run offline.

PV names are those of the legacy IOC databases in spear-rf-code-legacy/rfApp/Db
(station SRF1, cavities CAV1..CAV4; IQA records "<C><Q>:POWER|AMPL|PHASE").
"""
from __future__ import annotations

import json
import math
from dataclasses import dataclass, field, replace
from datetime import datetime
from pathlib import Path

import numpy as np

from .params import Cavity, Loop, Ring
from .system import RFSystem

STATION = "SRF1"
N_CAV = 4

# MeasDirCls on cavity A (Oct 2026), read as a closed-loop resonance: open-loop gain
# 0.957 with COUNTS.A = 0.9 dB, total delay 621 ns, loop phase within ~1 deg of ideal.
MEASDIRCLS_GAIN = 0.957
MEASDIRCLS_COUNTS_DB = 0.9
MEASDIRCLS_DELAY = 621e-9

# Legacy system, 500 mA, cavity-A probe spectrum (llrf/tests/llrf9Tests.tex, 2021): f [Hz], Q
MEASURED_2021_LEGACY = (8932.0, 11.1)


def legacy_pv_names(station: str = STATION) -> dict[str, str]:
    s = station
    pv = {
        "f_rf_MHz": "SPEAR:RFFreq",
        "state": f"{s}:STN:STATE:STRING",
        "beam_current_mA": f"{s}:STN:BEAM:CURR",
        "stn_volt_kV": f"{s}:STN:VOLT",
        "stn_volt_set_kV": f"{s}:STN:VOLT:CTRL",
        "kly_fwd_kW": f"{s}:KLYSOUTFRWD:POWER",
        "kly_fwd_max_kW": f"{s}:KLYSOUTFRWD:POWER:MAX",
        "kly_refl_kW": f"{s}:KLYSOUTREFL:POWER",
        "kly_drive_W": f"{s}:KLYSDRIVFRWD:POWER",
        "kly_drive_set_W": f"{s}:KLYSDRIVFRWD:POWER:ON",
        "kly_drive_sat_W": f"{s}:KLYSDRIVFRWD:POWER:SAT",
        "kly_gain_dB": f"{s}:KLYS:GAIN",
        "kly_eff_pct": f"{s}:KLYS:EFFICIENCY",
        "hvps_kV": f"{s}:HVPS:VOLT",
        "hvps_A": f"{s}:HVPS:CURR",
        "circ_load_kW": f"{s}:CIRCLDFRWD:POWER",
        "wg01_load_kW": f"{s}:WG01LDFRWD:POWER",
        "wg02_load_kW": f"{s}:WG02LDFRWD:POWER",
        "wg03_load_kW": f"{s}:WG03LDFRWD:POWER",
        "direct_on": f"{s}:STNDIRECT:LOOP:CTRL",
        "direct_track": f"{s}:STNDIRECT:LOOP:TRACK",
        "intcomp": f"{s}:STNDIRECT:INTCOMP:CTRL",
        "leadcomp": f"{s}:STNDIRECT:LEADCOMP:CTRL",
        "intcomp_rfp": f"{s}:STN:RFP:INTCOMP",
        "leadcomp_rfp": f"{s}:STN:RFP:LEADCOMP",
        "comb_on": f"{s}:STNCOMB:LOOP:CTRL",
        "rfp_ripple": f"{s}:STN:RFP:RIPPLELOOP",
        "rfp_analog_ripple": f"{s}:STN:RFP:ARIPPLELOOP",
        "rfp_fbsig": f"{s}:STN:RFP:FBSIG",
        "ripple_dc_coef": f"{s}:STNRIPPLE:LOOP:AMPL",
        "gff_on": f"{s}:STN:GFF:CTRL",
        "lfb_on": f"{s}:STN:LFB:CTRL",
        "ripple_track": f"{s}:STNRIPPLE:LOOP:TRACK",
        "tuner_loop_on": f"{s}:CAVTUNR:LOOP:CTRL",
        "load_angle_offset_on": f"{s}:CAVLOAD:ANGLE:CTRL",
        "cav_freq_offs_avg_kHz": f"{s}:CAV:FREQ:OFFS",
        "direct_counts": f"{s}:STNDIRECT:LOOP:COUNTS",
        "direct_phase_deg": f"{s}:STNDIRECT:LOOP:PHASE",
    }
    for f in "ABCDEFGHIJKL":
        pv[f"direct_counts_{f}"] = f"{s}:STNDIRECT:LOOP:COUNTS.{f}"
        pv[f"direct_phase_{f}"] = f"{s}:STNDIRECT:LOOP:PHASE.{f}"
    for n in range(1, N_CAV + 1):
        c = f"{s}:CAV{n}"
        pv.update({
            f"cav{n}_volt_kV": f"{c}PROBE:AMPL",
            f"cav{n}_probe_phase_deg": f"{c}PROBE:PHASE",
            f"cav{n}_fwd_kW": f"{c}FRWD:POWER",
            f"cav{n}_fwd_phase_deg": f"{c}FRWD:PHASE",
            f"cav{n}_refl_kW": f"{c}REFL:POWER",
            f"cav{n}_freq_offs_kHz": f"{c}:FREQ:OFFS",
            f"cav{n}_vswr": f"{c}:CPLG:FACTOR",
            f"cav{n}_beta_model": f"{c}:BETA:CTRL",
            f"cav{n}_q0_model": f"{c}:Q0:CTRL",
            f"cav{n}_load_angle_err_deg": f"{c}LOAD:ANGLE:ERR",
            f"cav{n}_tuner_mm": f"{c}TUNR:STEP:MOTOR.RBV",
        })
    return pv


def _plain(v):
    if v is None or isinstance(v, str):
        return v
    try:
        return float(v)
    except (TypeError, ValueError):
        return str(v)


@dataclass
class Snapshot:
    time: str
    station: str
    values: dict
    pvs: dict = field(default_factory=dict)

    def __getitem__(self, key):
        return self.values[key]

    def get(self, key, default=None):
        v = self.values.get(key)
        return default if v is None else v

    @property
    def missing(self) -> list[str]:
        return [k for k, v in self.values.items() if v is None]

    def save(self, path) -> Path:
        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(self.__dict__, indent=1))
        return path

    @classmethod
    def load(cls, path) -> "Snapshot":
        return cls(**json.loads(Path(path).read_text()))


def read_snapshot(station: str = STATION, timeout: float = 3.0) -> Snapshot:
    """caget every PV of ``legacy_pv_names`` (read-only)."""
    import epics

    pvs = legacy_pv_names(station)
    keys = list(pvs)
    vals = epics.caget_many([pvs[k] for k in keys], timeout=timeout)
    return Snapshot(datetime.now().isoformat(timespec="seconds"), station,
                    {k: _plain(v) for k, v in zip(keys, vals)}, pvs)


@dataclass(frozen=True)
class LegacyState:
    """Operating point derived from a snapshot; SI units unless stated."""

    snapshot: Snapshot
    cavity: Cavity
    I0: float
    f_rf: float                   # SPEAR:RFFreq, nominal if not in the snapshot
    V: np.ndarray                 # probe gap voltages
    P_fwd: np.ndarray
    P_refl: np.ndarray
    P_wall: np.ndarray            # V^2 / (2 R_s) with the IOC's Q0
    P_beam: np.ndarray            # P_fwd - P_refl - P_wall
    phi: np.ndarray               # beam phase from crest per cavity, cos = P_beam/(I0 V)
    beta: np.ndarray              # coupling from VSWR, assuming reactive compensation
    df_physics: np.ndarray        # reactive-compensation detuning per cavity [Hz]
    df_poly: np.ndarray           # IOC tuner-polynomial estimate (FREQ:OFFS) [Hz]

    @property
    def V_total(self) -> float:
        return float(self.V.sum())

    @property
    def U0(self) -> float:
        """Energy loss per turn from the power balance (dipole + ID radiation) [eV]."""
        return float(self.P_beam.sum() / self.I0)

    @property
    def gamma2(self) -> np.ndarray:
        return self.P_refl / self.P_fwd

    @property
    def loop_gain_setting(self) -> float:
        """Dimensionless direct-loop amplitude 10^((A+B+C+F)/20) (subIQampl output L)."""
        return float(self.snapshot["direct_counts_L"])

    def tracking_phase(self, avg_df_hz: float) -> float:
        """subSysPhaseTot delta: K = -0.00036 * B[ns] * J[kHz] * F [deg]."""
        s = self.snapshot
        return -0.00036 * s["direct_phase_B"] * (avg_df_hz / 1e3) * s["direct_phase_F"]

    def legacy_loop(self, gain_ref: float = MEASDIRCLS_GAIN, counts_db_ref: float = MEASDIRCLS_COUNTS_DB,
                    delay: float = MEASDIRCLS_DELAY, **kw) -> Loop:
        """Proportional loop scaled from the MeasDirCls reference by the live COUNTS.L.

        Integral and lead compensation are hardware networks whose parameters are not in
        the repository; pass gi/fi_hz/lead_hz explicitly to study them.
        """
        gain = gain_ref * self.loop_gain_setting / 10 ** (counts_db_ref / 20)
        return Loop(gain=gain, delay=delay, f_amp_hz=kw.pop("f_amp_hz", 2.5e6), **kw)

    def to_system(self, loop: Loop | None = None, measured_U0: bool = True,
                  detuning: str = "physics") -> RFSystem:
        """Model of this operating point at the live RF frequency."""
        ring = replace(Ring(), f_rf=self.f_rf, **({"U0_eV": self.U0} if measured_U0 else {}))
        df = self.df_physics if detuning == "physics" else self.df_poly
        return RFSystem(ring=ring, cavity=self.cavity, loop=loop or Loop(), n_cav=len(self.V),
                        V_total=self.V_total, I0=self.I0, detuning_hz=tuple(df))


def analyze(snap: Snapshot, R_over_Q: float = 116.6) -> LegacyState:
    """Derive the operating point; beta assumes over-coupling and reactive compensation."""
    n = list(range(1, N_CAV + 1))
    arr = lambda key, scale: np.array([snap[f"cav{i}_{key}"] * scale for i in n], float)
    V, P_fwd, P_refl = arr("volt_kV", 1e3), arr("fwd_kW", 1e3), arr("refl_kW", 1e3)
    q0 = float(np.mean(arr("q0_model", 1.0)))
    beta_model = float(np.mean(arr("beta_model", 1.0)))
    I0 = snap["beam_current_mA"] / 1e3
    f_rf = snap.get("f_rf_MHz", Ring().f_rf / 1e6) * 1e6
    Rs = R_over_Q * q0
    P_wall = V ** 2 / (2 * Rs)
    P_beam = P_fwd - P_refl - P_wall
    g = np.sqrt(np.clip(P_refl / P_fwd, 0, 0.99))
    vswr = (1 + g) / (1 - g)
    a = P_beam / P_wall
    beta = np.where(vswr * (1 + a) > 1, vswr * (1 + a), beta_model)
    if I0 > 5e-3:
        phi = np.arccos(np.clip(P_beam / (I0 * V), -1, 1))
        df_phys = -R_over_Q * 2 * I0 * np.sin(phi) * f_rf / (2 * V)
    else:
        phi, df_phys = np.full(len(n), np.nan), np.zeros(len(n))
    df_poly = arr("freq_offs_kHz", 1e3)
    cav = Cavity(R_over_Q=R_over_Q, Q0=q0, beta=float(np.median(beta)) if I0 > 5e-3 else beta_model)
    return LegacyState(snap, cav, I0, f_rf, V, P_fwd, P_refl, P_wall, P_beam, phi, beta, df_phys, df_poly)


def checks(st: LegacyState) -> list[str]:
    """Consistency findings worth an operator's attention."""
    s = st.snapshot
    out = []
    if s.get("intcomp") or s.get("leadcomp"):
        out.append("Direct loop: integral compensation %s, lead compensation %s (RFP readback %s/%s). "
                   "Their analog networks are not documented in the repository; model predictions "
                   "below are proportional-only." % ("ON" if s.get("intcomp") else "off",
                                                     "ON" if s.get("leadcomp") else "off",
                                                     s.get("intcomp_rfp"), s.get("leadcomp_rfp")))
    if s.get("direct_track"):
        k_now = s["direct_phase_K"]
        k_phys = st.tracking_phase(float(np.mean(st.df_physics)))
        out.append(f"Frequency-offset tracking is ON (PS-340-330-52: diagnostic, normally off). It rotates "
                   f"the loop phase by K = {k_now:+.1f} deg from avg FREQ:OFFS {s['direct_phase_J']:.1f} kHz; "
                   f"the physics detuning would give {k_phys:+.1f} deg ({k_now - k_phys:+.1f} deg excess).")
    for i, (dp, dk, g2) in enumerate(zip(st.df_poly, st.df_physics, st.gamma2), start=1):
        if abs(dp - dk) > max(10e3, 0.25 * abs(dk)) and g2 < 0.05:
            out.append(f"CAV{i}: tuner-polynomial FREQ:OFFS {dp / 1e3:.1f} kHz contradicts the measured "
                       f"reflection {g2 * 100:.1f} % (reactive-compensation detuning {dk / 1e3:.1f} kHz): "
                       f"polynomial calibration stale.")
    sum_fwd, kly = st.P_fwd.sum() / 1e3, s.get("kly_fwd_kW", 0.0)
    if kly and sum_fwd > kly:
        out.append(f"Power calibration: sum of cavity forward {sum_fwd:.0f} kW exceeds klystron forward "
                   f"{kly:.0f} kW by {100 * (sum_fwd / kly - 1):.1f} %.")
    pmax = s.get("kly_fwd_max_kW")
    if pmax and kly > 0.9 * pmax:
        out.append(f"Klystron forward {kly:.0f} kW is {100 * kly / pmax:.0f} % of KLYSOUTFRWD:POWER:MAX "
                   f"({pmax:.0f} kW).")
    if s.get("rfp_ripple") == 0.0:
        out.append("DSP ripple loop is OFF: line-harmonic klystron phase ripple (60-2880 Hz) is not cancelled.")
    for i in range(1, N_CAV + 1):
        e = s.get(f"cav{i}_load_angle_err_deg")
        if e is not None and abs(e) > 2.0:
            out.append(f"CAV{i}: load-angle error {e:.1f} deg (tuner not converged).")
    return out


def report(st: LegacyState, loop: Loop | None = None) -> str:
    """Plain-text performance summary of the live operating point."""
    from .stability import beam_mode, loop_margins, static_ratio

    s = st.snapshot
    lines = [f"SPEAR3 RF {s.station} snapshot {s.time}: {s.get('state')}",
             f"  beam {st.I0 * 1e3:.1f} mA, station {st.V_total / 1e3:.0f} kV "
             f"(set {s.get('stn_volt_set_kV', float('nan')):.0f}), klystron {s.get('kly_fwd_kW', 0):.0f} kW, "
             f"drive {s.get('kly_drive_W', 0):.1f} W (sat {s.get('kly_drive_sat_W', 0):.0f}), "
             f"HVPS {s.get('hvps_kV', 0):.1f} kV {s.get('hvps_A', 0):.1f} A",
             "  cav   V(kV)  Pfwd  Prefl |G|^2(%) Pwall Pbeam(kW) phi_s(deg) beta  df_phys df_poly(kHz)"]
    for i in range(len(st.V)):
        lines.append(f"  {i + 1:3d} {st.V[i] / 1e3:7.1f} {st.P_fwd[i] / 1e3:6.1f} {st.P_refl[i] / 1e3:5.2f} "
                     f"{100 * st.gamma2[i]:6.2f} {st.P_wall[i] / 1e3:6.1f} {st.P_beam[i] / 1e3:7.1f} "
                     f"{math.degrees(st.phi[i]):9.1f} {st.beta[i]:5.2f} {st.df_physics[i] / 1e3:8.1f} "
                     f"{st.df_poly[i] / 1e3:8.1f}")
    lines.append(f"  f_RF {st.f_rf / 1e6:.6f} MHz; energy loss per turn (power balance, dipoles + IDs): "
                 f"{st.U0 / 1e6:.3f} MeV; coupling from VSWR: beta {st.cavity.beta:.2f}, Q_L {st.cavity.QL:.0f}")
    hv, ha, pk = s.get("hvps_kV", 0.0), s.get("hvps_A", 0.0), s.get("kly_fwd_kW", 0.0)
    if hv and ha:
        lines.append(f"  klystron: perveance {ha / (hv * 1e3) ** 1.5 * 1e6:.3f} uA/V^1.5, efficiency "
                     f"{100 * pk / (hv * ha):.1f} %, drive {10 * math.log10(s.get('kly_drive_sat_W', 1) / max(s.get('kly_drive_W', 1), 1e-9)):.1f} dB "
                     f"below the SAT setting")
    lines.append(f"  direct loop: on={s.get('direct_on')} track={s.get('direct_track')} "
                 f"int={s.get('intcomp')} lead={s.get('leadcomp')} gain A={s.get('direct_counts_A')} dB "
                 f"-> L={st.loop_gain_setting:.3f}, total phase "
                 f"{s.get('direct_phase_L', s.get('direct_phase_deg', 0)):.1f} deg = C {s.get('direct_phase_C')} "
                 f"+ K {s.get('direct_phase_K', 0):+.1f} (VAL {s.get('direct_phase_deg', 0):.1f}, 0.5 deg "
                 f"monitor deadband), "
                 f"group delay {s.get('direct_phase_B', 0):.0f} ns")
    lines.append(f"  RFP: DSP ripple loop={s.get('rfp_ripple')} (phase cancellers 60-2880 Hz; analog "
                 f"{s.get('rfp_analog_ripple')}, DC coef {s.get('ripple_dc_coef', float('nan')):.3f}); "
                 f"comb and gap feed-forward modules not installed")
    f21, q21 = MEASURED_2021_LEGACY
    lines.append(f"  measured (2021, legacy, 500 mA): coherent {f21:.0f} Hz, damping {math.pi * f21 / q21:.0f} 1/s (Q {q21})")
    loop = loop or st.legacy_loop()
    for tag, lp in (("no direct loop", Loop()), (f"P-only legacy model (G={loop.gain:.2f})", loop)):
        sys_ = st.to_system(loop=lp)
        m = beam_mode(sys_)
        lines.append(f"  model, {tag}: f_s incoherent {sys_.w_s / 2 / math.pi:.0f} Hz, coherent "
                     f"{m.frequency:.0f} Hz, damping {m.damping:.0f} 1/s (Q {m.Q:.1f}), "
                     f"static ratio {static_ratio(sys_):.2f}")
    sys_ = st.to_system(loop=loop)
    mg = loop_margins(sys_)
    lmax = float(np.max(np.abs(sys_.open_loop(2j * np.pi * np.linspace(-2e6, 2e6, 40001)))))
    pm = f"{mg.phase_margin_deg:.0f} deg" if lmax > 1.05 else f"n/a (max|L| {lmax:.2f})"
    lines.append(f"  P-only loop margins: phase {pm}, gain {mg.gain_margin_db:.1f} dB, "
                 f"min|1+L| {mg.modulus_margin:.2f}; radiation damping {sys_.ring.alpha_rad:.0f} 1/s")
    cb = beam_mode(sys_, mu=-1)
    lines.append(f"  coupled-bunch mu=-1 (fundamental impedance): net damping {cb.damping:.0f} 1/s, "
                 f"cavity-driven growth {sys_.ring.alpha_rad - cb.damping:+.1f} 1/s")
    lines += ["  CHECK: " + c for c in checks(st)]
    return "\n".join(lines)
