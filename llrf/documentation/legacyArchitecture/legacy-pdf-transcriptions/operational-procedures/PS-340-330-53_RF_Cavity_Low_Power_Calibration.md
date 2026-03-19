# RF Cavity Low Power Calibration Procedure

| Field | Value |
|-------|-------|
| **Document Number** | PS-340-330-53-R0 |
| **Title** | RF Cavity Low Power Calibration Procedure |
| **Author** | H.S. (Heinz Schwarz), 7/2/97 |
| **Submitted by** | Heinz Schwarz, RF Engineer |
| **Approved by** | Alan Hill, Area Manager |
| **Organization** | Stanford Linear Accelerator Center |
| **Date** | July 21, 1999 |
| **Pages** | 4 |
| **Source PDF** | `ps3403305300.pdf` |

---

RF Cavity Raft Assembly # ____

Cavity SN ____ Date: ____ Initial: ____

## RF Cavity Low Power Calibration Procedure

### Low Power RF Test & Setting of Sampling Loop

### 1) Preparations

Cavity assembled with all accessories mounted (HOM Loads, Input Coupling Network with Window, Fixed Tuner, Movable Tuner w. fixture setting 8 mm insertion, Sampling Loop).

Cavity in Ante-Room of Clean Room together with Network Analyzer. Cavity purged with N₂ at atmospheric pressure.

The sampling loop is to be installed with new gasket and all bolts hand tight in the lower back port. The shorted side of the loop must point horizontally towards the HOM loads. Rotate the shorted side downward to achieve the right coupling.

### 2) Equipment

- WR2100/Coax Type N Adapter
- Network Analyzer HP 8719
- Type N Cal Kit and Type N Cables
- Temperature Meter
- Calculator
- Movable tuner spacer size: ____ inch
- Fixed tuner number: # ____

### 3) RF Measurements

Movable Tuner position set to 8 mm insertion (nominal operating position).

Calibrate network analyzer using ISOLATION FULL 2 PORT CALIBRATION (256 AVG), measure with 64 point averaging with smoothing "ON".

| Measurement | Value | Unit |
|-------------|-------|------|
| Frequency of resonance in S11 mode | f = ____ | kHz |
| Temperature at cavity surface | T = ____ | °C |
| Correction to 35°C | Δf_T = (35°C − T)(−7.95 kHz/°C) = ____ | kHz |
| Correction for Vacuum | Δf_v = +124 | kHz |
| Res. Freq. at 35°C & Vacuum | f₃₅°C&Vac = f + Δf_T + Δf_v = ____ | kHz |

**Target Frequency** at 35°C & Vacuum: f = 476,000 + 100 kHz. If f₃₅°C&Vac is outside tolerance the fixed tuner needs adjustment (30 kHz/mm, +2/−3 mm nominal range).

| Measurement | Value | Unit |
|-------------|-------|------|
| Frequency w. tuner all way out | f = ____ | kHz |
| Frequency w. tuner all way in | f = ____ | kHz |

**Input coupling:** Measure S11 of the input coupling/cavity assembly:

**Loaded Q:** Use Transmission measurement S21 through sampling probe:

Q_L = ____

**Unloaded Q:** Q₀ = Q_L (1+β) = ____

**External Q:** Q_e = Q₀/β = ____

**Remarks:** ____

### 4) Sampling Loop Setting

**Requirements:** At 150 kW cavity wall dissipation and a Q₀ of 30,000 a 1 W signal should appear at the end of the signal cable connected to the sampling probe:

Gap Voltage = 1025 kV

The dB ratio of Sampling Loop Power (Ps) versus Incident Power (Pinc) is then calculated to:

```
Ps/Pinc = −51.8 dB + 10·log(Q₀/30,000) + 10·log[4β/(1+β)²] + 0.6 dB
```

**Example:** Q₀ = 34,000, β = 4.0:

```
Ps/Pinc = −51.8 dB + 0.54 dB − 1.94 dB + 0.6 dB = −52.6 dB
```

**Target:**

```
Ps/Pinc = −51.8 dB + ____ dB − ____ dB + 0.6 dB = −____ dB
```

after tightening of the sampling probe. Acceptable variation is ± 0.3 dB.

A value of −0.5 dB needs to be added to above number to arrive at the setting before tightening of the loop:

```
Ps/Pinc = −____ dB − 0.5 dB = −____ dB before tightening.
```

**Final loop coupling number:** = −____ dB after tightening.

**Probe cal. for database** = 99.6 dB − Final coupl. number + Target Ps/Pinc = ____ dB

> If the value of the "final coupling" number is larger than the "target" number, the 99.6 will also get larger.

**Remarks:**

For calibration in the teststand the number −51.2 dB should be used which gives 1.14 W at the sampling probe for 150 kW wall loss corresponding to 1025 kV field at a Q₀ = 30,000.

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `ps3403305300.pdf`. Blank fields (____) represent fill-in entries on the original form. All text content is high confidence.

