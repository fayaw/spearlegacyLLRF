# SPEAR3 Interface Chassis Design Report

**Document ID**: SPEAR3-LLRF-DR-011
**Title**: Interface Chassis --- Central Interlock Coordination Hub with First-Fault Detection and Electrical Isolation
**Author**: LLRF Upgrade Team
**Date**: March 2026
**Version**: 1.0
**Status**: Interfaces Fully Specified (J. Sebek) --- Chassis Design and Fabrication Pending

**Reference Documents**:
| Document | Location | Content |
|----------|----------|---------|
| System Overview | `Designs/1_Overview of Current and Upgrade System.md` | Interface Chassis in upgrade scope (Section 4.7) |
| LLRF9 System Report | `Designs/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` | LLRF9 interlock interface |
| HVPS Technical Note | `Designs/4_HVPS_Engineering_Technical_Note.md` | HVPS fiber-optic interface (Section 14.5) |
| HVPS-PPS Interface | `Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` | PPS boundary and IC role (Section 9) |
| Software Design | `Designs/9_SOFTWARE_DESIGN.md` | Python coordinator IC monitoring |
| Waveform Buffer Design | `Designs/6_WAVEFORM_BUFFER_SYSTEM_DESIGN.md` | Comparator trip integration |
| Arc Detector Design | `Designs/7_ARC_DETECTOR_SYSTEM_DESIGN.md` | Arc detection permit integration |
| MPS Design | `Designs/10_MACHINE_PROTECTION_SYSTEM_DESIGN.md` | MPS-IC coordination protocol |
| Interface Chassis Spec | `Docs_JS/llrfInterfaceChassis.docx` | J. Sebek original specification |
| PPS System Overview | `pps/diagrams/00_SYSTEM_OVERVIEW.md` | PPS-IC boundary and legacy safety issues |
| PPS PLC Code Analysis | `pps/diagrams/07_PLC_CODE_AND_LOGIC.md` | SLC-500 ladder logic and failure modes |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Purpose and Role](#2-system-purpose-and-role)
3. [Design Requirements](#3-design-requirements)
4. [Input Signal Specifications](#4-input-signal-specifications)
5. [Output Signal Specifications](#5-output-signal-specifications)
6. [Electrical Isolation Design](#6-electrical-isolation-design)
7. [First-Fault Detection Circuit](#7-first-fault-detection-circuit)
8. [Fault Latching and Reset Logic](#8-fault-latching-and-reset-logic)
9. [Permit Logic Implementation](#9-permit-logic-implementation)
10. [LLRF9-HVPS Feedback Loop Analysis](#10-llrf9-hvps-feedback-loop-analysis)
11. [PPS Interface](#11-pps-interface)
12. [Signal Conditioning Details](#12-signal-conditioning-details)
13. [Integration with All Subsystems](#13-integration-with-all-subsystems)
14. [Physical Implementation](#14-physical-implementation)
15. [Commissioning and Testing Plan](#15-commissioning-and-testing-plan)
16. [Open Questions and Required Decisions](#16-open-questions-and-required-decisions)
17. [Implementation Status and Next Steps](#17-implementation-status-and-next-steps)

---

## 1. Executive Summary

The Interface Chassis is a **new, custom-designed hardware subsystem** that serves as the central interlock coordination hub for the entire SPEAR3 RF system upgrade. It is the most critical integration component in the upgrade architecture, connecting the LLRF9 controllers, HVPS controller, MPS PLC, arc detection system, Waveform Buffer System, and external safety systems (SPEAR MPS, orbit interlocks, PPS) through a single, electrically isolated, hardware-speed interlock logic chassis.

Unlike the MPS PLC (which operates at millisecond PLC scan rates), the Interface Chassis operates at **hardware speed with microsecond-scale processing delay**, using discrete logic components, optocouplers, and fiber-optic transceivers. It provides:

1. **First-fault detection**: Hardware-latched register identifying the initiating fault when multiple faults cascade
2. **Fault latching**: All inputs latch when they fault; faults persist until explicitly reset
3. **External reset**: Digital reset from MPS PLC simultaneously clears all latched faults
4. **Status reporting**: All input and output states plus first-fault status reported to MPS via digital lines
5. **Electrical isolation**: All external signals isolated from chassis digital ground using optocouplers and fiber-optic transceivers
6. **Fast permit logic**: Microsecond-scale combinational logic for all permit decisions

**Status**: Interfaces fully specified by J. Sebek. No chassis design or fabrication has started. This is on the critical path for system integration.

---

## 2. System Purpose and Role

### 2.1 Why the Interface Chassis Exists

In the legacy system, interlock signals were routed directly between subsystems (VXI LLRF to PLC-5, HVPS PLC to LLRF, etc.) without a central coordination point. This made first-fault identification difficult and created complex point-to-point wiring.

The Interface Chassis centralizes all interlock signal routing through a single point that provides:

- **Consistent isolation**: Every external signal passes through optocouplers or fiber-optic links
- **Deterministic response**: Hardware logic provides guaranteed sub-microsecond response
- **First-fault identification**: When faults cascade (e.g., LLRF9 trips, then HVPS trips), the chassis records which fault came first
- **Simplified wiring**: All subsystems connect to one chassis rather than to each other
- **Unified reset**: Single reset command clears all latched faults simultaneously

### 2.2 Position in System Architecture

```
                        +------------------+
                        |  SPEAR MPS (24V) |
                        |  Orbit Interlock |
                        +--------+---------+
                                 |
                                 v
+----------+    +----------------+----------------+    +-----------+
| LLRF9 #1 |--->|                                 |--->| LLRF9 #1  |
| (Status) |    |                                 |    | (Enable)  |
+----------+    |                                 |    +-----------+
                |                                 |
+----------+    |      INTERFACE CHASSIS          |    +-----------+
| LLRF9 #2 |--->|                                 |--->| HVPS SCR  |
| (Status) |    |  First-Fault Register           |    | ENABLE    |
+----------+    |  Fault Latching                 |    | (Fiber)   |
                |  Permit Logic                   |    +-----------+
+----------+    |  Optocoupler/Fiber Isolation     |
| HVPS     |--->|                                 |    +-----------+
| (Fiber)  |    |                                 |--->| HVPS      |
+----------+    |                                 |    | CROWBAR   |
                |                                 |    | (Fiber)   |
+----------+    |                                 |    +-----------+
| Arc Det. |--->|                                 |
| (Dry Ct) |    |                                 |    +-----------+
+----------+    |                                 |--->| MPS PLC   |
                |                                 |    | (Status)  |
+----------+    |                                 |    +-----------+
| Waveform |--->|                                 |
| Buffer   |    |                                 |
+----------+    |                                 |
                |                                 |
+----------+    |                                 |
| MPS PLC  |--->|                                 |
| (Permit, |    |                                 |
|  Heartbt,|    |                                 |
|  Reset)  |    +---------------------------------+
+----------+
```

---

## 3. Design Requirements

### 3.1 Functional Requirements

| Requirement | Specification |
|-------------|---------------|
| **First-fault circuit** | Hardware-latched register on all inputs; identifies initiating fault |
| **Fault latching** | All inputs latch when they fault; remain latched until reset |
| **External reset** | Digital reset from MPS simultaneously clears all latched faults |
| **Status reporting** | All input/output states plus first-fault status to MPS via digital lines |
| **Electrical isolation** | All external signals isolated from chassis digital ground |
| **Processing delay** | Microsecond-scale (standard electronic and electro-optical components) |

### 3.2 Environmental Requirements

| Parameter | Value |
|-----------|-------|
| **Operating temperature** | 0 to 50 degrees C (indoor equipment room) |
| **Power supply** | Standard AC mains or DC from equipment rack |
| **Form factor** | 19-inch rack-mount (height TBD) |
| **Location** | B118 equipment room (adjacent to LLRF9 units and MPS PLC) |

### 3.3 Reliability Requirements

| Parameter | Value |
|-----------|-------|
| **Fail-safe design** | All outputs de-energize on chassis power loss |
| **Component lifetime** | > 10 years for all active components |
| **MTBF** | > 100,000 hours |
| **Maintenance access** | Front-panel indicators; modular construction for board replacement |

---

## 4. Input Signal Specifications

### 4.1 Complete Input Table

| Input | Type | Source | Voltage | Isolation | Notes |
|-------|------|--------|---------|-----------|-------|
| **LLRF9 Status** | DC | LLRF9 rear panel | 5 VDC, up to 60 mA | Optocoupler | OR of 17 internal + 1 external interlocks |
| **HVPS STATUS** | Fiber-optic | HVPS Controller | HFBR-1412 receiver | Inherent (fiber) | Active when HVPS powered, no crowbar trigger |
| **MPS Summary Permit** | Digital | RF MPS PLC | TTL/5V | Optocoupler | Global RF permit |
| **MPS Heartbeat** | Digital | RF MPS PLC | TTL/5V | Optocoupler | Watchdog for MPS communication |
| **Power Signal Permit** | Digital | Waveform Buffer comparators | TTL/5V | Optocoupler | Combined RF/HVPS comparator trip status |
| **SPEAR MPS Permit** | DC | SPEAR MPS | 24 VDC | Optocoupler | Ring-level protection permit |
| **Orbit Interlock Permit** | DC | Orbit interlock system | 24 VDC | Optocoupler | Beam position safety |
| **Arc Interlock Permit(s)** | Dry contact or permit | Microstep-MIS detectors | Via optocoupler | Optocoupler | Cavity/klystron arc sensors |
| **Expansion Port 1** | TTL | External system | TTL/5V | Optocoupler | Future expansion |
| **Expansion Port 2** | TTL | External system | TTL/5V | Optocoupler | Future expansion |
| **Expansion Port 3** | DC | External system | 24 VDC | Optocoupler | Future expansion |
| **Expansion Port 4** | DC | External system | 24 VDC | Optocoupler | Future expansion |
| **MPS Reset** | Digital | RF MPS PLC | TTL/5V | Optocoupler | Reset command to clear all latched faults |

### 4.2 LLRF9 Status Signal Detail

The LLRF9 Status output is a single signal that represents the OR of all 18 interlock sources within the LLRF9:
- 9 RF input interlocks (overvoltage on each channel)
- 8 baseband ADC interlocks (window comparator on slow ADC channels)
- 1 external interlock input (the Interface Chassis LLRF9 Enable signal)

When any interlock trips, the LLRF9 Status goes OFF (low), the LLRF9 zeros its drive output, and opens the RF switch. The Interface Chassis reads this status to determine if the LLRF9 is operating normally.

**Critical behavior**: When the Interface Chassis removes the LLRF9 Enable (due to any other fault), the LLRF9 Status will also go OFF (since the external interlock input is OR-ed with the 17 internal sources). This creates a feedback loop that must be carefully handled (see Section 10).

### 4.3 HVPS STATUS Signal Detail

The HVPS STATUS is a fiber-optic signal from the HVPS CompactLogix controller:
- **Active (illuminated)**: HVPS controller is powered, no crowbar trigger, controller healthy
- **Inactive (dark)**: HVPS controller off, crowbar triggered, or controller fault
- **Receiver**: Broadcom HFBR-2412 at the Interface Chassis
- **Transmitter**: Broadcom HFBR-1412 at the HVPS controller

### 4.4 MPS Heartbeat Detail

The MPS Heartbeat is a periodic toggling signal from the MPS PLC:
- **Normal**: Signal toggles at defined rate (e.g., 1-2 Hz)
- **PLC fault**: Signal stops toggling (stuck high or low)
- **Interface Chassis monitoring**: Edge detector or timeout circuit determines if heartbeat is present
- **Timeout action**: If heartbeat absent for > defined timeout, Interface Chassis may remove permits

---

## 5. Output Signal Specifications

### 5.1 Complete Output Table

| Output | Type | Destination | Specification | Notes |
|--------|------|-------------|---------------|-------|
| **LLRF9 Enable** | DC (optocoupler) | LLRF9 interlock input | 3.2 VDC @ >= 8 mA | External permit to LLRF9 |
| **HVPS SCR ENABLE** | Fiber-optic | HVPS Controller | HFBR-2412 driver | Phase control thyristor enable |
| **HVPS KLYSTRON CROWBAR** | Fiber-optic | HVPS Controller | HFBR-2412 driver | Crowbar inhibit (normally illuminated) |
| **Digital Status Lines** | Multi-conductor | RF MPS PLC | TTL-level digital bus | Input states, output states, first-fault register |

### 5.2 LLRF9 Enable Detail

The LLRF9 Enable is an optocoupler-driven output that provides the external interlock permit to the LLRF9:
- **Active (permit granted)**: 3.2 VDC at >= 8 mA to LLRF9 interlock input
- **Inactive (permit removed)**: 0 V (optocoupler off)
- **LLRF9 response to removal**: LLRF9 immediately zeros drive output and opens RF switch

### 5.3 HVPS Fiber-Optic Outputs

**HVPS SCR ENABLE**:
- **Active (illuminated)**: HVPS phase control thyristors may fire
- **Inactive (dark)**: HVPS thyristors stop firing; HVPS voltage decays to zero
- **Driver**: Broadcom HFBR-2412 fiber-optic transmitter

**HVPS KLYSTRON CROWBAR**:
- **Active (illuminated)**: Crowbar thyristors INHIBITED (normal operation)
- **Inactive (dark)**: Crowbar thyristors may fire (protective crowbar discharge)
- **Default state**: Normally illuminated (keep crowbar inhibited)
- **Crowbar command**: De-illuminate to trigger crowbar discharge of stored energy
- **Driver**: Broadcom HFBR-2412 fiber-optic transmitter

### 5.4 Digital Status Lines

The Interface Chassis reports its complete state to the MPS PLC via a multi-conductor digital cable:
- **Input status bits**: One bit per input showing current (post-optocoupler) state
- **Output status bits**: One bit per output showing current drive state
- **First-fault register**: N-bit code identifying which input tripped first
- **Chassis health**: Power OK, self-test status

---

## 6. Electrical Isolation Design

### 6.1 Optocoupler Specifications

**Primary optocoupler family**: Broadcom ACSL-6xx0 series

| Parameter | Value |
|-----------|-------|
| **Maximum input forward voltage** | 1.8 VDC |
| **Recommended ON current** | 8 mA |
| **Maximum input current** | 15 mA |
| **Output type** | Transistor or logic gate (model dependent) |
| **Isolation voltage** | >= 3750 V RMS (1 minute) |
| **Propagation delay** | < 1 microsecond typical |
| **Common Mode Rejection** | >= 15 kV/microsecond |

### 6.2 Fiber-Optic Transceiver Specifications

**Transmitters**: Broadcom HFBR-1412
**Receivers**: Broadcom HFBR-2412

| Parameter | Value |
|-----------|-------|
| **Wavelength** | 820 nm (LED) |
| **Fiber type** | 62.5/125 micrometer multimode |
| **Connector** | ST |
| **Data rate** | DC to 5 Mbaud |
| **Link distance** | Up to 2 km |
| **Isolation** | Inherent (optical fiber) |

### 6.3 Input Conditioning Circuits

**For 5 VDC inputs (LLRF9 Status, MPS signals)**:
```
5V Source ---[R_series]---> Optocoupler LED ---> GND
                            |
                            +--> Optocoupler Output ---> Chassis Logic
```
R_series sized for 8 mA at 5V: R = (5V - 1.8V) / 8mA = 400 ohm (use 390 ohm standard)

**For 24 VDC inputs (SPEAR MPS, Orbit Interlock)**:
```
24V Source ---[R_series]---> Optocoupler LED ---> GND
                             |
                             +--> Optocoupler Output ---> Chassis Logic
```
R_series sized for 8 mA at 24V: R = (24V - 1.8V) / 8mA = 2775 ohm (use 2.7k standard)

**For dry contact inputs (Arc Detectors)**:
```
Chassis 5V ---[R_series]---> Optocoupler LED --+
                                                |
              Dry Contact (NC) ----------------+---> GND
                             |
                             +--> Optocoupler Output ---> Chassis Logic
```

---

## 7. First-Fault Detection Circuit

### 7.1 Operating Principle

The first-fault detection circuit captures which interlock input was the first to trip during a fault cascade. In many fault scenarios, one initial fault (e.g., arc detection) causes a chain reaction (LLRF9 trips, then HVPS trips, then vacuum may trip). Without first-fault detection, operators see multiple simultaneous faults and cannot determine the root cause.

### 7.2 Circuit Architecture

The first-fault register uses a **priority encoder with latching**:

```
Input 1 (LLRF9) ----[Latch]----+
Input 2 (HVPS)  ----[Latch]----+----> Priority Encoder ----> First-Fault Code
Input 3 (Arc)   ----[Latch]----+                              (N-bit digital)
Input 4 (WFBuf) ----[Latch]----+
  ...                           |
Input N         ----[Latch]----+
                                |
MPS Reset ----------------------+----> Clear All Latches
```

**Timing**: The priority encoder captures the first input to transition from OK to FAULT. All subsequent inputs that trip are latched individually but do not overwrite the first-fault code.

### 7.3 Resolution

The first-fault detection resolution depends on the propagation delay through the optocouplers and latch circuits. With ACSL-6xx0 optocouplers (< 1 microsecond delay), the system can distinguish faults separated by > 1 microsecond.

For faults that occur truly simultaneously (within 1 microsecond), the priority encoder assigns priority based on input position (Input 1 = highest priority). This is acceptable because truly simultaneous faults are rare and any identified fault is a valid root cause.

---

## 8. Fault Latching and Reset Logic

### 8.1 Latching Behavior

Each input has an associated SR (Set-Reset) latch:

- **Set condition**: Input transitions from OK to FAULT
- **Latch holds**: Fault state is held even if the input clears (returns to OK)
- **Reset condition**: Only when MPS Reset signal is received AND the input has returned to OK
- **Reset behavior**: All latches cleared simultaneously on MPS Reset

### 8.2 Reset Protocol

1. Fault occurs -> Input latches -> Permits removed -> System safe
2. Operator investigates fault
3. Fault source clears (e.g., vacuum recovers, LLRF9 ready)
4. Operator commands reset via EPICS -> MPS PLC asserts MPS Reset
5. Interface Chassis clears all latches
6. Permit logic re-evaluates -> If all inputs OK, permits restored
7. Station state machine can re-initiate operation

### 8.3 Reset Safety

The reset logic includes a safety feature: the MPS Reset signal is **edge-triggered** (not level-triggered). A sustained Reset signal does not prevent new faults from being latched. The reset clears existing latches on the rising edge, but new faults that occur during or after the reset pulse are latched normally.

---

## 9. Permit Logic Implementation

### 9.1 Master Permit Equation

```
All_Permits_OK = LLRF9_Status AND
                 HVPS_STATUS AND
                 MPS_Summary_Permit AND
                 MPS_Heartbeat_Present AND
                 Power_Signal_Permit AND
                 SPEAR_MPS_Permit AND
                 Orbit_Interlock_Permit AND
                 Arc_Interlock_Permit AND
                 (Expansion ports, if configured)

LLRF9_Enable     = All_Permits_OK
HVPS_SCR_ENABLE  = All_Permits_OK
HVPS_CROWBAR     = 1 (always enabled unless specific crowbar command)
```

### 9.2 Implementation

The permit logic is implemented using combinational logic gates (AND gates):
- Each input passes through its optocoupler and latch circuit
- The latch outputs feed into a multi-input AND gate
- The AND gate output drives the LLRF9 Enable and HVPS SCR ENABLE outputs
- The HVPS CROWBAR output has separate control logic (normally active)

### 9.3 Response Time Budget

| Stage | Delay |
|-------|-------|
| Optocoupler propagation | < 1 microsecond |
| Latch propagation | < 100 nanoseconds |
| AND gate propagation | < 100 nanoseconds |
| Output optocoupler/fiber driver | < 1 microsecond |
| **Total** | **< 3 microseconds** |

---

## 10. LLRF9-HVPS Feedback Loop Analysis

### 10.1 The Problem

When the Interface Chassis removes the LLRF9 Enable (due to any fault), the LLRF9 zeros its drive and its Status goes OFF. The Interface Chassis sees LLRF9 Status = OFF, which is an input fault. This creates a circular dependency:

```
Fault occurs -> IC removes LLRF9 Enable -> LLRF9 Status = OFF
     ^                                           |
     |                                           v
     +--- IC sees LLRF9 Status OFF (another fault input)
```

Similarly, when IC removes HVPS SCR ENABLE, the HVPS should remove its STATUS signal, which IC also monitors.

### 10.2 Design Solution

The Interface Chassis must distinguish between:
1. **Primary LLRF9 fault**: LLRF9 Status goes OFF while LLRF9 Enable is still ON (genuine LLRF9 internal fault)
2. **Consequential LLRF9 fault**: LLRF9 Status goes OFF because IC removed LLRF9 Enable (expected behavior, not a new fault)

**Implementation approach**: The first-fault register already handles this correctly. If a non-LLRF9 fault triggers the IC to remove LLRF9 Enable, the first-fault register captures the original fault (not the consequential LLRF9 status change). When all permits are restored after reset, the LLRF9 Status should return to ON as the LLRF9 Enable is restored.

### 10.3 Recovery Sequencing

The recovery sequence must be designed carefully:

1. MPS Reset clears all latches
2. Interface Chassis restores LLRF9 Enable (permits all inputs are OK)
3. LLRF9 receives Enable -> LLRF9 Status returns to ON
4. Interface Chassis sees LLRF9 Status ON -> system fully OK
5. HVPS SCR ENABLE restored -> HVPS STATUS returns to ON
6. All inputs confirmed OK -> system ready for operation

**Timing concern**: There is a brief period after step 2 where the LLRF9 Enable is asserted but the LLRF9 Status has not yet returned to ON. The Interface Chassis must allow this transient without triggering a new fault. This can be implemented with:
- A short blanking period after reset (e.g., 100 ms) during which LLRF9 Status changes are ignored
- Or by masking the LLRF9 Status input during the re-enable sequence

---

## 11. PPS Interface

### 11.1 Upgrade Architecture for PPS

In the upgraded system, the Interface Chassis replaces the PLC in the PPS safety chain. This addresses **critical safety concerns** identified in the legacy system:

**Legacy System Issues (from PPS analysis)**:
- ⚠️ **PLC Dependency**: Ross switch controlled by SLC-500 PLC (Rung 0016) — less fail-safe than direct control
- ⚠️ **Wiring Exposure**: PPS wires terminate on TS-5 and TS-6 inside HVPS controller (radiation safety concern)
- ⚠️ **Hardware Obsolescence**: SLC-500 PLC and 1746 modules are obsolete
- ⚠️ **Potential Failure Mode**: If PLC fails with outputs stuck ON, Ross switch stays energized/open (unsafe)

**Upgraded PPS Control (Direct, No PLC Dependency)**:
- **K4 relay**: PPS 1 Enable → Interface Chassis → K4 relay coil (contactor control)
- **Ross grounding switch**: PPS 2 Enable → Interface Chassis → Ross coil (HV ground)
- **Direct Control**: No PLC in the PPS safety chain — hardware-speed response
- **Fail-Safe Design**: Loss of PPS signal or Interface Chassis power → immediate safe state

This eliminates the legacy design concern where the PLC was in the PPS safety chain for the Ross switch and addresses all identified safety issues.

### 11.2 PPS Readback

The contactor auxiliary contact (S5) and Ross switch auxiliary contact signals are routed back through the Interface Chassis to the PPS interface, maintaining the same readback functionality as the legacy system.

### 11.3 PPS Isolation

All PPS signals are electrically isolated from the Interface Chassis digital ground using dedicated optocouplers, meeting PPS isolation requirements.

> **Note**: The PPS interface design requires approval from SLAC protection managers. See Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md for the complete PPS analysis and open questions.

---

## 12. Signal Conditioning Details

### 12.1 Input Signal Conditioning Summary

| Input Type | Conditioning | Component |
|------------|-------------|-----------|
| 5 VDC | Series resistor (390 ohm) -> optocoupler | ACSL-6xx0 |
| 24 VDC | Series resistor (2.7k ohm) -> optocoupler | ACSL-6xx0 |
| Dry contact | Pull-up resistor + series resistor -> optocoupler | ACSL-6xx0 |
| Fiber-optic | HFBR-2412 receiver -> logic level | HFBR-2412 |

### 12.2 Output Signal Conditioning Summary

| Output Type | Conditioning | Component |
|-------------|-------------|-----------|
| LLRF9 Enable (3.2V/8mA) | Optocoupler output with pull-up | ACSL-6xx0 |
| HVPS SCR ENABLE (fiber) | Logic level -> HFBR-1412 transmitter | HFBR-1412 |
| HVPS CROWBAR (fiber) | Logic level -> HFBR-1412 transmitter | HFBR-1412 |
| Digital status (to MPS) | TTL buffer/driver | 74HC-series |

---

## 13. Integration with All Subsystems

### 13.1 Integration Summary Table

| Subsystem | Inputs to IC | Outputs from IC | Cable Type |
|-----------|-------------|-----------------|------------|
| LLRF9 Unit 1 | Status (5V) | Enable (3.2V/8mA) | Multi-pin connector |
| LLRF9 Unit 2 | Status (5V) | (shared Enable or separate) | Multi-pin connector |
| HVPS Controller | STATUS (fiber) | SCR ENABLE (fiber), CROWBAR (fiber) | Fiber-optic (ST) |
| MPS PLC | Summary Permit, Heartbeat, Reset | Status Lines, First-Fault | Multi-conductor cable |
| Arc Detectors | Permit (dry contact/TTL) | (none direct) | Wire pairs |
| Waveform Buffer | Power Signal Permit (TTL) | Buffer Freeze Trigger | Wire pairs |
| SPEAR MPS | Permit (24V) | (none direct) | Wire pair |
| Orbit Interlock | Permit (24V) | (none direct) | Wire pair |
| PPS System | PPS 1, PPS 2 Enable | K4 relay, Ross switch, Readbacks | Dedicated PPS wiring |

---

## 14. Physical Implementation

### 14.1 Chassis Design

- **Form factor**: 19-inch rack-mount, 2U-4U height
- **Construction**: Aluminum or steel chassis with front-panel indicators
- **Front panel**: LED indicators for each input status, each output status, first-fault code, power, and fault
- **Rear panel**: All signal connectors (optocoupler, fiber-optic, digital)
- **Internal**: PCB(s) with optocouplers, fiber-optic transceivers, logic ICs, latch registers

### 14.2 PCB Design Requirements

- **Isolation**: Maintain physical separation between isolated input circuits and chassis logic ground
- **Creepage/clearance**: Meet UL/IEC requirements for the voltage levels present
- **EMI**: Shield sensitive logic from high-current switching circuits
- **Testability**: Include test points for all critical signals

### 14.3 Power Supply

- **Internal power**: +5V regulated supply for chassis logic
- **Isolated supplies**: Separate isolated supplies for optocoupler input circuits (if needed)
- **Power monitoring**: Chassis power OK signal included in status reporting

---

## 15. Commissioning and Testing Plan

### 15.1 Bench Testing

1. **Individual input testing**: Verify each input optocoupler responds correctly to its signal type
2. **Output verification**: Verify each output produces correct signal levels
3. **Permit logic**: Verify AND logic produces correct permit states for all input combinations
4. **First-fault detection**: Inject faults in sequence; verify first-fault register captures correctly
5. **Latching**: Verify faults remain latched after input clears
6. **Reset**: Verify MPS Reset clears all latches simultaneously
7. **Fail-safe**: Verify all outputs de-energize on chassis power loss
8. **Heartbeat monitoring**: Verify correct response to present/absent heartbeat

### 15.2 System Integration Testing

1. **LLRF9 integration**: Connect to LLRF9 Status and Enable; verify bidirectional operation
2. **HVPS integration**: Connect fiber-optic signals; verify SCR ENABLE and CROWBAR control
3. **MPS integration**: Connect all MPS signals; verify permit/heartbeat/reset protocol
4. **Arc detector integration**: Connect detector permits; verify interlock chain
5. **Waveform Buffer integration**: Connect comparator permits; verify trip propagation
6. **PPS integration**: Connect PPS signals; verify K4 and Ross switch control (requires PPS group approval)
7. **Full system fault injection**: Inject faults at each source; verify complete interlock chain response
8. **Recovery testing**: Verify system correctly recovers after each fault type

---

## 16. Open Questions and Required Decisions

### 16.1 Design Decisions

| Question | Options | Impact | Owner |
|----------|---------|--------|-------|
| Interface Chassis physical location | Inside Hoffman Box / Separate enclosure / Rack-mounted | Wiring, accessibility | RF Group |
| First-fault register readout method | Direct to MPS PLC / EPICS via dedicated IOC / Both | Diagnostics, complexity | RF Group |
| Reset logic: auto-reset or manual only? | Per-fault-type / All manual / Configurable | Uptime vs. safety | RF Group + PPS |
| LLRF9-HVPS re-enable sequencing | Simultaneous / HVPS first / LLRF9 first / Configurable | Recovery stability | RF Group |
| Number of arc detector inputs | Individual (5) / Grouped (2-3) / Single combined | First-fault granularity | RF Group |
| Heartbeat timeout period | 1 second / 2 seconds / Configurable | MPS fault sensitivity | RF Group |
| HVPS CROWBAR control logic | Always enabled / IC-controlled / MPS-controlled | Safety policy | RF Group |

### 16.2 PPS-Related Decisions

| Question | Options | Impact | Owner |
|----------|---------|--------|-------|
| PPS group approval for IC in safety chain | Approved / Modifications required | Fundamental architecture | PPS Group |
| PPS wiring isolation requirements | Dedicated conduit / Isolated within IC | Installation scope | PPS Group |
| GOB12-88PNE connector retention | Keep existing / New interface | Backward compatibility | PPS Group |

---

## 17. Implementation Status and Next Steps

### 17.1 Current Status

| Item | Status |
|------|--------|
| Interface specification | Complete (J. Sebek) |
| Signal interface definitions | Complete |
| Component selection (optocouplers, fiber) | Specified (ACSL-6xx0, HFBR-1412/2412) |
| Chassis design | Not started |
| PCB design | Not started |
| Fabrication | Not started |
| Assembly | Not started |
| Testing | Not started |
| PPS group coordination | Initial contact made (2022); needs update |

### 17.2 Next Steps

1. **Finalize design decisions** (see Section 16)
2. **Coordinate with PPS protection managers** for PPS interface approval
3. **Design PCB(s)** with all input conditioning, logic, latch, and output circuits
4. **Design chassis** (mechanical, front/rear panels, connectors)
5. **Fabricate PCBs and chassis**
6. **Assemble and bench test** all functions
7. **Integrate with LLRF9** (Status/Enable signals)
8. **Integrate with HVPS** (fiber-optic signals)
9. **Integrate with MPS PLC** (permit/heartbeat/reset/status)
10. **Integrate with arc detectors and Waveform Buffer**
11. **Full system commissioning**

### 17.3 Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Interface Chassis on critical path | High | High | Prioritize design and fabrication |
| PPS approval delays | High | Medium | Engage protection managers early with complete documentation |
| LLRF9-HVPS feedback loop instability | High | Medium | Design and simulate recovery sequencing before fabrication |
| Custom hardware reliability | Medium | Low | Conservative component ratings; thorough testing |
| PCB design errors | Medium | Medium | Design review; prototype before production |
| First-fault timing resolution insufficient | Low | Low | ACSL-6xx0 optocouplers provide < 1 microsecond resolution |
| Integration complexity | Medium | Medium | Test each subsystem interface independently before full integration |

---

*End of Document*
