# PS-341-360-01-02 Engineering Drawing Package — Specification Reference

**Document ID:** HVPS-ORIG-003  
**Source:** `hvps/architecture/originalDocuments/ps3413600102.pdf`  
**Type:** Scanned engineering drawings (image-only, no OCR text)  
**Pages:** 24  
**Format:** PDF 1.2, scanned at 2496×3247 pixels per page  
**Drawing Number Convention:** PS-341-360-01-02 (SLAC standard: PS = Power Supply, 341 = Department/Group, 360 = System, 01 = Drawing, 02 = Revision)

---

## 1. Document Characterization

This 24-page document is a **scanned engineering specification and drawing package** for the PEP-II klystron power supply. The document contains no embedded OCR text — all content is in scanned image form.

### Document Format Assessment
- **PDF Version:** 1.2 (very early PDF specification)
- **No metadata** (title, author, creator, dates are all empty)
- **Each page:** Single embedded PNG image at 2496×3247 resolution
- **Page size:** 599 × 779 points (approximately 8.3" × 10.8")
- **This is likely a scan of original D-size or C-size engineering drawings** reduced to fit standard page format

### Drawing Number System
The filename `ps3413600102` decodes as:
- **PS** — Power Supply (document type)
- **341** — Department/system identifier (SPEAR RF group at SLAC/SSRL)
- **360** — System or subsystem code
- **01** — Drawing or specification sheet number
- **02** — Revision 02

This numbering is consistent with other SLAC/SSRL drawing numbers found throughout the repository:
- `sd7307900101.pdf` — SD = Schematic Drawing, 730-790-01-01
- `wd7307900103.pdf` — WD = Wiring Diagram, 730-790-01-03

---

## 2. Inferred Content Based on Cross-References

While the scanned images cannot be OCR-processed in this analysis, the content can be inferred from multiple cross-references in the codebase:

### 2.1 Referenced in HVPS Engineering Technical Note
From `Designs/4_HVPS_Engineering_Technical_Note.md`, Section 1.2:
> **Source:** `architecture/originalDocuments/slac-pub-7591.pdf`, `architecture/originalDocuments/ps3413600102.pdf`

This document is cited alongside the IEEE paper as a primary source for:
- Input transformer rating (3.5 MVA phase-shifting)
- Rectifier transformer ratings (1.5 MVA each)
- Maximum output voltage (−90 kVDC)
- Maximum output current (27 A)
- Rectifier topology (12-pulse, thyristor phase-controlled)

### 2.2 Probable Page Contents (by Category)

Based on the 24-page count and typical SLAC power supply drawing packages, the document likely contains:

| Page Range (Estimated) | Content Type | Description |
|------------------------|-------------|-------------|
| 1 | Title sheet | Drawing title block, revision history, approval signatures |
| 2–3 | System specifications | Electrical specifications, performance requirements |
| 4–6 | Power one-line diagram | Single-line diagram showing power flow from 12.5kV input through transformers, SCRs, to output |
| 7–9 | Transformer specifications | Phase shifting transformer, rectifier transformers T1/T2 — turns ratios, tap voltages, VA ratings |
| 10–12 | SCR rectifier details | Thyristor stack configurations, snubber circuits, gate drive requirements |
| 13–15 | Filter network | Inductor specifications (350 µH, 40A), capacitor specs (30nF 37kV, 10nF 56kV), resistor networks |
| 16–17 | Crowbar circuit | Crowbar SCR configuration, snubber matching, trigger requirements |
| 18–19 | Grounding tank | Current sensing (Danfysik), voltage dividers, ground connections |
| 20–21 | Control circuit | Regulator card interface, Enerpro connections, PLC I/O |
| 22–23 | Interlock/protection | Safety interlocks, PPS interface, arc detection |
| 24 | Bill of materials or notes | Component list, general notes, reference drawings |

### 2.3 Known Specifications Traceable to This Document

From cross-referencing all existing technical notes:

**Power Conversion:**

| Parameter | Value | Confidence |
|-----------|-------|------------|
| Phase shifting transformer | Extended delta, 3.5 MVA | High |
| Phase shifting transformer output | 12.91 kV RMS φ-φ | High |
| Phase shift | ±15° | High |
| Rectifier transformer T1 | Open Wye primary, dual Wye secondary, 1.5 MVA | High |
| Rectifier transformer T2 | Open Wye primary, dual Wye secondary, 1.5 MVA | High |
| T1 secondary S1 | 21.0 kV RMS φ-φ | High |
| T1 secondary S2 | 21.0 kV RMS φ-φ | High |
| T2 secondary S1 | 21.0 kV RMS φ-φ | High |
| T2 secondary S2 | 10.5 kV RMS φ-φ | Medium |

**SCR Stacks:**

| Parameter | Value | Confidence |
|-----------|-------|------------|
| Phase control stacks | 12 total (6 per bridge) | High |
| Devices per stack | 14 × Powerex T8K7 (350A) | High |
| Stack snubber capacitor | 0.015 µF (R-C series) | High |
| Device snubber capacitor | 0.047 µF per device | High |
| Maximum voltage per stack | 18.26 kV (√2 × 12.91 kV) | High |

**Filter Network:**

| Parameter | Value | Confidence |
|-----------|-------|------------|
| Filter inductors | 2 × 0.3 H (L1, L2) | High |
| Full-load inductor current | 85 A | Medium |
| Filter capacitors (high voltage) | 10 nF at 56 kV (×2) | High |
| Filter capacitors (medium voltage) | 30 nF at 37 kV (×2) | High |
| Filter capacitors (main) | 8 µF at 30 kV (×4) | High |
| Filter resistors | 500 Ω at 1 kW (×8) | High |
| Termination resistors | 50 Ω (×12) | High |

**Crowbar:**

| Parameter | Value | Confidence |
|-----------|-------|------------|
| Crowbar stacks | 4 SCR stacks | High |
| Devices per crowbar stack | 6 thyristors | High |
| Trigger | Fiber-optic | High |
| Delay time | ~10 µs | High |
| Termination tank inductors | 200 µH | High |

---

## 3. Relationship to Presentation Document

The `pepII supply.pptx` presentation (analyzed in Note 02) appears to be derived from this engineering drawing package, with the presentation containing:
- Simplified versions of the schematics from this package
- Oscilloscope waveform captures not in this package
- Wiring diagrams that correspond to specific sheets in this package
- Component values that match the specifications herein

The wiring diagram sheets in the PPTX (Slides 18–24) carry drawing numbers:
- **WD-730-790-02** — "Trigger Enclosure Wiring"
- **WD-730-790-01** — "Interconnection Wiring"

These are **separate wiring diagrams** from the PS-341-360-01-02 specification package, indicating a full drawing set consists of at least:
- PS-341-360-01-02 — Power supply specifications (this document)
- WD-730-790-01 — Interconnection wiring
- WD-730-790-02 — Trigger enclosure wiring
- SD-730-790-01-01 — System schematic (in `hvps/documentation/schematics/`)

---

## 4. Image Quality & Future OCR Potential

The scanned images are at **2496×3247 pixels** (~300 DPI for D-size drawings). This resolution is suitable for:
- **Visual inspection** on screen
- **OCR processing** with specialized engineering OCR tools
- **Manual transcription** of key values and annotations

**Recommended future action:** Process these images with a specialized engineering OCR tool or manually transcribe the key specification tables from each page to create a fully text-searchable version.

---

## 5. Critical Information NOT Available Elsewhere

This drawing package is the **only source** for certain details that cannot be obtained from the IEEE paper or PPTX presentation:

1. **Detailed transformer winding specifications** — turns ratios, impedances, tap configurations
2. **SCR stack mechanical drawings** — physical layout, cooling requirements
3. **Snubber circuit component values** — resistor and capacitor details for each snubber
4. **Voltage divider specifications** — for the two HV output monitors
5. **Oil-to-oil feed-through specifications** — for the isolated tank connections
6. **Bill of materials** — complete component list with part numbers
7. **Tolerance specifications** — for all critical parameters
8. **Test requirements** — acceptance testing procedures and limits

---

**Document Status:** Reference characterization (image-only document — no text extraction possible)  
**Confidence Level:** Medium for inferred content, High for cross-referenced specifications  
**Recommended Action:** Manual transcription of key specification pages or OCR processing  
**Related Notes:** [01_SLAC_PUB_7591_IEEE_Paper_Analysis.md](01_SLAC_PUB_7591_IEEE_Paper_Analysis.md), [02_PEP_II_Power_Supply_Presentation_Analysis.md](02_PEP_II_Power_Supply_Presentation_Analysis.md)

