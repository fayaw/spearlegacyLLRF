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

## Pages 3–7: EPICS Panel Screenshots and Additional Procedures

### Page 3: Fig. 1 — KLYSTRON Panel

*[Screenshot of EPICS KLYSTRON control panel showing klystron and circulator status, description, cavities, power, and feedback sections]*

> **Note:** The solenoid and the filament ON/OFF buttons are now combined into a single ON/OFF button.

### Page 4: Fig. 2 — RF STATION Panel

*[Screenshot of EPICS RF STATION panel (HER RF 12-4) showing station control interface]*

### Page 5: Fig. 3 — HVPS Panel

*[Screenshot of EPICS HVPS panel]*

### Page 6: Fig. 4 — FEEDBACK Panel

*[Screenshot of EPICS FEEDBACK panel]*

### Page 7: Fig. 5 — FEEDBACK Options / Additional Controls

*[Screenshot of additional EPICS feedback loop control options]*

> **Note:** Pages 3–7 are primarily screenshots of EPICS control panels. Due to OCR limitations on graphical interface screenshots, the detailed labels and values within these panels are not reliably extractable. Consult the original PDF for accurate panel layouts.

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `ps3403305900.pdf`. Text content on pages 1–2 is high confidence. Pages 3–7 contain EPICS control panel screenshots with limited extractable text; the original PDF should be consulted for accurate panel details.

