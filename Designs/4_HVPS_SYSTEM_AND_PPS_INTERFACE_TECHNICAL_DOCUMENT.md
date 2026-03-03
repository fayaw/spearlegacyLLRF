# SPEAR3 HVPS System and PPS Interface — Technical Document
## Current System Analysis and Upgrade Engineering Design

**Document Number**: 4  
**Version**: 1.0  
**Date**: 2026-03-03  
**Status**: Engineering Reference  
**Purpose**: Comprehensive technical document explaining how the current HVPS system works, the PPS interface architecture, and the engineering design for the upgraded system.

**Schematic References**:
- `gp4397040201.pdf` — Vacuum contactor controller schematic
- `rossEngr713203.pdf` — Ross Engineering vacuum contactor internal schematic (1978)
- `sd7307900501.pdf` — Grounding (termination) tank schematic
- `wd7307900103.pdf` — Interconnection diagram: B118 controller ↔ contactor disconnect and termination tank
- `wd7307900206.pdf` — Wiring diagram: HVPS controller inside B118 (Hoffman Box)
- `wd7307940600.pdf` — Interconnection diagram: B118 controller ↔ contactor disconnect

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current HVPS System Overview](#2-current-hvps-system-overview)
3. [HVPS Power Electronics](#3-hvps-power-electronics)
4. [Current HVPS Controller (Hoffman Box)](#4-current-hvps-controller-hoffman-box)
5. [PPS Interface — Current System](#5-pps-interface--current-system)
6. [Vacuum Contactor Controller — Relay Logic](#6-vacuum-contactor-controller--relay-logic)
7. [Ross Grounding Switch](#7-ross-grounding-switch)
8. [Fiber-Optic Interfaces — HVPS to LLRF](#8-fiber-optic-interfaces--hvps-to-llrf)
9. [Legacy HVPS Control Software](#9-legacy-hvps-control-software)
10. [Upgrade System Engineering Design](#10-upgrade-system-engineering-design)
11. [Upgraded HVPS Controller Architecture](#11-upgraded-hvps-controller-architecture)
12. [Upgraded PPS Interface Design](#12-upgraded-pps-interface-design)
13. [Interface Chassis — HVPS Integration](#13-interface-chassis--hvps-integration)
14. [HVPS EPICS Integration and Python Supervisory Loop](#14-hvps-epics-integration-and-python-supervisory-loop)
15. [Known Documentation Issues and Required Verifications](#15-known-documentation-issues-and-required-verifications)
16. [Risk Assessment and Mitigation](#16-risk-assessment-and-mitigation)
17. [Appendix A: Terminal Strip Wiring Tables](#appendix-a-terminal-strip-wiring-tables)
18. [Appendix B: PLC I/O Mapping](#appendix-b-plc-io-mapping)
19. [Appendix C: Schematic Drawing Cross-Reference](#appendix-c-schematic-drawing-cross-reference)

---

## 1. Executive Summary

The SPEAR3 High Voltage Power Supply (HVPS) is a critical subsystem of the RF station that provides up to ~90 kV to the klystron cathode to generate ~1 MW of RF power at 476 MHz. The HVPS controller system is being upgraded from an Allen-Bradley SLC-500 PLC to a modern CompactLogix PLC as part of the LLRF upgrade project.

**The HVPS upgrade is particularly complicated because of the PPS (Personnel Protection System) interface.** The PPS is a safety-critical system that protects personnel by ensuring the high voltage is removed and the klystron output is grounded before anyone enters hazardous areas. The PPS interface wiring passes *through* the HVPS controller (Hoffman box), creating a coupling between our control electronics and the safety system that must be carefully managed.

### Key Concerns

1. **PPS wiring passes through the Hoffman box** — opening the controller box for maintenance may require radiation safety work control forms and system retests
2. **The Ross grounding switch is controlled via the PLC**, not directly by PPS — a PLC failure could theoretically prevent the safety grounding function
3. **Multiple documentation inconsistencies** exist in the schematic drawings, requiring field verification before the upgrade proceeds
4. **The contactor controller relay logic** is complex (K4, RR, TX, MX relays) and documentation errors exist in the labeling of these relays
5. **PPS standards compliance** of the existing design is unclear and must be reviewed with SSRL protection management

### Document Scope

This document covers:
- **Part I (Sections 2–9)**: How the current HVPS system works, from power electronics through PPS interface to legacy software
- **Part II (Sections 10–14)**: Engineering design for the upgraded system
- **Part III (Sections 15–16)**: Known issues, required verifications, and risk assessment
- **Appendices**: Detailed wiring tables, PLC I/O mapping, and drawing cross-references

---

## 2. Current HVPS System Overview

### 2.1 Physical Architecture

The HVPS system consists of the following major components:

| Component | Location | Function |
|-----------|----------|----------|
| **12.47 kV Input Contactor** | Switchgear | Vacuum contactor connecting utility power to HVPS transformer |
| **Contactor Controller** | Inside switchgear enclosure | Relay logic to close/hold/trip the vacuum contactor |
| **HVPS Transformer & Rectifier** | HVPS vault | Steps up and rectifies to DC for klystron |
| **Oil Cooling System** | HVPS vault | Cools transformer, SCR tanks, crowbar |
| **SCR Phase-Control Stack** | HVPS vault | Regulates output voltage via thyristor firing angle |
| **Crowbar Circuit** | HVPS vault | Fast short-circuit protection for klystron arcs |
| **Termination (Grounding) Tank** | Near klystron | Contains Ross grounding switch + klystron arc detection |
| **HVPS Controller (Hoffman Box)** | Building 118 | SLC-500 PLC + Enerpro gate driver + analog regulation |
| **PPS Interface** | On/through Hoffman Box | GOB12-88PNE connector + wiring to PLC and terminal strips |

### 2.2 Power Flow

```
Utility 12.47 kV AC
        │
        ▼
┌─────────────────────┐
│  Vacuum Contactor    │◄── Controller (L1 hold, L2 close coils)
│  (12.47 kV, 3-phase)│     ▲
└────────┬────────────┘     │ K4, MX, TX relay logic
         │                  │
         ▼                  │
┌─────────────────────┐     │
│  HVPS Transformer    │     │
│  + Rectifier         │     │
└────────┬────────────┘     │
         │                  │
         ▼                  │
┌─────────────────────┐     │
│  SCR Phase-Control   │◄───┤ Enerpro gate driver
│  Thyristor Stack     │     │ (controlled by PLC)
└────────┬────────────┘     │
         │                  │
         ▼                  │
┌─────────────────────┐     │
│  Output Filter       │     │
│  0 – ~90 kV DC      │     │
└────────┬────────────┘     │
         │                  │
         ▼                  │
┌─────────────────────┐     │
│  Crowbar Circuit     │◄───┤ Arc detection triggers
│  (klystron protect)  │     │
└────────┬────────────┘     │
         │                  │
         ▼                  │
┌─────────────────────┐     │
│  Ross Grounding      │◄───┤ PPS Chain 2 (via PLC relay)
│  Switch              │     │
│  (Termination Tank)  │     │
└────────┬────────────┘     │
         │                  │
         ▼                  │
   Klystron Cathode         │
   (~90 kV, ~15 A max)     │
                            │
┌─────────────────────┐     │
│  HVPS Controller     │────┘
│  (Hoffman Box, B118) │
│  SLC-500 PLC         │
│  + Enerpro boards    │
│  + Analog regulator  │
│  + PPS interface     │
└─────────────────────┘
```

### 2.3 Key Electrical Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| Input voltage | 12.47 kV AC, 3-phase | Via vacuum contactor |
| Output voltage | 0 to ~90 kV DC | Phase-controlled via SCRs |
| Klystron turn-on voltage | ~50 kV | `SRF1:HVPS:VOLT:MIN` |
| Nominal operating voltage | ~70–80 kV | Depends on beam current |
| Maximum output current | ~15 A | Measured via 15A/50mV shunt |
| Output power | ~1 MW | Delivered to klystron |

---

## 3. HVPS Power Electronics

### 3.1 SCR Phase-Control Regulation

The HVPS output voltage is regulated by controlling the firing angle of a thyristor (SCR) stack. The Enerpro gate driver boards receive a control signal from the PLC's analog output and translate it into precisely-timed gate pulses for each SCR. By adjusting the firing angle, the average DC output voltage is varied from 0 to ~90 kV.

**Enerpro Gate Driver Boards**: The current boards are aging and need replacement. Five new Enerpro boards (~$4,000 total) are budgeted for the upgrade. These boards interface between the PLC's analog control signal and the high-power SCR gates.

### 3.2 Crowbar Protection Circuit

The crowbar circuit is a fast-acting protection system for the klystron. If a klystron arc is detected (via sensors in the termination tank or HVPS transformer), the crowbar fires a thyristor that short-circuits the HVPS output, rapidly dumping the stored energy before it can damage the klystron.

**Crowbar Triggers** (two hardware sensors):
1. **Klystron arc trigger** — from the termination tank
2. **Transformer arc trigger** — from the HVPS transformer

Per SLAC PUB 7591, the HVPS stored energy is not sufficient to damage the klystron even without the crowbar firing. This is an important safety consideration — it means we do NOT require the LLRF or RF MPS to fire the crowbar. The crowbar remains a defense-in-depth measure.

The HVPS has a fiber-optic input (`KLYSTRON CROWBAR`) that can externally trigger the crowbar. Currently, this must be kept illuminated (enabled) for the HVPS to operate. We will maintain this signal from the Interface Chassis.

### 3.3 Oil Cooling System

Oil level sensors in three tanks are monitored by the PLC:
- **Ground (termination) tank oil** — Slot-6 AB-1746-IB16 IN8
- **Crowbar tank oil** — Slot-6 AB-1746-IB16 IN10
- **SCR tank oil** — Slot-6 AB-1746-IB16 IN11

### 3.4 Current Measurement

A Danfysik current transductor provides the DC output current measurement. It connects via TS-6 to:
- **Slot-9 AB-1746-NI4 In3+/In3−** for analog current readback
- **TS-3** for voltage monitoring
- The Danfysik requires ±15 VDC power (from SOLA PS-6) and provides a status output

---

## 4. Current HVPS Controller (Hoffman Box)

### 4.1 Physical Layout

The HVPS controller is housed in a Hoffman electrical enclosure in Building 118. It contains:

| Component | Model | Function |
|-----------|-------|----------|
| **PLC Processor** | Allen-Bradley SLC-500 | Main controller |
| **Digital Input** | AB 1746-IB16 (Slot 6) | 16 digital inputs |
| **Digital I/O** | AB 1746-IO8 (Slot 2) | 8 digital I/O for Ross switch, etc. |
| **Relay Output** | AB 1746-OX8 (Slot 5) | 8 relay outputs for contactor, PPS |
| **Digital Input** | AB 1746-IV16 (Slot 7) | 16 digital inputs for contactor status |
| **Analog Input** | AB 1746-NI4 (Slot 9) | 4 analog inputs for current monitoring |
| **Enerpro Gate Driver** | Commercial board | SCR firing pulse generation |
| **Analog Regulator** | Custom board | Analog voltage regulation loop |
| **SOLA Power Supply** | PS-6 | ±15 VDC, +12 VDC for instrumentation |
| **Touch Panel** | Operator interface | Local control and monitoring |

### 4.2 Terminal Strips

The Hoffman box contains multiple terminal strips that serve as wiring interface points:

| Terminal Strip | Function | Key Signals |
|---------------|----------|-------------|
| **TS-2** | Control Power | System common, +24 VDC, control power distribution |
| **TS-3** | Voltage Monitor | ±15V, current monitor signals |
| **TS-4** | Transformer Interlocks | Transformer safety interlocks |
| **TS-5** | Contactor Controls | PPS interface, contactor on/off/enable/status |
| **TS-6** | Grounding Tank Interface | Ross switch, oil levels, current shunt, Danfysik |
| **TS-8** | PPS/Local Panel | PPS permit signals, local panel LEDs |

### 4.3 PLC Program Structure (SLC-500)

The SLC-500 ladder logic is organized into rungs that control:

| Rung Range | Function |
|------------|----------|
| 0002 | Contactor close command (Master Ready + O:5/1) |
| 0014 | Emergency off bits from PPS 1 |
| 0015 | PPS ON status (PPS 1 OR PPS 2 → B3:1) |
| 0016 | Ross Ground Switch relay (PPS 1 AND PPS 2 AND others) |
| 0017 | Contactor Enable (Touch Panel Enable AND Emergency Off Clear → 1746-OX8/2) |
| 0068 | Bias Power enable (PPS 2 AND touch panel key enable) |

---

## 5. PPS Interface — Current System

### 5.1 PPS System Architecture

The PPS (Personnel Protection System) provides two independent safety chains to the HVPS:

**Chain 1 — Input Contactor Control**: Removes 12.47 kV input power to the HVPS
- PPS removes control voltage → contactor controller de-energizes → vacuum contactor opens
- Readback via auxiliary contact S5 on vacuum contactor

**Chain 2 — Ross Grounding Switch**: Shorts the HVPS output (klystron input)
- PPS command → PLC relay → 120 VAC to Ross relay coil → switch closes (grounds output)
- Readback via auxiliary contacts on Ross switch

### 5.2 PPS Connector (GOB12-88PNE)

The PPS interface connector is a Burndy/Souriau circular 8-pin connector (GOB12-88PNE, now likely a Souriau Trim Trio replacement). It is mounted on a locked PPS box secured to the Hoffman controller.

| Pin | Wire Color | Function | Termination |
|-----|-----------|----------|-------------|
| **A** | Red/Black | Contactor controls readback | TS-5 15 (S5 common on contactor) |
| **B** | Red | Contactor controls readback | TS-5 14 (S5 NC contact) + PPS1 Green LED |
| **C** | Orange | Ground Relay readback | TS-6 12 (Ross switch aux NC) |
| **D** | Green/Black | Ground Relay readback | TS-6 11 (Ross switch aux common) |
| **E** | Green | PPS 1 Permit | TS-8 1 → Slot 6 IN14 + PPS4 Red LED |
| **F** | Black | PPS Common (contactor) | TS-5 3 |
| **G** | Blue | PPS 2 Permit | TS-8 3 → Slot 6 IN15 + PPS3 Red LED |
| **H** | White | PPS Common (permits) | TS-8 6 + System common |

### 5.3 PPS Signal Flow

```
                    PPS Interface Chassis (External)
                    ┌────────────────────────────────┐
                    │                                │
     PPS Chain 1    │  Pins E-F: PPS 1 (24 VDC)  ──┤── Provides 24 VDC enable
     (Contactor)    │  Pins G-H: PPS 2 (24 VDC)  ──┤── Provides 24 VDC enable
                    │                                │
     Readbacks      │  Pins A-B: Contactor status ◄─┤── Expects closed contact = safe
     to PPS         │  Pins C-D: Ground sw status ◄─┤── Expects closed contact = safe
                    └────────────────────────────────┘
                              │         ▲
                              │         │
                    ══════════╪═════════╪══════════════
                    Inside Hoffman Box   │
                              │         │
                              ▼         │
                    ┌─────────────────┐  │
                    │   SLC-500 PLC   │  │
                    │                 │  │
                    │ Slot 6 IN14 ◄──┤──┤── PPS 1 input
                    │ Slot 6 IN15 ◄──┤──┤── PPS 2 input
                    │                 │  │
                    │ Slot 5 OUT2 ───┤──┤──► K4 relay coil (Contactor Enable)
                    │                 │  │     Source: PPS 1 via OX8 relay contacts
                    │ Slot 2 OUT3 ───┤──┤──► Ross Switch relay coil (120 VAC)
                    │                 │  │
                    │ Slot 7 IN0-3 ◄─┤──┤── Contactor status (blocking, overcurrent,
                    │                 │  │   closed, ready) from TS-5
                    └─────────────────┘  │
                                         │
                              ┌──────────┘
                              │ Readback wiring
                              ▼
                    TS-5 14,15 → Pin A,B (contactor S5 aux contacts)
                    TS-6 11,12 → Pin C,D (Ross switch aux contacts)
```

### 5.4 Critical PPS Safety Analysis

**Contactor Enable (Chain 1) — PPS-to-K4 Relay Path**:

The PPS 1 signal (24 VDC from pin E) is the *source voltage* for the relay output on Slot 5 AB-1746-OX8 position 2. This OX8 module contains mechanical relay contacts. Even if the PLC fails:
- If the PPS does not source 24 VDC, the relay contact closure cannot energize K4
- **This fails safe** — PLC failure cannot provide power to K4 if PPS has removed its permit

**Ross Ground Switch (Chain 2) — PPS-to-Ross Path**:

The Ross grounding switch coil is energized via Slot 2 AB-1746-IO8 OUT3, which provides **120 VAC**. The PLC ladder logic (rung 0016) requires both PPS 1 AND PPS 2 to be enabled before the relay can energize the Ross switch coil.

> ⚠️ **SAFETY CONCERN**: If the PLC fails in a state where the Ross relay is energized and PPS subsequently requests de-energization, the PLC may not respond. This means the Ross switch may not close (ground) when PPS commands it. This is a potential single-point failure in the PPS safety chain.

### 5.5 PPS Readbacks

The PPS external interface chassis monitors two sets of auxiliary contacts to verify the state of the safety functions:

**Contactor Readback (Pins A-B)**:
- Connected to S5 auxiliary contacts on the vacuum contactor
- Pin A → TS-5 15 → S5 common (wire 21 to TB2)
- Pin B → TS-5 14 → S5 NC contact (wire 22 to TB2)
- **Contact closed = contactor OPEN** (safe state)
- **Contact open = contactor CLOSED** (energized state)

**Ross Switch Readback (Pins C-D)**:
- Connected to auxiliary contacts on the Ross grounding switch
- Pin C → TS-6 12 → Ross switch auxiliary NC
- Pin D → TS-6 11 → Ross switch auxiliary common
- **Contact closed = switch CLOSED** (grounding = safe state)
- **Contact open = switch OPEN** (power flowing to klystron)

### 5.6 Local PPS Status Indicators

An AMP 8-pin connector (J2) drives four LEDs on the PPS box atop the Hoffman box:

| LED | Color | Signal | Meaning |
|-----|-------|--------|---------|
| PPS1 | Green | Pins A-B readback | Contactor status |
| PPS2 | Green | Pins C-D readback | Ross switch status |
| PPS3 | Red | PPS 2 permit | PPS 2 enabled |
| PPS4 | Red | PPS 1 permit | PPS 1 enabled |

There is **no PPS monitoring inside the PLC chassis** — monitoring is only via the external LEDs.

---

## 6. Vacuum Contactor Controller — Relay Logic

### 6.1 Controller Overview

The vacuum contactor controller is a separate enclosure within the switchgear that manages the opening and closing of the 12.47 kV vacuum contactor. Its internal schematic is documented in `gp4397040201.pdf` and the vacuum contactor internals in `rossEngr713203.pdf`.

### 6.2 Contactor Coils

The vacuum contactor uses a **two-coil design** (ref: `rossEngr713203.pdf`):

| Coil | Function | Power Level | Activation |
|------|----------|-------------|------------|
| **L2** | Close coil | High power | Energized briefly to mechanically close the contactor |
| **L1** | Hold coil | Low power | Energized continuously to hold the contactor closed |

This two-stage approach minimizes continuous power consumption while providing sufficient electromagnetic force to initially close the large mechanical contactor.

> ⚠️ **Documentation Error**: `gp4397040201.pdf` mislabels L1 as L2, identifying two different coils with the same name. The `rossEngr713203.pdf` drawing has the correct labeling.

### 6.3 Key Relays

| Relay | Function | Effect When Energized |
|-------|----------|----------------------|
| **K1** | Close permit | Allows the close coil L2 to be energized; requires MX to be energized |
| **K3** | Ready indicator | Powered by storage capacitor C6; indicates controller has sufficient energy to close contactor |
| **K4** | **PPS/Reset control** | Controls MX relay AND removes all control power to the contactor controller |
| **MX** | Main enable | Directly controls hold coil L1; must be energized for contactor to remain closed |
| **TX** | Overcurrent trip latch | Summarizes MCO protection relay faults; latches on fault |
| **RR** | Reset relay | Prevents TX from latching; acts as fault reset |

### 6.4 Control Logic Flow

**Closing the Contactor (normal turn-on)**:
1. K4 relay must be energized (PPS permit via PLC)
2. MX relay can then be energized (K4 NO contact + 86 lockout NC contact in series with MX coil)
3. With MX energized, K1 can be energized (along with other conditions)
4. K1 energized → close coil L2 fires → contactor mechanically closes
5. After closing, hold coil L1 maintains the contactor position (MX must stay energized)
6. Storage capacitor C6 charges → K3 energizes → controller is "ready"

**Opening the Contactor (fault/PPS trip)**:
1. K4 de-energized (PPS permit removed via PLC relay output)
2. K4 de-energization simultaneously:
   - Opens the MX coil circuit (K4 NO contact in series) → MX de-energizes
   - Removes all control power to the contactor controller
3. MX de-energization opens the L1 hold coil circuit → contactor opens
4. Controller stored energy (C6) dissipates → K3 de-energizes
5. **Re-closing requires several seconds** while C6 recharges after K4 is re-energized

**Overcurrent Trip (MCO protection)**:
1. One of 4 MCO protection relays (4 phases: 3 phase + neutral) detects overcurrent
2. MCO contact closure energizes TX relay
3. TX relay latches via its own NO contact (self-hold circuit)
4. TX removes permit from hold coil chain → contactor opens
5. TX remains latched even after MCO fault clears
6. To reset: RR relay must be energized (via PLC) AND all MCO faults cleared AND either RR energized or local reset switch pressed

### 6.5 Wiring Between Hoffman Box and Contactor Controller

The trunk cable between TS-5 (Hoffman Box) and TB2 (Contactor Disconnect) carries all contactor control signals (ref: `wd7307940600.pdf`):

| TS-5 | Wire Color | TB2 | Function |
|------|-----------|-----|----------|
| 1 | Green/White | CC1 | Common |
| 2 | Red/Black | BB | On (contactor close command) |
| 3 | White | CC | PPS Common |
| 4 | Black | 11? | PPS Permit → K4 coil |
| 5 | Red/White | EE | Reset → RR coil |
| 6 | Blue/White | 10 | Auxiliary Trip |
| 7 | Blue/Black | 7 | Overcurrent NC (blocking relay S1-3 NC) |
| 8 | Green/Black | 9 | Interlock Common |
| 9 | Black/White | 8 | Overcurrent NO (S2-1 NO) |
| 10 | White/Black | DD | Contactor Closed (S3-3 NC) |
| 11 | Orange | W | Contactor Open (S3-1 NO) |
| 12 | Orange/Black | 14 | Contactor Ready NO (S4-1 NO) |
| 13 | Blue | 16 | Contactor Ready NC (S4-3 NC) |
| 14 | Green | 22 | PPS Monitor Common (S5-3 NC) |
| 15 | Red | 21 | PPS Monitor (S5-2 Common) |

### 6.6 Labeling Errors in Documentation

Based on Jim Sebek's analysis in `HoffmanBoxPPSWiring.docx`:

1. **RR and K4 labels are likely swapped** on `WD-730-794-02-C0`:
   - The drawing labels RR as "PPS" relay and K4 as "Reset" relay
   - Analysis shows K4 is actually the PPS control relay (controls MX and all power)
   - RR is actually the reset relay (prevents TX from latching)

2. **K4 NO and 86 NC contacts are missing** from `WD-730-794-02-C0` between wire BB and MX coil

3. **TS-5 positions 4 and 5 may have swapped functions** (PPS Permit vs Reset) due to the RR/K4 labeling error

---

## 7. Ross Grounding Switch

### 7.1 Function

The Ross Engineering grounding switch (ref: `rossEngr713203.pdf`, `sd7307900501.pdf`) is located in the termination (grounding) tank a few feet upstream of the klystron. Its purpose is to short-circuit the HVPS output to ground, ensuring that no high voltage reaches the klystron when personnel access is required.

### 7.2 Operation

- **Normal state (de-energized)**: Switch is CLOSED — output is grounded (safe for personnel access)
- **Operating state (energized)**: Switch is OPEN — power can flow from HVPS to klystron
- Coil requires 120 VAC to hold the switch open
- De-energization returns the switch to its spring-loaded closed (grounded) position

### 7.3 Control Path

```
PPS 1 AND PPS 2 (both enabled)
        │
        ▼
PLC Ladder Rung 0016 (AND logic)
        │
        ▼
Slot 2  AB-1746-IO8  OUT3 (120 VAC relay output)
        │
        ▼
TS-6 13,14 → Cable → Ross Relay Coil (P5-F, P5-E)
        │
        ▼
Ross Switch OPENS (power can flow to klystron)
```

### 7.4 Auxiliary Contacts

| Contact | Terminal | Function | Connection |
|---------|----------|----------|------------|
| Ross Aux NC | TS-6 11, P5-J | Normal closed = switch grounding | PPS pin D + Slot-6 IN9 (via TS-6 10) |
| Ross Aux NO | TS-6 19, P5-I | Normal open = switch open | Slot-7 IN13 + TS-4 3 (transformer interlocks) |
| Ross Aux Common | TS-6 12, P5-H | Common terminal | PPS pin C |
| Manual Ground SW NC | TS-6 9, P5-C | Manual ground switch | Slot-6 IN? |
| Manual Ground SW Common | TS-6 10, P5-D | Manual ground switch common | |

### 7.5 Safety Concern — PLC in PPS Path

> ⚠️ **CRITICAL DESIGN ISSUE**: The Ross grounding switch coil is energized *via the PLC*. The 120 VAC to the Ross relay coil passes through a PLC relay module (Slot 2, AB-1746-IO8 OUT3). This means:
>
> 1. A PLC failure that keeps the relay energized could prevent the Ross switch from closing when PPS demands it
> 2. The PLC is a programmable device in a safety-critical path — this may not meet current PPS standards
> 3. A possible fault scenario (identified by Jim Sebek): "the PLC fails and sources the 120 VAC signal to the coil of the Ross Ground Switch Relay with no command given by the PPS system"
>
> **This is the single most important PPS interface issue that must be resolved before the upgrade proceeds.**

---

## 8. Fiber-Optic Interfaces — HVPS to LLRF

### 8.1 Overview

The HVPS controller uses three fiber-optic signals for fast hardware communication with the LLRF system:

| Signal | Direction | Fiber Component | Function |
|--------|-----------|-----------------|----------|
| **SCR ENABLE** | LLRF → HVPS | HFBR-1412 (TX) / HFBR-2412 (RX) | External permit: allows SCR firing if illuminated |
| **KLYSTRON CROWBAR** | LLRF → HVPS | HFBR-1412 (TX) / HFBR-2412 (RX) | External crowbar trigger: must be illuminated for HVPS to operate |
| **STATUS** | HVPS → LLRF | HFBR-1412 (TX) / HFBR-2412 (RX) | HVPS status: enabled if controller powered AND no crowbar trigger |

### 8.2 STATUS Signal Logic

The HVPS STATUS fiber-optic output is enabled (illuminated) when ALL of the following are true:
1. The HVPS controller is powered on
2. No crowbar trigger has been generated by hardware sensors (klystron arc, transformer arc)
3. No crowbar trigger has been generated by the fiber-optic input
4. No digital signal from the HVPS controller itself

If STATUS is not enabled, the LLRF controller should NOT receive a permit to turn on.

### 8.3 SCR ENABLE Signal

The SCR ENABLE is a fast hardware path from the LLRF to the HVPS. When the LLRF detects an RF fault:
1. LLRF zeroes its DAC output (removes drive signal)
2. LLRF opens the RF switch to the drive amplifier
3. LLRF removes SCR ENABLE → HVPS stops firing SCRs → output voltage decays

This protects the klystron collector from dissipating full HVPS power when no RF output is present.

### 8.4 Critical Recovery Logic Issue

> **Design Consideration**: When the Interface Chassis removes the permit from the LLRF, the LLRF9 status output goes to OFF (low). This in turn tells the Interface Chassis that LLRF is faulted, which would prevent the HVPS from being re-enabled. To recover from this circular dependency:
>
> 1. The Interface Chassis logic must be designed to distinguish between "LLRF faulted" and "LLRF disabled by our own permit removal"
> 2. We need to coordinate with the HVPS controller to ensure STATUS turns off when SCR ENABLE is removed
> 3. The recovery sequence must be engineered so that once the HVPS is confirmed off, the LLRF permit can be restored

---

## 9. Legacy HVPS Control Software

### 9.1 Overview

The legacy HVPS control loop runs as an SNL (State Notation Language) program (`rf_hvps_loop.st`) on a VxWorks RTOS. Written by Mike Zelazny in 1997 (with modifications by Stephanie Allison and Robert Sass), it manages the HVPS voltage setpoint to maintain stable klystron operation.

### 9.2 State Machine

The HVPS loop operates in four states:

```
        ┌──────┐
        │ init │
        └──┬───┘
           │
           ▼
        ┌──────┐   station ON &     ┌──────┐
        │ off  │──────────────────►│  on  │
        └──┬───┘   ctrl=ON          └──┬───┘
           │                           │
           │   station ON &            │ ctrl=PROC
           │   ctrl=PROC              ▼
           │                    ┌──────────┐
           └───────────────────►│  proc    │
                                │(process) │
                                └──────────┘
```

### 9.3 Operating Modes

| State | Condition | Action | Update Rate |
|-------|-----------|--------|-------------|
| **OFF** | Station OFF or PARK | No action; wait for station turn-on | — |
| **PROC** (Process) | Station ON, ctrl=PROC | Ramp voltage up or down based on power/vacuum/voltage conditions | ~0.5 Hz (event-driven or 10s max) |
| **ON** | Station ON, ctrl=ON | Maintain constant drive power (ON_CW) or gap voltage (TUNE) | ~0.5 Hz (event-driven or 10s max) |

### 9.4 PROCESS Mode Algorithm

In PROCESS mode, the loop decides whether to increase or decrease voltage:

**Decrease voltage if ANY of**:
- Klystron forward power > max allowed (`max_klystron_forward_power`)
- Cavity gap voltage above setpoint (MAJOR severity on `gap_voltage_check`)
- Worst cavity vacuum too high (MAJOR severity on `cavity_vacuum_check`)

**Increase voltage otherwise** (all conditions nominal)

The voltage delta is configurable:
- `delta_proc_voltage_up` — increase step (typically positive)
- `delta_proc_voltage_down` — decrease step (typically negative)

### 9.5 ON Mode Algorithm

In ON mode, the control variable depends on the station state:

**ON_CW mode** (direct loop active):
- Controls based on klystron drive power error
- `delta_hvps_voltage = -delta_on_voltage` (negative feedback on drive power)
- Goal: keep drive power constant by adjusting HVPS

**TUNE mode** (direct loop off):
- Controls based on gap voltage error
- `delta_hvps_voltage = delta_tune_voltage`
- Goal: keep gap voltage constant by adjusting HVPS

### 9.6 Voltage Safety Limits

The `HVPS_LOOP_SET_VOLTAGE()` macro implements critical safety checks:

1. **Upper limit**: If `requested_hvps_voltage > max_hvps_voltage` → clamp to max, set VOLT_LIM status
2. **Lower limit**: If `requested_hvps_voltage < min_hvps_voltage` (and decreasing) → clamp to min
3. **Readback tolerance**: If `|readback - prev_requested| > allowed_hvps_voltage_diff` → reject change, increment counter. After 10 consecutive tolerance violations → set VOLT_TOL status
4. **History tracking**: Every accepted voltage change is written to `history_hvps_voltage` for archival

### 9.7 Key Process Variables

| PV | Type | Function |
|----|------|----------|
| `{STN}:HVPS:VOLT:CTRL` | Float | Requested HVPS voltage (setpoint sent to PLC) |
| `{STN}:HVPS:VOLT` | Float | Readback HVPS voltage (from PLC) |
| `{STN}:HVPS:LOOP:CTRL` | Int | Loop control: OFF(0), PROC(1), ON(2) |
| `{STN}:HVPS:LOOP:STATE` | Int | Loop state readback |
| `{STN}:HVPS:LOOP:STATUS` | Int | Loop status (16 codes, see below) |
| `{STN}:HVPS:VOLT:MIN` | Float | Minimum HVPS voltage (~50 kV turn-on) |
| `{STN}:HVPS:VOLT:CTRL.DRVH` | Float | Maximum HVPS voltage |
| `{STN}:HVPS:LOOP:VOLTDIFF` | Float | Maximum allowed readback-vs-requested difference |
| `{STN}:HVPS:LOOP:VOLTUP` | Float | Voltage increase step for PROCESS mode |
| `{STN}:HVPS:LOOP:VOLTDOWN` | Float | Voltage decrease step for PROCESS mode |
| `{STN}:HVPS:LOOP:DELAY` | Int | Delay (in VxWorks ticks/60) before loop activates |

### 9.8 Status Codes

| Code | Name | Description |
|------|------|-------------|
| 0 | UNKNOWN | Initial/undefined state |
| 1 | GOOD | Normal operation |
| 2 | RFP_BAD | RF Processor module not responding |
| 3 | CAVV_LIM | Cavity voltage above limit (can't increase HVPS) |
| 4 | OFF | Loop is off (but station is on) |
| 5 | VACM_BAD | Bad vacuum reading |
| 6 | POWR_BAD | Klystron forward power reading bad |
| 7 | GAPV_BAD | Gap voltage reading bad |
| 8 | GAPV_TOL | Gap voltage out of tolerance |
| 9 | VOLT_LIM | At max HVPS voltage limit |
| 10 | STN_OFF | Station is OFF or PARKed |
| 11 | VOLT_TOL | Readback differs from requested voltage |
| 12 | VOLT_BAD | HVPS voltage readback invalid |
| 13 | DRIV_BAD | Klystron drive power invalid |
| 14 | ON_FM | Station in ON_FM mode (not used at SPEAR3) |
| 15 | DRIV_TOL | Drive power out of tolerance |

---

# PART II: UPGRADE SYSTEM ENGINEERING DESIGN

---

## 10. Upgrade System Engineering Design

### 10.1 Design Goals

The HVPS controller upgrade aims to:

1. **Replace obsolete SLC-500 PLC** with modern CompactLogix PLC (Allen-Bradley)
2. **Replace aging Enerpro gate driver boards** with new boards
3. **Redesign analog regulator board** with modern components
4. **Improve PPS interface** to meet current safety standards
5. **Enable EPICS communication** for integration with LLRF9 and Python coordinator
6. **Improve documentation** for maintainability
7. **Integrate with Interface Chassis** for centralized interlock management

### 10.2 What Stays vs. What Changes

| Component | Current | Upgrade | Notes |
|-----------|---------|---------|-------|
| PLC Processor | SLC-500 | **CompactLogix** | Already procured for HVPS1, HVPS2, and B44 Test Stand |
| PLC I/O Modules | 1746 series | **1769 series** (CompactLogix) | Complete re-specification of I/O |
| Enerpro Boards | Original (aging) | **New Enerpro** (~$4k for 5 boards) | Same function, new components |
| Analog Regulator | Custom board (original) | **Redesigned board** | Modern components, same function |
| PPS Connector | GOB12-88PNE | **Same or equivalent** | Physical PPS interface preserved |
| PPS Wiring | Through Hoffman Box | **Improved routing** (see Section 12) | Key safety improvement |
| Terminal Strips | TS-2 through TS-8 | **Mostly preserved** | Minimize rewiring |
| Hoffman Enclosure | Existing | **Reused** | Same physical enclosure |
| Fiber Optics | HFBR-1412/2412 | **Same** | Via Interface Chassis |
| Touch Panel | Original | **Upgraded** | Modern HMI |
| Communication | None (field bus only) | **EtherNet/IP + EPICS** | Key upgrade for software integration |

### 10.3 Procurement Status

| Item | Cost | Status |
|------|------|--------|
| CompactLogix PLC modules | — | Procured (HVPS1, HVPS2, B44 Test Stand) |
| Enerpro boards (x5) | ~$4,000 | Needed |
| Analog regulator redesign | Labor | JS to lead |
| PLC programming | Labor | ML, BM to program |
| PPS interface improvement | Labor + parts | ML, BM to lead |

---

## 11. Upgraded HVPS Controller Architecture

### 11.1 CompactLogix PLC Configuration

The CompactLogix PLC replaces the SLC-500 with modern equivalents for each I/O function:

| Function | SLC-500 Module | CompactLogix Equivalent | Slot |
|----------|---------------|------------------------|------|
| Digital Inputs (16ch) | AB 1746-IB16 | AB 1769-IQ16 or equivalent | TBD |
| Digital I/O (8ch) | AB 1746-IO8 | AB 1769 combo or discrete | TBD |
| Relay Output (8ch) | AB 1746-OX8 | AB 1769-OW8 or equivalent | TBD |
| Digital Input (16ch) | AB 1746-IV16 | AB 1769-IQ16 or equivalent | TBD |
| Analog Input (4ch) | AB 1746-NI4 | AB 1769-IF4 or equivalent | TBD |
| Communication | None | **EtherNet/IP built-in** | Processor |

### 11.2 Communication Architecture

```
┌─────────────────────────┐
│   CompactLogix PLC      │
│   (HVPS Controller)     │
│                         │
│  ┌──────────────────┐   │
│  │ EtherNet/IP Port │───┼───► Plant Network
│  └──────────────────┘   │         │
│                         │         ▼
│  ┌──────────────────┐   │    ┌─────────────┐
│  │ Ladder Logic     │   │    │ EPICS Gateway│
│  │ - SCR control    │   │    │ (pycomm3 or │
│  │ - Safety logic   │   │    │  OPC-UA)    │
│  │ - PPS handling   │   │    └──────┬──────┘
│  │ - Contactor ctrl │   │           │
│  └──────────────────┘   │           ▼
│                         │    ┌──────────────┐
│  ┌──────────────────┐   │    │ Python/EPICS │
│  │ Analog I/O       │   │    │ Coordinator  │
│  │ - Voltage ctrl   │   │    │              │
│  │ - Current readbk │   │    │ hvps_loop.py │
│  └──────────────────┘   │    └──────────────┘
└─────────────────────────┘
```

### 11.3 Key Design Decision: EPICS Driver

The EPICS interface to the CompactLogix PLC is a critical open engineering decision:

| Option | Pros | Cons | Status |
|--------|------|------|--------|
| **pycomm3** | Pure Python, direct EtherNet/IP | Must handle tag mapping, no standard EPICS records | Recommended |
| **OPC-UA** | Industry standard, built into CompactLogix | Additional software layer, latency | Alternative |
| **Custom EtherNet/IP** | Direct control | High development effort | Not recommended |

**Recommendation**: Use pycomm3 for direct Python-to-PLC communication, wrapped by an EPICS IOC for PV publishing. This allows the Python coordinator to both directly command the PLC and publish all HVPS data as EPICS PVs.

### 11.4 PLC Program Design (CompactLogix)

The new CompactLogix ladder logic must replicate all SLC-500 functions plus add EPICS communication:

**Core Functions (replicated from SLC-500)**:
- Contactor on/off control
- PPS input reading and safety logic
- Ross ground switch control
- Emergency off handling
- Oil level monitoring
- Current monitoring
- SCR gate driver control (via analog output to Enerpro)
- Contactor status readback (blocking, overcurrent, closed, ready)

**New Functions**:
- EtherNet/IP tag publishing for EPICS integration
- Enhanced diagnostic data (timestamps, fault counts)
- Configurable parameters via EPICS (voltage setpoints, limits)
- Heartbeat to Interface Chassis
- Status word to Interface Chassis (fiber-optic)

---

## 12. Upgraded PPS Interface Design

### 12.1 Design Philosophy

The PPS interface upgrade must address two critical issues:

1. **Minimize PPS wiring exposure** inside the Hoffman box
2. **Remove the PLC from the Ross switch safety chain** (or provide a hardware bypass)

### 12.2 Option A: Direct PPS-to-Ross Hardwire (Recommended)

**Concept**: Route the PPS signal directly to the Ross grounding switch coil via a dedicated relay, bypassing the PLC entirely.

```
PPS GOB12-88PNE
    │
    ├── PPS 1 (Pin E) ──► TS-8 1 ──► PLC Slot 6 IN14 (monitoring only)
    │                              └──► Direct relay R_PPS1 coil
    │
    ├── PPS 2 (Pin G) ──► TS-8 3 ──► PLC Slot 6 IN15 (monitoring only)
    │                              └──► Direct relay R_PPS2 coil
    │
    │   R_PPS1 NC + R_PPS2 NC contacts in series with Ross coil power
    │   (If either PPS removed → contacts open → Ross coil de-energizes → switch grounds)
    │
    └── Readbacks (Pins A-B, C-D) ── unchanged (direct to auxiliary contacts)
```

**Advantages**:
- PLC failure cannot prevent Ross switch from grounding
- Fails safe: relay de-energizes on PPS signal loss
- PLC still monitors PPS for status/logging
- Minimal change to existing wiring infrastructure

**Implementation**:
- Add two 24 VDC relays (R_PPS1, R_PPS2) inside Hoffman box
- Wire PPS 1 and PPS 2 directly to these relay coils
- Wire NC contacts of both relays in series with the 120 VAC Ross coil supply
- PLC independently monitors PPS 1 and PPS 2 status via its digital inputs
- PLC can still provide additional software-controlled Ross switch enable (in series with hardware path)

### 12.3 Option B: Dual-Path Redundancy

**Concept**: Maintain PLC control but add a hardware watchdog timer that de-energizes the Ross switch if the PLC fails to refresh within a timeout.

This is more complex and still involves software in the safety path, so Option A is preferred.

### 12.4 Contactor Enable Path — Upgrade

The contactor enable path (K4 relay) via the OX8 relay module is already reasonably safe because:
- The PPS 1 signal is the *source voltage* for the relay
- Even with PLC failure, no voltage can reach K4 if PPS has removed its permit

**For the upgrade**: Maintain this architecture but replace the 1746-OX8 with the CompactLogix equivalent relay output module. Verify that the new module uses the same relay topology (dry contacts sourced by external voltage).

### 12.5 PPS Wiring Segregation

**Current Problem**: PPS wiring runs through the Hoffman box alongside control wiring on shared terminal strips. Opening the box for maintenance may require PPS safety procedures.

**Upgrade Recommendation**:
1. Route all PPS wiring through a dedicated conduit section within the Hoffman box
2. Use clearly labeled barriers or channels to physically separate PPS wires from control wires
3. Ideally, bring PPS wiring into the box through a separate penetration
4. Document the PPS wire routing clearly in updated drawings
5. Coordinate with SSRL protection management on any requirements for sealed PPS junction boxes

### 12.6 PPS Standards Review

Before proceeding with the upgrade, a formal review with SSRL protection management (successors to Matt Cyterski and Tracy Yott) is required to determine:

1. Does the current PPS implementation meet current standards?
2. What changes are required for the upgrade to be compliant?
3. Can we work on the Hoffman box without PPS safety procedures if PPS wiring is properly segregated?
4. What documentation and testing is required for PPS approval?

---

## 13. Interface Chassis — HVPS Integration

### 13.1 HVPS Signals on the Interface Chassis

The Interface Chassis serves as the central interlock coordination hub. Its HVPS-related signals are:

**Inputs to Interface Chassis**:
| Signal | Source | Type | Meaning |
|--------|--------|------|---------|
| HVPS STATUS | HVPS Controller fiber-optic | Fiber (HFBR-2412 RX) | Controller powered, no crowbar, ready |

**Outputs from Interface Chassis**:
| Signal | Destination | Type | Meaning |
|--------|-------------|------|---------|
| SCR ENABLE | HVPS Controller fiber-optic | Fiber (HFBR-1412 TX) | Permission to fire SCRs |
| KLYSTRON CROWBAR | HVPS Controller fiber-optic | Fiber (HFBR-1412 TX) | Must be illuminated for HVPS to operate |

### 13.2 Interlock Logic for HVPS

The Interface Chassis removes SCR ENABLE (inhibits HVPS) when ANY of:
- LLRF9 status goes to OFF (RF fault detected)
- MPS global permit removed
- SPEAR MPS permit removed (24 VDC)
- Orbit interlock permit removed (24 VDC)
- Power monitoring comparator trips
- Arc detection system trips
- Expansion port trigger received

### 13.3 HVPS STATUS → LLRF9 Enable Logic

The HVPS STATUS signal informs the Interface Chassis whether the HVPS is ready:
- STATUS ON → HVPS is powered and no internal faults → can provide permit to LLRF9
- STATUS OFF → HVPS has internal fault or is not powered → remove LLRF9 permit

### 13.4 Recovery Sequence Design

After a fault, the system must be recovered in a specific sequence to break the circular dependency between LLRF status and HVPS enable:

```
1. Verify all fault sources cleared (MPS, SPEAR MPS, orbit, etc.)
2. Verify HVPS STATUS is ON (HVPS controller powered, no internal faults)
3. Interface Chassis sends SCR ENABLE to HVPS (but HVPS output is at 0V)
4. Interface Chassis sends permit to LLRF9
5. LLRF9 status goes to ON (active, but not driving RF yet)
6. Python coordinator can now begin turn-on sequence:
   a. Set HVPS voltage setpoint via EPICS → PLC → SCR firing
   b. LLRF9 begins driving RF at initial low power
   c. Ramp to operational levels
```

**Key Design Requirement**: The Interface Chassis must track *why* LLRF9 status is OFF. If it was because the chassis itself removed the permit, then LLRF9 OFF is expected and should not block recovery.

---

## 14. HVPS EPICS Integration and Python Supervisory Loop

### 14.1 EPICS PV Architecture for HVPS

The upgrade adds a complete set of EPICS PVs for HVPS control and monitoring:

**Control PVs** (written by Python coordinator):
| PV Name | Type | Function |
|---------|------|----------|
| `SRF1:HVPS:VOLT:SETPT` | Float | Voltage setpoint to PLC |
| `SRF1:HVPS:CONTACTOR:CMD` | Enum | Contactor open/close command |
| `SRF1:HVPS:LOOP:MODE` | Enum | OFF/PROCESS/ON |
| `SRF1:HVPS:LOOP:ENABLE` | Binary | Enable/disable supervisory loop |

**Readback PVs** (read from PLC via EPICS gateway):
| PV Name | Type | Function |
|---------|------|----------|
| `SRF1:HVPS:VOLT` | Float | Voltage readback |
| `SRF1:HVPS:CURR` | Float | Current readback (Danfysik) |
| `SRF1:HVPS:CONTACTOR:STATUS` | Enum | Open/Closed/Blocking/Ready |
| `SRF1:HVPS:PPS:1` | Binary | PPS 1 status |
| `SRF1:HVPS:PPS:2` | Binary | PPS 2 status |
| `SRF1:HVPS:ROSS:STATUS` | Enum | Ross switch open/closed |
| `SRF1:HVPS:OIL:GND` | Binary | Ground tank oil OK |
| `SRF1:HVPS:OIL:CROW` | Binary | Crowbar tank oil OK |
| `SRF1:HVPS:OIL:SCR` | Binary | SCR tank oil OK |
| `SRF1:HVPS:CROWBAR:STATUS` | Binary | Crowbar triggered |
| `SRF1:HVPS:STATUS` | Enum | Overall HVPS status word |

### 14.2 Python HVPS Supervisory Loop

The Python HVPS loop (`hvps_controller.py`) replaces the legacy `rf_hvps_loop.st`:

```python
class HVPSController:
    """
    HVPS supervisory control loop.
    Replaces legacy rf_hvps_loop.st SNL sequence.
    
    Modes:
      OFF     - No voltage control
      PROCESS - Ramp voltage based on power/vacuum/voltage conditions
      ON      - Maintain constant drive power (ON_CW) or gap voltage (TUNE)
    """
    
    async def process_mode_cycle(self):
        """Single cycle of PROCESS mode (replaces SNL 'proc' state)"""
        # Check sensor validity
        if not self._check_sensor_health():
            return
        
        # Determine voltage delta
        if (self.klystron_fwd_power > self.max_fwd_power or
            self.gap_voltage_alarm or
            self.vacuum_alarm):
            delta = self.config.delta_proc_down  # Decrease
        else:
            delta = self.config.delta_proc_up    # Increase
        
        self._apply_voltage_delta(delta)
    
    async def on_mode_cycle(self):
        """Single cycle of ON mode (replaces SNL 'on' state)"""
        if self.station_state == 'ON_CW' and self.direct_loop_active:
            # Drive power regulation
            delta = -self.drive_power_error
        else:
            # Gap voltage regulation (TUNE mode)
            delta = self.gap_voltage_error
        
        self._apply_voltage_delta(delta)
    
    def _apply_voltage_delta(self, delta: float):
        """Apply voltage change with safety limits (replaces HVPS_LOOP_SET_VOLTAGE macro)"""
        new_voltage = self.current_setpoint + delta
        
        # Upper limit
        if new_voltage > self.config.max_voltage:
            new_voltage = self.config.max_voltage
            self.status = HVPSStatus.VOLT_LIM
        
        # Lower limit
        if new_voltage < self.config.min_voltage and delta <= 0:
            new_voltage = self.config.min_voltage
        
        # Readback tolerance check
        if abs(self.readback_voltage - self.prev_setpoint) > self.config.max_diff:
            self.tolerance_count += 1
            if self.tolerance_count > 10:
                self.status = HVPSStatus.VOLT_TOL
            return  # Reject change
        
        self.tolerance_count = 0
        self._set_voltage(new_voltage)
```

### 14.3 Integration with Interface Chassis

The Python coordinator monitors the Interface Chassis status (via MPS PLC EPICS PVs) and coordinates with the HVPS:

1. **Before turn-on**: Verify Interface Chassis shows all permits active
2. **During operation**: Monitor Interface Chassis for fault indications
3. **On fault**: Log the fault, read Interface Chassis first-fault data, initiate controlled shutdown if needed
4. **On recovery**: Follow the recovery sequence (Section 13.4)

---

# PART III: KNOWN ISSUES AND RISK ASSESSMENT

---

## 15. Known Documentation Issues and Required Verifications

### 15.1 Documentation Errors Identified

| Drawing/Document | Error | Impact | Verification Required |
|------------------|-------|--------|----------------------|
| `gp4397040201.pdf` | L1 mislabeled as L2 (two coils with same name) | Could cause confusion during maintenance | Compare with `rossEngr713203.pdf` |
| `WD-730-794-02-C0` | RR and K4 relay labels appear to be swapped | Critical: affects understanding of PPS control path | Field inspection of relay wiring |
| `WD-730-794-02-C0` | K4 NO and 86 NC contacts missing between BB and MX coil | Schematic incomplete | Verify physical wiring |
| `ID 308-801-06-C1` | Difficult to interpret, may contain errors | Affects understanding of switchgear wiring | Expert consultation needed |
| `WD-730-790-02-C6` | TS-5 15 labeled as "??" | Function unclear from drawing | Verify: should be PPS S5-2 Common |
| Various | TS-5 function names differ between drawings | Confusing cross-referencing | Create unified wiring table |
| `HoffmanBoxPPSWiring.docx` | Pin A noted as potentially connecting to TS-5 15 (not TS-4 14) | Minor but needs verification | Field verify |

### 15.2 Required Field Verifications

**Priority 1 — Must complete before PLC replacement**:

1. **Verify K4 and RR relay identities and functions**
   - Under HV electrician lockout, trace wiring from TS-5 pins 4 and 5 to the actual relay coils in the contactor controller
   - Confirm which relay controls MX (PPS function) and which provides reset

2. **Verify PPS pin connections at TS-5 and TS-8**
   - Verify PPS 1 (Pin E) actually connects to TS-8 1 and then to Slot 6 IN14
   - Verify PPS 2 (Pin G) actually connects to TS-8 3 and then to Slot 6 IN15
   - Verify PPS common connections

3. **Verify Ross switch coil power source**
   - Confirm the 120 VAC to the Ross relay coil comes exclusively from Slot 2 OUT3
   - Check if there is any hardwired bypass

4. **Verify contactor auxiliary contacts**
   - Confirm S5 wiring to Pins A-B of the PPS connector
   - Confirm Ross switch auxiliary contact wiring to Pins C-D

**Priority 2 — Must complete before commissioning**:

5. **Verify oil level sensor wiring** (TS-6 to PLC)
6. **Verify Danfysik current transductor connections** (TS-6 to Slot 9)
7. **Verify all contactor status signals** (TS-5 to Slot 7 inputs)
8. **Create updated, verified wiring diagrams** for all terminal strips

### 15.3 Documentation To Be Created

| Document | Content | Priority |
|----------|---------|----------|
| Verified wiring diagram for Hoffman Box | All terminal strips, PLC I/O, PPS interface | High |
| Contactor controller schematic (corrected) | Fixed relay labels, complete circuit | High |
| CompactLogix I/O specification | All inputs/outputs, tag names, scaling | High |
| PPS interface drawing (upgrade) | New PPS-to-Ross direct path design | High |
| Interface Chassis ↔ HVPS signal spec | Fiber-optic signals, logic levels, timing | Medium |
| EPICS PV database for HVPS | All PV names, types, descriptions | Medium |
| Commissioning procedure | Step-by-step test and validation | Before install |

---

## 16. Risk Assessment and Mitigation

### 16.1 Technical Risks

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| **PPS interface non-compliance** | Critical | Medium | Formal review with SSRL protection before any changes |
| **PLC replacement breaks existing functions** | High | Medium | Build and test on B44 Test Stand (Test Stand 18) first |
| **Documentation errors lead to wiring mistakes** | High | High | Field verify ALL connections before upgrading |
| **K4/RR relay identity confusion** | High | High | Physical verification under lockout before design proceeds |
| **Ross switch PLC dependency** | Critical | Low (existing design) | Implement hardware bypass (Option A, Section 12.2) |
| **Enerpro board compatibility** | Medium | Low | Verify new boards on test stand |
| **EPICS communication latency** | Medium | Low | Proven in prototype; ~1 Hz sufficient |
| **Interface Chassis recovery logic** | High | Medium | Careful design with clear state tracking; test extensively |
| **Fiber-optic signal compatibility** | Medium | Low | Use same Broadcom components |

### 16.2 Operational Risks

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| Extended SPEAR downtime | High | Medium | Maximize off-machine testing; minimize on-machine time |
| Rollback to legacy system | Medium | Low | Maintain ability to revert during commissioning |
| Operator training gaps | Medium | Medium | Develop training materials and procedures before install |
| PPS retest requirements | High | High | Plan for PPS testing time; coordinate with protection group |

### 16.3 Critical Path

```
1. Field verify all wiring (Priority 1 items)          ← BLOCKING
       │
       ▼
2. PPS formal review with protection management        ← BLOCKING
       │
       ▼
3. Complete PPS interface design (based on review)
       │
       ▼
4. Build and test on B44 Test Stand
   ├── CompactLogix PLC programming
   ├── New Enerpro boards installed and tested
   ├── Analog regulator redesign tested
   └── PPS interface (new design) tested
       │
       ▼
5. Interface Chassis HVPS integration design
       │
       ▼
6. SPEAR installation (during scheduled downtime)
       │
       ▼
7. Commissioning with Dimtel support
```

### 16.4 Test Stand Strategy

**B44 Test Stand (Test Stand 18)** should replicate:
- CompactLogix PLC with all I/O modules
- Enerpro gate driver boards
- Analog regulator board
- Simulated PPS inputs (24 VDC switched)
- Simulated contactor controller status signals
- Ross switch relay (actual or simulated)
- Fiber-optic transmitters/receivers for Interface Chassis testing
- EPICS IOC for software integration testing
- Python coordinator running hvps_controller.py

---

## Appendix A: Terminal Strip Wiring Tables

### TS-5 (Contactor Controls) — Complete Wiring

| TS-5 Pin | Wire Color | Function | Internal Termination | External Destination (TB2) |
|----------|-----------|----------|---------------------|---------------------------|
| 1 | Green | Common | System common | CC1 — MX relay coil common |
| 2 | Red | Contactor On/Off | Slot 5 OX8-3 OUT 1 | BB — MX relay On |
| 3 | Black | PPS Common | PPS Pin F | CC — RR and K4 coil common |
| 4 | Black | Contactor Enable | Slot 5 OX8-5 OUT 2 | 11? — K4 coil |
| 5 | N/C | Reset | — | EE — RR coil |
| 6 | N/C | ?? | — | — |
| 7 | Brown | Blocking | Slot 7 IV16-0 IN 0 | 7 — S1-3 NC (Blocking relay) |
| 8 | Green | Common | System common (tied to 1) | 9 — Interlock common |
| 9 | Red | Overcurrent | Slot 7 IV16-1 IN 1 | 8 — S2-1 NO (Overcurrent) |
| 10 | ?? | Contactor Open | TS-8 8 (LED Off) | DD — S3-3 NC |
| 11 | Orange | Contactor Closed/OK | Slot 7 IV16-2 IN 2 + TS-8 7 (LED On) | W — S3-1 NO |
| 12 | N/C | ?? | — | 14 — S4-1 NO (Ready) |
| 13 | Blue | Contactor Ready | Slot 7 IV16-3 IN 3 | 16 — S4-3 NC (Ready) |
| 14 | Red | PPS Monitor | PPS Pin B + PPS1 Green LED | 22 — S5-3 NC |
| 15 | Red/Black | PPS Monitor | PPS Pin A | 21 — S5-2 Common |

### TS-6 (Grounding Tank Interface) — Complete Wiring

| TS-6 Pin | Wire Color | Function | Internal Termination | External (P5/LEV-3) |
|----------|-----------|----------|---------------------|---------------------|
| 1 | Black | DC Current Output | Slot-9 NI4 In3+ | J2-6 Danfysik output |
| 2 | Green | DC Common | Slot-9 NI4 In3-; SOLA common | J2-4 Danfysik ground |
| 3 | Blue | -15V | TS-3 8 voltage monitor | J2-5 Danfysik -15 VDC |
| 4 | Red | +15V | TS-3 9 voltage monitor | J2-9 Danfysik +15 VDC |
| 5 | White | Status + | TS-2 5 control power | J2-8 Danfysik Status + |
| 6 | N/C | Status - Transductor | — | J2-3 Danfysik Status - |
| 7 | ? | +12V | Oil Level circuit | LEV-3 1, Oil Level NC |
| 8 | ? | Ground Tank Oil | Slot-6 IB16 IN8 | LEV-3 2, Oil Level NC |
| 9 | Black | +12V (NO?) | — | P5-C Manual Ground SW NC |
| 10 | White/Black | Manual GND SW Common | — | P5-D Manual Ground SW Common |
| 11 | Orange | Ground Relay NC (common) | PPS Pin D + PPS2 Green LED | P5-J Ross Relay Aux Common |
| 12 | Red/Black | Ground Relay NC | PPS Pin C | P5-H Ross Relay Aux NC |
| 13 | Blue | Ground Relay Coil | Slot-2 IO8 OUT3 pin 5 | P5-F Ross Relay Coil |
| 14 | Green | Ground Relay Coil Return | Slot-2 IO8 AC Common pin 10 | P5-E Ross Relay Coil |
| 15 | Red | +12V | TS-6 bus | — |
| 16 | Violet | Crowbar Tank Oil | Slot-6 IB16 IN10 | — |
| 17 | Red | +12V | TS-6 bus | — |
| 18 | Yellow | SCR Tank Oil | Slot-6 IB16 IN11 | — |
| 19 | Green/Black | Ground Relay NO | Slot-7 IV16 IN13 + TS-4 3 | P5-I Ross Relay Aux NO |
| 20 | BNC signal | Shunt + | BNC-12 | P5-A 15A/50mV Shunt + |
| 21 | BNC shield | Shunt Common | BNC-12 | P5-B 15A/50mV Shunt Common |

---

## Appendix B: PLC I/O Mapping

### Current SLC-500 I/O Map

| Slot | Module | I/O Point | Function | Connected To |
|------|--------|-----------|----------|-------------|
| 2 | 1746-IO8 | OUT3 (5) | Ross Ground Switch Relay | TS-6 13,14 → Ross coil |
| 5 | 1746-OX8 | OUT1 (3) | Contactor On/Off | TS-5 2 → TB2 BB |
| 5 | 1746-OX8 | OUT2 (5) | Contactor Enable (K4) | TS-5 4 → TB2 K4 coil |
| 6 | 1746-IB16 | IN8 | Ground Tank Oil | TS-6 8 |
| 6 | 1746-IB16 | IN9 | Ground Switch NC | TS-6 10 |
| 6 | 1746-IB16 | IN10 | Crowbar Tank Oil | TS-6 16 |
| 6 | 1746-IB16 | IN11 | SCR Tank Oil | TS-6 18 |
| 6 | 1746-IB16 | IN14 | PPS 1 Input | TS-8 1 ← PPS Pin E |
| 6 | 1746-IB16 | IN15 | PPS 2 Input | TS-8 3 ← PPS Pin G |
| 7 | 1746-IV16 | IN0 | Blocking (contactor) | TS-5 7 ← S1-3 NC |
| 7 | 1746-IV16 | IN1 | Overcurrent (contactor) | TS-5 9 ← S2-1 NO |
| 7 | 1746-IV16 | IN2 | Contactor Closed | TS-5 11 ← S3-1 NO |
| 7 | 1746-IV16 | IN3 | Contactor Ready | TS-5 13 ← S4-3 NC |
| 7 | 1746-IV16 | IN13 | Ground Switch NO | TS-6 19 ← Ross Aux NO |
| 9 | 1746-NI4 | IN3+/IN3- | DC Current | TS-6 1,2 ← Danfysik |

---

## Appendix C: Schematic Drawing Cross-Reference

| Drawing Number | Title | Content | Key Information |
|---------------|-------|---------|-----------------|
| `gp4397040201` | Vacuum Contactor Controller | Internal relay logic of contactor controller | K1, K3, K4, MX, TX, RR relays; MCO protection; coil L1/L2 |
| `rossEngr713203` | Ross Engineering Vacuum Contactor (1978) | Internal schematic of contactor + controller driver | TB2 terminals; relays S1-S5; correct L1/L2 labeling |
| `sd7307900501` | Grounding (Termination) Tank | Tank schematic | Ross switch location; klystron arc sensor |
| `wd7307900103` | Interconnection: B118 ↔ Contactor + Tank | Larger interconnect diagram | Shows full cable routing between Hoffman box and HVPS |
| `wd7307900206` | Wiring: HVPS Controller (Hoffman Box) | Internal Hoffman box wiring | All terminal strips, PLC modules, PPS connections |
| `wd7307940600` | Interconnection: B118 ↔ Contactor Disconnect | TS-5 to TB2 cable detail | Wire colors, function names, terminal assignments |
| `WD-730-790-02-C6` | (Referenced in HoffmanBox doc) | Hoffman box master wiring | TS-5 function definitions (per Hoffman box labeling) |
| `WD-730-794-02-C0` | (Referenced in HoffmanBox doc) | Contactor interface detail | TS-5 to TB2 mapping (function names differ from C6) |
| `WD-730-790-01-C3` | (Referenced in HoffmanBox doc) | Current documentation | TS-5 and TB2 contactor disconnect |
| `ID 308-801-06-C1` | (Referenced in HoffmanBox doc) | Contactor disconnect wiring | TB2 terminal assignments (may contain errors) |
| `GP 439-704-02-C1` | (Referenced — see gp4397040201) | Contactor controller schematic | Original with text notes; mislabels L1=L2 |

---

## Appendix D: Abbreviations and Definitions

| Term | Definition |
|------|-----------|
| **HVPS** | High Voltage Power Supply — provides DC power to klystron cathode |
| **PPS** | Personnel Protection System — safety system for personnel access |
| **MPS** | Machine Protection System — protects equipment from damage |
| **LLRF** | Low-Level RF — control electronics for RF cavity field regulation |
| **SCR** | Silicon Controlled Rectifier (thyristor) — used for voltage regulation |
| **Ross Switch** | Ross Engineering grounding switch — shorts HVPS output for safety |
| **Contactor** | Vacuum contactor — high-voltage AC disconnect switch (12.47 kV) |
| **Crowbar** | Fast short-circuit protection for klystron arcs |
| **Hoffman Box** | Hoffman electrical enclosure housing the HVPS controller |
| **SLC-500** | Allen-Bradley Small Logic Controller — legacy PLC platform |
| **CompactLogix** | Allen-Bradley modern PLC platform — upgrade replacement |
| **Enerpro** | Commercial SCR gate driver board manufacturer |
| **Danfysik** | Current transductor manufacturer |
| **Interface Chassis** | New central interlock coordination hub (upgrade subsystem) |
| **GOB12-88PNE** | Burndy/Souriau 8-pin circular PPS connector |
| **K4, RR, TX, MX** | Relays in the vacuum contactor controller (see Section 6.3) |
| **S1–S5** | Auxiliary contacts in the vacuum contactor assembly |
| **TB2** | Terminal block 2 inside the contactor disconnect panel |
| **TS-1 through TS-8** | Terminal strips inside the Hoffman box |

---

*Document generated from analysis of: legacyLLRF/rf_hvps_loop.st, legacyLLRF/rf_hvps_loop_*.h, pps/HoffmanBoxPPSWiring.docx, pps/MSG from Jim Sebek to Faya about PPS.md, pps/*.pdf schematics, Docs_JS/*.docx, Designs/1-3_*.md, LLRF9/iGp/dl_llrf/hvps.edl*
