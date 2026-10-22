import math

import numpy as np
import pytest

from spear3rf import RFSystem, Ring, static_ratio


def test_reproduces_doc_p_steady_state():
    s = RFSystem()
    assert math.degrees(s.phi_s) == pytest.approx(67.51, abs=0.02)
    assert s.optimum_detuning_hz() == pytest.approx(-36.0e3, rel=2e-3)
    assert math.degrees(math.atan(s.tan_psi_L[0])) == pytest.approx(-45.35, abs=0.05)
    assert s.P_wall == pytest.approx(68.0e3, rel=0.01)
    assert s.P_beam_per_cav == pytest.approx(136.25e3, rel=1e-9)
    assert s.reflection()[0] == pytest.approx(0.0131, abs=0.0005)
    assert s.w_s / (2 * math.pi) == pytest.approx(10.03e3, rel=2e-3)


def test_radiation_damping_includes_insertion_devices():
    bare = Ring(U0_eV=0.912e6)
    assert 2 * bare.energy_eV * bare.T_rev / (bare.J_s * bare.U0_eV) == pytest.approx(2.87e-3, rel=2e-3)
    assert 1 / Ring().alpha_rad == pytest.approx(2.36e-3, rel=2e-3)


def test_detuning_is_linear_in_current():
    s = RFSystem()
    assert s.optimum_detuning_hz(0.1) * 5 == pytest.approx(s.optimum_detuning_hz(0.5))


def test_static_ratio_matches_wilson_6_1_2():
    # Wilson SLAC-PUB-6062 eq. (6.1.1) at the reactive-compensation detuning
    for I0 in (0.1, 0.5, 1.0):
        s = RFSystem(I0=I0)
        yc, ys = s.Y * math.cos(s.phi_s), s.Y * math.sin(s.phi_s)
        assert static_ratio(s) == pytest.approx((1 - yc ** 2) / (1 + ys ** 2), rel=1e-9)


def test_high_current_limit_current():
    s = RFSystem()
    i_lim = s.V_cav / (2 * s.cavity.RL * math.cos(s.phi_s))
    assert static_ratio(s.with_(I0=i_lim)) == pytest.approx(0.0, abs=1e-9)
    assert i_lim == pytest.approx(1.193, abs=0.002)


def test_impedance_normalisation():
    s = RFSystem(detuning_hz=0.0)
    assert complex(s.z_total(0.0)) == pytest.approx(4 * s.cavity.RL)
    assert np.allclose(s.vector_sum_weights, 0.25)
