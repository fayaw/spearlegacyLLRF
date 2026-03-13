"""
Power Conversion Chain Models
=============================

Models the complete SPEAR3 HVPS power conversion path:

    12.47 kV 3φ AC  →  Phase-Shift Transformer (T0)
                    →  Rectifier Transformers (T1, T2)
                    →  12-Pulse SCR Rectifier (2 × 6-pulse bridges)
                    →  Primary Filter (L1, L2)
                    →  Secondary Rectifiers (D1-D24)
                    →  Filter Bank (C, R)
                    →  Crowbar Point
                    →  Cable Termination (L3, L4)
                    →  -77 kV DC Output to Klystron

Reference documents:
    - 00-spear3-hvps-legacy-system-design.md
    - 01-pepii-power-supply-architecture.md
    - 00_HVPS_SYSTEM_OVERVIEW.md
"""

import numpy as np
from dataclasses import dataclass, field
from typing import Optional

from hvps.hvps_sim.config import HVPSConfig


@dataclass
class PowerState:
    """Instantaneous state of the power conversion chain."""
    time: float = 0.0
    # AC input
    v_ac_a: float = 0.0      # Phase A voltage (V)
    v_ac_b: float = 0.0      # Phase B voltage (V)
    v_ac_c: float = 0.0      # Phase C voltage (V)
    i_ac_a: float = 0.0      # Phase A current (A)
    i_ac_b: float = 0.0      # Phase B current (A)
    i_ac_c: float = 0.0      # Phase C current (A)
    # Transformer outputs
    v_t1_out: float = 0.0    # T1 rectifier transformer output (V)
    v_t2_out: float = 0.0    # T2 rectifier transformer output (V)
    # Rectifier outputs
    v_bridge1: float = 0.0   # Bridge 1 output (V)
    v_bridge2: float = 0.0   # Bridge 2 output (V)
    v_12pulse: float = 0.0   # Combined 12-pulse output (V)
    # Filter
    i_l1: float = 0.0        # L1 inductor current (A)
    i_l2: float = 0.0        # L2 inductor current (A)
    v_cap: float = 0.0       # Filter capacitor voltage (V)
    # Output
    v_out: float = 0.0       # Output voltage (V, negative)
    i_out: float = 0.0       # Output current (A)
    power_w: float = 0.0     # Output power (W)
    # Thyristor state
    firing_angle_deg: float = 90.0  # SCR firing angle
    # Ripple
    ripple_pp_v: float = 0.0
    ripple_rms_v: float = 0.0


class ACSource:
    """Three-phase AC voltage source (Substation 507)."""

    def __init__(self, config: HVPSConfig):
        self.cfg = config.ac_input
        self.v_peak = self.cfg.voltage_peak
        self.omega = self.cfg.omega

    def voltages(self, t: float) -> tuple:
        """Return instantaneous 3-phase voltages at time t.

        Returns (V_a, V_b, V_c) in volts, 120° apart.
        """
        v_a = self.v_peak * np.sin(self.omega * t)
        v_b = self.v_peak * np.sin(self.omega * t - 2 * np.pi / 3)
        v_c = self.v_peak * np.sin(self.omega * t + 2 * np.pi / 3)
        return v_a, v_b, v_c

    def voltages_shifted(self, t: float, shift_deg: float) -> tuple:
        """Return 3-phase voltages with a phase shift (degrees)."""
        shift_rad = np.radians(shift_deg)
        v_a = self.v_peak * np.sin(self.omega * t + shift_rad)
        v_b = self.v_peak * np.sin(self.omega * t - 2 * np.pi / 3 + shift_rad)
        v_c = self.v_peak * np.sin(self.omega * t + 2 * np.pi / 3 + shift_rad)
        return v_a, v_b, v_c


class PhaseShiftTransformer:
    """T0 — Extended delta phase-shift transformer (3.5 MVA).

    Creates dual secondaries with ±15° phase shift for 12-pulse operation.
    The 30° total offset between the two sets eliminates 5th and 7th harmonics.
    """

    def __init__(self, config: HVPSConfig):
        self.cfg = config.phase_shift_xfmr
        self.shift = self.cfg.phase_shift_deg  # ±15°
        self.losses_pu = self.cfg.copper_loss_pu + self.cfg.core_loss_pu

    def transform(self, v_a: float, v_b: float, v_c: float, t: float,
                  omega: float) -> tuple:
        """Apply phase-shift transformation.

        Returns (v_set1, v_set2) — each a tuple of 3 voltages.
        Set 1: +15° shifted, Set 2: -15° shifted.
        """
        efficiency = 1.0 - self.losses_pu
        shift1_rad = np.radians(self.shift)
        shift2_rad = np.radians(-self.shift)

        # Simplified model: phase shift with loss factor
        # Set 1 (+15°)
        cos1, sin1 = np.cos(shift1_rad), np.sin(shift1_rad)
        v1_a = efficiency * (v_a * cos1 - v_b * sin1 / np.sqrt(3))
        v1_b = efficiency * (v_b * cos1 - v_c * sin1 / np.sqrt(3))
        v1_c = efficiency * (v_c * cos1 - v_a * sin1 / np.sqrt(3))

        # Set 2 (-15°)
        cos2, sin2 = np.cos(shift2_rad), np.sin(shift2_rad)
        v2_a = efficiency * (v_a * cos2 - v_b * sin2 / np.sqrt(3))
        v2_b = efficiency * (v_b * cos2 - v_c * sin2 / np.sqrt(3))
        v2_c = efficiency * (v_c * cos2 - v_a * sin2 / np.sqrt(3))

        return (v1_a, v1_b, v1_c), (v2_a, v2_b, v2_c)


class RectifierTransformer:
    """T1/T2 — Rectifier step-up transformers (1.5 MVA each).

    Open wye primary (floating neutral), dual wye center-tapped secondary.
    Steps up to high voltage for secondary rectification.
    """

    def __init__(self, config: HVPSConfig, unit: str = "T1"):
        self.cfg = config.rect_xfmr
        self.unit = unit
        self.losses_pu = self.cfg.copper_loss_pu + self.cfg.core_loss_pu
        # Step-up ratio to reach ~40 kV per secondary
        # Secondary peak ≈ 40 kV for the diode rectifiers
        self.turns_ratio = 40_000.0 / (config.ac_input.voltage_peak / np.sqrt(3))

    def transform(self, v_a: float, v_b: float, v_c: float) -> tuple:
        """Step up 3-phase voltages for rectification.

        Returns (v_a_sec, v_b_sec, v_c_sec) scaled by turns ratio.
        """
        eff = 1.0 - self.losses_pu
        n = self.turns_ratio
        return (v_a * n * eff, v_b * n * eff, v_c * n * eff)


class SixPulseBridge:
    """6-pulse thyristor (SCR) bridge with phase-angle control.

    Models the average DC output voltage as a function of firing angle α:
        V_dc = (3√2/π) × V_LL × cos(α)

    For a star-point controlled topology on the primary side.
    """

    def __init__(self, config: HVPSConfig, bridge_id: str = "Bridge1"):
        self.cfg = config.thyristor_bridge
        self.bridge_id = bridge_id
        self.scr_drop = self.cfg.on_voltage_drop * self.cfg.scrs_per_stack
        self._conducting = True

    def output_voltage(self, v_ll_peak: float, alpha_deg: float) -> float:
        """Calculate average DC output voltage for the 6-pulse bridge.

        Parameters
        ----------
        v_ll_peak : float
            Peak line-to-line voltage at the bridge input (V).
        alpha_deg : float
            SCR firing delay angle in degrees (0=full, 90=half, 180=off).

        Returns
        -------
        float
            Average DC output voltage (V).
        """
        if not self._conducting:
            return 0.0
        alpha_rad = np.radians(np.clip(alpha_deg, 0, 180))
        # 6-pulse average: V_dc = (3√2/π) × V_LL_peak × cos(α)
        # Using V_LL_peak (not RMS)
        v_dc = (3.0 * np.sqrt(2) / np.pi) * v_ll_peak * np.cos(alpha_rad)
        # Subtract SCR forward drops
        v_dc -= 2 * self.scr_drop  # Two SCRs conducting at any time
        return max(v_dc, 0.0)

    def output_with_ripple(self, v_ll_peak: float, alpha_deg: float,
                           t: float, f_line: float) -> float:
        """Calculate instantaneous output including 6-pulse ripple.

        Adds a 6×f_line ripple component on top of the average DC.
        """
        v_avg = self.output_voltage(v_ll_peak, alpha_deg)
        if v_avg <= 0:
            return 0.0
        alpha_rad = np.radians(alpha_deg)
        # Ripple amplitude for 6-pulse: ultra-low for realistic filtering
        # Real HVPS has elaborate LC filtering achieving <1% ripple
        ripple_factor = 0.003 * (1.0 + 0.1 * abs(np.sin(alpha_rad)))
        omega_ripple = 2 * np.pi * 6 * f_line
        # Add multiple harmonics for more realistic ripple shape
        ripple = v_avg * ripple_factor * (
            np.cos(omega_ripple * t) + 
            0.3 * np.cos(2 * omega_ripple * t) +
            0.1 * np.cos(3 * omega_ripple * t)
        )
        return v_avg + ripple

    def turn_off(self):
        """Inhibit thyristor conduction (protection action)."""
        self._conducting = False

    def turn_on(self):
        """Re-enable thyristor conduction."""
        self._conducting = True


class TwelvePulseRectifier:
    """12-pulse rectifier combining two 6-pulse bridges.

    The 30° phase offset between bridges cancels 5th and 7th harmonics,
    yielding a 12×f_line ripple frequency (720 Hz at 60 Hz).
    """

    def __init__(self, config: HVPSConfig):
        self.bridge1 = SixPulseBridge(config, "Bridge1_SCR1-6")
        self.bridge2 = SixPulseBridge(config, "Bridge2_SCR7-12")
        self.config = config

    def output_voltage(self, v_ll_peak: float, alpha_deg: float) -> float:
        """Combined average DC output from both bridges in series."""
        v1 = self.bridge1.output_voltage(v_ll_peak, alpha_deg)
        v2 = self.bridge2.output_voltage(v_ll_peak, alpha_deg)
        return v1 + v2

    def output_with_ripple(self, v_ll_peak: float, alpha_deg: float,
                           t: float, f_line: float) -> float:
        """Combined output with 12-pulse ripple pattern."""
        v1 = self.bridge1.output_with_ripple(v_ll_peak, alpha_deg, t, f_line)
        # Bridge 2 is shifted by 30° (half of 60° = 1/12 period)
        phase_shift = 1.0 / (12.0 * f_line)
        v2 = self.bridge2.output_with_ripple(v_ll_peak, alpha_deg,
                                              t + phase_shift, f_line)
        return v1 + v2

    def turn_off_all(self):
        """Emergency turn-off of all thyristors."""
        self.bridge1.turn_off()
        self.bridge2.turn_off()

    def turn_on_all(self):
        """Re-enable all thyristors."""
        self.bridge1.turn_on()
        self.bridge2.turn_on()


class LCFilter:
    """LC filter network with primary inductors and secondary capacitors.

    Models the filter dynamics using state-space representation:
        di_L/dt = (v_in - v_C - R_total × i_L) / L_total
        dv_C/dt = (i_L - i_load) / C

    Components:
        L1, L2: 0.3H each (series → 0.6H total effective, or parallel)
        C: 8 µF filter capacitor bank
        R: Isolation and damping resistors
    """

    def __init__(self, config: HVPSConfig):
        self.cfg = config.filter
        # Total effective inductance (L1 and L2 in the two legs)
        # In the star-point topology, each bridge feeds through its inductor
        self.L = self.cfg.inductor_l1_h  # Per-bridge inductor
        self.C = self.cfg.capacitor_uf * 1e-6  # Convert µF to F
        self.R_damp = self.cfg.isolation_resistance
        # Cable termination inductors
        self.L_cable = self.cfg.cable_inductor_l3_uh * 1e-6  # Convert µH to H

        # State variables
        self.i_L1 = 0.0  # Current through L1
        self.i_L2 = 0.0  # Current through L2
        self.v_C = 0.0    # Capacitor voltage

    def reset(self):
        """Reset filter state to zero."""
        self.i_L1 = 0.0
        self.i_L2 = 0.0
        self.v_C = 0.0

    def step(self, v_bridge1: float, v_bridge2: float, i_load: float,
             dt: float) -> tuple:
        """Advance filter state by one time step.

        Parameters
        ----------
        v_bridge1, v_bridge2 : float
            Input voltages from bridge 1 and 2 (V).
        i_load : float
            Load current drawn by klystron (A).
        dt : float
            Time step (s).

        Returns
        -------
        tuple : (v_out, i_total)
            Output voltage (V) and total inductor current (A).
        """
        # Inductor 1: di_L1/dt = (v_bridge1 - v_C) / L
        di_L1 = (v_bridge1 - self.v_C) / self.L * dt
        # Inductor 2: di_L2/dt = (v_bridge2 - v_C) / L
        di_L2 = (v_bridge2 - self.v_C) / self.L * dt

        self.i_L1 += di_L1
        self.i_L2 += di_L2

        # Clamp to prevent negative inductor currents (diode action)
        self.i_L1 = max(self.i_L1, 0.0)
        self.i_L2 = max(self.i_L2, 0.0)

        i_total = self.i_L1 + self.i_L2

        # Capacitor: dv_C/dt = (i_total - i_load - i_damp) / C
        if self.C > 0:
            # Add damping current through isolation resistor
            i_damp = self.v_C / self.R_damp if self.R_damp > 0 else 0.0
            dv_C = (i_total - i_load - i_damp) / self.C * dt
            self.v_C += dv_C
        else:
            self.v_C = v_bridge1 + v_bridge2  # No filtering

        # Clamp capacitor voltage to physical limits
        self.v_C = max(self.v_C, 0.0)

        return self.v_C, i_total

    def stored_energy(self) -> float:
        """Calculate total stored energy in filter (Joules)."""
        e_l1 = 0.5 * self.L * self.i_L1 ** 2
        e_l2 = 0.5 * self.L * self.i_L2 ** 2
        e_c = 0.5 * self.C * self.v_C ** 2
        return e_l1 + e_l2 + e_c


class KlystronLoad:
    """Klystron load model with arc fault simulation.

    Normal operation: constant-impedance load (R = V/I ≈ 3500 Ω)
    Arc condition: low impedance (~10 Ω) for a brief period

    The klystron beam current follows a perveance law:
        I_beam = κ × V^(3/2)
    where κ is the perveance (~2.0 µA/V^(3/2)).
    """

    def __init__(self, config: HVPSConfig):
        self.cfg = config.klystron
        self.R_nominal = self.cfg.impedance_nominal
        self.R_arc = self.cfg.arc_impedance
        self.perveance = self.cfg.perveance
        self._arcing = False
        self._arc_start_time = 0.0
        self._arc_duration = self.cfg.arc_duration_us * 1e-6
        self._arc_energy = 0.0

    @property
    def is_arcing(self) -> bool:
        return self._arcing

    @property
    def arc_energy(self) -> float:
        return self._arc_energy

    def current(self, voltage: float, t: float) -> float:
        """Calculate load current given applied voltage.

        Parameters
        ----------
        voltage : float
            Applied voltage magnitude (V, positive value).
        t : float
            Current simulation time (s).

        Returns
        -------
        float
            Load current (A).
        """
        if self._arcing:
            if t - self._arc_start_time > self._arc_duration:
                self._arcing = False
            else:
                return voltage / self.R_arc if self.R_arc > 0 else 0.0

        # Perveance model: I = κ × V^(3/2)
        if voltage > 0:
            i_beam = self.perveance * voltage ** 1.5
            # Also limit by nominal impedance model
            i_resistive = voltage / self.R_nominal
            return min(i_beam, i_resistive)
        return 0.0

    def trigger_arc(self, t: float, duration_us: Optional[float] = None):
        """Trigger a klystron arc event.

        Parameters
        ----------
        t : float
            Time of arc initiation (s).
        duration_us : float, optional
            Arc duration in microseconds. Defaults to configured value.
        """
        self._arcing = True
        self._arc_start_time = t
        if duration_us is not None:
            self._arc_duration = duration_us * 1e-6
        self._arc_energy = 0.0

    def accumulate_arc_energy(self, voltage: float, current: float, dt: float):
        """Track energy delivered to klystron during arc."""
        if self._arcing:
            self._arc_energy += abs(voltage * current) * dt

    def reset(self):
        """Reset load state."""
        self._arcing = False
        self._arc_energy = 0.0


class PowerConversionChain:
    """Complete power conversion chain from AC input to DC output.

    Integrates all power components into a single callable model.
    """

    def __init__(self, config: HVPSConfig):
        self.config = config
        self.ac_source = ACSource(config)
        self.phase_xfmr = PhaseShiftTransformer(config)
        self.rect_xfmr_t1 = RectifierTransformer(config, "T1")
        self.rect_xfmr_t2 = RectifierTransformer(config, "T2")
        self.rectifier = TwelvePulseRectifier(config)
        self.lc_filter = LCFilter(config)
        self.klystron = KlystronLoad(config)

        # Operating state
        self._energized = False

    def reset(self):
        """Reset all components to initial state."""
        self.lc_filter.reset()
        self.klystron.reset()
        self.rectifier.turn_on_all()
        self._energized = False

    def energize(self):
        """Connect AC power (close vacuum contactor)."""
        self._energized = True

    def de_energize(self):
        """Disconnect AC power (open vacuum contactor)."""
        self._energized = False

    def compute(self, t: float, firing_angle_deg: float, dt: float) -> PowerState:
        """Compute one time step of the power conversion chain.

        Parameters
        ----------
        t : float
            Current simulation time (s).
        firing_angle_deg : float
            SCR firing angle (degrees). 0°=full output, 180°=off.
        dt : float
            Time step (s).

        Returns
        -------
        PowerState
            Complete snapshot of the power chain state.
        """
        state = PowerState(time=t, firing_angle_deg=firing_angle_deg)

        if not self._energized:
            return state

        # 1. AC source
        v_a, v_b, v_c = self.ac_source.voltages(t)
        state.v_ac_a, state.v_ac_b, state.v_ac_c = v_a, v_b, v_c

        # 2. Phase-shift transformer
        set1, set2 = self.phase_xfmr.transform(v_a, v_b, v_c, t,
                                                 self.ac_source.omega)

        # 3. Rectifier transformers (step up)
        v_t1 = self.rect_xfmr_t1.transform(*set1)
        v_t2 = self.rect_xfmr_t2.transform(*set2)

        # Peak line-to-line voltage at bridge input
        v_ll_peak_t1 = max(abs(v_t1[0] - v_t1[1]),
                           abs(v_t1[1] - v_t1[2]),
                           abs(v_t1[2] - v_t1[0]))
        v_ll_peak_t2 = max(abs(v_t2[0] - v_t2[1]),
                           abs(v_t2[1] - v_t2[2]),
                           abs(v_t2[2] - v_t2[0]))

        # 4. 12-pulse rectifier
        f_line = self.config.ac_input.frequency
        v_b1 = self.rectifier.bridge1.output_with_ripple(
            v_ll_peak_t1, firing_angle_deg, t, f_line)
        v_b2 = self.rectifier.bridge2.output_with_ripple(
            v_ll_peak_t2, firing_angle_deg, t, f_line)
        state.v_bridge1, state.v_bridge2 = v_b1, v_b2

        # 5. LC filter
        # Load current from previous state (or estimate)
        v_out_mag = abs(self.lc_filter.v_C)
        i_load = self.klystron.current(v_out_mag, t)
        v_filtered, i_total = self.lc_filter.step(v_b1, v_b2, i_load, dt)

        state.v_cap = v_filtered
        state.i_l1 = self.lc_filter.i_L1
        state.i_l2 = self.lc_filter.i_L2

        # 6. Output (negative polarity for klystron cathode)
        state.v_out = -v_filtered
        state.i_out = i_load
        state.power_w = abs(state.v_out * state.i_out)

        # Track arc energy
        self.klystron.accumulate_arc_energy(v_filtered, i_load, dt)

        # Estimate ripple
        v_12pulse = v_b1 + v_b2
        state.v_12pulse = v_12pulse
        if v_filtered > 0:
            state.ripple_pp_v = abs(v_12pulse - v_filtered)

        return state
