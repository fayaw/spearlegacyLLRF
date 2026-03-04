# SPEAR3 HVPS System Design and PPS Interface — Current and Upgraded

**Document Purpose**: Technical reference describing the High Voltage Power Supply (HVPS) controller system and its interface with the Personnel Protection System (PPS), for both the current legacy configuration and the planned upgrade architecture. This document details the complexity introduced by the HVPS controller upgrade and its impact on the safety-critical PPS boundary.

**Version**: 1.0
**Date**: 2026-03-04
**Status**: Technical Reference
**Context**: Part of the SPEAR3 LLRF Upgrade Project

**Reference Documents**:
| Document | Location | Content |
|----------|----------|---------|
| System Overview | `Designs/1_Overview of Current and Upgrade System.md` | Full legacy/upgrade comparison |
| Upgrade System Design | `Designs/2_LLRF_UPGRADE_SYSTEM_DESIGN.md` | Engineering design reference |
| LLRF9 System Report | `Designs/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` | LLRF9 hardware/software details |
| PPS System Overview | `pps/diagrams/00_SYSTEM_OVERVIEW.md` | PPS current vs. upgrade architecture |
| Vacuum Contactor Controller | `pps/diagrams/01_gp4397040201_vacuum_contactor_controller.md` | Relay logic, closing/opening sequences |
| Ross Contactor/Driver | `pps/diagrams/02_rossEngr713203_vacuum_contactor_driver.md` | TB2 pinout, auxiliary contacts |
| Grounding Tank | `pps/diagrams/03_sd7307900501_grounding_tank.md` | Ross switch, Danfysik, arc fault |
| Hoffman Box Wiring | `pps/diagrams/04_wd7307900206_hoffman_box_wiring.md` | PLC I/O map, all terminal strips |
| Full Interconnection | `pps/diagrams/05_wd7307900103_interconnection_full.md` | Hoffman Box to Contactor to Tank |
| Grounding Tank Interconnect | `pps/diagrams/06_wd7307940600_interconnection_grounding_tank.md` | TS-6 to Grounding Tank wiring |
| PLC Code and Logic | `pps/diagrams/07_PLC_CODE_AND_LOGIC.md` | Ladder logic rungs, fault scenarios |
| Corrected Hand Drawing | `pps/diagrams/08_CORRECTED_HAND_DRAWING.md` | PPS wiring corrections |
| Jim Sebek PPS Email | `pps/MSG from Jim Sebek to Faya about PPS.md` | 2022 PPS concerns and upgrade drivers |
| HoffmanBoxPPSWiring.docx | `pps/HoffmanBoxPPSWiring.docx` | Detailed PPS wiring analysis |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Context — SPEAR3 RF Station](#2-system-context--spear3-rf-station)
3. [Current (Legacy) HVPS System Design](#3-current-legacy-hvps-system-design)
4. [Current PPS Interface with HVPS](#4-current-pps-interface-with-hvps)
5. [Legacy PPS Safety Chain Analysis](#5-legacy-pps-safety-chain-analysis)
6. [Known Issues with the Current HVPS-PPS Design](#6-known-issues-with-the-current-hvps-pps-design)
7. [Upgraded HVPS System Design](#7-upgraded-hvps-system-design)
8. [Upgraded PPS Interface with HVPS](#8-upgraded-pps-interface-with-hvps)
9. [Interface Chassis — The New PPS Coordination Hub](#9-interface-chassis--the-new-pps-coordination-hub)
10. [Side-by-Side Comparison: Legacy vs. Upgraded HVPS-PPS Interface](#10-side-by-side-comparison-legacy-vs-upgraded-hvps-pps-interface)
11. [Why the HVPS-PPS Upgrade Is Complicated](#11-why-the-hvps-pps-upgrade-is-complicated)
12. [Implementation Risks and Mitigations](#12-implementation-risks-and-mitigations)
13. [Open Questions and Required Decisions](#13-open-questions-and-required-decisions)

---

## 1. Executive Summary

The SPEAR3 HVPS (High Voltage Power Supply) is the power source for a single klystron that drives four RF cavities at 476 MHz. The HVPS provides up to ~90 kV to the klystron cathode, with a turn-on voltage of ~50 kV. Because the HVPS operates at lethal voltages, it has a direct interface with the **Personnel Protection System (PPS)** — the radiation and electrical safety interlock system managed by SLAC/SSRL.

The HVPS controller system is being upgraded as part of the larger LLRF modernization project. This upgrade replaces the obsolete **Allen-Bradley SLC-500 PLC** with a modern **CompactLogix PLC**, installs new **Enerpro SCR gate driver boards**, and introduces a new **Interface Chassis** that fundamentally changes how the PPS interacts with the HVPS.

**Why this is complicated**: The PPS interface is a safety-critical boundary that is owned and regulated by SLAC's radiation protection group. Any modification to the PPS wiring, control logic, or readback paths requires coordination with PPS management, formal review, and possibly a radiation safety work control form and system retest. The current system has PPS signals routed *through* the HVPS controller box (Hoffman Box) with exposed wiring on terminal strips — a design that may not meet current PPS standards. The upgrade must simultaneously:

1. Replace the obsolete PLC hardware
2. Redesign the PPS control path to eliminate PLC dependency for safety functions
3. Isolate PPS wiring from non-PPS equipment
4. Maintain backward-compatible readback signals to the PPS chassis
5. Coordinate with SLAC protection managers who have authority over the PPS boundary
6. Reverse-engineer the existing SLC-500 ladder logic for migration to CompactLogix

> **Historical Context**: Jim Sebek's 2022 email to Matt Cyterski (SSRL protections manager) and Tracy Yott (PPS deputy) initiated discussions about the PPS interface concerns. Pre-pandemic, facilities had a project to redo the vacuum contactor controller due to obsolete parts, but that project was abandoned. The LLRF upgrade project has now absorbed this scope.

---

## 2. System Context — SPEAR3 RF Station

The SPEAR3 RF station consists of the following physical elements relevant to the HVPS-PPS interface:

| Component | Description | Location |
|-----------|-------------|----------|
| **Klystron** | Single klystron, ~1 MW output at 476 MHz | Tunnel |
| **4 RF Cavities** | Single-cell cavities, ~800 kV gap each, ~3.2 MV total | Tunnel (ring) |
| **HVPS** | Provides up to ~90 kV to klystron cathode | Building B118 |
| **HVPS Controller (Hoffman Box)** | PLC-based controller in NEMA enclosure | Building B118 |
| **Vacuum Contactor** | Ross Engineering HQ3, 12.47 kV | Contactor Disconnect Panel (switchgear) |
| **Contactor Controller (Driver)** | Ross Engineering HCA-1-A (P/N 820360) | Adjacent to contactor |
| **Grounding (Termination) Tank** | Contains Ross grounding switch, Danfysik DC-CT, Pearson CT-110 | Near klystron |
| **PPS Interface Chassis** | GOB12-88PNE 8-pin connector, locked box on Hoffman Box | Building B118 |

### Power Flow Path

```
12.47 kV Utility → Vacuum Contactor (HQ3) → HVPS Transformer/Rectifier → 
→ Grounding Tank → Klystron Cathode (~90 kV DC)
```

The PPS controls two points in this chain:
- **Chain 1**: The vacuum contactor (removes 12.47 kV input power)
- **Chain 2**: The Ross grounding switch (shorts the HVPS output to ground)

---

## 3. Current (Legacy) HVPS System Design

### 3.1 HVPS Controller Hardware (Hoffman Box)

The legacy HVPS controller is housed in a Hoffman NEMA enclosure (34"x42") located in Building B118. It contains:

**PLC System — Allen-Bradley SLC-500** (OBSOLETE):

| Slot | Module | Function |
|------|--------|----------|
| CPU | AB-1747-L532 | Processor |
| 1 | AB-1747-DCM | Data Communications (Scanner) |
| 2 | AB-1746-IO8 | 8-point Digital I/O Combo — **Ross switch coil control (OUT3)** |
| 3 | AB-1746-THERMC | Thermocouple inputs (SCR/air/transformer temps) |
| 5 | AB-1746-OX8 | 8-point Relay Output — **Contactor enable (OUT2)**, Contactor On/Off (OUT1) |
| 6 | AB-1746-IB16 | 16 DC Input — **PPS 1 (IN14)**, **PPS 2 (IN15)**, Oil Level (IN8), Manual GRN SW (IN9) |
| 7 | AB-1746-IV16 | 16 DC Input (various permits) |
| 8 | AB-1746-NIO4V | 4-channel Analog I/O |
| 9 | AB-1746-NI4 | 4-channel Analog Input — Danfysik HVPS current (IN3) |
| PS | AB-1747-P1 | PLC Power Supply |

**Power Supplies**:
- SOLA 85-10-2120: ±15V, +5V, 24V
- Kepko 120V/1A (x2): PS-1 and PS-4 (HVPS voltage reference/regulation)
- Kepko 5V/20A: PS-2
- Kepko 240V/0.225A: PS-5

**Circuit Boards**:
- PS Monitor Board (SD-730-793-12): Monitors power supply voltages
- Regulator Card (PC-237-230-14-C0): Analog voltage regulation for HVPS SCR gate drive
- Left/Right Trigger Interconnect boards (SD-730-793-08, -07): SCR firing timing
- Interface Boards INT1, INT2: Signal conditioning
- ENERPRO Firing Board: SCR gate driver (current design)

**Terminal Strips**:
- **TS-5**: Contactor controls (15 terminals) — connection to switchgear via Belden 83715 (15C #16 Teflon)
- **TS-6**: Grounding tank connections (21 terminals) — connection to termination tank via Belding 83709 (9C #16 Teflon) + Belden 83715
- TS-3: PPS status LEDs
- TS-7: Power distribution
- TS-1, TS-8: Miscellaneous

**External Connectors**:
- **GOB12-88PNE**: 8-pin circular PPS connector (Burndy/Souriau Trim Trio) — mounted in locked box on Hoffman Box
- AMP 8-Pin: PPS status LEDs
- BNC-1 through BNC-12: Monitor/trigger signals

### 3.2 HVPS Control Software (Legacy)

The HVPS is controlled by two software layers:

**Layer 1 — PLC Ladder Logic (SLC-500)**:
- Handles local HVPS regulation (voltage setpoint, SCR firing angle)
- Manages contactor enable/disable based on permits
- Controls Ross grounding switch based on PPS signals
- Monitors temperatures, oil levels, and fault conditions
- Communicates with the LLRF control system via Data Highway

**Layer 2 — SNL State Machine (VxWorks IOC)**:
The file `legacyLLRF/rf_hvps_loop.st` implements a supervisory HVPS control loop with three operating states:

| State | Function | Description |
|-------|----------|-------------|
| **off** | Station off/park | No voltage adjustment; waits for station state change |
| **proc** | Vacuum processing | Gradually raises HVPS voltage while monitoring vacuum, power, and gap voltage. Reduces voltage if any limit is exceeded. |
| **on** | Normal operation | Adjusts HVPS voltage to maintain constant klystron drive power (ON_CW mode) or gap voltage (TUNE mode). Runs at ~1 Hz via `HVPS_LOOP_MAX_INTERVAL`. |

Key control parameters from `rf_hvps_loop_defs.h`:
- 16 status codes (STN_OFF, RFP_BAD, POWR_BAD, GAPV_BAD, VACM_BAD, VOLT_BAD, DRIV_BAD, GOOD, OFF, ON_FM, DRIV_TOL, GAPV_TOL, CAVV_LIM, etc.)
- Voltage step sizes: `delta_proc_voltage_up/down` (processing), `delta_on_voltage` (CW mode), `delta_tune_voltage` (tune mode)
- Maximum HVPS voltage clamped by `max_hvps_voltage`
- Safety checks on klystron forward power, cavity vacuum, gap voltage, and HVPS voltage readback

### 3.3 Vacuum Contactor System

The vacuum contactor is a **Ross Engineering Model HQ3** rated for 12.47 kV. It uses a stored-energy closing mechanism:

**Closing Sequence** (drawing `gp4397040201`):
1. K4 relay energized (PPS control relay, from PLC OX8 OUT2)
2. K4 NO contacts close → provides control voltage and enables MX relay path
3. MX relay energizes (if K4 closed AND 86 lockout relay NC closed)
4. Internal HV DC power supply charges C6 capacitor (40,000 µF to ~350V DC)
5. K2 (ready relay) and K3 (current sensing) confirm energy available
6. K1 (close relay) fires → stored energy from C6 applied to L2 (closing coil)
7. L2 toggle mechanism closes HV vacuum contacts
8. L1 (holding coil, low-power DC) maintains contactor closed via MX NO contact

**Opening Sequence**:
1. Any trigger: K4 de-energized (PPS removed), MX de-energized, TX tripping relay, local OFF
2. MX de-energized → L1 holding coil loses power
3. L1 drops out (<1 AC cycle) → toggle opens HV contacts
4. S5 auxiliary contact closes → PPS readback: closed circuit = contactor OPEN (safe state)
5. C6 begins recharging (several seconds required before reclosing)

**Critical safety note**: The K4 relay is the primary PPS interlock. De-energizing K4 removes ALL control power. The contactor cannot be closed without K4, and K4 cannot be energized without PPS enable.

### 3.4 Ross Grounding Switch

Located in the grounding (termination) tank, the Ross grounding switch (SW1) shorts the HVPS output a few feet upstream of the klystron grid. It is an electrically-operated switch with:

- Coil control via TS-6 pins 13-14 (from PLC Slot-2 IO8 OUT3, 120 VAC)
- Auxiliary contacts: COM (pin 11/J1-L), NC (pin 12/J1-M), NO (pin 19/J1-R)
- NC auxiliary contact provides PPS readback (closed when switch is in grounding position = safe)

Also in the termination tank:
- **Manual grounding switch (SW2)**: Mushroom-type, manually operated backup
- **Danfysik UltraStab DC-CT**: Measures HVPS output current (10A/V), output to PLC Slot-9 IN3
- **Pearson CT-110**: Wideband current transformer for arc fault detection (coax to BNC-1)
- **Oil level sensor (LEV-3)**: NC dry contact to PLC Slot-6 IN8
- **15A/50mV shunt**: Return current measurement

---

## 4. Current PPS Interface with HVPS

### 4.1 PPS Connector — GOB12-88PNE

The PPS interface uses a single 8-pin circular connector (Burndy/Souriau Trim Trio, GOB12-88PNE) mounted in a locked enclosure on the exterior of the Hoffman Box.

| Pin | Signal | Direction | Routing | Destination |
|-----|--------|-----------|---------|-------------|
| **E** | PPS 1 Enable (+) | PPS → HVPS | To PLC Slot-6 IN14 AND Slot-5 OX8 OUT2 input side | PLC monitoring + hardware fail-safe for K4 |
| **F** | PPS 1 Enable (-) | PPS → HVPS | Return | — |
| **G** | PPS 2 Enable (+) | PPS → HVPS | To PLC Slot-6 IN15 | PLC monitoring only |
| **H** | PPS 2 Enable (-) | PPS → HVPS | Return | — |
| **A** | Readback 1 (Contactor) | HVPS → PPS | From TS-5 pin 15 ← S5 COM (via switchgear) | Contactor open = closed circuit |
| **B** | Readback 1 (Contactor) | HVPS → PPS | From TS-5 pin 14 ← S5 NC (via switchgear) | Contactor open = closed circuit |
| **C** | Readback 2 (Ross Switch) | HVPS → PPS | From TS-6 pin 12 ← Ross NC aux (via tank) | Switch grounded = closed circuit |
| **D** | Readback 2 (Ross Switch) | HVPS → PPS | From TS-6 pin 11 ← Ross COM aux (via tank) | Switch grounded = closed circuit |

### 4.2 PPS Signal Flow — Chain 1 (Vacuum Contactor)

```
PPS Chassis GOB12-88PNE Pin E (+24VDC)
    │
    ├──→ PLC Slot-6 IN14 (PPS 1 monitoring input)
    │        │
    │        └──→ PLC Rung 0014: Sets Emergency Off bits
    │        └──→ PLC Rung 0015: Sets PPS ON status (OR with PPS 2)
    │        └──→ PLC Rung 0017: Contactor Enable logic
    │                  │
    │                  └──→ Slot-5 OX8 OUT2 (relay output side)
    │                           │
    └──→ Slot-5 OX8 OUT2 (relay INPUT side) ← PPS 1 = HARDWARE FAIL-SAFE
              │
              │  [The OX8 relay SWITCHES the PPS 1 signal itself]
              │  [PLC rung controls the relay coil; PPS provides the power]
              │
              └──→ TS-5 ──→ K4 Relay Coil (switchgear)
                              │
                              ├── K4 NO contact 1 → Control voltage to chain
                              └── K4 NO contact 2 → MX Relay → L1 Holding Coil
                                                                    │
                                                            Contactor HELD CLOSED

READBACK:
    S5 NC Auxiliary Contact (on vacuum contactor HQ3)
        │
        └── TB2 pins 18 (COM), 19 (NC) ──→ Switchgear wiring
                                                │
                                                └── TS-5 pin 15 (COM) → GOB12 Pin A
                                                    TS-5 pin 14 (NC)  → GOB12 Pin B

    Contactor OPEN  → S5 NC CLOSED → Pins A-B: CLOSED circuit → PPS: SAFE
    Contactor CLOSED → S5 NC OPEN  → Pins A-B: OPEN circuit   → PPS: OPERATING
```

### 4.3 PPS Signal Flow — Chain 2 (Ross Grounding Switch)

```
PPS Chassis GOB12-88PNE Pin G (+24VDC)
    │
    └──→ PLC Slot-6 IN15 (PPS 2 monitoring input)
             │
             └──→ PLC Rung 0016: Ross Switch logic (PPS1 AND PPS2 → energize)
                       │
                       └──→ Slot-2 IO8 OUT3 (120 VAC output)
                                │
                                └──→ TS-6 pins 13-14 ──→ Ross switch coil
                                                           (P5/J1 pins N, P)

    When BOTH PPS 1 AND PPS 2 are present:
        PLC energizes IO8 OUT3 → Ross coil energized → switch OPEN (not grounding)
    When EITHER PPS is removed:
        PLC de-energizes IO8 OUT3 → Ross coil de-energized → switch CLOSES (grounding)

READBACK:
    Ross Switch Auxiliary Contact (in termination tank)
        │
        └── J1 pins L (COM), M (NC) ──→ TS-6 pin 11 (COM) → GOB12 Pin D
                                         TS-6 pin 12 (NC)  → GOB12 Pin C

    Switch CLOSED (grounding) → NC contact CLOSED → Pins C-D: CLOSED → PPS: SAFE
    Switch OPEN (operating)   → NC contact OPEN   → Pins C-D: OPEN   → PPS: OPERATING
```

### 4.4 PLC Ladder Logic — PPS-Related Rungs

| Rung | Function | Inputs | Output | Logic |
|------|----------|--------|--------|-------|
| **0014** | Emergency Off Bits | Slot-6 IN14 (PPS 1) | Internal bits | Sets emergency off status flags |
| **0015** | PPS ON Status | Slot-6 IN14 OR IN15 | B3:1 (internal) | PPS considered "on" if either PPS signal present |
| **0016** | Ross Switch Control | PPS1 AND PPS2 | Slot-2 IO8 OUT3 | Ross coil energized only when BOTH PPS present |
| **0017** | Contactor Enable | Touch Panel Enable AND Emergency Off Clear | Slot-5 OX8 OUT2 | OX8 relay enables K4; **input side uses PPS 1 signal** |
| **0002** | Close Contactor | Various permits | Slot-5 OX8 OUT1 | Actual contactor close command |
| **0068** | Bias Power Enable | PPS 2 (Slot-6 IN15) | Bias power | Klystron bias power gated by PPS 2 |

---

## 5. Legacy PPS Safety Chain Analysis

### 5.1 Hardware Fail-Safe Mechanism

The key safety feature of the current design is in the Slot-5 OX8 OUT2 relay configuration:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     OX8 RELAY (OUT2) WIRING                        │
│                                                                     │
│   INPUT SIDE:  PPS 1 signal (+24VDC from GOB12 Pin E)             │
│   OUTPUT SIDE: PLC Rung 0017 controls the relay COIL               │
│                                                                     │
│   The relay SWITCHES the PPS 1 voltage itself.                     │
│   If PPS 1 is removed → no voltage to switch → K4 cannot energize │
│   If PLC fails → relay de-energizes → K4 de-energizes → SAFE      │
│   If PLC fails with relay STUCK ON → still uses PPS 1 as source   │
│                                                                     │
│   This provides a HARDWARE fail-safe: K4 REQUIRES PPS 1            │
│   regardless of PLC state.                                          │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 Fail-Safe Contact Convention

Both readback circuits use **Normally Closed (NC)** contacts:
- S5 NC contact: Closed when contactor is OPEN (safe) → closed circuit to PPS = safe
- Ross NC contact: Closed when switch is in grounding position (safe) → closed circuit to PPS = safe

This is a fail-safe design: a broken wire or lost connection appears as an UNSAFE condition to the PPS, causing a protective action.

### 5.3 Asymmetry Between PPS 1 and PPS 2

An important design detail: PPS 1 and PPS 2 do NOT have symmetric safety functions:

| Feature | PPS 1 (Pins E-F) | PPS 2 (Pins G-H) |
|---------|-------------------|-------------------|
| Hardware fail-safe to K4 | YES (OX8 input side) | NO |
| Ross switch control | YES (AND with PPS 2, Rung 0016) | YES (AND with PPS 1, Rung 0016) |
| Contactor enable (Rung 0017) | Indirectly (through PLC + hardware) | NO (not in rung 0017 logic) |
| Bias power (Rung 0068) | NO | YES |
| Emergency off (Rung 0014) | YES | NO (not referenced) |

This asymmetry means: if PPS 2 is removed but PPS 1 remains, the contactor could potentially stay energized (PPS 1 still powers OX8 input), but the Ross switch de-energizes and the bias power disables.

---

## 6. Known Issues with the Current HVPS-PPS Design

The following issues were identified through engineering analysis and documented in Jim Sebek's 2022 email to PPS management:

### 6.1 PPS Wiring Exposure (Radiation Safety Concern)

**Issue**: PPS wires from the GOB12-88PNE connector terminate on TS-5 and TS-6 *inside* the Hoffman Box, alongside non-PPS wiring. The readback wires (S5 aux, Ross aux) pass through terminal strips that also carry HVPS control signals.

**Impact**: To open the Hoffman Box for maintenance, a radiation safety work control form and system retest may be required because PPS wiring is exposed. This creates an unnecessary maintenance burden and potential for accidental PPS wire disturbance.

**Standard**: Modern PPS standards typically require PPS wiring to be physically separated from non-PPS equipment, or enclosed in dedicated conduit/junction boxes.

### 6.2 PLC Dependency for Ross Switch (Chain 2)

**Issue**: The Ross grounding switch coil is directly controlled by the PLC via Slot-2 IO8 OUT3 (120 VAC). The PPS enable signals are inputs to the PLC, and the PLC *decides* whether to energize the Ross coil based on its ladder logic (Rung 0016).

**Impact**: If the PLC processor fails in a way that leaves outputs in an indeterminate state, the Ross switch behavior is unpredictable. While a normal PLC failure de-energizes outputs (causing the Ross switch to close/ground — the safe state), a stuck-on failure mode would leave the Ross switch open.

**Comparison with Chain 1**: Chain 1 (contactor) has a hardware fail-safe where PPS 1 directly powers the OX8 relay input side, making K4 independent of PLC software state. Chain 2 has no equivalent hardware fail-safe — it is purely PLC-dependent.

### 6.3 Hardware Obsolescence

**Issue**: The Allen-Bradley SLC-500 platform (1747-L532 processor, 1746-series I/O modules) is obsolete and no longer manufactured. Replacement parts are increasingly difficult to obtain and expensive.

**Affected modules**:
- AB-1747-L532 processor
- AB-1747-DCM scanner
- AB-1746-IO8 combo module
- AB-1746-OX8 relay output
- AB-1746-IB16 DC input
- AB-1746-IV16 DC input
- AB-1746-THERMC thermocouple
- AB-1746-NIO4V analog I/O
- AB-1746-NI4 analog input

### 6.4 Documentation Errors (Corrected)

Several errors were discovered during system analysis and have been corrected in the `pps/diagrams/` documentation:

| Error | Location | Correction |
|-------|----------|------------|
| K4 and RR relay labels swapped | WD-730-794-02-C0 | K4 is PPS control (not reset); RR is reset (not PPS) |
| L1 and L2 coil labels incorrect | GP-439-704-02-C1 | Both labeled as L2; corrected per rossEngr713203 |
| Hand drawing terminal strip error | HoffmanBoxPPSWiring.docx Figure 1 | Pin A→TS-4 pin 14 should be Pin A→TS-5 pin 15; Pin B→TS-4 pin 15 should be Pin B→TS-5 pin 14 |
| PLC Rung 0017 mislabeled | HoffmanBoxPPSWiring.docx | Labeled "Crowbar On" but actually controls "Contactor Enable" |
| Manual grounding switch contact type | WD-730-794-06-C0 vs SD-730-790-05-C1 | NO vs NC inconsistency — **field verification required** |

### 6.5 Incomplete Verification

Per Jim Sebek's 2022 email: "Under a high voltage electrician lockout, we looked at some wiring in their local HVPS contactor controller. I think that we verified some of the wiring to the input relays, but I do not think we verified their logic chain past that."

This means the PPS chain from K4 relay through MX, L1, and the contactor closing/opening sequence has not been fully field-verified against the schematic documentation.

---

## 7. Upgraded HVPS System Design

### 7.1 Hardware Changes

The HVPS controller upgrade replaces or modifies the following:

| Component | Legacy | Upgraded | Status |
|-----------|--------|----------|--------|
| **PLC** | SLC-500 (AB-1747-L532) | **CompactLogix** | Hardware procured; software development needed |
| **PLC I/O** | 1746-series modules | **CompactLogix I/O** | Procured for HVPS1, HVPS2, and B44 Test Stand |
| **SCR Gate Driver** | Original Enerpro firing board | **New Enerpro boards** (5 needed, ~$4k) | To be procured |
| **Analog Regulator** | PC-237-230-14-C0 regulator card | **Redesigned analog regulator** | Design needed |
| **Communication** | Data Highway (SLC-500 scanner) | **Ethernet/EPICS** (EtherNet/IP or OPC-UA) | Architecture decision needed |
| **Supervisory Control** | SNL rf_hvps_loop.st on VxWorks | **Python/EPICS hvps_loop.py** | Software design documented |
| **Interface to LLRF** | Direct via VXI backplane/CAMAC | **Via Interface Chassis + EPICS** | Interface Chassis design needed |

### 7.2 What Is Retained

The HVPS power stage (transformer, rectifier, oil system, SCR stack) is retained. The klystron, cavities, waveguide distribution, vacuum contactor (HQ3), contactor controller/driver (HCA-1-A), Ross grounding switch, termination tank components (Danfysik, Pearson, manual switch, oil level sensor), and all field cabling are retained.

### 7.3 New Subsystems Affecting the HVPS-PPS Interface

**Interface Chassis** (NEW — Critical for PPS):
- Central interlock coordination hub
- Optocoupler isolation (ACSL-6xx0 family) for all digital signals
- Fiber-optic drivers (HFBR-2412) for HVPS SCR enable and crowbar signals
- First-fault detection with hardware latching (<1 μs response)
- **Direct PPS control path** (eliminates PLC dependency for PPS functions)
- Isolated PPS readback routing

**Waveform Buffer System** (NEW — Indirect HVPS interface):
- 4 HVPS-related channels for voltage/current monitoring
- Analog comparator trips for HVPS fault detection
- Klystron collector power protection (DC power - RF power)

**LLRF9 Integration**:
- LLRF9 HVPS interlock output (spare digital output, default function)
- LLRF9 slow ADC can monitor HVPS-related analog signals
- LLRF9 HVPS masks (per-board HVPS mask PVs)
- LLRF9 STATUS signal feeds Interface Chassis (3.2V @ 8mA)

### 7.4 Upgraded HVPS Control Architecture

```
                Python/EPICS Coordinator (hvps_loop.py)
                    │
                    │  EPICS Channel Access (~1 Hz supervisory)
                    │
        ┌───────────┴────────────┐
        │                        │
   CompactLogix PLC         LLRF9 (x2)
   (HVPS regulation)        (RF measurement)
        │                        │
        │  PLC scan rate         │  10 Hz scalar readback
        │                        │
        │  ┌─── Analog ───┐      │  ┌── EPICS PVs ──┐
        │  │ Voltage ref   │      │  │ Drive power    │
        │  │ Current fbk   │      │  │ Gap voltage    │
        │  │ SCR firing    │      │  │ Cavity phases  │
        │  └───────────────┘      │  └────────────────┘
        │                        │
        └────────┬───────────────┘
                 │
          Interface Chassis
          (Hardware interlocks,
           PPS coordination,
           fiber-optic isolation)
                 │
    ┌────────────┼──────────────┐
    │            │              │
  HVPS SCR    HVPS Crowbar   PPS Interface
  Enable      Signal         (GOB12-88PNE
  (fiber)     (fiber)         or replacement)
```

### 7.5 Upgraded Supervisory Control Loop

The Python `hvps_loop.py` replaces the legacy SNL `rf_hvps_loop.st` with equivalent functionality:

| Legacy State | Upgraded Equivalent | Notes |
|--------------|---------------------|-------|
| `off` | `HVPSState.OFF` | HVPS idle, no voltage adjustment |
| `proc` | `HVPSState.PROCESSING` | Vacuum processing with voltage ramping |
| `on` | `HVPSState.REGULATING` | Maintains constant drive power or gap voltage |

Key differences:
- Python reads HVPS voltage/current from CompactLogix PLC via EPICS (instead of VXI bus)
- Python reads drive power from LLRF9 via EPICS (instead of VXI RFP module)
- Python writes voltage setpoint to CompactLogix PLC via EPICS
- PLC handles local voltage regulation loop (SCR firing angle)
- Hardware safety (interlock trips, crowbar) handled by Interface Chassis, not software

---

## 8. Upgraded PPS Interface with HVPS

### 8.1 Fundamental Architecture Change

The most significant change in the upgrade is the **removal of the PLC from the PPS safety chain**. In the upgraded system:

- PPS enable signals route **directly** to the Interface Chassis (not to the PLC)
- The Interface Chassis provides **direct hardware control** of K4 relay and Ross switch coil
- PPS readback signals route **through** the Interface Chassis with isolation
- The CompactLogix PLC handles only HVPS regulation — it is NOT in the PPS safety path
- All PPS-related connections use optocoupler or fiber-optic isolation

### 8.2 Upgraded PPS Chain 1 — Vacuum Contactor

```
PPS 1 Enable
    │
    └──→ Interface Chassis (optocoupler-isolated input)
              │
              ├──→ LLRF9 Enable signal (3.2V @ 8mA, optocoupler)
              │
              └──→ DIRECT to K4 Relay Coil (no PLC in path)
                        │
                        ├── K4 NO → MX Relay → L1 Holding Coil
                        └── Control voltage to chain
                                   │
                            Contactor HELD CLOSED

READBACK:
    S5 NC Auxiliary Contact (on vacuum contactor HQ3, RETAINED)
        │
        └── Interface Chassis (optocoupler-isolated readback)
                │
                └──→ PPS Interface (readback pins A-B)
```

**Key improvements over legacy:**
- No PLC in the control path — pure hardware chain
- Optocoupler isolation between PPS signals and HVPS equipment
- Interface Chassis provides first-fault detection (<1 μs)
- Failed Interface Chassis de-energizes K4 → fail-safe

### 8.3 Upgraded PPS Chain 2 — Ross Grounding Switch

```
PPS 2 Enable
    │
    └──→ Interface Chassis (optocoupler-isolated input)
              │
              └──→ DIRECT to Ross Switch Coil (no PLC in path)
                        │
                        Ross switch OPEN (not grounding) when PPS present
                        Ross switch CLOSES (grounding) when PPS removed

READBACK:
    Ross NC Auxiliary Contact (in termination tank, RETAINED)
        │
        └── Interface Chassis (optocoupler-isolated readback)
                │
                └──→ PPS Interface (readback pins C-D)
```

**Key improvements over legacy:**
- No PLC controlling the Ross switch coil — direct hardware path
- Ross switch coil power no longer routed through PLC relay module
- Eliminates the PLC-stuck-on failure mode for the Ross switch
- Isolated readback path

### 8.4 HVPS Control Signals via Interface Chassis

In addition to PPS, the Interface Chassis coordinates the following HVPS control signals:

| Signal | Type | Direction | Description |
|--------|------|-----------|-------------|
| **HVPS SCR ENABLE** | Fiber optic (HFBR-2412) | Interface Chassis → HVPS | Enables SCR gate firing; removal disables HVPS output |
| **HVPS KLYSTRON CROWBAR** | Fiber optic (HFBR-2412) | Interface Chassis → HVPS | Fires crowbar to short klystron output on fault |
| **HVPS STATUS** | Digital (optocoupler) | HVPS PLC → Interface Chassis | HVPS operating status for interlock logic |
| **LLRF9 STATUS** | Digital (3.2V) | LLRF9 → Interface Chassis | LLRF9 operating status (5V = OK, <0.1V = tripped) |
| **MPS PERMIT** | 24V digital | MPS PLC → Interface Chassis | Machine Protection System permit |
| **MPS HEARTBEAT** | 24V pulse | MPS PLC → Interface Chassis | Confirms MPS PLC is running |
| **SPEAR MPS** | 24V | SPEAR MPS → Interface Chassis | Storage ring machine protection |
| **ORBIT INTERLOCK** | 24V | Orbit system → Interface Chassis | Beam orbit interlock |

### 8.5 LLRF9 to HVPS Interface

The LLRF9 connects to the HVPS system through the Interface Chassis:

**LLRF9 → Interface Chassis:**
- Interlock output: 5V digital signal (+4.75V OK, <0.1V tripped, 220Ω impedance)
- This signal enables/disables HVPS SCR firing via the Interface Chassis
- The LLRF9 trips its output on RF fault conditions (overvoltage, baseband window, external interlock)

**Interface Chassis → LLRF9:**
- Enable input: 3.2V @ 8mA (optocoupler-isolated)
- When de-asserted, LLRF9 disables all DAC outputs (RF drive off)
- The Interface Chassis de-asserts this on PPS trip, MPS fault, HVPS fault, etc.

**LLRF9 → Python → CompactLogix:**
- HVPS voltage setpoint management via EPICS Channel Access
- LLRF9 provides klystron forward power measurement (Board 3 scalar readback)
- Python supervisory loop adjusts HVPS voltage setpoint based on LLRF9 measurements

---

## 9. Interface Chassis — The New PPS Coordination Hub

### 9.1 Purpose

The Interface Chassis is a **new custom hardware subsystem** that serves as the central coordination point for all hardware interlocks in the upgraded system. Its primary functions are:

1. **PPS Interface**: Receives PPS enable signals, routes them directly to controlled devices (K4, Ross switch), and returns readback signals — all with galvanic isolation
2. **Interlock Aggregation**: Combines fault signals from LLRF9, HVPS PLC, MPS PLC, SPEAR MPS, orbit interlock, and arc detection into coordinated response actions
3. **First-Fault Detection**: Hardware latching registers record which fault occurred first with <1 μs resolution
4. **Signal Isolation**: Optocoupler (ACSL-6xx0) and fiber-optic (HFBR-2412) isolation between all subsystems
5. **HVPS Control**: Provides fiber-optic isolated SCR enable and crowbar signals to the HVPS

### 9.2 Interface Chassis — HVPS-Related Connections

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INTERFACE CHASSIS                                 │
│                                                                     │
│  INPUTS:                                                            │
│    PPS 1 Enable ──[optocoupler]──→ K4 control logic                │
│    PPS 2 Enable ──[optocoupler]──→ Ross switch logic               │
│    LLRF9 Status ──[optocoupler]──→ Interlock aggregation           │
│    HVPS Status  ──[optocoupler]──→ Interlock aggregation           │
│    MPS Permit   ──[optocoupler]──→ Interlock aggregation           │
│    MPS Heartbeat─[optocoupler]──→ Watchdog logic                   │
│    SPEAR MPS    ──[optocoupler]──→ Interlock aggregation           │
│    Orbit Intlk  ──[optocoupler]──→ Interlock aggregation           │
│    Arc Detect   ──[dry contact]──→ Interlock aggregation           │
│    S5 Readback  ──[optocoupler]──→ PPS readback routing            │
│    Ross Readback─[optocoupler]──→ PPS readback routing             │
│    Wfm Buf Trip ──[TTL]─────────→ Interlock aggregation            │
│                                                                     │
│  OUTPUTS:                                                           │
│    K4 Relay Control ───────────→ Switchgear (contactor enable)     │
│    Ross Coil Control ──────────→ Termination tank (grounding sw)   │
│    HVPS SCR Enable ──[fiber]──→ HVPS Enerpro boards                │
│    HVPS Crowbar    ──[fiber]──→ HVPS crowbar circuit               │
│    LLRF9 Enable    ──[3.2V]──→ LLRF9 enable input                 │
│    PPS Readback 1  ──────────→ PPS chassis (S5 status)             │
│    PPS Readback 2  ──────────→ PPS chassis (Ross status)           │
│    First-Fault Reg ──────────→ MPS PLC / EPICS (fault data)       │
│                                                                     │
│  INTERLOCK LOGIC:                                                   │
│    Any fault → disable HVPS SCR Enable (fiber off)                 │
│    Any fault → disable LLRF9 Enable (3.2V off)                     │
│    PPS removed → de-energize K4 AND/OR Ross directly               │
│    Crowbar trigger → fire HVPS crowbar (fiber pulse)               │
│    First-fault register latches which input tripped first          │
│                                                                     │
│  RESET:                                                             │
│    MPS PLC reset signal → clears first-fault register              │
│    Requires all fault inputs clear before re-enabling              │
└─────────────────────────────────────────────────────────────────────┘
```

### 9.3 Critical Design Consideration: LLRF9-HVPS Feedback Loop

A key design challenge for the Interface Chassis is the **LLRF9 STATUS ↔ HVPS STATUS feedback loop**:

1. LLRF9 detects RF fault → LLRF9 STATUS goes low
2. Interface Chassis sees LLRF9 fault → disables HVPS SCR Enable
3. HVPS loses SCR enable → HVPS voltage drops → HVPS STATUS changes
4. Interface Chassis sees HVPS fault → additional fault latching
5. **Problem**: After fault clears, how does the system recover?

The Interface Chassis logic must be designed to allow:
- HVPS to recover after LLRF9 re-enables (LLRF9 STATUS goes high)
- LLRF9 to recover after Interface Chassis re-enables it (3.2V restored)
- Proper sequencing of re-enable signals to avoid oscillation
- MPS reset to clear first-fault register and allow restart

This feedback loop coordination is one of the most complex aspects of the Interface Chassis design.

---

## 10. Side-by-Side Comparison: Legacy vs. Upgraded HVPS-PPS Interface

### 10.1 Architecture Comparison

| Aspect | Legacy System | Upgraded System |
|--------|---------------|-----------------|
| **PPS Control Path** | Through SLC-500 PLC ladder logic | Direct via Interface Chassis hardware |
| **PPS Isolation** | Minimal — PPS wires on shared terminal strips | Full optocoupler and fiber-optic isolation |
| **Chain 1 (Contactor)** | PPS → PLC → OX8 relay → K4 (with PPS 1 hardware fail-safe) | PPS → Interface Chassis → K4 (direct, isolated) |
| **Chain 2 (Ross Switch)** | PPS → PLC → IO8 relay → Ross coil (PLC-dependent) | PPS → Interface Chassis → Ross coil (direct, isolated) |
| **Readback Path** | S5/Ross aux → TS-5/TS-6 → GOB12 (exposed wiring) | S5/Ross aux → Interface Chassis → PPS (isolated) |
| **First-Fault Detection** | None (software-based post-mortem analysis) | Hardware latching register (<1 μs) |
| **HVPS Enable** | PLC controls SCR firing directly | Fiber-optic isolated via Interface Chassis |
| **Crowbar Trigger** | Direct wiring | Fiber-optic isolated via Interface Chassis |
| **PLC Role in Safety** | Critical — PLC is in PPS chain | None — PLC handles regulation only |
| **PLC Failure Mode** | Ross switch: PLC-dependent (stuck-on risk) | All outputs fail to safe state (hardware) |
| **Wiring Exposure** | PPS wires accessible in Hoffman Box | PPS wires in isolated Interface Chassis |
| **Maintenance Access** | May require PPS work control form | Hoffman Box can be opened without PPS concern |

### 10.2 Signal Routing Comparison

**PPS 1 Enable Signal Path:**

| Step | Legacy | Upgraded |
|------|--------|----------|
| 1 | GOB12 Pin E (+24VDC) | PPS 1 Enable signal |
| 2 | Wired to PLC Slot-6 IN14 (monitoring) | Input to Interface Chassis (optocoupler) |
| 3 | Wired to OX8 OUT2 relay input side (fail-safe) | Interface Chassis direct output |
| 4 | PLC Rung 0017 controls OX8 relay coil | — (no PLC in path) |
| 5 | OX8 relay switches PPS 1 to TS-5 | Interface Chassis drives K4 directly |
| 6 | TS-5 → Belden cable → K4 coil | K4 coil (same endpoint) |

**PPS 2 / Ross Switch Path:**

| Step | Legacy | Upgraded |
|------|--------|----------|
| 1 | GOB12 Pin G (+24VDC) | PPS 2 Enable signal |
| 2 | Wired to PLC Slot-6 IN15 (monitoring) | Input to Interface Chassis (optocoupler) |
| 3 | PLC Rung 0016 (PPS1 AND PPS2 logic) | Interface Chassis hardware logic |
| 4 | PLC controls Slot-2 IO8 OUT3 (120 VAC) | Interface Chassis drives Ross coil directly |
| 5 | IO8 OUT3 → TS-6 pins 13-14 → Ross coil | Ross coil (same endpoint) |

### 10.3 Fail-Safe Comparison

| Failure Mode | Legacy Behavior | Upgraded Behavior |
|--------------|-----------------|-------------------|
| **PPS 1 removed** | K4 de-energizes (hardware fail-safe via OX8); Ross de-energizes (PLC logic) | K4 de-energizes (Interface Chassis); Ross de-energizes (Interface Chassis) |
| **PPS 2 removed** | Contactor may stay (PPS 1 still powers OX8); Ross de-energizes; bias power off | K4 and Ross both de-energize (Interface Chassis logic) |
| **PLC processor fault** | OX8 de-energizes → K4 safe; IO8 de-energizes → Ross safe (normal failure) | PLC not in safety path — no effect on PPS |
| **PLC stuck-on** | K4 safe (still needs PPS 1 voltage); Ross UNSAFE (coil stays energized) | PLC not in safety path — no effect on PPS |
| **Interface Chassis power loss** | N/A | All outputs de-energize → K4, Ross, LLRF9, HVPS SCR all safe |
| **Wire break in readback** | NC contact opens → PPS sees UNSAFE → protective action | Same behavior (NC contacts retained) |
| **Communication loss (Ethernet)** | Limited impact (PLC operates standalone) | PLC continues regulating; Interface Chassis continues protecting; Python supervisor pauses |

---

## 11. Why the HVPS-PPS Upgrade Is Complicated

The HVPS controller upgrade with PPS interface redesign is the most complex subsystem in the LLRF upgrade project for the following reasons:

### 11.1 Safety-Critical Boundary

The PPS is a **life-safety system**. Any modification to PPS wiring, control logic, or readback paths must be:
- Reviewed and approved by SLAC protection managers (Matt Cyterski's group or successors)
- Documented with formal change control
- Tested with radiation safety verification
- Possibly accompanied by a radiation safety work control form

This adds administrative and procedural overhead that no other subsystem in the LLRF upgrade requires.

### 11.2 Multiple Stakeholder Coordination

The HVPS-PPS interface involves multiple organizations:
- **RF Group**: Owns the HVPS controller and LLRF system
- **PPS/Protection Group**: Owns the PPS interface and has approval authority
- **Electrical Safety**: Involvement required for high-voltage work
- **Facilities**: May be involved in conduit/wiring modifications
- **Operations**: Must approve any changes affecting machine availability

### 11.3 Legacy Code Reverse Engineering

The SLC-500 PLC ladder logic must be reverse-engineered before migration to CompactLogix:
- Original code documentation is incomplete
- Rung labeling has known errors (e.g., Rung 0017 labeled "Crowbar On" but is actually "Contactor Enable")
- The code contains PPS-related logic that must be understood before removing PPS functions from the PLC
- Non-PPS functions (temperature monitoring, voltage regulation, fault handling) must be preserved

### 11.4 Custom Hardware Design

The Interface Chassis is a completely new, custom hardware subsystem:
- Requires PCB design for optocoupler and fiber-optic circuits
- Must handle mixed voltage levels (3.2V, 5V, 24V, 120VAC)
- First-fault detection logic requires careful timing design
- Signal isolation must meet PPS standards
- No commercial off-the-shelf solution exists
- Must be designed, fabricated, assembled, and tested before integration

### 11.5 Interconnection Complexity

The HVPS-PPS interface spans multiple physical locations:
- **Hoffman Box** (B118): PLC, power supplies, terminal strips, PPS connector
- **Switchgear** (contactor disconnect panel): Vacuum contactor, K4 relay, contactor controller
- **Termination Tank** (near klystron): Ross switch, Danfysik, Pearson
- **Interface Chassis** (new, location TBD): Central interlock hub

Cabling between these locations uses multi-conductor Teflon-insulated cables (Belden 83715 15C, Belding 83709 9C) that have been in place for decades. The upgrade must work with existing cable infrastructure where possible.

### 11.6 The LLRF9 STATUS / HVPS STATUS Feedback Loop

As described in Section 9.3, the bidirectional relationship between LLRF9 and HVPS through the Interface Chassis creates a feedback loop that must be carefully designed:
- LLRF9 fault disables HVPS, HVPS fault further complicates recovery
- The Interface Chassis must implement proper sequencing logic for system restart
- This logic does not exist in the legacy system (where the VXI-based LLRF and PLC operated semi-independently)

### 11.7 Testing Constraints

The HVPS system cannot be tested independently of the SPEAR3 machine in all configurations:
- Test Stand 18 (B44) provides a limited test environment for the CompactLogix PLC
- Full PPS chain testing requires access to the actual vacuum contactor and Ross switch
- Integration testing with the real klystron and cavities requires a SPEAR3 shutdown period
- The Dimtel commissioning support window is limited to one week

### 11.8 Backward Compatibility

The upgrade must maintain backward compatibility with:
- The PPS chassis (GOB12-88PNE connector and signal levels, unless PPS group approves change)
- The vacuum contactor closing/opening sequences (contactor controller HCA-1-A is retained)
- The Ross grounding switch coil requirements
- The S5 and Ross auxiliary contact wiring
- All existing field cables to switchgear and termination tank

---

## 12. Implementation Risks and Mitigations

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| PPS approval delays | High | Medium | Engage protection managers early; provide complete documentation |
| Interface Chassis design issues | High | Medium | Build prototype; test thoroughly before integration |
| SLC-500 code contains undocumented PPS logic | Medium | Medium | Complete reverse-engineering with field verification |
| Field cable incompatibility | Medium | Low | Verify all cable pinouts before cutover |
| LLRF9-HVPS feedback loop instability | High | Medium | Design and simulate Interface Chassis logic before fabrication |
| CompactLogix EPICS driver issues | Medium | Medium | Evaluate pycomm3, OPC-UA, and custom EtherNet/IP options early |
| Manual grounding switch contact type uncertainty | Low | High | Field verify NO vs NC before Interface Chassis design |
| Incomplete PPS chain verification | Medium | Medium | Schedule high-voltage electrician lockout for full verification |
| Test stand limitations | Medium | High | Maximize standalone testing; document all Test Stand 18 capabilities |
| Integration window too short | High | Medium | Complete all fabrication/assembly before shutdown; have backup plan |

---

## 13. Open Questions and Required Decisions

### 13.1 PPS-Specific Decisions

| Question | Options | Impact | Owner |
|----------|---------|--------|-------|
| Will PPS group approve removing PLC from safety chain? | Yes (Interface Chassis) / No (keep PLC in chain) | Fundamental architecture decision | PPS/Protection Group |
| Is the GOB12-88PNE connector retained or replaced? | Keep existing / New PPS interface standard | Affects Interface Chassis design | PPS/Protection Group |
| Must PPS wiring be in dedicated conduit? | Yes / No (isolated within Interface Chassis acceptable) | Affects installation scope | PPS/Protection Group |
| What PPS testing/certification is required? | Functional test only / Full retest / Radiation safety verification | Affects schedule | PPS/Protection Group |

### 13.2 HVPS-Specific Decisions

| Question | Options | Impact | Owner |
|----------|---------|--------|-------|
| CompactLogix EPICS driver | pycomm3 / OPC-UA / custom EtherNet/IP | Affects all HVPS software | RF Group |
| Analog regulator card redesign | Replicate existing / New design | Affects HVPS regulation performance | RF Group |
| Test Stand 18 scope | PLC only / PLC + Interface Chassis simulation | Affects testing completeness | RF Group |
| HVPS STATUS signal specification | Voltage levels, timing, behavior on fault | Affects Interface Chassis logic design | RF Group |

### 13.3 Interface Chassis Decisions

| Question | Options | Impact | Owner |
|----------|---------|--------|-------|
| Interface Chassis physical location | Inside Hoffman Box / Separate enclosure / Rack-mounted | Affects wiring and accessibility | RF Group |
| First-fault register readout method | Direct to MPS PLC / EPICS via dedicated IOC / Both | Affects diagnostics | RF Group |
| Reset logic: auto-reset or manual only? | Per-fault-type auto-reset / All manual / Configurable | Affects uptime and safety policy | RF Group + PPS |
| LLRF9-HVPS re-enable sequencing | Simultaneous / HVPS first then LLRF9 / Configurable | Affects recovery time and stability | RF Group |

### 13.4 Immediate Action Items

1. **Schedule meeting with PPS protection managers** to present upgraded PPS interface design and obtain preliminary feedback
2. **Complete field verification** of manual grounding switch contact type (NO vs NC)
3. **Complete full PPS chain field verification** (K4 → MX → L1 → contactor) under high-voltage electrician lockout
4. **Finalize Interface Chassis preliminary design** based on PPS group feedback
5. **Begin CompactLogix PLC programming** on Test Stand 18, starting with non-PPS functions (voltage regulation, temperature monitoring)
6. **Reverse-engineer complete SLC-500 ladder logic** and document all PPS-related rungs

---

*End of Document*
