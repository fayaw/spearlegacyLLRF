# Legacy LLRF Control System — Comprehensive Technical Report

**Document ID**: SPEAR3-LLRF-LEGACY-TR-001
**Date**: March 2026
**Classification**: Technical Reference for LLRF Upgrade Project
**Scope**: Complete analysis of all source code in `rf-spear-legacy/`

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Architecture](#2-system-architecture)
3. [Source Code Inventory](#3-source-code-inventory)
4. [VXI Bus Driver — drvP2RfVxi.c](#4-vxi-bus-driver)
5. [Device Support Modules](#5-device-support-modules)
6. [Custom EPICS Record Types](#6-custom-epics-record-types)
7. [SNL State Machines](#7-snl-state-machines)
8. [DSP Firmware](#8-dsp-firmware)
9. [Pure Math Subroutines](#9-pure-math-subroutines)
10. [Allen-Bradley Communication](#10-allen-bradley-communication)
11. [Stepper Motor Drivers](#11-stepper-motor-drivers)
12. [EPICS VXI Subsystem](#12-epics-vxi-subsystem)
13. [VxWorks Base Infrastructure](#13-vxworks-base-infrastructure)
14. [EPICS Databases](#14-epics-databases)
15. [IOC Boot Configuration](#15-ioc-boot-configuration)
16. [Diagnostic Utilities](#16-diagnostic-utilities)
17. [Upgrade Migration Assessment](#17-upgrade-migration-assessment)
18. [Appendix A: State Transition Tables](#appendix-a-state-transition-tables)
19. [Appendix B: Key PV Namespace](#appendix-b-key-pv-namespace)
20. [Appendix C: DSP Algorithm Pseudocode](#appendix-c-dsp-algorithm-pseudocode)

---

## 1. Executive Summary

### 1.1 Purpose

This document provides a comprehensive technical analysis of the entire SPEAR3 legacy LLRF control system source code, contained in the `rf-spear-legacy/` repository. The goal is to give the upgrade team a complete understanding of what the current system does, how it is organized, and what knowledge must be carried forward into the new LLRF9-based control system.

### 1.2 System Overview

The legacy LLRF control system was originally designed for the PEP-II B-Factory (circa 1996–1997) by R. Claus, S. Allison, R. Sass, and others at SLAC. It was later adapted for SPEAR3. The system controls a single RF station: one klystron driving four single-cell cavities at 476.3 MHz, producing approximately 2.85 MV total gap voltage.

### 1.3 Codebase Summary

| Metric | Value |
|--------|-------|
| **Total source lines** | **106,240** |
| **Total files** | **~250+** |
| **Primary language** | C (device support, drivers), SNL (state machines), DSP1610 assembly (firmware) |
| **RTOS** | VxWorks (Motorola PPC604) |
| **Bus standard** | VXI (VME eXtensions for Instrumentation) |
| **EPICS version** | R3.14.x (estimated from includes and API usage) |
| **PLC communication** | Allen-Bradley serial (via VME scanner card) |
| **Origin** | PEP-II B-Factory, SLAC, 1996–2006 |

### 1.4 Key Finding: Code Disposition

| Category | Lines | % of Total | Upgrade Disposition |
|----------|-------|------------|---------------------|
| **Eliminated (hardware-specific)** | ~82,000 | 77% | VXI, VxWorks, DSP, AB serial — all replaced |
| **Specification extraction** | ~15,000 | 14% | State machines, control algorithms, PV definitions |
| **Reusable math** | ~1,600 | 1.5% | subIQ.c, subSys.c — pure math, portable |
| **PEP-II dead code** | ~7,600 | 7% | GVF, CF2, CFM modules — never used in SPEAR3 |

**Bottom line**: ~77% of the codebase is hardware-specific and will be completely eliminated by the upgrade. The critical intellectual property is in the **behavioral specifications** encoded in the SNL state machines (7,112 lines) and the **signal processing algorithms** in the DSP firmware (16,125 lines) and subroutine records (1,571 lines).

---

## 2. System Architecture

### 2.1 Software Layer Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│ Layer 5: OPERATOR INTERFACE (EDM/MEDM screens, archiver, alarms)    │
├──────────────────────────────────────────────────────────────────────┤
│ Layer 4: SNL STATE MACHINES & SUBROUTINE RECORDS                    │
│  ┌──────────────┐ ┌────────────┐ ┌──────────────┐ ┌──────────────┐ │
│  │ rf_states.st │ │rf_hvps_    │ │rf_tuner_     │ │rf_dac_       │ │
│  │ (2,227 lines)│ │loop.st     │ │loop.st       │ │loop.st       │ │
│  │ Station FSM  │ │(343 lines) │ │(555 lines)   │ │(290 lines)   │ │
│  │ OFF/PARK/    │ │HVPS voltage│ │Cavity tuner  │ │Drive power/  │ │
│  │ TUNE/ON_CW   │ │regulation  │ │phase feedback│ │Gap voltage   │ │
│  └──────────────┘ └────────────┘ └──────────────┘ └──────────────┘ │
│  ┌──────────────┐ ┌────────────┐ ┌──────────────┐ ┌──────────────┐ │
│  │rf_calib.st   │ │rf_msgs.st  │ │subIQ.c       │ │subSys.c      │ │
│  │(3,345 lines) │ │(352 lines) │ │(965 lines)   │ │(606 lines)   │ │
│  │DAC/Modulator │ │TAXI error  │ │I/Q phase,    │ │Frequency,    │ │
│  │calibration   │ │monitoring  │ │amplitude,    │ │DC coeff,     │ │
│  │              │ │            │ │power calcs   │ │phase calcs   │ │
│  └──────────────┘ └────────────┘ └──────────────┘ └──────────────┘ │
├──────────────────────────────────────────────────────────────────────┤
│ Layer 3: EPICS DEVICE SUPPORT (C code, custom record types)         │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │ ACTIVE in SPEAR3:                                              │ │
│  │  devP2RfRfp.c  (2,389 lines) - RF Processor module, Slot 4    │ │
│  │  devP2RfIqa.c  (2,277 lines) - I/Q Amplitude, Slots 7/9/11   │ │
│  │  devP2RfAim.c  (2,061 lines) - Arc Interlock Module, Slot 12  │ │
│  │  devP2RfClk.c  (979 lines)   - Clock Module, Slot 2           │ │
│  │                                                                │ │
│  │ PEP-II ONLY (not installed in SPEAR3):                         │ │
│  │  devP2RfGvf.c  (2,325 lines) - Gap Voltage Feed-Forward       │ │
│  │  devP2RfCf2.c  (2,847 lines) - Comb Filter v2                 │ │
│  │  devP2RfCfm.c  (1,514 lines) - Comb Filter v1                 │ │
│  └─────────────────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────────────────┤
│ Layer 2: VXI BUS DRIVER                                             │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │ drvP2RfVxi.c (2,671 lines)                                    │ │
│  │ - Module discovery, registration, interrupt handling           │ │
│  │ - VME A16/A24/A32 memory-mapped register access               │ │
│  │ - File I/O for coefficients, DDF filters, DSP programs        │ │
│  │ - Circular buffer RAM access (512K per module)                 │ │
│  │ - DSP communication block interface                            │ │
│  └─────────────────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────────────────┤
│ Layer 1: HARDWARE COMMUNICATION                                     │
│  ┌──────────────┐ ┌────────────────┐ ┌──────────────────────────┐  │
│  │AB Serial     │ │VXI/VME         │ │DSP1610 Firmware          │  │
│  │drvAb.c       │ │epvxi subsystem │ │rfpDsp/ (ripple loop)     │  │
│  │(2,039 lines) │ │(7,846 lines)   │ │gvfDsp/ (GVF, PEP-II)    │  │
│  │Scanner card  │ │Module init,    │ │genDsp/ (math library)    │  │
│  │to PLC-5/     │ │resource mgr,   │ │obsDsp/ (observation)     │  │
│  │SLC-500       │ │ISR dispatch    │ │Total: ~16,125 lines      │  │
│  └──────────────┘ └────────────────┘ └──────────────────────────┘  │
├──────────────────────────────────────────────────────────────────────┤
│ Layer 0: VxWorks RTOS & HARDWARE                                    │
│  KSC V152 CPU (PPC604) | VXI Chassis | AB Scanner | DSP Boards     │
│  VxWorks BSP, MMU, boot, tick timers (~12,200 lines base/)         │
└──────────────────────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

```
RF Cavity Gap → IQA Modules → I/Q/Amplitude → subIQ.c math →
  → Power/Phase/Amplitude PVs → State Machine decisions →
  → RFP Module (feedback) + HVPS (voltage) + Tuner (frequency)
```

### 2.3 Hardware Slot Map (SPEAR3 VXI Crate)

| Slot | Module | Code File | Status |
|------|--------|-----------|--------|
| 0 | KSC V152 CPU | base/ | IOC processor |
| 1 | AB VME Scanner | drvAb.c | Allen-Bradley interface |
| 2 | Clock (CLK) | devP2RfClk.c | RF reference distribution |
| 3 | *(empty)* | — | GVF slot unused in SPEAR3 |
| 4 | **RF Processor (RFP)** | **devP2RfRfp.c** | **Core feedback controller** |
| 5 | MPS Shutoff | — | Not CF2 (PEP-II only) |
| 6 | *(empty)* | — | |
| 7 | **IQA #1** | **devP2RfIqa.c** | **Amplitude/phase monitor** |
| 8 | *(empty)* | — | |
| 9 | **IQA #2** | **devP2RfIqa.c** | **Amplitude/phase monitor** |
| 10 | *(empty)* | — | |
| 11 | **IQA #3** | **devP2RfIqa.c** | **Amplitude/phase monitor** |
| 12 | **AIM** | **devP2RfAim.c** | **Arc Interlock Module** |

> **Source**: `srf1.substitutions` in `rfApp/Db/` and slot assignments in device support `InitRecord()` functions.

---

## 3. Source Code Inventory

### 3.1 Complete File Inventory

#### Device Support & Driver (`rfApp/src/db/`)

| File | Lines | Description | SPEAR3 Active? | Reuse |
|------|-------|-------------|-----------------|-------|
| `drvP2RfVxi.c` | 2,671 | VXI master driver — init, ISR, VME access, file I/O | Yes (driver) | Reference |
| `drvP2RfVxi.h` | 236 | Driver header — constants, macros, prototypes | Yes | Reference |
| `devP2RfRfp.c` | 2,389 | RF Processor device support — feedback, DACs, DSP comm | **Yes** | Spec-extract |
| `devP2RfIqa.c` | 2,277 | I/Q Amplitude device support — scan task, I/Q data | **Yes** | Spec-extract |
| `devP2RfAim.c` | 2,061 | Arc Interlock Module device support | **Yes** | Spec-extract |
| `devP2RfClk.c` | 979 | Clock module device support | **Yes** | Reference |
| `devP2RfGvf.c` | 2,325 | Gap Voltage Feed-Forward — PEP-II only | No | Dead code |
| `devP2RfCf2.c` | 2,847 | Comb Filter v2 — PEP-II only | No | Dead code |
| `devP2RfCfm.c` | 1,514 | Comb Filter v1 — PEP-II only | No | Dead code |
| `subIQ.c` | 965 | Pure math: I/Q → phase, amplitude, power, DAC calcs | **Yes** | **Reusable** |
| `subSys.c` | 606 | Pure math: frequency offset, DC coeff, phase, logging | **Yes** | **Reusable** |
| `p2RfRfpDef.h` | 565 | RFP register/bit definitions | Yes | Reference |
| `p2RfIqaDef.h` | 619 | IQA register/bit definitions | Yes | Reference |
| `p2RfAimDef.h` | 383 | AIM register/bit definitions | Yes | Reference |
| `p2RfClkDef.h` | 328 | CLK register/bit definitions | Yes | Reference |
| `p2RfGvfDef.h` | 405 | GVF register/bit definitions | No | Dead code |
| `p2RfCf2Def.h` | 502 | CF2 register/bit definitions | No | Dead code |
| `p2RfCfmDef.h` | 330 | CFM register/bit definitions | No | Dead code |
| `p2RfLib.h` | 138 | Common library header | Yes | Reference |
| `fast_lock.h` | 135 | Fast mutex implementation | Yes | Reference |
| `rf_station_state.h` | 7 | Station state constants (OFF=0, PARK=1, TUNE=2, ON_FM=3, ON_CW=4) | **Yes** | **Reusable** |
| `p2RfInitClk.c` | 293 | Clock initialization | Yes | Reference |
| `p2RfInitHooks.c` | 133 | EPICS init hooks | Yes | Reference |
| 7 × `*Record.c` | ~2,203 | Custom record type implementations | Yes | Reference |
| 7 × `*Record.dbd` | ~280 | Record type definitions | Yes | Spec-extract |
| **Subtotal** | **~24,300** | | | |

#### SNL State Machines (`rfApp/src/seq/`)

| File | Lines | Description | Upgrade Disposition |
|------|-------|-------------|---------------------|
| `rf_states.st` | 2,227 | **Master station state machine** (OFF→PARK→TUNE→ON_FM→ON_CW) | **HIGH-PRIORITY SPEC-EXTRACT** |
| `rf_hvps_loop.st` | 343 | HVPS voltage regulation (init/off/proc/on) | **SPEC-EXTRACT → HVPS PLC** |
| `rf_tuner_loop.st` | 555 | Cavity tuner phase feedback loop | **SPEC-EXTRACT → Galil/LLRF9** |
| `rf_dac_loop.st` | 290 | Drive power/gap voltage DAC loop | **ELIMINATED** (LLRF9 internal) |
| `rf_calib.st` | 3,345 | DAC calibration & modulator setup | **PARTIAL SPEC-EXTRACT** |
| `rf_msgs.st` | 352 | TAXI error monitoring & logging | **ELIMINATED** (no TAXI in LLRF9) |
| 11 × `*.h` headers | 1,111 | PV declarations, macros, constants | **SPEC-EXTRACT** (PV names) |
| **Subtotal** | **8,223** | | |

#### DSP Firmware (`rfApp/src/dsp/`)

| Directory | Lines | Description | Upgrade Disposition |
|-----------|-------|-------------|---------------------|
| `rfpDsp/` | 7,919 | RFP ripple rejection — DSP1610 assembly | Reference (algorithms only) |
| `gvfDsp/` | 4,619 | GVF feed-forward — PEP-II only | Dead code |
| `genDsp/` | 1,556 | Generic math (atan, sin, cos, sqrt) | Eliminated |
| `obsDsp/` | 2,031 | Observation/analysis routines | Eliminated |
| **Subtotal** | **16,125** | | |

#### Allen-Bradley Communication

| Directory | Lines | Description | Upgrade Disposition |
|-----------|-------|-------------|---------------------|
| `basicSrc/` (drvAb.c, devABBINARY.c, devABStatus.c) | 2,835 | AB serial driver, binary I/O | Eliminated |
| `1746HSTP1Src/` (devSmAB1746HSTP1.c) | 1,673 | AB stepper motor driver | Eliminated (Galil replaces) |
| `1771DCMSrc/` | 2,649 | DCM data table access I/O module drivers | Eliminated |
| `1771IFESrc/` | 717 | IFE analog input | Eliminated |
| `1771IXSrc/` | 796 | IX thermocouple input | Eliminated |
| `1771NSeriesSrc/` | 1,418 | N-series analog I/O | Eliminated |
| `1791BlockIOSrc/` | 578 | Block I/O | Eliminated |
| `SLCDCMSrc/` | 563 | SLC-500 DCM interface | Eliminated |
| `gpIfaceSrc/` | 393 | General purpose I/O interface | Eliminated |
| `oldSrc/` | 1,073 | Deprecated AB module drivers | Dead code |
| **Subtotal** | **12,695** | | |

#### Stepper Motor Drivers (`stepper/`)

| File | Lines | Description | Upgrade Disposition |
|------|-------|-------------|---------------------|
| `drvCompuSm.c` | 872 | Compumotor 1830 serial driver | Eliminated (Galil replaces) |
| `drvOms.c` | 705 | OMS 6-axis VME stepper driver | Eliminated |
| `steppermotorRecord.c` | 959 | Custom stepper motor record | Eliminated |
| Others (devSm*, headers) | 305 | Device support wrappers | Eliminated |
| **Subtotal** | **2,841** | | |

#### EPICS VXI Subsystem (`epvxi/`)

| File | Lines | Description | Upgrade Disposition |
|------|-------|-------------|---------------------|
| `drvEpvxi.c` | 4,622 | VXI resource manager, module discovery | Eliminated |
| `drvEpvxiMsg.c` | 1,529 | VXI message-based communication | Eliminated |
| `drvHp1404a.c` | 393 | HP 1404A oscilloscope driver | Eliminated |
| `drvExampleVxi.c` | 240 | Example VXI driver | Dead code |
| Headers (3 files) | 1,062 | VXI definitions | Reference |
| **Subtotal** | **7,846** | | |

#### VxWorks Base Infrastructure (`rfApp/src/base/`)

~60 files totaling **12,187 lines**: VxWorks BSP, MMU configuration, boot support, DSP loading library, bus utilities, VXI interrupt service, initialization hooks, link-list library, time utilities.

**Upgrade Disposition**: **100% Eliminated** — All replaced by Linux on modern IOC hardware.

#### EPICS Databases (`rfApp/Db/`)

**76 files**, approximately **9,546 lines** of `.db`, `.substitutions`, and `.template` files.

Key databases:
- `rfp.db`, `rfp_dacs.db` — RFP module records
- `iqa.db`, `rf_iqa.db`, `rf_iqa_module.db` — IQA module records
- `aim.db` — AIM module records
- `clk.db` — Clock module records
- `rf_stn.db`, `rf_stn_cav.db` — Station-level records
- `rf_hvps.db` — HVPS records
- `rf_digital_plc.db`, `rf_digital_modu.db`, `rf_digital_hvps.db` — PLC/module/HVPS digital I/O
- `rf_analog.db` — Analog signal records
- `rf_beam*.db` — Beam-related records
- `rf_interlock*.db` — Interlock records
- `rf_sumy_*.db` — Summary alarm records
- `rf_temp.db` — Temperature monitoring
- Various `.substitutions` files — Template instantiation for SPEAR3 (SRF1 station)

**Upgrade Disposition**: **SPEC-EXTRACT** — PV names, relationships, and alarm configurations encode the operator interface contract. The LLRF9 IOC must provide equivalent PVs.

#### IOC Boot Configuration (`iocBoot/b132-iocrf/`)

| File | Lines | Description |
|------|-------|-------------|
| `st.cmd` | ~98 | VxWorks boot script — loads EPICS, databases, starts sequences |
| `config.ab` | ~55 | Allen-Bradley scanner configuration (3 adapters) |
| `Makefile` | ~15 | Build support |
| `vbb.hlp` | ~30 | VBB help file |

**Key information from `st.cmd`**:
- Station macro: `STN=SRF1` (SPEAR RF Station 1)
- 4 tuner loop instances: `CAV=1`, `CAV=2`, `CAV=3`, `CAV=4`
- Database loaded: `db/srf1.db`
- All 6 SNL programs started after `iocInit()`
- AB scanner: Link 0, base address `0xc00000`, vector `0x60`, IRQ level 4
- Three AB adapters configured: Adapter 1 (Full), Adapter 2 (3/4), Adapter 3 (1/4)
- VXI logical address base: 0x01, count: 13 devices

---


## 4. VXI Bus Driver

### 4.1 Overview — `drvP2RfVxi.c` (2,671 lines)

**Author**: R. Claus, SLAC/PEP-II LLRF Group (April 25, 1996)

This is the master driver for all PEP-II RF VXI modules. It provides the hardware abstraction layer between EPICS device support and the VXI bus.

### 4.2 Key Functions

| Function | Lines | Purpose |
|----------|-------|---------|
| `P2RF_Init()` | ~30 | Discover all PEP-II VXI modules via manufacturer code |
| `P2RF_InitModule()` | ~80 | Per-module: allocate memory, map VME space, connect ISR |
| `P2RF_RegisterModule()` | ~80 | Device support registration — verify make/model, store ISR/shutdown |
| `P2RF_RegisterClient()` | ~20 | Multi-client semaphore for shared module access |
| `P2RF_IntServRtn()` | ~60 | Interrupt service — dispatches to module-specific ISR |
| `P2RF_ReadVme()` | ~20 | Atomic VME register read (A16 or extended space) |
| `P2RF_WriteVme()` | ~20 | Atomic VME register write |
| `P2RF_LoadConsts()` | ~20 | Load integer constants array to module registers |
| `P2RF_LoadCoefs()` | ~30 | Load float coefficients with linear scaling to integer |
| `P2RF_ReadConstsFile()` | ~80 | Read constants from file (hex or Q14 float format) |
| `P2RF_ReadCoefFile()` | ~70 | Read float coefficients from file |
| `P2RF_LoadDdf()` | ~50 | Load Harris DDF (Digital Decimation Filter) chip registers |
| `P2RF_ReadDdfFile()` | ~100 | Parse DECI-MATE coefficient file format |
| `P2RF_CopyMemory()` | ~30 | Read from 512K circular buffer RAM (semaphore-protected) |
| `P2RF_RecordMemory()` | ~80 | Record circular buffer to binary file (double-buffered) |
| `P2RF_DspFindComBlk()` | ~15 | Locate DSP communication block in extended memory |
| `P2RF_SaveDspMemory()` | ~40 | Save DSP memory to ASCII file |
| `P2RF_LoadRegFile()` | ~60 | Load register values from formatted data file |
| `P2RF_ResetModule()` | ~15 | Software reset via VXI control register bit toggle |
| `P2RF_Shutdown()` | ~15 | Graceful shutdown of all modules |

### 4.3 Critical Implementation Details

**Atomic register access**: Uses FASTLOCK/FASTUNLOCK (mutex) around every register read/write. The code comments note: "Sometimes one runs into a problem where multiple tasks go after the same register on a module in an uncontrolled fashion."

**Interrupt handling**: VXI interrupts are dispatched through `P2RF_IntServRtn()` which reads the interrupt status register, acknowledges the interrupt, and calls the module-specific ISR registered during `P2RF_RegisterModule()`. The ISR uses a `vxTas()` (test-and-set) guard to detect overlapping interrupts.

**Memory access protocol**: The 512K circular buffer RAMs on each module are accessed through a single register (hardware manages addressing internally). Multi-client access is protected by a counting semaphore. The `P2RF_CopyMemory()` function performs an initial "dummy read" to position the hardware pointer before the actual data transfer.

**File format conventions**: 
- Constants files: ID string header + hex or Q14 float data
- Coefficient files: ID string header + floating-point data
- DDF files: Harris DECI-MATE format (F, FC, H1, H2 registers)
- Register files: ID header + index/value pairs with comment support

**Upgrade significance**: This driver is **100% eliminated** — LLRF9 uses Ethernet/IP instead of VXI bus. However, the register maps and file format conventions document what the legacy modules expected, which informs what PVs the new IOC must provide.

---

## 5. Device Support Modules

### 5.1 RF Processor — `devP2RfRfp.c` (2,389 lines)

**Author**: R. Claus (September 11, 1996), modified by M. Laznovsky (2003–2004)
**VXI Slot**: 4 | **Model**: 0x103 | **Drawing**: 340-304

This is the heart of the LLRF system — it controls the analog feedback loop that regulates cavity amplitude and phase.

#### Module States

```
    rfpReset (0) → rfpLoad (1) → rfpRun (2)
```

The RFP module has three hardware modes set via the MODE field in the RF Control register:
- **RESET**: Module initialization, DSP halted
- **LOAD**: Module accepts DSP code, coefficients, RAM data
- **RUN**: Active RF feedback loop, DSP executing ripple algorithm

#### Key Control Fields (from record)

| Field | Name | Description | Upgrade Equivalent |
|-------|------|-------------|-------------------|
| `rfoo` | RF Output On | Master RF enable | LLRF9 RF enable register |
| `rle` | Ripple Loop Enable | Enable ripple rejection DSP | LLRF9 built-in (always on) |
| `ice` | Integral Compensation Enable | Enable integral compensator | LLRF9 configuration |
| `lce` | Lead Compensation Enable | Enable lead compensator (inverted logic!) | LLRF9 configuration |
| `dle` | Direct Loop Enable | Enable amplitude direct feedback | LLRF9 amplitude loop |
| `cle` | Comb Loop Enable | Enable comb filter (PEP-II multi-bunch) | Eliminated |
| `rlon` | Analog Ripple Loop On | Enable analog ripple rejection path | Eliminated |
| `csmx` | Cavity Select Mux | Select which cavity signal to process | LLRF9 channel select |
| `fsmx` | Feedback Signal Mux | Select feedback signal source | LLRF9 feedback config |
| `mode` | Operating Mode | RESET/LOAD/RUN state | Implicit in LLRF9 startup |
| `lod` | Load Octal DACs | Trigger to load all 8 DAC channels | LLRF9 DAC configuration |
| `dlod` | Load DSP DAC Offsets | Load DAC offsets from DSP | LLRF9 offset trim |
| `ldsp` | Load DSP | Trigger DSP firmware download | Eliminated (FPGA) |
| `ldas` | Load Amplitude Setpoint | Load amplitude setpoint to DSP (Q13) | LLRF9 setpoint register |
| `ldpg` | Load Phase Gain | Load phase gain to DSP (Q14) | LLRF9 gain register |
| `amsp` | Amplitude Setpoint | Float value for DSP amplitude target | LLRF9 setpoint |
| `phsg` | Phase Gain | Float value for DSP phase gain | LLRF9 gain |

#### DSP Communication Protocol

The RFP communicates with its DSP via a shared memory block (`DspComBlk`) in extended VME space:

```c
typedef struct _DspComBlk {
    short cpuMsg;    // Command from CPU to DSP
    short cpuArg;    // Argument for command
    short dspMsg;    // Response from DSP to CPU
    short dspArg;    // Response argument
} DspComBlk;
```

Commands sent to DSP:
- `CMD_K_AMSP` — Load amplitude setpoint (Q13 format)
- `CMD_K_PHSG` — Load phase gain (Q14 format)
- `CMD_K_READY` — DSP reports ready after boot

**Note**: `lce` (Lead Compensation Enable) uses **inverted logic** — the hardware bit `RFP_M_LEADCOMP` is set when `lce=0` (compensation OFF). This is a historical quirk that caused confusion and is documented in the code comment by LAZMO (2004).

### 5.2 I/Q Amplitude — `devP2RfIqa.c` (2,277 lines)

**VXI Slots**: 7, 9, 11 (three instances for SPEAR3)

The IQA module measures I (in-phase) and Q (quadrature) signals from the RF system, providing amplitude and phase measurements for each of 8 channels.

#### Background Scan Task

The IQA uses a dedicated background task (`IqaScanTask`, priority 46, stack 3072 bytes) that runs continuously:

1. **Wait** for scan semaphore (given by EPICS scan at configurable rate, typically ~5 Hz)
2. **Read** I/Q data from dual-port memory for all 8 channels
3. **Verify consistency**: Each I and Q channel is read at least twice; two consecutive reads must return the same value to ensure I and Q belong together
4. **Read** amplitude data, convert to physical units
5. **Signal** data-ready semaphore to unblock EPICS clients

**Key design point**: The minimum hardware data-ready rate is ~50 Hz, but EPICS can only process ~10 Hz per field. The background task decouples the hardware rate from the software rate.

#### DDF Filter Loading

The IQA uses Harris HSP43220 DDF (Digital Decimation Filter) chips for signal conditioning. Filter coefficients are loaded from files generated by Harris DECI-MATE software. The loading sequence is:
1. Disable FIR (`H1` register with FDIS + HBYP bits)
2. Reset F register
3. Wait 2 FIR clock cycles (~16 ms at 60 Hz)
4. Reload H1 register (re-enable FIR)
5. Load H2 register (halfband filter)
6. Load F register (FIR filter parameters)
7. Load FC register (coefficient data, multiple words)

**Upgrade mapping**: LLRF9 does not use external DDF chips — digital filtering is implemented in the FPGA. No migration needed.

### 5.3 Arc Interlock Module — `devP2RfAim.c` (2,061 lines)

**VXI Slot**: 12

The AIM monitors arc detection signals and provides fast interlock shutdown. Key functions:
- Analog threshold monitoring for arc detection
- Automatic contactor de-energization on arc detect
- Event file generation (timestamped fault data)
- Fault status reporting back to station state machine

**Upgrade mapping**: Replaced by Microstep-MIS optical arc detection system (6 sensors) integrated through the Interface Chassis. Fundamentally different technology — no code migration.

### 5.4 Clock Module — `devP2RfClk.c` (979 lines)

**VXI Slot**: 2

Distributes RF reference clocks (10 MHz, 120 MHz) to all VXI modules in the crate. Manages clock multiplier synchronization and phase-locked loop status.

**Upgrade mapping**: Eliminated — LLRF9 has its own internal clock system with external reference input.

### 5.5 PEP-II Only Modules

Three modules in the codebase were designed for PEP-II and **were never installed in SPEAR3**:

- **`devP2RfGvf.c` (2,325 lines)** — Gap Voltage Feed-Forward. Used for PEP-II multi-bunch stabilization. Slot 3 is empty in SPEAR3.
- **`devP2RfCf2.c` (2,847 lines)** — Comb Filter v2. PEP-II multi-bunch comb filter for B-factory operation. Slot 5 in SPEAR3 is MPS Shutoff, not CF2.
- **`devP2RfCfm.c` (1,514 lines)** — Comb Filter v1. Original comb filter design.

These modules total 6,686 lines that are **dead code** in the SPEAR3 context. They can be safely ignored for the upgrade.

---


## 6. Custom EPICS Record Types

Seven custom record types were created for the PEP-II RF modules. Each has a record definition (`.dbd` file) and a C implementation (`*Record.c`):

| Record Type | DBD File | C File | Lines | Used in SPEAR3? |
|-------------|----------|--------|-------|-----------------|
| `p2RfRfp` | `p2RfRfpRecord.dbd` | `p2RfRfpRecord.c` (296 lines) | ~100+ fields | **Yes** |
| `p2RfIqa` | `p2RfIqaRecord.dbd` | `p2RfIqaRecord.c` (301 lines) | ~80+ fields | **Yes** |
| `p2RfAim` | `p2RfAimRecord.dbd` | `p2RfAimRecord.c` (300 lines) | ~60+ fields | **Yes** |
| `p2RfClk` | `p2RfClkRecord.dbd` | `p2RfClkRecord.c` (299 lines) | ~50+ fields | **Yes** |
| `p2RfGvf` | `p2RfGvfRecord.dbd` | `p2RfGvfRecord.c` (307 lines) | ~70+ fields | No (PEP-II) |
| `p2RfCf2` | `p2RfCf2Record.dbd` | `p2RfCf2Record.c` (366 lines) | ~80+ fields | No (PEP-II) |
| `p2RfCfm` | `p2RfCfmRecord.dbd` | `p2RfCfmRecord.c` (334 lines) | ~60+ fields | No (PEP-II) |

These record types will not exist in the upgraded system. The LLRF9 IOC will use standard EPICS record types (ai, ao, bi, bo, mbbi, mbbo, waveform, etc.) to represent equivalent functionality. The custom record field names define the PV namespace that operators and client software depend on.

**Upgrade note**: The field names in these records (e.g., `rfoo`, `rle`, `ice`, `lce`, `dle`, `amsp`, `phsg`) are used throughout the SNL state machines and database records. These names must be mapped to equivalent LLRF9 PVs.

---

## 7. SNL State Machines

### 7.1 Master Station State Machine — `rf_states.st` (2,227 lines)

**Authors**: Robert C. Sass (March 1997), Stephanie Allison, Mike Laznovsky
**Priority**: This is the **single most important behavioral document** in the codebase.

#### State Diagram

```
                    ┌───────────────┐
                    │     s_init    │
                    └───────┬───────┘
                            │ (always)
                    ┌───────▼───────┐
        ┌──────────►│    s_go_off   │◄──────────┐
        │           └───────┬───────┘           │
        │                   │                   │
        │           ┌───────▼───────┐           │
        │      ┌────┤     s_off     ├────┐      │
        │      │    └───────────────┘    │      │
        │      │         │    │    │     │      │
        │    PARK      TUNE  ON_FM  ON_CW      │
        │      │         │    │    │     │      │
        │      ▼         ▼    ▼    ▼     │      │
        │  s_go_park  s_go_tune  s_go_on_fm  s_go_on_cw
        │      │         │    │    │     │      │
        │      ▼         ▼    ▼    ▼     │      │
        │   s_park    s_tune  s_on_fm s_on_cw   │
        │      │         │    │    │     │      │
        │      │    ┌────┘    │    └─────┘      │
        │      │    │         │                 │
        └──────┴────┴─────────┴─────────────────┘
                    (fault → s_go_off)
```

#### Legal State Transitions

| From \ To | OFF | PARK | TUNE | ON_FM | ON_CW |
|-----------|-----|------|------|-------|-------|
| **OFF** | — | Y | Y | Y | Y |
| **PARK** | Y | — | — | — | — |
| **TUNE** | Y | — | — | — | Y |
| **ON_FM** | Y | — | Y | — | — |
| **ON_CW** | Y | — | Y | — | — |

**Note**: PARK cannot go directly to TUNE, ON_FM, or ON_CW. This forces the operator to go through OFF first, providing a deliberate safety step.

#### Entry Sequences (Critical for Upgrade)

**s_go_off** (entering OFF state):
1. Set station state readback to `STATION_OFF`
2. Turn off RF output (`rfoo = 0`)
3. Turn off integral compensation (`ice = 0`)
4. Disable ripple loop
5. Disable direct loop and comb loop
6. Zero requested HVPS voltage
7. Reset fault flags
8. Process RFP module record (apply changes)

**s_go_tune** (entering TUNE state):
1. Reset tuner position (3-second delay for settling)
2. Initialize stepper motors
3. Set up drive power DACs for tune mode
4. Enable RFP tune mode operation (`tnop = 1`)
5. Process RFP module record

**s_go_on_cw** (entering ON_CW state):
1. If direct loop enabled AND fast turnon enabled:
   - Turn on direct loop first
   - Apply variable delay for settling
2. Load ripple loop coefficients
3. Reset ripple DC coefficient before RF on
4. Enable integral and lead compensation
5. Enable RF output
6. Start direct loop (with timing delay if enabled)
7. Load DSP ready check

#### Fault Handling

The state machine monitors module severity PVs:
- `{STN}:STN:RFP:MODU.SEVR` — RFP module alarm severity
- `{STN}:STN:IQA:MODU.SEVR` — IQA module alarm severity  
- `{STN}:STN:AIM:MODU.SEVR` — AIM module alarm severity

When any module goes to `INVALID_ALARM`, the state machine transitions to OFF state. It also supports automatic reset/restart logic with configurable retry count.

**Fault file dumps**: On fault detection, the state machine writes diagnostic data files to `/dat/` for post-mortem analysis (signal RAMs, cavity RAMs, DSP memory).

### 7.2 HVPS Voltage Regulation — `rf_hvps_loop.st` (343 lines)

**Author**: Mike Zelazny (February 1997), modified by S. Allison, R. Sass

This loop runs at ~2 Hz (0.5 second cycle) and adjusts the klystron HVPS voltage.

#### States

| State | Condition | Action |
|-------|-----------|--------|
| `init` | Boot | Set voltage to current readback; set status to STN_OFF |
| `off` | Station OFF or PARK | No voltage adjustment |
| `proc` | Station ON + loop_ctrl=PROC | **Cavity processing mode**: raise/lower voltage based on klystron power, vacuum status, gap voltage |
| `on` | Station ON_CW + loop_ctrl!=PROC | **Normal regulation**: maintain constant klystron drive power (direct loop OFF) or gap voltage (direct loop ON) |

#### Regulation Algorithm (ON state)

```
if (direct_loop == OFF):
    error = drive_power_error
    delta = delta_on_voltage (from drive power error PV)
else:
    error = gap_voltage_error  
    delta = delta_tune_voltage (from gap voltage error PV)

if (error severity is OK):
    requested_voltage += delta
    clamp(requested_voltage, min_voltage, max_voltage)
    
tolerance_check:
    if |requested - readback| > allowed_diff:
        status = OUT_OF_TOLERANCE (for N cycles)
```

#### Processing Algorithm (PROC state)

```
every 0.5 seconds:
    if (klystron_forward_power > max_allowed):
        requested_voltage -= delta_proc_voltage_down
    elif (vacuum OK) AND (gap_voltage OK):
        requested_voltage += delta_proc_voltage_up
    
    clamp(requested_voltage, min_voltage, max_voltage)
```

#### Key PVs (from `rf_hvps_loop_pvs.h`)

| PV Pattern | Type | Description |
|------------|------|-------------|
| `{STN}:STN:STATE:RBCK` | int | Station state (monitored) |
| `{STN}:HVPS:LOOP:CTRL` | int | Loop control mode (monitored) |
| `{STN}:HVPS:VOLT:CTRL` | float | **Requested voltage (output)** |
| `{STN}:HVPS:VOLT` | float | Readback voltage (monitored) |
| `{STN}:KLYSOUTFRWD:POWER` | float | Klystron forward power (monitored) |
| `{STN}:KLYSOUTFRWD:POWER:MAX` | float | Max allowed power (monitored) |
| `{STN}:CAVVACM:SUMY:SEVR.SEVR` | int | Cavity vacuum summary severity |
| `{STN}:STN:VOLT.SEVR` | int | Gap voltage severity |
| `{STN}:KLYSDRIVFRWD:POWER:ERR.STAT` | int | Drive power error status |
| `{STN}:STN:VOLT:ERR.STAT` | int | Gap voltage error status |
| `{STN}:HVPS:LOOP:VOLTDIFF` | float | Allowed voltage tolerance |
| `{STN}:HVPS:LOOP:VOLTUP` | float | Processing step up size |
| `{STN}:HVPS:LOOP:VOLTDOWN` | float | Processing step down size |

### 7.3 Cavity Tuner Loop — `rf_tuner_loop.st` (555 lines)

**Author**: Stephanie Allison (October 1996)

This is a **reentrant** program — one instance per cavity (4 instances for SPEAR3, macro `CAV=1..4`). It adjusts the cavity tuner stepper motor position based on cavity resonant frequency (measured via phase).

#### States

| State | Action |
|-------|--------|
| `loop_init` | Initialize, clear event flags |
| `loop_unknown` | Determine previous state (on/off) |
| `loop_reset` | Move tuner to home position (park or on), retry up to LOOP_RESET_COUNT times with LOOP_RESET_DELAY settling |
| `loop_off` | Station OFF/PARK — no tuning |
| `loop_on` | Active tuning — read phase, calculate error, move stepper |

#### Phase Feedback Algorithm

```
phase_error = measured_phase - phase_offset
if |phase_error| > dead_band:
    step_count = proportional_gain * phase_error
    if (step_count > 0):
        move_tuner_up(step_count)
    else:
        move_tuner_down(|step_count|)
```

The tuner uses a potentiometer for absolute position feedback and the stepper motor encoder for incremental positioning.

**Upgrade mapping**: Galil DMC-4143 replaces AB 1746-HSTP1. Phase feedback input now comes from LLRF9 I/Q data. The feedback loop may be implemented in Galil firmware, in the LLRF9 IOC, or in a Python coordinator.

### 7.4 DAC Loop — `rf_dac_loop.st` (290 lines)

**Author**: Stephanie Allison (May 1997)

This loop controlled drive power and gap voltage by adjusting DAC values on the RFP module and optionally the GVF module. It operated at ~10 Hz.

**Upgrade disposition**: **FULLY ELIMINATED** — LLRF9 has an internal vector modulator that replaces all external DAC control.

### 7.5 Calibration — `rf_calib.st` (3,345 lines)

**Author**: R. Claus, SLAC/PEP-II LLRF Group

Operator-invoked calibration sequences:
- DAC offset nulling
- Cavity modulator response measurement
- Ripple loop calibration
- File-based coefficient loading

**Upgrade disposition**: **PARTIAL SPEC-EXTRACT** — Some calibration procedures may need LLRF9 equivalents. The LLRF9 may automate some calibrations that were manual in the legacy system.

### 7.6 Message Logging — `rf_msgs.st` (352 lines)

Monitors TAXI (Time-stamped Array Exchange Interface) errors from legacy RF modules and logs status messages.

**Upgrade disposition**: **ELIMINATED** — LLRF9 uses standard EPICS communication. Error logging handled by EPICS IOC alarming.

---


## 8. DSP Firmware

### 8.1 RFP Ripple Loop — `rfpDsp/` (7,919 lines)

**Authors**: R. Claus & P. Corredoura (October 1996); W. Ross modifications for SPEAR3 (2006)
**Processor**: Motorola DSP1610 (16-bit fixed-point)

The SPEAR3-specific version is `sp3ripple.s` (1,103 lines), modified from the PEP-II `ripple.s` by W. Ross in 2006 to accommodate the higher sampling frequency of SPEAR3.

#### Algorithm Overview

The ripple rejection algorithm cancels AC power line harmonics (60 Hz and multiples) from the klystron drive signal. It operates at approximately 23 kHz sampling rate.

**Key components**:
1. **Phase estimation**: Uses double-precision multiplication with 26 fast harmonics and 4 slow harmonics
2. **Amplitude estimation**: Removed in sp3ripple.s to gain cycle time for phase estimation
3. **Harmonic rejection**: Adaptive filtering with integrator + gain per harmonic
4. **DAC output**: 8 octal DAC channels for vector modulator control

**Data formats**:
- I/Q signals: 16-bit 2's complement
- Phase: Q13 format (range [-π to π])
- Amplitude setpoint: Q13 format
- Phase gain: Q14 format
- Harmonic coefficients: Q11 format (accumulated, range [-16.0 to +16.0])

**Key constants** (empirically tuned for SPEAR3):
- 26 fast harmonic coefficients (from coefficient file)
- 4 slow harmonic coefficients (effective ~3 kHz rate)
- DAC offset values (calibrated per-klystron)
- Phase gain value (tuned per-cavity)

#### Key DSP Files

| File | Lines | Description |
|------|-------|-------------|
| `sp3ripple.s` | 1,103 | SPEAR3 ripple rejection — main algorithm |
| `ripple.s` | 1,144 | Original PEP-II ripple rejection |
| `ripple_phaseoff.s` | 1,157 | Phase-offset variant |
| `lusqrt.s` | 1,064 | Fast unsigned long square root |
| `sqlu.s` | 1,024 | Unsigned square root |
| `loadDacs.s` | 183 | Load 8 octal DAC channels |
| `constDacs.s` | 153 | Load constant DAC values |
| `zeroDacs.s` | 151 | Zero all DAC channels |
| `rampDacs.s` | 188 | Ramp DAC values |
| `comBlk.s` | 147 | CPU-DSP communication block |
| `regInit.s` | 98 | Register initialization |
| `vecTbl.s` | 113 | Interrupt vector table |
| `dspSos.s` | 135 | Second-order section filter |

**Upgrade disposition**: **100% eliminated** as code. The LLRF9 FPGA has built-in ripple rejection implemented by Dmitry Teytelman. The DSP code serves as a reference for understanding what the legacy algorithms did and what performance characteristics to expect.

### 8.2 GVF DSP — `gvfDsp/` (4,619 lines)

PEP-II Gap Voltage Feed-Forward DSP code. **Not used in SPEAR3.** Dead code.

### 8.3 Generic Math — `genDsp/` (1,556 lines)

DSP1610 assembly implementations of `atan`, `sin`, `cos`, `sqrt2`. These are standard math functions optimized for the 16-bit fixed-point DSP. No migration needed — LLRF9 FPGA has hardware or lookup-table implementations.

### 8.4 Observation — `obsDsp/` (2,031 lines)

Data recording and analysis routines: equalization, adaptive filtering, amplitude-to-IQ conversion, circular buffer loading, register save/restore. Used for diagnostics only.

**Upgrade disposition**: Replaced by LLRF9 waveform recording and the dedicated Waveform Buffer System.

---

## 9. Pure Math Subroutines

### 9.1 I/Q Processing — `subIQ.c` (965 lines)

**Author**: Stephanie Allison (October 1996), R. Claus additions

This file contains **pure math functions** called by EPICS subroutine records. These are the most reusable code in the entire codebase — they have no hardware dependencies.

| Function | Description | Reusable? |
|----------|-------------|-----------|
| `subIQphase` | Phase = atan2(Q, I) with dead-zone | **Yes** |
| `subIQampl` | Amplitude from dB reference | **Yes** |
| `subIQampl2conv` | Reference amplitude to conversion factor | **Yes** |
| `subIQamplStn` | Total station amplitude (sum of 4 cavities) | **Yes** |
| `subIQamplCplg` | Cavity coupling factor from amplitudes | **Yes** |
| `subIQampl2loss` | Conversion loss from amplitude | **Yes** |
| `subIQampl2iq` | Amplitude + phase → I and Q (inverse conversion) | **Yes** |
| `subIQpower` | Power from I/Q (I² + Q²) or amplitude | **Yes** |
| `subIQpowerNet` | Net power (forward - reflected) | **Yes** |
| `subIQpowerEff` | Klystron efficiency or cavity strength | **Yes** |
| `subIQpower2gain` | Gain/loss from power ratio | **Yes** |
| `subIQpower2ampl` | Power to amplitude conversion | **Yes** |
| `subIQphaseOffs` | Total phase offset (sum of offsets) | **Yes** |
| `subIQphaseErr` | Load angle phase error | **Yes** |
| `subIQphase2posn` | Phase error → delta stepper position | **Yes** |
| `subIQdac` | Calculate II/IQ/QI/QQ DAC matrix values | Partial |
| `subIQcounts` | Error to delta counts conversion | Partial |
| `subIQcorrected` | Directivity correction | **Yes** |
| `subIQscaled` | Calculate scaled I and Q | **Yes** |
| `subIQget` | Get fresh I/Q from IQA record (with semaphore) | No (VXI-specific) |

**Upgrade recommendation**: Port these functions to Python or keep as C in the LLRF9 IOC. The algorithms are straightforward trigonometry and linear algebra. The key value is in the exact formulas and unit conventions.

### 9.2 System Functions — `subSys.c` (606 lines)

| Function | Description | Reusable? |
|----------|-------------|-----------|
| `subSysFreqOff` | Cavity frequency offset from phase | **Yes** |
| `subSysFreqOAvg` | Average cavity frequency offset | **Yes** |
| `subSysFreqErr` | Cavity park frequency error | **Yes** |
| `subSysPhaseTot` | Direct loop total phase calculation | **Yes** |
| `subSysPhaseCmb` | Comb loop phase calculation | No (PEP-II) |
| `subSysPhaseStn` | Station phase calculation | **Yes** |
| `subSysDCcoeff` | Ripple loop DC coefficient calculation | **Yes** |
| `subSysDrivSel` | Drive power setpoint selection | **Yes** |
| `subSysLog` | Value from logarithm | **Yes** |
| `subSysABreset` | Allen-Bradley reset | No (eliminated) |

---

## 10. Allen-Bradley Communication

### 10.1 Serial Driver — `drvAb.c` (2,039 lines)

**Authors**: Bob Dalesio (1988), major revision by Dalesio and Kraimer (1995)

This is the VME scanner card driver for Allen-Bradley Remote Serial I/O. It communicates with PLC-5, SLC-500, and I/O rack modules over a serial link through a VME-based scanner card.

**Key architecture**:
- Dual-ported memory interface to VME scanner card
- Base address: `0xC00000` (configurable)
- IRQ level: 4 (configurable)
- Up to 8 physical adapters per link, 16 cards per adapter
- Supports block transfer (BT) for large data transfers
- Auto-configuration or manual scan list
- Background scan task + interrupt-driven completion

**Configuration** (from `config.ab`):
```
1 0 Full    # Adapter 1, Group 0, Full rack
2 0 3/4     # Adapter 2, Group 0, 3/4 rack  
3 0 1/4     # Adapter 3, Group 0, 1/4 rack
```

### 10.2 I/O Module Drivers

| Module | File | Lines | Function |
|--------|------|-------|----------|
| AB Binary I/O | `devABBINARY.c` | 618 | Read/write digital I/O |
| AB Status | `devABStatus.c` | 102 | Read adapter/link status |
| AB DCM (Data Table) | `1771DCMSrc/` | 2,649 | PLC data table read/write (multiple record types) |
| AB 1771-IFE | `1771IFESrc/` | 717 | Analog input (4-20mA, thermocouple) |
| AB 1771-IX | `1771IXSrc/` | 796 | Thermocouple input |
| AB 1771-N Series | `1771NSeriesSrc/` | 1,418 | Analog I/O (high-precision) |
| AB 1791 Block I/O | `1791BlockIOSrc/` | 578 | Block I/O interface |
| SLC-500 DCM | `SLCDCMSrc/` | 563 | SLC-500 processor data access |
| GP Interface | `gpIfaceSrc/` | 393 | General purpose analog I/O |

### 10.3 Stepper Motor Driver — `devSmAB1746HSTP1.c` (1,673 lines)

EPICS device support for the Allen-Bradley 1746-HSTP1 stepper motor module. This module controlled the cavity tuner stepper motors via the SLC-500 backplane.

**Upgrade**: Replaced by Galil DMC-4143 motor controller (already commissioned August 2025).

**All Allen-Bradley code is 100% eliminated** — the new system uses Ethernet/IP (for PLCs) and Galil Ethernet protocol (for motors) instead of AB serial I/O.

---

## 11. Stepper Motor Drivers — `stepper/` (2,841 lines)

| File | Lines | Description |
|------|-------|-------------|
| `steppermotorRecord.c` | 959 | Custom stepper motor EPICS record type |
| `drvCompuSm.c` | 872 | Compumotor 1830 serial protocol driver |
| `drvOms.c` | 705 | OMS 6-axis VME stepper motor driver |
| `devSmCompumotor1830.c` | 82 | Compumotor device support |
| `devSmOms6Axis.c` | 83 | OMS device support |
| `steppermotor.h` | 66 | Record header |
| `drvOms.h` | 74 | OMS driver header |

These drivers supported multiple stepper motor controller types: Compumotor 1830 (serial), OMS VME boards, and AB 1746-HSTP1 (in the AB driver section). All are **obsolete** — replaced by the Galil DMC-4143 with EPICS motor record support.

---

## 12. EPICS VXI Subsystem — `epvxi/` (7,846 lines)

The VXI subsystem provides resource management and low-level hardware access for VXI modules:

- **`drvEpvxi.c` (4,622 lines)**: VXI resource manager — discovers modules by scanning logical addresses, manages A16/A24/A32 address space allocation, provides module lookup by manufacturer/model/slot
- **`drvEpvxiMsg.c` (1,529 lines)**: VXI message-based communication protocol
- **`drvHp1404a.c` (393 lines)**: Driver for HP 1404A VXI oscilloscope (used for diagnostics)
- **`epvxi.h` (532 lines)**: VXI bus constants, CSR register definitions, address space macros

**Upgrade disposition**: 100% eliminated. The VXI bus standard is no longer used.

---

## 13. VxWorks Base Infrastructure — `rfApp/src/base/` (12,187 lines)

~60 files providing:
- VxWorks BSP (Board Support Package) adaptations
- MMU (Memory Management Unit) configuration
- Boot sequence support
- DSP code loading library (`dwnLib.h`, `dld.c`, `dlt.c`)
- Bus utilities (`bus.c`, `busMap.c`, `mapAdx.c`)
- VXI interrupt service infrastructure (`vxiBaseIsr.c`)
- Linked list library (`lstLib.c`)
- Memory test utilities (`memTest.c`, `tstMem.c`)
- State display utilities (`stateShow.c`)
- Time utilities (`time.c`)
- Various hardware-specific headers

**Upgrade disposition**: 100% eliminated. Linux replaces VxWorks; standard EPICS7 IOC replaces the custom infrastructure.

---

## 14. EPICS Databases

### 14.1 Database Organization

The 76 database files in `rfApp/Db/` follow a hierarchical structure:

**Module-level databases** (one per VXI module type):
- `rfp.db`, `rfp_dacs.db` — RFP module PVs
- `iqa.db`, `rf_iqa.db`, `rf_iqa_module.db`, `rf_iqa_scale.db` — IQA module PVs
- `aim.db` — AIM module PVs
- `clk.db` — Clock module PVs
- `gvf.db`, `cf2.db`, `cfm.db` — PEP-II module PVs (not used in SPEAR3)

**Station-level databases**:
- `rf_stn.db` — Station state, controls, and status
- `rf_stn_cav.db` — Per-cavity station records
- `rf_hvps.db` — HVPS voltage, current, status
- `rf_klys.db` — Klystron parameters

**Signal processing databases**:
- `rf_analog.db` — Analog signal conditioning records
- `rf_beam*.db` — Beam-related calculations
- `rf_fbck.db` — Feedback parameters
- `iqCvt.db`, `iqGet.db` — I/Q conversion and acquisition
- `rf_temp.db` — Temperature monitoring

**Interlock databases**:
- `rf_interlock.db`, `rf_interlock_arc.db`, `rf_interlock_vxi.db` — Interlock status and configuration

**Summary/alarm databases**:
- `rf_sumy_*.db` — Summary alarm records for each subsystem

**Infrastructure**:
- `ab_adapter.db`, `ab_adapter_card.db`, `ab_dcm_table.db` — Allen-Bradley records
- `rf_ab_module.db` — AB module records
- `rf_digital_plc.db`, `rf_digital_modu.db`, `rf_digital_hvps.db` — Digital I/O records

### 14.2 Template/Substitution Pattern

The databases use EPICS substitution files to instantiate templates for SPEAR3:
- `rf_stn_4CV.substitutions` — 4-cavity station configuration
- `rf_iqa_4CV.substitutions` — 4-cavity IQA configuration
- `rf_analog_4CV.substitutions` — 4-cavity analog signals
- `rf_vxi_modules_4CV.substitutions` — VXI module configuration
- `rf_beam_spear.substitutions` — SPEAR3-specific beam records

The primary macro is `STN=SRF1` (SPEAR RF Station 1), with per-cavity macros `CAV=1..4`.

---

## 15. IOC Boot Configuration

The IOC boots on a KSC V152 CPU board (Motorola PPC604) running VxWorks. The boot sequence in `st.cmd`:

1. Load EPICS binary (`bin/vxWorks-ppc604_long/rf.munch`)
2. Configure error log queue size (5000 bytes)
3. Set environment variables for station macros (`STN=SRF1`, tuner loop macros)
4. Load EPICS database (`dbd/rf.dbd` + `db/srf1.db`)
5. Restore saved setpoints from files
6. Configure Allen-Bradley scanner (1 link, 3 adapters)
7. Configure VXI bus (LA base 0x01, 13 devices)
8. Start EPICS (`iocInit()`)
9. Start all 6 SNL programs (state machine, 4 tuner loops, HVPS loop, DAC loop, calibration, messages)

---

## 16. Diagnostic Utilities — `rfApp/src/diag/` (2,873 lines)

| File | Lines | Description |
|------|-------|-------------|
| `rf_vxi_diag.c` | 2,328 | VXI diagnostic commands (register dump, memory display, module status) |
| `rf_vxi_diag.h` | 141 | Diagnostic function prototypes |
| `rf_rfpDiags.c` | 120 | RFP-specific diagnostics (DSP status, DAC readback) |
| `rf_ripTest.c` | 284 | Ripple rejection test utility |

These VxWorks shell commands were used for debugging the VXI modules. All are eliminated with the VXI hardware.

---

## 17. Upgrade Migration Assessment

### 17.1 What Must Be Preserved

| What | Where | How to Preserve |
|------|-------|----------------|
| **Station state machine logic** | `rf_states.st` | Re-implement in Python coordinator or EPICS IOC |
| **HVPS regulation algorithm** | `rf_hvps_loop.st` | Re-implement in CompactLogix PLC (B118) |
| **Tuner feedback algorithm** | `rf_tuner_loop.st` | Re-implement for Galil DMC-4143 |
| **I/Q math functions** | `subIQ.c`, `subSys.c` | Port to Python or keep as C subroutine records |
| **PV naming conventions** | `rfApp/Db/*.db` | Map to LLRF9 IOC PV names |
| **State constants** | `rf_station_state.h` | Reuse directly (OFF=0, PARK=1, TUNE=2, ON_FM=3, ON_CW=4) |
| **Operator interface contract** | All `.db` + `.substitutions` | Provide equivalent PVs from LLRF9 IOC |

### 17.2 What Is Eliminated

| What | Lines | Replacement |
|------|-------|-------------|
| VXI bus driver + epvxi | ~10,500 | Ethernet/IP |
| VxWorks base infrastructure | ~12,200 | Linux + EPICS7 |
| DSP firmware | ~16,100 | LLRF9 FPGA (Dmitry's algorithms) |
| Allen-Bradley serial | ~12,700 | Ethernet/IP + Galil |
| Stepper motor drivers | ~4,500 | Galil DMC-4143 |
| Custom record types | ~2,200 | Standard EPICS records |
| DAC loop (`rf_dac_loop.st`) | ~290 | LLRF9 internal modulator |
| Message logging (`rf_msgs.st`) | ~352 | Standard EPICS alarming |
| PEP-II modules (GVF, CF2, CFM) | ~6,700 | Not applicable |
| **Total eliminated** | **~65,540** | |

### 17.3 Key Constants and Magic Numbers

These empirically-tuned values from the legacy system should be documented and preserved for reference:

| Constant | Source | Value/Type | Notes |
|----------|--------|------------|-------|
| IQA scan rate | `devP2RfIqa.c` | 5 Hz (`IQA_K_IQRDRT`) | Minimum client data rate |
| HVPS loop delay | `rf_hvps_loop_pvs.h` | Configurable (PV) | Fast turnon accommodation |
| Tuner reset count | `rf_tuner_loop_defs.h` | `LOOP_RESET_COUNT` | Max retries before failure |
| Tuner reset delay | `rf_tuner_loop_defs.h` | `LOOP_RESET_DELAY` | Settling time |
| Module reset timeout | `drvP2RfVxi.c` | 1 second | `P2RF_K_RESETTMO` |
| RFP DSP Q13 scale | `devP2RfRfp.c` | `1 << 13 = 8192` | Amplitude setpoint format |
| RFP DSP Q14 scale | `devP2RfRfp.c` | `1 << 14 = 16384` | Phase gain format |
| Octal DAC offset | `devP2RfRfp.c` | `RFP_K_OCTDACOS` | Hardware-specific offset |
| DSP ripple harmonics | `sp3ripple.s` | 26 fast + 4 slow | Optimized for SPEAR3 |

### 17.4 Open Questions for Upgrade Team

1. **Which external systems consume SPEAR3 RF PVs?** The archiver, machine physics applications, and SPEAR MPS may depend on specific PV names. A PV compatibility layer may be needed.

2. **Are any DSP tuning constants empirically derived?** The ripple rejection coefficients in the coefficient files may have been hand-tuned during commissioning. The LLRF9 may need similar tuning.

3. **What is the actual HVPS loop rate in the upgrade?** The legacy runs at ~2 Hz (500 ms cycle). The new CompactLogix PLC may run faster (~100 ms). Does this change the regulation algorithm behavior?

4. **How are calibration procedures affected?** The `rf_calib.st` sequences were operator-invoked. Does the LLRF9 automate any of these?

5. **What is the interlock response time requirement?** The legacy AIM provides sub-microsecond arc detection. The new Microstep-MIS optical system may have different latency characteristics.

---

## Appendix A: State Transition Tables

### A.1 Station States

| Code | Name | Description |
|------|------|-------------|
| 0 | `STATION_OFF` | All systems powered down, no RF |
| 1 | `STATION_PARK` | Systems powered, no RF, ready for transition |
| 2 | `STATION_TUNE` | Cavity tuning active, low-power RF drive |
| 3 | `STATION_ON_FM` | Frequency-modulated operation (not used in SPEAR3) |
| 4 | `STATION_ON_CW` | Continuous-wave operation (normal SPEAR3 mode) |

### A.2 HVPS Loop States

| Code | Name | Description |
|------|------|-------------|
| `HVPS_LOOP_STATE_OFF` | Off | No voltage regulation |
| `HVPS_LOOP_STATE_ON` | On | Normal regulation active |
| `HVPS_LOOP_CONTROL_PROC` | Processing | Cavity conditioning mode |

### A.3 Tuner Loop States

| Code | Name | Description |
|------|------|-------------|
| `LOOP_OFF` | Off | No tuning |
| `LOOP_ON` | On | Active phase feedback |
| Various status codes | Status | Diagnostic status (running, fault, reset, etc.) |

---

## Appendix B: Key PV Namespace

### B.1 Station Control PVs (from `rf_states.st`)

| PV | Type | Direction | Description |
|----|------|-----------|-------------|
| `{STN}:STN:STATE:CTRL` | int | Input (operator) | Desired station state |
| `{STN}:STN:STATE:RBCK` | int | Output | Current station state |
| `{STN}:STN:RFP:MODU.*` | record | Monitor | RFP module fields |
| `{STN}:STN:IQA:MODU.*` | record | Monitor | IQA module fields |
| `{STN}:STN:AIM:MODU.*` | record | Monitor | AIM module fields |

### B.2 HVPS PVs (from `rf_hvps_loop_pvs.h`)

| PV | Type | Description |
|----|------|-------------|
| `{STN}:HVPS:VOLT:CTRL` | float | Requested voltage setpoint |
| `{STN}:HVPS:VOLT` | float | Voltage readback |
| `{STN}:HVPS:LOOP:CTRL` | int | Loop control mode |
| `{STN}:HVPS:LOOP:STATUS` | int | Loop status code |
| `{STN}:HVPS:LOOP:STRING` | string | Status message |
| `{STN}:HVPS:LOOP:STATE` | int | Loop state |
| `{STN}:HVPS:LOOP:DELAY` | int | Loop start delay (ticks) |
| `{STN}:HVPS:LOOP:VOLTDIFF` | float | Voltage tolerance |
| `{STN}:HVPS:LOOP:VOLTUP` | float | Processing step up |
| `{STN}:HVPS:LOOP:VOLTDOWN` | float | Processing step down |
| `{STN}:HVPS:VOLT:MIN` | float | Minimum voltage |
| `{STN}:HVPS:VOLT:CTRL.DRVH` | float | Maximum voltage |

### B.3 Tuner PVs (from `rf_tuner_loop_pvs.h`)

Each tuner has PVs with cavity-specific macros `{CAV}`:
| PV Pattern | Type | Description |
|------------|------|-------------|
| `{STN}:C{CAV}:TUNER:LOOP:CTRL` | int | Loop control |
| `{STN}:C{CAV}:TUNER:LOOP:STATUS` | int | Loop status |
| `{STN}:C{CAV}:TUNER:POSN` | float | Position from potentiometer |
| `{STN}:C{CAV}:TUNER:SM:POSN` | float | Position from stepper motor |
| `{STN}:C{CAV}:TUNER:PHASE` | float | Measured phase |
| `{STN}:C{CAV}:TUNER:PHASE:OFFSET` | float | Phase setpoint |

---

## Appendix C: DSP Algorithm Pseudocode

### C.1 Ripple Rejection Algorithm (from `sp3ripple.s`)

```
INITIALIZATION:
    Load 26 fast harmonic coefficients from coefficient file
    Load 4 slow harmonic coefficients
    Initialize DAC offsets from calibration data
    Set amplitude setpoint (Q13)
    Set phase gain (Q14)

MAIN LOOP (runs at ~23 kHz):
    1. READ I/Q DATA
       Read Iref, Qref from reference channel
       Read Iklys, Qklys from klystron channel
    
    2. COMPUTE PHASE
       phase_ref  = atan2(Qref, Iref)    [Q13 output]
       phase_klys = atan2(Qklys, Iklys)  [Q13 output]
       phase_error = phase_ref - phase_klys
    
    3. FAST HARMONIC REJECTION (26 harmonics)
       for h = 0 to 25:
           state[h] = coeff[h] * state[h] + phase_error  [Q11 accumulator]
           correction += state[h]
    
    4. SLOW HARMONIC REJECTION (1 of 4 per cycle, ~3 kHz effective)
       slow_index = cycle_count % 4
       slow_state[slow_index] = slow_coeff[slow_index] * slow_state[slow_index] + phase_error
       correction += slow_state[slow_index]
    
    5. COMPUTE DAC OUTPUT
       For each DAC channel (II, IQ, QI, QQ):
           dac_value = correction * gain_matrix[channel] + dac_offset[channel]
           clamp(dac_value, DAC_MIN, DAC_MAX)
           output_to_DAC(channel, dac_value)
    
    6. CHECK FOR CPU MESSAGES
       if (message_pending):
           process_command(cpuMsg, cpuArg)
           // CMD_K_AMSP: update amplitude setpoint
           // CMD_K_PHSG: update phase gain
```

### C.2 HVPS Regulation Algorithm (from `rf_hvps_loop.st`)

```
EVERY 0.5 SECONDS:
    if station_state in {OFF, PARK}:
        goto OFF state (no regulation)
    
    if hvps_loop_ctrl == PROC:
        // PROCESSING MODE
        if klystron_forward_power > max_klystron_forward_power:
            voltage -= delta_proc_voltage_down
        elif cavity_vacuum_ok AND gap_voltage_ok:
            voltage += delta_proc_voltage_up
        clamp(voltage, min_hvps_voltage, max_hvps_voltage)
        write voltage to {STN}:HVPS:VOLT:CTRL
    
    else:
        // REGULATION MODE
        if direct_loop == OFF:
            // Regulate drive power
            delta = read({STN}:KLYSDRIVFRWD:HVPS:DELTA)
            if drive_power_error_severity == OK:
                voltage += delta
        else:
            // Regulate gap voltage
            delta = read({STN}:STNVOLT:HVPS:DELTA)
            if gap_voltage_error_severity == OK:
                voltage += delta
        
        clamp(voltage, min_hvps_voltage, max_hvps_voltage)
        write voltage to {STN}:HVPS:VOLT:CTRL
        
        // Tolerance check
        diff = |voltage - readback_hvps_voltage|
        if diff > allowed_hvps_voltage_diff:
            increment tolerance counter
            if counter > threshold:
                set status = OUT_OF_TOLERANCE
```

---

*End of Legacy LLRF Control System Technical Report*
