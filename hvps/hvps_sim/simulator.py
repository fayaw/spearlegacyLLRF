"""
HVPS Simulation Engine
======================

Main simulation integrator for the SPEAR3 HVPS legacy system.
Coordinates power conversion, control, and protection subsystems
through a unified time-stepping engine.

System operating modes:
    OFF → STARTUP → REGULATING → (FAULT → RECOVERY →) REGULATING → SHUTDOWN → OFF

Usage:
    from hvps.hvps_sim import HVPSSimulator, HVPSConfig

    sim = HVPSSimulator()
    result = sim.run(duration=10.0, voltage_kv=77.0)
    result.plot()
"""

import numpy as np
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Optional, Dict, List, Callable

from hvps.hvps_sim.config import HVPSConfig
from hvps.hvps_sim.power import PowerConversionChain, PowerState
from hvps.hvps_sim.controls import ControlSystem, ControlState
from hvps.hvps_sim.protection import (
    ProtectionManager, ProtectionStatus, ProtectionState, FaultType
)
from hvps.hvps_sim.filtering import LCFilter, TwelvePulseRippleGenerator, FilterComponents
from hvps.hvps_sim.thyristor_physics import TwelvePulseThyristorRectifier


class SystemMode(Enum):
    """HVPS system operating mode."""
    OFF = auto()
    STARTUP = auto()
    REGULATING = auto()
    FAULT = auto()
    RECOVERY = auto()
    SHUTDOWN = auto()


@dataclass
class SimulationResult:
    """Container for simulation time-series data.

    All arrays are indexed by time step.
    """
    # Time
    time: np.ndarray = field(default_factory=lambda: np.array([]))
    dt: float = 0.0
    duration: float = 0.0

    # System mode
    mode: List[str] = field(default_factory=list)

    # Output (primary quantities of interest)
    voltage_kv: np.ndarray = field(default_factory=lambda: np.array([]))
    current_a: np.ndarray = field(default_factory=lambda: np.array([]))
    power_mw: np.ndarray = field(default_factory=lambda: np.array([]))

    # Control signals
    firing_angle_deg: np.ndarray = field(default_factory=lambda: np.array([]))
    n7_10_ref: np.ndarray = field(default_factory=lambda: np.array([]))
    n7_11_phase: np.ndarray = field(default_factory=lambda: np.array([]))
    sig_hi_v: np.ndarray = field(default_factory=lambda: np.array([]))
    setpoint_kv: np.ndarray = field(default_factory=lambda: np.array([]))
    soft_start_pct: np.ndarray = field(default_factory=lambda: np.array([]))

    # Power chain
    v_bridge1_kv: np.ndarray = field(default_factory=lambda: np.array([]))
    v_bridge2_kv: np.ndarray = field(default_factory=lambda: np.array([]))
    v_capacitor_kv: np.ndarray = field(default_factory=lambda: np.array([]))
    i_inductor1_a: np.ndarray = field(default_factory=lambda: np.array([]))
    i_inductor2_a: np.ndarray = field(default_factory=lambda: np.array([]))
    filter_energy_j: np.ndarray = field(default_factory=lambda: np.array([]))
    
    # HVPS Monitoring Signals (4 channels from Waveform Buffer System)
    hvps_voltage_monitor_kv: np.ndarray = field(default_factory=lambda: np.array([]))      # Channel 1: DC Voltage
    hvps_current_monitor_a: np.ndarray = field(default_factory=lambda: np.array([]))       # Channel 2: DC Current  
    inductor2_sawtooth_monitor_kv: np.ndarray = field(default_factory=lambda: np.array([]))  # Channel 3: T2 Sawtooth
    transformer1_current_monitor_a: np.ndarray = field(default_factory=lambda: np.array([]))  # Channel 4: T1 AC Current

    # Protection
    protection_state: List[str] = field(default_factory=list)
    crowbar_active: np.ndarray = field(default_factory=lambda: np.array([]))
    arc_energy_j: np.ndarray = field(default_factory=lambda: np.array([]))

    # AC input
    v_ac_a_kv: np.ndarray = field(default_factory=lambda: np.array([]))
    i_ac_a: np.ndarray = field(default_factory=lambda: np.array([]))

    # Temperatures
    temp_phase_upper: np.ndarray = field(default_factory=lambda: np.array([]))
    temp_crowbar: np.ndarray = field(default_factory=lambda: np.array([]))

    def summary(self) -> str:
        """Return a human-readable summary of the simulation results."""
        if len(self.time) == 0:
            return "No simulation data."

        lines = [
            "SPEAR3 HVPS Simulation Results",
            "=" * 45,
            f"Duration:       {self.duration:.3f} s ({len(self.time)} steps)",
            f"Time step:      {self.dt*1e6:.1f} µs",
            "",
            "Output:",
            f"  Voltage:      {np.mean(self.voltage_kv):.2f} kV "
            f"(min: {np.min(self.voltage_kv):.2f}, max: {np.max(self.voltage_kv):.2f})",
            f"  Current:      {np.mean(self.current_a):.2f} A "
            f"(min: {np.min(self.current_a):.2f}, max: {np.max(self.current_a):.2f})",
            f"  Power:        {np.mean(self.power_mw):.3f} MW",
            "",
            "Control:",
            f"  Firing angle: {np.mean(self.firing_angle_deg):.1f}° "
            f"(range: {np.min(self.firing_angle_deg):.1f}° - "
            f"{np.max(self.firing_angle_deg):.1f}°)",
            f"  SIG HI:       {np.mean(self.sig_hi_v):.2f} V",
            "",
            "Regulation (steady-state):",
        ]

        # Calculate regulation metrics from last 25% of data
        n_ss = max(1, len(self.time) // 4)
        v_ss = self.voltage_kv[-n_ss:]
        if np.mean(v_ss) != 0:
            ripple_pp = (np.max(v_ss) - np.min(v_ss))
            ripple_rms = np.std(v_ss)
            v_mean = np.mean(np.abs(v_ss))
            lines.append(f"  Ripple P-P:   {ripple_pp:.3f} kV "
                        f"({ripple_pp/v_mean*100:.3f}%)")
            lines.append(f"  Ripple RMS:   {ripple_rms:.4f} kV "
                        f"({ripple_rms/v_mean*100:.4f}%)")

        # Protection events
        fault_steps = [i for i, s in enumerate(self.protection_state)
                       if s != "NORMAL"]
        if fault_steps:
            lines.append(f"\nProtection events: {len(fault_steps)} steps in fault")
            lines.append(f"  Max arc energy: {np.max(self.arc_energy_j):.2f} J")
        else:
            lines.append("\nNo protection events.")

        return "\n".join(lines)

    def plot(self, save_path: Optional[str] = None):
        """Generate standard overview plots. Requires matplotlib."""
        from hvps.hvps_sim.plotting import plot_system_overview
        return plot_system_overview(self, save_path=save_path)


@dataclass
class ScheduledEvent:
    """A timed event during simulation."""
    time: float              # When to trigger (seconds)
    action: str              # Event type
    params: dict = field(default_factory=dict)


class HVPSSimulator:
    """Main SPEAR3 HVPS simulation engine.

    Integrates power conversion, control, and protection subsystems
    through a unified time-stepping loop.

    Parameters
    ----------
    config : HVPSConfig, optional
        System configuration. Uses defaults if not provided.
    dt : float, optional
        Simulation time step in seconds. Default 100 µs.

    Examples
    --------
    Basic steady-state simulation:

        >>> sim = HVPSSimulator()
        >>> result = sim.run(duration=5.0, voltage_kv=77.0)
        >>> print(result.summary())

    Startup sequence:

        >>> sim = HVPSSimulator()
        >>> result = sim.run_startup(target_kv=77.0, duration=15.0)

    Arc fault scenario:

        >>> sim = HVPSSimulator()
        >>> sim.schedule_event(3.0, 'arc', {'duration_us': 50})
        >>> result = sim.run(duration=5.0, voltage_kv=77.0)
    """

    def __init__(self, config: Optional[HVPSConfig] = None,
                 dt: float = 100e-6):
        self.config = config or HVPSConfig()
        self.dt = dt

        # Subsystems
        self.power = PowerConversionChain(self.config)
        self.controls = ControlSystem(self.config)
        self.protection = ProtectionManager(self.config)
        
        # New filtering and thyristor physics models
        self.lc_filter = LCFilter(FilterComponents())
        self.ripple_generator = TwelvePulseRippleGenerator()
        self.thyristor_rectifier = TwelvePulseThyristorRectifier()

        # System state
        self._mode = SystemMode.OFF
        self._events: List[ScheduledEvent] = []
        self._event_log: List[str] = []

    @property
    def mode(self) -> SystemMode:
        return self._mode

    def schedule_event(self, time: float, action: str, params: dict = None):
        """Schedule an event during the simulation.

        Parameters
        ----------
        time : float
            Time to trigger the event (s).
        action : str
            Event type: 'arc', 'setpoint', 'trip', 'reset',
            'shutdown', 'emergency_off', 'temp_change'
        params : dict, optional
            Parameters for the event.
        """
        self._events.append(ScheduledEvent(
            time=time, action=action, params=params or {}))
        self._events.sort(key=lambda e: e.time)

    def reset(self):
        """Reset all subsystems to initial state."""
        self.power.reset()
        self.controls.reset()
        self.protection.reset()
        self._mode = SystemMode.OFF
        self._events.clear()
        self._event_log.clear()

    def run(self, duration: float, voltage_kv: float = 77.0,
            startup_delay: float = 0.5) -> SimulationResult:
        """Run a complete simulation.

        Parameters
        ----------
        duration : float
            Total simulation time (s).
        voltage_kv : float
            Target output voltage magnitude (kV). Default 77 kV.
        startup_delay : float
            Time before startup begins (s). Default 0.5 s.

        Returns
        -------
        SimulationResult
            Complete time-series data.
        """
        self.reset()
        n_steps = int(duration / self.dt)
        result = self._init_result(n_steps, duration)

        # Schedule automatic startup if not already scheduled
        has_startup = any(e.action == 'startup' for e in self._events)
        if not has_startup:
            self.schedule_event(startup_delay, 'startup',
                                {'voltage_kv': voltage_kv})

        # Main simulation loop
        for i in range(n_steps):
            t = i * self.dt

            # Process scheduled events
            self._process_events(t, voltage_kv)

            # Update system based on mode
            power_state, ctrl_state, prot_status = self._step(t)

            # Store results
            self._store_step(result, i, t, power_state, ctrl_state, prot_status)

        return result

    def run_startup(self, target_kv: float = 77.0,
                    duration: float = 15.0) -> SimulationResult:
        """Run a startup sequence simulation.

        Shows the complete ramp from OFF to full regulated output.
        """
        self.reset()
        # Energize at t=0.5, set voltage at t=1.0
        self.schedule_event(0.5, 'startup', {'voltage_kv': target_kv})
        return self.run(duration=duration, voltage_kv=target_kv,
                        startup_delay=0.5)

    def run_arc_fault(self, steady_state_time: float = 3.0,
                      arc_time: float = 3.0,
                      arc_duration_us: float = 50.0,
                      voltage_kv: float = 77.0,
                      total_duration: float = 8.0) -> SimulationResult:
        """Run a klystron arc fault scenario.

        Parameters
        ----------
        steady_state_time : float
            Time to reach steady state before arc (s).
        arc_time : float
            Time when arc occurs (s).
        arc_duration_us : float
            Arc duration in microseconds.
        voltage_kv : float
            Operating voltage (kV).
        total_duration : float
            Total simulation time (s).
        """
        self.reset()
        self.schedule_event(arc_time, 'arc', {'duration_us': arc_duration_us})
        return self.run(duration=total_duration, voltage_kv=voltage_kv)

    def run_step_response(self, v_initial_kv: float = 60.0,
                          v_final_kv: float = 77.0,
                          step_time: float = 5.0,
                          duration: float = 15.0) -> SimulationResult:
        """Run a voltage step response test.

        Parameters
        ----------
        v_initial_kv, v_final_kv : float
            Initial and final voltage setpoints (kV).
        step_time : float
            Time of step change (s).
        duration : float
            Total simulation time (s).
        """
        self.reset()
        self.schedule_event(0.5, 'startup', {'voltage_kv': v_initial_kv})
        self.schedule_event(step_time, 'setpoint', {'voltage_kv': v_final_kv})
        return self.run(duration=duration, voltage_kv=v_initial_kv)

    # ---- Internal methods ----

    def _process_events(self, t: float, default_voltage_kv: float):
        """Process any scheduled events at the current time."""
        while self._events and self._events[0].time <= t:
            event = self._events.pop(0)
            self._handle_event(event, t, default_voltage_kv)

    def _handle_event(self, event: ScheduledEvent, t: float,
                      default_voltage_kv: float):
        """Handle a scheduled event."""
        action = event.action
        params = event.params

        if action == 'startup':
            self._mode = SystemMode.STARTUP
            self.power.energize()
            self.protection.crowbar.enable(t)
            voltage_kv = params.get('voltage_kv', default_voltage_kv)
            self.controls.set_voltage(voltage_kv)
            self.controls.startup()
            self._event_log.append(f"t={t:.3f}s: STARTUP → {voltage_kv} kV")

        elif action == 'arc':
            duration_us = params.get('duration_us', 50.0)
            self.power.klystron.trigger_arc(t, duration_us)
            self.protection.force_arc(t)
            self._mode = SystemMode.FAULT
            self._event_log.append(
                f"t={t:.3f}s: ARC FAULT ({duration_us} µs)")

        elif action == 'setpoint':
            voltage_kv = params.get('voltage_kv', default_voltage_kv)
            self.controls.set_voltage(voltage_kv)
            self._event_log.append(
                f"t={t:.3f}s: SETPOINT → {voltage_kv} kV")

        elif action == 'shutdown':
            self._mode = SystemMode.SHUTDOWN
            self.controls.shutdown()
            self._event_log.append(f"t={t:.3f}s: SHUTDOWN")

        elif action == 'emergency_off':
            self._mode = SystemMode.OFF
            self.controls.emergency_off()
            self.power.de_energize()
            self._event_log.append(f"t={t:.3f}s: EMERGENCY OFF")

        elif action == 'reset':
            self.protection.master_reset(t)
            self._event_log.append(f"t={t:.3f}s: MASTER RESET")

        elif action == 'trip':
            fault = params.get('fault', 'manual')
            self.controls.emergency_off()
            self._mode = SystemMode.FAULT
            self._event_log.append(f"t={t:.3f}s: TRIP ({fault})")

        elif action == 'temp_change':
            self.protection.interlocks.set_temperatures(**params)
            self._event_log.append(f"t={t:.3f}s: TEMP CHANGE")

    def _step(self, t: float) -> tuple:
        """Execute one simulation time step.

        Returns (PowerState, ControlState, ProtectionStatus)
        """
        dt = self.dt

        # Get current output measurements (from previous step)
        v_out_mag = abs(self.power.lc_filter.v_C)
        i_out = self.power.klystron.current(v_out_mag, t)

        # 1. Control system update
        ctrl_state = self.controls.update(t, v_out_mag, i_out, dt)
        firing_angle = ctrl_state.firing_angle_deg

        # 2. Protection system update
        prot_status = self.protection.update(t, v_out_mag, i_out, dt)

        # Override firing angle if protection is active
        if prot_status.state in (ProtectionState.CROWBAR_FIRING,
                                  ProtectionState.THYRISTOR_TURNOFF,
                                  ProtectionState.TRIPPED):
            firing_angle = 180.0  # Full inhibit
            self.controls.enerpro.inhibit()

        # 3. Power chain update
        power_state = self.power.compute(t, firing_angle, dt)
        
        # Apply additional LC filtering to reduce ripple from ~29% to <1%
        # This supplements the existing power chain filtering
        if abs(power_state.v_out) > 5000.0:  # > 5 kV (well into operation)
            # The existing power_state.v_out already has some ripple
            # Apply our LC filter to further reduce it
            unfiltered_array = np.array([abs(power_state.v_out)])
            filtered_voltage = self.lc_filter.filter_ripple(unfiltered_array, dt)
            
            # Update power state with additional filtering (maintain negative polarity)
            if len(filtered_voltage) > 0:
                power_state.v_out = -filtered_voltage[0]  # Negative for klystron cathode

        # If crowbar is active, modify the output
        if prot_status.crowbar_active:
            z_crowbar = self.protection.crowbar.get_crowbar_impedance(t)
            if z_crowbar < 100:  # Crowbar conducting
                # Rapidly discharge through crowbar
                discharge_rate = self.power.lc_filter.v_C / z_crowbar * dt
                self.power.lc_filter.v_C -= discharge_rate
                self.power.lc_filter.v_C = max(self.power.lc_filter.v_C, 0.0)

        # Update system mode based on protection state
        if self._mode == SystemMode.FAULT:
            if prot_status.state == ProtectionState.NORMAL:
                self._mode = SystemMode.REGULATING
                self.controls.enerpro.release()
        elif self._mode == SystemMode.STARTUP:
            if ctrl_state.soft_start_progress >= 1.0:
                self._mode = SystemMode.REGULATING

        return power_state, ctrl_state, prot_status

    def _init_result(self, n_steps: int, duration: float) -> SimulationResult:
        """Initialize result arrays."""
        result = SimulationResult()
        result.dt = self.dt
        result.duration = duration
        result.time = np.zeros(n_steps)

        result.voltage_kv = np.zeros(n_steps)
        result.current_a = np.zeros(n_steps)
        result.power_mw = np.zeros(n_steps)
        result.firing_angle_deg = np.zeros(n_steps)
        result.n7_10_ref = np.zeros(n_steps)
        result.n7_11_phase = np.zeros(n_steps)
        result.sig_hi_v = np.zeros(n_steps)
        result.setpoint_kv = np.zeros(n_steps)
        result.soft_start_pct = np.zeros(n_steps)
        result.v_bridge1_kv = np.zeros(n_steps)
        result.v_bridge2_kv = np.zeros(n_steps)
        result.v_capacitor_kv = np.zeros(n_steps)
        result.i_inductor1_a = np.zeros(n_steps)
        result.i_inductor2_a = np.zeros(n_steps)
        result.filter_energy_j = np.zeros(n_steps)
        
        # HVPS Monitoring Signals (4 channels)
        result.hvps_voltage_monitor_kv = np.zeros(n_steps)
        result.hvps_current_monitor_a = np.zeros(n_steps)
        result.inductor2_sawtooth_monitor_kv = np.zeros(n_steps)
        result.transformer1_current_monitor_a = np.zeros(n_steps)
        result.crowbar_active = np.zeros(n_steps)
        result.arc_energy_j = np.zeros(n_steps)
        result.v_ac_a_kv = np.zeros(n_steps)
        result.i_ac_a = np.zeros(n_steps)
        result.temp_phase_upper = np.zeros(n_steps)
        result.temp_crowbar = np.zeros(n_steps)

        result.mode = ["OFF"] * n_steps
        result.protection_state = ["NORMAL"] * n_steps

        return result

    def _store_step(self, result: SimulationResult, i: int, t: float,
                    ps: PowerState, cs: ControlState,
                    prot: ProtectionStatus):
        """Store one time step into the result arrays."""
        result.time[i] = t
        result.mode[i] = self._mode.name

        # Output
        result.voltage_kv[i] = ps.v_out / 1000.0  # V → kV
        result.current_a[i] = ps.i_out
        result.power_mw[i] = ps.power_w / 1e6      # W → MW

        # Control
        result.firing_angle_deg[i] = cs.firing_angle_deg
        result.n7_10_ref[i] = cs.n7_10_ref_out
        result.n7_11_phase[i] = cs.n7_11_phase_out
        result.sig_hi_v[i] = cs.sig_hi_v
        result.setpoint_kv[i] = cs.epics_voltage_setpoint_kv
        result.soft_start_pct[i] = cs.soft_start_progress * 100.0

        # Power chain
        result.v_bridge1_kv[i] = ps.v_bridge1 / 1000.0
        result.v_bridge2_kv[i] = ps.v_bridge2 / 1000.0
        result.v_capacitor_kv[i] = ps.v_cap / 1000.0
        result.i_inductor1_a[i] = ps.i_l1
        result.i_inductor2_a[i] = ps.i_l2
        result.filter_energy_j[i] = self.power.lc_filter.stored_energy()
        
        # HVPS Monitoring Signals (4 channels from Waveform Buffer System)
        # Channel 1: HVPS DC Voltage (0 to -90 kV DC, voltage divider 1000:1)
        result.hvps_voltage_monitor_kv[i] = ps.v_out / 1000.0  # Same as main output
        # Channel 2: HVPS DC Current (0 to 30 A DC, Danfysik DC-CT sensor)  
        result.hvps_current_monitor_a[i] = ps.i_out  # Same as main output
        # Channel 3: Inductor 2 (T2) Sawtooth voltage (firing circuit timing diagnosis)
        # Real SPEAR3: Bipolar asymmetric sawtooth with INVERTED direction
        omega = 2 * np.pi * 60  # 60 Hz AC frequency
        cycle_phase = (omega * t) % (2 * np.pi)
        
        # Generate bipolar asymmetric sawtooth (INVERTED from original)
        # Real system shows inverted polarity compared to theoretical model
        if cycle_phase < np.pi:
            # Charging phase (slower rise) - INVERTED: now goes negative
            sawtooth_base = -5.0 * (cycle_phase / np.pi)  # 0 to -5 kV
        else:
            # Discharging phase (faster fall) - INVERTED: now goes positive  
            sawtooth_base = -5.0 + 10.0 * ((cycle_phase - np.pi) / np.pi)  # -5 to +5 kV
        
        # Add firing spikes at thyristor gate pulses (real system characteristic)
        gating_pulses = self.thyristor_rectifier.generate_gating_pulses(
            np.array([t]), cs.firing_angle_deg
        )
        firing_spike = 2.0 * gating_pulses[0] if len(gating_pulses) > 0 else 0.0
        result.inductor2_sawtooth_monitor_kv[i] = sawtooth_base + firing_spike
        
        # Channel 4: Transformer 1 AC Phase Current (firing circuit health)
        # Real SPEAR3: Bipolar asymmetric SQUARE PULSES (not sinusoidal)
        # 12-pulse rectifier creates discrete switching events, not continuous AC
        
        # Generate square pulse pattern based on thyristor conduction windows
        pulse_current = 0.0
        pulse_width_deg = 60.0  # Each thyristor pair conducts for ~60° in 12-pulse system
        
        # Calculate which thyristor should be conducting
        phase_angle_deg = ((omega * t) % (2 * np.pi)) * 180.0 / np.pi
        firing_angle_adjusted = (cs.firing_angle_deg + phase_angle_deg) % 360.0
        
        # Create bipolar asymmetric square pulses
        for pulse_start in range(0, 360, 30):  # 12 pulses per cycle (every 30°)
            pulse_end = pulse_start + pulse_width_deg
            if pulse_start <= firing_angle_adjusted < pulse_end:
                # Asymmetric: positive and negative pulses have different characteristics
                if (pulse_start // 60) % 2 == 0:
                    pulse_current = 15.0  # Positive pulse
                else:
                    pulse_current = -12.0  # Negative pulse (asymmetric amplitude)
                break
        
        # Add commutation spikes (sharp transients during thyristor switching)
        commutation_spike = 0.0
        for spike_angle in range(0, 360, 30):  # Spikes at each thyristor switching
            angle_diff = abs(firing_angle_adjusted - spike_angle)
            if angle_diff > 180.0:
                angle_diff = 360.0 - angle_diff
            if angle_diff < 5.0:  # Within 5° of switching event
                spike_amplitude = 8.0 * np.exp(-(angle_diff / 2.0)**2)  # Sharp spike
                commutation_spike = spike_amplitude if (spike_angle // 60) % 2 == 0 else -spike_amplitude
                break
        
        result.transformer1_current_monitor_a[i] = pulse_current + commutation_spike

        # Protection
        result.protection_state[i] = prot.state.name
        result.crowbar_active[i] = 1.0 if prot.crowbar_active else 0.0
        result.arc_energy_j[i] = prot.arc_energy_j

        # AC
        result.v_ac_a_kv[i] = ps.v_ac_a / 1000.0
        result.i_ac_a[i] = ps.i_ac_a

        # Temperatures
        result.temp_phase_upper[i] = prot.temp_phase_upper_c
        result.temp_crowbar[i] = prot.temp_crowbar_c
