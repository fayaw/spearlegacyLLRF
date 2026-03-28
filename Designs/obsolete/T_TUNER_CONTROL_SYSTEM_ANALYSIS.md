# SPEAR3 Legacy LLRF — Tuner Control System Technical Analysis

**Document:** T_TUNER_CONTROL_SYSTEM_ANALYSIS.md  
**Scope:** Complete reverse-engineering of the legacy mechanical cavity tuner control loop  
**Purpose:** Foundation for LLRF upgrade redesign — enable AI-optimized replacement  
**Sources:** `spear-rf-code-legacy/rfApp/` source tree (RCS-archived, EPICS/VxWorks era)  
**Status:** Reference analysis — legacy system (AB 1746-HSTP1 stepper replaced by Galil DMC-4143, Aug 2025)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [Control Loop Signal Chain](#3-control-loop-signal-chain)
4. [Physics Background: Load Angle and Optimal Detuning](#4-physics-background-load-angle-and-optimal-detuning)
5. [Algorithm 1 — Load Angle Phase Error Measurement](#5-algorithm-1--load-angle-phase-error-measurement)
6. [Algorithm 2 — Target Load Angle (Dual-Loop Integrator)](#6-algorithm-2--target-load-angle-dual-loop-integrator)
7. [Algorithm 3 — Phase Error to Motor Position](#7-algorithm-3--phase-error-to-motor-position)
8. [Algorithm 4 — Park Frequency Error (PEP-II Only, Disabled in SPEAR3)](#8-algorithm-4--park-frequency-error-pep-ii-only-disabled-in-spear3)
9. [SNL Sequencer Logic](#9-snl-sequencer-logic)
10. [Hardware Interface](#10-hardware-interface)
11. [Complete Parameter Reference](#11-complete-parameter-reference)
12. [Control Loop Analysis](#12-control-loop-analysis)
13. [Identified Design Gaps and Observations](#13-identified-design-gaps-and-observations)
14. [Source Traceability Index](#14-source-traceability-index)
15. [Operational Summary: SPEAR3 As Deployed](#15-operational-summary-spear3-as-deployed)

---

## 1. Executive Summary

The SPEAR3 legacy tuner control system is a **2 Hz proportional feedback loop** that steers a mechanical stepper motor to minimize the phase error between the cavity probe signal and the forward drive signal. The physical objective is to keep the cavity at resonance in the presence of beam-loading-induced detuning — the dominant source of cavity frequency deviation during operation — and secondarily to compensate slow thermal/mechanical drift.

**In SPEAR3 (ON_CW mode), the active control path is:**

```
IQA phase measurements (PROBE, FORWARD)
    → Load angle error (subIQphaseErr)  
    → Target load angle offset (subIQphaseOffsU integrator — if enabled)
    → Phase-error-to-position conversion (subIQphase2posn)
    → SNL sequencer clips and sends position command
    → Stepper motor moves
```

**Key design characteristics:**
- **Rate:** 2 Hz (EPICS `seq` record scan)
- **Error signal:** `(PROBE_phase − FRWD_phase + offset)` in degrees
- **Actuator:** Stepper motor, velocity 3 mm/s, resolution 0.003175 mm/step (≈400 steps/rev)
- **Position range:** −29.5 mm to +18 mm (absolute), ±2 mm per cycle (velocity limiting)
- **Target setpoint:** Provided by a slow integrator that nulls cavity voltage error (if enabled) or fixed at 0° (resonance)

**PARK mode (frequency-domain path via `subSysFreqErr`) is PEP-II functionality only. It is permanently disabled in the SPEAR3 deployment via a commented-out QL input (`#field(INPB,"7000")` in `rf_cav.db,v`).**

---

## 2. System Architecture Overview

### 2.1 Station Configuration

| Item | Value | Source |
|---|---|---|
| Station prefix | `SRF1:` | `rf_stn_4CV.substitutions,v` |
| Cavity prefix macro | `{STN}:CAV{N}` (N=1..4) | `rf_cav.db,v` |
| Number of cavities | 4 | `rf_tuner_loop.st,v` |
| RF frequency | 476 MHz | `rf_cav.db,v` (constant 0.00004726891 = 90/(476e3×4)) |

### 2.2 Station State Machine Context

The tuner loop only acts in `ON_CW` state. The state codes (from `rf_station_state.h,v`) are:

| State | Code | Tuner Behavior |
|---|---|---|
| OFF | 0 | Loop idle, no motor movement |
| PARK | 1 | PEP-II only — frequency-domain path (disabled in SPEAR3) |
| TUNE | 2 | Ramp/transition state |
| ON_FM | 3 | Transition state |
| **ON_CW** | **4** | **Active control — phase-domain path** |

### 2.3 Software Components

```
┌─────────────────────────────────────────────────────────────┐
│  EPICS DATABASE (rf_cav.db, rf_stn_cav.db)                  │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────────┐  │
│  │ IQA Records  │  │ subIQ.c funcs │  │ subSys.c funcs   │  │
│  │ PROBE:PHASE  │→ │ subIQphaseErr │  │ subSysFreqOff    │  │
│  │ FRWD:PHASE   │  │ subIQphaseOff │  │ subSysFreqErr    │  │
│  │ (400 Hz acq) │  │ subIQphase2ps │  │ (only PARK mode) │  │
│  └──────────────┘  └───────────────┘  └──────────────────┘  │
│            │                │                                 │
│            └────────────────┘                                 │
│                    │ TUNR:POSN:DELTA (sevent → SNL)           │
└────────────────────┼─────────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────────┐
│  rf_tuner_loop.st  (SNL State Machine, 4 instances)          │
│  loop_init → loop_unknown → loop_on                          │
│    sm_posn + posn_delta → TUNR:POSN:CTRL → motor record     │
└────────────────────┬─────────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────────┐
│  Stepper Motor Record (TUNR:STEP:MOTOR)                      │
│  Legacy: AB 1746-HSTP1 (steppermotor record type)            │
│  Current: Galil DMC-4143 (commissioned Aug 2025)             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Control Loop Signal Chain

### 3.1 Complete Data Flow (SPEAR3 ON_CW Mode)

The following shows the EPICS record chain that fires for each cavity (e.g., `SRF1:CAV1`):

```
Step 1: IQA hardware acquires I,Q at 400 Hz
  SRF1:CAV1PROBE:IQ → subIQphase → SRF1:CAV1PROBE:PHASE  (degrees, unadjusted stored in .L field)
  SRF1:CAV1FRWD:IQ  → subIQphase → SRF1:CAV1FRWD:PHASE   (degrees, unadjusted stored in .L field)

Step 2: Load angle target (slow integrator, if enabled)
  SRF1:CAV1:STRENGTH (= probe_amplitude / station_voltage × 100%)
  SRF1:CAV1:STRENGTH:CTRL (operator setpoint, %)
  → SRF1:CAV1LOAD:ANGLE:UNADOFFS (subIQphaseOffsU, 2 Hz integrator)
  → SRF1:CAV1LOAD:ANGLE:OFFS     (subIQphaseOffs,  = fixed_offs + unadj_offs, bounded)

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
  → fires event SRF1:CAVTUNR:LOOP:READY (event number)

Step 5: SNL sequencer (rf_tuner_loop.st, one instance per cavity)
  Wakes on READY event
  new_posn = sm_posn + posn_delta
  new_posn = clamp(new_posn, sm_drvl, sm_drvh)
  writes new_posn → SRF1:CAV1TUNR:POSN:CTRL

Step 6: Motor response
  SRF1:CAV1TUNR:POSN:CTRL FLNK → SRF1:CAV1TUNR:STEP:MOTOR (steppermotor/motor record)
  Motor moves to absolute position new_posn
  Readback: SRF1:CAV1TUNR:POSN (motor .RBV → EPICS ao)
```

### 3.2 Record Trigger Chain

The 2 Hz master trigger comes from a station-level sequence record:

```
SRF1:CAVTUNR:LOOP:SEQ  [SCAN="2 second"]
    → fires FLNK → SRF1:CAVTUNR:LOOP:READY (event)
    → SRF1:CAV{1,2,3,4}TUNR:POSN:DELTA processes (event-triggered, one per cavity)
        → each POSN:DELTA FLNK → SRF1:CAV{N}TUNR:LOOPMEAS:READY event
            → wakes SNL sequencer instance (rf_tuner_loop.st, per cavity)
                → SNL reads posn_delta, updates motor: pvPut(TUNR:POSN:CTRL)
                → SNL writes PROC to LOAD:ANGLE:UNADOFFS (via phase_offset_proc PV)
                    → subIQphaseOffsU fires → updates voltage integrator
                    → FLNK → LOAD:ANGLE:OFFS recomputed
                        → feeds next cycle's LOAD:ANGLE:ERR
```

> **Design note:** The outer voltage integrator (`UNADOFFS`) is **not** triggered directly by the 2 Hz seq scan record. It is triggered by the SNL sequencer writing PROC to `LOAD:ANGLE:UNADOFFS.PROC` after each successful inner-loop motor update. This means the outer integrator only fires when the motor was ready (`DMOV=1`) and the inner loop completed a full update cycle.

---

## 4. Physics Background: Load Angle and Optimal Detuning

### 4.1 The Cavity Load Angle

For a driven cavity with beam loading, define:
- $\phi_L$ = load angle = phase of cavity field relative to generator
- $\psi$ = forward coupler phase relative to cavity probe

The standard RF cavity phasor relationship gives the **optimal detuning** $\Delta\omega_{opt}$ for minimum generator power:

$$\Delta\omega_{opt} = -\frac{\omega_0}{2Q_L} \cdot \frac{I_b \sin\phi_s}{V_{gap}}$$

where $I_b$ is beam current, $\phi_s$ is synchronous phase, and $V_{gap}$ is gap voltage.

This optimal condition corresponds to a **target load angle** $\psi_{target}$ such that the generator drives the cavity at its optimal operating point.

### 4.2 How the Legacy System Handles This

**The legacy code does NOT compute the target load angle from physics formulae.** Instead, it uses two approaches:

**Approach A (intended for SPEAR3, outer loop currently inactive):** A slow integrator adjusts the load angle offset until cavity voltage (strength) reaches its setpoint. The correct detuning for the prevailing beam current is found implicitly — the system converges to the stable operating point where generator power is minimized and cavity voltage matches the setpoint. This is the correct approach for beam-loading-driven detuning compensation, though as noted in §6.3 the output is structurally clamped to zero in the deployed database.

**Approach B (PEP-II only, disabled in SPEAR3):** Explicitly computes `phase_err = (90°/(4·f_RF)) × Q_L × Δf` to drive to a frequency target. This requires knowing $Q_L$ and the desired frequency offset.

### 4.3 Physical Interpretation of the Error Signal

With the load angle offset = 0 (simplest case):

$$\text{error} = \phi_{probe} - \phi_{fwd}$$

This measures the **phase difference between cavity probe and forward drive**. When this is zero, the cavity is driven in phase with its own field — this corresponds to **resonance** (zero detuning). The tuner drives the cavity to resonance.

With a nonzero load angle offset $\theta$:

$$\text{error} = \phi_{probe} - \phi_{fwd} + \theta$$

The tuner now drives to a condition $\phi_{probe} - \phi_{fwd} = -\theta$, i.e., it applies a deliberate detuning. The amount of detuning corresponding to a phase offset $\theta$ in degrees is approximately:

$$\Delta f \approx \frac{\theta}{90°} \cdot \frac{f_0}{4 Q_L}$$

---

## 5. Algorithm 1 — Load Angle Phase Error Measurement

### 5.1 Function

**C function:** `subIQphaseErr` — `rfApp/src/db/subIQ.c,v` (line 650)  
**EPICS record:** `$(S):$(C)LOAD:ANGLE:ERR` (sub record, `rf_cav.db,v`)

### 5.2 Calculation

```c
psub->val = psub->l = psub->a - psub->b + psub->c + psub->d;
if      (psub->val < -180.0) psub->val += 360.0;
else if (psub->val >  180.0) psub->val -= 360.0;
```

In terms of PV inputs:

$$\boxed{\text{LOAD:ANGLE:ERR} = \phi_{probe} - \phi_{fwd} + \theta_{offset} + 0}$$

where:
- $\phi_{probe}$ = `PROBE:PHASE.L` (unadjusted, i.e., before phase offset removal) — INPA
- $\phi_{fwd}$ = `FRWD:PHASE.L` (unadjusted) — INPB
- $\theta_{offset}$ = `LOAD:ANGLE:OFFS` — INPC (target phase offset, degrees)
- INPD = 0 always (spare/unused)
- Result is wrapped to $[-180°, +180°]$

### 5.3 Record Definition (rf_cav.db,v)

```epics
grecord(sub,"$(S):$(C)LOAD:ANGLE:ERR") {
    field(INAM,"subIQinit")
    field(SNAM,"subIQphaseErr")
    field(INPA,"$(S):$(C)PROBE:PHASE.L  NPP MS")     # unadj probe phase
    field(INPB,"$(S):$(C)FRWD:PHASE.L   NPP MS")     # unadj forward phase
    field(INPC,"$(S):$(C)LOAD:ANGLE:OFFS.VAL NPP NMS") # target offset
    field(EGU,"deg")
    field(HOPR,"10")    field(LOPR,"-10")
    field(HIHI,"5")     field(LOLO,"-5")
    field(HHSV,"MAJOR") field(LLSV,"MAJOR")
}
```

### 5.4 Notes

- Uses `.L` (unadjusted, pre-offset) phase fields from IQA records, not `.VAL` (which has phase offset removed). This is intentional: the phase offset for signal conditioning is separate from the load angle target.
- Alarm thresholds: `HIHI/LOLO = ±5°` (MAJOR), `HIGH/LOW = ±180°` (MINOR — catches wrapping issues).

### 5.5 Why Is the Target Zero? — The IQA Calibration Requirement

The inner loop drives `LOAD:ANGLE:ERR → 0`. With `LOAD:ANGLE:OFFS = 0` (as deployed in SPEAR3), this means the loop forces:

$$\phi_{probe}.L - \phi_{fwd}.L = 0$$

**This condition equals cavity resonance only after a calibration step.** The raw IQA measurements of probe phase and forward phase include arbitrary offsets from RF cable lengths, directional coupler geometry, and signal conditioning hardware. The measured phase difference at true cavity resonance is generally not zero — it depends on the physical cable routing in each station.

The calibration procedure establishes the zero reference:
1. With **no beam** (so beam loading does not shift the resonant frequency), operators sweep the stepper motor position through resonance
2. At resonance (confirmed by minimum reflected power, or maximum stored energy, or minimum forward power for a fixed gap voltage), the EPICS IQA phase offset parameters are set so that `PROBE:PHASE.L − FRWD:PHASE.L = 0`
3. From that point forward, `LOAD:ANGLE:ERR = 0` means resonance; any non-zero value means the cavity has drifted from its resonant frequency by $\Delta f \approx \frac{\epsilon}{90°} \cdot \frac{f_0}{4 Q_L}$

**Why use `.L` rather than `.VAL`?** Both `PROBE:PHASE` and `FRWD:PHASE` have a `.VAL` field that has an individual per-signal phase offset subtracted (used to zero out cable/coupler delays for beam physics applications). The `.L` field stores the raw sub-record input value, before this offset is applied. Using `.L` for the load angle error means the calibration is done once at the system level (by setting both `.L` traces to zero at resonance), rather than needing to track per-signal offset subtraction. It does mean the load angle calibration is embedded implicitly in the `.L` values at the time of the no-beam tuning.

**Practical implication:** If the IQA phase calibration is incorrect or has drifted (hardware swap, cable re-routing), the tuner will drive the cavity to the wrong resonant condition — it will minimize the measured phase difference, but that measured zero may no longer correspond to the true frequency resonance. The system has no independent check of resonance other than this phase measurement.

### 5.6 Beam Loading Is the Primary Source of Cavity Detuning

The main cause of cavity frequency deviation during accelerator operation is not thermal drift — it is **beam loading**. When beam circulates in the ring and traverses the cavity, the beam-induced current drives the cavity and the reactive component of the beam-current interaction shifts the apparent resonant frequency by:

$$\Delta f_{beam} = -\frac{f_0}{4 Q_L} \cdot \frac{I_b \sin\phi_s}{\pi V_{gap}}$$

where $I_b$ is the stored beam current (mA), $\phi_s$ is the synchronous phase, and $V_{gap}$ is the cavity gap voltage. This detuning is proportional to beam current and changes dynamically as beam is injected, decays, or is lost.

For SPEAR3 at operating conditions ($I_b \sim 100\text{–}500$ mA, $Q_L \sim 7000$, $V_{gap}$ per cavity ~hundreds of kV, $f_0 = 476$ MHz), beam loading can detune the cavity by tens of kHz. Thermal drift from RF heating is much slower (hours timescale) and much smaller in magnitude at SPEAR3's relatively modest accelerating gradient.

**Consequence for Section 12:** The primary disturbance the inner loop must track is beam current variation, not thermal drift. The 2 Hz loop rate is adequate for the slow average detuning (beam current changes on timescales of seconds to minutes), but cannot track fast transients such as injection bursts or beam loss events, which can shift the detuning in a fraction of a second.

---

## 6. Algorithm 2 — Target Load Angle (Dual-Loop Integrator)

### 6.1 Overview

Two chained subroutine records compute the load angle offset (target phase). Together with the inner proportional phase loop (Algorithm 3), they implement a **dual-loop control structure**:

- **Outer loop (voltage regulation):** `subIQphaseOffsU` adjusts the target load angle offset until cavity *strength* (voltage ratio) matches its setpoint. This is a slow leaky integrator executed once per 2 Hz cycle via the SNL `phase_offset_proc` trigger — but only after the inner loop has successfully updated the motor.
- **Inner loop (phase regulation):** `subIQphase2posn` drives motor position to null the instantaneous load angle error. This is a proportional controller operating at 2 Hz.

The outer loop's design intent is to find the optimal cavity detuning implicitly: the integrator adjusts the load angle target until cavity voltage converges to its setpoint, which only occurs at the operating detuning that minimizes generator power for the prevailing beam loading conditions.

**In SPEAR3 as deployed, the outer voltage loop is structurally inactive by default** (see §6.3 Configuration Note — the output clamp bounds are absent). The tuner operates in pure resonance-seeking mode (inner loop only, offset fixed at 0°) unless the operator explicitly configures and enables the outer loop parameters via CSET or autosave restore.

### 6.2 Step 2a — Unadjusted Offset (Integrator Core)

**C function:** `subIQphaseOffsU` — `rfApp/src/db/subIQ.c,v` (line 551)  
**EPICS record:** `$(S):$(C)LOAD:ANGLE:UNADOFFS`

**Cavity Strength — the regulated quantity:**

The outer loop tracks *cavity strength* as a proxy for voltage adequacy:

$$\text{STRENGTH} = \frac{\text{PROBE:AMPL}}{\text{STN:VOLT}} \times 100\%$$

- `PROBE:AMPL` = cavity probe signal amplitude (kV) — this cavity's individual field amplitude
- `STN:VOLT` = total station gap voltage sum across all cavities (kV)
- Output clamped to 0% when `STN:VOLT < 2 kV` (AB threshold hardwired as INPC=2 in `subIQpowerEff`)

`STRENGTH:CTRL` (ao, EGU=%, DRVH=100, PINI=YES) is the operator setpoint for desired strength percentage.  
`STRENGTH:DIFF` (ao, EGU=%, DRVH=100) is the integrator deadband — the integrator only steps when `|STRENGTH − STRENGTH:CTRL| > STRENGTH:DIFF`.

**Trigger mechanism:** `LOAD:ANGLE:UNADOFFS` is processed when the SNL sequencer writes PROC to `LOAD:ANGLE:UNADOFFS.PROC` (via the `phase_offset_proc` PV binding), after each successful inner-loop motor update and only when `station_state ≠ STATION_PARK` and `dmov_meas_count ≥ LOOP_DMOV_MEAS (=1)`.

**Gate logic — the function distinguishes two cases:**

*Integrator RESET (state cleared to zero) — ANY of:*
1. `CAVLOAD:ANGLE:CTRL` ≤ 0.5 (disabled by operator, INPA)
2. Station state ≠ ON_CW (INPD ≠ 4)
3. Beam has MINOR or MAJOR alarm: `STN:BEAM:STAT.SEVR` ∈ {1, 2} (`0.5 < C < 2.5`, INPC):
   - `STN:BEAM:STAT` is a `bi` record with `ZSV=MAJOR` — when beam is OFF, SEVR=2 (MAJOR)
   - `STN:BEAM:STATINP` computes: `beam_curr ≥ RF_CUTOFF ? ON(1) : OFF(0)` — when beam current falls below the RF cutoff threshold: value=0 → ZSV fires → alarm propagates → SEVR=2

*Integrator UPDATES — ALL of:*
4. The reset conditions above are false (loop enabled, station=ON_CW, beam not alarmed)
5. `CAVLDANGERR:SUMY:SEVR.SEVR` = 0 (all 4 cavity load angle errors valid, INPB):
   - `CAVLDANGERR:SUMY:SEVR` is a calc record in `rf_sumy_stn.db,v` with `CALC="0"` and four `NPP MS` inputs from `CAV1–CAV4 LOAD:ANGLE:ERR.SEVR`. The record's VAL is always 0, but its `.SEVR` field reflects the maximum alarm severity across all 4 cavities via EPICS alarm maximization (MS = maximize severity). When any cavity's load angle error record has MAJOR/INVALID alarm, this gate freezes the integrator, preventing a bad phase measurement from corrupting the voltage estimate.
6. Beam was healthy on the previous cycle (INPE holds prior `BEAM:STAT.SEVR`, checked < 0.5) — prevents integrator resuming immediately after beam recovery; waits one clean cycle
7. Cavity strength measurement valid (`STRENGTH.SEVR` < 2.5, INPH)
8. `|strength_error| > STRENGTH:DIFF` (deadband, INPI)

**Active conditions (all must be true):**
1. `CAVLOAD:ANGLE:CTRL` = 1 (enabled by operator, INPA)
2. Station state = `ON_CW` (=4, INPD)
3. Beam current healthy: `STN:BEAM:STAT.SEVR` ≤ 0.5 or ≥ 2.5 (INPC). Note: SEVR=1 (MINOR) or 2 (MAJOR) triggers a RESET; SEVR=3 (INVALID — PV disconnected) does not trigger reset but still gates the update via condition 6
4. `CAVLDANGERR:SUMY:SEVR.SEVR` = 0 all cavities' load angle errors are valid (INPB, see above)
5. Previous-cycle beam status was OK (INPE < 0.5) — one-cycle recovery hysteresis
6. `STRENGTH.SEVR` < 2.5 — strength measurement valid (INPH)
7. `|STRENGTH − STRENGTH:CTRL| > STRENGTH:DIFF` — error exceeds deadband (INPI)

**Calculation (pseudo-code):**

```c
strength_error = STRENGTH.VAL - STRENGTH:CTRL;  // actual − desired (%)
// (L = psub->g - psub->f)

if (NOT active_conditions):
    offset = 0.0;  // reset integrator
else if (all_valid AND |strength_error| > deadband):
    offset -= strength_error * K;   // integrator step
// Apply forgetting factor
offset *= forget;
// Hard-clip at ±180°
offset = clamp(offset, -180, +180);
```

**Mathematical form:**

$$\theta_{unadj}[n] = \text{forget} \cdot \left( \theta_{unadj}[n-1] - K \cdot e_s[n-1] \right)$$

where:
- $e_s = \text{STRENGTH} - \text{STRENGTH:CTRL}$ (cavity voltage strength error, %)
- $K$ = `CAVLOAD:ANGLE:K` (deg/%)
- $\text{forget}$ = `CAVLOAD:ANGLE:FORGET` (≤1, dimensionless)
- Update rate = 2 Hz (driven by CAVTUNR:LOOP:SEQ)

### 6.3 Step 2b — Total Load Angle Offset

**C function:** `subIQphaseOffs` — `rfApp/src/db/subIQ.c,v` (line 626)  
**EPICS record:** `$(S):$(C)LOAD:ANGLE:OFFS`

```c
psub->val = psub->d;                      // fixed offset (INPD, default 0)
if (psub->a > 0.5) psub->val += psub->b;  // + unadj_offset if enabled
psub->val = clamp(psub->val, psub->e, psub->c); // clip to [min,max]
```

$$\boxed{\theta_{offset} = \text{clamp}(D_{fixed} + \theta_{unadj},\; E_{min},\; C_{max})}$$

**Record inputs:**
- INPA = `CAVLOAD:ANGLE:CTRL` (enable flag)
- INPB = `LOAD:ANGLE:UNADOFFS` (integrator output)
- INPC = max offset bound (absent from deployed db — design value `#field(INPC,"10")` is commented out)
- INPD = fixed offset — **INPD is not present in the deployed `rf_cav.db,v` record definition; defaults to 0**
- INPE = min offset bound — absent from deployed record; defaults to 0

**Purpose of the fixed offset (INPD / $D_{fixed}$):** This term allows a permanent, operator-preset constant phase bias that is independent of the integrator. In PEP-II, this encoded a known optimal detuning derived from design parameters (beam current, synchronous phase, cavity voltage) or absorbed a systematic calibration offset between RF reference and cavity probe. It enabled operating the cavity at a deliberate, predetermined off-resonance angle without needing the integrator to converge there. In SPEAR3, `INPD` is not present in the database record definition and defaults to 0 — no fixed offset is applied in SPEAR3.

> **⚠ Configuration Gap:** Both `INPC` (max bound) and `INPE` (min bound) are absent from the `LOAD:ANGLE:OFFS` record in `rf_cav.db,v`. The design value for INPC is preserved as a comment: `#field(INPC,"10")`. With C=0 and E=0, the `clamp(val, E, C)` operation reduces to `clamp(val, 0, 0) = 0`, permanently forcing the output to zero regardless of what the integrator computes. In the deployed SPEAR3 database, `LOAD:ANGLE:OFFS` is always 0 and the outer voltage loop has no effect on the cavity error signal.
>
> The effective equation in deployed SPEAR3 is simply: $\theta_{offset} = 0$.
>
> This is almost certainly intentional: SPEAR3 has modest beam loading and operates well in pure resonance-seeking mode. However, it must be accounted for in any operational analysis or redesign that assumes the outer loop is active.

---

## 7. Algorithm 3 — Phase Error to Motor Position

### 7.1 Function

**C function:** `subIQphase2posn` — `rfApp/src/db/subIQ.c,v` (line 670)  
**EPICS record:** `$(S):$(C)TUNR:POSN:DELTA`

### 7.2 Calculation

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

$$\boxed{\Delta x = \text{clamp}\!\left(\epsilon \cdot \frac{\text{mm}}{\text{deg}} \cdot G_{loop},\; {-D},\; {+D}\right) \quad \text{if } |\epsilon| > B}$$

where:
- $\epsilon$ = `LOAD:ANGLE:ERR` (degrees)
- $\frac{\text{mm}}{\text{deg}}$ = C (conversion factor, design value 0.02 mm/°)
- $G_{loop}$ = `CAVTUNR:LOOP:GAIN` (operator scalar, 0–1)
- $D$ = maximum position delta per cycle (design value 1 mm)
- $B$ = deadband (design value 0.25°)

**Record inputs (INPA–INPG mapped to A–G):**

| Field | Variable | Link | Design Value | DB Status |
|---|---|---|---|---|
| INPA | A | `STN:STATE:RBCK` | station state | ✅ wired |
| INPB | B | — | 0.25° (deadband) | ❌ commented out |
| INPC | C | — | 0.02 mm/° | ❌ commented out |
| INPD | D | — | 1 mm (max delta) | ❌ commented out |
| INPE | E | `CAVTUNR:LOOP:GAIN` | 0–1 | ✅ wired |
| INPF | F | `LOAD:ANGLE:ERR` | degrees | ✅ wired |
| INPG | G | `FREQ:ERR` (PARK only) | degrees | ✅ wired (inactive) |

> **⚠ Configuration Gap:** INPB, INPC, INPD are all commented out in `rf_cav.db,v`. At startup these default to 0, rendering the conversion factor C=0 (→ delta always 0) and maxDelta D=0. Must be initialized via autosave or operator action.

**Output record:**

```epics
grecord(sub,"$(S):$(C)TUNR:POSN:DELTA") {
    ...
    field(EGU,"mm")
    field(HOPR,"2")
    field(LOPR,"-2")
    field(PREC,"3")
    field(BRSV,"INVALID")
}
```

The `HOPR/LOPR = ±2 mm` suggests the operational per-cycle position budget. Note the code-level max is INPD (design: 1 mm), and the SNL sequencer also clips to the motor drive range.

---

## 8. Algorithm 4 — Park Frequency Error (PEP-II Only, Disabled in SPEAR3)

### 8.1 Overview

These functions existed for PEP-II (a collider with two rings). In SPEAR3 they are present in the code but permanently disabled.

### 8.2 Frequency Offset Estimation

**C function:** `subSysFreqOff` — `rfApp/src/db/subSys.c,v` (line 116)  
**EPICS record:** `$(S):$(C):FREQ:OFFS`

Estimates cavity frequency offset from mechanical tuner position using a polynomial:

$$f_{offset}[kHz] = p_0 + p_1 \cdot \Delta x + p_2 \cdot \Delta x^2 + p_3 \cdot \Delta x^3 + t_1 \cdot V_{cav}^2$$

where $\Delta x = x_{current} - x_{home}$ (mm from home position).

Parameters (INPA–INPE = p0, p1, p2, p3, t1) stored in autosave, calibrated per cavity and thermal conditions. INPF = `TUNR:POSN:ONHOME`, INPG = `TUNR:POSN`, INPH = `PROBE:AMPL`.

The temperature coefficient $t_1$ accounts for cavity detuning due to RF heating (proportional to $V^2$).

### 8.3 Park Frequency Error

**C function:** `subSysFreqErr` — `rfApp/src/db/subSys.c,v` (line 147)  
**EPICS record:** `$(S):$(C):FREQ:ERR`

$$\text{FREQ:ERR [deg]} = \frac{90°}{4 f_{RF}} \cdot Q_L \cdot \Delta f$$

$$= 0.00004726891 \cdot Q_L \cdot (f_{desired} - f_{offset})$$

This converts a frequency error in kHz to a phase error in degrees, allowing the same `subIQphase2posn` to handle both the ON_CW (phase) and PARK (frequency) paths.

**Status in SPEAR3:**

```epics
# From rf_cav.db,v:
grecord(sub,"$(S):$(C):FREQ:ERR") {
    field(SNAM,"subSysFreqErr")
    field(INPA,"0.00004726891")   # 90/(476e3 × 4) deg/kHz ← constant, CORRECT
  # field(INPB,"7000")            # Q_L — COMMENTED OUT → B=0 → output always 0
    field(INPD,"$(S):$(C):FREQ:OFFS.VAL  NPP MS")  # frequency offset input
    ...
}
```

`INPB` (loaded cavity Q ≈ 7000) is commented out, so `FREQ:ERR` is always 0 regardless of frequency deviation. The park path is permanently disabled.

---

## 9. SNL Sequencer Logic

**Source:** `rfApp/src/rf_tuner_loop.st,v` (555 lines, 4 instances via `program rf_tuner_loop("CAV=1")` through `CAV=4`)

### 9.1 State Diagram

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
   │         loop_on       │  Main control state
   └───────────────────────┘
```

### 9.2 Key PV Bindings

The complete SNL variable and PV binding table is in §9.4. The most critical bindings for the control action are:

| SNL Variable | EPICS PV | Description |
|---|---|---|
| `posn_ctrl` | `$(S):CAV$(CAV)TUNR:POSN:CTRL` | **Motor position command** — the inner loop integrator state |
| `posn_delta` | `$(S):CAV$(CAV)TUNR:POSN:DELTA` | Position correction from IQA calc chain |
| `sm_posn` | `$(S):CAV$(CAV)TUNR:STEP:MOTOR.RBV` | Motor position readback (authoritative) |
| `sm_dmov` | `$(S):CAV$(CAV)TUNR:STEP:MOTOR.DMOV` | Done-moving flag (1=done) |
| `phase_offset_proc` | `$(S):CAV$(CAV)LOAD:ANGLE:UNADOFFS.PROC` | **Outer loop trigger — SNL writes PROC here** |
| `loop_ctrl` | `$(S):CAVTUNR:LOOP:CTRL` | Master enable |
| `loop_status` | `$(S):CAV$(CAV)TUNR:LOOP:STATUS` | Status output |

### 9.3 loop_on Logic (Active Control)

The `loop_on` SNL state contains two event-handler `when` blocks that together implement the control action. All the "TRACKING/MOVING/SETTLING" described in earlier drafts are handled within these two event handlers — there are no separate sub-states.

**Measurement accumulator (`when(efTest(meas_ready_ef))` — LOOPMEAS:READY event):**

```
meas_count++;                            // count measurement events
if (sm_dmov == SM_DONE_MOVING=1):
    dmov_meas_count++;                   // motor was idle: good measurement
else:
    dmov_meas_count = 0;                 // reset if motor was moving during measurements
```

**Main control action (`when(efTest(loop_ready_ef))` — LOOP:READY event, 2 Hz):**

After the 2 Hz LOOP:READY event fires, the sequencer evaluates status and acts:

1. **Guard checks** (in priority order):
   - If `loop_ctrl == OFF` → set `LOOP_OFF_STATUS`, pass through (no motor action)
   - If `meas_count == 0` → `LOOP_PHASMISS_STATUS` (IQA measurements not arriving)
   - If `sm_dmov != DONE` AND `nomov_count > LOOP_NOMOV_COUNT(=5)` → `LOOP_SM_MOVE_STATUS` alarm
   - If `station_state == ON_FM` → `LOOP_ON_FM_STATUS`, no action
   - If klystron power below minimum → `LOOP_LOW_STATUS`, skip this cycle

2. **Normal path (requires `dmov_meas_count ≥ LOOP_DMOV_MEAS = 1`):**
   ```
   pvGet(sm_posn)                              // read current motor position
   pvGet(posn_delta)                           // read phase→position result from IQA calc

   // MOTOR SANITY CHECK: Did the motor reach the last commanded position?
   if (|posn_ctrl − sm_posn| > sm_rdbd) AND (prev_loop_ctrl == LOOP_CONTROL_ON):
       loop_status = LOOP_SM_CTRL_STATUS       // motor missed previous target
       prev_loop_ctrl = LOOP_CONTROL_OFF       // suppress until loop is re-enabled

   // Compute new absolute target position
   posn_new = sm_posn + posn_delta             // integrate delta onto current position
   posn_new = clamp(posn_new, sm_drvl, sm_drvh) // enforce motor travel limits

   // Write only if position has changed or loop was just re-enabled
   if (posn_ctrl != posn_new) OR (prev_loop_ctrl != LOOP_CONTROL_ON):
       posn_ctrl = posn_new
       pvPut(posn_ctrl)                        // → FLNK chain → motor record
   prev_loop_ctrl = loop_ctrl
   ```

3. **Outer loop trigger** (coupling point between inner and outer loops):
   ```
   if (station_state != STATION_PARK) AND (dmov_meas_count >= LOOP_DMOV_MEAS):
       pvPut(phase_offset_proc)                // writes PROC to LOAD:ANGLE:UNADOFFS
                                               // → fires outer voltage integrator
   ```
   The outer integrator only executes after the inner loop has confirmed motor idleness (`DMOV=1`). This prevents the voltage integrator from running on a cycle where the motor is still in motion (i.e., the probe amplitude is still settling).

4. **Reset per-cycle counters:**
   ```
   dmov_meas_count = 0
   meas_count = 0
   ```

### 9.4 Complete SNL Variable and PV Binding Table

| SNL Variable | Type | EPICS PV | Role |
|---|---|---|---|
| `loop_ctrl` | int | `{STN}:CAVTUNR:LOOP:CTRL` | Master enable, monitored (bo) |
| `loop_state` | int | `{STN}:CAV{CAV}TUNR:LOOP:STATE` | Output: current SNL state code |
| `loop_status` | int | `{STN}:CAV{CAV}TUNR:LOOP:STATUS` | Output: status code |
| `loop_status_string_c` | string | `{STN}:CAV{CAV}TUNR:LOOP:STRING` | Output: human-readable status text |
| `station_state` | int | `{STN}:STN:STATE:RBCK` | Monitored, drives state branching |
| `posn_ctrl` | float | `{STN}:CAV{CAV}TUNR:POSN:CTRL` | **Integrating state — motor position command (mm)** |
| `posn_delta` | float | `{STN}:CAV{CAV}TUNR:POSN:DELTA` | Per-cycle position increment from IQA calc |
| `posn_new` | float | `{STN}:CAV{CAV}TUNR:POSN:LOOP` | Logged: newly computed target position |
| `posn` | float | `{STN}:CAV{CAV}TUNR:POSN` | Potentiometer position readback |
| `posn_on_home` | float | `{STN}:CAV{CAV}TUNR:POSN:ONHOME` | Home position for ON mode |
| `posn_park_home` | float | `{STN}:CAV{CAV}TUNR:POSN:PARKHOME` | Home position for PARK mode (PEP-II only) |
| `posn_mdel` | float | `{STN}:CAV{CAV}TUNR:POSN.MDEL` | Monitor delta (used as reset tolerance) |
| `sm_posn` | float | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.RBV` | **Motor encoder/step position readback (authoritative)** |
| `sm_dmov` | int | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.DMOV` | Done-moving flag (1=done), monitored |
| `sm_drvh` | float | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.DRVH` | Motor upper travel limit (+18 mm) |
| `sm_drvl` | float | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.DRVL` | Motor lower travel limit (−29.5 mm) |
| `sm_rdbd` | float | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.RDBD` | Retry deadband (0.015875 mm = 5 steps) |
| `phase_offset_proc` | int | `{STN}:CAV{CAV}LOAD:ANGLE:UNADOFFS.PROC` | **Outer loop trigger — SNL writes PROC here** |
| `load_angle_sevr` | int | `{STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR` | This cavity's load angle alarm severity |
| `klys_frwd_pwr` | float | `{STN}:KLYSOUTFRWD:POWER` | Klystron forward power (gate condition) |
| `klys_frwd_pwr_min` | float | `{STN}:KLYSOUTFRWD:POWER:MIN` | Minimum power threshold |
| `loop_ready` | int | `{STN}:CAVTUNR:LOOP:READY` | Station-wide 2 Hz event flag |
| `meas_ready` | int | `{STN}:CAV{CAV}TUNR:LOOPMEAS:READY` | Per-cavity measurement ready event flag |

**Internal counters (no PV binding — SNL local state only):**

| Variable | Purpose |
|---|---|
| `meas_count` | LOOPMEAS:READY events received since last LOOP:READY |
| `dmov_meas_count` | LOOP:READY cycles where motor was done-moving (`DMOV=1`) |
| `nomov_count` | Consecutive cycles where motor was still moving |
| `nonfunc_count` | Consecutive "bad" cycles (rate-limits alarm generation) |
| `reset_count` | Reset sequence attempt counter |
| `prev_loop_ctrl` | Previous `loop_ctrl` (detects enable/disable transitions, used in sanity check) |
| `prev_loop_status` | Previous status code (only logs/pvPuts on status change) |

### 9.5 Key Constants (from `rf_tuner_loop_defs.h,v`)

| Constant | Value | Description |
|---|---|---|
| `LOOP_DMOV_MEAS` | 1 | Minimum done-moving measurements before commanding motor |
| `LOOP_NOMOV_COUNT` | 5 | Consecutive stuck-motor cycles before alarm |
| `LOOP_NONFUNC_INTERVAL` | 1 | Consecutive bad cycles before NONFUNC alarm |
| `LOOP_RESET_COUNT` | 5 | Maximum reset attempts before giving up |
| `LOOP_MAX_DELAY` | 60 | Maximum startup wait (seconds) |
| `SM_DONE_MOVING` | 1 | Value of `sm_dmov` when motor has completed move |
| Loop period | 0.5 s | From 2 Hz SCAN rate |

**Status codes** (values 0–13, all from `rf_tuner_loop_defs.h,v`):

| Code | Name | Meaning |
|---|---|---|
| 0 | `LOOP_UNKNOWN_STATUS` | Initial / unresolved state |
| 1 | `LOOP_OFF_STATUS` | Loop disabled by operator |
| 2 | `LOOP_GOOD_STATUS` | Normal operation, motor updating |
| 3 | `LOOP_RESET_STATUS` | Performing motor reset sequence |
| 4 | `LOOP_HOME_STATUS` | Moving to home position |
| 5 | `LOOP_PHASMISS_STATUS` | No phase measurements arriving (IQA down) |
| 6 | `LOOP_SM_MOVE_STATUS` | Motor stuck or not completing moves |
| 7 | `LOOP_SM_CTRL_STATUS` | Motor missed last commanded position (sanity check) |
| 8 | `LOOP_ON_FM_STATUS` | Station in ON_FM transition state |
| 9 | `LOOP_LOW_STATUS` | Klystron power below minimum |
| 13 | `LOOP_LDANGLIM_STATUS` | Load angle error at limit |

### 9.6 State Variables and Persistent State

The following classification clarifies which variables carry memory (state) across loop cycles versus which are recomputed fresh each cycle:

**Control state variables (have persistent memory — the loop's "remembrance"):**

| Variable | PV | Memory type |
|---|---|---|
| `posn_ctrl` | `TUNR:POSN:CTRL` | **Inner loop integrator state.** Accumulates `posn_delta` increments each cycle. Represents the absolute motor position command. |
| `LOAD:ANGLE:UNADOFFS` | `CAV{N}LOAD:ANGLE:UNADOFFS` | **Outer loop integrator state.** Accumulates strength-error-based corrections with leaky forgetting. Stored in EPICS record `.VAL`. |

**SNL bookkeeping state (sequencer-internal memory):**

| Variable | Role |
|---|---|
| `loop_state` | Current SNL state code (init/off/reset/on) |
| `loop_status` | Last computed status code |
| `prev_loop_ctrl` | Loop enable value from previous cycle (edge detection + sanity check) |
| `prev_loop_status` | Last status code written to PV (change-detect to avoid unnecessary pvPuts) |
| `meas_count` | Measurement events accumulated since last main event |
| `dmov_meas_count` | Motor-idle measurement count (gating condition) |
| `nomov_count` | Consecutive non-idle cycles (alarms and resets if > LOOP_NOMOV_COUNT) |

**Measured/derived values (recomputed each cycle — no inherent memory):**

| Variable | Source | Notes |
|---|---|---|
| `posn_delta` | IQA calculation chain (`subIQphase2posn`) | Phase error → position increment |
| `sm_posn` | Motor record `.RBV` | Actual encoder/step position |
| `sm_dmov` | Motor record `.DMOV` | Done-moving hardware flag |
| `station_state` | `STN:STATE:RBCK` | Station state from top-level sequencer |
| `load_angle_sevr` | `LOAD:ANGLE:ERR.SEVR` | Alarm status for this cavity's phase error |
| `klys_frwd_pwr` | `KLYSOUTFRWD:POWER` | Klystron power for gate check |

---

## 10. Hardware Interface

### 10.1 Stepper Motor Record

**EPICS record type:** `steppermotor` (custom AB 1746-HSTP1 driver record)  
**Physical device (legacy):** Allen-Bradley 1746-HSTP1 stepper module  
**Physical device (current, Aug 2025 upgrade):** Galil DMC-4143 motion controller

**Motor parameters from `rf_cav.db,v`:**

```epics
grecord(steppermotor,"$(S):$(C)TUNR:STEP:MOTOR") {
    field(DTYP,"AB-1746HSTP1")
    field(OUT,"#L0 A2 C$(M) S0 @@0x8413 0x0010 500")
    field(DOL,"$(S):$(C)TUNR:POSN:CTRL.VAL  NPP NMS")  # position command
    field(OMSL,"closed_loop")
    field(ACCL,".5")          # acceleration: 0.5 mm/s²
    field(VELO,"3")           # velocity: 3 mm/s
    field(DIST,"0.003175")    # mm per step (= 1/400 rev × lead_screw_pitch)
    field(MODE,"Position")
    field(CMOD,"Position")
    field(MRES,"400")         # steps per revolution
    field(PREC,"3")
    field(EGU,"mm")
    field(DRVH,"18")          # upper drive limit: +18 mm
    field(DRVL,"-29.5")       # lower drive limit: -29.5 mm
    field(RDBD,"0.015875")    # retry deadband: 0.015875 mm (= 5 steps exactly)
}
```

### 10.2 Mechanism Specifications

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

### 10.3 Position Control and Initialization

The motor uses **absolute position mode**. On IOC startup:
1. `TUNR:STEP:CHCKINIT` verifies motor is initialized
2. `TUNR:STEP:INIT` sequence captures current hardware position → `TUNR:POSN:CTRL.IVAL` and `TUNR:POSN:CTRL`
3. Subsequent commands write to `TUNR:POSN:CTRL`, which FLNKs directly to the motor record

---

## 11. Complete Parameter Reference

### 11.1 Operator-Settable Parameters

These are `ao`/`bo` records in `rf_stn_cav.db,v`, shared across all cavities at station level (prefix `$(S):CAV`):

| PV (with prefix `SRF1:CAV`) | Type | EGU | DRVH | Default | Description |
|---|---|---|---|---|---|
| `TUNR:LOOP:CTRL` | bo | — | — | — | Master loop enable (0=off, 1=on) |
| `TUNR:LOOP:GAIN` | ao | — | 1 | autosave | Phase-to-position gain scalar (0–1) |
| `LOAD:ANGLE:K` | ao | deg/% | 1 | autosave | Integrator K constant |
| `LOAD:ANGLE:FORGET` | ao | — | 1 | autosave | Forgetting factor (≤1) |
| `LOAD:ANGLE:ERRMAX` | ao | deg | 180 | autosave | Max allowed load angle error |
| `LOAD:ANGLE:CTRL` | bo | — | — | autosave | Enable load angle offset integrator |
| `STRENGTH:CTRL` | ao | % | 100 | autosave | Desired cavity strength setpoint (%) |
| `STRENGTH:DIFF` | ao | % | 100 | autosave | Voltage integrator deadband: only updates when \|STRENGTH−CTRL\| > this value |}

### 11.2 Per-Cavity Parameters (rf_cav.db,v)

These are `ao` records with per-cavity scope (prefix `$(S):$(C)` = e.g., `SRF1:CAV1`):

| PV (relative, e.g., `SRF1:CAV1`) | Function | Default | Notes |
|---|---|---|---|
| `TUNR:POSN:ONHOME` | Home position for freq polynomial | autosave | Reference for `subSysFreqOff` |
| `TUNR:POSN:PARKHOME` | Park home position | autosave | PEP-II only |
| `LOAD:ANGLE:OFFS` | Total load angle offset (computed) | 0 | output of `subIQphaseOffs` |

### 11.3 Uninitialized Parameters (Require Autosave Restore)

The following inputs exist in the code but are commented out in the database. Their "design values" are documented in comments only:

| Sub Record | Input | Function | Design Value | Status in DB |
|---|---|---|---|---|
| `TUNR:POSN:DELTA` | INPB | Phase deadband (°) | 0.25 | `#field(INPB,"0.25")` — commented |
| `TUNR:POSN:DELTA` | INPC | mm per degree | 0.02 | `#field(INPC,"0.02")` — commented |
| `TUNR:POSN:DELTA` | INPD | Max delta per cycle (mm) | 1.0 | `#field(INPD,"1")` — commented |
| `LOAD:ANGLE:OFFS` | INPC | Max offset bound (°) | 10 | `#field(INPC,"10")` — commented |
| `FREQ:ERR` | INPB | Loaded cavity Q | 7000 | `#field(INPB,"7000")` — commented |

### 11.4 Physical Constants (Hardwired)

| Constant | Value | Location | Meaning |
|---|---|---|---|
| `90/(476e3 × 4)` | 0.00004726891 deg/kHz | `rf_cav.db,v`, FREQ:ERR INPA | Phase per unit frequency for f=476 MHz |
| RF frequency | 476 MHz | Implicit in above | SPEAR3 accelerating frequency |
| Stepper DIST | 0.003175 mm/step | `rf_cav.db,v` motor record | Linear resolution |
| Stepper MRES | 400 steps/rev | `rf_cav.db,v` motor record | Angular resolution |
| Stepper RDBD | 0.015875 mm | `rf_cav.db,v` motor record | 5-step retry deadband |
| Motor DRVH | +18 mm | `rf_cav.db,v` motor record | Upper travel limit |
| Motor DRVL | −29.5 mm | `rf_cav.db,v` motor record | Lower travel limit |
| Motor VELO | 3 mm/s | `rf_cav.db,v` motor record | Maximum velocity |
| Motor ACCL | 0.5 mm/s² | `rf_cav.db,v` motor record | Acceleration |

---

## 12. Control Loop Analysis

### 12.1 Loop Timing Budget

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

### 12.2 Open-Loop Gain (Proportional Path)

The linearized loop gain from phase error to stepper position change per cycle:

$$G_{OL} = C_{mm/deg} \cdot G_{loop} = 0.02 \; \frac{\text{mm}}{°} \cdot G_{loop}$$

In turn, a position change of $\Delta x$ mm changes cavity resonant frequency by:

$$\frac{df}{dx} \approx p_1 \quad [\text{kHz/mm}]$$

(the linear coefficient of the tuner polynomial, which is calibrated per cavity)

This frequency change modifies the cavity transfer phase — which closes the loop.

**Effective loop gain** (phase domain, per cycle with $G_{loop}=1$):

$$G_{eff} = C_{mm/deg} \cdot p_1 \cdot \frac{90°}{4 f_0} \cdot Q_L$$

For nominal values ($C = 0.02$ mm/°, $p_1 \approx 10$ kHz/mm, $Q_L \approx 7000$, $f_0 = 476$ MHz):

$$G_{eff} \approx 0.02 \times 10 \times 0.00004726891 \times 10^3 \times 7000 \approx 66$$

> **Note:** This is the single-cycle proportional gain. The 2 Hz rate and motor velocity limit prevent instability by severely band-limiting the loop. The `CAVTUNR:LOOP:GAIN` scalar (0–1) is critical for stability.

### 12.3 Integrator Dynamics (Load Angle Offset)

The load angle offset integrator (`subIQphaseOffsU`) is a **leaky first-order IIR integrator**:

$$\theta[n] = \text{forget} \cdot \left( \theta[n-1] - K \cdot e_s[n-1] \right)$$

where $e_s = \text{STRENGTH} - \text{STRENGTH:CTRL}$ (cavity voltage strength error, %, only applied when $|e_s| > \text{STRENGTH:DIFF}$).

**K gain (`CAVLOAD:ANGLE:K`, deg/%):** Controls the per-sample step size. A larger K produces a faster outer loop response but risks overshoot if the inner phase loop bandwidth is comparable. `DRVH=1` limits K ≤ 1 deg/%.

**Forgetting factor (`CAVLOAD:ANGLE:FORGET`, dimensionless, 0 < forget ≤ 1):** Makes the integrator leaky, giving it a finite DC gain and a natural decay time constant. With forget < 1:
- **DC gain**: $G_{DC} = -K/(1 - \text{forget})$ deg/% — the steady-state offset for a persistent unit strength error
- **Decay time constant**: $\tau = -T / \ln(\text{forget})$ where $T = 0.5\,\text{s}$
- If strength error disappears, the accumulated offset decays back to zero with time constant $\tau$

**Example time constants** (T = 0.5 s):

| `forget` | $\tau$ (seconds) | DC gain (K=1 deg/%) | Notes |
|---|---|---|---|
| 1.000 | ∞ (pure integrator) | ∞ | Integrator winds up indefinitely |
| 0.999 | ≈ 500 s (8.3 min) | −1000 deg/% | Very slow, high-gain |
| 0.990 | ≈ 50 s | −100 deg/% | Moderate — typical range |
| 0.900 | ≈ 4.7 s | −10 deg/% | Aggressive |

**Physical interpretation:** The forgetting factor prevents integrator windup when conditions are abnormal. If the beam is lost (integrator resets to 0) and then returns, the offset must re-converge from zero — the time to re-converge is set by $\tau$. With forget=0.99, recovery takes ~150–200 s to reach 95% of steady state.

> **Configuration note:** `CAVLOAD:ANGLE:K` and `CAVLOAD:ANGLE:FORGET` are `ao` records with `PINI=YES` but have no hardcoded default values in the database. On a fresh start without autosave restore files, both default to 0, which disables the integrator entirely.

**Bandwidth hierarchy:**
- Inner proportional loop bandwidth: ≈ 0.1–0.5 Hz (operator-tunable via `LOOP:GAIN`)
- Outer integrator loop bandwidth: ≈ 0.002–0.02 Hz (set by K and forget)
- Primary disturbance (beam loading): detuning ∝ $I_b$ — changes on seconds to minutes timescale during normal operation, well within inner loop tracking capability
- Secondary disturbance (thermal drift): ≈ 0.1–1 kHz/min — much slower than beam loading effects

### 12.4 Loop Bandwidth Estimate and Disturbance Rejection

With a 2 Hz sampling rate and the proportional gain scaled back by `LOOP:GAIN`:
- The inner proportional loop bandwidth is approximately 0.1–0.5 Hz (operator-tunable via GAIN)
- The outer integrator loop bandwidth is approximately 0.01 Hz (set by FORGET and K)

**Primary disturbance — beam loading:** The dominant source of cavity detuning is beam current. As beam is injected, decays, or is lost, the beam-induced detuning $\Delta f \propto I_b \sin\phi_s / V_{gap}$ shifts the cavity resonance. Under normal SPEAR3 operation (slow current decay, ~hours lifetime), the average detuning drift rate is slow enough for the 2 Hz loop to track. However, discrete events — injection bursts, fast beam loss — can shift detuning faster than the 0.5 s loop period.

**Secondary disturbance — thermal drift:** RF heating causes slow mechanical deformation of the cavity body, shifting resonant frequency on timescale of minutes to hours. Magnitude at SPEAR3 operating gradients is much smaller than beam loading. The inner loop easily handles this.

**Uncorrected disturbances:** Fast detuning transients (injection events, beam loss) and any detuning component with frequency > ~0.25 Hz will not be corrected by the 2 Hz inner loop. These manifest as transient phase errors that ring down over several loop cycles.

---

## 13. Identified Design Gaps and Observations

### 13.1 Uninitialized Feedforward Parameters

The three key parameters for `subIQphase2posn` (deadband B, conversion C, max-delta D) are commented out in the database. In a clean-startup scenario without autosave restore, these all default to 0, and:
- C=0 → no motor movement
- D=0 → output clamped to 0

**Impact:** The tuner is non-functional on a fresh start without autosave or operator initialization. This is a configuration management risk.

**Recommendation for upgrade:** Encode these parameters as EPICS ao records with PINI=YES and default values, rather than as commented-out constants in INP link fields.

### 13.2 Load Angle Offset Integration Not Functioning by Default

Similarly, the max/min bounds for `LOAD:ANGLE:OFFS` (subIQphaseOffs INPC) are commented out, and C=E=0 clips the output to zero. The integrator path is inoperative by default.

**Implication:** SPEAR3 operates in pure resonance-seeking mode unless the operator explicitly enables and configures the integrator. This is likely intentional for SPEAR3 (as opposed to PEP-II which had high beam loading requiring optimal detuning).

### 13.3 Implicit vs. Explicit Physics

The legacy system uses an implicit integrator to find the optimal detuning rather than computing it from first principles ($\psi_{opt} = \arctan(2Q_L \Delta\omega / \omega_0)$). This is robust but slower to converge.

**For the LLRF upgrade**, an explicit model-based computation of $\Delta f_{opt}$ from measured $I_b$, $V_{gap}$, and $\phi_s$ would be faster and more transparent. This is directly enabled by the LLRF9's digital signal processing capability.

### 13.4 No Feedforward for Beam Loading

Beam-loading-induced detuning is the **primary disturbance** the tuner must compensate (see §5.6). When stored beam current changes — during injection, beam decay, or loss events — the beam-induced detuning shifts by $\Delta f \propto \Delta I_b \sin\phi_s / V_{gap}$. In the current system, the only compensation path is the 2 Hz inner phase loop, which can only react after the detuning has already shifted (reactive control).

The outer voltage integrator was designed to find the optimal detuning setpoint implicitly by integrating cavity strength error, but in deployed SPEAR3 this path is inactive (§6.3). Even if it were active, its ~50 s time constant means it cannot respond to injection transients.

**There is no feedforward from beam current to detuning setpoint.** This leaves the cavity transiently detuned during injection and loss events, which broadens the beam energy distribution until the loop corrects.

**Upgrade opportunity:** Real-time detuning feedforward from DCCT beam current measurement:

$$\Delta f_{ff} = -\frac{f_0}{4 Q_L} \cdot \frac{I_b \sin\phi_s}{\pi V_{gap}}$$

This can be computed digitally in the LLRF9 with sub-millisecond latency, effectively eliminating the beam-loading detuning transient rather than waiting for the tuner to correct it reactively.

### 13.5 Motor Resolution vs. Phase Resolution

With C = 0.02 mm/°:
- 1 motor step (0.003175 mm) corresponds to: $0.003175 / 0.02 = 0.159°$ phase change
- RDBD (5 steps = 0.015875 mm) corresponds to: $0.015875 / 0.02 = 0.794°$ phase equivalent

For a loaded Q of ~7000, 0.159° corresponds to:
$$\Delta f = \frac{0.159°}{90°} \times \frac{f_0}{4 Q_L} = \frac{0.159}{90} \times \frac{476 \times 10^6}{4 \times 7000} \approx 95 \text{ Hz}$$

This is the minimum resolvable frequency correction per step. The Galil upgrade achieves sub-step positioning, improving this.

### 13.6 No State Estimation or Predictive Control

The legacy system is purely reactive — it responds to measured phase error with no prediction or model. The slow 2 Hz rate means disturbances with components above 1 Hz (including AC ripple, beam chopping) are not corrected.

### 13.7 Integrator Parameters Have No Default Values

`CAVLOAD:ANGLE:K` and `CAVLOAD:ANGLE:FORGET` are `ao` records with `PINI=YES` but include no hardcoded initial values in the database. On a fresh start without autosave restore files, both default to 0 — which silently disables the outer integrator loop without any error indication. An operator examining `LOAD:ANGLE:CTRL=1` might believe the outer loop is active when it is not.

**Recommendation for upgrade:** Define explicit, well-documented default values for K and FORGET as part of the control system configuration, with operator-visible documentation of their effect on loop dynamics.

### 13.8 Outer Loop Trigger is SNL-Mediated, Not Scan-Based

The outer voltage integrator (`LOAD:ANGLE:UNADOFFS`) is not directly driven by the 2 Hz scan record. It is triggered by the SNL sequencer writing PROC to `LOAD:ANGLE:UNADOFFS.PROC` after each inner-loop cycle — and only when `dmov_meas_count ≥ 1`. This means:

- If the SNL sequencer is not running (e.g., IOC restart, task crash), the outer loop silently freezes at its last computed value
- If the motor is persistently stuck (`DMOV=0` for all cycles), the outer loop also freezes — the `phase_offset_proc` write is gated on `dmov_meas_count`
- There is no fallback mechanism for the outer loop to execute independently of the inner loop

**Recommendation for upgrade:** Consider a more explicit outer loop architecture with independent scan and clear separation from the inner motor loop state.

---

## 14. Source Traceability Index

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
| Station-level tuner parameters | `rfApp/Db/rf_stn_cav.db,v` | `codeReviewTechnicalNotes/07-epics-databases.md` |
| PARK mode disabled evidence | `rf_cav.db,v` (`#field(INPB,"7000")`) | `codeReviewTechnicalNotes/05-snl-state-machines.md` |
| 2 Hz loop rate | `rf_stn_cav.db,v` (SCAN="2 second") | `rf_tuner_loop.st,v` (event-driven) |
| RF frequency (476 MHz) | `rf_cav.db,v` (INPA=0.00004726891) | Derived: 90/(476000×4) |
| Station state codes | `rfApp/src/db/rf_station_state.h,v` | `codeReviewTechnicalNotes/05-snl-state-machines.md` |
| Hardware replaced by Galil | `codeReviewTechnicalNotes/06-plc-stepper-motors.md` | PDR §10.3 (Aug 2025) |

---

## 15. Operational Summary: SPEAR3 As Deployed

**In SPEAR3 as deployed, the tuner operates exclusively in pure resonance-seeking mode:**

1. **Inner loop (active):** 2 Hz proportional phase controller. Error = `PROBE:PHASE.L − FRWD:PHASE.L`. Motor drives to nullify this error → cavity stays at resonance.

2. **Outer loop (structurally inactive):** The `LOAD:ANGLE:OFFS` output is clamped to 0 by missing INPC/INPE bounds. The voltage integrator (`UNADOFFS`) computes values but they are discarded. Absent autosave files or explicit operator CSET, the tuner cannot apply any intentional detuning.

3. **PARK mode (disabled):** Frequency-domain control path. Permanently disabled via commented-out `INPB` in `FREQ:ERR` record.

**To activate the outer voltage regulation loop, an operator must:**
- Set `CAVLOAD:ANGLE:CTRL = 1` (enable integrator)
- Configure `STRENGTH:CTRL` (desired voltage ratio %)
- Configure `STRENGTH:DIFF` (deadband %)
- Configure `LOAD:ANGLE:K` (gain, deg/%)
- Configure `LOAD:ANGLE:FORGET` (forgetting factor ≤ 1)
- Either restore `INPC` to `LOAD:ANGLE:OFFS` (max bound ≈ 10°) or provide equivalent constraints via autosave/CSET

Without this configuration, `LOAD:ANGLE:OFFS = 0` always, and the only control goal is resonance (zero phase difference between probe and forward).
