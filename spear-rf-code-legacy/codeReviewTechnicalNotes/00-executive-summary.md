# SPEAR3 Legacy LLRF Codebase — Executive Summary & Upgrade Decision Matrix

**Document**: 00 of 09 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**Date**: March 2026 (Rev 7 — PDR R1 cross-reference audit: added arc sensor count discrepancy, gap voltage arithmetic error, Interface Chassis response time reconciliation, PDR coverage gap analysis; see Rev 7 correction notice)
(Rev 6 — corrected rf_states.st state count, replaced fabricated calibration macro, clarified tuner loop state diagram)
(Rev 5 — extended TAXI terminology correction to SDD; added GVF software dependency cross-reference; added document hierarchy section)
(Rev 4 — corrected cross-note consistency issues found during deep audit; see Rev 4 correction notice)
(Rev 3 — corrected legacy state machine names; added missing document references; added open discrepancies)

---

## CORRECTION NOTICE (Rev 7)

Rev 7 addresses findings from a comprehensive cross-reference audit of the Physical Design Report R1 against the legacy source code and existing technical notes 00–08. A dedicated audit document has been created as [09-pdr-cross-reference-audit.md](09-pdr-cross-reference-audit.md).

19. **PDR §2.3 and §12.3 contain conflicting arc detection sensor counts (SAFETY-CRITICAL).** PDR §2.3 (line 201) states "total 12 Microstep-MIS optical sensors" and the architecture diagram (line 126) labels the arc detection block as "12sensor". However, PDR §12.3 (line 965) explicitly states "There are **6 sensors** total (updated from original design)". PDR §19.2 (line 1327) adds further ambiguity with "10 sensors and 5 process + 1 sensor & 1 process for spare". Legacy code evidence: `p2RfAimDef.h` defines `AIM_VERSION_12CH` and `AIM_K_CHANCNT = (AIM_IS7CH ? 7 : 12)` — the "12" number comes from the legacy AIM hardware which is being **replaced** by the Microstep-MIS system. Section 12.3 is authoritative ("6 sensors total, updated from original design"). §2.3 and the architecture diagram retain a stale legacy count. Added as §7.3 in the Open Discrepancies section.

20. **PDR §4.3 contains a gap voltage arithmetic error.** Line 255 states "~712 kV for a total of ~2.5 MV" — but 712 kV × 4 cavities = 2,848 kV ≈ **2.85 MV**, not 2.5 MV. PDR §1 (lines 46, 55) correctly states ~2.85 MV. This is a typographical error in §4.3. Added as §7.4 in the Open Discrepancies section.

21. **Interface Chassis response time: µs vs ms inconsistency (internal to Note 00 and PDR).** Note 00 §2 (line 142) described the Interface Chassis as "<1 µs hardware AND-gate" while the §5 protection chain table (line 209) listed "<1 ms". The PDR similarly mixes "microsecond scale" (§7.1, line 624) with "<1 ms" (§7.6 table, line 674; §14.4, line 1194). Reconciliation: the Interface Chassis AND-gate propagation delay is **µs-scale** (pure hardware logic); the "<1 ms" figure represents an upper bound including optocoupler and fiber-optic transceiver latency. The §5 table has been updated with a clarifying footnote.

22. **GVF/TAXI dependency is not addressed in PDR upgrade design.** Note 07 correctly documents that GVF database records are loaded and actively used by the `rf_msgsTAXI` state set for LFB resync fault recovery. However, PDR §10 (Tuner Control System) makes no mention of GVF/TAXI dependency, failure modes if the GVF module is absent, or how LFB resync is handled in the upgrade. This is a design documentation gap — flagged as §7.5 in the Open Discrepancies section.

23. **Note 08 §2.3: subIQamplCplg visibility anomaly.** `subIQamplCplg()` (line 218 of `subIQ.c`) is the only function in the file declared without the `static` keyword, making it externally visible. All other 22 functions use `static long`. Footnote added to Note 08 §2.1.

24. **PDR coverage gap analysis added.** Seven PDR sections describing new or upgraded subsystems have no corresponding technical note coverage. A coverage map (§9) has been added to this document, and the complete audit is in [09-pdr-cross-reference-audit.md](09-pdr-cross-reference-audit.md).

---

## CORRECTION NOTICE (Rev 6)

Rev 6 addresses three issues found during a third-pass deep-dive, cross-referencing all SNL source files directly against Note 05 claims:

16. **Note 05 §2.2 state count was off by one: 22→23.** The note reported "22-state legacy machine" but the actual `rf_states.st` source (verified via `grep "^[[:space:]]*state "`) contains **23 SNL states** across 3 concurrent state sets: 17 in `ss rf_states`, 5 in `ss rf_statesLP`, and 1 in `ss rf_statesFF`. The missing state was `s_init` — the one-time initialization state that reads the current state PV, configures IQA3 channel names, clears fault flags, and transitions immediately to `s_go_off`. The `s_init` state was not listed in the state tables and the total count was wrong by one. Both are now corrected: `s_init` has been added to the state enumeration with its purpose documented, and the upgrade mapping note updated to "23-state."

17. **Note 05 §3.3 "Macro Pattern" code block was fabricated; "hundreds of states" claim was incorrect.** The section showed a `#define CALIB_MEAS(cavity, signal, ...) \ state calib_meas_##cavity##_##signal {...}` macro with the claim it "is expanded for each cavity × each measurement × each DAC combination, resulting in hundreds of states." Verification result: searching `rf_calib.st,v` for `CALIB_MEAS` returns **zero matches** — this macro does not exist. The actual source contains **28 hand-written SNL states** (Init, Startup, CombCheck, ... Done). Code repetition is reduced via **utility macros** (`CAL_MSG`, `CHECK_ABORT`, `SET_CAV_OFFSETS`, etc.) that reduce boilerplate *within* state bodies, not macros that generate states. Cavity × measurement iteration is handled by **nested `for` loops** within states. §3.3 has been rewritten with the actual code structure, complete state list, utility macro table, and a representative source code excerpt from `ZeroCavMults`.

18. **Note 05 §4.2 tuner loop state diagram presented algorithmic control modes as SNL states.** The diagram showed TRACKING, MOVING, and SETTLING as separate boxes within the ON region, which could mislead a reader into searching for `state TRACKING`, `state MOVING`, and `state SETTLING` declarations. The actual `rf_tuner_loop.st` source contains **5 SNL states**: `loop_init`, `loop_unknown`, `loop_reset`, `loop_off`, `loop_on`. The TRACKING/MOVING/SETTLING behaviors are **algorithmic control modes** implemented via conditional branching within the single `loop_on` state, driven by variables `dmov_meas_count`, `sm_dmov`, `nomov_count`, and `loop_status`. A clarifying note has been added after the diagram explaining this distinction.

---

## CORRECTION NOTICE (Rev 5)

Rev 5 addresses issues found during a second-pass deep-dive cross-referencing source code, design documents, and existing technical notes:

11. **Note 07 §1.1 GVF software/hardware classification was misleading.** The table stated `gvf.db` is "PEP-II ONLY — GVF module not installed in SRF1". While the **hardware** is absent (slot 3 is empty), the GVF **database records ARE loaded** via `rf_vxi_modules_All.substitutions` and are **actively referenced** by the TAXI monitoring state set `rf_msgsTAXI` in `rf_msgs.st` (lines 196–352). Specific PVs: `{STN}:STN:GVF:MODU.GST1` (status), `{STN}:STN:GVF:MODU.TMCK` (TAXI timing check), `{STN}:STN:GVF:STATE` (run state), `{STN}:STN:GVF:LFBLOOP` (woofer loop). Removal of `gvf.db` would **break TAXI error monitoring and LFB resync fault recovery**. Table and new §1.1.1 added to Note 07.

12. **SDD also contains CAMAC TAXI terminology errors (extending correction #10).** The SDD (§1.4 line 99 and §22 line 1500) propagates and amplifies the same error flagged in the PDR: "CAMAC TAXI monitoring" and "CAMAC TAXI eliminated with VXI". TAXI is a **VXI serial link protocol**, not a CAMAC feature. CAMAC is a completely different parallel bus standard not used in SPEAR3. Both the PDR (§2.1, 1 instance) and SDD (§1.4 and §22, 2 instances) require terminology correction. See correction #10 below for original PDR reference.

13. **Note 02 boot sequence includes CLKMACROS which is NOT in st.cmd.** Note 02 §2.1 shows `putenv("CLKMACROS=S=2")` in the boot sequence putenv() block. However, this macro **does not appear in the production `st.cmd`** as archived in RCS (`iocBoot/b132-iocrf/st.cmd,v`). The 11 putenv() calls in st.cmd are: IQA3MACROS, DATABASE_MACROS, C1–C4 TUNRLOOP_MACROS, AB_CONFIG_FILE, RESTORE_AB, RESTORE_VXI, RESTORE_INP, RESTORE_FILENAME. CLKMACROS is consumed by `p2RfInitHooks.c` via `getenv("CLKMACROS")` and must be established through an external mechanism (VxWorks boot parameters or a deployment wrapper script). If not set, clock initialization is gracefully skipped. Clarification added to Note 02 §2.1.

14. **Note 05 rf_calib.st line count discrepancy with design documents.** Both the PDR (§14.1) and SDD (§1.4) report `rf_calib.st` as "2,800+" lines. The actual RCS source is **3,345 lines** (as correctly stated in Note 05). This 545-line difference likely reflects either an earlier RCS revision snapshot in the design documents or a summary-level approximation. Precision footnote added to Note 05.

15. **Note 08 §3.1 subSys.c line numbers: systematic +1 offset.** All 11 function line references in §3.1 point to the closing `*/` of the multi-line documentation comment block rather than the function signature (`static long subSys*()`). The actual function definitions are consistently 1 line below each cited number. All 11 references corrected to point to the function signature line.

---

## CORRECTION NOTICE (Rev 4)

Rev 4 addresses issues found during a systematic source-code-to-notes cross-reference audit:

5. **Note 05 HVPS status codes were fabricated.** Rev 3 listed 6 status codes (UNKNOWN, READY, ON, OFF, FAULT, CROWBAR) that do not exist anywhere in the source code. The actual `rf_hvps_loop_defs.h` defines **16 status codes** (0–15). See [05-snl-state-machines.md](05-snl-state-machines.md) §5.3 for the corrected table.

6. **Note 05 HVPS PV names still had the VOLTS→VOLT error.** Rev 3 corrected this in Note 02 but failed to propagate the fix to Note 05 §5.2. Now corrected — the complete PV list from `rf_hvps_loop_pvs.h` replaces the partial/incorrect list.

7. **Note 05 collector protection logic was oversimplified.** Rev 3 described the `proc` state as checking only `klystron_forward_power > max_klystron_forward_power`. The actual source checks **three independent conditions** (forward power, gap voltage severity, AND cavity vacuum severity). Also, the phantom PV `{STN}:HVPS:PCOLL_MAX` was replaced with the correct PV `{STN}:KLYSOUTFRWD:POWER:MAX`.

8. **Note 03 LLRF9 signal mapping (§9.1) was incorrect.** Signal numbers, LLRF9 units, and board assignments did not match PDR Section 4.4. For example, "Cav A Probe" was listed as Signal 1 at Unit 1 BRD1 — it is actually Signal 13 at Unit 1 BRD1. All entries corrected.

9. **DSP firmware line count clarification.** Note 00 §1 reports ~15,667 lines — this is the count of `.s` and `.h` assembly/header files only (73 files). Note 04 reports ~16,763 lines across 102 files — this includes Makefiles, linker scripts, and test files. Both counts are from the `rfApp/src/dsp/` directory tree. The full directory contains 103 RCS-tracked files totaling ~16,261 lines.

10. **PDR §2.1 TAXI terminology error (not corrected — flagged for PDR/SDD revision).** PDR §2.1 (line 89) describes `rf_msgs.st` as "CAMAC TAXI error monitoring". SDD §1.4 (line 99) and §22 (line 1500) repeat and amplify this error with "CAMAC TAXI monitoring" and "CAMAC TAXI eliminated with VXI". TAXI is a **VXI serial link protocol** used by the GVF module for timing and error status signaling — it has nothing to do with CAMAC (a parallel bus standard not used in SPEAR3). The source code (`rf_msgs.st`, lines 196–352) correctly references the GVF TAXI error bit (`GVF_M_TAXIOFLW`) and prints "Gvf Taxi error detected". See Note 05 §7.2 for details. **Both PDR §2.1 and SDD §1.4, §22 require terminology correction.**

## CORRECTION NOTICE (Rev 3)

Rev 2 contained the following error that has been corrected in Rev 3:

4. **Legacy state machine names were incorrect.** Rev 2 described the legacy `rf_states.st` state sequence as "OFF→INITIALIZE→STANDBY→ON_CW→FAULT→FAULT_CLEAR". These are the **proposed upgrade states** from PDR Section 2.2, NOT the legacy states. The actual legacy states (from `rf_station_state.h` and `rf_states.st,v`) are: **OFF→PARK→TUNE→ON_FM→ON_CW** with 17 transition states. See [05-snl-state-machines.md](05-snl-state-machines.md) Section 2.2 for the corrected state diagram.

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
Layer 3: RF MPS PLC (ControlLogix 1756, ~ms) & HVPS PLC
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
| 2 | Interface Chassis | µs-scale † | AIM fast interlock chain (devP2RfAim.c) |
| 3 | RF MPS PLC (ControlLogix) | ~ms | PLC-5 via AB scanner (drvAb.c) |
| 4 | EPICS coordinator | ~1 Hz | SNL programs (rf_states.st, rf_hvps_loop.st) |

> **† Response time clarification (Rev 7):** The Interface Chassis uses hardware AND-gate logic with optocoupler-isolated and fiber-optic I/O. The AND-gate propagation delay is **µs-scale** (pure combinational logic). The PDR reports "<1 ms" in its protection layer table (§7.6 line 674, §14.4 line 1194), which represents a conservative upper bound including optocoupler switching time and fiber-optic transceiver latency. The PDR narrative text (§7.1 line 624) correctly describes the response as "microsecond scale". Both characterizations are technically correct at different measurement points, but µs-scale is the more precise figure for the AND-gate itself.

## 6. "First 2 Weeks" Priority (Revised)

1. **Extract rf_states.st state transitions** → write Python coordinator state machine spec
2. **Extract rf_hvps_loop.st** → write CompactLogix PLC functional specification
3. **Map legacy PV names to upgrade PV namespace** → create alias/migration table
4. **Extract rf_tuner_loop.st** → verify LLRF9 built-in tuner matches legacy behavior
5. **Evaluate subIQ.c/subSys.c** → which functions are needed in the EPICS coordinator?

## 7. Open Discrepancies Requiring Design Review

The following discrepancies were identified during cross-reference of the legacy source code, technical notes, and design documents. They are flagged here for resolution during design review.

### 7.1 Gap Voltage — Clarification (RESOLVED)

| Document | Section | V_gap per cavity | V_total (4 cavities) | Status |
|----------|---------|-----------------|---------------------|--------|
| Legacy Technical Design §1 | Key Parameters | **~800 kV** | **~3.2 MV** | **Design value** for SPEAR3 |
| PDR Section 1 (line 55–56) | Executive Summary | ~712 kV | ~2.85 MV | **Current measured value** |

**Clarification** (per domain expert):
- **~800 kV per cavity (~3.2 MV total)** is the original SPEAR3 design gap voltage.
- **~712 kV per cavity (~2.85 MV total)** is the current measured operating gap voltage.
- These are not contradictory — the system operates below design maximum. The PDR correctly uses the measured operating value for upgrade specification.

### 7.2 Authoritative Source Hierarchy

When discrepancies exist between sources, the following priority order applies:

1. **Legacy source code** (`spear-rf-code-legacy/`) — ground truth for what the legacy system actually does
2. **Legacy Technical Design Report** (`Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md`) — authoritative for legacy system behavior interpretation
3. **Physical Design Report** (`Designs/0_PHYSICAL_DESIGN_REPORT.md`) — authoritative for upgrade system specification
4. **Software Design Document** (`Designs/10_SOFTWARE_DESIGN_DOCUMENT.md`) — authoritative for upgrade software architecture
5. **Technical Notes 00–09** — analysis documents derived from sources above; defer to primary sources when conflicts exist

### 7.3 Arc Detection Sensor Count — Three Conflicting PDR Specifications (Rev 7, SAFETY-CRITICAL)

**Status: UNRESOLVED — requires PDR clarification before procurement**

The PDR contains three mutually inconsistent specifications for the arc detection sensor count:

| PDR Section | Line | Claim | Context |
|-------------|------|-------|---------|
| §2.3 (Architecture narrative) | 201 | "total 12 Microstep-MIS optical sensors" | System description |
| Architecture diagram | 126 | "12sensor" label on arc detection block | ASCII system diagram |
| §12.3 (Arc Detection Installation) | 965 | "**6 sensors** total (updated from original design)" | Installation specification |
| §19.2 (Procurement) | 1327 | "10 sensors and 5 process + 1 sensor & 1 process for spare" | Bill of materials |

**Legacy code evidence resolving the "12" origin:**

`spear-rf-code-legacy/rfApp/src/db/p2RfAimDef.h` defines:
```c
#define AIM_VERSION_7CH  0x1
#define AIM_VERSION_12CH 0x2
#define AIM_K_CHANCNT    (AIM_IS7CH ? 7 : 12)  /* total # of channels */
```

The legacy AIM (Arc Interlock Module) supported 7 or 12 hardware channels. The "12" in PDR §2.3 and the architecture diagram is a **stale reference to the legacy AIM channel count**, not the Microstep-MIS sensor specification. The AIM is being **completely replaced** by the new Microstep-MIS system (PDR §12.1).

**Authoritative specification:** PDR §12.3 (line 965) — "6 sensors total (updated from original design)": 4 cavity windows + 1 klystron window + 1 circulator.

**Interpretation of §19.2:** "10 sensors and 5 process" likely means: 6 active sensors + 4 spares = 10; 5 Microstep-MIS controller/process units + 1 spare = 6. This is consistent with 6 active sensors if the procurement includes spares.

**Recommendation:** Update PDR §2.3 (line 201) from "12" to "6" and update the architecture diagram label from "12sensor" to "6sensor". Add a note that the legacy AIM used 12 channels.

### 7.4 Gap Voltage Arithmetic Error in PDR §4.3 (Rev 7)

**Status: UNRESOLVED — typographical error requiring PDR correction**

| PDR Section | Line | Per-Cavity V_gap | Total (4 cavities) | Correct? |
|-------------|------|-----------------|---------------------|----------|
| §1 (Executive Summary) | 46, 55 | ~712 kV | ~2.85 MV | ✓ (712 × 4 = 2,848 ≈ 2.85 MV) |
| §4.3 (RF Cavities) | 255 | ~712 kV | ~2.5 MV | ✗ (712 × 4 = 2,848 ≠ 2,500) |

The per-cavity voltage (712 kV) is consistent across both sections. The error is in the total: §4.3 says "~2.5 MV" where it should say "~2.85 MV". This is a ~350 kV discrepancy (12%). Note 00 §7.1 already documents the distinction between the design target (~800 kV/cavity → ~3.2 MV) and the measured operating value (~712 kV/cavity → ~2.85 MV) — that clarification is correct and unchanged.

**Recommendation:** Change §4.3 line 255 from "~2.5 MV" to "~2.85 MV".

### 7.5 GVF/TAXI Dependency Gap in PDR §10 (Rev 7)

**Status: UNRESOLVED — design documentation gap**

The GVF module's hardware is not installed in SPEAR3 SRF1 (PDR §2.1: slot 3 is empty). However, Note 07 §1.1.1 (correction #11, Rev 5) confirms that GVF **database records ARE loaded** via `rf_vxi_modules_All.substitutions` and are actively used by the `rf_msgsTAXI` state set in `rf_msgs.st` (lines 196–352) for:

- `{STN}:STN:GVF:MODU.GST1` — module status monitoring
- `{STN}:STN:GVF:MODU.TMCK` — TAXI timing check
- `{STN}:STN:GVF:STATE` — run state
- `{STN}:STN:GVF:LFBLOOP` — LFB (Low Frequency feedback/woofer) loop status

PDR §10 (Tuner Control System upgrade, ~120 lines) makes **zero mention** of:
- GVF/TAXI dependency from the legacy code
- Failure modes if GVF-dependent monitoring is absent in the upgrade
- TAXI error handling strategy in the new system
- LFB resync fault recovery implementation

This matters because the commissioning team needs to know: "What happens to TAXI monitoring and LFB recovery if the GVF module is missing?" The legacy code gracefully handles this (error messages are logged but operation continues), but the upgrade design should explicitly document the strategy — either replicate the GVF monitoring through alternative PVs or explicitly document that this functionality is dropped.

**Recommendation:** Add a subsection to PDR §10 addressing GVF/TAXI dependency handling in the upgrade design.

---

## 8. Companion Documents

### Code Review Technical Notes

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
| [09-pdr-cross-reference-audit.md](09-pdr-cross-reference-audit.md) | PDR R1 cross-reference audit — errata, internal inconsistencies, coverage gaps |

### Authoritative Design References (not part of code review series but essential context)

| Document | Content |
|----------|---------|
| [Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md](../../Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md) | **Authoritative legacy system reference** — correct state names, complete PV architecture, control loop analysis, state transition tables |
| [Designs/10_SOFTWARE_DESIGN_DOCUMENT.md](../../Designs/10_SOFTWARE_DESIGN_DOCUMENT.md) | **Upgrade software architecture** — Python/PyEPICS/MATLAB coordinator design, legacy→upgrade code mapping (Section 22), PV contract reference |
| [Designs/0_PHYSICAL_DESIGN_REPORT.md](../../Designs/0_PHYSICAL_DESIGN_REPORT.md) | **Master upgrade specification** — hardware architecture, signal list, channel allocation, protection chain |

### Document Relationships & Cross-References (Rev 5)

The Software Design Document (SDD, Rev 1, March 18, 2026) postdates the technical notes series and explicitly references legacy SNL program line counts from this series (SDD §1.4, lines 94–98). Cross-verification confirms alignment:

| SNL Program | Notes Count | SDD Reference | Match |
|-------------|-----------|---------------|-------|
| `rf_states.st` | 2,227 | 2,227 | ✓ Exact |
| `rf_hvps_loop.st` | 343 | 343 | ✓ Exact |
| `rf_tuner_loop.st` | 555 | 555 | ✓ Exact |
| `rf_dac_loop.st` | 290 | 290 | ✓ Exact |
| `rf_msgs.st` | 352 | 352 | ✓ Exact |
| `rf_calib.st` | 3,345 | "2,800+" | ⚠️ Notes more precise (see correction #14) |

This confirms the technical notes serve as the **primary authoritative technical reference** for legacy system source-level details. When discrepancies exist between documentation sources, apply the hierarchy defined in §7.2: **Source Code > Technical Notes > Design Documents**.

---

## 9. PDR Coverage Gap Analysis (Rev 7)

The following table maps PDR R1 sections to technical note coverage. Sections marked "NONE" describe new or upgraded subsystems that have no corresponding legacy code analysis and no dedicated technical note. This serves as a roadmap for future documentation work.

| PDR Section | Topic | Technical Note Coverage | Gap Status |
|-------------|-------|------------------------|------------|
| §1 | Executive Summary | Note 00 (cross-referenced) | ✓ Covered |
| §2 | System Architecture | Note 00 §2, Note 02 | ✓ Covered (legacy mapping) |
| §3 | VXI Legacy Description | Note 01, Note 03 | ✓ Covered |
| §4 | RF Plant & Signal Allocation | Note 00 §3, Note 03 §9.1 | ✓ Covered (signal mapping) |
| §5 | LLRF9 Controller | Note 00 §3, Note 04 (DSP comparison) | ✓ Partial — LLRF9 is vendor hardware, covered by reference |
| §6 | HVPS System | Note 05 §5 (legacy HVPS loop) | ✓ Partial — legacy PLC code documented; CompactLogix upgrade not analyzed |
| §6.3 | HVPS CompactLogix Upgrade | **NONE** | ⚠️ **GAP** — new PLC design, no legacy equivalent to analyze |
| §7 | RF MPS PLC | Note 06 (legacy AB drivers) | ✓ Partial — legacy AB/PLC-5 interface documented |
| §7.3 | RF MPS ControlLogix Upgrade | **NONE** | ⚠️ **GAP** — new ControlLogix design, informed by but distinct from legacy |
| §8 | Interface Chassis | Note 00 §5 (protection chain) | ⚠️ **GAP** — entirely new hardware subsystem; only protection layer table exists |
| §9 | PPS Interface | **NONE** | ⚠️ **GAP** — new personnel safety interface, no legacy equivalent |
| §10 | Tuner Control System | Note 05 §4 (legacy tuner loop) | ✓ Partial — legacy SNL tuner documented; Galil upgrade referenced as "ALREADY DONE" |
| §10.3 | Tuner Galil Upgrade | Note 06 §3 | ✓ Covered (commissioned August 2025) |
| §11 | Waveform Buffer | **NONE** | ⚠️ **GAP** — entirely new monitoring system, no legacy equivalent |
| §12 | Arc Detection | Note 01 (AIM file inventory), Note 03 §6 (devP2RfAim.c) | ✓ Partial — legacy AIM documented; Microstep-MIS upgrade specification in Note 09 |
| §13 | Klystron Heater | **NONE** | ⚠️ **GAP** — programmable AC supply replaces motor-driven variac, no legacy code |
| §14 | Software Architecture | Note 02 (legacy architecture), Note 05 (SNL programs) | ✓ Partial — legacy code documented; upgrade coordinator in SDD |
| §15–18 | Schedule, Testing, Commissioning | N/A (project management) | N/A |
| §19 | Procurement | Note 09 §2 (arc sensor cross-reference) | ✓ Partial |

**Summary:** 7 PDR sections describing entirely new subsystems (Interface Chassis, Waveform Buffer, PPS Interface, HVPS CompactLogix, RF MPS ControlLogix, Klystron Heater, and detailed arc detection upgrade) have no legacy code equivalent and thus no dedicated technical note. These represent design documentation that should be reviewed and validated against vendor specifications and hardware design documents as they become available. See [09-pdr-cross-reference-audit.md](09-pdr-cross-reference-audit.md) for the complete PDR audit.
