# Bellow Cavity Phasing Procedure

| Field | Value |
|-------|-------|
| **Document Number** | PS-340-330-60-R1 |
| **Title** | Bellow Cavity Phasing Procedure |
| **Author** | H.S. (Heinz Schwarz), 1/5/99 |
| **Submitted by** | Heinz Schwarz, RF Engineer |
| **Approved by** | Alan Hill, Area Manager |
| **Organization** | Stanford Linear Accelerator Center |
| **Date** | September 17, 1999 |
| **Pages** | 5 |
| **Source PDF** | `ps3403306001.pdf` |

---

Station #: ____ Date: ____ Initial: ____

## Bellow Cavity Phasing — Procedure & Data

### 1) Introduction

The phase relationship between 4 (HER) or 2 (LER) cavities of each station has been optimized at installation to bring the RF phase of each cavity in coincidence with beam arrival.

Some touch-up adjustment may be required if the balance between the cavity gap voltages of a station is not constant under high beam current conditions. Small adjustments in the length of the bellows of the waveguide splitting network can correct this imbalance. The procedure is described below:

### 2) Measurement of Phase Error Procedure

The **Load Angle Offset routine** is used to measure the magnitude of the phase offset of individual cavities of a station in reference to the beam.

The set-up and measurement is done using the **Cavity Tuners Panel**:

Initially with zero beam the **Cav Strength (%)** numbers need to be transferred to the **Setpoint (%)** data input box to set the idling condition of the cavities of a station.

Next with a stored beam larger than the **Min Beam Curr (mA)** set on the same panel the Load Angle Offset routine can be turned **ON** to activate the **Load Angle Offset Loop** which moves the tuners to bring the Cav Strength (%) reading with beam back to the idling cavity strength. The phase offsets for each cavity can then be read as **Ld Angle Offset (Deg)** on the Cavity Tuner Panel. The Load Angle Offset Loop is an iterative loop which will take a few minutes to stabilize (The Ld Angle Error box will go yellow every time a tuner is asked to move).

Record the Angle Offsets after the loop has stabilized in the Data table under 4).

> **Note:** The Load Angle Offset routine has to be turned Off again after this measurement because it interferes with the Magic Detuning required for high beam current operation.

### Page 3: Cavity Tuners EPICS Panel (Example)

*[Screenshot of EPICS Cavity Tuners panel for station HER RF 8-3 showing:]*

**Temperatures (deg C):**

| Measurement | Cav A | Cav B | Cav C | Cav D |
|-------------|-------|-------|-------|-------|
| Fixed Tuner | 37 | 36 | 37 | 38 |
| Movable Tuner | 33 | 37 | 39 | 37 |
| Movable Tuner Bellows | 39 | 36 | 38 | 37 |
| Loop Status | GOOD | GOOD | GOOD | GOOD |
| Ld Angle Error (Deg) | -0.41 | -0.35 | 0.26 | 6.15 |

**Station State:** ON_CW

Panel also shows: Cav Strength (%), Setpoint (%), Diagnostic Plots, Stn Voltage (kV), Min Beam Curr (mA), Cav Voltage (kV), Tuner Pos (mm).

Example tuner readings from panel:

| Cavity | Cav Voltage (kV) | Tuner Pos (mm) | Tuner Range |
|--------|-----------------|----------------|-------------|
| A | 700 | 2.14 | -30.000 to +20.000 |
| B | 703 | 4.08 | -30.000 to +20.000 |
| C | 700 | 0.88 | -30.000 to +20.000 |

### 4) Data

**Phase Measurement and Bellow Adjustment Data:**

| Cavity | Ld Angle Offset (Deg) | Delta Phase = PhN − PhA | # bellow | Δ length (inch) = −0.085 × ΔPh |
|--------|----------------------|------------------------|----------|-------------------------------|
| A (Ref) | ____ | 0 | — | 0 |
| B | ____ | ____ | ____ | ____ |
| C | ____ | ____ | ____ | ____ |
| D | ____ | ____ | ____ | ____ |

**Calculate:** Delta Phase = PhN − PhA.

- If Delta Phase is **positive**: make bellow **shorter**
- If Delta Phase is **negative**: make bellow **longer**

**Bellow change is 0.085 inch/degree.**

> **Note:** Adjustment of bellow #1 for cavity C also shifts cavity D and needs to be compensated for by counter adjusting bellow #3.

**Repeat if necessary:**

| Cavity | Ld Angle Offset (Deg) | Delta Phase = PhN − PhA | # bellow | Δ length (inch) = −0.085 × ΔPh |
|--------|----------------------|------------------------|----------|-------------------------------|
| A (Ref) | ____ | 0 | — | 0 |
| B | ____ | ____ | ____ | ____ |
| C | ____ | ____ | ____ | ____ |
| D | ____ | ____ | ____ | ____ |

### Page 5: Bellow Layout Diagram

*[Diagram showing HER 4-cavity waveguide bellow arrangement:]*

```
          Bellow #1
    ──────────||──────────
    │                     │
    │    PEP 27.6         │     PEP 27.67
    │    / tet            │     / tet
    │                     │
    ▼                     ▼
  Cavity D    Cavity C    Cavity B    Cavity A

  Date: ____
  Bellow #2: ____  Bellow #1: ____  Bellow #3: ____
```

> The diagram shows the physical bellow positions in the waveguide splitting network for an HER station (4 cavities). Bellow #1 connects cavities C and D to the upstream magic tee; Bellow #2 and #3 connect individual cavities.

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `ps3403306001.pdf`. Text content on pages 1–2 and 4 is high confidence. Page 3 contains an EPICS panel screenshot with partially extractable readings. Page 5 contains a bellow layout diagram. This is revision R1 of the original document.

