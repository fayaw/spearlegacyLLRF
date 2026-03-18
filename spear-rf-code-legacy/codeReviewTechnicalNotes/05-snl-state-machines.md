# SNL State Machine Programs — Control Logic Deep Dive

**Document**: 05 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**(Rev 2 — corrected with upgrade mapping from PDR)**

---

## UPGRADE CONTEXT

The 6 SNL programs are the **primary spec extraction targets** for the upgrade. They define the operational procedures that the new Python/EPICS coordinator must replicate. Per PDR §14:

| Legacy SNL | Upgrade Target | Status |
|-----------|---------------|--------|
| `rf_states.st` | Python/EPICS coordinator state machine | **SPEC-EXTRACT → rewrite** |
| `rf_hvps_loop.st` | CompactLogix PLC ladder logic (B118) | **SPEC-EXTRACT → PLC code** |
| `rf_tuner_loop.st` | LLRF9 built-in tuner (10 Hz phase) + Python load-angle | **SPEC-EXTRACT → configure + rewrite** |
| `rf_calib.st` | LLRF9 built-in calibration (Dmitry's software) | Verify equivalence |
| `rf_msgs.st` | EPICS logging + LLRF9 diagnostics | Reference |
| `rf_dac_loop.st` | **ELIMINATED** — LLRF9 vector modulator | Per PDR §15.7: eliminated |

---

## 1. Overview

Six SNL (State Notation Language) programs control the RF station:

| Program | Lines | Instances | Function |
|---------|-------|-----------|----------|
| `rf_states.st` | 2,227 | 1 | Master station state machine |
| `rf_calib.st` | 3,345 | 1 | Calibration sequences |
| `rf_tuner_loop.st` | 555 | 4 (one per cavity) | Cavity tuner motor control |
| `rf_hvps_loop.st` | 343 | 1 | HVPS supervisory control |
| `rf_dac_loop.st` | 290 | 1 | Drive/gap voltage DAC control |
| `rf_msgs.st` | 352 | 1 | Message logging and TAXI monitoring |

**Support files**: 12 header/macro files (~1,151 lines) define PV names, status codes, and control macros.

---

## 2. rf_states.st — Master Station State Machine (2,227 lines)

### 2.1 Declaration

```snl
program rf_states ("name=tRFSTATES,STN=barfonthis")
```

Authors: Robert C. Sass (PEP-II, 1997), M. Laznovsky, S. Allison (SPEAR3 modifications)

### 2.2 State Diagram

```
                    ┌─────────┐
         ┌─────────│   OFF   │◄────────────────────────────┐
         │         └────┬────┘                              │
         │              │ Operator command                   │
         │              ▼                                    │
         │         ┌──────────┐                              │
         │         │INITIALIZE│                              │
         │         └────┬─────┘                              │
         │              │ All modules healthy                │
         │              ▼                                    │
         │         ┌─────────┐                              │
         │    ┌────│ STANDBY │◄─────────────────────┐      │
         │    │    └────┬────┘                       │      │
         │    │         │ Operator "RF ON"            │      │
         │    │         ▼                             │      │
         │    │    ┌─────────┐                        │      │
         │    │    │  ON_CW  │────── FAULT ──────►┌───┴────┐│
         │    │    └─────────┘                     │ FAULT  ││
         │    │                                    └───┬────┘│
         │    │                                        │     │
         │    │                                        ▼     │
         │    │                                ┌────────────┐│
         │    └────────────────────────────────│FAULT_CLEAR ││
         │                                     └────────────┘│
         └───────────────────────────────────────────────────┘
```

### 2.3 State Details

**OFF**:
- All RF outputs disabled
- Monitoring only
- Entry action: Disable all feedback loops, zero DACs

**INITIALIZE**:
- Loads DSP firmware into all modules
- Configures VXI modules (registers, DACs, filters)
- Configures AB PLC communication
- Verifies all module health (checks firmware version, interrupt status)
- Loads table/coefficient files
- Timeout → FAULT if initialization doesn't complete

**STANDBY**:
- All modules initialized and healthy
- RF feedback loops disabled
- HVPS may or may not be energized
- Ready for operator to enable RF

**ON_CW** (Continuous Wave):
- RF feedback active
- Sequence: Enable direct loop → ramp drive power → enable comb loop → enable ripple loop
- Monitors: AIM interlocks, HVPS status, IQA measurements
- Any fault → immediate transition to FAULT

**FAULT**:
- RF output disabled immediately
- Fault file dump triggered (AIM DAS sequence)
- Signal RAM contents captured to numbered fault files (/dat/FAULTSigI_00 through _10)
- Circular buffer of 11 fault files (NUMFFILES)
- Fault source recorded (AIM interlock, HVPS trip, IQA alarm, etc.)
- Automatic transition to FAULT_CLEAR after dump complete

**FAULT_CLEAR**:
- Resets interlocks
- Clears fault flags
- Transitions to STANDBY when all interlocks cleared

### 2.4 Key Variables (PVs)

```snl
int     station_state;          // {STN}:STN:STATE:RBCK
int     station_ctrl;           // {STN}:STN:STATE:CTRL
int     rfp_mode;               // {STN}:RFP:MODE
int     aim_interlock;          // {STN}:AIM:INTLK:STATUS
int     hvps_status;            // {STN}:HVPS:STATUS
int     fault_file_num;         // Current fault file index (0-10)
```

### 2.5 Fault File Handling (M. Laznovsky addition, 2003)

```c
#define NUMFFILES 11   // Circular buffer of fault dumps

// On entering FAULT state:
for (i = 0; i < 6; i++) {  // 6 signal RAMs: sigI, sigQ, cavI, cavQ, dacI, dacQ
    sprintf(filename, "/dat/FAULTSig%s_%02d", ramName[i], fault_file_num);
    P2RF_RecordMemory(drvPvt, memIndex[i], filename, count);
}
fault_file_num = (fault_file_num + 1) % NUMFFILES;
```

---

## 3. rf_calib.st — Calibration Sequences (3,345 lines)

### 3.1 Purpose

Automated calibration of the RF signal chain. Uses C preprocessor macros extensively to reduce code repetition across 4 cavities.

### 3.2 Calibration Procedures

**Octal DAC Offset Nulling**:
1. Set all DAC channels to zero
2. Measure residual I/Q output via IQA
3. Compute offset correction: `offset = -measured_residual`
4. Store offset for each DAC channel
5. Verify correction by re-measuring

**Cavity Modulator Calibration**:
1. For each cavity (1-4):
   - Set known modulator weights (e.g., II=1, IQ=0, QI=0, QQ=0)
   - Measure I/Q response via IQA
   - Rotate through all 4 combinations
   - Compute 2×2 coupling matrix from measurements
   - Store calibration coefficients

**RF Switch Calibration**:
1. Select each signal path through RF switches
2. Measure amplitude and phase for each path
3. Compute correction factors

### 3.3 Macro Pattern

```c
#define CALIB_MEAS(cavity, signal, ...)  \
  state calib_meas_##cavity##_##signal { \
    when (/* measurement ready */) {     \
      /* read I/Q from IQA */            \
      /* compute amplitude/phase */      \
      /* store result */                 \
    } state calib_next_##cavity          \
  }
```

This pattern is expanded for each cavity × each measurement × each DAC combination, resulting in hundreds of states.

---

## 4. rf_tuner_loop.st — Cavity Tuner Control (555 lines)

### 4.1 Declaration

```snl
program rf_tuner_loop ("name=C1TUNRLOOP,STN=SRF1,CAV=1")
```

Runs as **4 concurrent instances**, one per cavity.

### 4.2 State Diagram

```
         ┌────────┐
    ┌────│  OFF   │◄──────────────────────────┐
    │    └───┬────┘                            │
    │        │ loop_ctrl == LOOP_CONTROL_ON    │
    │        ▼                                 │
    │    ┌────────┐                            │
    │    │  PARK  │──── (station ON_CW) ──►┌───┴───┐
    │    └────────┘                         │  ON   │
    │                                       └───┬───┘
    │                                           │
    │    ┌──────────────────────────────────────┘
    │    │
    │    ▼
    │    ┌──────────┐
    │    │ TRACKING │◄──────────────────────┐
    │    └────┬─────┘                       │
    │         │ posn_delta > threshold      │
    │         ▼                             │
    │    ┌──────────┐                       │
    │    │  MOVING  │── (motor done) ──►┌───┴──────┐
    │    └──────────┘                   │ SETTLING │
    │                                    └──────────┘
    └────────────────────────────────────────────────
```

### 4.3 Control Algorithm

```
1. Read frequency error from IQA load angle measurement:
   freq_err = {STN}:CAV{CAV}LOAD:ANGLE:ERR

2. Compute required tuner motion:
   posn_delta = freq_err * tuner_gain

3. Check limits:
   if (posn_new > sm_drvh) posn_new = sm_drvh    // high drive limit
   if (posn_new < sm_drvl) posn_new = sm_drvl    // low drive limit

4. Command stepper motor:
   {STN}:CAV{CAV}TUNR:POSN:CTRL = posn_new

5. Wait for motor done (sm_dmov == SM_DONE_MOVING):
   - Timeout after LOOP_MOVE_COUNT × LOOP_MOVE_DELAY ticks
   - If stuck: increment nomov_count
   - After LOOP_NOMOV_COUNT stuck attempts: set LOOP_SM_MOVE_STATUS

6. After settling (LOOP_SETTLE_COUNT measurements):
   - Verify position within deadband (sm_rdbd)
   - If outside: retry move
   - If inside: return to TRACKING
```

### 4.4 PV Connections (from rf_tuner_loop_pvs.h)

| PV | Type | Direction | Description |
|----|------|-----------|-------------|
| `{STN}:CAVTUNR:LOOP:CTRL` | int | IN | Master loop control (all cavities) |
| `{STN}:CAV{CAV}TUNR:LOOP:STATE` | int | OUT | Per-cavity state (OFF=0, PARK=1, ON=2) |
| `{STN}:CAV{CAV}TUNR:LOOP:STATUS` | int | OUT | Status code (15 possible values) |
| `{STN}:CAV{CAV}TUNR:POSN` | float | IN | Current tuner position |
| `{STN}:CAV{CAV}TUNR:POSN:CTRL` | float | OUT | Position setpoint |
| `{STN}:CAV{CAV}TUNR:POSN:DELTA` | float | IN | Position delta from IQA |
| `{STN}:CAV{CAV}TUNR:STEP:MOTOR.*` | various | IN/OUT | Stepper motor record fields |
| `{STN}:KLYSOUTFRWD:POWER` | float | IN | Forward power (minimum check) |
| `{STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR` | int | IN | Load angle error severity |

---

## 5. rf_hvps_loop.st — HVPS Supervisory (343 lines)

### 5.1 Function

Monitors and controls the High Voltage Power Supply via Allen-Bradley SLC-500 PLC.

### 5.2 Key Operations

| Operation | PVs Involved | Description |
|-----------|-------------|-------------|
| Voltage setpoint | `{STN}:HVPS:VOLTS:CTRL` | Write target voltage to PLC |
| Voltage readback | `{STN}:HVPS:VOLTS:RBCK` | Read actual voltage from PLC |
| Contactor control | `{STN}:CONT:CLOSE/OPEN` | Close/open HV contactor |
| Crowbar arm | `{STN}:HVPS:CROWBAR:ARM` | Arm the crowbar protection |
| Fault monitoring | `{STN}:HVPS:FAULT:*` | Monitor overcurrent, overvoltage, cooling |
| Status reporting | `{STN}:HVPS:STATUS` | Overall HVPS status code |

### 5.3 Status Definitions (from rf_hvps_loop_defs.h)

| Code | Status | Description |
|------|--------|-------------|
| 0 | UNKNOWN | Initial state |
| 1 | READY | HVPS ready, contactor open |
| 2 | ON | HVPS energized, contactor closed |
| 3 | OFF | HVPS commanded off |
| 4 | FAULT | HVPS fault detected |
| 5 | CROWBAR | Crowbar fired |

---

## 6. rf_dac_loop.st — DAC Control (290 lines)

### 6.1 Function

Controls drive power and gap voltage by adjusting RFP/GVF DAC output levels.

### 6.2 Operating Modes

| Mode | PV | Description |
|------|-----|-------------|
| TUNE | `{STN}:STNDRV:*` | Drive power control — adjusts RFP master DAC |
| ON | `{STN}:STNGAP:*` | Gap voltage control — adjusts GVF output level |

### 6.3 Status Codes (from rf_dac_loop_defs.h — 15 states)

| Code | Status | Description |
|------|--------|-------------|
| 0 | UNKNOWN | Initial state |
| 1 | TUNE | Good — drive power control active |
| 2 | ON | Good — station gap voltage control active |
| 3 | TUNE_OFF | Drive power control turned off |
| 4 | ON_OFF | Gap voltage control turned off |
| 5 | DRIV_BAD | Nonfunctional — drive power measurement bad |
| 6 | GAPV_BAD | Nonfunctional — gap voltage measurement bad |
| 7 | CTRL | Warning — DAC not at requested value |
| 8 | STN_OFF | Station is OFF, PARK, or ON_FM |
| 9 | RFP_BAD | Nonfunctional — RF processor bad |
| 10 | DAC_LIMT | Warning — DAC at limit |
| 11 | GVF_BAD | Nonfunctional — Gap module bad |
| 12 | DRIV_HIGH | No gap voltage increase — drive too high |
| 13 | DRIV_TOL | Drive power out of tolerance |
| 14 | GAPV_TOL | Gap voltage out of tolerance |

### 6.4 DAC Control Macro (from rf_dac_loop_macs.h)

The `DAC_LOOP_SET` macro (~50 lines) implements the core feedback:
1. Check RF processor severity
2. If control OFF: just monitor tolerances
3. If control ON:
   - Get current DAC counts and delta
   - Check measurement validity
   - Check if other loop is at LOLO alarm (drive too high)
   - Compare current vs previous counts for control verification
   - Update DAC count output

---

## 7. rf_msgs.st — Message Logging (352 lines)

### 7.1 Function

- Monitors TAXI link status for communication errors
- Logs system messages to EPICS event log
- Sends periodic heartbeat messages
- Monitors for specific fault conditions and generates alerts

### 7.2 TAXI Error Monitoring

The TAXI serial link connects GVF modules and provides timing signals. rf_msgs.st polls TAXI error counters and alerts if error rate exceeds threshold.

---

## 8. Upgrade Impact

### 8.1 What to Preserve

1. **Station state machine logic** (rf_states.st) — the operational procedure specification
2. **Fault file system** — capture signal data on trip for post-mortem analysis
3. **Tuner loop algorithm** — frequency tracking with deadband, retry, and limit checking
4. **DAC loop feedback** — drive power and gap voltage regulation
5. **Calibration procedures** — DAC offset nulling, modulator calibration
6. **All PV names** from *_pvs.h files
7. **All status codes** from *_defs.h files

### 8.2 Rewrite Considerations

- SNL is still available in modern EPICS — can reuse the language
- Alternatively: Python IOC (pyDevSup), C++ state machines, or EPICS sequencer v2
- The macro-heavy style of rf_calib.st may benefit from a more modern approach
- PV names in *_pvs.h files must be preserved exactly
