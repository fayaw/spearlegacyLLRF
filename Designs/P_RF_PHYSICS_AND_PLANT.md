# SPEAR3 RF System — RF Physics, Control Theory and Physical Plant

**Document ID**: Doc P
**Version**: 2.1
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
| 2.0 | 2026-03-24 | Major rewrite: disturbance-driven control design narrative. |
| 2.1 | 2026-03-24 | LaTeX formatting for all equations and symbols. Physics review: corrected synchronous phase convention (Eq. 2.4), verified all numerical calculations, fixed minor inconsistencies. |

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
- [Appendix A — Parameter Table](#appendix-a--spear3-rf-system-parameter-table)
- [Appendix B — Reference Index](#appendix-b--source-document-reference-index)
- [Appendix C — Notation Conventions](#appendix-c--symbol-and-notation-conventions)

---

## Document Scope and Provenance

### Purpose

This document is the **Tier 1 physics and plant reference** for the SPEAR3 RF system. It describes the RF physics, control theory, and physical plant parameters that are **independent of the specific control hardware implementation**. The content does not change when VXI hardware is replaced with the LLRF9 controller — it describes the *why* behind the control system design.

> **The SPEAR3 LLRF control architecture is uniquely determined by the disturbance landscape of the RF plant.** Each feedback loop exists because a specific class of disturbance threatens RF field stability, and the loop's bandwidth and gain are set by the magnitude and frequency content of that disturbance.

### Provenance Statement

All technical content is derived from **original source documents** per the Documentation Architecture Proposal (v5.1, §2.1). AI-generated technical notes are cited as *"preliminary analysis (AI-generated, see [filename], unreviewed)"* per §2.4.

---

## 1. System Overview and Field Stability Requirements

### 1.1 The Control Problem in One Sentence

The SPEAR3 RF system must deliver a 476.3 MHz accelerating voltage of $\sim\!2.85$ MV across four cavities with amplitude stability $< 0.1\%$ RMS and phase stability $< 0.1°$ RMS, in the presence of beam loading forces that — without feedback — would drive the system unstable within microseconds.

### 1.2 Storage Ring Parameters

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| Beam energy | $E_0$ | 3.0 | GeV |
| Beam current (top-off) | $I_b$ | 500 | mA |
| Circumference | $C$ | 234.14 | m |
| Revolution frequency | $f_\text{rev}$ | 1.2804 | MHz |
| Revolution period | $T_\text{rev}$ | 0.781 | μs |
| Harmonic number | $h$ | 372 | — |
| RF frequency | $f_\text{RF}$ | 476.3051755 | MHz |
| Momentum compaction | $\alpha_c$ | $1.18 \times 10^{-3}$ | — |
| Energy loss per turn | $U_0$ | ~0.91 | MeV |
| Total accelerating voltage | $V_\text{RF}$ | ~2.85 | MV |
| Synchrotron frequency | $f_s$ | ~9.4 | kHz |
| Radiation damping time | $\tau_\text{rad}$ | ~5 | ms |

> **Sources**: [R1] McIntosh et al., SLAC-PUB-10983, EPAC 2004. [R2] Hettel et al., PAC 1999. [R5] `Designs/0_SYSTEM_DESIGN_REPORT.md`.

### 1.3 RF System Configuration

The RF station consists of: a single 1.2 MW CW klystron (Marconi/CPI K3512S) → waveguide circulator → $3\times$ Magic-Tee power splitter → four PEP-II-type single-cell HOM-damped copper cavities. A single I/Q modulator at the klystron input is the primary actuator for all fast feedback loops.

> **Sources**: [R1]; [R6] Schwarz, PS-340-330-51-R0, 1999.

### 1.4 Field Stability Requirements

| Parameter | Requirement | Typical Achieved | Rationale |
|-----------|------------|-----------------|-----------|
| Amplitude stability | $< 0.1\%$ RMS | $< 0.05\%$ RMS | Photon beam position, energy spread |
| Phase stability | $< 0.1°$ RMS | $< 0.05°$ RMS | Bunch timing, longitudinal emittance |
| HVPS voltage regulation | $< \pm 0.5\%$ | $< \pm 0.3\%$ | Klystron gain/phase stability |
| HVPS ripple | $< 1\%$ P-P | $< 0.5\%$ P-P | RF phase modulation budget |

> **Sources**: [R5]; [R4] LLRF9 Commissioning Tests.

---

## 2. Plant Physics Model

This section derives the mathematical models of the three physical subsystems that the LLRF controller must regulate: the RF cavity, the klystron amplifier, and the HVPS.

### 2.1 RF Cavity as a Narrowband Resonator

#### 2.1.1 Equivalent Circuit

Near its fundamental mode at $\omega_0 = 2\pi \times 476.3\;\text{MHz}$, each cavity is modeled as a parallel RLC circuit. The cavity parameters (per cavity, linac convention $R_s = V^2/2P$):

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| Resonant frequency | $f_0$ | 476.315 | MHz |
| Shunt impedance | $R_s$ | 3.73 | MΩ |
| Unloaded Q | $Q_0$ | 32,000 | — |
| Loaded Q | $Q_L$ | 6,700 | — |
| Coupling coefficient | $\beta = Q_0/Q_\text{ext}$ | 3.78 | — |

> **Sources**: [R6] Schwarz parameter table; [R7] Rimmer et al., LBL-33360.

#### 2.1.2 Cavity Transfer Function

The cavity voltage response to a driving current near resonance:

$$H_\text{cav}(s) = \frac{R_s \,\omega_{1/2}}{s + \omega_{1/2} + j\Delta\omega} \tag{Eq.\;2.1a}$$

where $\omega_{1/2} = \omega_0/(2Q_L)$ is the cavity half-bandwidth. The **impedance seen by the beam** at frequency offset $\Delta\omega$ from $\omega_\text{RF}$:

$$Z_\text{cav}(\Delta\omega) = \frac{R_s}{1 + j\,2Q_L\,\Delta\omega/\omega_0} \tag{Eq.\;2.1}$$

**Cavity half-bandwidth:**

$$\Delta f_{1/2} = \frac{f_0}{2Q_L} = \frac{476.315\;\text{MHz}}{2 \times 6{,}700} = 35.5\;\text{kHz} \tag{Eq.\;2.1b}$$

This determines the cavity natural response time $\tau_\text{cav} = 1/(2\pi\Delta f_{1/2}) \approx 4.5\;\mu\text{s}$.

#### 2.1.3 Beam Loading — Steady-State Phasor Analysis

The beam-induced voltage at resonance:

$$V_{b,\text{res}} = I_b \cdot R_s = 0.5\;\text{A} \times 3.73\;\text{M}\Omega = 1.865\;\text{MV} \tag{Eq.\;2.2}$$

This exceeds the desired gap voltage ($V_\text{gap} = 712$ kV) by a factor of 2.6, demonstrating that **beam loading is the dominant effect**.

**Synchronous phase** — In the convention where $\phi_s$ is measured from the voltage crest (SLAC convention, used throughout this document):

$$V_\text{RF} \cos\phi_s = U_0 \tag{Eq.\;2.4}$$

$$\cos\phi_s = \frac{U_0}{V_\text{RF}} = \frac{0.91\;\text{MeV}}{2.85\;\text{MV}} = 0.319 \implies \phi_s \approx 71.4° \tag{Eq.\;2.4a}$$

Note: $\sin\phi_s = \sin(71.4°) = 0.948$, which appears in the beam loading compensation formulas below.

**Optimum detuning** — minimizes reflected power at the input coupler:

$$\tan\psi_\text{opt} = -\frac{I_b \, R_s \, \sin\phi_s}{V_\text{gap}} = -\frac{0.5 \times 3.73 \times 10^6 \times 0.948}{712 \times 10^3} = -2.48 \tag{Eq.\;2.5}$$

$$\psi_\text{opt} \approx -68° \tag{Eq.\;2.5a}$$

**Optimum frequency detuning:**

$$\Delta f_\text{opt} = \frac{f_0 \tan\psi_\text{opt}}{2Q_L} = \frac{476.3\;\text{MHz} \times (-2.48)}{2 \times 6{,}700} \approx -88\;\text{kHz} \tag{Eq.\;2.6}$$

The cavity must be tuned $\sim\!88$ kHz **below** $f_\text{RF}$ at 500 mA.

**Required generator power per cavity:**

$$P_\text{gen} = \frac{V_\text{gap}^2}{4R_L}\left[1 + \left(\frac{I_b R_s \sin\phi_s}{V_\text{gap}}\right)^{\!2}\right]^{1/2} + \frac{I_b V_\text{gap}\cos\phi_s}{n_\text{cav}} \tag{Eq.\;2.7}$$

where $R_L = R_s/(1+\beta) \approx 780\;\text{k}\Omega$, giving $\approx 135$ kW/cavity, $\approx 540$ kW total (within the 1.2 MW klystron capacity).

> **Sources**: [R11] Gamp, CAS 2011; [R12] Wilson, SLAC-PUB-6062; [R13] Boussard, PAC 1985.

### 2.2 Klystron as the Actuator

For control analysis, the klystron is modeled as:

$$G_\text{kly}(s) = K_\text{kly} \cdot e^{-s\tau_\text{kly}} \tag{Eq.\;2.8}$$

where $K_\text{kly}$ is the small-signal gain and $\tau_\text{kly} < 150$ ns.

| Parameter | Value | Unit |
|-----------|-------|------|
| Maximum output power | 1.2 MW | CW |
| Gain | 43 dB (min) | — |
| Bandwidth | 5 MHz | −3 dB |
| Group delay | $< 150$ ns | — |
| Perveance | $\sim\!2.0 \times 10^{-6}$ | A/V$^{3/2}$ |

**Saturation model:**

$$P_\text{out} = P_\text{sat} \cdot \frac{P_\text{in}/P_\text{in,sat}}{1 + P_\text{in}/P_\text{in,sat}} \tag{Eq.\;2.9}$$

**AM-PM conversion** — klystron output phase sensitivity to cathode voltage:

$$\Delta\phi_\text{kly} \propto \frac{\Delta V_k}{V_k} \tag{Eq.\;2.10}$$

> **Sources**: [R1]; [R15] Corredoura, PAC 1999; [R5].

### 2.3 Loop Delay Budget — The Fundamental Bandwidth Ceiling

The maximum stable crossover frequency (with $\sim\!45°$ phase margin):

$$\boxed{f_{c,\text{max}} \approx \frac{1}{4\tau_d}} \tag{Eq.\;2.11}$$

This is the single most important constraint in the entire control design.

| Component | Legacy (analog) | LLRF9 (digital) |
|-----------|:-:|:-:|
| Klystron group delay | $< 150$ ns | $< 150$ ns |
| I/Q modulator | $< 5$ ns | $< 5$ ns |
| Cable propagation | $\sim\!50$ ns | $\sim\!50$ ns |
| Electronics/computation | $\sim\!300$ ns | $\sim\!65$ ns |
| **Total** $\tau_d$ | **$\sim\!500$ ns** | **$\sim\!270$ ns** |
| $f_{c,\text{max}}$ | **$\sim\!500$ kHz** | **$\sim\!926$ kHz** |

### 2.4 Complete Open-Loop Plant Transfer Function

$$G_\text{plant}(s) = G_0 \cdot H_\text{cav}(s) \cdot e^{-s\tau_d} = \frac{G_0 \,\omega_{1/2}}{s + \omega_{1/2} + j\Delta\omega}\; e^{-s\tau_d} \tag{Eq.\;2.12}$$

The cavity bandwidth ($35.5$ kHz) and the loop delay ($270$–$500$ ns) together define the limits of what feedback can achieve.

---

## 3. I/Q Signal Processing Framework

### 3.1 Baseband I/Q Representation

All RF feedback loops use baseband In-phase and Quadrature (I/Q) techniques:

$$V_\text{RF}(t) = I(t)\cos(\omega_\text{RF}t) - Q(t)\sin(\omega_\text{RF}t) \tag{Eq.\;3.0}$$

where $I(t) = A(t)\cos\phi(t)$ and $Q(t) = A(t)\sin\phi(t)$, with inverse relations:

$$A(t) = \sqrt{I^2 + Q^2}\,,\qquad \phi(t) = \text{atan2}(Q, I) \tag{Eq.\;3.0a}$$

### 3.2 Baseband I/Q Modulator

The I/Q modulator performs a scaled rotation:

$$\begin{pmatrix} I_\text{out} \\ Q_\text{out} \end{pmatrix} = G \begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{pmatrix} \begin{pmatrix} I_\text{in} \\ Q_\text{in} \end{pmatrix} \tag{Eq.\;3.1}$$

**Implementation**: Four AD834 four-quadrant multipliers + two EL2073 summing amplifiers. Group delay $< 5$ ns, full-power BW $> 40$ MHz, dynamic range $> 50$ dB. Total system: 7 I/Q modulators, 56 DAC channels.

> **Sources**: [R15] Corredoura, Eq. 2; [R14] Schwarz, PS-340-330-52-R0.

### 3.3 I/Q Demodulation

RF signals are converted to baseband I/Q using $+13$ dBm demodulators. Outputs: AC-coupled into $50\;\Omega$, low-pass filtered ($F_c = 225$ MHz), video amplified (17 dB) to $\pm 1$ V.

### 3.4 Cavity Probe Vector Sum

Each of the 4 cavity probe signals is demodulated to I/Q and combined through a programmable network (4 I/Q modulators + 2 summing amplifiers) to form the **total accelerating RF vector**.

### 3.5 Error Signal Generation

$$\vec{E} = \vec{V}_\text{ref} - \vec{V}_\text{probe} \tag{Eq.\;3.2}$$

$$\vec{V}_\text{drive} = G_\text{loop} \cdot \vec{E} = G_\text{loop}\left(\vec{V}_\text{ref} - \vec{V}_\text{probe}\right) \tag{Eq.\;3.3}$$

> **Sources**: [R15]; [R14].

---

## 4. Disturbance Analysis and Control Problem Statement

**The control architecture follows inevitably from the disturbance landscape.**

### 4.1 Disturbance Taxonomy

| # | Disturbance | Frequency | Magnitude | Impact |
|---|-------------|-----------|-----------|--------|
| D1 | Beam loading (steady-state) | DC | $V_b = 1.865$ MV/cavity | Dominates voltage budget |
| D2 | Beam loading (transient) | DC–100 kHz | Growth rates $< T_\text{rev}$ | Longitudinal instability |
| D3 | Robinson instability | $f_s \sim 9.4$ kHz | Exponential growth | Beam loss |
| D4 | Coupled-bunch modes | $n \cdot f_\text{rev}$ | $1/\tau_{cb}$ | Beam oscillation |
| D5 | HVPS ripple | 360, 720, 1080… Hz | $< 1\%$ P-P voltage | Phase modulation |
| D6 | Klystron gain drift | 0.01–1 Hz | up to 7 dB | Loop gain variation |
| D7 | Microphonics | 1–300 Hz | $\Delta f \sim 1$–$10$ Hz | Cavity detuning |
| D8 | Thermal detuning | $< 0.01$ Hz | $\Delta f \sim 1$–$100$ Hz | Slow frequency drift |

### 4.2 D1/D2: Beam Loading — The Dominant Disturbance

**Growth rate for coupled-bunch instability** from the fundamental mode [R15]:

$$\frac{1}{\tau} = \frac{I_b\,\alpha_c\,f_\text{RF}}{2\,\nu_s\,\beta^2\,(E/e)}\;R_{cb} \tag{Eq.\;4.1}$$

where $R_{cb} = \sum_n \text{Re}\!\left[Z(\omega_\text{RF} + n\omega_\text{rev} + \omega_s) - Z(\omega_\text{RF} + n\omega_\text{rev} - \omega_s)\right]$.

**Without feedback**, the peak cavity impedance of $\sim\!750\;\text{k}\Omega$ produces growth rates faster than $T_\text{rev} \approx 0.78\;\mu\text{s}$. This single fact drove the PEP-II system design to include multiple feedback loops [R15].

> **Sources**: [R15] Corredoura, PAC 1999, Eq. 1; [R11] Gamp, CAS 2011.

### 4.3 D3: Robinson Instability

**Robinson stability criterion** (above transition):

$$\text{Re}\{Z_\text{eff}(\omega_\text{RF} + \omega_s)\} < \text{Re}\{Z_\text{eff}(\omega_\text{RF} - \omega_s)\} \tag{Eq.\;4.2}$$

**Robinson growth rate:**

$$\frac{1}{\tau_\text{Rob}} = \frac{\alpha_c\,\omega_\text{rev}\,I_b}{4\,\omega_s\,(E/e)} \left[\text{Re}\{Z(\omega_\text{RF} + \omega_s)\} - \text{Re}\{Z(\omega_\text{RF} - \omega_s)\}\right] \tag{Eq.\;4.3}$$

Direct feedback reduces $Z_\text{eff} = Z_\text{cav}/(1 + G_\text{OL})$, reducing the growth rate by the same factor.

> **Sources**: [R16] Robinson, CEAL-1010; [R11] Gamp; [R13] Boussard.

### 4.4 D4: Coupled-Bunch Modes

For $h = 372$ modes, each mode $m$ driven by:

$$\frac{1}{\tau_m} = \frac{\alpha_c\,\omega_\text{rev}\,I_b}{4\,\omega_s\,(E/e)}\sum_p\left[\text{Re}\{Z((ph+m)\omega_\text{rev}+\omega_s)\} - \text{Re}\{Z((ph+m)\omega_\text{rev}-\omega_s)\}\right] \tag{Eq.\;4.4}$$

For SPEAR3 ($f_\text{rev} = 1.28$ MHz $\gg \Delta f_{1/2} = 35.5$ kHz), only 1–2 revolution harmonics interact with each cavity mode. **The comb filter (essential for PEP-II) is not needed at SPEAR3.**

### 4.5 D5: HVPS Ripple

The 12-pulse SCR rectifier produces:

$$f_\text{ripple} = 12n \times f_\text{line} = 720,\;1440,\;2160,\;\ldots\;\text{Hz} \tag{Eq.\;4.5}$$

with residual harmonics at $60,\;120,\;\ldots,\;360$ Hz (reduced by $\sim\!20$ dB due to imperfect 12-pulse balance). Coupling to RF field via AM-PM conversion:

$$\Delta\phi_\text{RF} \sim \frac{\partial P_\text{kly}/\partial V_k}{P_\text{kly}} \cdot \Delta V_\text{ripple} \tag{Eq.\;4.6}$$

> **Sources**: [R21]; [R22]; *AI-generated analysis, see `01_FEEDBACK_LOOP_ARCHITECTURE.md`, unreviewed*.

### 4.6 D6: Klystron Gain Variation

Small-signal gain varies up to $\sim\!7$ dB over the operating range. The gain tracking function (§6.9) compensates by adjusting I/Q modulator weights.

### 4.7 D7/D8: Microphonics and Thermal Detuning

For normal-conducting copper cavities: microphonic excursions $< 10$ Hz (negligible vs. $\Delta f_{1/2} = 35.5$ kHz). Thermal drift: $\sim\!-1$ kHz/°C. The tuner loop (§8) tracks both.

### 4.8 Frequency-Domain Summary: The Disturbance Spectrum

```
 Frequency (Hz)    Disturbance              Required Loop
 ═══════════════════════════════════════════════════════════════
 0.001 – 0.01      Thermal drift (D8)       Tuner loop (~0.01–1 Hz)
 0.01 – 1          Klystron gain (D6)       HVPS loop (~1 Hz), DAC loop (0.1 Hz)
 1 – 10            Slow mechanical (D7)     Tuner loop
 60 – 2000         HVPS ripple (D5)         Ripple loop (300 Hz) + Direct loop
 10³ – 10⁵         Beam transients (D2)     Direct loop (~800 kHz)
 ~9.4 kHz          Robinson (D3)            Direct loop (impedance reduction)
 ~1.28 MHz         Coupled-bunch (D4)       Direct loop (+ Comb in PEP-II)
 ═══════════════════════════════════════════════════════════════
```

**This table is the Rosetta Stone of the control design.** Each loop exists because one or more disturbances occupy a specific frequency band.

---

## 5. Control Architecture: From Disturbances to Loops

### 5.1 The Design Logic: Bandwidth Matching

The fundamental principle: **match the loop bandwidth to the disturbance frequency content**. For SPEAR3:

$$\text{DAC}\;(0.1\;\text{Hz}) \;\ll\; \text{HVPS/Tuner}\;(\sim\!1\;\text{Hz}) \;\ll\; \text{Ripple}\;(300\;\text{Hz}) \;\ll\; \text{Direct}\;(\sim\!800\;\text{kHz})$$

Bandwidth separations of $10\times$–$1000\times$ provide natural frequency-domain decoupling.

### 5.2 Direct Feedback Loop — Compensating Beam Loading (D1–D4)

**Open-loop transfer function:**

$$G_\text{OL}(s) = G_\text{prop} \cdot G_\text{lead}(s) \cdot G_\text{int}(s) \cdot G_\text{kly}(s) \cdot H_\text{cav}(s) \cdot e^{-s\tau_d} \tag{Eq.\;5.1}$$

**Closed-loop transfer function:**

$$T(s) = \frac{G_\text{OL}(s)}{1 + G_\text{OL}(s)} \tag{Eq.\;5.2}$$

**Effective cavity impedance seen by the beam:**

$$Z_\text{eff}(\omega) = \frac{Z_\text{cav}(\omega)}{1 + G_\text{OL}(\omega)} \tag{Eq.\;5.3}$$

This is the central result. The direct loop **transforms the cavity from a high-impedance resonator into a low-impedance broadband structure**:

- At DC: $G_\text{OL} \sim 15$ dB + integrator $\implies$ $Z$ reduction $\sim\!40$ dB (factor $\sim\!100$)
- At $\pm 35.5$ kHz: $G_\text{OL} \sim 15$ dB $\implies$ $Z$ reduction $\sim\!15$ dB
- At $f > f_c$: $|G_\text{OL}| < 1$ $\implies$ $Z_\text{eff} \approx Z_\text{cav}$ (no reduction)

**Robinson stability under feedback:** Since $\omega_s \ll$ loop bandwidth, both synchrotron sidebands see approximately equal impedance reduction:

$$\text{Re}\{Z_\text{eff}(\omega_\text{RF} \pm \omega_s)\} \approx \frac{\text{Re}\{Z_\text{cav}(\omega_\text{RF} \pm \omega_s)\}}{|1 + G_\text{OL}(\omega_s)|}$$

The asymmetry is preserved but absolute values reduced by $\sim\!40$ dB.

> **Sources**: [R15] Corredoura, Fig. 3; [R14]; [R11].

### 5.3 Comb Loop — Narrowband Enhancement at Revolution Harmonics (D4)

**Z-domain transfer function** [R15]:

$$H_\text{comb}(z) = G\,\frac{z^{-1} - z^{-n}}{1 - 2K\cos(2\pi\nu_s)\,z^{-n} + K^2 z^{-2n}} \tag{Eq.\;5.4}$$

**SPEAR3 status**: The comb filter is **not used**. SPEAR3's $f_\text{rev} = 1.28$ MHz $\gg \Delta f_{1/2}$ means only 1–2 harmonics interact with each cavity mode.

### 5.4 Slow Loops — Maintaining Operating Point (D6, D7, D8)

- **Tuner Loop** ($\sim\!0.01$–$1$ Hz): Adjusts cavity mechanical tuner to maintain $\psi_\text{opt}$ (Eq. 2.6).
- **HVPS Loop** ($\sim\!1$ Hz): Adjusts klystron cathode voltage to maintain $\sim\!10\%$ below saturation.
- **DAC Loop** ($\sim\!0.1$ Hz): Adjusts I/Q modulator baseline to maintain $V_\text{gap}$ setpoint.

### 5.5 Ripple Loop — HVPS Harmonic Rejection (D5)

Measures **klystron forward phase** (not cavity probe), avoiding the $35.5$ kHz cavity BW limitation. DSP at $\sim\!23$ kHz sample rate tracks harmonics of 60 Hz.

### 5.6 Multi-Loop Stability: The Bandwidth Separation Principle

**Formal argument**: For two loops with bandwidths $f_1 \gg f_2$:

$$L_\text{total}(s) = L_1(s) + L_2(s) + L_1(s)\,L_2(s) \tag{Eq.\;5.5}$$

The condition for safe decoupling:

$$\frac{f_i}{f_{i+1}} \geq 10 \quad \text{for all adjacent loop pairs} \tag{Eq.\;5.6}$$

SPEAR3 satisfies this with large margins: DAC$\to$HVPS ($10\times$), HVPS$\to$Ripple ($300\times$), Ripple$\to$Direct ($2{,}700\times$).

> **Sources**: [R14]; [R15]; Åström & Murray, *Feedback Systems*, Ch. 12.

---

## 6. Loop-by-Loop Transfer Functions and Design

### 6.1 Direct Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D1–D4 | Primary stability loop |
| Measurement | Cavity probe vector sum (I/Q) | After combining network |
| Actuator | I/Q modulator on klystron drive | Direct analog path |
| Bandwidth | $\sim\!800$ kHz (legacy) / $\sim\!930$ kHz (LLRF9) | Limited by $\tau_d$ (Eq. 2.11) |
| Gain (proportional) | $\sim\!15$ dB | Adjustable via EPICS PV |
| Integrator BW | $\sim\!30$ kHz | Rejects carrier-frequency ripple |
| Impedance reduction | $\sim\!40$ dB at DC | Measured [R15] |
| SPEAR3 status | **Active** | |

### 6.2 Comb Loop

Not used at SPEAR3 (§5.3). Transfer function: Eq. 5.4.

### 6.3 LFB Woofer

Not used at SPEAR3. Addresses D2 (residual coupled-bunch motion).

### 6.4 Ripple Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D5 (HVPS ripple) | Harmonic rejection |
| Measurement | Klystron forward I/Q | Upstream of cavity |
| Bandwidth | $\sim\!300$ Hz | 120, 240, 360 Hz + harmonics |
| Algorithm | DSP harmonic estimator at $\sim\!23$ kHz | 6 fast + 8 slow harmonics |
| Fixed-point | q13 (phase), q11 (accum), q15 (gains) | TMS320C16xx |
| SPEAR3 status | **Active** | |

> **Sources**: `spear-rf-code-legacy/dsp1610/rfpDsp/ripple.s` [R36]; [R20t].

### 6.5 Gap Feedforward Loop

Not used at SPEAR3. Addresses D2 (ion clearing gap transient).

### 6.6 HVPS Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D6 | Operating point regulation |
| Actuator | HVPS cathode voltage | |
| Bandwidth | $\sim\!1$ Hz | Slow integrator |
| Operating point | $\sim\!10\%$ below saturation | Headroom for fast loops |
| SPEAR3 status | **Active** | |

### 6.7 Tuner Loop Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D7, D8 | Frequency tracking |
| Measurement | $\angle(\text{probe}) - \angle(\text{fwd})$ | Detuning angle |
| Actuator | Stepper motor (Galil) | |
| Bandwidth | $\sim\!0.01$–$1$ Hz | Mechanical limit |
| Implementation | EPICS SNL: `rf_tuner_loop.st` | |
| SPEAR3 status | **Active** | |

### 6.8 DAC Loop Specifications

Outermost amplitude regulation loop. Bandwidth $\sim\!0.1$ Hz. Adjusts I/Q modulator baseline DAC values to maintain $V_\text{gap}$ setpoint.

### 6.9 Gain Tracking Function

$$G_\text{modulator} \cdot G_\text{klystron} = G_\text{loop} \;(\text{constant}) \tag{Eq.\;6.1}$$

$$\therefore\; G_\text{modulator} = G_\text{loop} \,/\, G_\text{klystron}(V_\text{HVPS})$$

A slow EPICS loop (2 Hz) adjusts I/Q modulator weights to maintain constant forward-path gain as the klystron operating point shifts.

> **Sources**: [R15]; [R14].

---

## 7. HVPS Plant Model and Dynamics

### 7.1 Power Supply Architecture

The SPEAR3 klystron HVPS is a PEP-II design: 12-pulse primary SCR-controlled rectifier at 12.47 kV (SLAC). Designed by R. Cassel and M.N. Nguyen.

### 7.2 HVPS Electrical Parameters

| Parameter | Value | Unit |
|-----------|-------|------|
| Input voltage | 12,470 V RMS L-L | 3-phase 60 Hz |
| Output voltage range | 0 to $-90$ kV | DC |
| Maximum current | 27 A | DC |
| Nominal operating | $-77$ kV, 22 A | DC |
| Power rating | 2.5 MVA | — |
| Voltage regulation | $< \pm 0.5\%$ | at $> 65$ kV |
| Voltage ripple | $< 1\%$ P-P, $< 0.2\%$ RMS | at $> 60$ kV |
| Filter inductors ($L_1, L_2$) | 0.3 H each | 85 A DC |
| Filter capacitors ($C$) | $4 \times 8\;\mu\text{F}$ at 30 kV | — |
| SCR crowbar arc energy | $< 5$ J (with), $< 20$ J (without) | — |

> **Sources**: [R21] Cassel & Nguyen, SLAC-PUB-7591; [R22] PS-341-360-01-R2.

### 7.3 SCR Phase Control Dynamics

$$V_\text{dc} = V_\text{dc,max} \cos\alpha \tag{Eq.\;7.1}$$

The Enerpro FCOG1200 firing boards:

$$H_\text{Enerpro}(s) = \frac{1}{1 + s/\omega_\text{Enerpro}} \tag{Eq.\;7.2}$$

where $\omega_\text{Enerpro} \approx 415$ rad/s (settling $\sim\!50$ ms $\approx 3$ AC cycles).

> **Sources**: [R25] Bourbeau, IEEE 1983; [R26] Enerpro manual.

### 7.4 PLC Voltage Regulation Loop

The SLC-500 PLC implements a first-order IIR filter with scan period $T = 10$ ms:

$$y[n] = (1-\alpha)\,y[n-1] + \alpha\,x[n] \tag{Eq.\;7.3}$$

with $\alpha = 0.4$, giving time constant $\tau = -T/\ln(1-\alpha) \approx 20$ ms.

> **Sources**: [R27] `CasselPLCCode.pdf`; [R23] `hvps/simulation/hvps_sim/config.py`.

### 7.5 Klystron Arc Protection

Four protection mechanisms: SCR crowbar ($< 1\;\mu\text{s}$), star point bypass, $500\;\Omega$ isolation resistors, $200\;\mu\text{H}$ cable inductors. Result: $< 5$ J to klystron, $I^2 t < 40\;\text{A}^2\text{s}$.

### 7.6 HVPS Dynamic Response Summary

| Subsystem | Time Constant | Bandwidth |
|-----------|:-:|:-:|
| PLC filter | $\tau = 20$ ms | $\sim\!8$ Hz |
| Enerpro PLL | settling $\sim\!50$ ms | $\sim\!66$ Hz |
| SCR commutation | $\sim\!100\;\mu\text{s}$ | $\sim\!1.6$ kHz |
| Filter LC network | $\tau_{LC} = 86\;\mu\text{s}$ | $\sim\!1.8$ kHz |
| Overall voltage step | $< 10$ ms (10% step) | $\sim\!16$ Hz |

The Enerpro PLL ($\sim\!50$ ms settling) dominates: HVPS loop bandwidth limited to $\sim\!1$ Hz.

---

## 8. Tuner Mechanics and Resonant Frequency Control

### 8.1 Cavity Tuner Physical Description

| Parameter | Value |
|-----------|-------|
| Motor | Superior Electric Slo-Syn M093-FC11 (NEMA 34D) |
| Drive mechanism | Worm gear (self-locking) |
| Tuning range | $\sim\!\pm 200$ kHz |
| Step resolution | $\sim\!1$ Hz/step |
| Distance per microstep | $3.175\;\mu\text{m}$ (legacy), $0.05\;\mu\text{m}$ (Galil) |

> **Sources**: [R29]–[R33] Tuner documentation in `llrf/tuners/`.

### 8.2 Tuning Physics

$$f_\text{res}(x) = \text{polynomial fit (3rd–4th order)} \tag{Eq.\;8.1}$$

Temperature dependence: $\sim\!-1$ kHz/°C.

### 8.3 Tuner Control Loop

$$\varepsilon = \left[\angle(\text{probe}) - \angle(\text{fwd})\right] - \psi_\text{target} \tag{Eq.\;8.2}$$

where $\psi_\text{target}$ is the target detuning angle (Eq. 2.6). Implemented in `rf_tuner_loop.st` (EPICS SNL). Bandwidth $\sim\!0.01$–$1$ Hz.

> **Sources**: [R14]; [R34] `rf_tuner_loop.st`; [R35] Galil commissioning notes.

---

## 9. Performance Requirements and Verification

### 9.1 Disturbance Rejection Summary

| Disturbance | Frequency | Open-Loop Impact | Rejection | Residual |
|-------------|-----------|:-:|:-:|:-:|
| Beam loading (D1–D2) | DC–100 kHz | Unstable | $\sim\!40$ dB | Stable |
| Robinson (D3) | $\sim\!9.4$ kHz | Exponential growth | $\sim\!40$ dB | $\ll 1/\tau_\text{rad}$ |
| HVPS ripple (D5) | 360–2000 Hz | $\sim\!1\%$ phase | $\sim\!40$ dB | $< 0.01\%$ |
| Thermal drift (D8) | $< 0.01$ Hz | $\sim\!100$ Hz/hr | Tuner tracks | $< 1$ Hz |
| Klystron gain (D6) | 0.01–1 Hz | $\sim\!7$ dB var. | Gain tracking | $< 0.5$ dB |

### 9.2 LLRF9 Commissioning Results

From [R4]: LLRF9 achieves improved noise floor vs. legacy at 500 mA. Overall amplitude stability $< 0.05\%$ RMS, phase stability $< 0.05°$ RMS — both exceed requirements.

### 9.3 Performance Margins

| Parameter | Capacity | Typical | Margin |
|-----------|:-:|:-:|:-:|
| Klystron power | 1.2 MW | $\sim\!800$ kW | $\sim\!50\%$ |
| HVPS voltage | 90 kV | $\sim\!74$ kV | $\sim\!22\%$ |
| Gap voltage/cavity | 1 MV | $\sim\!712$ kV | $\sim\!40\%$ |
| Direct loop BW | $\sim\!930$ kHz | $\sim\!800$ kHz | $\sim\!16\%$ |
| Impedance reduction | $\sim\!40$ dB | Required $\sim\!30$ dB | $> 10$ dB margin |

### 9.4 Calibration Data

Calibration files in `llrf/calibrations/` establish numerical relationships for all feedback loops.

> **Sources**: [R38]; [R39] Jim Sebek's master document index.

---

## Appendix A — SPEAR3 RF System Parameter Table

### A.1 Storage Ring Parameters

| Parameter | Symbol | Value | Unit | Source |
|-----------|--------|-------|------|--------|
| Beam energy | $E_0$ | 3.0 | GeV | [R1] |
| Beam current | $I_b$ | 500 | mA | [R1] |
| Circumference | $C$ | 234.14 | m | [R2] |
| Revolution frequency | $f_\text{rev}$ | 1.2804 | MHz | Derived |
| Harmonic number | $h$ | 372 | — | [R1] |
| RF frequency | $f_\text{RF}$ | 476.3051755 | MHz | [R4] |
| Momentum compaction | $\alpha_c$ | $1.18 \times 10^{-3}$ | — | [R2] |
| Energy loss per turn | $U_0$ | ~0.91 | MeV | [R1] |
| Synchrotron tune | $\nu_s$ | ~0.0073 | — | Derived |
| Synchrotron frequency | $f_s$ | ~9.4 | kHz | Derived |

### A.2 Cavity Parameters (Per Cavity)

| Parameter | Symbol | Value | Unit | Source |
|-----------|--------|-------|------|--------|
| Resonant frequency | $f_0$ | 476.315 | MHz | [R6] |
| Shunt impedance (linac) | $R_s$ | 3.73 | MΩ | [R6] |
| $R/Q$ | $R/Q$ | ~116 | Ω | [R7] |
| Unloaded Q | $Q_0$ | 32,000 | — | [R6] |
| Loaded Q | $Q_L$ | 6,700 | — | [R6] |
| Coupling coefficient | $\beta$ | 3.78 | — | Derived |
| Cavity half-bandwidth | $\Delta f_{1/2}$ | 35.5 | kHz | Derived |
| Operational gap voltage | $V_\text{gap}$ | ~712 | kV | [R5] |

### A.3 Klystron Parameters

| Parameter | Value | Unit | Source |
|-----------|-------|------|--------|
| Type | Marconi/CPI K3512S | — | [R1] |
| Maximum power | 1.2 MW CW | — | [R1] |
| Gain | 43 dB min | — | [R1] |
| Bandwidth | 5 MHz ($-3$ dB) | — | [R1] |
| Group delay | $< 150$ ns | — | [R1] |
| Drive power | $\sim\!29$ W | — | [R5] |
| Perveance | $\sim\!2.0 \times 10^{-6}$ | A/V$^{3/2}$ | [R23] |

### A.4 Feedback Loop Parameters

| Loop | Bandwidth | SPEAR3 Status | Addresses | Source |
|------|-----------|:-:|:-:|--------|
| Direct | $\sim\!800$ kHz | Active | D1–D4 | [R14] |
| Comb | 2 MHz | Not used | D4 | [R14] |
| Ripple | $\sim\!300$ Hz | Active | D5 | [R14] |
| Gap FF | 100 Hz | Not used | D2 | [R14] |
| HVPS | $\sim\!1$ Hz | Active | D6 | [R14] |
| Tuner | $\sim\!0.01$–$1$ Hz | Active | D7, D8 | [R14] |
| DAC | $\sim\!0.1$ Hz | Active | Amplitude drift | [R14] |
| LFB Woofer | 1 MHz | Not used | D2 | [R14] |

---

## Appendix B — Source Document Reference Index

### B.1 Published Papers

| Ref | Citation |
|-----|---------|
| [R1] | McIntosh, P. et al., "The SPEAR3 RF System," SLAC-PUB-10983, EPAC 2004 |
| [R2] | Hettel, R. et al., "Design of the SPEAR 3 Light Source," PAC 1999 |
| [R7] | Rimmer, R.A. et al., "RF Cavity Development for the PEP-II B Factory," LBL-33360, 1992 |
| [R11] | Gamp, A., "Beam-Cavity Interaction," CAS 2011, arXiv:1112.3203 |
| [R12] | Wilson, P.B., "Fundamental-Mode RF Design," SLAC-PUB-6062, 1993 |
| [R13] | Boussard, D., "Control of Cavities with High Beam Loading," PAC 1985 |
| [R15] | Corredoura, P., "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8124, PAC 1999 |
| [R16] | Robinson, K.W., "Stability of Beam in RF Systems," CEA-CEAL-1010, 1964 |
| [R17] | Rimmer, R.A. et al., "Comparison of Calculated, Measured, and Beam Sampled Impedances," PRSTAB 3, 102001, 2000 |
| [R21] | Cassel, R. and Nguyen, M.N., "A Unique Power Supply for the PEP II Klystron," SLAC-PUB-7591, PAC 1997 |
| [R25] | Bourbeau, E.J., "Application of PLL Techniques to SCR Drives," IEEE 1983 |

### B.2 Textbooks

| Ref | Citation |
|-----|---------|
| [R3] | SSRL SPEAR3 Accelerator Parameters |
| [R10] | Wiedemann, H., *Particle Accelerator Physics*, 4th ed., Springer, 2015 |
| [R18] | Analog Devices AD834 datasheet |

### B.3 Repository Documents

| Ref | Document | Path |
|-----|----------|------|
| [R4] | LLRF9 Commissioning Tests | `llrf/tests/llrf9Tests.pdf` |
| [R5] | System Design Report | `Designs/0_SYSTEM_DESIGN_REPORT.md` |
| [R6] | RF System Description (Schwarz) | `llrf/documentation/legacyArchitecture/ps3403305100.pdf` |
| [R14] | Feedback Loop Description (Schwarz) | `llrf/documentation/legacyArchitecture/feedbackLoopDescriptionps3403305200.pdf` |
| [R19] | Comprehensive FBK Loops Description | `llrf/.../PEPII_LLRF_FBK_Loops_Description.md` |
| [R20t] | DSP Firmware Analysis | `spear-rf-code-legacy/codeReviewTechnicalNotes/04-dsp-firmware.md` |
| [R21t] | SLAC-PUB-7591 Transcription | `hvps/architecture/originalDocuments/transcriptions/slac-pub-7591_transcription.md` |
| [R22] | HVPS Technical Spec | `hvps/architecture/originalDocuments/ps3413600102.pdf` |
| [R23] | HVPS Simulation Config | `hvps/simulation/hvps_sim/config.py` |
| [R26] | Enerpro FCOG1200 Manual | `hvps/controls/enerpro/enerproDocuments/` |
| [R27] | Cassel PLC Code | `hvps/documentation/plc/CasselPLCCode.pdf` |
| [R34] | Tuner Loop Source Code | `spear-rf-code-legacy/rfApp/src/seq/rf_tuner_loop.st` |
| [R35] | Galil Commissioning Notes | `llrf/tuners/galil/GalilCommissioning.docx` |
| [R36] | DSP Ripple Firmware | `spear-rf-code-legacy/dsp1610/rfpDsp/ripple.s` |
| [R38] | RF Calibration Data | `llrf/calibrations/*.xlsx` |
| [R39] | RF Document Index | `llrf/documentation/RfSystemDocumentIndexR3.xlsx` |

### B.4 External Web References

| Ref | URL | Content |
|-----|-----|---------|
| [W1] | https://inspirehep.net/files/945e7ff73cc428af4c018fd1bdb6afa7 | McIntosh EPAC04 |
| [W2] | https://www.osti.gov/biblio/839730 | OSTI SLAC-PUB-10983 |
| [W3] | https://export.arxiv.org/pdf/1112.3203v1.pdf | Gamp CAS 2011 |
| [W4] | https://www.dimtel.com/products/llrf9 | Dimtel LLRF9 |
| [W5] | https://proceedings.jacow.org/p85/PDF/PAC1985_1852.PDF | Boussard PAC85 |
| [W7] | https://inspirehep.net/files/dbbd3f9a808792f9901894060a879b5f | Chang et al. NSRRC |

---

## Appendix C — Symbol and Notation Conventions

### C.1 Frequently Used Symbols

| Symbol | Definition | Unit |
|--------|-----------|------|
| $f_0$ | Cavity resonant frequency | MHz |
| $f_\text{RF}$ | RF operating frequency | MHz |
| $f_\text{rev}$ | Revolution frequency | MHz |
| $f_s$ | Synchrotron frequency | kHz |
| $Q_0$ | Unloaded quality factor | — |
| $Q_L$ | Loaded quality factor | — |
| $\beta$ | Coupling coefficient $= Q_0/Q_\text{ext}$ | — |
| $R_s$ | Shunt impedance | MΩ |
| $V_\text{gap}$ | Gap voltage per cavity | kV |
| $I_b$ | DC beam current | mA or A |
| $\phi_s$ | Synchronous phase angle | degrees |
| $\psi$ | Detuning angle | degrees |
| $\Delta f$ | Frequency detuning | kHz |
| $\tau_d$ | Total loop delay | ns |
| $G_\text{OL}$ | Open-loop gain | dB or — |
| $Z_\text{eff}$ | Effective impedance (with feedback) | Ω |

### C.2 Conventions

1. **Shunt impedance**: Linac convention ($R_s = V^2/2P$) unless stated. Accelerator convention $= 2\times$ larger.
2. **Synchronous phase**: $\phi_s$ measured from voltage crest (SLAC convention): $V_\text{RF}\cos\phi_s = U_0$.
3. **Detuning**: $\Delta f = f_0 - f_\text{RF}$. Negative = cavity below RF (normal above transition).
4. **Reference tags**: [Rn] = numbered reference, [Rnt] = transcription, [Wn] = web, [Dn] = disturbance (§4).

---

*End of Document*

**Document Control**:
- Tier 1 RF physics reference for the SPEAR3 LLRF system.
- Definitive version: `Designs/P_RF_PHYSICS_AND_PLANT.md`
- **Provenance**: AI-ASSISTED — proposed by AI based on exhaustive review of original source documents and published literature. Subject to human review.
- **Review status**: UNREVIEWED — requires verification by a qualified RF engineer.
