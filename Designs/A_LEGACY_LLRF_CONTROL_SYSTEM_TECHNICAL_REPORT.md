# SPEAR3 Legacy LLRF Control System — Comprehensive Technical Report

**Document ID**: SPEAR3-LLRF-LEGACY-TR-001
**Date**: March 18, 2026
**Author**: Generated from source code analysis of `rf-spear-legacy/`
**Classification**: Technical Reference for LLRF Upgrade Project
**Source Repository**: `rf-spear-legacy/` (CVS/RCS archive, 2,291 versioned files)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [Software Stack and Build Infrastructure](#3-software-stack-and-build-infrastructure)
4. [IOC Startup and Runtime Configuration](#4-ioc-startup-and-runtime-configuration)
5. [State Machine — rf_states.st](#5-state-machine--rf_statesst)
6. [HVPS Control Loop — rf_hvps_loop.st](#6-hvps-control-loop--rf_hvps_loopst)
7. [DAC Control Loop — rf_dac_loop.st](#7-dac-control-loop--rf_dac_loopst)
8. [Tuner Control Loop — rf_tuner_loop.st](#8-tuner-control-loop--rf_tuner_loopst)
9. [Calibration System — rf_calib.st](#9-calibration-system--rf_calibst)
10. [Message Logging and Diagnostics — rf_msgs.st](#10-message-logging-and-diagnostics--rf_msgsst)
11. [Custom EPICS Record Types and Device Support](#11-custom-epics-record-types-and-device-support)
12. [VXI Hardware Driver Layer](#12-vxi-hardware-driver-layer)
13. [Allen-Bradley PLC Interface](#13-allen-bradley-plc-interface)
14. [Stepper Motor Subsystem](#14-stepper-motor-subsystem)
15. [DSP Firmware Layer](#15-dsp-firmware-layer)
16. [EPICS Database and PV Namespace](#16-epics-database-and-pv-namespace)
17. [Feedback Loop Architecture — Integrated View](#17-feedback-loop-architecture--integrated-view)
18. [Interlock and Protection Logic](#18-interlock-and-protection-logic)
19. [Assessment and Modernization Considerations](#19-assessment-and-modernization-considerations)
20. [Appendix: Source File Inventory](#20-appendix-source-file-inventory)

---

## 1. Executive Summary

### 1.1 System Purpose

The legacy LLRF control system manages the SPEAR3 RF station at SSRL, controlling a single klystron that delivers ~800 kW of 476.3 MHz RF power to four storage ring cavities. The software orchestrates station state transitions, regulates high-voltage power supply voltage, controls cavity tuner stepper motors, manages drive power and gap voltage feedback loops, performs hardware calibration sequences, and logs fault/diagnostic messages.

### 1.2 Heritage and Provenance

The software was originally developed for the **PEP-II B-Factory** at SLAC beginning in 1996-1997 and subsequently adapted for SPEAR3. Key authors include:

| Author | Contribution | Era |
|--------|-------------|-----|
| **Robert C. Sass (RCS)** | Master state machine (`rf_states.st`) | 1997 |
| **Stephanie Allison (SAA)** | HVPS loop, DAC loop, tuner loop, messages; extensive modifications to state machine | 1996-2000 |
| **Mike Zelazny** | HVPS loop original design | 1997 |
| **R. Claus** | Calibration system (`rf_calib.st`) | 1997 |
| **P. Corredoura** | Calibration extensions, RF processing architecture | 1997 |
| **M. Laznovsky (LAZMO)** | Calibration rewrite, state machine modifications | 2003-2006 |

The code has been in continuous service for over **25 years** with minimal structural changes after ~2006.

### 1.3 Scale of the Codebase

| Category | Files | Lines of Code |
|----------|-------|---------------|
| **SNL State Programs** (`.st`) | 6 | ~7,112 |
| **SNL Header Files** (`.h` for SNL) | 11 | ~1,111 |
| **Custom EPICS Records** (`.c` record support) | 7 | ~2,228 |
| **Device Support Modules** (`.c`) | 8 | ~18,546 |
| **VXI Driver** (`drvP2RfVxi.c/h`) | 2 | ~2,862 |
| **Allen-Bradley Driver** (`drvAb.c/h`) | 2 | ~2,080 |
| **Stepper Motor Support** | 5 | ~3,591 |
| **DSP Firmware** (assembly + headers) | ~60+ | ~4,000+ |
| **EPICS Database Templates** (`.db`, `.substitutions`) | 76 | ~5,000+ |
| **IOC Boot / Configuration** | 30+ | ~1,500+ |
| **Total Versioned Files** | **2,291** | **~48,000+** |

### 1.4 Key Technical Characteristics

- **Operating System**: VxWorks RTOS (real-time, deterministic scheduling)
- **CPU Architecture**: PowerPC 604 (Motorola/Freescale) in VXI slot-0 CPU module
- **EPICS Version**: EPICS Base 3.14.x (R3.14.8.2 through R3.14.11 based on RCS tags)
- **Control Framework**: EPICS State Notation Language (SNL) / Sequencer
- **Hardware Bus**: VXI (VME eXtensions for Instrumentation) with custom PEP-II RF modules
- **PLC Communication**: Allen-Bradley serial link (1747-DCM scanner)
- **Station Identifier**: `SRF1` (SPEAR RF Station 1)
- **IOC Name**: `B132-IOCRF` (Building 132, IOC for RF)

---

## 2. System Architecture Overview

### 2.1 Hardware Architecture

```
VXI CRATE (Building B132)
+------------------------------------------------------------------+
| Slot 0: VXI CPU (PowerPC 604)                                    |
|   - VxWorks RTOS                                                  |
|   - EPICS IOC with 6 SNL programs                                 |
|   - Custom record types: RFP, IQA, GVF, CF2, CLK, AIM            |
|                                                                    |
| Slot 1: Allen-Bradley Scanner (1747-DCM equivalent, VME)          |
|   - Serial link to SLC-500 PLC (HVPS, B118)                       |
|   - Serial link to PLC-5 (RF MPS)                                 |
|   - Serial link to 1746-HSTP1 stepper modules (x4 cavities)       |
|                                                                    |
| Slot 2: Clock Module (CLK)                                        |
|   - 476.3 MHz reference distribution                               |
|   - Phase-locked timing for all RF processing                      |
|                                                                    |
| Slot 3: RF Processor Module (RFP) — "Heart of the system"         |
|   - DSP1610 processor for fast feedback                            |
|   - Octal DACs for I/Q setpoints                                   |
|   - Direct loop, compensation loops                                |
|   - Waveform capture buffers                                       |
|                                                                    |
| Slot 4: IQA Module #1 (Amplitude/Phase Monitor)                   |
| Slot 5: IQA Module #2                                              |
| Slot 6: IQA Module #3 (HER only — not used in SPEAR3)             |
|                                                                    |
| Slot 7: GVF Module (Gap Voltage Feedforward)                      |
|   - Woofer (LFB) feedback loop                                    |
|   - GFF reference generation                                       |
|   - Ripple loop for power-line noise rejection                     |
|                                                                    |
| Slot 8: CF2 Module (Comb Filter v2)                                |
|   - Revolution-harmonic feedback (comb filter)                     |
|   - Beam-loading compensation                                      |
|                                                                    |
| Slot 9: AIM Module (Arc Interface Module)                          |
|   - Interlock status aggregation                                   |
|   - Beam abort control                                             |
|   - Fault file history buffer                                      |
+------------------------------------------------------------------+
```

### 2.2 Software Architecture

```
+---------------------------+
|     OPERATOR DISPLAYS     |     EDM panels, EPICS archiver
|     (Channel Access)      |
+---------------------------+
            |
+---------------------------+
|    SNL STATE PROGRAMS     |     6 concurrent state machines
|  rf_states (master)       |     on VxWorks threads
|  rf_hvps_loop             |
|  rf_dac_loop              |
|  rf_tuner_loop (x4)       |     One instance per cavity
|  rf_calib                 |
|  rf_msgs                  |
+---------------------------+
            |
+---------------------------+
|   EPICS DATABASE LAYER    |     ~76 .db/.template files
|   Custom Record Types:    |     Standard + custom records
|   RFP, IQA, GVF, CF2,    |     Subroutine records (subIQ, subSys)
|   CLK, AIM                |     CALC, SEQ, FANOUT records
+---------------------------+
            |
+---------------------------+
|   DEVICE SUPPORT LAYER    |     devP2Rf*.c files
|   devP2RfRfp (2,389 L)   |     Translates EPICS record fields
|   devP2RfIqa (2,260 L)   |     to VXI register operations
|   devP2RfGvf (2,350 L)   |
|   devP2RfCf2 (2,970 L)   |
|   devP2RfClk (957 L)     |
|   devP2RfAim (1,982 L)   |
+---------------------------+
            |
+---------------------------+
|    VXI DRIVER LAYER       |     drvP2RfVxi.c (2,671 lines)
|    drvP2RfVxi             |     VXI bus access, module init,
|                           |     ISR handling, DMA transfers
+---------------------------+         +---------------------------+
            |                          |   ALLEN-BRADLEY DRIVER    |
     [VXI Backplane]                   |   drvAb.c (2,039 lines)  |
            |                          |   Serial link to PLCs     |
     +------+------+                   +---------------------------+
     |      |      |                              |
   [RFP]  [IQA] [GVF]                    [SLC-500]  [PLC-5]  [1746-HSTP1]
   [CF2]  [CLK] [AIM]                     (HVPS)   (RF MPS)   (Steppers)
```

### 2.3 Program Execution Model

All 6 SNL programs plus 4 tuner loop instances (one per cavity) run as **separate VxWorks tasks** (threads) within a single IOC process. They communicate exclusively through **EPICS Process Variables (PVs)** — there is no direct shared memory or message passing between SNL programs.

The programs execute concurrently with the following approximate update rates:

| Program | Instances | Typical Update Rate | Priority |
|---------|-----------|-------------------|----------|
| `rf_states` (ss rf_states) | 1 | Event-driven (monitor callbacks) | High |
| `rf_states` (ss rf_statesLP) | 1 | Event-driven + delay-based ramps | High |
| `rf_states` (ss rf_statesFF) | 1 | Event-driven (fault trigger) | High |
| `rf_hvps_loop` | 1 | ~0.5 Hz (configurable) up to 10 Hz | Medium |
| `rf_dac_loop` | 1 | Event-driven + max 10s timeout | Medium |
| `rf_tuner_loop` | 4 | Event-driven (phase measurement ready) | Medium |
| `rf_calib` | 1 | On-demand only | Low |
| `rf_msgs` | 2 state sets | Event-driven (PV monitors) | Low |

---

## 3. Software Stack and Build Infrastructure

### 3.1 Build System

The project uses the standard EPICS build system with a top-level `Makefile` and `configure/` directory:

- **Top-level Makefile**: Builds `rfApp`, `allenBradley`, `epvxi`, `stepper` applications
- **configure/RELEASE**: Defines paths to EPICS base, sequencer, Allen-Bradley support
- **rfApp/Makefile**: Builds the `rf` IOC application combining all subsystems
- **rfApp/src/seq/Makefile**: Compiles all 6 SNL programs into the `rfSeq` library
- **rfApp/src/db/Makefile**: Builds custom record types and device support into `rfDb` library
- **rfApp/src/dsp/Makefile**: DSP firmware compilation (separate toolchain)

### 3.2 Version Control

The codebase uses **CVS** (Concurrent Versions System) with RCS backend files (`,v` suffix). Version tags visible in the RCS headers include:

| Tag | EPICS Version | Date |
|-----|--------------|------|
| `RF-SPEAR-R0-3-2` | R3.14.11 | Dec 2011 |
| `R_epics_3_14_11_rtems_4_9_4_aug_13_2012` | R3.14.11 | Aug 2012 |
| `R_epics_3_14_8_2_rtems_4_9_1_aug_10_2009` | R3.14.8.2 | Aug 2009 |
| `R3_13_6` | R3.13.6 | Original |

### 3.3 Runtime Dependencies

- **VxWorks**: RTOS with `taskDelay()`, `taskLib.h`, `sysLib.h`
- **EPICS Base**: 3.14.x (record support, Channel Access, database)
- **EPICS Sequencer**: SNL compiler and runtime
- **National Instruments VXI**: `nivxi` library for VXI resource management
- **Allen-Bradley support**: Custom `allenBradley` module in this repository


---

## 4. IOC Startup and Runtime Configuration

### 4.1 Startup Command File (`st.cmd`)

The IOC starts from `iocBoot/b132-iocrf/st.cmd` which performs:

1. **Load binary**: `ld < bin/vxWorks-ppc604_long/rf.munch`
2. **Configure errlog**: `errlogInit(5000)` — increased from default 1260 bytes
3. **Set macros**: Station `SRF1`, cavity tuner macros for 4 cavities (`C1`-`C4`)
4. **Load database**: `dbLoadRecords("db/srf1.db")` — the complete station database
5. **Restore settings**: `dbRestore("spear1",0,-1)` and `dbRestore("/sav/savedataSRF1.sav",0,-1)`
6. **Configure Allen-Bradley**: `abConfigVme(0, 0xc00000, 0x60, 4)` — VME address and interrupt
7. **Configure VXI**: 13-device window from LA 1, A24/A32 address space allocation
8. **Start EPICS**: `iocInit()`
9. **Start SNL sequences** in order:
   - `rf_states` (master state machine)
   - `rf_tuner_loop` × 4 instances (one per cavity: C1, C2, C3, C4)
   - `rf_hvps_loop`
   - `rf_dac_loop`
   - `P2RF_Calib` (on-demand calibration)
   - `rf_msgs` (message logging)
10. **Override database values**: Station ID and summary calculation formula

### 4.2 Macro Substitution

The macro system enables the same PEP-II code to be used for different stations:

| Macro | SPEAR3 Value | Purpose |
|-------|-------------|---------|
| `STN` | `SRF1` | Station name prefix for all PVs |
| `CAV` | `1`, `2`, `3`, `4` | Cavity number for tuner loops |
| `name` | `tRFSTATES`, `HVPSLOOP`, etc. | VxWorks task name |

### 4.3 IQA3 Dynamic Assignment

The code includes a PEP-II heritage feature: if the `IQA3MACROS` environment variable is set, a third IQA module is dynamically assigned. For SPEAR3, this variable is set to `R=SRF1`, enabling the third IQA fault-file capture. This is handled in `rf_states.st` initialization through dynamic `pvAssign()` calls.

---

## 5. State Machine — rf_states.st

### 5.1 Overview

| Attribute | Value |
|-----------|-------|
| **File** | `rfApp/src/seq/rf_states.st` |
| **Lines** | 2,227 |
| **Author** | Robert C. Sass (1997), heavily modified by S. Allison and M. Laznovsky |
| **State Sets** | 3: `rf_states` (main), `rf_statesLP` (loop control), `rf_statesFF` (fault files) |
| **PV Bindings** | ~80+ Channel Access variables |

### 5.2 Station States

The system defines 5 mutually exclusive station states:

| State | Value | Description |
|-------|-------|-------------|
| `STATION_OFF` | 0 | All RF systems disabled. Safe state. |
| `STATION_PARK` | 1 | Tuners parked at safe retracted position. No RF. |
| `STATION_TUNE` | 2 | HVPS on, RF on, tuners at home position. Tune mode DACs active. |
| `STATION_ON_FM` | 3 | Frequency modulation mode — loads I/Q files for 400 Hz or 1 kHz modulation |
| `STATION_ON_CW` | 4 | Full operational continuous wave mode — all feedback loops active |

### 5.3 State Transition Matrix

```
From \ To    OFF    PARK   TUNE   ON_FM  ON_CW
  OFF         —      Y      Y      Y      Y
  PARK        Y      —      —      —      —
  TUNE        Y      —      —      —      Y
  ON_FM       Y      —      Y      —      —
  ON_CW       Y      —      Y      —      —
```

All states can transition to OFF. Most upward transitions require NO_ALARM on fault summaries. Fault detection in any "on" state triggers automatic transition to OFF.

### 5.4 State Set 1: `ss rf_states` — Main State Machine

**`s_init`**: Initializes all variables, clears event flags, sets `ldir=1`, `ldqr=1`, assigns IQA3 channels if HER.

**`s_off`**: Monitors for:
- `fault_detected` → attempts auto-reset (`s_go_stn_reset`)
- Valid `ctrl` + `fault_noon == NO_ALARM` + `panel_onoff == NO_ALARM` → transition to requested state
- Blocks transitions if faults present, displays appropriate message

**`s_go_off`**: The OFF-transition action state:
1. Reads HVPS voltage (for fault timestamp)
2. Sets `rbck = STATION_OFF`
3. Passes through TUNE state briefly (allows HVPS fault logging)
4. Ramps HVPS voltage to zero, waits 5 seconds
5. Turns off HVPS triggers and RF switch
6. Turns off integral compensation
7. Zeros all I/Q reference values
8. Resyncs clock module
9. If fault file capture enabled, triggers `ffwrite_ef` event and waits for completion

**`s_go_stn_reset`**: Automatic fault recovery:
- Checks `reset_count > 0`, no forced fault, contactor closed, panel on
- Handles vacuum errors with a 10-second pump-down wait
- Attempts up to `reset_count` iterations (each with 5-second delay)
- If successful, restores previous state; if failed, goes to OFF

**`s_go_park`**: Parks tuners, resets beam abort, sets `rbck = STATION_PARK`

**`s_go_tune`**: TUNE transition:
1. Forces beam abort
2. Sets I/Q tune reference values
3. Sets run mode to TUNE
4. Executes HVPS-on sequence (HVPSONSUB): RF switch on → set default voltage → home tuners → wait → enable SCR triggers → enable AIM HVPS

**`s_go_on_cw`**: The most complex transition state — handles two modes:

**Fast Turn-On** (if direct loop control is ON and fast turn-on is enabled):
1. Home cavities, reset comb filters
2. Preload gap I/Q reference values
3. Turn on direct loop immediately (leave gain as-is)
4. Turn on integral and lead compensation if enabled
5. Turn on comb loop if enabled
6. Set run mode to OPERATE, turn on RF, set HVPS to fast-on voltage
7. Enable SCR triggers, AIM HVPS
8. Enable GFF and LFB loops if configured
9. Reset beam abort

**Normal Turn-On** (direct loop off or fast turn-on disabled):
1. Initialize reference amplitude
2. Execute OPERATE sequence (OPERATESUB): set OPERATE run mode, HVPS-on sequence
3. Set `directlp_ef` event to let the LP state set handle loop enabling

### 5.5 State Set 2: `ss rf_statesLP` — Loop Control Sequence

This state set manages the careful sequencing of feedback loop transitions, operating concurrently with the main state machine. States:

**`s_lp_check`**: Central dispatcher, waits for event flags from loop control PV changes:
- Direct loop on/off requests
- Lead compensation on/off
- Integral compensation on/off
- Comb loop on/off
- GFF loop on/off
- LFB woofer on/off
- Beam abort reset requests

**`s_gv_down`**: Lowers gap voltage before enabling direct loop. Executes the transition sequence that lowers gap voltage and drive power, forces beam abort, waits for `volt_settle_time`.

**`s_direct_ramp`**: Gradually ramps direct loop gain from a negative offset to zero:
- Increments `directlpgainoff` by `directlpgaindelta` each step
- Waits `ramp_settle_time` between steps
- Enables lead and integral compensation at appropriate points
- When complete, triggers comb loop, GFF, and LFB event flags

**`s_comb_ramp`**: Similar gain ramping for the comb loop filter.

**`s_gv_up`**: After loop ramping complete, waits for gap voltage to settle within tolerance, then restores drive power and resets beam abort.

**Critical Safety Feature**: The loop control sequence prevents operators from disabling the direct loop while in ON_CW with the beam abort already reset. The operator must first take the station out of ON_CW.

### 5.6 State Set 3: `ss rf_statesFF` — Fault File Capture

Triggered by `ffwrite_ef` event flag when a fault occurs in an "on" state:

1. Increments `faultnum` (wraps at 15)
2. Captures timestamp from HVPS voltage PV
3. Puts RFP, CF2, and GVF modules into LOAD state (stops acquisition)
4. For each of 11 data sources (4 RFP buffers, 2 CF2 buffers, 2 IQA buffers, 1 GVF buffer, 1 AIM buffer, 1 optional IQA3):
   - Saves current filename and size
   - Writes fault filename (e.g., `/dat/FAULTRfpSI_1`)
   - Sets fault-specific buffer size
   - Triggers data capture (`fget` poke)
5. Waits for all captures to complete (max ~3 minute timeout)
6. Restores original filenames and sizes
7. Resumes CF2 and GVF acquisition

**Fault File Naming Convention**: `/dat/FAULT<module><buffer>_<number>` where number is 1-15 in a circular buffer.

---

## 6. HVPS Control Loop — rf_hvps_loop.st

### 6.1 Overview

| Attribute | Value |
|-----------|-------|
| **File** | `rfApp/src/seq/rf_hvps_loop.st` |
| **Lines** | 343 |
| **Author** | Mike Zelazny (1997), modified by S. Allison and R. Sass |
| **Purpose** | Regulate HVPS voltage based on station state and RF parameters |
| **Update Rate** | Configurable, max every 10 seconds (`HVPS_LOOP_MAX_INTERVAL`) |

### 6.2 Operating Modes

The HVPS loop has three control modes (`hvps_loop_ctrl`):

| Mode | Value | Description |
|------|-------|-------------|
| `HVPS_LOOP_CONTROL_OFF` | 0 | No voltage adjustment — operator manual control |
| `HVPS_LOOP_CONTROL_PROC` | 1 | Processing mode — raise/lower voltage during cavity conditioning |
| `HVPS_LOOP_CONTROL_ON` | 2 | Regulation mode — maintain constant drive power or gap voltage |

### 6.3 Process Mode (Cavity Conditioning)

In process mode, the loop raises or lowers HVPS voltage based on:

- **Decrease voltage if**: klystron forward power exceeds max, gap voltage too high (MAJOR severity), cavity vacuum too high (MAJOR severity)
- **Increase voltage if**: All conditions nominal
- **Delta**: `delta_proc_voltage_down` / `delta_proc_voltage_up` (configurable via PVs)
- **Safety checks**: RFP module must be valid, klystron power readable, gap voltage readable, cavity vacuums readable, HVPS voltage readable

### 6.4 Regulation Mode

In ON mode, the voltage adjustment depends on the station state:

- **ON_CW with direct loop ON**: Uses `delta_on_voltage` computed from drive power error (negative feedback — if drive power is too high, reduce HVPS voltage to reduce klystron gain)
- **TUNE or direct loop OFF**: Uses `delta_tune_voltage` computed from gap voltage error
- **Cavity voltage limit**: If cavity voltages exceed maximum while trying to increase, holds voltage constant (`HVPS_LOOP_STATUS_CAVV_LIM`)

### 6.5 Voltage Setting Macro

The `HVPS_LOOP_SET_VOLTAGE()` macro (defined in `rf_hvps_loop_macs.h`):
1. Applies delta to `requested_hvps_voltage`
2. Clamps between `min_hvps_voltage` and `max_hvps_voltage`
3. Checks if change exceeds `allowed_hvps_voltage_diff` (safety check)
4. Writes to `{STN}:HVPS:VOLT:CTRL` PV
5. Updates voltage history

### 6.6 Status Reporting

16 defined status codes including:
- `GOOD`, `OFF`, `STN_OFF` — normal conditions
- `RFP_BAD`, `VOLT_BAD`, `POWR_BAD`, `GAPV_BAD`, `VACM_BAD` — hardware/sensor faults
- `GAPV_TOL`, `DRIV_TOL`, `VOLT_TOL` — out-of-tolerance conditions
- `CAVV_LIM`, `VOLT_LIM` — at limits
- `ON_FM`, `DRIV_BAD` — mode-specific conditions

### 6.7 Key PVs

| PV | Type | Description |
|----|------|-------------|
| `{STN}:HVPS:VOLT:CTRL` | float | Requested HVPS voltage setpoint |
| `{STN}:HVPS:VOLT` | float | HVPS voltage readback |
| `{STN}:HVPS:LOOP:CTRL` | int | Loop control mode (OFF/PROC/ON) |
| `{STN}:HVPS:LOOP:STATE` | int | Current loop state |
| `{STN}:HVPS:LOOP:STATUS` | int | Current loop status code |
| `{STN}:KLYSOUTFRWD:POWER` | float | Klystron forward power |
| `{STN}:KLYSOUTFRWD:POWER:MAX` | float | Maximum allowed klystron forward power |
| `{STN}:HVPS:LOOP:VOLTDOWN` | float | Voltage step size (down) for processing |
| `{STN}:HVPS:LOOP:VOLTUP` | float | Voltage step size (up) for processing |

---

## 7. DAC Control Loop — rf_dac_loop.st

### 7.1 Overview

| Attribute | Value |
|-----------|-------|
| **File** | `rfApp/src/seq/rf_dac_loop.st` |
| **Lines** | 290 |
| **Author** | Stephanie Allison (1997) |
| **Purpose** | Adjust RFP/GFF DAC amplitude setpoints for drive power or gap voltage control |
| **Update Rate** | Event-driven, max every 10 seconds |

### 7.2 Operating Modes

The DAC loop adjusts different parameters depending on station state and which feedback loops are active:

| Station State | Direct Loop | Adjusts | Target | Hardware |
|---------------|------------|---------|--------|----------|
| TUNE | N/A | Drive power amplitude | RFP tune mode DACs | RFP module |
| ON_CW | OFF, GVF unavailable | Drive power amplitude | RFP difference node DACs | RFP module |
| ON_CW | OFF, GVF available | Drive power amplitude | GFF reference values | GVF module |
| ON_CW | ON, GVF unavailable | Gap voltage amplitude | RFP difference node DACs | RFP module |
| ON_CW | ON, GVF available | Gap voltage amplitude | GFF reference values | GVF module |

### 7.3 Control Algorithm

The `DAC_LOOP_SET()` macro implements:
1. Read error from either `dp_error_stat` (drive power) or `gv_error_stat` (gap voltage)
2. If error severity is MAJOR or worse: update counts by delta value
3. Clamp counts within limits
4. Write new count value to appropriate hardware PV
5. Track phase changes and force DAC setpoint updates when phase changes

### 7.4 Ripple Loop Integration

The DAC loop also manages the ripple loop amplitude setpoint. The ripple loop operates at a slower rate than the main DAC loop, so the DAC loop checks a separate `ripple_loop_ready_ef` event flag before loading new ripple loop amplitude values.

---

## 8. Tuner Control Loop — rf_tuner_loop.st

### 8.1 Overview

| Attribute | Value |
|-----------|-------|
| **File** | `rfApp/src/seq/rf_tuner_loop.st` |
| **Lines** | 555 |
| **Author** | Stephanie Allison (1996-1999) |
| **Instances** | 4 (one per cavity, reentrant: `option +r`) |
| **Purpose** | Move cavity tuners based on phase measurements to maintain resonance |

### 8.2 States

| State | Description |
|-------|-------------|
| `loop_init` | Initialize variables, clear event flags |
| `loop_unknown` | Determine correct initial state after boot/reset |
| `loop_reset` | Move tuner to home position (ON home or PARK home) |
| `loop_off` | Wait for station to leave OFF state |
| `loop_on` | Active tuning — all station states except OFF |

### 8.3 Tuner Control Algorithm

When in `loop_on` state:

1. Wait for `meas_ready_ef` (phase measurement available from IQA module)
2. Wait for `loop_ready_ef` (loop timing trigger)
3. If stepper motor is done moving and enough measurements accumulated:
   a. Get current stepper motor position (`sm_posn`)
   b. Get phase delta (`posn_delta`) from database calculation
   c. Compute new position: `posn_new = sm_posn + posn_delta`
   d. Check drive limits (`sm_drvh`, `sm_drvl`)
   e. Check for external control interference (`SM_CTRL_STATUS`)
   f. Write new position to stepper motor (`posn_ctrl`)
   g. Process phase offset for load angle calculation

### 8.4 Home/Reset Mechanism

The reset state implements a multi-attempt homing algorithm:
1. Read desired home position from PV (`posn_on_home` or `posn_park_home`)
2. Read current position from linear potentiometer (`posn`)
3. Calculate delta between desired and actual position
4. If within tolerance (`posn_mdel * LOOP_RESET_TOLS`): done
5. Otherwise: compute new stepper motor position = current SM position + delta
6. Command move and wait for completion
7. Repeat up to `LOOP_RESET_COUNT` times

### 8.5 Status Codes

18 defined status codes including:
- `LOOP_GOOD_STATUS` — functioning normally
- `LOOP_SM_MOVE_STATUS` — stepper motor stuck/moving too long
- `LOOP_SM_BAD_STATUS` — stepper motor communication error
- `LOOP_PHAS_BAD_STATUS` — phase measurement invalid
- `LOOP_PHASMISS_STATUS` — no phase measurements received
- `LOOP_POWR_LOW_STATUS` — klystron forward power too low for tuning
- `LOOP_DRV_LIMT_STATUS` — stepper motor at drive limit
- `LOOP_LDANGLIM_STATUS` — load angle out of acceptable range
- `LOOP_SM_CTRL_STATUS` — external control changed motor position

### 8.6 Load Angle Offset

When the loop is ON and station is not in PARK mode, the code evaluates `load_angle_sevr` to check if the load angle is within acceptable bounds. If the load angle is out of limits, the loop reports `LOOP_LDANGLIM_STATUS`. This feeds into the higher-level load angle balancing between all 4 cavities.

---

## 9. Calibration System — rf_calib.st

### 9.1 Overview

| Attribute | Value |
|-----------|-------|
| **File** | `rfApp/src/seq/rf_calib.st` |
| **Lines** | 3,345 |
| **Author** | R. Claus (1997), P. Corredoura (1997), M. Laznovsky (2004 major rewrite) |
| **Purpose** | Automated calibration of RFP module octal DACs and RF processing chain |
| **Activation** | On-demand only (operator initiates via `{STN}:STN:RFP:DOODCALIB` PV) |

### 9.2 Calibration Procedures

The calibration system nulls various hardware offsets in the RFP module through iterative measurement and adjustment. Key calibration stages include:

1. **Modulator Offset Nulling**: Zeros the I/Q modulator offsets for the direct loop, comb loop, and compensation stages
2. **Multiplier Weight Calibration**: Calibrates the octal DAC weights for cavity-specific processing
3. **Difference Node Offset Nulling**: Zeros the difference node offsets in the RFP feedback path
4. **Klystron Demodulator Calibration**: Calibrates the klystron signal demodulation chain
5. **Tune Setpoint Calibration**: Adjusts tune mode reference values

### 9.3 Key Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `COUNT` | 30,000 | Number of words averaged per measurement |
| `MAX_ATTEMPTS` | 50 | Maximum iterations for nulling |
| `MARGIN` | 1 | Acceptable DAC count error |
| `BIG_MARGIN` | 2 | Acceptable error for tune setpoint |
| `BIG_MARGIN2` | 4 | Acceptable error for klystron/compensation stages |
| `MAX_DAC` | 2047 | Maximum 12-bit DAC value |
| `MIN_DAC` | -2048 | Minimum 12-bit DAC value |

### 9.4 Calibration Method

The nulling algorithm uses a binary search approach:
1. Save current hardware state
2. Set feedback signal path to the target stage
3. Average many samples to get a stable measurement
4. Adjust DAC value toward zero offset
5. Repeat until error < margin or max attempts reached
6. Restore hardware state

The 2004 rewrite by M. Laznovsky reduced runtime from ~20 minutes to ~3 minutes by replacing repeated code with macros and reducing unnecessary delays.

---

## 10. Message Logging and Diagnostics — rf_msgs.st

### 10.1 Overview

| Attribute | Value |
|-----------|-------|
| **File** | `rfApp/src/seq/rf_msgs.st` |
| **Lines** | 352 |
| **Author** | Stephanie Allison (1997-2000), R. Sass (1999) |
| **State Sets** | 2: `rf_msgs` (message logging), `rf_msgsTAXI` (taxi error monitoring) |

### 10.2 Message Logging (State Set 1)

Monitors specific PVs for changes and logs messages via `epicsPrintf()`:
- **Trip Reset**: When HVPS trip is reset
- **Filament Bypass**: Timer bypass activated
- **Filament On/Off**: Filament state changes
- **Station Online/Offline**: Station availability
- **Filament Fault**: Opens HVPS contactor when filament faults, logs forced-off events
- **HVPS Subsystem Faults**: Logs specific HVPS fault conditions (12kV, SCR1, SCR2, Enerpro fast/slow inhibit, supply on) — only logged when the fault occurs without other concurrent faults

### 10.3 TAXI Error Monitor (State Set 2)

The `rf_msgsTAXI` state set monitors the GVF module's TAXI (LFB communication link) status bit. When a TAXI overflow error is detected and the LFB woofer loop is running:
1. Wait a random 0.5-4 second delay (to prevent multiple IOCs from simultaneously resyncing)
2. Force a taxi status check
3. If error persists, send a resync command to the LFB system
4. Log the error

This is described in the code as a "kludge" — a workaround for an intermittent communication error between the GVF module and the longitudinal feedback (LFB) system.


---

## 11. Custom EPICS Record Types and Device Support

### 11.1 Overview

The system implements 7 custom EPICS record types, each with dedicated device support modules that interface with the VXI hardware. These are not standard EPICS record types — they are fully custom implementations specific to the PEP-II RF processing hardware.

### 11.2 Record Type Summary

| Record Type | Definition File | Record Code | Device Support | Lines (Dev) | Purpose |
|-------------|----------------|-------------|----------------|-------------|---------|
| **p2RfRfp** | `p2RfRfpRecord.dbd` | `p2RfRfpRecord.c` (296) | `devP2RfRfp.c` (2,389) | 2,685 | RF Processor module — heart of the fast feedback |
| **p2RfIqa** | `p2RfIqaRecord.dbd` | `p2RfIqaRecord.c` (301) | `devP2RfIqa.c` (2,260) | 2,561 | I/Q Amplitude monitor — 4-channel RF detector |
| **p2RfGvf** | `p2RfGvfRecord.dbd` | `p2RfGvfRecord.c` (307) | `devP2RfGvf.c` (2,350) | 2,657 | Gap Voltage Feedforward — LFB woofer, GFF ref |
| **p2RfCf2** | `p2RfCf2Record.dbd` | `p2RfCf2Record.c` (366) | `devP2RfCf2.c` (2,970) | 3,336 | Comb Filter v2 — revolution harmonic feedback |
| **p2RfClk** | `p2RfClkRecord.dbd` | `p2RfClkRecord.c` (299) | `devP2RfClk.c` (957) | 1,256 | Clock module — timing distribution |
| **p2RfAim** | `p2RfAimRecord.dbd` | `p2RfAimRecord.c` (300) | `devP2RfAim.c` (1,982) | 2,282 | Arc Interface Module — interlocks, beam abort |

### 11.3 RF Processor Module (RFP)

The RFP record (`p2RfRfpDef.h`, 565 lines of definitions) is the most critical hardware interface. Key capabilities:

- **Octal DAC control**: 8 DAC channels for I/Q setpoints in tune mode, operate mode, and compensation stages
- **Direct loop control**: Enable/disable, gain adjustment
- **Comb loop control**: Enable/disable
- **Ripple loop control**: Enable/disable, amplitude setting
- **Lead/Integral compensation**: Enable/disable
- **Waveform capture**: 4 buffers (SI, SQ, CI, CQ) for fault file capture
- **RF switch control**: RF enable/disable
- **Run mode selection**: TUNE vs. OPERATE
- **DAC state management**: RESET, LOAD, RUN
- **I/Q file loading**: Load drive I/Q waveforms from files

### 11.4 IQA Module

The IQA record provides per-cavity amplitude and phase monitoring:

- **4 RF input channels** with amplitude and phase readback
- **Calibration coefficients** for each channel
- **Alarm thresholds** for amplitude and phase
- **History buffer** for fault file capture
- **Beam abort** control (Force Beam Abort, Reset Beam Abort, Reset Faults)

### 11.5 GVF Module (Gap Voltage Feedforward)

- **GFF reference values**: I/Q reference for gap voltage feedforward
- **LFB woofer loop**: Enable/disable, gain control
- **Ripple compensation**: Filter coefficients for power-line frequency rejection
- **TAXI status**: Communication link status with LFB system
- **Waveform buffer**: For fault file capture
- **State management**: LOAD/RUN modes

### 11.6 CF2 Module (Comb Filter v2)

- **Comb filter coefficients**: I/Q filter weights for revolution-harmonic rejection
- **History buffers**: I and Q channel history for diagnostics
- **Diagnostic recording**: Enable/disable
- **State management**: LOAD/RUN modes

### 11.7 Subroutine Records

Two custom subroutine records provide calculated values:

- **subIQ.c** (965 lines): I/Q conversion calculations — converts between I/Q pairs and amplitude/phase, performs coordinate rotations, and computes error signals
- **subSys.c** (464 lines): System-level calculations — summary alarm status, station state monitoring, gap voltage computation

---

## 12. VXI Hardware Driver Layer

### 12.1 Overview

| Attribute | Value |
|-----------|-------|
| **File** | `rfApp/src/db/drvP2RfVxi.c` (2,671 lines), `drvP2RfVxi.h` (191 lines) |
| **Purpose** | Low-level VXI bus interface for all PEP-II RF modules |

### 12.2 Capabilities

The VXI driver provides:
- **Module discovery**: Scans VXI backplane, identifies PEP-II RF modules by manufacturer ID and model code
- **Register access**: Read/write to module-specific A16/A24/A32 VXI address spaces
- **DMA transfers**: High-speed data transfers for waveform capture
- **Interrupt handling**: VXI interrupt service routines for module events
- **Module initialization**: Configuration of each module type during IOC startup
- **Diagnostic functions**: Register dumps, status reports

### 12.3 Module Types Handled

The driver recognizes and initializes these VXI module types:
- RFP (RF Processor)
- IQA (I/Q Amplitude Monitor)
- GVF (Gap Voltage Feedforward)
- CF2/CFM (Comb Filter)
- CLK (Clock)
- AIM (Arc Interface Module)

---

## 13. Allen-Bradley PLC Interface

### 13.1 Overview

| Attribute | Value |
|-----------|-------|
| **Driver** | `allenBradley/allenBradleyApp/basicSrc/drvAb.c` (2,039 lines) |
| **Scanner** | Allen-Bradley 1747-DCM (VME module in VXI crate) |
| **Protocol** | Allen-Bradley serial (DF1 / DH-485) |

### 13.2 Connected PLCs

| PLC | Location | Function | Communication |
|-----|----------|----------|---------------|
| SLC-500 (1747-L532) | B118 Hoffman Box | HVPS controller | AB serial via DCM |
| PLC-5 (1771 series) | B132 | RF MPS | AB serial via DCM |
| 1746-HSTP1 (×4) | Tunnel | Cavity tuner steppers | AB serial via DCM |

### 13.3 Data Exchange

The Allen-Bradley driver provides EPICS record support for:
- **DCM records** (`abDcmRecord`): Bidirectional data table transfers with SLC-500/PLC-5
- **Binary I/O records**: Digital inputs and outputs via 1746-series modules
- **Analog I/O records**: 4-20mA and voltage signals via 1746-NI4/NIO4V modules

The HVPS PLC ladder logic communicates through AB data tables, exchanging:
- Voltage setpoint (IOC → PLC)
- Voltage readback, current readback (PLC → IOC)
- Contactor control commands (IOC → PLC)
- Status/fault bits (PLC → IOC)
- Temperature readings (PLC → IOC)

### 13.4 Device Support Modules

| Module | File | Lines | Purpose |
|--------|------|-------|---------|
| `devAiAbDcm` | `devAiAbDcm.c` | ~300 | Analog input from DCM data table |
| `devAoAbDcm` | `devAoAbDcm.c` | ~250 | Analog output to DCM data table |
| `devBiAbDcm` | `devBiAbDcm.c` | ~200 | Binary input from DCM data table |
| `devBoAbDcm` | `devBoAbDcm.c` | ~200 | Binary output to DCM data table |
| `devLiAbDcm` | `devLiAbDcm.c` | ~200 | Long integer input from DCM |
| `devLoAbDcm` | `devLoAbDcm.c` | ~200 | Long integer output to DCM |
| `devMbbiAbDcm` | `devMbbiAbDcm.c` | ~250 | Multi-bit binary input from DCM |
| `devMbboAbDcm` | `devMbboAbDcm.c` | ~250 | Multi-bit binary output to DCM |

---

## 14. Stepper Motor Subsystem

### 14.1 Overview

| Attribute | Value |
|-----------|-------|
| **Device Support** | `devSmAB1746HSTP1.c` (1,673 lines) |
| **Record Support** | `steppermotorRecord.c` (959 lines) |
| **Hardware** | Allen-Bradley 1746-HSTP1 high-speed stepper module |
| **Motors** | Superior Electric Slo-Syn M093-FC11 (NEMA 34D) |
| **Drivers** | Superior Electric SS2000MD4-M Slo-Syn PWM driver |

### 14.2 Stepper Motor Record

The `steppermotorRecord` is a custom EPICS record type (not the standard EPICS motor record) that provides:
- Position setpoint (`VAL`)
- Position readback (`RBV`)
- Done moving flag (`DMOV`)
- Drive high/low limits (`DRVH`, `DRVL`)
- Retry dead band (`RDBD`)
- Velocity and acceleration settings

### 14.3 Device Support for 1746-HSTP1

The `devSmAB1746HSTP1.c` device support interfaces with the Allen-Bradley stepper module through the AB serial link:
- Translates EPICS motor position commands to AB stepper module commands
- Reads position feedback from the stepper module encoder interface
- Handles homing sequences
- Implements motion monitoring (stall detection, limit switches)

---

## 15. DSP Firmware Layer

### 15.1 Overview

The `rfApp/src/dsp/` directory contains firmware for the **DSP1610** digital signal processor embedded in the RFP and GVF VXI modules. The DSP1610 is a 16-bit fixed-point processor from SGS-Thomson (now STMicroelectronics).

### 15.2 DSP Programs

| Directory | Program | Purpose |
|-----------|---------|---------|
| `rfpDsp/` | RFP feedback | Fast I/Q feedback processing, direct loop, DAC output generation |
| `gvfDsp/` | GVF feedback | Gap voltage feedforward computation, LFB woofer |
| `obsDsp/` | Observer | Signal observation, filtering, data acquisition |
| `genDsp/` | Common | Shared math functions (sin, cos, atan, sqrt), definitions |

### 15.3 Key DSP Functions

- **comBlk.s**: Communication block — shared memory interface between VxWorks CPU and DSP
- **vecTbl.s**: Interrupt vector table
- **regInit.s**: Register initialization
- **dspSos.s**: Second-order section (biquad) digital filter implementation
- **ripple.s**: Power-line ripple compensation filter
- **sp3ripple.s**: SPEAR3-specific ripple filter variant
- **wave_out.s**: Waveform output generation
- **Equaliz.s**: Equalization filter
- **adapt.s**: Adaptive filter algorithm
- **apTOiq.s / iqTOap.s**: Amplitude/Phase ↔ I/Q coordinate conversion

### 15.4 Development Tools

The `dsp1610/` directory contains the complete DSP development toolchain:
- `as1600` — Assembler
- `ld1600` — Linker
- `ar1600` — Archiver
- `cpp16` — C preprocessor for DSP
- `cmd1610` — Debug/command interface
- Memory initialization files (`m1_*.if`, `m2_*.if`, etc.)

---

## 16. EPICS Database and PV Namespace

### 16.1 PV Naming Convention

All PVs follow the PEP-II convention: `{STN}:SUBSYSTEM:PARAMETER:FIELD`

For SPEAR3: `SRF1:...`

### 16.2 Key PV Categories

| Prefix | Subsystem | Examples |
|--------|-----------|---------|
| `SRF1:STN:STATE:` | Station state | `:CTRL` (command), `:RBCK` (readback), `:STRING` (display) |
| `SRF1:STN:RFP:` | RF Processor | `:RFENABLE`, `:DIRECTLOOP`, `:COMBLOOP`, `:DACS`, `:STATE` |
| `SRF1:STN:GVF:` | GVF module | `:GFFLOOP`, `:LFBLOOP`, `:STATE` |
| `SRF1:STN:CF2:` | Comb Filter | `:STATE`, `:HISTREC`, `:DIAGREC` |
| `SRF1:STN:CLK:` | Clock module | `:MODU.RSYN` (resync) |
| `SRF1:STN:AIM:` | Arc Interface | `:FRCBMABT`, `:MODU.RBA`, `:FILAMENT`, `:SOLENOID` |
| `SRF1:STN:IQA1/2/3:` | IQA monitors | `:MODU.AHSZ`, `:MODU.AHFS` |
| `SRF1:HVPS:` | HVPS control | `:VOLT:CTRL`, `:VOLT`, `:LOOP:CTRL`, `:RESET:CTRL` |
| `SRF1:HVPSSCR:` | SCR triggers | `:ON:CTRL` |
| `SRF1:HVPSCONTACT:` | Contactor | `:CLOSE:CTRL` |
| `SRF1:FILAMENT:` | Heater | `:ON:PLC`, `:TIMEBYP:PLC`, `:SUMY:PLC` |
| `SRF1:CAVTUNR:` | Tuner system | `:LOOPON:RESET.PROC`, `:LOOPPARK:RESET.PROC` |
| `SRF1:CAVn:TUNR:` | Per-cavity tuner | `:LOOP:CTRL`, `:LOOP:STATE`, `:LOOP:STATUS` |
| `SRF1:KLYSOUTFRWD:` | Klystron fwd power | `:POWER`, `:POWER:MAX` |
| `SRF1:KLYSDRIVFRWD:` | Drive power | `:POWER:ERR`, `:HVPS:DELTA` |
| `SRF1:STNON:SUMY:` | Fault summaries | `:STAT.SEVR` (ON faults) |
| `SRF1:STNOFF:SUMY:` | Fault summaries | `:STAT.SEVR` (OFF faults) |
| `SRF1:STNPARK:SUMY:` | Fault summaries | `:STAT.SEVR` (PARK faults) |

### 16.3 Database Templates

76 database files define the EPICS records, including:
- **Module records**: `aim.db`, `cf2.db`, `clk.db`, `gvf.db`, `iqa.db` — one per VXI module type
- **Allen-Bradley records**: `rf_ab_module.db`, `rf_ab_2CV.substitutions`, `rf_ab_4CV.substitutions`
- **Analog signal records**: `rf_analog.db` — RF power, voltage, current readbacks
- **Station records**: station state, fault summaries, alarm aggregation
- **I/Q conversion**: `iqCvt.db`, `iqGet.db` — amplitude/phase to I/Q and vice versa

---

## 17. Feedback Loop Architecture — Integrated View

### 17.1 Loop Hierarchy

The system implements a multi-layered feedback architecture operating at different timescales:

```
Layer 1 — DSP Fast Feedback (~MHz rate, in hardware)
├── Direct Loop: analog phase/amplitude feedback via RFP DSP
├── Comb Filter: revolution-harmonic beam-loading compensation via CF2
├── Ripple Loop: power-line frequency rejection via RFP DSP
└── Lead/Integral Compensation: additional feedback shaping via RFP

Layer 2 — SNL Supervisory Control (~0.5-10 Hz, software)
├── HVPS Loop (rf_hvps_loop.st): HVPS voltage regulation
├── DAC Loop (rf_dac_loop.st): drive power / gap voltage amplitude trim
├── Tuner Loop (rf_tuner_loop.st ×4): cavity frequency tracking
└── GFF/LFB: gap voltage feedforward and LFB woofer via GVF module

Layer 3 — State Machine (event-driven, software)
├── rf_states.st: station state management, loop sequencing
├── rf_msgs.st: fault logging and diagnostics
└── rf_calib.st: on-demand calibration
```

### 17.2 Signal Flow: Sensor to Actuator

```
                          LLRF Signal Processing Chain
                          ============================

   RF Cavities (×4)
   ├── Probe signals ──────────► IQA modules ──► Amplitude/Phase readback
   │                                            ├── Tuner loop (phase → motor)
   │                                            └── DAC loop (amplitude → RFP DAC)
   ├── Forward power couplers ─► IQA modules ──► Power readback
   │                                            ├── HVPS loop (power → voltage)
   │                                            └── Collector power monitoring
   └── Reflected power ───────► IQA modules ──► Arc/mismatch detection
                                                └── AIM interlock

   Station Reference ──────────► CLK module ──► Phase-locked LO distribution
                                               └── All modules synchronized

   RFP Module
   ├── [INPUT]  I/Q baseband signals from mixers
   ├── [DSP]    Direct loop, comb filter, ripple comp, compensation
   ├── [OUTPUT] I/Q drive signal via DACs ──► Drive Amplifier ──► Klystron
   └── [CTRL]   Octal DACs set by DAC loop (tune/operate setpoints)

   GVF Module
   ├── [INPUT]  Gap voltage error, LFB data
   ├── [COMPUTE] Feedforward reference, ripple filter coefficients
   └── [OUTPUT]  GFF I/Q reference values

   HVPS Chain
   ├── IOC rf_hvps_loop ──► SRF1:HVPS:VOLT:CTRL ──► AB serial ──► SLC-500 PLC
   └── SLC-500 ──► Analog output ──► Enerpro ──► SCR gate drive ──► Thyristors
```

### 17.3 Loop Interaction Diagram

```
                    ┌──────────────┐
                    │  BEAM CURRENT │
                    └──────┬───────┘
                           │ (beam loading affects cavity fields)
                           ▼
┌──────────┐    ┌──────────────────┐    ┌──────────────┐
│ HVPS     │───►│  KLYSTRON        │───►│  CAVITIES    │
│ Voltage  │    │  (800 kW @ 476MHz)│   │  (×4, ~712kV │
│ (SLC-500)│    └──────────────────┘    │   gap each)  │
└──────────┘              ▲              └──────┬───────┘
      ▲                   │                     │
      │            ┌──────┴───────┐      ┌──────┴───────┐
      │            │ Drive Amp    │      │ Probe Signals │
      │            │ (~29 W)      │      │ (amplitude,   │
      │            └──────────────┘      │  phase)       │
      │                   ▲              └──────┬───────┘
      │                   │                     │
      │            ┌──────┴───────┐      ┌──────┴───────┐
      │            │ RFP Module   │◄─────│ IQA Modules  │
      │            │ (Direct Loop,│      │ (A/P detect) │
      │            │  Comb, DACs) │      └──────────────┘
      │            └──────────────┘              │
      │                   ▲                      │
      │                   │                      ▼
┌─────┴──────┐   ┌───────┴────────┐   ┌──────────────────┐
│ HVPS Loop  │   │   DAC Loop     │   │   Tuner Loop (×4) │
│ (rf_hvps)  │   │   (rf_dac)     │   │   (rf_tuner)      │
│            │   │                │   │                    │
│ Adjusts    │   │ Adjusts I/Q   │   │ Adjusts stepper   │
│ HV voltage │   │ DAC setpoints │   │ motor position    │
└────────────┘   └────────────────┘   └────────────────────┘
      ▲                 ▲                      ▲
      │                 │                      │
      └────────────┬────┘──────────────────────┘
                   │
            ┌──────┴───────┐
            │  rf_states   │
            │  (master     │
            │   sequencer) │
            └──────────────┘
```

---

## 18. Interlock and Protection Logic

### 18.1 Protection Hierarchy

| Level | Mechanism | Response Time | Action |
|-------|-----------|---------------|--------|
| **Hardware** | AIM module beam abort | <1 ms | Immediate RF disable |
| **Hardware** | SCR trigger disable | <1 ms | HVPS output removed |
| **PLC** | RF MPS PLC-5 | ~10 ms | Permit removal |
| **Software** | `fault_stnoff` monitor in rf_states | ~100 ms | State → OFF |
| **Software** | Auto-reset in `s_go_stn_reset` | ~5 s per attempt | Automatic recovery |
| **Operator** | Manual reset | Minutes | Operator intervention |

### 18.2 Fault Summary PVs

The system uses a hierarchy of severity-based alarm summary PVs:

| PV | Trigger | Effect |
|----|---------|--------|
| `{STN}:STNOFF:SUMY:STAT.SEVR` | Any `!= NO_ALARM` in ON state | Transition to OFF |
| `{STN}:STNON:SUMY:STAT.SEVR` | Any `!= NO_ALARM` in OFF state | Block transition to ON |
| `{STN}:STNPARK:SUMY:STAT.SEVR` | Any `!= NO_ALARM` in PARK/OFF | Block PARK / trigger OFF from PARK |
| `{STN}:HVPSCONTACT:SUMY:STAT.SEVR` | HVPS contactor fault | Prevent auto-reset |
| `{STN}:STN:LOCAL:ON.SEVR` | Local panel switch off | Block all ON transitions |
| `{STN}:STN:FORCED:LTCH` | Forced fault latch | Prevent auto-reset |

### 18.3 Beam Abort Control

The AIM module provides beam abort functionality:
- **Force Beam Abort** (`{STN}:STN:AIM:FRCBMABT`): Used during state transitions to protect the beam
- **Reset Beam Abort** (`{STN}:STN:AIM:MODU.RBA`): Cleared after loops are stable
- **Reset Faults** (`{STN}:STN:AIM:MODU.RSTF`): Clears AIM fault registers including BATS (Beam Abort Trip Status)

### 18.4 Automatic Recovery

When a fault is detected in an ON state:
1. `fault_detected` flag is set, `state_when_fault` is saved
2. System transitions through `s_go_off` (full shutdown sequence)
3. Enters `s_go_stn_reset` which checks:
   - `reset_count > 0` (auto-reset enabled and retries remaining)
   - `forced_fault == 0` (no manually forced fault)
   - Contactor closed, panel switch on (if was in non-PARK state)
4. Performs station reset, waits 5 seconds, checks fault summary
5. Repeats up to `reset_count` times
6. If successful: restores previous state
7. If failed: remains in OFF, logs failure message


---

## 19. Assessment and Modernization Considerations

### 19.1 Hardware Obsolescence Assessment

| Component | Status | Risk Level | Replacement Path |
|-----------|--------|------------|-----------------|
| VXI Crate & CPU | **End-of-life** | 🔴 Critical | Replace with modern VME/PCIe or ATCA/µTCA chassis |
| PowerPC 604 CPU | **End-of-life** | 🔴 Critical | Any modern processor (x86/ARM with EPICS 7.x) |
| VxWorks RTOS | **Available but expensive** | 🟡 Medium | RTEMS, Linux/PREEMPT_RT, or VxWorks 7 |
| DSP1610 | **End-of-life** | 🔴 Critical | FPGA + embedded soft core, or modern DSP/SoC |
| RFP/IQA/GVF/CF2/CLK/AIM modules | **Custom, irreplaceable** | 🔴 Critical | New FPGA-based digital LLRF platform |
| Allen-Bradley DCM scanner | **End-of-life** | 🔴 Critical | EtherNet/IP gateway or modern PLC interface |
| 1746-HSTP1 stepper | **End-of-life** | 🟡 Medium | Modern stepper controller (EtherCAT, modbus) |
| PLC-5 | **End-of-life** | 🔴 Critical | CompactLogix, ControlLogix, or software PLC |
| SLC-500 | **Discontinued** | 🟡 Medium | CompactLogix replacement |

### 19.2 Software Architecture Assessment

**Strengths of the Legacy Design**:
- Well-proven in production for 25+ years
- Clean separation between supervisory control (SNL) and fast feedback (DSP)
- Comprehensive fault detection and automatic recovery
- PV-based inter-program communication provides loose coupling
- Extensive status reporting for operator visibility
- Good use of macros for multi-station deployment

**Weaknesses and Technical Debt**:
- PEP-II heritage code paths that are unused in SPEAR3 (e.g., HER/LER-specific IQA3 handling)
- Complex state transitions with many implicit timing dependencies (`taskDelay()` scattered throughout)
- No formal unit tests or simulation capability
- Custom record types tightly coupled to specific hardware register layouts
- DSP firmware in assembly language — no modern development or debugging tools
- No automated build/test/deploy pipeline
- Save/restore via custom `dbRestore` rather than standard autosave module
- Limited error recovery granularity (fault always goes to full OFF before retry)

### 19.3 Functional Requirements for the Replacement

Based on the code analysis, the replacement system must preserve these functional requirements:

| # | Requirement | Legacy Implementation | Criticality |
|---|------------|----------------------|-------------|
| F1 | 5-state station management (OFF/PARK/TUNE/ON_FM/ON_CW) | `rf_states.st` state set 1 | Essential |
| F2 | Configurable fast turn-on (sub-second beam recovery) | `rf_states.st` `s_go_on_cw` fast path | Essential |
| F3 | Automatic fault detection and retry | `rf_states.st` `s_go_stn_reset` | Essential |
| F4 | Fault file capture (11 data sources, 15 circular buffer) | `rf_states.st` state set 3 | Important |
| F5 | HVPS voltage regulation (3 modes: OFF/PROC/ON) | `rf_hvps_loop.st` | Essential |
| F6 | HVPS voltage processing (cavity conditioning) | `rf_hvps_loop.st` PROC mode | Important |
| F7 | Drive power / gap voltage amplitude regulation | `rf_dac_loop.st` | Essential |
| F8 | Per-cavity tuner control (4 instances) | `rf_tuner_loop.st` ×4 | Essential |
| F9 | Tuner homing (ON and PARK positions) | `rf_tuner_loop.st` reset state | Important |
| F10 | Octal DAC calibration (offset nulling) | `rf_calib.st` | Important |
| F11 | Direct loop with soft-start gain ramping | `rf_states.st` LP state set | Essential |
| F12 | Comb filter loop with soft-start gain ramping | `rf_states.st` LP state set | Essential |
| F13 | Lead + integral compensation control | `rf_states.st` LP state set | Essential |
| F14 | GFF loop and LFB woofer control | `rf_states.st`, `rf_dac_loop.st` | Essential |
| F15 | Ripple loop gain tracking | `rf_dac_loop.st` | Important |
| F16 | Beam abort force/reset management | `rf_states.st`, AIM module | Essential |
| F17 | TAXI error detection and auto-resync | `rf_msgs.st` TAXI state set | Important |
| F18 | HVPS subsystem fault logging | `rf_msgs.st` | Useful |
| F19 | Filament fault response (contactor open) | `rf_msgs.st` | Important |
| F20 | Load angle monitoring per cavity | `rf_tuner_loop.st` | Important |

### 19.4 Highest-Risk Areas for Modernization

1. **Loop Transition Sequencing**: The `rf_statesLP` state set implements extremely intricate timing-sensitive loop enable/disable sequences. The gain ramping with `directlpgaindelta`, `comblpgaindelta`, and `ramp_settle_time` parameters must be precisely replicated. Getting this wrong could cause beam loss or hardware damage.

2. **Fast Turn-On Path**: The fast turn-on code in `s_go_on_cw` bypasses the normal sequential loop enable sequence for rapid beam recovery. This is operationally critical and has many subtle hardware dependencies.

3. **Fault File Capture**: The coordinated capture of data from 11 different hardware buffers across 5 different module types, all within a tight timing window after a fault, requires careful reimplementation.

4. **HVPS PLC Communication**: The SLC-500 ladder logic and AB serial communication protocol must be fully characterized before replacement. The voltage control safety interlocks in the PLC are part of the safety chain.

5. **DSP Feedback Algorithms**: The DSP1610 firmware implements the critical fast-feedback loops. These algorithms must be precisely understood and reimplemented (likely in FPGA fabric) with equivalent or better performance.

### 19.5 PEP-II Heritage Features to Evaluate for Removal

| Feature | Location | Notes |
|---------|----------|-------|
| IQA3 dynamic assignment | `rf_states.st` init | HER-specific, may not be needed |
| `ring` PV and HER/LER TAXI assignment | `rf_msgs.st` | PEP-II ring selection |
| `DOCOMB` conditional compilation | `rf_calib.st` | Old comb vs CF2 |
| CF2 vs CFM conditional code | `rf_states.st` | Old CFM support |
| ON_FM state and I/Q file loading | `rf_states.st` | May not be used at SPEAR3 |
| PEP-II-specific calibration stages | `rf_calib.st` | Review with RF engineers |

### 19.6 Recommended Modernization Strategy

1. **Preserve the supervisory architecture**: The 6-program SNL architecture maps well to a modern EPICS 7 IOC with IOC Shell sequencer or Python-based state machines. The program decomposition is sound.

2. **Replace hardware layer completely**: All VXI modules → FPGA-based digital LLRF platform (as described in PDR). This eliminates the custom record types and device support layer.

3. **Implement a hardware abstraction layer**: Create a clean interface between the supervisory state machines and the new hardware. This should be designed for testability (simulation mode).

4. **Retain the PV interface contract**: Where possible, maintain the same PV names and semantics so existing operator displays, archiving, and external systems continue to work.

5. **Add comprehensive testing**: Implement unit tests for state machine logic, integration tests for loop interactions, and hardware-in-the-loop simulation for commissioning.

6. **Modernize the PLC interface**: Replace AB serial with EtherNet/IP and update the SLC-500 to CompactLogix. Keep the same voltage control logic but add modern diagnostics.

---

## 20. Appendix: Source File Inventory

### 20.1 SNL State Programs

| File | Directory | Lines | Description |
|------|-----------|-------|-------------|
| `rf_states.st` | `rfApp/src/seq/` | 2,227 | Master state machine (3 state sets) |
| `rf_calib.st` | `rfApp/src/seq/` | 3,345 | RFP octal DAC calibration |
| `rf_tuner_loop.st` | `rfApp/src/seq/` | 555 | Per-cavity tuner control (reentrant ×4) |
| `rf_hvps_loop.st` | `rfApp/src/seq/` | 343 | HVPS voltage regulation |
| `rf_msgs.st` | `rfApp/src/seq/` | 352 | Message logging + TAXI error monitor |
| `rf_dac_loop.st` | `rfApp/src/seq/` | 290 | DAC amplitude control |

### 20.2 SNL Header Files

| File | Directory | Lines | Description |
|------|-----------|-------|-------------|
| `rf_states_pvs.h` | `rfApp/src/seq/` | ~300 | PV declarations for rf_states |
| `rf_states_defs.h` | `rfApp/src/seq/` | ~150 | Constants and macros for rf_states |
| `rf_states_macs.h` | `rfApp/src/seq/` | ~200 | Macro functions for rf_states |
| `rf_loop_defs.h` | `rfApp/src/seq/` | ~20 | Common loop definitions |
| `rf_loop_macs.h` | `rfApp/src/seq/` | ~20 | Common loop macros |
| `rf_hvps_loop_defs.h` | `rfApp/src/seq/` | ~80 | HVPS loop constants |
| `rf_hvps_loop_macs.h` | `rfApp/src/seq/` | ~80 | HVPS loop macros |
| `rf_hvps_loop_pvs.h` | `rfApp/src/seq/` | ~120 | HVPS loop PV declarations |
| `rf_dac_loop_defs.h` | `rfApp/src/seq/` | ~50 | DAC loop constants |
| `rf_dac_loop_macs.h` | `rfApp/src/seq/` | ~100 | DAC loop macros |
| `rf_dac_loop_pvs.h` | `rfApp/src/seq/` | ~120 | DAC loop PV declarations |
| `rf_tuner_loop_defs.h` | `rfApp/src/seq/` | ~80 | Tuner loop constants |
| `rf_tuner_loop_macs.h` | `rfApp/src/seq/` | ~80 | Tuner loop macros |
| `rf_tuner_loop_pvs.h` | `rfApp/src/seq/` | ~100 | Tuner loop PV declarations |

### 20.3 Custom Record Types and Device Support

| File | Directory | Lines | Description |
|------|-----------|-------|-------------|
| `p2RfRfpRecord.c` | `rfApp/src/db/` | 296 | RFP record support |
| `devP2RfRfp.c` | `rfApp/src/db/` | 2,389 | RFP device support |
| `p2RfRfpDef.h` | `rfApp/src/db/` | 565 | RFP module definitions |
| `p2RfIqaRecord.c` | `rfApp/src/db/` | 301 | IQA record support |
| `devP2RfIqa.c` | `rfApp/src/db/` | 2,260 | IQA device support |
| `p2RfIqaDef.h` | `rfApp/src/db/` | 509 | IQA module definitions |
| `p2RfGvfRecord.c` | `rfApp/src/db/` | 307 | GVF record support |
| `devP2RfGvf.c` | `rfApp/src/db/` | 2,350 | GVF device support |
| `p2RfGvfDef.h` | `rfApp/src/db/` | 330 | GVF module definitions |
| `p2RfCf2Record.c` | `rfApp/src/db/` | 366 | CF2 record support |
| `devP2RfCf2.c` | `rfApp/src/db/` | 2,970 | CF2 device support |
| `p2RfCf2Def.h` | `rfApp/src/db/` | 403 | CF2 module definitions |
| `p2RfClkRecord.c` | `rfApp/src/db/` | 299 | CLK record support |
| `devP2RfClk.c` | `rfApp/src/db/` | 957 | CLK device support |
| `p2RfClkDef.h` | `rfApp/src/db/` | 271 | CLK module definitions |
| `p2RfAimRecord.c` | `rfApp/src/db/` | 300 | AIM record support |
| `devP2RfAim.c` | `rfApp/src/db/` | 1,982 | AIM device support |
| `p2RfAimDef.h` | `rfApp/src/db/` | 390 | AIM module definitions |
| `drvP2RfVxi.c` | `rfApp/src/db/` | 2,671 | VXI bus driver |
| `drvP2RfVxi.h` | `rfApp/src/db/` | 191 | VXI driver header |
| `subIQ.c` | `rfApp/src/db/` | 965 | I/Q conversion subroutines |
| `subSys.c` | `rfApp/src/db/` | 464 | System subroutines |

### 20.4 Allen-Bradley Support

| File | Directory | Lines | Description |
|------|-----------|-------|-------------|
| `drvAb.c` | `allenBradley/.../basicSrc/` | 2,039 | AB driver |
| `devSmAB1746HSTP1.c` | `allenBradley/.../1746HSTP1Src/` | 1,673 | Stepper motor device support |
| `steppermotorRecord.c` | `stepper/stepper/` | 959 | Custom stepper motor record |

### 20.5 Key Database Files

| File | Directory | Description |
|------|-----------|-------------|
| `srf1.db` | `rfApp/Db/` | Complete station database (via substitutions) |
| `aim.db` | `rfApp/Db/` | AIM module records |
| `cf2.db` | `rfApp/Db/` | CF2 (comb filter) records |
| `clk.db` | `rfApp/Db/` | Clock module records |
| `gvf.db` | `rfApp/Db/` | GVF module records |
| `iqa.db` | `rfApp/Db/` | IQA monitor records |
| `rf_ab_module.db` | `rfApp/Db/` | Allen-Bradley module records |
| `rf_analog.db` | `rfApp/Db/` | Analog signal computation records |
| `iqCvt.db` | `rfApp/Db/` | I/Q ↔ amplitude/phase conversion |

---

## Glossary

| Term | Definition |
|------|-----------|
| **AIM** | Arc Interface Module — VXI module for interlock aggregation and beam abort |
| **BATS** | Beam Abort Trip Status — AIM fault register |
| **CF2** | Comb Filter v2 — VXI module for revolution-harmonic feedback |
| **CFM** | Comb Filter Module (original version, replaced by CF2) |
| **CLK** | Clock Module — VXI timing distribution |
| **CW** | Continuous Wave — full-power operational mode |
| **DCM** | Data Communications Module (Allen-Bradley 1747-DCM) |
| **DSP** | Digital Signal Processor (DSP1610 in RFP/GVF modules) |
| **EPICS** | Experimental Physics and Industrial Control System |
| **FM** | Frequency Modulation mode |
| **GFF** | Gap voltage Feed-Forward |
| **GVF** | Gap Voltage Feedforward module (VXI) |
| **HVPS** | High Voltage Power Supply |
| **I/Q** | In-phase / Quadrature (baseband representation of RF signals) |
| **IOC** | Input/Output Controller (EPICS process) |
| **IQA** | I/Q Amplitude monitor module (VXI) |
| **LFB** | Longitudinal Feedback (beam stabilization system) |
| **LLRF** | Low-Level Radio Frequency (control system) |
| **MPS** | Machine Protection System |
| **PV** | Process Variable (EPICS data point) |
| **RFP** | RF Processor module (VXI) |
| **SCR** | Silicon Controlled Rectifier (thyristor in HVPS) |
| **SNL** | State Notation Language (EPICS sequencer programming language) |
| **TAXI** | Communication link protocol used by LFB system |
| **VXI** | VME eXtensions for Instrumentation |

---

*End of Technical Report*

*This document was generated through comprehensive source code analysis of the `rf-spear-legacy/` repository. All line counts, state descriptions, and PV references are derived directly from the codebase. For operational parameters and runtime behavior details, consult the operations team and archived log files.*
