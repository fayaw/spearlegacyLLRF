# SPEAR3 RF System — Documentation Architecture

**Document ID**: DOCUMENTATION_ARCHITECTURE  
**Version**: 6.0  
**Date**: March 24, 2026  
**Status**: PROPOSAL — For Review  
**Supersedes**: v5.1 (March 24, 2026)  
**Author**: Faya Wang, with AI-assisted analysis  

---

## Revision History

| Version | Date | Description |
|---------|------|-------------|
| 6.0 | 2026-03-24 | Major update following deep codebase review: Doc L v1.0 drafted (1,323 lines, 21 sections, 50+ photo placeholders); improved Doc L section outline to match actual 6-part structure with precise original source citations; updated U-document descriptions with corrected hardware details from source review; added Enerpro FCOG6100 serial numbers and Galil DMC-4143 Rev 1.3h details; corrected AI technical note file names to match actual repository paths; updated gap analysis with findings from comprehensive source review; added Appendix D mapping Doc L sections to original sources |
| 5.1 | 2026-03-24 | Critical correction: properly distinguished original source documents (PDFs, docx, code) from AI-generated analysis products (technical notes, obsolete design docs); rewrote provenance model so all new documents cite original sources directly; added review status framework for AI-generated content; removed citations of unreviewed AI summaries as authoritative references |
| 5.0 | 2026-03-23 | Complete rewrite: verified file paths, added inventories, gap analysis, reading paths, conventions |
| 4.0 | 2026-03-22 | Four-tier architecture proposal with traceability appendices |
| 1.0–3.0 | 2026-03-19 to 21 | Earlier iterations |

---

## Table of Contents

1. [Purpose and Scope](#1-purpose-and-scope)
2. [Document Provenance — A Critical Distinction](#2-document-provenance--a-critical-distinction)
3. [Four-Tier Documentation Architecture](#3-four-tier-documentation-architecture)
4. [Original Source Document Inventory](#4-original-source-document-inventory)
5. [AI-Generated Analysis Products — Review Status](#5-ai-generated-analysis-products--review-status)
6. [Tier 0 — Master Document Index](#6-tier-0--master-document-index)
7. [Tier 1 — RF Physics, Control Theory and Physical Plant (Doc P)](#7-tier-1--rf-physics-control-theory-and-physical-plant-doc-p)
8. [Tier 2 — Legacy System and Operational Reference](#8-tier-2--legacy-system-and-operational-reference)
9. [Tier 3 — Upgrade Design Documents](#9-tier-3--upgrade-design-documents)
10. [Documentation Gap Analysis](#10-documentation-gap-analysis)
11. [Reading Paths by Role](#11-reading-paths-by-role)
12. [Document Conventions and Standards](#12-document-conventions-and-standards)
13. [Implementation Priorities and Action Items](#13-implementation-priorities-and-action-items)
14. [Appendix A — Subsystem × Tier Cross-Reference Matrix](#appendix-a--subsystem--tier-cross-reference-matrix)
15. [Appendix B — Source Document Catalog](#appendix-b--source-document-catalog)
16. [Appendix C — AI-Generated Analysis Review Checklist](#appendix-c--ai-generated-analysis-review-checklist)
17. [Appendix D — Doc L Section ↔ Original Source Cross-Reference](#appendix-d--doc-l-section--original-source-document-cross-reference)

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

| Directory | Content | Original Sources | AI-Generated MD |
|-----------|---------|------------------|-----------------|
| `hvps/` | High Voltage Power Supply | ~100 PDFs, ~30 docx, ~10 xlsx, PNG | 58 markdown files |
| `llrf/` | Low-Level RF | ~80 PDFs, ~12 docx, ~8 xlsx, 1 tex | 26 markdown files |
| `pps/` | Personnel Protection System | 6 PDFs, 1 docx | 13 markdown files |
| `spear-rf-code-legacy/` | Complete legacy codebase | 2,293 source code files | 9 markdown files |
| `Designs/` | System Design Report, this proposal | 1 docx (PDR R1), 1 vsdx | 14 markdown files |
| `Docs_JS/` | Jim Sebek's original docx files | 4 docx | — |
| `Archived/` | Earlier drafts | 2 docx (PDR V0, V0_jjs) | 3 markdown files |


---

## 2. Document Provenance — A Critical Distinction

> **This section corrects a fundamental error in v5.0 and all earlier versions of this proposal.**

The repository contains two fundamentally different categories of content that must not be confused:

### 2.1 Original Source Documents (Authoritative)

These are human-authored or human-generated engineering artifacts that carry engineering authority:

- **Engineering PDFs**: Schematics, wiring diagrams, drawings, specifications, data sheets, conference papers, signed safety reviews — created by engineers at SLAC, PEP-II project, or vendors
- **Human-authored docx**: Jim Sebek's operational notes, design specifications, and task lists; engineering design notes by project team members; EWP procedures; commissioning logs
- **Measurement data (xlsx)**: Calibration records, test measurements, PLC labels, reliability data — captured from actual hardware
- **Original source code**: The 2,293 legacy source files in `spear-rf-code-legacy/` — the actual VXI/EPICS/SNL/DSP code that runs the system
- **Other originals**: PowerPoint presentations, Visio drawings, LaTeX documents (llrf9Tests.tex), Galil firmware hex files, text log files

These are the **ground truth**. Any new design document must cite these directly.

### 2.2 AI-Generated Analysis Products (Unreviewed Drafts)

Every markdown (.md) file in the technical-notes directories, transcription directories, and `Designs/obsolete/` was generated by AI as a review or analysis of the original source documents listed above. These include:

- **Technical notes** (`hvps/*/technical-notes/*.md`, `llrf/*/technical-notes/*.md`, `pps/diagrams/*.md`) — AI-generated analyses of PDF schematics, docx notes, and engineering documents
- **Transcriptions** (`hvps/architecture/originalDocuments/transcriptions/*.md`, `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/*.md`) — AI-generated OCR transcriptions and interpretations of legacy PDFs
- **Obsolete design documents** (`Designs/obsolete/*.md` — Docs A, B, 3, 4, 5, 8, 10, 11) — AI-generated summary/design documents that attempted to synthesize information from original sources and technical notes
- **Code review technical notes** (`spear-rf-code-legacy/codeReviewTechnicalNotes/*.md`) — AI-generated analysis of the legacy source code
- **Archived drafts** (`Archived/*.md`) — Earlier AI-generated document drafts

These are **useful work products** — they represent significant analytical effort and can accelerate human review. However, they carry **zero engineering authority** until reviewed and verified by a named engineer against the original source documents.

### 2.3 The Correct Provenance Flow

```
ORIGINAL SOURCE DOCUMENTS (ground truth, authoritative)
  ├── Engineering PDFs (schematics, specs, drawings, papers)
  ├── Human-authored docx (Jim Sebek, design notes, procedures)
  ├── Measurement data (xlsx — calibrations, tests, reliability)
  ├── Original source code (2,293 files)
  └── Other originals (pptx, tex, hex, vsdx, txt logs)
        │
        │  AI analysis (recent, unreviewed)
        ▼
  AI-GENERATED ANALYSIS PRODUCTS (drafts, need human review)
  ├── 60+ technical notes markdown files
  ├── ~20 transcription markdown files
  ├── 8 obsolete design document drafts
  ├── 9 code review technical notes
  └── 3 archived earlier drafts
        │
        │  Human review + original source verification
        ▼
  NEW DESIGN DOCUMENTS (to be created, citing original sources)
  ├── Doc 0  — System Design Report (exists, based on docx PDR)
  ├── Doc P  — RF Physics & Plant (to be written)
  ├── Doc L  — Legacy System Architecture (to be written)
  ├── Doc D  — Operational Data Catalog (to be written)
  └── U1–U10 — Upgrade subsystem specifications (various states)
```

### 2.4 Rule: New Documents Must Cite Original Sources

All new design documents (Doc P, Doc L, Doc D, U1–U10) must reference **original source documents** as their authority — the actual PDF schematic, the actual docx design note, the actual source code file. They may reference AI-generated technical notes as "preliminary analysis (AI-generated, see [filename], unreviewed)" but must not rely on them as authoritative sources.

### 2.5 Special Cases

| Document | Status | Notes |
|----------|--------|-------|
| `Designs/0_SYSTEM_DESIGN_REPORT.md` (Doc 0) | **Under PDR review** | Markdown version of `Designs/docx/SPEAR3_LLRF_PDR_R1.docx`. The docx is the authoritative version. |
| `pps/pps_Ben.md` | **Transcription of meeting** | Ben Morris PPS Interface Upgrade Proposal transcribed from March 5, 2026 meeting. Quasi-original — content comes directly from human presentation. |
| `pps/MSG from Jim Sebek to Faya about PPS.md` | **Transcribed email** | Jim Sebek's 2022 email thread, transcribed. Original human content. |
| `hvps/documentation/switchgear/technical_notes/*.docx` | **Uncertain provenance** | These docx files exist alongside AI-generated .md files. Need to determine if they are human-authored originals or AI-generated exports. |


---

## 3. Four-Tier Documentation Architecture

The documentation is organized into four tiers. This structure remains sound from earlier versions of this proposal — what changes is the provenance model and where references point.

```
Tier 0 ─── Master Document Index (navigation layer)
  │
Tier 1 ─── RF Physics, Control Theory & Physical Plant (Doc P)
  │         One document: physics that doesn't change with the upgrade
  │         Sources: original PEP-II PDFs, conference papers, textbooks
  │
Tier 2 ─── Legacy System & Operational Reference
  │         ├── Doc L  — Legacy System Architecture (consolidated reference)
  │         ├── Doc D  — Operational Data Catalog (measurements, calibrations)
  │         └── Original source documents remain in their current locations
  │         Sources: original PDFs, docx, schematics, code, xlsx
  │
Tier 3 ─── Upgrade Design Documents
            ├── Doc 0  — System Design Report (top-level PDR)
            └── U1–U10 — Individual subsystem upgrade specifications
            Sources: original docx designs, equipment manuals, vendor docs
```

### 3.1 Key Principles

1. **Physics is separated from implementation.** Tier 1 (Doc P) covers cavity equations, beam loading, feedback theory, and plant parameters. These do not change when the hardware is upgraded.

2. **Original sources are the authority.** All new documents cite original PDFs, docx, schematics, and code. AI-generated analyses serve as preliminary work products to accelerate writing, not as authoritative references.

3. **Upgrade documents are modular.** Each upgrade document (U1–U10) covers one subsystem and can be written, reviewed, and approved independently.

4. **AI analyses are a review backlog, not finished documentation.** The ~100 AI-generated markdown files are valuable as a head start on systematic documentation, but each needs human verification before it can carry engineering authority.

5. **Existing original sources stay in place.** PDFs, schematics, docx files, and source code remain in their current directory locations. New design documents reference them by path.

### 3.2 Status of Existing Directories

| Directory | Disposition |
|-----------|-------------|
| `Docs_JS/` | Jim Sebek's original docx files. **Retain as primary sources.** Unique operational reference (`LLRFOperation_jims.docx`) and latest task list (`LLRFUpgradeTaskListRev3.docx`). Two files duplicated in `llrf/architecture/`. |
| `Archived/` | Earlier AI-generated document drafts plus two early PDR docx versions. **Retain for historical reference.** No content needs migration — all superseded. |
| `Designs/obsolete/` | Eight AI-generated design document drafts (Docs A, B, 3, 4, 5, 8, 10, 11). **Retain as reference for AI analysis.** These are unreviewed drafts that synthesize content from original sources. Useful as starting points when writing the new U-documents, but not authoritative. |

---

## 4. Original Source Document Inventory

This section catalogs the **authoritative original source documents** by subsystem. These are the ground truth from which all design documentation must ultimately derive.

### 4.1 HVPS Original Sources

**Engineering Schematics (PDF)** — `hvps/documentation/schematics/`:
- sd2372301200.pdf, sd2372301401.pdf — Regulator board schematics
- sd7307900101.pdf — HVPS system schematic
- sd7307900501.pdf — System overview schematic
- sd7307930304.pdf, sd7307930402.pdf, sd7307930702.pdf, sd7307930801.pdf — Phase tank schematics
- sd7307931203.pdf, sd7307931301.pdf — Crowbar and protection schematics
- sd7307940400.pdf — Control/monitoring schematic

**Wiring Diagrams (PDF)** — `hvps/documentation/wiringDiagrams/`:
- ei7307900000.pdf — Equipment interconnection
- wd7307900103.pdf — Phase tank trigger wiring
- wd7307900206.pdf, wd7307940200-600.pdf — HVPS wiring diagrams (6 total)

**Switchgear Drawings (PDF)** — `hvps/documentation/switchgear/`:
- gp3085000103.pdf — Switchgear schematic and arrangement
- gp4397040201.pdf — Vacuum contactor schematic
- id3088010601.pdf — Connection wiring diagram
- rossEngr713203.pdf — Ross Engineering energy storage schematic
- DOC041421-04142021114320.pdf — Additional switchgear documentation
- DB41-122m MCO.pdf — Motor control operator documentation

**PEP-II Architecture Documents (PDF/PPTX)** — `hvps/architecture/originalDocuments/`:
- slac-pub-7591.pdf — SLAC publication on PEP-II RF HVPS
- ps3413600102.pdf — PEP-II power supply specification
- pepII supply.pptx — PEP-II supply presentation

**Enerpro SCR Board Documentation (PDF)** — `hvps/controls/enerpro/enerproDocuments/`:
- 12 PDFs including FCOG1200 schematics (revisions F, K, L), operating manuals, product data, auto-balance documentation, Bourbeau IEEE 1983 paper, and "Closing the Loop" application note

**PLC Documentation (PDF)** — `hvps/documentation/plc/`:
- CasselPLCCode.pdf — PLC program listing
- CasselSymbolDatabase.pdf — PLC symbol database
- Cassel_land.pdf — PLC ladder logic documentation

**Human-Authored Design Notes (docx)** — `hvps/architecture/designNotes/`:
- EnerproVoltageandCurrentRegulatorBoardNotes.docx
- HoffmanBoxPPSWiring.docx, HoffmanBoxPowerDistribution.docx
- RFSystemMPSRequirements.docx
- controllerFiberOpticConnections.docx, interfacesBetweenRFSystemControllers.docx
- hoffmanTestingNotes.docx, regulatorEnerproTestingNotes.docx
- rfedmHvpsLabelsPvs.docx
- LLRFUpgradeTaskListRev0.docx

**Enerpro Discussion Notes (docx)** — `hvps/controls/enerpro/`:
- enerproBoardHvps.docx, enerproDiscussion07072022.docx, enerproPhaseReferenceAdapter.docx

**PLC Discussion Notes (docx)** — `hvps/documentation/plc/`:
- PLC software discusion 1.docx, plcNotesR1.docx

**Measurement Data (xlsx)**:
- `hvps/documentation/plc/hvpsMeasurements20220314.xlsx` — PLC measurements
- `hvps/documentation/plc/hvpsPlcLabels.xlsx` — PLC label database
- `hvps/documentation/wiringDiagrams/hvpsMonitorConnections.xlsx` — Monitor connections
- `hvps/maintenance/HVPSReliability.xlsx` — Failure and reliability records
- `hvps/maintenance/Spear1Tests20220817.xlsx` — SPEAR1 HVPS test data
- `hvps/maintenance/Spear2Tests2021.xlsx` — SPEAR2 HVPS test data
- `hvps/maintenance/phaseTankScrs.xlsx` — Phase tank thyristor records

**Safety Procedures & Reviews (docx/PDF)** — `hvps/documentation/procedures/`:
- ~17 docx EWP and safety review documents (crowbar, phase tank, main tank procedures)
- ~8 signed PDF safety reviews (SR-444-636 series) with audit records
- 3 xlsx complex lockout permits
- 1 PDF hazard analysis (`spear3HvpsHazards.pdf`)

**Other**:
- `hvps/documentation/hoistingRigging/` — Lift plan (docx, vsdx, PNG)
- `hvps/documentation/mechanical/` — Transformer assembly drawings (10 PNG)
- `hvps/documentation/stackAssemblies/` — Stack driver schematics and parts lists (9 PDF)
- `hvps/maintenance/` — Stack installation checklist (docx), phase tank maintenance (docx)

### 4.2 LLRF Original Sources

**Legacy Architecture PDFs** — `llrf/documentation/legacyArchitecture/`:
- PS-340-330 series: bd3403300000.pdf, bd3403300100.pdf, blockDiagrambd3403290100-1.pdf (block diagrams)
- ps3403305100.pdf (RF System Description), ps3403305200.pdf/feedbackLoopDescriptionps3403305200.pdf (Feedback Loop Description)
- ps3403305300.pdf through ps3403306102.pdf — 9 operational procedure documents (PS-340-330-53 through PS-340-330-61)
- architecture-and-performance-of-the-pep-ii-low-level-rf.pdf — Conference paper
- Operator_interface_for_the_PEP-II_low_level_RF_control_system.pdf — Conference paper
- TUPKF061.pdf — Conference paper

**Jim Sebek's Design Documents (docx)** — `llrf/architecture/`:
- WaveformBuffersforLLRFUpgrade.docx — Waveform buffer design
- llrfInterfaceChassis.docx — Interface chassis design
- arcDetectorHardwareOptions.docx — Arc detector hardware comparison
- analogDesignComponents.docx — Analog design components
- rfPowerDetector.docx — RF power detector design
- llrfUpgradeTasks20221108.docx — Upgrade task list (Nov 2022 revision)

**Jim Sebek's Operational Documents (docx)** — `Docs_JS/` and `llrf/documentation/`:
- LLRFOperation_jims.docx — Primary LLRF operational reference
- LLRFUpgradeTaskListRev3.docx — Latest upgrade task list (Rev 3)
- LLRFDocumentationNotesR2.docx — Documentation notes
- fiberOpticCableSignalControlRev3.docx — Fiber optic cable signal control

**LLRF9 Controller Documentation** — `llrf/llrf9/`:
- llrf9_manual_print.pdf — Dimtel LLRF9 manual
- iGp/ — iGp software distribution (EDM screens, configuration, help files)

**Local Panel Drawings (PDF)** — `llrf/documentation/localPanel/`:
- 13 PDF drawings: ad, dl, gp, ml, pc, pf, sd, si series panel layouts

**Legacy Interface Modules (PDF)** — `llrf/documentation/legacyInterfaceModules/`:
- SD-340-308-01-R1-1of1.pdf, SD-340-308-02-R1.pdf, sd3403090102.pdf

**MPS Wiring Diagrams (PDF)** — `llrf/documentation/mpsWiringDiagrams/`:
- 33 wiring diagrams: wd3403300200.pdf through wd3403303400.pdf

**Arc Detector Documentation** — `llrf/arcDetector/`:
- Waveguide Arc Detector_product sheet.pdf, microStepMISarcDetector.pdf — Product sheets
- tups072.pdf — Conference paper on waveguide arc detection
- mechanical/ — Mechanical drawings subdirectory

**Tuner / Galil Documentation** — `llrf/tuners/`:
- `galil/dmc-4103-r13h-manual.pdf` — Galil DMC-4103 manual
- `galil/ds_41x3.pdf` — Galil DMC-41x3 datasheet
- `galil/GalilCommissioning.docx` — Commissioning log
- `galil/dmc-4103-r13k.hex`, `galil/dmc-4103-r13k-ser.hex` — Firmware
- `galil/firstMotion2024.txt`, `galil/functioningGalil20250825SwapABToManual.txt` — Test logs
- `galil/readme.txt`, `galil/doc.pdf` — Additional documentation
- `Old Stepper Catalog_Superior Electric_0.pdf` — Legacy stepper motor catalog
- `SLO-SYN.pdf`, `SLO-SYN_MD808_Stepper_Drive_Manual.pdf`, `SLO-SYN_SS2000MD4M_Step_Drive_Translator_Manual.pdf` — Stepper motor/drive manuals
- `cavityTunerInspections20230613.docx` — Cavity tuner inspection records

**Other LLRF Documentation**:
- `llrf/documentation/coaxCables/sd3403300100.pdf` — Coax cable drawing
- `llrf/documentation/filamentHeater/sd3403110002.pdf` — Filament heater schematic
- `llrf/driveAmp/KAW2051M12 (7-98-907-012A).pdf` — Drive amplifier datasheet
- `llrf/documentation/LocalPanelToXConnectMapping.xlsx` — Panel-to-cross-connect mapping
- `llrf/documentation/RfSystemDocumentIndexR3.xlsx` — RF system document index (Jim Sebek's master index)

**Calibration Data (xlsx)** — `llrf/calibrations/`:
- driveAmpCalibration.xlsx, klystronCouplerDriveAmpCalibrations.xlsx
- pulsarCouplerCalibration2049.xlsx, reflectedPowerCalibrations.xlsx
- tuneModeDacCalibration.xlsx, b132R11PatchPanel.xlsx

**Test Results** — `llrf/tests/`:
- llrf9Tests.tex — Human-authored LaTeX test report (original)
- llrf9Tests.pdf — Compiled PDF
- graphics/ — Test result plots (PNG/PDF)

### 4.3 PPS Original Sources

**Schematics (PDF)** — `pps/`:
- gp4397040201.pdf — Vacuum contactor schematic
- rossEngr713203.pdf — Ross Engineering shorting switch schematic
- sd7307900501.pdf — System schematic
- wd7307900103.pdf, wd7307900206.pdf, wd7307940600.pdf — Wiring diagrams

**Design Notes (docx)** — `pps/`:
- HoffmanBoxPPSWiring.docx — Hoffman box PPS wiring documentation

**Human Communications (markdown, original content)** — `pps/`:
- pps_Ben.md — Ben Morris PPS Interface Upgrade Proposal (March 5, 2026 meeting transcription)
- MSG from Jim Sebek to Faya about PPS.md — Jim Sebek 2022 email thread on PPS compliance concerns

### 4.4 Legacy Code Original Sources

**Source Code** — `spear-rf-code-legacy/`:
- 2,293 source files (RCS versioned with `,v` suffix) including:
  - `rfApp/` — Main RF application: EPICS databases, SNL state machines (rf_states.st, rf_tuner_loop.st, rf_hvps_loop.st, rf_dac_loop.st, rf_calib.st, rf_msgs.st), C source, KSC VXI driver
  - `dsp1610/` — TMS320C16xx DSP firmware (assembly)
  - `allenBradley/` — Allen-Bradley PLC interface drivers and EPICS device support
  - `epvxi/` — EPICS VXI support drivers
  - `stepper/` — Stepper motor control code
  - `iocBoot/` — IOC boot configurations
  - `configure/` — Build system configuration

### 4.5 Design Document Original Sources

- `Designs/docx/SPEAR3_LLRF_PDR_R1.docx` — PDR Rev 1 (authoritative version of Doc 0)
- `Designs/docx/drawings/PRD_drawings.vsdx` — PDR Visio drawings
- `Archived/0_SPEAR3_LLRF_PDR_V0.docx` — PDR V0 (earlier draft)
- `Archived/0_SPEAR3_LLRF_PDR_V0_jjs.docx` — PDR V0 with Jim Sebek's comments

### 4.6 Cross-Cutting Reference

Jim Sebek's `llrf/documentation/RfSystemDocumentIndexR3.xlsx` is a master index of RF system documents maintained by the original system engineer. This should be treated as the most authoritative existing document catalog and cross-referenced when building the Master Index (Tier 0).


---

## 5. AI-Generated Analysis Products — Review Status

This section catalogs all AI-generated markdown files in the repository, organized by subsystem. Each file was created by AI analysis of original source documents. **None of these files carry engineering authority until reviewed by a named engineer against the original source documents.**

### 5.1 Review Status Codes

| Code | Meaning |
|------|---------|
| `UNREVIEWED` | AI-generated, not yet reviewed by any engineer |
| `IN REVIEW` | Currently being reviewed by a named engineer |
| `REVIEWED` | Verified against original source by named engineer (date and name recorded) |
| `SUPERSEDED` | Content has been incorporated into a new design document; this file is for reference only |

### 5.2 HVPS AI-Generated Technical Notes

**Architecture Technical Notes** — `hvps/architecture/technical-notes/`:

| File | Original Source | Status |
|------|----------------|--------|
| HVPS_ARCHITECTURE_TN_00_*.md | slac-pub-7591.pdf, ps3413600102.pdf, pepII supply.pptx | UNREVIEWED |
| HVPS_ARCHITECTURE_TN_01_*.md | slac-pub-7591.pdf | UNREVIEWED |
| HVPS_ARCHITECTURE_TN_02_*.md | pepII supply.pptx | UNREVIEWED |
| HVPS_ARCHITECTURE_TN_03_*.md | ps3413600102.pdf | UNREVIEWED |
| HVPS_ARCHITECTURE_TN_04_*.md | (synthesis) | UNREVIEWED |
| HVPS_ARCHITECTURE_TN_05_*.md | designNotes docx | UNREVIEWED |
| HVPS_ARCHITECTURE_TN_06_*.md | designNotes docx | UNREVIEWED |

**PEP-II Document Transcriptions** — `hvps/architecture/originalDocuments/transcriptions/`:

| File | Original Source | Status |
|------|----------------|--------|
| pepII_supply_transcription.md | pepII supply.pptx | UNREVIEWED |
| ps3413600102_transcription.md | ps3413600102.pdf | UNREVIEWED |
| slac-pub-7591_transcription.md | slac-pub-7591.pdf | UNREVIEWED |

**Enerpro Technical Notes** — `hvps/controls/enerpro/technical-notes/`:

| File | Original Source | Status |
|------|----------------|--------|
| ENERPRO_TN_00 through 08 (9 files) | Enerpro PDFs + enerproBoardHvps.docx | UNREVIEWED |

**PLC Technical Notes** — `hvps/documentation/plc/technical-notes/`:

| File | Original Source | Status |
|------|----------------|--------|
| PLC_TN_00_overview through PLC_TN_09 (10 files) | CasselPLCCode.pdf, CasselSymbolDatabase.pdf, plcNotesR1.docx | UNREVIEWED |

**Schematics Technical Notes** — `hvps/documentation/schematics/technical_notes/`:

| File | Original Source | Status |
|------|----------------|--------|
| TN_HVPS_System_Overview.md + 13 schematic-specific TN | Individual schematic PDFs (sd-series) | UNREVIEWED |

**Switchgear Technical Notes** — `hvps/documentation/switchgear/`:

| File | Original Source | Status |
|------|----------------|--------|
| README.md + 4 TN_*.md (and corresponding .docx) | Switchgear PDFs (gp, id, ross series) | UNREVIEWED |

**Wiring Diagram Technical Note** — `hvps/documentation/wiringDiagrams/`:

| File | Original Source | Status |
|------|----------------|--------|
| phase_tank_wiring_technical_note.md | wd7307940200-600.pdf series | UNREVIEWED |

### 5.3 LLRF AI-Generated Technical Notes

**Legacy Architecture Technical Notes** — `llrf/documentation/legacyArchitecture/technical-notes/`:

| File | Original Source | Status |
|------|----------------|--------|
| LLRF_TN_00 through 05 (6 files) | Legacy architecture PDFs, transcriptions | UNREVIEWED |

**Legacy PDF Transcriptions** — `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/`:

| File | Original Source | Status |
|------|----------------|--------|
| ~17 transcription files | PS-340-330 series PDFs, block diagrams, conference papers | UNREVIEWED |

**Filament Heater Technical Note** — `llrf/documentation/filamentHeater/`:

| File | Original Source | Status |
|------|----------------|--------|
| FILAMENT_HEATER_TECHNICAL_NOTES.md | sd3403110002.pdf | UNREVIEWED |

### 5.4 PPS AI-Generated Technical Notes

**PPS Diagrams / Analysis** — `pps/diagrams/`:

| File | Original Source | Status |
|------|----------------|--------|
| 00_PPS_System_Overview.md through 08 (9 files) + README.md | PPS schematic PDFs, HoffmanBoxPPSWiring.docx | UNREVIEWED |

### 5.5 Code Review Technical Notes

**Code Review Series** — `spear-rf-code-legacy/codeReviewTechnicalNotes/`:

| File | Original Source | Status |
|------|----------------|--------|
| 00_CODE_REVIEW_MASTER_INDEX.md | Synthesis of all code analysis | UNREVIEWED |
| 01_REPO_STRUCTURE_AND_BUILD_SYSTEM.md | Build files, Makefiles | UNREVIEWED |
| 02_EPICS_IOC_AND_DATABASE_LAYER.md | rfApp/Db/*.db, iocBoot/ | UNREVIEWED |
| 03_SNL_STATE_MACHINES.md | rfApp/src/seq/*.st | UNREVIEWED |
| 04_DSP_FIRMWARE.md | dsp1610/ | UNREVIEWED |
| 05_VXI_HARDWARE_INTERFACE.md | epvxi/, KSC driver | UNREVIEWED |
| 06_PLC_INTERFACE.md | allenBradley/ | UNREVIEWED |
| 07_SIGNAL_PROCESSING.md | rfApp/src/seq/ signal processing | UNREVIEWED |
| 08_TUNER_AND_STEPPER.md | stepper/, rf_tuner_loop.st | UNREVIEWED |

### 5.6 Obsolete Design Documents (AI-Generated Drafts)

**Designs/obsolete/**:

| File | Content Description | Status |
|------|---------------------|--------|
| A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md | AI synthesis of legacy LLRF system | UNREVIEWED |
| B_SPEAR3_CURRENT_LLRF_TECHINICAL_DESIGN_REPORT.md | AI synthesis of current LLRF system | UNREVIEWED |
| 3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md | AI synthesis of LLRF9 upgrade design | UNREVIEWED |
| 4_HVPS_Engineering_Technical_Note.md | AI synthesis of HVPS engineering | UNREVIEWED |
| 5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md | AI draft of klystron heater upgrade | UNREVIEWED |
| 8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md | AI draft of PPS interface design | UNREVIEWED |
| 10_SOFTWARE_DESIGN_DOCUMENT.md | AI draft of software design | UNREVIEWED |
| 11_INTERFACE_CHASSIS_DESIGN.md | AI draft of interface chassis design | UNREVIEWED |

### 5.7 Review Process

When a named engineer reviews an AI-generated file:

1. **Compare against original source document(s)** cited in the file header
2. **Mark errors, omissions, and misinterpretations** directly in the file or as comments
3. **Update the status** in this section from `UNREVIEWED` to `REVIEWED BY [name] [date]`
4. **Note any corrections** that change the technical content

**Priority order for reviews**: Safety-critical content first (MPS, crowbar protection, PPS), then operational procedures, then reference material.


---

## 6. Tier 0 — Master Document Index

**Status**: To be created  
**Proposed location**: `Designs/00_MASTER_INDEX.md`  
**Priority**: Medium (can be generated once other documents stabilize)

### 6.1 Purpose

A single navigation page that catalogs every document in the repository, organized by tier and subsystem. This is the entry point for anyone new to the project.

### 6.2 Proposed Contents

1. **Quick Navigation Table**: Tier × Subsystem matrix (see Appendix A) with links
2. **Complete Document Registry**: Every file listed with path, type (original / AI-generated), status, and subsystem
3. **Getting Started Guides**: Curated reading paths for different roles (see §11)
4. **Cross-reference to Jim Sebek's master index**: `llrf/documentation/RfSystemDocumentIndexR3.xlsx`

---

## 7. Tier 1 — RF Physics, Control Theory and Physical Plant (Doc P)

**Status**: To be written  
**Proposed location**: `Designs/P_RF_PHYSICS_AND_PLANT.md`  
**Priority**: High — needed by all Tier 3 upgrade documents

### 7.1 Purpose

A self-contained reference document covering the RF physics, control theory, and physical plant parameters that are **independent of the specific control hardware implementation**. This content does not change when VXI hardware is replaced with the LLRF9 controller.

### 7.2 Content Outline and Source References

Each section below lists the **original source documents** to be consulted. AI-generated technical notes are noted parenthetically as preliminary analysis aids.

| Section | Topic | Original Sources |
|---------|-------|-----------------|
| §1 | SPEAR3 RF accelerating system overview | slac-pub-7591.pdf, ps3413600102.pdf, pepII supply.pptx |
| §2 | Cavity physics: impedance, detuning, beam loading | Textbook references (Wiedemann, Wangler), ps3403305200.pdf (feedback loop description) |
| §3 | I/Q feedback control theory | architecture-and-performance-of-the-pep-ii-low-level-rf.pdf, TUPKF061.pdf |
| §4 | Feedback loop transfer functions and stability | ps3403305200.pdf, feedbackLoopDescriptionps3403305200.pdf |
| §5 | HVPS plant model: SCR bridge, power supply dynamics | slac-pub-7591.pdf, ps3413600102.pdf, Enerpro FCOG1200 manuals |
| §6 | Klystron characteristics and operating points | Klystron vendor data, llrf9Tests.pdf |
| §7 | Tuner mechanics and resonant frequency control | SLO-SYN motor manuals, galil/dmc-4103-r13h-manual.pdf, cavityTunerInspections20230613.docx |
| §8 | Signal processing: baseband conversion, DSP algorithms | dsp1610/ source code, rfApp/src/seq/ source code |
| §9 | Noise, stability, and performance requirements | llrf9Tests.pdf/tex, calibration xlsx data |

*Preliminary AI analysis exists in*: LLRF_TN_00 through 05, HVPS_ARCHITECTURE_TN_00 through 06, Code Review TN 04 and 07 *(all unreviewed)*

### 7.3 Key Characteristics

- **Does NOT contain**: Hardware-specific implementation details, upgrade designs, or operational procedures
- **Does contain**: Equations, transfer functions, plant parameters, physical constants, measurement definitions
- **References**: Original PDFs and textbooks; may note AI-generated analyses as "preliminary, unreviewed"
- **Estimated scope**: ~60–80 pages equivalent

---

## 8. Tier 2 — Legacy System and Operational Reference

### 8.1 Doc L — Legacy System Architecture

**Status**: DRAFT v1.0 completed (1,323 lines, 21 sections, 50+ photo placeholders)  
**Location**: `Designs/L_LEGACY_SYSTEM_ARCHITECTURE.md`  
**Priority**: High — required context for all upgrade work

#### 8.1.1 Purpose

A consolidated, end-to-end reference for the legacy PEP-II/SPEAR3 RF system as currently installed and operating. Doc L serves three critical functions:
1. **Upgrade baseline** — provides the complete "as-built" reference against which upgrade designs (U1–U10) are specified
2. **Knowledge preservation** — captures institutional knowledge about a system designed in 1997 before key personnel retire and hardware is removed
3. **Operational reference** — consolidates scattered documentation (150+ PDFs, 50+ docx, 18+ xlsx, 2,293 code files) into a single navigable resource

#### 8.1.2 Document Structure (6 Parts, 21 Sections)

**Part I — System Overview** (§1–4):
- §1 Introduction, scope, PEP-II heritage → McIntosh SLAC-PUB-11017, Corredoura SLAC-PUB-8498
- §2 System architecture block diagram, subsystem summary → `sd7307900101.pdf`, `bd3403300000.pdf`, `bd3403300100.pdf`, Doc 0 §2.1
- §3 Physical layout across B118, B132, B514, tunnel → Doc 0 §3, `pps/HoffmanBoxPPSWiring.docx`, `wd7307900103.pdf`
- §4 Key system parameters (RF, HVPS, measured June 2020 data) → `llrf9Tests.pdf`, `hvpsMeasurements20220314.xlsx`

**Part II — RF Signal Chain** (§5–8):
- §5 LLRF Controller (VXI system) — 10-slot module inventory, RFP feedback, IQA measurement, AIM interlocks, feedback loops (4 active, 3 PEP-II-only), DCM serial communication → `ps3403305100.pdf` (11 pages), `bd3403300000.pdf`, Corredoura SLAC-PUB-8498, all `rf_*.st` and `rf_*_pvs.h` source files
- §6 Klystron and drive system — SLAC 476 MHz CW klystron, KAW2051M12 drive amp, collector power protection → `spear3HvpsHazards.tex`, `KAW2051M12.pdf`, `rf_hvps_loop.st`
- §7 Waveguide distribution — circulator → 3 magic-tees → 4 cavities, 24 monitored RF signals → Doc 0 §4.2/§4.6, `sd3403300100.pdf`
- §8 RF cavities and tuner assemblies — 4 PEP-II single-cell HOM-damped copper cavities, SLO-SYN M093-FC11 motors, Galil DMC-4143 Rev 1.3h (commissioned Aug 2025) → `SLO-SYN*.pdf`, `galil/dmc-4103-r13h-manual.pdf`, `cavityTunerInspections20230613.docx`

**Part III — Power Systems** (§9–12):
- §9 HVPS power section — 12-pulse thyristor bridge (12 × Powerex T8K7 SCR stacks), T0/T1/T2 transformers, L1/L2 filter inductors, secondary rectifiers, crowbar, cable inductors L3/L4 → all 11 schematic PDFs, `slac-pub-7591.pdf`, `ps3413600102.pdf`
- §10 HVPS control system (Hoffman Box) — SLC-500 PLC (13 slots), analog regulator card (PC-237-230), terminal strips, voltage regulation loop → `CasselPLCCode.pdf`, `CasselSymbolDatabase.pdf`, `plcNotesR1.docx`, `sd2372301401.pdf`, `wd7307900206.pdf`
- §11 Enerpro SCR firing system — **FCOG6100 Rev.K** (S/N: 41506, 50470, 30045), **FCOAUX60 Rev D** (S/N: 03198, 03813, 1694), custom phase reference adapter (3×2MΩ resistors) → `hvps/controls/enerpro/enerproDocuments/` (12 PDFs), `enerproBoardHvps.docx`, `enerproPhaseReferenceAdapter.docx`
- §12 Arc protection — PEP-II 4-layer architecture: Layer 1 SCR inhibit (<1μs), Layer 2 crowbar (<1μs), Layer 3 500Ω isolation (passive), Layer 4 cable inductors (passive) → `slac-pub-7591.pdf`, `sd7307931203.pdf`, `sd7307931301.pdf`

**Part IV — Protection and Safety Systems** (§13–15):
- §13 PPS Interface — ⚠️ critical compliance issue (PLC in PPS chain), K4/MX/RR relay chain, Ross HQ3 vacuum contactor + HCA-1-A controller, Ross grounding switch → `pps/HoffmanBoxPPSWiring.docx` (80 paragraphs, 5 tables), `gp4397040201.pdf`, `rossEngr713203.pdf`, `sd7307900501.pdf`, `wd7307900103.pdf`/`wd7307900206.pdf`/`wd7307940600.pdf`
- §14 RF MPS — PLC-5 (1771) → **ControlLogix 1756** (hardware assembled, software written, tested without RF power) → `llrf/documentation/mpsWiringDiagrams/` (33 wiring diagrams), `RFSystemMPSRequirements.docx`
- §15 Interlock architecture — multi-layer trip chain: Fast Interlock Chassis (<1μs) → RF MPS (~10ms) → SLC-500 HVPS (~100ms) → VXI/SNL (~1s) → fault file capture → Doc 0 §17, `rf_states.st`

**Part V — Control Software and Instrumentation** (§16–18):
- §16 EPICS IOC and SNL software — 6 SNL programs: `rf_states.st` (2,227 lines, **23 states across 3 concurrent state sets**), `rf_calib.st` (3,345 lines, 28 calibration states), `rf_tuner_loop.st` (555 lines × 4 instances), `rf_hvps_loop.st` (343 lines), `rf_dac_loop.st` (290 lines, ⚠️ eliminated in upgrade), `rf_msgs.st` (352 lines) + 12 header files (~1,151 lines) → `spear-rf-code-legacy/rfApp/src/seq/` (all source files)
- §17 Tuner control — Legacy: AB 1746-HSTP1 + SLO-SYN SS2000MD4-M (obsolete) → Current: **Galil DMC-4143 Rev 1.3h** (commissioned Aug 2025, Ethernet) → `galil/functioningGalil20250825SwapABToManual.txt`, `galil/firstMotion2024.txt`, `GalilCommissioning.docx`
- §18 Diagnostics, calibration, fault recording — 24 RF signal monitoring, IQA-based measurement, PLC monitoring (thermocouples, oil levels), fault file circular buffer (11 files) → `rf_calib.st`, `llrf/calibrations/` (6 xlsx), `llrf9Tests.pdf`

**Part VI — Integration and Legacy Considerations** (§19–21):
- §19 Cabling and interconnections — B118↔Switchgear (Belden 83715), B118↔B514 (fiber optic + electrical), B132↔Tunnel (RF coax + motor) → `wd7307900103.pdf`, `wd7307900206.pdf`, `wd7307940600.pdf`
- §20 Known issues and legacy debt — 6 critical/high issues (PPS compliance, VXI obsolescence, SLC-500 EOL, PLC-5 MPS, SLO-SYN obsolescence, VxWorks/SNL) + 4 documentation gaps → all sources cross-referenced
- §21 Source document reference index — complete catalog organized by subsystem → cross-referenced against `RfSystemDocumentIndexR3.xlsx`

**Cross-cutting features**:
- 50+ photo placeholders with specific descriptions of exact shot needed
- Every section cites original source documents directly
- AI technical notes as secondary "See also" references with `(AI-generated, UNREVIEWED)` tag

#### 8.1.3 Current Status and Next Steps

Doc L v1.0 is a **comprehensive draft** requiring:
1. **Engineering review** — verify all technical claims against physical system and source documents
2. **Photo documentation** — capture all 50+ photo placeholders before legacy hardware removal
3. **PV and register verification** — confirm EPICS PV names and PLC register assignments against running system
4. **Operational setpoint capture** — record current alarm limits, tuning deadbands, and safe operating envelopes (feeds into Doc D)


### 8.2 Code Review Technical Notes

**Status**: Exist (AI-generated, unreviewed)  
**Location**: `spear-rf-code-legacy/codeReviewTechnicalNotes/`  
**Files**: 9 markdown files (00 master index + 01–08 topic-specific)

These are AI-generated analyses of the 2,293 legacy source files. They are organized as a self-contained series with a master index. They are valuable as a systematic walkthrough of the codebase but need human review before being cited as authoritative. See §5.5 for review status tracking.

### 8.3 Doc D — Operational Data & Baselines Catalog

**Status**: To be written — **CRITICAL PRIORITY** (time-sensitive)  
**Proposed location**: `Designs/D_OPERATIONAL_DATA_CATALOG.md`  
**Priority**: CRITICAL — data can only be captured while legacy system is still running

#### 8.3.1 Purpose

A catalog and analysis of operational data from the currently running SPEAR3 RF system. This includes calibration records, EPICS archiver data, performance baselines, and maintenance history. Once the legacy hardware is removed, this data cannot be re-measured.

#### 8.3.2 Existing Data Sources

| Data Type | Location | Format |
|-----------|----------|--------|
| Drive amp calibration | `llrf/calibrations/driveAmpCalibration.xlsx` | xlsx |
| Klystron coupler calibration | `llrf/calibrations/klystronCouplerDriveAmpCalibrations.xlsx` | xlsx |
| Pulsar coupler calibration | `llrf/calibrations/pulsarCouplerCalibration2049.xlsx` | xlsx |
| Reflected power calibration | `llrf/calibrations/reflectedPowerCalibrations.xlsx` | xlsx |
| Tune mode DAC calibration | `llrf/calibrations/tuneModeDacCalibration.xlsx` | xlsx |
| Patch panel mapping | `llrf/calibrations/b132R11PatchPanel.xlsx` | xlsx |
| PLC measurements | `hvps/documentation/plc/hvpsMeasurements20220314.xlsx` | xlsx |
| PLC label database | `hvps/documentation/plc/hvpsPlcLabels.xlsx` | xlsx |
| Monitor connections | `hvps/documentation/wiringDiagrams/hvpsMonitorConnections.xlsx` | xlsx |
| HVPS reliability records | `hvps/maintenance/HVPSReliability.xlsx` | xlsx |
| SPEAR1 HVPS test data | `hvps/maintenance/Spear1Tests20220817.xlsx` | xlsx |
| SPEAR2 HVPS test data | `hvps/maintenance/Spear2Tests2021.xlsx` | xlsx |
| Phase tank SCR records | `hvps/maintenance/phaseTankScrs.xlsx` | xlsx |
| LLRF9 test results | `llrf/tests/llrf9Tests.tex`, `llrf/tests/llrf9Tests.pdf` | LaTeX/PDF |
| Local panel mapping | `llrf/documentation/LocalPanelToXConnectMapping.xlsx` | xlsx |
| Simulation results | `hvps/simulation/hvps_sim/`, `hvps/simulation/pyspice_sim/` | PNG |
| RF system document index | `llrf/documentation/RfSystemDocumentIndexR3.xlsx` | xlsx |

#### 8.3.3 Data Still Needed (Must Capture Before Hardware Swap)

- EPICS archiver trends at representative operating points (500 mA stored beam)
- Live PV readings for all RF control channels
- Beam-based measurements of cavity response
- Current operational setpoints and tuning parameters
- Legacy system alarm limits and trip thresholds


---

## 9. Tier 3 — Upgrade Design Documents

### 9.1 Doc 0 — System Design Report (Exists)

**Status**: Under PDR review  
**Location**: `Designs/0_SYSTEM_DESIGN_REPORT.md` (markdown), `Designs/docx/SPEAR3_LLRF_PDR_R1.docx` (authoritative docx)  
**Constraint**: This document is preserved as-is during the current review cycle

Doc 0 defines 10 subsystems and serves as the top-level system design reference. All upgrade documents (U1–U10) must be consistent with Doc 0.

### 9.2 Upgrade Documents (U1–U10)

Each subsystem defined in Doc 0 gets a dedicated upgrade design document. These documents describe **what is being built** (new hardware, new software, new interfaces) and **how it connects** to the rest of the system.

| ID | Subsystem | Original Sources for Upgrade Design | Status |
|----|-----------|--------------------------------------|--------|
| U1 | LLRF Controller | llrf9_manual_print.pdf, iGp/ software, llrf9Tests.tex/pdf | In progress |
| U2 | HVPS Control Upgrade | hvps/architecture/designNotes/ (10 docx), Enerpro docs, schematic PDFs | In progress |
| U3 | RF Machine Protection System | wd3403300200-3400 (33 MPS wiring diagrams), RFSystemMPSRequirements.docx | **NOT STARTED** |
| U4 | Interface Chassis | llrfInterfaceChassis.docx, analogDesignComponents.docx | In progress |
| U5 | PPS Interface | pps_Ben.md (Ben Morris proposal, March 2026), Jim Sebek email, HoffmanBoxPPSWiring.docx, PPS schematic PDFs | In progress |
| U6 | Tuner Control System | galil/dmc-4103-r13h-manual.pdf, GalilCommissioning.docx, stepper motor manuals, SLO-SYN docs, firstMotion2024.txt | **NOT STARTED** (Galil commissioned Aug 2025) |
| U7 | Waveform Buffer System | WaveformBuffersforLLRFUpgrade.docx | **NOT STARTED** (design in docx only) |
| U8 | Arc Detection System | Waveguide Arc Detector product sheet, tups072.pdf, arcDetectorHardwareOptions.docx | **NOT STARTED** |
| U9 | Klystron Heater | sd3403110002.pdf (filament heater schematic) | In progress |
| U10 | Control Software | rfApp/ source code (legacy reference), LLRF9/iGp configuration | In progress |

*AI-generated preliminary drafts exist in* `Designs/obsolete/` — Docs 3, 4, 5, 8, 10, 11. These can serve as starting points for the corresponding U-documents but are unreviewed and must be verified against original sources before use.

### 9.3 Upgrade Document Standard Template

Each U-document should follow a consistent structure:

1. **Scope and Subsystem Boundary** — What this document covers; interfaces to other subsystems
2. **Legacy System Reference** — Pointer to relevant Doc L sections and original source documents
3. **Requirements** — Derived from Doc 0 with specific performance, interface, and safety requirements
4. **Design Description** — New hardware, firmware, software, and configuration
5. **Interface Specification** — Signals, protocols, cable/connector details
6. **Test Plan** — How the subsystem will be verified
7. **Risk and Mitigation** — Known risks and planned mitigations
8. **References** — Original source documents consulted (PDFs, docx, code paths)

---

## 10. Documentation Gap Analysis

### 10.1 Critical Gaps (Must Address Before Hardware Swap)

| Gap | Description | Action Required |
|-----|-------------|-----------------|
| Doc D not started | Operational baselines and live measurements not systematically captured | Begin Doc D immediately; capture EPICS archiver data, calibration baselines, operational setpoints |
| No reviewed legacy documentation | All AI-generated technical notes are unreviewed | Prioritize review of safety-critical content (MPS, PPS, crowbar) |

### 10.2 High-Priority Gaps (Required for Upgrade)

| Gap | Description | Action Required |
|-----|-------------|-----------------|
| U3 (RF MPS) not started | Hardware assembled, software not started, no design document | Write U3 from 33 MPS wiring diagrams + RFSystemMPSRequirements.docx |
| U6 (Tuner Control) not started | Galil commissioned Aug 2025 but design scattered across multiple sources | Write U6 from Galil docs + GalilCommissioning.docx + stepper motor manuals + test logs |
| U7 (Waveform Buffer) not started | Design exists only in WaveformBuffersforLLRFUpgrade.docx | Write U7 from Jim Sebek's docx |
| U8 (Arc Detection) not started | COTS hardware selected but no formal design document | Write U8 from arc detector product sheets + tups072.pdf + arcDetectorHardwareOptions.docx |
| Doc P not written | Physics reference needed by all upgrade documents | Write Doc P from original PEP-II documents and textbook references |
| Doc L v1.0 drafted | Engineering review and photo population needed | Review Doc L v1.0 (1,323 lines); verify against physical system; capture 50+ photos |

### 10.3 Knowledge Gaps (From `Designs/todo list.md`)

The repository contains a `Designs/todo list.md` that identifies specific knowledge gaps requiring investigation. These should be addressed in the relevant documents:

- Legacy system details that are only in Jim Sebek's institutional knowledge
- PLC ladder logic interpretation (some rungs not fully understood)
- Enerpro board revision differences (Rev F vs K vs L behavior)
- Phase tank SCR replacement history and failure modes
- MPS signal routing and trip logic (complex, safety-critical)

### 10.4 Reference Gaps

| Gap | Impact |
|-----|--------|
| No verified document catalog | Jim Sebek's `RfSystemDocumentIndexR3.xlsx` exists but needs to be reconciled with current repository |
| Switchgear TN docx provenance unclear | Need to determine if the 4 `.docx` files in `hvps/documentation/switchgear/technical_notes/` are human-authored or AI-generated |
| Simulation models undocumented | `hvps/simulation/` contains two simulation packages with results but no formal documentation |


---

## 11. Reading Paths by Role

Different readers need different entry points. The Master Index (Tier 0) should prominently feature these curated paths.

### 11.1 New Engineer Orientation

**Goal**: Understand the overall system in 2–3 hours

1. Doc 0 §1–3 (System Design Report — executive summary, architecture, physical layout)
2. Doc P §1–4 (if written; otherwise: slac-pub-7591.pdf, architecture-and-performance-of-the-pep-ii-low-level-rf.pdf)
3. Doc L §1 (if written; otherwise: sd7307900501.pdf system schematic + bd3403300000.pdf block diagram)
4. `llrf/documentation/RfSystemDocumentIndexR3.xlsx` (Jim Sebek's master document index)

### 11.2 Upgrade Implementer (Specific Subsystem)

**Goal**: Everything needed to design and test one subsystem upgrade

1. Doc 0 — relevant subsystem section
2. Relevant U-document (U1–U10) — if it exists
3. Original source documents for that subsystem (see §4 inventory)
4. AI-generated technical notes for background (see §5 — note: unreviewed)
5. Doc D — relevant calibration data and operational baselines
6. Relevant original docx from Jim Sebek (Docs_JS/, llrf/architecture/)

### 11.3 Design Reviewer

**Goal**: Evaluate an upgrade design for completeness and correctness

1. Doc 0 — system context and requirements
2. Relevant U-document under review
3. Doc P — physics and plant parameters being relied upon
4. Original source schematics and specifications (§4) — to verify claims
5. Doc D — operational data that validates or constrains the design
6. `Designs/todo list.md` — known open issues

### 11.4 Operations / Maintenance Staff

**Goal**: Understand what changed and how to operate the upgraded system

1. Doc 0 §2 (system architecture) — what's new
2. Relevant U-documents — what changed in their area
3. `hvps/documentation/procedures/` — EWP and safety procedures
4. `LLRFOperation_jims.docx` — legacy operational reference
5. Doc D — calibration records and maintenance history

### 11.5 Future Maintainer (Post-Upgrade)

**Goal**: Understand the complete system years after the upgrade

1. Master Index (Tier 0) — navigate entire document set
2. Doc P — physics foundation
3. Doc L — why things were the way they were (legacy context)
4. Doc 0 + relevant U-documents — what was built and why
5. Code Review TN series — codebase walkthrough (once reviewed and verified)
6. Original source PDFs — when precise engineering details are needed

---

## 12. Document Conventions and Standards

### 12.1 File Naming

| Type | Convention | Example |
|------|-----------|---------|
| Design documents | `{ID}_{DESCRIPTIVE_NAME}.md` | `P_RF_PHYSICS_AND_PLANT.md` |
| Upgrade documents | `U{N}_{SUBSYSTEM_NAME}_UPGRADE.md` | `U3_RF_MPS_UPGRADE.md` |
| Technical notes | `{SUBSYSTEM}_TN_{NN}_{TOPIC}.md` | `LLRF_TN_03_SNL_STATE_MACHINES.md` |

### 12.2 Document Headers

Every markdown document should include:

```markdown
**Document ID**: [identifier]
**Version**: [version]
**Date**: [date]
**Status**: [DRAFT / IN REVIEW / APPROVED]
**Author**: [name(s)]
**Provenance**: [ORIGINAL / AI-GENERATED / AI-ASSISTED]
```

The `Provenance` field is **mandatory** and distinguishes between:
- `ORIGINAL` — Human-authored content
- `AI-GENERATED` — Content produced by AI analysis (requires human review before citation)
- `AI-ASSISTED` — Human-authored content with AI assistance (e.g., this proposal)

### 12.3 Reference Format

When citing source documents:

**For original source documents (authoritative):**
```
Source: sd7307900101.pdf (HVPS system schematic, hvps/documentation/schematics/)
Source: LLRFOperation_jims.docx (Jim Sebek, operational reference, Docs_JS/)
Source: rf_states.st (SNL state machine, spear-rf-code-legacy/rfApp/src/seq/)
```

**For AI-generated analysis (informational only):**
```
See also: HVPS_ARCHITECTURE_TN_01 (AI-generated analysis of slac-pub-7591.pdf, UNREVIEWED)
See also: Code Review TN 03 (AI-generated analysis of SNL state machines, UNREVIEWED)
```

### 12.4 Directory Structure Convention

Technical notes directories follow a consistent pattern that has evolved organically:

```
{subsystem}/
  ├── architecture/           # Design-level documents and original notes
  │   ├── designNotes/        # Human-authored original design notes (docx)
  │   ├── originalDocuments/  # Original PDFs from PEP-II era
  │   │   └── transcriptions/ # AI-generated transcriptions of originals
  │   └── technical-notes/    # AI-generated architecture-level analysis
  ├── controls/               # Control system documentation
  │   └── {component}/
  │       ├── {component}Documents/  # Original vendor PDFs
  │       └── technical-notes/       # AI-generated component analysis
  ├── documentation/          # Engineering documentation
  │   ├── {topic}/            # Original PDFs and drawings
  │   │   └── technical_notes/ # AI-generated schematic analysis
  │   └── procedures/         # Original safety and operational procedures
  └── maintenance/            # Maintenance records and checklists (original xlsx/docx)
```


---

## 13. Implementation Priorities and Action Items

### 13.1 Priority 1: CRITICAL (Time-Sensitive)

| Action | Deliverable | Dependencies | Rationale |
|--------|-------------|--------------|-----------|
| Begin Doc D data collection | `Designs/D_OPERATIONAL_DATA_CATALOG.md` | Access to running system | Operational data lost forever when legacy hardware removed |
| Capture EPICS archiver baselines | Data files + Doc D entries | Running SPEAR3 beam time | Must capture at 500 mA operating point |
| Record operational setpoints and alarm limits | Doc D appendix | Operator/engineer interviews | Institutional knowledge at risk |

### 13.2 Priority 2: HIGH (Required for Upgrade Progress)

| Action | Deliverable | Dependencies | Rationale |
|--------|-------------|--------------|-----------|
| Write Doc P | `Designs/P_RF_PHYSICS_AND_PLANT.md` | Original PDFs (§4.1, 4.2) | Foundation for all U-documents |
| Review Doc L v1.0 | `Designs/L_LEGACY_SYSTEM_ARCHITECTURE.md` (1,323 lines drafted) | Original PDFs, docx, code (§4) | Engineering review needed; populate 50+ photo placeholders |
| Write U3 (RF MPS) | `Designs/U3_RF_MPS_UPGRADE.md` | 33 MPS wiring diagrams, MPS requirements docx | Hardware assembled, software needed |
| Write U6 (Tuner Control) | `Designs/U6_TUNER_CONTROL_UPGRADE.md` | Galil docs, commissioning docx, test logs | Galil commissioned, needs formal document |
| Review safety-critical AI-generated TN | Updated §5 review status | Original source documents | MPS, PPS, crowbar content must be verified |

### 13.3 Priority 3: MEDIUM (Supports Quality and Navigation)

| Action | Deliverable | Dependencies | Rationale |
|--------|-------------|--------------|-----------|
| Write U7 (Waveform Buffer) | `Designs/U7_WAVEFORM_BUFFER_UPGRADE.md` | WaveformBuffersforLLRFUpgrade.docx | New custom hardware needs formal document |
| Write U8 (Arc Detection) | `Designs/U8_ARC_DETECTION_UPGRADE.md` | Arc detector product sheets, tups072.pdf | COTS hardware needs integration document |
| Create Master Index | `Designs/00_MASTER_INDEX.md` | Most other documents stable | Navigation layer |
| Reconcile Jim Sebek's index | Updated RfSystemDocumentIndexR3 | RfSystemDocumentIndexR3.xlsx | Verify completeness of repository |
| Resolve switchgear TN docx provenance | Updated §2.5 / §5.2 | File inspection | Clarify if docx files are human-authored or AI-generated |

### 13.4 Priority 4: LOWER (Ongoing Quality)

| Action | Deliverable | Dependencies | Rationale |
|--------|-------------|--------------|-----------|
| Systematic review of remaining AI-generated TN | Updated §5 review status | Engineer availability | Improve quality of reference material |
| Add Provenance headers to all AI-generated files | Updated file headers | — | Prevent future confusion about document authority |
| Consolidate Docs_JS/ duplicates | Cleanup or README | Verify identical copies | Reduce confusion about canonical locations |

---

## Appendix A — Subsystem × Tier Cross-Reference Matrix

This matrix shows where each subsystem's content lives across the four tiers. Cells marked with ★ indicate documents that need to be created.

| Subsystem | Tier 0 (Index) | Tier 1 (Physics) | Tier 2 (Legacy) | Tier 3 (Upgrade) |
|-----------|---------------|------------------|-----------------|------------------|
| Overall System | Master Index ★ | — | — | Doc 0 (exists) |
| RF Physics & Plant | — | Doc P ★ | — | — |
| LLRF Controller | — | Doc P §3–4 ★ | Doc L §5 (drafted) | U1 (in progress) |
| HVPS | — | Doc P §5 ★ | Doc L §9–12 (drafted) | U2 (in progress) |
| RF MPS | — | — | Doc L §14 (drafted) | U3 ★ |
| Interface Chassis | — | — | Doc L §5,15 (drafted) | U4 (in progress) |
| PPS Interface | — | — | Doc L §13 (drafted) | U5 (in progress) |
| Tuner Control | — | Doc P §7 ★ | Doc L §8,17 (drafted) | U6 ★ |
| Waveform Buffer | — | — | — | U7 ★ |
| Arc Detection | — | — | Doc L §12 (drafted) | U8 ★ |
| Klystron Heater | — | — | Doc L §6 (drafted) | U9 (in progress) |
| Control Software | — | — | Doc L §16–18 (drafted) | U10 (in progress) |
| Operational Data | — | — | Doc D ★ | — |


---

## Appendix B — Source Document Catalog

This appendix provides a comprehensive listing of all **original source documents** (not AI-generated) organized by file type. This replaces the previous Appendix B which incorrectly traced content from AI-generated documents.

### B.1 Engineering PDFs by Subsystem

**HVPS Schematics** (11 files):
`hvps/documentation/schematics/` — sd2372301200, sd2372301401, sd7307900101, sd7307900501, sd7307930304, sd7307930402, sd7307930702, sd7307930801, sd7307931203, sd7307931301, sd7307940400

**HVPS Wiring** (8 files):
`hvps/documentation/wiringDiagrams/` — ei7307900000, wd7307900103, wd7307900206, wd7307940200, wd7307940300, wd7307940400, wd7307940503, wd7307940600

**HVPS Switchgear** (6 files):
`hvps/documentation/switchgear/` — gp3085000103, gp4397040201, id3088010601, rossEngr713203, DOC041421, DB41-122m MCO

**HVPS PEP-II** (2 files + 1 pptx):
`hvps/architecture/originalDocuments/` — slac-pub-7591.pdf, ps3413600102.pdf, pepII supply.pptx

**HVPS Enerpro** (12 files):
`hvps/controls/enerpro/enerproDocuments/` — E640_F/K/L FCOG1200 schematics, E128_R, OP manuals, PD720, auto-balance, brochure, Bourbeau 1983, Closing the Loop

**HVPS PLC** (3 files):
`hvps/documentation/plc/` — CasselPLCCode, CasselSymbolDatabase, Cassel_land

**HVPS Stack Assemblies** (9 files):
`hvps/documentation/stackAssemblies/` — StackDriver1sd73079103, ad-series, pf-series

**HVPS Safety Procedures** (~8 signed PDFs):
`hvps/documentation/procedures/` — SR-444-636 series signed reviews and audit records, hazard analysis

**LLRF Legacy Architecture** (~15 files):
`llrf/documentation/legacyArchitecture/` — PS-340-330 series (block diagrams, descriptions, 9 procedures), 3 conference papers

**LLRF Local Panel** (13 files):
`llrf/documentation/localPanel/` — ad, dl, gp, ml, pc, pf, sd, si series

**LLRF Interface Modules** (3 files):
`llrf/documentation/legacyInterfaceModules/` — SD-340-308 series

**LLRF MPS Wiring** (33 files):
`llrf/documentation/mpsWiringDiagrams/` — wd3403300200 through wd3403303400

**LLRF Arc Detector** (3 files):
`llrf/arcDetector/` — product sheet, microStepMIS, tups072

**LLRF Tuner/Galil** (5 PDFs):
`llrf/tuners/` and `llrf/tuners/galil/` — dmc-4103-r13h-manual, ds_41x3, doc, SLO-SYN manuals, Old Stepper Catalog

**LLRF Other** (3 files):
Coax (sd3403300100), filament heater (sd3403110002), drive amp (KAW2051M12)

**LLRF Tests** (1 PDF + 1 LaTeX):
`llrf/tests/` — llrf9Tests.pdf, llrf9Tests.tex

**PPS** (6 files):
`pps/` — gp4397040201, rossEngr713203, sd7307900501, wd7307900103, wd7307900206, wd7307940600

### B.2 Human-Authored docx by Author/Topic

**Jim Sebek — Operational** (4 files):
`Docs_JS/LLRFOperation_jims.docx`, `Docs_JS/LLRFUpgradeTaskListRev3.docx`, `llrf/documentation/LLRFDocumentationNotesR2.docx`, `llrf/documentation/fiberOpticCableSignalControlRev3.docx`

**Jim Sebek — Design** (6 files):
`llrf/architecture/` — WaveformBuffersforLLRFUpgrade, llrfInterfaceChassis, arcDetectorHardwareOptions, analogDesignComponents, rfPowerDetector, llrfUpgradeTasks20221108

**HVPS Design Notes** (10 files):
`hvps/architecture/designNotes/` — Enerpro board notes, Hoffman Box PPS/power, MPS requirements, fiber optic connections, controller interfaces, testing notes, labels/PVs, task list Rev 0

**HVPS Controls Discussion** (5 files):
Enerpro (3): `hvps/controls/enerpro/` — board HVPS, discussion 07/2022, phase reference adapter
PLC (2): `hvps/documentation/plc/` — PLC software discussion, PLC notes R1

**HVPS Procedures** (~17 files):
`hvps/documentation/procedures/` — EWP documents, safety reviews (SR-444-636 series in docx), maintenance outlines, switch procedures

**HVPS Maintenance** (2 files):
`hvps/maintenance/` — stack installation checklist, phase tank maintenance

**Galil/Tuner** (2 files):
`llrf/tuners/galil/GalilCommissioning.docx`, `llrf/tuners/cavityTunerInspections20230613.docx`

**PPS** (1 file):
`pps/HoffmanBoxPPSWiring.docx`

**PDR Versions** (3 files):
`Designs/docx/SPEAR3_LLRF_PDR_R1.docx`, `Archived/0_SPEAR3_LLRF_PDR_V0.docx`, `Archived/0_SPEAR3_LLRF_PDR_V0_jjs.docx`

### B.3 Measurement Data (xlsx) — Complete Listing

| File | Location | Content |
|------|----------|---------|
| driveAmpCalibration.xlsx | llrf/calibrations/ | Drive amplifier calibration data |
| klystronCouplerDriveAmpCalibrations.xlsx | llrf/calibrations/ | Klystron coupler calibrations |
| pulsarCouplerCalibration2049.xlsx | llrf/calibrations/ | Pulsar coupler calibration |
| reflectedPowerCalibrations.xlsx | llrf/calibrations/ | Reflected power calibrations |
| tuneModeDacCalibration.xlsx | llrf/calibrations/ | Tune mode DAC calibration |
| b132R11PatchPanel.xlsx | llrf/calibrations/ | B132 R11 patch panel mapping |
| LocalPanelToXConnectMapping.xlsx | llrf/documentation/ | Local panel to cross-connect mapping |
| RfSystemDocumentIndexR3.xlsx | llrf/documentation/ | Jim Sebek's master document index |
| hvpsMeasurements20220314.xlsx | hvps/documentation/plc/ | PLC measurement data |
| hvpsPlcLabels.xlsx | hvps/documentation/plc/ | PLC label database |
| hvpsMonitorConnections.xlsx | hvps/documentation/wiringDiagrams/ | HVPS monitor connections |
| HVPSReliability.xlsx | hvps/maintenance/ | HVPS failure and reliability records |
| Spear1Tests20220817.xlsx | hvps/maintenance/ | SPEAR1 HVPS test data |
| Spear2Tests2021.xlsx | hvps/maintenance/ | SPEAR2 HVPS test data |
| phaseTankScrs.xlsx | hvps/maintenance/ | Phase tank thyristor records |
| Spear3HVPSComplexLockoutPermit.xlsx | hvps/documentation/procedures/ | SPEAR3 lockout permit |
| Spear3Spear1HVPSComplexLockoutPermit.xlsx | hvps/documentation/procedures/ | SPEAR3/SPEAR1 lockout permit |
| Spear3Spear2HVPSComplexLockoutPermit.xlsx | hvps/documentation/procedures/ | SPEAR3/SPEAR2 lockout permit |

### B.4 Source Code

`spear-rf-code-legacy/` — 2,293 files. See §4.4 for directory breakdown.

### B.5 Other Original Files

| Type | Files | Location |
|------|-------|----------|
| Visio | PRD_drawings.vsdx, mainTankLiftPlan.vsdx | Designs/docx/drawings/, hvps/documentation/hoistingRigging/ |
| LaTeX | llrf9Tests.tex, spear3HvpsHazards.tex | llrf/tests/, hvps/documentation/procedures/ |
| Firmware | dmc-4103-r13k.hex, dmc-4103-r13k-ser.hex | llrf/tuners/galil/ |
| Text logs | firstMotion2024.txt, functioningGalil20250825SwapABToManual.txt, readme.txt | llrf/tuners/galil/ |
| Mechanical drawings | 10 PNG transformer/assembly drawings | hvps/documentation/mechanical/ |
| Simulation code | hvps_sim/ (Python), pyspice_sim/ (PySpice) | hvps/simulation/ |


---

## Appendix C — AI-Generated Analysis Review Checklist

This appendix provides a systematic review checklist for all AI-generated markdown files. When an engineer completes a review, they should update the **Reviewer** and **Date** columns and note any significant corrections.

### C.1 Safety-Critical Content (Review First)

| File | Subsystem | Original Source | Reviewer | Date | Notes |
|------|-----------|----------------|----------|------|-------|
| PPS diagrams 00–08 | PPS | PPS schematic PDFs | — | — | Safety-critical: PPS compliance |
| MPS-related TN (if any) | LLRF | 33 MPS wiring diagrams | — | — | Safety-critical: machine protection |
| Crowbar/protection schematics TN | HVPS | sd7307931203, sd7307931301 | — | — | Safety-critical: equipment protection |
| PLC TN 01–09 | HVPS | PLC code and symbol database | — | — | Safety-related: interlocks |

### C.2 Architecture and System-Level Content

| File | Subsystem | Original Source | Reviewer | Date | Notes |
|------|-----------|----------------|----------|------|-------|
| HVPS_ARCHITECTURE_TN_00–06 | HVPS | PEP-II docs, design notes | — | — | |
| LLRF_TN_00–05 | LLRF | Legacy architecture PDFs | — | — | |
| Code Review TN 00–08 | Code | 2,293 source files | — | — | |

### C.3 Component-Level Content

| File | Subsystem | Original Source | Reviewer | Date | Notes |
|------|-----------|----------------|----------|------|-------|
| ENERPRO_TN_00–08 | HVPS | Enerpro PDFs and docx | — | — | |
| Schematics TN (14 files) | HVPS | Individual schematic PDFs | — | — | |
| Switchgear TN (5 files) | HVPS | Switchgear PDFs | — | — | |
| Phase tank wiring TN | HVPS | Wiring diagram PDFs | — | — | |
| FILAMENT_HEATER_TECHNICAL_NOTES | LLRF | sd3403110002.pdf | — | — | |

### C.4 Transcriptions

| File | Subsystem | Original Source | Reviewer | Date | Notes |
|------|-----------|----------------|----------|------|-------|
| pepII_supply_transcription | HVPS | pepII supply.pptx | — | — | |
| ps3413600102_transcription | HVPS | ps3413600102.pdf | — | — | |
| slac-pub-7591_transcription | HVPS | slac-pub-7591.pdf | — | — | |
| Legacy PDF transcriptions (~17) | LLRF | PS-340-330 series PDFs | — | — | |

### C.5 Obsolete Design Documents

| File | Maps To | Reviewer | Date | Notes |
|------|---------|----------|------|-------|
| Doc A (Legacy LLRF) | Doc P + Doc L | — | — | |
| Doc B (Current LLRF) | Doc P + Doc L | — | — | |
| Doc 3 (LLRF9 System) | U1 | — | — | |
| Doc 4 (HVPS Engineering) | U2 + Doc L + Doc P | — | — | |
| Doc 5 (Klystron Heater) | U9 | — | — | |
| Doc 8 (HVPS PPS Interface) | U5 | — | — | |
| Doc 10 (Software Design) | U10 | — | — | |
| Doc 11 (Interface Chassis) | U4 | — | — | |

---

*End of Document*

**Document Control**:
- This document should be reviewed and updated whenever new documentation is created or existing documents are substantially revised.
- The definitive version is `Designs/DOCUMENTATION_ARCHITECTURE_PROPOSAL.md` in the `spearlegacyLLRF` repository.
- **Provenance**: AI-ASSISTED — structure and content proposed by AI, based on exhaustive repository review, subject to human review and approval.


---

## Appendix D — Doc L Section ↔ Original Source Document Cross-Reference

This appendix maps each Doc L section to its primary original source documents, enabling efficient verification during engineering review.

| Doc L Section | Part | Primary Original Sources | AI Technical Notes Consulted |
|---------------|------|-------------------------|------------------------------|
| §1 Introduction | I | McIntosh SLAC-PUB-11017; Corredoura SLAC-PUB-8498 | `llrf/documentation/legacyArchitecture/technical-notes/00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` |
| §2 Architecture | I | `sd7307900101.pdf`, `bd3403300000.pdf`, `bd3403300100.pdf`, Doc 0 §2.1 | `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md` |
| §3 Physical Layout | I | Doc 0 §3, `pps/HoffmanBoxPPSWiring.docx`, `wd7307900103.pdf` | `pps/diagrams/00_SYSTEM_OVERVIEW.md` |
| §4 Parameters | I | `llrf9Tests.pdf`, `hvpsMeasurements20220314.xlsx`, Doc 0 §1 | `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md` §Validation |
| §5 LLRF VXI | II | `ps3403305100.pdf` (11 pages), `bd3403300000.pdf`, SLAC-PUB-8498, all `rf_*.st` + `rf_*_pvs.h` | `llrf/*/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md`, `02_VXI_HARDWARE_MODULE_REFERENCE.md` |
| §6 Klystron | II | `spear3HvpsHazards.tex`, `KAW2051M12.pdf`, `rf_hvps_loop.st`, Doc 0 §4.1/§4.5 | — |
| §7 Waveguide | II | Doc 0 §4.2/§4.6, `sd3403300100.pdf` | — |
| §8 Cavities/Tuners | II | `SLO-SYN*.pdf` (3 manuals), `galil/dmc-4103-r13h-manual.pdf`, `galil/ds_41x3.pdf`, `cavityTunerInspections20230613.docx`, `GalilCommissioning.docx`, `functioningGalil20250825SwapABToManual.txt` | `spear-rf-code-legacy/codeReviewTechnicalNotes/08-signal-processing.md` |
| §9 HVPS Power | III | 11 schematic PDFs (`sd7307900101–sd7307940400`), `slac-pub-7591.pdf`, `ps3413600102.pdf` | `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md`, `hvps/documentation/schematics/technical_notes/` (14 files) |
| §10 HVPS Control | III | `CasselPLCCode.pdf`, `CasselSymbolDatabase.pdf`, `plcNotesR1.docx`, `sd2372301401.pdf`, `wd7307900206.pdf`, `pps/HoffmanBoxPPSWiring.docx`, `hvpsPlcLabels.xlsx` | `hvps/documentation/plc/technical-notes/01-system-overview.md` through `09-binary-bit-registers.md` |
| §11 Enerpro | III | `hvps/controls/enerpro/enerproDocuments/` (12 PDFs), `enerproBoardHvps.docx`, `enerproDiscussion07072022.docx`, `enerproPhaseReferenceAdapter.docx` | `hvps/controls/enerpro/technical-notes/00-system-overview.md` through `08-troubleshooting-reference.md` |
| §12 Arc Protection | III | `slac-pub-7591.pdf`, `sd7307931203.pdf`, `sd7307931301.pdf` | `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md` §Arc Protection |
| §13 PPS | IV | `pps/HoffmanBoxPPSWiring.docx` (80¶, 5 tables), `gp4397040201.pdf`, `rossEngr713203.pdf`, `sd7307900501.pdf`, `wd7307900103.pdf`, `wd7307900206.pdf`, `wd7307940600.pdf` | `pps/diagrams/00_PPS_System_Overview.md` through `08_CORRECTED_HAND_DRAWING.md` |
| §14 RF MPS | IV | `llrf/documentation/mpsWiringDiagrams/` (33 PDFs), `RFSystemMPSRequirements.docx`, Doc 0 §7 | `spear-rf-code-legacy/codeReviewTechnicalNotes/06-plc-stepper-motors.md` |
| §15 Interlocks | IV | Doc 0 §17, `rf_states.st`, Fast Interlock Chassis schematics | — |
| §16 EPICS/SNL | V | `spear-rf-code-legacy/rfApp/src/seq/` (6 .st + 12 .h files), `LLRFOperation_jims.docx` | `spear-rf-code-legacy/codeReviewTechnicalNotes/03_SNL_STATE_MACHINES.md`, `05-snl-state-machines.md` |
| §17 Tuner Control | V | `galil/functioningGalil20250825SwapABToManual.txt`, `galil/firstMotion2024.txt`, `GalilCommissioning.docx`, Doc 0 §10 | `spear-rf-code-legacy/codeReviewTechnicalNotes/08-tuner-and-stepper.md` |
| §18 Diagnostics | V | `rf_calib.st`, `llrf/calibrations/` (6 xlsx), `llrf9Tests.pdf` | — |
| §19 Cabling | VI | `wd7307900103.pdf`, `wd7307900206.pdf`, `wd7307940600.pdf`, Doc 0 §3 | — |
| §20 Known Issues | VI | All sources; `pps/MSG from Jim Sebek to Faya about PPS.md` | All technical notes series |
| §21 Source Index | VI | Repository scan + `llrf/documentation/RfSystemDocumentIndexR3.xlsx` | — |

### D.1 Key Discoveries from Deep Codebase Review

During the exhaustive review that informed Doc L v1.0, several important details were confirmed or corrected:

1. **Enerpro board identification**: FCOG6100 Rev.K (serial numbers 41506, 50470, 30045), with FCOAUX60 Rev D auxiliaries (S/N: 03198, 03813, 1694) — confirmed from `hvps/controls/enerpro/` directory structure and documentation
2. **Galil DMC-4143 Rev 1.3h**: Confirmed commissioned August 2025 from `functioningGalil20250825SwapABToManual.txt` timestamp — this replaces legacy AB 1746-HSTP1 controllers
3. **SNL program complexity**: `rf_states.st` has **23 states across 3 concurrent state sets** (not the 18–20 commonly cited) — confirmed from direct source code reading
4. **SNL line counts**: rf_states.st=2,227; rf_calib.st=3,345 (largest!); rf_tuner_loop.st=555; rf_hvps_loop.st=343; rf_dac_loop.st=290; rf_msgs.st=352; 12 headers=~1,151 — all confirmed from source
5. **VXI slots 6–8**: Contain PEP-II modules (Comb Filter I, Comb Filter Q, GVF) that are **present but NOT used in SPEAR3** — important for upgrade planning
6. **PPS compliance**: Both PPS chains confirmed to route through SLC-500 PLC ladder logic (Rungs 0016 and 0017) — critical safety finding from `CasselPLCCode.pdf` + `HoffmanBoxPPSWiring.docx`
7. **K4/RR relay label swap**: Original wiring diagrams have K4 and RR labels swapped — corrected in Doc L and PPS technical notes, but field verification recommended
