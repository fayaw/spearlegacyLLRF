# SPEAR3 RF System — RF Physics, Control Theory and Physical Plant

**Document ID**: Doc P
**Version**: 2.5
**Date**: March 25, 2026
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
| 2.2 | 2026-03-24 | GitHub rendering fix: converted all display equations to fenced math code blocks for reliable MathJax rendering; moved equation labels to text below blocks; cleaned up negative thin spaces, thousand-separator braces, and degree symbols. |
| 2.3 | 2026-03-24 | Attempted \\tag{} for inline equation numbering — caused rendering failures on GitHub. Reverted. |
| 2.4 | 2026-03-24 | Inline equation numbering via \\qquad \\text{} — labels now appear on the same line as equations without using \\tag{}. |
| 2.5 | 2026-03-25 | Deep review of sections 6, 8, 9: expanded loop-by-loop documentation with code-verified parameters, transfer functions, state machines, and PV names; added bandwidth hierarchy table (§6.0); expanded PEP-II heritage features with physics rationale (§6.3); documented HVPS/DAC/tuner loop state machines and interlocks (§6.4–6.6); expanded tuner signal path and state machine documentation (§8.3); comprehensive calibration system taxonomy — rf_calib.st (28 states), HVPS PLC registers, hardware calibration files (§9.4); fixed math rendering (`DAC→HVPS`). |

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

The SPEAR3 RF system must deliver a 476.3 MHz accelerating voltage of $\sim 2.85$ MV across four cavities with amplitude stability $< 0.1\%$ RMS and phase stability $< 0.1^\circ$ RMS, in the presence of beam loading forces that — without feedback — would drive the system unstable within microseconds.

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
| Phase stability | $< 0.1^\circ$ RMS | $< 0.05^\circ$ RMS | Bunch timing, longitudinal emittance |
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

```math
H_\text{cav}(s) = \frac{R_s \,\omega_{1/2}}{s + \omega_{1/2} + j\Delta\omega} \qquad \text{(Eq. 2.1a)}
```

where $\omega_{1/2} = \omega_0/(2Q_L)$ is the cavity half-bandwidth. The **impedance seen by the beam** at frequency offset $\Delta\omega$ from $\omega_\text{RF}$:

```math
Z_\text{cav}(\Delta\omega) = \frac{R_s}{1 + j\,2Q_L\,\Delta\omega/\omega_0} \qquad \text{(Eq. 2.1)}
```

**Cavity half-bandwidth:**

```math
\Delta f_{1/2} = \frac{f_0}{2Q_L} = \frac{476.315\;\text{MHz}}{2 \times 6700} = 35.5\;\text{kHz} \qquad \text{(Eq. 2.1b)}
```

This determines the cavity natural response time $\tau_\text{cav} = 1/(2\pi\Delta f_{1/2}) \approx 4.5\;\mu\text{s}$.

#### 2.1.3 Beam Loading — Steady-State Phasor Analysis

The beam-induced voltage at resonance:

```math
V_{b,\text{res}} = I_b \cdot R_s = 0.5\;\text{A} \times 3.73\;\text{M}\Omega = 1.865\;\text{MV} \qquad \text{(Eq. 2.2)}
```

This exceeds the desired gap voltage ($V_\text{gap} = 712$ kV) by a factor of 2.6, demonstrating that **beam loading is the dominant effect**.

**Synchronous phase** — In the convention where $\phi_s$ is measured from the voltage crest (SLAC convention, used throughout this document):

```math
V_\text{RF} \cos\phi_s = U_0 \qquad \text{(Eq. 2.4)}
```

```math
\cos\phi_s = \frac{U_0}{V_\text{RF}} = \frac{0.91\;\text{MeV}}{2.85\;\text{MV}} = 0.319 \implies \phi_s \approx 71.4^\circ \qquad \text{(Eq. 2.4a)}
```

Note: $\sin\phi_s = \sin(71.4^\circ) = 0.948$, which appears in the beam loading compensation formulas below.

**Optimum detuning** — minimizes reflected power at the input coupler:

```math
\tan\psi_\text{opt} = -\frac{I_b \, R_s \, \sin\phi_s}{V_\text{gap}} = -\frac{0.5 \times 3.73 \times 10^6 \times 0.948}{712 \times 10^3} = -2.48 \qquad \text{(Eq. 2.5)}
```

```math
\psi_\text{opt} \approx -68^\circ \qquad \text{(Eq. 2.5a)}
```

**Optimum frequency detuning:**

```math
\Delta f_\text{opt} = \frac{f_0 \tan\psi_\text{opt}}{2Q_L} = \frac{476.3\;\text{MHz} \times (-2.48)}{2 \times 6700} \approx -88\;\text{kHz} \qquad \text{(Eq. 2.6)}
```

The cavity must be tuned $\sim 88$ kHz **below** $f_\text{RF}$ at 500 mA.

**Required generator power per cavity:**

```math
P_\text{gen} = \frac{V_\text{gap}^2}{4R_L}\left[1 + \left(\frac{I_b R_s \sin\phi_s}{V_\text{gap}}\right)^{2}\right]^{1/2} + \frac{I_b V_\text{gap}\cos\phi_s}{n_\text{cav}} \qquad \text{(Eq. 2.7)}
```

where $R_L = R_s/(1+\beta) \approx 780\;\text{k}\Omega$, giving $\approx 135$ kW/cavity, $\approx 540$ kW total (within the 1.2 MW klystron capacity).

> **Sources**: [R11] Gamp, CAS 2011; [R12] Wilson, SLAC-PUB-6062; [R13] Boussard, PAC 1985.

### 2.2 Klystron as the Actuator

For control analysis, the klystron is modeled as:

```math
G_\text{kly}(s) = K_\text{kly} \cdot e^{-s\tau_\text{kly}} \qquad \text{(Eq. 2.8)}
```

where $K_\text{kly}$ is the small-signal gain and $\tau_\text{kly} < 150$ ns.

| Parameter | Value | Unit |
|-----------|-------|------|
| Maximum output power | 1.2 MW | CW |
| Gain | 43 dB (min) | — |
| Bandwidth | 5 MHz | −3 dB |
| Group delay | $< 150$ ns | — |
| Perveance | $\sim 2.0 \times 10^{-6}$ | A/V$^{3/2}$ |

**Saturation model:**

```math
P_\text{out} = P_\text{sat} \cdot \frac{P_\text{in}/P_\text{in,sat}}{1 + P_\text{in}/P_\text{in,sat}} \qquad \text{(Eq. 2.9)}
```

**AM-PM conversion** — klystron output phase sensitivity to cathode voltage:

```math
\Delta\phi_\text{kly} \propto \frac{\Delta V_k}{V_k} \qquad \text{(Eq. 2.10)}
```

> **Sources**: [R1]; [R15] Corredoura, PAC 1999; [R5].

### 2.3 Loop Delay Budget — The Fundamental Bandwidth Ceiling

The maximum stable crossover frequency (with $\sim 45^\circ$ phase margin):

```math
\boxed{f_{c,\text{max}} \approx \frac{1}{4\tau_d}} \qquad \text{(Eq. 2.11)}
```

This is the single most important constraint in the entire control design.

| Component | Legacy (analog) | LLRF9 (digital) |
|-----------|:-:|:-:|
| Klystron group delay | $< 150$ ns | $< 150$ ns |
| I/Q modulator | $< 5$ ns | $< 5$ ns |
| Cable propagation | $\sim 50$ ns | $\sim 50$ ns |
| Electronics/computation | $\sim 300$ ns | $\sim 65$ ns |
| **Total** $\tau_d$ | **$\sim 500$ ns** | **$\sim 270$ ns** |
| $f_{c,\text{max}}$ | **$\sim 500$ kHz** | **$\sim 926$ kHz** |

### 2.4 Complete Open-Loop Plant Transfer Function

```math
G_\text{plant}(s) = G_0 \cdot H_\text{cav}(s) \cdot e^{-s\tau_d} = \frac{G_0 \,\omega_{1/2}}{s + \omega_{1/2} + j\Delta\omega}\; e^{-s\tau_d} \qquad \text{(Eq. 2.12)}
```

The cavity bandwidth ($35.5$ kHz) and the loop delay ($270$–$500$ ns) together define the limits of what feedback can achieve.

---

## 3. I/Q Signal Processing Framework

### 3.1 Baseband I/Q Representation

All RF feedback loops use baseband In-phase and Quadrature (I/Q) techniques:

```math
V_\text{RF}(t) = I(t)\cos(\omega_\text{RF}t) - Q(t)\sin(\omega_\text{RF}t) \qquad \text{(Eq. 3.0)}
```

where $I(t) = A(t)\cos\phi(t)$ and $Q(t) = A(t)\sin\phi(t)$, with inverse relations:

```math
A(t) = \sqrt{I^2 + Q^2}\,,\qquad \phi(t) = \text{atan2}(Q, I) \qquad \text{(Eq. 3.0a)}
```

### 3.2 Baseband I/Q Modulator

The I/Q modulator performs a scaled rotation:

```math
\begin{pmatrix} I_\text{out} \\ Q_\text{out} \end{pmatrix} = G \begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{pmatrix} \begin{pmatrix} I_\text{in} \\ Q_\text{in} \end{pmatrix} \qquad \text{(Eq. 3.1)}
```

**Implementation**: Four AD834 four-quadrant multipliers + two EL2073 summing amplifiers. Group delay $< 5$ ns, full-power BW $> 40$ MHz, dynamic range $> 50$ dB. Total system: 7 I/Q modulators, 56 DAC channels.

> **Sources**: [R15] Corredoura, Eq. 2; [R14] Schwarz, PS-340-330-52-R0.

### 3.3 I/Q Demodulation

RF signals are converted to baseband I/Q using $+13$ dBm demodulators. Outputs: AC-coupled into $50\;\Omega$, low-pass filtered ($F_c = 225$ MHz), video amplified (17 dB) to $\pm 1$ V.

### 3.4 Cavity Probe Vector Sum

Each of the 4 cavity probe signals is demodulated to I/Q and combined through a programmable network (4 I/Q modulators + 2 summing amplifiers) to form the **total accelerating RF vector**.

### 3.5 Error Signal Generation

```math
\vec{E} = \vec{V}_\text{ref} - \vec{V}_\text{probe} \qquad \text{(Eq. 3.2)}
```

```math
\vec{V}_\text{drive} = G_\text{loop} \cdot \vec{E} = G_\text{loop}\left(\vec{V}_\text{ref} - \vec{V}_\text{probe}\right) \qquad \text{(Eq. 3.3)}
```

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

```math
\frac{1}{\tau} = \frac{I_b\,\alpha_c\,f_\text{RF}}{2\,\nu_s\,\beta^2\,(E/e)}\;R_{cb} \qquad \text{(Eq. 4.1)}
```

where $R_{cb} = \sum_n \text{Re}\left[Z(\omega_\text{RF} + n\omega_\text{rev} + \omega_s) - Z(\omega_\text{RF} + n\omega_\text{rev} - \omega_s)\right]$.

**Without feedback**, the peak cavity impedance of $\sim 750\;\text{k}\Omega$ produces growth rates faster than $T_\text{rev} \approx 0.78\;\mu\text{s}$. This single fact drove the PEP-II system design to include multiple feedback loops [R15].

> **Sources**: [R15] Corredoura, PAC 1999, Eq. 1; [R11] Gamp, CAS 2011.

### 4.3 D3: Robinson Instability

**Robinson stability criterion** (above transition):

```math
\text{Re}\{Z_\text{eff}(\omega_\text{RF} + \omega_s)\} < \text{Re}\{Z_\text{eff}(\omega_\text{RF} - \omega_s)\} \qquad \text{(Eq. 4.2)}
```

**Robinson growth rate:**

```math
\frac{1}{\tau_\text{Rob}} = \frac{\alpha_c\,\omega_\text{rev}\,I_b}{4\,\omega_s\,(E/e)} \left[\text{Re}\{Z(\omega_\text{RF} + \omega_s)\} - \text{Re}\{Z(\omega_\text{RF} - \omega_s)\}\right] \qquad \text{(Eq. 4.3)}
```

Direct feedback reduces $Z_\text{eff} = Z_\text{cav}/(1 + G_\text{OL})$, reducing the growth rate by the same factor.

> **Sources**: [R16] Robinson, CEAL-1010; [R11] Gamp; [R13] Boussard.

### 4.4 D4: Coupled-Bunch Modes

For $h = 372$ modes, each mode $m$ driven by:

```math
\frac{1}{\tau_m} = \frac{\alpha_c\,\omega_\text{rev}\,I_b}{4\,\omega_s\,(E/e)}\sum_p\left[\text{Re}\{Z((ph+m)\omega_\text{rev}+\omega_s)\} - \text{Re}\{Z((ph+m)\omega_\text{rev}-\omega_s)\}\right] \qquad \text{(Eq. 4.4)}
```

For SPEAR3 ($f_\text{rev} = 1.28$ MHz $\gg \Delta f_{1/2} = 35.5$ kHz), only 1–2 revolution harmonics interact with each cavity mode. **The comb filter (essential for PEP-II) is not needed at SPEAR3.**

### 4.5 D5: HVPS Ripple

The 12-pulse SCR rectifier produces:

```math
f_\text{ripple} = 12n \times f_\text{line} = 720,\;1440,\;2160,\;\ldots\;\text{Hz} \qquad \text{(Eq. 4.5)}
```

with residual harmonics at $60,\;120,\;\ldots,\;360$ Hz (reduced by $\sim 20$ dB due to imperfect 12-pulse balance). Coupling to RF field via AM-PM conversion:

```math
\Delta\phi_\text{RF} \sim \frac{\partial P_\text{kly}/\partial V_k}{P_\text{kly}} \cdot \Delta V_\text{ripple} \qquad \text{(Eq. 4.6)}
```

> **Sources**: [R21]; [R22]; *AI-generated analysis, see `01_FEEDBACK_LOOP_ARCHITECTURE.md`, unreviewed*.

### 4.6 D6: Klystron Gain Variation

Small-signal gain varies up to $\sim 7$ dB over the operating range. The gain tracking function (§6.9) compensates by adjusting I/Q modulator weights.

### 4.7 D7/D8: Microphonics and Thermal Detuning

For normal-conducting copper cavities: microphonic excursions $< 10$ Hz (negligible vs. $\Delta f_{1/2} = 35.5$ kHz). Thermal drift: $\sim -1$ kHz/°C. The tuner loop (§8) tracks both.

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

```math
\text{DAC}\;(0.1\;\text{Hz}) \;\ll\; \text{HVPS/Tuner}\;(\sim 1\;\text{Hz}) \;\ll\; \text{Ripple}\;(300\;\text{Hz}) \;\ll\; \text{Direct}\;(\sim 800\;\text{kHz})
```
Bandwidth separations of $10\times$–$1000\times$ provide natural frequency-domain decoupling.

### 5.2 Direct Feedback Loop — Compensating Beam Loading (D1–D4)

**Open-loop transfer function:**

```math
G_\text{OL}(s) = G_\text{prop} \cdot G_\text{lead}(s) \cdot G_\text{int}(s) \cdot G_\text{kly}(s) \cdot H_\text{cav}(s) \cdot e^{-s\tau_d} \qquad \text{(Eq. 5.1)}
```

**Closed-loop transfer function:**

```math
T(s) = \frac{G_\text{OL}(s)}{1 + G_\text{OL}(s)} \qquad \text{(Eq. 5.2)}
```

**Effective cavity impedance seen by the beam:**

```math
Z_\text{eff}(\omega) = \frac{Z_\text{cav}(\omega)}{1 + G_\text{OL}(\omega)} \qquad \text{(Eq. 5.3)}
```

This is the central result. The direct loop **transforms the cavity from a high-impedance resonator into a low-impedance broadband structure**:

- At DC: $G_\text{OL} \sim 15$ dB + integrator $\implies$ $Z$ reduction $\sim 40$ dB (factor $\sim 100$)
- At $\pm 35.5$ kHz: $G_\text{OL} \sim 15$ dB $\implies$ $Z$ reduction $\sim 15$ dB
- At $f > f_c$: $|G_\text{OL}| < 1$ $\implies$ $Z_\text{eff} \approx Z_\text{cav}$ (no reduction)

**Robinson stability under feedback:** Since $\omega_s \ll$ loop bandwidth, both synchrotron sidebands see approximately equal impedance reduction:

```math
\text{Re}\{Z_\text{eff}(\omega_\text{RF} \pm \omega_s)\} \approx \frac{\text{Re}\{Z_\text{cav}(\omega_\text{RF} \pm \omega_s)\}}{|1 + G_\text{OL}(\omega_s)|}
```
The asymmetry is preserved but absolute values reduced by $\sim 40$ dB.

> **Sources**: [R15] Corredoura, Fig. 3; [R14]; [R11].

### 5.3 Comb Loop — Narrowband Enhancement at Revolution Harmonics (D4)

**Z-domain transfer function** [R15]:

```math
H_\text{comb}(z) = G\,\frac{z^{-1} - z^{-n}}{1 - 2K\cos(2\pi\nu_s)\,z^{-n} + K^2 z^{-2n}} \qquad \text{(Eq. 5.4)}
```

**SPEAR3 status**: The comb filter is **not used**. SPEAR3's $f_\text{rev} = 1.28$ MHz $\gg \Delta f_{1/2}$ means only 1–2 harmonics interact with each cavity mode.

### 5.4 Slow Loops — Maintaining Operating Point (D6, D7, D8)

- **Tuner Loop** ($\sim 0.01$–$1$ Hz): Adjusts cavity mechanical tuner to maintain $\psi_\text{opt}$ (Eq. 2.6).
- **HVPS Loop** ($\sim 1$ Hz): Adjusts klystron cathode voltage to maintain $\sim 10\%$ below saturation.
- **DAC Loop** ($\sim 0.1$ Hz): Adjusts I/Q modulator baseline to maintain $V_\text{gap}$ setpoint.

### 5.5 Ripple Loop — HVPS Harmonic Rejection (D5)

Measures **klystron forward phase** (not cavity probe), avoiding the $35.5$ kHz cavity BW limitation. DSP at $\sim 23$ kHz sample rate tracks harmonics of 60 Hz.

### 5.6 Multi-Loop Stability: The Bandwidth Separation Principle

**Formal argument**: For two loops with bandwidths $f_1 \gg f_2$:

```math
L_\text{total}(s) = L_1(s) + L_2(s) + L_1(s)\,L_2(s) \qquad \text{(Eq. 5.5)}
```

The condition for safe decoupling:

```math
\frac{f_i}{f_{i+1}} \geq 10 \quad \text{for all adjacent loop pairs} \qquad \text{(Eq. 5.6)}
```

SPEAR3 satisfies this with large margins: DAC→HVPS ($10\times$), HVPS→Ripple ($300\times$), Ripple→Direct ($2700\times$).

> **Sources**: [R14]; [R15]; Åström & Murray, *Feedback Systems*, Ch. 12.

---

## 6. Loop-by-Loop Transfer Functions and Design

This section documents each feedback loop in the SPEAR3 LLRF system, ordered from fastest to slowest. All five active loops and the inactive PEP-II heritage features are covered with code-verified parameters.

### 6.0 Loop Bandwidth Hierarchy

The following table summarizes the complete bandwidth hierarchy. Adjacent loops are separated by at minimum the required factor of 10 in bandwidth (Eq. 5.6), ensuring frequency-domain decoupling.

| Loop | Bandwidth | Disturbance | Implementation | Source File(s) |
|------|:-:|:-:|:-:|:-:|
| Direct (feedback) | ~800 kHz | D1–D4 | Analog (RFP module) | Hardware |
| Ripple (harmonic) | 60–1500 Hz | D5 | DSP assembly (AT&T DSP1610) | `sp3ripple.s` |
| HVPS (voltage) | ~0.1 Hz | D6 | EPICS SNL | `rf_hvps_loop.st` |
| DAC (amplitude) | ~0.1 Hz | D6 | EPICS SNL | `rf_dac_loop.st` |
| Tuner (frequency) | ~0.01 Hz | D7, D8 | EPICS SNL | `rf_tuner_loop.st` |

**Separation ratios** (code-verified from maximum cycle times):

| Adjacent Pair | Ratio | Requirement |
|:-:|:-:|:-:|
| Direct / Ripple | ~500x | >= 10x |
| Ripple / HVPS | ~600x | >= 10x |
| Ripple / DAC | ~600x | >= 10x |
| HVPS and DAC | ~1x | Co-equal, orthogonal actuators |
| DAC / Tuner | ~10x | >= 10x |

The HVPS and DAC loops operate at comparable bandwidths (~0.1 Hz, both with `MAX_INTERVAL = 10.0` s) but act on orthogonal actuators (cathode voltage vs. modulator DAC counts) and can be treated as parallel rather than cascaded.

### 6.1 Direct Loop — Fast Cavity Impedance Control

The direct feedback loop is the primary stability loop, operating entirely in analog hardware on the RFP (RF Processor) VXI module. It measures the cavity probe vector sum and drives the I/Q modulator to reduce effective cavity impedance at beam harmonics.

**Open-loop transfer function** (from Eq. 5.1):

```math
G_\text{OL}(s) = G_\text{prop} \cdot G_\text{lead}(s) \cdot G_\text{int}(s) \cdot G_\text{kly}(s) \cdot H_\text{cav}(s) \cdot e^{-s\tau_d} \qquad \text{(Eq. 6.1)}
```

**Effective impedance with feedback** (from Eq. 5.3):

```math
Z_\text{eff}(s) = \frac{Z_\text{cav}(s)}{1 + G_\text{OL}(s)} \qquad \text{(Eq. 6.2)}
```

At DC (below the loop bandwidth), the open-loop gain is approximately 40 dB, yielding impedance reduction of ~100x. This is the critical mechanism for Robinson instability suppression (D3) and steady-state beam loading compensation (D1).

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D1–D4 | Primary stability loop |
| Measurement | Cavity probe vector sum (I/Q) | After combining network |
| Actuator | I/Q modulator on klystron drive | Direct analog path |
| Bandwidth | ~800 kHz (legacy) / ~930 kHz (LLRF9) | Limited by total loop delay (Eq. 2.11) |
| Gain (proportional) | ~15 dB | Adjustable via EPICS PV `{STN}:STN:RFP:DIRECTLOOP` |
| Integrator BW | ~30 kHz | Rejects carrier-frequency ripple |
| Impedance reduction | ~40 dB at DC | Measured [R15] |
| Phase rotation | 2x2 I/Q matrix | Compensates cable and klystron phase |
| SPEAR3 status | **Active** | |

The direct loop phase is computed by `subSysPhaseTot` in `subSys.c` (line 178), which implements rate-limited delta tracking with frequency-offset compensation from the tuner position polynomial model. It computes the delta phase from frequency offset: `K = -0.000360 * group_delay * freq_offset * conv_const` (when loop and tracking are on), then tracks total phase as `L = L + rate_limited(C + D + K - L)` with +/-180 deg wrap.

> **Sources**: [R15]; [R14]; `subSys.c` line 178 (phase computation); RFP module hardware.

### 6.2 Ripple Loop — HVPS Harmonic Rejection

The ripple loop cancels power supply harmonics (D5) using a bank of narrowband resonant controllers implemented on the AT&T DSP1610 processor. Each harmonic channel estimates and subtracts one spectral component of the HVPS ripple from the klystron drive signal.

**Transfer function** — the ripple loop implements a parallel bank of resonant controllers:

```math
H_\text{ripple}(z) = \sum_{n \in \mathcal{F}} H_n(z) + \sum_{m \in \mathcal{S}} H_m(z) \qquad \text{(Eq. 6.3)}
```

where F denotes fast harmonic channels and S denotes slow harmonic channels. Each channel implements a second-order resonant section at the target harmonic frequency, using downloadable coefficients from EPICS via the `Coef_IOC` array in DSP shared memory.

**SPEAR3-specific configuration** (from `sp3ripple.s`, W. Ross, July 2006):

| Parameter | Fast Harmonics | Slow Harmonics |
|-----------|:-:|:-:|
| Count | 26 (SPEAR3, reduced from PEP-II's 34) | 4 |
| Sample rate | ~23 kHz | ~23/4 = 5.75 kHz effective |
| Processing | Every DSP cycle | One per cycle (interleaved) |
| Frequency coverage | Higher harmonics (> 360 Hz) | Near 60 Hz fundamental |
| Phase precision | q13 (double-precision multiply) | q13 (double-precision multiply) |
| Gain precision | q15 | q15 |

The SPEAR3 variant (`sp3ripple.s`) reduced the fast harmonic count from 34 (PEP-II) to 26 to accommodate the higher sampling frequency needed for SPEAR3's 476.3 MHz RF. The slow harmonics use interleaved processing — only one slow channel is updated each sample cycle — providing better coefficient resolution for low-frequency harmonics where the discrete-time resonant coefficients approach 2.0 and 16-bit word resolution becomes limiting.

The code evolved significantly for SPEAR3: W. Ross (March 2006) modified the algorithm to use the klystron ADC available on the Rev 4 RFP module (replacing data from the IQA module), removed the software FIFO for the reference signal, and replaced amplitude estimation with phase-only estimation using double-precision multiplication. The result: 26 fast phase harmonics + 4 slow phase harmonics.

**DC gain coefficient tracking**: The ripple loop gain is automatically adjusted to track klystron gain variations. The function `subSysDCcoeff` in `subSys.c` (line 277) implements this: it adjusts the DC coefficient based on the deviation between desired and actual klystron gain, using deadband limiting. The DAC loop (`rf_dac_loop.st`) loads updated ripple amplitude setpoints via the `ripple_loop_load` PV whenever `ripple_loop_ampl_ef` fires.

> **Sources**: `sp3ripple.s` (W. Ross, 2006) [R36]; `ripple.s` (Claus & Corredoura, 1996) [R36]; `subSys.c` line 277.

### 6.3 PEP-II Heritage Features — Not Commissioned at SPEAR3

The LLRF9/legacy VXI crate contains three subsystems inherited from the PEP-II LLRF design that are **not used at SPEAR3**. They are documented here for completeness and to explain the unused VXI slot allocations.

**Comb Filter Loop** (VXI slots 6–7: CFM1, CFM2):

The comb filter provides narrowband gain enhancement at revolution-frequency harmonics to damp coupled-bunch instabilities (D4). Its transfer function (Eq. 5.4):

```math
H_\text{comb}(z) = \frac{G_c}{1 - G_c\,z^{-N}} \qquad N = f_\text{RF}/f_\text{rev}
```

At PEP-II, with high beam current (> 1 A) distributed across hundreds of bunches feeding multiple cavities, coupled-bunch modes driven by cavity higher-order modes (HOMs) and fundamental impedance required active damping. SPEAR3, with only 2 cavities and moderate beam loading at 500 mA, has sufficiently weak coupled-bunch driving terms that the direct loop's ~40 dB impedance reduction alone stabilizes all modes. The comb filter modules (`{STN}:STN:CFM1`, `{STN}:STN:CFM2`) are physically present but not programmed. In the calibration sequence `rf_calib.st`, comb-related code is conditionally compiled via `#define DOCOMB 0`.

**Longitudinal Feedback (LFB) Woofer**:

The LFB "woofer" channel provides a low-frequency correction path for residual coupled-bunch motion (D4 residual and D2 transients) that the comb filter cannot capture due to its narrowband nature. In the PEP-II architecture, the LFB system (a separate bunch-by-bunch feedback processor) communicated corrections to the LLRF via the GVF module. The term "woofer" refers to its role in the "tweeter-woofer" decomposition of longitudinal feedback: the tweeter (bunch-by-bunch kickers) handles high-frequency motion while the woofer (RF cavity voltage modulation) handles low-frequency components.

At SPEAR3, the LFB system does not exist as a separate installation. The direct loop alone provides sufficient coupled-bunch damping, and the ion-clearing gap transient (D2) is manageable through gap voltage feedback without a dedicated woofer path.

**Gap Voltage Feed-Forward (GVF)** (VXI slot 8):

The GVF module implements adaptive feedforward for gap voltage stabilization, using previous cavity field measurements as a predictive reference. The DSP code (`gvff.s`, Sapozhnikov & Ross, 1996) implements a double-precision adaptive filter with fractional-displacement circular buffer loading. At SPEAR3, with a single klystron feeding only 2 cavities (vs. PEP-II's multi-klystron, multi-cavity topology), the feedforward path provides negligible benefit over the direct feedback loop. The DAC loop (`rf_dac_loop.st`) checks `gvf_module_sevr` for GVF module availability and falls back to RFP-based DAC adjustment when the GVF is unavailable, which is the normal SPEAR3 operating mode.

> **Sources**: [R14]; [R15]; `rf_calib.st` (`DOCOMB` flag); `gvff.s` (DSP); `rf_dac_loop.st` (GVF fallback).

### 6.4 HVPS Loop — Klystron Operating Point Regulation

The HVPS loop adjusts klystron cathode voltage to maintain constant klystron drive power (TUNE mode) or station gap voltage (ON_CW mode). It is the primary mechanism for compensating klystron gain drift (D6).

**Control law** — discrete-time integrator implemented in `rf_hvps_loop.st`:

```math
V_\text{HVPS}[n+1] = V_\text{HVPS}[n] + \Delta V \qquad \text{(Eq. 6.4)}
```

where delta-V is computed from the error between measured and desired klystron drive power or gap voltage. The loop cycles at most every `HVPS_LOOP_MAX_INTERVAL = 10.0` s, giving an effective bandwidth of ~0.1 Hz.

**State machine** (from `rf_hvps_loop.st`, M. Zelazny, Feb 1997):

| State | Condition | Function |
|-------|-----------|----------|
| `init` | IOC boot | Initialize `requested_hvps_voltage` to current readback |
| `off` | Station OFF or PARK | Hold voltage; wait for station state change |
| `proc` | `hvps_loop_ctrl == CONTROL_PROC` | Cavity processing: slowly raise/lower voltage based on vacuum, power, and gap voltage |
| `on` | Normal operation (TUNE or ON_CW) | Maintain constant drive power or gap voltage |

**PROC state** — cavity conditioning logic:

```math
\Delta V = \begin{cases} \Delta V_\text{down} & \text{if } P_\text{fwd} > P_\text{max} \text{ or } V_\text{gap} \text{ high or vacuum bad} \\ \Delta V_\text{up} & \text{otherwise (all OK)} \end{cases} \qquad \text{(Eq. 6.5)}
```

**ON state** — normal regulation. The error source depends on direct loop state:
- Direct loop **OFF**: regulate klystron drive power (forward power setpoint)
- Direct loop **ON**: regulate station gap voltage (cavity voltage setpoint)

**Safety interlocks** (checked every cycle before voltage adjustment):
- RFP module severity (`rf_processor_severity`) — is the RF processor plugged in?
- Klystron forward power validity — is klystron power measurable?
- Cavity gap voltage validity — is gap voltage measurable?
- Cavity vacuum severity — are cavity vacuums acceptable?
- HVPS voltage readback validity — is the HVPS voltage reading out?
- Voltage tolerance: 10 consecutive out-of-tolerance readings before status change (`HVPS_LOOP_MAX_VOLT_TOL = 10`)

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D6 | Klystron operating point regulation |
| Actuator | HVPS cathode voltage (`requested_hvps_voltage`) | Via PLC register N7:30 |
| Bandwidth | ~0.1 Hz | `HVPS_LOOP_MAX_INTERVAL = 10.0` s |
| Operating point | ~10% below saturation | Headroom for fast loops |
| Control law | Discrete integrator (Eq. 6.4) | |
| Status codes | 16 distinct statuses | See `rf_hvps_loop_defs.h` |
| SPEAR3 status | **Active** | |

> **Sources**: `rf_hvps_loop.st` [R16]; `rf_hvps_loop_defs.h`; Section 7 (HVPS plant model).

### 6.5 DAC Loop — Amplitude Regulation

The DAC loop adjusts the baseline I/Q modulator DAC values to maintain constant klystron drive power (TUNE mode) or gap voltage (ON_CW mode). It acts on a different actuator than the HVPS loop (modulator counts vs. cathode voltage) and together they form a complementary pair for operating-point regulation.

**Control law** — proportional correction with deadband (from `subIQcounts` in `subIQ.c`, line 653):

```math
\Delta\text{counts} = A \cdot (C - B) \cdot D \cdot (1 + H) \qquad \text{(Eq. 6.6)}
```

where A is gain (0–1), B is actual measurement (kV or W), C is desired setpoint, D is conversion factor (Counts/kV), and H is loop gain adjustment. Applied only when B > G_min (minimum threshold) and |C - B| > E (deadband). Clamped to +/-F (max delta counts).

The SNL state machine (`rf_dac_loop.st`, S. Allison, May 1997) wraps this control law:

| State | Condition | Function |
|-------|-----------|----------|
| `loop_init` | IOC boot | Initialize counters and flags |
| `loop_off` | Station OFF, PARK, or ON_FM | Hold; forward RFP DAC phase changes; load ripple loop amplitude |
| `loop_tune` | Station TUNE | Adjust `tune_counts` for drive power via RFP tune mode octal DACs |
| `loop_on` | Station ON_CW | Adjust `on_counts` (RFP) or `gff_counts` (GVF) for gap voltage or drive power |

**ON_CW mode routing** — the DAC loop selects the appropriate actuator and error source based on direct loop and GVF module status (from `rf_dac_loop.st`):
- Direct loop **OFF** + GVF unavailable: adjust `on_counts` via RFP DACs using drive power error
- Direct loop **OFF** + GVF available: adjust `gff_counts` via GVF module using drive power error
- Direct loop **ON** + GVF unavailable: adjust `on_counts` via RFP DACs using gap voltage error
- Direct loop **ON** + GVF available: adjust `gff_counts` via GVF module using gap voltage error

At SPEAR3, the GVF module is unavailable (PEP-II only), so the DAC loop always uses RFP-based DAC adjustment.

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D6 (operating point) | Complementary to HVPS loop |
| Actuator | I/Q modulator DAC counts | 12-bit, +/-2047 counts max (`DAC_LOOP_MAX_COUNTS`) |
| Bandwidth | ~0.1 Hz | `DAC_LOOP_MAX_INTERVAL = 10.0` s |
| Minimum delta | 0.5 counts | `DAC_LOOP_MIN_DELTA_COUNTS` — prevents DAC chattering |
| Status codes | 15 distinct statuses | See `rf_dac_loop_defs.h` |
| SPEAR3 status | **Active** | |

The DAC loop also handles loading ripple loop amplitude setpoints when they change. Every cycle, it checks `ripple_loop_ampl_ef` and writes `ripple_loop_load` to update the ripple loop gain.

> **Sources**: `rf_dac_loop.st` [R17]; `rf_dac_loop_defs.h`; `subIQ.c` line 653 (`subIQcounts`).

### 6.6 Tuner Loop — Resonant Frequency Tracking

The tuner loop maintains cavity resonant frequency by driving stepper motors to adjust mechanical plunger insertion depth. It compensates thermal detuning (D8) and microphonics (D7). This is the slowest control loop in the system.

**Control law** — discrete-time integrator (from `rf_tuner_loop.st`, S. Allison, Oct 1996):

```math
x_\text{ctrl}[n] = x_\text{SM}[n] + \Delta x[n] \qquad \text{(Eq. 6.7)}
```

where x_SM is the current stepper motor readback position (PV `{STN}:CAV{CAV}TUNR:STEP:MOTOR.RBV`) and delta-x is the position correction computed in the EPICS database from the load angle error (PV `{STN}:CAV{CAV}TUNR:POSN:DELTA`). The SNL program does not compute delta-x itself — it reads the pre-computed value from the database. See Section 8.3 for the full signal path.

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D7, D8 | Frequency tracking |
| Measurement | Load angle error severity | `{STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR` |
| Actuator | Stepper motor (legacy SLO-SYN / Galil upgrade) | `{STN}:CAV{CAV}TUNR:POSN:CTRL` |
| Bandwidth | ~0.01 Hz | `LOOP_MAX_DELAY = 60.0` s maximum cycle time |
| Position feedback | Linear potentiometer | `{STN}:CAV{CAV}TUNR:POSN` |
| Reset tolerance | 2x MDEL | Position monitor deadband |
| Reset attempts | 5 (`LOOP_RESET_COUNT`), 60-tick delay between attempts | |
| Instances | 4 (one per cavity) | Reentrant (`option +r`) |
| Forward power check | Klystron power must exceed minimum | `{STN}:KLYSOUTFRWD:POWER:MIN` |
| SPEAR3 status | **Active** | |

> **Sources**: `rf_tuner_loop.st` [R18]; `rf_tuner_loop_defs.h`; `rf_tuner_loop_pvs.h`; Section 8 (tuner mechanics).

### 6.7 Gain Tracking Function

The gain tracking function maintains constant forward-path gain as the klystron operating point shifts due to HVPS voltage changes or cathode aging:

```math
G_\text{modulator} \cdot G_\text{klystron} = G_\text{loop} \;(\text{constant}) \qquad \text{(Eq. 6.8)}
```

```math
\therefore\; G_\text{modulator} = G_\text{loop} \,/\, G_\text{klystron}(V_\text{HVPS})
```

Implemented as a ~2 Hz EPICS subroutine record (`subSysDCcoeff` in `subSys.c`, line 277). The algorithm adjusts the I/Q modulator multiplier weights based on the deviation between desired and actual klystron gain:

```math
\Delta G = D \cdot 10^{(G_\text{desired} + G_\text{deviation})/20} - G_\text{current} \qquad \text{(Eq. 6.9)}
```

Applied with deadband limiting. The gain state is tracked across on/off transitions and reset on beam abort events.

> **Sources**: [R15]; [R14]; `subSys.c` line 277 (`subSysDCcoeff`).

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

```math
V_\text{dc} = V_\text{dc,max} \cos\alpha \qquad \text{(Eq. 7.1)}
```

The Enerpro FCOG1200 firing boards:

```math
H_\text{Enerpro}(s) = \frac{1}{1 + s/\omega_\text{Enerpro}} \qquad \text{(Eq. 7.2)}
```

where $\omega_\text{Enerpro} \approx 415$ rad/s (settling $\sim 50$ ms $\approx 3$ AC cycles).

> **Sources**: [R25] Bourbeau, IEEE 1983; [R26] Enerpro manual.

### 7.4 PLC Voltage Regulation Loop

The SLC-500 PLC implements a first-order IIR filter with scan period $T = 10$ ms:

```math
y[n] = (1-\alpha)\,y[n-1] + \alpha\,x[n] \qquad \text{(Eq. 7.3)}
```

with $\alpha = 0.4$, giving time constant $\tau = -T/\ln(1-\alpha) \approx 20$ ms.

> **Sources**: [R27] `CasselPLCCode.pdf`; [R23] `hvps/simulation/hvps_sim/config.py`.

### 7.5 Klystron Arc Protection

Four protection mechanisms: SCR crowbar ($< 1\;\mu\text{s}$), star point bypass, $500\;\Omega$ isolation resistors, $200\;\mu\text{H}$ cable inductors. Result: $< 5$ J to klystron, $I^2 t < 40\;\text{A}^2\text{s}$.

### 7.6 HVPS Dynamic Response Summary

| Subsystem | Time Constant | Bandwidth |
|-----------|:-:|:-:|
| PLC filter | $\tau = 20$ ms | $\sim 8$ Hz |
| Enerpro PLL | settling $\sim 50$ ms | $\sim 66$ Hz |
| SCR commutation | $\sim 100\;\mu\text{s}$ | $\sim 1.6$ kHz |
| Filter LC network | $\tau_{LC} = 86\;\mu\text{s}$ | $\sim 1.8$ kHz |
| Overall voltage step | $< 10$ ms (10% step) | $\sim 16$ Hz |

The Enerpro PLL ($\sim 50$ ms settling) dominates: HVPS loop bandwidth limited to $\sim 1$ Hz.

---

## 8. Tuner Mechanics and Resonant Frequency Control

### 8.1 Cavity Tuner Physical Description

Each of the four SPEAR3 cavities is equipped with a mechanical tuner consisting of a plunger driven by a stepper motor through a worm gear assembly.

| Parameter | Value | Notes |
|-----------|-------|-------|
| Motor | Superior Electric Slo-Syn M093-FC11 (NEMA 34D) | NEMA 34D frame |
| Drive mechanism | Worm gear (self-locking) | Prevents backdriving |
| Tuning range | ~+/-200 kHz | Full plunger travel |
| Step resolution | ~1 Hz/step (legacy) | ~0.05 um/microstep (Galil) |
| Position sensor | Linear potentiometer | Readback via `{STN}:CAV{CAV}TUNR:POSN` |
| Motor controller | Galil DMC-4040 (upgrade) | Replaced SLO-SYN controller |

> **Sources**: [R29]–[R33] Tuner documentation in `llrf/tuners/`.

### 8.2 Tuning Physics

The resonant frequency is a nonlinear function of plunger insertion depth. The relationship is modeled by a polynomial fit (from `subSysFreqOff` in `subSys.c`, line 115):

```math
f_\text{res}(x) = f_0 + p_1 \Delta x + p_2 (\Delta x)^2 + p_3 (\Delta x)^3 + t_1 V_\text{gap}^2 \qquad \text{(Eq. 8.1)}
```

where delta-x = x_current - x_home is the displacement from home tuner position, p_0 through p_3 are polynomial coefficients (fitted from tuner measurements), and t_1 is the thermal detuning coefficient accounting for voltage-dependent cavity heating. The code applies exponential smoothing to the raw polynomial estimate.

**Temperature dependence**: approximately -1 kHz per degree C. A change in cavity wall temperature (from beam heating or coolant temperature drift) shifts the resonant frequency slowly (D8), requiring continuous tuner correction. The voltage-squared term in Eq. 8.1 captures the dominant thermal effect from RF-induced heating.

### 8.3 Tuner Control Loop — Signal Path

The tuner loop has a distributed architecture where the control computation is split between the EPICS database and the SNL state machine:

**Signal flow**:
1. **Hardware**: Cavity probe and forward power detectors measure load angle
2. **EPICS database**: Computes `LOAD:ANGLE` from phase difference, computes `LOAD:ANGLE:ERR` from setpoint deviation, computes `TUNR:POSN:DELTA` as the position correction
3. **SNL state machine** (`rf_tuner_loop.st`): Reads `POSN:DELTA`, adds to current motor position, writes motor command

**Load angle error** (computed in EPICS database):

```math
\varepsilon = \left[\angle(\text{probe}) - \angle(\text{fwd})\right] - \psi_\text{target} \qquad \text{(Eq. 8.2)}
```

where the target detuning angle follows from the optimum detuning condition (Eq. 2.6).

**State machine** (from `rf_tuner_loop.st`, 555 lines, S. Allison, Oct 1996):

| State | Function | Transition |
|-------|----------|------------|
| `loop_init` | Assign PV names from macros; initialize flags | Always -> `loop_unknown` |
| `loop_unknown` | Wait for `posn_delta` monitor to fire, establishing connection | Monitor fires -> `loop_reset` |
| `loop_reset` | Move motor to current `posn_delta + sm_posn`; verify arrival within 2x MDEL | Success -> `loop_off`; Fail (5 attempts) -> `loop_off` with error status |
| `loop_off` | Hold position; monitor station state and loop enable PVs | Enable ON + conditions met -> `loop_on` |
| `loop_on` | Read `posn_delta`, compute `posn_new = sm_posn + posn_delta`, command motor move | Enable OFF -> `loop_off` |

**Safety interlocks** (checked before motor move in `loop_on`):
- Load angle alarm: `load_angle_alarm_sevr` must be below threshold
- Forward power minimum: `kly_fwd_power` must exceed `kly_fwd_power_min`
- Motor done: previous motor move must be complete (`done_moving_status`)
- Loop enable: `loop_enabled` PV must be true
- Station state: station must be in appropriate operating mode

**Status codes** (`rf_tuner_loop_defs.h`): The state machine reports 13 distinct status values via PV `{STN}:CAV{CAV}TUNR:LOOP:STATUS`, including: OK, moving, target reached, loop disabled, alarm condition, power too low, motor fault, reset failed, and others.

> **Sources**: [R14]; [R34] `rf_tuner_loop.st`; [R35] Galil commissioning notes; `subSys.c` line 115 (`subSysFreqOff`).

---


## 9. Performance Requirements and Verification

### 9.1 Disturbance Rejection Summary

| Disturbance | Frequency | Open-Loop Impact | Rejection | Residual |
|-------------|-----------|:-:|:-:|:-:|
| Beam loading (D1–D2) | DC–100 kHz | Unstable | ~40 dB | Stable |
| Robinson (D3) | ~9.4 kHz | Exponential growth | ~40 dB | << 1/tau_rad |
| HVPS ripple (D5) | 360–2000 Hz | ~1% phase | ~40 dB | < 0.01% |
| Thermal drift (D8) | < 0.01 Hz | ~100 Hz/hr | Tuner tracks | < 1 Hz |
| Klystron gain (D6) | 0.01–1 Hz | ~7 dB var. | Gain tracking | < 0.5 dB |

### 9.2 LLRF9 Commissioning Results

From [R4]: LLRF9 achieves improved noise floor vs. legacy at 500 mA. Overall amplitude stability < 0.05% RMS, phase stability < 0.05 deg RMS — both exceed requirements.

### 9.3 Performance Margins

| Parameter | Capacity | Typical | Margin |
|-----------|:-:|:-:|:-:|
| Klystron power | 1.2 MW | ~800 kW | ~50% |
| HVPS voltage | 90 kV | ~74 kV | ~22% |
| Gap voltage/cavity | 1 MV | ~712 kV | ~40% |
| Direct loop BW | ~930 kHz | ~800 kHz | ~16% |
| Impedance reduction | ~40 dB | Required ~30 dB | > 10 dB margin |

### 9.4 Calibration System

The SPEAR3 LLRF calibration system consists of three distinct subsystems, each with its own storage format, execution environment, and operational procedures.

#### 9.4.1 RF Signal Chain Calibration (`rf_calib.st`)

The primary calibration program (`rf_calib.st`, ~2800 lines) implements a 28-state calibration sequence that nulls offsets and establishes scale factors for every node in the RF signal chain. Key numerical parameters from `rf_calib_defs.h`:

| Parameter | Value | Description |
|-----------|:-----:|-------------|
| `COUNT` | 30,000 | Data averaging depth (words per measurement) |
| `MAX_DAC` | 2047 | 12-bit DAC full range (unsigned maximum) |
| `MAX_DAC_SMALL` | 511 | Reduced DAC range for fine nulling |
| `MAX_COMB` | +/-512 | Comb filter multiplier range |
| `MODMAX` | 1024 | RF modulator maximum |
| `ZERO_ATTEMPTS` | 11 | Iterations for zeroing procedures |
| `MAX_ATTEMPTS` | 50 | Maximum nulling attempts |
| `MARGIN` | 1 | Standard convergence tolerance (counts) |
| `BIG_MARGIN` | 2 | Relaxed tolerance |
| `BIG_MARGIN2` | 4 | Coarse tolerance |

The 28 calibration states are organized into 14 logical categories:

| Category | Nodes Calibrated | Example PV Suffixes |
|----------|-----------------|---------------------|
| 1. Octal DACs | RFP module (cavity, direct loop, comb loop) | Various octal DAC channels |
| 2. IQA modulator offset | I/Q modulator DC null on IQA module | `IQA:MOD:OFFSI`, `IQA:MOD:OFFSQ` |
| 3. Multiplier weights | All 4 cavity weighting multipliers | `MUL{n}I`, `MUL{n}Q` |
| 4. Klystron modulator matrix | 4 coefficients (II, IQ, QI, QQ) | `KLYS:MODII`, `KLYS:MODIQ`, etc. |
| 5. Klystron demodulator offset | Klystron I/Q demodulator DC offset | `KLOI`, `KLOQ` |
| 6. Direct loop control node | Direct loop offset nulling | `DLIO`, `DLQO` |
| 7. Comb loop control node | Comb loop offset nulling | `CLIO`, `CLQO` |
| 8. Sum node | Signal summing junction offset | `SNIO`, `SNQO` |
| 9. Gain stages | Per-cavity gain offsets (4 cav x 2 ch) | Various |
| 10. Compensation stage | Compensation filter offset | `CSIO`, `CSQO` |
| 11. Diff node | Difference node offset | `DNIO`, `DNQO` |
| 12. Klystron demod (fine) | Fine demodulator offset nulling | `KLOI`, `KLOQ` |
| 13. Tune mode setpoints | Tune-mode DAC values with offset correction | Various |
| 14. Comb output offsets | Comb filter output offset (when `DOCOMB=1`) | `CO1I`, `CO1Q`, etc. |

Each state uses iterative binary-search or stepping algorithms with the margin-based convergence checking. The `DOCOMB` flag (`#define DOCOMB 0`) disables comb-related calibration states at SPEAR3 (Section 6.3).

#### 9.4.2 HVPS PLC Calibration

The HVPS high-voltage power supply has its own calibration subsystem in the Allen-Bradley SLC-500 PLC, separate from the RF signal chain. Key parameters from the N7 register map (`hvps/documentation/plc/technical-notes/08-analog-registers-calibration.md`):

| Register | Multiplier | Description |
|----------|:----------:|-------------|
| N7:20 | 10000 | Output Reference Multiplier |
| N7:22 | 10075 | Voltage Multiplier |
| N7:24 | 4600 | AC Current Multiplier |
| N7:27 | 5000 | DC Current Multiplier |
| N7:29 | 6 | Power Multiplier |

**Voltage scaling** (from measurement data in `hvpsMeasurements20220314.xlsx`):
- Phase angle formula: `N7:11 = (N7:10 x 12000)/32767 + 6000`
- Voltage conversion: V_HVPS (kV) is approximately N7:15 x 0.00305
- Calibration range: 2000–3200 V input / 60–69 kV output

Temperature monitoring uses 4 thermocouples with alarm thresholds, routed through the PLC analog input module.

#### 9.4.3 Hardware Calibration Data Files

Six Excel calibration files in `llrf/calibrations/` provide hardware-specific measurement data:

| File | Contents |
|------|----------|
| `driveAmpCalibration.xlsx` | Drive amplifier amplitude response curves |
| `klystronCouplerDriveAmpCalibrations.xlsx` | Klystron-to-coupler coupling measurements |
| `tuneModeDacCalibration.xlsx` | Tune mode DAC output verification |
| `reflectedPowerCalibrations.xlsx` | Reflected power detector calibration |
| `pulsarCouplerCalibration2049.xlsx` | Pulsar-specific coupler cal data |
| `b132R11PatchPanel.xlsx` | Patch panel wiring and termination data |

These files document the physical measurement campaigns that establish the numerical constants used in the software calibration routines above.

> **Sources**: [R38] `rf_calib.st`; [R39] Jim Sebek's master document index; `rf_calib_defs.h`; `08-analog-registers-calibration.md`; `hvpsMeasurements20220314.xlsx`.

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
| Drive power | $\sim 29$ W | — | [R5] |
| Perveance | $\sim 2.0 \times 10^{-6}$ | A/V$^{3/2}$ | [R23] |

### A.4 Feedback Loop Parameters

| Loop | Bandwidth | SPEAR3 Status | Addresses | Source |
|------|-----------|:-:|:-:|--------|
| Direct | $\sim 800$ kHz | Active | D1–D4 | [R14] |
| Comb | 2 MHz | Not used | D4 | [R14] |
| Ripple | $\sim 300$ Hz | Active | D5 | [R14] |
| Gap FF | 100 Hz | Not used | D2 | [R14] |
| HVPS | $\sim 1$ Hz | Active | D6 | [R14] |
| Tuner | $\sim 0.01$–$1$ Hz | Active | D7, D8 | [R14] |
| DAC | $\sim 0.1$ Hz | Active | Amplitude drift | [R14] |
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
