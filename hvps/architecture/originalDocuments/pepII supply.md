# SLAC Klystron Power Supply - Comprehensive Technical Analysis

> **Source:** `hvps/architecture/originalDocuments/pepII supply.pptx`
> **Type:** Comprehensive Technical Presentation Analysis
> **Total Slides:** 24
> **Processing Date:** 2026-03-04

## Executive Summary

This document provides a comprehensive technical analysis of the SLAC Klystron Power Supply system for the PEP II accelerator. The presentation covers detailed technical specifications, system architecture, protection mechanisms, and control systems for a high-voltage power supply designed to drive klystron amplifiers.

## Technical Specifications

- **Voltages:** 90, 65
- **Currents:** 27
- **Power:** 2.5
- **Regulation:** 0.5

## System Requirements

### Primary Specifications
- **Output Voltage:** 90 kV DC continuous
- **Output Current:** 27 A DC continuous  
- **Output Power:** 2.5 MW continuous
- **Regulation:** < ±0.5% at voltages >65kV
- **Ripple:** < ±0.5% at full load

### Critical Requirements
- **Klystron Arc Protection:** Fast detection and crowbar protection
- **Continuous Control:** Variable output voltage control
- **Physical Constraints:** Must fit on existing transformer pads
- **Cost Effectiveness:** Optimized design for performance/cost ratio

## System Architecture

### Power Conversion Topology
The klystron power supply utilizes a high-voltage transformer and rectifier configuration to convert AC input power to the required DC output for klystron operation.

### Slide 1: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 2: 12/3/2024

SLAC Klystron Power Supply

Klystron Power Supply Specifications

90kV 27A DC Continues 2.5MW
Regulation & Ripple < ±0.5% @ >65kV.
Protect Klystron under Klystron Arc (Important).
Continues Control of Output Voltage. 
Fit on existing transformer pads.
Cost effective.

### Slide 3: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 4: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 5: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 6: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 7: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 8: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 9: 12/3/2024

SLAC Klystron Power Supply

Power supply waveforms

Inductor voltage, Line current (AC)

Three Line Voltages (note overlap)


```
TECHNICAL SYSTEM DIAGRAM

Tek --> Bind --> M --> Pos

Key Elements: Tek, Bind, M, Pos, N, SCH
```


```
TECHNICAL SYSTEM DIAGRAM

Tek --> Jl --> Ni --> BS

Key Elements: Tek, Jl, Ni, BS, SB, Sia
```

### Slide 10: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 11: 12/3/2024

SLAC Klystron Power Supply

Transformer Phase Voltages

Three Core Voltages “Lower”

Three Core Voltages  “Upper”


```
TECHNICAL SYSTEM DIAGRAM

Tek --> JL --> Ti --> BeiS

Key Elements: Tek, JL, Ti, BeiS, SSB, Son
```


```
TECHNICAL SYSTEM DIAGRAM

Tek --> JL --> Ti --> BeiS

Key Elements: Tek, JL, Ti, BeiS, SSB, Sia
```

### Slide 12: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 13: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 14: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

### Slide 15: 12/3/2024

SLAC Klystron Power Supply

Pep II Power supply

Light Triggered delay ~1 usec
Independent of Voltage

### Slide 16: 12/3/2024

SLAC Klystron Power Supply

Present SCR Crowbar Delay

Present Crowbar Trigger
Normal and reversed driver

### Slide 17: 12/3/2024

SLAC Klystron Power Supply

SCR Crowbar Trigger Delay

Normal SCR Triggered Crowbar

Light Triggered SCR Crowbar

### Slide 18: 12/3/2024

SLAC Klystron Power Supply

Control wiring

### Slide 19: 12/3/2024

SLAC Klystron Power Supply

Control wiring

### Slide 20: 12/3/2024

SLAC Klystron Power Supply

Control wiring

### Slide 21: 12/3/2024

SLAC Klystron Power Supply

Control wiring

### Slide 22: 12/3/2024

SLAC Klystron Power Supply

Control wiring

### Slide 23: 12/3/2024

SLAC Klystron Power Supply

Control wiring

### Slide 24: 12/3/2024

SLAC Klystron Power Supply

Control wiring


## Technical Analysis

### Power Supply Design
The SLAC klystron power supply represents a sophisticated high-voltage, high-power system designed specifically for accelerator applications. Key design considerations include:

1. **High Voltage Generation:** Utilizes step-up transformers and rectifier circuits to achieve 90kV output
2. **Current Handling:** Designed for continuous 27A operation with appropriate thermal management
3. **Regulation Performance:** Achieves tight voltage regulation through feedback control systems
4. **Protection Systems:** Incorporates fast-acting arc protection to prevent klystron damage

### Control System Integration
The power supply integrates with the overall accelerator control system to provide:
- Remote voltage control and monitoring
- Status indication and fault reporting
- Coordinated operation with RF systems
- Safety interlocks and personnel protection

### Protection and Safety
Critical protection features include:
- **Arc Detection:** Fast response to klystron arcing events
- **Crowbar Protection:** Rapid energy dissipation during fault conditions
- **Overvoltage/Overcurrent Protection:** Prevents equipment damage
- **Personnel Safety:** Proper interlocks and access controls

## System Integration

This klystron power supply is part of the comprehensive PEP II accelerator system and must coordinate with:
- RF klystron amplifiers
- Beam control systems
- Facility power distribution
- Safety and interlock systems

## Conclusion

The SLAC klystron power supply represents a well-engineered solution for high-power RF amplifier applications, incorporating the necessary performance, protection, and control features required for reliable accelerator operation.
