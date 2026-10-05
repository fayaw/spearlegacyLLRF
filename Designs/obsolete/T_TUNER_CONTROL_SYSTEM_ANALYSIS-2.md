# SPEAR3 Legacy LLRF — Tuner Control System Technical Analysis

**Document:** T_TUNER_CONTROL_SYSTEM_ANALYSIS.md  
**Scope:** Complete reverse-engineering of the legacy mechanical cavity tuner control loop  
**Purpose:** Foundation for LLRF upgrade redesign — enable AI-optimized replacement  
**Sources:** `spear-rf-code-legacy/rfApp/` source tree (RCS-archived, EPICS/VxWorks era); SLAC SPEAR RF EPICS operator help pages: [rf_tuners.html](https://www.slac.stanford.edu/grp/ssrl/spear/epics/app/rf/help/rf_tuners.html) \[W_tuners\], [rf_tuner_input.html](https://www.slac.stanford.edu/grp/ssrl/spear/epics/app/rf/help/rf_tuner_input.html) \[W_tuner_input\]  
**Status:** Reference analysis — legacy system (AB 1746-HSTP1 stepper)

---

## Table of Contents

### Part I — What and Why

1. [Executive Summary](#1-executive-summary)
2. [Physics: Cavity Detuning and Beam Loading](#2-physics-cavity-detuning-and-beam-loading)
3. [Dual-Loop Architecture Overview](#3-dual-loop-architecture-overview)

### Part II — How It Works

4. [Inner Loop: Phase Regulation](#4-inner-loop-phase-regulation)
5. [Outer Loop: Voltage Regulation](#5-outer-loop-voltage-regulation)
6. [Sequencer: Housekeeping and Error Handling](#6-sequencer-housekeeping-and-error-handling)
7. [Disabled Path: Park Mode (PEP-II Only)](#7-disabled-path-park-mode-pep-ii-only)

### Part III — Analysis

8. [Control Loop Analysis](#8-control-loop-analysis)
9. [Hardware Interface](#9-hardware-interface)
10. [Design Gaps and Upgrade Opportunities](#10-design-gaps-and-upgrade-opportunities)
11. [Operational Summary: SPEAR3 As Deployed](#11-operational-summary-spear3-as-deployed)

### Appendices

- [A. Complete EPICS Signal Chain](#appendix-a-complete-epics-signal-chain)
- [B. Parameter Reference](#appendix-b-parameter-reference)
- [C. SNL Variables, Constants, and Status Codes](#appendix-c-snl-variables-constants-and-status-codes)
- [D. Source Traceability Index](#appendix-d-source-traceability-index)

---

# Part I — What and Why

## 1. Executive Summary

The SPEAR3 tuner control system keeps each cavity at its resonant frequency by mechanically adjusting a tuner plunger in response to measured phase error. The primary disturbance it compensates is **beam-loading-induced detuning** — the reactive component of beam current shifts the cavity's apparent resonant frequency in proportion to beam current. A secondary, slower disturbance is thermal drift from RF heating.

The system was designed as **two nested feedback loops**:

| Loop | What it regulates | Controller type | Rate | Status in SPEAR3 |
|---|---|---|---|---|
| **Inner** | Phase error (probe − forward) | Proportional → stepper motor | 2 Hz | **Active** |
| **Outer** | Cavity voltage (strength) | Leaky integrator → phase offset | 2 Hz | **Disabled by default** |

**In SPEAR3 as deployed, only the inner loop is active.** It drives the cavity to the resonant frequency calibrated during a no-beam reference procedure. The outer voltage loop exists in the code but its output is structurally clamped to zero (see §5.3). The PARK mode frequency-domain path is PEP-II functionality, permanently disabled.

**Key numbers:**
- 2 Hz loop rate, 4 cavities, station prefix `SRF1:`
- Stepper motor: 3 mm/s, 0.003175 mm/step, range −29.5 to +18 mm
- Phase deadband: 0.25° (design), conversion: 0.020–0.030 mm/° (nominal operational range per \[W_tuner_input\]), max delta: 1 mm/cycle

---

## 2. Physics: Cavity Detuning and Beam Loading

### 2.1 Why the Tuner Exists

An RF cavity has a resonant frequency $f_0$ determined by its geometry. When driven off-resonance, the generator must supply extra reactive power. The mechanical tuner adjusts cavity geometry to keep $f_0$ aligned with the drive frequency (476 MHz at SPEAR3), minimizing reflected power and maximizing efficiency.

Two phenomena shift the effective resonant frequency during operation:

**Beam loading (primary, fast):** When stored beam traverses the cavity, the reactive component of the beam-induced current shifts the apparent resonant frequency by:

$$\Delta f_{beam} = -\frac{f_0}{4 Q_L} \cdot \frac{I_b \sin\phi_s}{\pi V_{gap}}$$

where $I_b$ is beam current, $\phi_s$ is synchronous phase, $Q_L$ is loaded cavity Q (~7000), and $V_{gap}$ is gap voltage. This detuning is proportional to beam current and changes dynamically as beam is injected, decays, or is lost. At SPEAR3 operating conditions ($I_b \sim 100\text{–}500$ mA), beam loading can detune the cavity by tens of kHz.

**Thermal drift (secondary, slow):** RF heating causes slow mechanical deformation of the cavity body, shifting the resonant frequency on timescales of minutes to hours. At SPEAR3's operating gradient this is much smaller than beam loading.

### 2.2 The Load Angle

For a driven cavity with beam loading, define:
- $\phi_L$ = load angle = phase of cavity field relative to generator
- $\psi$ = forward coupler phase relative to cavity probe

The optimal detuning $\Delta\omega_{opt}$ for minimum generator power is:

$$\Delta\omega_{opt} = -\frac{\omega_0}{2Q_L} \cdot \frac{I_b \sin\phi_s}{V_{gap}}$$

This corresponds to a target load angle $\psi_{target}$ where the generator operates most efficiently.

### 2.3 How the Error Signal Maps to Detuning

The inner loop measures:

$$\text{error} = \phi_{probe} - \phi_{fwd} + \theta_{offset}$$

With $\theta_{offset} = 0$ (as in SPEAR3), `error = 0` means $\phi_{probe} = \phi_{fwd}$, which corresponds to **resonance** (zero detuning). The tuner drives toward this condition.

With a nonzero $\theta_{offset}$, the tuner drives to $\phi_{probe} - \phi_{fwd} = -\theta_{offset}$, applying a deliberate detuning of approximately:

$$\Delta f \approx \frac{\theta}{90°} \cdot \frac{f_0}{4 Q_L}$$

### 2.4 The IQA Calibration Requirement — Why the Target Is Zero

The inner loop drives `LOAD:ANGLE:ERR → 0`. But the raw IQA measurements include arbitrary phase offsets from cable lengths, directional coupler geometry, and signal conditioning hardware. The measured phase difference at true resonance is generally *not* zero.

**A calibration step establishes the zero reference:**
1. With **no beam** (so beam loading does not shift the resonant frequency), operators sweep the tuner through resonance
2. At resonance (confirmed by minimum reflected power or maximum stored energy), the EPICS IQA phase offset parameters are set so that `PROBE:PHASE.L − FRWD:PHASE.L = 0`
3. From that point forward, `LOAD:ANGLE:ERR = 0` means resonance; any nonzero value means detuning by $\Delta f \approx \frac{\epsilon}{90°} \cdot \frac{f_0}{4 Q_L}$

**EPICS panel parameters for this calibration:** The per-signal offsets described in step 2 are set via the **"Probe Phase Offset"** and **"Frwd Phase Offset"** parameters on the Tuner Inputs & Constants panel \[W_tuner_input\]. These are the operator-accessible knobs that translate the raw IQA `.L` measurement to zero at resonance. Both offsets are determined during tuner configuration.

**Why `.L` rather than `.VAL`?** Both `PROBE:PHASE` and `FRWD:PHASE` have a `.VAL` field with an individual per-signal phase offset subtracted (for beam physics applications). The `.L` field is the raw input before this offset. Using `.L` means the load angle calibration is set once at the system level (both `.L` traces zeroed at resonance) rather than needing to track per-signal offsets.

**Practical implication:** If the IQA phase calibration is incorrect or has drifted (hardware swap, cable re-routing), the tuner drives the cavity to the wrong frequency — it minimizes the measured phase difference, but that measured zero no longer corresponds to the true resonance. The system has no independent check of resonance other than this phase measurement.

---

## 3. Dual-Loop Architecture Overview

### 3.1 The Two Loops

The system was designed with two nested feedback loops. The **inner loop** (phase regulation) runs at 2 Hz and drives a stepper motor to null the measured phase error. The **outer loop** (voltage regulation) is a slow integrator that adjusts the inner loop's phase setpoint to maintain cavity voltage.

```
                    ┌─────────────────────────────────────────────┐
                    │           OUTER LOOP (voltage)              │
                    │    STRENGTH error → leaky integrator        │
                    │         → LOAD:ANGLE:OFFS (θ_offset)        │
                    │    [DISABLED IN SPEAR3: output = 0]         │
                    └──────────────────┬──────────────────────────┘
                                       │ θ_offset (= 0 in SPEAR3)
                    ┌──────────────────▼──────────────────────────┐
 IQA 400 Hz ──────► │           INNER LOOP (phase)                │
 PROBE:PHASE.L      │  error = probe − fwd + θ_offset             │
 FRWD:PHASE.L       │  delta = error × mm/deg × gain              │
                    │  new_posn = current_posn + delta            │
                    │           → stepper motor                   │
                    └──────────────────┬──────────────────────────┘
                                       │ motor moves tuner plunger
                    ┌──────────────────▼──────────────────────────┐
                    │           CAVITY PHYSICS                    │
                    │  Tuner position → resonant frequency        │
                    │  Resonant frequency → probe/fwd phase diff  │
                    └─────────────────────────────────────────────┘
```

**In SPEAR3 as deployed:** $\theta_{offset} = 0$ always. The outer loop exists in the code architecture but defaults to disabled on a fresh start without autosave (see §5.3). In normal operation with autosave restore the outer loop can be functional. The tuner operates in pure resonance-seeking mode — zero phase error means resonance.

### 3.2 Station Configuration

| Item | Value | Source |
|---|---|---|
| Station prefix | `SRF1:` | `rf_stn_4CV.substitutions,v` |
| Cavity prefix | `{STN}:CAV{N}` (N=1..4) | `rf_cav.db,v` |
| Number of cavities | 4 (independent tuner per cavity) | `rf_tuner_loop.st,v` |
| RF frequency | 476 MHz | `rf_cav.db,v` |
| Loop rate | 2 Hz (SCAN="2 second") | `rf_stn_cav.db,v` |

### 3.3 Station State Machine Context

The tuner loop only acts in `ON_CW` state. The state codes (from `rf_station_state.h,v`) are:

| State | Code | Tuner Behavior |
|---|---|---|
| OFF | 0 | Loop idle, no motor movement |
| PARK | 1 | PEP-II only — disabled in SPEAR3 |
| TUNE | 2 | Ramp/transition state |
| ON_FM | 3 | Transition state |
| **ON_CW** | **4** | **Active control — phase-domain path** |

### 3.4 Software Components

```
┌─────────────────────────────────────────────────────────────┐
│  EPICS DATABASE (rf_cav.db, rf_stn_cav.db)                  │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────────┐  │
│  │ IQA Records  │  │ subIQ.c funcs │  │ subSys.c funcs   │  │
│  │ PROBE:PHASE  │→ │ subIQphaseErr │  │ subSysFreqOff    │  │
│  │ FRWD:PHASE   │  │ subIQphaseOff │  │ subSysFreqErr    │  │
│  │ (400 Hz acq) │  │ subIQphase2ps │  │ (only PARK mode) │  │
│  └──────────────┘  └───────────────┘  └──────────────────┘  │
│            │                │                               │
│            └────────────────┘                               │
│                    │ TUNR:POSN:DELTA (event → SNL)          │
└────────────────────┼────────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────────┐
│  rf_tuner_loop.st  (SNL State Machine, 4 instances)          │
│  loop_init → loop_unknown → loop_on                          │
│    sm_posn + posn_delta → TUNR:POSN:CTRL → motor record      │
└────────────────────┬─────────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────────┐
│  Stepper Motor Record (TUNR:STEP:MOTOR)                      │
│  IN SERVICE: AB 1746-HSTP1 (steppermotor record type)        │
│  IN DEVELOPMENT: Galil DMC-4143 — not installed, not running │
└──────────────────────────────────────────────────────────────┘
```

> ### ⚠ Galil controller status
>
> Per the system owner: the Galil DMC-4143 control **has not been installed and is not in operation — it is in development**. Test moves were performed on the existing cavity motors and worked fine, but the controller is expected to go online only **when the current LLRF upgrade project is finished**. It has *not* replaced the Allen-Bradley hardware.
>
> **The AB 1746-HSTP1 stepper controller remains the in-service hardware.** Everything in this document describing present-day tuner behaviour refers to the AB path; Galil material is forward-looking.

---

# Part II — How It Works

## 4. Inner Loop: Phase Regulation

This section traces the signal from IQA measurement through to motor command — the active control path in SPEAR3.

### 4.1 Step 1 — Phase Error Measurement

**C function:** `subIQphaseErr` — `rfApp/src/db/subIQ.c,v` (line 650)  
**EPICS record:** `$(S):$(C)LOAD:ANGLE:ERR`

```c
psub->val = psub->l = psub->a - psub->b + psub->c + psub->d;
if      (psub->val < -180.0) psub->val += 360.0;
else if (psub->val >  180.0) psub->val -= 360.0;
```

$$\boxed{\text{LOAD:ANGLE:ERR} = \phi_{probe} - \phi_{fwd} + \theta_{offset} + 0}$$

| Input | PV | Description |
|---|---|---|
| INPA ($\phi_{probe}$) | `PROBE:PHASE.L` | Unadjusted probe phase (degrees) |
| INPB ($\phi_{fwd}$) | `FRWD:PHASE.L` | Unadjusted forward phase (degrees) |
| INPC ($\theta_{offset}$) | `LOAD:ANGLE:OFFS` | Target phase offset (= 0 in SPEAR3) |
| INPD | — | Spare, always 0 |

Result wrapped to $[-180°, +180°]$. Alarm limits: `HIHI/LOLO = ±5°` (MAJOR).

**Load angle error limit (Ld Angle Err Limit):** The operator panel exposes a separate parameter **"Ld Angle Err Limit"** (nominal **0.5°** per \[W_tuner_input\]) that is distinct from the ±5° EPICS HIHI/LOLO alarms. When `|LOAD:ANGLE:ERR|` exceeds this limit, the outer loading angle offset integrator (§5.2) is **frozen** — no further offset accumulation occurs until the error returns within bounds. This provides a guard against the outer loop winding up during large transient detuning events.

**Note on `.L` field:** Uses unadjusted (pre-offset) phase from IQA records. The `.VAL` field has a per-signal phase offset subtracted for beam physics applications — that subtraction is separate from the load angle target. See §2.4 for the calibration requirement that makes `error = 0` correspond to resonance.

```epics
grecord(sub,"$(S):$(C)LOAD:ANGLE:ERR") {
    field(INAM,"subIQinit")
    field(SNAM,"subIQphaseErr")
    field(INPA,"$(S):$(C)PROBE:PHASE.L  NPP MS")
    field(INPB,"$(S):$(C)FRWD:PHASE.L   NPP MS")
    field(INPC,"$(S):$(C)LOAD:ANGLE:OFFS.VAL NPP NMS")
    field(EGU,"deg")
    field(HOPR,"10")    field(LOPR,"-10")
    field(HIHI,"5")     field(LOLO,"-5")
    field(HHSV,"MAJOR") field(LLSV,"MAJOR")
}
```

### 4.2 Step 2 — Phase Error to Position Delta

**C function:** `subIQphase2posn` — `rfApp/src/db/subIQ.c,v` (line 670)  
**EPICS record:** `$(S):$(C)TUNR:POSN:DELTA`

```c
// Select error source based on station state
if (state == STATION_PARK) error = G;  // park freq error (PEP-II)
else                        error = F;  // load angle error (SPEAR3 ON_CW)

gain = clamp(gain, 0, 1);  // CAVTUNR:LOOP:GAIN

if (|error| > deadband_B):
    delta = clamp(error * C_mm_per_deg * gain, -D_mm, +D_mm)
else:
    delta = 0
```

$$\boxed{\Delta x = \text{clamp}\!\left(\epsilon \cdot C_{mm/deg} \cdot G_{loop},\; {-D},\; {+D}\right) \quad \text{if } |\epsilon| > B}$$

| Input | PV / Value | Design Value | DB Status |
|---|---|---|---|
| A | `STN:STATE:RBCK` (station state) | — | ✅ wired |
| B | deadband (degrees) | 0.25° | ❌ commented out |
| C | mm per degree | 0.020–0.030 mm/° (nominal range per \[W_tuner_input\]) | ❌ commented out |
| D | max delta per cycle | 1 mm | ❌ commented out |
| E | `CAVTUNR:LOOP:GAIN` | 0–1; nominal **1.00** (always run at unity per \[W_tuner_input\]) | ✅ wired |
| F | `LOAD:ANGLE:ERR` | degrees | ✅ wired |
| G | `FREQ:ERR` (PARK only) | degrees | ✅ wired (inactive) |

> **⚠ Configuration Gap:** INPB, INPC, INPD are all commented out in `rf_cav.db,v`. At startup these default to 0, making C=0 (delta always 0) and D=0 (output clamped to 0). The tuner is non-functional without autosave restore or operator initialization.

### 4.3 Step 3 — SNL Motor Command Integration

**Source:** `rfApp/src/rf_tuner_loop.st,v` — the `loop_on` state, 2 Hz LOOP:READY event handler

After the IQA chain computes `POSN:DELTA`, the SNL sequencer integrates it into an absolute motor position:

```
pvGet(sm_posn)                              // current motor position (from .RBV)
pvGet(posn_delta)                           // phase→position result

// MOTOR SANITY CHECK: Did the motor reach last commanded position?
if (|posn_ctrl − sm_posn| > sm_rdbd) AND (prev_loop_ctrl == ON):
    loop_status = LOOP_SM_CTRL_STATUS       // missed previous target
    prev_loop_ctrl = OFF                    // suppress until re-enabled

// Compute new absolute target
posn_new = sm_posn + posn_delta             // integrate onto current position
posn_new = clamp(posn_new, sm_drvl, sm_drvh) // enforce travel limits

// Write only if position changed or loop just re-enabled
if (posn_ctrl != posn_new) OR (prev_loop_ctrl != ON):
    posn_ctrl = posn_new
    pvPut(posn_ctrl)                        // → FLNK → motor record
prev_loop_ctrl = loop_ctrl
```

**Key design choice:** The SNL uses `sm_posn` (motor `.RBV` — actual position) as the base for each cycle, not the last commanded `posn_ctrl`. This means the inner loop is truly proportional — each cycle's motor command is: $x_{new} = x_{actual} + \Delta x$. The position integration is *implicit* through new commands building on the actual position.

**Outer loop trigger** (coupling to §5): After the motor update, the SNL also fires the outer voltage integrator:
```
if (station_state != STATION_PARK) AND (dmov_meas_count >= 1):
    pvPut(phase_offset_proc)     // writes PROC to LOAD:ANGLE:UNADOFFS
```
This `phase_offset_proc` write is the only mechanism that triggers the outer loop. It only fires when the motor was idle (`DMOV=1`) and the inner loop completed a full update. See §5 for the outer loop details.

---

## 5. Outer Loop: Voltage Regulation

### 5.1 Purpose and Design Intent

The outer loop's job is to find the **optimal detuning** for the prevailing beam loading conditions. Rather than computing this from beam current (which would require accurate knowledge of $I_b$, $\phi_s$, and $Q_L$), it uses an implicit approach: adjust the load angle offset until the cavity voltage (expressed as "strength") matches a setpoint. The physics ensures that this condition is satisfied only at the optimal operating point.

### 5.2 The Integrator — `subIQphaseOffsU`

**C function:** `subIQphaseOffsU` — `rfApp/src/db/subIQ.c,v` (line 551)  
**EPICS record:** `$(S):$(C)LOAD:ANGLE:UNADOFFS`

**Regulated quantity — cavity strength:**

$$\text{STRENGTH} = \frac{\text{PROBE:AMPL}}{\text{STN:VOLT}} \times 100\%$$

- `PROBE:AMPL` = cavity probe signal amplitude (kV)
- `STN:VOLT` = total station gap voltage sum across all cavities (kV)
- Clamped to 0% when `STN:VOLT < 2 kV` (hardwired floor in `subIQpowerEff`)

`STRENGTH:CTRL` (ao, %, DRVH=100) is the operator setpoint.  
`STRENGTH:DIFF` (ao, %, DRVH=100) is the integrator deadband (nominal operating value **0.05%** per \[W_tuner_input\]).

**Trigger mechanism:** NOT driven by the 2 Hz scan record. Triggered by the SNL sequencer writing PROC to `LOAD:ANGLE:UNADOFFS.PROC` (via `phase_offset_proc` PV) — see §4.3. This means the outer loop only fires when the inner loop has confirmed motor idleness and completed a full update.

**Integrator update equation:**

$$\theta_{unadj}[n] = \text{forget} \cdot \left( \theta_{unadj}[n-1] - K \cdot e_s[n-1] \right)$$

where:
- $e_s = \text{STRENGTH} - \text{STRENGTH:CTRL}$ (cavity voltage strength error, %)
- $K$ = `CAVLOAD:ANGLE:K` (deg/%, DRVH=1; nominal operating value **0.5 deg/%** per \[W_tuner_input\])
- $\text{forget}$ = `CAVLOAD:ANGLE:FORGET` (≤1, dimensionless; nominal operating value **0.9995** per \[W_tuner_input\])

**Gate logic — two modes:**

*RESET (state cleared to zero) — ANY of:*
1. `CAVLOAD:ANGLE:CTRL` ≤ 0.5 — disabled by operator (INPA)
2. Station state ≠ ON_CW — INPD ≠ 4
3. Beam has MINOR or MAJOR alarm: `STN:BEAM:STAT.SEVR` ∈ {1, 2} (INPC):
   - `STN:BEAM:STAT` is a `bi` record with `ZSV=MAJOR` — when beam is OFF, SEVR=2
   - `STN:BEAM:STATINP` computes: `beam_curr ≥ RF_CUTOFF ? ON : OFF`

> **Beam loss behavior \[W_tuner_input\]:** When beam current drops below the minimum threshold, the stored load angle offset is **cleared to zero** and must regenerate from scratch as beam is re-injected. This is by design — the optimal detuning depends on beam current; a stale offset from a previous fill is not applicable to a new injection.

*UPDATE (all must be true) — integrator steps:*
4. Reset conditions are all false (enabled, ON_CW, beam healthy)
5. `CAVLDANGERR:SUMY:SEVR.SEVR` = 0 — all 4 cavities' load angle errors valid (INPB):
   - This is a calc record in `rf_sumy_stn.db,v` with `CALC="0"` and four `NPP MS` inputs from `CAV1–CAV4 LOAD:ANGLE:ERR.SEVR`. Its `.SEVR` reflects the worst alarm across all 4 cavities via EPICS severity maximization.
6. Previous-cycle beam was healthy (INPE < 0.5) — one-cycle recovery hysteresis
7. `STRENGTH.SEVR` < 2.5 — strength measurement valid (INPH)
8. `|strength_error| > STRENGTH:DIFF` — error exceeds deadband (INPI)

**Pseudo-code:**

```c
strength_error = STRENGTH - STRENGTH_CTRL;   // actual − desired (%)

if (NOT active):
    offset = 0.0;                             // RESET
else if (all_valid AND |strength_error| > deadband):
    offset -= strength_error * K;             // integrator step
offset *= forget;                             // leaky decay
offset = clamp(offset, -180, +180);           // hard limits
```

### 5.3 Total Offset — `subIQphaseOffs`

**C function:** `subIQphaseOffs` — `rfApp/src/db/subIQ.c,v` (line 626)  
**EPICS record:** `$(S):$(C)LOAD:ANGLE:OFFS`

```c
psub->val = psub->d;                      // fixed offset (INPD)
if (psub->a > 0.5) psub->val += psub->b;  // + unadj_offset if enabled
psub->val = clamp(psub->val, psub->e, psub->c); // clip to [min, max]
```

$$\boxed{\theta_{offset} = \text{clamp}(D_{fixed} + \theta_{unadj},\; E_{min},\; C_{max})}$$

| Input | Function | In deployed SPEAR3 db |
|---|---|---|
| INPA | `CAVLOAD:ANGLE:CTRL` (enable) | ✅ wired |
| INPB | `LOAD:ANGLE:UNADOFFS` (integrator output) | ✅ wired |
| INPC | Max bound | ❌ absent in DB source — `#field(INPC,"10")` commented out → C = 0 on fresh start; **autosave restores 75° in normal operation** \[W_tuner_input\] |
| INPD | Fixed offset | ❌ absent → D = 0 |
| INPE | Min bound | ❌ absent → E = 0 |

**Purpose of the fixed offset (INPD):** Allows a permanent operator-set phase bias independent of the integrator. In PEP-II, this encoded a known optimal detuning from design parameters or absorbed systematic calibration offsets. In SPEAR3, INPD is absent: no fixed offset is applied.

> **⚠ The outer loop defaults to disabled on a fresh IOC start without autosave.**
>
> The DB source has `#field(INPC,"10")` commented out. On a clean start without autosave, C = 0 (and E = 0), so `clamp(val, 0, 0) = 0` forces the output to zero regardless of what the integrator computes.
>
> **However, in normal SPEAR3/PEP-II operation with autosave restore, `INPC` is restored to the nominal operational value of 75° per \[W_tuner_input\].** The official SLAC operator documentation states: *"Max Offs nominal value = 75 degrees"* and that it *"should not need to be greater than 10 degrees but is presently set higher."* With autosave active and `LOAD:ANGLE:CTRL=1`, the outer loop IS functional. The `#field(INPC,"10")` comment suppresses only the DB-compiled hard-coded default value; the 10° figure was likely a conservative initial recommendation subsequently raised to 75° in the deployed system.
>
> **Consequence of fresh start without autosave:** $\theta_{offset} = 0$. The voltage integrator (`UNADOFFS`) computes values but they are discarded by the zero-valued clamp bounds.
>
> **To activate the outer loop** on a fresh start, configure: `CAVLOAD:ANGLE:CTRL=1`, `STRENGTH:CTRL`, `STRENGTH:DIFF` (~0.05%), `LOAD:ANGLE:K` (~0.5 deg/%), `LOAD:ANGLE:FORGET` (~0.9995), and set `INPC` on `LOAD:ANGLE:OFFS` (max bound) to ~75°. Note also the fundamental sign-ambiguity described in §10.8 — cavity voltage is symmetric about resonance.

---

## 6. Sequencer: Housekeeping and Error Handling

**Source:** `rfApp/src/rf_tuner_loop.st,v` (555 lines, 4 instances — `program rf_tuner_loop("STN=RRRS,CAV=X,name=CXTUNRLOOP")`)

The SNL sequencer manages the complete lifecycle of the tuner loop. §4.3 covered the normal control path within `loop_on`. This section covers startup, error handling, and state classification.

### 6.1 State Diagram

```
           startup
               │
          ┌────▼─────┐
          │loop_init │  Initialize PV monitors,
          │          │  wait for valid readbacks
          └────┬─────┘
               │ pvGet(sm_dmov) and sm_posn valid
          ┌────▼──────────┐
          │ loop_unknown  │  Wait for loop ctrl to be set
          └────┬──────────┘
        ┌──────┴──────┐
        │ (ctrl=IDLE  │
        │  or RESET)  │
   ┌────▼────┐   ┌────▼────┐
   │loop_off │   │loop_reset│  Reset motor to home
   └────┬────┘   └────┬────┘
        │             │ (reset complete)
        │             │
   ┌────▼─────────────▼────┐
   │         loop_on       │  Main control state (see §4.3)
   └───────────────────────┘
```

### 6.2 Guard Checks in loop_on

Before the normal control path (§4.3) executes, the 2 Hz event handler evaluates guard conditions in priority order:

| Priority | Condition | Status Code | Action |
|---|---|---|---|
| 1 | `loop_ctrl == OFF` | `LOOP_OFF_STATUS` (1) | No motor action |
| 2 | `meas_count == 0` | `LOOP_PHASMISS_STATUS` (5) | IQA not producing data |
| 3 | Motor stuck > 5 cycles | `LOOP_SM_MOVE_STATUS` (6) | Motor alarm |
| 4 | `station_state == ON_FM` | `LOOP_ON_FM_STATUS` (8) | Wait for CW |
| 5 | Klystron power low | `LOOP_LOW_STATUS` (9) | Skip cycle |
| 6 | `dmov_meas_count < 1` | — | Wait for motor idle |
| 7 | Motor missed target | `LOOP_SM_CTRL_STATUS` (7) | Sanity alarm |

Only if all guards pass does the normal path fire (§4.3 Step 3).

### 6.3 Measurement Accumulator

A separate `when(efTest(meas_ready_ef))` block counts measurement events between 2 Hz ticks:

```
meas_count++
if (sm_dmov == SM_DONE_MOVING):    dmov_meas_count++
else:                               dmov_meas_count = 0
```

The main control path requires `dmov_meas_count ≥ LOOP_DMOV_MEAS (=1)` — at least one measurement where the motor was idle — before acting.

### 6.4 State Variables and Persistent State

Understanding which variables carry memory across cycles is critical for the upgrade design:

**Control state (persistent memory — the loop's "remembrance"):**

| Variable | PV | Memory type |
|---|---|---|
| `posn_ctrl` | `TUNR:POSN:CTRL` | **Inner loop state.** The absolute motor position command. Updated each cycle as $x_{actual} + \Delta x$. |
| `LOAD:ANGLE:UNADOFFS .VAL` | `CAV{N}LOAD:ANGLE:UNADOFFS` | **Outer loop state.** Accumulated strength-error-based corrections with leaky forgetting. Stored in EPICS record `.VAL`. |

**Sequencer bookkeeping (SNL-internal):**

| Variable | Role |
|---|---|
| `loop_state` | Current SNL state (init/off/reset/on) |
| `loop_status` | Last computed status code |
| `prev_loop_ctrl` | Previous cycle's enable value (edge detection + sanity check) |
| `prev_loop_status` | Last status written to PV (change-detect) |
| `meas_count` | Measurement events since last 2 Hz tick |
| `dmov_meas_count` | Motor-idle measurements (gating condition) |
| `nomov_count` | Consecutive stuck-motor cycles |

**Measured values (stateless — recomputed each cycle):**

| Variable | Source |
|---|---|
| `posn_delta` | `subIQphase2posn` output |
| `sm_posn` | Motor record `.RBV` |
| `sm_dmov` | Motor record `.DMOV` |
| `station_state` | `STN:STATE:RBCK` |
| `load_angle_sevr` | `LOAD:ANGLE:ERR.SEVR` |
| `klys_frwd_pwr` | `KLYSOUTFRWD:POWER` |

---

## 7. Disabled Path: Park Mode (PEP-II Only)

These functions existed for PEP-II (a collider with two rings). In SPEAR3 they are present in the code but permanently disabled. For PEP-II, the nominal park frequency offset was **±340 kHz** per station: half the cavities were parked at +340 kHz relative to resonance and the other half at −340 kHz \[W_tuners\].

### 7.1 Frequency Offset Estimation

**C function:** `subSysFreqOff` — `rfApp/src/db/subSys.c,v` (line 116)  
**EPICS record:** `$(S):$(C):FREQ:OFFS`

Estimates frequency offset from tuner position using a polynomial:

$$f_{offset} = p_0 + p_1 \cdot \Delta x + p_2 \cdot \Delta x^2 + p_3 \cdot \Delta x^3 + t_1 \cdot V_{cav}^2$$

where $\Delta x = \text{Tuner Posn} - \text{ON Home Posn}$ (mm) — position relative to the ON mode home (`TUNR:POSN:ONHOME`), **not** absolute position. Parameters are calibrated per cavity and thermal conditions. The $t_1 \cdot V_{cav}^2$ term accounts for RF-heating-induced detuning. The polynomial is typically accurate to **~10 kHz** per \[W_tuner_input\].

**Nominal coefficient ranges** (from \[W_tuner_input\]):

| Coefficient | Nominal Range | Units |
|---|---|---|
| $p_0$ | 10 to 20 | kHz |
| $p_1$ | 20 to 30 | kHz/mm |
| $p_2$ | 0.4 to 0.6 | kHz/mm² |
| $p_3$ | −0.01 to +0.01 | kHz/mm³ |
| $t_1$ | ≈ −0.00010 | kHz/kV² |

**Output smoothing:** A first-order IIR smoother with $S = 0.5$ is applied to the frequency offset output before it reaches `FREQ:ERR` \[W_tuner_input\]:

$$f_{smooth}[n] = (1 - S) \cdot f_{offset}[n] + S \cdot f_{smooth}[n-1]$$

This halves the effective bandwidth of the polynomial estimate, attenuating noise that could cause excessive motor movement in PARK mode.

### 7.2 Park Frequency Error

**C function:** `subSysFreqErr` — `rfApp/src/db/subSys.c,v` (line 147)  
**EPICS record:** `$(S):$(C):FREQ:ERR`

$$\text{FREQ:ERR} = 0.00004726891 \cdot Q_L \cdot (f_{desired} - f_{offset}) \quad [\text{degrees}]$$

This converts a frequency error to phase error in degrees so `subIQphase2posn` can handle both ON_CW (phase) and PARK (frequency) paths.

**Disabled in SPEAR3:** `INPB` ($Q_L$ ≈ 7000) is commented out → B=0 → output always 0.

```epics
grecord(sub,"$(S):$(C):FREQ:ERR") {
    field(SNAM,"subSysFreqErr")
    field(INPA,"0.00004726891")   # 90/(476e3 × 4) deg/kHz
  # field(INPB,"7000")            # Q_L — COMMENTED OUT
    field(INPD,"$(S):$(C):FREQ:OFFS.VAL  NPP MS")
}
```

---

# Part III — Analysis

## 8. Control Loop Analysis

### 8.1 Loop Timing Budget

```
Period:     T = 0.5 s (2 Hz)

Per cycle:
  IQA measurement:     ~2.5 ms (400 Hz, latency ~1 IQA period)
  EPICS record chain:  ~5 ms (subIQphaseErr → subIQphase2posn → event)
  SNL wakeup + calc:   ~1 ms
  Motor command write: ~1 ms
  ─────────────────────────────
  Software latency:    ~10 ms  (small vs. 500 ms period)
  Motor travel time:   0 to ~33 ms for 0.1 mm move @ 3 mm/s
  Motor settling:      additional 6 s for full deceleration from max speed

Total loop delay: ≈ loop period (0.5 s) dominates
```

### 8.2 Open-Loop Gain (Proportional Path)

The linearized loop gain from phase error to stepper position change per cycle:

$$G_{OL} = C_{mm/deg} \cdot G_{loop} = 0.020\text{–0.030} \; \frac{\text{mm}}{\text{°}} \cdot G_{loop}$$

A position change of $\Delta x$ mm changes cavity resonant frequency by:

$$\frac{df}{dx} \approx p_1 \quad [\text{kHz/mm}]$$

(the linear coefficient of the tuner polynomial, calibrated per cavity)

**Effective loop gain** (phase domain, per cycle with $G_{loop}=1$):

$$G_{eff} = C_{mm/deg} \cdot p_1 \cdot \frac{90°}{4 f_0} \cdot Q_L$$

For nominal values ($C = 0.020$ mm/° (lower end of range), $p_1 \approx 10$ kHz/mm, $Q_L \approx 7000$, $f_0 = 476$ MHz):

$$G_{eff} \approx 0.02 \times 10 \times 0.00004726891 \times 10^3 \times 7000 \approx 66$$

> **Note:** This is the single-cycle proportional gain. The 2 Hz rate and motor velocity limit prevent instability by severely band-limiting the loop. `CAVTUNR:LOOP:GAIN` (0–1) is critical for stability.

### 8.3 Integrator Dynamics (Outer Loop)

The load angle offset integrator is a **leaky first-order IIR integrator**:

$$\theta[n] = \text{forget} \cdot \left( \theta[n-1] - K \cdot e_s[n-1] \right)$$

**K gain** (`CAVLOAD:ANGLE:K`, deg/%): Per-sample step size. `DRVH=1` limits K ≤ 1 deg/%.

**Forgetting factor** (`CAVLOAD:ANGLE:FORGET`, 0 < forget ≤ 1): Makes the integrator leaky:
- **DC gain:** $G_{DC} = -K/(1 - \text{forget})$ deg/%
- **Decay time constant:** $\tau = -T / \ln(\text{forget})$ where $T = 0.5\,\text{s}$
- If the strength error disappears, the accumulated offset decays to zero with time constant $\tau$

| `forget` | $\tau$ (seconds) | DC gain (K=1 deg/%) | Notes |
|---|---|---|---|
| 1.000 | ∞ (pure integrator) | ∞ | Winds up indefinitely |
| 0.999 | ≈ 500 s (8.3 min) | −1000 deg/% | Very slow, high-gain |
| 0.990 | ≈ 50 s | −100 deg/% | Moderate — typical range |
| 0.900 | ≈ 4.7 s | −10 deg/% | Aggressive |

> **Configuration note:** Both K and FORGET are `ao` records with `PINI=YES` but no hardcoded defaults. On a fresh start without autosave, both = 0, silently disabling the integrator.

### 8.4 Bandwidth Hierarchy and Disturbance Rejection

- Inner proportional loop bandwidth: ≈ 0.1–0.5 Hz (operator-tunable via `LOOP:GAIN`)
- Outer integrator loop bandwidth: ≈ 0.002–0.02 Hz (set by K and forget)

**Primary disturbance — beam loading:** The dominant source of cavity detuning. As beam is injected, decays, or is lost, $\Delta f \propto I_b \sin\phi_s / V_{gap}$ shifts the cavity resonance. Under normal SPEAR3 operation (slow current decay, hours lifetime), the average detuning rate is slow enough for the 2 Hz loop. However, discrete events — injection bursts, fast beam loss — can shift detuning faster than the 0.5 s loop period.

**Secondary disturbance — thermal drift:** RF heating shifts resonant frequency on minutes-to-hours timescale. Much smaller than beam loading at SPEAR3 gradients. Easily handled by the inner loop.

**Uncorrected disturbances:** Fast detuning transients (injection events, beam loss) and components > ~0.25 Hz are not corrected by the 2 Hz loop. These manifest as transient phase errors that ring down over several loop cycles.

---

## 9. Hardware Interface

### 9.1 Stepper Motor Record

**EPICS record type:** `steppermotor` (custom AB 1746-HSTP1 driver record)  
**Physical device (legacy):** Allen-Bradley 1746-HSTP1 stepper module  
**Physical device (in development, not installed):** Galil DMC-4143 motion controller

```epics
grecord(steppermotor,"$(S):$(C)TUNR:STEP:MOTOR") {
    field(DTYP,"AB-1746HSTP1")
    field(OUT,"#L0 A2 C$(M) S0 @@0x8413 0x0010 500")
    field(DOL,"$(S):$(C)TUNR:POSN:CTRL.VAL  NPP NMS")
    field(OMSL,"closed_loop")
    field(ACCL,".5")          # acceleration: 0.5 mm/s²
    field(VELO,"3")           # velocity: 3 mm/s
    field(DIST,"0.003175")    # mm per step
    field(MODE,"Position")
    field(CMOD,"Position")
    field(MRES,"400")         # steps per revolution
    field(PREC,"3")
    field(EGU,"mm")
    field(DRVH,"18")          # upper drive limit: +18 mm
    field(DRVL,"-29.5")       # lower drive limit: -29.5 mm
    field(RDBD,"0.015875")    # retry deadband: 5 steps
}
```

### 9.2 Mechanism Specifications

| Parameter | Value | Calculation |
|---|---|---|
| Step resolution | 0.003175 mm/step | 1.27 mm/rev ÷ 400 steps/rev |
| Retry deadband | 0.015875 mm | 5 steps exactly |
| Maximum velocity | 3 mm/s | |
| Acceleration | 0.5 mm/s² | |
| Travel range | 47.5 mm total | −29.5 to +18 mm |
| Time to traverse full range | ~15.8 s | at 3 mm/s |
| Time to stop from full speed | 6 s | at 0.5 mm/s² |
| Min detectable move | 0.015875 mm | 1 RDBD = 5 steps |

### 9.3 Position Control and Initialization

The motor uses **absolute position mode**. On IOC startup:
1. `TUNR:STEP:CHCKINIT` verifies motor is initialized
2. `TUNR:STEP:INIT` sequence captures current hardware position → `TUNR:POSN:CTRL`
3. Subsequent commands write to `TUNR:POSN:CTRL`, which FLNKs directly to the motor record

---

## 10. Design Gaps and Upgrade Opportunities

### 10.1 Commented-Out Parameters Make Tuner Non-Functional on Fresh Start

The three key parameters for `subIQphase2posn` (deadband B, conversion C, max-delta D) are commented out in the database. On a clean start without autosave restore, C=0 → no motor movement, D=0 → output clamped to 0.

**Recommendation:** Encode these as `ao` records with `PINI=YES` and default values.

### 10.2 Outer Loop Disabled on Fresh Start (Functional with Autosave)

The LOAD:ANGLE:OFFS bounds (INPC) are commented out in the DB source (`#field(INPC,"10")`): `clamp(val, 0, 0) = 0` on a fresh IOC start without autosave. In normal operation with autosave restore, INPC is restored to 75° \[W_tuner_input\], making the outer loop potentially active when `LOAD:ANGLE:CTRL=1`. Additionally, K and FORGET have no hardcoded DB defaults (both = 0 on fresh start without autosave).

**Risk:** On a fresh IOC start without autosave (disaster recovery, new deployment), the outer loop is silently non-functional. An operator setting `LOAD:ANGLE:CTRL=1` may believe the outer loop is active when it is not.

**Recommendation:** Encode explicit defaults for K (0.5 deg/%), FORGET (0.9995), and OFFS bounds (±75°) as DB `PINI=YES` values in the upgrade design.

### 10.3 No Feedforward for Beam Loading

Beam loading is the primary disturbance (§2.1, §8.4). The only compensation path is the 2 Hz reactive inner loop. The outer integrator was designed to find optimal detuning implicitly, but is inactive. Even if active, its ~50 s time constant cannot respond to injection transients.

**There is no feedforward from beam current to detuning setpoint.** This leaves the cavity transiently detuned during injection and loss events.

**Upgrade opportunity:** Real-time detuning feedforward from DCCT beam current:

$$\Delta f_{ff} = -\frac{f_0}{4 Q_L} \cdot \frac{I_b \sin\phi_s}{\pi V_{gap}}$$

Computable in the LLRF9 with sub-millisecond latency.

### 10.4 Implicit vs. Explicit Physics

The legacy system uses an implicit integrator to find optimal detuning rather than first-principles computation ($\psi_{opt} = \arctan(2Q_L \Delta\omega / \omega_0)$). This is robust but slow.

**Upgrade opportunity:** Explicit model-based $\Delta f_{opt}$ from measured $I_b$, $V_{gap}$, and $\phi_s$ — directly enabled by LLRF9 DSP.

### 10.5 Motor Resolution vs. Phase Resolution

With C = 0.020 mm/° (minimum end of nominal range; worst-case resolution):
- 1 step (0.003175 mm) ≡ 0.159° phase change
- RDBD (5 steps = 0.015875 mm) ≡ 0.794° phase

For $Q_L \approx 7000$: 0.159° corresponds to $\Delta f \approx 95$ Hz minimum resolvable correction. The Galil controller would achieve sub-step positioning once commissioned.

### 10.6 No State Estimation or Predictive Control

Purely reactive — responds to measured error with no prediction. The 2 Hz rate cannot correct disturbances > 1 Hz (AC ripple, beam chopping).

### 10.7 Outer Loop Trigger Is SNL-Mediated

The outer integrator is triggered by the SNL writing PROC, not by the scan record. If the sequencer is not running (IOC restart, task crash) or the motor is persistently stuck (`DMOV=0`), the outer loop freezes silently.

**Recommendation:** Consider independent scan-based outer loop in upgrade.

### 10.8 Voltage Loop Sign Ambiguity — Lorentzian Symmetry Problem

**This is a fundamental control-design vulnerability in the outer (voltage) loop.**

The cavity voltage response vs. detuning is a Lorentzian:

$$V(\Delta f) = \frac{V_{max}}{\sqrt{1 + \left(\frac{2 Q_L \,\Delta f}{f_0}\right)^2}}$$

This curve is **symmetric around resonance** — the same reduced voltage appears at $+\Delta f$ and $-\Delta f$. The integrator uses voltage error alone (`STRENGTH − STRENGTH:CTRL`) to decide which direction to push the phase offset:

```c
psub->val -= psub->l * psub->j;   // offset -= (actual − desired) × K
```

When voltage is too low (actual < desired), the integrator always **increases** the offset. This is correct only if the cavity is detuned on one side of resonance. If it happens to be on the other side:

```
Scenario: cavity detuned ABOVE resonance (Δf > 0)
  → voltage < target  (down the Lorentzian slope)
  → error = actual − desired < 0
  → offset -= (negative × K) → offset INCREASES
  → inner loop drives tuner further above resonance
  → voltage drops MORE → error grows → offset increases faster
  → POSITIVE FEEDBACK → runaway to ±180° clamp
```

The integrator converges only from the **correct side** of resonance; from the wrong side it diverges. Which side is "correct" depends on the sign of K and the tuner geometry (sign of $df/dx$), but the fundamental issue is that voltage alone does not distinguish $+\Delta f$ from $-\Delta f$.

**Why this doesn't cause problems in practice:** In SPEAR3 as deployed, the outer loop is non-functional on fresh start (see §5.3, §10.2). The inner loop uses phase error, which is **monotonic** with detuning (not symmetric), so it does not have this ambiguity. If the outer loop were ever activated (e.g., via autosave with Max Offs = 75°):

1. **Normal operation (beam loading dominant):** Beam loading consistently pulls the cavity to one side of resonance (determined by $\sin\phi_s$). If the initial sign convention is chosen for this side, convergence is reliable under steady-state conditions.
2. **Transient risk:** After a beam loss/injection event, the cavity could briefly end up on the wrong side of resonance. The integrator would push in the wrong direction until either (a) the inner loop's phase control pulls it back, or (b) the offset hits the ±180° clamp.
3. **Startup ambiguity:** On first activation, the cavity's initial detuning direction is unknown. The integrator has a 50/50 chance of guessing wrong.

**Upgrade recommendation:** Any replacement for the voltage loop should use **signed detuning information** (available from the phase measurement) rather than unsigned voltage error. Options include:
- Feedforward from beam current (§10.3) — eliminates the need for voltage feedback entirely
- Model-based optimal detuning (§10.4) — computes $\Delta f_{opt}$ directly from $I_b$, $V_{gap}$, $\phi_s$
- If a voltage feedback loop is retained, include sign discrimination by checking the inner loop's phase error sign to determine which side of resonance the cavity is on, and flip the integrator sign accordingly

---

## 11. Operational Summary: SPEAR3 As Deployed

**In SPEAR3 as deployed, the tuner operates exclusively in pure resonance-seeking mode:**

1. **Inner loop (active):** 2 Hz proportional phase controller. Error = `PROBE:PHASE.L − FRWD:PHASE.L`. Motor drives to nullify this error → cavity stays at the calibrated resonant frequency.

2. **Outer loop (inactive on fresh start; potentially active with autosave):** The `LOAD:ANGLE:OFFS` max bound (INPC) is commented out in the DB source — on a fresh start `clamp(val, 0, 0) = 0` discards the integrator output. In normal SPEAR3 operation, autosave restores INPC to 75°, allowing the outer loop to function when `LOAD:ANGLE:CTRL=1`. In practice at SPEAR3 with modest beam loading the outer loop has always run at $\theta_{offset} = 0$ (pure resonance-seeking mode). See §5.3, §10.2.

3. **PARK mode (disabled):** Permanently disabled via commented-out `INPB` in `FREQ:ERR`.

**What "resonance" means here:** The calibrated zero reference from the no-beam IQA calibration procedure (§2.4). The system keeps `probe_phase − fwd_phase = 0`, which equals resonance only if the calibration is valid.

**What is NOT compensated:** With $\theta_{offset} = 0$, the tuner always drives toward zero detuning (resonance). It does not apply the optimal detuning angle that would minimize generator power under beam loading. For SPEAR3's modest beam loading this is acceptable. For higher beam loading conditions, the outer voltage loop exists in the architecture but requires explicit configuration to activate.

---

# Appendices

## Appendix A. Complete EPICS Signal Chain

### A.1 Data Flow (SPEAR3 ON_CW Mode)

```
Step 1: IQA hardware acquires I,Q at 400 Hz
  SRF1:CAV1PROBE:IQ → subIQphase → SRF1:CAV1PROBE:PHASE  (degrees, unadjusted in .L)
  SRF1:CAV1FRWD:IQ  → subIQphase → SRF1:CAV1FRWD:PHASE   (degrees, unadjusted in .L)

Step 2: Load angle target (slow integrator, if enabled)
  SRF1:CAV1:STRENGTH (= probe_amplitude / station_voltage × 100%)
  SRF1:CAV1:STRENGTH:CTRL (operator setpoint, %)
  → SRF1:CAV1LOAD:ANGLE:UNADOFFS (subIQphaseOffsU, triggered by SNL)
  → SRF1:CAV1LOAD:ANGLE:OFFS     (subIQphaseOffs, = fixed_offs + unadj_offs, bounded)

Step 3: Load angle error
  SRF1:CAV1LOAD:ANGLE:ERR (subIQphaseErr):
    error = PROBE:PHASE.L − FRWD:PHASE.L + LOAD:ANGLE:OFFS
    wrapped to [−180°, +180°]

Step 4: Phase error to position delta
  SRF1:CAV1TUNR:POSN:DELTA (subIQphase2posn):
    if |error| > deadband_B:
        delta = error × C_mm_per_deg × gain_E
        delta = clamp(delta, −D_mm, +D_mm)
    else:
        delta = 0
  → fires event SRF1:CAVTUNR:LOOP:READY

Step 5: SNL sequencer (one instance per cavity)
  Wakes on READY event
  new_posn = sm_posn + posn_delta
  new_posn = clamp(new_posn, sm_drvl, sm_drvh)
  writes new_posn → SRF1:CAV1TUNR:POSN:CTRL

Step 6: Motor response
  SRF1:CAV1TUNR:POSN:CTRL FLNK → SRF1:CAV1TUNR:STEP:MOTOR
  Motor moves to absolute position new_posn
  Readback: SRF1:CAV1TUNR:POSN (motor .RBV → EPICS ao)
```

### A.2 Record Trigger Chain

```
SRF1:CAVTUNR:LOOP:SEQ  [SCAN="2 second"]
    → fires FLNK → SRF1:CAVTUNR:LOOP:READY (event)
    → SRF1:CAV{1,2,3,4}TUNR:POSN:DELTA processes (event-triggered)
        → each POSN:DELTA FLNK → SRF1:CAV{N}TUNR:LOOPMEAS:READY event
            → wakes SNL sequencer instance (per cavity)
                → SNL reads posn_delta, updates motor: pvPut(TUNR:POSN:CTRL)
                → SNL writes PROC to LOAD:ANGLE:UNADOFFS (via phase_offset_proc)
                    → subIQphaseOffsU fires → updates voltage integrator
                    → FLNK → LOAD:ANGLE:OFFS recomputed
                        → feeds next cycle's LOAD:ANGLE:ERR
```

---

## Appendix B. Parameter Reference

### B.1 Operator-Settable Parameters (Station-Level)

These are `ao`/`bo` records in `rf_stn_cav.db,v`, shared across all cavities (prefix `$(S):CAV`):

| PV (with prefix `SRF1:CAV`) | Type | EGU | DRVH | Default | Description |
|---|---|---|---|---|---|
| `TUNR:LOOP:CTRL` | bo | — | — | — | Master loop enable (0=off, 1=on) |
| `TUNR:LOOP:GAIN` | ao | — | 1 | autosave | Phase-to-position gain scalar (0–1) |
| `LOAD:ANGLE:K` | ao | deg/% | 1 | autosave | Integrator K constant |
| `LOAD:ANGLE:FORGET` | ao | — | 1 | autosave | Forgetting factor (≤1) |
| `LOAD:ANGLE:ERRMAX` | ao | deg | 180 | autosave | Max allowed load angle error |
| `LOAD:ANGLE:CTRL` | bo | — | — | autosave | Enable load angle offset integrator |
| `STRENGTH:CTRL` | ao | % | 100 | autosave | Desired cavity strength setpoint (%) |
| `STRENGTH:DIFF` | ao | % | 100 | autosave | Voltage integrator deadband |

### B.2 Per-Cavity Parameters (rf_cav.db,v)

| PV (e.g., `SRF1:CAV1`) | Function | Default | Notes |
|---|---|---|---|
| `TUNR:POSN:ONHOME` | Home position for freq polynomial | autosave | Reference for `subSysFreqOff` |
| `TUNR:POSN:PARKHOME` | Park home position | autosave | PEP-II only |
| `LOAD:ANGLE:OFFS` | Total load angle offset (computed) | 0 | output of `subIQphaseOffs` |

### B.3 Commented-Out Parameters (Require Autosave)

| Sub Record | Input | Function | Design Value | Status |
|---|---|---|---|---|
| `TUNR:POSN:DELTA` | INPB | Phase deadband (°) | 0.25 | `#field(INPB,"0.25")` — commented |
| `TUNR:POSN:DELTA` | INPC | mm per degree | 0.020–0.030 range | `#field(INPC,"0.02")` — commented |
| `TUNR:POSN:DELTA` | INPD | Max delta per cycle (mm) | 1.0 | `#field(INPD,"1")` — commented |
| `LOAD:ANGLE:OFFS` | INPC | Max offset bound (°) | 10 (DB); **75 operational** \[W_tuner_input\] | `#field(INPC,"10")` — commented; autosave restores 75° in normal operation |
| `FREQ:ERR` | INPB | Loaded cavity Q | 7000 | `#field(INPB,"7000")` — commented |

### B.4 Physical Constants (Hardwired)

| Constant | Value | Location | Meaning |
|---|---|---|---|
| `90/(476e3 × 4)` | 0.00004726891 deg/kHz | `rf_cav.db,v`, FREQ:ERR INPA | Phase per unit frequency |
| RF frequency | 476 MHz | Implicit | SPEAR3 accelerating frequency |
| Stepper DIST | 0.003175 mm/step | Motor record | Linear resolution |
| Stepper MRES | 400 steps/rev | Motor record | Angular resolution |
| Stepper RDBD | 0.015875 mm | Motor record | 5-step retry deadband |
| Motor DRVH/DRVL | +18 / −29.5 mm | Motor record | Travel limits |
| Motor VELO | 3 mm/s | Motor record | Maximum velocity |
| Motor ACCL | 0.5 mm/s² | Motor record | Acceleration |

---

## Appendix C. SNL Variables, Constants, and Status Codes

### C.1 Complete PV Binding Table

| SNL Variable | Type | EPICS PV | Role |
|---|---|---|---|
| `loop_ctrl` | int | `{STN}:CAVTUNR:LOOP:CTRL` | Master enable, monitored (bo) |
| `loop_state` | int | `{STN}:CAV{CAV}TUNR:LOOP:STATE` | Output: current SNL state code |
| `loop_status` | int | `{STN}:CAV{CAV}TUNR:LOOP:STATUS` | Output: status code |
| `loop_status_string_c` | string | `{STN}:CAV{CAV}TUNR:LOOP:STRING` | Output: human-readable status text |
| `station_state` | int | `{STN}:STN:STATE:RBCK` | Monitored, drives state branching |
| `posn_ctrl` | float | `{STN}:CAV{CAV}TUNR:POSN:CTRL` | Motor position command (mm) |
| `posn_delta` | float | `{STN}:CAV{CAV}TUNR:POSN:DELTA` | Per-cycle position increment |
| `posn_new` | float | `{STN}:CAV{CAV}TUNR:POSN:LOOP` | Logged: newly computed target |
| `posn` | float | `{STN}:CAV{CAV}TUNR:POSN` | Potentiometer position readback |
| `posn_on_home` | float | `{STN}:CAV{CAV}TUNR:POSN:ONHOME` | Home for ON mode |
| `posn_park_home` | float | `{STN}:CAV{CAV}TUNR:POSN:PARKHOME` | Home for PARK (PEP-II) |
| `posn_mdel` | float | `{STN}:CAV{CAV}TUNR:POSN.MDEL` | Monitor delta |
| `sm_posn` | float | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.RBV` | Motor readback (authoritative) |
| `sm_dmov` | int | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.DMOV` | Done-moving flag, monitored |
| `sm_drvh` | float | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.DRVH` | Upper travel limit |
| `sm_drvl` | float | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.DRVL` | Lower travel limit |
| `sm_rdbd` | float | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.RDBD` | Retry deadband |
| `phase_offset_proc` | int | `{STN}:CAV{CAV}LOAD:ANGLE:UNADOFFS.PROC` | Outer loop trigger |
| `load_angle_sevr` | int | `{STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR` | Load angle alarm severity |
| `klys_frwd_pwr` | float | `{STN}:KLYSOUTFRWD:POWER` | Klystron forward power |
| `klys_frwd_pwr_min` | float | `{STN}:KLYSOUTFRWD:POWER:MIN` | Minimum power threshold |
| `loop_ready` | int | `{STN}:CAVTUNR:LOOP:READY` | Station-wide 2 Hz event |
| `meas_ready` | int | `{STN}:CAV{CAV}TUNR:LOOPMEAS:READY` | Per-cavity measurement event |

### C.2 Internal Counters (No PV Binding)

| Variable | Purpose |
|---|---|
| `meas_count` | LOOPMEAS:READY events since last LOOP:READY |
| `dmov_meas_count` | Motor-idle measurements (gating condition) |
| `nomov_count` | Consecutive stuck-motor cycles |
| `nonfunc_count` | Consecutive bad cycles (rate-limits alarms) |
| `reset_count` | Reset attempt counter |
| `prev_loop_ctrl` | Previous enable value (edge detection + sanity check) |
| `prev_loop_status` | Previous status code (change-detect) |

### C.3 Constants (from `rf_tuner_loop_defs.h,v`)

| Constant | Value | Description |
|---|---|---|
| `LOOP_DMOV_MEAS` | 1 | Min done-moving measurements before acting |
| `LOOP_NOMOV_COUNT` | 5 | Stuck-motor cycles before alarm |
| `LOOP_NONFUNC_INTERVAL` | 1 | Bad cycles before NONFUNC alarm |
| `LOOP_RESET_COUNT` | 5 | Max reset attempts |
| `LOOP_MAX_DELAY` | 60 | Max startup wait (seconds) |
| `SM_DONE_MOVING` | 1 | DMOV value = done |

### C.4 Status Codes

| Code | Name | Meaning |
|---|---|---|
| 0 | `LOOP_UNKNOWN_STATUS` | Initial / unresolved |
| 1 | `LOOP_OFF_STATUS` | Disabled by operator |
| 2 | `LOOP_GOOD_STATUS` | Normal operation |
| 3 | `LOOP_RESET_STATUS` | Performing reset |
| 4 | `LOOP_HOME_STATUS` | Moving to home |
| 5 | `LOOP_PHASMISS_STATUS` | No IQA data |
| 6 | `LOOP_SM_MOVE_STATUS` | Motor stuck |
| 7 | `LOOP_SM_CTRL_STATUS` | Motor missed target |
| 8 | `LOOP_ON_FM_STATUS` | Station in FM |
| 9 | `LOOP_LOW_STATUS` | Klystron power low |
| 13 | `LOOP_LDANGLIM_STATUS` | Load angle at limit |

---

## Appendix D. Source Traceability Index

| System Element | Primary Source | Secondary Source |
|---|---|---|
| Loop topology, 5-state machine | `rfApp/src/rf_tuner_loop.st,v` | `codeReviewTechnicalNotes/05-snl-state-machines.md` |
| `subIQphaseErr` (error calc) | `rfApp/src/db/subIQ.c,v` line 650 | `rf_cav.db,v` line ~544 |
| `subIQphaseOffsU` (integrator) | `rfApp/src/db/subIQ.c,v` line 551 | `rf_cav.db,v` line ~591 |
| `subIQphaseOffs` (total offset) | `rfApp/src/db/subIQ.c,v` line 626 | `rf_cav.db,v` line ~567 |
| `subIQphase2posn` (phase→posn) | `rfApp/src/db/subIQ.c,v` line 670 | `rf_cav.db,v` line ~637 |
| `subSysFreqOff` (polynomial freq) | `rfApp/src/db/subSys.c,v` line 116 | `codeReviewTechnicalNotes/08-signal-processing.md` |
| `subSysFreqErr` (freq error) | `rfApp/src/db/subSys.c,v` line 147 | `rf_cav.db,v` line ~466 |
| Motor parameters | `rfApp/Db/rf_cav.db,v` lines 655–690 | `codeReviewTechnicalNotes/06-plc-stepper-motors.md` |
| Station-level parameters | `rfApp/Db/rf_stn_cav.db,v` | `codeReviewTechnicalNotes/07-epics-databases.md` |
| PARK mode disabled | `rf_cav.db,v` (`#field(INPB,"7000")`) | `codeReviewTechnicalNotes/05-snl-state-machines.md` |
| 2 Hz loop rate | `rf_stn_cav.db,v` (SCAN="2 second") | `rf_tuner_loop.st,v` |
| RF frequency (476 MHz) | `rf_cav.db,v` (INPA=0.00004726891) | Derived: 90/(476000×4) |
| Station state codes | `rfApp/src/db/rf_station_state.h,v` | `codeReviewTechnicalNotes/05-snl-state-machines.md` |
| Galil planned as AB replacement (**not yet installed**) | `codeReviewTechnicalNotes/06-plc-stepper-motors.md` | PDR §10.3; test moves performed Aug 2025, `llrf/tuners/galil/functioningGalil20250825SwapABToManual.txt` |
