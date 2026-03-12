"""
Control System Models
=====================

Models the complete SPEAR3 HVPS control hierarchy:

    EPICS IOC → VXI Crate → PLC (SLC-5/03) → Regulator Board → Enerpro → SCRs

Key components:
    - PLCController: Digital low-pass filter, voltage/phase reference
    - EnerproFiringBoard: PLL-based SCR firing angle control
    - RegulatorBoard: SLAC SD-237-230-14 voltage/current regulation
    - ControlSystem: Integrated control chain

Reference documents:
    - 05-control-algorithms.md (PLC registers and algorithms)
    - 06-control-theory.md (Enerpro phase control theory)
    - 03-control-signal-interface.md (signal interfaces)
    - 04-regulator-board-design.md (SLAC regulator board)
    - 08-analog-registers-calibration.md (PLC register map)
"""

import numpy as np
from dataclasses import dataclass, field
from typing import Optional

from hvps.hvps_sim.config import HVPSConfig


@dataclass
class ControlState:
    """Snapshot of all control system variables."""
    time: float = 0.0
    # EPICS setpoint
    epics_voltage_setpoint_kv: float = 0.0
    # PLC registers
    n7_10_ref_out: float = 0.0       # Voltage reference (0-32000)
    n7_11_phase_out: float = 0.0     # Phase angle (6000-18000)
    n7_30_ext_ref: float = 0.0       # External reference from EPICS
    n7_43_delta: float = 0.0         # Filter delta value
    # Regulator board
    reg_voltage_error: float = 0.0   # Voltage error signal
    reg_current_error: float = 0.0   # Current error signal
    reg_output_v: float = 0.0        # Output to Enerpro SIG HI
    # Enerpro
    sig_hi_v: float = 0.0            # Combined SIG HI voltage
    firing_angle_deg: float = 150.0  # SCR firing angle (degrees)
    # System state
    regulator_on: bool = False       # B3:0/2
    soft_start_active: bool = False
    soft_start_progress: float = 0.0 # 0.0 to 1.0


class PLCController:
    """Allen-Bradley SLC-5/03 PLC control model.

    Implements the exact control algorithms from the PLC technical notes:

    Rung 104 — Digital Low-Pass Filter for N7:10 (Reference Out):
        N7:43 = (N7:30 - N7:10) / 10
        N7:10 += N7:43
        If N7:43 == 0: N7:10 = N7:30  (force exact match)
        Clamp: N7:10 ≤ min(N7:32, N7:33)
        Period: 80 ms

    Rung 108 — Phase Angle Calculation for N7:11 (Phase Out):
        N7:11 = (N7:10 × 12000) / 32767 + 6000
        Clamp: N7:11 ≤ 18000

    Rung 11 — Initialization (when regulator off):
        N7:10 = 0, N7:11 = 0
    """

    def __init__(self, config: HVPSConfig):
        self.cfg = config.plc
        self.T = self.cfg.scan_period_s
        self.alpha = self.cfg.filter_alpha

        # PLC registers (16-bit signed integers)
        self.n7_10 = 0      # Reference Out (voltage setpoint to regulator)
        self.n7_11 = 0      # Phase Out (phase angle to Enerpro)
        self.n7_30 = 0      # External Reference (from EPICS)
        self.n7_31 = self.cfg.ref_min_internal   # Minimum reference (100)
        self.n7_32 = self.cfg.ref_max_internal   # Max internal reference (32000)
        self.n7_33 = self.cfg.ref_max_external   # Max external reference
        self.n7_40 = self.cfg.phase_multiplier   # Phase multiplier (12000)
        self.n7_41 = self.cfg.phase_offset       # Phase offset (6000)
        self.n7_42 = self.cfg.phase_max          # Max phase angle (18000)
        self.n7_43 = 0      # Delta (filter step)

        # Control flags
        self.regulator_on = False    # B3:0/2
        self._time_accumulator = 0.0
        self._last_scan_time = 0.0

    def set_epics_setpoint(self, voltage_kv: float):
        """Set the EPICS voltage setpoint (converted to PLC register units).

        Maps voltage to N7:30 register value:
            N7:30 = voltage_kv / 90.0 × 32000
        (Full scale ≈ 90 kV → 32000 counts)
        """
        # Scale: 0 kV → 0, 77 kV → ~27378, 90 kV → 32000
        # Adjust scaling to better reach target voltage
        self.n7_30 = int(np.clip(
            abs(voltage_kv) / 85.0 * 32000, 0, 32767))

    def turn_on(self):
        """Enable the regulator (B3:0/2 = True)."""
        self.regulator_on = True

    def turn_off(self):
        """Disable the regulator (B3:0/2 = False)."""
        self.regulator_on = False
        # Rung 11: Reset outputs when off
        self.n7_10 = 0
        self.n7_11 = 0

    def scan(self, t: float) -> tuple:
        """Execute one PLC scan cycle if enough time has elapsed.

        Parameters
        ----------
        t : float
            Current simulation time (s).

        Returns
        -------
        tuple : (n7_10, n7_11, did_scan)
            Updated register values and whether a scan executed.
        """
        self._time_accumulator += (t - self._last_scan_time)
        self._last_scan_time = t

        did_scan = False
        if self._time_accumulator >= self.T:
            self._time_accumulator -= self.T
            did_scan = True

            if not self.regulator_on:
                self.n7_10 = 0
                self.n7_11 = 0
                return self.n7_10, self.n7_11, did_scan

            # --- Rung 104: Low-pass filter for N7:10 ---
            # Enforce minimum reference
            ref = max(self.n7_30, self.n7_31)

            # Delta calculation (integer division!)
            self.n7_43 = int((ref - self.n7_10) / 10)

            # Update reference
            self.n7_10 += self.n7_43

            # Force exact match when delta rounds to zero
            if self.n7_43 == 0:
                self.n7_10 = ref

            # Clamp to max internal reference
            if self.n7_10 > self.n7_32:
                self.n7_10 = self.n7_32

            # Clamp to max external reference
            if self.n7_33 > 0 and self.n7_10 > self.n7_33:
                self.n7_10 = self.n7_33

            # --- Rung 108: Phase angle calculation ---
            # N7:11 = (N7:10 × 12000) / 32767 + 6000
            product = self.n7_10 * self.n7_40  # 32-bit product
            self.n7_11 = int(product / self.cfg.phase_divisor) + self.n7_41

            # --- Rung 109: Phase angle clamping ---
            if self.n7_11 > self.n7_42:
                self.n7_11 = self.n7_42

        return self.n7_10, self.n7_11, did_scan

    def get_dac_voltage(self, register_value: int) -> float:
        """Convert PLC register value to analog output voltage (0-10V)."""
        return register_value / self.cfg.dac_max * 10.0

    @property
    def time_constant(self) -> float:
        """Effective time constant of the digital low-pass filter (seconds)."""
        return self.cfg.time_constant_s

    def reset(self):
        """Reset PLC to power-on state."""
        self.n7_10 = 0
        self.n7_11 = 0
        self.n7_30 = 0
        self.n7_43 = 0
        self.regulator_on = False
        self._time_accumulator = 0.0
        self._last_scan_time = 0.0


class EnerproFiringBoard:
    """Enerpro FCOG1200 SCR firing board model.

    Uses PLL-based phase control for frequency-independent delay angle:
        α = α₀ + (E/12) × R3/(R1+R2) × 180°

    where E is the SIG HI control voltage.

    The PLL locks to AC mains and generates precise firing pulses
    at VCO frequency = 384 × f_line = 23,040 Hz (at 60 Hz).

    Transfer function (simplified for simulation):
        firing_angle = map(sig_hi, [0.9V, 5.9V]) → [150°, 30°]
    Higher SIG HI → lower firing angle → higher output voltage.
    """

    def __init__(self, config: HVPSConfig):
        self.cfg = config.enerpro
        self.sig_hi = 0.0
        self.firing_angle = self.cfg.max_delay_angle_deg  # Start at max (off)
        self._phase_loss = False
        self._inhibited = False

        # PLL dynamics (simplified as first-order lag)
        # Settling time: ~3 AC cycles at 60 Hz → ~50 ms
        self._tau = 3.0 / config.ac_input.frequency
        self._target_angle = self.firing_angle

    def set_sig_hi(self, voltage: float):
        """Set the SIG HI command input voltage.

        Parameters
        ----------
        voltage : float
            SIG HI voltage (0.9 to 5.9 VDC typically).
        """
        self.sig_hi = np.clip(voltage, 0.0, 10.0)
        # Map SIG HI to firing angle
        # Higher voltage → lower angle → more output
        # 0.9V → 150° (minimum output), 5.9V → 30° (maximum output)
        if self.sig_hi < self.cfg.sig_hi_min_v:
            self._target_angle = self.cfg.max_delay_angle_deg
        elif self.sig_hi > self.cfg.sig_hi_max_v:
            self._target_angle = self.cfg.min_delay_angle_deg
        else:
            # Linear interpolation
            frac = ((self.sig_hi - self.cfg.sig_hi_min_v) /
                    (self.cfg.sig_hi_max_v - self.cfg.sig_hi_min_v))
            self._target_angle = (self.cfg.max_delay_angle_deg -
                                  frac * (self.cfg.max_delay_angle_deg -
                                          self.cfg.min_delay_angle_deg))

    def update(self, dt: float) -> float:
        """Update firing angle with PLL dynamics.

        Parameters
        ----------
        dt : float
            Time step (s).

        Returns
        -------
        float
            Current firing angle (degrees).
        """
        if self._phase_loss or self._inhibited:
            self.firing_angle = self.cfg.max_delay_angle_deg
            return self.firing_angle

        # First-order lag toward target angle
        if self._tau > 0 and dt > 0:
            alpha_filt = min(dt / self._tau, 1.0)
            self.firing_angle += alpha_filt * (self._target_angle - self.firing_angle)
        else:
            self.firing_angle = self._target_angle

        return self.firing_angle

    def set_phase_loss(self, lost: bool):
        """Indicate AC phase loss condition."""
        self._phase_loss = lost

    def inhibit(self):
        """Inhibit all gate pulses (protection action)."""
        self._inhibited = True

    def release(self):
        """Release gate inhibit."""
        self._inhibited = False
        self._phase_loss = False

    def reset(self):
        """Reset firing board to power-on state."""
        self.sig_hi = 0.0
        self.firing_angle = self.cfg.max_delay_angle_deg
        self._target_angle = self.cfg.max_delay_angle_deg
        self._phase_loss = False
        self._inhibited = False


class RegulatorBoard:
    """SLAC SD-237-230-14-C1 Voltage/Current Regulator Board.

    Functions:
        - Compares voltage setpoint (from PLC) with measured output voltage
        - Compares current limit with measured output current
        - Generates control signal for Enerpro SIG HI input
        - Provides soft-start ramping
        - Implements overvoltage/overcurrent trip logic

    The output is summed with PLC phase output at the Enerpro SIG HI input:
        SIG_HI = (V_reg / 7.5kΩ + V_plc / 1kΩ) × R_equivalent

    Simplified model: PI controller with soft-start envelope.
    """

    def __init__(self, config: HVPSConfig):
        self.cfg = config.regulator
        self.out_cfg = config.output

        # PI controller gains (tuned for HVPS dynamics)
        self.kp = 2.0        # Proportional gain (increased)
        self.ki = 8.0        # Integral gain (increased)
        self._integral = 0.0
        self._output = 0.0

        # Soft-start
        self.soft_start_time = self.cfg.soft_start_time_s
        self._soft_start_progress = 0.0
        self._soft_starting = False
        self._soft_start_elapsed = 0.0

        # Trip states
        self._tripped = False
        self._trip_reason = ""

        # Summing resistors
        self.r_reg = self.cfg.reg_to_sighi_r   # 7.5 kΩ
        self.r_plc = self.cfg.plc_to_sighi_r   # 1 kΩ

    def start_soft_start(self):
        """Initiate soft-start sequence."""
        self._soft_starting = True
        self._soft_start_elapsed = 0.0
        self._soft_start_progress = 0.0

    def compute(self, v_setpoint_v: float, v_measured_v: float,
                i_measured_a: float, dt: float) -> float:
        """Compute regulator output voltage.

        Parameters
        ----------
        v_setpoint_v : float
            Desired output voltage magnitude (V, positive).
        v_measured_v : float
            Measured output voltage magnitude (V, positive).
        i_measured_a : float
            Measured output current (A).
        dt : float
            Time step (s).

        Returns
        -------
        float
            Regulator output voltage to Enerpro SIG HI summing point (V).
        """
        if self._tripped:
            self._output = 0.0
            return self._output

        # Soft-start envelope
        if self._soft_starting:
            self._soft_start_elapsed += dt
            self._soft_start_progress = min(
                self._soft_start_elapsed / self.soft_start_time, 1.0)
            if self._soft_start_progress >= 1.0:
                self._soft_starting = False
            v_setpoint_v *= self._soft_start_progress

        # Voltage error (positive error = need more voltage)
        v_error = v_setpoint_v - v_measured_v

        # Current limiting: reduce setpoint if over current limit
        i_limit = self.cfg.current_limit_a
        if i_measured_a > i_limit:
            i_error = i_limit - i_measured_a
            v_error = min(v_error, i_error * 100.0)  # Current loop takes over

        # PI controller
        self._integral += v_error * dt
        # Anti-windup
        self._integral = np.clip(self._integral, -5.0, 5.0)

        self._output = self.kp * v_error + self.ki * self._integral

        # Clamp output to SIG HI range contribution
        self._output = np.clip(self._output, 0.0, 8.0)

        # Check for trips
        if v_measured_v > self.cfg.overvoltage_trip_kv * 1000:
            self.trip("Overvoltage")
        if i_measured_a > self.cfg.overcurrent_trip_a:
            self.trip("Overcurrent")

        return self._output

    def trip(self, reason: str = ""):
        """Trigger a trip condition."""
        self._tripped = True
        self._trip_reason = reason
        self._output = 0.0
        self._integral = 0.0

    def reset_trip(self):
        """Clear trip condition."""
        self._tripped = False
        self._trip_reason = ""
        self._integral = 0.0

    @property
    def is_tripped(self) -> bool:
        return self._tripped

    @property
    def trip_reason(self) -> str:
        return self._trip_reason

    @property
    def soft_start_progress(self) -> float:
        return self._soft_start_progress

    def reset(self):
        """Reset regulator to initial state."""
        self._integral = 0.0
        self._output = 0.0
        self._soft_start_progress = 0.0
        self._soft_starting = False
        self._soft_start_elapsed = 0.0
        self._tripped = False
        self._trip_reason = ""


class ControlSystem:
    """Integrated HVPS control system.

    Coordinates PLC, regulator board, and Enerpro firing board into a
    coherent control chain:

        EPICS setpoint → PLC (N7:10, N7:11) → Regulator Board → Enerpro → α
    """

    def __init__(self, config: HVPSConfig):
        self.config = config
        self.plc = PLCController(config)
        self.enerpro = EnerproFiringBoard(config)
        self.regulator = RegulatorBoard(config)
        self._voltage_setpoint_kv = 0.0

    def set_voltage(self, voltage_kv: float):
        """Set desired output voltage (kV, positive magnitude).

        This propagates through the control chain:
        EPICS → PLC N7:30 → filtered to N7:10 → phase N7:11 → SIG HI → α
        """
        self._voltage_setpoint_kv = abs(voltage_kv)
        self.plc.set_epics_setpoint(voltage_kv)

    def startup(self):
        """Execute startup sequence."""
        self.plc.turn_on()
        self.regulator.start_soft_start()
        self.enerpro.release()

    def shutdown(self):
        """Execute controlled shutdown."""
        self.plc.turn_off()
        self.enerpro.inhibit()

    def emergency_off(self):
        """Emergency shutdown — immediate gate inhibit."""
        self.plc.turn_off()
        self.enerpro.inhibit()
        self.regulator.trip("Emergency Off")

    def update(self, t: float, v_measured_v: float, i_measured_a: float,
               dt: float) -> ControlState:
        """Execute one control cycle.

        Parameters
        ----------
        t : float
            Current time (s).
        v_measured_v : float
            Measured output voltage magnitude (V, positive).
        i_measured_a : float
            Measured output current (A).
        dt : float
            Time step (s).

        Returns
        -------
        ControlState
            Complete snapshot of control system variables.
        """
        state = ControlState(time=t)
        state.epics_voltage_setpoint_kv = self._voltage_setpoint_kv
        state.regulator_on = self.plc.regulator_on

        # 1. PLC scan
        n7_10, n7_11, did_scan = self.plc.scan(t)
        state.n7_10_ref_out = n7_10
        state.n7_11_phase_out = n7_11
        state.n7_30_ext_ref = self.plc.n7_30
        state.n7_43_delta = self.plc.n7_43

        # 2. Convert PLC outputs to analog voltages
        v_plc_ref = self.plc.get_dac_voltage(n7_10)     # 0-10V
        v_plc_phase = self.plc.get_dac_voltage(n7_11)   # 0-10V

        # 3. Regulator board — voltage/current feedback
        v_setpoint_v = self._voltage_setpoint_kv * 1000.0
        v_reg = self.regulator.compute(v_setpoint_v, v_measured_v,
                                        i_measured_a, dt)
        state.reg_output_v = v_reg
        state.reg_voltage_error = v_setpoint_v - v_measured_v
        state.soft_start_active = self.regulator._soft_starting
        state.soft_start_progress = self.regulator.soft_start_progress

        # 4. Sum regulator and PLC outputs at Enerpro SIG HI
        # V_sig_hi = V_reg/R_reg + V_plc_phase/R_plc  (simplified summing)
        r_reg = self.regulator.r_reg
        r_plc = self.regulator.r_plc
        r_parallel = (r_reg * r_plc) / (r_reg + r_plc)
        i_sum = v_reg / r_reg + v_plc_phase / r_plc
        sig_hi = i_sum * r_parallel
        sig_hi = np.clip(sig_hi, 0.0, 10.0)
        state.sig_hi_v = sig_hi

        # 5. Enerpro firing board
        self.enerpro.set_sig_hi(sig_hi)
        firing_angle = self.enerpro.update(dt)
        state.firing_angle_deg = firing_angle

        return state

    def reset(self):
        """Reset entire control system."""
        self.plc.reset()
        self.enerpro.reset()
        self.regulator.reset()
        self._voltage_setpoint_kv = 0.0
