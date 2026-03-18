# SPEAR3 Legacy LLRF Codebase — Executive Summary & Upgrade Decision Matrix

**Document**: 00 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**Date**: March 2026 (Rev 2 — corrected with upgrade system context from PDR)

---

## CORRECTION NOTICE (Rev 2)

Rev 1 of this report contained errors that have been corrected:

1. **CFM, GVF/GFF modules are PEP-II heritage — NOT used for SPEAR3**. The VXI crate template (`crat_vxi_13slot.db` in `srf1.substitutions`) shows slot 3 is empty and slot 5 is "MPS Shutoff". The `rf_vxi_modules_All.substitutions` loads `gvf.db` (slot 3) and `cf2.db` (slot 5) but these are PEP-II template artifacts — the physical modules are not present in the SPEAR3 SRF1 crate. PDR Section 2.1 confirms only: CPU, AB controller, Clock, RFP, three IQAs, and AIM are in the VXI crate.

2. **The upgrade target is NOT a monolithic FPGA replacement**. It is a heterogeneous system: Dimtel LLRF9/476 (FPGA-based controller) + CompactLogix PLC (HVPS) + ControlLogix PLC (RF MPS) + Galil DMC-4143 (tuner motion) + Interface Chassis (hardware interlocks) + EPICS/Python/MATLAB coordinator.

3. **Eliminated loops**: Per PDR Section 15.7, the following legacy loops are eliminated because the LLRF9 digital feedback handles them internally:
   - Ripple rejection loop (DSP firmware)
   - Comb filter loop (CFM — PEP-II only)
   - Gap voltage feedback (GVF — PEP-II only)
   - 4-way DAC branching loop (rf_dac_loop.st)

---

## 1. System at a Glance

| Metric | Value |
|--------|-------|
| Total source files | **253** |
| Total lines of code | **82,430+** |
| Custom EPICS record types | **7** (RFP, GVF, IQA, AIM, CLK, CF2, CFM) — but only **4 active in SPEAR3** (RFP, IQA, AIM, CLK) |
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

### SPEAR3 SRF1 VXI Crate (Actual Physical Configuration)

From `srf1.substitutions` crate template and PDR Section 2.1:

| Slot | Module | In SPEAR3? | Record Type |
|------|--------|-----------|-------------|
| 0 | B132-IOCRF (KSC V152 CPU) | **Yes** | — |
| 1 | AB Scanner (VME adapter) | **Yes** | — |
| 2 | Clock | **Yes** | P2RfClkRecord |
| 3 | *(empty — GVF defined in software but NOT installed)* | **No** | — |
| 4 | RF Processing (RFP) | **Yes** | P2RfRfpRecord |
| 5 | MPS Shutoff *(not CF2 — CF2 defined in software but NOT installed)* | **Not CF2** | — |
| 6 | Link Passthru | — | — |
| 7 | IQA1 (Forward) | **Yes** | P2RfIqaRecord |
| 8 | *(empty)* | — | — |
| 9 | IQA2 (Reflected) | **Yes** | P2RfIqaRecord |
| 10 | *(empty)* | — | — |
| 11 | IQA3 (Cavity) | **Yes** | P2RfIqaRecord |
| 12 | Arc Interlock (AIM) | **Yes** | P2RfAimRecord |

**Active SPEAR3 VXI modules**: CPU, AB Scanner, Clock, RFP, 3× IQA, AIM = **8 modules**

## 2. Architecture — Legacy vs. Upgrade

### 2.1 Legacy Architecture (What This Codebase Implements)

```
Layer 6: SNL State Machines (6 programs)
         rf_states, rf_calib, rf_tuner_loop, rf_hvps_loop,
         rf_dac_loop, rf_msgs
Layer 5: EPICS Database & Subroutines (subIQ.c, subSys.c)
Layer 4: Custom Record Types (RFP, IQA, AIM, CLK active; GVF, CF2, CFM PEP-II heritage)
Layer 3: Device Support (devP2RfRfp, devP2RfIqa, devP2RfAim, devP2RfClk active)
Layer 2: Core VXI Driver (drvP2RfVxi.c) + AB PLC Driver (drvAb.c)
Layer 1: VXI Infrastructure (drvEpvxi.c) + KSC V152 + VxWorks RTOS
Layer 0: Hardware (VXI chassis, klystron, cavities, AB PLCs, stepper motors)
```

### 2.2 Upgrade Architecture (What the Legacy Code Informs)

From PDR Section 2.2 — the upgrade replaces all control electronics:

```
Layer 4: EPICS/Python/MATLAB Coordinator (~1 Hz supervisory)
         ← informed by rf_states.st, rf_hvps_loop.st, rf_tuner_loop.st
Layer 3: RF MPS PLC (ControlLogix 1756, ~ms)
         ← new system, informed by legacy AIM interlock logic
Layer 2: Interface Chassis (<1 µs hardware AND-gate)
         ← entirely new, no legacy equivalent
Layer 1: LLRF9 FPGA (<1 µs, 270 ns loop delay)
         ← replaces RFP + IQA + Clock + DSP firmware + analog feedback
Layer 0: Same RF plant (klystron, cavities, waveguide) + new peripherals
         Motor: Galil DMC-4143 (already commissioned!)
         HVPS: CompactLogix PLC (replaces SLC-500)
         Arc: Microstep-MIS optical (replaces non-functional legacy)
         Waveform Buffer: new monitoring system
         Heater: Programmable AC supply (replaces motor-driven variac)
```

## 3. Legacy → Upgrade Mapping (Key Table)

| Legacy Component | Lines | Upgrade Target | Migration Type | Priority |
|------------------|-------|---------------|---------------|----------|
| **rf_states.st** | 2,227 | Python/EPICS coordinator state machine | Spec extraction → rewrite | **High** |
| **rf_hvps_loop.st** | 343 | CompactLogix PLC ladder logic | Spec extraction → PLC code | **High** |
| **rf_tuner_loop.st** | 555 | LLRF9 built-in tuner + Python load-angle controller | Spec extraction → configure + rewrite | **High** |
| **rf_calib.st** | 3,345 | LLRF9 built-in calibration (Dmitry's software) | Verify equivalence | Medium |
| **rf_msgs.st** | 352 | EPICS logging + LLRF9 diagnostics | Spec extraction → EPICS records | Medium |
| **rf_dac_loop.st** | 290 | **ELIMINATED** — LLRF9 handles internally | Document for reference only | Low |
| **subIQ.c** (23 funcs) | 965 | EPICS coordinator calculations | Evaluate for reuse | Medium |
| **subSys.c** (11 funcs) | 464 | EPICS coordinator calculations | Evaluate for reuse | Medium |
| **devP2RfRfp.c** | 2,389 | **ELIMINATED** — LLRF9 replaces RFP module | Reference only | None |
| **devP2RfIqa.c** | 2,260 | **ELIMINATED** — LLRF9 replaces IQA modules | Reference only | None |
| **devP2RfAim.c** | 1,982 | **ELIMINATED** — replaced by Interface Chassis + Arc Detection | Reference for interlock spec | Low |
| **devP2RfClk.c** | 957 | **ELIMINATED** — LLRF9 has internal clock | Reference only | None |
| **DSP firmware** | 15,667 | **ELIMINATED** — LLRF9 FPGA handles all fast processing | None | None |
| **devP2RfGvf/Cfm/Cf2** | 6,807 | **NOT APPLICABLE** — PEP-II only, never used in SPEAR3 | None | N/A |
| **AB PLC drivers** | ~7,500 | **ELIMINATED** — new PLCs use Ethernet/IP | None | None |
| **Stepper motor code** | 2,763 | Galil DMC-4143 + EPICS motor record | **Already commissioned** | Done |
| **PV databases** | ~15,000 | PV alias mapping to new PV namespace | Direct extraction | **High** |
| **Table/coefficient files** | 57 files | Evaluate for LLRF9 compatibility | Check data format | Low |

## 4. Upgrade Decision Matrix (Revised)

### Codebase Breakdown by Upgrade Relevance

| Category | Files | Lines | % | Description |
|----------|-------|-------|---|-------------|
| **ELIMINATED** (LLRF9 replaces) | ~80 | ~35,000 | 42% | VXI driver, device support, DSP firmware, custom records — all replaced by LLRF9 |
| **PEP-II ONLY** (never used in SPEAR3) | ~30 | ~10,000 | 12% | GVF, CFM, CF2 device support, firmware, databases |
| **OBSOLETE INFRASTRUCTURE** | ~60 | ~15,000 | 18% | VxWorks, KSC V152, VXI bus browser, base utilities |
| **SPEC EXTRACTION** (informs new code) | ~30 | ~11,000 | 13% | SNL programs, HVPS/tuner loop logic, interlock specs |
| **REUSABLE** (physics/math) | ~10 | ~1,500 | 2% | subIQ.c, subSys.c, station state definitions |
| **PV REFERENCE** (preserves operator interface) | 78+ | ~15,000 | 18% | EPICS databases, substitution files, PV name patterns |
| **ALREADY DONE** | ~5 | ~2,700 | 3% | Stepper motor → Galil (commissioned August 2025) |

### Effort Estimates (Revised for Actual Upgrade)

| Effort Level | Scope | Duration |
|-------------|-------|----------|
| **Zero** (direct reuse) | subIQ.c, subSys.c, table files | — |
| **Small** (API updates) | Signal processing for EPICS coordinator | 1-2 weeks |
| **Medium** (spec extraction + rewrite) | Python state machine (from rf_states.st), PV mapping | 4-8 weeks |
| **Large** (new development) | EPICS coordinator, CompactLogix PLC code, Interface Chassis logic | 3-6 months |
| **Already done** | Galil tuner controller (commissioned August 2025) | Done |
| **External** (vendor) | LLRF9 firmware (Dmitry/Dimtel) | Vendor scope |

## 5. Protection Chain (4-Layer Architecture)

From PDR Section 17:

| Layer | Subsystem | Response | Legacy Equivalent |
|-------|-----------|----------|-------------------|
| 1 | LLRF9 FPGA | <1 µs | RFP analog feedback (no software equivalent) |
| 2 | Interface Chassis | <1 ms | AIM fast interlock chain (devP2RfAim.c) |
| 3 | RF MPS PLC (ControlLogix) | ~ms | PLC-5 via AB scanner (drvAb.c) |
| 4 | EPICS coordinator | ~1 Hz | SNL programs (rf_states.st, rf_hvps_loop.st) |

## 6. "First 2 Weeks" Priority (Revised)

1. **Extract rf_states.st state transitions** → write Python coordinator state machine spec
2. **Extract rf_hvps_loop.st** → write CompactLogix PLC functional specification
3. **Map legacy PV names to upgrade PV namespace** → create alias/migration table
4. **Extract rf_tuner_loop.st** → verify LLRF9 built-in tuner matches legacy behavior
5. **Evaluate subIQ.c/subSys.c** → which functions are needed in the EPICS coordinator?

## 7. Companion Documents

| Document | Content |
|----------|---------|
| [01-file-inventory.md](01-file-inventory.md) | Complete 253-file catalog with revised verdicts |
| [02-architecture-overview.md](02-architecture-overview.md) | PV naming, boot sequence, legacy→upgrade mapping |
| [03-vxi-device-support.md](03-vxi-device-support.md) | VXI driver + device support (ELIMINATED by LLRF9) |
| [04-dsp-firmware.md](04-dsp-firmware.md) | DSP algorithms (ELIMINATED by LLRF9 FPGA) |
| [05-snl-state-machines.md](05-snl-state-machines.md) | SNL programs — primary spec extraction targets |
| [06-plc-stepper-motors.md](06-plc-stepper-motors.md) | AB drivers (ELIMINATED) + stepper (ALREADY DONE) |
| [07-epics-databases.md](07-epics-databases.md) | PV structure — critical for PV migration mapping |
| [08-signal-processing.md](08-signal-processing.md) | subIQ.c + subSys.c — evaluate for coordinator reuse |

