# SPEAR3 HVPS Simulink Model

## Overview

MATLAB/Simulink model of the SPEAR3 High Voltage Power Supply (HVPS) system at SLAC National Accelerator Laboratory. This model implements a switching-level simulation of the complete 12-pulse thyristor phase-controlled rectifier using Simscape Electrical (Specialized Power Systems) blocks.

**System Specifications:**
- **Output:** -77 kV DC @ 22 A (1.7 MW nominal)
- **Input:** 12.47 kV 3-phase AC, 60 Hz
- **Topology:** 12-pulse thyristor phase-controlled rectifier with star-point controller
- **Architecture:** Based on PEP-II klystron power supply design (SLAC, 1997)

## Requirements

- MATLAB R2020b or later
- Simulink
- Simscape Electrical / Specialized Power Systems toolbox (`powerlib`)

## Quick Start

```matlab
% 1. Run the model builder script
spear3_hvps_simulink_model

% 2. Open the generated model
open_system('SPEAR3_HVPS')

% 3. Run the simulation
sim('SPEAR3_HVPS')

% 4. Analyze results
plot_spear3_overview(t, V_out_kV, I_out_A, alpha_deg)
analyze_ripple(t, V_out_kV, 0.3)
```

## Model Architecture

```
Substation 507 (12.47 kV, 60 Hz, 3-phase)
    │
    ├──► T0a Phase-Shift Transformer (+15°) ──► T1 Rectifier Xfmr (2.67:1) ──► Bridge1 SCR (6-pulse)
    │                                                                              │
    └──► T0b Phase-Shift Transformer (-15°) ──► T2 Rectifier Xfmr (2.67:1) ──► Bridge2 SCR (6-pulse)
                                                                                   │
                                                    [12-pulse DC output, series connected]
                                                                │
                                                    L1 + L2 (0.3 H each)
                                                                │
                                                    C_Filter (8 µF) + R_iso (500 Ω)
                                                                │
                                                    L3 Cable Termination (200 µH)
                                                                │
                                                    Klystron Load (3500 Ω)
                                                                │
                                                    ══════ GND ══════

Control System:
    V_measured ──► PLC LPF (α=0.4, T=10ms) ──► PI Regulator (Kp=2, Ki=8)
    I_measured     with soft-start ramp           ──► Enerpro Mapping (SIG HI → α)
                                                       ──► 6-Pulse Generators → SCR Gates

Protection:
    Crowbar SCR (4 stacks, 100 kV, ~1 µs fiber-optic trigger)
    Arc detection (dV/dt, current spike, voltage drop)
    4-layer protection: Passive → Semi-active → Active → Cable termination
```

## Subsystem Details

### Power Conversion Chain

| Component | Block Type | Key Parameters |
|-----------|-----------|----------------|
| AC Source | Three-Phase Source | 12.47 kV RMS, 60 Hz, Yg |
| T0a/T0b | Three-Phase Transformer | 3.5 MVA, ±15° phase shift |
| T1/T2 | Three-Phase Transformer | 1.5 MVA, 2.67:1 step-up |
| Bridge1/2 | Universal Bridge (Thyristor) | 6-pulse, snubber R=100Ω C=0.1µF |
| L1/L2 | Series RLC Branch | 0.3 H, 0.5 Ω winding resistance |
| C_Filter | Series RLC Branch | 8 µF, 500 Ω isolation resistor |
| L3 | Series RLC Branch | 200 µH cable termination |
| Klystron | Series RLC Branch | 3500 Ω (nominal) |

### Control System

| Component | Implementation | Parameters |
|-----------|---------------|------------|
| EPICS Setpoint | Constant block | 77 kV |
| Soft-Start | Ramp + Saturation | 5 s ramp time |
| PLC LPF (Rung 104) | Discrete Transfer Fcn | α=0.4, T=10ms, τ≈20ms |
| PI Regulator | PID Controller block | Kp=2.0, Ki=8.0 |
| Enerpro Mapping | Gain + Bias | 0.9V→150°, 5.9V→30° |
| PLL Dynamics | Transfer Function | τ=50ms (3 AC cycles) |

### Key Equations

**12-Pulse DC Output:**
```
V_dc = (6√2/π) × V_LL × cos(α) ≈ 2.70 × V_LL × cos(α)
```

**Operating Points:**
| Parameter | α = 0° | Nominal (77 kV) | Measured (June 2020) |
|-----------|--------|-----------------|---------------------|
| cos(α) | 1.000 | 0.856 | 0.801 |
| α | 0° | 31.1° | 36.8° |
| V_dc | 90.0 kV | 77.0 kV | 72.1 kV |

**LC Filter:**
- Resonance: fc ≈ 103 Hz
- 720 Hz attenuation: ~37 dB (≈70x reduction)
- Unfiltered ripple: 3.41% P-P → Filtered: <0.02% P-P

## Simulation Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| Solver | `ode23tb` | Stiff solver for power electronics |
| Max step | 10 µs | Captures SCR switching dynamics |
| Stop time | 0.5 s | Covers startup + steady state |
| Rel. tolerance | 1e-4 | Balance accuracy vs speed |

## Analysis Functions

The script includes three analysis functions:

1. **`plot_spear3_overview(t, V, I, alpha)`** — 4-panel overview (voltage, current, firing angle, power)
2. **`analyze_ripple(t, V, t_start)`** — Ripple P-P, RMS, and FFT spectrum analysis
3. **`analyze_protection(t, V, I, arc_time)`** — Arc event zoom and energy calculation

## Testing Scenarios

### Normal Operation
Run with default parameters. Expected: -77 kV stable, <1% ripple, ~22 A.

### Arc Fault Test
Set `Crowbar_Trigger` step time to occur during simulation:
```matlab
set_param('SPEAR3_HVPS/Crowbar_Trigger', 'Time', '0.3');
sim('SPEAR3_HVPS');
analyze_protection(t, V, I, 0.3);
```

### Startup Sequence
Increase simulation time and observe soft-start ramp:
```matlab
set_param('SPEAR3_HVPS', 'StopTime', '8');
sim('SPEAR3_HVPS');
```

## Correspondence to Python Simulation

| Python Module | Simulink Component |
|--------------|-------------------|
| `config.py` | Section 1: System Parameters (struct `P`) |
| `power.py` → `ACSource` | AC_Source_12kV block |
| `power.py` → `PhaseShiftTransformer` | T0a/T0b blocks |
| `power.py` → `RectifierTransformer` | T1/T2 blocks |
| `power.py` → `SixPulseBridge` | Bridge1_SCR / Bridge2_SCR (Universal Bridge) |
| `power.py` → `LCFilter` | L1, L2, C_Filter, R_Damping blocks |
| `power.py` → `KlystronLoad` | Klystron_Load block |
| `controls.py` → `PLCController` | PLC_LPF (Discrete Transfer Fcn) |
| `controls.py` → `RegulatorBoard` | PI_Regulator (PID Controller) |
| `controls.py` → `EnerproFiringBoard` | Enerpro_Gain + Enerpro_Offset + PLL |
| `protection.py` → `CrowbarSystem` | Crowbar_SCR (Breaker) + Trigger |
| `simulator.py` | Top-level model with solver config |

## Notes

- **Port naming**: The `add_line()` calls use standard Specialized Power Systems port naming. If your MATLAB version uses different port conventions, manual wiring adjustments may be needed. The script wraps wiring in try/catch blocks and reports which connections need attention.
- **Klystron perveance model**: The basic model uses a fixed resistor (3500 Ω). For the nonlinear perveance model `I = κV^(3/2)`, replace `Klystron_Load` with a MATLAB Function block implementing the Child-Langmuir law.
- **Secondary rectifiers (D1-D24)**: The 4 diode bridge stages are simplified in this model. For detailed secondary rectifier modeling, add additional Universal Bridge blocks configured with diodes.
- **Star-point controller**: The actual system uses SCR star-point control on the primary side. This model approximates this with conventional thyristor bridge phase control, which produces equivalent DC output characteristics.

## Reference Documents

- `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md`
- `hvps/architecture/technical-notes/01-pepii-power-supply-architecture.md`
- `hvps/architecture/technical-notes/04-regulator-board-design.md`
- `hvps/controls/enerpro/technical-notes/` (00-08)
- `hvps/documentation/plc/technical-notes/` (01-09)
- `hvps/simulation/hvps_sim/` (Python simulation for comparison)
