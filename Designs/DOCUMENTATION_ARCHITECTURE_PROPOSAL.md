# SPEAR3 RF System — Documentation Architecture Proposal

**Document**: Documentation Architecture Technical Note
**Version**: 5.0
**Date**: March 24, 2026
**Status**: PROPOSAL — For Review

---

## 1. Purpose

This document proposes a comprehensive reorganization of the SPEAR3 RF system documentation. The goal is to create a clear, navigable, and maintainable documentation set that:

- Separates physics, legacy system reference, and upgrade design into distinct tiers
- Provides a dedicated upgrade design document for each subsystem defined in Doc 0
- Accommodates operational data catalogs and baselines from the currently running system
- Preserves the existing code review series material as a reference foundation
- Constrains only Doc 0 (System Design Report) — all other documents may be completely rewritten or reorganized

---

## 2. Background and Motivation

### 2.1 Current State

The SPEAR3 RF system documentation spans a 20-year history of design, construction, commissioning, maintenance, and now upgrade planning. Material is distributed across:

- **`Designs/0_SYSTEM_DESIGN_REPORT.md`** — The master System Design Report (Doc 0, ~1,500 lines), which defines the upgrade architecture, subsystem boundaries, interface specifications, and acceptance criteria (§19.4)
- **`Designs/obsolete/`** — Eight prior design documents (Docs 1–8, A, B) from earlier review cycles, now superseded. These contain valuable analysis but mix physics, legacy description, and upgrade design in each document
- **`spear-rf-code-legacy/`** — The complete legacy EPICS/VxWorks codebase: 253+ source files, 82,430+ lines including VXI drivers, DSP firmware, EPICS databases, PLC communication drivers, and 6 SNL state machine programs
- **`hvps/`** — HVPS documentation tree: schematics, wiring diagrams, PLC code, maintenance procedures, measurement data, simulation models, reliability logs, Enerpro controller documentation, and switchgear technical notes
- **`llrf/`** — LLRF documentation tree: architecture documents, calibration spreadsheets, LLRF9 test reports, arc detector specifications, tuner commissioning data, drive amplifier data, legacy architecture papers
- **`pps/`** — Personnel Protection System wiring and schematics
- **`Docs_JS/`** — Original engineering notes (J. Sebek): operational guide, upgrade task list, interface chassis specification, waveform buffer design
- **Published literature** — McIntosh et al. 2005 (*The SPEAR3 RF System*, SLAC-PUB), Corredoura 1999 (*PEP-II LLRF Architecture*), and related IPAC/PAC proceedings

### 2.2 Problems Identified in Previous Reviews

Over four rounds of review, several structural problems were identified in the original 8-document series:

1. **Layer mixing** — Every document blends RF physics, legacy system description, and upgrade design. An engineer looking for "how the legacy HVPS controller works" had to read across 4+ documents and cross-reference code review notes.

2. **Incomplete legacy coverage** — The prior Doc A covered only the 6 SNL state machine programs. The full legacy codebase spans VXI drivers, DSP firmware, EPICS databases, PLC drivers, and signal processing — all comprehensively analyzed in earlier code review technical notes.

3. **No single baseline reference** — Operational measurements (HVPS voltages, RF calibrations, alarm setpoints, reliability statistics) are scattered across 18+ spreadsheet files, EPICS database definitions, and test reports with no consolidated index.

4. **Redundant material** — The same RF physics concepts (beam loading, detuning, Robinson stability) were explained 3–5 times across different documents at different levels of completeness.

5. **Missing traceability** — No systematic mapping from Doc 0 acceptance criteria (§19.4) to the actual measured baselines that define "current performance."

### 2.3 Design Principles for the New Structure

The reorganization follows these principles:

| Principle | Rationale |
|-----------|-----------|
| **Layered architecture** | Separate physics foundations, legacy reference, upgrade design, and operational data into distinct tiers |
| **Single source of truth** | Each topic has exactly one authoritative location; other documents reference, not duplicate |
| **Traceability** | Every design decision traces to a requirement in Doc 0; every baseline traces to a source measurement |
| **Incremental completeness** | Documents can be written and reviewed independently; placeholder sections explicitly mark gaps |
| **Preservation of investment** | Prior analysis is reorganized, not discarded — code review findings are incorporated by reference |

---

## 3. Documentation Tier Architecture

### 3.1 Tier Overview

```
Tier 0 ─── System Level
│  Doc 0: System Design Report (CONSTRAINED — exists, maintained)
│
Tier 1 ─── Foundation Layer  
│  Doc P: RF Physics & Beam Dynamics Reference
│  Doc L: Legacy System Architecture Reference
│
Tier 2 ─── Operational Reference
│  Doc D: Operational Data & Baselines Catalog
│  Doc M: Master Document & Drawing Index
│
Tier 3 ─── Subsystem Upgrade Designs (one per Doc 0 subsystem)
│  Doc U-HVPS:  HVPS Controller Upgrade Design
│  Doc U-LLRF:  LLRF9 Integration Design
│  Doc U-IF:    Interface Chassis Design
│  Doc U-ARC:   Arc Detection System Design
│  Doc U-PPS:   PPS Upgrade Design
│  Doc U-TUN:   Tuner Control Upgrade Design
│  Doc U-SOFT:  Software Architecture Design
│  Doc U-COMM:  Commissioning & Test Plan
│  Doc U-SAFE:  Safety & Interlock Design
│  Doc U-DIAG:  Diagnostics & Monitoring Design
│
Tier 4 ─── Implementation Artifacts
   Code review technical notes (existing, by reference)
   Simulation reports (existing, by reference)
   Test procedures and results (generated during commissioning)
```

### 3.2 Tier Definitions

**Tier 0 — System Level**: The single master document that defines scope, architecture, interfaces, requirements, and acceptance criteria. Doc 0 is the only document that is **constrained** (i.e., its structure and content are maintained as-is, with revisions tracked). All other documents derive their authority from Doc 0.

**Tier 1 — Foundation Layer**: Reference documents that capture domain knowledge independent of the specific upgrade design. These change rarely and serve as the knowledge base for understanding the system.

**Tier 2 — Operational Reference**: Living reference documents that catalog measured data, document indices, and configuration baselines. These are updated as new measurements are taken or documents are created.

**Tier 3 — Subsystem Upgrade Designs**: One document per subsystem defined in Doc 0. Each follows a standard template and contains only the upgrade design for that subsystem, referencing Tier 1 and Tier 2 for background and baselines.

**Tier 4 — Implementation Artifacts**: Working documents generated during development, testing, and commissioning. These are referenced from higher tiers but not managed within the documentation architecture itself.

---

## 4. Document Specifications

### 4.1 Doc 0 — System Design Report (Existing)

| Attribute | Value |
|-----------|-------|
| **Status** | Active, Rev 1+, ~1,500 lines |
| **Location** | `Designs/0_SYSTEM_DESIGN_REPORT.md` |
| **Scope** | System-level architecture, subsystem definitions, interface specifications, implementation phases, acceptance criteria |
| **Constraint** | Structure and section numbering are frozen; content updated by tracked revisions only |
| **Key sections** | §1–4 System overview; §5–16 Subsystem specifications; §17 Software architecture; §18 Safety; §19 Implementation phases and success criteria; §20 Source document appendix |

**Relationship to other documents**: Doc 0 defines the subsystem boundaries that determine the Tier 3 document set. Its §19.4 success criteria table is the primary acceptance reference that Doc D baselines are measured against.

### 4.2 Doc P — RF Physics & Beam Dynamics Reference

| Attribute | Value |
|-----------|-------|
| **Status** | To be written |
| **Scope** | RF cavity physics, beam loading theory, Robinson stability criteria, synchrotron oscillation dynamics, detuning and tuner physics, klystron operating principles, power distribution (magic tee), waveguide network theory |
| **Audience** | Engineers new to the system; provides the physics context needed to understand design decisions |
| **Sources** | Material extracted from obsolete Docs 1–8 physics sections; published references (McIntosh et al. 2005, Corredoura 1999, SLAC-PUB-7591) |

**Content outline**:
1. Storage ring RF fundamentals (3.0 GeV, 500 mA, h=372, 476.336 MHz, 1 MeV/turn synchrotron radiation loss)
2. Cavity electrodynamics (HOM-damped copper cavities, 800 kV/cavity, 3.2 MV total accelerating voltage)
3. Beam loading and Robinson stability (threshold conditions, stability diagrams)
4. Synchrotron oscillation physics (measured νs ≈ 8.9–9.7 kHz depending on feedback, Q factor interpretation)
5. Klystron physics (1.2 MW CW at 476.3 MHz, perveance monitoring, saturation characteristics)
6. HVPS power conversion (12-pulse thyristor, 12.47 kV → −74 kV DC, ripple spectrum at 360/720 Hz harmonics)
7. RF feedback theory (direct loop, comb filter, gap voltage feedback, ripple suppression)
8. Tuner physics (mechanical tuner, detuning angle, load angle offset)

**Key references to incorporate**:
- `hvps/architecture/originalDocuments/slac-pub-7591.pdf` — PEP-II HVPS design (Bellomo et al.)
- `llrf/documentation/legacyArchitecture/architecture-and-performance-of-the-pep-ii-low-level-rf.pdf` — PEP-II LLRF architecture (Corredoura)
- `llrf/documentation/legacyArchitecture/feedbackLoopDescriptionps3403305200.pdf` — Feedback loop description (PS-340-330-52)
- `llrf/documentation/legacyArchitecture/ps3403305100.pdf` through `ps3403306102.pdf` — RF system technical specifications series
- McIntosh et al. 2005, *The SPEAR3 RF System* (SLAC-PUB, OSTI:839730)

### 4.3 Doc L — Legacy System Architecture Reference

| Attribute | Value |
|-----------|-------|
| **Status** | To be written |
| **Scope** | Complete technical description of the legacy RF system as-built and as-operating, organized by functional subsystem |
| **Audience** | Upgrade designers who need to understand what they are replacing; maintenance engineers |
| **Sources** | Legacy codebase (`spear-rf-code-legacy/`), code review technical notes, EPICS database definitions, PLC documentation, original PEP-II design documents |

**Content outline**:
1. System overview — hardware architecture, signal flow from AC mains through klystron to cavity
2. VXI chassis and module inventory (CPU, AB Scanner, Clock, RFP, IQA×3, CFM, GVF, AIM)
3. EPICS IOC architecture — database organization (`rfApp/Db/`), substitutions (`srf1.substitutions`), record types, scan rates
4. SNL state machine architecture — the 6 programs and their interactions:
   - `rf_states.st` — Master station state machine (ON/OFF/TUNE/FAULT transitions, 2,227 lines)
   - `rf_hvps_loop.st` — HVPS voltage regulation loop (343 lines)
   - `rf_dac_loop.st` — DAC output control loop (290 lines)
   - `rf_tuner_loop.st` — Cavity tuner feedback with load angle offset (555 lines)
   - `rf_calib.st` — IQA calibration system (2,800+ lines)
   - `rf_msgs.st` — Message and event logging (352 lines)
5. VXI module device support drivers — hardware interface layer for RFP, IQA, CFM, GVF, AIM, Clock modules
6. Allen-Bradley PLC interface — SLC-500 via AB-1746 modules, DCM data conversion
7. Fast interlock system — VXI-based arc detection, reflected power trips, MPS interface
8. Signal processing chain — IQ demodulation, amplitude/phase calculation, fault detection logic
9. Control loop architecture — direct feedback, comb filter, gap voltage feedback, ripple loop, HVPS voltage loop
10. Fault handling — fault file capture (11 waveform buffers, circular history of 15 events), auto-reset logic

**Key source files to reference** (from `spear-rf-code-legacy/rfApp/`):

| Directory | Content | Files |
|-----------|---------|-------|
| `Db/` | EPICS database definitions | `rf_hvps.db`, `rf_cav.db`, `rf_iqa.db`, `rf_analog.db`, `rf_fbck.db`, `rf_beam.db`, `rf_stn_*.db`, `rf_temp_*.db`, `rf_digital_*.db` |
| `src/seq/` | SNL state machines | `rf_states.st`, `rf_hvps_loop.st`, `rf_dac_loop.st`, `rf_tuner_loop.st`, `rf_calib.st`, `rf_msgs.st` |
| `src/drv/` | VXI device support drivers | Module-specific C drivers for RFP, IQA, CFM, GVF, AIM, Clock |
| `src/sub/` | Subroutine records | `subIQ*.c` (IQ amplitude/phase calculations) |
| `DbIoc/` | IOC instance configuration | `srf1.substitutions` (PV macro expansion for SRF1 station) |

### 4.4 Doc D — Operational Data & Baselines Catalog

| Attribute | Value |
|-----------|-------|
| **Status** | To be written (highest priority after Doc 0) |
| **Scope** | Consolidated catalog of all operational measurements, calibration data, alarm setpoints, reliability statistics, and performance baselines for the legacy RF system |
| **Audience** | Upgrade designers (baseline reference), commissioning team (acceptance testing reference), operations (alarm setpoint reference) |
| **Sources** | 18+ measurement spreadsheets, EPICS database alarm definitions, LLRF9 test report, HVPS reliability logs, published facility parameters |
| **Update policy** | Snapshot with revision control — Rev 0 captures pre-upgrade state; each measurement campaign adds a revision |

**Content outline** (detailed specification follows in §5 of this proposal):
1. Scope, conventions, and data classification system
2. Facility reference parameters (machine physics)
3. HVPS operating baselines (electrical, thermal, control loop)
4. HVPS reliability baselines (20-year failure history, MTBF)
5. RF signal chain calibrations (end-to-end gain/loss budget)
6. Cavity and beam baselines (accelerating voltage, tuner)
7. LLRF spectral performance baselines (legacy vs. LLRF9 comparison)
8. Control system timing baselines (SNL constants)
9. Cross-facility reference data (SPEAR1/SPEAR2 comparison)
10. Data gap register and planned measurements
11. Appendices: full EPICS alarm tables, PLC I/O map, traceability matrix

**Primary data sources** (with reference tags used in the document):

| Tag | Source File | Content | Date |
|-----|------------|---------|------|
| `[HM-2022]` | `hvps/documentation/plc/hvpsMeasurements20220314.xlsx` | HVPS operating points at 500 mA | 2022-03-14 |
| `[MC-2022]` | `hvps/documentation/wiringDiagrams/hvpsMonitorConnections.xlsx` | Transformer impedance baselines | 2022-02/03 |
| `[HR-2024]` | `hvps/maintenance/HVPSReliability.xlsx` | 20-year HVPS failure history | 2005–2024 |
| `[PS-2020]` | `hvps/maintenance/phaseTankScrs.xlsx` | SCR leakage current baselines | 2020-07/08 |
| `[PP-xxxx]` | `llrf/calibrations/b132R11PatchPanel.xlsx` | RF patch panel path loss (39 paths) | undated |
| `[DA-2020]` | `llrf/calibrations/driveAmpCalibration.xlsx` | Drive amplifier calibration | 2020-11-16 |
| `[KC-2020]` | `llrf/calibrations/klystronCouplerDriveAmpCalibrations.xlsx` | Klystron coupler characterization | 2020-09-14 |
| `[PC-xxxx]` | `llrf/calibrations/pulsarCouplerCalibration2049.xlsx` | Directional coupler baseline | mfg code 2049 |
| `[RP-2021]` | `llrf/calibrations/reflectedPowerCalibrations.xlsx` | Reflected power trip thresholds | 2021-02-08 |
| `[TD-xxxx]` | `llrf/calibrations/tuneModeDacCalibration.xlsx` | Tuner DAC calibration | undated |
| `[PL-xxxx]` | `hvps/documentation/plc/hvpsPlcLabels.xlsx` | PLC I/O mapping (17 sheets) | undated |
| `[LP-xxxx]` | `hvps/documentation/plc/LocalPanelToXConnectMapping.xlsx` | Local panel signal mapping | undated |
| `[DI-xxxx]` | `llrf/documentation/RfSystemDocumentIndexR3.xlsx` | Master document index (95 entries) | Rev 3 |
| `[L9-2021]` | `llrf/tests/llrf9Tests.tex` + `.pdf` | LLRF9 spectral comparison (J. Sebek) | early 2021 |
| `[DB-HVPS]` | `spear-rf-code-legacy/rfApp/Db/rf_hvps.db` | HVPS EPICS alarm setpoints | RCS latest |
| `[DB-IQA]`  | `spear-rf-code-legacy/rfApp/Db/rf_iqa.db` | IQA EPICS alarm setpoints | RCS latest |
| `[DB-CAV]`  | `spear-rf-code-legacy/rfApp/Db/rf_cav.db` | Cavity EPICS alarm setpoints | RCS latest |
| `[DB-FBCK]` | `spear-rf-code-legacy/rfApp/Db/rf_fbck.db` | Feedback loop EPICS records | RCS latest |
| `[SNL-ST]`  | `spear-rf-code-legacy/rfApp/src/seq/rf_states.st` | State machine timing constants | RCS latest |
| `[SNL-HL]`  | `spear-rf-code-legacy/rfApp/src/seq/rf_hvps_loop.st` | HVPS loop parameters | RCS latest |
| `[SNL-TL]`  | `spear-rf-code-legacy/rfApp/src/seq/rf_tuner_loop.st` | Tuner loop parameters | RCS latest |
| `[SIM-HV]`  | `hvps/simulation/hvps_sim/simulation_results/SIMULATION_RESULTS_SUMMARY.md` | HVPS simulation baselines | 2026-03-13 |
| `[GL-2024]` | `llrf/tuners/galil/firstMotion2024.txt` | Galil tuner commissioning | 2024 |
| `[GL-2025]` | `llrf/tuners/galil/functioningGalil20250825SwapABToManual.txt` | Galil config update | 2025-08-25 |
| `[S1-2022]` | `hvps/maintenance/Spear1Tests20220817.xlsx` | SPEAR1 comparison data | 2022-08-17 |
| `[S2-2021]` | `hvps/maintenance/Spear2Tests2021.xlsx` | SPEAR2 comparison data | 2021 |
| `[MC-2005]` | McIntosh et al. 2005, *The SPEAR3 RF System* | Published facility parameters | 2005 |
| `[PUB-7591]` | `hvps/architecture/originalDocuments/slac-pub-7591.pdf` | PEP-II HVPS design | 1997 |

### 4.5 Doc M — Master Document & Drawing Index

| Attribute | Value |
|-----------|-------|
| **Status** | To be written |
| **Scope** | Comprehensive index of all technical documents, schematics, wiring diagrams, procedures, and drawings across the RF system |
| **Sources** | `llrf/documentation/RfSystemDocumentIndexR3.xlsx` (95 entries), plus HVPS schematics, switchgear drawings, maintenance procedures |

**Content outline**:
1. LLRF document index (62 entries from `[DI-xxxx]`):
   - Block diagrams: BD-340-330-00 (LER station), BD-340-330-01 (LLRF)
   - Specifications: PS-340-330-51 through PS-340-330-61 (RF system description, feedback loops, calibration procedures, safety certifications, surveys, cable cal, power tests, cavity phasing, turn-on, phasing, non-ionizing radiation)
   - Wiring diagrams: WD-340-330-02 through WD-340-330-34 (34 wiring diagrams covering local panel, cavity junction box, vacuum, waveguide air, thermocouple modules×14, analog inputs×2, digital I/O×4, tuner motor, filament, fiber optics, arc detector, water flow, focus PS, klystron window, circulator)
   - Schematics: SD-340-311-00 (filament), SD-340-311-01 (local panel), SD-340-330-01 (coax cable), SD-340-308-01/02 (fast interlock chassis), SD-340-309-01 (VXI motherboard)
2. HVPS document index (33 entries from `[DI-xxxx]`):
   - Technical specification: PS-341-360-01-R2
   - SLAC publications: SLAC-PUB-7591
   - Electrical connections: EI-730-790-00-C0
   - Physical outline: SA-730-790-03-C2
   - Schematics: SD-730-790-01 (high power), SD-730-790-05 (grounding tank), SD-237-230-14 (regulator board), SD-730-793-03/04/07/08/12/13 (SCR drivers, triggers, monitor, optical trigger)
   - Wiring diagrams: WD-730-790-01/02 (interconnection), WD-730-794-02 through 06 (contactor, phase tank, crowbar, monitor, grounding tank)
   - Switchgear: GP-439-704-02, GP-308-500-01, GP-439-704-02, Ross Engineering 713203, ID-308-801-06
3. Maintenance procedures:
   - HVPS main tank: SR-444-636-01 through 07 (7 revisions), EWP procedures (crowbar, phase tank, main tank)
   - HVPS stack installation: `hvps/maintenance/hvpsStackInstallationChecklist.docx`
   - Phase tank maintenance: `hvps/maintenance/phaseTankMaintenance-20240425jjs.docx`
   - HVPS switch procedure: `hvps/documentation/procedures/spearRfHvpsSwitchProcedureR0.docx`
4. Schematic technical notes (analysis documents for each HVPS schematic):
   - `hvps/documentation/schematics/technical_notes/` — 15 analysis documents covering system overview, regulator board, SCR drivers, trigger interconnects, monitor board, crowbar triggers, optical triggers, grounding tank
   - `hvps/documentation/switchgear/technical_notes/` — 4 analysis documents covering switchgear schematic, vacuum contactor, connection wiring
5. PPS documentation:
   - `pps/HoffmanBoxPPSWiring.docx` — PPS wiring to Hoffman box
   - `pps/gp4397040201.pdf`, `pps/rossEngr713203.pdf` — Switchgear drawings
   - `pps/sd7307900501.pdf`, `pps/wd7307900103.pdf`, `pps/wd7307900206.pdf`, `pps/wd7307940600.pdf` — PPS-relevant HVPS wiring and schematics
6. Arc detection documents:
   - `llrf/arcDetector/Waveguide Arc Detector_product sheet.pdf` — Product specification
   - `llrf/arcDetector/microStepMISarcDetector.pdf` — MicroStep MIS receiver specification
   - `llrf/arcDetector/tups072.pdf` — Related technical note
   - `llrf/architecture/arcDetectorHardwareOptions.docx` — Hardware selection analysis
7. Tuner documentation:
   - `llrf/tuners/SLO-SYN.pdf` — Legacy stepper motor data
   - `llrf/tuners/SLO-SYN_MD808_Stepper_Drive_Manual.pdf` — Legacy motor drive manual
   - `llrf/tuners/SLO-SYN_SS2000MD4M_Step_Drive_Translator_Manual.pdf` — Legacy step translator manual
   - `llrf/tuners/galil/dmc-4103-r13h-manual.pdf` — Galil DMC-4143 controller manual
   - `llrf/tuners/galil/ds_41x3.pdf` — Galil data sheet
   - `llrf/tuners/galil/GalilCommissioning.docx` — Commissioning notes
   - `llrf/tuners/cavityTunerInspections20230613.docx` — Cavity tuner inspection (June 2023)
8. LLRF9 documentation:
   - `llrf/llrf9/llrf9_manual_print.pdf` — LLRF9 operator manual (Dimtel)
9. Drive amplifier:
   - `llrf/driveAmp/KAW2051M12 (7-98-907-012A).pdf` — Drive amplifier specification
10. Engineering design notes:
    - `hvps/architecture/designNotes/` — 10 design notes covering Enerpro regulator, Hoffman box PPS wiring, power distribution, controller fiber optics, interfaces between controllers, regulator testing, RFEDM/HVPS PV labels, RF system MPS requirements
    - `hvps/controls/enerpro/` — Enerpro FCOG1200 documentation (12 PDFs covering schematics Rev F/K/L, operating manual, brochure, auto-balance, product guide, Bourbeau IEEE 1983 paper)
    - `hvps/controls/enerpro/enerproBoardHvps.docx`, `enerproDiscussion07072022.docx`, `enerproPhaseReferenceAdapter.docx` — Engineering analysis notes

### 4.6 Tier 3 — Subsystem Upgrade Design Documents

Each Tier 3 document follows a **standard template**:

```
Section 1: Scope and relationship to Doc 0 (reference specific Doc 0 section)
Section 2: Legacy system summary (reference Doc L for details)
Section 3: Baseline data summary (reference Doc D for measurements)
Section 4: Upgrade requirements (derived from Doc 0 §19.4 + subsystem-specific)
Section 5: Upgrade design
Section 6: Interface specifications (reference Doc 0 interface tables)
Section 7: Verification and test plan (reference Doc U-COMM)
Section 8: Risk register
Section 9: Source references
```

The following subsystem documents are defined:

| Document | Doc 0 Section | Scope | Key Sources |
|----------|---------------|-------|-------------|
| **Doc U-HVPS** | §5 | HVPS PLC controller replacement (Allen-Bradley SLC-500 → CompactLogix/modern PLC). Retains power section unchanged. | `hvps/architecture/designNotes/`, `hvps/controls/enerpro/`, `hvps/documentation/plc/`, Doc 0 §5 |
| **Doc U-LLRF** | §6 | LLRF9 (Dimtel) integration: board configuration, signal routing, feedback loop tuning, interface to EPICS coordinator | `llrf/llrf9/`, `llrf/architecture/`, `llrf/tests/llrf9Tests.*`, Doc 0 §6 |
| **Doc U-IF** | §7 | Interface Chassis design: LO synthesis, RF signal conditioning, interlock logic, power combiner | `llrf/architecture/llrfInterfaceChassis.docx`, `llrf/documentation/legacyArchitecture/`, Doc 0 §7 |
| **Doc U-ARC** | §8 | Arc Detection upgrade: MicroStep MIS receivers, fiber sensors, OR-gate latch logic, 6-bit diagnostic register | `llrf/arcDetector/`, `llrf/architecture/arcDetectorHardwareOptions.docx`, Doc 0 §8 |
| **Doc U-PPS** | §9 | PPS interface upgrade: dual-channel safety interlock, key switch, visible verification | `pps/`, `hvps/architecture/designNotes/HoffmanBoxPPSWiring.docx`, Doc 0 §9 |
| **Doc U-TUN** | §10 | Tuner Control upgrade: Galil DMC-4143, stepper motor interface, phase-based feedback from LLRF9 | `llrf/tuners/`, `llrf/tuners/galil/`, Doc 0 §10 |
| **Doc U-SOFT** | §17 | Software Architecture: EPICS coordinator, Python IOC modules, state machine redesign, alarm configuration | `spear-rf-code-legacy/rfApp/`, `Docs_JS/`, Doc 0 §17 |
| **Doc U-COMM** | §19 | Commissioning & Test Plan: phased rollout, acceptance test procedures, rollback criteria | Doc 0 §19, Doc D (baselines) |
| **Doc U-SAFE** | §18 | Safety & Interlock Design: MPS integration, radiation safety, personnel protection, electrical safety | Doc 0 §18, `hvps/documentation/procedures/spear3HvpsHazards.pdf` |
| **Doc U-DIAG** | §15–16 | Diagnostics & Monitoring: waveform buffer system, fault logging, performance trending, archiver integration | `Docs_JS/WaveformBuffersforLLRFUpgrade.docx`, Doc 0 §15–16 |

---

## 5. Doc D Detailed Specification — Operational Data & Baselines Catalog

This section provides the complete content specification for Doc D, the highest-priority new document after Doc 0. Doc D serves as the single authoritative reference for all measured operational data and performance baselines.

### 5.1 Data Classification System

Every data value in Doc D carries a **maturity classification**:

| Symbol | Classification | Definition |
|--------|---------------|------------|
| **V** | Verified | Directly measured, multiple confirmations or published; high confidence |
| **P** | Provisional | Measured once or estimated from related data; reasonable confidence |
| **S** | Simulated | Derived from validated simulation models; model confidence stated |
| **G** | Gap | Data not yet captured; measurement plan defined in §5.10 |

Every data value also carries a **source tag** (e.g., `[HM-2022]`) linking to the primary source file listed in §4.4.

### 5.2 Facility Reference Parameters

These are the fixed machine parameters from published literature and design specifications.

| Parameter | Value | Units | Source | Class |
|-----------|-------|-------|--------|-------|
| Beam energy | 3.0 | GeV | `[MC-2005]` | V |
| Design beam current | 500 | mA | `[MC-2005]` | V |
| RF frequency | 476.336 | MHz | `[MC-2005]` | V |
| Harmonic number | 372 | — | `[MC-2005]` | V |
| Synchrotron radiation loss | ~1 | MeV/turn | `[MC-2005]` | V |
| Design accelerating voltage | 3.2 | MV (total) | `[MC-2005]` | V |
| Voltage per cavity | 800 | kV | `[MC-2005]` | V |
| Number of cavities | 4 | — | `[MC-2005]` | V |
| Cavity type | PEP-II HER, HOM-damped copper | — | `[MC-2005]` | V |
| Klystron type | Marconi, 1.2 MW CW | — | `[MC-2005]` | V |
| Klystron frequency | 476.3 | MHz | `[MC-2005]` | V |
| HVPS topology | 12-pulse thyristor | — | `[PUB-7591]` | V |
| HVPS AC input | 12.47 kV, 3-phase delta | — | Doc 0 §5 | V |
| HVPS DC output (design) | -74 kV at 22 A | — | Doc 0 §5 | V |
| HVPS nominal power | 1.5 MW (nominal) | — | Doc 0 §5 | V |
| Beam emittance | 18 | nm-rad | `[MC-2005]` | V |

### 5.3 HVPS Operating Baselines

#### 5.3.1 Electrical Operating Points (from `[HM-2022]`)

Measured March 14, 2022, at 500 mA beam current with nominal 2850 kV gap voltage.

| Parameter | Value | Units | PLC Register | Conditions |
|-----------|-------|-------|-------------|------------|
| Gap Voltage range tested | 2000–3000 | kV | — | 7 operating points |
| VHVPS output readback (at 2850 kV gap) | 60.01–67.37 | kV | N7:2 (reg output) | Varies with gap voltage |
| AC current | See xlsx | A | N7:4 | |
| Regulator output register | N7:2 | ADC counts | — | Analog register |
| Phase angle | N7:1 | ADC counts (0–1023) | — | ~43% duty at nominal |
| Phase monitor | N7:3 | ADC counts | — | |

> **Note**: Full operating point table (7 measured points from 2000–3000 kV) is in `[HM-2022]`. The above summarizes the nominal operating point at design current. Data is 4 years old as of March 2026; recalibration recommended before upgrade swap.

#### 5.3.2 EPICS Alarm Setpoints (from `[DB-HVPS]`)

| PV Suffix | Description | HIHI | HIGH | LOW | LOLO | HOPR | LOPR | EGU | Sev(HH/H/L/LL) | Source |
|-----------|-------------|------|------|-----|------|------|------|-----|-----------------|--------|
| `HVPS:CURR` | HVPS Monitored Current | 30 | 30 | — | — | 30 | — | Amp | MAJ/MIN/—/— | `[DB-HVPS]` |
| `HVPS:VOLT` | HVPS Monitored Voltage | 87 | 85 | — | — | 90 | — | kV | MAJ/MIN/—/— | `[DB-HVPS]` |
| `HVPS:ACURR` | HVPS AC Current | 500 | 400 | — | — | 500 | — | Amp | MAJ/MIN/—/— | `[DB-HVPS]` |
| `HVPS:OIL` | HVPS Oil Temperature | 80 | 75 | 15 | 10 | 80 | — | C | MAJ/MIN/MIN/MAJ | `[DB-HVPS]` |
| `HVPS:PERV` | HVPS Perveance | 1.1 | 1.05 | 1.0 | 0.95 | 1.5 | 0.5 | micrPerv | MAJ/MIN/MIN/MAJ | `[DB-HVPS]` |
| `HVPS:POWER` | HVPS Power | — | — | — | — | 1200 | — | kW | —/—/—/— | `[DB-HVPS]` |

**Perveance interpretation**: Perveance = I / V^1.5 × 31.62278. Nominal ~1.0 microperv at design operating point. Increase above 1.05 indicates grid emission growth (tube aging); decrease below 0.95 indicates space-charge-limited operation change. The CALC record formula is `A<E?F:B*C/(A**D)` with C=31.62278, D=1.5, E=20 (threshold for V below which perveance calculation is suppressed to avoid division artifacts).

#### 5.3.3 HVPS Control Loop Parameters (from `[DB-HVPS]`)

| PV Suffix | Description | DRVH | DRVL | Units | Physical Meaning |
|-----------|-------------|------|------|-------|------------------|
| `HVPS:LOOP:DELAY` | Loop activation delay | 30 | 1 | Sec | Prevents oscillation at startup; `taskDelay(delay*60)` in `[SNL-HL]` |
| `HVPS:LOOP:KVDIFF` | Allowed kV difference | 100 | — | kV | Max deviation before fault; safety interlock |
| `HVPS:LOOP:KVDOWN` | Delta kV down (ramp rate) | — | -5.0 | kV | Max downward step per iteration |
| `HVPS:LOOP:KVUP` | Delta kV up (ramp rate) | 1 | — | kV | Max upward step per iteration; prevents transients |
| `HVPS:VOLT:CTRL` | Desired voltage setpoint | 90 | — | kV | Safety limit; hardware limit at 87 kV via `HVPS:VOLT:MAX` |
| `HVPS:VOLT:MIN` | Minimum voltage | 60 | — | kV | Floor for operating range |
| `HVPS:VOLT:MAX` | Maximum voltage | 87 | — | kV | Ceiling for operating range |

**HVPS Loop Status States** (enumerated mbbi record, from `[DB-HVPS]`):
- `GOOD` (1), `RFP_BAD` (2, MAJOR), `CAVV_LIM` (3, MAJOR), `LOOP_OFF` (4, MAJOR), `VACM_BAD` (5, MAJOR), `POWR_BAD` (6, MAJOR), `GAPV_BAD` (7, MAJOR), `GAPV_TOL` (8, MINOR), `VOLT_LIM` (9, MINOR), `STN_OFF` (10), `VOLT_TOL` (11, MINOR), `VOLT_BAD` (12, MAJOR), `DRIV_BAD` (13, MAJOR), `ON_FM` (14), `DRIV_TOL` (15, MINOR)

#### 5.3.4 Transformer Monitor Baselines (from `[MC-2022]`)

Measured February–March 2022 on HVPS1 and HVPS2.

| Unit | Measurement | Value | Date |
|------|------------|-------|------|
| HVPS1 | Main winding impedance (high-side pairs) | 0.25–0.35 Ohm | Feb/Mar 2022 |
| HVPS2 | Main winding impedance | ~0.35 Ohm | Feb 2022 |
| Both | Isolation to ground | Open (>1 MOhm) | 2022 |

Reference schematics: WD-730-794-05-C3, EI-730-790-00-C0.

#### 5.3.5 SCR Leakage Current Baselines (from `[PS-2020]`)

| Stack | Date | Total Voltage | Leakage Current | Condition |
|-------|------|---------------|-----------------|-----------|
| S2 C+ | 2020-07-31 | 24.91 kV | 136.51 uA | Dressed, 6-stage series |
| S2 C- (bare) | 2020-08-18 | 25 kVDC | 22.6 uA | Bare SCR |
| S2 C- (dressed) | 2020-08-18 | 25 kVDC | 92.9 uA | With snubbers/dividers |

**Observations**: Voltage imbalance of ~2 kV per stage over 25 kV total indicates SCR aging signature. Individual stage voltages range 1.9–2.1 kV with resistance 14.1–15.3 MOhm per stage.

#### 5.3.6 HVPS Simulation Reference (from `[SIM-HV]`)

| Parameter | Simulation Value | Units | Notes |
|-----------|-----------------|-------|-------|
| Mean output voltage | -77.75 | kV | Target -77 kV, regulation within +/-3% |
| Peak-to-peak ripple (with LC filter) | 6.91 | % | L=0.6H, C=8.22uF, R=250 Ohm |
| RMS ripple | 2.089 | % of mean | |
| Improvement over baseline | 4.2x | factor | Baseline ~28.88% without filtering |
| Firing angle at nominal | 77.7 | degrees | Range: 61.1 to 150.0 degrees |
| Ripple frequency | 720 | Hz | 12-pulse operation maintained |
| Transformer current crest factor | 2.52 | — | Square-wave (thyristor switching) |

> **Classification**: S (Simulated). These are design validation values, not measured on actual hardware. Use as reference for upgrade performance comparison.

### 5.4 HVPS Reliability Baselines (from `[HR-2024]`)

#### 5.4.1 Summary Statistics

| Metric | HVPS1 | HVPS2 |
|--------|-------|-------|
| Documented events | 48 | 62 |
| Service period | 2005–2024 | 2012–2024 |
| First major failure | 2006-06-23 (tension rod snap, 220 hr downtime) | 2013-12-16 (6 days after commissioning) |
| Most recent failure | 2024-03-14 (swapped to active) | 2024-03-13 (phase stack issue) |
| Longest uninterrupted run | [TBD — extract from log] | [TBD — extract from log] |

#### 5.4.2 Failure Category Breakdown

| Category | HVPS1 Count | HVPS2 Count | Examples |
|----------|------------|------------|---------|
| Transformer | 2 | 0 | Tension rod snap (2006), arc trip |
| Phase tank (SCR/thyristor) | 3+ | 6+ | Stack shorts, leakage, hipot failures |
| Crowbar | 2 | 2+ | Tension rod, trigger failures |
| Controller/PLC | 5+ | 3+ | Controller swaps, AB module failures |
| Cooling/oil | 2 | 1 | Oil temperature alarms, pump issues |
| Switchgear/contactor | 1 | 2 | Vacuum contactor failures |
| Discretionary maintenance | 10+ | 8+ | Preventive swaps, inspections |

#### 5.4.3 Reliability Trend

- **2005–2012 (HVPS1 only)**: Higher failure rate during early operational period; 3 major failures
- **2012–2017 (both units)**: HVPS2 infant mortality period; multiple cascading faults
- **2018–2024**: Stabilization; MTBF improving to estimated 100–200 days between unplanned swaps
- **Baseline for upgrade acceptance**: Doc 0 §19.4 specifies >99% uptime. With ~365 days/year and estimated 3–5 unplanned outages per year averaging 24–48 hours each, legacy system achieves approximately 98.5–99.3% uptime (needs verification from archiver data).

### 5.5 RF Signal Chain Calibrations

#### 5.5.1 Patch Panel Path Loss (from `[PP-xxxx]`)

The B132 R11 patch panel routes 39 RF signal paths between the RF plant and the LLRF system. Key signal paths and their measured losses:

| Signal | Coupler Loss | Cable Loss | Total Path Loss | LLRF9 Channel | Notes |
|--------|-------------|------------|-----------------|---------------|-------|
| Cavity A Probe | 2.36 dB | 1.54 dB | 3.9 dB | Unit 1 BRD1 CH0 | Primary feedback input |
| Cavity A Forward | 2.36 dB | varies | ~3 dB | Unit 1 BRD1 CH5 | Power distribution monitor |
| Cavity A Reflected | 2.36 dB | varies | ~3 dB | — | Arc/reflected power protection |
| Klystron Forward | varies | varies | varies | Unit 2 BRD1 | Drive power monitor |

> **Note**: Full 39-row path loss table is in `[PP-xxxx]`. Signal-to-channel mapping follows Doc 0 §6 Table (9 signals to LLRF9). Variable attenuators (4–10 dB) and fixed attenuators (7 dB on J2) are configured per signal path to match LLRF9 input power requirements.

#### 5.5.2 Drive Amplifier Calibration (from `[DA-2020]`)

| Parameter | Value | Units | Date | Equipment |
|-----------|-------|-------|------|-----------|
| Operating frequency | 476.305569700 | MHz | 2020-11-16 | R&S SMBV 100A |
| Input cable lengths | Documented | m | — | As-installed |
| Frequency response | Characterized | dB vs. freq | — | Over operational bandwidth |

Reference: Drive amp specification `llrf/driveAmp/KAW2051M12 (7-98-907-012A).pdf`.

#### 5.5.3 Klystron Coupler Calibration (from `[KC-2020]`)

| Parameter | Value | Units | Date | Equipment |
|-----------|-------|-------|------|-----------|
| Operating frequency | 476.311 | MHz | 2020-09-14 | E4418 power meter |
| Coupler insertion loss | Characterized | dB | — | |
| Directivity | Verified | dB | — | Meets specification |

#### 5.5.4 Reflected Power Trip Thresholds (from `[RP-2021]`)

| Parameter | Value | Units | Location |
|-----------|-------|-------|----------|
| Coupled input power | -12.37 | dBm | IQA1Ch2 input |
| IQA demodulated I | 234 | ADC counts | At trip threshold |
| IQA demodulated Q | -1687 | ADC counts | At trip threshold |
| Nominal reflected power | 8.1 | dBm | Normal operation |
| HIGH trip threshold | 10.8 | dBm | First alarm level |
| HIHI trip threshold | 11.4 | dBm | Major alarm / interlock |
| Fixed attenuation | 16 | dB | Signal conditioning |

> **Significance**: These thresholds define the reflected power protection interlock. They must be replicated or improved in the LLRF9 configuration. The 2.7 dBm margin between nominal and HIGH alarm is critical for arc protection response time.

#### 5.5.5 Directional Coupler Baseline (from `[PC-xxxx]`)

- Coupler: Pulsar C4-08-411NMF (20 dB directional)
- Part number: 206568
- Manufacturing date code: 2049, Lot #4619
- Application: Reflected power measurement path

### 5.6 Cavity and Beam Baselines

#### 5.6.1 IQA EPICS Configuration (from `[DB-IQA]`)

| Parameter | DRVH | DRVL | HOPR | LOPR | EGU | Notes |
|-----------|------|------|------|------|-----|-------|
| Phase offset | 180 | -180 | 180 | -180 | deg | Per-channel calibration |
| Smooth factor | 1.0 | — | 1.0 | — | — | Signal averaging control |
| Power amplitude | varies | — | varies | — | varies | Set per cavity; HIHI/HIGH per channel |
| Phase measurement | — | — | 180 | -180 | deg | Hysteresis 0.99 deg |

**Alarm configuration**: IQA power measurements use one-sided alarms (LOLO = -1E30, LOW = -1E30) — only upper limits are monitored. The large hysteresis (0.99) reduces alarm chatter from synchrotron oscillation modulation. ADC full-scale is 2047 counts for I/Q.

#### 5.6.2 Tuner DAC Calibration (from `[TD-xxxx]`)

- Equipment: FSW13 spectrum analyzer
- Fixed attenuation: 8 dB in measurement path
- Content: DAC output versus frequency deviation characterization

#### 5.6.3 Galil Tuner Controller Commissioning (from `[GL-2024]`, `[GL-2025]`)

| Parameter | Value | Notes |
|-----------|-------|-------|
| Controller | Galil DMC-4143 Rev 1.3h | Firmware 22285 |
| Motor type | MT -2,-2,-2,-2 | Stepper, 4 axes |
| Microstepping | Enabled (SHB command) | 256 microsteps/step |
| First motion test | 2024 | Initial commissioning |
| AB-to-manual swap | 2025-08-25 | Configuration change for manual control |
| Amplifier gain | AGB=3 | Motor axis B setting |

> **Note**: Legacy tuner resolution was ~0.002–0.003 mm/microstep. With 256 microsteps/step on the Galil, resolution is significantly improved per Doc 0 §19.4.

#### 5.6.4 Beam Loading Data

> **Classification**: G (Gap). No raw beam loading versus current data files found in the workspace. Published reference (McIntosh 2005) confirms 3.2 MV at 500 mA but does not provide intermediate operating points.
>
> **Measurement plan**: Controlled ramp 0–500 mA with EPICS archiver at 1 Hz capturing all 4 cavity probe amplitudes and phases. See §5.10 Data Gap Register.

### 5.7 LLRF Spectral Performance Baselines (from `[L9-2021]`)

This section contains the most critical upgrade justification data — a direct A/B comparison of the legacy LLRF system and the LLRF9 replacement, measured under identical conditions by J. Sebek in early 2021.

#### 5.7.1 Test Conditions

| Parameter | Value |
|-----------|-------|
| Beam current | 500 mA |
| Gap voltage | 2850 kV (nominal) |
| Spectrum analyzer | Rohde & Schwarz FSW13 |
| Span | 50 kHz |
| Resolution bandwidth | 1 Hz |
| Video bandwidth | 1 Hz |
| Monitoring point | Cavity A probe (via 20 dB coupler + 3 dB splitter to FSW13) |
| LLRF9 connection | 9 coupled signals via 20 dB couplers (0.4 dB insertion loss accounted for) |

#### 5.7.2 Power Line Harmonic Rejection

| Harmonic | Unfiltered Level | Legacy Rejection | LLRF9 Rejection | Delta |
|----------|-----------------|------------------|-----------------|-------|
| -720 Hz | -30.9 dBc | 25.8 dB | 16.0 dB | Legacy better by 9.8 dB |
| -360 Hz | -33.6 dBc | 24.9 dB | 18.8 dB | Legacy better by 6.1 dB |
| +360 Hz | -33.6 dBc | 27.0 dB | 21.3 dB | Legacy better by 5.7 dB |
| +720 Hz | -30.9 dBc | 24.0 dB | 20.2 dB | Legacy better by 3.8 dB |

> **Annotation**: The legacy system's superior harmonic rejection is attributed to its dedicated analog "ripple loop" — a specialized feedback path designed specifically for HVPS harmonic suppression. The LLRF9, while a more capable digital system overall, does not include an equivalent dedicated ripple suppression loop in its tested configuration. This is a **known regression** that should be addressed during LLRF9 commissioning tuning. The LLRF9 digital architecture may be able to implement equivalent or superior ripple suppression through its configurable firmware; this should be validated during Doc U-COMM commissioning procedures.

#### 5.7.3 Synchrotron Resonance Comparison

| Parameter | Legacy | LLRF9 | Assessment |
|-----------|--------|-------|------------|
| Frequency (nu_s) | 8,932 Hz | 9,657 Hz | LLRF9 closer to natural frequency (less frequency pulling) |
| Amplitude | -92.8 dBc | -95.9 dBc | LLRF9 better by 3.1 dB |
| Quality factor Q | 11.1 | 16.7 | LLRF9 higher Q indicates less beam excitation |

**Physical interpretation**: The synchrotron resonance is a damped harmonic oscillator driven by beam-cavity interaction. Lower amplitude and higher Q indicate that the LLRF9 feedback provides better damping of coherent synchrotron oscillations. The frequency shift (8.9→9.7 kHz) reflects different feedback-modified cavity impedance; the LLRF9 value is closer to the natural synchrotron frequency, suggesting less impedance modification by the feedback loop.

Additionally, the legacy system introduces a spurious resonance at approximately 2800 Hz (close to but not at the 4th harmonic of 720 Hz) with a width significantly broader than power line harmonics. This is attributed to feedback loop gain peaking in the legacy analog system. The LLRF9 spectrum shows no such artifacts.

#### 5.7.4 Noise Floor

| System | Noise Floor | Conditions |
|--------|------------|------------|
| Raw klystron output | ~-112 dBm | No feedback, no beam |
| Legacy LLRF | ~-112 dBm | 500 mA, full feedback |
| LLRF9 | ~-112 dBm | 500 mA, full feedback |

> The noise floor is measurement-limited (FSW13 instrument noise floor) rather than system-limited. All three measurements yield the same value, confirming the measurement apparatus is the limiting factor.

#### 5.7.5 Raw HVPS Harmonic Levels (Pre-Rejection Reference)

Measured with no LLRF feedback active, gap voltage at nominal 2850 kV, no beam:

| Harmonic | Level (dBc below carrier) |
|----------|--------------------------|
| +/- 360 Hz | -33.6 |
| +/- 720 Hz | -30.9 |
| All 30 Hz multiples | Potentially present |

These represent the HVPS-generated modulation that both LLRF systems must suppress. The raw levels are set by the 12-pulse thyristor switching topology and the LC filter characteristics.

#### 5.7.6 Mapping to Doc 0 Success Criteria

| Doc 0 §19.4 Criterion | Legacy Baseline | LLRF9 Measurement | Verdict | Notes |
|----------------------|-----------------|-------------------|---------|-------|
| Amplitude stability <0.1% | G (not yet captured) | G (not yet captured) | **MEASUREMENT NEEDED** | Requires 24-hr archiver data, not spectrum analysis |
| Phase stability <0.1 deg | G (not yet captured) | G (not yet captured) | **MEASUREMENT NEEDED** | Same — need archiver StdDev, not spectrum |
| Tuner resolution improved | ~0.002–0.003 mm/microstep | 256 microsteps/step (Galil) | **IMPROVED** | Per `[GL-2024]` |
| Control loop response ~1s | G (not yet measured) | G (not yet measured) | **MEASUREMENT NEEDED** | Step response test required |
| Uptime >99% | ~98.5–99.3% (estimated) | — | **BASELINE KNOWN** (estimated) | From `[HR-2024]` analysis |
| Fault diagnostics improved | 15-event circular buffer, limited waveform | 16k-sample + circular buffer proposed | **IMPROVED** | Per Doc 0 §15 |
| Synchrotron resonance damping | -92.8 dBc, Q=11.1 | -95.9 dBc, Q=16.7 | **IMPROVED** | Per `[L9-2021]` |
| HVPS harmonic rejection | ~25 dB (360/720 Hz) | ~19 dB (360/720 Hz) | **REGRESSION** | Ripple loop absent; needs commissioning attention |

### 5.8 Control System Timing Baselines

#### 5.8.1 SNL State Machine Constants (from `[SNL-ST]`)

| Constant | Value | Units | Physical Rationale |
|----------|-------|-------|--------------------|
| NUMFAULTS | 15 | events | Circular buffer size for fault history; 15 events covers ~1 week of typical fault rate |
| NUMFFILES | 11 | files | Waveform buffer count (10→11, changed 2003-06-12): RFP I/Q×4, CF2 I/Q×2, IQA1/IQA2, GVF, AIM history + spare |
| MAXFFWAIT | 180 | seconds | Timeout for fault file I/O operations (3 min); VxWorks disk I/O can be slow under load |
| FILETRY | 60 | retries | Retry count for waveform file read/write operations |
| VACUUMWAIT | 600 | seconds | Recovery time after vacuum event (10 min); allows ion pump recovery after cavity arc. Determined empirically from arc event recovery observations |
| RESETWAIT | 300 | seconds | Minimum time between automatic reset attempts (5 min); prevents rapid cycling that could damage hardware |
| TUNERWAIT | 60 | seconds | Tuner motor settling time (1 min); mechanical backlash and thermal settling |
| LP_ON_WAIT | 5.0 | seconds | Delay before enabling direct RF feedback loop after mode transition; allows transients to settle |
| COMPENSATION_WAIT | 1.0 | seconds | Settling time for compensation (lead/integral) loop gain adjustments |
| MAX_GV_UP_WAIT | 30.0 | seconds | Maximum wait for gap voltage to stabilize before increasing drive power; prevents open-loop power ramp |

#### 5.8.2 Loop Activation Sequence Timing (from `[SNL-ST]`)

The state machine follows a specific sequence when transitioning from OFF to OPERATE:

```
1. OFF → TUNE: Load tune-mode I/Q settings, enable RF switch
2. TUNE → HVPS ON: Enable SCR triggers, wait LP_ON_WAIT (5s) for voltage stabilization
3. HVPS voltage ramp: Increment voltage by KVUP (1 kV) per iteration
4. Wait for gap voltage tolerance: MAX_GV_UP_WAIT (30s) timeout
5. Enable direct loop: volt_settle_time (configurable PV), then LP_ON_WAIT (5s)
6. Enable lead compensation: wait COMPENSATION_WAIT (1s)
7. Enable integral compensation: wait COMPENSATION_WAIT (1s)  
8. Enable comb loop: LP_ON_WAIT (5s) for gain ramp
9. Enable gap voltage feedback: transition complete
10. Enable ripple loop amplitude setpoint: final tuning
```

Total estimated cold-start time: ~2–5 minutes depending on voltage ramp distance.

#### 5.8.3 Fault File Capture Parameters (from `[SNL-ST]`)

| Module | Save PV | Size PV | Get PV | Status PV |
|--------|---------|---------|--------|-----------|
| RFP I sine ref | `STN:RFP:MODU.SIRF` | `STN:RFP:MODU.RMSZ` | `STN:RFP:MODU.GSIR` | `STN:RFP:MODU.SIST` |
| RFP Q sine ref | `STN:RFP:MODU.SQRF` | `STN:RFP:MODU.RMSZ` | `STN:RFP:MODU.GSQR` | `STN:RFP:MODU.SQST` |
| RFP I cos ref | `STN:RFP:MODU.CIRF` | `STN:RFP:MODU.RMSZ` | `STN:RFP:MODU.GCIR` | `STN:RFP:MODU.CIST` |
| RFP Q cos ref | `STN:RFP:MODU.CQRF` | `STN:RFP:MODU.RMSZ` | `STN:RFP:MODU.GCQR` | `STN:RFP:MODU.CQST` |
| CFM1 history | `STN:CFM1:MODU.HFIL` | `STN:CFM1:MODU.HSIZ` | `STN:CFM1:MODU.GHST` | `STN:CFM1:MODU.HSTT` |
| CFM2 history | `STN:CFM2:MODU.HFIL` | `STN:CFM2:MODU.HSIZ` | `STN:CFM2:MODU.GHST` | `STN:CFM2:MODU.HSTT` |
| IQA1 history | `STN:IQA1:MODU.AHFS` | `STN:IQA1:MODU.AHSZ` | `STN:IQA1:MODU.GAHS` | `STN:IQA1:MODU.ASTT` |
| IQA2 history | `STN:IQA2:MODU.AHFS` | `STN:IQA2:MODU.AHSZ` | `STN:IQA2:MODU.GAHS` | `STN:IQA2:MODU.ASTT` |
| GVF result | `STN:GVF:MODU.RFIL` | `STN:GVF:MODU.RSIZ` | `STN:GVF:MODU.GRB` | `STN:GVF:MODU.RSTT` |
| AIM history buffer | `STN:AIM:MODU.HBFN` | `STN:AIM:MODU.HBSZ` | `STN:AIM:MODU.HGET` | `STN:AIM:MODU.HBST` |

> **Upgrade note**: The LLRF9 upgrade replaces this 10-buffer scheme with a 16k-sample per-channel waveform buffer plus a continuous circular buffer. This dramatically improves post-fault analysis capability.

### 5.9 Cross-Facility Reference Data

#### 5.9.1 SPEAR1 HVPS Tests (from `[S1-2022]`)

Date: August 17, 2022. Content: High-pot leakage current tests, thyristor characterization, spare stack qualification for the SPEAR1 RF HVPS. Provides reference for SCR aging comparisons across similar PEP-II-heritage power supplies.

#### 5.9.2 SPEAR2 HVPS Tests (from `[S2-2021]`)

Date: 2021. Content: SCR hipot results, rectifier stack characterization, spare inventory tracking. Provides cross-facility comparison context for SPEAR3 HVPS performance expectations.

### 5.10 Data Gap Register and Planned Measurements

#### 5.10.1 High-Priority Gaps (Must capture before hardware swap)

| ID | Measurement | Why Critical | How to Capture | Deadline |
|----|------------|--------------|----------------|----------|
| G1 | Beam loading vs. current (0–500 mA) | Upgrade acceptance requires stability across full range | Controlled ramp, archiver at 1 Hz, all 4 cavity probes | Before LLRF9 deployment |
| G2 | 24-hour amplitude/phase stability baseline | Doc 0 §19.4 success criteria (<0.1%, <0.1 deg) | EPICS archiver at 10 Hz, stable 500 mA, exclude RF events | March 2026 |
| G3 | Control loop step response | Establishes baseline responsiveness | Oscilloscope at 1 kHz, 5 kV setpoint step, 50 mA beam | March 2026 |
| G4 | Thermal operating profile (24-hr) | Commissioning thermal interlocks on new PLC | Archiver at 0.1 Hz, all temp sensors, stable 500 mA | Apr–May 2026 |

#### 5.10.2 Medium-Priority Gaps

| ID | Measurement | Why Useful | Notes |
|----|------------|-----------|-------|
| G5 | Cavity detuning curve (frequency vs. tuner position) | Tuner control optimization | DAC cal exists but not mechanical transfer function |
| G6 | Klystron saturation curve (output vs. drive level) | Drive amp sizing for LLRF9 | Drive amp cal exists but not full klystron response |
| G7 | HVPS regulator loop gain measurement | Voltage regulation bandwidth | PLC parameters exist but closed-loop response unmeasured |
| G8 | Long-term LLRF9 stability (multi-week) | Validates single-session test data | Requires 4+ weeks post-LLRF9 commissioning |

#### 5.10.3 Data Freshness Assessment

| Data Category | Last Update | Age (as of Mar 2026) | Confidence | Action |
|---------------|------------|---------------------|------------|--------|
| HVPS operating points `[HM-2022]` | 2022-03-14 | 4 years | P | Recalibrate before swap |
| Transformer impedance `[MC-2022]` | 2022-02/03 | 4 years | P | Repeat measurement 2026 |
| HVPS reliability `[HR-2024]` | 2024-03-14 | 2 years | V | Current; continue logging |
| SCR leakage `[PS-2020]` | 2020-07/08 | 5.5 years | P | Re-measure; SCRs have been refurbished since |
| RF patch panel `[PP-xxxx]` | undated | unknown | P | Verify before LLRF9 connection |
| Drive amp `[DA-2020]` | 2020-11-16 | 5.3 years | P | Re-verify if drive amp unchanged |
| Reflected power trips `[RP-2021]` | 2021-02-08 | 5 years | P | Verify before trip threshold transfer to LLRF9 |
| LLRF9 spectral data `[L9-2021]` | early 2021 | 5 years | V | Single-session; extend with `[G8]` |
| Galil commissioning `[GL-2025]` | 2025-08-25 | 0.6 years | V | Recent; high confidence |
| EPICS alarm setpoints `[DB-*]` | RCS latest | current | V | Extract from production database |
| Simulation results `[SIM-HV]` | 2026-03-13 | current | S | Validated model |

---

## 6. Document Dependency and Reference Map

### 6.1 Cross-Reference Matrix

The following matrix shows how each document references other documents in the architecture:

```
                 Doc 0  Doc P  Doc L  Doc D  Doc M  U-HVPS  U-LLRF  U-IF  U-ARC  U-PPS  U-TUN  U-SOFT  U-COMM  U-SAFE  U-DIAG
Doc 0              —      —      —      —      —      —       —      —     —      —      —      —       —       —       —
Doc P              R      —      —      —      —      —       —      —     —      —      —      —       —       —       —
Doc L              R      R      —      —      R      —       —      —     —      —      —      —       —       —       —
Doc D              R      —      R      —      R      —       —      —     —      —      —      —       —       —       —
Doc M              R      —      —      R      —      —       —      —     —      —      —      —       —       —       —
U-HVPS             R      R      R      R      R      —       —      —     —      —      —      —       —       —       —
U-LLRF             R      R      R      R      R      —       —      R     —      —      —      —       —       —       —
U-IF               R      R      R      R      R      —       R      —     R      —      —      —       —       —       —
U-ARC              R      —      R      R      R      —       R      R     —      —      —      —       —       R       —
U-PPS              R      —      R      —      R      R       —      —     —      —      —      —       —       R       —
U-TUN              R      R      R      R      R      —       R      —     —      —      —      —       —       —       —
U-SOFT             R      —      R      R      R      R       R      R     R      —      R      —       —       —       R
U-COMM             R      —      —      R      R      R       R      R     R      R      R      R       —       R       R
U-SAFE             R      —      R      —      R      R       —      R     R      R      —      —       R       —       —
U-DIAG             R      —      R      R      R      —       R      R     —      —      —      R       R       —       —

R = References
```

### 6.2 Writing Priority and Dependencies

Documents should be written in this order based on dependency depth:

| Priority | Document | Depends On | Estimated Size | Status |
|----------|----------|-----------|----------------|--------|
| 0 | Doc 0 | — | ~1,500 lines | **EXISTS** |
| 1 | Doc D | Doc 0 | ~800–1000 lines | To write (this proposal is its specification) |
| 1 | Doc M | Doc 0 | ~400–600 lines | To write (mostly index/catalog) |
| 2 | Doc P | Doc 0 | ~600–800 lines | To write (extract from obsolete docs + literature) |
| 2 | Doc L | Doc 0, Doc M | ~1000–1500 lines | To write (requires full legacy code review synthesis) |
| 3 | Doc U-HVPS | Doc 0, Doc L, Doc D | ~400–600 lines | To write |
| 3 | Doc U-LLRF | Doc 0, Doc L, Doc D | ~500–700 lines | To write |
| 3 | Doc U-IF | Doc 0, Doc L, Doc D, U-LLRF | ~300–500 lines | To write |
| 3 | Doc U-TUN | Doc 0, Doc L, Doc D, U-LLRF | ~300–400 lines | To write |
| 3 | Doc U-ARC | Doc 0, Doc L, Doc D | ~200–300 lines | To write |
| 3 | Doc U-PPS | Doc 0, Doc L | ~200–300 lines | To write |
| 3 | Doc U-SOFT | Doc 0, Doc L, all U-* | ~600–800 lines | To write (last Tier 3, references all others) |
| 3 | Doc U-SAFE | Doc 0, Doc L, U-* | ~300–400 lines | To write |
| 3 | Doc U-DIAG | Doc 0, Doc L, Doc D, U-LLRF | ~300–400 lines | To write |
| 4 | Doc U-COMM | Doc 0, Doc D, all U-* | ~400–600 lines | To write (last, references all upgrade designs) |

### 6.3 Estimated Total Documentation Volume

| Tier | Documents | Estimated Lines | Notes |
|------|-----------|----------------|-------|
| Tier 0 | Doc 0 | 1,500 | Existing |
| Tier 1 | Doc P, Doc L | 1,600–2,300 | New |
| Tier 2 | Doc D, Doc M | 1,200–1,600 | New |
| Tier 3 | 10 × Doc U-* | 3,200–5,100 | New |
| **Total** | **14 documents** | **~7,500–10,500 lines** | Compared to prior 14,600 lines in 8 docs + Doc 0 |

The new structure achieves comparable or slightly reduced volume while eliminating redundancy and providing complete coverage of areas (operational data, document index, commissioning) that were previously unaddressed.

---

## 7. Migration Plan from Obsolete Documents

### 7.1 Content Disposition

The 8 obsolete documents in `Designs/obsolete/` contain material that maps to the new structure as follows:

| Obsolete Document | Physics Content → | Legacy Content → | Upgrade Content → | Data Content → |
|-------------------|-------------------|------------------|-------------------|----------------|
| Doc 1 (Cavity/RF) | Doc P §2–3 | Doc L §9 | Doc U-LLRF §5 | Doc D §5.6 |
| Doc 2 (HVPS Power) | Doc P §6 | Doc L §1–2 | — (power section retained) | Doc D §5.3 |
| Doc 3 (HVPS Controller) | — | Doc L §6 | Doc U-HVPS §5 | Doc D §5.3 |
| Doc 4 (Feedback Loops) | Doc P §7 | Doc L §9 | Doc U-LLRF §5 | Doc D §5.7 |
| Doc 5 (Software) | — | Doc L §3–5, 8, 10 | Doc U-SOFT §5 | Doc D §5.8 |
| Doc 6 (Interlocks) | — | Doc L §7 | Doc U-ARC/U-SAFE §5 | Doc D §5.5 |
| Doc 7 (Tuner) | Doc P §8 | Doc L §9 | Doc U-TUN §5 | Doc D §5.6 |
| Doc 8 (HVPS Controller Design) | Doc P §6 | Doc L §6 | Doc U-HVPS §5 | Doc D §5.3–5.4 |
| Doc A (Legacy SNL) | — | Doc L §4 | Doc U-SOFT §2 | Doc D §5.8 |
| Doc B (Integration) | — | Doc L §1 | Multiple U-* | Doc D §5.7 |

### 7.2 Material Not Migrated

The following categories of content from obsolete documents are intentionally **not** migrated:

1. **Redundant physics explanations** — Each concept appears once in Doc P
2. **Interim design proposals** that were superseded by Doc 0 decisions
3. **Review comments and revision history** — Preserved in git history
4. **Tutorial-style introductions** — Replaced by targeted Doc P sections

---

## 8. Conventions and Standards

### 8.1 File Naming

All documents follow the pattern:
```
{ID}_{TITLE_IN_CAPS}.md
```

Examples:
- `0_SYSTEM_DESIGN_REPORT.md`
- `D_OPERATIONAL_DATA_CATALOG.md`
- `P_RF_PHYSICS_REFERENCE.md`
- `L_LEGACY_SYSTEM_ARCHITECTURE.md`
- `M_MASTER_DOCUMENT_INDEX.md`
- `U-HVPS_CONTROLLER_UPGRADE_DESIGN.md`

### 8.2 Section Numbering

- Doc 0: Frozen section numbers (§1–§20)
- All other documents: Sequential numbering within each document
- Cross-references use the format: `Doc X §Y.Z` (e.g., "Doc 0 §19.4", "Doc D §5.7.2")

### 8.3 Data Reference Tags

Source data is referenced using short tags defined in Doc D §4.4:
- Format: `[TAG]` where TAG is a mnemonic + year (e.g., `[HM-2022]`, `[L9-2021]`, `[DB-HVPS]`)
- Tag definitions are in a single master table in Doc D
- Other documents using the same data reference the tag and cite Doc D

### 8.4 Version Control

- All documents are maintained in the git repository under `Designs/`
- Obsolete documents remain in `Designs/obsolete/` for reference
- Document version is tracked in the header (Version field)
- Significant changes require version increment and change log entry

---

## 9. Open Questions and Decisions Needed

| # | Question | Options | Recommendation | Status |
|---|----------|---------|----------------|--------|
| 1 | Should Doc D include full EPICS PV tables or reference them externally? | (a) Inline tables (b) Appendix (c) External CSV | (b) Appendix — keeps main body readable while providing complete data in the same document | Open |
| 2 | Should Doc U-SOFT be split into architecture + implementation? | (a) Single document (b) U-SOFT-ARCH + U-SOFT-IMPL | (a) Single document with clear section separation — splitting adds cross-reference overhead without significant benefit at current project scale | Open |
| 3 | How to handle the HVPS harmonic rejection regression in LLRF9? | (a) Flag as risk in Doc U-COMM (b) Create dedicated analysis note (c) Address in Doc U-LLRF commissioning section | (a)+(c) — Flag in commissioning plan as a specific test item, with mitigation options documented in Doc U-LLRF | Open |
| 4 | Should the Enerpro FCOG1200 documentation be incorporated into Doc L or remain as separate reference? | (a) Incorporate summary (b) Reference only | (a) — Summary of key operating principles in Doc L §6, with full Enerpro docs referenced via Doc M | Open |
| 5 | What is the update cadence for Doc D after upgrade commissioning? | (a) Per-campaign update (b) Quarterly (c) Annual | (a) Per-campaign — each measurement campaign produces a Doc D revision with new data appended | Open |

---

## 10. Summary

This proposal defines a 14-document architecture organized in 4 tiers:

- **Tier 0**: Doc 0 (System Design Report) — existing, constrained
- **Tier 1**: Doc P (Physics), Doc L (Legacy) — foundation reference
- **Tier 2**: Doc D (Operational Data), Doc M (Document Index) — living references
- **Tier 3**: 10 subsystem upgrade design documents — one per Doc 0 subsystem

The architecture eliminates the layer-mixing, redundancy, and traceability problems identified in the prior 8-document series while preserving all valuable analysis through systematic content migration. Doc D (Operational Data & Baselines Catalog) is the highest-priority new document, providing the consolidated baseline reference needed for upgrade acceptance testing.

Total estimated volume: ~7,500–10,500 lines across 14 documents, compared to ~14,600 lines in the prior structure — achieving better coverage with less redundancy.
