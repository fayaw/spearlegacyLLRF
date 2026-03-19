# PEP II Power Supply — Presentation Transcription

**Original Document:** `pepII supply.pptx`
**Document Type:** PowerPoint Presentation (24 slides)
**Footer on all slides:** SLAC Klystron Power Supply
**Date on all slides:** 12/3/2024
**Transcription Method:** python-pptx text extraction + Tesseract OCR on 300 DPI rendered slides and embedded images

---

## Slide 1 — Title Slide

### Pep II Power supply

> **[Image — Left (4.9" × 4.0")]:** Photograph of the power supply transformer tank installation, showing the large oil-filled transformer enclosure on an outdoor concrete pad with high-voltage bushings visible on top.

> **[Image — Right (3.4" × 5.1")]:** Photograph showing the internal view of the power supply components from above, including transformer windings, filter inductors, and capacitor assemblies arranged inside the oil tank.

> **[Logo — Bottom right]:** Power Conversion Department

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

## Slide 3 — Pep II Power supply (Circuit Topology Comparison)

### Pep II Power supply

> **[Embedded OLE Object — Four-Quadrant Circuit Topology Comparison Diagram]:**
>
> The slide presents four circuit topologies arranged in a 2×2 grid:
>
> **Top Left: "CONVENTIONAL CIRCUIT — DRY INDUCTOR L-C FILTER"**
> - Standard rectifier topology
> - INPUT → INDUCTOR → FILTER CAPACITOR → LOAD
> - Filter inductor and filter capacitor in series-parallel configuration
>
> **Top Right: "NORMAL CIRCUIT — STAR POINT CONTROL"**
> - Star point controller with filter inductor on input side
> - INPUT → INDUCTOR → CAPACITOR → LOAD
> - Filter inductor on primary side
>
> **Bottom Left: "PROPOSED CIRCUIT"**
> - Modified topology with FILTER INDUCTOR on primary side
> - Includes INDUCTOR BYPASS path
> - INPUT → FILTER INDUCTOR → Load path with bypass capability
>
> **Bottom Right: "ACTUAL CIRCUIT"**
> - Final implemented design
> - FILTER INDUCTOR on primary with INDUCTOR BYPASS
> - Separate FILTER CAPACITOR path on secondary
> - LOAD connected through isolating configuration
>
> Key difference demonstrated: The star point control and actual circuit allow the filter inductor to be bypassed under fault conditions, which is critical for klystron arc protection.

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 4 — Pep II Power supply (Complete Power Supply Schematic)

### Pep II Power supply

> **[Embedded OLE Object — Complete PEP-II Klystron Power Supply Schematic]:**
>
> **Title: PEP-II KLYSTRON POWER SUPPLY**
>
> Full system block/circuit diagram showing signal flow from left to right:
>
> **Input (Left):**
> - 12.5KV 3PH, 3000 KVA input
> - DISCONNECT & BREAKER
>
> **Phase Shifting & Control:**
> - PHASE SHIFTING TRANSFORMER
> - THYRISTOR CONTROLLED RECTIFIER (SCR Phase Controlled) — 40KV 80A
>
> **Filtering:**
> - FILTER INDUCTOR
>
> **Rectifier/Transformer Section:**
> - RECTIFIER TRANSFORMER
> - RECTIFIERS: 30KV 30A
> - FILTER RESISTORS: 500 OHMS 1KW
> - CAPACITORS: 8uFD 30KV
> - FILTER RECTIFIERS: 30KV 3A AVE
>
> **Output/Protection:**
> - CROWBAR: 100KV 80KA
> - TERMINATION TANK
> - Output Bushings: 90KV
>
> **Output (Right):**
> - KLYSTRON: 90KV, 27 AMPS
> - Output voltage taps: -90KV (cathode), -77KV, -52KV, -26KV

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 5 — Pep II Power supply (Installation Photograph)

### Pep II Power supply

> **[Image (6.2" × 4.6")]:** Large photograph of the completed power supply installation on an outdoor concrete transformer pad. Visible features include:
> - Main transformer oil tank enclosure
> - High-voltage bushings protruding from top
> - Cooling radiator panels on the sides
> - Cable terminations and connections
> - Concrete pad mounting

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 6 — Pep II Power supply (Operational Monitoring Display)

### Pep II Power supply

> **[Image (7.1" × 4.5")]:** Photograph of the power supply operational monitoring/control display screen showing real-time power readings:
>
> **Main Reading:**
> - **HR@1:** 80 KV, 22.4A, 1.81MW
>
> **Channel Configuration:**
> | Channel | Scale | Time Base |
> |---------|-------|-----------|
> | BNC1 | 1 V/div dc | 4 ms/div |
> | BNC10 | 5 V/div dc | 4 ms/div |
> | BNC MATH | 5 V/div dc | 4 ms/div |
> | (additional) | 20 V/div/div | 4 ms/div |
> | (additional) | 1 mV/div dc | — |
>
> - Date code: 020103
> - Frequency reference: 200 Hz
> - cB (calibration indicator)

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 7 — Pep II Power supply (Filter Inductor Waveform Measurement)

### Pep II Power supply

> **[Image (7.1" × 4.5")]:** Oscilloscope waveform display showing filter inductor characteristics:
>
> **Math Channel Traces:**
> - **1) Math:** +200 uW SGO-FER (filter measurement at inductor)
> - **2) Math:** 200 uY 360 Hz — Filter inductor incremental inductance measurement at 360 Hz ripple frequency
>
> Grid-based oscilloscope display with multiple overlapping waveforms showing:
> - Inductor voltage ripple waveform
> - Current waveform through inductor
> - Time and amplitude divisions marked on grid

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 8 — Pep II Power supply (Output Ripple at 60KV)

### Pep II Power supply

> **[Image (6.4" × 5.1")]:** Oscilloscope capture labeled **"KLYSTRON POWER SUPPLY"** showing three waveforms at **60KV** output voltage:
>
> - **Top trace: 60KV DC** — DC Ripple Voltage (shows larger ripple due to SCR phase-back at reduced voltage)
> - **Middle trace:** Filter Inductor Voltage — shows 12-pulse ripple pattern with larger amplitude at this reduced operating point
> - **Bottom trace:** Transformer Line Voltage — stepped waveform showing transformer secondary voltage
> - **Time scale:** 2 ms/div

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 9 — Power Supply Waveforms

### Power supply waveforms

Two Tektronix oscilloscope captures side by side:

> **[Left Image — "Inductor voltage, Line current (AC)"]:**
> Tektronix digital oscilloscope display (Trig'd mode):
> - **M Pos:** -800.0 μs
> - CH1: 20.0V — Inductor voltage
> - CH2: 200V — AC line current
> - CH3: 2.00V
> - CH4: 100V
> - **Time scale:** M 2.50ms
> - **Trigger:** AC Line
> - **Date:** 21-Aug-07 07:53, 60.0Hz

> **[Right Image — "Three Line Voltages (note overlap)"]:**
> Tektronix digital oscilloscope display (Trig'd mode):
> - **M Pos:** -800.0 μs
> - CH1: 500V
> - CH2: 5.00V
> - **Time scale:** M 2.50ms
> - **Trigger:** AC Line
> - Shows three overlapping line voltage waveforms demonstrating 12-pulse operation with phase overlap between upper and lower transformer secondaries

---

## Slide 10 — Pep II Power supply (Output Ripple at 85KV)

### Pep II Power supply

> **[Image (6.5" × 5.1")]:** Oscilloscope capture labeled **"KLYSTRON POWER SUPPLY"** showing three waveforms at **85KV** output voltage (near full output):
>
> - **Top trace: 85KV DC** — DC Ripple Voltage (smaller ripple at near-full voltage)
> - **Middle trace:** Filter Inductor Voltage — shows 12-pulse ripple pattern
> - **Bottom trace:** Transformer Line Voltage — stepped waveform
> - **Time scale:** 2 ms/div

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 11 — Transformer Phase Voltages

### Transformer Phase Voltages

Two Tektronix oscilloscope captures side by side:

> **[Left Image — "Three Core Voltages 'Lower'"]:**
> Tektronix digital oscilloscope display (Trig'd mode):
> - **M Pos:** -800.0 μs
> - CH1: 5.00V
> - CH2: 5.00V
> - **Time scale:** M 2.50ms
> - **Trigger:** AC Line
> - **Date:** 21-Aug-07 08:05, 60.0Hz
> - Shows three-phase voltage waveforms from the "lower" transformer secondary (T2-S2, 10.5KV)

> **[Right Image — "Three Core Voltages 'Upper'"]:**
> Tektronix digital oscilloscope display (Trig'd mode):
> - **M Pos:** -800.0 μs
> - CH1: 3.00V (or 5.00V — scale varies)
> - CH2: 5.00V
> - **Time scale:** M 2.50ms
> - **Trigger:** AC Line
> - Shows three-phase voltage waveforms from the "upper" transformer secondary (T1/T2-S1, 21KV)

---

## Slide 12 — Pep II Power supply (AC Line Current)

### Pep II Power supply

**Label:** AC CURRENT

> **[Image (4.4" × 4.1")]:** Oscilloscope capture showing the AC input current waveform of the power supply:
>
> **Oscilloscope scales:**
> - Vertical: 9.5V reference, 5V/div
> - Horizontal: 4 ms/div (full sweep: 20.04ms — approximately one 60Hz cycle)
> - Cursor/marker: 40μs
>
> Shows the characteristic 12-pulse rectifier current waveform with reduced harmonic content compared to 6-pulse operation. The waveform shows the stepped current shape typical of a phase-controlled thyristor rectifier.

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 13 — Pep II Power supply (Klystron Arc Voltage & Current Response)

### Pep II Power supply

> **[Image (4.8" × 4.6")]:** Oscilloscope capture labeled **"KLYSTRON ARC VOLTAGE/CURRENT"** showing the power supply response during a klystron arc event:
>
> **Trace details:**
> - **KLYSTRON ARC VOLTAGE:** 10KV/DIV — Shows rapid voltage collapse from ~40kV operating voltage
> - **KLYSTRON ARC CURRENT:** 20 AMP/DIV — Shows current spike during arc event
>
> **Scale/Timing:**
> - Voltage scale: /div markers visible
> - Arc initiation: ~19.8 μs
> - **Time scale:** 10μs/div
> - Total capture window: ~80.4 μs
> - Voltage collapse from ~80KV to ~0 visible
>
> Demonstrates the arc protection performance — the SCR crowbar fires and energy to the klystron is limited.

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 14 — Pep II Power supply (AC Current During Klystron Arc)

### Pep II Power supply

> **[Image (5.4" × 5.1")]:** Oscilloscope capture labeled **"AC CURRENT WITH KLYSTRON ARC"** showing:
>
> **Trace details:**
> - **0V** reference line at top
> - **AC CURRENT:** 10AMP/DIV — Shows primary AC current response during klystron arc
> - **KLYSTRON VOLTAGE:** 10kV/Div — Shows voltage collapse (100kV scale)
>
> **Key observations:**
> - Primary current rate of rise limited by filter inductor
> - Current approximately doubles for ~2ms before SCR turn-off
> - Complete interruption of primary current takes 4-8 ms
> - **Time scale:** 2.5 ms/div

---

## Slide 15 — Pep II Power supply (Light Triggered Thyristor Characteristics)

### Pep II Power supply

> **[Image (4.9" × 4.4", WMF format)]:** Dual oscilloscope capture showing light-triggered thyristor turn-on characteristics:
>
> **Panel A (top):**
> - 1) Trigger: 1 VOL 5 uSEC
> - 2) Current 40A/div: 20 VOL 5 uSEC
> - 3) Voltage 5kV/div: 5 VOL 5 uSEC
>
> **Panel B (bottom):**
> - 4) Trigger: 1 VOL 5 uSEC (with time delay marker TD)
> - 5) Current 40A/div: 20 VOL 5 uSEC
> - 6) Voltage 5kV/div: 5 VOL 5 uSEC
>
> Both panels show the thyristor turn-on transient at different operating voltages.

**Text Labels:**
- Light Triggered delay ~1 usec
- Independent of Voltage

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 16 — Present SCR Crowbar Delay

### Present SCR Crowbar Delay

Two oscilloscope captures side by side:

> **[Left Image (4.6" × 3.6", WMF)]:** Present crowbar trigger waveform:
> - 1) Klystron Voltage 10Kv/div: 14V, 5 us
> - 2) Arc Current 20A/div: 1V, 5 us
> - 3) Trigger: 30 V, 5 us
> - Shows crowbar SCR trigger with measurable delay

> **[Right Image (4.6" × 3.6", WMF)]:** Crowbar trigger waveform with normal and reversed driver:
> - 2) Klystron Voltage delayed: 500 mV, 5 us
> - 3) Trigger normal: 50 V, 5 us
> - 4) Klystron Voltage normal: 500 mV, 5 us
> - Trigger delay shown: ~50 μs

**Text Labels:**
- Present Crowbar Trigger
- Normal and reversed driver

---

## Slide 17 — SCR Crowbar Trigger Delay

### SCR Crowbar Trigger Delay

Two oscilloscope captures side by side comparing normal vs. light-triggered SCR crowbar:

> **[Left Image (4.5" × 3.9", WMF) — "Normal SCR Triggered Crowbar"]:**
> - 1) Klystron Voltage 10Kv/div: 1V, 5 us
> - 2) Arc Current 20A/div: 1V, 5 us
> - 3) Trigger: 50V, 5 us
> - Shows standard electrically-triggered SCR crowbar response with longer delay

> **[Right Image (4.5" × 3.8", WMF) — "Light Triggered SCR Crowbar"]:**
> - 1) Crowbar Current 20A/div: 20V, 5 us
> - 2) Load Current 20A/div: 20V, 5 us
> - 3) Trigger: (marker)
> - 4) Kly Voltage 20kV/Div: 1M, 5 us
> - 5) Kly Voltage (additional scale): 4kV, 5 us
> - Shows faster response with light-triggered SCR — reduced trigger delay compared to normal SCR

---

## Slide 18 — Control Wiring (Trigger Enclosure)

### Control wiring

> **[Image (8.3" × 5.2", WMF)]:** Schematic wiring diagram of the **TRIGGER ENCLOSURE WIRING** showing:
>
> **Major Components and Connections:**
> - **PS4** — Power supply reference module
> - **SLORA** — Signal routing/logic module
> - **A-1794-THERMO** — Temperature monitoring/thermocouple module
> - **RETARDDEM** — Retard/delay timing module
> - **SIGBOARD** — Signal conditioning board
> - **TO KLYSTRON CONTROLS** — Output connections to klystron control system
>
> **Reference Drawing:**
> - LOCAL CONTROL PANEL
> - Drawing number: WD-730-790-02

---

## Slide 19 — Control Wiring (Interconnection Diagram)

### Control wiring

> **[Image (7.2" × 5.4", WMF)]:** Detailed **2MW KLYSTRON TEST STAND POWER SUPPLY INTERCONNECTION WIRING** diagram.
>
> **Drawing Reference:** WD-730-790-01, R. CASSEL
>
> **Major Junction Boxes and Enclosures:**
> - **HOFFMAN 12X10** (×2) — Junction boxes for SCR triggers and monitoring
> - **SCR TRIGGERS** — HOFFMAN 12X10
> - **PWR SUPP REGULATOR** — HOFFMAN BOX 34X42
>
> **Signal/Control Connections:**
> - DC Voltage monitoring (with BNC-2 connector)
> - ARC FAULT signal
> - OIL-LEVEL sensing (LEV2)
> - CROWBAR control
> - CONTACTOR CONTROLS (ETO)
> - CONTACTOR CLOSED / CONTACTOR DISCONNECT / CONTACTOR READY status
> - PERSONNEL PROTECTION interlocks
> - LOCKING RELAY
> - TSTRIP24B RESET
> - TEMP monitoring
>
> **Equipment Connections:**
> - CROWBAR SCR's
> - NWL TRANSFORMER (NWL #39308)
> - TRANSFORMER INTERLOCKS
> - TRANSFORMER MONITORS
> - PHASE SCR's
> - TERMINATION TANK
>
> **Cabling Specifications:**
> - BELDING 83715 15C #16 TEFLON
> - BELDING 83709 9C #16 TEF
> - #6 TWISTED SHIELDED
>
> **Terminal Blocks:** TB1, TB2, TB3, TB4, TB5, TEB4
>
> **Bottom Labels:**
> - TERMINAL STRIP LAYOUT
> - PWR SUPP CONTROLS
> - DISPLAY
> - o FAULT indicator

---

## Slide 20 — Control Wiring (Power/Termination Tank Circuit Schematic)

### Control wiring

> **[Image (7.1" × 5.6", WMF)]:** Detailed power circuit schematic of the termination tank and output section:
>
> **High-Voltage Components:**
> - **D1, D1:** Diode pairs — 25KV 100A (×2)
> - **L1:** Filter inductor — 350 UHY 40A
> - **L2:** Filter inductor — 350 UHY 40A
> - **C1:** Capacitor — 10 NFD 56KV
> - **C2:** Capacitor — 10 NFD 56KV
> - **C3:** Capacitor — 30 NFD 37KV
>
> **Monitoring & Safety:**
> - **DANFYSIK DC-CT** (DANDONTMON CT1) — DC current transformer for output current measurement
> - **HV12, HVE1** — High voltage monitoring points
> - **10A/V PERSON 110** — Personnel protection circuit
> - **LEV3 OIL-LEVEL** — Oil level sensor
> - **50 OHM 90KV** — Bleeder/discharge resistor (R1)
> - **15A/50MV SH1 GaN** — Current shunt
>
> **Output Configuration:**
> - +OUT FOR POS CURRENT
> - POWER SUPPLY 10 NFD 56KV
> - SW1, SW2 — Switching elements
> - ROSS-GRN-SW — Safety ground switch
> - HVI-G — High voltage interlock ground
>
> **Output Connections (color-coded):**
> - GRN (Green), RED, BLK (Black), WHT (White), ORG (Orange)
>
> **Connectors:**
> - MS3102R18-1P — Military-spec circular connector
>
> **Termination Tank Components:**
> - Resistor strings (shown as zigzag pattern)
> - Capacitor bank connections

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 21 — Control Wiring (Crowbar SCR Stack Assembly Drawing)

### Control wiring

> **[Image (5.8" × 5.7")]:** Detailed mechanical assembly drawing of the **Crowbar SCR stack** with numbered component callouts:
>
> **Parts List:**
>
> | # | Component | Qty |
> |---|-----------|-----|
> | 1 | Trigger Coil | — |
> | 2 | Red Split ring | 2ea |
> | 3 | Ferrit Rod | 2ea |
> | 4 | Ferrit Ring | — |
> | 5 | Aluminum Castings | 8ea |
> | 6 | End Block | 2ea |
> | 7 | Crowbar threaded rod | — |
> | 8 | Crowbar Drive End | — |
> | 9 | Split Ring | 3ea |
> | 10 | Washer Pad Small | 2ea |
> | 11 | Tension Rod | — |
> | 12 | Washer Pad large | 2ea |
> | 13 | SCR's | 4 ea |
> | 14 | ZnO 2.5KV (varistor) | 14 ea |
> | 15 | ZnO 120V (varistor) | 14 ea |
> | 16 | Spherical Washer | 6ea |
> | 17 | Flat Washer | — |
> | 18 | Belleville washers | — |
> | 19 | Jam Nut Steel | — |
> | 20 | Spherical Washer concave | — |
> | 21 | Threaded End Long | — |
> | 22 | Multi Contact Band | 14 ea |
>
> The drawing shows the complete SCR stack assembly with alternating SCR devices, ZnO varistors for voltage grading, ferrite components for triggering, and the mechanical compression hardware.

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 22 — Control Wiring (Phase Controller SCR Stack Assembly)

### Control wiring

> **[Image (5.6" × 5.4")]:** Assembly drawing of the **Phase Controller SCR stack** with numbered component callouts:
>
> **Parts List:**
>
> | # | Component | Qty |
> |---|-----------|-----|
> | 1 | Jam Nut Steel | — |
> | 2 | Spherical Washer concave | — |
> | 3 | Tension Rod | — |
> | 4 | SCR's | 6, 2ea |
> | 5 | Washer Pad Small | 2ea |
> | 6 | Washer Pad large | 2ea |
> | 7 | Spherical Washer concave | — |
> | 8 | Red Split ring | 2ea |
> | 9 | Threaded End Long | — |
> | 10 | Aluminum Castings | 8ea |
> | 11 | Spacer | 6 ea |

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 23 — Control Wiring (Phase Controller SCR Stack — Alternate View)

### Control wiring

> **[Image (4.9" × 5.1")]:** Assembly drawing of the **Phase Controller SCR stack** (alternate/detailed view) with numbered component callouts:
>
> **Parts List:**
>
> | # | Component | Qty |
> |---|-----------|-----|
> | 1 | Trigger Coil | — |
> | 2 | Red Split ring | 2ea |
> | 3 | Ferrit Rod | 2ea |
> | 4 | Ferrit Ring | — |
> | 5 | Aluminum Castings | 8ea |
> | 6 | End Block | 2ea |
> | 7 | Threaded End short | — |
> | 8 | SCR end part | — |
> | 9 | Split Ring | 3ea |
> | 10 | Washer Pad Small | 2ea |
> | 11 | Tension Rod | — |
> | 12 | Washer Pad large | 2ea |
> | 13 | SCR's | 14 ea |
> | 14 | ZnO 2.5KV (varistor) | 14 ea |
> | 15 | ZnO 120V (varistor) | ea |
> | 16 | Spherical Washer | 6ea |
> | 17 | Flat Washer | — |
> | 18 | Belleville washers | — |
> | 19 | Jam Nut Steel | — |
> | 20 | Spherical Washer concave | — |
> | 21 | Threaded End Long | — |

> **[Logo — Bottom right]:** Power Conversion Department

---

## Slide 24 — Control Wiring (SCR Controller & Crowbar Wiring Diagram)

### Control wiring

> **[Image (4.7" × 5.7")]:** Complete wiring/block diagram of the **4-B SLC5B8 CONTROLLER** and crowbar trigger system:
>
> **Controller Section (Top):**
> - **A+ TRIGGER / A- TRIGGER** — Phase A trigger pair
> - **B+ TRIGGER / B- TRIGGER** — Phase B trigger pair
> - **C+ TRIGGER / C- TRIGGER** — Phase C trigger pair
> - Each trigger pair has DC power connections (DC 24V DC, 5V DC)
> - TRIGGER SUPPLY connections for each phase
>
> **Controller Label:**
> - **4-B SLC5B8 CONTROLLER** (central controller unit)
>
> **Trigger Card Section:**
> - **ENERPRO TRIGGER CARD** — Crowbar trigger interface
> - **ENERPRO CONTROLLER CARD** — Main controller interface
> - CONNECTION CARD modules for signal routing
>
> **Crowbar Section (Bottom):**
> - **CROWBAR MASTER** — Primary crowbar SCR trigger
> - **CROWBAR SLAVE** (×2) — Secondary crowbar SCR triggers
> - **2/24 VOLT SUPPLY** — Crowbar trigger power supply
>
> **Terminal Connections:**
> - TS1, TS2, TS3, TS4, TS5, TS6 — Terminal strip identifiers for external connections

> **[Logo — Bottom right]:** Power Conversion Department
