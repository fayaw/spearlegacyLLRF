# SPEAR3 LLRF Upgrade System — Physical Design Report

**Document ID**: SPEAR3-LLRF-PDR-001
**Revision**: R0
**Date**: March 2026
**Author**: LLRF Upgrade Engineering Team (SSRL/SLAC)
**Classification**: Top-Level System Design Reference

---

## Purpose and Scope

This Physical Design Report is the top-level system design reference for the SPEAR3 Low-Level RF (LLRF) Upgrade Project. It describes the overall system architecture, the scope and high-level design of each subsystem in both the current (legacy) and upgraded configurations, and the interfaces and interactions between subsystems.

This document is intended to serve as the entry point for the detailed engineering design of each subsystem. It consolidates physical design information from across the project and provides traceability to the detailed design documents in this repository.

**Audience**: RF group engineers, controls engineers, PPS/protection specialists, operations staff, and management reviewers.

**Related Design Documents**:

| Doc # | Title | Content |
|-------|-------|---------|
| 1 | Overview of Current and Upgrade System | Full legacy/upgrade comparison, control loop mapping |
| 2 | SPEAR3 LLRF Upgrade System Design | Detailed engineering design (docx) |
| 3 | LLRF9 System & Software Report | LLRF9 hardware, EPICS IOC, PV architecture |
| 4 | HVPS Engineering Technical Note | HVPS power section, controller, upgrade design |
| 5 | Klystron Heater Subsystem Upgrade | SCR-based heater control design |
| 8 | HVPS-PPS Interface Technical Document | PPS interface, safety chain, Interface Chassis |
| 9 | Software Design | Python/EPICS coordinator architecture |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System-Level Architecture](#2-system-level-architecture)
3. [Physical Layout and Locations](#3-physical-layout-and-locations)
4. [RF Plant — Retained Physical Infrastructure](#4-rf-plant--retained-physical-infrastructure)
5. [Subsystem 1: LLRF Controller](#5-subsystem-1-llrf-controller)
6. [Subsystem 2: High Voltage Power Supply (HVPS)](#6-subsystem-2-high-voltage-power-supply-hvps)
7. [Subsystem 3: Machine Protection System (MPS)](#7-subsystem-3-machine-protection-system-mps)
8. [Subsystem 4: Interface Chassis](#8-subsystem-4-interface-chassis)
9. [Subsystem 5: Personnel Protection System (PPS) Interface](#9-subsystem-5-personnel-protection-system-pps-interface)
10. [Subsystem 6: Tuner Control System](#10-subsystem-6-tuner-control-system)
11. [Subsystem 7: Waveform Buffer System](#11-subsystem-7-waveform-buffer-system)
12. [Subsystem 8: Arc Detection System](#12-subsystem-8-arc-detection-system)
13. [Subsystem 9: Klystron Cathode Heater](#13-subsystem-9-klystron-cathode-heater)
14. [Subsystem 10: Control Software](#14-subsystem-10-control-software)
15. [Control Loop Architecture](#15-control-loop-architecture)
16. [Inter-Subsystem Interface Matrix](#16-inter-subsystem-interface-matrix)
17. [Protection Chain and Interlock Architecture](#17-protection-chain-and-interlock-architecture)
18. [Communication Architecture](#18-communication-architecture)
19. [Implementation Phases and Risk Summary](#19-implementation-phases-and-risk-summary)
20. [Appendix: Source Document Index](#20-appendix-source-document-index)

---

## 1. Executive Summary

The SPEAR3 RF station provides 476 MHz RF power to the SPEAR3 storage ring at the Stanford Synchrotron Radiation Lightsource (SSRL). A single klystron, driven at approximately 1 MW, feeds four single-cell RF cavities through a waveguide distribution network. The combined cavity gap voltage is approximately 3.2 MV.

The LLRF Upgrade Project replaces the entire control electronics chain — not merely the low-level RF controller, but also the machine protection system, HVPS controller, tuner motor controllers, and supporting infrastructure. The project also introduces several new subsystems that did not exist in the legacy system: an Interface Chassis for centralized hardware interlock coordination, a Waveform Buffer System for extended signal monitoring and klystron collector protection, an optical arc detection system, and a modernized klystron cathode heater controller.

### Key System Parameters

| Parameter | Value |
|-----------|-------|
| RF Frequency | ~476 MHz |
| Total Gap Voltage | ~3.2 MV (sum of 4 cavities) |
| Cavity Gap Voltage | ~800 kV each |
| Klystron Power | ~1 MW |
| HVPS Voltage | up to ~90 kV (negative polarity) |
| HVPS Operating Voltage | ~74.7 kV at 500 mA beam |
| Drive Power | ~50 W nominal |
| Number of Cavities | 4 (single-cell, individual tuners) |
| LLRF9 Units | 2 active, 2 spare (4 purchased) |

### Upgrade Drivers

1. **Hardware obsolescence** — VXI, CAMAC, PLC-5, SLC-500, and analog modules are end-of-life
2. **PPS compliance** — Legacy design routes PPS wiring through HVPS controller and has PLC in the safety chain
3. **Performance improvement** — Digital FPGA-based feedback (270 ns loop delay) replaces analog processing
4. **Diagnostics** — 16k-sample waveform capture, circular buffers, first-fault detection, and collector protection
5. **Maintainability** — Modern hardware, comprehensive documentation, Python/EPICS software


---

## 2. System-Level Architecture

### 2.1 Legacy System Architecture

The legacy SPEAR3 LLRF system was originally designed for the PEP-II B-Factory (circa 1997) and later adapted for SPEAR3. It consists of:

- **LLRF Controller**: Custom PEP-II analog RF Processor (RFP) module in a VXI chassis, with associated analog signal processing modules (CFM, GVF) for comb filter and gap voltage feedback
- **Control Software**: State Notation Language (SNL) programs on VxWorks RTOS, running on the VXI crate processor
- **HVPS Controller**: Allen-Bradley SLC-500 PLC with Enerpro SCR gate driver boards, housed in a Hoffman NEMA enclosure in Building B118
- **Machine Protection System (MPS)**: Allen-Bradley PLC-5 (1771 series)
- **Tuner Motor Controllers**: Allen-Bradley 1746-HSTP1 stepper modules with Superior Electric SS2000MD4-M Slo-Syn PWM drivers (obsolete)
- **Interlock System**: Distributed across analog modules, PLC I/O, and direct wiring with no central coordination point
- **Communication**: VXI backplane, CAMAC, field bus, limited EPICS

### 2.2 Upgraded System Architecture

The upgraded system replaces all control electronics while retaining the RF plant physical infrastructure (klystron, cavities, waveguide, HVPS power section, tuner mechanical assemblies). The upgraded architecture is:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        OPERATOR LAYER                               │
│   EDM Panels  │  Web Dashboard  │  EPICS Archiver  │  Logging       │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ EPICS Channel Access
┌───────────────────────────┴─────────────────────────────────────────┐
│                  PYTHON/EPICS COORDINATOR                           │
│  State Machine │ HVPS Loop │ Tuner Manager │ Fault Manager │ Diag   │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ EPICS Channel Access (~1 Hz supervisory)
┌───────────────────────────┴─────────────────────────────────────────┐
│                     HARDWARE SUBSYSTEMS                             │
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────────────┐    │
│  │ LLRF9 #1 │  │ LLRF9 #2 │  │ HVPS PLC │  │ MPS PLC           │    │
│  │ (Field   │  │ (Monitor │  │ Compact- │  │ ControlLogix 1756 │    │
│  │  Control │  │  + Intlk)│  │ Logix    │  │                   │    │
│  │  + Tuner)│  │          │  │          │  │                   │    │
│  └────┬─────┘  └────┬─────┘  └─────┬────┘  └──────┬────────────┘    │
│       │             │              │              │                 │
│  ┌────┴─────────────┴──────────────┴──────────────┴────────────┐    │
│  │              INTERFACE CHASSIS (NEW)                        │    │
│  │   First-fault detection │ Optocoupler isolation │ Fiber I/O │    │
│  └────┬──────────────┬──────────────┬──────────────┬───────────┘    │
│       │              │              │              │                │
│  ┌────┴─────┐  ┌─────┴────┐  ┌──────┴───┐  ┌───────┴────────┐       │
│  │ Waveform │  │   Arc    │  │  Motor   │  │ Heater         │       │
│  │ Buffer   │  │ Detect.  │  │ Ctrl     │  │ Controller     │       │
│  │ System   │  │ (MIS)    │  │ (4-axis) │  │ (SCR-based)    │       │
│  └──────────┘  └──────────┘  └──────────┘  └────────────────┘       │
└─────────────────────────────────────────────────────────────────────┘
                            │
              Hardware interlock signals
                            │
┌───────────────────────────┴─────────────────────────────────────────┐
│                      SAFETY SYSTEMS                                 │
│  PPS Interface │ SPEAR MPS │ Orbit Interlock │ External Permits     │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.3 What Stays, What Changes, What Is New

**Retained Physical Hardware** (same equipment):
- Klystron and its RF output
- 4 RF cavities and waveguide distribution (circulator, magic-tees, waveguide loads)
- Stepper motors (M093-FC11 or equivalent) and mechanical tuner assemblies
- Linear potentiometers on tuners (position indication)
- HVPS power electronics (transformer, rectifier, oil system, crowbar)
- Vacuum contactor (Ross HQ3) and contactor controller (Ross HCA-1-A)
- Ross grounding switch, Danfysik DC-CT, Pearson CT-110
- Field cabling (Belden 83715 15C #16 Teflon, Belding 83709 9C #16 Teflon)

**Replaced / Upgraded**:
- LLRF Controller: Analog RFP → Dimtel LLRF9/476 (×2 units)
- MPS: PLC-5 1771 → ControlLogix 1756
- HVPS Controller: SLC-500 → CompactLogix PLC + new Enerpro boards + redesigned analog regulator
- Tuner Motor Controllers: AB 1746-HSTP1 + Slo-Syn → modern motion controller (Galil DMC-4143 or alternative, TBD)
- Control Software: SNL/VxWorks → Python/PyEPICS + LLRF9 internal EPICS IOC
- Operator Interface: Legacy EDM panels → modernized panels

**New Subsystems** (did not exist in legacy):
- Interface Chassis — central hardware interlock coordination hub
- Waveform Buffer System — 8 RF + 4 HVPS channel extended monitoring
- Arc Detection — Microstep-MIS optical sensors on cavity windows and klystron

**Enhanced Subsystems** (upgraded from legacy):
- Klystron Heater Controller — Motor-driven variac → SCR-based with EPICS integration
- Collector Power Protection — Forward power proxy → Direct DC-RF power calculation in Waveform Buffer System


---

## 3. Physical Layout and Locations

The SPEAR3 RF station spans multiple buildings and locations at SSRL/SLAC:

| Location | Equipment | Notes |
|----------|-----------|-------|
| **Building B118** (Controller Room) | HVPS Controller (Hoffman Box) | HVPS control location |
| **Building B514** (HVPS Vault) | HVPS Main Tank (transformer, rectifier, inductor, filter caps), Phase Tank (12 thyristor stacks), Crowbar Tank (4 thyristor stacks, output V-divider), Grounding Tank (Danfysik DC-CT, Pearson CT-110, Ross switch) | High-voltage power section; FR3 oil-filled, N₂ blanket |
| **Contactor Disconnect Panel** (Switchgear, adjacent to B514) | Vacuum contactor (Ross HQ3), Contactor controller (Ross HCA-1-A), K4/MX/RR/L1 relays, S5 auxiliary contact | 12.47 kV AC switchgear |
| **Termination Tank** (near klystron) | HV cable termination, Ross Engineering HV relay | Mineral oil filled |
| **Switch-over Tank** (adjacent B514) | HV cable connections between SPEAR1/SPEAR2 and klystron | FR3 oil filled |
| **Building B132** (Klystron ) | Klystron, drive amplifier, LLRF9 units, MPS PLC, Interface Chassis, Waveform Buffer, Motion Controller, Python coordinator server | Main control electronics location|
| **SPEAR3 Storage Ring Tunnel** | 4 RF cavities, waveguide distribution, tuner assemblies, arc detection sensors | Radiation area |

### Cabling Between Locations

| Cable Run | Cable Type | Conductors | Route |
|-----------|-----------|------------|-------|
| B118 → Switchgear (Contactor) | Belden 83715 | 15C #16 Teflon | TS-5 to contactor controller |
| B118 → Termination Tank (Grounding) | Belding 83709 + Belden 83715 | 9C + 15C #16 Teflon | TS-6 to grounding tank |
| B118 → B514 (HVPS) | Electrical cable pairs | SCR trigger cables (12 pairs) | Controller to Phase Tank thyristor stacks |
| B118 → B514 (HVPS) | Fiber optic | SCR ENABLE, CROWBAR, STATUS | Controller to HVPS (upgrade: via Interface Chassis) |
| B132 → B132 | Coax cables | RF drive signal | To drive amplifier |
| B132 → Tunnel | Coax cables | RF signals (forward, reflected, probe) | LLRF inputs from cavities |
| B132 → Tunnel | Multi-conductor | Motor power + encoder signals | To tuner assemblies |

---

## 4. RF Plant — Retained Physical Infrastructure

The RF plant is the physical chain that delivers 476 MHz RF power from the klystron to the storage ring beam. All of this hardware is retained as-is during the upgrade.

### 4.1 Klystron

The single klystron is located in Building B132 and operates at approximately 1 MW output power, driven at ~50 W input from the drive amplifier. The klystron cathode is powered by the HVPS at up to ~90 kV (nominal ~74.7 kV at 500 mA beam current). It has a non-full-power collector requiring dedicated protection (see Section 11.3 for upgrade and current implementation in Section 4.5).

### 4.2 Waveguide Distribution

The klystron output feeds a waveguide network consisting of:
- A circulator (protects klystron from reflected power)
- Magic-tee power splitters (two stage splitter that distributes power to 4 cavities)
- Waveguide loads (absorb rejected power)

### 4.3 RF Cavities

Four single-cell cavities at 476 MHz, each contributing ~800 kV gap voltage for a total of ~3.2 MV. Each cavity has:
- A cavity probe (monitors internal field amplitude and phase)
- A forward power coupler
- A reflected power coupler
- An individual stepper motor tuner (adjusts resonant frequency via mechanical plunger)
- Cavity window viewports (for arc detection sensor mounting)

### 4.4 Drive Amplifier

The drive amplifier is located in Building B132 near the klystron and boosts the LLRF9 output signal (~0 dBm) to ~50 W to drive the klystron input. In the upgrade, the LLRF9 Unit 1 output (from the thermally stabilized output chain on Board 1 or Board 2) connects to the drive amplifier input via coax cable. A KAW2051M12 amplifier datasheet is available in `llrf/driveAmp/`.

### 4.5 Legacy Collector Power Protection

The current SPEAR3 system includes collector power protection implemented through the HVPS control loop. The legacy system monitors klystron forward power and compares it against configurable limits:

**Current Implementation**:
- **Monitoring**: `LLRF:HVPS:PCOLL_MAX` PV sets maximum collector power limit
- **Protection Logic**: HVPS loop (`rf_hvps_loop.st`) monitors `klystron_forward_power` vs. `max_klystron_forward_power`
- **Action**: When klystron forward power exceeds limits, HVPS voltage is reduced (`delta_proc_voltage_down`)
- **Integration**: Collector limit displayed in HVPS EDL panel ("COLLECTOR LIMIT")

**Legacy Limitations**:
- Indirect protection through HVPS voltage adjustment (slow response)
- No direct DC power measurement or calculation
- Limited diagnostic capability for collector power trends
- Protection relies on forward power proxy rather than actual collector power calculation

### 4.6 RF Signal Monitoring

The amplitudes of the RF data need to be acquired. The RF signals that are currently monitored are listed in the table below, along with their location in the RF plant signal flow.

#### RF Plant Signal Flow

```
  (6) Station Ref ────────────────────────────────────────────────────────────────────────────────────────
  (5) Kly Drive ──► [Drive Amp] ──► [KLYSTRON] ──(1)Fwd──► [CIRCULATOR] ──(3,4)──► [CIRC LOAD]
                                      (2) Refl ◄──────────  P1=kly  P2→waveguide
                                                                      │
                                                                      ▼
                                                            [MAGIC TEE 1]  (1st split: half power each side)
                                                               P2│       P3│       P4│
                                                                 │         │         └──► [WG LOAD 1] (7,8)
                                                                 │         │
                                              ───────────────────┘         └───────────────────────
                                             │                                                     │
                                             ▼                                                     ▼
                                    [MAGIC TEE 2]  (2nd split)                          [MAGIC TEE 3]  (2nd split)
                                     P2│    P3│    P4│                                   P2│    P3│    P4│
                                       │      │      └──► [WG LOAD 2] (15,16)              │      │      └──► [WG LOAD 3] (23,24)
                                       │      │                                             │      │
                                       ▼      ▼                                             ▼      ▼
                                   [CAV A] [CAV B]                                      [CAV C] [CAV D]
                                   Fwd (9)  Fwd (11)                                   Fwd (17) Fwd (19)
                                  Refl (10) Refl (12)                                 Refl (18) Refl (20)
                                 Probe (13) Probe (14)                               Probe (21) Probe (22)
```

> **Note on waveguide loads**: By the magic-tee symmetry, equal reflected power from the two cavities feeding a magic tee exits port 4 into the attached waveguide load, not back toward the klystron. The circulator load absorbs power that the circulator does not properly direct to the cavities along with any net reflection returning from the first magic tee.

#### Monitored RF Signals

| # | Signal | Monitored By | Notes |
|---|--------|--------------|-------|
| 1 | Klystron Output Forward Power | LLRF9 Unit 2 BRD2 | RF power at the klystron output traveling toward the circulator; primary measure of station RF output level. |
| 2 | Klystron Output Reflected Power | LLRF9 Unit 2 BRD2 | RF power reflected back into the klystron output port from the load chain; should be near zero; used for klystron protection. |
| 3 | Circulator Load Forward Power | Waveform Buffer Ch1 | Power delivered to the circulator load (circulator port 3); absorbs power the circulator does not properly direct to the cavities plus any net reflection returning from the waveguide network. |
| 4 | Circulator Load Reflected Power | Waveform Buffer Ch2 | Power reflected from the circulator load back into the circulator; indicates load match quality. |
| 5 | Klystron Drive Power | LLRF9 Unit 2 BRD1 | Input drive signal level to the klystron from the drive amplifier; sets the klystron gain and operating point. |
| 6 | Station Reference Power | Waveform Buffer Ch3 | Monitor of the 476 MHz reference signal level distributed to the LLRF system; loss of this signal indicates a reference chain fault. |
| 7 | Waveguide Load 1 Forward Power | LLRF9 Unit 1 BRD3 | Power entering WG Load 1 at port 4 of Magic Tee 1; absorbs the combined out-of-phase reflections from the two second-layer magic tees that make it back to Magic Tee 1. |
| 8 | Waveguide Load 1 Reflected Power | Waveform Buffer Ch4 | Power reflected from WG Load 1 back into Magic Tee 1; indicates load match quality. |
| 9 | Cavity A Forward Power | LLRF9 Unit 1 BRD1 | RF power traveling into Cavity A from Magic Tee 2; used to monitor power distribution balance across cavities. |
| 10 | Cavity A Reflected Power | LLRF9 Unit 2 BRD3 | Power reflected from Cavity A back into the waveguide; elevated reflection indicates cavity detuning or mismatch. |
| 11 | Cavity B Forward Power | LLRF9 Unit 1 BRD2 | RF power traveling into Cavity B from Magic Tee 2; compared with Cavity A forward to verify magic-tee balance. |
| 12 | Cavity B Reflected Power | LLRF9 Unit 2 BRD3 | Power reflected from Cavity B; monitored for detuning and arc detection. |
| 13 | Cavity A Probe Signal | LLRF9 Unit 1 BRD1 | Electric field sampled by Cavity A's internal pickup probe; direct measure of the accelerating voltage amplitude and phase; primary LLRF fast feedback and tuner control input for Cavity A. |
| 14 | Cavity B Probe Signal | LLRF9 Unit 1 BRD1 | Electric field from Cavity B's internal probe; used in the LLRF vector-sum feedback and Cavity B tuner control. |
| 15 | Waveguide Load 2 Forward Power | LLRF9 Unit 1 BRD3 | Power entering WG Load 2 at port 4 of Magic Tee 2; absorbs the sum of equal reflected power from Cavities A and B. |
| 16 | Waveguide Load 2 Reflected Power | Waveform Buffer Ch5 | Power reflected from WG Load 2; indicates match quality of the load. |
| 17 | Cavity C Forward Power | LLRF9 Unit 1 BRD2 | RF power traveling into Cavity C from Magic Tee 3. |
| 18 | Cavity C Reflected Power | LLRF9 Unit 2 BRD3 | Power reflected from Cavity C; monitored for detuning and arc detection. |
| 19 | Cavity D Forward Power | LLRF9 Unit 2 BRD1 | RF power traveling into Cavity D from Magic Tee 3. |
| 20 | Cavity D Reflected Power | LLRF9 Unit 2 BRD2 | Power reflected from Cavity D. |
| 21 | Cavity C Probe Signal | LLRF9 Unit 1 BRD2 | Electric field from Cavity C's internal probe; used in the LLRF vector-sum feedback and Cavity C tuner control. |
| 22 | Cavity D Probe Signal | LLRF9 Unit 2 BRD1 | Electric field from Cavity D's internal probe; used in the LLRF vector-sum feedback and Cavity D tuner control. |
| 23 | Waveguide Load 3 Forward Power | LLRF9 Unit 1 BRD3 | Power entering WG Load 3 at port 4 of Magic Tee 3; absorbs the sum of equal reflected power from Cavities C and D. |
| 24 | Waveguide Load 3 Reflected Power | Waveform Buffer Ch6 | Power reflected from WG Load 3; indicates match quality of the load. |



---

## 5. Subsystem 1: LLRF Controller

> **Detailed reference**: `llrf/llrf9`

### 5.1 Legacy System

The legacy LLRF controller is a custom PEP-II analog RF Processor (RFP) module in a VXI chassis. It performs analog I/Q processing at ~kHz bandwidth for the fast RF feedback loop. Associated modules include the CFM (Comb Filter Module) for multi-bunch stabilization and the GVF (Gap Voltage Feedback) for gap voltage regulation. The VXI chassis also hosts a processor running VxWorks RTOS with SNL (State Notation Language) control programs.

The legacy system processes 24 RF channels through the VXI system and uses analog-domain signal processing for feedback, calibration, ripple rejection, and comb filtering.

### 5.2 Upgraded System — Dimtel LLRF9/476

Two Dimtel LLRF9/476 units replace the entire VXI-based LLRF system (four units purchased; two active, two spares).

**Hardware per unit**:
- 3 × LLRF4.6 boards: each with Xilinx Spartan-6 FPGA, 4 high-speed ADC channels, 2 DAC channels, 3 RF channel.
- LO/Interconnect module: divide-and-mix LO synthesis for low phase noise, RF reference distribution, output amplification/filtering, interlock logic
- Linux SBC (mini-ITX): runs the built-in EPICS IOC (EPICS Base 3.14)
- Thermal stabilization: aluminum cold plate with 3 TEC modules under PID control, only available to board1&2
- Power supply: 90-264 VAC auto-ranging
- 3U 19" rack chassis

**LO Frequency Plan (LLRF9/476)**:

| Signal | Ratio to f_rf | Frequency (MHz) |
|--------|--------------|------------------|
| Reference (f_rf) | 1 | 476.000 |
| IF | 1/12 | 39.667 |
| Local Oscillator | 11/12 | 436.333 |
| ADC Clock | 11/48 | 109.083 |
| DAC Clock | 11/24 | 218.167 |

**Auxiliary I/O per unit**:
- 8 slow ADC channels (12-bit, selectable ranges, galvanically isolated)
- 12 slow DAC outputs (AD5644)
- Opto-isolated interlock input (3.3V/5V/24V selectable)
- Interlock output (+4.75V high / <0.1V tripped, 220 Ω)
- Two opto-isolated trigger inputs

### 5.3 Two-Unit Configuration for SPEAR3

**Unit 1 — Field Control & Tuner Loops**:

| Board | Ch0 (Ref) | Ch1 | Ch2 | Ch3 | Output | Thermal Stabilization |
|-------|-----------|-----|-----|-----|--------|-----------------------|
| BRD1 | Station Ref | Cav A Probe | Cav B Probe | Cav A Fwd | Klystron Drive | Y |
| BRD2 | Station Ref | Cav C Probe | Cav C Fwd | Cav B Fwd | (Spare / Monitor) | Y |
| BRD3 | Station Ref | WG Load 1 Fwd | WG Load 2 Fwd | WG Load 3 Fwd | (Not used) | N |

- **Primary vector sum**: Only Cavities A & B (on BRD1, same board as output) participate in the 270 ns direct feedback loop for klystron drive
- **Critical constraint**: Cavities C & D are monitored but NOT in the main fast feedback loop
- **Tuner phase data**: All 4 cavity probe phases available at 10 Hz for tuner control
- **BRD3**: Monitors the three waveguide load forward power signals (WG Load 1, 2, 3); RF connections on rear panel only; no thermal stabilization

**Unit 2 — Monitoring & Interlocks**:

| Board | Ch0 (Ref) | Ch1 | Ch2 | Ch3 | Output | Thermal Stabilization |
|-------|-----------|-----|-----|-----|--------|-----------------------|
| BRD1 | Station Ref | Cav D Probe | Cav D Fwd | Drv Fwd | (Not used) | Y |
| BRD2 | Station Ref | Cav D Refl | Kly Refl | Kly Fwd | (Not used) | Y |
| BRD3 | Station Ref | Cav A Refl | Cav B Refl | Cav C Refl | (Not used) | N |


- **Reflected power monitoring**: All 4 cavity reflected + klystron reflected for arc/mismatch detection
- **Interlock chain**: Reflected power events → Unit 2 interlock output → Interface Chassis → disables Unit 1 drive
- **No drive output required** from Unit 2

> **Remaining RF signals**: The 6 signals not covered by the two LLRF9 units (Circulator Load Fwd/Refl, Station Reference, WG Load 1/2/3 Reflected) are monitored by the Waveform Buffer System — see [Section 11](#11-subsystem-7-waveform-buffer-system).

### 5.4 Key Performance Specifications

| Parameter | Value |
|-----------|-------|
| Direct loop delay | 270 ns |
| RF input channels | 9 per unit (18 total) |
| RF input range | 0 to -30 dBm |
| ADC resolution | 12-bit |
| Setpoint profile points | 512 |
| Setpoint step time range | 70 μs to 37 ms per step |
| Waveform samples/channel | 16,384 |
| Scalar readback rate | 10 Hz |
| Scalar readback bandwidth | 4.4 Hz |
| Phase readback resolution | Sub-degree |
| Interlock timestamp resolution | ±17.4 ns |

### 5.5 Interfaces

- **RF inputs**: 50 Ω SMA from cavity probes, forward couplers, reflected couplers, station reference
- **RF output**: SMA to drive amplifier (Unit 1 only, thermally stabilized, BRD1 or BRD2)
- **Interlock I/O**: LEMO connectors; Unit 1 external interlock input from Interface Chassis, Unit 2 interlock output to Interface Chassis
- **Slow ADC**: DA-15 connector; HVPS monitoring signals, auxiliary sensors
- **Ethernet**: Channel Access for EPICS communication (default ports 5064/5065)
- **Unit 1 ↔ Unit 2**: Interlock daisy-chain (Unit 2 reflected power trip disables Unit 1 drive)


---

## 6. Subsystem 2: High Voltage Power Supply (HVPS)

> **Detailed reference**: `hvps/`

### 6.1 Power Section (Retained)

The HVPS converts 12.47 kV RMS 3-phase AC to regulated DC high voltage for the klystron cathode.

**Power chain**:
```
12.47 kV 3φ → Phase-Shift Xfmr (3.5 MVA, ±15°) → 2 Rectifier Xfmrs (1.5 MVA each)
→ 12-Pulse Thyristor Bridges (12 stacks × 14 Powerex T8K7 each)
→ Filter Inductors (2 × 0.3 H) → 4 Secondary Rectifiers (series)
→ Crowbar Tank (4 thyristor stacks, fiber-optic triggered)
→ −90 kV DC → Klystron
```

| Parameter | Value |
|-----------|-------|
| Maximum output voltage | −90 kV DC |
| Maximum output current | 27 A |
| Maximum output power | 2.5 MW |
| Nominal operating voltage | −74.7 kV |
| Nominal operating current | 22.0 A |
| Rectifier topology | 12-pulse, thyristor phase-controlled |
| Number of HVPSs | 2 (SPEAR1 active, SPEAR2 warm spare) |
- **Nominal operatiing beam current**: 500 mA

The power section, including transformers, thyristor stacks, filter inductors, secondary rectifiers, crowbar, oil system, and all power cabling, is retained unchanged.

### 6.2 Legacy Controller

The legacy controller is housed in a Hoffman NEMA enclosure (34"×42") in Building B118 and contains:

- **PLC**: Allen-Bradley SLC-500 (1747-L532 CPU) with I/O modules in slots 1-9 (OBSOLETE)
- **Enerpro Firing Board**: Current SCR gate driver
- **Regulator Card** (PC-237-230-14-C0): Analog voltage regulation loop
- **Power Supplies**: SOLA ±15V/+5V/24V, Kepko 120V (×2), Kepko 5V/20A, Kepko 240V
- **PS Monitor Board** (SD-730-793-12): Monitors power supply health
- **Terminal Strips**: TS-5 (contactor, 15 terminals), TS-6 (grounding tank, 21 terminals), TS-3 (PPS LEDs), TS-7 (power distribution)
- **PPS Connector**: GOB12-88PNE (Burndy/Souriau Trim Trio), 8-pin, in locked box

The SLC-500 PLC executes ladder logic for voltage regulation, contactor management, temperature monitoring, and — critically — PPS safety chain control (Ross grounding switch via Slot-2 IO8 OUT3).

### 6.3 Upgraded Controller

The HVPS controller upgrade replaces the PLC and SCR gate driver while retaining the power section and Hoffman enclosure.

**New hardware**:
- **CompactLogix PLC**: Replaces SLC-500; handles voltage regulation, temperature monitoring, fault management, and EPICS communication
- **Enerpro FCOG1200 Board**: Upgraded SCR gate driver with modified RN4 resistors for SPEAR monitor winding impedance (2 MΩ)
- **Redesigned Analog Regulator**: Replaces obsolete regulator card components
- **Fiber Optic Interfaces**: HFBR-1412 transmitter (STATUS), HFBR-2412 receivers (SCR ENABLE, CROWBAR) — connected to Interface Chassis, NOT directly to LLRF

**Key change**: The CompactLogix PLC is removed from the PPS safety chain. PPS functions (K4 relay, Ross switch control) are routed through the new Interface Chassis instead. The PLC handles only non-safety functions: voltage regulation, temperature monitoring, and EPICS interface.

### 6.4 HVPS EPICS Interface

| PV Category | Example PV | Update Rate |
|-------------|------------|-------------|
| Setpoint | `SRF1:HVPS:VOLT:CTRL.VAL` | ≤1 Hz (from Python) |
| Readback | `SRF1:HVPS:VOLT:RBCK` | ~1 Hz |
| Status | `SRF1:HVPS:STATUS:READY` | ~1 Hz |
| Control | `SRF1:HVPS:CONTACTOR:CMD` | On demand |
| Interlock | `SRF1:HVPS:INTLK:SUMMARY` | ~1 Hz |

### 6.5 HVPS Interfaces

- **Interface Chassis** (fiber optic): SCR ENABLE (in), CROWBAR inhibit (in), STATUS (out)
- **Python Coordinator** (EPICS/Ethernet): Voltage setpoint, readbacks, fault status
- **Waveform Buffer System**: HVPS voltage, current, inductor voltages monitored on 4 dedicated channels
- **Switchgear**: Existing field cables to vacuum contactor controller and grounding tank

---

## 7. Subsystem 3: Machine Protection System (MPS)

### 7.1 Legacy System

The legacy MPS uses an Allen-Bradley PLC-5 (1771 series). It aggregates interlock signals from the RF system, HVPS, and external sources (SPEAR MPS, orbit interlock) and manages the RF permit.

### 7.2 Upgraded System — ControlLogix 1756

The MPS PLC is upgraded to Allen-Bradley ControlLogix 1756 platform.

**Status**: Hardware assembled, software written, tested without RF power. Ready for EPICS development and system integration.

**Functions**:
- Aggregate all RF interlock inputs (from Interface Chassis status outputs)
- Issue global RF permit signal (to Interface Chassis)
- Provide heartbeat signal to Interface Chassis (watchdog for MPS communication health)
- Issue reset signal to Interface Chassis (clears all latched faults)
- Log fault events with timestamps
- Provide EPICS interface for operator monitoring and diagnostics

### 7.3 MPS Interfaces

- **Interface Chassis**: MPS Summary permit (out), MPS Heartbeat watchdog (out), Reset signal (out), Fault status (in)
- **Python Coordinator** (EPICS): Status readbacks, fault history, permit control
- **External Safety Systems**: SPEAR MPS permit, orbit interlock, radiation safety (via Interface Chassis)


---

## 8. Subsystem 4: Interface Chassis

> **Primary design reference**: `llrf/architecture/llrfInterfaceChassis.docx`
>
> **Supporting references**:
> - `hvps/architecture/designNotes/interfacesBetweenRFSystemControllers.docx` — inter-controller signal specifications
> - `hvps/architecture/designNotes/controllerFiberOpticConnections.docx` — HVPS fiber-optic circuit details
> - `llrf/documentation/fiberOpticCableSignalControlRev3.docx` — fiber-optic signal control rationale
> - `hvps/architecture/designNotes/RFSystemMPSRequirements.docx` — protection philosophy and MPS requirements
> - `llrf/architecture/WaveformBuffersforLLRFUpgrade.docx` — Waveform Buffer comparator trip outputs
> - `llrf/architecture/arcDetectorHardwareOptions.docx` — arc detection interface requirements
> - `llrf/documentation/LLRFDocumentationNotesR2.docx` — legacy system interconnect documentation

### 8.1 Purpose and Legacy Context

The Interface Chassis is a **new subsystem** that centralizes all hardware interlock coordination for the RF system. It replaces interlock functions that were previously distributed across several legacy modules with no single coordination point:

| Legacy Module | Drawing | Function Replaced by Interface Chassis |
|---|---|---|
| RF System Local Panel | SD-340-311-01-R0 | Fiber-optic signal conditioning; analog permit aggregation for SCR ENABLE and CROWBAR signals; conversion of fiber-optic status from HVPS to electrical signal for VXI chassis |
| Arc Interlock Chassis (VXI) | SD-340-308-01/02-R1 | First-layer fault processing; RF signal detection; generation of HVPS fiber-optic control signals through Local Panel |
| Arc Interlock VXI Module | SD-340-309-01-C2 | VXI-bus interface to AB MPS; relay of AB SUMMARY and HEARTBEAT signals |
| Allen-Bradley PLC-5 MPS | — | Serial communication of interlock summary and heartbeat via DCM modules in daisy-chain topology |

In the legacy system, interlock signals traveled through multiple stages: the VXI module generated status signals, fiber-optic links connected through the Local Panel (which contained HFBR-1414 transmitters and HFBR-2416 receivers soldered on its PCB), and serial connections through Allen-Bradley DCM modules formed a daisy chain from the VXI scanner to the PLC-5 MPS, then to the SLC-500 tuner controller, and finally to the SLC-500 HVPS PLC via a telephone terminal box above the termination tank. This distributed architecture had no central first-fault identification in hardware, fault detection latency in the millisecond range through the PLC, and distributed analog logic prone to noise and drift.

The Interface Chassis replaces this architecture with:

- **First-fault detection** — hardware-based latching circuit that captures the initiating fault signal before cascade events propagate, providing unambiguous fault identification
- **Electrical isolation** — all external electrical signals isolated from chassis ground via optocouplers; fiber-optic signals are inherently isolated
- **Microsecond-scale response** — implemented entirely in standard electronic and electro-optical components with no processor in the critical path; processing delays on the order of microseconds
- **Fault latching** — all inputs latch when faulted; latches held until external reset from MPS
- **Status reporting** — all input permit states, all output permit states, and first-fault register status reported to the MPS PLC via digital lines

### 8.2 Input Signals

| Input Signal | Type | Source | Isolation | Notes |
|---|---|---|---|---|
| LLRF9 Status | 5 VDC, up to 60 mA | LLRF9 rear panel (daisy-chain output) | Optocoupler (ACSL-6xx0 family; 7–8 mA input) | Logical OR of 17 internal LLRF9 interlocks + 1 external permit. Output is 5 VDC when all OK, pulled low on any fault. See [Section 5.5](#55-interfaces). |
| HVPS STATUS | Fiber-optic (820 nm) | HVPS Left Side Trigger Interconnect Board (SD-730-793-08-C1) | HFBR-2412 receiver in Interface Chassis | Illuminated when: (1) PLC 24V Fault/Enable (Slot-5 OUT 0) is active, AND (2) no crowbar trigger condition exists. Does **not** indicate that the Enerpro firing circuit is enabled or that thyristors are actually firing. See [Section 8.3.2](#832-hvps-fiber-optic-signals). |
| MPS RF Summary Permit | Digital (24V) | RF MPS ControlLogix PLC | Optocoupler (HCPL-2400-000E) | Global RF system permit from the MPS. Removal removes all downstream permits. |
| MPS Heartbeat | Digital | RF MPS ControlLogix PLC | Optocoupler (HCPL-2400-000E) | Watchdog signal; loss indicates MPS communication failure. |
| MPS External Reset | Digital | RF MPS ControlLogix PLC | Optocoupler (HCPL-2400-000E) | Simultaneous reset of all latched faults in the Interface Chassis. Active-edge triggered. |
| SPEAR MPS Permit | 24 VDC | SPEAR MPS system | Optocoupler (HCPL-2400-000E) | Ring-wide machine protection permit. Also carries beamline MPS status (beamline MPS is a satellite of SPEAR MPS; it does not communicate directly with the RF system). |
| Orbit Interlock Permit | 24 VDC | SPEAR Orbit Interlock system | Optocoupler (HCPL-2400-000E) | Beam position safety permit. Removed if beam position exceeds safe trajectory envelope near any beamline. |
| Arc Detection | Dry relay contacts (NC = safe, open = fault) | MicroStep-MIS Wave Arc Detector control units | Optocoupler (HCPL-2400-000E) | Up to 4 control units (2 sensors each, one per cavity). Semiconductor switch in each control unit remains closed when no arc detected; latches open on detected arc. Requires external 24 VDC and digital lines for test and reset. |
| Power Monitoring | Digital (comparator trip) | Waveform Buffer System | Optocoupler (HCPL-2400-000E) | Single summary permit from analog comparator circuits. Trips if any monitored RF signal or HVPS signal exceeds preset threshold. Latched until reset. See [Section 11](#11-subsystem-7-waveform-buffer-system). |
| Expansion Inputs (x2) | TTL level | External (future use) | Optocoupler | For fast timing experiments requiring synchronous RF turn-off. Designed for 50 ohm termination upstream of chassis (BNC terminator); internal input impedance ~1 kohm. |
| Expansion Inputs (x2) | 24 VDC level | External (future use) | Optocoupler | General-purpose expansion for future subsystem integration. |

**Optocoupler design notes** (ref: `llrf/architecture/llrfInterfaceChassis.docx`):

The primary recommended optocoupler family for general electrical isolation is the **Broadcom ACSL-6xx0** (e.g., ACSL-6300-50TE, ACSL-6410-00TE). Key specifications:
- Maximum input forward voltage: 1.8 VDC
- Recommended minimum ON-state input current: 8 mA
- Maximum allowable input current: 15 mA
- Response time: ~0.5 us

The **Broadcom HCPL-2400-000E** (0.5 us response) is specified in `hvps/architecture/designNotes/interfacesBetweenRFSystemControllers.docx` as the standard for inter-controller isolation and is equally valid. Resistor values for each input voltage level are calculated as R = (V_input - 1.8 V) / I_target. Sample values for 8 mA and 10 mA designs:

| Input Voltage | R for 8 mA | R for 10 mA |
|---|---|---|
| 24 VDC | 2.78 kohm | 2.22 kohm |
| 12 VDC | 1.28 kohm | 1.02 kohm |
| 5 VDC | 400 ohm | 320 ohm |

The specific optocoupler selection for each interface (ACSL-6xx0 vs. HCPL-2400-000E) will be determined during detailed PCB design. Both families meet the microsecond response requirement.

### 8.3 Output Signals

| Output Signal | Type | Destination | Driver | Notes |
|---|---|---|---|---|
| LLRF9 Enable | >=3.2 VDC, >=8 mA | LLRF9 external interlock input (opto-isolated, daisy-chained pair) | Optocoupler output | Drives the shared external interlock input on the LLRF9 daisy chain. When removed, the LLRF9 disables its DAC output and opens its RF switch, which in turn pulls its own status output low. |
| HVPS SCR ENABLE | Fiber-optic (820 nm) | HVPS Right Side Trigger Interconnect Board (SD-730-793-07-C2) | HFBR-1412 transmitter in Interface Chassis | Hardware permit for phase control thyristor triggers. Removing this signal inhibits triggers on all phases except B+/B- (which remain enabled to discharge filter inductor current). See [Section 8.3.2](#832-hvps-fiber-optic-signals). |
| HVPS KLYSTRON CROWBAR | Fiber-optic (820 nm) | HVPS Left Side Trigger Interconnect Board (SD-730-793-08-C1) | HFBR-1412 transmitter in Interface Chassis | **Normally illuminated — no active control planned.** Removing this signal fires the crowbar thyristor stack to discharge HVPS output filter capacitors. See [Section 8.3.2](#832-hvps-fiber-optic-signals). |
| Fault Status (all inputs) | Digital lines | RF MPS ControlLogix PLC | Optocoupler | Reports the state of every input permit to the MPS for monitoring and logging. |
| Fault Status (all outputs) | Digital lines | RF MPS ControlLogix PLC | Optocoupler | Reports the state of every output permit to the MPS. |
| First-Fault Register | Digital lines | RF MPS ControlLogix PLC | Optocoupler | Identifies which input signal was the first to fault in a cascade event. Held until MPS reset. |

> **Note on PPS outputs**: The upgrade design concept (see [Section 9.3](#93-upgraded-pps-design)) proposes that the Interface Chassis directly drive the K4 relay (vacuum contactor control, PPS Chain 1) and the Ross grounding switch (PPS Chain 2), removing the PLC from the PPS safety chain. These PPS-related outputs (K4 Relay Drive, Ross Switch Drive, PPS Readback A-B, PPS Readback C-D) are described in Section 9 and are **not part of the primary Interface Chassis design document** (`llrfInterfaceChassis.docx`). They will require formal PPS regulatory review and approval before they can be incorporated into the Interface Chassis design. Until that review is complete, the Interface Chassis baseline design includes only the outputs listed in the table above.

#### 8.3.1 LLRF9 Interlock Daisy-Chain Topology

The two LLRF9 units are daisy-chained for interlock purposes: Unit 2's interlock output connects to Unit 1's external interlock input. The Interface Chassis provides one enable signal that enters this daisy chain. The LLRF9 interlock input is opto-isolated; the interlock output is not. Signal levels (ref: LLRF9 manual p. 14, and `llrf/architecture/llrfInterfaceChassis.docx`):

- **Input** (to LLRF9): Opto-isolated, selectable for 3.3V or 5V logic. A signal >=3.2 VDC supplying >=8 mA guarantees an enable. The Interface Chassis optocoupler output drives this directly.
- **Output** (from LLRF9): 5 VDC from transistor, can supply up to 60 mA. Logical OR of 18 signals (17 internal interlocks + 1 external permit). Pulled low on any fault. Dimtel uses Broadcom ACSL-6300-50TE optocoupler internally; a CDBU00340-HF protection diode is present on the output.

When the Interface Chassis removes the LLRF9 Enable, the LLRF9 disables its DAC output, opens its RF switch to the drive amplifier, and its status output goes low. The Interface Chassis reads this low status as confirmation of LLRF9 shutdown.

#### 8.3.2 HVPS Fiber-Optic Signals

Three fiber-optic signals connect the Interface Chassis to the HVPS controller (ref: `hvps/architecture/designNotes/controllerFiberOpticConnections.docx`, `llrf/documentation/fiberOpticCableSignalControlRev3.docx`):

**1. SCR ENABLE (Interface Chassis -> HVPS)**

This signal provides a hardware permit for the phase control thyristors. When the fiber is illuminated, the optical receiver in the HVPS Right Side Trigger Interconnect Board (SD-730-793-07-C2) pulls input U9B-2 to logic low, removing its inhibit from the thyristor triggers. When the fiber goes dark, U9B-2 is pulled high and triggers for phases A and C are inhibited on both the right side and (through the FO SCR ENABLE line on the COMMANDS bus) the left side interconnect boards. The B+/B- phase triggers remain enabled on both boards so that the filter inductor current can discharge safely.

This signal should be disabled whenever any permit input to the Interface Chassis is lost. It is the primary mechanism by which the LLRF system protects the klystron: when the LLRF detects a fault and disables RF drive, the klystron collector must not absorb the full HVPS DC beam power (SLAC B-factory klystrons are not full-collector designs). The Interface Chassis must remove SCR ENABLE promptly to prevent collector damage.

**2. KLYSTRON CROWBAR (Interface Chassis -> HVPS)**

This signal controls the HVPS output crowbar circuit. The **normal operating condition is fiber illuminated** (crowbar NOT fired). Removing the optical signal causes the receiver on the Left Side Trigger Interconnect Board (SD-730-793-08-C1) to trigger monostable U3B, which initiates firing of the crowbar thyristor stacks to discharge the HVPS output filter capacitors. The crowbar firing also disables the left side thyristor triggers and sets the SLAVE CROWBAR OFF signal on the COMMANDS bus, which in turn disables the right side triggers.

**There are currently no designs to actively control this signal from the Interface Chassis.** The signal must simply be kept illuminated to allow the HVPS to operate. The HVPS retains its own independent hardware crowbar triggers for transformer arcs (via the Stangenes ground fault current transformer) and klystron arcs (via the Pearson CT-110 current transformer in the termination tank). These hardware triggers fire the crowbar directly within the HVPS controller regardless of the fiber-optic state.

Engineering rationale for not requiring external crowbar control: SLAC-PUB-7591 (Cassel & Nguyen, 1997) demonstrates that even without the crowbar firing, passive circuit elements (2 x 0.5 ohm resistors per output capacitor, series inductors in the termination tank) limit the energy delivered to the klystron during an arc to below the threshold for catastrophic damage. The crowbar reduces this energy by an additional factor of approximately four.

**3. STATUS (HVPS -> Interface Chassis)**

This signal provides a basic health indication from the HVPS controller. The Left Side Trigger Interconnect Board illuminates the STATUS fiber when two conditions are met:
1. The PLC 24V Fault/Enable signal (Slot-5 OUT 0, labeled "Control System Enable" in PLC code) is at logic high
2. No condition has caused the crowbar circuit to fire (no klystron arc trigger, no transformer arc trigger, no PLC force crowbar command, no loss of KLYSTRON CROWBAR fiber)

**This signal does NOT indicate**:
- That the Enerpro FCOG6100 firing circuit has been enabled
- That the thyristor triggers are actually firing
- That the HVPS output is at the desired voltage
- That the HVPS is regulating properly

It is a necessary-but-not-sufficient indicator of HVPS readiness. The Interface Chassis uses this signal as one input to the permit logic. If STATUS is lost, the Interface Chassis removes permits to the LLRF9 and the SCR ENABLE.

> **Fiber-optic component note**: The source document `llrfInterfaceChassis.docx` states "The drivers will be HFBR-2412 and the receiver will be HFBR-1412." This appears to contain a transposition error in the part numbers. Per Broadcom convention and datasheets, **HFBR-1412 is a fiber-optic transmitter** and **HFBR-2412 is a fiber-optic receiver**. The Interface Chassis therefore uses HFBR-1412 (transmitter) for its two output signals (SCR ENABLE, CROWBAR) and HFBR-2412 (receiver) for the STATUS input. These are the same component family (820 nm, ST/SMA port) used in the legacy Local Panel (which used HFBR-1414 transmitters and HFBR-2416 receivers, the SMA-port variants of the same series).

### 8.4 Permit Logic

The permit logic is implemented in combinational digital hardware with no software or processor involvement:

```
All_Permits_OK = LLRF9_Status AND HVPS_STATUS AND MPS_RF_Summary AND 
                 MPS_Heartbeat AND SPEAR_MPS AND Orbit_Interlock AND 
                 Arc_Detection AND Power_Monitoring AND
                 Expansion_1 AND Expansion_2 AND Expansion_3 AND Expansion_4

LLRF9_Enable    = All_Permits_OK
HVPS_SCR_ENABLE = All_Permits_OK
HVPS_CROWBAR    = 1  (always illuminated; no active control mechanism in current design)
```

When any single permit input transitions to a fault state:
1. The corresponding input **latches** in the faulted state
2. The **first-fault register** captures which input faulted first (if multiple faults cascade)
3. All output permits are **simultaneously removed**
4. All latched states and the first-fault register are **held** until the MPS issues an external reset signal

The expansion port inputs are included in the permit logic. When not connected, these inputs must be terminated or driven to a safe (permit-asserted) state to avoid false trips.

### 8.5 Critical Design Consideration — LLRF9/HVPS Feedback Loop

The Interface Chassis creates a bidirectional coupling between LLRF9 and HVPS that requires careful engineering for fault recovery (ref: `llrf/architecture/llrfInterfaceChassis.docx`):

**Fault scenario**:
1. LLRF9 detects an RF fault -> disables DAC output and RF switch -> LLRF9 status output goes low
2. Interface Chassis receives low LLRF9 status -> removes HVPS SCR ENABLE (fiber goes dark)
3. HVPS thyristor triggers are inhibited -> HVPS output ramps down
4. HVPS PLC may remove 24V enable -> HVPS STATUS fiber goes dark
5. Interface Chassis sees HVPS STATUS lost -> latches HVPS_STATUS fault

**Recovery problem**: Even after the original LLRF9 fault is cleared, the LLRF9 status output remains low because the Interface Chassis has removed the LLRF9 Enable (which is one of the 18 signals ORed into the LLRF9 status output). The system cannot self-recover without explicit sequencing.

**Required sequencing logic** (from source document): "We need to design our logic circuit such that we can restore power to the system. We need to engineer the system such that once we have ensured that the HVPS is off we can return the enable to the LLRF9."

The specific recovery sequence must:
1. Confirm that the HVPS is off (SCR ENABLE removed, output voltage decayed)
2. Coordinate with the HVPS controller to confirm STATUS correctly reflects the disabled state
3. Re-assert the LLRF9 Enable so the LLRF9 can return to a ready state
4. Await MPS reset to clear all latched faults
5. Re-assert HVPS SCR ENABLE only when all permits are satisfied

This sequencing logic did not exist in the legacy system (the Local Panel and VXI modules operated independently without feedback coupling). The detailed design of this recovery sequencer is a key open item for the Interface Chassis PCB design.

### 8.6 Interface Chassis Connections Summary

The source document (`llrfInterfaceChassis.docx`) provides the following signal summary:

**Inputs**:
- LLRF Status (electrical, 5 VDC)
- HVPS STATUS (fiber-optic)
- MPS summary permit (electrical)
- MPS heartbeat (electrical)
- MPS external reset signal (electrical)
- Power signal permit (electrical)
- SPEAR MPS permit (electrical, 24 VDC)
- Orbit interlock permit (electrical, 24 VDC)
- Waveguide arc interlock permits (dry contacts)
- Expansion ports (2 x TTL, 2 x 24 VDC)

**Outputs**:
- LLRF Enable (electrical, >=3.2 VDC)
- HVPS SCR ENABLE (fiber-optic)
- HVPS KLYSTRON CROWBAR (fiber-optic, always illuminated)
- Digital statuses of all inputs (to MPS)
- Digital statuses of all outputs (to MPS)
- Digital statuses of first-fault trips (to MPS)

### 8.7 Physical Implementation

The Interface Chassis is custom hardware requiring PCB design. Key requirements from the source document:

- **Board layout**: Isolated areas for external signal I/O with optocouplers bridging to internal chassis ground. All input and output electrical signal returns must be electrically isolated from the chassis digital ground.
- **Voltage levels**: Mixed input voltages (3.2V, 5V, 24V) converted to a common internal digital family through optocoupler interface circuits. Driver chips may be required for output interfaces, particularly fiber-optic transmitters.
- **Fiber-optic transceivers**: HFBR-1412 (TX) for SCR ENABLE and CROWBAR outputs; HFBR-2412 (RX) for STATUS input. Mounting location TBD.
- **First-fault detection**: Digital latching logic with sufficient timing margin to distinguish the initiating fault from cascade events. All standard electronic components; no FPGA or microcontroller required.
- **MPS interface**: Multi-conductor cable carrying all digital status lines from the Interface Chassis to the MPS through system cross-connects. The number of free digital I/O lines on the ControlLogix MPS will determine whether fault status encoding is needed to minimize cabling.
- **Connectors**: Design-appropriate connectors for each interface type (BNC for expansion/TTL, multi-pin for MPS digital, fiber-optic ST or SMA for HVPS signals, appropriate connector for LLRF9 LEMO-style interlock signals).
- **Location**: TBD — inside Hoffman Box, separate enclosure, or rack-mounted in B132.

### 8.8 Design Status and Open Items

The Interface Chassis design is documented at the architectural level. The following items require resolution during detailed engineering design:

| Item | Status | Notes |
|---|---|---|
| Permit logic design | Architecture defined | Combinational logic; detailed schematic TBD |
| First-fault register design | Architecture defined | Timing analysis and gate-level design TBD |
| LLRF9/HVPS recovery sequencer | Requirement identified | Detailed sequencing logic TBD (see [Section 8.5](#85-critical-design-consideration--llrf9hvps-feedback-loop)) |
| Optocoupler selection (ACSL-6xx0 vs. HCPL-2400-000E) | Under evaluation | Both families meet requirements; final selection during PCB design |
| Chassis physical location | TBD | Depends on cable routing, thermal, and access constraints |
| MPS digital I/O channel count | TBD | Determines whether fault encoding is needed |
| PPS integration (K4, Ross switch) | Upgrade concept only | Requires formal PPS regulatory approval; see [Section 9](#9-subsystem-5-personnel-protection-system-pps-interface) |
| Expansion port termination scheme | Architecture defined | BNC with external 50 ohm terminator recommended |
| Arc detector interface details | Concept defined | Depends on MicroStep-MIS procurement and ControlLogix integration |
| Waveform Buffer comparator thresholds | TBD | Set during system commissioning based on actual RF power levels |


---

## 9. Subsystem 5: Personnel Protection System (PPS) Interface

> **Detailed reference**: `pps/`

### 9.1 PPS Overview

The PPS is the radiation and electrical safety interlock system managed by SLAC's radiation protection group. It controls two points in the HVPS power chain:

- **Chain 1**: Vacuum contactor (removes 12.47 kV input power to HVPS)
- **Chain 2**: Ross grounding switch (shorts the HVPS output to ground)

The PPS interface uses a GOB12-88PNE (Burndy/Souriau Trim Trio) 8-pin circular connector mounted in a locked box on the Hoffman enclosure.

### 9.2 Legacy PPS Design (Problems)

In the legacy system, PPS signals are routed through the Hoffman Box:

1. **PPS wiring exposure** — PPS wires terminate on terminal strips (TS-5, TS-6) inside the HVPS controller, co-located with non-PPS wiring
2. **PLC in safety chain** — The Ross grounding switch is controlled by the SLC-500 PLC (Slot-2 IO8 OUT3, 120 VAC). If the PLC fails in a stuck-on state, the Ross switch coil stays energized (unsafe)
3. **K4 relay via PLC** — Although the K4 relay coil uses PPS 1 voltage for its power rail (providing a hardware fail-safe), the enable path runs through PLC OX8 OUT2

### 9.3 Upgraded PPS Design

The upgraded design removes the PLC from the PPS safety chain entirely:

- **Chain 1 (Contactor)**: PPS Enable 1 → Interface Chassis (optocoupler isolated) → K4 relay direct drive → MX → L1 holding coil. S5 NC auxiliary contact readback via Interface Chassis to PPS.
- **Chain 2 (Ross Switch)**: PPS Enable 2 → Interface Chassis (optocoupler isolated) → Ross switch direct drive. Ross NC auxiliary contact readback via Interface Chassis to PPS.

**Key improvements**:
- No PLC dependency for safety functions
- Electrical isolation of all PPS signals through optocouplers
- PPS wiring isolated from non-PPS equipment
- Hardware fail-safe: Interface Chassis power loss → all outputs de-energize → K4, Ross, LLRF9, HVPS SCR all safe

### 9.4 PPS Regulatory Considerations

Any modification to PPS wiring, control logic, or readback paths requires:
- Review and approval by SLAC AD Safety Division 
- Formal change control documentation
- Radiation safety verification testing
- Possibly a radiation safety work control form

This adds significant administrative scope beyond the engineering work and requires early engagement with the PPS/protection group (initiated by Jim Sebek's 2022 email to Matt Cyterski and Tracy Yott).


---

## 10. Subsystem 6: Tuner Control System

### 10.1 Physical Mechanism

Each of the 4 RF cavities has a mechanical tuner that adjusts the cavity resonant frequency by moving a plunger into or out of the cavity volume. The tuner is driven by a stepper motor (Superior Electric M093-FC11 or equivalent) through a gear reduction mechanism.

**Tuner parameters** (from legacy documentation):
- Gear ratio: 80:1 (worm gear)
- Lead screw pitch: 10 turns/inch
- Microstep resolution: 0.002–0.003 mm per microstep (legacy)
- Linear potentiometer: Provides absolute position indication (not used in closed-loop control)
- Travel range: ~12 mm total mechanical range
- ON home positions: ~10.1–10.7 mm (cavity-dependent)
- Park positions: retracted position for safe storage

### 10.2 Legacy Controller

- **Motor controller**: Allen-Bradley 1746-HSTP1 (high-speed stepper module, OBSOLETE)
- **Motor driver**: Superior Electric SS2000MD4-M Slo-Syn PWM driver (OBSOLETE)
- **Control software**: SNL `rf_tuner_loop.st`  — phase-based feedback with home reset, motion monitoring, and load angle offset computation
- **Phase source**: Legacy analog RFP module

### 10.3 Upgraded Controller

The tuner motor controller is being replaced with a modern motion controller. The leading candidate is the **Galil DMC-4143** (4-axis), which is supported by the LLRF9's built-in tuner control features and EPICS motor records. Other candidates under investigation include the Domenico/Dunning design and Danh's design.

**Upgraded tuner control loop**:
1. LLRF9 measures cavity probe phase relative to station reference (10 Hz, sub-degree resolution)
2. Python coordinator processes phase data and computes motor commands
3. Motor commands sent via EPICS motor records to motion controller
4. Motion controller drives stepper motors

**LLRF9 tuner support**: The LLRF9 includes built-in tuner control PVs (per cavity):
- `LLRF:TUNER:Cn:GAIN_P` — proportional gain
- `LLRF:TUNER:Cn:GAIN_I` — integral gain
- `LLRF:TUNER:Cn:OFFSET` — detuning phase offset
- `LLRF:TUNER:Cn:CLOSE` — loop state (open/closed)
- `LLRF:TUNER:Cn:MINFWD` — minimum forward power threshold

### 10.4 Load Angle Offset Loop

The load angle offset loop is a supervisory function that balances gap voltage across all 4 cavities by adjusting the individual tuner phase setpoints. In the legacy system this was embedded in `rf_tuner_loop.st`; in the upgrade it becomes a separate Python module (`load_angle_controller.py`) that:
1. Reads all 4 cavity probe amplitudes from LLRF9
2. Computes amplitude imbalance
3. Adjusts individual tuner phase offset PVs to redistribute power

### 10.5 Tuner Interfaces

- **LLRF9 Unit 1**: Provides 10 Hz phase measurements for all 4 cavities (BRD1: Cav 1,2; BRD2: Cav 3,4)
- **Motion Controller**: EPICS motor records via Ethernet
- **Stepper Motors**: Power and encoder cables to tunnel (existing field cabling)
- **Python Coordinator**: Tuner manager module processes phase data, commands motor moves, manages load angle

### 10.6 Risk Note

The tuner motor controller is identified as the hardest-to-prove subsystem. Previous attempts with candidate controllers have had reliability issues. The mitigation plan is to test the chosen controller on the SPEAR3 booster tuners first before committing to storage ring installation.

---

## 11. Subsystem 7: Waveform Buffer System

> **Detailed reference**: `llrf/architecture/WaveformBuffersforLLRFUpgrade.docx`

### 11.1 Purpose

The Waveform Buffer System is a new signal conditioning and monitoring chassis that extends the LLRF9's RF monitoring capabilities and adds dedicated HVPS signal monitoring. It serves three functions:

1. **Extended RF signal monitoring** — 8 RF channels with circular waveform buffers for pre-fault capture; monitors the 6 RF signals not assigned to the two LLRF9 units
2. **HVPS signal monitoring** — 4 channels (voltage, current, 2 inductor voltages) with circular buffers
3. **Enhanced klystron collector power protection** — computes DC power minus RF power (vs. legacy forward power proxy) and triggers a hardware trip if collector power exceeds the limit

### 11.2 Channel Configuration

**RF Channels (8)**:

The two LLRF9 units together cover 18 of the 24 monitored RF signals (see [Section 5.3](#53-two-unit-configuration-for-spear3)). The 6 remaining signals are routed to the Waveform Buffer RF inputs:

| Channel | Signal # | Signal | Purpose |
|---------|----------|---------|---------|
| 1 | 3 | Circulator Load Forward Power | Monitors power dissipated in circulator load; cross-check of circulator isolation |
| 2 | 4 | Circulator Load Reflected Power | Indicates circulator load match quality |
| 3 | 6 | Station Reference Power | Monitors 476 MHz reference level; loss of reference triggers fault |
| 4 | 8 | Waveguide Load 1 Reflected Power | Monitors WG Load 1 match quality |
| 5 | 16 | Waveguide Load 2 Reflected Power | Monitors WG Load 2 match quality |
| 6 | 24 | Waveguide Load 3 Reflected Power | Monitors WG Load 3 match quality |
| 7–8 | — | (Spare) | Reserved for future use |

**HVPS Channels (4)**:

| Channel | Signal | Conditioning | Purpose |
|---------|--------|--------------|---------|
| 1 | HVPS Voltage | Voltage divider | Regulation monitoring |
| 2 | HVPS Current | Current transformer | Load monitoring |
| 3 | Inductor 1 Voltage | Voltage divider | Firing circuit health |
| 4 | Inductor 2 Voltage | Voltage divider | Firing circuit health |

### 11.3 Key Features

- **Circular buffers**: Continuous acquisition at kHz rate; freeze on fault trigger for pre/post-fault capture (~100 ms pre-fault data)
- **Analog comparator trips**: Hardware-based threshold detection on each channel; comparator outputs feed Interface Chassis
- **Enhanced collector power protection algorithm** (improvement over legacy forward power proxy):
  ```
  DC_Power = HVPS_Voltage × HVPS_Current
  RF_Power = Klystron_Forward_Power
  Collector_Power = DC_Power - RF_Power
  IF Collector_Power > Collector_Limit THEN Trip
  ```
  This provides direct collector power calculation vs. the legacy system's forward power proxy method.
- **EPICS interface**: Waveform readout, threshold configuration, trip status

### 11.4 Interfaces

- **RF signal inputs**: RF detectors on cavity forward/reflected couplers (signal conditioned)
- **HVPS signal inputs**: Voltage dividers and current transformers from HVPS
- **Interface Chassis**: Comparator trip outputs (digital) feed into Interface Chassis permit logic
- **Python Coordinator** (EPICS): Waveform readout, configuration, collector power trend monitoring


---

## 12. Subsystem 8: Arc Detection System

### 12.1 Purpose

The arc detection system is a new subsystem that provides optical monitoring of the RF cavity windows and klystron for electrical arcing. The legacy system had a non-functional arc detection capability that is being replaced entirely.

### 12.2 Technology

**Microstep-MIS Waveguide Arc Detectors**: Optical sensors that detect the light flash produced by an electrical arc inside a waveguide or cavity viewport. These are commercial off-the-shelf devices providing:
- Optical fiber sensors mounted at cavity window viewports and klystron window
- Controller unit with dry-contact relay outputs
- Response time on the order of microseconds
- Configurable sensitivity thresholds

### 12.3 Installation

- Sensors mounted on cavity window viewports (4 cavities) and klystron window
- Mechanical mounting requires custom adapters for the existing CF flange viewports (see `llrf/arcDetector/Mechanical/Reference/` for viewport specifications)
- Sensor fiber runs to controller unit located in B118 equipment area

### 12.4 Interfaces

- **Interface Chassis**: Dry-contact relay outputs from arc detector controller → Interface Chassis optocoupler inputs → permit logic
- **MPS PLC**: Arc detection status reported via Interface Chassis fault status to MPS

---

## 13. Subsystem 9: Klystron Cathode Heater

> **Detailed reference**: `Designs/5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md`

### 13.1 Legacy System

The current klystron heater control system is inherited from the PEP-II era and consists of a motor-driven variac for voltage adjustment, feeding a Kepko 5V/20A power supply (PS-2).

**Current System Architecture**:
- **Input Power**: 120VAC, Phase C (from Hoffman box wiring)
- **Control Method**: Motor-driven variac for voltage adjustment
- **Power Supply**: Kepko 5V/20A (PS-2) with transformer isolation for HV safety
- **Output**: 5V/20A maximum (~100W typical operation)
- **Control Interface**: Manual or slow automatic adjustment
- **EPICS Integration**: Limited monitoring capabilities

**System Limitations**:
- **Slow Response**: Motor-driven variac requires seconds to minutes for adjustment
- **Limited Precision**: Mechanical variac resolution ~1-2% of full scale
- **Aging Components**: 25+ year old system with increasing failure rates
- **Manual Operation**: Requires operator intervention for power adjustments
- **Poor EPICS Integration**: Limited monitoring and control capabilities
- **No Automated Sequences**: Manual warm-up and cool-down procedures
- **Minimal Diagnostics**: No real-time power, voltage, or current monitoring
- **Maintenance Issues**: Mechanical wear, obsolete parts, calibration drift

### 13.2 Upgraded System — SCR-Based Control

The upgrade replaces the variac/motor system with a solid-state SCR controller:

| Parameter | Legacy | Upgraded |
|-----------|--------|----------|
| Control method | Motor-driven variac | SCR zero-crossing switching |
| Response time | Seconds–minutes | <100 ms |
| Voltage regulation | ±0.3% | ±0.1% |
| Reliability | Mechanical wear | Solid-state (>50,000 hr MTBF) |
| EPICS integration | Limited | Full (automated sequences) |

**Upgraded system architecture**:
```
Python/EPICS Coordinator → SCR Controller → Low-Pass Filter (120–180 Hz)
→ Isolation Transformer → Klystron Cathode Heater (5V/20A)
```

**Key design features**:
- Zero-crossing SCR switching minimizes harmonic generation
- LC low-pass filter (fc ≈ 159 Hz) attenuates switching harmonics
- True RMS voltage/current monitoring (AD637 RMS-to-DC converters)
- Automated warm-up, standby, and cool-down sequences

### 13.3 Interfaces

- **Python Coordinator** (EPICS): Setpoint control, RMS readbacks, status, automated sequences
- **HVPS coordination**: Heater must be at operating temperature before HVPS enable; HVPS must be off before heater cooldown
- **MPS**: Heater "ready" status required for RF permit

---

## 14. Subsystem 10: Control Software

> **Detailed reference**: `llrf/epicsSequences/legacyLLRF, Docs_JS/LLRFOperation_jims.docx`

### 14.1 Legacy Software

The legacy control software consists of SNL (State Notation Language) programs running on VxWorks RTOS in the VXI crate processor:

| Program | Lines | Function |
|---------|-------|----------|
| `rf_states.st` | 2,227 | Master state machine (OFF/PARK/TUNE/ON_CW), turn-on, fault handling |
| `rf_dac_loop.st` | 290 | DAC control loop (gap voltage regulation) |
| `rf_hvps_loop.st` | 343 | HVPS control loop (drive power regulation) |
| `rf_tuner_loop.st` | 555 | Tuner control (×4 cavities, phase-based, load angle) |
| `rf_calib.st` | 2,800+ | Calibration (analog offset nulling, coefficient calibration, ~20 min) |
| `rf_msgs.st` | 352 | Message logging, HVPS faults, TAXI error detection |

### 14.2 Upgraded Software — Python/EPICS Coordinator

The upgrade replaces all SNL code with a Python/PyEPICS coordinator application that operates as a supervisory control layer at ~1 Hz. It is NOT in the fast safety path.

### 14.3 Key Design Principles

- **Separation of concerns**: Each module has a single responsibility
- **Hardware abstraction**: All hardware interfaces go through the EPICS layer
- **Configuration-driven**: All operational parameters in configuration files
- **Fault tolerance**: Graceful degradation when subsystems are unavailable
- **Diagnostics**: Structured event logging, LLRF9 + waveform buffer readout, system performance metrics, and logging
- **Testability**: Mock interfaces for all hardware dependencies
- **Safety delegation**: Hardware safety handled by Interface Chassis; Python handles sequencing and coordination only


---

## 15. Control Loop Architecture

This section maps the control loops in the system, identifying which hardware subsystem closes each loop, the loop bandwidth, and the upgrade path.

### 15.1 Fast RF Feedback (Direct Loop)

| Aspect | Legacy | Upgraded |
|--------|--------|----------|
| Implementation | Analog I/Q in RFP module | LLRF9 FPGA: digital proportional + integral |
| Loop delay | ~kHz bandwidth | 270 ns |
| Controlled variable | Cavity field amplitude and phase | Same (vector sum of Cav 1+2 on BRD1) |
| Actuator | DAC driving klystron input | LLRF9 DAC → drive amplifier → klystron |
| Safety | Analog limits | LLRF9 RF interlocks (overvoltage, 9 per board) + baseband window comparators (8 per unit) |

This is the fastest loop in the system and is entirely closed inside the LLRF9 FPGA. The Python coordinator does NOT participate.

### 15.2 HVPS Supervisory Loop (~1 Hz)

| Aspect | Legacy | Upgraded |
|--------|--------|----------|
| Implementation | SNL `rf_hvps_loop.st` on VxWorks | Python `hvps_controller.py` + CompactLogix PLC |
| Bandwidth | ~1 Hz | ~1 Hz |
| Measurement | Drive power from analog module | Klystron forward power from LLRF9 Unit 1, BRD3 |
| Setpoint | HVPS voltage via field bus | HVPS voltage via EPICS to CompactLogix PLC |
| Purpose | Maintain drive power within target range by adjusting klystron voltage | Same |

The PLC handles low-level voltage regulation; the Python coordinator provides supervisory setpoint management.

### 15.3 Tuner Control Loops (×4, ~1 Hz)

| Aspect | Legacy | Upgraded |
|--------|--------|----------|
| Implementation | SNL `rf_tuner_loop.st` | LLRF9 phase data + Python `tuner_manager.py` + motor controller |
| Measurement | Cavity probe phase from analog module | Cavity probe phase from LLRF9 (10 Hz, sub-degree) |
| Actuator | HSTP1 stepper module + Slo-Syn driver | Modern motion controller + stepper driver |
| Phase setpoint | Fixed per cavity + load angle offset | LLRF9 tuner PVs (OFFSET, GAIN_P, GAIN_I) |

### 15.4 Load Angle Offset Loop (~1 Hz)

| Aspect | Legacy | Upgraded |
|--------|--------|----------|
| Implementation | Part of `rf_tuner_loop.st` | Python `load_angle_controller.py` |
| Measurement | 4 cavity probe amplitudes | 4 cavity probe amplitudes from LLRF9 |
| Actuator | Adjusts individual tuner phase setpoints | Adjusts LLRF9 tuner offset PVs |
| Purpose | Balance gap voltage across 4 cavities | Same |

### 15.5 Station State Machine

| Aspect | Legacy | Upgraded |
|--------|--------|----------|
| Implementation | SNL `rf_states.st` (2,227 lines) | Python `state_machine.py` |
| States | OFF, STANDBY, PARK, TUNE, ON_CW, ON_FM (unused), FAULT | OFF, PARK, TUNE, ON_CW, FAULT |
| Turn-on sequence | Multi-step with manual fast-on values | LLRF9 setpoint profiles (512 pts, 70 μs–37 ms/step) |
| Safety | Software-based fault handling | Hardware safety delegated to Interface Chassis; software handles sequencing |

### 15.6 Calibration

| Aspect | Legacy | Upgraded |
|--------|--------|----------|
| Implementation | SNL `rf_calib.st` (2,800+ lines, ~20 min) | Python `rf_calib.py` + LLRF9 built-in digital calibration |
| Scope | Analog offset nulling, coefficient calibration for RFP module | Factory + installation calibration stored in EEPROM |
| Duration | ~20 minutes | Minutes (digital, no analog drift) |

### 15.7 Eliminated Loops

The following legacy loops are eliminated in the upgrade because the LLRF9's digital feedback inherently provides their function:
- **Ripple rejection loop** — LLRF9 digital feedback inherently rejects power-line ripple
- **Comb filter loop (CFM)** — Multi-bunch stabilization handled by LLRF9 FPGA
- **Gap voltage feedback (GVF)** — Cavity field stabilization handled by LLRF9 vector sum feedback
- **4-way branching (DAC loop)** — Eliminated; LLRF9 controls all via single vector sum


---

## 16. Inter-Subsystem Interface Matrix

This matrix summarizes all physical and logical interfaces between subsystems in the upgraded system.

| From \ To | LLRF9 #1 | LLRF9 #2 | HVPS PLC | MPS PLC | Interface Chassis | Waveform Buffer | Arc Detect | Motor Ctrl | Heater Ctrl | Python Coord |
|-----------|----------|----------|----------|---------|-------------------|-----------------|------------|------------|-------------|--------------|
| **LLRF9 #1** | — | Interlock daisy (LEMO) | — | — | Status (5V digital) | — | — | — | — | EPICS (Ethernet) |
| **LLRF9 #2** | Interlock daisy (LEMO) | — | — | — | Status (5V digital) | — | — | — | — | EPICS (Ethernet) |
| **HVPS PLC** | — | — | — | — | STATUS (fiber), SCR EN (fiber), CROWBAR (fiber) | — | — | — | — | EPICS (Ethernet) |
| **MPS PLC** | — | — | — | — | Summary, Heartbeat, Reset (digital) | — | — | — | — | EPICS (Ethernet) |
| **Interface Chassis** | Enable (3.2V) | Enable (3.2V) | SCR EN, CROWBAR (fiber) | Fault status (digital) | — | — | — | — | — | — |
| **Waveform Buffer** | — | — | — | — | Comparator trips (digital) | — | — | — | — | EPICS (Ethernet) |
| **Arc Detect** | — | — | — | — | Relay contacts (dry) | — | — | — | — | — |
| **Motor Ctrl** | — | — | — | — | — | — | — | — | — | EPICS (Ethernet) |
| **Heater Ctrl** | — | — | — | — | — | — | — | — | — | EPICS (Ethernet) |
| **Python Coord** | EPICS (Ethernet) | EPICS (Ethernet) | EPICS (Ethernet) | EPICS (Ethernet) | Monitoring only | EPICS (Ethernet) | — | EPICS (Ethernet) | EPICS (Ethernet) | — |
| **PPS** | — | — | — | — | PPS Enable 1&2, Readback A-B/C-D | — | — | — | — | — |
| **External (SPEAR MPS, Orbit)** | — | — | — | — | 24V permits | — | — | — | — | — |

### Interface Signal Types Summary

| Signal Type | Examples | Medium | Speed |
|-------------|----------|--------|-------|
| **EPICS Channel Access** | PV reads/writes, setpoints, readbacks | Ethernet (TCP/UDP) | ~1–10 Hz |
| **Hardware interlock (digital)** | LLRF9 status, MPS summary, comparator trips | Optocoupled wire | <1 μs |
| **Fiber-optic interlock** | HVPS SCR ENABLE, CROWBAR, STATUS | HFBR fiber | <1 μs |
| **RF signals** | Cavity probes, forward, reflected | 50 Ω coax (SMA) | 476 MHz analog |
| **Motor control** | Step/direction pulses, encoder signals | Shielded cable | kHz pulse |
| **Interlock daisy-chain** | LLRF9 Unit 1 ↔ Unit 2 | LEMO coax | <1 μs |
| **PPS signals** | Enable 1&2, readback A-B/C-D | GOB12-88PNE connector + wire | DC / relay |
| **Dry contacts** | Arc detection relay outputs | Wire | DC / relay |

---

## 17. Protection Chain and Interlock Architecture

### 17.1 Protection Philosophy

The upgraded system implements a layered protection architecture:

1. **Layer 1 — LLRF9 FPGA interlocks** (<1 μs): RF overvoltage, baseband window comparators, internal housekeeping. These are the fastest protection and act within the LLRF9 itself to disable the DAC output.

2. **Layer 2 — Interface Chassis hardware** (<1 μs from input change): Aggregates all permit signals and coordinates system-wide protection. All signals are optocoupler-isolated or fiber-optic. First-fault detection identifies the initiating event.

3. **Layer 3 — MPS PLC** (~ms): Aggregates RF interlock status with external safety systems (SPEAR MPS, orbit interlock). Provides reset signal to Interface Chassis.

4. **Layer 4 — Python Coordinator** (~1 s): Supervisory monitoring, logging, fault analysis, and recovery sequencing. NOT in the fast safety path.

### 17.2 Fault Propagation Example — RF Arc Event

```
1. Arc occurs in cavity window
   ↓ (light flash, μs)
2. Microstep-MIS detector closes relay contact
   ↓ (<1 μs)
3. Interface Chassis receives arc signal → latches fault → removes all permits:
   - LLRF9 Enable removed → LLRF9 disables DAC output → no RF drive
   - HVPS SCR ENABLE removed → thyristors stop firing → HV ramps down
   - First-fault register captures "Arc Detection" as initiating event
   ↓ (~μs)
4. LLRF9 detects interlock trip → captures 16k-sample waveforms
   Waveform Buffer freezes circular buffers (pre-fault data preserved)
   ↓ (~ms)
5. MPS PLC receives fault status from Interface Chassis → logs event
   ↓ (~s)
6. Python coordinator detects fault → logs structured event → enters FAULT state
   Operator notified; waveform data available for analysis
   ↓ (manual or auto)
7. MPS issues reset → Interface Chassis clears latches → system ready for restart
```

### 17.3 Fail-Safe Design

All critical subsystems are designed to fail safe:

| Subsystem | Failure Mode | Safe State |
|-----------|-------------|------------|
| Interface Chassis power loss | All outputs de-energize | LLRF9 disabled, HVPS SCR disabled, K4/Ross de-energized |
| LLRF9 power loss | Interlock status goes low | Interface Chassis removes permits |
| HVPS PLC failure | STATUS signal lost | Interface Chassis removes permits |
| MPS PLC failure | Heartbeat lost | Interface Chassis removes permits |
| Python coordinator crash | No effect on safety | Hardware protection continues; supervisory control paused |
| Ethernet failure | No effect on safety | Hardware protection continues; supervisory control paused |


---

## 18. Communication Architecture

### 18.1 EPICS Channel Access Network

All supervisory communication in the upgraded system uses EPICS Channel Access over Ethernet:

| Device | IP Address | IOC Type | Key PV Prefix | Update Rate |
|--------|-----------|----------|---------------|-------------|
| LLRF9 Unit 1 | TBD | Built-in Linux IOC | `LLRF1:` | 10 Hz (scalars) |
| LLRF9 Unit 2 | TBD | Built-in Linux IOC | `LLRF2:` | 10 Hz (scalars) |
| HVPS CompactLogix | TBD | External EPICS gateway | `SRF1:HVPS:` | ~1 Hz |
| MPS ControlLogix | TBD | External EPICS gateway | `SRF1:MPS:` | ~1 Hz |
| Motion Controller | TBD | EPICS motor record IOC | `SRF1:MTR:` | On demand |
| Waveform Buffer | TBD | Dedicated IOC | `SRF1:WFBUF:` | ~1 Hz / event |
| Heater Controller | TBD | Dedicated IOC | `SRF1:HTR:` | 10 Hz |
| Python Coordinator | TBD | caproto / PyEPICS client | Various | ~1 Hz |

### 18.2 Network Configuration

- **EPICS CA max array size**: 26 MB (`EPICS_CA_MAX_ARRAY_BYTES=26000000`) — required for LLRF9 waveform data
- **Default CA ports**: 5064 (search), 5065 (connection)
- **IOC discovery**: CA address list maintained in configuration file
- **Best practice**: Use CA monitors (subscriptions) rather than polling for frequently-read PVs

### 18.3 Non-EPICS Communication Paths

| Path | Type | Purpose |
|------|------|---------|
| Interface Chassis ↔ all hardware | Hardwired digital/fiber | Safety interlocks (no network dependency) |
| LLRF9 Unit 1 ↔ Unit 2 | LEMO interlock daisy-chain | Fast interlock propagation |
| PPS ↔ Interface Chassis | Hardwired (GOB12-88PNE) | Personnel safety (no network dependency) |
| Arc Detection → Interface Chassis | Dry contact relay | Arc interlock (no network dependency) |

**Critical design principle**: All safety-critical communication paths are hardwired. No safety function depends on the Ethernet network or EPICS Channel Access. Network loss pauses supervisory control but does not compromise protection.

---

## 19. Implementation Phases and Risk Summary

### 19.1 Implementation Phases

> **Critical Constraint**: The SPEAR3 LLRF upgrade has extremely limited flexibility for integration testing since bringing systems online directly impacts SPEAR operations. This severely constrains the available testing window and requires a fundamentally different approach than typical development projects.

**Key Implications**:
- Maximum standalone subsystem testing must occur before installation
- Integration testing must be incremental and carefully planned
- Some subsystems can be brought online for limited testing without full operational impact
- Full system integration testing window is minimal

#### Phase 1: Maximum Standalone Development

- **Software Framework**: Develop with simulated interfaces where live hardware unavailable
- **Tuner Testing**: Test Galil controller with Booster RF cavity
- **LLRF9 Installation**: Install both units, connect RF signals, and bring them online
- **MPS Online**: Bring MPS online for EPICS interface development
- **HVPS PLC Online**: Enables EPICS software development
- **Waveform Buffer Assembly**: Complete assembly and standalone testing
- **Interface Chassis Design/Fab**: Complete design and fabrication
- **HVPS Controller**: Design, fabrication, and installation
- **Arc Detector**: Design and fabrication
- **Test Stand 18**: Upgrade to work with the upgraded HVPS controller

#### Phase 2: Incremental Subsystem Integration

- **Tuner Test with SPEAR Cavity**
- **HVPS Integration**: Integrate HVPS PLC with Python/EPICS (test at test stand T18)
- **MPS Integration**: Integrate MPS with LLRF9, waveform buffer, arc detector, HVPS PLC, interface chassis, and software coordinator with existing RF signals

#### Phase 3: Critical Path Integration

- **LLRF9 Integration — Basic RF Processing**: Verify vector sum, feedback loops, online calibration
- **EPICS Integration**: Configure IOC, verify all PV interfaces
- **End-to-End Interlock Testing**: Verify complete interlock chain (limited RF power)

#### Phase 4: Full Power Commissioning

- **Incremental Power Ramp**: Gradually increase power while monitoring all systems
- **Performance Validation**: Verify all success criteria are met
- **Operator Training**: Train operators on new system
- **Documentation**: Complete commissioning report


### 19.2 Procurement Status

| Item | Status | Cost Estimate |
|------|--------|---------------|
| LLRF9 (4 units) | Complete | — |
| MPS PLC modules | Complete | — |
| HVPS PLC modules | Complete (HVPS1, HVPS2, B44 Test Stand) | — |
| Enerpro FCOG1200 boards | Needed | ~$4k (5 boards) |
| Arc detection (Microstep-MIS) | Needed | ~$20k |
| Waveform Buffer System | Needed | RF detectors ~$1.7k + fabrication |
| Interface Chassis | Needed | Design + fabrication |
| Heater SCR controller | Needed | ~$17k |
| Remaining items | Various | <$50k total (operational budget) |

### 19.3 Key Technical Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Tuner motor controller reliability | High | Test on booster tuners first; evaluate multiple candidates |
| HVPS PLC code migration (SLC-500 → CompactLogix) | High | Reverse-engineer legacy code; build Test Stand 18 (B44) |
| PPS approval delays | High | Engage protection managers early; provide complete documentation |
| Interface Chassis logic design (LLRF9/HVPS feedback loop) | High | Design and simulate before fabrication; careful sequencing logic |
| Waveform Buffer System (new custom hardware) | Medium | Staged development: PCB design → assembly → testing → integration |
| Communication latency (Ethernet/EPICS for ~1 Hz control) | Low | Proven in LLRF9 prototype commissioning |

### 19.4 Success Criteria

| Metric | Legacy Performance | Target |
|--------|-------------------|--------|
| Amplitude stability | <0.1% | Same or better |
| Phase stability | <0.1 deg | Same or better |
| Tuner resolution | ~0.002–0.003 mm/microstep | Improved (up to 256 microsteps/step) |
| Control loop response | ~1 second | Same or better |
| Uptime | >99.5% | Same or better |
| Fault diagnostics | Limited fault file capture | 16k-sample waveform + circular buffer + first-fault |

---

## 20. Appendix: Source Document Index

### Repository Documentation

| Path | Type | Content |
|------|------|---------|
| `Designs/1_Overview of Current and Upgrade System.md` | Markdown | Full legacy/upgrade comparison, control loop mapping |
| `Designs/2_SPEAR3_LLRF_Upgrade_System_Design.docx` | Word | Detailed engineering design |
| `Designs/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` | Markdown | LLRF9 hardware, EPICS IOC, PV architecture, 550+ PVs |
| `Designs/4_HVPS_Engineering_Technical_Note.md` | Markdown | HVPS power section, controller, upgrade design |
| `Designs/5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md` | Markdown | SCR-based heater control system design |
| `Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` | Markdown | PPS interface, safety chain, Interface Chassis |
| `Designs/9_SOFTWARE_DESIGN.md` | Markdown | Python/EPICS coordinator architecture and API |

### LLRF Source Material

| Path | Content |
|------|---------|
| `llrf/legacyLLRF/rf_states.st` | Legacy master state machine (2,227 lines) |
| `llrf/legacyLLRF/rf_dac_loop.st` | Legacy DAC control loop (290 lines) |
| `llrf/legacyLLRF/rf_hvps_loop.st` | Legacy HVPS control loop (343 lines) |
| `llrf/legacyLLRF/rf_tuner_loop.st` | Legacy tuner control loop (555 lines) |
| `llrf/legacyLLRF/rf_calib.st` | Legacy calibration system (2,800+ lines) |
| `llrf/legacyLLRF/rf_msgs.st` | Legacy message logging (352 lines) |
| `llrf/architecture/llrfInterfaceChassis.docx` | Interface Chassis specification |
| `llrf/architecture/WaveformBuffersforLLRFUpgrade.docx` | Waveform Buffer System design |
| `llrf/architecture/arcDetectorHardwareOptions.docx` | Arc detection hardware selection |
| `llrf/documentation/LLRFOperation_jims.docx` | Jim's SPEAR3 RF Station Operation Guide |
| `llrf/documentation/LLRFUpgradeTaskListRev3.docx` | Full project scope, procurement, costs |
| `llrf/tuners/galil/` | Galil DMC-4143 firmware and test notes |
| `llrf/driveAmp/KAW2051M12*.pdf` | Drive amplifier datasheet |
| `llrf/arcDetector/` | Arc detector product sheets and mechanical references |

### HVPS Source Material

| Path | Content |
|------|---------|
| `hvps/architecture/originalDocuments/slac-pub-7591.pdf` | Original HVPS design publication |
| `hvps/architecture/originalDocuments/ps3413600102.pdf` | HVPS power section specifications |
| `hvps/controls/enerpro/` | Enerpro SCR gate driver documentation and schematics |
| `hvps/documentation/plc/` | SLC-500 PLC code, labels, and analysis |
| `hvps/documentation/schematics/` | HVPS electrical schematics |
| `hvps/documentation/wiringDiagrams/` | Wiring diagrams (Hoffman Box, HVPS) |
| `hvps/documentation/procedures/` | Maintenance and safety procedures |
| `hvps/maintenance/` | Stack installation checklists, phase tank maintenance |

### PPS Source Material

| Path | Content |
|------|---------|
| `pps/diagrams/00_SYSTEM_OVERVIEW.md` | PPS current vs. upgrade architecture overview |
| `pps/diagrams/01-08_*.md` | Detailed analysis of each PPS-related schematic |
| `pps/MSG from Jim Sebek to Faya about PPS.md` | 2022 PPS concerns and upgrade drivers |
| `pps/HoffmanBoxPPSWiring.docx` | Detailed PPS wiring analysis |
| `pps/*.pdf` | Original PPS schematics and wiring diagrams |

---

*End of Physical Design Report*

**Document Control**:
- **Created**: March 2026
- **Revision**: R0
- **Next Review**: Upon completion of Interface Chassis preliminary design
- **Distribution**: LLRF Upgrade Team, SPEAR3 Operations, Engineering Management, PPS/Protection Group
