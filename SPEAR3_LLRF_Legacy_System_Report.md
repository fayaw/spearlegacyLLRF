# SPEAR3 Legacy LLRF Control System — Comprehensive Technical Report

**Date:** March 2026  
**Repository:** `spearlegacyLLRF` → `rf-spear-legacy/`  
**Purpose:** Complete technical analysis of the existing SPEAR3 Low-Level RF (LLRF) control system codebase to enable AI-assisted system upgrade design  

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Critical Naming Clarification](#2-critical-naming-clarification)
3. [RF Power Chain and Physical System](#3-rf-power-chain-and-physical-system)
4. [Hardware Architecture](#4-hardware-architecture)
5. [Software Stack Architecture](#5-software-stack-architecture)
6. [DSP Firmware and Control Loops](#6-dsp-firmware-and-control-loops)
7. [Station State Machine](#7-station-state-machine)
8. [SNL Sequence Programs](#8-snl-sequence-programs)
9. [EPICS Database and PV Structure](#9-epics-database-and-pv-structure)
10. [SPEAR3-Specific Adaptations](#10-spear3-specific-adaptations)
11. [Allen-Bradley PLC Integration](#11-allen-bradley-plc-integration)
12. [Fault Handling and Diagnostics](#12-fault-handling-and-diagnostics)
13. [Build System and Dependencies](#13-build-system-and-dependencies)
14. [Release History](#14-release-history)
15. [Upgrade Considerations](#15-upgrade-considerations)
16. [Complete File Inventory](#16-complete-file-inventory)

---

## 1. Executive Summary

The SPEAR3 LLRF system is a direct adaptation of the PEP-II B-Factory Low-Level RF control system, designed at SLAC in the mid-1990s. It controls **normal-conducting copper RF cavities** operating at **476 MHz** with harmonic number **372** (vs PEP-II's 3,492). The system manages a single RF station ("SRF1") with **4 copper cavities** powered by a **single klystron** amplifier.

### Key System Parameters

| Parameter | Value |
|-----------|-------|
| RF Frequency | 476 MHz |
| Cavity Type | **Normal-conducting copper** |
| Number of Cavities | 4 per station |
| Harmonic Number | 372 (SPEAR3) |
| Station Identifier | SRF1 (legacy naming) |
| IOC Identifier | B132-IOCRF |
| Location | Building 132, SLAC |

### Technology Stack

| Component | Technology | Era |
|-----------|-----------|-----|
| IOC CPU | Motorola MVME2400 PowerPC 604 | ~2000 |
| RTOS | VxWorks 5.4 | ~1999 (EOL) |
| EPICS | 3.14.8.2 → 3.14.11 | ~2006 |
| Bus | VME/VXI (13-slot crate) | ~1995 |
| DSP | WE DSP1610 (16-bit fixed-point) | ~1993 |
| PLC | Allen-Bradley 1771 series | ~1990s |
| Source Control | CVS (2,291 archived files) | Legacy |

### Codebase Scale

| Category | Count |
|----------|-------|
| Total CVS files | 2,291 |
| Custom EPICS record types | 6 |
| SNL state machines | 6 |
| EPICS database templates | ~80 |
| DSP assembly programs | ~100 |
| C/C++ source files | ~60 |
| Calibration/reference tables | ~45 |


---

## 2. Critical Naming Clarification

> **⚠️ IMPORTANT: The "SRF" prefix in PV names (e.g., `SRF1:STN:STATE`) does NOT indicate superconducting RF technology.**

The "SRF" prefix is a **legacy naming convention** inherited from the PEP-II B-Factory project. Both PEP-II and SPEAR3 operate exclusively with **normal-conducting copper RF cavities**. There are no superconducting cavities anywhere in this system.

This distinction has significant engineering implications:

| Aspect | Normal-Conducting (Actual) | Superconducting (Not Used) |
|--------|---------------------------|---------------------------|
| Cavity Material | Copper | Niobium |
| Operating Temperature | Room temperature + active water cooling | 2–4 K cryogenic |
| Loaded Q | ~10³–10⁴ | ~10⁶–10⁸ |
| Cavity Bandwidth | Wide (~kHz range) | Very narrow (~Hz range) |
| Primary Detuning Source | Thermal expansion | Lorentz force detuning, microphonics |
| Power Dissipation | High (significant wall losses) | Very low (nearly lossless) |
| Cooling | High-flow water cooling required | Liquid helium cryostat |
| Tuner Mechanism | Mechanical (stepper motors) | Piezo + stepper |

The codebase uses the `SRF` prefix throughout because it was originally written for PEP-II station naming. When adapted for SPEAR3, the PV prefix was retained as `SRF1` rather than being renamed. The EPICS configuration ID `ID=2` distinguishes SPEAR3 from PEP-II at runtime (see `P2RF_K_HARMNO(i)` in `p2RfLib.h`).

---

## 3. RF Power Chain and Physical System

### Signal Flow (Normal-Conducting Copper Cavity System)

```
                                        ┌──── Cavity 1 (copper) ──── Beam
                                        │
RF Reference ──► LLRF ──► Klystron ──►──┼──── Cavity 2 (copper) ──── Beam
  (476 MHz)      System    Amplifier    │
                                        ├──── Cavity 3 (copper) ──── Beam
                                        │
                                        └──── Cavity 4 (copper) ──── Beam
                                                    │
                                              RF Pickups (I/Q)
                                                    │
                                              ◄─── Feedback ◄───
```

### Key Components

1. **RF Reference** — 476 MHz master oscillator, distributed by CLK module (340-306)
2. **LLRF System** — VXI crate with RFP (340-304), IQA (340-302), GVF (340-305) modules
3. **Klystron Amplifier** — High-power vacuum tube amplifier, powered by HVPS (High Voltage Power Supply)
   - Klystron drive power, filament, solenoid, and window temperature are all monitored
   - HVPS voltage is regulated by the `rf_hvps_loop.st` sequence
4. **4 Copper Cavities** — Each independently monitored via IQA modules
   - Each cavity has a mechanical tuner (stepper motor) for resonance adjustment
   - Active water cooling to manage thermal loads from resistive RF power losses
   - Vacuum system with ion pumps (monitored for cavity conditioning)
5. **RF Pickups** — I/Q detection at each cavity for amplitude and phase measurement
6. **Allen-Bradley PLC** — Digital and analog I/O for interlocks, temperatures, vacuum, HVPS status

### Why the Control Loops Exist (Normal-Conducting Context)

In a normal-conducting copper cavity system, the control loops address:

- **Amplitude regulation**: Klystron output power fluctuations due to HVPS ripple, klystron aging, and beam loading
- **Phase regulation**: Phase drift from thermal cavity expansion, klystron phase pushing, and beam phase transients
- **Ripple compensation**: AC mains harmonics (60 Hz and harmonics) appearing in the HVPS cause amplitude and phase modulation on the RF — the DSP ripple loop actively cancels these
- **Tuner control**: Slow thermal drift of cavity resonant frequency requires mechanical tuner repositioning (stepper motors, seconds timescale)
- **HVPS regulation**: Klystron voltage must be ramped and maintained for stable RF output


---

## 4. Hardware Architecture

### VME/VXI Crate Layout (13-Slot Elma Crate, Building 132)

From `srf1.substitutions,v` and `crat_vxi_13slot.template`:

| Slot | Module | Drawing | Description |
|------|--------|---------|-------------|
| 0 | MVME2400 | — | PowerPC 604 IOC (B132-IOCRF) |
| 1 | AB 1771 DCM | — | Allen-Bradley PLC Scanner |
| 2 | CLK | 340-306 | Clock & RF Distribution |
| 3 | *(empty)* | — | — |
| 4 | RFP | 340-304 | RF Processing (contains WE DSP1610) |
| 5 | MPS | — | Machine Protection Shutoff |
| 6 | Link | — | VXI Link Passthrough |
| 7 | IQA1 | 340-302 | I/Q Amplitude Detector #1 |
| 8 | *(empty)* | — | — |
| 9 | IQA2 | 340-302 | I/Q Amplitude Detector #2 |
| 10 | *(empty)* | — | — |
| 11 | IQA3 | 340-302 | I/Q Amplitude Detector #3 |
| 12 | AIM | 340-307 | Arc Interlock Module |

### IOC Platform

| Component | Specification |
|-----------|---------------|
| CPU Board | Motorola MVME2400 (PowerPC 604) |
| RTOS | VxWorks 5.4 |
| Boot Method | NFS from `/afs/slac/g/spear/epics/...` |
| EPICS Base | 3.14.8.2 → 3.14.11 |
| VME Addressing | A16 (VXI CSR), A24/A32 (extended memory) |
| Default Interrupt Level | 5 (configurable via `P2RfIntLevel`) |

### VXI Module Registry

All custom modules share VXI Manufacturer ID **0xF00** (SLAC PEP-II RF Group):

| Module | VXI Model Code | Drawing | Full Name | Primary Function |
|--------|---------------|---------|-----------|-----------------|
| **RFP** | 0x103 | 340-304 | RF Processing | I/Q DAC generation, direct loop, comb loop, ripple compensation; contains embedded WE DSP1610 |
| **IQA** | 0x102 | 340-302 | I/Q & Amplitude Detector | I/Q detection (8 channels per module), amplitude measurement, 512-word history buffer |
| **GVF** | 0x105 | 340-305 | Gap Voltage Feed Forward | Gap feed-forward (GFF) and low-frequency beam feedback (LFB) loops; has its own DSP |
| **CLK** | 0x106 | 340-306 | Clock & RF Distribution | 476 MHz reference distribution, config ID register (SPEAR3 vs PEP-II selection) |
| **AIM** | 0x107 | 340-307 | Arc Interlock Module | Fast arc detection (7 or 12 channels), beam abort trigger, history buffer |
| **CF2/CFM** | 0x101 | 340-301 | Comb / Group Delay Equalizer | Coupled-bunch instability suppression (PEP-II legacy, limited use at SPEAR3) |

### VXI-VME Adapter

The **Kinetic Systems V152** adapter bridges VXI and VME buses. Its full source tree (PLD designs, driver source, resource manager) is preserved in `rfApp/ksc_v152/` (1,696 files). Key subdirectories:

- `PLDs/` — CUPL programmable logic source and compiled JEDEC files
- `driver_source/` — VXI resource manager C source and headers
- `documents/` — Technical documentation
- `prog_files/` — Compiled programming files (`v152_u35.jed`, `u7.pof`)

### Stepper Motor System

Cavity tuners use stepper motors controlled via:
- **Compumotor 1830** controller (`devSmCompumotor1830.c`)
- **OMS 6-Axis** controller (`devSmOms6Axis.c`)
- Custom `steppermotorRecord` EPICS record type
- 4 reentrant instances of `rf_tuner_loop.st` (one per cavity)


---

## 5. Software Stack Architecture

The software is organized in 7 layers, from hardware to operator interface:

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 6: Operator Interface (MEDM/EDM displays)            │  ← Not in this repo
├─────────────────────────────────────────────────────────────┤
│  Layer 5: EPICS Database Templates (~80 .db files)          │  rfApp/Db/
│    Station, cavity, HVPS, klystron, IQA, analog, digital,   │
│    temperature, interlock, feedback, summary PVs            │
├─────────────────────────────────────────────────────────────┤
│  Layer 4: SNL State Machine Sequences (6 programs)          │  rfApp/src/seq/
│    rf_states, rf_tuner_loop, rf_hvps_loop,                  │
│    rf_dac_loop, rf_calib, rf_msgs                           │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: Subroutine Records (~30 functions)                │  rfApp/src/db/
│    subIQ.c (I/Q processing: phase, amplitude, power,        │
│             DAC, directivity, conversion, coupling)          │
│    subSys.c (freq offset, phase calc, ripple coefficients,  │
│              drive selection, Allen-Bradley reset)            │
├─────────────────────────────────────────────────────────────┤
│  Layer 2: Custom EPICS Record Types (6 record types)        │  rfApp/src/db/
│    p2RfRfpRecord (RFP), p2RfIqaRecord (IQA),               │
│    p2RfGvfRecord (GVF), p2RfClkRecord (CLK),               │
│    p2RfAimRecord (AIM), p2RfCf2Record/p2RfCfmRecord (Comb)  │
├─────────────────────────────────────────────────────────────┤
│  Layer 1: Universal VXI Driver                              │  rfApp/src/db/
│    drvP2RfVxi.c — Module discovery, address mapping,        │
│    interrupt routing, DSP loading, coefficient management    │
├─────────────────────────────────────────────────────────────┤
│  Layer 0: EPICS Base + VxWorks + VME/VXI Hardware           │
│    EPICS 3.14.x, VxWorks 5.4, Allen-Bradley 1771 DCM,      │
│    Stepper motors, KSC V152 VXI-VME adapter                 │
└─────────────────────────────────────────────────────────────┘
```

### Layer 1: VXI Driver (`drvP2RfVxi.c`)

The universal VXI driver provides:
- **Module auto-discovery** via VXI resource manager tables
- **Address space mapping** (A16 CSR, A24/A32 extended)
- **DSP program loading** from table files into embedded DSP1610 processors
- **Coefficient table loading** (amplitude, phase, ripple coefficients)
- **Interrupt routing** from VXI modules to EPICS processing
- **Register-level read/write** for all VXI module types

Key data structures defined in `p2RfLib.h`:

```c
P2RF_K_RFFREQ    /* 476 MHz RF frequency */
P2RF_K_HARMNO(i) /* 372 (SPEAR3, config ID=2) or 3492 (PEP-II) */
P2RF_K_SAMPFACT  /* 72 — sampling factor for DSP */
```

### Layer 2: Custom Record Types

Each VXI module has a dedicated EPICS record type with:
- **Record definition** (`.dbd` file with field definitions)
- **Record support** (`*Record.c` — init, process, special processing)
- **Device support** (`dev*.c` — hardware I/O for each field)

| Record Type | Source Files | Fields | Purpose |
|-------------|-------------|--------|---------|
| `p2RfRfpRecord` | `p2RfRfpRecord.c/dbd`, `devP2RfRfp.c` | ~100 | RFP module: DAC values, loop gains, DSP status, I/Q drive |
| `p2RfIqaRecord` | `p2RfIqaRecord.c/dbd`, `devP2RfIqa.c` | ~80 | IQA module: 8 I/Q channels, amplitude, history readback |
| `p2RfGvfRecord` | `p2RfGvfRecord.c/dbd`, `devP2RfGvf.c` | ~60 | GVF module: feed-forward/LFB configuration |
| `p2RfClkRecord` | `p2RfClkRecord.c/dbd`, `devP2RfClk.c` | ~30 | CLK module: reference distribution, config ID |
| `p2RfAimRecord` | `p2RfAimRecord.c/dbd`, `devP2RfAim.c` | ~50 | AIM module: arc detection thresholds, trip status |
| `p2RfCf2/CfmRecord` | `p2RfCf2Record.c/dbd`, `p2RfCfmRecord.c/dbd` | ~40 | Comb filter: IIR coefficients, loop configuration |

### Layer 3: Subroutine Records

**`subIQ.c`** — ~20 I/Q processing subroutines:

| Function | Purpose |
|----------|---------|
| `subIQinit` | General initialization |
| `subIQgetInit` / `subIQget` | Fresh I/Q value acquisition from IQA record |
| `subIQphase` | Phase calculation from I and Q |
| `subIQampl` | Amplitude from dB calculation |
| `subIQampl2conv` | Reference amplitude to conversion factor |
| `subIQamplStn` | Total station amplitude / gap voltage |
| `subIQamplCplg` | Cavity coupling factor from amplitudes |
| `subIQampl2loss` | Conversion loss from amplitude |
| `subIQampl2iq` | Amplitude to I and Q decomposition |
| `subIQpower` | Power or amplitude calculation |
| `subIQpowerNet` | Net power calculation |
| `subIQpowerEff` | Klystron efficiency or cavity shunt impedance |
| `subIQpower2gain` | Gain/loss from powers or amplitudes |
| `subIQpower2ampl` | Power/amplitude to amplitude |
| `subIQphaseOffs` | Total phase offset |
| `subIQphaseOffsU` | Unadjusted phase offset |
| `subIQphaseErr` | Load angle phase error |
| `subIQphase2posn` | Phase error to delta stepper motor position |
| `subIQdac` | Calculate II/IQ/QI/QQ DAC values (I/Q rotation matrix) |
| `subIQcounts` | Error to delta counts conversion |
| `subIQcorrected` | Directivity correction |
| `subIQscaled` | Scaled I and Q calculation |

**`subSys.c`** — ~10 system-level subroutines:

| Function | Purpose |
|----------|---------|
| `subSysInit` | General initialization |
| `subSysFreqOff` | Cavity frequency offset estimation |
| `subSysFreqOAvg` | Average cavity frequency offset |
| `subSysFreqErr` | Cavity park frequency error |
| `subSysPhaseTot` | Direct loop total phase |
| `subSysPhaseCmb` | Comb loop phase |
| `subSysPhaseStn` | Station phase |
| `subSysDCcoeff` | Ripple loop DC coefficient calculation |
| `subSysDrivSel` | Drive power setpoint selection |
| `subSysLog` | Value from log calculation |
| `subSysABreset` | Allen-Bradley scanner reset |


---

## 6. DSP Firmware and Control Loops

### DSP Hardware: WE DSP1610

The RFP and GVF modules each contain an embedded **Western Electric (Lucent) DSP1610** processor:

| Feature | Specification |
|---------|---------------|
| Architecture | 16-bit fixed-point |
| Word Size | 16-bit data, 16-bit instruction |
| External RAM | 8K–16K words (configurable via `DSP_K_ESIZE`) |
| Arithmetic | Hardware multiply-accumulate, saturation modes |
| Toolchain | Custom assembler (`as1600`), linker (`ld1600`), archiver (`ar1600`), C preprocessor (`cpp16`) |
| Toolchain Location | `dsp1610/` directory (30+ files) |

### DSP Command Protocol

Communication between the IOC (VxWorks) and DSP uses a 15-command mailbox protocol (from `dspCmdDef.h`):

| Command | Code | Purpose |
|---------|------|---------|
| `CMD_K_NOOP` | 0x0000 | No operation |
| `CMD_K_READY` | 0x0001 | DSP reports ready |
| `CMD_K_TEST` | 0x0002 | Self-test |
| `CMD_K_ERROR` | 0x0003 | DSP error condition |
| `CMD_K_LDTBL` | 0x0004 | Load coefficient tables |
| `CMD_K_SVDATA` | 0x0005 | Save external RAM data |
| `CMD_K_APHASE` | 0x0006 | Save average phase |
| `CMD_K_LDREF` | 0x0007 | Load I/Q reference waveform tables |
| `CMD_K_UREF` | 0x0008 | Update reference tables (hot swap) |
| `CMD_K_AMSP` | 0x000A | Ripple amplitude setpoint |
| `CMD_K_PHSG` | 0x000B | Ripple DC Z⁻¹ phase gain |
| `CMD_K_DACO` | 0x000C | Ripple DAC offsets (II/IQ/QI/QQ) |
| `CMD_K_PHARM` | 0x000D | Ripple phase harmonic coefficients |
| `CMD_K_AHARM` | 0x000E | Ripple amplitude harmonic coefficients |
| `CMD_K_DONE` | 0xFFFF | Operation complete acknowledgement |

### 8 Control Loops

The system implements 8 feedback/feedforward loops operating at different timescales:

```
Timescale:  µs            ms              100ms           seconds
            │              │                │               │
            ▼              ▼                ▼               ▼
     ┌─────────────┐ ┌──────────┐  ┌──────────────┐ ┌─────────────┐
     │ Direct Loop │ │ Comb     │  │ HVPS Loop    │ │ Tuner Loop  │
     │ (RFP DSP)  │ │ Loop     │  │ (SNL ~0.5s)  │ │ (SNL ~1-10s)│
     │             │ │ (RFP DSP)│  │              │ │             │
     │ Ripple Loop │ │          │  │ DAC Loop     │ │             │
     │ (RFP DSP)  │ │ GFF/LFB  │  │ (SNL ~1s)    │ │             │
     │             │ │ (GVF DSP)│  │              │ │             │
     └─────────────┘ └──────────┘  └──────────────┘ └─────────────┘
         DSP               DSP            EPICS           EPICS
      (hardware)        (hardware)       (software)     (software)
```

#### Loop 1: Direct Loop (RFP DSP — Microseconds)

- **Purpose**: Fast cavity field amplitude and phase regulation
- **Implementation**: Runs continuously on RFP DSP1610
- **Signal path**: Compares measured I/Q from cavity pickup with setpoint, computes correction DAC values
- **DAC values**: II, IQ, QI, QQ rotation matrix (see `subIQdac`)
- **Key files**: `rfpDsp/comBlk.s`, `rfpDsp/vecTbl.s`, coefficient loading routines

#### Loop 2: Comb Loop (RFP DSP — Beam-Synchronous)

- **Purpose**: Coupled-bunch instability suppression
- **Implementation**: Comb filter on RFP DSP, beam-synchronous timing
- **Context**: More critical for PEP-II (high harmonic number); limited use at SPEAR3
- **Key files**: CF2/CFM record types, `cfmIirCoefs*.tbl`

#### Loop 3: Gap Voltage Feed-Forward / GFF (GVF DSP)

- **Purpose**: Anticipatory correction for beam loading transients
- **Implementation**: Separate DSP on GVF module
- **Key files**: `gvfDsp/gvff.s`, `gvfDsp/gvff.h`, `gvfDsp/gvffMisc.h`

#### Loop 4: Low-Frequency Beam Feedback / LFB (GVF DSP)

- **Purpose**: Slow beam stability feedback
- **Implementation**: Shares GVF module DSP with GFF
- **Key files**: `gvfDsp/` directory

#### Loop 5: Ripple Compensation (RFP DSP — AC Mains Synchronous)

- **Purpose**: Active cancellation of AC power line harmonics (60 Hz and harmonics) that modulate the klystron HVPS, causing amplitude and phase ripple on the RF
- **Implementation**: DSP1610 assembly, phase and amplitude harmonic tracking
- **SPEAR3-specific**: `sp3ripple.s` uses **26 fast coefficients** (vs 34 for PEP-II) because the higher DSP sampling frequency at SPEAR3 allows fewer filter taps to cover the same frequency range
- **Coefficient download commands**: `CMD_K_AMSP`, `CMD_K_PHSG`, `CMD_K_DACO`, `CMD_K_PHARM`, `CMD_K_AHARM`
- **Key files**: `rfpDsp/sp3ripple.s` (SPEAR3), `rfpDsp/ripple.s` (PEP-II original), `rfpDsp/dspSos.s` (second-order sections filter)

#### Loop 6: HVPS Loop (EPICS SNL — ~0.5s Cycle)

- **Purpose**: Regulate klystron high-voltage power supply
- **Implementation**: `rf_hvps_loop.st` state machine sequence
- **States**: `init` → `off` → `proc` (processing/ramping) → `on` (regulation)
- **In processing mode**: Ramps HVPS voltage while monitoring vacuum, drive power, cavity conditions
- **In on mode**: Adjusts HVPS to maintain constant drive power or gap voltage

#### Loop 7: DAC Loop (EPICS SNL — ~1s Cycle)

- **Purpose**: Adjust RF drive amplitude setpoints
- **Implementation**: `rf_dac_loop.st` state machine sequence
- **States**: `loop_init` → `loop_off` → `loop_tune` → `loop_on`
- **In tune mode**: Adjusts for drive power setpoint
- **In on_cw mode**: Adjusts for gap voltage (if direct loop on) or drive power (if direct loop off)

#### Loop 8: Tuner Loop (EPICS SNL — 1–10s Cycle)

- **Purpose**: Maintain cavity resonant frequency by adjusting mechanical tuner position
- **Implementation**: `rf_tuner_loop.st` — **reentrant** (4 instances, one per cavity)
- **States**: `loop_init` → `loop_unknown` → `loop_reset` → `loop_on`
- **Mechanism**: Converts load angle phase error to stepper motor delta position via `subIQphase2posn`
- **Key PVs**: `SRF1:CAV{1-4}TUNR:*` for each cavity

### DSP Source File Organization

```
rfApp/src/dsp/
├── genDsp/          — General DSP definitions and utilities
│   ├── dspCmdDef.h  — 15-command mailbox protocol
│   ├── dspDef.h     — Memory map, buffer sizes
│   ├── macros.h     — Assembly macros
│   ├── aucDef.h     — AUC (auxiliary control) definitions
│   ├── bioDef.h     — Binary I/O definitions
│   ├── comDef.h     — Communication block definitions
│   ├── intDef.h     — Interrupt definitions
│   ├── pioDef.h     — Parallel I/O definitions
│   ├── timDef.h     — Timer definitions
│   ├── atan.s       — Arctangent function
│   ├── cos.s, sin.s — Trig functions
│   └── sqrt2.s      — Square root
│
├── rfpDsp/          — RFP module DSP programs (~50 files)
│   ├── sp3ripple.s  — *** SPEAR3-specific ripple loop ***
│   ├── ripple.s     — PEP-II original ripple loop
│   ├── dspSos.s     — Second-order sections (IIR filter)
│   ├── comBlk.s     — Communication block layout
│   ├── vecTbl.s     — Interrupt vector table
│   ├── constDacs.s  — Constant DAC output test
│   ├── loadDacs.s   — DAC coefficient loading
│   ├── rampDacs.s   — DAC ramp test
│   ├── zeroDacs.s   — Zero all DACs
│   ├── lusqrt.s     — Lookup-table square root
│   └── regInit.s    — Register initialization
│
├── gvfDsp/          — GVF module DSP programs (~40 files)
│   ├── gvff.s       — Main GFF/LFB loop
│   ├── gvff.h       — GFF definitions
│   ├── gvffMisc.h   — Miscellaneous GFF support
│   ├── comBlk.s     — Communication block
│   ├── wave_out.s   — Waveform output
│   └── dspmemtest.s — Memory self-test
│
├── obsDsp/          — Observer/diagnostic DSP (~15 files)
│   ├── Equaliz.s    — Equalization
│   ├── adapt.s      — Adaptive filter
│   ├── apTOiq.s     — Amplitude/phase to I/Q conversion
│   ├── iqTOap.s     — I/Q to amplitude/phase
│   ├── averPhas.s   — Average phase computation
│   └── takeDat.s    — Data acquisition
│
└── Utility scripts
    ├── constDacsRfp  — Set constant DAC values
    ├── loadDacsRfp   — Load DAC coefficients
    ├── rampDacsRfp   — Run DAC ramp test
    ├── zeroDacsRfp   — Zero all DACs
    └── wave_out      — Output waveform test
```


---

## 7. Station State Machine

The master station control is implemented in `rf_states.st` (~2,412 lines), the largest and most critical file in the codebase.

### State Set: `ss rf_states`

**5 Primary (Steady) States:**

| State | Code | Description |
|-------|------|-------------|
| `s_off` | `STATION_OFF (0)` | RF off, HVPS off, tuners may be parked |
| `s_park` | `STATION_PARK (1)` | Tuners at park position, HVPS off |
| `s_tune` | `STATION_TUNE (2)` | Tune mode — HVPS on, active cavity tuning |
| `s_on_fm` | `STATION_ON_FM (3)` | Frequency modulation / sweep mode |
| `s_on_cw` | `STATION_ON_CW (4)` | Continuous wave — normal beam operation |

**11 Transition States:**

| State | Triggers From → To |
|-------|-------------------|
| `s_init` | Boot → `s_go_off` (initialization) |
| `s_go_off` | Any → `s_off` (shutdown) |
| `s_go_stn_reset` | Fault → auto-reset sequence |
| `s_go_park` | OFF → `s_park` |
| `s_go_tune` | OFF/PARK → `s_tune` |
| `s_go_tune_to_on_cw` | TUNE → `s_on_cw` (via tune) |
| `s_go_on_fm` | OFF/TUNE → `s_on_fm` |
| `go_on_fm_to_tune` | ON_FM → `s_tune` |
| `s_go_on_cw` | OFF/TUNE → `s_on_cw` |
| `go_on_cw_to_tune` | ON_CW → `s_tune` |
| `s_go_tickleon` / `s_go_tickleoff` | Beam tickle (tune measurement) on/off |
| `s_lp_check` | Loop parameter validation |

### State Transition Diagram

```
                    ┌─────────────────────────────────────┐
                    │                                     │
         ┌─────────▼──────────┐                           │
    ─────► s_init             │                           │
         │  (boot)            │                           │
         └────────┬───────────┘                           │
                  │                                       │
         ┌────────▼───────────┐    Fault                  │
    ┌────► s_off              ◄────────────────────┐      │
    │    │  (STATION_OFF)     │                    │      │
    │    └──┬───┬───┬───┬─────┘                    │      │
    │       │   │   │   │                          │      │
    │       │   │   │   └──► s_go_on_cw ───►───┐   │      │
    │       │   │   └──────► s_go_on_fm ───►─┐ │   │      │
    │       │   └──────────► s_go_tune ──►─┐ │ │   │      │
    │       └──────────────► s_go_park ─┐  │ │ │   │      │
    │                                   │  │ │ │   │      │
    │    ┌──────────────────┐           │  │ │ │   │      │
    ◄────┤ s_park           ◄───────────┘  │ │ │   │      │
    │    │ (STATION_PARK)   │              │ │ │   │      │
    │    └──────────────────┘              │ │ │   │      │
    │                                      │ │ │   │      │
    │    ┌──────────────────┐              │ │ │   │      │
    ◄────┤ s_tune           ◄──────────────┘ │ │   │      │
    │    │ (STATION_TUNE)   │◄───────────────┘ │   │      │
    │    └──────┬───────────┘                  │   │      │
    │           │                              │   │      │
    │           └───► s_go_on_cw ──►───────────┘   │      │
    │                                              │      │
    │    ┌──────────────────┐                      │      │
    ◄────┤ s_on_fm          │                      │      │
    │    │ (STATION_ON_FM)  │──► go_on_fm_to_tune ─┼──►───┘
    │    └──────────────────┘              │        │
    │                                     ▼        │
    │    ┌──────────────────┐          s_tune      │
    ◄────┤ s_on_cw          │                      │
         │ (STATION_ON_CW)  │──► go_on_cw_to_tune ┘
         │                  │──► s_go_tickleon/off
         └──────────────────┘
              │        ▲
              │        │ (fault_stnoff)
              └────►───┘
                  s_go_stn_reset (auto-reset)
```

### Fault Detection and Auto-Reset

The state machine monitors multiple fault conditions:

- **`fault_detected`** — General fault flag in any ON state
- **`fault_stnoff`** — Forces transition to OFF on hardware fault
- **`iqfm_fault`** — I/Q fault during FM mode
- **Vacuum errors** — `vacuum_err1`, `vacuum_err2` (latched and severity)
- **HVPS contactor status** — Monitored to prevent auto-reset if contactor is bad

**Auto-Reset Parameters:**

| Parameter | PV | Default |
|-----------|------|---------|
| Max retry count | `SRF1:STN:RESET:COUNTER` | 25 |
| Vacuum wait | hardcoded | 10 seconds |
| Inter-attempt delay | hardcoded | 5 seconds |
| DAC reset value | `DACRESET` | 0 |
| Reset wait ticks | `RESETWAIT` | 300 (at 10ms/tick = 3 seconds) |

**Auto-reset is inhibited if:**
- Forced fault condition active
- HVPS contactor status is bad
- Panel is off
- Vacuum is bad

### Fault Data Capture

On each fault, the system captures 11 diagnostic files (`NUMFFILES = 11`):

1. RFP sine I buffer
2. RFP sine Q buffer
3. RFP cosine I buffer
4. RFP cosine Q buffer
5. CF2 I history buffer
6. CF2 Q history buffer
7. IQA1 amplitude history
8. IQA2 amplitude history
9. IQA3 amplitude history
10. GVF reference buffer
11. AIM history buffer (added June 2003)

Up to **15 faults** are stored with timestamps (`NUMFAULTS = 15`), accessible via `SRF1:STN:FAULT:TIME1` through `SRF1:STN:FAULT:TIME15`.


---

## 8. SNL Sequence Programs

Six State Notation Language (SNL) programs run concurrently in the IOC:

### 8.1 `rf_states.st` — Master Station Control

- **Size**: ~2,412 lines (largest file in the codebase)
- **Authors**: Robert C. Sass (original, 1997), Stephanie Allison, Mike Zelazny, M. Laznovsky
- **Program declaration**: `program rf_states("STN=RRRS,name=SRFSTATES")`
- **Options**: `-a` (synchronous pvGets), `+c` (wait for all connections)
- **Function**: Controls station state transitions, fault handling, auto-reset, tickle mode
- **Key PVs monitored**: `SRF1:STN:STATE:CTRL` (desired state), `SRF1:STN:STATE:RBCK` (actual state)
- **Auxiliary PVs assigned**: FM/tickle file references, all fault tracking PVs
- **See Section 7** for full state machine analysis

### 8.2 `rf_tuner_loop.st` — Per-Cavity Tuner Control

- **Size**: ~400 lines
- **Author**: Stephanie Allison (Oct 1996)
- **Program declaration**: `program rf_tuner_loop("STN=RRRS,CAV=X,name=CXTUNRLOOP")`
- **Options**: `+r` (reentrant — 4 instances for C1-C4), `-a` (synchronous), `+c` (wait for connections)
- **States**: `loop_init` → `loop_unknown` → `loop_reset` → `loop_on`
- **Function**: Converts load angle phase error to stepper motor position delta
- **Mechanism**: Uses `subIQphase2posn` to compute tuner moves
- **Handles**: Reset requests, set-home, bad load angle conditions

### 8.3 `rf_hvps_loop.st` — HVPS Voltage Regulation

- **Size**: ~350 lines
- **Author**: Mike Zelazny (Feb 1997)
- **Program declaration**: `program rf_hvps_loop("STN=RRRS,name=HVPSLOOP")`
- **States**: `init` → `off` → `proc` (processing) → `on` (regulation)
- **Cycle time**: ~0.5 seconds
- **Processing mode**: Ramps HVPS voltage up/down based on vacuum status, drive power, cavity conditions
- **On mode**: Adjusts voltage to maintain constant drive power or gap voltage
- **Monitors**: Klystron drive power, cavity vacuums, gap voltage

### 8.4 `rf_dac_loop.st` — Drive/Gap Voltage DAC Adjustment

- **Size**: ~300 lines
- **Author**: Stephanie Allison (May 1997)
- **Program declaration**: `program rf_dac_loop("STN=RRRS,name=DACLOOP")`
- **States**: `loop_init` → `loop_off` → `loop_tune` → `loop_on`
- **Function**: Adjusts RFP DAC amplitude counts or GFF reference values
- **Tune mode**: Adjusts for drive power setpoint
- **On_CW mode**: Adjusts for gap voltage (direct loop on) or drive power (direct loop off)
- **Operates on**: Tuner mode setpoint, difference node offset, GFF reference values

### 8.5 `rf_calib.st` — RFP Octal DAC Calibration

- **Size**: ~200 lines
- **Function**: Calibrates the 8 DACs on the RFP module
- **Used during**: Initial setup and periodic recalibration

### 8.6 `rf_msgs.st` — Message Logging

- **Size**: ~150 lines
- **Function**: Monitors station events and logs messages to the EPICS message system
- **Watches**: State changes, fault conditions, sequence events

### Sequence Startup (from `st.cmd`)

All sequences are started in the IOC boot script with macro substitutions:

```
seq &rf_states, "STN=SRF1,name=SRFSTATES"
seq &rf_tuner_loop, "STN=SRF1,CAV=1,name=C1TUNRLOOP"
seq &rf_tuner_loop, "STN=SRF1,CAV=2,name=C2TUNRLOOP"
seq &rf_tuner_loop, "STN=SRF1,CAV=3,name=C3TUNRLOOP"
seq &rf_tuner_loop, "STN=SRF1,CAV=4,name=C4TUNRLOOP"
seq &rf_hvps_loop, "STN=SRF1,name=HVPSLOOP"
seq &rf_dac_loop, "STN=SRF1,name=DACLOOP"
seq &rf_calib, "STN=SRF1,name=RFCALIB"
seq &rf_msgs, "STN=SRF1,name=RFMSGS"
```

Note: 9 sequence instances total (4 for tuner loop, 1 each for the other 5).


---

## 9. EPICS Database and PV Structure

### PV Naming Convention

**Format**: `SRF1:<subsystem>:<parameter>[:<field>]`

| Prefix | Subsystem | Example PVs |
|--------|-----------|-------------|
| `SRF1:STN:` | Station-level control | `STATE:CTRL`, `STATE:RBCK`, `FAULT:NUM`, `RESET:COUNTER` |
| `SRF1:CAV1:`–`SRF1:CAV4:` | Per-cavity parameters | Gap voltage, phase, coupling, vacuum |
| `SRF1:STN:RFP:` | RFP module | DAC values, loop gains, DSP status |
| `SRF1:STN:IQA1/2/3:` | IQA modules | I/Q values, amplitude, history |
| `SRF1:STN:GVF:` | GVF module | Feed-forward config, LFB parameters |
| `SRF1:STN:CLK:` | Clock module | Reference status, config ID |
| `SRF1:STN:AIM:` | Arc interlock | Thresholds, trip status, history |
| `SRF1:STN:CF2/CFM:` | Comb filter | IIR coefficients, loop status |
| `SRF1:STNHVPS:` | HVPS | Voltage, current, contactor status |
| `SRF1:STNKLYS:` | Klystron | Drive power, efficiency, temperatures |
| `SRF1:CAV{n}TUNR:` | Cavity tuners | Position, home, loop on/off |
| `SRF1:STNVACM:` | Vacuum | Ion pump current, interlock |
| `SRF1:STNCOMB:` | Comb loop | Phase, gain, reset |

### Database Template Categories (~80 files in `rfApp/Db/`)

#### Station and System

| File | Purpose |
|------|---------|
| `rf_stn.db` | Station-level control PVs (state, fault, reset, settling times) |
| `rf_stn_cav.db` | Per-cavity station parameters |
| `rf_stn_All.substitutions` | Full station template with all sub-files |
| `rf_stn_4CV.substitutions` | 4-cavity variant |
| `rf_stn_4CVAll.substitutions` | 4-cavity with all subsystems |
| `rf_stn_2CV.substitutions` | 2-cavity variant (PEP-II) |

#### VXI Modules

| File | Purpose |
|------|---------|
| `rfp.db`, `rfp_dacs.db` | RFP record and DAC control |
| `iqa.db`, `rf_iqa.db` | IQA record and processing |
| `rf_iqa_module.db` | IQA module-level parameters |
| `rf_iqa_scale.db` | IQA scaling factors |
| `iqGet.db`, `iqCvt.db` | I/Q acquisition and conversion |
| `clk.db` | Clock module record |
| `aim.db` | Arc interlock record |
| `gvf.db` | GVF record |
| `cf2.db`, `cfm.db` | Comb filter records |

#### HVPS and Klystron

| File | Purpose |
|------|---------|
| `rf_hvps.db` | HVPS control and monitoring |
| `rf_digital_hvps.db` | Digital HVPS interface |
| `rf_klys.db` | Klystron parameters (filament time, window temp, solenoid current) |
| `rf_digital_modu.db` | Digital modulator interface |

#### Cavity and Beam

| File | Purpose |
|------|---------|
| `rf_cav.db` | Per-cavity parameters (gap voltage, coupling, vacuum) |
| `rf_beam.db` | Beam-related calculations |
| `rf_beam_spr.db` | SPEAR-specific beam parameters |
| `rf_fbck.db` | Feedback parameters |

#### I/O and Interlocks

| File | Purpose |
|------|---------|
| `rf_analog.db`, `rf_analog_log.db` | Analog signal monitoring |
| `rf_digital_All.substitutions` | All digital I/O points |
| `rf_digital_plc.db` | PLC digital interface |
| `rf_interlock.db` | General interlocks |
| `rf_interlock_arc.db` | Arc-specific interlocks |
| `rf_interlock_vxi.db` | VXI-related interlocks |

#### Temperature and Environment

| File | Purpose |
|------|---------|
| `rf_temp.db` | Temperature monitoring (cavity, klystron, water) |
| `rf_temp_4CV.substitutions` | 4-cavity temperature layout |

#### Allen-Bradley PLC

| File | Purpose |
|------|---------|
| `rf_ab_module.db` | AB module template |
| `rf_ab_4CV.substitutions` | 4-cavity AB I/O layout |
| `ab_adapter.db`, `ab_adapter_card.db` | AB adapter configuration |
| `ab_dcm_table.db` | DCM routing table |

#### Summary and Alarm Records

| File | Purpose |
|------|---------|
| `rf_sumy_stn.db`, `rf_sumy_stn_spr.db` | Station summary alarms (SPEAR-specific) |
| `rf_sumy_4CV.db` | 4-cavity summary |
| `rf_sumy_arc_4CV.db` | Arc interlock summary |
| `rf_sumy_cav.db` | Cavity summary |
| `rf_sumy_circ.db` | Circulator summary |
| `rf_sumy_hvps.db` | HVPS summary |
| `rf_sumy_klys.db` | Klystron summary |
| `rf_sumy_plc.db` | PLC communication summary |
| `rf_sumy_wg.db` | Waveguide summary |

### IOC-Specific Configuration (`rfApp/DbIoc/`)

| File | Purpose |
|------|---------|
| `srf1.substitutions` | **Main SPEAR3 station** — fully populated with `RRRS=SRF1, RNG=SPEAR, ID=2, REG=1` |
| `srf2.substitutions` | Template for 2nd station (not deployed) |
| `srf3.substitutions` | Template for 3rd station (not deployed) |

### Macro Substitutions

The database uses consistent macros across all templates:

| Macro | Meaning | SPEAR3 Value |
|-------|---------|--------------|
| `RRRS` | Station name | `SRF1` |
| `RNG` | Ring identifier | `SPEAR` |
| `ID` | Configuration ID | `2` |
| `REG` | Region | `1` |
| `PS` | Power supply | `RF-SOLN-MAIN` |


---

## 10. SPEAR3-Specific Adaptations

The codebase was originally written for PEP-II and adapted for SPEAR3. The following table summarizes all known differences:

### PEP-II vs SPEAR3 Comparison

| Parameter | PEP-II (HER/LER) | SPEAR3 |
|-----------|-------------------|--------|
| Configuration ID | 0 or 1 | **2** |
| Harmonic Number | 3,492 | **372** |
| Cavities per Station | 2 or 4 | **4** |
| RF Frequency | 476 MHz | **476 MHz** (same) |
| Ripple Loop | `ripple.s` (34 fast coefficients) | **`sp3ripple.s` (26 fast coefficients)** |
| Amplitude Coefficients | `AmplCoefs.tbl` | **`Sp3AmpCoefs.tbl`** |
| Phase Coefficients | `PhaseCoefs.tbl` | **`Sp3PhsCoefs.tbl`** |
| Beam Substitutions | `rf_beam_her.substitutions` / `rf_beam_ler.substitutions` | **`rf_beam_spear.substitutions`** |
| Station Summary | `rf_sumy_stn_pep.db` | **`rf_sumy_stn_spr.db`** |
| Beam-Specific DB | `rf_beam.db` | **`rf_beam_spr.db`** |
| Comb Filter | Full use (high harmonic → many coupled-bunch modes) | **Limited use** (low harmonic) |
| I/Q Reference Waveforms | `DRIVE_HER_I/Q`, `DRIVE_LER_I/Q` | Generic noise/sweep tables |
| IQA DDF Reports | `iqaDdf_23KHz.rpt`, `iqaDdf_50Hz.rpt` | Same |
| Station Naming | Various HER/LER prefixes | **SRF1** |

### SPEAR3-Specific Files

Files created or modified specifically for SPEAR3:

| File | Purpose |
|------|---------|
| `rfApp/src/dsp/rfpDsp/sp3ripple.s` | Ripple loop with 26 fast coefficients |
| `rfApp/src/dsp/sp3rippleRfp` | SPEAR3 ripple build script |
| `iocBoot/tbl/Sp3AmpCoefs.tbl` | SPEAR3 amplitude calibration |
| `iocBoot/tbl/Sp3PhsCoefs.tbl` | SPEAR3 phase calibration |
| `rfApp/Db/rf_beam_spear.substitutions` | SPEAR beam parameters |
| `rfApp/Db/rf_beam_spr.db` | SPEAR beam database |
| `rfApp/Db/rf_sumy_stn_spr.db` | SPEAR station summary |
| `rfApp/DbIoc/srf1.substitutions` | SPEAR station configuration (ID=2) |

### Runtime Configuration Switching

The code uses the configuration ID (`ID=2`) to select SPEAR3 parameters at runtime. In `p2RfLib.h`:

```c
/* Harmonic number depends on ring ID */
#define P2RF_K_HARMNO(i) ((i)==2 ? 372 : 3492)
```

This means the same binary can theoretically run on PEP-II or SPEAR3 hardware — the ring is selected by the `ID` macro passed through database substitutions and read from the CLK module's config register.

### Calibration and Reference Tables (`iocBoot/tbl/`)

**SPEAR3-Specific Tables:**
- `Sp3AmpCoefs.tbl` — Amplitude coefficients tuned for SPEAR3 cavity response
- `Sp3PhsCoefs.tbl` — Phase coefficients tuned for SPEAR3

**Generic Tables (shared PEP-II/SPEAR3):**
- `NOISE_I`, `NOISE_Q` and variants — Noise floor reference waveforms
- `SINE_I`, `SINE_Q` — Sine reference waveforms
- `SWEEP_400_I/Q`, `SWEEP_1000_I/Q` — Frequency sweep tables
- `TICKLE_I/Q` — Beam tickle (tune measurement) references
- `NUS1KHZ_I/Q` — 1 kHz noise references
- `WOOFER_NOISE.tbl` — Low-frequency noise compensation

**PEP-II-Only Tables (not used by SPEAR3):**
- `DRIVE_HER_I/Q`, `DRIVE_LER_I/Q` — PEP-II ring-specific drive
- `cfmIirCoefsHER.tbl`, `cfmIirCoefsLER.tbl` — Comb filter coefficients
- `detunEqHER.tbl`, `detunEqLER.tbl` — Detuning equalization
- `gvfHERdetun.tbl`, `gvfLERdetun.tbl` — GVF ring-specific detuning


---

## 11. Allen-Bradley PLC Integration

### Hardware Configuration

The Allen-Bradley 1771 PLC scanner (DCM — Data Communications Module) occupies VXI Slot 1 and interfaces with the PLC I/O racks. From `config.ab`:

| Rack | Population | Purpose |
|------|------------|---------|
| Rack 1 | Fully populated | Primary digital/analog I/O (temperatures, interlocks, HVPS status) |
| Rack 2 | ~75% populated | Additional I/O |
| Rack 3 | ~25% populated | Spare capacity |

### Software Stack

The `allenBradley/` directory contains the complete driver package:

**Core Driver (`basicSrc/`):**
- `drvAb.c/h` — Main Allen-Bradley scanner driver
- `devABBINARY.c` — Binary I/O device support (bi, bo, mbbi, mbbo)
- `devABStatus.c` — Scanner status monitoring

**1771 DCM Module (`1771DCMSrc/`):**
- `abDcm.h` — DCM data structures
- `abDcmRecord.c/dbd` — Custom DCM EPICS record
- Device support for all standard record types:
  - `devAiAbDcm.c`, `devAoAbDcm.c` — Analog I/O
  - `devAiAbDcmi2f.c`, `devAoAbDcmi2f.c` — Integer-to-float conversion variants
  - `devBiAbDcm.c`, `devBoAbDcm.c` — Binary I/O
  - `devLiAbDcm.c`, `devLoAbDcm.c` — Long integer I/O
  - `devMbbiAbDcm.c`, `devMbboAbDcm.c` — Multi-bit binary I/O

**Additional Module Drivers:**
- `1746HSTP1Src/` — Stepper motor via AB 1746-HSTP1
- `1771IFESrc/` — 1771-IFE analog input
- `1771IXSrc/` — 1771-IX thermocouple input
- `1771NSeriesSrc/` — N-series modules
- `1791BlockIOSrc/` — 1791 block I/O
- `SLCDCMSrc/` — SLC-500 DCM alternative
- `gpIfaceSrc/` — General purpose interface

### PLC-Monitored Signals

Through the AB PLC interface, the LLRF system monitors:
- **Temperatures**: Cavity body, klystron window, water cooling, ambient air
- **Digital interlocks**: Water flow, vacuum, door switches, MPS status
- **HVPS status**: Contactor position, voltage/current readbacks
- **Klystron parameters**: Filament current, solenoid current, body current


---

## 12. Fault Handling and Diagnostics

### Diagnostic Utilities (`rfApp/src/diag/`)

| File | Purpose |
|------|---------|
| `rf_rfpDiags.c` | RFP module DSP board diagnostics (memory test, register verification, DAC test) |
| `rf_ripTest.c` | Ripple loop functional test (injects known signals, verifies DSP response) |
| `rf_vxi_diag.c/h` | VXI bus diagnostic routines (A16 register read/write tests for all RF modules) |

### DSP Memory and Self-Tests

| Program | Location | Purpose |
|---------|----------|---------|
| `dsptestRfp` | `rfApp/src/dsp/` | RFP DSP functional test |
| `dsptestGvf` | `rfApp/src/dsp/` | GVF DSP functional test |
| `dspmemtestRfp` | `rfApp/src/dsp/` | RFP DSP memory test |
| `dspmemtestGvf` | `rfApp/src/dsp/` | GVF DSP memory test |

### Fault Hierarchy

```
Station Fault (SRF1:STN:FAULT:*)
    │
    ├── HVPS/Klystron Faults
    │   ├── HVPS contactor bad
    │   ├── Klystron overcurrent
    │   ├── Klystron window overtemp
    │   └── Filament fault
    │
    ├── Cavity Faults (per cavity)
    │   ├── Vacuum interlock (ion pump)
    │   ├── Reflected power high
    │   ├── Arc detected (AIM)
    │   └── Temperature alarm
    │
    ├── VXI Module Faults
    │   ├── RFP DSP error
    │   ├── IQA communication loss
    │   └── Module not responding
    │
    ├── PLC Communication Faults
    │   ├── AB scanner timeout
    │   └── Rack communication error
    │
    └── Control Loop Faults
        ├── Direct loop out of range
        ├── Tuner at limit
        └── HVPS regulation failure
```

### Summary Alarm Records

The system uses cascading summary records for alarm aggregation:

| Level | Database | Aggregates |
|-------|----------|-----------|
| Station | `rf_sumy_stn_spr.db` | All subsystem summaries |
| HVPS | `rf_sumy_hvps.db` | HVPS voltage, current, contactor |
| Klystron | `rf_sumy_klys.db` | Drive power, efficiency, temperatures |
| Cavity | `rf_sumy_cav.db` | Per-cavity gap voltage, phase, vacuum |
| Arc | `rf_sumy_arc_4CV.db` | AIM trip status, all 4 cavities |
| Circulator | `rf_sumy_circ.db` | Waveguide circulator status |
| Waveguide | `rf_sumy_wg.db` | Waveguide pressure, reflected power |
| PLC | `rf_sumy_plc.db` | AB scanner communication |

---

## 13. Build System and Dependencies

### Build Configuration

The build system uses EPICS standard `configure/` structure:

| File | Purpose |
|------|---------|
| `configure/RELEASE` | External dependency paths |
| `configure/CONFIG` | Compiler and platform settings |
| `configure/CONFIG_APP` | Application-specific config |
| `configure/RULES*` | Build rules (standard EPICS + custom DSP rules) |

### External Dependencies

| Dependency | Version | Path |
|------------|---------|------|
| EPICS Base | 3.14.8.2 → 3.14.11 | `$(EPICS_BASE)` |
| SNCSEQ | seq-R2-0-13-spear1 | `$(SNCSEQ)` |
| iocStats | iocStats-R3-1-12-spear1 | `$(IOCSTATS)` |
| autosave/restore | restore-R1-0-2 | `$(RESTORE)` |

Note: The `-spear1` suffix on dependencies indicates SPEAR-specific builds or patches to standard EPICS modules.

### Build Notes

From `RELEASE_NOTES`:
> RF-SPEAR must be built on Solaris to use VxWorks 5.4 installed at SLAC. Since no Solaris machine has access to SPEAR NFS, the release must be checked out and built in AFS space and then moved to NFS space on a SPEAR Linux machine.

This indicates a complex cross-compilation workflow:
1. Source lives in AFS (Andrew File System)
2. Must be built on Solaris for VxWorks 5.4 cross-compilation
3. Build artifacts must be transferred to NFS for the IOC to boot

### DSP Build Process

DSP firmware has its own build chain separate from EPICS:
- `Makefile.Dsp` files in each DSP subdirectory
- Uses `dsp1610/` toolchain (as1600, ld1600, cpp16)
- Produces binary images loaded into DSP via VXI driver at IOC boot time

---

## 14. Release History

| Release | Date | Key Changes |
|---------|------|-------------|
| **R0-0-0** | Sept 2012 | Initial SPEAR3 release (adapted from PEP-II) |
| **R0-0-1** | Oct 2012 | Moved epvxi, allenBradley, stepper to local (removed epics/site dependency) |
| **R0-0-2** | Mar 2013 | HCW temperature low alarm limit changes; separate low limit on load angle offset |
| **R0-0-3** | Jul 2014 | Magic T post temperature calculations based on ambient; increased klystron gain/efficiency precision; reduced HCW temp limits; removed ripple loop gain tracking from feedback severity sum |
| **R0-1-0** | Oct 2016 | iocStats upgrade to R3-1-12; klystron IP current rescaled to nA; window temp HIGH increase; crate location correction; added base routines |
| **R0-2-0** | Oct 2016 | Tuner connectors C and D swapped in software to match hardware wiring |
| **R0-3-0** | Jan 2017 | Undid C/D swap from R0-2-0; added `seq` record to stop & init all 4 cavity tuners |
| **R0-3-1** | Sept 2020 | Solenoid bucking coil current/voltage alarm limits for new klystron; committed 2018 production changes to CVS |
| **R0-3-2** | Sept 2020 | Klystron window air inlet alarm limits for new klystron |
| *(force-tag)* | Jan 2021 | `SRF1:FILAMENT:TIME` changed 1600 → 2100 seconds for new klystron |
| *(force-tag)* | Jun 2021 | Ambient air and cavity ion pump temperature alarm limit changes |

### Key Observations

1. **Very low release frequency**: 8 releases over 8 years (2012–2020), plus 2 force-tags in 2021
2. **Most changes are alarm limit adjustments**: Primarily for klystron replacements and temperature recalibrations
3. **No fundamental algorithm changes**: The core control loops, state machine, and DSP code have been stable since initial deployment
4. **Last official release**: September 2020 (R0-3-2)
5. **Force-tags indicate production urgency**: Changes were applied directly to production and retroactively tagged


---

## 15. Upgrade Considerations

### Obsolescence Risks (Critical)

| Component | Risk Level | Reason |
|-----------|-----------|--------|
| **VxWorks 5.4** | 🔴 Critical | End of life >15 years ago; no security patches, no vendor support |
| **MVME2400 PowerPC 604** | 🔴 Critical | Discontinued; no replacement boards available |
| **WE DSP1610** | 🔴 Critical | Obsolete processor; no modern toolchain support |
| **VXI bus** | 🔴 Critical | Effectively dead standard; module replacements unavailable |
| **EPICS 3.14.x** | 🟡 High | Far behind current EPICS 7.x; limited community support |
| **Allen-Bradley 1771** | 🟡 High | Legacy PLC; AB has moved to ControlLogix/CompactLogix |
| **CVS source control** | 🟡 Medium | Migrated to Git (this repo), but CVS artifacts (`,v` files) need interpretation |
| **Solaris build host** | 🟡 Medium | Solaris is EOL; cross-compilation workflow is fragile |
| **KSC V152 VXI-VME adapter** | 🟡 Medium | No longer manufactured; spares limited |

### What Must Be Preserved in an Upgrade

1. **Control loop algorithms**: The 8 feedback/feedforward loops are well-proven and must be replicated or improved
2. **State machine logic**: The 5-state + 11-transition station control is operationally validated over decades
3. **I/Q processing mathematics**: `subIQ.c` functions (phase, amplitude, power, DAC rotation) implement fundamental RF physics
4. **Interlock architecture**: The multi-level fault detection (AIM hardware → PLC → EPICS) protects expensive hardware
5. **Auto-reset logic**: The 25-retry auto-reset with vacuum/contactor checks keeps the beam running
6. **PV naming convention**: Operators and higher-level systems depend on `SRF1:*` naming
7. **Calibration tables**: SPEAR3-specific amplitude and phase coefficients represent real machine measurements

### What Can Be Modernized

1. **IOC platform**: Replace MVME2400 + VxWorks 5.4 with modern Linux IOC (e.g., Raspberry Pi, MicroTCA, or commodity x86)
2. **EPICS version**: Upgrade to EPICS 7.x with pvAccess, structured data, and modern tooling
3. **DSP processing**: Replace WE DSP1610 with FPGA-based digital processing (e.g., MicroTCA AMC, RFSoC, or custom FPGA board) — vastly higher bandwidth, floating-point, and configurable loop topologies
4. **VXI bus**: Replace with modern standard (MicroTCA, PCIe, Ethernet-based I/O)
5. **PLC interface**: Upgrade Allen-Bradley 1771 to modern EtherNet/IP or Modbus TCP
6. **State machines**: Port SNL to modern Python/C++ state engines with better testing and debugging
7. **Build system**: Modern CMake or Meson, CI/CD pipeline, containerized builds
8. **Source control**: Already migrated to Git; establish proper branching and release workflow

### Architecture Recommendations for Upgrade

```
Current System:                    Proposed Upgrade:
┌──────────────┐                  ┌──────────────────────┐
│ VxWorks 5.4  │                  │ Linux (RHEL/Debian)  │
│ MVME2400     │    ──────►       │ Modern x86/ARM IOC   │
│ EPICS 3.14   │                  │ EPICS 7.x            │
└──────┬───────┘                  └──────────┬───────────┘
       │                                     │
┌──────┴───────┐                  ┌──────────┴───────────┐
│ VXI Crate    │                  │ FPGA/RFSoC Board     │
│ RFP+IQA+GVF  │    ──────►      │ (replaces all VXI    │
│ +CLK+AIM     │                  │  modules + DSP)      │
│ DSP1610      │                  │ JESD204B/C ADC/DAC   │
└──────┬───────┘                  └──────────┬───────────┘
       │                                     │
┌──────┴───────┐                  ┌──────────┴───────────┐
│ AB 1771 PLC  │                  │ EtherNet/IP or       │
│ (digital/    │    ──────►       │ Modbus TCP I/O       │
│  analog I/O) │                  │ (modern PLC/SCADA)   │
└──────────────┘                  └──────────────────────┘
```

### Key Functional Requirements for Upgrade

1. **Fast feedback latency**: Direct loop must maintain µs-class response (FPGA essential)
2. **8 concurrent control loops**: Must operate simultaneously at their respective timescales
3. **4-cavity independent tuner control**: Reentrant architecture must be preserved
4. **Fault data capture**: 11 diagnostic buffers per fault event (can be expanded in upgrade)
5. **Auto-reset with 25 retries**: Autonomous recovery is operationally critical
6. **Operator PV compatibility**: Either preserve SRF1:* naming or provide mapping layer
7. **Calibration table loading**: Must support runtime coefficient updates for DSP/FPGA
8. **Arc interlock response**: < 10 µs trip time must be maintained (likely needs dedicated hardware)


---

## 16. Complete File Inventory

### Summary by Directory

| Directory | File Count | Description |
|-----------|-----------|-------------|
| `configure/` | 14 | Build configuration |
| `rfApp/src/db/` | 41 | VXI driver, record types, device support, subroutines |
| `rfApp/src/seq/` | 19 | SNL state machines and headers |
| `rfApp/src/base/` | 62 | Bus abstraction, DSP support, VXI interface, utilities |
| `rfApp/src/dsp/` | ~100 | DSP firmware (genDsp, rfpDsp, gvfDsp, obsDsp) |
| `rfApp/src/diag/` | 5 | Diagnostic routines |
| `rfApp/Db/` | 81 | EPICS database templates |
| `rfApp/DbIoc/` | 5 | IOC-specific substitutions |
| `rfApp/ksc_v152/` | 1,696 | VXI-VME adapter (PLD, driver, docs) |
| `iocBoot/b132-iocrf/` | ~60 | IOC boot files, VXI tables, calibration tables |
| `allenBradley/` | ~100 | Allen-Bradley PLC driver suite |
| `epvxi/` | ~30 | EPICS VXI resource manager |
| `stepper/` | 18 | Stepper motor record and device support |
| `dsp1610/` | ~30 | WE DSP1610 assembler toolchain |
| Attic (legacy) | 31 | Obsolete files from CVS |
| **Total** | **~2,291** | |

### Critical Source Files (Must-Read for Upgrade Team)

**Tier 1 — Core Logic (read first):**

| File | Lines | Why |
|------|-------|-----|
| `rfApp/src/seq/rf_states.st` | ~2,412 | Master station state machine — the "brain" of the system |
| `rfApp/src/db/subIQ.c` | ~1,200 | All I/Q processing math (phase, amplitude, DAC rotation) |
| `rfApp/src/db/drvP2RfVxi.c` | ~800 | Universal VXI hardware driver |
| `rfApp/src/db/p2RfLib.h` | ~300 | Key constants: RF frequency, harmonic number, config ID |
| `rfApp/src/db/rf_station_state.h` | ~50 | Station state definitions (5 states) |

**Tier 2 — Control Loops (read for algorithm understanding):**

| File | Lines | Why |
|------|-------|-----|
| `rfApp/src/seq/rf_tuner_loop.st` | ~400 | Per-cavity tuner control (reentrant) |
| `rfApp/src/seq/rf_hvps_loop.st` | ~350 | Klystron voltage regulation |
| `rfApp/src/seq/rf_dac_loop.st` | ~300 | Drive power / gap voltage setpoint |
| `rfApp/src/dsp/rfpDsp/sp3ripple.s` | ~500 | SPEAR3 ripple loop DSP assembly |
| `rfApp/src/dsp/gvfDsp/gvff.s` | ~400 | Gap voltage feed-forward DSP |
| `rfApp/src/db/subSys.c` | ~400 | System-level calculations |

**Tier 3 — Hardware Interface (read for porting):**

| File | Lines | Why |
|------|-------|-----|
| `rfApp/src/db/p2RfRfpRecord.c` | ~500 | RFP module record support |
| `rfApp/src/db/p2RfIqaRecord.c` | ~400 | IQA module record support |
| `rfApp/src/dsp/genDsp/dspCmdDef.h` | ~50 | DSP command protocol definition |
| `iocBoot/b132-iocrf/st.cmd` | ~200 | IOC startup sequence |
| `rfApp/DbIoc/srf1.substitutions` | ~50 | SPEAR3 station macro configuration |

**Tier 4 — Database Layer (reference for PV design):**

| File | Purpose |
|------|---------|
| `rfApp/Db/rf_stn.db` | Station-level PVs |
| `rfApp/Db/rf_cav.db` | Per-cavity PVs |
| `rfApp/Db/rf_hvps.db` | HVPS control PVs |
| `rfApp/Db/rf_klys.db` | Klystron monitoring PVs |
| `rfApp/Db/rf_iqa.db` | IQA processing PVs |
| `rfApp/Db/rf_temp.db` | Temperature monitoring PVs |
| `rfApp/Db/rf_interlock.db` | Interlock PVs |
| `rfApp/Db/rf_fbck.db` | Feedback parameter PVs |

---

## Appendix A: Key Authors and Contributors

| Name | Role | Key Contributions |
|------|------|-------------------|
| Robert C. Sass (RCS) | Lead developer (PEP-II era) | `rf_states.st`, core state machine, VXI driver |
| Stephanie Allison (SAA) | Lead developer | `rf_tuner_loop.st`, `rf_dac_loop.st`, record types, subroutines |
| R. Claus (Ric Claus) | DSP developer | `subIQ.c`, DSP firmware, ripple loop, diagnostics |
| P. Corredoura | DSP/controls | Ripple loop algorithm, comb filter design |
| Mike Zelazny | HVPS control | `rf_hvps_loop.st`, system integration |
| M. Laznovsky (LAZMO) | EPICS porting | EPICS 3.14 port, Allen-Bradley reset, VXI diagnostics |
| Kristi Luchini | VXI diagnostics | `rf_vxi_diag.c`, VXI test routines |
| W. Ross | DSP modifications | `sp3ripple.s` (SPEAR3 adaptation), ripple loop improvements |
| J. Sebek | Operations | Alarm limit adjustments for new klystron (2018–2021) |

---

## Appendix B: Glossary

| Term | Meaning |
|------|---------|
| AIM | Arc Interlock Module (VXI 340-307) |
| CF2/CFM | Comb Filter Module (VXI 340-301) |
| CLK | Clock & RF Distribution Module (VXI 340-306) |
| GFF | Gap Voltage Feed-Forward |
| GVF | Gap Voltage Feed-Forward Module (VXI 340-305) |
| HVPS | High Voltage Power Supply (klystron) |
| IQA | In-phase/Quadrature & Amplitude Detector (VXI 340-302) |
| LFB | Low-Frequency Beam Feedback |
| LLRF | Low-Level Radio Frequency (control system) |
| MPS | Machine Protection System |
| PEP-II | Positron-Electron Project II (B-Factory at SLAC) |
| RFP | RF Processing Module (VXI 340-304) |
| SNL | State Notation Language (EPICS sequencer) |
| SPEAR3 | Stanford Positron Electron Asymmetric Ring (3rd generation) |
| SRF1 | Station name (legacy PEP-II naming; does NOT indicate superconducting RF) |
| VXI | VME eXtensions for Instrumentation (bus standard) |

---

*End of Report*

