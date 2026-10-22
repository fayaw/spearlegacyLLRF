import os
from pathlib import Path

import pytest

from spear3rf import live

SNAP = Path(__file__).parent / "data" / "SRF1_20261006T144832.json"


@pytest.fixture(scope="module")
def state():
    return live.analyze(live.Snapshot.load(SNAP))


def test_live_module_is_read_only():
    src = Path(live.__file__).read_text()
    for forbidden in ("caput", ".put(", "epics.PV(", "ca.put"):
        assert forbidden not in src


def test_snapshot_operating_point(state):
    assert state.I0 == pytest.approx(0.4965, abs=1e-3)
    assert state.V_total == pytest.approx(2.846e6, rel=2e-3)
    assert 1.0e6 < state.U0 < 1.2e6
    assert state.f_rf == pytest.approx(476.3e6)                   # fixture predates SPEAR:RFFreq
    assert 3.0 < state.cavity.beta < 4.5          # rules out beta 8.3 (Q_L 3447)
    assert all(-40e3 < df < -32e3 for df in state.df_physics)


def test_tracking_phase_reproduces_ioc(state):
    s = state.snapshot
    assert state.tracking_phase(s["direct_phase_J"] * 1e3) == pytest.approx(s["direct_phase_K"], abs=0.05)


def test_loop_gain_setting_matches_subiqampl(state):
    s = state.snapshot
    db = s["direct_counts_A"] + s["direct_counts_B"] + s["direct_counts_C"] + s["direct_counts_F"]
    assert state.loop_gain_setting == pytest.approx(10 ** (db / 20), rel=1e-6)


def test_report_and_checks(state):
    text = live.report(state)
    assert "CHECK" in text and "power balance" in text
    assert any("CAV3" in c for c in live.checks(state))


@pytest.mark.skipif(os.environ.get("SPEAR3RF_LIVE") != "1", reason="set SPEAR3RF_LIVE=1 to read EPICS")
def test_live_read():
    snap = live.read_snapshot(timeout=5.0)
    assert not [k for k in ("beam_current_mA", "stn_volt_kV", "direct_counts_L") if snap.get(k) is None]
