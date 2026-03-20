# SPEAR3 Low-Level RF Control System — Technical Design Report

**Document Number**: SPEAR3-LLRF-TDR-001  
**Revision**: 1.0  
**Date**: 2026-03-19  
**Classification**: Engineering Technical Design Report  
**Prepared by**: Faya Wang  
**Scope**: Complete technical reference for the existing SPEAR3 LLRF system, serving as the primary reference for the ongoing LLRF upgrade and modernization  

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Historical Context and System Heritage](#2-historical-context-and-system-heritage)
3. [System Operating Parameters](#3-system-operating-parameters)
4. [RF Cavity Physics and Beam Loading Theory](#4-rf-cavity-physics-and-beam-loading-theory)
5. [System Architecture](#5-system-architecture)
6. [Multi-Loop Feedback Architecture](#6-multi-loop-feedback-architecture)
7. [Direct (Wideband) RF Feedback Loop](#7-direct-wideband-rf-feedback-loop)
8. [Ripple Feedback Loop](#8-ripple-feedback-loop)
9. [HVPS Voltage Regulation Loop](#9-hvps-voltage-regulation-loop)
10. [DAC Control Loop](#10-dac-control-loop)
11. [Tuner Control Loop](#11-tuner-control-loop)
12. [PEP-II Heritage Loops (Not Active in SPEAR3)](#12-pep-ii-heritage-loops-not-active-in-spear3)
13. [VXI Hardware Modules](#13-vxi-hardware-modules)
14. [DSP Firmware and Real-Time Signal Processing](#14-dsp-firmware-and-real-time-signal-processing)
15. [EPICS Control Software Architecture](#15-epics-control-software-architecture)
16. [SNL State Machine Programs](#16-snl-state-machine-programs)
17. [Signal Processing and Physics Algorithms](#17-signal-processing-and-physics-algorithms)
18. [HVPS and Power Conversion System](#18-hvps-and-power-conversion-system)
19. [Machine Protection and Interlock Architecture](#19-machine-protection-and-interlock-architecture)
20. [Operational Procedures and Modes](#20-operational-procedures-and-modes)
21. [Known Limitations and Failure Modes](#21-known-limitations-and-failure-modes)
22. [Upgrade Architecture Summary](#22-upgrade-architecture-summary)
23. [References](#23-references)

---

## 1. Executive Summary

The SPEAR3 (Stanford Positron Electron Asymmetric Ring, 3rd generation) Low-Level RF (LLRF) system is a heritage PEP-II B-Factory design operating at 476.315 MHz, controlling a single RF station that drives four single-cell copper cavities from one 1.2 MW klystron. The system was originally designed at SLAC by Corredoura, Allison, Sass, Tighe, and Claus (1996–1997) for the PEP-II asymmetric electron-positron collider, and was adopted for SPEAR3 in 2003 when the storage ring was upgraded from 358.54 MHz to 476.315 MHz.

The LLRF system implements a multi-rate hierarchical feedback architecture with seven distinct control loops spanning bandwidths from ~800 kHz (analog direct feedback) down to ~0.1 Hz (DAC loop). Of these seven loops, five are actively used in SPEAR3 (Direct, Ripple, HVPS, DAC, and Tuner), while two are PEP-II heritage elements that were never deployed at SPEAR3 (Comb, Gap Voltage Feed-Forward).

The legacy system is built on a VXI instrumentation bus platform with custom SLAC-designed modules, controlled by an EPICS IOC running VxWorks on a Motorola PPC604 processor. The control software comprises 253 functional source files totaling over 82,000 lines of code, including 6 SNL (State Notation Language) real-time sequencer programs, AT&T DSP1610/TI TMS320C16xx DSP firmware in assembly, 7 custom EPICS record types, and 78+ EPICS database files.

This report serves as:
- A primary reference for understanding the complete SPEAR3 legacy LLRF system
- A foundational document supporting the ongoing upgrade to a Dimtel LLRF9/476 FPGA-based system
- A mathematical treatment of the RF cavity physics, beam loading compensation, and feedback control strategies

**Key parameters at a glance**:

| Parameter | Value |
|-----------|-------|
| RF frequency | 476.315 MHz |
| Beam energy | 3.0 GeV |
| Design beam current | 500 mA |
| Number of cavities | 4 (PEP-II type, single-cell, copper) |
| Gap voltage per cavity | 712 kV (operating), 800 kV (design) |
| Klystron power | 1.2 MW maximum (HVPS: 2.5 MW max, 90 kV, 27 A) |
| Direct loop impedance reduction | ~40 dB (~100×) |
| Direct loop bandwidth | ~800 kHz (legacy), improvable with LLRF9 |
| Loop delay | ~1 μs (legacy VXI), 270 ns (LLRF9 upgrade) |

---

## 2. Historical Context and System Heritage

### 2.1 PEP-II B-Factory Origin

The PEP-II B-Factory at SLAC was an asymmetric electron-positron collider operating from 1999 to 2008. Its RF system operated at 476 MHz and was designed to handle extreme beam loading conditions:

- **High Energy Ring (HER)**: 9 GeV, up to 1.8 A stored current, 5 nominal RF stations (4 cavities/station), later expanded to 7 stations during high-luminosity upgrades.
- **Low Energy Ring (LER)**: 3.1 GeV, up to 3.0 A stored current, 2 nominal RF stations (2 cavities/station), later expanded to 3 stations.

The LLRF system was the critical subsystem enabling stable operation under these heavy beam loading conditions, where beam-induced voltages could exceed generator-supplied voltages by substantial margins.

**Key design reference**: Corredoura, P.L., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8498, April 1999.

### 2.2 SPEAR3 Adoption (2003)

In 2003, SPEAR was upgraded to SPEAR3, a 3rd-generation synchrotron light source at SSRL/SLAC. The RF system upgrade replaced the original 358.54 MHz, 5-cell aluminum cavity system with a PEP-II HER RF station:

| Parameter | SPEAR2 (Original) | SPEAR3 (PEP-II Heritage) |
|-----------|-------------------|--------------------------|
| RF Frequency | 358.54 MHz | 476.315 MHz |
| Harmonic Number | 280 | 372 |
| Cavities | 1 × 5-cell aluminum | 4 × single-cell copper (PEP-II type) |
| Klystron | PEP-I type, ~200 kW | 1.2 MW (PEP-II type) |
| Gap Voltage | 1.6 MV total | 3.2 MV total (800 kV/cavity design) |
| Beam Current | 100 mA | 500 mA (design) |
| LLRF Control | Analog + EPICS | PEP-II VXI LLRF + EPICS |

SPEAR3 is a **single-station** implementation of the PEP-II LLRF design, driving 4 cavities from one klystron. The control software (SNL/EPICS sequences) was adapted from PEP-II with station-specific macro substitutions (`STN=SRF1`).

**Key reference**: McIntosh, P. et al, "The SPEAR3 RF System," EPAC, 2004.

### 2.3 Current Upgrade Context (2022–Present)

As of 2026, the SPEAR3 LLRF system is undergoing a comprehensive upgrade. Key drivers:

- **Hardware obsolescence**: Custom SLAC VXI modules, PLC-5/SLC-500 controllers, and Slo-Syn stepper motor drivers are all end-of-life.
- **PPS compliance**: Legacy design routes Personnel Protection System wiring through the HVPS controller PLC, creating an unacceptable coupling.
- **Performance improvement**: FPGA-based feedback (270 ns loop delay) replaces analog processing (~1 μs delay).
- **Diagnostics**: 16,384-sample waveform capture, circular buffers, and first-fault detection.

**Retained**: Klystron, 4 RF cavities, waveguide distribution, HVPS power section, mechanical tuner assemblies, field cabling.  
**Replaced**: LLRF controller (VXI → Dimtel LLRF9/476 × 2), RF MPS (PLC-5 → ControlLogix 1756), HVPS controller (SLC-500 → CompactLogix), tuner controller (AB 1746-HSTP1 → Galil DMC-4143), control software (SNL/VxWorks → EPICS/Python/MATLAB).  
**New**: Interface Chassis (hardware interlock hub), Waveform Buffer System, Arc Detection System (Microstep-MIS), PPS Interface Box.

---

## 3. System Operating Parameters

### 3.1 SPEAR3 RF System Parameters

| Parameter | Symbol | Value | Notes |
|-----------|--------|-------|-------|
| RF Frequency | $f_\text{RF}$ | 476.3 MHz | Harmonic 372 of revolution frequency |
| Revolution Frequency | $f_\text{rev}$ | 1.2808 MHz | $C = 234.137$ m circumference |
| Beam Energy | $E_0$ | 3.0 GeV | |
| Design Beam Current | $I_b$ | 500 mA | Top-off mode |
| Bunch Spacing | $T_b$ | 2.1 ns | $1/f_\text{RF}$ |
| Fill Pattern | — | 276 bunches in 4 groups + 1 camshaft | |
| Number of Cavities | $N_\text{cav}$ | 4 | Single-cell, HOM-damped copper |
| Cavity Shunt Impedance | $R_s$ | 3.8 MΩ | Per cavity, circuit convention |
| Cavity Unloaded Q | $Q_0$ | 33,500 | |
| Cavity Loaded Q | $Q_L$ | 6,700 | $\beta = Q_0/Q_\text{ext} = 4.0$ |
| Cavity Half-Bandwidth | $f_{1/2}$ | 35.5 kHz | $f_0/(2Q_L)$ |
| Gap Voltage per Cavity | $V_\text{gap}$ | 712 kV (operating) | 800 kV design |
| Total Accelerating Voltage | $V_\text{total}$ | 2.85 MV (operating) | 3.2 MV design; note: 4 × 712 kV = 2.85 MV |
| Klystron Maximum Power | $P_\text{kly}$ | 1.2 MW | |
| Klystron Operating Voltage | $V_\text{HVPS}$ | 74.4 kV (nominal) | Up to 90 kV maximum |
| IF Frequency (legacy) | $f_\text{IF}$ | 4.9 MHz | $f_\text{RF} - f_\text{LO}$ |
| LO Frequency (legacy) | $f_\text{LO}$ | 471.1 MHz | |
| Synchrotron Frequency | $f_s$ | ~8.8 kHz | At operating conditions |
| Momentum Compaction | $\alpha_c$ | $1.18 \times 10^{-3}$ | |

### 3.2 PEP-II Reference Parameters (Schwarz, 1998)

These parameters from the original PEP-II design document PS-340-330-51-R0 provide essential context for the SPEAR3 adaptation:

| Parameter | Symbol | HER | LER | SPEAR3 |
|-----------|--------|-----|-----|--------|
| Frequency | $f_0$ | 476 MHz | 476 MHz | 476.3 MHz |
| Cavities per Station | $m$ | 4 | 2 | 4 |
| Shunt Impedance | $R_s$ | 3.73 MΩ | 3.73 MΩ | 3.8 MΩ |
| Gap Voltage/Cavity | $V_c$ | 700 kV | 850 kV | 712 kV |
| Cavity Wall Power | $P_c$ | 65.7 kW | 96.8 kW | ~66.7 kW |
| Loaded Q | $Q_L$ | 6,780 | 6,780 | 6,700 |
| Coupling Factor | $\beta$ | 3.84 | 5.22 | 4.0 |
| Synchronous Phase | $\phi_s$ | 75.0° | 76.1° | ~8.4° |
| Detuning Angle | $\psi$ | −66.0° | −74.5° | ~−21° |
| Synchrotron Frequency | $f_s$ | 6.10 kHz | 3.67 kHz | ~8.8 kHz |

### 3.3 LLRF9/476 Key Specifications (Upgrade)

| Parameter | Value |
|-----------|-------|
| Hardware per unit | 3 × LLRF4.6 boards (Xilinx FPGA + 4 ADC + 2 DAC + 3 RF channels) |
| Direct loop delay | 270 ns |
| RF input range | +2 dBm full-scale, 12-bit ADC |
| Setpoint profiles | 512 points, 70 μs – 37 ms per step |
| Waveform capture | 16,384 samples/channel |
| Scalar readback rate | 10 Hz |
| Interlock timestamp | ±17.4 ns resolution |

**LLRF9 LO Frequency Plan** ($f_\text{RF} = 476.3052$ MHz):

| Signal | Ratio | Frequency |
|--------|-------|-----------|
| RF Reference | $1$ | 476.3052 MHz |
| IF | $1/12$ | 39.6921 MHz |
| Local Oscillator | $11/12$ | 436.6131 MHz |
| ADC Clock | $11/48$ | 109.1533 MHz |
| DAC Clock | $11/24$ | 218.3065 MHz |

---

## 4. RF Cavity Physics and Beam Loading Theory

### 4.1 Cavity Impedance Model

An RF cavity near its fundamental resonance is modeled as a parallel RLC circuit. The cavity transfer function (voltage response to driving current) in the Laplace domain is:

$$H_\text{cav}(s) = \frac{R_s}{Q_L} \cdot \frac{\omega_0}{s^2 + \frac{\omega_0}{Q_L}s + \omega_0^2}$$

Near resonance, using the narrowband approximation ($|\Delta\omega| \ll \omega_0$):

$$Z_\text{cav}(\Delta\omega) = \frac{R_s}{1 + j \cdot 2Q_L \cdot \frac{\Delta\omega}{\omega_0}}$$

where:
- $R_s = 3.8$ MΩ is the shunt impedance (circuit convention) per SPEAR3 cavity
- $Q_0 = 33{,}500$ is the unloaded quality factor
- $Q_L = 6{,}700$ is the loaded quality factor
- $\beta = Q_0/Q_\text{ext} = 4.0$ is the input coupling coefficient
- $\omega_0 = 2\pi \times 476.315$ MHz is the resonant angular frequency

The cavity half-bandwidth is:

$$f_{1/2} = \frac{f_0}{2Q_L} = \frac{476.315 \text{ MHz}}{2 \times 6700} \approx 35.5 \text{ kHz}$$

This bandwidth determines the maximum rate at which cavity fields can change naturally without external feedback.

### 4.2 Beam Loading and Generator Power

When a beam of DC current $I_b$ passes through a cavity, each bunch deposits energy that excites the cavity fundamental mode. In phasor notation, the beam-induced voltage is:

$$\vec{V}_b = I_b \cdot R_s \cdot e^{j\psi}$$

where $\psi = \arctan(2Q_L \cdot \Delta f / f_0)$ is the detuning angle. The total cavity voltage is the superposition of generator-driven and beam-induced components:

$$\vec{V}_\text{cav} = \vec{V}_g + \vec{V}_b$$

The required generator power for a given gap voltage $V_\text{gap}$ and beam current $I_b$ is:

$$P_\text{gen} = \frac{V_\text{gap}^2}{4 R_s / Q_L \cdot Q_L} \cdot \frac{(1+\beta)^2}{\beta} \cdot \left[1 + \left(\frac{2Q_L \Delta f}{f_0}\right)^2\right] + I_b \cdot V_\text{gap} \cdot \cos\phi_s$$

The first term represents cavity wall losses; the second term represents beam acceleration power.

**Optimum detuning** (minimizes reflected power for given $I_b$ and $V_\text{gap}$):

$$\tan\psi_\text{opt} = -\frac{I_b \cdot R_s \cdot \sin\phi_s}{V_\text{gap}}$$

$$\Delta f_\text{opt} = \frac{f_0 \cdot \tan\psi_\text{opt}}{2Q_L}$$

For SPEAR3 at 500 mA ($I_b = 0.5$ A, $R_s = 3.8$ MΩ, $V_\text{gap} = 712$ kV, $\phi_s \approx 8.4°$):

$$\tan\psi_\text{opt} \approx -\frac{0.5 \times 3.8 \times 10^6 \times \sin 8.4°}{712 \times 10^3} \approx -0.390$$

$$\psi_\text{opt} \approx -21.3°, \quad \Delta f_\text{opt} \approx -13.9 \text{ kHz}$$

### 4.3 Robinson Instability

The Robinson instability arises from the asymmetry of the effective cavity impedance at revolution frequency sidebands above and below $f_\text{RF}$. The instability growth/damping rate for a single cavity is:

$$\frac{1}{\tau_\text{Robinson}} = -\frac{I_b \cdot \alpha_c \cdot \omega_\text{rev}}{4 E_0 \cdot \omega_s} \left[\text{Re}\{Z_\text{eff}(\omega_\text{RF} + \omega_s)\} - \text{Re}\{Z_\text{eff}(\omega_\text{RF} - \omega_s)\}\right]$$

where $\alpha_c$ is the momentum compaction factor, $\omega_\text{rev}$ is the angular revolution frequency, $\omega_s$ is the synchrotron angular frequency, and $E_0$ is the beam energy.

**Stability criterion**: For operation above transition energy ($\alpha_c > 0$, which is the case for both PEP-II and SPEAR3), stability requires:

$$\text{Re}\{Z_\text{eff}(\omega_\text{RF} + \omega_s)\} < \text{Re}\{Z_\text{eff}(\omega_\text{RF} - \omega_s)\}$$

This is achieved by tuning the cavity resonance **below** the RF frequency (negative detuning), which is the standard operating condition. However, at high beam currents, the natural asymmetry may not provide sufficient damping, and **active feedback** is required.

### 4.4 Impedance Reduction via Direct Feedback

The direct feedback loop reduces the effective impedance seen by the beam at all frequencies within its bandwidth:

$$Z_\text{eff,fb}(\omega) = \frac{Z_\text{cav}(\omega)}{1 + G_\text{OL}(\omega)}$$

where $G_\text{OL}(\omega)$ is the open-loop gain at frequency $\omega$. For a loop gain of $G \approx 100$ (40 dB), the impedance is reduced from 3.8 MΩ to approximately 38 kΩ per cavity. This reduction:

1. Suppresses Robinson instability growth rates by a factor of ~100
2. Reduces coupled-bunch instability growth rates proportionally
3. Improves cavity field stability against beam current fluctuations

### 4.5 Coupled-Bunch Instabilities

At revolution frequency harmonics ($n \cdot f_\text{rev}$), the cavity fundamental impedance drives coupled-bunch instabilities. The growth rate for coupled-bunch mode $\mu$ is proportional to:

$$\frac{1}{\tau_\mu} \propto I_b \sum_{p=-\infty}^{\infty} \text{Re}\{Z_\text{eff}(\omega_p)\} \cdot \cos\left(\frac{2\pi \mu p}{h}\right)$$

where $\omega_p = (ph + \mu)\omega_\text{rev} + \omega_s$ and $h$ is the harmonic number.

At SPEAR3 ($I_b = 500$ mA, $h = 372$, $f_\text{rev} = 1.2808$ MHz), the coupled-bunch growth rates are **moderate** compared to PEP-II due to the lower beam current. The direct feedback loop alone provides sufficient suppression; no comb filter is required.

### 4.6 Klystron Saturation Model

The klystron is a nonlinear amplifier with characteristics:

$$P_\text{out} = P_\text{sat} \cdot \frac{P_\text{in}/P_\text{in,sat}}{1 + P_\text{in}/P_\text{in,sat}}$$

$$\Delta\phi_\text{kly} = \Delta\phi_\text{AM-PM} \cdot \frac{P_\text{in}}{P_\text{in,sat}}$$

As beam current changes, the required klystron output power shifts along the saturation curve, causing up to **7 dB variation** in small-signal gain. The baseband modulator (gain tracking function) compensates:

$$G_\text{modulator} \times G_\text{klystron} = G_\text{loop} \quad (\text{constant})$$

> **Source**: Corredoura, arXiv:physics/0007029; Fox et al., Phys. Rev. ST Accel. Beams 13, 052802 

### 4.7 HVPS Ripple Spectrum

The HVPS uses a 12-pulse thyristor rectifier (two 6-pulse bridges with ±15° phase-shift transformer, confirmed in HVPS Engineering Technical Note). Dominant ripple harmonics:

$$f_\text{ripple} = 12n \cdot f_\text{line} = 720, 1440, 2160, \ldots \text{ Hz}$$

with amplitude $\propto 1/n$ for an ideal 12-pulse rectifier. Typical ripple voltage is 0.1–0.5% of DC output at the fundamental 720 Hz. This modulates the klystron cathode voltage:

$$\frac{\Delta P_\text{kly}}{P_\text{kly}} \approx 2.5 \times \frac{\Delta V_\text{kly}}{V_\text{kly}}$$

### 4.8 Collector Power Protection

The klystron collector dissipates the difference between DC input power and RF output power:

$$P_\text{collector} = V_\text{HVPS} \cdot I_\text{HVPS} - P_\text{kly,fwd}$$

If RF output drops to zero (e.g., LLRF trip), the full DC power goes to the collector:

$$P_\text{collector,max} = 74.7 \text{ kV} \times 22 \text{ A} = 1.64 \text{ MW}$$

This exceeds the collector's continuous thermal rating, requiring fast HVPS shutdown within ~100 ms.

current operation, what klyston ouput power?

---

## 5. System Architecture

### 5.1 RF Station Physical Layout

The SPEAR3 RF station is located in Building 132 (LLRF/klystron area) and the SPEAR3 tunnel. It consists of:

```
┌──────────────────────────────────────────────────────────────────┐
│                   SPEAR3 RF STATION (SRF1)                       │
│                                                                  │
│  ┌──────────┐      ┌───────────┐     ┌──────────┐    ┌──────────┐│
│  │  HVPS    │─DC──>│  KLYSTRON │─RF>─│CIRCULATOR│──> │ WAVEGUIDE││
│  │ (90 kV)  │      │ (1.2 MW)  │     │          │    │ NETWORK  ││
│  │ B118     │      │ B132      │     │ B132     │    │ → Tunnel ││
│  └──────────┘      └─────┬─────┘     └─────┬────┘    └────┬─────┘│
│                          │                 │              │      │
│                    ┌─────┴───┐    ┌────────┴─┐    ┌───────┴─┐    │
│                    │  Drive  │    │Reflected │    │ 3 Magic │    │
│                    │  Amp    │    │  Load    │    │ Tees    │    │
│                    │ (120 W) │    │          │    │ → 4 Cav │    │
│                    └────┬────┘    └──────────┘    └────┬────┘    │
│                         │                              │         │
│  ┌──────────────────────┴──────────────────────────────┴─────┐   │
│  │              VXI CRATE — LLRF SYSTEM (B132)               │   │
│  │  CPU  CLK  RFP  IQA1  IQA2  IQA3  AIM  (+ AB Scanner)     │   │
│  │  Ethernet ◄──▶ EPICS IOC (VxWorks) ◄──▶ Channel Access   │   │
│  └───────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐   │
│  │  RF CAVITY ARRAY (×4, in SPEAR3 tunnel)                   │   │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐                   │   │
│  │  │Cav A │  │Cav B │  │Cav C │  │Cav D │  ◄── Beam         │   │
│  │  │Probe │  │Probe │  │Probe │  │Probe │                   │   │
│  │  │Tuner │  │Tuner │  │Tuner │  │Tuner │                   │   │
│  │  └──────┘  └──────┘  └──────┘  └──────┘                   │   │
│  └───────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

**Equipment per station**: 1.2 MW klystron, HVPS (2.5 MW max, 90 kV, 27 A max), circulator + matched load, 3 magic-tee splitters, 3 waveguide loads, 4 single-cell 476 MHz cavities (each with movable tuner, ceramic window, HOM loads, 400 l/s ion pump), 6 equipment racks, 1 air-conditioned LLRF blue rack, PLC-5 MPS controller, SLC-500 HVPS controller, EPICS workstation.

**Cooling systems** (3 circuits): LCW Loop 1 (35°C, klystron), LCW Loop 2 (35°C, cavities), HCW Loop (unregulated, waveguide loads).

### 5.2 IQ Baseband Signal Processing Philosophy

All RF signals in the PEP-II/SPEAR3 LLRF system are processed using **In-phase/Quadrature (IQ) baseband decomposition**. Every 476 MHz signal is heterodyned to baseband via a common Local Oscillator:

$$V_\text{RF}(t) = I(t) \cdot \cos(\omega_\text{RF} t) - Q(t) \cdot \sin(\omega_\text{RF} t)$$

$$\text{Amplitude: } A = \sqrt{I^2 + Q^2} \qquad \text{Phase: } \phi = \arctan\left(\frac{Q}{I}\right)$$

This approach provides: vector control of amplitude and phase independently; wideband feedback bandwidth set by analog electronics (~MHz), not limited to narrow bands around the RF carrier; precise digital IQ measurement via IQA modules; and programmable baseband access for DSP and DAC control.

### 5.3 Control Software Stack

```
Layer 6: SNL State Machines (6 programs)
         rf_states, rf_calib, rf_tuner_loop, rf_hvps_loop,
         rf_dac_loop, rf_msgs
Layer 5: EPICS Database & Subroutines (subIQ.c, subSys.c)
Layer 4: Custom Record Types (RFP, IQA, AIM, CLK active)
Layer 3: Device Support (devP2RfRfp, devP2RfIqa, devP2RfAim, devP2RfClk)
Layer 2: Core VXI Driver (drvP2RfVxi.c) + AB PLC Driver (drvAb.c)
Layer 1: VXI Infrastructure (drvEpvxi.c) + KSC V152 + VxWorks RTOS
Layer 0: Hardware (VXI chassis, klystron, cavities, AB PLCs, stepper motors)
```

Total codebase: 253 functional source files, 82,430+ lines.

### 5.4 Communication Architecture

The legacy system uses a daisy-chained Allen-Bradley serial communication architecture:

```
VXI Crate (B132)        MPS Rack (B132)           HVPS Controller (B118)
┌──────────────┐        ┌──────────────┐           ┌──────────────┐
│ AB VME       │─serial─│ PLC-5 Main   │─serial──▶│ SLC-500 HVPS │
│ Scanner      │        │ (1771 DCM)   │           └──────────────┘
│ (VXI Slot 1) │        └──────────────┘
└──────────────┘                │
                          ┌─────┴──────┐
                          │ SLC-500    │
                          │ Tuner Ctrl │
                          │ (1747-DCM) │
                          └────────────┘
```

**Key vulnerability**: A single serial cable daisy-chains from the VXI AB scanner through the PLC-5 DCM, SLC-500 tuner controller, and a long-haul telephone wire to the HVPS PLC in B118. Failure of any DCM module isolates all downstream controllers.

---

## 6. Multi-Loop Feedback Architecture

### 6.1 Loop Hierarchy

The LLRF system implements a multi-rate hierarchical feedback architecture. Bandwidth separation of at least one decade between adjacent loops prevents inter-loop coupling:

| # | Loop Name | Bandwidth | Implementation | SPEAR3 Status |
|---|-----------|-----------|----------------|---------------|
| 1 | Direct (Wideband) RF Feedback | ~800 kHz | Analog: RFP module | **Active** |
| 2 | Comb (Narrowband) RF Feedback | ~2 MHz span, ~10 kHz/tooth | Digital: VXI Comb Filter | **PEP-II only** |
| 3 | Ripple Feedback | Up to ~50 kHz (design) | DSP: AT&T DSP1610 | **Active** (as slow phase tracker) |
| 4 | HVPS Voltage Regulation | ~0.5–1 Hz | Software: SNL (`rf_hvps_loop.st`) | **Active** |
| 5 | DAC Control | ~0.1 Hz | Software: SNL (`rf_dac_loop.st`) | **Active** |
| 6 | Tuner Control | ~1 Hz | Software: SNL (`rf_tuner_loop.st`) | **Active** |
| 7 | Gap Voltage Feed-Forward | N/A (feed-forward) | VXI GVF module | **PEP-II only** |

**Critical stability requirement**:

$$f_\text{BW,direct} \gg f_\text{BW,ripple} \gg f_\text{BW,HVPS} \sim f_\text{BW,tuner} \gg f_\text{BW,DAC}$$

$$800\text{ kHz} \gg 300\text{ Hz (deployed)} \gg 1\text{ Hz} \sim 1\text{ Hz} \gg 0.1\text{ Hz}$$

> **Note**: The ripple loop design bandwidth extends to ~50 kHz (DSP capability), but at SPEAR3 it operates as a slow phase tracker with ~300 Hz effective bandwidth. The bandwidth hierarchy above reflects the deployed configuration.

### 6.2 Signal Flow Overview

```
Station Reference (476 MHz)  ──▶  IQ Demod  ──▶  I_ref, Q_ref
                                                      │
Cavity Probes (×4, 476 MHz) ──▶  Vector Sum ──▶  I_cav, Q_cav
         IQ Demod                                     │
                                                      ▼
                               ┌───────────────────────────────┐
                               │   DIRECT LOOP (ANALOG)        │
                               │   Error = Ref − Cav           │
                               │   Gain + Phase Compensation   │
                               │   Lead + Integral Compensation│
                               └──────────────┬────────────────┘
                                              │
                               ┌──────────────┴────────────────┐
                               │   BASEBAND MODULATOR          │
                               │   2×2 Matrix (Gilbert-cell)   │
                               │   Gain Tracking               │
                               └──────────────┬────────────────┘
                                              │
                               ┌──────────────┴────────────────┐
                               │   IQ RF MODULATOR (476 MHz)   │
                               └──────────────┬────────────────┘
                                              │
                               ┌──────────────┴────────────────┐
                               │   DRIVE AMPLIFIER (120 W)     │
                               └──────────────┬────────────────┘
                                              │
                                              ▼
                                        KLYSTRON (1.2 MW)
                                              │
                              ┌───────────────┼───────────────┐
                              ▼               ▼               ▼
                         Cavity A        Cavity B ... Cavity D
```

### 6.3 Behavioral Modes — Direct Loop ON vs. OFF

The control hierarchy changes fundamentally depending on whether the direct loop is active:

| Feature | Direct Loop ON (ON_CW with beam) | Direct Loop OFF (TUNE, ON_FM) |
|---------|:---:|:---:|
| Cavity impedance control | Direct + Lead/Integral compensation | None |
| Gap voltage regulation | DAC Loop → DAC reference setpoint | HVPS Loop → HVPS voltage |
| Drive power regulation | HVPS Loop → klystron voltage | DAC Loop → DAC level |
| Primary control variable | DAC Loop commands gap voltage | HVPS Loop commands gap voltage |

This mode reversal between the DAC and HVPS loops is a key architectural feature: each loop serves a different primary function depending on the operating state.

---

## 7. Direct (Wideband) RF Feedback Loop

### 7.1 Purpose

The direct loop is the **primary impedance reduction loop**. It reduces the effective cavity impedance seen by the beam by a factor of ~100 (40 dB), providing the fundamental stability against Robinson instability and coupled-bunch mode growth.

### 7.2 Open-Loop Transfer Function

$$G_\text{OL}(s) = G_0 \cdot H_\text{cav}(s) \cdot H_\text{kly}(s) \cdot e^{-\tau_d s}$$

where:
- $G_0$ = adjustable loop gain (PV: `SRF1:STNDIRECT:LOOP:COUNTS.A`)
- $H_\text{cav}(s)$ = cavity transfer function (narrowband, $\sim 35.5$ kHz bandwidth)
- $H_\text{kly}(s)$ = klystron transfer function (wideband, with AM/PM conversion)
- $\tau_d$ = total loop delay ($\sim 1\;\mu\text{s}$ legacy, 270 ns LLRF9)

### 7.3 Closed-Loop Response and Effective Impedance

$$T(s) = \frac{G_\text{OL}(s)}{1 + G_\text{OL}(s)} \qquad Z_\text{eff}(s) = \frac{Z_\text{cav}(s)}{1 + G_\text{OL}(s)}$$

For $G_0 \approx 100$ at the cavity resonance, $Z_\text{eff} \approx 38$ kΩ per cavity (down from 3.8 MΩ).

### 7.4 Maximum Stable Gain and Bandwidth

The loop delay contributes $-\omega \cdot \tau_d$ radians of phase shift. At the unity-gain crossover frequency $\omega_c$:

$$\omega_c \cdot \tau_d < \pi - \text{PM} - \angle H_\text{cav}(\omega_c) - \angle H_\text{kly}(\omega_c)$$

For 45° phase margin:

$$f_{c,\text{max}} \approx \frac{1}{4\tau_d}$$

| System | Loop Delay $\tau_d$ | Max Crossover $f_{c,\text{max}}$ |
|--------|---|---|
| Legacy VXI | ~1 μs | ~250 kHz |
| LLRF9 | 270 ns | ~926 kHz |

The LLRF9's 3.7× reduction in loop delay enables a corresponding increase in achievable bandwidth and gain.

### 7.5 Implementation (Analog Baseband)

The direct loop operates entirely at IQ baseband:

1. **Error computation**: $\epsilon_I = I_\text{ref} - I_\text{cav}$, $\epsilon_Q = Q_\text{ref} - Q_\text{cav}$
2. **Gain application**: Each error component multiplied by the loop gain
3. **Phase rotation**: A 2×2 matrix rotates the IQ error vector to compensate for the total loop phase delay
4. **Compensation**: Lead compensation ($H_\text{lead}(s) = \frac{1 + s\tau_\text{lead}}{1 + s\tau_\text{lead}/\alpha}$, $\alpha > 1$) adds phase margin; integral compensation ($H_\text{int}(s) = 1 + \frac{1}{s\tau_\text{int}}$) provides zero steady-state error.
5. **Baseband modulator**: Four Gilbert-cell analog multipliers (rated ±1V max) in a 2×2 matrix configuration apply gain and phase rotation, compensating for klystron gain/phase variations.

### 7.6 Critical Design Considerations

**Polarity inversion hazard**: The Gilbert-cell multipliers invert output polarity when overdriven beyond ±1V, converting negative feedback to positive feedback and causing catastrophic instability. A **soft limiter** (back-to-back 1N4157 Schottky diodes across 50 kΩ feedback resistor with 100 Ω series resistor) was added post-commissioning to prevent this.

**Phase alignment**: The feedback loop phase must be set precisely (PV: `SRF1:STNDIRECT:LOOP:PHASE.C`). Incorrect phase causes positive feedback; the alignment must be verified after any klystron replacement.

**Gain tracking**: As klystron cathode voltage varies, its gain changes by up to 7 dB. The baseband modulator matrix coefficients (quad DAC on RFP) are adjusted to maintain constant overall loop gain.

### 7.7 Sub-Functions

The direct loop contains three configurable sub-functions:

1. **Integral Compensation**: Smooths HVPS ripple and eliminates steady-state error. Turned OFF in the OFF station state.
2. **Lead Compensation**: Increases bandwidth and gain, providing additional phase margin at the crossover frequency.
3. **Frequency Offset Tracking**: Compensates for phase rotation caused by cavity detuning during heavy beam loading. Primarily a diagnostic tool — **should not normally be activated** during routine operation.

---

## 8. Ripple Feedback Loop

### 8.1 Purpose

The ripple loop was designed to cancel RF amplitude/phase modulation from the HVPS switching ripple (fundamental at 720 Hz for the 12-pulse rectifier, harmonics to ~50 kHz).

### 8.2 Design vs. Operational Deployment

The original PEP-II design specification (PS-340-330-52-R0) states:

> *"The Ripple Loop is intended to remove amplitude and phase ripple in the klystron output power but at the time it is only utilized to keep the low bandwidth phase across the klystron and drive amplifier constant as the klystron voltage is varied."*

In practice at SPEAR3, the ripple loop serves primarily as a **slow phase tracker** compensating for klystron phase shift at different cathode voltage operating points, rather than performing active wideband ripple cancellation.

### 8.3 DSP Implementation

The ripple loop DSP runs on an **AT&T DSP1610** processor (also designated TI TMS320C16xx after TI's acquisition of the AT&T DSP product line) at ~23 kHz loop rate. The algorithm performs:

1. Read I/Q signals from ADC channels (reference and klystron)
2. Compute phase and amplitude: $\phi = \arctan(Q/I)$, $A = \sqrt{I^2 + Q^2}$
3. Compute errors: $\epsilon_\phi = \phi_\text{ref} - \phi_\text{kly}$, $\epsilon_A = A_\text{ref} - A_\text{kly}$
4. Harmonic estimation (dual-rate):
   - 6 "fast" harmonics processed every cycle at 23 kHz
   - 8 "slow" harmonics processed round-robin (~3 kHz effective)
5. Accumulate corrections and apply to DAC outputs

Fixed-point arithmetic: q13 format for phase (±π), q11 for accumulators, q15 for gain coefficients.

### 8.4 Instability Risk

From Corredoura (2000): *"An analog integrator in the direct RF feedback loop cancels the ripple but simulations show it will cause instability as beam currents reach 2A."* This was a primary concern for PEP-II but is benign for SPEAR3's 500 mA operation.

### 8.5 Upgrade Fate

The LLRF9's 270 ns loop delay and ~1 MHz digital processing bandwidth provide inherent rejection of 720 Hz ripple without a dedicated loop. The ripple loop is **eliminated** in the upgrade architecture.

---

## 9. HVPS Voltage Regulation Loop

### 9.1 Purpose

The HVPS loop regulates klystron cathode voltage to maintain either:
- **Processing mode**: Gradually ramps voltage while conditioning cavities (monitoring vacuum, reflected power, and forward power)
- **Operating mode**: Adjusts voltage to maintain constant drive power (TUNE state) or gap voltage (ON_CW with direct loop)

### 9.2 State Machine

The HVPS loop implements 4 SNL states: `init`, `off`, `proc`, and `on`.

**Processing mode** (`proc` state) — each cycle (~0.5 s):

$$\text{if } (P_\text{fwd} > P_\text{fwd,max}) \;\text{OR}\; (\text{SEVR}(V_\text{gap}) = \text{MAJOR}) \;\text{OR}\; (\text{SEVR}(p_\text{vac}) = \text{MAJOR})$$
$$\quad \Rightarrow \Delta V_\text{HVPS} = \Delta V_\text{down}$$
$$\text{else}$$
$$\quad \Rightarrow \Delta V_\text{HVPS} = \Delta V_\text{up}$$

This triple-condition protection check ensures safe conditioning: forward power overload, gap voltage limits, or vacuum excursion each independently command voltage reduction.

**Operating mode** (`on` state) — two sub-modes depending on station state:
- ON_CW with direct loop: Drive power regulation via $\Delta V = -\delta_\text{on}$ (adjusts to maintain drive power at setpoint)
- TUNE without direct loop: Gap voltage regulation via $\Delta V = \delta_\text{tune}$ (adjusts to maintain gap voltage at setpoint)

### 9.3 Status Codes

16 distinct status codes (0–15) are defined in `rf_hvps_loop_defs.h`, covering: UNKNOWN, GOOD, RFP_BAD, CAVV_LIM, OFF, VACM_BAD, POWR_BAD, GAPV_BAD, GAPV_TOL, VOLT_LIM, STN_OFF, VOLT_TOL, VOLT_BAD, DRIV_BAD, ON_FM, and DRIV_TOL.

### 9.4 Key PVs

| PV | Description |
|----|-------------|
| `SRF1:HVPS:VOLT:CTRL` | Voltage setpoint to PLC |
| `SRF1:HVPS:VOLT` | Voltage readback from PLC |
| `SRF1:HVPS:LOOP:CTRL` | Loop control (OFF=0, PROC=1, ON=2) |
| `SRF1:KLYSOUTFRWD:POWER` | Klystron forward power |
| `SRF1:KLYSOUTFRWD:POWER:MAX` | Max forward power limit |

---

## 10. DAC Control Loop

### 10.1 Purpose

The DAC loop is the **outer supervisory loop** that adjusts IQ reference setpoints (via Octal DACs on the RFP module) to maintain desired drive power or gap voltage. It is the bridge between the ~1 Hz EPICS supervisory layer and the ~800 kHz analog direct feedback.

### 10.2 Operating Modes

| Station State | Direct Loop | DAC Adjusts | Target |
|---------------|-------------|-------------|--------|
| OFF/PARK/ON_FM | — | Nothing | — |
| TUNE | OFF | RFP tune-mode DACs | Drive power |
| ON_CW | ON | RFP difference node DACs | Gap voltage |

### 10.3 Control Algorithm

From `rf_dac_loop_macs.h`, the DAC_LOOP_SET macro implements a proportional controller:

$$\Delta_\text{counts} = G_\text{DAC} \cdot (V_\text{desired} - V_\text{actual}) \cdot K_\text{conv} \cdot (1 + G_\text{loop})$$

where:
- $G_\text{DAC}$ = loop gain (0 to 1)
- $V_\text{desired} - V_\text{actual}$ = gap voltage or drive power error
- $K_\text{conv}$ = counts-to-physical conversion factor
- $G_\text{loop}$ = additional loop gain term

The output is:
- Clamped to ±2047 counts (12-bit DAC range)
- Subject to a minimum delta threshold of 0.5 counts (prevents hunting)
- Updated no less frequently than every 10 seconds (even without trigger events)

### 10.4 Upgrade Fate (This is not true. we still need it  to regular driver power to klystron at close to staturation!)

The DAC loop is **eliminated** in the LLRF9 architecture. The LLRF9 controls the modulator internally via a single vector sum output — there is no external DAC setpoint management.

---

## 11. Tuner Control Loop

### 11.1 Purpose

The tuner loop adjusts each cavity's resonant frequency via a mechanical plunger driven by a stepper motor. The optimal detuning depends on beam current:

$$\Delta f_\text{opt} = -\frac{f_\text{RF}}{2Q_L} \cdot \frac{I_b \cdot R_s \cdot \sin\phi_s}{V_\text{gap}}$$

At zero beam current, the cavity should be at resonance ($\Delta f = 0$). As current increases, the tuner moves to compensate reactive beam loading.

### 11.2 Implementation

The SNL program `rf_tuner_loop.st` (555 lines) runs as 4 concurrent instances (one per cavity). It contains 5 SNL states: `loop_init`, `loop_unknown`, `loop_reset`, `loop_off`, and `loop_on`. Within `loop_on`, three algorithmic control modes (TRACKING, MOVING, SETTLING) are implemented via conditional branching.

**Control algorithm**:

1. Read frequency error from load angle measurement: $\epsilon_f = \phi_\text{fwd} - \phi_\text{cav}$
2. Compute required motion: $\Delta_\text{pos} = \epsilon_f \times K_\text{tuner}$
3. Enforce limits: $\text{pos}_\text{min} \leq \text{pos}_\text{new} \leq \text{pos}_\text{max}$
4. Command stepper motor and wait for done-moving flag
5. After settling period, verify position within readback deadband

### 11.3 Mechanical Parameters

| Parameter | Value |
|-----------|-------|
| Motor | Superior Electric M093-FC11 (200 steps/rev) |
| Microstepping | 2 microsteps/step → 400 microsteps/rev |
| Gear ratio | 1:2 (motor:lead screw via timing belt) |
| Lead screw | ½-10 Acme (10 TPI) → 2.54 mm/rev |
| Distance per microstep | 3.175 μm |
| Readback deadband | 5 microsteps ≈ 16 μm |
| Normal operating motion | ~0.2 mm |
| Total travel (home to ON) | ~2.5 mm |

### 11.4 Load Angle Offset (Cavity Balancing)

The load angle offset function balances gap voltage across 4 cavities by adjusting individual tuner detuning:

$$\text{error}_i = \frac{V_{\text{gap},i}}{V_{\text{gap,total}}} - \text{target}_i$$

$$\Delta\psi_i = K_\text{LA} \cdot \text{error}_i$$

### 11.5 Upgrade

The legacy Slo-Syn stepper system has been replaced by a **Galil DMC-4143** motion controller (commissioned August 2025). As deployed, it operates at 16 microsteps/step (3,200 microsteps/rev → 0.397 μm/microstep), an 8× improvement in positioning resolution over the legacy 2 microsteps/step. The Galil hardware supports up to 256 microsteps/step (51,200 microsteps/rev → 0.05 μm), enabling further refinement if needed.

> **Source note**: The legacy architecture technical notes contain a discrepancy: Doc 01 (§6.4) states "256 microsteps/step, 16× improvement" while Doc 02 (§7B.1) states "16 microsteps/step" as the actual deployed configuration. The deployed value of 16 microsteps/step from the hardware reference document is used here.

---

## 12. PEP-II Heritage Loops (Not Active in SPEAR3)

### 12.1 Comb (Narrowband) RF Feedback Loop

The comb filter provides narrowband gain at revolution harmonic frequencies for coupled-bunch mode suppression. Its z-domain transfer function:

$$H_\text{comb}(z) = \frac{a \cdot z^{-N}}{1 - b \cdot z^{-N}}$$

where $N$ = samples per revolution period, $a$ = feed-forward gain, $b$ = feedback coefficient ($|b| < 1$ for stability). Gain peaks occur at $f = n \cdot f_\text{rev}$ ($n = 0, 1, 2, \ldots$) with peak gain $a/(1-b)$ and per-tooth bandwidth $\approx (1-b) \cdot f_\text{rev} / \pi$.

**Not used in SPEAR3**: The direct feedback loop alone provides sufficient coupled-bunch suppression at SPEAR3's moderate beam loading (500 mA vs. PEP-II's 1.8–3.0 A). The Comb Filter Modules were physically present in the inherited VXI crate but never populated or connected.

### 12.2 Gap Voltage Feed-Forward (GVF)

The GVF module provided IQ reference values for gap voltage setpoint and an interface to the PEP-II Longitudinal Feedback (LFB) system via fiber optic TAXI link. Since SPEAR3 has no LFB system, the GVF hardware was never installed (slot 3 was empty). Gap voltage control was handled entirely by the software DAC loop.

**Software dependency**: Although the GVF hardware was absent, the GVF database records (`gvf.db`) were loaded and actively consumed by the TAXI monitoring state set in `rf_msgs.st` for error recovery. Removal of these database records would break the TAXI error monitoring code path.

---

## 13. VXI Hardware Modules

### 13.1 SPEAR3 VXI Crate Configuration

| Slot | Module | Function | SPEAR3 Status |
|------|--------|----------|---------------|
| 0 | Slot 0 μProcessor (KSC V152) | VXI bus controller, EPICS IOC (VxWorks) | **Active** |
| 1 | CLK/RF Distribution | Master clock, LO generation (471.1 MHz), RF reference distribution | **Active** |
| 2 | RFP (RF Processor) | Central feedback processing module | **Active** |
| 3 | IQA-1 (IQ/AMP Detector) | Forward power IQ measurement | **Active** |
| 4 | IQA-2 (IQ/AMP Detector) | Reflected power IQ measurement | **Active** |
| 5 | IQA-3 (IQ/AMP Detector) | Cavity probe IQ measurement | **Active** |
| 6 | Comb Filter (I) | Digital comb filter for I-channel | **PEP-II only — not used** |
| 7 | Comb Filter (Q) | Digital comb filter for Q-channel | **PEP-II only — not used** |
| 8 | GVF | Gap voltage reference + LFB woofer interface | **PEP-II only — not used** (software records loaded) |
| 9 | ARC/Interlock Detector (AIM) | Arc detection, interlock management, beam abort | **Active** (arc detection non-functional) |
| 10–12 | Spare | Available for expansion | — |

> **Note**: The AB Scanner (Allen-Bradley serial interface) is mounted in a separate VME slot, not in the VXI instrument slots listed above.

### 13.2 RFP (RF Processor) Module

The heart of the LLRF system. Contains:

- **Analog signal processing**: IQ demodulators for cavity probes, vector summing network (sums 4 cavity IQ signals), direct loop error amplifier, lead/integral compensation networks, baseband modulator (4× Gilbert-cell), IQ RF modulator (upconversion to 476 MHz)
- **Digital control**: Octal DACs (12-bit, ±2048 counts) for tune/operate IQ setpoints, modulator matrix coefficients, and ripple loop coefficients. Mode control (TUNE/OPERATE), RF switch, DSP interface, built-in history buffer (circular, freeze-on-fault)

Key control PVs: `SRF1:RFP:RFSWITCH` (RF output), `SRF1:RFP:RUNMODE` (TUNE/OPERATE), `SRF1:RFP:DIRECTLOOP` (direct loop enable), `SRF1:RFP:LEADCOMP`, `SRF1:RFP:INTCOMP`.

### 13.3 IQA (IQ/Amplitude Detector) Modules

Three IQA modules provide precision digital IQ demodulation:

- Custom digital down-converter ASIC/FPGA (Ziomek & Corredoura, PAC 1995)
- Outputs: I, Q, amplitude ($\sqrt{I^2 + Q^2}$), phase ($\arctan(Q/I)$)
- Linear detector output (used for drive power limiting)
- Part of the built-in network analyzer system

### 13.4 AIM (Arc/Interlock Module)

- 12-channel arc detection
- Fast interlock chain
- BATS (Beam Abort Trigger System) interface
- Fault history buffers (13 channels, written to `/dat/FAULT*` files on fault)
- Filament control interface

### 13.5 CLK/RF Distribution Module

Generates the 471.1 MHz Local Oscillator (legacy PEP-II frequency plan), distributes 476 MHz reference, provides sampling clocks to IQA modules, and serves as the master timing reference. PLL configuration via constants macro `ClkConsts(r,a,m,p)`.

---

## 14. DSP Firmware and Real-Time Signal Processing

### 14.1 Overview

The VXI modules use on-board AT&T DSP1610 (later designated TI TMS320C16xx) fixed-point DSPs for signal processing too fast for the ~1 Hz EPICS scan rate. All firmware is assembly language, loaded at boot time via VXI A24 bus. Total: ~16,763 lines across 102 files in 4 subdirectories (rfpDsp, gvfDsp, obsDsp, genDsp).

### 14.2 RFP DSP — Ripple Rejection

The primary DSP function in the active SPEAR3 system. The SPEAR3-specific variant (`sp3ripple.s`, 1,103 lines) adapts the PEP-II algorithm for harmonic number 372.

**Algorithm** (23 kHz loop rate):

1. **ADC Read**: Interleaved reads of I/Q reference and klystron signals (16-bit two's complement)
2. **Phase/Amplitude Computation**: $\phi = \text{atan2}(Q, I)$ (q13 format), $A = \sqrt{I^2 + Q^2}$ (unsigned 16-bit)
3. **Error Computation**: $\epsilon_\phi = \phi_\text{ref} - \phi_\text{kly}$, $\epsilon_A = A_\text{ref} - A_\text{kly}$
4. **Harmonic Estimation**: 6 fast harmonics (every cycle) + 8 slow harmonics (round-robin at ~3 kHz)
5. **Correction Accumulation**: $\text{DAC}_\text{corr} = \sum h_n \cdot g_n$ (q11 format)
6. **DAC Output**: Base + correction written to hardware

**CPU-DSP Communication**: Shared memory protocol via A24 bus with 17-word communication block (blkId, version, checksum, status, 8 status arguments, DSP message, CPU message, and arguments). Commands include NOOP, READY, TEST, ERROR, LOADTBL, SAVEDATA, and various ripple-specific parameter updates.

### 14.3 Upgrade Fate

**All DSP firmware is eliminated.** The LLRF9 FPGA performs all fast signal processing with 270 ns loop delay (vs. ~43 μs DSP cycle time). No algorithmic migration is needed — the LLRF9 implements its own algorithms designed by Dimtel.

---

## 15. EPICS Control Software Architecture

### 15.1 IOC Configuration

The EPICS IOC boots VxWorks on a Motorola PPC604 (KSC V152 slot-0 controller). The boot sequence:

1. Load application binary (`rf.munch`)
2. Set station macros via `putenv()` (`STN=SRF1`, tuner macro sets, etc.)
3. Load EPICS database (`srf1.db` via substitutions, instantiating ~78 `.db` files)
4. `initHookAtBeginning`: Initialize Clock module PLL before VXI resource manager
5. Configure AB scanner (1 link, 3 racks)
6. Configure VXI address space (A24: 1 MB, A32: 256 MB)
7. `iocInit()`: Resource manager scans backplane, initializes all VXI modules (cold/warm start), resolves database links, starts SNL programs
8. `initHookAfterScanInit`: Enable RF module interrupts, fix KSC ISR

### 15.2 PV Naming Convention

All PV names use EPICS macro substitution. The primary macro is `STN=SRF1` (SPEAR RF Station 1).

| Subsystem | PV Pattern | Example |
|-----------|-----------|---------|
| Station Control | `{STN}:STN:STATE:*` | `SRF1:STN:STATE:RBCK` |
| HVPS | `{STN}:HVPS:VOLT:*` | `SRF1:HVPS:VOLT:CTRL` |
| Tuner (per-cavity) | `{STN}:CAV{N}TUNR:*` | `SRF1:CAV1TUNR:POSN:CTRL` |
| DAC Loop | `{STN}:STNDAC:*` | `SRF1:STNDAC:LOOP:STATUS` |
| Direct Loop | `{STN}:STNDIRECT:*` | `SRF1:STNDIRECT:LOOP:PHASE.C` |
| Klystron | `{STN}:KLYSOUTFRWD:*` | `SRF1:KLYSOUTFRWD:POWER` |
| Cavity | `{STN}:CAV{N}:*` | `SRF1:CAV1:GAPV:VOLT` |
| RFP Module | `{STN}:RFP:*` | `SRF1:RFP:DIRECTLOOP` |

**Upgrade implication**: Preserving PV names exactly is critical — operators, archiver, alarm handlers, and higher-level applications all depend on specific PV name strings. The upgrade must either preserve all names or implement a PV alias/gateway mapping.

### 15.3 EPICS Database Architecture

78+ database files organized by function:

- **VXI module records** (7 custom record types: RFP, IQA, AIM, CLK, GVF, CF2, CFM)
- **IQ signal processing** (rf_iqa.db, rf_iqa_module.db, rf_iqa_scale.db)
- **Station control** (rf_stn.db, rf_stn_cav.db)
- **Feedback control** (rf_fbck.db)
- **HVPS** (rf_hvps.db)
- **Klystron/drive** (rf_klys.db)
- **Cavity control** (rf_cav.db)
- **DAC configuration** (rf_rfp_fourdacs.db, rf_rfp_twodacs.db)
- **PLC I/O** (rf_analog.db, rf_digital_*.db, rf_interlock.db)
- **Summary/fanout** (rf_sumy_*.db)

---

## 16. SNL State Machine Programs

### 16.1 Overview

Six SNL (State Notation Language) programs implement the real-time control logic:

| Program | Lines | Instances | Function |
|---------|-------|-----------|----------|
| `rf_states.st` | 2,227 | 1 | Master station state machine |
| `rf_calib.st` | 3,345 | 1 | Automated calibration sequences |
| `rf_tuner_loop.st` | 555 | 4 (per cavity) | Cavity tuner motor control |
| `rf_hvps_loop.st` | 343 | 1 | HVPS supervisory control |
| `rf_dac_loop.st` | 290 | 1 | Drive/gap voltage DAC control |
| `rf_msgs.st` | 352 | 1 | Message logging and TAXI monitoring |

Support files: 12 header/macro files (~1,151 lines).

### 16.2 Master State Machine (`rf_states.st`)

**23 states** across 3 concurrent state sets:

- **`ss rf_states`** (main): s_init → s_go_off → s_off, s_go_park → s_park (PARK), s_go_tune → s_tune (TUNE), s_go_on_fm → s_on_fm (ON_FM), s_go_on_cw → s_on_cw (ON_CW), plus transition states for ramps, fault handling, and state fallbacks.
- **`ss rf_statesLP`** (loop protection): 5 states monitoring loop health concurrently.
- **`ss rf_statesFF`** (fault files): Manages asynchronous fault file capture.

**Primary operating states** (from `rf_station_state.h`):

$$\text{OFF}(0) \rightarrow \text{PARK}(1) \rightarrow \text{TUNE}(2) \rightarrow \text{ON\_FM}(3) \rightarrow \text{ON\_CW}(4)$$

Transitions between primary states always go through intermediate states (e.g., `s_go_park` initializes VXI modules; `s_go_tune` enables drive and engages direct loop; `s_go_on_cw` activates full feedback chain).

**Fault handling**: Any fault in ON_CW triggers a fault file capture sequence (13 channels of signal RAM saved to `/dat/FAULT*` circular buffer) followed by automatic transition to OFF.

### 16.3 Calibration Sequencer (`rf_calib.st`)

The largest SNL program (3,345 lines) containing 28 hand-written states that perform automated calibration:

1. **Octal DAC offset nulling**: Set all DACs to zero, measure residual I/Q via IQA, compute and apply correction offsets.
2. **Cavity modulator calibration**: For each cavity, apply known modulator weights, measure I/Q response, compute 2×2 coupling matrix.
3. **RF switch calibration**: Measure amplitude/phase for each signal path, compute correction factors.

Cavity × measurement iteration is handled by nested `for` loops within states, not by macro-generated states. Utility macros (`CAL_MSG`, `CHECK_ABORT`, `SET_CAV_OFFSETS`) reduce boilerplate within state bodies.

### 16.4 Upgrade Mapping

| Legacy SNL | Upgrade Target | Status |
|-----------|---------------|--------|
| `rf_states.st` | Python/EPICS coordinator | **Rewrite** — 23 states → 6 simplified states |
| `rf_hvps_loop.st` | CompactLogix PLC ladder logic | **Rewrite** — spec extraction for PLC |
| `rf_tuner_loop.st` | LLRF9 built-in + Python load-angle | **Configure + rewrite** |
| `rf_calib.st` | LLRF9 built-in calibration | **Verify equivalence** |
| `rf_msgs.st` | EPICS logging + LLRF9 diagnostics | **Reference** |
| `rf_dac_loop.st` | **Eliminated** — LLRF9 internal | Per PDR §15.7 |

---

## 17. Signal Processing and Physics Algorithms

### 17.1 subIQ.c — IQ Signal Processing Library

23 pure-math functions with no hardware dependencies. Key algorithms:

**Phase from IQ**:
$$\phi = \arctan\left(\frac{Q}{I}\right) \times \frac{180°}{\pi}$$

**Power from IQ** (state-dependent exponential smoothing):
$$A_\text{raw} = \sqrt{I^2 + Q^2} \cdot K_\text{IQ}$$
$$A_\text{smooth}(n) = A_\text{raw} \cdot (1 - J) + A_\text{smooth}(n-1) \cdot J$$
$$P = \left(\frac{A_\text{smooth}}{E}\right)^2 \quad (\text{if power mode})$$

**Coupling factor** (VSWR-based):
$$r = \frac{A_\text{reflected}}{A_\text{forward}}, \quad \text{VSWR} = \frac{1 + r}{1 - r}$$

**Proportional controller** (DAC count computation):
$$\Delta_\text{counts} = G \cdot (V_\text{desired} - V_\text{actual}) \cdot K \cdot (1 + G_\text{loop})$$

with deadband, minimum threshold, and max-delta clamping.

**RF detector conversion loss** (calibration):
$$L_\text{dB} = 20 \cdot \log_{10}\left(\frac{K_E \cdot \sqrt{P_\text{cal}}}{A}\right)$$

### 17.2 subSys.c — System-Level Calculations

11 functions for system-level quantities:

**Frequency offset estimation** (polynomial from tuner position):
$$f_\text{offset} = p_0 + p_1 \Delta x + p_2 \Delta x^2 + p_3 \Delta x^3 + t_1 V^2$$

where $\Delta x = x_\text{current} - x_\text{home}$ is the tuner position relative to home.

**Total direct loop phase** (rate-limited delta tracking):
$$K = -0.000360 \times \tau_\text{group} \times f_\text{offset} \times K_\text{conv}$$
$$L = L + \text{rate\_limited}(C + D + K - L) \quad \text{(with } \pm 180° \text{ wrap)}$$

**Drive power setpoint selection** (with hysteresis): Returns mode 1 (low beam current) or mode 2 (high beam current) based on klystron forward power.

**Log-to-linear conversion**: $V = B \cdot 10^A$ (for vacuum/ion pump readings).

### 17.3 Upgrade Reuse Assessment

| Category | Verdict |
|----------|---------|
| subIQ.c (23 functions) | **KEEP** — direct reuse, no hardware dependency |
| subSys.c (11 functions) | **KEEP** — minor cleanup (AB reset call) |
| Functions duplicating LLRF9 outputs | May be redundant — LLRF9 provides I/Q, power, phase as PV readbacks |
| System-level calculations (gain, coupling, beam loading) | Still needed in coordinator/MATLAB tools |

---

## 18. HVPS and Power Conversion System

### 18.1 Power Section

| Parameter | Value |
|-----------|-------|
| Input voltage | 12.47 kV RMS, 3-phase |
| Phase-shifting transformer | 3.5 MVA, extended delta, ±15° |
| Rectifier transformers | 2 × 1.5 MVA, open-wye primary |
| Maximum output | −90 kVDC, 27 A |
| Maximum output power | 2.5 MW |
| Nominal operating point | −74.7 kV, 22.0 A (at 500 mA beam) |
| Phase control stacks | 12 × 14 Powerex T8K7 (350 A) thyristors |
| Filter inductors | 2 × 0.3 H, 85 A full load, 1084 J stored each |
| Output filter capacitors | 4 × 8 μF (series), 0.22 μF output capacitor |
| Crowbar stacks | 4 × 6 thyristors, fiber-optic triggered |
| Output voltage dividers | 2 × 100 MΩ (5×20 MΩ + 2×10 kΩ parallel), scale: 9.1 V at −91 kV |

### 18.2 SCR Firing Circuit

Enerpro FCOG6100 firing circuit with FCOAUX60 daughter board (30° delayed triggering) generates 12 thyristor trigger pulses. Trigger chain:

$$\text{Enerpro} \rightarrow \text{Trigger Interconnect Boards (L/R)} \rightarrow 12 \times \text{SCR Driver Boards} \rightarrow 12 \times \text{SCR Stacks (14 SCRs each)}$$

### 18.3 Regulator Board (SD-237-230-14)

SLAC-designed dual voltage/current regulator with diode-OR output. The SIGHI node combines PLC and regulator signals:

$$V_\text{SIGHI} = \frac{7.5 \cdot V_\text{PLC} + 1.0 \cdot V_\text{REG}}{8.5}, \quad R_\text{Thevenin} = 882\;\Omega$$

### 18.4 PLC Digital Low-Pass Filter

The SLC-500 PLC implements a first-order digital LPF for smooth voltage ramping:

$$N_{43} = N_{30} - N_{10} \quad (\text{error})$$

$$N_{43} = N_{43} / 10 \quad (\alpha = 0.1)$$

$$N_{10} = N_{10} + N_{43} \quad (\text{update})$$

Loop period $T = 80$ ms, time constant $\tau = -T/\ln(1-\alpha) \approx 0.76$ s.

### 18.5 Fiber Optic Connections (LLRF → HVPS)

Three fiber optic signals:

| Signal | Direction | Active State | Function |
|--------|-----------|-------------|----------|
| SCR ENABLE | LLRF → HVPS | Illuminated = permit | Enables thyristor triggers |
| KLYSTRON CROWBAR | LLRF → HVPS | Illuminated = inhibit | Removes light to fire crowbar |
| STATUS | HVPS → LLRF | Illuminated = ready | HVPS control supply + no crowbar |

Fail-safe convention: All signals except AB Summary use loss-of-light = fault.

---

## 19. Machine Protection and Interlock Architecture

### 19.1 Five Independent Crowbar/Disable Sources

The HVPS implements defense-in-depth with five independent shutdown paths:

| # | Source | Action |
|---|--------|--------|
| 1 | Fiber Optic SCR ENABLE (from LLRF) | Loss → disables right-side triggers + disables left-side |
| 2 | TRANSFORMER ARC TRIGGER (BNC-0) | Fire crowbar + disable all triggers |
| 3 | Fiber Optic KLYSTRON CROWBAR (from LLRF) | Loss → fire crowbar + disable all triggers |
| 4 | KLYSTRON ARC TRIGGER (BNC-12) | Fire crowbar + disable all triggers |
| 5 | PLC FORCE CROWBAR (Slot-5 OUT3) | Active-low → disable triggers + fire crowbar |

**Critical design feature**: Phases B+ and B- on the right side have OFF signals tied to common (always enabled), allowing safe discharge of filter inductor stored energy even when all other triggers are disabled.

### 19.2 Crowbar Energy Budget

| Scenario | Energy to Klystron | Status |
|----------|-------------------|--------|
| Crowbar functioning | < 4 J | Safe (well below 20 J threshold) |
| Crowbar failed (passive only) | < 16 J | Still safe (2Ω resistors + inductors limit current) |
| Damage threshold | 20 J | Philips specification |

### 19.3 HVPS Shutdown Timing

- SCR disable → <10% power in ~100 ms
- Inductor discharge through B-phase thyristors (always enabled) + rectifier return path
- Capacitor discharge through 2Ω series resistors → klystron load

### 19.4 Legacy PPS Interface

PPS connector: Burndy GOB12-88PNE (8-pin). Two enable pairs (PPS 1, PPS 2) sourced by PPS; two status contacts (NO + NC) monitored by PPS. PPS logic is routed through the HVPS controller PLC — this is the primary compliance issue motivating the upgrade to a dedicated, PLC-independent PPS Interface Box.

### 19.5 Upgrade: Interface Chassis

The Interface Chassis is a new centralized hardware interlock hub replacing the distributed legacy wiring. Key features:

- **Combinational logic** (no processor in critical path): microsecond-scale response
- **First-fault detection**: Hardware latching on all inputs identifies the initiating fault
- **Electrical isolation**: All external signals isolated via optocouplers (Broadcom ACSL-6xx0) or fiber optic transceivers (HFBR-1412/2412)
- **Inputs**: LLRF9 status, HVPS status (fiber), MPS permit + heartbeat, SPEAR MPS permit, orbit interlock, arc detection, waveform buffer power monitoring
- **Outputs**: LLRF enable, HVPS SCR enable (fiber), HVPS crowbar (fiber), fault status to MPS

---

## 20. Operational Procedures and Modes

### 20.1 Normal Operation (ON_CW)

Three nested control loops operate simultaneously:

1. **Fast analog** (RFP, ~MHz): IQ decomposition—error correction—RF drive
2. **DAC Loop** (VxWorks, ~1 Hz): Monitor total gap voltage, adjust `SRF1:STN:ON:IQ` setpoint
3. **HVPS Loop** (VxWorks, ~0.5 Hz): Monitor `SRF1:KLYSDRIVFRWD:POWER`, adjust `SRF1:HVPS:VOLT:CTRL`

Fill pattern: 276 bunches in 4 groups + 1 camshaft bunch, with top-off injection every ~5 minutes.

### 20.2 Station Turn-On Sequence

1. **Tuners positioned** to `SRF1:CAViTUNR:POSN:ONHOME`
2. **HVPS powered** to minimum voltage (`SRF1:HVPS:VOLT:MIN`, typically 50 kV)
3. **DAC initialized** to ~100 counts → few watts drive → few hundred kV gap voltage
4. **Tuner feedback starts** — phase difference now measurable
5. **DAC increases** to ~200 counts
6. **Direct loop closed** — transient: drive spikes to ~45 W before settling to ~10 W (at low HVPS voltage, klystron output peaks at only ~50 kW — safe)
7. **Slow loops activated** — DAC and HVPS ramp over 10–20 seconds
8. **Steady state** — gap voltage and drive power at setpoints

### 20.3 Cavity Processing (ON_FM Mode)

Cavity conditioning uses frequency modulation (FM sweep across resonance) followed by CW processing. The HVPS `proc` state carefully ramps voltage while monitoring vacuum activity, forward power, and gap voltage with triple-condition protection logic.

### 20.4 TUNE Mode

Used for system bring-up after klystron replacement or HVPS refurbishment. Direct loop disabled, feedback loops disabled. The operator manually sets drive power and may need to adjust `SRF1:STNDIRECT:LOOP:PHASE.C` for new klystron phase characteristics.

### 20.5 Calibration (MATLAB Integration)

MATLAB commissioning routines (from PS-340-330-52-R0):

| Routine | Function |
|---------|----------|
| ConfDirect | Configure direct loop phase, gain, gain tracking |
| MeasDirCls | Measure closed-loop response in-situ (no beam loss) |
| Config Comb | Configure comb filter parameters (PEP-II only) |
| Make Equal | Set comb delay equalizer (PEP-II only) |
| Make Poly | Generate polynomial fit of resonant frequency vs. tuner position |
| Tune Cavs | Automated cavity tuning sequence |
| ConfWoofer | Configure woofer/GVF parameters (PEP-II only) |

---

## 21. Known Limitations and Failure Modes

### 21.1 Hardware Obsolescence

| Component | Status | Risk |
|-----------|--------|------|
| VXI modules (RFP, IQA, CLK, AIM) | Custom SLAC design, no spares available | Single point of failure |
| PLC-5 (RF MPS) | Discontinued by Rockwell | End-of-support |
| SLC-500 (HVPS controller) | Discontinued by Rockwell | End-of-support |
| 1746-HSTP1 (stepper) | Discontinued (replaced by Galil Aug 2025) | **Resolved** |
| Slo-Syn motors (M093-FC11) | Obsolete (Superior Electric) | Spares increasingly scarce |
| PWM drivers (SS2000MD4-M) | Obsolete | No replacements available |
| KSC V152 (VXI CPU) | Obsolete | No replacements available |

### 21.2 Design Vulnerabilities

1. **Gilbert-cell multiplier overdrive** → polarity inversion → positive feedback → catastrophic instability. Mitigated by soft limiter diodes.
2. **Cavity probe signal loss** → direct loop saturation → klystron overdrive. Mitigated by drive power limiting circuit (post-commissioning addition).
3. **Serial communication chain** → single cable failure isolates all downstream PLCs.
4. **Arc detection non-functional** → PEP-II fiber optic arc detectors were never commissioned. System has operated 20+ years without waveguide arc protection.
5. **Collector power monitoring** → software-based at ~1 Hz (far slower than thermal damage time constant).
6. **No absolute tuner position feedback** → relies on step counting from reference position; lost steps accumulate as permanent error.
7. **PPS routed through PLC** → non-compliant design coupling safety system to operational controller.

### 21.3 Operational Constraints

| Risk | Severity | Legacy Mitigation |
|------|----------|-------------------|
| Multiplier overdrive → positive feedback | Critical | 1N4157 soft limiter |
| Probe signal loss → drive saturation | Critical | Drive power limiter |
| HVPS ripple → field modulation | Medium | Ripple loop (phase tracker mode) |
| Tuner motor failure → detuning drift | Medium | Load angle monitor + alarm |
| Fast turn-on after beam abort | High | Pre-set tuner positions + quick ramp sequence |

---

## 22. Upgrade Architecture Summary

### 22.1 System Comparison

| Component | Legacy | Upgrade |
|-----------|--------|---------|
| Fast RF feedback | RFP analog + DSP (~1 μs) | LLRF9 FPGA (270 ns) |
| Signal monitoring | 3× IQA (VXI) | LLRF9 ADC (18 ch) + Waveform Buffer (12 ch) |
| HVPS control | SLC-500 via AB serial | CompactLogix via Ethernet/IP |
| RF MPS | PLC-5 via AB serial | ControlLogix 1756 via Ethernet/IP |
| Tuner control | AB 1746-HSTP1 | Galil DMC-4143 (commissioned Aug 2025) |
| Interlocks | Distributed analog + PLC | Interface Chassis (hardware AND-gate, <1 μs) |
| Supervisory | SNL on VxWorks | Python/EPICS coordinator (~1 Hz) |
| Arc detection | VXI AIM (non-functional) | Microstep-MIS optical (6 sensors) |
| PPS safety | Through HVPS PLC | Dedicated PPS Interface Box |
| Waveform capture | VXI history buffer | 16,384-sample/ch + circular buffers |
| Communication | AB serial daisy-chain | Ethernet/IP throughout |

### 22.2 Eliminated Loops

The following legacy loops are eliminated because the LLRF9 digital feedback handles their functions internally:

- **Ripple rejection** — LLRF9 bandwidth inherently rejects 720 Hz ripple
- **Comb filter** — PEP-II only; not needed for SPEAR3 beam current
- **Gap voltage feed-forward** — PEP-II only; no LFB system at SPEAR3
- **DAC loop (4-way branching)** — LLRF9 controls via single vector sum output

### 22.3 Upgrade State Machine

The proposed upgrade simplifies the 23-state legacy machine into 6 states:

$$\text{OFF} \rightarrow \text{INITIALIZE} \rightarrow \text{STANDBY} \rightarrow \text{ON\_CW} \rightarrow \text{FAULT} \rightarrow \text{FAULT\_CLEAR}$$

Legacy PARK + VXI init maps to INITIALIZE. Legacy TUNE + ON_FM are collapsed into a ramp-to-ON_CW sequence. Fault file capture becomes a substep of the FAULT state.

---

## 23. References

### Primary Sources (PEP-II LLRF Design)

1. Corredoura, P.L., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8498, PAC 1999. DOI: 10.2172/10204
2. Corredoura, P. et al., "Experience with the PEP-II RF System at High Beam Currents," EPAC 2000. arXiv: physics/0007029
3. Fox, J. et al., "Lessons learned from PEP-II LLRF and longitudinal feedback," Phys. Rev. ST Accel. Beams 13, 052802 (2010)
4. Rivetta, C. et al., "Modeling and simulation of longitudinal dynamics for LER-HER at PEP-II," Phys. Rev. ST Accel. Beams 10, 022801 (2007)
5. Allison, S., Claus, R., "Operator Interface for the PEP-II Low Level RF Control System," PAC 1997

### SPEAR3 RF System

6. McIntosh, P., "An Automated 476 MHz RF Cavity Processing Facility at SLAC," SLAC-PUB-10083, PAC 2003. DOI: 10.2172/815601
7. McIntosh, P., "The SPEAR3 RF System," SLAC-PUB-11017, January 2005. DOI: 10.2172/839730
8. Park, S., Corbett, J., "Booster Synchrotron RF System Upgrade for SPEAR3," IPAC 2010

### PEP-II RF System Design

9. Schwarz, H., Rimmer, R., "RF system design for the PEP-II B Factory," PAC 1994. OSTI: 10194040
10. Pedersen, F., "RF Cavity Feedback," SLAC-400, November 1992
11. Ziomek, C., Corredoura, P., "Digital I/Q Demodulator," PAC 1995

### SLAC Internal Documents

12. Schwarz, H., "PEP-II RF System Description," PS-340-330-51-R0, 1998 (transcribed)
13. Schwarz, H., Corredoura, P., "LLRF Feedback Loop Description," PS-340-330-52-R0, 1999 (transcribed)
14. Sebek, J., "SPEAR3 RF Station Operation," `LLRFOperation_jims.docx`
15. Sebek, J., "LLRF Documentation Notes," `LLRFDocumentationNotesR2.docx`, November 2021
16. Sebek, J., "Fiber Optic Cable Signal Control," `fiberOpticCableSignalControlRev3.docx`, June 2022
17. Cassel, R., Nguyen, M., "PEP-II High Voltage Power Supply Crowbar Energy Analysis," SLAC-PUB-7591, 1997
18. Wilson, P.B., "Fundamental-Mode RF Design in e+e- Storage Ring Factories," SLAC-PUB-6062, 1993

### SPEAR3 LLRF Upgrade Documents

19. Physical Design Report, Rev 1, `Designs/0_PHYSICAL_DESIGN_REPORT.md`, March 2026
20. Software Design Document, `Designs/10_SOFTWARE_DESIGN_DOCUMENT.md`
21. LLRF9 System and Software Report, `Designs/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md`
22. HVPS Engineering Technical Note, `Designs/4_HVPS_Engineering_Technical_Note.md`
23. Interface Chassis Design, `Designs/11_INTERFACE_CHASSIS_DESIGN.md`
24. Legacy LLRF Control System Technical Design, `Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md`

### Legacy Code Analysis

25. SPEAR3 LLRF Legacy Code Analysis Notes (8 documents), `spear-rf-code-legacy/codeReviewTechnicalNotes/`
26. PEP-II/SPEAR3 LLRF Technical Notes (6 documents), `llrf/documentation/legacyArchitecture/technical-notes/`
27. Legacy PDF Transcriptions (14 documents), `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/`

---

## Appendix A: Complete PV Reference Table

| PV Name | Type | Description |
|---------|------|-------------|
| `SRF1:STN:STATE:RBCK` | int | Station state readback (0=OFF, 1=PARK, 2=TUNE, 3=ON_FM, 4=ON_CW) |
| `SRF1:STN:STATE:CTRL` | int | Station state control command |
| `SRF1:STN:RESET` | int | Station reset trigger |
| `SRF1:HVPS:VOLT:CTRL` | float | HVPS voltage setpoint to PLC |
| `SRF1:HVPS:VOLT` | float | HVPS voltage readback from PLC |
| `SRF1:HVPS:VOLT:MIN` | float | Minimum HVPS voltage |
| `SRF1:HVPS:LOOP:CTRL` | int | HVPS loop control (0=OFF, 1=PROC, 2=ON) |
| `SRF1:HVPS:LOOP:STATUS` | int | HVPS loop status (0–15) |
| `SRF1:KLYSOUTFRWD:POWER` | float | Klystron forward power |
| `SRF1:KLYSOUTFRWD:POWER:MAX` | float | Max forward power limit |
| `SRF1:KLYSDRIVFRWD:POWER` | float | Klystron drive forward power |
| `SRF1:STNDAC:LOOP:STATUS` | int | DAC loop status (15 codes) |
| `SRF1:STNDIRECT:LOOP:COUNTS.A` | float | Direct loop gain |
| `SRF1:STNDIRECT:LOOP:PHASE.C` | float | Direct loop phase compensation |
| `SRF1:RFP:RFSWITCH` | int | RF output enable/disable |
| `SRF1:RFP:RUNMODE` | int | TUNE/OPERATE mode |
| `SRF1:RFP:DIRECTLOOP` | int | Direct loop enable |
| `SRF1:RFP:LEADCOMP` | int | Lead compensation enable |
| `SRF1:RFP:INTCOMP` | int | Integral compensation enable |
| `SRF1:CAV{N}TUNR:LOOP:STATE` | int | Tuner state (0=OFF, 1=PARK, 2=ON) |
| `SRF1:CAV{N}TUNR:POSN` | float | Tuner position readback |
| `SRF1:CAV{N}TUNR:POSN:CTRL` | float | Tuner position setpoint |
| `SRF1:CAV{N}TUNR:POSN:ONHOME` | float | Tuner ON home position |
| `SRF1:CAV{N}LOAD:ANGLE:ERR` | float | Load angle error |
| `SRF1:CAVVACM:SUMY:SEVR.SEVR` | int | Cavity vacuum summary severity |
| `SRF1:CAVVOLT:CHECK` | int | Cavity voltage check |

*(Where `{N}` = 1, 2, 3, or 4 for the four cavities)*

---

## Appendix B: Source Code File Summary

| Category | Files | Lines | Upgrade Verdict |
|----------|-------|-------|-----------------|
| VXI Driver + Device Support | ~20 | ~18,000 | ELIMINATED (LLRF9 replaces) |
| Custom Record Types | 7 | ~2,200 | ELIMINATED |
| SNL State Machines | 6 + 12 headers | ~8,200 | SPEC-EXTRACT |
| DSP Firmware | ~100 | ~16,700 | ELIMINATED (LLRF9 FPGA) |
| PLC/Stepper Drivers | ~20 | ~7,000 | ELIMINATED (Galil/Ethernet) |
| EPICS Databases | 78+ | ~15,000 | PV REFERENCE |
| Signal Processing (subIQ, subSys) | 2 | ~1,430 | **REUSE** |
| PEP-II Only Modules | ~30 | ~10,000 | NOT USED IN SPEAR3 |
| Infrastructure/Build | ~60 | ~15,000 | OBSOLETE |
| **Total** | **253** | **~82,430** | |

---

## Appendix C: Glossary

| Term | Definition |
|------|-----------|
| AIM | Arc/Interlock Module — VXI module for arc detection and fast interlocks |
| CFM | Comb Filter Module — PEP-II only digital filter for revolution harmonic suppression |
| GVF | Gap Voltage Feed-Forward — PEP-II only VXI module for gap voltage reference + LFB interface |
| HVPS | High Voltage Power Supply — provides klystron cathode voltage (up to 90 kV) |
| IQ | In-phase/Quadrature — two-component RF signal representation |
| IQA | IQ/Amplitude Detector — VXI digital demodulation module |
| LFB | Longitudinal Feedback — PEP-II bunch-by-bunch coupled-mode damping system |
| LLRF | Low-Level RF — the feedback and control electronics for the RF system |
| LLRF9 | Dimtel LLRF9/476 — FPGA-based LLRF controller replacing the VXI system |
| MPS | Machine Protection System |
| PPS | Personnel Protection System |
| RFP | RF Processor — central VXI analog feedback processing module |
| Robinson instability | Beam-cavity instability from impedance asymmetry at synchrotron sidebands |
| SCR | Silicon Controlled Rectifier (thyristor) — HVPS switching element |
| SNL | State Notation Language — EPICS real-time sequencer programming language |
| VXI | VMEbus eXtensions for Instrumentation — modular instrument bus standard |

---

*Document generated: 2026-03-19 | Revision 1.0*  
*Source material: 6 technical notes (~3,800 lines), 8 code review notes (~2,500 lines), 15 legacy PDF transcriptions (~2,600 lines), 253 source files (82,430+ lines), 11 published papers, 18+ engineering design documents.*
