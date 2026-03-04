# SPEAR3 HVPS System — Engineering Technical Note

**Document ID:** HVPS-ETN-001  
**Revision:** R0  
**Date:** 2025  
**Author:** Engineering Team (SSRL/SLAC)  
**Classification:** Engineering Reference — Authoritative System Knowledge Source

---

## Purpose and Scope

This document is the single, authoritative engineering knowledge source for the SPEAR3 High Voltage Power Supply (HVPS) system. It consolidates all institutional knowledge of the **legacy system** and the **proposed controller upgrade design** into one reference, intended to support:

- **Schematic generation** ready for fabrication
- **Circuit simulation** (SPICE, MATLAB/Simulink)
- **Detailed design validation** and peer review
- **AI-assisted engineering** workflows for all of the above

All technical data herein is traceable to the source documents in this repository. Cross-references are provided as relative file paths.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Power Section — Legacy Hardware (Retained)](#2-power-section--legacy-hardware-retained)
3. [Legacy Controller Architecture](#3-legacy-controller-architecture)
4. [Machine Protection System (MPS) and Interlocks](#4-machine-protection-system-mps-and-interlocks)
5. [EPICS Control System Interface](#5-epics-control-system-interface)
6. [Proposed Upgrade Design](#6-proposed-upgrade-design)
7. [Interface Specifications for Upgrade](#7-interface-specifications-for-upgrade)
8. [Component Specifications and Selection](#8-component-specifications-and-selection)
9. [Stored Energy and Safety Analysis](#9-stored-energy-and-safety-analysis)
10. [Maintenance and Reliability](#10-maintenance-and-reliability)
11. [Document Cross-Reference Index](#11-document-cross-reference-index)
12. [HVPS Integration in LLRF System Context](#12-hvps-integration-in-llrf-system-context)
13. [Future Considerations and Upgrade Path](#13-future-considerations-and-upgrade-path)

---

## 1. System Overview

### 1.1 Function

The SPEAR3 HVPS converts three-phase 12.47 kV RMS AC mains power into regulated DC high voltage for a 1.5 MW klystron that provides RF power to the SPEAR3 storage ring cavities.

### 1.2 Top-Level Specifications

| Parameter | Value | Notes |
|---|---|---|
| Input voltage | 12.47 kV RMS, 3-phase | From substation 507, breaker 160 |
| Input transformer rating | 3.5 MVA (phase-shifting) | Ref: `architecture/originalDocuments/slac-pub-7591.pdf` |
| Rectifier transformer rating | 1.5 MVA each (×2) | T1 and T2 |
| Maximum output voltage | −90 kVDC | Negative polarity |
| Maximum output current | 27 A | |
| Maximum output power | 2.5 MW | |
| Nominal operating voltage | −74.7 kV | At 500 mA SPEAR beam current |
| Nominal operating current | 22.0 A | At 500 mA SPEAR beam current |
| Rectifier topology | 12-pulse, thyristor phase-controlled | Extended delta + two open-wye bridges |
| Number of HVPSs | 2 (SPEAR1, SPEAR2) | One active, one warm spare |
| Location | Building 514 (HVPS), Building 118 (controller) | |

> **Source:** `architecture/originalDocuments/slac-pub-7591.pdf`, `architecture/originalDocuments/ps3413600102.pdf`, `documentation/procedures/spear3HvpsHazards.tex`

### 1.3 System Block Diagram (Textual)

```
  12.47 kV RMS 3φ
        │
   ┌────┴────┐
   │Switchgear│──── Disconnect, Fuses (3×50A), Vacuum Contactor
   └────┬────┘
        │
  ┌─────┴──────┐
  │ Phase-Shift │  Extended Delta Transformer (3.5 MVA)
  │ Transformer │  Creates ±15° phase-shifted outputs
  └──┬─────┬───┘
     │     │
  ┌──┴──┐ ┌┴───┐
  │ T1  │ │ T2 │   Rectifier Transformers (1.5 MVA each)
  │(+15°)│ │(-15°)│  Open-wye primaries
  └──┬──┘ └┬───┘
     │     │
  ┌──┴──┐ ┌┴───┐
  │6-Pulse│ │6-Pulse│   Phase Control Thyristor Bridges
  │Bridge │ │Bridge │   12 stacks × 14 Powerex T8K7 each
  └──┬──┘ └┬───┘
     │     │
  ┌──┴──┐ ┌┴───┐
  │L1    │ │L2   │   Filter Inductors (0.3 H each)
  │(0.3H)│ │(0.3H)│
  └──┬──┘ └┬───┘
     │     │
  ┌──┴─────┴───┐
  │  4 Secondary│  Each with diode rectifier bridge
  │  Rectifiers │  Connected in series
  │  + Filters  │  8 µF filter caps + 0.22 µF output cap
  └──────┬──────┘
         │
  ┌──────┴──────┐
  │ Crowbar Tank │  4 stacks × 6 thyristors (fiber-optic triggered)
  └──────┬──────┘
         │
    ─90 kVDC ──────► Klystron (via switch-over tank)
```

### 1.4 Physical Layout

| Tank/Location | Contents | Connection |
|---|---|---|
| Main Tank (B514) | Phase-shifting xfmr, rectifier xfmrs, inductors, filter caps, diode rectifiers | FR3 oil filled, N₂ blanket |
| Phase Tank (B514) | 12 phase-control thyristor stacks, snubber circuits | FR3 oil, bolted cover |
| Crowbar Tank (B514) | 4 crowbar thyristor stacks, output voltage dividers, output cap (0.22 µF) | FR3 oil, bolted cover |
| Grounding Tank (B514) | Output DC current monitor (Danfysik), ground connections | |
| Switch-over Tank (adjacent B514) | HV cable connections between SPEAR1/SPEAR2 and klystron | FR3 oil |
| Termination Tank (near klystron) | HV cable termination, Ross Engineering HV relay | Mineral oil |
| Controller (B118) | PLC, Enerpro firing board, regulator card, fiber optics | Hoffman enclosure |

> **Source:** `documentation/procedures/phaseTankMaintenanceOutline.docx`, `documentation/procedures/crowbarTankMaintenanceOutline.docx`, `documentation/mechanical/Internal Layout - dwg D36942-E.png`


---

## 2. Power Section — Legacy Hardware (Retained)

The power section will be retained as-is during the controller upgrade. This section documents its design for simulation and interface purposes.

### 2.1 Phase-Shifting Transformer

| Parameter | Value |
|---|---|
| Type | Extended delta |
| Rating | 3.5 MVA |
| Input | 12.47 kV RMS, 3-phase |
| Output | Two 3-phase sets, each 12.91 kV RMS phase-to-phase |
| Phase shift | +15° (to T1) and −15° (to T2) relative to input |
| Monitor windings | Three single-phase windings on main transformer legs |
| Monitor winding output | ~100 V peak-to-peak sinusoidal |
| Monitor winding source impedance | 2 MΩ (at HVPS end) |

The monitor windings provide phase references to the controller. **Critical design constraint:** These references are offset by ±15° from the rectifier transformer primaries. The Enerpro firing board must compensate for this offset.

> **Source:** `controls/enerpro/enerproBoardHvps.docx` (Figures 2 & 3), `documentation/wiringDiagrams/hvpsMonitorConnections.xlsx`

### 2.2 Rectifier Transformers (T1, T2)

| Parameter | T1 | T2 |
|---|---|---|
| Rating | 1.5 MVA | 1.5 MVA |
| Primary | Open-wye, 12.91 kV RMS φ-φ | Open-wye, 12.91 kV RMS φ-φ |
| Phase offset from input | +15° | −15° |
| Secondary S1 voltage (φ-φ) | 21.0 kV RMS | 21.0 kV RMS |
| Secondary S2 voltage (φ-φ) | 21.0 kV RMS | 10.5 kV RMS |
| Secondary configuration | Wye, each feeding diode rectifier bridge | Wye, each feeding diode rectifier bridge |

> **Source:** `documentation/procedures/spear3HvpsHazards.tex`, `documentation/schematics/sd7307900101.pdf`

### 2.3 Phase Control Thyristor Stacks (Phase Tank)

| Parameter | Value |
|---|---|
| Number of stacks | 12 (6 per bridge, 2 bridges) |
| Devices per stack | 14 × Powerex T8K7 (350 A rating) |
| Stack snubber capacitor | 0.015 µF per stack (R-C series) |
| Device snubber capacitor | 0.047 µF per device |
| Maximum voltage per stack | 18.26 kV (√2 × 12.91 kV) |
| Trigger pulse amplitude | 240 V (first pulse), 120 V (subsequent) |
| Trigger pulse width | 16 µs per pulse, in 15° bursts |
| Trigger connection | Electrical cable pairs from B118 controller |
| Positive stack identification | Green PCB, SS flange on cathode side |
| Negative stack identification | Blue PCB |

**Stack Layout (Phase Tank — viewed from top):**

| Position | Inside Wall (near center) | Outside Wall |
|---|---|---|
| Row 1 | High Side (S2) C+ | High Side (S2) C− |
| Row 2 | High Side (S2) B+ | High Side (S2) B− |
| Row 3 | High Side (S2) A+ | High Side (S2) A− |
| Row 4 | Low Side (S1) A+ | Low Side (S1) A− |
| Row 5 | Low Side (S1) B+ | Low Side (S1) B− |
| Row 6 | Low Side (S1) C+ | Low Side (S1) C− |

**Trigger Wire Color Code:**

| Positive Stack | P1 (outer) | P2 (inner) | Negative Stack | P1 (outer) | P2 (inner) |
|---|---|---|---|---|---|
| C+ | Black | Blue/Black | C− | Red | Orange/Black |
| B+ | White | Blue/White | B− | Red/White | White/Black |
| A+ | Orange | Blue | A− | Red/Black | Black/White |

> **Source:** `maintenance/hvpsStackInstallationChecklist.docx`, `maintenance/phaseTankMaintenance-20240425jjs.docx`, `documentation/wiringDiagrams/wd7307900103.pdf`

### 2.4 Filter Inductors

| Parameter | Value |
|---|---|
| Number | 2 (L1, L2), one per bridge |
| Inductance | 0.3 H each |
| Full-load current | 85 A |
| Stored energy (full load) | 1,084 J each |

> **Source:** `documentation/procedures/spear3HvpsHazards.tex`, `documentation/mechanical/39312(L1, L2) filter-current limiting choke - dwg W39312-C.png`

### 2.5 Diode Rectifier Bridges (Secondary)

| Parameter | Value |
|---|---|
| Number of bridges | 4 (one per secondary winding) |
| Configuration | Full bridge per secondary, all four in series |
| Stack resistance | 120 MΩ per stack (voltage sharing resistors) |
| Bridge total shunt resistance | 80 MΩ per bridge |
| Voltage tap | 105% tap feeds filter capacitor via 2 × 500 Ω series resistors |

### 2.6 Output Filter

| Component | Value | Purpose |
|---|---|---|
| Main filter capacitors | 8 µF per section (×4 sections) | Ripple filtering |
| Filter series resistors | 2 × 500 Ω | Current limiting to filter caps |
| Output capacitor | 0.22 µF | Additional output filtering |
| Output cable capacitance | ~0.006 µF | Parasitic |

### 2.7 Crowbar System (Crowbar Tank)

| Parameter | Value |
|---|---|
| Number of stacks | 4 (one per filter capacitor section) |
| Devices per stack | 6 thyristors |
| Voltage sharing resistor | 5 MΩ per device, 30 MΩ per stack |
| Trigger | Fiber-optic (Broadcom/Avago HFBR series) |
| Purpose | Fast discharge of filter caps on klystron or transformer arc |

### 2.8 Output Voltage Dividers

| Parameter | Value |
|---|---|
| Number | 2 (identical, redundant) |
| Total resistance | 100 MΩ each |
| Divider configuration | Five 20 MΩ resistors in series + two 10 kΩ in parallel (≈5 kΩ bottom) |
| Scale factor | 9.1 V at −91 kV output |
| Low-pass filter | 5 kΩ with 0.22 µF gives τ = 1.1 ms (f₋₃dB ≈ 145 Hz) |
| Output cable | Belden 88761 shielded twisted pair (~30 pF/ft) |

> **Source:** `architecture/designNotes/EnerproVoltageandCurrentRegulatorBoardNotes.docx`

### 2.9 Switchgear

| Parameter | Value |
|---|---|
| Disconnect switch | Manual, lockable |
| Fuses | 3 × 50A, 50E medium voltage |
| Contactor | Vacuum contactor |
| Control power (DC) | 125 VDC from Substation 507 |
| Control power (AC) | 208 VAC, 3-phase |

> **Source:** `documentation/switchgear/`, `documentation/procedures/spearRfHvpsSwitchProcedureR0.docx`


---

## 3. Legacy Controller Architecture

### 3.1 Controller Overview

The legacy HVPS controller resides in a Hoffman enclosure in Building 118. It comprises three primary subsystems that work together to regulate the HVPS output:

1. **Allen-Bradley SLC-500 PLC** — Sequencing, interlocks, digital filtering of setpoint, and analog I/O
2. **SLAC Regulator Board** (SD-237-230-14) — Analog voltage/current feedback regulation
3. **Enerpro FCOG6100 Firing Circuit** — Thyristor phase-angle trigger generation

> **Source:** `controls/enerpro/enerproBoardHvps.docx`, `architecture/designNotes/EnerproVoltageandCurrentRegulatorBoardNotes.docx`

### 3.2 Signal Flow — Setpoint to Output

```
  EPICS IOC (VXI crate)
      │
      │  I:1 Register 1 (16-bit integer setpoint)
      ▼
  ┌─────────────┐
  │  SLC-500 PLC │
  │              │
  │  N7:30 ◄── External Reference (from VXI DCM)
  │    │                                              
  │  N7:10 ◄── Digital LPF ramp (Rung 104)           
  │    │         τ ≈ 0.68 s, updated every ~80 ms     
  │    │                                              
  │    ├──► O:8.0 ──► Regulator Board EL1 (Reference) 
  │    │                                              
  │  N7:11 ◄── Phase angle calc (Rung 108-109)       
  │    │         N7:11 = (N7:10 × 12000)/32767 + 6000
  │    │         Clamped to max 18000                 
  │    │                                              
  │    └──► O:8.1 ──► Enerpro SIGHI (via 1 kΩ)       
  └─────────────┘
                          
  ┌──────────────────┐        ┌──────────────────┐
  │ Regulator Board  │        │ Enerpro FCOG6100 │
  │  SD-237-230-14   │        │                  │
  │                  │        │                  │
  │ EL1 ──► Ref Amp  │        │  Phase refs ◄── Monitor windings
  │         (INA117) │        │  (J5, via 2MΩ)  │
  │                  │        │                  │
  │ J1 ──► HV Sense  │        │  SIGHI ──► Phase │
  │        (INA117)  │        │  angle control   │
  │                  │        │                  │
  │ Error Amp (OP77) │        │  Triggers ──► Phase tank stacks
  │    │             │        │                  │
  │    ▼             │        │                  │
  │ Diode OR ◄─ I limit      │                  │
  │    │             │        │                  │
  │    ▼             │        │                  │
  │ Output (via 7.5kΩ) ──────► SIGHI summing    │
  │                  │        │  junction        │
  └──────────────────┘        └──────────────────┘

  SIGHI = V_PLC × (7.5k/(1k+7.5k)) + V_REG × (1k/(1k+7.5k))
  
  Thevenin equivalent:
    V_th = (7.5 × V_PLC + 1 × V_REG) / 8.5
    R_th = (1k × 7.5k) / (1k + 7.5k) = 882 Ω
```

> **Source:** `architecture/designNotes/regulatorEnerproTestingNotes.docx`, `documentation/plc/plcNotesR1.docx`

### 3.3 PLC Details (Allen-Bradley SLC-500)

#### 3.3.1 Module Configuration

| Slot | Module | Function |
|---|---|---|
| 1 | AB-1747-DCM | Communication to VXI IOC (8 words in, 8 words out) |
| 2 | Digital Input | Binary interlock inputs (I:2) |
| 3 | AB-1746-NI8 | Thermocouple inputs (I:3.0–I:3.7 → N7:100–N7:107) |
| 5 | Digital Output | Binary control outputs (O:5) |
| 6 | Digital Input | Binary interlock inputs (I:6) |
| 8 | AB-1746-NIO4V | 4 analog I/O: 2 inputs + 2 outputs |
| 9 | AB-1746-NI4 | 4 analog inputs |

#### 3.3.2 Analog I/O Map

**Inputs:**

| Module | Channel | Signal | PLC Register |
|---|---|---|---|
| Slot 8 NIO4V | IN 0 | Voltage monitor from regulator (J3-1) | → N7:12 (Rung 76) |
| Slot 8 NIO4V | IN 1 | Phase angle monitor = SIGHI readback | → N7:13 (Rung 88) |
| Slot 9 NI4 | IN 0 | AC current from regulator (J3-2) | → N7:14 (Rung 78) |
| Slot 9 NI4 | IN 1 | Output voltage monitor 1 (→ also J1-1 regulator) | → N7:15 (Rung 80) |
| Slot 9 NI4 | IN 2 | Output voltage monitor 2 (redundant) | → N7:16 (Rung 81) |
| Slot 9 NI4 | IN 3 | DC current (Danfysik) from grounding tank | → N7:17 (Rung 82) |

**Outputs:**

| Module | Channel | Signal | PLC Register |
|---|---|---|---|
| Slot 8 NIO4V | OUT 0 | Reference voltage → regulator EL1 | N7:10 → O:8.0 (Rung 112) |
| Slot 8 NIO4V | OUT 1 | Phase control → Enerpro SIGHI (1 kΩ) | N7:11 → O:8.1 (Rung 113) |

#### 3.3.3 VXI DCM Interface (Slot 1)

**Inputs to PLC (from EPICS IOC):**

| Register | Function |
|---|---|
| I:1.1 | External Reference setpoint (→ N7:30) |
| I:1.2 | Maximum External Reference (→ N7:33) |

**Outputs from PLC (to EPICS IOC):**

| Register | Function |
|---|---|
| O:1.1 | AC Current (N7:4) |
| O:1.2 | Reference Out voltage / N7:10 |
| O:1.3 | HVPS Voltage Monitor 1 (N7:15) |
| O:1.4 | DC Current / Danfysik (N7:17) |
| O:1.5 | Maximum Internal Voltage Reference |

#### 3.3.4 Digital Low-Pass Filter (Rung 104)

The PLC implements a first-order digital low-pass filter to ramp the voltage setpoint:

```
N7:43 = N7:30 - N7:10          (difference = desired - actual)
N7:43 = N7:43 / 10             (α = 0.1 per step)
N7:10 = N7:10 + N7:43          (update actual)
if N7:43 == 0: N7:10 = N7:30   (force equality when close)
N7:10 = min(N7:10, 32000)      (upper clamp)
if N7:33 > 0: N7:10 = min(N7:10, N7:33)  (external max clamp)
```

**Transfer function:** Equivalent to continuous `H(s) = 1/(1 + sτ)` where:
- Loop period T = 80 ms (S:4 bit 2)
- α = 1/10
- Time constant τ = T / α = **0.68 s** (after correction: τ = -T/ln(1-α) ≈ 0.76 s)
- Step response: `V(t) = V_final × (1 - 0.9^(t/T))`

#### 3.3.5 Phase Angle Calculation (Rungs 108–109)

```
N7:11 = N7:10                       (copy reference)
product = N7:11 × N7:40             (N7:40 = 12000, constant)
if product overflows (≥ 32767):
    N7:11 = product / 32767          (double-divide from S:13/S:14)
else:
    N7:11 = 1                        (non-overflow case)
N7:11 = N7:11 + N7:41               (N7:41 = 6000, offset)
N7:11 = min(N7:11, N7:42)           (N7:42 = 18000, clamp)
```

This maps the 16-bit reference to a phase angle command range of approximately 6000–18000 counts.

#### 3.3.6 Key PLC Constants

| Register | Label | Value | Purpose |
|---|---|---|---|
| N7:9 | AC Amp Offset | −117 | Calibration offset for AC current |
| N7:19 | Voltage Offset | (calibration) | Calibration offset for voltage |
| N7:20 | Voltage Scale | 10000 | Scaling for display |
| N7:21 | Phase Angle Scale | 1000 | Scaling for display |
| N7:31 | Internal Reference Min | 100 | Minimum setpoint |
| N7:32 | Max Reference | 32000 | Maximum setpoint clamp |
| N7:40 | Phase Multiplier | 12000 | Phase angle calculation |
| N7:41 | Phase Offset | 6000 | Phase angle offset |
| N7:42 | Phase Max | 18000 | Phase angle clamp |
| N7:71 | Max Volt constant | 32000 | |
| N7:72 | Max Phase constant | 18000 | |
| N7:73 | Min Volt constant | 100 | |

> **Source:** `documentation/plc/plcNotesR1.docx`, `documentation/plc/PLC software discusion 1.docx`, `documentation/plc/hvpsPlcLabels.xlsx`

### 3.4 Regulator Board (SD-237-230-14)

#### 3.4.1 Architecture

The SLAC-designed common regulator board provides both voltage and current regulation. It accepts:
- **Voltage reference** from PLC (O:8.0) via connector J4
- **HV voltage feedback** from output voltage dividers via J1A/J1B
- **AC current feedback** for current limiting

The two control paths (voltage and current) are combined via a **diode OR** circuit: the lower of the two error signals determines the SIGHI drive, ensuring that either voltage or current limit is enforced.

#### 3.4.2 Voltage Feedback Path

```
HVPS Output (negative)
    │
    ├── Voltage Divider: 5 × 20MΩ + 2 × 10kΩ parallel = 5kΩ bottom
    │     (Scale: V_divider ≈ V_HVPS / 20000)
    │     (At -91 kV: V_divider ≈ -4.55 V)
    │
    ▼
J1A/J1B (Negative Voltage Sense)
    │
    ├── 5 kΩ load resistor + 0.22 µF capacitor
    │     (τ = 1.1 ms, f₋₃dB = 145 Hz)
    │
    ├── INA117 Difference Amplifier (unity gain)
    │     (Input impedance: 10⁹ Ω differential)
    │     (CMRR: >86 dB at DC)
    │     (Bandwidth: 300 kHz at −3 dB)
    │
    ▼
TP4 (HV Readback test point)
    │
    ├── Through 24.9 kΩ to OP77 summing junction
    │
```

**Transfer function (divider input to INA117 output):**
```
H(s) = V_INA117_out / V_HVPS = -(1/20000) × 1/(1 + s × 1.1ms)
```
DC gain: −5 × 10⁻⁵ V/V (i.e., −0.05 mV per volt of HVPS output)

#### 3.4.3 Voltage Reference Path

```
PLC O:8.0 (N7:10)
    │
    ▼
J4-1 / J4-7 (Reference Voltage / Common)
    │
    ├── INA117 Difference Amplifier (inverting)
    │
    ├── Trim pot + 24.9 kΩ fixed resistor
    │
    ▼
TP9 (Reference test point)
    │
    ├── Through 24.9 kΩ to OP77 summing junction
```

#### 3.4.4 Error Amplifier

The OP77 inverting error amplifier sums the feedback and reference currents at its virtual ground:
- **Feedback path:** INA117 output → 24.9 kΩ → summing junction
- **Reference path:** INA117 output → (trim + 24.9 kΩ) → summing junction

Output at TP7 represents the error signal. This is limited by a 10 V Zener diode and drives the SIGHI input through a 7.5 kΩ resistor.

#### 3.4.5 Output Stage

The regulator output drives the Enerpro SIGHI through a **7.5 kΩ** resistor. The PLC output drives SIGHI through a **1 kΩ** resistor. Combined at the SIGHI node:

```
SIGHI ≈ (7.5 × V_PLC + 1.0 × V_REG) / 8.5
R_thevenin = 882 Ω
```

The regulator output is bounded by a ±10 V Zener. Adjusting the PLC offset (previously changed from original to reduced value) keeps the regulator operating in its linear range (±3 V) for normal operation.

> **Source:** `architecture/designNotes/EnerproVoltageandCurrentRegulatorBoardNotes.docx`, `architecture/designNotes/regulatorEnerproTestingNotes.docx`

#### 3.4.6 Key Component List (Regulator Board)

| Component | Part Number | Function | Status |
|---|---|---|---|
| INA117 | Texas Instruments | Unity-gain diff amp, 200V CMR | Available (DIP, SOIC) |
| INA114 | Texas Instruments | Instrumentation amp, 1 MHz GBW | Available (DIP, SOIC) |
| OP77 | Analog Devices | Precision opamp, 600 kHz GBW | Available |
| BUF634 | Texas Instruments | High-current buffer, 250 mA | DIP obsolete; BUF634A recommended |
| MC34074 | ON Semiconductor | Quad opamp, 4.5 MHz GBW | SMD only; TL074 (TI) as DIP alt. |
| 4N32 | Vishay | Optocoupler (5 µs on, 100 µs off) | Available |
| VTL5C | (Obsolete) | Opto variable resistor | Obsolete — requires replacement |
| CD4044B | (CMOS) | Quad RS latch, tri-state | Available |
| 1N3064 | (Obsolete) | Small signal diode | Replace with 1N4150 (Vishay) or BAW27 |
| MAD4030-B | Astec/Artesyn | Isolated DC-DC converter | Obsolete — requires replacement |

### 3.5 Enerpro FCOG6100 Firing Circuit (Legacy)

| Parameter | Value |
|---|---|
| Model | FCOG6100 Rev K |
| Auxiliary board | FCOAUX60 Rev D |
| Serial numbers (boards) | 41506, 50470, 30045 (FCOG6100) |
| Serial numbers (aux) | 03198, 03813, 1694 (FCOAUX60) |
| Input | SIGHI control voltage + 3-phase references |
| Phase reference input | J5 with input resistors R37–R39 (2 MΩ) |
| SIGHI operating range | 0–6 VDC (effective ~0.85–5.85 V) |
| Output | 12 pairs of thyristor triggers (P1, P2 + FCOAUX60) |
| VCO-based phase control | Phase-locked loop with voltage-controlled oscillator |

The FCOG6100 uses LM324 opamps as phase comparators. Phase references enter through the external R37–R39 resistors on J5.

> **Source:** `controls/enerpro/enerproBoardHvps.docx`, `controls/enerpro/enerproDocuments/`


---

## 4. Machine Protection System (MPS) and Interlocks

### 4.1 Interlock Overview

The HVPS controller implements a comprehensive interlock system using the PLC digital I/O. All interlocks are designed **fail-safe**: a broken cable or lost signal removes the permit. Interlocks are organized into binary input registers I:2 and I:6, with status bits mapped to B3:0 through B3:5.

### 4.2 Binary Input Interlocks

| PLC Tag | Register | Signal | Normal State |
|---|---|---|---|
| I:2/0 | B3:12/0 | 120 VAC Control Power | On |
| I:2/1 | B3:12/1 | A Phase Reference Voltage | On |
| I:2/2 | B3:12/2 | Filter Inductor 1 | Off |
| I:2/3 | B3:12/3 | Filter Inductor 2 | Off |
| I:6/0 | B3:13/0 | SCR Disable Fiber Drive | Off |
| I:6/1 | B3:13/1 | Crowbar Enable | Off |
| I:6/2 | B3:13/2 | Crowbar Monitor | On |
| I:6/3 | B3:13/3 | Klystron Arc Monitor | On |
| I:6/4 | B3:13/4 | SCR Trigger 1 | Off |
| I:6/5 | B3:13/5 | Transformer Arc Monitor | On |
| I:6/6 | B3:13/6 | SCR Trigger 2 | Off |
| I:6/7 | B3:13/7 | RF Crowbar | On |
| I:6/8 | B3:13/8 | Ground Tank Oil Level | On |
| I:6/9 | B3:13/9 | Ground Tank Switch | On |
| I:6/10 | B3:13/10 | Crowbar Oil Level | On |
| I:6/11 | B3:13/11 | SCR Oil Level | On |
| I:6/12 | B3:13/12 | DC Power Supply Status | On |
| I:6/13 | B3:13/13 | AC Contactor Over-Current | On |
| I:6/14 | B3:13/14 | Transformer Sudden Pressure | On |
| I:6/15 | B3:13/15 | Oil Pump Flow Switch | On |

### 4.3 Binary Output Controls

| PLC Tag | Signal | Normal State |
|---|---|---|
| O:2/0 | AC Bias Power Supply | On |
| O:2/1 | 120 VDC Power Supply | On |
| O:2/2 | 240 VDC Power Supply | On |
| O:2/3 | Ground Tank Relay Coil | On |
| O:5/0 | SCR Enable | On |
| O:5/1 | Contactor On | On |
| O:5/2 | Contactor Enable | On |
| O:5/3 | Force Crowbar | Off |
| O:5/4 | Crowbar Off | On |
| O:5/5 | Enerpro Slow Start | Off |
| O:5/6 | Enerpro Fast Inhibit | On |
| O:5/7 | Regulator Reset | Off |

### 4.4 Fault Latches and Alarm Registers

| Register | Bit | Label | Set in Rung |
|---|---|---|---|
| B3:3/5 | 5 | Regulator Over Current | 22 |
| B3:3/6 | 6 | Regulator Over Voltage | 23 |
| B3:3/7 | 7 | Transformer Alarm | 21 |
| B3:3/8 | 8 | Contactor Alarm | 20 |
| B3:3/9 | 9 | Regulator Trip | 29 |
| B3:3/10 | 10 | Aux Power Alarm | 28 |
| B3:3/11 | 11 | Emergency Off Alarm | 14 |
| B3:3/12 | 12 | Contactor Over Current Alarm | 24 |
| B3:3/13 | 13 | SCR Driver Latch | 25 |
| B3:3/15 | 15 | SCR Driver Up Latch | 26 |
| B3:4/5 | 5 | Over Current Trip Latch | 58 |
| B3:4/6 | 6 | DC Power Fault | 59 |
| B3:4/10 | 10 | Crowbar Latch | 13 |
| B3:4/11 | 11 | Over Current Latch | 53 |
| B3:4/12 | 12 | Over Voltage Latch | 54 |
| B3:4/13 | 13 | Klystron Arc Trip | 55 |
| B3:4/14 | 14 | Ground Tank Oil Level | 52 |
| B3:4/15 | 15 | Transformer Arc Trip | 57 |

### 4.5 Fast Inhibit Sequence

When B3:0/4 (SCR On Latch) goes high (Rung 10):
1. Timer T4:5 starts (3 second delay)
2. B3:0/13 (Fast Inhibit) is latched immediately
3. After 3 seconds, B3:0/2 (Regulator On) goes high
4. When B3:0/2 goes low (fault), N7:10 and N7:11 are zeroed (Rung 11)

> **Source:** `documentation/plc/hvpsPlcLabels.xlsx`, `documentation/plc/PLC software discusion 1.docx`, `architecture/designNotes/rfedmHvpsLabelsPvs.docx`

---

## 5. EPICS Control System Interface

### 5.1 Process Variables (PVs) — HVPS Expert Panel

The HVPS status is displayed on the "SPEAR RF Klystron HVPS" EPICS panel. Key PVs:

| Panel Label | PV Name | Description |
|---|---|---|
| Contactor Closed | SRF1:HVPSCONTACT:CLOSE:STAT | Aux relay closes when contactor closed |
| Contactor Open | SRF1:HVPSCONTACT:OPEN:STAT | Aux relay closes when contactor open |
| Contactor Ready | SRF1:HVPSCONTACT:READY:STAT | Aux relay closes when contactor can be closed |
| Over Voltage | SRF1:HVPS:VOLT:LTCH | HVPS voltage limit exceeded (regulator card) |
| Klystron Arc | SRF1:HVPSKLYS:ARC:LTCH | Klystron arc sensed |
| Transformer Arc | SRF1:HVPSXFORM:ARC:LTCH | Transformer arc sensed |
| Crowbar | SRF1:HVPS:CROWBAR:LTCH | Pulses to crowbar thyristors detected |
| Crowbar from RF | SRF1:HVPSRF:CROWBAR:LTCH | LLRF commanded crowbar to fire |
| Emergency Off | SRF1:HVPS:PANIC:LTCH | Mushroom switch in ground tank |
| AC Current | SRF1:HVPSAC:CURR:LTCH | 12.47 kVAC mains over-current |
| Over Temperature | SRF1:HVPS:TEMP:LTCH | Mechanical thermal switch in oil |
| Oil Level | SRF1:HVPSOIL:LEVEL:LTCH | Mechanical oil level switch |
| Transformer Press | SRF1:HVPSXFORM:PRESS:LTCH | Slow oil overpressure |
| Transfer Vac/Press | SRF1:HVPSXFORM:VACM:LTCH | Rapid overpressure and/or vacuum |
| Open Load | SRF1:HVPS:OPENLOAD:LTCH | HVPS-to-klystron connection open |
| 12 kV Available | SRF1:HVPS12KV:VOLT:STAT | 12.47 kVAC measured on phase A |
| AC Auxiliary Power | SRF1:HVPSAC:POWER:STAT | Control power in HVPS controller |
| DC Auxiliary Power | SRF1:HVPSDC:POWER:STAT | HVPS controller DC supplies on |
| Enerpro Fast Inhibit | SRF1:HVPSENERFAST:ON:STAT | Enerpro fast inhibit status |
| Enerpro Slow Start | SRF1:HVPSENERSLOW:START:STAT | Enerpro soft start status |
| Supply Status | SRF1:HVPSSUPPLY:ON:STAT | Contactor on + some interlocks clear |
| Supply Ready | SRF1:HVPSSUPPLY:READY:STAT | Supply ready to output HV |
| PPS | SRF1:HVPS:PPS:STAT | PPS chain made up |
| SCR 1 | SRF1:HVPSSCR1:ON:STAT | Firing status of left side thyristors |
| SCR 2 | SRF1:HVPSSCR2:ON:STAT | Firing status of right side thyristors |

### 5.2 Analog Readbacks via DCM

| PV Equivalent | Raw Format | Scale Factor (ESLO) | Typical Value |
|---|---|---|---|
| RF PLC Voltage | AB-1771DCM AI-13 bit | 0.02442 | 72.4 kV |
| RF PLC Current | AB-1771DCM AI-13 bit | 0.01221 | 22.09 A |
| HVPS Current | AB-SLC500DCM-Signed | 0.00153 | 21.92 A |
| HVPS Voltage | AB-SLC500DCM-Signed | 0.00305 | 72.47 kV |

> **Source:** `architecture/designNotes/rfedmHvpsLabelsPvs.docx`, `documentation/plc/hvpsPlcLabels.xlsx`


---

## 6. Proposed Upgrade Design

### 6.1 Upgrade Philosophy

The upgrade retains the proven high-power section (transformers, thyristor stacks, inductors, diode rectifiers, crowbar, oil tanks) and replaces the controller electronics. The key motivations are:

1. **Obsolescence:** The SLC-500 PLC is end-of-life; the FCOG6100 is no longer manufactured
2. **Reliability:** Modern components reduce failure risk during SPEAR operations
3. **Capability:** Modern PLC supports floating-point math (eliminating integer overflow issues), improved diagnostics, and modern network interfaces
4. **Maintainability:** Standardized, commercially available components with long-term support

> **Source:** `architecture/designNotes/LLRFUpgradeTaskListRev0.docx`

### 6.2 Components to be Replaced

| Legacy Component | Replacement | Notes |
|---|---|---|
| AB SLC-500 PLC | Modern PLC (floating-point capable) | Eliminates 16-bit integer math workarounds |
| AB-1747-DCM | Modern Ethernet/IP or similar | Direct EPICS IOC interface |
| Enerpro FCOG6100 Rev K | **Enerpro FCOG1200 Rev L** | 12-pulse, single board (no FCOAUX60 needed) |
| FCOAUX60 Rev D | (Eliminated) | FCOG1200 has all 12 outputs |
| SLAC Regulator SD-237-230-14 | **Redesigned regulator board** | Address obsolete parts, improve performance |
| VXI crate IOC | Modern EPICS IOC | Standard Ethernet |
| Hoffman enclosure wiring | **Redesigned power distribution** | `architecture/designNotes/HoffmanBoxPowerDistribution.docx` |

### 6.3 Components to be Retained

- Phase-shifting transformer and all high-voltage transformers
- Phase control thyristor stacks (phase tank)
- Crowbar thyristor stacks (crowbar tank)
- Filter inductors L1, L2
- Diode rectifier bridges
- Output filter capacitors
- Output voltage dividers
- Switchgear
- All oil tanks and oil systems
- Monitor windings on phase-shifting transformer
- Danfysik DC current transformer

### 6.4 New Interface Chassis

A new chassis will serve as the central interface between LLRF, RF MPS, SPEAR MPS, and the HVPS controller. All permits are **active-high** (fail-safe).

#### 6.4.1 Input Permits

| Input | Signal Type | Source |
|---|---|---|
| LLRF permit for HVPS | Optocoupler | From LLRF system |
| HVPS controller ready | Fiber optic receiver (HFBR-2412) | From HVPS controller |
| SPEAR PPS permit | 24 VDC | Personnel Protection System |
| SPEAR orbit interlock | 24 VDC | Orbit interlock system |
| RF MPS permit | 24 VDC | RF Machine Protection System |
| Spare inputs | 24 VDC and 5 VDC | Future expansion |

#### 6.4.2 Output Permits

| Output | Signal Type | Destination |
|---|---|---|
| LLRF enable | Optocoupler | To LLRF system |
| Phase control thyristor enable | Fiber optic transmitter (HFBR-1412) | To HVPS controller |
| Crowbar inhibit | Fiber optic transmitter (HFBR-1412) | To HVPS controller |

#### 6.4.3 Logic

All input optocoupler outputs feed a logical AND gate. The AND output drives the HFBR-1412 fiber optic transmitters. The crowbar enable is normally always enabled; only the phase control thyristor trigger enable is removed on fault.

A fault from RF MPS **or** loss of HVPS controller fiber optic status removes the LLRF permit.

RF MPS will also send a **software command** (via EPICS) instructing the HVPS controller to turn off — this is a soft, redundant signal.

#### 6.4.4 Interface Chassis — Optical Isolation

All inputs are optically isolated using **HCPL-2400-000E** optocouplers (Broadcom):
- Response time: ~1 µs
- Input drive: designed for 10 mA (15 V input with appropriate series resistor)
- Spare inputs use jumpers when not connected

> **Source:** `architecture/designNotes/interfacesBetweenRFSystemControllers.docx`

### 6.5 Enerpro FCOG1200 (Upgrade Firing Board)

#### 6.5.1 Key Specifications

| Parameter | FCOG1200 Rev L |
|---|---|
| Pulse configuration | 12-pulse (single board) |
| Phase reference input | J7 (8-pin header, TE 3-640440-8) |
| Phase detection IC | EP1016 (custom Enerpro ASIC) |
| EP1016 supply | 0–12 VDC |
| EP1016 input range | 1 V to 11 V (safe operating) |
| SIGHI input range | 0–6 VDC (recommended 0.85–5.85 V or 0.85–6.2 V max) |
| SIGHI input circuit | R40, R41 → R26 → C35 → buffer U8C (MC34074) |
| Auto-balance capability | On-board trimpot, external, or on-board auto-balance |
| Inner loop bandwidth | ≥ 500 Hz (per Enerpro documentation) |
| Trigger outputs | J1–J4 (maps to legacy P1, P2, FCOAUX60 connectors) |
| PLL VCO gain | Same as FCOG6100 (per Enerpro) |

#### 6.5.2 Phase Reference Adapter Board (New Design Required)

Because the SPEAR monitor windings are offset ±15° from the rectifier transformer primaries, a custom adapter board is needed between the monitor windings and J7 of the FCOG1200.

**Design Requirements:**
- 3 inputs (Phase A, B, C from monitor windings, ~100 Vpp, 2 MΩ source impedance)
- 6 outputs (3 pairs, one for +15° lag, one for +75° lag, to J7 pins 1–6)
- Phase shift achieved by RC low-pass filter on Enerpro board with modified resistors

**Resistor Configuration (Recommended — Equal Amplitude Approach):**

| Output | Adapter Resistor | Enerpro RN4 Resistor | J7 Pins | Phase Shift | AC Amplitude at Comparator |
|---|---|---|---|---|---|
| Phase A → +75° lag | 1.37 MΩ | RN4A–C: 470 kΩ | 1, 2, 3 | +75° | ~1.5 Vpp |
| Phase A → +15° lag | 2 MΩ | RN4D–F: 150 kΩ | 4, 5, 6 | +15° | ~1.5 Vpp |

**Key constraints from Enerpro:**
- EP1016 internally processes each trio (X = pins 1–3, Y = pins 4–6) independently
- Within each trio, all three phases must have identical amplitude and DC offset
- Cross-trio amplitude and offset differences are acceptable
- EP1016 comparators are high-gain opamps without built-in bias — they rely on the +5V bias of each input signal
- 220 pF capacitors across EP1016 provide comparator hysteresis

**Mating Connector:**
- J7 header: TE 3-640440-8
- Mating cable connector: C2MTAPLG08 (TE Connectivity 3-640440-8)
- Cover: C2MTACVR08
- Hand crimp tool: TE P/N 58074-1

> **Source:** `controls/enerpro/enerproBoardHvps.docx`, `controls/enerpro/enerproPhaseReferenceAdapter.docx`, `controls/enerpro/enerproDiscussion07072022.docx`

### 6.6 SIGHI Input Design for FCOG1200

#### 6.6.1 Input Circuit Differences from FCOG6100

In the FCOG1200 Rev K/L:
- Input path: R40=R41, R26, C35 → buffer U8C (MC34074) → R47 → inverting input of U7D (at +5 VDC)
- C31 placement is after R26 (not before as in FCOG6100)
- C31 can be given a small value (e.g., 100 pF → BW ≈ 5 MHz) or omitted
- Enerpro recommends keeping C31 with small value for transient protection

#### 6.6.2 SIGHI Range and Protection

- Valid operating range: **0.85 V to 5.85 V** (recommended)
- Absolute maximum: 0 V to 6 VDC (no 6.2 V Zener as in FCOG6100 Rev R)
- Input current at R26 (39 kΩ) limits damage even at ±15 V drive
- No Zener protection needed if output opamp limits to ±15 V
- At SIGHI = −15 V: U8C output clamps to ~0.1 V → buffer U7D output ≈ 11 V (MC34074 limit)
- At SIGHI = +15 V: U8C clamps to ~11 V → buffer output ≈ 0.1 V (safe)

### 6.7 Redesigned Regulator Board

The regulator board will be redesigned to:
1. Replace all obsolete components (VTL5C, 1N3064, MAD4030-B, BUF634 DIP)
2. Maintain the dual voltage/current control architecture with diode OR
3. Match the interface to the new PLC and FCOG1200
4. Improve the error amplifier bandwidth and noise performance
5. Maintain compatibility with existing voltage divider and current monitor signals

**Design constraints for the new regulator:**
- Input voltage feedback: Same voltage divider interface (5 kΩ / 0.22 µF at board input)
- Reference input: From new PLC DAC (higher resolution than 16-bit integer)
- Output: Drive SIGHI of FCOG1200 within 0.85–5.85 V range
- Error amplifier: Must handle power-line harmonics visible in feedback (see Figure 4 in `enerproBoardHvps.docx`)

### 6.8 Hoffman Enclosure Power Distribution

The controller Hoffman box requires the following power supplies:

| Supply | Voltage | Source | Loads |
|---|---|---|---|
| PPS (Premises Power Supply) | 120 VAC | B118 panel | Internal power supplies |
| DC Supply 1 | +15 VDC | From 120 VAC | Analog electronics |
| DC Supply 2 | −15 VDC | From 120 VAC | Analog electronics |
| DC Supply 3 | +5 VDC | From 120 VAC | Logic, Enerpro board |
| DC Supply 4 | +24 VDC | From 120 VAC | Relay drivers, fiber optics |
| Enerpro supply | +12 VDC | From 120 VAC | FCOG1200 board |

> **Source:** `architecture/designNotes/HoffmanBoxPowerDistribution.docx`, `architecture/designNotes/HoffmanBoxPPSWiring.docx`

### 6.9 Fiber Optic Connections (Controller to HVPS)

| Connection | Fiber Type | Transmitter | Receiver | Function |
|---|---|---|---|---|
| SCR Enable | Plastic fiber | HFBR-1412 | HFBR-2412 | Phase control thyristor trigger enable |
| Crowbar Enable | Plastic fiber | HFBR-1412 | HFBR-2412 | Crowbar thyristor inhibit control |
| HVPS Status | Plastic fiber | HFBR-1412 | HFBR-2412 | HVPS controller ready status |
| Crowbar Trigger | Plastic fiber | HFBR-1412 | HFBR-2412 | Crowbar firing signal |

HFBR-1412 transmitter drive: Broadcom recommends specific driver circuit per Figure 11 of data sheet.

> **Source:** `architecture/designNotes/controllerFiberOpticConnections.docx`, `architecture/designNotes/interfacesBetweenRFSystemControllers.docx`


---

## 7. Interface Specifications for Upgrade

### 7.1 Interface Summary — Legacy Hardware to New Controller

The following interfaces must be preserved or replicated in the upgraded controller:

| Interface | Legacy Signal | Cable/Connector | New Controller Requirement |
|---|---|---|---|
| Phase references | 3 × ~100 Vpp sine, 2 MΩ source | Shielded twisted pair to B118 | → Phase reference adapter → FCOG1200 J7 |
| HV voltage feedback 1 | 0 to −4.55 V (at −91 kV), via 100 MΩ divider | Belden 88761 STP | → Regulator board J1A/J1B |
| HV voltage feedback 2 | Redundant (same as above) | Belden 88761 STP | → PLC analog input (monitoring) |
| DC current (Danfysik) | Current transformer output | Cable to grounding tank | → PLC analog input |
| AC current | From regulator board J3-2 | Internal | → PLC analog input |
| Phase trigger cables | 12 × twisted pairs (color coded) | Multi-conductor, B514 to phase tank | Retained as-is |
| Crowbar triggers | 4 × fiber optic | Plastic fiber, B118 to crowbar tank | Retained as-is |
| Contactor control | 125 VDC logic | To switchgear in B514 | → PLC digital output |
| PPS permit | 24 VDC | From PPS chain | → Interface chassis input |
| LLRF interface | Optocoupler | From LLRF system | → Interface chassis |
| RF MPS | 24 VDC | From RF MPS | → Interface chassis |

### 7.2 Measured Operating Points (for Simulation Validation)

From `documentation/plc/hvpsMeasurements20220314.xlsx` (500 mA SPEAR operation):

| Parameter | Measured Value | PLC Register |
|---|---|---|
| Gap voltage (kV) | 2000–3200 | (EPICS) |
| HVPS output (kV) | 60.0–68.7 | N7:15 |
| External Reference | 19570–21721 | N7:10 |
| Phase Out (SIGHI counts) | 13167–13955 | N7:11 |
| SIGHI readback (Enerpro input) | 10548–11170 | N7:13 |
| Regulator voltage (TP4) | 6.0–6.9 V | TP4 |
| Regulator output (TP7) | −0.304 V | TP7 (nearly saturated) |

**Key observation:** At these operating points, the regulator output TP7 was nearly constant at −0.304 V, indicating the regulator was saturated. After adjusting the PLC offset, the regulator returned to its linear operating range.

> **Source:** `architecture/designNotes/regulatorEnerproTestingNotes.docx`, `documentation/plc/hvpsMeasurements20220314.xlsx`

---

## 8. Component Specifications and Selection

### 8.1 Enerpro FCOG1200 Documentation

| Document | Location |
|---|---|
| E640_F FCOG1200 Schematic (08-13-96) | `controls/enerpro/enerproDocuments/E640_F FCOG1200 Schematic (08-13-96).pdf` |
| E640_K FCOG1200 Schematic (09-30-09) | `controls/enerpro/enerproDocuments/E640_K FCOG1200 Schematic (09-30-09).pdf` |
| E640_L FCOG1200 Schematic (03-01-21) | `controls/enerpro/enerproDocuments/E640_L FCOG1200 Schematic (03-01-21).pdf` |
| FCOG1200 Operating Manual (OP-0111 Rev C) | `controls/enerpro/enerproDocuments/OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.pdf` |
| FCOG1200 Auto Balance Instructions | `controls/enerpro/enerproDocuments/FCOG1200 Auto Balance.pdf` |
| FCOG1200 Brochure | `controls/enerpro/enerproDocuments/FCOG1200 Brochure.pdf` |
| Phase Control Theory | `controls/enerpro/enerproDocuments/PHASE CONTROL THEORY.PDF` |
| Closing the Loop Application Note | `controls/enerpro/enerproDocuments/Closing the Loop.pdf` |
| E128 Rev Schematic (legacy FCOG6100) | `controls/enerpro/enerproDocuments/E128_R_Schematic_11-14.pdf` |

### 8.2 Fiber Optic Components

| Component | Part Number | Manufacturer | Function |
|---|---|---|---|
| Fiber TX | HFBR-1412 | Broadcom/Avago | Transmitter for plastic fiber |
| Fiber RX | HFBR-2412 | Broadcom/Avago | Receiver for plastic fiber |
| Optocoupler | HCPL-2400-000E | Broadcom | Optical isolation for interface chassis |

### 8.3 Regulator Board Obsolescence Replacements

| Obsolete Part | Replacement | Notes |
|---|---|---|
| VTL5C (opto variable resistor) | Application-specific redesign | Response time was ms-scale; new design may use different approach |
| 1N3064 (signal diode) | 1N4150 (Vishay) or BAW27 (Vishay) | BAW27 is direct replacement; 1N4150 is recommended by Digikey |
| MAD4030-B (DC-DC converter) | Modern isolated DC-DC (e.g., Traco, Recom) | Must match voltage/current specs |
| BUF634 (DIP) | BUF634A (SMD) | Higher BW, current, slew rate; no DIP available |
| MC34074 (DIP) | TL074 (TI, DIP available) | Comparable quad opamp; slightly lower specs |

### 8.4 Thyristor Specifications

| Parameter | Phase Stack (Powerex T8K7) | Crowbar Stack |
|---|---|---|
| Current rating | 350 A | — |
| Devices per stack | 14 | 6 |
| Voltage sharing (MOV) | Yes, per device | Yes, 5 MΩ per device |
| Snubber (per device) | 0.047 µF capacitor | — |
| Snubber (per stack) | 0.015 µF R-C series | — |
| Self-fire voltage (typical) | 7.0–7.8 kV per device | 7.0–7.3 kV per device |
| Leakage current (typical @ 4.2 kV) | 3–42 µA per device | 5–35 µA per device |

> **Source:** `maintenance/phaseTankScrs.xlsx`, `maintenance/HVPSReliability.xlsx`

---

## 9. Stored Energy and Safety Analysis

### 9.1 Summary of Stored Energy

| Component | Value | Max Energy (J) | Time Constant τ (s) | Time to <50 V (s) |
|---|---|---|---|---|
| Filter inductor (each) | 0.3 H | 1,084 | < 0.1 | < 0.1 |
| Phase stack snubber cap | 0.015 µF | 2.5 | 4.2 | 24.8 |
| Phase thyristor snubber cap | 0.047 µF | 0.040 | 0.94 | 3.1 |
| Filter capacitor (normal shutdown) | 8 µF | 8,788 | < 1 | < 1 |
| Output capacitor (normal shutdown) | 0.22 µF | 911 | < 1 | < 1 |
| Output cables (normal shutdown) | ~0.006 µF | 25 | < 1 | < 1 |
| Total output cap (normal shutdown) | 2.23 µF | 9,824 | < 1 | < 1 |
| Total output cap (output open) | 2.23 µF | 9,824 | 20.9 | 160 |
| Filter capacitor (internal failure) | 8 µF | 8,788 | 640 | 4,890 (~82 min) |

### 9.2 Discharge Paths

In the event of abnormal discharge (output open, no klystron load):

| Discharge Path | Resistance | τ (s) for 8 µF |
|---|---|---|
| Filter rectifier shunt R | 80 MΩ | 640 |
| Main rectifier shunt R | 3.3 MΩ (via 500 Ω filter R) | 26.7 |
| Crowbar thyristor shunt R | 30 MΩ | 240 |
| Output voltage dividers | 12.5 MΩ (¼ of 2 × 50 MΩ) | 100 |
| **Total parallel** | **2.348 MΩ** | **18.79** |

Total output voltage decays below 50 V in **160 seconds** (output open, all discharge paths connected).

**Worst case (internal failure, filter caps disconnected from main rectifiers):** τ = 640 s, time to safe level = **81.5 minutes**.

> **Source:** `documentation/procedures/spear3HvpsHazards.tex`

---

## 10. Maintenance and Reliability

### 10.1 Phase Tank Maintenance

Phase tank maintenance involves replacing all 12 thyristor stacks with tested spares on a periodic basis. The procedure (reference: `maintenance/phaseTankMaintenance-20240425jjs.docx`) includes:

1. Execute Energy Isolation Plan (EIP SR-444-636-05-R1)
2. Pump FR3 oil from phase tank into temporary storage
3. Remove tank cover (two-person lift)
4. Discharge stored energy using Phenix discharge sticks
5. Disconnect grounding buswork and trigger cables
6. Remove existing stacks; install tested replacements
7. Verify positive/negative stack placement per layout table (Section 2.3)
8. Reconnect buswork and trigger cables per color code table
9. Replace cover, refill oil, restore nitrogen and cooling water

### 10.2 Crowbar Tank Maintenance

Similar procedure to phase tank but for 4 crowbar stacks. Additional checks include:
- High-pot each crowbar stack to 25 kV individually
- Measure and record output capacitor capacitance
- Verify voltage divider resistance (100 MΩ each)
- Test fiber optic trigger connections

> **Source:** `documentation/procedures/crowbarTankMaintenanceOutline.docx`, `maintenance/hvpsStackInstallationChecklist.docx`

### 10.3 Stack Testing Protocol

Before installation, each stack undergoes bench testing:
1. Clean stacks and visually inspect for damage
2. High-pot entire stack and record leakage current at 25 kV
3. Measure voltage across each thyristor/MOV pair for individual leakage
4. Replace high-leakage devices (typical pass: < 50 µA at 4.2 kV)
5. Verify device polarity and PCB color (green = positive, blue = negative)
6. Test fiber-optic trigger response (crowbar stacks)
7. Record self-fire voltage (typical 7.0–7.8 kV)

### 10.4 HVPS Switch-over Procedure

Switching between SPEAR1 and SPEAR2 requires:
1. Verify active HVPS is off and output at 0 VDC
2. Execute appropriate EIP (SR-444-636-06-R1 or SR-444-636-07-R1)
3. Disconnect and ground output cables of active supply
4. Reconfigure switch-over tank connections
5. Remove administrative locks on new supply
6. Energize new supply per startup procedure

> **Source:** `documentation/procedures/spearRfHvpsSwitchProcedureR0.docx`

---

## 11. Document Cross-Reference Index

### 11.1 Architecture and Design Notes

| File | Content |
|---|---|
| `architecture/designNotes/EnerproVoltageandCurrentRegulatorBoardNotes.docx` | Detailed regulator board component analysis, circuit operation, transfer functions |
| `architecture/designNotes/HoffmanBoxPPSWiring.docx` | Hoffman enclosure premises power wiring |
| `architecture/designNotes/HoffmanBoxPowerDistribution.docx` | Internal power supply distribution design |
| `architecture/designNotes/LLRFUpgradeTaskListRev0.docx` | Upgrade project task list and scope |
| `architecture/designNotes/RFSystemMPSRequirements.docx` | RF system machine protection requirements |
| `architecture/designNotes/controllerFiberOpticConnections.docx` | Fiber optic link specifications |
| `architecture/designNotes/hoffmanTestingNotes.docx` | Hoffman enclosure test results |
| `architecture/designNotes/interfacesBetweenRFSystemControllers.docx` | Interface chassis design — permits, logic, optocouplers |
| `architecture/designNotes/regulatorEnerproTestingNotes.docx` | Regulator/Enerpro testing data and offset adjustment |
| `architecture/designNotes/rfedmHvpsLabelsPvs.docx` | EPICS PV mapping for HVPS status display |

### 11.2 Original Reference Documents

| File | Content |
|---|---|
| `architecture/originalDocuments/slac-pub-7591.pdf` | SLAC technical publication — HVPS design |
| `architecture/originalDocuments/ps3413600102.pdf` | HVPS power supply specification |
| `architecture/originalDocuments/pepII supply.pptx` | PEP-II power supply reference (historical) |

### 11.3 Controls — Enerpro

| File | Content |
|---|---|
| `controls/enerpro/enerproBoardHvps.docx` | FCOG1200 interface analysis, phase reference design, SIGHI circuit |
| `controls/enerpro/enerproDiscussion07072022.docx` | Enerpro technical correspondence (Saul Rivera) — detailed answers |
| `controls/enerpro/enerproPhaseReferenceAdapter.docx` | Phase reference adapter board design specification |
| `controls/enerpro/enerproDocuments/` | Enerpro schematics (E128, E640 series), operating manuals, application notes |
| `controls/enerpro/MC34071-D.PDF` | MC34074 quad opamp data sheet |

### 11.4 Schematics

| File | Content |
|---|---|
| `documentation/schematics/sd7307900101.pdf` | Top-level HVPS schematic (system overview) |
| `documentation/schematics/sd7307900501.pdf` | HVPS subsystem schematic |
| `documentation/schematics/sd2372301200.pdf` | Regulator board schematic (SD-237-230-12) |
| `documentation/schematics/sd2372301401.pdf` | Regulator board schematic (SD-237-230-14) |
| `documentation/schematics/sd7307930304.pdf` | Controller schematic |
| `documentation/schematics/sd7307930402.pdf` | Controller schematic |
| `documentation/schematics/sd7307930702.pdf` | Controller schematic |
| `documentation/schematics/sd7307930801.pdf` | Controller schematic |
| `documentation/schematics/sd7307931203.pdf` | Controller schematic |
| `documentation/schematics/sd7307931301.pdf` | Controller schematic |
| `documentation/schematics/sd7307940400.pdf` | Controller schematic |

### 11.5 Wiring Diagrams

| File | Content |
|---|---|
| `documentation/wiringDiagrams/ei7307900000.pdf` | Equipment interconnect diagram |
| `documentation/wiringDiagrams/wd7307900103.pdf` | Phase tank trigger wiring |
| `documentation/wiringDiagrams/wd7307900206.pdf` | Controller wiring |
| `documentation/wiringDiagrams/wd7307940200.pdf` – `wd7307940600.pdf` | Controller wiring diagrams |
| `documentation/wiringDiagrams/hvpsMonitorConnections.xlsx` | Monitor winding measurements (HVPS1 & HVPS2) |

### 11.6 PLC Documentation

| File | Content |
|---|---|
| `documentation/plc/plcNotesR1.docx` | PLC register analysis — N7:10, N7:11 algorithm |
| `documentation/plc/PLC software discusion 1.docx` | PLC program walkthrough — rungs, timers, DCM interface |
| `documentation/plc/hvpsPlcLabels.xlsx` | Complete PLC I/O map — binary, analog, registers, bits |
| `documentation/plc/hvpsMeasurements20220314.xlsx` | Measured operating data at various setpoints |
| `documentation/plc/CasselPLCCode.pdf` | Original PLC code listing |
| `documentation/plc/CasselSymbolDatabase.pdf` | PLC symbol database |
| `documentation/plc/Cassel_land.pdf` | PLC ladder diagram |

### 11.7 Safety and Procedures

| File | Content |
|---|---|
| `documentation/procedures/spear3HvpsHazards.tex` | Stored energy analysis, discharge calculations |
| `documentation/procedures/spearRfHvpsSwitchProcedureR0.docx` | HVPS switchover procedure |
| `documentation/procedures/sr4446360201R1.docx` – `sr44463607R1.docx` | Energy isolation plans (EIPs) |
| `documentation/procedures/crowbarTankMaintenanceOutline.docx` | Crowbar tank maintenance procedure |
| `documentation/procedures/phaseTankMaintenanceOutline.docx` | Phase tank maintenance outline |

### 11.8 Maintenance and Test Data

| File | Content |
|---|---|
| `maintenance/HVPSReliability.xlsx` | HVPS reliability data and failure history |
| `maintenance/Spear1Tests20220817.xlsx` | SPEAR1 test results |
| `maintenance/Spear2Tests2021.xlsx` | SPEAR2 test results |
| `maintenance/hvpsStackInstallationChecklist.docx` | Comprehensive pre-turn-on checklist |
| `maintenance/phaseTankMaintenance-20240425jjs.docx` | Phase tank maintenance procedure (detailed) |
| `maintenance/phaseTankScrs.xlsx` | Phase tank SCR leakage and self-fire test data |

### 11.9 Mechanical Drawings

| File | Content |
|---|---|
| `documentation/mechanical/Internal Layout - dwg D36942-E.png` | HVPS internal layout |
| `documentation/mechanical/39309 Auto Trans assy - dwg C36683-E.png` | Auto-transformer assembly |
| `documentation/mechanical/39310 rect xfrmr #1 assy - dwg C36776-H.png` | Rectifier transformer #1 |
| `documentation/mechanical/39311 rect xfrmr #2 assy - dwg C36800-H.png` | Rectifier transformer #2 |
| `documentation/mechanical/39312(L1, L2) filter-current limiting choke - dwg W39312-C.png` | Filter inductor drawing |
| `documentation/mechanical/39313 Power-filter rect assy - dwg B37020-E.png` | Power/filter rectifier assembly |

---

## Appendix A — Glossary

| Term | Definition |
|---|---|
| HVPS | High Voltage Power Supply |
| LLRF | Low-Level Radio Frequency (control system) |
| MPS | Machine Protection System |
| PPS | Personnel Protection System |
| SCR | Silicon Controlled Rectifier (thyristor) |
| SIGHI | Signal High — control voltage input to Enerpro board |
| FCOG | Firing Circuit and Oscillator/Gate (Enerpro product line) |
| EIP | Energy Isolation Plan |
| EWP | Electrical Work Plan |
| LOTO | Lock Out / Tag Out |
| DCM | Data Communications Module (AB-1747-DCM) |
| VXI | VMEbus Extensions for Instrumentation |
| IOC | Input/Output Controller (EPICS) |
| FR3 | Envirotemp FR3 natural ester dielectric fluid |
| MOV | Metal Oxide Varistor |
| GBW | Gain-Bandwidth Product |
| CMR / CMRR | Common-Mode Rejection / Common-Mode Rejection Ratio |

---

## Appendix B — Upgrade Task Summary

From `architecture/designNotes/LLRFUpgradeTaskListRev0.docx`:

1. ☐ Design and fabricate Phase Reference Adapter board
2. ☐ Procure Enerpro FCOG1200 Rev L boards (with modified RN4 resistors)
3. ☐ Design and fabricate new Regulator Board (replace SD-237-230-14)
4. ☐ Design and fabricate Interface Chassis (LLRF/MPS/PPS/HVPS permits)
5. ☐ Select and program replacement PLC (floating-point, Ethernet-capable)
6. ☐ Redesign Hoffman enclosure power distribution
7. ☐ Commission new EPICS IOC interface
8. ☐ Bench test all new boards and interfaces
9. ☐ Install and commission on warm-spare HVPS first
10. ☐ Switchover test and validation
11. ☐ Update all procedures and documentation

---

*End of Engineering Technical Note — HVPS-ETN-001 R0*


---

## 12. HVPS Integration in LLRF System Context

### 12.1 Multi-Level RF Control Hierarchy

The HVPS is not a standalone system but an integral component of a sophisticated multi-level control architecture for the SPEAR3 RF system. Understanding this hierarchy is essential for proper HVPS controller design and operation.

#### 12.1.1 Control Level Overview

| Level | System | Update Rate | Controlled Parameter | Control Authority |
|-------|--------|-------------|----------------------|-------------------|
| **Level 1 (Fastest)** | RFP Analog Feedback | ~1 kHz | Cavity field I/Q components | Primary RF regulation |
| **Level 2 (Fast)** | Direct Loop (LLRF) | ~1 kHz | Gap voltage dynamics | Stability against Robinson instability |
| **Level 3 (Slow)** | DAC Loop (LLRF) | ~1 Hz | Total gap voltage setpoint | Beam energy compensation |
| **Level 4 (Slow)** | **HVPS Loop (LLRF)** | **~1 Hz** | **Klystron gain via HVPS voltage** | **Drive power regulation** |
| **Level 5 (Slow)** | Tuner Servo (LLRF) | 1 Hz | Cavity resonant frequency | Frequency tracking |
| **Level 6 (Very Slow)** | Operators/EPICS | Minutes | Station state (ON/OFF/TUNE/PARK) | System mode control |

> **Source:** `Docs_JS/LLRFOperation_jims.docx`

#### 12.1.2 HVPS Role in RF Power Chain

```
SPEAR Beam Acceleration ← 4 Cavities (~375 kW total) ← RF Cavities ← Klystron (~1.5 MW peak)
                                                                         ↑
                                                                   Voltage-Dependent
                                                                   Gain Amplifier
                                                                         ↑
                                                              HVPS Voltage Control
                                                              (Secondary Loop)
                                                                         ↑
                                                              Drive Power Regulation
                                                              Independent of Gap Voltage
```

**Key Insight:** The klystron is **not** a fixed-gain amplifier. Its gain varies with HVPS voltage, allowing the LLRF system to:
- Maintain constant drive power while varying gap voltage (via DAC loop)
- Optimize klystron operating point for efficiency and stability
- Protect klystron collector from excessive power dissipation

#### 12.1.3 RF Station Turn-On Sequence Integration

The HVPS controller must coordinate with the LLRF system during station startup:

1. **Tuners** move to TUNE/ON Home position
2. **HVPS** powers on at Turn-On Voltage (SRF1:HVPS:VOLT:MIN ≈ 50 kV)
3. **DAC** set to Fast On RFP Counts (SRF1:STN:ONFAST:INIT = 100)
4. Creates low measurable RF power (~few watts drive, few hundred kV gap)
5. **DAC** ramped to ~200, then direct loop analog switch closed (adds integrator)
6. Switch closure creates ~45 W transient rise → settles to ~10 W
7. Wait 10-20 seconds for transient decay
8. **Both DAC and HVPS feedback loops become active simultaneously**
9. Loop gains & phases: SRF1:STNDIRECT:LOOP:COUNTS.A (amplitude), SRF1:STNDIRECT:LOOP:PHASE.C (phase shift)

**Critical HVPS Design Requirement:** The HVPS controller must accept and respond to setpoint changes from the LLRF system while maintaining its own internal regulation and protection functions.

### 12.2 HVPS Interface Signals in System Context

#### 12.2.1 Fiber Optic Communication Architecture

The HVPS controller communicates with the broader RF system via three fiber optic links, all using Broadcom HFBR-1412 transmitters and HFBR-2412 receivers:

| Signal | Direction | Function | Source/Destination |
|--------|-----------|----------|-------------------|
| **SCR ENABLE** | Interface Chassis → HVPS | Phase control thyristor trigger enable | LLRF permit via Interface Chassis |
| **KLYSTRON CROWBAR** | Interface Chassis → HVPS | Crowbar thyristor inhibit control | Always enabled (protection only) |
| **STATUS** | HVPS → Interface Chassis | HVPS controller ready status | To LLRF system via Interface Chassis |

#### 12.2.2 Interface Chassis Integration

The Interface Chassis serves as the central permit coordination hub for the entire RF system:

**Input Permits to Interface Chassis:**
- LLRF Status (electrical, 5 VDC @ 60 mA max)
- **HVPS STATUS** (fiber optic, HFBR-2412 receiver)
- RF MPS summary permit (24 VDC)
- SPEAR MPS permit (24 VDC)
- SPEAR orbit interlock permit (24 VDC)
- Power signal permit (24 VDC)
- Waveguide arc interlock permits (dry contacts)
- Expansion ports (TTL and 24 VDC)

**Output Permits from Interface Chassis:**
- LLRF Enable (electrical, 3.2 VDC @ 8 mA min)
- **Phase Control Thyristor Enable** (fiber optic, HFBR-1412 transmitter → HVPS SCR ENABLE)
- **Crowbar Inhibit** (fiber optic, HFBR-1412 transmitter → HVPS KLYSTRON CROWBAR)

**Logic:** All input permits feed a logical AND gate. The AND output drives both the LLRF enable and the HVPS SCR ENABLE. Loss of any permit removes both LLRF and HVPS enables simultaneously.

> **Source:** `Docs_JS/llrfInterfaceChassis.docx`

#### 12.2.3 Machine Protection System Coordination

The HVPS controller must coordinate with multiple protection systems:

**RF MPS (Primary):**
- Monitors klystron temperatures, water flows, vacuum, power supplies
- Provides global RF permit to Interface Chassis
- Monitors Interface Chassis input/output status via digital lines
- Receives software commands to turn off HVPS (redundant to hardware permits)

**SPEAR MPS:**
- Handles machine protection for SPEAR ring (thermal, vacuum, water)
- Provides 24 VDC permit to Interface Chassis
- Beamline MPS configured as satellite of SPEAR MPS

**SPEAR Orbit Interlock:**
- Monitors electron beam position near beamlines
- Provides 24 VDC permit to Interface Chassis
- Prevents mis-steered beam from damaging ring components

### 12.3 Legacy LLRF Code Integration

#### 12.3.1 HVPS Control Loop States (from rf_hvps_loop.st)

The legacy LLRF system implements the HVPS control loop with four main states:

| State | Function | HVPS Behavior |
|-------|----------|---------------|
| **init** | IOC boot initialization | HVPS sequence in proper state |
| **off** | RF station turned off or parked | HVPS voltage at zero |
| **proc** | Cavity processing mode | Voltage ramp based on klystron power, cavity vacuum, gap voltage |
| **on** | Normal operation | Constant drive power regulation via HVPS voltage adjustment |

**Key Process Variables (Legacy System):**
- `{STN}:STN:STATE:RBCK` — Station state readback
- `{STN}:HVPS:LOOP:CTRL` — HVPS loop control
- `{STN}:HVPS:LOOP:STATE` — HVPS loop state
- `{STN}:HVPS:LOOP:STATUS` — HVPS loop status
- `{STN}:HVPS:VOLT:CTRL.VAL` — HVPS voltage setpoint from LLRF

#### 12.3.2 State Transition Matrix (from rf_states.st)

Legal state transitions for the RF system (including HVPS coordination):

```
From   To →    OFF    PARK   TUNE   ON_FM  ON_CW
  ↓
OFF             —      Y      Y      Y      Y
PARK            Y      —      —      —      —
TUNE            Y      —      —      —      Y
ON_FM           Y      —      Y      —      —
ON_CW           Y      —      Y      —      —
```

**HVPS Controller Requirements:**
- Must respond to state change commands from LLRF system
- Must maintain internal protection regardless of commanded state
- Must provide status feedback to enable proper state transitions

### 12.4 LLRF9 Upgrade Integration

#### 12.4.1 Dimtel LLRF9 System Architecture

The upgraded LLRF system will use Dimtel LLRF9 chassis with the following characteristics:

**Signal Processing:**
- 18 most important RF signals monitored by LLRF9
- MATLAB-based analysis and configuration system
- Cavity response model: `H = -i*σ*G*ω/(ω² - i*σ*ω - ωᵣ²) × exp(-i*((ω-ωᵣf)*τ - φ₀))`
- Parameters: σ (damping), G (coupling), ωᵣ (resonant frequency), τ (delay), φ₀ (phase offset)

**Data Management:**
- Circular waveform buffers (~samples at kHz rate)
- History data extraction at ~Hz rate
- Fault freeze and file archival capability

**HVPS Interface Requirements:**
- LLRF9 provides 5 VDC output (up to 60 mA) for permit signaling
- LLRF9 requires 3.2 VDC input (minimum 8 mA) for external permit
- Opto-isolated interlock inputs and outputs
- Daisy-chained configuration for multiple modules

#### 12.4.2 Enhanced Signal Acquisition for HVPS

The upgrade will include dedicated HVPS signal monitoring:

**HVPS Signals (4 channels):**
- HVPS voltage and current (via voltage dividers)
- Inductor voltages (firing circuit health monitoring)
- Sampling rate: kHz (slower than RF due to signal nature)
- Buffer: kilosamples (stores ~100 ms, captures failure 100 ms before trip)
- Discriminator thresholds for overvoltage/overcurrent

**Klystron Collector Power Protection:**
- Calculated from HVPS voltage × current + RF power measurement
- Protects against drive beam overload (non-full-power collector tubes)
- Redundant measurement for system protection
- Product of beam voltage × current = input DC power
- Roughly half converted to RF, other half = collector heat

> **Source:** `Docs_JS/WaveformBuffersforLLRFUpgrade.docx`

#### 12.4.3 Upgrade Task Integration

From the LLRF Upgrade Task List, the HVPS controller is **75% specified** with remaining tasks:

**Design Tasks:**
- Redesign analog regulator board (replace obsolete components)
- Re-specification of Enerpro FCOG1200 board
- Re-programming PLC code with modern CompactLogix
- Improvement of PPS interface

**Integration Tasks:**
- Interface Chassis design and fabrication
- Slow Power Monitoring (8 additional RF channels with Mini-Circuits detectors)
- Arc Detection Circuitry (MicroStep-MIS controllers)
- Stepper Motor Controls for cavity tuners

**Procurement Status:**
- LLRF9 system: Complete (in-house with spares)
- MPS components: ~$22k (CompactLogix I/O modules specified)
- HVPS controller components: To be procured based on final design

### 12.5 System Performance Integration

#### 12.5.1 Control Loop Bandwidth Coordination

The HVPS controller must operate within the overall LLRF bandwidth hierarchy:

| Control Loop | Bandwidth | HVPS Interaction |
|--------------|-----------|------------------|
| RFP Analog | ~1 kHz | No direct interaction (isolated by drive amplifier) |
| Direct Loop | ~1 kHz | Must not interfere with fast RF regulation |
| DAC Loop | ~1 Hz | Coordinates with HVPS loop for power regulation |
| **HVPS Loop** | **~1 Hz** | **Primary control authority for drive power** |
| Tuner Loop | 1 Hz | Independent frequency control |

**Design Constraint:** The HVPS controller response time must be compatible with ~1 Hz update rate while maintaining internal regulation bandwidth sufficient for power line rejection and transient response.

#### 12.5.2 Typical Operating Points in System Context

From measured data during 500 mA SPEAR operation:

| Parameter | Value Range | System Impact |
|-----------|-------------|---------------|
| Gap voltage | 2000-3200 kV | Beam energy regulation |
| HVPS output | 60.0-68.7 kV | Klystron gain control |
| Drive power | ~10-45 W | Klystron input power |
| Klystron output | ~500 kW | RF power to cavities |
| Collector power | ~250 kW | Heat dissipation in klystron |

**Control Relationship:** As gap voltage increases (via DAC loop), drive power tends to increase. The HVPS loop increases HVPS voltage to maintain constant drive power by increasing klystron gain.

### 12.6 Safety Integration in System Context

#### 12.6.1 Fault Response Coordination

The HVPS controller must coordinate fault responses with the broader RF system:

**RF Fault Sequence:**
1. LLRF detects RF fault (reflected power, cavity field drop)
2. LLRF zeros DAC output and opens RF switch to drive amplifier
3. LLRF removes permit to Interface Chassis
4. Interface Chassis removes SCR ENABLE to HVPS controller
5. HVPS controller inhibits thyristor firing
6. Klystron collector protected from full DC power

**HVPS Fault Sequence:**
1. HVPS controller detects internal fault (arc, overcurrent, etc.)
2. HVPS controller removes STATUS signal to Interface Chassis
3. Interface Chassis removes LLRF enable
4. LLRF system shuts down RF output
5. System coordination prevents damage to both klystron and HVPS

#### 12.6.2 Protection System Hierarchy

```
Personnel Protection System (PPS)
    ↓ 24 VDC permit
Interface Chassis ← SPEAR MPS (24 VDC permit)
    ↓ Logical AND    ← SPEAR Orbit Interlock (24 VDC permit)
    ├─→ LLRF Enable  ← RF MPS (24 VDC permit)
    └─→ HVPS SCR ENABLE ← HVPS STATUS (fiber optic)
```

**Design Principle:** All protection systems can independently shut down the RF system, but restoration requires all permits to be restored and all systems to be ready.

---

## 13. Future Considerations and Upgrade Path

### 13.1 Migration Strategy

The HVPS controller upgrade is part of a comprehensive LLRF system modernization. The migration strategy must ensure:

**Phase 1: HVPS Controller Replacement**
- Install new controller on warm-spare HVPS first
- Validate all interfaces with existing LLRF system
- Prove compatibility with legacy rf_hvps_loop.st control algorithms
- Maintain existing EPICS PV structure for operational continuity

**Phase 2: Interface Chassis Installation**
- Deploy Interface Chassis with new permit logic
- Migrate from direct LLRF-HVPS communication to chassis-mediated permits
- Validate fault response times and coordination
- Update MPS integration for new digital status reporting

**Phase 3: LLRF9 System Integration**
- Replace legacy LLRF with Dimtel LLRF9 chassis
- Implement new HVPS control algorithms optimized for LLRF9
- Commission enhanced signal acquisition and waveform buffers
- Update operator interfaces and documentation

### 13.2 Performance Enhancement Opportunities

The upgraded HVPS controller enables several performance improvements:

**Enhanced Diagnostics:**
- Real-time waveform capture of HVPS voltage, current, and inductor voltages
- Automated fault analysis and trending
- Predictive maintenance based on firing circuit health monitoring

**Improved Control:**
- Floating-point PLC eliminates integer overflow issues
- Higher resolution DACs for smoother voltage regulation
- Modern Ethernet interfaces for faster EPICS communication

**Better Integration:**
- Standardized fiber optic interfaces reduce noise and ground loops
- Coordinated fault response with microsecond timing
- Enhanced safety through redundant protection systems

### 13.3 Long-Term Maintenance Considerations

**Component Lifecycle Management:**
- Modern PLC and Enerpro boards have long-term manufacturer support
- Standardized components reduce spare parts inventory
- Improved documentation supports future maintenance

**Operational Flexibility:**
- New controller supports both SPEAR3 and future accelerator requirements
- Modular design allows incremental upgrades
- Enhanced monitoring supports remote operation and diagnostics

> **Sources:** `Docs_JS/LLRFUpgradeTaskListRev3.docx`, `Docs_JS/WaveformBuffersforLLRFUpgrade.docx`, `Docs_JS/llrfInterfaceChassis.docx`, `legacyLLRF/rf_hvps_loop.st`, `legacyLLRF/rf_states.st`

