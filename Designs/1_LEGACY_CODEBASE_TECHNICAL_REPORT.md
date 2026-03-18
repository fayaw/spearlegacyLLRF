# SPEAR3 Legacy LLRF Control System — Comprehensive Codebase Technical Report

**Document ID**: SPEAR3-LLRF-LEGACY-CODE-001
**Date**: March 2026
**Subject**: Technical analysis of the `rf-spear-legacy/` codebase
**Purpose**: Provide complete understanding of the current (legacy) software system to support the LLRF upgrade project

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Repository Structure and Metrics](#2-repository-structure-and-metrics)
3. [System Architecture Overview](#3-system-architecture-overview)
4. [Core VXI Driver Layer](#4-core-vxi-driver-layer)
5. [Custom EPICS Record Types and Device Support](#5-custom-epics-record-types-and-device-support)
6. [DSP Firmware Subsystem](#6-dsp-firmware-subsystem)
7. [Signal Processing Subroutines](#7-signal-processing-subroutines)
8. [Allen-Bradley PLC Subsystem](#8-allen-bradley-plc-subsystem)
9. [Stepper Motor Subsystem](#9-stepper-motor-subsystem)
10. [VXI Infrastructure Layer](#10-vxi-infrastructure-layer)
11. [SNL State Machine Programs](#11-snl-state-machine-programs)
12. [IOC Configuration and Runtime](#12-ioc-configuration-and-runtime)
13. [Data Flow Examples](#13-data-flow-examples)
14. [Appendix A: Complete File Inventory](#appendix-a-complete-file-inventory)

---

## 1. Executive Summary

The `rf-spear-legacy/` directory contains the complete EPICS-based control software for the SPEAR3 RF station. Originally developed at SLAC for the PEP-II B-Factory (circa 1995-1997) by R. Claus, P. Corredoura, S. Allison, R. Sass, and others, the system was adapted for SPEAR3 operation.

### Scale

| Metric | Value |
|--------|-------|
| **Total lines of code** | **82,430+** |
| **Source files** | **253** (extracted from CVS archive) |
| **Custom EPICS record types** | **7** (RFP, GVF, IQA, AIM, CLK, CF2, CFM) |
| **Device support modules** | **7** (one per record type) |
| **DSP firmware programs** | **4** (RFP, GVF, Observer, Generic shared) |
| **DSP assembly lines** | **15,667** |
| **PLC driver files** | **~20** (across AB SLC-500, PLC-5, stepper) |
| **SNL state machine programs** | **6** (~7,112 lines) |
| **Subroutine record functions** | **~35** (subIQ.c + subSys.c) |

### Technology Stack

- **RTOS**: VxWorks (Motorola 68040 / PowerPC 604)
- **EPICS**: R3.13.x era (pre-Base 3.14)
- **Hardware bus**: VXI (VME eXtensions for Instrumentation)
- **VXI controller**: Kinetics Systems KSC V152 slot-0 controller
- **DSP processor**: TI TMS320C16xx family (on-board in RF modules)
- **PLC**: Allen-Bradley SLC-500 (HVPS), PLC-5/1771-DCM (RF MPS), 1746-HSTP1 (tuners)
- **Source control**: CVS (files stored as RCS `,v` archives)

### Software Architecture Summary

The system follows a strict layered EPICS architecture:

```
┌──────────────────────────────────────────────────────┐
│  SNL State Machines (rf_states, rf_hvps_loop, etc.)  │  ~7,112 lines
├──────────────────────────────────────────────────────┤
│  Subroutine Records (subIQ.c, subSys.c)             │  ~1,429 lines
├──────────────────────────────────────────────────────┤
│  Custom EPICS Record Types (7 types)                 │  ~2,371 lines
├──────────────────────────────────────────────────────┤
│  Device Support Layer (7 modules)                    │  ~15,059 lines
├──────────────────────────────────────────────────────┤
│  Core VXI Driver (drvP2RfVxi.c)                      │  ~2,671 lines
├──────────────────────────────────────────────────────┤
│  VXI Infrastructure (EPVXI + KSC)                    │  ~6,000+ lines
├──────────────────────────────────────────────────────┤
│  AB PLC Drivers (drvAb, dev1771DCM, devSLCDCM, etc.) │  ~5,000+ lines
├──────────────────────────────────────────────────────┤
│  DSP Firmware (TMS320C16xx assembly)                 │  ~15,667 lines
├──────────────────────────────────────────────────────┤
│  VxWorks RTOS / VME Hardware                         │
└──────────────────────────────────────────────────────┘
```


---

## 2. Repository Structure and Metrics

### Directory Layout

```
rf-spear-legacy/
├── rfApp/                              # Main RF application
│   ├── src/
│   │   ├── db/                         # Custom record types + device support (CORE)
│   │   │   ├── drvP2RfVxi.c/h         # Central VXI driver (2,671 lines)
│   │   │   ├── devP2RfRfp.c           # RF Processor device support (2,389 lines)
│   │   │   ├── devP2RfGvf.c           # Gap Voltage Feed-Forward device support (2,350 lines)
│   │   │   ├── devP2RfIqa.c           # I/Q & Amplitude device support (2,260 lines)
│   │   │   ├── devP2RfAim.c           # Arc/Interlock Module device support (1,982 lines)
│   │   │   ├── devP2RfCf2.c           # Comb Filter v2 device support (2,970 lines)
│   │   │   ├── devP2RfCfm.c           # Comb Filter v1 device support (1,487 lines)
│   │   │   ├── devP2RfClk.c           # Clock Module device support (957 lines)
│   │   │   ├── p2Rf*Def.h             # Register definitions per module type
│   │   │   ├── p2Rf*Record.c          # Custom record type implementations
│   │   │   ├── p2RfLib.h              # Shared library definitions & data structures
│   │   │   ├── subIQ.c                # I/Q signal processing subroutines (965 lines)
│   │   │   └── subSys.c               # System-level subroutines (464 lines)
│   │   ├── base/                       # VXI utilities, DSP library, infrastructure
│   │   │   ├── vbb.c                  # VXI Bus Browser utility (2,398 lines)
│   │   │   ├── dlt.c                  # Down Load Table utility (1,008 lines)
│   │   │   ├── bus.c                  # Bus access routines (855 lines)
│   │   │   ├── sgl.c                  # Signaling/messaging library (731 lines)
│   │   │   ├── lip.c                  # Load In Place utility (582 lines)
│   │   │   ├── dld.c                  # Down Load DSP utility (575 lines)
│   │   │   ├── dspCmdDef.h            # DSP command protocol definitions
│   │   │   ├── dspLib.h               # DSP library interface
│   │   │   └── ... (40+ header/source files)
│   │   ├── dsp/                        # DSP firmware (TMS320C16xx assembly)
│   │   │   ├── rfpDsp/                # RFP module DSP (ripple loop, DAC control)
│   │   │   ├── gvfDsp/                # GVF module DSP (feed-forward, waveform output)
│   │   │   ├── obsDsp/                # Observer DSP (adaptive filtering, I/Q processing)
│   │   │   └── genDsp/                # Shared DSP functions (trig, sqrt)
│   │   ├── diag/                       # Diagnostic utilities
│   │   │   └── rf_vxi_diag.c          # VXI module diagnostics (2,328 lines)
│   │   ├── seq/                        # SNL state machine programs
│   │   │   ├── rf_states.st           # Station state machine (2,227 lines)
│   │   │   ├── rf_calib.st            # Calibration sequences (3,345 lines)
│   │   │   ├── rf_tuner_loop.st       # Tuner motor control (555 lines)
│   │   │   ├── rf_hvps_loop.st        # HVPS supervisory (343 lines)
│   │   │   ├── rf_msgs.st             # Message logging (352 lines)
│   │   │   └── rf_dac_loop.st         # DAC loop control (290 lines)
│   │   └── rf/                         # IOC main entry point
│   ├── Db/                             # EPICS database files
│   ├── DbIoc/                          # IOC-specific databases
│   └── ksc_v152/                       # KSC slot-0 VXI controller driver & PLDs
│       ├── driver_source/              # VXI library and resource manager source
│       └── PLDs/                       # Programmable Logic Device definitions
├── allenBradley/                       # Allen-Bradley PLC drivers
│   └── allenBradleyApp/
│       ├── basicSrc/                   # Core AB driver (drvAb.c, 2,039 lines)
│       ├── 1771DCMSrc/                 # PLC-5 scanner device support
│       ├── SLCDCMSrc/                  # SLC-500 device support
│       ├── 1746HSTP1Src/               # Stepper motor module device support (1,673 lines)
│       └── ... (additional AB modules)
├── stepper/                            # Stepper motor control
│   └── stepper/
│       ├── steppermotorRecord.c        # Custom stepper record type (959 lines)
│       ├── drvCompuSm.c               # Compumotor driver (872 lines)
│       └── drvOms.c                    # Oregon Micro Systems driver (705 lines)
├── epvxi/                              # EPICS VXI infrastructure
│   └── src/
│       ├── drvEpvxi.c                  # VXI resource manager (4,622 lines)
│       ├── drvEpvxiMsg.c              # VXI messaging (1,529 lines)
│       └── epvxi.h                     # VXI framework API (532 lines)
├── dsp1610/                            # TMS320C16xx development tools
├── iocBoot/                            # IOC boot configuration
│   └── b132-iocrf/                     # SPEAR3 RF station boot scripts
└── configure/                          # EPICS build configuration
```

### Top 25 Files by Size

| File | Lines | Description |
|------|-------|-------------|
| `epvxi/src/drvEpvxi.c` | 4,622 | VXI resource manager and infrastructure |
| `rfApp/src/seq/rf_calib.st` | 3,345 | Calibration sequence program |
| `rfApp/src/db/devP2RfCf2.c` | 2,970 | Comb Filter v2 device support |
| `rfApp/src/db/drvP2RfVxi.c` | 2,671 | **Core VXI driver** — central hub for all modules |
| `rfApp/src/base/vbb.c` | 2,398 | VXI Bus Browser interactive utility |
| `rfApp/src/db/devP2RfRfp.c` | 2,389 | RF Processor device support |
| `rfApp/src/db/devP2RfGvf.c` | 2,350 | Gap Voltage Feed-Forward device support |
| `rfApp/src/diag/rf_vxi_diag.c` | 2,328 | VXI diagnostic routines |
| `rfApp/src/db/devP2RfIqa.c` | 2,260 | I/Q & Amplitude Detector device support |
| `rfApp/src/seq/rf_states.st` | 2,227 | RF station state machine |
| `allenBradley/.../drvAb.c` | 2,039 | Core Allen-Bradley serial driver |
| `rfApp/src/db/devP2RfAim.c` | 1,982 | Arc/Interlock Module device support |
| `allenBradley/.../devSmAB1746HSTP1.c` | 1,673 | AB stepper motor module driver |
| `epvxi/src/drvEpvxiMsg.c` | 1,529 | VXI message passing |
| `rfApp/src/db/devP2RfCfm.c` | 1,487 | Comb Filter v1 device support |
| `rfApp/src/dsp/gvfDsp/wave_out.s` | 1,298 | GVF waveform output DSP |
| `rfApp/src/dsp/gvfDsp/gvff.s` | 1,199 | GVF feed-forward DSP |
| `rfApp/src/dsp/rfpDsp/ripple_phaseoff.s` | 1,157 | RFP ripple loop w/ phase offset |
| `rfApp/src/dsp/rfpDsp/ripple.s` | 1,144 | RFP ripple rejection loop |
| `rfApp/src/dsp/rfpDsp/sp3ripple.s` | 1,103 | SPEAR3-specific ripple loop variant |
| `rfApp/src/dsp/rfpDsp/lusqrt.s` | 1,064 | Fixed-point square root (unsigned) |
| `rfApp/src/dsp/rfpDsp/sqlu.s` | 1,024 | Alternate square root implementation |
| `rfApp/src/base/dlt.c` | 1,008 | Download table utility |
| `rfApp/src/db/subIQ.c` | 965 | I/Q signal processing subroutines |
| `stepper/stepper/steppermotorRecord.c` | 959 | Custom stepper motor record type |


---

## 3. System Architecture Overview

### 3.1 Hardware Context

The VXI chassis (Building B132, SPEAR RF station) contains the following modules:

| Slot | Module | VXI Model | Drawing | EPICS Record Type |
|------|--------|-----------|---------|-------------------|
| 0 | KSC V152 Slot-0 Controller | — | — | (infrastructure) |
| 1+ | Clock & RF Distribution | 0x106 | — | P2RfClkRecord |
| 1+ | RF Processing (RFP) | 0x103 | 340-304 | P2RfRfpRecord |
| 1+ | Gap Voltage Feed-Forward (GVF) | 0x105 | — | P2RfGvfRecord |
| 1+ | I/Q & Amplitude Detector (IQA) ×3 | 0x102 | — | P2RfIqaRecord |
| 1+ | Arc Detector / Fast Interlock (AIM) | 0x107 | — | P2RfAimRecord |
| 1+ | Comb/Group Delay Equalizer v1 (CFM) | 0x101 | — | P2RfCfmRecord |
| 1+ | Comb/Group Delay Equalizer v2 (CF2) | 0x101 | — | P2RfCf2Record |

All modules are manufactured by SLAC (`P2RF_K_MAKE = 0xf00`, "SLAC PEP-II RF") and share the VXI register-based interface defined in the `drvP2RfVxi` driver.

### 3.2 Software Data Flow

```
  ┌─────────────────────────────────────────────────────────────┐
  │                     EPICS Channel Access                     │
  │  (Operator displays, archiver, other IOCs)                   │
  └───────────────────────────┬─────────────────────────────────┘
                              │ PV access
  ┌───────────────────────────┴─────────────────────────────────┐
  │  SNL State Machines              Subroutine Records          │
  │  (rf_states, rf_hvps_loop,       (subIQ: phase, amplitude,   │
  │   rf_tuner_loop, rf_calib,        power, DAC calculations;   │
  │   rf_dac_loop, rf_msgs)           subSys: freq, DC coeff)    │
  └───────────────────────────┬─────────────────────────────────┘
                              │ dbPut / dbGet / scanOnce
  ┌───────────────────────────┴─────────────────────────────────┐
  │  Custom Record Types (7 types)                               │
  │  p2RfRfpRecord, p2RfGvfRecord, p2RfIqaRecord,               │
  │  p2RfAimRecord, p2RfClkRecord, p2RfCf2Record, p2RfCfmRecord │
  │  → Each has: InitRecord() and Action() routines              │
  └───────────────────────────┬─────────────────────────────────┘
                              │ DSET (Device Support Entry Table)
  ┌───────────────────────────┴─────────────────────────────────┐
  │  Device Support Modules (devP2Rf*.c)                         │
  │  → Per-module: ISR, ColdInit, WarmInit, Action               │
  │  → Async: SpawnReset, SpawnLdDsp, SpawnGetHist, callbacks    │
  │  → Data structures: *Board (per-module private state)        │
  └───────────────────────────┬─────────────────────────────────┘
                              │ P2RF_ReadVme / P2RF_WriteVme
  ┌───────────────────────────┴─────────────────────────────────┐
  │  Core VXI Driver (drvP2RfVxi.c)                              │
  │  → Module registration and management table                  │
  │  → A16/A24 address space translation (ADX2IDX, STD2IDX)     │
  │  → Interrupt routing and dispatching                         │
  │  → DSP firmware loading (P2RF_LoadDsp)                       │
  │  → Coefficient/table/register file I/O                       │
  │  → Memory recording and copying (waveform capture)           │
  └───────────────────────────┬─────────────────────────────────┘
                              │ epvxiFetchPConfig / VME bus read/write
  ┌───────────────────────────┴─────────────────────────────────┐
  │  EPVXI Framework (drvEpvxi.c)                                │
  │  → VXI resource manager: module discovery, address allocation│
  │  → Make/model registration and verification                  │
  │  → A16/A24/A32 space management                              │
  │  → Trigger routing and interrupt infrastructure              │
  └───────────────────────────┬─────────────────────────────────┘
                              │ VME bus operations via VxWorks
  ┌───────────────────────────┴─────────────────────────────────┐
  │  VxWorks RTOS on Motorola 68040 / PPC604 CPU                 │
  │  VXI backplane (VMEbus with instrument extensions)           │
  └─────────────────────────────────────────────────────────────┘
```

### 3.3 Interrupt Architecture

Each VXI module generates hardware interrupts that are dispatched by the core driver:

1. **Hardware interrupt** fires on VXI backplane (level configurable, default 5)
2. `drvP2RfVxi.c` → `P2RF_IntServRtn()` is invoked by VxWorks ISR dispatcher
3. The ISR reads the module's Interrupt Status register to determine the source
4. It calls the **module-specific ISR** registered during `P2RF_RegisterModule()`
5. The module ISR (e.g., `RfpIsr`, `IqaIsr`, `GvfIsr`) handles the event:
   - For DSP messages: queues a `callbackRequest` to handle in task context
   - For fault/status changes: sets bits in the record's `istt` field
   - Calls `scanOnce()` to trigger EPICS record processing
6. EPICS processes the record → `Action()` runs → updates PVs → posts events

**Critical design note** (from source comments): Register read-modify-write operations must be atomic because multiple tasks may access the same module register. The solution used is to route register modifications through the ISR by generating software interrupts, avoiding the need for the non-portable Motorola CAS2 instruction.


---

## 4. Core VXI Driver Layer

**File**: `rfApp/src/db/drvP2RfVxi.c` (2,671 lines) + `rfApp/src/db/drvP2RfVxi.h`

This is the **single most critical file** in the codebase. It provides the complete hardware abstraction layer between EPICS device support and the physical VXI modules.

### 4.1 Module Management

The driver maintains an internal table of registered module types and instantiated modules. Each VXI slot that contains a PEP-II RF module is tracked with a driver-private (`drvPvt`) data structure containing:

- VXI logical address
- A16 register base pointer (for control/status registers)
- A24 memory base pointer (for DSP external RAM)
- Module type identifier
- Interrupt service routine pointer
- Per-module state information

**Module Registration API**:
```c
P2RF_RegisterModule(make, model, name, initFunc, shutdownFunc, isrFunc, isrArg)
```
Called at IOC startup by each device support module. Registers the module type so the driver can recognize it during VXI bus scanning.

**Module Initialization**:
```c
P2RF_InitModule(drvPvt, slot, coldFlag)
```
Called for each discovered module. Resolves A16/A24 addresses, sets up interrupt vectors, and invokes the device support's `ColdInit()` or `WarmInit()` depending on whether the module was already running.

### 4.2 Register Access API

All register access flows through two fundamental functions:

```c
P2RF_ReadVme(drvPvt, registerIndex, &value)   // Read 16-bit register
P2RF_WriteVme(drvPvt, registerIndex, value)    // Write 16-bit register
```

The `registerIndex` is a **word index** (not byte offset) into the module's A16 register space. The conversion macros are:

```c
#define ADX2IDX(a)  ((a) >> 1)       // Byte address → word index (A16 space)
#define STD2IDX(a)  ADX2IDX(a)       // Standard VXI register byte → word index
```

Each module header (`p2Rf*Def.h`) defines both the byte address (`*_A_*`) and the word index (`*_I_*`) for every register:
```c
#define RFP_A_RFCTRL    0x20          // RF Control register byte address
#define RFP_I_RFCTRL    STD2IDX(RFP_A_RFCTRL)  // Word index
```

### 4.3 DSP Firmware Management

The core driver handles the complete lifecycle of on-board DSP processors:

**Firmware Loading**:
```c
P2RF_LoadDsp(drvPvt, memIndex, filename, resetFlag, msgBuf, msgLen)
```
- Reads a TI TMS320C16xx COFF executable from a file
- Parses the COFF header (defined in `filehdr.h`, `scnhdr.h`)
- Resets the DSP (by toggling the NOTDSPRST bit in the module control register)
- Loads each section (.text, .data, .ram, .comm) into DSP memory via A24 bus writes
- Releases DSP from reset to begin execution

**DSP Communication Protocol**:
The driver locates the DSP Communications Block in external RAM:
```c
P2RF_DspFindComBlk(drvPvt, &comBlkPtr)
```

The Communications Block is a fixed-format shared memory structure (defined in `dspCmdDef.h` and `comBlk.s`):

| Offset | Field | Description |
|--------|-------|-------------|
| 0 | `blkId` | Block identifier (0x0001 expected) |
| 1 | `vers` | Version number (0x0001 expected) |
| 2 | `chkSum` | Checksum |
| 3 | `status` | DSP status code |
| 4-11 | `sttArg[8]` | Status arguments (8 words) |
| 12 | `dspMsg` | Message FROM DSP to CPU |
| 13 | `dspArg` | Message argument FROM DSP |
| 14 | `cpuMsg` | Message FROM CPU to DSP |
| 15 | `cpuArg` | Message argument FROM CPU |
| 16 | `comLen` | Block size |

**DSP Command Set** (from `dspCmdDef.h`):

| Command | Value | Direction | Description |
|---------|-------|-----------|-------------|
| `CMD_K_NOOP` | 0x0000 | — | No operation |
| `CMD_K_READY` | 0x0001 | DSP→CPU | DSP reports ready after boot |
| `CMD_K_TEST` | 0x0002 | — | Test command |
| `CMD_K_ERROR` | 0x0003 | DSP→CPU | DSP error condition |
| `CMD_K_LDTBL` | 0x0004 | CPU→DSP | Load coefficient tables |
| `CMD_K_SVDATA` | 0x0005 | DSP→CPU | DSP requests data save |
| `CMD_K_APHASE` | 0x0006 | — | Save average phase |
| `CMD_K_LDREF` | 0x0007 | CPU→DSP | Load reference tables |
| `CMD_K_UREF` | 0x0008 | CPU→DSP | Update reference tables |
| `CMD_K_AMSP` | 0x000a | CPU→DSP | Update ripple amplitude setpoint |
| `CMD_K_PHSG` | 0x000b | CPU→DSP | Update ripple DC Z⁻¹ phase gain |
| `CMD_K_DACO` | 0x000c | CPU→DSP | Load ripple DAC offsets (II,IQ,QI,QQ) |
| `CMD_K_PHARM` | 0x000d | CPU→DSP | Ripple phase harmonic coefficients |
| `CMD_K_AHARM` | 0x000e | CPU→DSP | Ripple amplitude harmonic coefficients |
| `CMD_K_DONE` | 0xFFFF | both | Operation complete |

### 4.4 Memory and Table Operations

```c
P2RF_LoadTblFile(drvPvt, id, memIndex, filename, count, abortFlg, msgBuf, len)
P2RF_LoadRegFile(drvPvt, filename, msgBuf, len)
P2RF_LoadConsts(drvPvt, memIndex, data, count)
P2RF_LoadCoefs(drvPvt, memIndex, data, count)
P2RF_LoadDdf(drvPvt, memIndex, filename, msgBuf, len)    // Digital filter definitions
P2RF_RecordMemory(drvPvt, id, memIndex, filename, count)
P2RF_CopyMemory(drvPvt, memIndex, buffer, count)
P2RF_SaveDspMemory(drvPvt, filename, start, count)
```

These functions support:
- Loading waveform tables (DAC I/Q drive patterns) from files into module memory
- Loading digital filter coefficients (F, FC, H sections) for IQA/CF2 modules
- Capturing waveform data from module memory to files for analysis
- Saving DSP memory snapshots for diagnostics

### 4.5 Interrupt Management

```c
P2RF_IntEnable()          // Global interrupt enable for all RF modules
P2RF_IntDisable()         // Global interrupt disable
P2RF_ModIntEnable(drvPvt)  // Per-module interrupt enable
P2RF_ModIntDisable(drvPvt) // Per-module interrupt disable
```

The interrupt level is configured globally via `P2RF_K_INTLEVEL` (typically 5) and is set in each module's Interrupt Control register during initialization.


---

## 5. Custom EPICS Record Types and Device Support

This section describes each of the 7 custom EPICS record types. Each record type has:
- A **definition header** (`p2Rf*Def.h`): Hardware register addresses, bit field definitions, constants
- A **record source** (`p2Rf*Record.c`): EPICS record field definitions and processing logic
- A **device support source** (`devP2Rf*.c`): Hardware interface, ISR, initialization

### 5.1 RF Processor (RFP) — The Heart of the Feedback System

**Files**: `p2RfRfpDef.h` (495 lines), `p2RfRfpRecord.c` (296 lines), `devP2RfRfp.c` (2,389 lines)

**VXI Model**: 0x103
**Function**: Core RF feedback processor. Contains octal DACs for I/Q signal manipulation, direct loop and comb loop feedback controls, DSP for ripple rejection, and cavity signal multiplexing.

**Key Hardware Registers** (from `p2RfRfpDef.h`):

| Register | Addr | Description |
|----------|------|-------------|
| `RFP_A_RFCTRL` | 0x20 | RF Control register — mode, loop enables, cavity mux |
| `RFP_A_RFSTAT` | 0x20 | RF Status register — current state readback |
| `RFP_A_INTCTRL` | 0x1C | Interrupt Control — enable/mask individual interrupts |
| `RFP_A_INTSTAT` | 0x1A | Interrupt Status — pending interrupt sources |
| `RFP_A_CCC1II` | 0x30+ | Octal DAC registers (C1II through CLCQQ, then MDRV) |
| `RFP_A_SMSTOPDT` | — | State Machine stop data taking command |

**Operating Modes** (from `RFP_V_MODE` field):
- `rfpReset` (0): Module in reset — no RF output
- `rfpLoad` (1): Load mode — can program DSP, load tables, modify DACs
- `rfpRun` (2): Run mode — feedback loops active, optional DACs output and single-shot counter

**Control Bits** (from `RFP_M_*` masks):
- `RFP_M_DIRLPENB`: Direct loop enable
- `RFP_M_CMBLPENB`: Comb loop enable
- `RFP_M_RIPLPENB`: Ripple loop enable
- `RFP_M_RFENB`: RF feedback enable
- `RFP_M_DACSOUT`: DACs output enable
- `RFP_M_SGLSHTCNT`: Single-shot counter mode
- `RFP_M_CAVSELMUX`: Cavity selection multiplexer
- `RFP_M_FBSIGMUX`: Feedback signal multiplexer
- `RFP_M_DACINJPT`: DAC injection point
- `RFP_M_NOTDSPRST`: DSP reset (active low)
- `RFP_M_OPMODE`: Operating mode (cw vs. tuning)
- `RFP_M_INTCOMP`: Integral compensator enable
- `RFP_M_LEADCOMP`: Lead compensator enable

**Interrupt Sources** (from `RFP_M_*` interrupt bits):
- `RFP_M_INVRFREF`: Invalid RF reference clock
- `RFP_M_INVCLKS`: Invalid 80/40/10 MHz and/or ripple clocks
- `RFP_M_ADCOFLW`: ADC overflow detected
- `RFP_M_RIPLPERR`: Ripple loop serial link error
- `RFP_M_DSPMSG`: Message from DSP
- `RFP_M_INVSMOP`: Invalid state machine operation
- `RFP_M_INVOP`: Invalid operation
- `RFP_M_SOFTWARE`: Software interrupt

**Device Support Architecture** (`devP2RfRfp.c`):

The RFP device support is the most complex in the system. Its private data structure (`RfpBoard`) contains:

```c
typedef struct {
  void           *drvPvt;        // Driver private (VXI address info)
  P2RfRfpRecord  *rec;           // Back-pointer to EPICS record
  RfpRstBlk       resetBlk;      // Async reset control block
  RfpDspMsgBlk    dspMsgBlk;     // DSP message handling block
  RfpDspBlk       dspBlk;        // DSP load control block
  RfpRamBlk       getRamBlk;     // Async RAM read control block
  RfpRamBlk       ldRamBlk;      // Async RAM write control block
  unsigned int    intPrc;        // Interrupt processing counter
  RfpDspMsgPrm    dspMsgPrm;     // DSP message parameters
  RfpDspPrm       dspPrm;        // DSP load parameters
  RfpMemPrm       sigIPrm;       // Signal I RAM parameters
  RfpMemPrm       sigQPrm;       // Signal Q RAM parameters
  RfpMemPrm       cavIPrm;       // Cavity I RAM parameters
  RfpMemPrm       cavQPrm;       // Cavity Q RAM parameters
  RfpMemPrm       dacIPrm;       // DAC I RAM parameters
  RfpMemPrm       dacQPrm;       // DAC Q RAM parameters
} RfpBoard;
```

**DSP Communication Block Structure**:
```c
typedef struct _DspComBlk {
  volatile unsigned short  blkId;           // Block identifier
  volatile unsigned short  vers;            // Version
  volatile unsigned short  chkSum;          // Checksum
  volatile unsigned short  status;          // Status
  volatile unsigned short  sttArg[STT_K_ARGCNT]; // Status arguments
  volatile unsigned short  dspMsg;          // Message from DSP
  volatile unsigned short  dspArg;          // DSP argument
  volatile unsigned short  cpuMsg;          // Message to DSP
  volatile unsigned short  cpuArg;          // CPU argument
  volatile unsigned short  comLen;          // Block size
} DspComBlk;
```

**Key Device Support Functions**:

1. **`InitRecord()`**: Allocates `RfpBoard` structure, calls `P2RF_InitModule()`, performs `ColdInit()` or `WarmInit()`
2. **`Action()`** (~400 lines): The main record processing routine. Handles:
   - Interrupt-driven processing (when `intPrc > 0`)
   - Module reset requests (`rec->mrst`)
   - Interrupt mask updates (`rec->imsk`)
   - Operating mode changes (RESET → LOAD → RUN transitions)
   - Feedback loop enables (direct, comb, ripple)
   - DAC loading (octal DAC write with readback verification)
   - DSP loading (`SpawnLdDsp`)
   - DSP parameter downloads (amplitude setpoint, phase gain, DAC offsets, harmonic coefficients)
   - Signal RAM read/write (for waveform capture)
3. **`ColdInit()`**: Full initialization from scratch:
   - Configures interrupt control register
   - Resets module to LOAD mode
   - Resets DSP, loads firmware from file (`rec->dspe` field)
   - Loads all octal DACs from database values
   - Loads DAC I and Q memory tables from files
   - Configures RF Control register (loop enables, mux settings, mode)
   - Boots DSP (releases from reset)
4. **`WarmInit()`**: Syncs database to already-running module (reads current state)
5. **`RfpIsr()`**: ISR for RFP interrupts:
   - Handles DSP message interrupt (`RFP_M_DSPMSG`) → queues callback
   - Updates interrupt status field (`rec->istt`)
   - Triggers record processing via `scanOnce()`
6. **`DspMsgCallback()`**: Processes DSP messages in task context:
   - `CMD_K_READY`: DSP booted successfully → loads all DSP parameters (amplitude setpoint, phase gain, DAC offsets, phase harmonics, amplitude harmonics)
   - Other messages: logs and processes

**Octal DAC System**: The RFP has an array of octal DACs for precise I/Q signal control:
- Cavity weights: C1II, C1IQ, C1QI, C1QQ through C4II...C4QQ
- Compensation loop: CLCII, CLCIQ, CLCQI, CLCQQ
- Master drive: MDRV (on Version 2+ boards, `RFP_K_VER2VERN`)
- Each DAC value has a fixed offset: `RFP_K_OCTDACOS`
- Values are shifted by `RFP_V_OCTDAC` bits before writing
- Write-readback verification is performed on every load

### 5.2 Gap Voltage Feed-Forward (GVF)

**Files**: `p2RfGvfDef.h` (330 lines), `p2RfGvfRecord.c` (307 lines), `devP2RfGvf.c` (2,350 lines)

**VXI Model**: 0x105
**Function**: Gap Voltage Feed-Forward processing with TAXI link interface. Implements a feed-forward control loop that compensates for beam loading by anticipating changes based on gap timing. Also handles the LFB (Low-Frequency Bunch-by-bunch feedback) woofer function and waveform output.

**Key Capabilities**:
- Feed-forward loop for beam loading compensation
- TAXI serial link interface for timing signals
- Waveform output for arbitrary signal generation
- LFB woofer control
- DSP with firmware for feed-forward calculation

**Device Support Pattern**: Follows the same architecture as RFP:
- `GvfBoard` private structure with per-module DSP comm block
- `ColdInit()` / `WarmInit()` for startup
- DSP firmware loading and communication
- Waveform RAM load/read operations
- TAXI link monitoring

### 5.3 I/Q & Amplitude Detector (IQA)

**Files**: `p2RfIqaDef.h` (509 lines — largest header), `p2RfIqaRecord.c` (301 lines), `devP2RfIqa.c` (2,260 lines)

**VXI Model**: 0x102
**Function**: Amplitude and phase measurement module. Performs I/Q detection on RF signals and provides amplitude, phase, and timing measurements. Three instances are typically used — one each for forward, reflected, and cavity probe signals.

**Key Features**:
- I/Q signal acquisition with digital filtering
- Digital filter definition (DDF) file loading for configurable filter characteristics
- Amplitude and phase measurement
- History memory for waveform capture
- Multiple filter configurations (e.g., 50 Hz bandwidth for slow monitoring, 23 kHz for fast acquisition)

**DDF Filter Loading**: The IQA module supports loadable digital filters with F (feedforward), FC (feedback coefficient), and H (transfer function) register sets. The configuration files (`iqaDdf_50Hz.rpt`, `iqaDdf_23KHz.rpt`) are loaded at initialization.

### 5.4 Arc Detector / Fast Interlock (AIM)

**Files**: `p2RfAimDef.h` (390 lines), `p2RfAimRecord.c` (300 lines), `devP2RfAim.c` (1,982 lines)

**VXI Model**: 0x107
**Function**: Arc detection and fast interlock module. Monitors for RF arcs in the waveguide system and generates fast trip signals. Also handles beam abort detection, filament monitoring, and fault history recording.

**Key Capabilities**:
- **12-channel** arc detection (version-dependent: early boards had fewer channels)
- Fast interlock chain input/output
- Beam abort trip (BATS) monitoring
- Fault history recording (up to `NUMFFILES = 11` fault files)
- Filament current monitoring
- Hardware fault file dumps (DAS — Data Acquisition Sequence):
  - Configuration files: `aimDas0.inst`, `aimDas1.inst` define data capture sequences
  - After faults, signal/cavity/DAC RAM contents are dumped for analysis

**Fault File System**: When a trip occurs, the AIM device support triggers a sequence that:
1. Captures the current state of all signal RAMs
2. Writes fault data to numbered files (`/dat/FAULTSigI_00` through `_10`)
3. Records fault metadata (time, source, interlock chain state)

### 5.5 Clock & RF Distribution (CLK)

**Files**: `p2RfClkDef.h` (271 lines), `p2RfClkRecord.c` (299 lines), `devP2RfClk.c` (957 lines)

**VXI Model**: 0x106
**Function**: Generates and distributes the master RF clock and derived clocks to all other VXI modules. Controls PLL lock for the 476.3 MHz reference and 39 MHz subharmonic.

**Key Registers**:
- `CLK_A_CLKCTRL`: Clock control register (PLL configuration)
- `CLK_A_39MHZ_PLL`: 39 MHz PLL constants
- `CLK_A_471MHZ_PLL`: 471 MHz PLL constants (approximate RF frequency subharmonic)

The `ClkConsts(r,a,m,p)` macro packs PLL parameters: R divider, A counter, M divider, and polarity bit into a 16-bit register value.

### 5.6 Comb Filter / Group Delay Equalizer v2 (CF2)

**Files**: `p2RfCf2Def.h` (403 lines), `p2RfCf2Record.c` (366 lines), `devP2RfCf2.c` (2,970 lines — largest device support)

**VXI Model**: 0x101 (shared with CFM)
**Function**: Second-generation comb filter for narrowband rejection of revolution-frequency harmonics. Implements digital filtering with loadable coefficients for comb notch frequency and bandwidth control.

**Key Capabilities**:
- Comb filter with configurable notch frequencies
- Group delay equalization
- Coefficient file loading (IIR filter coefficients)
- Multiple filter bank support
- Run-time coefficient updates

### 5.7 Comb Filter / Group Delay Equalizer v1 (CFM)

**Files**: `p2RfCfmDef.h` (279 lines), `p2RfCfmRecord.c` (334 lines), `devP2RfCfm.c` (1,487 lines)

**VXI Model**: 0x101
**Function**: First-generation comb filter. Similar to CF2 but older design with fewer features. Supports coefficient loading from table files (`cfmIirCoefsHER.tbl`).

### Common Device Support Pattern

All 7 device support modules follow a consistent EPICS DSET (Device Support Entry Table) pattern:

```c
typedef struct {
  long       number;        // Number of entries
  DEVSUPFUN  report;        // Report function (NULL for most)
  DEVSUPFUN  init;          // Global init (NULL for most)
  DEVSUPFUN  init_record;   // Per-record initialization → InitRecord()
  DEVSUPFUN  get_ioint_info;// I/O interrupt info (NULL for most)
  DEVSUPFUN  action;        // Record processing → Action()
} P2RfXxxDset;
```

Each module's `InitRecord()` performs:
1. Allocate per-board private structure (`XxxBoard`)
2. Call `P2RF_InitModule()` to register with the core driver
3. Set up ISR callbacks and DSP communication blocks
4. Perform `ColdInit()` (full hardware setup) or `WarmInit()` (sync DB to running hardware)
5. Store private data in `rec->dpvt`

Each module's `Action()` handles:
1. Interrupt-driven processing (ISR sets flags → `Action()` posts events)
2. Register reads for status updates
3. Control field changes (operator writes → register writes)
4. Asynchronous operations (DSP load, RAM read/write) via callbacks


---

## 6. DSP Firmware Subsystem

### 6.1 Overview

Each VXI module that processes RF signals has an embedded TI TMS320C16xx DSP. The DSP handles real-time signal processing that is too fast for the IOC CPU (which runs EPICS at ~1 Hz scan rates). The DSP code is written in assembly and loaded by the IOC at boot time via the `P2RF_LoadDsp()` function.

**Architecture**: The DSP has:
- Internal program memory (.text section)
- Internal data memory (.data section)
- External RAM (.ram section, accessible by the CPU via VXI A24 bus)
- Communications block (.comm section, at top of external RAM)

### 6.2 RFP DSP Firmware (~4,600 lines)

**Directory**: `rfApp/src/dsp/rfpDsp/`

The RFP DSP implements the **ripple rejection loop** — a critical function that cancels AC line frequency harmonics (60 Hz and multiples) from the RF system. This is important because the HVPS injects 360 Hz ripple (from 6-pulse rectification of 60 Hz mains) onto the klystron beam voltage, which modulates the RF field.

**Key Files**:

| File | Lines | Description |
|------|-------|-------------|
| `ripple.s` | 1,144 | Core ripple rejection loop |
| `ripple_phaseoff.s` | 1,157 | Ripple loop with phase offset capability |
| `sp3ripple.s` | 1,103 | SPEAR3-specific ripple loop variant |
| `lusqrt.s` | 1,064 | Fixed-point unsigned square root |
| `sqlu.s` | 1,024 | Alternate unsigned square root |
| `ramping.s` | 400+ | DAC ramp-up/ramp-down |
| `comBlk.s` | 130 | Communications block template |
| `comDef.h` | ~50 | Communications block definitions |

**Ripple Loop Algorithm** (from `ripple.s` comments):

The ripple loop operates at approximately **23 kHz** (the ripple clock frequency). Each cycle it:

1. **Reads I/Q signals**: Interlaced reads of Qref, Qkly, Ikly, Iref (from ADCs)
   - Signal format: 16-bit two's complement
2. **Computes phase and amplitude**: Using arctangent (Q/I) in q13 format [−π to π]
3. **Calculates errors**:
   - Phase error = PhaseRef − PhaseKly
   - Amplitude error = AmpRef − AmpKly
4. **Harmonic estimation**: Maintains estimators for AC harmonics (60 Hz, 120 Hz, 180 Hz, etc.)
   - "Fast" harmonics: processed every cycle at 23 kHz
   - "Slow" harmonics: 8 additional harmonics processed round-robin (effective ~3 kHz rate)
   - This enables cancellation of harmonics up to ~1.5 kHz with reasonable coefficient resolution
5. **Accumulates corrections**: In q11 format [−16.0 to +16.0)
6. **Applies corrections**: Updates DAC output values

**Fixed-Point Arithmetic**: All DSP math uses fixed-point representation:
- q13: 13 fractional bits, used for phase/angle representation
- q11: 11 fractional bits, used for accumulator headroom
- The `lusqrt` and `sqlu` functions implement fixed-point square root via lookup table

**DSP Interrupts (BIO bits)**:
- "Message to DSP": Edge-triggered → sets flag in ISR
- "Open/Close Ripple Loop": Level-sensitive → polled via BIO
- "Ripple Clock": Edge-triggered → ISR flag
- "Rear Panel Trigger": Edge-triggered → ISR flag

### 6.3 GVF DSP Firmware (~2,400 lines)

**Directory**: `rfApp/src/dsp/gvfDsp/`

| File | Lines | Description |
|------|-------|-------------|
| `gvff.s` | 1,199 | Gap voltage feed-forward calculation |
| `wave_out.s` | 1,298 | Waveform output control |

The GVF DSP implements:
- Feed-forward correction waveform generation
- Waveform output from DAC memory
- Communication with the host CPU via the communications block

### 6.4 Observer DSP Firmware (~2,500 lines)

**Directory**: `rfApp/src/dsp/obsDsp/`

The Observer DSP implements signal monitoring and adaptive filtering:
- I/Q to amplitude/phase conversion
- Adaptive filtering algorithms
- Arctangent calculation for phase extraction
- Phase averaging and equalization

### 6.5 Generic Shared DSP Functions (~900 lines)

**Directory**: `rfApp/src/dsp/genDsp/`

Shared utility functions used by all DSP firmware:
- Trigonometric functions (sine, cosine via lookup tables)
- Square root (both signed and unsigned variants)
- Fixed-point multiplication and accumulation helpers

### 6.6 DSP Boot Sequence

When the IOC boots or a DSP reload is requested:

1. CPU writes RESET to module control register (clears `NOTDSPRST` bit)
2. CPU loads COFF executable into DSP memory via A24 bus
3. CPU releases DSP from reset (sets `NOTDSPRST` bit)
4. DSP executes `_c_int0` → initializes stack → calls `ComInit` (copies comm block template to ERAM)
5. DSP enters main processing loop
6. DSP writes `CMD_K_READY` to `dspMsg` field and generates DSP message interrupt
7. CPU ISR queues `DspMsgCallback` → callback detects `CMD_K_READY`
8. Callback loads all runtime parameters (amplitude setpoint, phase gain, DAC offsets, harmonic coefficients) via the comm block
9. DSP acknowledges each parameter with `CMD_K_DONE`


---

## 7. Signal Processing Subroutines

### 7.1 subIQ.c — I/Q Signal Processing (965 lines, 25+ functions)

**File**: `rfApp/src/db/subIQ.c`

These functions are registered as EPICS subroutine record processing functions. They perform coordinate transforms, power calculations, and calibration computations on I/Q data from the VXI modules.

**Functions by Category**:

**Phase Calculations**:
- `subIQPhase()`: Phase from I/Q using `atan2(Q, I)` → degrees
- `subIQPhaseStn()`: Station-level phase computation

**Amplitude / Power**:
- `subIQAmp()`: Amplitude from I/Q: `sqrt(I² + Q²)`
- `subIQAmpdB()`: Amplitude in dB: `20 * log10(amp)`
- `subIQPwrdB()`: Power in dB from amplitude
- `subIQPwr()`: Power from amplitude: `amp² / impedance`
- `subIQPwrEff()`: Power efficiency calculation

**Gain / Loss**:
- `subIQGaindB()`: Gain in dB between two power levels
- `subIQGainAmp()`: Gain from amplitude ratio
- `subIQLossdB()`: Loss in dB

**I/Q ↔ Amplitude/Phase Transforms**:
- `subIQIQfromAP()`: Convert amplitude+phase to I+Q
- `subIQAPfromIQ()`: Convert I+Q to amplitude+phase

**DAC Value Computation**:
- `subIQDacII()`, `subIQDacIQ()`, `subIQDacQI()`, `subIQDacQQ()`: Compute octal DAC values for the 2×2 I/Q matrix (used for cavity coupling calibration)

**Directivity Correction**:
- `subIQDirCorr()`: Apply directional coupler correction factors

**Scaling and Conversion**:
- `subIQScale()`: Apply scaling factor to I/Q values
- `subIQOffset()`: Apply DC offset correction

Each function follows the EPICS subroutine record interface:
```c
static long subIQPhase(struct subRecord *psub) {
    psub->val = atan2(psub->b, psub->a) * 180.0 / PI;
    return OK;
}
```
Input values come from the `sub` record's A-L input fields (linked to PVs from the custom record types), and the result goes to the `.VAL` field.

### 7.2 subSys.c — System-Level Calculations (464 lines, 11 functions)

**File**: `rfApp/src/db/subSys.c`

System-level calculations that operate on data from multiple modules.

**Functions**:

| Function | Description |
|----------|-------------|
| `subSysFreqOff()` | Frequency offset calculation from IQA measurements |
| `subSysFreqErr()` | Frequency error (difference from setpoint) |
| `subSysFreqOAvg()` | Frequency offset averaging |
| `subSysPhaseTot()` | Total phase calculation (summing cavity phases) |
| `subSysPhaseCmb()` | Phase combining from multiple cavities |
| `subSysPhaseStn()` | Station-level phase computation |
| `subSysDCcoeff()` | DC coefficient calculation for the compensation loop |
| `subSysDrivSel()` | Drive selection logic (choose between drive sources) |
| `subSysLog()` | Logging function (writes to event log) |
| `subSysABreset()` | Allen-Bradley PLC reset sequence |

**`subSysDCcoeff()`** is notable for implementing the DC coefficient computation that feeds into the RFP compensation loop. This function takes I/Q measurements from multiple IQA modules and computes the coupling matrix coefficients that the RFP needs for proper feedback operation.

**`subSysABreset()`** handles the sequence required to reset the Allen-Bradley PLC communication after a fault or communication loss.


---

## 8. Allen-Bradley PLC Subsystem

### 8.1 Core Driver — drvAb.c (2,039 lines)

**File**: `allenBradley/allenBradleyApp/basicSrc/drvAb.c`

This is the core Allen-Bradley serial communication driver. It manages the serial link between the VME-based IOC and the AB PLCs connected via the Allen-Bradley VME adapter card.

**Key Functions**:
- `abConfigNlinks()`: Configure number of AB serial links
- `abConfigVme()`: Configure VME adapter card base address, interrupt level
- `abConfigScanListAscii()`: Load AB scanner configuration from ASCII file
- `abConfigAuto()`: Auto-discover AB devices on the link
- `abDrv()`: Main driver task — handles serial communication, block transfers, error recovery

**Communication Protocol**:
- Block transfer format for PLC-5 and SLC-500
- Link status monitoring
- Command/response sequencing
- Adapter/group/card indexing for I/O mapping

### 8.2 PLC-5 Device Support — 1771-DCM Scanner

**Directory**: `allenBradley/allenBradleyApp/1771DCMSrc/`

Device support for the AB 1771-DCM (Data Communications Module) scanner, which provides the serial interface to PLC-5 racks. Supports:
- **Analog input** (`devAi1771DCM.c`): Read analog channels from PLC I/O
- **Analog output** (`devAo1771DCM.c`): Write analog setpoints
- **Binary input** (`devBi1771DCM.c`): Read discrete I/O
- **Binary output** (`devBo1771DCM.c`): Write discrete I/O
- **Multi-bit binary I/O** (`devMbbi1771DCM.c`, `devMbbo1771DCM.c`): Multi-bit word I/O
- **Long I/O** (`devLi1771DCM.c`, `devLo1771DCM.c`): 32-bit integer I/O

These modules communicate with the RF MPS PLC (Allen-Bradley PLC-5/ControlLogix).

### 8.3 SLC-500 Device Support

**Directory**: `allenBradley/allenBradleyApp/SLCDCMSrc/`

Device support for the AB SLC-500 series PLC, which is used as the HVPS controller. The SLC-500 handles:
- HVPS voltage setpoint and readback
- Crowbar control
- Contactor control
- Cooling system monitoring
- Various analog and digital I/O for HVPS operation

### 8.4 Stepper Motor Module — 1746-HSTP1 (1,673 lines)

**File**: `allenBradley/allenBradleyApp/1746HSTP1Src/devSmAB1746HSTP1.c`

The most complex AB device support module. Controls the AB 1746-HSTP1 stepper motor modules used for cavity tuner positioning.

**Functions**:
- `ab1746HSTP1_init()`: Initialize stepper module communication
- `ab1746HSTP1_start_trans()`: Start a move transaction
- `ab1746HSTP1_query()`: Query current position and status
- `ab1746HSTP1_strt_trans()`: Start motor motion
- `ab1746HSTP1_end_trans()`: Complete motion transaction

**Motion Sequence**:
1. Write target position to HSTP1 module via AB serial link
2. Issue START command
3. Poll for DONE status
4. Read back actual position
5. Compare with target — if outside deadband, retry

**Configuration**: Through the AB scan list file (loaded by `abConfigScanListAscii()`), each HSTP1 module is mapped to an adapter/rack/card address on the AB serial network.


---

## 9. Stepper Motor Subsystem

### 9.1 Custom Stepper Motor Record (959 lines)

**File**: `stepper/stepper/steppermotorRecord.c`

A custom EPICS record type for stepper motor control. This is an independent record type (not one of the P2Rf types) that supports multiple driver backends.

**Key Features**:
- **Deadband retry logic**: If the motor stops outside the target deadband, automatically retries the move
- **Position feedback**: Reads position from a potentiometer (ADC) or encoder
- **Direction control**: Forward/reverse with configurable polarity
- **Velocity and acceleration**: Configurable motion parameters
- **Error handling**: Detects stall, limit switch, and communication errors
- **Alarm support**: Sets EPICS alarms on position error, motion failure

### 9.2 Driver Backends

The stepper motor record supports three different hardware drivers:

**1. Allen-Bradley 1746-HSTP1** (1,673 lines):
- Primary driver used for SPEAR3 cavity tuners
- Communicates via AB serial link through the `drvAb` driver
- See Section 8.4 for details

**2. Oregon Micro Systems (drvOms.c, 705 lines)**:
- VME-based motion controller
- Direct register access for position and velocity control

**3. Compumotor (drvCompuSm.c, 872 lines)**:
- Parker Compumotor stepper/servo controller
- Serial command interface

### 9.3 Tuner Motor Integration

Each of the 4 SPEAR3 cavities has a mechanical tuner driven by a stepper motor (Superior Electric Slo-Syn M093-FC11, NEMA 34D). The tuner adjusts the cavity resonant frequency to match the RF drive frequency. The control chain is:

```
rf_tuner_loop.st ──PV──> steppermotorRecord ──DSET──> devSmAB1746HSTP1 ──AB──> PLC ──> Motor
```

Four instances of `rf_tuner_loop.st` run concurrently, one per cavity (C1TUNRLOOP through C4TUNRLOOP).

---

## 10. VXI Infrastructure Layer

### 10.1 EPVXI Resource Manager — drvEpvxi.c (4,622 lines)

**File**: `epvxi/src/drvEpvxi.c`

This is the EPICS VXI infrastructure layer, originally written by Jeff Hill at Los Alamos (1989). It provides:

**Device Discovery**:
- Scans the VXI backplane for installed modules
- Reads VXI manufacturer ID, model number, serial number
- Builds a device table with A16/A24/A32 address assignments

**Resource Management**:
- Allocates A24 address windows for modules that need memory access
- Allocates A32 address windows for larger memory requirements
- Manages VXI logical addresses (configurable via `EPICS_VXI_LA_BASE`, `EPICS_VXI_LA_COUNT`)
- Handles dynamic addressing of blocked-address and independently-addressed DC devices

**Make/Model Registration**:
```c
epvxiRegisterMakeName(makeCode, "manufacturer_name")
epvxiRegisterModelName(makeCode, modelCode, "model_name")
```
Called by each device support module to register its hardware type.

**Device Access API**:
```c
epvxiOpen(la, makeCode, modelCode)  // Open a device at logical address
epvxiClose(la)                       // Close a device
epvxiFetchPConfig(la, &pConfig)      // Get device configuration (addresses)
```

**VXI Message Passing** (`drvEpvxiMsg.c`, 1,529 lines):
- Word-serial protocol support for VXI instrument communication
- Command/response messaging via A16 registers

### 10.2 KSC Slot-0 Controller

**Directory**: `rfApp/ksc_v152/`

The Kinetics Systems V152 is the VXI slot-0 controller that manages the VXI backplane. This directory contains:
- **VXI library** (driver_source/vxilib/): VME-to-VXI address translation, interrupt routing
- **Resource manager** (driver_source/resman/): Device configuration, memory allocation, backplane scanning
- **PLDs** (PLDs/): Programmable logic definitions for the hardware adapter

---

## 11. SNL State Machine Programs

### 11.1 rf_states.st — RF Station State Machine (2,227 lines)

**Author**: Robert C. Sass, PEP-II (1997); modified by M. Laznovsky, S. Allison for SPEAR3

The main state machine controlling the RF station. Declares itself as:
```snl
program rf_states ("name=tRFSTATES,STN=barfonthis")
```

**States**:
- **OFF**: RF system powered down — all loops disabled
- **INITIALIZE**: System startup — loads DSP firmware, configures modules
- **STANDBY**: Modules initialized but RF not enabled
- **ON_CW**: Continuous-wave operation — feedback loops active, RF output enabled
- **ON_PULSE**: Pulsed operation mode
- **FAULT**: System has detected a fault — RF disabled, fault recorded
- **FAULT_CLEAR**: Clearing fault condition — resetting interlocks

**Key Operations in State Transitions**:
- OFF → INITIALIZE: Loads DSP, initializes VXI modules, configures AB PLC
- INITIALIZE → STANDBY: Verifies all modules healthy
- STANDBY → ON_CW: Enables direct loop, ramps up drive power, enables comb loop and ripple loop
- ON_CW → FAULT: Triggered by AIM interlock, HVPS trip, or other fault detection
- FAULT → FAULT_CLEAR: Dumps fault files (AIM DAS), resets interlocks
- FAULT_CLEAR → STANDBY: Ready for operator to re-enable

**AIM Fault File Handling** (added by M. Laznovsky, 2003):
When entering FAULT state, the program dumps signal memory from all modules to numbered fault files for post-mortem analysis. Up to 11 fault files are maintained in a circular buffer (`NUMFFILES`).

### 11.2 rf_calib.st — Calibration Sequences (3,345 lines)

**Author**: R. Claus, P. Corredoura, M. Laznovsky

The largest SNL program. Implements automated calibration procedures for the RF system. Uses extensive C preprocessor macros to reduce code repetition.

**Calibration Sequences**:
- **Octal DAC offset nulling**: Zeros all DAC channels, measures residual, computes offset correction
- **Cavity modulator calibration**: Sets known modulator weights, measures I/Q response, computes coupling matrix
- **RF switch calibration**: Calibrates the signal path through RF switches
- **Multi-cavity support**: Can calibrate individual cavities or all cavities simultaneously
- **DAC linearity verification**: Ramps DAC values, measures output linearity

**Macro Usage**: The program heavily uses C preprocessor macros to parameterize calibration sequences:
```c
#define CALIB_DAC(cavity, component, reg, ...) \
  state calib_##cavity##_##component { ... }
```

### 11.3 rf_tuner_loop.st — Cavity Tuner Control (555 lines)

**Author**: SLAC/PEP-II RF Group

Controls cavity tuner stepper motors for resonant frequency tracking. Runs as **4 concurrent instances** (one per cavity), each parameterized by macros:
```snl
program rf_tuner_loop ("name=C1TUNRLOOP,STN=SRF1,CAV=1")
```

**States**:
- **IDLE**: Tuner loop disabled, waiting for enable command
- **TRACKING**: Actively tracking frequency error, commanding motor moves
- **MOVING**: Motor in motion, waiting for completion
- **SETTLING**: Motor stopped, waiting for frequency to settle

**Control Algorithm**:
- Reads frequency error from IQA measurement
- Computes required tuner motion (steps) based on error and gain
- Commands stepper motor via steppermotorRecord
- Ramps velocity based on error magnitude
- Monitors limit switches and position feedback

### 11.4 rf_hvps_loop.st — HVPS Supervisory Control (343 lines)

Monitors and controls the High Voltage Power Supply via the AB SLC-500 PLC:
- Voltage regulation (setpoint → PLC → SCR gate driver)
- Crowbar arming/monitoring
- Contactor control (close/open high voltage)
- Fault monitoring (overcurrent, overvoltage, cooling, etc.)
- Logging of HVPS events

### 11.5 rf_dac_loop.st — Drive Power and Gap Voltage DAC Loop (290 lines)

Controls the RFP/GVF DAC output levels:
- Drive power ramping (gradual increase for klystron protection)
- Gap voltage regulation
- Sequencing for DAC loading and verification
- Coordination with station state machine

### 11.6 rf_msgs.st — Message Logging and Monitoring (352 lines)

Handles system messaging and monitoring:
- CAMAC TAXI error monitoring (detects communication faults on TAXI serial link)
- General message logging to the EPICS event log
- Periodic heartbeat messaging

---

## 12. IOC Configuration and Runtime

### 12.1 Startup Script (st.cmd)

**File**: `iocBoot/b132-iocrf/st.cmd`

The IOC boot sequence for the SPEAR3 RF station:

```bash
# 1. Load the compiled EPICS application
ld < bin/vxWorks-ppc604_long/rf.munch

# 2. Initialize error logging
errlogInit(5000)

# 3. Set station-specific macros
putenv("DATABASE_MACROS=STN=SRF1")
putenv("C1TUNRLOOP_MACROS=STN=SRF1,CAV=1,name=C1TUNRLOOP")
putenv("C2TUNRLOOP_MACROS=STN=SRF1,CAV=2,name=C2TUNRLOOP")
putenv("C3TUNRLOOP_MACROS=STN=SRF1,CAV=3,name=C3TUNRLOOP")
putenv("C4TUNRLOOP_MACROS=STN=SRF1,CAV=4,name=C4TUNRLOOP")

# 4. Load EPICS database
dbLoadDatabase("dbd/rf.dbd")
rf_registerRecordDeviceDriver(pdbbase)
dbLoadRecords("db/srf1.db")

# 5. Restore saved PV values
dbRestore("spear1", 0, -1)
dbRestore("/sav/savedataSRF1.sav", 0, -1)

# 6. Configure Allen-Bradley
abConfigNlinks(1)
abConfigVme(0, 0xc00000, 0x60, 4)
abConfigScanListAscii(0, getenv("AB_CONFIG_FILE"), 1)

# 7. Configure VXI address space
_EPICS_VXI_LA_BASE  = 0x01   # Starting logical address
EPICS_VXI_LA_COUNT  = 13     # Number of VXI devices
EPICS_VXI_A24_BASE  = 0x00900000  # A24 window start
EPICS_VXI_A24_SIZE  = 0x00100000  # A24 window size (1 MB)
EPICS_VXI_A32_BASE  = 0x90000000  # A32 window start
EPICS_VXI_A32_SIZE  = 0x10000000  # A32 window size (256 MB)

# 8. Start EPICS
iocInit()
```

### 12.2 Database Files

The EPICS database (`srf1.db`) instantiates records for:
- One RFP record (station RF processor)
- One GVF record (gap voltage feed-forward)
- Three IQA records (forward, reflected, cavity)
- One AIM record (arc/interlock)
- One CLK record (clock module)
- One CF2 record (comb filter v2)
- Stepper motor records (4 tuners)
- AB PLC I/O records (HVPS, MPS, stepper modules)
- Subroutine records (I/Q calculations, system-level computations)
- SNL state machine parameter records

### 12.3 AB Configuration File

**File**: `iocBoot/b132-iocrf/config.ab`

Defines the Allen-Bradley scan list — maps AB adapter/rack/slot addresses to VXI IOC data structures. Configures:
- Which AB modules are on the link
- Scan rates for each module
- Block transfer sizes
- I/O types (analog, digital, stepper)

### 12.4 Table Files

**Directory**: `iocBoot/tbl/`

Contains pre-computed waveform and coefficient tables loaded into VXI modules at startup:

| File Pattern | Description |
|-------------|-------------|
| `DRIVE_*_I/Q` | Drive waveform tables (I and Q components) |
| `NOISE_*_I/Q` | Noise injection tables for system identification |
| `SWEEP_*_I/Q` | Frequency sweep tables for transfer function measurement |
| `SINE_I/Q` | Sinusoidal waveform tables |
| `TICKLE_I/Q` | Small-signal excitation tables |
| `iqaDdf_*.rpt` | IQA digital filter definitions (50 Hz, 23 kHz bandwidth) |
| `cfmIirCoefs*.tbl` | Comb filter IIR coefficients |
| `detunEq*.tbl` | Detuning equalizer tables |
| `aimDas*.inst` | AIM data acquisition sequence instructions |

---

## 13. Data Flow Examples

### 13.1 Example: Reading Cavity Forward Power

1. **IQA hardware** digitizes I/Q components of the cavity forward signal at RF frequency
2. **IQA ISR** fires on data-ready interrupt → updates `rec->istt` → calls `scanOnce()`
3. **IQA Action()** reads I and Q registers: `P2RF_ReadVme(drvPvt, IQA_I_xxx, &value)`
4. **EPICS database** links IQA I/Q fields to `subIQ` subroutine records
5. **subIQAmp()**: Computes amplitude = `sqrt(I² + Q²)`
6. **subIQPwrdB()**: Computes power in dBm
7. **subIQPhase()**: Computes phase = `atan2(Q, I) * 180/π`
8. **Channel Access**: Operator display shows forward power and phase

### 13.2 Example: Changing Feedback Loop Mode (STANDBY → ON_CW)

1. **Operator** clicks "RF ON" button → writes to `rf_states.st` enable PV
2. **rf_states.st** transitions from STANDBY to ON_CW state
3. **State code** writes to RFP record fields:
   - `rec->mode = rfpRun` (via `dbPut`)
   - `rec->dle = 1` (enable direct loop)
   - `rec->cle = 1` (enable comb loop)
   - `rec->rle = 1` (enable ripple loop)
   - `rec->dacs = 1` (enable DAC output)
4. **RFP Action()** processes:
   - Reads current `rctl` register
   - Sets `RFP_M_DIRLPENB`, `RFP_M_CMBLPENB`, `RFP_M_RIPLPENB` bits
   - Sets `RFP_M_RFENB` and `RFP_M_MODE` = RUN
   - Writes to hardware: `P2RF_WriteVme(drvPvt, RFP_I_RFCTRL, rctl)`
   - Verifies readback matches
5. **RFP hardware** closes feedback loops → RF output enabled

### 13.3 Example: Tuner Motor Positioning

1. **rf_tuner_loop.st** (instance for cavity 1) reads frequency error from IQA
2. Computes required motor steps based on error magnitude and gain
3. Writes target position to `steppermotorRecord`
4. **steppermotorRecord** calls `devSmAB1746HSTP1` device support
5. **devSmAB1746HSTP1** formats AB block transfer command
6. **drvAb** sends command over serial link to 1746-HSTP1 module
7. **HSTP1 module** drives stepper motor (Slo-Syn M093) to target position
8. **rf_tuner_loop.st** monitors done status, verifies position reached

---

## Appendix A: Complete File Inventory

### Device Support & Custom Records (rfApp/src/db/)

| File | Lines | Type |
|------|-------|------|
| drvP2RfVxi.c | 2,671 | Core VXI driver |
| drvP2RfVxi.h | ~300 | Core VXI driver header |
| devP2RfRfp.c | 2,389 | RFP device support |
| devP2RfGvf.c | 2,350 | GVF device support |
| devP2RfIqa.c | 2,260 | IQA device support |
| devP2RfAim.c | 1,982 | AIM device support |
| devP2RfCf2.c | 2,970 | CF2 device support |
| devP2RfCfm.c | 1,487 | CFM device support |
| devP2RfClk.c | 957 | CLK device support |
| p2RfRfpDef.h | 495 | RFP register definitions |
| p2RfIqaDef.h | 509 | IQA register definitions |
| p2RfCf2Def.h | 403 | CF2 register definitions |
| p2RfAimDef.h | 390 | AIM register definitions |
| p2RfGvfDef.h | 330 | GVF register definitions |
| p2RfCfmDef.h | 279 | CFM register definitions |
| p2RfClkDef.h | 271 | CLK register definitions |
| p2RfRfpRecord.c | 296 | RFP record implementation |
| p2RfGvfRecord.c | 307 | GVF record implementation |
| p2RfIqaRecord.c | 301 | IQA record implementation |
| p2RfAimRecord.c | 300 | AIM record implementation |
| p2RfClkRecord.c | 299 | CLK record implementation |
| p2RfCf2Record.c | 366 | CF2 record implementation |
| p2RfCfmRecord.c | 334 | CFM record implementation |
| p2RfLib.h | ~200 | Shared library definitions |
| subIQ.c | 965 | I/Q signal processing subroutines |
| subSys.c | 464 | System-level subroutines |

### SNL Programs (rfApp/src/seq/)

| File | Lines | Description |
|------|-------|-------------|
| rf_states.st | 2,227 | RF station state machine |
| rf_calib.st | 3,345 | Calibration sequences |
| rf_tuner_loop.st | 555 | Tuner motor control (×4 instances) |
| rf_hvps_loop.st | 343 | HVPS supervisory |
| rf_msgs.st | 352 | Message logging |
| rf_dac_loop.st | 290 | DAC loop control |

### DSP Firmware (rfApp/src/dsp/)

| Directory | Total Lines | Key Files |
|-----------|-------------|-----------|
| rfpDsp/ | ~4,600 | ripple.s, sp3ripple.s, lusqrt.s, sqlu.s, ramping.s, comBlk.s |
| gvfDsp/ | ~2,400 | gvff.s, wave_out.s |
| obsDsp/ | ~2,500 | (observer, adaptive filter, arctangent) |
| genDsp/ | ~900 | (shared trig, sqrt utilities) |

### Allen-Bradley Drivers (allenBradley/)

| File/Directory | Lines | Description |
|---------------|-------|-------------|
| basicSrc/drvAb.c | 2,039 | Core AB serial driver |
| 1746HSTP1Src/devSmAB1746HSTP1.c | 1,673 | Stepper motor module |
| 1771DCMSrc/ | ~2,000 | PLC-5 scanner (ai, ao, bi, bo, mbbi, mbbo, li, lo) |
| SLCDCMSrc/ | ~1,500 | SLC-500 device support |

### VXI Infrastructure (epvxi/)

| File | Lines | Description |
|------|-------|-------------|
| drvEpvxi.c | 4,622 | VXI resource manager |
| drvEpvxiMsg.c | 1,529 | VXI message protocol |
| epvxi.h | 532 | VXI framework API |

### Stepper Motor (stepper/)

| File | Lines | Description |
|------|-------|-------------|
| steppermotorRecord.c | 959 | Custom stepper motor record |
| drvCompuSm.c | 872 | Compumotor driver backend |
| drvOms.c | 705 | Oregon Micro Systems driver backend |

### Base Utilities (rfApp/src/base/)

| File | Lines | Description |
|------|-------|-------------|
| vbb.c | 2,398 | VXI Bus Browser utility |
| dlt.c | 1,008 | Download Table utility |
| bus.c | 855 | Bus access routines |
| sgl.c | 731 | Signaling/messaging library |
| lip.c | 582 | Load In Place utility |
| dld.c | 575 | Download DSP utility |
| initModule.c | ~200 | Module initialization |
| rfBaseRegister.c | ~200 | Base registration functions |
| time.c | ~280 | Time utilities |
| dspCmdDef.h | 65 | DSP command definitions |
| dspLib.h | ~300 | DSP library header |
| hbLib.h | ~280 | Heartbeat library |
| modTypes.h | ~160 | Module type definitions |
| (40+ additional headers) | | Various interface definitions |

---

*End of Technical Report*

