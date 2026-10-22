"""Interpret the legacy MeasDirCls fit (cavity A, Oct 2026) with the spear3rf model.

Reported by the MATLAB routine:  gain 0.489 V/V, Q 3447, f_c 476.3025 MHz,
delay 621 ns, phase -179 deg at peak / f_c / f_rf.  Live PVs: STNDIRECT:LOOP:COUNTS.A
= 0.9 (dB, subIQampl), STNDIRECT:LOOP:PHASE.C = -20 deg (subSysPhaseTot).

The routine's source is not in the repository, so the reported pair (gain, Q) is
tested under three readings and each is confronted with the 2021 beam measurement
(llrf/tests/llrf9Tests.tex: legacy synchrotron peak 8931.5 Hz, Q 11.14 at 500 mA).
"""
import math
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from spear3rf import Cavity, Loop, RFSystem, Ring, beam_mode  # noqa: E402
from spear3rf.fitting import closed_loop_response, fit_loop_response  # noqa: E402
from spear3rf.stability import loop_margins, static_ratio  # noqa: E402

G_REP, Q_REP, TAU_REP = 0.489, 3447.0, 621e-9
F2021, Q2021 = 8931.5, 11.14
SIG2021 = math.pi * F2021 / Q2021
Q0 = 32000.0

readings = {
    "H1 open-loop fit (G, Q_L as printed)": (G_REP, Q_REP),
    "H2 closed-loop resonance, peak = G/(1+G)": (G_REP / (1 - G_REP), Q_REP / (1 - G_REP)),
    "H3 closed-loop resonance, peak = 1/(1+G)": (1 / G_REP - 1, Q_REP / G_REP),
}

print(f"2021 legacy beam measurement: f = {F2021:.1f} Hz, Q = {Q2021}, sigma = {SIG2021:.0f} 1/s")
print(f"gain setting COUNTS.A = 0.9 dB -> 10^(0.9/20) = {10 ** (0.9 / 20):.3f} (offsets B, C, F unknown)\n")
for name, (G, QL) in readings.items():
    beta = Q0 / QL - 1
    print(f"{name}: G = {G:.3f} ({20 * math.log10(G):+.1f} dB), Q_L = {QL:.0f}, beta = {beta:.2f}")
    cav = Cavity(beta=beta)
    for ac in (1.18e-3, 1.10e-3):
        for ph in (-1.0, 1.0):
            s = RFSystem(ring=Ring(alpha_c=ac), cavity=cav, loop=Loop(gain=G, phase_deg=ph, delay=TAU_REP))
            m = beam_mode(s)
            print(f"   alpha_c={ac:.2e} phase err {ph:+.0f} deg: f_coh = {m.frequency:7.0f} Hz, "
                  f"sigma = {m.damping:6.0f} 1/s, Q = {m.Q:5.1f}   (f_s incoh {s.w_s / 2 / math.pi:.0f})")
    s = RFSystem(cavity=cav)
    print(f"   coupler |Gamma|^2 at 500 mA (tuned): {s.reflection()[0] * 100:.1f} %, "
          f"P_fwd/cav = {(s.P_wall + s.P_beam_per_cav) / (1 - s.reflection()[0]) / 1e3:.0f} kW\n")

print("Synthetic check: what does a single resonator+delay fit return for a closed loop?")
f = np.concatenate([-np.linspace(250e3, 200, 400), np.linspace(200, 250e3, 400)])
for tau in (400e-9, 500e-9, 621e-9):
    H = closed_loop_response(f, 0.957, 6746.0, 0.0, tau, 0.0, kind="T")
    fit = fit_loop_response(f, H, kind=None, p0=(0.5, 3500.0, 0.0, tau, 0.0))
    print(f"   true G 0.957, Q_L 6746, tau {tau * 1e9:.0f} ns -> fitted gain {fit['gain']:.3f}, "
          f"Q {fit['q_loaded']:.0f}, delay {fit['delay'] * 1e9:.0f} ns, f_r {fit['f_res']:.0f} Hz")

print("\nLoop margins of the H2 legacy loop (tau 621 ns, f_amp 2.5 MHz):")
for I0 in (1e-6, 0.5):
    s = RFSystem(I0=I0, cavity=Cavity(beta=Q0 / 6746 - 1),
                 loop=Loop(gain=0.957, delay=TAU_REP, f_amp_hz=2.5e6))
    m = loop_margins(s)
    print(f"   I = {I0 * 1e3:5.0f} mA: PM {m.phase_margin_deg:.0f} deg, GM {m.gain_margin_db:.1f} dB, "
          f"min|1+L| {m.modulus_margin:.2f}, static ratio {static_ratio(s):.2f}")
s0 = RFSystem(I0=1e-6, detuning_hz=0.0, cavity=Cavity(beta=Q0 / 6746 - 1))
print(f"   Gamp max gain Q_L/(4 f tau) = {6746 / (4 * s0.ring.f_rf * TAU_REP):.2f} "
      f"({20 * math.log10(6746 / (4 * s0.ring.f_rf * TAU_REP)):.1f} dB)")
