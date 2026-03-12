# SPEAR3 HVPS Legacy System Simulation

A physics-based simulation package for the SPEAR3 High Voltage Power Supply (HVPS) system at SLAC National Accelerator Laboratory.

## System Overview

The SPEAR3 HVPS delivers **-77 kV DC @ 22 A (1.7 MW)** to power the SPEAR3 storage ring klystrons. Based on the PEP-II design (1997), it uses a **12-pulse thyristor phase-controlled rectifier** with star-point controller topology.

```
12.47 kV 3φ AC  →  Phase-Shift Xfmr (T0, 3.5 MVA)
                →  Rectifier Xfmrs (T1/T2, 1.5 MVA each)
                →  12-Pulse SCR Rectifier (2 × 6-pulse bridges)
                →  Filter Network (L: 0.3H, C: 8µF)
                →  Secondary Rectifiers (D1-D24)
                →  Crowbar Protection (SCR13-16, ~1µs trigger)
                →  Cable Termination (L3/L4, 200µH)
                →  -77 kV DC Output → Klystron
```

## Package Structure

```
hvps_sim/
├── __init__.py        # Package initialization
├── config.py          # System parameters (all from documentation)
├── power.py           # Power conversion chain models
├── controls.py        # PLC + Regulator + Enerpro control system
├── protection.py      # 4-layer arc protection + safety interlocks
├── simulator.py       # Main simulation engine
├── plotting.py        # Visualization tools
├── examples.py        # Runnable demonstration scenarios
└── README.md          # This file
```

## Quick Start

```python
from hvps.hvps_sim import HVPSSimulator, HVPSConfig

# Create simulator with default configuration
sim = HVPSSimulator()

# Run steady-state at -77 kV
result = sim.run(duration=5.0, voltage_kv=77.0)
print(result.summary())

# Plot results (requires matplotlib)
result.plot()
```

## Example Scenarios

```python
from hvps.hvps_sim.examples import (
    run_normal_operation,    # Steady-state at -77 kV / 22 A
    run_startup_sequence,    # Full startup with soft-start ramp
    run_arc_fault,           # Klystron arc with crowbar response
    run_step_response,       # 60 kV → 77 kV setpoint change
    run_power_quality_analysis,  # Ripple and regulation analysis
    run_crowbar_test,        # Forced crowbar and recovery
    run_all,                 # Run everything
)

# Run all scenarios
results = run_all(plot=True)
```

## Key Simulation Features

### Power Conversion
- 3-phase AC source (12.47 kV, 60 Hz)
- Phase-shift transformer with ±15° dual wye (12-pulse operation)
- 6-pulse SCR bridges with phase-angle control and ripple model
- LC filter with inductor current and capacitor voltage dynamics
- Klystron load model with perveance law (I = κV^3/2)

### Control System
- **PLC (SLC-5/03)**: Exact digital low-pass filter from ladder logic
  - `N7:10 += (N7:30 - N7:10) / 10` every 80 ms → τ ≈ 0.76 s
  - `N7:11 = 0.3662 × N7:10 + 6000` (phase angle calculation)
  - Integer arithmetic with clamping (matches PLC behavior)
- **Regulator Board (SD-237-230-14)**: PI controller with soft-start
- **Enerpro FCOG1200**: PLL-based firing angle with dynamic response

### Protection System
- **4-Layer Arc Protection**:
  1. Current limiting via filter inductors
  2. Crowbar SCR activation (~1 µs fiber-optic trigger)
  3. Primary thyristor turn-off (4-8 ms)
  4. Cable termination inductors (200 µH)
- Arc energy tracking (<5 J with crowbar, <20 J without)
- Safety interlocks (temperature, pressure, vacuum, oil, OC, OV)
- Fault latching with master reset (matches PLC B3:4 register)

### Simulation Engine
- Configurable time step (default 100 µs)
- System mode state machine: OFF → STARTUP → REGULATING → FAULT → RECOVERY
- Scheduled events (arc, setpoint change, trip, reset)
- Comprehensive data logging

## Configuration

All parameters come from the legacy system documentation:

```python
from hvps.hvps_sim.config import HVPSConfig

config = HVPSConfig()
print(config.summary())

# Customize parameters
config.output.voltage_nominal_kv = -77.0
config.plc.filter_alpha = 0.1          # τ ≈ 0.76 s
config.plc.scan_period_s = 0.080       # 80 ms
config.crowbar.trigger_delay_us = 1.0  # 1 µs fiber-optic
```

## Dependencies

- **Required**: `numpy` (numerical computation)
- **Optional**: `matplotlib` (plotting)

## Documentation References

This simulation is based on the following legacy system documents:
- `00-spear3-hvps-legacy-system-design.md` — Complete system design report
- `01-pepii-power-supply-architecture.md` — PEP-II foundation architecture
- `04-regulator-board-design.md` — SLAC SD-237-230-14 board analysis
- `05-control-algorithms.md` — PLC control algorithm details
- `06-control-theory.md` — Enerpro PLL control theory
- `06-safety-interlock-systems.md` — Safety and interlock system details
- `00_HVPS_SYSTEM_OVERVIEW.md` — Complete schematic-based system overview

