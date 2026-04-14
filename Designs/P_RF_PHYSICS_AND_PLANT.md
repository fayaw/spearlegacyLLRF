# SPEAR3 RF System — RF Physics, Control Theory and Physical Plant

**Document ID**: Doc P  
**Version**: 3.2  
**Date**: March 26, 2026  
**Status**: DRAFT 
**Location**: Designs/P_RF_PHYSICS_AND_PLANT.md 
**Author**: Faya Wang, with AI-assisted analysis  
**Tier**: 1 — Physics and Plant Reference (implementation-independent)  

---

## Revision History

| Version | Date | Description |
|---------|:------------:|-------------|
| 1.0 | 2026-03-24 | Initial draft: nine-section catalog structure. |
| 2.0 | 2026-03-24 | Major rewrite: disturbance-driven control design narrative. |
| 2.1 | 2026-03-24 | LaTeX formatting for all equations and symbols. Physics review: corrected synchronous phase convention (Eq. 2.4), verified all numerical calculations, fixed minor inconsistencies. |
| 2.2 | 2026-03-24 | GitHub rendering fix: converted all display equations to fenced math code blocks for reliable MathJax rendering; moved equation labels to text below blocks; cleaned up negative thin spaces, thousand-separator braces, and degree symbols. |
| 2.3 | 2026-03-24 | Attempted \\tag{} for inline equation numbering — caused rendering failures on GitHub. Reverted. |
| 2.4 | 2026-03-24 | Inline equation numbering via \\qquad \\text{} — labels now appear on the same line as equations without using \\tag{}. |
| 2.5 | 2026-03-24 | Deep cross-reference review against original sources (McIntosh SLAC-PUB-10983, Schwarz PS-340-330-51, SSRL parameter page, simulation config, legacy code). Corrected synchrotron frequency formula to convention-independent form; added note on design vs operational VRF; corrected QL/β traceability to Schwarz; corrected DSP identification (AT&T DSP1610, not TMS320C16xx); corrected HVPS ripple harmonic description; added radiation damping time clarification; added new [R3] SSRL web reference; updated Appendix A parameters. |
| 2.6 | 2026-03-24 | Major physics corrections per operational data review: updated U0 from 0.91 to 1.02 MeV with full recalculation cascade (φs, fs, detuning, generator power); corrected Eq. 2.7 generator power formula (~196 kW/cavity, matching measured ~200 kW); standardized RF frequency to 476.3 MHz; corrected I/Q modulator count from PEP-II (7) to SPEAR3 (5); added D1/D2 beam loading physics, D4 comb filter physics, expanded D6 klystron gain tracking detail; added thermal detuning estimation; added system block diagrams; comprehensive LaTeX formatting cleanup. |
| 2.7 | 2026-03-24 | Physics verification: simplified Eq. 2.4b to use cos convention directly (removed convention-independent form); verified Eq. 2.5 optimum detuning via first-principles admittance derivation (confirmed self-consistent with Rs = 3.73 MΩ); clarified Rs convention in Appendix C (Rs = V²/(2P), circuit convention). |
| 3.0 | 2026-03-25 | **Major improvements** based on deep codebase review: (a) Added formal symbol definitions for all transfer function blocks in Eq. 5.1 (§5.2), comb filter Eq. 5.4 (§5.3), and multi-loop Eq. 5.5 (§5.6); (b) Strengthened mathematical rigor with gain/phase budget analysis, explicit compensator forms (Eq. 6.1a), and cross-term stability derivation; (c) Transformed §6 from parameter tables into full engineering sections with transfer functions, control laws, and design rationale — added Eqs. 6.4a–c (ripple harmonic estimator), 6.6a (HVPS control), 6.7a–c (tuner loop), 6.8a (DAC loop), 6.9a–c (gain tracking); (d) Expanded §9.4 from 2 lines to comprehensive calibration overview with 6 subsections including calibration sequence (27-state rf_calib.st), drive/power/frequency calibration equations (Eqs. 9.1–9.3); (e) Expanded Appendix C from 15 to 100+ symbol definitions organized by subsystem. |
| 3.1 | 2026-03-25 | **Structural improvements**: (a) Added §6.0 Loop Overview and Implementation Summary with 9-loop classification table and 4-tier implementation taxonomy (analog HW → digital HW → RT software → supervisory SW); (b) Expanded §6.2 (Comb) from 2 lines to full engineering section with closed-loop impedance (Eq. 6.2a), FIR equalizer (Eq. 6.2b), complete comb path TF (Eq. 6.2c), PEP-II parameter table, frev/Δf₁/₂ ratio argument; (c) Expanded §6.3 (LFB Woofer) from 2 lines to full section with woofer transfer function (Eq. 6.3a), woofer/tweeter complementarity table, direct loop interaction analysis; (d) §5→§6 boundary cleanup: trimmed §5.2 detailed symbol table and impedance analysis (moved to §6.1), trimmed §5.3 comb symbol table (moved to §6.2), added forward references; (e) Added §3 transitional sentence cementing I/Q framework role; (f) Updated Appendix C.4 with comb/FIR symbols, added C.4a LFB woofer symbols. |
| 3.2 | 2026-03-26 | **Added D9 (Ring Circumference Thermal Drift)**: New disturbance class documenting the ~4 kHz/year secular drift in RF operating frequency caused by seasonal thermal expansion of the ring tunnel. Added §4.8 with physics derivation: harmonic condition (Eq. 4.8), circumference change calculation (Eqs. 4.8a–b), D8 vs. D9 comparison table, and operational impact on tuner range. Updated disturbance taxonomy table (§4.1, D8 label clarified, D9 added); renamed old §4.8 frequency-domain summary to §4.9 with D9 entry at annual timescale; updated §5.4 and §6.7 to reference D9. |
| 3.3 | 2026-03-27 | **Added extra loop functions**: comb filter, LFB Woofer and Direct loop |

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
| RF frequency | $f_\text{RF}$ | 476.3 | MHz |
| Momentum compaction | $\alpha_c$ | $1.18 \times 10^{-3}$ | — |
| Energy loss per turn | $U_0$ | 1.02 | MeV |
| Total accelerating voltage (design) | $V_\text{RF}$ | 3.2 | MV |
| Total accelerating voltage (operational) | $V_\text{RF}$ | ~2.85 | MV |
| Synchrotron frequency | $f_s$ | ~10.1 | kHz |
| Synchrotron tune | $\nu_s$ | ~0.008 | — |
| Longitudinal radiation damping time | $\tau_s$ | ~2.9 | ms |
| Transverse radiation damping time | $\tau_{x,y}$ | ~4.2, 5.1 | ms |

> **Note on $f_\text{RF}$**: The nominal RF frequency is 476.3 MHz. The precise frequency (e.g. 476.3051755 MHz as measured) varies slightly as the ring circumference changes with temperature. For consistency, 476.3 MHz is used throughout this document.

> **Note on $U_0$**: The current operational energy loss per turn is $U_0 = 1.02$ MeV. This is validated by the measured generator power of $\sim 200$ kW/cavity (§2.1.3). The value 0.91 MeV appearing in some earlier references [R1] corresponds to a different set of insertion-device contributions; the current ID complement increases $U_0$.

> **Note on $V_\text{RF}$**: The **design** value of 3.2 MV (800 kV/cavity) is from the original SPEAR3 RF system specification [R1]. The **operational** value of $\sim 2.85$ MV (712 kV/cavity) is from LLRF9 commissioning measurements [R4] (also the current operation norminal at 500 mA ) and is used throughout the beam loading calculations in this document.

> **Note on $\alpha_c$**: Published values range from 0.0011 (SSRL parameter page [R3]) to 0.00118 (used in this document) depending on the specific lattice optics. Differences of $\sim 7\%$ in $\alpha_c$ produce $\sim 3\%$ differences in $f_s$.

> **Sources**: [R1] McIntosh et al., SLAC-PUB-10983, EPAC 2004 (Table 1: $Q_s = 0.008$, $\alpha = 0.00113$). [R2] Hettel et al., PAC 1999. [R3] SSRL SPEAR Storage Ring Parameters ($\nu_s = 0.007$, $\alpha_c = 0.0011$, $V_\text{RF} = 3.2$ MV). [R5] `Designs/0_SYSTEM_DESIGN_REPORT.md`.

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

### 2.0 High-Level System Block Diagram

The following diagram shows the full RF control architecture — four cavities driven by one klystron, with multiple feedback loops spanning seven decades of frequency:

```
  ┌────────────────────────────────────────────────────────────────────────────────────┐
  │                        SPEAR3 RF CONTROL SYSTEM — OVERVIEW                         │
  ├────────────────────────────────────────────────────────────────────────────────────┤
  │                                                                                    │
  │   IQ Ref ──▶(Σ)──▶ BASEBAND ──▶ IQ RF ──▶ DRIVE ──▶ KLYSTRON ──▶ 3x MAGIC ──┐   │
  │     (DAC)    ↑      MODULATOR     MOD       AMP       1.2 MW      TEE          │   │
  │              │      (gain/phase   (up to    (~29 W)   (43 dB,    SPLITTER      │   │
  │              │       tracking)    476 MHz)             <150 ns)                │   │
  │              │                                                                 │   │
  │              │                                             ┌───────────────────┤   │
  │              │  DIRECT LOOP                                │                   │   │
  │              │  (~800 kHz BW)                              ▼                   ▼   │
  │              │  ┌────────────────┐                      ┌──────┐          ┌──────┐ │
  │              ├──┤ Error Amp +    │◀── Vector ◀── IQ ◀──┤Cav 1 │   ...   │Cav 4 │ │
  │              │  │ Lead/Integral  │    Sum       Demod   │      │          │      │ │
  │              │  │ Compensation   │    (4 cav)           │ Probe│          │ Probe│ │
  │              │  └────────────────┘                      └──┬───┘          └──┬───┘ │
  │              │                                             │                 │     │
  │   RIPPLE     │                                             ▼                 ▼     │
  │   LOOP ──────┤  ◀── Kly Fwd IQ ◀── IQ Demod ◀── Klystron Forward Power           │
  │   (~300 Hz)  │       (DSP: AT&T DSP1610, 23 kHz sample rate)                       │
  │              │                                                                     │
  │   DAC LOOP ──┘  (~0.1 Hz, maintains Vgap setpoint)                                 │
  │                                                                                    │
  │   TUNER LOOP (0.01–1 Hz): ∠probe − ∠fwd → stepper motor → mechanical tuner         │
  │   HVPS LOOP  (~1 Hz): Drive power monitor → PLC → SCR firing angle → Vk            │
  │                                                                                    │
  │   ╔════════════════════════════════════════════════════════════════════════╗       │
  │   ║  NOT USED at SPEAR3: Comb Loop, Gap FF Loop, LFB Woofer                ║       │
  │   ╚════════════════════════════════════════════════════════════════════════╝       │
  └────────────────────────────────────────────────────────────────────────────────────┘
```

**Key architectural features:**
- **Single klystron, four cavities**: One I/Q modulator drives all four cavities simultaneously. Field regulation uses the vector sum of all four cavity probes.
- **Bandwidth hierarchy**: Direct (800 kHz) ≫ Ripple (300 Hz) ≫ HVPS/Tuner (~1 Hz) ≫ DAC (0.1 Hz) — natural frequency-domain decoupling.
- **Analog fast path**: The direct loop operates entirely in analog baseband for minimum delay ($\sim 270$–500 ns total loop delay).

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

> **Traceability note**: $R_s = 3.73$ MΩ and $Q_0 = 32{,}000$ are directly from [R6] Schwarz. Schwarz reports $\beta_\text{actual} = 3.72$ and $\beta_\text{optimum} = 3.84$ for PEP-II HER, giving $Q_L = 6{,}780$. The value $\beta = 3.78$ used here is a derived operating point (intermediate between actual and optimum) consistent with $Q_L \approx 6{,}700$ via $Q_L = Q_0/(1+\beta) = 32{,}000/4.78 = 6{,}695$. McIntosh [R1] reports $R_s = 3.8$ MΩ in accelerator convention (= $2 \times R_s^\text{linac} = 7.6$ MΩ, consistent with Schwarz $R_a = 7.5$ MΩ [R6]).

> **Sources**: [R6] Schwarz parameter table (PS-340-330-51-R0); [R7] Rimmer et al., LBL-33360.

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
\cos\phi_s = \frac{U_0}{V_\text{RF}} = \frac{1.02\;\text{MeV}}{2.85\;\text{MV}} = 0.358 \implies \phi_s \approx 69.0^\circ \qquad \text{(Eq. 2.4a)}
```

Note: $\sin\phi_s = \sin(69.0^\circ) = 0.934$, which appears in the beam loading compensation formulas below.

**Synchrotron frequency** :

```math
\nu_s = \sqrt{\frac{h\,\alpha_c\,V_\text{RF}\,\sin\phi_s}{2\pi\,E_0}} \qquad \text{(Eq. 2.4b)}
```

> With $V_\text{RF} = 2.85$ MV, $\sin\phi_s = 0.934$: $\nu_s = \sqrt{372 \times 0.00118 \times 2.85 \times 0.934 \,/\, (2\pi \times 3000)} \approx 0.0079$, giving $f_s = \nu_s \, f_\text{rev} \approx 10.1$ kHz. Published values: $Q_s = 0.008$ [R1], $\nu_s = 0.007$ [R3] — the range reflects differences in operational $V_\text{RF}$ and $\alpha_c$ across lattice configurations. For control design, the key constraint is that the direct loop bandwidth ($\sim 800$ kHz) $\gg f_s$.

**Optimum detuning** — minimizes reflected power at the input coupler:

```math
\tan\psi_\text{opt} = -\frac{I_b \, R_s \, \sin\phi_s}{V_\text{gap}} = -\frac{0.5 \times 3.73 \times 10^6 \times 0.934}{712 \times 10^3} = -2.45 \qquad \text{(Eq. 2.5)}
```

```math
\psi_\text{opt} \approx -67.8^\circ \qquad \text{(Eq. 2.5a)}
```

> **Derivation note**: Equation 2.5 follows from the condition that optimum detuning makes the reactive component of the required generator current zero, minimizing reflected power at the input coupler. The cavity admittance at the drive frequency is $Y = G(1 + j\tan\psi)$ with $G = 1/(2R_s)$. The reactive generator current is $\text{Im}(I_\text{gen}) = V_\text{gap} \cdot G \cdot \tan\psi + I_b \sin\phi_s$. Setting this to zero gives $\tan\psi_\text{opt} = -I_b \sin\phi_s / (V_\text{gap} \cdot G) = -I_b \cdot R_s \cdot \sin\phi_s / V_\text{gap}$, which is Eq. 2.5. The formula is self-consistent: both $V_{b,\text{res}} = I_b R_s$ (Eq. 2.2) and $P_\text{wall} = V^2/(2R_s)$ (Eq. 2.7a) use the same $R_s = 3.73$ MΩ, confirming that $\tan\psi_\text{opt} = -V_{b,\text{res}} \sin\phi_s / V_\text{gap}$ is the correct form.

**Optimum frequency detuning** — using $\sin\phi_s$ explicitly in the formula:

```math
\Delta f_\text{opt} = \frac{f_0 \tan\psi_\text{opt}}{2Q_L} = -\frac{f_0 \, I_b \, R_s \, \sin\phi_s}{2Q_L \, V_\text{gap}} = -\frac{476.3\;\text{MHz} \times 0.5 \times 3.73 \times 10^6 \times 0.934}{2 \times 6700 \times 712 \times 10^3} \approx -87\;\text{kHz} \qquad \text{(Eq. 2.6)}
```

The cavity must be tuned $\sim 87$ kHz **below** $f_\text{RF}$ at 500 mA.

**Required generator power per cavity** — At optimum coupling ($\beta_\text{opt}$) and optimum detuning ($\psi_\text{opt}$), the minimum generator power per cavity is the sum of cavity wall losses and beam power:

```math
P_\text{gen/cav} = P_\text{wall} + \frac{P_\text{beam}}{n_\text{cav}} = \frac{V_\text{gap}^2}{2R_s} + \frac{I_b \, U_0}{n_\text{cav}} \qquad \text{(Eq. 2.7)}
```

**Evaluation:**

```math
P_\text{wall} = \frac{V_\text{gap}^2}{2R_s} = \frac{(712\;\text{kV})^2}{2 \times 3.73\;\text{M}\Omega} = 68\;\text{kW/cavity} \qquad \text{(Eq. 2.7a)}
```

```math
\frac{P_\text{beam}}{n_\text{cav}} = \frac{I_b \, U_0}{n_\text{cav}} = \frac{0.5\;\text{A} \times 1.02\;\text{MeV}}{4} = 127.5\;\text{kW/cavity} \qquad \text{(Eq. 2.7b)}
```

```math
P_\text{gen/cav} = 68 + 127.5 \approx 196\;\text{kW/cavity} \qquad        \text{(Eq. 2.7c)}
```

**Total RF power**: $4 \times 196 = 782$ kW — within the 1.2 MW klystron capacity ($\sim 35\%$ margin). The measured forward power at 500 mA is $\sim 200$ kW/cavity, consistent with this calculation (the small excess accounts for reflected power at non-ideal coupling).

> **Note**: Eq. 2.7 is the minimum-power condition at optimum coupling. In the general case with arbitrary coupling $\beta$ and detuning $\psi$, the generator power includes reflected power terms. The important identity is that beam power per cavity $= I_b V_\text{gap}\cos\phi_s = I_b \, U_0/n_\text{cav}$.

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
| Perveance | $\sim 2.0 \times 10^{-6}$ | $\text{A/V}^{3/2}$ |

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

This is the single most important constraint in the entire control design (a practical rule-of-thumb, $2\times$  phase margin of $\frac{\pi}{4}$).

| Component | Legacy (analog) | LLRF9 (digital) |
|-----------|:-:|:-:|
| Klystron group delay | $< 150$ ns | $< 150$ ns |
| I/Q modulator | $< 5$ ns | $< 5$ ns |
| Cable propagation | $\sim 50$ ns | $\sim 50$ ns |
| Electronics/computation | $\sim 300$ ns | $\sim 65$ ns |
| **Total** $\tau_d$ | **$\sim 500$ ns** | **$\sim 270$ ns** |
| $f_{c,\text{max}}$ | **$\sim 500$ kHz** | **$\sim 926$ kHz** |

**Note**: Diret loop delay is 270 ns from LLRF9 manual, which is assumed the total delay of the loop as listed here [To be confirmed].

### 2.4 Complete Open-Loop Plant Transfer Function

```math
G_\text{plant}(s) = G_0 \cdot H_\text{cav}(s) \cdot e^{-s\tau_d} = \frac{G_0 \,\omega_{1/2}}{s + \omega_{1/2} + j\Delta\omega}\; e^{-s\tau_d} \qquad \text{(Eq. 2.12)}
```

The cavity bandwidth ($35.5$ kHz) and the loop delay together define the limits of what feedback can achieve.

---

## 3. I/Q Signal Processing Framework

### 3.1 Baseband I/Q Representation

All RF feedback loops use baseband In-phase and Quadrature (I/Q) techniques:

```math
V_\text{RF}(t) =A(t)\cos[\omega_\text{RF}t + \phi(t)] = I(t)\cos(\omega_\text{RF}t) - Q(t)\sin(\omega_\text{RF}t) \qquad \text{(Eq. 3.0)}
```

where $I(t) = A(t)\cos\phi(t)$ and $Q(t) = A(t)\sin\phi(t)$, with inverse relations:

```math
A(t) = \sqrt{I^2 + Q^2}\,,\qquad \phi(t) = \text{atan2}(Q, I) \qquad    \text{(Eq. 3.0a)}
```

### 3.2 Baseband I/Q Modulator

The I/Q modulator performs a scaled rotation:

```math
\begin{pmatrix} I_\text{out} \\ Q_\text{out} \end{pmatrix} = G \begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{pmatrix} \begin{pmatrix} I_\text{in} \\ Q_\text{in} \end{pmatrix} \qquad    \text{(Eq. 3.1)}
```

**Implementation**: Each baseband I/Q modulator uses four AD834 four-quadrant multipliers (DC to 500 MHz) + two EL2073 summing amplifiers to implement the 2×2 matrix. Group delay $< 5$ ns, full-power BW $> 40$ MHz, dynamic range $> 50$ dB.

**SPEAR3 modulator count**: 4 cavity combining modulators (one per probe) + 1 drive modulator (direct loop gain/phase) = **5 baseband I/Q modulators**, with associated Octal DAC channels on the RFP module for the 2×2 matrix coefficients.

> **PEP-II comparison**: The PEP-II HER system used 7 baseband I/Q modulators (4 cavity combining + 1 direct loop + 1 comb filter adjust + 1 ripple) with 56 DAC channels [R15]. SPEAR3 requires fewer because: (a) the comb loop is not used, (b) the ripple correction is applied via DSP rather than a dedicated modulator. The AD834 multipliers and EL2073 op-amps are the same components.

> **Sources**: [R15] Corredoura, Eq. 2 (PEP-II configuration); [R14] Schwarz, PS-340-330-52-R0; Doc B §13.2 (SPEAR3 RFP module description).

### 3.3 I/Q Demodulation

RF signals are converted to baseband I/Q using $+13$ dBm demodulators. Outputs: AC-coupled into $50\;\Omega$, low-pass filtered ($F_c = 225$ MHz), video amplified (17 dB) to $\pm 1$ V.

### 3.4 Cavity Probe Vector Sum

Each of the 4 cavity probe signals is demodulated to I/Q and combined through a programmable combining network (4 I/Q baseband modulators + 2 summing amplifiers on the RFP module) to form the **total accelerating RF vector**. The DAC weights for each modulator set the complex gain for each cavity's contribution to the vector sum.

### 3.5 Error Signal Generation

```math
\vec{E} = \vec{V}_\text{ref} - \vec{V}_\text{probe} \qquad \text{(Eq. 3.2)}
```

```math
\vec{V}_\text{drive} = G_\text{loop} \cdot \vec{E} = G_\text{loop}\left(\vec{V}_\text{ref} - \vec{V}_\text{probe}\right) \qquad \text{(Eq. 3.3)}
```

> **Sources**: [R15]; [R14].

The error signals $\Delta I$, $\Delta Q$ are then used with the reference $I, Q$ to caculate the rotation angle or multipliers in Eq.(3.1) for cavity field requlation. The I/Q baseband representation developed in this section is used throughout §4–§9 to express all loop transfer functions in the complex baseband domain.

---

## 4. Disturbance Analysis and Control Problem Statement

**The control architecture follows inevitably from the disturbance landscape.**

### 4.1 Disturbance Taxonomy

| # | Disturbance | Frequency | Magnitude | Impact |
|---|-------------|-----------|-----------|--------|
| D1 | Beam loading (steady-state) | DC | $V_b = 1.865$ MV/cavity | Dominates voltage budget |
| D2 | Beam loading (transient) | DC–100 kHz | Growth rates $< T_\text{rev}$ | Longitudinal instability |
| D3 | Robinson instability | $f_s \sim 10$ kHz (Eq. 2.4b) | Exponential growth | Beam loss |
| D4 | Coupled-bunch modes | $n \cdot f_\text{rev}$ | $1/\tau_{cb}$ | Beam oscillation |
| D5 | HVPS ripple | 360, 720, 1080… Hz | $< 1\%$ P-P voltage | Phase modulation |
| D6 | Klystron gain drift | 0.01–1 Hz | up to 7 dB | Loop gain variation |
| D7 | Microphonics | 1–300 Hz | $\Delta f \sim 1$–$10$ Hz | Cavity detuning |
| D8 | Thermal detuning (cavity) | $< 0.01$ Hz | $\Delta f \sim 1$–$100$ Hz | Slow frequency drift |
| D9 | Ring circumference thermal drift | Seasonal ($\ll 0.001$ Hz) | $\Delta f_{RF} \sim 4$ kHz/year | Secular tuner setpoint migration |

### 4.2 D1/D2: Beam Loading — The Dominant Disturbance

**D1 — Steady-state beam loading**: Each bunch extracts energy from the cavity field. The beam-induced voltage $V_{b,\text{res}} = I_b R_s = 1.865$ MV per cavity (Eq. 2.2) exceeds the gap voltage by a factor of $\sim$ 2.6. Without active compensation, the generator must supply this reactive power in addition to the real power delivered to the beam. Detuning the cavity (§2.1.3) brings the reactive component to zero at the operating current, but any current deviation creates a mismatch.

**D2 — Transient beam loading**: Current transients (injection, ion-clearing gap, bunch-by-bunch variations) cause rapid changes in the beam-induced voltage. These transients drive cavity field oscillations at frequencies up to $\sim f_\text{rev}$.

**How feedback suppresses D1/D2**: The direct feedback loop reduces the effective impedance seen by the beam:

```math
Z_\text{eff}(\omega) = \frac{Z_\text{cav}(\omega)}{1 + G_\text{OL}(\omega)} \qquad \text{(Eq. 4.1a, same as Eq. 5.3)}
```

At DC and low frequencies where $|G_\text{OL}| \gg 1$ (proportional gain $\sim 15$ dB + integrator), the impedance reduction is $\sim 40$ dB ($\times 100$). This has two physical effects:

1. **Voltage regulation**: The beam-induced voltage perturbation $\Delta V_b = \Delta I_b \cdot Z_\text{eff}$ is reduced by the loop gain. A 1% current transient that would cause $\sim 19$ kV field perturbation without feedback produces only $\sim 190$ V with 40 dB impedance reduction.

2. **Stability**: The beam-cavity interaction becomes stable because the reduced impedance eliminates the conditions for exponential growth. The **growth rate** for coupled-bunch instability from the fundamental mode [R15]:

```math
\frac{1}{\tau} = \frac{I_b\,\alpha_c\,f_\text{RF}}{2\,\nu_s\,\beta^2\,(E/e)}\;R_{cb} \qquad \text{(Eq. 4.1)}
```

where $R_{cb} = \sum_n \text{Re}\left[Z_\text{eff}(\omega_\text{RF} + n\omega_\text{rev} + \omega_s) - Z_\text{eff}(\omega_\text{RF} + n\omega_\text{rev} - \omega_s)\right]$.

With feedback, $Z_\text{eff}$ replaces $Z_\text{cav}$ in the sum, reducing growth rates by the same factor as the impedance reduction. **Without feedback**, the peak cavity impedance of $\sim 750\;\text{k}\Omega$ produces growth rates faster than $T_\text{rev} \approx 0.78\;\mu\text{s}$. This single fact drove the PEP-II system design to include multiple feedback loops [R15].

```
  Beam Loading Phasor Diagram (Steady State at 500 mA)
  ────────────────────────────────────────────────────
                    │ Imaginary
                    │
        Vb,res      │      Vgap (712 kV)
    (1865 kV) ←─────┤─────────────────→ Real
                    │╲  φs = 69°
                    │ ╲
                    │  ╲  Vgen (generator voltage)
                    │   ╲
                    │    ╲  ψopt = −68° (detuning angle)
                    │
  The generator voltage Vgen must compensate both the beam
  loading Vb and the detuning. At optimum detuning, the
  reflected power is minimized (Pgen ≈ 196 kW/cav).
```

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

For $h = 372$ modes, each mode $m$ is driven by the impedance sampled at revolution harmonics:

```math
\frac{1}{\tau_m} = \frac{\alpha_c\,\omega_\text{rev}\,I_b}{4\,\omega_s\,(E/e)}\sum_p\left[\text{Re}\{Z((ph+m)\omega_\text{rev}+\omega_s)\} - \text{Re}\{Z((ph+m)\omega_\text{rev}-\omega_s)\}\right] \qquad \text{(Eq. 4.4)}
```

**Physics of the comb filter**: The comb filter is designed to provide additional impedance reduction at revolution frequency harmonics — precisely where beam-driven modes exist — without increasing gain (and noise) at frequencies between harmonics. Its transfer function (Eq. 5.4) has gain peaks at integer multiples of $f_\text{rev}$, creating a frequency response that looks like the teeth of a comb:

```
  Comb Filter Frequency Response
  ──────────────────────────────────
  Gain
   │  ╷  ╷  ╷  ╷  ╷  ╷  ╷  ╷
   │  │  │  │  │  │  │  │  │   ← peaks at n × frev
   │  │  │  │  │  │  │  │  │
   │──┘──┘──┘──┘──┘──┘──┘──┘──── frequency
       frev 2frev 3frev  ...

  Each peak targets one coupled-bunch mode.
  Between peaks, gain returns to unity → no noise amplification.
```

**Why SPEAR3 does not need the comb filter**: The key ratio is $f_\text{rev}/\Delta f_{1/2}$:

- **SPEAR3**: $f_\text{rev} = 1.28$ MHz $\gg \Delta f_{1/2} = 35.5$ kHz → ratio $\approx 36$. In this regime, only the central RF harmonic lies within the cavity bandwidth, while all revolution sidebands are many cavity linewidths away and therefore do not significantly couple through the cavity impedance. The cavity effectively behaves as a narrowband filter, responding primarily to the carrier component of the beam current.

- As a result, beam-induced disturbances at revolution harmonics are not directly amplified by the cavity, and the interaction is dominated by the fundamental RF component. Meanwhile, the beam current is much lower than PEPII, comb filtering is not necesssary for fine control and disturbance rejection, as the overall system is less sensitive to revolution harmonic coupling compared to PEP-II, relaxing the requirements on harmonic-by-harmonic suppression.

- **PEP-II**: $f_\text{rev} \approx 136$ kHz, comparable to $\Delta f_{1/2}$ → ratio $\approx 4$. Although only the central RF harmonic lies strictly within the cavity bandwidth, the nearby revolution harmonics are only a few cavity linewidths away and therefore couple significantly through the cavity impedance. 
- As a result, multiple revolution sidebands contribute to beam–cavity interaction and must be actively controlled for PEPII. This operating regime necessitates the use of a comb filter, which provides selective suppression at revolution harmonics. This approach effectively mitigates beam-induced disturbances while avoiding the excessive noise amplification that would arise from a purely wideband feedback loop.

### 4.5 D5: HVPS Ripple

The 12-pulse SCR rectifier produces two families of harmonics:

**12-pulse fundamental harmonics** (ideal 12-pulse cancellation):

```math
f_\text{12p} = 12n \times f_\text{line} = 720,\;1440,\;2160,\;\ldots\;\text{Hz} \qquad \text{(Eq. 4.5a)}
```

**Residual 6-pulse harmonics** (from imperfect phase balance between the two 6-pulse bridges):

```math
f_\text{6p} = 6n \times f_\text{line} = 360,\;720,\;1080,\;\ldots\;\text{Hz} \qquad \text{(Eq. 4.5b)}
```

The 360 Hz component (first 6-pulse harmonic absent in ideal 12-pulse operation) is the **dominant residual** and the primary target of the ripple loop. Additional low-order harmonics at 60, 120, 180, 240 Hz may appear at reduced levels ($\sim 20$–$40$ dB below 360 Hz) depending on SCR firing symmetry. Coupling to RF field via AM-PM conversion:

```math
\Delta\phi_\text{RF} \sim \frac{\partial P_\text{kly}/\partial V_k}{P_\text{kly}} \cdot \Delta V_\text{ripple} \qquad \text{(Eq. 4.6)}
```

> **Sources**: [R21]; [R22]; *`01_FEEDBACK_LOOP_ARCHITECTURE.md`*.

### 4.6 D6: Klystron Gain Variation

**Source of gain variation**: As beam current changes from 0 to 500 mA, the HVPS loop adjusts cathode voltage $V_k$ to maintain the klystron $\sim 10\%$ below saturation. As $V_k$ changes, the small-signal gain (slope of the $P_\text{out}$ vs $P_\text{in}$ curve) varies by up to $\sim 7$ dB. This shifts the open-loop gain of the direct feedback loop, potentially affecting stability margins.

**Gain tracking implementation** (§6.9): The baseband modulator on the RFP module (4 Gilbert-cell multipliers in a 2×2 matrix) has its matrix coefficients controlled by 12-bit Octal DACs. A slow EPICS loop ($\sim 1$ Hz) reads the klystron forward power and drive power monitors, computes the current gain, and adjusts the modulator matrix to maintain constant overall loop gain:

```math
G_\text{modulator} = \frac{G_\text{loop,target}}{G_\text{klystron}(V_k)} \qquad \text{(Eq. 4.6a)}
```

The MATLAB calibration routine `ConfDirect` (initiated from the EPICS feedback panel) performs the initial gain tracking setup by measuring klystron gain at the current operating point and writing the appropriate 2×2 matrix coefficients to the quad DAC.

> **Note**: In PEP-II, the ripple loop also applied gain/phase correction via a dedicated I/Q modulator. At SPEAR3, the ripple loop phase correction is handled by the DSP (AT&T DSP1610), and the slow gain tracking is handled by the baseband modulator coefficients on the RFP module.

> **Sources**: [R14] Schwarz, PS-340-330-52-R0; [R15] Corredoura; Doc B §7.6.

### 4.7 D7/D8: Microphonics and Thermal Detuning

For normal-conducting copper cavities: microphonic excursions $< 10$ Hz (negligible vs. $\Delta f_{1/2} = 35.5$ kHz).

**Thermal detuning estimation**: The resonant frequency of a copper cavity scales inversely with its linear dimensions: $\Delta f/f = -\alpha_\text{Cu} \cdot \Delta T$, where $\alpha_\text{Cu} \approx 16.5 \times 10^{-6}\;/\text{°C}$ is the linear thermal expansion coefficient of copper. For a simple cavity at 476.3 MHz, this gives:

```math
\frac{\partial f_0}{\partial T} \approx -f_0 \cdot \alpha_\text{Cu} = -476.3\;\text{MHz} \times 16.5 \times 10^{-6} \approx -7.9\;\text{kHz/°C} \qquad \text{(Eq. 4.7)}
```

> **Note**: This first-principles estimate ($-7.9$ kHz/°C) applies to the uncooled cavity body. In practice, the PEP-II-type cavities at SPEAR3 are water-cooled with a regulated cooling circuit that maintains body temperature to within $\sim \pm 0.1$°C. 

The tuner loop (§8) tracks both microphonics and thermal drift, maintaining the cavity at the optimum detuning angle $\psi_\text{opt}$ (Eq. 2.5a).

### 4.8 D9: Ring Circumference Thermal Drift — Long-Term RF Frequency Migration

**Physical origin**: The RF harmonic condition requires the RF operating frequency to equal an integer multiple of the revolution frequency:

```math
f_\text{RF} = h \cdot f_\text{rev} = \frac{h \cdot c}{C} \qquad \text{(Eq. 4.8)}
```

The ring circumference $C = 234.14$ m is set by the physical path of the beam through the tunnel. As the building structure thermally expands and contracts with seasonal temperature changes, $C$ varies slowly on a monthly-to-annual timescale. By the harmonic condition, the correct RF operating frequency must shift accordingly. A nominally fixed RF master oscillator becomes progressively detuned from the correct harmonic as the circumference drifts.

**Measured magnitude at SPEAR3**: The RF operating frequency drifts by approximately $\Delta f_\text{RF} \approx 4$ kHz over one year. From the harmonic condition:

```math
\frac{\Delta C}{C} = -\frac{\Delta f_\text{RF}}{f_\text{RF}} = -\frac{4\;\text{kHz}}{476.3\;\text{MHz}} = 8.4 \times 10^{-6} \qquad \text{(Eq. 4.8a)}
```

```math
\Delta C = 8.4 \times 10^{-6} \times 234.14\;\text{m} \approx 2.0\;\text{mm} \qquad \text{(Eq. 4.8b)}
```

A 2 mm annual change in the 234 m circumference is consistent with a tunnel temperature variation of $\sim$ 0.8°C (concrete/steel: $\alpha_\text{struct} \approx 10$–$12 \times 10^{-6}$/°C), physically plausible for a building with seasonal HVAC cycling.

**Contrast with D8 (cavity body thermal detuning)**:

| | D8: Cavity thermal detuning | D9: Ring circumference drift |
|---|---|---|
| **Physical origin** | Cavity copper temperature → $f_0$ shifts | Tunnel/building temperature → $C$ changes → required $f_\text{RF}$ shifts |
| **Rate** | $-7.9$ kHz/°C (Eq. 4.7); | $\sim 4$ kHz/year (measured operational data) |
| **Timescale** | Short-term (hourly) | Long-term (seasonal/annual) |
| **Control variable** | Tuner re-tracks $f_0$ relative to $f_\text{RF}$ | Tuner re-converges to new equilibrium as $f_\text{RF}$ migrates; RF master oscillator updated periodically |

**Impact on the control system**: The operating detuning $\Delta f = f_\text{RF} - f_0$ defines the tuner equilibrium. Both D8 and D9 shift $\Delta f$, but from opposite sides — D8 moves $f_0$ (cavity geometry changes), while D9 moves $f_\text{RF}$ (ring geometry changes). The tuner loop (§6.7) is closed around the detuning angle $\psi = \arctan(2Q_L \Delta f / f_0)$, so it automatically re-converges to $\psi_\text{opt}$ when $f_\text{RF}$ changes, provided:

1. The tuner mechanical range and total step count are sufficient to reach the new equilibrium position.
2. The RF master oscillator frequency is updated periodically by feedback system to track the ring operating point.

### 4.9 Frequency-Domain Summary: The Disturbance Spectrum

```
 Frequency (Hz)    Disturbance                  Required Loop
 ══════════════════════════════════════════════════════════════════════
 ~3×10⁻⁸ (annual) Ring circ. thermal drift (D9) Tuner (+ periodic RF MO update)
 0.001 – 0.01      Cavity thermal drift (D8)     Tuner loop (~0.01–1 Hz)
 0.01 – 1          Klystron gain (D6)            HVPS loop (~1 Hz), DAC loop (0.1 Hz)
 1 – 10            Slow mechanical (D7)          Tuner loop
 60 – 2000         HVPS ripple (D5)              Ripple loop (300 Hz) + Direct loop
 10³ – 10⁵         Beam transients (D2)          Direct loop (~800 kHz)
 ~10 kHz           Robinson (D3)                 Direct loop (impedance reduction)
 ~1.28 MHz         Coupled-bunch (D4)            Direct loop (+ Comb in PEP-II)
 ══════════════════════════════════════════════════════════════════════
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

→ See §6.1 for block-by-block symbol definitions, explicit compensator forms (Eq. 6.1a), gain/phase budget at crossover, and stability analysis.

**Closed-loop transfer function:**

```math
T(s) = \frac{G_\text{OL}(s)}{1 + G_\text{OL}(s)} \qquad \text{(Eq. 5.2)}
```

At frequencies well below $f_c$, $|G_\text{OL}| \gg 1$ and $T \approx 1$; above $f_c$, $T \to 0$.

**Effective cavity impedance seen by the beam:**

```math
Z_\text{eff}(\omega) = \frac{Z_\text{cav}(\omega)}{1 + G_\text{OL}(\omega)} \qquad \text{(Eq. 5.3)}
```

This is the central result. The direct loop **transforms the cavity from a high-impedance resonator into a low-impedance broadband structure**:

- At DC: impedance reduction $\sim 40$ dB (integrator provides very high gain)
- At $f_s \approx 10$ kHz: $\sim 30$ dB (Robinson sidebands well suppressed)
- At $\Delta f_{1/2} = 35.5$ kHz: $\sim 15$ dB
- At $f > f_c$: no reduction ($Z_\text{eff} \approx Z_\text{cav}$)

> **Sources**: [R15] Corredoura, Fig. 3; [R14]; [R11].

### 5.3 Comb Loop — Narrowband Enhancement at Revolution Harmonics (D4)

**Z-domain transfer function** [R15]:

```math
H_\text{comb}(z) = G\,\frac{z^{-1} - z^{-n}}{1 - 2K\cos(2\pi\nu_s)\,z^{-n} + K^2 z^{-2n}} \qquad \text{(Eq. 5.4)}
```

The comb filter produces gain peaks at frequencies $f = m \cdot f_\text{rev} \pm f_s$ for integer $m$, precisely targeting the revolution-harmonic sidebands that drive coupled-bunch instabilities (Eq. 4.4).

### 5.4 Slow Loops — Maintaining Operating Point (D6, D7, D8, D9)

- **Tuner Loop** ($\sim 0.01$–$1$ Hz): Adjusts cavity mechanical tuner to maintain $\psi_\text{opt}$ (Eq. 2.6), compensating cavity thermal drift (D8) and microphonics (D7). Also re-converges to the new equilibrium after a ring-circumference-driven RF frequency update (D9).
- **HVPS Loop** ($\sim 1$ Hz): Adjusts klystron cathode voltage to maintain $\sim 10\%$ below saturation.
- **DAC Loop** ($\sim 0.1$ Hz): Adjusts I/Q modulator baseline to maintain $V_\text{gap}$ setpoint.

### 5.5 Ripple Loop — HVPS Harmonic Rejection (D5)

Measures **klystron forward phase** (not cavity probe), avoiding the $35.5$ kHz cavity BW limitation. DSP at $\sim 23$ kHz sample rate tracks harmonics of 60 Hz.

### 5.6 Multi-Loop Stability: The Bandwidth Separation Principle

**Formal argument**: Consider two feedback loops acting on the same plant. Let $L_1(s)$ be the loop transfer function (return ratio) of the fast loop and $L_2(s)$ be that of the slow loop, where:

- $L_1(s) = G_\text{OL,fast}(s)$: the open-loop transfer function of the fast loop (e.g., the direct loop, with bandwidth $f_1 \sim 800$ kHz)
- $L_2(s) = G_\text{OL,slow}(s)$: the open-loop transfer function of the slow loop (e.g., the ripple loop, with bandwidth $f_2 \sim 300$ Hz)

The combined loop transfer function for the two nested loops is:

```math
L_\text{total}(s) = (1 + L_1(s))(1 + L_2(s)) - 1 = L_1(s) + L_2(s) + L_1(s)\,L_2(s) \qquad \text{(Eq. 5.5)}
```

The cross-term $L_1(s) \cdot L_2(s)$ represents the interaction between the two loops. At frequencies near $f_1$, $|L_2(j\omega)| \ll 1$ (the slow loop has negligible gain), so $L_\text{total} \approx L_1$ — the fast loop sees the slow loop as transparent. Conversely, at frequencies near $f_2$, $|L_1(j\omega)| \gg 1$ (the fast loop has high gain), but the cross-term simply augments the slow loop's authority without introducing new phase crossings, provided the bandwidth separation is sufficient.

The condition for safe decoupling — ensuring the cross-term does not introduce additional gain or phase crossings near either loop's crossover frequency:

```math
\frac{f_i}{f_{i+1}} \geq 10 \quad \text{for all adjacent loop pairs} \qquad \text{(Eq. 5.6)}
```

This ensures that at each loop's crossover frequency, all other loops are either at very high gain (inner loops) or very low gain (outer loops), so the Nyquist criterion can be applied to each loop independently.

SPEAR3 satisfies this with large margins: DAC $\to$ HVPS ($10\times$), HVPS $\to$ Ripple ($300\times$), Ripple $\to$ Direct ($2700\times$). The smallest separation (DAC→HVPS, $10\times$) is adequate because both are slow integrating loops with well-separated crossover frequencies.

> **Sources**: [R14]; [R15]; Åström & Murray, *Feedback Systems*, Ch. 12.

---

## 6. Loop-by-Loop Transfer Functions and Design

This section provides the transfer function, control law, and design rationale for each feedback loop. The subsections follow a consistent structure: **purpose → signal flow → transfer function → key parameters → design constraints**.

### 6.0 Loop Overview and Implementation Summary

The bandwidth requirement of each disturbance dictates the implementation technology. Microsecond-scale beam loading demands analog hardware with continuous processing. Millisecond-scale HVPS ripple is handled by a dedicated DSP. Second-scale drift is corrected by IOC software running in EPICS. This principle — **disturbance timescale → implementation tier** — makes the entire multi-loop architecture a natural consequence of the physics.

| Loop | §Ref | Implementation | Update Rate | Controller Type | Bandwidth | SPEAR3 Status |
|------|:----:|----------------|:-----------:|-----------------|:---------:|:-------------:|
| Direct | 6.1 | Analog hardware (VXI RFP module) | Continuous | Lead-lag + PI | ~800 kHz | Active |
| Comb | 6.2 | Digital hardware (VXI CFM, IIR + FIR) | ~10 MHz | IIR comb + FIR equalizer | ~2 MHz span | Not used |
| LFB Woofer | 6.3 | Digital hardware (GVF module, TAXI fiber) | ~10 MHz | External injection | ~1 MHz | Not used |
| Ripple | 6.4 | Digital hardware (AT&T DSP1610) | 23 kHz | Adaptive harmonic estimator | ~300 Hz | Active |
| Gap FF | 6.5 | Digital hardware (GVF module DSP) | ~10 MHz | Feed-forward | ~100 Hz | Not used |
| HVPS | 6.6 | Real-time software (EPICS SNL) | ~1 Hz | Proportional + deadband | ~1 Hz | Active |
| Tuner | 6.7 | Real-time software (EPICS SNL) | ~1 Hz | Bang-bang | ~0.01–1 Hz | Active |
| DAC | 6.8 | Real-time software (EPICS SNL) | Event / 10 s | Proportional + deadband | ~0.1 Hz | Active |
| Gain Tracking | 6.9 | Supervisory software (EPICS CA) | ~2 Hz | Ratio maintenance | ~0.5 Hz | Active |

The loops naturally partition into four implementation tiers:

1. **Analog hardware** (continuous): The direct loop — minimum latency path for the fastest disturbances (D1–D4).
2. **Digital hardware** (MHz-rate): Comb, woofer, gap feedforward, and ripple loops — dedicated DSP/FPGA processing for structured disturbances (D4, D5).
3. **Real-time software** (~1 Hz): HVPS, tuner, and DAC loops — EPICS programs managing slow plant dynamics (D6–D8).
4. **Supervisory software** (~0.1–2 Hz): Gain tracking — EPICS Channel Access for calibration maintenance.

### 6.1 Direct Loop — Wideband RF Field Regulation

**Purpose**: Reduces the effective cavity impedance seen by the beam by $\sim 40$ dB at low frequencies, suppressing Robinson instability (D3), coupled-bunch growth (D4), and regulating against beam loading transients (D1–D2). This is the primary stability loop.

**Signal flow**: Cavity probe I/Q (4 cavities, vector-summed) → error amplifier (compare to reference) → lead/integral compensator → baseband modulator (gain tracking) → I/Q RF modulator → drive amplifier → klystron → cavities.

**Open-loop transfer function** (restating Eq. 5.1 with component forms from §5.2):

```math
G_\text{OL}(s) = K_p \cdot \frac{1 + s/\omega_z}{1 + s/\omega_p} \cdot \left(1 + \frac{\omega_i}{s}\right) \cdot K_\text{kly} \cdot \frac{R_s\,\omega_{1/2}}{s + \omega_{1/2}} \cdot e^{-s\tau_d} \qquad \text{(Eq. 6.1a)}
```

where the terms are (left to right): proportional gain, lead compensator, PI integrator, klystron gain, cavity response, and transport delay. All symbols are defined in the Eq. 5.1 table (§5.2).

**Gain and phase budget at crossover** ($f_c \approx 800$ kHz legacy, $\approx 930$ kHz LLRF9):

| Contributor | Gain at $f_c$ | Phase at $f_c$ |
|-------------|:----:|:----:|
| Proportional $K_p$ | $+15$ dB | $0^\circ$ |
| Lead compensator | $+3$ to $+6$ dB | $+30^\circ$ to $+50^\circ$ (advance) |
| PI integrator | $\approx 0$ dB (above $\omega_i$) | $\approx 0^\circ$ |
| Cavity $H_\text{cav}$ | $-20\log_{10}(f_c/\Delta f_{1/2})$ | $-90^\circ + \arctan(\Delta f_{1/2}/f_c)$ |
| Transport delay | $0$ dB | $-360^\circ \cdot f_c \cdot \tau_d$ |
| **Net at crossover** | **$0$ dB** (by definition) | **$> -135^\circ$** (PM $> 45^\circ$) |

**Stability margins**: Phase margin $\geq 45^\circ$ (required), gain margin $\geq 6$ dB (required). The lead compensator zero and pole frequencies are chosen to provide sufficient phase advance at crossover to compensate the cavity pole ($-90^\circ$) and delay lag ($-\omega_c\tau_d$).

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D1–D4 | Primary stability loop |
| Measurement | Cavity probe vector sum (I/Q) | After combining network |
| Actuator | I/Q modulator on klystron drive | Direct analog path, minimum delay |
| Bandwidth $f_c$ | $\sim 800$ kHz (legacy) / $\sim 930$ kHz (LLRF9) | Limited by $\tau_d$ via Eq. 2.11 |
| Proportional gain $K_p$ | $\sim 15$ dB ($\approx 5.6$) | Adjustable via EPICS PV |
| Integrator frequency $\omega_i$ | $\sim 2\pi \times 30$ kHz | Rejects DC errors |
| Phase margin | $\geq 45^\circ$ | Maintained by lead compensation |
| DC impedance reduction | $\sim 40$ dB | $\approx 100\times$ reduction in $\|Z_\text{eff}\|$ |
| SPEAR3 status | **Active** | — |

> **Sources**: [R15] Corredoura, Figs. 3, 5; [R14] Schwarz; [R11] Gamp.

### 6.2 Comb Loop — Narrowband Enhancement at Revolution Harmonics

**Purpose**: Provides an additional ~20 dB of impedance reduction at revolution frequency harmonics — precisely where coupled-bunch modes are driven (D4) — complementing the broadband reduction of the direct loop. Between revolution harmonics, the comb gain returns to unity, avoiding unnecessary noise amplification.

**Signal flow**: Cavity probe I/Q → ADC → IIR comb filter → FIR group delay equalizer → one-turn delay + vernier → DAC → summing node (added to direct loop output).

**IIR comb transfer function** (restating Eq. 5.4 with engineering context):

```math
H_\text{comb}(z) = G\,\frac{z^{-1} - z^{-n}}{1 - 2K\cos(2\pi\nu_s)\,z^{-n} + K^2 z^{-2n}} \qquad \text{(Eq. 5.4)}
```

The peak gain at each comb tooth is $G_\text{peak} = G/(1-K)$, and the $-3$ dB bandwidth per tooth is approximately $(1-K) \cdot f_\text{rev}/\pi$. For typical PEP-II parameters ($K \approx 0.95$, $G \approx 0.05$), peak gain $\approx 1$ (unity) and tooth bandwidth $\approx 2.2$ kHz — narrow enough to target individual synchrotron sidebands without amplifying inter-harmonic noise.

**Closed-loop impedance with Direct + Comb**: The combined impedance reduction at a revolution harmonic $m \cdot f_\text{rev}$ is:

```math
Z_\text{eff,D+C}(\omega) = \frac{Z_\text{cav}(\omega)}{1 + G_\text{OL,direct}(\omega) + G_\text{OL,comb}(\omega)} \qquad \text{(Eq. 6.2a)}
```

At revolution harmonics where both loops have authority, the impedance reduction is the product of the individual factors: the direct loop provides ~20 dB broadband, and the comb adds ~20 dB at targeted harmonics, for a combined ~40 dB at revolution sidebands.

**Group delay equalization**: A 32-tap FIR filter compensates for the frequency-dependent group delay of the cavity and transport path across the comb filter's operating range ($\sim 4$ MHz centered on $f_\text{RF}$). The FIR coefficients are designed for the worst-case detuned cavity condition, maintaining phase linearity to $< 10^\circ$ over the full bandwidth. The one-turn delay is implemented as a FIFO and fine-adjusted with shift registers at 25 ns steps to match the revolution period to sub-ns precision.

```math
H_\text{eq}(z) = \sum_{k=0}^{31} c_k\, z^{-k} \qquad \text{(Eq. 6.2b)}
```

The complete comb path transfer function including equalization:

```math
G_\text{OL,comb}(z) = H_\text{comb}(z) \cdot H_\text{eq}(z) \cdot z^{-n_\text{delay}} \qquad \text{(Eq. 6.2c)}
```

where $n_\text{delay}$ accounts for the hardware transport delay (ADC + DAC + cable propagation).

> **Sources**: [R15] Corredoura, SLAC-PUB-8498, Figs. 4–6; [R14] Schwarz.

### 6.3 LFB Woofer — Longitudinal Feedback via RF Modulation

**Purpose**: Provides broadband damping of low-order coupled-bunch modes ($|n| < 10$) by using the RF station as a longitudinal "sub-woofer" kicker (D2). In the multi-band longitudinal feedback architecture, the woofer handles the low-frequency content of the bunch oscillation spectrum (up to ~1 MHz), while a dedicated stripline kicker (the "tweeter") handles high-frequency content. This is the standard PEP-II/ALS/APS longitudinal damping architecture.

**Signal flow**: LFB BPM pickup → bunch-by-bunch DSP processing (external system) → 10-bit fiber-optic TAXI link at 10 MHz → GVF module DAC → FIR group delay equalizer → injection summing node → I/Q reference modulation.

**Transfer function**: The woofer acts as an additive correction to the static I/Q reference:

```math
\vec{V}_\text{ref,total}(s) = \vec{V}_\text{ref,static} + K_\text{woofer} \cdot H_\text{FIR}(s) \cdot e^{-s\tau_\text{woofer}} \cdot \Delta\vec{V}_\text{LFB}(s) \qquad \text{(Eq. 6.3a)}
```

where:
- $K_\text{woofer}$ is the woofer injection gain (adjustable), setting the strength of RF modulation per unit LFB correction signal
- $H_\text{FIR}(s)$ is the same 32-tap group delay equalizer used for the comb filter (Eq. 6.2b), compensating cavity and transport delay across the woofer bandwidth
- $\tau_\text{woofer}$ is the one-turn injection delay (matching the revolution period for proper bunch alignment)
- $\Delta\vec{V}_\text{LFB}(s)$ is the LFB correction signal received over the TAXI fiber link

**Woofer/Tweeter complementarity**: The longitudinal feedback system partitions the correction bandwidth between two actuators:

| Actuator | Mechanism | Bandwidth | Modes Addressed |
|----------|-----------|---------|---------------|
| Woofer (RF station) | Modulates cavity voltage via I/Q reference injection | DC – ~1 MHz | Low-order  |
| Tweeter (stripline kicker) | Direct longitudinal kick via broadband kicker | ~1 – ~200 MHz | High-order  |

The RF station woofer is effective for low-order modes because these modes require large energy corrections at low frequency — naturally suited to the high-power RF cavity. Higher-order modes require fast, broadband corrections — suited to the stripline kicker's low latency.

**Interaction with direct loop**: The woofer injection enters upstream of the direct loop error point (at the reference input), so the direct loop sees the modified reference as its setpoint and tracks it. This means the woofer operates *through* the direct loop rather than in parallel, and the direct loop's bandwidth ($\sim 800$ kHz) sets an upper limit on the effective woofer bandwidth.

| Parameter | PEP-II Value | SPEAR3 Notes |
|-----------|:----:|----|
| Addresses | D2, D4 (low-order coupled-bunch) | — |
| External system | LFB bunch-by-bunch DSP | Not installed |
| Data link | TAXI fiber, 10-bit, 10 MHz | — |
| Injection hardware | GVF VXI module | Present but unused |
| FIR equalizer | 32-tap (shared design with comb) | — |
| One-turn delay | $\approx 7.34\;\mu\text{s}$ (PEP-II) | — |
| Effective bandwidth | DC – ~1 MHz | — |
| SPEAR3 status | — | **Not used** |

**Why not needed at SPEAR3**: SPEAR3 does not have a longitudinal feedback system installed. At 500 mA beam current with $h = 372$, the coupled-bunch instability growth rates are manageable with the direct loop alone. PEP-II required the woofer to damp strong coupled-bunch oscillations driven by the high beam current ($> 1$ A) and large harmonic number ($h = 3{,}492$) where many more revolution harmonics drive unstable modes.

> **Sources**: [R15] Corredoura, SLAC-PUB-8498; [R16] Fox et al., LFB system design; [R14] Schwarz.

### 6.4 Ripple Loop — HVPS Harmonic Rejection

**Purpose**: Cancels RF amplitude and phase modulation caused by HVPS switching ripple (D5). The ripple appears as harmonics of 60 Hz on the klystron cathode voltage, modulating klystron gain and phase via AM-PM conversion.

**Signal flow**: Klystron forward I/Q → I/Q demodulation → DSP phase/amplitude extraction → harmonic estimator → correction I/Q → DAC → summing node with direct loop.

**Key design choice**: Measures the **klystron forward signal** (not cavity probe), because the ripple frequencies ($< 2$ kHz) are well within the cavity bandwidth ($35.5$ kHz) and the correction must be applied upstream.

**Harmonic estimator algorithm** (from `ripple.s` [R36]): The DSP implements an adaptive harmonic tracker — for each harmonic $k$:

```math
\hat{A}_k[n] = \hat{A}_k[n-1] + \mu_k \cdot e[n] \cdot \cos(2\pi k f_\text{line} n T_s) \qquad \text{(Eq. 6.4a)}
```

```math
\hat{B}_k[n] = \hat{B}_k[n-1] + \mu_k \cdot e[n] \cdot \sin(2\pi k f_\text{line} n T_s) \qquad \text{(Eq. 6.4b)}
```

```math
u[n] = \sum_{k} \left[\hat{A}_k \cos(2\pi k f_\text{line} n T_s) + \hat{B}_k \sin(2\pi k f_\text{line} n T_s)\right] \qquad \text{(Eq. 6.4c)}
```

where $e[n] = \phi_\text{ref} - \phi_\text{kly}$ is the phase error at sample $n$, $\hat{A}_k, \hat{B}_k$ are the estimated cosine/sine coefficients of the $k$-th harmonic, $\mu_k$ is the adaptation gain for harmonic $k$, $f_\text{line} = 60$ Hz, and $T_s = 1/23\;\text{kHz}$ is the sampling period. This is a **narrowband adaptive notch** algorithm that converges on the exact amplitude and phase of each harmonic.

**Dual-rate processing**: 6 fast harmonics (60–360 Hz, every cycle at 23 kHz) + 8 slow harmonics (420–840 Hz, round-robin at $\sim 2.9$ kHz effective rate). Fixed-point: q13 (phase), q11 (accumulators with $[-16, +16)$ headroom), q15 (gains).

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D5 (HVPS ripple) | Harmonic rejection |
| Measurement | Klystron forward I/Q | Upstream of cavity |
| Effective bandwidth | $\sim 300$ Hz (fast) / $\sim 1.5$ kHz (slow) | Limited by DSP sample rate |
| Algorithm | Adaptive harmonic estimator | 6 fast + 8 slow harmonics |
| Sample rate | $\sim 23$ kHz | Hardware ripple clock on RFP module |
| DSP | AT&T DSP1610 (16-bit fixed-point) | On RFP VXI module |
| SPEAR3 status | **Active** (primarily as slow phase tracker) | |

> **Note**: In SPEAR3 operations, the ripple loop is deployed primarily as a **slow phase tracker** compensating for klystron phase shifts across cathode voltage changes (D6). The LLRF9 inherently rejects HVPS ripple through its high-bandwidth direct loop, making the legacy DSP-based ripple loop unnecessary in the upgrade.

> **Sources**: [R36] `ripple.s`; [R20t]; [R14] Schwarz §5.

### 6.5 Gap Feedforward Loop

Not used at SPEAR3. Addresses D2 (ion clearing gap transient). In PEP-II, the GVF module provided pre-computed I/Q correction waveforms via DSP firmware (`gvff.s`). Not needed at SPEAR3 due to smaller harmonic number ($h = 372$ vs. PEP-II $h = 3{,}492$).

### 6.6 HVPS Loop — Klystron Operating Point Regulation

**Purpose**: Adjusts the klystron cathode voltage $V_k$ to maintain the klystron operating point at $\sim 10\%$ below saturation (D6), ensuring the direct loop has sufficient headroom for fast corrections.

**Signal flow**: Klystron forward power monitor (or station gap voltage) → EPICS SNL (`rf_hvps_loop.st`) → PLC HVPS voltage setpoint → Enerpro SCR firing angle → cathode voltage $V_k$.

**Control law** (from `rf_hvps_loop.st`): Operates in two modes:

1. **Processing mode** (`STATION_PROC`): Slowly ramps $V_k$ upward while monitoring cavity vacuum, conditioning the cavities by gradually increasing RF power.

2. **Operating mode** (`STATION_ON_CW`): Proportional controller with deadband and rate limiting:

```math
\Delta V_k[n] = \begin{cases} K_\text{HVPS} \cdot (P_\text{target} - P_\text{measured}) & \text{if } |P_\text{target} - P_\text{measured}| > P_\text{deadband} \\ 0 & \text{otherwise} \end{cases} \qquad \text{(Eq. 6.6a)}
```

where $K_\text{HVPS}$ is the proportional gain (voltage step per unit power error), clamped to a maximum step size per cycle.

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D6 | Operating point regulation |
| Measurement | Klystron forward power or station gap voltage | Mode-selectable |
| Actuator | HVPS cathode voltage $V_k$ | Via PLC → Enerpro firing angle |
| Bandwidth | $\sim 1$ Hz | Limited by PLC scan rate and Enerpro settling |
| Update rate | $\sim 2$ Hz ($\sim 0.5$ s cycle) | Configurable via `hvps_loop_delay` |
| Control law | Proportional with deadband | Rate-limited output |
| Implementation | EPICS SNL: `rf_hvps_loop.st` (343 lines, 4 states) | States: init, off, proc, on |
| SPEAR3 status | **Active** | |

> **Sources**: [R14]; `spear-rf-code-legacy/rfApp/src/seq/rf_hvps_loop.st`.

### 6.7 Tuner Loop — Cavity Resonant Frequency Tracking

**Purpose**: Adjusts the mechanical cavity tuner to maintain the optimum detuning angle $\psi_\text{opt}$ (Eq. 2.5a), compensating for beam loadng (main factor), cavity thermal drift (D8) and microphonics (D7). Also re-converges to the new equilibrium following a ring-circumference-driven shift in the RF operating frequency (D9).

**Signal flow**: Cavity probe phase and klystron forward phase → phase subtraction → comparison to $\psi_\text{target}$ → deadband logic → stepper motor command → mechanical tuner.

**Control law** (from `rf_tuner_loop.st` [R34]):

```math
\varepsilon = \left[\angle(V_\text{probe}) - \angle(V_\text{fwd})\right] - \psi_\text{target} \qquad \text{(Eq. 6.7a)}
```

```math
\text{Step command} = \begin{cases} +N_\text{step} & \text{if } \varepsilon > \varepsilon_\text{deadband} \\ -N_\text{step} & \text{if } \varepsilon < -\varepsilon_\text{deadband} \\ 0 & \text{otherwise} \end{cases} \qquad \text{(Eq. 6.7b)}
```

**Frequency offset estimation** (from `subSysFreqOff` in `subSys.c`):

```math
\Delta f_\text{est}(x, V) = p_0 + p_1(x - x_\text{home}) + p_2(x - x_\text{home})^2 + p_3(x - x_\text{home})^3 + t_1 V^2 \qquad \text{(Eq. 6.7c)}
```

where $x$ is the tuner position (steps), $x_\text{home}$ is the home position, $p_0\ldots p_3$ are polynomial coefficients from calibration, and $t_1 V^2$ accounts for voltage-dependent detuning. Exponential smoothing is applied.

| Parameter | Value | Notes |
|-----------|-------|-------|
| Addresses | D7, D8, D9 | Frequency tracking (microphonics + cavity thermal + ring circ. drift) |
| Measurement | $\angle(\text{probe}) - \angle(\text{fwd})$ | Detuning angle proxy |
| Actuator | Stepper motor → mechanical tuner plunger | Per cavity (4 independent loops) |
| Bandwidth | $\sim 0.01$–$1$ Hz | Limited by mechanical response |
| Control law | Bang-bang with deadband | $N_\text{step}$ steps per correction cycle |
| Tuning resolution | $\sim 1$ Hz/step | Worm gear mechanism, self-locking |
| Implementation | EPICS SNL: `rf_tuner_loop.st` (555 lines) | States: init, unknown, reset, off, on |
| Motor controller | Galil DMC-4143 (Rev 1.3h, commissioned Aug 2025) | Replaces legacy AB 1746-HSTP1 |
| SPEAR3 status | **Active** | |

> **Sources**: [R14]; [R34] `rf_tuner_loop.st`; [R35] Galil commissioning notes.

### 6.8 DAC Loop — Outermost Amplitude Regulation

**Purpose**: Maintains the cavity gap voltage (or klystron drive power) at the software setpoint by adjusting the I/Q modulator baseline DAC values. This is the outermost and slowest feedback loop, compensating for long-term drifts.

**Signal flow**: Gap voltage readback (cavity probe amplitude) or drive power readback → error calculation → proportional controller with deadband → DAC count adjustment → RFP Octal DAC → I/Q modulator baseline.

**Control law** (from `rf_dac_loop.st` and `subIQcounts` in `subIQ.c`):

```math
\Delta C_\text{DAC}[n] = K_\text{DAC} \cdot (V_\text{set} - V_\text{meas}) \cdot D_\text{conv} \cdot (1 + G_\text{loop}) \qquad \text{(Eq. 6.8a)}
```

where $\Delta C_\text{DAC}$ is the DAC count change, $K_\text{DAC}$ is proportional gain (0–1), $D_\text{conv}$ is the calibration conversion factor (counts/kV), and $G_\text{loop}$ is the direct loop gain correction. Output subject to deadband, rate limiting ($|\Delta C| \leq \Delta C_\text{max}$), and range limiting ($\pm 2047$ counts, 12-bit DAC).

**Operating modes** (station-state dependent):

| Station State | DAC Loop Mode | Controlled Variable |
|---------------|:-:|:-:|
| `STATION_OFF` / `STATION_PARK` | Inactive | — |
| `STATION_TUNE` | Drive power regulation | Tune-mode DAC |
| `STATION_ON_CW`, direct loop OFF | Drive power regulation | RFP DAC |
| `STATION_ON_CW`, direct loop ON | Gap voltage regulation | RFP DAC |

| Parameter | Value | Notes |
|-----------|-------|-------|
| Bandwidth | $\sim 0.1$ Hz | Limited by scan rate and smoothing |
| Update rate | Event-driven or $\leq 10$ s timeout | `DAC_LOOP_MAX_INTERVAL = 10.0` |
| DAC range | $\pm 2047$ counts (12-bit) | Minimum delta: 0.5 counts |
| Implementation | EPICS SNL: `rf_dac_loop.st` (290 lines, 4 states) | init, off, tune, on |
| SPEAR3 status | **Active** | |

> **Sources**: `rf_dac_loop.st`; `subIQ.c` (`subIQcounts`).

### 6.9 Gain Tracking Function

**Purpose**: Compensates for klystron gain variation (D6) as cathode voltage changes. The klystron small-signal gain varies by up to $\sim 7$ dB across the operating range; without tracking, this shifts the direct loop's open-loop gain and stability margins.

**Control law**:

```math
G_\text{modulator} \cdot G_\text{klystron}(V_k) = G_\text{loop,target} \;(\text{constant}) \qquad \text{(Eq. 6.9a)}
```

```math
\therefore\; G_\text{modulator} = G_\text{loop,target} \,/\, G_\text{klystron}(V_k) \qquad \text{(Eq. 6.9b)}
```

**Implementation**: A slow EPICS calculation (~2 Hz) reads klystron forward and drive power monitors, computes current gain $G_\text{kly} = P_\text{fwd}/P_\text{drive}$, and writes updated $2\times 2$ matrix coefficients to the RFP Octal DAC. The `ConfDirect` calibration routine performs initial gain measurement and matrix setup.

The DC gain coefficient tracking in `subSysDCcoeff` adjusts the ripple loop's DC coefficient based on klystron gain deviations with deadband limiting:

```math
\Delta G_\text{DC} = D_\text{scale} \cdot 10^{(G_\text{desired} + L_\text{accum})/20} - G_\text{actual} \qquad \text{(Eq. 6.9c)}
```

> **Sources**: [R15]; [R14]; `subSys.c` (`subSysDCcoeff`).


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

| Parameter | Value |
|-----------|-------|
| Motor | Superior Electric Slo-Syn M093-FC11 (NEMA 34D) |
| Drive mechanism | Worm gear (self-locking) |
| Tuning range | $\sim \pm 200$ kHz |
| Step resolution | $\sim 1$ Hz/step |
| Distance per microstep | $3.175\;\mu\text{m}$ (legacy), $0.05\;\mu\text{m}$ (Galil) |

> **Sources**: [R29]–[R33] Tuner documentation in `llrf/tuners/`.

### 8.2 Tuning Physics

```math
f_\text{res}(x) = \text{polynomial fit (3rd–4th order)} \qquad \text{(Eq. 8.1)}
```

Temperature dependence: $\sim -1$ kHz/°C.

### 8.3 Tuner Control Loop

```math
\varepsilon = \left[\angle(\text{probe}) - \angle(\text{fwd})\right] - \psi_\text{target} \qquad \text{(Eq. 8.2)}
```

where $\psi_\text{target}$ is the target detuning angle (Eq. 2.6). Implemented in `rf_tuner_loop.st` (EPICS SNL). Bandwidth $\sim 0.01$–$1$ Hz.

> **Sources**: [R14]; [R34] `rf_tuner_loop.st`; [R35] Galil commissioning notes.

---

## 9. Performance Requirements and Verification

### 9.1 Disturbance Rejection Summary

| Disturbance | Frequency | Open-Loop Impact | Rejection | Residual |
|-------------|-----------|:-:|:-:|:-:|
| Beam loading (D1–D2) | DC–100 kHz | Unstable | $\sim 40$ dB | Stable |
| Robinson (D3) | $\sim 10$ kHz (Eq. 2.4b) | Exponential growth | $\sim 40$ dB | $\ll 1/\tau_s$ |
| HVPS ripple (D5) | 360–2000 Hz | $\sim 1\%$ phase | $\sim 40$ dB | $< 0.01\%$ |
| Thermal drift (D8) | $< 0.01$ Hz | $\sim 100$ Hz/hr | Tuner tracks | $< 1$ Hz |
| Klystron gain (D6) | 0.01–1 Hz | $\sim 7$ dB var. | Gain tracking | $< 0.5$ dB |

### 9.2 LLRF9 Commissioning Results

From [R4]: LLRF9 achieves improved noise floor vs. legacy at 500 mA. Overall amplitude stability $< 0.05\%$ RMS, phase stability $< 0.05^\circ$ RMS — both exceed requirements.

### 9.3 Performance Margins

| Parameter | Capacity | Typical | Margin |
|-----------|:-:|:-:|:-:|
| Klystron power | 1.2 MW | $\sim 782$ kW ($4 \times 196$) | $\sim 35\%$ |
| HVPS voltage | 90 kV | $\sim 74$ kV | $\sim 22\%$ |
| Gap voltage/cavity | 1 MV | $\sim 712$ kV | $\sim 40\%$ |
| Direct loop BW | $\sim 930$ kHz | $\sim 800$ kHz | $\sim 16\%$ |
| Impedance reduction | $\sim 40$ dB | Required $\sim 30$ dB | $> 10$ dB margin |

### 9.4 Calibration Data

Calibration establishes the numerical relationships between raw hardware signals (ADC counts, DAC counts, detector voltages) and physical quantities (kV, kW, degrees, Hz). It is essential for closing all feedback loops accurately. This section provides a high-level summary; detailed calibration procedures and data tables will be documented in **Doc D (Operational Data Catalog)**.

#### 9.4.1 Calibration Sequence Overview

The master calibration is executed by `rf_calib.st` (3,345 lines, 27 states). It runs as an EPICS SNL program and requires the station to be OFF (no RF power). The sequence progresses through the following phases:

| Phase | States | What It Does |
|-------|--------|-------------|
| **Initialization** | Startup, CombCheck, Setup | Registers with RFP module, verifies hardware, sets known baseline |
| **Zero all multipliers** | ZeroCavMults, ZeroDirMults, ZeroCombMults | Writes zero to all I/Q modulator DACs — establishes the "no signal" baseline for offset measurement |
| **Combiner calibration** | Combiner | Calibrates the 4 cavity combining modulators: measures each probe independently, adjusts I/Q matrix for accurate vector sum |
| **Direct loop calibration** | Direct, SummingNodeI/Q, GainStageI/Q | Characterizes direct loop gain stages and summing node offsets. I and Q channels measured independently to resolve cross-coupling |
| **Klystron chain** | ZeroKlysMults, DiffNodeOffsets, KlysStage, CompStage, CombStage, KlysDemod | Calibrates klystron forward path: drive modulator offsets, klystron gain, compensator stages, demodulator phase alignment |
| **Tuner & modulator** | TuneStage, NullModulator | Calibrates tune-mode drive path; nulls RF modulator output (zero DAC → zero RF) |
| **Completion** | Finish/Done or Abort/Abend | Restores operational configuration, reports success/failure |

Each state includes retry logic (`NUM_TRIES` iterations), severity checking on PV readbacks, and abort handling. The entire sequence takes ~2–5 minutes.

#### 9.4.2 Drive Amplitude Calibration

Establishes the mapping from DAC counts to klystron input drive power. Data files: `driveAmpCalibration.xlsx`, `klystronCouplerDriveAmpCalibrations.xlsx`.

The key relationship is the **drive conversion constant** $D_\text{conv}$ (counts/kV), computed by `subIQampl2conv`:

```math
D_\text{conv} = \frac{A_\text{ref}}{V_\text{gap} \cdot (1 + G_\text{loop})} \qquad \text{(Eq. 9.1)}
```

where $A_\text{ref}$ is the reference amplitude (counts), $V_\text{gap}$ is the measured gap voltage (kV), and $G_\text{loop}$ is the feedback loop gain. This constant is used by the DAC loop (Eq. 6.8a) and recomputed whenever the operating point changes.

#### 9.4.3 Power Measurement Calibration

Maps RF detector voltages to physical power levels. Data files: `reflectedPowerCalibrations.xlsx`, `pulsarCouplerCalibration2049.xlsx`.

The **RF detector conversion loss** measured during calibration (`subIQampl2loss`):

```math
L_\text{det} = 20 \cdot \log_{10}\!\left(\frac{E_\text{conv} \cdot \sqrt{P_\text{cal}}}{A_\text{det}}\right) \;\text{dB} \qquad \text{(Eq. 9.2)}
```

where $E_\text{conv} = 0.31623$ (power conversion constant), $P_\text{cal}$ is calibration power (mW), and $A_\text{det}$ is measured detector amplitude (V). Accounts for cable attenuation, coupler directivity, and detector nonlinearity.

The **coupling factor** (VSWR-based, `subIQamplCplg`):

```math
\beta_\text{meas} = \frac{1 + r}{1 - r}, \qquad r = \frac{A_\text{refl}}{A_\text{fwd}} \qquad \text{(Eq. 9.3)}
```

#### 9.4.4 Frequency and Detuning Calibration

Maps tuner motor position to cavity resonant frequency offset. The polynomial model (Eq. 6.7c) is fitted from measured data: the tuner is stepped across its range and the resonant frequency measured at each position. Calibration coefficients $p_0, \ldots, p_3$ and temperature coefficient $t_1$ are stored in EPICS PVs.

#### 9.4.5 Tuner Mode DAC Calibration

Data file: `tuneModeDacCalibration.xlsx`. Establishes DAC counts-to-drive-power for the `STATION_TUNE` state (low-power cavity conditioning). Separate from operational drive calibration (§9.4.2) because the operating point differs.

#### 9.4.6 Signal Routing and Patch Panel

Data file: `b132R11PatchPanel.xlsx`. Documents physical signal routing in Building 132 R11: cable lengths, attenuation values, connector types, and signal naming. Essential for verifying the delay budget (§2.3) and signal levels.

> **Upgrade note**: Many calibrations will need adaptation for the LLRF9 system (different ADC/DAC ranges, signal levels, processing gains). The polynomial frequency model (Eq. 6.7c) and combiner matrix calibration are expected to transfer; drive and power detector calibrations require new measurements.

> **Sources**: [R38]; [R39]; `rf_calib.st`; `subIQ.c` (§2.2 of [R20u]).

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
| RF frequency | $f_\text{RF}$ | 476.3 | MHz | [R4] |
| Momentum compaction | $\alpha_c$ | $1.18 \times 10^{-3}$ | — | [R2] |
| Energy loss per turn | $U_0$ | 1.02 | MeV | Operational (current IDs) |
| Total RF voltage (design) | $V_\text{RF}$ | 3.2 | MV | [R1] [R3] |
| Total RF voltage (operational) | $V_\text{RF}$ | ~2.85 | MV | [R4] [R5] |
| Synchronous phase | $\phi_s$ | 69.0 | deg | Eq. 2.4a ($\cos$ convention) |
| Synchrotron tune | $\nu_s$ | ~0.008 | — | Eq. 2.4b; [R1] |
| Synchrotron frequency | $f_s$ | ~10.1 | kHz | Eq. 2.4b |
| Long. radiation damping time | $\tau_s$ | 2.87 | ms | [R1] |
| Trans. radiation damping time | $\tau_{x,y}$ | 4.24, 5.14 | ms | [R1] |

### A.2 Cavity Parameters (Per Cavity)

| Parameter | Symbol | Value | Unit | Source |
|-----------|--------|-------|------|--------|
| Resonant frequency | $f_0$ | 476.315 | MHz | [R6] |
| Shunt impedance (linac) | $R_s$ | 3.73 | MΩ | [R6] |
| $R/Q$ | $R/Q$ | ~116 | Ω | [R7] |
| Unloaded Q | $Q_0$ | 32,000 | — | [R6] |
| Loaded Q | $Q_L$ | 6,700 | — | Derived from $\beta = 3.78$ |
| Coupling coefficient (this doc) | $\beta$ | 3.78 | — | Derived |
| Coupling coefficient (Schwarz actual) | $\beta$ | 3.72 | — | [R6] |
| Coupling coefficient (Schwarz optimum) | $\beta$ | 3.84 | — | [R6] |
| Cavity half-bandwidth | $\Delta f_{1/2}$ | 35.5 | kHz | Derived |
| Operational gap voltage | $V_\text{gap}$ | ~712 | kV | [R5] |
| Beam-induced voltage | $V_{b,\text{res}}$ | 1.865 | MV/cav | Eq. 2.2: $I_b R_s$ |
| Optimum detuning angle | $\psi_\text{opt}$ | $\approx -67.8$ | deg | Eq. 2.5a |
| Optimum frequency detuning | $\Delta f_\text{opt}$ | $\approx -87$ | kHz | Eq. 2.6 |
| Cavity wall losses | $P_\text{wall}$ | ~68.1 | kW/cav | Eq. 2.7a |
| Beam power per cavity | $P_\text{beam}/n_\text{cav}$ | ~127.5 | kW/cav | Eq. 2.7b |
| Generator power per cavity | $P_\text{gen/cav}$ | ~196 | kW | Eq. 2.7c |
| Total RF power (4 cav) | $P_\text{gen,tot}$ | ~782 | kW | $4 \times P_\text{gen/cav}$ |

### A.3 Klystron Parameters

| Parameter | Value | Unit | Source |
|-----------|-------|------|--------|
| Type | Marconi/CPI K3512S | — | [R1] |
| Maximum power | 1.2 MW CW | — | [R1] |
| Gain | 43 dB min | — | [R1] |
| Bandwidth | 5 MHz ($-3$ dB) | — | [R1] |
| Group delay | $< 150$ ns | — | [R1] |
| Drive power | $\sim 29$ W | — | [R5] |
| Perveance | $\sim 2.0 \times 10^{-6}$ | $\text{A/V}^{3/2}$ | [R23] |

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
| [R3] | SSRL SPEAR Storage Ring Parameters, https://www-ssrl.slac.stanford.edu/accphy/spear_parameters.html (last updated 26 Apr 2002, H.-D. Nuhn) |
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
| [W8] | https://www-ssrl.slac.stanford.edu/accphy/spear_parameters.html | SSRL SPEAR Storage Ring Parameters [R3] |

---

## Appendix C — Symbol and Notation Conventions

### C.1 Cavity and Beam Parameters

| Symbol | Definition | Unit | First Ref |
|--------|-----------|------|-----------|
| $f_0$ | Cavity resonant frequency | MHz | Eq. 2.1 |
| $f_\text{RF}$ | RF operating frequency ($= h \cdot f_\text{rev}$) | MHz | §1 |
| $f_\text{rev}$ | Revolution frequency | MHz | §1 |
| $\omega_0$ | Angular resonant frequency ($= 2\pi f_0$) | rad/s | Eq. 2.1 |
| $\omega_{1/2}$ | Cavity half-bandwidth ($= \omega_0 / 2Q_L = 2\pi \times 35.5$ kHz) | rad/s | Eq. 2.1a |
| $\Delta f_{1/2}$ | Cavity half-bandwidth (linear frequency) | kHz | Eq. 2.1b |
| $Q_0$ | Unloaded quality factor | — | §2.1.1 |
| $Q_L$ | Loaded quality factor | — | §2.1.1 |
| $Q_\text{ext}$ | External quality factor (coupling port) | — | §2.1.1 |
| $\beta$ | Coupling coefficient ($= Q_0/Q_\text{ext}$) | — | §2.1.1 |
| $R_s$ | Shunt impedance (circuit convention: $V^2/2P$) | MΩ | §2.1.1 |
| $R_a$ | Shunt impedance (accelerator convention: $V^2/P = 2R_s$) | MΩ | §C.2 |
| $V_\text{gap}$ | Gap voltage per cavity | kV | §2.1.1 |
| $V_\text{RF}$ | Total RF voltage ($= n_\text{cav} \times V_\text{gap}$) | MV | §2.1.3 |
| $I_b$ | DC beam current | A | §2.1.3 |
| $V_{b,\text{res}}$ | Beam-induced voltage at resonance ($= I_b R_s$) | MV | Eq. 2.2 |
| $\phi_s$ | Synchronous phase angle (from voltage crest) | degrees | Eq. 2.4 |
| $\psi$ | Detuning angle | degrees | Eq. 2.5 |
| $\psi_\text{opt}$ | Optimum detuning angle | degrees | Eq. 2.5a |
| $\Delta f$ | Frequency detuning ($= f_0 - f_\text{RF}$) | kHz | Eq. 2.6 |
| $\Delta\omega$ | Angular frequency offset from RF | rad/s | Eq. 2.1 |
| $U_0$ | Energy loss per turn (synchrotron radiation) | MeV | §1 |
| $h$ | Harmonic number ($= f_\text{RF}/f_\text{rev}$) | — | §1 |
| $\alpha_c$ | Momentum compaction factor | — | Eq. 2.4b |
| $\nu_s$ | Synchrotron tune ($= f_s/f_\text{rev}$) | — | Eq. 2.4b |
| $f_s$ | Synchrotron frequency | kHz | Eq. 2.4b |
| $E_0$ | Beam energy | MeV | Eq. 2.4b |
| $n_\text{cav}$ | Number of cavities | — | Eq. 2.7 |

### C.2 Klystron and Drive Parameters

| Symbol | Definition | Unit | First Ref |
|--------|-----------|------|-----------|
| $K_\text{kly}$ | Klystron small-signal voltage gain | — or dB | Eq. 2.8 |
| $\tau_\text{kly}$ | Klystron group delay | ns | Eq. 2.8 |
| $G_\text{kly}(s)$ | Klystron transfer function ($K_\text{kly} e^{-s\tau_\text{kly}}$) | — | Eq. 5.1 |
| $P_\text{sat}$ | Klystron saturation power | MW | Eq. 2.9 |
| $P_\text{in,sat}$ | Klystron input power at saturation | W | Eq. 2.9 |
| $V_k$ | Klystron cathode voltage | kV | §6.6 |
| $P_\text{fwd}$ | Klystron forward power | kW | §6.9 |
| $P_\text{drive}$ | Klystron drive power | W | §6.9 |

### C.3 Loop Transfer Functions and Compensator Parameters

| Symbol | Definition | Unit | First Ref |
|--------|-----------|------|-----------|
| $G_\text{OL}(s)$ | Direct loop open-loop transfer function | — | Eq. 5.1 |
| $G_\text{prop}$, $K_p$ | Proportional gain | — or dB | Eq. 5.1 |
| $G_\text{lead}(s)$ | Lead compensator: $(1 + s/\omega_z)/(1 + s/\omega_p)$ | — | Eq. 5.1 |
| $G_\text{int}(s)$ | PI integrator: $1 + \omega_i/s$ | — | Eq. 5.1 |
| $\omega_z$ | Lead compensator zero frequency | rad/s | §5.2 |
| $\omega_p$ | Lead compensator pole frequency | rad/s | §5.2 |
| $\omega_i$ | Integrator unity-gain frequency ($\approx 2\pi \times 30$ kHz) | rad/s | §5.2 |
| $H_\text{cav}(s)$ | Cavity transfer function | — | Eq. 2.1a |
| $\tau_d$ | Total loop delay | ns | Eq. 2.11 |
| $f_c$ | Crossover frequency (where $|G_\text{OL}| = 1$) | kHz | Eq. 2.11 |
| $T(s)$ | Closed-loop transfer function | — | Eq. 5.2 |
| $Z_\text{eff}$ | Effective impedance with feedback | Ω | Eq. 5.3 |
| $Z_\text{cav}$ | Cavity impedance without feedback | Ω | Eq. 2.1 |
| $L_1(s), L_2(s)$ | Fast and slow loop transfer functions | — | Eq. 5.5 |
| $G_0$ | DC plant gain | — | Eq. 2.12 |

### C.4 Comb Filter and Group Delay Equalization Parameters

| Symbol | Definition | Unit | First Ref |
|--------|-----------|------|-----------|
| $z$ | Z-transform variable ($e^{j\omega T_s}$) | — | Eq. 5.4 |
| $n$ | Samples per revolution ($= f_s/f_\text{rev}$) | — | Eq. 5.4 |
| $G$ | Comb feed-forward gain | — | Eq. 5.4 |
| $K$ | Comb feedback coefficient ($|K| < 1$) | — | Eq. 5.4 |
| $\nu_s$ | Synchrotron tune ($= f_s/f_\text{rev}$) | — | Eq. 5.4 |
| $G_\text{peak}$ | Comb tooth peak gain ($= G/(1-K)$) | — | §6.2 |
| $H_\text{eq}(z)$ | Group delay equalizer (32-tap FIR) | — | Eq. 6.2b |
| $c_k$ | FIR equalizer coefficients ($k = 0\ldots 31$) | — | Eq. 6.2b |
| $G_\text{OL,comb}(z)$ | Comb path open-loop transfer function | — | Eq. 6.2c |
| $n_\text{delay}$ | Hardware transport delay (samples) | — | Eq. 6.2c |
| $Z_\text{eff,D+C}$ | Effective impedance with Direct + Comb | Ω | Eq. 6.2a |

### C.4a LFB Woofer Parameters

| Symbol | Definition | Unit | First Ref |
|--------|-----------|------|-----------|
| $K_\text{woofer}$ | Woofer injection gain | — | Eq. 6.3a |
| $H_\text{FIR}(s)$ | Woofer group delay equalizer (shared with comb) | — | Eq. 6.3a |
| $\tau_\text{woofer}$ | Woofer one-turn injection delay | μs | Eq. 6.3a |
| $\Delta\vec{V}_\text{LFB}(s)$ | LFB correction signal (from TAXI fiber) | V | Eq. 6.3a |
| $\vec{V}_\text{ref,total}$ | Total I/Q reference (static + woofer) | V | Eq. 6.3a |

### C.5 Ripple Loop Parameters

| Symbol | Definition | Unit | First Ref |
|--------|-----------|------|-----------|
| $\hat{A}_k, \hat{B}_k$ | Estimated harmonic coefficients (cosine, sine) | counts | Eq. 6.4a,b |
| $\mu_k$ | Adaptation gain for harmonic $k$ | — | Eq. 6.4a |
| $f_\text{line}$ | AC line frequency (60 Hz) | Hz | Eq. 6.4a |
| $T_s$ | DSP sampling period ($1/23$ kHz) | s | Eq. 6.4a |
| $e[n]$ | Phase error at sample $n$ | rad | Eq. 6.4a |

### C.6 Slow Loop Parameters

| Symbol | Definition | Unit | First Ref |
|--------|-----------|------|-----------|
| $K_\text{HVPS}$ | HVPS loop proportional gain | V/W | Eq. 6.6a |
| $P_\text{deadband}$ | HVPS loop deadband | W | Eq. 6.6a |
| $\varepsilon$ | Tuner detuning angle error | degrees | Eq. 6.7a |
| $\psi_\text{target}$ | Target detuning angle | degrees | Eq. 6.7a |
| $N_\text{step}$ | Tuner steps per correction cycle | steps | Eq. 6.7b |
| $p_0 \ldots p_3$ | Frequency offset polynomial coefficients | kHz, kHz/step, ... | Eq. 6.7c |
| $t_1$ | Voltage-dependent detuning coefficient | kHz/kV² | Eq. 6.7c |
| $x, x_\text{home}$ | Tuner position, home position | steps | Eq. 6.7c |
| $K_\text{DAC}$ | DAC loop proportional gain (0–1) | — | Eq. 6.8a |
| $D_\text{conv}$ | DAC conversion factor | counts/kV | Eq. 6.8a |
| $G_\text{loop}$ | Direct loop gain correction factor | — | Eq. 6.8a |
| $G_\text{modulator}$ | Baseband modulator gain (adjustable) | — | Eq. 6.9a |
| $G_\text{loop,target}$ | Target constant loop gain | — | Eq. 6.9a |

### C.7 Calibration Parameters

| Symbol | Definition | Unit | First Ref |
|--------|-----------|------|-----------|
| $D_\text{conv}$ | Drive conversion constant (counts/kV) | counts/kV | Eq. 9.1 |
| $A_\text{ref}$ | Reference DAC amplitude | counts | Eq. 9.1 |
| $L_\text{det}$ | RF detector conversion loss | dB | Eq. 9.2 |
| $E_\text{conv}$ | Power conversion constant (0.31623) | — | Eq. 9.2 |
| $P_\text{cal}$ | Calibration power | mW | Eq. 9.2 |
| $\beta_\text{meas}$ | Measured coupling factor (VSWR-based) | — | Eq. 9.3 |
| $r$ | Reflection coefficient magnitude | — | Eq. 9.3 |

### C.8 I/Q Signal Processing

| Symbol | Definition | Unit | First Ref |
|--------|-----------|------|-----------|
| $I(t), Q(t)$ | In-phase, quadrature baseband components | V | Eq. 3.0 |
| $A(t)$ | Amplitude $[= \sqrt{I^2 + Q^2}]$ | V | Eq. 3.0a |
| $\phi(t)$ | Phase $[= \text{atan2}(Q, I)]$ | rad | Eq. 3.0a |
| $G$ (in Eq. 3.1) | Baseband modulator gain | — | Eq. 3.1 |
| $\theta$ | Baseband modulator rotation angle | rad | Eq. 3.1 |
| $\vec{E}$ | Error vector $[= \vec{V}_\text{ref} - \vec{V}_\text{probe}]$ | V | Eq. 3.2 |

### C.9 Conventions

1. **Shunt impedance**: $R_s = V^2/(2P)$ throughout (circuit convention). Accelerator convention $R_a = 2R_s$.
2. **Synchronous phase**: $\phi_s$ measured from voltage crest (SLAC convention): $V_\text{RF}\cos\phi_s = U_0$.
3. **Detuning**: $\Delta f = f_0 - f_\text{RF}$. Negative = cavity below RF (normal above transition).
4. **Laplace variable**: $s = \sigma + j\omega$; for frequency response analysis, $s = j\omega$.
5. **Bold symbols**: Vectors (e.g., $\vec{V}_\text{ref}$, $\vec{E}$).
6. **Hat notation**: Estimated quantities (e.g., $\hat{A}_k$).
7. **Reference tags**: [Rn] = numbered reference, [Rnt] = transcription, [Wn] = web, [Dn] = disturbance (§4).
8. **Equation numbering**: (Eq. M.N) where M = section number, N = sequence within section. Lettered variants (a, b, c) denote closely related sub-equations.

---

*End of Document*

**Document Control**:
- Tier 1 RF physics reference for the SPEAR3 LLRF system.
- Definitive version: `Designs/P_RF_PHYSICS_AND_PLANT.md`
