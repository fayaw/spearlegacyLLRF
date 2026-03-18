# SPEAR3 Legacy LLRF Codebase — Executive Summary & Upgrade Decision Matrix

**Document**: 00 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**Date**: March 2026

---

## 1. System at a Glance

| Metric | Value |
|--------|-------|
| Total source files | **253** |
| Total lines of code | **82,430+** |
| Custom EPICS record types | **7** (RFP, GVF, IQA, AIM, CLK, CF2, CFM) |
| EPICS database files | **78+** (.db and .substitutions) |
| SNL state machine programs | **6** (+ 12 header/macro files) |
| DSP firmware programs | **4 directories** (~15,667 lines TMS320C16xx assembly) |
| PLC driver files | **~20** (Allen-Bradley SLC-500, PLC-5, 1746-HSTP1) |
| Subroutine functions | **23** in subIQ.c + **11** in subSys.c |
| Operating system | VxWorks (Motorola 68040 / PPC604) |
| EPICS version | R3.13.x era (pre-Base 3.14) |
| Hardware bus | VXI (VMEbus eXtensions for Instrumentation) |
| VXI controller | Kinetics Systems KSC V152 slot-0 |
| Source control | CVS (files stored as RCS `,v` archives) |

## 2. Architecture Summary

```
Layer 7: Operator Displays & Archiver (Channel Access clients)
         ─────────────────────────────────────────────────────
Layer 6: SNL State Machines (6 programs, ~7,112 lines)
         rf_states, rf_calib, rf_tuner_loop, rf_hvps_loop,
         rf_dac_loop, rf_msgs
         ─────────────────────────────────────────────────────
Layer 5: EPICS Database & Subroutine Records (78+ .db files)
         subIQ.c (23 I/Q math functions)
         subSys.c (11 system-level functions)
         ─────────────────────────────────────────────────────
Layer 4: Custom Record Types (7 types, ~2,371 lines)
         p2RfRfpRecord, p2RfGvfRecord, p2RfIqaRecord,
         p2RfAimRecord, p2RfClkRecord, p2RfCf2Record, p2RfCfmRecord
         ─────────────────────────────────────────────────────
Layer 3: Device Support (7 modules, ~15,059 lines)
         devP2RfRfp, devP2RfGvf, devP2RfIqa, devP2RfAim,
         devP2RfClk, devP2RfCf2, devP2RfCfm
         ─────────────────────────────────────────────────────
Layer 2: Core VXI Driver (drvP2RfVxi.c, 2,671 lines)
         + AB PLC Driver (drvAb.c, 2,039 lines)
         + Stepper Motor (steppermotorRecord.c, 959 lines)
         ─────────────────────────────────────────────────────
Layer 1: VXI Infrastructure (drvEpvxi.c, 4,622 lines)
         + KSC V152 controller + VxWorks RTOS
         ─────────────────────────────────────────────────────
Layer 0: Hardware (VXI chassis, SLAC PEP-II RF modules,
         AB PLCs, stepper motors, klystron, cavities)
```

## 3. VXI Chassis Slot Assignments (SRF1 Station)

From `srf1.substitutions`:

| Slot | Module | Record Type |
|------|--------|-------------|
| 0 | B132-IOCRF (KSC V152 CPU) | — |
| 1 | AB Scanner (VME adapter) | — |
| 2 | Clock | P2RfClkRecord |
| 4 | RF Processing (RFP) | P2RfRfpRecord |
| 5 | MPS Shutoff | — |
| 6 | Link Passthru | — |
| 7 | IQA1 (Forward) | P2RfIqaRecord |
| 9 | IQA2 (Reflected) | P2RfIqaRecord |
| 11 | IQA3 (Cavity) | P2RfIqaRecord |
| 12 | Arc Interlock (AIM) | P2RfAimRecord |

Additional modules (GVF, CF2/CFM) vary by station configuration.

## 4. Upgrade Decision Matrix

### 4.1 Verdict Categories

| Verdict | Meaning |
|---------|---------|
| **REMOVE** | Hardware-specific code that has no equivalent in the new system. Will be entirely replaced by new hardware/firmware. |
| **RECREATE** | Functional logic that must be preserved but rewritten for new hardware/OS/EPICS version. |
| **ADAPT** | Code that can be adapted with moderate changes (e.g., API updates, OS porting). |
| **KEEP** | Logic that is directly reusable or needs only minor changes. |
| **REFERENCE** | Code that serves as the specification — the new implementation must replicate its behavior. |

### 4.2 Subsystem Verdicts

| Subsystem | Files | Lines | Verdict | Rationale |
|-----------|-------|-------|---------|-----------|
| **VXI Infrastructure** (epvxi/) | 8 | 7,401 | **REMOVE** | VXI bus is being replaced. No VXI in new system. |
| **KSC V152 Controller** (ksc_v152/) | ~30 | ~5,000 | **REMOVE** | Slot-0 controller hardware is being replaced. |
| **Core VXI Driver** (drvP2RfVxi.c/h) | 2 | 2,862 | **REMOVE** | VXI register abstraction has no equivalent in new system. However, the DSP communication protocol and table loading logic are **REFERENCE** material. |
| **Device Support Modules** (devP2Rf*.c) | 7 | 15,059 | **REMOVE** → **REFERENCE** | These files encode the complete operational semantics of each module type. The new device support will be completely different (FPGA registers instead of VXI), but every control function, state machine, and DAC loading sequence documented here must be replicated. |
| **Custom Record Types** (p2Rf*Record.c) | 7 | 2,203 | **REMOVE** → **RECREATE** | The record field definitions (which PVs exist, their types, and links) are the de-facto specification. New records will need equivalent fields to preserve the PV interface. |
| **Register Definitions** (p2Rf*Def.h) | 7 | 2,747 | **REMOVE** → **REFERENCE** | Register maps are specific to old hardware. But they define the functional capabilities that new hardware must match. |
| **DSP Firmware** (rfpDsp/, gvfDsp/, obsDsp/, genDsp/) | ~60 | 15,667 | **REMOVE** → **REFERENCE** | TMS320C16xx assembly is being replaced by FPGA. But the algorithms (ripple rejection, feed-forward, I/Q processing, sqrt, trig) must be replicated in FPGA firmware. |
| **SNL State Machines** (rf_*.st) | 6 | 7,112 | **RECREATE** | Station state machine, calibration, tuner loop, HVPS loop, DAC loop, messaging — all must be reimplemented. SNL may or may not be the target language. These are the closest thing to a "specification" of operational procedures. |
| **SNL Header/Macro Files** (rf_*_defs.h, etc.) | 12 | 1,151 | **RECREATE** | PV names, status definitions, control macros. These define the operator interface contract. |
| **Signal Processing** (subIQ.c) | 1 | 965 | **KEEP** / **ADAPT** | Pure math functions (atan2, sqrt, power calculations). No hardware dependency. Can be reused directly or with minimal EPICS API updates. |
| **System Calculations** (subSys.c) | 1 | 464 | **KEEP** / **ADAPT** | Frequency offset, phase combining, DC coefficient calculations. Hardware-independent math. |
| **Allen-Bradley Drivers** (allenBradley/) | ~20 | ~7,500 | **EVALUATE** | Depends on whether AB PLCs are retained. If HVPS PLC is kept → ADAPT existing AB driver. If HVPS is replaced → REMOVE. Community AB drivers may be available for modern EPICS. |
| **Stepper Motor** (stepper/) | 5 | 2,763 | **EVALUATE** | If cavity tuners keep AB 1746-HSTP1 → ADAPT. If stepper controller changes → use community motor record. Custom `steppermotorRecord` can likely be replaced by standard EPICS motor record. |
| **EPICS Databases** (Db/) | 78 | ~15,000 | **RECREATE** | The .db files define the complete PV structure. New databases will differ in record types but must preserve the PV naming convention and operator interface. |
| **Base Utilities** (rfApp/src/base/) | 45+ | ~10,000 | **REMOVE** | VXI bus browser, DSP download, bus access, memory test — all VxWorks/VME-specific. |
| **Diagnostics** (rfApp/src/diag/) | 1 | 2,328 | **REMOVE** → **RECREATE** | VXI-specific diagnostics. New system needs equivalent diagnostics for new hardware. |
| **Boot Configuration** (iocBoot/) | 10+ | ~1,000 | **RECREATE** | Startup scripts, AB config, VXI addressing — all must be recreated for new IOC. |
| **Table/Coefficient Files** (iocBoot/tbl/) | 57 | — | **KEEP** | Waveform tables, DDF filter definitions, IIR coefficients. These encode physics — keep as-is if new hardware uses same data format. |
| **Init Hooks** (p2RfInitClk.c, p2RfInitHooks.c) | 2 | 375 | **REMOVE** → **REFERENCE** | VXI clock module pre-initialization and boot sequence. Logic must be replicated for new system. |
| **VxWorks Support** (fast_lock.h, misc) | 3 | ~300 | **REMOVE** | VxWorks-specific locking, RTOS-specific APIs. Replace with EPICS base OS-independence layer (epicsMutex, etc.). |

### 4.3 Effort Estimates

| Effort Level | Subsystems | Estimated Duration |
|-------------|------------|-------------------|
| **Zero effort** (direct reuse) | subIQ.c, subSys.c, table files | — |
| **Small** (API updates) | Signal processing adaptation | 1-2 weeks |
| **Medium** (significant rewrite) | SNL state machines, EPICS databases, stepper motor | 4-8 weeks |
| **Large** (full reimplementation) | New device support, new record types, FPGA firmware | 3-6 months |
| **N/A** (removed) | VXI infrastructure, KSC, VxWorks-specific code | — |

## 5. Critical Dependencies

```
                    ┌─────────────────────┐
                    │   rf_states.st      │ ◄── Master state machine
                    │ (stations: OFF,     │     controls everything
                    │  STANDBY, ON_CW,    │
                    │  FAULT)             │
                    └──┬──┬──┬──┬──┬─────┘
                       │  │  │  │  │
         ┌─────────────┘  │  │  │  └──────────────┐
         │                │  │  │                  │
    ┌────▼─────┐   ┌──────▼──▼──▼──────┐   ┌──────▼──────┐
    │rf_hvps   │   │  7 Custom Records  │   │rf_tuner     │
    │_loop.st  │   │  (RFP,GVF,IQA,    │   │_loop.st ×4  │
    │          │   │   AIM,CLK,CF2,CFM) │   │             │
    └────┬─────┘   └──────┬─────────────┘   └──────┬──────┘
         │                │                        │
    ┌────▼─────┐   ┌──────▼─────────────┐   ┌──────▼──────┐
    │AB SLC-500│   │  7 Device Support  │   │steppermotor │
    │PLC via   │   │  + Core VXI Driver │   │Record via   │
    │drvAb.c   │   │  + DSP Firmware    │   │AB 1746-HSTP1│
    └──────────┘   └────────────────────┘   └─────────────┘
```

**Key dependency chain**: Any change to device support (Layer 3) requires updating the record types (Layer 4), which propagates to the database (Layer 5), which affects the SNL programs (Layer 6). This is unavoidable when replacing hardware.

## 6. Upgrade Priority ("First 2 Weeks" Checklist)

1. **Define FPGA register map** — This determines new device support structure
2. **Port subIQ.c and subSys.c** — Quick wins, preserves physics calculations
3. **Extract PV naming convention** — Document every PV name from .db files and SNL pvs.h files
4. **Map rf_states.st state transitions** — This is the operational specification
5. **Catalog DSP algorithms** — Document ripple loop, feed-forward, and observer algorithms from assembly comments for FPGA implementation

## 7. Companion Documents

| Document | Content |
|----------|---------|
| [01-file-inventory.md](01-file-inventory.md) | Complete 253-file catalog with verdicts |
| [02-architecture-overview.md](02-architecture-overview.md) | PV naming, boot sequence, VxWorks patterns, build system |
| [03-vxi-device-support.md](03-vxi-device-support.md) | VXI driver and all 7 device support modules |
| [04-dsp-firmware.md](04-dsp-firmware.md) | TMS320C16xx firmware: ripple, feed-forward, observer |
| [05-snl-state-machines.md](05-snl-state-machines.md) | All 6 SNL programs with state transition details |
| [06-plc-stepper-motors.md](06-plc-stepper-motors.md) | Allen-Bradley drivers and stepper motor subsystem |
| [07-epics-databases.md](07-epics-databases.md) | 78+ database files, PV structure, substitution patterns |
| [08-signal-processing.md](08-signal-processing.md) | subIQ.c and subSys.c function-by-function analysis |

