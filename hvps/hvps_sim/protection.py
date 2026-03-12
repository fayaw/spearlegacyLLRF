"""
Protection System Models
========================

Models the 4-layer SPEAR3 HVPS arc protection system:

    Layer 1: Primary current limiting via filter inductors (L1, L2)
    Layer 2: Crowbar SCR activation (~1 µs fiber-optic trigger)
    Layer 3: Primary thyristor turn-off (4-8 ms)
    Layer 4: Cable termination inductors (L3, L4) limit discharge current

Also models safety interlocks:
    - Transformer interlocks (pressure, vacuum, temperature, oil)
    - AC/DC power interlocks
    - Overcurrent/overvoltage protection
    - Emergency off

Reference documents:
    - 06-safety-interlock-systems.md
    - 00-spear3-hvps-legacy-system-design.md
    - 01-pepii-power-supply-architecture.md
"""

import numpy as np
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Optional, List

from hvps.hvps_sim.config import HVPSConfig


class FaultType(Enum):
    """Types of faults in the HVPS system."""
    NONE = auto()
    KLYSTRON_ARC = auto()
    OVERVOLTAGE = auto()
    OVERCURRENT = auto()
    AC_OVERCURRENT = auto()
    TRANSFORMER_PRESSURE = auto()
    TRANSFORMER_VACUUM = auto()
    TRANSFORMER_OVERTEMP = auto()
    TRANSFORMER_LOW_OIL = auto()
    TRANSFORMER_SUDDEN_PRESSURE = auto()
    PHASE_LOSS = auto()
    WATER_FLOW = auto()
    EMERGENCY_OFF = auto()
    CROWBAR_FAULT = auto()


class ProtectionState(Enum):
    """Protection system operating state."""
    NORMAL = auto()
    ARC_DETECTED = auto()
    CROWBAR_FIRING = auto()
    THYRISTOR_TURNOFF = auto()
    RECOVERING = auto()
    TRIPPED = auto()
    LOCKOUT = auto()


@dataclass
class ProtectionStatus:
    """Complete protection system status snapshot."""
    time: float = 0.0
    state: ProtectionState = ProtectionState.NORMAL
    fault_type: FaultType = FaultType.NONE
    crowbar_active: bool = False
    crowbar_enabled: bool = False
    thyristors_inhibited: bool = False
    arc_energy_j: float = 0.0
    fault_current_a: float = 0.0
    recovery_time_remaining_s: float = 0.0
    # Interlock statuses
    transformer_ok: bool = True
    ac_power_ok: bool = True
    cooling_ok: bool = True
    all_interlocks_ok: bool = True
    # Latch bits (match PLC B3:4 register)
    latch_crowbar: bool = False         # B3:4/10
    latch_pressure: bool = False        # B3:4/0
    latch_vacuum: bool = False          # B3:5/12
    latch_overtemp: bool = False        # B3:4/1
    latch_low_oil: bool = False         # B3:4/3
    latch_sudden_pressure: bool = False # B3:4/4
    latch_ac_overcurrent: bool = False  # B3:4/11
    latch_overvoltage: bool = False     # B3:4/12
    # Temperatures
    temp_phase_upper_c: float = 25.0
    temp_phase_lower_c: float = 25.0
    temp_crowbar_c: float = 25.0
    temp_cabinet_c: float = 25.0


class CrowbarSystem:
    """Crowbar SCR protection (SCR13-16).

    4 series-connected SCR stacks with fiber-optic trigger:
        - Voltage rating: 100 kV
        - Current rating: 80 A per stack
        - Trigger delay: ~1 µs (fiber-optic)
        - Enable timer: 8 seconds (T4:12)

    When triggered, shorts the HVPS output to rapidly dump stored
    energy and protect the klystron from arc damage.

    Energy delivered during arc: <5 J (with crowbar), <20 J (without).
    """

    def __init__(self, config: HVPSConfig):
        self.cfg = config.crowbar
        self.trigger_delay = self.cfg.trigger_delay_us * 1e-6
        self.enable_timer = self.cfg.enable_timer_s

        self._enabled = False
        self._firing = False
        self._fire_time = 0.0
        self._enable_time = 0.0
        self._energy_dumped = 0.0

    @property
    def is_enabled(self) -> bool:
        return self._enabled

    @property
    def is_firing(self) -> bool:
        return self._firing

    @property
    def energy_dumped(self) -> float:
        return self._energy_dumped

    def enable(self, t: float):
        """Enable crowbar circuit (after contactor close)."""
        self._enabled = True
        self._enable_time = t

    def disable(self):
        """Disable crowbar circuit."""
        self._enabled = False
        self._firing = False

    def trigger(self, t: float):
        """Fire the crowbar SCRs.

        Parameters
        ----------
        t : float
            Time of trigger initiation.
        """
        if self._enabled:
            self._firing = True
            self._fire_time = t
            self._energy_dumped = 0.0

    def update(self, t: float, v_output: float, i_output: float,
               dt: float) -> bool:
        """Update crowbar state.

        Parameters
        ----------
        t : float
            Current time.
        v_output : float
            HVPS output voltage magnitude (V).
        i_output : float
            HVPS output current (A).
        dt : float
            Time step.

        Returns
        -------
        bool
            True if crowbar is actively shorting the output.
        """
        if self._firing:
            # After trigger delay, crowbar conducts
            if t - self._fire_time >= self.trigger_delay:
                self._energy_dumped += abs(v_output * i_output) * dt
                return True

            # Check enable timer (auto-disable after 8 seconds)
            if t - self._fire_time > self.enable_timer:
                self._firing = False
                self._enabled = False

        return False

    def get_crowbar_impedance(self, t: float) -> float:
        """Get effective crowbar impedance.

        Returns low impedance when firing (active short), high when off.
        """
        if self._firing and (t - self._fire_time >= self.trigger_delay):
            return 0.5  # Very low impedance when conducting (Ω)
        return 1e9  # Effectively open circuit

    def reset(self):
        """Reset crowbar to initial state."""
        self._enabled = False
        self._firing = False
        self._energy_dumped = 0.0


class ArcDetector:
    """Arc detection system.

    Monitors voltage and current for arc signatures:
        - Sudden voltage drop (dV/dt threshold)
        - Current spike
        - Voltage/current ratio change

    Response: triggers crowbar within ~1 µs.
    """

    def __init__(self, config: HVPSConfig):
        self.cfg = config
        # Detection thresholds
        self.dv_dt_threshold = 1e9       # V/s (fast voltage drop)
        self.voltage_drop_pct = 20.0     # % sudden drop triggers arc detect
        self.current_spike_factor = 2.0  # Current doubles = arc

        self._v_prev = 0.0
        self._i_prev = 0.0
        self._arc_detected = False

    def check(self, v_output: float, i_output: float, dt: float) -> bool:
        """Check for arc conditions.

        Parameters
        ----------
        v_output : float
            Output voltage magnitude (V).
        i_output : float
            Output current (A).
        dt : float
            Time step (s).

        Returns
        -------
        bool
            True if arc detected.
        """
        self._arc_detected = False

        if dt > 0 and self._v_prev > 1000:  # Only check when energized
            # dV/dt check
            dv_dt = abs(self._v_prev - v_output) / dt
            if dv_dt > self.dv_dt_threshold:
                self._arc_detected = True

            # Voltage drop percentage check
            if v_output < self._v_prev * (1.0 - self.voltage_drop_pct / 100.0):
                self._arc_detected = True

            # Current spike check
            if self._i_prev > 0 and i_output > self._i_prev * self.current_spike_factor:
                self._arc_detected = True

        self._v_prev = v_output
        self._i_prev = i_output

        return self._arc_detected

    @property
    def is_arc_detected(self) -> bool:
        return self._arc_detected

    def reset(self):
        """Reset detector state."""
        self._v_prev = 0.0
        self._i_prev = 0.0
        self._arc_detected = False


class InterlockSystem:
    """Safety interlock system matching PLC ladder logic.

    Monitors all safety conditions and latches faults:
        - Transformer: pressure, vacuum, temperature, oil level
        - Power: AC overcurrent, overvoltage, phase loss
        - Cooling: water flow
        - Personnel: emergency off

    All latches follow PLC pattern:
        - SET by fault condition (OTL instruction)
        - HELD by latch bit
        - CLEARED only by Master Reset (B3:0/10)
    """

    def __init__(self, config: HVPSConfig):
        self.cfg = config.interlocks
        self.out_cfg = config.output

        # Simulated sensor readings
        self.temp_phase_upper = 25.0  # °C (N7:100)
        self.temp_phase_lower = 25.0  # °C (N7:101)
        self.temp_crowbar = 25.0      # °C (N7:102)
        self.temp_cabinet = 25.0      # °C (N7:103)
        self.ac_current_a = 0.0       # A per phase
        self.water_flow_ok = True
        self.oil_level_ok = True
        self.pressure_ok = True
        self.vacuum_ok = True

        # Fault latches (match PLC B3:4 register)
        self._latches = {
            FaultType.TRANSFORMER_PRESSURE: False,
            FaultType.TRANSFORMER_VACUUM: False,
            FaultType.TRANSFORMER_OVERTEMP: False,
            FaultType.TRANSFORMER_LOW_OIL: False,
            FaultType.TRANSFORMER_SUDDEN_PRESSURE: False,
            FaultType.AC_OVERCURRENT: False,
            FaultType.OVERVOLTAGE: False,
            FaultType.OVERCURRENT: False,
            FaultType.PHASE_LOSS: False,
            FaultType.WATER_FLOW: False,
            FaultType.EMERGENCY_OFF: False,
            FaultType.CROWBAR_FAULT: False,
        }

    def check_all(self, v_output: float, i_output: float,
                   i_ac: float = 0.0) -> List[FaultType]:
        """Check all interlock conditions.

        Returns list of any active faults.
        """
        faults = []

        # Temperature checks
        if self.temp_phase_upper > self.cfg.temp_phase_upper_max_c:
            self._latches[FaultType.TRANSFORMER_OVERTEMP] = True
            faults.append(FaultType.TRANSFORMER_OVERTEMP)
        if self.temp_phase_lower > self.cfg.temp_phase_lower_max_c:
            self._latches[FaultType.TRANSFORMER_OVERTEMP] = True
            faults.append(FaultType.TRANSFORMER_OVERTEMP)
        if self.temp_crowbar > self.cfg.temp_crowbar_max_c:
            self._latches[FaultType.TRANSFORMER_OVERTEMP] = True
            faults.append(FaultType.TRANSFORMER_OVERTEMP)

        # Pressure/vacuum/oil
        if not self.pressure_ok:
            self._latches[FaultType.TRANSFORMER_PRESSURE] = True
            faults.append(FaultType.TRANSFORMER_PRESSURE)
        if not self.vacuum_ok:
            self._latches[FaultType.TRANSFORMER_VACUUM] = True
            faults.append(FaultType.TRANSFORMER_VACUUM)
        if not self.oil_level_ok:
            self._latches[FaultType.TRANSFORMER_LOW_OIL] = True
            faults.append(FaultType.TRANSFORMER_LOW_OIL)

        # Overcurrent (AC)
        if abs(i_ac) > self.cfg.ac_overcurrent_a:
            self._latches[FaultType.AC_OVERCURRENT] = True
            faults.append(FaultType.AC_OVERCURRENT)

        # Overcurrent (DC)
        if abs(i_output) > self.cfg.dc_overcurrent_a:
            self._latches[FaultType.OVERCURRENT] = True
            faults.append(FaultType.OVERCURRENT)

        # Overvoltage
        if abs(v_output) > self.cfg.overvoltage_kv * 1000:
            self._latches[FaultType.OVERVOLTAGE] = True
            faults.append(FaultType.OVERVOLTAGE)

        # Water flow
        if not self.water_flow_ok:
            self._latches[FaultType.WATER_FLOW] = True
            faults.append(FaultType.WATER_FLOW)

        return faults

    @property
    def transformer_ok(self) -> bool:
        """Composite transformer interlock status (B3:2/1)."""
        return not any([
            self._latches[FaultType.TRANSFORMER_PRESSURE],
            self._latches[FaultType.TRANSFORMER_VACUUM],
            self._latches[FaultType.TRANSFORMER_OVERTEMP],
            self._latches[FaultType.TRANSFORMER_LOW_OIL],
            self._latches[FaultType.TRANSFORMER_SUDDEN_PRESSURE],
        ])

    @property
    def all_ok(self) -> bool:
        """All interlocks clear."""
        return not any(self._latches.values())

    def get_active_faults(self) -> List[FaultType]:
        """Return list of currently latched faults."""
        return [ft for ft, latched in self._latches.items() if latched]

    def master_reset(self):
        """Clear all fault latches (B3:0/10 Master Reset)."""
        for key in self._latches:
            self._latches[key] = False

    def trigger_emergency_off(self):
        """Trigger emergency off."""
        self._latches[FaultType.EMERGENCY_OFF] = True

    def set_temperatures(self, phase_upper: float = None,
                         phase_lower: float = None,
                         crowbar: float = None,
                         cabinet: float = None):
        """Update temperature readings."""
        if phase_upper is not None:
            self.temp_phase_upper = phase_upper
        if phase_lower is not None:
            self.temp_phase_lower = phase_lower
        if crowbar is not None:
            self.temp_crowbar = crowbar
        if cabinet is not None:
            self.temp_cabinet = cabinet

    def reset(self):
        """Reset all interlocks to default (healthy) state."""
        self.master_reset()
        self.temp_phase_upper = 25.0
        self.temp_phase_lower = 25.0
        self.temp_crowbar = 25.0
        self.temp_cabinet = 25.0
        self.water_flow_ok = True
        self.oil_level_ok = True
        self.pressure_ok = True
        self.vacuum_ok = True


class ProtectionManager:
    """Coordinates all protection layers into the 4-layer response.

    Protection sequence during klystron arc:
        1. Arc detected (dV/dt or current spike)
        2. Crowbar fires (~1 µs) — shorts output to limit arc energy
        3. Primary thyristors turn off (4-8 ms) — stops power delivery
        4. Cable inductors (L3, L4) limit discharge current
        5. System enters recovery (arc energy < 5 J)
        6. After recovery time, system can restart
    """

    def __init__(self, config: HVPSConfig):
        self.config = config
        self.crowbar = CrowbarSystem(config)
        self.arc_detector = ArcDetector(config)
        self.interlocks = InterlockSystem(config)

        self._state = ProtectionState.NORMAL
        self._fault_type = FaultType.NONE
        self._recovery_start = 0.0
        self._recovery_time = config.output.arc_recovery_ms / 1000.0
        self._thyristor_turnoff_time = 0.006  # 6 ms (midpoint of 4-8 ms)
        self._turnoff_start = 0.0

    @property
    def state(self) -> ProtectionState:
        return self._state

    @property
    def fault_type(self) -> FaultType:
        return self._fault_type

    def update(self, t: float, v_output: float, i_output: float,
               dt: float) -> ProtectionStatus:
        """Execute protection system checks and state machine.

        Parameters
        ----------
        t : float
            Current time (s).
        v_output : float
            Output voltage magnitude (V).
        i_output : float
            Output current (A).
        dt : float
            Time step (s).

        Returns
        -------
        ProtectionStatus
            Complete protection system snapshot.
        """
        status = ProtectionStatus(time=t)

        # Check interlocks
        interlock_faults = self.interlocks.check_all(v_output, i_output)
        status.transformer_ok = self.interlocks.transformer_ok
        status.all_interlocks_ok = self.interlocks.all_ok

        # Update temperatures in status
        status.temp_phase_upper_c = self.interlocks.temp_phase_upper
        status.temp_phase_lower_c = self.interlocks.temp_phase_lower
        status.temp_crowbar_c = self.interlocks.temp_crowbar
        status.temp_cabinet_c = self.interlocks.temp_cabinet

        # Copy latch states
        status.latch_crowbar = self.crowbar.is_firing
        status.latch_pressure = self.interlocks._latches[FaultType.TRANSFORMER_PRESSURE]
        status.latch_vacuum = self.interlocks._latches[FaultType.TRANSFORMER_VACUUM]
        status.latch_overtemp = self.interlocks._latches[FaultType.TRANSFORMER_OVERTEMP]
        status.latch_low_oil = self.interlocks._latches[FaultType.TRANSFORMER_LOW_OIL]
        status.latch_ac_overcurrent = self.interlocks._latches[FaultType.AC_OVERCURRENT]
        status.latch_overvoltage = self.interlocks._latches[FaultType.OVERVOLTAGE]

        # Protection state machine
        if self._state == ProtectionState.NORMAL:
            # Check for arc
            arc = self.arc_detector.check(v_output, i_output, dt)
            if arc:
                self._state = ProtectionState.ARC_DETECTED
                self._fault_type = FaultType.KLYSTRON_ARC
                # Layer 2: Fire crowbar
                self.crowbar.trigger(t)
                self._state = ProtectionState.CROWBAR_FIRING

            # Check for interlock faults
            if interlock_faults:
                self._state = ProtectionState.TRIPPED
                self._fault_type = interlock_faults[0]

        elif self._state == ProtectionState.CROWBAR_FIRING:
            # Crowbar conducting, wait for thyristor turn-off
            crowbar_active = self.crowbar.update(t, v_output, i_output, dt)
            status.crowbar_active = crowbar_active

            if not hasattr(self, '_turnoff_started') or not self._turnoff_started:
                self._turnoff_start = t
                self._turnoff_started = True

            if t - self._turnoff_start >= self._thyristor_turnoff_time:
                self._state = ProtectionState.THYRISTOR_TURNOFF
                self._turnoff_started = False

        elif self._state == ProtectionState.THYRISTOR_TURNOFF:
            # Layer 3: Thyristors turning off
            self.crowbar.update(t, v_output, i_output, dt)
            self._state = ProtectionState.RECOVERING
            self._recovery_start = t

        elif self._state == ProtectionState.RECOVERING:
            # Waiting for system to settle
            elapsed = t - self._recovery_start
            status.recovery_time_remaining_s = max(
                0, self._recovery_time - elapsed)
            if elapsed >= self._recovery_time:
                self._state = ProtectionState.NORMAL
                self._fault_type = FaultType.NONE
                self.crowbar.disable()
                self.crowbar.enable(t)

        elif self._state == ProtectionState.TRIPPED:
            # Latched fault — requires master reset
            pass

        status.state = self._state
        status.fault_type = self._fault_type
        status.crowbar_enabled = self.crowbar.is_enabled
        status.arc_energy_j = self.crowbar.energy_dumped
        status.fault_current_a = i_output if self._state != ProtectionState.NORMAL else 0.0

        return status

    def force_arc(self, t: float):
        """Force an arc event for testing."""
        self._state = ProtectionState.ARC_DETECTED
        self._fault_type = FaultType.KLYSTRON_ARC
        self.crowbar.trigger(t)
        self._state = ProtectionState.CROWBAR_FIRING
        self._turnoff_started = False

    def master_reset(self, t: float):
        """Master reset — clear all faults and return to normal."""
        self._state = ProtectionState.NORMAL
        self._fault_type = FaultType.NONE
        self.interlocks.master_reset()
        self.crowbar.reset()
        self.crowbar.enable(t)
        self.arc_detector.reset()
        self._turnoff_started = False

    def reset(self):
        """Reset protection system to initial state."""
        self._state = ProtectionState.NORMAL
        self._fault_type = FaultType.NONE
        self.crowbar.reset()
        self.arc_detector.reset()
        self.interlocks.reset()
        self._turnoff_started = False

