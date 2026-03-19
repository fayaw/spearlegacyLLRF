# Cross-Reference Errata & PDR Inconsistency Register

**Document**: 09 of 09 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**Date**: March 2026 (Rev 1)
**Purpose**: Register of discrepancies found between legacy source code, design documents, and technical notes

---

## Overview

This document records all known discrepancies between the following sources:

- **Legacy source code**: `spear-rf-code-legacy/` (2,285 RCS-controlled files)
- **Physical Design Report (PDR)**: `Designs/0_PHYSICAL_DESIGN_REPORT.md` (Rev R1)
- **Software Design Document (SDD)**: `Designs/10_SOFTWARE_DESIGN_DOCUMENT.md` (Rev R1)
- **Legacy Technical Design Report**: `Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md`
- **LLRF9 System & Software Report**: `Designs/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md`
- **HVPS Engineering Technical Note**: `Designs/4_HVPS_Engineering_Technical_Note.md`
- **Interface Chassis Design**: `Designs/11_INTERFACE_CHASSIS_DESIGN.md`
- **Technical Notes 00–08**: `spear-rf-code-legacy/codeReviewTechnicalNotes/`

Each finding is classified:
- 🔴 **CRITICAL** — Factual error that could cause hardware damage, migration failure, or PV connection failure
- 🟡 **SIGNIFICANT** — PDR internal contradiction requiring design review resolution
- 🟢 **COVERAGE GAP** — Missing documentation that should be added for completeness

---

## 1. STATE MACHINE NAMES — FACTUAL ERROR IN TECH NOTES 00, 01, 05

🔴 **CRITICAL — Corrected in this revision**

### What Tech Notes 00, 01, and 05 Said (Rev 2)

Tech notes described the `rf_states.st` master state machine using these states:

```
OFF → INITIALIZE → STANDBY → ON_CW → FAULT → FAULT_CLEAR
```

- Tech note 00, Section 3 (Legacy → Upgrade Mapping): "Master state machine: OFF→INITIALIZE→STANDBY→ON_CW→FAULT→FAULT_CLEAR"
- Tech note 01, Section 2.1 (rf_states.st row): Same state sequence
- Tech note 05, Section 2.2: ASCII state diagram with INITIALIZE, STANDBY, FAULT, FAULT_CLEAR boxes
- Tech note 05, Section 2.3: Detailed descriptions of "INITIALIZE" (loads DSP firmware), "STANDBY" (all modules healthy), "FAULT_CLEAR" (resets interlocks)

### What the Legacy Code Actually Implements

**Source**: `rfApp/src/db/rf_station_state.h,v`
```c
#define STATION_OFF     0
#define STATION_PARK    1
#define STATION_TUNE    2
#define STATION_ON_FM   3
#define STATION_ON_CW   4
```

**Source**: `rfApp/src/seq/rf_states.st,v` — All SNL state declarations:

Primary states:
- `state s_off` — All RF outputs disabled
- `state s_park` — VXI modules initialized, RF off, HVPS may be energized
- `state s_tune` — Drive power ramping, direct loop engagement
- `state s_on_fm` — Frequency modulation mode (comb + ripple loops engaging)
- `state s_on_cw` — Continuous wave mode, full RF power

Transition states (the operational detail the upgrade design must preserve):
- `state s_go_off` — Orderly shutdown from any state to OFF
- `state s_go_park` — Transition to PARK (initialize modules)
- `state s_go_tune` — Transition to TUNE (enable drive power)
- `state s_go_on_fm` — Transition to ON_FM
- `state s_go_on_cw` — Transition to ON_CW
- `state s_go_tune_to_on_cw` — Direct transition from TUNE to ON_CW (skipping ON_FM)
- `state go_on_cw_to_tune` — Fallback from ON_CW to TUNE
- `state go_on_fm_to_tune` — Fallback from ON_FM to TUNE
- `state s_comb_ramp` — Comb loop ramp-up sequence
- `state s_direct_ramp` — Direct loop ramp-up sequence
- `state s_gv_up` — Gap voltage ramp up
- `state s_gv_down` — Gap voltage ramp down
- `state s_lp_check` — Loop parameter check
- `state s_faultfiles` — Fault file dump (captures signal RAM to `/dat/FAULTSigI_00..10`)
- `state s_go_stn_reset` — Station reset sequence
- `state s_go_tickleoff` — Tickle off sequence
- `state s_go_tickleon` — Tickle on sequence

**Source**: `Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md`, Section 1:
> "Station state sequencing — orderly transitions between OFF, PARK, TUNE, ON_FM, and ON_CW operating modes"

### Root Cause

The tech notes confused the **proposed upgrade state machine** (PDR Section 2.2: OFF→INITIALIZE→STANDBY→ON_CW→FAULT→FAULT_CLEAR) with the **actual legacy state machine** (OFF→PARK→TUNE→ON_FM→ON_CW). The states "INITIALIZE", "STANDBY", and "FAULT_CLEAR" **do not exist** in the legacy code.

### Impact

- Anyone reading these tech notes as a reference for legacy behavior will be fundamentally misled
- Migration tasks that extract "legacy behavior" from the tech notes will be extracting the wrong state definitions
- The 17 transition states in the legacy code (see list above) represent critical operational sequencing that will need to be preserved or deliberately mapped in the upgrade

### Correction Applied

- Tech note 00: Fixed in Rev 3 — state sequence corrected to legacy states
- Tech note 01: Fixed in Rev 3 — rf_states.st entry corrected
- Tech note 05: Fixed in Rev 3 — state diagram and descriptions rewritten from code

### Cross-Reference for Upgrade States

The **upgrade** state machine (for the Python/EPICS coordinator) will use a different state set:
- PDR Section 2.2: OFF, INITIALIZE, STANDBY, ON_CW, FAULT, FAULT_CLEAR
- SDD Section 5: Detailed upgrade state machine specification
- These are **design choices for the new system**, not descriptions of the legacy system

---

## 2. HVPS PV NAMING — FACTUAL ERROR IN TECH NOTE 02

🔴 **CRITICAL — Corrected in this revision**

### What Tech Note 02 Said (Rev 2)

Section 1, "PV Naming Conventions":
```
{STN}:HVPS:VOLTS:RBCK         — HVPS voltage readback
{STN}:HVPS:VOLTS:CTRL         — HVPS voltage setpoint
```

### What the Legacy Code Uses

**Source**: `rfApp/src/seq/rf_hvps_loop_pvs.h,v`
```snl
assign  requested_hvps_voltage to "{STN}:HVPS:VOLT:CTRL";
assign  readback_hvps_voltage to "{STN}:HVPS:VOLT";
assign  history_hvps_voltage to "{STN}:HVPS:VOLT:LOOP";
```

**Source**: `rfApp/Db/rf_hvps.db,v`
```
grecord(ai,"$(S):HVPS:VOLT")      { field(DESC,"HVPS Monitored Voltage") }
grecord(ai,"$(S):HVPS:VOLT:RBCK") { field(DESC,"HVPS Desired Volt Readback") }
grecord(ao,"$(S):HVPS:VOLT:CTRL") { field(DESC,"HVPSDESVLT HVPS Desired Volt") }
```

**Source**: PDR Section 6.4:
```
| Setpoint | SRF1:HVPS:VOLT:CTRL.VAL |
| Readback | SRF1:HVPS:VOLT:RBCK     |
```

### Correction

The PV namespace uses `VOLT` (no S), not `VOLTS`:
- Setpoint: `{STN}:HVPS:VOLT:CTRL` (ao record)
- Monitored voltage: `{STN}:HVPS:VOLT` (ai record — actual measured value from HVPS)
- Desired readback: `{STN}:HVPS:VOLT:RBCK` (ai record — echoes the setpoint via hardware readback)
- Loop history: `{STN}:HVPS:VOLT:LOOP` (ao record — what the HVPS loop last commanded)

### Additional HVPS PVs Not Previously Documented

From `rf_hvps_loop_pvs.h,v`, the complete HVPS voltage-related PV set:
```
{STN}:HVPS:VOLT           — Monitored voltage (actual hardware measurement)
{STN}:HVPS:VOLT:CTRL      — Desired voltage setpoint (operator command)
{STN}:HVPS:VOLT:RBCK      — Desired voltage readback (hardware echo)
{STN}:HVPS:VOLT:LOOP      — Loop last-commanded voltage
{STN}:HVPS:VOLT:MIN       — Minimum allowed voltage
{STN}:HVPS:VOLT:CTRL.DRVH — Maximum allowed voltage (drive high limit on CTRL record)
{STN}:HVPS:LOOP:VOLTDIFF  — Allowed voltage tolerance
{STN}:HVPS:LOOP:VOLTDOWN  — Voltage step-down delta
{STN}:HVPS:LOOP:VOLTUP    — Voltage step-up delta
{STN}:HVPS:LOOP:VOLTHIST.RES — Reset voltage history
```

### Impact

Any EPICS engineer following tech note 02 would attempt to connect to `{STN}:HVPS:VOLTS:CTRL` which **does not exist**. This would cause PV connection failures during commissioning.

---

## 3. ARC DETECTION SENSOR COUNT — PDR INTERNAL CONTRADICTION

🟡 **SIGNIFICANT — Requires design review resolution**

Three different sensor counts appear in the PDR:

| PDR Section | Sensor Count | Context |
|-------------|-------------|---------|
| Section 2 (diagram, line 126) | **12** | ASCII architecture diagram shows "12sensor" |
| Section 2.3 (line 202) | **12** | "Arc Detection — total 12 Microstep-MIS optical sensors" |
| Section 12.3 (line 965) | **6** | "There are **6 sensors** total (updated from original design)" with enumeration: 4 cavity + 1 klystron + 1 circulator |
| Section 12.4 (line 976) | **6** (implied) | "6-bit latch" and "6 status inputs" in signal path diagram |
| Section 19.2 (line 1327) | **10+1 spare** | Procurement: "10 sensors and 5 process + 1 sensor & 1 process for spare" |

### Analysis

- Section 12.3 is the most detailed and specific: it enumerates each sensor location and explicitly says "(updated from original design)" — suggesting 12 was an earlier count that was revised down to 6
- Section 12.4's signal path diagram shows 6 inputs, consistent with Section 12.3
- Sections 2 and 2.3 appear to retain the **original (pre-revision) count** of 12
- Section 19.2's procurement of 10 sensors does not match either 6 or 12

### Possible Reconciliation

The procurement of "10 sensors + 5 process" might mean:
- 6 deployed sensors + 4 spare sensors = 10 total sensors ordered
- 5 "process" units may be the Microstep-MIS controller channels
- Plus 1 extra sensor + 1 extra process for spare inventory

However, this is speculation. The PDR does not explicitly reconcile these numbers.

### Impact

- Hardware fabrication and installation depend on the correct sensor count
- If the Interface Chassis is designed for 6 sensor inputs but 12 are specified elsewhere, wiring and connector allocation will be wrong
- Procurement will need the correct count to order materials

### Recommended Action

Design review should confirm: **Is the correct count 6 (Section 12.3) or 12 (Section 2)?** If 6, update Sections 2 and 2.3. If 12, update Section 12.3 and the signal path diagram.

---

## 4. TOTAL GAP VOLTAGE — THREE DIFFERENT VALUES ACROSS DOCUMENTS

🟡 **SIGNIFICANT — Requires physics/operations clarification**

| Document | Section | V_gap per cavity | V_total (4 cavities) | Internal Consistency |
|----------|---------|-----------------|---------------------|---------------------|
| PDR Section 1 (line 55-56) | Executive Summary | ~712 kV | ~2.85 MV | ✓ (712×4=2848≈2850) |
| PDR Section 4.3 (line 255) | RF Cavities | ~712 kV | **~2.5 MV** | ✗ (712×4=2848≠2500) |
| Legacy Tech Design Section 1 | Key Parameters | **~800 kV** | **~3.2 MV** | ✓ (800×4=3200) |

### Analysis

- PDR Section 4.3's "~2.5 MV" appears to be a **typo or outdated figure** — it contradicts the per-cavity voltage of 712 kV stated in the same document
- The Legacy Technical Design's "~800 kV per cavity" and "~3.2 MV total" could reflect:
  - Actual measured commissioning values (higher than design target)
  - PEP-II legacy values retained in documentation
  - A different operating point than the upgrade target
- PDR Section 1's "~2.85 MV" with "~712 kV each" is internally consistent and likely represents the **upgrade design target**

### Impact

- RF power budget calculations depend on accurate gap voltage
- Klystron drive requirements scale with cavity voltage
- HVPS voltage setpoints depend on the target gap voltage
- These differences could affect LLRF9 setpoint configuration

### Recommended Action

1. Correct PDR Section 4.3 to read "~2.85 MV" instead of "~2.5 MV" (if 712 kV per cavity is the correct figure)
2. Document whether ~800 kV (legacy) vs ~712 kV (upgrade) represents a deliberate design change or measurement vs. specification difference
3. If the operating point has changed, note this in the PDR with explanation

---

## 5. MISSING DOCUMENT REFERENCES IN TECH NOTES

🟢 **COVERAGE GAP — Corrected in this revision**

Two significant design documents exist but were not referenced by any of the 9 technical notes:

### 5.1 Legacy Technical Design Report

**File**: `Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md` (1,424 lines)

This document provides:
- Correct legacy state names (OFF, PARK, TUNE, ON_FM, ON_CW) — would have prevented Issue #1
- Detailed analysis of each control loop (DAC, HVPS, Tuner, Direct, Comb)
- Complete EPICS Process Variable Architecture (Section 14)
- State transition tables (Appendix A)
- Complete PV reference (Appendix B)
- Source file index (Appendix C)

**Recommended**: Reference in tech note 00 Section 7 (Companion Documents) as authoritative source for legacy system behavior.

### 5.2 Software Design Document

**File**: `Designs/10_SOFTWARE_DESIGN_DOCUMENT.md` (1,561 lines)

This document provides:
- Python/PyEPICS/MATLAB coordinator architecture (the upgrade software)
- Module decomposition for state machine, HVPS controller, tuner manager, fault manager
- Section 22: "Legacy Code Mapping" — directly maps legacy functions to new code
- EPICS PV Contract Reference (Section 17)
- Concurrency and threading model (Section 18)

**Recommended**: Reference in tech note 00 as the authoritative source for how legacy code maps to the upgrade software architecture.

---

## 6. HVPS COLLECTOR POWER PROTECTION — INCOMPLETE IN TECH NOTE 05

🟢 **COVERAGE GAP**

### What's Missing

Tech note 05, Section 3.3 ("HVPS Loop Control Logic") mentions "delta_hvps_voltage adjustment based on klystron forward power" but does not extract or document the complete collector power protection logic.

### What the Code Shows

**Source**: `rfApp/src/seq/rf_hvps_loop_pvs.h,v`
```snl
float   klystron_forward_power;
assign  klystron_forward_power to "{STN}:KLYSOUTFRWD:POWER";
monitor klystron_forward_power;

float   max_klystron_forward_power;
assign  max_klystron_forward_power to "{STN}:KLYSOUTFRWD:POWER:MAX";
monitor max_klystron_forward_power;

float   delta_on_voltage;
assign  delta_on_voltage to "{STN}:KLYSDRIVFRWD:HVPS:DELTA";

float   delta_tune_voltage;
assign  delta_tune_voltage to "{STN}:STNVOLT:HVPS:DELTA";
```

**Protection logic** (from `rf_hvps_loop.st,v`):
- If `klystron_forward_power > max_klystron_forward_power`, the loop reduces HVPS voltage by `delta_proc_voltage_down`
- This protects the non-full-power collector from overheating
- Related PVs: `{STN}:HVPS:LOOP:VOLTDOWN` (step-down delta), `{STN}:HVPS:LOOP:VOLTUP` (step-up delta)

### Impact

Migration team needs to understand this protection logic to implement equivalent behavior in the new CompactLogix PLC code. PDR Section 4.5 references this protection but the tech notes don't fully extract the PV list or logic sequence.

### Recommended Action

Add a subsection to tech note 05 documenting:
- All PVs related to collector power protection (listed above)
- Trigger condition: `klystron_forward_power > max_klystron_forward_power`
- Response action: `delta_hvps_voltage = delta_proc_voltage_down` (reduces HVPS voltage)
- Cross-reference to PDR Section 4.5 and 11.3

---

## 7. FILE COUNT METHODOLOGY — UNCLEAR IN TECH NOTE 01

🟢 **COVERAGE GAP**

### Issue

Tech note 01 claims "Total source files: 253" with "82,430+ lines of code" but the actual repository contains significantly more files:

| Count Method | Result |
|-------------|--------|
| All RCS `,v` files in repository | 2,285 |
| RCS files in `rfApp/` only | 2,045 |
| Functional code files (`.c`, `.h`, `.st`, `.s`, `.db`, `.dbd`, `.substitutions`) | ~426 |
| Display files (`.HIF`, `.ACF`, `.GDF`, `.CNF`, `.SYM`, etc.) | ~541 |
| Build/config files (`Makefile`, etc.) | ~450+ |
| VXI/RF table files (`.tbl`, coefficient data) | ~57 in `iocBoot/tbl/` + ~27 in VXI tables |

The "253" count is likely scoped to a specific subset (e.g., `rfApp/src/` functional code excluding display and build files) but the methodology is not documented.

### Recommended Action

Clarify in tech note 01: "253 functional source files in rfApp/ — this count excludes display files (~541), build configuration (~450), VXI boot tables (~27), and RF coefficient/table files (~57)."

---

## 8. IOC BOOTSTRAP AND OPERATIONAL INFRASTRUCTURE — NOT DOCUMENTED

🟢 **COVERAGE GAP**

The following files are present in the repository but not analyzed in any technical note:

### 8.1 IOC Boot Configuration
- `iocBoot/b132-iocrf/st.cmd,v` — Main IOC startup script
- `iocBoot/b132-iocrf/srf1.substitutions,v` — SPEAR3 SRF1 macro expansion (station name, slot assignments, cavity mappings)
- `iocBoot/b132-iocrf/config.ab,v` — Allen-Bradley PLC rack/group configuration

### 8.2 Display Files (~541 files, not inventoried)
- `.HIF` (158 files) — MEDM/EDM operator display definitions
- `.ACF` (158 files) — Access control/security files
- `.GDF` (115 files) — Graphics display files
- `.CNF` (241 files) — Configuration files
- `.SYM` (135 files) — Symbol/icon definitions

These display files will require migration to a modern display framework (CS-Studio/Phoebus/etc.) in the upgrade. No tech note addresses this migration scope.

### 8.3 Table/Coefficient Files (57 files in `iocBoot/tbl/`)

Tech note 01 Section 11 mentions these files with verdict "KEEP" but doesn't categorize them by purpose:

| Category | Files | Purpose |
|----------|-------|---------|
| IQ Calibration | `AmplCoefs.tbl`, `PhaseCoefs.tbl`, `Sp3AmpCoefs.tbl`, `Sp3PhsCoefs.tbl` | Amplitude/phase calibration coefficients |
| DSP Filter | `cfmIirCoefsHER.tbl`, `cfmIirCoefsLER.tbl` | IIR filter coefficients for CFM (PEP-II) |
| GVF Detuning | `gvfDspConsts.tbl`, `gvfHERdetun.tbl`, `gvfLERdetun.tbl` | Gap voltage feed-forward (PEP-II) |
| Test/Noise | `NOISE_I*`, `NOISE_Q*`, `SINE_*`, `SWEEP_*`, `TICKLE_*`, `WOOFER_NOISE.tbl` | Test and noise injection waveforms |
| AIM DAS | `aimDas0.inst`, `aimDas1.inst` | AIM data acquisition sequence instructions |
| Drive Waveforms | `DRIVE_HER_I/Q`, `DRIVE_LER_I/Q` | PEP-II drive waveforms (not SPEAR3) |

**SPEAR3-relevant files**: `Sp3AmpCoefs.tbl`, `Sp3PhsCoefs.tbl`, `NOISE_*_spear.out` files, `aimDas*.inst`, potentially `TICKLE_*` and `WOOFER_NOISE.tbl`

**Compatibility with LLRF9**: The LLRF9 uses a different coefficient loading mechanism. These table files may need format conversion. This has not been assessed.

---

## 9. LEGACY-TO-LLRF9 SIGNAL MAPPING — NOT DOCUMENTED

🟢 **COVERAGE GAP**

### Issue

Tech note 03 documents the legacy VXI module signals (IQA1=Forward, IQA2=Reflected, IQA3=Cavity) but does **not** map them to their LLRF9 equivalents. PDR Section 5.3 provides detailed LLRF9 channel allocation.

### Required Mapping (from PDR Section 3 and 5.3)

| Legacy VXI Module | Legacy Signal | LLRF9 Unit | LLRF9 Board | LLRF9 Channel | PDR Signal # |
|-------------------|--------------|-----------|------------|--------------|-------------|
| IQA1 (Slot 7) — Forward | Kly Forward Power | Unit 2 | BRD3 | CH2 | Signal 15 |
| IQA1 (Slot 7) — Forward | Kly Reflected Power | Unit 2 | BRD3 | CH3 | Signal 16 |
| IQA2 (Slot 9) — Reflected | Cav A Reflected | Unit 2 | BRD3 | CH0 | Signal 10 |
| IQA2 (Slot 9) — Reflected | Cav B Reflected | Unit 2 | BRD3 | CH1 | Signal 12 |
| IQA3 (Slot 11) — Cavity | Cav A Probe | Unit 1 | BRD1 | CH0 | Signal 1 |
| IQA3 (Slot 11) — Cavity | Cav B Probe | Unit 1 | BRD1 | CH1 | Signal 2 |
| RFP (Slot 4) — RF Processor | Drive Output | Unit 1 | BRD1 | OUT | Signal 5 |

*Note: This is a partial mapping. The complete allocation across 2 LLRF9 units with 3 boards each is in PDR Section 5.3.*

### Impact

Engineers need this mapping to verify signal continuity during commissioning. Without it, there's no way to confirm that the same physical signal ends up at the same logical processing point in the upgrade.

### Recommended Action

Add a "Legacy-to-LLRF9 Signal Routing" section to tech note 03, or create a dedicated mapping table document.

---

## 10. DOCUMENT CROSS-REFERENCE MATRIX

The following matrix shows which PDR sections are covered by which tech notes:

| PDR Section | Topic | Tech Note | Coverage |
|-------------|-------|-----------|----------|
| 1 | Executive Summary | 00 | ✓ Partial (gap voltage not flagged) |
| 2 | System Architecture | 00, 02 | ✓ Good |
| 3 | Signal List | 03 | ⚠️ Missing LLRF9 mapping |
| 4 | RF Plant | 03, 04 | ✓ Partial |
| 4.5 | Collector Protection | 05 | ⚠️ Incomplete (see Item 6) |
| 5 | LLRF9 Controller | — | ❌ Not covered (new system) |
| 6 | HVPS Subsystem | 02, 05 | ⚠️ PV naming error (see Item 2) |
| 7 | RF MPS PLC | 06 | ✓ Partial |
| 8 | Waveform Buffer | — | ❌ Not covered (new system) |
| 9 | Heater Subsystem | — | ❌ Not covered (new system) |
| 10 | Tuner Motor | 05, 06 | ✓ Good |
| 11 | Interface Chassis | — | ❌ Not covered (new system) |
| 12 | Arc Detection | 03 | ⚠️ Sensor count not flagged (see Item 3) |
| 13 | Testing | — | N/A (upgrade scope) |
| 14 | Integration | — | N/A (upgrade scope) |
| 15 | Legacy Loops | 04, 05, 08 | ✓ Good |
| 16 | Risk Register | — | N/A (project management) |
| 17 | Protection Chain | 00, 03 | ✓ Partial |
| 18 | Standards | — | N/A (reference) |
| 19 | Procurement | — | N/A (project management) |

Sections marked ❌ are upgrade-only systems with no legacy equivalent — coverage is not expected from legacy code review tech notes. However, tech note 00 should note their existence for completeness.

---

## 11. SUMMARY OF CORRECTIONS APPLIED

| Issue | Severity | Tech Notes Affected | Correction Status |
|-------|----------|--------------------|--------------------|
| 1. State machine names | 🔴 CRITICAL | 00, 01, 05 | ✅ Corrected in Rev 3 |
| 2. HVPS PV naming (VOLTS→VOLT) | 🔴 CRITICAL | 02 | ✅ Corrected in Rev 3 |
| 3. Arc sensor count contradiction | 🟡 SIGNIFICANT | PDR internal | ⏳ Flagged for design review |
| 4. Gap voltage contradiction | 🟡 SIGNIFICANT | PDR internal | ⏳ Flagged for design review |
| 5. Missing document references | 🟢 COVERAGE GAP | 00 | ✅ Added in Rev 3 |
| 6. HVPS collector protection incomplete | 🟢 COVERAGE GAP | 05 | ⏳ Flagged (detail in errata) |
| 7. File count methodology unclear | 🟢 COVERAGE GAP | 01 | ⏳ Flagged (detail in errata) |
| 8. IOC bootstrap not documented | 🟢 COVERAGE GAP | — | ⏳ Documented in errata |
| 9. Legacy-to-LLRF9 mapping missing | 🟢 COVERAGE GAP | 03 | ⏳ Documented in errata |

---

## Appendix: Authoritative Source Hierarchy

When discrepancies exist between sources, the following priority order applies:

1. **Legacy source code** (`spear-rf-code-legacy/`) — ground truth for what the legacy system actually does
2. **Legacy Technical Design Report** (`Designs/A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md`) — authoritative for legacy system behavior interpretation
3. **Physical Design Report** (`Designs/0_PHYSICAL_DESIGN_REPORT.md`) — authoritative for upgrade system specification
4. **Software Design Document** (`Designs/10_SOFTWARE_DESIGN_DOCUMENT.md`) — authoritative for upgrade software architecture
5. **Technical Notes 00–08** — analysis documents derived from sources above; defer to primary sources when conflicts exist

