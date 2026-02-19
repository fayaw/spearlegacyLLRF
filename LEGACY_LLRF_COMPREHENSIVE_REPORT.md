# SPEAR Legacy LLRF Control System — Comprehensive Report

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [File-by-File Analysis](#3-file-by-file-analysis)
4. [Control Loop Deep Dive](#4-control-loop-deep-dive)
5. [Hardware Interfaces & Modules](#5-hardware-interfaces--modules)
6. [State Transition Diagrams](#6-state-transition-diagrams)
7. [PV Naming Conventions & Signal Flow](#7-pv-naming-conventions--signal-flow)
8. [Design Patterns for New Hardware](#8-design-patterns-for-new-hardware)
9. [Recommendations for Upgraded System](#9-recommendations-for-upgraded-system)

---

## 1. Executive Summary

This codebase implements the **Low-Level RF (LLRF) control system** originally designed for the **PEP-II (B-Factory) RF stations** at SLAC. The system is built on the **EPICS** (Experimental Physics and Industrial Control System) framework using **SNL** (State Notation Language) sequence programs that run on **VxWorks** real-time IOCs (Input/Output Controllers).

### Key Facts
| Attribute | Value |
|-----------|-------|
| **Language** | SNL (State Notation Language) → compiles to C |
| **Runtime** | VxWorks RTOS on VME-based IOCs |
| **Framework** | EPICS R3.14.x |
| **Communication** | Channel Access (CA) via Process Variables (PVs) |
| **Total Files** | 19 (6 `.st` sequences, 12 `.h` headers, 1 `Makefile`, 1 `.dbd`) |
| **Total Lines** | ~6,000+ lines of control logic |
| **Control Loops** | 3 primary feedback loops + 1 state machine + 1 calibration + 1 messaging |

### The Six Core Sequences

| Sequence | File | Purpose |
|----------|------|---------|
| `rf_dac_loop` | `rf_dac_loop.st` | DAC-based drive power & gap voltage control |
| `rf_hvps_loop` | `rf_hvps_loop.st` | High Voltage Power Supply voltage regulation |
| `rf_tuner_loop` | `rf_tuner_loop.st` | Cavity tuner stepper motor positioning |
| `rf_states` | `rf_states.st` | Master station state machine & loop coordination |
| `P2RF_Calib` | `rf_calib.st` | RF Processor octal DAC offset calibration |
| `rf_msgs` | `rf_msgs.st` | Event logging & LFB taxi error monitoring |

---

## 2. System Architecture Overview

### Block Diagram (Conceptual)

```
┌─────────────────────────────────────────────────────────────────────┐
│                         RF STATION IOC (VxWorks)                    │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │  rf_states   │  │  rf_msgs     │  │  rf_calib    │              │
│  │ (Master SM)  │  │ (Logging)    │  │ (Calibration)│              │
│  └──────┬───────┘  └──────────────┘  └──────────────┘              │
│         │ coordinates                                               │
│  ┌──────┴──────────────────────────────────────┐                   │
│  │                                              │                   │
│  ▼              ▼              ▼                 │                   │
│  ┌────────────┐ ┌────────────┐ ┌──────────────┐ │                   │
│  │rf_dac_loop │ │rf_hvps_loop│ │rf_tuner_loop │ │                   │
│  │(DAC Ctrl)  │ │(HVPS Ctrl) │ │(Tuner Ctrl)  │ │                   │
│  └─────┬──────┘ └─────┬──────┘ └──────┬───────┘ │                   │
│        │               │               │         │                   │
│  ┌─────┴───────────────┴───────────────┴─────────┘                  │
│  │              EPICS Channel Access (PVs)                          │
│  └──────────────────────┬───────────────────────────────────────────┘
│                         │
├─────────────────────────┼───────────────────────────────────────────┤
│   HARDWARE MODULES      │                                           │
│   ┌─────┐ ┌─────┐ ┌────┴──┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐     │
│   │ RFP │ │ GVF │ │ AIM   │ │CFM/ │ │IQA  │ │HVPS │ │Tuner│     │
│   │     │ │     │ │       │ │CF2  │ │1/2/3│ │     │ │(SM) │     │
│   └─────┘ └─────┘ └───────┘ └─────┘ └─────┘ └─────┘ └─────┘     │
│   RF Proc  Gap V   Intlck   Comb    IQ Anlz  HV PS   Stepper     │
│            Fdfwd   Module   Filter           Supply   Motors      │
└─────────────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │   KLYSTRON         │
                    │   → RF CAVITIES    │
                    │   → BEAM           │
                    └───────────────────┘
```

### Hierarchical Control Model

```
Level 3:  rf_states (Master) — Orchestrates station state transitions
              │
Level 2:  rf_dac_loop ─── rf_hvps_loop ─── rf_tuner_loop (Feedback Loops)
              │                │                  │
Level 1:  EPICS DB records, subroutine records, sequence records
              │                │                  │
Level 0:  VME Hardware — RFP, GVF, AIM, CFM, IQA, HVPS, Stepper Motors
```


---

## 3. File-by-File Analysis

### 3.1 Build System Files

#### `Makefile`
- **Purpose**: EPICS build system configuration for compiling SNL sequences into a VxWorks library
- **Library**: `rfSeq` (VxWorks IOC library)
- **Compiled Sequences**: `rf_tuner_loop.st`, `rf_hvps_loop.st`, `rf_states.st`, `rf_dac_loop.st`, `rf_calib.st`, `rf_msgs.st`
- **History**: Originally by Stephanie Allison, ported to EPICS R3.14.6 by M. Laznovsky (2005)
- **Key Detail**: Uses standard EPICS `$(TOP)/configure/CONFIG` and `$(TOP)/configure/RULES`

#### `rfSeq.dbd`
- **Purpose**: EPICS Database Definition file that registers all six SNL programs with the IOC
- **Registrars**: `P2RF_CalibRegistrar`, `rf_dac_loopRegistrar`, `rf_hvps_loopRegistrar`, `rf_statesRegistrar`, `rf_tuner_loopRegistrar`, `rf_msgsRegistrar`
- **Key Detail**: Each registrar allows the IOC startup script to instantiate the sequence programs

### 3.2 Shared Headers

#### `rf_loop_defs.h`
- **Purpose**: Common definitions shared by ALL control loop sequences
- **Contents**:
  - `LOOP_CONTROL_OFF (0)` / `LOOP_CONTROL_ON (1)` — universal loop on/off states
  - Macro name definitions for SNL macro substitution: `MACRO_TASK_NAME`, `MACRO_STN_NAME`, `MACRO_CAV_NAME`, `MACRO_RING_NAME`, `MACRO_REG_NAME`, `MACRO_IOC_NAME`
  - Includes `rf_station_state.h` for station state definitions (STATION_OFF, STATION_TUNE, STATION_ON_CW, etc.)
- **Relevance to New System**: These constants define the fundamental on/off semantics and naming patterns used across ALL loops

#### `rf_loop_macs.h`
- **Purpose**: Shared alarm severity checking macros used by all loops
- **Macros**:
  - `LOOP_INVALID_SEVERITY(sevr)` — returns true if severity >= INVALID_ALARM
  - `LOOP_MAJOR_SEVERITY(sevr)` — returns true if severity >= MAJOR_ALARM
  - `LOOP_MINOR_SEVERITY(sevr)` — returns true if severity >= MINOR_ALARM
- **Relevance to New System**: Critical pattern — all loops use alarm severity to determine if a measurement is trustworthy before acting on it

### 3.3 DAC Loop Files

#### `rf_dac_loop_defs.h`
- **Purpose**: Constants specific to the DAC feedback loop
- **Key Constants**:
  - `DAC_LOOP_MAX_INTERVAL = 10.0` — maximum seconds between loop iterations (heartbeat)
  - `DAC_LOOP_MAX_COUNTS = 2047` — DAC full scale (12-bit, 0–2047)
  - `DAC_LOOP_MIN_DELTA_COUNTS = 0.5` — dead band for DAC changes
- **Status Codes** (15 states): UNKNOWN, TUNE, ON, TUNE_OFF, ON_OFF, DRIV_BAD, GAPV_BAD, CTRL, STN_OFF, RFP_BAD, DAC_LIMT, GVF_BAD, DRIV_HIGH, DRIV_TOL, GAPV_TOL
- **Each status has a human-readable string** for operator display

#### `rf_dac_loop_pvs.h`
- **Purpose**: Declares all EPICS Process Variables (PVs) used by the DAC loop
- **Key PVs** (41 PVs total):
  - **Station state**: `{STN}:STN:STATE:RBCK` — monitored to know current operating mode
  - **Control inputs**: `{STN}:STN:TUNE:CTRL`, `{STN}:STN:ON:CTRL` — loop enable/disable
  - **Readiness signals**: `{STN}:STNDAC:LOOP:READY`, `{STN}:STNRIPPLE:LOOP:READY`
  - **Phase measurement**: `{STN}:STN:PHASE:CALC` — phase angle from RF processor
  - **Direct/Comb loop values**: amplitude and phase setpoints for RFP DAC updates
  - **DAC count values**: `{STN}:STN:TUNE:IQ.A`, `{STN}:STN:ON:IQ.A`, `{STN}:STN:GFF:IQ.A`
  - **Delta calculations**: `{STN}:KLYSDRIVFRWD:DAC:DELTA`, `{STN}:STNVOLT:DAC:DELTA`, etc.
  - **Error monitoring**: `{STN}:STN:VOLT:ERR.STAT`, `{STN}:KLYSDRIVFRWD:POWER:ERR.STAT`
- **Event Flags**: `loop_ready_ef`, `ripple_loop_ready_ef`, `ripple_loop_ampl_ef`, `phase_ef`, `rfp_dac_ef`

#### `rf_dac_loop_macs.h`
- **Purpose**: Core control algorithm macros for the DAC loop
- **Key Macros**:
  - `DAC_LOOP_GET_STATUS()` — determines status from pvGet return code and severity
  - `DAC_LOOP_OFF()` — sets loop to station-off status
  - `DAC_LOOP_CHANGE()` — clears event flags and resets previous control states on state transitions
  - `DAC_LOOP_SET()` — **THE CORE CONTROL ALGORITHM** — reads current counts, calculates new DAC value, applies limits, checks tolerance, puts new value
  - `DAC_LOOP_CHECK_STATUS()` — updates status string if status changed, logs critical errors

#### `rf_dac_loop.st`
- **Purpose**: Main DAC loop state sequence — controls drive power and gap voltage
- **Author**: Stephanie Allison (29-May-1997)
- **Program Line**: `program rf_dac_loop("STN=RRRS,name=DACLOOP")`
- **Options**: `-a` (synchronous pvGets), `+c` (wait for all connections)
- **States**: `loop_init` → `loop_off` → `loop_tune` / `loop_on`
- **Detailed state behavior** — see Section 4.1

### 3.4 HVPS Loop Files

#### `rf_hvps_loop_defs.h`
- **Purpose**: Constants specific to the HVPS feedback loop
- **Key Constants**:
  - `HVPS_LOOP_MAX_INTERVAL = 10.0` — heartbeat interval
  - `HVPS_LOOP_MAX_VOLT_TOL = 10` — number of tolerance violations before status change
  - Control modes: OFF(0), PROC(1), ON(2)
- **Status Codes** (16 states): UNKNOWN, GOOD, RFP_BAD, CAVV_LIM, OFF, VACM_BAD, POWR_BAD, GAPV_BAD, GAPV_TOL, VOLT_LIM, STN_OFF, VOLT_TOL, VOLT_BAD, DRIV_BAD, ON_FM, DRIV_TOL

#### `rf_hvps_loop_pvs.h`
- **Purpose**: HVPS loop PV declarations
- **Key PVs** (~35 PVs):
  - **HVPS voltage control**: `{STN}:HVPS:VOLT:CTRL` (set), `{STN}:HVPS:VOLT` (readback)
  - **Limits**: `{STN}:HVPS:VOLT:MIN`, `{STN}:HVPS:VOLT:CTRL.DRVH` (max)
  - **Delta voltages**: `{STN}:HVPS:LOOP:VOLTDOWN` (proc decrease), `{STN}:HVPS:LOOP:VOLTUP` (proc increase), `{STN}:KLYSDRIVFRWD:HVPS:DELTA` (on delta), `{STN}:STNVOLT:HVPS:DELTA` (tune delta)
  - **Safety monitors**: klystron forward power (+ max limit), cavity vacuum severity, gap voltage severity, gap voltage check

#### `rf_hvps_loop_macs.h`
- **Purpose**: HVPS control algorithm macros
- **Key Macros**:
  - `HVPS_LOOP_SET_VOLTAGE()` — **CORE HVPS ALGORITHM**: reads current voltage, adds delta, applies min/max limits, checks readback-vs-requested tolerance, puts new value, updates history
  - `HVPS_LOOP_CHECK_STATUS()` — updates status string, resets voltage history on transitions from OFF

#### `rf_hvps_loop.st`
- **Purpose**: HVPS voltage regulation state sequence
- **Author**: Mike Zelazny (03-Feb-1997)
- **Program Line**: `program rf_hvps_loop ("name=HVPSLOOP")`
- **States**: `init` → `off` → `proc` / `on`
- **Detailed state behavior** — see Section 4.2

### 3.5 Tuner Loop Files

#### `rf_tuner_loop_defs.h`
- **Purpose**: Constants for the cavity tuner stepper motor control
- **Key Constants**:
  - `LOOP_MAX_DELAY = 60.0` — max seconds between cycles
  - `LOOP_NONFUNC_INTERVAL = 1` — missed beats before nonfunctional
  - `LOOP_DMOV_MEAS = 1` — measurements required after motor done moving
  - `LOOP_NOMOV_COUNT = 5` — stuck motor detection threshold
  - `LOOP_RESET_COUNT = 5` — home position reset attempts
  - `LOOP_MOVE_COUNT = 100` — wait-for-done-moving iterations
- **Status Codes** (14 states): UNKNOWN, OFF, STN_OFF, GOOD, ON_FM, SM_CTRL, SM_LIMIT, SM_BAD, DRV_LIMT, SM_MOVE, PHAS_BAD, PHASMISS, POWR_LOW, LDANGLIM

#### `rf_tuner_loop_pvs.h`
- **Purpose**: Tuner loop PV declarations — note `{CAV}` macro for per-cavity instances
- **Key PVs** (~35 PVs):
  - **Loop control**: `{STN}:CAVTUNR:LOOP:CTRL` — shared enable across cavities
  - **Per-cavity reset/home**: `{STN}:CAV{CAV}TUNR:LOOP:RESET`, `:LOOP:HOME`
  - **Reset mode selectors**: ON reset vs PARK reset (separate PVs)
  - **Position PVs**: `POSN:CTRL` (command), `POSN` (potentiometer readback), `POSN:LOOP` (loop output), `POSN:DELTA` (calculated change)
  - **Stepper motor**: `.RBV` (readback), `.DRVH/.DRVL` (limits), `.DMOV` (done moving), `.RDBD` (deadband)
  - **RF measurements**: klystron forward power and minimum threshold
  - **Load angle error**: `{STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR`

#### `rf_tuner_loop_macs.h`
- **Purpose**: Tuner loop control macros
- **Key Macros**:
  - `TUNER_LOOP_POSN_STATUS()` — determines position status from severity and alarm type (HW_LIMIT_ALARM detection)
  - `TUNER_LOOP_DELTA_STATUS()` — validates delta measurement quality
  - `TUNER_LOOP_LDANG_STATUS()` — checks load angle severity
  - `TUNER_LOOP_STATE_UPDATE()` — updates state, status, clears home flags, optionally triggers reset
  - `TUNER_LOOP_INIT_FLAGS()` — clears all measurement and movement counters
  - `TUNER_LOOP_HOME()` — sets home position from current potentiometer reading

#### `rf_tuner_loop.st`
- **Purpose**: Cavity tuner position control sequence
- **Author**: Stephanie Allison (31-Oct-1996)
- **Program Line**: `program rf_tuner_loop("STN=RRRS,CAV=X,name=CXTUNRLOOP")`
- **Options**: `+r` (reentrant — one instance per cavity!), `-a`, `+c`
- **States**: `loop_init` → `loop_unknown` → `loop_reset` / `loop_off` / `loop_on`
- **Detailed state behavior** — see Section 4.3

### 3.6 Station State Machine

#### `rf_states.st`
- **Purpose**: Master state machine controlling the entire RF station — **THE MOST COMPLEX FILE** (~2227 lines)
- **Authors**: Robert C. Sass, Stephanie Allison, M. Laznovsky (1997-2004)
- **Program Line**: `program rf_states ("name=tRFSTATES,STN=barfonthis")`
- **Contains 3 sub-sequences**:
  1. `rf_states` — main station state transitions (OFF, PARK, TUNE, ON_FM, ON_CW)
  2. `rf_statesLP` — loop transition management (direct, comb, GFF, LFB, lead/integral compensation)
  3. `rf_statesFF` — fault file data collection after station faults
- **Detailed state behavior** — see Section 4.4

### 3.7 Calibration Sequence

#### `rf_calib.st`
- **Purpose**: Automated calibration of RF Processor octal DAC offsets — **THE LARGEST FILE** (3345 lines)
- **Authors**: R. Claus, P. Corredoura, M. Laznovsky (1997-2005)
- **Program Line**: `program P2RF_Calib ("STN=RRRS")`
- **What it calibrates** (in order):
  1. Comb module presence check
  2. Hardware state initialization (save/restore)
  3. Cavity multiplier weight offset nulling (per cavity × 4 coefficients)
  4. Cavity output offset nulling
  5. Direct loop coefficient and control offsets
  6. Comb loop coefficient and control offsets
  7. Sum node offsets
  8. Gain stage offsets (per cavity)
  9. Klystron modulator offsets
  10. RF modulator offsets
  11. Compensation stage offsets
  12. Difference node offsets
  13. Klystron demodulator offsets
  14. Tune setpoint offsets
- **Algorithm**: Iterative binary search with convergence checking — adjusts DAC values, reads I/Q data from hardware RAM, computes average offset, narrows search bounds
- **Direct hardware access**: Uses `P2RF_CopyMemory()`, `P2RF_WriteVme()`, `P2RF_AvgOffset()` functions

### 3.8 Message/Monitoring Sequence

#### `rf_msgs.st`
- **Purpose**: Event logging and specialized fault monitoring
- **Author**: Stephanie Allison (27-Mar-1997)
- **Program Line**: `program rf_msgs ("name=tRFMSGS,STN=RRRS")`
- **Contains 2 sub-sequences**:
  1. `rf_msgs` — logs: trip resets, filament bypass/on/off, station online/offline, HVPS faults (12KV, ENERFAST, ENERSLOW, SUPPLY, SCR1, SCR2). Also opens HVPS contactor on filament fault.
  2. `rf_msgsTAXI` — monitors GVF module taxi error bit, sends LFB resync when detected. Uses random delay (0.5–4s) to prevent multiple IOCs from racing.


---

## 4. Control Loop Deep Dive

### 4.1 DAC Loop (`rf_dac_loop.st`)

#### Purpose
Adjusts the amplitude (in DAC counts) of either the **tune-mode setpoint** or the **difference node offset RFP DAC values** or the **gap feed-forward reference values**. It uses an error-based delta calculation computed in the EPICS database to incrementally adjust the previous DAC count value.

#### State Machine

```
     ┌──────────┐
     │loop_init │  Initialize all variables, clear event flags
     └────┬─────┘
          │
     ┌────▼─────┐
     │ loop_off │◄─── Station is OFF, PARK, or ON_FM
     └──┬───┬───┘     Updates RFP DACs on phase/amplitude changes
        │   │          Loads ripple loop amplitude on changes
        │   │
   TUNE │   │ ON_CW (with configurable delay)
        │   │
   ┌────▼───┘──┐       ┌──────────┐
   │ loop_tune │       │ loop_on  │
   └───────────┘       └──────────┘
   Drive power via     Gap voltage or drive power depending on:
   RFP tune DACs       - direct_loop ON/OFF
                       - GVF module available/unavailable
```

#### Control Algorithm (`DAC_LOOP_SET` macro)

```
1. CHECK: Is RF processor offline? → STATUS = RFP_BAD, exit
2. IF control is OFF:
   a. Update RFP DACs only on phase changes
   b. Set status based on tolerance severity
3. IF control is ON:
   a. pvGet current count value
   b. pvGet delta count (error-proportional correction)
   c. CHECK measurement validity → STATUS = BAD if invalid
   d. CHECK if drive too high AND gap voltage bad → STATUS = DRIV_HIGH
   e. CHECK if DAC was changed externally (count_diff check) → STATUS = CTRL
   f. CALCULATE: new_counts = old_counts + delta_counts
   g. CLAMP to [0, 2047] → STATUS = DAC_LIMT if clamped
   h. CHECK tolerance → STATUS = TOL if out of tolerance
   i. pvPut new counts ONLY IF:
      - Phase changed, OR
      - Control mode changed, OR
      - Delta exceeds deadband (±0.5 counts)
```

#### Loop Behavior in ON_CW (Most Complex)

The DAC loop behavior in ON_CW depends on TWO conditions:

| Direct Loop | GVF Module | What Gets Controlled | Which DACs |
|-------------|------------|---------------------|------------|
| OFF | Bad (invalid) | Drive power | RFP on_counts (`{STN}:STN:ON:IQ.A`) |
| OFF | Good | Drive power | GFF gff_counts (`{STN}:STN:GFF:IQ.A`) |
| ON | Bad (invalid) | Gap voltage | RFP on_counts (`{STN}:STN:ON:IQ.A`) |
| ON | Good | Gap voltage | GFF gff_counts (`{STN}:STN:GFF:IQ.A`) |

#### Timing
- Event-driven: Triggers on `loop_ready_ef` (set by external timing)
- Fallback: 10-second maximum interval heartbeat
- Ripple loop amplitude updates at a slower rate (separate `ripple_loop_ready_ef`)

---

### 4.2 HVPS Loop (`rf_hvps_loop.st`)

#### Purpose
Controls the **High Voltage Power Supply** that feeds the klystron. Two main functions:
1. **PROCESS mode**: Slowly ramp HVPS voltage up/down while the vacuum system conditions the cavity
2. **ON mode**: Maintain constant klystron drive power or station gap voltage by adjusting HVPS voltage

#### State Machine

```
     ┌───────┐
     │ init  │  Set initial voltage from readback, status = STN_OFF
     └───┬───┘
         │
     ┌───▼───┐
     │  off  │◄─── Station is OFF or PARKed
     └─┬───┬─┘     Waits for station to leave OFF/PARK
       │   │
  PROC │   │ other (with configurable delay for fast turnon)
       │   │
  ┌────▼───┘──┐       ┌────────┐
  │   proc    │◄─────►│   on   │  (can transition between proc and on)
  └───────────┘       └────────┘
  Ramp voltage         Maintain drive power or gap voltage
  based on vacuum,     based on error delta calculations
  power, gap checks
```

#### PROC Mode Algorithm (Cavity Processing)

```
Priority-ordered safety checks:
1. RFP module online?                → RFP_BAD
2. Klystron forward power valid?     → POWR_BAD
3. Gap voltage valid?                → GAPV_BAD
4. Cavity vacuums OK?               → VACM_BAD
5. HVPS voltage reading out?         → VOLT_BAD

If all OK:
  IF (klys_power > max) OR (gap_voltage > limit) OR (vacuum too high):
    delta = delta_proc_voltage_down  (decrease)
  ELSE:
    delta = delta_proc_voltage_up    (increase)
  
  APPLY: HVPS_LOOP_SET_VOLTAGE()
```

#### ON Mode Algorithm (Steady-State Control)

```
Priority-ordered checks:
1. RFP module online?                          → RFP_BAD
2. Station in ON_FM?                           → ON_FM (no control)
3. HVPS control off?                           → OFF (track readback)
4. HVPS voltage valid?                         → VOLT_BAD
5. Drive power valid? (ON_CW + direct loop)    → DRIV_BAD
6. Gap voltage valid?                          → GAPV_BAD

If all OK:
  IF (ON_CW AND direct_loop ON):
    delta = -delta_on_voltage (from KLYSDRIVFRWD:HVPS:DELTA subroutine record)
  ELSE:
    delta = delta_tune_voltage (from STNVOLT:HVPS:DELTA subroutine record)
  
  IF (cavity_voltage above max AND increasing):
    → CAVV_LIM (don't apply delta)
  ELSE:
    APPLY: HVPS_LOOP_SET_VOLTAGE()
  
  Check out-of-tolerance conditions after delta applied
```

#### Voltage Limiting (`HVPS_LOOP_SET_VOLTAGE`)

```
1. Read current requested_hvps_voltage
2. Add delta
3. CLAMP to [min_hvps_voltage, max_hvps_voltage]
4. CHECK readback vs previous request:
   IF |readback - prev_requested| > allowed_diff:
     → Don't update (voltage not tracking)
     → Increment tolerance counter
     → After 10 failures: VOLT_TOL status
5. Write new voltage
6. Update history PV
```

---

### 4.3 Tuner Loop (`rf_tuner_loop.st`)

#### Purpose
Moves the **cavity tuner** (stepper motor-driven) based on RF phase/load angle measurements. The tuner adjusts the cavity resonant frequency to maintain optimal coupling. One instance runs per cavity (`+r` reentrant option).

#### State Machine

```
     ┌───────────┐
     │ loop_init │  Get task name, set UNKNOWN, clear all flags
     └─────┬─────┘
           │
     ┌─────▼─────┐
     │loop_unknown│  Determine initial state (ON or OFF)
     └──┬─────┬──┘   Wait for loop_ready or timeout (60s)
        │     │
    ON? │     │ default
        │     │
   ┌────▼─┐ ┌─▼──────┐
   │loop_ │ │loop_   │
   │on    │ │off     │   ← Station OFF: process home/reset requests
   └──┬───┘ └────────┘
      │
      │◄── loop_reset (go-home sequence)
      │
   Main control loop:
   - Count fresh measurements
   - Process go-home and set-home buttons
   - Calculate new stepper motor position
   - Apply drive limits
   - Check position control status
```

#### Reset (Home) Algorithm

```
1. Get target position (on_home or park_home depending on state)
2. Get position monitor-delta (deadband) × LOOP_RESET_TOLS (factor of 2)
3. FOR reset_count = 0 to LOOP_RESET_COUNT (5 attempts):
   a. Wait between attempts (LOOP_RESET_DELAY = 60 ticks)
   b. Verify: stepper motor done moving AND valid position readings
   c. Calculate: posn_delta = target - current_position
   d. IF |delta| < tolerance: DONE
   e. ELSE: command stepper = SM_position + delta
   f. Wait for stepper to stop (up to LOOP_MOVE_COUNT × LOOP_MOVE_DELAY)
```

#### ON State Control Algorithm

```
Each loop_ready cycle:
1. IF control OFF:  → LOOP_OFF_STATUS
2. IF no measurements received: → PHASMISS_STATUS (measurement system failure)
3. IF stepper stuck (not done moving for NOMOV_COUNT cycles): → SM_MOVE_STATUS
4. IF not enough measurements since motor stopped: → SM_MOVE_STATUS
5. IF station ON_FM: → ON_FM_STATUS (no tuning in FM mode)

6. Otherwise (nominal operation):
   a. pvGet(posn_delta)  — the error signal computed in EPICS database
   b. Validate delta measurement quality → PHAS_BAD if invalid
   c. Check klystron power adequate → POWR_LOW if bad/too low
   d. IF enough measurements after motor stop:
      i.  pvGet(sm_posn) — current stepper motor position
      ii. Check stepper status (HW_LIMIT, bad severity, etc.)
      iii. Check load angle within limits → LDANGLIM_STATUS
      iv. Calculate: posn_new = sm_posn + posn_delta
      v.  CLAMP to [sm_drvl, sm_drvh] → DRV_LIMT_STATUS
      vi. Check if stepper isn't at commanded position → SM_CTRL_STATUS
      vii. pvPut(posn_ctrl) = posn_new  (command the motor)
   e. Process phase offset if not PARK and measurements complete
```

#### Key Design Feature: Dual Position Sensing
The tuner uses BOTH:
- **Potentiometer** (`POSN`) — absolute position reference
- **Stepper motor encoder** (`STEP:MOTOR.RBV`) — for precise incremental positioning

The reset algorithm bridges these two by calculating the difference and commanding the stepper.

---

### 4.4 Station State Machine (`rf_states.st`)

#### Purpose
The master orchestrator that controls the entire RF station's operational state. Manages transitions between operational modes, coordinates all sub-loops, handles faults, and manages automatic recovery.

#### Legal State Transition Matrix

```
 From\To   OFF    PARK   TUNE   ON_FM  ON_CW
 ────────  ─────  ─────  ─────  ─────  ─────
 OFF              YES    YES    YES    YES
 PARK       YES
 TUNE       YES                        YES
 ON_FM      YES          YES
 ON_CW      YES          YES
```

#### Sub-Sequence 1: `rf_states` (Main State Machine)

**States**: `s_init`, `s_off`, `s_park`, `s_tune`, `s_on_fm`, `s_on_cw` + transition states

**"Go" Transition States** (where the actual work happens):

| State | Actions |
|-------|---------|
| `s_go_off` | Ramp HVPS down → triggers OFF → logs fault files if needed |
| `s_go_park` | DACs off → park tuners → reset beam abort |
| `s_go_tune` | TUNE mode → zero operate/GFF IQ → HVPS on |
| `s_go_on_fm` | Load I/Q files (400Hz or 1kHz) → DACs on → continuous RF → operate mode → HVPS on |
| `s_go_on_cw` | **Most complex** — two paths: Normal or Fast Turnon |
| `s_go_tune_to_on_cw` | DACs off → reset/load/run → set IQ reference → operate mode |
| `go_on_cw_to_tune` | TUNE mode → direct loop off → zero GFF/operate IQ |
| `s_go_stn_reset` | Automatic fault reset with retry counting |

**Fast Turnon Sequence** (s_go_on_cw with direct loop ON and fast turnon enabled):
1. Home cavities and reset comb filters
2. Preload gap I/Q reference (selection 3)
3. Direct loop ON (leave gain as-is)
4. Integral compensation ON (if enabled)
5. Lead compensation ON (if enabled)
6. Comb loop ON (if enabled)
7. Set operate mode, RF ON
8. Set HVPS to fast turnon voltage
9. HVPS triggers ON, AIM HVPS ON
10. GFF loop ON, LFB loop ON
11. Set continuous RF
12. Reset beam abort

#### Sub-Sequence 2: `rf_statesLP` (Loop Transitions)

Manages the complex sequencing required to safely turn control loops on and off:

**States**: `s_lp_check`, `s_gv_down`, `s_direct_ramp`, `s_comb_ramp`, `s_gv_up`

**Direct Loop ON Sequence**:
```
s_lp_check → s_gv_down → s_direct_ramp → (s_comb_ramp) → s_lp_check → s_gv_up → s_lp_check
```

1. `s_gv_down`: Execute direct loop transition sequence (lower gap voltage and drive power), force beam abort
2. Wait `volt_settle_time` for gap voltage to decrease
3. `s_direct_ramp`: Turn direct loop ON, set IQ reference (selection 2), get initial gain offset
   - Ramp gain: increment by `directlpgaindelta` until offset reaches 0
   - Turn lead compensation ON
   - Turn integral compensation ON
4. `s_comb_ramp`: Turn comb loop ON, ramp gain similarly
5. `s_gv_up`: Restore gap voltage and gains
   - Wait for gap voltage within tolerance OR MAX_GV_UP_WAIT (30s)
   - Restore drive power
   - Reset beam abort

**Safety Constraint**: Once direct loop is ON and beam abort is reset, the direct loop CANNOT be turned off without first taking the station out of ON_CW.

#### Sub-Sequence 3: `rf_statesFF` (Fault Files)

Triggered after a station fault to capture diagnostic data:
1. Increment fault number (circular 1–15)
2. Record timestamp
3. Set RFP, CFM, GVF modules to LOAD state
4. For each module (up to 11 files): save current filename/size, set fault filename/size, trigger data collection
5. Wait for all to complete (max 180 iterations × ~0.33s = 60s)
6. Restore original filenames and sizes
7. Restore module states to RUN


---

## 5. Hardware Interfaces & Modules

### Module Summary

| Module | Abbrev | PV Prefix | Function |
|--------|--------|-----------|----------|
| RF Processor | RFP | `{STN}:STN:RFP:` | Core digital signal processing: I/Q modulation/demodulation, DAC control, memory buffers, direct/comb loop hardware |
| Gap Voltage Feed-Forward | GVF | `{STN}:STN:GVF:` | Gap voltage feed-forward reference (I/Q), LFB woofer loop, taxi error monitoring |
| AIM (Accelerator Interface Module) | AIM | `{STN}:STN:AIM:` | HVPS permissive, beam abort control, fault reset, filament control |
| Comb Filter Module (legacy) | CFM1/CFM2 | `{STN}:STN:CFM1:`, `{STN}:STN:CFM2:` | Comb filtering for coupled-bunch instability suppression |
| Comb Filter v2 | CF2 | `{STN}:STN:CF2:` | Replacement comb filter with I/Q history buffers |
| IQ Analyzer | IQA1/IQA2/IQA3 | `{STN}:STN:IQA1:`, etc. | Signal analysis, amplitude history buffers |
| HVPS | - | `{STN}:HVPS:` | High voltage power supply control, voltage readback, triggers, contactor |
| Cavity Tuner | - | `{STN}:CAV{CAV}TUNR:` | Stepper motor, potentiometer, position control |
| Klystron | - | `{STN}:KLYS*:` | Forward power, drive power, output monitoring |

### RFP Module Key Fields

| Field | Description | Used By |
|-------|-------------|---------|
| `.SEVR` | Module severity | All loops (health check) |
| `.DLE` | Direct Loop Enable | DAC loop, HVPS loop |
| `.RFENABLE` | RF switch on/off | rf_states |
| `.AMSP` | Amplitude setpoint | rf_calib |
| `.LOD` | Load octal DACs | rf_calib |
| `.DLOD` | Load quad DACs | rf_calib |
| `.LDIR/.LDQR` | Load I/Q files | rf_states (ON_FM) |
| `.DIRF/.DQRF` | I/Q file paths | rf_states (ON_FM) |
| `.SIRF/.SQRF/.CIRF/.CQRF` | Fault data files | rf_statesFF |
| `RUNMODE` | Tune(0)/Operate(1) | rf_states |
| `STATE` | Reset(0)/Load(1)/Run(2) | rf_states, rf_calib |
| `DACS` | DACs on(1)/off(0) | rf_states |
| `SSCONT` | Single-shot(0)/Continuous(1) | rf_states |
| `DIRECTLOOP` | Direct loop hardware on/off | rf_statesLP |
| `COMBLOOP` | Comb loop hardware on/off | rf_statesLP |
| `LEADCOMP` | Lead compensation on/off | rf_statesLP |
| `INTCOMP` | Integral compensation on/off | rf_statesLP |
| `CAVSEL` | Cavity selector | rf_calib |
| `FBSIG` | Feedback signal selector | rf_calib |
| Various `CAV*.A-H` | Cavity multiplier weights/offsets | rf_calib |
| Various `MODU.*` | Module control/offset fields | rf_calib |

---

## 6. State Transition Diagrams

### Overall System Operation Flow

```
                    POWER ON / IOC BOOT
                          │
                    ┌─────▼─────┐
                    │    OFF    │  All loops inactive
                    │           │  HVPS off, RF off
                    └───┬───┬───┘
          ┌─────────────┤   ├──────────────┐
          │             │   │              │
     ┌────▼───┐    ┌────▼───┐    ┌────────▼────────┐
     │  PARK  │    │  TUNE  │    │     ON_FM       │
     │        │    │        │    │ (Frequency Mod)  │
     │Tuners  │    │Drive   │    │ Load I/Q files   │
     │parked  │    │pwr     │    │ Continuous RF     │
     │Beam    │    │control │    └────────┬─────────┘
     │abort   │    │HVPS on │             │ To TUNE only
     │reset   │    │        │             │
     └────────┘    └───┬────┘    ┌────────▼─────────┐
     Back to OFF       │         │      TUNE        │
     only              │         │    (from ON_FM)   │
                       │         └──────────────────┘
                  ┌────▼──────────────────────────┐
                  │           ON_CW               │
                  │  (Continuous Wave Operation)   │
                  │                                │
                  │  ┌─ Direct Loop (ON/OFF) ──┐  │
                  │  │  ┌─ Comb Loop ──────┐   │  │
                  │  │  │  ┌─ GFF Loop ──┐ │   │  │
                  │  │  │  │  ┌─ LFB ──┐ │ │   │  │
                  │  │  │  │  │ Woofer │ │ │   │  │
                  │  │  │  │  └────────┘ │ │   │  │
                  │  │  │  └─────────────┘ │   │  │
                  │  │  └──────────────────┘   │  │
                  │  └── Lead Compensation ────┘  │
                  │  └── Integral Compensation ─┘ │
                  │  └── Ripple Loop ────────────┘│
                  │  └── Tickle (beam tune meas) ─┘│
                  └───────────────────────────────┘
                  Back to TUNE or OFF
```

### Loop Coordination During ON_CW Transitions

```
TUNE → ON_CW (Normal):
  1. DACs OFF → Reset → Load → Run
  2. Set IQ reference (selection 1)
  3. Initialize ripple loop
  4. Set OPERATE mode
  5. HVPS ON
  6. Trigger direct loop check (ef)

TUNE → ON_CW (Fast Turnon):
  1. DACs OFF → Reset → Load → Run
  2. Home cavities, reset combs
  3. Set IQ reference (selection 3)
  4. Direct loop ON (full gain)
  5. Integral + Lead compensation ON
  6. Comb loop ON
  7. OPERATE mode, RF ON
  8. HVPS at fast turnon voltage
  9. HVPS triggers ON
  10. GFF + LFB ON
  11. Continuous RF
  12. Reset beam abort
```

---

## 7. PV Naming Conventions & Signal Flow

### PV Naming Structure

```
{STN}:{SUBSYSTEM}:{PARAMETER}:{QUALIFIER}
  │         │           │           │
  │         │           │           └─ CTRL, RBCK, STAT, SEVR, DELTA, etc.
  │         │           └─ VOLT, POWER, PHASE, POSN, STATE, LOOP, etc.
  │         └─ STN, HVPS, KLYS*, CAV*, CAVTUNR, STNVOLT, etc.
  └─ Station ID (e.g., HR81, LR02) passed as macro
```

### Key Signal Flows

#### Drive Power Control (TUNE mode)
```
Phase Measurement → {STN}:STN:PHASE:CALC
     │
     ▼
Error Calculation → {STN}:KLYSDRIVFRWD:POWER:ERR.STAT
     │
     ▼
Delta Calculation → {STN}:KLYSDRIVFRWD:DAC:DELTA
     │
     ▼ (rf_dac_loop reads this)
DAC Update       → {STN}:STN:TUNE:IQ.A (new counts)
     │
     ▼
RFP Hardware     → Klystron Drive Power changes
```

#### Gap Voltage Control (ON_CW with Direct Loop)
```
Gap Voltage Measurement → {STN}:STN:VOLT
     │
     ▼
Error Calculation       → {STN}:STN:VOLT:ERR.STAT
     │
     ├─── HVPS Path ──→ {STN}:KLYSDRIVFRWD:HVPS:DELTA → rf_hvps_loop → {STN}:HVPS:VOLT:CTRL
     │
     └─── DAC Path ───→ {STN}:STNVOLT:DAC:DELTA → rf_dac_loop → {STN}:STN:ON:IQ.A or GFF:IQ.A
```

#### Cavity Tuning Control
```
Load Angle Measurement → {STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR
     │
     ▼
Position Delta Calc    → {STN}:CAV{CAV}TUNR:POSN:DELTA
     │
     ▼ (rf_tuner_loop reads this)
Stepper Motor Command  → {STN}:CAV{CAV}TUNR:STEP:MOTOR (new position)
     │
     ▼
Cavity Frequency changes → Load angle error decreases
```

---

## 8. Design Patterns for New Hardware

### Pattern 1: Tri-File Architecture Per Loop

Each control loop follows a consistent pattern of three header files + one sequence file:
- `*_defs.h` — Constants, status codes, string messages
- `*_pvs.h` — PV declarations with assign/monitor/evflag/sync
- `*_macs.h` — Control algorithm macros
- `*.st` — State machine using all three headers

**Recommendation for new system**: Maintain this separation. It makes each loop self-documenting and allows independent modification of algorithms vs. PV bindings.

### Pattern 2: Event-Driven with Heartbeat Fallback

Every loop uses the pattern:
```
when (efTestAndClear(ready_ef) || delay(MAX_INTERVAL))
```
This ensures:
- **Normal operation**: Loop triggers on external timing signal
- **Degraded operation**: Loop still runs at heartbeat rate even if timing fails

**Recommendation**: Essential for reliability. New system should maintain this dual-trigger approach.

### Pattern 3: Priority-Ordered Safety Checks

All loops follow the same pattern before applying control:
1. Check hardware module online (INVALID_ALARM severity)
2. Check measurement quality (alarm status/severity)
3. Check safety conditions (vacuum, power limits, etc.)
4. Only then apply control algorithm

**Recommendation**: This defense-in-depth approach should be replicated. Consider adding more structured interlock checking in new system.

### Pattern 4: Status Machine with Human-Readable Strings

Each loop maintains:
- Numeric status code (for programmatic use)
- Human-readable status string (for operator display)
- Status change logging (epicsPrintf for significant events)

**Recommendation**: Excellent practice for operations. New system should add timestamp and severity level to status strings.

### Pattern 5: Graceful Degradation

The DAC loop demonstrates adaptive behavior based on available hardware:
- If GVF module is bad → fall back to RFP DACs
- If direct loop is on → control gap voltage; if off → control drive power

**Recommendation**: New system should explicitly define fallback modes for each loop.

### Pattern 6: Coordinated Loop Sequencing

The `rf_statesLP` sub-sequence demonstrates that feedback loops cannot simply be turned on/off independently:
- Gain must be ramped gradually
- Beam abort must be managed
- Gap voltage must settle before and after transitions
- Loops must be enabled in a specific order

**Recommendation**: Critical for any upgraded system. Document the required sequencing order explicitly.

---

## 9. Recommendations for Upgraded System

### 9.1 What to Preserve

1. **Hierarchical state machine architecture** — Master station SM coordinating independent feedback loops
2. **Event-driven + heartbeat timing model** — Proven reliable
3. **Priority-ordered safety checking** — Defense in depth
4. **Gain ramping during loop transitions** — Essential for stability
5. **Automatic fault reset with retry counting** — Reduces operator burden
6. **Fault file capture on trip** — Essential for post-mortem analysis
7. **Dual position sensing for tuners** — Absolute + incremental

### 9.2 What to Modernize

1. **Replace VxWorks-specific calls** (`taskDelay`, `sysClkRateGet`) with EPICS-portable equivalents (`epicsThreadSleep`)
2. **Replace C macros with proper functions** — The `DAC_LOOP_SET` and similar macros are difficult to debug
3. **Add structured logging** — Replace `epicsPrintf` with a proper logging framework with severity levels and timestamps
4. **Replace C-string status messages** with enumerated PV types (mbbo records)
5. **Consider Python/PyEPICS for higher-level coordination** — Keep time-critical loops in SNL/C, move state machine to Python
6. **Add unit testing framework** — Critical for regression testing during upgrades
7. **Replace direct VME hardware access** (in rf_calib) with standard EPICS device support

### 9.3 Critical Control Parameters to Characterize for New Hardware

| Parameter | Current Value | Description | Where Defined |
|-----------|--------------|-------------|---------------|
| DAC range | 0–2047 (12-bit) | Max DAC count | `rf_dac_loop_defs.h` |
| DAC deadband | 0.5 counts | Minimum change threshold | `rf_dac_loop_defs.h` |
| HVPS voltage tolerance | Configurable PV | Readback vs requested difference | `rf_hvps_loop_pvs.h` |
| HVPS tolerance count | 10 | Failures before status change | `rf_hvps_loop_defs.h` |
| Tuner reset tolerance | 2 × MDEL | Position error threshold | `rf_tuner_loop_defs.h` |
| Tuner stuck threshold | 5 cycles | Non-movement detection | `rf_tuner_loop_defs.h` |
| Gain ramp rate | Configurable PV | Delta per step for loop transitions | `rf_states.st` |
| Voltage settle time | Configurable PV | Wait after gap voltage change | `rf_states.st` |
| Fast turnon voltage | Configurable PV | HVPS voltage for fast ON | `rf_states.st` |
| Fault file circular buffer | 15 slots | Number of fault snapshots retained | `rf_states.st` |
| Max loop interval | 10.0s (DAC, HVPS), 60.0s (Tuner) | Heartbeat timeout | Various `_defs.h` |

### 9.4 Questions for New Hardware Design

1. **What is the new DAC resolution?** (Current: 12-bit → 2047 max counts)
2. **What is the new feedback bandwidth?** (Current: ~1–2 Hz effective for DAC/HVPS loops)
3. **Will the direct loop hardware be preserved or replaced?** (Impacts entire ON_CW sequencing)
4. **How many cavities per station?** (Current: up to 4, tuner loop is reentrant)
5. **Will comb filtering be on the same module or separate?** (Current code handles both CFM and CF2)
6. **What diagnostic data needs to be captured on fault?** (Current: 11 data files per fault)
7. **Is fast turnon still required?** (Adds significant complexity to rf_states)
8. **What is the new HVPS topology?** (Current: single HVPS per klystron)

---

*Report generated from deep analysis of the `spearlegacyLLRF/legacyLLRF` codebase.*
*All 19 files reviewed in detail.*
*Prepared for planning new LLRF control system for upgraded hardware.*
