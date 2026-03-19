# Legacy PDF Transcriptions — PEP-II RF System Archive

This directory contains faithful markdown transcriptions of all **15 original legacy PDF documents** from the PEP-II RF system archive. These transcriptions were generated via OCR extraction (Tesseract 5.3.0 at 300 DPI with PyMuPDF) to provide searchable, version-controlled access to the complete legacy documentation.

---

## Document Index

### Design Specifications (2 documents)

| # | Document | PDF | Pages | Description |
|---|----------|-----|:-----:|-------------|
| 1 | [PS-340-330-51](design-specifications/PS-340-330-51_RF_System_Description.md) | `ps3403305100.pdf` | 11 | RF System Description — comprehensive overview of HER (5 stations) and LER (2 stations) RF systems, nominal parameter tables |
| 2 | [PS-340-330-52](design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md) | `feedbackLoopDescriptionps3403305200.pdf` | 8 | LLRF Feedback Loop Description — all loop architectures (Direct, Comb, Tuner, HVPS, DAC, Ripple, Gap FF, LFB Woofer) with bandwidth specifications |

### Operational Procedures (9 documents)

| # | Document | PDF | Pages | Description |
|---|----------|-----|:-----:|-------------|
| 3 | [PS-340-330-53](operational-procedures/PS-340-330-53_RF_Cavity_Low_Power_Calibration.md) | `ps3403305300.pdf` | 4 | RF Cavity Low Power Calibration Procedure — sampling loop setting, resonance frequency measurement |
| 4 | [PS-340-330-54](operational-procedures/PS-340-330-54_RF_Station_Safety_Certification.md) | `ps3403305400.pdf` | 2 | RF Station Safety Certification Check-Off List — post-installation safety verification |
| 5 | [PS-340-330-55](operational-procedures/PS-340-330-55_RF_Station_Safety_Survey.md) | `ps3403305503.pdf` | 4 | RF Station Safety Survey (R3) — annual safety survey with radiation limits |
| 6 | [PS-340-330-56](operational-procedures/PS-340-330-56_RF_Station_Coupling_Cable_Calibration.md) | `ps3403305600.pdf` | 4 | RF Station Coupling & Cable Calibration — all signal path calibration tables |
| 7 | [PS-340-330-57](operational-procedures/PS-340-330-57_RF_Station_Full_Power_Test.md) | `ps3403305700.pdf` | 2 | RF Station Full Power Test & Survey — 1.2 MW klystron full power checkout |
| 8 | [PS-340-330-58](operational-procedures/PS-340-330-58_RF_Station_Cavity_Phasing.md) | `ps3403305800.pdf` | 4 | RF Station Cavity Phasing — waveguide bellow adjustment for cavity phase alignment |
| 9 | [PS-340-330-59](operational-procedures/PS-340-330-59_RF_Station_Turn_On_Procedure.md) | `ps3403305900.pdf` | 7 | RF Station Turn-On Procedure — EPICS panel operations, beam and parked modes |
| 10 | [PS-340-330-60](operational-procedures/PS-340-330-60_Bellow_Cavity_Phasing.md) | `ps3403306001.pdf` | 5 | Bellow Cavity Phasing Procedure (R1) — detailed bellow adjustment process |
| 11 | [PS-340-330-61](operational-procedures/PS-340-330-61_RF_Non_Ionizing_Radiation_Safety.md) | `ps3403306102.pdf` | 13 | RF Non-Ionizing Radiation Safety Procedure (R2) — waveguide safety, pressure interlocks, WSWCF forms |

### Block Diagrams (3 documents)

| # | Document | PDF | Pages | Description |
|---|----------|-----|:-----:|-------------|
| 12 | [BD-340-330-00](block-diagrams/BD-340-330-00_PEP-II_LER_RF_Station_Block_Diagram.md) | `bd3403300000.pdf` | 1 | PEP-II LER RF Station Block Diagram — complete station from PLC to cavities |
| 13 | [BD-340-330-01](block-diagrams/BD-340-330-01_PEP-II_Low_Level_RF_Configuration.md) | `bd3403300100.pdf` | 1 | PEP-II LER LLRF Configuration Block Diagram — detailed signal processing chain |
| 14 | [BD-340-329-01](block-diagrams/PEP-II_Low_Level_RF_Block_Diagram.md) | `blockDiagrambd3403290100-1.pdf` | 1 | PEP-II HER LLRF Configuration Block Diagram — HER counterpart to BD-340-330-01 |

### Duplicate

| # | Document | PDF | Notes |
|---|----------|-----|-------|
| 15 | *(not transcribed separately)* | `ps3403305200.pdf` | Identical content to `feedbackLoopDescriptionps3403305200.pdf` (PS-340-330-52) |

---

## Related Resources

- **Technical Notes** (synthesized analysis): [`../technical-notes/`](../technical-notes/)
- **Original PDFs**: [`../`](../) (same directory as this transcriptions folder)

## OCR Quality Notes

| Content Type | Confidence | Notes |
|-------------|:----------:|-------|
| Procedural text (forms, procedures) | ⬛⬛⬛⬛⬛ High | Clear, structured text — reliable extraction |
| Parameter tables | ⬛⬛⬛⬛⬜ Good | Most numerical values extracted correctly; verify critical parameters against original |
| Dense calibration tables | ⬛⬛⬛⬜⬜ Medium | Large tables (PS-340-330-56 pp.3–4) may have minor OCR artifacts |
| EPICS screenshots | ⬛⬛⬜⬜⬜ Low | Panel screenshots (PS-340-330-59 pp.3–7) have limited extractable text |
| Block diagrams | ⬛⬜⬜⬜⬜ Minimal | Signal flow diagrams — component labels extracted but routing not reliable |
| Engineering drawings | ⬛⬜⬜⬜⬜ Minimal | Facility layouts (PS-340-330-51 pp.5–11) — consult original PDFs |

## Methodology

- **PDF Library**: PyMuPDF (fitz) — native text extraction attempted first
- **OCR Engine**: Tesseract 5.3.0 — fallback at 300 DPI for image-based pages
- **All 15 PDFs** are image-based (scanned documents) — OCR was required for all pages
- **Total pages processed**: 76 pages across 15 PDFs
- **Transcription approach**: Faithful 1-to-1 reproduction of original content with markdown formatting for readability

