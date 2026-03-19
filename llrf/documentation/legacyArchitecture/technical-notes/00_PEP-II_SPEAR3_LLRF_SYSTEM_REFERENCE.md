# PEP-II / SPEAR3 LLRF System — Comprehensive Technical Reference

**Document Number**: LLRF-REF-001
**Version**: 3.0
**Date**: 2026-03-19
**Classification**: Engineering Technical Reference — AI-Ready Documentation Package
**Companion Documents**:
- `Designs/0_PHYSICAL_DESIGN_REPORT.md` — SPEAR3 LLRF Upgrade PDR (Rev 1, March 2026)
- `Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` — Source code analysis

---

## Document Purpose

This document provides a **comprehensive, AI-ingestible technical reference** for the PEP-II Low-Level RF (LLRF) system as adapted for the SPEAR3 storage ring at SSRL/SLAC. It reconstructs the complete system architecture from three complementary source layers:

1. **Legacy engineering drawings** — 15 image-based PDFs in `legacyArchitecture/` (cataloged and content-mapped herein)
2. **Published technical literature** — SLAC technical reports and peer-reviewed papers (synthesized herein)
3. **Legacy source code** — SNL/EPICS control programs in `spear-rf-code-legacy/rfApp/src/seq/` (analyzed in the companion document)

### Related Documents in This Package

| Document | File | Coverage |
|----------|------|----------|
| This document | `00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` | System overview, hardware architecture, RF theory |
| Feedback Loop Architecture | `01_FEEDBACK_LOOP_ARCHITECTURE.md` | Detailed loop analysis and reconstruction |
| VXI Hardware Module Reference | `02_VXI_HARDWARE_MODULE_REFERENCE.md` | Module-level hardware documentation |
| Legacy PDF Catalog | `03_LEGACY_PDF_CATALOG.md` | Complete PDF inventory and content mapping |
| Literature Synthesis | `04_LITERATURE_SYNTHESIS.md` | Published paper analysis and operational insights |
| Cross-Reference Index | `05_CROSS_REFERENCE_INDEX.md` | Topic → source mapping matrix |
| Legacy Control System Design | `../../Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` | Source code-derived control logic |

---

## PART I: SYSTEM CONTEXT AND OVERVIEW

### 1.1 Historical Context

The PEP-II B-Factory at SLAC was an asymmetric electron-positron collider operating from 1999 to 2008. Its RF system operated at **476 MHz** and was designed to handle extreme beam loading conditions:

- **High Energy Ring (HER)**: 9 GeV, up to 1.8 A stored current, 5 nominal RF stations (4 cavities each) — later expanded to 7 stations during high-luminosity upgrades
- **Low Energy Ring (LER)**: 3.1 GeV, up to 3.0 A stored current, 2 nominal RF stations (2 cavities each) — later expanded to 3 stations

> **Clarification (cross-referenced with PS-340-330-51-R0)**: The original PEP-II RF system design (Schwarz, July 1999) specified **5 HER stations** (8HR1, 8HR3, 8HR5 in region 8/B685; 12HR1, 12HR3 in region 12/B725) and **2 LER stations** (4LR4, 4LR5 in region 4/B645, with a 3rd station 4LR3 partially installed). The higher counts (7 HER, 3 LER) reflect the final expanded operational configuration.
> **Source**: `legacy-pdf-transcriptions/design-specifications/PS-340-330-51_RF_System_Description.md`

The LLRF system was designed by **P. Corredoura, S. Allison, R. Sass, R. Tighe, and R. Claus** at SLAC (1996–1997) and evolved throughout PEP-II operation (1999–2008).

**Key Design Reference**: Corredoura, P.L., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8498, April 1999. DOI: 10.2172/10204

### 1.2 SPEAR3 Adoption

In 2003, SPEAR (Stanford Positron Electron Asymmetric Ring) was upgraded to **SPEAR3**, a 3rd-generation synchrotron light source. The RF system upgrade replaced the original 358.54 MHz system with essentially a **PEP-II HER RF station**:

| Parameter | SPEAR2 (original) | SPEAR3 (PEP-II heritage) |
|-----------|-------------------|--------------------------|
| RF Frequency | 358.54 MHz | 476.315 MHz |
| Harmonic Number | 280 | 372 |
| Cavities | 1 × 5-cell aluminum | 4 × single-cell copper (PEP-II type) |
| Klystron | PEP-I type, ~200 kW | 1.2 MW (PEP-II type) |
| Gap Voltage | 1.6 MV total | 3.2 MV total (800 kV/cavity) |
| Beam Current | 100 mA | 500 mA (design) |
| Beam Energy | 3.0 GeV | 3.0 GeV |
| LLRF Control | Analog + EPICS | PEP-II VXI LLRF + EPICS (adopted) |

**Key Reference**: McIntosh, P., "The SPEAR3 RF System," SLAC-PUB-11017, January 2005. DOI: 10.2172/839730

The SPEAR3 LLRF system is a **single-station** implementation of the PEP-II LLRF design, driving 4 cavities from one klystron. The control software (SNL/EPICS sequences) was adapted from PEP-II with station-specific macro substitutions.

**Source**: McIntosh, P., "The SPEAR3 RF System," SLAC-PUB-11017, January 2005; Sebek, J., "SPEAR3 RF Station Operation," `llrf/documentation/LLRFOperation_jims.docx`

### 1.3 SPEAR3 LLRF Upgrade Context (2022–present)

As of 2026, the SPEAR3 LLRF system is undergoing a comprehensive upgrade (documented in `Designs/0_PHYSICAL_DESIGN_REPORT.md`, Rev 1, March 2026). The upgrade replaces **all control electronics** while retaining the RF plant physical infrastructure. Key drivers:

- **Hardware obsolescence** — Custom SLAC VXI modules, PLC-5/SLC-500 controllers, and Slo-Syn stepper motor drivers are all end-of-life and unsupported
- **PPS compliance** — Legacy design routes Personnel Protection System wiring through the HVPS controller and places a PLC in the safety chain
- **Performance improvement** — FPGA-based feedback (270 ns loop delay) replaces analog processing
- **Diagnostics** — 16,384-sample waveform capture + circular buffers + first-fault detection

**What is retained**: Klystron, 4 RF cavities, waveguide distribution network, HVPS power section (transformers, rectifiers, crowbar), stepper motors and mechanical tuner assemblies, field cabling.

**What is replaced**: LLRF controller (VXI → Dimtel LLRF9/476 × 2), RF MPS (PLC-5 → ControlLogix 1756), HVPS controller (SLC-500 → CompactLogix), tuner controller (AB 1746-HSTP1 → Galil DMC-4143), control software (SNL/VxWorks → EPICS/Python/MATLAB).

**What is new**: Interface Chassis (central hardware interlock hub), Waveform Buffer System (8 RF + 4 HVPS monitoring channels), Arc Detection System (6 Microstep-MIS optical sensors), PPS Interface Box (dedicated, PLC-independent).

**Eliminated PEP-II feedback loops**: The following legacy loops are no longer needed in the LLRF9 architecture:
- **Comb (Narrowband) RF Feedback Loop** — Used for PEP-II multi-bunch stabilization; not applicable to SPEAR3 single-station configuration
- **Gap Voltage Feed-Forward (GVF)** — PEP-II cavity field stabilization; now handled by LLRF9 vector-sum feedback
- **Ripple Feedback Loop** — LLRF9 digital feedback inherently rejects power-line ripple
- **4-way DAC branching** — LLRF9 controls via single vector sum output

> **Source**: `Designs/0_PHYSICAL_DESIGN_REPORT.md`, Section 15.7; `llrf/documentation/LLRFUpgradeTaskListRev3.docx`

### 1.4 System Operating Parameters (SPEAR3)

| Parameter | Symbol | Value | Notes |
|-----------|--------|-------|-------|
| RF Frequency | f_RF | 476.315 MHz | Harmonic 372 of revolution frequency |
| Revolution Frequency | f_rev | 1.2808 MHz | C = 234.137 m |
| Beam Energy | E | 3.0 GeV | |
| Design Beam Current | I_b | 500 mA | Top-off mode |
| Bunch Spacing | | 2.1 ns | 476 MHz RF period |
| Fill Pattern | | 276 bunches in 4 groups + 1 camshaft | |
| Number of Cavities | | 4 | Single-cell, HOM-damped copper |
| Cavity Shunt Impedance | R_s | 3.9 MΩ | Per cavity |
| Cavity Unloaded Q | Q_0 | 33,500 | |
| Cavity Loaded Q | Q_L | 6,700 | β = 4.0 |
| Gap Voltage per Cavity | V_gap | 800 kV | Design operating point, now operating at 712kV |
| Total Accelerating Voltage | V_total | 3.2 MV | Sum of 4 cavities (2.5 MV for now) |
| Klystron Power | P_kly | 1.2 MW max | operating at 74 kV cathode voltage |
| Klystron Type | | SLAC design | 476 MHz CW |
| IF Frequency (LLRF) | f_IF | 4.9 MHz | 476 - 471.1 MHz LO |
| LO Frequency | f_LO | 471.1 MHz | |

### 1.4a PEP-II RF Cavity Nominal Parameter Table (Schwarz, 1998)

The following parameters are from the original PEP-II design document PS-340-330-51-R0. These represent the **design operating point** and provide critical context for the SPEAR3 adaptation.

| Parameter | Symbol | Unit | HER | LER |
|-----------|--------|------|-----|-----|
| Frequency | f₀ | MHz | 476 | 476 |
| RF Voltage / Ring | V | MV | 14.00 | 3.40 |
| Number of Cavities | n | — | 20 | 4 |
| Cavities / Klystron | m | — | 4 | 2 |
| Shunt Impedance | R_s | MΩ | 3.73 | 3.73 |
| Shunt Impedance (accel. notation) | Rₐ=2*R_s | MΩ | 7.5 | 7.5 |
| Gap Voltage / Cavity | V_c | kV | 700.0 | 850.0 |
| Cavity Wall Power | P_c=V_c^2/Rₐ | kW | 65.7 | 96.8 |
| Beam Power / Cavity | P_b | kW | 186.3 | 408.3 |
| Total Power / Cavity | P_totc | kW | 252.0 | 505.2 |
| Forward Power / Cavity | P_fwd | kW | 252.0 | 519.7 |
| Loaded Q | Q_L | — | 6,780 | 6,780 |
| Optimum Coupling Factor (β=1+P_b/P_c) | β | — | 3.84 | 5.22 |
| Synchronous Phase Angle | φ | degrees | 75.0 | 76.10 |
| Detuning Angle | ψ | degrees | −66.0 | −74.52 |
| Change in Resonant Frequency | Δf | kHz | −78.9 | −126.7 |
| Generator Power / Cavity | P_g | kW | 252.0 | 519.7 |
| Klystron Power | P_kly | kW | 1,049 | 1,082 |
| Synchrotron Frequency | f_s | kHz | 6.10 | 3.67 |

> **Source**: `legacy-pdf-transcriptions/design-specifications/PS-340-330-51_RF_System_Description.md` — transcribed from Schwarz parameter table dated 5/20/98.

### 1.4b PEP-II RF Station Physical Infrastructure

From PS-340-330-51, each PEP-II RF station includes:

**Equipment Inventory per Station**:
| Equipment | HER | LER | Location |
|-----------|-----|-----|----------|
| 1.2 MW Klystron | 1 | 1 | Surface building |
| HVPS (2 MW, 90 kV, 23 A) | 1 | 1 | Exterior pad |
| Circulator + Load | 1 | 1 | Surface building |
| Magic-Tee splitters | 3 | 1 | Surface building |
| 1.2 MW Waveguide Loads | 3 | 1 | Surface building |
| Single-cell 476 MHz Cavities | 4 | 2 | Tunnel |
| HOM Loads per cavity | 3 | 3 | Tunnel |
| Movable Tuner per cavity | 1 | 1 | Tunnel |
| Ceramic Window per cavity | 1 | 1 | Tunnel |
| 400 l/s VACION Pump per cavity | 1 | 1 | Tunnel |
| Equipment Racks | 6 | 6 | Surface building |
| LLRF Blue Rack (air-conditioned) | 1 | 1 | Surface building |
| Allen Bradley PLC-5 Control | 1 | 1 | In equipment racks |
| EPICS Workstation | 1 | 1 | Surface building |
| Grounding Switch (aluminum tank) | 1 | 1 | Adjacent to racks |

**Cooling Systems** (3 circuits per region):
| System | Medium | Temperature | Serves |
|--------|--------|-------------|--------|
| LCW Loop 1 | Low-Conductivity Water | 35°C (regulated) | Klystron |
| LCW Loop 2 | Low-Conductivity Water | 35°C (regulated) | Cavities (tunnel) |
| HCW Loop | High-Conductivity Water | Unregulated | Waveguide loads |

**Master Oscillator**: Located in the PEP control room in region 8, connected to the Main Drive Line of the LINAC in sector 30 and to other PEP region RF stations via phase-stabilized RF distribution lines.

> **Source**: `legacy-pdf-transcriptions/design-specifications/PS-340-330-51_RF_System_Description.md`; `legacy-pdf-transcriptions/block-diagrams/BD-340-330-00_PEP-II_LER_RF_Station_Block_Diagram.md`

### 1.5 LLRF9/476 Key Specifications (Upgrade System)

The LLRF9/476 from Dimtel is the replacement for the entire VXI-based LLRF system. Two active units (of 4 purchased) replace the RFP, Clock, IQA, Comb Filter, and GVF modules:

| Parameter | Value | Source |
|-----------|-------|--------|
| Hardware per unit | 3 × LLRF4.6 boards (Xilinx FPGA + 4 ADC + 2 DAC + 3 RF ch) | PDR §5.2 |
| Direct loop delay | 270 ns | PDR §5.4 |
| RF input range | +2 dBm full-scale, 12-bit ADC | PDR §5.4 |
| Setpoint profiles | 512 points, 70 μs – 37 ms per step | PDR §5.4 |
| Waveform capture | 16,384 samples/channel | PDR §5.4 |
| Scalar readback rate | 10 Hz | PDR §5.4 |
| Interlock timestamp | ±17.4 ns resolution | PDR §5.4 |
| Thermal stabilization | 3 TEC modules on BRD1, BRD2 (PID controlled) | PDR §5.2 |

**LO Frequency Plan** (LLRF9/476, nominal f_RF = 476.3052 MHz):

| Signal | Ratio to f_RF | Frequency (MHz) |
|--------|--------------|-----------------|
| RF Reference | 1 | 476.3052 |
| IF | 1/12 | 39.6921 |
| Local Oscillator | 11/12 | 436.6131 |
| ADC Clock | 11/48 | 109.1533 |
| DAC Clock | 11/24 | 218.3065 |

**Two-unit SPEAR3 configuration**:
- **Unit 1** (Field Control & Tuner): BRD1 outputs klystron drive (thermally stabilized); monitors cavity probes A/B with PI control. BRD2 monitors probes C/D with integral control. BRD3 monitors circulator/load forward powers.
- **Unit 2** (Monitoring & Interlocks): BRD1 monitors cavity D probe + drive forward. BRD2 monitors klystron reflected/forward. BRD3 monitors all 4 cavity reflected powers. Interlock output to Interface Chassis on reflected power events.

> **Source**: `Designs/0_PHYSICAL_DESIGN_REPORT.md`, Sections 5.2–5.5

### 1.6 Fundamental Design Challenge: Beam Loading

The dominant design driver for the PEP-II LLRF system is **heavy beam loading**. At high beam currents, the beam-induced voltage in the cavity can exceed the generator-supplied voltage, creating:

1. **Robinson instability** — the beam-cavity interaction creates a positive feedback that can exponentially grow synchrotron oscillations
2. **Coupled-bunch instabilities** — driven by the fundamental cavity impedance seen by revolution harmonics
3. **Ion clearing gap transients** — the gap in the fill pattern creates large periodic transients in cavity voltage

The LLRF feedback system addresses these by:
- **Reducing effective cavity impedance** seen by the beam (direct loop reduces impedance by ~factor of 100)
- **Filtering revolution harmonics** to suppress coupled-bunch mode growth (comb loop — PEP-II only)
- **Compensating klystron gain/phase variations** as power demand changes (baseband modulator / gain tracking)
- **Canceling power supply ripple** that modulates klystron output (ripple loop)

### 1.7 Signal Processing Philosophy: IQ Baseband

The PEP-II LLRF system uses **In-phase / Quadrature (IQ) baseband signal processing** throughout. All RF signals at 476 MHz are heterodyned down to baseband using a common Local Oscillator at 471.1 MHz (PEP-II) or equivalent frequency, producing IQ signal pairs that represent the amplitude and phase of each RF signal.

This approach provides:
- **Vector control** — independent manipulation of amplitude and phase
- **Wideband feedback** — baseband bandwidth set by analog electronics (~MHz), not limited to narrowband around RF carrier
- **Precise measurement** — digital IQ demodulators (IQA modules) provide high-accuracy amplitude/phase readings
- **Programmability** — baseband signals are accessible to DSP and DAC-based control

The IQ representation:
```
V_RF(t) = I(t) · cos(ω_RF · t) - Q(t) · sin(ω_RF · t)

Amplitude: A = √(I² + Q²)
Phase:     φ = arctan(Q / I)
```

---

## PART II: SYSTEM ARCHITECTURE OVERVIEW

### 2.1 RF Station Physical Layout

Each PEP-II / SPEAR3 RF station consists of:

```
┌───────────────────────────────────────────────────────────────────┐
│                    RF STATION BLOCK DIAGRAM                       │
│                                                                   │
│  ┌──────────┐      ┌───────────┐    ┌──────────┐     ┌──────────┐ │
│  │  HVPS    │───▶ │  KLYSTRON │───▶│CIRCULATOR│───▶│ WAVEGUIDE│ │
│  │ (90 kV)  │     │ (1.2 MW)  │     │          │     │ NETWORK  │ │
│  └──────────┘     └─────┬─────┘     └─────┬────┘     └────┬─────┘ │
│                         │                 │               │       │
│                   ┌─────┴───┐     ┌───────┴──┐    ┌───────┴─┐     │
│                   │  Drive  │     │Reflected │    │ Forward │     │
│                   │  Amp    │     │  Load    │    │ to Cav  │     │
│                   │ (120 W) │     │          │    │ 1,2,3,4 │     │
│                   └────┬────┘     └──────────┘    └────┬────┘     │
│                        │                               │          │
│  ┌─────────────────────┴───────────────────────────────┴──────┐   │
│  │              VXI CRATE — LLRF SYSTEM                       │   │
│  │                                                            │   │
│  │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐           │   │
│  │  │ μP  │ │ CLK │ │ RFP │ │IQA-1│ │IQA-2│ │IQA-3│           │   │
│  │  │Slot0│ │ RF  │ │     │ │     │ │     │ │     │           │   │
│  │  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘           │   │
│  │                                                            │   │
│  │  ┌─────┐ ┌─────┐ ┌──────┐ ┌──────┐ ┌─────┐                 │   │
│  │  │COMB │ │COMB │ │ GVF  │ │ ARC/ │ │SPARE│                 │   │
│  │  │(I)⚠│  │(Q)⚠│ │FFWD⚠│ │INTLK │ │     │                 │   │
│  │  └─────┘ └─────┘ └──────┘ └──────┘ └─────┘                 │   │
│  │  ⚠ = PEP-II ONLY (not used in SPEAR3)                     │   │
│  │                                                            │   │
│  │  Ethernet ◄──► EPICS IOC (VxWorks) ◄──► Channel Access     │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │  RF CAVITY ARRAY (×4)                                      │   │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐                    │   │
│  │  │Cav A │  │Cav B │  │Cav C │  │Cav D │    ◄── Beam        │   │
│  │  │      │  │      │  │      │  │      │                    │   │
│  │  │Probe │  │Probe │  │Probe │  │Probe │                    │   │
│  │  │Tuner │  │Tuner │  │Tuner │  │Tuner │                    │   │
│  │  └──────┘  └──────┘  └──────┘  └──────┘                    │   │
│  └────────────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────────┘
```

**Source**: Corredoura, SLAC-PUB-8498, Fig. 1; Cross-ref: `bd3403300000.pdf`, `bd3403300100.pdf`

### 2.2 Signal Flow: RF to Baseband IQ

The fundamental signal processing chain in the PEP-II LLRF system:

```
RF Signal Path (476 MHz → IQ Baseband):
═══════════════════════════════════════

   Cavity Probes (×4)          IQ Demodulator
   ┌──────────────┐           ┌──────────────┐
   │ 476 MHz RF   │──mixer──▶│  I component  │──▶ To feedback
   │ from each    │    │      │  Q component  │    processing
   │ cavity probe │    │      └──────────────┘
   └──────────────┘    │
                       │
                  ┌────┴────┐
                  │  LO     │
                  │471.1 MHz│
                  └─────────┘

   Σ (Vector Sum of 4 cavities) ──▶ "Station Gap Voltage"

Drive Signal Path (IQ Baseband → 476 MHz):
═══════════════════════════════════════════

   IQ Reference     IQ Modulator       Drive Chain
   ┌──────────┐    ┌──────────────┐   ┌──────────────┐
   │ I_ref    │──▶│  476 MHz RF  │──▶│  120 W amp   │──▶ Klystron
   │ Q_ref    │──▶│  output      │   │  (solid state)│
   └──────────┘    └──────────────┘   └──────────────┘
         ▲               ▲
         │               │
   ┌─────┴─────┐   ┌────┴────┐
   │ Feedback  │   │  LO     │
   │ Processor │   │471.1 MHz│
   │ (RFP)     │   └─────────┘
   └───────────┘
```

### 2.3 Control Loop Hierarchy

The LLRF system implements a **multi-rate hierarchical feedback architecture**:

```
BANDWIDTH / RATE        LOOP                      FUNCTION
══════════════════════════════════════════════════════════════════
~800 kHz (analog)  ┌─ Direct Loop ──────────── Cavity field stabilization
                   │                            (impedance reduction ~100×)
                   │
~2 MHz span,       ├─ Comb Loop [PEP-II ONLY] ─────────────── Revolution harmonic filtering
~10 kHz/tooth      │                            (coupled-bunch suppression)
(digital DSP)      │
                   │
~300 Hz (analog)   ├─ Ripple Loop ───────────── HVPS switching ripple
                   │                            cancellation
                   │
~10 kHz (analog)   ├─ Lead/Integral Comp ────── Phase margin improvement
                   │                            and steady-state accuracy
                   │
~1 Hz (EPICS)      ├─ HVPS Loop ─────────────── Klystron beam voltage
                   │                            regulation
                   │
~0.1 Hz (EPICS)    ├─ DAC Loop ──────────────── Setpoint adjustment
                   │                            (drive power / gap voltage)
                   │
~1 Hz (EPICS)      ├─ Tuner Loop ────────────── Cavity resonance frequency
                   │                            (stepper motor)
                   │
Gain tracking      └─ Klystron Sat Loop ─────── Baseband modulator gain
 (quasi-static)                                 compensation for klystron
                                                nonlinearity
```

**Critical stability requirement**: Each loop bandwidth must be separated by at least one decade to prevent inter-loop coupling:

```
f_BW(comb span) >> f_BW(direct) >> f_BW(ripple) >> f_BW(HVPS) ~ f_BW(tuner) >> f_BW(DAC)
  ~2 MHz        ~800 kHz          ~300 Hz        ~1 Hz        ~1 Hz          ~0.1 Hz
```

**Source**: Corredoura SLAC-PUB-8498; Fox et al. Phys. Rev. ST Accel. Beams 13, 052802 (2010)
**Cross-ref**: `feedbackLoopDescriptionps3403305200.pdf` (8 pages), `01_FEEDBACK_LOOP_ARCHITECTURE.md`

> **Bandwidth clarification (cross-referenced with PS-340-330-52-R0)**: The Comb Loop operates over a **2 MHz overall span** (per PS-52: "bandwidth of 2 MHz"). Within that span, each comb tooth has a per-tooth bandwidth of ~10 kHz. The Direct Loop's 800 kHz bandwidth refers to its closed-loop unity-gain crossover frequency, while the Comb Loop's 2 MHz span refers to the frequency range containing the revolution harmonics where the comb filter provides gain.
> **Source**: `legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md`

---

## PART III: FEEDBACK LOOP ARCHITECTURE SUMMARY

> **Detailed analysis**: See `01_FEEDBACK_LOOP_ARCHITECTURE.md`

### 3.1 Direct (Wideband) RF Feedback Loop

**Purpose**: Reduce the effective cavity impedance seen by the beam by a factor of ~100, suppressing Robinson instability and reducing coupled-bunch growth rates.

**Implementation**: Analog feedback at baseband. The cavity probe signal (IQ-demodulated) is compared with a reference setpoint. The error signal drives the klystron through the IQ modulator.

**Block Diagram** (from Corredoura SLAC-PUB-8498, Fig. 3):
```
                    ┌────────────────┐
  IQ Reference ──▶(+)──▶│  Gain     │──▶ IQ Modulator ──▶ Klystron
                  (-)    │  + Phase  │         ▲
                   ▲     │  Adjust   │         │ 476 MHz
                   │     └───────────┘         │ Carrier
                   │                           │
                   │     ┌────────────┐        │
                   └─────│ IQ Demod   │◀── Cavity Probe (vector sum)
                         └────────────┘
```

**Key Parameters**:
- Bandwidth: ~800 kHz (limited by group delay through klystron + cavity)
- Impedance reduction: ~40 dB (factor of 100)
- Phase margin: Must be carefully set to avoid instability
- Complication: Loss of cavity probe signal causes immediate saturation

**Source Code**: Direct loop ON/OFF is controlled by `rf_states.st` variable `direct_loop`; the `rf_dac_loop.st` adjusts DAC setpoints differently depending on direct loop state.

### 3.2 Comb (Narrowband) RF Feedback Loop — ⚠️ PEP-II ONLY

> ⚠️ **This loop was NOT used in the SPEAR3 legacy system and is NOT present in the LLRF9 upgrade. Retained for PEP-II historical reference.**

**Purpose**: Provide additional gain at revolution frequency harmonics to further suppress coupled-bunch modes that the direct loop alone cannot fully damp.

**Implementation**: Digital FIR filter with one-turn delay, operating in parallel with the direct loop. The comb filter has high gain at revolution harmonics (spaced by f_rev = 1.28 MHz for SPEAR3, 136.3 kHz for PEP-II) and low gain between them.

```
                          ┌──────────────────┐
  Error Signal ──▶──────▶│  Comb Filter     │──▶(+)──▶ Drive
                          │  (1-turn delay)  │    ▲
                          │  I and Q         │    │
                          │  separate filters│    │
                          └──────────────────┘    │
                                                  │
                              Direct Loop Output──┘
```

**Key Parameters**:
- Comb filter bandwidth per tooth: Configurable
- Revolution harmonic spacing: 1.2808 MHz (SPEAR3) / 136.3 kHz (PEP-II)
- Implementation: Dedicated VXI Comb Filter modules (I and Q separate)

**Source Code**: Comb loop amplitude/phase are PV-controlled; `rf_calib.st` handles comb filter calibration.

### 3.3 Ripple Loop

**Purpose**: Cancel RF amplitude/phase modulation caused by the switching HVPS power supply ripple (~360 Hz for 6-pulse SCR, harmonics up to ~50 kHz).

**Implementation**: Originally intended as DSP-based; ultimately implemented as an analog wideband feedback. The ripple loop detects the klystron output modulation and feeds back to cancel it.

**Key Challenge** (from Corredoura 2000): "An analog integrator in the direct RF feedback loop cancels the ripple but simulations show it will cause instability as beam currents reach 2A."

**Source Code**: `rf_dac_loop.st` contains `ripple_loop_ampl` PV and `ripple_loop_load` processing.

### 3.4 Tuner Loop

**Purpose**: Keep the cavity resonant frequency tuned relative to the RF drive frequency. The optimal detuning depends on beam current and compensates for the reactive component of beam loading.

**Implementation**: EPICS-based slow loop controlling stepper motors on each cavity's mechanical tuner. The tuner position is adjusted based on the phase angle between the forward power and cavity voltage.

**Source Code**: `rf_tuner_loop.st` — per-cavity instances via `CAV` macro.

### 3.5 HVPS Voltage Regulation Loop

**Purpose**: Regulate klystron cathode voltage to maintain drive power or gap voltage at setpoint. During "processing" mode, carefully ramps voltage while monitoring cavity vacuum.

**Source Code**: `rf_hvps_loop.st` — states: init, off, proc, on.

### 3.6 Gap Voltage Feed-Forward (GVF) — ⚠️ PEP-II ONLY

> ⚠️ **The GVF module is PEP-II hardware only. In SPEAR3, gap voltage control was handled by the DAC control loop in VxWorks software. Not present in LLRF9 upgrade.**

**Purpose**: Provide a feed-forward path to stabilize gap voltage during beam transients, working in conjunction with the wideband feedback.

**Implementation**: Dedicated VXI GVF module with I/Q reference values and LFB (Longitudinal Feedback) "woofer" interface via fiber optic link.

---

## PART IV: SPEAR3-SPECIFIC CONSIDERATIONS

### 4.1 Single-Station Configuration

Unlike PEP-II (which had up to 10 RF stations), SPEAR3 operates with a **single RF station** driving 4 cavities. This simplifies some aspects (no inter-station coordination) but removes redundancy.

### 4.2 Beam Loading at SPEAR3 vs PEP-II

| Parameter | PEP-II HER | PEP-II LER | SPEAR3 |
|-----------|-----------|-----------|---------|
| Beam Current | up to 1.8 A | up to 3.0 A | 500 mA |
| Cavities per station | 4 | 2 | 4 |
| Beam loading severity | Extreme | Extreme | Moderate |
| Direct loop required? | Absolutely | Absolutely | Yes (for stability) |
| Coupled-bunch concern | Critical | Critical | Moderate |

SPEAR3 operates at ~500 mA, which is moderate beam loading compared to PEP-II's multi-ampere operation. However, the single-station configuration means there is no backup — reliability is paramount.

### 4.3 Known Limitations and Operational Challenges

From operational experience (Fox et al. 2010, Corredoura 2000):

1. **Klystron gain variation**: As cathode voltage changes with power demand, klystron gain varies by up to 7 dB (LER). The baseband modulator must compensate, but this reduces dynamic range for transient handling.

2. **Probe signal loss**: Intermittent loss of cavity probe RF signal causes direct loop saturation and potential klystron overdrive. Drive power limiting circuits were added post-commissioning.

3. **HVPS ripple**: The SCR-based HVPS produces switching ripple that modulates klystron output. The ripple loop cancels this, but instability risk increases at high currents.

4. **Ion clearing gap transients**: The gap in the fill pattern creates periodic cavity voltage transients. The tuner loop must be set to optimize the steady-state detuning to minimize these transients, which differ between HER and LER configurations.

5. **Fast turn-on**: After a beam abort at high current, all stations trip on reflected power. Fast turn-on sequences (< 20 seconds) were developed but required careful management of baseband voltage limiting to prevent multiplier overdrive.

---

## PART V: KEY REFERENCES

### Primary Sources (PEP-II LLRF Design)

1. **Corredoura, P.L.**, "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8498, PAC 1999. DOI: 10.2172/10204
   — *Definitive system description. Block diagrams, VXI module list, feedback loop architecture.*

2. **Corredoura, P. et al.**, "Experience with the PEP-II RF System at High Beam Currents," SLAC-PUB-8498, EPAC 2000. arXiv: physics/0007029
   — *Operational experience, klystron gain tracking, drive power limiting, ripple loop design.*

3. **Fox, J. et al.**, "Lessons learned from PEP-II LLRF and longitudinal feedback," Phys. Rev. ST Accel. Beams 13, 052802 (2010).
   — *Comprehensive operational review, growth rate measurements, DSP filter design, system evolution.*

4. **Rivetta, C. et al.**, "Modeling and simulation of longitudinal dynamics for LER-HER at PEP-II," Phys. Rev. ST Accel. Beams 10, 022801 (2007).
   — *Time-domain simulation model, nonlinear elements, stability analysis, loop gain optimization.*

5. **Allison, S., Claus, R.**, "Operator Interface for the PEP-II Low Level RF Control System," PAC 1997.
   — *EPICS interface design, operator displays, automated sequences.*

### SPEAR3 RF System

6. **McIntosh, P.**, "An Automated 476 MHz RF Cavity Processing Facility at SLAC," SLAC-PUB-10083, PAC 2003. DOI: 10.2172/815601
   — *Cavity conditioning, processing parameters, SPEAR3 cavity preparation.*

7. **McIntosh, P.**, "The SPEAR3 RF System," SLAC-PUB-11017, January 2005. DOI: 10.2172/839730
   — *SPEAR3 RF system configuration, installation, commissioning.*

8. **Park, S., Corbett, J.**, "Booster Synchrotron RF System Upgrade for SPEAR3," IPAC 2010.
   — *Booster upgrade to 476 MHz, PEP-II equipment reuse.*

### PEP-II RF System Design

9. **Schwarz, H., Rimmer, R.**, "RF system design for the PEP-II B Factory," PAC 1994. OSTI: 10194040
   — *Original RF system design parameters, klystron and cavity specifications.*

10. **Pedersen, F.**, "RF Cavity Feedback," SLAC-400, November 1992.
    — *Foundational theory for RF feedback in heavy beam loading, Robinson instability.*

---

*For detailed feedback loop analysis, see `01_FEEDBACK_LOOP_ARCHITECTURE.md`.*
*For VXI module hardware details, see `02_VXI_HARDWARE_MODULE_REFERENCE.md`.*
*For complete PDF catalog, see `03_LEGACY_PDF_CATALOG.md`.*
*For literature synthesis, see `04_LITERATURE_SYNTHESIS.md`.*
*For cross-reference matrix, see `05_CROSS_REFERENCE_INDEX.md`.*
