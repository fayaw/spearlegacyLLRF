# RF Station Coupling & Cable Calibration Procedure

| Field | Value |
|-------|-------|
| **Document Number** | PS-340-330-56-R0 |
| **Title** | RF Station Coupling & Cable Cal Procedure |
| **Author** | H.S. (Heinz Schwarz) & P.C. (Paul Corredoura), 7/2/97 |
| **Submitted by** | Heinz Schwarz, RF Engineer |
| **Approved by** | Alan Hill, Area Manager |
| **Organization** | Stanford Linear Accelerator Center |
| **Date** | July 21, 1999 |
| **Pages** | 4 |
| **Source PDF** | `ps3403305600.pdf` |

---

Station #: ____ Date: ____ Initial: ____

## RF Station Coupling & Cable Loss — Test Procedure & Data

### 1) Introduction

In the attached table data is to be entered derived from component calibration data sheets or the cable loss is to be calibrated using the procedure described below.

### 2) Procedure

**Cavity sampling probe coupling value:**

In the column "Device Info" enter the Cavity Raft Assembly # installed in cavity position A, B, C or D.

Cavity sampling probe database value is nominal **99.6 dB** modified by a number derived from the LOW POWER TEST DATA for the correct Cavity Raft Assembly. On page 3 LOW POWER TEST DATA calculate the difference between the calculated coupling Ps/Pinc (approx. −52.5 dB) and the "Final loop coupling number after tightening". If the final number is larger than Ps/Pinc the difference must be added to the 99.6 dB so it will also be larger.

**Forward and reflected coupling value:**

In the column "Device Info" enter the Coupler # installed and check if the FORWARD port of the coupler agrees with the forward direction of the power flow. If the coupler is reversed, please note.

The forward and reflected coupling value is found on calibration data sheets for the couplers.

**Cable loss value:**

The cable loss value needs to be measured at **476 MHz**. First set the signal generator with a 10 dB matching attenuator to 0 dBm (1 mW) into the HP 435 power meter, then connect the signal generator/attenuator to the proper J-NUMBER of the 1/4 inch Heliax pigtails in the Blue Rack and measure the loss at the other end of the cable in the tunnel or upstairs with the same HP 435 power meter. Re-check the output power of the signal generator (0 dBm) often.

### 3) Equipment

- Signal Generator HP 8648
- 10 dB attenuator to improve source match
- Power Meter HP 435

---

## Pages 3–4: Calibration Data Tables

> **Note**: Pages 3 and 4 consist of detailed calibration data entry tables for all signal paths in an RF station. The tables list coupling values, cable losses, and IQ module channel conversion losses for each signal channel. Due to the dense tabular format and OCR limitations, the structure is reproduced below with the nominal values where legible.

### Cavity A

| Signal Path | Device Info | Nominal (dB) | Measured (dB) |
|-------------|-------------|:------------:|:-------------:|
| Cavity A probe coupling value — cavity assembly # = ____ | | 99.6 | ____ |
| Cavity A probe Heliax, coupler and SMA pigtail cable loss | | 1.0 | ____ |
| Cavity A probe IQ module channel conversion loss | | 13.15 | ____ |
| Cavity A forward coupling value — coupler # = ____ | | 60.0 | ____ |
| Cavity A forward Heliax and SMA pigtail cable loss | | 1.0 | ____ |
| Cavity A forward IQ module channel conversion loss | | 13.15 | ____ |
| Cavity A reflected coupling value — coupler # = ____ | | 60.0 | ____ |
| Cavity A reflected Heliax and SMA pigtail cable loss | | 1.0 | ____ |
| Cavity A reflected IQ module channel conversion loss | | 13.15 | ____ |

### Cavities B, C, D

*[Same structure repeated for cavities B, C, and D with identical nominal values]*

Each cavity (B, C, D) has the same three signal paths (probe, forward, reflected) with the same nominal coupling/loss values:
- Probe coupling: 99.6 dB
- Forward coupling: 60.0 dB
- Reflected coupling: 60.0 dB
- Cable losses: 1.0 dB each
- IQ module conversion loss: 13.15 dB each

### Klystron

| Signal Path | Device Info | Nominal (dB) | Measured (dB) |
|-------------|-------------|:------------:|:-------------:|
| Klystron forward coupling value — coupler # = ____ | | 30.0 | ____ |
| Klystron forward Heliax and SMA pigtail cable loss | | 1.0 | ____ |
| Klystron forward IQ module channel conversion loss | | 13.15 | ____ |
| Klystron reflected coupling value — coupler # = ____ | | 60.0 | ____ |
| Klystron reflected Heliax and SMA pigtail cable loss | | 1.0 | ____ |
| Klystron reflected IQ module channel conversion loss | | 13.15 | ____ |

### Circulator Load

| Signal Path | Device Info | Nominal (dB) | Measured (dB) |
|-------------|-------------|:------------:|:-------------:|
| Circulator load forward coupling value — coupler # = ____ | | 60.0 | ____ |
| Circulator load forward Heliax and SMA pigtail cable loss | | 4.0 | ____ |
| Circulator load forward IQ module channel conversion loss | | 13.15 | ____ |
| Circulator load reflected coupling value — coupler # = ____ | | 60.0 | ____ |
| Circulator load reflected Heliax and SMA pigtail cable loss | | 4.0 | ____ |
| Circulator load reflected IQ module channel conversion loss | | 13.15 | ____ |

### Magic Tee Loads (#1, #2, #3)

*[Same structure for each of the three Magic Tee loads]*

Each Magic Tee load (forward and reflected):
- Coupling value: 60.0 dB
- Cable loss: 1.0 dB (per OCR — some entries show 4.0 dB)
- IQ module conversion loss: 13.15 dB

### Klystron Drive

| Signal Path | Device Info | Nominal (dB) | Measured (dB) |
|-------------|-------------|:------------:|:-------------:|
| Klystron drive forward coupling value — amplifier serial # = ____ | | 30.0 | ____ |
| Klystron drive forward Heliax and SMA pigtail cable loss | | 1.0 | ____ |
| Klystron drive forward IQ module channel conversion loss | | 13.15 | ____ |
| Klystron drive amplifier to klystron input forward cable loss | | 1.0 | ____ |

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `ps3403305600.pdf`. Pages 1–2 are high confidence text. Pages 3–4 contain dense calibration tables; nominal values are extracted where legible, but some entries may have OCR artifacts. Consult the original PDF for exact form layout and all fill-in fields.

