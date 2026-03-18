# SPEAR3 Low-Level RF Control System — Legacy Codebase Technical Report

**Repository:** `rf-spear-legacy/`  
**Report Date:** 2026-03-18  
**Purpose:** Comprehensive technical reference for AI-assisted system upgrade design  
**Last Software Release:** RF-SPEAR-R0-3-2 (Sept 2020, force-tagged through Jun 2021)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Overview](#2-system-overview)
3. [Hardware Architecture](#3-hardware-architecture)
4. [Firmware & DSP](#4-firmware--dsp)
5. [Software Architecture](#5-software-architecture)
6. [Control System Design](#6-control-system-design)
7. [Signal Processing](#7-signal-processing)
8. [External Interfaces](#8-external-interfaces)
9. [Operational Characteristics](#9-operational-characteristics)
10. [Upgrade Considerations](#10-upgrade-considerations)
11. [Appendices](#11-appendices)

---

## 1. Executive Summary

This report documents the complete legacy Low-Level RF (LLRF) control system for the SPEAR3 synchrotron light source at SLAC National Accelerator Laboratory. The system was originally designed for the PEP-II B-Factory (1995–1996) by R. Claus, S. Allison, and colleagues in the SLAC PEP-II RF Group, and was later adapted for SPEAR3 operation.

The system controls a 476 MHz RF station (SRF1) with 4 superconducting cavities via a VME/VXI crate containing custom SLAC-designed VXI modules. The software runs on EPICS 3.14.x over VxWorks RTOS on a Motorola PowerPC 604 single-board computer. Real-time RF feedback is performed by embedded WE DSP1610 processors on the VXI modules, while higher-level control loops, state management, and operator interface are handled by EPICS sequences and database records.

**Key upgrade drivers:**
- All custom VXI hardware is 25+ years old with no spare parts manufacturing capability
- DSP1610 processors are obsolete (~30 years old)
- VxWorks 5.4 and EPICS 3.14.x are legacy platforms
- The system has no modern network protocols (no pvAccess), limited diagnostics, and relies on obsolete Allen-Bradley PLC I/O modules

This report captures the full technical detail needed to design a replacement system while preserving all critical control functionality.

---

## 2. System Overview

### 2.1 Historical Context

| Aspect | Detail |
|--------|--------|
| Original facility | PEP-II B-Factory at SLAC |
| Original designers | R. Claus, S. Allison, R. Sass, M. Laznovsky, M. Zelazny, K. Luchini |
| Design period | 1994–1997 |
| Adapted for SPEAR3 | ~2004–2012 |
| Latest release | RF-SPEAR-R0-3-2 (2020) |
| Source control | CVS (RCS `,v` files) |
| Copyright | Board of Trustees, Leland Stanford Junior University |

### 2.2 Physical Installation

- **Location:** Building 132, SLAC National Accelerator Laboratory
- **IOC name:** B132-IOCRF
- **Crate:** 13-slot VXI/VME crate (Elma manufacturer), location B132-101-11-24
- **Network:** Connected to SPEAR3 controls subnet (134.79.33.x); uses AFS file system for EPICS distribution

### 2.3 RF System Parameters

| Parameter | Value |
|-----------|-------|
| RF frequency | 476 MHz |
| Harmonic number (SPEAR3) | 372 |
| Harmonic number (PEP-II) | 3,492 |
| Number of RF stations | 1 (SRF1) |
| Number of cavities per station | 4 |
| Sampling factor | 72 (10 MHz effective) |
| Station PV prefix | `SRF1:` |

### 2.4 High-Level Signal Flow

```
RF Reference (476 MHz)
       │
       ▼
  ┌─────────┐
  │  CLK    │ Clock & RF Distribution Module
  │(340-306)│ - Distributes reference to all modules
  └────┬────┘
       │
       ▼
  ┌─────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
  │  RFP    │────>│Modulator │────>│ Klystron │────>│ Cavities │
  │(340-304)│     │  (I/Q)   │     │  (HV)    │     │(4 cells) │
  │ DSP1610 │     └──────────┘     └──────────┘     └─────┬────┘
  │ DACs    │                                             │
  └────▲────┘                                      Cavity Pickups
       │                                                  │
       │          ┌──────────┐                            │
       │          │  GVF     │ Gap Voltage Feed Forward   │
       │          │(340-305) │<───────────────────────────┤
       │          └──────────┘                            │
       │                                                  │
       │          ┌──────────┐                            │
       │          │  IQA     │ I/Q & Amplitude Detector   │
       │          │(340-302) │<───────────────────────────┤
       │          │ x2 or x3 │                            │
       │          └────┬─────┘                            │
       │               │                                  │
       │         I/Q Data                                 │
       │               │                                  │
       │    ┌──────────▼──────────┐                       │
       │    │   EPICS Database    │                       │
       │    │   subIQ.c / subSys.c│                       │
       │    │   State Machines    │                       │
       │    └──────────┬──────────┘                       │
       │               │                                  │
       └───────────────┘                                  │
                                                          │
  ┌─────────┐     ┌──────────┐                            │
  │  CF2    │     │  AIM     │ Arc Detect/Fast Interlock  │
  │(340-301)│     │(340-307) │<───────────────────────────┘
  │Comb Filt│     └──────────┘
  └─────────┘

  ┌─────────────────┐     ┌──────────────────┐
  │ Allen-Bradley   │     │ Stepper Motors   │
  │ PLC (1771 DCM)  │     │ (Compumotor/OMS) │
  │ Digital/Analog  │     │ Cavity Tuners    │
  └─────────────────┘     └──────────────────┘
```

---

## 3. Hardware Architecture

### 3.1 VME/VXI Crate Configuration

| Slot | Module | EPICS Name | Description |
|------|--------|------------|-------------|
| 0 | MVME2400 (PowerPC 604) | B132-IOCRF | IOC - VxWorks RTOS host |
| 1 | Allen-Bradley 1771 Scanner | — | PLC I/O scanner |
| 2 | CLK (340-306) | `SRF1:STN:CLK` | Clock & RF Distribution |
| 3 | *(empty)* | — | — |
| 4 | RFP (340-304) | `SRF1:STN:RFP` | RF Processing (DSP1610) |
| 5 | MPS Shutoff | — | Machine Protection interlock |
| 6 | Link Passthru | — | VXI link passthrough |
| 7 | IQA1 (340-302) | `SRF1:STN:IQA1` | I/Q Amplitude Detector #1 |
| 8 | *(empty)* | — | — |
| 9 | IQA2 (340-302) | `SRF1:STN:IQA2` | I/Q Amplitude Detector #2 |
| 10 | *(empty)* | — | — |
| 11 | IQA3 (340-302) | `SRF1:STN:IQA3` | I/Q Amplitude Detector #3 |
| 12 | AIM (340-307) | `SRF1:STN:AIM` | Arc Interlock Module |

> **Source:** `rfApp/DbIoc/srf1.substitutions,v`

### 3.2 IOC Platform

| Component | Specification |
|-----------|--------------|
| CPU Board | Motorola MVME2400-series |
| Processor | PowerPC 604 |
| RTOS | VxWorks 5.4 / RTEMS 4.9.x |
| EPICS Version | 3.14.8.2 → 3.14.11 |
| Boot method | NFS boot from `/afs/slac/g/spear/epics/...` |
| VME address spaces | A16 (VXI CSR), A24 (module extended), A32 (large memory) |
| Interrupt level | 5 (default, configurable via `P2RfIntLevel`) |

### 3.3 VXI Module Inventory

All SLAC PEP-II RF VXI modules share:
- **VXI Manufacturer ID:** `0xF00` (SLAC PEP-II RF)
- **Bus:** VXI C-size (VMEbus backplane + P2 VXI extensions)
- **Address:** A16 for configuration registers, A24/A32 for extended memory
- **Common driver:** `drvP2RfVxi.c` discovers all modules by manufacturer ID

#### 3.3.1 RFP — RF Processing Module

| Property | Value |
|----------|-------|
| Model ID | `0x103` |
| Drawing | 340-304 |
| Full Name | RF-Processing |
| DSP | WE DSP1610 embedded processor |
| Key Functions | I/Q DAC generation, direct loop feedback, comb loop, RF enable, run mode, octal DAC calibration |
| Number of cavities supported | 4 |
| A16 Registers | MANID, MODELNO, STATUS/CONTROL, OFFSET, ATTRIBUTE, SERIALHI/LO, VERSION, INTSTAT, INTCTRL, SUBCLASS, RFCTRL, RFSTAT |
| Key control bits | RFENABLE, RUNMODE (tune/operate), DIRECTLOOP, COMBLOOP, LEADCOMP, INTCOMP, DACS on/off, single-shot/continuous |
| Memory buffers | 4 per station (I/Q sine/cosine reference waveforms) |
| DSP communication | Shared memory command/response protocol |
| HW versions | Version 2+ adds additional registers |

> **Source:** `rfApp/src/db/p2RfRfpDef.h,v`, `devP2RfRfp.c,v`, `p2RfRfpRecord.c,v`

#### 3.3.2 IQA — I/Q & Amplitude Detector

| Property | Value |
|----------|-------|
| Model ID | `0x102` |
| Drawing | 340-302 |
| Full Name | I/Q & A Detector |
| Channels | 8 per module |
| Key Functions | I/Q detection, amplitude measurement, history buffer, ripple compensation |
| History memory | 512 words per channel |
| Ripple channel | Channel 0 |
| HW versions | Version 3+ has different SSI/STI channel mapping |
| Invalid I/Q value marker | `0x8000` |
| Instances | 2–3 per station (IQA1, IQA2, IQA3) |

> **Source:** `rfApp/src/db/p2RfIqaDef.h,v`, `devP2RfIqa.c,v`, `p2RfIqaRecord.c,v`

#### 3.3.3 GVF — Gap Voltage Feed Forward

| Property | Value |
|----------|-------|
| Model ID | `0x105` |
| Drawing | 340-305 |
| Full Name | Gap Voltage Feed Forward |
| Key Functions | GFF loop, LFB loop, I/Q reference generation, gap voltage feed-forward |
| Key record fields | GFFLOOP, LFBLOOP, I/Q reference values |

> **Source:** `rfApp/src/db/p2RfGvfDef.h,v`, `devP2RfGvf.c,v`, `p2RfGvfRecord.c,v`

#### 3.3.4 CLK — Clock & RF Distribution

| Property | Value |
|----------|-------|
| Model ID | `0x106` |
| Drawing | 340-306 |
| Full Name | Clock & RF Distribution |
| Key Functions | 476 MHz reference distribution, timing synchronization, ring configuration ID |
| Configuration ID | Distinguishes PEP-II (3492 harmonics) from SPEAR3 (372 harmonics) |
| Resync command | Available via `RSYN` field |

> **Source:** `rfApp/src/db/p2RfClkDef.h,v`, `devP2RfClk.c,v`, `p2RfClkRecord.c,v`

#### 3.3.5 AIM — Arc Interlock Module

| Property | Value |
|----------|-------|
| Model ID | `0x107` |
| Drawing | 340-307 |
| Full Name | Arc Detector / Fast Interlock |
| Channels | 7 (version 1) or 12 (version 2+) |
| Key Functions | Arc detection, beam abort control, fast interlock trip, HVPS permissive, fault history |
| Key commands | Force Beam Abort (FBA), Reset Beam Abort (RBA), Reset Faults (RSTF) |
| History buffer | Available for fault file dumps |

> **Source:** `rfApp/src/db/p2RfAimDef.h,v`, `devP2RfAim.c,v`, `p2RfAimRecord.c,v`

#### 3.3.6 CF2/CFM — Comb / Group Delay Equalizer

| Property | Value |
|----------|-------|
| Model ID | `0x101` |
| Drawing | 340-301 (CFM original), newer CF2 version |
| Full Name | Comb/Group Delay Equalizer |
| Key Functions | Comb filtering for coupled-bunch instability suppression, I/Q history recording |
| Versions | CFM (original, 2 instances per station) → CF2 (newer, single instance with I/Q channels) |
| Compilation flag | `#define CF2` selects CF2 vs old CFM code paths |

> **Source:** `rfApp/src/db/p2RfCf2Def.h,v`, `p2RfCfmDef.h,v`

### 3.4 Allen-Bradley PLC I/O

The system uses Allen-Bradley 1771-series I/O modules interfaced via a DCM (Data Communications Module) scanner:

| Component | Description |
|-----------|-------------|
| Scanner | AB 1771 DCM scanner in VXI slot 1 |
| Configuration | `iocBoot/b132-iocrf/config.ab` |
| EPICS driver | `allenBradley/` — custom EPICS driver supporting 1771DCM, 1746HSTP1, 1791 Block I/O |
| Functions | Digital interlocks, HVPS contactor status, temperature readbacks, vacuum interlocks, panel on/off switch |
| AB driver source | `allenBradley/allenBradleyApp/` with device support for ai, ao, bi, bo, li, lo, mbbi, mbbo record types |

> **Source:** `allenBradley/` directory, `rfApp/src/db/subSys.c,v` (`subSysABreset`)

### 3.5 Stepper Motor Controllers (Cavity Tuners)

| Component | Description |
|-----------|-------------|
| Motor types | Compumotor 1830, OMS 6-Axis |
| Purpose | Cavity tuner positioning for resonant frequency control |
| Number | 4 (one per cavity: C1–C4) |
| Control | Per-cavity reentrant SNL sequence `rf_tuner_loop.st` |
| Position feedback | Potentiometer (analog) + stepper motor encoder |
| EPICS driver | `stepper/` directory with `devSmCompumotor1830.c`, `devSmOms6Axis.c`, `drvCompuSm.c`, `drvOms.c` |

### 3.6 VXI-VME Bus Adapter

| Component | Description |
|-----------|-------------|
| Adapter | KSC (Kinetic Systems) V152 |
| Purpose | VXI-to-VME bridge connecting VXI modules to VME backplane |
| PLDs | Custom programmable logic in `rfApp/ksc_v152/PLDs/` |
| Configuration | Logical address base = 0x01, count = 13 devices |
| A24 window | Base 0x00900000, Size 0x00100000 |
| A32 window | Base 0x90000000, Size 0x10000000 |

> **Source:** `iocBoot/b132-iocrf/st.cmd,v`, `rfApp/ksc_v152/`


---

## 4. Firmware & DSP

### 4.1 DSP1610 Architecture

The RFP and IQA modules contain embedded WE (AT&T/Lucent) DSP1610 digital signal processors. These perform the real-time RF feedback computations at hardware clock rates, independent of the EPICS IOC scan rates.

| Property | Value |
|----------|-------|
| DSP family | WE DSP16xx (AT&T/Lucent) |
| Word size | 16-bit fixed-point |
| External RAM | 8K–16K words (configurable: `DSP_K_ESIZE`) |
| External RAM base | `0x8000` (`DSP_A_ERAM`) |
| Assembly tools | `as1600` (assembler), `ld1600` (linker), `ar1600` (archiver), `cpp16` (preprocessor) |
| Tool location | `dsp1610/` directory |

> **Source:** `dsp1610/`, `rfApp/src/base/DSP.h,v`, `rfApp/src/dsp/`

### 4.2 DSP Programs (per module type)

Three distinct DSP program variants exist:

| DSP Type | Directory | Purpose |
|----------|-----------|---------|
| **genDsp** | `rfApp/src/dsp/genDsp/` | General-purpose DSP definitions |
| **gvfDsp** | `rfApp/src/dsp/gvfDsp/` | GVF module DSP (gap feed-forward, GFF/LFB) |
| **rfpDsp** | `rfApp/src/dsp/rfpDsp/` | RFP module DSP (RF processing, direct/comb loop) |
| **obsDsp** | `rfApp/src/dsp/obsDsp/` | Observer DSP |

Each DSP program directory contains header files defining:
- **aucDef.h** — Auxiliary channel definitions
- **bioDef.h** — Binary I/O port definitions
- **comDef.h** — Communication area definitions
- **dspDef.h** — DSP parameter definitions
- **intDef.h** — Interrupt vector definitions
- **pioDef.h** — Parallel I/O definitions
- **sttDef.h** — State/status definitions
- **timDef.h** — Timer definitions
- **funcs.h** — DSP function declarations

### 4.3 Command/Response Protocol

The IOC communicates with the DSP via a shared-memory mailbox structure (`DspComBlk`) in the module's extended address space:

```c
typedef struct _DspComBlk {
    volatile unsigned short  blkId;      // Block identification
    volatile unsigned short  vers;       // Version
    volatile unsigned short  chkSum;     // Checksum
    volatile unsigned short  status;     // DSP status
    volatile unsigned short  sttArg[];   // State arguments
    volatile unsigned short  dspMsg;     // Message from DSP to CPU
    volatile unsigned short  dspArg;     // Argument for DSP message
    volatile unsigned short  cpuMsg;     // Command from CPU to DSP
    volatile unsigned short  cpuArg;     // Argument for CPU command
    volatile unsigned short  comLen;     // Communication block length
} DspComBlk;
```

**DSP Commands (CPU → DSP):**

| Command | Value | Description |
|---------|-------|-------------|
| `CMD_K_NOOP` | 0x0000 | No operation |
| `CMD_K_READY` | 0x0001 | DSP reports ready |
| `CMD_K_TEST` | 0x0002 | Test command |
| `CMD_K_ERROR` | 0x0003 | DSP error condition |
| `CMD_K_LDTBL` | 0x0004 | Load coefficient tables |
| `CMD_K_SVDATA` | 0x0005 | Save ERAM data |
| `CMD_K_APHASE` | 0x0006 | Save average phase |
| `CMD_K_LDREF` | 0x0007 | Load reference tables |
| `CMD_K_UREF` | 0x0008 | Update reference tables |
| `CMD_K_AMSP` | 0x000a | Update Ripple Amplitude Setpoint |
| `CMD_K_PHSG` | 0x000b | Update Ripple DC Z⁻¹ Phase Gain |
| `CMD_K_DACO` | 0x000c | Load Ripple II/IQ/QI/QQ DAC offsets |
| `CMD_K_PHARM` | 0x000d | Ripple Phase Harmonic coefficients |
| `CMD_K_AHARM` | 0x000e | Ripple Amplitude Harmonic coefficients |
| `CMD_K_DONE` | 0xFFFF | Operation complete |

> **Source:** `rfApp/src/dsp/genDsp/dspCmdDef.h,v`, `rfApp/src/db/devP2RfRfp.c,v`

### 4.4 Coefficient and Table Loading

The driver supports loading several types of data to the DSP:

| Function | Purpose | Source |
|----------|---------|--------|
| `P2RF_LoadConsts` | Load constant tables to DSP memory | `drvP2RfVxi.c` |
| `P2RF_LoadCoefs` | Load filter coefficients with float→fixed conversion | `drvP2RfVxi.c` |
| `P2RF_LoadDdf` | Load Digital Decimation Filter parameters (F, FC, H1, H2 registers) | `drvP2RfVxi.c` |
| `P2RF_LoadDsp` | Download DSP executable code | `drvP2RfVxi.c` |
| `P2RF_LoadTblFile` | Load data table from file | `drvP2RfVxi.c` |
| `P2RF_LoadRegFile` | Load register values from file | `drvP2RfVxi.c` |

**Digital Decimation Filter (DDF) Structure:**

```c
typedef struct {
    int             fcCnt;      // Coefficient count, 1-257
    unsigned short  f;          // F_REGISTER (taps, decimation rate, bypass, etc.)
    P2RfFc          fc[257];    // Max 512 taps => 257 coefs
    unsigned short  h1;         // H_REGISTER1 (CIC decimation, bypass, etc.)
    unsigned short  h2;         // H_REGISTER2 (CIC stages, growth)
} P2RfDdf;
```

### 4.5 Real-Time Loop Rates and Timing

The DSP-level feedback loops (direct loop, comb filter) operate at hardware clock rates derived from the 476 MHz RF:

| Parameter | Formula | SPEAR3 Value |
|-----------|---------|--------------|
| Revolution frequency | f_RF / h | 476 MHz / 372 ≈ 1.28 MHz |
| DSP sample rate | (f_rev × 4 × sampling_factor) / h | ~10 MHz effective |
| ns per sample | `P2RF_K_NSPERSAMP(i)` | Derived from harmonic number |

> **Upgrade Requirement:** Any replacement must match or exceed these real-time rates for the inner feedback loops. The direct loop bandwidth is critical for beam stability.

---

## 5. Software Architecture

### 5.1 EPICS Version and Build System

| Component | Version/Tool |
|-----------|-------------|
| EPICS Base | 3.14.8.2 → 3.14.11 |
| SNCSEQ | seq-R2-0-13-spear1 |
| iocStats | iocStats-R3-1-12-spear1 |
| Restore | restore-R1-0-2 |
| Build system | EPICS standard `configure/` + Makefiles |
| Target arch | vxWorks-ppc604_long |
| Source control | CVS → Git (current repository) |

> **Source:** `configure/RELEASE,v`

### 5.2 Architectural Layers

```
┌──────────────────────────────────────────────────────┐
│  Layer 6: Operator Interface (MEDM/EDM Displays)     │
├──────────────────────────────────────────────────────┤
│  Layer 5: EPICS Database (Templates & Substitutions) │
│  - rf_stn.db, rf_cav.db, rf_hvps.db, rf_klys.db ... │
├──────────────────────────────────────────────────────┤
│  Layer 4: State Machine Sequences (SNL/SNC)          │
│  - rf_states.st, rf_tuner_loop.st, rf_hvps_loop.st  │
│  - rf_dac_loop.st, rf_calib.st, rf_msgs.st          │
├──────────────────────────────────────────────────────┤
│  Layer 3: Subroutine Records                         │
│  - subIQ.c (I/Q processing)                          │
│  - subSys.c (system calculations)                    │
├──────────────────────────────────────────────────────┤
│  Layer 2: Custom EPICS Records + Device Support      │
│  - p2RfRfpRecord, p2RfIqaRecord, p2RfGvfRecord      │
│  - p2RfClkRecord, p2RfAimRecord, p2RfCf2Record      │
│  - devP2Rf*.c (device support for each module)       │
├──────────────────────────────────────────────────────┤
│  Layer 1: VXI Driver (drvP2RfVxi.c)                  │
│  - Module discovery, address mapping, ISR routing    │
│  - DSP loading, coefficient management               │
├──────────────────────────────────────────────────────┤
│  Layer 0: EPICS Base + VxWorks + VME/VXI Hardware    │
│  - epvxi driver, Allen-Bradley driver, stepper driver│
└──────────────────────────────────────────────────────┘
```

### 5.3 VXI Driver (`drvP2RfVxi.c`)

The central hardware abstraction layer. Key data structures:

```c
// Per-module private data
typedef struct _P2RfPvt {
    P2RfBlk              *blk;      // Driver block
    int                   la;       // Logical address
    P2RfModel             model;    // Module model info
    volatile VXICSR      *csr;      // VXI CSR pointer
    volatile P2RfDevDep  *devDep;   // Device-dependent registers
    vxi16_t              *ext;      // Extended address space pointer
    FAST_LOCK             lock;     // Mutual exclusion
    void                (*isrRtn)();// ISR callback
    void                 *isrArg;   // ISR argument
    void                (*sdRtn)(); // Shutdown callback
    void                 *sdArg;    // Shutdown argument
    int                   sharedCnt;// Shared client count
    SEM_ID                shrSem;   // Circular buffer semaphore
} P2RfPvt;
```

**Driver initialization flow:**
1. `P2RF_Init()` → Called by EPICS driver table during `iocInit`
2. Installs reboot hook (`P2RF_Shutdown`)
3. Allocates driver block, gets unique driver ID from `epvxiUniqueDriverID()`
4. Calls `epvxiLookupLA()` with search pattern `{VXI_DSP_make, 0xF00}` to discover all SLAC RF modules
5. For each module: `P2RF_InitModule()` → `epvxiOpen()`, maps A16/A24/A32 spaces, initializes mutual exclusion lock
6. Supports cold start (full hardware init) and warm start (preserve hardware state after reboot)

**Key driver API:**

| Function | Purpose |
|----------|---------|
| `P2RF_RegisterModule` | Register a VXI module with the driver |
| `P2RF_RegisterClient` | Register a client (shared module access) |
| `P2RF_IntEnable/Disable` | Global interrupt control |
| `P2RF_ModIntEnable/Disable` | Per-module interrupt control |
| `P2RF_ReadVme/WriteVme` | VME register read/write |
| `P2RF_LoadConsts/Coefs/Ddf` | Load data to DSP |
| `P2RF_LoadDsp` | Download DSP firmware |
| `P2RF_CopyMemory` | Copy memory blocks |
| `P2RF_RecordMemory` | Record (snapshot) module memory for fault analysis |
| `P2RF_DspFindComBlk` | Find DSP communication block in module memory |
| `P2RF_SaveDspMemory` | Save DSP memory to file |

> **Source:** `rfApp/src/db/drvP2RfVxi.c,v`, `drvP2RfVxi.h,v`

### 5.4 Custom Record Types

Six custom EPICS record types, all built into the `rfDb` library:

| Record Type | Module | Source Files |
|-------------|--------|-------------|
| `p2RfRfpRecord` | RFP (RF Processing) | `p2RfRfpRecord.c`, `devP2RfRfp.c`, `p2RfRfpDef.h` |
| `p2RfIqaRecord` | IQA (I/Q Amplitude) | `p2RfIqaRecord.c`, `devP2RfIqa.c`, `p2RfIqaDef.h` |
| `p2RfGvfRecord` | GVF (Gap Voltage FF) | `p2RfGvfRecord.c`, `devP2RfGvf.c`, `p2RfGvfDef.h` |
| `p2RfClkRecord` | CLK (Clock Dist.) | `p2RfClkRecord.c`, `devP2RfClk.c`, `p2RfClkDef.h` |
| `p2RfAimRecord` | AIM (Arc Interlock) | `p2RfAimRecord.c`, `devP2RfAim.c`, `p2RfAimDef.h` |
| `p2RfCf2Record` | CF2 (Comb Filter V2) | `p2RfCf2Record.c`, `devP2RfCf2.c`, `p2RfCf2Def.h` |

Each record type follows the EPICS pattern:
1. **Record definition** (`.h,v`): Register maps, constants, hardware parameters
2. **Record support** (`Record.c,v`): RSET with `InitRecord` and `Process` entry points
3. **Device support** (`dev*.c,v`): Hardware I/O via `drvP2RfVxi` driver

The records are "fat" records with many custom fields that map directly to hardware registers and computed values. They are processed periodically and on-demand to read/write hardware.

### 5.5 Subroutine Records

#### 5.5.1 I/Q Processing (`subIQ.c`)

Contains ~20 calculation routines called by EPICS subroutine records:

| Function | Purpose | Key I/O |
|----------|---------|---------|
| `subIQphase` | Phase from I/Q with offset | A=I, B=Q, C=offset → VAL=phase (deg) |
| `subIQampl` | Amplitude from dB gain | A=gain(dB), B/C/F=offsets, D=divisor, E=conversion → VAL=amplitude(counts) |
| `subIQampl2conv` | Reference amplitude → conversion constant | A=ref_ampl, C=gap_voltage, E=direct_gain → VAL=counts/kV |
| `subIQamplStn` | Total station gap voltage | Combines per-cavity values |
| `subIQamplCplg` | Cavity coupling factor | From amplitude ratios |
| `subIQampl2loss` | Conversion loss calculation | |
| `subIQampl2iq` | Amplitude → I/Q components | |
| `subIQpower` | Power/amplitude calculation | |
| `subIQpowerNet` | Net power calculation | |
| `subIQpowerEff` | Klystron efficiency | |
| `subIQpower2gain` | Gain from power ratio | |
| `subIQdac` | Calculate II/IQ/QI/QQ DAC values | |
| `subIQcounts` | Error → delta counts | |
| `subIQcorrected` | Directivity correction | |
| `subIQscaled` | Scaled I/Q calculation | |

**Key constants:**
- `SUBIQ_PI = 3.14159265359`
- `SUBIQ_IQ2VOLTS = 2.0/65535.0` (16-bit ADC to volts)
- Timeout: `SUBIQGET_TMO = sysClkRateGet()/5` (200 ms)

> **Source:** `rfApp/src/db/subIQ.c,v`

#### 5.5.2 System Calculations (`subSys.c`)

| Function | Purpose | Key I/O |
|----------|---------|---------|
| `subSysFreqOff` | Cavity frequency offset estimation | Position, polynomial coefficients, temperature → kHz |
| `subSysFreqOAvg` | Average cavity frequency offset | |
| `subSysFreqErr` | Cavity park frequency error | |
| `subSysPhaseTot` | Direct loop phase calculation | |
| `subSysPhaseCmb` | Comb loop phase calculation | |
| `subSysPhaseStn` | Station phase calculation | |
| `subSysDCcoeff` | Ripple loop DC coefficient | |
| `subSysDrivSel` | Drive power setpoint selection | |
| `subSysLog` | Logarithmic value calculation | |
| `subSysABreset` | Allen-Bradley PLC reset | Calls `ab_reset()` |

**Frequency offset model:**
```
offset = p0 + p1*Δx + p2*Δx² + p3*Δx³ + t1*V²
```
Where Δx = tuner_current_position - tuner_home_position, V = cavity voltage.

Smoothing: `smoothed = raw * (1-L) + previous * L` (L = smoothing factor, 0-1)

> **Source:** `rfApp/src/db/subSys.c,v`

### 5.6 State Machines (SNL)

All state machines are written in EPICS State Notation Language (SNL/SNC) and compiled to C.

#### 5.6.1 Station State Machine (`rf_states.st`)

**The central control program.** ~2,400 lines. Manages the RF station through 5 operating states.

**State Transition Matrix:**

| From ↓ \ To → | OFF | PARK | TUNE | ON_FM | ON_CW |
|----------------|-----|------|------|-------|-------|
| **OFF** | — | ✓ | ✓ | ✓ | ✓ |
| **PARK** | ✓ | — | ✗ | ✗ | ✗ |
| **TUNE** | ✓ | ✗ | — | ✗ | ✓ |
| **ON_FM** | ✓ | ✗ | ✓ | — | ✗ |
| **ON_CW** | ✓ | ✗ | ✓ | ✗ | — |

**State definitions:**
```c
#define STATION_OFF     0  // RF off, HVPS off
#define STATION_PARK    1  // Tuners parked, HVPS off
#define STATION_TUNE    2  // Tune mode, HVPS on, cavity resonance tuning
#define STATION_ON_FM   3  // FM modulation mode (frequency sweep)
#define STATION_ON_CW   4  // CW operation (normal beam delivery)
```

**States and their detailed behavior:**

| State | Name | Purpose | Entry Actions |
|-------|------|---------|---------------|
| `s_init` | Initialize | Setup on boot | Get current state, clear event flags, init variables |
| `s_off` | Off | Station idle | Monitor for operator commands; check for auto-reset |
| `s_park` | Park | Tuners parked | Only transition to OFF allowed |
| `s_tune` | Tune | Cavity tuning | Transitions to OFF or ON_CW |
| `s_on_fm` | FM mode | Frequency sweep | Transitions to OFF or TUNE |
| `s_on_cw` | CW mode | Normal operation | Direct/comb/GFF loops, tickle beam |
| `s_go_off` | Going OFF | Shutdown sequence | Ramp HVPS down, turn off RF, zero references, write fault files |
| `s_go_stn_reset` | Auto Reset | Fault recovery | Multiple retry attempts with configurable count |
| `s_go_park` | Going PARK | Park sequence | DACs off, tuners to park position, reset beam abort |
| `s_go_tune` | Going TUNE | Tune startup | Clock resync, set tune mode, HVPS on |
| `s_go_on_fm` | Going ON_FM | FM startup | DAC reset/load, load I/Q frequency files |
| `s_go_on_cw` | Going ON_CW | CW startup | DAC reset/load/run, set I/Q reference, set operate mode |

**Fault handling:** 
- `fault_stnoff` summary drives transition to OFF from any active state
- `fault_noon` prevents transitions from OFF to active states  
- `contactor_noon` prevents auto-reset if contactor is bad
- Up to 15 fault records with timestamps (`ftimes[0..14]`)
- 11 fault data files written per fault event (RFP I/Q, CF2 I/Q, IQA1/2 amplitude, GVF, AIM)

**Auto-reset logic:**
- Configurable retry count (`reset_count`)
- Waits for vacuum pump-down if vacuum errors detected (600 ticks = 10 seconds)
- 300-tick (5-second) delay between reset attempts
- Restores previous state on success; goes to OFF on failure

**Parallel state sets managed by this sequence:**
- Direct loop on/off (`directlp_ef` event flag)
- Lead compensation on/off (`leadcomp_ef`)  
- Integral compensation on/off (`intcomp_ef`)
- Comb loop on/off (`comblp_ef`)
- GFF loop on/off (`gfflp_ef`)
- LFB loop on/off (`lfblp_ef`)
- Tickle beam on/off (in ON_CW state)

> **Source:** `rfApp/src/seq/rf_states.st,v`

#### 5.6.2 Tuner Loop (`rf_tuner_loop.st`)

Reentrant per-cavity sequence (4 instances: C1–C4).

**States:** `loop_init` → `loop_unknown` → `loop_off` / `loop_on` / `loop_reset`

**Key behavior:**
- Reads phase error from database (calculated by `subIQphaseErr`)
- Converts phase error to stepper motor position delta (via `subIQphase2posn`)
- Moves stepper motor with position feedback from potentiometer
- Reset function drives tuner to home (park or on) position
- Handles "bad load angle" condition
- Non-functional detection: monitors for measurement updates and motor done-moving status
- Configurable tolerances and retry counts for reset operations

**Timing:** Waits for measurement ready event flag or max delay timeout

> **Source:** `rfApp/src/seq/rf_tuner_loop.st,v`, headers in `rf_tuner_loop_*.h,v`

#### 5.6.3 HVPS Loop (`rf_hvps_loop.st`)

Controls klystron High Voltage Power Supply.

**States:** `init` → `off` / `proc` / `on`

**Processing mode (`proc`):** Adjusts HVPS voltage based on:
- Klystron forward power vs. maximum setpoint
- Cavity gap voltage (decrease if too high)
- Cavity vacuum (decrease if too high)
- Otherwise: increase voltage (cavity processing/conditioning)

**On mode (`on`):** Maintains constant drive power or gap voltage:
- If direct loop OFF: adjusts based on `delta_tune_voltage`
- If direct loop ON: adjusts based on `-delta_on_voltage` (negative feedback)
- Cavity voltage limit check prevents increase if any cavity is at max
- Out-of-tolerance monitoring for drive power and gap voltage errors

**Status hierarchy:** RFP bad → Power bad → Gap voltage bad → Vacuum bad → HVPS voltage bad → Operational

> **Source:** `rfApp/src/seq/rf_hvps_loop.st,v`, headers in `rf_hvps_loop_*.h,v`

#### 5.6.4 DAC Loop (`rf_dac_loop.st`)

Adjusts amplitude setpoints for RF station operation.

**States:** `loop_init` → `loop_off` / `loop_tune` / `loop_on`

**Key functions:**
- **Tune mode:** Adjusts RFP octal DACs for drive power control
- **ON_CW with direct loop OFF:** Adjusts GFF reference values for drive power
- **ON_CW with direct loop ON:** Adjusts for gap voltage control
- Handles phase offset changes by forcing DAC recalculation
- Ripple loop amplitude setpoint tracking
- Process counts tracking for monitoring delta values

> **Source:** `rfApp/src/seq/rf_dac_loop.st,v`, headers in `rf_dac_loop_*.h,v`

#### 5.6.5 Calibration (`rf_calib.st`)

RFP Octal DAC calibration sequence. Activated on demand; does nothing until explicitly triggered.

> **Source:** `rfApp/src/seq/rf_calib.st,v`

#### 5.6.6 Message Logging (`rf_msgs.st`)

Logs state transitions and events not captured by bumpless reboot mechanism.

> **Source:** `rfApp/src/seq/rf_msgs.st,v`

### 5.7 Database Templates and Substitutions

The EPICS database is organized into template `.db` files instantiated via `.substitutions` files:

| Category | Template File(s) | Description |
|----------|-----------------|-------------|
| Station | `rf_stn.db`, `rf_stn_cav.db` | Station-level control and status |
| Cavity | `rf_cav.db` | Per-cavity parameters |
| HVPS | `rf_hvps.db`, `rf_digital_hvps.db` | High voltage power supply |
| Klystron | `rf_klys.db` | Klystron parameters (filament time, solenoid, etc.) |
| IQA | `rf_iqa.db`, `rf_iqa_module.db`, `rf_iqa_scale.db` | I/Q detector readbacks |
| Analog | `rf_analog.db`, `rf_analog_log.db` | Analog readbacks |
| Digital | `rf_digital_modu.db`, `rf_digital_plc.db` | Digital I/O status |
| Temperature | `rf_temp.db` | Temperature monitoring |
| DAC | `rf_dac.db`, `rf_rfp_fourdacs.db` | DAC control and calibration |
| Beam | `rf_beam.db`, `rf_beam_spr.db` | Beam-related parameters |
| Interlock | `rf_interlock.db`, `rf_interlock_arc.db`, `rf_interlock_vxi.db` | Interlock chain |
| Summaries | `rf_sumy_*.db` | Fault/status summary records |
| Feedback | `rf_fbck.db` | Feedback loop parameters |
| VXI modules | `rfp.db`, `iqa.db`, `gvf.db`, `clk.db`, `aim.db`, `cf2.db` | VXI module records |
| Crate | `crat_vxi_13slot.template` | Crate-level parameters |

**Substitution pattern (SPEAR3):**
```
file rf_stn_4CVAll.db
{{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
```
Where: `RRRS` = station name, `RNG` = ring type, `ID` = configuration ID (2=SPEAR3), `REG` = region

### 5.8 IOC Startup and Configuration

The IOC boot script (`iocBoot/b132-iocrf/st.cmd`) performs:

1. **Load binary:** `ld < bin/vxWorks-ppc604_long/rf.munch`
2. **Initialize error logging:** `errlogInit(5000)`
3. **Set environment variables** for macro substitution:
   - `DATABASE_MACROS=STN=SRF1`
   - Per-cavity tuner loop macros (`C1TUNRLOOP_MACROS` through `C4TUNRLOOP_MACROS`)
   - Allen-Bradley config file, restore paths
4. **Load database:** `dbLoadDatabase("dbd/rf.dbd")` + `dbLoadRecords("db/srf1.db")`
5. **Restore setpoints:** `dbRestore("spear1",0,-1)` + saved data files
6. **Configure Allen-Bradley:** `abConfigNlinks(1)`, `abConfigVme(0, 0xc00000, 0x60, 4)`
7. **Configure VXI:** Set LA base=1, count=13, A24/A32 windows
8. **Start EPICS:** `iocInit()`
9. **Start sequences:**
   - `seq(&rf_states, getenv("DATABASE_MACROS"))`
   - `seq(&rf_tuner_loop, ...)` × 4 (one per cavity)
   - `seq(&rf_hvps_loop, ...)`
   - `seq(&rf_dac_loop, ...)`
   - `seq(&P2RF_Calib, ...)`
   - `seq(&rf_msgs, ...)`
10. **Override defaults:** Station ID, summary calculation

> **Source:** `iocBoot/b132-iocrf/st.cmd,v`


---

## 6. Control System Design

### 6.1 RF Feedback Control Overview

The SPEAR3 LLRF system implements a multi-loop RF feedback architecture designed for stable cavity field regulation. The loops operate at different timescales and serve different purposes:

| Loop | Timescale | Implemented In | Purpose |
|------|-----------|---------------|---------|
| Direct Loop | Hardware (µs) | RFP DSP + `rf_states.st` | Fast cavity field regulation |
| Comb Loop | Hardware (µs) | RFP/CF2 DSP + `rf_states.st` | Coupled-bunch instability suppression |
| GFF Loop | Hardware (µs) | GVF module + `rf_states.st` | Gap voltage feed-forward |
| LFB Loop | Hardware (µs) | GVF module + `rf_states.st` | Low-frequency beam feedback |
| Ripple Loop | DSP + EPICS (ms) | IQA DSP + `rf_dac_loop.st` | AC mains ripple compensation |
| HVPS Loop | EPICS (0.5s) | `rf_hvps_loop.st` | Klystron voltage regulation |
| Tuner Loop | EPICS (1-10s) | `rf_tuner_loop.st` | Cavity mechanical tuner positioning |
| DAC Loop | EPICS (1s) | `rf_dac_loop.st` | Drive power / gap voltage setpoint |

### 6.2 Direct Loop

The direct (or "fast") feedback loop regulates the cavity field at the fundamental RF frequency. It operates entirely within the RFP module's DSP.

- **Activation:** Enabled/disabled via `SRF1:STN:RFP:DIRECTLOOP` (ON/OFF)
- **Control:** `SRF1:STNDIRECT:LOOP:CTRL` triggers enable/disable sequence
- **Gain:** Adjustable gain with transition ramping (`directlpgainoff`, `directlpgaindelta`)
- **Compensation:** Lead compensation (`LEADCOMP`) and integral compensation (`INTCOMP`) can be independently enabled
- **Sequencing in `rf_states.st`:** The state machine orchestrates direct loop turn-on after ON_CW entry, including drive power restoration and voltage settling waits (`COMPENSATION_WAIT = 1.0s`, `LP_ON_WAIT = 5.0s`)
- **Fast turn-on:** Supported when going directly to ON_CW with direct loop enabled (`fastoncontrol`)

### 6.3 Comb Loop / Comb Filter

Suppresses coupled-bunch instabilities using a comb filter that creates rejection notches at revolution harmonics.

- **Module:** CF2 (newer) or dual CFM (older), selected by `#define CF2` compile flag
- **Activation:** `SRF1:STN:RFP:COMBLOOP` and `SRF1:STNCOMB:LOOP:CTRL`
- **Transition:** Uses gain ramping similar to direct loop (`comblpgainoff`, `comblpgaindelta`)
- **Reset:** `SRF1:STNCOMB:LOOP:RESET.PROC` resets comb loop state
- **Phase:** Adjustable via `subSysPhaseCmb` calculation

### 6.4 Gap Voltage Feed Forward (GFF)

Provides feed-forward correction to maintain cavity gap voltage stability.

- **Module:** GVF (340-305)
- **Activation:** `SRF1:STN:GFF:CTRL`
- **I/Q Reference:** Initial values set/reset via `SRF1:STN:GFF:RESET.PROC`
- **Integration with direct loop:** When direct loop is ON, GFF references are used for gap voltage control

### 6.5 Low-Frequency Feedback (LFB)

Provides beam stabilization at frequencies below the direct loop bandwidth.

- **Module:** GVF (340-305)
- **Activation:** `SRF1:STN:LFB:CTRL`

### 6.6 Ripple Compensation

Compensates for AC mains power supply ripple in the klystron HVPS, which would otherwise modulate the RF field.

- **Implementation:** IQA module DSP (channel 0), controlled via DSP commands
- **Parameters:** Amplitude setpoint (`CMD_K_AMSP`), DC Z⁻¹ phase gain (`CMD_K_PHSG`), DAC offsets (`CMD_K_DACO`), phase/amplitude harmonic coefficients (`CMD_K_PHARM`, `CMD_K_AHARM`)
- **DC coefficient:** Calculated by `subSysDCcoeff` with configurable initial value
- **Reset:** `SRF1:STNRIPPLE:LOOP:AMPL.J` resets ripple loop DC coefficient before RF on

### 6.7 HVPS Regulation Loop

Software loop running at ~0.5 second intervals in `rf_hvps_loop.st`.

**Two operating modes:**

1. **Processing (PROC):** Cavity conditioning — ramps voltage up slowly, reduces on high power/vacuum/voltage
2. **On (ON):** Normal operation — maintains drive power (tune/direct-off) or gap voltage (direct-on) constant

**HVPS voltage adjustment formula:**
```
new_voltage = prev_voltage + delta
if (|delta| > max_delta): delta = sign(delta) * max_delta
if (new_voltage > max_voltage): new_voltage = max_voltage
if (new_voltage < min_voltage): new_voltage = min_voltage
```

### 6.8 Cavity Tuner Control Loop

Mechanical feedback loop in `rf_tuner_loop.st` (4 instances).

**Control algorithm:**
1. Measure cavity detuning via load angle (phase error between forward and reflected power)
2. Calculate position correction: `posn_ctrl = sm_posn + (posn_new - posn)` 
3. Command stepper motor to new position
4. Wait for motor done-moving signal
5. Repeat until within tolerance: `|posn_delta| < posn_mdel * LOOP_RESET_TOLS`

**Frequency offset estimation (`subSysFreqOff`):**
- Third-order polynomial in tuner position
- Temperature correction term proportional to V²
- Exponential smoothing filter

### 6.9 Interlock and Fault Handling

**Interlock hierarchy:**

```
Panel ON/OFF (local key switch)
    │
    ▼
Fault Summaries ──────────────────────────────────┐
├── STNON summary   → blocks OFF→ON transitions   │
├── STNPARK summary → blocks OFF→PARK transitions  │
├── STNOFF summary  → forces active→OFF transition │
├── HVPSCONTACT     → blocks auto-reset            │
└── Forced Fault    → blocks auto-reset            │
                                                    │
AIM Module ─────────────────────────────────────────┤
├── Arc Detection (7 or 12 channels)               │
├── Beam Abort (force/reset)                       │
├── HVPS permissive                                │
└── Fast Interlock Trip                            │
                                                    │
Allen-Bradley PLC ──────────────────────────────────┘
├── Vacuum interlocks
├── Temperature interlocks  
├── HVPS contactor status
└── Waveguide/window interlocks
```

**Fault file dumps:** On fault detection in active states, the system captures:
- 4 RFP memory buffers (I/Q sine/cosine)
- 2 CF2 history buffers (I/Q)
- 2-3 IQA amplitude histories
- 1 GVF reference buffer
- 1 AIM history buffer

Files are written to `/dat/FAULT*_<number>` with rotating fault numbers (1–15).

---

## 7. Signal Processing

### 7.1 I/Q Signal Model

All RF signals are represented in I/Q (In-phase/Quadrature) format:
- **I** = In-phase component (cosine)
- **Q** = Quadrature component (sine)
- **Amplitude** = √(I² + Q²)
- **Phase** = atan2(Q, I)

### 7.2 Amplitude and Phase Calculations

**Phase calculation (`subIQphase`):**
```
phase = atan2(Q, I) × (180/π) + offset
if (phase < -180): phase += 360
if (phase > 180): phase -= 360
```

**Amplitude from dB (`subIQampl`):**
```
k = (gain_dB + offset1 + offset2 + offset3) / divisor
amplitude_dimensionless = 10^k
amplitude_counts = amplitude_dimensionless × conversion
```

### 7.3 Power Measurements and Calibration

**Conversion constant calculation (`subIQampl2conv`):**
```
conversion = ref_amplitude / (gap_voltage × (1 + direct_loop_gain))
```
Valid only when: amplitude > 0.0001, gain > 0.0001, severity < 2.5, voltage > minimum

### 7.4 I/Q to Counts Conversion

- ADC resolution: 16-bit (0–65535)
- Voltage conversion: `SUBIQ_IQ2VOLTS = 2.0/65535.0`
- Count clamping with rounding: values clamped to [LOPR, HOPR] with ±0.4999 rounding

### 7.5 Frequency Offset Estimation

Third-order polynomial model with temperature correction:
```
Δf = p0 + p1×Δx + p2×Δx² + p3×Δx³ + t1×V²
```
Applied with exponential smoothing: `Δf_smooth = Δf_raw × (1-α) + Δf_prev × α`

---

## 8. External Interfaces

### 8.1 EPICS Channel Access

- **Protocol:** EPICS Channel Access (CA) only — no pvAccess support
- **PV naming convention:** `SRF1:<subsystem>:<parameter>`
- **Key subsystem prefixes:**
  - `SRF1:STN:` — Station-level
  - `SRF1:CAV1:` through `SRF1:CAV4:` — Per-cavity
  - `SRF1:HVPS:` — High voltage power supply
  - `SRF1:STN:RFP:` — RF Processing module
  - `SRF1:STN:IQA1:`, `IQA2:`, `IQA3:` — I/Q detectors
  - `SRF1:STN:GVF:` — Gap voltage feed forward
  - `SRF1:STN:CLK:` — Clock module
  - `SRF1:STN:AIM:` — Arc interlock module
  - `SRF1:STN:CF2:` — Comb filter

### 8.2 Machine Protection System (MPS)

- AIM module provides fast interlock (hardware trip)
- MPS Shutoff module in VXI slot 5
- Beam abort mechanism via AIM Force/Reset commands
- HVPS permissive controlled by AIM module

### 8.3 Timing System

- Clock module distributes 476 MHz reference
- Synchronized timestamp support via Unix server (TSconfigure)
- Clock resync command available during state transitions

### 8.4 Save/Restore

- `dbRestore` mechanism for setpoint persistence
- Server: `spear1` (formerly IP 134.79.33.34)
- Local save files: `/sav/savedataSRF1.sav`
- Fault data files: `/dat/FAULT*`
- Noise/drive data tables: `iocBoot/tbl/` directory

### 8.5 Data Tables

Pre-loaded calibration and reference data in `iocBoot/tbl/`:

| File Pattern | Purpose |
|-------------|---------|
| `NOISE_I`, `NOISE_Q` | I/Q noise floor tables |
| `NOISE_I_BL`, `NOISE_Q_BL` | Baseline noise tables |
| `DRIVE_HER_I/Q`, `DRIVE_LER_I/Q` | Drive reference waveforms |
| `NUS1KHZ_I/Q` | 1 kHz noise reference |
| `AmplCoefs.tbl` | Amplitude coefficients |

---

## 9. Operational Characteristics

### 9.1 Normal Operating Procedure

Typical station turn-on sequence (operator perspective):
1. Verify no faults: `SRF1:STNON:SUMY:STAT.SEVR == NO_ALARM`
2. Verify panel ON: `SRF1:STN:LOCAL:ON.SEVR == NO_ALARM`
3. Command TUNE: Set `SRF1:STN:STATE:CTRL = 2`
4. Wait for TUNE stable, verify HVPS on
5. Command ON_CW: Set `SRF1:STN:STATE:CTRL = 4`
6. System automatically: resets DACs, loads reference, enables HVPS, sets operate mode
7. Direct loop enables automatically (if `SRF1:STNDIRECT:LOOP:CTRL = ON`)
8. Comb loop enables on request
9. Beam tickle available for tune measurement

### 9.2 Fault Conditions and Recovery

**Common fault sources:**
- Vacuum excursion (cavity vacuum too high)
- Arc detection (AIM trips)
- HVPS contactor open
- Klystron faults (overcurrent, window temperature)
- Module communication failure (VXI INVALID severity)

**Auto-reset behavior:**
- Configurable retry count (`SRF1:STN:RESET:COUNTER`)
- Maximum retries up to 9999
- Vacuum wait: 10 seconds for pump-down
- Inter-attempt delay: 5 seconds
- Inhibited if: forced fault active, contactor bad, or panel off

### 9.3 Known Issues and Workarounds

From code comments and release notes:
- `devRegisterAddress` "seems not to work" — bypassed with direct address assignment (see `drvP2RfVxi.c`)
- Force-tagged releases (2021) indicate alarm limit changes made directly in production
- Klystron replacement (2021) required filament time and solenoid limit changes
- Tuner connectors C and D were physically swapped (R0-2-0), then swapped back (R0-3-0)
- Allen-Bradley reset function added for EPICS 3.14.6 compatibility (2005)

### 9.4 Release History

| Release | Date | Key Changes |
|---------|------|-------------|
| RF-SPEAR-R0-0-0 | 9/2012 | Initial SPEAR3 release |
| RF-SPEAR-R0-0-1 | 10/2012 | Move epvxi, AB, stepper to local; use restore module |
| RF-SPEAR-R0-0-2 | 3/2013 | HCW temp limits, load angle offset |
| RF-SPEAR-R0-0-3 | 7/2014 | Magic T post temp calc, klystron gain/efficiency precision |
| RF-SPEAR-R0-1-0 | 10/2016 | iocStats upgrade, window temp, klystron IP current |
| RF-SPEAR-R0-2-0 | 10/2016 | Tuner connectors C/D swap |
| RF-SPEAR-R0-3-0 | 1/2017 | Undo C/D swap, add tuner stop&init sequence |
| RF-SPEAR-R0-3-1 | 9/2020 | Solenoid bucking coil limits for new klystron |
| RF-SPEAR-R0-3-2 | 9/2020 | Klystron window/filament/temperature limits |

---

## 10. Upgrade Considerations

### 10.1 Obsolete Components (Prioritized Risk)

| Component | Risk Level | Reason | Replacement Options |
|-----------|-----------|--------|-------------------|
| WE DSP1610 | 🔴 Critical | No manufacturing, no spares | FPGA (e.g., Xilinx Zynq), modern DSP (TI C6000) |
| VXI modules (all 6 types) | 🔴 Critical | Custom SLAC, no spares | MTCA.4 / µTCA, custom FPGA boards |
| VxWorks 5.4 | 🔴 Critical | Unsupported, security risk | Linux (RTEMS still possible) |
| EPICS 3.14.x | 🟡 High | Legacy, no pvAccess | EPICS 7.x with pvAccess |
| KSC V152 adapter | 🟡 High | Obsolete, limits bus performance | Eliminated with µTCA/PCIe |
| AB 1771 DCM | 🟡 High | Legacy PLC I/O | Modern fieldbus (EtherCAT, PROFINET) |
| MVME2400 SBC | 🟡 High | No spares | Modern x86/ARM SBC |
| Compumotor/OMS steppers | 🟠 Medium | Functional but aging | Modern stepper controllers |

### 10.2 Functional Requirements Summary

Any replacement system must implement:

1. **RF field regulation** via I/Q feedback at ≤ µs latency (direct loop equivalent)
2. **Coupled-bunch instability suppression** via comb filtering
3. **Gap voltage feed-forward** with I/Q reference tables
4. **5-state station control** (OFF, PARK, TUNE, ON_FM, ON_CW) with defined transitions
5. **Per-cavity tuner control** (4 independent loops)
6. **HVPS regulation** with processing/conditioning mode
7. **Arc detection and fast interlock** with beam abort
8. **Fault recording** with 11-channel data capture and 15-fault history
9. **Auto-reset/recovery** with configurable retry count
10. **PLC I/O interface** for interlocks, temperature, vacuum
11. **Save/restore** for setpoint persistence
12. **Backward-compatible PV names** for archiver and display continuity

### 10.3 Performance Requirements

| Requirement | Current Value | Notes |
|------------|--------------|-------|
| Direct loop latency | < 1 µs (DSP hardware) | Critical for beam stability |
| Comb filter bandwidth | Revolution frequency harmonics | Must cover ~1.28 MHz revolution |
| HVPS loop rate | ~2 Hz (0.5s cycle) | Can likely be faster |
| Tuner loop rate | ~0.1–1 Hz | Limited by mechanical response |
| DAC loop rate | ~1 Hz | Can likely be faster |
| ADC/DAC resolution | 16-bit | May benefit from higher resolution |
| I/Q channels | 8 per IQA × 3 = 24 total | |
| Fault capture time | < 1 revolution period | For post-mortem analysis |

### 10.4 Interface Preservation Requirements

- PV names must be preserved or mapped for archiver continuity
- Operator display compatibility (can migrate from MEDM to CS-Studio/Phoebus)
- Save/restore data format compatibility or migration
- Interlock logic must be preserved or formally verified
- Timing interface must remain compatible with SPEAR3 timing system

### 10.5 Potential Architecture Options

1. **FPGA-based (µTCA.4/MTCA.4):** Replace all VXI modules with FPGA AMC cards in MTCA crate. Direct loop, comb filter, GFF in FPGA fabric. IOC on Linux CPU (e.g., NAT MCH or separate CPU AMC). Most common modern LLRF approach.

2. **SoC-based (Zynq/RFSoC):** Use Xilinx Zynq UltraScale+ RFSoC with integrated ADCs/DACs. Combines FPGA and ARM cores. Can run Linux + EPICS directly.

3. **Hybrid:** Keep some existing I/O (e.g., stepper motors) while replacing VXI electronics with modern digital processing.

### 10.6 Migration Strategy Considerations

- **Phase 1:** Characterize current system performance (loop bandwidths, latencies, noise floors)
- **Phase 2:** Design replacement hardware/firmware with functional equivalence
- **Phase 3:** Develop EPICS 7 IOC with equivalent PV set
- **Phase 4:** Parallel operation and validation
- **Phase 5:** Cutover during maintenance period

---

## 11. Appendices

### Appendix A: Source File Index

#### Core Application (`rfApp/src/`)

| Directory | Files | Purpose |
|-----------|-------|---------|
| `src/db/` | `drvP2RfVxi.c/h`, `devP2Rf*.c`, `p2Rf*Record.c`, `p2Rf*Def.h`, `subIQ.c`, `subSys.c`, `p2RfLib.h`, `p2RfInitHooks.c`, `p2RfInitClk.c`, `fast_lock.h`, `rf_station_state.h` | EPICS driver, records, device support, subroutines |
| `src/seq/` | `rf_states.st`, `rf_tuner_loop.st`, `rf_hvps_loop.st`, `rf_dac_loop.st`, `rf_calib.st`, `rf_msgs.st`, plus `*_defs.h`, `*_macs.h`, `*_pvs.h` | State machine sequences |
| `src/base/` | `bus.c`, `dld.c`, `dlt.c`, `lip.c`, `sgl.c`, `vbb.c`, `initModule.c`, `mvxLib.c`, `lstLib.c`, `mapAdx.c`, `memTest.c`, `stateShow.c`, `ethShow.c`, `bootFix.c`, `rfBaseRegister.c`, `vxiBaseIsr.c` + headers | Base libraries (VXI bus, messaging, download, diagnostics) |
| `src/diag/` | `rf_rfpDiags.c`, `rf_ripTest.c`, `rf_vxi_diag.c/h` | Diagnostic utilities |
| `src/dsp/` | `genDsp/`, `gvfDsp/`, `rfpDsp/`, `obsDsp/` — all `.h` files | DSP firmware definitions |
| `src/rf/` | `rfMain.cpp`, `Makefile` | IOC main entry point |

#### Database Templates (`rfApp/Db/`)

60+ `.db`, `.substitutions`, and `.template` files defining the complete EPICS PV set.

#### IOC Configuration (`rfApp/DbIoc/`)

| File | Purpose |
|------|---------|
| `srf1.substitutions` | SPEAR3 Station 1 macro definitions |
| `srf2.substitutions` | Station 2 (if applicable) |
| `srf3.substitutions` | Station 3 (if applicable) |
| `rfreport` | RF system report script |

#### Supporting Modules

| Module | Directory | Purpose |
|--------|-----------|---------|
| Allen-Bradley | `allenBradley/` | PLC I/O driver |
| VXI Bus | `epvxi/` | VXI bus driver/resource manager |
| DSP Tools | `dsp1610/` | DSP1610 assembler/linker toolchain |
| Steppers | `stepper/` | Stepper motor driver |
| KSC V152 | `rfApp/ksc_v152/` | VXI-VME adapter, PLDs, driver source |

### Appendix B: PV Naming Convention

```
{STN}:{SUBSYSTEM}:{PARAMETER}[:{FIELD}]

Where:
  {STN}     = Station name (SRF1)
  {SUBSYSTEM} = Functional subsystem
  {PARAMETER} = Specific measurement/control
  {FIELD}   = Optional EPICS record field
```

**Key PV examples:**

| PV | Type | Description |
|----|------|-------------|
| `SRF1:STN:STATE:CTRL` | int | Desired station state (0-4) |
| `SRF1:STN:STATE:RBCK` | int | Actual station state (0-4) |
| `SRF1:STN:STATE:STRING` | string | State display string |
| `SRF1:STN:RESET:CTRL` | int | Station reset command |
| `SRF1:STN:RESET:COUNTER` | float | Auto-reset retry count |
| `SRF1:STN:RFP:RFENABLE` | int | RF switch on/off |
| `SRF1:STN:RFP:RUNMODE` | int | Tune(0)/Operate(1) |
| `SRF1:STN:RFP:DIRECTLOOP` | int | Direct loop on/off |
| `SRF1:STN:RFP:COMBLOOP` | int | Comb loop on/off |
| `SRF1:STN:RFP:LEADCOMP` | int | Lead compensation on/off |
| `SRF1:STN:RFP:INTCOMP` | int | Integral compensation on/off |
| `SRF1:HVPS:VOLT:CTRL` | double | Requested HVPS voltage |
| `SRF1:HVPS:VOLT:MIN` | double | Default HVPS voltage |
| `SRF1:HVPSSCR:ON:CTRL` | int | HVPS trigger on/off |
| `SRF1:STN:AIM:FRCBMABT` | int | Force beam abort |
| `SRF1:STN:AIM:MODU.RBA` | int | Reset beam abort |
| `SRF1:STN:AIM:MODU.RSTF` | int | Reset AIM faults |
| `SRF1:STN:CLK:MODU.RSYN` | int | Clock resync |
| `SRF1:STN:FAULT:NUM` | int | Current fault number |
| `SRF1:STN:FAULT:CTRL` | int | Fault file control |
| `SRF1:STN:TICKLE:CTRL` | int | Beam tickle on/off |

### Appendix C: Glossary

| Term | Definition |
|------|-----------|
| AIM | Arc Interlock Module — fast interlock and arc detection VXI card |
| CF2/CFM | Comb Filter Module — comb filter for coupled-bunch suppression |
| CLK | Clock distribution VXI module |
| CW | Continuous Wave — normal beam delivery mode |
| DDF | Digital Decimation Filter |
| DSP | Digital Signal Processor (WE DSP1610) |
| EPICS | Experimental Physics and Industrial Control System |
| FM | Frequency Modulation — sweep mode for testing |
| GFF | Gap Feed Forward — feed-forward for cavity voltage |
| GVF | Gap Voltage Feed Forward VXI module |
| HVPS | High Voltage Power Supply (for klystron) |
| I/Q | In-phase / Quadrature signal representation |
| IOC | Input/Output Controller (EPICS) |
| IQA | I/Q & Amplitude detector VXI module |
| LA | Logical Address (VXI bus) |
| LFB | Low-Frequency Feedback |
| LLRF | Low-Level RF (control system) |
| MPS | Machine Protection System |
| PV | Process Variable (EPICS) |
| RFP | RF Processing VXI module |
| SNL | State Notation Language (EPICS sequencer) |
| SRF1 | SPEAR RF Station 1 |
| VXI | VMEbus Extensions for Instrumentation |

---

*End of Report*
