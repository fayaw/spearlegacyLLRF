# PEP-II Low Level RF Block Diagram (HER)

| Field | Value |
|-------|-------|
| **Document Number** | BD-340-329-01-R0 |
| **Title** | PEP-II HER LLRF Configuration — Block Diagram |
| **Author** | P. Corredoura, 1/26/98 |
| **Organization** | Stanford Linear Accelerator Center, U.S. Department of Energy |
| **Date** | January 26, 1998 |
| **Pages** | 1 |
| **Source PDF** | `blockDiagrambd3403290100-1.pdf` |
| **Drawing Standard** | ASME Y14.5M-1994 |

---

## Description

This is a detailed block diagram of the PEP-II High Energy Ring (HER) Low-Level RF (LLRF) configuration. It is the HER counterpart to BD-340-330-01 (LER configuration), showing the complete signal processing chain for a 4-cavity HER RF station.

> **Note**: The HER configuration is nearly identical to the LER configuration (BD-340-330-01) since both rings use the same LLRF architecture. The key difference is that HER stations drive **4 cavities** per station (vs. 2 for LER) with correspondingly more signal channels.

## Key Components and Signal Flow (from OCR)

### RF Input and Drive Chain
- **476 MHz** input signal
- **RF switch** — to real/imaginary control
- **RF MODULATOR** — I&Q modulation
- **AMPLIFIER** — +16 dBm → +30 dBm → +30 dBm stages
- 120 W max drive power
- **KLYSTRON** — 1.2 MW max output
- **CIRCULATOR** — with LOAD

### Cavity RF Distribution (4 cavities for HER)
- 4 cavities, each with:
  - Cavity probe: to I&Q detector (30 dBm max)
  - Forward power: to I&Q detector
  - Reflected power: to I&Q detector
  - REF-476 reference signal
- Additional cavity channels compared to LER

### VXI RF Module — Signal Processing
- **Baseband Network Analyzer**
- **I/Q MOD** and **I/Q DETECTOR** pairs (multiple channels)
- **512K RAM** blocks — data acquisition
- Sample rate: **F_sample = 10 MHz**
- PADs — signal attenuators

### Feedback Loops
- **DIRECT LOOP**: PID controller, direct adj for 4 cavities
- **COMB FILTER** (×2): 1-turn delays, delay equalizers, system I/Q
- **RIPPLE LOOP**: HVPS D/A connection
- **GAP FEEDFORWARD**: VXI module with lowpass filter, gap module

### External System Connections
- Longitudinal feedback system — kick
- VXI comb modules (×2)
- Serial and parallel bus interfaces
- Power supply connections

---

## Title Block

| Field | Value |
|-------|-------|
| Drawing | BD-340-329-01 R0 |
| Title | PEP2 HER LLRF CONFIGURATION |
| Designed by | Paul Corredoura |
| Approved by | Paul Corredoura |
| Status | Draft |
| Scale | Do Not Scale Drawing |

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `blockDiagrambd3403290100-1.pdf`. This is a single-page engineering block diagram with dense signal routing. The content is nearly identical to BD-340-330-01 (LER) with additional cavity channels for the HER 4-cavity configuration. **The original PDF should be consulted for accurate signal routing, gain levels, and detailed component labels.** Note the different document numbering scheme: BD-340-**329**-01 (HER) vs. BD-340-**330**-01 (LER).

