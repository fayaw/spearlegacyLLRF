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

| # | Filename | Type | Pages | File Size | Verified Content (OCR-confirmed) | Priority |
|---|----------|------|-------|-----------|----------------------------------|----------|
| 1 | `bd3403300000.pdf` | Block Diagram | 1 | 105 KB | **PEP-II LER RF Station block diagram** — top-level station architecture showing HVPS, klystron, circulator, waveguide, LLRF, interlocks | ★★★ |
| 2 | `bd3403300100.pdf` | Block Diagram | 1 | 90 KB | **PEP-II Low Level RF Configuration (LER)** — VXI module interconnection, signal levels (+30 dBm max klystron, +16/+3 dBm drive chain), IQ routing | ★★★ |
| 3 | `blockDiagrambd3403290100-1.pdf` | Block Diagram | 1 | 100 KB | **PEP-II Low Level RF block diagram** — additional LLRF block diagram (note: drawing group 3290 vs 3300), shows RF modulator, amplifier chain, system I/Q, longitudinal feedback interface | ★★☆ |
| 4 | `feedbackLoopDescriptionps3403305200.pdf` | Process Spec | 8 | 812 KB | **LLRF Feedback Loop Description (PS-340-330-52-R0)** — CRITICAL document describing all feedback loops: Direct, Comb, Tuner, HVPS, DAC, Ripple, Gap FF, LFB Woofer, Optimized Station Phasing. Includes block diagrams. Reconstructed in `01_FEEDBACK_LOOP_ARCHITECTURE.md` | ★★★ |
| 5 | `ps3403305100.pdf` | Process Spec | 11 | 597 KB | **PEP-II RF System Description (PS-340-330-51-R0)** — comprehensive system overview: HER (5 stations, 4 cav/station) and LER (2 stations, 2 cav/station) layouts, nominal parameter table (shunt impedance, Q values, beam loading), station cross-section drawings, plan views of Regions 4/8/12 | ★★★ |
| 6 | `ps3403305200.pdf` | Process Spec | 8 | 813 KB | **LLRF Feedback Loop Description (PS-340-330-52-R0)** — identical content to #4 (duplicate copy) | ★★★ |
| 7 | `ps3403305300.pdf` | Oper. Procedure | 4 | 184 KB | **RF Cavity Low Power Calibration Procedure (PS-340-330-53-R0)** — cold cavity measurement: sampling loop installation, network analyzer setup, coupling measurement (nominal 99.6 dB), resonance curve fitting | ★★☆ |
| 8 | `ps3403305400.pdf` | Oper. Procedure | 2 | 114 KB | **RF Station Safety Certification Check-Off List (PS-340-330-54-R0)** — waveguide flange torque test (>25 ft-lbs), interlock test, RF non-ionizing radiation survey checklist | ★☆☆ |
| 9 | `ps3403305503.pdf` | Oper. Procedure | 4 | 220 KB | **RF Station Safety Survey (PS-340-330-55-R3)** — Rev 3 safety survey form for RF station klystron department/engineering sign-offs | ★☆☆ |
| 10 | `ps3403305600.pdf` | Oper. Procedure | 4 | 343 KB | **RF Station Coupling & Cable Calibration Procedure (PS-340-330-56-R0)** — detailed cable loss measurement procedure at 476 MHz: cavity probe coupling (nominal 99.6 dB), forward/reflected coupler values (60.0 dB), IQ module channel conversion loss (13.15 dB), Heliax cable losses, complete J-number mapping for all 4 cavities + circulator + magic tees + klystron drive | ★★☆ |
| 11 | `ps3403305700.pdf` | Oper. Procedure | 2 | 126 KB | **RF Station Full Power Test & Survey (PS-340-330-57-R0)** — full-power klystron test with waveguide SHORT plate installed (power into circulator load), non-ionizing radiation survey at full power | ★☆☆ |
| 12 | `ps3403305800.pdf` | Oper. Procedure | 4 | 209 KB | **RF Station Cavity Phasing Procedure (PS-340-330-58-R0)** — cavity-to-beam phase optimization for 4 (HER) or 2 (LER) cavities per station, wavelength spacing data, phase relationship tables (0°, −90°, +180°, +90° / −270°) | ★★☆ |
| 13 | `ps3403305900.pdf` | Oper. Procedure | 7 | 1179 KB | **RF Station Turn-On Procedure (PS-340-330-59-R0)** — complete startup sequence: filament/solenoid pre-conditions, HVPS contactor close, ON_CW mode with auto loop engagement (Ripple→Direct→Comb), PARK mode, cavity processing (ON_FM at 1000 Hz then ON_CW), EPICS panel screenshots (Klystron, RF Station, HVPS, Feedback panels) | ★★★ |
| 14 | `ps3403306001.pdf` | Oper. Procedure | 5 | 301 KB | **Bellow Cavity Phasing Procedure (PS-340-330-60-R1)** — Rev 1 procedure for fine-tuning cavity phase after initial installation, adjusts for gap voltage balance changes | ★★☆ |
| 15 | `ps3403306102.pdf` | Oper. Procedure | 13 | 947 KB | **RF Non-Ionizing Radiation Safety Procedure (PS-340-330-61-R2)** — Rev 2 comprehensive NIR safety: waveguide network pressurization (0.25 psig), flange torque (30 ft-lbs), RF survey at 100 kW (<0.1 mW/cm²), klystron removal lockout, annual re-certification, Waveguide Safety Work Control Form | ★★☆ |

### 2.1a Transcription Status (v2.2 Update)

**All 15 legacy PDFs have been transcribed to searchable markdown** and are available in `legacy-pdf-transcriptions/`. Transcriptions include:

| Category | Count | Transcription Directory |
|----------|-------|------------------------|
| Design Specifications | 2 | `legacy-pdf-transcriptions/design-specifications/` |
| Operational Procedures | 9 | `legacy-pdf-transcriptions/operational-procedures/` |
| Block Diagrams | 3 | `legacy-pdf-transcriptions/block-diagrams/` |
| Duplicate (not transcribed) | 1 | `ps3403305200.pdf` = identical to `feedbackLoopDescriptionps3403305200.pdf` |

**Key transcription files for cross-referencing**:
- `PS-340-330-51_RF_System_Description.md` — Complete parameter tables, station layouts, cooling systems
- `PS-340-330-52_LLRF_Feedback_Loop_Description.md` — All feedback loop descriptions with block diagrams
- `BD-340-330-00_PEP-II_LER_RF_Station_Block_Diagram.md` — Complete station block diagram with PLC I/O counts
- `BD-340-330-01_PEP-II_Low_Level_RF_Configuration.md` — LLRF signal processing chain with signal levels
- `PS-340-330-59_RF_Station_Turn_On_Procedure.md` — EPICS panel reconstructions, startup sequence, processing limits

OCR quality: v2 extraction at 450 DPI with multi-pass strategy. See `legacy-pdf-transcriptions/README.md` for detailed quality assessment per content type.

### 2.2 Document Characteristics

- **All PDFs are image-based** (scanned engineering drawings/typewritten documents)
- **No extractable text** — OCR required for full digitization
- **Total pages**: 75 pages across 15 documents
- **Total size**: ~6.0 MB
- **Drawing date**: Estimated 1996-2005 based on source code dates and PEP-II timeline

### 2.3 Digitization Priority

> **✅ Digitization complete**: All 15 PDFs have been OCR-transcribed (v2, 450 DPI). The priority ranking below is retained for historical reference but all documents are now searchable in markdown format.

**Tier 1 (Critical — design specifications and core reference)**:
1. `feedbackLoopDescriptionps3403305200.pdf` — Core control theory, all loops described (8 pp)
2. `ps3403305100.pdf` — Main RF system description with parameter tables (11 pp)
3. `bd3403300000.pdf` — Top-level RF station block diagram (1 pp)
4. `bd3403300100.pdf` — LLRF module interconnection diagram (1 pp)

**Tier 2 (Important — operational procedures with engineering data)**:
5. `ps3403305900.pdf` — Turn-on procedure with EPICS panel screenshots and loop engagement sequence (7 pp)
6. `ps3403305600.pdf` — Coupling & cable calibration with quantitative loss data (4 pp)
7. `ps3403305800.pdf` — Cavity phasing with wavelength/phase tables (4 pp)
8. `ps3403305300.pdf` — Cavity low power calibration procedure (4 pp)
9. `ps3403306001.pdf` — Bellow cavity phasing (5 pp)

**Tier 3 (Reference — safety and administrative)**:
10. `ps3403306102.pdf` — Non-ionizing radiation safety procedure with waveguide specs (13 pp)
11. `ps3403305503.pdf` — Safety survey form (4 pp)
12. `ps3403305700.pdf` — Full power test & survey (2 pp)
13. `ps3403305400.pdf` — Safety certification checklist (2 pp)
14. `blockDiagrambd3403290100-1.pdf` — Additional LLRF block diagram (1 pp)

> **⚠️ Note**: Documents PS-340-330-53 through PS-340-330-61 are **operational procedures**, not module-level design specifications. The LLRF loop design details (DAC loop, HVPS loop, comb filter, ripple loop, etc.) are described in PS-340-330-52-R0 (`feedbackLoopDescriptionps3403305200.pdf`) and in published papers by Corredoura et al. No standalone module specification documents for individual loops were found in this legacy archive.

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

33 wiring diagram PDFs: `wd3403300200.pdf` through `wd3403303400.pdf`
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
| RF system description | `ps3403305100.pdf` | Corredoura SLAC-PUB-8498 | — |
| Direct loop (design) | `feedbackLoopDescriptionps3403305200.pdf` (pp. 3-4) | Corredoura 1999; Fox 2010 §II | `rf_states.st` |
| Comb loop (design) | `feedbackLoopDescriptionps3403305200.pdf` (p. 5) | Corredoura 1999; Fox 2010 §III | `rf_calib.st` |
| Tuner loop (design) | `feedbackLoopDescriptionps3403305200.pdf` (p. 5) | Corredoura 1999 | `rf_tuner_loop.st` |
| HVPS loop (design) | `feedbackLoopDescriptionps3403305200.pdf` (p. 6) | — | `rf_hvps_loop.st` |
| DAC loop (design) | `feedbackLoopDescriptionps3403305200.pdf` (p. 6) | — | `rf_dac_loop.st` |
| Ripple loop (design) | `feedbackLoopDescriptionps3403305200.pdf` (p. 6) | Corredoura 2000 §6 | `rf_dac_loop.st` |
| Gap FF / LFB Woofer (design) | `feedbackLoopDescriptionps3403305200.pdf` (pp. 6-7) | Corredoura SLAC-PUB-8498 | `rf_msgs.st` (TAXI recovery) |
| Drive chain / modulator | — (no standalone spec in archive) | Corredoura 2000, Figs. 4-6 | — |
| Lead/integral comp | — (no standalone spec in archive) | — | `rf_states.st` (INTCOMP, LEADCOMP) |
| Cavity low power calibration | `ps3403305300.pdf` | — | `rf_calib.st` |
| Cable/coupling calibration | `ps3403305600.pdf` | — | — |
| Cavity phasing | `ps3403305800.pdf` | — | — |
| Station turn-on | `ps3403305900.pdf` | — | `rf_states.st` |
| Bellow cavity phasing | `ps3403306001.pdf` | — | — |
| NIR safety | `ps3403306102.pdf` | — | — |

---

*See also: `00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` for system overview.*
*See also: `05_CROSS_REFERENCE_INDEX.md` for complete topic mapping.*
