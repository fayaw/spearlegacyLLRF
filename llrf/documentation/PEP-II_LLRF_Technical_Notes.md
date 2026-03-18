# PEP-II Low-Level RF (LLRF) System — Comprehensive Technical Notes

## For the SPEAR3 (SSRL) LLRF Upgrade Project

**Purpose:** This document is a comprehensive engineering reference compiled from the original PEP-II LLRF design documents. It is intended to enable AI-assisted design replication of the PEP-II LLRF architecture for the SPEAR3 LLRF upgrade at the Stanford Synchrotron Radiation Lightsource (SSRL).

**Compiled from:** 15 original PEP-II engineering PDF documents (scanned image format)  
**Location:** `llrf/documentation/legacyArchitecture/`  
**Original Authors:** Paul Corredoura, Heinz Schwarz, J. Judkins, M. Allen (SLAC)  
**Date Range of Source Documents:** 1997–2005

---

## Table of Contents

1. [Source Document Registry](#1-source-document-registry)
2. [System Overview & Context](#2-system-overview--context)
3. [System Architecture](#3-system-architecture)
4. [Feedback Loop Architecture](#4-feedback-loop-architecture)
5. [Operating Parameters](#5-operating-parameters)
6. [Calibration Procedures](#6-calibration-procedures)
7. [Station Operating Procedures](#7-station-operating-procedures)
8. [Safety Systems & Radiation Protection](#8-safety-systems--radiation-protection)
9. [SPEAR3 Adaptation Context](#9-spear3-adaptation-context)
10. [External References & Published Papers](#10-external-references--published-papers)
11. [Glossary](#11-glossary)

---

## 1. Source Document Registry

All source documents are scanned image PDFs (no extractable text layer) located in `llrf/documentation/legacyArchitecture/`. Content was extracted via OCR (Tesseract 5.3.0).

| # | Filename | Drawing Number | Title | Pages | Author/Date |
|---|----------|---------------|-------|-------|-------------|
| 1 | `bd3403300000.pdf` | BD-340-330-00-R0 | PEP-II LER RF Station — Block Diagram | 1 | P. Corredoura, 1/28/99 |
| 2 | `bd3403300100.pdf` | BD-340-330-01-R0 | PEP-II LER LLRF Configuration — Block Diagram | 1 | P. Corredoura, 1/28/98 |
| 3 | `blockDiagrambd3403290100-1.pdf` | BD-340-329-01-R0 | PEP-II HER LLRF Configuration — Block Diagram | 1 | P. Corredoura, 1/26/98 |
| 4 | `ps3403305100.pdf` | PS-340-330-51-R0 | RF System Description | 11 | H. Schwarz, 7/21/99 |
| 5 | `ps3403305200.pdf` | PS-340-330-52-R0 | LLRF Feedback Loop Description | 8 | H. Schwarz, 7/21/99 |
| 6 | `feedbackLoopDescriptionps3403305200.pdf` | PS-340-330-52-R0 | LLRF Feedback Loop Description (duplicate) | 8 | H. Schwarz, 7/21/99 |
| 7 | `ps3403305300.pdf` | PS-340-330-53-R0 | RF Cavity Low Power Calibration Procedure | 4 | H. Schwarz, 7/2/97 |
| 8 | `ps3403305400.pdf` | PS-340-330-54-R0 | RF Station Safety Certification Check-Off List | 2 | H. Schwarz, 4/19/99 |
| 9 | `ps3403305503.pdf` | PS-340-330-55-R3 | RF Station Safety Survey | 4 | A. Hill/H. Schwarz, 12/2/05 |
| 10 | `ps3403305600.pdf` | PS-340-330-56-R0 | RF Station Coupling & Cable Loss Calibration | 4 | H. Schwarz & P. Corredoura, 7/2/97 |
| 11 | `ps3403305700.pdf` | PS-340-330-57-R0 | RF Station Full Power Test & Survey | 2 | H. Schwarz, 6/8/99 |
| 12 | `ps3403305800.pdf` | PS-340-330-58-R0 | RF Station Cavity Phasing Procedure | 4 | H. Schwarz, 3/24/97 |
| 13 | `ps3403305900.pdf` | PS-340-330-59-R0 | RF Station Turn-On Procedure | 7 | H. Schwarz, 9/14/98 |
| 14 | `ps3403306001.pdf` | PS-340-330-60-R1 | Bellow Cavity Phasing Procedure | 5 | H. Schwarz, 1/5/99 |
| 15 | `ps3403306102.pdf` | PS-340-330-61-R2 | RF Non-Ionizing Radiation Safety Procedure | 13 | H. Schwarz/J. Judkins, 4/19/99 |

**Total: 74 pages across 15 documents (14 unique — documents #5 and #6 are duplicates with different modification dates)**


---

## 2. System Overview & Context

### 2.1 PEP-II B-Factory RF System

The PEP-II B-Factory at SLAC consisted of two storage rings colliding beams at the BaBar detector:

- **High Energy Ring (HER):** 9 GeV electrons, 1.03 A design current
- **Low Energy Ring (LER):** 3.1 GeV positrons, 2.00 A design current

Both rings operated at an RF frequency of **476.000 MHz** with a harmonic number of 3492. The rings could accommodate up to 1746 bunches (every other bucket filled) with an ion-clearing gap.

> **Source:** `ps3403305100.pdf` (PS-340-330-51-R0, RF System Description)

### 2.2 RF Station Configuration

**HER (5 stations):**
- 3 stations in Region 8, support building B685 (stations 8HR1, 8HR3, 8HR5)
- 2 stations in Region 12, support building B725 (stations 12HR1, 12HR3)
- Each station drives **4 single-cell cavities** (20 cavities total)
- Station numbering: lowest number is first in line of beam

**LER (2–3 stations):**
- Located in Region 4, support building B645 (stations 4LR3, 4LR4, 4LR5)
- Station 4LR3 was partially installed; 4LR4 and 4LR5 were operational
- Each station drives **2 single-cell cavities** (4–6 cavities total)

**Master Oscillator:** Located in the old PEP control room, Region 8; connected to the LINAC Main Drive Line in sector 30 via phase-stabilized RF distribution.

> **Source:** `ps3403305100.pdf`, pages 2–3

### 2.3 Physical Station Layout

Each RF station consists of:

1. **Support Building (surface):**
   - 1.2 MW CW klystron
   - 6 electronic racks: station breakers, emergency-off, local control/monitor panels, PLC (Allen-Bradley), klystron filament/focus supplies, ion gauge readouts, ion pump supplies
   - Air-conditioned "blue rack" containing LLRF VXI modules
   - Circulator with 1.2 MW load (klystron protection)
   - Waveguide power-splitting network: Magic-tee(s) followed by waveguides into tunnel

2. **High-Voltage Power Supply (outside building):**
   - 2 MW (90 kV, 23 A) HVPS
   - Aluminum tank with grounding switch and lock-out provisions

3. **Tunnel:**
   - Single-cell RF cavities with HOM loads (3 per cavity), movable tuner, input ceramic window, 400 l/sec VACION vacuum pump per cavity
   - Waveguide penetrations from surface building

4. **Cooling Systems (per region):**
   - LCW circuit #1: Klystron cooling at regulated 35°C supply
   - LCW circuit #2: Cavity cooling at regulated 35°C supply
   - HCW circuit: High-power waveguide loads (unregulated temperature)
   - Pumps and controllers on platforms outside support buildings

> **Source:** `ps3403305100.pdf`, pages 2–3, 7; `bd3403300000.pdf`

### 2.4 LLRF System Design Philosophy

The PEP-II LLRF system was designed by Paul Corredoura at SLAC with these key design principles:

- **Baseband In-phase/Quadrature (IQ) Signal Processing:** All RF signals are downconverted to baseband I and Q components for processing, then upconverted back to 476 MHz. This enables both analog and digital signal processing techniques.
- **VXI-based modular hardware:** Custom VXI modules in a single crate per station, enabling compact and highly integrated design.
- **EPICS control environment:** Full programmability through EPICS IOCs with MATLAB-based calibration routines.
- **Built-in network analyzer:** Each station has integrated signal generation and measurement capability for closed-loop testing without beam loss.
- **Transient signal recorders:** Circular buffers that freeze on fault for post-mortem analysis.
- **Multiple nested feedback loops:** Direct Loop, Comb Loop, Tuner Loop, HVPS Loop, DAC Loop, Ripple Loop, Gap FF Loop, and Woofer Loop working in concert.

> **Source:** `bd3403300100.pdf`; Corredoura, P., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8024 (1999); Corredoura et al., SLAC-PUB-8498 (2000)


---

## 3. System Architecture

### 3.1 VXI Crate Module Inventory

Each RF station has a single VXI crate containing the following custom modules (per Corredoura's published VXI topology):

| Slot | Module | Function |
|------|--------|----------|
| 0 | Slot 0 µProcessor | EPICS IOC, system control |
| 1 | Allen-Bradley Scanner | Interface to PLC interlock system |
| 2 | Spare | |
| 3 | Spare | |
| 4 | Arc/Interlock Detector | 8-channel arc detection, interlock monitoring |
| 5 | Clock & RF Distribution | 476 MHz reference distribution, 471.1 MHz L.O. generation |
| 6 | RFP Module (RF Processing) | RF modulation, drive amplifier interface, baseband processing |
| 7 | IQ/AMP Detector 1 | Cavity probe signal downconversion (cavities A, B) |
| 8 | IQ/AMP Detector 2 | Cavity probe signal downconversion (cavities C, D) |
| 9 | IQ/AMP Detector 3 | Klystron/load forward & reflected power monitoring |
| 10 | Comb Filter (I) | **[PEP-II SPECIFIC]** In-phase comb filtering with 1-turn delay |
| 11 | Comb Filter (Q) | **[PEP-II SPECIFIC]** Quadrature comb filtering with 1-turn delay |
| 12 | Gap Voltage Feed-Forward | **[PEP-II SPECIFIC]** Ion-clearing gap compensation |
| — | VME Scanner | Heartbeat monitoring, Allen-Bradley DH-465 communication |

> **Source:** `bd3403300000.pdf`; `bd3403300100.pdf`; Corredoura et al., SLAC-PUB-8498 Fig. 1

### 3.2 RF Signal Chain — Drive Path

The complete RF signal chain from reference to cavity:

```
476 MHz Reference
    │
    ▼
RF Modulator ─── I/Q baseband signals control amplitude & phase
    │
    ▼
Amplifier (+16 dBm bare)
    │
    ▼
RF Switch (on/off control)
    │
    ▼
Amplifier (+34 dBm → +38 dBm)
    │
    ▼
120 W Drive Amplifier (50 dB gain)
    │
    ▼
1.2 MW Klystron (476 MHz CW)
    │
    ▼
Circulator (klystron protection from reflected power)
    │    └── 1.2 MW Load
    ▼
Magic-Tee Power Splitter Network
    │    └── 1.2 MW Load at each 4th port
    ▼
Waveguide Penetration → Tunnel
    │
    ▼
RF Cavities (2 or 4 per station)
```

> **Source:** `bd3403300100.pdf`; `bd3403300000.pdf`

### 3.3 RF Signal Chain — Monitoring Path

Each cavity provides multiple monitoring signals back to the LLRF system:

| Signal | Coupling | Nominal dB | J-Number (HER) |
|--------|----------|-----------|-----------------|
| Cavity A probe | Sampling loop | 99.6 dB | J1 |
| Cavity A forward | Directional coupler | 60.0 dB | J2 |
| Cavity A reflected | Directional coupler | 60.0 dB | J3 |
| Cavity B probe | Sampling loop | 99.6 dB | J4 |
| Cavity B forward | Directional coupler | 60.0 dB | J5 |
| Cavity B reflected | Directional coupler | 60.0 dB | J6 |
| Cavity C probe | Sampling loop | 99.6 dB | J7 |
| Cavity C forward | Directional coupler | 60.0 dB | J8 |
| Cavity C reflected | Directional coupler | 60.0 dB | J9 |
| Cavity D probe | Sampling loop | 99.6 dB | J10 |
| Cavity D forward | Directional coupler | 60.0 dB | J11 |
| Cavity D reflected | Directional coupler | 60.0 dB | J12 |
| Klystron forward | Directional coupler | 60.0 dB | J15 |
| Klystron reflected | Directional coupler | 60.0 dB | J16 |
| Circulator load fwd | Directional coupler | 60.0 dB | J19 |
| Circulator load refl | Directional coupler | 60.0 dB | J20 |
| Magic-tee #1 load fwd | Directional coupler | 60.0 dB | J21 |
| Magic-tee #1 load refl | Directional coupler | 60.0 dB | J22 |
| Magic-tee #2 load fwd | Directional coupler | 60.0 dB | J23 |
| Magic-tee #2 load refl | Directional coupler | 60.0 dB | J24 |
| Magic-tee #3 load fwd | Directional coupler | 60.0 dB | J25 |
| Magic-tee #3 load refl | Directional coupler | 60.0 dB | J26 |
| Drive forward | Amplifier coupling | 30.0 dB | J36 |
| Drive to klystron | Cable | — | J14 |

All signals pass through 1/4-inch Heliax pigtails and are downconverted through IQ module channels with **13.15 dB** conversion loss per channel.

> **Source:** `ps3403305600.pdf` (PS-340-330-56-R0), pages 3–4

### 3.4 Baseband IQ Processing Architecture

The core signal processing operates at baseband using I (in-phase) and Q (quadrature) components:

1. **Downconversion:** 476 MHz cavity probe signals are mixed with a 471.1 MHz local oscillator to produce ~4.9 MHz IF signals, which are further mixed to baseband I and Q.
2. **ADC Sampling:** Fsample = 10 MHz; each channel has 512K RAM for waveform capture.
3. **Vector Sum:** Multiple cavity I/Q signals are combined at baseband to form the station sum signal.
4. **Error Generation:** Station sum compared against DAC-generated I_REF and Q_REF to produce error signals.
5. **PID Controller:** Error signals processed through PID with integral and lead compensation.
6. **Upconversion:** Corrected baseband I/Q signals are upconverted back to 476 MHz via an RF modulator.
7. **Baseband Modulator:** 4-multiplier matrix compensates for klystron gain/phase variations. Uses Gilbert-cell multipliers rated at 1 V maximum input. Schottky diode soft limiters prevent overdrive.

Output signal levels:
- RF output to klystron drive: -10 dBm to -6 dBm nominal
- Klystron drive output: +9 dBm typical
- Baseband signal range: ±2 V maximum

> **Source:** `bd3403300100.pdf`; `blockDiagrambd3403290100-1.pdf`; Corredoura et al., SLAC-PUB-8498

### 3.5 Control System Architecture

**PLC System (Allen-Bradley):**
- Processor: PLC-5S
- Communication: SLC-5000/3 with DH-465 network
- Digital outputs: 64 channels
- Digital inputs: 64 channels  
- Thermocouple inputs: 112 channels (separate crate)
- Analog inputs: 32 channels
- Remote I/O link to tunnel equipment

**EPICS Integration:**
- VXI Slot 0 µProcessor runs EPICS IOC
- Ethernet connection to workstation
- MATLAB calibration routines accessible through EPICS panels
- Allen-Bradley scanner provides interlock summary and heartbeat

**Fiber Optic Links:**
- HVPS control: SCR Enable and Crowbar trigger via fiber
- Allen-Bradley Remote I/O: fiber optic to tunnel PLC nodes
- Longitudinal Feedback: wideband fiber optic link for "woofer" kick signal
- Arc detector interlocks: fiber optic from tunnel

**Operator Interfaces (EPICS Panels):**
- KLYSTRON panel: Filament ON/OFF, Solenoid ON/OFF
- RF STATION panel: Mode buttons (ON_CW, TUNE, ON_FM, PARK, OFF-LINE, OFF), loop controls
- KLYSTRON HVPS panel: Voltage control, contactor open/close
- FEEDBACK panel: Loop status indicators for all feedback loops
- CAVITY TUNERS panel: Tuner position, cavity strength, load angle offset

> **Source:** `bd3403300000.pdf`; `ps3403305900.pdf`, pages 3–6

### 3.6 Tuner Control System

Each cavity has a movable tuner controlled by a stepping motor:

- **Stepping motor controllers:** One per cavity, in the VXI crate
- **Motor driver/translator:** In support building, connected via cable to tunnel
- **Tuner position sensors:** Stepper motor position tracking
- **Control cable:** From VXI crate to motor controller to driver/translator to tunnel stepping motors and limit switches (2 per tuner)
- **Tuner resolution:** Fixed tuner adjustment range ±2 to -3 mm; 30 kHz/mm sensitivity
- **Movable tuner nominal position:** 8 mm insertion (nominal operating position)

> **Source:** `bd3403300000.pdf`; `ps3403305300.pdf`


---

## 4. Feedback Loop Architecture

The PEP-II LLRF system employs **10 distinct feedback/feedforward loops** that work together to maintain stable beam operation. All loops are described in the order their buttons appear on the EPICS Feedback panel.

> **Primary Source:** `ps3403305200.pdf` (PS-340-330-52-R0, LLRF Feedback Loop Description)

### 4.1 Direct Loop (Primary Fast Feedback)

**Purpose:** Keeps the cavity gap voltage constant as set by a DAC reference over an **800 kHz bandwidth**. This is the primary loop for lowering the cavity impedance to reduce multibunch oscillations of the beam.

**Signal Path:**
1. Combined baseband field signals (I_sum, Q_sum) from all cavities of a station
2. Compared against Gap module reference (I_REF, Q_REF) generated by DAC
3. Error signal processed through PID controller
4. PID output upconverted to RF and drives the klystron

**PID Controller Options:**
- **Integral Compensation:** Smooths ripple from klystron HVPS
- **Lead Compensation:** Increases bandwidth and gain of the loop
- **Frequency Offset Tracking:** Takes out phase shift from cavity detuning during heavy beam loading (diagnostic use; should NOT normally be activated)

**Calibration:**
- MATLAB routine: `ConfDirect` — sets loop phase, loop gain, and gain tracking
- Network analyzer test: `MeasDirCls` — measures closed-loop response without beam loss

> **Source:** `ps3403305200.pdf`, page 4

### 4.2 Comb Loop [PEP-II SPECIFIC]

**Purpose:** Provides additional impedance reduction at specific synchrotron frequency sidebands around the revolution harmonics. Operates over a **2 MHz bandwidth** with a **1-turn delay**.

**Key Feature:** The comb filter provides narrowband gain at revolution harmonics where coupled-bunch modes are driven. This is complementary to the wideband Direct Loop.

**Calibration:**
- MATLAB routine: `Config Comb` — sets loop phase, gain, and delay; requires Direct Loop ON and ON_CW mode
- Equalizer routine: `Make Equal` — compensates for group delay effects in both Comb Loop and Woofer link. User should never have to create new equalizer files.
- Test: Uses same `MeasDirCls` network analyzer routine as Direct Loop

**Hardware:** Implemented in dedicated VXI Comb Filter modules (I and Q) with 1-turn delay lines and delay equalizers.

> **Source:** `ps3403305200.pdf`, page 5; `bd3403300100.pdf`

### 4.3 Tuner Loop (Cavity Resonance Tracking)

**Purpose:** Tunes and maintains each cavity at resonance by correcting thermal frequency variations and compensating cavity beam loading.

**Detection Method:** Phase relationship between forward power and cavity field (as seen by cavity probe) measured by digital IQ detectors.

**Control:** Software-controlled stepping motor adjusting tuner position.

**Calibration Routine: `Tune Cavs`**
1. Injects noise onto CW REF signal
2. Measures resonance curves of all cavities in several iterations
3. Fits standard resonance curves to measured response
4. Establishes resonance condition for each cavity
5. Establishes correct vector summation of multiple cavity signals at baseband (for Direct and Comb Loops)

**Polynomial Routine: `Make Poly`**
- Creates polynomial of resonance frequency vs. tuner position
- Required for parking cavities at desired frequency
- Required to allow Direct Loop to adjust phase as cavities detune

> **Source:** `ps3403305200.pdf`, page 5

### 4.4 HVPS Loop (Klystron Power Supply Regulation)

Operates in two distinct modes:

**Mode 1 — Direct Loop ON (beam operation):**
- **Function:** Keeps klystron operating at ~10% below saturated output power
- **Input:** Drive power measured at klystron input
- **Setpoint:** ON_CW Drive Power reference value
- **Action:** Error positive → increase HVPS voltage; error negative → decrease voltage
- **Bandwidth:** ~1 Hz (slow loop)

**Mode 2 — Direct Loop OFF (no beam, tuning):**
- **Function:** Keeps measured gap voltage equal to requested "Station Gap Voltage"
- **Action:** Adjusts HVPS voltage directly (affecting klystron output power)

> **Source:** `ps3403305200.pdf`, pages 6–7

### 4.5 DAC Loop (Gap Voltage Fine Correction)

**Purpose:** Keeps the measured gap voltage of the station equal to its requested "Station Gap Voltage" by adjusting the DAC in the Gap Voltage Feed-Forward module.

**Bandwidth:** 0.1 Hz (very slow)

**Mode 1 — Direct Loop ON:** Adjusts DAC in Gap Voltage FF module
**Mode 2 — Direct Loop OFF:** Keeps drive power at requested level by adjusting DAC

> **Source:** `ps3403305200.pdf`, pages 6–7

### 4.6 Direct Feedback Loop Options

Controls optional functions of the Direct Loop:
1. **Frequency Offset Tracking** — diagnostic for cavity detuning phase shift
2. **Integral Compensation** — ripple smoothing from HVPS
3. **Lead Compensation** — bandwidth and gain enhancement

> **Source:** `ps3403305200.pdf`, page 6

### 4.7 Ripple Loop

**Purpose:** Removes amplitude and phase ripple in klystron output power. In practice, it maintains low-bandwidth phase across the klystron and drive amplifier constant as klystron voltage varies.

**Status:** "Should be ON for all normal operation."

> **Source:** `ps3403305200.pdf`, page 6

### 4.8 Gap Feed-Forward Loop [PEP-II SPECIFIC]

**Purpose:** Tells the Direct Loop to ignore the effects of the ion-clearing gap in the beam bunch train.

**Operation:** Learns the variation in klystron drive caused by the beam gap, then adds an equal variation to the reference signal so that the error signal driving the klystron stays unchanged.

**Adaptation Time:** ~1000 beam revolutions to full adaptation.

> **Source:** `ps3403305200.pdf`, page 6

### 4.9 Longitudinal Feedback Woofer

**Purpose:** Third cavity impedance reduction loop (after Direct and Comb). Uses information from the lowest beam oscillation modes detected by the Longitudinal Multibunch Feedback system.

**Application:** One RF station in each ring acts as a powerful longitudinal kicker via a wideband fiber optic link.

**Calibration:** `ConfWoofer` MATLAB routine; requires ON_CW with Direct, Comb, and Gap FF Loops operating. Sets loop phase, loop gain, and one-turn delay.

> **Source:** `ps3403305200.pdf`, page 7

### 4.10 Optimized Station Phasing Routine

**Purpose:** Sets correct phase for each station for maximum voltage gain.

**Trigger:** `Phase Stns` MATLAB button; requires beam current > 100 mA.

**Operation:** Equalizes power contribution of each operational station in a ring by adjusting station phase in **0.5° maximum steps for 10 iterations**. Can be repeated if optimum not achieved in one try.

**Reference Stations (phase fixed):**
- HER: Station 8-3 (primary), Station 12-3 (alternate if 8-3 off)
- LER: Station 4-4

> **Source:** `ps3403305200.pdf`, page 7

### 4.11 Loop Hierarchy and Interaction

The loops operate in a nested hierarchy with different bandwidths:

| Loop | Bandwidth | Type | Required Mode |
|------|-----------|------|---------------|
| Direct Loop | 800 kHz | Fast analog feedback | ON_CW |
| Comb Loop [PEP-II] | 2 MHz (narrowband) | Analog with 1-turn delay | ON_CW + Direct ON |
| Woofer | ~10 kHz | Fiber-linked digital feedback | ON_CW + Direct + Comb + Gap FF |
| Ripple Loop | ~1 kHz | Phase correction | All normal operation |
| HVPS Loop | ~1 Hz | Slow software loop | ON_CW |
| DAC Loop | ~0.1 Hz | Very slow software loop | All modes |
| Tuner Loop | < 0.1 Hz | Stepping motor software | All modes |
| Gap FF [PEP-II] | ~1000 revolutions | Adaptive feedforward | ON_CW + Direct ON |


---

## 5. Operating Parameters

### 5.1 RF Station & Cavity Nominal Parameter Table (1998)

This is the definitive parameter table from the original PEP-II design, authored by Heinz Schwarz on 5/20/98.

| Parameter | Symbol | Unit | HER | LER |
|-----------|--------|------|-----|-----|
| Frequency | f₀ | MHz | 476 | 476 |
| RF Voltage / Ring | V | MV | 14.00 | 3.40 |
| Energy Loss / Turn / Ring | V₁ | MV | 3.58 | 0.77 |
| Number of Cavities | n | — | 20 | 4 |
| Number of Cavities / Klystron | m | — | 4 | 2 |
| Number of Idling Stations | x | — | 0 | 0 |
| Beam Current | I₀ | A | 1.03 | 2.00 |
| Shunt Impedance / Cavity | Z₀ | MΩ | 3.73 | 3.73 |
| Shunt Impedance (Accel.) / Cavity | Ra | MΩ | 7.5 | 7.5 |
| Gap Voltage / Cavity | Vc | kV | 700.0 | 850.0 |
| Cavity Wall Power | Pc | kW | 65.7 | 96.8 |
| Synchrotron Radiation Power / Cavity | Ps | kW | 184.4 | 385.0 |
| HOM Power / Cavity | Ph | kW | 1.9 | 23.3 |
| Beam Power / Cavity | Pb | kW | 186.3 | 408.3 |
| Total Power / Cavity | Ptotc | kW | 252.0 | 505.2 |
| Forward Power / Cavity | Pfwd | kW | 252.0 | 519.7 |
| Equivalent Window Power (E-field) | Pw | kW | 244.3 | 360.3 |
| Equivalent Window Power (B-field) | Pw | kW | 259.8 | 708.3 |
| Energy Loss / Turn / Cavity | Va | kV | 180.8 | 204.2 |
| Optimum Coupling Factor | β_opt | — | 3.84 | 5.22 |
| Actual Coupling Factor | β | — | 3.72 | 3.72 |
| Synchronous Phase Angle | Φ | degrees | 75.0 | 76.10 |
| Detuning Angle | ψ | degrees | -66.0 | -74.52 |
| Change in Resonant Frequency | Δf | kHz | -78.9 | -126.7 |
| Unloaded Q | Q₀ | — | 32,000 | 32,000 |
| Loaded Q | QL | — | 6,780 | 6,780 |
| Generator Power / Cavity | Pg | kW | 252.0 | 519.7 |
| Generator Induced Voltage at Resonance / Cav | Vgr | kV | 1,121 | 1,609 |
| Generator Induced Voltage / Cavity | Vg | kV | 456 | 430 |
| Beam Induced Voltage at Resonance / Cavity | Vbr | kV | 1,628 | 3,161 |
| Beam Induced Voltage / Cavity | Vb | kV | 662 | 844 |
| Beam Induced Power at Resonance (Cavity) | Pe' | kW | 355 | 1,339 |
| Beam Induced Power at Resonance (Emitted) | Pe | kW | 1,322 | 4,983 |
| Total Beam Induced Power at Resonance / Cav | P | kW | 1,677 | 6,322 |
| Generator Current / Cavity | Ig | A | 1.42 | 2.04 |
| Beam Current at f₀ | Ib | A | 2.06 | 4.00 |
| Beta with Beam | β_beam | — | 1.0 | 0.7 |
| Reflected Power / Cavity | Pr | kW | 0.1 | 14.6 |
| Reflected Power / Klystron | Pr_tot | kW | 0.2 | 29.1 |
| Power Loss in Waveguide | Pwg | kW | 10.3 | 21.3 |
| Generator Power / Klystron | Pg_tot | kW | 262 | 541 |
| Klystron Power | Pkly | kW | 1,049 | 1,082 |
| Synchrotron Frequency | fs | kHz | 6.10 | 3.67 |
| Bunch Length | σ | cm | 1.15 | 1.24 |

> **Source:** `ps3403305100.pdf`, page 4 (PS-340-330-51-R0)

### 5.2 Cavity Processing Limit Parameters

| Parameter | HER FM | HER CW | LER FM | LER CW |
|-----------|--------|--------|--------|--------|
| Max Cavity Vacuum | 1E-8 Torr | 1E-8 Torr | 1E-8 Torr | 1E-8 Torr |
| Max Cavity Gap Voltage | 800 kV | 750 kV | 900 kV | 850 kV |
| Max Klystron Forward Power | 540 kW | 450 kW | 330 kW | 290 kW |

> **Source:** `ps3403305900.pdf`, page 7 (PS-340-330-59-R0)

### 5.3 Cavity Phase Relationships (HER 4-Cavity Station)

| Cavity | Distance (wavelengths) | Nominal RF Phase |
|--------|------------------------|------------------|
| A (Reference) | 0 | 0° |
| B | 3.25 | -90° |
| C | 8.75 | -270° (+90°) |
| D | 12.0 | 0° |

Phase correction sensitivity: **0.085 inch per degree** of bellow adjustment.

**Note:** Bellow #1 adjustment for cavity C also shifts cavity D; compensation required on bellow #3.

> **Source:** `ps3403305800.pdf` (PS-340-330-58-R0), pages 2–3

### 5.4 Cavity Low-Power Calibration Constants

| Parameter | Value |
|-----------|-------|
| R/Q | 116.67 |
| Reference Shunt Impedance (R) | 3.5 MΩ |
| Reference Unloaded Q (Q₀) | 30,000 |
| Reference Gap Voltage | 1,025 kV |
| Reference Cable Output Power | 1 W |
| Minimum Cable Loss | 0.6 dB |
| Reference Cavity Wall Power | 150 kW |
| Baseline Ps/Pinc | -51.8 dB |
| Temperature Correction | -7.95 kHz/°C (referenced to 35°C) |
| Vacuum Correction | +124 kHz |
| Target Frequency | 476,000 ± 100 kHz (at 35°C and vacuum) |
| Fixed Tuner Sensitivity | 30 kHz/mm |
| Fixed Tuner Range | +2 to -3 mm |
| Teststand Calibration | -51.2 dB (gives 1.14 W at probe for 150 kW) |

**Sampling Loop Coupling Formula:**

```
Ps/Pinc = -51.8 dB + 10·log(Q₀/30,000) + 10·log[48/(1+β)²] + 0.6 dB
```

Example: Q₀ = 34,000, β = 4.0 → Ps/Pinc = -51.8 + 0.54 - 1.94 + 0.6 = **-52.6 dB**

Add -0.5 dB before tightening sampling probe; acceptable variation after tightening: ±0.3 dB.

> **Source:** `ps3403305300.pdf` (PS-340-330-53-R0), pages 2–4


---

## 6. Calibration Procedures

### 6.1 Cavity Low-Power Calibration (PS-340-330-53-R0)

**Performed on:** Each cavity raft assembly before installation.

**Prerequisites:**
- Cavity assembled with all accessories: HOM loads, input coupling network with window, fixed tuner, movable tuner (8 mm insertion fixture), sampling loop
- Cavity in ante-room of clean room with network analyzer
- Cavity purged with N₂ at atmospheric pressure
- Sampling loop installed with new gasket, all bolts hand tight, shorted side pointing horizontally towards HOM loads (rotate downward for correct coupling)

**Equipment Required:**
- Network Analyzer HP 8719
- WR2100/Coax Type N adapter
- Type N calibration kit and cables
- Temperature meter, calculator
- Movable tuner spacer

**Measurement Protocol:**
1. Calibrate network analyzer: ISOLATION FULL 2 PORT CALIBRATION (256 AVG), measure with 64-point averaging, smoothing ON
2. Measure resonance frequency in S11 mode at 8 mm tuner insertion
3. Apply temperature correction: Δf_T = (35°C - T) × (-7.95 kHz/°C)
4. Apply vacuum correction: Δf_V = +124 kHz
5. Target: f₃₅°C&Vac = 476,000 ± 100 kHz
6. Measure tuner range: frequency with tuner all way in and all way out
7. Measure input coupling β from S11
8. Measure loaded Q (Q_L) from S21 through sampling probe
9. Calculate: Q₀ = Q_L × (1 + β); Q_e = Q₀ / β
10. Set sampling loop coupling per formula in Section 5.4

> **Source:** `ps3403305300.pdf` (PS-340-330-53-R0)

### 6.2 Station Coupling & Cable Loss Calibration (PS-340-330-56-R0)

**Purpose:** Calibrate all RF signal paths between cavities/klystron and the LLRF VXI crate.

**Equipment:**
- Signal Generator HP 8648 with 10 dB matching attenuator
- Power Meter HP 435

**Procedure:**
1. Set signal generator to 0 dBm (1 mW) at 476 MHz with 10 dB attenuator
2. Connect to each J-number pigtail in the Blue Rack
3. Measure power at other end of cable (tunnel or upstairs)
4. Cable loss = source power - measured power
5. Re-check source output frequently

**Standard Values:**
- Cavity probe coupling: 99.6 dB (modified by low-power test data)
- Directional coupler coupling: 60.0 dB
- Drive amplifier coupling: 30.0 dB
- IQ module channel conversion loss: 13.15 dB per channel
- Typical Heliax cable losses: 1.0–5.0 dB depending on run length

> **Source:** `ps3403305600.pdf` (PS-340-330-56-R0)

### 6.3 Cavity Phasing Procedure (PS-340-330-58-R0)

**Purpose:** Align RF phase of each cavity with beam arrival.

**Equipment:**
- Network Analyzer HP 8753
- 120 W Drive Amplifier (50 dB gain)
- Coax/waveguide transition at first Magic-Tee

**Setup:**
- Drive amplifier output to waveguide transition
- Network analyzer source via existing monitor cable (~1 mW needed)
- Monitor output (30 dB coupling) with 20 dB attenuator to R-port
- Cavity sampling probe to A-port (max input: 0 dBm)
- Network Analyzer: CENTER 476 MHz, 50 kHz SPAN, 1602 POINTS, DUAL DISPLAY
- Display: S11 (A/R) log amplitude at 0.05 dB/div scale, PHASE
- MARKER #1 at 476 MHz = reference for cavity A

**Procedure:**
1. Unplug tuner motor drive cables (manual adjustment only)
2. Set each cavity to resonance (adjust for max field, move tuner down as last step)
3. Measure phase of cavities B, C, D relative to cavity A
4. Calculate delta phase = measured - nominal
5. If positive (advanced phase): make bellow **longer**
6. If negative (delayed phase): make bellow **shorter**
7. Bellow change: **0.085 inch per degree**
8. Compensate: Bellow #1 (cavity C) also shifts cavity D → adjust bellow #3
9. Repeat measurements after adjustment to verify

> **Source:** `ps3403305800.pdf` (PS-340-330-58-R0)

### 6.4 Bellow Cavity Phasing Under Beam (PS-340-330-60-R1)

**Purpose:** Touch-up phase adjustment when cavity gap voltages are imbalanced at high beam current.

**Procedure using Load Angle Offset Routine:**
1. With zero beam: transfer "Cav Strength (%)" to "Setpoint (%)" box on Cavity Tuners Panel
2. With stored beam > Min Beam Curr (mA): activate "Load Angle Offset Loop"
3. Loop moves tuners to restore Cav Strength (%) to idling value WITH beam
4. Read phase offsets: "Ld Angle Offset (Deg)" on Cavity Tuner Panel
5. Wait several minutes for stabilization (Ld Angle Error box goes yellow during tuner moves)
6. Record stabilized values
7. **CRITICAL:** Turn OFF Load Angle Offset Loop after measurement (interferes with Magic Detuning at high beam current)

**Phase Correction:**
- Delta Phase = PhN (nominal) - PhA (actual)
- If positive: make bellow **shorter**
- If negative: make bellow **longer**
- Sensitivity: 0.085 inch/degree

> **Source:** `ps3403306001.pdf` (PS-340-330-60-R1)


---

## 7. Station Operating Procedures

### 7.1 Station Turn-On Sequence (PS-340-330-59-R0)

**Pre-Conditions:**
- Klystron filament & solenoid "ON" (from EPICS KLYSTRON panel)
- Filament voltage/current reading "GREEN"
- Filament time-left counter = 0 sec "GREEN" (30-minute warm-up timer)
- All boxes on RF STATION panel "GREEN" (except HVPS if contactor OFF)

**Turn-On Steps:**
1. Push **RESET** button (clears faults)
2. **Contactor CLOSE** on RF STATION or HVPS panel
   - If contactor cannot close: check "manual reset" interlocks on HVPS SMART TOUCH panel (Rack 2); press RESET
3. For beam operation:
   - Select **ON_CW** mode
   - Set HVPS Loop to **ON** (OFF → PROC → ON buttons)
   - Station automatically ramps HVPS voltage to set "Stn Gap Volt (kV)"
   - Ripple Loop, Direct Loop, Comb Loop automatically initiate
   - Set "Auto Reset Tries Left" to max 25 for automatic recovery after trips

> **Source:** `ps3403305900.pdf` (PS-340-330-59-R0), pages 2–7

### 7.2 Operating Modes

| Mode | Description |
|------|-------------|
| **ON_CW** | Normal beam operation with all loops active |
| **TUNE** | Low-power tuning/conditioning without full HVPS power |
| **ON_FM** | 1000 Hz FM mode for cavity processing after vents |
| **PARK** | Temporary parking at +340 kHz from resonance; HVPS contactor stays closed; all interlocks must be green |
| **OFF-LINE** | Long-term parking; STATION LOCK-OUT key at Local Display Panel (Rack 3); HVPS and klystron turned off |
| **OFF** | RF off with HVPS contactor closed; fires beam abort; tuners remain at previous position |
| **PROC** | Processing mode — station automatically steps HVPS voltage up until limiting parameter reached, steps down when limit passed |

**Park Mode Details:**
- Beam abort automatically fires if essential interlocks trip: waveguide pressure, cavity vacuum, cavity/load cooling flow
- If station does not stay in PARK mode, one of the essential interlocks is not made up

**Processing Sequence:**
- After intentional or accidental vent: process first in ON_FM (1000 Hz) then ON_CW
- Use HVPS Loop OFF → PROC for automatic voltage stepping
- Limit parameters per Section 5.2

> **Source:** `ps3403305900.pdf` (PS-340-330-59-R0)

### 7.3 Fast Turn-On Procedure (from published literature)

The original slow turn-on procedure required ~3 minutes per station. An improved fast turn-on was developed:

1. Preset tuner positions, loop gains, and baseband IQ references to no-beam, normal gap voltage values
2. Preset baseband modulator gain to minimum (full beam current) setting to prevent overdrive
3. Apply klystron high voltage for no-beam condition
4. All feedback loops settle into regular operation automatically

**Result:** Cycle time reduced from 3 minutes to **< 20 seconds**.

**Critical design detail:** Schottky diode soft limiters (back-to-back 1N4157 diodes across feedback resistor in gain stage preceding baseband modulator) prevent Gilbert-cell multiplier overdrive which would cause polarity inversion and positive feedback.

> **Source:** Corredoura et al., "Experience with the PEP-II RF System at High Beam Currents," SLAC-PUB-8498 (2000)

### 7.4 Full Power Test Procedure (PS-340-330-57-R0)

**Purpose:** Test 1.2 MW klystron without sending power to cavities.

**Setup:** Waveguide SHORT plate installed between circulator and first Magic-Tee. All power reflects back into circulator 1.2 MW load. No ionizing radiation in tunnel.

**Pre-Checks:**
1. Waveguide connections made, pressure interlock activated
2. SHORT installed with yellow flag; torque checked on 6 random bolts > 25 ft-lbs
3. Klystron grounding cable connected
4. Klystron HV cable connected with 4 screws
5. Klystron lead shielding panels in place

**Radiation Surveys:**
- At ~100 kW: RF radiation < 0.1 mW/cm² (all accessible waveguide up to SHORT)
- At full 1.2 MW: RF radiation < 1.5 mW/cm² (operational limit)
- At full 1.2 MW: Ionizing radiation < 5 mR/hr at 30 cm from klystron surface

> **Source:** `ps3403305700.pdf` (PS-340-330-57-R0)


---

## 8. Safety Systems & Radiation Protection

### 8.1 Safety Certification Check-Off (PS-340-330-54-R0)

Required after initial installation and after major work on power components (klystron, waveguide, cavities) or interlock system.

**Check Items:**
1. ☐ Waveguide flange torque test: 6 random bolts > 25 ft-lbs on all accessible flanges (upstairs and tunnel)
2. ☐ All interlocks tested per Interlock Test Procedure
3. ☐ Klystron grounding cable connected
4. ☐ Klystron HV cable connected with 4 screws in place
5. ☐ Klystron lead shielding panels and collector shielding in place

**Post Turn-On Surveys at ~100 kW:**
- Non-ionizing RF radiation: < 0.1 mW/cm² at all accessible waveguide joints
- Ionizing radiation: < 5 mR/hr at 30 cm from klystron surface

> **Source:** `ps3403305400.pdf` (PS-340-330-54-R0)

### 8.2 Annual Safety Survey (PS-340-330-55-R3)

**Frequency:** Once per year or after major downtimes of several days duration.

**Checklist (R3 revision):**
1. ☐ Waveguide connections verified; torque test 6 random bolts > 25 ft-lbs
2. ☐ Waveguide pressure interlock test verified
3. ☐ Klystron grounding cable connected
4. ☐ Klystron HV cable connected with 4 screws
5. ☐ HVPS Hoffman Box cover in place with securing bolts (R2 addition)
6. ☐ Klystron lead shielding per traveler photos and documentation (R3 addition)
7. ☐ Klystron area posted as Radiation Area (RA)
8. ☐ All personnel in/near RA must be RWT-I certified during survey

**Radiation Surveys:**
- At 100 kW: Non-ionizing < 0.1 mW/cm²; Ionizing < 5 mR/hr at 30 cm (and < 100 mR/hr contact)
- At full operating power: Ionizing < 5 mR/hr at 30 cm (and < 100 mR/hr contact)
- RP Field Operations Group (X4299) performs ionizing radiation surveys

> **Source:** `ps3403305503.pdf` (PS-340-330-55-R3)

### 8.3 Non-Ionizing Radiation Safety (PS-340-330-61-R2)

**Personnel Hazard Threshold:** RF radiation > 1.5 mW/cm² at 476 MHz.

**Reference:** ANSI C95.1-1982 (American National Standard Safety Levels for RF Electromagnetic Fields, 300 kHz to 100 GHz)

**Radiation Integrity Approach (3 layers):**
1. Careful assembly with inspection
2. RF field survey of fully assembled system
3. Waveguide pressurization system tied to interlock

**Waveguide Network:**
- WR2100 aluminum waveguide
- Two flange seal types: Parker Seals (penetrations, from PEP-I era) and flat/grooved flanges with silicone rubber O-rings (new installation)
- All flange bolts torqued to **30 ft-lbs** at assembly
- Post-installation: inspect minimum 6 random bolts per flange; pass if > 25 ft-lbs
- Field-assembled joints pressure-tested to 0.25 psig with "Snoop" bubble check

**Waveguide Pressurization System:**
- Regulated 0.25 psig instrument air through air dryer
- Limited volumetric supply rate: leak causes pressure drop
- Pressure switch actuates → RF station shutdown + beam abort
- After leak repair: radiation survey at ~100 kW before resuming operation
- **Guards against:** missing waveguide sections, improperly assembled flange joints

**Coaxial Cable Safety:**
- Warning labels on 120 W drive amplifier to klystron cables at each connector
- Labels specify up to 120 W may be present; do not disconnect while power ON

**Special Components:**
- Klystron output: 6-inch coaxial to WR2100 transition (pressurized)
- 1.2 MW circulator: specified leak-tight, part of pressurization; gas barrier on downstream side
- 1.2 MW loads: attached through waveguide gas barriers with large water drain holes
- Cavity window: special flange with O-ring sealed ceramic vacuum window (pressurized)
- Infrared monitors: measure window temperature through monitor port (beyond cutoff at 476 MHz)

> **Source:** `ps3403306102.pdf` (PS-340-330-61-R2), pages 3–8

### 8.4 Waveguide Pressure Interlock Verification (PS-340-330-61-R2, Section 11)

**Frequency:** At least once per year or after major downtime.

**Procedure:**
1. Locate pressure switches below circulator loads (2 switch sets + 1 gauge per zone)
2. Locate input air Tee to switches
3. Loosen compression fitting on 3/8" copper tubing supply to Tee
4. Gently pull tubing out while watching pressure gauge
5. Dip gauge pressure down to 3 inches
6. Verify: Local Panel Waveguide Pressure LED → Red
7. Verify on EPICS: Local Pressure Switch tripped AND NIRP Output for station tripped
8. Hit Reset and repeat as necessary
9. Re-connect and re-tighten air supply

> **Source:** `ps3403306102.pdf` (PS-340-330-61-R2), page 7

### 8.5 Waveguide Safety Work Control Procedure

**Two operational scenarios requiring work control:**

**Scenario I — Component removal/repair (no RF power needed):**
1. Prepare Waveguide Safety Work Control Form (WSWCF) for ADSO office
2. Lock Off PEP-II Bend Magnet Chopper Supplies in Region 8 (B685) — prevents beam-induced RF in cavities
3. Signatures: Person Responsible (RF Engineer), Area Manager, ADSO
4. Lock and Tag RF station HVPS off
5. After work: W.G. Pressure Relay Test, close out WSWCF

**Scenario II — Station commissioning/testing at full klystron power without cavities:**
1. Install waveguide shorting plate on circulator output
2. Requires HVPS PPS Bypass and RHP sign-off
3. Prepare WSWCF AND Radiation Safety Work Control Form (RSWCF)
4. Additional signatures: RHP, PPS
5. RHP padlocks waveguide shorts in place

> **Source:** `ps3403306102.pdf` (PS-340-330-61-R2), pages 10–13


---

## 9. SPEAR3 Adaptation Context

### 9.1 SPEAR3 RF System Overview

SPEAR3 is a 3 GeV third-generation synchrotron light source at SSRL (Stanford Synchrotron Radiation Lightsource). The RF system was upgraded in 2003 from the SPEAR2 configuration:

**SPEAR2 (before upgrade):**
- 1× 200 kW klystron
- 1× 358.5 MHz, 5-cell aluminum cavity
- 100 mA stored current

**SPEAR3 (after upgrade):**
- 1× 1.2 MW klystron (PEP-II type)
- 4× 476.3 MHz HOM-damped single-cell copper cavities (PEP-II type)
- 500 mA design current (operating with top-off injection)
- 3.2 MV total accelerating voltage (800 kV/cavity)
- LLRF system based on PEP-II design

> **Source:** McIntosh, P., "The SPEAR3 RF System," SLAC Technical Report (2005), OSTI ID:839730

### 9.2 What Transfers Directly from PEP-II to SPEAR3

The following PEP-II LLRF subsystems are directly applicable to SPEAR3:

| Subsystem | Applicability | Notes |
|-----------|---------------|-------|
| Baseband IQ processing architecture | ✅ Direct | Core signal processing unchanged |
| VXI module framework | ✅ Direct | Same hardware platform |
| RFP Module | ✅ Direct | RF modulation and drive chain |
| IQ/AMP Detector modules | ✅ Direct | Cavity signal downconversion |
| Direct Loop | ✅ Direct | Primary impedance reduction |
| Tuner Loop | ✅ Direct | Cavity resonance tracking |
| HVPS Loop | ✅ Direct | Klystron power regulation |
| DAC Loop | ✅ Direct | Gap voltage fine correction |
| Ripple Loop | ✅ Direct | Klystron ripple compensation |
| EPICS control interface | ✅ Direct | Same IOC framework |
| MATLAB calibration routines | ✅ Direct | ConfDirect, Tune Cavs, Make Poly, etc. |
| Woofer link | ✅ Direct | Longitudinal feedback interface |
| Arc/Interlock detection | ✅ Direct | Safety systems |
| Clock & RF Distribution | ✅ Direct | Reference signal handling |
| Built-in network analyzer | ✅ Direct | MeasDirCls, etc. |

### 9.3 PEP-II-Specific Modules NOT Required for SPEAR3

| Module | Function | Why Not Needed |
|--------|----------|----------------|
| **Comb Filter Module (CFM)** | Multi-cavity impedance reduction at revolution harmonics with 1-turn delay | PEP-II-specific for collider ring dynamics with large circumference and many bunches. SPEAR3 has different coupled-bunch instability spectrum. |
| **Gap Voltage Feed-Forward (GVF)** | Compensation for ion-clearing gap transients | PEP-II-specific beam fill pattern with large ion-clearing gap. SPEAR3 operates differently. |
| **Gap Feed-Forward (GFF)** | Adaptive feedforward to ignore gap effects on Direct Loop | Complementary to GVF; PEP-II-specific. |
| **Optimized Station Phasing** | Multi-station phase equalization | PEP-II had 5+ stations per ring. SPEAR3 has single station. |

> ⚠️ **IMPORTANT:** The CFM, GVF, and GFF are PEP-II-specific modules designed for the PEP-II collider's unique operating conditions (large circumference, many bunches, ion-clearing gaps, multi-station configuration). They should NOT be attributed to the SPEAR3 architecture.

### 9.4 Key Differences: PEP-II vs. SPEAR3

| Parameter | PEP-II LER | PEP-II HER | SPEAR3 |
|-----------|------------|------------|--------|
| Energy | 3.1 GeV | 9 GeV | 3 GeV |
| RF Frequency | 476 MHz | 476 MHz | 476.3 MHz |
| Beam Current | 2.00 A | 1.03 A | 0.5 A |
| Cavities per Station | 2 | 4 | 4 |
| Number of Stations | 2–3 | 5 | 1 |
| Total Cavities | 4–6 | 20 | 4 |
| Gap Voltage / Cavity | 850 kV | 700 kV | 800 kV |
| Klystron Power | 1.2 MW | 1.2 MW | 1.2 MW |
| Ring Type | Collider (positrons) | Collider (electrons) | Light source (electrons) |
| Ion-Clearing Gap | Yes (large) | Yes (large) | No (or small) |
| Circumference | 2200 m | 2200 m | 234 m |

### 9.5 SPEAR3 LLRF Control System Resources

The SPEAR3 LLRF controls are documented at:
- **SPEAR LLRF Controls Homepage:** https://slac.stanford.edu/grp/ssrl/spear/epics/app/rf/index.html
- Content includes: EPICS databases, setup procedures, IQA module calibration, station configuration, woofer configuration, MATLAB programs, configuration tables

> **Source:** SLAC SPEAR EPICS Controls documentation


---

## 10. External References & Published Papers

### 10.1 Key Published Papers

| # | Authors | Title | Reference | Year |
|---|---------|-------|-----------|------|
| 1 | P. Corredoura | "Architecture and Performance of the PEP-II Low-Level RF System" | SLAC-PUB-8024; DOI: 10.2172/10204 | 1999 |
| 2 | P. Corredoura et al. | "Experience with the PEP-II RF System at High Beam Currents" | SLAC-PUB-8498; arXiv: physics/0007029 | 2000 |
| 3 | J. Fox, T. Mastorides, C. Rivetta et al. | "Lessons Learned from PEP Low Level RF and Longitudinal Feedback" | Phys. Rev. ST Accel. Beams 13, 052802 | 2010 |
| 4 | C. Rivetta, T. Mastorides, J.D. Fox et al. | "Modeling and Simulation of Longitudinal Dynamics for LER-HER at PEP" | Phys. Rev. ST Accel. Beams 10, 022801 | 2007 |
| 5 | P. Corredoura | "Klystron Equalization for RF Feedback" | SLAC-PUB-6049 | 1993 |
| 6 | P. McIntosh | "The SPEAR3 RF System" | SLAC Technical Report; DOI: 10.2172/839730 | 2005 |
| 7 | S. Park, J. Corbett | "Booster Synchrotron RF System Upgrade for SPEAR3" | OSTI ID:1045177 | 2010 |
| 8 | S. Park | "SSRL RF System Upgrade" | CERN: cds.cern.ch/record/394334 | 1999 |
| 9 | R. Hettel et al. | "Design of the SPEAR 3 Light Source" | SLAC; includes P. Corredoura as co-author | 2001 |
| 10 | R. Hettel | "SPEAR 3 Design Report" | SLAC Technical Report; DOI: 10.2172/808721 | 2002 |

### 10.2 Online Resources

| Resource | URL |
|----------|-----|
| SPEAR3 LLRF Controls Homepage | https://slac.stanford.edu/grp/ssrl/spear/epics/app/rf/index.html |
| SPEAR3 Accelerator Page | https://www-ssrl.slac.stanford.edu/ssrl/web/spear3 |
| SPEAR3 Technical Documentation | https://www-ssrl.slac.stanford.edu/spear3/spear3_technical.html |
| PEP-II LLRF Architecture Paper (OSTI) | https://www.osti.gov/biblio/10204 |
| PEP-II High Current Experience (arXiv) | https://arxiv.org/pdf/physics/0007029 |
| SPEAR3 RF System Paper (OSTI) | https://www.osti.gov/biblio/839730 |
| SPEAR3 Design Report (OSTI) | https://www.osti.gov/biblio/808721 |

### 10.3 Key Personnel

| Name | Role | Affiliation |
|------|------|-------------|
| Paul Corredoura | LLRF system designer and lead engineer | SLAC |
| Heinz Schwarz | RF system description and procedures author | SLAC |
| Alan Hill | RF Area Manager (approved procedures) | SLAC |
| J. Judkins | Non-ionizing radiation safety co-author | SLAC |
| M. Allen | Non-ionizing radiation safety co-author | SLAC |
| R. Tighe | LLRF operations | SLAC |
| S. Allison | LLRF operations / EPICS | SLAC |
| W. Ross | LLRF operations | SLAC |
| R. Sass | LLRF operations | SLAC |
| J. Fox | Longitudinal feedback system | SLAC |
| C. Rivetta | LLRF modeling and simulation | SLAC |
| T. Mastorides | LLRF modeling | SLAC |
| D. Teytelman | Feedback system design | SLAC |
| P. McIntosh | SPEAR3 RF system | SLAC |
| S. Park | SPEAR3/SSRL RF upgrade | SLAC |
| J. Corbett | SPEAR3 accelerator physics | SLAC |
| R. Hettel | SPEAR3 project lead | SLAC/SSRL |

---

## 11. Glossary

| Abbreviation | Full Term |
|-------------|-----------|
| ADC | Analog-to-Digital Converter |
| ADSO | Accelerator Department Safety Officer |
| CFM | Comb Filter Module (PEP-II specific) |
| CW | Continuous Wave |
| DAC | Digital-to-Analog Converter |
| DH-465 | Allen-Bradley Data Highway communication protocol |
| EOIC | Engineering Officer in Charge |
| EPICS | Experimental Physics and Industrial Control System |
| FM | Frequency Modulation |
| GFF | Gap Feed-Forward (PEP-II specific) |
| GVF | Gap Voltage Feed-Forward (PEP-II specific) |
| HCW | High-Conductivity Water |
| HER | High Energy Ring (PEP-II, 9 GeV electrons) |
| HOM | Higher-Order Mode |
| HVPS | High-Voltage Power Supply |
| IOC | Input/Output Controller (EPICS) |
| IQ | In-phase / Quadrature |
| LCW | Low-Conductivity Water |
| LER | Low Energy Ring (PEP-II, 3.1 GeV positrons) |
| LFB | Longitudinal Feedback |
| LLRF | Low-Level Radio Frequency |
| NIRP | Non-Ionizing Radiation Protection |
| PEP-II | Positron-Electron Project II (B-Factory at SLAC) |
| PID | Proportional-Integral-Derivative (controller) |
| PLC | Programmable Logic Controller |
| PPS | Personnel Protection System |
| PROC | Processing mode |
| RA | Radiation Area |
| RHP | Radiation Health Physics |
| RSWCF | Radiation Safety Work Control Form |
| RWT-I | Radiation Worker Training - Level I |
| SLC | SLAC Linear Collider |
| SPEAR | Stanford Positron Electron Asymmetric Ring |
| SSRL | Stanford Synchrotron Radiation Lightsource |
| VACION | Varian Ion Pump |
| VXI | VMEbus Extensions for Instrumentation |
| WSWCF | Waveguide Safety Work Control Form |

---

*Document compiled from original PEP-II engineering documents for the SPEAR3 LLRF upgrade project.*  
*All source PDFs are located in `llrf/documentation/legacyArchitecture/`.*
