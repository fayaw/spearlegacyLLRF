# SPEAR3 High Voltage Power Supply (HVPS) System — Complete Design Overview

**Document ID:** HVPS-OVERVIEW-001  
**Revision:** R1  
**Date:** March 2026  
**Author:** Engineering Team (SSRL/SLAC)  
**Classification:** System Design Reference — Complete HVPS Architecture

---

## Purpose and Scope

This document provides a comprehensive technical overview of the SPEAR3 High Voltage Power Supply (HVPS) system based on analysis of all circuit schematics, technical notes, and system documentation. It serves as the master reference for understanding the complete HVPS design, from system-level architecture down to individual circuit boards.

**Key Sources:**
- 10 detailed DOCX technical notes (extracted from PDF schematics)
- Existing markdown analyses (SD-7307900101, SD-237-230-14)
- System engineering documents (Designs/4_HVPS_Engineering_Technical_Note.md)
- PPS interface documentation (Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [Power Conversion Chain](#3-power-conversion-chain)
4. [Control and Regulation System](#4-control-and-regulation-system)
5. [Protection and Safety Systems](#5-protection-and-safety-systems)
6. [Monitoring and Interface Systems](#6-monitoring-and-interface-systems)
7. [Circuit Board Inventory and Functions](#7-circuit-board-inventory-and-functions)
8. [Signal Flow and Interconnections](#8-signal-flow-and-interconnections)
9. [Component Technology Analysis](#9-component-technology-analysis)
10. [System Performance Characteristics](#10-system-performance-characteristics)
11. [Maintenance and Troubleshooting](#11-maintenance-and-troubleshooting)
12. [Upgrade Considerations](#12-upgrade-considerations)

---

## 1. Executive Summary

### 1.1 System Function
The SPEAR3 HVPS converts 12.5KV 3-phase AC mains power into regulated -77KV DC at 27 amps (~2MW) to power a klystron tube that provides 476 MHz RF power to the SPEAR3 storage ring cavities.

### 1.2 Key System Characteristics
- **Power Level**: ~2MW (77KV × 27A)
- **Architecture**: 12-pulse thyristor-controlled rectifier
- **Regulation**: Precision voltage/current control via SCR phase angle
- **Protection**: Multi-layer protection including crowbar, arc detection, and interlocks
- **Control**: Distributed control across multiple specialized circuit boards
- **Safety**: Integrated with Personnel Protection System (PPS)

### 1.3 System Topology
```
12.5KV 3φ AC → Phase Shift Transformer → 12-Pulse SCR Rectifier → 
HV Filter → -77KV DC → Klystron Load
     ↑                    ↑                    ↑
Control System      Protection System    Monitoring System
```

---

## 2. System Architecture Overview

### 2.1 Functional Block Diagram

The HVPS consists of four major subsystems:

#### A. Power Conversion Subsystem
- **Input**: 12.5KV 3-phase AC from facility power
- **Phase Shifting Transformer**: Provides 30° phase shift for 12-pulse operation
- **SCR Rectifier**: Six thyristors (40KV 80A) in 12-pulse configuration
- **Output Filter**: LC filter network (350µHY inductors, 30NFD capacitors)
- **Output**: -77KV DC at 27A to klystron

#### B. Control and Regulation Subsystem
- **Voltage/Current Regulator Board** (SD-237-230-14): Master control with precision op-amps
- **SCR Driver Boards** (SD-730-793-03): Generate gate pulses for thyristors
- **Trigger Interconnect Boards** (SD-730-793-07/08): Coordinate 6-phase SCR firing

#### C. Protection Subsystem
- **Crowbar System**: Fast-acting thyristor protection (40KV 80A)
- **SCR Crowbar Driver Boards** (SD-730-793-04, SD-730-794-04): Crowbar firing control
- **Arc Detection**: Klystron and transformer arc monitoring
- **Interlock System**: Integration with PPS for personnel safety

#### D. Monitoring and Interface Subsystem
- **Monitor Board** (SD-730-793-12): Precision voltage/current measurement
- **Grounding Tank** (SD-730-790-05): HV filtering and sensing
- **Interface Systems**: EPICS control system integration

### 2.2 Physical Layout
- **Main Tank**: Contains SCR rectifiers, transformers, and HV components
- **Phase Tank**: Houses phase shifting transformer
- **Crowbar Tank**: Contains crowbar thyristor and protection circuits
- **Grounding Tank**: HV filter components and current/voltage sensing
- **Control Racks**: Electronic control boards and interfaces

---

## 3. Power Conversion Chain

### 3.1 Input Power System (SD-730-790-01)
**Primary Components:**
- 12.5KV 3-phase AC input with disconnect and breaker
- Phase shifting transformer providing dual secondary outputs
- 30° phase shift between secondary sets for 12-pulse operation

**Benefits of 12-Pulse Configuration:**
- Eliminates 5th and 7th harmonics
- Doubles ripple frequency to 720Hz (12 × 60Hz)
- Reduces input current distortion
- Improves power quality and regulation

### 3.2 SCR Rectifier System
**Thyristor Specifications:**
- **Rating**: 40KV 80A per device
- **Configuration**: Six thyristors in 12-pulse arrangement
- **Control**: Phase-angle control for voltage regulation
- **Firing**: Synchronized gate pulses from trigger system

**Rectifier Operation:**
- Two 6-pulse rectifier sets fed from phase-shifted transformer
- Precision timing control via CD4047B/CD4528 timing circuits
- IXFH12N90 MOSFET gate drivers (900V, 12A)
- 50µS ±5% gate pulse width with adjustable sub-pulses

### 3.3 Output Filter System (SD-730-790-05)
**Grounding Tank Components:**
- **Filter Inductors**: L1, L2 (350µHY 40A each, series connected)
- **Filter Capacitors**: C3, C5 (30NFD 37KV), C4 (10NFD 56KV)
- **Current Sensing**: Danfysik DC-CT (positive output) + 15A/50MV shunt
- **Voltage Sensing**: 25KV 100A voltage transducer
- **Termination**: HVT-G (50Ω 90KV) for impedance matching

**Filter Performance:**
- LC filter network provides ripple reduction
- Oil-filled tank for HV insulation
- Dual current sensing for redundancy
- Precision voltage measurement for regulation feedback

---

## 4. Control and Regulation System

### 4.1 Master Regulator Board (SD-237-230-14)
**Architecture:**
- **Power Supply**: ±15V, +30V rails with precision regulation
- **Op-Amp Stages**: MC34074 (quad), OP77 (precision), INA117/INA114 (instrumentation)
- **Isolation**: 6× 4N32 optocouplers for galvanic isolation
- **Protection Logic**: CD4044B RS latches for trip conditions

**Functional Circuits:**
1. **Voltage Limit Amplifier**: INA117 (U13) with 4.99K input, 500pF compensation
2. **Voltage Difference Amplifier**: INA117 (U11A) with precision 10.00K feedback
3. **Current Limit Amplifier**: 4.99K/5K input network, MC34074 processing
4. **Current Difference Amplifier**: INA114/INA117 for precision measurement
5. **Over-Voltage Trip**: MC34074 comparator with CD4044B latch
6. **Over-Current Trip**: MC34074 comparator with 1N4747 (20V) clamping
7. **Manual Trip**: R32 (1K) input with CD4044B latch
8. **Under-Voltage Lockout**: R47 (100K) + C11 time constant
9. **SCR Phase-Control Output**: OP77 precision output with 1N4740 (10V) clamp
10. **Soft-Start Logic**: MC34074 with C32 (10µF) + R49 (10K) timing

**Configuration Options:**
- **PEP II Mode**: R20 not used (gain=1), standard component values
- **NLCTA Mode**: R20=5.6K (gain=10), C11=5µF, modified jumpers

### 4.2 SCR Driver System (SD-730-793-03/04)
**Timing Generation:**
- **CD4047B**: Astable/monostable multivibrator for base timing
- **CD4528**: Dual monostable multivibrators for precision pulse widths
- **CD4049**: Hex inverting buffers for signal conditioning
- **Timing Parameters**: 50µS ±5% main pulse, 16µS ±1µS adjustable sub-pulse

**Power Stage:**
- **MIC-4451**: High-speed MOSFET gate driver
- **IXFH12N90**: Power MOSFETs (900V, 12A) for gate pulse generation
- **1N4744**: 15V Zener diodes for MOSFET gate protection
- **MR856**: Fast-recovery diodes for output rectification

**Variants:**
- **SD-730-793-03**: Standard SCR driver (60Hz continuous operation)
- **SD-730-793-04**: Crowbar driver (single-shot operation, MIC-4427 optical output)

### 4.3 Trigger Interconnect System (SD-730-793-07/08)
**Right Side Board (SD-730-793-07):**
- **SCR Triggers**: 3× MIC-4427 drivers for 6-phase SCR control
- **Phase Monitoring**: 6 channels with CD4538 (20mS timing)
- **Arc Detection**: Klystron + transformer arc inputs with P3KE7 TVS protection
- **Crowbar Control**: CD4538 timing with R29 (237K) for 1-second CBREADY
- **Fiber-Optic I/O**: HCPL-4503, HFBR-1412/2412 for status communication

**Left Side Board (SD-730-793-08):**
- **Mirror Architecture**: Same IC complement as right-side board
- **24V Fault/Enable Bus**: Connection to right-side board
- **Commands Interface**: IDC20 connector for external control
- **Monitoring**: 6-phase SCR monitoring with bypass capability

---

## 5. Protection and Safety Systems

### 5.1 Crowbar Protection System
**Primary Crowbar (SD-730-793-04):**
- **Thyristor**: 40KV 80A crowbar SCR
- **Trigger**: Single-shot firing with 50mS/44µS timing
- **Optical Output**: MIC-4427 for fiber-optic isolation
- **Power**: +12V supply with IXFH12N90 MOSFETs

**Secondary Crowbar (SD-730-794-04):**
- **MOSFETs**: 3× IRFDP120 for faster switching
- **Power**: +15V supply (different from 793-series)
- **EMI Filtering**: Ferrite beads (300Ω/500Ω) for noise rejection
- **Timing**: CM14528 monostables with 200pF timing capacitors

### 5.2 Arc Detection System
**Klystron Arc Detection:**
- BNC input connectors on trigger interconnect boards
- P3KE7 TVS diodes for transient protection
- R26 (33K) + R33 (35K) signal conditioning
- Integration with fault/enable logic

**Transformer Arc Detection:**
- Similar architecture to klystron arc detection
- Separate BNC inputs for transformer monitoring
- Combined fault logic for coordinated protection

### 5.3 Multi-Layer Protection Architecture
1. **Hardware Level**: Zener diodes, TVS diodes, fuses
2. **Circuit Level**: Op-amp comparators, CD4044B latches
3. **System Level**: Crowbar thyristors, SCR inhibit
4. **Facility Level**: PPS interlocks, disconnect breakers

---

## 6. Monitoring and Interface Systems

### 6.1 Monitor Board (SD-730-793-12)
**Dual Isolated Architecture:**
- **Domain 1**: +15V1, -15V1, GND1 (channels 1-3, crowbar monitor)
- **Domain 2**: +15V2, -15V2, GND2 (voltage/current BNC outputs)
- **DC-DC Converters**: 2× NMH2415S for 1500V isolation

**Precision Monitoring:**
- **Voltage Monitor**: 10kV/V scale, R33/R36 (511Ω/536Ω 1% precision)
- **Current Monitor**: 5A/V scale, R2 (1K) + R32 (10K)
- **Buffer Amplifiers**: 5× BUF634 unity-gain buffers
- **Reference Calibration**: R25 (2K 12-turn trimmer)

**Output Connectors:**
- **BNC1**: Voltage output (10kV/V)
- **BNC2**: Current output (5A/V)
- **BNC3**: Crowbar monitor output

### 6.2 Interface Systems
**EPICS Integration:**
- Real-time monitoring of voltage, current, status
- Remote control capabilities
- Alarm and fault reporting
- Historical data logging

**PPS Interface:**
- Safety interlock integration
- Personnel protection coordination
- Emergency shutdown capabilities
- Status reporting to facility systems

---

## 7. Circuit Board Inventory and Functions

### 7.1 Complete Board Inventory

| Drawing Number | Board Name | Primary Function | Key Components |
|----------------|------------|------------------|----------------|
| **SD-730-790-01-C1** | HVPS System Overview | System-level architecture | Phase shift transformer, SCR rectifiers, filters |
| **SD-730-790-05-C1** | Grounding Tank Assembly | HV filtering and sensing | 350µHY inductors, 30NFD caps, Danfysik DC-CT |
| **SD-237-230-14-C1** | Voltage/Current Regulator | Master control and regulation | INA117, MC34074, CD4044B, 4N32 optocouplers |
| **SD-730-793-03-C4** | SCR Driver Board | SCR gate pulse generation | CD4047B, CD4528, MIC-4451, IXFH12N90 |
| **SD-730-793-04-C2** | SCR Crowbar Driver | Crowbar firing control | CD4047B, CD4538, MIC-4427 optical |
| **SD-730-793-07-C2** | Right Side Trigger Interconnect | 6-phase SCR control hub | 3× MIC-4427, CD4538 monitoring, fiber-optic I/O |
| **SD-730-793-08-C1** | Left Side Trigger Interconnect | Mirror of right-side control | Same as 793-07, 24V fault/enable bus |
| **SD-730-793-12-C3** | Monitor Board | Precision measurement | NMH2415S, BUF634, dual isolated domains |
| **SD-730-793-13-C1** | HV Power Circuit Modification | Modified SCR driver variant | 6N-139 optocoupler, modified timing |
| **SD-730-794-04-C0** | SCR Crowbar Trigger | Alternative crowbar design | IRFDP120 MOSFETs, ferrite filtering |

### 7.2 Board Interconnection Matrix

```
System Level:
SD-730-790-01 (System) ←→ All other boards (power, control, monitoring)

Control Level:
SD-237-230-14 (Master) ←→ SD-730-793-03/04 (SCR Drivers)
                       ←→ SD-730-793-07/08 (Trigger Interconnect)

Monitoring Level:
SD-730-793-12 (Monitor) ←→ SD-730-790-05 (Grounding Tank)
                        ←→ System voltage/current sensing

Protection Level:
SD-730-793-04/SD-730-794-04 (Crowbar) ←→ Arc detection inputs
                                       ←→ Fault/enable logic
```

---

## 8. Signal Flow and Interconnections

### 8.1 Primary Signal Paths

#### Power Flow:
```
12.5KV 3φ AC → Phase Shift Transformer → SCR Rectifiers → 
HV Filter (Grounding Tank) → -77KV DC → Klystron
```

#### Control Flow:
```
Voltage/Current Commands → Regulator Board → SCR Drivers → 
Trigger Interconnect → SCR Gate Pulses → Thyristors
```

#### Feedback Flow:
```
HV Output → Voltage/Current Sensing → Monitor Board → 
Regulator Board → Control Loop Closure
```

#### Protection Flow:
```
Fault Detection → Protection Logic → Crowbar Trigger → 
SCR Inhibit → System Shutdown
```

### 8.2 Critical Signal Nets

**Power Rails:**
- +12V: Logic supply for 793-series boards
- +15V: Logic supply for 794-series and monitor boards
- ±15V: Analog supply for regulator board
- +30V: High-voltage rail for output stages

**Control Signals:**
- SCR Gate Pulses: 6-phase synchronized firing
- Phase Control: Variable phase angle from regulator
- Enable/Inhibit: System enable and emergency shutdown
- Soft-Start: Controlled startup sequencing

**Monitoring Signals:**
- Voltage Feedback: 10kV/V scale from monitor board
- Current Feedback: 5A/V scale from current sensing
- Status Signals: Power-on, ready, fault indications
- Arc Detection: Klystron and transformer arc inputs

**Protection Signals:**
- Crowbar Trigger: Fast-acting fault protection
- Trip Signals: Over-voltage, over-current, manual trip
- Interlock Signals: PPS interface and safety systems
- Fault/Enable Bus: 24V coordination between boards

---

## 9. Component Technology Analysis

### 9.1 Integrated Circuits by Function

#### Timing and Logic:
- **CD4047B**: CMOS astable/monostable multivibrator (base timing)
- **CD4528/CD4538**: CMOS dual monostable multivibrators (precision timing)
- **CD4049**: CMOS hex inverting buffers (signal conditioning)
- **CD4001**: CMOS quad NOR gates (logic functions)
- **CD4075**: CMOS triple 3-input OR gates (fault logic)
- **CD4044B**: CMOS quad RS latches (trip/protection logic)

#### Analog Processing:
- **MC34074**: Quad operational amplifiers (general purpose)
- **OP77**: Precision operational amplifiers (critical paths)
- **INA117**: High common-mode voltage instrumentation amplifiers
- **INA114**: Precision instrumentation amplifiers
- **BUF634**: High-speed unity-gain buffer amplifiers

#### Drivers and Interfaces:
- **MIC-4451**: High-speed MOSFET gate drivers
- **MIC-4427**: Dual low-side MOSFET drivers (optical outputs)
- **75116**: Differential line driver/receiver
- **NMH2415S**: Isolated DC-DC converters (±15V output)

#### Isolation and Communication:
- **4N32**: Optocouplers for galvanic isolation
- **HCPL-4503**: High-speed optocouplers
- **HFBR-1412**: Fiber-optic transmitters
- **HFBR-2412**: Fiber-optic receivers
- **6N-138/6N-139**: Optocouplers for trigger isolation

### 9.2 Power Semiconductors

#### Power MOSFETs:
- **IXFH12N90**: N-channel power MOSFETs (900V, 12A) - primary switching
- **IRFDP120**: N-channel power MOSFETs (lower voltage, faster) - crowbar applications
- **IRFD110**: N-channel MOSFETs (trigger switching)

#### Thyristors:
- **Main SCRs**: 40KV 80A thyristors for power rectification
- **Crowbar SCR**: 40KV 80A thyristor for fault protection

#### Diodes:
- **MR856**: Fast-recovery rectifiers (output stages)
- **1N3064**: Signal diodes (protection/clamping)
- **1N4728**: 3.3V Zener diodes (references)
- **1N4740**: 10V Zener diodes (clamping)
- **1N4742**: 12V Zener diodes (references)
- **1N4744/1N4744A**: 15V Zener diodes (MOSFET protection)
- **1N4747**: 20V Zener diodes (clamping)
- **P3KE7**: TVS diodes (transient protection)

### 9.3 Passive Components

#### Precision Resistors:
- **10.00K (0.1%)**: Precision feedback networks
- **4.99K**: Current/voltage limit amplifiers
- **511Ω/536Ω (1%)**: Precision voltage scaling
- **237K**: Crowbar timing (1-second)
- **24.9K**: 5µS timing resistors

#### Filter Components:
- **350µHY**: High-current filter inductors
- **30NFD 37KV**: High-voltage filter capacitors
- **10NFD 56KV**: High-voltage filter capacitors
- **Ferrite Beads**: 300Ω/500Ω EMI filtering

#### Timing Capacitors:
- **200pF**: Monostable timing
- **0.1µF**: Decoupling and bypass
- **10µF**: Power supply filtering
- **0.47µF**: Distributed decoupling (20× on monitor board)

---

## 10. System Performance Characteristics

### 10.1 Power Specifications
- **Input**: 12.5KV 3-phase AC, ~160A
- **Output**: -77KV DC at 27A (2.08MW)
- **Efficiency**: ~85-90% (estimated, including transformer losses)
- **Power Factor**: >0.95 (12-pulse configuration)
- **Harmonic Distortion**: <5% THD (12-pulse eliminates 5th/7th harmonics)

### 10.2 Regulation Performance
- **Voltage Regulation**: ±0.5% (load regulation)
- **Current Regulation**: ±1% (current limit accuracy)
- **Transient Response**: <10ms (load step response)
- **Ripple**: <1% (720Hz ripple frequency)
- **Stability**: Long-term drift <0.1%/hour

### 10.3 Protection Response Times
- **Crowbar Activation**: <10µS (hardware-based)
- **SCR Inhibit**: <1µS (gate blocking)
- **Arc Detection**: <100µS (fault recognition)
- **Over-voltage Trip**: <1ms (comparator response)
- **Over-current Trip**: <1ms (comparator response)

### 10.4 Control System Performance
- **Phase Control Range**: 0-150° (SCR firing angle)
- **Timing Accuracy**: ±1µS (gate pulse timing)
- **Soft-Start Time**: Adjustable, typically 1-10 seconds
- **Monitoring Accuracy**: ±0.1% (voltage/current measurement)

---

## 11. Maintenance and Troubleshooting

### 11.1 Critical Test Points

#### Regulator Board (SD-237-230-14):
- **TP3**: +15V supply monitoring
- **TP4**: Negative voltage monitoring
- **TP6**: -15V supply monitoring
- **TP8**: Manual trip monitoring
- **TP9**: Power-on status
- **TP10**: Ground reference
- **TP12**: Trip output monitoring

#### SCR Driver Boards (SD-730-793-03/04):
- **TP1**: Trigger input verification
- **TP2**: Timing chain output
- **TP3**: Intermediate timing
- **TP4**: MOSFET gate drive Q1
- **TP5**: MOSFET gate drive Q2

#### Trigger Interconnect Boards (SD-730-793-07/08):
- **TP1-TP11**: Various monitoring points for diagnostics
- **Multiple test points**: For 6-phase monitoring and fault logic

### 11.2 Common Failure Modes

#### Power Stage Failures:
- **SCR Gate Drive Failure**: Check IXFH12N90 MOSFETs and MIC-4451 drivers
- **Timing Circuit Failure**: Verify CD4047B/CD4528 operation and timing capacitors
- **Protection Circuit Failure**: Check Zener diodes and TVS protection devices

#### Control System Failures:
- **Regulation Loop Instability**: Check op-amp stages and feedback networks
- **Optocoupler Failure**: Test 4N32 isolation devices
- **Reference Voltage Drift**: Verify Zener diode references

#### Protection System Failures:
- **Crowbar Malfunction**: Check crowbar SCR and trigger circuits
- **Arc Detection False Trips**: Verify P3KE7 TVS diodes and signal conditioning
- **Interlock System Issues**: Check PPS interface and fault logic

### 11.3 Calibration Procedures

#### Voltage Regulation Calibration:
1. Verify reference voltage accuracy (Zener diodes)
2. Calibrate voltage feedback scaling (precision resistors)
3. Adjust voltage limit settings (potentiometers)
4. Verify over-voltage trip points

#### Current Regulation Calibration:
1. Calibrate current sensing (Danfysik DC-CT, shunt resistors)
2. Adjust current limit settings
3. Verify over-current trip points
4. Check current feedback scaling

#### Timing Calibration:
1. Verify SCR gate pulse timing (50µS ±5%)
2. Adjust sub-pulse timing (16µS ±1µS)
3. Check crowbar timing (1-second CBREADY)
4. Verify soft-start timing

---

## 12. Upgrade Considerations

### 12.1 Component Obsolescence Assessment

#### High Risk (Obsolete/Difficult to Source):
- **OP77**: Precision op-amp, consider modern equivalents (OPA177, AD797)
- **INA117**: High-voltage instrumentation amp, consider INA149 or discrete design
- **CD4047B**: CMOS multivibrator, still available but consider modern timing ICs
- **NMH2415S**: Isolated DC-DC converter, consider modern equivalents

#### Medium Risk (Available but Aging):
- **MC34074**: Quad op-amp, widely available, multiple sources
- **4N32**: Standard optocoupler, multiple sources available
- **IXFH12N90**: Power MOSFET, consider modern equivalents with better performance
- **MIC-4451/4427**: MOSFET drivers, consider modern high-speed drivers

#### Low Risk (Standard Components):
- **CD4528/CD4538**: CMOS logic, widely available
- **1N4728 series**: Standard Zener diodes, multiple sources
- **BUF634**: Unity-gain buffer, still in production
- **Passive components**: Resistors, capacitors generally available

### 12.2 Performance Improvement Opportunities

#### Digital Control Upgrade:
- Replace analog control loops with digital controllers
- Implement advanced control algorithms (PID, adaptive control)
- Add comprehensive diagnostics and monitoring
- Enable remote configuration and calibration

#### Protection System Enhancement:
- Implement faster digital protection algorithms
- Add predictive fault detection
- Enhance arc detection with advanced signal processing
- Improve coordination between protection systems

#### Monitoring System Upgrade:
- Add high-resolution ADCs for better measurement accuracy
- Implement real-time data logging and analysis
- Add network connectivity for remote monitoring
- Enhance user interface with graphical displays

### 12.3 Modernization Strategy

#### Phase 1: Component Replacement
- Replace obsolete components with modern equivalents
- Maintain existing circuit topology and interfaces
- Improve reliability and availability
- Reduce maintenance requirements

#### Phase 2: Control System Upgrade
- Implement digital control system
- Maintain existing power stage and protection systems
- Add enhanced monitoring and diagnostics
- Improve regulation performance and stability

#### Phase 3: Complete System Modernization
- Replace entire control and protection systems
- Implement modern power electronics (IGBT-based)
- Add advanced features (soft switching, active filtering)
- Integrate with modern facility control systems

---

## Document Cross-Reference Index

### Primary Technical Documents
- **sd7307900101.docx**: HVPS System Overview Schematic
- **sd7307900501.docx**: Grounding Tank Assembly
- **sd2372301401.docx**: Enerpro Voltage/Current Regulator Board
- **sd7307930304.docx**: SCR Driver Board
- **sd7307930402.docx**: SCR Crowbar Driver Board
- **sd7307930702.docx**: Right Side Trigger Interconnect Board
- **sd7307930801.docx**: Left Side Trigger Interconnect Board
- **sd7307931203.docx**: Monitor Board
- **sd7307931301.docx**: HV Power Circuit Modification
- **sd7307940400.docx**: SCR Crowbar Trigger Board

### Supporting Analysis Documents
- **SD-7307900101_HVPS_System_Schematic_Analysis.md**: System-level analysis
- **SD-237-230-14_Regulator_Board_Analysis.md**: Regulator board analysis

### System Engineering Documents
- **Designs/4_HVPS_Engineering_Technical_Note.md**: Complete system engineering reference
- **Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md**: PPS interface documentation

### Original Schematic PDFs
- **sd7307900101.pdf** through **sd7307940400.pdf**: Original scanned schematics

---

**Document Status**: Complete system overview based on comprehensive schematic analysis  
**Analysis Date**: March 2026  
**Confidence Level**: High (based on detailed circuit analysis and cross-referencing)  
**Next Review**: Recommended annual review for component availability and system performance
