# SPEAR3 Legacy LLRF Control System — Comprehensive Codebase Technical Report

**Document ID**: SPEAR3-LLRF-CTR-001
**Date**: March 18, 2026
**Author**: RF Department, SSRL/Accelerator (Codegen Analysis)
**Classification**: Engineering Technical Reference — Current System Analysis
**Purpose**: Comprehensive technical analysis of the legacy LLRF control system codebase to support the SPEAR3 LLRF Upgrade Project

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [Hardware Platform and Module Layer](#3-hardware-platform-and-module-layer)
4. [Software Architecture](#4-software-architecture)
5. [Master State Machine — rf_states.st](#5-master-state-machine--rf_statesst)
6. [DAC Control Loop — rf_dac_loop.st](#6-dac-control-loop--rf_dac_loopst)
7. [HVPS Supervisory Loop — rf_hvps_loop.st](#7-hvps-supervisory-loop--rf_hvps_loopst)
8. [Tuner Control Loop — rf_tuner_loop.st](#8-tuner-control-loop--rf_tuner_loopst)
9. [Calibration System — rf_calib.st](#9-calibration-system--rf_calibst)
10. [Diagnostics and Messaging — rf_msgs.st](#10-diagnostics-and-messaging--rf_msgsst)
11. [Key PV Interface Summary](#11-key-pv-interface-summary)
12. [Upgrade Considerations and Risk Areas](#12-upgrade-considerations-and-risk-areas)
13. [Appendices](#13-appendices)

---

## Glossary

| Term | Definition |
|------|-----------|
| **SNL** | State Notation Language — EPICS domain-specific language for finite state machines |
| **RFP** | RF Processor — Custom PEP-II VXI module for analog I/Q processing and DAC control |
| **GVF** | Gap Voltage Feedback — VXI module for gap voltage feed-forward and LFB woofer |
| **IQA** | I/Q Acquisition — VXI module for amplitude/phase detection |
| **AIM** | Accelerator Interface Module — VXI module for beam abort, filament, HVPS permissive |
| **CLK** | Clock Module — VXI module for RF clock generation and resynchronization |
| **CF2/CFM** | Comb Filter Module — VXI module for revolution harmonic filtering |
| **HVPS** | High Voltage Power Supply — Klystron cathode power supply (~74 kV, 22 A) |
| **PEP-II** | Positron-Electron Project II (B-Factory) — Original facility this system was designed for |
| **TAXI** | TAXI link — Serial fiber link used by LFB system; error recovery in rf_msgs.st |
| **DAC** | Digital-to-Analog Converter — 12-bit octal DACs on RFP module (±2048 counts) |
| **VXI** | VME eXtensions for Instrumentation — The hardware bus platform |
| **VxWorks** | Wind River real-time operating system running on the VXI crate processor |

---

## 1. Executive Summary

This report provides a comprehensive technical analysis of the complete legacy LLRF control system codebase for the SPEAR3 storage ring at SSRL. The system was originally designed for the PEP-II B-Factory (1996–1997) by S. Allison, R.C. Sass, M. Zelazny, P. Corredoura, R. Claus, and M. Laznovsky at SLAC, and has been in continuous operation for over 25 years.

### Codebase Summary

The software consists of **6 SNL programs** totaling **~7,112 lines of state machine code** plus **~1,168 lines of header/macro definitions**, compiled into a single VxWorks shared library (`rfSeq`). Below these sits a hardware module layer of custom EPICS record types, VXI device drivers, DSP firmware (assembly language), and Allen-Bradley PLC communication drivers.

| File | Lines | Function | Original Author |
|------|-------|----------|----------------|
| `rf_states.st` | 2,227 | Master state machine (OFF/PARK/TUNE/ON_FM/ON_CW), direct loop control, fault file writer | R.C. Sass (1997), S. Allison |
| `rf_calib.st` | 3,345 | Automated calibration: octal DAC nulling, IQ matrix, combining coefficients | R. Claus (1997), P. Corredoura, M. Laznovsky (2004 rewrite) |
| `rf_tuner_loop.st` | 555 | Per-cavity tuner stepper motor control (reentrant, 4 instances) | S. Allison (1996) |
| `rf_msgs.st` | 352 | Message logging, filament monitoring, HVPS fault logging, TAXI error recovery | S. Allison (1997) |
| `rf_hvps_loop.st` | 343 | HVPS voltage regulation: processing and on-state control | M. Zelazny (1997), S. Allison |
| `rf_dac_loop.st` | 290 | Drive power and gap voltage RFP/GFF DAC control | S. Allison (1997) |
| Header files (11) | 1,168 | PV declarations, macro definitions, status constants | Multiple |
| `Makefile` | 51 | Build system for rfSeq library | S. Allison, K. Luchini |
| `rfSeq.dbd` | 6 | EPICS database definition registrations | — |

### Key Findings for Upgrade

1. **The state machine is the operational contract.** The 5-state main sequence with its specific transition rules, timing delays, and fault-handling logic defines how the RF station behaves. The upgrade must preserve these operational semantics.
2. **Heavy macro usage hides actual logic.** The `DAC_LOOP_SET`, `HVPS_LOOP_SET_VOLTAGE`, and `TUNER_LOOP_*` macros contain the real control algorithms — the `.st` files alone are insufficient to understand the system.
3. **Calibration is the largest and most hardware-dependent component.** At 3,345 lines, `rf_calib.st` encodes detailed knowledge of analog hardware imperfections (octal DAC offsets, IQ matrix errors). Much of this will be eliminated by the LLRF9's digital architecture.
4. **Four distinct timescales coexist.** Analog feedback (~ms), digital supervisory loops (~0.5s), mechanical tuner control (~seconds), and event-driven state changes. The upgrade must maintain appropriate separation between these.
5. **Inter-program coupling is implicit.** The 6 programs communicate via EPICS PVs with timing assumptions (e.g., `taskDelay` calls between state transitions) that create hidden dependencies.
6. **PEP-II heritage code is still present.** Comb filter, GVF/LFB woofer, ON_FM (frequency modulation) mode, and TAXI error recovery are PEP-II features not used by SPEAR3 but still compiled in — some conditionally via `#define CF2`.

---

## 2. System Architecture Overview

### 2.1 Control Rate Hierarchy

The system operates on four distinct timescales, each with different hardware ownership:

```
FASTEST    Analog Feedback Loops (RFP module hardware, ~±90 kHz bandwidth)
           ├── Direct loop (cavity field stabilization — I/Q feedback)
           ├── Comb loop (revolution harmonic suppression — PEP-II, not SPEAR3)
           ├── Lead compensation (phase-lead for stability margin)
           └── Integral compensation (DC error elimination)

MEDIUM     Digital Supervisory Loops (~0.5–1 s period, SNL programs)
           ├── DAC loop (rf_dac_loop.st — setpoint adjustment)
           ├── HVPS loop (rf_hvps_loop.st — voltage regulation)
           └── Ripple loop (AC line harmonic cancellation)

SLOW       Mechanical Control Loop (~seconds)
           └── Tuner loop (rf_tuner_loop.st — stepper motor positioning)

EVENT      State Machine (asynchronous, event-driven)
           ├── Station state sequencing (rf_states.st)
           ├── Fault management and auto-recovery
           ├── Calibration (rf_calib.st)
           └── Message logging (rf_msgs.st)
```

**Stability requirement**: The bandwidth separation between adjacent tiers must be at least one decade to prevent inter-loop coupling instabilities:
$$f_{BW,\text{direct}} \gg f_{BW,\text{DAC}} \gg f_{BW,\text{tuner}}$$

### 2.2 Signal Flow

```
[476.3 MHz Reference] → [Clock Module] → [RFP Module]
                                              ↓
[4 Cavity Probes] → [IQA Modules] → [RFP I/Q Processing]
                                              ↓
                                    [Direct Loop (analog)]
                                              ↓
                          [Octal DACs: tune/operate/GFF setpoints]
                                              ↓
                                    [Drive Amplifier (~29 W)]
                                              ↓
                                        [KLYSTRON]
                                              ↓
                                    [Waveguide Distribution]
                                              ↓
                                      [4 RF Cavities]
```

### 2.3 Program Interaction Map

The 6 SNL programs interact through shared EPICS PVs. The primary interaction patterns are:

```
rf_states.st ──────────────────── (writes station state)
    │                                      ↓
    │   rf_dac_loop.st ─── (reads station state, writes DAC counts)
    │   rf_hvps_loop.st ── (reads station state, writes HVPS voltage)
    │   rf_tuner_loop.st ─ (reads station state, writes motor position) [x4]
    │   rf_calib.st ────── (reads station state, calibrates hardware)
    │   rf_msgs.st ─────── (reads station state, logs events)
    │
    └── All programs share the PV: {STN}:STN:STATE:RBCK (station state readback)
        All programs share the PV: {STN}:STN:STATE:CTRL (desired station state)
```

**Critical shared PVs between programs:**
- `{STN}:STN:STATE:RBCK` / `{STN}:STN:STATE:CTRL` — Station state (read by all)
- `{STN}:STN:RFP:MODU.DLE` — Direct loop enable status (read by DAC loop, HVPS loop)
- `{STN}:STN:RFP:RFENABLE` — RF switch (written by rf_states, monitored by rf_calib)
- `{STN}:HVPS:VOLT:CTRL` — HVPS voltage setpoint (written by rf_hvps_loop, read by rf_states)
- `{STN}:STN:AIM:FILAMENT` — Filament on/off (monitored by rf_msgs)
- `{STN}:STNOFF:SUMY:STAT.SEVR` — Fault summary severity (triggers OFF transition in rf_states)


---

## 3. Hardware Platform and Module Layer

### 3.1 VXI Module Hierarchy

The VXI crate hosts custom SLAC-designed modules, each with a corresponding custom EPICS record type and device support layer. Source files are in `rf-spear-legacy/rfApp/src/db/`:

| Module | Record Type | Device Support | Definition Header | Key Function |
|--------|-------------|---------------|-------------------|-------------|
| **RFP** (RF Processor) | `p2RfRfpRecord` | `devP2RfRfp.c` | `p2RfRfpDef.h` | Heart of fast feedback — octal DACs, I/Q processing, direct/comb loop, RF switch, run mode |
| **GVF** (Gap Voltage Feedback) | `p2RfGvfRecord` | `devP2RfGvf.c` | `p2RfGvfDef.h` | Gap feed-forward reference (I/Q), LFB woofer, TAXI link monitoring |
| **IQA** (I/Q Acquisition) | `p2RfIqaRecord` | `devP2RfIqa.c` | `p2RfIqaDef.h` | Amplitude/phase measurement (~1 MHz bandwidth), klystron drive and cavity probe detection |
| **AIM** (Accelerator Interface) | `p2RfAimRecord` | `devP2RfAim.c` | `p2RfAimDef.h` | Beam abort force/reset, filament control, HVPS permissive, fault history buffers |
| **CLK** (Clock) | `p2RfClkRecord` | `devP2RfClk.c` | `p2RfClkDef.h` | RF clock generation, resynchronization |
| **CF2** (Comb Filter v2) | `p2RfCf2Record` | `devP2RfCf2.c` | `p2RfCf2Def.h` | Digital narrowband filtering at revolution harmonics (history buffers, diagnostic recording) |
| **CFM** (Comb Filter original) | `p2RfCfmRecord` | `devP2RfCfm.c` | `p2RfCfmDef.h` | Original comb filter (superseded by CF2 on SPEAR3) |

**VXI Driver Layer**: `drvP2RfVxi.c` / `drvP2RfVxi.h` — Core VXI bus interface providing register-level access to all modules. The driver uses `p2RfLib.h` for shared data structures (`P2RfBufDsc` for waveform buffer descriptors).

### 3.2 DSP Firmware

The RFP and GVF modules contain embedded DSP processors (TMS320C16xx family). Firmware is in assembly language:

**RFP DSP** (`rf-spear-legacy/rfApp/src/dsp/rfpDsp/`):
- `ripple.s` / `sp3ripple.s` — AC line ripple rejection algorithm (SPEAR3-specific variant)
- `constDacs.s` — Constant DAC output mode
- `loadDacs.s` / `rampDacs.s` / `zeroDacs.s` — DAC loading utilities
- `dspSos.s` — Second-order section (SOS) IIR filter implementation
- `lusqrt.s` / `sqlu.s` — Fixed-point square root (for amplitude calculation)
- `vecTbl.s` — Interrupt vector table
- DSP definitions: `comDef.h`, `pioDef.h`, `timDef.h`, `intDef.h`, `aucDef.h`, `bioDef.h`

**GVF DSP** (`rf-spear-legacy/rfApp/src/dsp/gvfDsp/`):
- `gvff.s` — Gap voltage feed-forward main loop
- `wave_out.s` — Waveform output
- `sndMsg.s` — DSP-to-host message passing
- `comBlk.s` — Communication block management

**Observer DSP** (`rf-spear-legacy/rfApp/src/dsp/obsDsp/`):
- `adapt.s` — Adaptive filtering
- `iqTOap.s` / `apTOiq.s` — I/Q to amplitude/phase conversion and vice versa
- `atan.s` — Fixed-point arctangent
- `averPhas.s` — Phase averaging
- `Equaliz.s` — Signal equalization
- `dspSos.s` — Second-order section filter

**Upgrade implication**: These DSP algorithms are replaced entirely by the LLRF9's Spartan-6/Artix-7 FPGA implementation. The FPGA provides 270 ns loop delay vs. the legacy system's analog bandwidth. The ripple loop and observer algorithms are no longer needed.

### 3.3 Allen-Bradley PLC Communication

The VXI crate communicates with Allen-Bradley PLCs via serial link through a VME-based AB communication module:

**Driver source** (`rf-spear-legacy/allenBradley/`):
- `drvAb.c` / `drvAb.h` — Core AB driver for VME ↔ AB serial communication
- `1771DCMSrc/` — PLC-5 1771-DCM scanner device support (analog/digital/binary I/O records)
- `SLCDCMSrc/devABSLCDCM.c` — SLC-500 DCM device support (HVPS controller)
- `1746HSTP1Src/devSmAB1746HSTP1.c` — Stepper motor module device support (tuner motors)
- `basicSrc/devABBINARY.c` — Binary I/O device support for general AB modules

This entire AB communication stack is eliminated in the upgrade. The new system uses Ethernet/EPICS Channel Access for all PLC communication.

### 3.4 Stepper Motor / Tuner Subsystem

**Driver stack** (`rf-spear-legacy/stepper/`):
- `steppermotorRecord.c` / `steppermotorRecord.dbd` — Custom EPICS stepper motor record
- `steppermotor.h` — Stepper motor record field definitions
- `devSmAB1746HSTP1.c` — AB 1746-HSTP1 device support (sends step commands via AB serial)
- `drvOms.c` / `drvOms.h` — Oregon Micro Systems stepper driver (alternative)
- `devSmOms6Axis.c` — OMS 6-axis device support
- `drvCompuSm.c` / `devSmCompumotor1830.c` — Compumotor alternative driver

**Upgrade**: Replaced by Galil DMC-4143 motion controller with EPICS motor records over Ethernet. The Galil was commissioned August 2025 and is operational.

### 3.5 Supporting Infrastructure

**IOC Main** (`rf-spear-legacy/rfApp/src/rf/rfMain.cpp`): The VxWorks IOC entry point.

**Subroutine Records** (`rf-spear-legacy/rfApp/src/db/`):
- `subIQ.c` — IQ vector calculation subroutine (used by DAC loop for setpoint computation)
- `subSys.c` — System-level subroutine records

**Diagnostics** (`rf-spear-legacy/rfApp/src/diag/`):
- `rf_rfpDiags.c` — RFP module diagnostics
- `rf_ripTest.c` — Ripple loop test utilities
- `rf_vxi_diag.c` / `rf_vxi_diag.h` — VXI bus diagnostics

---

## 4. Software Architecture

### 4.1 Build System

The SNL programs are compiled via the EPICS build system:

```makefile
# From llrf/legacyLLRF/Makefile
TOP=../../..
include $(TOP)/configure/CONFIG
USR_INCLUDES += -I ../../db          # Access to record definition headers
LIBRARY_IOC_vxWorks = rfSeq          # Output: libRfSeq.a for VxWorks
DBD = rfSeq.dbd                       # Database definition file

rfSeq_SRCS += rf_tuner_loop.st
rfSeq_SRCS += rf_hvps_loop.st
rfSeq_SRCS += rf_states.st
rfSeq_SRCS += rf_dac_loop.st
rfSeq_SRCS += rf_calib.st
rfSeq_SRCS += rf_msgs.st
```

The SNL compiler (`snc`) translates `.st` files to C, which is then compiled for VxWorks and linked into the `rfSeq` library. The library is loaded by the IOC at boot time.

### 4.2 SNL Compilation Options

Each program specifies compilation options that affect runtime behavior:

| Program | `-a` (async gets) | `+c` (connect wait) | `+r` (reentrant) | `+d` (debug) | Notes |
|---------|:--:|:--:|:--:|:--:|-------|
| `rf_states.st` | `-a` (sync) | `+c` (yes) | `-r` (no) | `+d` (yes) | Single instance, debug enabled |
| `rf_dac_loop.st` | `-a` (sync) | `+c` (yes) | — | — | Single instance |
| `rf_hvps_loop.st` | `-a` (sync) | `+c` (yes) | — | — | Single instance |
| `rf_tuner_loop.st` | `-a` (sync) | `+c` (yes) | `+r` (yes) | — | **Reentrant** — 4 concurrent instances |
| `rf_calib.st` | `-a` (sync) | `+c` (yes) | `-r` (no) | — | Single instance, long-running |
| `rf_msgs.st` | `-a` (sync) | `+c` (yes) | — | — | Single instance |

**Key**: The `+c` option means all programs wait for all PV connections to be established before execution begins. The `-a` option means all `pvGet()` calls are synchronous (blocking). The `+r` option on `rf_tuner_loop.st` is critical — it allows 4 independent instances (one per cavity) to run concurrently with separate state.

### 4.3 Macro Parameterization

Programs are instantiated with EPICS macros:
- `STN` — Station name (e.g., `RFCA` for SPEAR3). Every PV is prefixed with `{STN}:`.
- `CAV` — Cavity identifier (used only by tuner loop: `A`, `B`, `C`, `D`)
- `name` — Task name for VxWorks process identification and logging

### 4.4 Header/Macro Architecture

The code uses a layered header structure where **C preprocessor macros implement the core algorithms**:

```
rf_loop_defs.h          ←── Shared: station state constants, severity check macros
rf_loop_macs.h          ←── Shared: MACRO_TASK_NAME, MACRO_STN_NAME

rf_dac_loop_defs.h      ←── DAC loop status constants (15 states)
rf_dac_loop_macs.h      ←── DAC_LOOP_SET(), DAC_LOOP_CHECK_STATUS(), DAC_LOOP_OFF()
rf_dac_loop_pvs.h       ←── DAC loop PV declarations (~30 PVs)

rf_hvps_loop_defs.h     ←── HVPS loop status constants (16 states)
rf_hvps_loop_macs.h     ←── HVPS_LOOP_SET_VOLTAGE(), HVPS_LOOP_CHECK_STATUS()
rf_hvps_loop_pvs.h      ←── HVPS loop PV declarations (~25 PVs)

rf_tuner_loop_defs.h    ←── Tuner loop status constants, timing parameters
rf_tuner_loop_macs.h    ←── TUNER_LOOP_HOME(), TUNER_LOOP_INIT_FLAGS(), state update macros
rf_tuner_loop_pvs.h     ←── Tuner loop PV declarations (~20 PVs per cavity)
```

**Why this matters for the upgrade**: The macro definitions contain the actual control algorithms. For example, `HVPS_LOOP_SET_VOLTAGE()` (in `rf_hvps_loop_macs.h`) implements voltage clamping, tolerance checking, and voltage history recording — none of which is visible in the `.st` file itself.

### 4.5 Severity-Based Logic

A distinctive pattern throughout the codebase is the use of EPICS alarm severity as control flow:

```c
/* From rf_loop_defs.h */
#define LOOP_INVALID_SEVERITY(arg) ((arg) >= INVALID_ALARM)
#define LOOP_MAJOR_SEVERITY(arg)   ((arg) >= MAJOR_ALARM)
#define LOOP_MINOR_SEVERITY(arg)   ((arg) >= MINOR_ALARM)
```

These macros are used pervasively to check hardware health:
- `LOOP_INVALID_SEVERITY(pvSeverity(rf_processor_severity))` — Is the RFP module online?
- `LOOP_MAJOR_SEVERITY(pvSeverity(gap_voltage_check))` — Is gap voltage above the alarm threshold?
- `LOOP_INVALID_SEVERITY(pvSeverity(klystron_forward_power))` — Is klystron power reading valid?

**Upgrade implication**: The upgraded system should implement equivalent health-checking through EPICS alarm severity on the new PVs. This pattern should be preserved in the new Python/EPICS coordinator.


---

## 5. Master State Machine — rf_states.st

### 5.1 Overview

`rf_states.st` (2,227 lines, R.C. Sass 1997) is the master station control program. It defines the operational states of the RF station and manages all transitions between them. It consists of **3 state sets** that execute concurrently:

1. **`rf_states`** — Main state machine (station operational states)
2. **`rf_statesLP`** — Direct loop / comb loop control (gain ramping, compensation enabling)
3. **`rf_statesFF`** — Fault file writer (captures VXI module data after faults)

### 5.2 Station State Definitions

States are defined in `rf_station_state.h` (included via `rf_loop_defs.h`):

| State | Value | Description |
|-------|-------|-------------|
| `STATION_OFF` | 0 | All RF systems powered down. Safe state. |
| `STATION_PARK` | 1 | Tuners parked, HVPS standby. No RF power. |
| `STATION_TUNE` | 2 | Low-power operation. HVPS on, RF switch on, tune-mode DACs. Cavity conditioning. |
| `STATION_ON_FM` | 3 | Frequency modulation mode (PEP-II heritage, not typically used on SPEAR3) |
| `STATION_ON_CW` | 4 | Full CW operation. Direct/comb loops enabled. Beam delivery mode. |

### 5.3 Legal State Transition Matrix

```
From ╲ To →   OFF    PARK   TUNE   ON_FM   ON_CW
    ↓
   OFF         —      Y      Y      Y       Y
   PARK        Y      —      —      —       —
   TUNE        Y      —      —      —       Y
   ON_FM       Y      —      Y      —       —
   ON_CW       Y      —      Y      —       —
```

**Key observations:**
- OFF is the universal reset state — all other states can go to OFF
- PARK is a dead end — can only return to OFF
- TUNE can go directly to ON_CW (bypassing ON_FM)
- ON_CW and ON_FM can go to TUNE (step down) or OFF (emergency)
- There is no direct path from PARK to TUNE or any ON state — must go through OFF first

### 5.4 State Transition Details

#### OFF → PARK
**Conditions**: `park_noon == NO_ALARM` (no park-preventing faults)
**Actions**:
1. Zero HVPS requested voltage
2. Force beam abort
3. Set tuner park positions
4. Move station to PARK state

#### OFF → TUNE
**Conditions**: `fault_noon == NO_ALARM && panel_onoff == NO_ALARM` (no faults, local panel OK)
**Actions**:
1. Zero HVPS requested voltage
2. Reset beam abort
3. Reset AIM faults
4. Resynchronize clock module
5. Set RFP to LOAD state
6. Set DACs to TUNE mode setpoints
7. Set RFP run mode = TUNE
8. Enable RF switch
9. Set HVPS triggers ON
10. Wait for settle time (`volt_settle_time`)
11. Set tuners to ON home positions
12. Update state readback to TUNE

#### TUNE → ON_CW
**Actions**:
1. Set DAC file control to LOAD
2. Set RFP run mode = OPERATE
3. Load ON_CW DAC setpoints
4. Set RFP state to RUN
5. Set DACs ON
6. Process direct loop transition sequence
7. Enable fast turnon if conditions met (`directlpcontrol == LOOP_CONTROL_ON`)
8. Signal direct loop state set to start ramping

#### Fault Transitions (any ON-state → OFF)
**Trigger**: `fault_stnoff != NO_ALARM` (fault summary exceeds threshold)
**Actions**:
1. Turn off RF switch
2. Zero HVPS requested voltage
3. Force beam abort
4. Turn off all loops (direct, lead compensation, integral compensation, comb)
5. Write fault files (triggers `rf_statesFF` state set)
6. Log fault message
7. Attempt auto-reset if retry count > 0 and contactor status is OK

### 5.5 Auto-Reset Logic

When a fault transitions the station to OFF, the auto-reset mechanism attempts to bring it back online:

```
if (stn_reset > 0 && contactor_noon == NO_ALARM) {
    reset_count = stn_reset;
    decrement reset_count;
    delay(RESET_WAIT);    // 120 seconds (2 minutes)
    reset AIM faults;
    attempt transition to previous state (TUNE or ON_CW);
}
```

The retry count (`stn_reset`) is operator-configurable. Each retry decrements the counter. If all retries are exhausted, the station remains in OFF.

**Upgrade implication**: The auto-reset logic is a critical operational feature. The new EPICS coordinator must implement equivalent auto-recovery with configurable retry counts and appropriate delays.

### 5.6 Direct Loop Control State Set (rf_statesLP)

This concurrent state set manages the direct loop, lead compensation, integral compensation, and comb loop. It implements a carefully sequenced gain ramping procedure:

```
s_lp_check → (direct loop ON requested) → s_gv_down
    ↓ (wait for gap voltage to settle)
s_gv_down → s_direct_ramp
    ↓ (ramp direct loop gain incrementally)
s_direct_ramp → (enable lead compensation) → (enable integral compensation)
    ↓ (gain offset reaches 0)
s_direct_ramp → s_comb_ramp (if comb loop requested)
    ↓ (ramp comb gain incrementally)
s_comb_ramp → s_gv_up
    ↓ (wait for gap voltage to increase, reset beam abort)
s_gv_up → s_lp_check
```

**Key detail**: When turning the direct loop ON, the system:
1. Restores drive power and gap voltage settings
2. Waits for `volt_settle_time` for gap voltage to stabilize
3. Enables the direct loop with a gain offset (negative value)
4. Incrementally ramps gain by `directlpgaindelta` each `ramp_settle_time`
5. Only after gain reaches 0 does it enable lead/integral compensation
6. Only after compensation is stable does it enable the comb loop (if requested)
7. Finally restores drive power and resets beam abort

**Safety constraint**: Once the beam abort has been reset and the station is in ON_CW with the direct loop on, the direct loop cannot be turned off without first taking the station out of ON_CW. This prevents the operator from accidentally removing the fast feedback while beam is present.

### 5.7 Fault File Writer State Set (rf_statesFF)

Triggered by the `ffwrite_ef` event flag when a fault occurs. It:
1. Increments the fault number counter (wraps after `NUMFAULTS`)
2. Records the timestamp
3. Sets RFP, CFM, and GVF modules to LOAD state (freezes waveform buffers)
4. Writes fault data to numbered files (`/dat/FAULTxxxx_N` where N is fault number)
5. Waits for file writes to complete (up to `MAXFFWAIT` iterations)
6. Restores module states and filenames

**Files captured**: RFP, GVF, CFM1, CFM2, and AIM module waveform buffers (11 files total, defined by `NUMFFILES`).

---

## 6. DAC Control Loop — rf_dac_loop.st

### 6.1 Purpose

`rf_dac_loop.st` (290 lines, S. Allison 1997) adjusts the amplitude (in counts) of the RFP octal DAC setpoints or GVF feed-forward reference values to regulate either drive power (in TUNE mode) or gap voltage (in ON_CW mode).

### 6.2 States

| State | Condition | Function |
|-------|-----------|----------|
| `loop_init` | Always first | Initialize flags, clear event flags |
| `loop_off` | Station OFF, PARK, or ON_FM | Idle; only force-update DACs on phase/amplitude change |
| `loop_tune` | Station in TUNE | Adjust drive power via RFP tune-mode octal DACs |
| `loop_on` | Station in ON_CW | Adjust gap voltage or drive power depending on direct loop and GVF availability |

### 6.3 Core Algorithm (DAC_LOOP_SET macro)

The `DAC_LOOP_SET` macro in `rf_dac_loop_macs.h` implements the control algorithm:

1. **Check RFP health**: If RF processor severity is INVALID, report bad status
2. **Check if loop is OFF**: If control is off, only update on phase changes
3. **Get current counts and delta**: Read current DAC value and computed error delta
4. **Check delta validity**: Verify delta measurement severity is acceptable
5. **Drive power guard**: If gap voltage is in LOLO alarm and delta is positive (increasing), block the increase to protect against excessive drive power
6. **Consistency check**: If previously controlling, verify current counts match expected value. If they differ (indicating external modification), log a warning
7. **Apply delta**: `counts = counts + delta_counts`
8. **Clamp**: Ensure counts stays within ±2047 (12-bit DAC range)
9. **Write if changed**: Only write new count value if the change exceeds `DAC_LOOP_MIN_DELTA_COUNTS` (0.5 counts)

### 6.4 Operating Mode Logic (ON_CW)

In ON_CW, the DAC loop behavior depends on two conditions:
- **Direct loop state** (on/off)
- **GVF module availability** (online/offline)

| Direct Loop | GVF Available | Action |
|:-----------:|:------------:|--------|
| OFF | No | Adjust drive power via RFP operate-mode DACs |
| OFF | Yes | Adjust drive power via GFF feed-forward reference |
| ON | No | Adjust gap voltage via RFP operate-mode DACs |
| ON | Yes | Adjust gap voltage via GFF feed-forward reference |

This 4-way branching handles all possible degraded-mode combinations.

### 6.5 Ripple Loop Integration

The DAC loop also manages the ripple loop amplitude setpoint. When the ripple loop amplitude PV changes, it's loaded at a slower rate (gated by `ripple_loop_ready_ef`). This prevents rapid ripple corrections from destabilizing the main DAC loop.

---

## 7. HVPS Supervisory Loop — rf_hvps_loop.st

### 7.1 Purpose

`rf_hvps_loop.st` (343 lines, M. Zelazny 1997) controls the klystron high voltage power supply. It has two primary functions:
1. **Processing mode**: Gradually ramp HVPS voltage while conditioning cavities (managing vacuum, forward power, and gap voltage)
2. **On mode**: Maintain stable klystron drive power or gap voltage by adjusting HVPS voltage

### 7.2 States

| State | Condition | Function |
|-------|-----------|----------|
| `init` | Always first | Set initial voltage to current readback, initialize status |
| `off` | Station OFF or PARK | Idle |
| `proc` | `hvps_loop_ctrl == HVPS_LOOP_CONTROL_PROC` | Cavity processing — ramp voltage up/down based on conditions |
| `on` | Other (default active) | Normal operation — maintain voltage for stable drive/gap |

### 7.3 Processing Mode Algorithm

Runs at ~0.5s intervals (triggered by `hvps_loop_ready_ef` or 10s timeout):

1. **Hardware health checks** (in priority order):
   - RFP module severity → `HVPS_LOOP_STATUS_RFP_BAD`
   - Klystron forward power severity → `HVPS_LOOP_STATUS_POWR_BAD`
   - Gap voltage severity → `HVPS_LOOP_STATUS_GAPV_BAD`
   - Cavity vacuum severity → `HVPS_LOOP_STATUS_VACM_BAD`
   - HVPS voltage readback severity → `HVPS_LOOP_STATUS_VOLT_BAD`

2. **Voltage adjustment** (if all health checks pass):
   - If klystron forward power > max, OR gap voltage > limit, OR vacuum too high → **decrease voltage** by `delta_proc_voltage_down`
   - Otherwise → **increase voltage** by `delta_proc_voltage_up`

3. **Apply via HVPS_LOOP_SET_VOLTAGE()**: Clamp within [min, max], check readback vs. request tolerance

### 7.4 On-Mode Algorithm

When the station is in TUNE or ON_CW:

- **TUNE / Direct loop OFF**: Uses `delta_tune_voltage` (computed from gap voltage error)
- **ON_CW with direct loop ON**: Uses `-delta_on_voltage` (computed from drive power error — note the sign inversion)

**Cavity voltage limit guard**: If gap voltage check shows MAJOR severity (above limit) and the delta would increase voltage, the move is blocked. After `HVPS_LOOP_MAX_VOLT_TOL` (10) consecutive blocked cycles, status changes to `HVPS_LOOP_STATUS_CAVV_LIM`.

### 7.5 HVPS_LOOP_SET_VOLTAGE Macro Detail

The `HVPS_LOOP_SET_VOLTAGE()` macro implements:

```
1. Read current requested voltage
2. Add delta voltage
3. Clamp to [min_hvps_voltage, max_hvps_voltage]
4. Check |readback - previous_request| > allowed_diff
   → If out of tolerance: hold previous value, increment tolerance counter
   → If tolerance count > 10: report VOLT_TOL status
5. Write new requested voltage
6. Record in voltage history
```

**Key parameter PVs:**
- `{STN}:HVPS:VOLT:CTRL` — Requested voltage (written)
- `{STN}:HVPS:VOLT` — Readback voltage (read)
- `{STN}:HVPS:VOLT:MIN` / `{STN}:HVPS:VOLT:CTRL.DRVH` — Voltage limits
- `{STN}:HVPS:LOOP:VOLTDIFF` — Allowed readback-request difference
- `{STN}:HVPS:LOOP:VOLTDOWN` / `{STN}:HVPS:LOOP:VOLTUP` — Processing delta voltages

---

## 8. Tuner Control Loop — rf_tuner_loop.st

### 8.1 Purpose

`rf_tuner_loop.st` (555 lines, S. Allison 1996) controls the mechanical cavity tuners. It runs as **4 reentrant instances** (one per cavity: A, B, C, D), each managing an independent stepper motor.

### 8.2 States

| State | Condition | Function |
|-------|-----------|----------|
| `loop_init` | Always first | Initialize status, clear event flags |
| `loop_unknown` | After init or reset | Determine starting state based on previous loop state |
| `loop_reset` | Reset requested | Move tuner to home position (ON or PARK) |
| `loop_off` | Station OFF | Idle; process home/park requests |
| `loop_on` | Station PARK/TUNE/ON_FM/ON_CW | Active control |

### 8.3 Active Control Algorithm (loop_on)

Triggered by `loop_ready_ef` (from database-driven scan rate):

1. **Count fresh measurements**: Track `meas_count` and `dmov_meas_count` (measurements while motor done moving)
2. **Health checks** (in priority order):
   - Loop control OFF → `LOOP_OFF_STATUS`
   - No measurements received → `LOOP_PHASMISS_STATUS`
   - Motor not done moving for too long → `LOOP_SM_MOVE_STATUS`
   - Not enough done-moving measurements → increment nonfunctional counter
   - Station in ON_FM → `LOOP_ON_FM_STATUS` (no tuner control in FM mode)

3. **Position calculation** (if healthy):
   - Read `posn_delta` (computed by database from cavity phase vs. reference)
   - Check phase measurement validity
   - Check minimum klystron forward power (`klys_frwd_pwr_min`) — don't tune if power too low
   - Check load angle severity (inter-cavity balance)
   - Compute: `posn_new = sm_posn + posn_delta`
   - Clamp to drive limits: `[sm_drvl, sm_drvh]`
   - **Consistency check**: If previous command position doesn't match current motor position (within deadband `sm_rdbd`), report `LOOP_SM_CTRL_STATUS` — indicates external interference

4. **Write motor command**: `pvPut(posn_ctrl)` if position changed

5. **Load angle offset processing**: After position update, process phase offset (for inter-cavity power balancing)

### 8.4 Home Reset Procedure

The reset procedure moves the tuner to a known position:

1. Read home position (ON or PARK, depending on current station state)
2. Read position monitor delta (MDEL) and calculate tolerance
3. Attempt up to `LOOP_RESET_COUNT` iterations:
   a. Wait for potentiometer reading to update
   b. Read current position from potentiometer AND stepper motor
   c. If both readings valid and motor not moving:
      - Calculate delta = home_position - current_potentiometer_position
      - If within tolerance → done
      - Else: command motor to `sm_posn + delta`
      - Wait for motor to finish moving
4. If first attempt fails (bad position readings), abort reset

**Important**: The home reset uses the potentiometer for absolute position reference but commands via the stepper motor's relative position — compensating for the difference between the two position sources.

### 8.5 Load Angle Offset

The load angle offset loop redistributes power across cavities by adjusting individual tuner phase setpoints. In the legacy system, this is triggered by `phase_offset_proc` after each tuner position update. The actual computation happens in an EPICS database subroutine record, not in the SNL code.

**Upgrade mapping**: This becomes a separate Python module (`load_angle_controller.py`) reading all 4 cavity probe amplitudes from LLRF9 and adjusting individual tuner phase offset PVs.


---

## 9. Calibration System — rf_calib.st

### 9.1 Overview

`rf_calib.st` (3,345 lines, R. Claus 1997, major rewrite by M. Laznovsky 2004) is the largest source file and implements automated calibration of the analog RF processing chain. It performs iterative nulling of hardware offset errors in the RFP module's octal DACs and IQ processing matrices.

### 9.2 Calibration Targets

The calibration system nulls offsets in these hardware subsystems:

| Target | PV Pattern | Hardware | Nulling Method |
|--------|-----------|----------|---------------|
| **Combining matrix coefficients** | `{STN}:STN:RFP:CAVk.A/C/E/G` (4x4 = 16 values) | Per-cavity IQ combining weights | Iterative binary search |
| **Combining matrix offsets** | `{STN}:STN:RFP:CAVk.B/D/F/H` (4x4 = 16 values) | Per-cavity IQ offset corrections | Iterative nulling |
| **Combining output offsets** | `{STN}:STN:RFP:MODU.CO1I/Q..CO4I/Q` (8 values) | Per-cavity output I/Q offsets | DAC nulling |
| **Direct loop coefficients** | `{STN}:STN:RFP:DIRECT.A/C/E/G` (4 values) | Direct loop IQ matrix | Save/restore during cal |
| **Direct loop offsets** | `{STN}:STN:RFP:DIRECT.B/D/F/H` (4 values) | Direct loop I/Q offsets | DAC nulling |
| **Comb loop coefficients** | `{STN}:STN:RFP:COMB.A/C/E/G` (4 values) | Comb loop IQ matrix | Save/restore during cal |
| **Sum node offsets** | `{STN}:STN:RFP:MODU.SNIO/SNQO` (2 values) | Sum node I/Q offsets | DAC nulling |
| **Gain stage offsets** | `{STN}:STN:RFP:MODU.GO1I/Q..GO4I/Q` (8 values) | Gain stage I/Q offsets | DAC nulling |
| **Klystron modulator offsets** | `{STN}:STN:RFP:MODU.KMII/IQ/QI/QQ` + `KLIO/KLQO` (6 values) | Klystron IQ matrix and offsets | DAC nulling |
| **RF modulator offsets** | `{STN}:STN:RFP:MODU.RFIO/RFQO` (2 values) | RF modulator I/Q offsets | DAC nulling |
| **Compensation stage offsets** | `{STN}:STN:RFP:MODU.CSIO/CSQO` (2 values) | Compensation stage offsets | DAC nulling |
| **Difference node offsets** | `{STN}:STN:RFP:MODU.DNIO/DNQO` (2 values) | Difference node offsets | DAC nulling |
| **Klystron demodulator offsets** | `{STN}:STN:RFP:MODU.KLOI/KLOQ` (2 values) | Klystron demod offsets | DAC nulling |
| **Tune setpoints** | `{STN}:STN:RFP:TUNE.A/C` + offsets `.B/.D` (4 values) | Tune mode IQ setpoints | Save/restore |

### 9.3 Calibration Algorithm

The core algorithm is a binary-search-based iterative nulling procedure:

1. **Setup**: Save current values of all DAC settings. Disable RF, direct loop, comb loop, ripple loop, and integral/lead compensation.
2. **For each calibration target**:
   a. Set the RFP feedback signal to route through the specific signal path being calibrated
   b. Acquire 30,000 words of data and compute average offset
   c. Apply `P2RF_UpdateSetPt()` — a binary search that adjusts the DAC value to drive the measured offset toward zero
   d. Iterate up to `MAX_ATTEMPTS` (50) times until the error is within `MARGIN` (1 count) or `BIG_MARGIN` (2–4 counts for certain targets)
3. **Restore**: Restore all saved settings and re-enable disabled loops

**Key parameters:**
- `COUNT = 30000` — Words of data averaged per measurement
- `MAX_ATTEMPTS = 50` — Maximum iterations per target
- `MARGIN = 1` — Acceptable error for most targets (1 DAC count)
- `BIG_MARGIN = 2` — Acceptable error for tune setpoints
- `BIG_MARGIN2 = 4` — Acceptable error for klystron/compensation stages
- `MAX_DAC = 2047` / `MIN_DAC = -2048` — Full 12-bit DAC range
- `ZERO_ATTEMPTS = 11` — Iterations for zeroing operations

### 9.4 Runtime and History

- **Original runtime**: ~20 minutes (1997 version, ~4630 lines)
- **Optimized runtime**: ~3 minutes (2004 rewrite by M. Laznovsky, ~2800 lines)
- **Current version**: 3,345 lines (includes subsequent additions: DiffNodeOffsets, KlysDemod states)

### 9.5 Upgrade Implications

**Most of this code becomes unnecessary.** The LLRF9's digital FPGA architecture does not have:
- Analog octal DACs requiring offset nulling
- Analog IQ combining matrices with drift
- Analog modulator/demodulator offset errors

The LLRF9 performs IQ processing entirely in the digital domain where offsets are deterministic and correctable in firmware. However, **some calibration concepts survive in new form**:
- The LLRF9 has its own calibration procedures (managed by Dmitry's MATLAB tools)
- The combining matrix concept maps to the LLRF9's digital weighting of cavity probe signals
- Amplitude/phase calibration of RF input channels is still required (different implementation)

---

## 10. Diagnostics and Messaging — rf_msgs.st

### 10.1 Overview

`rf_msgs.st` (352 lines, S. Allison 1997) provides two concurrent state sets:
1. **`rf_msgs`** — General message logging for operational events
2. **`rf_msgsTAXI`** — TAXI link error detection and LFB resynchronization

### 10.2 Message Logging (rf_msgs state set)

Uses C preprocessor macros for pattern-based event monitoring:

```c
/* Log when a channel changes to non-zero */
CHECK_MSG(channel, channel_ef, string)

/* Log on/off transitions */
CHECK_ONOFF_MSG(channel, channel_ef, string, line)

/* Log HVPS faults only when station is on and no other faults */
CHECK_HVPS_MSG(channel, channel_ef, string)
```

**Monitored events:**
- HVPS trip reset
- Filament timer bypass
- Filament on/off
- Station online/offline
- Filament fault → automatic contactor open
- HVPS-specific faults (12kV, Enerpro fast/slow, supply, SCR1/2)

**Filament protection logic**: When `filament_sumy` goes to zero (filament fault summary), the code automatically opens the HVPS contactor:
```c
when (efTestAndClear(filament_sumy_ef) && (!filament_sumy)) {
    pvGet(contactor);
    if (contactor) {
        contactor = 0;
        pvPut(contactor);  // Open contactor
    }
}
```

### 10.3 TAXI Error Recovery (rf_msgsTAXI state set)

The TAXI link is a serial fiber connection used by the LFB (Low-Frequency Beam feedback) system. When a TAXI overflow error is detected in the GVF module status register:

1. Wait a random 0.5–4 seconds (to prevent multiple IOCs from all resynchronizing simultaneously)
2. Force a TAXI status check
3. If error persists, send a resynchronization command to the LFB system
4. Log the event

**Ring-dependent PV assignment**: The TAXI resync PV is dynamically assigned based on the ring:
- HER (ring == 0): `LFB0FSH:WF:SINGLE_SYNC`
- LER (ring == 1): `LFB0FSL:WF:SINGLE_SYNC`

**Upgrade note**: The TAXI link and LFB system are PEP-II components not used on SPEAR3. This entire state set is dead code for SPEAR3 operations but remains compiled in.

---

## 11. Key PV Interface Summary

### 11.1 Station State PVs

| PV | Type | Direction | Used By | Description |
|----|------|-----------|---------|-------------|
| `{STN}:STN:STATE:CTRL` | int | Write (states), Read (all) | rf_states → all | Desired station state |
| `{STN}:STN:STATE:RBCK` | int | Write (states), Read (all) | rf_states → all | Current station state readback |
| `{STN}:STN:STATE:STRING` | string | Write | rf_states | Human-readable state string |
| `{STN}:STN:RESET:CTRL` | int | Read/Write | rf_states | Auto-reset retry count |
| `{STN}:STNOFF:SUMY:STAT.SEVR` | int | Read (monitor) | rf_states | Station-off fault summary severity |
| `{STN}:STNON:SUMY:STAT.SEVR` | int | Read (monitor) | rf_states | Station-on fault summary severity |

### 11.2 HVPS Control PVs

| PV | Type | Direction | Description |
|----|------|-----------|-------------|
| `{STN}:HVPS:VOLT:CTRL` | float | Write | Requested HVPS voltage setpoint |
| `{STN}:HVPS:VOLT` | float | Read | HVPS voltage readback |
| `{STN}:HVPS:VOLT:MIN` | float | Read | Minimum HVPS voltage |
| `{STN}:HVPS:VOLT:CTRL.DRVH` | float | Read | Maximum HVPS voltage (drive high) |
| `{STN}:HVPS:LOOP:CTRL` | int | Read | HVPS loop control mode (OFF/PROC/ON) |
| `{STN}:HVPS:LOOP:STATE` | int | Write | HVPS loop current state |
| `{STN}:HVPS:LOOP:STATUS` | int | Write | HVPS loop status code |
| `{STN}:HVPS:LOOP:VOLTDIFF` | float | Read | Allowed voltage readback tolerance |
| `{STN}:HVPS:LOOP:VOLTDOWN` | float | Read | Processing mode voltage decrease step |
| `{STN}:HVPS:LOOP:VOLTUP` | float | Read | Processing mode voltage increase step |
| `{STN}:HVPSSCR:ON:CTRL` | int | Write | HVPS SCR trigger enable |
| `{STN}:KLYSOUTFRWD:POWER` | float | Read | Klystron forward power readback |
| `{STN}:KLYSOUTFRWD:POWER:MAX` | float | Read | Maximum klystron forward power limit |

### 11.3 DAC Loop PVs

| PV | Type | Direction | Description |
|----|------|-----------|-------------|
| `{STN}:STN:TUNE:CTRL` | int | Read | Tune loop control (on/off) |
| `{STN}:STN:ON:CTRL` | int | Read | On loop control (on/off) |
| `{STN}:STN:TUNE:IQ.A` | float | Read/Write | Tune mode DAC amplitude (counts) |
| `{STN}:STN:ON:IQ.A` | float | Read/Write | On mode DAC amplitude (counts) |
| `{STN}:STN:GFF:IQ.A` | float | Read/Write | GFF mode DAC amplitude (counts) |
| `{STN}:KLYSDRIVFRWD:DAC:DELTA` | float | Read | Drive power DAC delta (tune mode) |
| `{STN}:STNVOLT:DAC:DELTA` | float | Read | Gap voltage DAC delta (on mode) |

### 11.4 Tuner Loop PVs (per cavity, {CAV} = A/B/C/D)

| PV | Type | Direction | Description |
|----|------|-----------|-------------|
| `{STN}:CAV{CAV}TUNR:SM.VAL` | float | Write | Stepper motor commanded position |
| `{STN}:CAV{CAV}TUNR:SM.RBV` | float | Read | Stepper motor readback position |
| `{STN}:CAV{CAV}TUNR:SM.DMOV` | int | Read | Done moving flag |
| `{STN}:CAV{CAV}TUNR:SM.DRVH` | float | Read | Upper drive limit |
| `{STN}:CAV{CAV}TUNR:SM.DRVL` | float | Read | Lower drive limit |
| `{STN}:CAV{CAV}TUNR:SM.RDBD` | float | Read | Retry deadband |
| `{STN}:CAV{CAV}TUNR:POSN` | float | Read | Potentiometer position (absolute) |
| `{STN}:CAV{CAV}TUNR:DELTA` | float | Read | Phase-based position delta |

### 11.5 Hardware Module PVs

| PV | Type | Description |
|----|------|-------------|
| `{STN}:STN:RFP:MODU.SEVR` | int | RFP module severity (INVALID = offline) |
| `{STN}:STN:RFP:RFENABLE` | int | RF switch enable |
| `{STN}:STN:RFP:RUNMODE` | int | Run mode (TUNE=0, OPERATE=1) |
| `{STN}:STN:RFP:DIRECTLOOP` | int | Direct loop enable |
| `{STN}:STN:RFP:COMBLOOP` | int | Comb loop enable |
| `{STN}:STN:RFP:LEADCOMP` | int | Lead compensation enable |
| `{STN}:STN:RFP:INTCOMP` | int | Integral compensation enable |
| `{STN}:STN:RFP:DACS` | int | DAC on/off control |
| `{STN}:STN:RFP:STATE` | int | RFP state (RESET/LOAD/RUN) |
| `{STN}:STN:GVF:MODU.SEVR` | int | GVF module severity |
| `{STN}:STN:AIM:MODU.HVPS` | long | AIM HVPS permissive |
| `{STN}:STN:AIM:FRCBMABT` | int | Force beam abort |
| `{STN}:STN:AIM:MODU.RBA` | int | Reset beam abort |
| `{STN}:STN:AIM:FILAMENT` | int | Filament on/off |
| `{STN}:STN:CLK:MODU.RSYN` | int | Clock module resynchronize |

---

## 12. Upgrade Considerations and Risk Areas

### 12.1 Functions That Must Be Preserved

These operational functions are essential to SPEAR3 operations and must be replicated in the upgrade:

| Function | Legacy Implementation | Upgrade Implementation | Critical? |
|----------|---------------------|----------------------|:---------:|
| 5-state station sequencing | `rf_states.st` main state set | Python/EPICS coordinator state machine | **Yes** |
| Auto-reset after fault | `rf_states.st` auto-reset logic | Python coordinator with configurable retries | **Yes** |
| HVPS voltage regulation (processing mode) | `rf_hvps_loop.st` proc state | CompactLogix PLC + Python coordinator | **Yes** |
| HVPS voltage regulation (on mode) | `rf_hvps_loop.st` on state | CompactLogix PLC + Python coordinator | **Yes** |
| Tuner phase-based control | `rf_tuner_loop.st` (x4) | LLRF9 phase data → Python → Galil DMC-4143 | **Yes** |
| Load angle offset balancing | Subroutine record via `rf_tuner_loop.st` | Python `load_angle_controller.py` module | **Yes** |
| Gap voltage / drive power regulation | `rf_dac_loop.st` | LLRF9 internal control + Python coordinator | **Yes** |
| Fault file capture | `rf_statesFF` state set | LLRF9 16k waveform + Waveform Buffer circular buffers | **Yes** |
| Direct loop gain ramping | `rf_statesLP` state set | LLRF9 setpoint profiles (512 points, 70µs–37ms/step) | **Yes** |
| Collector power protection | `rf_hvps_loop.st` forward power limit | Waveform Buffer DC power calculation + RF MPS | **Yes** |
| Filament fault → contactor open | `rf_msgs.st` | RF MPS PLC | **Yes** |
| Message logging | `rf_msgs.st` | Python coordinator structured logging | Medium |

### 12.2 Functions Eliminated by New Hardware

These functions exist because of legacy analog hardware limitations and are no longer needed:

| Function | Why It Existed | Why It's Eliminated |
|----------|---------------|-------------------|
| Octal DAC offset calibration | Analog DAC drift and manufacturing offsets | LLRF9 uses digital processing — no analog DAC offsets |
| IQ combining matrix calibration | Analog IQ mixer imperfections | LLRF9 does IQ processing digitally in FPGA |
| Comb loop and CFM modules | PEP-II multi-bunch instability suppression | Not used on SPEAR3; LLRF9 vector sum handles this |
| GVF/LFB woofer | PEP-II gap voltage feed-forward | LLRF9 handles gap voltage regulation internally |
| TAXI error recovery | PEP-II LFB serial fiber link errors | No TAXI link in upgraded system |
| ON_FM state | PEP-II frequency modulation mode | Not used on SPEAR3 |
| Ripple loop (DSP-based) | AC line ripple rejection via DSP | LLRF9 digital feedback inherently rejects line ripple |
| Allen-Bradley serial communication | Legacy PLC-5 and SLC-500 interface | All PLCs communicate via Ethernet/EPICS |

### 12.3 Hidden Complexity and Risk Areas

1. **Timing dependencies between programs**: The state machine uses `taskDelay()` calls (e.g., `taskDelay(60)` = 1 second at 60 Hz tick rate) to sequence operations. These delays encode empirically-tuned settling times. The upgrade must validate equivalent delays or use explicit readback confirmation instead.

2. **HVPS voltage tolerance counter**: The HVPS loop allows up to 10 consecutive out-of-tolerance readings before reporting a fault. This filter prevents spurious trips on noisy readbacks. The new CompactLogix PLC must implement equivalent filtering.

3. **Tuner dual-position-source logic**: The home reset uses potentiometer position for absolute reference but stepper motor position for motion commands. The Galil DMC-4143 may have different position feedback behavior; this needs validation.

4. **DAC loop 4-way branching**: The DAC loop's mode selection based on (direct_loop state × GVF availability) creates 4 distinct operating paths. The upgrade should simplify this since the LLRF9 eliminates the GVF module, but the concept of degraded-mode operation should be preserved.

5. **Direct loop gain ramping sequence**: The careful sequencing in `rf_statesLP` (gap voltage settle → direct loop on → gain ramp → lead comp → integral comp → comb → beam abort reset) is critical for stable turn-on. The LLRF9's setpoint profile feature may handle this differently, but the sequencing requirements must be preserved.

6. **Auto-reset with contactor check**: The auto-reset logic checks contactor status before attempting restart. If the contactor has opened (loss of 12 kV), auto-reset is skipped. This safety check must be preserved.

7. **Severity-based control flow**: The entire system uses EPICS alarm severity as health indicators. The new system must define equivalent severity mappings for all new PV sources (LLRF9 IOC, CompactLogix, Galil, Waveform Buffer).

### 12.4 Mapping to PDR Subsystems

| Legacy Code | PDR Section | New Subsystem |
|-------------|-------------|---------------|
| `rf_states.st` main | §14 Control Software | EPICS/Python Coordinator |
| `rf_states.st` direct loop control | §5 LLRF Controller | LLRF9 internal + Coordinator |
| `rf_states.st` fault files | §11 Waveform Buffer | LLRF9 waveforms + Waveform Buffer |
| `rf_dac_loop.st` | §15.2 Control Loops | LLRF9 internal + Coordinator |
| `rf_hvps_loop.st` | §6 HVPS | CompactLogix PLC + Coordinator |
| `rf_tuner_loop.st` | §10 Tuner Control | LLRF9 phase → Coordinator → Galil |
| `rf_calib.st` | §5.4 LLRF9 Specs | LLRF9 internal + Dmitry MATLAB tools |
| `rf_msgs.st` message logging | §14 Control Software | Python coordinator logging |
| `rf_msgs.st` filament protection | §13 Klystron Heater | RF MPS PLC |
| `rf_msgs.st` TAXI recovery | — | Eliminated |
| VXI module drivers | §5.1 Legacy System | Eliminated (LLRF9 replaces VXI) |
| AB PLC drivers | §6.2 Legacy Controller | Eliminated (Ethernet replaces serial) |
| DSP firmware | §5.2 LLRF9 | Replaced by LLRF9 FPGA |
| Stepper motor drivers | §10.3 Upgraded Controller | Galil DMC-4143 EPICS motor records |

---

## 13. Appendices

### Appendix A: Complete File Inventory

#### SNL Source Files (llrf/legacyLLRF/)
| File | Lines | Purpose |
|------|-------|---------|
| `rf_states.st` | 2,227 | Master state machine |
| `rf_calib.st` | 3,345 | Calibration system |
| `rf_tuner_loop.st` | 555 | Tuner control (reentrant) |
| `rf_msgs.st` | 352 | Message logging |
| `rf_hvps_loop.st` | 343 | HVPS supervisory control |
| `rf_dac_loop.st` | 290 | DAC control loop |

#### Header Files (llrf/legacyLLRF/)
| File | Lines | Contents |
|------|-------|---------|
| `rf_dac_loop_macs.h` | 197 | DAC_LOOP_SET, DAC_LOOP_CHECK_STATUS, DAC_LOOP_OFF macros |
| `rf_dac_loop_pvs.h` | 158 | DAC loop PV declarations |
| `rf_tuner_loop_pvs.h` | 136 | Tuner loop PV declarations |
| `rf_hvps_loop_macs.h` | 135 | HVPS_LOOP_SET_VOLTAGE, HVPS_LOOP_CHECK_STATUS macros |
| `rf_hvps_loop_pvs.h` | 135 | HVPS loop PV declarations |
| `rf_tuner_loop_macs.h` | 90 | TUNER_LOOP_HOME, TUNER_LOOP_INIT_FLAGS macros |
| `rf_hvps_loop_defs.h` | 81 | HVPS loop status constants (16 statuses) |
| `rf_tuner_loop_defs.h` | 80 | Tuner loop timing and status constants |
| `rf_dac_loop_defs.h` | 71 | DAC loop status constants (15 statuses) |
| `rf_loop_defs.h` | 15 | Shared: station state constants, severity macros |
| `rf_loop_macs.h` | 13 | Shared: macro name constants |

#### Build Files
| File | Lines | Purpose |
|------|-------|---------|
| `Makefile` | 51 | EPICS build system configuration |
| `rfSeq.dbd` | 6 | Database definition file for rfSeq library |

### Appendix B: Status Code Reference

#### HVPS Loop Status Codes (16 states)
| Code | Value | Description |
|------|-------|-------------|
| UNKNOWN | 0 | Unknown status |
| GOOD | 1 | Normal operation |
| RFP_BAD | 2 | RF Processor module offline |
| CAVV_LIM | 3 | Cavity voltage above limit |
| OFF | 4 | Loop manually disabled |
| VACM_BAD | 5 | Cavity vacuum too high |
| POWR_BAD | 6 | Klystron forward power reading invalid |
| GAPV_BAD | 7 | Gap voltage reading invalid |
| GAPV_TOL | 8 | Gap voltage out of tolerance |
| VOLT_LIM | 9 | At HVPS voltage limit |
| STN_OFF | 10 | Station OFF or PARKed |
| VOLT_TOL | 11 | Readback voltage differs from requested |
| VOLT_BAD | 12 | HVPS voltage readback invalid |
| DRIV_BAD | 13 | Klystron drive power reading invalid |
| ON_FM | 14 | Station in ON_FM mode |
| DRIV_TOL | 15 | Klystron drive power out of tolerance |

#### DAC Loop Status Codes (15 states)
| Code | Value | Description |
|------|-------|-------------|
| UNKNOWN | 0 | Unknown status |
| TUNE | 1 | Good — drive power control active |
| ON | 2 | Good — gap voltage control active |
| TUNE_OFF | 3 | Drive power control disabled |
| ON_OFF | 4 | Gap voltage control disabled |
| DRIV_BAD | 5 | Drive power measurement invalid |
| GAPV_BAD | 6 | Gap voltage measurement invalid |
| CTRL | 7 | DAC not at requested value (external modification) |
| STN_OFF | 8 | Station OFF, PARK, or ON_FM |
| RFP_BAD | 9 | RF Processor module offline |
| DAC_LIMT | 10 | DAC value at hardware limit (±2047) |
| GVF_BAD | 11 | Gap module offline |
| DRIV_HIGH | 12 | Drive power too high to increase gap voltage |
| DRIV_TOL | 13 | Drive power out of tolerance |
| GAPV_TOL | 14 | Gap voltage out of tolerance |

### Appendix C: CVS Repository Structure (rf-spear-legacy)

```
rf-spear-legacy/
├── allenBradley/                          # Allen-Bradley PLC drivers
│   └── allenBradleyApp/
│       ├── basicSrc/                      # Core AB driver (drvAb.c)
│       ├── 1771DCMSrc/                    # PLC-5 scanner (13 files)
│       ├── SLCDCMSrc/                     # SLC-500 scanner (HVPS)
│       ├── 1746HSTP1Src/                  # Stepper motor module
│       ├── 1771IFESrc/                    # Analog input
│       ├── 1771IXSrc/                     # Thermocouple input
│       ├── 1771NSeriesSrc/                # N-series analog
│       ├── 1791BlockIOSrc/                # Block I/O
│       ├── gpIfaceSrc/                    # General purpose interface
│       └── oldSrc/                        # Deprecated drivers
├── dsp1610/                               # TMS320C16xx DSP definitions
├── epvxi/src/                             # VXI bus driver layer
├── rfApp/
│   ├── ksc_v152/                          # Kinetics Systems VXI library
│   └── src/
│       ├── base/                          # VXI base utilities, DSP library
│       ├── db/                            # EPICS records and device support
│       │   ├── drvP2RfVxi.c/h            # Core VXI driver
│       │   ├── devP2Rf{Rfp,Gvf,Iqa,Aim,Clk,Cf2,Cfm}.c
│       │   ├── p2Rf{Rfp,Gvf,Iqa,Aim,Clk,Cf2,Cfm}Record.c
│       │   ├── p2Rf{Rfp,Gvf,Iqa,Aim,Clk,Cf2,Cfm}Def.h
│       │   ├── subIQ.c, subSys.c         # Subroutine records
│       │   └── rf_station_state.h         # Station state definitions
│       ├── diag/                          # Diagnostic utilities
│       ├── dsp/                           # DSP firmware
│       │   ├── genDsp/                    # Shared DSP definitions
│       │   ├── rfpDsp/                    # RFP DSP firmware (assembly)
│       │   ├── gvfDsp/                    # GVF DSP firmware (assembly)
│       │   └── obsDsp/                    # Observer DSP firmware
│       ├── rf/rfMain.cpp                  # IOC main entry point
│       └── seq/                           # SNL sequences (same as legacyLLRF)
└── stepper/                               # Stepper motor drivers
    └── stepper/
        ├── steppermotorRecord.c/dbd       # Custom stepper record
        ├── devSmAB1746HSTP1.c             # AB stepper device support
        ├── drvOms.c/h                     # OMS driver
        ├── devSmOms6Axis.c                # OMS 6-axis device support
        └── drvCompuSm.c                   # Compumotor driver
```

---

*End of Report*
