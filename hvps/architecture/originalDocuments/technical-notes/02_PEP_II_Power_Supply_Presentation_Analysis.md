# PEP-II Power Supply Presentation — Complete Schematic & Design Analysis

**Document ID:** HVPS-ORIG-002  
**Source:** `hvps/architecture/originalDocuments/pepII supply.pptx`  
**Title:** "SLAC Klystron Power Supply — Pep II Power Supply"  
**Author:** R. Cassel (inferred from drawing numbers and style)  
**Slides:** 24 total  
**Content Types:** Schematics, waveform captures, component specifications, control wiring diagrams

---

## 1. Document Overview

This presentation is the most detailed single source of the PEP-II/SPEAR3 HVPS design. It contains:
- **Slide 1:** Title slide with HVPS photograph
- **Slide 2:** Specifications
- **Slide 3:** Circuit topology comparison (4 configurations)
- **Slide 4:** System block diagram with component values
- **Slides 5–8:** Detailed schematics (image-only, circuit diagrams)
- **Slide 9:** Power supply waveforms — inductor voltage, AC line current, line voltages
- **Slide 10:** Additional schematic detail
- **Slide 11:** Transformer phase voltages — upper and lower core voltages
- **Slide 12:** AC current waveform
- **Slides 13–14:** Additional schematics
- **Slide 15:** Light-triggered SCR testing — trigger delay measurements
- **Slide 16:** Present SCR crowbar delay measurements
- **Slide 17:** SCR vs light-triggered crowbar comparison
- **Slides 18–24:** Complete control system wiring diagrams (7 sheets)

---

## 2. Specifications (Slide 2)

| Parameter | Value |
|-----------|-------|
| Output voltage | 90 kV DC |
| Output current | 27 A DC (continuous) |
| Output power | 2.5 MW |
| Regulation & ripple | < ±0.5% at > 65 kV |
| Klystron arc protection | **Critical requirement** |
| Voltage control | Continuous |
| Physical constraint | Must fit existing transformer pads |
| Cost | Cost effective |

---

## 3. Circuit Topology Comparison (Slide 3) — Four Configurations

Slide 3 presents **four circuit configurations** side by side, showing the evolution of the design:

### 3.1 Normal Circuit
```
AC Input → Filter Inductor → Filter Capacitor → Load
```
- Standard L-C filter on secondary side
- Filter capacitor directly connected to load
- **Problem:** Full capacitor energy dumps into klystron on arc

### 3.2 Conventional Circuit
```
AC Input → L-C Filter (inductor + capacitor in standard arrangement) → Load
```
- Standard industrial approach
- Filter inductor and capacitor on secondary side
- Same vulnerability to arc energy

### 3.3 Primary Inductor "Star Point Control" Circuit
```
AC Input → Primary Filter Inductor → Transformer → Rectifier → Load
                                                    ↕
                                              Inductor Bypass
```
- Filter inductor moved to **primary side**
- Star point controller configuration
- Inductor bypass capability for fault protection
- Still has filter capacitor energy concern

### 3.4 Proposed Circuit (Actual Design)
```
AC Input → Primary Filter Inductor → Transformer → Rectifier → Load
                                                    ↕           ↑
                                              Inductor Bypass   │
                                                                │
           Filter Capacitor → Bleeder Resistors ────────────────┘
```
- **All features of star point control PLUS**
- Filter capacitor **isolated from load** by bleeder (high-ohmage) resistors
- Inductor bypass for primary-side fault management
- This is the unique PEP-II contribution

---

## 4. System Block Diagram with Component Values (Slide 4)

### 4.1 Input Section
| Component | Value/Rating |
|-----------|-------------|
| Input voltage | 12.5 kV 3-phase |
| Input power | 3000 kVA |
| Disconnect & breaker | Included |

### 4.2 Phase Shifting Transformer
- PEP-II phase shifting transformer
- Creates two phase-shifted outputs for T1 and T2

### 4.3 Controlled Thyristor Section
| Component | Rating |
|-----------|--------|
| SCR rectifier (controlled thyristor) | 40 kV, 80 A |
| Configuration | Phase-controlled bridge |

### 4.4 Rectifier Transformers
| Component | Designation |
|-----------|------------|
| Transformer 1 | T1 (feeds one 6-pulse bridge) |
| Transformer 2 | T2 (feeds other 6-pulse bridge) |

### 4.5 Secondary Rectifiers & Filter
| Component | Rating | Purpose |
|-----------|--------|---------|
| Main rectifiers | 30 kV, 30 A | Full-current power rectification |
| Filter rectifiers | 30 kV, 3 A avg | Low-current filtering path |
| Filter capacitors | 8 µF, 30 kV | Voltage smoothing |
| Filter resistors | 500 Ω, 1 kW | Isolate filter cap from load |
| Filter inductor | (primary side) | Part of star point control |

### 4.6 Output & Voltage Distribution
| Point | Voltage |
|-------|---------|
| Full output | −90 kV |
| Intermediate | −77 kV |
| Lower tap | −52 kV |
| Lowest tap | −26 kV |
| Ground reference | GRN |

### 4.7 Protection
| Component | Rating |
|-----------|--------|
| Crowbar | 100 kV, 80 A |
| Location | Between output and klystron |

### 4.8 Termination Tank
- Located between power supply output and klystron
- Contains output termination components

---

## 5. Waveform Analysis

### 5.1 Power Supply Waveforms (Slide 9)
Two oscilloscope captures showing:

**Capture 1: Inductor voltage and AC line current**
- Shows the inductor voltage ripple pattern
- AC line current waveform with 12-pulse characteristics

**Capture 2: Three line voltages (note overlap)**
- Shows the three-phase line voltage waveforms
- Overlap region visible at phase transitions
- Characteristic of phase-controlled rectifier operation

### 5.2 Transformer Phase Voltages (Slide 11)
Two oscilloscope captures:

**"Three Core Voltages — Lower"**
- Transformer core voltages for the lower voltage secondary
- Shows balanced three-phase operation

**"Three Core Voltages — Upper"**
- Transformer core voltages for the upper voltage secondary
- 30° phase shift visible relative to lower set
- Confirms proper 12-pulse phasing

### 5.3 AC Current (Slide 12)
- Single oscilloscope capture labeled "AC CURRENT"
- Shows the 12-pulse AC current waveform drawn from the mains
- Reduced harmonic content compared to 6-pulse

---

## 6. Crowbar Protection Testing (Slides 15–17)

### 6.1 Light-Triggered SCR Testing (Slide 15)
**Key measurement: Light-triggered delay ~1 µs, independent of voltage**

Six measurement channels:
| Channel | Parameter | Scale |
|---------|-----------|-------|
| 1 | Trigger | 1 V, 5 µs/div |
| 2 | Current | 40 A/div, 20 V, 5 µs/div |
| 3 | Voltage | 5 kV/div, 5 V, 5 µs/div |
| 4 | Trigger | 1 V, 5 µs/div |
| 5 | Current | 40 A/div, 20 V, 5 µs/div |
| 6 | Voltage | 5 kV/div, 5 V, 5 µs/div |

**Critical finding:** Light-triggered SCR has ~1 µs delay, voltage-independent. This is significantly faster than conventional SCR triggering.

### 6.2 Present SCR Crowbar Delay (Slide 16)
**Title:** "Present SCR Crowbar Delay"

**Waveform Capture 1:**
| Channel | Parameter | Scale |
|---------|-----------|-------|
| 1 | Klystron Voltage | 10 kV/div, 1 V, 5 µs/div |
| 2 | Arc Current | 20 A/div, 1 V, 5 µs/div |
| 3 | Trigger | 50 V, 5 µs/div |

**Waveform Capture 2 — "Present Crowbar Trigger: Normal and Reversed Driver":**
| Channel | Parameter | Scale |
|---------|-----------|-------|
| 1 | Trigger delayed | 50 V, 5 µs/div |
| 2 | Klystron Voltage delayed | 500 mV, 5 µs/div |
| 3 | Trigger normal | 50 V, 5 µs/div |
| 4 | Klystron Voltage normal | 500 mV, 5 µs/div |

This shows comparison between normal and reversed driver configurations for the crowbar trigger.

### 6.3 SCR vs Light-Triggered Crowbar Comparison (Slide 17)
**Title:** "SCR Crowbar Trigger Delay"

**Normal SCR Triggered Crowbar:**
| Channel | Parameter | Scale |
|---------|-----------|-------|
| 1 | Klystron Voltage | 10 kV/div, 1 V, 5 µs/div |
| 2 | Arc Current | 20 A/div, 1 V, 5 µs/div |
| 3 | Trigger | 50 V, 5 µs/div |

**Light Triggered SCR Crowbar:**
| Channel | Parameter | Scale |
|---------|-----------|-------|
| 1 | Crowbar Current | 20 A/div, 20 V, 5 µs/div |
| 3 | Load Current | 20 A/div, 20 V, 5 µs/div |
| 4 | Klystron Voltage | 20 kV/div, 1 V, 5 µs/div |
| 6 | Trigger | 50 V, 5 µs/div |

**Key comparison:** The light-triggered SCR crowbar shows significantly faster response compared to the normal SCR triggered crowbar.

> **SPEAR3 Note:** The current SPEAR3 system uses fiber-optic triggered crowbar SCRs, which evolved from the light-triggered concept tested here. See `Designs/4_HVPS_Engineering_Technical_Note.md` Section 2.6 for the current crowbar configuration.

---

## 7. Control Wiring Diagrams (Slides 18–24) — Complete System

These seven slides contain the complete control system wiring diagrams for the PEP-II HVPS. They document every signal connection between the controller, power components, and monitoring systems.

### 7.1 Trigger Enclosure Wiring — WD-730-790-02 (Slide 18)
**Drawing:** "Trigger Enclosure Wiring, 2.5 MW Klystron PEP-II Power Supply, WD-730-790-02, R. Cassel, R5"

#### SCR Driver Boards (12 total for phase control + 2 for crowbar)
Each driver board has identical pinouts:

| Pin | Signal | Function |
|-----|--------|----------|
| P1-1 | OUT-1 | Gate pulse output 1 |
| P1-2 | OUT-2 | Gate pulse output 2 |
| P1-3 | BIAS | Bias voltage |
| P1-4 | GRN | Ground reference |
| P1-5 | +100V | +100V supply |
| P1-6 | +200V | +200V supply |
| P2-1 | +12V | +12V logic supply |
| P2-2 | COM | Common/ground |
| P2-5 | TRIG | Trigger input |
| P2-7 | OFF | Inhibit/off command |
| P2-9 | PWR-C | Power collector |
| P2-10 | PWR-E | Power emitter |

**Board designations:**
- H1(A+), H1(A−), H1(B+), H1(B−), H1(C+), H1(C−) — Bridge 1 (6 boards)
- H2(A+), H2(A−), H2(B+), H2(B−), H2(C+), H2(C−) — Bridge 2 (6 boards)
- H3(C1), H3(C2) — Crowbar (2 boards)

#### Enerpro 12-Phase Controller (EN-1B)
| Pin | Signal |
|-----|--------|
| J1-1 | +A (Gate) |
| J1-2 | +A (Cathode) |
| J1-4 | +B (Gate) |
| J1-5 | +B (Cathode) |
| J1-7 | +C (Gate) |
| J1-8 | +C (Cathode) |
| J2-1 | −A (Gate) |
| J2-2 | −A (Cathode) |
| J2-4 | −B (Gate) |
| J2-5 | −B (Cathode) |
| J2-7 | −C (Gate) |
| J2-8 | −C (Cathode) |

#### Interface Board Connections
Two identical Interface Boards (IN1, IN2) with:
| Pin | Signal | Function |
|-----|--------|----------|
| E1-3 through E1-14 | +A, −A, +B, −B, +C, −C and GRN | Phase trigger outputs |
| P1-1 | +12V | Logic supply |
| P1-3 | ENABLE | System enable |
| P1-5 | CROWBAR | Crowbar command |
| P1-7 | CWBAR OFF | Crowbar inhibit |
| P1-9 | S OUT | Status output |
| P1-11 | S IN | Status input |
| P1-13 | ARC | Arc detection input |
| M2-1 | 12V | Power supply |
| M2-3 | ENABLE | Enable signal |
| M2-5 | CROWBAR | Crowbar signal |
| M2-7 | ON | On command |
| M2-9 | +SCRS | Positive SCR enable |
| M2-11 | −SCRS | Negative SCR enable |

#### PLC System
- **CPU:** SLC-5/03 (AB-1747-DCM) — Slot 0
- **Communication:** 1794-DCM (RS232 + DH485) — Slot 1
- **I/O Module:** AB-1746-IO8 — Slot 2 (4 outputs, 4 inputs)
- **Thermocouple:** AB-1794-THERMC — Slot 3
  - TC-1: SCR Top Oil temperature
  - TC-2: SCR Bottom Oil temperature
  - TC-3: Crowbar temperature
  - TC-4: Air temperature
- **Discrete Output:** AB-1746-OX8 — Slot 5 (8 outputs)
- **Digital Input:** AB-1794-IV16 — Slot 7 (16 inputs)
- **Analog I/O:** AB-1794-NIO4V — Slot 8 (4 channels)
- **Analog Input:** AB-1794-NI4 — Slot 9 (4 channels)

#### Power Supplies
| Designation | Model | Output |
|------------|-------|--------|
| PS-1 | Kepco 120V/1A | Bias supply for driver boards |
| PS-2 | Kepco 240V/0.25A | High-voltage bias supply |
| PS-3 | Kepco 5V/20A | Logic power supply |
| PS-4 | Kepco 120V/1A | Additional bias supply |
| PS-5 | LND X-152 | Isolated DC-DC supply |
| PS-6 | Sola 85-15-2120 | PLC/control power |

#### Regulator Card (PC-237-230-14-C0 / EN-2)
| Pin | Signal | Function |
|-----|--------|----------|
| J1-1 | ED2 | Error signal 2 |
| J1-2 | COM | Common |
| J1-3 | EI+ | Error input positive |
| J1-4 | COM | Common |
| J2-1 | RESET | System reset |
| J2-2 | COM | Common |
| J2-3 | STOP | Emergency stop |
| J2-4 | +24V | Power supply |
| J2-5 | CURR TRIP | Current trip output |
| J2-6 | VOLT TRIP | Voltage trip output |
| J2-7 | MAN TRIP | Manual trip output |
| J2-8 | CUR LIMIT | Current limit input |
| J3-1 | VOLT | Voltage feedback |
| J3-2 | CUR | Current feedback |
| J3-3 | COM | Common |
| J4-1 | EL1 | Error limit 1 |
| J4-2 | IL1 | Current limit 1 |
| J4-3 | SIG HI | Signal high |
| J4-4 | I1 | Current input 1 |
| J4-5 | I2 | Current input 2 |
| J4-6 | +12V | Logic supply |
| J4-7 | COM | Common |
| J4-8 | +30 | +30V supply |

#### PLC Analog Signals
| PLC Input | Signal | Purpose |
|-----------|--------|---------|
| Slot 8, IN 0+ | Reference monitor | Setpoint reference |
| Slot 8, IN 1+ | DC current monitor | Load current |
| Slot 8, OUT 0 | Reference voltage | DAC setpoint output |
| Slot 8, OUT 2 | Reference phase | Phase reference output |
| Slot 9, IN 0+ | Enerpro voltage | SCR firing angle feedback |
| Slot 9, IN 1+ | 2nd voltage monitor | Redundant voltage measurement |
| Slot 9, IN 2+ | Enerpro current | SCR current feedback |
| Slot 9, IN 3+ | DC current monitor | Redundant current |

#### PLC Digital Outputs (Slot 5)
| Output | Signal | Function |
|--------|--------|----------|
| OUT 0 | CONT. ON/OFF | Contactor control |
| OUT 1 | 24V ENABLE | System enable |
| OUT 2 | FAST ENABLE | Fast enable for SCRs |
| OUT 3 | SLOW START | Soft-start ramp |
| OUT 4 | CROWBAR OFF | Crowbar inhibit |
| OUT 5 | PHASE LOSS | Phase loss detection |

#### PLC Digital Inputs (Slot 7)
Contactor controls, transformer interlocks, PPS permits, and status signals from TS-4, TS-5 terminal strips.

### 7.2 Interconnection Wiring — WD-730-790-01 (Slide 19)
**Drawing:** "Interconnection Wiring, 2MW Klystron Test Stand Power Supply, WD-730-790-01, R. Cassel, R3"

This slide shows the physical cable interconnections between:
- Hoffman Box (34×42) — Main controller enclosure
- NWL #39308 — Transformer tank
- Hoffman 12×10 junction boxes
- Termination Tank
- Personnel Protection System (PPS)

**Key Cable Types:**
- Belding 88761 Shielded Twisted Pair — Signal cables
- Belding 83715 15C #16 Teflon — Power/trigger cables  
- Belding 83709 9C #16 Teflon — Crowbar cables
- RG-58 Coaxial — Monitor signals

**Terminal Strip Layout:**
| TS | Function | Location |
|----|----------|----------|
| TS-1 | AC Power | Controller |
| TS-2 | Permits | Controller |
| TS-3 | PWR SUP Monitors | Controller |
| TS-4 | Transformer Interlocks | Tank |
| TS-5 | Contactor Controls | Controller |
| TS-6 | Grounding Tank | Ground tank |
| TS-7 | Transformer Monitors | Tank |
| TS-8 | Permits | Controller |
| TS-NWL | NWL Transformer | Tank |

**Interlock Signals:**
- Oil level (3 sensors: LEV-1, LEV-2, LEV-3)
- Temperature (T20-1-509 thermocouples)
- Pressure (sudden pressure relay)
- PPS (Personnel Protection System)
- Blocking relay, Overcurrent, Contactor status

**Connector Types:**
- MS3108E18-1S (P5) — Multi-pin circular
- MS3108E24-20S (P1, P2) — Multi-pin circular
- GOB1288PNE (J1) — 8-pin connector
- AMP-8PIN (J2/P2) — 8-pin for interface
- F-10PIN-R#16 (P5) — 10-pin power connector

### 7.3 Grounding Tank / Termination Tank Components (Slide 20)

#### Filter Components
| Component | Value | Rating | Function |
|-----------|-------|--------|----------|
| L1 | 350 µH | 40 A | Filter inductor 1 |
| L2 | 350 µH | 40 A | Filter inductor 2 |
| C1 | 10 nF | 56 kV | Filter capacitor 1 |
| C2 | 10 nF | 56 kV | Filter capacitor 2 |
| C3 | 30 nF | 37 kV | Filter capacitor 3 |
| C4 | 30 nF | 37 kV | Filter capacitor 4 |
| D1 | 25 kV, 100 A | (×2) | Rectifier diode stack |
| R1 | 50 Ω | 90 kV | Voltage divider/bleeder |
| S1 | 15 A / 50 mV | Shunt | Current measurement shunt |

#### Current Monitoring
| Component | Model | Specification |
|-----------|-------|--------------|
| CT1 | Pearson 110 | 10 A/V, AC current transformer |
| CT2 | Danfysik DC-CT | DC current transducer |

**Danfysik DC-CT Pinout:**
| Pin | Signal |
|-----|--------|
| 9 | +15V supply |
| 2 | Test |
| 3 | Status − |
| 4 | GRN (ground) |
| 5 | DC PWR / −15V |
| 6 | Output |
| 8 | Status + |

#### Switching Components
| Component | Type | Function |
|-----------|------|----------|
| HVT-1 | HV relay | Power supply HV connection |
| HVT-2 | HV relay | Load HV connection |
| HVT-G | HV relay | Ground HV connection |
| SW1 | Manual GRN switch | Manual ground switch |
| SW2 | Ross Engineering GRN switch | HV ground safety switch (NO/NC/COM, 5 pins) |
| LEV3 | Oil level sensor | Termination tank oil level |

### 7.4 Additional Wiring Diagrams (Slides 21–24)
Slides 21–24 contain additional detailed wiring diagrams showing:
- Wire color codes for all cable runs
- Terminal strip assignments
- Relay logic interconnections
- Wire gauge specifications (#18, #16, #20 AWG)
- Detailed NWL transformer internal connections (TS-NWL with pins 1–46)
- Complete resistor networks in termination tank (R11–R47)
- Oil level and temperature monitoring connections

**NWL Transformer Internal Connections (TS-NWL):** 46 terminal positions connecting:
- Phase SCR triggers
- Crowbar SCR connections  
- Transformer monitor windings
- Oil level sensors
- Temperature sensors

**Termination Tank Resistor Network:**
| Resistor Group | Value | Rating | Quantity | Purpose |
|----------------|-------|--------|----------|---------|
| R11-R13, R17-R19 | 500 Ω | 10 W | 6 | Filter bleeder |
| R21-R23 | 500 Ω | 10 W | 3 | Filter bleeder |
| R31-R33 | 500 Ω | 10 W | 3 | Filter bleeder |
| R42, R44 | 500 Ω | 10 W | 2 | Filter bleeder |
| R14-R16 | 50 Ω | — | 3 | Termination |
| R24-R26 | 50 Ω | — | 3 | Termination |
| R34-R36 | 50 Ω | — | 3 | Termination |
| R46-R47 | 50 Ω | — | 2 | Termination |

These 50 Ω resistors serve as **cable termination resistors** for impedance matching (consistent with the IEEE paper's mention of snubber networks matched to output cable impedance), while the 500 Ω 10 W resistors are the **filter capacitor isolation resistors** described in the IEEE paper.

---

## 8. Key Engineering Insights from This Document

### 8.1 Design Maturity
The wiring diagrams show a mature, production-quality design with:
- Complete drawing numbers (WD-730-790-01, WD-730-790-02)
- Revision tracking (R3, R5)
- Standard military-style connectors (MS3108)
- Industrial cable specifications (Belding Teflon-insulated)

### 8.2 PLC System
The original PEP-II system used an **Allen-Bradley SLC-5/03** PLC, which is the same family as the SPEAR3 legacy controller. This confirms the lineage of the current PLC code analyzed in `hvps/documentation/plc/technical-notes/`.

### 8.3 Enerpro Integration
The Enerpro FCOG1200 12-phase firing controller (EN-1B) is directly wired to the SCR driver boards, confirming the architecture described in `hvps/controls/enerpro/technical-notes/`.

### 8.4 Regulator Card
The regulator card is designated **PC-237-230-14-C0**, matching drawing number **SD-237-230-14** analyzed in `hvps/documentation/schematics/technical_notes/SD-237-230-14_Regulator_Board_Analysis.md`.

---

**Document Status:** Complete analysis of all 24 slides  
**Confidence Level:** High — text extracted via LibreOffice PDF conversion + original PPTX metadata  
**Related Notes:** [01_SLAC_PUB_7591_IEEE_Paper_Analysis.md](01_SLAC_PUB_7591_IEEE_Paper_Analysis.md), [04_Original_Design_Consolidated_Specifications.md](04_Original_Design_Consolidated_Specifications.md)

