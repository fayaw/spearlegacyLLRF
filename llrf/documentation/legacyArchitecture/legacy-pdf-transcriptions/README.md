# Legacy PDF Transcriptions — PEP-II RF System Archive

This directory contains faithful markdown transcriptions of all **15 original legacy PDF documents** from the PEP-II RF system archive. These transcriptions were generated via OCR extraction and enhanced with domain knowledge to provide searchable, version-controlled access to the complete legacy documentation.

---

## Document Index

### Design Specifications (2 documents)

| # | Document | PDF | Pages | Description |
|---|----------|-----|:-----:|-------------|
| 1 | [PS-340-330-51](design-specifications/PS-340-330-51_RF_System_Description.md) | `ps3403305100.pdf` | 11 | RF System Description — comprehensive overview of HER (5 stations) and LER (2 stations) RF systems, nominal parameter tables, engineering drawings |
| 2 | [PS-340-330-52](design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md) | `feedbackLoopDescriptionps3403305200.pdf` | 8 | LLRF Feedback Loop Description — all loop architectures (Direct, Comb, Tuner, HVPS, DAC, Ripple, Gap FF, LFB Woofer) with bandwidth specifications and block diagrams |

### Operational Procedures (9 documents)

| # | Document | PDF | Pages | Description |
|---|----------|-----|:-----:|-------------|
| 3 | [PS-340-330-53](operational-procedures/PS-340-330-53_RF_Cavity_Low_Power_Calibration.md) | `ps3403305300.pdf` | 4 | RF Cavity Low Power Calibration Procedure — sampling loop setting, resonance frequency measurement |
| 4 | [PS-340-330-54](operational-procedures/PS-340-330-54_RF_Station_Safety_Certification.md) | `ps3403305400.pdf` | 2 | RF Station Safety Certification Check-Off List — post-installation safety verification |
| 5 | [PS-340-330-55](operational-procedures/PS-340-330-55_RF_Station_Safety_Survey.md) | `ps3403305503.pdf` | 4 | RF Station Safety Survey (R3) — annual safety survey with radiation limits |
| 6 | [PS-340-330-56](operational-procedures/PS-340-330-56_RF_Station_Coupling_Cable_Calibration.md) | `ps3403305600.pdf` | 4 | RF Station Coupling & Cable Calibration — all signal path calibration tables |
| 7 | [PS-340-330-57](operational-procedures/PS-340-330-57_RF_Station_Full_Power_Test.md) | `ps3403305700.pdf` | 2 | RF Station Full Power Test & Survey — 1.2 MW klystron full power checkout |
| 8 | [PS-340-330-58](operational-procedures/PS-340-330-58_RF_Station_Cavity_Phasing.md) | `ps3403305800.pdf` | 4 | RF Station Cavity Phasing — waveguide bellow adjustment for cavity phase alignment |
| 9 | [PS-340-330-59](operational-procedures/PS-340-330-59_RF_Station_Turn_On_Procedure.md) | `ps3403305900.pdf` | 7 | RF Station Turn-On Procedure — EPICS panel operations, structured panel reconstructions, beam and parked modes |
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

### v2 Quality Ratings (after 450 DPI multi-pass re-extraction + domain knowledge)

| Content Type | v1 Confidence | v2 Confidence | Improvement | Notes |
|-------------|:----------:|:----------:|:----------:|-------|
| Procedural text | ⬛⬛⬛⬛⬛ High | ⬛⬛⬛⬛⬛ High | Verified | 450 DPI confirms v1 extraction accuracy |
| Parameter tables | ⬛⬛⬛⬛⬜ Good | ⬛⬛⬛⬛⬛ High | ✓ | Re-extraction confirmed numerical values |
| Dense calibration tables | ⬛⬛⬛⬜⬜ Medium | ⬛⬛⬛⬛⬜ Good | ✓ | Higher DPI improved digit recognition |
| EPICS screenshots | ⬛⬛⬜⬜⬜ Low | ⬛⬛⬛⬛⬜ Good | ✓✓ | Panel content reconstructed as structured tables using OCR fragments + domain knowledge |
| Block diagrams | ⬛⬜⬜⬜⬜ Minimal | ⬛⬛⬛⬜⬜ Medium | ✓✓ | New labels recovered (REFL ports, mux/comp, LOWPASS); existing ASCII art verified |
| Engineering drawings | ⬛⬜⬜⬜⬜ Minimal | ⬛⬛⬛⬜⬜ Medium | ✓✓ | Rotated text decoded; structured descriptions with equipment tables added |
| Feedback loop block diagrams | ⬛⬜⬜⬜⬜ Minimal | ⬛⬛⬛⬛⬜ Good | ✓✓✓ | Rotated labels decoded; signal flow diagrams reconstructed; loop summary tables added |

### Key v2 Improvements

- **EPICS Screenshots (PS-340-330-59 pp.3–6):** Panel screenshots reconstructed as structured tables showing typical parameters, controls, color coding, and MATLAB configuration buttons. Content combines OCR-confirmed elements (panel titles, notes) with PEP-II LLRF domain knowledge.
- **Engineering Drawings (PS-340-330-51 pp.5–11):** Rotated annotation text decoded from garbled OCR output (e.g., "epinBevem" → "Waveguide"). Station/region configuration tables, equipment inventories, and cooling system specifications extracted from drawing annotations and cross-referenced with text description (pp.1–4).
- **Feedback Loop Diagrams (PS-340-330-52 pp.3, 8):** Rotated block diagram labels decoded. Signal flow reconstructed as ASCII block diagrams. Loop summary reference table created with bandwidth, control variables, and MATLAB configuration buttons.
- **Block Diagrams (BD-340-330-00/01, BD-340-329-01):** 450 DPI re-extraction confirmed all existing labels and recovered additional fine-grained labels (REFL port numbers, mux/comp ADC paths, LOWPASS filter, EPICS processor slot).

## Methodology

### v1 (initial extraction)
- **PDF Library**: PyMuPDF (fitz) — native text extraction attempted first
- **OCR Engine**: Tesseract 5.3.0 — fallback at 300 DPI for image-based pages
- **All 15 PDFs** are image-based (scanned documents) — OCR was required for all pages
- **Total pages processed**: 76 pages across 15 PDFs

### v2 (improved extraction)
- **OCR Engine**: Tesseract 5.3.0 at **450 DPI** (up from 300 DPI)
- **Multi-pass strategy**: Content-type-specific preprocessing pipelines:
  - **Text pages**: Adaptive threshold (Gaussian, block 31, C=10), contrast 1.8×, sharpness 2.0×
  - **EPICS screenshots**: OTSU thresholding, contrast 2.5×, sharpness 3.0×, brightness 1.3×, + inverted pass
  - **Block diagrams**: Adaptive threshold (block 51, C=15), morphological dilation/erosion, PSM 6+11
  - **Engineering drawings**: OTSU thresholding, contrast 2.2×, sharpness 3.0×, + inverted pass
- **Page Segmentation Modes**: Multiple passes per page (PSM 3 auto, PSM 4 column, PSM 6 block, PSM 11 sparse)
- **Best result selection**: Longest meaningful output from all passes selected per page
- **Domain knowledge augmentation**: Where OCR alone was insufficient (EPICS panels, rotated drawing annotations), content was reconstructed using confirmed OCR fragments combined with PEP-II RF system domain knowledge, clearly marked as such in each transcription

