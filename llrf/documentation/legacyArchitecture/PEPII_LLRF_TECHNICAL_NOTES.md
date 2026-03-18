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
16. [SPEAR3 RF System — Comprehensive Operational Reference](#16-spear3-rf-system--comprehensive-operational-reference)
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

## 16. SPEAR3 RF System — Comprehensive Operational Reference

> **Sources**: `Designs/0_PHYSICAL_DESIGN_REPORT.md` (PDR, Rev 1, March 2026);
> `llrf/documentation/LLRFOperation_jims.docx` (J. Sebek, SSRL RF Operations Guide);
> `llrf/documentation/LLRFDocumentationNotesR2.docx` (J. Sebek, Nov 2021);
> `llrf/documentation/fiberOpticCableSignalControlRev3.docx` (J. Sebek, June 2022);
> `llrf/documentation/LLRFUpgradeTaskListRev3.docx` (July 2025);
> `llrf/documentation/LocalPanelToXConnectMapping.xlsx`;
> `llrf/documentation/RfSystemDocumentIndexR3.xlsx`.

### 16.1 SPEAR3 RF System Parameters

SPEAR3 adopted PEP-II RF technology in 2003, installing a single PEP-II HER RF station:

| Parameter | Design Value | Operating Value |
|-----------|-------------|-----------------|
| Beam Energy | 3.0 GeV | 3.0 GeV |
| Design Stored Current | 500 mA | 500 mA |
| RF Frequency | 476.3 MHz | 476.3051755 MHz (precise) |
| Total Gap Voltage | 3.2 MV (design) | ~2.85 MV (operational) |
| Gap Voltage per Cavity | 800 kV (design) | ~712 kV (operational) |
| Number of Cavities | 4 | 4 (single-cell, individual tuners) |
| Klystron Rated Power | 1.5 MW CW | ~800 kW typical operating |
| HVPS Voltage (max) | −90 kV | ~−74.7 kV at 500 mA beam |
| Drive Power | — | ~29 W nominal |
| Cavity Type | PEP-II single-cell, HOM-damped copper | Same |
| Circumference | 234 m | 234 m |
| Harmonic Number | 372 | 372 |
| Revolution Frequency | — | ~2.035 MHz |

> **Source**: Gap voltage and beam current data from LLRF9 commissioning measurements (`llrf/tests/llrf9Tests.pdf`, J. Sebek, 2021). SLAC-PUB-10083 (McIntosh et al., 2003) confirms SPEAR3 upgrade replaced the 358.54 MHz RF system with a PEP-II HER RF station at 476.3 MHz.

The SPEAR3 configuration is a single **PEP-II HER RF station** with cavities tuned to 476.3 MHz.

### 16.2 Physical Layout and Locations

| Location | Equipment | Notes |
|----------|-----------|-------|
| **B118** (Power Supply Room) | HVPS Controller (Hoffman Box) | HVPS control, PLC, Enerpro boards |
| **B514** (HVPS Substation) | HVPS Main Tank, Phase Tank (12 thyristor stacks), Crowbar Tank (4 stacks) | FR3 oil-filled, N₂ blanket |
| **Switchgear** (adj. B514) | Vacuum contactor (Ross HQ3), controller (Ross HCA-1-A), K4/MX/RR/L1 relays | 12.47 kV AC |
| **Termination Tank** (B132) | HV cable termination, Ross relay, Danfysik DC-CT, Pearson CT-110 | Mineral oil filled |
| **B132** (Klystron Building) | Klystron, drive amplifier, LLRF9 units, RF MPS PLC, motion controller, arc detector, IOC | Main control location |
| **B132-12, EL 36** | Local Panel (legacy interlock signal hub) | Fiber ↔ electrical conversion |
| **B132-14** | Cross-connect racks (X530, X15, etc.) | Signal distribution |
| **Storage Ring Tunnel** | 4 RF cavities, waveguide, tuner assemblies, arc detection sensors | Radiation area |

> **Source**: PDR §3, `LLRFDocumentationNotesR2.docx` §Action Items


### 16.3 Legacy SPEAR3 LLRF Controller (VXI System)

The legacy LLRF controller is a custom PEP-II analog RF Processor (RFP) module in a Kinetics Systems VXI chassis. The VXI crate contains:

| Module | Function |
|--------|----------|
| Kinetics Systems CPU | EPICS Processor running VxWorks RTOS |
| Allen-Bradley VME Scanner | Communication hub (serial link to all AB controllers) |
| Clock/RF Distribution Module | 476 MHz reference distribution |
| RFP Module | Analog RF processing — heart of fast feedback (~90 kHz bandwidth) |
| IQA Module × 3 | Amplitude/phase detection (~1 MHz bandwidth) |
| Arc Interface/Interlock Module | VXI interface to Fast Interlock Chassis |

**Control Software** — Six SNL programs compiled into a single `rfSeq` IOC library:

| Program | Lines | Function | Author |
|---------|-------|----------|--------|
| `rf_states.st` | 2,227 | Master state machine (OFF/PARK/TUNE/ON_CW/ON_FM) | R. Sass, 1997 |
| `rf_hvps_loop.st` | 343 | HVPS supervisory control (voltage regulation, drive power monitor) | — |
| `rf_dac_loop.st` | 290 | DAC control loop (drive power and gap voltage) | S. Allison, 1997 |
| `rf_tuner_loop.st` | 555 | Cavity tuner stepper motor control (×4 cavities, phase-based) | — |
| `rf_calib.st` | 2,800+ | Calibration (analog offset nulling, coefficient calibration, ~20 min) | R. Claus, PEP-II LLRF |
| `rf_msgs.st` | 352 | Message logging, HVPS fault monitoring, TAXI error detection | — |

> **Source**: PDR §2.1, §14.1; Legacy code at `llrf/legacyLLRF/`; GitHub: `https://github.com/slac-epics/rf-spear`
> EDM launch: `edm -x -m "STN=SRF1,RING=SPR,NCV=4CV,PS=RF-SOLN-MAIN" -eolc rf_station_4CVSPR.edl`

### 16.4 SPEAR3 RF Station Control Loops (Legacy)

There are several cascaded control loops operating at different timescales:

**Fast Analog Control (RFP Module, ~90 kHz bandwidth)**:
- Inputs: RF signals from four cavity probes
- Processing: Decomposes each into I/Q components, compares against setpoints, corrects errors
- Output: Reconstructed RF input to drive amplifier
- Almost entirely analog signal processing
- Two critical PVs: Loop Gain `SRF1:STNDIRECT:LOOP:COUNTS.A` and Loop Phase `SRF1:STNDIRECT:LOOP:PHASE.C`
- Transfer function center is detuned to lower frequency for stability against Robinson instability

**Digital Gain Control (DAC Loop, ~seconds)**:
- Monitors sum of gap voltages in four cavities
- Adjusts PV `SRF1:STN:ON:IQ` — RFP output linearly depends on this value
- Ultimate purpose: control total gap voltage of RF cavities

**HVPS Supervisory Loop (~seconds)**:
- Monitors klystron drive power `SRF1:KLYSDRIVFRWD:POWER`
- When drive power exceeds goal (`SRF1:KLYSDRIVFRWD:POWER:ON` or `:HIGH`), increases HVPS setpoint `SRF1:HVPS:VOLT:CTRL.VAL`
- Increased HVPS voltage → increased klystron gain → reduced required drive power
- Both DAC and HVPS loops remain active during normal operation (values vary a few tenths of percent)

**Spectral Performance** (Cavity A with 500 mA beam):
- Peaks at ~2.8 kHz: internal feedback loops for power-line ripple rejection
- Peaks at ~8.8 kHz: synchrotron oscillations, ~90 dB below fundamental
- Detuning angle not extremely critical for beam stability

> **Source**: `LLRFOperation_jims.docx` §Fast Analog Control, §HVPS Output Control, Figures 8–9

### 16.5 RF Station Turn-On Procedure (ON_CW Mode)

The turn-on sequence involves careful sequencing of power levels and control loop engagement:

**Phase 1 — Initialization**:
- Tuners moved to "TUNE/ON Home" positions (`SRF1:CAV1TUNR:POSN:ONHOME`)
- HVPS programmed to "Turn-On Voltage" (`SRF1:HVPS:VOLT:MIN`) → 50 kV
- RFP multiplying DAC set to "Fast On RFP Counts" (`SRF1:STN:ONFAST:INIT`) → ~100 counts
- Result: Few watts drive power, few hundred kV total gap voltage — sufficient for phase detection

**Phase 2 — Direct Loop Engagement**:
- DAC counts increased to ~200, raising drive power slightly
- Analog switch on RFP module closes, engaging direct loop feedback
- Switch adds an integrator to the analog feedback loop
- **Transient**: Drive power temporarily rises to ~45 W before settling to ~10 W
- At HVPS = 50 kV, klystron output only ~50 kW (safe level, no damage risk)
- Internal VxWorks controls prevent direct loop engagement if klystron output would exceed safe value

**Phase 3 — Slow Ramp (~10–20 seconds)**:
- Both DAC and HVPS voltage ramped up slowly
- System waits for direct loop transient to die out
- Then slow (~1 Hz) feedback loops become active
- DAC controls gap voltage; HVPS controls drive power headroom

**Phase 4 — Steady-State Operation**:
- All loops active and continuously regulating
- Gap voltage maintained to within a few tenths of percent

> **Source**: `LLRFOperation_jims.docx` §RF Station Turn-On, Figure 10



### 16.5a LLRF9 Digital Controller (Upgrade — Dimtel LLRF9/476)

The Dimtel LLRF9/476 replaces the legacy VXI RFP + IQA modules with a fully digital architecture:

| Parameter | Value |
|-----------|-------|
| RF Inputs | 9 channels per unit |
| Center Frequency | 476 MHz (customized for SPEAR3) |
| Input Bandwidth | ~6 MHz |
| Full-Scale Input Level | +2 dBm |
| Channel-to-Channel Isolation | 68 dB |
| Spurious-Free Dynamic Range | 66 dB |
| ADC Resolution | 12-bit |
| Readout Rate | 10 Hz (baseband I/Q at 4.4 Hz BW) |
| Klystron Drive Outputs | 2 (full-scale +9 dBm) |
| Spare/Calibration Outputs | 2 (full-scale -14 dBm) |
| **Direct Loop Delay** | **270 ns** (critical performance spec) |
| Feedback Loops | Direct (proportional) + Integral |
| Waveform Samples | 16,384 per channel |
| Ramp Profile Steps | 512 |
| Time Per Step | 70 ns - 37 ms |
| Interlock Timestamp Resolution | +/-17.4 ns |
| Network/Spectrum Analyzer | Integrated (1024 points) |

**Hardware Architecture** (per unit, 3 boards):
- 3 x LLRF4.6 processing boards (Xilinx Spartan-6 or Artix-7 FPGA)
- Aluminum cold plate with 3 TEC modules for thermal stabilization (boards 1 and 2 only)
- Board 3 has reduced thermal requirements

**IF/LO Frequency Plan**:
- IF = (1/12) x f_RF = 39.6921 MHz
- LO = (11/12) x f_RF = 436.6131 MHz
- ADC Clock = (11/48) x f_RF
- DAC Clock = (11/24) x f_RF

**SPEAR3 Two-Unit Configuration**:
- **Unit 1** (field control): Station Ref, Cav A/B/C probe, Cav A/B/C forward -> Klystron Drive output
- **Unit 2** (monitoring): Cav D probe/fwd/refl, Kly Fwd/Refl, Drive Fwd, Circ Load, WG loads
- **4 units purchased total** (2 active, 2 spare)

**24-Signal RF Monitoring Assignment**:

| Unit | Board | Ch1 | Ch2 | Ch3 | Ch4 | Output |
|------|-------|-----|-----|-----|-----|--------|
| 1 | BRD1 | Station Ref | Cav A Probe | Cav B Probe | Cav A Fwd | Klystron Drive |
| 1 | BRD2 | Station Ref | Cav C Probe | Cav C Fwd | Cav B Fwd | Spare/Monitor |
| 1 | BRD3 | Station Ref | Circ Load Fwd | WG Load 2 Fwd | WG Load 3 Fwd | -- |
| 2 | BRD1 | Station Ref | Cav D Probe | Cav D Fwd | Drive Fwd | -- |
| 2 | BRD2 | Station Ref | Cav D Refl | Kly Refl | Kly Fwd | -- |
| 2 | BRD3 | Station Ref | Cav A Refl | Cav B Refl | Cav C Refl | -- |

**6 signals NOT covered by LLRF9** (handled by Waveform Buffer System):
WG Load 1 Fwd, WG Load 1 Refl, Circ Load Refl, Station Ref (spare), WG Load 2 Refl, WG Load 3 Refl

> **Source**: PDR Sec.4, Sec.5; Dimtel LLRF9 product documentation (https://www.dimtel.com/products/llrf9)

### 16.6 SPEAR3 HVPS Power Section

The HVPS converts 12.47 kV RMS 3-phase AC to regulated DC high voltage for the klystron cathode:

| Parameter | Value |
|-----------|-------|
| Maximum output voltage | −90 kV DC |
| Maximum output current | 27 A |
| Maximum output power | 2.5 MW |
| Nominal operating voltage | −74.4 kV at 500 mA beam |
| Nominal operating current | 22 A |
| Rectifier topology | 12-pulse thyristor phase-controlled |
| Phase-shift transformer (T0) | 350 kVA extended delta, dual wye ±15° |
| Rectifier transformers T1, T2 | 1.5 MVA each, open-wye primary to dual-wye secondary, 12.5 kV |
| Rectifier stacks | 6 stacks × 14 Powerex T8K7 SCRs |
| Crowbar stacks | 4 thyristor stacks |
| Number of HVPSs | 2 (HVPS1 active, HVPS2 warm spare) |

**Legacy HVPS Controller** (Hoffman Box, B118):
- Allen-Bradley SLC-500 PLC (1747-L532 CPU, OBSOLETE)
- Enerpro FCOG6100 + FCOAUX60 (30° delayed triggering daughter board) gate driver
- Regulator card SD-237-230-14-C1 (INA117, INA114, OP77, BUF634, 4N32, VTL5C — OBSOLETE)
- Power supplies: SOLA ±15V/+5V/24V, Kepko 120V×2, Kepco 5V/20A, Kepco 240V
- Terminal strips: TS-5 (contactor, 15 terminals), TS-6 (grounding tank, 21 terminals), TS-3 (PPS LEDs), TS-7 (power distribution)

**SLC-500 PLC Slot Configuration**:

| Slot | Module | Function |
|------|--------|----------|
| CPU | AB-1747-L532 | Processor (OBSOLETE) |
| 1 | AB-1747-DCM | Data Communications/Scanner (OBSOLETE) |
| 2 | AB-1746-IO8 | 8-pt Digital I/O — Ross switch coil (OUT3, 120 VAC) |
| 3 | AB-1746-THERMC | Thermocouple inputs (SCR/air/transformer temps) |
| 5 | AB-1746-OX8 | 8-pt Relay Output — K4 relay (OUT2), Contactor On/Off (OUT1) |
| 6 | AB-1746-IB16 | 16 DC Input — PPS 1 (IN14), PPS 2 (IN15), Oil Level (IN8), Manual GRN SW (IN9) |
| 7 | AB-1746-IV16 | 16 DC Input (various permits) |
| 8 | AB-1746-NIO4V | 4-ch Analog I/O — voltage setpoint output to Enerpro via regulator (N7:10 → OUT0) |
| 9 | AB-1746-NI4 | 4-ch Analog Input — Danfysik HVPS current (IN3) |

> **Source**: PDR §6.2, `hvps/documentation/plc/plcNotesR1.docx`

**Five Independent Crowbar Triggering Sources** (defense-in-depth):

1. **SCR ENABLE** (fiber-optic): Interface Chassis → HVPS (loss of signal disables SCR triggers)
2. **TRANSFORMER ARC TRIGGER** (BNC-0): Stangenes transformer arc detection
3. **KLYSTRON CROWBAR** (fiber-optic): Interface Chassis → HVPS (klystron protection)
4. **KLYSTRON ARC TRIGGER** (BNC-12): Termination tank shunt sensing
5. **PLC FORCE CROWBAR** (Slot-5 OUT3): Active-low signal from SLC-500

**HVPS Turn-Off Dynamics** (from `fiberOpticCableSignalControlRev3.docx`, SLAC-PUB-7591):
- Normal turn-off (no crowbar): Within ~10 ms, HVPS power decreases to ~10% of operational value
- Filter inductors: 30 mH, 1.3 Ω winding resistance — discharge much faster than L/R time constant
- Only B phases of each bridge are fired at turn-off, latching up for inductor discharge path
- Crowbar functioning: <1 J of energy from HVPS reaches klystron
- **Even if crowbar fails to fire**: passive circuit elements (resistors, inductors) limit klystron arc energy to ~4 J — still below catastrophic damage threshold
- Conclusion: crowbar reduces discharge energy by additional factor of 4, but system is safe even without crowbar

> **Source**: `fiberOpticCableSignalControlRev3.docx`, SLAC-PUB-7591 (Cassel & Nguyen, PAC 1997)


### 16.7 Fiber Optic Signal Control (LLRF ↔ HVPS)

Three fiber optic cables connect the LLRF system to the HVPS controller. **⚠ WARNING: Signal naming conventions are inverted for the crowbar signal.**

| Signal | Direction | Illuminated Meaning | Loss of Light Meaning |
|--------|-----------|--------------------|-----------------------|
| **SCR Enable** | LLRF → HVPS | Permit to fire thyristors | Disables thyristor triggers (fail-safe) |
| **Klystron Crowbar (Off)** | LLRF → HVPS | Crowbar NOT fired (normal) | **Fires crowbar** (fail-safe) |
| **Status** | HVPS → LLRF | HVPS controller on, crowbar not commanded | HVPS fault or controller off |

**⚠ CRITICAL**: The "Klystron Crowbar" fiber is actually a "Crowbar Off" signal. Illuminated = crowbar NOT fired. Removing light causes crowbar to fire. This inverted naming has caused confusion in documentation.

**SCR Enable Logic** (should be enabled by AND of):
1. PLC summary OK signal
2. PLC Fiber Optic Crowbar Off signal
3. LLRF controller summary OK signal

**Crowbar Fire Conditions**: Should fire when manual grounding switch (mushroom) or Ross grounding relay is closed. The LLRF must also inhibit thyristor triggers whenever it fires the crowbar (redundant measure).

**Non-full-collector klystron safety concern**: If LLRF trips drive power without disabling HVPS, all HVPS output goes to the klystron collector (thermal damage risk). The LLRF system should disable SCR Enable immediately when drive power is removed, rather than waiting for MPS collector power calculation.

> **Source**: `fiberOpticCableSignalControlRev3.docx` (J. Sebek, June 2022), Figures 1–2

### 16.8 Allen-Bradley Communication Chain (Legacy)

The legacy AB communication topology is a serial daisy-chain from the VXI crate:

```
VXI Crate (AB VME Scanner)
  └──► DCM module in Top PLC-5 MPS crate (B132)
        ├── Serial to Bottom PLC-5 MPS crate (directly below)
        └── Daisy-chain from DCM terminals to:
              └──► DCM in SLC-500 Tuner Controller (B132)
                    └── Daisy-chain from SLC-500 terminals to:
                          └──► Telephone terminal box (above HVPS termination tank)
                                └──► Long-haul cable to SLC-500 HVPS PLC (B118)
```

**⚠ NOTE**: Block diagram BD-340-330-00 incorrectly shows two outputs from the VXI scanner. There is only **one** cable. All AB communication flows through this single serial link.

> **Source**: `LLRFDocumentationNotesR2.docx` §Allen-Bradley Connections

### 16.9 Legacy Interlock Architecture (Local Panel and Fast Interlock Chassis)

**Fast Interlock Chassis** (B132):
- Schematics: SD-340-308-01-R1 (transmitter board, 18 HFBR-1414 fiber transmitters) and SD-340-308-02-R1 (receiver board, DB25/DB37, RF detector, fiber receivers)
- RF detector: Coupled signal from klystron forward power (J32 input, J16/J31 outputs)
- DB25 connector J15 connects to VXI Arc Interlock Module (J3)
- DB37 connector J2 for arc detection (largely disconnected in existing system)

**VXI Arc Interlock Module** (SD-340-309-01-C2):
- 23 of 25 signals on J3 (to J15 on chassis) are **outputs** driven by VXI
- Only 2 inputs: AB_SUMMARY_FLT_BAR (Pin 10) and HEARTBEAT (Pin 23) — from Local Panel via fiber
- Key outputs: FILAMENT_ON (1), HVPS_ON (2), FILAMENT_TIMEOUT (3), SOLENOID_ON (14), ABORT_BAR (15), FAULT_RESET (16)

**Local Panel** (B132-12, EL 36):
- Signal conversion hub: electrical ↔ fiber-optic
- Schematic: SD-340-311-01-00 (scanned hardcopy by J. Wachter)
- Connectors J2, J3 (25-pin each) connect to cross-connect block X530 (B132-14 rack)
- Fiber transmitters: HFBR-1414 (soldered on PCB)
- Fiber receivers: HFBR-2414 or HFBR-2416 (Broadcom datasheet discrepancy noted, soldered on PCB)
- All cables enter chassis through rear slot, connect directly to PCB components

**Eight Fiber Optic Links** (Local Panel ↔ Arc Interlock Chassis):

| # | Cable | LP Component | AIC Connector | Signal Direction | Type |
|---|-------|-------------|---------------|-----------------|------|
| 1 | RESET | U16 (RX) | J50 | AIC → LP | Optical |
| 2 | FIL. TIMEOUT BYPASS | U15 (RX) | J49 | AIC → LP | Optical |
| 3 | VXI BEAM ABORT | U10 (RX) | J48 | AIC → LP | Optical |
| 4 | HVPS ON REQUEST | U12 (RX) | J47 | AIC → LP | Optical |
| 5 | FIL. AND FOCUS REQ. | U14 (RX) | J46 | AIC → LP | Optical |
| 6 | STATION ONLINE REQ. | U13 (RX) | J45 | AIC → LP | Optical |
| 7 | AB HEARTBEAT | U21 (TX) | J29 | LP → AIC | Optical |
| 8 | AB SUMMARY | U22 (TX) | J30 | LP → AIC | Optical |

> **Source**: `LLRFDocumentationNotesR2.docx` §Fiber Optic, §Fast Interlock, Tables 1–2


### 16.10 Local Panel Connector Mapping

**⚠ CRITICAL WARNING**: The J3 pin numbering is **reversed** between WD-340-330-02-R0 (cross-connect side) and SD-340-311-01 (Local Panel schematic). J3 pins 01–13 on the cross-connect diagram map to J3 pins 13–01 on the Local Panel, and J3 pins 14–25 map to J3 pins 25–14. This reversal is confirmed in the xlsx mapping and in `LLRFDocumentationNotesR2.docx`.

**J2 Connector** (25 pins — HVPS analog, solenoid/filament controls):

| LP Schematic Label | Pin | Cross-Connect Label | X-Connect |
|-------------------|-----|--------------------|-----------| 
| Vin+ (from HVPS) | J2-01 | HVPS Vin+ | X332-J2-01 |
| Iin+ (from HVPS) | J2-02 | HVPS Iin+ | X332-J2-02 |
| Vout (to AB) | J2-03 | HVPS Vout | X332-J2-03 |
| Iout (to AB) | J2-04 | HVPS Iout | X332-J2-04 |
| GND | J2-05 | Return | X332-J2-05 |
| SolenoidM Ctrl24 (AB) | J2-06 | Main Focus On | X332-J2-06 |
| SolenoidM Fault15 (sup) | J2-07 | Main Focus PS Interlock | X332-J2-07 |
| Filament Ctrl24 (AB) | J2-09 | Filament On | X332-J2-09 |
| Timeout Ctrl24 (AB) | J2-10 | Filament Timer Bypass | X332-J2-10 |
| HV Detected24 (AB) | J2-11 | HV Detected | X332-J2-11 |
| Local Mode24 (AB) | J2-12 | Local/Remote | X332-J2-12 |
| Vin- (from HVPS) | J2-14 | HVPS Vin- | X332-J2-14 |
| Iin- (from HVPS) | J2-15 | HVPS Iin- | X332-J2-15 |
| Solenoid Req24 | J2-18 | Online/Offline Request | X332-J2-18 |
| SolenoidB Ctrl24 | J2-19 | Bucking Coil PS On/Off | X332-J2-19 |
| SolenoidB Fault15 | J2-20 | Bucking Coil PS Interlock | X332-J2-20 |
| Filament Req24 | J2-21 | Filament PS On/Off | X332-J2-21 |
| Reset Req24 | J2-23 | Interlock Reset | X332-J2-23 |
| RF detected24 | J2-24 | RF On Indicator | X332-J2-24 |
| Online mode24 | J2-25 | Online/Offline Control | X332-J2-25 |

**J3 Connector** (25 pins — MPS summaries, interlocks, AB heartbeat):

| LP Schematic Label | LP Pin | X-Connect Label | LP Actual Pin (REVERSED) |
|-------------------|--------|----------------|-------------------------|
| Cavity1 Summary24 | J3-01 | Return | J3-13 |
| Cavity3 Summary24 | J3-02 | Return | J3-12 |
| Klystron Summary24 | J3-03 | Spare 4 | J3-11 |
| Focus Summary24 | J3-04 | Spare 2 | J3-10 |
| Magic Tee2 Summary24 | J3-05 | Interlock Sum | J3-09 |
| Waveguide Pressure24 | J3-06 | Temp Sum | J3-08 |
| Water Flow Summary24 | J3-07 | Flow Sum | J3-07 |
| Temperature Summary24 | J3-08 | Waveguide Air | J3-06 |
| AB Summary24 | J3-09 | Magic Tee 2 Sum | J3-05 |
| Cavity2 Summary24 | J3-14 | No Connect | J3-25 |
| Cavity4 Summary24 | J3-15 | Spare 5 | J3-24 |
| Collector Summary24 | J3-16 | Spare 3 | J3-23 |
| Magic Tee1 Summary24 | J3-17 | Waveguide Air MPS | J3-22 |
| Magic Tee3 Summary24 | J3-18 | AB Heartbeat | J3-21 |
| Circulator Summary24 | J3-19 | Vacuum Sum | J3-20 |
| Vacuum Summary24 | J3-20 | Circulator Sum | J3-19 |
| AB Heartbeat24 | J3-21 | Magic Tee 3 Sum | J3-18 |

> **Source**: `LocalPanelToXConnectMapping.xlsx`, `LLRFDocumentationNotesR2.docx` §Local Panel

### 16.11 Waveguide Air (NIRP) Interlock System

The SPEAR3 waveguide pressure interlock system differs from PEP-II (which combined waveguide systems):

| Signal Wire | Pressure Switch | Cross-Connect |
|------------|----------------|---------------|
| W1 Red | Waveguide 1 (long run) | X15-1 |
| W1 Black | Waveguide 1 (long run) | X15-2 |
| W2 Red | Waveguide 2 (long run) | X15-3 |
| W2 Black | Waveguide 2 (long run) | X15-4 |
| C1 Red | Circulator 1 (short run) | X15-5 |
| C1 Black | Circulator 1 (short run) | X15-6 |
| C2 Red | Circulator 2 (short run) | X15-7 |
| C2 Black | Circulator 2 (short run) | X15-8 |

Each system (long waveguide and circulator) has dual pressure switches for redundancy.

> **Source**: `LLRFDocumentationNotesR2.docx` §Waveguide Air, Table 3


### 16.12 SPEAR3 Tuner Control System (Detailed)

**Mechanical Tuner Assembly** (Drawing SA-341-392-61):
- **Stepper Motor**: Superior Electric Slo-Syn M093-FC11 (NEMA 34D, 200 steps/revolution)
- **Motor shaft pulley**: SDP/SI 6A 3-15DF03712 (15-groove timing belt pulley)
- **Lead screw pulley**: SDP/SI 6A 3-30H3708 (30-groove timing belt pulley)
- **Timing belt**: SDP/SI 6G 3-045037
- **Pulley gear ratio**: 30/15 = 2:1 → lead screw turns at ½ stepper motor speed
- **Lead screw**: Acme ½-10 thread (PF-341-392-68), 10 TPI = 0.1"/rev = 2.54 mm/rev
- **Linear motion per stepper revolution**: 0.5 × 2.54 mm = 1.27 mm

**Resolution Calculation**:
- 200 steps/revolution × 2 microsteps/step = 400 microsteps/revolution (motor)
- 1:2 gear ratio → 800 microsteps per lead screw revolution
- **Linear resolution**: 2.54 mm / 800 = **0.003175 mm per microstep** (~3.2 μm)
- Legacy deadband (RDBD): 5 microsteps = ~16 μm

**Operational Motion Characteristics**:
- Startup motion (home to initial position): ~2.5 mm (one lead screw revolution)
- Normal operation motion: ~0.2 mm (well above resolution and deadband)
- Linear potentiometers provide position indication (not used in feedback)

**Tuner Feedback Loops** (two cascaded):
1. **Primary cavity phase loop** (proportional/integral, ~1 Hz):
   - Measures phase difference between cavity forward power and probe signal
   - Adjusts tuner position to maintain resonant frequency slightly below f_RF
   - Driven by LLRF9 phase measurements (10 Hz)
2. **Load angle offset loop** (slower, supervisory):
   - Balances gap voltage across all 4 cavities
   - User sets `SRF1:CAV1:STRENGTH:CTRL` for each cavity's fraction of total gap voltage
   - Adjusts individual tuner phase setpoints to redistribute power

**Legacy Controller** (OBSOLETE):
- Motor controller: Allen-Bradley 1746-HSTP1 (high-speed stepper)
- Motor driver: Superior Electric SS2000MD4-M Slo-Syn PWM driver

**Upgrade Controller**: Galil DMC-4143 Rev 1.3h (4-axis, commissioned August 2025)
- Much finer resolution: 16–64 microsteps/step possible (vs. legacy 2)
- EPICS motor records via Ethernet
- Built-in LLRF9 tuner control PVs per cavity (GAIN_P, GAIN_I, OFFSET, CLOSE, MINFWD)

**Critical features to preserve in upgrade** (from `LLRFOperation_jims.docx`):
1. Home position establishment and reset
2. Minimum forward power threshold before engaging tuner loops
3. Load angle offset loop (best suited for EPICS application)
4. Step size enforcement (avoid excessive small steps → mechanical wear)
5. Motion profiles (acceleration/deceleration — legacy used only uniform pulse rates)
6. "Stop and Init" feature — aligns internal step counter with potentiometer readback
7. Robust driver recovery (power loss, communication loss scenarios)

> **Source**: `LLRFOperation_jims.docx` §RF Tuner Operation, §Mechanical Tuner Assembly, Figures 7, 11, 12; PDR §10

### 16.13 Klystron Cathode Heater System

**Legacy System** (Schematic: SD-340-311-00):
- Motor-driven variac providing continuously variable AC voltage
- 10:1 step-down toroidal isolation transformer (T1)
- Solid-state relay (SSR) for on/off switching
- Monitoring: AC voltmeter, ammeter, current transformer (Texmate CT), elapsed-time meter
- Remote control via Allen-Bradley PLC digital/analog I/O

| Parameter | Value |
|-----------|-------|
| AC Input | 120 VAC, 60 Hz |
| Maximum Power Rating | ~1 kW |
| Nominal Operating Power | ~500 W |
| Nominal Operating Voltage | 68 V (AC, at transformer input) |
| Nominal Operating Current | 7.3 A |
| Transformer Ratio | 10:1 step-down |
| Secondary Output | ~6.8 V RMS at 73 A |
| Maximum Rating | 14.0 V RMS at 71 A |

**Upgrade**: Commercial programmable AC supply (TDK/Lambda, Ametek, or Chroma). Controlled by RF MPS PLC via analog/Ethernet. Klystron does not receive permit unless heater reaches power level and times out. EPICS override available for short power dip scenarios.

> **Source**: PDR §13, `LLRFUpgradeTaskListRev3.docx`

### 16.14 Upgrade Project Component Map

| Legacy Component | Upgrade Replacement | Status |
|-----------------|-------------------|--------|
| VXI LLRF Modules | Dimtel LLRF9/476 (4 units) | **Complete** — in house |
| PLC-5 1771 (RF MPS) | ControlLogix 1756 | **Complete** — assembled, tested w/o RF |
| SLC-500 (HVPS) | CompactLogix PLC | **Complete** — modules for HVPS1, HVPS2, B44 |
| AB 1746-HSTP1 + Slo-Syn (Tuner) | Galil DMC-4143 Rev 1.3h | **Operational** — commissioned Aug 2025 |
| VXI Arc Detector | Microstep-MIS sensors (6 sensors) | **Needed** — ~$10k sensors + $10k adapters |
| VXI Waveform Buffers | Custom PCB (8 RF + 4 HVPS ch) | **Needed** — designed, not fabricated |
| Fast Interlock / Local Panel | New Interface Chassis | **Needed** — on critical path |
| EPICS SNL/VxWorks | Python/EPICS/MATLAB Coordinator | **Needed** — largest untouched software scope |
| VxWorks EPICS IOC | Modern Linux EPICS IOC (LLRF9 built-in) | Included with LLRF9 |
| Enerpro FCOG6100 | Enerpro FCOG1200 (5 boards) | **Needed** — ~$722 each |
| Regulator card SD-237-230-14-C1 | Redesigned analog regulator | **Needed** — design not started |
| Motor-driven variac (heater) | Programmable AC supply (COTS) | **Needed** |
| PPS through Hoffman Box | Dedicated PPS Interface Box (Bud enclosure) | **Needed** — proven design |

**Protection Layer Architecture** (four layers):

| Layer | Subsystem | Response Time | Function |
|-------|-----------|---------------|----------|
| 1 | LLRF9 FPGA | <1 μs | RF overvoltage, baseband window comparators, DAC zeroing |
| 2 | Interface Chassis | <1 μs | Hardware AND-logic, first-fault latch, fiber I/O |
| 3 | RF MPS PLC | ~ms | Fault aggregation, permit management, reset coordination |
| 4 | EPICS Coordinator | ~1 Hz | State machine, supervisory control, auto-recovery |

> **Source**: PDR §§17, 19; `LLRFUpgradeTaskListRev3.docx`

### 16.15 Known Documentation Errors and Discrepancies

| Issue | Details | Source |
|-------|---------|--------|
| BD-340-330-00 two scanner outputs | Block diagram shows two outputs from VXI AB scanner; there is only ONE cable | `LLRFDocumentationNotesR2.docx` |
| J3 pin numbering reversal | WD-340-330-02-R0 and SD-340-311-01 use reversed numbering for J3 | `LocalPanelToXConnectMapping.xlsx` |
| Crowbar signal naming | "Klystron Crowbar" is actually "Crowbar Off" — illuminated = no crowbar | `fiberOpticCableSignalControlRev3.docx` |
| HFBR-2414 vs HFBR-2416 | Local Panel receivers labeled HFBR-2414 but Broadcom datasheet says HFBR-2416 | `LLRFDocumentationNotesR2.docx` |
| WD-340-330-05/06-R0 | PEP-II waveguide air diagrams do not match SPEAR3 configuration | `LLRFDocumentationNotesR2.docx` |
| WD-340-330-02-R0 vs WD-340-330-25-R0 | Labeling differences between cross-connect and AB output module diagrams | `LLRFDocumentationNotesR2.docx` |
| Cav C/D wiring | WD-340-330-24-R0 only covers Cav A/B flow/vacuum interlocks; C/D documented by J. Wachter | `LLRFDocumentationNotesR2.docx` |

---


### 16.16 Complete SPEAR3 RF System Drawing Index

> **Source**: `RfSystemDocumentIndexR3.xlsx` (J. Sebek). Files at `/accphys/data/sebek/spear/llrf/documentation/` and `hvps/documentation/`.

**Block Diagrams**:

| Document | Description |
|----------|-------------|
| BD-340-330-00 | LER Station Block Diagram (⚠ has errors — see §16.15) |
| BD-340-330-01 | LER LLRF Configuration Block Diagram |
| BD-340-329-01 | HER LLRF Configuration Block Diagram |

**Process Specifications / Procedures**:

| Document | Description |
|----------|-------------|
| PS-340-330-51-R0 | RF System Description (11 pp, H. Schwarz) |
| PS-340-330-52-R0 | LLRF Feedback Loop Description (8 pp) — not all PEP-II loops used in SPEAR3 |
| PS-340-330-53-R0 | RF Cavity Low Power Calibration Procedure (4 pp) |
| PS-340-330-54-R0 | RF Station Safety Certification Check-Off List |
| PS-340-330-55-R3 | RF Station Safety Survey |
| PS-340-330-56-R0 | RF Station Coupling & Cable Calibration Procedure |
| PS-340-330-57-R0 | RF Station Full Power Test & Survey |
| PS-340-330-58-R0 | RF Station Cavity Phasing Procedure |
| PS-340-330-59-R0 | RF Station Turn-on Procedure |
| PS-340-330-60-R1 | Bellow Cavity Phasing Procedure |
| PS-340-330-61-R2 | RF Non-Ionizing Radiation Safety Procedure |

**LLRF Wiring Diagrams** (WD-340-330 series):

| Document | Description |
|----------|-------------|
| WD-340-330-02-R0 | Wiring to Local Panel (external systems, cross-connects, DB25 connectors) |
| WD-340-330-03-R0 | Cavity Junction Box (tuner drives, linear pots, limit switches, IR sensors) |
| WD-340-330-04-R0 | Cavity Vacuum I&C (gauge controllers, pump power supplies to AB) |
| WD-340-330-05-R0 | Waveguide Air Interlock System (PEP-II config — differs from SPEAR3) |
| WD-340-330-06-R0 | Waveguide Air Interlock System (alternate PEP-II config) |
| WD-340-330-07 thru 20 | AB TC Modules 1–14 (thermocouple wiring: klystron, cavities A–D) |
| WD-340-330-21-R0 | AB Analog Input 1 (Cav A/B tuner, vacuum, filament/focus/bucking V/I) |
| WD-340-330-22-R0 | AB Analog Input 2 (Cav C/D tuner, vacuum, Kly Fwd Pwr, HVPS V/I) |
| WD-340-330-23-R0 | AB Digital Input 1 (klystron flow/HCW, vacuum, waveguide air, circulator) |
| WD-340-330-24-R0 | AB Digital Input 2 (Cav A/B flow, vacuum, pump current — ⚠ no C/D) |
| WD-340-330-25-R0 | AB Digital Output 1 (summary interlocks to Local Panel) |
| WD-340-330-26-R0 | AB Digital Output 2 (blank outputs) |
| WD-340-330-27-R0 | Cavity Tuner Motor Control (AB to motor driver to tuner) |
| WD-340-330-28-R0 | Klystron Filament Control (AB to Filament Control Chassis 340-311) |
| WD-340-330-29-R0 | Control Fiber Optic Cables (Local Panel connections) |
| WD-340-330-30-R0 | Arc Detector Fiber Optic Cables (klystron, circulator, Cav A/B/C/D) |
| WD-340-330-31-R0 | Water Flow Interlocks (to AB digital inputs) |
| WD-340-330-32-R0 | Klystron Focus Power Supplies |
| WD-340-330-33-R0 | Klystron Window Air (blower control, flow monitor) |
| WD-340-330-34-R0 | RF Circulator Controller |

**LLRF Schematics**:

| Document | Description |
|----------|-------------|
| SD-340-308-01-R1 | Fast Interlock Chassis Transmitter Board (18× HFBR-1414) |
| SD-340-308-02-R1 | Fast Interlock Chassis Receiver Board (DB25/DB37, RF detector, fiber RX) |
| SD-340-309-01-C2 | Fast Interlock Module VXI Mother Board (VXI interface, J3 connector) |
| SD-340-311-01-00 | Local Panel Schematic (scanned hardcopy) |
| SD-340-311-00 | Klystron Filament Schematic |
| SD-340-330-01-R0 | Coax Cable Plant |

**HVPS Documents**:

| Document | Description |
|----------|-------------|
| PS-341-360-01-R2 | Klystron Power Supply Technical Specification |
| SLAC-PUB-7591 | "A Unique Power Supply for the PEP II Klystron at SLAC" (design + waveforms) |
| EI-730-790-00-C0 | HVPS Electrical Connections (NWL schematic 39308) |
| SD-730-790-01-C1 | HVPS High Power Schematic |
| SD-730-790-05-C1 | HVPS Grounding Tank Schematic |
| GP-439-704-02-C1 | Switchgear Vacuum Contactor Controller |
| SD-237-230-14-C1 | Voltage Regulator Board |
| SD-730-793-03-C4 | HVPS 12kV SCR Driver Board |
| SD-730-793-04-C2 | HVPS SCR Crowbar Trigger Board |
| SD-730-793-07-C2 | HVPS SCR Right Side Trigger Interconnect (includes F.O. SCR Enable) |
| SD-730-793-08-C2 | HVPS SCR Left Side Trigger Interconnect (includes F.O. Crowbar + Status) |
| SD-730-793-12-C3 | HVPS Monitor Board (buffered V/I to LLRF) |
| SD-730-793-13-C1 | HVPS Optical SCR Trigger Board |
| WD-730-790-01-C3 | HVPS Interconnection Wiring |
| WD-730-790-02-C6 | HVPS Controller Interconnection Wiring |
| WD-730-794-02-C0 | Contactor Interconnection Wiring |
| WD-730-794-03-C0 | Phase Tank Interconnection Wiring |
| WD-730-794-04-C0 | Crowbar Tank Interconnection Wiring |
| WD-730-794-05-C3 | Monitor Interconnection Wiring |
| WD-730-794-06-C0 | Grounding Tank Interconnection Wiring |

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
| "A Unique Power Supply for the PEP II Klystron at SLAC" | R. Cassel, M. Nguyen | 1997 | SLAC-PUB-7591, PAC 1997 poster 5P014 |
| "Klystron Equalization for RF Feedback" | P. Corredoura | 1993 | SLAC-PJB-6049 |
| "Klystron Power Supply Technical Specification (PEP-II)" | SLAC/NWL | — | PS-341-360-01-R2 |
| "SPEAR3 Design Report" | R. Hettel et al. | 2002 | DOI: 10.2172/808721 |
| "PEP-II RF and Feedback R\&D" | N. Eisen, H.D. Schwarz, R. Rimmer et al. | 1992 | OSTI: 10122076 |

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
| Dimtel LLRF9 Product Page | https://www.dimtel.com/products/llrf9 |
| Dimtel LLRF9/500 Specifications | https://www.dimtel.com/products/specs/llrf9_500 |
| Legacy SPEAR3 RF EPICS Code (GitHub) | https://github.com/slac-epics/rf-spear |
| SLAC-PUB-7591 (HVPS Design) | https://www.osti.gov/biblio/461159 |
| PEP-II LLRF at High Currents (arXiv) | https://arxiv.org/abs/physics/0007029 |

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
| **NIRP** | Non-Ionizing Radiation Protection (waveguide air pressure system) |
| **SCR** | Silicon Controlled Rectifier (thyristor) |
| **LLRF9** | Dimtel LLRF9/476 — digital LLRF controller replacing legacy VXI system |
| **Interface Chassis** | New central interlock coordination hub (upgrade) |
| **Waveform Buffer** | New 8 RF + 4 HVPS channel monitoring system with circular buffers |
| **PDR** | Physical Design Report (Designs/0_PHYSICAL_DESIGN_REPORT.md) |
| **CompactLogix** | Allen-Bradley CompactLogix PLC — HVPS controller upgrade |
| **ControlLogix** | Allen-Bradley ControlLogix 1756 PLC — RF MPS upgrade |
| **Galil DMC-4143** | 4-axis motion controller for tuner stepper motors (upgrade) |
| **Microstep-MIS** | Commercial optical arc detection sensors (upgrade) |
| **Enerpro** | SCR gate driver board manufacturer (FCOG6100 legacy, FCOG1200 upgrade) |

---

*End of Technical Notes*

*This document was generated by extracting and synthesizing information from the original PEP-II engineering documents stored in `llrf/documentation/legacyArchitecture/`, combined with publicly available SLAC technical reports and journal publications. For complete technical detail, refer to the original PDF documents listed in Section 17. The original documents contain engineering drawings and block diagrams that provide visual detail beyond what is captured in text form here.*
