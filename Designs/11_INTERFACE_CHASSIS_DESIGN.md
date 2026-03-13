# SPEAR3 Interface Chassis Design Report

**Document ID**: SPEAR3-LLRF-DR-011
**Title**: Interface Chassis — Central Interlock Coordination Hub with First-Fault Detection and Electrical Isolation
**Author**: LLRF Upgrade Team
**Date**: March 2026
**Version**: 1.0
**Status**: Interfaces Fully Specified (J. Sebek) — Chassis Design and Fabrication Pending

**Reference Documents**:
| Document | Location | Content |
|----------|----------|---------|
| **Primary Interface Chassis Specification** | `llrf/architecture/llrfInterfaceChassis.docx` | J. Sebek complete interface specification |
| **HVPS Fiber-Optic Connections** | `hvps/architecture/designNotes/controllerFiberOpticConnections.docx` | Detailed HVPS fiber-optic circuit behavior |
| **Inter-Controller Interfaces** | `hvps/architecture/designNotes/interfacesBetweenRFSystemControllers.docx` | Standard optocoupler specifications |
| **RF System MPS Requirements** | `hvps/architecture/designNotes/RFSystemMPSRequirements.docx` | Protection philosophy and MPS requirements |
| **Fiber-Optic Signal Control** | `llrf/documentation/fiberOpticCableSignalControlRev3.docx` | Fiber-optic signal control rationale |
| **Waveform Buffer Comparators** | `llrf/architecture/WaveformBuffersforLLRFUpgrade.docx` | Waveform Buffer comparator trip outputs |
| **Arc Detector Hardware Options** | `llrf/architecture/arcDetectorHardwareOptions.docx` | Arc detection interface requirements |

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
11. [Signal Conditioning Details](#11-signal-conditioning-details)
12. [Integration with All Subsystems](#12-integration-with-all-subsystems)
13. [Physical Implementation](#13-physical-implementation)
14. [Commissioning and Testing Plan](#14-commissioning-and-testing-plan)
15. [Open Questions and Required Decisions](#15-open-questions-and-required-decisions)
16. [Implementation Status and Next Steps](#16-implementation-status-and-next-steps)

---

## 1. Executive Summary

The Interface Chassis is a **new, custom-designed hardware subsystem** that serves as the central interlock coordination hub for the entire SPEAR3 RF system upgrade. It connects the LLRF9 controllers, HVPS controller, MPS PLC, arc detection system, Waveform Buffer System, and external safety systems (SPEAR MPS, orbit interlocks) through a single, electrically isolated, hardware-speed interlock logic chassis.

**Key capabilities**:
1. **First-fault detection**: Hardware-latched register identifying the initiating fault when multiple faults cascade
2. **Fault latching**: All inputs latch when they fault; faults persist until explicitly reset
3. **External reset**: Digital reset from MPS PLC simultaneously clears all latched faults
4. **Status reporting**: All input and output states plus first-fault status reported to MPS via digital lines
5. **Electrical isolation**: All external signals isolated from chassis digital ground using optocouplers and fiber-optic transceivers
6. **Fast permit logic**: Microsecond-scale combinational logic for all permit decisions

**Status**: Interfaces fully specified by J. Sebek. No chassis design or fabrication has started.

---

## 2. System Purpose and Role

### 2.1 Why the Interface Chassis Exists

In the legacy system, interlock signals were routed directly between subsystems without a central coordination point. The Interface Chassis centralizes all interlock signal routing through a single point that provides:

- **Consistent isolation**: Every external signal passes through optocouplers or fiber-optic links
- **Deterministic response**: Hardware logic provides guaranteed sub-microsecond response
- **First-fault identification**: When faults cascade, the chassis records which fault came first
- **Simplified wiring**: All subsystems connect to one chassis rather than to each other
- **Unified reset**: Single reset command clears all latched faults simultaneously

**Important**: The Interface Chassis has **no connection to PPS systems**. All PPS interfaces are handled separately through dedicated PPS hardware and wiring.

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

---

## 4. Input Signal Specifications

### 4.1 Complete Input Table

| Input | Type | Source | Voltage | Isolation | Notes |
|-------|------|--------|---------|-----------|-------|
| **LLRF9 Status** | DC | LLRF9 rear panel (daisy-chain output) | 5 VDC, up to 60 mA | Optocoupler (ACSL-6xx0 family) | Logical OR of 17 internal LLRF9 interlocks + 1 external permit. Output is 5 VDC when all OK, pulled low on any fault. |
| **HVPS STATUS** | Fiber-optic | HVPS Left Side Trigger Interconnect Board (SD-730-793-08-C1) | 820 nm | HFBR-2412 receiver | Illuminated when: (1) PLC 24V Fault/Enable (Slot-5 OUT 0) is active, AND (2) no crowbar trigger condition exists. Does **not** indicate that the Enerpro firing circuit is enabled or that thyristors are actually firing. |
| **MPS RF Summary Permit** | Digital | RF MPS ControlLogix PLC | 24 VDC | Optocoupler (HCPL-2400-000E) | Global RF system permit from the MPS. Removal removes all downstream permits. |
| **MPS Heartbeat** | Digital | RF MPS ControlLogix PLC | TTL/24V | Optocoupler (HCPL-2400-000E) | Watchdog signal; loss indicates MPS communication failure. |
| **MPS External Reset** | Digital | RF MPS ControlLogix PLC | TTL/24V | Optocoupler (HCPL-2400-000E) | Simultaneous reset of all latched faults in the Interface Chassis. Active-edge triggered. |
| **Power Monitoring** | Digital (comparator trip) | Waveform Buffer System | TTL | Optocoupler (HCPL-2400-000E) | Single summary permit from analog comparator circuits. Trips if any monitored RF signal or HVPS signal exceeds preset threshold. Latched until reset. |
| **SPEAR MPS Permit** | DC | SPEAR MPS system | 24 VDC | Optocoupler (HCPL-2400-000E) | Ring-wide machine protection permit. Also carries beamline MPS status (beamline MPS is a satellite of SPEAR MPS; it does not communicate directly with the RF system). |
| **Orbit Interlock Permit** | DC | SPEAR Orbit Interlock system | 24 VDC | Optocoupler (HCPL-2400-000E) | Beam position safety permit. Removed if beam position exceeds safe trajectory envelope near any beamline. |
| **Arc Detection** | Dry relay contacts | MicroStep-MIS Wave Arc Detector control units | NC = safe, open = fault | Optocoupler (HCPL-2400-000E) | Up to 4 control units (2 sensors each, one per cavity). Semiconductor switch in each control unit remains closed when no arc detected; latches open on detected arc. Requires external 24 VDC and digital lines for test and reset. |
| **Expansion Port 1** | TTL | External system (future use) | TTL | Optocoupler | For fast timing experiments requiring synchronous RF turn-off. Designed for 50 Ω termination upstream of chassis (BNC terminator); internal input impedance ~1 kΩ. |
| **Expansion Port 2** | TTL | External system (future use) | TTL | Optocoupler | For fast timing experiments requiring synchronous RF turn-off. Designed for 50 Ω termination upstream of chassis (BNC terminator); internal input impedance ~1 kΩ. |
| **Expansion Port 3** | DC | External system (future use) | 24 VDC | Optocoupler | General-purpose expansion for future subsystem integration. |
| **Expansion Port 4** | DC | External system (future use) | 24 VDC | Optocoupler | General-purpose expansion for future subsystem integration. |

### 4.2 LLRF9 Status Signal Detail

The LLRF9 Status output is a single signal that represents the OR of all 18 interlock sources within the LLRF9:
- 17 internal interlocks (RF input overvoltage, baseband ADC window comparators, etc.)
- 1 external interlock input (the Interface Chassis LLRF9 Enable signal)

**LLRF9 Daisy-Chain Topology**: The two LLRF9 units are daisy-chained for interlock purposes: Unit 2's interlock output connects to Unit 1's external interlock input. The Interface Chassis provides one enable signal that enters this daisy chain.

**Signal levels** (ref: LLRF9 manual p. 14):
- **Input** (to LLRF9): Opto-isolated, selectable for 3.3V or 5V logic. A signal ≥3.2 VDC supplying ≥8 mA guarantees an enable.
- **Output** (from LLRF9): 5 VDC from transistor, can supply up to 60 mA. Logical OR of 18 signals (17 internal interlocks + 1 external permit). Pulled low on any fault. Dimtel uses Broadcom ACSL-6300-50TE optocoupler internally; a CDBU00340-HF protection diode is present on the output.

### 4.3 HVPS STATUS Signal Detail

The HVPS STATUS fiber-optic signal provides a basic health indication from the HVPS controller. The Left Side Trigger Interconnect Board illuminates the STATUS fiber when **both** conditions are met:

1. The PLC 24V Fault/Enable signal (Slot-5 OUT 0, labeled "Control System Enable" in PLC code) is at logic high
2. No condition has caused the crowbar circuit to fire (no klystron arc trigger, no transformer arc trigger, no PLC force crowbar command, no loss of KLYSTRON CROWBAR fiber)

**This signal does NOT indicate**:
- That the Enerpro FCOG6100 firing circuit has been enabled
- That the thyristor triggers are actually firing
- That the HVPS output is at the desired voltage
- That the HVPS is regulating properly

It is a necessary-but-not-sufficient indicator of HVPS readiness.

### 4.4 Optocoupler Design Notes

The primary recommended optocoupler family for general electrical isolation is the **Broadcom ACSL-6xx0** (e.g., ACSL-6300-50TE, ACSL-6410-00TE). Key specifications:
- Maximum input forward voltage: 1.8 VDC
- Recommended minimum ON-state input current: 8 mA
- Maximum allowable input current: 15 mA
- Response time: ~0.5 μs

The **Broadcom HCPL-2400-000E** (0.5 μs response) is specified in `hvps/architecture/designNotes/interfacesBetweenRFSystemControllers.docx` as the standard for inter-controller isolation and is equally valid.

**Resistor calculations** for each input voltage level: R = (V_input - 1.8 V) / I_target

| Input Voltage | R for 8 mA | R for 10 mA |
|---|---|---|
| 24 VDC | 2.78 kΩ | 2.22 kΩ |
| 12 VDC | 1.28 kΩ | 1.02 kΩ |
| 5 VDC | 400 Ω | 320 Ω |

The specific optocoupler selection for each interface (ACSL-6xx0 vs. HCPL-2400-000E) will be determined during detailed PCB design. Both families meet the microsecond response requirement.

---

## 5. Output Signal Specifications

### 5.1 Complete Output Table

| Output | Type | Destination | Specification | Notes |
|--------|------|-------------|---------------|-------|
| **LLRF9 Enable** | DC (optocoupler) | LLRF9 external interlock input (daisy-chained pair) | ≥3.2 VDC @ ≥8 mA | Drives the shared external interlock input on the LLRF9 daisy chain. When removed, the LLRF9 disables its DAC output and opens its RF switch, which in turn pulls its own status output low. |
| **HVPS SCR ENABLE** | Fiber-optic (820 nm) | HVPS Right Side Trigger Interconnect Board (SD-730-793-07-C2) | HFBR-1412 transmitter | Hardware permit for phase control thyristor triggers. Removing this signal inhibits triggers on all phases except B+/B- (which remain enabled to discharge filter inductor current). |
| **HVPS KLYSTRON CROWBAR** | Fiber-optic (820 nm) | HVPS Left Side Trigger Interconnect Board (SD-730-793-08-C1) | HFBR-1412 transmitter | **Normally illuminated — no active control planned.** Removing this signal fires the crowbar thyristor stack to discharge HVPS output filter capacitors. |
| **Fault Status (all inputs)** | Digital lines | RF MPS ControlLogix PLC | TTL-level optocoupler outputs | Reports the state of every input permit to the MPS for monitoring and logging. |
| **Fault Status (all outputs)** | Digital lines | RF MPS ControlLogix PLC | TTL-level optocoupler outputs | Reports the state of every output permit to the MPS. |
| **First-Fault Register** | Digital lines | RF MPS ControlLogix PLC | TTL-level optocoupler outputs | Identifies which input signal was the first to fault in a cascade event. Held until MPS reset. |

**Note**: The Interface Chassis has **no PPS-related outputs**. All PPS interfaces (K4 relay, Ross switch, PPS readbacks) are handled by separate, dedicated PPS hardware systems.

### 5.2 HVPS Fiber-Optic Outputs

Three fiber-optic signals connect the Interface Chassis to the HVPS controller (ref: `hvps/architecture/designNotes/controllerFiberOpticConnections.docx`, `llrf/documentation/fiberOpticCableSignalControlRev3.docx`):

**1. SCR ENABLE (Interface Chassis → HVPS)**

This signal provides a hardware permit for the phase control thyristors. When the fiber is illuminated, the optical receiver in the HVPS Right Side Trigger Interconnect Board (SD-730-793-07-C2) pulls input U9B-2 to logic low, removing its inhibit from the thyristor triggers. When the fiber goes dark, U9B-2 is pulled high and triggers for phases A and C are inhibited on both the right side and (through the FO SCR ENABLE line on the COMMANDS bus) the left side interconnect boards. The B+/B- phase triggers remain enabled on both boards so that the filter inductor current can discharge safely.

This signal should be disabled whenever any permit input to the Interface Chassis is lost. It is the primary mechanism by which the LLRF system protects the klystron: when the LLRF detects a fault and disables RF drive, the klystron collector must not absorb the full HVPS DC beam power (SLAC B-factory klystrons are not full-collector designs).

**2. KLYSTRON CROWBAR (Interface Chassis → HVPS)**

This signal controls the HVPS output crowbar circuit. The **normal operating condition is fiber illuminated** (crowbar NOT fired). Removing the optical signal causes the receiver on the Left Side Trigger Interconnect Board (SD-730-793-08-C1) to trigger monostable U3B, which initiates firing of the crowbar thyristor stacks to discharge the HVPS output filter capacitors. The crowbar firing also disables the left side thyristor triggers and sets the SLAVE CROWBAR OFF signal on the COMMANDS bus, which in turn disables the right side triggers.

**There are currently no designs to actively control this signal from the Interface Chassis.** The signal must simply be kept illuminated to allow the HVPS to operate. The HVPS retains its own independent hardware crowbar triggers for transformer arcs (via the Stangenes ground fault current transformer) and klystron arcs (via the Pearson CT-110 current transformer in the termination tank). These hardware triggers fire the crowbar directly within the HVPS controller regardless of the fiber-optic state.

**Engineering rationale for not requiring external crowbar control**: SLAC-PUB-7591 (Cassel & Nguyen, 1997) demonstrates that even without the crowbar firing, passive circuit elements (2 × 0.5 Ω resistors per output capacitor, series inductors in the termination tank) limit the energy delivered to the klystron during an arc to below the threshold for catastrophic damage. The crowbar reduces this energy by an additional factor of approximately four.

**3. STATUS (HVPS → Interface Chassis)**

This signal provides a basic health indication from the HVPS controller. The Left Side Trigger Interconnect Board illuminates the STATUS fiber when two conditions are met:
1. The PLC 24V Fault/Enable signal (Slot-5 OUT 0, labeled "Control System Enable" in PLC code) is at logic high
2. No condition has caused the crowbar circuit to fire (no klystron arc trigger, no transformer arc trigger, no PLC force crowbar command, no loss of KLYSTRON CROWBAR fiber)

**This signal does NOT indicate**:
- That the Enerpro FCOG6100 firing circuit has been enabled
- That the thyristor triggers are actually firing
- That the HVPS output is at the desired voltage
- That the HVPS is regulating properly

It is a necessary-but-not-sufficient indicator of HVPS readiness. The Interface Chassis uses this signal as one input to the permit logic. If STATUS is lost, the Interface Chassis removes permits to the LLRF9 and the SCR ENABLE.

> **Fiber-optic component note**: The source document `llrfInterfaceChassis.docx` states "The drivers will be HFBR-2412 and the receiver will be HFBR-1412." This appears to contain a transposition error in the part numbers. Per Broadcom convention and datasheets, **HFBR-1412 is a fiber-optic transmitter** and **HFBR-2412 is a fiber-optic receiver**. The Interface Chassis therefore uses HFBR-1412 (transmitter) for its two output signals (SCR ENABLE, CROWBAR) and HFBR-2412 (receiver) for the STATUS input. These are the same component family (820 nm, ST/SMA port) used in the legacy Local Panel (which used HFBR-1414 transmitters and HFBR-2416 receivers, the SMA-port variants of the same series).

---

## 6. Permit Logic Implementation

### 6.1 Master Permit Equation

```
All_Permits_OK = LLRF9_Status AND HVPS_STATUS AND MPS_RF_Summary_Permit AND 
                 MPS_Heartbeat AND MPS_External_Reset_OK AND SPEAR_MPS_Permit AND 
                 Orbit_Interlock_Permit AND Arc_Detection AND Power_Monitoring AND
                 Expansion_Port_1 AND Expansion_Port_2 AND Expansion_Port_3 AND Expansion_Port_4

LLRF9_Enable    = All_Permits_OK
HVPS_SCR_ENABLE = All_Permits_OK
HVPS_CROWBAR    = 1  (always illuminated; no active control mechanism in current design)
```

### 6.2 Implementation

The permit logic is implemented as a hardware AND gate with all input signals feeding into it. When any input signal is lost (goes to logic low), the AND gate output goes low, which immediately removes the LLRF9 Enable and HVPS SCR ENABLE outputs.

The HVPS CROWBAR signal is not part of the permit logic — it is simply kept illuminated at all times to prevent inadvertent crowbar firing.

---

## 7. LLRF9-HVPS Feedback Loop Analysis

### 7.1 The Problem

The Interface Chassis creates a bidirectional feedback loop between LLRF9 and HVPS that complicates system recovery. From the source document (`llrf/architecture/llrfInterfaceChassis.docx`):

> "When the Interface Chassis removes the LLRF9 Enable, the LLRF9 status output goes low (because the Enable is one of the 18 ORed inputs). The system cannot self-recover without explicit recovery sequencing logic."

**Fault cascade scenario**:
1. Any permit input to Interface Chassis faults (e.g., arc detection, power monitoring, MPS heartbeat loss)
2. Interface Chassis removes LLRF9 Enable and HVPS SCR ENABLE simultaneously
3. LLRF9 sees external permit removed → disables DAC output → opens RF switch → LLRF9 Status output goes low
4. HVPS sees SCR ENABLE removed → thyristor triggers inhibited → HVPS output voltage decays
5. HVPS STATUS may go dark (depending on PLC logic and crowbar state)
6. Interface Chassis now sees **both** LLRF9 Status = OFF **and** HVPS STATUS = OFF as additional faulted inputs

**Recovery problem**: Even after the original fault clears, the Interface Chassis cannot self-recover because:
- LLRF9 Status remains low until LLRF9 Enable is restored
- HVPS STATUS may remain dark until SCR ENABLE is restored
- But Interface Chassis won't restore enables while it sees LLRF9 Status and HVPS STATUS as faulted inputs

```
Original Fault → IC removes enables → LLRF9/HVPS respond → Status signals go low
     ^                                                            |
     |                                                            v
     +--- IC sees LLRF9/HVPS Status OFF (additional fault inputs) ←+
```

### 7.2 Required Recovery Sequence

The source document specifies a 5-step recovery sequence that must be implemented in the Interface Chassis logic:

1. **Confirm HVPS is off**: Verify HVPS STATUS is dark and HVPS output voltage is zero
2. **Coordinate STATUS state**: Ensure HVPS STATUS reflects the actual HVPS state (not just the absence of SCR ENABLE)
3. **Re-assert LLRF9 Enable**: Restore external permit to LLRF9 daisy chain
4. **Await MPS reset**: Wait for MPS External Reset signal to clear all latched faults
5. **Re-assert SCR ENABLE**: Restore HVPS thyristor trigger permits

**Critical timing consideration**: The Interface Chassis must implement this sequencing logic because it did not exist in the legacy system. The legacy Local Panel and VXI modules operated independently without coordinated recovery.

### 7.3 Design Implications

**First-fault register importance**: The first-fault detection circuit becomes critical for diagnosing the root cause when multiple systems cascade. Without it, operators cannot distinguish between:
- **Primary fault**: Original system failure (e.g., arc detection, power monitoring trip)
- **Consequential faults**: LLRF9 Status and HVPS STATUS going low as expected responses to Interface Chassis removing their enables

**Logic complexity**: The Interface Chassis must implement state machine logic that:
- Recognizes when LLRF9 Status and HVPS STATUS are low due to its own actions (not new faults)
- Sequences the recovery steps in the correct order
- Handles timeout conditions if any step fails to complete
- Provides diagnostic information to the MPS for troubleshooting

This sequencing logic represents a significant increase in complexity compared to the simple combinational permit logic originally envisioned.

---

## 8. Integration Summary

### 8.1 Interface Summary Table

| Interface Partner | Signal Direction | Signals | Medium |
|-------------------|-----------------|---------|--------|
| LLRF9 Controllers | LLRF9 → IC | Status (5 VDC) | Wire pair |
| LLRF9 Controllers | IC → LLRF9 | Enable (3.2 VDC @ 8 mA) | Wire pair |
| HVPS Controller | HVPS → IC | STATUS (fiber) | Fiber-optic (ST) |
| HVPS Controller | IC → HVPS | SCR ENABLE (fiber), CROWBAR (fiber) | Fiber-optic (ST) |
| MPS PLC | MPS → IC | Summary Permit, Heartbeat, Reset | Multi-conductor cable |
| IC IOC | IC → Network | All status, first-fault register, arc trip data | EPICS CA (Ethernet) |
| Arc Detectors | Arc → IC | Permit (dry contact/TTL) | Wire pairs |
| Waveform Buffer | WB → IC | Power Signal Permit (TTL) | Wire pairs |
| SPEAR MPS | SPEAR → IC | Permit (24V) | Wire pair |
| Orbit Interlock | Orbit → IC | Permit (24V) | Wire pair |

**Important**: No PPS interfaces. All PPS connections are handled by separate, dedicated PPS hardware systems.

---

## 9. EPICS IOC Interface

The Interface Chassis has a **dedicated EPICS IOC** (analogous to the Heater Controller and Waveform Buffer IOCs) that publishes all IC status data directly onto the EPICS network. The Python coordinator accesses the IC entirely through this IOC — there is no indirect path through the MPS PLC for IC or arc detection data.

**PV prefix**: `SRF1:IC:`

### 9.1 Published PVs

| PV | Type | Description |
|----|------|-------------|
| `SRF1:IC:LLRF9_STATUS` | Binary | LLRF9 status input to IC |
| `SRF1:IC:HVPS_STATUS` | Binary | HVPS STATUS fiber input to IC |
| `SRF1:IC:MPS_PERMIT` | Binary | MPS RF Summary Permit input to IC |
| `SRF1:IC:SPEAR_MPS_PERMIT` | Binary | SPEAR MPS permit input to IC |
| `SRF1:IC:ORBIT_INTERLOCK` | Binary | Orbit interlock permit input to IC |
| `SRF1:IC:ARC_DETECTION` | Binary | Arc detection summary permit to IC |
| `SRF1:IC:POWER_MONITORING` | Binary | Waveform Buffer power monitoring permit to IC |
| `SRF1:IC:LLRF9_ENABLE` | Binary | IC output: LLRF9 Enable |
| `SRF1:IC:HVPS_SCR_ENABLE` | Binary | IC output: HVPS SCR ENABLE (fiber) |
| `SRF1:IC:FIRST_FAULT_REG` | Integer | First-fault register bit field |
| `SRF1:IC:FIRST_FAULT_TIME` | String | Timestamp of first fault |
| `SRF1:IC:RECOVERY_ACTIVE` | Binary | IC recovery sequence in progress |
| `SRF1:IC:ARC:CAV_A_TRIP` | Binary | Cavity A arc sensor trip status |
| `SRF1:IC:ARC:CAV_B_TRIP` | Binary | Cavity B arc sensor trip status |
| `SRF1:IC:ARC:CAV_C_TRIP` | Binary | Cavity C arc sensor trip status |
| `SRF1:IC:ARC:CAV_D_TRIP` | Binary | Cavity D arc sensor trip status |
| `SRF1:IC:ARC:KLY_TRIP` | Binary | Klystron arc sensor trip status |
| `SRF1:IC:ARC:SUMMARY_TRIP` | Binary | Any arc detected (OR of all 5 sensors) |
| `SRF1:IC:ARC:FIRED_ID_REG` | Integer | 5-bit register identifying which sensor(s) fired |
| `SRF1:IC:ARC:EVENT_COUNT` | Integer | Total arc events since startup |
| `SRF1:IC:ARC:LAST_EVENT_TIME` | String | Timestamp of last arc event |

**Note**: Arc detection PVs are published by the IC IOC because the arc detectors connect hardwired (dry relay contacts) directly to the Interface Chassis hardware.

**Safety invariant**: The IOC is a read-only diagnostic and monitoring interface. The IOC crash or loss of Ethernet does not affect the IC hardware permit logic, which operates autonomously at <1 μs in hardware.

---

## 10. Implementation Status and Next Steps

### 10.1 Current Status

- **Interface specification**: ✅ Complete (J. Sebek, `llrf/architecture/llrfInterfaceChassis.docx`)
- **Chassis mechanical design**: ❌ Not started
- **PCB design**: ❌ Not started  
- **Fabrication**: ❌ Not started
- **EPICS IOC development**: ❌ Not started
- **Testing**: ❌ Not started

### 10.2 Critical Path Items

1. **Chassis mechanical design** — 19-inch rack-mount enclosure with front-panel indicators
2. **PCB design** — Mixed-voltage optocoupler circuits, fiber-optic transceiver mounting, first-fault logic
3. **Component procurement** — Long-lead items: optocouplers, fiber-optic transceivers, connectors
4. **Fabrication and assembly** — PCB fabrication, chassis assembly, cable harnesses
5. **EPICS IOC development** — Soft IOC reading IC digital I/O and publishing `SRF1:IC:` PVs
6. **Factory testing** — Bench testing of all input/output interfaces and logic functions
7. **Integration testing** — Testing with actual LLRF9, HVPS, and MPS hardware

### 10.3 Open Questions

1. **Physical location**: Inside existing Hoffman Box, separate enclosure, or 19-inch rack mount?
2. **Power supply**: AC mains or DC from equipment rack?
3. **Front-panel indicators**: LEDs for each input/output state and first-fault register?
4. **Connector types**: D-sub, terminal blocks, or modular connectors for digital I/O?
5. **Cable routing**: Conduit paths from Interface Chassis to all connected subsystems?
6. **IOC host**: Embedded SBC inside IC chassis, or soft IOC on the control room PC?

**Note**: The Interface Chassis is on the critical path for system integration. All other subsystems (LLRF9, HVPS, MPS PLC) are waiting for the Interface Chassis to coordinate their interlock signals.
