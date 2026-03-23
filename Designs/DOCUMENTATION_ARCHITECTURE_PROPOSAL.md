# SPEAR3 RF System — Documentation Architecture

**Document ID**: DOCUMENTATION_ARCHITECTURE  
**Version**: 5.0  
**Date**: March 23, 2026  
**Status**: PROPOSAL — For Review  
**Supersedes**: v4.0 (March 22, 2026)  
**Author**: Faya Wang, with AI-assisted analysis  

---

## Revision History

| Version | Date | Description |
|---------|------|-------------|
| 5.0 | 2026-03-23 | Complete rewrite: verified all source document references against actual repository contents; added comprehensive inventory of 123 existing markdown files and 300+ source documents; incorporated Ben Morris PPS Interface Upgrade Proposal; added documentation gap analysis; formalized technical-notes convention; restructured with per-subsystem inventories |
| 4.0 | 2026-03-22 | Four-tier architecture proposal with traceability appendices |
| 3.0 | 2026-03-21 | Revised upgrade document scope and numbering |
| 2.0 | 2026-03-20 | Added reading-path matrix and cross-reference table |
| 1.0 | 2026-03-19 | Initial documentation architecture concept |

---

## Table of Contents

1. [Purpose and Scope](#1-purpose-and-scope)
2. [Four-Tier Documentation Architecture](#2-four-tier-documentation-architecture)
3. [Current Repository State — What Already Exists](#3-current-repository-state--what-already-exists)
4. [Tier 0 — Master Document Index](#4-tier-0--master-document-index)
5. [Tier 1 — RF Physics, Control Theory and Physical Plant (Doc P)](#5-tier-1--rf-physics-control-theory-and-physical-plant-doc-p)
6. [Tier 2 — Legacy System and Operational Reference](#6-tier-2--legacy-system-and-operational-reference)
7. [Tier 3 — Upgrade Design Documents](#7-tier-3--upgrade-design-documents)
8. [Subsystem Documentation Inventories](#8-subsystem-documentation-inventories)
9. [Documentation Gap Analysis](#9-documentation-gap-analysis)
10. [Reading Paths by Role](#10-reading-paths-by-role)
11. [Document Conventions and Standards](#11-document-conventions-and-standards)
12. [Implementation Priorities and Action Items](#12-implementation-priorities-and-action-items)
13. [Appendix A — Subsystem × Tier Cross-Reference Matrix](#appendix-a--subsystem--tier-cross-reference-matrix)
14. [Appendix B — Traceability: Original Documents to Proposed Architecture](#appendix-b--traceability-original-documents-to-proposed-architecture)
15. [Appendix C — Source Document Lineages](#appendix-c--source-document-lineages)

---

## 1. Purpose and Scope

This document proposes a comprehensive reorganization of the SPEAR3 RF system documentation. The SPEAR3 RF system is undergoing a major controls upgrade — replacing VXI-based PEP-II heritage hardware with a modern Dimtel LLRF9 controller, new interface chassis, and updated PLC/controls infrastructure. The documentation must serve three simultaneous needs:

1. **Preserve institutional knowledge** of the legacy PEP-II/SPEAR3 system before hardware is removed
2. **Support the upgrade design** with clear, modular engineering documents
3. **Enable future maintainers** to understand both the physics and the implementation

### 1.1 What This Document Is

This is an **architecture proposal** — it defines the organizational structure, identifies what already exists and where, catalogs what is missing, and proposes a plan to fill the gaps. It is not itself a technical document about the RF system.

### 1.2 Repository Scope

This proposal covers the entire `spearlegacyLLRF` repository:

| Directory | Content | Files |
|-----------|---------|-------|
| `hvps/` | High Voltage Power Supply — architecture, controls, schematics, PLC, switchgear, procedures, maintenance, simulation | 58 MD + ~100 PDF/docx/xlsx |
| `llrf/` | Low-Level RF — legacy architecture, transcriptions, filament heater, calibrations, arc detector, tuners, tests, LLRF9 | 26 MD + ~80 PDF/docx/xlsx |
| `pps/` | Personnel Protection System — system analysis, upgrade proposal | 13 MD + ~10 PDF |
| `spear-rf-code-legacy/` | Complete legacy codebase (2,293 files) with 8-document code review series | 9 MD + 2,293 source files |
| `Designs/` | System Design Report, this proposal, obsolete design docs | 14 MD + docx/vsdx |
| `Docs_JS/` | Jim Sebek's original docx files (canonical copies also exist in `llrf/architecture/`) | 4 docx |
| `Archived/` | Earlier document drafts (superseded) | 3 MD + 2 docx |

**Total**: 123 markdown files (47,733 lines), plus hundreds of PDFs, schematics, spreadsheets, and source code files.


---

## 2. Four-Tier Documentation Architecture

The documentation is organized into four tiers that progress from navigation and overview down to detailed engineering specifications. This structure reflects how the repository has organically evolved and formalizes it into a coherent framework.

```
Tier 0 ─── Master Document Index (navigation layer)
  │
Tier 1 ─── RF Physics, Control Theory & Physical Plant (Doc P)
  │         One document: physics that doesn't change with the upgrade
  │
Tier 2 ─── Legacy System & Operational Reference
  │         ├── Doc L  — Legacy System Architecture (consolidated reference)
  │         ├── Code Review Technical Notes (00–08) — definitive code analysis
  │         ├── Doc D  — Operational Data Catalog (measurements, calibrations)
  │         └── Subsystem Technical Notes (existing series in hvps/, llrf/, pps/)
  │
Tier 3 ─── Upgrade Design Documents
            ├── Doc 0  — System Design Report (top-level PDR)
            └── U1–U10 — Individual subsystem upgrade specifications
```

### 2.1 Key Principles

1. **Physics is separated from implementation.** Tier 1 (Doc P) covers cavity equations, beam loading, feedback theory, and plant parameters. These do not change when the hardware is upgraded.

2. **Legacy knowledge is preserved, not duplicated.** The extensive technical-notes series already written for each subsystem (hvps/, llrf/, pps/) remain in their current locations and serve as the authoritative detailed reference. Doc L provides a consolidated cross-subsystem view that points into them.

3. **Upgrade documents are modular.** Each upgrade document (U1–U10) covers one subsystem and can be written, reviewed, and approved independently.

4. **Existing work is leveraged.** The repository already contains 123 markdown documents. This architecture codifies what exists, identifies specific gaps, and defines standards for new documents — it does not start from scratch.

5. **Traceability is explicit.** Every piece of legacy content can be traced from its original source (PDF, schematic, docx) through transcription and analysis to its final location in the architecture.

---

## 3. Current Repository State — What Already Exists

Before defining what to create, it is essential to understand what already exists. The repository is **far more mature than earlier versions of this proposal acknowledged**.

### 3.1 Documentation by Subsystem — Summary

| Subsystem | Technical Notes | Transcriptions | Source PDFs | Schematics | Procedures | Other |
|-----------|----------------|----------------|-------------|------------|------------|-------|
| HVPS Architecture | 7 (00–06) | 3 (PEP-II, ps341, slac-pub) | 3 | — | — | 10 design notes (docx) |
| HVPS Controls/Enerpro | 9 (00–08) | — | — | — | — | — |
| HVPS PLC | 10 (01–09 + overview) | — | — | — | — | — |
| HVPS Schematics | 14 (system overview + 13 schematic analyses) | — | 11 | — | — | — |
| HVPS Switchgear | 5 (overview + 4 TN) | — | — | — | — | — |
| HVPS Wiring | 1 (phase tank) | — | — | — | — | — |
| HVPS Procedures | — | — | — | — | ~40 (EWP, SR, lockout, safety) | — |
| HVPS Maintenance | — | — | — | — | — | 6 (checklists, reliability, test data) |
| HVPS Simulation | — | — | — | — | — | 2 packages (hvps_sim, pyspice_sim) |
| LLRF Legacy Architecture | 6 (00–05) | 17 (3 block diagrams, 3 design specs, 9 op procedures, 2 conf papers) | ~30 (via catalog) | — | — | — |
| LLRF Filament Heater | 1 (comprehensive TN) | — | — | — | — | — |
| LLRF Local Panel | — | — | 13 | — | — | — |
| LLRF Legacy Interface Modules | — | — | 3 | — | — | — |
| LLRF MPS Wiring | — | — | 33 | — | — | — |
| LLRF Coax Cables | — | — | 1 (sd) | — | — | — |
| LLRF Calibrations | — | — | — | — | — | 6 (xlsx) |
| LLRF Tests | — | — | — | — | — | 1 (llrf9Tests.pdf/tex) + graphics |
| LLRF Arc Detector | — | — | 3 (product sheets, tups072) | — | — | 1 mechanical subdir |
| LLRF Architecture (Design) | — | — | — | — | — | 6 (docx: waveform buffers, analog, arc det, interface, tasks, power det) |
| LLRF Tuners/Galil | — | — | 2 (manual, datasheet) | — | — | commissioning docx, firmware, logs |
| LLRF LLRF9 | — | — | 1 (llrf9_manual) | — | — | iGp subdirectory |
| LLRF Drive Amp | — | — | 1 (KAW2051M12 datasheet) | — | — | — |
| PPS | 10 (00–08 + README) | — | — | — | — | 2 (Ben Morris proposal, Jim Sebek email) |
| Code Review | 9 (00–08) | — | — | — | — | — |
| Designs | — | — | — | — | — | Doc 0 (PDR), this proposal, 8 obsolete docs, todo list |

### 3.2 Documentation Lineages

The repository contains three distinct documentation lineages that flow into the proposed architecture:

**Lineage 1: Original Source Materials**
- Legacy PDF schematics and drawings (hvps/documentation/schematics/*.pdf, llrf/documentation/localPanel/*.pdf, llrf/documentation/mpsWiringDiagrams/*.pdf, etc.)
- Jim Sebek's original docx files (Docs_JS/ and hvps/architecture/designNotes/)
- PEP-II engineering documents (hvps/architecture/originalDocuments/)
- Equipment datasheets and product sheets (llrf/arcDetector/, llrf/driveAmp/, llrf/tuners/galil/)

**Lineage 2: Transcriptions and Detailed Analysis**
- OCR transcriptions of legacy PDFs (hvps/architecture/originalDocuments/transcriptions/, llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/)
- Schematic-by-schematic analysis notes (hvps/documentation/schematics/technical_notes/)
- Component-level technical notes (hvps/controls/enerpro/technical-notes/, hvps/documentation/plc/technical-notes/)
- System-level technical notes (hvps/architecture/technical-notes/, llrf/documentation/legacyArchitecture/technical-notes/, pps/diagrams/)

**Lineage 3: Design and Planning Documents**
- System Design Report: `Designs/0_SYSTEM_DESIGN_REPORT.md` (Doc 0, PDR R1)
- Original design documents now in `Designs/obsolete/` (Docs 3, 4, 5, 8, 10, 11, A, B)
- Ben Morris PPS Interface Upgrade Proposal: `pps/pps_Ben.md` (March 5, 2026)
- Earlier drafts in `Archived/` (superseded by current documents)
- This documentation architecture proposal


### 3.3 Status of Docs_JS/ (Jim Sebek's Original Files)

The `Docs_JS/` directory contains four docx files authored by Jim Sebek:

| File | Duplicate Location | Status |
|------|--------------------|--------|
| `LLRFOperation_jims.docx` | Unique — not duplicated elsewhere | **Canonical**: Primary operational reference |
| `LLRFUpgradeTaskListRev3.docx` | `llrf/architecture/llrfUpgradeTasks20221108.docx` is a related but different revision | **Canonical**: Latest task list revision |
| `WaveformBuffersforLLRFUpgrade.docx` | `llrf/architecture/WaveformBuffersforLLRFUpgrade.docx` (identical) | **Duplicate**: Canonical copy is in llrf/architecture/ |
| `llrfInterfaceChassis.docx` | `llrf/architecture/llrfInterfaceChassis.docx` (identical) | **Duplicate**: Canonical copy is in llrf/architecture/ |

**Recommendation**: Retain `Docs_JS/` as a reference collection of Jim Sebek's original documents. The canonical locations for design documents are in `llrf/architecture/`. The operational document (`LLRFOperation_jims.docx`) and the latest task list (`LLRFUpgradeTaskListRev3.docx`) are unique and should be preserved as primary sources.

### 3.4 Status of Archived/ Directory

The `Archived/` directory contains earlier drafts that have been fully superseded:

| File | Superseded By |
|------|---------------|
| `1_Overview of Current and Upgrade System.md` | `Designs/0_SYSTEM_DESIGN_REPORT.md` (Doc 0) |
| `2_LLRF_UPGRADE_SYSTEM_DESIGN.md` | Doc 0 + individual upgrade documents (U1–U10) |
| `9_SOFTWARE_DESIGN.md` | `Designs/obsolete/10_SOFTWARE_DESIGN_DOCUMENT.md` (Doc 10 / U10) |

These are retained for historical reference only. No content from Archived/ needs to be migrated.

### 3.5 Status of Designs/obsolete/ Documents

These eight documents were the original monolithic design documents. They have been moved to `obsolete/` because their content is being reorganized into the tiered architecture. Each document's content disposition is tracked in Appendix B.

| ID | File | Lines | Disposition |
|----|------|-------|-------------|
| Doc 3 | `3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` | 1,277 | → U1 (LLRF Controller) with legacy content to Doc L |
| Doc 4 | `4_HVPS_Engineering_Technical_Note.md` | 1,877 | → U2 (HVPS) with legacy/physics content to Doc L/Doc P |
| Doc 5 | `5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md` | 415 | → U9 (Klystron Heater), already clean upgrade-only |
| Doc 8 | `8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` | 868 | → U5 (PPS Interface), updated with Ben Morris proposal |
| Doc 10 | `10_SOFTWARE_DESIGN_DOCUMENT.md` | 1,561 | → U10 (Control Software), already clean upgrade-only |
| Doc 11 | `11_INTERFACE_CHASSIS_DESIGN.md` | 446 | → U4 (Interface Chassis), already clean upgrade-only |
| Doc A | `A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` | 1,584 | → Doc P (§3–4: physics), Doc L (§5–15: implementation) |
| Doc B | `B_SPEAR3_CURRENT_LLRF_TECHINICAL_DESIGN_REPORT.md` | 1,324 | → Doc P (§4,6–8: physics), Doc L (§5,9–21: implementation) |

---

## 4. Tier 0 — Master Document Index

**Status**: To be created  
**Proposed location**: `Designs/00_MASTER_INDEX.md`  
**Priority**: Medium (can be generated once other documents stabilize)

### 4.1 Purpose

A single navigation page that catalogs every document in the repository, organized by tier and subsystem. This is the entry point for anyone new to the project.

### 4.2 Proposed Format

The Master Index should contain:

1. **Quick Navigation Table**: Tier × Subsystem matrix (see Appendix A) with links
2. **Complete Document Registry**: Every markdown file listed with:
   - File path (relative to repository root)
   - Title
   - Tier assignment
   - Subsystem
   - Status (complete / in-progress / planned)
   - Line count
3. **Source Document Catalog**: Every PDF, docx, xlsx, and other non-markdown source file, organized by subsystem and type
4. **Reading Paths**: Curated sequences for different roles (see §10)

### 4.3 Maintenance Strategy

The Master Index should be regenerated periodically from document metadata. A simple script that walks the repository directory tree, extracts first-line titles from markdown files, and produces the registry table would ensure it stays current.


---

## 5. Tier 1 — RF Physics, Control Theory and Physical Plant (Doc P)

**Status**: To be created (content exists scattered across multiple documents)  
**Proposed location**: `Designs/P_RF_PHYSICS_AND_PLANT.md`  
**Priority**: High — required foundation before detailed upgrade design  

### 5.1 Purpose

Doc P is the single reference for all physics and control theory that is **independent of the hardware implementation**. When the VXI hardware is replaced with the LLRF9, the cavity equations, beam loading theory, feedback loop transfer functions, and plant parameters remain the same. Doc P captures this invariant knowledge.

### 5.2 Proposed Content Outline

| Section | Topic | Primary Sources |
|---------|-------|-----------------|
| §1 | RF cavity equivalent circuit and fundamental equations | Doc A §3 (`Designs/obsolete/A_*`, "RF Cavity Physics and Mathematical Models"), Doc B §4 (`Designs/obsolete/B_*`, "RF Cavity Physics and Beam Loading Theory") |
| §2 | Beam loading theory and Robinson instability | Doc B §4 (beam loading subsections), llrf technical note `01_FEEDBACK_LOOP_ARCHITECTURE.md` |
| §3 | IQ signal processing and vector representation | Doc A §4 ("IQ Signal Processing and Vector Representation") |
| §4 | Multi-loop feedback architecture and transfer functions | Doc B §6–8 ("Multi-Loop Feedback Architecture", "Direct RF Feedback Loop", "Ripple Feedback Loop"), Doc A §9–10 ("Direct Loop", "Comb Loop") |
| §5 | Klystron characteristics and power conversion | Doc B §18 ("HVPS and Power Conversion System"), hvps/architecture/technical-notes/01-pepii-power-supply-architecture.md |
| §6 | SPEAR3 operating parameters and beam parameters | Doc B §3 ("System Operating Parameters"), llrf/calibrations/ data |
| §7 | Plant model: cavity, waveguide, coupler, tuner | Doc B §11 ("Tuner Control Loop"), llrf/documentation/legacyArchitecture/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md |
| §8 | Control theory — stability, margins, performance | Doc A §15 ("Performance Characteristics and Stability Analysis") |

### 5.3 What Doc P Is NOT

- It does NOT describe the VXI hardware implementation (that is Doc L and the code review notes)
- It does NOT describe the LLRF9 implementation (that is U1)
- It does NOT include operational procedures (that is Doc D)
- It does NOT contain HVPS circuit details (that is Doc L and hvps/architecture/technical-notes/)

### 5.4 Relationship to Existing Documents

Doc P consolidates physics content from Doc A and Doc B while those documents' implementation sections go to Doc L. The existing LLRF technical notes (particularly `01_FEEDBACK_LOOP_ARCHITECTURE.md`) and HVPS architecture notes provide supporting detail that Doc P references but does not duplicate.

---

## 6. Tier 2 — Legacy System and Operational Reference

Tier 2 is the largest tier and encompasses four types of documents:

### 6.1 Doc L — Legacy System Architecture

**Status**: To be created (synthesized from existing technical notes and obsolete design docs)  
**Proposed location**: `Designs/L_LEGACY_SYSTEM_ARCHITECTURE.md`  
**Priority**: Medium — enables upgrade design by documenting what is being replaced

#### 6.1.1 Purpose

Doc L is the **consolidated cross-subsystem reference** for the legacy PEP-II/SPEAR3 RF control system as currently implemented. It provides the system-level view that ties together the detailed subsystem technical notes.

#### 6.1.2 Proposed Content Outline

| Section | Topic | Primary Sources |
|---------|-------|-----------------|
| §1 | System architecture overview | Doc B §5 ("System Architecture"), Doc A §2 ("System Architecture Overview") |
| §2 | VXI hardware architecture | llrf/documentation/legacyArchitecture/technical-notes/02_VXI_HARDWARE_MODULE_REFERENCE.md, Doc B §13 ("VXI Hardware Modules") |
| §3 | DSP firmware and real-time processing | Doc B §14, Doc A §6–8 (DAC/HVPS/Tuner loops), code review notes 04 |
| §4 | EPICS/SNL software architecture | Doc A §5 ("Master State Machine"), §14 ("EPICS PV Architecture"), Doc B §15–16, code review notes 05, 07 |
| §5 | HVPS system architecture | hvps/architecture/technical-notes/00-06 (complete series), Doc B §18 |
| §6 | PLC control system | hvps/documentation/plc/technical-notes/01-09 (complete series) |
| §7 | Enerpro SCR controls | hvps/controls/enerpro/technical-notes/00-08 (complete series) |
| §8 | Personnel Protection System | pps/diagrams/00-08 (complete analysis series) |
| §9 | Machine protection and interlocks | Doc B §19, code review notes 06 |
| §10 | Tuner control (cavity mechanical tuning) | Doc A §8, Doc B §11, llrf/tuners/galil/ |
| §11 | Calibration system | Doc A §11, llrf/calibrations/ |
| §12 | Known limitations and failure modes | Doc B §21 |

#### 6.1.3 Key Design Decision

Doc L does **not** duplicate the detailed technical notes. It provides a system-level narrative that *references* the subsystem technical-notes series by file path. For example, §5 (HVPS System Architecture) provides a high-level summary and then says "for detailed schematic analysis, see `hvps/documentation/schematics/technical_notes/`; for PLC control logic, see `hvps/documentation/plc/technical-notes/`."

### 6.2 Code Review Technical Notes (00–08)

**Status**: Complete (Rev 6, existing and authoritative)  
**Location**: `spear-rf-code-legacy/codeReviewTechnicalNotes/`  
**Priority**: N/A — no changes needed

These nine documents constitute the definitive technical analysis of the legacy codebase:

| ID | File | Topic |
|----|------|-------|
| 00 | `00_EXECUTIVE_SUMMARY_AND_UPGRADE_DECISION_MATRIX.md` | Executive summary, file inventory with verdicts (253 files) |
| 01 | `01_COMPLETE_FILE_INVENTORY.md` | Complete file-by-file inventory with upgrade/retire/preserve decisions |
| 02 | `02_ARCHITECTURE_OVERVIEW.md` | PV naming conventions, boot sequence, system architecture |
| 03 | `03_VXI_DRIVER_AND_DEVICE_SUPPORT.md` | VXI driver analysis, device support deep dive |
| 04 | `04_DSP_FIRMWARE_ANALYSIS.md` | TMS320C16xx assembly code analysis |
| 05 | `05_SNL_STATE_MACHINE_PROGRAMS.md` | rf_states.st, rf_tuner_loop.st, rf_hvps_loop.st, rf_dac_loop.st, rf_calib.st, rf_msgs.st |
| 06 | `06_PLC_INTEGRATION_AND_STEPPER_MOTORS.md` | Allen-Bradley PLC integration, stepper motor control |
| 07 | `07_EPICS_DATABASE_AND_PV_ARCHITECTURE.md` | Database records, PV architecture |
| 08 | `08_SIGNAL_PROCESSING_AND_PHYSICS_ALGORITHMS.md` | Signal processing algorithms, physics implementation |

These are preserved exactly as-is. They are referenced from Doc L and Doc P where relevant.

### 6.3 Doc D — Operational Data Catalog

**Status**: To be created  
**Proposed location**: `Designs/D_OPERATIONAL_DATA_CATALOG.md`  
**Priority**: **CRITICAL — highest priority, time-sensitive**

#### 6.3.1 Purpose

Doc D catalogs all operational measurements, calibration data, performance baselines, and empirical knowledge that must be captured **before the legacy hardware is removed**. This is the most time-critical document because the data can only be collected while the legacy system is still operational.

#### 6.3.2 Existing Data Already in Repository

The following operational data is already available and should be referenced from Doc D:

| Data Type | Location | Contents |
|-----------|----------|----------|
| Drive amplifier calibration | `llrf/calibrations/driveAmpCalibration.xlsx` | Drive amp response curves |
| Klystron coupler calibrations | `llrf/calibrations/klystronCouplerDriveAmpCalibrations.xlsx` | Coupler and drive amp cal data |
| Pulsar coupler calibration | `llrf/calibrations/pulsarCouplerCalibration2049.xlsx` | Pulsar coupler cal for station 2049 |
| Reflected power calibrations | `llrf/calibrations/reflectedPowerCalibrations.xlsx` | Reflected power measurement cal |
| Tune mode DAC calibration | `llrf/calibrations/tuneModeDacCalibration.xlsx` | Tuner DAC calibration data |
| Patch panel connections | `llrf/calibrations/b132R11PatchPanel.xlsx` | B132 rack 11 patch panel mapping |
| LLRF9 test results | `llrf/tests/llrf9Tests.pdf`, `llrf/tests/llrf9Tests.tex` | LLRF9 test data with graphics |
| HVPS reliability data | `hvps/maintenance/HVPSReliability.xlsx` | HVPS failure and reliability records |
| HVPS test data (SPEAR1) | `hvps/maintenance/Spear1Tests20220817.xlsx` | SPEAR1 HVPS test measurements |
| HVPS test data (SPEAR2) | `hvps/maintenance/Spear2Tests2021.xlsx` | SPEAR2 HVPS test measurements |
| Phase tank SCR data | `hvps/maintenance/phaseTankScrs.xlsx` | Phase tank thyristor records |
| HVPS simulation results | `hvps/simulation/hvps_sim/`, `hvps/simulation/pyspice_sim/` | Circuit simulation results |

#### 6.3.3 Data Still Needed (Must Capture Before Hardware Swap)

- Current cavity field stability measurements (gap voltage, phase)
- Forward/reflected power operational baselines for each station
- Tuner position vs. frequency response curves (actual, not theoretical)
- HVPS voltage/current regulation performance under beam loading
- Interlock trip thresholds and response times (as-measured)
- PLC register values and timing under normal operation
- Any operator "tribal knowledge" about tuning procedures and set points
- Water cooling system flow rates and temperature data (if available)

#### 6.3.4 Legacy Operational Procedures (Already Transcribed)

Nine PEP-II operational procedures have been transcribed from legacy PDFs and are available in `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/operational-procedures/`:

| Document | Title |
|----------|-------|
| PS-340-330-53 | RF Cavity Low Power Calibration |
| PS-340-330-54 | RF Station Safety Certification Check-Off List |
| PS-340-330-55 | RF Station Safety Survey |
| PS-340-330-56 | RF Station Coupling & Cable Calibration |
| PS-340-330-57 | RF Station Full Power Test & Survey |
| PS-340-330-58 | RF Station Cavity Phasing |
| PS-340-330-59 | RF Station Turn-On Procedure |
| PS-340-330-60 | Bellow Cavity Phasing |
| PS-340-330-61 | RF Non-Ionizing Radiation Safety |

These are PEP-II vintage procedures. Doc D should assess which remain applicable to SPEAR3 operations and which need updates for the upgraded system.

### 6.4 Subsystem Technical Notes (Existing Series)

The detailed technical notes that already exist in each subsystem directory are Tier 2 documents. They remain in their current locations (not moved) and are referenced from Doc L. See §8 for the complete inventory of each series.


---

## 7. Tier 3 — Upgrade Design Documents

### 7.1 Doc 0 — System Design Report (Top-Level PDR)

**Status**: Exists — under PDR review (R1, March 17, 2026)  
**Location**: `Designs/0_SYSTEM_DESIGN_REPORT.md`  
**Source docx**: `Designs/docx/SPEAR3_LLRF_PDR_R1.docx`  
**Priority**: N/A — already in review

Doc 0 is the top-level Preliminary Design Report. It provides the project-level summary, scope, schedule, and references all subsystem upgrade documents (U1–U10). No changes to Doc 0 are proposed by this architecture — it remains the umbrella document.

### 7.2 Upgrade Subsystem Documents (U1–U10)

Each upgrade document specifies the design for one subsystem of the upgraded system. Documents that already exist (from `Designs/obsolete/`) need varying levels of revision to fit the new architecture.

| ID | Title | Source | Status | Work Required |
|----|-------|--------|--------|---------------|
| **U1** | LLRF Controller (LLRF9) | `Designs/obsolete/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` (1,277 lines) | Exists — needs refocusing | Remove legacy system description (§1–2, move to Doc L). Retain §3+ (LLRF9 architecture, I/O mapping, software design). Add references to code review notes 04, 05 for legacy context. |
| **U2** | HVPS Upgrade | `Designs/obsolete/4_HVPS_Engineering_Technical_Note.md` (1,877 lines) | Exists — needs significant refocusing | Extract physics content to Doc P, legacy description to Doc L. Retain upgrade-specific: new PLC program, new controls architecture, Enerpro board modifications. Reference hvps/architecture/technical-notes/ for legacy detail. |
| **U3** | RF Machine Protection System | None — to be written | **Not started** | New document. Define new MPS architecture replacing legacy VXI-based MPS. Reference: `hvps/architecture/designNotes/RFSystemMPSRequirements.docx`, llrf/documentation/mpsWiringDiagrams/ (33 wiring diagrams), Doc B §19 (current MPS architecture). |
| **U4** | Interface Chassis | `Designs/obsolete/11_INTERFACE_CHASSIS_DESIGN.md` (446 lines) | Exists — clean upgrade-only | Minimal changes needed. Already focused on upgrade design. Source docx: `llrf/architecture/llrfInterfaceChassis.docx`. |
| **U5** | PPS Interface | `Designs/obsolete/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` (868 lines) | Exists — needs update | Incorporate Ben Morris's PPS Interface Upgrade Proposal (`pps/pps_Ben.md`, March 5, 2026) which proposes a standard interface solution. Reference Jim Sebek's 2022 PPS compliance email (`pps/MSG from Jim Sebek to Faya about PPS.md`). Cross-reference pps/diagrams/ analysis series (00–08) for current system documentation. |
| **U6** | Tuner Control | None — to be written | **Not started** | New document. Define Galil DMC-4103 based tuner control replacing legacy stepper motor VXI control. Sources: `llrf/tuners/galil/` (commissioning data, firmware, manuals), Doc A §8 (legacy tuner loop), Doc B §11, code review notes 05 (rf_tuner_loop.st), `spear-rf-code-legacy/stepper/` (legacy stepper code). |
| **U7** | Waveform Buffer | None — to be written | **Not started** | New document. Source: `llrf/architecture/WaveformBuffersforLLRFUpgrade.docx` (Jim Sebek's design). Convert docx to markdown and expand into full upgrade specification. |
| **U8** | Arc Detection | None — to be written | **Not started** | New document. Source: `llrf/architecture/arcDetectorHardwareOptions.docx` (hardware comparison), `llrf/arcDetector/` (MicroStep-MIS product sheets, tups072.pdf conference paper on waveguide arc detection). |
| **U9** | Klystron Heater | `Designs/obsolete/5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md` (415 lines) | Exists — clean upgrade-only | Minimal changes needed. Already well-focused on upgrade. Cross-reference `llrf/documentation/filamentHeater/FILAMENT_HEATER_TECHNICAL_NOTES.md` for legacy system detail. |
| **U10** | Control Software | `Designs/obsolete/10_SOFTWARE_DESIGN_DOCUMENT.md` (1,561 lines) | Exists — clean upgrade-only | Minimal changes needed. Already focused on new Python/EPICS coordinator. Cross-reference code review notes (00–08) for what is being replaced. |

### 7.3 Summary of Upgrade Document Status

```
 Exists, minimal changes:  U4, U5, U9, U10  (4 documents)
 Exists, needs refocusing:  U1, U2           (2 documents)
 Not started:               U3, U6, U7, U8   (4 documents)
```


---

## 8. Subsystem Documentation Inventories

This section provides the complete file-level inventory for each subsystem's documentation. These are the existing documents that form the backbone of Tier 2.

### 8.1 HVPS Documentation

#### 8.1.1 Architecture Technical Notes (`hvps/architecture/technical-notes/`)

| File | Title | Content |
|------|-------|---------|
| `00-spear3-hvps-legacy-system-design.md` | SPEAR3 HVPS Legacy System Design Report | Comprehensive overview of the legacy HVPS system |
| `01-pepii-power-supply-architecture.md` | PEP-II Power Supply Architecture | Architecture analysis from SLAC-PUB-7591 |
| `02-power-supply-schematics-analysis.md` | Power Supply Schematics Analysis | Analysis from PEP-II supply presentation |
| `03-detailed-schematic-analysis.md` | Detailed Schematic Analysis | From PS-341-360-01-R2 specification |
| `04-regulator-board-design.md` | Regulator Board Design | Enerpro V/A Regulator board analysis |
| `05-system-integration-notes.md` | System Integration and Wiring | Hoffman Box integration and wiring |
| `06-design-notes-synthesis.md` | Design Notes Synthesis | Comprehensive synthesis of all design notes |

**Source transcriptions** (`hvps/architecture/originalDocuments/transcriptions/`): pepII_supply_transcription.md, ps3413600102_transcription.md, slac-pub-7591_transcription.md

**Original source documents** (`hvps/architecture/originalDocuments/`): pepII supply.pptx, ps3413600102.pdf, slac-pub-7591.pdf

**Design notes** (`hvps/architecture/designNotes/`): 10 docx files covering Enerpro V/A regulator notes, Hoffman Box PPS wiring, power distribution, fiber optic connections, MPS requirements, controller interfaces, testing notes, EDMS PV labels, and the original upgrade task list Rev 0.

#### 8.1.2 Enerpro SCR Controls Technical Notes (`hvps/controls/enerpro/technical-notes/`)

| File | Title |
|------|-------|
| `00-introduction.md` | Introduction to Enerpro SCR Firing Board |
| `01-hardware-specifications.md` | Hardware Specifications |
| `02-input-control-signals.md` | Input Control Signals |
| `03-circuit-analysis.md` | Circuit Analysis |
| `04-output-characteristics.md` | Output Characteristics |
| `05-operating-procedures.md` | Operating Procedures |
| `06-control-theory.md` | Control Theory |
| `07-auto-balance-system.md` | Auto-Balance System |
| `08-troubleshooting.md` | Troubleshooting |

#### 8.1.3 PLC Technical Notes (`hvps/documentation/plc/technical-notes/`)

| File | Title |
|------|-------|
| `00-plc-overview.md` | PLC System Overview |
| `01-system-overview.md` | SLC-500 System Overview |
| `02-hardware-io-configuration.md` | Hardware I/O Configuration |
| `03-symbol-database.md` | Symbol Database Reference |
| `04-ladder-logic-overview.md` | Ladder Logic Overview |
| `05-control-algorithms.md` | Control Algorithms |
| `06-safety-interlocks.md` | Safety Interlocks |
| `07-vxi-epics-communications.md` | VXI/EPICS Communications |
| `08-calibration-verification.md` | Calibration and Verification |
| `09-binary-register-reference.md` | Binary Register Reference |

#### 8.1.4 Schematics Analysis (`hvps/documentation/schematics/technical_notes/`)

| File | Title |
|------|-------|
| `00_HVPS_SYSTEM_OVERVIEW.md` | HVPS System Overview |
| `README.md` | Directory guide |
| `SD-237-230-14_Regulator_Board_Analysis.md` | Regulator Board schematic analysis |
| `SD-7307900101_HVPS_System_Schematic_Analysis.md` | System schematic analysis |
| `sd2372301299.md` through `sd7307940400.md` | 10 individual schematic analyses (sd-series drawings) |

**Source PDFs** (same directory): 11 schematic PDFs (sd2372301200.pdf through sd7307940400.pdf)

#### 8.1.5 Switchgear Documentation (`hvps/documentation/switchgear/`)

| File | Title |
|------|-------|
| `00_SYSTEM_OVERVIEW.md` | 12.47 KV Switchgear System Overview |
| `technical_notes/TN_gp3085000103_*.md` | Vacuum Contactor Controller schematic analysis |
| `technical_notes/TN_gp4397040201_*.md` | Vacuum Contactor Electrical Schematic |
| `technical_notes/TN_DOC041421_RossEngr713203_*.md` | Ross Engineering Primary Energy Storage schematic |
| `technical_notes/TN_id3088010601_*.md` | Connection Wiring Diagram analysis |

#### 8.1.6 Wiring Diagram Analysis (`hvps/documentation/wiringDiagrams/`)

| File | Title |
|------|-------|
| `WD-7307900103_Phase_Tank_Wiring_Analysis.md` | Phase Tank Trigger Wiring Diagram analysis |

#### 8.1.7 Other HVPS Documentation

- **Procedures** (`hvps/documentation/procedures/`): ~40 files including EWP safety documents, signed safety reviews (SR-444-636 series), lockout permits, hazard analyses, and maintenance outlines
- **Maintenance** (`hvps/maintenance/`): HVPS reliability data, SPEAR1/SPEAR2 test data, phase tank SCR records, stack installation checklists, phase tank maintenance procedures
- **Simulation** (`hvps/simulation/`): Two simulation packages — hvps_sim (Python-based), pyspice_sim (PySpice circuit simulation)
- **Mechanical** (`hvps/documentation/mechanical/`): Transformer and component assembly drawings (PNG)
- **Stack Assemblies** (`hvps/documentation/stackAssemblies/`): Stack driver schematics and parts lists (PDF)
- **Hoisting/Rigging** (`hvps/documentation/hoistingRigging/`): Main tank lift plan

### 8.2 LLRF Documentation

#### 8.2.1 Legacy Architecture Technical Notes (`llrf/documentation/legacyArchitecture/technical-notes/`)

| File | Title | Content |
|------|-------|---------|
| `00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` | PEP-II/SPEAR3 LLRF System Reference | Comprehensive system-level reference document |
| `01_FEEDBACK_LOOP_ARCHITECTURE.md` | Feedback Loop Architecture | Multi-loop feedback system design and theory |
| `02_VXI_HARDWARE_MODULE_REFERENCE.md` | VXI Hardware Module Reference | VXI module catalog and specifications |
| `03_LEGACY_PDF_CATALOG.md` | Legacy PDF Catalog | Index of all legacy PDF documents |
| `04_LITERATURE_SYNTHESIS.md` | Literature Synthesis | Synthesis of all PEP-II/SPEAR3 RF literature |
| `05_CROSS_REFERENCE_INDEX.md` | Cross-Reference Index | Cross-reference between documents, topics, and hardware |

#### 8.2.2 Legacy PDF Transcriptions (`llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/`)

**Block Diagrams** (3 documents):
- PS-340-330-50 series block diagram transcriptions

**Design Specifications** (3 documents):
- `PS-340-330-51_RF_System_Description.md` — RF System Description
- `PS-340-330-52_LLRF_Feedback_Loop_Description.md` — LLRF Feedback Loop Description
- Third design specification transcription

**Operational Procedures** (9 documents):
- PS-340-330-53 through PS-340-330-61 (see §6.3.4 for full listing)

**Conference Papers** (2 documents):
- Transcriptions of published papers on PEP-II RF system

#### 8.2.3 Filament Heater Documentation (`llrf/documentation/filamentHeater/`)

| File | Content |
|------|---------|
| `FILAMENT_HEATER_TECHNICAL_NOTES.md` | Comprehensive analysis of klystron filament heater system (SD-349-311-20) |

#### 8.2.4 Other LLRF Documentation

- **Architecture design documents** (`llrf/architecture/`): 6 docx files — WaveformBuffersforLLRFUpgrade, analogDesignComponents, arcDetectorHardwareOptions, llrfInterfaceChassis, llrfUpgradeTasks20221108, rfPowerDetector
- **Calibrations** (`llrf/calibrations/`): 6 xlsx files covering drive amp, couplers, reflected power, tuner mode, patch panel
- **Test data** (`llrf/tests/`): LLRF9 test results (PDF, LaTeX source, graphics)
- **Arc detector** (`llrf/arcDetector/`): Product sheets, conference paper (tups072), mechanical drawings
- **Tuners/Galil** (`llrf/tuners/galil/`): DMC-4103 commissioning docx, firmware hex files, manuals, first motion logs, stepper motor data
- **LLRF9** (`llrf/llrf9/`): LLRF9 manual PDF, iGp subdirectory
- **Drive amplifier** (`llrf/driveAmp/`): KAW2051M12 datasheet
- **Local panel drawings** (`llrf/documentation/localPanel/`): 13 PDF drawings (ad, dl, gp, ml, pc, pf, sd, si series)
- **Legacy interface modules** (`llrf/documentation/legacyInterfaceModules/`): 3 PDF schematics (SD-340-308-01, SD-340-308-02, sd3403090102)
- **MPS wiring diagrams** (`llrf/documentation/mpsWiringDiagrams/`): 33 PDF wiring diagrams
- **Coax cables** (`llrf/documentation/coaxCables/`): SD and WD series cable drawings

### 8.3 PPS Documentation

#### 8.3.1 PPS Analysis Series (`pps/diagrams/`)

| File | Title |
|------|-------|
| `README.md` | PPS documentation directory overview |
| `00_SYSTEM_OVERVIEW.md` | PPS System Overview — current vs. upgrade architecture comparison |
| `01_VacuumContactorController.md` | Vacuum Contactor Controller schematic analysis |
| `02_RossEngineeringDriver.md` | Ross Engineering high-voltage shorting switch driver |
| `03_GroundingTank.md` | Grounding (termination) tank schematic |
| `04_HoffmanBoxWiring.md` | Hoffman Box internal wiring to PPS |
| `05_Interconnections.md` | Interconnection wiring between subsystems |
| `06_PLCCodeAndLogic.md` | PLC code governing PPS relay sequences |
| `07_CorrectedHandDrawing.md` | Corrected hand-drawn schematic with corrections applied |
| `08_additional_analysis.md` | Additional analysis and observations |

#### 8.3.2 PPS Upgrade Proposal

| File | Content |
|------|---------|
| `pps/pps_Ben.md` | **Ben Morris PPS Interface Upgrade Proposal** (March 5, 2026) — proposes standard PPS interface solution with detailed technical specifications. This is the primary design input for U5. |
| `pps/MSG from Jim Sebek to Faya about PPS.md` | 2022 email thread (Jim Sebek → Matt Cyterski/Tracy Yott) documenting PPS compliance concerns. Identifies two key issues: (1) Ross relay commanded through Allen-Bradley PLC instead of directly, (2) PPS wiring passes through RF controller Hoffman box. Historical context for the upgrade. |

### 8.4 Legacy Code Documentation

#### 8.4.1 Code Review Technical Notes (`spear-rf-code-legacy/codeReviewTechnicalNotes/`)

See §6.2 for the complete listing. This 9-document series (Rev 6) provides the definitive analysis of the legacy EPICS/VXI/SNL/DSP codebase.

#### 8.4.2 Legacy Source Code

The `spear-rf-code-legacy/` directory contains 2,293 source files (RCS versioned with `,v` suffix) organized as:

| Directory | Content |
|-----------|---------|
| `rfApp/` | Main RF application — EPICS databases (Db/, DbIoc/), SNL state machines, C source, KSC VXI driver (ksc_v152/) |
| `dsp1610/` | TMS320C16xx DSP firmware (assembly source) |
| `allenBradley/` | Allen-Bradley PLC interface drivers and EPICS device support |
| `epvxi/` | EPICS VXI support — drivers, IOC boot, test code |
| `stepper/` | Stepper motor control code |
| `iocBoot/` | IOC boot configurations (b132-iocrf) |
| `configure/` | Build system configuration |


---

## 9. Documentation Gap Analysis

This section identifies documentation that is needed but does not yet exist, referenced from `Designs/todo list.md` and from systematic review of the repository.

### 9.1 Critical Gaps (Must Address Before or During Upgrade)

| Gap | Description | Priority | Rationale |
|-----|-------------|----------|-----------|
| **Doc D data collection** | Operational measurements, baselines, tribal knowledge | **CRITICAL** | Data can only be captured while legacy system is operational. Once hardware is removed, this opportunity is permanently lost. |
| **U3 — RF MPS Design** | New machine protection system architecture | **HIGH** | Safety-critical system. Cannot proceed with upgrade without MPS design. Source material exists in `hvps/architecture/designNotes/RFSystemMPSRequirements.docx` and 33 MPS wiring diagrams. |
| **U6 — Tuner Control Design** | Galil DMC-4103 tuner control upgrade | **HIGH** | Commissioning data exists (`llrf/tuners/galil/`), needs formal specification document. |
| **U7 — Waveform Buffer Design** | Waveform buffer upgrade specification | **MEDIUM** | Jim Sebek's docx design exists (`llrf/architecture/WaveformBuffersforLLRFUpgrade.docx`), needs conversion and expansion to formal spec. |
| **U8 — Arc Detection Design** | Arc detection hardware selection and integration | **MEDIUM** | Hardware comparison exists (`llrf/architecture/arcDetectorHardwareOptions.docx`), product sheets available. Needs formal design document. |

### 9.2 Knowledge Gaps (From `Designs/todo list.md`)

The following systems lack adequate documentation and were explicitly identified as gaps:

| System | Current State | What's Needed |
|--------|---------------|---------------|
| **RF waveguide, klystron, cavity layout** | No dedicated documentation. Scattered references in Doc B §18, calibration data in `llrf/calibrations/`. | Comprehensive physical plant documentation: waveguide routing, klystron specifications, cavity parameters, coupler details, RF power budget. This would be part of Doc P §7. |
| **Water cooling system** | No documentation exists anywhere in the repository. | Water system schematics, flow rates, temperature requirements, interlock connections. Could be a standalone technical note or a section of Doc L/Doc P. |
| **Tuner mechanical detail and operation data** | Galil commissioning data exists in `llrf/tuners/galil/`. Legacy stepper motor data in `spear-rf-code-legacy/stepper/`. Stepper motor catalog in `llrf/tuners/galil/Old Stepper Catalog_Superior Electric_0.pdf`. | Formal documentation of mechanical tuner system: motor specifications, drive mechanism, position feedback, frequency-vs-position curves, operational limits. Part of U6 and Doc L. |
| **Control system integration** | Ongoing (per todo list item 0). | Cross-subsystem interface documentation showing how LLRF, HVPS, PPS, MPS, and tuner systems interconnect. Partially covered by `hvps/architecture/designNotes/interfacesBetweenRFSystemControllers.docx`. |

### 9.3 Reference Documentation Gaps

| Gap | Description | Notes |
|-----|-------------|-------|
| **HVPS wiring diagrams** | Only phase tank wiring has been analyzed in markdown. Other wiring diagrams exist as PDFs but lack analysis documents. | Lower priority — the schematic analyses (§8.1.4) cover the electrical design. Wiring analysis is primarily needed for maintenance. |
| **LLRF local panel documentation** | 13 PDF drawings exist but no markdown analysis or index. | Could be cataloged in the Master Index (Tier 0). Analysis may be needed for U4 (Interface Chassis). |
| **LLRF coax cable documentation** | Only source PDF, no analysis. | Cable routing documentation would be useful but is lower priority. |
| **Operational procedures update** | 9 PEP-II procedures have been transcribed but need review for SPEAR3 applicability. | Should be addressed as part of Doc D. Some procedures may need updating for upgraded system (post-upgrade task). |

---

## 10. Reading Paths by Role

Different users of this documentation have different needs. The following reading paths guide each role through the most relevant documents.

### 10.1 New Engineer (Understanding the System)

1. **Start**: Master Index (Tier 0) — get oriented
2. **Physics**: Doc P §1–4 — cavity physics, beam loading, IQ processing, feedback theory
3. **System overview**: Doc L §1–2 — legacy architecture overview and VXI hardware
4. **Current system**: Doc B (in `Designs/obsolete/B_*`) §3–5 — operating parameters, historical context, system architecture
5. **Upgrade overview**: Doc 0 (`Designs/0_SYSTEM_DESIGN_REPORT.md`) — what we're building
6. **Deep dive**: Choose subsystem technical-notes series based on area of interest

### 10.2 Upgrade Implementer (Building the New System)

1. **Start**: Doc 0 — project scope and requirements
2. **Physics**: Doc P — understand what the control system must achieve
3. **Legacy**: Code review notes 00, 02, 05, 07 — understand what is being replaced
4. **Subsystem spec**: Relevant U-document for the subsystem being implemented
5. **Legacy detail**: Relevant subsystem technical-notes series for implementation details
6. **Operational data**: Doc D — calibration data and performance baselines to match

### 10.3 Design Reviewer (PDR/CDR Review)

1. **Start**: Doc 0 — overall design report
2. **Architecture**: Doc P — verify physics basis is correct
3. **Subsystem**: Relevant U-document(s) under review
4. **Legacy reference**: Doc L — verify upgrade addresses legacy limitations (§12)
5. **Traceability**: This document (Appendix B) — verify content migration is complete

### 10.4 Operations / Maintenance Engineer

1. **Start**: Doc D — operational data, calibration procedures
2. **Procedures**: `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/operational-procedures/` — legacy procedures still in use
3. **Safety**: `hvps/documentation/procedures/` — safety reviews, lockout permits, EWPs
4. **PPS**: `pps/diagrams/00_SYSTEM_OVERVIEW.md` — protection system overview
5. **Troubleshooting**: `hvps/controls/enerpro/technical-notes/08-troubleshooting.md`, relevant subsystem notes

### 10.5 Future Maintainer (Years After Upgrade)

1. **Start**: Master Index (Tier 0)
2. **Physics**: Doc P — understand the physical plant
3. **System**: Doc 0 + relevant U-documents — understand the upgraded system
4. **Software**: U10 (`Designs/obsolete/10_SOFTWARE_DESIGN_DOCUMENT.md`) — control software architecture
5. **Legacy reference**: Doc L and code review notes — understand what came before and why decisions were made
6. **Data**: Doc D — calibration baselines and operational history


---

## 11. Document Conventions and Standards

### 11.1 Technical Notes Convention

The repository has organically converged on a technical-notes directory pattern. This section formalizes it as the standard for all future documentation.

**Directory structure**:
```
{subsystem}/{topic}/technical-notes/NN-title.md
```

**Naming rules**:
- `NN` is a two-digit zero-padded number (00, 01, 02, ...)
- `00` is always the overview/introduction document for that series
- Title uses lowercase with hyphens (kebab-case) or UPPER_SNAKE_CASE (both conventions exist; new documents should use kebab-case)
- Each markdown file is a self-contained technical note that can be read independently

**Document header** (recommended for all new technical notes):
```markdown
# Title

**Source Document**: [reference to original PDF/docx if applicable]
**Document Type**: Technical Note — [Schematic Analysis / System Reference / Design Specification]
**Purpose**: [one-line description]
**Date**: [creation/last-update date]
```

### 11.2 File Organization Rules

1. **Markdown documents** stay close to their source material. If a technical note analyzes a PDF schematic, both the PDF and the markdown should be in the same directory (or parent/child directories).

2. **PDFs, schematics, and source material** are not moved or renamed. They retain their original engineering drawing numbers.

3. **Design documents** (Tier 3) live in `Designs/` with the naming convention `{ID}_{TITLE}.md`.

4. **Transcriptions** of legacy PDFs are placed in dedicated `transcriptions/` or `legacy-pdf-transcriptions/` subdirectories near their source material.

### 11.3 Cross-Reference Convention

When referencing another document in the repository, use the **relative file path from the repository root**:

```markdown
See [HVPS System Overview](hvps/documentation/schematics/technical_notes/00_HVPS_SYSTEM_OVERVIEW.md)
```

When referencing a section within another document, use the standard markdown format:

```markdown
See Doc A §3 (`Designs/obsolete/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md`, 
section "RF Cavity Physics and Mathematical Models")
```

### 11.4 Document Status Labels

| Label | Meaning |
|-------|---------|
| **Complete** | Content is stable, reviewed, and authoritative |
| **In Progress** | Content exists but is being actively revised |
| **Planned** | Document is defined in the architecture but not yet started |
| **Obsolete** | Superseded by other documents; retained for reference only |

---

## 12. Implementation Priorities and Action Items

### 12.1 Priority 1 — CRITICAL (Before Hardware Swap)

| Action | Responsible | Dependencies | Notes |
|--------|-------------|--------------|-------|
| Begin Doc D data collection | RF operations team | Access to running legacy system | Capture calibration data, performance baselines, operator knowledge. Time-critical. |
| Verify existing calibration data | Engineering | `llrf/calibrations/` | Confirm the 6 calibration spreadsheets are current and complete. |

### 12.2 Priority 2 — HIGH (Enable Upgrade Design)

| Action | Dependencies | Notes |
|--------|--------------|-------|
| Create Doc P (RF Physics) | Doc A, Doc B, LLRF technical notes | Consolidate physics from Doc A §3–4 and Doc B §4,6–8. Reference existing `01_FEEDBACK_LOOP_ARCHITECTURE.md`. |
| Create U3 (RF MPS) | `RFSystemMPSRequirements.docx`, MPS wiring diagrams | Safety-critical. Must be designed before upgrade implementation. |
| Create U6 (Tuner Control) | `llrf/tuners/galil/`, Doc A §8, code review notes 05 | Galil DMC-4103 commissioning data exists; needs formal spec. |
| Refocus U1 (LLRF Controller) | Doc 3, Doc L (when available) | Extract legacy content from Doc 3 → Doc L, keep upgrade spec in U1. |
| Update U5 (PPS Interface) | `pps/pps_Ben.md`, pps/diagrams/ series | Incorporate Ben Morris proposal into formal upgrade document. |

### 12.3 Priority 3 — MEDIUM (Complete Architecture)

| Action | Dependencies | Notes |
|--------|--------------|-------|
| Create U7 (Waveform Buffer) | `WaveformBuffersforLLRFUpgrade.docx` | Convert and expand Jim Sebek's design document. |
| Create U8 (Arc Detection) | `arcDetectorHardwareOptions.docx`, product sheets | Hardware selection and integration specification. |
| Create Doc L (Legacy Architecture) | All subsystem technical notes, Doc A, Doc B, code review notes | Consolidation document — can be built incrementally as subsystem notes are finalized. |
| Refocus U2 (HVPS) | Doc 4, hvps/architecture/technical-notes/ | Extract physics → Doc P, legacy detail → Doc L. |

### 12.4 Priority 4 — LOWER (Documentation Quality)

| Action | Dependencies | Notes |
|--------|--------------|-------|
| Create Master Index (Tier 0) | All other documents stabilized | Generate from repository scan. Can be automated. |
| Document water cooling system | Facility survey, operator knowledge | No existing documentation. Start from scratch. |
| Document RF waveguide/cavity/klystron plant | Facility survey, Doc B §18 | Physical plant documentation for Doc P §7. |
| Document tuner mechanical system | `llrf/tuners/galil/`, stepper motor data | Feeds into U6. |
| Review/update operational procedures | Doc D, legacy procedure transcriptions | Post-upgrade: adapt PEP-II procedures for upgraded system. |
| Resolve Docs_JS/ canonical status | — | Determine if Docs_JS/ should be consolidated or kept as-is. |


---

## Appendix A — Subsystem × Tier Cross-Reference Matrix

This matrix shows which documents cover each subsystem at each tier. **Bold** indicates the document exists; *italic* indicates it is planned.

| Subsystem | Tier 0 (Index) | Tier 1 (Physics) | Tier 2 (Legacy) | Tier 3 (Upgrade) |
|-----------|---------------|-------------------|------------------|-------------------|
| **RF Cavity / Physics** | *Master Index* | *Doc P §1–4* | **Doc A §3–4**, **Doc B §4,6–8**, **Code Review 08** | — |
| **LLRF Controller** | *Master Index* | *Doc P §4,7* | **LLRF TN 00–05**, **Transcriptions (17)**, **Code Review 03–05**, *Doc L §2–4* | **Doc 3** → *U1* |
| **HVPS** | *Master Index* | *Doc P §5* | **HVPS Arch TN 00–06**, **Enerpro TN 00–08**, **PLC TN 01–09**, **Schematics TN (14)**, **Switchgear (5)**, *Doc L §5–7* | **Doc 4** → *U2* |
| **PPS** | *Master Index* | — | **PPS diagrams 00–08**, **Jim Sebek email**, *Doc L §8* | **Doc 8** → *U5*, **pps_Ben.md** |
| **MPS** | *Master Index* | — | **MPS wiring (33 PDFs)**, **Doc B §19**, **Code Review 06**, *Doc L §9* | *U3* |
| **Interface Chassis** | *Master Index* | — | **Legacy Interface Modules (3 PDFs)**, **Local Panel (13 PDFs)** | **Doc 11** → U4 |
| **Tuner** | *Master Index* | *Doc P §7* | **Galil commissioning data**, **Code Review 05**, **Stepper code**, *Doc L §10* | *U6* |
| **Waveform Buffer** | *Master Index* | — | — | *U7* (from docx) |
| **Arc Detection** | *Master Index* | — | **Product sheets**, **tups072** | *U8* (from docx) |
| **Klystron Heater** | *Master Index* | — | **Filament Heater TN** | **Doc 5** → U9 |
| **Control Software** | *Master Index* | — | **Code Review 00–08**, *Doc L §4* | **Doc 10** → U10 |
| **Calibration / Data** | *Master Index* | — | **Calibrations (6 xlsx)**, **Test data**, **Reliability data**, *Doc D* | — |
| **Operational** | *Master Index* | — | **Op Procedures (9 transcriptions)**, **Safety procedures (~40)**, *Doc D* | — |

---

## Appendix B — Traceability: Original Documents to Proposed Architecture

This appendix maps each section of the original design documents (now in `Designs/obsolete/`) to their proposed destination in the new architecture. Section titles are taken directly from the actual document headings.

### B.1 Doc A — Legacy LLRF Control System Technical Design

**Source**: `Designs/obsolete/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` (1,584 lines)

| Section | Title | Destination |
|---------|-------|-------------|
| §1 | Executive Summary | Doc L §1 (summary context) |
| §2 | System Architecture Overview | Doc L §1 |
| §3 | RF Cavity Physics and Mathematical Models | **Doc P §1** |
| §4 | IQ Signal Processing and Vector Representation | **Doc P §3** |
| §5 | Master State Machine — rf_states | Doc L §4, cross-ref Code Review 05 |
| §6 | DAC Loop — Drive Power and Gap Voltage Control | Doc L §3 (implementation), **Doc P §4** (theory) |
| §7 | HVPS Loop — Klystron High Voltage Control | Doc L §5 (implementation), **Doc P §4** (theory) |
| §8 | Tuner Loop — Cavity Mechanical Tuning | Doc L §10, **Doc P §7** |
| §9 | Direct Loop — Analog Cavity Field Feedback | **Doc P §4** |
| §10 | Comb Loop — Narrowband Revolution Harmonic Feedback | **Doc P §4** |
| §11 | Calibration System — Octal DAC Nulling | Doc L §11 |
| §12 | Message Logging and TAXI Error Recovery | Doc L §4 |
| §13 | Fault Management and Automatic Recovery | Doc L §9 |
| §14 | EPICS Process Variable Architecture | Doc L §4, cross-ref Code Review 07 |
| §15 | Performance Characteristics and Stability Analysis | **Doc P §8** |
| App A | State Transition Tables | Doc L §4 appendix |
| App B | Complete PV Reference | Doc L appendix, cross-ref Code Review 07 |
| App C | Source File Index | Already in Code Review 01 |
| App D | Document Change Log | Retained in Doc A (archive) |

### B.2 Doc B — SPEAR3 Current LLRF Technical Design Report

**Source**: `Designs/obsolete/B_SPEAR3_CURRENT_LLRF_TECHINICAL_DESIGN_REPORT.md` (1,324 lines)

| Section | Title | Destination |
|---------|-------|-------------|
| §1 | Executive Summary | Doc L §1 (context) |
| §2 | Historical Context and System Heritage | Doc L §1 |
| §3 | System Operating Parameters | **Doc P §6** |
| §4 | RF Cavity Physics and Beam Loading Theory | **Doc P §1–2** |
| §5 | System Architecture | Doc L §1 |
| §6 | Multi-Loop Feedback Architecture | **Doc P §4** |
| §7 | Direct (Wideband) RF Feedback Loop | **Doc P §4** |
| §8 | Ripple Feedback Loop | **Doc P §4** |
| §9 | HVPS Voltage Regulation Loop | Doc L §5 |
| §10 | DAC Control Loop | Doc L §3 |
| §11 | Tuner Control Loop | Doc L §10, **Doc P §7** |
| §12 | PEP-II Heritage Loops (Not Active in SPEAR3) | Doc L appendix (historical reference) |
| §13 | VXI Hardware Modules | Doc L §2, cross-ref LLRF TN 02 |
| §14 | DSP Firmware and Real-Time Signal Processing | Doc L §3, cross-ref Code Review 04 |
| §15 | EPICS Control Software Architecture | Doc L §4 |
| §16 | SNL State Machine Programs | Doc L §4, cross-ref Code Review 05 |
| §17 | Signal Processing and Physics Algorithms | Doc L §3, cross-ref Code Review 08 |
| §18 | HVPS and Power Conversion System | Doc L §5, **Doc P §5** |
| §19 | Machine Protection and Interlock Architecture | Doc L §9 |
| §20 | Operational Procedures and Modes | Doc D |
| §21 | Known Limitations and Failure Modes | Doc L §12 |
| §22 | Upgrade Architecture Summary | Doc 0 (already covered) |
| §23 | References | Distributed to referencing documents |
| App A | Complete PV Reference Table | Doc L appendix |
| App B | Source Code File Summary | Already in Code Review 01 |
| App C | Glossary | Master Index or Doc L appendix |

### B.3 Docs 3, 4, 5, 8, 10, 11 — Upgrade Design Documents

These map directly to upgrade documents U1–U10 as specified in §7.2. Their legacy/physics content (if any) migrates to Doc L/Doc P; their upgrade-specific content becomes the basis of the corresponding U-document.

| Original | Lines | Upgrade Doc | Content to Extract |
|----------|-------|-------------|--------------------|
| Doc 3 | 1,277 | U1 | §1–2 legacy description → Doc L |
| Doc 4 | 1,877 | U2 | Physics → Doc P, legacy circuits → Doc L |
| Doc 5 | 415 | U9 | Clean — no extraction needed |
| Doc 8 | 868 | U5 | Update with pps_Ben.md proposal |
| Doc 10 | 1,561 | U10 | Clean — no extraction needed |
| Doc 11 | 446 | U4 | Clean — no extraction needed |


---

## Appendix C — Source Document Lineages

This appendix traces the three documentation lineages through the repository, showing how original source materials flow through transcription and analysis to their final home in the architecture.

### C.1 HVPS Lineage

```
Original Sources                    Transcriptions/Analysis               Architecture Destination
─────────────────                   ───────────────────────                ────────────────────────
pepII supply.pptx          ──→  pepII_supply_transcription.md    ──→  HVPS Arch TN 01,02  ──→  Doc L §5
ps3413600102.pdf           ──→  ps3413600102_transcription.md    ──→  HVPS Arch TN 03      ──→  Doc L §5
slac-pub-7591.pdf          ──→  slac-pub-7591_transcription.md   ──→  HVPS Arch TN 01      ──→  Doc P §5
10 design notes (docx)     ──→  HVPS Arch TN 05,06              ──→  Doc L §5–9
11 schematic PDFs          ──→  14 Schematics TN                 ──→  Doc L §5
Enerpro board (physical)   ──→  Enerpro TN 00–08                 ──→  Doc L §7
PLC program (SLC-500)      ──→  PLC TN 01–09                     ──→  Doc L §6
Switchgear drawings        ──→  Switchgear TN (5)                ──→  Doc L §5
Reliability/test data      ──→  maintenance/ xlsx                 ──→  Doc D
```

### C.2 LLRF Lineage

```
Original Sources                    Transcriptions/Analysis               Architecture Destination
─────────────────                   ───────────────────────                ────────────────────────
~30 PEP-II legacy PDFs     ──→  17 legacy-pdf-transcriptions     ──→  LLRF TN 00–05        ──→  Doc L §2–4, Doc P §1–4
PS-340-330 series PDFs     ──→  Block diagrams, specs, procedures ──→  LLRF TN 00–05        ──→  Doc L, Doc D
Jim Sebek docx files       ──→  llrf/architecture/ docx           ──→  U4, U7               ──→  Tier 3
VXI hardware (physical)    ──→  LLRF TN 02 (VXI Module Ref)      ──→  Doc L §2
Calibration measurements   ──→  6 calibrations xlsx               ──→  Doc D
LLRF9 manual              ──→  (already digital)                  ──→  U1
Galil DMC-4103 docs       ──→  commissioning docx                 ──→  U6
Filament heater schematic  ──→  FILAMENT_HEATER_TECHNICAL_NOTES  ──→  U9
Arc detector materials     ──→  product sheets, tups072            ──→  U8
```

### C.3 PPS Lineage

```
Original Sources                    Analysis                               Architecture Destination
─────────────────                   ────────                               ────────────────────────
Switchgear schematics      ──→  PPS diagrams 00–08               ──→  Doc L §8
Jim Sebek email (2022)     ──→  MSG from Jim Sebek.md            ──→  U5 (context)
Ben Morris proposal (2026) ──→  pps_Ben.md                       ──→  U5 (primary design input)
```

### C.4 Legacy Code Lineage

```
Original Sources                    Analysis                               Architecture Destination
─────────────────                   ────────                               ────────────────────────
2,293 source files         ──→  Code Review TN 00–08 (Rev 6)    ──→  Doc L §3–4, Doc P §8
  rfApp/ (EPICS/SNL)       ──→  TN 02, 03, 05, 07               ──→  Doc L §4
  dsp1610/ (DSP firmware)  ──→  TN 04                            ──→  Doc L §3
  allenBradley/ (PLC)      ──→  TN 06                            ──→  Doc L §6
  stepper/ (tuner)         ──→  TN 05 (rf_tuner_loop.st)         ──→  Doc L §10, U6
```

---

*End of Document*

**Document Control**:
- This document should be reviewed and updated whenever new documentation is created or existing documents are substantially revised.
- The definitive version is `Designs/DOCUMENTATION_ARCHITECTURE_PROPOSAL.md` in the `spearlegacyLLRF` repository.
