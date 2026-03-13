# SPEAR3 Legacy LLRF Control System — Technical Design Report

**Document Number**: LLRF-DES-006  
**Version**: 1.0  
**Date**: 2026-03-13  
**Classification**: Engineering Technical Reference  
**Derived From**: Deep code review of `llrf/legacyLLRF/` source files  
**Original Facility**: PEP-II B-Factory → SPEAR3 Storage Ring (SSRL/SLAC)  
**Original Authors**: S. Allison, R.C. Sass, M. Zelazny, P. Corredoura, R. Claus, M. Laznovsky (1996–2005)  

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [RF Cavity Physics and Mathematical Models](#3-rf-cavity-physics-and-mathematical-models)
4. [IQ Signal Processing and Vector Representation](#4-iq-signal-processing-and-vector-representation)
5. [Master State Machine — rf_states](#5-master-state-machine--rf_states)
6. [DAC Loop — Drive Power and Gap Voltage Control](#6-dac-loop--drive-power-and-gap-voltage-control)
7. [HVPS Loop — Klystron High Voltage Control](#7-hvps-loop--klystron-high-voltage-control)
8. [Tuner Loop — Cavity Mechanical Tuning](#8-tuner-loop--cavity-mechanical-tuning)
9. [Direct Loop — Analog Cavity Field Feedback](#9-direct-loop--analog-cavity-field-feedback)
10. [Comb Loop — Narrowband Revolution Harmonic Feedback](#10-comb-loop--narrowband-revolution-harmonic-feedback)
11. [Calibration System — Octal DAC Nulling](#11-calibration-system--octal-dac-nulling)
12. [Message Logging and TAXI Error Recovery](#12-message-logging-and-taxi-error-recovery)
13. [Fault Management and Automatic Recovery](#13-fault-management-and-automatic-recovery)
14. [EPICS Process Variable Architecture](#14-epics-process-variable-architecture)
15. [Performance Characteristics and Stability Analysis](#15-performance-characteristics-and-stability-analysis)
16. [Appendix A — State Transition Tables](#appendix-a--state-transition-tables)
17. [Appendix B — Complete PV Reference](#appendix-b--complete-pv-reference)
18. [Appendix C — Source File Index](#appendix-c--source-file-index)

---

## 1. Executive Summary

This document provides a comprehensive technical design analysis of the legacy Low-Level RF (LLRF) control system deployed on the SPEAR3 storage ring at the Stanford Synchrotron Radiation Lightsource (SSRL). The system was originally designed for the PEP-II asymmetric B-Factory (1996–1997) and subsequently adapted for SPEAR3, where it has been in continuous operation for over 25 years.

The LLRF control system is implemented as a set of six concurrent EPICS State Notation Language (SNL) programs executing on a VxWorks real-time operating system. These programs collectively manage:

- **Station state sequencing** — orderly transitions between OFF, PARK, TUNE, ON_FM, and ON_CW operating modes
- **Drive power / gap voltage regulation** — closed-loop control of RF processor DAC setpoints
- **HVPS voltage control** — klystron beam voltage regulation for cavity power management
- **Cavity tuner positioning** — mechanical resonance frequency adjustment via stepper motors
- **Octal DAC calibration** — automated offset nulling and IQ matrix calibration
- **Diagnostic logging** — fault recording, message logging, and TAXI error recovery

The RF system operates at **476 MHz** with a single high-power klystron driving one or more superconducting RF cavities. The control system maintains the cavity accelerating voltage at the required setpoint while managing beam loading, detuning, and hardware protection.

**Key Control Parameters:**

| Parameter | Symbol | Typical Value | Control Loop |
|-----------|--------|---------------|--------------|
| RF Frequency | f_RF | 476.000 MHz | Fixed reference |
| DAC Resolution | — | 12-bit (±2048 counts) | DAC Loop |
| DAC Loop Period | T_DAC | ~0.5 s | DAC Loop |
| HVPS Loop Period | T_HVPS | ~0.5 s | HVPS Loop |
| Maximum Loop Idle | T_max | 10.0 s | All supervisory loops |
| HVPS Voltage Tolerance Count | N_tol | 10 cycles | HVPS Loop |
| Tuner Motor Deadband | RDBD | Configurable (mm) | Tuner Loop |
| Minimum DAC Delta | Δ_min | 0.5 counts | DAC Loop |
| Maximum DAC Counts | DAC_max | 2047 | DAC Loop |

---

## 2. System Architecture Overview

### 2.1 Software Architecture

The legacy LLRF control system consists of **6 SNL programs** compiled into a single VxWorks shared library (`rfSeq`) and registered via the EPICS database definition file `rfSeq.dbd`:

```
rfSeq Library
├── rf_states.st      — Master station state machine (3 state sets)
├── rf_dac_loop.st    — DAC/drive power/gap voltage control loop
├── rf_hvps_loop.st   — High voltage power supply regulation loop
├── rf_tuner_loop.st  — Cavity tuner stepper motor control
├── rf_calib.st       — Automated calibration sequences
└── rf_msgs.st        — Message logging and TAXI error recovery
```

Each program is parameterized via EPICS macros:
- `STN` — Station identifier (e.g., `RFCA` for SPEAR3 Cavity A)
- `CAV` — Cavity identifier (used by tuner loop for per-cavity instances)
- `name` — Task name for logging

### 2.2 Hardware Module Hierarchy

The software interfaces with several VXI-based hardware modules through EPICS Channel Access:

```
RF Station Hardware Architecture
│
├── RFP (RF Processor Module)
│   ├── Octal DACs (I/Q setpoints for tune, operate, GFF modes)
│   ├── Direct loop analog feedback
│   ├── Comb loop digital filtering
│   ├── Lead compensation
│   ├── Integral compensation
│   ├── Ripple loop
│   ├── Run mode control (TUNE / OPERATE)
│   └── RF switch (enable/disable)
│
├── GVF (Gap Voltage Feedback Module)
│   ├── Gap voltage feed-forward reference (I/Q)
│   ├── LFB (Low-Frequency Beam feedback) woofer
│   ├── GFF (Gap Feed-Forward) loop
│   └── TAXI error monitoring
│
├── IQA (I/Q Acquisition Modules × 2–3)
│   ├── Klystron drive I/Q measurement
│   └── Cavity probe I/Q measurement
│
├── AIM (Accelerator Interface Module)
│   ├── Beam abort force/reset
│   ├── Filament control
│   ├── HVPS permissive
│   └── Fault history buffers
│
├── CLK (Clock Module)
│   └── Resynchronization
│
├── CFM/CF2 (Comb Filter Modules)
│   ├── Narrowband filtering at revolution harmonics
│   └── History buffers
│
└── HVPS (High Voltage Power Supply — external)
    ├── Voltage setpoint/readback
    ├── SCR trigger control
    └── Contactor control
```

### 2.3 Control Loop Hierarchy and Timescales

The control system implements a hierarchical multi-rate control architecture:

```
Fastest ──► Analog Loops (RFP hardware, ~μs bandwidth)
            ├── Direct loop (cavity field stabilization)
            ├── Comb loop (revolution harmonic suppression)
            ├── Lead compensation
            └── Integral compensation

Medium  ──► Digital Supervisory Loops (~0.5–1s period)
            ├── DAC loop (setpoint adjustment)
            ├── HVPS loop (voltage regulation)
            └── Ripple loop (AC line ripple cancellation)

Slowest ──► Mechanical Loops (~seconds)
            └── Tuner loop (stepper motor positioning)

State   ──► Event-driven State Machine (asynchronous)
            ├── Station state sequencing
            ├── Fault management
            └── Calibration
```

The mathematical relationship between loop bandwidths follows the stability requirement:

$$f_{BW,\text{direct}} \gg f_{BW,\text{DAC}} \gg f_{BW,\text{tuner}}$$

where the separation must be at least one decade to avoid inter-loop coupling instabilities.

---

## 3. RF Cavity Physics and Mathematical Models

### 3.1 Cavity Equivalent Circuit

A superconducting RF cavity can be modeled as a parallel RLC resonator. The impedance of the loaded cavity at the RF driving frequency ω is:

$$Z_{\text{cav}}(\omega) = \frac{R_s}{1 + j Q_L \left(\frac{\omega}{\omega_0} - \frac{\omega_0}{\omega}\right)}$$

where:
- **R_s** = shunt impedance (typically 1–5 MΩ for a SPEAR3 cavity)
- **Q_L** = loaded quality factor (including external coupling and beam loading)
- **ω₀** = 2π × 476 MHz = angular resonant frequency

For small detuning Δω = ω - ω₀ ≪ ω₀, this simplifies to:

$$Z_{\text{cav}}(\omega) \approx \frac{R_s}{1 + j 2 Q_L \frac{\Delta\omega}{\omega_0}}$$

### 3.2 Cavity Voltage Dynamics

The cavity accelerating voltage V_cav in the time domain obeys the first-order differential equation:

$$\frac{d \tilde{V}_{\text{cav}}}{dt} + \left(\frac{\omega_0}{2 Q_L} + j \Delta\omega\right) \tilde{V}_{\text{cav}} = \frac{\omega_0 R_s}{2 Q_L} \left(\tilde{I}_g - \tilde{I}_b\right)$$

where:
- **Ṽ_cav** = complex cavity voltage envelope (I + jQ representation)
- **Ĩ_g** = generator current (proportional to klystron forward power)
- **Ĩ_b** = beam-induced current
- **Δω** = cavity detuning from the RF driving frequency

The cavity time constant (half-bandwidth) is:

$$\tau_{\text{cav}} = \frac{2 Q_L}{\omega_0}$$

For a typical SPEAR3 cavity with Q_L ~ 10,000 at 476 MHz:

$$\tau_{\text{cav}} = \frac{2 \times 10{,}000}{2\pi \times 476 \times 10^6} \approx 6.7 \, \mu\text{s}$$

### 3.3 Beam Loading

The beam current generates a voltage component in the cavity. For a stored beam with DC current I_b and a Gaussian bunch distribution, the fundamental component of beam loading at the RF frequency is:

$$\tilde{I}_{b,\text{RF}} = 2 I_b \, F_b \, e^{j\phi_s}$$

where:
- **F_b** = beam form factor (bunch shape dependent, typically ≈ 1 for short bunches)
- **φ_s** = synchronous phase angle

The beam loading voltage is:

$$V_b = \tilde{I}_{b,\text{RF}} \cdot Z_{\text{cav}}(\omega_{\text{RF}})$$

### 3.4 Klystron Transfer Function

The klystron converts the HVPS beam voltage V_HVPS into RF power. The saturated klystron output power follows:

$$P_{\text{kly}} = \eta_{\text{kly}} \cdot P_{\text{beam}} = \eta_{\text{kly}} \cdot V_{\text{HVPS}} \cdot I_{\text{kly}}$$

where η_kly is the klystron efficiency (~40–60%). In the linear regime (below saturation), the klystron forward output power is approximately:

$$P_{\text{fwd}} \propto G_{\text{kly}} \cdot P_{\text{drive}}$$

where G_kly is the klystron gain and P_drive is the drive power set by the RFP module's DAC values. The drive power relates to the I/Q DAC setpoints as:

$$P_{\text{drive}} = k_{\text{DAC}} \left(I_{\text{DAC}}^2 + Q_{\text{DAC}}^2\right)$$

### 3.5 Detuning and Load Angle

The cavity detuning Δf = f₀ - f_RF causes a reactive impedance component. The load angle ψ is defined as:

$$\tan(\psi) = -2 Q_L \frac{\Delta f}{f_0}$$

The tuner loop controls the mechanical tuner to minimize |ψ|, which minimizes reflected power and maintains the optimal coupling condition. The relationship between tuner position x and detuning is approximately linear for small displacements:

$$\Delta f(x) = K_{\text{tuner}} \cdot (x - x_0)$$

where K_tuner is the tuning sensitivity in Hz/mm.

---

## 4. IQ Signal Processing and Vector Representation

### 4.1 Complex Baseband Representation

All RF signals in the LLRF system are represented in In-phase/Quadrature (I/Q) format. An RF signal at frequency ω_RF:

$$v(t) = A(t) \cos\left(\omega_{\text{RF}} t + \phi(t)\right)$$

is decomposed into I and Q components:

$$I(t) = A(t) \cos(\phi(t))$$
$$Q(t) = A(t) \sin(\phi(t))$$

such that the complex baseband signal is:

$$\tilde{v}(t) = I(t) + j \, Q(t) = A(t) \, e^{j\phi(t)}$$

### 4.2 Amplitude and Phase Extraction

The amplitude and phase are recovered as:

$$A(t) = |\tilde{v}(t)| = \sqrt{I^2(t) + Q^2(t)}$$

$$\phi(t) = \arg\left(\tilde{v}(t)\right) = \arctan\left(\frac{Q(t)}{I(t)}\right)$$

### 4.3 IQ Combining Matrix

The RFP module uses a 2×2 matrix to combine individual cavity probe signals into a station-level signal. For cavity k, the combining matrix is:

$$\begin{pmatrix} I_{\text{out},k} \\ Q_{\text{out},k} \end{pmatrix} = \begin{pmatrix} c_{II,k} & c_{IQ,k} \\ c_{QI,k} & c_{QQ,k} \end{pmatrix} \begin{pmatrix} I_{\text{in},k} \\ Q_{\text{in},k} \end{pmatrix} + \begin{pmatrix} o_{II,k} \\ o_{QQ,k} \end{pmatrix}$$

where:
- **c_{II,k}, c_{IQ,k}, c_{QI,k}, c_{QQ,k}** — combining coefficients (PVs: `{STN}:STN:RFP:CAVk.A/C/E/G`)
- **o_{II,k}, o_{QQ,k}** — offset corrections (PVs: `{STN}:STN:RFP:CAVk.B/D/F/H`)

The station-level gap voltage vector is the sum over all N_cav cavities:

$$\tilde{V}_{\text{gap}} = \sum_{k=1}^{N_{\text{cav}}} \tilde{V}_{\text{out},k} = \sum_{k=1}^{N_{\text{cav}}} \left(I_{\text{out},k} + j \, Q_{\text{out},k}\right)$$

### 4.4 Vector Rotation and Phase Alignment

Phase rotation by angle θ in the IQ plane is accomplished by the matrix multiplication:

$$\begin{pmatrix} I' \\ Q' \end{pmatrix} = \begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{pmatrix} \begin{pmatrix} I \\ Q \end{pmatrix}$$

The combining matrix coefficients can encode both rotation and scaling:

$$\begin{pmatrix} c_{II} & c_{IQ} \\ c_{QI} & c_{QQ} \end{pmatrix} = G \begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{pmatrix}$$

where G is the gain factor and θ is the alignment phase.

### 4.5 DAC Setpoint to RF Vector Mapping

The RFP module converts the I/Q DAC count values into an RF drive signal. The relationship between DAC counts and the drive vector is:

$$\tilde{V}_{\text{drive}} = k_I \cdot N_I + j \cdot k_Q \cdot N_Q$$

where N_I, N_Q are the integer DAC counts (range: 0 to 2047) and k_I, k_Q are the DAC-to-voltage conversion factors. The drive power is proportional to:

$$P_{\text{drive}} \propto |\tilde{V}_{\text{drive}}|^2 = k_I^2 N_I^2 + k_Q^2 N_Q^2$$

The DAC loop adjusts the amplitude A (in counts) of this vector while the phase φ is set separately:

$$N_I = A \cos(\phi_{\text{calc}})$$
$$N_Q = A \sin(\phi_{\text{calc}})$$

where φ_calc is the calculated phase from the `{STN}:STN:PHASE:CALC` PV.

---

## 5. Master State Machine — rf_states

### 5.1 Overview

The master state machine (`rf_states.st`, authored by R.C. Sass, 1997) manages the overall RF station operating state. It implements **three concurrent state sets**:

1. **rf_states** — primary station state transitions
2. **rf_statesLP** — loop transition sequencing (direct, comb, lead, integral compensation)
3. **rf_statesFF** — fault file data collection

### 5.2 Station State Definitions

The station operates in one of five discrete states:

| State | Enum Value | Description |
|-------|-----------|-------------|
| `STATION_OFF` | 0 | Station powered down, all loops disabled |
| `STATION_PARK` | 1 | Tuners at park position, DACs off, minimal activity |
| `STATION_TUNE` | 2 | RF on in tune mode, HVPS active, drive power regulation |
| `STATION_ON_FM` | 3 | Frequency modulation mode for conditioning |
| `STATION_ON_CW` | 4 | Continuous-wave operation, full feedback enabled |

### 5.3 Legal State Transition Matrix

The state machine enforces a strict transition matrix:

```
From \ To    OFF    PARK    TUNE    ON_FM    ON_CW
  OFF         —      ✓       ✓       ✓        ✓
  PARK        ✓      —       ✗       ✗        ✗
  TUNE        ✓      ✗       —       ✗        ✓
  ON_FM       ✓      ✗       ✓       —        ✗
  ON_CW       ✓      ✗       ✓       ✗        —
```

Key design decisions:
- PARK can only return to OFF (safety constraint)
- ON_FM cannot directly transition to ON_CW (must go through TUNE)
- ON_CW to TUNE is the standard operational path for reducing power

### 5.4 Transition Sequencing Mathematics

#### 5.4.1 OFF → TUNE Sequence

1. Resynchronize clock module
2. Force beam abort: `fba = 1`
3. Set I/Q tune reference to initial values
4. Set run mode to TUNE
5. Execute HVPS turn-on subsequence (HVPSONSUB):
   - Enable RF switch
   - Set HVPS voltage to minimum default: `V_HVPS = V_{HVPS,min}`
   - Home cavity tuners
   - Wait TUNERWAIT (60 ticks ≈ 1 second)
   - Enable HVPS triggers and AIM HVPS permissive
   - Wait for HVPS to stabilize (~10 seconds with polling)

#### 5.4.2 TUNE → ON_CW Sequence (Normal Path)

1. Disable DACs
2. Reset and load DAC waveforms (DACRLSUB)
3. Set DAC state to RUN
4. Initialize I/Q reference amplitude (SETIQSUB with mode 1)
5. Initialize ripple loop DC coefficient
6. Set run mode to OPERATE
7. Zero tune I/Q setpoints
8. Transition to ON_CW state
9. Trigger direct loop sequencing via event flag

#### 5.4.3 OFF → ON_CW Fast Turnon Sequence

When the direct loop control and fast turnon are both enabled, the system bypasses the TUNE state:

1. Home cavity tuners, reset comb filters
2. Preload gap I/Q reference (SETIQSUB mode 3 — "fast on" initial values)
3. Wait 3 seconds for sequence completion
4. Enable direct loop immediately: `pvPut(directlpon)`
5. Enable integral/lead compensation if configured
6. Enable comb loop if configured
7. Set run mode to OPERATE, enable RF switch
8. Set HVPS to fast turnon voltage: `V_HVPS = V_{HVPS,faston}`
9. Enable HVPS triggers
10. Enable GFF and LFB woofer loops
11. Reset beam abort

### 5.5 Direct Loop Gain Ramping Algorithm

When the direct loop is turned on, the gain is ramped up from a negative offset to avoid transients:

```
Initial: gain_offset = directlpgainoff  (negative value, e.g., -20 dB)

Loop:
  while gain_offset < 0:
    gain_offset += gain_delta       // gain_delta ≥ 1.0 (enforced minimum)
    if gain_offset > -0.1:
      gain_offset = 0.0             // Snap to final value
    write gain_offset to hardware
    wait(ramp_settle_time)
```

Mathematically, after n ramp steps:

$$G_{\text{offset}}(n) = \min\left(0, \, G_{\text{offset}}(0) + n \cdot \Delta G\right)$$

where G_offset(0) < 0 is the initial offset and ΔG ≥ 1.0 dB is the ramp step size.

The effective loop gain during ramping is:

$$G_{\text{eff}}(n) = G_{\text{nominal}} \cdot 10^{G_{\text{offset}}(n)/20}$$

### 5.6 Comb Loop Gain Ramping

An identical algorithm is applied to the comb loop:

$$G_{\text{comb,offset}}(n) = \min\left(0, \, G_{\text{comb,offset}}(0) + n \cdot \Delta G_{\text{comb}}\right)$$

The sequencing order is: direct loop → lead compensation → integral compensation → comb loop → GFF → LFB woofer.

---

## 6. DAC Loop — Drive Power and Gap Voltage Control

### 6.1 Overview

The DAC loop (`rf_dac_loop.st`, authored by S. Allison, 1997) implements a discrete-time integral controller that adjusts the RFP octal DAC amplitude setpoints to regulate either drive power or gap voltage.

### 6.2 Control Law — Discrete Integral Controller

The DAC loop implements a pure integral controller in the discrete time domain. At each update cycle k:

$$N(k) = N(k-1) + \Delta N(k)$$

where:
- **N(k)** = DAC count value at cycle k (float, range [0, 2047])
- **ΔN(k)** = delta counts computed by the EPICS subroutine record based on the control error

The delta ΔN(k) is computed externally (in the EPICS database) from the error signal:

$$\Delta N(k) = K_i \cdot e(k)$$

where K_i is the integral gain and e(k) is the measured error at cycle k. The error depends on the operating mode:

**TUNE mode** (drive power control):
$$e_{\text{tune}}(k) = P_{\text{drive,setpoint}} - P_{\text{drive,measured}}$$

**ON_CW mode, direct loop OFF** (drive power control via GFF):
$$e_{\text{on}}(k) = P_{\text{drive,setpoint}} - P_{\text{drive,measured}}$$

**ON_CW mode, direct loop ON** (gap voltage control):
$$e_{\text{gapv}}(k) = V_{\text{gap,setpoint}} - V_{\text{gap,measured}}$$

### 6.3 DAC Saturation and Clamping

The DAC output is clamped to the hardware limits:

$$N(k) = \begin{cases}
0 & \text{if } N(k-1) + \Delta N(k) < 0 \\
2047 & \text{if } N(k-1) + \Delta N(k) > 2047 \\
N(k-1) + \Delta N(k) & \text{otherwise}
\end{cases}$$

When saturation occurs, the delta is adjusted for anti-windup:

$$\Delta N_{\text{eff}}(k) = N(k) - N(k-1)$$

This is implemented in the `DAC_LOOP_SET` macro (from `rf_dac_loop_macs.h`).

### 6.4 Minimum Delta Threshold (Dead Zone)

To prevent hunting oscillations, the controller only updates when the delta exceeds a minimum threshold:

$$|\Delta N(k)| > \Delta N_{\text{min}} = 0.5 \text{ counts}$$

If the delta is below this threshold AND neither the phase has changed nor the control mode has changed, no update is written to hardware.

### 6.5 Control Path Selection Logic

The DAC loop selects the appropriate control path based on three conditions:

```
if (direct_loop == OFF):
    if (GVF module available):
        Control GFF counts for drive power
        Target PV: {STN}:STN:GFF:IQ.A
        Delta PV:  {STN}:KLYSDRIVFRWD:GFF:DELTA
    else:
        Control RFP ON counts for drive power
        Target PV: {STN}:STN:ON:IQ.A
        Delta PV:  {STN}:KLYSDRIVFRWD:ODAC:DELTA

else (direct_loop == ON):
    if (GVF module available):
        Control GFF counts for gap voltage
        Target PV: {STN}:STN:GFF:IQ.A
        Delta PV:  {STN}:STNVOLT:GFF:DELTA
    else:
        Control RFP ON counts for gap voltage
        Target PV: {STN}:STN:ON:IQ.A
        Delta PV:  {STN}:STNVOLT:DAC:DELTA
```

### 6.6 Drive Power Limiting Protection

When the drive power is already high and the gap voltage needs to increase, the controller prevents further increase to protect the klystron:

$$\text{if } \left(\text{LOLO}(P_{\text{gap,error}}) \text{ OR } \text{INVALID}(P_{\text{drive}}) \right) \text{ AND } \Delta N > \Delta N_{\text{min}}:$$
$$\quad \text{status} \leftarrow \text{DRIV\_HIGH (no gap voltage increase)}$$

### 6.7 Transfer Function Analysis

The DAC loop, combined with the cavity plant dynamics, forms a Type-1 servo. The open-loop discrete-time transfer function is:

$$G_{\text{OL}}(z) = K_i \cdot \frac{z}{z - 1} \cdot G_{\text{plant}}(z)$$

where G_plant(z) is the Z-transform of the plant (RFP module + klystron + cavity), and the z/(z-1) factor represents the discrete integrator.

The closed-loop transfer function is:

$$G_{\text{CL}}(z) = \frac{G_{\text{OL}}(z)}{1 + G_{\text{OL}}(z)}$$

For stability, the Nyquist criterion requires that the phase margin at the unity-gain crossover frequency exceeds ~45°. Given the slow update rate (~0.5s) compared to the cavity bandwidth (~150 kHz), the plant appears essentially static to this loop, and stability is guaranteed for moderate gains K_i.

### 6.8 Ripple Loop Integration

The ripple loop operates at a slower rate and provides AC line frequency (60 Hz) rejection. Its amplitude setpoint is loaded via:

$$A_{\text{ripple}} \leftarrow \text{pvPut(ripple\_loop\_load)}$$

This is only updated when the ripple loop ready flag is set and the amplitude has changed, preventing unnecessary hardware writes.

---

## 7. HVPS Loop — Klystron High Voltage Control

### 7.1 Overview

The HVPS loop (`rf_hvps_loop.st`, authored by M. Zelazny, 1997) controls the klystron beam voltage to regulate either cavity gap voltage (in TUNE mode) or klystron drive power (in ON_CW with direct loop). It operates in three modes: OFF, PROCESS (conditioning), and ON.

### 7.2 PROCESS Mode — Cavity Conditioning

In PROCESS mode, the loop slowly increases the HVPS voltage while monitoring cavity health:

$$V_{\text{HVPS}}(k+1) = \begin{cases}
V_{\text{HVPS}}(k) + \Delta V_{\text{down}} & \text{if any condition requires decrease} \\
V_{\text{HVPS}}(k) + \Delta V_{\text{up}} & \text{if all conditions are satisfied}
\end{cases}$$

**Decrease conditions** (any one triggers):
- Klystron forward power > maximum setpoint: P_fwd > P_fwd,max
- Cavity gap voltage exceeds limit (MAJOR severity)
- Cavity vacuum exceeds limit (MAJOR severity)

**Increase condition**: All of the above are within limits.

The voltage step sizes Δ V_down and Δ V_up are independently configurable via PVs:
- `{STN}:HVPS:LOOP:VOLTDOWN` — negative step for decreasing
- `{STN}:HVPS:LOOP:VOLTUP` — positive step for increasing

### 7.3 ON Mode — Operational Regulation

In ON mode, the HVPS loop maintains steady-state operating conditions. The control action depends on the station state and direct loop:

**Case 1: ON_CW with direct loop ON** (drive power control):

$$\Delta V_{\text{HVPS}}(k) = -\Delta V_{\text{on}}(k)$$

The negative sign compensates for the inverse relationship: increasing HVPS voltage increases klystron gain, which (with the direct loop maintaining cavity voltage) reduces required drive power.

The delta is computed externally and read from: `{STN}:KLYSDRIVFRWD:HVPS:DELTA`

**Case 2: TUNE or ON_CW with direct loop OFF** (gap voltage control):

$$\Delta V_{\text{HVPS}}(k) = \Delta V_{\text{tune}}(k)$$

Read from: `{STN}:STNVOLT:HVPS:DELTA`

### 7.4 Voltage Clamping and Safety

The HVPS voltage is constrained to the operational range:

$$V_{\text{HVPS,min}} \leq V_{\text{HVPS}}(k) \leq V_{\text{HVPS,max}}$$

Implementation:
```
if V_requested > V_max:
    status = VOLT_LIM
    if delta > 0: V_requested = V_max    // Only clamp upward changes
elif V_requested < V_min AND delta <= 0:
    V_requested = V_min
```

### 7.5 Readback Tolerance Protection

To prevent the control loop from diverging when the HVPS actual voltage does not track the setpoint, a tolerance check is implemented:

$$\text{if } |V_{\text{readback}} - V_{\text{requested,prev}}| > \Delta V_{\text{allowed}}:$$
$$\quad V_{\text{requested}} \leftarrow V_{\text{requested,prev}} \quad \text{(hold previous value)}$$
$$\quad N_{\text{tol}} \leftarrow N_{\text{tol}} + 1$$

After N_tol exceeds 10 consecutive violations, the status changes to VOLT_TOL. The counter resets when the readback comes within tolerance.

### 7.6 Cavity Voltage Limiting in ON Mode

When increasing HVPS voltage would cause any cavity voltage to exceed its maximum limit:

$$\text{if MAJOR\_SEVERITY}(V_{\text{gap,check}}) \text{ AND } \Delta V > 0:$$
$$\quad \text{cavv\_lim\_count} \leftarrow \text{cavv\_lim\_count} + 1$$
$$\quad \text{if cavv\_lim\_count} > 10: \text{status} \leftarrow \text{CAVV\_LIM}$$

### 7.7 Transfer Function

The HVPS control loop forms a discrete-time control system:

$$V_{\text{HVPS}}(z) = V_{\text{HVPS,prev}}(z) + \Delta V(z) \cdot H_{\text{limit}}(z)$$

where H_limit(z) represents the clamping and tolerance checking nonlinearities. In the linear operating region, this is effectively another Type-1 (integral) controller with the plant being the HVPS power supply + klystron + cavity chain.

---

## 8. Tuner Loop — Cavity Mechanical Tuning

### 8.1 Overview

The tuner loop (`rf_tuner_loop.st`, authored by S. Allison, 1996) controls the mechanical cavity tuner via a stepper motor to keep the cavity resonant frequency aligned with the RF drive frequency. One instance runs per cavity (reentrant, `option +r`).

### 8.2 Control Law

The tuner loop implements a proportional position control that commands the stepper motor to a new position based on the measured load angle error:

$$x_{\text{new}} = x_{\text{SM}} + \Delta x$$

where:
- **x_SM** = current stepper motor position (readback from motor encoder)
- **Δx** = position delta computed from the load angle measurement

The delta Δx is computed externally by the EPICS database using the load angle error:

$$\Delta x = K_{\text{tuner}} \cdot \epsilon_{\psi}$$

where:
- **K_tuner** = tuner loop gain (position change per unit load angle error)
- **ε_ψ** = load angle error = ψ_setpoint - ψ_measured

### 8.3 Position Clamping

The commanded position is clamped to the motor drive limits:

$$x_{\text{cmd}} = \begin{cases}
x_{\text{DRVH}} & \text{if } x_{\text{new}} > x_{\text{DRVH}} \\
x_{\text{DRVL}} & \text{if } x_{\text{new}} < x_{\text{DRVL}} \\
x_{\text{new}} & \text{otherwise}
\end{cases}$$

where DRVH and DRVL are the high and low drive limits of the stepper motor record.

### 8.4 Motion Verification

The loop verifies that the stepper motor executes the commanded move by checking two conditions:

**Done-moving check (DMOV)**:
- The stepper motor's DMOV field must return to 1 (done moving)
- Up to LOOP_MOVE_COUNT (100) × LOOP_MOVE_DELAY (10 ticks) = ~16.7 seconds timeout

**Position verification**:
- The actual position must match the command within the retry deadband:
  $$|x_{\text{ctrl}} - x_{\text{SM}}| \leq \text{RDBD}$$
- If this fails, status is set to LOOP_SM_CTRL_STATUS and the previous control flag is cleared

**Stuck detection**:
- If the motor has not finished moving after LOOP_NOMOV_COUNT (5) consecutive cycles, status changes to LOOP_SM_MOVE_STATUS

### 8.5 Measurement Gating

Updates are only applied when valid measurements are available:

1. **meas_ready event**: Triggered by the external measurement system at each measurement cycle
2. **dmov_meas_count**: Counts valid measurements taken after the motor has stopped moving
3. A minimum of LOOP_DMOV_MEAS (1) valid post-move measurement is required before the next move command

This ensures the load angle measurement reflects the actual tuner position, not a transient during motor motion.

### 8.6 Power Threshold

The tuner loop requires minimum klystron forward power to function:

$$\text{if } P_{\text{kly,fwd}} < P_{\text{kly,fwd,min}} \text{ OR INVALID}(P_{\text{kly,fwd}}):$$
$$\quad \text{status} \leftarrow \text{POWR\_LOW\_STATUS}$$

This prevents the tuner from acting on noise when the klystron is not producing meaningful RF power.

### 8.7 Reset (Homing) Procedure

The reset procedure moves the tuner to a predefined home position using an iterative correction algorithm:

```
for attempt = 0 to LOOP_RESET_COUNT-1:
    if attempt > 0: wait(LOOP_RESET_DELAY ticks)
    
    if (SM done moving) AND (valid position readings):
        delta = home_position - current_position
        
        if |delta| < LOOP_RESET_TOLS × position_MDEL:
            break  // Close enough to home
        
        command = SM_position + delta
        write command to stepper motor
        wait for motor to finish moving
```

The tolerance for homing is:

$$\text{tolerance} = \text{LOOP\_RESET\_TOLS} \times \text{MDEL} = 2 \times \text{MDEL}$$

where MDEL is the monitor deadband of the position PV (minimum detectable position change).

### 8.8 Load Angle Phase Offset Processing

After each valid tuner update (except in PARK mode), the load angle phase offset is recalculated:

$$\phi_{\text{offset}} = \phi_{\text{unadj}} - \phi_{\text{ref}}$$

This is triggered by processing the `{STN}:CAV{CAV}LOAD:ANGLE:UNADOFFS.PROC` record.

---

## 9. Direct Loop — Analog Cavity Field Feedback

### 9.1 Architecture

The direct loop is an analog feedback loop implemented in the RFP (RF Processor) hardware module. It operates at RF/IF speeds (~μs response) and provides the primary cavity field stabilization. The SNL software controls its on/off state and gain ramping, but does not participate in the real-time feedback.

### 9.2 Mathematical Description

The direct loop implements a proportional feedback around the cavity:

$$\tilde{V}_{\text{drive}}(t) = \tilde{V}_{\text{setpoint}} + G_{\text{direct}} \cdot \left(\tilde{V}_{\text{gap,setpoint}} - \tilde{V}_{\text{gap,measured}}\right)$$

In the Laplace domain, the cavity with direct loop feedback has the transfer function:

$$\frac{\tilde{V}_{\text{cav}}(s)}{\tilde{V}_{\text{setpoint}}(s)} = \frac{G_{\text{cav}}(s) \cdot G_{\text{kly}}}{1 + G_{\text{direct}} \cdot G_{\text{cav}}(s) \cdot G_{\text{kly}}}$$

where:
$$G_{\text{cav}}(s) = \frac{1}{1 + s \tau_{\text{cav}}}$$

The closed-loop bandwidth increases with direct loop gain:

$$f_{\text{BW,CL}} = f_{\text{BW,cav}} \cdot (1 + G_{\text{direct}} \cdot G_{\text{kly}})$$

### 9.3 Gain Control

The direct loop gain is controlled through two mechanisms:

1. **Gain coefficients**: The 2×2 direct loop matrix in the RFP:
   $$\begin{pmatrix} c_{II} & c_{IQ} \\ c_{QI} & c_{QQ} \end{pmatrix}_{\text{direct}} \quad \text{PVs: } \texttt{\{STN\}:STN:RFP:DIRECT.A/C/E/G}$$

2. **Gain offset** (for ramping): Applied as a multiplicative attenuation:
   $$G_{\text{eff}} = G_{\text{matrix}} \cdot 10^{G_{\text{offset}}/20}$$
   
   PV: `{STN}:STNDIRECT:LOOP:COUNTS.C`

### 9.4 Compensation Filters

Two additional compensation paths augment the direct loop:

**Lead Compensation** (phase advance):
$$H_{\text{lead}}(s) = \frac{1 + s \tau_{\text{lead}}}{1 + s \alpha \tau_{\text{lead}}}, \quad \alpha < 1$$

Controlled by PV `{STN}:STN:RFP:LEADCOMP` (ON/OFF).

**Integral Compensation** (steady-state error elimination):
$$H_{\text{int}}(s) = \frac{K_{\text{int}}}{s}$$

Controlled by PV `{STN}:STN:RFP:INTCOMP` (ON/OFF). This is turned OFF when the station goes to OFF state (added 2004).

The combined direct loop with compensation:

$$G_{\text{total}}(s) = G_{\text{direct}} \cdot H_{\text{lead}}(s) \cdot \left(1 + H_{\text{int}}(s)\right)$$

---

## 10. Comb Loop — Narrowband Revolution Harmonic Feedback

### 10.1 Purpose

The comb loop provides narrowband feedback at revolution frequency harmonics to reduce beam-induced oscillations. It operates through the CFM/CF2 (Comb Filter Module) hardware.

### 10.2 Mathematical Description

The comb filter transfer function is a sum of narrowband bandpass filters at revolution frequency harmonics:

$$H_{\text{comb}}(f) = \sum_{n=1}^{N} \frac{G_n}{1 + j Q_n \left(\frac{f}{n f_{\text{rev}}} - \frac{n f_{\text{rev}}}{f}\right)}$$

where:
- **f_rev** = revolution frequency of the storage ring
- **G_n** = gain at the n-th harmonic
- **Q_n** = quality factor (bandwidth) of the n-th filter

### 10.3 Gain Ramping

The comb loop gain is ramped identically to the direct loop (Section 5.6), with:

- Initial offset: `{STN}:STNCOMB:LOOP:COUNTS.C`
- Ramp delta: `{STN}:STNCOMB:LOOP:COUNTS.H`

### 10.4 Transition Sequencing

The comb loop requires the direct loop to be ON before it can be activated:

$$\text{Precondition: } G_{\text{direct}} > 0 \text{ AND station\_state} = \text{ON\_CW}$$

The rf_statesLP sequence enforces this through event flag checking.

---

## 11. Calibration System — Octal DAC Nulling

### 11.1 Overview

The calibration system (`rf_calib.st`, authored by R. Claus, 1997; rewritten by M. Laznovsky, 2004) performs automated offset nulling and IQ matrix calibration for the RFP module's digital signal processing hardware.

### 11.2 Calibration Measurement Principle

The calibration uses a statistical averaging approach. For each measurement point, COUNT = 30,000 samples are acquired and averaged to reduce noise:

$$\bar{X} = \frac{1}{N} \sum_{i=1}^{N} X_i, \quad N = 30{,}000$$

The standard error of the mean is:

$$\sigma_{\bar{X}} = \frac{\sigma_X}{\sqrt{N}} = \frac{\sigma_X}{\sqrt{30{,}000}} \approx \frac{\sigma_X}{173}$$

This provides approximately 45 dB of noise reduction relative to single-sample measurements.

### 11.3 Iterative Nulling Algorithm

The offset nulling uses a bisection-like iterative approach. For each channel:

```
Goal: Find DAC_value such that measured_output ≈ 0

for iteration = 0 to MAX_ATTEMPTS-1:
    Set DAC to current_value
    Measure output (30,000-sample average)
    
    error = measured_output - GOAL
    
    if |error| ≤ MARGIN:
        break  // Nulled within tolerance
    
    Adjust current_value based on error direction and magnitude
```

The convergence criterion:

$$|X_{\text{measured}} - X_{\text{goal}}| \leq M$$

where M = MARGIN = 1 count for most channels, BIG_MARGIN = 2 for TUNESTPT, and BIG_MARGIN2 = 4 for KLYSTAGE and COMPSTAGE.

### 11.4 DAC Range Constraints

All offset DAC values are bounded:

| DAC Type | Minimum | Maximum | Bits |
|----------|---------|---------|------|
| Standard Octal DAC | -2048 | +2047 | 12-bit signed |
| Small Octal DAC | -512 | +511 | 10-bit signed |
| Comb perturbation | -512 | +512 | ~10-bit |
| RF Modulator | 0 | 1024 | 10-bit unsigned |

### 11.5 Multiplier Zeroing

The combining matrix multiplier offset zeroing uses a search algorithm:

$$\text{Search range: } [-256, +256]$$
$$\text{Convergence tolerance: } |\text{error}| \leq 8 \text{ counts}$$

The search attempts up to ZERO_ATTEMPTS (11) iterations to find the offset value that drives the output signal to zero.

### 11.6 Channels Calibrated

The calibration procedure nulls offsets for:

1. **Cavity combining multipliers** (4 cavities × 4 coefficients each = 16 channels)
2. **Cavity output offsets** (4 cavities × 2 I/Q = 8 channels)
3. **Direct loop coefficients** (4 channels: II, IQ, QI, QQ)
4. **Direct loop control offsets** (2 channels: I, Q)
5. **Comb loop coefficients** (4 channels)
6. **Sum node offsets** (2 channels)
7. **Gain stage offsets** (4 cavities × 2 I/Q = 8 channels)
8. **Klystron modulator offsets** (4 channels: KMII, KMIQ, KMQI, KMQQ)
9. **Difference node offsets** (added 2004)
10. **Klystron demodulator offsets** (added 2004)

---

## 12. Message Logging and TAXI Error Recovery

### 12.1 Message Logging (rf_msgs)

The `rf_msgs.st` sequence monitors and logs significant hardware events using EPICS event flags:

| Event | Condition | Action |
|-------|-----------|--------|
| Trip Reset | `hvps_reset` set | Log "Trip Reset" |
| Filament Bypass | `filament_timer` set | Log "Filament Bypassed" |
| Filament ON/OFF | `filament` changed | Log state change |
| Station ON/OFF LINE | `station` changed | Log state change |
| Filament fault | `filament_sumy` cleared | Open HVPS contactor |
| HVPS faults | Specific HVPS alarm → MAJOR | Log fault with identification |

### 12.2 TAXI Error Recovery

The GVF module communicates with the LFB (Low-Frequency Beam feedback) system via a serial "TAXI" link. Link errors can cause the LFB to lose synchronization.

The TAXI recovery algorithm:

```
on GVF status change:
    if (TAXI overflow bit set) AND (woofer loop ON) AND (GVF in RUN state):
        wait(random 0.5-4.0 seconds)    // Prevent multiple IOCs from resetting simultaneously
        force taxi status check
        wait 2 ticks
        re-read status
        if TAXI error still present:
            send resync to LFB
            log "Gvf Taxi error detected. Resynch sent."
```

The random delay uses `rand()` seeded with `time(0)` to decorrelate multiple IOCs:

$$t_{\text{wait}} = \frac{\text{rand}() \bmod 210 + 30}{60} \text{ seconds} \in [0.5, 4.0] \text{ s}$$

---

## 13. Fault Management and Automatic Recovery

### 13.1 Fault Detection

The station monitors several fault summary PVs:

| Fault Summary | Purpose | Monitored By |
|--------------|---------|--------------|
| `{STN}:STNON:SUMY:STAT.SEVR` | Prevents transition to ON states | rf_states (fault_noon) |
| `{STN}:STNPARK:SUMY:STAT.SEVR` | Prevents transition to PARK | rf_states (park_noon) |
| `{STN}:STNOFF:SUMY:STAT.SEVR` | Forces transition to OFF | rf_states (fault_stnoff) |
| `{STN}:STN:LOCAL:ON.SEVR` | Local panel switch | rf_states (panel_onoff) |
| `{STN}:STN:FORCED:LTCH` | Forced fault latch | rf_states (forced_fault) |
| `{STN}:HVPSCONTACT:SUMY:STAT.SEVR` | Contactor status | rf_states (contactor_noon) |

### 13.2 Automatic Reset Algorithm

When a fault is detected in an ON state, the system attempts automatic recovery:

```
if (reset_count > 0) AND (no forced fault) AND 
   (PARK state OR (contactor OK AND panel OK)):
    
    // Check for vacuum problems first
    if vacuum errors present:
        wait VACUUMWAIT (600 ticks = 10 seconds)
    
    // Retry loop
    while (reset_count > 0) AND (fault still present) AND (hardware OK):
        issue station reset command
        reset_count -= 1
        wait RESETWAIT (300 ticks = 5 seconds)
        check fault summary
    
    if fault cleared:
        restore previous operating state
        log "Automatic reset successful"
    else:
        remain in OFF state
        log "Automatic reset failed"
```

The maximum retry count is configurable via `{STN}:STN:RESET:COUNTER`.

### 13.3 Fault File Collection

When a fault causes a transition to OFF, the rf_statesFF sequence collects diagnostic data from all hardware modules:

1. Increment fault number (circular, 1–15)
2. Record timestamp from the HVPS voltage PV
3. Set hardware modules to LOAD state (stop data acquisition)
4. For each module (11 total):
   - Save current filename and buffer size
   - Write fault filename (e.g., `/dat/FAULTRfpSI_3`)
   - Set fault buffer size
   - Trigger data collection
5. Wait for all modules to complete (timeout: MAXFFWAIT × 20 ticks ≈ 60 seconds)
6. Restore original filenames and buffer sizes
7. Restore module states to RUN

---

## 14. EPICS Process Variable Architecture

### 14.1 PV Naming Convention

All PVs follow the PEP-II naming convention parameterized by station macro `{STN}`:

```
{STN}:{SUBSYSTEM}:{PARAMETER}:{QUALIFIER}
```

Examples:
- `RFCA:STN:STATE:RBCK` — Station state readback
- `RFCA:HVPS:VOLT:CTRL` — HVPS voltage setpoint
- `RFCA:CAV1TUNR:POSN:CTRL` — Cavity 1 tuner position command

### 14.2 Event-Driven Communication Pattern

The SNL programs use the EPICS monitor/event-flag pattern for efficient inter-process communication:

```
variable declaration:    int     loop_ready;
PV assignment:           assign  loop_ready to "{STN}:STNDAC:LOOP:READY";
Monitor subscription:    monitor loop_ready;
Event flag declaration:  evflag  loop_ready_ef;
Synchronization:         sync    loop_ready loop_ready_ef;
```

The event flag is set automatically when the PV value changes. The SNL `when` clause can test and clear the flag atomically:

```c
when (efTestAndClear(loop_ready_ef) || delay(MAX_INTERVAL))
{
    // Process loop update
}
```

This pattern ensures:
- Updates are processed within one scan period of the PV change
- The maximum idle time is bounded by the delay timeout
- Event flags prevent missed updates (latching behavior)

### 14.3 Severity-Based Interlock Pattern

All hardware health checks use the EPICS alarm severity system:

```c
// From rf_loop_macs.h
#define LOOP_INVALID_SEVERITY(arg) ((arg) >= INVALID_ALARM)
#define LOOP_MAJOR_SEVERITY(arg)   ((arg) >= MAJOR_ALARM)
#define LOOP_MINOR_SEVERITY(arg)   ((arg) >= MINOR_ALARM)
```

Severity levels (from EPICS alarm.h):
| Severity | Value | Meaning |
|----------|-------|---------|
| NO_ALARM | 0 | Normal operation |
| MINOR_ALARM | 1 | Warning level |
| MAJOR_ALARM | 2 | Fault level |
| INVALID_ALARM | 3 | Hardware disconnected/unavailable |

### 14.4 Key PV Groups by Subsystem

**Station Control:**
| PV | Type | Description |
|----|------|-------------|
| `{STN}:STN:STATE:CTRL` | int | Commanded station state |
| `{STN}:STN:STATE:RBCK` | int | Actual station state |
| `{STN}:STN:STATE:STRING` | string | State description for display |
| `{STN}:STN:RESET:CTRL` | int | Station reset trigger |
| `{STN}:STN:RESET:COUNTER` | float | Auto-reset retry count |

**RFP Module Control:**
| PV | Type | Description |
|----|------|-------------|
| `{STN}:STN:RFP:RFENABLE` | int | RF switch on/off |
| `{STN}:STN:RFP:RUNMODE` | int | 0=TUNE, 1=OPERATE |
| `{STN}:STN:RFP:DIRECTLOOP` | int | Direct loop on/off |
| `{STN}:STN:RFP:COMBLOOP` | int | Comb loop on/off |
| `{STN}:STN:RFP:LEADCOMP` | int | Lead compensation on/off |
| `{STN}:STN:RFP:INTCOMP` | int | Integral compensation on/off |
| `{STN}:STN:RFP:DACS` | int | DACs on/off |
| `{STN}:STN:RFP:STATE` | int | 0=RESET, 1=LOAD, 2=RUN |
| `{STN}:STN:RFP:SSCONT` | int | 0=single shot, 1=continuous |

**DAC Loop:**
| PV | Type | Description |
|----|------|-------------|
| `{STN}:STN:TUNE:IQ.A` | float | Tune mode DAC amplitude |
| `{STN}:STN:ON:IQ.A` | float | Operate mode DAC amplitude |
| `{STN}:STN:GFF:IQ.A` | float | GFF reference amplitude |
| `{STN}:STN:PHASE:CALC` | float | Calculated setpoint phase |
| `{STN}:KLYSDRIVFRWD:DAC:DELTA` | float | Tune delta counts |
| `{STN}:STNVOLT:DAC:DELTA` | float | ON gap voltage delta counts |
| `{STN}:STNDAC:LOOP:STATUS` | int | DAC loop status code |

**HVPS Control:**
| PV | Type | Description |
|----|------|-------------|
| `{STN}:HVPS:VOLT:CTRL` | float | Requested HVPS voltage |
| `{STN}:HVPS:VOLT` | float | Readback HVPS voltage |
| `{STN}:HVPS:VOLT:MIN` | float | Minimum HVPS voltage |
| `{STN}:HVPS:VOLT:CTRL.DRVH` | float | Maximum HVPS voltage |
| `{STN}:HVPS:LOOP:CTRL` | int | 0=OFF, 1=PROCESS, 2=ON |
| `{STN}:HVPS:LOOP:STATUS` | int | HVPS loop status code |

**Tuner Control:**
| PV | Type | Description |
|----|------|-------------|
| `{STN}:CAV{CAV}TUNR:POSN` | float | Potentiometer position |
| `{STN}:CAV{CAV}TUNR:POSN:CTRL` | float | Commanded position |
| `{STN}:CAV{CAV}TUNR:POSN:DELTA` | float | Computed position delta |
| `{STN}:CAV{CAV}TUNR:STEP:MOTOR.RBV` | float | Stepper motor readback |
| `{STN}:CAV{CAV}TUNR:LOOP:CTRL` | int | Loop on/off control |
| `{STN}:CAV{CAV}TUNR:LOOP:STATUS` | int | Loop status code |
| `{STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR` | int | Load angle error severity |

---

## 15. Performance Characteristics and Stability Analysis

### 15.1 Loop Bandwidth Budget

The hierarchical control architecture requires bandwidth separation:

| Loop | Bandwidth | Period | Constraint |
|------|-----------|--------|------------|
| Direct loop (hardware) | ~10–100 kHz | ~10–100 μs | Limited by klystron bandwidth |
| DAC loop (software) | ~0.5–1 Hz | ~0.5–1 s | Must be ≪ direct loop BW |
| HVPS loop (software) | ~0.5–1 Hz | ~0.5–1 s | Must be ≪ direct loop BW |
| Tuner loop (software) | ~0.01–0.1 Hz | ~10–100 s | Limited by mechanical response |
| Comb loop (hardware) | ~10 kHz per harmonic | N/A | Revolution harmonics only |

### 15.2 Stability Margins

**DAC Loop Stability:**

The open-loop gain magnitude at the Nyquist frequency (f_N = 1/2T = 1 Hz) must satisfy:

$$|G_{\text{OL}}(f_N)| < 1$$

Given that the plant (klystron + cavity) has a very flat response at these low frequencies, stability is determined primarily by the integral gain K_i:

$$|K_i \cdot G_{\text{plant,DC}}| \cdot T < \pi \quad \Rightarrow \quad K_i < \frac{\pi}{T \cdot G_{\text{plant,DC}}}$$

**HVPS Loop Stability:**

The HVPS has significant transport delay (SCR firing delay + LC filter ringing) which limits the achievable bandwidth:

$$f_{\text{BW,HVPS}} < \frac{1}{2\pi \tau_{\text{HVPS}}}$$

where τ_HVPS includes the SCR commutation time (~8 ms at 60 Hz) and the output filter time constant.

### 15.3 Inter-Loop Coupling Analysis

The DAC loop and HVPS loop both affect the cavity voltage but through different paths:

**Coupling matrix:**
$$\begin{pmatrix} V_{\text{gap}} \\ P_{\text{drive}} \end{pmatrix} = \begin{pmatrix} G_{11} & G_{12} \\ G_{21} & G_{22} \end{pmatrix} \begin{pmatrix} N_{\text{DAC}} \\ V_{\text{HVPS}} \end{pmatrix}$$

where:
- G₁₁ = ∂V_gap/∂N_DAC — gap voltage sensitivity to DAC
- G₁₂ = ∂V_gap/∂V_HVPS — gap voltage sensitivity to HVPS voltage  
- G₂₁ = ∂P_drive/∂N_DAC — drive power sensitivity to DAC
- G₂₂ = ∂P_drive/∂V_HVPS — drive power sensitivity to HVPS voltage

The system decouples naturally because:
- In TUNE mode: DAC controls drive power, HVPS controls gap voltage
- In ON_CW with direct loop: DAC controls gap voltage (or GFF), HVPS adjusts for drive power
- The direct loop provides fast rejection of perturbations, reducing the coupling seen by the slow loops

### 15.4 Robustness Considerations

The legacy design includes several robustness features:

1. **Timeout fallbacks**: All loops process at least every 10 seconds regardless of event activity
2. **Severity gating**: Invalid measurements are rejected, preventing control action on bad data
3. **Status tracking**: Each loop maintains detailed status for operator diagnostics
4. **Anti-windup**: DAC and HVPS clamping prevents integrator windup at limits
5. **Dead zone**: Minimum delta thresholds prevent chatter and unnecessary hardware writes
6. **Gain ramping**: Gradual loop engagement prevents transient overshoots
7. **Sequential engagement**: Loops are brought online in order of increasing bandwidth to prevent instabilities

---

## Appendix A — State Transition Tables

### A.1 DAC Loop State Transitions

| Current State | Condition | Next State |
|---------------|-----------|------------|
| loop_init | (always) | loop_off |
| loop_off | station == TUNE | loop_tune |
| loop_off | station == ON_CW | loop_on (with delay) |
| loop_off | rfp_dac changed | loop_off (update DACs) |
| loop_off | ripple_ampl changed | loop_off (load ripple) |
| loop_tune | station == ON_CW | loop_on |
| loop_tune | station ≠ TUNE | loop_off |
| loop_tune | ready OR timeout | loop_tune (update) |
| loop_on | station == TUNE | loop_tune |
| loop_on | station ≠ ON_CW | loop_off |
| loop_on | ready OR timeout | loop_on (update) |

### A.2 HVPS Loop State Transitions

| Current State | Condition | Next State |
|---------------|-----------|------------|
| init | (always) | off |
| off | station ON AND ctrl == PROC | proc |
| off | station ON | on (with delay) |
| proc | station OFF/PARK | off |
| proc | ctrl ≠ PROC | on (with delay) |
| proc | ready OR timeout | proc (update) |
| on | station OFF/PARK | off |
| on | ctrl == PROC | proc |
| on | ready OR timeout | on (update) |

### A.3 Tuner Loop State Transitions

| Current State | Condition | Next State |
|---------------|-----------|------------|
| loop_init | (always) | loop_unknown |
| loop_unknown | prev ON AND ready | loop_on |
| loop_unknown | ready OR timeout | loop_off |
| loop_off | reset requested | loop_reset |
| loop_off | home requested | loop_off (set home) |
| loop_off | station ≠ OFF | loop_on |
| loop_on | meas ready | loop_on (count) |
| loop_on | reset requested | loop_reset |
| loop_on | home requested | loop_on (set home) |
| loop_on | station == OFF | loop_off |
| loop_on | loop ready | loop_on (update) |
| loop_reset | (always) | loop_unknown |

---

## Appendix B — Complete PV Reference

### B.1 Station States (from rf_station_state.h)

| Define | Value | State |
|--------|-------|-------|
| STATION_OFF | 0 | Off |
| STATION_PARK | 1 | Park |
| STATION_TUNE | 2 | Tune |
| STATION_ON_FM | 3 | On FM |
| STATION_ON_CW | 4 | On CW |

### B.2 DAC Loop Status Codes

| Code | Value | Description |
|------|-------|-------------|
| UNKNOWN | 0 | Unknown status |
| TUNE | 1 | Good — drive power control |
| ON | 2 | Good — gap voltage control |
| TUNE_OFF | 3 | Drive power control turned off |
| ON_OFF | 4 | Gap voltage control turned off |
| DRIV_BAD | 5 | Drive power bad |
| GAPV_BAD | 6 | Gap voltage bad |
| CTRL | 7 | DAC not at requested value |
| STN_OFF | 8 | Station OFF/PARK/ON_FM |
| RFP_BAD | 9 | RF processor bad |
| DAC_LIMT | 10 | DAC at limit (0 or 2047) |
| GVF_BAD | 11 | Gap module bad |
| DRIV_HIGH | 12 | No gap volt increase — drive too high |
| DRIV_TOL | 13 | Drive power out of tolerance |
| GAPV_TOL | 14 | Gap voltage out of tolerance |

### B.3 HVPS Loop Status Codes

| Code | Value | Description |
|------|-------|-------------|
| UNKNOWN | 0 | Unknown |
| GOOD | 1 | Good |
| RFP_BAD | 2 | RF Processor bad |
| CAVV_LIM | 3 | Cavity voltage above limit |
| OFF | 4 | Loop off |
| VACM_BAD | 5 | Bad vacuum |
| POWR_BAD | 6 | Klystron forward power bad |
| GAPV_BAD | 7 | Gap voltage bad |
| GAPV_TOL | 8 | Gap voltage out of tolerance |
| VOLT_LIM | 9 | HVPS at voltage limit |
| STN_OFF | 10 | Station OFF/PARK |
| VOLT_TOL | 11 | Readback ≠ requested |
| VOLT_BAD | 12 | Readback invalid |
| DRIV_BAD | 13 | Klystron drive bad |
| ON_FM | 14 | Station in ON_FM |
| DRIV_TOL | 15 | Drive power out of tolerance |

### B.4 Tuner Loop Status Codes

| Code | Value | Description |
|------|-------|-------------|
| UNKNOWN | 0 | Unknown |
| OFF | 1 | Loop OFF |
| STN_OFF | 2 | Station OFF |
| GOOD | 3 | Successful |
| ON_FM | 4 | Station in ON_FM |
| SM_CTRL | 5 | Tuner not at requested position |
| SM_LIMIT | 6 | Tuner at hardware limit |
| SM_BAD | 7 | Tuner has bad status |
| DRV_LIMT | 8 | Tuner at drive limit |
| SM_MOVE | 9 | Tuner taking too long to move |
| PHAS_BAD | 10 | Bad measurements |
| PHASMISS | 11 | Missing measurements |
| POWR_LOW | 12 | RF power bad or too low |
| LDANGLIM | 13 | Load angle error out of limits |

---

## Appendix C — Source File Index

| File | Lines | Author(s) | Date | Purpose |
|------|-------|-----------|------|---------|
| `Makefile` | 51 | S. Allison, K. Luchini | 1997–2005 | EPICS build rules |
| `rfSeq.dbd` | 6 | — | — | SNL program registration |
| `rf_states.st` | 2227 | R.C. Sass, S. Allison, M. Laznovsky | 1997–2004 | Master state machine |
| `rf_dac_loop.st` | 290 | S. Allison | 1997 | DAC/drive/gap voltage loop |
| `rf_dac_loop_defs.h` | 69 | S. Allison | 1997 | DAC loop constants |
| `rf_dac_loop_macs.h` | 197 | S. Allison | 1997 | DAC loop computation macros |
| `rf_dac_loop_pvs.h` | 156 | S. Allison | 1997 | DAC loop PV declarations |
| `rf_hvps_loop.st` | 343 | M. Zelazny, S. Allison, R.C. Sass | 1997–1999 | HVPS voltage control |
| `rf_hvps_loop_defs.h` | 81 | M. Zelazny | 1997 | HVPS loop constants |
| `rf_hvps_loop_macs.h` | 134 | M. Zelazny | 1997 | HVPS loop computation macros |
| `rf_hvps_loop_pvs.h` | 135 | M. Zelazny | 1997 | HVPS loop PV declarations |
| `rf_tuner_loop.st` | 555 | S. Allison | 1996–1999 | Cavity tuner stepper control |
| `rf_tuner_loop_defs.h` | 80 | S. Allison | 1996 | Tuner loop constants |
| `rf_tuner_loop_macs.h` | 90 | S. Allison | 1996 | Tuner loop macros |
| `rf_tuner_loop_pvs.h` | 136 | S. Allison | 1996 | Tuner loop PV declarations |
| `rf_calib.st` | 3345 | R. Claus, P. Corredoura, M. Laznovsky | 1997–2005 | Calibration sequences |
| `rf_msgs.st` | 352 | S. Allison, R.C. Sass | 1997–2000 | Message logging & TAXI |
| `rf_loop_defs.h` | 14 | — | — | Shared loop definitions |
| `rf_loop_macs.h` | 12 | — | — | Shared severity macros |

**Total source code: ~8,028 lines** (excluding blank lines and comments)

---

*End of Document*

*This technical design report was generated from a comprehensive code review of the legacy LLRF control system source files located in `llrf/legacyLLRF/`. All mathematical models and control descriptions are derived directly from analysis of the SNL state machine implementations and their associated header files.*
