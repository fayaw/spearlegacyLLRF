# Legacy PDF Archive Catalog — PEP-II LLRF Engineering Drawings

**Document Number**: LLRF-REF-004
**Version**: 1.0
**Date**: 2026-03-18

---

## 1. SLAC Drawing Number System

SLAC uses a structured drawing numbering system. The format is: `[Type][Group][Drawing][Sheet][Revision]`

**Type Prefixes**:
| Prefix | Document Type |
|--------|--------------|
| `bd` | Block Diagram |
| `ps` | Process Specification / Technical Note |
| `sd` | Schematic Drawing |
| `wd` | Wiring Diagram |
| `ad` | Assembly Drawing |
| `pf` | Panel Front drawing |
| `dl` | Detail List |
| `gp` | General Specification |
| `ml` | Material List |
| `si` | Signal Interface |
| `pc` | Printed Circuit |

The group `3403` corresponds to the PEP-II RF/LLRF system documentation.

---

## 2. Legacy Architecture PDFs (`legacyArchitecture/`)

### 2.1 Complete Inventory

| # | Filename | Type | Pages | File Size | Inferred Content | Priority |
|---|----------|------|-------|-----------|-----------------|----------|
| 1 | `bd3403300000.pdf` | Block Diagram | 1 | 108 KB | **Top-level LLRF system block diagram** — overall RF station architecture | ★★★ |
| 2 | `bd3403300100.pdf` | Block Diagram | 1 | 92 KB | **Subsystem block diagram** — VXI module interconnection or signal routing | ★★★ |
| 3 | `blockDiagrambd3403290100-1.pdf` | Block Diagram | 1 | 103 KB | **Additional block diagram** — possibly RF power chain or cavity layout (note: drawing group 3290 vs 3300) | ★★☆ |
| 4 | `feedbackLoopDescriptionps3403305200.pdf` | Process Spec | 8 | 832 KB | **Feedback loop description** — detailed explanation of all feedback loops (CRITICAL document, reconstructed in `01_FEEDBACK_LOOP_ARCHITECTURE.md`) | ★★★ |
| 5 | `ps3403305100.pdf` | Process Spec | 11 | 612 KB | **Main LLRF system specification** — RFP module details, signal processing architecture, IQ baseband scheme | ★★★ |
| 6 | `ps3403305200.pdf` | Process Spec | 8 | 833 KB | **Feedback loop description** (likely same as #4 or different revision) | ★★★ |
| 7 | `ps3403305300.pdf` | Process Spec | 4 | 189 KB | **DAC loop specification** — drive power / gap voltage DAC control loop | ★★☆ |
| 8 | `ps3403305400.pdf` | Process Spec | 2 | 117 KB | **HVPS loop specification** — klystron voltage regulation loop | ★★☆ |
| 9 | `ps3403305503.pdf` | Process Spec | 4 | 226 KB | **Drive chain specification** — baseband modulator, gain stage, limiting circuits (Rev 03) | ★★★ |
| 10 | `ps3403305600.pdf` | Process Spec | 4 | 352 KB | **Comb filter module specification** — digital comb loop implementation | ★★☆ |
| 11 | `ps3403305700.pdf` | Process Spec | 2 | 130 KB | **Lead/integral compensation specification** — analog compensation networks | ★★☆ |
| 12 | `ps3403305800.pdf` | Process Spec | 4 | 215 KB | **Ripple loop specification** — HVPS ripple cancellation | ★★☆ |
| 13 | `ps3403305900.pdf` | Process Spec | 7 | 1208 KB | **GVF module specification** — gap voltage feed-forward, LFB woofer, fiber optic interface (largest PS doc) | ★★★ |
| 14 | `ps3403306001.pdf` | Process Spec | 5 | 309 KB | **Tuner loop specification** — cavity mechanical tuner control (Rev 01) | ★★☆ |
| 15 | `ps3403306102.pdf` | Process Spec | 13 | 970 KB | **System test/commissioning procedure** — calibration steps, loop configuration, acceptance criteria (Rev 02, longest PS doc) | ★★★ |

### 2.2 Document Characteristics

- **All PDFs are image-based** (scanned engineering drawings/typewritten documents)
- **No extractable text** — OCR required for full digitization
- **Total pages**: 75 pages across 15 documents
- **Total size**: ~6.3 MB
- **Drawing date**: Estimated 1996-2005 based on source code dates and PEP-II timeline

### 2.3 Digitization Priority

**Tier 1 (Critical — digitize first)**:
1. `feedbackLoopDescriptionps3403305200.pdf` — Core control theory (8 pp)
2. `ps3403305100.pdf` — Main system spec (11 pp)
3. `bd3403300000.pdf` — Top-level block diagram (1 pp)
4. `ps3403306102.pdf` — System test procedure (13 pp)
5. `ps3403305503.pdf` — Drive chain details (4 pp)

**Tier 2 (Important — digitize second)**:
6. `ps3403305900.pdf` — GVF module spec (7 pp)
7. `bd3403300100.pdf` — Subsystem diagram (1 pp)
8. `ps3403305600.pdf` — Comb filter spec (4 pp)
9. `ps3403306001.pdf` — Tuner loop spec (5 pp)

**Tier 3 (Reference — digitize as needed)**:
10-15. Remaining specifications (DAC loop, HVPS loop, ripple loop, lead comp, additional block diagram)

---

## 3. Related PDFs in Other Directories

### 3.1 Legacy Interface Modules (`legacyInterfaceModules/`)

| Filename | Pages | Content |
|----------|-------|---------|
| `SD-340-308-01-R1-1of1.pdf` | — | Interface module schematic sheet 1 |
| `SD-340-308-02-R1.pdf` | — | Interface module schematic sheet 2 |
| `sd3403090102.pdf` | — | Interface module pinout/connector |

### 3.2 Coax Cables (`coaxCables/`)

| Filename | Content |
|----------|---------|
| `sd3403300100.pdf` | Coaxial cable routing/connection drawing |

### 3.3 Local Panel (`localPanel/`)

| Filename | Type | Content |
|----------|------|---------|
| `ad3403100000.pdf` | Assembly | Local control panel assembly |
| `ad3403100500.pdf` | Assembly | Panel subassembly |
| `dl3403100000.pdf` | Detail List | Panel component list |
| `gp3403100100.pdf` | General Spec | Panel general specification |
| `ml3403100000.pdf` | Material List | Panel materials |
| `pc3403100100.pdf` | PC Board | Panel printed circuit board |
| `pf3403100100.pdf` | Panel Front | Panel front layout (sheet 1) |
| `pf3403100200.pdf` | Panel Front | Panel front layout (sheet 2) |
| `pf3403100502.pdf` | Panel Front | Panel front layout (Rev 02) |
| `sd3403110100.pdf` | Schematic | Panel schematic |
| `si3403100100.pdf` | Signal Interface | Panel signal interface (sheet 1) |
| `si3403100200.pdf` | Signal Interface | Panel signal interface (sheet 2) |
| `si3403100501.pdf` | Signal Interface | Panel signal interface (Rev 01) |

### 3.4 MPS Wiring Diagrams (`mpsWiringDiagrams/`)

35 wiring diagram PDFs: `wd3403300200.pdf` through `wd3403303400.pdf`
These document the Machine Protection System wiring for the RF station.

### 3.5 Filament Heater (`filamentHeater/`)

| Filename | Content |
|----------|---------|
| `sd3403110002.pdf` | Filament heater circuit schematic |
| `FILAMENT_HEATER_TECHNICAL_NOTES.md` | Technical notes (already digitized!) |

---

## 4. Cross-Reference: PDFs ↔ Published Papers ↔ Source Code

| Topic | Primary PDF | Published Reference | Source Code |
|-------|------------|--------------------|----|
| System block diagram | `bd3403300000.pdf` | Corredoura SLAC-PUB-8498, Fig. 1 | — |
| Feedback loop architecture | `feedbackLoopDescriptionps3403305200.pdf` | Corredoura SLAC-PUB-8498, Fig. 3 | All `.st` files |
| RFP module specification | `ps3403305100.pdf` | Corredoura SLAC-PUB-8498 | `rf_calib.st` (p2RfRfpDef.h) |
| Drive chain / modulator | `ps3403305503.pdf` | Corredoura 2000, Figs. 4-6 | — |
| DAC loop | `ps3403305300.pdf` | — | `rf_dac_loop.st` |
| HVPS loop | `ps3403305400.pdf` | — | `rf_hvps_loop.st` |
| Comb filter | `ps3403305600.pdf` | — | `rf_calib.st` (comb sections) |
| Lead/integral comp | `ps3403305700.pdf` | — | `rf_states.st` (INTCOMP, LEADCOMP) |
| Ripple loop | `ps3403305800.pdf` | — | `rf_dac_loop.st` (ripple sections) |
| GVF module | `ps3403305900.pdf` | Corredoura SLAC-PUB-8498 (woofer) | `rf_msgs.st` (TAXI recovery) |
| Tuner loop | `ps3403306001.pdf` | — | `rf_tuner_loop.st` |
| System commissioning | `ps3403306102.pdf` | — | `rf_calib.st`, `rf_states.st` |

---

*See also: `00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` for system overview.*
*See also: `05_CROSS_REFERENCE_INDEX.md` for complete topic mapping.*
