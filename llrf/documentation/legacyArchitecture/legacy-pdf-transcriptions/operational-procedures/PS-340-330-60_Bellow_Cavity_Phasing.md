# Bellow Cavity Phasing Procedure

| Field | Value |
|-------|-------|
| **Document Number** | PS-340-330-60-R1 |
| **Title** | Bellow Cavity Phasing Procedure |
| **Submitted by** | Heinz Schwarz, RF Engineer |
| **Approved by** | Alan Hill, Area Manager |
| **Organization** | Stanford Linear Accelerator Center |
| **Date** | July 21, 1999 (R1 revision) |
| **Pages** | 5 |
| **Source PDF** | `ps3403306001.pdf` |

---

Station #: ____ Date: ____ Initial: ____

## Bellow Cavity Phasing Procedure

### 1) Introduction

This procedure describes the phasing of cavities in a PEP-II RF station by adjusting waveguide bellows. Proper cavity phasing ensures that the RF phase of each cavity is in coincidence with beam arrival for maximum acceleration efficiency.

The procedure is closely related to the RF Station Cavity Phasing Procedure (PS-340-330-58-R0) and provides detailed instructions for the physical bellow adjustment process.

### 2) Phasing Principle

The cavities are spaced along the beam path at specific distances. The phase relationship between cavities must be maintained so that particles see the correct accelerating phase at each cavity. Phase errors are corrected by adjusting the length of the waveguide bellows connecting the power distribution network to each cavity.

Key relationship:
- Bellow length change: **0.085 inch per degree** of phase adjustment

### 3) Equipment

- Network Analyzer HP 8753
- 120 W Drive Amplifier (gain 50 dB)
- Coax/Waveguide Transition
- Bellows adjustment tools
- Phase measurement cables and adapters

### 4) Procedure

The procedure follows these steps:

1. Measure the phase of each cavity relative to cavity A (reference) using the network analyzer.
2. Calculate the phase error (delta phase) for each cavity.
3. Calculate the required bellow length change (delta length = 0.085 × delta phase in degrees).
4. If delta phase is positive (advanced phase): make bellow longer.
5. If delta phase is negative (delayed phase): make bellow shorter.
6. Adjust bellows accordingly.
7. Re-measure phases to verify corrections.

> **Important Note:** Bellow adjustment for cavity C also shifts cavity D and needs to be compensated for on cavity D bellow.

### 5) Data Recording

**Phase Measurements:**

| Signal Name | Nominal Phase | Measured Phase | Delta Phase | Δ Length (inch) |
|-------------|:------------:|:-------------:|:-----------:|:--------------:|
| Cavity A probe (Ref.) | 0° | 0° | 0 | 0 |
| Cavity B probe | −90° | ____ | ____ | ____ |
| Cavity C probe | +90° | ____ | ____ | ____ |
| Cavity D probe | 0° | ____ | ____ | ____ |

**Post-Adjustment Verification:**

| Signal Name | Nominal Phase | Measured Phase (after) | Error |
|-------------|:------------:|:---------------------:|:-----:|
| Cavity A probe (Ref.) | 0° | 0° | 0° |
| Cavity B probe | −90° | ____ | ____ |
| Cavity C probe | +90° | ____ | ____ |
| Cavity D probe | 0° | ____ | ____ |

---

## Pages 3–5: Additional Details and Diagrams

### Page 3: Bellow Adjustment Details

*[Detailed instructions for physical bellow adjustment including torque specifications and safety precautions]*

### Page 4: Measurement Setup

*[Diagram showing the physical arrangement of equipment for phase measurements]*

### Page 5: Reference Information

*[Additional reference information and revision notes]*

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `ps3403306001.pdf`. Text content on pages 1–2 is high confidence. Pages 3–5 contain diagrams and supplementary details that are partially extractable; the original PDF should be consulted for complete content. This is revision R1 of the original document.

