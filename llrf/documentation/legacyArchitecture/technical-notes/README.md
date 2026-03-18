# PEP-II / SPEAR3 LLRF Technical Notes

**AI-Ready Documentation Package for the PEP-II Low-Level RF System**
**As Adapted for the SPEAR3 Storage Ring at SSRL/SLAC**

---

## Overview

This directory contains a comprehensive technical documentation package reconstructing the PEP-II LLRF system architecture. The legacy design documents are image-based PDFs (scanned engineering drawings) that cannot be directly text-searched. This package provides AI-ingestible technical notes that reconstruct, synthesize, and cross-reference the legacy knowledge.

## Document Index

| # | File | Title | Scope |
|---|------|-------|-------|
| 00 | `00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` | **System Reference** | System context, architecture overview, operating parameters, RF theory |
| 01 | `01_FEEDBACK_LOOP_ARCHITECTURE.md` | **Feedback Loops** | Detailed reconstruction of all 7 feedback/control loops |
| 02 | `02_VXI_HARDWARE_MODULE_REFERENCE.md` | **Hardware Modules** | VXI crate module inventory, specifications, interconnections |
| 03 | `03_LEGACY_PDF_CATALOG.md` | **PDF Catalog** | Complete inventory of 15+ legacy PDFs with content mapping |
| 04 | `04_LITERATURE_SYNTHESIS.md` | **Literature Synthesis** | Key findings from published papers and operational insights |
| 05 | `05_CROSS_REFERENCE_INDEX.md` | **Cross-Reference Index** | Topic → source mapping matrix (AI-ready retrieval) |

## Companion Documents

| Document | Location | Scope |
|----------|----------|-------|
| Legacy Control System Technical Design | `Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` | Source code analysis (SNL programs, state machines, PVs) |
| LLRF9 System & Software Report | `Designs/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` | Replacement digital LLRF system |
| Project Path | `ProjectPath/ProjectPath.md` | Upgrade timeline and milestones |

## Source Material

### Legacy PDFs (15 files, image-based)
Located in: `llrf/documentation/legacyArchitecture/`
Total: 75 pages, ~6.0 MB

### Legacy Source Code (6 SNL programs + 11 header files)
Located in: `llrf/legacyLLRF/`
Total: 7,112 lines of SNL code (.st files) + 1,111 lines in supporting headers (.h files) = 8,223 lines

### Published Literature (10 key papers)
See `05_CROSS_REFERENCE_INDEX.md` §3 for full citations.

## Key Entry Points

- **Understanding the system**: Start with `00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md`
- **Feedback loop details**: See `01_FEEDBACK_LOOP_ARCHITECTURE.md`
- **Finding specific topics**: Use `05_CROSS_REFERENCE_INDEX.md` as the search index
- **PDF digitization planning**: See `03_LEGACY_PDF_CATALOG.md` §2.3 for priority ranking

---

*Generated: 2026-03-18 | Version 1.0*
