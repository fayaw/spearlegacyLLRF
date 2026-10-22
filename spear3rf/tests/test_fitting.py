import numpy as np
import pytest

from spear3rf.fitting import (closed_loop_response, fit_loop_response, fit_lorentzian_db,
                              lorentzian_db, open_loop_response, resonator_through_loop)

F = np.concatenate([-np.logspace(2, np.log10(3e5), 200)[::-1], np.logspace(2, np.log10(3e5), 200)])
TRUTH = dict(gain=0.95, q_loaded=6700.0, f_res=-2.7e3, delay=620e-9, phase_deg=1.0)


def test_open_loop_fit_round_trip():
    fit = fit_loop_response(F, open_loop_response(F, **TRUTH))
    for k, v in TRUTH.items():
        assert fit[k] == pytest.approx(v, rel=1e-6, abs=1e-6)


def test_closed_loop_fit_round_trip():
    fit = fit_loop_response(F, closed_loop_response(F, **TRUTH, kind="T"), kind="T")
    for k, v in TRUTH.items():
        assert fit[k] == pytest.approx(v, rel=1e-6, abs=1e-6)


def test_resonator_through_loop():
    peak, q = resonator_through_loop(0.957, 6746.0)
    assert peak == pytest.approx(0.489, abs=5e-4)
    assert q == pytest.approx(3447, rel=1e-3)


def test_lorentzian_round_trip():
    f = np.linspace(7e3, 11e3, 801)
    truth = (8931.5, 11.14, -92.8, -112.0)
    fit = fit_lorentzian_db(f, lorentzian_db(f, *truth), p0=(9.2e3, 8.0, -95.0, -110.0))
    assert fit["f0"] == pytest.approx(truth[0], rel=1e-6)
    assert fit["q"] == pytest.approx(truth[1], rel=1e-5)
