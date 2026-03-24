# SPEAR3 RF System — RF Physics, Control Theory and Physical Plant

**Document ID**: Doc P
**Version**: 2.0
**Date**: March 24, 2026
**Status**: DRAFT — For Engineering Review
**Location**: Designs/P_RF_PHYSICS_AND_PLANT.md
**Author**: Faya Wang, with AI-assisted analysis
**Tier**: 1 — Physics and Plant Reference (implementation-independent)

---

## Revision History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | 2026-03-24 | Initial draft: nine-section catalog structure. |
| 2.0 | 2026-03-24 | Major rewrite: restructured around disturbance-driven control design philosophy. Added comprehensive mathematical formulations. New §4 (Disturbance Analysis) and §5 (Control Architecture) establish causal chain from disturbances to loop architecture. Strengthened transfer function derivations, beam loading phasor analysis, Robinson stability criteria, and quantitative disturbance rejection calculations throughout. |

---

## Table of Contents

1. [System Overview and Field Stability Requirements](#1-system-overview-and-field-stability-requirements)
2. [Plant Physics Model](#2-plant-physics-model)
3. [I/Q Signal Processing Framework](#3-iq-signal-processing-framework)
4. [Disturbance Analysis and Control Problem Statement](#4-disturbance-analysis-and-control-problem-statement)
5. [Control Architecture: From Disturbances to Loops](#5-control-architecture-from-disturbances-to-loops)
6. [Loop-by-Loop Transfer Functions and Design](#6-loop-by-loop-transfer-functions-and-design)
7. [HVPS Plant Model and Dynamics](#7-hvps-plant-model-and-dynamics)
8. [Tuner Mechanics and Resonant Frequency Control](#8-tuner-mechanics-and-resonant-frequency-control)
9. [Performance Requirements and Verification](#9-performance-requirements-and-verification)

Appendices:
- [Appendix A — SPEAR3 RF System Parameter Table](#appendix-a--spear3-rf-system-parameter-table)
- [Appendix B — Source Document Reference Index](#appendix-b--source-document-reference-index)
- [Appendix C — Symbol and Notation Conventions](#appendix-c--symbol-and-notation-conventions)

---

## Document Scope and Provenance

### Purpose

This document is the **Tier 1 physics and plant reference** for the SPEAR3 RF system. It describes the RF physics, control theory, and physical plant parameters that are **independent of the specific control hardware implementation**. The content does not change when VXI hardware is replaced with the LLRF9 controller — it describes the *why* behind the control system design.

The central thesis of this document is:

> **The SPEAR3 LLRF control architecture is uniquely determined by the disturbance landscape of the RF plant.** Each feedback loop exists because a specific class of disturbance threatens RF field stability, and the loop's bandwidth and gain are set by the magnitude and frequency content of that disturbance. Understanding the disturbances is therefore the key to understanding the control design.

### Provenance Statement

All technical content is derived from **original source documents** per the Documentation Architecture Proposal (v5.1, §2.1):
- Published SLAC technical papers and conference proceedings
- Original engineering specifications and design documents
- Measurement data from actual hardware
- Legacy source code implementing the physics algorithms
- Standard textbook references in accelerator physics and RF engineering
- External web research with full bibliographic citations

AI-generated technical notes are cited parenthetically as *"preliminary analysis (AI-generated, see [filename], unreviewed)"* per §2.4.

---

## 1. System Overview and Field Stability Requirements

### 1.1 The Control Problem in One Sentence

The SPEAR3 RF system must deliver a 476.3 MHz accelerating voltage of ~2.85 MV across four cavities with amplitude stability better than 0.1% RMS and phase stability better than 0.1° RMS, in the presence of beam loading forces that—without feedback—would drive the system unstable within microseconds.

### 1.2 Storage Ring Parameters

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| Beam energy | E₀ | 3.0 | GeV |
| Beam current (top-off) | I_b | 500 | mA |
| Circumference | C | 234.14 | m |
| Revolution frequency | f_rev | 1.2804 | MHz |
| Revolution period | T_rev | 0.781 | μs |
| Harmonic number | h | 372 | — |
| RF frequency | f_RF | 476.3051755 | MHz |
| Momentum compaction | α_c | 1.18 × 10⁻³ | — |
| Energy loss per turn | U₀ | ~0.91 | MeV |
| Total accelerating voltage | V_RF | ~2.85 | MV |
| Synchrotron frequency | f_s | ~9.4 | kHz |
| Radiation damping time | τ_rad | ~5 | ms |

> **Sources**: [R1] McIntosh et al., "The SPEAR3 RF System," SLAC-PUB-10983, EPAC 2004. [R2] Hettel et al., "Design of the SPEAR 3 Light Source," PAC 1999. [R5] `Designs/0_SYSTEM_DESIGN_REPORT.md`.

### 1.3 RF System Configuration

The RF station consists of: a single 1.2 MW CW klystron (Marconi/CPI K3512S) → waveguide circulator → 3×Magic-Tee power splitter → four PEP-II-type single-cell HOM-damped copper cavities. A single I/Q modulator at the klystron input is the primary actuator for all fast feedback loops.

This architecture was inherited directly from the PEP-II B-Factory at SLAC (1996–2008), which ran 5–7 such stations simultaneously. SPEAR3 uses only one station, which simplifies coordination but does not change the fundamental physics.

> **Sources**: [R1]; [R6] Schwarz, H., "PEP-II RF System Description," PS-340-330-51-R0, 1999.

### 1.4 Field Stability Requirements

The field stability requirements derive from the storage ring's requirements for photon beam stability:

| Parameter | Requirement | Typical Achieved | Rationale |
|-----------|------------|-----------------|-----------|
| Amplitude stability | <0.1% RMS | <0.05% RMS | Photon beam position, energy spread |
| Phase stability | <0.1° RMS | <0.05° RMS | Bunch timing, longitudinal emittance |
| HVPS voltage regulation | <±0.5% | <±0.3% | Klystron gain/phase stability |
| HVPS ripple | <1% P-P | <0.5% P-P | RF phase modulation budget |

These requirements define the *minimum disturbance rejection* the control system must provide. The rest of this document shows how the disturbance landscape determines the control architecture that achieves these specifications.

> **Sources**: [R5]; [R4] LLRF9 Commissioning Tests, `llrf/tests/llrf9Tests.pdf`.

---

## 2. Plant Physics Model

This section derives the mathematical models of the three physical subsystems that the LLRF controller must regulate: the RF cavity, the klystron amplifier, and the HVPS. Together, these form the "plant" in the control-theoretic sense.

### 2.1 RF Cavity as a Narrowband Resonator

#### 2.1.1 Equivalent Circuit

Near its fundamental mode at omega_0 = 2*pi * 476.3 MHz, each cavity is modeled as a parallel RLC circuit. The cavity parameters (per cavity, linac convention R_s = V^2/2P):

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| Resonant frequency | f_0 | 476.315 | MHz |
| Shunt impedance | R_s | 3.73 | MOhm |
| Unloaded Q | Q_0 | 32,000 | -- |
| Loaded Q | Q_L | 6,700 | -- |
| Coupling coefficient | beta = Q_0/Q_ext | 3.72 | -- |

> **Sources**: [R6] Schwarz parameter table; [R7] Rimmer et al., "RF Cavity Development for the PEP-II B Factory," LBL-33360.

#### 2.1.2 Cavity Transfer Function

The cavity voltage response to a driving current, in the Laplace domain near resonance:

```
    H_cav(s) = R_s * omega_half / (s + omega_half + j*Delta_omega)
```

where omega_half = omega_0/(2*Q_L) is the cavity half-bandwidth in angular frequency. Using the narrowband approximation (|Delta_omega| << omega_0), the **impedance as seen by the beam** at angular frequency offset Delta_omega from the RF frequency:

```
    Z_cav(Delta_omega) = R_s / (1 + j*2*Q_L*Delta_omega/omega_0)     ... (Eq. 2.1)
```

**Numerical evaluation** of the cavity half-bandwidth:

```
    Delta_f_half = f_0/(2*Q_L) = 476.315 MHz / (2 * 6,700) = 35.5 kHz
```

This 35.5 kHz bandwidth is the fundamental frequency scale of the cavity: it determines (a) the natural response time of the cavity (~4.5 us = 1/(2*pi*35.5 kHz)), and (b) the frequency range over which the cavity presents significant impedance to the beam. Disturbances slower than ~35 kHz are not filtered by the cavity and must be actively rejected by feedback.

#### 2.1.3 Beam Loading -- Steady-State Phasor Analysis

When a beam of DC current I_b traverses the cavity, each bunch deposits energy that excites the fundamental mode. The beam-induced voltage at resonance is:

```
    V_b,res = I_b * R_s = 0.5 A * 3.73 MOhm = 1.865 MV             ... (Eq. 2.2)
```

This exceeds the desired gap voltage (712 kV), demonstrating that **beam loading is the dominant effect** in this system. The total cavity voltage is the phasor sum:

```
    V_cav = V_gen + V_beam                                           ... (Eq. 2.3)
```

**Synchronous phase** -- determined by the equilibrium condition:

```
    e * V_RF * sin(phi_s) = U_0
    sin(phi_s) = 0.91 MeV / 2.85 MV = 0.319
    phi_s = 71.4 deg  (above transition)                             ... (Eq. 2.4)
```

**Optimum detuning** -- minimizes reflected power at the input coupler:

```
    tan(psi_opt) = -I_b * R_s * sin(phi_s) / V_gap                  ... (Eq. 2.5)

    Numerical: tan(psi_opt) = -(0.5 * 3.73e6 * 0.948) / 712e3 = -2.49
    psi_opt = -68 deg
```

**Optimum frequency detuning:**

```
    Delta_f_opt = f_0 * tan(psi_opt) / (2*Q_L)                      ... (Eq. 2.6)
               = 476.3 MHz * (-2.49) / (2 * 6,700) = -88.6 kHz
```

The cavity must be tuned ~89 kHz **below** the RF frequency at 500 mA. This detuning varies linearly with beam current; the tuner control loop (Sec. 8) tracks it continuously.

**Required generator power per cavity:**

```
    P_gen = V_gap^2/(4*R_L) * [1 + (I_b*R_s*sin(phi_s)/V_gap)^2]^(1/2)
            + I_b*V_gap*cos(phi_s)/n_cav                             ... (Eq. 2.7)

    where R_L = R_s/(1+beta) = 790 kOhm

    = 68 kW (wall) + 59 kW (beam) + losses = 135 kW/cavity
    Total for 4 cavities: ~540 kW (within 1.2 MW klystron capacity)
```

> **Sources**: [R11] Gamp, "Beam-Cavity Interaction," CAS 2011, arXiv:1112.3203. [R12] Wilson, "Fundamental-Mode RF Design," SLAC-PUB-6062. [R13] Boussard, "Control of Cavities with High Beam Loading," PAC 1985.

### 2.2 Klystron as the Actuator

The klystron amplifies the LLRF drive signal to the power level needed by the cavities. For control analysis, it is modeled as:

```
    G_kly(s) = K_kly * exp(-s*tau_kly)                               ... (Eq. 2.8)

    where:
      K_kly = G_linear for P_in << P_sat (linear regime)
      tau_kly < 150 ns (group delay)
```

| Parameter | Value | Unit |
|-----------|-------|------|
| Maximum output power | 1.2 MW | CW |
| Typical operating power | ~800 kW | -- |
| Gain | 43 dB (min) | -- |
| Bandwidth | 5 MHz | -3 dB |
| Group delay | <150 ns | -- |
| Perveance | ~2.0e-6 | A/V^(3/2) |
| Drive power for max output | ~29 W | -- |

**Saturation model** -- The klystron output follows an approximately logistic curve:

```
    P_out = P_sat * (P_in/P_in,sat) / (1 + P_in/P_in,sat)          ... (Eq. 2.9)
```

The HVPS loop maintains the operating point at ~10% below saturation, ensuring the small-signal gain seen by the fast feedback loops remains approximately constant. As the operating point moves along the saturation curve, the small-signal gain varies by up to ~7 dB over the full operating range.

**AM-PM conversion** -- The klystron output phase depends on the cathode voltage (velocity modulation). A change Delta_V_k in cathode voltage produces a phase shift:

```
    Delta_phi_kly ~ Delta_V_k / V_k                                  ... (Eq. 2.10)
```

This phase sensitivity is the mechanism by which HVPS ripple couples into the RF field.

> **Sources**: [R1]; [R15] Corredoura, PAC 1999; `Designs/0_SYSTEM_DESIGN_REPORT.md` Sec.4-5 [R5].

### 2.3 Loop Delay Budget -- The Fundamental Bandwidth Ceiling

The maximum bandwidth of any feedback loop is limited by the total signal propagation delay around the loop. For a system with total loop delay tau_d, the maximum stable crossover frequency (with ~45 deg phase margin) is:

```
    f_c,max = 1/(4*tau_d)                                            ... (Eq. 2.11)
```

This is the single most important constraint in the entire control design.

**Loop delay budget:**

| Component | Legacy (analog) | LLRF9 (digital) |
|-----------|----------------|----------------|
| Klystron group delay | <150 ns | <150 ns |
| I/Q modulator | <5 ns | <5 ns |
| Cable propagation | ~50 ns | ~50 ns |
| Electronics/computation | ~300 ns | ~65 ns |
| **Total tau_d** | **~500 ns** | **~270 ns** |
| **f_c,max** | **~500 kHz** | **~930 kHz** |

The LLRF9 digital system nearly doubles the achievable control bandwidth, which directly translates to better disturbance rejection at higher frequencies.

### 2.4 Complete Open-Loop Plant Transfer Function

The complete forward path from I/Q modulator output to cavity voltage measurement is:

```
    G_plant(s) = G_IQmod * G_kly(s) * H_cav(s) * G_probe * exp(-s*tau_cable)

    Simplifying (gain terms absorbed into G_0):

    G_plant(s) = G_0 * H_cav(s) * exp(-s*tau_d)

               = G_0 * omega_half / (s + omega_half + j*Delta_omega) * exp(-s*tau_d)
                                                                      ... (Eq. 2.12)
```

This is the transfer function that every feedback loop must work with. The cavity bandwidth (35.5 kHz) and the loop delay (270-500 ns) together define the limits of what feedback can achieve.

---

## 3. I/Q Signal Processing Framework

### 3.1 Baseband I/Q Representation

All RF feedback loops use baseband In-phase and Quadrature (I/Q) techniques. An RF signal with slowly-varying amplitude A(t) and phase phi(t):

```
    V_RF(t) = A(t)*cos(omega_RF*t + phi(t))
            = I(t)*cos(omega_RF*t) - Q(t)*sin(omega_RF*t)

    where:  I(t) = A(t)*cos(phi(t))    (In-phase)
            Q(t) = A(t)*sin(phi(t))    (Quadrature)
```

The inverse relations:

```
    A(t) = sqrt(I^2 + Q^2)         (Amplitude)
    phi(t) = atan2(Q, I)           (Phase)
```

**Advantages of I/Q for RF control** [R15]:
1. I and Q channels use **identical electronics** (unlike amplitude/phase systems)
2. All modulation information is preserved in baseband (DC to ~few MHz)
3. Phase shifts applied **without step discontinuities** (unlike RF phase shifters)
4. Full 360-degree vector rotation achievable continuously

### 3.2 Baseband I/Q Modulator

The I/Q modulator is the central actuator. It performs a scaled rotation:

```
    | I_out |       | cos(theta)  -sin(theta) | | I_in |
    |       | = G * |                         | |      |   ... (Eq. 3.1)
    | Q_out |       | sin(theta)   cos(theta) | | Q_in |
```

**Implementation**: Four AD834 four-quadrant multipliers + two EL2073 summing amplifiers.
- Group delay: <5 ns
- Full-power bandwidth: >40 MHz
- Dynamic range: >50 dB
- Multiplier weights set by 12-bit DAC channels (AD7805)
- Total system: 7 I/Q modulators, 56 "slow" DAC channels

> **Sources**: [R15] Corredoura, Eq. 2, Fig. 5; [R14] Schwarz, PS-340-330-52-R0.

### 3.3 I/Q Demodulation

RF signals from cavity probes, klystron forward power, and measurement points are converted to baseband I/Q using +13 dBm I/Q demodulators. Outputs:
- AC-coupled into 50 Ohm, low-pass filtered (F_c = 225 MHz)
- Video amplifiers: 17 dB gain, producing +/-1 V maximum I/Q signals
- The +/-1 V level matches the AD834 multiplier input specification

### 3.4 Cavity Probe Vector Sum

Each of the 4 cavity probe signals is demodulated to I/Q and passed through a programmable combining network (4 I/Q modulators + 2 summing amplifiers). The DAC weights produce the **total accelerating RF vector** for the station.

The combining weights account for: coupling coefficient differences, waveguide path length offsets, and probe calibration. A MATLAB routine ("Tune Cavs") establishes correct weights by measuring individual cavity resonance responses.

### 3.5 Error Signal Generation

The direct RF feedback error signal:

```
    E_vec = V_ref - V_probe                                          ... (Eq. 3.2)

    where:
      E_vec = (E_I, E_Q) = error vector
      V_ref = reference setpoint (from DAC Loop)
      V_probe = measured cavity field (from vector sum)
```

This error drives the I/Q modulator:

```
    V_drive = G_loop * E_vec = G_loop * (V_ref - V_probe)           ... (Eq. 3.3)
```

where G_loop is the open-loop gain (complex, frequency-dependent). This is a classical proportional feedback structure on a 2D (I/Q) vector.

> **Sources**: [R15]; [R14].

---

## 4. Disturbance Analysis and Control Problem Statement

This section enumerates every disturbance source that threatens RF field stability, quantifies each one, and establishes the control requirements that determine the feedback loop architecture. **The control architecture follows inevitably from this disturbance landscape.**

### 4.1 Disturbance Taxonomy

| # | Disturbance | Source | Frequency | Magnitude | Impact |
|---|-------------|--------|-----------|-----------|--------|
| D1 | Beam loading (steady-state) | Average beam current | DC | V_b = 1.865 MV/cavity | Dominates cavity voltage budget |
| D2 | Beam loading (transient) | Bunch-by-bunch current variation, injection, ion clearing gap | DC to ~100 kHz | Growth rates < T_rev | Longitudinal instability |
| D3 | Robinson instability | Impedance asymmetry at synchrotron sidebands | f_s ~ 9.4 kHz | Exponential growth | Beam loss |
| D4 | Coupled-bunch modes | Cavity fundamental impedance at revolution harmonics | n*f_rev (1.28 MHz) | Growth rate ~ 1/tau_cb | Beam oscillation |
| D5 | HVPS ripple | 12-pulse SCR rectifier | 360, 720, 1080... Hz | <1% P-P voltage | Phase modulation via AM-PM |
| D6 | Klystron gain drift | Operating point shift with beam current | ~0.01-1 Hz | up to 7 dB | Loop gain variation |
| D7 | Microphonics | Mechanical vibration of cavity body | 1-300 Hz | Delta_f ~ 1-10 Hz | Cavity detuning |
| D8 | Thermal detuning | Cavity temperature change | <0.01 Hz | Delta_f ~ 1-100 Hz | Slow frequency drift |

### 4.2 D1/D2: Beam Loading -- The Dominant Disturbance

Beam loading is the single largest disturbance. At 500 mA, the beam-induced voltage (1.865 MV per cavity) exceeds the desired gap voltage (712 kV) by a factor of 2.6 (Eq. 2.2). The generator must supply enough power to both maintain the gap voltage and compensate the beam-induced voltage.

**Transient beam loading** occurs when the beam current changes rapidly -- during injection, due to the ion clearing gap (~5% of buckets empty), or from bunch-to-bunch current variations. These transients excite the cavity fundamental mode at rates determined by the cavity bandwidth and beam spectrum.

**Growth rate for coupled-bunch instability** from the fundamental cavity mode [R15]:

```
    1/tau = (I_b * eta * f_RF) / (2 * nu_s * beta^2 * E/e) * R_cb   ... (Eq. 4.1)

    where:
      I_b = 500 mA (DC beam current)
      eta = alpha_c = 1.18e-3 (momentum compaction, above transition)
      f_RF = 476.3 MHz
      nu_s = 0.0073 (synchrotron tune)
      beta = 1 (ultra-relativistic)
      E/e = 3.0 GV
      R_cb = sum of Re{Z(omega_RF + n*omega_rev + omega_s) - Z(omega_RF + n*omega_rev - omega_s)}
```

For the most dangerous mode (n=0, the Robinson mode), R_cb is dominated by the impedance difference at the two synchrotron sidebands nearest the cavity resonance peak. **Without feedback**, the peak cavity impedance of ~750 kOhm at the detuned frequency (Fig. 3 of Corredoura [R15]) produces growth rates that can be faster than one revolution period (~0.78 us).

This single fact -- **growth rates less than T_rev** -- drove the PEP-II system design to include multiple RF feedback loops [R15].

> **Sources**: [R15] Corredoura, PAC 1999, Eq. 1; [R11] Gamp, CAS 2011, Sec. 4.

### 4.3 D3: Robinson Instability

The Robinson instability arises from the asymmetry of the effective cavity impedance at the upper and lower synchrotron sidebands of the RF frequency.

**Robinson stability criterion** (above transition energy):

```
    Re{Z_eff(omega_RF + omega_s)} < Re{Z_eff(omega_RF - omega_s)}   ... (Eq. 4.2)
```

When the cavity is detuned below the RF frequency for beam loading compensation (Sec. 2.1.3), the impedance peak shifts toward the lower sideband, naturally satisfying this criterion for the monopole mode. However, the impedance at revolution harmonics near the cavity peak can violate this condition for higher-order coupled-bunch modes.

**Robinson growth rate:**

```
    1/tau_Rob = (alpha_c * omega_rev * I_b) / (4 * omega_s * E/e)
                * [Re{Z(omega_RF + omega_s)} - Re{Z(omega_RF - omega_s)}]
                                                                      ... (Eq. 4.3)
```

Direct RF feedback reduces the effective impedance Z_eff = Z_cav/(1 + G_OL) (Sec. 5.2), which reduces the impedance asymmetry and hence the growth rate by the same factor as the impedance reduction.

> **Sources**: [R16] Robinson, CEA Report CEAL-1010, 1964; [R11] Gamp, CAS 2011; [R13] Boussard, PAC 1985; Chang et al., "Study of Direct RF Feedback with the Pedersen Model," NSRRC.

### 4.4 D4: Coupled-Bunch Modes

For a storage ring with harmonic number h = 372, there are 372 coupled-bunch modes. Each mode m is driven by the real impedance difference at the revolution harmonics nearest the cavity resonance:

```
    1/tau_m = (alpha_c * omega_rev * I_b) / (4 * omega_s * E/e)
              * sum_p [Re{Z((ph + m)*omega_rev + omega_s)} - Re{Z((ph + m)*omega_rev - omega_s)}]
                                                                      ... (Eq. 4.4)
```

For SPEAR3 (C = 234.14 m, f_rev = 1.28 MHz), revolution harmonics are widely spaced relative to the cavity bandwidth (35.5 kHz). Only a few revolution harmonics interact strongly with the fundamental cavity mode. This is a significant advantage over PEP-II (C = 2199.3 m, f_rev = 136 kHz), where dozens of revolution harmonics fell within the cavity bandwidth.

**Consequence for SPEAR3**: The comb filter (essential for PEP-II) is **not needed** at SPEAR3. The direct feedback loop alone provides sufficient impedance reduction at the few relevant revolution harmonics.

> **Sources**: [R15] Corredoura, PAC 1999; [R11] Gamp, CAS 2011, Sec. 5.

### 4.5 D5: HVPS Ripple

The 12-pulse SCR rectifier produces voltage ripple at harmonics of 12 * f_line:

```
    f_ripple = 12*n*f_line = 720, 1440, 2160, ... Hz                ... (Eq. 4.5)

    Typical amplitude: <1% peak-to-peak of V_HVPS at >60 kV
```

However, due to imperfect balance in the 12-pulse transformer, lower harmonics are also present:

```
    f_residual = 60, 120, 180, 240, 300, 360 Hz  (reduced by ~20 dB relative to 720 Hz)
```

This ripple couples to the RF field through the klystron AM-PM conversion (Eq. 2.10):

```
    Delta_phi_RF ~ (dP_kly/dV_k) * Delta_V_ripple / P_kly           ... (Eq. 4.6)
```

The ripple frequency content (60-2000 Hz) falls well within the direct loop bandwidth, so the direct loop provides ~40 dB of passive rejection. The dedicated ripple loop provides additional targeted rejection of the dominant harmonics.

> **Sources**: [R21] Cassel and Nguyen, SLAC-PUB-7591; [R22] PS-341-360-01-R2; *Preliminary analysis (AI-generated, see `llrf/documentation/legacyArchitecture/technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md`, unreviewed)*.

### 4.6 D6: Klystron Gain Variation

As beam current increases, the HVPS loop raises the klystron cathode voltage to maintain the operating point near saturation. This changes:
1. Small-signal gain -- varies by up to 7 dB over the operating range
2. AM-PM conversion coefficient
3. Group delay (weakly)

If uncompensated, these variations change the open-loop gain G_OL, which changes the stability margins and disturbance rejection of the direct feedback loop. The gain tracking function (Sec. 6.4) compensates by adjusting the I/Q modulator weights.

### 4.7 D7/D8: Microphonics and Thermal Detuning

Mechanical vibrations of the cavity structure cause small frequency shifts (microphonics). For the PEP-II copper normal-conducting cavities used at SPEAR3, microphonic effects are small (<10 Hz peak frequency excursion) because:
1. Normal-conducting cavities have much lower Q (~6,700) than superconducting cavities (~10^9)
2. The cavity bandwidth (35.5 kHz) is >> microphonic excursions
3. The massive copper structure has low mechanical susceptibility

Thermal detuning is more significant: the cavity resonant frequency shifts with body temperature at a rate of approximately -1 kHz/degC (from thermal expansion of the copper cavity walls). The LCW cooling system maintains cavity body temperature at ~35 degC. During power-up transients, frequency drifts of 10-100 Hz occur over timescales of minutes to hours.

The tuner loop (Sec. 8) tracks both microphonics and thermal detuning by adjusting the mechanical plunger position.

### 4.8 Frequency-Domain Summary: The Disturbance Spectrum

Collecting all disturbances onto a single frequency axis reveals the control design requirements:

```
    Frequency (Hz)    Disturbance                  Required Loop
    ============================================================================
    0.001 - 0.01      Thermal drift (D8)           Tuner loop (~0.01-1 Hz)
    0.01 - 1          Klystron gain drift (D6)     HVPS loop (~1 Hz), DAC loop (0.1 Hz)
    1 - 10            Slow mechanical (D7)         Tuner loop
    60 - 2000         HVPS ripple (D5)             Ripple loop (300 Hz) + Direct loop
    10^3 - 10^5       Beam transients (D2)         Direct loop (~800 kHz)
    ~9.4 kHz          Robinson instability (D3)    Direct loop (impedance reduction)
    ~1.28 MHz         Coupled-bunch modes (D4)     Direct loop (+ Comb in PEP-II)
    ============================================================================
```

**This table is the Rosetta Stone of the control design.** Each feedback loop exists because one or more disturbances occupy a specific frequency band. The loop's bandwidth is matched to the disturbance spectrum. The loop's gain is set by the required rejection ratio. The loops are separated in bandwidth by factors of 10x or more to prevent interaction.

The rest of this document derives each loop's design from the entries in this table.

---

## 5. Control Architecture: From Disturbances to Loops

This section shows how the specific loop architecture follows inevitably from the disturbance spectrum of Section 4. The design logic is:

1. **Identify the fastest disturbance** -- beam loading transients with growth rates < T_rev
2. **Design the fastest loop** -- the Direct Loop, bandwidth limited by tau_d
3. **Identify disturbances the fastest loop cannot handle** -- too-narrow-band (revolution harmonics) or too slow (thermal drift)
4. **Add auxiliary loops** -- each targeting specific disturbance bands with appropriate bandwidth

### 5.1 The Design Logic: Bandwidth Matching

The fundamental principle is **match the loop bandwidth to the disturbance frequency content**:

```
    Required loop gain at frequency f = |Disturbance(f)| / |Tolerance(f)|

    Loop bandwidth >= highest disturbance frequency requiring active rejection
```

For the SPEAR3 system, this produces the following hierarchy:

```
    DAC Loop (0.1 Hz)  <<  HVPS/Tuner (~1 Hz)  <<  Ripple (300 Hz)
                       <<  Direct Loop (~800 kHz)  <<  [Comb (2 MHz, not used)]
```

The bandwidth separation between adjacent loops (factors of 10x-1000x) provides natural frequency-domain decoupling, which is the key to multi-loop stability (Sec. 5.6).

### 5.2 Direct Feedback Loop -- Compensating Beam Loading (D1-D4)

The direct feedback loop is the primary, highest-bandwidth loop. It exists because **beam-driven growth rates can exceed the revolution frequency** (Sec. 4.2).

**Open-loop transfer function:**

```
    G_OL(s) = G_prop * G_lead(s) * G_int(s) * G_kly(s) * H_cav(s) * exp(-s*tau_d)
                                                                      ... (Eq. 5.1)

    where:
      G_prop = proportional gain setting (~15 dB = factor 5.6)
      G_lead(s) = lead compensator (adds phase margin when cavities are detuned)
      G_int(s) = integrator (30 kHz BW, rejects carrier-frequency ripple)
      G_kly(s) = klystron transfer function (Eq. 2.8)
      H_cav(s) = cavity transfer function (Sec. 2.1.2)
      tau_d = total loop delay (Sec. 2.3)
```

**Closed-loop transfer function** (reference to cavity voltage):

```
    T(s) = G_OL(s) / (1 + G_OL(s))                                  ... (Eq. 5.2)
```

**Effective cavity impedance seen by beam:**

```
    Z_eff(omega) = Z_cav(omega) / (1 + G_OL(omega))                 ... (Eq. 5.3)
```

This is the central result. The direct feedback loop **transforms the cavity from a high-impedance resonator into a low-impedance broadband structure**. At frequencies within the loop bandwidth:

```
    |Z_eff| << |Z_cav|    by a factor of (1 + |G_OL|)
```

**Quantitative impedance reduction:**
- At DC (cavity center): G_OL ~ 15 dB + integral gain => Z reduction ~40 dB (factor ~100)
- At +/- 35.5 kHz (cavity half-BW): G_OL ~ 15 dB => Z reduction ~15 dB
- At > f_c (beyond loop bandwidth): G_OL < 1 => Z_eff = Z_cav (no reduction)

The measured impedance reduction from Corredoura [R15] Fig. 3 confirms this analysis: the direct loop reduces peak impedance from ~750 kOhm to ~7 kOhm (40 dB), but at frequencies beyond the loop bandwidth, the impedance actually increases slightly due to the loop delay converting imaginary impedance to real impedance.

**Lead compensation** increases phase margin when the cavities are detuned for full beam current. This decreases the closed-loop translation of imaginary to real cavity impedance, further reducing peak driving impedances by ~25% [R15].

**Integral compensation** (30 kHz bandwidth) provides large gain near the carrier frequency, rejecting HVPS switching ripple at the cavity field without requiring a separate ripple feedback path.

**Robinson stability under feedback:** With direct feedback, both synchrotron sidebands see reduced impedance:

```
    Re{Z_eff(omega_RF + omega_s)} = Re{Z_cav(omega_RF + omega_s)} / |1 + G_OL(omega_s)|
    Re{Z_eff(omega_RF - omega_s)} = Re{Z_cav(omega_RF - omega_s)} / |1 + G_OL(omega_s)|
```

Since both sidebands are reduced by approximately the same factor (omega_s << loop bandwidth), the impedance **asymmetry** is preserved but the **absolute values** are reduced by ~40 dB. The Robinson growth rate (Eq. 4.3) is reduced by the same factor, providing substantial stability margin.

> **Sources**: [R15] Corredoura, PAC 1999, Fig. 3; [R14] Schwarz, PS-340-330-52-R0; [R11] Gamp, CAS 2011.

### 5.3 Comb Loop -- Narrowband Enhancement at Revolution Harmonics (D4)

For machines where many revolution harmonics fall within the cavity bandwidth (PEP-II: f_rev = 136 kHz, cavity BW = 35 kHz -> ~0.3 harmonics per half-BW), the direct loop alone cannot provide sufficient impedance reduction at each sideband. The comb filter adds narrow-band gain at the synchrotron sidebands of each revolution harmonic.

**Z-domain transfer function** [R15]:

```
    H_comb(z) = G * (z^(-1) - z^(-n)) / (1 - 2K*cos(2*pi*nu_s)*z^(-n) + K^2*z^(-2n))
                                                                      ... (Eq. 5.4)
    where:
      G = forward gain
      K = reverse gain (|K| < 1 for stability)
      n = samples per revolution period
      nu_s = synchrotron tune
```

The filter peaks at synchrotron sidebands and has zeros at revolution harmonics themselves (avoiding amplification of the gap transient signal).

**SPEAR3 status**: The comb filter is **not used**. SPEAR3's large revolution harmonic spacing (1.28 MHz >> 35.5 kHz cavity BW) means only 1-2 harmonics interact with each cavity mode. The wideband direct loop provides sufficient reduction.

### 5.4 Slow Loops -- Maintaining Operating Point (D6, D7, D8)

Three slow loops maintain the quasi-static operating point around which the fast loops operate:

**Tuner Loop (~0.01-1 Hz)**: Adjusts cavity mechanical tuner to maintain optimum detuning angle (Eq. 2.6). Tracks thermal drift (D8) and slow microphonics (D7). Implemented in EPICS SNL (`rf_tuner_loop.st`). See Sec. 8 for details.

**HVPS Loop (~1 Hz)**: Adjusts klystron cathode voltage to maintain the klystron operating point ~10% below saturation. Compensates for beam current changes (D6). Error signal: klystron input drive power vs. ON_CW setpoint.

**DAC Loop (~0.1 Hz)**: Adjusts the I/Q modulator baseline DAC values to maintain the cavity gap voltage at the operator setpoint. This is the outermost amplitude regulation loop.

### 5.5 Ripple Loop -- HVPS Harmonic Rejection (D5)

The ripple loop targets the discrete-frequency disturbances from HVPS ripple (360 Hz + harmonics). It uses the **klystron forward phase** (not the cavity probe) as its measurement point, acting upstream of the cavity for rapid correction.

**Key design choice**: Measuring the klystron forward signal rather than the cavity probe signal avoids the 35.5 kHz cavity bandwidth limitation. The klystron forward signal shows the ripple immediately, without the ~4.5 us cavity response time.

In SPEAR3 practice, the ripple loop operates primarily as a slow phase tracker compensating for klystron phase shift as cathode voltage changes, rather than for fast ripple cancellation (the direct loop integrator handles most ripple rejection).

The DSP firmware implements a harmonic estimation algorithm at ~23 kHz sample rate, tracking harmonics of 60 Hz synchronized to the storage ring harmonic number (h = 372). See Sec. 6.5 for details.

> **Sources**: [R14] Schwarz, "Ripple Loop"; `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md` [R20t].

### 5.6 Multi-Loop Stability: The Bandwidth Separation Principle

The eight-loop system is stable because the loops are separated in bandwidth by factors of 10x or more. From the perspective of any given loop:

- **Faster loops** appear as approximately unity gain (they've already settled)
- **Slower loops** appear as approximately constant (they haven't moved yet)

**Formal argument**: Consider two loops with bandwidths f_1 >> f_2. The combined system has the loop transfer function:

```
    L_total(s) = L_1(s) + L_2(s) + L_1(s)*L_2(s)                   ... (Eq. 5.5)
```

If f_1 >> f_2, then at frequencies near f_1: L_2 ~ constant (its DC gain), so the cross-term L_1*L_2 merely scales the fast loop gain. At frequencies near f_2: L_1 ~ T_1(s) (its closed-loop transfer function, ~ unity in-band), so the slow loop effectively operates on a plant already stabilized by the fast loop.

The condition for safe decoupling is:

```
    f_i / f_(i+1) >= 10    for all adjacent loop pairs                ... (Eq. 5.6)
```

The SPEAR3 system satisfies this with large margins:

```
    DAC (0.1) -> HVPS/Tuner (1): ratio = 10x
    HVPS (1) -> Ripple (300): ratio = 300x
    Ripple (300) -> Direct (800k): ratio = 2,700x
```

> **Sources**: [R14]; [R15]; *Standard multi-loop control theory, e.g. Astrom & Murray, "Feedback Systems," Ch. 12*.

---

## 6. Loop-by-Loop Transfer Functions and Design

Having established the disturbance-driven rationale (Sec. 4-5), this section provides the detailed specifications of each loop. Each subsection references the disturbance(s) it addresses and the control strategy from Sec. 5.

### 6.1 Direct Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D1-D4 (beam loading, Robinson, coupled-bunch) | Primary stability loop |
| Measurement | Cavity probe vector sum (I/Q) | After combining network |
| Actuator | I/Q modulator on klystron drive | Direct analog path |
| Bandwidth | ~800 kHz (legacy) / ~930 kHz (LLRF9) | Limited by tau_d (Eq. 2.11) |
| Gain (proportional) | ~15 dB | Adjustable via EPICS PV |
| Integrator BW | ~30 kHz | Rejects carrier-frequency ripple |
| Lead compensation | Adjustable | Phase margin improvement when detuned |
| Impedance reduction | ~40 dB at DC | Measured by Corredoura [R15] |
| SPEAR3 status | **Active** | Essential for beam stability |

**Closed-loop bandwidth estimate:**

```
    The cavity acts as a single-pole rolloff at f_half = 35.5 kHz.
    The proportional gain extends the effective bandwidth:
    
    f_BW,closed = f_half * (1 + G_prop) = 35.5 kHz * (1 + 5.6) ~ 235 kHz (proportional only)
    
    With lead compensation, the bandwidth is extended further:
    f_BW,total ~ 500-800 kHz (limited by delay-induced phase loss)
```

### 6.2 Comb Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D4 (coupled-bunch modes) | Narrowband enhancement |
| Measurement | Cavity probe (I/Q) | AC-coupled after direct loop modulator |
| Actuator | I/Q modulator (separate from direct) | Parallel to direct loop |
| Bandwidth | ~2 MHz (per tooth: ~10 kHz) | Limited by revolution harmonics |
| Peak gain | ~20 dB above direct loop | At synchrotron sidebands |
| Transfer function | Eq. 5.4 (z-domain IIR) | |
| SPEAR3 status | **Not used** | Not needed (see Sec. 5.3) |

### 6.3 LFB Woofer Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D2 (residual coupled-bunch motion) | Sub-woofer for LFB system |
| Measurement | Beam BPM (from longitudinal feedback system via fiber optic) | External measurement |
| Actuator | DAC -> I/Q modulator | Band-limited drive |
| Bandwidth | ~1 MHz | |
| SPEAR3 status | **Not used** | LFB system not deployed at SPEAR3 |

### 6.4 Ripple Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D5 (HVPS ripple) | Harmonic rejection |
| Measurement | Klystron forward I/Q | Upstream of cavity (avoids cavity BW limit) |
| Actuator | I/Q modulator | |
| Bandwidth | ~300 Hz | Covers 120, 240, 360 Hz and harmonics |
| Algorithm | DSP harmonic estimator at ~23 kHz | 6 fast + 8 slow harmonics |
| Fixed-point formats | q13 (phase), q11 (accumulators), q15 (gains) | TMS320C16xx |
| SPEAR3 status | **Active** | Phase tracking + ripple rejection |

**DSP algorithm detail:**

```
    For each harmonic h[n] (n = 1..6 fast, 1..8 slow):
        h[n].I_accum += PhaseErr * cos(2*pi*n*f_ripple*t)
        h[n].Q_accum += PhaseErr * sin(2*pi*n*f_ripple*t)
    
    Correction: DAC_out = DAC_base + sum(h[n].accum * gain[n])
```

Fast harmonics are processed every cycle (~23 kHz); slow harmonics in round-robin at ~3 kHz effective rate.

> **Sources**: `spear-rf-code-legacy/dsp1610/rfpDsp/ripple.s` and `sp3ripple.s` [R36]; [R20t].

### 6.5 Gap Feedforward Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D2 (ion clearing gap transient) | Predictive compensation |
| Measurement | Error signal | |
| Actuator | DAC -> I/Q modulator | |
| Bandwidth | ~100 Hz | Adaption rate ~100 ms |
| Algorithm | DSP adapts IQ reference on 1-turn timeframe | Converges to track gap shape |
| SPEAR3 status | **Not used** | SPEAR3 gap transient manageable without |

### 6.6 HVPS Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D6 (klystron gain drift) | Operating point regulation |
| Measurement | Klystron input drive power | |
| Reference | ON_CW drive power setpoint | |
| Actuator | HVPS cathode voltage | |
| Bandwidth | ~1 Hz | Slow integrator |
| Operating point | ~10% below klystron saturation | Provides headroom for fast loops |
| SPEAR3 status | **Active** | |

### 6.7 Tuner Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D7 (microphonics), D8 (thermal detuning) | Frequency tracking |
| Measurement | Phase(probe) - Phase(klystron forward) | Detuning angle measurement |
| Reference | Fixed Offset = target detuning angle | |
| Actuator | Stepper motor via Galil controller | |
| Bandwidth | ~0.01-1 Hz | Limited by mechanical response |
| Implementation | EPICS SNL: `rf_tuner_loop.st` | |
| SPEAR3 status | **Active** | See Sec. 8 for mechanical details |

### 6.8 DAC Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | Long-term amplitude drift | Outermost amplitude regulation |
| Measurement | Cavity probe amplitude | |
| Reference | Station Gap Voltage setpoint | Operator-settable |
| Actuator | I/Q modulator baseline DAC values | |
| Bandwidth | ~0.1 Hz | Very slow integrator |
| SPEAR3 status | **Active** | |

### 6.9 Gain Tracking Function

As beam current changes, the klystron operating point moves along the saturation curve, changing the small-signal gain (D6). A slow EPICS loop (2 Hz) adjusts the I/Q modulator weights to maintain constant forward-path gain:

```
    G_modulator * G_klystron = G_loop (constant)                     ... (Eq. 6.1)

    Therefore: G_modulator = G_loop / G_klystron(V_HVPS)
```

This is implemented as a PV-driven adjustment of the direct loop modulator coefficients based on the measured klystron output power.

> **Sources**: [R15] Corredoura, PAC 1999; [R14] Schwarz, PS-340-330-52-R0.

---

## 7. HVPS Plant Model and Dynamics

### 7.1 Power Supply Architecture

The SPEAR3 klystron HVPS is a PEP-II design based on a 12-pulse primary SCR-controlled rectifier operating at 12.47 kV (SLAC site-wide distribution). Designed by R. Cassel and M.N. Nguyen at SLAC.

**Key design features:**
1. **12-pulse SCR bridge** with primary filter inductor -- rapid voltage control, good regulation
2. **"Star point controller" configuration** -- filter inductor on primary side, energy bypass during faults
3. **Unique secondary rectifier/filter** -- minimizes stored energy during klystron arcs
4. **SCR crowbar** -- limits arc energy to <5 J (with crowbar), <20 J (without)

### 7.2 HVPS Electrical Parameters

| Parameter | Value | Unit |
|-----------|-------|------|
| Input voltage | 12,470 V RMS L-L | 3-phase 60 Hz |
| Output voltage range | 0 to -90 kV | DC |
| Maximum current | 27 A | DC |
| Nominal operating | -77 kV, 22 A | DC |
| Power rating | 2.5 MVA | -- |
| Voltage regulation | <+/-0.5% | at >65 kV |
| Voltage ripple | <1% P-P, <0.2% RMS | at >60 kV |
| Phase shift transformer (T0) | 3.5 MVA, +/-15 deg | -- |
| Rectifier transformers (T1,T2) | 1.5 MVA each | Open wye primary, dual wye secondary |
| Filter inductors (L1,L2) | 0.3 H each | 85 A DC rating |
| Filter capacitors (C) | 4 x 8 uF at 30 kV | -- |
| Isolation resistors (R) | 8 x 500 Ohm, 1 kW | -- |
| Cable termination inductors | 200 uH each | -- |
| SCR bridge stacks | 6 x 14 series SCRs | 40 kV, 80 A per stack |
| Crowbar stacks | 4 series SCR stacks | 100 kV total, 1 us trigger |
| Arc energy (with crowbar) | <5 J | -- |
| Arc energy (without crowbar) | <20 J | -- |

> **Sources**: [R21] Cassel and Nguyen, SLAC-PUB-7591, PAC 1997; [R22] PS-341-360-01-R2.

### 7.3 SCR Phase Control Dynamics

The firing angle alpha determines the output DC voltage:

```
    V_dc = V_dc,max * cos(alpha)                                     ... (Eq. 7.1)
    
    where V_dc,max = (3*sqrt(2)/pi) * V_secondary
```

The Enerpro FCOG1200 firing boards use a PLL architecture:

```
    PLL free-running frequency: 23,040 Hz = 384 * 60 Hz
    Settling time: ~3 AC cycles (50 ms)
    Bandwidth: -3 dB at ~66 Hz (415 rad/s)
    
    H_enerpro(s) = 1 / (1 + s/omega_enerpro)                        ... (Eq. 7.2)
    where omega_enerpro = 415 rad/s
```

> **Sources**: [R25] Bourbeau, IEEE 1983; [R26] Enerpro FCOG1200 manual; *Preliminary analysis (AI-generated, see `hvps/controls/enerpro/technical-notes/06-control-theory.md`, unreviewed)*.

### 7.4 PLC Voltage Regulation Loop

The Allen-Bradley SLC-500 PLC implements a digital regulation loop:

```
    Scan period: T = 10 ms
    Filter coefficient: alpha = 0.4
    Time constant: tau = -T/ln(1-alpha) = 20 ms
    
    Filter equation: y[n] = (1-alpha)*y[n-1] + alpha*x[n]           ... (Eq. 7.3)
```

**Voltage reference scaling:**
- Internal range: 100 to 32,000 (16-bit integer)
- Phase angle output: N7:11 = (N7:10 * 12,000/32,767) + 6,000
- Maximum phase angle value: 18,000

> **Sources**: [R27] `hvps/documentation/plc/CasselPLCCode.pdf`; [R28] `hvps/documentation/plc/CasselSymbolDatabase.pdf`; [R23] `hvps/simulation/hvps_sim/config.py`.

### 7.5 Klystron Arc Protection

Protection limits arc energy through four mechanisms:
1. **SCR crowbar** -- fires within ~1 us (fiber-optic trigger)
2. **Star point controller bypass** -- isolates load from line
3. **Isolation resistors** -- 500 Ohm limits current to ~1 A max
4. **Cable termination inductors** -- 200 uH limits di/dt

Result: <5 J to klystron (with crowbar), <20 J (without). I^2*t specification: <40 A^2*s.

### 7.6 HVPS Dynamic Response Summary

Key time constants for control design:

| Subsystem | Time Constant | Bandwidth |
|-----------|--------------|-----------|
| PLC filter | tau = 20 ms | ~8 Hz |
| Enerpro PLL | settling ~ 50 ms | ~66 Hz |
| SCR commutation | ~100 us | ~1.6 kHz |
| Filter LC network | tau_LC = 86 us | ~1.8 kHz |
| Overall voltage step | <10 ms (10% step) | ~16 Hz |

The slowest element (Enerpro PLL at 50 ms settling) dominates the HVPS dynamic response. This is why the HVPS feedback loop bandwidth is limited to ~1 Hz -- the plant itself cannot respond faster than ~16 Hz.

---

## 8. Tuner Mechanics and Resonant Frequency Control

### 8.1 Cavity Tuner Physical Description

Each cavity has a mechanical tuner: a movable plunger driven by a stepper motor through a worm gear.

| Parameter | Value |
|-----------|-------|
| Motor | Superior Electric Slo-Syn M093-FC11 (NEMA 34D) |
| Drive mechanism | Worm gear (self-locking) |
| Tuning range | ~+/-200 kHz |
| Step resolution | ~1 Hz/step (via worm gear ratio) |
| Gear ratio | 1:2 (pulley, motor:lead screw) |
| Lead screw | 1/2-10 Acme thread (10 TPI), 1 rev = 2.54 mm |
| Distance per microstep | 3.175 um (legacy), 0.05 um (Galil upgrade) |

The worm gear provides self-locking: loss of tuner control does not cause rapid frequency drift.

> **Sources**: [R29]-[R33] Tuner documentation in `llrf/tuners/`.

### 8.2 Tuning Physics

The cavity resonant frequency depends nonlinearly on plunger position:

```
    f_res(x) = polynomial fit (3rd-4th order)                        ... (Eq. 8.1)
    
    Measured by "Tune Cavs" MATLAB routine (noise injection + resonance fit)
```

**Temperature dependence**: ~-1 kHz/degC from copper thermal expansion. LCW cooling maintains ~35 degC. During power transients, 10-100 Hz drifts over minutes.

### 8.3 Tuner Control Loop

```
    Error = (Phase_probe - Phase_forward) - Fixed_Offset             ... (Eq. 8.2)
    
    where Fixed_Offset = target detuning angle (Eq. 2.6)
```

Implemented in `rf_tuner_loop.st` (EPICS SNL). Bandwidth ~0.01-1 Hz, limited by stepper motor mechanics.

**Park frequency**: When beam is absent, cavities are "parked" at a designated frequency determined from the polynomial fit.

> **Sources**: [R14] Schwarz, "Tuner Loop"; [R34] `spear-rf-code-legacy/rfApp/src/seq/rf_tuner_loop.st`; [R35] `llrf/tuners/galil/GalilCommissioning.docx`.

---

## 9. Performance Requirements and Verification

### 9.1 Disturbance Rejection Summary

The multi-loop architecture achieves the following disturbance rejection:

| Disturbance | Frequency | Open-Loop Impact | Rejection | Residual |
|-------------|-----------|-----------------|-----------|----------|
| Beam loading (D1-D2) | DC-100 kHz | Unstable (growth < T_rev) | ~40 dB (direct loop) | Stable with margin |
| Robinson (D3) | ~9.4 kHz | Exponential growth | ~40 dB impedance reduction | Growth rate << 1/tau_rad |
| HVPS ripple (D5) | 360-2000 Hz | ~1% phase mod | ~40 dB (direct + ripple) | <0.01% phase |
| Thermal drift (D8) | <0.01 Hz | ~100 Hz/hr | Tuner loop tracks | <1 Hz residual |
| Klystron gain (D6) | ~0.01-1 Hz | ~7 dB variation | HVPS + gain tracking | <0.5 dB variation |

### 9.2 LLRF9 Commissioning Results

Key measurements from `llrf9Tests.pdf` [R4]:
- LLRF9 achieves improved noise floor compared to legacy system at 500 mA
- HVPS harmonics (360, 720 Hz) visible in both systems but reduced with LLRF9
- Overall amplitude stability: <0.05% RMS (exceeds <0.1% requirement)
- Overall phase stability: <0.05 deg RMS (exceeds <0.1 deg requirement)

### 9.3 Performance Margins

| Parameter | Capacity | Typical Use | Margin |
|-----------|----------|-------------|--------|
| Klystron power | 1.2 MW | ~800 kW | ~50% |
| HVPS voltage | 90 kV | ~74 kV | ~22% |
| Gap voltage/cavity | 1 MV | ~712 kV | ~40% |
| Direct loop BW | ~930 kHz (LLRF9) | ~800 kHz | ~16% |
| Impedance reduction | ~40 dB | Required: ~30 dB | >10 dB margin |

### 9.4 Calibration Data

Calibration files in `llrf/calibrations/` establish numerical relationships for all feedback loops:

| File | Content |
|------|---------|
| driveAmpCalibration.xlsx | Drive amp power vs. DAC setting |
| klystronCouplerDriveAmpCalibrations.xlsx | Klystron coupler calibrations |
| pulsarCouplerCalibration2049.xlsx | Pulsar coupler calibration |
| reflectedPowerCalibrations.xlsx | Reflected power calibrations |
| tuneModeDacCalibration.xlsx | Tune mode DAC calibration |
| b132R11PatchPanel.xlsx | B132 R11 patch panel mapping |

> **Sources**: [R38] Calibration files; [R39] Jim Sebek's master document index.

---

## Appendix A -- SPEAR3 RF System Parameter Table

### A.1 Storage Ring Parameters

| Parameter | Symbol | Value | Unit | Source |
|-----------|--------|-------|------|--------|
| Beam energy | E_0 | 3.0 | GeV | [R1] |
| Beam current (top-off) | I_b | 500 | mA | [R1] |
| Circumference | C | 234.14 | m | [R2] |
| Revolution frequency | f_rev | 1.2804 | MHz | Derived |
| Harmonic number | h | 372 | -- | [R1] |
| RF frequency | f_RF | 476.3051755 | MHz | [R4] |
| Momentum compaction | alpha_c | 1.18e-3 | -- | [R2] |
| Energy loss per turn | U_0 | ~0.91 | MeV | [R1] |
| Synchrotron tune | nu_s | ~0.0073 | -- | Derived |
| Synchrotron frequency | f_s | ~9.4 | kHz | Derived |

### A.2 Cavity Parameters (Per Cavity)

| Parameter | Symbol | Value | Unit | Source |
|-----------|--------|-------|------|--------|
| Resonant frequency | f_0 | 476.315 | MHz | [R6] |
| Shunt impedance (linac) | R_s | 3.73 | MOhm | [R6] |
| Shunt impedance (accel) | R_s | 7.5 | MOhm | [R6] |
| R/Q | R/Q | ~116 | Ohm | [R7] |
| Unloaded Q | Q_0 | 32,000 | -- | [R6] |
| Loaded Q | Q_L | 6,700 | -- | [R6] |
| Coupling coefficient | beta | 3.72 | -- | [R6] |
| Cavity half-bandwidth | Delta_f_half | ~35.5 | kHz | Derived |
| Operational gap voltage | V_gap | ~712 | kV | [R5] |

### A.3 Klystron Parameters

| Parameter | Value | Unit | Source |
|-----------|-------|------|--------|
| Type | Marconi/CPI K3512S | -- | [R1] |
| Maximum power | 1.2 MW CW | -- | [R1] |
| Gain | 43 dB min | -- | [R1] |
| Bandwidth | 5 MHz (-3 dB) | -- | [R1] |
| Group delay | <150 ns | -- | [R1] |
| Drive power | ~29 W | -- | [R5] |
| Perveance | ~2.0e-6 | A/V^(3/2) | [R23] |

### A.4 Feedback Loop Parameters

| Loop | Bandwidth | SPEAR3 Status | Addresses | Source |
|------|-----------|---------------|-----------|--------|
| Direct | ~800 kHz | Active | D1-D4 | [R14] |
| Comb | 2 MHz | Not used | D4 | [R14] |
| Ripple | ~300 Hz | Active | D5 | [R14] |
| Gap FF | 100 Hz | Not used | D2 | [R14] |
| HVPS | ~1 Hz | Active | D6 | [R14] |
| Tuner | ~0.01-1 Hz | Active | D7, D8 | [R14] |
| DAC | ~0.1 Hz | Active | Amplitude drift | [R14] |
| LFB Woofer | 1 MHz | Not used | D2 | [R14] |

---

## Appendix B -- Source Document Reference Index

### B.1 Published Papers

| Ref | Citation |
|-----|---------|
| [R1] | McIntosh, P. et al., "The SPEAR3 RF System," SLAC-PUB-10983, EPAC 2004. DOI: 10.2172/839730 |
| [R2] | Hettel, R. et al., "Design of the SPEAR 3 Light Source," PAC 1999 |
| [R7] | Rimmer, R.A. et al., "RF Cavity Development for the PEP-II B Factory," LBL-33360, 1992 |
| [R8] | Rimmer, R.A. et al., "High-Power Testing of the First PEP-II RF Cavity," SLAC-PUB-7210, 1996 |
| [R9] | Goldberg, D.A. et al., "Measurement and Analysis of HOM Damping in B-Factory RF Cavities," PAC 1995 |
| [R11] | Gamp, A., "Beam-Cavity Interaction," CAS 2011, arXiv:1112.3203 |
| [R12] | Wilson, P.B., "Fundamental-Mode RF Design in e+e- Storage Ring Factories," SLAC-PUB-6062, 1993 |
| [R13] | Boussard, D., "Control of Cavities with High Beam Loading," PAC 1985 |
| [R15] | Corredoura, P., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8124, PAC 1999 |
| [R16] | Robinson, K.W., "Stability of Beam in Radiofrequency Systems," CEA Report CEAL-1010, 1964 |
| [R17] | Rimmer, R.A. et al., "Comparison of Calculated, Measured, and Beam Sampled Impedances," PRSTAB 3, 102001, 2000 |
| [R21] | Cassel, R. and Nguyen, M.N., "A Unique Power Supply for the PEP II Klystron," SLAC-PUB-7591, PAC 1997 |
| [R25] | Bourbeau, E.J., "Application of PLL Techniques to SCR Drives," IEEE 1983 |

### B.2 Textbooks and General References

| Ref | Citation |
|-----|---------|
| [R3] | SSRL SPEAR3 Accelerator Parameters, https://www-ssrl.slac.stanford.edu/ssrl/web/node/15 |
| [R10] | Wiedemann, H., Particle Accelerator Physics, 4th ed., Springer, 2015 |
| [R18] | Analog Devices AD834 datasheet |

### B.3 Original Engineering Documents in Repository

| Ref | Document | Repository Path |
|-----|----------|----------------|
| [R4] | LLRF9 Commissioning Tests | `llrf/tests/llrf9Tests.pdf` |
| [R5] | System Design Report (PDR R1) | `Designs/0_SYSTEM_DESIGN_REPORT.md` |
| [R6] | RF System Description (Schwarz) | `llrf/documentation/legacyArchitecture/ps3403305100.pdf` |
| [R6t] | Transcription of [R6] | `llrf/.../PS-340-330-51_RF_System_Description.md` |
| [R14] | Feedback Loop Description (Schwarz) | `llrf/documentation/legacyArchitecture/feedbackLoopDescriptionps3403305200.pdf` |
| [R14t] | Transcription of [R14] | `llrf/.../PS-340-330-52_LLRF_Feedback_Loop_Description.md` |
| [R15t] | Transcription of Corredoura PAC99 | `llrf/.../conference-papers/Architecture_and_Performance_PEP-II_LLRF.md` |
| [R19] | Comprehensive FBK Loops Description | `llrf/.../PEPII_LLRF_FBK_Loops_Description.md` |
| [R20t] | DSP Firmware Analysis | `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md` |
| [R21t] | Transcription of SLAC-PUB-7591 | `hvps/architecture/originalDocuments/transcriptions/slac-pub-7591_transcription.md` |
| [R22] | HVPS Technical Specification | `hvps/architecture/originalDocuments/ps3413600102.pdf` |
| [R23] | HVPS Simulation Config | `hvps/simulation/hvps_sim/config.py` |
| [R26] | Enerpro FCOG1200 Manual | `hvps/controls/enerpro/enerproDocuments/` |
| [R27] | Cassel PLC Code | `hvps/documentation/plc/CasselPLCCode.pdf` |
| [R28] | Cassel PLC Symbol Database | `hvps/documentation/plc/CasselSymbolDatabase.pdf` |
| [R29] | SLO-SYN Motor Manual | `llrf/tuners/SLO-SYN.pdf` |
| [R30] | SLO-SYN MD808 Manual | `llrf/tuners/SLO-SYN_MD808_Stepper_Drive_Manual.pdf` |
| [R31] | SLO-SYN SS2000MD4M Manual | `llrf/tuners/SLO-SYN_SS2000MD4M_Step_Drive_Translator_Manual.pdf` |
| [R32] | Galil DMC-4103 Manual | `llrf/tuners/galil/dmc-4103-r13h-manual.pdf` |
| [R33] | Cavity Tuner Inspections | `llrf/tuners/cavityTunerInspections20230613.docx` |
| [R34] | Tuner Loop Source Code | `spear-rf-code-legacy/rfApp/src/seq/rf_tuner_loop.st` |
| [R35] | Galil Commissioning Notes | `llrf/tuners/galil/GalilCommissioning.docx` |
| [R36] | DSP Ripple Firmware | `spear-rf-code-legacy/dsp1610/rfpDsp/ripple.s` |
| [R37] | LLRF9 Test Graphics | `llrf/tests/graphics/` |
| [R38] | RF Calibration Data | `llrf/calibrations/*.xlsx` |
| [R39] | RF System Document Index | `llrf/documentation/RfSystemDocumentIndexR3.xlsx` |

### B.4 AI-Generated Analysis (Consulted, Unreviewed)

| File | Subsystem |
|------|-----------|
| `llrf/.../technical-notes/01_FEEDBACK_LOOP_ARCHITECTURE.md` | LLRF architecture |
| `hvps/controls/enerpro/technical-notes/06-control-theory.md` | Enerpro PLL |
| `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md` | DSP firmware |
| `hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md` | HVPS design |
| `hvps/architecture/technical-notes/01-pepii-power-supply-architecture.md` | PEP-II HVPS |

### B.5 External Web References

| Ref | URL | Content |
|-----|-----|---------|
| [W1] | https://inspirehep.net/files/945e7ff73cc428af4c018fd1bdb6afa7 | McIntosh EPAC04 |
| [W2] | https://www.osti.gov/biblio/839730 | OSTI record for SLAC-PUB-10983 |
| [W3] | https://export.arxiv.org/pdf/1112.3203v1.pdf | Gamp CAS 2011 |
| [W4] | https://www.dimtel.com/products/llrf9 | Dimtel LLRF9 |
| [W5] | https://proceedings.jacow.org/p85/PDF/PAC1985_1852.PDF | Boussard PAC85 |
| [W6] | https://www.osti.gov/biblio/808721 | SPEAR 3 Design Report |
| [W7] | https://inspirehep.net/files/dbbd3f9a808792f9901894060a879b5f | Chang et al., NSRRC, Pedersen model |

---

## Appendix C -- Symbol and Notation Conventions

### C.1 Frequently Used Symbols

| Symbol | Definition | Typical Unit |
|--------|-----------|-------------|
| f_0 | Cavity resonant frequency | MHz |
| f_RF | RF operating frequency | MHz |
| f_rev | Revolution frequency | MHz |
| f_s | Synchrotron frequency | kHz |
| Q_0 | Unloaded quality factor | -- |
| Q_L | Loaded quality factor | -- |
| beta | Coupling coefficient = Q_0/Q_ext | -- |
| R_s | Shunt impedance | MOhm |
| V_gap | Gap voltage per cavity | kV |
| I_b | DC beam current | mA or A |
| phi_s | Synchronous phase angle | degrees |
| psi | Detuning angle | degrees |
| Delta_f | Frequency detuning | kHz |
| tau_d | Total loop delay | ns |
| G_OL | Open-loop gain | dB or -- |
| Z_eff | Effective impedance (with feedback) | Ohm |

### C.2 Conventions

1. **Shunt impedance**: Linac convention (R_s = V^2/2P) unless stated. Accelerator convention = 2x larger.
2. **Phase**: Positive = counter-clockwise in I/Q plane. phi_s measured from RF zero-crossing.
3. **Detuning**: Delta_f = f_0 - f_RF. Negative = cavity below RF (normal for beam loading compensation above transition).
4. **Reference tags**: [Rn] = numbered reference, [Rnt] = transcription, [Wn] = web reference, [Dn] = disturbance number (Sec. 4).

---

*End of Document*

**Document Control**:
- Tier 1 RF physics reference for the SPEAR3 LLRF system.
- Definitive version: `Designs/P_RF_PHYSICS_AND_PLANT.md`
- **Provenance**: AI-ASSISTED -- proposed by AI based on exhaustive review of original source documents and published literature. Subject to human review.
- **Review status**: UNREVIEWED -- requires verification by a qualified RF engineer.
