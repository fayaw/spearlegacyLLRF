"""Does a fixed integral-path phase stay safe as the beam current (load angle) changes?

P = 10 dB, I corner 3 kHz (gi = gp), delay 620 ns.  The low-frequency loop phase is
rotated by the cavity load angle psi_L(I), so a fixed phase_i is compared with one
scheduled as phase_i = -psi_L (this package's sign convention).
"""
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from spear3rf import Loop, RFSystem, beam_mode  # noqa: E402

g = 10 ** 0.5
print("  I(mA)  psi_L(deg) | sigma: P only | I at 0 deg | I at +45 deg | I at -psi_L  (1/s)")
for I0 in (0.02, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6):
    base = RFSystem(I0=I0)
    psi = math.degrees(math.atan(base.tan_psi_L[0]))
    row = []
    for ph in (None, 0.0, 45.0, -psi):
        lp = (Loop(gain=g, delay=620e-9, f_amp_hz=2.5e6) if ph is None else
              Loop(gain=g, delay=620e-9, gi=g, fi_hz=3e3, phase_i_deg=ph, f_amp_hz=2.5e6))
        row.append(beam_mode(base.with_(loop=lp)).damping)
    print(f"{I0 * 1e3:7.0f} {psi:10.1f}  | " + " | ".join(f"{x:10.0f}" for x in row))
print(f"radiation damping alone: {RFSystem().ring.alpha_rad:.0f} 1/s")
