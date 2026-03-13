# HVPS Schematic Generation Summary

Generated on: 2026-03-13 17:21:39

## Generated Schematics

### 1. LC Filter Circuit (`hvps_lc_filter.png`)
- **Purpose**: Detailed LC filter topology with exact component values
- **Components**: L1=0.3H, L2=0.3H, C=8μF, R=500Ω
- **Analysis**: Resonant frequency ~103Hz, 48x attenuation @ 720Hz
- **Key Feature**: PEP-II isolation resistor design for arc protection

### 2. 12-Pulse Rectifier Overview (`hvps_12pulse_overview.png`)
- **Purpose**: Complete 12-pulse rectifier topology
- **Components**: Phase-shift transformer T0, rectifier transformers T1/T2
- **Configuration**: Star point controller with ±15° phase shift
- **Output**: 720Hz ripple frequency, ~0.5% before filtering

### 3. System Block Diagram (`hvps_system_blocks.png`)
- **Purpose**: Complete HVPS system overview
- **Power Flow**: 12.47kV input → -77kV @ 22A output
- **Subsystems**: Power conversion, control, and protection
- **Specifications**: 1.7MW nominal, 2.5MW maximum capability

### 4. Control System Hierarchy (`hvps_control_hierarchy.png`)
- **Purpose**: Complete control system architecture
- **Chain**: EPICS → VXI → PLC → Regulator → Enerpro FCOG1200
- **Feedback**: HV divider, current transformer, temperature monitoring
- **Performance**: ±0.5% regulation, <10ms response time

## System Specifications

- **Output**: -77 kV DC @ 22 A (1.7 MW nominal)
- **Input**: 12.47 kV RMS, 3-phase, 60 Hz
- **Topology**: 12-pulse thyristor phase-controlled rectifier
- **Filter**: L1=L2=0.3H, C=8μF, R=500Ω
- **Ripple**: <1% P-P, <0.2% RMS (specification)
- **Regulation**: ±0.5% at voltages >65 kV
- **SCR Count**: 168 total (12 stacks × 14 SCRs each)

## Validation Notes

All component values and specifications are derived from comprehensive
documentation review of SPEAR3 HVPS technical documents. These schematics
provide visual validation for simulation implementation and enable
comparison with documented system architecture.

**Critical for T1 AC Current Analysis:**
- 12-pulse rectification creates 720Hz ripple (not 360Hz)
- ±15° phase shift eliminates 5th and 7th harmonics
- LC filter provides ~48x attenuation at 720Hz
- Expected near-sinusoidal current waveform due to excellent filtering
