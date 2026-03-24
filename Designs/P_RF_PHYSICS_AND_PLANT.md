# SPEAR3 RF System — RF Physics, Control Theory and Physical Plant

**Document ID**: Doc P  
**Version**: 1.0  
**Date**: March 24, 2026  
**Status**: DRAFT — For Engineering Review  
**Location**: Designs/P_RF_PHYSICS_AND_PLANT.md  
**Author**: Faya Wang, with AI-assisted analysis  
**Tier**: 1 — Physics and Plant Reference (implementation-independent)

---

## Revision History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | 2026-03-24 | Initial draft: complete nine-section structure covering SPEAR3 RF accelerating system overview, cavity physics, I/Q feedback control theory, feedback loop transfer functions and stability, HVPS plant model, klystron characteristics, tuner mechanics, signal processing, and noise/stability/performance requirements. All sections cite original source documents per Documentation Architecture Proposal v5.1 provenance rules. |

---

## Table of Contents

1. [SPEAR3 RF Accelerating System Overview](#1-spear3-rf-accelerating-system-overview)
2. [Cavity Physics: Impedance, Detuning, and Beam Loading](#2-cavity-physics-impedance-detuning-and-beam-loading)
3. [I/Q Feedback Control Theory](#3-iq-feedback-control-theory)
4. [Feedback Loop Transfer Functions and Stability](#4-feedback-loop-transfer-functions-and-stability)
5. [HVPS Plant Model: SCR Bridge and Power Supply Dynamics](#5-hvps-plant-model-scr-bridge-and-power-supply-dynamics)
6. [Klystron Characteristics and Operating Points](#6-klystron-characteristics-and-operating-points)
7. [Tuner Mechanics and Resonant Frequency Control](#7-tuner-mechanics-and-resonant-frequency-control)
8. [Signal Processing: Baseband Conversion and DSP Algorithms](#8-signal-processing-baseband-conversion-and-dsp-algorithms)
9. [Noise, Stability, and Performance Requirements](#9-noise-stability-and-performance-requirements)

Appendices:
- [Appendix A — SPEAR3 RF System Parameter Table](#appendix-a--spear3-rf-system-parameter-table)
- [Appendix B — Source Document Reference Index](#appendix-b--source-document-reference-index)
- [Appendix C — Symbol and Notation Conventions](#appendix-c--symbol-and-notation-conventions)

---

## Document Scope and Provenance

### Purpose

This document is the **Tier 1 physics and plant reference** for the SPEAR3 RF system. It covers the RF physics, control theory, and physical plant parameters that are **independent of the specific control hardware implementation**. The content described here does not change when VXI hardware is replaced with the LLRF9 controller — it describes the fundamental physics governing the RF accelerating system.

This document serves three purposes:
1. **Onboarding reference** for engineers who need to understand *why* the control system works the way it does
2. **Authoritative source** for design decisions in the upgrade (Tier 3 documents U1–U10)
3. **Institutional knowledge preservation** of the physics and engineering principles underlying the SPEAR3 RF system

### Provenance Statement

All technical content in this document is derived from **original source documents** as defined in the Documentation Architecture Proposal (v5.1, §2.1). These include:
- Published SLAC technical papers and conference proceedings
- Original engineering specifications and design documents
- Measurement data from actual hardware
- Legacy source code implementing the physics algorithms
- Standard textbook references in accelerator physics and RF engineering

Where AI-generated technical notes from the repository have been consulted during preparation, they are cited parenthetically as *"preliminary analysis (AI-generated, see [filename], unreviewed)"* per the provenance rules in the Documentation Architecture Proposal §2.4.

External web references obtained through research are cited with full bibliographic information.

### What This Document Contains

- Equations, transfer functions, plant parameters, physical constants, measurement definitions
- Circuit-level physics of the RF cavity, klystron, HVPS, and tuner systems
- Control theory fundamentals applicable to the LLRF feedback architecture
- SPEAR3-specific numerical parameters derived from original measurements

### What This Document Does NOT Contain

- Hardware-specific implementation details of either the legacy or upgraded control system
- Upgrade design specifications (see Tier 3 documents U1–U10)
- Operational procedures (see Doc L)
- Wiring diagrams or schematic interpretations (see individual subsystem technical notes)

---

## 1. SPEAR3 RF Accelerating System Overview

### 1.1 Storage Ring Context

SPEAR3 (Stanford Positron Electron Asymmetric Ring, 3rd generation) is a 3.0 GeV electron storage ring operated by the Stanford Synchrotron Radiation Lightsource (SSRL) at SLAC National Accelerator Laboratory. Originally constructed in 1972 for colliding beam physics, SPEAR was converted to a dedicated synchrotron radiation source and underwent a major upgrade to SPEAR3 in 2003.

**Key storage ring parameters:**

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| Beam energy | E₀ | 3.0 | GeV |
| Beam current (top-off) | I_b | 500 | mA |
| Circumference | C | 234.14 | m |
| Revolution frequency | f_rev | 1.2804 | MHz |
| Harmonic number | h | 372 | — |
| RF frequency | f_RF | 476.3051755 | MHz |
| Momentum compaction | α_c | 1.18 × 10⁻³ | — |
| Energy loss per turn | U₀ | ~0.91 | MeV |
| Total accelerating voltage | V_RF | ~3.2 (design) / ~2.85 (operational) | MV |
| Beam emittance | ε | 7–18 | nm·rad |
| Synchrotron tune | ν_s | ~0.0073 | — |
| Synchrotron frequency | f_s | ~9.4 | kHz |

> **Sources**: McIntosh, P. et al., "The SPEAR3 RF System," SLAC-PUB-10983, presented at EPAC 2004 [R1]. Hettel, R. et al., "Design of the SPEAR 3 Light Source," presented at PAC 1999 [R2]. SSRL website parameters page [R3]. LLRF9 commissioning measurements, `llrf/tests/llrf9Tests.pdf` [R4].

### 1.2 RF System Configuration

The SPEAR3 RF system consists of a single RF station adopting the PEP-II HER (High Energy Ring) station architecture. The configuration was inherited directly from the PEP-II B-Factory project at SLAC, leveraging substantial operational experience accumulated since 1996.

**RF station architecture (signal flow):**

```
476.3 MHz                                                    Beam
Master    ┌─────────┐  ┌───────────┐  ┌──────────┐  ┌─────────────┐  Direction
Oscillator│  LLRF   │  │   Drive   │  │ Klystron │  │ Waveguide + │  ──────►
──────────┤Controller├──┤ Amplifier ├──┤ (1.2 MW) ├──┤ Circulator  ├──┐
          │(I/Q Mod)│  │ (~120 W)  │  │          │  │             │  │
          └────┬────┘  └───────────┘  └─────┬────┘  └─────────────┘  │
               │                            │                         │
               │                     ┌──────┴──────┐         ┌───────┴───────┐
               │                     │    HVPS     │         │ Power Splitter│
               │                     │ (90 kV DC)  │         │ (3 × Magic-T)│
               │                     │ SCR-bridge  │         └───┬───┬───┬───┘
               │                     └─────────────┘             │   │   │   │
               │                                            ┌────┴┐┌┴──┐┌┴──┐┌┴───┐
               └──── Cavity Probe Feedback ◄────────────────┤Cav A││CavB││CavC││CavD│
                                                            │     ││    ││    ││    │
                                                            │Tuner││Tunr││Tunr││Tunr│
                                                            └─────┘└────┘└────┘└────┘
```

**Major RF system components:**

| Component | Type/Model | Key Specification |
|-----------|-----------|-------------------|
| Klystron | Marconi/CPI K3512S | 1.2 MW CW, 476.3 MHz, 43 dB gain, <150 ns group delay |
| Cavities (×4) | PEP-II single-cell HOM-damped copper | 800 kV max/cavity, R_s = 3.73 MΩ (linac convention) |
| HVPS | PEP-II 2.5 MVA SCR bridge | 0–90 kV, 27 A max, <0.5% regulation |
| Drive Amplifier | Solid-state | ~120 W, 476 MHz |
| Circulator | AFT type | Klystron protection from reflected power |
| Waveguide | WR2100 | Air-pressurized, interlocked |

> **Sources**: McIntosh et al. [R1]; `Designs/0_SYSTEM_DESIGN_REPORT.md` §1, §4 [R5]; `llrf/documentation/legacyArchitecture/ps3403305100.pdf` — Schwarz, H., "PEP-II RF System Description," PS-340-330-51-R0, July 1999 [R6].

### 1.3 PEP-II Heritage

The SPEAR3 RF system is a direct descendant of the PEP-II B-Factory RF system designed and built at SLAC during 1994–1998. The key design decisions — choice of 476 MHz frequency, single-cell HOM-damped cavity design, SCR-controlled klystron power supply, baseband I/Q feedback architecture — were all established for PEP-II and carried over to SPEAR3 with minimal modification.

The PEP-II system was substantially more complex, with 5 HER stations (4 cavities each = 20 cavities) and 2–3 LER stations, requiring multi-station phase coordination and wideband coupled-bunch feedback. SPEAR3 uses only a single station with 4 cavities, simplifying operations considerably. Several PEP-II-specific features (Comb Loop, Gap Feed-Forward, LFB Woofer) are not used in SPEAR3.

**PEP-II vs. SPEAR3 key differences:**

| Parameter | PEP-II HER | SPEAR3 |
|-----------|-----------|--------|
| Number of stations | 5 (later 7) | 1 |
| Cavities per station | 4 | 4 |
| Total cavities | 20 (HER) + 4–6 (LER) | 4 |
| Beam current | 1.03 A (HER) / 2.0 A (LER) | 0.5 A |
| V_gap per cavity | 700 kV (HER) / 850 kV (LER) | ~712 kV |
| Comb Loop | Active (multi-bunch) | Not used |
| Gap Feed-Forward | Active (ion-clearing gap) | Not used |
| LFB Woofer | Active | Not used |

> **Sources**: Schwarz, H., "PEP-II RF System Description," PS-340-330-51-R0, Table 1 [R6]; `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PS-340-330-51_RF_System_Description.md` [R6t].

### 1.4 RF Cavity Design

The SPEAR3 RF cavities are PEP-II-type single-cell copper structures operating at 476.3 MHz, manufactured by ACCEL Instruments GmbH (Germany). They feature an integrated Higher-Order Mode (HOM) damping system consisting of three intersecting waveguides that couple out HOM power into in-vacuum, water-cooled RF loads.

**Cavity parameters (per cavity):**

| Parameter | Symbol | Value | Unit | Convention |
|-----------|--------|-------|------|------------|
| Resonant frequency | f₀ | 476.315 | MHz | — |
| Shunt impedance | R_s | 3.73 | MΩ | Linac (V²/2P) |
| Shunt impedance | R_s | 7.5 | MΩ | Accelerator (V²/P) |
| R/Q | R/Q | ~116 | Ω | Linac convention |
| Unloaded Q | Q₀ | 32,000–33,500 | — | — |
| Loaded Q | Q_L | 6,700–6,780 | — | — |
| Coupling coefficient | β | 3.72–4.0 | — | β = Q₀/Q_ext |
| Cavity half-bandwidth | f₁/₂ | ~35.5 | kHz | f₀/(2Q_L) |
| Maximum gap voltage | V_gap,max | 1,000 | kV | Design limit |
| Operational gap voltage | V_gap | ~712 | kV | At 500 mA |
| Cavity wall power | P_c | ~68 | kW | V²/(2R_s) |

The distinction between linac convention (R_s = V²/2P) and accelerator convention (R_s = V²/P) is important. The PEP-II design documents predominantly use linac convention, while some accelerator physics textbooks use the accelerator convention (factor of 2 difference). This document uses linac convention unless explicitly stated otherwise.

> **Sources**: Schwarz parameter table in PS-340-330-51-R0 [R6]; McIntosh et al. [R1]; Rimmer, R.A. et al., "RF Cavity Development for the PEP-II B Factory," LBL-33360, 1992 [R7]; Rimmer, R.A. et al., "High-Power Testing of the First PEP-II RF Cavity," SLAC-PUB-7210 / LBNL-38147, 1996 [R8]; Goldberg, D.A. et al., "Measurement and Analysis of Higher-Order-Mode (HOM) Damping in B-Factory RF Cavities," Proc. PAC 1995 [R9].

### 1.5 Power Budget

The RF power budget determines the required klystron output for a given beam current and gap voltage. The total forward power per cavity consists of:

```
P_fwd = P_cavity_wall + P_beam + P_reflected + P_waveguide_loss

where:
  P_cavity_wall = V_gap² / (2 R_s)           ≈ 68 kW at 712 kV
  P_beam = I_b × V_gap × cos(φ_s) / n_cav    ≈ 59 kW at 500 mA (4 cavities)
  P_reflected ≈ small (with proper tuning)
  P_waveguide_loss ≈ 5–10 kW
```

At 500 mA beam current with 4 cavities, total klystron forward power ≈ 4 × (68 + 59 + 8) ≈ 540 kW, well within the 1.2 MW klystron capability. The klystron typically operates at ~800 kW.

> **Sources**: Schwarz parameter table [R6]; `Designs/0_SYSTEM_DESIGN_REPORT.md` §4 [R5].

---

## 2. Cavity Physics: Impedance, Detuning, and Beam Loading

### 2.1 Equivalent Circuit Model

An RF cavity near its fundamental resonant mode can be represented by a parallel RLC circuit. This model is valid within a bandwidth of several times the cavity half-bandwidth around resonance (the "narrowband approximation").

**Parallel RLC equivalent circuit:**

```
         ┌───R_s───┐
         │         │
I_gen ──►├───L─────┤──► V_gap    ◄── I_beam
         │         │
         └───C─────┘
```

The cavity impedance as a function of frequency:

```
Z_cav(ω) = R_s / [1 + jQ_L(ω/ω₀ - ω₀/ω)]
```

Using the narrowband approximation (|Δω| << ω₀):

```
Z_cav(Δω) ≈ R_s / (1 + j·2Q_L·Δω/ω₀)

where Δω = ω - ω₀ is the angular frequency offset from resonance
```

The loaded shunt impedance is:

```
R_L = R_s / (1 + β)    where β = Q₀/Q_ext (coupling coefficient)
```

For SPEAR3: R_L = 3.73 MΩ / (1 + 3.72) ≈ 790 kΩ.

The cavity half-bandwidth (3 dB point):

```
Δf₁/₂ = f₀ / (2·Q_L) = 476.315 MHz / (2 × 6,700) ≈ 35.5 kHz
```

This bandwidth is the fundamental frequency scale of the cavity: disturbances faster than ~35 kHz are naturally attenuated by the cavity response, while slower disturbances require active feedback for suppression.

> **Sources**: Wiedemann, H., *Particle Accelerator Physics*, 4th ed., Springer, 2015, Ch. 19 "Beam-Cavity Interaction" [R10]. Gamp, A., "Beam-Cavity Interaction," CERN Accelerator School, CAS 2011, arXiv:1112.3203 [R11]. Wilson, P.B., "Fundamental-Mode RF Design in e⁺e⁻ Storage Ring Factories," SLAC-PUB-6062, 1993 [R12]. Schwarz parameter table [R6].

### 2.2 Beam Loading

When a charged particle beam traverses an RF cavity, each bunch deposits energy that excites the cavity's fundamental mode. The beam-induced voltage opposes the generator-driven voltage for particles above transition energy (which is always the case in an electron storage ring).

**Fundamental beam loading relation:**

The beam-induced voltage at the fundamental mode is:

```
V_b = 2·k·q = I_b · R_s / Q_L · Q_L · F(ψ)

For a bunched beam at the RF frequency:
V_b,resonance = I_b · R_s    (at exact resonance)
```

where I_b is the DC beam current and R_s is the cavity shunt impedance (linac convention).

**Phasor analysis:**

The total cavity voltage is the vector sum of the generator-induced voltage and beam-induced voltage:

```
V̄_cav = V̄_g + V̄_b
```

The generator voltage and beam voltage are related through the synchronous phase angle φ_s and the detuning angle ψ:

```
V_g · e^(jψ) = generator contribution
V_b · e^(j(π - φ_s)) = beam contribution (opposing acceleration)
```

**Synchronous phase:**

The synchronous phase φ_s is defined by the equilibrium condition where the energy gain per turn equals the synchrotron radiation loss:

```
e·V_RF·sin(φ_s) = U₀

For SPEAR3: sin(φ_s) = 0.91 MeV / 2.85 MV ≈ 0.319
φ_s ≈ 71.4° (above transition)
```

> **Sources**: Boussard, D., "Control of Cavities with High Beam Loading," IEEE Trans. Nucl. Sci. NS-32, 1985, PAC 1985 [R13]. Gamp [R11]. Wilson [R12]. `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md` [R14t].

### 2.3 Optimum Detuning for Beam Loading Compensation

To minimize the reflected power at the input coupler (and hence the required generator power), the cavity must be detuned from the RF frequency. The optimum detuning angle is:

```
tan(ψ_opt) = -I_b · R_s · sin(φ_s) / V_gap

For SPEAR3 at 500 mA (per cavity):
tan(ψ_opt) = -(0.5 A × 3.73 MΩ × sin(71.4°)) / 712 kV
            = -(0.5 × 3.73 × 10⁶ × 0.948) / 712 × 10³
            ≈ -2.49
ψ_opt ≈ -68.1°
```

The corresponding frequency detuning:

```
Δf_opt = f₀ · tan(ψ_opt) / (2·Q_L)
       = 476.315 MHz × (-2.49) / (2 × 6,700)
       ≈ -88.6 kHz
```

This means the cavity resonant frequency must be tuned approximately 89 kHz **below** the RF frequency at full beam current. The cavity tuner (mechanical plunger driven by a stepper motor) achieves this detuning.

**Detuning varies with beam current:** At injection (low current), the detuning is small. As beam current increases during top-off, the tuner loop continuously adjusts the cavity resonant frequency to track the optimum detuning.

### 2.4 Generator Power Requirements

The minimum generator power for a matched cavity (no reflected power) with optimum detuning is:

```
P_gen,min = (V_gap² / (4·R_L)) · [1 + (I_b·R_s·sin(φ_s)/V_gap)²]^(1/2) + P_beam

P_beam = I_b · V_gap · cos(φ_s) / n_cav
```

For non-optimum conditions, the generator power increases. The HVPS loop adjusts the klystron cathode voltage to maintain the klystron operating point approximately 10% below saturation, providing sufficient headroom for transient beam loading compensation by the fast feedback loops.

### 2.5 Robinson Instability

The Robinson instability is a single-bunch longitudinal instability driven by the asymmetry of the cavity impedance at the upper and lower synchrotron sidebands of the RF frequency.

**Growth rate for the fundamental cavity mode:**

```
1/τ = (I_b · α_c · ω_rev) / (4 · E₀ · ω_s) × 
      [Re{Z_eff(ω_RF + ω_s)} - Re{Z_eff(ω_RF - ω_s)}]
```

| Symbol | Definition |
|--------|-----------|
| I_b | DC beam current |
| α_c | Momentum compaction factor |
| ω_rev | Angular revolution frequency |
| E₀ | Beam energy |
| ω_s | Angular synchrotron frequency |
| Z_eff | Effective cavity impedance (includes feedback) |

For a detuned cavity (Δf < 0, below transition), the upper sideband sees higher impedance than the lower sideband, which drives Robinson instability. The direct RF feedback loop reduces this impedance asymmetry by ~40 dB (factor of 100), effectively suppressing the Robinson instability.

> **Sources**: Corredoura, P., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8124, PAC 1999, Eq. 1 [R15]; `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/conference-papers/Architecture_and_Performance_PEP-II_LLRF.md` [R15t]. Robinson, K.W., CEA Report CEAL-1010, 1964 [R16]. *Preliminary analysis (AI-generated, see `llrf/documentation/legacyArchitecture/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md`, unreviewed)*.

### 2.6 Coupled-Bunch Instabilities

For storage rings with large circumference (like PEP-II), multiple revolution harmonics interact with the cavity fundamental mode, driving coupled-bunch instabilities with growth rates that can be faster than one revolution period. The growth rate for mode μ is given by Equation 1 of Corredoura [R15]:

```
1/τ_μ = (I_b · η · f_RF) / (2 · ν_s · β² · E/e) × R_cb

where R_cb = Σ Re{Z(ω_RF + n·ω_rev + ω_s) - Z(ω_RF + n·ω_rev - ω_s)}
summed over all revolution harmonics n
```

For SPEAR3 at 500 mA, the coupled-bunch growth rates from the fundamental cavity mode are manageable with the Direct Loop alone (no Comb Loop needed), unlike PEP-II which required the full Direct + Comb + LFB Woofer architecture.

### 2.7 Higher-Order Mode (HOM) Impedances

The PEP-II/SPEAR3 cavities incorporate three HOM damping waveguides that reduce the quality factors of higher-order modes by typically 2–3 orders of magnitude (from Q ~ 10⁴ to Q ~ 10¹–10²). This ensures that beam-driven HOM power is extracted before it can drive coupled-bunch instabilities.

The HOM damping system was extensively characterized during PEP-II cavity development. Measurements showed that with the dampers installed, the effective HOM impedances are reduced to levels where the existing feedback systems (or natural radiation damping) can control any residual instabilities.

> **Sources**: Goldberg et al. [R9]; Rimmer, R.A. et al., "Comparison of Calculated, Measured, and Beam Sampled Impedances of a HOM-Damped RF Cavity," Phys. Rev. ST Accel. Beams 3, 102001, 2000 [R17].

---

## 3. I/Q Feedback Control Theory

### 3.1 In-Phase and Quadrature (I/Q) Signal Representation

All RF feedback loops in the PEP-II/SPEAR3 system use baseband In-phase and Quadrature (I/Q) techniques. An RF signal at frequency ω_RF with slowly-varying amplitude A(t) and phase φ(t) can be decomposed into:

```
V_RF(t) = A(t)·cos(ω_RF·t + φ(t))
        = I(t)·cos(ω_RF·t) - Q(t)·sin(ω_RF·t)

where:
  I(t) = A(t)·cos(φ(t))    (In-phase component)
  Q(t) = A(t)·sin(φ(t))    (Quadrature component)
```

The inverse relations:

```
A(t) = √(I² + Q²)         (Amplitude)
φ(t) = atan2(Q, I)         (Phase)
```

**Advantages of I/Q representation for RF control:**
1. The I and Q channels are **identical** electronically — unlike amplitude/phase systems where the phase channel requires different hardware
2. All modulation information is preserved in baseband signals (DC to ~few MHz)
3. Phase shifts can be applied **without step discontinuities** (unlike RF phase shifters)
4. A full 360° vector rotation is achievable by varying I and Q continuously

> **Sources**: Corredoura [R15], §2 "RF Feedback Details"; `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/conference-papers/Architecture_and_Performance_PEP-II_LLRF.md` [R15t].

### 3.2 Baseband I/Q Modulator

The baseband I/Q modulator is the central actuator through which all RF feedback loops act. It performs a scaled rotation of an input I/Q vector:

```
┌       ┐       ┌                  ┐ ┌      ┐
│ I_out │       │ cos θ    -sin θ  │ │ I_in │
│       │ = G · │                  │ │      │
│ Q_out │       │ sin θ     cos θ  │ │ Q_in │
└       ┘       └                  ┘ └      ┘
```

where G is the gain and θ is the rotation angle. This is implemented using four analog four-quadrant multipliers (AD834) and two summing amplifiers (EL2073), achieving:
- **Group delay**: <5 ns
- **Full-power bandwidth**: >40 MHz
- **Dynamic range**: >50 dB

The multiplier weights are set by DAC channels (AD7805, 8-channel 12-bit). For each modulator, 4 DAC channels are needed (one per matrix element), and additional channels null analog offsets. The total system uses 56 "slow" DAC channels and 7 baseband I/Q modulators.

> **Sources**: Corredoura [R15], Eq. 2, Fig. 5; AD834 datasheet [R18]; `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PEPII_LLRF_FBK_Loops_Description.md` §2.2 [R14t].

### 3.3 I/Q Demodulation

RF signals from cavity probes, klystron forward power, and other measurement points are converted to baseband I/Q signals using high-level (+13 dBm) I/Q demodulators. The mixer outputs are:
- AC-coupled into 50 Ω
- Low-pass filtered (F_c = 225 MHz) to remove RF leakage
- Amplified by video amplifiers (17 dB gain) to produce ±1 V maximum I/Q signals

The ±1 V level is dictated by the input specification of the AD834 multipliers used in the downstream I/Q modulators.

### 3.4 Cavity Probe Signal Combining (Vector Sum)

Each of the 4 cavity probe signals is demodulated to baseband I/Q and passed through a programmable combining network consisting of 4 I/Q baseband modulators and 2 summing amplifiers. By setting the appropriate DAC weights, the resulting I/Q signals represent the **total accelerating RF vector** for the station (the weighted vector sum of all cavity fields).

The combining weights account for:
- Different coupling coefficients between cavities
- Phase offsets from waveguide path length differences
- Relative calibration of probe pickup antennas

A MATLAB routine ("Tune Cavs") establishes the correct vector summation by measuring individual cavity resonance responses and fitting standard resonance curves.

> **Sources**: Schwarz, H., "LLRF Feedback Loop Description," PS-340-330-52-R0, July 1999 [R14]; Corredoura [R15].

### 3.5 Error Signal Generation

The direct RF feedback error signal is formed by comparing the cavity probe vector sum against the station reference:

```
E̅ = V̅_ref - V̅_probe

where:
  E̅ = (E_I, E_Q) = error vector
  V̅_ref = reference setpoint (from DAC Loop)
  V̅_probe = measured cavity field (from vector sum)
```

This error drives the I/Q modulator, which adjusts the klystron drive to reduce the error. The fundamental feedback equation is:

```
V̅_drive = G_loop · E̅ = G_loop · (V̅_ref - V̅_probe)
```

where G_loop is the open-loop gain (complex, frequency-dependent).

---

## 4. Feedback Loop Transfer Functions and Stability

### 4.1 Multi-Loop Architecture Overview

The SPEAR3 RF control system implements eight feedback and feedforward loops spanning seven decades of frequency (0.1 Hz to 2 MHz). These loops are organized in a nested hierarchy:

| Loop | Bandwidth | Measurement | Actuator | SPEAR3 Status |
|------|-----------|-------------|----------|---------------|
| Comb Loop | 2 MHz | Cavity probe | I/Q Modulator | Not used |
| LFB Woofer | 1 MHz | Beam BPM (external) | DAC → I/Q Mod | Not used |
| Direct Loop | 800 kHz | Cavity probe | I/Q Modulator | **Active** |
| Ripple Loop | 300 Hz | Klystron fwd phase | I/Q Modulator | **Active** |
| Gap FF Loop | 100 Hz | Error signal | DAC → I/Q Mod | Not used |
| HVPS Loop | ~1 Hz | Klystron drive power | HVPS cathode voltage | **Active** |
| Tuner Loop | ~1 Hz | Probe vs. fwd phase | Stepper motor | **Active** |
| DAC Loop | 0.1 Hz | Cavity probe amplitude | DAC output | **Active** |

> **Sources**: Schwarz [R14]; `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md` [R14t]; `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PEPII_LLRF_FBK_Loops_Description.md` [R19].

### 4.2 Direct Loop Transfer Function

The Direct Loop is the primary, highest-bandwidth feedback loop. Its open-loop transfer function is:

```
G_direct(s) = G_prop · G_lead(s) · G_int(s) · G_kly(s) · H_cav(s) · e^(-s·τ_d)

where:
  G_prop = proportional gain (~15 dB)
  G_lead(s) = lead compensator (increases phase margin when detuned)
  G_int(s) = integrator (30 kHz bandwidth, rejects power supply ripple at carrier)
  G_kly(s) = klystron transfer function (approximately unity gain with <150 ns delay)
  H_cav(s) = cavity transfer function (single pole at ω₁/₂ = 2π × 35.5 kHz)
  τ_d = total loop delay ≈ 500 ns (legacy analog) / 270 ns (LLRF9 digital)
```

**Cavity as the bandwidth-limiting element:** The cavity itself acts as the loop bandwidth limiter. The direct loop gain is approximately 15 dB (factor of ~5.6) at low frequencies, falling off at 20 dB/decade above the cavity half-bandwidth.

**Maximum achievable bandwidth:** Limited by the total loop delay τ_d. For stable operation with adequate phase margin (>30°), the maximum closed-loop bandwidth is approximately:

```
f_BW,max ≈ 1 / (4·τ_d)

Legacy (τ_d ≈ 1 μs): f_BW,max ≈ 250 kHz (extended to ~800 kHz with lead compensation)
LLRF9 (τ_d ≈ 270 ns): f_BW,max ≈ 930 kHz
```

**Impedance reduction:** The effective cavity impedance seen by the beam is reduced by the direct loop gain:

```
Z_eff(ω) = Z_cav(ω) / (1 + G_direct(ω))
```

At low frequencies: Z_eff ≈ Z_cav / (1 + 15 dB) ≈ Z_cav / 5.6, a ~15 dB reduction. Including lead and integral compensation, the achieved impedance reduction is approximately 40 dB (factor of 100) at the cavity center frequency.

> **Sources**: Corredoura [R15], Fig. 3; Schwarz [R14] "Direct Loop" section; *Preliminary analysis (AI-generated, see `llrf/documentation/legacyArchitecture/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md`, unreviewed)*.

### 4.3 Direct Loop Compensation

**Lead compensation:** Since all signals are baseband, applying lead compensation is straightforward. Lead-lag compensation increases phase margin when the cavities are detuned for full beam current. This decreases the closed-loop translation of imaginary to real cavity impedance, further reducing the peak driving impedances by approximately 25%.

**Integral compensation:** Provides large gains at frequencies close to the RF carrier. With a 30 kHz bandwidth integrator, large modulations caused by the switching ripple of the klystron HVPS are rejected at the cavity field.

### 4.4 Ripple Loop

The Ripple Loop corrects phase disturbances from the HVPS. The klystron gain and phase are sensitive to cathode voltage, so the 12-pulse SCR rectifier ripple (360 Hz fundamental, harmonics to ~50 kHz) modulates the klystron output.

The ripple loop uses the klystron forward phase signal (not the cavity probe), acting upstream of the cavity for rapid correction. It operates at ~300 Hz bandwidth, covering the dominant ripple harmonics (120, 240, 360 Hz).

In SPEAR3 practice, the ripple loop is deployed primarily as a slow phase tracker compensating for klystron phase shift as cathode voltage changes, rather than for fast ripple cancellation.

> **Sources**: Schwarz [R14] "Ripple Loop" section; `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md` §2 [R20t].

### 4.5 HVPS Loop

The HVPS loop regulates the klystron operating point by adjusting the cathode voltage. It measures the klystron input drive power and compares it to the ON_CW setpoint. The error drives a slow integrator (~1 Hz bandwidth) that adjusts the HVPS voltage setpoint.

**Operating principle:** The loop keeps the klystron operating at approximately 10% below saturated output power, providing headroom for the fast feedback loops to handle transient beam loading.

### 4.6 DAC Loop

The DAC loop is a very slow (0.1 Hz) integrating controller that maintains the measured gap voltage equal to the operator-settable "Station Gap Voltage" setpoint by adjusting the baseline I/Q modulator DAC values.

### 4.7 Tuner Loop

The Tuner Loop adjusts each cavity's mechanical tuner to maintain the optimal detuning angle for beam loading compensation. It compares the phase difference between the klystron forward signal and the cavity probe signal against a reference (the "Fixed Offset"), and drives the stepper motor to minimize the error.

### 4.8 Loop Hierarchy and Stability

The loops are designed with bandwidth separation of typically 10× or more between adjacent loops, ensuring that each loop operates independently without destabilizing the others:

```
DAC Loop (0.1 Hz) → HVPS/Tuner (1 Hz) → Gap FF (100 Hz) → 
Ripple (300 Hz) → Direct (800 kHz) → Comb (2 MHz)
```

This separation provides natural frequency-domain decoupling. The direct loop (innermost fast loop) dominates the dynamic response, while slower loops set the operating point.

> **Sources**: Schwarz [R14]; `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PEPII_LLRF_FBK_Loops_Description.md` §7 [R19].

---

## 5. HVPS Plant Model: SCR Bridge and Power Supply Dynamics

### 5.1 Power Supply Architecture

The SPEAR3 klystron High Voltage Power Supply (HVPS) is a PEP-II design based on a 12-pulse primary SCR-controlled rectifier operating at 12.47 kV (the SLAC site-wide distribution voltage). This architecture was designed by R. Cassel and M.N. Nguyen at SLAC.

**Key design features:**
1. **12-pulse SCR bridge** with primary filter inductor — provides rapid voltage control, good regulation, and fast turn-off during faults
2. **"Star point controller" configuration** — the filter inductor is on the primary side, allowing energy bypass during faults
3. **Unique secondary rectifier/filter** — minimizes stored energy available during klystron arcs
4. **SCR crowbar** — limits arc energy to <5 J with crowbar, <20 J without

> **Sources**: Cassel, R. and Nguyen, M.N., "A Unique Power Supply for the PEP II Klystron at SLAC," SLAC-PUB-7591, PAC 1997 [R21]; `hvps/architecture/originalDocuments/slac-pub-7591.pdf` and transcription [R21t]. Cassel, R., "PEP-II RF System — 2.5 MW Klystron Power Supply Technical Specification," PS-341-360-01-R2 [R22]; `hvps/architecture/originalDocuments/ps3413600102.pdf` and transcription [R22t].

### 5.2 Power Supply Signal Flow

```
12.47 kV      ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
3-phase  ──►  │Phase Shift│  │  SCR     │  │ Filter   │  │ Rectifier│
60 Hz         │Transformer│──│ Bridge   │──│ Inductor │──│Transformer│──►
              │(±15° Δ)  │  │(12-pulse)│  │(L₁,L₂)  │  │(T1,T2)   │
              └──────────┘  └──────────┘  └──────────┘  └──────────┘
                                                              │
              ┌──────────┐  ┌──────────┐  ┌──────────┐       │
              │Termination│  │  SCR     │  │Secondary │       │
 Klystron ◄── │   Tank   │──│ Crowbar  │──│Rectifiers│◄──────┘
              │(L₃,L₄,C) │  │(4 stacks)│  │+ Filters │
              └──────────┘  └──────────┘  └──────────┘
```

### 5.3 HVPS Electrical Parameters

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| Input voltage | V_in | 12,470 | V RMS L-L |
| Input frequency | f_line | 60 | Hz |
| Input phases | — | 3 | — |
| Output voltage range | V_out | 0 to -90 | kV |
| Output current max | I_out | 27 | A |
| Nominal operating voltage | V_nom | -77 | kV |
| Nominal operating current | I_nom | 22 | A |
| Power rating | P | 2.5 | MVA |
| Voltage regulation | — | <±0.5% | at >65 kV |
| Voltage ripple | — | <1% P-P, <0.2% RMS | at >60 kV |
| Phase shift transformer | T0 | 3.5 MVA, ±15° | — |
| Rectifier transformers | T1, T2 | 1.5 MVA each | Open wye primary, dual wye secondary |
| Filter inductors | L₁, L₂ | 0.3 H each | 85 A DC rating |
| Filter capacitors | C | 4 × 8 μF at 30 kV | — |
| Isolation resistors | R | 8 × 500 Ω, 1 kW | — |
| Cable termination inductors | L₃, L₄ | 200 μH each | — |
| SCR bridge stacks | — | 6 × 14 series SCRs | 40 kV, 80 A per stack |
| Crowbar stacks | — | 4 series SCR stacks | 100 kV total, 1 μs trigger |
| Klystron perveance | K_p | 2.0 × 10⁻⁶ | A/V^(3/2) |
| Arc energy (with crowbar) | — | <5 | J |
| Arc energy (without crowbar) | — | <20 | J |

> **Sources**: Cassel and Nguyen [R21]; PS-341-360-01-R2 specification [R22]; `hvps/simulation/hvps_sim/config.py` [R23]; `hvps/architecture/originalDocuments/transcriptions/pepII_supply_transcription.md` [R24t].

### 5.4 SCR Phase Control Dynamics

The 12-pulse SCR bridge uses phase-controlled rectification. The firing angle α determines the output DC voltage:

```
V_dc = V_dc,max · cos(α)

where V_dc,max = (3√2/π) · V_secondary ≈ peak output for α = 0°
```

The firing angle is controlled by the Enerpro FCOG1200 firing boards, which use a phase-locked loop (PLL) architecture:

```
PLL free-running frequency: 23,040 Hz = 384 × 60 Hz
Settling time: ~3 AC cycles (50 ms) for a step change
Bandwidth: -3 dB at ~66 Hz (415 rad/s)
DC gain: unity
```

The Enerpro board transfer function (from command input to firing angle):

```
H_enerpro(s) ≈ 1 / (1 + s/ω_enerpro)    where ω_enerpro ≈ 415 rad/s
```

> **Sources**: Bourbeau, E.J., "Application of PLL Controlled Phase Angle Regulating Techniques to SCR AC and DC Motor Drives," IEEE 1983 [R25]; `hvps/controls/enerpro/enerproDocuments/bourbeauIEEE1983_04504257.pdf` [R25]; Enerpro FCOG1200 operating manual [R26]; *Preliminary analysis (AI-generated, see `hvps/controls/enerpro/technical-notes/06-control-theory.md`, unreviewed)*.

### 5.5 PLC Voltage Regulation Loop

The Allen-Bradley SLC-500 PLC implements a digital voltage regulation loop that filters the HVPS output measurement and generates the phase angle command for the Enerpro boards.

**Digital filter parameters:**
- Scan period: T = 10 ms
- Filter coefficient: α = 0.4
- Time constant: τ = -T/ln(1-α) ≈ 20 ms
- Filter equation: y[n] = (1-α)·y[n-1] + α·x[n]

**Voltage reference scaling:**
- Internal range: 100 to 32,000 (16-bit integer)
- Phase angle output: N7:11 = (N7:10 × 12,000/32,767) + 6,000
- Maximum phase angle value: 18,000

> **Sources**: `hvps/documentation/plc/CasselPLCCode.pdf` [R27]; `hvps/documentation/plc/CasselSymbolDatabase.pdf` [R28]; `hvps/simulation/hvps_sim/config.py` [R23].

### 5.6 Klystron Arc Protection

Protection of the klystron during arcs is a critical design requirement. The HVPS design limits arc energy through:

1. **SCR crowbar** — fires within ~1 μs (fiber-optic trigger), shorts the output to clamp voltage
2. **Star point controller bypass** — turns on both SCRs in one phase, turns off all others, isolating the load from the line and discharging inductor energy into its resistance
3. **Isolation resistors** — the 500 Ω resistors between filter capacitors and output limit current to ~1 A maximum even if the crowbar fails
4. **Cable termination inductors** — 200 μH inductors limit di/dt of distribution cable discharge

The result: <5 J reaches the klystron with crowbar, <20 J without (single-point failure tolerance). The I²t specification for klystron protection is <40 A²·s.

> **Sources**: Cassel and Nguyen [R21]; PS-341-360-01-R2 §1.3 [R22].

### 5.7 HVPS Dynamic Response

The combined HVPS plant model for control design includes:

```
                    ┌───────────┐  ┌──────────┐  ┌──────────────┐  ┌─────────┐
V_ref ──► PLC ──►  │  Enerpro  │──│SCR Bridge│──│Filter Network│──│Klystron │──► V_kly
          filter    │  PLL/DAC  │  │ (12-pulse)│  │ (L,C,R)      │  │  Load   │
                    └───────────┘  └──────────┘  └──────────────┘  └─────────┘
```

Key time constants:
- PLC filter: τ_PLC ≈ 20 ms
- Enerpro PLL settling: ~50 ms (3 cycles)
- SCR commutation: ~100 μs (turn-off time)
- Filter LC network: τ_LC ≈ L/R ≈ 0.3 H / 3500 Ω ≈ 86 μs (with klystron load)
- Overall voltage step response: <10 ms for 10% step

---

## 6. Klystron Characteristics and Operating Points

### 6.1 Klystron Overview

The SPEAR3 klystron is a Marconi/CPI K3512S, a high-power CW amplifier designed for the PEP-II B-Factory. It operates at 476.3 MHz with the following specifications:

| Parameter | Value | Unit |
|-----------|-------|------|
| Frequency | 476.3 | MHz |
| Maximum output power | 1.2 | MW CW |
| Typical operating power | ~800 | kW |
| Gain | 43 | dB (minimum) |
| Bandwidth (-3 dB) | 5 | MHz |
| Group delay | <150 | ns |
| Cathode voltage | up to -90 | kV |
| Beam current | up to 27 | A |
| Efficiency | >60 | % |
| Drive power (for max output) | ~29 | W |
| Perveance | ~2.0 × 10⁻⁶ | A/V^(3/2) |

> **Sources**: McIntosh et al. [R1]; `Designs/0_SYSTEM_DESIGN_REPORT.md` §4, §5 [R5]; `llrf/tests/llrf9Tests.pdf` [R4].

### 6.2 Klystron Transfer Curve

The klystron exhibits a nonlinear relationship between input drive power and output RF power. At low drive levels, the klystron acts as a linear amplifier. As drive power increases, the klystron approaches saturation:

```
P_out = G_kly · P_drive    (linear region)
P_out → P_sat             (saturation)
```

The HVPS loop maintains the klystron operating point at approximately **10% below saturation** (the "ON_CW Drive Power" setpoint). This provides:
1. Sufficient linear headroom for the fast feedback loops to modulate the drive
2. Adequate power reserve for transient beam loading compensation
3. Reasonable efficiency (operating too far below saturation wastes HVPS power)

### 6.3 Klystron Phase Sensitivity to Cathode Voltage

The klystron output phase varies with cathode voltage due to velocity modulation effects. As the cathode voltage changes (e.g., from HVPS ripple or regulation steps), the electron beam velocity in the drift tube changes, shifting the output phase.

This phase sensitivity is the primary reason for:
1. The **Ripple Loop** — cancels phase modulation from HVPS 360 Hz (12-pulse) ripple
2. The **HVPS voltage regulation** — tight regulation minimizes phase noise from voltage variations

The ripple loop DSP processes the klystron I/Q signals at 23 kHz, estimating and canceling harmonics of the 60 Hz mains frequency. For SPEAR3, harmonic number 372 (matching the storage ring harmonic number) is used for synchronization.

> **Sources**: Schwarz [R14] "Ripple Loop"; `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md` §2 [R20t]; `llrf/tests/llrf9Tests.pdf` [R4].

### 6.4 Klystron as a Control Element

For the LLRF feedback system, the klystron can be modeled as a gain block with a time delay:

```
G_kly(s) = K · e^(-s·τ_kly)

where:
  K ≈ 1 (when expressed in normalized units, I/Q modulator to cavity)
  τ_kly < 150 ns (klystron group delay)
```

This delay is a significant fraction of the total loop delay and was the driving force for procuring wide-band (short-delay) klystrons for PEP-II. The total Direct Loop delay budget is:

| Component | Delay |
|-----------|-------|
| Klystron group delay | <150 ns |
| I/Q modulator | <5 ns |
| Cable propagation | ~50 ns |
| Electronics (demod, mixing) | ~100 ns |
| Total (legacy analog) | ~500 ns |
| **Total (LLRF9 digital)** | **~270 ns** |

---

## 7. Tuner Mechanics and Resonant Frequency Control

### 7.1 Cavity Tuner Physical Description

Each of the four SPEAR3 RF cavities has a mechanical tuner consisting of a movable plunger that protrudes into the cavity through a port. The plunger position varies the cavity's resonant frequency by changing the effective volume (and hence capacitance) of the cavity.

**Tuner specifications:**

| Parameter | Value |
|-----------|-------|
| Motor type | Superior Electric Slo-Syn M093-FC11 (NEMA 34D) |
| Drive mechanism | Worm gear (self-locking) |
| Tuning range | ~±200 kHz |
| Step resolution | ~1 Hz/step (via worm gear ratio) |
| Maximum speed | Limited by stepper motor and controller |

The worm gear provides self-locking: when the motor is not energized, the tuner position is held mechanically. This is a safety feature — loss of tuner control does not cause the cavity to drift off frequency rapidly.

> **Sources**: `llrf/tuners/SLO-SYN.pdf` [R29]; `llrf/tuners/SLO-SYN_MD808_Stepper_Drive_Manual.pdf` [R30]; `llrf/tuners/SLO-SYN_SS2000MD4M_Step_Drive_Translator_Manual.pdf` [R31]; `llrf/tuners/galil/dmc-4103-r13h-manual.pdf` [R32]; `llrf/tuners/cavityTunerInspections20230613.docx` [R33].

### 7.2 Tuning Physics

The cavity resonant frequency depends on the tuner plunger position through a nonlinear relationship that is characterized empirically:

```
f_res(x) = polynomial fit from "Make Poly" MATLAB routine

where x = tuner position (stepper motor counts)
```

The polynomial is typically 3rd or 4th order and is measured by the "Tune Cavs" MATLAB routine, which injects noise onto a CW reference and fits standard resonance curves to the measured response.

**Temperature dependence:** The cavity resonant frequency also varies with temperature due to thermal expansion of the copper cavity walls. At steady-state operation, the LCW (Low-Conductivity Water) cooling system maintains the cavity body temperature at 35°C. Thermal transients during power changes cause frequency shifts that the tuner loop must track.

### 7.3 Tuner Control Loop

The tuner control loop maintains the optimal detuning angle (§2.3) by comparing the phase difference between the klystron forward signal and the cavity probe signal:

```
Error = (Phase_probe - Phase_forward) - Fixed_Offset

where Fixed_Offset = target detuning angle
```

The loop is implemented in software (EPICS SNL state machine `rf_tuner_loop.st`) and drives the stepper motor through a controller. The loop bandwidth is ~0.01–1 Hz, limited by the mechanical response of the stepper motor and worm gear.

**Park frequency:** When beam is not present, the cavities are "parked" at a specific frequency (typically near resonance or at a designated park frequency). The park position is determined from the polynomial fit of frequency vs. tuner position.

> **Sources**: Schwarz [R14] "Tuner Loop"; `spear-rf-code-legacy/rfApp/src/seq/rf_tuner_loop.st` [R34]; `llrf/tuners/galil/GalilCommissioning.docx` [R35].

---

## 8. Signal Processing: Baseband Conversion and DSP Algorithms

### 8.1 Digital Down-Conversion

A family of digital down-converters within the LLRF system provides high-accuracy measurements of RF signals throughout the system. These convert 476 MHz RF signals to I/Q baseband with excellent dynamic range and phase accuracy.

In the legacy system, the IQA (I/Q Analyzer) modules provide this function. In the LLRF9 upgrade, the FPGA performs digital down-conversion with 9 input channels at the card level.

### 8.2 DSP Ripple Rejection Algorithm

The legacy TMS320C16xx DSP firmware implements a harmonic estimation algorithm for HVPS ripple rejection:

```
1. Read I/Q signals from ADCs (16-bit, interlaced)
2. Compute phase: φ = atan2(Q, I)  (q13 fixed-point)
3. Compute amplitude: A = √(I² + Q²)
4. For each harmonic h[n] (n = 1..6 fast, 1..8 slow):
   h[n].I_accum += PhaseErr × cos(2π·n·f_ripple·t)
   h[n].Q_accum += PhaseErr × sin(2π·n·f_ripple·t)
5. Sum corrections: DAC_correction = Σ h[n].accum × gain[n]
6. Apply to DAC: DAC_out = DAC_base + DAC_correction
```

The algorithm operates at ~23 kHz loop rate, with "fast" harmonics processed every cycle and "slow" harmonics in round-robin at ~3 kHz effective rate.

**Fixed-point arithmetic formats:**

| Format | Range | Resolution | Application |
|--------|-------|-----------|-------------|
| q13 | [-1.0, +1.0) | ~1.2×10⁻⁴ | Phase angles (maps to [-π, +π]) |
| q11 | [-16.0, +16.0) | ~4.9×10⁻⁴ | Accumulators (extra headroom) |
| q15 | [-1.0, +1.0) | ~3.1×10⁻⁵ | Gain coefficients |

> **Sources**: `spear-rf-code-legacy/dsp1610/rfpDsp/ripple.s` and `sp3ripple.s` [R36]; `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md` §2 [R20t].

### 8.3 Coordinate Transforms

The DSP firmware implements fixed-point coordinate transform functions:

**I/Q to Amplitude/Phase:**
```
A = √(I² + Q²)     — via lookup table with linear interpolation (lusqrt.s)
φ = atan2(Q, I)     — via lookup table with linear interpolation (atan.s)
```

**Amplitude/Phase to I/Q:**
```
I = A × cos(φ)      — via 256-entry sin/cos lookup tables
Q = A × sin(φ)
```

These transforms are fundamental to the signal processing chain throughout the LLRF system.

### 8.4 Comb Filter (PEP-II Only)

The comb filter implements a second-order IIR digital filter with the transfer function:

```
H(z) = G(z⁻¹ - z⁻ⁿ) / (1 - 2K·cos(2π·ν_s)·z⁻ⁿ + K²·z⁻²ⁿ)

where:
  G = forward gain
  K = reverse gain
  n = one revolution period in samples
  ν_s = synchrotron tune
```

The filter response peaks at synchrotron sidebands of revolution harmonics and has a zero at the revolution harmonics themselves. This is not used in SPEAR3.

> **Sources**: Corredoura [R15], Eq. 3.

### 8.5 Network Analyzer and Diagnostic Functions

The LLRF system includes a built-in network analyzer and arbitrary RF function generator that interface with MATLAB. These provide:
- Automated configuration of each feedback loop
- Cavity FM processing and resonance curve measurement
- Closed-loop response measurement ("MeasDirCls" routine — does not disturb stored beam)
- Transfer function measurement for system identification

---

## 9. Noise, Stability, and Performance Requirements

### 9.1 RF Field Stability Requirements

The SPEAR3 RF field stability requirements derive from the storage ring requirements for beam stability:

| Parameter | Requirement | Typical Achieved |
|-----------|------------|-----------------|
| Amplitude stability | <0.1% RMS | <0.05% RMS |
| Phase stability | <0.1° RMS | <0.05° RMS |
| Voltage regulation | ±0.5% | ±0.3% |
| Ripple (HVPS contribution) | <1% P-P | <0.5% P-P |

These stability requirements flow down from the storage ring requirements for:
- Photon beam position stability at beam lines
- Energy stability for precision experiments
- Bunch length stability

### 9.2 LLRF9 Commissioning Test Results

The LLRF9 controller was tested against the legacy system at SPEAR3. Key measurements from `llrf9Tests.pdf`:

**Spectrum measurements at 500 mA:**
- LLRF9 shows improved noise floor compared to legacy system
- HVPS harmonics (360 Hz, 720 Hz, etc.) are visible in both systems but reduced with LLRF9 digital filtering
- Filtered spectrum measurements show the LLRF9 achieving better than the legacy system across the measurement band

**Key test configurations:**
- Cavity A spectrum: Legacy vs. LLRF9 at 500 mA
- Tune mode: HVPS harmonic content visible
- Filtered fits: Quantitative comparison of spectral components

> **Sources**: `llrf/tests/llrf9Tests.pdf` [R4]; `llrf/tests/llrf9Tests.tex` [R4t]; test graphics in `llrf/tests/graphics/` [R37].

### 9.3 HVPS Noise Contributions

The primary noise source in the RF field is HVPS voltage ripple, which modulates the klystron gain and phase. The 12-pulse SCR rectifier produces:

| Harmonic | Frequency | Typical Amplitude |
|----------|-----------|-------------------|
| 6th (fundamental ripple) | 360 Hz | <1% P-P at >60 kV |
| 12th | 720 Hz | <0.3% P-P |
| Higher harmonics | 1080+ Hz | Decreasing |
| 60 Hz and 120 Hz | 60, 120 Hz | Small (12-pulse cancellation) |

The ripple loop and direct loop together provide >40 dB rejection of these harmonics at the cavity field.

### 9.4 Calibration Data

The repository contains extensive calibration data that characterizes the RF signal chain:

| Calibration File | Content | Location |
|-----------------|---------|----------|
| driveAmpCalibration.xlsx | Drive amplifier power vs. DAC setting | llrf/calibrations/ |
| klystronCouplerDriveAmpCalibrations.xlsx | Klystron coupler and drive amp calibrations | llrf/calibrations/ |
| pulsarCouplerCalibration2049.xlsx | Pulsar coupler calibration | llrf/calibrations/ |
| reflectedPowerCalibrations.xlsx | Reflected power measurement calibrations | llrf/calibrations/ |
| tuneModeDacCalibration.xlsx | Tune mode DAC calibration | llrf/calibrations/ |
| b132R11PatchPanel.xlsx | B132 R11 patch panel mapping | llrf/calibrations/ |

These calibrations establish the numerical relationships between DAC counts, power levels, voltage levels, and physical quantities that are essential for proper operation of all feedback loops.

> **Sources**: Calibration xlsx files in `llrf/calibrations/` [R38]; `llrf/documentation/RfSystemDocumentIndexR3.xlsx` [R39] — Jim Sebek's master document index.

### 9.5 Performance Margins

The SPEAR3 RF system has significant performance margins:

| Parameter | Capacity | Typical Use | Margin |
|-----------|----------|-------------|--------|
| Klystron power | 1.2 MW | ~800 kW | ~50% |
| HVPS voltage | 90 kV | ~74 kV | ~22% |
| Gap voltage per cavity | 1 MV | ~712 kV | ~40% |
| Direct loop bandwidth | ~800 kHz (LLRF9: ~930 kHz) | — | — |
| Impedance reduction | ~40 dB | Required for Robinson stability | >10 dB margin |

These margins provide operational flexibility and resilience against component degradation.

---

## Appendix A — SPEAR3 RF System Parameter Table

This appendix consolidates all SPEAR3-specific numerical parameters referenced throughout this document.

### A.1 Storage Ring Parameters

| Parameter | Symbol | Value | Unit | Source |
|-----------|--------|-------|------|--------|
| Beam energy | E₀ | 3.0 | GeV | [R1] |
| Beam current (top-off) | I_b | 500 | mA | [R1] |
| Circumference | C | 234.14 | m | [R2] |
| Revolution frequency | f_rev | 1.2804 | MHz | Derived |
| Harmonic number | h | 372 | — | [R1] |
| RF frequency | f_RF | 476.3051755 | MHz | [R4] |
| Momentum compaction | α_c | 1.18 × 10⁻³ | — | [R2] |
| Energy loss per turn | U₀ | ~0.91 | MeV | [R1] |
| Synchrotron tune | ν_s | ~0.0073 | — | Derived |
| Synchrotron frequency | f_s | ~9.4 | kHz | Derived |

### A.2 Cavity Parameters (Per Cavity)

| Parameter | Symbol | Value | Unit | Source |
|-----------|--------|-------|------|--------|
| Resonant frequency | f₀ | 476.315 | MHz | [R6] |
| Shunt impedance (linac) | R_s | 3.73 | MΩ | [R6] |
| Shunt impedance (accel) | R_s | 7.5 | MΩ | [R6] |
| R/Q | R/Q | ~116 | Ω | [R7] |
| Unloaded Q | Q₀ | 32,000–33,500 | — | [R6] |
| Loaded Q | Q_L | 6,700–6,780 | — | [R6] |
| Coupling coefficient | β | 3.72–4.0 | — | [R6] |
| Cavity half-bandwidth | Δf₁/₂ | ~35.5 | kHz | Derived |
| Operational gap voltage | V_gap | ~712 | kV | [R5] |

### A.3 HVPS Parameters

| Parameter | Value | Unit | Source |
|-----------|-------|------|--------|
| Input voltage | 12,470 V RMS | L-L | [R22] |
| Output range | 0 to -90 kV | DC | [R21] |
| Maximum current | 27 A | DC | [R21] |
| Nominal operating voltage | -77 kV | DC | [R5] |
| Voltage regulation | <±0.5% | >65 kV | [R21] |
| Ripple | <1% P-P | >60 kV | [R21] |
| Arc energy (with crowbar) | <5 J | — | [R21] |

### A.4 Klystron Parameters

| Parameter | Value | Unit | Source |
|-----------|-------|------|--------|
| Type | Marconi/CPI K3512S | — | [R1] |
| Maximum power | 1.2 MW CW | — | [R1] |
| Gain | 43 dB min | — | [R1] |
| Bandwidth | 5 MHz | -3 dB | [R1] |
| Group delay | <150 ns | — | [R1] |
| Drive power | ~29 W | — | [R5] |
| Perveance | ~2.0 × 10⁻⁶ | A/V^(3/2) | [R23] |

### A.5 Feedback Loop Parameters

| Loop | Bandwidth | SPEAR3 Status | Source |
|------|-----------|---------------|--------|
| Direct | ~800 kHz | Active | [R14] |
| Comb | 2 MHz | Not used | [R14] |
| Ripple | ~300 Hz | Active | [R14] |
| Gap FF | 100 Hz | Not used | [R14] |
| HVPS | ~1 Hz | Active | [R14] |
| Tuner | ~0.01–1 Hz | Active | [R14] |
| DAC | ~0.1 Hz | Active | [R14] |
| LFB Woofer | 1 MHz | Not used | [R14] |

---

## Appendix B — Source Document Reference Index

All references cited in this document, organized by reference number.

### B.1 Published Papers and Conference Proceedings

| Ref | Citation |
|-----|---------|
| [R1] | McIntosh, P. et al., "The SPEAR3 RF System," SLAC-PUB-10983, presented at EPAC 2004, Lucerne, Switzerland. DOI: 10.2172/839730 |
| [R2] | Hettel, R. et al., "Design of the SPEAR 3 Light Source," presented at PAC 1999 |
| [R7] | Rimmer, R.A. et al., "RF Cavity Development for the PEP-II B Factory," LBL-33360, 1992 |
| [R8] | Rimmer, R.A. et al., "High-Power Testing of the First PEP-II RF Cavity," SLAC-PUB-7210 / LBNL-38147, June 1996 |
| [R9] | Goldberg, D.A. et al., "Measurement and Analysis of Higher-Order-Mode (HOM) Damping in B-Factory RF Cavities," Proc. PAC 1995 |
| [R13] | Boussard, D., "Control of Cavities with High Beam Loading," IEEE Trans. Nucl. Sci. NS-32, PAC 1985 |
| [R15] | Corredoura, P., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8124, PAC 1999 |
| [R16] | Robinson, K.W., "Stability of Beam in Radiofrequency Systems," CEA Report CEAL-1010, 1964 |
| [R17] | Rimmer, R.A. et al., "Comparison of Calculated, Measured, and Beam Sampled Impedances of a HOM-Damped RF Cavity," Phys. Rev. ST Accel. Beams 3, 102001, 2000 |
| [R21] | Cassel, R. and Nguyen, M.N., "A Unique Power Supply for the PEP II Klystron at SLAC," SLAC-PUB-7591, PAC 1997 |
| [R25] | Bourbeau, E.J., "Application of PLL Controlled Phase Angle Regulating Techniques to SCR AC and DC Motor Drives," IEEE 1983 |

### B.2 Textbooks and General References

| Ref | Citation |
|-----|---------|
| [R3] | SSRL SPEAR3 Accelerator Parameters page, https://www-ssrl.slac.stanford.edu/ssrl/web/node/15 |
| [R10] | Wiedemann, H., *Particle Accelerator Physics*, 4th ed., Springer, 2015 |
| [R11] | Gamp, A., "Beam-Cavity Interaction," CERN Accelerator School, CAS 2011, arXiv:1112.3203 |
| [R12] | Wilson, P.B., "Fundamental-Mode RF Design in e⁺e⁻ Storage Ring Factories," SLAC-PUB-6062, 1993 |
| [R18] | Analog Devices AD834 datasheet, 500 MHz four-quadrant multiplier |

### B.3 Original Engineering Documents in Repository

| Ref | Document | Repository Path |
|-----|----------|----------------|
| [R4] | LLRF9 Commissioning Tests (J. Sebek, 2021) | `llrf/tests/llrf9Tests.pdf` |
| [R4t] | LLRF9 Tests LaTeX source | `llrf/tests/llrf9Tests.tex` |
| [R5] | SPEAR3 LLRF System Design Report (PDR R1) | `Designs/0_SYSTEM_DESIGN_REPORT.md` and `Designs/docx/SPEAR3_LLRF_PDR_R1.docx` |
| [R6] | PEP-II RF System Description (Schwarz, PS-340-330-51-R0) | `llrf/documentation/legacyArchitecture/ps3403305100.pdf` |
| [R6t] | Transcription of [R6] | `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PS-340-330-51_RF_System_Description.md` |
| [R14] | LLRF Feedback Loop Description (Schwarz, PS-340-330-52-R0) | `llrf/documentation/legacyArchitecture/feedbackLoopDescriptionps3403305200.pdf` (= `ps3403305200.pdf`) |
| [R14t] | Transcription of [R14] | `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md` |
| [R15t] | Transcription of Corredoura PAC99 | `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/conference-papers/Architecture_and_Performance_PEP-II_LLRF.md` |
| [R19] | Comprehensive FBK Loops Description | `llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/design-specifications/PEPII_LLRF_FBK_Loops_Description.md` |
| [R21t] | Transcription of SLAC-PUB-7591 | `hvps/architecture/originalDocuments/transcriptions/slac-pub-7591_transcription.md` |
| [R22] | PEP-II HVPS Technical Specification (PS-341-360-01-R2) | `hvps/architecture/originalDocuments/ps3413600102.pdf` |
| [R22t] | Transcription of [R22] | `hvps/architecture/originalDocuments/transcriptions/ps3413600102_transcription.md` |
| [R23] | HVPS Simulation Configuration | `hvps/simulation/hvps_sim/config.py` |
| [R24t] | PEP-II Supply Presentation Transcription | `hvps/architecture/originalDocuments/transcriptions/pepII_supply_transcription.md` |
| [R26] | Enerpro FCOG1200 Operating Manual | `hvps/controls/enerpro/enerproDocuments/OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.pdf` |
| [R27] | Cassel PLC Code | `hvps/documentation/plc/CasselPLCCode.pdf` |
| [R28] | Cassel PLC Symbol Database | `hvps/documentation/plc/CasselSymbolDatabase.pdf` |
| [R29] | SLO-SYN Motor Manual | `llrf/tuners/SLO-SYN.pdf` |
| [R30] | SLO-SYN MD808 Stepper Drive Manual | `llrf/tuners/SLO-SYN_MD808_Stepper_Drive_Manual.pdf` |
| [R31] | SLO-SYN SS2000MD4M Manual | `llrf/tuners/SLO-SYN_SS2000MD4M_Step_Drive_Translator_Manual.pdf` |
| [R32] | Galil DMC-4103 Manual | `llrf/tuners/galil/dmc-4103-r13h-manual.pdf` |
| [R33] | Cavity Tuner Inspections (2023) | `llrf/tuners/cavityTunerInspections20230613.docx` |
| [R34] | Legacy Tuner Loop Source Code | `spear-rf-code-legacy/rfApp/src/seq/rf_tuner_loop.st` |
| [R35] | Galil Commissioning Notes | `llrf/tuners/galil/GalilCommissioning.docx` |
| [R36] | DSP Ripple Firmware Source | `spear-rf-code-legacy/dsp1610/rfpDsp/ripple.s`, `sp3ripple.s` |
| [R37] | LLRF9 Test Graphics | `llrf/tests/graphics/` (13 PDF files) |
| [R38] | RF Calibration Data | `llrf/calibrations/*.xlsx` (6 files) |
| [R39] | Jim Sebek's RF System Document Index | `llrf/documentation/RfSystemDocumentIndexR3.xlsx` |

### B.4 AI-Generated Analysis Products (Consulted, Unreviewed)

The following AI-generated technical notes were consulted during preparation of this document as preliminary analysis aids. They are **not cited as authoritative sources** per the Documentation Architecture Proposal §2.4.

| File | Subsystem | Notes |
|------|-----------|-------|
| `llrf/documentation/legacyArchitecture/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md` | LLRF | Detailed reconstruction of feedback loop architecture |
| `hvps/controls/enerpro/technical-notes/06-control-theory.md` | HVPS | Enerpro PLL control theory analysis |
| `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md` | Code | DSP firmware algorithm analysis |
| `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md` | HVPS | Legacy HVPS system design overview |
| `hvps/architecture/technical-notes/01-pepii-power-supply-architecture.md` | HVPS | PEP-II power supply architecture |

### B.5 External Web References

| Ref | URL | Content |
|-----|-----|---------|
| [W1] | https://inspirehep.net/files/945e7ff73cc428af4c018fd1bdb6afa7 | McIntosh et al. EPAC04 full text |
| [W2] | https://www.osti.gov/biblio/839730 | OSTI record for SLAC-PUB-10983 |
| [W3] | https://export.arxiv.org/pdf/1112.3203v1.pdf | Gamp, "Beam-Cavity Interaction," CAS 2011 |
| [W4] | https://www.dimtel.com/products/llrf9 | Dimtel LLRF9 product page |
| [W5] | https://www.dimtel.com/products/specs/llrf9_500 | LLRF9/500 specifications |
| [W6] | https://proceedings.jacow.org/p85/PDF/PAC1985_1852.PDF | Boussard, "Control of Cavities with High Beam Loading" |
| [W7] | https://www.osti.gov/biblio/808721 | SPEAR 3 Design Report (Hettel, 2002) |

---

## Appendix C — Symbol and Notation Conventions

### C.1 Frequently Used Symbols

| Symbol | Definition | Typical Unit |
|--------|-----------|-------------|
| f₀, ω₀ | Cavity resonant frequency | MHz, rad/s |
| f_RF, ω_RF | RF operating frequency | MHz, rad/s |
| f_rev, ω_rev | Revolution frequency | MHz, rad/s |
| f_s, ω_s | Synchrotron frequency | kHz, rad/s |
| Q₀ | Unloaded quality factor | dimensionless |
| Q_L | Loaded quality factor | dimensionless |
| Q_ext | External (coupling) quality factor | dimensionless |
| β | Coupling coefficient = Q₀/Q_ext | dimensionless |
| R_s | Shunt impedance | MΩ |
| R_L | Loaded shunt impedance = R_s/(1+β) | kΩ |
| V_gap | Gap voltage per cavity | kV |
| I_b | DC beam current | mA or A |
| φ_s | Synchronous phase angle | degrees |
| ψ | Detuning angle | degrees |
| Δf | Frequency detuning = f₀ - f_RF | kHz |
| α_c | Momentum compaction factor | dimensionless |
| E₀ | Beam energy | GeV |
| U₀ | Energy loss per turn | MeV |
| τ_d | Total loop delay | ns |
| G | Gain (various loops) | dB or dimensionless |
| I, Q | In-phase and Quadrature components | V (baseband) |

### C.2 Conventions

1. **Shunt impedance convention**: This document uses the **linac convention** (R_s = V²/2P) unless explicitly stated otherwise. The accelerator convention (R_s = V²/P) gives values exactly 2× larger.

2. **Phase convention**: Positive phase angles represent phase advance (counter-clockwise rotation in the I/Q plane). The synchronous phase φ_s is measured from the zero-crossing of the RF voltage.

3. **Frequency detuning**: Δf = f₀ - f_RF. Negative detuning (Δf < 0) means the cavity resonant frequency is below the RF frequency, which is the normal operating condition for beam loading compensation above transition.

4. **Reference tag format**: [Rn] for numbered references, [Rnt] for transcription of the same source, [Wn] for web references.

---

*End of Document*

**Document Control**:
- This document is the Tier 1 RF physics reference for the SPEAR3 LLRF system.
- The definitive version is `Designs/P_RF_PHYSICS_AND_PLANT.md` in the `spearlegacyLLRF` repository.
- **Provenance**: AI-ASSISTED — structure and content proposed by AI based on exhaustive review of original source documents, published papers, and web research. Subject to human review and approval by a named engineer.
- **Review status**: UNREVIEWED — requires verification of all equations, parameters, and physical arguments against original source documents by a qualified RF engineer.
