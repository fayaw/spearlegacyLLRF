# PEP-II Low-Level RF (LLRF) System — Comprehensive Technical Notes

> **Purpose**: Complete technical reference for the original PEP-II LLRF design,  
> created to support the SPEAR3 (SSRL) LLRF upgrade project which replicates the PEP-II architecture.  
> **Document Number**: SPEAR3-LLRF-LEGACY-001  
> **Generated**: March 2026  
> **Source Material**: Original SLAC/PEP-II engineering drawings and process specifications  
> located in `llrf/documentation/legacyArchitecture/` plus published SLAC technical reports.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [RF Station Architecture](#2-rf-station-architecture)
3. [LLRF Signal Processing Architecture](#3-llrf-signal-processing-architecture)
4. [VXI Crate Module Topology](#4-vxi-crate-module-topology)
5. [RF Feedback Loop Architecture](#5-rf-feedback-loop-architecture)
6. [Cavity and RF Parameters](#6-cavity-and-rf-parameters)
7. [High-Voltage Power Supply (HVPS) System](#7-high-voltage-power-supply-hvps-system)
8. [Klystron Drive Chain](#8-klystron-drive-chain)
9. [Cavity Tuner System](#9-cavity-tuner-system)
10. [Interlock and Machine Protection System](#10-interlock-and-machine-protection-system)
11. [Control System Architecture](#11-control-system-architecture)
12. [Waveguide Network and Power Distribution](#12-waveguide-network-and-power-distribution)
13. [Cavity Low-Power Calibration](#13-cavity-low-power-calibration)
14. [RF Station Operating Procedures](#14-rf-station-operating-procedures)
15. [Safety Systems](#15-safety-systems)
16. [Relevance to SPEAR3 LLRF Upgrade](#16-relevance-to-spear3-llrf-upgrade)
17. [Reference Documents](#17-reference-documents)
18. [External Publications](#18-external-publications)

---

## 1. System Overview

### 1.1 Background

The PEP-II B Factory was an asymmetric electron-positron collider at SLAC consisting of two storage rings:

| Parameter | High Energy Ring (HER) | Low Energy Ring (LER) |
|-----------|----------------------|----------------------|
| Beam Energy | 9.0 GeV | 3.1 GeV |
| Design Beam Current | 0.99 A (achieved ~950 mA) | 2.14 A (achieved ~1700 mA) |
| RF Frequency | 476 MHz | 476 MHz |
| Circumference | 2200 m | 2200 m |
| Harmonic Number | 3492 | 3492 |
| Revolution Frequency | 136.3 kHz | 136.3 kHz |
| RF Voltage (total, CDR) | 18.5 MV | 5.1 MV |
| Energy Loss/Turn | 3.57 MeV | 0.87 MeV |
| Number of RF Stations | 6 (later expanded to 8+) | 2 (later expanded to 4+) |
| Number of Cavities | 24 (4 per station) | 8–10 (2 per station) |
| Klystron Power | 1.2 MW CW each | 1.2 MW CW each |

> **Reference**: `ps3403305100.pdf` (PS-340-330-51-R0) — *PEP-II RF System Description*, Heinz Schwarz, July 1999;  
> SLAC/AP-99 — *Impedance Study for the PEP-II B-factory* (Heifets et al., March 1995), Table 1;  
> LBL-34960 — *High-Power RF Cavity R&D* (Rimmer et al.), Table 1.  
> **Note**: The CDR design values evolved during construction and operation. Beam currents shown  
> are the CDR design targets; achieved currents at the end of PEP-II operation were approximately  
> HER: 1.8 A, LER: 2.9 A with additional RF stations installed beyond the original complement.

### 1.2 Design Philosophy

The LLRF system was designed by Paul Corredoura and team at SLAC with these key principles:

- **Baseband I/Q signal processing** using both analog and digital techniques
- **VXI-based modular hardware** for flexibility and maintainability
- **EPICS control system** for turn-key operation with minimal operator intervention
- **Multiple cascaded feedback loops** to reduce cavity impedance seen by the beam
- **Built-in network analyzer** and transient recorders for diagnostics
- **Fiber optic interface** to the longitudinal multibunch feedback system
- **MATLAB-based calibration routines** for automated loop configuration

### 1.3 The SPEAR3 Connection

SPEAR3 adopted essentially a PEP-II HER RF station for its RF system upgrade in 2003:
- **1 × 1.2 MW klystron** feeding **4 × 476.3 MHz single-cell copper cavities**
- The LLRF system is a direct copy of the PEP-II LLRF architecture
- The same VXI modules, EPICS software, and feedback strategies were used
- The current SPEAR3 LLRF upgrade project replaces the aging VXI hardware with modern equivalents (Dimtel LLRF9) while preserving the proven control algorithms

---

## 2. RF Station Architecture

### 2.1 HER Station Configuration (4-Cavity)

Each HER RF station (and SPEAR3) drives **four single-cell cavities** through the following signal chain:

```
Master Oscillator (476 MHz)
       │
       ▼
  LLRF System (VXI Crate)
       │
       ▼
  120 W Solid-State Drive Amplifier (~+51 dBm max output)
       │
       ▼
  1.2 MW Klystron (typical ~50 W drive at saturation)
       │
       ▼
  Circulator (klystron protection from reflected power)
       │
       ▼
  Waveguide Power Splitting Network
  ├── Magic-Tee #1 → Cavity 1 + Load
  ├── Magic-Tee #2 → Cavity 2 + Load  
  └── Magic-Tee #3 → Cavity 3 + Cavity 4
                      (via 4th-port loads)
```

> **Reference**: `bd3403300000.pdf` (BD-340-330-00-R0) — *PEP-II LER RF Station Block Diagram*,  
> `blockDiagrambd3403290100-1.pdf` (BD-340-329-01-R0) — *PEP-II HER LLRF Configuration Block Diagram*,  
> Paul Corredoura, 1/28/99.

### 2.2 LER Station Configuration (2-Cavity)

Each LER station uses a single Magic-Tee to split power to 2 cavities. Otherwise identical to HER.

### 2.3 Physical Layout

Each RF station occupies a surface support building and includes:

- **6 equipment racks** containing:
  - Station breakers and emergency off button
  - Local control and monitor panels (HVPS and station)
  - Safety key switches and red warning beacon
  - PLC system (Allen-Bradley) for temperature readback and interlock functions
  - Klystron filament and focus supplies
  - Cavity ion gauge readouts and ion pump supplies
- **1 air-conditioned blue rack** containing LLRF VXI modules
- **Aluminum grounding switch tank** with lock-out provisions for HVPS
- **Klystron** with circulator, waveguide network, and penetrations to tunnel
- **3 water cooling systems** per region:
  - LCW Circuit 1: Klystron cooling (regulated 35°C supply)
  - LCW Circuit 2: Cavity cooling in tunnel (regulated 35°C)
  - HCW Circuit: Waveguide high-power loads (unregulated)

> **Reference**: `ps3403305100.pdf`, pages 2-3, 7 (cross-sectional layout diagrams).

### 2.4 Station Locations (PEP-II)

| Ring | Region | Building | Stations |
|------|--------|----------|----------|
| HER | 8 | B685 | 8HR1, 8HR3, 8HR5 |
| HER | 12 | B725 | 12HR1, 12HR3 |
| LER | 4 | B645 | 4LR4, 4LR5 (4LR3 partial) |

---

## 3. LLRF Signal Processing Architecture

### 3.1 Baseband I/Q Processing

The PEP-II LLRF system uses **baseband In-phase/Quadrature (I/Q) signal processing** throughout. The 476 MHz RF signals are down-converted to baseband using analog I/Q demodulators and digital I/Q detectors. All feedback processing occurs at baseband, then the corrected signal is up-converted back to 476 MHz via an I/Q modulator.

**Signal Flow (per cavity channel):**

```
Cavity Probe (476 MHz, ~-10 dBm)
       │
       ▼
  I/Q Detector (Digital Down-Converter)
  ├── I (In-phase) component
  └── Q (Quadrature) component
       │
       ▼
  Vector Summation (all cavities combined)
       │
       ▼
  Feedback Processing (Direct Loop, Comb Loop, etc.)
       │
       ▼
  I/Q Modulator → 476 MHz RF output
       │
       ▼
  120 W Drive Amplifier (~50 W typical) → Klystron
```

### 3.2 I/Q Detector Design

The digital I/Q demodulator was a key innovation designed by C. Ziomek and P. Corredoura:

- **Input**: 476 MHz RF signal
- **Local Oscillator**: 471.1 MHz (4.9 MHz IF)
- **A/D Converter**: High-speed ADC digitizing the IF signal
- **Sample Rate**: Up to 10 MHz (Fsample)
- **Digital Processing**: Custom digital I/Q extraction using 512K RAM look-up tables
- **Accuracy**: Better than 0.1° phase and 0.1% amplitude over 30 dB dynamic range
- **Key advantage**: Eliminates analog I/Q errors (gain imbalance, quadrature errors, DC offsets)

Each LLRF system contains **three I/Q Amplitude Detector (IQA) modules** that can monitor up to 8 RF signals each (24 total inputs per station).

> **Reference**: `bd3403300100.pdf` (BD-340-330-01-R0) — *PEP-II LER LLRF Configuration*;  
> C. Ziomek, P. Corredoura, "Digital I/Q Demodulator", PAC 1995.

### 3.3 Baseband Modulator

The baseband modulator compensates for klystron gain and phase variations:

- **4 wideband analog multipliers** (Gilbert-cell based, 1V max input)
- **2 high-speed op-amps** for summing
- Used to compensate klystron gain tracking as cathode voltage changes
- Soft limiting circuits (back-to-back Schottky diodes 1N4157) prevent overdrive
- The modulator gain must decrease as klystron HV increases (up to 7 dB range in LER)

```
I_REF ──→ [Gain] ──→ [×I-I] ──→ ┐
                      [×I-Q] ──→ ┤──→ [Σ] ──→ RF Mod ──→ 476 MHz ──→ Drive Amp
Q_REF ──→ [Gain] ──→ [×Q-I] ──→ ┤
                      [×Q-Q] ──→ ┘
```

> **Reference**: Corredoura et al., "Experience with the PEP-II RF System at High Beam Currents", EPAC 2000 (SLAC-PUB-8498).

---

## 4. VXI Crate Module Topology

### 4.1 HER Configuration (Standard)

The LLRF hardware for each station is housed in a single VXI crate with the following modules:

| Slot | Module | Function |
|------|--------|----------|
| 0 | EPICS Processor (Slot 0) | μProcessor — EPICS IOC, state sequencer |
| 1 | Allen-Bradley VME Scanner | Interface to AB PLC (DH-485 network) |
| 2–3 | Spare (2 slots) | Reserved |
| 4 | Arc Detector/Interlocks | Arc detection, interlock summary, fault latch |
| 5 | Clock & RF Distribution | 476 MHz reference distribution, LO generation |
| 6 | RFP Module | RF Processing — feedback loops, modulator |
| 7 | Gap Voltage Feed-Forward | 476 MHz gap voltage FF, ion clearing gap compensation |
| 8 | Comb Filter (I) | I-channel comb filter with 1-turn delay |
| 9 | IQ/Amplitude Detector #1 | Digital I/Q detection (8 inputs) — *between comb I and Q* |
| 10 | Comb Filter (Q) | Q-channel comb filter with 1-turn delay |
| 11 | IQ/Amplitude Detector #2 | Digital I/Q detection (8 inputs) |
| 12 | IQ/Amplitude Detector #3 | Digital I/Q detection (8 inputs) |
| -- | Stepping Motor Controller ×4 | Tuner motor control (4 cavities, separate rack) |

> **Note on slot ordering**: The Comb Filter (I) and Comb Filter (Q) modules are **not** in adjacent  
> slots — an IQ/Amplitude Detector module is interleaved between them. This physical arrangement  
> reflects the signal routing architecture where I-channel comb output feeds into the first IQA  
> for monitoring before the Q-channel comb processes its data. Refer to Corredoura EPAC 2000  
> (SLAC-PUB-8498) Figure 1 for the canonical crate layout diagram.

**Additional I/O:**
- **Fiber Optic Receivers** (2): Connection to longitudinal feedback system kicker
- **Remote I/O**: SLC-500 system remote I/O link for thermocouple and analog inputs
- **Beam Phase Monitors**: From station LR44 (fiber optics from beam position monitors)

> **Reference**: `bd3403300000.pdf` (BD-340-330-00-R0) — station block diagram showing all VXI slots;  
> Corredoura, "Architecture and Performance of the PEP-II Low-Level RF System", PAC 1999 (SLAC-PUB-8124).

### 4.2 Key Signal Interfaces

| Signal | Level | Type | Source/Destination |
|--------|-------|------|-------------------|
| 476 MHz Reference | +3 dBm | RF coax | Master Oscillator → Clock/RF Distrib |
| 471.1 MHz L.O. | - | RF coax | Clock/RF Distrib → IQA modules |
| Cavity probes (4) | -10 to -6 dBm | RF coax | Tunnel cavities → IQA modules |
| RF Drive output | +16 dBm | RF coax | RFP Module → Drive Amplifier |
| Drive Amplifier out | +30 dBm max | RF coax | 120W Amp → Klystron input |
| Klystron forward | - | Directional coupler | Klystron → IQA |
| Klystron reflected | - | Directional coupler | Circulator → IQA |
| Longitudinal kick | - | Fiber optic | LFB System ↔ Gap voltage FF module |
| Interlock signals | Digital | Fiber optic | MPS → Arc Detector module |
| HVPS trigger | Digital | - | VXI → HVPS |
| Stepping motor commands | Analog/Digital | - | VXI → Tuner motors |
| Thermocouple inputs | Analog | - | 12 channels → separate crate |
| Analog monitor inputs | Analog | - | 32 channels → VXI analog I/O |

---

## 5. RF Feedback Loop Architecture

The PEP-II LLRF system implements **multiple cascaded feedback loops** to manage beam-cavity interactions. These loops are critical because heavy beam loading drives longitudinal coupled-bunch instabilities.

### 5.1 Loop Summary

| Loop | Bandwidth | Purpose | Status During ON_CW+Beam |
|------|-----------|---------|--------------------------|
| Direct Loop | 800 kHz | Primary impedance reduction; keeps gap voltage constant | ON (required) |
| Comb Loop | 2 MHz | Additional impedance reduction at revolution harmonics | ON |
| Tuner Loop | ~100 Hz | Maintains cavity resonance; compensates thermal drift | ON |
| HVPS Loop | ~1 Hz | Adjusts klystron HV to maintain 10% headroom below saturation | ON |
| DAC Loop | ~0.1 Hz | Keeps measured gap voltage equal to requested value | ON |
| Ripple Loop | ~300 Hz | Removes HVPS switching ripple from klystron output | ON |
| Gap Feed-Forward | Per revolution | Compensates ion-clearing gap transients | ON |
| LFB Woofer | Low modes | 3rd impedance reduction loop via longitudinal feedback | ON |

> **Reference**: `ps3403305200.pdf` / `feedbackLoopDescriptionps3403305200.pdf` (PS-340-330-52-R0) — *LLRF Feedback Loop Description*, Heinz Schwarz, July 1999.

### 5.2 Direct Feedback Loop (Primary Loop)

The **Direct Loop** is the most critical feedback loop:

- **Purpose**: Reduces cavity impedance as seen by the beam to suppress multi-bunch oscillations
- **Bandwidth**: 800 kHz
- **Mechanism**: Compares combined baseband field signals of all station cavities to a DAC reference (Gap module). The error signal is up-converted to RF to drive the klystron.
- **Contains**:
  - **PID Controller** with configurable gains
  - **Integral Compensation**: Smooths out HVPS ripple at low frequencies
  - **Lead Compensation**: Increases bandwidth and gain of the loop
  - **Frequency Offset Tracking**: Compensates phase shift from cavity detuning during heavy beam loading (diagnostic mode, not normally activated)
- **Configuration**: MATLAB routine `ConfDirect` sets loop phase, loop gain, and gain tracking
- **Measurement**: MATLAB routine `MeasDirCls` measures closed-loop response using built-in network analyzer (non-destructive to stored beam)

### 5.3 Comb Feedback Loop

- **Purpose**: Provides additional impedance reduction at specific synchrotron frequency sidebands around revolution harmonics
- **Bandwidth**: 2 MHz
- **Key feature**: Includes a **1-turn delay** (ring revolution period)
- **Signal path**: Separate I and Q comb filter modules in VXI crate
- **Configuration**: MATLAB routine `Config Comb` (station must be ON_CW with Direct Loop closed)
- **Equalizer**: MATLAB routine `Make Equal` creates delay equalizer to compensate group delay effects (used in both Comb Loop and Woofer link)

### 5.4 Tuner Loop

- **Purpose**: Tunes and maintains each cavity at resonance
- **Mechanism**: Keeps the phase relationship between forward power and cavity field constant, as measured by digital IQ detectors. The loop controls tuner position via stepping motors.
- **Compensates**: Thermal frequency variations and cavity beam loading
- **Configuration**: MATLAB routine `Tune Cavs` — measures resonance curves by injecting noise onto CW RF signal, fits standard resonance curves, establishes resonance condition, and sets up correct vector summation of multiple cavity signals for Direct and Comb loops
- **Additional**: MATLAB routine `Make Poly` creates polynomial of resonance frequency vs. tuner position for parking cavities and allowing direct loop phase adjustment during detuning

### 5.5 HVPS Loop

**With Direct Loop ON (normal beam operation):**
- Adjusts klystron high voltage to maintain ~10% headroom below saturation
- Measures drive power at klystron input, compares to ON_CW drive power set-point
- Increases HV for excessive drive, decreases for insufficient drive
- Bandwidth: ~1 Hz (slow loop)

**With Direct Loop OFF (no beam):**
- Keeps measured gap voltage equal to requested "Station Gap Voltage"
- Adjusts HVPS to control klystron output power directly

### 5.6 DAC Loop

**With Direct Loop ON:**
- Bandwidth: 0.1 Hz
- Keeps measured gap voltage equal to requested "Station Gap Voltage"
- Adjusts the DAC in the Gap Voltage Feed-Forward module

**With Direct Loop OFF:**
- Keeps drive power at requested level by adjusting the Gap Voltage FF module DAC

### 5.7 Ripple Loop

- **Purpose**: Removes amplitude and phase ripple from HVPS switching in klystron output
- **Current function**: Maintains low-bandwidth phase across klystron and drive amplifier as klystron voltage varies
- **Must be ON** for all normal operation
- **Note**: Originally intended as DSP-based, but the 50 kHz bandwidth ripple combined with digital IQ receiver delay proved challenging. An analog integrator in the Direct Loop was used instead. Simulations showed this would cause instability at currents >2A, prompting plans for a wideband analog ripple loop.

### 5.8 Gap Feed-Forward Loop

- **Purpose**: Tells the Direct Loop to ignore ion-clearing gap transients in the beam bunch train
- **Mechanism**: Learns the variation in klystron drive caused by the beam gap and adds an equal variation to the reference signal, keeping the error signal unchanged
- **Adaptation time**: ~1000 beam revolutions for full adaptation

### 5.9 LFB Woofer

- **Purpose**: Third cavity impedance reduction loop (alongside Direct and Comb loops)
- **Source**: Derives information from lowest beam oscillation modes detected by the Longitudinal Multibunch Feedback (LFB) system
- **Connection**: Wideband **fiber optic link** between LFB system and RF station
- **Effect**: Uses one RF station per ring as a powerful longitudinal kicker ("sub-woofer")
- **Configuration**: MATLAB routine `ConfWoofer` (requires Direct Loop, Comb Loop, and Gap FF all active)

### 5.10 Optimized Station Phasing

- MATLAB routine `Phase Stns` equalizes power contribution of all stations in a ring
- Adjusts station phases in 0.5° maximum steps for 10 iterations
- Only operational above 100 mA beam current
- Reference stations: HER: 8-3 (alternate: 12-3); LER: 4-4

---

## 6. Cavity and RF Parameters

### 6.1 Cavity Specifications

| Parameter | HER Value | LER Value | SPEAR3 Value |
|-----------|-----------|-----------|-------------|
| Type | Single-cell, normal-conducting copper | Same | Same (PEP-II design) |
| Frequency | 476.0 MHz | 476.0 MHz | 476.3 MHz |
| Design Gap Voltage (CDR) | 0.77 MV per cavity | 0.64 MV per cavity | ~0.8 MV per cavity |
| Max Gap Voltage | ~1 MV | ~1 MV | 800 kV (nominal) |
| Unloaded Q₀ | ≥30,000 (at 40°C, with ports) | ≥30,000 | ~30,000 |
| Coupling Factor β | 3.6 (design, without beam) | 3.6 | Similar |
| Loaded Qₗ | ~6,522 (= Q₀/(1+β)) | ~6,522 | Similar |
| Shunt Impedance R_s | 3.5 MΩ (circuit def: V²/2P) | 3.5 MΩ | Similar |
| R/Q (derived) | ~117 Ω (= R_s/Q₀) | ~117 Ω | Similar |
| Wall Loss per Cavity (CDR) | 84.9 kW | 49.7 kW | — |
| HOM Loads | 3 per cavity | 3 per cavity | 3 per cavity |
| Movable Tuner | 1 per cavity | 1 per cavity | 1 per cavity |
| Input Ceramic Window | 1 per cavity | 1 per cavity | 1 per cavity |
| Vacuum Pump | 400 l/sec VACION per cavity | Same | Same |
| Sampling Probe | 1 per cavity (adjustable coupling) | Same | Same |
| Manufacturer | ACCEL Instruments GmbH (Germany) | Same | Same |

> **Reference**: `ps3403305100.pdf` (PS-340-330-51-R0), page 4 — Parameter Table;  
> `ps3403305300.pdf` (PS-340-330-53-R0) — *RF Cavity Low Power Calibration Procedure*;  
> LBL-34960 (Rimmer et al.) Table 1 — R_s, β, Q₀, wall loss per cavity.  
> **Notation**: R_s uses the circuit definition V²/2P (linac convention gives R_s_linac = V²/P = 7.0 MΩ).  
> R/Q ≈ R_s/Q₀ = 3.5 MΩ / 30,000 ≈ 117 Ω (circuit) or ~233 Ω (linac).  
> The loaded Q value of 6,522 is derived from Q₀=30,000 and β=3.6; measured values on individual  
> cavities may differ by ~5% due to manufacturing variations and coupling adjustment.

### 6.2 Cavity Calibration Parameters

From the low-power calibration procedure:

- **Resonance temperature correction**: Δf_T = (35°C - T) × (-7.95 kHz/°C)
- **Vacuum correction**: Δf_v = +124 kHz
- **Target frequency at 35°C & vacuum**: f = 476,000 + 100 kHz (±tolerance)
- **Fixed tuner adjustment**: 30 kHz/mm, +2/-3 mm nominal range
- **Sampling probe coupling target**: At 150 kW wall dissipation and Q₀=30,000, 1W signal at cable end
- **Sampling probe formula**: Ps/Pinc = -51.8 dB + 10·log(Q₀/30,000) + 10·log[4β/(1+β)²] + 0.6 dB

### 6.3 Klystron Parameters

| Parameter | Value |
|-----------|-------|
| Operating Frequency | 476 MHz |
| Maximum CW Output Power | 1.2 MW |
| Beam Voltage | ~65-90 kV |
| Beam Current | ~23 A |
| HVPS Rating | 2 MW (90 kV, 23 A) |
| Perveance | 0.75 μA/V^(3/2) |
| Drive Power (at saturation) | ~50 W typical |
| Operating Point | ~10% below saturation |
| Gain Variation | Up to 7 dB over operating voltage range |
| Focus Supplies | 2 per klystron (Focus #1, Focus #2) |
| Filament Supply | 1 per klystron |

---

## 7. High-Voltage Power Supply (HVPS) System

### 7.1 HVPS Specifications

- **Rating**: 2 MW (90 kV, 23 A)
- **Location**: Outside the RF support building
- **Type**: Switching power supply
- **Ripple**: 50 kHz switching frequency creates amplitude/phase modulation on klystron output
- **Controls**:
  - HVPS on/off request from VXI
  - HVPS reset from VXI
  - Contactor open/close from VXI
  - HVPS ready signal → VXI
  - Contactor status → VXI
  - HVPS on/off status → VXI
  - Voltage set-point (DAC) from HVPS loop

### 7.2 Focus and Filament Supplies

- **Focus Supply #1**: Voltage and current monitored via analog inputs
- **Focus Supply #2**: Voltage and current monitored via analog inputs
- **Filament Supply**: Voltage monitor, current monitor, current limit, on/off control

### 7.3 Station Power-Up Sequence

The station power-up is controlled by an **EPICS state sequence** (`rf_states.st`):

**State Machine States**: OFF → PARK → TUNE → ON_CW → ON_CW+Direct Loop → FAULT

**Fast Turn-On Procedure** (for beam abort recovery, <20 seconds):
1. Preset tuner positions, loop gains, and baseband IQ references to no-beam values
2. Apply klystron HV corresponding to no-beam condition
3. Once klystron reaches nominal output, all feedback loops settle automatically

**Standard Turn-On Procedure** (~3 minutes):
1. Energize station at moderate gap voltage with feedback loops disabled
2. Ramp up Direct Loop gain
3. Ramp up Comb Loop gain
4. Raise gap voltage to desired level

> **Reference**: `ps3403305800.pdf` — *RF Station Startup & Conditioning*;  
> Legacy EPICS code in `llrf/legacyLLRF/rf_states.st` (Robert C. Sass, March 1997).

---

## 8. Klystron Drive Chain

### 8.1 Signal Chain Detail

```
DAC Reference (I_REF, Q_REF from Gap Module)
       │
       ▼
  Error Computation: Error = Reference - Cavity_Sum
       │
       ▼
  PID Controller (Direct Loop)
       │
       ▼
  Comb Filter Addition (if Comb Loop active)
       │
       ▼
  Baseband Modulator (4× Gilbert-cell multipliers)
  ├── Gain tracking compensation for klystron HV variation
  └── Soft limiter (1N4157 Schottky diodes, ±1V threshold)
       │
       ▼
  Voltage-to-Current Amplifier (transimpedance)
       │
       ▼
  IQ RF Modulator (up-converts to 476 MHz)
       │
       ▼
  Fixed Attenuators (set operating point)
       │
       ▼
  Quad DAC (fine gain control)
       │
       ▼
  120 W Solid-State Drive Amplifier (up to ~+51 dBm output)
       │
       ▼
  Klystron (1.2 MW CW output; ~50 W drive at saturation)
```

### 8.2 Drive Power Limiting

To prevent klystron overdrive:
- **Baseband limiter**: Back-to-back Schottky diodes across feedback resistor
- **Drive power limiter** (proposed upgrade): Linear detector in IQA module detects actual drive power; if it exceeds a programmable set-point, both baseband signals are reduced proportionally to decrease drive while maintaining output phase
- **Critical operating trade-off**: Balancing maximum available drive power vs. dynamic range of the baseband modulator

---

## 9. Cavity Tuner System

### 9.1 Tuner Hardware

- **Type**: Movable plunger tuner (one per cavity)
- **Actuator**: Stepping motor with limit switches
- **Controller**: Stepping motor controller modules in VXI crate (4 per station)
- **Nominal insertion**: 8 mm (operating position)
- **Tuning range**: From "all way out" to "all way in" (full travel)
- **Frequency sensitivity**: ~30 kHz/mm

### 9.2 Tuner Control Loop

The tuner loop is a **software loop** running in the EPICS IOC:
1. Digital IQ detectors measure phase of forward power vs. cavity probe signal
2. The phase difference indicates detuning from resonance
3. Loop adjusts stepping motor position to maintain resonance
4. Also compensates thermal frequency drift during operation

### 9.3 Cavity FM Processing

During commissioning and conditioning, the LLRF system can sweep the RF frequency across the cavity resonance (FM mode). This is used for:
- Initial cavity processing and conditioning
- Measuring resonance curves
- Establishing resonance conditions for each cavity

> **Reference**: `ps3403305300.pdf` (PS-340-330-53-R0), pages 3-4;  
> SPEAR3 upgrade: Galil DMC-4143 motion controller replaces VXI stepping motor controllers.

---

## 10. Interlock and Machine Protection System

### 10.1 Interlock Architecture

The PEP-II RF station interlock system uses multiple layers:

**Layer 1 — VXI Arc Detector/Interlock Module:**
- Arc detection from cavity probes (8 channels)
- Fast hardware interlock logic (AND gates, first-fault latch)
- Fiber optic I/O for remote interlocks
- Heartbeat watchdog
- Interlock summary to EPICS

**Layer 2 — Allen-Bradley PLC (Process Logic Controller):**
- Temperature readback and monitoring
- Water system interlocks (flow, delta-T, over-temp)
- Magnet over-temperature
- Waveguide air pressure monitoring
- Most slow interlock functions

**Layer 3 — EPICS Software Interlocks:**
- Software-implemented protection logic
- State machine fault handling and auto-recovery
- HVPS control interlocks

### 10.2 Interlock Signals

From the station block diagram, the following signals feed into the interlock system:

| Signal | Source | Type |
|--------|--------|------|
| Circulator water temp | Water system | Analog → PLC |
| Water delta temp | Water system | Analog → PLC |
| Water flow | Water system | Analog → PLC |
| Magnet over temp | Magnets | Digital → PLC |
| Arc detection (8ch) | Cavity probes/waveguide | Fast analog → VXI |
| Beam abort | Machine protection | Digital → VXI |
| Waveguide air pressure | Pressure sensor | Analog → PLC |
| HVPS fault status | HVPS | Digital → VXI |
| Klystron reflected power | Directional coupler | Analog → IQA |
| Key controller | Local panel | Digital → VXI |

### 10.3 Station Operating Modes (Local Panel)

Three mode positions on the local panel:
- **LOCAL**: Full local control
- **PROCESS**: Limited local/remote control
- **AUTO**: Full remote/EPICS control

> **Reference**: `bd3403300000.pdf` — local panel interface details;  
> `ps3403305700.pdf` (PS-340-330-57-R0) — *RF Station Interlock Test Procedure*.

---

## 11. Control System Architecture

### 11.1 EPICS-Based Control

The entire LLRF system runs under **EPICS** (Experimental Physics and Industrial Control System):

- **IOC**: VxWorks-based EPICS IOC running on VME/VXI processor (Slot 0)
- **State Sequences**: Written in State Notation Language (SNL) for station state management
- **Key State Sequence Programs**:
  - `rf_states.st` — Main station state machine (OFF/PARK/TUNE/ON_CW/FAULT)
  - `rf_hvps_loop.st` — HVPS control loop
  - `rf_dac_loop.st` — DAC control loop
  - `rf_tuner_loop.st` — Tuner control loop
  - `rf_calib.st` — Calibration routines
  - `rf_msgs.st` — Message handling
- **Operator Interface**: EPICS-based GUI displays (EDM/MEDM panels)
- **MATLAB Integration**: MATLAB applications accessible through dedicated panel for calibration and diagnostic routines

### 11.2 Allen-Bradley PLC Interface

- **PLC Type**: Allen-Bradley SLC-500 family (original PEP-II/SPEAR3 legacy)
- **Communication**: DH-485 network via AB VME Scanner in VXI crate
- **Functions**:
  - Temperature monitoring (thermocouples — 12 channels in separate crate)
  - Analog input monitoring (32 channels)
  - Water system interlocks
  - Slow interlock functions
  - Status reporting to EPICS

### 11.3 Network Architecture

```
EPICS Workstation (in support building)
       │ Ethernet
       ▼
  VXI Crate EPICS IOC ←──→ Allen-Bradley PLC (DH-485)
       │                         │
       ├── VXI RF Modules         ├── Thermocouple inputs
       ├── Stepping Motors         ├── Analog inputs (32ch)
       ├── Arc Detector            ├── Water interlocks
       └── HVPS Interface          └── Misc slow interlocks
                │
       Fiber Optic Links
       ├── Longitudinal Feedback System
       ├── Beam Phase Monitors
       └── Remote I/O (SLC-500)
```

### 11.4 Built-In Diagnostics

**Network Analyzer:**
- Each LLRF system contains a built-in baseband network analyzer
- Can measure open-loop and closed-loop transfer functions
- Interfaces with MATLAB for automated measurements
- `MeasDirCls` routine measures Direct+Comb loop closed-loop response without disturbing stored beam

**Transient Recorders (History Buffers):**
- Circular buffers throughout the system record selected RF signals
- After a fault, buffers are frozen and data stored to disk files
- Enables post-mortem analysis of intermittent faults
- Extremely valuable for diagnosing beam loss events

**Arbitrary RF Function Generator:**
- Built into the VXI system
- Used for cavity FM processing, noise injection, and diagnostic measurements

---

## 12. Waveguide Network and Power Distribution

### 12.1 Waveguide Configuration

- **Type**: WR2100 waveguide (standard for 476 MHz)
- **Klystron output** → Circulator → Power splitting network
- **Circulator**: Protects klystron from reflected power; terminates into high-power load
- **Power splitting**: Magic-Tee hybrid junctions
  - HER: 3 Magic-Tees → 4 cavity feeds + high-power dummy loads on difference ports
  - LER: 1 Magic-Tee → 2 cavity feeds + 1 high-power dummy load
  - Load power rating sized for full reflected/imbalance power (worst-case: up to half of klystron output per load)
- **Penetrations**: 4 waveguide runs through wall into tunnel (HER) or 2 (LER)
- **Pressurization**: 0.25 psig instrument air (dried), pressure-switch interlocked

### 12.2 Waveguide Flange Requirements

- All flange bolts torqued to **30 ft-lbs**
- Inspection: Minimum 6 random bolts per flange must exceed **25 ft-lbs**
- Gas leak test: Pressurize to 0.25 psig, check with "Snoop" for bubbles
- RF leakage survey: <0.1 mW/cm² at 100 kW klystron output

### 12.3 Waveguide Pressure Interlock

- Two zones per station, each with pressure switches and gauge
- Pressure drop triggers station shutdown and beam abort
- Annual verification required (loosen air supply, verify trip at 3 inches)

> **Reference**: `ps3403305600.pdf` (PS-340-330-56-R0/61-R2) — *RF Non-Ionizing Radiation Safety Procedure*;  
> `ps3403306102.pdf` (PS-340-330-61-R2) — extended safety procedures with waveguide work control.

---

## 13. Cavity Low-Power Calibration

### 13.1 Procedure Overview

The RF cavity low-power calibration is performed before high-power operation:

1. **Preparation**: Cavity fully assembled with all accessories (HOM loads, coupling network, window, fixed tuner, movable tuner at 8mm insertion, sampling loop). Purged with N₂ at atmospheric pressure.

2. **Equipment**: WR2100/Coax Type N Adapter, HP 8719 Network Analyzer, Type N Cal Kit, Temperature Meter

3. **Measurements**:
   - Resonant frequency in S11 mode
   - Temperature correction to 35°C
   - Vacuum correction (+124 kHz)
   - Verify target frequency within tolerance
   - Measure input coupling β
   - Measure loaded Q (via S21 transmission through sampling probe)
   - Calculate unloaded Q₀ = Qₗ(1+β)
   - Calculate external Qe = Q₀/β

4. **Sampling Loop Setting**:
   - Target: 1W at cable end for 150 kW cavity wall dissipation at Q₀=30,000
   - Coupling adjustment by rotating shorted side of loop
   - Tightening correction: -0.5 dB before tightening
   - Acceptable variation: ±0.3 dB

> **Reference**: `ps3403305300.pdf` (PS-340-330-53-R0) — *RF Cavity Low Power Calibration Procedure*, Heinz Schwarz, July 1997.

---

## 14. RF Station Operating Procedures

### 14.1 Station States

The EPICS state machine manages these station states:

| State | Description | Loops Active |
|-------|-------------|--------------|
| OFF | Station powered down, HVPS off | None |
| PARK | Cavities parked at park frequency, RF off | None |
| TUNE | Tuner loop active, measuring resonance | Tuner only |
| ON_FM | FM mode for cavity conditioning | Tuner |
| ON_CW | CW RF on, klystron at power | HVPS, DAC, Tuner, Ripple |
| ON_CW+Direct | Full beam operation | All loops active |
| FAULT | Station tripped, fault recorded | None (auto-recovery may restart) |

### 14.2 Auto-Recovery

The state machine includes **automatic reset/restart logic**:
- After a beam abort, stations will attempt to automatically restart
- Fast turn-on (<20 seconds) is critical above ~300 mA beam current
- All stations trip simultaneously on cavity reflected power after beam abort
- The state machine can be programmed to wait for various conditions before restart

### 14.3 Fault Diagnosis

After a fault:
1. Circular buffers freeze with pre-fault and post-fault data
2. Selected waveforms are written to disk files
3. Post-mortem analysis tools available via MATLAB
4. Fault signature analysis distinguishes:
   - Cavity arc (large reflected power perturbation)
   - Loss of cavity probe signal (drive saturates, no reflected power spike)
   - HVPS fault (voltage drop signature)
   - Water system fault (slow temperature drift)

> **Reference**: `ps3403305800.pdf` — *RF Station Startup & Conditioning*;  
> `ps3403305900.pdf` — *RF Station Maintenance*.

---

## 15. Safety Systems

### 15.1 Non-Ionizing Radiation (RF)

- Waveguide flange torque: 30 ft-lbs (inspection threshold: 25 ft-lbs)
- RF leakage limit: **0.1 mW/cm²** at accessible waveguide joints
- Waveguide pressurized at 0.25 psig with dried instrument air
- Pressure interlock shuts down station on leak detection
- Annual RF radiation survey required on all stations
- Survey also required after each waveguide opening or major downtime

### 15.2 Ionizing Radiation (X-Ray from Klystron)

- Klystron lead shielding panels and collector lead panels required
- Radiation limit: **<5 mR/hr** at 30 cm from klystron surface, **<100 mR/hr** on contact
- Klystron area posted as Radiation Area (RA)
- Personnel in klystron area during survey must be RWT-I certified
- RP Field Operations Group performs ionizing radiation surveys

### 15.3 High-Voltage Safety

- HVPS has lock-out provisions via grounding switch
- Lock-and-Tag procedures required before klystron removal
- HVPS Hoffman Box cover must be in place with securing bolts
- Four screws must secure HV cable to klystron

### 15.4 Waveguide Safety Work Control

Two scenarios requiring formal work control:
1. **Component removal/repair**: Bend Magnet Chopper Supplies locked off, waveguide shorting plates installed
2. **Station testing without cavities**: Waveguide shorting plate on circulator output, HVPS PPS bypass required, RHP sign-off needed

> **Reference**: `ps3403305400.pdf` (PS-340-330-54-R0) — *RF Station Safety Certification Check-Off List*;  
> `ps3403305503.pdf` (PS-340-330-55-R3) — *RF Station Safety Survey*;  
> `ps3403305600.pdf` / `ps3403306102.pdf` — *RF Non-Ionizing Radiation Safety Procedure*.

---

## 16. Relevance to SPEAR3 LLRF Upgrade

### 16.1 SPEAR3 RF System Configuration

SPEAR3 adopted the PEP-II RF technology in 2003:

| Parameter | SPEAR3 Value |
|-----------|-------------|
| Beam Energy | 3.0 GeV |
| Design Stored Current | 500 mA |
| RF Frequency | 476.3 MHz |
| Total RF Voltage | 3.2 MV |
| Gap Voltage per Cavity | 800 kV |
| Number of Cavities | 4 |
| Klystrons | 1 × 1.2 MW CW |
| Cavity Type | PEP-II single-cell, HOM-damped copper |
| LLRF System | PEP-II VXI-based LLRF (direct copy) |
| Circumference | 234 m |
| Harmonic Number | 372 |

The SPEAR3 configuration is essentially a single **PEP-II HER RF station** with cavities tuned to 476.3 MHz instead of 476.0 MHz.

### 16.2 Current Upgrade Project

The SPEAR3 LLRF upgrade project replaces the legacy VXI hardware with modern equivalents while preserving the proven control architecture:

| Legacy Component | Upgrade Replacement |
|-----------------|-------------------|
| VXI LLRF Modules | Dimtel LLRF9/476 (4 units) |
| Allen-Bradley SLC-500 PLC | Allen-Bradley ControlLogix 1756 (Klystron MPS) |
| Allen-Bradley PLC (HVPS) | CompactLogix PLC |
| VXI Stepping Motor Controllers | Galil DMC-4143 Motion Controller |
| VXI Arc Detector | Microstep MIS sensors + process chassis |
| VXI Waveform Buffers | Custom PCB with ADC + comparators |
| VXI Interface Chassis | New Interface Chassis (AND-gate, first-fault, fiber I/O) |
| EPICS SNL State Machines | Python/EPICS Coordinator |
| VxWorks EPICS IOC | Modern Linux EPICS IOC |

### 16.3 Key Design Principles Preserved

The following PEP-II LLRF design principles are preserved in the SPEAR3 upgrade:

1. **Baseband I/Q processing** — The Dimtel LLRF9 implements the same I/Q feedback architecture
2. **Direct + Comb feedback loops** — Same cascaded loop topology with impedance reduction
3. **Tuner loop** — Software-based tuner loop with stepping motor control (now via Galil)
4. **HVPS loop** — Slow loop to maintain klystron headroom
5. **Gap feed-forward** — Ion clearing gap compensation
6. **EPICS control** — Full EPICS integration with state machine control
7. **Interlock architecture** — Hardware AND gates, first-fault latch, fiber I/O
8. **Post-mortem diagnostics** — Waveform buffers for fault analysis

### 16.4 Design Differences in the Upgrade

| Aspect | Legacy (PEP-II) | Upgrade (SPEAR3) |
|--------|-----------------|-------------------|
| Feedback processing | Analog + limited digital | Fully digital (FPGA-based in LLRF9) |
| I/Q detection | Custom VXI analog/digital hybrid | Integrated in LLRF9 digital receiver |
| Network analyzer | Custom VXI-based | Built into LLRF9 |
| State machine | SNL/VxWorks | Python/EPICS on Linux |
| PLC interface | DH-485 via VME scanner | EtherNet/IP direct |
| Woofer interface | Fiber optic to LFB system | TBD for SPEAR3 |
| Beam gap FF | Per-revolution learning | LLRF9 integrated |

---

## 17. Reference Documents

### 17.1 Legacy Architecture Documents (in this repository)

All documents are located in `llrf/documentation/legacyArchitecture/`:

| File | Drawing/Doc Number | Title | Pages | Author |
|------|-------------------|-------|-------|--------|
| `bd3403300000.pdf` | BD-340-330-00-R0 | PEP-II LER RF Station Block Diagram | 1 | P. Corredoura, 1/28/99 |
| `bd3403300100.pdf` | BD-340-330-01-R0 | PEP-II LER LLRF Configuration Block Diagram | 1 | P. Corredoura, 1/28/98 |
| `blockDiagrambd3403290100-1.pdf` | BD-340-329-01 | PEP-II HER LLRF Configuration Block Diagram | 1 | P. Corredoura, 1/26/98 |
| `ps3403305100.pdf` | PS-340-330-51-R0 | PEP-II RF System Description | 11 | H. Schwarz, 7/21/99 |
| `ps3403305200.pdf` | PS-340-330-52-R0 | LLRF Feedback Loop Description | 8 | H. Schwarz, 7/21/99 |
| `feedbackLoopDescriptionps3403305200.pdf` | PS-340-330-52-R0 | LLRF Feedback Loop Description (copy) | 8 | H. Schwarz, 7/21/99 |
| `ps3403305300.pdf` | PS-340-330-53-R0 | RF Cavity Low Power Calibration Procedure | 4 | H. Schwarz, 7/2/1997 |
| `ps3403305400.pdf` | PS-340-330-54-R0 | RF Station Safety Certification Check-Off List | 2 | H. Schwarz, 4/19/99 |
| `ps3403305503.pdf` | PS-340-330-55-R3 | RF Station Safety Survey | 4 | A. Hill, 12/2/05 |
| `ps3403305600.pdf` | PS-340-330-56-R0 | RF Non-Ionizing Radiation Safety Procedure | 4 | H. Schwarz, 4/19/99 |
| `ps3403305700.pdf` | PS-340-330-57-R0 | RF Station Interlock Test Procedure | 2 | H. Schwarz |
| `ps3403305800.pdf` | PS-340-330-58-R0 | RF Station Startup & Conditioning | 4 | H. Schwarz |
| `ps3403305900.pdf` | PS-340-330-59-R0 | RF Station Maintenance | 7 | H. Schwarz |
| `ps3403306001.pdf` | PS-340-330-60-R1 | Klystron Specifications | 5 | H. Schwarz |
| `ps3403306102.pdf` | PS-340-330-61-R2 | RF Non-Ionizing Radiation Safety Procedure (Extended) | 13 | H. Schwarz/J. Johnson, 4/19/99 |

### 17.2 Legacy EPICS Source Code

Located in `llrf/legacyLLRF/`:

| File | Purpose |
|------|---------|
| `rf_states.st` | Main station state machine (OFF/PARK/TUNE/ON_CW/FAULT) |
| `rf_hvps_loop.st` | HVPS control loop implementation |
| `rf_hvps_loop_defs.h` / `_macs.h` / `_pvs.h` | HVPS loop definitions, macros, PV names |
| `rf_dac_loop.st` | DAC control loop implementation |
| `rf_dac_loop_defs.h` / `_macs.h` / `_pvs.h` | DAC loop definitions, macros, PV names |
| `rf_tuner_loop.st` | Tuner control loop implementation |
| `rf_tuner_loop_defs.h` / `_macs.h` / `_pvs.h` | Tuner loop definitions, macros, PV names |
| `rf_loop_defs.h` / `_macs.h` | Common loop definitions and macros |
| `rf_calib.st` | Calibration routines |
| `rf_msgs.st` | Message handling |

---

## 18. External Publications

### 18.1 Key SLAC Technical Reports

| Publication | Authors | Year | DOI/Reference |
|-------------|---------|------|---------------|
| "Architecture and Performance of the PEP-II Low-Level RF System" | P. Corredoura | 1999 | SLAC-PUB-8124, DOI: 10.2172/10204 |
| "Low Level System Design for the PEP-II B Factory" | P. Corredoura et al. | 1995 | PAC 1995 |
| "Experience with the PEP-II RF System at High Beam Currents" | P. Corredoura et al. | 2000 | SLAC-PUB-8498, EPAC 2000 |
| "Digital I/Q Demodulator" | C. Ziomek, P. Corredoura | 1995 | PAC 1995 |
| "Operator Interface for the PEP-II Low Level RF Control System" | S. Allison, R. Claus | 1997 | PAC 1997 |
| "Impedance Study for the PEP-II B-factory" | S. Heifets, K. Ko, C. Ng et al. | 1995 | SLAC/AP-99, March 1995 |
| "RF Cavity Development for the PEP-II B Factory" | R. A. Rimmer | 1992 | LBL-33360 |
| "High-Power RF Cavity R&D for the PEP-II B Factory" | R. Rimmer, G. Lambertson et al. | 1994 | LBL-34960 |
| "The SPEAR3 RF System" | P. McIntosh | 2005 | SLAC-PUB, DOI: 10.2172/839730 |
| "An Automated 476 MHz RF Cavity Processing Facility at SLAC" | P. McIntosh, A. Hill, H. Schwarz | 2003 | SLAC-PUB-10083 |
| "Booster Synchrotron RF System Upgrade for SPEAR3" | S. Park, J. Corbett | 2010 | IPAC 2010 |
| "Design of the SPEAR 3 Light Source" | R. Hettel et al. | 2001 | PAC 2001 |
| "SSRL RF System Upgrade" | S. Park | 1999 | EPAC 1999 |
| "PEP-II Asymmetric B Factory: R&D Results" | J. Dorfan, A. Hutton et al. | 1992 | SLAC-PUB-5785, LBL-PUB-32098 |

### 18.2 Journal Papers

| Publication | Authors | Year | DOI |
|-------------|---------|------|-----|
| "Lessons Learned from PEP-II Low Level RF and Longitudinal Feedback" | J. Fox, T. Mastorides, C. Rivetta, D. Van Winkle, D. Teytelman | 2010 | Phys. Rev. ST-AB 13, 052802 |
| "Modeling and Simulation of Longitudinal Dynamics for LER-HER at PEP-II" | C. Rivetta et al. | 2007 | Phys. Rev. ST-AB 10, 022801 |

### 18.3 Online Resources

| Resource | URL |
|----------|-----|
| SPEAR3 Overview | https://www-ssrl.slac.stanford.edu/spear3/ |
| SPEAR LLRF Controls (EPICS) | https://slac.stanford.edu/grp/ssrl/spear/epics/app/rf/index.html |
| PEP-II LLRF System (OSTI) | https://www.osti.gov/biblio/10204 |
| SPEAR3 RF System (OSTI) | https://www.osti.gov/biblio/839730 |

---

## Appendix A: Glossary

| Term | Definition |
|------|-----------|
| **LLRF** | Low-Level RF — the control system that regulates cavity fields |
| **VXI** | VME eXtensions for Instrumentation — modular instrument standard |
| **EPICS** | Experimental Physics and Industrial Control System |
| **IQ** | In-phase / Quadrature — complex signal representation |
| **IQA** | I/Q Amplitude Detector module |
| **RFP** | RF Processing module |
| **HER** | High Energy Ring (9 GeV electrons) |
| **LER** | Low Energy Ring (3.1 GeV positrons) |
| **HVPS** | High Voltage Power Supply |
| **HOM** | Higher-Order Mode |
| **LFB** | Longitudinal Feedback system |
| **MPS** | Machine Protection System |
| **PPS** | Personnel Protection System |
| **SNL** | State Notation Language (EPICS sequencer) |
| **DH-485** | Allen-Bradley industrial communication protocol |
| **Magic-Tee** | Waveguide hybrid junction for power splitting |
| **Circulator** | Ferrite device routing RF power in one direction |
| **FM mode** | Frequency Modulation mode for cavity conditioning |
| **CW** | Continuous Wave |
| **LCW** | Low Conductivity Water |
| **HCW** | High Conductivity Water |

---

*End of Technical Notes*

*This document was generated by extracting and synthesizing information from the original PEP-II engineering documents stored in `llrf/documentation/legacyArchitecture/`, combined with publicly available SLAC technical reports and journal publications. For complete technical detail, refer to the original PDF documents listed in Section 17. The original documents contain engineering drawings and block diagrams that provide visual detail beyond what is captured in text form here.*
