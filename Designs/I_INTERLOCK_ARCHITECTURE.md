# SPEAR3 RF Station Legacy System Interlock Architecture

**Document ID**: Doc I
**Version**: 1.3  
**Date**: April 10, 2026  
**Status**: To be released  
**Location**: Designs/I_INTERLOCK_ARCHITECTURE.md  
**Author**: Faya Wang, with AI-assisted analysis  
**Tier**: 2 — Legacy System Interlock Architecture

---

## Revision History

| Rev | Date | Author | Changes |
|-----|------|--------|---------|
| 1.3 | 2026-04-10 | Faya Wang | R10: Added §6.9 documenting complete dual-PPS-chain interaction and roles — Chain 1 (HV vacuum contactor, fail-safe open) vs Chain 2 (Ross grounding switch, fail-safe closed/grounded), differential compliance exposure (Chain 1 has series PPS voltage fail-safe at OX8 relay input; Chain 2 does not), and safe-access operational sequence. R11: Resolved RF shutdown ambiguity for HVPS PLC trip scenario — added §9.6 explicitly tracing signal path from SLC-500 trip → SCR ENABLE removed (immediate, ~10–20 ms) → RF drive removed by SNL `s_go_off` Step 6 (~6 s after initial trip); no direct hardware RF kill path exists from HVPS PLC to RFP module; klystron is inert without cathode HV during the intervening gap. Updated §8.3 key feature (4) to cross-reference §9.6. R12: Added Part X (Fault Data Availability and Analysis): §10.1 data source overview table; §10.2 AIM hardware history buffer (HISBUF, `/dat/aimHist.dat`, ARCLTDSTT bit interpretation); §10.3 SNL `/dat/FAULT*_N` files (11 channel list, slot numbering, access); §10.4 B118 four-channel oscilloscope monitor (CH1 DC voltage, CH2 DC current, CH3 T2 sawtooth, CH4 T1 AC current) with comparison to `hvps_sim` Python package; §10.5 EPICS Channel Archiver (access procedure, key PVs); §10.6 step-by-step fault analysis procedure with fault categorization guide. |
| 1.2 | 2026-04-09 | Faya Wang | R6: Added TRIPLVL register download path (AIM VXI registers → Fast IC analog comparators). R7: Rewrote §3.8 to distinguish 12-ch AIM hardware history buffer (Fast IC fast ADC → 512 KB HISBUF ring buffer, gated by ADCMUX/ADCCTL) from SNL software fault file capture (ss rf_statesFF, 11 RF/IQA channels). R8: Rewrote §3.6 fiber outputs with correct destinations per signal (external supplies, SPEAR3 MPS, Fast IC hardware). R9: Documented HVPS STATUS fiber (B514 → Fast IC, informational, HVPSON in FISTAT) — NOT a Fast IC trip source. Updated §2.2 Fast IC inputs table, §6.2 SLC-500 inputs, and §8.3 HVPS trip example accordingly. |
| 1.1 | 2026-04-09 | Faya Wang | R1: Corrected AIM arc-detection role (Fast IC 340-308 is analog front-end; AIM 340-307 is VXI digital companion receiving arc status via direct hardware link). R2: Clarified MPS Shutoff module (Slot 5) role — redundant RF drive cut path; HVPS shutdown occurs via Fast IC Path A, not via Slot 5. R3: Documented RF MPS PLC as three-path actor (added Path C via VXI Slot 5). R4: Added inputs/outputs tables for AIM, RF MPS PLC, SLC-500 HVPS PLC, and SNL State Machine. R5: Added RF MPS PLC cooling-water temperature trip (§8.2) and HVPS transformer arc/crowbar trip (§8.3) examples. |
| 1.0 | 2026-04-09 | Faya Wang | Initial document — synthesized from complete codebase review |
---

## Table of Contents

#### Front Matter
- [Background](#background)

#### Part I — Architecture Overview
- [1.1 The Five Actors](#11-the-five-actors)
- [1.2 Signal Flow Diagram](#12-signal-flow-diagram)

#### Part II — Fast Interlock Chassis 340-308
- [2.1 Function](#21-function)
- [2.2 Inputs](#22-inputs)
- [2.3 Outputs](#23-outputs)
- [2.4 Front Panel](#24-front-panel)
- [2.5 Trip Mechanism](#25-trip-mechanism)

#### Part III — AIM Module (VXI Slot 12)
- [3.0 Role Clarification — AIM vs. Fast Interlock Chassis](#30-role-clarification--aim-vs-fast-interlock-chassis)
- [3.1 Hardware Identity](#31-hardware-identity)
- [3.2 Arc Detection (12 Channels)](#32-arc-detection-12-channels)
- [3.3 Hardware Trip Path — RF_FAULT Backplane Line](#33-hardware-trip-path--rf_fault-backplane-line)
- [3.4 ISR Path — Software Notification (~10 μs)](#34-isr-path--software-notification-10-μs)
- [3.5 AIM Status PV Map](#35-aim-status-pv-map)
- [3.6 AIM Control Output Signals (Fiber Optic Outputs)](#36-aim-control-output-signals-fiber-optic-outputs)
- [3.7 BATS — Beam Abort Trip Signal](#37-bats--beam-abort-trip-signal)
- [3.8 Fault Capture — Two Independent Systems](#38-fault-capture--two-independent-systems)
  - [System A — AIM Hardware History Buffer (12-channel AIM only)](#system-a--aim-hardware-history-buffer-12-channel-aim-only)
  - [System B — SNL Fault File Capture (`ss rf_statesFF`)](#system-b--snl-fault-file-capture-ss-rf_statesff)
- [3.9 Inputs](#39-inputs)
- [3.10 Outputs](#310-outputs)

#### Part IV — VXI Slot 5: "MPS Shutoff"
- [4.1 What It Is](#41-what-it-is)
- [4.2 Hardware Function](#42-hardware-function)
- [4.3 Software Visibility](#43-software-visibility)
- [4.4 Key Conclusion](#44-key-conclusion)
- [4.5 Analysis: Is the MPS Shutoff Module Necessary?](#45-analysis-is-the-mps-shutoff-module-necessary)

#### Part V — RF MPS PLC (ControlLogix 1756)
- [5.1 Platform](#51-platform)
- [5.2 Inputs](#52-inputs)
- [5.3 Outputs](#53-outputs)
- [5.4 Protection Functions](#54-protection-functions)
- [5.5 Trip Actions — Three Paths](#55-trip-actions--three-paths)
- [5.6 EPICS PV Path](#56-epics-pv-path)
- [5.7 MPS Wiring Documents](#57-mps-wiring-documents)

#### Part VI — SLC-500 HVPS PLC
- [6.1 Platform](#61-platform)
- [6.2 Inputs](#62-inputs)
- [6.3 Outputs](#63-outputs)
- [6.4 Rack Slot Configuration](#64-rack-slot-configuration)
- [6.5 What the SLC-500 Interlocks On](#65-what-the-slc-500-interlocks-on)
- [6.6 SCR Enable Relay — The HVPS Supervisory Enable Path](#66-scr-enable-relay--the-hvps-supervisory-enable-path)
- [6.7 HVPS Alarm Aggregation Tree](#67-hvps-alarm-aggregation-tree)
- [6.8 PPS Dual-Chain Architecture (Contactor and Grounding Switch)](#68-pps-dual-chain-architecture-contactor-and-grounding-switch)

#### Part VII — SNL State Machine (`rf_states.st`)
- [7.1 Inputs](#71-inputs)
- [7.2 Outputs](#72-outputs)
- [7.3 Architecture](#73-architecture)
- [7.4 The Single Trip Wire: `fault_stnoff`](#74-the-single-trip-wire-fault_stnoff)
- [7.5 STNMPS Alarm Tree (SPEAR3-specific, `rf_sumy_stn_spr.db`)](#75-stnmps-alarm-tree-spear3-specific-rf_sumy_stn_sprdb)
- [7.6 Orderly Shutdown Sequence (`s_go_off`)](#76-orderly-shutdown-sequence-s_go_off)
- [7.7 HVPS Startup Sequence (HVPSONSUB macro)](#77-hvps-startup-sequence-hvpsonsub-macro)
- [7.8 BATS Reset (`RESET_BMABTSUB`)](#78-bats-reset-reset_bmabtsub)
- [7.9 `forced_fault` Latch — Blocking Auto-Reset](#79-forced_fault-latch--blocking-auto-reset)

#### Part VIII — Fault Event Timeline
- [8.1 Example: Waveguide Arc](#81-example-waveguide-arc)
- [8.2 Example: RF MPS PLC Trip — Cooling Water Overtemperature](#82-example-rf-mps-plc-trip--cooling-water-overtemperature)
- [8.3 Example: HVPS PLC Trip — High-Voltage Transformer Arc](#83-example-hvps-plc-trip--high-voltage-transformer-arc)
- [8.4 Recovery Sequence](#84-recovery-sequence)

#### Part IX — Key Cross-Layer Interactions
- [9.1 AIM `aimon` ↔ SLC-500 Hardware Gate](#91-aim-aimon--slc-500-hardware-gate)
- [9.2 `forced_fault` Anti-Auto-Reset](#92-forced_fault-anti-auto-reset)
- [9.3 VXI Interlock Latch Register Fix (2004)](#93-vxi-interlock-latch-register-fix-2004)
- [9.4 Dual SCR Enable Paths — Supervisory vs. Fast](#94-dual-scr-enable-paths--supervisory-vs-fast)
- [9.5 RF MPS PLC Three-Path Architecture — Defense in Depth](#95-rf-mps-plc-three-path-architecture--defense-in-depth)
- [9.6 RF Shutdown Path Following HVPS PLC Trip](#96-rf-shutdown-path-following-hvps-plc-trip)

#### Part X — Fault Data Availability and Analysis
- [10.1 Overview of Fault Data Sources](#101-overview-of-fault-data-sources)
- [10.2 AIM Hardware History Buffer](#102-aim-hardware-history-buffer)
- [10.3 SNL Fault Files (`/dat/FAULT*_N`)](#103-snl-fault-files-datfault_n)
- [10.4 B118 Oscilloscope — Four HVPS Monitor Channels](#104-b118-oscilloscope--four-hvps-monitor-channels)
- [10.5 EPICS Channel Archiver](#105-epics-channel-archiver)
- [10.6 Step-by-Step Fault Analysis Procedure](#106-step-by-step-fault-analysis-procedure)

#### Appendices
- [Appendix A — EPICS PV Quick Reference](#appendix-a--epics-pv-quick-reference)
- [Appendix B — Items Requiring Field Verification](#appendix-b--items-requiring-field-verification)
- [Appendix C — Source Reference Index](#appendix-c--source-reference-index)

---

## Background

This document focuses on the legacy interlock system design, providing a deeper and more detailed description of the interlock architecture within the broader SPEAR3 RF system. It is part of the overall system architecture defined in **[R1]** — SPEAR3 RF System Legacy Architecture, which serves as the primary system-level reference. This document extends and elaborates on the interlock-related content presented there. Relevant sections in **[R1]**:

  - §5.5 — AIM Module (VXI Slot 12)
  - §9 — SLC-500 HVPS PLC
  - §13 — PPS Interface
  - §14 — RF MPS PLC
  - §15 — Interlock Architecture overview

All source code and EPICS database files cited in this document are listed with their reference numbers in [Appendix C](#appendix-c--source-reference-index).

---

## Part I — Architecture Overview

### 1.1 The Five Actors

The SPEAR3 RF interlock system involves five distinct hardware/software actors. They are **not redundant layers of the same function** — each addresses a different threat class at a different speed:

| Actor | Speed | Location | What It Protects Against |
|-------|-------|----------|--------------------------|
| **Fast Interlock Chassis** (340-308) | < 1 μs | B132 | Arc breakdown, reflections exceeding cavity/klystron ratings |
| **AIM Module** (VXI Slot 12) | < 1 μs (HW) / ~10 μs (ISR) | VXI Crate | Digitizes arc channel status from Fast IC; asserts RF_FAULT on VXI backplane; manages BATS; captures fault waveforms; drives control outputs (HVPS_On, Filament, Solenoid) |
| **RF MPS PLC** (AB PLC-5) | ~10 ms | B132 | Collector overpower, vacuum excursion, secondary arc, cooling |
| **SLC-500 HVPS PLC** (DH+ Rack 2) | ~20 ms | B118 | HVPS internal faults: oil, transformer, crowbar, overvoltage, arc in HV tank |
| **SNL State Machine** (`rf_states.st`) | ~1 s | VXI CPU (VxWorks) | Orderly shutdown sequencing, fault recording, recovery coordination |

### 1.2 Signal Flow Diagram

Three fault sources feed five actors. Hardware paths (top) are independent of software; the EPICS alarm tree (bottom) is the single software trip wire to the SNL state machine.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   FAULT SOURCES                                             │
├──────────────────────┬───────────────────────────────────────┬──────────────────────────────┤
│  Arc / RF overpow.   │  Collector / vacuum / cooling /       │  HVPS internal faults        │
│  (fiber, coax)       │  reflected power (protection)         │ (oil, arc, voltage, crowbar) │
└──────────┬───────────┴──────────────────┬────────────────────┴───────────────┬──────────────┘
           │                              │                                    │
           ▼                              ▼                                    ▼
┌──────────────────────┐    ┌─────────────────────────────┐       ┌────────────────────────────┐
│  FAST INTERLOCK      │    │  RF MPS PLC                 │       │  SLC-500 HVPS PLC          │
│  CHASSIS 340-308     │    │  AB PLC-5 / 1771-DCM, B132  │       │  B118, ~10–20 ms scan      │
│  (B132, < 1 μs)      │    │  ~10 ms scan cycle          │       │                            │
│                      │    │                             │       │  Detects: arc, crowbar,    │
│  Analog comparators  │    │  Path A: relay → Fast IC ───┼──────►│  overvolt, oil, transformer│
│  No CPU, no firmware │◄───┼──(removes hw permit)        │       │                            │
│                      │    │                             │       │  SCR supervisory relay:    │
│  ┌──────────────────┐│    │  Path B: DH+ permit bit OFF ├──┐    │  Slot 5 OX8 → fiber → B514 │
│  │ SCR ENABLE  OUT  ││    │  → STN:MPS:LTCH = MAJOR     │  │    │  (turns off SCR gate drive)│
│  │ (fiber → B514)   ││    │                             │  │    │                            │
│  └────────┬─────────┘│    │  Path C: relay → VXI Slot 5 ├──┼──┐ │  Updates HVPS:*:LTCH PVs   │
│           │          │    │  MPS SHUTOFF MODULE         │  │  │ └────────────┬───────────────┘
│  ┌────────┴─────────┐│    │  → RF_FAULT on VXI backplane│  │  │              │
│  │ CROWBAR FIRE OUT ││    │ (redundant RF cut, no HVPS) │  │  │              │ DH+ ~1 Hz
│  │ (fiber → B514)   ││    └─────────────────────────────┘  │  │              ▼
│  └────────┬─────────┘│                                     │  │       {STN}:HVPS*:*:LTCH
│           │          │                                     │  │       → HVPSSTN:SUMY:LTCH
│  ┌────────┴─────────┐│                                     │  │       → HVPSOFF:SUMY:STAT
│  │ STATUS WORD OUT  ││                                     │  │
│  │ → AIM Slot 12    ││                                     │  │ Path C
│  └────────┬─────────┘│                                     │  └─────────────────────────────┐
└───────────┼──────────┘                                     │                                │
            │ direct chassis-to-module cable                 │ Path B                         │
            ▼                                                │                                ▼
┌───────────────────────────────────────────────────┐        │            ┌───────────────────────────┐
│  AIM MODULE  VXI Slot 12  (devP2RfAim.c)          │        │            │  VXI SLOT 5               │
│                                                   │        │            │  MPS SHUTOFF MODULE       │
│  Arc channel registers (ARCCURSTT, ARCLTDSTT)     │        │            │                           │
│  populated from Fast IC status word               │        │            │  Receives MPS permit      │
│                                                   │        │            │  removal via relay        │
│  RF_FAULT ─────────────────────────────────────────────────┼────────────►                           │
│  asserted on VXI P2 backplane (< 1 μs)            │        │            │  Asserts RF_FAULT on      │
│                           │                       │        │            │  VXI P2 backplane         │
│                           ▼                       │        │            └────────────┬──────────────┘
│             ┌─────────────────────────┐           │        │                         │
│             │  RFP MODULE  Slot 4     │◄──────────┼────────┼─────────────────────────┘
│             │  RF drive DAC → zero    │           │        │       RF_FAULT line (open-collector)
│             │  (hardware, < 1 μs)     │           │        │
│             └─────────────────────────┘           │        │
│                                                   │        │
│  AIM ISR fires (~10 μs):                          │        │
│  → scanOnce(AIM:MODU)                             │        │
│  → STN:VXI:LTCH = MAJOR                           │        │
│  → STNMPS:SUMY:LTCH = MAJOR ◄─────────────────────┼────────┘
└───────────────────────────────────────────────────┘
                        │
                        │  All three fault sources feed into:
                        ▼
            ┌────────────────────────────────────────┐
            │   EPICS ALARM AGGREGATION TREE         │
            │   rf_sumy_stn.db / rf_sumy_stn_spr.db  │
            │   (~100 ms EPICS CA propagation)       │
            │                                        │
            │   STNMPS:SUMY:LTCH  ──────────────┐    │
            │   └ STN:VXI:LTCH (AIM fast path)  │    │
            │   └ STN:MPS:LTCH  (MPS PLC Path B)│    │
            │   └ STN:FORCED:LTCH (hard arc)    │    │
            │                                   │    │
            │   HVPSOFF:SUMY:STAT  ─────────────┤    │
            │   └ HVPSSTN:SUMY:LTCH (SLC-500)   │    │
            │                                   ▼    │
            │         {STN}:STNOFF:SUMY:STAT.SEVR    │
            │         ── single SNL trip wire ──     │
            └────────────────────┬───────────────────┘
                                 │  fault_stnoff != NO_ALARM
                                 ▼
            ┌────────────────────────────────────────┐
            │   SNL STATE MACHINE  rf_states.st      │
            │   VxWorks IOC, ~1 s response           │
            │                                        │
            │   s_go_off sequence:                   │
            │   1. fba=1  → BATS (beam abort)        │
            │   2. HVPS voltage setpoint → 0         │
            │   3. hvpstrig=OFF → SCR gate off (DH+) │
            │   4. rfswitch=OFF → RF drive off       │
            │   5. Fault file capture (11 channels)  │
            └────────────────────────────────────────┘
```

**Speed summary by path:**

| Path | Actor | Hardware action | EPICS notification | SNL response |
|------|-------|----------------|-------------------|--------------|
| Arc / RF overpow. → Fast IC | Fast IC 340-308 | < 1 μs (SCR + CROWBAR + RF cut) | ~50–500 μs (AIM ISR → VXI:LTCH) | ~1 s |
| MPS PLC Path A → Fast IC | RF MPS PLC + Fast IC | ~10–15 ms (relay + Fast IC) | ~1 s (DH+ Path B) | ~1 s |
| MPS PLC Path C → Slot 5 | RF MPS PLC + Slot 5 | ~10–15 ms (RF cut only, no HVPS) | — | — |
| HVPS internal fault → SLC-500 | SLC-500 HVPS PLC | ~10–20 ms (SCR supervisory relay) | ~100 ms–1 s (DH+ → EPICS) | ~1 s |

---

## Part II — Fast Interlock Chassis 340-308

### 2.1 Function

The Fast Interlock Chassis is a pure analog hardware circuit — no software, no firmware, no CPU in the trip path. It provides sub-microsecond RF protection that is completely independent of all PLCs and computers.

**Physical location**: B132 electronics rack, right below the VXI crate.

### 2.2 Inputs

| Input Type | Source | Connection | Notes |
|------------|--------|------------|-------|
| Arc detection (fiber optic) | 4× cavity waveguide window sensors | Fiber optic receivers on chassis | Raw optical arc pulses → analog comparators |
| Arc detection (fiber optic) | Klystron output window sensor | Fiber optic receiver | |
| Arc detection (fiber optic) | Main circulator sensor | Fiber optic receiver | |
| RF reflected power | Detector diodes at cavity and waveguide junctions | Coaxial cable, analog voltage | Compared against DC threshold |
| RF forward power | Detector diodes (klystron output monitor) | Coaxial cable, J16 "DETECTED KLYSTRON POWER" | |
| SPEAR3 beam permit | Machine-level MPS permit | External hardwired | Permit removal treated as fault |
| Orbit interlock | SPEAR3 orbit feedback system | External hardwired | |
| **HVPS status (fiber)** | **B514 HVPS power section self-status** | **Fiber optic direct from B514 → B132** | **Informational only. Reports `HVPSON` in AIM `FISTAT` register (bit 6). Does NOT cause a Fast IC hardware trip. Used to gate arc voltage readback in AIM (arc peaks not read when `HVPSON=0`). Source is B514 power section; NOT from SLC-500 (B118).** |
| MPS PLC permit | RF MPS PLC (ControlLogix) relay output | Hardwired relay I/O | Permit removal triggers SCR ENABLE + CROWBAR (Path A) |

### 2.3 Outputs

| Output | Destination | Latency | Mechanism |
|--------|-------------|---------|-----------|
| SCR ENABLE remove | B514 HVPS SCR gate drivers | < 1 μs | Fiber optic — eliminates ground loop |
| CROWBAR fire | B514 crowbar thyristor | < 1 μs | Fiber optic |
| Status word | AIM Module (VXI Slot 12) | ~1 μs | Direct chassis-to-module connection |

### 2.4 Front Panel

The front panel of the Fast Interlock Chassis (SLAC drawing 340-308, photo in §15 of Doc L) shows:
- **FAULT RESET** button — latches cannot be cleared without this
- **LAMENT TIMEOUT** indicator — klystron filament interlock
- **BEAM ABORT** indicator/control
- **TEST PORT** 12-channel test port for arc threshold adjustment
- **INPUT MONITOR** — CH.1 through CH.12 input monitor test points
- **HVPS ON**, **SOLENOID ON**, **FILAMENT ON** status indicators
- **J16 DETECTED KLYSTRON POWER** coaxial input

### 2.5 Trip Mechanism

Each arc detection channel has an adjustable current threshold set by AIM configurable with software. When a fiber-optic arc pulse arrives (arc sensors generate an optical burst on breakdown):
1. Analog comparator fires
2. Fault latch is set (latching relay or SR flip-flop — requires hardware FAULT RESET to clear)
3. SCR ENABLE output goes low simultaneously (< 1 μs)
4. CROWBAR fire pulse is generated

For reflected power, the analog input voltage from the RF detectors is compared to a DC threshold. Exceeding the threshold fires the same trip mechanism.

> **Source**: [R1] §15; [R21] §5.2.

---

## Part III — AIM Module (VXI Slot 12)

### 3.0 Role Clarification — AIM vs. Fast Interlock Chassis

> **The AIM module (drawing 340-307) and the Fast Interlock Chassis (drawing 340-308) are companion units designed as a pair.** Their sequential SLAC drawing numbers reflect this: 340-307 is the VXI digital module; 340-308 is the external analog chassis.

**Fast Interlock Chassis 340-308** is the **analog front-end**:
- Directly receives fiber-optic arc sensor pulses from cavity windows, klystron output, and circulator
- Performs sub-microsecond analog threshold comparisons (no CPU, no firmware, no software in the trip path)
- Fires the hardware trip: SCR ENABLE fiber removed (→ B514) and CROWBAR fiber pulse (→ B514)
- Sends the resulting arc-channel status word to the AIM module via a direct chassis-to-module cable

**AIM module 340-307** is the **VXI digital companion**:
- Receives arc-channel status word from Fast IC via direct hardware connection
- Its 12-channel arc registers (`ARCCURSTT`, `ARCLTDSTT`) digitally represent the Fast IC's per-channel arc detector states
- **Provides the VXI configuration interface for Fast IC comparator thresholds**: writing to the AIM's `TRIPLVL` registers (A24 address space) sets the arc detection threshold for each channel; the Fast IC reads these values from the AIM via their direct link and applies them to its analog comparators. Enforced range: 10–255 (MINTRIPLVL / MAXTRIPLVL in `devP2RfAim.c`).
- Asserts `RF_FAULT` on the VXI P2 backplane (sub-μs) to cut RF drive from the RFP module
- Generates the ISR → EPICS alarm chain notification (~10 μs)
- Drives 6 fiber-optic control outputs to multiple destinations: external power supplies (Filament heater, Solenoid), HVPS SCR enable hardware, SPEAR3 Machine MPS (Beam Abort), and Fast IC hardware (Fault Reset)
- Manages BATS: Force Beam Abort and Reset Beam Abort signals to the machine MPS
- **Captures arc-channel history waveforms** via on-module 512 KB ADC ring buffer (12-ch AIM `HISBUF`): the Fast IC's fast ADC continuously samples all arc channel voltages and the HVPS voltage into this buffer; on fault the buffer freezes and is read back
- Captures RF/IQA fault waveforms at the SNL level (11 channels → `/dat/FAULT*_N` files)

**Key distinction**: The AIM IS correctly named as an arc detector — it registers and latches per-channel arc events and asserts the VXI-level RF protection. However, it does **not** process raw fiber-optic arc pulses directly. All raw optical signal processing is done by the Fast IC 340-308. The AIM's arc detection is the digital representation and VXI-backplane consequence of what the Fast IC detected.

---

### 3.1 Hardware Identity

- **Module type**: SLAC PEP-II RF custom VXI module — "Arc detector / Interlock Module" (AIM), drawing 340-307
- **VXI slot**: 12 (last slot, rightmost in crate)
- **Device support driver**: `devP2RfAim.c` (1,982 lines)
- **Primary EPICS record**: `{STN}:STN:AIM:MODU` (type `p2RfAim`)
- **DAS instruction files**: `/tbl/aimDas0.inst`, `/tbl/aimDas1.inst`
- **History file**: `/dat/aimHist.dat`

### 3.2 Arc Detection (12 Channels)

The AIM module has 12 independently configurable arc detection channels. Each channel has:
- **Enable/disable** bit (`ARCENBSTT` register, `MODU.AFES` field)
- **Threshold** setting (8-bit value, range 10–255): configured via EPICS writing to the AIM's `TRIPLVL` registers (A24 offset `0x0020` for ch 0, successive offsets per channel). The device driver (`devP2RfAim.c`) writes the value to the AIM VXI register; the Fast IC reads it via their direct hardware link and applies it to its analog comparator for that channel. The old method of adjusting thresholds via the Fast IC front panel is superseded by this software interface.
- **Current status** (`ARCCURSTT`, `MODU.ACST`) — real-time arc presence (populated from Fast IC status word)
- **Latched status** (`ARCLTDSTT`, `MODU.ALST`) — fault held since last reset (populated from Fast IC status word)

> **Note on channel count**: The legacy AIM supports 12 hardware channels. The SPEAR3 deployment uses 6 sensor locations (4 cavity windows + 1 klystron window + 1 circulator), provisioned with up to 11 total sensors including spares. See PDR §12.3 for the authoritative upgrade count.

### 3.3 Hardware Trip Path — RF_FAULT Backplane Line

This is the fastest path, entirely in hardware with no software:

```
Arc detected on any channel (< 1 μs)
    OR Fast Interlock Chassis status asserted
        │
        ├──► SCR Enable remove, CROWBAR FIRE, Status Word ──► AIM
        ▼
AIM module asserts RF_FAULT LOW
on VXI P2 backplane (open-collector line)
        │
        ├──► RFP module (Slot 4) monitors RF_FAULT
        │    → Immediately zeros the RF drive DAC outputs
        │    → RF power output collapses (< 1 μs within crate)
        │
        └──► CLK module (Slot 2) monitors RF_FAULT
             → Reference clock protection action
```

The `RF_FAULT` line is **open-collector**: any module on the VXI P2 bus can assert it. The RFP module's reaction is purely analog — no DSP, no SNL, no EPICS involved.

### 3.4 ISR Path — Software Notification (~10 μs) 

After the hardware trip fires:
```c
AimIsr() {
    read FAST INTERLOCK STATUS REGISTER  // latched, not ISR register (Sass 2004 fix)
    update rec->istt
    board->intPrc++
    scanOnce(rec)   // schedules AIM:MODU for EPICS processing
}
```

> **Critical 2004 fix** (Sass, `rf_interlock_vxi.db` rev 1.2): Prior to January 2004, the VXI interlock records read the AIM **interrupt status register** (ISR). Because EPICS processed these records continuously, the ISR bits self-cleared on every read — a latched fault could be invisible to the alarm system because it was cleared before alarm propagation. The fix changed to reading the AIM **fast interlock status/latch register**, which holds bits until the operator presses the hardware FAULT RESET button on the interlock chassis front panel. This was a significant reliability fix.

The record `{STN}:STN:AIM:MODU` then processes via a three-stage fanout (`FANO1` → `FANO2` → `FANO3`) that updates all derivative records.

### 3.5 AIM Status PV Map

| PV | AIM Register | Content |
|----|-------------|---------|
| `{STN}:STN:AIM:ARCCURSTT` | `MODU.ACST` | mbbiDirect — 12-bit arc current status word (one bit per channel) |
| `{STN}:STN:AIM:ARCLTDSTT` | `MODU.ALST` | mbbiDirect — 12-bit arc latched status (holds until FAULT RESET) |
| `{STN}:STN:AIM:ARCENBSTT` | `MODU.AFES` | mbbiDirect — 12-bit arc enable bitmap |
| `{STN}:STN:AIM:FSTFLT` | `MODU.FFLT` | mbbiDirect — fast fault status from Fast IC |
| `{STN}:STN:AIM:FSTINTSTT` | `MODU.FSTT` | mbbiDirect — fast interlock state (daisy chain) |
| `{STN}:STN:AIM:INTSTATE` | `MODU.ISTT` | mbbiDirect — overall AIM interlock state |
| `{STN}:STN:AIM:INTACK` | `MODU.IACK` | mbboDirect — interlock acknowledge |

These feed into `rf_interlock_vxi.db`:
```
{STN}:STN:AIM:LTCH.BN  →  {STN}:STN:VXI:LTCH  (bi, MAJOR alarm)
    → {STN}:STNMPS:SUMY:LTCH.INPC
```

### 3.6 AIM Control Output Signals (Fiber Optic Outputs)

The AIM module drives **6 fiber-optic control output signals** via the `FICTRL` (Fast Interlock Control) register (A16 address `0x20`). They are software-commanded by the SNL state machine. These signals fan out to **multiple destinations** — some go directly to external power supply hardware, some go to Fast IC hardware, and one goes to the SPEAR3 Machine MPS:

| Signal Name | EPICS PV | AIM FICTRL bit | Destination | Function |
|------------|---------|----------------|-------------|----------|
| Klystron Filament On | `{STN}:STN:AIM:FILAMENT` | bit 2 (`MODU.FOO`) | Klystron filament heater supply (external) | Enables klystron filament heater; required before HVPS startup |
| Solenoid On | `{STN}:STN:AIM:SOLENOID` | bit 0 (`MODU.SOO`) | Klystron focusing solenoid supply (external) | Enables solenoid; required before HVPS startup |
| **HVPS On (aimon)** | `{STN}:STN:AIM:MODU.HVPS` | bit 1 (`MODU.HVPS`) | HVPS SCR enable hardware | **Hardware enable gate** — AIM holds LOW at startup; HVPS cannot energize until IOC asserts it in `HVPSONSUB` |
| Force Beam Abort (fba) | `{STN}:STN:AIM:FRCBMABT` | bit 6 (`MODU.FBA`) | SPEAR3 Machine MPS (injection kicker) | Fires machine-level beam abort; asserted in `s_go_off` Step 1 |
| Fault Reset | `{STN}:STN:AIM:MODU.RSTF` | bit 5 (`MODU.RSTF`) | Fast IC hardware arc latches | Clears arc latches in Fast IC and AIM (equivalent to pressing front-panel FAULT RESET button) |
| Forced Fault | `{STN}:STN:AIM:FRCFLT` | bit 4 (`MODU.FF`) | Fast IC test input | Forces a latched fault (used for testing) |

> **Note**: L_LEGACY §5.5 lists a sixth signal `Filament_Timeout` — this is the `FILTMOOVRD` bit (bit 3, `MODU.FTOR`), a filament-timeout safety override to the Fast IC's filament-watchdog logic. It is not commonly used in normal SPEAR3 operation and does not appear in the EPICS operator interface.

Strobed signals (HVPS, FILTMOOVRD, FLTRESET, RSTBMABT) are written high then immediately re-cleared in the same processing cycle to avoid latching; latching signals (SOLENOID, FILAMENT, FRCDFLT, FRCBMABT) hold their state.

### 3.7 BATS — Beam Abort Trip Signal

When the HVPS crowbar fires (detected through the Fast IC status into the AIM), the AIM asserts a BATS into the SPEAR3 beam MPS network. This fires the injection kicker and prevents new electrons from entering the storage ring during RF downtime.

**BATS reset sequence** (required before restarting):
```c
/* RESET_BMABTSUB macro in rf_states.st */
if (fault_stnoff == NO_ALARM) {
    fba = 0;        pvPut(fba)   // de-assert Force Beam Abort
    pvPut(rba)                   // Reset Beam Abort (RBA → MODU.RBA)
    pvPut(rstf)                  // Reset Faults (RSTF → MODU.RSTF — clears arc latches)
}
```
This three-write sequence is only executed when `fault_stnoff == NO_ALARM` — all fault conditions must be clear first.

### 3.8 Fault Capture — Two Independent Systems

There are **two completely separate** capture systems that activate on fault. They capture different signals by different mechanisms at different speeds.

#### System A — AIM Hardware History Buffer (12-channel AIM only)

The 12-channel AIM module includes a 512 KB on-module ring buffer (`HISBUF`, A24 address `0x0038`, `AIM_K_HISBUFID`). The **Fast IC has an onboard fast ADC** that continuously samples all arc channel voltages and the HVPS voltage, storing them into this AIM memory. Two `FICTRL` bits control the ADC:

| FICTRL bit | Name | 0 | 1 |
|------------|------|---|---|
| bit 8 | `ADCMUX` | HVPS voltage + all 12 arc channels (normal) | HVPS voltage only |
| bit 9 | `ADCCTL` | Start / continue buffering (normal; no fault) | Stop buffering (freeze on fault) |

*Normal operation*: `ADCCTL=0` and no fault → ADC continuously overwrites the ring buffer.  
*On fault*: The fault assertion sets `ADCCTL=1` → buffer freezes at fault instant → pre-fault arc waveforms and HVPS voltage are preserved.

**Buffer readout**: The driver reads arc voltage peak values via the `ARCVOL` register (A24 `0x003A`) — a sequential-readout register that returns one channel's voltage per read, cycling through all channels. Similarly, `CRTVOL` (A24 `0x003C`) returns per-channel crate voltage measurements. The readout is gated: if `FISTAT.HVPSON = 0` (HVPS off), the driver skips arc voltage readback (no HV → no expected arc peaks).

> **7-channel AIM (legacy PEP-II)**: Used a different mechanism — two DAS (Data Acquisition System) chips with instruction files (`/tbl/aimDas0.inst`, `/tbl/aimDas1.inst`) that defined what registers to capture. This DAS mechanism is NOT used in the 12-channel SPEAR3 AIM. The `/dat/aimHist.dat` file listed in §3.1 is the 7-ch DAS artifact; SPEAR3 uses the HISBUF hardware buffer.

#### System B — SNL Fault File Capture (`ss rf_statesFF`)

A software-level capture triggered by `efSet(ffwrite_ef)` in the SNL `s_go_off` state at ~1 s after the hardware fault. Captures **11 RF/IQA signal channels** (not arc voltages). The `ss rf_statesFF` state set:
1. Increments fault slot number (circular buffer 1–15, `NUMFAULTS=15`)
2. Timestamps via `pvTimeStamp(hvpswdefault)` — the HVPS voltage PV's timestamp
3. Places 11 signal modules in LOAD mode
4. Reads hardware signal memory buffers from RFP, IQA modules
5. Writes to `/dat/FAULTxxx_N` files (N = fault slot 1–15)
6. Maximum wait: `MAXFFWAIT = 180 × 20 ticks ≈ 3.6 s`

The 11 fault file channels:

| Channel | File Pattern | Signal |
|---------|-------------|--------|
| 0 | `FAULTRfpSI_N` | RFP Signal I (cavity forward, I) |
| 1 | `FAULTRfpSQ_N` | RFP Signal Q (cavity forward, Q) |
| 2 | `FAULTRfpCI_N` | RFP Cavity I (cavity voltage, I) |
| 3 | `FAULTRfpCQ_N` | RFP Cavity Q (cavity voltage, Q) |
| 4 | `FAULTIqa1Amp_N` | IQA1 amplitude waveform |
| 5 | `FAULTIqa2Amp_N` | IQA2 amplitude waveform |
| 6 | `FAULTGvf_N` | GVF signal (PEP-II heritage, inactive in SPEAR3) |
| 7 | `FAULTAim_N` | AIM arc/interlock status snapshot |
| 8 | `FAULTCmbI_N` / `FAULTCmbQ_N` | Combiner I/Q (PEP-II, inactive in SPEAR3) |
| 9 | `FAULTIqa3Amp_N` | IQA3 amplitude waveform |
| 10 | *(additional)* | Additional channel added in 2003 Laznovsky revision |

> **Source**: [R2] lines 1900–2200 (`ss rf_statesFF`); [R3] §5 in [R21]; [R6] (`AIM_A_HISBUF`, `AIM_V_ADCMUX`, `AIM_V_ADCCTL`).

### 3.9 Inputs

| Input | Source | Connection | Notes |
|-------|--------|------------|-------|
| Arc channel status (12 channels, `ARCCURSTT`) | Fast Interlock Chassis 340-308 | Direct chassis-to-module cable | Digital arc-detected status word, one bit per channel; ARCLTDSTT holds bits until FAULT RESET |
| Fast IC interlock chain state (`FSTINTSTT`, `MODU.FSTT`) | Fast Interlock Chassis 340-308 | Direct chassis-to-module cable | Daisy-chain fast interlock state |
| Fast IC fast fault status (`FSTFLT`, `MODU.FFLT`) | Fast Interlock Chassis 340-308 | Direct chassis-to-module cable | Aggregated fast fault indication |
| AIM interrupt | AIM on-board IRQ logic | VXI interrupt line | `AIM_M_ARCDETD` (arc detected), `AIM_M_VXIBPFLT` (VXI backplane fault), `AIM_M_FRCDFLTINT` (forced fault), etc. |
| AB (DH+) heartbeat/summary | AB-6008 scanner (VXI Slot 1) | VXI backplane | Watchdog for DH+ communication health; contributes to `AIMARC:LTCH` via first-fault register |
| AIM_M_SOFTWARE interrupt | EPICS IOC write | VXI register write | Software-triggered interrupt (for test/forced-fault operations) |

### 3.10 Outputs

| Output | Destination | Mechanism | Notes |
|--------|-------------|-----------|-------|
| `RF_FAULT` assertion (open-collector LOW) | VXI P2 backplane | VXI bus | Sub-μs; causes RFP (slot 4) to zero RF drive DAC and CLK (slot 2) to react |
| HVPS_On fiber (`aimon`, `MODU.HVPS`) | HVPS enable chain (via Fast IC → B514 SCR) | Fiber optic from AIM/Fast IC | Software gate; must be explicitly asserted by SNL `HVPSONSUB`; AIM holds LOW at startup |
| Klystron Filament On (`MODU.FOO`) | Klystron filament heater power supply | Fiber optic | Commanded by SNL; part of HVPS startup sequence |
| Solenoid On (`MODU.SOO`) | Klystron focusing solenoid supply | Fiber optic | Commanded by SNL; required before HVPS can be energized |
| Force Beam Abort (`MODU.FBA`, `fba`) | SPEAR3 machine MPS | Hardwired to SPEAR3 MPS | Fires injection kicker to dump beam; asserted in `s_go_off` Step 1 |
| Reset Beam Abort (`MODU.RBA`, `rba`) | SPEAR3 machine MPS | Hardwired to SPEAR3 MPS | De-asserts beam abort; used in recovery `RESET_BMABTSUB` |
| Fault Reset (`MODU.RSTF`, `rstf`) | AIM hardware latches | AIM register write | Clears `ARCLTDSTT`, `AIMARC:LTCH`, fast interlock latches — same effect as hardware FAULT RESET button |
| EPICS PVs (arc status, interlock state) | EPICS IOC (VxWorks) | EPICS CA record processing | `ARCCURSTT`, `ARCLTDSTT`, `ARCENBSTT`, `FSTFLT`, `INTSTATE` → `STN:VXI:LTCH` → alarm tree |

---

## Part IV — VXI Slot 5: "MPS Shutoff" — Clarification

### 4.1 What It Is

**This slot requires careful distinction between hardware labeling, software configuration, and functional role.**

The SPEAR3 VXI crate (SRF1) at slot 5 is labeled **"MPS Shutoff"** in the crate physical template (`crat_vxi_13slot.template,v`). This is its functional designation in the SPEAR3 system.

The IOC software (`rf_vxi_modules_All.substitutions,v`) loads `cf2.db` (the Comb Filter 2 database) for slot 5 — **this is a PEP-II inherited template artifact**. The `devP2RfCf2.c` driver (2,970 lines) is a PEP-II-only module; the CF2 DSP functionality (comb filter, group delay equalizer, filter bank) is **not exercised in SPEAR3**.

| Aspect | PEP-II | SPEAR3 SRF1 |
|--------|--------|-------------|
| Physical slot 5 module | CF2 (Comb Filter 2) DSP | MPS Shutoff module |
| Software DB loaded | `cf2.db` | `cf2.db` (PEP-II template artifact) |
| Device driver active? | Yes — `devP2RfCf2.c` | No — physical CF2 module not installed |
| Functional use | RF comb filter feedback | MPS permit interface |

> **Source**: [R19] line 65; [R20] line 95.

### 4.2 Hardware Function

The "MPS Shutoff" module in slot 5 provides the **VXI-backplane MPS permit interface**. Its role is:

1. The module occupies slot 5 and has access to the VXI P2 backplane
2. It receives the RF MPS permit signal from the RF MPS PLC (ControlLogix) — the permit is delivered either via hardwired relay I/O from the PLC to a connector on this module, or via a dedicated backplane line
3. When the MPS permit is **present**: the module holds the `RF_PERMIT` backplane line HIGH (or asserts a permissive signal); the RFP module (slot 4) is allowed to output RF drive
4. When the MPS permit is **removed**: the module drops `RF_PERMIT` or asserts `RF_FAULT` on the backplane; the RFP module immediately cuts output (same hardware-speed path as the arc trip)

### 4.3 Software Visibility

The MPS permit status is tracked in EPICS via `{STN}:STN:MPS:LTCH` — a binary input record reading from the AB DH+ communication registers (`rf_interlock.db`, `DTYP="AB-1771DCM BI"`, word `T6[WL,B]`). This is the software-visible representation of the MPS permit held by the RF MPS PLC.

The `{STN}:STN:VXI:LTCH` record (from `rf_interlock_vxi.db`) reads from the AIM latch register bits (`{STN}:STN:AIM:LTCH.BN`) — not from the CF2 slot 5 module. The CF2 OVFL and status records (`{STN}:STN:CF2OVFL:STAT`) are loaded in the DB but are not connected to any active hardware in SPEAR3 (their `DTYP="Soft Channel"` reads from the inactive `{STN}:STN:CF2:MODU` record).

### 4.4 Key Conclusion

> **VXI Slot 5 in SPEAR3 is an MPS permit gate at the VXI backplane level. It does NOT run the CF2 DSP firmware. The cf2.db PV records loaded for slot 5 are inactive (hardware not present). The MPS permit removal causes the RFP module to cut RF drive at hardware speed through the VXI backplane permit line — exactly the same speed and mechanism as the AIM's RF_FAULT assertion.**

### 4.5 Analysis: Is the MPS Shutoff Module Necessary?

The MPS PLC trip relay connects to **both** the Fast Interlock Chassis and (if wired) the VXI Slot 5 module. When the relay opens, the following happens simultaneously on both paths:

| Path | Triggered By | HVPS Action | RF Drive Action |
|------|-------------|-------------|-----------------|
| **Path A** — Fast IC (§5.5) | MPS relay opens → Fast IC loses permit | SCR ENABLE removed + CROWBAR fired (fiber → B514) | Fast IC status → AIM → `RF_FAULT` on VXI backplane |
| **Path C** — VXI Slot 5 | MPS relay opens → Slot 5 loses permit | **None** — Slot 5 has no connection to B514 SCR or crowbar | `RF_FAULT` asserted directly on VXI P2 backplane |

**Assessment:**

The Slot 5 RF drive kill via VXI backplane is **functionally redundant** with the RF_FAULT assertion that already results from Path A (Fast IC → AIM). Both fire in response to the same relay opening, and both assert `RF_FAULT` on the VXI P2 bus at sub-millisecond speed.

Critically, Slot 5 does **not** independently shut off the HVPS. The HVPS shutdown (SCR ENABLE removal and crowbar firing) is handled exclusively by the Fast Interlock Chassis in Path A. The concern that "this path does not shut off the HVPS" is accurate for Slot 5 alone — but the HVPS shutdown is guaranteed by Path A firing simultaneously.

**Why Slot 5 may have been retained:**
- Defense-in-depth: provides a direct, CPU-free VXI backplane RF kill that is independent of the AIM module's health
- Carried forward from the PEP-II architecture where the CF2 slot served a different role; repurposed in SPEAR3 as an MPS permit gate
- In a failure scenario where the AIM module fails to assert `RF_FAULT` (e.g., AIM hardware fault), Slot 5 provides a fallback RF kill path

> **Conclusion**: In normal operation, Slot 5 provides redundant defense-in-depth for RF drive cutoff only. It is not the primary HVPS shutdown path — that function is owned by the Fast IC. 

---

## Part V — RF MPS PLC (PLC-5 / 1771-DCM)

### 5.1 Platform

| Attribute | Detail |
|-----------|--------|
| Hardware | Allen-Bradley PLC-5 / 1771-DCM |
| Location | B132 (same rack as VXI crate) |
| DH+ node | Rack 1 |
| Status | Hardware replaced; software written and tested without RF power |

### 5.2 Inputs

| Input | Source | Connection | Notes |
|-------|--------|------------|-------|
| Klystron collector power (calculated) | Klystron high-voltage and RF output detectors | Analog I/O module in ControlLogix rack | Cathode power minus RF output; excessive difference = klystron overheating |
| Reflected power (4 cavities) | RF detector diodes at cavity and waveguide junctions | Analog I/O | VSWR or arc condition in waveguide |
| Secondary arc sensors | Arc sensor inputs not in Fast IC path | Digital I/O | Redundant arc coverage in waveguide runs |
| Cooling water flow | Flow meters on klystron and dummy load circuits | Digital/analog I/O | Below minimum flow trips MPS |
| Cooling water temperature | Temperature sensors on water circuits | Analog I/O | Exceeding maximum trips MPS |
| Klystron vacuum | Ion pump current or Penning gauge | Analog I/O | Vacuum excursion protection |
| HVPS fault status | SLC-500 HVPS PLC | DH+ (ControlLogix reads SLC-500 via DH+ scanner) | HVPS faults forwarded to MPS summary |
| 476 MHz reference power | `{STN}:STNREF:POWER:LTCH` | EPICS gateway | Reference RF monitor |
| Local panel / remote switch | B132 local panel | Digital I/O | Local/remote mode selector |

### 5.3 Outputs

| Output | Destination | Connection | Notes |
|--------|-------------|------------|-------|
| **MPS permit relay** (Path A) | Fast Interlock Chassis 340-308 | Hardwired relay contact | De-energizing removes Fast IC permit → SCR ENABLE + CROWBAR from Fast IC |
| **MPS permit relay** (Path C) | VXI Slot 5 MPS Shutoff module | Hardwired relay contact (same relay, separate contact or same wire) | De-energizing removes VXI backplane RF permit → RFP drive cut |
| DH+ permit status bit | EPICS IOC (via AB-6008 scanner) | DH+ word T6[WL,B] | Software path (Path B) — updates `{STN}:STN:MPS:LTCH` |

### 5.4 Protection Functions

The MPS PLC monitors **equipment protection** parameters on a ~10 ms scan cycle:

| Monitored Parameter | Trip Condition | Notes |
|--------------------|----------------|-------|
| **Klystron collector power** | Cathode power − RF output exceeds limit | Excessive collector power = poor klystron efficiency → overheating |
| **Reflected power** | Reflected power at any cavity exceeds limit | VSWR/arc condition in waveguide |
| **Arc conditions** | Secondary arc sensors (not in Fast IC path) | Redundant arc coverage |
| **Cooling water flow** | Below minimum flow rate | Klystron and waveguide loads |
| **Cooling water temperature** | Exceeds maximum | Thermal runaway detection |
| **Klystron vacuum** | Ion pump current or Penning gauge exceeds limit | Vacuum excursion protection |
| **HVPS fault conditions** | Status from SLC-500 via DH+ | Forwarded to MPS summary |
| **Reference power level** | `{STN}:STNREF:POWER:LTCH` | 476 MHz reference monitor |

### 5.5 Trip Actions — Three Paths

**Path A — Hardware HVPS shutdown + RF cut (fast, ~10 ms PLC scan):**

The MPS PLC has **hardwired relay I/O connections to the Fast Interlock Chassis 340-308**. When the PLC detects a fault requiring immediate action:
1. PLC relay output de-energizes
2. Removes the external MPS permit input to the Fast Interlock Chassis
3. Fast IC treats permit removal as a fault → fires SCR ENABLE removal and CROWBAR via fiber to B514 (< 1 μs after relay contact opens)
4. Fast IC sends updated status word to AIM → AIM asserts `RF_FAULT` on VXI backplane → RFP RF drive zeroed

This path: ~10 ms (PLC scan) + relay opening time + Fast IC response (< 1 μs) ≈ **~10–15 ms total**.
**Action**: HVPS shutdown (SCR ENABLE + CROWBAR) AND RF drive cut.

**Path B — Software/EPICS notification (slow, ~1 s):**

1. PLC writes "no permit" status to its DH+ output data table
2. VXI AB6008 scanner reads DH+ registers at ~1 Hz
3. Updates `{STN}:STN:MPS:LTCH` EPICS record
4. Alarm propagates via `rf_sumy_stn_spr.db` → `{STN}:STNMPS:SUMY:LTCH.INPI` → `{STN}:STNOFF:SUMY:STAT.SEVR`
5. SNL `fault_stnoff != NO_ALARM` triggers `s_go_off`

Path B is **bookkeeping** — the MPS hardware has already acted on Path A. Path B ensures the EPICS state machine learns about the fault, logs it, triggers fault file capture, and performs the orderly shutdown sequence.
**Action**: Orderly HVPS ramp-to-zero + fault file capture (hardware already tripped via Path A).

**Path C — VXI backplane RF permit gate (~10 ms PLC scan):**

The same MPS permit removal that triggers Path A simultaneously removes the permit from VXI Slot 5 MPS Shutoff module. The module asserts `RF_FAULT` (or removes `RF_PERMIT`) on the VXI P2 backplane → RFP RF drive cut.

Path C: ~10 ms (PLC scan) + relay opening time ≈ **~10 ms total**.
**Action**: RF drive cut only. No HVPS action.

> **Note**: Path C is functionally redundant with the RF drive cut already produced by Path A (via Fast IC → AIM → VXI RF_FAULT). See §4.5 for analysis. The HVPS shutdown is exclusively owned by Path A through the Fast IC.

### 5.6 EPICS PV Path

```
RF MPS PLC (CAllen-Bradley PLC-5 / 1771-DCM, Rack 1 DH+ node)
    │  DH+ word T6[WL,B]
    ▼
{STN}:STN:MPS:LTCH  (bi, DTYP="AB-1771DCM BI", MAJOR alarm)
    │  .SEVR  NPP MS
    ▼
{STN}:STNMPS:SUMY:LTCH.INPI
    │  .SEVR  NPP MS
    ▼
{STN}:STNOFF:SUMY:STAT.SEVR  (→ fault_stnoff in rf_states.st)
```

### 5.7 MPS Wiring Documents

33 MPS wiring diagrams (SLAC drawings wd3403300200 through wd3403303400) describe the complete MPS hardware signal chain. Original harness is for the PLC-5.

---

## Part VI — SLC-500 HVPS PLC

### 6.1 Platform

| Attribute | Detail |
|-----------|--------|
| CPU | Allen-Bradley 1747-L532 |
| DH+ Scanner | Allen-Bradley 1747-DCM |
| Location | B118 (HVPS building), Hoffman Box enclosure |
| DH+ Node | Rack 2 |
| Rack | 14-slot SLC chassis |

### 6.2 Inputs

| Input | Source | Connection | Notes |
|-------|--------|------------|-------|
| HVPS DC output voltage | HVPS power supply analog | Slot 8–9 Analog I/O (AI word 30) | Used for voltage readback and overvoltage detection |
| HVPS DC output current | HVPS power supply analog | Slot 8–9 Analog I/O (AI word 31) | Used for current readback and overcurrent detection |
| Primary AC current | AC current transformer | Slot 8–9 Analog I/O | Overcurrent detection (`HVPSAC:CURR:LTCH`) |
| Oil temperature (thermocouple) | Oil tank thermocouple | Slot 3 thermocouple input | `HVPSOIL:TEMP:LTCH` overtemperature latch |
| PPS enable | PPS system (GOB12-88PNE, Pin E→F) | Slot 6 IB16 digital input 14 | Used for HV vacuum contactor control |
| **B514 HVPS STATUS fiber** | **B514 HVPS power section self-status** | **Slot 6 IB16 fiber-optic receiver** | **B514 reports its operational status back to B118. The same STATUS fiber from B514 also goes directly to the Fast IC in B132 (see §2.2 — `HVPSON` in FISTAT). The SLC-500 reads B514 STATUS here; it does NOT re-transmit it onward.** |
| Fast IC interlock status | Fast Interlock Chassis 340-308 | Slot 6 IB16 (fiber-optic receiver) | Arc/interlock status from Fast IC — separate from B514 STATUS above |
| Crowbar fired / arc status | Internal HVPS self-monitoring | Slot 6 IB16 digital inputs | `HVPS:CROWBAR:LTCH`, `HVPSKLYS:ARC:LTCH`, etc. |
| Oil level | Float switch in HV tank | Slot 6 IB16 digital input | `HVPSOIL:LEVEL:LTCH` |
| Transformer arc | Arc detector inside HV transformer | Slot 6 IB16 digital input | `HVPSXFORM:ARC:LTCH` |
| SCR bank status | SCR gate driver feedback | Slot 6 IB16 digital inputs | `HVPSSCR1:ON:STAT`, `HVPSSCR2:ON:STAT` |
| Contactor status | HV vacuum contactor auxiliary contact | Slot 6 IB16 digital inputs | `HVPSCONTACT:*:STAT` group |
| `hvpstrig` (SCR enable command) | EPICS IOC via DH+ (SNL `HVPSONSUB`) | DH+ incoming data table → Slot 5 OX8 relay | Supervisory SCR enable gate; must be ON for HVPS to produce HV |

### 6.3 Outputs

| Output | Destination | Connection | Notes |
|--------|-------------|------------|-------|
| **SCR ENABLE relay** (`HVPSSCR:ON:CTRL`) | B514 SCR gate drivers | Slot 5 OX8 relay OUT → fiber optic cable → B514 | Supervisory HVPS enable path; ~20 ms speed; must be ON simultaneously with Fast IC SCR enable path |
| Ross grounding switch command | Ross Engineering HQ3 grounding switch | Slot 2 IO8 (120 VAC) | **PPS Chain 2**: grounds HV tank before personnel entry |
| HV vacuum contactor command | Ross Engineering HQ3 vacuum contactor | Slot 5 OX8 OUT2 → relay chain (K4 → MX → RR → L1) | **PPS Chain 1**: connects/disconnects 12.47 kV AC to HVPS primary (fail-safe open) |
| **HVPS DH+ status registers** | EPICS IOC (via AB-6008 scanner, Rack 2) | DH+ | All `HVPS*:*:LTCH` and `HVPS*:*:STAT` PVs populated from these registers |
| Voltage setpoint output | HVPS voltage control SCR firing angle | Slot 8–9 Analog I/O (AO) | SNL `rf_hvps_loop.st` writes ramp-controlled setpoint |

### 6.4 Rack Slot Configuration

| Slot | Module | Function |
|------|--------|---------|
| 0 | 1747-L532 CPU | Program execution |
| 1 | 1747-DCM | DH+ communication master for Rack 2 |
| 2 | IO8 (8-pt, 120 VAC) | Ross grounding switch output (PPS Chain 2) |
| 3 | Thermocouple input | HVPS temperature measurements |
| 5 | OX8 relay output | SCR ENABLE / HVPS control relay (see §6.6) |
| 6 | IB16 digital input | PPS enables, fiber-optic inputs from Fast IC |
| 8–9 | Analog I/O | HVPS voltage readback, current readback, setpoint output |

### 6.5 What the SLC-500 Interlocks On

The SLC-500 monitors every significant HVPS internal condition and exposes them as EPICS records via DH+. The full set of HVPS interlock sources, with their DH+ word/bit assignments from `rf_digital_All.substitutions,v`:

#### Category 1 — Electrical Faults

| PV | DH+ Card/Bit | Alarm | Description |
|----|-------------|-------|-------------|
| `{STN}:HVPS:CROWBAR:LTCH` | C12.9 | MAJOR | **Crowbar fired** — HVPS crowbar thyristor discharged; stored energy dumped |
| `{STN}:HVPS:VOLT:LTCH` | C14.1 | MAJOR | **Overvoltage** — DC output exceeded rated voltage |
| `{STN}:HVPSAC:CURR:LTCH` | C12.3 | MAJOR | **AC current trip** — primary AC current exceeded limit |
| `{STN}:HVPS:OPENLOAD:LTCH` | C14.9 | MAJOR | **Open load** — no current path to load (klystron disconnected or contactor open during energization) |
| `{STN}:HVPS:PANIC:LTCH` | C12.11 | MAJOR | **Emergency Off (PANIC)** — manual or automatic emergency shutdown latch |
| `{STN}:RFHVPS:CROWBAR:LTCH` | C14.11 | MAJOR | **RF crowbar request** — request from RF system to fire HVPS crowbar |

#### Category 2 — Oil System

| PV | DH+ Card/Bit | Alarm | Description |
|----|-------------|-------|-------------|
| `{STN}:HVPSOIL:LEVEL:LTCH` | C12.14 | MAJOR | **Oil level low** — insulating oil in HV tank below minimum |
| `{STN}:HVPSOIL:TEMP:LTCH` | C12.15 | MAJOR | **Oil temperature high** — insulating oil overtemperature |
| `{STN}:HVPSOIL:TEMP` | Analog (SLC-500 AI) | Monitored | Oil temperature value (°C); also has configurable ULIM at `{STN}:HVPSOIL:TEMP:ULIM` |

> **Design note**: HVPS oil temperature was removed from the `HVPSSTN:SUMY:LTCH` roll-up in the Sass 2004 revision (`rf_sumy_hvps.db,v` rev 1.2 log: "Remove HVPS oil temperature from HVPS summary. It remains in the overall temperature summary"). Oil temperature LTCH still contributes to `{STN}:HVPSTEMP:SUMY:LTCH` → `{STN}:STNTEMP:SUMY:LTCH` path.

#### Category 3 — Transformer / HV Tank

| PV | DH+ Card/Bit | Alarm | Description |
|----|-------------|-------|-------------|
| `{STN}:HVPSXFORM:ARC:LTCH` | C14.10 | MAJOR | **Transformer arc** — arc detector inside the HV transformer tank |
| `{STN}:HVPSXFORM:PRESS:LTCH` | C14.6 | MAJOR | **Transformer overpressure** — SF₆ or oil pressure in transformer enclosure exceeded limit |
| `{STN}:HVPSXFORM:VACM:LTCH` | C14.7 | MAJOR | **Transformer vacuum/pressure** — vacuum integrity or gas pressure fault |
| `{STN}:HVPSKLYS:ARC:LTCH` | C12.4 | MAJOR | **Klystron arc** (as seen from HVPS side) — arc current surge into cathode load |
| `{STN}:HVPS:TEMP:LTCH` | C14.0 | MAJOR | **Overtemperature** — general HVPS enclosure over-temperature |

#### Category 4 — Supply and Contactor Status

| PV | DH+ Card/Bit | Alarm | Description |
|----|-------------|-------|-------------|
| `{STN}:HVPS:PPS:STAT` | C14.8 | MAJOR on 0=NOPERMIT | **PPS Status** — PPS permit present (PERMIT=0, NOPERMIT=1 → alarm inverted) |
| `{STN}:HVPS12KV:VOLT:STAT` | C12.1 | MAJOR on 0=NOTAVAIL | **12 kV AC available** — primary 12.47 kV supply status |
| `{STN}:HVPSAC:POWER:STAT` | C12.2 | MAJOR on 0=OFF | **Auxiliary AC power** status |
| `{STN}:HVPSDC:POWER:STAT` | C12.10 | MAJOR on 0=OFF | **Auxiliary DC power** status |
| `{STN}:HVPSSUPPLY:ON:STAT` | C14.4 | MAJOR on 0=OFF | **HV supply on** status |
| `{STN}:HVPSSUPPLY:READY:STAT` | C14.5 | MAJOR on 0=NOTREADY | **HV supply ready** status |
| `{STN}:HVPSENERFAST:ON:STAT` | C12.12 | MAJOR on 0=OFF | **Fast inhibit** — energization fast inhibit active |
| `{STN}:HVPSENERSLOW:START:STAT` | C12.13 | MAJOR on 1=INACTIVE | **Slow start** — energization slow-start sequencer |
| `{STN}:HVPSCONTACT:CLOSE:STAT` | C12.5 | MAJOR on 0=OPEN | HV contactor close status |
| `{STN}:HVPSCONTACT:ON:STAT` | C12.6 | MAJOR on 0=OFF | HV contactor on status |
| `{STN}:HVPSCONTACT:OPEN:STAT` | C12.7 | MAJOR on 1=OPEN | HV contactor open status |
| `{STN}:HVPSCONTACT:READY:STAT` | C12.8 | MAJOR on 0=NOTREADY | HV contactor ready |
| `{STN}:HVPSSCR1:ON:STAT` | C14.2 | MAJOR on 0=OFF | SCR bank 1 on status |
| `{STN}:HVPSSCR2:ON:STAT` | C14.3 | MAJOR on 0=OFF | SCR bank 2 on status |

> **Note on DH+ addressing**: "C12.9" means Card (output word) 12, bit 9. Word 12 = physical I/O module card 12÷2 = slot 6. The SLC-500 uses 8-bit word addressing where adjacent card pairs share a 16-bit word.

#### Category 5 — Analog Monitoring

| PV | Source | Alarm Limits | Description |
|----|--------|-------------|-------------|
| `{STN}:HVPS:VOLT` | SLC-500 AI | HIHI=87, HIGH=85 kV | HVPS DC output voltage |
| `{STN}:HVPS:CURR` | SLC-500 AI | HIHI=30, HIGH=30 A | HVPS DC output current |
| `{STN}:HVPS:PLC:VOLT` | SLC-500 AI word 30 | ±100 kV range | Voltage readback from PLC (independent ADC) |
| `{STN}:HVPS:PLC:CURR` | SLC-500 AI word 31 | ±50 A range | Current readback from PLC (independent ADC) |
| `{STN}:HVPSAC:CURR` | SLC-500 AI | Monitored | Primary AC current |
| `{STN}:HVPSOIL:TEMP` | Thermocouple slot 3 | ULIM configurable | Oil temperature (°C) |

### 6.6 SCR Enable Relay — The HVPS Supervisory Enable Path

The SLC-500 controls the HVPS SCR bank through a relay in Rack 2 Slot 5 (OX8 relay output, OUT port). This is the **supervisory SCR ENABLE path** — it must be held closed for the HVPS to maintain output voltage.

```
SNL rf_states.st HVPSONSUB() macro
    └── pvPut(hvpstrig, ON)
        └── {STN}:HVPSSCR:ON:CTRL = 1
            └── DH+ → SLC-500 Rack2
                └── OX8 relay OUT closed
                    └── Fiber optic cable → B514
                        └── SCR gate driver enable
```

This path is **distinct from** the Fast Interlock Chassis SCR ENABLE path:

| Path | Speed | Source | Notes |
|------|-------|--------|-------|
| Fast IC → SCR ENABLE (fiber) | < 1 μs | Fast Interlock Chassis trip | Hardware trip, opens on fault |
| SLC-500 relay → SCR ENABLE (fiber) | ~20 ms | Supervisory enable/disable | Must be explicitly enabled; cleared in s_go_off |

Both paths use fiber optic to B514. **Both** must be asserted for the HVPS SCR to conduct. The Fast IC path is the fast-trip path; the SLC-500 relay path is the supervisory gate that must be deliberately enabled by the SNL state machine as part of the startup sequence.

> **PV**: `{STN}:HVPSSCR:ON:CTRL` (bo record, `rf_hvps.db,v`): "HVPS SCR Enable Switch". Writing ON enables the HVPS; writing OFF disables (part of s_go_off orderly shutdown).

### 6.7 HVPS Alarm Aggregation Tree

```
{STN}:HVPSSTN:SUMY:LTCH
    ├── INPA: HVPSAC:CURR:LTCH      (AC overcurrent)
    ├── INPB: HVPSKLYS:ARC:LTCH    (klystron arc from HVPS side)
    ├── INPC: HVPS:CROWBAR:LTCH    (crowbar fired)
    ├── INPD: HVPS:PANIC:LTCH      (emergency off)
    ├── INPE: HVPSTEMP:SUMY:LTCH   (oil temp + general temp)
    │         └── INPA: HVPS:TEMP:LTCH      (general overtemp)
    │             INPB: HVPSOIL:TEMP:LTCH   (oil overtemp)
    ├── INPF: HVPSOIL:LEVEL:LTCH   (oil level low)
    ├── INPG: HVPSXFORM:ARC:LTCH   (transformer arc)
    ├── INPH: HVPSXFORM:PRESS:LTCH (transformer overpressure)
    ├── INPI: HVPSXFORM:VACM:LTCH  (transformer vacuum/pressure)
    ├── INPJ: HVPS:VOLT:LTCH       (DC overvoltage)
    └── INPK: HVPS:OPENLOAD:LTCH  (open load)

{STN}:HVPSOFF:SUMY:STAT    →    feeds STNOFF:SUMY:STAT.INPB
    ├── INPE: HVPSCONTACT:SUMY:STAT   (contactor status)
    ├── INPH: HVPSSTN:SUMY:STAT       (operational status summary)
    └── INPI: HVPSSTN:SUMY:LTCH       (latched fault summary)

{STN}:HVPS:SUMY:LTCH
    ├── INPB: HVPSCONTACT:SUMY:STAT
    ├── INPD: HVPSSTN:SUMY:LTCH
    ├── INPE: HVPSAC:POWER:STAT       (AC power available)
    ├── INPF: HVPSDC:POWER:STAT       (DC auxiliary power)
    ├── INPG: HVPS:PPS:STAT           (PPS permit)
    ├── INPH: HVPS12KV:VOLT:STAT      (12 kV AC)
    └── INPI: HVPSSUPPLY:READY:STAT   (supply ready)
```

### 6.8 PPS Dual-Chain Architecture (Contactor and Grounding Switch)

| | **Chain 1 — HV Vacuum Contactor** | **Chain 2 — Ross Grounding Switch** |
|---|---|---|
| **Safety function** | Disconnect 12.47 kV AC primary power from HVPS | Ground the HVPS HV bus (−77 kV) for safe personnel access |
| **SLC-500 output** | Slot-5 OX8 OUT2 relay contact → K4 → MX → L1 relay chain | Slot-2 IO8 OUT3 (120 VAC) → Ross switch coil |
| **PLC rung** | Rung 0017 (mislabeled "Crowbar On" on original drawing — corrected to "Contactor Enable") | Rung 0016 (Ross switch enable) |
| **PPS input** | PPS 1 (GOB12-88PNE Pin E→F) | PPS 2 (GOB12-88PNE Pin G→H) |
| **Operating state** | Coil held energized (contactor **CLOSED** — 12.47 kV connected) | Coil held energized (switch held **OPEN** — HV bus not grounded) |
| **Fail-safe state** | PPS removed → K4 drops → L1 drops → contactor **spring-opens** → 12.47 kV disconnected | PPS removed → 120 VAC removed → switch **spring-closes** → HV bus grounded |
| **Readback signal** | S5 NC auxiliary contact → GOB12-88PNE Pins A-B | Ross switch NC auxiliary contact → GOB12-88PNE Pins C-D |
| **Readback meaning** | Pins A-B shorted = contactor OPEN (12.47 kV removed, safe) | Pins C-D shorted = switch CLOSED (HV bus grounded, safe) |

#### Chain 1 — HV Vacuum Contactor Relay Path

The full relay chain from PPS to contactor, as routed through the SLC-500. This is the personnel-safety path described in `L_LEGACY_SYSTEM_ARCHITECTURE.md` §13.

```
PPS Enable (GOB12-88PNE, Pin E→F)
    → SLC-500 Slot-6 IB16 Input 14
    → PLC Rung 0017 (ladder logic)
    → Slot-5 OX8 OUT2
    → Terminal Strip TS-5 → switchgear cable
    → K4 relay (PPS control)
    → MX relay (external operational enable)
    → RR relay (reset latch)
    → L1 holding coil
    → Ross Engineering HQ3 vacuum contactor
      (connects/disconnects 12.47 kV AC to HVPS primary)
```

#### Chain 2 — Ross Grounding Switch

```
PPS 2 Enable (GOB12-88PNE Pin G→H)
    → SLC-500 PLC Slot-6 IB16 Input 15
    → PLC Rung 0016 (Ross switch enable)
    → Slot-2 IO8 OUT3 (120 VAC)
    → TS-6 → Belden 83709 cable → Termination Tank
    → Ross Grounding Switch coil

Readback: Ross Switch NC Aux → TS-6 pins 11,12 → GOB12-88PNE Readback C-D
```

> **Critical design issue**: The PPS chain routes through SLC-500 ladder logic — a programmable device is in the personnel safety chain. This does not meet modern PPS standards (SLAC ES&H). Flagged in `L_LEGACY_SYSTEM_ARCHITECTURE.md` §13.4.

#### Fail-Safe Directions

Both chains are designed so that removing electrical power drives them to the personnel-safe state:

- **Chain 1** (contactor): Operator/PPS removes PPS 1 → K4 relay de-energizes → holding coil L1 loses drive → vacuum contactor spring-opens → 12.47 kV AC is removed from the HVPS primary transformer. A power loss anywhere in the relay chain produces the same outcome.
- **Chain 2** (grounding switch): Operator/PPS removes PPS 2 → PLC Rung 0016 no longer energizes 120 VAC output → Ross switch coil de-energizes → switch spring-closes → HVPS HV bus is grounded. A power loss to the PLC or 120 VAC supply produces the same outcome.

Both readbacks use **NC (normally-closed) auxiliary contacts**, meaning the readback circuit is closed (complete) only when the device is at its safe-access state. A broken wire or failed contact reads as "unsafe" — fail-safe readback.

#### Safe-Access Operational Sequence

Personnel access to the SSRL tunnel requires both chains in their safe state **in the correct order**:

```
SHUTDOWN for personnel entry:
  1. PPS 1 removed → Rung 0017 drops → contactor opens → 12.47 kV disconnected
  2. HVPS energy dissipates (capacitor discharge through load)
  3. PPS 2 removed → Rung 0016 drops → Ross switch closes → HV bus grounded
  4. Readbacks A-B and C-D loop complete → PPS confirms both chains safe
  5. Personnel entry permitted

RESTORE after personnel exit:
  1. Personnel withdraw; PPS confirms exclusion at entry points
  2. PPS 2 restored → Rung 0016 energized → Ross switch opens (HV bus un-grounded)
  3. PPS 1 restored → Rung 0017 energized → K4 → contactor closes → 12.47 kV restored
  4. Normal HVPS startup sequence may proceed
```

> **Critical**: The contactor (Chain 1) must be OPEN and HVPS fully discharged **before** the grounding switch (Chain 2) closes onto the HV bus. Closing a grounding switch onto a live high-voltage bus would produce a catastrophic high-energy arc fault. The site PPS system enforces correct sequencing at the machine level through PPS permitting logic.

#### Compliance Comparison

| | **Chain 1** | **Chain 2** |
|---|---|---|
| **Compliance issue** | PPS 1 routes through SLC-500 Rung 0017 | PPS 2 routes through SLC-500 Rung 0016 |
| **Hardware fail-safe** | **Present** — OX8 relay input side is wired directly to PPS 1 signal (24VDC from GOB12-88PNE Pin E). Even if the PLC closes the output contact, K4 coil cannot energize without PPS 1 voltage physically present. | **Absent** — PLC drives 120 VAC directly to Ross switch coil via IO8 OUT3. If PLC fails energized (maintains 120 VAC output despite PPS 2 removal), the Ross switch remains held open (un-grounded) without a PPS 2 command. |
| **Failure mode concern** | PLC closes OX8 spuriously → K4 cannot energize (no PPS 1 voltage) → **no hazard** | PLC maintains 120 VAC spuriously → Ross switch stays open → **HV bus not grounded when PPS removed** |

> **Chain 2 is the higher-priority compliance concern.** The spring-return mechanism provides a fail-safe against total power loss, but does not protect against a PLC output failure that maintains the coil energized. The upgrade architecture (see `pps/diagrams/00_SYSTEM_OVERVIEW.md`) eliminates this by providing direct PPS control of both chains through the Interface Chassis, bypassing the PLC for safety-critical permitting.

> **Sources**: [R25] (detailed wiring); `pps/diagrams/00_SYSTEM_OVERVIEW.md`; `pps/diagrams/07_PLC_CODE_AND_LOGIC.md`; `pps/diagrams/08_CORRECTED_HAND_DRAWING.md`.

---

## Part VII — SNL State Machine (`rf_states.st`)

### 7.1 Inputs

| Input PV | Source | Connection | Role |
|----------|--------|------------|------|
| `{STN}:STNOFF:SUMY:STAT.SEVR` (`fault_stnoff`) | EPICS alarm aggregation tree (`rf_sumy_stn.db`) | EPICS CA `pvMonitor` | **Master trip wire** — any MAJOR alarm propagated here triggers `s_go_off` |
| `{STN}:HVPS:VOLT` (`hvpsvoltrd`) | SLC-500 AI (DH+ word 30) | EPICS CA `pvGet` | HVPS voltage readback for ramp control |
| `{STN}:HVPS:CURR` | SLC-500 AI (DH+ word 31) | EPICS CA `pvGet` | HVPS current readback |
| `{STN}:STN:AIM:ARCLTDSTT` | AIM ARCLTDSTT register | EPICS CA `pvMonitor` | Arc latched status — used to distinguish arc fault from other faults |
| `{STN}:STN:FORCED:LTCH` (`forced_fault`) | AIM first-fault register bit | EPICS CA `pvMonitor` | Hard arc latch — blocks auto-reset |
| `{STN}:HVPSOFF:SUMY:STAT` | EPICS HVPS alarm tree | EPICS CA `pvMonitor` | HVPS off/fault status, feeds `fault_stnoff` |
| `{STN}:STN:LOCAL:ON` | Local panel switch | EPICS CA | Local/remote mode; local mode forces OFF |
| `{STN}:STN:STATE` (`stnstate`) | EPICS state PV | EPICS CA | Station state (restored at boot in `s_init`) |
| `{STN}:HVPSSCR:ON:CTRL` readback | DH+ readback from SLC-500 | EPICS CA | SCR enable relay state confirmation |
| TAXI/GVF status (via `rf_msgs.st`) | GVF module software PVs | EPICS inter-IOC | TAXI error monitoring; triggers resync if TAXI errors detected |

### 7.2 Outputs

| Output PV | Destination | Action |
|-----------|-------------|--------|
| `{STN}:STN:AIM:FRCBMABT` (`fba`) | AIM `MODU.FBA` → SPEAR3 machine MPS | Force Beam Abort — fires injection kicker; set in `s_go_off` Step 1 |
| `{STN}:STN:AIM:MODU.RBA` (`rba`) | AIM `MODU.RBA` → SPEAR3 machine MPS | Reset Beam Abort — de-asserts beam abort during recovery |
| `{STN}:STN:AIM:MODU.RSTF` (`rstf`) | AIM hardware latches | Resets all AIM arc latches and fast interlock latches |
| `{STN}:STN:AIM:MODU.HVPS` (`aimon`) | AIM fiber optic HVPS_On output | Hardware gate for HVPS energization; set in `HVPSONSUB` |
| `{STN}:HVPSSCR:ON:CTRL` (`hvpstrig`) | SLC-500 DH+ → Slot 5 OX8 relay → B514 SCR | Supervisory SCR ENABLE gate; ON in `HVPSONSUB`, OFF in `s_go_off` Step 5 |
| `{STN}:HVPS:VOLT:SP` (`hvpswdefault`) | SLC-500 DH+ → Analog output → SCR firing angle | HVPS voltage setpoint; set to 0 in `s_go_off` Step 3 |
| `{STN}:STN:RFP:RFENABLE` (`rfswitch`) | RFP module RF drive enable | RF drive gate; ON in `HVPSONSUB`, OFF in `s_go_off` Step 6 |
| `{STN}:STN:STATE` (`stnstate`) | EPICS state display PV | Operator state display: OFF/PARK/TUNE/ON_FM/ON_CW |
| `{STN}:STN:INTCOMP` (`intcomp`) | RFP/IQA integrator compensation | Direct feedback integrator; disabled in `s_go_off` Step 7 |
| `ef_set(ffwrite_ef)` | `ss rf_statesFF` event flag | Triggers fault waveform capture state set in `s_go_off` Step 8 |

### 7.3 Architecture

The SNL state machine (`rf_states.st`, 2,227 lines, 3 concurrent state sets) is the **software coordination layer**. It does not provide fast protection — by the time `fault_stnoff` changes, all hardware trips have already fired. Its roles are:

1. **Orderly shutdown** — ramp HVPS to zero before removing SCR enable (protects the HV capacitors/diodes from abrupt current interruption)
2. **Fault recording** — capture of 11 signal channel waveforms to circular buffer
3. **Recovery sequencing** — managed restart with `forced_fault` and auto-reset logic
4. **Operator state interface** — OFF/PARK/TUNE/ON_FM/ON_CW state display
5. **BATS management** — force/reset beam abort in the correct sequence

### 7.4 The Single Trip Wire: `fault_stnoff`

```
{STN}:STNOFF:SUMY:STAT.SEVR  (monitored as fault_stnoff in rf_states.st)

Inputs (from rf_sumy_stn.db record):
    INPA: {STN}:STNPARK:SUMY:STAT     ← VXI latch summary
               └── {STN}:STN:VXI:LTCH (AIM fast interlock bits)
    INPB: {STN}:HVPSOFF:SUMY:STAT     ← HVPS fault/status
    INPC: {STN}:STN:LOCAL:ON           ← Local/remote panel state
    INPD: {STN}:STN:ABSUMY:LTCH       ← DH+ AB communication summary latch
    INPE: {STN}:STN:SUMY:PLC           ← PLC module status summary
```

Any input going MAJOR alarm propagates (via EPICS `MS` = Maximize Severity) to `STNOFF:SUMY:STAT.SEVR`. Every ON state checks this:

```snl
/* In s_on_cw, s_tune, s_on_fm */
when (fault_stnoff != NO_ALARM) {
    fault_detected = 1;
} state s_go_off
```

### 7.5 STNMPS Alarm Tree (SPEAR3-specific, `rf_sumy_stn_spr.db`)

The SPEAR3-specific MPS summary aggregates into the station trip path:

```
{STN}:STNMPS:SUMY:LTCH
    INPB: {STN}:STN:FORCED:LTCH    (AIM forced fault latch)
    INPC: {STN}:STN:VXI:LTCH       (AIM fast interlock status bits)
    INPE: {STN}:STN:NCV:PLC        (no-current-value PLC)
    INPF: {STN}:STNREF:POWER:LTCH  (476 MHz reference power)
    INPG: {STN}:STNCRATEPS:TEMP:LTCH (VXI crate power supply temperature)
    INPH: {STN}:STN:RF476MHZREF:LTCH (476 MHz reference status)
    INPI: {STN}:STN:MPS:LTCH        (RF MPS PLC permit)
```

### 7.6 Orderly Shutdown Sequence (`s_go_off`)

```
State s_go_off (entered when fault_stnoff != NO_ALARM in any ON state):

Step 1: TUNESUB()
    fba = 1   pvPut(fba)        → {STN}:STN:AIM:FRCBMABT = 1
                                   → MODU.FBA asserted → BATS fired (beam abort)
    runmode = TUNE               → puts IQA/RFP in tune mode (low drive)

Step 2: setiqtune()              → zero I/Q drive setpoints

Step 3: pvPut(hvpswdefault, 0)  → write 0 to HVPS voltage setpoint
                                   rf_hvps_loop.st ramps voltage down

Step 4: taskDelay(300)           → ~5 second wait for HVPS to discharge

Step 5: hvpstrig = OFF   pvPut(hvpstrig)
    → {STN}:HVPSSCR:ON:CTRL = 0  → DH+ → SLC-500 Rack2
    → SCR gate drive disabled from supervisory path

Step 6: rfswitch = OFF   pvPut(rfswitch)
    → {STN}:STN:RFP:RFENABLE = 0 → RF drive enable explicitly removed

Step 7: intcomp = OFF    pvPut(intcomp)
    → Direct feedback integrator compensation disabled

Step 8: efSet(ffwrite_ef)        → triggers ss rf_statesFF (fault file capture)

Step 9: → state s_off
```

### 7.7 HVPS Startup Sequence (HVPSONSUB macro)

```snl
/* executed inside s_go_on_cw when transitioning to ON_CW */
HVPSONSUB():
    rfswitch = ON          pvPut(rfswitch)   → RF drive enabled
    pvGet(hvpswdefault)                       → read default voltage setpoint
    /* call TUNESUB to home tuners */
    hvpstrig = ON          pvPut(hvpstrig)   → SCR gate drive enabled via DH+
    aimon = ON             pvPut(aimon)       → write {STN}:STN:AIM:MODU.HVPS = 1
                                                → AIM fiber "HVPS_On" asserted
    /* wait up to 10 s checking fault_stnoff */
```

The `aimon` write is a **hardware interlock gate**: the AIM module physically holds its "HVPS_On" fiber output LOW until the IOC writes a 1 to `MODU.HVPS`. This ensures the HVPS cannot be energized unless the software state machine has explicitly authorized it.

### 7.8 BATS Reset (`RESET_BMABTSUB`)

```snl
/* RESET_BMABTSUB(fault) — called during recovery */
if (fault == NO_ALARM) {
    fba = 0;    pvPut(fba)    → de-assert Force Beam Abort
    pvPut(rba)                 → Reset Beam Abort (MODU.RBA)
    pvPut(rstf)                → Reset Faults (MODU.RSTF — clears all arc latches)
}
```

### 7.9 `forced_fault` Latch — Blocking Auto-Reset

`{STN}:STN:FORCED:LTCH` is set by AIM hardware on detection of a severe arc event. When this latch is set:

1. `{STN}:STNMPS:SUMY:LTCH.INPB` is MAJOR → contributes to `STNOFF:SUMY:STAT`
2. In `s_go_stn_reset` (auto-reset state):
   ```snl
   when (forced_fault != NO_ALARM) {
       /* exit without reset attempt */
   } state s_off
   ```
3. The station stays locked in `s_off` until an operator physically presses the **FAULT RESET** button on the Fast Interlock Chassis front panel — this clears the AIM hardware latch and de-asserts `forced_fault`

This was a SPEAR3-specific customization (Sass comment 2004: *"SPEAR is using forced fault to trip the station under certain conditions"*) to prevent automatic recovery after hard arcs.

---

## Part VIII — Fault Event Timeline

### 8.1 Example: Waveguide Arc

```
t = 0 ns        Arc breakdown at cavity waveguide window:
                → fiber-optic light pulse arrives at Fast Interlock Chassis

t < 1 μs        Fast IC analog comparator fires:
                → SCR ENABLE removed (fiber optic → B514)
                  HVPS SCR stops conducting; HV output begins to collapse
                → CROWBAR fired (fiber optic → B514)
                  Crowbar thyristor shorts HV output; stored cap energy
                  dumps into crowbar resistor (not klystron cathode)
                → Status word updated → AIM module received

t < 1 μs        AIM hardware asserts RF_FAULT on VXI P2 backplane:
                → RFP module (Slot 4) monitors RF_FAULT pin directly
                  RF drive DAC output zeroed in hardware
                  RF power into klystron collapses

t ≈ 5–50 μs     AIM ISR fires:
                → Reads ARCLTDSTT latch register (not ISR register — retains fault)
                → forced_fault latch set if arc current exceeded threshold
                → scanOnce({STN}:STN:AIM:MODU)

t ≈ 50–500 μs   EPICS IOC processes AIM:MODU record:
                → FANO1/2/3 fanout updates ARCCURSTT, ARCLTDSTT, FSTFLT records
                → {STN}:STN:VXI:LTCH goes MAJOR
                → {STN}:STNMPS:SUMY:LTCH propagates (MS) → STNOFF:SUMY:STAT MAJOR

t ≈ 10–15 ms    MPS PLC (ControlLogix) next scan cycle:
                → Detects fault via DH+ status or hardwired arc monitor
                → De-energizes relay → removes hardwired permit to Fast IC
                  (Fast IC already fired at t<1μs; this is PLC-level confirmation)
                → Writes STN:MPS:LTCH bit OFF in DH+ output table

t ≈ 20 ms        SLC-500 detects HVPS crowbar event:
                → Updates HVPS:CROWBAR:LTCH = FAULT in DH+ registers
                → HVPSSTN:SUMY:LTCH → HVPSOFF:SUMY:STAT → STNOFF:SUMY:STAT

t ≈ 1 s          SNL rf_states.st detects fault_stnoff != NO_ALARM:
                → fault_detected = 1
                → Transitions from s_on_cw → s_go_off state

t ≈ 1.0–1.1 s   s_go_off Step 1: TUNESUB()
                → fba = 1 (BATS fired from software side to confirm beam abort)
                → runmode = TUNE

t ≈ 1.1–6 s     s_go_off Steps 2–4: HVPS voltage setpoint → 0
                → rf_hvps_loop.st ramps HVPS voltage down to zero
                → ~5 s wait for capacitor bank to discharge

t ≈ 6 s         s_go_off Steps 5–7:
                → hvpstrig = OFF (SCR supervisory enable removed via DH+)
                → rfswitch = OFF (RFP drive enable removed)
                → intcomp = OFF

t ≈ 6–10 s      ss rf_statesFF: Fault file capture
                → 11 signal channels × /dat/FAULT*_N (N = 1–15 circular)
                → Max 3.6 s for capture to complete

t > 10 s        State machine in s_off; operator notified via EPICS alarm
```

### 8.2 Example: RF MPS PLC Trip — Cooling Water Overtemperature

This example illustrates a **slow equipment-protection fault** picked up by the RF MPS PLC (ControlLogix). No arc occurs, no hardware trip fires first — the PLC is the first actor.

```
t = 0 s         Cooling water return temperature sensor reads at scan interval:
                → Exceeds maximum setpoint continuously for N scan cycles
                  (debounce / confirmation prevents spurious trips)

t ≈ 10–30 ms    RF MPS PLC scan cycle completes:
                → PLC program sets cooling overtemperature fault flag
                → Relay output de-energizes (Path A):
                  Removes MPS permit hardwired to Fast Interlock Chassis

t ≈ 10–15 ms    Fast Interlock Chassis responds to permit loss:
                → Treats permit removal as fault condition
                → SCR ENABLE removed (fiber optic → B514)
                  HVPS SCR stops conducting; HV output begins to collapse
                → CROWBAR fired (fiber optic → B514)
                  Crowbar thyristor shorts HV output
                → Fast IC sends updated status word → AIM module

t < 1 μs (after relay) 
                AIM hardware responds to Fast IC status:
                → Asserts RF_FAULT on VXI P2 backplane (open-collector)
                → RFP module (Slot 4) monitors RF_FAULT
                  RF drive DAC output zeroed in hardware
                  RF power into klystron collapses

                VXI Slot 5 MPS Shutoff module responds simultaneously (Path C):
                → Also asserts RF_FAULT on VXI P2 backplane
                  (redundant with AIM assertion above)

t ≈ 5–50 μs     AIM ISR fires:
                → Reads FISTAT latch register (Sass 2004 fix)
                → scanOnce({STN}:STN:AIM:MODU) scheduled

t ≈ 10–30 ms    PLC writes permit bit OFF to DH+ output table (Path B):
                → AB-6008 scanner reads at ~1 Hz
                → {STN}:STN:MPS:LTCH → MAJOR alarm set

t ≈ 50–500 ms   EPICS propagates alarm:
                → {STN}:STNMPS:SUMY:LTCH.INPI = MAJOR
                → {STN}:STNOFF:SUMY:STAT.SEVR = MAJOR

t ≈ 1 s          SNL rf_states.st detects fault_stnoff != NO_ALARM:
                → Transitions s_on_cw → s_go_off

t ≈ 1.0–6 s     s_go_off orderly shutdown:
                → Step 1: fba = 1 (BATS fired from software side)
                → Steps 2–4: HVPS voltage setpoint → 0; ~5 s ramp
                  (Fast IC crowbar already discharged the capacitors)
                → Step 5: hvpstrig = OFF (SCR supervisory enable removed)
                → Step 6: rfswitch = OFF (RF drive enable removed)

t ≈ 6–10 s      ss rf_statesFF: Fault file capture
                → 11 signal channels → /dat/FAULT*_N files

t > 10 s        State machine in s_off
                → EPICS operator display shows MPS trip: STN:MPS:LTCH = FAULT
                → No forced_fault latch set (cooling fault, not arc)
                → Auto-reset allowed once fault clears (cooling temp returns to normal)
                → Operator may allow auto-recovery or command manual restart
```

> **Key features of this type of trip**: (1) The PLC is the first actor (~10–30 ms). (2) The HVPS is fully shut down via Path A (Fast IC SCR ENABLE + CROWBAR) — the Slot 5 module adds RF cut redundancy but no HVPS action. (3) No `forced_fault` latch is set, so SNL auto-reset may proceed after cooling fault clears. (4) The fault is identifiable by `{STN}:STN:MPS:LTCH = FAULT` with a normal (empty) `ARCLTDSTT` register.

---

### 8.3 Example: HVPS PLC Trip — High-Voltage Transformer Arc

This example illustrates a **HVPS internal fault** monitored by the SLC-500 HVPS PLC. The fault occurs inside the high-voltage transformer/oil tank at B514 — no RF waveguide arc, no MPS PLC involvement.

```
t = 0 ms        Arc discharge inside the HV transformer tank (B514):
                → Arc detector sensor inside HV tank registers arc current surge
                → If arc is energetic enough: crowbar may self-fire via
                  analog crowbar trigger circuit (independent of HVPS PLC)

t ≈ 10–20 ms    SLC-500 HVPS PLC scan cycle (B118):
                → Reads arc detector digital input:
                  Slot 6 IB16 input: C14.10 = HVPSXFORM:ARC:LTCH = FAULT
                → PLC ladder logic sets HVPS fault state
                → Slot 5 OX8 relay: SCR ENABLE relay OPENED
                  (supervisory SCR enable path removed from B514 SCR gate driver)
                → DH+ output table updated with fault status

t ≈ 10–20 ms    SCR ENABLE removed via SLC-500 supervisory path:
                → Fiber optic to B514 SCR gate driver enable
                → HV output begins to collapse (no gate drive on SCR thyristors)
                → B514 HVPS power section self-protection responds:
                  B514 drops its STATUS fiber signal (STATUS fiber → B132 Fast IC)
                → Fast IC records HVPSON = 0 in FISTAT register (bit 6)
                → AIM reads FISTAT on next processing: HVPSON=0 is noted
                NOTE: Fast IC does NOT fire SCR ENABLE removal or CROWBAR
                in response to HVPSON going low. The HVPS is already being
                shut down. HVPSON=0 is INFORMATIONAL — it gates the AIM's
                arc voltage history buffer readout (skipped when HVPS is off).

t ≈ 100 ms–1 s  EPICS alarm propagation:
                → AB-6008 scanner reads DH+ at ~1 Hz
                → {STN}:HVPSXFORM:ARC:LTCH = MAJOR
                → {STN}:HVPSSTN:SUMY:LTCH.INPG = MAJOR (transformer arc links in)
                → {STN}:HVPSOFF:SUMY:STAT = MAJOR
                → {STN}:STNOFF:SUMY:STAT.SEVR = MAJOR (via INPB)

t ≈ 1 s          SNL rf_states.st detects fault_stnoff != NO_ALARM:
                → Transitions s_on_cw → s_go_off

t ≈ 1.0–1.1 s   s_go_off Step 1: TUNESUB()
                → fba = 1 (BATS fired to confirm beam abort)
                → runmode = TUNE

t ≈ 1.1–6 s     s_go_off Steps 2–4: HVPS voltage setpoint → 0
                → rf_hvps_loop.st attempts HVPS voltage ramp down
                  (HVPS is already de-energized via SLC-500 SCR relay;
                  ramp command is a no-op but the sequence must complete)
                → ~5 s wait

t ≈ 6 s         s_go_off Steps 5–7:
                → hvpstrig = OFF (SCR supervisory enable again confirmed OFF)
                → rfswitch = OFF (RF drive enable removed)
                → intcomp = OFF

t ≈ 6–10 s      ss rf_statesFF: Fault file capture
                → Waveform data captured to /dat/FAULT*_N files
                NOTE: Fault occurred in HVPS tank at B514; signal content
                in fault files shows the RF state at the time of HVPS collapse

t > 10 s        State machine in s_off
                → Operator alarms: HVPSXFORM:ARC:LTCH and HVPSSTN:SUMY:LTCH
                → HVPS must be inspected before restart
                → No arc in RF waveguide: ARCLTDSTT = 0, FSTFLT = 0
                → No forced_fault latch (this is HVPS path, not Fast IC/AIM arc)
                → Recovery requires: clearing HVPS arc latch, verifying HVPS
                  oil/insulation condition, then normal restart sequence
```

> **Key features of this type of trip**: (1) The SLC-500 HVPS PLC is the first actor (~10–20 ms); the RF MPS PLC and Fast IC are not involved. (2) HVPS shutdown is via the **SLC-500 supervisory SCR relay** (§6.6 path) — this is distinct from the Fast IC SCR ENABLE path. (3) The B514 HVPS power section drops its STATUS fiber when it begins to collapse; the Fast IC records `HVPSON=0` in its `FISTAT` register and reports it to AIM — but this is **status reporting only**, not a Fast IC hardware trip. (4) **RF drive shutdown signal chain**: There is no direct hardware path from the SLC-500 HVPS PLC trip to the RFP module RF drive. The RF drive remains asserted at the software level until `s_go_off` Step 6 writes `rfswitch = OFF` at approximately t ≈ 6 s after the initial trip. During the intervening period the klystron cathode HV has already collapsed — the klystron produces no RF output even with drive signal still applied, because klystron amplification requires cathode high voltage. This is safe but the indirection must be understood. See §9.6 for the complete RF shutdown signal trace for this scenario. (5) Fault files capture the RF/IQA signal waveform at HVPS collapse time. (6) The `HVPSXFORM:ARC:LTCH` bit identifies the source; `ARCLTDSTT = 0` and `FSTFLT = 0` confirm no waveguide arc was involved.

---

### 8.4 Recovery Sequence

```
Operator observes fault via EPICS display
    → Checks fault files (/dat/FAULT*_N for latest fault slot)
    → Identifies fault channel (ARCLTDSTT bit, FSTFLT word, etc.)

Physical action:
    → Presses FAULT RESET on Fast Interlock Chassis front panel
      → Clears hardware arc latches in AIM module
      → Clears forced_fault latch
      → ARCLTDSTT bits cleared
      → {STN}:STN:FORCED:LTCH → OK → STNMPS:SUMY:LTCH clears

EPICS action:
    → fault_stnoff returns to NO_ALARM when all faults clear
    → Operator commands station to ON via EPICS display

SNL response:
    → s_off → s_go_park → s_go_tune → s_go_on_cw
    → HVPSONSUB():
        rfswitch = ON
        hvpstrig = ON  → SLC-500 Rack2 relay closes → SCR gate drive enabled
        aimon = ON     → AIM "HVPS_On" fiber output asserted
    → RESET_BMABTSUB():
        fba = 0 → rba → rstf  (BATS reset, arc hardware latches cleared)
    → Station climbs to ON_CW
```

---

## Part IX — Key Cross-Layer Interactions

### 9.1 AIM `aimon` ↔ SLC-500 Hardware Gate

The `aimon` write (`{STN}:STN:AIM:MODU.HVPS = 1`) sets the AIM "HVPS_On" fiber optic output. This is a **hardware interlock gate** — the SLC-500 HVPS controller cannot energize the HV supply unless the AIM has asserted this fiber signal. This cross-link means:

- The SNL state machine must explicitly authorize HVPS energization (via `HVPSONSUB`)
- If the software is not in the ON transition sequence (e.g., the IOC is dead), AIM holds this output LOW and HVPS cannot be energized

In the fault path, `aimon` is NOT explicitly cleared in `s_go_off` — the hardware trip (SCR ENABLE removed by Fast IC + SLC-500 `hvpstrig=OFF`) has already shut down the HVPS. The explicit `aimon=ON` is only needed at startup.

### 9.2 `forced_fault` Anti-Auto-Reset

Without `{STN}:STN:FORCED:LTCH`, the auto-reset state (`s_go_stn_reset`) would retry `reset_count` times automatically. With `forced_fault = MAJOR`, the auto-reset loop exits immediately to `s_off`, requiring operator intervention. This prevents the HVPS from automatically re-energizing after a hard arc event — critical for SPEAR3 where arc repetition can damage cavity surfaces.

### 9.3 VXI Interlock Latch Register Fix (2004)

Before January 2004, VXI interlock bits were read from the AIM interrupt status register (ISR). EPICS processed the AIM:MODU record continuously, and each read cleared the ISR — a latched fault could be invisible to the alarm system because it self-cleared between EPICS scans. Sass changed `rf_interlock_vxi.db` (rev 1.2, Jan 2004) to read from the AIM **fast interlock status/latch register**, which holds bits until the hardware FAULT RESET button is pressed. **This is a critical reliability fix** — without it, the software alarm chain would miss fast faults.

### 9.4 Dual SCR Enable Paths — Supervisory vs. Fast

The HVPS SCR bank has two independent enable paths that operate in different domains:

| Path | Owner | Speed | Set by | Cleared by |
|------|-------|-------|--------|-----------|
| Fast IC → fiber → B514 SCR | Hardware interlock | < 1 μs | Normal (held enable) | Fast IC fault trip |
| SLC-500 relay → fiber → B514 SCR | Supervisory enable | ~20 ms | SNL `hvpstrig=ON` in `HVPSONSUB` | SNL `hvpstrig=OFF` in `s_go_off` |

The SLC-500 relay is the **supervisory gate** — it deliberately enables the HVPS at the beginning of the startup sequence and is the controlled OFF path during orderly shutdown. The Fast IC path is the **fast-trip gate** — always held enabled during normal operation, trips open on fault. Both must be satisfied simultaneously for the HVPS to produce HV output.

### 9.5 RF MPS PLC Three-Path Architecture — Defense in Depth

The RF MPS PLC is unique among the five actors in that a single relay activation produces consequences on three independent signal paths simultaneously (see §5.5 for full description). This is a cross-layer interaction worth noting explicitly:

| Path | Layer | HVPS Effect | RF Effect | Speed | Notes |
|------|-------|-------------|-----------|-------|-------|
| **A** — MPS relay → Fast IC | Hardware interlock | SCR ENABLE removed + CROWBAR fired | RF_FAULT via AIM | < 15 ms total | Primary HVPS shutdown path |
| **B** — DH+ permit bit | Software / EPICS | None (bookkeeping) | SNL orderly shutdown | ~1 s | Fault record, fault file, state machine |
| **C** — MPS relay → VXI Slot 5 | Hardware backplane | None | RF_FAULT via Slot 5 | < 15 ms total | Redundant RF cut only |

The design consequence: for any RF MPS PLC trip, the HVPS shutdown is **always owned by Path A** through the Fast Interlock Chassis. Paths B and C cannot substitute for Path A from an HVPS protection standpoint. If Path A were to fail (e.g., Fast IC hardware fault preventing it from responding to permit loss), neither Path B nor Path C would shut off the HVPS — only Path C would cut RF drive.

This asymmetry should be considered during upgrade architecture design: the new Interface Chassis interlock design must maintain an equivalent hardware-speed path from MPS signals to the HVPS SCR/crowbar circuit.

### 9.6 RF Shutdown Path Following HVPS PLC Trip

**Open question resolved.** When the SLC-500 HVPS PLC trips and shuts off the HVPS, the RF drive is **not immediately cut** by any direct hardware signal from the HVPS PLC. There is no wired path from the SLC-500 to the Fast Interlock Chassis SCR ENABLE or CROWBAR outputs, and no direct fiber-optic kill to the VXI RFP module.

The complete RF shutdown signal trace for a HVPS PLC-only trip is:

```yaml
t = 0 ms        SLC-500 HVPS PLC detects internal fault (e.g., transformer arc):
                → Slot-5 OX8 relay opens
                → Supervisory SCR ENABLE removed (fiber optic → B514 SCR gate driver)
                → HVPS HV output begins to collapse (SCR gates disabled)

t ≈ 0 ms        B514 HVPS power section responds to loss of SCR gating:
                → STATUS fiber to B132 Fast IC drops (HVPSON=0)
                → Fast IC records HVPSON=0 in FISTAT bit 6
                ⚠ This is INFORMATIONAL ONLY — Fast IC does NOT fire SCR ENABLE
                  removal or CROWBAR in response to HVPSON going low.
                  The HVPS is already being shut down by the SLC-500.
                  HVPSON=0 only gates AIM arc voltage history buffer readout.

t ≈ 0 ms        KLYSTRON CATHODE VOLTAGE COLLAPSES:
                → Klystron cathode at approximately 0 V (or HVPS residual)
                → RF drive signal still present from RFP module (software unaware)
                → Klystron cannot amplify without cathode HV: RF output = ~0
                → Cavity fields decay on cavity time constant (~1 ms for SPEAR3)

t = 0 ms        RF DRIVE SIGNAL PATH (VXI → klystron):
                → RFP module (VXI Slot 4) continues outputting RF drive DAC values
                → RF_FAULT NOT asserted (no AIM arc latch, no Fast IC trip)
                → rfswitch PV still = ON

t ≈ 100 ms–1 s  EPICS alarm propagation (DH+ → AB-6008 scanner → EPICS):
                → {STN}:HVPSXFORM:ARC:LTCH (or other HVPS fault latch) = MAJOR
                → {STN}:HVPSSTN:SUMY:LTCH propagates to HVPSOFF:SUMY:STAT
                → {STN}:STNOFF:SUMY:STAT.SEVR = MAJOR
                → fault_stnoff != NO_ALARM in rf_states.st

t ≈ 1 s         SNL rf_states.st detects fault → enters s_go_off:
                → Step 1: fba = 1 (BATS fired from software side)
                → Steps 2–4: HVPS voltage setpoint → 0 (no-op; already collapsed)
                → Step 5: hvpstrig = OFF (SCR supervisory enable confirmed OFF)
                → Step 6: rfswitch = OFF
                          {STN}:STN:RFP:RFENABLE = 0
                          → RFP module RF drive DAC output disabled
                          ← RF DRIVE IS CUT HERE (t ≈ 6 s after initial trip)
```

**Why the ~6 s latency is safe**: A klystron is a velocity-modulation amplifier that requires cathode high voltage to produce RF output. Without cathode HV, even a full-amplitude drive signal produces no forward power. The cavity fields have completely decayed within ~1 ms of HV collapse. The ~6 s period between HVPS trip and `rfswitch = OFF` therefore does not produce any RF output and poses no equipment hazard — the klystron is a passive, inert component during this window.

**No direct hardware RF kill path from HVPS PLC**: Unlike the Fast IC path (where a trip simultaneously fires SCR ENABLE removal AND asserts RF_FAULT through AIM to cut drive), the SLC-500 HVPS PLC trip path has no equivalent direct RF kill. The B514 STATUS → Fast IC → HVPSON=0 path is intentionally informational-only.

**Possible indirect secondary path (not guaranteed)**: If the sudden HVPS voltage collapse causes reflected power to rise at the cavity junctions (forward power drops → VSWR increases), the RF MPS PLC may detect a reflected power trip condition and fire Path A (MPS relay → Fast IC → RF_FAULT). This would cut RF drive in ~10–15 ms via AIM → VXI backplane. However, this secondary path is **not guaranteed**: if drive power was low before the trip, reflected power may stay below the MPS threshold.

**RF shutdown timeline summary for HVPS PLC trip**:

| Time | Event | RF Drive State |
|------|-------|----------------|
| t = 0 | HVPS PLC trips; SCR ENABLE removed | Drive ON; klystron de-powered |
| t ≈ 0 | HVPS HV collapses; klystron cathode at ~0 V | Drive ON (software unaware); RF output = 0 |
| t ≈ 100 ms–1 s | EPICS alarms propagate via DH+ | Drive ON (SNL not yet triggered) |
| t ≈ 1 s | SNL s_go_off sequence begins | Drive ON (Steps 1–5 in progress) |
| **t ≈ 6 s** | **s_go_off Step 6: rfswitch = OFF** | **Drive OFF — RF drive cut** |

> **Design implication for the upgrade**: The upgrade Interface Chassis interlock design should include a direct hardware path from HVPS enable removal (or HVPS PLC fault output) to the LLRF9 RF enable input. This would eliminate the ~6 s software-dependent window and make the RF shutdown timing visible and auditable in hardware — consistent with the defense-in-depth philosophy of the rest of the interlock architecture.

---

## Part X — Fault Data Availability and Analysis

When a fault event occurs, multiple data sources capture pre- and post-event waveforms at different speeds and with different signal content. This section describes where each data source is stored, how to access it, and provides a step-by-step fault analysis procedure.

### 10.1 Overview of Fault Data Sources

| Source | What It Captures | Time Resolution | Latency to Availability | Storage Location |
|--------|-----------------|-----------------|------------------------|-------------------|
| **AIM Hardware History Buffer** | 12 arc channel voltages + HVPS voltage (continuous ADC ring buffer) | ~μs per sample | Immediately (freezes on fault) | VXI AIM module on-board memory; exported to IOC `/dat/aimHist.dat` |
| **SNL Fault Files** (`/dat/FAULT*_N`) | 11 RF/IQA signal channels (I/Q waveforms, amplitude waveforms) | ~1 ms per sample | ~6–10 s post-fault | VxWorks virtual disk `/dat/` on VXI IOC |
| **B118 Oscilloscope (4-channel)** | HVPS DC voltage, HVPS DC current, inductor T2 sawtooth voltage, transformer T1 AC current | Oscilloscope sweep rate (operator-set; typical 10–100 ms/div) | Continuous display; capture on trigger | Local oscilloscope (memory, USB, or printout) |
| **EPICS Channel Archiver** | All EPICS PVs — alarm states, analog readbacks, timestamps, state machine transitions | 1 Hz nominal; event-driven on PV change | Always available; rolling multi-year history | EPICS archiver server (see §10.5) |

---

### 10.2 AIM Hardware History Buffer

**What it contains**: The Fast Interlock Chassis (340-308) onboard fast ADC continuously digitizes all 12 arc channel voltages and the HVPS DC voltage into the AIM module's 512 KB ring buffer (`HISBUF`, A24 address space, offset `0x0038`). On fault, the `ADCCTL` bit freezes the buffer, preserving the pre-fault arc waveforms.

**Where stored**: VXI AIM module on-board memory. The device driver (`devP2RfAim.c`) reads arc voltage peaks via the `ARCVOL` register and crate voltage via `CRTVOL`. The history data is exported to `/dat/aimHist.dat` on the IOC. Note: buffer readout is **gated** — if `FISTAT.HVPSON = 0` (HVPS off at fault time), the driver skips arc voltage readback.

**EPICS readback PVs** (immediately available post-fault):

| PV | Content |
|----|--------|
| `{STN}:STN:AIM:ARCCURSTT` | 12-bit real-time arc channel status (clears when arc ends) |
| `{STN}:STN:AIM:ARCLTDSTT` | 12-bit latched arc channel status (holds until FAULT RESET button pressed) |
| `{STN}:STN:AIM:FSTFLT` | Fast IC aggregated fast fault status word |
| `{STN}:STN:AIM:INTSTATE` | AIM overall interlock state |

**Interpreting `ARCLTDSTT` bit pattern**:

| Bits | Sensor Location | Notes |
|------|----------------|-------|
| 0–3 | Four cavity waveguide window arc sensors | Cavity 1–4 in numerical order |
| 4 | Klystron output window arc sensor | High-energy arc in klystron output waveguide |
| 5 | Main circulator arc sensor | Arc at circulator assembly |
| 6–11 | Spare channels (not connected in SPEAR3) | Should always be 0 |
| **All zeros** | **No waveguide arc detected** | Fault originated from HVPS, MPS PLC, or other non-arc source |

---

### 10.3 SNL Fault Files (`/dat/FAULT*_N`)

**What they contain**: 11 pre-fault RF and IQA signal channels captured from hardware signal memory buffers in the RFP and IQA VXI modules. These represent the RF state at the moment of fault.

**Where stored**: VxWorks virtual disk `/dat/` on the VXI IOC in B132. Files use the naming convention `FAULT<channel>_<slot>` where `<slot>` is 1–15 (circular buffer, `NUMFAULTS=15`). The current slot number is tracked as EPICS PV `{STN}:STN:NFAULT`.

**File channel list** (in capture order for SPEAR3 `#else` branch of `#ifdef CF2`):

| Slot Index | File Pattern | Signal |
|------------|-------------|--------|
| 0 | `FAULTRfpSI_N` | RFP Signal I (cavity forward, I component) |
| 1 | `FAULTRfpSQ_N` | RFP Signal Q (cavity forward, Q component) |
| 2 | `FAULTRfpCI_N` | RFP Cavity I (cavity voltage, I component) |
| 3 | `FAULTRfpCQ_N` | RFP Cavity Q (cavity voltage, Q component) |
| 4 | `FAULTIqa1Amp_N` | IQA1 amplitude waveform |
| 5 | `FAULTIqa2Amp_N` | IQA2 amplitude waveform |
| 6 | `FAULTGvf_N` | GVF signal (PEP-II heritage; inactive in SPEAR3) |
| 7 | `FAULTAim_N` | AIM arc/interlock status snapshot |
| 8 | `FAULTCmbI_N` | Combiner I (PEP-II; inactive in SPEAR3) |
| 9 | `FAULTIqa3Amp_N` | IQA3 amplitude waveform |
| 10 | `FAULTCmbQ_N` | Combiner Q (PEP-II; inactive in SPEAR3) |

**Access procedure**:
1. Check `{STN}:STN:NFAULT` EPICS PV to find the most recent fault slot number N
2. Log in to the VxWorks IOC shell (telnet to B132 VXI CPU) or access via NFS/FTP
3. List `/dat/FAULT*_N` (substitute the slot number)
4. Transfer files to a workstation for analysis (binary format; see §10.6 for reading)

---

### 10.4 B118 Oscilloscope — Four HVPS Monitor Channels

**Location**: Building B118, HVPS Hoffman Box equipment area. An oscilloscope is permanently installed to monitor 4 analog signals from the HVPS system.

**The four channels are physical analog signals routed from the HVPS cabinet to BNC inputs on the oscilloscope via shielded cables.** The oscilloscope is a standalone instrument; it is **not** connected to EPICS. The signal identities are:

| Channel | Signal | Source Hardware | Expected Waveform Pattern | Diagnostic Value |
|---------|--------|-----------------|--------------------------|------------------|
| **CH1** | HVPS DC Output Voltage | Resistive voltage divider (1000:1) from HVPS DC bus | Smooth DC at −77 kV nominal; slight 12-pulse ripple (~6.9% P-P) | Crowbar: instant collapse to ~0 V; SCR disable: decay over ~100 ms; setpoint changes visible as slow ramp |
| **CH2** | HVPS DC Output Current | Danfysik DC-CT (Hall-effect current transducer) | DC at ~22 A nominal | Arc event: current spike; crowbar: current spike then zero; HVPS trip: current decay |
| **CH3** | Inductor 2 (T2) Sawtooth Voltage | SCR firing circuit monitor winding on T2 | **Bipolar asymmetric sawtooth** (inverted direction vs. theoretical model — this is normal for real SPEAR3) | Waveform disappears when SCR firing stops; asymmetry changes indicate firing angle / regulation shifts; absence indicates HVPS off |
| **CH4** | Transformer 1 (T1) AC Phase Current | Current transducer on T1 primary winding | **Bipolar asymmetric square pulses** with commutation spikes (not sinusoidal — characteristic of 12-pulse discrete switching) | Dropout indicates HVPS de-energized; asymmetric pulses indicate phase balance issue; commutation spike amplitude indicates SCR health |

**Accessing data for fault analysis**:
- **Field capture**: Use the oscilloscope's single-shot trigger or freeze function at the time of fault; export via USB/Ethernet or photograph the screen. The scope is a standalone instrument — no EPICS waveform interface exists for this unit.
---

### 10.5 EPICS Channel Archiver

**What it contains**: The SLAC EPICS Channel Archiver continuously records all EPICS PVs with timestamps. This provides the complete alarm and measurement history for all PVs in the RF station, typically with years of rolling history.

**Access methods**:

1. **EPICS Strip Chart / Archive Viewer GUI**: Open the Strip Chart tool from any EPICS operator display. Enter PV name(s) and select the time window around the fault event.

2. **Channel Archiver web interface**: Contact SLAC SSRL controls group for the archiver server hostname and web URL.

3. **Python (Archiver Appliance REST API)**:
   ```python
   import requests
   pv = "SRF1:STN:AIM:ARCLTDSTT"  # substitute actual station prefix
   t0 = "2026-04-10T02:00:00Z"      # start time (UTC ISO-8601)
   t1 = "2026-04-10T03:00:00Z"      # end time
   url = f"http://<archiver-host>/retrieval/data/getData.json?pv={pv}&from={t0}&to={t1}"
   data = requests.get(url).json()
   ```

**Key PVs to retrieve for fault post-mortem**:

| Category | PV | What to Look For |
|----------|----|------------------|
| Arc fault | `{STN}:STN:AIM:ARCLTDSTT` | Which bit(s) set at fault time? |
| Fast IC fault | `{STN}:STN:AIM:FSTFLT` | Fast IC fault word at trip instant |
| MPS PLC | `{STN}:STN:MPS:LTCH` | Did MPS PLC trip independently of arc? |
| HVPS summary | `{STN}:HVPSSTN:SUMY:LTCH` | Which HVPS sub-fault latched? |
| Transformer arc | `{STN}:HVPSXFORM:ARC:LTCH` | HV transformer internal arc event? |
| Crowbar | `{STN}:HVPS:CROWBAR:LTCH` | Crowbar activated? |
| Overvoltage | `{STN}:HVPS:VOLT:LTCH` | DC output overvoltage? |
| HVPS voltage | `{STN}:HVPS:VOLT` | Pre-fault and collapse waveform (1 Hz; limited time resolution) |
| Station state | `{STN}:STN:STATE` | State machine transitions: ON_CW → s_go_off → OFF |
| Fault slot | `{STN}:STN:NFAULT` | Fault file slot number — use to locate `/dat/FAULT*_N` files |
| Forced fault | `{STN}:STN:FORCED:LTCH` | Hard arc latch — requires manual FAULT RESET to clear |

---

### 10.6 Step-by-Step Fault Analysis Procedure

#### Immediate Response (within minutes of fault)

1. **Record exact UTC timestamp** from the EPICS alarm notification or operator display
2. **Read the EPICS alarm display** on the EDM operator panel — identify which latches are set:
   - `ARCLTDSTT ≠ 0` → Arc fault; note which bit(s)
   - `HVPSXFORM:ARC:LTCH` set → HV transformer internal arc
   - `HVPS:CROWBAR:LTCH` set → Crowbar fired
   - `STN:MPS:LTCH` set → MPS PLC trip (cooling, vacuum, or power)
   - `STN:FORCED:LTCH` set → Hard arc; manual FAULT RESET required before recovery
3. **Note fault slot number** from `{STN}:STN:NFAULT` — needed to retrieve fault files
4. **Go to B118** and check the oscilloscope display for the fault waveforms: 
   - Was CH1 a sudden drop (crowbar) or a slow decay (SCR disable)? 
   - Did CH4 drop at the same instant as CH1, or before?
5. **Do NOT press FAULT RESET** on the Fast Interlock Chassis front panel until the cause is understood — pressing it clears the arc latch evidence

#### Detailed Analysis (after initial survey)

1. **Retrieve fault files** from IOC: `telnet <B132-IOC-hostname>`, then check `/dat/FAULT*_N` for the slot noted above
2. **Retrieve EPICS archiver history** for the key PVs listed in §10.5 in a ±5 minute window around the fault timestamp
3. **Plot fault file data**. The files are binary with a short header followed by raw ADC samples as 16-bit integers or 32-bit floats (format is hardware-dependent; consult `devP2RfAim.c` for AIM fault file format or the RFP/IQA driver for RF signal file format). In Python:
   ```python
   import numpy as np
   data = np.fromfile('/dat/FAULTRfpSI_1', dtype=np.int16)  # example
   ```
4. **Review the B118 oscilloscope capture** (see §10.4): note whether CH1 (DC voltage) shows an abrupt collapse (crowbar, < 1 μs) or a gradual decay (~100 ms for SCR disable), and whether CH4 (T1 AC current) dropped simultaneously with or prior to CH1
5. **Determine the initiating event** — use EPICS timestamp ordering (1 Hz resolution for DH+ PVs) to sequence events among HVPS faults; use the arc channel bit pattern for hardware-speed (< 1 μs) faults

#### Fault Categorization Guide

| Observed Indicators | Most Likely Initiating Event | First Actor |
|--------------------|-----------------------------|--------------|
| `ARCLTDSTT` bits 0–3 set | Cavity waveguide window arc (cavity N = bit N) | Fast IC (< 1 μs) |
| `ARCLTDSTT` bit 4 set | Klystron output window arc | Fast IC (< 1 μs) |
| `ARCLTDSTT` bit 5 set | Main circulator arc | Fast IC (< 1 μs) |
| `ARCLTDSTT = 0`, `HVPSXFORM:ARC:LTCH` set | HV transformer internal arc | SLC-500 HVPS PLC (~10–20 ms) |
| `ARCLTDSTT = 0`, `HVPS:CROWBAR:LTCH` set, no arc latch | HVPS overvoltage → crowbar self-fired; OR analog crowbar threshold exceeded | Crowbar analog circuit (< 1 μs) |
| `ARCLTDSTT = 0`, `STN:MPS:LTCH` set | RF MPS PLC trip (cooling water over-temp, vacuum excursion, or overpower) | RF MPS PLC (~10 ms) |
| `ARCLTDSTT = 0`, `HVPSOIL:TEMP:LTCH` set | Oil overtemperature (slow thermal fault) | SLC-500 HVPS PLC (~10–20 ms) |
| `ARCLTDSTT = 0`, `HVPS:VOLT:LTCH` set | HVPS DC output overvoltage | SLC-500 HVPS PLC (~10–20 ms) |
| CH3 waveform entirely absent (oscilloscope) | SCR firing stopped — contactor open, or full SCR fault | Hardware, timing depends on cause |
| CH4 waveform asymmetric or one phase missing | Phase imbalance in primary; possible SCR failure or phase loss | SLC-500 or AC protection |
| CH1 voltage collapse: instant step to ~0 V | Crowbar fired | Crowbar circuit (analog, < 1 μs) |
| CH1 voltage collapse: exponential decay over ~100 ms | SCR gate drive disabled (supervisory path) | SLC-500 relay (~10–20 ms) |

> **Sources**: §3.8 (AIM history buffer and SNL fault files); §6.5 (HVPS PV list); §9.6 (RF shutdown path); `rfApp/Db/rf_hvps.db` (HVPS scalar PV definitions); `llrf/llrf9/iGp/matlab/llrf/read_waveforms.m` (LabCA MATLAB access pattern); `iocBoot/b132-iocrf/Tables/device.tbl` (KSC2961 GPIB controller registration).

---

## Appendix A — EPICS PV Quick Reference

| PV | Description | Normal State |
|----|-------------|-------------|
| `{STN}:STNOFF:SUMY:STAT.SEVR` | **Master trip wire** (SNL `fault_stnoff`) | NO_ALARM |
| `{STN}:STN:AIM:MODU.HVPS` | AIM HVPS permissive (`aimon`) | 1 when ON |
| `{STN}:STN:AIM:FRCBMABT` | Force Beam Abort (`fba`) | 0 when ON |
| `{STN}:STN:AIM:MODU.RSTF` | Reset AIM Faults (`rstf`) | — (write only) |
| `{STN}:STN:AIM:MODU.RBA` | Reset Beam Abort (`rba`) | — (write only) |
| `{STN}:STN:AIM:ARCLTDSTT` | Arc latched status (12-bit word) | 0 = no arc |
| `{STN}:STN:AIM:ARCCURSTT` | Arc current status (12-bit word) | 0 = no arc |
| `{STN}:STN:AIM:FSTFLT` | Fast fault status from Fast IC | 0 = OK |
| `{STN}:STN:VXI:LTCH` | VXI interlock latch (from AIM latch register) | OK |
| `{STN}:STN:FORCED:LTCH` | Forced fault latch (blocks auto-reset) | OK |
| `{STN}:STN:MPS:LTCH` | RF MPS PLC permit status | OK |
| `{STN}:HVPSSCR:ON:CTRL` | HVPS SCR enable switch (`hvpstrig`) | 1 when ON |
| `{STN}:STN:RFP:RFENABLE` | RF drive enable (`rfswitch`) | 1 when ON |
| `{STN}:HVPS:CROWBAR:LTCH` | HVPS crowbar fired latch | OK |
| `{STN}:HVPS:VOLT:LTCH` | HVPS overvoltage latch | OK |
| `{STN}:HVPSOIL:LEVEL:LTCH` | HVPS oil level latch | OK |
| `{STN}:HVPSOIL:TEMP:LTCH` | HVPS oil temperature latch | OK |
| `{STN}:HVPSXFORM:ARC:LTCH` | Transformer arc latch | OK |
| `{STN}:HVPS:PANIC:LTCH` | Emergency Off latch | OK |
| `{STN}:HVPSOFF:SUMY:STAT` | HVPS OFF status summary | NO_ALARM |
| `{STN}:HVPSSTN:SUMY:LTCH` | HVPS station fault summary | NO_ALARM |
| `{STN}:STNMPS:SUMY:LTCH` | Station MPS summary (SPEAR3) | NO_ALARM |

---

## Appendix B — Items Requiring Field Verification

The following details were inferred from code analysis and require physical hardware verification:

| Item | What Was Inferred | Needs Verification |
|------|------------------|-------------------|
| Slot 5 physical module | Labeled "MPS Shutoff" in crate template; CF2 DB loaded as PEP-II artifact | Confirm what is physically present in VXI slot 5 in the SRF1 crate |
| Fast IC ↔ MPS PLC wiring | Hardwired relay I/O between ControlLogix and Fast IC; exact connector/terminal IDs | Verify against MPS wiring drawings wd3403300200–wd3403303400 |
| Fast IC ↔ AIM connection | AIM receives status word from Fast IC | Verify physical cable/connector; check if via VXI backplane or external cable |
| SLC-500 SCR fiber path | OX8 relay OUT → fiber → B514 | Verify fiber cable routing and connection in B118/B514 |
| DH+ word/bit assignments | Derived from `rf_digital_All.substitutions,v` | Cross-check against SLC-500 ladder logic program (if available) |
| `aimon` interlock gate | AIM fiber output physically gates SLC-500 HVPS enable | Verify signal path in B118 circuitry |
| Arc sensor count | PDR §12.3 says 6 locations, 11 total sensors | Confirm physical installation count |

---

## Appendix C — Source Reference Index

All findings in this document were derived from direct analysis of the following source files. References are cited throughout as **[Rn]**.

### Design Documents

| Ref | File | Description |
|-----|------|-------------|
| **[R1]** | `Designs/L_LEGACY_SYSTEM_ARCHITECTURE.md` | SPEAR3 RF System Legacy Architecture (v2.5+) — primary system reference |

### Primary Source Code

| Ref | File | Location | Lines | Role |
|-----|------|----------|-------|------|
| **[R2]** | `rf_states.st,v` | `rfApp/src/seq/` | 2,227 | Master SNL state machine — all fault detection and response logic |
| **[R3]** | `devP2RfAim.c,v` | `rfApp/src/vxi/` | 1,982 | AIM module device support — arc channels, ISR, BATS, fault files |
| **[R4]** | `devABSLCDCM.c` | `rfApp/src/ab/` | 563 | SLC-500 DH+ device support — HVPS supervisory communication |
| **[R5]** | `p2RfCf2Def.h,v` | `rfApp/src/vxi/` | 403 | CF2 register definitions (PEP-II heritage, slot 5 reference) |
| **[R6]** | `p2RfAimDef.h,v` | `rfApp/src/vxi/` | — | AIM register definitions (`TRIPLVL`, `HISBUF`, `ARCVOL`, `FISTAT`, `HVPSON`) |

### EPICS Database Files

| Ref | File | Location | Role |
|-----|------|----------|------|
| **[R7]** | `aim.db,v` | `rfApp/Db/` | AIM module PV definitions — arc status, interlock state, control outputs |
| **[R8]** | `rf_digital_hvps.db,v` | `rfApp/Db/` | HVPS digital I/O template — all HVPS status/latch bits from SLC-500 |
| **[R9]** | `rf_digital_All.substitutions,v` | `rfApp/Db/` | Instantiates HVPS digital I/O with DH+ word/bit assignments |
| **[R10]** | `rf_sumy_hvps.db,v` | `rfApp/Db/` | HVPS alarm aggregation tree |
| **[R11]** | `rf_sumy_stn.db,v` | `rfApp/Db/` | Station-level alarm aggregation — STNOFF/STNON/STNMPS trees |
| **[R12]** | `rf_sumy_stn_spr.db,v` | `rfApp/Db/` | SPEAR3-specific additions to station summary (STNMPS, external MPS) |
| **[R13]** | `rf_interlock.db,v` | `rfApp/Db/` | DCM-based hardware interlock channels (MPS wiring) |
| **[R14]** | `rf_interlock_vxi.db,v` | `rfApp/Db/` | VXI-based interlock channels — AIM latch register bits |
| **[R15]** | `rf_analog_All.substitutions,v` | `rfApp/Db/` | Analog channel assignments (HVPS volts, current, temperature) |
| **[R16]** | `rf_hvps.db,v` | `rfApp/Db/` | HVPS supervisory records — voltage setpoints, SCR control, oil temp |
| **[R17]** | `crat_vxi_13slot.template,v` | `rfApp/Db/` | VXI crate slot labeling — confirms slot 5 = "MPS Shutoff" |
| **[R18]** | `rf_vxi_modules_All.substitutions,v` | `rfApp/Db/` | VXI module DB loading — `cf2.db` assigned to slot 5 (PEP-II artifact) |

### Technical Notes (Code Analysis Series)

| Ref | File | Location | Content |
|-----|------|----------|---------|
| **[R19]** | `00-executive-summary.md` | `codeReviewTechnicalNotes/` | System overview, slot 5 clarification |
| **[R20]** | `01-file-inventory.md` | `codeReviewTechnicalNotes/` | File classification — CF2 marked PEP-II only |
| **[R21]** | `03-vxi-device-support.md` | `codeReviewTechnicalNotes/` | AIM §5: arc channels, fast interlock chain, BATS, fault files |
| **[R22]** | `05-snl-state-machines.md` | `codeReviewTechnicalNotes/` | Complete 23-state SNL architecture documentation |
| **[R23]** | `06-plc-stepper-motors.md` | `codeReviewTechnicalNotes/` | PLC topology: 3 DH+ nodes, SLC-500 HVPS functions |
