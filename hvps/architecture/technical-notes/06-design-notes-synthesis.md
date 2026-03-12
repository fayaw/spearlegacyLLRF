# HVPS Design Notes — Technical Summary

> **Synthesized from:** All design notes in `hvps/architecture/designNotes/`
> **Scope:** SPEAR3 High Voltage Power Supply (HVPS) controller system — hardware, controls, interlocks, interfaces, and diagnostics

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Enerpro Voltage & Current Regulator Board](#2-enerpro-voltage--current-regulator-board)
3. [Fiber Optic Control Interface](#3-fiber-optic-control-interface)
4. [Hoffman Box — PPS Interlocks](#4-hoffman-box--pps-interlocks)
5. [Hoffman Box — Power Distribution](#5-hoffman-box--power-distribution)
6. [Controller Interfaces Between RF Subsystems](#6-controller-interfaces-between-rf-subsystems)
7. [RF System Machine Protection Requirements](#7-rf-system-machine-protection-requirements)
8. [LLRF Upgrade Scope](#8-llrf-upgrade-scope)
9. [Testing & Commissioning Notes](#9-testing--commissioning-notes)
10. [EPICS PVs and Diagnostic Panels](#10-epics-pvs-and-diagnostic-panels)
11. [Known Documentation Errors](#11-known-documentation-errors)
12. [Component Obsolescence Notes](#12-component-obsolescence-notes)
13. [Source Document Cross-Reference](#13-source-document-cross-reference)

---

## 1. System Overview

The SPEAR3 HVPS system converts 12.47 kVAC three-phase mains power into a regulated negative high-voltage DC output (nominally ~72 kV, ~19 A) to power a klystron RF source. The major subsystems are:

| Subsystem | Function |
|---|---|
| **Enerpro FCOG6100 firing board** | Phase-controlled thyristor triggering for the 12-pulse rectifier bridge |
| **SLAC regulator board (SD-237-230-14-C1)** | Closed-loop voltage/current regulation interfacing with the Enerpro |
| **Right/Left Trigger Interconnect Boards** | Route Enerpro pulses to 12 SCR driver boards; implement enable/disable logic |
| **12 kV SCR Driver Boards (SD-730-793-03-C4)** | High-voltage pulse amplifiers driving thyristor gate triggers |
| **Monitor Board (SD-730-793-12-C3)** | Analog signal conditioning for voltage/current readbacks |
| **Hoffman Box** | Houses PLC (Allen-Bradley 1746 SLC-500), terminal strips, power supplies, and interlocks |
| **Ross Engineering Vacuum Contactor** | 12.47 kV switchgear with PPS-controlled permits |
| **Crowbar thyristor stacks** | Rapid discharge of filter capacitors on fault |
| **PLC (AB SLC-500 / future ControlLogix 1756)** | Sequencing, interlocks, and EPICS interface |

Typical full-load operating parameters (HVPS2, June 2020, 500 mA beam):

| Parameter | Value |
|---|---|
| Output voltage | 72.08 kVDC |
| Output current | 19.4 ADC |
| AC line current | 92.0 Arms |
| Voltage sense (regulator board) | 7.183 VDC |
| SIG HI to Enerpro | 4.40 VDC |
| Reference voltage (EL1) | 7.159 VDC |
| Current sense (regulator board) | 2.027 VDC |

---

## 2. Enerpro Voltage & Current Regulator Board

*Source: `EnerproVoltageandCurrentRegulatorBoardNotes.docx`*

### 2.1 Board Identity

SLAC drawing **SD-237-230-14-C1**. Designed as a common regulator that can operate as either a voltage or current controller for the Enerpro thyristor gate firing boards.

### 2.2 Key Components

| Component | Type | Key Specs | Notes |
|---|---|---|---|
| **INA117** | Unity-gain difference amplifier | CM range ±200 V; BW 300 kHz; ±15 VDC supply | Balancing resistors required for high CMRR |
| **INA114** | Instrumentation amplifier | Gain set by one external resistor; GBW 1 MHz | Three-opamp architecture; DIP & SOIC |
| **OP77** | Precision opamp | GBW 600 kHz; ultra-low offset/noise | Used as inverting error amplifier |
| **BUF634** | High-current output buffer | 30/180 MHz BW; 250 mA continuous | TI recommends migration to BUF634A |
| **MC34074** | Quad opamp | GBW 4.5 MHz; single-supply capable | ON Semi; alt. TL074 (TI) |
| **4N32** | Optocoupler | Turn-on 5 µs; turn-off 100 µs | Vishay |
| **VTL5C** | Opto variable resistor | MOhm → kOhm; 150 ms recovery | **Obsolete** |
| **CD4044B** | Quad R/S latch | Three-state outputs; common enable | CMOS |
| **MAD4030-B** | DC-DC converter (4.5 W) | ±15 VDC from Enerpro 30 VDC | **Obsolete** (Astec/Artesyn) |

### 2.3 Signal Processing Architecture

The board processes two analog feedback signals through parallel chains:

1. **Negative output voltage** — sensed via external voltage dividers, conditioned by INA117 difference amplifier.
2. **Positive output (AC) current** — sensed via current transformer, conditioned by INA114 then INA117.

Both chains feed into an OP77 inverting error amplifier with integrator compensation. The two error amplifier outputs are combined through a **non-linear diode summing junction** — the lower of the two voltages (whichever limit is more constraining) determines the control voltage sent to the Enerpro board.

### 2.4 Voltage Reference Input

- Source: AB Slot-8, Output 0 (EL1), connected to J4-1/J4-7.
- The reference voltage enters the INA117 negative input, producing a negative output.
- After trim and fixed resistor, this becomes one input to the OP77 error amplifier summing junction.
- **Test point:** TP9 monitors the inverted voltage reference.

### 2.5 High Voltage Readback

- Inputs from voltage dividers (drawing WD-730-792-01 section of WD-730-794-04): five series resistors followed by two parallel resistors per divider.
- The input circuit forms a low-pass filter with the on-board load resistor and capacitor.
- INA117 provides high CMRR at the common-mode voltage present at the HVPS output.
- **Test point:** TP4 monitors the inverted voltage difference.
- The DC transfer function from HVPS output to difference amplifier output produces the scale factor used for readback.

### 2.6 Error Amplifier

The error amplifier (OP77) operates as an inverting integrator:
- Inputs: voltage reference current and HV readback current via matched resistors to the summing junction.
- Feedback: RC network providing integral action.
- Output: drives one leg of the diode summing junction.
- Two VTL5C variable resistors controlled by the interlock system can reduce the feedback impedance (effectively reducing integrator gain) during fault conditions.
- **Test point:** TP5 monitors the error amplifier output.

### 2.7 Current Sensing Path

- AC line current sensed by current transformers on phases A and C, with a burden resistor generating a proportional voltage.
- Input low-pass filter, then INA114 (negative unity gain), then INA117 (inversion).
- The current reference (IL1) is sourced from the Enerpro board's regulated voltage.
- Under normal conditions, the current error amplifier saturates because the current is well below the limit — the voltage loop controls the Enerpro.
- **Test points:** TP1 (current readback), TP12 (current reference), TP11 (overcurrent threshold), TP2 (comparator output).

### 2.8 Enerpro SIG HI Control

The final control voltage to the Enerpro is a resistive combination of:
- **Regulator board output** (through 7.5 kΩ) — the voltage error amplifier output after buffer.
- **PLC DAC output** (Slot-8, Out 1, through 1 kΩ) — the feedforward/setpoint signal.

The Thevenin equivalent determines the SIG HI input to the Enerpro, which operates over a nominal range. The error amplifier can provide fine adjustment of the operating point.

- **Test point:** TP7 monitors the buffered regulator contribution to SIG HI.

### 2.9 Interlocks on the Regulator Board

The board implements five interlock inputs:

| Interlock | Source | Detection |
|---|---|---|
| Overvoltage | HV readback | MC34074 comparator vs. threshold |
| Overcurrent | AC current readback | MC34074 comparator vs. threshold |
| External inhibit | Optocoupler input (not currently connected) | Logic level |
| Enerpro undervoltage | Enerpro control voltage | MC34074 comparator at threshold |
| Enerpro phase loss | Enerpro I1 pin | Optocoupler |

When any interlock trips, three actions occur:
1. VTL5C resistors reduce error amplifier gain.
2. Regulator contribution to Enerpro control voltage is pulled to ground.
3. CD4044B latches capture the fault state.

- **Test point:** TP6 monitors the comparator output that disables the error amplifiers.

### 2.10 Enerpro Board Revisions

| Location | FCOG6100 Rev | FCOG6100 S/N | FCOAUX60 Rev | FCOAUX60 S/N |
|---|---|---|---|---|
| Bad Board | K | 30045 | D | 1694 |
| HVPS1 | K | 41504 | D | 03198 |
| HVPS2 | K | 50470 | D | 03813 |
| Test Stand | K | 49845 | D (Variant?) | 03774 |


---

## 3. Fiber Optic Control Interface

*Source: `controllerFiberOpticConnections.docx` (J. Sebek, May 17, 2022, Rev. 1)*

### 3.1 Overview

Three fiber optic links connect the LLRF control system to the HVPS controller:

| Signal | Direction | Type | Function |
|---|---|---|---|
| **SCR Enable** | LLRF → Controller | Broadcom HFBR-2412 / HFBR-1412 | Enables phase-control thyristor triggers |
| **Klystron Crowbar** | LLRF → Controller | Broadcom HFBR-2412 / HFBR-1412 | Commands crowbar firing and disables triggers |
| **Status** | Controller → LLRF | Broadcom HFBR-1412 / HFBR-2412 | Reports controller health (supply OK + no crowbar) |

All three signals are **active-high** (presence of light = permit/OK), so a fiber break fails safely.

### 3.2 Enerpro Trigger Distribution

The Enerpro FCOG6100 generates a picket fence of thyristor trigger pulses via a voltage-controlled oscillator (nominal frequency with average inter-pulse time). These pulses are routed through two interconnect boards to 12 SCR driver boards (one per thyristor phase).

### 3.3 Right Side Trigger Interconnect Board (SD-730-793-07-C2)

Controls thyristor triggers for one extended-delta transformer primary. Phase B+/B− triggers are **always enabled** (OFF tied to common) to allow filter inductor discharge. The remaining four phases are controlled by logic gates U9A and U9B.

**Trigger disable sources (any one disables all four phases):**

| Input | Source | Logic |
|---|---|---|
| U9A-5 | PLC Slot-5 Out 0 (24V Fault/Enable) | Low = disable (MOSFET gate) |
| U9A-4 | Left Side board "Slave Crowbar Off" | High or open = disable |
| U9B-8 | Transformer Arc OR PLC Force Crowbar | High = disable |
| U9B-2 | Fiber optic SCR Enable from LLRF | No light = disable |

The board also generates two signals on the **Commands bus**:
- FO SCR Enable (active low) — pass-through of the fiber optic signal
- Slave Crowbar Trigger — goes high on transformer arc or PLC force crowbar

### 3.4 Left Side Trigger Interconnect Board (SD-730-793-08-C1)

Complementary to the right side board. Same B-phase always-enabled design. Additional unique functions:

- **Crowbar firing control**: Generates optical triggers to the crowbar thyristor stacks.
- Crowbar fired when **any** of: klystron crowbar fiber optic, klystron arc signal, or slave crowbar trigger from right side board.
- Generates "Slave Crowbar Off" signal to the right side board when any crowbar condition is active.

**Trigger disable sources:**

| Input | Source | Logic |
|---|---|---|
| PLC 24V Fault/Enable (via FO SCR Enable bus) | Same as right side | Low = disable |
| Slave Crowbar Trigger from right side | Transformer arc or PLC force crowbar | High = disable |
| Fiber optic Klystron Crowbar | LLRF system | Active = fire crowbar + disable |
| Klystron Arc signal | BNC input | Active = fire crowbar + disable |

### 3.5 SCR Driver Board (SD-730-793-03-C4)

Each driver board receives the Enerpro trigger pulse (TRIG, pin 5 of ribbon cable) and the OFF control (pin 7). The trigger pulse drives monostable U1B, which generates a timed pulse train for the thyristor gate. If OFF is high or open, CLR on U1B is held low, disabling all trigger generation.

### 3.6 Status Fiber Optic Output

The left side trigger interconnect board generates the fiber optic status signal. The status light is **ON** (healthy) only when:
1. Control supply voltage is present, AND
2. No crowbar firing command has been issued.

Loss of either condition extinguishes the status signal, informing the LLRF that the HVPS has faulted.

### 3.7 Commands Bus Signals

| Pin | Signal | Source |
|---|---|---|
| 1 | +12 VDC | Control Power Supply |
| 3 | 24V FAULT/ENABLE | PLC Slot-5 Out 0 |
| 5 | FO SCR ENABLE\ | Right Side Interconnect |
| 7 | CROWBAR ENABLE\ | PLC Slot-5 Out 4 |
| 9 | SLAVE CROWBAR TRIGGER | Right Side Interconnect |
| 11 | PLC FORCE CROWBAR\ | PLC Slot-5 Out 3 |
| 13 | SLAVE CROWBAR OFF | Left Side Interconnect |

---

## 4. Hoffman Box — PPS Interlocks

*Source: `HoffmanBoxPPSWiring.docx`*

### 4.1 PPS Input Connector

The PPS system enters the Hoffman box through a **Burndy GOB12-88PNE** 8-pin circular connector, likely from a locked PPS box mounted on the HVPS controller. Signals are distributed to terminal strips, LED indicators, and PLC inputs.

Key terminal strips in the Hoffman box:
- **TS-5**: Contactor Controls — interfaces to the Ross Engineering vacuum contactor via a trunk cable to TB2 in the HVPS.
- **TS-6**: Ground Tank connections — DC current sense, ground relay, oil level, and auxiliary status.
- **TS-8**: Permit signals and local panel connections.

### 4.2 Vacuum Contactor Control

The Ross Engineering vacuum contactor uses a two-coil architecture:
- **L2 (Close coil)**: High-power coil to initially close the contactor. Requires K1 relay energized, which requires MX relay energized.
- **L1 (Hold coil)**: Low-power coil to maintain the closed position. Requires MX energized and TX (auxiliary trip) de-energized.

### 4.3 PPS Relay Control — Corrected Understanding

**Critical finding:** The labels on drawing WD-730-794-02-C0 are **swapped**.

| Relay | Labeled As | Actual Function |
|---|---|---|
| **K4** | RESET | **PPS control** — opens contactor and disables controller |
| **RR** | PPS | **RESET** — clears TX relay latch after MCO fault |

**K4 relay operation:**
- Energized by sourcing 24 VDC on the PPS Permit line (wire II in the controller).
- Controls four sets of NO contacts:
  - Phase C 120 VAC control power to TB1-1
  - Two pairs powering oil pump M1 (Phase A)
  - 24 VDC "ON" control from BB to BB1 (to MX relay via 86L lockout relay)
- De-energizing K4 removes all permits and disables the controller, requiring a startup delay to rebuild stored energy in the controller capacitors.

### 4.4 MX Relay Operation

The MX relay energizes the vacuum contactor when K4 is energized, the 86L lockout relay is clear, and the "ON" command is given. MX controls:
- Contactor open indication (via S4 auxiliary contact)
- Hold coil L1 path (through TX NC contacts)
- Controller coil switching (removes close circuit power, enabling hold circuit)

### 4.5 Grounding Tank PPS

Documented via TS-6 in the Hoffman Box and WD-730-794-06-C0. Connections include:
- **Danfysik DC current transducer**: ±15 VDC supply, current output, and status signals
- **Oil level switch**: NC dry contact
- **Manual ground switch**: Auxiliary NC contact
- **Ross ground relay**: Coil drive and auxiliary contacts (NO, NC, Common)
- **Current shunt**: 15 A/50 mV

---

## 5. Hoffman Box — Power Distribution

*Source: `HoffmanBoxPowerDistribution.docx`*

### 5.1 Power Supply Inventory

| Supply | Voltage | Rating | Application | Status |
|---|---|---|---|---|
| KEPKO-120V PS | 120 VDC / 1A | G5 | Gate pulse H1 | Active |
| KEPKO-240V PS | 240 VDC / 0.25A | G5 | First gate pulse | Active |
| SOLA 85-15-2120 | ±15 VDC / 200 mA | F8 | Analog monitors, Danisense | **Obsolete** |
| 120 VAC:24 VAC xfmr | 24 VAC / 25 VA | F5 | Enerpro voltage (10W max) | Active |
| Lambda LND-X-152 | 12/24 VDC / 2A | E5 | Emergency Off, oil switches, 12V interlocks | **Obsolete** |
| AB-1747-P1 | 24 VDC | C5 | Slot 7 1746-IV16 VDC input | Active |
| Enerpro/MAD4030 | ±15 VDC | Regulator card | On-board DC-DC from 30 VDC | **Obsolete** |

### 5.2 Lambda LND-X-152 Configuration Issue

This obsolete supply is configured unconventionally:
- Two independent floating outputs with commons tied together.
- The −12 VDC terminal is tied to Hoffman box common.
- Result: "common" is at +12 VDC and "+12 VDC" is at +24 VDC relative to Hoffman box common.
- This means the current limit applies to the **sum** of both supply currents.
- **Recommendation:** Replace with separate +12 VDC and +24 VDC supplies.

### 5.3 Monitor Board Power

- Uses regulated ±15 VDC from the SOLA supply.
- The 30 VDC is dropped by two 3.3 V Zener diodes (1N4728) to ~23.4 VDC.
- Two Murata NMH2415S DC-DC converters (2 W each) provide isolated power:
  - One for general circuitry
  - One for remote voltage/current detection (isolates B118 and B132 grounds — good design)
- Output ripple: 70 mV p-p typical (150 mV p-p max). Better alternative: Traco TIM 2-2423 (50 mV p-p).
- DIP package NMH2415DC is being discontinued; SIP package NMH2415SC still available.

### 5.4 Regulator Card Power Budget

- On-board MAD4030 DC-DC converter creates ±15 VDC from the 30 VDC Enerpro control voltage.
- Rated at 4.5 W (150 mA per rail).
- Major current consumers: two BUF634 buffers (up to 250 mA each if driving low impedance).
- Estimated budget: ~200 mA for buffer outputs + ~50 mA for signal opamps.

### 5.5 Open Questions from Power Distribution Analysis

- Are TS-1 (E5) fuses oversized at 10 A?
- TS-2 pin 1 shows 26 V — should this be 24 V?
- TS-2 pin 3 does not appear connected — is it needed?
- Ground tank TS-6 says ±12 VDC but SOLA supply is ±15 VDC — which is correct?
- Missing fiber optic cable interconnects on wiring diagram.
- 12 kV SCR Driver Board C18 rated for 200 V — should be at least 240 V.

---

## 6. Controller Interfaces Between RF Subsystems

*Source: `interfacesBetweenRFSystemControllers.docx`*

### 6.1 Interface Architecture

SPEAR3 is upgrading three key RF subsystem controllers:
1. **LLRF controller** — Dimtel LLRF9 commercial system (amplitude/phase control of cavity RF fields)
2. **HVPS controller** — new PLC-based controller
3. **RF MPS controller** — new machine protection system for RF components

The high-power elements (klystron, HVPS hardware, cavities) remain unchanged. An **interface chassis** is being designed to interconnect all subsystems.

### 6.2 Interface Chassis Design

**Input Permits** (all active-high for fail-safe):

| Input | Signal Type |
|---|---|
| LLRF permit for HVPS to turn on | Optocoupler |
| HVPS controller "ready" status | Fiber optic receiver (HFBR-2412) |
| SPEAR PPS permit | 24 VDC |
| SPEAR orbit interlock permit | 24 VDC |
| RF MPS permit for HVPS | 24 VDC |
| Spare inputs | 24 VDC and/or 5 VDC |

**Output Permits** (all active-high):

| Output | Signal Type |
|---|---|
| LLRF enable | Optocoupler |
| HVPS phase control thyristor enable | Fiber optic transmitter (HFBR-1412) |
| HVPS crowbar inhibit | Fiber optic transmitter (HFBR-1412) |

**Output Status:**
- Status signals to RF MPS showing all input inhibit states and three output permit states (24 VDC logic).

### 6.3 General Design Principles

- All permits are **active high** — a cable break fails safely.
- All inputs are **optically isolated** using Broadcom/Avago HCPL-2400-000E optocouplers (response time in microseconds).
- Input optocouplers drive a logical **AND gate**, which feeds the HFBR-1412 fiber transmitters.
- Current design intent: crowbar enable to HVPS is always enabled; only the phase control thyristor trigger enable is removed on fault.
- An RF MPS fault or loss of HVPS status fiber removes the LLRF enable permit.
- RF MPS also sends a **redundant software command** via EPICS to instruct the HVPS controller to turn off.

---

## 7. RF System Machine Protection Requirements

*Source: `RFSystemMPSRequirements.docx`*

### 7.1 Protection Philosophy

Each RF subsystem must be protected from high-power faults (DC or RF). The general approach:
1. Eliminate stored energy in the faulting component.
2. Disable upstream power sources.
3. Notify downstream elements to shut down gracefully.

### 7.2 HVPS Protection

**Primary threat:** Internal faults (transformer arcs, overcurrent).

**Five methods to disable HVPS thyristor triggers:**

| # | Source | Path | Type |
|---|---|---|---|
| 1 | Fiber optic SCR Enable (LLRF) | Right Side Trigger Interconnect → all driver boards | Fiber optic |
| 2 | Transformer Arc Trigger | BNC-0 → Right Side Trigger Interconnect; also fires crowbar | Electronic |
| 3 | Fiber optic Klystron Crowbar (LLRF) | Left Side Trigger Interconnect → crowbar + disable | Fiber optic |
| 4 | Klystron Arc Trigger | BNC-12 → Left Side Trigger Interconnect → crowbar + disable | Electronic |
| 5 | PLC Force Crowbar (Slot-5 Out 3) | Right Side Trigger Interconnect → Slave CB Trig → both boards | PLC output |

**Stored energy management:**
- **Output filter capacitors**: Discharged by firing the optical thyristor crowbar stacks.
- **Input filter inductors**: Discharged by maintaining B-phase triggers (B+/B−) while disabling A and C phases, allowing current to free-wheel through the B-phase thyristors within ~2/3 of a cycle.

**Upstream disable:** Opening the 12.47 kV vacuum contactor (controlled by PPS and PLC).

### 7.3 Klystron Protection

**Fast faults:**
- Klystron arcs and waveguide arcs: HVPS crowbar fired immediately via fiber optic and electronic paths.
- Reflected power from klystron output coupler: should also trigger crowbar (design goal for new LLRF).

**Slow faults:**
- Cathode heater, focus/bucking coil currents, collector power, water flows, temperatures.
- Focus coil L/R time constant should be measured to determine response time budget.
- PLC extinguishes both fiber optic signals (SCR enable and crowbar).

### 7.4 Cavity Protection

- Main danger: arcing at cavity windows.
- LLRF senses over-voltage and excessive reflected power.
- LLRF redundantly removes drive power.
- LLRF removes permit from PLC; PLC extinguishes HVPS fiber optic signals.

### 7.5 Filter Inductor Discharge Detail

When triggers for phases A and C are inhibited on the driver boards:
- Pin P2-7 is driven high.
- This sets CLR input to U1B low (forcing output to logical 0) and sets external reset on U4 high (disabling astable operation).
- These actions inhibit all pulses to the thyristor gate transformer primary.
- Phase B thyristors continue to be triggered, providing a short-circuit path for inductor current discharge.

---

## 8. LLRF Upgrade Scope

*Source: `LLRFUpgradeTaskListRev0.docx`*

### 8.1 LLRF Controls

- Purchased: **Dimtel LLRF9** system — 4 units (2 operational + 2 spares).
- Interface with rest of system: one input permit (from MPS/PPS chain) and one output permit (LLRF fault status).

### 8.2 MPS System Upgrade

- Legacy PLC-5 (1771 hardware) → **ControlLogix 1756** using Rockwell Automation conversion kit.
- Hardware assembled, software written — needs testing with actual hardware.

### 8.3 Interface Chassis

A new chassis to connect MPS to the rest of the RF system and SPEAR3:

**Inputs:**
- One electrical input from LLRF9 (optocoupler)
- One fiber optic input from HVPS controller
- One electrical input from RF power detector (optocoupler)
- Possibly optical arc detectors (Microstep-MIS)
- SPEAR3 MPS permit, orbit interlock, and other external permits

**Outputs:**
- LLRF enable permit (optocoupler)
- HVPS SCR trigger enable (fiber optic)
- HVPS crowbar inhibit (fiber optic)
- Status to RF MPS

### 8.4 HVPS Controller Upgrade Scope

The HVPS controller upgrade includes:
- PLC migration (SLC-500 → ControlLogix)
- Possible regulator board redesign (address obsolete components)
- Interface chassis design and build
- Verification of all interlock paths

---

## 9. Testing & Commissioning Notes

*Sources: `hoffmanTestingNotes.docx`, `regulatorEnerproTestingNotes.docx`*

### 9.1 Enerpro Testing Procedures

Key test points and verification items for the Enerpro board:
- **TP1**: Response of input phase references
- **TP2**: Input to phase-locked loop (PLL)
- **TP3**: Delay output (TP7/TP12 for FCOG1200)
- **TP5**: Attenuation and phase shift
- **TP8**: Phase loss detection (TP15/TP16 for FCOG1200)

Phase references enter on J5 pins 1, 3, 5, sourced from 120 VAC instrument transformers T0A and T0C (drawing WD-730-794-05-C3). Verification required for voltage amplitudes, waveforms, phase order, and relative phase shifts using A-phase (TS-7 pin 1) as reference.

**Open question:** Can the FCOG1200 (12-pulse) board work with only the three phases already available, or are all six phases from the open-star transformers needed?

### 9.2 Regulator Board Testing Procedures

| Test Point | Signal | Purpose |
|---|---|---|
| TP4 | Buffered voltage readback | Cross-calibrate with voltage monitor |
| TP5 | Error amplifier output | Verify feedback loop behavior |
| TP7 | SIG HI contribution | Verify regulator output to Enerpro |
| TP9 | Voltage setpoint | Verify reference input |
| TP1 | Buffered current readback | Verify current measurement |
| TP3 | Current error amplifier | Verify current limit behavior |
| TP10 | Overvoltage trip setting | Verify threshold |
| TP11 | Overcurrent trip setting | Verify threshold |
| TP12 | Current setpoint reference | Verify from Enerpro |

**Recommended test sequence:**
1. Step changes in voltage setpoint via EPICS at various operating points.
2. Monitor TP9 (setpoint), TP7 (SIG HI), TP4 (voltage readback) simultaneously.
3. Capture startup transient when HVPS is turned on from EPICS.
4. Verify current limit (IL1) on TP12 and TP3 is far from active control.

### 9.3 Monitor Board Testing

The Monitor Board (SD-730-793-12-C3) is **not included** in the Trigger Enclosure Wiring Diagram WD-730-790-02. Connections need to be traced and the wiring diagram updated.
- **BNC1**: Isolated output of second voltage monitor
- **BNC2**: Isolated current output (from Danfysik)
- **J2H, J2G**: Reference voltage outputs

### 9.4 Regulator-Enerpro Integration Testing (April 2022)

**Problem:** Regulator board output (TP7) stayed constant regardless of HVPS output.

**Root cause:** PLC offset was too high. At higher HVPS output voltages, the PLC DAC voltage exceeded the required SIG HI value, causing the regulator to saturate at its lower Zener diode limit.

**Fix:** Reduced PLC offset (memory register adjustment), which lowered the PLC contribution to SIG HI and allowed the regulator to operate within its linear range.

**Enerpro timing:** Scope hold-off needed to be set appropriately to lock the CK1 signal from TP4.

---

## 10. EPICS PVs and Diagnostic Panels

*Source: `rfedmHvpsLabelsPvs.docx`*

### 10.1 EDM Panel Hierarchy

1. **RF Station** (operator panel) → RF Detail button →
2. **SPEAR RF Station** (expert panel) → HVPS button →
3. **SPEAR RF Klystron HVPS** (expert HVPS panel)

### 10.2 HVPS EPICS Process Variables

| Panel Label | PV Name | Description |
|---|---|---|
| Contactor Closed | `SRF1:HVPSCONTACT:CLOSE:STAT` | Aux relay: contactor closed |
| Contactor Open | `SRF1:HVPSCONTACT:OPEN:STAT` | Aux relay: contactor open |
| Contactor Status | `SRF1:HVPSCONTACT:ON:STAT` | Inverted contactor closed |
| Contactor Ready | `SRF1:HVPSCONTACT:READY:STAT` | Aux relay: contactor can be closed |
| Over Voltage | `SRF1:HVPS:VOLT:LTCH` | Voltage limit exceeded (reg. card) |
| Klystron Arc | `SRF1:HVPSKLYS:ARC:LTCH` | Arc sensed (ground tank + LHS trigger) |
| Transformer Arc | `SRF1:HVPSXFORM:ARC:LTCH` | Arc sensed (HVPS + RHS trigger) |
| Crowbar | `SRF1:HVPS:CROWBAR:LTCH` | Pulses to crowbar thyristors |
| Crowbar from RF | `SRF1:HVPSRF:CROWBAR:LTCH` | LLRF commanded crowbar fire |
| Emergency Off | `SRF1:HVPS:PANIC:LTCH` | Mushroom switch in ground tank |
| AC Current | `SRF1:HVPSAC:CURR:LTCH` | 12.47 kVAC mains overcurrent trip |
| Over Temperature | `SRF1:HVPS:TEMP:LTCH` | Thermal switch in HVPS oil |
| Oil Level | `SRF1:HVPSOIL:LEVEL:LTCH` | Oil level switch in HVPS oil |
| Transformer Press | `SRF1:HVPSXFORM:PRESS:LTCH` | Slow HVPS oil overpressure |
| Transfer Vac/Press | `SRF1:HVPSXFORM:VACM:LTCH` | Rapid overpressure and/or vacuum |
| Open Load | `SRF1:HVPS:OPENLOAD:LTCH` | HVPS-to-klystron connection open |
| 12 kV Available | `SRF1:HVPS12KV:VOLT:STAT` | 12.47 kVAC on phase A |
| AC Auxiliary Power | `SRF1:HVPSAC:POWER:STAT` | Control power in HVPS controller |
| DC Auxiliary Power | `SRF1:HVPSDC:POWER:STAT` | HVPS controller DC supplies on |
| Enerpro Fast Inhibit | `SRF1:HVPSENERFAST:ON:STAT` | Enerpro fast inhibit status |
| Enerpro Slow Start | `SRF1:HVPSENERSLOW:START:STAT` | Enerpro soft start status |
| Supply Status | `SRF1:HVPSSUPPLY:ON:STAT` | Contactor on + some interlocks clear |
| Supply Ready | `SRF1:HVPSSUPPLY:READY:STAT` | Supply ready to output HV |
| PPS | `SRF1:HVPS:PPS:STAT` | PPS chain made up |
| SCR 1 | `SRF1:HVPSSCR1:ON:STAT` | Left side board thyristor firing |
| SCR 2 | `SRF1:HVPSSCR2:ON:STAT` | Right side board thyristor firing |

### 10.3 Trip Diagnosis Procedure

When an RF trip occurs:
1. Take a screenshot of the **SPEAR RF Klystron HVPS** panel.
2. Record which status bars show faults (latched indicators).
3. The pattern of latched faults reveals the cause (e.g., klystron arc vs. transformer arc vs. overcurrent).

---

## 11. Known Documentation Errors

Errors identified across the design notes that should be corrected in future drawing revisions:

| Drawing | Error | Correction |
|---|---|---|
| WD-730-794-02-C0 | RR relay labeled "PPS", K4 relay labeled "RESET" | Labels should be **swapped**: K4 = PPS, RR = RESET |
| WD-730-794-02-C0 | MX relay connection shown as BB–CC1 only | Should include K4 contacts (BB→BB1) and 86L lockout relay (BB1→BB2) |
| WD-730-794-02-C0 | Contactor Open labeled as from S3 aux contact | Needs field verification |
| GP 439-704-02-C1 | L1 coil mislabeled as L2 | L1 is the hold coil; L2 is the close coil |
| ID 308-801-06-C1 | Wire W1 shown connected | W1 is not connected to anything; label B2 and label 3 should be removed |
| Trigger Encl. Wiring | P1 pin numbering inverted for driver boards | Headers have inverted pin numbers vs. driver board schematics |
| 12 kV SCR Driver Board | C18 rated 200 V | Should be at least 240 V based on operating voltage |

---

## 12. Component Obsolescence Notes

| Component | Function | Status | Recommended Replacement |
|---|---|---|---|
| **VTL5C** | Opto variable resistor (regulator board) | Obsolete | No direct replacement identified |
| **MAD4030-B** | ±15 VDC DC-DC converter (regulator board) | Obsolete (Astec/Artesyn) | No pin-compatible replacement confirmed |
| **SOLA 85-15-2120** | ±15 VDC dual supply | Obsolete | Consider Acopian or equivalent |
| **Lambda LND-X-152** | 12/24 VDC 2A supply | Obsolete (TDK/Lambda) | Replace with separate +12 VDC and +24 VDC supplies |
| **1N3064** | Small signal switching diode | Obsolete | Vishay 1N4150 (Digikey rec.) or BAW27 (Vishay direct) |
| **BUF634** (DIP) | High-current buffer (regulator/monitor boards) | DIP discontinued | BUF634A (no DIP available; higher performance) |
| **Murata NMH2415DC** (DIP) | DC-DC converter (monitor board) | Being discontinued | NMH2415SC (SIP package, still available) |
| **Burndy GOB12-88PNE** | PPS 8-pin connector | Possibly Souriau Trim Trio | Verify current part number |

---

## 13. Source Document Cross-Reference

| Document | Primary Topics | Key Drawings Referenced |
|---|---|---|
| `EnerproVoltageandCurrentRegulatorBoardNotes.docx` | Regulator board SD-237-230-14-C1: components, circuit operation, transfer functions, interlocks | SD-237-230-14-C1, WD-730-792-01, WD-730-794-04 |
| `controllerFiberOpticConnections.docx` | Three fiber optic signals, trigger interconnect boards, driver boards, commands bus | SD-730-793-03-C4, SD-730-793-07-C2, SD-730-793-08-C1, WD-730-790-02-C6 |
| `HoffmanBoxPPSWiring.docx` | PPS connectors, vacuum contactor control, K4/RR/MX relay logic, grounding tank PPS | WD-730-790-02-C6, WD-730-794-02-C0, GP 439-704-02-C1, rossEngr713203 |
| `HoffmanBoxPowerDistribution.docx` | Power supply inventory, obsolescence issues, monitor/regulator board power budgets | WD-730-790-02-C6, SD-730-793-12-C3, SD-237-230-14-C0 |
| `interfacesBetweenRFSystemControllers.docx` | Interface chassis design, permit architecture, LLRF/HVPS/MPS/PPS interconnections | — |
| `RFSystemMPSRequirements.docx` | Machine protection for HVPS, klystron, cavities; fault response; stored energy management | SD-730-793-03-C4, SD-730-793-07-C2, SD-730-793-08-C1 |
| `LLRFUpgradeTaskListRev0.docx` | LLRF9 procurement, MPS upgrade PLC-5→ControlLogix, interface chassis scope | — |
| `hoffmanTestingNotes.docx` | Test procedures for Enerpro, regulator board, monitor board | SD-237-230-14-C1, SD-730-793-12-C3, WD-730-790-02 |
| `regulatorEnerproTestingNotes.docx` | April 2022 field testing: regulator saturation fix, PLC offset adjustment, Enerpro timing | — |
| `rfedmHvpsLabelsPvs.docx` | EPICS PVs for HVPS diagnostics, EDM panel navigation, trip diagnosis | — |

---

*This document synthesizes all design notes in `hvps/architecture/designNotes/`. For detailed circuit analysis and transfer functions, refer to the original source documents. For system-level architecture, see also `00-architecture-overview.md` in this directory.*
