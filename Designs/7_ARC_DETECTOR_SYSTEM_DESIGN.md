# SPEAR3 Arc Detector System Design Report

**Document ID**: SPEAR3-LLRF-DR-007
**Title**: Optical Arc Detection System --- Microstep-MIS Waveguide Arc Detectors for RF Cavity and Klystron Protection
**Author**: LLRF Upgrade Team
**Date**: March 2026
**Version**: 1.0
**Status**: Design Phase --- Procurement Pending

**Reference Documents**:
| Document | Location | Content |
|----------|----------|---------|
| System Overview | `Designs/1_Overview of Current and Upgrade System.md` | Arc detection in upgrade scope (Section 2.1, 4.x) |
| HVPS Technical Note | `Designs/4_HVPS_Engineering_Technical_Note.md` | Arc detection interface specifications |
| Interface Chassis Design | `Designs/11_INTERFACE_CHASSIS_DESIGN.md` | Arc detection input integration |
| MPS Design | `Designs/10_MACHINE_PROTECTION_SYSTEM_DESIGN.md` | Arc interlock in MPS logic |
| LLRF Upgrade Task List | `Docs_JS/LLRFUpgradeTaskListRev3.docx` | Budget (~$20k) and procurement status |
| Microstep-MIS Product Sheet | `llrf/arcDetector/microStepMISarcDetector.pdf` | Manufacturer specifications |
| Waveguide Arc Detector Sheet | `llrf/arcDetector/Waveguide Arc Detector_product sheet.pdf` | Product specifications |
| Arc Detector Conference Paper | `llrf/arcDetector/tups072.pdf` | Technical reference paper |
| Mechanical Reference Photos | `llrf/arcDetector/Mechanical/Reference/` | Viewport and flange photos |
| Cavity Viewport Drawings | `llrf/arcDetector/Mechanical/Reference/PF-*.PDF.URL` | Viewport mechanical drawings |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Background and Motivation](#2-background-and-motivation)
3. [Arc Detection Physics and Requirements](#3-arc-detection-physics-and-requirements)
4. [Microstep-MIS Technology Overview](#4-microstep-mis-technology-overview)
5. [Sensor Placement and Coverage](#5-sensor-placement-and-coverage)
6. [Mechanical Integration](#6-mechanical-integration)
7. [Signal Interface and Electrical Design](#7-signal-interface-and-electrical-design)
8. [Integration with Interface Chassis](#8-integration-with-interface-chassis)
9. [Integration with Machine Protection System](#9-integration-with-machine-protection-system)
10. [EPICS Integration and Diagnostics](#10-epics-integration-and-diagnostics)
11. [Interlock Chain and Fault Response](#11-interlock-chain-and-fault-response)
12. [Procurement and Budget](#12-procurement-and-budget)
13. [Installation Plan](#13-installation-plan)
14. [Commissioning and Testing](#14-commissioning-and-testing)
15. [Implementation Status and Next Steps](#15-implementation-status-and-next-steps)

---

## 1. Executive Summary

The Arc Detector System is a new safety subsystem in the SPEAR3 LLRF upgrade that provides optical detection of electrical arcs in the RF waveguide network and cavity windows. It replaces a non-functional legacy arc detection system with modern **Microstep-MIS optical waveguide arc detectors** --- proven commercial devices used at multiple accelerator facilities worldwide.

Arcs in RF cavities and waveguides produce intense optical radiation that can be detected through viewports. Undetected arcs can damage cavity windows, waveguide components, and the klystron output window. The Arc Detector System provides fast detection (microsecond-scale) and feeds hardware interlock signals into the Interface Chassis, which removes RF drive and HVPS power to protect the RF system.

**Key Features**:
- Microstep-MIS optical arc detectors with fiber-optic light collection
- Coverage of all 4 RF cavity windows and the klystron output window
- Dry contact or permit signal output for each detector
- Integration with Interface Chassis via optocoupler-isolated inputs
- Hardware-speed interlock chain (no software in the safety path)
- Estimated total cost: ~$20,000

---

## 2. Background and Motivation

### 2.1 Legacy System

The legacy SPEAR3 RF system includes an arc detection capability that is documented as **non-functional**. The original system design included arc detection provisions, but the hardware was never fully commissioned or has degraded to the point of being unreliable. This represents a gap in the machine protection that the upgrade addresses.

### 2.2 Arc Hazards

Electrical arcs in the RF system can occur at several locations:

| Location | Cause | Consequence |
|----------|-------|-------------|
| **Cavity windows** | Contamination, multipacting, vacuum excursion | Window cracking/failure, vacuum breach |
| **Waveguide junctions** | Poor contact, contamination, condensation | Waveguide damage, power loss |
| **Klystron output window** | High power density, contamination | Klystron window failure (catastrophic) |
| **RF couplers** | Excessive reflected power, standing waves | Coupler damage |

### 2.3 Upgrade Rationale

The LLRF upgrade provides the opportunity to install a modern, reliable arc detection system that:
- Uses proven commercial technology (Microstep-MIS)
- Integrates seamlessly with the new Interface Chassis interlock architecture
- Provides fast hardware-level protection
- Includes diagnostic capabilities for arc event logging and analysis

---

## 3. Arc Detection Physics and Requirements

### 3.1 Arc Characteristics

RF arcs in accelerator systems have the following characteristics:

| Parameter | Typical Value | Notes |
|-----------|---------------|-------|
| **Arc duration** | Microseconds to milliseconds | Self-extinguishing if RF removed quickly |
| **Optical emission** | Broadband, UV through visible | High intensity relative to background |
| **Recurrence** | May repeat within milliseconds | Multiple arcs possible in single event |
| **RF reflected power** | Spike coincident with arc | Detectable by LLRF9 interlocks |

### 3.2 Detection Requirements

| Requirement | Value | Rationale |
|-------------|-------|-----------|
| **Detection latency** | < 10 microseconds | Must trip before arc damages components |
| **Sensitivity** | Detect arcs at minimum operating power | Low-power arcs still damage windows |
| **False positive rate** | < 1 per month | Spurious trips reduce accelerator availability |
| **Coverage** | All cavity windows + klystron output | All vulnerable optical viewports |
| **Output** | Hardware interlock signal | No software in the safety path |
| **Reset** | Manual or automatic (configurable) | Per system protection policy |

---

## 4. Microstep-MIS Technology Overview

### 4.1 Operating Principle

The Microstep-MIS Waveguide Arc Detector is an optical detection system that uses fiber-optic cables to collect light from RF waveguide viewports. The detector electronics evaluate the optical signal for characteristics consistent with an electrical arc (intensity, rise time, duration) and output a permit/trip signal.

### 4.2 Key Specifications (from manufacturer documentation)

| Parameter | Value |
|-----------|-------|
| **Detection method** | Optical (fiber-optic light collection) |
| **Spectral range** | UV through visible |
| **Response time** | < 5 microseconds (typical) |
| **Fiber optic input** | Standard SMA or ST connector |
| **Output signal** | Dry contact relay (NO/NC selectable) and/or TTL |
| **Power supply** | 24 VDC or 230 VAC (model dependent) |
| **Sensitivity adjustment** | Adjustable threshold (potentiometer or digital) |
| **Diagnostics** | LED status indicators, test/simulation input |
| **Mounting** | DIN rail or panel mount |
| **Operating temperature** | 0 to 50 degrees C |

### 4.3 Proven Track Record

Microstep-MIS arc detectors are used at multiple accelerator facilities worldwide for RF system protection. The technology is well-established for detecting arcs in:
- RF cavity windows
- Waveguide components
- Klystron output windows
- Power coupler assemblies

---

## 5. Sensor Placement and Coverage

### 5.1 Sensor Locations

| Sensor ID | Location | Purpose |
|-----------|----------|---------|
| ARC-1 | Cavity 1 window viewport | Detect arcs in Cavity 1 |
| ARC-2 | Cavity 2 window viewport | Detect arcs in Cavity 2 |
| ARC-3 | Cavity 3 window viewport | Detect arcs in Cavity 3 |
| ARC-4 | Cavity 4 window viewport | Detect arcs in Cavity 4 |
| ARC-5 | Klystron output window | Detect arcs at klystron output |

### 5.2 Coverage Analysis

The 5 sensor locations cover all critical optical viewpoints in the RF system:

- **4 cavity windows**: Each single-cell cavity has a viewport through which the fiber-optic cable can collect light. Arcs at the cavity windows are the most common and most damaging arc events in storage ring RF systems.
- **Klystron output window**: The klystron output window is a critical component. An arc at this location can cause catastrophic klystron failure.
- **Waveguide network**: While the waveguide components between the klystron and cavities do not all have viewports, arcs in the waveguide network typically produce reflected power spikes that are detected by the LLRF9 interlocks on Unit 2 (reflected power monitoring).

---

## 6. Mechanical Integration

### 6.1 Viewport Specifications

The fiber-optic cables couple to existing or new viewports on the cavity and klystron windows. Key mechanical considerations:

| Component | Specification | Notes |
|-----------|---------------|-------|
| **Viewport flange** | Mini-CF (1.33" / DN16) | Standard UHV-compatible flange |
| **Viewport lens** | UV-grade fused silica, 0.75" diameter | Transmits UV for arc detection |
| **Vacuum seal** | Copper gasket (CF standard) | UHV-compatible |
| **Fiber coupling** | SMA fiber connector to viewport adapter | Custom adapter may be needed |

### 6.2 Reference Drawings

Mechanical reference documents in `llrf/arcDetector/Mechanical/Reference/`:
- `PF-341-320-02_00.PDF` through `PF-341-320-06_00.PDF`: Cavity viewport port drawings
- `SA-341-342-48_01.PDF`, `SA-341-342-65_02.PDF`: Assembly drawings
- `SA-341-320-05_00.PDF`: Related drawing
- Mini-CF flange specifications (1.33" x 0.75", DN16, 304SS)
- UV-grade fused silica viewport specifications (MDC Precision 9722013)

### 6.3 Fiber-Optic Cable Routing

- **Cable type**: Multi-mode fiber-optic cable with SMA connectors
- **Length**: Varies by sensor location (typically 5--20 meters from viewport to detector electronics)
- **Routing**: Through existing cable trays and conduits in the accelerator tunnel and equipment areas
- **Protection**: Fiber cables routed in protective conduit where exposed to mechanical hazard

---

## 7. Signal Interface and Electrical Design

### 7.1 Detector Output Signals

Each Microstep-MIS detector unit provides:

| Output | Type | Description |
|--------|------|-------------|
| **Permit relay** | Dry contact (NO or NC, selectable) | Main interlock output |
| **TTL output** | 0/5V logic | Fast digital output for monitoring |
| **LED indicators** | Visual | Power, fault, arc detected status |
| **Test input** | Logic or optical | Simulates arc for system testing |

### 7.2 Interlock Wiring

The primary interlock path uses the **dry contact relay output** from each detector:

```
Microstep-MIS Detector (per sensor)
    |
    +-- Dry Contact Relay (NC = Permit)
    |       |
    |       +-- Wire pair to Interface Chassis
    |           (optocoupler-isolated input)
    |
    +-- TTL Output (optional monitoring)
            |
            +-- To MPS PLC digital input (for diagnostics)
```

**Fail-safe design**: Using NC (Normally Closed) contacts for the permit relay ensures that:
- A powered, healthy detector with no arc: contacts closed = permit granted
- A powered detector detecting an arc: contacts open = permit removed
- A de-powered detector: contacts open = permit removed (fail-safe)
- A broken wire: circuit open = permit removed (fail-safe)

### 7.3 Power Distribution

- Each detector requires 24 VDC power supply
- Centralized 24 VDC power supply in the detector electronics enclosure
- Power supply monitoring: loss of 24 VDC causes all permits to drop (fail-safe)

---

## 8. Integration with Interface Chassis

### 8.1 Signal Path

The Arc Detector System interfaces with the Interface Chassis through dedicated, optocoupler-isolated inputs:

| Signal | Source | Destination | Type | Isolation |
|--------|--------|-------------|------|-----------|
| Arc Interlock Permit(s) | Microstep-MIS detectors | Interface Chassis | Dry contacts or permit signal | Optocoupler (ACSL-6xx0 family) |

### 8.2 Input Configuration Options

Two configuration options exist for connecting multiple arc detectors to the Interface Chassis:

**Option A --- Individual inputs**: Each detector has its own Interface Chassis input, providing per-sensor first-fault identification.

**Option B --- Series-wired permits**: All detector permits wired in series to a single Interface Chassis input. Simpler wiring but cannot identify which sensor tripped (first-fault information lost).

**Recommended**: Option A (individual inputs) is preferred for diagnostics, with the understanding that additional Interface Chassis input channels may be needed. If input channels are limited, detectors can be grouped (e.g., cavities 1-2 on one input, cavities 3-4 on another, klystron on a third).

### 8.3 Interface Chassis Response

When an Arc Interlock Permit is removed:

1. Interface Chassis latches the fault in the first-fault register
2. LLRF9 Enable is removed (LLRF9 zeros drive, opens RF switch)
3. HVPS SCR ENABLE is removed (HVPS thyristors stop firing)
4. Status is reported to MPS PLC via digital status lines
5. Fault remains latched until MPS Reset is received

---

## 9. Integration with Machine Protection System

### 9.1 MPS Interface

The MPS receives arc detection status through two paths:

| Path | Signal | Purpose |
|------|--------|---------|
| **Primary (hardware)** | Via Interface Chassis status lines | Fast interlock chain |
| **Secondary (diagnostics)** | TTL outputs direct to MPS PLC digital inputs | Per-sensor status for logging |

### 9.2 MPS Logic

In the MPS PLC logic:
- Arc detection is one of several interlock sources contributing to the MPS Summary Permit
- The MPS logs arc events with timestamps for post-event analysis
- Arc faults may be configured for auto-reset or manual-reset depending on system protection policy
- The MPS can differentiate between single-arc events (possibly auto-resettable) and repeated arcs (requiring manual investigation)

---

## 10. EPICS Integration and Diagnostics

### 10.1 Process Variable Database

**Per-sensor PVs (n = 1--5)**:
```
SRF1:ARC:DET{n}:STATUS           # Detector status (OK/TRIPPED/FAULT)
SRF1:ARC:DET{n}:PERMIT           # Permit state (1=granted, 0=removed)
SRF1:ARC:DET{n}:COUNT            # Cumulative arc count
SRF1:ARC:DET{n}:LAST_TIME        # Timestamp of last arc event
SRF1:ARC:DET{n}:LAST_DURATION    # Duration of last arc event (if available)
SRF1:ARC:DET{n}:SENSITIVITY      # Sensitivity setting readback
```

**System-level PVs**:
```
SRF1:ARC:SYSTEM:STATUS            # Overall arc detection system status
SRF1:ARC:SYSTEM:PERMIT            # Combined arc permit (AND of all sensors)
SRF1:ARC:SYSTEM:TOTAL_COUNT       # Total arc count across all sensors
SRF1:ARC:SYSTEM:LAST_FAULT        # Identity of last sensor to trip
SRF1:ARC:SYSTEM:RESET             # Reset arc detection system
SRF1:ARC:SYSTEM:TEST              # Initiate system self-test
```

### 10.2 Diagnostic Capabilities

- **Arc event logging**: Each arc event is logged with timestamp, sensor ID, and duration
- **Trend analysis**: Arc count trends over time can indicate developing problems
- **System self-test**: The test input on each detector can be triggered via EPICS to verify the complete interlock chain
- **Sensitivity monitoring**: Sensitivity settings are readable and archivable for drift detection

---

## 11. Interlock Chain and Fault Response

### 11.1 Complete Interlock Chain

```
Arc Event (optical)
    |
    v
Fiber-Optic Cable
    |
    v
Microstep-MIS Detector (< 5 us detection)
    |
    v
Dry Contact Relay Opens (permit removed)
    |
    v
Interface Chassis Optocoupler Input (< 1 us processing)
    |
    +---> LLRF9 Enable Removed ---> LLRF9 zeros drive, opens RF switch
    |
    +---> HVPS SCR ENABLE Removed ---> HVPS thyristors stop firing
    |
    +---> First-Fault Register Latched
    |
    +---> Status to MPS PLC
```

**Total response time**: < 10 microseconds from arc onset to LLRF9 drive removal

### 11.2 Recovery Sequence

After an arc event:

1. Arc extinguishes (RF power removed)
2. Operator or automatic system assesses the arc event
3. If single isolated arc: MPS Reset clears the Interface Chassis latch
4. Interface Chassis restores LLRF9 Enable and HVPS SCR ENABLE
5. Station state machine can re-initiate ON_CW sequence
6. If repeated arcs: manual investigation required (possible contamination, vacuum issue, or component damage)

---

## 12. Procurement and Budget

### 12.1 Cost Estimate

| Item | Quantity | Unit Cost | Total |
|------|----------|-----------|-------|
| Microstep-MIS Arc Detector units | 5 | ~$3,000 | ~$15,000 |
| Fiber-optic cables (with connectors) | 5 | ~$200 | ~$1,000 |
| UV-grade fused silica viewports | As needed | ~$500 | ~$2,000 |
| Viewport adapters and hardware | 5 | ~$100 | ~$500 |
| Wiring, connectors, enclosure | 1 lot | ~$500 | ~$500 |
| Spare detector unit | 1 | ~$3,000 | ~$3,000 |
| **Total** | | | **~$22,000** |

> **Note**: The LLRF Upgrade Task List Rev 3 estimates ~$20,000 for arc detection. The above estimate includes a spare unit for a more conservative total of ~$22,000.

### 12.2 Procurement Status

| Item | Status |
|------|--------|
| Microstep-MIS detectors | Not ordered |
| Fiber-optic cables | Not ordered |
| Viewports | Need to verify existing viewport compatibility |
| Mounting hardware | Not designed |

---

## 13. Installation Plan

### 13.1 Pre-Installation

1. **Verify existing viewports**: Inspect all 4 cavity viewports and klystron output viewport for compatibility with fiber-optic coupling
2. **Design fiber-optic adapters**: Custom adapters may be needed to couple SMA fiber connectors to viewport flanges
3. **Plan cable routing**: Route fiber-optic cables from tunnel viewports to detector electronics location
4. **Prepare electronics enclosure**: DIN-rail mounted detector units with 24 VDC power supply

### 13.2 Installation Sequence

1. Install viewport adapters on cavity and klystron windows (during maintenance shutdown)
2. Route fiber-optic cables from viewports to electronics location
3. Mount detector electronics in designated enclosure
4. Wire detector outputs to Interface Chassis inputs
5. Wire TTL diagnostic outputs to MPS PLC (optional path)
6. Connect 24 VDC power supply
7. Verify all connections before powering on

### 13.3 Installation Constraints

- Cavity viewport access requires tunnel access during maintenance shutdown
- Klystron area access requires coordination with radiation safety
- Fiber-optic cables must not be bent below minimum bend radius
- All tunnel installations must comply with SLAC ES&H requirements

---

## 14. Commissioning and Testing

### 14.1 Bench Testing

1. **Individual detector test**: Verify each Microstep-MIS unit responds to optical stimulus
2. **Sensitivity calibration**: Set detection threshold appropriate for each installation location
3. **Response time verification**: Confirm < 10 microsecond detection latency
4. **Relay output verification**: Confirm dry contact operation (NO/NC) and contact ratings

### 14.2 System Integration Testing

1. **Interface Chassis integration**: Verify arc detection permit signal reaches Interface Chassis
2. **Interlock chain verification**: Confirm that simulated arc trips LLRF9 Enable and HVPS SCR ENABLE
3. **First-fault capture**: Verify Interface Chassis correctly identifies arc detector as first fault
4. **MPS integration**: Verify MPS receives and logs arc detection status
5. **EPICS PV verification**: Confirm all arc detection PVs update correctly

### 14.3 Operational Testing

1. **False positive baseline**: Run system for extended period at full RF power to establish false positive rate
2. **Sensitivity optimization**: Adjust thresholds to minimize false positives while maintaining detection capability
3. **Self-test procedure**: Verify the built-in test function works through the complete interlock chain
4. **Recovery sequence validation**: Verify the system correctly recovers after a trip event

---

## 15. Implementation Status and Next Steps

### 15.1 Current Status

| Item | Status |
|------|--------|
| System specification | Conceptual design complete |
| Detector selection | Microstep-MIS selected (pending procurement) |
| Mechanical design | Viewport compatibility assessment needed |
| Procurement | Not started (~$20k budget identified) |
| Installation design | Cable routing to be determined |
| Interface design | Defined in Interface Chassis specification |
| EPICS integration | Not started |

### 15.2 Next Steps

1. **Procure Microstep-MIS detector units** (5 operational + 1 spare)
2. **Inspect existing viewports** on all cavities and klystron output
3. **Design and procure fiber-optic adapters** for viewport coupling
4. **Design cable routing** from tunnel to electronics location
5. **Bench test** all detector units before installation
6. **Install during maintenance shutdown** (coordinate with operations)
7. **Commission** with Interface Chassis and MPS integration
8. **Optimize sensitivity** settings during RF operation

### 15.3 Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Viewport incompatibility | Medium | Medium | Early inspection; custom adapters if needed |
| False positive rate too high | Medium | Medium | Adjustable sensitivity; extended baseline testing |
| Fiber-optic damage during installation | Low | Medium | Careful routing; protective conduit |
| Ambient light interference | Low | Low | Fiber coupling design excludes ambient light |
| Detector unit failure | Low | Low | Spare unit on hand for quick replacement |
| Installation window too short | Medium | Medium | Pre-fabricate all adapters and cables; minimize tunnel time |

---

*End of Document*