# SPEAR3 Machine Protection System (MPS) Design Report

**Document ID**: SPEAR3-LLRF-DR-010
**Title**: RF Machine Protection System --- ControlLogix 1756 PLC-Based Interlock Aggregation and Fault Management
**Author**: LLRF Upgrade Team
**Date**: March 2026
**Version**: 1.0
**Status**: Hardware Assembled, Software Written, Tested Without RF Power

**Reference Documents**:
| Document | Location | Content |
|----------|----------|---------|
| System Overview | `Designs/1_Overview of Current and Upgrade System.md` | MPS in upgrade scope (Section 2.1, 4.5) |
| LLRF9 System Report | `Designs/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` | LLRF9 interlock system |
| HVPS Technical Note | `Designs/4_HVPS_Engineering_Technical_Note.md` | HVPS interlock integration |
| HVPS-PPS Interface | `Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` | PPS and MPS coordination |
| Software Design | `Designs/9_SOFTWARE_DESIGN.md` | Python coordinator MPS interface |
| Waveform Buffer Design | `Designs/6_WAVEFORM_BUFFER_SYSTEM_DESIGN.md` | Collector protection integration |
| Arc Detector Design | `Designs/7_ARC_DETECTOR_SYSTEM_DESIGN.md` | Arc interlock integration |
| Interface Chassis Design | `Designs/11_INTERFACE_CHASSIS_DESIGN.md` | MPS-Interface Chassis coordination |
| MPS Requirements | `hvps/architecture/designNotes/RFSystemMPSRequirements.docx` | Original MPS requirements |
| MPS Wiring Diagrams | `llrf/documentation/mpsWiringDiagrams/wd3403300200-3400.pdf` | Legacy MPS wiring (34 sheets) |
| PPS System Overview | `pps/diagrams/00_SYSTEM_OVERVIEW.md` | PPS-MPS boundary |
| PLC Code and Logic | `pps/diagrams/07_PLC_CODE_AND_LOGIC.md` | Legacy PLC ladder logic reference |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Legacy MPS System](#2-legacy-mps-system)
3. [Upgraded MPS Architecture](#3-upgraded-mps-architecture)
4. [MPS Functions and Responsibilities](#4-mps-functions-and-responsibilities)
5. [Interlock Input Sources](#5-interlock-input-sources)
6. [MPS Output Signals](#6-mps-output-signals)
7. [Interface Chassis Coordination](#7-interface-chassis-coordination)
8. [PLC Hardware Configuration](#8-plc-hardware-configuration)
9. [PLC Software Architecture](#9-plc-software-architecture)
10. [EPICS IOC and PV Database](#10-epics-ioc-and-pv-database)
11. [Fault Management Logic](#11-fault-management-logic)
12. [Redundant Protection Coordination](#12-redundant-protection-coordination)
13. [Wiring and I/O Maps](#13-wiring-and-io-maps)
14. [Implementation Status and Next Steps](#14-implementation-status-and-next-steps)

---

## 1. Executive Summary

The Machine Protection System (MPS) is the central fault management and interlock aggregation system for the SPEAR3 RF station. It replaces the legacy **Allen-Bradley PLC-5 (1771-series)** with a modern **Allen-Bradley ControlLogix 1756 PLC** platform.

The MPS serves as the intelligence layer that aggregates interlock status from all RF subsystems, makes permit decisions, manages fault logging, and coordinates with the Interface Chassis (which handles the fast hardware interlock path). Unlike the Interface Chassis --- which operates at hardware speed with microsecond response --- the MPS operates at PLC scan rates (milliseconds) and provides:

1. **Interlock aggregation**: Collects status from LLRF9, HVPS, arc detectors, vacuum systems, beam current monitors, and other sources
2. **Summary Permit**: Provides a single MPS Summary Permit signal to the Interface Chassis
3. **Heartbeat/watchdog**: Generates a periodic heartbeat signal to prove the MPS PLC is running
4. **Reset coordination**: Issues reset commands to clear latched faults in the Interface Chassis
5. **Fault logging**: Records fault events with timestamps for post-event analysis
6. **Status reporting**: Reads back Interface Chassis first-fault register and subsystem status
7. **Operator interface**: Provides EPICS PVs for status display, fault acknowledgment, and system control

**Status**: Hardware assembled, PLC software written and tested without RF power. Ready for EPICS IOC development and system integration.

---

## 2. Legacy MPS System

### 2.1 Legacy Hardware

The legacy RF MPS uses an **Allen-Bradley PLC-5 (1771-series)** platform:

| Component | Description |
|-----------|-------------|
| **Processor** | PLC-5 (1771 chassis) |
| **I/O modules** | 1771-series digital and analog I/O |
| **Communication** | Data Highway Plus (DH+) to VxWorks IOC |
| **Wiring** | Documented in 34 wiring diagram sheets (wd3403300200 through wd3403303400) |

### 2.2 Legacy MPS Functions

The legacy MPS aggregates interlocks from:
- RF power levels (from VXI-based signal processors)
- HVPS status signals
- Cavity vacuum interlocks
- Beam current monitors
- Water flow interlocks (cavity and waveguide cooling)
- Temperature interlocks
- External permits (SPEAR MPS, orbit interlocks)

### 2.3 Reasons for Upgrade

| Issue | Impact |
|-------|--------|
| **Hardware obsolescence** | PLC-5 and 1771-series modules discontinued by Allen-Bradley |
| **Spare parts** | Increasingly difficult and expensive to obtain |
| **Communication** | DH+ protocol is obsolete; no modern EPICS drivers |
| **Expandability** | Cannot easily add new interlock sources (arc detection, Waveform Buffer) |
| **Documentation** | Legacy PLC code requires reverse engineering |

---

## 3. Upgraded MPS Architecture

### 3.1 Hardware Platform

The upgraded MPS uses an **Allen-Bradley ControlLogix 1756 PLC**:

| Component | Description |
|-----------|-------------|
| **Processor** | ControlLogix L7x or L8x series |
| **Chassis** | 1756 chassis (slot count TBD based on I/O requirements) |
| **Digital I/O** | 1756-series digital input and output modules |
| **Analog I/O** | 1756-series analog input modules (for Waveform Buffer signals) |
| **Communication** | EtherNet/IP to EPICS IOC |
| **Programming** | Studio 5000 Logix Designer (ladder logic, structured text, function blocks) |

### 3.2 System Architecture

```
                    Interlock Sources
    +--------+--------+--------+--------+--------+
    | LLRF9  | HVPS   | Arc    | Vacuum | External|
    | Status | Status | Det.   | Intlks | Permits |
    +---+----+---+----+---+----+---+----+---+-----+
        |        |        |        |        |
        v        v        v        v        v
    +------------------------------------------------+
    |        ControlLogix 1756 MPS PLC               |
    |                                                 |
    |  +------------------+  +--------------------+  |
    |  | Interlock        |  | Fault Management   |  |
    |  | Aggregation      |  | and Logging        |  |
    |  +--------+---------+  +----------+---------+  |
    |           |                       |             |
    |  +--------v---------+  +----------v---------+  |
    |  | Permit Decision  |  | Status Reporting   |  |
    |  | Logic            |  | to EPICS           |  |
    |  +--------+---------+  +--------------------+  |
    +-----------|-------------------------------------+
                |
        +-------v-------+
        | To Interface   |
        | Chassis:       |
        | - Summary Permit
        | - Heartbeat    |
        | - Reset        |
        +-------+-------+
                |
        +-------v-------+
        | From Interface |
        | Chassis:       |
        | - Status Lines |
        | - First-Fault  |
        +----------------+
```

### 3.3 Division of Responsibility: MPS vs. Interface Chassis

| Function | MPS PLC | Interface Chassis |
|----------|---------|-------------------|
| **Fast hardware interlock** | No (too slow) | Yes (microsecond response) |
| **Interlock aggregation** | Yes (PLC scan rate) | Yes (hardware OR of permits) |
| **First-fault detection** | No (software timing insufficient) | Yes (hardware latching) |
| **Summary permit** | Yes (generates signal) | Yes (receives and uses signal) |
| **Heartbeat/watchdog** | Yes (generates signal) | Yes (monitors signal) |
| **Fault logging** | Yes (with timestamps) | No (no storage) |
| **Reset coordination** | Yes (issues reset) | Yes (receives and executes reset) |
| **EPICS interface** | Yes (via EtherNet/IP) | No (status read by MPS) |
| **Operator display** | Yes (PVs for EDM/web) | No (status via MPS PVs) |

---

## 4. MPS Functions and Responsibilities

### 4.1 Primary Functions

1. **Interlock Monitoring**: Continuously scan all interlock input sources at PLC scan rate
2. **Permit Logic**: Evaluate all interlocks and generate MPS Summary Permit
3. **Heartbeat Generation**: Output a periodic toggling signal to prove PLC is alive
4. **Reset Management**: Accept operator or automatic reset commands and propagate to Interface Chassis
5. **Fault Logging**: Record all fault events with timestamps and source identification
6. **Status Aggregation**: Collect status from Interface Chassis and all subsystems
7. **Redundant Calculations**: Perform backup collector power calculation from Waveform Buffer analog signals

### 4.2 Non-Safety Functions

The MPS also provides non-safety monitoring functions:
- RF power level monitoring and trending
- HVPS voltage and current monitoring
- Temperature monitoring (various locations)
- Cooling water flow monitoring
- Vacuum system status monitoring

These functions support operations but are not in the safety interlock path.

---

## 5. Interlock Input Sources

### 5.1 Complete Interlock Input Table

| Input Source | Signal Type | Module | Priority | Notes |
|--------------|-------------|--------|----------|-------|
| **LLRF9 Unit 1 Status** | Digital (via IC) | DI | Critical | Field control unit |
| **LLRF9 Unit 2 Status** | Digital (via IC) | DI | Critical | Monitor/interlock unit |
| **HVPS Status** | Digital (via IC) | DI | Critical | HVPS controller ready |
| **Arc Detection Permit** | Digital (via IC) | DI | Critical | All arc detectors combined |
| **Waveform Buffer Permit** | Digital (via IC) | DI | Critical | All comparator trips combined |
| **Collector Power Trip** | Digital (via IC) | DI | Critical | Collector protection |
| **Cavity 1 Vacuum** | Digital | DI | High | Vacuum interlock |
| **Cavity 2 Vacuum** | Digital | DI | High | Vacuum interlock |
| **Cavity 3 Vacuum** | Digital | DI | High | Vacuum interlock |
| **Cavity 4 Vacuum** | Digital | DI | High | Vacuum interlock |
| **Beam Current** | Analog or digital | AI/DI | High | Beam loss detection |
| **Cooling Water Flow** | Digital | DI | Medium | Cavity/waveguide cooling |
| **Temperature Interlocks** | Digital | DI | Medium | Various locations |
| **SPEAR MPS Permit** | Digital (via IC) | DI | Critical | Ring-level protection |
| **Orbit Interlock** | Digital (via IC) | DI | Critical | Beam position safety |
| **Interface Chassis Status** | Multi-bit digital | DI | Critical | First-fault register readback |

### 5.2 Signal Path Note

Many critical interlock signals reach the MPS through two paths:
- **Direct digital input**: For MPS logging and status reporting
- **Via Interface Chassis**: For fast hardware interlock action

This dual-path architecture ensures that the fast hardware protection (Interface Chassis) is never limited by PLC scan time, while the MPS still has full visibility into all interlock sources for fault management.

---

## 6. MPS Output Signals

### 6.1 To Interface Chassis

| Signal | Type | Description |
|--------|------|-------------|
| **MPS Summary Permit** | Digital | AND of all MPS-evaluated interlocks; active = all OK |
| **MPS Heartbeat** | Digital (toggling) | Periodic toggle signal proving PLC is running |
| **MPS Reset** | Digital (pulsed) | Reset command to clear all latched faults in Interface Chassis |

### 6.2 To HVPS Controller (CompactLogix)

| Signal | Type | Description |
|--------|------|-------------|
| **HVPS Voltage Setpoint** | Via Python/EPICS | Supervisory voltage control (not from MPS PLC directly) |
| **MPS HVPS Permit** | Digital | MPS-level permit for HVPS operation |

### 6.3 To EPICS (via EtherNet/IP)

All MPS status, fault logs, and control commands are exposed as EPICS PVs (see Section 10).

---

## 7. Interface Chassis Coordination

### 7.1 Signal Exchange

The MPS and Interface Chassis exchange the following signals:

| Signal | Direction | Purpose |
|--------|-----------|---------|
| MPS Summary Permit | MPS -> IC | Combined MPS permit |
| MPS Heartbeat | MPS -> IC | PLC watchdog |
| MPS Reset | MPS -> IC | Clear latched faults |
| IC Status Lines | IC -> MPS | Input/output states and first-fault register |

### 7.2 Heartbeat Protocol

The MPS heartbeat is a digital signal that toggles at a defined rate (e.g., 1 Hz or 2 Hz). The Interface Chassis monitors this signal:

- **Heartbeat present**: Normal operation; Interface Chassis treats MPS as healthy
- **Heartbeat absent** (signal stuck high or low for > timeout period): Interface Chassis treats this as an MPS failure and may remove permits as a safety measure

The heartbeat timeout period must be coordinated between the MPS PLC scan time and the Interface Chassis monitoring logic.

### 7.3 Reset Sequence

When the operator or Python coordinator requests a fault reset:

1. Python coordinator sends reset command via EPICS PV to MPS PLC
2. MPS PLC verifies that the fault condition has cleared (source interlock restored)
3. MPS PLC asserts MPS Reset signal to Interface Chassis (digital pulse)
4. Interface Chassis clears all latched faults in the first-fault register
5. Interface Chassis restores output permits (LLRF9 Enable, HVPS SCR ENABLE)
6. MPS PLC verifies that Interface Chassis status lines show all clear
7. MPS PLC reports successful reset via EPICS PVs

### 7.4 First-Fault Readback

The Interface Chassis provides its first-fault register contents to the MPS via multi-bit digital status lines. The MPS PLC reads these lines and translates them into EPICS PVs for operator display.

---

## 8. PLC Hardware Configuration

### 8.1 Module Lineup

The ControlLogix 1756 chassis is configured with the following modules (preliminary):

| Slot | Module | Function |
|------|--------|----------|
| 0 | 1756-L7x | ControlLogix processor |
| 1 | 1756-EN2T | EtherNet/IP communication module |
| 2 | 1756-IB16 | 16-point digital input (interlock sources group 1) |
| 3 | 1756-IB16 | 16-point digital input (interlock sources group 2) |
| 4 | 1756-IB16 | 16-point digital input (Interface Chassis status) |
| 5 | 1756-OB16 | 16-point digital output (permits, heartbeat, reset) |
| 6 | 1756-IF8 | 8-channel analog input (Waveform Buffer signals) |
| 7 | 1756-PA75 | Power supply (redundant) |
| TBD | Additional modules as needed | Expansion for future interlocks |

### 8.2 Communication

| Interface | Protocol | Purpose |
|-----------|----------|---------|
| **EtherNet/IP** | CIP over TCP/IP | Primary communication to EPICS IOC |
| **Digital I/O** | Hardwired | Interface Chassis, interlock sources |
| **Analog I/O** | Hardwired | Waveform Buffer signals |

### 8.3 Power and Reliability

- **Redundant power supply**: Dual power supply modules for high availability
- **Battery backup**: Processor battery for program and data retention during power loss
- **Scan time**: Configurable; target < 10 ms for interlock scan task
- **Watchdog**: Built-in processor watchdog timer

---

## 9. PLC Software Architecture

### 9.1 Program Structure

The MPS PLC software is organized into the following tasks and programs:

| Task | Priority | Period | Function |
|------|----------|--------|----------|
| **Interlock_Scan** | High | 5-10 ms | Scan all interlock inputs, update summary permit |
| **Fault_Management** | Medium | 50 ms | Fault logging, timestamp capture, status update |
| **Heartbeat** | High | 500 ms | Toggle heartbeat output |
| **Communication** | Low | 100 ms | Update EPICS-mapped tags |
| **Collector_Calc** | Medium | 100 ms | Redundant collector power calculation |
| **Diagnostics** | Low | 1000 ms | Self-diagnostics, module health checks |

### 9.2 Interlock Logic

The MPS Summary Permit logic (simplified):

```
MPS_Summary_Permit = 
    LLRF9_Unit1_OK AND
    LLRF9_Unit2_OK AND
    HVPS_Status_OK AND
    Arc_Detection_Permit AND
    Waveform_Buffer_Permit AND
    Collector_Power_OK AND
    All_Vacuum_OK AND
    Beam_Current_OK AND
    Cooling_Water_OK AND
    Temperature_OK AND
    SPEAR_MPS_Permit AND
    Orbit_Interlock_OK AND
    No_Unacknowledged_Critical_Faults
```

### 9.3 Fault Categories

| Category | Reset Policy | Example Sources |
|----------|-------------|-----------------|
| **Auto-reset** | Automatically clears when source clears | Transient RF trips, single arc events |
| **Manual-reset** | Requires operator acknowledgment | Repeated arcs, vacuum trips, HVPS faults |
| **Latched** | Requires explicit operator reset | PPS-related, collector power trip, system faults |

---

## 10. EPICS IOC and PV Database

### 10.1 EPICS Communication

The MPS PLC communicates with EPICS through an EtherNet/IP driver. Options include:
- **pycomm3**: Python library for Allen-Bradley PLC communication
- **OPC-UA**: Via ControlLogix OPC-UA server
- **Custom EtherNet/IP driver**: Direct CIP protocol implementation

### 10.2 Process Variable Database

**System Status PVs**:
```
SRF1:MPS:STATUS                    # Overall MPS status (OK/FAULT/OFFLINE)
SRF1:MPS:SUMMARY_PERMIT            # MPS Summary Permit state (1/0)
SRF1:MPS:HEARTBEAT                 # Heartbeat state (toggling)
SRF1:MPS:SCAN_TIME                 # Current PLC scan time (ms)
SRF1:MPS:UPTIME                    # PLC uptime (seconds)
```

**Per-Interlock PVs (for each source)**:
```
SRF1:MPS:INTLK:{source}:STATUS    # Interlock status (OK/TRIPPED)
SRF1:MPS:INTLK:{source}:LATCHED   # Latched fault flag
SRF1:MPS:INTLK:{source}:TIME      # Timestamp of last fault
SRF1:MPS:INTLK:{source}:COUNT     # Cumulative fault count
SRF1:MPS:INTLK:{source}:ENABLE    # Enable/disable this interlock
```

**Fault Management PVs**:
```
SRF1:MPS:FAULT:ACTIVE_COUNT        # Number of active faults
SRF1:MPS:FAULT:FIRST_FAULT         # Identity of first fault (from IC)
SRF1:MPS:FAULT:LAST_FAULT          # Identity of most recent fault
SRF1:MPS:FAULT:LOG                 # Fault log array (last N events)
SRF1:MPS:FAULT:RESET               # Reset command (write 1 to reset)
SRF1:MPS:FAULT:ACK                 # Acknowledge command
```

**Collector Protection PVs (redundant calculation)**:
```
SRF1:MPS:COLL:DC_POWER             # DC power from analog inputs (kW)
SRF1:MPS:COLL:RF_POWER             # RF power from analog inputs (kW)
SRF1:MPS:COLL:DISSIPATION          # Calculated collector power (kW)
SRF1:MPS:COLL:LIMIT                # Collector limit setting (kW)
SRF1:MPS:COLL:STATUS               # Collector protection status
```

---

## 11. Fault Management Logic

### 11.1 Fault Detection and Response

When any interlock source trips:

1. **PLC scan detects** the changed input state
2. **Timestamp captured** using PLC system clock
3. **Fault logged** in internal fault buffer (circular, last N events)
4. **MPS Summary Permit** re-evaluated (may be removed if critical interlock)
5. **EPICS PVs updated** for operator display
6. **If auto-reset category**: MPS monitors source; when source clears, fault automatically resets
7. **If manual-reset category**: Fault remains active until operator acknowledges via EPICS PV

### 11.2 Fault Prioritization

| Priority | Sources | MPS Response |
|----------|---------|-------------|
| **Critical** | LLRF9, HVPS, arc, collector, PPS, SPEAR MPS | Immediate Summary Permit removal |
| **High** | Vacuum, beam current | Summary Permit removal after confirmation |
| **Medium** | Cooling, temperature | Warning first; permit removal if sustained |
| **Low** | Non-safety monitoring | Alarm only; no permit action |

### 11.3 Fault History

The MPS maintains a circular fault history buffer in PLC memory:
- **Buffer size**: Last 100-500 fault events (TBD)
- **Per-event data**: Source ID, timestamp, fault type, auto/manual reset status
- **EPICS access**: Fault history readable via EPICS waveform PVs
- **Persistent storage**: Python coordinator archives fault history to disk

---

## 12. Redundant Protection Coordination

### 12.1 Multi-Layer Protection Architecture

The SPEAR3 RF system implements defense-in-depth with multiple independent protection layers:

| Layer | System | Response Time | Function |
|-------|--------|---------------|----------|
| **Layer 1** | LLRF9 internal interlocks | 270 ns - microseconds | RF overvoltage, reflected power |
| **Layer 2** | Interface Chassis | < 1 microsecond | Hardware permit logic, first-fault |
| **Layer 3** | Waveform Buffer comparators | < 1 microsecond | RF/HVPS threshold trips |
| **Layer 4** | MPS PLC | < 10 ms | Aggregated interlock logic |
| **Layer 5** | Python coordinator | ~1 second | Supervisory monitoring, logging |

### 12.2 Collector Power Protection Redundancy

The klystron collector power is protected by three independent systems:

1. **Waveform Buffer System** (primary, hardware speed): Analog computation with hardware trip
2. **MPS PLC** (secondary, millisecond speed): Digital computation from buffered analog signals
3. **Python coordinator** (tertiary, ~1 Hz): Software monitoring with alarm and logging

---

## 13. Wiring and I/O Maps

### 13.1 Legacy Wiring Reference

The legacy MPS wiring is documented in 34 wiring diagram sheets:

| Drawing Range | Content |
|---------------|---------|
| wd3403300200 - wd3403300500 | Power distribution, PLC chassis |
| wd3403300601 - wd3403301000 | Digital input wiring (interlocks) |
| wd3403301100 - wd3403301500 | Digital output wiring (permits) |
| wd3403301600 - wd3403302000 | Analog I/O wiring |
| wd3403302100 - wd3403302500 | Field wiring to tunnel |
| wd3403302600 - wd3403303000 | Interface wiring |
| wd3403303100 - wd3403303400 | Miscellaneous and spare |

### 13.2 Upgrade Wiring Considerations

- Existing field wiring (tunnel to B118) is retained where possible
- New wiring required for Interface Chassis interconnection
- New analog inputs from Waveform Buffer System
- ControlLogix module terminal blocks replace 1771-series wiring
- All new wiring must comply with SLAC ES&H wiring standards

---

## 14. Implementation Status and Next Steps

### 14.1 Current Status

| Item | Status |
|------|--------|
| ControlLogix 1756 hardware | Assembled |
| PLC modules | Procured (for HVPS1, HVPS2, and B44 Test Stand) |
| PLC software | Written |
| Testing without RF | Complete |
| EPICS IOC development | Not started |
| EtherNet/IP driver evaluation | Not started |
| Interface Chassis integration | Pending IC fabrication |
| System integration with RF | Not started |

### 14.2 Next Steps

1. **Evaluate EPICS communication options** (pycomm3, OPC-UA, custom EtherNet/IP)
2. **Develop EPICS IOC** with complete PV database
3. **Integrate with Interface Chassis** when IC is fabricated
4. **Test complete interlock chain** from source through IC through MPS
5. **Develop Python coordinator MPS interface** module
6. **Commission on Test Stand 18** (B44) with simulated signals
7. **System commissioning** with live RF signals during SPEAR3 shutdown

### 14.3 Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| EtherNet/IP EPICS driver issues | Medium | Medium | Evaluate multiple options early; pycomm3 is well-tested |
| PLC scan time too slow for some interlocks | Low | Low | Critical interlocks use Interface Chassis hardware path |
| Legacy wiring incompatibility | Medium | Low | Verify all field wiring before cutover |
| Fault logic complexity | Medium | Medium | Thorough testing on test stand before SPEAR3 installation |
| Interface Chassis coordination timing | Medium | Medium | Design and simulate MPS-IC protocol before integration |
| Incomplete legacy code reverse engineering | Medium | Medium | Complete documentation before CompactLogix migration |

---

*End of Document*
