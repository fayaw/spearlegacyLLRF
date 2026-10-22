import math

import numpy as np
import pytest

from spear3rf import Loop, RFSystem, beam_mode, sideband_estimate
from spear3rf.stability import char_fn, count_rhp_zeros, loop_margins, pedersen_quartic
from spear3rf.timedomain import simulate


def test_open_loop_equals_pedersen_quartic():
    s = RFSystem()
    roots = np.roots(pedersen_quartic(s))
    beam = beam_mode(s).s
    assert np.min(np.abs(roots - beam)) < 1e-7 * abs(beam)
    for r in roots:
        assert abs(complex(char_fn(s, r))) < 1e-6 * abs(r) ** 2


def test_low_current_damping_matches_wilson_6_2_1():
    s = RFSystem(I0=0.02)
    xi, eta = -s.tan_psi_L[0], s.w_s / s.w_half
    wilson = (s.Y * s.w_s / math.sin(s.phi_s) * xi * eta
              / ((1 + (xi + eta) ** 2) * (1 + (xi - eta) ** 2)))
    robinson = beam_mode(s).damping - s.ring.alpha_rad
    assert robinson == pytest.approx(wilson, rel=0.02)
    assert sideband_estimate(s).damping - s.ring.alpha_rad == pytest.approx(wilson, rel=1e-3)


def test_cavity_above_rf_is_robinson_unstable():
    assert beam_mode(RFSystem(detuning_hz=20e3)).damping < 0


@pytest.mark.parametrize("loop", [
    Loop(),
    Loop(gain=2.0, phase_deg=40.0, delay=270e-9),
    Loop(gain=1.0, delay=500e-9, gi=1.0, fi_hz=30e3),
    Loop(gain=3.0, delay=270e-9, f_amp_hz=2.5e6),
])
def test_time_domain_agrees_with_characteristic_equation(loop):
    s = RFSystem(loop=loop)
    m = beam_mode(s)
    td = simulate(s, t_end=min(8e-3, 10.0 / abs(m.damping)), dt=5e-9).fit
    assert td.frequency == pytest.approx(m.frequency, rel=2e-3)
    assert td.damping == pytest.approx(m.damping, rel=0.01)


def test_klystron_anisotropy_acts_only_through_the_loop():
    open_loop = RFSystem()
    ref = simulate(open_loop).fit
    assert simulate(open_loop, klystron_amp_gain=0.3, klystron_am_pm=1.0).fit.s == pytest.approx(ref.s, rel=1e-9)
    closed = RFSystem(loop=Loop(gain=1.0, delay=625e-9, f_amp_hz=2.5e6))
    iso = simulate(closed).fit
    assert simulate(closed, klystron_amp_gain=1.0, klystron_am_pm=0.0).fit.s == pytest.approx(iso.s, rel=1e-9)
    # an amplitude path weaker than the phase path leaves more of the open-loop (detuned-cavity) damping
    assert simulate(closed, klystron_amp_gain=0.5).fit.damping > iso.damping


def test_rhp_zero_count_flags_integrator_instability():
    stable = RFSystem(loop=Loop(gain=2.0, delay=270e-9))
    unstable = RFSystem(loop=Loop(gain=1.0, delay=500e-9, gi=1.0, fi_hz=30e3))
    assert count_rhp_zeros(lambda z: char_fn(stable, z)) == 0
    assert count_rhp_zeros(lambda z: char_fn(unstable, z)) == 2
    assert beam_mode(unstable).damping < 0


def test_phase_margin_of_tuned_cavity_loop():
    g, tau = 10.0, 270e-9
    s = RFSystem(I0=1e-9, detuning_hz=0.0, loop=Loop(gain=g, delay=tau))
    wc = s.w_half * math.sqrt(g * g - 1)
    pm = 180 - math.degrees(math.atan(wc / s.w_half) + wc * tau)
    assert loop_margins(s).phase_margin_deg == pytest.approx(pm, abs=0.2)


def test_gamp_max_gain_rule():
    # Gamp CAS 2011 eq. (62): A_F,max = Q_L / (4 f tau) puts 45 deg of delay phase at crossover
    tau = 270e-9
    s0 = RFSystem(I0=1e-9, detuning_hz=0.0)
    g = s0.cavity.QL / (4 * s0.ring.f_rf * tau)
    m = loop_margins(s0.with_(loop=Loop(gain=g, delay=tau)))
    wc = 2 * math.pi * max(m.crossovers_hz)
    assert math.degrees(wc * tau) == pytest.approx(45.0, abs=0.5)
    assert m.phase_margin_deg == pytest.approx(90 - math.degrees(math.atan(wc / s0.w_half)) + 45, abs=0.2)
