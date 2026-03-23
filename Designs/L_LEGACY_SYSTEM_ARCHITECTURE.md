# SPEAR3 RF Station — Legacy System Architecture

**Document ID**: Doc L  
**Tier**: 2 — Legacy System & Operational Reference  
**Version**: 1.0  
**Date**: March 23, 2026  
**Status**: DRAFT  
**Replaces**: Doc A (`A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md`) + Doc B (`B_SPEAR3_CURRENT_LLRF_TECHINICAL_DESIGN_REPORT.md`)  
**Classification**: Engineering Architecture Reference  

---

## Table of Contents

1. [Introduction and Purpose](#1-introduction-and-purpose)
2. [System Heritage and Context](#2-system-heritage-and-context)
3. [Physical Architecture and Station Layout](#3-physical-architecture-and-station-layout)
4. [System-Level Architecture](#4-system-level-architecture)
5. [Subsystem S1: LLRF Controller](#5-subsystem-s1-llrf-controller)
6. [Subsystem S2: High Voltage Power Supply (HVPS)](#6-subsystem-s2-high-voltage-power-supply-hvps)
7. [Subsystem S3: RF Machine Protection System (RF MPS)](#7-subsystem-s3-rf-machine-protection-system-rf-mps)
8. [Subsystem S4: Distributed Interlock System (Interface Chassis Predecessor)](#8-subsystem-s4-distributed-interlock-system-interface-chassis-predecessor)
9. [Subsystem S5: Personnel Protection System (PPS) Interface](#9-subsystem-s5-personnel-protection-system-pps-interface)
10. [Subsystem S6: Tuner Control System](#10-subsystem-s6-tuner-control-system)
11. [Subsystem S7: Waveform Capture (Legacy Diagnostic Baseline)](#11-subsystem-s7-waveform-capture-legacy-diagnostic-baseline)
12. [Subsystem S8: Arc Detection System](#12-subsystem-s8-arc-detection-system)
13. [Subsystem S9: Klystron Cathode Heater](#13-subsystem-s9-klystron-cathode-heater)
14. [Subsystem S10: Control Software](#14-subsystem-s10-control-software)
15. [EPICS Process Variable Architecture](#15-epics-process-variable-architecture)
16. [Protection and Interlock Architecture](#16-protection-and-interlock-architecture)
17. [Known Limitations and Failure Modes](#17-known-limitations-and-failure-modes)
18. [Source Document Index](#18-source-document-index)

---

## 1. Introduction and Purpose

### 1.1 Scope

This document provides a comprehensive, system-level description of the **current (pre-upgrade) SPEAR3 RF station** — the complete legacy system that has been in continuous operation since 2003. It is the authoritative reference for understanding *how the existing system works* at the architecture level, without requiring the reader to examine source code or individual circuit schematics.

Doc L answers the question: **"How does the current SPEAR3 RF station work, from design concept to real-world implementation?"**

### 1.2 Audience

- **Upgrade designers** who need to understand what they are replacing
- **New engineers** learning the SPEAR3 RF system for the first time
- **Reviewers** evaluating upgrade proposals against legacy baseline
- **Operators** seeking deeper understanding of the system they run daily

### 1.3 Relationship to Other Documents

| Document | Relationship to Doc L |
|----------|----------------------|
| **Doc 0** (`0_SYSTEM_DESIGN_REPORT.md`) | Doc 0 defines the upgrade system; Doc L defines the legacy baseline. Both use the same 10-subsystem framework. |
| **Code Review Notes** (`spear-rf-code-legacy/codeReviewTechnicalNotes/`) | Doc L describes system-level architecture; the 8 code review notes provide code-level detail. Doc L references but does not duplicate them. |
| **Doc P** (planned) | Doc P will cover RF physics and control theory common to both legacy and upgrade systems. Doc L references the physics only as needed for architecture context. |
| **HVPS Technical Notes** (`hvps/architecture/technical-notes/`) | Detailed component-level HVPS analysis. Doc L §6 synthesizes at architecture level. |
| **Enerpro Technical Notes** (`hvps/controls/enerpro/technical-notes/`) | SCR firing control details. Doc L §6 references for the power conversion subsystem. |
| **PLC Technical Notes** (`hvps/documentation/plc/technical-notes/`) | HVPS PLC ladder logic analysis. Doc L §6 provides the control architecture view. |
| **PPS Diagrams** (`pps/diagrams/`) | PPS schematic analysis. Doc L §9 synthesizes the safety chain architecture. |
| **LLRF Legacy Architecture Notes** (`llrf/documentation/legacyArchitecture/technical-notes/`) | PEP-II heritage architecture documentation. Doc L §2 and §5 draw from these. |

### 1.4 System-Level vs. Code-Level Distinction

Doc L intentionally operates at the **system architecture** level. The distinction is:

| Doc L (System Level) | Code Review Notes (Code Level) |
|----------------------|-------------------------------|
| "The HVPS controller uses an SLC-500 PLC with an Enerpro SCR firing board" | "Rung 0016 controls OUT3 on the IO8 module (Slot 2) to drive the Ross switch coil at 120 VAC" |
| "The tuner loop measures cavity probe phase and drives a stepper motor to minimize load angle error" | "`rf_tuner_loop.st` has 5 SNL states: `loop_init`, `loop_unknown`, `loop_reset`, `loop_off`, `loop_on`" |
| "The station state machine sequences through OFF → PARK → TUNE → ON_FM → ON_CW" | "`rf_states.st` contains 23 SNL states across 3 concurrent state sets, with `s_init` reading the current state PV" |

When code-level detail is needed, Doc L provides a cross-reference to the specific code review note and section.

### 1.5 Photo Placeholders

> **📷 NOTE**: This document includes placeholders for photographs of the current legacy hardware. These will be populated during a scheduled photo documentation session covering all major system components in B132, B118, B514, and the tunnel. Each placeholder indicates the subject and planned photo location.

---

## 2. System Heritage and Context

### 2.1 PEP-II B-Factory Origin (1996–2008)

The SPEAR3 LLRF system is a direct descendant of the PEP-II B-Factory RF system designed at SLAC by P. Corredoura, S. Allison, R.C. Sass, R. Tighe, and R. Claus (1996–1997). PEP-II was an asymmetric electron-positron collider that operated from 1999 to 2008:

| Ring | Energy | Current | Stations | Cavities/Station |
|------|--------|---------|----------|-------------------|
| High Energy Ring (HER) | 9 GeV | up to 1.8 A | 5→7 | 4 |
| Low Energy Ring (LER) | 3.1 GeV | up to 3.0 A | 2→3 | 2 |

The PEP-II LLRF system was engineered to handle extreme beam loading conditions where beam-induced cavity voltages substantially exceeded generator-supplied voltages. This over-engineering proved beneficial for the much lighter beam loading conditions at SPEAR3.

> **Source**: Corredoura, P.L., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8498, PAC 1999;  `llrf/documentation/legacyArchitecture/technical-notes/00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md`

### 2.2 SPEAR3 Adoption (2003)

In 2003, SPEAR was upgraded to SPEAR3, a 3rd-generation synchrotron light source at SSRL/SLAC. The RF system upgrade replaced the original 358.54 MHz system with a PEP-II HER RF station:

| Parameter | SPEAR2 (Original) | SPEAR3 (PEP-II Heritage) |
|-----------|-------------------|--------------------------|
| RF Frequency | 358.54 MHz | 476.315 MHz |
| Harmonic Number | 280 | 372 |
| Cavities | 1 × 5-cell aluminum | 4 × single-cell copper (PEP-II type) |
| Klystron | PEP-I type, ~200 kW | 1.2 MW (PEP-II type) |
| Gap Voltage | 1.6 MV total | 3.2 MV total (800 kV/cavity design) |
| Beam Current | 100 mA | 500 mA (design) |
| Beam Energy | 3.0 GeV | 3.0 GeV |
| LLRF Control | Analog + EPICS | PEP-II VXI LLRF + EPICS |

SPEAR3 is a **single-station** implementation of the PEP-II LLRF design: one klystron driving four single-cell copper cavities through a waveguide distribution network. The control software was adapted from PEP-II with station-specific macro substitutions (`STN=SRF1`).

> **Source**: McIntosh, P., "The SPEAR3 RF System," SLAC-PUB-11017, January 2005; `llrf/documentation/legacyArchitecture/technical-notes/00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` §1.2

### 2.3 System Operating Parameters

| Parameter | Symbol | Value | Notes |
|-----------|--------|-------|-------|
| RF Frequency | f_RF | 476.315 MHz | Harmonic 372 of revolution frequency |
| Revolution Frequency | f_rev | 1.2808 MHz | C = 234.137 m circumference |
| Beam Energy | E | 3.0 GeV | |
| Design Beam Current | I_b | 500 mA | Top-off mode |
| Fill Pattern | — | 276 bunches in 4 groups + 1 camshaft | |
| Number of Cavities | N_cav | 4 | Single-cell, HOM-damped copper |
| Cavity Shunt Impedance | R_s | 3.8 MΩ | Per cavity, circuit convention |
| Cavity Unloaded Q | Q_0 | 33,500 | |
| Cavity Loaded Q | Q_L | 6,700 | β = Q₀/Q_ext = 4.0 |
| Cavity Half-Bandwidth | f_½ | 35.5 kHz | f₀/(2Q_L) |
| Gap Voltage per Cavity | V_gap | 712 kV (operating) | 800 kV design |
| Total Accelerating Voltage | V_total | 2.85 MV (operating) | 3.2 MV design |
| Klystron Maximum Power | P_kly | 1.2 MW | |
| HVPS Operating Voltage | V_HVPS | 74.4 kV (nominal) | Up to 90 kV maximum |
| IF Frequency (legacy) | f_IF | 4.9 MHz | f_RF − f_LO |
| LO Frequency | f_LO | 471.1 MHz | |
| Synchrotron Frequency | f_s | ~8.8 kHz | At operating conditions |
| Momentum Compaction | α_c | 1.18 × 10⁻³ | |

> **Source**: `Designs/obsolete/B_SPEAR3_CURRENT_LLRF_TECHINICAL_DESIGN_REPORT.md` §3; `llrf/documentation/legacyArchitecture/technical-notes/00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` §1.4

### 2.4 25 Years of Continuous Operation

The SPEAR3 LLRF system has been in continuous service since 2003 — over two decades of uninterrupted operation. The system has delivered stable RF power through thousands of user-mode shifts, multiple storage ring energy configurations, and various fill pattern optimizations. This operational longevity is a testament to the robustness of the original PEP-II design, but it also means that every component is well beyond its intended design life.

---

## 3. Physical Architecture and Station Layout

### 3.1 Site Overview

The SPEAR3 RF system is distributed across four physical locations at the Stanford Synchrotron Radiation Lightsource (SSRL), all on the SLAC campus:

```
                         SPEAR3 RF Station — Physical Layout

    ┌─────────────────────────────┐
    │   SUBSTATION 507            │
    │   12.47 kV 3φ Input Power   │     ⟵ Primary power source
    │   Breaker 160               │        for HVPS
    └──────────────┬──────────────┘
                   │ HV Cable
    ┌──────────────▼──────────────┐
    │   BUILDING B514             │
    │   HVPS Power Equipment      │     ⟵ Transformers, rectifiers,
    │   • Phase-shift xfmr (T0)   │        crowbar, filter bank
    │   • Rectifier xfmrs (T1,T2) │        (OUTDOOR / INDOOR)
    │   • SCR bridges (12 stacks) │
    │   • Filter bank & crowbar   │
    │   • Grounding (Term.) Tank  │
    └──────────────┬──────────────┘
                   │ −77 kV DC cable
    ┌──────────────▼──────────────┐     ┌───────────────────────────┐
    │   BUILDING B132             │     │   BUILDING B118           │
    │   RF Station Equipment      │     │   HVPS Control Room       │
    │   • Klystron                │     │   • Hoffman Box (SLC-500  │
    │   • Circulator + Load       │     │     PLC, Enerpro boards,  │
    │   • Waveguide distribution  │     │     relay logic)          │
    │   • Drive amplifier (50 W)  │     │   • Allen-Bradley PLC-5   │
    │   • VXI crate (LLRF ctrl)   │     │     (RF MPS)              │
    │   • Filament heater         │◄────│   • Fiber optic interface │
    │   • Arc detection (waveguide│     │   • Waveform monitoring   │
    │     pickup)                 │     │   • Operator workstation  │
    └──────────────┬──────────────┘     └───────────────────────────┘
                   │ RF waveguide
    ┌──────────────▼──────────────┐
    │   SPEAR3 TUNNEL             │
    │   • 4 × RF Cavities        │     ⟵ Single-cell copper,
    │   • 4 × Cavity tuners      │        PEP-II type
    │   • Waveguide connections   │
    │   • HOM loads               │
    │   • VACION pumps            │
    └─────────────────────────────┘
```

> **📷 PHOTO PLACEHOLDER**: Aerial/map view showing relative positions of B132, B118, B514, and tunnel

### 3.2 Building B132 — RF Station

Building B132 houses the main RF station equipment. This is where the klystron, RF signal chain, and control electronics are located.

**Key Equipment**:

| Equipment | Model/Type | Function |
|-----------|------------|----------|
| Klystron | SLAC PEP-II type, 476 MHz | ~1.2 MW CW RF power source |
| Circulator + Water Load | — | Isolates klystron from waveguide reflections |
| Magic-Tee Splitters | × 3 | Distributes RF power to 4 cavities |
| Waveguide Loads | 1.2 MW rating × 3 | Absorbs reflected/excess power |
| Drive Amplifier | KAW2051M12, ~50 W | Provides input drive to klystron |
| VXI Crate | 13-slot VXI mainframe | LLRF controller (see §5) |
| Filament Heater | Motor-driven variac, 1 kW | Cathode heating (see §13) |
| Equipment Racks | 6 standard racks | Ancillary equipment, patch panels |
| LLRF "Blue Rack" | Air-conditioned | Sensitive RF electronics |

> **📷 PHOTO PLACEHOLDER**: B132 equipment room overview showing klystron, waveguide runs, and equipment racks
> **📷 PHOTO PLACEHOLDER**: VXI crate front panel with module labels visible
> **📷 PHOTO PLACEHOLDER**: Drive amplifier and RF signal chain

> **Source**: `llrf/documentation/legacyArchitecture/technical-notes/00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` §1.4b; `Designs/0_SYSTEM_DESIGN_REPORT.md` §3

### 3.3 Building B118 — HVPS Control Room

Building B118 contains the HVPS controller electronics, the RF MPS PLC, and the operator interface.

**Key Equipment**:

| Equipment | Model/Type | Function |
|-----------|------------|----------|
| Hoffman Box | NEMA enclosure | HVPS controller: SLC-500 PLC + Enerpro boards + relay logic |
| RF MPS PLC | Allen-Bradley PLC-5 (1771 series) | Machine protection; since converted to ControlLogix 1756 hardware |
| Fiber Optic Interface | HFBR-series | Communication between B118 and B132 |
| Monitoring Equipment | Oscilloscope, meters | HVPS waveform monitoring |
| Operator Workstation | EPICS/EDM display terminal | System status and control |

> **📷 PHOTO PLACEHOLDER**: B118 control room overview
> **📷 PHOTO PLACEHOLDER**: Hoffman Box (HVPS controller) with door open showing PLC and wiring
> **📷 PHOTO PLACEHOLDER**: RF MPS PLC rack

> **Source**: `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md`; `Designs/0_SYSTEM_DESIGN_REPORT.md` §3

### 3.4 Building B514 — HVPS Power Equipment

Building B514 (and its adjacent outdoor pad) houses the high-power electrical equipment for the HVPS.

**Key Equipment**:

| Equipment | Rating | Function |
|-----------|--------|----------|
| Phase-Shift Transformer (T0) | 3.5 MVA, oil-immersed | Creates 12-pulse rectification (±15° phase shift) |
| Rectifier Transformers (T1, T2) | 1.5 MVA each, oil-immersed | Step-down transformers for SCR bridges |
| SCR Bridges | 12 stacks × 14 Powerex T8K7 SCRs each | Phase-controlled rectification |
| Filter Inductors (L1, L2) | 0.3 H, 85 A rated | Primary-side filtering |
| Secondary Rectifier Bridges | 24 diodes, 4 bridges in series | DC rectification (120 kV, 22 A) |
| Capacitor Bank | 8 µF total | DC filtering, ~24 kJ stored energy |
| Crowbar SCR Stacks | 4 stacks, 100 kV / 80 A | Arc protection — discharges stored energy |
| Cable Termination Inductors (L3, L4) | 200 µH | Limits cable discharge current to klystron |
| Grounding (Termination) Tank | Aluminum enclosure | Ross grounding switch, current transducers, manual ground |

> **📷 PHOTO PLACEHOLDER**: B514 transformer area (T0, T1, T2)
> **📷 PHOTO PLACEHOLDER**: SCR stack assemblies
> **📷 PHOTO PLACEHOLDER**: Grounding (termination) tank with Ross switch

> **Source**: `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md`; `hvps/architecture/originalDocuments/transcriptions/slac-pub-7591_transcription.md`

### 3.5 SPEAR3 Tunnel — RF Cavities and Tuners

Four PEP-II type single-cell copper RF cavities are installed in the SPEAR3 storage ring tunnel.

**Per-Cavity Equipment**:

| Component | Specification |
|-----------|---------------|
| Cavity Type | PEP-II single-cell, normal conducting copper |
| Operating Frequency | 476.315 MHz |
| HOM Loads | 3 per cavity (higher-order mode damping) |
| Movable Tuner | Mechanical plunger with stepper motor |
| Ceramic Window | 1 per cavity (vacuum-to-waveguide interface) |
| VACION Pump | 400 l/s per cavity |
| Temperature Control | LCW loop at 35°C (regulated) |

> **📷 PHOTO PLACEHOLDER**: Tunnel view showing RF cavities installed on the beamline
> **📷 PHOTO PLACEHOLDER**: Close-up of cavity tuner mechanical assembly
> **📷 PHOTO PLACEHOLDER**: Waveguide connection to cavity with ceramic window

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §4; `llrf/documentation/legacyArchitecture/technical-notes/00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` §1.4b

### 3.6 Inter-Building Connections

| Connection | Route | Signal Type | Cable |
|------------|-------|-------------|-------|
| B514 → B132 | Underground cable run | −77 kV DC (HVPS output) | HV power cable |
| B118 ↔ B132 | Fiber optic | Control/status signals | Fiber optic bundle |
| B118 ↔ B514 | Direct cable | Monitoring (4 channels) | Multiconductor |
| B118 ↔ Contactor Panel | Multiconductor | PPS, control, status | Belden 83715 (15C #16 Teflon) |
| B118 ↔ Grounding Tank | Multiconductor | PPS, control, status | Belden 83709 (9C #16 Teflon) |
| B132 ↔ Tunnel | Waveguide | 476 MHz RF power | WR1800 waveguide |
| B132 ↔ Tunnel | Coaxial cable | RF monitoring signals | Semi-rigid coax |

> **Source**: `pps/diagrams/04_wd7307900206_hoffman_box_wiring.md`; `pps/diagrams/05_wd7307900103_interconnection_full.md`; `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md`

---

## 4. System-Level Architecture

### 4.1 Overall Block Diagram

The legacy SPEAR3 RF station is a hierarchical control system with four distinct layers operating at different timescales:

```
    LAYER 4 — OPERATOR / SUPERVISORY (~seconds)
    ┌─────────────────────────────────────────────────────────────────┐
    │  EPICS IOC (VxWorks, Motorola PPC604)                          │
    │  ├── rf_states.st    — Station state machine (OFF→PARK→...→CW) │
    │  ├── rf_hvps_loop.st — HVPS voltage regulation (~0.5s period)  │
    │  ├── rf_dac_loop.st  — DAC/gap voltage control (~0.5s period)  │
    │  ├── rf_tuner_loop.st — Tuner control (×4 cavities, ~seconds)  │
    │  ├── rf_calib.st     — Calibration sequences                   │
    │  └── rf_msgs.st      — Message logging & TAXI error recovery   │
    └──────────────┬──────────────────────────┬──────────────────────┘
                   │ Channel Access            │ Allen-Bradley Serial
    ┌──────────────▼──────────────┐   ┌───────▼────────────────────┐
    │  VXI Hardware Modules       │   │  External PLCs             │
    │  (Layer 2/3)                │   │  (Layer 2/3)               │
    │  ├── RFP (RF Processor)     │   │  ├── SLC-500 (HVPS ctrl)   │
    │  ├── IQA ×3 (I/Q detect)   │   │  ├── PLC-5 (RF MPS)        │
    │  ├── CLK (Clock/LO)        │   │  └── 1746-HSTP1 ×4 (tuner) │
    │  ├── AIM (Arc Interlock)    │   └────────────────────────────┘
    │  └── [GVF, CFM — not used] │
    └──────────────┬──────────────┘
                   │ Analog + Digital signals
    LAYER 1 — FAST ANALOG FEEDBACK (~µs)
    ┌──────────────▼──────────────┐
    │  RFP Analog Feedback Loops  │
    │  ├── Direct loop (~800 kHz) │
    │  ├── Lead compensation      │
    │  ├── Integral compensation  │
    │  └── Ripple loop (720 Hz)   │
    └──────────────┬──────────────┘
                   │ RF signals
    LAYER 0 — RF PLANT (physical)
    ┌──────────────▼──────────────┐
    │  Drive Amp → Klystron →     │
    │  Circulator → Magic Tee →   │
    │  4 × Cavities + Tuners      │
    └─────────────────────────────┘
```

### 4.2 Control Loop Hierarchy

The legacy system implements a **multi-rate hierarchical feedback architecture** with five active control loops (plus three inactive PEP-II heritage loops):

| Loop | Bandwidth | Period | Implementation | Function |
|------|-----------|--------|----------------|----------|
| **Direct** | ~800 kHz | Analog (continuous) | RFP hardware | Cavity field stabilization (proportional + integral) |
| **Lead Compensation** | ~100 kHz | Analog (continuous) | RFP hardware | Phase margin enhancement |
| **Integral Compensation** | ~1 kHz | Analog (continuous) | RFP hardware | Steady-state error elimination |
| **Ripple** | 720 Hz | Analog (continuous) | RFP hardware | AC line ripple rejection |
| **DAC** | ~1 Hz | ~0.5 s | SNL software | Drive power / gap voltage setpoint adjustment |
| **HVPS** | ~1 Hz | ~0.5 s | SNL software | Klystron voltage regulation |
| **Tuner** | ~0.1 Hz | ~seconds | SNL software | Mechanical cavity resonance frequency adjustment |

**Inactive PEP-II Heritage Loops** (hardware present but not used at SPEAR3):
- **Comb Filter** — Revolution harmonic suppression (PEP-II only; not needed for SPEAR3 beam current)
- **Gap Voltage Feed-Forward (GVF)** — PEP-II cavity field stabilization (hardware never installed)
- **LFB Woofer** — Longitudinal multibunch feedback interface (LFB system not present at SPEAR3)

The loop bandwidth separation follows the stability requirement: f_BW,direct >> f_BW,DAC >> f_BW,tuner, with at least one decade of separation between adjacent loops to avoid inter-loop coupling instabilities.

> **Source**: `Designs/obsolete/B_SPEAR3_CURRENT_LLRF_TECHINICAL_DESIGN_REPORT.md` §6; `Designs/obsolete/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` §2.3; `llrf/documentation/legacyArchitecture/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md`

### 4.3 Communication Architecture

The legacy system uses two communication paths:

**1. VXI Backplane** (within B132 VXI crate):
- VMEbus for register-level module communication
- VXI trigger bus for synchronization
- EPICS device support drivers for each module type

**2. Allen-Bradley Serial Network** (B132 → B118):
- Daisy-chain serial communication (Data Highway Plus / DH-485)
- VXI crate contains a VME Allen-Bradley communication module (DCM)
- Connects to: HVPS SLC-500 PLC, RF MPS PLC-5, 4× tuner stepper modules
- ~1 Hz update rate for supervisory control

```
    VXI Crate (B132)
    ┌────────────────────────────────┐
    │ CPU ── AB DCM ── CLK ── RFP   │
    │                 ── IQA1        │
    │                 ── IQA2        │
    │                 ── IQA3        │
    │                 ── AIM         │
    └────────┬───────────────────────┘
             │ Allen-Bradley Serial (DH-485)
             │
    ┌────────▼───────┐  ┌──────────────┐  ┌──────────────┐ ×4
    │ SLC-500 PLC    │  │ PLC-5        │  │ 1746-HSTP1   │
    │ (HVPS ctrl)    │  │ (RF MPS)     │  │ (Cavity tuner│
    │ B118           │  │ B118         │  │  stepper)    │
    └────────────────┘  └──────────────┘  └──────────────┘
```

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §2.1; `spear-rf-code-legacy/codeReviewTechnicalNotes/02-architecture-overview.md` §2; `spear-rf-code-legacy/codeReviewTechnicalNotes/06-plc-stepper-motors.md`

### 4.4 RF Signal Flow

The RF signal chain from the master oscillator to the cavity probes:

```
Master Oscillator (476.315 MHz)
        │
        ▼
  ┌─────────────┐     ┌──────────┐     ┌──────────┐     ┌──────────────┐
  │ VXI Clock   │────►│ RFP      │────►│ Drive    │────►│ Klystron     │
  │ Module      │     │ Module   │     │ Amplifier│     │ ~1.2 MW      │
  │ (LO gen,    │     │ (I/Q     │     │ ~50 W    │     │ 476 MHz      │
  │  IF gen)    │     │  feedback)│     │ KAW2051  │     │              │
  └─────────────┘     └──────────┘     └──────────┘     └──────┬───────┘
                                                               │ WG
                                                         ┌─────▼─────┐
                                                         │ Circulator│
                                                         │ + Load    │
                                                         └─────┬─────┘
                                                               │
                                                    ┌──────────▼──────────┐
                                                    │ Magic-Tee Network   │
                                                    │ (3× splitters)      │
                                                    └─┬──┬──┬──┬─────────┘
                                                      │  │  │  │
                                              ┌───────▼┐ │  │ ┌▼───────┐
                                              │Cav 1  │ │  │ │Cav 4   │
                                              │Probe──│◄┘  └►│──Probe │
                                              └───────┘      └────────┘
                                                      │      │
                                                      ▼      ▼
                                              IQA Modules (I/Q detection)
                                                      │
                                                      ▼
                                              RFP (feedback processing)
```

Twenty-four RF signals are monitored across the system (see Doc 0 §4.6 for the complete signal map). Key signals include:
- Klystron drive forward and reverse
- Klystron output forward and reverse
- 4× cavity forward, 4× cavity reverse
- 4× cavity probe (field measurement)

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §4; `llrf/documentation/legacyArchitecture/technical-notes/00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` §1.4

---

## 5. Subsystem S1: LLRF Controller

### 5.1 Purpose

The LLRF controller is the central RF signal processing and feedback system. It maintains stable cavity field amplitude and phase by continuously measuring the cavity probe signals, comparing them to setpoints, and adjusting the klystron drive to compensate for beam loading, detuning, and other perturbations.

### 5.2 Hardware Architecture — VXI Crate

The LLRF controller is housed in a 13-slot VXI mainframe in Building B132. The crate contains the following modules:

| Slot | Module | Make/Model | Function |
|------|--------|------------|----------|
| 0 | CPU | Kinetics Systems V152 (Motorola PPC604) | VxWorks RTOS, EPICS IOC, SNL programs |
| 1 | AB DCM | Allen-Bradley 1747-DCM | Serial communication to PLCs and stepper modules |
| 2 | CLK | Custom SLAC PEP-II design | Master oscillator distribution, LO generation (471.1 MHz), IF generation (4.9 MHz) |
| 3 | (Empty) | — | Originally GVF module (PEP-II); not installed in SRF1 |
| 4 | RFP | Custom SLAC PEP-II RF Processor | Central feedback processing: I/Q modulation/demodulation, analog direct loop, DAC control, ripple loop |
| 5 | (MPS Shutoff) | — | Not a full VXI module; provides MPS shutoff function |
| 6 | IQA1 | Custom SLAC PEP-II I/Q Acquisition | Monitors klystron drive forward I/Q |
| 7 | IQA2 | Custom SLAC PEP-II I/Q Acquisition | Monitors klystron output I/Q |
| 8 | IQA3 | Custom SLAC PEP-II I/Q Acquisition | Monitors cavity probe I/Q (configurable channel assignment) |
| 9 | AIM | Custom SLAC PEP-II Arc Interface Module | Arc detection input, fast interlock interface, fault history buffer |
| 10–12 | (Empty/spare) | — | Available for expansion |

> **📷 PHOTO PLACEHOLDER**: VXI crate with module positions labeled
> **📷 PHOTO PLACEHOLDER**: RFP module front panel showing RF connectors and status indicators

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §2.1; `llrf/documentation/legacyArchitecture/technical-notes/02_VXI_HARDWARE_MODULE_REFERENCE.md`; `spear-rf-code-legacy/codeReviewTechnicalNotes/03-vxi-device-support.md`

### 5.3 RF Processor (RFP) Module — Heart of the System

The RFP module is the most critical hardware component. It implements all fast RF feedback in analog circuitry:

**Signal Processing Chain**:
1. **RF Input**: Cavity probe signals (476.315 MHz) enter the RFP
2. **I/Q Demodulation**: Mixed down to IF (4.9 MHz) using LO from Clock module (471.1 MHz), then digitally demodulated to baseband I and Q components
3. **Error Computation**: I/Q error = measured − setpoint (setpoints come from Octal DACs)
4. **Direct Loop**: Proportional + integral analog feedback applied to error signal
5. **Lead Compensation**: Additional phase margin for stability
6. **Integral Compensation**: Long-time-constant integration for zero steady-state error
7. **Ripple Loop**: Narrowband 720 Hz rejection loop for AC power line harmonic
8. **I/Q Modulation**: Corrected signal modulated back to 476 MHz for drive amplifier input

**Key Characteristics**:
- Loop delay: ~1 µs (limited by cable propagation and analog processing)
- Direct loop impedance reduction: ~40 dB (factor of ~100)
- Direct loop bandwidth: ~800 kHz
- Octal DAC resolution: 12-bit (±2048 counts)
- Operating modes: TUNE (open loop / manual setpoint) and OPERATE (closed loop / cavity field control)

The RFP module provides a **Run Mode** control that switches between TUNE and OPERATE, and an **RF Switch** that enables/disables the RF output to the drive amplifier.

> **Source**: `Designs/obsolete/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` §2.2, §9; `llrf/documentation/legacyArchitecture/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md`; `spear-rf-code-legacy/codeReviewTechnicalNotes/03-vxi-device-support.md`

### 5.4 IQA Modules — Signal Monitoring

Three IQA (I/Q Acquisition) modules provide digitized measurements of RF signals:

| IQA | Assignment | Measures |
|-----|------------|----------|
| IQA1 | Klystron drive | Drive forward I/Q → amplitude and phase |
| IQA2 | Klystron output | Forward power I/Q → klystron operating point |
| IQA3 | Cavity probe | Cavity field I/Q → gap voltage and load angle |

Each IQA module:
- Receives 476.315 MHz RF signal from directional couplers
- Mixes with LO (471.1 MHz) to produce IF (4.9 MHz)
- Digitizes I and Q components via dual ADCs
- Reports amplitude (√(I² + Q²)) and phase (arctan(Q/I)) to EPICS
- Provides data for the subroutine calculations in `subIQ.c` and `subSys.c`

IQA3 has a configurable channel assignment for monitoring different cavity probe signals, set via the `IQA3MACROS` environment variable during IOC boot.

> **Source**: `spear-rf-code-legacy/codeReviewTechnicalNotes/03-vxi-device-support.md`; `spear-rf-code-legacy/codeReviewTechnicalNotes/08-signal-processing.md`

### 5.5 Clock Module

The Clock module generates and distributes the frequency reference signals:

| Signal | Frequency | Purpose |
|--------|-----------|---------|
| RF Reference | 476.315 MHz | Master oscillator distribution |
| LO | 471.1 MHz | Local oscillator for I/Q demodulation |
| IF | 4.9 MHz | Intermediate frequency (f_RF − f_LO) |
| ADC Clock | Derived | Sampling clock for IQA digitizers |

The Clock module contains a PLL (Phase-Locked Loop) that generates the LO and IF frequencies from the incoming RF reference. It must initialize **before** the VXI resource manager runs during IOC boot — a critical boot-order dependency.

> **Source**: `spear-rf-code-legacy/codeReviewTechnicalNotes/02-architecture-overview.md` §2.1; `llrf/documentation/legacyArchitecture/technical-notes/02_VXI_HARDWARE_MODULE_REFERENCE.md`

### 5.6 Arc Interface Module (AIM)

The AIM provides the interface between the VXI crate and the external interlock/arc detection hardware:

- **Inputs**: Arc detection signals from waveguide photodiodes (fiber-optic)
- **Outputs**: Fast interlock chain status to the rest of the VXI system
- **Functions**: Fault history buffer (captures the sequence of events leading to a trip), beam abort force/reset, filament control interface, HVPS permissive
- **Status**: The arc detection function has been **non-functional** for an extended period (see §12)

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §2.1; `spear-rf-code-legacy/codeReviewTechnicalNotes/03-vxi-device-support.md`

---

## 6. Subsystem S2: High Voltage Power Supply (HVPS)

### 6.1 Purpose

The HVPS converts 12.47 kV three-phase AC utility power into −77 kV DC to power the klystron cathode. It is a 1.7 MW nominal (2.5 MW maximum capability) power conversion system.

### 6.2 Power Topology

The HVPS uses a **12-pulse thyristor phase-controlled rectifier** with a star point controller configuration:

```
12.47 kV 3φ AC (Substation 507, Breaker 160)
     │
     ▼
Phase-Shift Transformer T0 (3.5 MVA)
     │  Creates ±15° phase offset → 12-pulse
     ├──────────────────────┐
     ▼                      ▼
Rectifier Xfmr T1 (+15°)   Rectifier Xfmr T2 (−15°)
     │ 1.5 MVA each         │
     ▼                      ▼
6-Pulse SCR Bridge          6-Pulse SCR Bridge
(SCR1-6, 14 per stack)     (SCR7-12, 14 per stack)
     │                      │
     ▼                      ▼
Filter Inductors L1, L2 (0.3 H, 85 A)
     │
     ▼
Secondary Rectifier Bridges (4 in series, 24 diodes)
     │
     ▼
Filter Capacitor Bank (8 µF, ~24 kJ)
     │
     ▼
Crowbar Protection (4 SCR stacks, fiber-optic trigger)
     │
     ▼
Cable Termination Inductors (L3, L4, 200 µH)
     │
     ▼
−77 kV DC Output → Klystron Cathode
```

**Key Power Parameters** (measured June 2020):

| Parameter | Measured | Design Maximum |
|-----------|----------|----------------|
| Output Voltage | 72.08 kV | 90 kV |
| Output Current | 19.4 A | 27 A |
| Power | 1.398 MW | 2.5 MW |
| Firing Angle (α) | ~36.8° | 0°–180° |
| Voltage Ripple | <0.2% RMS | <1% p-p |
| Regulation | ±0.5% (>65 kV) | — |

**System Configuration**: Two HVPS units exist (SPEAR1 active, SPEAR2 warm spare), providing operational redundancy.

> **📷 PHOTO PLACEHOLDER**: HVPS main transformer area (T0, T1, T2) in B514
> **📷 PHOTO PLACEHOLDER**: SCR stack assembly showing thyristor modules
> **📷 PHOTO PLACEHOLDER**: Crowbar SCR stacks and snubber networks

> **Source**: `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md`; `hvps/architecture/originalDocuments/transcriptions/slac-pub-7591_transcription.md`; `hvps/architecture/technical-notes/06-design-notes-synthesis.md`

### 6.3 HVPS Controller — Hoffman Box (B118)

The HVPS controller is housed in a Hoffman NEMA enclosure in Building B118 and contains:

**PLC System**:
- **Processor**: Allen-Bradley SLC-5/03 (AB-1747-L532) — **obsolete, end-of-life**
- **Scanner**: Allen-Bradley 1747-DCM — serial communication to VXI crate
- **I/O Modules** (9 slots): Digital input, digital output, analog input, analog output modules
- **Functions**: Voltage regulation, contactor control, safety interlocks, status reporting

**Enerpro SCR Firing System**:
- **Firing Board**: Enerpro FCOG1200 — 12-pulse SCR firing controller
- **Control Signal**: 0–10 VDC analog from PLC → Enerpro → SCR gate pulses
- **Phase Control**: 0°–180° firing angle control for voltage regulation
- **Auto-Balance**: Built-in current balance between the two 6-pulse bridges

**Regulator Board**:
- **Part Number**: PC-237-230 (custom SLAC design, documented as SD-237-230-14-C1)
- **Function**: Conditions feedback signals, provides voltage/current sense to PLC
- **Voltage Divider**: 1000:1 ratio for HVPS output voltage monitoring

**Power Supplies**:
- Kepco units providing regulated DC for control electronics
- SOLA isolation transformer for PLC power
- 24 VDC supply for relay logic

> **📷 PHOTO PLACEHOLDER**: Hoffman Box interior showing PLC, Enerpro board, regulator card, and terminal strips
> **📷 PHOTO PLACEHOLDER**: Enerpro FCOG1200 firing board close-up
> **📷 PHOTO PLACEHOLDER**: PLC rack with I/O modules labeled

> **Source**: `hvps/documentation/plc/technical-notes/01-system-overview.md`; `hvps/controls/enerpro/technical-notes/00-system-overview.md`; `hvps/architecture/technical-notes/04-regulator-board-design.md`

### 6.4 Arc Protection — 4-Layer System

The HVPS incorporates a multi-layer arc protection system (inherited from PEP-II design):

| Layer | Component | Response Time | Function |
|-------|-----------|---------------|----------|
| 1 | Isolation Resistors (500 Ω) | Instantaneous | Limits capacitor discharge current during tube arcs (PEP-II innovation) |
| 2 | Crowbar SCR Stacks (4 series) | ~1 µs (fiber-optic trigger) | Dumps stored energy through low-impedance path |
| 3 | Cable Termination Inductors (L3, L4) | Passive | Reduces cable discharge current rate of rise |
| 4 | PLC-Controlled Contactor | ~100 ms | Opens primary 12.47 kV contactor to remove input power |

The crowbar is triggered by fiber-optic signals and fires in <1 µs — fast enough to protect the klystron from stored-energy discharge damage. The 500 Ω isolation resistors limit the initial current surge from the 8 µF capacitor bank before the crowbar fires.

> **Source**: `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md`; `hvps/architecture/originalDocuments/transcriptions/slac-pub-7591_transcription.md`

### 6.5 HVPS Monitoring Signals

Four monitoring signals are routed from B514 to B118:

| Signal | Measurement | Purpose |
|--------|-------------|---------|
| HVPS Output Voltage | DC voltage divider (1000:1) | Voltage regulation feedback |
| HVPS Output Current | Danfysik DC-CT | Current monitoring and protection |
| Inductor 2 Voltage | T2 bridge timing | Firing circuit health verification |
| Transformer 1 Phase Current | T1 circuit | Firing circuit balance verification |

> **Source**: `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md`; `hvps/architecture/technical-notes/05-system-integration-notes.md`

---

## 7. Subsystem S3: RF Machine Protection System (RF MPS)

### 7.1 Purpose

The RF MPS protects the klystron and RF station equipment from damage due to faults. It is distinct from the facility-wide SPEAR MPS (which provides an external permit input) — the RF MPS is concerned solely with the RF station's own equipment protection.

### 7.2 Hardware

- **Original PLC**: Allen-Bradley PLC-5 (1771 series) — **obsolete**
- **Upgraded PLC**: ControlLogix 1756 (hardware assembled, software written, tested without RF power as of 2026)
- **Location**: B118, separate rack from HVPS controller

### 7.3 Protection Functions

The RF MPS monitors and responds to:

| Fault Condition | Detection Method | Response |
|-----------------|------------------|----------|
| Reflected power high | Directional coupler + detector | Fast RF shutoff |
| Forward power high | Directional coupler + detector | HVPS voltage reduction |
| Arc detected | Waveguide photodiodes → AIM | Crowbar + RF shutoff |
| VSWR limit exceeded | Calculated from forward/reflected | RF shutoff |
| Vacuum failure | ION pump current monitors | Beam abort + RF shutoff |
| HVPS overcurrent | Current transducer (Danfysik) | Crowbar + contactor open |
| HVPS overvoltage | Voltage divider feedback | Firing angle limit |
| Cooling water failure | Temperature/flow sensors | Orderly shutdown |
| External MPS trip | SPEAR MPS permit signal | RF shutoff |

### 7.4 Interface

The RF MPS communicates with the VXI LLRF controller via the Allen-Bradley serial network. It receives configuration commands and reports fault status. The MPS also has direct hardwired interlock connections to the HVPS for safety-critical functions (crowbar trigger, contactor control) that do not depend on the serial communication link.

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §7; `hvps/architecture/designNotes/RFSystemMPSRequirements.docx`; `llrf/documentation/mpsWiringDiagrams/`

---

## 8. Subsystem S4: Distributed Interlock System (Interface Chassis Predecessor)

### 8.1 Legacy Architecture

The legacy system does **not** have a centralized Interface Chassis. Instead, interlock functions are distributed across multiple subsystems:

| Function | Legacy Implementation |
|----------|----------------------|
| Fast RF interlock | AIM module in VXI crate + direct wiring |
| HVPS interlock | PLC-5 (MPS) + SLC-500 (HVPS controller) relay logic |
| Arc detection interlock | Fiber optic inputs to AIM module |
| PPS interface | Terminal strips in Hoffman Box (see §9) |
| Contactor control | Relay chain in switchgear controller |
| Crowbar trigger | Fiber optic from interlock chassis to B514 |

**Local Control Chassis**: A small chassis in B132 that aggregates local interlock signals (water flow, temperature, vacuum) and feeds them to the AIM module.

**Fast Interlock Chassis**: A separate chassis that receives the arc detection fiber optic signals and communicates interlock status to the AIM module.

### 8.2 Limitations of Distributed Architecture

- No single point where all interlock states can be observed simultaneously
- Interlock logic is split between PLC software, relay hardware, and VXI module firmware
- No hardware-based first-fault detection — fault ordering must be reconstructed from timestamps
- No standardized interlock signal format (mix of TTL, relay contacts, fiber optic, analog thresholds)
- Adding or modifying an interlock requires understanding multiple subsystems

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §2.1, §8; `Designs/obsolete/11_INTERFACE_CHASSIS_DESIGN.md`

---

## 9. Subsystem S5: Personnel Protection System (PPS) Interface

### 9.1 Purpose

The PPS interface ensures that high voltage is removed from the HVPS and the klystron is safe before personnel can enter the RF station or high-voltage areas. It interfaces with the SLAC/SSRL Personnel Protection System (the facility-wide radiation safety system).

### 9.2 Legacy PPS Architecture

The PPS uses a GOB12-88PNE connector for its interface and controls two independent safety chains:

**Chain 1 — HV Contactor (removes input power)**:
```
PPS Enable 1 (Pin E→F) → SLC-500 PLC (Slot-6 IB16, Input 14)
    → PLC Rung 0017 → Slot-5 OX8 OUT2 → Terminal Strip TS-5
    → Cable (Belden 83715) → K4 Relay (PPS Control)
    → MX Relay → L1 Holding Coil → Contactor opens

Readback: S5 NC Auxiliary Contact → TS-5 Pins 14,15
    → GOB12-88PNE Readback Pins A-B
```

**Chain 2 — Ross Grounding Switch (grounds HVPS output)**:
```
PPS Enable 2 (Pin G→H) → SLC-500 PLC (Slot-6 IB16, Input 15)
    → PLC Rung 0016 → Slot-2 IO8 OUT3 (120 VAC)
    → Terminal Strip TS-6 → Cable (Belden 83709)
    → Ross Grounding Switch coil

Readback: Ross Switch NC Auxiliary Contact → TS-6 Pins 11,12
    → GOB12-88PNE Readback Pins C-D
```

> **📷 PHOTO PLACEHOLDER**: PPS interface connector (GOB12-88PNE) on Hoffman Box
> **📷 PHOTO PLACEHOLDER**: Terminal strips TS-5 and TS-6 inside Hoffman Box showing PPS wiring
> **📷 PHOTO PLACEHOLDER**: Ross Engineering grounding switch in termination tank

### 9.3 Identified PPS Compliance Issues

Multiple compliance issues have been identified and documented (Jim Sebek, 2022; Ben Morris, March 2026):

| Issue | Description | Risk |
|-------|-------------|------|
| **⚠️ PLC in Safety Chain** | Ross grounding switch is controlled by PLC (Rung 0016). PPS command must pass through PLC logic to activate the safety device. | PLC failure could prevent safety function |
| **⚠️ PPS Wiring Exposure** | PPS wires terminate on TS-5 and TS-6 inside the HVPS controller Hoffman Box. Opening the Hoffman Box door exposes PPS wiring. | Requires RSWCF to work on HVPS controller |
| **⚠️ Limited Status Display** | Single indicator light; does not clearly show both PPS channels independently. | Operator cannot verify independent channel status |
| **⚠️ Emergency-Off Coupling** | PPS interface is tied into the emergency-off circuit. | Violates current PPS design rules |
| **⚠️ Accessible PPS Cable** | PPS control cable inside Hoffman Box can be unplugged by anyone who opens the door. | Unauthorized access risk |

**Hardware Fail-Safe Note**: Despite the PLC dependency, the Slot-5 OX8 OUT2 output that controls K4 uses PPS 1 (24 VDC) as its input-side power source. This means K4 **cannot** be energized without PPS enable, even if the PLC fails. However, the Ross switch chain (Chain 2) has no equivalent fail-safe — it depends entirely on PLC logic.

### 9.4 Vacuum Contactor Controller (Switchgear)

The 12.47 kV vacuum contactor is controlled by a dedicated switchgear controller panel:

**Key Components**:
- **Vacuum Contactor**: Ross Engineering Model HQ3 — high-voltage vacuum contactor
- **K4 Relay**: PPS control relay (energizes when PPS permits)
- **MX Relay**: External control relay
- **RR Relay**: Reset relay
- **L1 Holding Coil**: Maintains contactor closed
- **S5 Auxiliary Contact**: NC contact provides PPS readback

**Correction Note**: Earlier documentation had K4 and RR relay functions swapped. K4 is the PPS control relay (not reset); RR is the reset relay (not PPS). This error has been corrected in the current PPS diagrams.

> **Source**: `pps/diagrams/00_SYSTEM_OVERVIEW.md`; `pps/diagrams/01_gp4397040201_vacuum_contactor_controller.md`; `pps/diagrams/02_rossEngr713203_vacuum_contactor_driver.md`; `pps/pps_Ben.md`; `pps/MSG from Jim Sebek to Faya about PPS.md`

---

## 10. Subsystem S6: Tuner Control System

### 10.1 Purpose

Each of the four RF cavities has a mechanical tuner that adjusts the cavity resonant frequency. The tuner compensates for beam loading effects (which shift the cavity's optimal frequency) by physically moving a plunger in/out of the cavity. The goal is to maintain near-zero reactive beam loading — keeping the cavity tuned so that the klystron sees a resistive load.

### 10.2 Hardware

| Component | Model | Specification |
|-----------|-------|---------------|
| Stepper Motor | Superior Electric Slo-Syn M093-FC11 | NEMA 34D frame |
| Motor Driver | Superior Electric SS2000MD4-M | PWM Slo-Syn translator — **obsolete** |
| Controller | Allen-Bradley 1746-HSTP1 | PLC stepper module (4 instances, one per cavity) — **obsolete** |
| Tuner Mechanism | PEP-II design | Mechanical plunger, ~0.002–0.003 mm/microstep resolution |

### 10.3 Control Algorithm

The tuner loop operates as a slow control loop (~0.1 Hz bandwidth):

1. **Measurement**: Read cavity probe phase and klystron drive phase from IQA modules
2. **Load Angle Calculation**: Compute load angle error = measured phase − ideal phase (uses `subIQ.c` calculation subroutines)
3. **Deadband Check**: If load angle error > deadband threshold (configurable `RDBD`), initiate move
4. **Move Command**: Issue stepper motor move command via Allen-Bradley serial link
5. **Settle Wait**: Wait for motor to reach target position (motor done signal)
6. **Verify**: Check that load angle error decreased

The tuner has **three behavioral modes** within its ON state (these are algorithmic modes, not separate SNL states):
- **TRACKING**: Monitoring load angle, waiting for error to exceed deadband
- **MOVING**: Motor move in progress, waiting for motion complete
- **SETTLING**: Post-move settling period, waiting for cavity transient to die down

**Special Behaviors**:
- In PARK mode, tuners move to a predetermined "park home" position
- In ON states, tuners move to "on home" position initially, then track load angle
- Maximum loop idle time: 60 seconds (tuner processes at least once per minute even without events)

> **Source**: `Designs/obsolete/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` §8; `spear-rf-code-legacy/codeReviewTechnicalNotes/05-snl-state-machines.md` §4; `spear-rf-code-legacy/codeReviewTechnicalNotes/06-plc-stepper-motors.md`; `llrf/tuners/`

---

## 11. Subsystem S7: Waveform Capture (Legacy Diagnostic Baseline)

### 11.1 Legacy Waveform Capabilities

The legacy system has **limited** waveform capture capability compared to the planned upgrade:

| Capability | Legacy System | Upgrade (for reference) |
|------------|---------------|------------------------|
| VXI History Buffers | AIM fault history buffer (limited depth) | 16,384 samples/channel |
| HVPS Waveforms | 4-channel oscilloscope monitoring at B118 | Dedicated waveform buffer system |
| RF Signal Capture | No continuous circular buffer | Circular buffer + triggered capture |
| First-Fault Record | Software-based timestamp reconstruction | Hardware-based first-fault register |

The legacy system relies on the VXI AIM module's fault history buffer for post-trip analysis. This buffer has limited depth and cannot capture long pre-trigger windows. HVPS waveforms are monitored using standalone oscilloscope equipment at B118, which requires manual configuration for each diagnostic session.

### 11.2 No Dedicated Waveform Buffer

The legacy system does not have a dedicated waveform buffer subsystem. The upgrade introduces a purpose-built Waveform Buffer System (see Doc 0 §11) with 8 RF channels and 4 HVPS channels, providing 100 ms of pre-trigger waveform capture for HVPS signals and 16k-sample depth for RF signals.

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §11; `llrf/architecture/WaveformBuffersforLLRFUpgrade.docx`

---

## 12. Subsystem S8: Arc Detection System

### 12.1 Purpose

The arc detection system is intended to detect electrical arcs in the waveguide distribution network. Waveguide arcs can damage components and must be detected and responded to within microseconds to prevent equipment damage.

### 12.2 Legacy Implementation

The legacy arc detection system uses **photodiode-based sensors** at waveguide windows and junctions. Optical signals from the photodiodes are transmitted via fiber optic to the AIM (Arc Interface Module) in the VXI crate, which feeds into the fast interlock chain.

**Current Status**: The arc detection system has been **non-functional** for an extended period. The photodiode sensors and fiber optic links have degraded to the point where they no longer reliably detect arcs. The system remains wired into the AIM module but does not provide effective protection.

### 12.3 Impact of Non-Functional Arc Detection

Without arc detection, the system relies on other protection mechanisms (reflected power monitoring, HVPS crowbar, vacuum interlocks) to protect against waveguide arc damage. These alternative mechanisms are slower than dedicated arc detection and may not catch all arc events before damage occurs.

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §12; `llrf/architecture/arcDetectorHardwareOptions.docx`; `llrf/arcDetector/`

---

## 13. Subsystem S9: Klystron Cathode Heater

### 13.1 Purpose

The klystron cathode heater provides controlled AC power to the klystron cathode, enabling thermionic electron emission necessary for klystron operation. The cathode must be heated to operating temperature (~1000°C) before the HVPS can be enabled.

### 13.2 Circuit Architecture

The heater uses a motor-driven variac (continuously variable autotransformer) with a step-down isolation transformer:

```
120 VAC Phase C (Hoffman Box, B118)
     │
     ▼
10A Fuse / Breaker (TB1)
     │
     ▼
Solid-State Relay (FILAMENT_ON control)
     │
     ▼
Variac V1 (1.0 KVA, 0–140 VAC output)
     │
     ├── Motor M1 (UP/DOWN with limit switches)
     │
     ▼
Toroidal Transformer T1 (10:1 step-down)
     │
     ▼
Filament Output (~6.8 V RMS, ~73 A) → Klystron Cathode
```

**Key Parameters**:

| Parameter | Value |
|-----------|-------|
| AC Input | 120 VAC, 60 Hz (Phase C) |
| Maximum Power | ~1 kW |
| Nominal Operating Power | ~500 W |
| Nominal Operating Voltage | 68 V AC (at transformer input) |
| Nominal Operating Current | 7.3 A (primary) |
| Transformer Ratio | 10:1 step-down |
| Secondary Output | ~6.8 V RMS at ~73 A |
| Thermal Headroom | 2:1 (500W nominal / 1000W maximum) |

### 13.3 Control Interface

The heater is controlled remotely via the Allen-Bradley PLC through a fiber-optic interface link between B118 and B132:

- **FILAMENT_ON**: Digital command to enable/disable the solid-state relay
- **MOTOR-UP / MOTOR-DOWN**: Digital commands to drive the variac motor
- **UP/DOWN LIMIT**: Limit switch feedback from the variac mechanism
- **V_MON**: Voltage monitoring (transformer input, via voltage divider)
- **A_MON**: Current monitoring (Texmate CT on secondary)

**Front Panel Indicators**: DS1 and DS2 green LEDs, AC voltmeter, AC ammeter, and an elapsed-time meter for cathode hours tracking.

### 13.4 Operational Sequence

1. **Cold Start / Pre-Heat**: Heater energized, cathode ramps to ~1000°C over ~30 minutes
2. **Ready**: Heater at nominal power, "FILAMENT ON" status reported to MPS
3. **HVPS Enable**: Only permitted when heater status = READY (MPS interlock)
4. **Normal Operation**: Heater maintains cathode temperature during RF operation
5. **Normal Shutdown**: HVPS off → heater **remains on** (for quick recovery)
6. **Maintenance Shutdown**: HVPS off → gradual heater power reduction (extended outages only)

The heater is kept ON during normal shutdowns to maintain cathode temperature, allowing rapid restart without the 30-minute warmup period.

> **📷 PHOTO PLACEHOLDER**: Filament heater assembly in B132 showing variac, transformer, and front panel
> **📷 PHOTO PLACEHOLDER**: Filament heater front panel with meters and indicators

> **Source**: `llrf/documentation/filamentHeater/FILAMENT_HEATER_TECHNICAL_NOTES.md`; `Designs/0_SYSTEM_DESIGN_REPORT.md` §13

---

## 14. Subsystem S10: Control Software

### 14.1 Overview

The legacy control software runs on a VxWorks RTOS (Real-Time Operating System) on a Motorola PPC604 processor in the VXI crate's CPU module. It uses the EPICS (Experimental Physics and Industrial Control System) framework, version R3.13.x, with custom device support for the VXI hardware modules.

### 14.2 Codebase Scale

| Category | Files | Lines | Description |
|----------|-------|-------|-------------|
| VXI Driver + Device Support | ~20 | ~18,000 | Custom EPICS device support for RFP, IQA, CLK, AIM, GVF, CFM modules |
| Custom Record Types | 7 | ~2,200 | p2RfRfp, p2RfIqa, p2RfAim, p2RfClk, p2RfGvf, p2RfCfm, p2RfCf2 |
| SNL State Machines | 6 + 12 headers | ~8,200 | Core control logic (see §14.3) |
| DSP Firmware | ~100 | ~16,700 | AT&T DSP1610/TI TMS320C16xx assembly |
| PLC/Stepper Drivers | ~20 | ~7,000 | Allen-Bradley communication drivers |
| EPICS Databases | 78+ | ~15,000 | Record definitions, substitution files |
| Signal Processing | 2 | ~1,430 | subIQ.c (23 functions), subSys.c (11 functions) |
| PEP-II Only Modules | ~30 | ~10,000 | Not used in SPEAR3 (GVF, CFM, CF2, LFB) |
| Infrastructure/Build | ~60 | ~15,000 | VxWorks utilities, build system, Makefiles |
| **Total** | **253** | **~82,430** | |

> **Source**: `spear-rf-code-legacy/codeReviewTechnicalNotes/00-executive-summary.md`; `spear-rf-code-legacy/codeReviewTechnicalNotes/01-file-inventory.md`

### 14.3 SNL State Machine Programs

The core control logic is implemented as **6 SNL (State Notation Language) programs** compiled into a single VxWorks shared library (`rfSeq`):

| Program | Lines | Author(s) | Function |
|---------|-------|-----------|----------|
| `rf_states.st` | 2,227 | R.C. Sass, S. Allison, M. Laznovsky (1997–2004) | Master station state machine — sequences OFF → PARK → TUNE → ON_FM → ON_CW with 23 SNL states across 3 concurrent state sets |
| `rf_hvps_loop.st` | 343 | M. Zelazny, S. Allison, R.C. Sass (1997–1999) | HVPS voltage regulation — adjusts klystron cathode voltage to maintain gap voltage setpoint |
| `rf_dac_loop.st` | 290 | S. Allison (1997) | DAC control — adjusts RFP Octal DAC setpoints for drive power and gap voltage |
| `rf_tuner_loop.st` | 555 | S. Allison (1996–1999) | Cavity tuner control — drives stepper motors to minimize load angle error (4 instances, one per cavity) |
| `rf_calib.st` | 3,345 | R. Claus, P. Corredoura, M. Laznovsky (1997–2005) | Automated calibration — 28 hand-written states for IQ offset nulling and matrix calibration |
| `rf_msgs.st` | 352 | S. Allison, R.C. Sass (1997–2000) | Message logging — fault recording and VXI TAXI error monitoring/recovery |

Each program is parameterized via EPICS macros (`STN`, `CAV`, `name`, `RING`, `REG`, `IOC`) allowing a single codebase to serve multiple station instances (though only SRF1 is used at SPEAR3).

> **For code-level detail**: See `spear-rf-code-legacy/codeReviewTechnicalNotes/05-snl-state-machines.md`

### 14.4 Station State Machine

The station operates in 5 major operating modes, with transitions managed by the master state machine:

```
                 STATION STATE DIAGRAM
  
  OFF ──────────► PARK ──────────► TUNE
   ▲               │                 │
   │               │                 │
   │    ◄──────────┘                 ▼
   │                              ON_FM
   │                                 │
   │                                 ▼
   └──────────────────────────── ON_CW
                  (fault/shutdown)
```

| State | Value | Description |
|-------|-------|-------------|
| OFF | 0 | All systems inactive, RF switch off |
| PARK | 1 | VXI hardware initialized, PLCs communicating, no RF output |
| TUNE | 2 | Low-power RF on (TUNE mode), klystron warm-up, tuner calibration |
| ON_FM | 3 | Full power, frequency modulated (transitional state for HVPS ramp-up) |
| ON_CW | 4 | Full power, continuous wave — normal operating state |

**Transition Sequences**: Moving between states involves complex multi-step sequences (e.g., PARK → TUNE requires enabling the RF switch, setting RFP to TUNE mode, engaging direct loop, enabling lead and integral compensation). The state machine orchestrates these sequences and handles fault conditions at each step.

> **Source**: `Designs/obsolete/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` §5; `spear-rf-code-legacy/codeReviewTechnicalNotes/05-snl-state-machines.md` §2

### 14.5 Signal Processing Subroutines

Two C source files provide mathematical calculations used by EPICS subroutine records:

**`subIQ.c`** (23 functions, 965 lines):
- I/Q coordinate transformations
- Amplitude and phase calculations
- Load angle computation
- Power calculations from directional coupler signals
- Cavity gap voltage computation

**`subSys.c`** (11 functions, 464 lines):
- System-level calculations (gap voltage sum, drive power balance)
- Status aggregation and alarm computation
- Interlock threshold evaluations

These files are candidates for **direct reuse** in the upgrade system, as the underlying physics calculations remain valid.

> **Source**: `spear-rf-code-legacy/codeReviewTechnicalNotes/08-signal-processing.md`

### 14.6 DSP Firmware

The legacy system includes DSP firmware for the AT&T DSP1610/TI TMS320C16xx processors used in the RFP and GVF modules. The firmware implements:

- Real-time signal processing (I/Q filtering, amplitude/phase extraction)
- Gap transient compensation (GVF module — PEP-II only, not used at SPEAR3)
- Waveform observation and data collection

The DSP firmware is written in assembly language (~16,700 lines across ~100 files) and is completely eliminated in the upgrade (replaced by LLRF9 FPGA processing).

> **Source**: `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md`

### 14.7 IOC Boot Sequence

The EPICS IOC boot follows a specific initialization order with critical dependencies:

1. VxWorks kernel boot (PPC604)
2. Load application binary (`rf.munch`)
3. Set station macros via `putenv()` (STN=SRF1, tuner macros, etc.)
4. Load database definition (`rf.dbd`)
5. Load EPICS records (`srf1.db` via substitution files)
6. **Clock module PLL initialization** (must happen before VXI resource manager)
7. Allen-Bradley scanner configuration
8. VXI address space configuration and resource manager scan
9. `iocInit()` — module discovery, device support initialization, DSP firmware loading
10. Interrupt enable and CA server start

> **For detailed boot sequence**: See `spear-rf-code-legacy/codeReviewTechnicalNotes/02-architecture-overview.md` §2.1

---

## 15. EPICS Process Variable Architecture

### 15.1 PV Naming Convention

All process variable (PV) names follow the EPICS macro substitution scheme inherited from PEP-II:

| Macro | Value | Meaning |
|-------|-------|---------|
| `STN` | `SRF1` | Station identifier (SPEAR RF Station 1) |
| `CAV` | `1`–`4` | Cavity number |
| `RNG` | `SPEAR` | Ring identifier |
| `RING` | `SPEAR` | Ring identifier (alternate macro) |
| `REG` | `1` | Region number |
| `IOC` | `SRF1` | IOC identifier |

### 15.2 PV Namespace by Subsystem

**Station Control** (from `rf_states.st`):
- `SRF1:STN:STATE:RBCK` — Station state readback (0=OFF, 1=PARK, 2=TUNE, 3=ON_FM, 4=ON_CW)
- `SRF1:STN:STATE:CTRL` — Station state control command
- `SRF1:STN:RESET` — Station reset trigger

**VXI Module Records** (from custom device support):
- `SRF1:RFP:*` — RF Processor (TUNE/OPERATE mode, RF switch, direct loop, DACs)
- `SRF1:IQA1:*`, `SRF1:IQA2:*`, `SRF1:IQA3:*` — I/Q Acquisition modules
- `SRF1:AIM:*` — Arc Interface Module
- `SRF1:CLK:*` — Clock Module
- `SRF1:GVF:*` — Gap Voltage Feed-Forward (PEP-II — databases loaded but hardware absent)
- `SRF1:CF2:*` — Comb Filter v2 (PEP-II — databases loaded but hardware absent)

**HVPS Control** (from `rf_hvps_loop.st`):
- `SRF1:HVPS:VOLT` — Monitored voltage (actual measurement)
- `SRF1:HVPS:VOLT:RBCK` — Desired voltage readback (echoes setpoint)
- `SRF1:HVPS:VOLT:CTRL` — Desired voltage setpoint (operator command)
- `SRF1:HVPS:VOLT:LOOP` — Loop last-commanded voltage
- `SRF1:HVPS:VOLT:MIN` — Minimum allowed voltage
- `SRF1:HVPS:LOOP:STATUS` — HVPS loop status code (0–15)
- `SRF1:CONT:CLOSE` / `SRF1:CONT:OPEN` — Contactor commands

**DAC Loop** (from `rf_dac_loop.st`):
- `SRF1:STNDAC:LOOP:STATUS` — DAC loop status code (15 states)
- `SRF1:STNDRV:*` — Station drive parameters
- `SRF1:STNGAP:*` — Station gap voltage parameters

**Tuner Control** (from `rf_tuner_loop.st`, per-cavity):
- `SRF1:CAV{N}TUNR:LOOP:STATE` — Tuner state (0=OFF, 1=PARK, 2=ON)
- `SRF1:CAV{N}TUNR:LOOP:STATUS` — Tuner status code (0–13)
- `SRF1:CAV{N}TUNR:POSN` — Tuner position readback
- `SRF1:CAV{N}TUNR:POSN:CTRL` — Tuner position setpoint
- `SRF1:CAV{N}LOAD:ANGLE:ERR` — Load angle error

**RF Measurements** (from `subIQ.c` / `subSys.c` subroutine records):
- `SRF1:KLYSOUTFRWD:POWER` — Klystron forward power
- `SRF1:KLYSDRIVFRWD:POWER` — Klystron drive forward power
- `SRF1:CAV{N}LOAD:ANGLE:*` — Load angle calculations
- `SRF1:CAV{N}:PHASE:*` — Cavity phase calculations
- `SRF1:CAV{N}:GAPV:*` — Gap voltage calculations

*(Where `{N}` = 1, 2, 3, or 4 for the four cavities)*

### 15.3 Upgrade PV Migration Importance

The PV naming convention is deeply embedded in:
- **Operator displays** (MEDM/EDM screens in `llrf/llrf9/iGp/dl_llrf/` and `llrf/llrf9/iGp/dl_8/`)
- **EPICS archiver** configuration
- **Alarm handler** configuration
- **Higher-level applications** across the facility
- **MATLAB analysis tools**

Changing PV names carries the highest disruption risk of any upgrade activity. The upgrade plan must either preserve exact PV names or provide a comprehensive alias/gateway mapping.

> **Source**: `spear-rf-code-legacy/codeReviewTechnicalNotes/02-architecture-overview.md` §1; `spear-rf-code-legacy/codeReviewTechnicalNotes/07-epics-databases.md`; `Designs/obsolete/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` Appendix B

---

## 16. Protection and Interlock Architecture

### 16.1 Protection Hierarchy

The legacy protection system operates at multiple timescales:

| Layer | System | Response Time | Mechanism |
|-------|--------|---------------|-----------|
| **Fastest** | RFP analog interlocks | ~µs | Hardware trip directly in RFP module |
| **Fast** | AIM + fiber optic | ~µs | Arc detection → crowbar trigger via fiber |
| **Medium** | RF MPS PLC | ~ms | PLC-5 software (fault evaluation → interlock output) |
| **Slow** | SNL state machine | ~seconds | Software fault detection, orderly shutdown |
| **Safety** | PPS | N/A | Personnel protection (independent of control system) |

### 16.2 Interlock Signal Flow

```
                    LEGACY INTERLOCK ARCHITECTURE

    FAST (µs)                    MEDIUM (ms)                SLOW (s)
    ┌──────────┐                ┌──────────────┐          ┌──────────────┐
    │ RFP      │                │ PLC-5        │          │ rf_states.st │
    │ Hardware  │                │ (RF MPS)     │          │ (SNL)        │
    │ Interlock │                │              │          │              │
    └─────┬────┘                └──────┬───────┘          └──────┬───────┘
          │                            │                         │
          │  ┌──────────┐              │                         │
          │  │ AIM      │              │                         │
          │  │ Module   │              │                         │
          │  │ + Fiber  │              │                         │
          │  └─────┬────┘              │                         │
          │        │                   │                         │
          ▼        ▼                   ▼                         ▼
    ┌──────────────────────────────────────────────────────────────┐
    │              INTERLOCK ACTIONS                                │
    │  • RF Switch OFF (immediate)                                 │
    │  • Crowbar fire (via fiber optic, <1 µs)                    │
    │  • HVPS contactor open (via PLC relay, ~100 ms)             │
    │  • Beam abort (via facility MPS)                             │
    │  • Orderly state transition (software, ~seconds)            │
    └──────────────────────────────────────────────────────────────┘
```

### 16.3 PPS Safety Chain (Independent)

The PPS operates independently of the control system (see §9 for detailed architecture). Key design principle: **all safety-critical functions are hardwired**. No safety function depends on software, network communication, or EPICS Channel Access.

### 16.4 Critical Design Principle

The legacy system follows a defense-in-depth approach:
1. **Hardware feedback loops** (direct loop in RFP) reject most perturbations without software intervention
2. **Hardware interlocks** (AIM, fiber optic, relay chains) provide sub-millisecond protection
3. **PLC-based protection** (MPS) provides equipment protection with fault diagnosis
4. **Software state machine** provides orderly shutdown and automatic recovery sequences
5. **PPS** provides personnel safety independently of all other systems

Each layer operates independently — failure of a slower layer does not compromise faster layers.

> **Source**: `Designs/0_SYSTEM_DESIGN_REPORT.md` §17; `Designs/obsolete/B_SPEAR3_CURRENT_LLRF_TECHINICAL_DESIGN_REPORT.md` §19; `pps/diagrams/00_SYSTEM_OVERVIEW.md`

---

## 17. Known Limitations and Failure Modes

### 17.1 Hardware Obsolescence

| Component | Issue | Impact |
|-----------|-------|--------|
| Kinetics V152 CPU | End-of-life; no vendor support | Cannot replace if CPU fails |
| Custom VXI modules (RFP, IQA, CLK, AIM) | SLAC custom design; no spares program | Single points of failure with no replacements |
| Allen-Bradley SLC-500 PLC | Rockwell end-of-life; limited spare parts | HVPS controller failure risk |
| Allen-Bradley PLC-5 | Rockwell end-of-life | RF MPS failure risk |
| Slo-Syn SS2000MD4-M motor drivers | Discontinued | Tuner motor driver failure |
| AB 1746-HSTP1 stepper modules | Discontinued | Tuner controller failure |
| AT&T DSP1610 processors | Obsolete for 20+ years | DSP failure = module replacement required |

### 17.2 Software Limitations

| Limitation | Description |
|------------|-------------|
| VxWorks licensing | Operating system no longer supported at SLAC |
| EPICS R3.13.x | Two major versions behind current EPICS 7.x |
| Single-threaded SNL | All control logic in single IOC; IOC crash = full station loss |
| No first-fault detection | Software-based timestamping; cannot determine fault ordering |
| Limited diagnostics | VXI history buffer insufficient for root-cause analysis |
| No waveform pre-trigger | Cannot capture events leading up to a fault |
| No remote code update | Requires physical access to VxWorks boot parameters |

### 17.3 Communication Vulnerabilities

| Vulnerability | Description |
|---------------|-------------|
| Single serial link | All PLC/stepper communication through one AB serial chain |
| No redundancy | Loss of AB DCM module = loss of all external PLC communication |
| Slow update rate | ~1 Hz supervisory update rate through AB serial |
| No encryption/authentication | VxWorks/EPICS communication on flat network |

### 17.4 PPS Compliance Gaps

See §9.3 for detailed PPS compliance issues. The five identified issues (PLC in safety chain, wiring exposure, limited display, emergency-off coupling, accessible cable) collectively create a non-compliant PPS implementation by current SSRL standards.

### 17.5 Arc Detection Failure

The non-functional arc detection system (§12) represents a gap in the waveguide protection chain. The system relies on secondary protection mechanisms that are slower and less targeted than dedicated arc detection.

### 17.6 Single Points of Failure

| Single Point | Failure Impact |
|-------------|----------------|
| VXI CPU | Complete station loss |
| AB DCM module | Loss of all PLC/stepper communication |
| RFP module | Loss of all RF feedback |
| Clock module | Loss of all RF signal processing |
| Klystron | No RF power output |
| HVPS (active unit) | No klystron power (switchover to SPEAR2 required) |

---

## 18. Source Document Index

### 18.1 Design Documents

| Document | Path | Content |
|----------|------|---------|
| System Design Report (Doc 0) | `Designs/0_SYSTEM_DESIGN_REPORT.md` | Top-level upgrade system design |
| Legacy LLRF Control (Doc A) | `Designs/obsolete/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` | Legacy SNL control software design (superseded by this document) |
| Current LLRF Technical Design (Doc B) | `Designs/obsolete/B_SPEAR3_CURRENT_LLRF_TECHINICAL_DESIGN_REPORT.md` | Complete legacy LLRF technical design (superseded by this document) |
| Documentation Architecture | `Designs/DOCUMENTATION_ARCHITECTURE_PROPOSAL.md` | Documentation reorganization framework |

### 18.2 Code Review Technical Notes (8 documents, Rev 6)

| Note | Path | Content |
|------|------|---------|
| 00 — Executive Summary | `spear-rf-code-legacy/codeReviewTechnicalNotes/00-executive-summary.md` | Legacy → upgrade decision matrix, codebase breakdown |
| 01 — File Inventory | `spear-rf-code-legacy/codeReviewTechnicalNotes/01-file-inventory.md` | Complete 253-file catalog with upgrade verdicts |
| 02 — Architecture Overview | `spear-rf-code-legacy/codeReviewTechnicalNotes/02-architecture-overview.md` | PV naming, boot sequence, cross-cutting concerns |
| 03 — VXI Device Support | `spear-rf-code-legacy/codeReviewTechnicalNotes/03-vxi-device-support.md` | VXI driver and device support analysis (ELIMINATED by LLRF9) |
| 04 — DSP Firmware | `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md` | DSP algorithms (ELIMINATED by LLRF9 FPGA) |
| 05 — SNL State Machines | `spear-rf-code-legacy/codeReviewTechnicalNotes/05-snl-state-machines.md` | SNL programs — primary spec extraction targets |
| 06 — PLC & Stepper Motors | `spear-rf-code-legacy/codeReviewTechnicalNotes/06-plc-stepper-motors.md` | AB drivers (ELIMINATED) + stepper (ALREADY DONE) |
| 07 — EPICS Databases | `spear-rf-code-legacy/codeReviewTechnicalNotes/07-epics-databases.md` | PV structure — critical for PV migration mapping |
| 08 — Signal Processing | `spear-rf-code-legacy/codeReviewTechnicalNotes/08-signal-processing.md` | subIQ.c + subSys.c — evaluate for coordinator reuse |

### 18.3 HVPS Documentation

| Document Set | Path | Content |
|-------------|------|---------|
| HVPS System Design | `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md` | Comprehensive HVPS legacy system design report |
| PEP-II Power Supply Architecture | `hvps/architecture/technical-notes/01-pepii-power-supply-architecture.md` | Original PEP-II HVPS design |
| Power Supply Schematics | `hvps/architecture/technical-notes/02-power-supply-schematics-analysis.md` | Electrical schematic analysis |
| Detailed Schematic Analysis | `hvps/architecture/technical-notes/03-detailed-schematic-analysis.md` | Component-level circuit analysis |
| Regulator Board Design | `hvps/architecture/technical-notes/04-regulator-board-design.md` | Custom SLAC regulator card |
| System Integration Notes | `hvps/architecture/technical-notes/05-system-integration-notes.md` | Subsystem integration details |
| Design Notes Synthesis | `hvps/architecture/technical-notes/06-design-notes-synthesis.md` | Comprehensive integration of all HVPS design docs |
| Enerpro Technical Notes | `hvps/controls/enerpro/technical-notes/` (9 documents) | SCR firing control system documentation |
| PLC Technical Notes | `hvps/documentation/plc/technical-notes/` (9 documents) | SLC-500 PLC ladder logic and I/O analysis |
| Original Design Publications | `hvps/architecture/originalDocuments/` | SLAC-PUB-7591, PS-3413600102, PEP-II supply presentation |
| Procedures | `hvps/documentation/procedures/` | Maintenance procedures, safety documentation, lockout permits |
| Mechanical Drawings | `hvps/documentation/mechanical/` | Transformer and rectifier assembly drawings |
| Schematics | `hvps/documentation/schematics/` | HVPS electrical schematics |
| Wiring Diagrams | `hvps/documentation/wiringDiagrams/` | Hoffman Box and HVPS wiring |

### 18.4 PPS Documentation

| Document | Path | Content |
|----------|------|---------|
| PPS System Overview | `pps/diagrams/00_SYSTEM_OVERVIEW.md` | Current vs. upgrade architecture overview |
| Vacuum Contactor Controller | `pps/diagrams/01_gp4397040201_vacuum_contactor_controller.md` | Contactor controller schematic analysis |
| Vacuum Contactor Driver | `pps/diagrams/02_rossEngr713203_vacuum_contactor_driver.md` | Ross Engineering contactor details |
| Grounding Tank | `pps/diagrams/03_sd7307900501_grounding_tank.md` | Termination tank schematic |
| Hoffman Box Wiring | `pps/diagrams/04_wd7307900206_hoffman_box_wiring.md` | HVPS controller wiring diagram analysis |
| Full Interconnection | `pps/diagrams/05_wd7307900103_interconnection_full.md` | B118 ↔ Contactor + Tank wiring |
| Grounding Tank Interconnection | `pps/diagrams/06_wd7307940600_interconnection_grounding_tank.md` | B118 ↔ Termination Tank wiring |
| PLC Code and Logic | `pps/diagrams/07_PLC_CODE_AND_LOGIC.md` | PLC rung analysis for PPS functions |
| Corrected Hand Drawing | `pps/diagrams/08_CORRECTED_HAND_DRAWING.md` | Corrected PPS interface figure |
| PPS Upgrade Proposal | `pps/pps_Ben.md` | Ben Morris meeting notes (March 2026) |
| Jim Sebek PPS Email | `pps/MSG from Jim Sebek to Faya about PPS.md` | 2022 PPS concerns and upgrade drivers |
| Original PPS Schematics | `pps/*.pdf` (6 PDFs) | Original engineering drawings |

### 18.5 LLRF Documentation

| Document Set | Path | Content |
|-------------|------|---------|
| PEP-II/SPEAR3 System Reference | `llrf/documentation/legacyArchitecture/technical-notes/00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` | Comprehensive PEP-II heritage technical reference |
| Feedback Loop Architecture | `llrf/documentation/legacyArchitecture/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md` | Detailed legacy loop analysis and reconstruction |
| VXI Hardware Module Reference | `llrf/documentation/legacyArchitecture/technical-notes/02_VXI_HARDWARE_MODULE_REFERENCE.md` | Module-level hardware documentation |
| Legacy PDF Catalog | `llrf/documentation/legacyArchitecture/technical-notes/03_LEGACY_PDF_CATALOG.md` | PDF inventory and content mapping |
| Literature Synthesis | `llrf/documentation/legacyArchitecture/technical-notes/04_LITERATURE_SYNTHESIS.md` | Published paper analysis |
| Cross-Reference Index | `llrf/documentation/legacyArchitecture/technical-notes/05_CROSS_REFERENCE_INDEX.md` | Topic → source mapping matrix |
| Legacy PDF Transcriptions | `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/` (15+ documents) | Transcribed PEP-II engineering drawings and procedures |
| Filament Heater Notes | `llrf/documentation/filamentHeater/FILAMENT_HEATER_TECHNICAL_NOTES.md` | Klystron cathode heater technical analysis |
| LLRF9 EDM Screens | `llrf/llrf9/iGp/dl_llrf/` | Operator display panels for LLRF9 (upgrade reference) |
| Tuner Documentation | `llrf/tuners/` | Galil DMC-4143 firmware, Slo-Syn manuals |
| Arc Detector | `llrf/arcDetector/` | Arc detection product sheets and references |
| Drive Amplifier | `llrf/driveAmp/KAW2051M12*.pdf` | Drive amplifier datasheet |
| Operation Guide | `llrf/documentation/LLRFOperation_jims.docx` | J. Sebek SPEAR3 RF Station Operation Guide |
| Upgrade Task List | `llrf/documentation/LLRFUpgradeTaskListRev3.docx` | Full project scope, procurement, costs |

### 18.6 Legacy Source Code

| Path | Content |
|------|---------|
| `spear-rf-code-legacy/rfApp/src/seq/` | 6 SNL programs + 12 header files — core control logic |
| `spear-rf-code-legacy/rfApp/src/db/` | Custom record types, device support, signal processing subroutines |
| `spear-rf-code-legacy/rfApp/src/dsp/` | DSP firmware (assembly) for RFP and GVF modules |
| `spear-rf-code-legacy/rfApp/src/vxi/` | VXI bus drivers and device support |
| `spear-rf-code-legacy/rfApp/src/diag/` | Diagnostic utilities |
| `spear-rf-code-legacy/rfApp/Db/` | EPICS database files (.db, .substitutions) |
| `spear-rf-code-legacy/stepper/` | Stepper motor driver code |

### 18.7 Published References

1. Corredoura, P.L., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8498, PAC 1999
2. McIntosh, P., "The SPEAR3 RF System," SLAC-PUB-11017, January 2005
3. Cassel, R., Nguyen, M., "PEP-II High Voltage Power Supply Crowbar Energy Analysis," SLAC-PUB-7591, 1997
4. Fox, J. et al., "Lessons learned from PEP-II LLRF and longitudinal feedback," Phys. Rev. ST Accel. Beams 13, 052802 (2010)
5. Schwarz, H., "PEP-II RF System Description," PS-340-330-51-R0, 1998
6. Schwarz, H., Corredoura, P., "LLRF Feedback Loop Description," PS-340-330-52-R0, 1999
7. Allison, S., Claus, R., "Operator Interface for the PEP-II Low Level RF Control System," PAC 1997
8. Schwarz, H., Rimmer, R., "RF system design for the PEP-II B Factory," PAC 1994
9. Pedersen, F., "RF Cavity Feedback," SLAC-400, November 1992
10. Wilson, P.B., "Fundamental-Mode RF Design in e+e- Storage Ring Factories," SLAC-PUB-6062, 1993

---

*End of Document*

*Doc L — Legacy System Architecture, Version 1.0*  
*This document synthesizes information from the complete SPEAR3 LLRF workspace including: design documents, code review technical notes, HVPS technical notes, Enerpro SCR documentation, PLC analysis, PPS schematic analysis, legacy PDF transcriptions, published literature, and the 253-file / 82,430-line legacy codebase.*
