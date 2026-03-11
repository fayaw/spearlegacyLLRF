# SPEAR3 HVPS Switchgear System Overview

**Document ID:** HVPS-SG-OVERVIEW-001  
**Revision:** R0  
**Date:** March 2026  
**Author:** Engineering Team (SSRL/SLAC)  
**Classification:** System Overview — Comprehensive Reference

---

## Purpose and Scope

This document provides a comprehensive overview of the SPEAR3 High Voltage Power Supply (HVPS) switchgear system, integrating information from circuit schematics, technical documentation, and system design references. It serves as the primary reference for understanding the complete switchgear architecture, its role in the SPEAR3 RF system, and its integration with the LLRF upgrade project.

**Key Documentation Sources:**
- Circuit schematic technical notes (this directory)
- HVPS Engineering Technical Note (`Designs/4_HVPS_Engineering_Technical_Note.md`)
- HVPS-PPS Interface Document (`Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md`)
- LLRF9 System Report (`Designs/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md`)
- Legacy system documentation (`llrf/`, `pps/`)

---

## Table of Contents

1. [System Context — SPEAR3 RF Station](#1-system-context--spear3-rf-station)
2. [HVPS Switchgear Architecture](#2-hvps-switchgear-architecture)
3. [Vacuum Contactor Controller System](#3-vacuum-contactor-controller-system)
4. [Energy Storage and Closing System](#4-energy-storage-and-closing-system)
5. [Protection and Safety Systems](#5-protection-and-safety-systems)
6. [Personnel Protection System (PPS) Interface](#6-personnel-protection-system-pps-interface)
7. [Control and Monitoring Systems](#7-control-and-monitoring-systems)
8. [Physical Installation and Layout](#8-physical-installation-and-layout)
9. [Integration with LLRF Upgrade](#9-integration-with-llrf-upgrade)
10. [Technical Specifications Summary](#10-technical-specifications-summary)
11. [Document Cross-Reference](#11-document-cross-reference)

---

## 1. System Context — SPEAR3 RF Station

### 1.1 Overall RF System Architecture

The SPEAR3 storage ring operates with a single RF station consisting of:

- **One klystron** (~1 MW, 476.3 MHz) providing RF power
- **Four single-cell RF cavities** distributed around the ring
- **High Voltage Power Supply (HVPS)** providing up to ~90 kV to the klystron cathode
- **Low-Level RF (LLRF) control system** for field regulation and feedback
- **Switchgear system** for safe connection/disconnection of 12.47 kV mains power to the HVPS

### 1.2 HVPS Role in the RF Chain

```
12.47 kV Mains → Switchgear → HVPS Transformer/Rectifier → ~90 kV DC → Klystron → ~1 MW RF → 4 Cavities
```

The switchgear system serves as the critical interface between:
- **Utility power**: 12.47 kV three-phase AC from SLAC electrical distribution
- **HVPS input**: Controlled connection to the high-voltage transformer primary
- **Safety systems**: Personnel Protection System (PPS) and machine protection interlocks

### 1.3 Historical Context

The switchgear system was originally designed for the PEP-II B-Factory project (circa 1997) and later adapted for SPEAR3. The circuit schematics analyzed in this documentation set are from the PEP-II era, specifically:

- **Stanford Linear Accelerator Center (SLAC)** engineering drawings
- **Lawrence Berkeley Laboratory** collaboration
- **Ross Engineering Corp.** vacuum contactor driver design
- **Positron-Electron Project II (PEP-II)** accelerator infrastructure

---

## 2. HVPS Switchgear Architecture

### 2.1 System Topology

The switchgear system consists of three main subsystems:

1. **12.47 kV Vacuum Contactor Controller** — Primary switching device
2. **Energy Storage Closing System** — Capacitor-based contactor operation
3. **Protection and Control System** — Overcurrent, undervoltage, and safety interlocks

### 2.2 Power Flow Architecture

```
12.47 kV Incoming Line (3-phase)
    ↓
Current Transformers (CT 50/5 or 200/5)
    ↓
Vacuum Contactor (15 kV, 400A, 3-pole HQ3)
    ↓
Surge Arrestors
    ↓
HVPS Transformer Primary
```

### 2.3 Major Equipment Components

| Component | Specification | Function |
|-----------|---------------|----------|
| **Vacuum Contactor** | 15 kV, 400A, 3-pole HQ3 (Ross Engineering) | Main switching device |
| **Current Transformers** | 50/5 or 200/5 ratio | Protection relay measurement |
| **Energy Storage Capacitors** | 3500mF @ ~350 VDC | Contactor closing energy |
| **Protection Relays** | 50-51 (overcurrent), 27 (undervoltage), BR (blocking) | System protection |
| **Control Power Supply** | 125 VDC, 115 VAC | Control circuit power |
| **Metal Enclosure** | NEMAT rated, 48" × 140" MAX | Outdoor weatherproof housing |

---

## 3. Vacuum Contactor Controller System

### 3.1 Vacuum Contactor Technology

The system uses **vacuum interrupter technology** for 12.47 kV switching:

- **Model**: HQ3 (Ross Engineering)
- **Rating**: 15 kV, 400A, 3-pole
- **Interrupting capability**: Suitable for transformer inrush and fault currents
- **Operating mechanism**: Stored energy closing with toggle mechanism
- **Maintenance**: Vacuum bottles have long service life, minimal maintenance

### 3.2 Stored Energy Closing System

The vacuum contactor uses a **capacitor-based stored energy closing system**:

**Energy Storage Components:**
- **C1**: 3500mF main closing capacitor
- **C7**: 40,000mF filter capacitor (40V rating)
- **Charging circuit**: 10MΩ, 25W charging resistor
- **Voltage monitoring**: 330kΩ/250kΩ voltage divider
- **Discharge protection**: 220Ω, 50W discharge resistor

**Operating Sequence:**
1. **Charging**: Capacitors charge to ~350 VDC through internal HV DC supply
2. **Ready indication**: K2 relay closes when sufficient energy is stored
3. **Close command**: MX relay initiates closing sequence
4. **Current verification**: K3 relay verifies holding coil current
5. **Energy application**: K1 relay connects stored energy to closing coil L2
6. **Mechanical closing**: L2 solenoid actuates toggle mechanism with high force
7. **Holding**: L1 holding coil maintains closed position using DC power

### 3.3 Opening Sequence

**Normal Opening:**
1. MX relay opens (or TX local trip, or interlock activation)
2. L1 holding coil current is interrupted
3. L1 drops out within 1 power cycle
4. Toggle mechanism releases, opening HV contacts
5. Contacts clear in ~1/2 to 1 cycle at first current zero

**Fault Ride-Through (Blocking Relay):**
- **BR blocking relay** activates when fault current exceeds 2000A
- Prevents premature opening during fault conditions
- Contactor holds closed for minimum 170ms even if AC control power is lost
- Opens only after fault current decays below holding level

---

## 4. Energy Storage and Closing System

### 4.1 Power Supply Architecture

**Internal HV DC Power Supply:**
- **Output**: +350 VDC for energy storage
- **Protection**: 6/10A fuse
- **Load resistors**: 50Ω, 100W for controlled charging
- **Connection**: TB1-20 terminal

**Internal LV DC Power Supply:**
- **Output**: 125 VDC for control circuits
- **Protection**: FU-A 30A fuse
- **Connection**: TB3-14 terminal
- **Function**: Powers relay coils, indicators, door interlocks

### 4.2 Energy Storage Calculations

**Stored Energy**: E = ½CV² = ½ × 3500×10⁻⁶ × (350)² ≈ 214 Joules

**Discharge Characteristics:**
- **To 80V**: ~5 minutes (if not automatic discharge)
- **To 40V**: ~10 minutes (if not automatic discharge)
- **Door interlock discharge**: <5 seconds when door opened

### 4.3 Safety Considerations

**Electrical Safety:**
- **Voltage level**: 300-800 VDC stored energy (lethal voltage)
- **Automatic discharge**: Door interlocks discharge capacitors when opened
- **Manual discharge**: External terminals provided for safe discharge
- **Lockout procedures**: AC power must be off before external discharge

**Mechanical Safety:**
- **High closing force**: Toggle mechanism provides high contact pressure
- **Interlock switches**: S1A, S1B verify mechanical position
- **Pressure relief**: Vacuum contactor includes pressure monitoring

---

## 5. Protection and Safety Systems

### 5.1 Overcurrent Protection

**Phase Protection (50-51 A, B, C):**
- **Current transformers**: 200/5 ratio (or 50/5 in some configurations)
- **Relay type**: Type CO-6 or equivalent
- **Settings**: 2-6A with 20-40A instantaneous attachment
- **Test capability**: Current test block for maintenance testing

**Ground/Neutral Protection (50-51N):**
- **Current transformer**: Separate neutral CT
- **Relay type**: Type CO-6 or equivalent  
- **Settings**: 0.5-2.5A with 20-40A instantaneous attachment
- **Function**: Detects ground faults and unbalanced conditions

### 5.2 Undervoltage Protection

**27 Relay (Undervoltage):**
- **Function**: Monitors incoming 12.47 kV line voltage
- **Connection**: AG circuit (TB3-5)
- **Purpose**: Prevents operation during voltage sags or outages
- **Coordination**: Interfaces with Block 1 circuitry

### 5.3 Blocking Relay System

**BR Blocking Relay:**
- **Activation threshold**: >2000A fault current
- **Function**: Prevents contactor opening during high fault currents
- **Hold time**: Minimum 170ms before dropout
- **Purpose**: Allows fault current to decay naturally before interruption
- **Bypass capability**: Overrides MX and TX local off commands during fault

### 5.4 Lockout Relay System

**Motor Contactors (MC3, MC4, MC5, MC7):**
- **Function**: Lockout relay coordination
- **Connections**: TB3-10, TB3-12
- **Purpose**: Prevents automatic reclosing after fault
- **Reset**: Manual reset required after lockout condition

---

## 6. Personnel Protection System (PPS) Interface

### 6.1 PPS Integration Overview

The switchgear system is integrated with SLAC's Personnel Protection System (PPS) for radiation and electrical safety. The PPS interface ensures that:

- **Personnel safety**: No RF power when personnel access is required
- **Equipment protection**: Coordinated shutdown of HVPS and RF systems
- **Fault isolation**: Rapid isolation of faulted equipment
- **Interlock integrity**: Fail-safe operation of all safety systems

### 6.2 PPS Signal Interface

**From PPS to Switchgear:**
- **24 VDC permit signals**: Via optocouplers for electrical isolation
- **Orbit interlock permit**: Prevents operation during beam instability
- **MPS (Machine Protection System) permit**: Overall facility safety coordination

**From Switchgear to PPS:**
- **Status signals**: Contactor position, fault conditions
- **Fiber optic communications**: Electrical isolation for safety-critical signals
- **First-fault indication**: Identifies initiating fault source

### 6.3 Safety Chain Architecture

**Normal Operation Chain:**
1. PPS provides 24 VDC permit
2. Interface Chassis enables LLRF9 and HVPS
3. LLRF9 provides drive signal
4. HVPS provides klystron cathode voltage
5. Klystron produces RF power

**Fault Response Chain:**
1. Fault detected (overcurrent, undervoltage, interlock, etc.)
2. Appropriate protection relay operates
3. Vacuum contactor opens (unless blocked by BR)
4. HVPS input power removed
5. RF power ceases
6. PPS logs fault and prevents restart until cleared

---

## 7. Control and Monitoring Systems

### 7.1 Control System Architecture

**Legacy Control (Current):**
- **PLC**: SLC-500 series
- **HMI**: Legacy operator interface
- **Communication**: Proprietary protocols
- **Integration**: Limited EPICS interface

**Upgraded Control (LLRF Upgrade Project):**
- **PLC**: CompactLogix series
- **HMI**: EPICS-based operator interface
- **Communication**: Ethernet/IP, fiber optic
- **Integration**: Full EPICS integration with LLRF9 system

### 7.2 Terminal Block Architecture

The system uses a comprehensive terminal block system for interconnection:

**TB1 - HCA Driver Box (21 terminals):**
- Control voltage interlock (TB1-1)
- Energy storage circuits (TB1-9, TB1-15)
- Relay control circuits (TB1-10, TB1-11, TB1-12)
- Internal power supplies (TB1-20, TB1-21)

**TB2 - HQ3 Vacuum Contactor (14 terminals):**
- Fast dropout circuit (TB2-1)
- Local controls (TB2-3, TB2-12)
- Position indication (TB2-S2, TB2-S3A, TB2-S3B)
- Voltage sensing (TB2-6)

**TB3 - Switchgear (24 terminals):**
- Protection relay connections (TB3-5 through TB3-24)
- Power supply interfaces (TB3-14, TB3-15)
- External system connections (TB3-9, TB3-10, TB3-22)

**TB4 - Power/CT Terminal Block:**
- Current transformer secondary connections
- Power circuit interfaces

**TBD - RFPS/External Terminal Block (11 terminals):**
- RF power supply transformer connections
- External monitoring and control
- Oil pump transformer (cooling system)

### 7.3 Wire Naming and Documentation

**Wire Identification System:**
- **Numbered wires**: 1-22+ for main control circuits
- **Alpha designations**: CC, BB, EE, RR, SS for circuit functions
- **Terminal cross-reference**: Complete TB1/TB2/TB3/TB4/TBD mapping
- **Circuit tracing**: Full wire-by-wire documentation for maintenance

---

## 8. Physical Installation and Layout

### 8.1 Enclosure Specifications

**NEMAT Rated Enclosure:**
- **Dimensions**: 48" × 140" maximum
- **Configuration**: Door-in-door arrangement
- **Weather protection**: Outdoor rated (W/P = weatherproof)
- **Foundation**: Concrete pad 7' × 15'
- **Access**: Front and rear access panels

**Internal Layout:**
- **Rear compartment**: 12.47 kV incoming connections
- **Front compartment**: Control and protection equipment
- **Swinging panel**: Vacuum contactor driver (maintenance access)
- **Viewing window**: Front panel observation capability

### 8.2 Cable and Conduit Systems

**Incoming Power:**
- **Cable**: #4-15KV rated, 3-conductor
- **Installation**: Underground conduit
- **Termination**: Rear compartment with surge arrestors

**Control Wiring:**
- **Internal**: Terminal block interconnections
- **External**: Conduit to building systems
- **Fiber optic**: PPS and safety system communications
- **Grounding**: Comprehensive equipment grounding system

### 8.3 Environmental Considerations

**Thermal Management:**
- **Space heater**: Prevents condensation in outdoor installation
- **Temperature monitoring**: Cabinet temperature sensor (planned addition)
- **Ventilation**: Natural convection with filtered air intakes

**Moisture Protection:**
- **Gaskets**: All access panels sealed
- **Drainage**: Condensate drainage provisions
- **Humidity control**: Space heater operation during high humidity

---

## 9. Integration with LLRF Upgrade

### 9.1 Upgrade Project Context

The SPEAR3 LLRF Upgrade Project modernizes the entire RF control system, including:

- **LLRF Controller**: Legacy analog → Dimtel LLRF9 (×2 units)
- **HVPS Controller**: SLC-500 PLC → CompactLogix PLC
- **Control Software**: SNL/VxWorks → Python/EPICS
- **Interface Systems**: New Interface Chassis for interlock coordination

### 9.2 Switchgear Role in Upgrade

**Retained Components:**
- **Vacuum contactor**: HQ3 contactor and driver system
- **Protection relays**: 50-51, 27, BR relay systems
- **Energy storage**: Capacitor-based closing system
- **Enclosure**: NEMAT rated switchgear cabinet

**Modified/Upgraded Components:**
- **Control interface**: New fiber optic connections to upgraded HVPS controller
- **Monitoring systems**: Enhanced EPICS integration
- **Safety coordination**: Interface Chassis integration
- **Diagnostics**: Improved fault detection and logging

### 9.3 Interface Chassis Integration

The new **Interface Chassis** serves as the coordination hub between:

**LLRF9 Units (×2):**
- Status monitoring (5 VDC signals)
- Enable control (3.2 VDC @ 8mA permits)
- Fast interlock coordination

**HVPS Controller:**
- SCR ENABLE (fiber optic to HVPS)
- STATUS monitoring (fiber optic from HVPS)
- KLYSTRON CROWBAR (fiber optic, must remain illuminated)

**Switchgear System:**
- Integration with existing protection relays
- Coordination with vacuum contactor control
- First-fault detection and logging

### 9.4 Upgrade Benefits

**Improved Reliability:**
- **Digital control**: Eliminates analog drift and calibration issues
- **Redundant systems**: Dual LLRF9 units with automatic failover
- **Enhanced diagnostics**: 16k-sample waveform capture on faults

**Enhanced Safety:**
- **Fiber optic isolation**: Electrical isolation between systems
- **First-fault detection**: Rapid identification of fault sources
- **Coordinated shutdown**: Proper sequencing of LLRF, HVPS, and switchgear

**Operational Improvements:**
- **EPICS integration**: Standard SLAC control system interface
- **Remote monitoring**: Network-based diagnostics and control
- **Automated procedures**: Reduced operator workload

---

## 10. Technical Specifications Summary

### 10.1 Electrical Specifications

| Parameter | Specification | Notes |
|-----------|---------------|-------|
| **Incoming Voltage** | 12.47 kV, 3-phase | SLAC electrical distribution |
| **Contactor Rating** | 15 kV, 400A, 3-pole | HQ3 vacuum contactor |
| **Current Transformers** | 50/5 or 200/5 ratio | Protection measurement |
| **Control Power** | 125 VDC, 115 VAC | Internal power supplies |
| **Energy Storage** | 3500mF @ 350 VDC | Closing capacitor |
| **Interrupting Capability** | Per IEEE standards | Vacuum interrupter technology |

### 10.2 Protection System Specifications

| Function | Device | Setting | Purpose |
|----------|--------|---------|---------|
| **Phase Overcurrent** | 50-51 A,B,C | 2-6A, 20-40A inst. | Phase fault protection |
| **Ground Overcurrent** | 50-51N | 0.5-2.5A, 20-40A inst. | Ground fault protection |
| **Undervoltage** | 27 | Per system voltage | Voltage monitoring |
| **Blocking Relay** | BR | >2000A activation | Fault ride-through |
| **Fast Dropout** | Circuit | 6A-600V rated | Rapid de-energization |

### 10.3 Physical Specifications

| Parameter | Specification | Notes |
|-----------|---------------|-------|
| **Enclosure** | NEMAT 48" × 140" | Outdoor weatherproof |
| **Foundation** | 7' × 15' concrete pad | Structural support |
| **Cable** | #4-15KV, 3-conductor | Underground installation |
| **Access** | Door-in-door arrangement | Maintenance accessibility |
| **Environmental** | Outdoor rated | Temperature/humidity protection |

---

## 11. Document Cross-Reference

### 11.1 Circuit Schematic Technical Notes

Located in this directory (`hvps/documentation/switchgear/technical_notes/`):

| Document | Content | Key Information |
|----------|---------|-----------------|
| `TN_DOC041421_RossEngr713203_SystemSchematic.md` | Ross Engineering energy storage system | HCA-1-A panel, capacitor charging, safety interlocks |
| `TN_gp3085000103_SwitchgearSchematicAndArrangement.md` | 12.47 kV switchgear overview | Physical arrangement, protection relays, CT connections |
| `TN_gp4397040201_VacContSchematicDiagram.md` | Detailed electrical schematic | Complete circuit logic, 9-step operation sequence |
| `TN_id3088010601_ConnectionWiringDiagram.md` | Physical wiring connections | Terminal blocks, wire routing, cabinet layout |

### 11.2 System Design Documents

Located in `Designs/` directory:

| Document | Content | Relevance |
|----------|---------|-----------|
| `4_HVPS_Engineering_Technical_Note.md` | Complete HVPS system reference | Power supply specifications, control systems |
| `8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` | PPS integration details | Safety systems, interlock coordination |
| `3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` | LLRF upgrade system | Integration with switchgear systems |

### 11.3 Legacy Documentation

Located in `pps/` directory:

| Document | Content | Historical Context |
|----------|---------|-------------------|
| `gp4397040201.pdf` | Original schematic PDF | Source document for detailed analysis |
| `rossEngr713203.pdf` | Ross Engineering drawing | Energy storage system design |
| Various PPS diagrams | Protection system details | Safety system integration |

### 11.4 Maintenance and Operations

Located in `hvps/maintenance/` and related directories:

- Maintenance procedures and schedules
- Spare parts specifications
- Troubleshooting guides
- Operational procedures

---

## Conclusion

The SPEAR3 HVPS switchgear system is a sophisticated, safety-critical component of the accelerator's RF power system. Its vacuum contactor technology, stored energy closing system, and comprehensive protection schemes ensure reliable and safe operation of the 12.47 kV to HVPS interface.

The system's integration with the LLRF Upgrade Project demonstrates the careful balance between modernizing control systems while retaining proven, reliable power switching technology. The comprehensive documentation in this directory provides the technical foundation for continued operation, maintenance, and future enhancements of this critical system.

**Key Success Factors:**
- **Proven technology**: Vacuum interrupter reliability
- **Comprehensive protection**: Multiple layers of fault protection
- **Safety integration**: Proper PPS interface design
- **Maintainability**: Accessible design with complete documentation
- **Upgrade compatibility**: Seamless integration with modern control systems

This overview serves as the entry point for understanding the complete switchgear system, with detailed technical information available in the referenced circuit schematic technical notes and system design documents.
