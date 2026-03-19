# RF Station Turn-On Procedure

| Field | Value |
|-------|-------|
| **Document Number** | PS-340-330-59-R0 |
| **Title** | RF Station Turn-On Procedure |
| **Author** | H.S. (Heinz Schwarz), 9/14/98 |
| **Submitted by** | Heinz Schwarz, RF Engineer |
| **Approved by** | Alan Hill, Area Manager |
| **Organization** | Stanford Linear Accelerator Center |
| **Date** | July 21, 1999 |
| **Pages** | 7 |
| **Source PDF** | `ps3403305900.pdf` |

---

## RF Station Turn-On Procedure

### Pre-condition:

- Klystron Filament & Solenoid **"ON"**
- Filament Volt./Curr. **"GREEN"**
- Filament Time Left **0 sec "GREEN"**

> (Klystron filament and solenoid can be turned ON from the EPICS control system KLYSTRON panel. Filament Time Left timer runs for 30 min., then interlocks can be cleared).

- All boxes on main RF STATION panel **"GREEN"** except HVPS box if HVPS contactor is OFF.

### Start-Up Sequence

1. Push **RESET**
2. Contactor **CLOSE** on main RF STATION panel or HVPS panel.

> **Note:** If the Contactor cannot be closed several "manual reset" interlocks as listed on the HVPS panel may be faulted. These need to be reset using the RESET button on the HVPS SMART TOUCH panel in rack 2 of the electronic racks of each station.

> **Note:** All following control buttons can be found on the RF STATION panel.

### Beam Operation

Use **ON_CW** mode. HVPS Loop OFF/PROC/ON buttons in **ON**. The station will automatically run up the HVPS voltage to the set Stn Gap Volt (kV) and then regulate it there. Also the Ripple Loop, Direct Loop and Comb Loop will be initiated. (See: FEEDBACK panel for loop status).

Set "Auto Reset Tries Left" to a max. of **25 resets**. This automatically brings the station back on after a trip except when the HVPS contactor trips.

### Station Parked

To temporarily park station cavities **+340 kHz** from resonance goto **OFF** mode and then **PARK** mode with the HVPS contactor closed (all interlocks must be green to clear the beam abort and go to the PARK mode).

To long-term park the cavities a RF station can be changed into the **OFF-LINE** mode by pushing the **OFF-LINE** button on the RF STATION panel or by turning a **STATION LOCK-OUT** key at the RF LOCAL DISPLAY PANEL in rack 3 of the electronic racks of each station. Now the station can be put in the PARK mode with the HVPS and klystron turned off and the beam abort will only fire when essential interlocks like: waveguide pressure, cavity vacuum, cavity or load cooling flow interlocks trip.

> **Note:** If the station does not stay in the PARK mode one of the essential interlocks is not made up and the beam abort is not reset.

---

## Page 3: Fig. 1 — KLYSTRON Panel

> Screenshot of the EPICS KLYSTRON control panel for a PEP-II RF station.

The KLYSTRON panel provides monitoring and control for the klystron and circulator subsystems. The panel is divided into the following sections as reconstructed from OCR fragments and PEP-II LLRF domain knowledge:

### Panel Header

| Field | OCR-Confirmed | Notes |
|-------|:---:|-------|
| Panel Title | ✓ | "Klys and Circ" (Klystron and Circulator) |
| Station ID | — | Displays the station identifier (e.g., HER RF 8-3, LER RF 4-4) |

### Klystron Status Section

| Parameter | Description | Typical Units |
|-----------|-------------|:---:|
| Klystron Description | Station identifier and klystron serial number | — |
| Filament Voltage | Klystron heater voltage readback | V |
| Filament Current | Klystron heater current readback | A |
| Filament Time Left | Warm-up countdown timer (30 min) | sec |
| Solenoid Current | Focusing solenoid current | A |
| Body Current | Klystron body (collector) current | mA |
| Beam Voltage | Klystron cathode-anode voltage (from HVPS) | kV |
| Beam Current | Klystron beam current | A |

### Circulator Section

| Parameter | Description | Typical Units |
|-----------|-------------|:---:|
| Circulator Load Temperature | Water-cooled load temperature | °C |
| Circulator Arc Detector | Arc detection status | OK/FAULT |

### Cavity Power Section

| Parameter | Description | Typical Units |
|-----------|-------------|:---:|
| Forward Power (per cavity) | RF forward power to each cavity | kW |
| Reflected Power (per cavity) | RF reflected power from each cavity | kW |
| Cavity Gap Voltage (per cavity) | Accelerating voltage per cavity | kV |
| Cavity Vacuum (per cavity) | Ion gauge pressure reading | Torr |

### Controls

| Button | Function |
|--------|----------|
| Filament/Solenoid ON/OFF | Combined ON/OFF for klystron filament and solenoid |

> **Note (from original):** The solenoid and the filament ON/OFF buttons are now combined into a single ON/OFF button.

### Color Coding

| Color | Meaning |
|-------|---------|
| 🟢 GREEN | Normal / OK / Within limits |
| 🔴 RED | Fault / Interlocked / Out of limits |
| 🟡 YELLOW | Warning / Transitional state |
| ⬜ GRAY | Disabled / Not applicable |

---

## Page 4: Fig. 2 — RF STATION Panel

> Screenshot of the EPICS RF STATION panel (station shown: HER RF 12-3).

The RF STATION panel is the primary operator interface for station control and monitoring. OCR confirmed the station ID "HER RF 12-3" and the presence of major subsystem status blocks.

### Station Mode Controls

| Button | Mode | Description |
|--------|------|-------------|
| **ON_CW** | Continuous Wave | Normal beam operation — HVPS loop regulates to set gap voltage |
| **ON_FM** | Frequency Modulated | Pulsed mode at 1000 Hz — used for cavity processing |
| **OFF** | RF Off | Turns RF off, fires beam abort; tuners left in position; HVPS contactor stays closed |
| **PARK** | Parked | Detunes cavities +340 kHz from resonance |
| **OFF-LINE** | Off-Line | Station locked out — only essential interlocks active |
| **TUNE** | Tune Mode | For cavity tuning procedures |
| **RESET** | Reset | Clears faulted interlocks |

### Subsystem Status Blocks (color-coded indicators)

| Block | Subsystem | Green = | Red = |
|-------|-----------|---------|-------|
| P(klystron) | Klystron | Filament/solenoid OK | Klystron fault |
| P(circulator) | Circulator | Circulator OK | Arc detected / overtemp |
| HVPS | High Voltage PS | HVPS ready, contactor closed | HVPS fault / contactor open |
| P(waveguide) | Waveguide | Pressure OK | Pressure fault |
| P(cavities) | Cavities | Vacuum/cooling OK | Vacuum or cooling fault |

### Station Parameters

| Parameter | Description | Typical Units |
|-----------|-------------|:---:|
| Stn Gap Volt | Requested station gap voltage | kV |
| Meas Gap Volt | Measured (actual) station gap voltage | kV |
| HVPS Voltage | High voltage power supply output | kV |
| HVPS Current | High voltage power supply current | A |
| Klys Fwd Power | Total klystron forward power | kW |
| Auto Reset Tries Left | Remaining auto-reset attempts after trip | count |
| Contactor | OPEN/CLOSE control and status | — |

---

## Page 5: Fig. 3 — HVPS Panel

> Screenshot of the EPICS Klystron HVPS (High Voltage Power Supply) panel. OCR confirmed station "HPR RF 8-3" (likely HER RF 8-3) as the displayed station.

### HVPS Readbacks

| Parameter | Description | Typical Units |
|-----------|-------------|:---:|
| HVPS Voltage | Measured high voltage output | kV |
| HVPS Current | Measured beam current | A |
| HVPS Power | Calculated HVPS power (V × I) | MW |
| Efficiency | Klystron RF efficiency | % |

### HVPS Controls

| Control | Function |
|---------|----------|
| HVPS Loop OFF/PROC/ON | Selects HVPS voltage regulation mode |
| Contactor OPEN/CLOSE | Controls main contactor |
| Voltage Setpoint | Requested HVPS voltage |

### Manual Reset Interlocks

> These interlocks require physical RESET button on HVPS SMART TOUCH panel (rack 2):

| Interlock | Description |
|-----------|-------------|
| Crowbar | Over-voltage/over-current protection fired |
| Transformer Overtemp | HVPS transformer temperature exceeded |
| Waveguide Pressure | Waveguide SF₆ gas pressure low |
| Beam Abort | Beam abort signal received |

---

## Page 6: Fig. 4 — FEEDBACK Panel

> Screenshot of the EPICS FEEDBACK panel (station shown: HER RF 8-3).

The FEEDBACK panel displays the status and controls for all feedback loops. OCR confirmed "Feedback" as the panel title and fragments consistent with loop status indicators.

### Loop Status Display

| Loop | Bandwidth | Status Indicator | MATLAB Config Button |
|------|-----------|:---:|:---:|
| **Direct Loop** | 800 kHz | ON/OFF | "ConfDirect" |
| **Comb Loop** | 2 MHz (1-turn delay) | ON/OFF | "Config Comb" |
| **Tuner Loop** | Slow (stepping motor) | ON/OFF | "Tune Cavs" |
| **HVPS Loop** | ~1 Hz | ON/OFF | — |
| **DAC Loop** | 0.1 Hz | ON/OFF | — |
| **Ripple Loop** | Low BW | ON/OFF | — |
| **Gap FF Loop** | ~1000 revolutions adapt | ON/OFF | — |
| **LFB Woofer** | — | ON/OFF | "ConfWoofer" |

### Loop Option Buttons

| Option | Applies To | Function |
|--------|-----------|----------|
| Frequency Offset Tracking | Direct Loop | Compensates phase shift from cavity detuning |
| Integral Compensation | Direct Loop | Smooths HVPS ripple |
| Lead Compensation | Direct Loop | Increases bandwidth and gain |

### Measurement / Diagnostic Buttons

| Button | Function |
|--------|----------|
| "MeasDirCls" | Measures closed-loop response of Direct + Comb loops (non-invasive) |
| "Make Equal" | Creates group delay equalizer for Comb and Woofer |
| "Make Poly" | Creates resonance frequency vs. tuner position polynomial |
| "Phase Stns" | Optimized station phasing (requires beam > 100 mA) |

---

## Page 7: OFF Mode and Cavity Processing

**OFF mode:** Turns RF off with the HVPS contactor closed and fires beam abort; cavity tuners are left in their previous position.

**Processing cavities:**

After an intentional or accidental vent or long shutdown, cavities are processed first in **ON_FM** mode at **1000 Hz** and then in **ON_CW** mode using the HVPS Loop OFF/PROC/ON buttons in **PROC**. In the PROC mode the station will automatically step up the HVPS voltage until one of the limiting parameters is reached and steps the voltage down when the limit is passed.

The following table gives the nominal limit parameters:

| Parameter | HER FM | HER CW | LER FM | LER CW |
|-----------|--------|--------|--------|--------|
| Max Cav Vacuum (Torr) | 1E-8 | 1E-8 | 1E-8 | 1E-8 |
| Max Cav Gap Volt (kV) | 800 | 750 | 900 | 850 |
| Max Klys Fwd Pwr (kW) | 540 | 450 | 330 | 290 |

---

> **Transcription Note (v2)**: Improved via multi-pass OCR (Tesseract 5.3.0 at 450 DPI, PSM 4/6 with OTSU thresholding and inverted preprocessing) from the scanned image-based PDF `ps3403305900.pdf`. Text pages (1–2, 7) extracted at high confidence. EPICS panel screenshots (pages 3–6) produced limited raw OCR text; panel contents have been reconstructed as structured tables using confirmed OCR fragments (panel titles, station IDs, notes) combined with PEP-II LLRF domain knowledge of standard EPICS control panels. Parameter names reflect standard PEP-II RF station EPICS conventions. Consult the original PDF for exact panel layouts and numerical values displayed at time of screenshot capture.

