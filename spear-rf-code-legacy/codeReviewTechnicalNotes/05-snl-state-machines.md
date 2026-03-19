# SNL State Machine Programs — Control Logic Deep Dive

**Document**: 05 of 09 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**(Rev 6 — corrected rf_states.st state count from 22→23 (added missing s_init); replaced fabricated CALIB_MEAS macro code block with accurate utility macro description and 28-state enumeration; added tuner loop state diagram clarification distinguishing 5 SNL states from 3 algorithmic control modes)**
**(Rev 5 — added rf_calib.st line count precision footnote; see §3 footnote ¹)**
**(Rev 4 — corrected HVPS PV naming error VOLTS→VOLT; replaced fabricated HVPS status codes with the 16 actual codes from source; corrected proc state protection logic to reflect 3-condition check; corrected phantom PV references; added loop state/control mode enumerations)**
**(Rev 3 — corrected legacy state machine names and state diagram from source code; added HVPS collector protection)**

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

### 2.2 State Diagram (Corrected from Source Code)

> **Rev 3 correction**: Rev 2 showed the **proposed upgrade** state machine (OFF→INITIALIZE→STANDBY→ON_CW→FAULT→FAULT_CLEAR from PDR Section 2.2). The actual legacy state machine is shown below, extracted directly from `rf_station_state.h` and `rf_states.st,v`.

**Primary States** (from `rf_station_state.h`): OFF=0, PARK=1, TUNE=2, ON_FM=3, ON_CW=4

```
                      ┌─────────┐
           ┌──────────│   OFF   │◄──────── s_go_off (from any state)
           │          └────┬────┘
           │               │ Operator: STATE:CTRL = PARK
           │               ▼
           │          ┌──────────┐
           │   ┌──────│   PARK   │◄──────── s_go_park (init VXI, load DSP/tables)
           │   │      └────┬─────┘
           │   │           │ Operator: STATE:CTRL = TUNE
           │   │           ▼
           │   │      ┌─────────┐
           │   │ ┌────│  TUNE   │◄──────── s_go_tune (enable drive, direct loop)
           │   │ │    └────┬────┘
           │   │ │         │ Operator: STATE:CTRL = ON_FM or ON_CW
           │   │ │         ├─────── s_go_on_fm ─────┐
           │   │ │         │                         ▼
           │   │ │         │                    ┌─────────┐
           │   │ │         │         ┌──────────│  ON_FM  │ (comb+ripple loops)
           │   │ │         │         │          └────┬────┘
           │   │ │         │         │               │ s_go_on_cw (or direct)
           │   │ │         │         │               ▼
           │   │ │         └── s_go_tune_to_on_cw ──►┌─────────┐
           │   │ │                                    │  ON_CW  │ (full power)
           │   │ │          go_on_cw_to_tune ◄────────└─────────┘
           │   │ │          go_on_fm_to_tune ◄────────┘
           │   │ └────────────────────┘
           │   └──────────────────────────────────────────────┘
           └──────────────────────────────────────────────────────┘

  Transition states within operating modes:
  ┌────────────────────────────────────────────────┐
  │ s_comb_ramp    — Comb loop ramp-up sequence    │
  │ s_direct_ramp  — Direct loop ramp-up sequence  │
  │ s_gv_up        — Gap voltage ramp up           │
  │ s_gv_down      — Gap voltage ramp down         │
  │ s_lp_check     — Loop parameter check          │
  │ s_faultfiles   — Fault file dump               │
  │ s_go_stn_reset — Station reset sequence        │
  │ s_go_tickleoff — Tickle off sequence           │
  │ s_go_tickleon  — Tickle on sequence            │
  └────────────────────────────────────────────────┘
```

**State set architecture** (3 concurrent state sets in rf_states.st):
1. **`ss rf_states`** — Main state machine (above). Contains all primary and transition states.
2. **`ss rf_statesLP`** — Loop protection state set. Runs concurrently, monitors loop health.
3. **`ss rf_statesFF`** — Fault file state set. Manages asynchronous fault file capture.

### 2.3 State Details (Corrected from Source Code)

**s_off (OFF = 0)**:
- All RF outputs disabled
- Monitoring only
- Entry action: Disable all feedback loops, zero DACs
- Transition: Operator sets `STATE:CTRL = PARK` → enters `s_go_park`

**s_park (PARK = 1)**:
- VXI modules initialized (DSP firmware loaded, table files loaded)
- AB PLC communication configured
- Module health verified (firmware version, interrupt status)
- RF output disabled, HVPS may be energized
- Transition: Operator sets `STATE:CTRL = TUNE` → enters `s_go_tune`

**s_tune (TUNE = 2)**:
- Drive power ramping via direct loop engagement
- Direct loop active (s_direct_ramp transition state handles ramp-up)
- Gap voltage being established (s_gv_up/s_gv_down handle ramps)
- Transition to ON_FM: `s_go_on_fm` → enables comb and ripple loops
- Transition to ON_CW (direct): `s_go_tune_to_on_cw` → skips ON_FM

**s_on_fm (ON_FM = 3)**:
- Frequency modulation mode — comb + ripple rejection loops active
- `s_comb_ramp` transition state handles comb loop engagement
- Drive power established, gap voltage controlled
- Transition: Operator sets `STATE:CTRL = ON_CW` → enters `s_go_on_cw`
- Fallback: `go_on_fm_to_tune` → returns to TUNE if problems

**s_on_cw (ON_CW = 4)**:
- Continuous wave — full RF power
- All feedback loops active (direct, comb, ripple)
- Monitors: AIM interlocks, HVPS status, IQA measurements
- Any fault → `s_faultfiles` (captures signal RAM to `/dat/FAULTSigI_00..10`) → `s_go_off`
- Fallback: `go_on_cw_to_tune` → returns to TUNE if operator requests or loop instability

**Initialization State (1)**:
| State | Purpose |
|-------|---------|
| `s_init` | One-time initialization: reads current state PV, configures IQA3 channel names, clears fault flags, sets `clock_resync = 1`. Always transitions immediately to `s_go_off`. |

**Transition States (17 total)**:
| State | Purpose |
|-------|---------|
| `s_go_off` | Orderly shutdown from any state to s_off |
| `s_go_park` | Initialize VXI modules, load DSP firmware/tables |
| `s_go_tune` | Enable drive power, engage direct feedback loop |
| `s_go_on_fm` | Enable comb and ripple rejection loops |
| `s_go_on_cw` | Full power engagement from ON_FM |
| `s_go_tune_to_on_cw` | Direct transition from TUNE to ON_CW (bypassing ON_FM) |
| `go_on_cw_to_tune` | Controlled fallback from ON_CW to TUNE |
| `go_on_fm_to_tune` | Controlled fallback from ON_FM to TUNE |
| `s_comb_ramp` | Comb loop ramp-up sequence (gradual engagement) |
| `s_direct_ramp` | Direct loop ramp-up sequence |
| `s_gv_up` | Gap voltage ramp up (incremental step-up) |
| `s_gv_down` | Gap voltage ramp down (incremental step-down) |
| `s_lp_check` | Loop parameter validity check |
| `s_faultfiles` | Fault file capture (signal RAM → `/dat/FAULTSig*`) |
| `s_go_stn_reset` | Station reset sequence |
| `s_go_tickleoff` | Tickle excitation off |
| `s_go_tickleon` | Tickle excitation on |

> **Total: 23 states** across 3 concurrent state sets — 1 initialization + 5 primary + 12 transition (in `ss rf_states`) + 5 loop-protection (in `ss rf_statesLP`) + 1 fault-file (in `ss rf_statesFF`, counted separately from the transition table but part of the 23 total; see `s_faultfiles` above). Note that `s_lp_check`, `s_gv_down`, `s_direct_ramp`, `s_comb_ramp`, and `s_gv_up` belong to `ss rf_statesLP`; `s_faultfiles` belongs to `ss rf_statesFF`; all others belong to `ss rf_states`.

> **Note on upgrade mapping**: The proposed upgrade state machine (PDR §2.2: OFF→INITIALIZE→STANDBY→ON_CW→FAULT→FAULT_CLEAR) simplifies the 23-state legacy machine into 6 states. The legacy PARK+VXI-init maps to the upgrade's INITIALIZE. The legacy TUNE+ON_FM are collapsed into the upgrade's ramp-to-ON_CW sequence. The legacy fault-file capture becomes a substep of the upgrade's FAULT state. See `Designs/10_SOFTWARE_DESIGN_DOCUMENT.md` Section 22 for the complete legacy→upgrade state mapping.

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

## 3. rf_calib.st — Calibration Sequences (3,345 lines) ¹

### 3.1 Purpose

Automated calibration of the RF signal chain. Uses C preprocessor utility macros and nested `for` loops to reduce code repetition across 4 cavities. Contains 28 hand-written SNL states.

> ¹ **Line count precision note (Rev 3)**: The PDR (§14.1) and SDD (§1.4) both report rf_calib.st as "2,800+" lines. The actual RCS-tracked source (`rfApp/src/rf_calib.st,v`) is **3,345 lines** — a 545-line difference. This discrepancy likely reflects an earlier RCS revision snapshot used when drafting the design documents, or a summary-level approximation. The count cited here (3,345) was verified directly against the latest RCS head revision and is the authoritative figure.

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

### 3.3 Code Structure and Utility Macros

The `rf_calib.st` program contains **28 hand-written SNL states** — not macro-generated states. All state declarations are explicit:

`Init` → `Startup` → `CombCheck` → `Startup2` → `Setup` → `ZeroCavMults` → `ZeroDirMults` → `DirectInitial` → `ZeroCombMults` → `Combiner` → `Direct` → `SummingNodeI` → `SummingNodeQ` → `GainStageI` → `GainStageQ` → `TuneStage` → `ZeroKlysMults` → `DiffNodeOffsets` → `KlysStage` → `CompStage` → `Direct_Final` → `CombStage` → `KlysDemod` → `NullModulator` → `Finish` / `Abort` / `Abend` → `Done`

Code repetition across the 4 cavities is reduced via **utility macros** that perform common operations *within* state bodies (not state-generating macros):

| Macro | Purpose |
|-------|---------|
| `CAL_MSG(_S_)` | Logs calibration progress messages via `epicsPrintf` |
| `CHECK_ABORT` | Tests `doCalib == 0` and jumps to `Abort` state via `goto ABORT` |
| `SET_CAV_OFFSETS(_Z_,_D0_,_D1_,_D2_,_D3_)` | Sets multiplier DAC offsets for current cavity (II, QI, IQ, QQ) |
| `MEASURE_*`, `ZERO_*`, `STAGE_*`, `NULL_*` | Measurement, zeroing, and calibration-stage subroutines |

Configuration constants (also macros): `P2RF_K_CAVCNT` (4 cavities), `COUNT` (30000 averaging window), `MAX_ATTEMPTS` (50 iteration limit), signal-path selectors (`TOTAL`, `COMB_OUT`, `NOISE`, `DRIVE`, etc.).

Within each state, **nested `for` loops** iterate over cavities and measurement combinations:

```c
state ZeroCavMults {
    when (doCalib == 0) { } state Abort
    when (calStatus != STT_OK) { } state Abend
    when () {
        CAL_MSG("ZeroCavMults");
        for (cav = 0; cav < P2RF_K_CAVCNT; cav++) {
            /* ... binary search to null multiplier offsets ... */
            SET_CAV_OFFSETS(comOfset, delta, 0, delta, 0);
            /* ... measure, iterate, converge ... */
        }
    } state ZeroDirMults
}
```

The state count (28) is **static** regardless of cavity count or measurement combinations — iteration is handled by loops within states, not by state proliferation.

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

> **Important distinction**: The diagram above shows **5 actual SNL states**: `loop_init`, `loop_unknown`, `loop_reset`, `loop_off`, and `loop_on`. The labels "TRACKING," "MOVING," and "SETTLING" within the ON region are **not separate SNL state declarations** — they are **algorithmic control modes** implemented via conditional logic within the single `loop_on` state. The source code contains no `state TRACKING`, `state MOVING`, or `state SETTLING` declarations. Instead, these modes emerge from control-flow branching within `loop_on`'s `when` clauses, driven by state variables: `dmov_meas_count` (measurements since motor stopped), `sm_dmov` (stepper motor done-moving flag from AB controller), `nomov_count` (stuck-motor counter), and `loop_status` (current mode status code). A reader examining the source should look for these variables within `loop_on`, not for separate state blocks.

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
| `{STN}:CAV{CAV}TUNR:LOOP:STATUS` | int | OUT | Status code (14 values, 0–13; see `rf_tuner_loop_defs.h`) |
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

### 5.2 Key PV Connections (from `rf_hvps_loop_pvs.h`)

> **Rev 4 correction**: Rev 3 listed PVs as `{STN}:HVPS:VOLTS:CTRL` and `{STN}:HVPS:VOLTS:RBCK` (with 'S'). The actual PV namespace uses `{STN}:HVPS:VOLT:CTRL` and `{STN}:HVPS:VOLT` (no 'S'), verified against `rf_hvps_loop_pvs.h,v`. Rev 3 also listed phantom PVs (`PCOLL_MAX`, `CROWBAR:ARM`, `CONT:CLOSE/OPEN`, `HVPS:FAULT:*`, `HVPS:STATUS`) that do **not** appear in the SNL program's PV declarations. These may exist in the EPICS database layer (`.db` files) but are not part of the `rf_hvps_loop.st` SNL state machine. The table below lists only PVs actually declared in `rf_hvps_loop_pvs.h`.

| PV | Type | Mon | Description |
|----|------|-----|-------------|
| `{STN}:STN:STATE:RBCK` | int | Y | Station state readback |
| `{STN}:HVPS:LOOP:CTRL` | int | Y | Loop control command (OFF=0, PROC=1, ON=2) |
| `{STN}:HVPS:LOOP:STATE` | int | N | Loop state output (OFF=0, PROC=1, ON=2) |
| `{STN}:HVPS:LOOP:STATUS` | int | N | Loop status output (0–15, see §5.3) |
| `{STN}:HVPS:LOOP:STRING` | string | N | Status description string |
| `{STN}:HVPS:LOOP:DELAY` | int | N | Startup delay (ticks) for fast turnon |
| `{STN}:HVPS:LOOP:READY` | int | Y | External ready trigger (event flag) |
| `{STN}:STN:RFP:MODU.SEVR` | int | Y | RF Processor severity |
| `{STN}:STN:RFP:MODU.DLE` | int | Y | Direct loop enable |
| `{STN}:KLYSOUTFRWD:POWER` | float | Y | Klystron forward power |
| `{STN}:KLYSOUTFRWD:POWER:MAX` | float | Y | Max klystron forward power limit |
| `{STN}:CAVVACM:SUMY:SEVR.SEVR` | int | Y | Cavity vacuum summary severity |
| `{STN}:CAVVACM:CHECK` | int | Y | Cavity vacuum check |
| `{STN}:STN:VOLT.SEVR` | int | Y | Gap voltage severity |
| `{STN}:STN:VOLT:ERR.STAT` | int | Y | Gap voltage error status |
| `{STN}:KLYSDRIVFRWD:POWER:ERR.STAT` | int | Y | Drive power error status |
| `{STN}:CAVVOLT:CHECK` | int | Y | Cavity voltage check |
| `{STN}:HVPS:VOLT:CTRL` | float | N | Voltage setpoint to PLC |
| `{STN}:HVPS:VOLT` | float | Y | Voltage readback from PLC |
| `{STN}:HVPS:VOLT:LOOP` | float | N | Voltage history output |
| `{STN}:HVPS:LOOP:VOLTHIST.RES` | int | N | Reset voltage history |
| `{STN}:HVPS:LOOP:VOLTDIFF` | float | Y | Allowed voltage difference |
| `{STN}:HVPS:VOLT:MIN` | float | Y | Minimum voltage limit |
| `{STN}:HVPS:VOLT:CTRL.DRVH` | float | Y | Maximum voltage limit (drive high) |
| `{STN}:HVPS:LOOP:VOLTDOWN` | float | Y | Delta voltage down (proc mode) |
| `{STN}:HVPS:LOOP:VOLTUP` | float | Y | Delta voltage up (proc mode) |
| `{STN}:KLYSDRIVFRWD:HVPS:DELTA.SEVR` | float | Y | Drive-to-HVPS delta severity |
| `{STN}:KLYSDRIVFRWD:HVPS:DELTA` | float | N | Drive-to-HVPS delta (on mode) |
| `{STN}:STNVOLT:HVPS:DELTA` | float | N | Station-volt-to-HVPS delta (tune mode) |

### 5.3 Loop States, Control Modes, and Status Definitions (from `rf_hvps_loop_defs.h`)

> **Rev 4 correction**: Rev 3 listed 6 status codes (UNKNOWN, READY, ON, OFF, FAULT, CROWBAR). **These were completely wrong** — none of the names READY, FAULT, or CROWBAR exist in the source code. The actual source defines **16 status codes** (0–15). The correct enumeration from `rf_hvps_loop_defs.h,v` is below.

**Control Modes** (`hvps_loop_ctrl` values):

| Value | Name | Description |
|-------|------|-------------|
| 0 | HVPS_LOOP_CONTROL_OFF | Loop control is off |
| 1 | HVPS_LOOP_CONTROL_PROC | Processing (ramp) mode |
| 2 | HVPS_LOOP_CONTROL_ON | Active regulation mode |

**Loop States** (`hvps_loop_state` values):

| Value | Name | Description |
|-------|------|-------------|
| 0 | HVPS_LOOP_STATE_OFF | Loop is off |
| 1 | HVPS_LOOP_STATE_PROC | Processing (ramping voltage up/down) |
| 2 | HVPS_LOOP_STATE_ON | Active regulation |

**Status Codes** (`hvps_loop_status` values — 16 codes, 0–15):

| Code | Name | String | Description |
|------|------|--------|-------------|
| 0 | UNKNOWN | "HVPS loop in unknown status." | Initial/undefined state |
| 1 | GOOD | "HVPS loop reporting good status." | Normal operation |
| 2 | RFP_BAD | "RF Processor bad." | RF Processor module severity invalid |
| 3 | CAVV_LIM | "Cavity voltage above limit." | Cavity voltage above limit (on state, increasing blocked) |
| 4 | OFF | "HVPS loop is off." | Loop control is off |
| 5 | VACM_BAD | "Bad vacuum." | Cavity vacuum severity invalid |
| 6 | POWR_BAD | "Klystron forward power bad." | Klystron forward power severity invalid |
| 7 | GAPV_BAD | "Gap voltage bad." | Gap voltage severity invalid |
| 8 | GAPV_TOL | "Gap voltage out of tolerance." | Gap voltage error out of tolerance (on state) |
| 9 | VOLT_LIM | "HVPS loop at HVPS voltage limit." | Requested voltage at max limit |
| 10 | STN_OFF | "Station is OFF or PARKed." | Station state is OFF or PARK |
| 11 | VOLT_TOL | "Readback voltage differs from Requested" | Readback–request mismatch exceeds allowed diff |
| 12 | VOLT_BAD | "Readback HVPS voltage invalid." | HVPS voltage readback severity invalid |
| 13 | DRIV_BAD | "Klystron Drive Power is bad." | Drive power severity invalid (on_cw + direct loop) |
| 14 | ON_FM | "Station in ON_FM mode." | Station is in ON_FM mode (no regulation) |
| 15 | DRIV_TOL | "Klystron Drive Power out of tolerance." | Drive power error out of tolerance (on_cw + direct loop) |

**Constants**:
- `HVPS_LOOP_MAX_INTERVAL` = 10.0 s — maximum time between cycles regardless of events
- `HVPS_LOOP_MAX_VOLT_TOL` = 10 — tolerance violation count before status change

### 5.4 HVPS State Machine Architecture (from `rf_hvps_loop.st`)

The HVPS loop implements 4 states: `init`, `off`, `proc`, and `on`.

```
          ┌──────┐
          │ init │──────────────────────────────────────────► off
          └──────┘
                                                              │
          ┌────────────────────────────────────────────────────┤
          │                                                    │
          ▼                                                    ▼
      ┌──────┐  (ctrl==PROC && stn!=OFF/PARK)             ┌──────┐
      │ proc │◄───────────────────────────────────────────│  off  │
      └──┬───┘                                            └──┬───┘
         │                                                    │
         │  (ctrl!=PROC)         (stn!=OFF/PARK && ctrl!=PROC)│
         │──────────────────────────────► on ◄────────────────┘
         │                                │
         │◄──────(ctrl==PROC)─────────────┘
         │                                │
         │  (stn==OFF||PARK)              │  (stn==OFF||PARK)
         └──────────► off ◄───────────────┘
```

### 5.5 HVPS Proc State — Processing/Protection Logic (Corrected)

> **Rev 4 correction**: Rev 3 described the proc state as only checking `klystron_forward_power > max_klystron_forward_power`. The actual source code checks **three independent conditions** for voltage decrease. Rev 3 also referenced a phantom PV `{STN}:HVPS:PCOLL_MAX` — no such PV exists in `rf_hvps_loop_pvs.h`. The correct PV is `{STN}:KLYSOUTFRWD:POWER:MAX`.

The `proc` state implements **cavity processing** — gradually ramping HVPS voltage while monitoring multiple safety conditions. Each cycle (event-driven via `hvps_loop_ready_ef`, or every `HVPS_LOOP_MAX_INTERVAL` = 10 s max):

**Step 1 — Module health checks** (any failure blocks further action):
1. RF Processor severity invalid → status = RFP_BAD
2. Klystron forward power severity invalid → status = POWR_BAD
3. Gap voltage severity invalid → status = GAPV_BAD
4. Cavity vacuum severity invalid → status = VACM_BAD
5. HVPS voltage readback severity invalid → status = VOLT_BAD

**Step 2 — Voltage direction decision** (3 conditions for decrease, from source):
```c
if ((klystron_forward_power > max_klystron_forward_power) ||  /* Condition 1 */
    (LOOP_MAJOR_SEVERITY(pvSeverity(gap_voltage_check)))  ||  /* Condition 2 */
    (LOOP_MAJOR_SEVERITY(pvSeverity(cavity_vacuum_check))))   /* Condition 3 */
{
    delta_hvps_voltage = delta_proc_voltage_down;  /* Decrease */
}
else
{
    delta_hvps_voltage = delta_proc_voltage_up;    /* Increase */
}
```

- **Condition 1**: Klystron forward power (`{STN}:KLYSOUTFRWD:POWER`) exceeds max forward power limit (`{STN}:KLYSOUTFRWD:POWER:MAX`)
- **Condition 2**: Cavity gap voltage check (`{STN}:CAVVOLT:CHECK`) has MAJOR severity — gap voltage is above setpoint
- **Condition 3**: Cavity vacuum check (`{STN}:CAVVACM:CHECK`) has MAJOR severity — worst cavity vacuum is too high

**Step 3 — Voltage application** via `HVPS_LOOP_SET_VOLTAGE()` macro (from `rf_hvps_loop_macs.h`):
1. Get current requested voltage
2. Add delta (positive for increase, negative for decrease)
3. Clamp to `[min_hvps_voltage, max_hvps_voltage]` range
4. Check readback–requested difference against `allowed_hvps_voltage_diff`
5. If difference exceeds limit for >10 cycles → status = VOLT_TOL
6. Put new voltage to `{STN}:HVPS:VOLT:CTRL`

**Rate**: Event-driven (external trigger via `hvps_loop_ready` PV) or maximum 10-second interval.

**Limitation**: Uses forward power as a **proxy** for collector dissipation — does not calculate actual DC collector power. The `max_klystron_forward_power` setpoint must be configured conservatively.

### 5.6 HVPS On State — Active Regulation

The `on` state maintains HVPS voltage to keep klystron drive power or station gap voltage constant:

- **ON_CW mode with direct loop**: Delta from `{STN}:KLYSDRIVFRWD:HVPS:DELTA` (negated) — adjusts HVPS voltage to stabilize drive power
- **TUNE mode or direct loop off**: Delta from `{STN}:STNVOLT:HVPS:DELTA` — adjusts HVPS voltage to stabilize gap voltage
- **Cavity voltage limit check**: If `gap_voltage_check` has MAJOR severity and delta is positive (increasing), blocks increase and reports CAVV_LIM after tolerance count exceeded
- **Tolerance monitoring**: Checks `dp_error_stat` (drive power error) and `gv_error_stat` (gap voltage error) for out-of-tolerance conditions → DRIV_TOL or GAPV_TOL

### 5.7 Upgrade Replacement Context

**Upgrade replacement** (PDR §11.3, Waveform Buffer System):
- **Direct calculation**: `Collector_Power = (HVPS_V × HVPS_I) − Klystron_Forward_Power`
- **Measurement**: HVPS voltage divider + current transformer → Waveform Buffer ADC inputs
- **Speed**: Continuous kHz-rate acquisition with hardware analog comparator trip (µs response)
- **Two layers**:
  1. **Fast (hardware)**: Analog comparator in Waveform Buffer → Interface Chassis permit trip
  2. **Slow (software)**: RF MPS PLC (ControlLogix) calculation → SCR permit removal

> **Upgrade action**: The CompactLogix PLC spec (B118 ladder logic) must replicate the collector protection function with the improved direct-power calculation. The legacy forward-power proxy tolerance margins should be documented as a baseline for commissioning validation. See PDR §4.5 for legacy implementation details and §11.3 for the upgrade approach.

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

The TAXI serial link connects GVF modules and provides timing signals. The `rf_msgsTAXI` state set within `rf_msgs.st` monitors the GVF TAXI link status via `{STN}:STN:GVF:MODU.TMCK` and, upon detecting a TAXI overflow error (`GVF_M_TAXIOFLW`), sends a resync command to the LFB (Low-Frequency Feedback) system. The implementation dynamically assigns the LFB PV based on the ring being serviced.

> **PDR terminology note**: PDR §2.1 (line 89) describes this as "CAMAC TAXI error monitoring". This is incorrect — TAXI is a VXI serial link protocol used by the GVF module, not a CAMAC feature. The source code (`rf_msgs.st,v`) explicitly references GVF module status bits and prints "Gvf Taxi error detected" on fault. CAMAC is a completely different bus standard not used in this system.

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
