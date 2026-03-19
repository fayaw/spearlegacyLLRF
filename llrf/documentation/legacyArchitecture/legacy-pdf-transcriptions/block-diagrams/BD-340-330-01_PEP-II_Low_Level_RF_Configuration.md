# PEP-II Low Level RF Configuration (LER)

| Field | Value |
|-------|-------|
| **Document Number** | BD-340-330-01-R0 |
| **Title** | PEP-II LER LLRF Configuration — Block Diagram |
| **Author** | P. Corredoura, 1/28/98 |
| **Organization** | Stanford Linear Accelerator Center, U.S. Department of Energy |
| **Date** | January 28, 1998 |
| **Pages** | 1 |
| **Source PDF** | `bd3403300100.pdf` |
| **Drawing Standard** | ASME Y14.5M-1994 |

---

## Description

This is a detailed block diagram of the PEP-II Low Energy Ring (LER) Low-Level RF (LLRF) configuration showing the complete signal processing chain from the 476 MHz input through the modulator, klystron, and RF distribution to four cavities, with all feedback loop signal paths.

## Key Components and Signal Flow (from OCR)

### RF Input and Drive Chain
- **476 MHz** input signal
- **RF switch** — to real/imaginary control
- **RF MODULATOR** — I&Q modulation
- **AMPLIFIER** — +16 dBm → +30 dBm → +30 dBm stages
- 120 W max drive power
- **KLYSTRON** — 1.2 MW max output
- **CIRCULATOR** — with LOAD

### Cavity RF Distribution
- 4 cavities, each with:
  - Cavity probe: to I&Q detector (30 dBm max)
  - Forward power: to I&Q detector
  - Reflected power: to I&Q detector
  - REF-476 reference signal

### VXI RF Module — Signal Processing
- **Baseband Network Analyzer**
- **I/Q MOD** (modulator) and **I/Q DETECTOR** (demodulator) pairs
- **512K RAM** blocks (multiple) — data acquisition
  - cav X ADC, cav Q ADC
  - sig I ADC, sig Q ADC
- Sample rate: **F_sample = 10 MHz**
- **PADs** — signal attenuators

### Feedback Loops Shown
- **DIRECT LOOP**:
  - PID controller
  - Direct loop adjustment
  - Signal paths for all 4 cavities (cav 1 adj, cav 2 adj, cav 3 adj, cav 4 adj)
- **COMB FILTER** (×2):
  - Comb loop with 1-turn delays
  - Delay equalizers
  - System I/Q processing
  - +/− 2V signal range
  - Mass I/Q MOD → I/Q detector
- **RIPPLE LOOP**:
  - Connected to HVPS via D/A
  - 30 dBm max signal
- **GAP FEEDFORWARD**:
  - VXI module
  - Lowpass filter
  - Connected to gap module

### Signal Monitoring Points
- Forward power monitoring (max levels noted)
- Reflected power monitoring
- Spare channels (spare1, spare2)
- REF-476 reference distribution

### Interconnections to External Systems
- Serial link to I&Q
- Parallel bus
- PSP1610 LOAD connection
- ATET connection
- Longitudinal feedback system — kick connection
- VXI comb modules (×2)
- Power supply connections

---

## Title Block

| Field | Value |
|-------|-------|
| Drawing | BD-340-330-01 R0 |
| Title | PEP2 LER LLRF CONFIGURATION — BLOCK DIAGRAM |
| Designed by | Paul Corredoura |
| Approved by | Paul Corredoura |
| Status | Draft |
| Scale | Do Not Scale Drawing |

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `bd3403300100.pdf`. This is a single-page engineering block diagram with dense signal routing; OCR text extraction from complex diagrams has limited reliability. The component and signal path lists above are assembled from recognizable OCR fragments. **The original PDF should be consulted for accurate signal routing, gain levels, and detailed component labels.**

