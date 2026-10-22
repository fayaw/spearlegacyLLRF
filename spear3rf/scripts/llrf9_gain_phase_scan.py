"""Preliminary LLRF9 gain/phase scan at 500 mA with the spear3rf model.

Total loop delay is the open question: 270 ns is the LLRF9 internal figure; the legacy
MeasDirCls fit gives 621 ns for the whole loop, so the external path alone is likely
~0.5 us and an LLRF9 loop ~0.8 us.  All three are scanned.
"""
import math
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from spear3rf import Loop, RFSystem, beam_mode  # noqa: E402
from spear3rf.stability import loop_margins  # noqa: E402

BASE = RFSystem()
F_AMP = 2.5e6
print(f"radiation damping {BASE.ring.alpha_rad:.0f} 1/s, open-loop beam mode "
      f"{beam_mode(BASE).frequency:.0f} Hz / {beam_mode(BASE).damping:.0f} 1/s\n")

for tau in (270e-9, 620e-9, 800e-9):
    gmax = BASE.cavity.QL / (4 * BASE.ring.f_rf * tau)
    print(f"=== total delay {tau * 1e9:.0f} ns  (Gamp 45-deg gain limit {20 * math.log10(gmax):.1f} dB)")
    print(" G(dB) phase  f_coh(Hz) sigma(1/s)    Q   PM(deg) GM(dB) |1+L|@720Hz(dB)")
    for gdb in (0, 6, 10, 14, 18):
        for ph in (-20, 0, 20):
            lp = Loop(gain=10 ** (gdb / 20), phase_deg=ph, delay=tau, f_amp_hz=F_AMP)
            s = BASE.with_(loop=lp)
            m = beam_mode(s)
            mg = loop_margins(s)
            rej = 20 * math.log10(abs(1 + complex(s.open_loop(2j * math.pi * 720.0))))
            flag = "  <-- unstable" if mg.gain_margin_db < 0 or m.damping < 0 else ""
            print(f"{gdb:5d} {ph:+5d} {m.frequency:10.0f} {m.damping:10.0f} {m.Q:6.1f} "
                  f"{mg.phase_margin_deg:8.0f} {mg.gain_margin_db:6.1f} {rej:10.1f}{flag}")
    print()

print("=== integral path, P = 10 dB, delay 620 ns: corner fi with gi = gp")
print("  fi(Hz) phase_i  f_coh(Hz) sigma(1/s)  PM(deg) GM(dB) |1+L|@720Hz(dB)")
for fi in (300, 1000, 3000, 10000):
    for phi in (-45, 0, 45):
        g = 10 ** 0.5
        lp = Loop(gain=g, delay=620e-9, gi=g, fi_hz=fi, phase_i_deg=phi, f_amp_hz=F_AMP)
        s = BASE.with_(loop=lp)
        m = beam_mode(s)
        mg = loop_margins(s)
        rej = 20 * math.log10(abs(1 + complex(s.open_loop(2j * math.pi * 720.0))))
        print(f"{fi:8d} {phi:+6d} {m.frequency:10.0f} {m.damping:10.0f} "
              f"{mg.phase_margin_deg:8.0f} {mg.gain_margin_db:6.1f} {rej:10.1f}")
