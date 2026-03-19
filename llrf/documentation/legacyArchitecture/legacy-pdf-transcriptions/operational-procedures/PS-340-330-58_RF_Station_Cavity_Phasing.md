# RF Station Cavity Phasing Procedure

| Field | Value |
|-------|-------|
| **Document Number** | PS-340-330-58-R0 |
| **Title** | RF Station Cavity Phasing Procedure |
| **Author** | H.S. (Heinz Schwarz), 3/24/97 |
| **Submitted by** | Heinz Schwarz, RF Engineer |
| **Approved by** | Alan Hill, Area Manager |
| **Organization** | Stanford Linear Accelerator Center |
| **Date** | July 21, 1999 |
| **Pages** | 4 |
| **Source PDF** | `ps3403305800.pdf` |

---

Station #: ____ Date: ____ Initial: ____

## RF Station Cavity Phasing — Test Procedure & Data

### 1) Introduction

The phase relationship between 4 (HER) or 2 (LER) cavities of one station needs to be optimized to bring the RF phase of each cavity in coincidence with beam arrival.

The cavities are placed in the tunnel at the following positions starting upstream:

| Cavity | Distance (wavelengths) | Phase of RF |
|--------|----------------------|-------------|
| A | 0 (Ref.) | 0° (Ref.) |
| B | — | −270° (+90°) |
| C | — | — |
| D | — | — |

### 2) Equipment

- Coax/Waveguide Transition at waveguide into first Magic-Tee after circulator.
- Cavity cooling at 35°C, Hi-conductivity water flowing in 1.2 MW loads.
- Network Analyzer HP 8753.
- 120 W Drive Amplifier (gain 50 dB).

### 3) Set-up and Procedure

Output of 120 W drive amplifier connected to waveguide transition driving waveguide and cavities.

Set up network analyzer source (in tunnel) to drive amplifier via one of the existing monitor cables (approx. 1 mW needed to drive amplifier to 100 W output).

Connect monitor output from amplifier (30 dB coupling) with a 20 dB attenuator to the R-port of the network analyzer, connect cavity sampling probe to A-port (max. input power on R, A, B ports: 0 dBm).

Network analyzer set to CENTER **476 MHz**, 50 kHz SPAN, 1602 POINTS in sweep, DUAL DISPLAY, measure:
1. S11 (A/R) log amplitude at 0.05 dB scale
2. PHASE, MARKER #1 set to 476 MHz and REFERENCE for cavity A.

Unplug tuner motor drive cables from tuners.

Set cavities to resonance (manual tuner adjust for max. field in cavity, move tuner down as last step) and measure phase of each cavity in reference to cavity A. Adjust phase errors of cavities by moving waveguide bellows.

### 4) Data

**Initial Phase Measurements:**

| Signal Name | Nom. Ph | Ampl./Phase (1) | Ampl./Phase (2) | Ampl./Phase (3) | Avg. Phase |
|-------------|---------|-----------------|-----------------|-----------------|------------|
| cav. A probe (Ref.) | 0° | 0 dB / 0° | 0 dB / 0° | 0 dB / 0° | 0° |
| cav. B probe | −90° | ____ / ____ | ____ / ____ | ____ / ____ | ____ |
| cav. C probe | +90° | ____ / ____ | ____ / ____ | ____ / ____ | ____ |
| cav. D probe | 0° | ____ / ____ | ____ / ____ | ____ / ____ | ____ |

Calculate average phase from several measurements above.

**Calculate:** Delta phase = P_A − P_N

- If delta phase is positive: advanced phase → make bellow longer
- If delta phase is negative: delayed phase → make bellow shorter
- Bellow change is **0.085 inch/degree**

> **Note:** Bellow adjustment for cavity C also shifts cavity D and needs to be compensated for on cavity D bellow.

**Bellow Adjustments:**

| Signal Name | Nominal Phase | Average Phase | Delta Phase (P_A − P_N) | Δ length (inch) = 0.085 × ΔPh |
|-------------|:------------:|:------------:|:----------------------:|:-----------------------------:|
| cav. A probe (Ref.) | 0° | 0° | 0 | 0 |
| cav. B probe | −90° | ____ | ____ | ____ |
| cav. C probe | +90° | ____ | ____ | ____ |
| cav. D probe | 0° | ____ | ____ | ____ |

**Measure phases after bellow adjustment:**

| Signal Name | Nom. Ph | Ampl./Phase (1) | Ampl./Phase (2) | Ampl./Phase (3) | Avg. Phase |
|-------------|---------|-----------------|-----------------|-----------------|------------|
| cav. A probe (Ref.) | 0° | 0 dB / 0° | 0 dB / 0° | 0 dB / 0° | 0° |
| cav. B probe | −90° | ____ / ____ | ____ / ____ | ____ / ____ | ____ |
| cav. C probe | +90° | ____ / ____ | ____ / ____ | ____ / ____ | ____ |
| cav. D probe | 0° | ____ / ____ | ____ / ____ | ____ / ____ | ____ |

---

## Page 4: Test Setup Diagram

```
                          Drive Amplifier
                               |
                          Bellow #1
                  .-------[   ]-------.
                  |   PEP 27.6"       |
                  |                   |
                  |   Bellow #2       |
                  .-------[   ]-------.
                  |   PEP 27.6"       |
                  |                   |

     Cavity D    Cavity C    Cavity B    Cavity A

                        Source
                        ------
                      Analyzer
                      HP 8753

               4 Cavity Phasing Test Set-up
```

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `ps3403305800.pdf`. Text content on pages 1–3 is high confidence. Page 4 contains a test setup diagram; the ASCII representation above is approximate — consult the original PDF for accurate physical layout.

