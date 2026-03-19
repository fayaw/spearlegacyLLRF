# PEP II Power Supply — Presentation Transcription

**Original Document:** `pepII supply.pptx`
**Document Type:** PowerPoint Presentation (24 slides)
**Footer on all slides:** SLAC Klystron Power Supply
**Date on all slides:** 12/3/2024
**Transcription Method:** python-pptx text extraction + Tesseract OCR on rendered slides and embedded images

---

## Slide 1 — Title Slide

### Pep II Power supply

> **[Image — Left side]:** Photograph of the power supply transformer tank installation, showing the large oil-filled transformer enclosure on an outdoor concrete pad.

> **[Image — Right side]:** Photograph showing the internal view of the power supply components, including transformer windings, filter inductors, and capacitor assemblies.

> **[Logo — Bottom right]:** Power Conversion Department logo

---

## Slide 2 — Klystron Power Supply Specifications

### Klystron Power Supply Specifications

- 90kV 27A DC Continues 2.5MW
- Regulation & Ripple < ±0.5% @ >65kV.
- Protect Klystron under Klystron Arc (Important).
- Continues Control of Output Voltage.
- Fit on existing transformer pads.
- Cost effective.

---

## Slide 3 — Pep II Power supply (Topology Comparison)

### Pep II Power supply

> **[Embedded OLE Object — Circuit Diagram]:**
> Comparison diagram showing two circuit topologies:
>
> **Left: "CONVENTIONAL CIRCUIT DRY INDUCTOR L-C FILTER"**
> - Shows standard rectifier with filter inductor and filter capacitor in series-parallel configuration
> - Filter inductor → Filter capacitor → Load
>
> **Right: "STAR POINT CONTROL"**
> - Shows the star point controller topology with filter inductor in primary
> - Filter inductor on input side
> - Inductor bypass path
> - Filter capacitor on secondary
> - Demonstrates the key difference: inductor bypass capability for fault protection

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 4 — Pep II Power supply (Full Schematic)

### Pep II Power supply

> **[Embedded OLE Object — Complete Power Supply Schematic]:**
> Full system block/circuit diagram showing:
>
> - **Input:** 12.5KV 3PH, 3000 KVA
> - **Disconnect & Breaker**
> - **Phase Shifting Transformer**
> - **Thyristor Controlled (SCR Phase Controlled Rectifier)** — 12 phase, 8 pulse configuration
> - **Filter Inductor**
> - **Rectifier Transformer**
> - **Rectifiers:** 30KV 30A
> - **Filter Resistors:** 500 OHMS 1KW
> - **Capacitors:** 8uFD 30KV
> - **Filter Rectifiers:** 30KV 3A AVE
> - **Crowbar:** 100KV 80KA
> - **Termination Tank**
> - **Output Bushings: 90KV**
> - **Output to Klystron:** 90KV, 27 AMPS
>
> Label: **PEP-II KLYSTRON POWER SUPPLY**

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 5 — Pep II Power supply (Photograph 1)

### Pep II Power supply

> **[Image (6.2" × 4.6")]:** Large photograph of the power supply installation, showing the transformer tank and associated equipment on the outdoor pad. Visible components include the main transformer enclosure, high-voltage bushings, cooling radiators, and cable terminations.

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 6 — Pep II Power supply (Operational Display)

### Pep II Power supply

> **[Image (7.1" × 4.5")]:** Photograph of the power supply operational monitoring display/screen showing real-time readings:
> - **HR@1:** 80 KV, 22.4A, 1.81MW
> - Multiple BNC channel displays (BNC1, BNC10, BNC MATH)
> - Channel scales: 1 V/div dc, 5 V/div dc, 5 V/div dc, 20 V/div/div, 1 mV/div dc
> - Time scales: 4 ms/div for multiple channels
> - Date code: 020103
> - Frequency reference: 200 Hz

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 7 — Pep II Power supply (Filter Waveform)

### Pep II Power supply

> **[Image (7.1" × 4.5")]:** Oscilloscope waveform display showing filter inductor characteristics:
> - **Channel labels:** Math traces
> - **1) Math:** +200 uW (microhenry measurement)
> - **2) Math:** 200uy 360 Hz — Filter inductor measurement at 360 Hz
> - Multiple overlapping waveforms showing inductor voltage and current relationship
> - Grid-based oscilloscope display with time and amplitude divisions

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 8 — Pep II Power supply (Output Ripple at High Voltage)

### Pep II Power supply

> **[Image (6.4" × 5.1")]:** Oscilloscope capture labeled **"KLYSTRON POWER SUPPLY"** showing three waveforms:
> - **Top trace:** 60KV DC — DC Ripple Voltage
> - **Middle trace:** Filter Inductor Voltage (shows 12-pulse ripple pattern)
> - **Bottom trace:** Transformer Line Voltage (stepped waveform)
> - **Time scale:** 2 ms/div

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 9 — Power Supply Waveforms

### Power supply waveforms

Two oscilloscope captures side by side:

> **[Left Image — "Inductor voltage, Line current (AC)"]:**
> Tektronix oscilloscope display (Trig'd mode):
> - CH1: 20.0V, CH2: 200V — showing inductor voltage and AC line current
> - CH3: 2.00V, CH4: 100V
> - Time scale: M 2.50ms
> - Trigger: AC Line
> - Date: 21-Aug-07 07:53, 60.0Hz

> **[Right Image — "Three Line Voltages (note overlap)"]:**
> Tektronix oscilloscope display (Trig'd mode):
> - CH1: 500V, CH2: 5.00V
> - Time scale: M 2.50ms
> - Trigger: AC Line
> - Shows three overlapping line voltage waveforms demonstrating 12-pulse operation

---

## Slide 10 — Pep II Power supply (Output Ripple at Lower Voltage)

### Pep II Power supply

> **[Image (6.5" × 5.1")]:** Oscilloscope capture labeled **"KLYSTRON POWER SUPPLY"** showing three waveforms at reduced output voltage:
> - **Top trace:** DC Ripple Voltage
> - **Middle trace:** Filter Inductor Voltage (larger ripple at lower voltage due to SCR phase-back)
> - **Bottom trace:** Transformer Line Voltage
> - **Time scale:** 2 ms/div

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 11 — Transformer Phase Voltages

### Transformer Phase Voltages

Two oscilloscope captures side by side:

> **[Left Image — "Three Core Voltages 'Lower'"]:**
> Tektronix oscilloscope display (Trig'd mode):
> - CH1: 5.00V, CH2: 5.00V
> - Time scale: M 2.50ms
> - Trigger: AC Line
> - Date: 21-Aug-07 08:05, 60.0Hz
> - Shows three-phase voltage waveforms from the "lower" transformer secondary

> **[Right Image — "Three Core Voltages 'Upper'"]:**
> Tektronix oscilloscope display (Trig'd mode):
> - CH1: 3.00V, CH2: 5.00V
> - Time scale: M 2.50ms
> - Trigger: AC Line
> - Shows three-phase voltage waveforms from the "upper" transformer secondary

---

## Slide 12 — Pep II Power supply (AC Current)

### Pep II Power supply

**Label:** AC CURRENT

> **[Image (4.4" × 4.1")]:** Oscilloscope capture showing the AC input current waveform of the power supply:
> - Time scale: 4 ms/div
> - Shows the characteristic 12-pulse rectifier current waveform with reduced harmonic content

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 13 — Pep II Power supply (Klystron Arc Response)

### Pep II Power supply

> **[Image (4.8" × 4.6")]:** Oscilloscope capture labeled **"KLYSTRON ARC VOLTAGE/CURRENT"** showing the power supply response during a klystron arc event:
> - **KLYSTRON ARC VOLTAGE:** 10KV/DIV — Shows rapid voltage collapse during arc
> - **KLYSTRON ARC CURRENT:** Shows current spike during arc event
> - **Time scale:** 40us/div
> - Demonstrates the arc protection performance of the power supply

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 14 — Pep II Power supply (AC Current During Arc)

### Pep II Power supply

> **[Image (5.4" × 5.1")]:** Oscilloscope capture labeled **"AC CURRENT WITH KLYSTRON ARC"** showing:
> - **0V** reference line
> - **AC CURRENT:** 10AMP/DIV — Shows primary current response during klystron arc
> - **KLYSTRON VOLTAGE:** 10kV/Div — Shows voltage collapse
> - **Time scale:** 2.5 ms/div
> - Demonstrates that primary current only approximately doubles for ~2ms before SCR turn-off

---

## Slide 15 — Pep II Power supply (Light Triggered Thyristor)

### Pep II Power supply

> **[Image (4.9" × 4.4", WMF format)]:** Oscilloscope captures showing light-triggered thyristor characteristics:
> - **Trigger:** VOL 5 uSEC
> - **Panel A:** Current 40A/div: 20 VOL 5 uSEC; Voltage 5kV/div: 5 VOL 5 uSEC
> - **Panel B:** Trigger: 1 VOL 5 uSEC TD; Current 40 A/div: 20 VOL 5 uSEC; Voltage 5kV/div: 5 VOL 5 uSEC
> - Shows fast turn-on characteristics of light-triggered SCRs

**Label:** Light Triggered delay ~1 usec
Independent of Voltage

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 16 — Present SCR Crowbar Delay

### Present SCR Crowbar Delay

Two oscilloscope captures side by side:

> **[Left Image (4.6" × 3.6", WMF)]:** Crowbar trigger waveform showing:
> - 1) Klystron Voltage 10Kv/div: 14, 5 us
> - 2) Arc Current 20A/div: 1V, 5 us
> - 3) Trigger: 30 V, 5 us
> - Shows crowbar SCR trigger delayed ~50 μs

> **[Right Image (4.6" × 3.6", WMF)]:** Crowbar trigger waveform (reversed driver) showing:
> - 2) Klystron Voltage delayed: 500 mV, 5 us
> - 3) Trigger normal: 50 V, 5 us
> - 4) Klystron Voltage normal: 500 mV, 5 us
> - Trigger delay: ~50 μs, 500 μs total

**Label:** Present Crowbar Trigger — Normal and reversed driver

---

## Slide 17 — SCR Crowbar Trigger Delay

### SCR Crowbar Trigger Delay

Two oscilloscope captures side by side:

> **[Left Image (4.5" × 3.9", WMF) — "Normal SCR Triggered Crowbar"]:**
> - 1) Klystron Voltage 10Kv/div: 14, 5 us
> - 2) Arc Current 20A/div: 1V, 5 us
> - 3) Trigger: 50V, 5 us
> - Shows standard electrically-triggered SCR crowbar response

> **[Right Image (4.5" × 3.8", WMF) — "Light Triggered SCR Crowbar"]:**
> - 1) Crowbar Current 20A/div: 20V, 5 us
> - 2) Klystron Voltage 10KV/Div: 1M, 5 us
> - Shows faster response with light-triggered SCR crowbar
> - Demonstrates reduced trigger delay compared to normal SCR

---

## Slide 18 — Control Wiring (Trigger Enclosure)

### Control wiring

> **[Image (8.3" × 5.2", WMF)]:** Schematic wiring diagram of the **TRIGGER ENCLOSURE WIRING** showing:
>
> **Components and connections:**
> - **PS4** — Power supply reference
> - **SLORA** — Signal routing
> - **A-1794-THERMO** — Temperature monitoring
> - **RETARDDEM** — Retard/delay module
> - **SIGBOARD** — Signal board
> - **TO KLYSTRON CONTROLS** — Output connections to klystron control system
>
> **Reference:**
> - LOCAL CONTROL PANEL
> - Drawing: WD-730-790-02

---

## Slide 19 — Control Wiring (Interconnection Diagram)

### Control wiring

> **[Image (7.2" × 5.4", WMF)]:** Detailed **2MW KLYSTRON TEST STAND POWER SUPPLY INTERCONNECTION WIRING** diagram showing:
>
> **Major Junction Boxes and Enclosures:**
> - **HOFFMAN 12X10** (×2) — Junction boxes
> - **SCR TRIGGERS** — HOFFMAN 12X10
> - **PWR SUPP REGULATOR** — HOFFMAN BOX 34X42
>
> **Signal/Control Connections:**
> - DC Voltage monitoring
> - ARC FAULT
> - OIL-LEVEL sensing
> - CROWBAR control
> - CONTACTOR CONTROLS (ETO)
> - CONTACTOR CLOSED / CONTACTOR DISCONNECT status
> - PERSONNEL PROTECTION
>
> **Equipment Connections:**
> - CROWBAR SCR's
> - NWL TRANSFORMER (NWL #39308)
> - TRANSFORMER INTERLOCKS
> - TRANSFORMER MONITORS
> - PHASE SCR's
> - TERMINATION TANK
>
> **Cabling:**
> - BELDING 83715 15C #16 TEFLON
> - BELDING 83709 9C #16 TEF
> - #6 TWISTED SHIELDED
>
> **Terminal Blocks:** TB1, TB2, TB3, TB4, TB5, TEB4
>
> **Reference Drawing:** WD-730-790-01
> **Title:** TERMINAL STRIP LAYOUT / PWR SUPP CONTROLS

---

## Slide 20 — Control Wiring (Power Circuit Schematic)

### Control wiring

> **[Image (7.1" × 5.6", WMF)]:** Power circuit schematic diagram showing:
>
> **Components:**
> - **D1, D1:** Diode pairs — 25KV 100A (×2)
> - **L1, L2:** Filter inductors — 350 UHY 40A (each)
> - **C1:** Capacitor — 10 NFD 56KV
> - **C2:** Capacitor — 10 NFD 56KV
> - **C3:** Capacitor
> - **DANFYSIK DC-CT:** DC current transformer for output current measurement
> - **Output:** +OUT FOR POS CURRENT
> - **POWER SUPPLY 10 NFD 56KV**
> - **ROSS-GRN-SW:** Safety ground switch
> - **50 OHM 90KV** — Bleeder/discharge resistor
>
> **Monitoring:**
> - **LEV3 OIL-LEVEL** — Oil level sensor
> - **10A/V PERSON 110** — Personnel protection
> - Status indicators: +15v, status +, status -
>
> **Connectors:**
> - Output: GRN, RED, BLK, WHT color-coded wiring
> - MS3102R18-1P connector
>
> **Termination Tank Components:**
> - Resistor strings (shown as VVV pattern)
> - Capacitor bank connections

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 21 — Control Wiring (Crowbar Assembly Drawing)

### Control wiring

> **[Image (5.8" × 5.7")]:** Detailed mechanical assembly drawing of the **Crowbar** SCR stack showing numbered component parts:
>
> **Parts List:**
> 1. Crowbar threaded rod
> 2. Jam Nut Steel
> 3. Spherical Washer concave
> 4. Trigger Coil
> 5. Ferrit Rod (2ea)
> 6. Crowbar Drive End
> 7. Belleville washers
> 8. Diode (1 ea)
> 9. Split Ring (3ea)
> 10. End Block (2ea)
> 11. Spherical Washer (6ea)
> 12. Aluminum Castings (8ea)
> 13. Tension Rod
> 14. ZnO (varistor elements)
> 15. (Additional components)
> 16. Spherical Washer concave
> 17. Washer Pad Small (2ea)
> 18. ZnO [120V ea]
> 19. (Continuation)
> 20. Mi (continued)
> 21. Washer Pad large (2ea)
> 22. Ferrit Ring
> 23. Red Split ring (2ea)
> 24. Spherical Washer concave
> 25. Threaded End Long

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 22 — Control Wiring (SCR Stack Assembly)

### Control wiring

> **[Image (5.6" × 5.4")]:** Assembly drawing of the **SCR stack** showing numbered component parts:
>
> **Parts List:**
> 1. Jam Nut Steel
> 2. Spherical Washer concave
> 3. Tension Rod
> 4. SCR's (6, 2ea)
> 5. Washer Pad Small (2ea)
> 6. Washer Pad large (2ea)
> 7. Spherical Washer concave
> 8. Red Split ring (2ea)
> 9. Threaded End Long
> 10. Aluminum Castings (8ea)
> 11. Spacer (6 ea)

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 23 — Control Wiring (SCR Phase Controller Stack Assembly)

### Control wiring

> **[Image (4.9" × 5.1")]:** Assembly drawing of the **SCR Phase Controller** stack showing numbered component parts:
>
> **Parts List:**
> 1. Trigger Coil
> 2. Red Split ring (2ea)
> 3. Ferrit Rod (2ea)
> 4. Ferrit Ring
> 5. Aluminum Castings (8ea)
> 6. End Block (2ea)
> 7. Threaded End short
> 8. SCR end part
> 9. Split Ring (3ea)
> 10. Washer Pad Small (2ea)
> 11. Tension Rod
> 12. Washer Pad large (2ea)
> 13. SCR's (14 ea)
> 14. ZnO 2.5KV (14 ea)
> 15. ZnO 120V (ea)
> 16. Spherical Washer (6ea)
> 17. Flat Washer
> 18. Belleville washers
> 19. Jam Nut Steel
> 20. Spherical Washer concave
> 21. Threaded End Long

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 24 — Control Wiring (SCR Controller Overview)

### Control wiring

> **[Image (4.7" × 5.7")]:** Simplified block/wiring diagram showing the **SCR 6B CONTROLLER** overview:
> - Shows the complete SCR controller assembly layout
> - Overall system interconnection view

> **[Logo — Bottom right]:** Power Conversion Department

