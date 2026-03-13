"""
SPEAR3 HVPS System Configuration
=================================

All parameters are derived from the legacy system technical documentation:
  - 00-spear3-hvps-legacy-system-design.md
  - 01-pepii-power-supply-architecture.md
  - 04-regulator-board-design.md
  - Enerpro technical notes (00-08)
  - PLC technical notes (01-09)
  - SD-237-230-14 Regulator Board Analysis
  - 00_HVPS_SYSTEM_OVERVIEW.md
"""

from dataclasses import dataclass, field
import math


@dataclass
class ACInputConfig:
    """12.47 kV 3-phase AC input from Substation 507, Breaker 160."""
    voltage_rms: float = 12_470.0       # V RMS line-to-line
    frequency: float = 60.0             # Hz
    phases: int = 3
    # Derived
    @property
    def voltage_peak(self) -> float:
        return self.voltage_rms * math.sqrt(2)
    @property
    def omega(self) -> float:
        return 2.0 * math.pi * self.frequency
    @property
    def period(self) -> float:
        return 1.0 / self.frequency


@dataclass
class PhaseShiftTransformerConfig:
    """T0 — Extended Delta phase-shift transformer (3.5 MVA)."""
    rating_mva: float = 3.5
    primary_voltage: float = 12_470.0   # V RMS (delta)
    phase_shift_deg: float = 15.0       # ±15° dual wye secondary
    turns_ratio: float = 1.0            # Nominally 1:1 for phase shifting
    leakage_reactance_pu: float = 0.05  # ~5% leakage
    copper_loss_pu: float = 0.01        # ~1% copper losses
    core_loss_pu: float = 0.005         # ~0.5% core losses


@dataclass
class RectifierTransformerConfig:
    """T1/T2 — Rectifier transformers (1.5 MVA each)."""
    rating_mva: float = 1.5
    primary_voltage: float = 12_500.0   # V RMS (open wye, floating neutral)
    secondary_voltage: float = 12_500.0 # V RMS per secondary winding
    phase_shift_deg: float = 15.0       # +15° for T1, -15° for T2
    leakage_reactance_pu: float = 0.06
    copper_loss_pu: float = 0.012
    core_loss_pu: float = 0.005


@dataclass
class ThyristorBridgeConfig:
    """6-pulse SCR bridge — Powerex T8K7 thyristors."""
    num_stacks: int = 6                 # 6 SCR stacks per bridge
    scrs_per_stack: int = 14            # 14 series SCRs per stack
    voltage_rating: float = 40_000.0    # V per stack
    current_rating: float = 80.0        # A per stack
    on_voltage_drop: float = 1.5        # V per SCR (forward drop)
    turn_on_time_us: float = 5.0        # µs
    turn_off_time_us: float = 100.0     # µs
    # Snubber network per stack
    snubber_r: float = 100.0            # Ω
    snubber_c: float = 0.1e-6           # F (0.1 µF)


@dataclass
class FilterConfig:
    """Primary filter inductors and secondary filter network."""
    # Primary filter inductors L1, L2
    inductor_l1_h: float = 0.3          # H (350 µH per doc variant)
    inductor_l2_h: float = 0.3          # H
    inductor_current_rating: float = 85.0  # A
    inductor_stored_energy_j: float = 1084.0  # J each at rated current
    # Secondary filter capacitor bank
    capacitor_uf: float = 8.0           # µF total (confirmed from SPEAR3 docs)
    capacitor_voltage_rating: float = 100_000.0  # V
    # Isolation resistors (PEP-II design)
    isolation_resistance: float = 500.0  # Ω
    # Voltage divider
    voltage_divider_ratio: float = 1000.0  # 1000:1
    # Cable termination inductors L3, L4
    cable_inductor_l3_uh: float = 200.0  # µH
    cable_inductor_l4_uh: float = 200.0  # µH


@dataclass
class SecondaryRectifierConfig:
    """Secondary diode rectifier bridges (D1-D24)."""
    # Main power bridge
    main_voltage_rating: float = 30_000.0  # V
    main_current_rating: float = 30.0      # A
    # Filter bridge
    filter_voltage_rating: float = 30_000.0  # V
    filter_current_rating: float = 3.0       # A
    # Combined capability
    total_voltage_capability: float = 120_000.0  # V (4 bridges series)
    diode_forward_drop: float = 1.0              # V per diode


@dataclass
class CrowbarConfig:
    """Crowbar SCR protection system (SCR13-16)."""
    num_stacks: int = 4                   # 4 series SCR stacks
    voltage_rating: float = 100_000.0     # V
    current_rating: float = 80.0          # A per stack
    trigger_delay_us: float = 1.0         # µs (fiber-optic trigger)
    trigger_type: str = "fiber_optic"
    enable_timer_s: float = 8.0           # 8-second enable delay (T4:12)
    # dV/dt snubber networks
    snubber_r: float = 50.0               # Ω
    snubber_c: float = 0.22e-6            # F


@dataclass
class PLCConfig:
    """Allen-Bradley SLC-5/03 PLC control parameters."""
    # Digital low-pass filter (Rung 104)
    scan_period_s: float = 0.080          # 80 ms scan period
    filter_alpha: float = 0.1             # α = 1/10
    # Derived time constant: τ = -T/ln(1-α) ≈ 0.76 s
    @property
    def time_constant_s(self) -> float:
        return -self.scan_period_s / math.log(1.0 - self.filter_alpha)

    # Voltage reference (N7:10)
    ref_max_internal: int = 32000         # N7:32
    ref_min_internal: int = 100           # N7:31
    ref_max_external: int = 26869         # N7:33

    # Phase angle (N7:11)
    phase_multiplier: int = 12000         # N7:40
    phase_offset: int = 6000              # N7:41
    phase_max: int = 18000                # N7:42
    phase_divisor: int = 32767            # Full-scale 16-bit

    # DAC scaling
    dac_bits: int = 16
    dac_max: int = 32767

    # Initialization
    init_ref_out: int = 0                 # N7:10 = 0 on startup
    init_phase_out: int = 0               # N7:11 = 0 on startup


@dataclass
class EnerproConfig:
    """Enerpro FCOG1200 SCR firing board parameters."""
    # SIG HI command input
    sig_hi_min_v: float = 0.9             # V minimum
    sig_hi_max_v: float = 5.9             # V maximum
    sig_hi_impedance: float = 10_000.0    # Ω (R40)
    # Phase control
    min_delay_angle_deg: float = 30.0     # α₀ minimum
    max_delay_angle_deg: float = 150.0    # Maximum firing angle
    # PLL parameters
    vco_base_freq_hz: float = 23_040.0    # 384 × 60 Hz
    pll_settling_cycles: int = 3          # AC cycles for step change
    # Transfer function
    bandwidth_hz: float = 66.0            # -3dB at ~415 rad/s
    gain_peak_db: float = 0.81            # at 60 rad/s
    dc_gain: float = 1.0                  # unity
    # Auto-balance
    auto_balance_enabled: bool = True
    balance_tolerance_pct: float = 5.0    # ±5% current match


@dataclass
class RegulatorBoardConfig:
    """SLAC SD-237-230-14-C1 regulator board parameters."""
    # Voltage control
    voltage_gain: float = 1.0             # INA117 unity gain
    voltage_bandwidth_hz: float = 300_000.0  # INA117 bandwidth
    # Current control
    current_gain: float = 1.0
    current_limit_a: float = 30.0         # A maximum
    # Output driver
    output_buffer_bandwidth_hz: float = 30e6  # BUF634 30 MHz
    output_current_max_a: float = 0.250   # BUF634 250 mA
    # Soft-start
    soft_start_time_s: float = 5.0        # seconds to full output
    # Summing resistors to Enerpro SIG HI
    reg_to_sighi_r: float = 7_500.0       # Ω (regulator output)
    plc_to_sighi_r: float = 1_000.0       # Ω (PLC N7:11 output)
    # Op-amp specs
    op77_gbw_hz: float = 600_000.0        # OP77 gain-bandwidth
    mc34074_gbw_hz: float = 4_500_000.0   # MC34074 gain-bandwidth
    # Protection thresholds
    overvoltage_trip_kv: float = 85.0
    overcurrent_trip_a: float = 28.0


@dataclass
class OutputConfig:
    """Nominal output specifications."""
    voltage_nominal_kv: float = -77.0     # kV (negative polarity)
    voltage_max_kv: float = -90.0         # kV maximum
    current_nominal_a: float = 22.0       # A
    current_max_a: float = 30.0           # A
    power_nominal_mw: float = 1.7         # MW
    power_max_mw: float = 2.5             # MW
    # Regulation specs
    voltage_regulation_pct: float = 0.5   # ±0.5% at >65 kV
    current_regulation_pct: float = 1.0   # ±1% at >10 A
    ripple_pp_pct: float = 1.0            # <1% peak-to-peak
    ripple_rms_pct: float = 0.2           # <0.2% RMS
    stability_pct_per_hour: float = 0.1   # <0.1%/hour
    # Dynamic performance
    voltage_response_ms: float = 10.0     # <10 ms for 10% step
    arc_recovery_ms: float = 100.0        # <100 ms
    restart_time_s: float = 30.0          # <30 s complete restart
    # Arc protection
    arc_energy_with_crowbar_j: float = 5.0    # <5 J
    arc_energy_without_crowbar_j: float = 20.0  # <20 J


@dataclass
class EfficiencyConfig:
    """System efficiency parameters."""
    overall_efficiency: float = 0.92      # >92% at full load
    transformer_loss_pct: float = 2.0     # ~2%
    rectifier_loss_pct: float = 3.0       # ~3%
    filter_loss_pct: float = 1.0          # ~1%
    power_factor: float = 0.95            # >0.95 at full load
    thd_pct: float = 5.0                  # <5% THD


@dataclass
class KlystronLoadConfig:
    """Klystron load model parameters."""
    # Normal operation
    impedance_nominal: float = 3500.0     # Ω (77kV / 22A)
    # Arc fault model
    arc_impedance: float = 10.0           # Ω during arc
    arc_probability_per_hour: float = 0.1 # random arcs
    arc_duration_us: float = 50.0         # µs typical arc
    # Beam characteristics
    perveance: float = 2.0e-6             # A/V^(3/2) — klystron perveance


@dataclass
class InterlocksConfig:
    """Safety interlock thresholds."""
    # Temperature (thermocouple readings)
    temp_phase_upper_max_c: float = 80.0  # °C (N7:100)
    temp_phase_lower_max_c: float = 80.0  # °C (N7:101)
    temp_crowbar_max_c: float = 60.0      # °C (N7:102)
    temp_cabinet_max_c: float = 50.0      # °C (N7:103)
    # Overcurrent
    ac_overcurrent_a: float = 160.0       # A (per phase)
    dc_overcurrent_a: float = 28.0        # A
    # Overvoltage
    overvoltage_kv: float = 85.0          # kV


@dataclass
class HVPSConfig:
    """Complete HVPS system configuration."""
    ac_input: ACInputConfig = field(default_factory=ACInputConfig)
    phase_shift_xfmr: PhaseShiftTransformerConfig = field(default_factory=PhaseShiftTransformerConfig)
    rect_xfmr: RectifierTransformerConfig = field(default_factory=RectifierTransformerConfig)
    thyristor_bridge: ThyristorBridgeConfig = field(default_factory=ThyristorBridgeConfig)
    filter: FilterConfig = field(default_factory=FilterConfig)
    secondary_rect: SecondaryRectifierConfig = field(default_factory=SecondaryRectifierConfig)
    crowbar: CrowbarConfig = field(default_factory=CrowbarConfig)
    plc: PLCConfig = field(default_factory=PLCConfig)
    enerpro: EnerproConfig = field(default_factory=EnerproConfig)
    regulator: RegulatorBoardConfig = field(default_factory=RegulatorBoardConfig)
    output: OutputConfig = field(default_factory=OutputConfig)
    efficiency: EfficiencyConfig = field(default_factory=EfficiencyConfig)
    klystron: KlystronLoadConfig = field(default_factory=KlystronLoadConfig)
    interlocks: InterlocksConfig = field(default_factory=InterlocksConfig)

    def summary(self) -> str:
        """Return a human-readable summary of key parameters."""
        lines = [
            "SPEAR3 HVPS Configuration Summary",
            "=" * 45,
            f"AC Input:    {self.ac_input.voltage_rms/1000:.2f} kV RMS, "
            f"{self.ac_input.frequency} Hz, {self.ac_input.phases}-phase",
            f"Output:      {self.output.voltage_nominal_kv} kV DC @ "
            f"{self.output.current_nominal_a} A",
            f"Power:       {self.output.power_nominal_mw} MW nominal, "
            f"{self.output.power_max_mw} MW max",
            f"Regulation:  ±{self.output.voltage_regulation_pct}% voltage, "
            f"±{self.output.current_regulation_pct}% current",
            f"Ripple:      <{self.output.ripple_pp_pct}% P-P, "
            f"<{self.output.ripple_rms_pct}% RMS",
            f"Efficiency:  >{self.efficiency.overall_efficiency*100:.0f}%",
            f"PLC Filter:  τ = {self.plc.time_constant_s:.3f} s "
            f"(α={self.plc.filter_alpha}, T={self.plc.scan_period_s*1000:.0f} ms)",
            f"Crowbar:     {self.crowbar.trigger_delay_us} µs trigger, "
            f"{self.crowbar.num_stacks} stacks",
            f"Arc Energy:  <{self.output.arc_energy_with_crowbar_j} J (with crowbar)",
        ]
        return "\n".join(lines)
