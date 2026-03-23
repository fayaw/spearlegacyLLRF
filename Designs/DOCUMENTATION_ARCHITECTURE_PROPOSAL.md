# SPEAR3 RF System — Documentation Architecture Proposal

**Document**: Documentation Architecture Technical Note
**Version**: 4.0
**Date**: March 22, 2026
**Status**: PROPOSAL — For Review

---

## 1. Purpose

This document proposes a comprehensive reorganization of the SPEAR3 RF system documentation. The goal is to create a clear, navigable, and maintainable documentation set that:

- Separates physics, legacy system reference, and upgrade design into distinct tiers
- Provides a dedicated upgrade design document for each of the 10 subsystems defined in Doc 0
- Accommodates operational data from the currently running system
- Preserves the existing 8-document code review series unchanged
- Constrains only Doc 0 (System Design Report) — all other documents may be completely rewritten or reorganized

---

## 2. Background and Motivation

### 2.1 Current State

The existing `Designs/` folder contains 8 active design documents (~14,600 lines total) plus the System Design Report (Doc 0, ~1,500 lines). Over four rounds of review, several structural problems were identified:

1. **Layer mixing** — Every document blends RF physics, legacy system description, and upgrade design. An engineer looking for "how the legacy HVPS controller works" must read Doc 4 (§2–5), Doc 8 (§3–5), Doc B (§9–11), Doc A (§12), and code review notes 06–07.

2. **Incomplete legacy coverage** — Doc A (`A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md`) covers only the 6 SNL state machine programs in `rfApp/src/seq/`. The full legacy codebase spans 253 functional source files, 82,430+ lines across VXI drivers, DSP firmware, EPICS databases, PLC drivers, and signal processing — all comprehensively analyzed in the 8 code review technical notes (Rev 6).

3. **Missing subsystem documents** — Four of the 10 Doc 0 subsystems lack dedicated upgrade design documents:
   - RF MPS (Subsystem 3) — Hardware assembled, software not started
   - Tuner Control (Subsystem 6) — Galil commissioned Aug 2025, but design scattered across Docs 3, 10, and 0
   - Waveform Buffer (Subsystem 7) — New custom hardware, design exists in docx but no formal design doc
   - Arc Detection (Subsystem 8) — COTS hardware, no standalone design doc

4. **No operational data layer** — The running SPEAR3 RF system has 25+ years of operational history, calibration records, EPICS archiver data, and performance baselines. None of this is systematically captured or cataloged in the workspace.

### 2.2 Design Constraints

| Constraint | Rationale |
|------------|-----------|
| Doc 0 is the only document that must be preserved as-is | Currently under review (PDR-level) |
| All other documents may be completely rewritten or reorganized | Allows optimal structure without backward-compatibility baggage |
| The 8 code review technical notes (Rev 6) are kept unchanged | Already the definitive code-level legacy reference |
| Existing documents serve as reference material for new documents | Content is not lost, only reorganized |

---

## 3. Proposed Architecture

### 3.1 Four-Tier Structure

```
TIER 0 — NAVIGATION
  └── Master Document Index

TIER 1 — RF PHYSICS & PLANT FOUNDATION
  └── Doc P: RF Physics, Control Theory & Physical Plant

TIER 2 — LEGACY SYSTEM & OPERATIONAL REFERENCE
  ├── Doc L: Legacy System Architecture
  ├── Code Review Technical Notes (8 documents, Rev 6)
  └── Doc D: Operational Data & Baselines Catalog

TIER 3 — UPGRADE DESIGN
  ├── Doc 0: System Design Report (UNCHANGED)
  ├── U1:  LLRF Controller Upgrade Design
  ├── U2:  HVPS Upgrade Design
  ├── U3:  RF MPS Upgrade Design                    ← NEW
  ├── U4:  Interface Chassis Upgrade Design
  ├── U5:  PPS Interface Upgrade Design
  ├── U6:  Tuner Control System Upgrade Design       ← NEW
  ├── U7:  Waveform Buffer System Upgrade Design     ← NEW
  ├── U8:  Arc Detection System Upgrade Design       ← NEW
  ├── U9:  Klystron Heater Upgrade Design
  └── U10: Control Software Upgrade Design
```

### 3.2 Tier Separation Principle

Each tier answers a different category of question:

| Tier | Question It Answers | Audience |
|------|---------------------|----------|
| Tier 0 | "Where do I find information about X?" | Everyone |
| Tier 1 | "Why does the cavity detune?" / "What is I/Q processing?" | New engineers, reviewers |
| Tier 2 | "How does the current system work?" / "What does the system measure at 500 mA?" | Upgrade implementers, operators |
| Tier 3 | "What exactly are we building?" / "How does the new HVPS PLC regulate voltage?" | Implementers, testers, reviewers |

A document lives in exactly one tier. Cross-tier references are made by explicit section citation, never by duplicating content.

---

## 4. Tier 0 — Master Document Index

**File**: `Designs/00_MASTER_INDEX.md` (new)

A single navigation page containing:

- **Document catalog**: Every document with its filename, title, tier, subsystem coverage, status, and approximate length
- **Reading paths by role**:
  - *New engineer*: Doc P → Doc L → Doc 0 → subsystem-specific U-docs
  - *Upgrade implementer*: Doc 0 → specific U-doc → Doc L (legacy comparison) → Code Review Notes (code detail)
  - *Reviewer*: Master Index → Doc 0 → U-docs under review → Doc P for physics validation
  - *Operator*: Doc D (baselines) → Doc 0 §2–4 (architecture overview)
- **Subsystem-to-document cross-reference matrix**
- **Dependency graph**: Which documents must be read before which

---

## 5. Tier 1 — Doc P: RF Physics, Control Theory & Physical Plant

**File**: `Designs/P_RF_PHYSICS_AND_PLANT.md` (new)

### 5.1 Purpose

A single authoritative reference for the physics and physical hardware that is common to both the legacy and upgrade systems. All other documents reference Doc P instead of re-deriving physics or re-describing the RF plant.

### 5.2 Source Material

| Content | Current Location | Extraction |
|---------|-----------------|------------|
| Beam-cavity interaction, Robinson instability, detuning | Doc A §3 (5 subsections) | Move |
| I/Q signal processing theory | Doc A §4 (5 subsections) | Move |
| Feedback loop hierarchy and control theory | Doc B §5–6 | Move |
| RF power flow, VSWR, coupling | Doc B §4, Code Review Note 08 | Synthesize |
| Physical plant (klystron, waveguide, cavities, tuners) | Doc 0 §4 | Reference (not duplicate) |
| 24 RF signal monitoring map | Doc 0 §4.6 | Reference |
| Key system parameters (476.315 MHz, gap voltage, beam current) | Doc B §4, Doc 0 §4 | Consolidate |
| Signal processing algorithms (subIQ.c, subSys.c) | Code Review Note 08 | Reference |

### 5.3 Proposed Outline

| Section | Title | Content |
|---------|-------|---------|
| §1 | Introduction | Purpose, scope, system context |
| §2 | Beam-Cavity Interaction | Beam loading, detuning curve, Robinson instability criteria, steady-state gap voltage |
| §3 | RF Cavity Resonator Model | Equivalent circuit, loaded/unloaded Q, coupling factor β, bandwidth, filling time |
| §4 | I/Q Signal Processing | Modulation/demodulation, phase detection, amplitude extraction, coordinate systems |
| §5 | Feedback Control Theory | Direct loop (proportional+integral), tuner loop (phase-based), HVPS loop (voltage regulation), stability analysis — generic, not implementation-specific |
| §6 | Power Flow and Distribution | Klystron → circulator → magic-tee network → 4 cavities, power balance equations, VSWR, reflected power interpretation |
| §7 | Physical Plant Description | Klystron characteristics, waveguide network topology, cavity parameters, tuner mechanism, drive amplifier — references Doc 0 §4 for detailed specifications |
| §8 | System Parameters and Constants | 476.315 MHz operating frequency, nominal gap voltage (2.85 MV), beam current range (0–500 mA), HVPS operating point (74.4 kV, 22 A), key physical constants used in calculations |
| §9 | References | PEP-II design publications, textbook references, cross-references to Doc 0 and code review notes |

### 5.4 What Doc P Does NOT Cover

- Hardware implementation details (legacy or upgrade) — that's Tier 2/3
- LLRF9 FPGA firmware — that's U1
- PLC ladder logic — that's U2/U3
- Operational procedures — that's Doc D / operator guides

---

## 6. Tier 2 — Legacy System & Operational Reference

### 6.1 Doc L: Legacy System Architecture

**File**: `Designs/L_LEGACY_SYSTEM_ARCHITECTURE.md` (new, replaces Doc A + Doc B)

#### 6.1.1 Purpose

A system-level description of how the current (pre-upgrade) SPEAR3 RF station works. Operates at the architecture level — one level above code. An engineer can read Doc L and understand the legacy system without reading source code; they consult the code review technical notes when they need to trace behavior to specific code.

#### 6.1.2 Distinction from Code Review Notes

| Doc L (System Level) | Code Review Notes (Code Level) |
|----------------------|-------------------------------|
| "The HVPS controller uses an SLC-500 PLC with an Enerpro SCR firing board" | "Rung 0016 controls OUT3 on the IO8 module (Slot 2) to drive the Ross switch coil at 120 VAC" |
| "The tuner loop measures cavity probe phase and drives a stepper motor" | "`rf_tuner_loop.st` has 5 SNL states: `s_init`, `s_off`, `s_park`, `s_tune`, `s_on`" |
| "PPS Chain 1 controls the vacuum contactor via the K4 relay" | "K4 relay input side is wired directly to PPS 1 signal (24 VDC), bypassing the PLC" |

#### 6.1.3 Proposed Outline

| Section | Title | Content |
|---------|-------|---------|
| §1 | System Heritage | PEP-II origins (1996–1997), SPEAR3 adaptation (2003), 25+ years of operation |
| §2 | System Overview | VXI 13-slot crate configuration (8 active modules), PLC-5, SLC-500, stepper controllers, signal flow diagram |
| §3 | Control Hierarchy | EPICS/VxWorks → SNL state machines → VXI hardware registers → DSP firmware → analog processing |
| §4 | Operational Modes | OFF/PARK/TUNE/ON_FM/ON_CW state machine, turn-on sequence, fault handling |
| §5 | Subsystem Descriptions | One subsection per Doc 0 subsystem: LLRF (RFP/IQA/Clock), HVPS (SLC-500 + Enerpro FCOG6100 + regulator card), RF MPS (PLC-5 1771), Tuner (1746-HSTP1 + Slo-Syn), Heater (motor-driven variac), Arc Detection (AIM module, non-functional) |
| §6 | EPICS PV Architecture | 76 database files, macro substitution scheme, PV naming conventions (`{STN}:RFP:*`, `{STN}:HVPS:VOLT:*`, etc.) |
| §7 | Protection and Interlock Architecture | Distributed interlocks (no central coordination), PPS wiring through Hoffman Box, fail-safe design issues |
| §8 | Known Limitations | PLC in PPS safety chain, TAXI serial link vulnerability, obsolete components (VTL5C, 1746-HSTP1, SLC-500), no first-fault identification, limited fault diagnostics |
| §9 | Legacy → Upgrade Mapping | Comprehensive table: each legacy component → its upgrade replacement, verdict (ELIMINATED/REPLACED/RETAINED), and reference to the relevant U-doc |
| §10 | References | Cross-references to code review notes, Doc P, and source documents |

#### 6.1.4 Source Material

| Source | Content Extracted |
|--------|-------------------|
| Current Doc A §5–19 | SNL state machine descriptions (system-level summary only; code detail stays in Note 05) |
| Current Doc B §2–3, §7–21 | System configuration, VXI hardware, operational descriptions |
| Code Review Note 00 | Executive summary, architecture comparison, mapping table |
| Code Review Note 02 | PV naming, IOC boot sequence |
| Code Review Note 06 | PLC architecture (3 racks) |
| `pps/diagrams/00_SYSTEM_OVERVIEW.md` | Legacy PPS architecture |

### 6.2 Code Review Technical Notes (Unchanged)

**Location**: `spear-rf-code-legacy/codeReviewTechnicalNotes/` (8 documents, Rev 6)

These remain unchanged. They provide exhaustive code-level analysis of all 253 functional source files:

| Note | File | Content | Lines |
|------|------|---------|-------|
| 00 | `00-executive-summary.md` | System overview, verdict matrix, architecture comparison | ~200 |
| 01 | `01-file-inventory.md` | Every file classified by verdict (ELIMINATED 42%, PEP-II 12%, OBSOLETE 18%, SPEC-EXTRACT 13%, REUSE 2%, PV REFERENCE 18%, DONE 3%) | ~120 |
| 02 | `02-architecture-overview.md` | PV naming conventions, macro substitution, IOC boot sequence, upgrade context | ~200 |
| 03 | `03-vxi-device-support.md` | VXI driver deep dive — all ELIMINATED by LLRF9 | — |
| 04 | `04-dsp-firmware.md` | TMS320C16xx assembly (~16,763 lines) — all ELIMINATED by LLRF9 FPGA | — |
| 05 | `05-snl-state-machines.md` | 6 SNL programs: state diagrams, PV dependencies, upgrade mapping | — |
| 06 | `06-plc-stepper-motors.md` | PLC-5, SLC-500, HSTP1 architecture — all ELIMINATED or DONE | — |
| 07 | `07-epics-databases.md` | 76 database files, PV architecture, GVF/TAXI dependency | — |
| 08 | `08-signal-processing.md` | subIQ.c (23 functions, 965 lines) + subSys.c — physics algorithms, REUSE candidates | — |

### 6.3 Doc D: Operational Data & Baselines Catalog

**File**: `Designs/D_OPERATIONAL_DATA_CATALOG.md` (new)

#### 6.3.1 Purpose

Catalogs what operational data exists, what needs to be captured from the running system before hardware replacement, and how measured baselines map to upgrade acceptance criteria.

#### 6.3.2 Proposed Outline

| Section | Title | Content |
|---------|-------|---------|
| §1 | Data Already in Workspace | Inventory of existing measurement and calibration files |
| §2 | Data Collection Plan | What to capture from the running system, which PVs, at what rate |
| §3 | Acceptance Criteria Mapping | Legacy measured performance → upgrade success criteria (Doc 0 §19.4) |
| §4 | Collection Procedures | How to extract EPICS archiver data, naming conventions, storage format |

#### 6.3.3 Existing Data Inventory

| Data | Location | Type |
|------|----------|------|
| HVPS operating measurements (2022, 500 mA) | `hvps/documentation/plc/hvpsMeasurements20220314.xlsx` | Measured |
| RF calibration — patch panel | `llrf/calibrations/b132R11PatchPanel.xlsx` | Calibration |
| RF calibration — drive amplifier | `llrf/calibrations/driveAmpCalibration.xlsx` | Calibration |
| RF calibration — klystron coupler | `llrf/calibrations/klystronCouplerDriveAmpCalibrations.xlsx` | Calibration |
| RF calibration — Pulsar coupler | `llrf/calibrations/pulsarCouplerCalibration2049.xlsx` | Calibration |
| RF calibration — reflected power | `llrf/calibrations/reflectedPowerCalibrations.xlsx` | Calibration |
| RF calibration — DAC tuning | `llrf/calibrations/tuneModeDacCalibration.xlsx` | Calibration |
| LLRF9 test results | `llrf/tests/llrf9Tests.pdf`, `llrf/tests/llrf9Tests.tex` | Test |
| Galil tuner commissioning logs | `llrf/tuners/galil/functioningGalil20250825SwapABToManual.txt`, `firstMotion2024.txt` | Commissioning |
| HVPS simulation results | `hvps/simulation/hvps_sim/simulation_results/` | Simulation |
| PySpice simulation results | `hvps/simulation/pyspice_sim/simulation_results/` | Simulation |

#### 6.3.4 Data to Capture from Running System

| Category | Example PVs | Rate | Priority |
|----------|-------------|------|----------|
| Steady-state RF amplitudes | `SRF1:CAV{A-D}:PROBE:AMPL` | 10 Hz snapshot | Critical |
| Steady-state RF phases | `SRF1:CAV{A-D}:PROBE:PHASE` | 10 Hz snapshot | Critical |
| HVPS operating point | `SRF1:HVPS:VOLT:RBCK`, `SRF1:HVPS:CURR:RBCK` | 1 Hz | Critical |
| Forward/reflected power per cavity | `SRF1:CAV{A-D}:FWD:PWR`, `SRF1:CAV{A-D}:REFL:PWR` | 1 Hz | Critical |
| Tuner positions | Potentiometer readbacks | 1 Hz | Critical |
| Feedback loop gains | Direct loop, HVPS loop, tuner loop gains | Save/restore snapshot | High |
| Temperature profiles | SCR, transformer, oil, ambient thermocouples | 0.1 Hz | Medium |
| Trip event statistics | Fault file archives, trip count, first-fault distribution | Event-driven | High |
| Klystron heater parameters | Heater voltage, current, power, elapsed time | 1 Hz | Medium |
| Beam loading characterization | All RF signals vs. beam current (0–500 mA ramp) | Archiver extract | Critical |

#### 6.3.5 Acceptance Criteria Mapping

From Doc 0 §19.4:

| Metric | Baseline to Capture | How to Measure | Upgrade Target |
|--------|---------------------|----------------|----------------|
| Amplitude stability | Archiver: probe amplitude variance at 500 mA, 24-hour window | Standard deviation of `SRF1:CAV{A-D}:PROBE:AMPL` | <0.1% (same or better) |
| Phase stability | Archiver: probe phase variance at 500 mA, 24-hour window | Standard deviation of `SRF1:CAV{A-D}:PROBE:PHASE` | <0.1 deg (same or better) |
| Tuner resolution | Measured step size from Galil commissioning logs | Step response measurement | Improved (256 microsteps/step) |
| Control loop response | Step response test: HVPS setpoint change → readback settled | Archiver: timestamp analysis | ~1 second (same or better) |
| Uptime | Operator logs: unplanned downtime over 12-month window | Total operational hours minus fault downtime | >99% (same or better) |
| Fault diagnostics | Legacy: fault file capture only | — | 16k-sample waveform + circular buffer + first-fault |

---

## 7. Tier 3 — Upgrade Design Documents

### 7.1 Doc 0: System Design Report (UNCHANGED)

**File**: `Designs/0_SYSTEM_DESIGN_REPORT.md` (~1,500 lines)

The PDR-level system overview defining all 10 subsystems, the upgraded architecture, physical layout, inter-subsystem interface matrix, protection chain, implementation phases, and risk summary. This is the only constrained document.

### 7.2 Subsystem Upgrade Documents (U1–U10)

Each document covers one subsystem's upgrade design. The numbering aligns with Doc 0's subsystem numbering for clear cross-referencing.

#### 7.2.1 Document Disposition Table

| Doc | Subsystem | Based On | Action | Notes |
|-----|-----------|----------|--------|-------|
| **U1** | LLRF Controller | Current Doc 3 (~3,500 lines, polished) | **Reuse** | May expand tuner LLRF9 content; migrate legacy content to Doc L |
| **U2** | HVPS | Current Doc 4 (~2,500 lines, polished) | **Reuse** | Legacy power section / controller content optionally migrated to Doc L |
| **U3** | RF MPS | No dedicated document exists | **NEW** | ControlLogix 1756, EPICS IOC design, fault aggregation, Interface Chassis interaction |
| **U4** | Interface Chassis | Current Doc 11 (~1,500 lines, mostly complete) | **Reuse** | On critical path; zero implementation started |
| **U5** | PPS Interface | Current Doc 8 (~2,000 lines, polished) | **Reuse** | Legacy PPS content optionally migrated to Doc L |
| **U6** | Tuner Control | Content split across Docs 3, 10, and 0 | **NEW** | Galil DMC-4143, EPICS motor records, load angle algorithm, commissioning data |
| **U7** | Waveform Buffer | Mentions in Docs 3, 10, 11 | **NEW** | Source: `llrf/architecture/WaveformBuffersforLLRFUpgrade.docx` |
| **U8** | Arc Detection | Mentions in Doc 11 | **NEW** | Source: `llrf/architecture/arcDetectorHardwareOptions.docx`, `llrf/arcDetector/` |
| **U9** | Klystron Heater | Current Doc 5 (~1,100 lines, near-complete) | **Reuse** | Chroma programmable AC supply, ASYN EPICS module |
| **U10** | Control Software | Current Doc 10 (~2,000 lines, polished) | **Reuse** | Python/PyEPICS/MATLAB coordinator, 17 modules |

#### 7.2.2 New Document Outlines

**U3 — RF MPS Upgrade Design** (new)

| Section | Content |
|---------|---------|
| §1 | Purpose and scope (equipment protection, distinct from facility SPEAR MPS) |
| §2 | Legacy system (PLC-5 1771, distributed interlocks, no central coordination) |
| §3 | Protection philosophy (from `RFSystemMPSRequirements.docx`) |
| §4 | ControlLogix 1756 hardware (module selection, I/O configuration) |
| §5 | Interface Chassis interaction (Summary Permit, Heartbeat, Reset → IC; fault status ← IC) |
| §6 | Layered protection architecture (Layer 1–4 response times) |
| §7 | Collector power protection (DC power calculation, redundant with Waveform Buffer) |
| §8 | EPICS IOC design (`SRF1:MPS:` PVs, fault logging, state reporting) |
| §9 | Fault handling and recovery sequencing |
| §10 | Heater control integration (Chroma analog ramp via MPS DAC) |
| §11 | Implementation status, test results, and integration plan |

**U6 — Tuner Control System Upgrade Design** (new)

| Section | Content |
|---------|---------|
| §1 | Purpose and cavity tuning physics (reference Doc P §3) |
| §2 | Legacy system (1746-HSTP1 + Slo-Syn, `rf_tuner_loop.st`) |
| §3 | Galil DMC-4143 hardware (4-axis, Rev 1.3h, Ethernet) |
| §4 | LLRF9 tuner support (10 Hz phase, built-in tuner PVs per cavity) |
| §5 | Control loop architecture (LLRF9 phase → Python → EPICS motor record → Galil → stepper) |
| §6 | Load angle offset algorithm (amplitude balancing across 4 cavities) |
| §7 | EPICS motor record configuration (`SRF1:MTR:` PVs) |
| §8 | Home position management and park sequence |
| §9 | Commissioning results (August 2025 data, `llrf/tuners/galil/`) |
| §10 | Risk: hardest-to-prove subsystem; booster tuner test plan |

**U7 — Waveform Buffer System Upgrade Design** (new)

| Section | Content |
|---------|---------|
| §1 | Purpose (extended RF monitoring, HVPS monitoring, collector power protection) |
| §2 | Channel configuration (8 RF channels, 4 HVPS channels) |
| §3 | RF signal assignment (6 signals not covered by LLRF9 units + 2 spares) |
| §4 | HVPS signal conditioning (voltage dividers, current transformers, inductor voltages) |
| §5 | Circular buffer architecture (kHz acquisition, pre-fault capture, freeze-on-trigger) |
| §6 | Analog comparator trips (per-channel thresholds, Interface Chassis interface) |
| §7 | Enhanced collector power protection algorithm |
| §8 | PCB design and hardware specification |
| §9 | EPICS IOC (`SRF1:WFBUF:` PVs, waveform readout, threshold configuration) |
| §10 | Interface Chassis integration (comparator trip outputs → IC permit logic) |

**U8 — Arc Detection System Upgrade Design** (new)

| Section | Content |
|---------|---------|
| §1 | Purpose (optical arc detection for cavity windows, klystron, circulator) |
| §2 | Legacy system (VXI AIM module — non-functional) |
| §3 | Microstep-MIS technology (optical fiber sensors, dry-contact relay output, µs response) |
| §4 | Sensor installation (10 sensors: 8 on cavity windows, 1 klystron, 1 circulator) |
| §5 | Receiver-to-sensor assignment (6 receivers: 5 active, 1 spare) |
| §6 | Arc Detection Chassis design (OR-gate permit, 10-bit latching register) |
| §7 | Signal path (sensors → receivers → Arc Chassis → Interface Chassis) |
| §8 | Mechanical mounting (CF flange viewport adapters, fiber routing) |
| §9 | EPICS interface (per-sensor trip PVs, event count, latch reset) |
| §10 | Arc Detection Chassis → Interface Chassis interface specification |

### 7.3 Standard Upgrade Document Structure

Each U-doc follows a consistent structure where applicable:

1. **Purpose and scope**
2. **Legacy system description** (brief; references Doc L for detail)
3. **Upgrade requirements** (derived from Doc 0 section for this subsystem)
4. **Hardware design** (component selection, configuration, specifications)
5. **Software/firmware design** (EPICS IOC, PLC code, FPGA configuration)
6. **Interface specification** (connections to other subsystems; references Doc 0 §16 interface matrix)
7. **EPICS PV catalog** (complete PV list with types, update rates, descriptions)
8. **Protection and interlock integration** (how this subsystem participates in the protection chain)
9. **Implementation status and test results**
10. **Source documents and references**

---

## 8. Current Documents — Disposition Summary

### 8.1 Documents Replaced

| Document | Replaced By | Rationale |
|----------|-------------|-----------|
| `A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` | Doc P (physics, §3–4) + Doc L (system-level legacy) | Doc A covers only 6 SNL programs; physics content belongs in Tier 1; system-level content belongs in Doc L; code-level detail already exists in code review notes |
| `B_SPEAR3_CURRENT_LLRF_TECHINICAL_DESIGN_REPORT.md` | Doc P (physics, §4–6) + Doc L (legacy architecture) | Monolithic document mixing physics, legacy system, and upgrade. Clean separation into appropriate tiers eliminates duplication |

### 8.2 Documents Reused (with optional refocusing)

| Document | Becomes | Refocusing |
|----------|---------|------------|
| `3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` | U1 | Optionally expand tuner LLRF9 content; legacy LLRF description migrated to Doc L |
| `4_HVPS_Engineering_Technical_Note.md` | U2 | Legacy power section / controller content optionally migrated to Doc L |
| `5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md` | U9 | Minor: legacy variac description can reference Doc L instead of inline |
| `8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` | U5 | Legacy PPS chain description optionally migrated to Doc L |
| `10_SOFTWARE_DESIGN_DOCUMENT.md` | U10 | No changes needed — already a clean upgrade-only SDD |
| `11_INTERFACE_CHASSIS_DESIGN.md` | U4 | No changes needed — already a clean upgrade-only design |

### 8.3 Documents Created

| Document | Tier | Priority | Estimated Effort |
|----------|------|----------|-----------------|
| Master Index | 0 | 8th | Low — catalog of other documents |
| Doc P: RF Physics & Plant | 1 | 2nd | Medium — extract and consolidate from Docs A, B, Note 08 |
| Doc L: Legacy System Architecture | 2 | 7th | Medium — synthesize from Docs A, B, code review notes, PPS diagrams |
| Doc D: Operational Data Catalog | 2 | 1st | Medium — inventory + collection plan + acceptance mapping |
| U3: RF MPS | 3 | 3rd | High — new design document for assembled but un-documented subsystem |
| U6: Tuner Control | 3 | 5th | Medium — consolidate scattered content + commissioning data |
| U7: Waveform Buffer | 3 | 4th | Medium — formalize existing docx design |
| U8: Arc Detection | 3 | 6th | Low — COTS hardware, straightforward design |

---

## 9. Coverage Verification

### 9.1 Subsystem × Tier Matrix

Every cell shows which document provides coverage. Empty cells indicate the subsystem did not exist in that context (e.g., Interface Chassis had no legacy equivalent).

| Subsystem | Tier 1 (Physics) | Tier 2 (Legacy) | Tier 3 (Upgrade) |
|-----------|:---:|:---:|:---:|
| S1 LLRF Controller | Doc P §3–4 | Doc L §2–5 + Notes 03, 04, 05 | **U1** |
| S2 HVPS | Doc P §6 | Doc L §5 + Notes 06, 07 | **U2** |
| S3 RF MPS | — | Doc L §5, §7 + Note 06 | **U3** (new) |
| S4 Interface Chassis | — | Doc L §7 (did not exist) | **U4** |
| S5 PPS Interface | — | Doc L §5, §7 + PPS diagrams | **U5** |
| S6 Tuner Control | Doc P §2–3 | Doc L §5 + Notes 05, 06 | **U6** (new) |
| S7 Waveform Buffer | Doc P §6 (signals) | — (did not exist) | **U7** (new) |
| S8 Arc Detection | — | Doc L §5 (legacy non-functional) | **U8** (new) |
| S9 Klystron Heater | — | Doc L §5 | **U9** |
| S10 Control Software | — | Doc L §3–4, §6 + Notes 05, 07 | **U10** |
| **Cross-cutting** | Doc P §7–8 | **Doc D** (operational data) | Doc 0 (system) |

### 9.2 Gap Check

No subsystem lacks coverage in any applicable tier. The four previously-missing upgrade documents (U3, U6, U7, U8) are now explicitly planned.

---

## 10. Implementation Priority

Ordered by urgency and dependency:

| Priority | Document | Rationale |
|----------|----------|-----------|
| **1** | **Doc D** (Operational Data Catalog) | **Time-sensitive**: Once legacy hardware is replaced, you lose the ability to measure its baseline performance. Must capture before any hardware swap. |
| **2** | **Doc P** (RF Physics & Plant) | Foundation for all other documents. New upgrade docs need to reference physics without re-deriving it. |
| **3** | **U3** (RF MPS) | Hardware assembled and tested; EPICS IOC development not started (Doc 0: "High" risk). Design doc needed to drive software development. |
| **4** | **U7** (Waveform Buffer) | New custom hardware. Design exists in docx (`WaveformBuffersforLLRFUpgrade.docx`) but needs formal design document. Doc 0: "Medium" risk. |
| **5** | **U6** (Tuner Control) | Galil commissioned Aug 2025, operational. Load angle algorithm and Python coordinator integration need documentation. Doc 0: "High" risk (hardest-to-prove subsystem). |
| **6** | **U8** (Arc Detection) | COTS hardware (Microstep-MIS). Straightforward OR-gate + latch chassis design. Needed before Interface Chassis (U4) integration. |
| **7** | **Doc L** (Legacy System Architecture) | Can be written in parallel with other work. Replaces mixed content in current Docs A and B. |
| **8** | **Master Index** | Written last, once other documents exist. |

Documents that already exist (U1, U2, U4, U5, U9, U10) require only optional refocusing — this is low priority and can be done incrementally.

---

## 11. Open Questions for Review

1. **Document naming/numbering**: This proposal uses `U1`–`U10` aligned with Doc 0's subsystem numbers. Alternative: retain the current arbitrary numbering (Doc 3, 4, 5, etc.) for backward compatibility.

2. **Legacy content in existing docs**: Docs 4 (HVPS) and 8 (PPS) contain substantial legacy descriptions alongside upgrade design. Should the legacy content:
   - (a) Stay in the U-docs (self-contained, but still mixes tiers), or
   - (b) Be migrated to Doc L (clean tier separation, but requires refactoring existing polished docs)?

3. **Tuner document scope**: Should the tuner upgrade design be:
   - (a) A standalone document (U6), or
   - (b) Expanded within U1 (LLRF Controller), since LLRF9 provides the phase data?

4. **Doc D priority**: The proposal puts Doc D first because operational data capture is time-sensitive. Does this align with the project schedule?

5. **Archived documents**: The `Archived/` folder contains earlier drafts (PDR V0, earlier software design). Should these be kept in `Archived/` as historical reference, or removed?

---

## 12. Summary

| Metric | Current (v3) | Proposed (v4) |
|--------|:---:|:---:|
| Total design documents | 8 + Doc 0 | 14 + Doc 0 + Master Index |
| Subsystems with dedicated upgrade docs | 6 of 10 | **10 of 10** |
| Documents mixing physics/legacy/upgrade | 6 of 8 | **0** (clean tier separation) |
| Legacy codebase coverage | Doc A (6 SNL programs only) | Doc L (system-level) + **8 code review notes** (253 files, 82K+ lines) |
| Operational data framework | None | **Doc D** (catalog + collection plan + acceptance mapping) |
| Navigation system | None | **Master Index** (reading paths by role, cross-reference matrix) |
| Constrained documents | All (refocus only) | **Doc 0 only** (everything else freely reorganized) |

---

## Appendix A: Full Document List (Proposed)

| ID | Tier | Filename | Title | Status |
|----|------|----------|-------|--------|
| — | 0 | `00_MASTER_INDEX.md` | Master Document Index | Planned |
| P | 1 | `P_RF_PHYSICS_AND_PLANT.md` | RF Physics, Control Theory & Physical Plant | Planned |
| L | 2 | `L_LEGACY_SYSTEM_ARCHITECTURE.md` | Legacy System Architecture | Planned |
| — | 2 | `codeReviewTechnicalNotes/` (8 files) | Legacy Code Review (Rev 6) | **Complete** |
| D | 2 | `D_OPERATIONAL_DATA_CATALOG.md` | Operational Data & Baselines Catalog | Planned |
| 0 | 3 | `0_SYSTEM_DESIGN_REPORT.md` | System Design Report | **Under Review** |
| U1 | 3 | `U1_LLRF_CONTROLLER.md` | LLRF Controller Upgrade Design | Exists (as Doc 3) |
| U2 | 3 | `U2_HVPS.md` | HVPS Upgrade Design | Exists (as Doc 4) |
| U3 | 3 | `U3_RF_MPS.md` | RF MPS Upgrade Design | Planned |
| U4 | 3 | `U4_INTERFACE_CHASSIS.md` | Interface Chassis Upgrade Design | Exists (as Doc 11) |
| U5 | 3 | `U5_PPS_INTERFACE.md` | PPS Interface Upgrade Design | Exists (as Doc 8) |
| U6 | 3 | `U6_TUNER_CONTROL.md` | Tuner Control System Upgrade Design | Planned |
| U7 | 3 | `U7_WAVEFORM_BUFFER.md` | Waveform Buffer System Upgrade Design | Planned |
| U8 | 3 | `U8_ARC_DETECTION.md` | Arc Detection System Upgrade Design | Planned |
| U9 | 3 | `U9_KLYSTRON_HEATER.md` | Klystron Heater Upgrade Design | Exists (as Doc 5) |
| U10 | 3 | `U10_CONTROL_SOFTWARE.md` | Control Software Upgrade Design | Exists (as Doc 10) |

---

## Appendix B: Source Document Traceability

This appendix maps how content from current documents flows into the proposed architecture.

### Doc A → Proposed Architecture

| Current Doc A Section | Proposed Destination |
|----------------------|---------------------|
| §1–2 (Introduction, System Heritage) | Doc L §1 |
| §3 (Cavity Physics, 5 subsections) | **Doc P §2–3** |
| §4 (IQ Signal Processing, 5 subsections) | **Doc P §4** |
| §5–11 (SNL State Machines) | Doc L §3–4 (system-level summary); Code Review Note 05 (code-level detail) |
| §12–19 (HVPS, Tuner, Calibration details) | Doc L §5 (subsystem descriptions) |
| Appendices (PV lists, state tables) | Doc L §6 (PV architecture) |

### Doc B → Proposed Architecture

| Current Doc B Section | Proposed Destination |
|----------------------|---------------------|
| §1–3 (Heritage, System Overview) | Doc L §1–2 |
| §4 (RF Physics) | **Doc P §2, §6** |
| §5–6 (Feedback Loop Hierarchy) | **Doc P §5** |
| §7–21 (VXI Hardware, Operations, Loops) | Doc L §2–5 |
| §22 (Upgrade Summary) | Eliminated — superseded by Doc 0 and U-docs |
| §23 (References) | Distributed to relevant documents |

---
