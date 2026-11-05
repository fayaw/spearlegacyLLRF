import math

import numpy as np
import pytest

from spear3rf import Loop, Quadrature, RFSystem, beam_mode, beam_variance, static_ratio
from spear3rf.stability import char_fn
from spear3rf.timedomain import simulate, simulate_noise

LAG = dict(gi=1.0, fi_hz=2929.0, f_leak_hz=260.0)


def p_loop(g_db, **kw):
    return Loop(gain=10 ** (g_db / 20), delay=625e-9, f_amp_hz=2.5e6, **kw)


@pytest.mark.parametrize("loop", [Loop(), p_loop(0), p_loop(15, phase_deg=20.0), p_loop(0, **LAG),
                                  p_loop(0, gi=1.0, fi_hz=1e3)])
def test_linear_klystron_reproduces_characteristic_equation(loop):
    sy = RFSystem(loop=loop)
    q = Quadrature(sy)
    for s in (complex(-1e3, 5e4), complex(2e3, -3e4), complex(0.0, 2 * math.pi * 8.8e3)):
        assert complex(q.char_fn(s)) == pytest.approx(complex(char_fn(sy, s)), rel=1e-12)
    assert q.mode().s == pytest.approx(beam_mode(sy).s, rel=1e-9)


@pytest.mark.parametrize("amp_gain, am_pm", [(0.75, 0.0), (1.0, 0.6), (0.40, 0.10)])
def test_klystron_anisotropy_matches_time_domain(amp_gain, am_pm):
    sy = RFSystem(I0=0.497, loop=Loop(gain=0.875, delay=625e-9, f_amp_hz=2.5e6, gi=0.875, fi_hz=2929.0,
                                      f_leak_hz=260.0))
    fd = Quadrature(sy, amp_gain, am_pm).mode()
    td = simulate(sy, t_end=6e-3, skip=0.5e-3, klystron_amp_gain=amp_gain, klystron_am_pm=am_pm).fit
    assert fd.frequency == pytest.approx(td.frequency, rel=3e-3)
    assert fd.damping == pytest.approx(td.damping, abs=0.02 * abs(td.damping) + 5.0)


def test_static_response_is_a_rigid_rotation():
    # without feedback the beam follows a klystron phase step exactly; with an integral path it
    # follows a reference step exactly (measurement noise enters with the opposite sign)
    f0 = np.array([1e-4])
    open_ = Quadrature(RFSystem()).response(f0)
    assert (open_.chi * open_.drive["klystron_PM"])[0] == pytest.approx(-1.0, abs=1e-6)
    integ = Quadrature(RFSystem(loop=p_loop(0, gi=1.0, fi_hz=1e3))).response(f0)
    assert (integ.chi * integ.drive["measurement_PM"])[0] == pytest.approx(1.0, abs=1e-6)
    assert abs((integ.chi * integ.drive["klystron_PM"])[0]) < 1e-6
    prop = RFSystem(loop=p_loop(0))
    assert Quadrature(prop).response(f0).chi[0] == pytest.approx(1.0 / static_ratio(prop), rel=1e-6)


def test_symmetric_loop_reduces_to_scalar_sensitivity():
    sy0 = RFSystem(detuning_hz=0.0)
    sy = sy0.with_(loop=p_loop(6))
    f = np.array([3e3, 8.8e3, 20e3])
    ro, rc = Quadrature(sy0).response(f), Quadrature(sy).response(f)
    for src in ("klystron_AM", "klystron_PM"):
        ratio = np.abs(rc.drive[src]) ** 2 / np.abs(ro.drive[src]) ** 2
        assert ratio == pytest.approx(1.0 / np.abs(1.0 + rc.open_loop) ** 2, rel=1e-9)


def test_resonant_variance_formula():
    for loop, tol in ((Loop(), 0.04), (p_loop(0), 0.015)):
        q = Quadrature(RFSystem(loop=loop))
        m = q.mode()
        sig, wc, ws = m.damping, m.s.imag, q.system.w_s
        var, _ = beam_variance(q, "klystron_PM")
        h2 = abs(q.response(np.array([wc / (2 * math.pi)])).drive["klystron_PM"][0]) ** 2
        assert var == pytest.approx(ws ** 4 * h2 / (8 * wc ** 2 * sig), rel=tol)


def test_time_domain_noise_agrees_with_quadrature():
    sy = RFSystem()
    q = Quadrature(sy)
    psd = 1e-10
    for which in ("AM", "PM"):
        var_td, _ = simulate_noise(sy, which, psd, t_end=0.08, seed=3)
        var_fd = psd * beam_variance(q, f"klystron_{which}")[0]
        assert var_td == pytest.approx(var_fd, rel=0.15)
