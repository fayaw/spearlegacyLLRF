# SPEAR3 RF System — Legacy System Architecture

**Document ID**: Doc L  
**Version**: 2.0  
**Date**: March 24, 2026  
**Status**: DRAFT — For Engineering Review  
**Location**: Designs/L_LEGACY_SYSTEM_ARCHITECTURE.md  
**Author**: Faya Wang, with AI-assisted analysis  
**Tier**: 2 — Legacy System and Operational Reference

---

## Revision History

| Version | Date | Description |
|---------|------|-------------|
| 2.0 | 2026-03-24 | Major revision: adopted Doc P numbered reference system [Rn]; added internet research citations (SLAC publications, PEP-II conference papers, OSTI records); restructured all inline Source/See-also blocks into numbered references; added Appendix B (Source Document Reference Index) with 5 categories; added Appendix C (Symbol and Notation Conventions); fixed TOC anchor formatting |
| 1.0 | 2026-03-24 | Initial draft, assembled from exhaustive review of all original source documents and AI-generated technical notes |

---

## Table of Contents

#### Part I — System Overview
1. [Introduction and Purpose](#1-introduction-and-purpose)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [Physical Layout and Locations](#3-physical-layout-and-locations)
4. [Key System Parameters](#4-key-system-parameters)

#### Part II — RF Signal Chain
5. [LLRF Controller (VXI System)](#5-llrf-controller-vxi-system)
6. [Klystron and Drive System](#6-klystron-and-drive-system)
7. [Waveguide Distribution Network](#7-waveguide-distribution-network)
8. [RF Cavities and Tuner Assemblies](#8-rf-cavities-and-tuner-assemblies)

#### Part III — Power Systems
9. [High-Voltage Power Supply — Power Section](#9-high-voltage-power-supply--power-section)
10. [HVPS Control System — Hoffman Box (B118)](#10-hvps-control-system--hoffman-box-b118)
11. [Enerpro SCR Firing System](#11-enerpro-scr-firing-system)
12. [Arc Protection and Crowbar System](#12-arc-protection-and-crowbar-system)

#### Part IV — Protection and Safety Systems
13. [Personnel Protection System (PPS) Interface](#13-personnel-protection-system-pps-interface)
14. [RF Machine Protection System (MPS)](#14-rf-machine-protection-system-mps)
15. [Interlock Architecture and Signal Chain](#15-interlock-architecture-and-signal-chain)

#### Part V — Control Software and Instrumentation
16. [EPICS IOC and SNL Software Architecture](#16-epics-ioc-and-snl-software-architecture)
17. [Tuner Control System](#17-tuner-control-system)
18. [Diagnostics, Calibration and Monitoring](#18-diagnostics-calibration-and-monitoring)

#### Part VI — Integration and Legacy Considerations
19. [Cabling and Interconnections](#19-cabling-and-interconnections)
20. [Known Issues, Limitations and Legacy Debt](#20-known-issues-limitations-and-legacy-debt)

#### Appendices
- [Appendix A — Source Document Reference Index](#appendix-a--source-document-reference-index)
- [Appendix B — Symbol and Notation Conventions](#appendix-b--symbol-and-notation-conventions)

---

## Document Scope and Provenance

### Purpose

This document is the **Tier 2 legacy system reference** for the SPEAR3 RF system. It describes the complete RF system **as currently installed and operating** — the "legacy" configuration prior to the LLRF Upgrade Project. It covers every major subsystem from design concepts through real-world implementation: physical hardware, control electronics, software, protection systems, cabling, calibration data, and known limitations.

Doc L serves three critical functions:
1. **Upgrade baseline** — Provides the complete "as-built" reference against which upgrade designs (U1–U10) are specified
2. **Knowledge preservation** — Captures institutional knowledge about a system designed in 1997 (PEP-II era) before key personnel retire and obsolete hardware is removed
3. **Operational reference** — Consolidates scattered documentation into a single navigable resource

### Provenance Statement

All technical content in this document is derived from **original source documents** as defined in the Documentation Architecture Proposal (v6.0, §2.1). These include:
- Original engineering schematics, wiring diagrams, and drawings (PDFs from SLAC/PEP-II project)
- Human-authored design notes and operational procedures (docx files by J. Sebek, R. Cassel, et al.)
- Measurement and calibration data (xlsx files from actual hardware)
- The complete legacy source code (2,293 files in `spear-rf-code-legacy/`)
- Published SLAC technical papers and conference proceedings
- Vendor documentation (Enerpro, Galil, Superior Electric, Ross Engineering)

Where AI-generated technical notes from the repository have been consulted during preparation, they are cited parenthetically as *"preliminary analysis (AI-generated, see [filename], unreviewed)"* per the provenance rules in the Documentation Architecture Proposal §2.4.

External references obtained through web research are cited with full bibliographic information in Appendix A.

### Relationship to Other Documents

| Document | Relationship |
|----------|-------------|
| Doc 0 (System Design Report) | Doc 0 describes the *upgrade* architecture. Doc L describes the *legacy* system that Doc 0's upgrade replaces |
| Doc P (RF Physics and Plant) | Doc P covers physics and control theory independent of hardware. Doc L covers the specific hardware implementation |
| Doc D (Operational Data Catalog) | Doc D will contain measured data and calibrations. Doc L explains the system that produced that data |
| U1–U10 (Upgrade Documents) | Each U-document references the relevant Doc L sections for the legacy baseline of its subsystem |

### What This Document Contains

- Physical hardware descriptions with part numbers, serial numbers, and specifications
- Control system architecture and PLC configurations
- Software architecture for 6 SNL programs (7,112 lines total)
- Protection and safety system signal chains
- Complete cabling and interconnection references
- Known issues and legacy debt catalog

### What This Document Does NOT Contain

- RF physics or control theory derivations (see Doc P)
- Upgrade design specifications (see U1–U10)
- Measured calibration data tables (see Doc D)
- Source code listings (see `spear-rf-code-legacy/`)

### Reference Tag Format

- **[Rn]** — Numbered references to original source documents, published papers, and repository files
- **[Rnt]** — Transcription of the corresponding [Rn] source
- **[Wn]** — External web references with URLs

All references are cataloged in [Appendix A](#appendix-a--source-document-reference-index).

## Figures and Photo Placeholders

This document includes placeholders for photographs and figures of the actual legacy system hardware. These placeholders describe the exact shot needed and are formatted as:

> 📷 **[PHOTO PLACEHOLDER]**: *Description of the photograph needed*

These should be populated with actual photographs taken during the documentation process, before legacy hardware is removed.

---

# PART I — SYSTEM OVERVIEW

---

## 1. Introduction and Purpose

### 1.1 PEP-II Heritage

The SPEAR3 RF system is a direct adaptation of a PEP-II B-Factory High Energy Ring (HER) RF station. PEP-II was an asymmetric electron-positron collider at SLAC that operated from 1999 to 2008 with up to 10 RF stations. When SPEAR was upgraded to SPEAR3 (a 3rd-generation synchrotron light source) in 2003, a complete PEP-II HER station — klystron, four RF cavities, HVPS, waveguide distribution, and LLRF electronics — was installed as the SPEAR3 RF system [R1] [R2] [R3].

---

## 2. System Architecture Overview

### 2.1 Top-Level System Block Diagram

The legacy SPEAR3 RF system consists of the following major elements:

```
                         ┌─────────────────────────────────────────────────┐
                         │              EPICS CONTROL LAYER                │
                         │   VXI IOC (VxWorks) + 6 SNL Programs           │
                         │   EDM Operator Panels | EPICS Archiver         │
                         └──────────┬─────────────┬──────────┬────────────┘
                                    │ Channel     │          │
                                    │ Access      │          │
                    ┌───────────────┼─────────────┼──────────┼──────────────────┐
                    │               │             │          │                  │
               ┌────┴────┐   ┌─────┴─────┐  ┌───┴────┐  ┌──┴──────┐   ┌──────┴──────┐
               │ VXI     │   │AB DCM     │  │AB PLC-5│  │AB SLC   │   │ Stepper     │
               │ Crate   │   │Serial     │  │(MPS)   │  │500(HVPS)│   │ 1746-HSTP1  │
               │ B132    │   │Link       │  │B132    │  │B118     │   │ (4×cav)     │
               └────┬────┘   └─────┬─────┘  └───┬────┘  └──┬──────┘   └──────┬──────┘
                    │               │             │          │                  │
        ┌───────────┤        ┌──────┘             │     ┌────┘                 │
        │           │        │                    │     │                      │
   ┌────┴─────┐ ┌───┴───┐   │              ┌─────┴──┐  │              ┌───────┴──────┐
   │  RFP     │ │ IQA   │   │              │Interlock│  │              │ SLO-SYN     │
   │  Module  │ │×3     │   │              │Chassis  │  │              │ Stepper     │
   │ (RF      │ │(meas.)│   │              │(Fast IC)│  │              │ Motors ×4   │
   │ Feedback)│ │       │   │              └────┬────┘  │              │ (tunnel)    │
   └────┬─────┘ └───┬───┘   │                  │       │              └─────────────┘
        │           │        │                  │       │
   ┌────┴───────────┴────────┴──────────────────┤       │
   │              RF SIGNAL PATH                │       │
   │  Drive Amp → Klystron → Circulator →       │       │
   │  Magic-Tees → 4 Cavities (tunnel)         │       │
   └────────────────────────────────────────────┘       │
                                                        │
                    ┌───────────────────────────────────┘
                    │
   ┌────────────────┴───────────────────────────────────┐
   │              HVPS POWER SECTION (B514)              │
   │  12.47kV → Switchgear → Phase-Shift Transformer →  │
   │  12-Pulse Thyristor Bridges → Filter → Crowbar →   │
   │  Cable Termination → Klystron Cathode (−77kV)      │
   └─────────────────────────────────────────────────────┘
```

> 📷 **[PHOTO PLACEHOLDER]**: *Overall SPEAR3 RF system — composite image showing B132 control electronics, B514 HVPS power section, and tunnel cavity installations, with arrows indicating signal/power flow between locations*

### 2.2 Subsystem Summary

| Subsystem | Location | Primary Hardware | Legacy Control | Function |
|-----------|----------|-----------------|----------------|----------|
| LLRF Controller | B132 | VXI crate (RFP, IQA×3, CLK, AIM) | SNL/EPICS on VxWorks | RF feedback and station control |
| HVPS Power Section | B514 | Transformer, thyristor bridges, crowbar | — (power electronics) | −77 kV DC to klystron cathode |
| HVPS Controller | B118 | SLC-500 PLC, analog regulator, Enerpro boards | PLC ladder logic + SNL | Voltage regulation and sequencing |
| RF MPS | B132 | PLC-5 → ControlLogix 1756 | PLC ladder logic | Equipment protection |
| PPS Interface | B118/Switchgear | Hoffman box, relay chain, Ross switch | Hardwired + PLC | Personnel safety |
| Tuner Motors | Tunnel | SLO-SYN M093-FC11 × 4 | AB 1746-HSTP1 via SNL | Cavity frequency tuning |
| Interlock System | B132 | Fast Interlock Chassis, Local Control Chassis | Analog + PLC | Fault detection and trip chains |
| Klystron + Drive | B132 | SLAC klystron, KAW2051M12 drive amp | VXI (RF output) | RF power amplification |
| Waveguide + Cavities | B132/Tunnel | WR-1800 waveguide, 4 PEP-II cavities | — (passive) | RF power distribution and acceleration |

> **Sources**: [R5] §2.1; [R9]; [R10], [R11]; preliminary analysis (AI-generated, see `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md`, unreviewed).


---

## 3. Physical Layout and Locations

The SPEAR3 RF station is distributed across multiple buildings at SSRL. Understanding the physical geography is essential for understanding cable runs, signal latency, and maintenance access.

| Location | Equipment | Distance from B132 |
|----------|-----------|-------------------|
| **Building B132** (Klystron Gallery) | Klystron, drive amplifier, VXI crate (LLRF controller), RF MPS PLC, Fast Interlock Chassis, Local Control Chassis, stepper motor controllers | — (primary location) |
| **Building B118** (Power Supply Room) | HVPS Controller (Hoffman NEMA enclosure), SLC-500 PLC, Enerpro firing boards, analog regulator card, monitoring oscilloscope | ~100 m cable run to B514 |
| **Building B514** (HVPS Substation) | HVPS Main Tank (transformer, rectifier, inductor, filter caps), Phase Tank (12 thyristor stacks), Crowbar Tank (4 thyristor stacks, output voltage divider) | Adjacent to switchgear |
| **Contactor Disconnect Panel** (Switchgear) | Vacuum contactor (Ross HQ3), contactor controller (Ross HCA-1-A), K4/MX/RR/L1 relays, S5 auxiliary contact | Adjacent to B514 |
| **Termination Tank** (near B132) | HV cable termination, Ross Engineering HV grounding switch, Danfysik DC-CT, Pearson CT-110 current transformer | Near klystron |
| **Switch-over Tank** | HV cable connections between SPEAR1/SPEAR2 HVPS and klystron | Adjacent to B514 |
| **SPEAR3 Storage Ring Tunnel** | 4 RF cavities, waveguide distribution network (circulator, magic-tees, waveguide loads), tuner motor assemblies, arc detection sensor mounting points | Radiation area, restricted access |

> 📷 **[PHOTO PLACEHOLDER]**: *Site map or aerial view of SSRL showing B118, B132, B514, switchgear location, and tunnel access points with cable routing indicated*

> 📷 **[PHOTO PLACEHOLDER]**: *Building B132 exterior — klystron gallery where main LLRF control electronics are housed*

> 📷 **[PHOTO PLACEHOLDER]**: *Building B118 interior — HVPS controller Hoffman enclosure (front view, showing PLC, terminal strips, power supplies)*

> 📷 **[PHOTO PLACEHOLDER]**: *Building B514 exterior and interior — HVPS main tank, phase tank, and crowbar tank in the high-voltage substation*

> 📷 **[PHOTO PLACEHOLDER]**: *Switchgear/contactor disconnect panel showing vacuum contactor, Ross HCA-1-A controller, and relay panel*

> 📷 **[PHOTO PLACEHOLDER]**: *Termination tank showing Ross grounding switch, Danfysik DC-CT, and Pearson CT-110 installation*

> 📷 **[PHOTO PLACEHOLDER]**: *SPEAR3 tunnel showing RF cavity installations with waveguide connections and tuner assemblies visible*

> **Sources**: [R5] §3; [R25]; [R14]; preliminary analysis (AI-generated, see `pps/diagrams/00_SYSTEM_OVERVIEW.md`, unreviewed).


---

## 4. Key System Parameters

### 4.1 RF System Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| RF Frequency | 476.315 MHz | Harmonic 372 of revolution frequency |
| Revolution Frequency | 1.2808 MHz | Circumference = 234.137 m |
| Beam Energy | 3.0 GeV | |
| Design Beam Current | 500 mA | Top-off mode |
| Fill Pattern | 276 bunches in 4 groups + 1 camshaft | |
| Number of Cavities | 4 | Single-cell, HOM-damped copper (PEP-II type) |
| Cavity Shunt Impedance (R_s) | 3.9 MΩ | Per cavity |
| Cavity Unloaded Q (Q_0) | 33,500 | |
| Cavity Loaded Q (Q_L) | 6,700 | β = 4.0 (coupling factor) |
| Gap Voltage per Cavity | ~712 kV | Operating point (design: 800 kV) |
| Total Accelerating Voltage | ~2.85 MV | Sum of 4 cavities |
| Klystron Output Power | ~800 kW | Operating (rated: ~1.5 MW) |
| Drive Power | ~29 W | At klystron input |
| IF Frequency | 4.9 MHz | 476 − 471.1 MHz LO |
| LO Frequency | 471.1 MHz | Distributed from CLK module |

### 4.2 HVPS Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| Input Power | 12.47 kV RMS, 3-phase, 60 Hz | Substation 507, Breaker 160 |
| Output Voltage (rated) | −90 kV DC max | Negative polarity for klystron cathode |
| Output Voltage (operating) | ~−74.7 kV | At 500 mA beam current |
| Output Current (operating) | ~19.4 A | Measured June 2020 |
| Power (operating) | ~1.4 MW | |
| Topology | 12-pulse thyristor phase-controlled rectifier | Star point controller configuration |
| Voltage Regulation | ±0.5% | At voltages >65 kV |
| Ripple | <1% peak-to-peak, <0.2% RMS | |
| Configuration | 2-unit (SPEAR1 active, SPEAR2 warm spare) | |

### 4.3 Measured Operating Point (June 2020)

| Parameter | Measured | Calculated | Error |
|-----------|----------|-----------|-------|
| Output Voltage | 72.08 kV | 72.08 kV (input) | — |
| Output Current | 19.4 A | 19.2 A (from perveance) | 1.0% |
| Power | 1.398 MW | 1.384 MW | 1.0% |
| Firing Angle | SIG HI = 4.40 V | α ≈ 36.8° | Consistent |
| Voltage Sense | 7.183 V | 7.19 V (÷10,035) | 0.1% |


---

# PART II — RF SIGNAL CHAIN

---

## 5. LLRF Controller (VXI System)

### 5.1 Overview

The LLRF controller is a VXI-based system located in Building B132 that provides the fast RF feedback, station state management, and measurement functions for the RF station. It was designed for PEP-II by P. Corredoura, S. Allison, R. Sass, R. Tighe, and R. Claus at SLAC (1996–1997).

The VXI crate hosts a Kinetics Systems IOC running VxWorks RTOS, which serves as the primary intelligence for the entire RF system. All communication with external PLCs (HVPS, MPS, stepper motors) passes through the VXI crate via an Allen-Bradley DCM serial communication module.

> 📷 **[PHOTO PLACEHOLDER]**: *VXI crate front panel in B132, showing all installed modules with labels identifying each slot*

> 📷 **[PHOTO PLACEHOLDER]**: *VXI crate rear panel showing RF signal cabling, control cables, and fiber optic connections*

### 5.2 VXI Module Inventory

| Slot | Module | Function | SPEAR3 Status |
|------|--------|----------|---------------|
| 0 | Slot 0 μProcessor | VXI bus controller, EPICS IOC host (VxWorks RTOS) | **Active** |
| 1 | CLK/RF Distribution | Master clock, LO generation (471.1 MHz), RF reference distribution | **Active** |
| 2 | RFP (RF Processor) | Central feedback processing — IQ demod, vector sum, direct loop, baseband modulator | **Active** |
| 3 | IQA-1 | Digital IQ demodulator + amplitude detector | **Active** |
| 4 | IQA-2 | Digital IQ demodulator + amplitude detector | **Active** |
| 5 | IQA-3 | Digital IQ demodulator + amplitude detector | **Active** |
| 6 | Comb Filter (I) | Digital comb filter for I-channel | ⚠️ **PEP-II only — NOT used in SPEAR3** |
| 7 | Comb Filter (Q) | Digital comb filter for Q-channel | ⚠️ **PEP-II only — NOT used in SPEAR3** |
| 8 | GVF (Gap Voltage Feed-Forward) | Gap voltage reference + LFB interface | ⚠️ **PEP-II only — NOT used in SPEAR3** |
| 9 | ARC/Interlock Module (AIM) | Arc detection, interlock management, fault history | **Active (limited function)** |

> **Sources**: [R7] (RF System Description); [R10], [R11] (block diagrams); [R2] Fig. 1 (VXI crate topology); preliminary analysis (AI-generated, see `llrf/documentation/legacyArchitecture/technical-notes/02_VXI_HARDWARE_MODULE_REFERENCE.md`, unreviewed).


### 5.3 RFP (RF Processor) Module — Heart of the LLRF

The RFP module is the central signal processing module in the VXI crate. It performs:

**Analog Signal Processing**:
- IQ demodulation of 4 cavity probe signals (476 MHz → 4.9 MHz IF → baseband I/Q)
- Vector summing of 4 cavity I/Q signals
- Direct loop error amplifier comparing vector sum against IQ reference
- Lead and integral compensation networks for loop stability
- Baseband modulator (4 × Gilbert-cell multipliers in 2×2 matrix for I→I, I→Q, Q→I, Q→Q correction)
- IQ RF modulator (baseband → 476 MHz upconversion for klystron drive)

**Digital Control Interface**:
- Octal DACs (12-bit, ±2048 counts) for: tune mode IQ setpoints, operate mode IQ offsets, klystron modulator matrix coefficients, ripple loop coefficients
- Mode control: TUNE / OPERATE switching
- RF switch: enable/disable RF output to klystron
- Built-in history buffer (circular buffer, freeze on fault for post-mortem analysis)

**Key PVs** (from `rf_dac_loop_pvs.h`):
```
{STN}:RFP:TUNESTPT:I     — Tune mode I setpoint
{STN}:RFP:TUNESTPT:Q     — Tune mode Q setpoint
{STN}:RFP:DIFFNODE:I     — Operate mode I offset
{STN}:RFP:DIFFNODE:Q     — Operate mode Q offset
{STN}:RFP:RFSWITCH        — RF output enable/disable
{STN}:RFP:RUNMODE         — TUNE/OPERATE mode select
{STN}:RFP:DIRECTLOOP      — Direct loop enable/disable
```

> 📷 **[PHOTO PLACEHOLDER]**: *RFP module front panel showing RF connectors, status LEDs, and labeling*

> 📷 **[PHOTO PLACEHOLDER]**: *RFP module internal board (if accessible) showing analog signal processing components*

> **Sources**: [R7]; [R16]; preliminary analysis (AI-generated, see `llrf/documentation/legacyArchitecture/technical-notes/02_VXI_HARDWARE_MODULE_REFERENCE.md` §2.1, unreviewed).


### 5.4 IQA (IQ/Amplitude Detector) Modules

Three IQA modules provide precision digital measurement of RF signals. Each module performs digital IQ demodulation using a custom SLAC ASIC, producing:
- I component (in-phase), Q component (quadrature)
- Amplitude = √(I² + Q²)
- Phase = arctan(Q/I)

**Channel allocation** (typical SPEAR3/HER configuration):
- IQA-1: Klystron drive power monitoring
- IQA-2: Cavity probe signals (multiplexed or summed)
- IQA-3: Additional monitor points (configurable via `rf_states.st`)

> **Sources**: [R3] (IQA module description); Ziomek, C. and Corredoura, P., "Digital I/Q Demodulator," PAC 1995 [R41].

> 📷 **[PHOTO PLACEHOLDER]**: *IQA module front panel with RF input connectors*


### 5.5 ARC/Interlock Module (AIM)

The AIM module provides the interface between the VXI crate and the external interlock system:

- Beam abort force/reset interface
- Filament control signals
- HVPS permissive signals
- Fault history buffers (11 channels written to `/dat/FAULT*_` files on fault)
- Station fault word monitoring

**Fault file capture** (from `rf_states.st`, M. Laznovsky addition, 2003):
On entering a fault state, 11 signal channels (RfpSI, RfpSQ, RfpCI, RfpCQ, Cf2I, Cf2Q, Iqa1Amp, Iqa2Amp, Iqa3Amp, Gvf, Aim) are dumped to disk as `/dat/FAULT<channel>_<n>` in a circular buffer of fault files.

> **Sources**: [R16] (fault file handling code); [R20] (AIM status monitoring).


### 5.6 Feedback Loop Architecture

The legacy LLRF system implements multiple feedback loops, some inherited from PEP-II and some SPEAR3-specific:

**Active in SPEAR3**:
1. **Direct (Wideband) RF Feedback Loop** — Reduces effective cavity impedance by ~40 dB (factor of 100), suppressing Robinson instability. Analog feedback at baseband. Bandwidth: ~800 kHz. Critical for beam stability.
2. **Tuner Loop** — EPICS-based slow loop controlling stepper motors to maintain cavity resonant frequency. Implemented in `rf_tuner_loop.st`.
3. **HVPS Voltage Regulation Loop** — Regulates klystron cathode voltage via PLC-controlled SCR firing angle. Implemented across `rf_hvps_loop.st` (SNL) and PLC ladder logic.
4. **DAC Control Loop** — Manages drive power and gap voltage setpoints through RFP octal DACs. Implemented in `rf_dac_loop.st`.

**NOT active in SPEAR3** (PEP-II only, hardware present but unused):
- Comb (Narrowband) RF Feedback Loop — for multi-bunch stabilization at revolution harmonics
- Gap Voltage Feed-Forward (GVF) — PEP-II cavity field stabilization with LFB interface
- Ripple Feedback Loop — LLRF9 digital feedback inherently rejects this

> **Sources**: [R2] (complete loop architecture); [R8] (feedback loop description); [R42] Fox et al. operational review; preliminary analysis (AI-generated, see `llrf/documentation/legacyArchitecture/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md`, unreviewed).


### 5.7 Communication Architecture

The VXI crate communicates with all external controllers via a single Allen-Bradley DCM (Direct Communication Module) serial link:

```
VXI IOC (VxWorks)
    │
    ├── AB DCM Serial Link ──→ SLC-500 PLC (HVPS, B118)
    │                      ──→ PLC-5/ControlLogix (RF MPS, B132)
    │                      ──→ 1746-HSTP1 × 4 (Stepper motors)
    │
    ├── RF Signals ──→ RFP module (476 MHz drive output)
    │             ←── Cavity probes × 4 (476 MHz)
    │
    └── Interlocks ──→ AIM module ←── Fast Interlock Chassis
```

The serial link provides ~1 Hz supervisory communication (setpoints, readbacks, status). Fast feedback (the direct RF loop) operates entirely within the RFP module at analog speeds.

> **Sources**: [R5] §2.1; [R20].


---

## 6. Klystron and Drive System

### 6.1 Klystron

The SPEAR3 klystron is a SLAC-designed 476 MHz CW klystron located in Building B132. It is a single-beam tube with a non-full-power collector, meaning collector power must be actively managed to avoid thermal damage.

| Parameter | Value |
|-----------|-------|
| Frequency | 476.315 MHz |
| Rated Output Power | ~1.5 MW |
| Operating Output Power | ~800 kW |
| Cathode Voltage | −74.7 kV (operating) to −90 kV (max) |
| Cathode Current | ~19.4 A (at 72 kV) |
| Drive Power | ~29 W |
| Gain | ~44.4 dB |
| Collector type | Non-full-power (requires collector power protection) |

**Collector Power Protection**: Because the klystron has a non-full-power collector, the collector dissipation (cathode power minus RF output power) must be monitored. In the legacy system, this is implemented through:
1. Software monitoring in `rf_hvps_loop.st` comparing `klystron_forward_power` vs `max_klystron_forward_power`
2. MPS hardware limit using an RF detector module in the Fast Interlock Chassis that couples klystron forward power
3. The AB controller monitors HVPS V and I and computes collector power, removing the MPS permit if limits are exceeded

> 📷 **[PHOTO PLACEHOLDER]**: *SPEAR3 klystron in B132 — full view showing input waveguide, output waveguide, collector cooling, and solenoid magnets*

> 📷 **[PHOTO PLACEHOLDER]**: *Klystron collector region showing cooling water connections and temperature monitoring*

> 📷 **[PHOTO PLACEHOLDER]**: *Klystron input section showing drive amplifier connection and input waveguide coupling*

> **Sources**: [R5] §4.1, §4.5; [R17]; [R43] (klystron prototype); [R44] (1.2 MW production klystron).


### 6.2 Drive Amplifier

The drive amplifier boosts the LLRF output signal from ~0 dBm to ~29 W (14.6 dBm → 44.6 dBm) to drive the klystron input. The amplifier is a KAW2051M12 unit.

> 📷 **[PHOTO PLACEHOLDER]**: *Drive amplifier (KAW2051M12) in B132 rack, showing RF input/output connections*

> **Sources**: [R32] (drive amplifier datasheet); [R5] §4.4.


---

## 7. Waveguide Distribution Network

### 7.1 Network Topology

The klystron output feeds a waveguide network that distributes RF power equally to 4 cavities:

```
Klystron Output
    │
    ▼
[CIRCULATOR] ──→ Circulator Load (absorbs reflected power)
    │
    ▼
[MAGIC-TEE 1] ──→ (P4) WG Load 1
    │         │
    ▼         ▼
[MAGIC-TEE 2]  [MAGIC-TEE 3]
    │    │         │    │
    ▼    ▼         ▼    ▼
 Cav A  Cav B   Cav C  Cav D
    │    │         │    │
   (P4)  (P4)     (P4)  (P4)
  WG Load 2      WG Load 3
```

Each magic-tee splits power equally between two outputs (P2 and P3 ports). The P4 port (difference port) receives the sum of equal reflected power from the two cavities and directs it to a waveguide load.

### 7.2 Monitored RF Signals

The system monitors 24 RF signals at various points in the waveguide network. Key signals include:
- Klystron forward and reflected power (signals 1, 2)
- Each cavity's forward power, reflected power, and probe signal (signals 9–14, 17–22)
- Waveguide load powers (signals 7–8, 15–16, 23–24)
- Station reference and klystron drive (signals 5, 6)

> 📷 **[PHOTO PLACEHOLDER]**: *Waveguide network in B132 showing circulator, magic-tee splitters, and waveguide runs toward tunnel*

> 📷 **[PHOTO PLACEHOLDER]**: *Directional coupler installation on waveguide showing RF signal tap points*

> 📷 **[PHOTO PLACEHOLDER]**: *Waveguide loads (circulatory load and magic-tee difference port loads)*

> **Sources**: [R5] §4.2, §4.6 (complete 24-signal table); [R33].


---

## 8. RF Cavities and Tuner Assemblies

### 8.1 Cavity Specifications

Four single-cell, HOM-damped copper cavities (PEP-II type) are installed in the SPEAR3 storage ring tunnel. Each cavity provides:
- Accelerating gap voltage: ~712 kV (operating)
- Resonant frequency: 476.315 MHz (tuner-adjustable)
- 3 HOM (Higher-Order Mode) loads per cavity for beam stability
- Ceramic window for RF power transmission
- Internal probe for field amplitude and phase monitoring

Each cavity has waveguide window viewports on either side of the ceramic window, providing mounting points for arc detection sensors.

> 📷 **[PHOTO PLACEHOLDER]**: *Single RF cavity installation in SPEAR3 tunnel — side view showing waveguide connection, HOM dampers, tuner plunger, and vacuum gauges*

> 📷 **[PHOTO PLACEHOLDER]**: *Cavity tuner assembly close-up showing stepper motor, mechanical linkage, linear potentiometer (position readback), and plunger mechanism*

> 📷 **[PHOTO PLACEHOLDER]**: *Ceramic window on cavity showing arc detection sensor mounting points*

> 📷 **[PHOTO PLACEHOLDER]**: *All four cavities in the tunnel with waveguide distribution visible*

### 8.2 Tuner Mechanical Assembly

Each cavity has an individual stepper motor tuner that adjusts the cavity resonant frequency by varying the insertion depth of a mechanical plunger:

| Component | Specification |
|-----------|--------------|
| Motor | Superior Electric SLO-SYN M093-FC11 (NEMA 34D) |
| Motor Driver (legacy) | Superior Electric SLO-SYN SS2000MD4-M PWM translators (obsolete) |
| Motor Controller (legacy) | Allen-Bradley 1746-HSTP1 stepper modules |
| Motor Controller (current) | Galil DMC-4143 Rev 1.3h 4-axis controller (commissioned Aug 2025) |
| Position Feedback | Linear potentiometer on each tuner |
| Tuning Range | Adjustable to compensate for beam loading detuning |


---

# PART III — POWER SYSTEMS

---

## 9. High-Voltage Power Supply — Power Section

### 9.1 Architecture Overview

The HVPS is a 12-pulse thyristor phase-controlled rectifier based on the PEP-II design (SLAC, 1997). It delivers negative-polarity DC high voltage to the klystron cathode. The power section is located in Building B514; the control system is in Building B118.

Two complete HVPS units exist: **SPEAR1** (active) and **SPEAR2** (warm spare). They connect to the klystron through a switch-over tank that allows rapid changeover if the primary unit fails.

### 9.2 Power Conversion Chain

```
Substation 507, Breaker 160 (12.47 kV RMS 3φ 60 Hz)
    │
    ▼
┌─────────────────────┐
│ SWITCHGEAR          │  Disconnect switch, 3×50A fuses, vacuum contactor
│ (Contactor Panel)   │  Ross HQ3 contactor + HCA-1-A controller
└─────────┬───────────┘
          │
┌─────────▼───────────┐
│ PHASE-SHIFT XFMR T0 │  3.5 MVA, oil-immersed
│ Extended Delta       │  Primary: 12.47 kV delta
│                      │  Secondary: Dual wye ±15° phase shift
└─────┬─────────┬──────┘
      │         │
┌─────▼────┐ ┌──▼────────┐
│ T1 (+15°)│ │ T2 (−15°) │  Rectifier transformers, 1.5 MVA each
│ Open wye │ │ Open wye  │  Secondary: dual wye, center-tapped
└─────┬────┘ └──┬────────┘
      │         │
┌─────▼─────────▼────────┐
│ 12-PULSE SCR BRIDGES   │  12 stacks × 14 Powerex T8K7 SCRs each
│ Star point controller  │  Phase angle control: 0°–180°
│ Enerpro FCOG1200       │  Firing board generates 12 gate pulses
└─────────┬──────────────┘
          │
┌─────────▼──────────────┐
│ FILTER INDUCTORS       │  L1, L2: 0.3H, 85A rated, air core
│ (Primary side)         │  1,084 J stored energy each
└─────────┬──────────────┘
          │
┌─────────▼──────────────┐
│ SECONDARY RECTIFIERS   │  4 diode bridges in series (D1-D24)
│ + FILTER               │  Main: 30 kV, 30 A; Filter: 30 kV, 3 A
│                        │  Cap bank: 8 μF; Isolation resistors: 500Ω
│                        │  Voltage divider: 1000:1
└─────────┬──────────────┘
          │
┌─────────▼──────────────┐
│ CROWBAR PROTECTION     │  4 SCR stacks in series (SCR13-16)
│                        │  100 kV, 80 A each
│                        │  Fiber-optic trigger (~1 μs response)
└─────────┬──────────────┘
          │
┌─────────▼──────────────┐
│ CABLE TERM. INDUCTORS  │  L3, L4: 200 μH
│ (Layer 4 protection)   │  Limits cable discharge current to klystron
└─────────┬──────────────┘
          │
          ▼
   −77 kV DC @ 22 A → Klystron Cathode
```

> 📷 **[PHOTO PLACEHOLDER]**: *HVPS Main Tank in B514 — exterior view showing oil-filled tank with transformer assembly, access hatches, and cooling system connections*

> 📷 **[PHOTO PLACEHOLDER]**: *Phase Tank interior (if accessible during maintenance) showing 12 thyristor stack assemblies with SCR gate driver connections*

> 📷 **[PHOTO PLACEHOLDER]**: *Crowbar Tank showing 4 SCR stacks with fiber optic trigger connections and dV/dt snubber networks*

> 📷 **[PHOTO PLACEHOLDER]**: *Filter inductors L1 and L2 — air-core inductors with temperature monitoring sensors visible*

> 📷 **[PHOTO PLACEHOLDER]**: *Switch-over tank showing HV cable connections between SPEAR1 and SPEAR2 units*

### 9.3 Key Component Specifications

| Component | Specification | Drawing Reference |
|-----------|--------------|-------------------|
| Phase-shift transformer T0 | 3.5 MVA, 12.47 kV delta / dual wye ±15° | `sd7307900101.pdf` |
| Rectifier transformers T1, T2 | 1.5 MVA each, open wye / dual wye CT | `sd7307900101.pdf` |
| SCR stacks (phase control) | 12 × Powerex T8K7 (8 kV, 700 A), 14/stack | `sd7307930304.pdf`, `sd7307930402.pdf` |
| Filter inductors L1, L2 | 0.3 H, 85 A, air core | `sd7307930702.pdf` |
| Secondary rectifiers D1-D24 | 4 bridges in series, 30 kV, 30 A | `sd7307930801.pdf` |
| Filter capacitors | 8 μF total, ~24 kJ at full voltage | `sd7307931203.pdf` |
| Crowbar SCRs (SCR13-16) | 4 stacks in series, 100 kV, 80 A each | `sd7307931301.pdf` |
| Cable termination inductors L3, L4 | 200 μH | `sd7307940400.pdf` |
| Voltage divider | 1000:1 ratio | `sd2372301200.pdf` |
| Regulator card | PC-237-230 (SD-237-230-14-C1) | `sd2372301401.pdf` |

> **Sources**: All schematic PDFs in `hvps/documentation/schematics/` [R9]; [R6] (PEP-II HVPS architecture); [R22] (power supply specification); preliminary analysis (AI-generated, see `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md` and `hvps/documentation/schematics/technical_notes/`, unreviewed).


### 9.4 Monitoring Signals (B514 → B118)

Four analog monitoring signals are sent from the HVPS power section to the B118 control room:

| Signal | Purpose |
|--------|---------|
| HVPS Output Voltage | DC voltage monitoring via 1000:1 divider |
| HVPS Output Current | DC current monitoring via Danfysik DC-CT |
| Inductor 2 Voltage | T2 firing circuit timing verification |
| Transformer 1 Phase Current | T1 firing circuit health monitoring |

> **Sources**: [R23]; [R9].


---

## 10. HVPS Control System — Hoffman Box (B118)

### 10.1 Overview

The HVPS control system is housed in a Hoffman NEMA enclosure (the "Hoffman Box") located in Building B118. It contains the PLC, analog regulation electronics, Enerpro SCR firing boards, power supplies, terminal strips, and fiber optic interfaces.

> 📷 **[PHOTO PLACEHOLDER]**: *Hoffman Box front door open — overview showing PLC rack, Enerpro boards, power supplies, and terminal strip rows (TS-1 through TS-6)*

> 📷 **[PHOTO PLACEHOLDER]**: *Hoffman Box rear/side view showing cable entry points and fiber optic connections*

### 10.2 SLC-500 PLC Hardware Configuration

| Slot | Module | Function |
|------|--------|----------|
| 0 | SLC-500 CPU (AB-1747-L532) | Main processor |
| 1 | 1747-DCM (DCM-FULL) | Direct Communication Module — VXI/EPICS interface |
| 2 | 1746-IO8 | 8-point digital I/O (12 kV, 240V power, grounding switch relay) |
| 3 | Thermocouple Module | 8-channel temperature sensing (4 channels actively scaled) |
| 4 | (empty) | Unused slot |
| 5 | 1746-OX8 | 8-point relay output (SCR enable, contactor, crowbar, fast inhibit) |
| 6 | 1746-IB16 | 16-point 24V DC digital input (fiber optic signals, oil levels, PPS) |
| 7 | 1746-IV16 | 16-point 24V DC digital input (contactor status, transformer interlocks) |
| 8 | AB-1746-NIO4V | 4-channel analog I/O (voltage reference output, phase angle readback) |
| 9 | AB-1746-NI4 | 4-channel analog input (AC current, voltage monitors, DC current) |
| 10 | Input module | Additional inputs (12 channels) |
| 11 | Input module | Additional inputs |
| 13 | Output module | Additional outputs (4 channels) |

> 📷 **[PHOTO PLACEHOLDER]**: *SLC-500 PLC rack inside Hoffman Box — close-up showing all modules with slot labels*

> 📷 **[PHOTO PLACEHOLDER]**: *Terminal strips TS-3 (PPS LEDs), TS-5 (contactor controls), and TS-6 (grounding tank) inside Hoffman Box*

### 10.3 Control Functions

The PLC implements the following control functions in ladder logic:

1. **Power-up/power-down sequencing** — Orderly startup of contactors, SCR drives, and HVPS output
2. **Voltage reference generation** — Converts EPICS setpoint (via VXI → DCM) to analog reference for the Enerpro firing board
3. **Phase angle calculation** — Computes approximate SIG HI value for feedforward to Enerpro board
4. **Safety interlock monitoring** — Monitors oil levels, temperatures, PPS status, fiber optic signals
5. **Crowbar management** — Arms/disarms crowbar protection, handles crowbar events
6. **Communication** — Exchanges 8×16-bit input and output words with VXI crate via DCM

**Key PLC Registers**:
| Register | Purpose |
|----------|---------|
| N7:10 | Voltage reference output (to analog regulator) |
| N7:11 | Phase angle / SIG HI feedforward |
| N7:100–N7:107 | Thermocouple raw readings |
| N7:110–N7:113 | Scaled temperature values |
| I:1/O:1 | DCM communication words (VXI interface) |

> **Sources**: [R26] (PLC ladder logic); [R27] (PLC symbol database); [R37]; [R38]; [R39]; preliminary analysis (AI-generated, see `hvps/documentation/plc/technical-notes/`, unreviewed).


### 10.4 Analog Regulation

The voltage regulation loop is split between the PLC (digital setpoint, sequencing) and an analog regulator card:

```
EPICS Setpoint → VXI/DCM → PLC (N7:10) → DAC → Analog Regulator → Enerpro SIG HI → SCR Firing Angle
                                                        ▲
                                          HVPS Voltage ─┘ (1000:1 divider feedback)
```

The analog regulator card (PC-237-230, drawing SD-237-230-14-C1) compares the voltage reference with the HVPS output voltage feedback (from the 1000:1 divider) and generates the SIG HI control signal for the Enerpro firing board.

> 📷 **[PHOTO PLACEHOLDER]**: *Analog regulator card (PC-237-230) inside Hoffman Box — showing input/output connections and adjustment potentiometers*

> **Sources**: [R12] (regulator card schematic); [R13] (voltage divider schematic); preliminary analysis (AI-generated, see `hvps/architecture/technical-notes/04-regulator-board-design.md`, unreviewed).


### 10.5 Terminal Strips and External Connections

The Hoffman Box connects to external equipment via 6 terminal strips:

| Terminal Strip | Connection | Cable Type |
|---------------|-----------|-----------|
| TS-3 | PPS status LEDs | Internal |
| TS-5 | Contactor controls (B118 → Switchgear) | Belden 83715 (15C #16 Teflon) |
| TS-6 | Grounding tank (B118 → Termination Tank) | Belden 83709 (9C #16 Teflon) + Belden 83715 |

> **Sources**: [R25]; [R15]; preliminary analysis (AI-generated, see `pps/diagrams/04_wd7307900206_hoffman_box_wiring.md`, unreviewed).


---

## 11. Enerpro SCR Firing System

### 11.1 Overview

The Enerpro FCOG1200 (or FCOG6100) is a 12-pulse SCR gate driver board that generates precisely timed gate pulses for the 12 thyristor stacks. It receives a control voltage (SIG HI) from the analog regulator and converts it to a firing angle, synchronized to the AC line frequency via phase reference signals from the transformer monitor windings.

### 11.2 Current Hardware

| Board | Model | Revision | Serial Numbers |
|-------|-------|----------|----------------|
| Main firing boards | Enerpro FCOG6100 | Rev. K | 41506, 50470, 30045 |
| Auxiliary firing boards | Enerpro FCOAUX60 | Rev D | 03198, 03813, 1694 |

### 11.3 Phase Reference Adapter

A custom Phase Reference Adapter board interfaces between the transformer monitor windings and the Enerpro board's J7 phase reference input. It uses 3×2MΩ resistors to scale the high-voltage phase reference signals down to the Enerpro input requirements.

> 📷 **[PHOTO PLACEHOLDER]**: *Enerpro FCOG6100 firing board installed in Hoffman Box — front view showing SIG HI input, gate pulse outputs, and status indicators*

> 📷 **[PHOTO PLACEHOLDER]**: *Phase Reference Adapter board showing 3×2MΩ resistor dividers and J7 connector*

> 📷 **[PHOTO PLACEHOLDER]**: *SCR gate pulse cable connections from Enerpro board to phase tank thyristor stacks (12 pairs)*

> **Sources**: [R28] (12 Enerpro PDFs); [R40]; preliminary analysis (AI-generated, see `hvps/controls/enerpro/technical-notes/`, unreviewed).


---

## 12. Arc Protection and Crowbar System

### 12.1 Four-Layer Protection Architecture

The HVPS implements a 4-layer arc protection system to protect the klystron from destructive energy discharge during arcs:

| Layer | Protection | Response Time | Mechanism |
|-------|-----------|---------------|-----------|
| 1 | SCR firing inhibit | <1 μs | Fiber-optic SCR ENABLE signal removed; thyristors stop conducting at next AC zero-crossing |
| 2 | Crowbar firing | <1 μs | Fiber-optic CROWBAR signal fires 4 series-connected crowbar SCRs, shorting the HVPS output |
| 3 | Filter capacitor isolation | Passive | 500Ω isolation resistors (PEP-II innovation) limit capacitor discharge current during arc |
| 4 | Cable termination inductors | Passive | L3, L4 (200 μH) limit rate of current rise from cable discharge into klystron |

The first two layers are actively controlled: the Interface Chassis (or in legacy, the VXI AIM module and PLC) can assert SCR ENABLE removal and CROWBAR firing via fiber optic signals. Layers 3 and 4 are passive protection inherent in the circuit design.

> 📷 **[PHOTO PLACEHOLDER]**: *Fiber optic cables connecting B118 Hoffman Box to B514 HVPS — showing SCR ENABLE, CROWBAR, and STATUS fibers*

> 📷 **[PHOTO PLACEHOLDER]**: *500Ω isolation resistors on the secondary rectifier/filter capacitor assembly in the main tank*

> **Sources**: [R6] (PEP-II HVPS architecture — describes 4-layer protection philosophy); HVPS schematics [R9].


---

# PART IV — PROTECTION AND SAFETY SYSTEMS

---

## 13. Personnel Protection System (PPS) Interface

### 13.1 Overview

The PPS interface controls two critical safety functions: the HV vacuum contactor (which connects 12.47 kV AC power to the HVPS) and the Ross grounding switch (which grounds the HVPS output for safe access).

**⚠️ KEY COMPLIANCE ISSUE**: In the legacy system, both PPS chains pass through the SLC-500 PLC inside the Hoffman Box. This places a programmable logic controller in the personnel safety chain — a design that does not meet modern PPS standards.

### 13.2 Legacy PPS Chain 1: HV Contactor

```
PPS 1 Enable (GOB12-88PNE Pin E→F)
    → SLC-500 PLC Slot-6 IB16 Input 14
    → PLC Rung 0017 (Contactor Enable logic)
    → Slot-5 OX8 OUT2
    → TS-5 → Belden 83715 cable → Switchgear
    → K4 Relay (PPS Control) → MX Relay → L1 Holding Coil → Contactor energized

Readback: S5 auxiliary contact (NC) → TS-5 pins 14,15 → GOB12-88PNE Readback A-B
```

### 13.3 Legacy PPS Chain 2: Ross Grounding Switch

```
PPS 2 Enable (GOB12-88PNE Pin G→H)
    → SLC-500 PLC Slot-6 IB16 Input 15
    → PLC Rung 0016 (Ross switch enable)
    → Slot-2 IO8 OUT3 (120 VAC)
    → TS-6 → Belden 83709 cable → Termination Tank
    → Ross Grounding Switch coil

Readback: Ross Switch NC Aux → TS-6 pins 11,12 → GOB12-88PNE Readback C-D
```

### 13.4 Identified Issues

| Issue | Severity | Details |
|-------|----------|---------|
| PLC in PPS chain | Critical | Both PPS chains route through SLC-500 PLC ladder logic |
| PPS wiring exposed | High | PPS wires terminate on TS-5 and TS-6 inside the HVPS controller enclosure |
| Ross switch PLC dependency | High | Ross switch controlled by PLC 120 VAC output (Slot-2), not direct PPS |
| K4/RR relay label swap | Medium | Drawing labels K4 and RR relay functions incorrectly (corrected in AI analysis) |
| Hardware obsolescence | High | SLC-500 and 1746 modules are end-of-life |

### 13.5 Relay Chain Details (Contactor Disconnect Panel)

| Component | Function | Type |
|-----------|----------|------|
| K4 | PPS Control Relay — energized only when PPS enable present | Relay |
| MX | External Control — provides operational enable from non-PPS sources | Relay |
| RR | Reset — latching reset relay for post-trip recovery | Relay |
| L1 | Holding Coil — maintains vacuum contactor energized | Coil |
| S5 | Auxiliary Contact — provides PPS readback (NC contact) | Contact |
| Vacuum Contactor | Ross Eng. Model HQ3 — connects 12.47 kV AC to HVPS | HV contactor |
| Controller | Ross Eng. HCA-1-A — contactor controller logic | Controller |

> 📷 **[PHOTO PLACEHOLDER]**: *Contactor disconnect panel interior showing K4, MX, RR relays, L1 holding coil, and S5 auxiliary contact wiring*

> 📷 **[PHOTO PLACEHOLDER]**: *Ross HQ3 vacuum contactor and HCA-1-A controller in switchgear enclosure*

> 📷 **[PHOTO PLACEHOLDER]**: *Ross grounding switch in termination tank with Danfysik DC-CT and Pearson CT-110*

> 📷 **[PHOTO PLACEHOLDER]**: *PPS GOB12-88PNE connector showing pin assignments for Enable and Readback signals*

> **Sources**: [R25] (detailed wiring); [R14]; [R15]; switchgear schematics; preliminary analysis (AI-generated, see `pps/diagrams/`, unreviewed).


---

## 14. RF Machine Protection System (MPS)

### 14.1 Overview

The RF MPS provides equipment/machine protection — distinct from the personnel-safety PPS. It monitors klystron operating parameters and RF station conditions, removing permits to protect equipment from damage.

### 14.2 Hardware Evolution

| Era | Platform | Status |
|-----|----------|--------|
| Original | Allen-Bradley PLC-5 (1771 series) | Obsolete, replaced |
| Current | Allen-Bradley ControlLogix 1756 | Hardware assembled, software written, tested without RF power |

The ControlLogix conversion retained the fundamental protection logic while modernizing the platform. The MPS PLC is located in Building B132 near the VXI crate and klystron.

### 14.3 Protection Functions

The RF MPS monitors and protects against:
- Excessive klystron collector power (cathode power minus RF output)
- Excessive reflected power at any cavity
- Waveguide arc conditions (via interlock chassis inputs)
- Loss of cooling water
- Klystron vacuum excursion
- HVPS fault conditions

When any protection condition is triggered, the MPS removes the permit signal, which:
1. Removes HVPS SCR ENABLE (disabling high voltage)
2. Removes the RF drive enable (shutting off RF output)
3. May trigger the crowbar (for arc conditions requiring fast energy dump)

### 14.4 MPS Wiring

33 MPS wiring diagrams (wd3403300200 through wd3403303400) describe the complete MPS signal chain from multiple trip sources to HVPS and crowbar outputs.

> 📷 **[PHOTO PLACEHOLDER]**: *RF MPS ControlLogix 1756 PLC rack in B132*

> **Sources**: MPS wiring diagrams [R21]; [R5] §7; preliminary analysis (AI-generated, see `spear-rf-code-legacy/codeReviewTechnicalNotes/06-plc-stepper-motors.md`, unreviewed).


---

## 15. Interlock Architecture and Signal Chain

### 15.1 Overview

The interlock system spans multiple hardware layers, from fast analog hardware interlocks to slow PLC-monitored conditions:

| Layer | Speed | Hardware | Function |
|-------|-------|----------|----------|
| Fast analog | <1 μs | Fast Interlock Chassis | Arc detection, reflected power limits |
| PLC hardware | ~10 ms | RF MPS ControlLogix | Equipment protection calculations |
| PLC software | ~100 ms | SLC-500 (HVPS) | HVPS sequencing and monitoring |
| EPICS supervisory | ~1 s | VXI IOC / SNL | State machine, operator interface |

### 15.2 Interlock Chassis

The Fast Interlock Chassis (also called Local Control Chassis) in B132 receives and summarizes hardware interlock signals:
- Arc detection inputs from waveguide fiber optic sensors
- Reflected power monitor inputs
- External permits (SPEAR MPS beam permit, orbit interlock)
- HVPS status fiber optic signals

It reports summarized interlock status to the VXI crate through the ARC/Interlock Module (AIM).

### 15.3 Complete Trip Chain

```
Fault detected (arc, reflected power, vacuum, etc.)
    │
    ├── Fast Interlock Chassis (analog, <1 μs)
    │       │
    │       ├── SCR ENABLE removed (fiber optic → B514)
    │       ├── CROWBAR fired (fiber optic → B514)
    │       └── AIM fault word → VXI IOC
    │
    ├── RF MPS PLC (digital, ~10 ms)
    │       │
    │       ├── MPS permit removed
    │       └── Status → VXI IOC
    │
    └── VXI IOC / rf_states.st (software, ~1 s)
            │
            ├── Fault file capture (/dat/FAULT*_)
            ├── Station state → OFF
            └── Operator notification
```

> 📷 **[PHOTO PLACEHOLDER]**: *Fast Interlock Chassis in B132 — front panel showing indicator LEDs, fiber optic connections, and RF detector inputs*

> **Sources**: [R5] §17; [R16].


---

# PART V — CONTROL SOFTWARE AND INSTRUMENTATION

---

## 16. EPICS IOC and SNL Software Architecture

### 16.1 IOC Platform

The VXI crate Slot 0 processor runs VxWorks RTOS with an EPICS IOC. The IOC hosts 6 SNL (State Notation Language) programs compiled into a single `rfSeq` library:

| Program | Lines | Instances | Authors | Function |
|---------|-------|-----------|---------|----------|
| `rf_states.st` | 2,227 | 1 | R.C. Sass, M. Laznovsky, S. Allison | Master station state machine |
| `rf_calib.st` | 3,345 | 1 | R. Claus | Calibration sequences |
| `rf_tuner_loop.st` | 555 | 4 (per cavity) | — | Cavity tuner motor control |
| `rf_hvps_loop.st` | 343 | 1 | — | HVPS supervisory control |
| `rf_dac_loop.st` | 290 | 1 | S. Allison | Drive/gap voltage DAC control |
| `rf_msgs.st` | 352 | 1 | — | Message logging, TAXI monitoring |

Plus 11 header/macro files (1,111 lines) defining PV names, status codes, and control macros.

> **Sources**: Legacy source code in `spear-rf-code-legacy/rfApp/src/seq/` [R16]–[R20]; preliminary analysis (AI-generated, see `spear-rf-code-legacy/codeReviewTechnicalNotes/`, unreviewed).


### 16.2 rf_states.st — Master Station State Machine

**Primary States**: OFF (0) → PARK (1) → TUNE (2) → ON_FM (3) → ON_CW (4)

**State architecture**: 3 concurrent state sets:
1. **`ss rf_states`** — Main state machine with 5 primary states + 17 transition states
2. **`ss rf_statesLP`** — Loop protection (concurrent monitoring)
3. **`ss rf_statesFF`** — Fault file capture (asynchronous)

**Total**: 23 states across 3 concurrent state sets.

**State transitions**:
- OFF → PARK: Operator command; initializes VXI modules, loads DSP firmware
- PARK → TUNE: Operator command; enables drive power, engages direct feedback loop
- TUNE → ON_FM: Enables comb and ripple loops (PEP-II modes)
- TUNE → ON_CW (direct): Bypasses ON_FM, goes straight to full power
- Any → OFF: Fault or operator shutdown; orderly disengagement of all loops

### 16.3 rf_hvps_loop.st — HVPS Supervisory Control

States: `init` → `off` → `proc` (processing/conditioning) → `on`

**Processing mode** carefully ramps HVPS voltage while monitoring cavity vacuum. If vacuum exceeds limits, voltage is reduced. This is used during cavity conditioning and post-trip recovery.

**16 status codes** (from source): The HVPS reports status via integer codes that the SNL program interprets for operator display and automated responses.

### 16.4 rf_tuner_loop.st — Cavity Tuner Control

Runs as 4 instances (one per cavity) via `CAV` macro substitution. Implements a slow feedback loop that maintains cavity resonant frequency by:
1. Reading cavity phase angle (from IQA module)
2. Comparing against setpoint (optimal detuning for current beam current)
3. Commanding stepper motor moves via AB 1746-HSTP1 controller

**5 SNL states**, 2 control algorithms (phase-feedback-based position tuning for resonance maintenance, and position homing for park/on transitions) plus a loop-off monitoring state.

### 16.5 rf_dac_loop.st — Drive/Gap Voltage DAC Control

Manages the RFP module's octal DACs that control drive power and gap voltage setpoints. The loop operates differently depending on whether the direct feedback loop is on or off, and transitions between TUNE and OPERATE modes.

**⚠️ ELIMINATED IN UPGRADE**: This program is entirely replaced by the LLRF9 internal vector modulator control.

### 16.6 rf_calib.st — Calibration Sequences

The largest SNL program (3,345 lines) implements 28 calibration measurement states including:
- IQA module amplitude/phase calibration
- Klystron gain measurement
- Cavity tuner characterization
- Feedback loop gain optimization

### 16.7 rf_msgs.st — Message Logging

Monitors CAMAC TAXI communication errors, VXI module health, and system messages. Reports status to EPICS archiver.


---

## 17. Tuner Control System

### 17.1 Legacy Configuration (Pre-2025)

| Component | Detail |
|-----------|--------|
| Controllers | Allen-Bradley 1746-HSTP1 stepper modules (4 units) |
| Drivers | Superior Electric SLO-SYN SS2000MD4-M PWM step drive translators |
| Motors | Superior Electric SLO-SYN M093-FC11 (NEMA 34D, 4 units) |
| Communication | Via AB DCM serial link from VXI crate |
| Software | `rf_tuner_loop.st` (SNL, 4 instances) |

### 17.2 Current Configuration (August 2025 – Present)

| Component | Detail |
|-----------|--------|
| Controller | Galil DMC-4143 Rev 1.3h 4-axis motion controller |
| Motors | Same SLO-SYN M093-FC11 (retained) |
| Communication | Ethernet (with heartbeat monitoring) |
| Position Feedback | Linear potentiometers on each tuner (retained) |

> **Sources**: [R29]; [R30]; [R31]; [R34]; [R35]; [R36]; preliminary analysis (AI-generated, see `spear-rf-code-legacy/codeReviewTechnicalNotes/08-signal-processing.md` §tuner, unreviewed).

The Galil controller was commissioned in August 2025 and is now operational for cavity tuner control.

> **Sources**: [R34]; [R35]; [R36]; [R5] §10.

> 📷 **[PHOTO PLACEHOLDER]**: *Galil DMC-4143 controller installed in B132 electronics rack*

> 📷 **[PHOTO PLACEHOLDER]**: *Legacy AB 1746-HSTP1 module (if still visible) showing comparison with Galil replacement*


---

## 18. Diagnostics, Calibration and Monitoring

### 18.1 RF Signal Monitoring

24 RF signals are monitored across the waveguide network (see §7.2 for complete table). In the legacy system, these are measured by the VXI IQA modules. In the upgrade, they will be distributed across LLRF9 units and the Waveform Buffer System.

### 18.2 HVPS Monitoring

4 analog monitoring signals from B514 to B118 (see §9.4). Additionally, the PLC monitors:
- 8 thermocouple channels (4 actively scaled to engineering units)
- Oil level switches (main tank, phase tank, crowbar tank)
- Contactor and grounding switch status
- All fiber optic signal states

### 18.3 Fault Recording

**Legacy fault file system**: On any fault triggering a station trip, the VXI IOC captures 11 signal channels to `/dat/FAULT<channel>_<n>` files in a circular buffer of fault records (channels: RfpSI, RfpSQ, RfpCI, RfpCQ, Cf2I, Cf2Q, Iqa1Amp, Iqa2Amp, Iqa3Amp, Gvf, Aim). These files preserve pre-fault waveforms for post-mortem analysis.

### 18.4 Calibration Data

Calibration sequences are implemented in `rf_calib.st` (28 measurement states). Key calibrations include:
- RF signal amplitude and phase calibration against known references
- Klystron gain curve measurement
- Cavity detuning characterization
- Tuner motor step-to-frequency conversion factors

> **Sources**: [R19]; [R24]; [R18].


---

# PART VI — INTEGRATION AND LEGACY CONSIDERATIONS

---

## 19. Cabling and Interconnections

### 19.1 Major Cable Runs

| Cable Run | Cable Type | Conductors | Route |
|-----------|-----------|------------|-------|
| B118 → Switchgear (Contactor) | Belden 83715 | 15C #16 Teflon | TS-5 to contactor controller |
| B118 → Termination Tank (Grounding) | Belden 83709 + Belden 83715 | 9C + 15C #16 Teflon | TS-6 to grounding tank |
| B118 → B514 (SCR triggers) | Electrical cable pairs | 12 pairs | Controller to Phase Tank thyristor stacks |
| B118 → B514 (Fiber optic) | Fiber optic | SCR ENABLE, CROWBAR, STATUS | Controller to HVPS power section |
| B132 → Tunnel (RF signals) | Coax cables | Forward, reflected, probe per cavity | LLRF inputs from cavities |
| B132 → Tunnel (Motor) | Multi-conductor | Motor power + encoder per cavity | To tuner assemblies |

### 19.2 Connector Types

| Interface | Connector | Notes |
|-----------|-----------|-------|
| PPS | GOB12-88PNE | Lockable, military-grade |
| RF signals | SMA/N-type | 50Ω coaxial |
| Fiber optic | HFBR series | Avago/Broadcom |
| PLC communication | AB DCM | Proprietary serial |
| Galil Ethernet | RJ-45 | Standard Ethernet |

> **Sources**: [R14]; [R15]; [R5] §3.


---

## 20. Known Issues, Limitations and Legacy Debt

### 20.1 Critical Issues

| Issue | Category | Impact | Details |
|-------|----------|--------|---------|
| PPS compliance | Safety | **Critical** | PLC in PPS chain; PPS wires exposed in HVPS controller enclosure |
| VXI crate obsolescence | Hardware | **Critical** | Custom SLAC modules (RFP, IQA, CLK, AIM) — no replacements available |
| SLC-500 PLC end-of-life | Hardware | **High** | Allen-Bradley discontinued; no vendor support |
| PLC-5 MPS platform | Hardware | **High** | Originally PLC-5 (1771); ControlLogix conversion assembled but not yet operational with RF |
| SLO-SYN driver obsolescence | Hardware | **Medium** | SS2000MD4-M discontinued; Galil DMC-4143 now operational replacement |
| VxWorks/SNL software | Software | **High** | PEP-II era code (1997); unsupported OS; no modern development tools |

### 20.2 Documentation Gaps

| Gap | Impact | Notes |
|-----|--------|-------|
| K4/RR relay label error | Medium | Corrected in AI analysis; as-built drawings may still show incorrect labels |
| Manual grounding switch contact type | Low | Inconsistency between WD-730-794-06-C0 (NO) and SD-730-790-05-C1 (NC); field verification required |
| MPS trip logic completeness | Medium | 33 MPS wiring diagrams exist but a consolidated trip logic truth table has not been assembled |
| Operational setpoints and limits | High | Alarm limits, tuner deadbands, safe operating envelopes not systematically captured |

### 20.3 Operational Workarounds

Several operational workarounds are in place due to legacy limitations:
- Manual operator intervention required for some fault recovery sequences that could be automated
- Cavity processing (conditioning) requires careful manual voltage ramping due to limited automation in legacy SNL code
- PEP-II hardware modules (comb filter, GVF) occupy VXI slots but are non-functional in SPEAR3 configuration

---


---

## Appendix A — Source Document Reference Index

All references cited in this document, organized by reference number.

### A.1 Published Papers and Conference Proceedings

| Ref | Citation |
|-----|---------|
| [R1] | McIntosh, P. et al., "The SPEAR3 RF System," SLAC-PUB-10983 (also cited as SLAC-PUB-11017), presented at EPAC 2004, Lucerne, Switzerland. DOI: 10.2172/839730 |
| [R2] | Corredoura, P., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8498, PAC 1999. DOI: 10.1109/PAC.1999.795726 |
| [R3] | Corredoura, P. et al., "Experience with the PEP-II RF System at High Beam Currents," arXiv:physics/0007029, EPAC 2000 |
| [R6] | Cassel, R. and Nguyen, M.N., "A Unique Power Supply for the PEP II Klystron at SLAC," SLAC-PUB-7591, PAC 1997. IEEE doi: 10.1109/PAC.1997.753249 |
| [R41] | Ziomek, C. and Corredoura, P., "Digital I/Q Demodulator," Proc. PAC 1995 |
| [R42] | Fox, J. et al., "Longitudinal Feedback System for PEP-II," Phys. Rev. ST Accel. Beams 13, 052802 (2010) |
| [R43] | Fowkes, W.R. et al., "PEP-II Prototype Klystron," SLAC-PUB-6093, April 1993 |
| [R44] | Fowkes, W.R. et al., "1.2 MW Klystron for Asymmetric Storage Ring B Factory," SLAC-PUB-6778, March 1995 |
| [R45] | Rimmer, R.A., "RF Cavity Development for the PEP-II B Factory," LBL-33360, November 1992 |
| [R46] | Rimmer, R.A. et al., "High-Power Testing of the First PEP-II RF Cavity," SLAC-PUB-7210 / LBNL-38147, June 1996 |
| [R47] | Robinson, K.W., "Stability of Beam in Radiofrequency System," CEA Report CEAL-1010, February 1964. DOI: 10.2172/4075988 |
| [R48] | Boussard, D., "Control of Cavities with High Beam Loading," IEEE Trans. Nucl. Sci. NS-32, PAC 1985 |
| [R49] | McIntosh, P., "An Automated 476 MHz RF Cavity Processing Facility at SLAC," SLAC-PUB-10083, July 2003. DOI: 10.2172/815601 |

### A.2 Textbooks and General References

| Ref | Citation |
|-----|---------|
| [R50] | Wiedemann, H., *Particle Accelerator Physics*, 4th ed., Springer, 2015 |
| [R51] | Dimtel, Inc., "LLRF9 Product Page," https://www.dimtel.com/products/llrf9 |
| [R52] | Dimtel, Inc., "LLRF9/500 Specifications," https://www.dimtel.com/products/specs/llrf9_500 |

### A.3 Original Engineering Documents in Repository

| Ref | Document | Repository Path |
|-----|----------|----------------|
| [R4] | LLRF9 Commissioning Tests (J. Sebek, 2021) | `llrf/tests/llrf9Tests.pdf` |
| [R5] | SPEAR3 LLRF System Design Report (PDR R1) | `Designs/0_SYSTEM_DESIGN_REPORT.md` and `Designs/docx/SPEAR3_LLRF_PDR_R1.docx` |
| [R7] | PEP-II RF System Description (Schwarz, PS-340-330-51-R0) | `llrf/documentation/legacyArchitecture/ps3403305100.pdf` |
| [R7t] | Transcription of [R7] | `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PS-340-330-51_RF_System_Description.md` |
| [R8] | LLRF Feedback Loop Description (Schwarz, PS-340-330-52-R0) | `llrf/documentation/legacyArchitecture/ps3403305200.pdf` (= `feedbackLoopDescriptionps3403305200.pdf`) |
| [R8t] | Transcription of [R8] | `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md` |
| [R9] | HVPS System Schematic (top-level) | `hvps/documentation/schematics/sd7307900101.pdf` |
| [R10] | LLRF Block Diagram (HER configuration) | `llrf/documentation/legacyArchitecture/bd3403300000.pdf` |
| [R11] | LLRF Block Diagram (alternative view) | `llrf/documentation/legacyArchitecture/bd3403300100.pdf` |
| [R12] | Analog Regulator Card Schematic | `hvps/documentation/schematics/sd2372301401.pdf` |
| [R13] | Voltage Divider Network Schematic | `hvps/documentation/schematics/sd2372301200.pdf` |
| [R14] | Interconnection: B118 ↔ Contactor ↔ Termination Tank | `hvps/documentation/wiringDiagrams/wd7307900103.pdf` |
| [R15] | Hoffman Box Internal Wiring | `hvps/documentation/wiringDiagrams/wd7307900206.pdf` |
| [R16] | Legacy SNL: rf_states.st (master state machine) | `spear-rf-code-legacy/rfApp/src/seq/rf_states.st` |
| [R17] | Legacy SNL: rf_hvps_loop.st (HVPS control) | `spear-rf-code-legacy/rfApp/src/seq/rf_hvps_loop.st` |
| [R18] | Legacy SNL: rf_tuner_loop.st (tuner control) | `spear-rf-code-legacy/rfApp/src/seq/rf_tuner_loop.st` |
| [R19] | Legacy SNL: rf_calib.st (calibration sequences) | `spear-rf-code-legacy/rfApp/src/seq/rf_calib.st` |
| [R20] | Legacy SNL: rf_msgs.st (message logging) | `spear-rf-code-legacy/rfApp/src/seq/rf_msgs.st` |
| [R21] | MPS Wiring Diagrams (33 drawings) | `llrf/documentation/mpsWiringDiagrams/wd3403300200.pdf` through `wd3403303400.pdf` |
| [R22] | PEP-II HVPS Technical Specification (PS-341-360-01-R2) | `hvps/architecture/originalDocuments/ps3413600102.pdf` |
| [R22t] | Transcription of [R22] | `hvps/architecture/originalDocuments/transcriptions/ps3413600102_transcription.md` |
| [R23] | HVPS Monitor Connections | `hvps/documentation/wiringDiagrams/hvpsMonitorConnections.xlsx` |
| [R24] | HVPS Measurements (March 2022) | `hvps/documentation/plc/hvpsMeasurements20220314.xlsx` |
| [R25] | PPS Wiring in Hoffman Box (J. Sebek) | `pps/HoffmanBoxPPSWiring.docx` |
| [R26] | PLC Ladder Logic Printout (Cassel) | `hvps/documentation/plc/CasselPLCCode.pdf` |
| [R27] | PLC Symbol/Label Database (Cassel) | `hvps/documentation/plc/CasselSymbolDatabase.pdf` |
| [R28] | Enerpro Schematics and Manuals (12 PDFs) | `hvps/controls/enerpro/enerproDocuments/` |
| [R29] | SLO-SYN Stepper Drive Manual | `llrf/tuners/SLO-SYN_SS2000MD4M_Step_Drive_Translator_Manual.pdf` |
| [R30] | SLO-SYN Motor Specifications | `llrf/tuners/SLO-SYN.pdf` |
| [R31] | Galil DMC-4103 Manual | `llrf/tuners/galil/dmc-4103-r13h-manual.pdf` |
| [R32] | Drive Amplifier Datasheet (KAW2051M12) | `llrf/driveAmp/KAW2051M12 (7-98-907-012A).pdf` |
| [R33] | Coaxial Cable Interconnection Diagram | `llrf/documentation/coaxCables/sd3403300100.pdf` |
| [R34] | Galil Commissioning Log (Aug 2025) | `llrf/tuners/galil/functioningGalil20250825SwapABToManual.txt` |
| [R35] | Galil Commissioning Documentation | `llrf/tuners/galil/GalilCommissioning.docx` |
| [R36] | Cavity Tuner Inspections (June 2023) | `llrf/tuners/cavityTunerInspections20230613.docx` |
| [R37] | PLC Operation Notes | `hvps/documentation/plc/plcNotesR1.docx` |
| [R38] | PLC Software Discussion | `hvps/documentation/plc/PLC software discusion 1.docx` |
| [R39] | PLC Label Database | `hvps/documentation/plc/hvpsPlcLabels.xlsx` |
| [R40] | Enerpro Board Integration Notes | `hvps/controls/enerpro/enerproBoardHvps.docx` |

### A.4 AI-Generated Analysis Products (Consulted, Unreviewed)

The following AI-generated technical notes were consulted during preparation of this document as preliminary analysis aids. They are **not cited as authoritative sources** per the Documentation Architecture Proposal §2.4.

| Directory | Files | Coverage |
|-----------|-------|----------|
| `hvps/architecture/technical-notes/` | 8 + notebook | HVPS system design, PEP-II heritage, schematics, regulator, integration |
| `hvps/documentation/plc/technical-notes/` | 9 | PLC hardware, I/O config, ladder logic, algorithms, safety |
| `hvps/documentation/schematics/technical_notes/` | 14 | Individual schematic analyses |
| `hvps/controls/enerpro/technical-notes/` | 9 | Enerpro system, hardware, circuits, control theory |
| `llrf/documentation/legacyArchitecture/technical-notes/` | 6 | PEP-II/SPEAR3 reference, feedback loops, VXI hardware |
| `pps/diagrams/` | 11 | PPS system, contactor, Ross switch, Hoffman box, PLC code |
| `spear-rf-code-legacy/codeReviewTechnicalNotes/` | 9 | Executive summary, architecture, VXI, DSP, SNL, PLC |

**Total AI-generated analysis**: ~100 markdown files, ~24,000+ lines

**⚠️ PROVENANCE WARNING**: All files in the directories above are AI-generated analysis products. They were created by analyzing original source documents and have NOT been reviewed by engineering staff. Always verify against original source documents.

### A.5 External Web References

| Ref | URL | Content |
|-----|-----|---------|
| [W1] | https://inspirehep.net/files/945e7ff73cc428af4c018fd1bdb6afa7 | McIntosh et al. EPAC04 full text |
| [W2] | https://www.osti.gov/biblio/839730 | OSTI record for SLAC-PUB-10983 (SPEAR3 RF System) |
| [W3] | https://digital.library.unt.edu/ark:/67531/metadc619632/ | Corredoura, PEP-II LLRF Architecture (UNT Digital Library) |
| [W4] | https://www.osti.gov/biblio/10204 | OSTI record for Corredoura PAC99 |
| [W5] | https://arxiv.org/pdf/physics/0007029 | Corredoura et al., PEP-II RF at High Beam Currents |
| [W6] | https://ieeexplore.ieee.org/document/753249/ | Cassel & Nguyen, PEP-II Klystron Power Supply (IEEE) |
| [W7] | https://www.osti.gov/servlets/purl/7066243 | Rimmer, RF Cavity Development for PEP-II (LBL-33360) |
| [W8] | https://www.osti.gov/servlets/purl/505666 | Rimmer et al., High-Power Testing PEP-II RF Cavity |
| [W9] | https://www.osti.gov/biblio/4075988 | Robinson, Stability of Beam in RF System (CEAL-1010) |
| [W10] | https://proceedings.jacow.org/p85/PDF/PAC1985_1852.PDF | Boussard, Control of Cavities with High Beam Loading |
| [W11] | https://www.dimtel.com/products/llrf9 | Dimtel LLRF9 product page |
| [W12] | https://www.dimtel.com/products/specs/llrf9_500 | LLRF9/500 specifications |
| [W13] | https://inspirehep.net/files/dd3ac6684a603446924fb193fcd7faf0 | Fowkes et al., 1.2 MW Klystron (SLAC-PUB-6778) |
| [W14] | https://s3.cern.ch/inspire-prod-files-e/ede001caff380d3448f21bc3b1d5e371 | Fowkes et al., PEP-II Prototype Klystron (SLAC-PUB-6093) |
| [W15] | https://slac.stanford.edu/pubs/slacpubs/10000/slac-pub-10083.pdf | McIntosh, 476 MHz Cavity Processing (SLAC-PUB-10083) |
| [W16] | https://www.osti.gov/biblio/815601 | OSTI record for SLAC-PUB-10083 |
| [W17] | https://inspirehep.net/literature/1102529 | INSPIRE record for Robinson 1964 |
| [W18] | https://www.desy.de/~branlard/papers/LINAC14/WEIOA06.pdf | Branlard, "Low Level RF for SRF Accelerators," LINAC14 |

---

## Appendix B — Symbol and Notation Conventions

### B.1 Frequently Used Symbols

| Symbol | Definition | Typical Unit |
|--------|-----------|-------------|
| f₀, ω₀ | Cavity resonant frequency | MHz, rad/s |
| f_RF, ω_RF | RF operating frequency (476.315 MHz) | MHz, rad/s |
| f_rev, ω_rev | Revolution frequency (1.2808 MHz) | MHz, rad/s |
| f_s, ω_s | Synchrotron frequency (~9.4 kHz) | kHz, rad/s |
| Q₀ | Unloaded quality factor (33,500) | dimensionless |
| Q_L | Loaded quality factor (6,700) | dimensionless |
| β | Coupling coefficient = Q₀/Q_ext (4.0) | dimensionless |
| R_s | Shunt impedance (3.9 MΩ) | MΩ |
| V_gap | Gap voltage per cavity (~712 kV operating) | kV |
| I_b | DC beam current (500 mA design) | mA or A |
| V_HV | HVPS output voltage (−74.7 kV operating) | kV |
| I_HV | HVPS output current (19.4 A operating) | A |
| α | SCR firing angle | degrees |
| SIG HI | Enerpro control voltage (proportional to α) | V |

### B.2 Abbreviations

| Abbreviation | Definition |
|-------------|-----------|
| AIM | Arc/Interlock Module (VXI) |
| CLK | Clock/RF Distribution module (VXI) |
| DCM | Direct Communication Module (Allen-Bradley) |
| GVF | Gap Voltage Feed-Forward (PEP-II only) |
| HER | High Energy Ring (PEP-II) |
| HOM | Higher-Order Mode |
| HVPS | High-Voltage Power Supply |
| IQA | IQ/Amplitude detector module (VXI) |
| LLRF | Low-Level RF |
| MPS | Machine Protection System |
| PPS | Personnel Protection System |
| RFP | RF Processor module (VXI) |
| SCR | Silicon Controlled Rectifier (thyristor) |
| SNL | State Notation Language (EPICS) |

### B.3 Conventions

1. **Shunt impedance convention**: This document uses the **linac convention** (R_s = V²/2P) unless explicitly stated otherwise. The accelerator convention (R_s = V²/P) gives values exactly 2× larger.

2. **Phase convention**: Positive phase angles represent phase advance. The synchronous phase φ_s is measured from the zero-crossing of the RF voltage.

3. **Frequency detuning**: Δf = f₀ − f_RF. Negative detuning (Δf < 0) means the cavity resonant frequency is below the RF frequency — the normal operating condition for beam loading compensation above transition.

4. **Reference tag format**: [Rn] for numbered references, [Rnt] for transcription of the same source, [Wn] for web references.

5. **Voltage polarity**: HVPS voltages are reported as positive magnitudes unless preceded by a minus sign. The actual cathode polarity is negative (−77 kV).

---

*End of Document*

**Document Control**:
- This document is the Tier 2 legacy system reference for the SPEAR3 RF system.
- The definitive version is `Designs/L_LEGACY_SYSTEM_ARCHITECTURE.md` in the `spearlegacyLLRF` repository.
- **Provenance**: AI-ASSISTED — structure and content proposed by AI based on exhaustive review of original source documents, published papers, and web research. Subject to human review and approval by a named engineer.
- **Review status**: UNREVIEWED — requires verification by a qualified RF engineer against original source documents and the physical system.
