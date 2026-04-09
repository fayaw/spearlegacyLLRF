# SPEAR3 RF Station — Interlock Architecture Deep Dive

**Document**: I_INTERLOCK_ARCHITECTURE.md
**System**: SPEAR3 RF Station (B132 / B118 / B514)
**Author**: Faya Wang (AI-assisted analysis)
**Date**: April 9, 2026
**Version**: 1.0
**Status**: Draft — based on full codebase analysis; hardware details require field verification

---

## Revision History

| Rev | Date | Author | Changes |
|-----|------|--------|---------|
| 1.0 | 2026-04-09 | Faya Wang | Initial document — synthesized from complete codebase review |

---

## Prerequisite Documents

This document assumes familiarity with the overall system block diagram. Read first:

- `Designs/L_LEGACY_SYSTEM_ARCHITECTURE.md` — full system architecture reference (v2.5+)
  - §5.5 — AIM Module (VXI Slot 12)
  - §9 — SLC-500 HVPS PLC
  - §13 — PPS Interface
  - §14 — RF MPS PLC
  - §15 — Interlock Architecture overview

---

## Source References

All findings in this document were derived from direct analysis of the following source files. No secondary sources were used.

### Primary Source Code

| File | Location | Lines | Role in Interlock |
|------|----------|-------|-------------------|
| `rf_states.st,v` | `rfApp/src/seq/` | 2,227 | Master SNL state machine — all fault detection and response logic |
| `devP2RfAim.c,v` | `rfApp/src/vxi/` | 1,982 | AIM module device support — arc channels, ISR, BATS, fault files |
| `devABSLCDCM.c` | `rfApp/src/ab/` | 563 | SLC-500 DH+ device support — HVPS supervisory communication |
| `p2RfCf2Def.h,v` | `rfApp/src/vxi/` | 403 | CF2 register definitions (PEP-II heritage, slot 5 reference) |

### EPICS Database Files

| File | Location | Role |
|------|----------|------|
| `aim.db,v` | `rfApp/Db/` | AIM module PV definitions — arc status, interlock state, control outputs |
| `rf_digital_hvps.db,v` | `rfApp/Db/` | HVPS digital I/O template — all HVPS status/latch bits from SLC-500 |
| `rf_digital_All.substitutions,v` | `rfApp/Db/` | Instantiates HVPS digital I/O with DH+ word/bit assignments |
| `rf_sumy_hvps.db,v` | `rfApp/Db/` | HVPS alarm aggregation tree |
| `rf_sumy_stn.db,v` | `rfApp/Db/` | Station-level alarm aggregation — STNOFF/STNON/STNMPS trees |
| `rf_sumy_stn_spr.db,v` | `rfApp/Db/` | SPEAR3-specific additions to station summary (STNMPS, external MPS) |
| `rf_interlock.db,v` | `rfApp/Db/` | DCM-based hardware interlock channels (MPS wiring) |
| `rf_interlock_vxi.db,v` | `rfApp/Db/` | VXI-based interlock channels — AIM latch register bits |
| `rf_analog_All.substitutions,v` | `rfApp/Db/` | Analog channel assignments (HVPS volts, current, temperature) |
| `rf_hvps.db,v` | `rfApp/Db/` | HVPS supervisory records — voltage setpoints, SCR control, oil temp |
| `crat_vxi_13slot.template,v` | `rfApp/Db/` | VXI crate slot labeling — confirms slot 5 = "MPS Shutoff" |
| `rf_vxi_modules_All.substitutions,v` | `rfApp/Db/` | VXI module DB loading — `cf2.db` assigned to slot 5 (PEP-II artifact) |

### Technical Notes (Code Analysis Series)

| File | Location | Content |
|------|----------|---------|
| `00-executive-summary.md` | `codeReviewTechnicalNotes/` | System overview, slot 5 clarification |
| `01-file-inventory.md` | `codeReviewTechnicalNotes/` | File classification — CF2 marked PEP-II only |
| `03-vxi-device-support.md` | `codeReviewTechnicalNotes/` | AIM §5: arc channels, fast interlock chain, BATS, fault files |
| `05-snl-state-machines.md` | `codeReviewTechnicalNotes/` | Complete 23-state SNL architecture documentation |
| `06-plc-stepper-motors.md` | `codeReviewTechnicalNotes/` | PLC topology: 3 DH+ nodes, SLC-500 HVPS functions |

---

## Part I — Architecture Overview

### 1.1 The Five Actors

The SPEAR3 RF interlock system involves five distinct hardware/software actors. They are **not redundant layers of the same function** — each addresses a different threat class at a different speed:

| Actor | Speed | Location | What It Protects Against |
|-------|-------|----------|--------------------------|
| **Fast Interlock Chassis** (340-308) | < 1 μs | B132 | Arc breakdown, reflections exceeding cavity/klystron ratings |
| **AIM Module** (VXI Slot 12) | < 1 μs (HW) / ~10 μs (ISR) | VXI Crate | Arc detection aggregation, beam abort, RF_FAULT backplane assertion |
| **RF MPS PLC** (ControlLogix 1756) | ~10 ms | B132 | Collector overpower, vacuum excursion, secondary arc, cooling |
| **SLC-500 HVPS PLC** (DH+ Rack 2) | ~20 ms | B118 | HVPS internal faults: oil, transformer, crowbar, overvoltage, arc in HV tank |
| **SNL State Machine** (`rf_states.st`) | ~1 s | VXI CPU (VxWorks) | Orderly shutdown sequencing, fault recording, recovery coordination |

### 1.2 Signal Flow Diagram

```
PHYSICAL FAULT EVENT
        │
        ├─── Arc / RF detector ───────────────────────────────────────────────┐
        │                                                                      │
        │                                                                      ▼
        │                                           FAST INTERLOCK CHASSIS 340-308 (B132)
        │                                           Analog threshold comparators, < 1 μs
        │                                                   │
        │                                    ┌──────────────┴──────────────┐
        │                                    │                             │
        │                                    ▼                             ▼
        │                    SCR ENABLE removed              CROWBAR fired
        │                    (fiber optic → B514)            (fiber optic → B514)
        │                                                             │
        │                        Status word ───────────────────────►│
        │                              │                     AIM MODULE (VXI Slot 12)
        │                              │                     devP2RfAim.c
        │                              │                              │
        │                              │                    RF_FAULT asserted on
        │                              │                    VXI P2 backplane
        │                              │                              │
        │                              │                              ▼
        │                              │                    RFP (Slot 4) drive cut
        │                              │                    to zero (hardware, ~1 μs)
        │                              │                              │
        │                              │                    AIM ISR fires
        │                              │                    → scanOnce(AIM:MODU)
        │                              │                    → {STN}:STN:VXI:LTCH = MAJOR
        │                                                            │
        ├─── Collector power / vacuum ──────────────────────────────►│
        │             RF MPS PLC (ControlLogix, ~10 ms)              │
        │             → Removes hardware permit to Fast IC            │
        │             → Writes DH+ permit bit OFF                    │
        │             → {STN}:STN:MPS:LTCH = MAJOR                   │
        │                                                            │
        ├─── HVPS internal faults ──────────────────────────────────►│
        │             SLC-500 PLC (B118, ~20 ms)                     │
        │             → SCR Enable relay opened                      │
        │             → {STN}:HVPS*:*:LTCH = MAJOR                   │
        │                                                            │
        │                                                   ALARM AGGREGATION TREE
        │                                                   (EPICS CA, ~100 ms)
        │                                                            │
        │                                      ┌─────────────────────┘
        │                                      ▼
        │                           {STN}:STNOFF:SUMY:STAT.SEVR
        │                           (the single SNL trip wire)
        │                                      │
        │                                      ▼ fault_stnoff != NO_ALARM
        │                           SNL rf_states.st (VxWorks, ~1 s)
        │                           s_go_off: forced beam abort →
        │                           HVPS ramp-to-zero → hvpstrig=OFF →
        │                           rfswitch=OFF → fault file capture
        │
        └──────────────────────────────────────────────────────────────────────
```

---

## Part II — Fast Interlock Chassis 340-308

### 2.1 Function

The Fast Interlock Chassis is a pure analog hardware circuit — no software, no firmware, no CPU in the trip path. It provides sub-microsecond RF protection that is completely independent of all PLCs and computers.

**Physical location**: B132 electronics rack, adjacent to the VXI crate.

### 2.2 Inputs

| Input Type | Source | Connection |
|------------|--------|------------|
| Arc detection (fiber optic) | 4× cavity waveguide window sensors | Fiber optic receivers on chassis |
| Arc detection (fiber optic) | Klystron output window sensor | Fiber optic receiver |
| Arc detection (fiber optic) | Main circulator sensor | Fiber optic receiver |
| RF reflected power | Detector diodes at cavity and waveguide junctions | Coaxial cable, analog voltage |
| RF forward power | Detector diodes (klystron output monitor) | Coaxial cable, J16 "DETECTED KLYSTRON POWER" |
| SPEAR3 beam permit | Machine-level MPS permit | External hardwired |
| Orbit interlock | SPEAR3 orbit feedback system | External hardwired |
| HVPS status (fiber) | B514 HVPS self-status | Fiber optic from B514 |
| MPS PLC permit | RF MPS PLC (ControlLogix) relay output | Hardwired relay I/O |

### 2.3 Outputs

| Output | Destination | Latency | Mechanism |
|--------|-------------|---------|-----------|
| SCR ENABLE remove | B514 HVPS SCR gate drivers | < 1 μs | Fiber optic — eliminates ground loop |
| CROWBAR fire | B514 crowbar thyristor | < 1 μs | Fiber optic |
| Status word | AIM Module (VXI Slot 12) | ~1 μs | Direct chassis-to-module connection |

### 2.4 Front Panel

The front panel of the Fast Interlock Chassis (SLAC drawing 340-308, photo in §15 of Doc L) shows:
- **FAULT RESET** button — latches cannot be cleared without this
- **LAMENT TIMEOUT** indicator — klystron filament interlock
- **BEAM ABORT** indicator/control
- 12-channel test port for arc threshold adjustment
- **TEST CH.** — CH.3 through CH.12 input monitor test points for arc current injection
- **HVPS ON**, **SOLENOID ON**, **FILAMENT ON** status indicators
- **J16 DETECTED KLYSTRON POWER** coaxial input

### 2.5 Trip Mechanism

Each arc detection channel has an adjustable current threshold. When a fiber-optic arc pulse arrives (arc sensors generate an optical burst on breakdown):
1. Analog comparator fires
2. Fault latch is set (latching relay or SR flip-flop — requires hardware FAULT RESET to clear)
3. SCR ENABLE output goes low simultaneously (< 1 μs)
4. CROWBAR fire pulse is generated

For reflected power, the analog input voltage from the RF detectors is compared to a DC threshold. Exceeding the threshold fires the same trip mechanism.

> **Source**: §15 of `Designs/L_LEGACY_SYSTEM_ARCHITECTURE.md` v2.5; `codeReviewTechnicalNotes/03-vxi-device-support.md` §5.2.

---

## Part III — AIM Module (VXI Slot 12)

### 3.1 Hardware Identity

- **Module type**: SLAC PEP-II RF custom VXI module — "Arc detector / Interlock Module" (AIM)
- **VXI slot**: 12 (last slot, rightmost in crate)
- **Device support driver**: `devP2RfAim.c` (1,982 lines)
- **Primary EPICS record**: `{STN}:STN:AIM:MODU` (type `p2RfAim`)
- **DAS instruction files**: `/tbl/aimDas0.inst`, `/tbl/aimDas1.inst`
- **History file**: `/dat/aimHist.dat`

### 3.2 Arc Detection (12 Channels)

The AIM module has 12 independently configurable arc detection channels. Each channel has:
- **Enable/disable** bit (`ARCENBSTT` register, `MODU.AFES` field)
- **Threshold** setting (analog current threshold, adjustable via front panel on Fast IC)
- **Current status** (`ARCCURSTT`, `MODU.ACST`) — real-time arc presence
- **Latched status** (`ARCLTDSTT`, `MODU.ALST`) — fault held since last reset

> **Note on channel count**: The legacy AIM supports 12 hardware channels. The SPEAR3 deployment uses 6 sensor locations (4 cavity windows + 1 klystron window + 1 circulator), provisioned with up to 11 total sensors including spares. See PDR §12.3 for the authoritative upgrade count.

### 3.3 Hardware Trip Path — RF_FAULT Backplane Line

This is the fastest path, entirely in hardware with no software:

```
Arc detected on any channel (< 1 μs)
    OR Fast Interlock Chassis status asserted
        │
        ▼
AIM module asserts RF_FAULT LOW
on VXI P2 backplane (open-collector line)
        │
        ├──► RFP module (Slot 4) monitors RF_FAULT
        │    → Immediately zeros the RF drive DAC outputs
        │    → RF power output collapses (< 1 μs within crate)
        │
        └──► CLK module (Slot 2) monitors RF_FAULT
             → Reference clock protection action
```

The `RF_FAULT` line is **open-collector**: any module on the VXI P2 bus can assert it. The RFP module's reaction is purely analog — no DSP, no SNL, no EPICS involved.

### 3.4 ISR Path — Software Notification (~10 μs)

After the hardware trip fires:
```c
AimIsr() {
    read FAST INTERLOCK STATUS REGISTER  // latched, not ISR register (Sass 2004 fix)
    update rec->istt
    board->intPrc++
    scanOnce(rec)   // schedules AIM:MODU for EPICS processing
}
```

> **Critical 2004 fix** (Sass, `rf_interlock_vxi.db` rev 1.2): Prior to January 2004, the VXI interlock records read the AIM **interrupt status register** (ISR). Because EPICS processed these records continuously, the ISR bits self-cleared on every read — a latched fault could be invisible to the alarm system because it was cleared before alarm propagation. The fix changed to reading the AIM **fast interlock status/latch register**, which holds bits until the operator presses the hardware FAULT RESET button on the interlock chassis front panel. This was a significant reliability fix.

The record `{STN}:STN:AIM:MODU` then processes via a three-stage fanout (`FANO1` → `FANO2` → `FANO3`) that updates all derivative records.

### 3.5 AIM Status PV Map

| PV | AIM Register | Content |
|----|-------------|---------|
| `{STN}:STN:AIM:ARCCURSTT` | `MODU.ACST` | mbbiDirect — 12-bit arc current status word (one bit per channel) |
| `{STN}:STN:AIM:ARCLTDSTT` | `MODU.ALST` | mbbiDirect — 12-bit arc latched status (holds until FAULT RESET) |
| `{STN}:STN:AIM:ARCENBSTT` | `MODU.AFES` | mbbiDirect — 12-bit arc enable bitmap |
| `{STN}:STN:AIM:FSTFLT` | `MODU.FFLT` | mbbiDirect — fast fault status from Fast IC |
| `{STN}:STN:AIM:FSTINTSTT` | `MODU.FSTT` | mbbiDirect — fast interlock state (daisy chain) |
| `{STN}:STN:AIM:INTSTATE` | `MODU.ISTT` | mbbiDirect — overall AIM interlock state |
| `{STN}:STN:AIM:INTACK` | `MODU.IACK` | mbboDirect — interlock acknowledge |

These feed into `rf_interlock_vxi.db`:
```
{STN}:STN:AIM:LTCH.BN  →  {STN}:STN:VXI:LTCH  (bi, MAJOR alarm)
    → {STN}:STNMPS:SUMY:LTCH.INPC
```

### 3.6 AIM Control Output Signals (Fiber Optic Outputs)

The AIM module drives 6 fiber-optic output signals to the Fast Interlock Chassis / external equipment. All are software-commanded by the SNL state machine at the ~1 Hz timescale:

| Signal Name | EPICS PV | AIM Field | Function |
|------------|---------|-----------|---------|
| Klystron Filament On | `{STN}:STN:AIM:FILAMENT` | `MODU.FOO` | Enables klystron filament heater power |
| Solenoid On | `{STN}:STN:AIM:SOLENOID` | `MODU.SOO` | Enables klystron focusing solenoid current |
| **HVPS On (aimon)** | `{STN}:STN:AIM:MODU.HVPS` | `MODU.HVPS` | **Hardware gate for HVPS energization — must be set** |
| Force Beam Abort (fba) | `{STN}:STN:AIM:FRCBMABT` | `MODU.FBA` | Fires SPEAR3 machine-level beam abort |
| Fault Reset | `{STN}:STN:AIM:MODU.RSTF` | `MODU.RSTF` | Clears all AIM arc latches and fast interlock latches |
| Forced Fault | `{STN}:STN:AIM:FRCFLT` | `MODU.FF` | Forces a latched fault (used for testing) |

### 3.7 BATS — Beam Abort Trip Signal

When the HVPS crowbar fires (detected through the Fast IC status into the AIM), the AIM asserts a BATS into the SPEAR3 beam MPS network. This fires the injection kicker and prevents new electrons from entering the storage ring during RF downtime.

**BATS reset sequence** (required before restarting):
```snl
/* RESET_BMABTSUB macro in rf_states.st */
if (fault_stnoff == NO_ALARM) {
    fba = 0;        pvPut(fba)   // de-assert Force Beam Abort
    pvPut(rba)                   // Reset Beam Abort (RBA → MODU.RBA)
    pvPut(rstf)                  // Reset Faults (RSTF → MODU.RSTF — clears arc latches)
}
```
This three-write sequence is only executed when `fault_stnoff == NO_ALARM` — all fault conditions must be clear first.

### 3.8 Fault File Capture — DAS History Buffers

The AIM module has onboard history memory (Data Acquisition System, DAS) that captures time-series data at the moment of fault. Triggered by `efSet(ffwrite_ef)` in the SNL `s_go_off` state, the `ss rf_statesFF` state set:
1. Increments fault slot number (circular buffer 1–15, `NUMFAULTS=15`)
2. Timestamps via `pvTimeStamp(hvpswdefault)` — the HVPS voltage PV's timestamp
3. Places 11 signal modules in LOAD mode
4. Executes DAS instruction files to dump hardware capture buffers
5. Writes to `/dat/FAULTxxx_N` files (N = fault slot 1–15)
6. Maximum wait: `MAXFFWAIT = 180 × 20 ticks ≈ 3.6 s`

The 11 fault file channels captured on each event:

| Channel | File Pattern | Signal |
|---------|-------------|--------|
| 0 | `FAULTRfpSI_N` | RFP Signal I (cavity forward, I component) |
| 1 | `FAULTRfpSQ_N` | RFP Signal Q (cavity forward, Q component) |
| 2 | `FAULTRfpCI_N` | RFP Cavity I (cavity voltage, I component) |
| 3 | `FAULTRfpCQ_N` | RFP Cavity Q (cavity voltage, Q component) |
| 4 | `FAULTIqa1Amp_N` | IQA1 amplitude waveform |
| 5 | `FAULTIqa2Amp_N` | IQA2 amplitude waveform |
| 6 | `FAULTGvf_N` | GVF signal (PEP-II heritage channel, inactive in SPEAR3) |
| 7 | `FAULTAim_N` | AIM arc/interlock status snapshot |
| 8 | `FAULTCmbI_N` / `FAULTCmbQ_N` | Combiner I/Q (PEP-II, inactive in SPEAR3) |
| 9 | `FAULTIqa3Amp_N` | IQA3 amplitude waveform |
| 10 | *(additional)* | Additional channel added in 2003 Laznovsky revision |

> **Source**: `rf_states.st,v` lines 1900–2200 (`ss rf_statesFF`); `devP2RfAim.c` §5 in `03-vxi-device-support.md`.

---

## Part IV — VXI Slot 5: "MPS Shutoff" — Clarification

### 4.1 What It Is

**This slot requires careful distinction between hardware labeling, software configuration, and functional role.**

The SPEAR3 VXI crate (SRF1) at slot 5 is labeled **"MPS Shutoff"** in the crate physical template (`crat_vxi_13slot.template,v`). This is its functional designation in the SPEAR3 system.

The IOC software (`rf_vxi_modules_All.substitutions,v`) loads `cf2.db` (the Comb Filter 2 database) for slot 5 — **this is a PEP-II inherited template artifact**. The `devP2RfCf2.c` driver (2,970 lines) is a PEP-II-only module; the CF2 DSP functionality (comb filter, group delay equalizer, filter bank) is **not exercised in SPEAR3**.

| Aspect | PEP-II | SPEAR3 SRF1 |
|--------|--------|-------------|
| Physical slot 5 module | CF2 (Comb Filter 2) DSP | MPS Shutoff module |
| Software DB loaded | `cf2.db` | `cf2.db` (PEP-II template artifact) |
| Device driver active? | Yes — `devP2RfCf2.c` | No — physical CF2 module not installed |
| Functional use | RF comb filter feedback | MPS permit interface |

> **Source**: `codeReviewTechnicalNotes/00-executive-summary.md` line 65; `codeReviewTechnicalNotes/01-file-inventory.md` line 95.

### 4.2 Hardware Function

The "MPS Shutoff" module in slot 5 provides the **VXI-backplane MPS permit interface**. Its role is:

1. The module occupies slot 5 and has access to the VXI P2 backplane
2. It receives the RF MPS permit signal from the RF MPS PLC (ControlLogix) — the permit is delivered either via hardwired relay I/O from the PLC to a connector on this module, or via a dedicated backplane line
3. When the MPS permit is **present**: the module holds the `RF_PERMIT` backplane line HIGH (or asserts a permissive signal); the RFP module (slot 4) is allowed to output RF drive
4. When the MPS permit is **removed**: the module drops `RF_PERMIT` or asserts `RF_FAULT` on the backplane; the RFP module immediately cuts output (same hardware-speed path as the arc trip)

### 4.3 Software Visibility

The MPS permit status is tracked in EPICS via `{STN}:STN:MPS:LTCH` — a binary input record reading from the AB DH+ communication registers (`rf_interlock.db`, `DTYP="AB-1771DCM BI"`, word `T6[WL,B]`). This is the software-visible representation of the MPS permit held by the RF MPS PLC.

The `{STN}:STN:VXI:LTCH` record (from `rf_interlock_vxi.db`) reads from the AIM latch register bits (`{STN}:STN:AIM:LTCH.BN`) — not from the CF2 slot 5 module. The CF2 OVFL and status records (`{STN}:STN:CF2OVFL:STAT`) are loaded in the DB but are not connected to any active hardware in SPEAR3 (their `DTYP="Soft Channel"` reads from the inactive `{STN}:STN:CF2:MODU` record).

### 4.4 Key Conclusion

> **VXI Slot 5 in SPEAR3 is an MPS permit gate at the VXI backplane level. It does NOT run the CF2 DSP firmware. The cf2.db PV records loaded for slot 5 are inactive (hardware not present). The MPS permit removal causes the RFP module to cut RF drive at hardware speed through the VXI backplane permit line — exactly the same speed and mechanism as the AIM's RF_FAULT assertion.**

---

## Part V — RF MPS PLC (ControlLogix 1756)

### 5.1 Platform

| Attribute | Detail |
|-----------|--------|
| Hardware | Allen-Bradley ControlLogix 1756 |
| Location | B132 (same rack as VXI crate) |
| DH+ node | Rack 1 |
| Predecessor | Allen-Bradley PLC-5 / 1771-DCM (original) |
| Status | Hardware replaced; software written and tested without RF power |

### 5.2 Protection Functions

The MPS PLC monitors **equipment protection** (not personnel safety) parameters on a ~10 ms scan cycle:

| Monitored Parameter | Trip Condition | Notes |
|--------------------|----------------|-------|
| **Klystron collector power** | Cathode power − RF output exceeds limit | Excessive collector power = poor klystron efficiency → overheating |
| **Reflected power** | Reflected power at any cavity exceeds limit | VSWR/arc condition in waveguide |
| **Arc conditions** | Secondary arc sensors (not in Fast IC path) | Redundant arc coverage |
| **Cooling water flow** | Below minimum flow rate | Klystron and waveguide loads |
| **Cooling water temperature** | Exceeds maximum | Thermal runaway detection |
| **Klystron vacuum** | Ion pump current or Penning gauge exceeds limit | Vacuum excursion protection |
| **HVPS fault conditions** | Status from SLC-500 via DH+ | Forwarded to MPS summary |
| **Reference power level** | `{STN}:STNREF:POWER:LTCH` | 476 MHz reference monitor |

### 5.3 Trip Actions — Two Paths

**Path A — Hardware (fast, ~10 ms PLC scan + Fast IC response):**

The MPS PLC has **hardwired relay I/O connections to the Fast Interlock Chassis 340-308**. When the PLC detects a fault requiring immediate action:
1. PLC relay output de-energizes
2. Removes the external MPS permit input to the Fast Interlock Chassis
3. Fast IC treats permit removal as a fault condition
4. Fast IC fires SCR ENABLE removal and CROWBAR via fiber to B514 (< 1 μs after relay contact opens)

This path is: ~10 ms (PLC scan) + relay opening time + Fast IC response (< 1 μs) ≈ **~10–15 ms total**.

**Path B — Software/EPICS (slow, ~1 s):**

1. PLC writes "no permit" status to its DH+ output data table
2. VXI AB6008 scanner reads DH+ registers at ~1 Hz
3. Updates `{STN}:STN:MPS:LTCH` EPICS record
4. Alarm propagates via `rf_sumy_stn_spr.db` → `{STN}:STNMPS:SUMY:LTCH.INPI` → `{STN}:STNOFF:SUMY:STAT.SEVR`
5. SNL `fault_stnoff != NO_ALARM` triggers `s_go_off`

Path B is **bookkeeping** — the MPS hardware has already acted on Path A. Path B ensures the EPICS state machine learns about the fault, logs it, and performs the orderly shutdown sequence.

### 5.4 EPICS PV Path

```
RF MPS PLC (ControlLogix, Rack 1 DH+ node)
    │  DH+ word T6[WL,B]
    ▼
{STN}:STN:MPS:LTCH  (bi, DTYP="AB-1771DCM BI", MAJOR alarm)
    │  .SEVR  NPP MS
    ▼
{STN}:STNMPS:SUMY:LTCH.INPI
    │  .SEVR  NPP MS
    ▼
{STN}:STNOFF:SUMY:STAT.SEVR  (→ fault_stnoff in rf_states.st)
```

### 5.5 MPS Wiring Documents

33 MPS wiring diagrams (SLAC drawings wd3403300200 through wd3403303400) describe the complete MPS hardware signal chain. Original harness is for the PLC-5; the ControlLogix replacement retained equivalent signal connections.

---

## Part VI — SLC-500 HVPS PLC

### 6.1 Platform

| Attribute | Detail |
|-----------|--------|
| CPU | Allen-Bradley 1747-L532 |
| DH+ Scanner | Allen-Bradley 1747-DCM |
| Location | B118 (HVPS building), Hoffman Box enclosure |
| DH+ Node | Rack 2 |
| Rack | 14-slot SLC chassis |

### 6.2 Rack Slot Configuration

| Slot | Module | Function |
|------|--------|---------|
| 0 | 1747-L532 CPU | Program execution |
| 1 | 1747-DCM | DH+ communication master for Rack 2 |
| 2 | IO8 (8-pt, 120 VAC) | Ross grounding switch output (PPS Chain 2) |
| 3 | Thermocouple input | HVPS temperature measurements |
| 5 | OX8 relay output | SCR ENABLE / HVPS control relay (see §6.4) |
| 6 | IB16 digital input | PPS enables, fiber-optic inputs from Fast IC |
| 8–9 | Analog I/O | HVPS voltage readback, current readback, setpoint output |

### 6.3 What the SLC-500 Interlocks On

The SLC-500 monitors every significant HVPS internal condition and exposes them as EPICS records via DH+. The full set of HVPS interlock sources, with their DH+ word/bit assignments from `rf_digital_All.substitutions,v`:

#### Category 1 — Electrical Faults

| PV | DH+ Card/Bit | Alarm | Description |
|----|-------------|-------|-------------|
| `{STN}:HVPS:CROWBAR:LTCH` | C12.9 | MAJOR | **Crowbar fired** — HVPS crowbar thyristor discharged; stored energy dumped |
| `{STN}:HVPS:VOLT:LTCH` | C14.1 | MAJOR | **Overvoltage** — DC output exceeded rated voltage |
| `{STN}:HVPSAC:CURR:LTCH` | C12.3 | MAJOR | **AC current trip** — primary AC current exceeded limit |
| `{STN}:HVPS:OPENLOAD:LTCH` | C14.9 | MAJOR | **Open load** — no current path to load (klystron disconnected or contactor open during energization) |
| `{STN}:HVPS:PANIC:LTCH` | C12.11 | MAJOR | **Emergency Off (PANIC)** — manual or automatic emergency shutdown latch |
| `{STN}:RFHVPS:CROWBAR:LTCH` | C14.11 | MAJOR | **RF crowbar request** — request from RF system to fire HVPS crowbar |

#### Category 2 — Oil System

| PV | DH+ Card/Bit | Alarm | Description |
|----|-------------|-------|-------------|
| `{STN}:HVPSOIL:LEVEL:LTCH` | C12.14 | MAJOR | **Oil level low** — insulating oil in HV tank below minimum |
| `{STN}:HVPSOIL:TEMP:LTCH` | C12.15 | MAJOR | **Oil temperature high** — insulating oil overtemperature |
| `{STN}:HVPSOIL:TEMP` | Analog (SLC-500 AI) | Monitored | Oil temperature value (°C); also has configurable ULIM at `{STN}:HVPSOIL:TEMP:ULIM` |

> **Design note**: HVPS oil temperature was removed from the `HVPSSTN:SUMY:LTCH` roll-up in the Sass 2004 revision (`rf_sumy_hvps.db,v` rev 1.2 log: "Remove HVPS oil temperature from HVPS summary. It remains in the overall temperature summary"). Oil temperature LTCH still contributes to `{STN}:HVPSTEMP:SUMY:LTCH` → `{STN}:STNTEMP:SUMY:LTCH` path.

#### Category 3 — Transformer / HV Tank

| PV | DH+ Card/Bit | Alarm | Description |
|----|-------------|-------|-------------|
| `{STN}:HVPSXFORM:ARC:LTCH` | C14.10 | MAJOR | **Transformer arc** — arc detector inside the HV transformer tank |
| `{STN}:HVPSXFORM:PRESS:LTCH` | C14.6 | MAJOR | **Transformer overpressure** — SF₆ or oil pressure in transformer enclosure exceeded limit |
| `{STN}:HVPSXFORM:VACM:LTCH` | C14.7 | MAJOR | **Transformer vacuum/pressure** — vacuum integrity or gas pressure fault |
| `{STN}:HVPSKLYS:ARC:LTCH` | C12.4 | MAJOR | **Klystron arc** (as seen from HVPS side) — arc current surge into cathode load |
| `{STN}:HVPS:TEMP:LTCH` | C14.0 | MAJOR | **Overtemperature** — general HVPS enclosure over-temperature |

#### Category 4 — Supply and Contactor Status

| PV | DH+ Card/Bit | Alarm | Description |
|----|-------------|-------|-------------|
| `{STN}:HVPS:PPS:STAT` | C14.8 | MAJOR on 0=NOPERMIT | **PPS Status** — PPS permit present (PERMIT=0, NOPERMIT=1 → alarm inverted) |
| `{STN}:HVPS12KV:VOLT:STAT` | C12.1 | MAJOR on 0=NOTAVAIL | **12 kV AC available** — primary 12.47 kV supply status |
| `{STN}:HVPSAC:POWER:STAT` | C12.2 | MAJOR on 0=OFF | **Auxiliary AC power** status |
| `{STN}:HVPSDC:POWER:STAT` | C12.10 | MAJOR on 0=OFF | **Auxiliary DC power** status |
| `{STN}:HVPSSUPPLY:ON:STAT` | C14.4 | MAJOR on 0=OFF | **HV supply on** status |
| `{STN}:HVPSSUPPLY:READY:STAT` | C14.5 | MAJOR on 0=NOTREADY | **HV supply ready** status |
| `{STN}:HVPSENERFAST:ON:STAT` | C12.12 | MAJOR on 0=OFF | **Fast inhibit** — energization fast inhibit active |
| `{STN}:HVPSENERSLOW:START:STAT` | C12.13 | MAJOR on 1=INACTIVE | **Slow start** — energization slow-start sequencer |
| `{STN}:HVPSCONTACT:CLOSE:STAT` | C12.5 | MAJOR on 0=OPEN | HV contactor close status |
| `{STN}:HVPSCONTACT:ON:STAT` | C12.6 | MAJOR on 0=OFF | HV contactor on status |
| `{STN}:HVPSCONTACT:OPEN:STAT` | C12.7 | MAJOR on 1=OPEN | HV contactor open status |
| `{STN}:HVPSCONTACT:READY:STAT` | C12.8 | MAJOR on 0=NOTREADY | HV contactor ready |
| `{STN}:HVPSSCR1:ON:STAT` | C14.2 | MAJOR on 0=OFF | SCR bank 1 on status |
| `{STN}:HVPSSCR2:ON:STAT` | C14.3 | MAJOR on 0=OFF | SCR bank 2 on status |

> **Note on DH+ addressing**: "C12.9" means Card (output word) 12, bit 9. Word 12 = physical I/O module card 12÷2 = slot 6. The SLC-500 uses 8-bit word addressing where adjacent card pairs share a 16-bit word.

#### Category 5 — Analog Monitoring

| PV | Source | Alarm Limits | Description |
|----|--------|-------------|-------------|
| `{STN}:HVPS:VOLT` | SLC-500 AI | HIHI=87, HIGH=85 kV | HVPS DC output voltage |
| `{STN}:HVPS:CURR` | SLC-500 AI | HIHI=30, HIGH=30 A | HVPS DC output current |
| `{STN}:HVPS:PLC:VOLT` | SLC-500 AI word 30 | ±100 kV range | Voltage readback from PLC (independent ADC) |
| `{STN}:HVPS:PLC:CURR` | SLC-500 AI word 31 | ±50 A range | Current readback from PLC (independent ADC) |
| `{STN}:HVPSAC:CURR` | SLC-500 AI | Monitored | Primary AC current |
| `{STN}:HVPSOIL:TEMP` | Thermocouple slot 3 | ULIM configurable | Oil temperature (°C) |

### 6.4 SCR Enable Relay — The HVPS Supervisory Enable Path

The SLC-500 controls the HVPS SCR bank through a relay in Rack 2 Slot 5 (OX8 relay output, OUT port). This is the **supervisory SCR ENABLE path** — it must be held closed for the HVPS to maintain output voltage.

```
SNL rf_states.st HVPSONSUB() macro
    └── pvPut(hvpstrig, ON)
        └── {STN}:HVPSSCR:ON:CTRL = 1
            └── DH+ → SLC-500 Rack2
                └── OX8 relay OUT closed
                    └── Fiber optic cable → B514
                        └── SCR gate driver enable
```

This path is **distinct from** the Fast Interlock Chassis SCR ENABLE path:

| Path | Speed | Source | Notes |
|------|-------|--------|-------|
| Fast IC → SCR ENABLE (fiber) | < 1 μs | Fast Interlock Chassis trip | Hardware trip, opens on fault |
| SLC-500 relay → SCR ENABLE (fiber) | ~20 ms | Supervisory enable/disable | Must be explicitly enabled; cleared in s_go_off |

Both paths use fiber optic to B514. **Both** must be asserted for the HVPS SCR to conduct. The Fast IC path is the fast-trip path; the SLC-500 relay path is the supervisory gate that must be deliberately enabled by the SNL state machine as part of the startup sequence.

> **PV**: `{STN}:HVPSSCR:ON:CTRL` (bo record, `rf_hvps.db,v`): "HVPS SCR Enable Switch". Writing ON enables the HVPS; writing OFF disables (part of s_go_off orderly shutdown).

### 6.5 HVPS Alarm Aggregation Tree

```
{STN}:HVPSSTN:SUMY:LTCH
    ├── INPA: HVPSAC:CURR:LTCH      (AC overcurrent)
    ├── INPB: HVPSKLYS:ARC:LTCH    (klystron arc from HVPS side)
    ├── INPC: HVPS:CROWBAR:LTCH    (crowbar fired)
    ├── INPD: HVPS:PANIC:LTCH      (emergency off)
    ├── INPE: HVPSTEMP:SUMY:LTCH   (oil temp + general temp)
    │         └── INPA: HVPS:TEMP:LTCH      (general overtemp)
    │             INPB: HVPSOIL:TEMP:LTCH   (oil overtemp)
    ├── INPF: HVPSOIL:LEVEL:LTCH   (oil level low)
    ├── INPG: HVPSXFORM:ARC:LTCH   (transformer arc)
    ├── INPH: HVPSXFORM:PRESS:LTCH (transformer overpressure)
    ├── INPI: HVPSXFORM:VACM:LTCH  (transformer vacuum/pressure)
    ├── INPJ: HVPS:VOLT:LTCH       (DC overvoltage)
    └── INPK: HVPS:OPENLOAD:LTCH  (open load)

{STN}:HVPSOFF:SUMY:STAT    →    feeds STNOFF:SUMY:STAT.INPB
    ├── INPE: HVPSCONTACT:SUMY:STAT   (contactor status)
    ├── INPH: HVPSSTN:SUMY:STAT       (operational status summary)
    └── INPI: HVPSSTN:SUMY:LTCH       (latched fault summary)

{STN}:HVPS:SUMY:LTCH
    ├── INPB: HVPSCONTACT:SUMY:STAT
    ├── INPD: HVPSSTN:SUMY:LTCH
    ├── INPE: HVPSAC:POWER:STAT       (AC power available)
    ├── INPF: HVPSDC:POWER:STAT       (DC auxiliary power)
    ├── INPG: HVPS:PPS:STAT           (PPS permit)
    ├── INPH: HVPS12KV:VOLT:STAT      (12 kV AC)
    └── INPI: HVPSSUPPLY:READY:STAT   (supply ready)
```

### 6.6 PPS Relay Chain (Contactor Control)

The SLC-500 also controls the 12.47 kV HV vacuum contactor via the PPS relay chain. This is the personnel-safety path described in `L_LEGACY_SYSTEM_ARCHITECTURE.md` §13.

```
PPS Enable (GOB12-88PNE, Pin E→F)
    → SLC-500 Slot-6 IB16 Input 14
    → PLC Rung 0017 (ladder logic)
    → Slot-5 OX8 OUT2
    → Terminal Strip TS-5 → switchgear cable
    → K4 relay (PPS control)
    → MX relay (external operational enable)
    → RR relay (reset latch)
    → L1 holding coil
    → Ross Engineering HQ3 vacuum contactor
      (connects/disconnects 12.47 kV AC to HVPS primary)
```

> **Critical design issue**: The PPS chain routes through SLC-500 ladder logic — a programmable device is in the personnel safety chain. This does not meet modern PPS standards (SLAC ES&H). Flagged in `L_LEGACY_SYSTEM_ARCHITECTURE.md` §13.4.

---

## Part VII — SNL State Machine (`rf_states.st`)

### 7.1 Architecture

The SNL state machine (`rf_states.st`, 2,227 lines, 3 concurrent state sets) is the **software coordination layer**. It does not provide fast protection — by the time `fault_stnoff` changes, all hardware trips have already fired. Its roles are:

1. **Orderly shutdown** — ramp HVPS to zero before removing SCR enable (protects the HV capacitors/diodes from abrupt current interruption)
2. **Fault recording** — capture of 11 signal channel waveforms to circular buffer
3. **Recovery sequencing** — managed restart with `forced_fault` and auto-reset logic
4. **Operator state interface** — OFF/PARK/TUNE/ON_FM/ON_CW state display
5. **BATS management** — force/reset beam abort in the correct sequence

### 7.2 The Single Trip Wire: `fault_stnoff`

```
{STN}:STNOFF:SUMY:STAT.SEVR  (monitored as fault_stnoff in rf_states.st)

Inputs (from rf_sumy_stn.db record):
    INPA: {STN}:STNPARK:SUMY:STAT     ← VXI latch summary
               └── {STN}:STN:VXI:LTCH (AIM fast interlock bits)
    INPB: {STN}:HVPSOFF:SUMY:STAT     ← HVPS fault/status
    INPC: {STN}:STN:LOCAL:ON           ← Local/remote panel state
    INPD: {STN}:STN:ABSUMY:LTCH       ← DH+ AB communication summary latch
    INPE: {STN}:STN:SUMY:PLC           ← PLC module status summary
```

Any input going MAJOR alarm propagates (via EPICS `MS` = Maximize Severity) to `STNOFF:SUMY:STAT.SEVR`. Every ON state checks this:

```snl
/* In s_on_cw, s_tune, s_on_fm */
when (fault_stnoff != NO_ALARM) {
    fault_detected = 1;
} state s_go_off
```

### 7.3 STNMPS Alarm Tree (SPEAR3-specific, `rf_sumy_stn_spr.db`)

The SPEAR3-specific MPS summary aggregates into the station trip path:

```
{STN}:STNMPS:SUMY:LTCH
    INPB: {STN}:STN:FORCED:LTCH    (AIM forced fault latch)
    INPC: {STN}:STN:VXI:LTCH       (AIM fast interlock status bits)
    INPE: {STN}:STN:NCV:PLC        (no-current-value PLC)
    INPF: {STN}:STNREF:POWER:LTCH  (476 MHz reference power)
    INPG: {STN}:STNCRATEPS:TEMP:LTCH (VXI crate power supply temperature)
    INPH: {STN}:STN:RF476MHZREF:LTCH (476 MHz reference status)
    INPI: {STN}:STN:MPS:LTCH        (RF MPS PLC permit)
```

### 7.4 Orderly Shutdown Sequence (`s_go_off`)

```
State s_go_off (entered when fault_stnoff != NO_ALARM in any ON state):

Step 1: TUNESUB()
    fba = 1   pvPut(fba)        → {STN}:STN:AIM:FRCBMABT = 1
                                   → MODU.FBA asserted → BATS fired (beam abort)
    runmode = TUNE               → puts IQA/RFP in tune mode (low drive)

Step 2: setiqtune()              → zero I/Q drive setpoints

Step 3: pvPut(hvpswdefault, 0)  → write 0 to HVPS voltage setpoint
                                   rf_hvps_loop.st ramps voltage down

Step 4: taskDelay(300)           → ~5 second wait for HVPS to discharge

Step 5: hvpstrig = OFF   pvPut(hvpstrig)
    → {STN}:HVPSSCR:ON:CTRL = 0  → DH+ → SLC-500 Rack2
    → SCR gate drive disabled from supervisory path

Step 6: rfswitch = OFF   pvPut(rfswitch)
    → {STN}:STN:RFP:RFENABLE = 0 → RF drive enable explicitly removed

Step 7: intcomp = OFF    pvPut(intcomp)
    → Direct feedback integrator compensation disabled

Step 8: efSet(ffwrite_ef)        → triggers ss rf_statesFF (fault file capture)

Step 9: → state s_off
```

### 7.5 HVPS Startup Sequence (HVPSONSUB macro)

```snl
/* executed inside s_go_on_cw when transitioning to ON_CW */
HVPSONSUB():
    rfswitch = ON          pvPut(rfswitch)   → RF drive enabled
    pvGet(hvpswdefault)                       → read default voltage setpoint
    /* call TUNESUB to home tuners */
    hvpstrig = ON          pvPut(hvpstrig)   → SCR gate drive enabled via DH+
    aimon = ON             pvPut(aimon)       → write {STN}:STN:AIM:MODU.HVPS = 1
                                                → AIM fiber "HVPS_On" asserted
    /* wait up to 10 s checking fault_stnoff */
```

The `aimon` write is a **hardware interlock gate**: the AIM module physically holds its "HVPS_On" fiber output LOW until the IOC writes a 1 to `MODU.HVPS`. This ensures the HVPS cannot be energized unless the software state machine has explicitly authorized it.

### 7.6 BATS Reset (`RESET_BMABTSUB`)

```snl
/* RESET_BMABTSUB(fault) — called during recovery */
if (fault == NO_ALARM) {
    fba = 0;    pvPut(fba)    → de-assert Force Beam Abort
    pvPut(rba)                 → Reset Beam Abort (MODU.RBA)
    pvPut(rstf)                → Reset Faults (MODU.RSTF — clears all arc latches)
}
```

### 7.7 `forced_fault` Latch — Blocking Auto-Reset

`{STN}:STN:FORCED:LTCH` is set by AIM hardware on detection of a severe arc event. When this latch is set:

1. `{STN}:STNMPS:SUMY:LTCH.INPB` is MAJOR → contributes to `STNOFF:SUMY:STAT`
2. In `s_go_stn_reset` (auto-reset state):
   ```snl
   when (forced_fault != NO_ALARM) {
       /* exit without reset attempt */
   } state s_off
   ```
3. The station stays locked in `s_off` until an operator physically presses the **FAULT RESET** button on the Fast Interlock Chassis front panel — this clears the AIM hardware latch and de-asserts `forced_fault`

This was a SPEAR3-specific customization (Sass comment 2004: *"SPEAR is using forced fault to trip the station under certain conditions"*) to prevent automatic recovery after hard arcs.

---

## Part VIII — Fault Event Timeline

### 8.1 Example: Waveguide Arc

```
t = 0 ns        Arc breakdown at cavity waveguide window:
                → fiber-optic light pulse arrives at Fast Interlock Chassis

t < 1 μs        Fast IC analog comparator fires:
                → SCR ENABLE removed (fiber optic → B514)
                  HVPS SCR stops conducting; HV output begins to collapse
                → CROWBAR fired (fiber optic → B514)
                  Crowbar thyristor shorts HV output; stored cap energy
                  dumps into crowbar resistor (not klystron cathode)
                → Status word updated → AIM module received

t < 1 μs        AIM hardware asserts RF_FAULT on VXI P2 backplane:
                → RFP module (Slot 4) monitors RF_FAULT pin directly
                  RF drive DAC output zeroed in hardware
                  RF power into klystron collapses

t ≈ 5–50 μs     AIM ISR fires:
                → Reads ARCLTDSTT latch register (not ISR register — retains fault)
                → forced_fault latch set if arc current exceeded threshold
                → scanOnce({STN}:STN:AIM:MODU)

t ≈ 50–500 μs   EPICS IOC processes AIM:MODU record:
                → FANO1/2/3 fanout updates ARCCURSTT, ARCLTDSTT, FSTFLT records
                → {STN}:STN:VXI:LTCH goes MAJOR
                → {STN}:STNMPS:SUMY:LTCH propagates (MS) → STNOFF:SUMY:STAT MAJOR

t ≈ 10–15 ms    MPS PLC (ControlLogix) next scan cycle:
                → Detects fault via DH+ status or hardwired arc monitor
                → De-energizes relay → removes hardwired permit to Fast IC
                  (Fast IC already fired at t<1μs; this is PLC-level confirmation)
                → Writes STN:MPS:LTCH bit OFF in DH+ output table

t ≈ 20 ms        SLC-500 detects HVPS crowbar event:
                → Updates HVPS:CROWBAR:LTCH = FAULT in DH+ registers
                → HVPSSTN:SUMY:LTCH → HVPSOFF:SUMY:STAT → STNOFF:SUMY:STAT

t ≈ 1 s          SNL rf_states.st detects fault_stnoff != NO_ALARM:
                → fault_detected = 1
                → Transitions from s_on_cw → s_go_off state

t ≈ 1.0–1.1 s   s_go_off Step 1: TUNESUB()
                → fba = 1 (BATS fired from software side to confirm beam abort)
                → runmode = TUNE

t ≈ 1.1–6 s     s_go_off Steps 2–4: HVPS voltage setpoint → 0
                → rf_hvps_loop.st ramps HVPS voltage down to zero
                → ~5 s wait for capacitor bank to discharge

t ≈ 6 s         s_go_off Steps 5–7:
                → hvpstrig = OFF (SCR supervisory enable removed via DH+)
                → rfswitch = OFF (RFP drive enable removed)
                → intcomp = OFF

t ≈ 6–10 s      ss rf_statesFF: Fault file capture
                → 11 signal channels × /dat/FAULT*_N (N = 1–15 circular)
                → Max 3.6 s for capture to complete

t > 10 s        State machine in s_off; operator notified via EPICS alarm
```

### 8.2 Recovery Sequence

```
Operator observes fault via EPICS display
    → Checks fault files (/dat/FAULT*_N for latest fault slot)
    → Identifies fault channel (ARCLTDSTT bit, FSTFLT word, etc.)

Physical action:
    → Presses FAULT RESET on Fast Interlock Chassis front panel
      → Clears hardware arc latches in AIM module
      → Clears forced_fault latch
      → ARCLTDSTT bits cleared
      → {STN}:STN:FORCED:LTCH → OK → STNMPS:SUMY:LTCH clears

EPICS action:
    → fault_stnoff returns to NO_ALARM when all faults clear
    → Operator commands station to ON via EPICS display

SNL response:
    → s_off → s_go_park → s_go_tune → s_go_on_cw
    → HVPSONSUB():
        rfswitch = ON
        hvpstrig = ON  → SLC-500 Rack2 relay closes → SCR gate drive enabled
        aimon = ON     → AIM "HVPS_On" fiber output asserted
    → RESET_BMABTSUB():
        fba = 0 → rba → rstf  (BATS reset, arc hardware latches cleared)
    → Station climbs to ON_CW
```

---

## Part IX — Key Cross-Layer Interactions

### 9.1 AIM `aimon` ↔ SLC-500 Hardware Gate

The `aimon` write (`{STN}:STN:AIM:MODU.HVPS = 1`) sets the AIM "HVPS_On" fiber optic output. This is a **hardware interlock gate** — the SLC-500 HVPS controller cannot energize the HV supply unless the AIM has asserted this fiber signal. This cross-link means:

- The SNL state machine must explicitly authorize HVPS energization (via `HVPSONSUB`)
- If the software is not in the ON transition sequence (e.g., the IOC is dead), AIM holds this output LOW and HVPS cannot be energized

In the fault path, `aimon` is NOT explicitly cleared in `s_go_off` — the hardware trip (SCR ENABLE removed by Fast IC + SLC-500 `hvpstrig=OFF`) has already shut down the HVPS. The explicit `aimon=ON` is only needed at startup.

### 9.2 `forced_fault` Anti-Auto-Reset

Without `{STN}:STN:FORCED:LTCH`, the auto-reset state (`s_go_stn_reset`) would retry `reset_count` times automatically. With `forced_fault = MAJOR`, the auto-reset loop exits immediately to `s_off`, requiring operator intervention. This prevents the HVPS from automatically re-energizing after a hard arc event — critical for SPEAR3 where arc repetition can damage cavity surfaces.

### 9.3 VXI Interlock Latch Register Fix (2004)

Before January 2004, VXI interlock bits were read from the AIM interrupt status register (ISR). EPICS processed the AIM:MODU record continuously, and each read cleared the ISR — a latched fault could be invisible to the alarm system because it self-cleared between EPICS scans. Sass changed `rf_interlock_vxi.db` (rev 1.2, Jan 2004) to read from the AIM **fast interlock status/latch register**, which holds bits until the hardware FAULT RESET button is pressed. **This is a critical reliability fix** — without it, the software alarm chain would miss fast faults.

### 9.4 Dual SCR Enable Paths — Supervisory vs. Fast

The HVPS SCR bank has two independent enable paths that operate in different domains:

| Path | Owner | Speed | Set by | Cleared by |
|------|-------|-------|--------|-----------|
| Fast IC → fiber → B514 SCR | Hardware interlock | < 1 μs | Normal (held enable) | Fast IC fault trip |
| SLC-500 relay → fiber → B514 SCR | Supervisory enable | ~20 ms | SNL `hvpstrig=ON` in `HVPSONSUB` | SNL `hvpstrig=OFF` in `s_go_off` |

The SLC-500 relay is the **supervisory gate** — it deliberately enables the HVPS at the beginning of the startup sequence and is the controlled OFF path during orderly shutdown. The Fast IC path is the **fast-trip gate** — always held enabled during normal operation, trips open on fault. Both must be satisfied simultaneously for the HVPS to produce HV output.

---

## Appendix A — EPICS PV Quick Reference

| PV | Description | Normal State |
|----|-------------|-------------|
| `{STN}:STNOFF:SUMY:STAT.SEVR` | **Master trip wire** (SNL `fault_stnoff`) | NO_ALARM |
| `{STN}:STN:AIM:MODU.HVPS` | AIM HVPS permissive (`aimon`) | 1 when ON |
| `{STN}:STN:AIM:FRCBMABT` | Force Beam Abort (`fba`) | 0 when ON |
| `{STN}:STN:AIM:MODU.RSTF` | Reset AIM Faults (`rstf`) | — (write only) |
| `{STN}:STN:AIM:MODU.RBA` | Reset Beam Abort (`rba`) | — (write only) |
| `{STN}:STN:AIM:ARCLTDSTT` | Arc latched status (12-bit word) | 0 = no arc |
| `{STN}:STN:AIM:ARCCURSTT` | Arc current status (12-bit word) | 0 = no arc |
| `{STN}:STN:AIM:FSTFLT` | Fast fault status from Fast IC | 0 = OK |
| `{STN}:STN:VXI:LTCH` | VXI interlock latch (from AIM latch register) | OK |
| `{STN}:STN:FORCED:LTCH` | Forced fault latch (blocks auto-reset) | OK |
| `{STN}:STN:MPS:LTCH` | RF MPS PLC permit status | OK |
| `{STN}:HVPSSCR:ON:CTRL` | HVPS SCR enable switch (`hvpstrig`) | 1 when ON |
| `{STN}:STN:RFP:RFENABLE` | RF drive enable (`rfswitch`) | 1 when ON |
| `{STN}:HVPS:CROWBAR:LTCH` | HVPS crowbar fired latch | OK |
| `{STN}:HVPS:VOLT:LTCH` | HVPS overvoltage latch | OK |
| `{STN}:HVPSOIL:LEVEL:LTCH` | HVPS oil level latch | OK |
| `{STN}:HVPSOIL:TEMP:LTCH` | HVPS oil temperature latch | OK |
| `{STN}:HVPSXFORM:ARC:LTCH` | Transformer arc latch | OK |
| `{STN}:HVPS:PANIC:LTCH` | Emergency Off latch | OK |
| `{STN}:HVPSOFF:SUMY:STAT` | HVPS OFF status summary | NO_ALARM |
| `{STN}:HVPSSTN:SUMY:LTCH` | HVPS station fault summary | NO_ALARM |
| `{STN}:STNMPS:SUMY:LTCH` | Station MPS summary (SPEAR3) | NO_ALARM |

---

## Appendix B — Items Requiring Field Verification

The following details were inferred from code analysis and require physical hardware verification:

| Item | What Was Inferred | Needs Verification |
|------|------------------|-------------------|
| Slot 5 physical module | Labeled "MPS Shutoff" in crate template; CF2 DB loaded as PEP-II artifact | Confirm what is physically present in VXI slot 5 in the SRF1 crate |
| Fast IC ↔ MPS PLC wiring | Hardwired relay I/O between ControlLogix and Fast IC; exact connector/terminal IDs | Verify against MPS wiring drawings wd3403300200–wd3403303400 |
| Fast IC ↔ AIM connection | AIM receives status word from Fast IC | Verify physical cable/connector; check if via VXI backplane or external cable |
| SLC-500 SCR fiber path | OX8 relay OUT → fiber → B514 | Verify fiber cable routing and connection in B118/B514 |
| DH+ word/bit assignments | Derived from `rf_digital_All.substitutions,v` | Cross-check against SLC-500 ladder logic program (if available) |
| `aimon` interlock gate | AIM fiber output physically gates SLC-500 HVPS enable | Verify signal path in B118 circuitry |
| Arc sensor count | PDR §12.3 says 6 locations, 11 total sensors | Confirm physical installation count |
