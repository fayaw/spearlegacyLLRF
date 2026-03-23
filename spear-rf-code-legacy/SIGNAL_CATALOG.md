# SPEAR3 RF System — EPICS Signal Catalog

> **Comprehensive, AI-ingestible documentation of all EPICS Process Variables (PVs)**
> **in the SPEAR3 Low-Level RF legacy control system.**

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Macro Substitution Reference](#2-macro-substitution-reference)
3. [Custom VXI Record Types](#3-custom-vxi-record-types)
4. [Record Type Distribution](#4-record-type-distribution)
5. [Signal Catalog by Subsystem](#5-signal-catalog-by-subsystem)
6. [Sequencer State Machines](#6-sequencer-state-machines)
7. [VXI Crate Slot Map](#7-vxi-crate-slot-map)
8. [Station Configuration](#8-station-configuration)

---

## 1. System Overview

| Property | Value |
|----------|-------|
| **System** | SPEAR3 Low-Level RF Control System |
| **Facility** | SLAC National Accelerator Laboratory / SSRL |
| **Station** | SRF1 (SPEAR3 RF Station 1) |
| **Configuration** | 4-cavity (CAV1-CAV4) |
| **IOC Name** | B132-IOCRF |
| **Total DB Records** | 742 |
| **Total Sequencer PV Assignments** | 261 |
| **Source Path** | `spear-rf-code-legacy/rfApp/` |

### Architecture Summary

The SPEAR3 RF system uses a single VXI crate-based IOC (`B132-IOCRF`) running vxWorks on a KSC V152 PowerPC CPU. The IOC communicates with:

- **VXI modules** via backplane (custom record types: p2RfRfp, p2RfIqa, p2RfAim, p2RfClk, p2RfGvf)
- **Allen-Bradley PLC** via VME scanner for analog/digital I/O, interlocks, and temperature
- **Stepper motor controllers** for cavity tuner positioning
- **DSP processors** embedded in VXI modules for real-time signal processing

The control system manages four RF cavities (CAV1–CAV4), one klystron, one HVPS, and associated interlocks.

## 2. Macro Substitution Reference

All PV names in the database use macro substitution. For the SPEAR3 production system:

| Macro | Resolves To | Context | Description |
|-------|-------------|---------|-------------|
| `$(A)` | `1|2|3` | db | Allen-Bradley adapter number |
| `$(AI)` | `R0G0|R1G0` | db | Analog input card identifier |
| `$(C)` | `CAV1|CAV2|CAV3|CAV4` | db | Cavity identifier |
| `$(CD)` | `0-14` | db | Allen-Bradley adapter card number |
| `$(I)` | `1|2|3` | db | IQA module instance number |
| `$(ID)` | `2` | db | Station numeric ID |
| `$(M)` | `0|2|4|6` | db | Stepper motor card number |
| `$(PS)` | `RF-SOLN-MAIN` | db | Power supply device name (EPSC) |
| `$(R)` | `SRF1` | db | Ring station name |
| `$(REG)` | `1` | db | Region number |
| `$(RNG)` | `SPEAR` | db | Ring identifier |
| `$(RRRS)` | `SRF1` | db | Station name (used in .substitutions files, maps to $(S)) |
| `$(S)` | `SRF1` | db | Station name (primary macro used in .db files) |
| `$(T)` | `0-7` | db | DCM block transfer table number |
| `$(W)` | `varies` | db | PLC word number for analog input |
| `{CAV}` | `1|2|3|4` | sequencer | Cavity number (used in sequencer files) |
| `{STN}` | `SRF1` | sequencer | Station name (used in .st sequencer files) |

### PV Name Construction Examples

```
Template:  $(S):HVPS:VOLT:CTRL
Resolved:  SRF1:HVPS:VOLT:CTRL

Template:  $(S):$(C)TUNR:POSN
Resolved:  SRF1:CAV1TUNR:POSN  (for cavity 1)
           SRF1:CAV2TUNR:POSN  (for cavity 2)
           SRF1:CAV3TUNR:POSN  (for cavity 3)
           SRF1:CAV4TUNR:POSN  (for cavity 4)

Sequencer: {STN}:STN:STATE:CTRL
Resolved:  SRF1:STN:STATE:CTRL
```

## 3. Custom VXI Record Types

These custom EPICS record types are defined in `rfApp/src/db/*.dbd` and interface directly with VXI hardware modules:

### 3.1. `p2RfRfp` — RF Processor

| Property | Value |
|----------|-------|
| **DBD Source** | `p2RfRfpRecord.dbd` |
| **VXI Slot** | 4 |
| **SPEAR3 Status** | ✅ Active |

VXI RF Processor module - core signal processing for cavity drive, I/Q modulation, DAC outputs, loop control. Contains DSP for direct/comb feedback loops.

**Key hardware-interface fields:** `RCTL`, `RSTT`, `DLE`, `CLE`, `RLE`, `RFOO`, `TNOP`, `SCDT`, `RFFR`, `SSCT`

### 3.2. `p2RfIqa` — I/Q Amplitude Detector

| Property | Value |
|----------|-------|
| **DBD Source** | `p2RfIqaRecord.dbd` |
| **VXI Slot** | 7,9,11 |
| **SPEAR3 Status** | ✅ Active |

VXI I/Q and Amplitude Detector module - measures forward, reflected, and cavity probe signals. Provides I, Q, amplitude, phase for each channel.

**Key hardware-interface fields:** `TCTL`, `FEST`, `STI`, `SSI`, `FO`, `RCO`, `AT0-AT7`, `AD0-AD3`

### 3.3. `p2RfAim` — Arc Interlock Module

| Property | Value |
|----------|-------|
| **DBD Source** | `p2RfAimRecord.dbd` |
| **VXI Slot** | 12 |
| **SPEAR3 Status** | ✅ Active |

VXI Arc Interlock Module - detects arc faults, manages fast shutoff, controls station on/off, filament, solenoid, HVPS enable signals.

**Key hardware-interface fields:** `FCTL`, `FSTT`, `SOO`, `HVPS`, `FOO`, `FTOR`, `FF`, `RSTF`, `FBA`, `RBA`

### 3.4. `p2RfClk` — Clock Module

| Property | Value |
|----------|-------|
| **DBD Source** | `p2RfClkRecord.dbd` |
| **VXI Slot** | 2 |
| **SPEAR3 Status** | ✅ Active |

VXI Clock Module - generates timing for the RF system including 476 MHz reference, sample clocks, and trigger signals.

**Key hardware-interface fields:** `TCTL`, `AUXO`, `AUXI`, `SFTT`, `HNRB`, `P391`, `P392`, `P471`, `SNCH`, `TCLK`, `RSYN`

### 3.5. `p2RfGvf` — Gap Voltage Feedback

| Property | Value |
|----------|-------|
| **DBD Source** | `p2RfGvfRecord.dbd` |
| **VXI Slot** | 3 |
| **SPEAR3 Status** | ⚠️ Software only (no hardware module installed) |

VXI Gap Voltage Feedback module - PEP-II hardware not installed in SRF1, but software layer is active for TAXI monitoring and LFB resync fault recovery.

**Key hardware-interface fields:** `GCTL`, `GST0`, `GST1`, `MTL`, `LFBL`, `GFFL`, `MODE`, `TMCK`

### 3.6. `p2RfCf2` — Comb Filter 2

| Property | Value |
|----------|-------|
| **DBD Source** | `p2RfCf2Record.dbd` |
| **VXI Slot** | 5 |
| **SPEAR3 Status** | ❌ Not installed |

VXI Comb Filter module - PEP-II only, not installed in SRF1.

### 3.7. `p2RfCfm` — Comb Filter Module

| Property | Value |
|----------|-------|
| **DBD Source** | `p2RfCfmRecord.dbd` |
| **VXI Slot** | N/A |
| **SPEAR3 Status** | ❌ Not installed |

VXI Comb Filter Module - PEP-II only, not installed in SRF1.

## 4. Record Type Distribution

| Record Type | Count | Purpose |
|-------------|-------|---------|
| `calc` | 244 | Calculation — derived values, alarm logic, data conversion |
| `fanout` | 66 | Fanout — triggers processing of multiple downstream records |
| `sub` | 57 | Subroutine — custom C-function computation (subIQ.c, subSys.c) |
| `ao` | 56 | Analog Output — setpoints, control values |
| `bo` | 55 | Binary Output — on/off controls, enables |
| `seq` | 50 | Sequence — ordered multi-step processing chains |
| `mbbo` | 38 | Multi-Bit Binary Output — state selectors, mode controls |
| `bi` | 36 | Binary Input — status bits, fault flags |
| `ai` | 29 | Analog Input — hardware readbacks, measurements |
| `stringout` | 25 | String Output — text status, state descriptions |
| `mbbiDirect` | 25 | Multi-Bit Binary Input Direct — bit-field extraction from hardware |
| `compress` | 11 | Compress — circular buffer history records |
| `event` | 11 | Event — loop-ready synchronization signals |
| `sel` | 10 | Select — multi-input selection logic |
| `mbboDirect` | 7 | Multi-Bit Binary Output Direct — bit-field outputs |
| `mbbi` | 6 | Multi-Bit Binary Input — enumerated state readbacks |
| `stringin` | 3 | String Input — text readbacks |
| `calcout` | 2 | Calc Output — calculation with output trigger |
| `steppermotor` | 1 | Custom — Stepper motor controller for cavity tuners |
| `p2RfIqa` | 1 | Custom — I/Q Amplitude Detector VXI module interface |
| `p2RfRfp` | 1 | Custom — RF Processor VXI module interface |
| `p2RfAim` | 1 | Custom — Arc Interlock Module VXI module interface |
| `p2RfCf2` | 1 | Custom — Comb Filter 2 VXI module interface |
| `p2RfCfm` | 1 | Custom — Comb Filter Module VXI module interface |
| `p2RfClk` | 1 | Custom — Clock Module VXI module interface |
| `p2RfGvf` | 1 | Custom — Gap Voltage Feedback VXI module interface |
| `longout` | 1 | Long Output — integer output values |
| `state` | 1 | State — state variable record |
| `abDcm` | 1 | Custom — Allen-Bradley DCM block transfer data |
| **TOTAL** | **742** | |

## 5. Signal Catalog by Subsystem

### 5.1. Station Control (152 signals)

**Station-level control and status signals - manages overall station state, reset sequences, fault handling, remote/local control, beam abort status, and DCM communications.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(R):STN:A$(M)$(C)` | sub | computed |  | V |  | iqCvt.db |
| `$(R):STN:AIM:ARCCURSTT` | mbbiDirect | derived |  |  |  | aim.db |
| `$(R):STN:AIM:ARCENBSTT` | mbbiDirect | derived |  |  |  | aim.db |
| `$(R):STN:AIM:ARCLTDSTT` | mbbiDirect | derived |  |  |  | aim.db |
| `$(R):STN:AIM:FANO1` | fanout | processing |  |  |  | aim.db |
| `$(R):STN:AIM:FANO2` | fanout | processing |  |  |  | aim.db |
| `$(R):STN:AIM:FANO3` | fanout | processing |  |  |  | aim.db |
| `$(R):STN:AIM:FILAMENT` | bo | setpoint |  |  | 0=Off 1=On | aim.db |
| `$(R):STN:AIM:FRCBMABT` | bo | setpoint |  |  | 0=Off 1=On | aim.db |
| `$(R):STN:AIM:FRCFLT` | bo | setpoint |  |  | 0=Off 1=On | aim.db |
| `$(R):STN:AIM:FSTFLT` | mbbiDirect | derived |  |  |  | aim.db |
| `$(R):STN:AIM:FSTINTSTT` | mbbiDirect | derived |  |  |  | aim.db |
| `$(R):STN:AIM:HCTL` | bo | setpoint |  |  | 0=On 1=Off | aim.db |
| `$(R):STN:AIM:HGET` | bo | setpoint |  |  |  | aim.db |
| `$(R):STN:AIM:HMUX` | bo | setpoint |  |  | 0=HVPS_ARC 1=HVPS | aim.db |
| `$(R):STN:AIM:INTACK` | mbboDirect | setpoint |  |  |  | aim.db |
| `$(R):STN:AIM:INTSTATE` | mbbiDirect | derived |  |  |  | aim.db |
| `$(R):STN:AIM:MODU` | p2RfAim | readback |  |  |  | aim.db |
| `$(R):STN:AIM:READAS` | bo | setpoint |  |  | 0=NoRead 1=Read | aim.db |
| `$(R):STN:AIM:SOLENOID` | bo | setpoint |  |  | 0=Off 1=On | aim.db |
| `$(R):STN:CF2:ANAINP` | mbbo | setpoint | Analog Input |  |  | cf2.db |
| `$(R):STN:CF2:CALD` | calc | computed | diag buf button update |  |  | cf2.db |
| `$(R):STN:CF2:CALH` | calc | computed | hist buf button update |  |  | cf2.db |
| `$(R):STN:CF2:CMBBNKSEL` | mbbo | setpoint | comb bank select |  |  | cf2.db |
| `$(R):STN:CF2:CMBSTAT` | mbbiDirect | derived |  |  |  | cf2.db |
| `$(R):STN:CF2:D1SRC` | mbbo | setpoint | diag mem 1 source |  |  | cf2.db |
| `$(R):STN:CF2:D2SRC` | mbbo | setpoint | diag mem 2 source |  |  | cf2.db |
| `$(R):STN:CF2:DATALIGN` | mbbo | setpoint | pre-DAC data alignment |  |  | cf2.db |
| `$(R):STN:CF2:DDCREM` | mbbo | setpoint | DC removal |  |  | cf2.db |
| `$(R):STN:CF2:DGAIN` | mbbo | setpoint | digital gain |  |  | cf2.db |
| `$(R):STN:CF2:DIAGREC` | mbbo | setpoint | diagnostic mem record enable |  |  | cf2.db |
| `$(R):STN:CF2:ECRESET` | mbbo | setpoint | error count reset |  |  | cf2.db |
| `$(R):STN:CF2:ECTIME` | stringin | derived | last error count reset |  |  | cf2.db |
| `$(R):STN:CF2:EQUBNKSEL` | mbbo | setpoint | equalizer bank select |  |  | cf2.db |
| `$(R):STN:CF2:FAN1` | fanout | processing |  |  |  | cf2.db |
| `$(R):STN:CF2:HBSRC` | mbbo | setpoint | history buffer source |  |  | cf2.db |
| `$(R):STN:CF2:HISTREC` | mbbo | setpoint | history buffer record enable |  |  | cf2.db |
| `$(R):STN:CF2:INTACK` | mbboDirect | setpoint | interrupt acknowledge |  |  | cf2.db |
| `$(R):STN:CF2:INTBNKSEL` | mbbo | setpoint | interpolator bank select |  |  | cf2.db |
| `$(R):STN:CF2:INTFILON` | mbbo | setpoint | interp filter enable |  |  | cf2.db |
| `$(R):STN:CF2:INTSTATE` | mbbiDirect | derived | interrupt state |  |  | cf2.db |
| `$(R):STN:CF2:IOTYPE` | mbbo | setpoint | I/O Type |  |  | cf2.db |
| `$(R):STN:CF2:MODU` | p2RfCf2 | readback |  |  |  | cf2.db |
| `$(R):STN:CF2:SCAN` | fanout | processing | temporary 2-sec scan pv |  |  | cf2.db |
| `$(R):STN:CF2:SEQ1` | seq | processing |  |  |  | cf2.db |
| `$(R):STN:CF2:SERLPBK` | mbbo | setpoint | serial loopback enable |  |  | cf2.db |
| `$(R):STN:CF2:SQD1` | seq | processing | diag buf button upd seq1 |  |  | cf2.db |
| `$(R):STN:CF2:SQD2` | seq | processing | diag buf button upd seq2 |  |  | cf2.db |
| `$(R):STN:CF2:SQH1` | seq | processing | hist buf button upd seq1 |  |  | cf2.db |
| `$(R):STN:CF2:SQH2` | seq | processing | hist buf button upd seq2 |  |  | cf2.db |
| `$(R):STN:CF2:STATE` | mbbo | setpoint | module state |  |  | cf2.db |
| `$(R):STN:CF2:SYNCSRC` | mbbo | setpoint | scope sync source |  |  | cf2.db |
| `$(R):STN:CF2OVFL:STAT` | bi | derived | CF2 Overflow Status |  | 0=OK 1=FAULT | cf2.db |
| `$(R):STN:CFM$(M):CMBSETSEL` | mbbo | setpoint |  |  |  | cfm.db |
| `$(R):STN:CFM$(M):DATAALIGN` | mbbo | setpoint |  |  |  | cfm.db |
| `$(R):STN:CFM$(M):EQBNKSEL` | bo | setpoint |  |  | 0=Bank 0 1=Bank 1 | cfm.db |
| `$(R):STN:CFM$(M):INPDATA` | ai | derived |  |  |  | cfm.db |
| `$(R):STN:CFM$(M):INTACK` | mbboDirect | setpoint |  |  |  | cfm.db |
| `$(R):STN:CFM$(M):INTSTATE` | mbbiDirect | derived |  |  |  | cfm.db |
| `$(R):STN:CFM$(M):MODU` | p2RfCfm | readback |  |  |  | cfm.db |
| `$(R):STN:CFM$(M):RIST` | bo | setpoint | Read Int Status Reg |  | 0=NoRead 1=Read | cfm.db |
| `$(R):STN:CFM$(M):STATE` | mbbo | setpoint |  |  |  | cfm.db |
| `$(R):STN:CFM$(M)OVFL:STAT` | bi | derived | CFM$(M) Overflow Status |  | 0=OK 1=FAULT | cfm.db |
| `$(R):STN:CFM1:MODU` | calc | computed | dummy CFM1 |  |  | cf2.db |
| `$(R):STN:CFM1OVFL:STAT` | bi | derived | CFM1 Ovfl Status Proxy |  | 0=OK 1=FAULT | cf2.db |
| `$(R):STN:CFM2:MODU` | calc | computed | dummy CFM2 |  |  | cf2.db |
| `$(R):STN:CFM2OVFL:STAT` | bi | derived | CFM2 Ovfl Status Proxy |  | 0=OK 1=FAULT | cf2.db |
| `$(R):STN:CLK:471PLLSEL` | mbbo | setpoint |  |  |  | clk.db |
| `$(R):STN:CLK:AUXIN` | mbbo | setpoint |  |  |  | clk.db |
| `$(R):STN:CLK:AUXINENB` | bo | setpoint |  |  | 0=Disable 1=Enable | clk.db |
| `$(R):STN:CLK:AUXOUT` | mbbo | setpoint |  |  |  | clk.db |
| `$(R):STN:CLK:AUXOUTENB` | bo | setpoint |  |  | 0=Disable 1=Enable | clk.db |
| `$(R):STN:CLK:CALONSEL` | bo | setpoint |  |  | 0=Off 1=On | clk.db |
| `$(R):STN:CLK:INTACK` | mbboDirect | setpoint |  |  |  | clk.db |
| `$(R):STN:CLK:INTSTATE` | mbbiDirect | derived |  |  |  | clk.db |
| `$(R):STN:CLK:MODU` | p2RfClk | readback | Clock Module |  |  | clk.db |
| `$(R):STN:CLK:RIST` | bo | setpoint | Read Int Status Reg |  | 0=NoRead 1=Read | clk.db |
| `$(R):STN:CLK:SFTTRGENB` | bo | setpoint |  |  | 0=Not Driven 1=Backplane Driven | clk.db |
| `$(R):STN:CLK:TRNCLKSEL` | bo | setpoint |  |  | 0=Local Counter 1=External Fiducial | clk.db |
| `$(R):STN:GVF:DATAALIGN` | mbbo | setpoint |  |  |  | gvf.db |
| `$(R):STN:GVF:EQBNKSEL` | bo | setpoint |  |  | 0=Bank 0 1=Bank 1 | gvf.db |
| `$(R):STN:GVF:GST1STATE` | mbbiDirect | derived |  |  |  | gvf.db |
| `$(R):STN:GVF:INTACK` | mbboDirect | setpoint |  |  |  | gvf.db |
| `$(R):STN:GVF:INTSTATE` | mbbiDirect | derived |  |  |  | gvf.db |
| `$(R):STN:GVF:MODU` | p2RfGvf | readback |  |  |  | gvf.db |
| `$(R):STN:GVF:REGTIMER` | bo | setpoint |  |  | 0=NoRead 1=Read | gvf.db |
| `$(R):STN:GVF:STATE` | mbbo | setpoint |  |  |  | gvf.db |
| `$(R):STN:GVF:XFERFN` | bo | setpoint |  |  | 0=Off 1=On | gvf.db |
| `$(R):STN:I$(M)$(C)` | sub | computed |  | V |  | iqCvt.db |
| `$(R):STN:IQGET$(M)` | sub | computed |  |  |  | iqGet.db |
| `$(R):STN:P$(M)$(C)` | sub | computed |  | deg |  | iqCvt.db |
| `$(R):STN:PWR$(M)$(C)` | sub | computed |  | W |  | iqCvt.db |
| `$(R):STN:Q$(M)$(C)` | sub | computed |  | V |  | iqCvt.db |
| `$(R):STN:TRM` | bi | readback |  |  |  | iqGet.db |
| `$(S):STN:ARCSUMY:LTCH` | bi | derived | STN Arc Fault |  | 0=OK 1=FAULT | rf_stn.db |
| `$(S):STN:BEAMABORT:STAT` | bi | derived | Beam Abort Status |  | 0=OFF 1=ON | rf_stn.db |
| `$(S):STN:CONV:LOSS` | sub | computed | IQ and A Conv Loss Calc | dB |  | rf_stn.db |
| `$(S):STN:CRATE:LTCH` | bi | derived | STN Crate Temp/VoltTol |  | 0=OK 1=FAULT | rf_stn.db |
| `$(S):STN:DCM:MODU` | abDcm | readback | Station DCM Module |  |  | rf_stn.db |
| `$(S):STN:FASTON:CTRL` | bo | setpoint | Station Fast On Enable |  | 0=OFF 1=ON | rf_stn.db |
| `$(S):STN:FAULT:ANUM` | ao | setpoint | Fault to Analyze |  |  | rf_stn.db |
| `$(S):STN:FAULT:CTRL` | bo | setpoint | Fault Files Enable |  | 0=OFF 1=ON | rf_stn.db |
| `$(S):STN:FAULT:FSIZE` | ao | setpoint | Fault File Size Kb | Kb |  | rf_stn.db |
| `$(S):STN:FAULT:NUM` | ao | setpoint | Last Fault Number |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME1` | stringout | setpoint | Date/Time FAULT 1 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME10` | stringout | setpoint | Date/Time FAULT 10 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME11` | stringout | setpoint | Date/Time FAULT 11 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME12` | stringout | setpoint | Date/Time FAULT 12 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME13` | stringout | setpoint | Date/Time FAULT 13 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME14` | stringout | setpoint | Date/Time FAULT 14 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME15` | stringout | setpoint | Date/Time FAULT 15 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME2` | stringout | setpoint | Date/Time FAULT 2 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME3` | stringout | setpoint | Date/Time FAULT 3 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME4` | stringout | setpoint | Date/Time FAULT 4 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME5` | stringout | setpoint | Date/Time FAULT 5 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME6` | stringout | setpoint | Date/Time FAULT 6 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME7` | stringout | setpoint | Date/Time FAULT 7 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME8` | stringout | setpoint | Date/Time FAULT 8 |  |  | rf_stn.db |
| `$(S):STN:FAULT:TIME9` | stringout | setpoint | Date/Time FAULT 9 |  |  | rf_stn.db |
| `$(S):STN:FM1000HZ:IFILE` | stringout | setpoint | Swept Sine 1000 Hz I File |  |  | rf_stn.db |
| `$(S):STN:FM1000HZ:QFILE` | stringout | setpoint | Swept Sine 1000 Hz Q File |  |  | rf_stn.db |
| `$(S):STN:FM400HZ:IFILE` | stringout | setpoint | Swept Sine 400 Hz I File |  |  | rf_stn.db |
| `$(S):STN:FM400HZ:QFILE` | stringout | setpoint | Swept Sine 400 Hz Q File |  |  | rf_stn.db |
| `$(S):STN:FMTYPE:CTRL` | bo | setpoint | Station ON FM File Type |  | 0=400_HZ 1=1000_HZ | rf_stn.db |
| `$(S):STN:ID` | state | state | Station ID |  |  | rf_stn.db |
| `$(S):STN:NCV:PLC` | bi | readback | Station Cavity ID |  | 0=4CV 1=2CV | rf_stn.db |
| `$(S):STN:PARK:CTRL` | calc | computed | Station Park Control |  |  | rf_stn.db |
| `$(S):STN:PARK:FAN1` | fanout | processing | Station Park First Fanout |  |  | rf_stn.db |
| `$(S):STN:PARK:FAN2` | fanout | processing | Station Park Second Fanout |  |  | rf_stn.db |
| `$(S):STN:PARK:FAN3` | fanout | processing | Station Park Third        |  |  | rf_stn.db |
| `$(S):STN:PARK:SEQ1` | seq | processing | Station Park First Seq |  |  | rf_stn.db |
| `$(S):STN:PARK:SEQ2` | seq | processing | Station Park Second Seq |  |  | rf_stn.db |
| `$(S):STN:RAMP:SETTLE` | ao | setpoint | Ramping Settling Time | Sec |  | rf_stn.db |
| `$(S):STN:RESET:COUNTER` | ao | setpoint | Reset Counter | Count |  | rf_stn.db |
| `$(S):STN:RESET:CTRL` | seq | processing | Interlock Reset |  |  | rf_stn.db |
| `$(S):STN:RESETCONT:CTRL` | seq | processing | Interlock Reset (cont) |  |  | rf_stn.db |
| `$(S):STN:RF476MHZREF:FANO` | fanout | processing | RF 476 MHz Reference Fanout |  |  | rf_stn.db |
| `$(S):STN:RF476MHZREF:LTCH` | bi | derived | RF 476 MHz Ref Status |  | 0=OK 1=FAULT | rf_stn.db |
| `$(S):STN:RING:PLC` | mbbi | derived | Station Ring ID |  |  | rf_stn.db |
| `$(S):STN:STATE:CTRL` | mbbo | setpoint | Desired Station State |  |  | rf_stn.db |
| `$(S):STN:STATE:RBCK` | mbbo | setpoint | Actual Station State |  |  | rf_stn.db |
| `$(S):STN:STATE:STRING` | stringout | setpoint | Station State Status String |  |  | rf_stn.db |
| `$(S):STN:SUMY:STAT` | mbbi | derived | $(RING) RF$(REGIOC) Stat |  |  | rf_stn.db |
| `$(S):STN:SUMY:STAT:VSTA` | longout | setpoint | Station Status VSTA |  |  | rf_stn.db |
| `$(S):STN:SUMY:STATC` | calc | computed | Station Status (Calc) |  |  | rf_stn.db |
| `$(S):STN:TICKLE:CTRL` | bo | setpoint | Station Tickle Enable |  | 0=OFF 1=ON | rf_stn.db |
| `$(S):STN:TICKLE:IFILE` | stringout | setpoint | Beam Tickle I File |  |  | rf_stn.db |
| `$(S):STN:TICKLE:QFILE` | stringout | setpoint | Beam Tickle Q File |  |  | rf_stn.db |
| `$(S):STN:VOLT:SETTLE` | ao | setpoint | Stn Voltage Settling Time | Sec |  | rf_stn.db |
| `$(S):STNAB:RESET:CTRL` | sub | computed | Allen-Bradley Reset |  |  | rf_stn.db |
| `$(S):WGAIR:NIRP:STAT` | bi | derived | WG Air NIRP Status |  | 0=OK 1=FAULT | rf_stn.db |
| `$(S):WGAIR:NIRP:STATC` | calc | computed | WG Air NIRP Status (Calc) |  |  | rf_stn.db |

### 5.2. Station Cavity (18 signals)

**Per-cavity station signals - tuner loop control, load angle calculations, gap voltage setpoints, cavity calibration, direct/comb loop phase control.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(S):STN:CONV:CONST` | sub | computed | Ref Ampl Conv Const Calc | Cnts/kV |  | rf_stn_cav.db |
| `$(S):STN:PHASE` | ao | setpoint | STNPHASE  Station Phase | deg |  | rf_stn_cav.db |
| `$(S):STN:PHASE:CALC` | sub | computed | Station Phase | deg |  | rf_stn_cav.db |
| `$(S):STN:VOLT` | calc | computed | Station Voltage | kV |  | rf_stn_cav.db |
| `$(S):STN:VOLT:CTRL` | ao | setpoint | STNVLTDES Stn Volt Control | kV |  | rf_stn_cav.db |
| `$(S):STN:VOLT:ERR` | sel | computed | Stn Volt Error | kV | HH=30, LL=-30 | rf_stn_cav.db |
| `$(S):STN:VOLT:FACTOR` | calc | computed | Station Voltage Factors |  |  | rf_stn_cav.db |
| `$(S):STN:VOLT:FACTORSEQ` | seq | processing | Stn Voltage Factor Update |  |  | rf_stn_cav.db |
| `$(S):STN:VOLT:HIST` | compress | history | Station Voltage History | kV |  | rf_stn_cav.db |
| `$(S):STNCOMB:LOOP:PHASE` | sub | computed | Comb Loop Phase | deg |  | rf_stn_cav.db |
| `$(S):STNCURR:VOLT:CTRL` | ao | setpoint | Stn Volt Control | kV |  | rf_stn_cav.db |
| `$(S):STNDIRECT:LOOP:PHASE` | sub | computed | Direct Loop Total Phase | deg |  | rf_stn_cav.db |
| `$(S):STNHCW:TEMPHst` | compress | history | Station HCW Temp History | C |  | rf_stn_cav.db |
| `$(S):STNTRANS:VOLT:CTRL` | sel | computed | Stn Volt Transit Control | kV |  | rf_stn_cav.db |
| `$(S):STNVOLT:DAC:CALSEQ` | seq | processing | Stn DAC Calib |  |  | rf_stn_cav.db |
| `$(S):STNVOLT:DAC:DELTA` | sub | computed | Stn Volt DAC Delta Cnts | Counts |  | rf_stn_cav.db |
| `$(S):STNVOLT:GFF:CALSEQ` | seq | processing | Stn GFF Calib |  |  | rf_stn_cav.db |
| `$(S):STNVOLT:GFF:DELTA` | sub | computed | Stn Volt GFF Delta Cnts | Counts |  | rf_stn_cav.db |

### 5.3. Hvps (35 signals)

**High Voltage Power Supply control and monitoring - contactor logic, voltage control loops, power/perveance calculations, SCR control, DCM table status.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(S):HVPS$(C):$(Q)` | bi | readback | HVPS $(C) $(D) |  | 0=$(ZN) 1=$(ON) | rf_digital_hvps.db |
| `$(S):HVPS:CURR` | ai | readback | HVPS Monitored Current | Amp | HH=30, H=30 | rf_hvps.db |
| `$(S):HVPS:LOOP:CTRL` | mbbo | setpoint | HVPS Loop Enable |  |  | rf_hvps.db |
| `$(S):HVPS:LOOP:DELAY` | ao | setpoint | HVPS Loop Activation Delay | Sec |  | rf_hvps.db |
| `$(S):HVPS:LOOP:READY` | event | processing | HVPS Loop Ready |  |  | rf_hvps.db |
| `$(S):HVPS:LOOP:STATE` | mbbo | setpoint | HVPS Loop State |  |  | rf_hvps.db |
| `$(S):HVPS:LOOP:STATUS` | mbbo | setpoint | HVPS Loop Status |  |  | rf_hvps.db |
| `$(S):HVPS:LOOP:STRING` | stringout | setpoint | HVPS Loop Status String |  |  | rf_hvps.db |
| `$(S):HVPS:LOOP:VOLTDIFF` | ao | setpoint | HVPS Loop Allowed kV Diff | kV |  | rf_hvps.db |
| `$(S):HVPS:LOOP:VOLTDOWN` | ao | setpoint | HVPS Loop Delta kV Down | kV |  | rf_hvps.db |
| `$(S):HVPS:LOOP:VOLTHIST` | compress | history | HVPS Loop Voltage History | kV |  | rf_hvps.db |
| `$(S):HVPS:LOOP:VOLTUP` | ao | setpoint | HVPS Loop Delta kV Up | kV |  | rf_hvps.db |
| `$(S):HVPS:PERV` | calc | computed | HVPS Perveance | micrPerv | HH=1.1, H=1.05, L=1.0, LL=0.95 | rf_hvps.db |
| `$(S):HVPS:POWER` | calc | computed | HVPS Power | kW |  | rf_hvps.db |
| `$(S):HVPS:RESET:CTRL` | bo | output | HVPS Reset Control |  | H=3 | rf_hvps.db |
| `$(S):HVPS:VOLT` | ai | readback | HVPS Monitored Voltage | kV | HH=87, H=85 | rf_hvps.db |
| `$(S):HVPS:VOLT:CTRL` | ao | output | HVPSDESVLT HVPS Desired Volt | kV |  | rf_hvps.db |
| `$(S):HVPS:VOLT:FASTON` | ao | setpoint | Fast Turnon Stn Voltage | kV |  | rf_stn_cav.db |
| `$(S):HVPS:VOLT:LOOP` | ao | setpoint | HVPS Loop Desired Voltage | kV |  | rf_hvps.db |
| `$(S):HVPS:VOLT:MAX` | ao | output | HVPS Max Voltage | kV |  | rf_hvps.db |
| `$(S):HVPS:VOLT:MIN` | ao | setpoint | HVPSMINVLT HVPS Min Voltage | kV |  | rf_hvps.db |
| `$(S):HVPS:VOLT:RBCK` | ai | readback | HVPS Desired Volt Readback | kV | HH=87, H=85 | rf_hvps.db |
| `$(S):HVPS:VOLT:ULIM` | ai | readback | HVPS Max Voltage Readback | kV |  | rf_hvps.db |
| `$(S):HVPS:VOLTULIM:CTRL` | ao | setpoint | HVPSMAXVLT HVPS Max Voltage | kV |  | rf_hvps.db |
| `$(S):HVPS:VOLTULIM:SEQ` | seq | processing | HVPS Max Voltage Seq |  |  | rf_hvps.db |
| `$(S):HVPSAC:CURR` | ai | readback | HVPS AC Current | Amp | HH=500, H=400 | rf_hvps.db |
| `$(S):HVPSCONTACT:CLOSE:CTRL` | bo | output | HVPS Contactor State Control |  | 0=OPEN 1=CLOSE | rf_hvps.db |
| `$(S):HVPSCONTACT:CTRL:SEQ` | seq | processing | HVPS Contactor Control Seq |  |  | rf_hvps.db |
| `$(S):HVPSDCM:T0:STAT` | mbbi | readback | HVPS SLC Table 0 Status |  |  | rf_hvps.db |
| `$(S):HVPSOIL:TEMP` | ai | readback | HVPS Oil | C | HH=80, H=75, L=15, LL=10 | rf_hvps.db |
| `$(S):HVPSOIL:TEMP:FRST` | bo | setpoint | HVPS Oil |  | 0=OK 1=FAULT | rf_hvps.db |
| `$(S):HVPSOIL:TEMP:ULIM` | ao | setpoint | HVPS Oil | C |  | rf_hvps.db |
| `$(S):HVPSSCR:ON:CTRL` | bo | output | HVPS SCR Enable Switch |  | 0=OFF 1=ON | rf_hvps.db |
| `$(S):KLYSDRIVFRWD:HVPS:DELTA` | sub | computed | Drive Pwr HVPS Delta Volt | kV |  | rf_klys.db |
| `$(S):STNVOLT:HVPS:DELTA` | sub | computed | Stn Volt HVPS Delta Volt | kV |  | rf_stn_cav.db |

### 5.4. Klystron (25 signals)

**Klystron monitoring and derived calculations - drive power, forward power, gain, collector power, efficiency, filament power, ripple measurements.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(S):FILAMENT:POWER` | calc | computed | Filament Power | W |  | rf_klys.db |
| `$(S):FILAMENT:TIME` | ai | readback | Klys Filament Time Left | Sec | HH=1700, H=1 | rf_klys.db |
| `$(S):KLYS:EFFICIENCY` | sub | computed | Klystron Efficiency | Percent |  | rf_klys.db |
| `$(S):KLYS:GAIN` | sub | computed | Klystron Gain | dB |  | rf_klys.db |
| `$(S):KLYS:GAIN:CTRL` | ao | setpoint | Klys Gain Setpoint | dB |  | rf_klys.db |
| `$(S):KLYSCOLL:POWER` | sub | computed | Klystron Collector Power | kW |  | rf_klys.db |
| `$(S):KLYSCOLL:POWER:ULIM` | ai | readback | Klys Coll Power Limit | kW |  | rf_klys.db |
| `$(S):KLYSCOLLPLC:POWER` | ai | readback | Klys Coll Power from PLC | kW | HH=1175, H=1150 | rf_klys.db |
| `$(S):KLYSDRIVFRWD:DAC:DELTA` | sub | computed | Drive Power DAC Delta Cnts | Counts |  | rf_klys.db |
| `$(S):KLYSDRIVFRWD:GFF:DELTA` | sub | computed | Drive Power GFF Delta Counts | Counts |  | rf_klys.db |
| `$(S):KLYSDRIVFRWD:ODAC:DELTA` | sub | computed | Drive Power DAC Delta Counts | Counts |  | rf_klys.db |
| `$(S):KLYSDRIVFRWD:POWER:CTRL` | sel | computed | Drive Power Setpoint | W |  | rf_klys.db |
| `$(S):KLYSDRIVFRWD:POWER:ERR` | sel | computed | Drive Power Error | W | HH=5, LL=-1 | rf_klys.db |
| `$(S):KLYSDRIVFRWD:POWER:HIGH` | ao | setpoint | DRVPWRHI  Drive Pwr Hi Beam | W |  | rf_klys.db |
| `$(S):KLYSDRIVFRWD:POWER:HIST` | compress | history | Klys Drive Power History | W |  | rf_klys.db |
| `$(S):KLYSDRIVFRWD:POWER:ON` | ao | setpoint | DRVPWRLO  Drive Power Lo Bm | W |  | rf_klys.db |
| `$(S):KLYSDRIVFRWD:POWER:SAT` | ao | setpoint | DRVPWRSAT Drive Power Satur | W |  | rf_klys.db |
| `$(S):KLYSDRIVFRWD:POWER:SEL` | sub | computed | Drive Power Setpoint Select |  |  | rf_klys.db |
| `$(S):KLYSDRIVFRWD:POWER:TUNE` | ao | setpoint | Drive Pwr TUNE Ctrl | W |  | rf_klys.db |
| `$(S):KLYSOUTFRWD:POWER:HIGH` | ao | setpoint | Klys Out Frwd Pwr High Beam | kW |  | rf_klys.db |
| `$(S):KLYSOUTFRWD:POWER:HIST` | compress | history | Klys Out Frwd Power History | kW |  | rf_klys.db |
| `$(S):KLYSOUTFRWD:POWER:MAX` | ao | setpoint | Klys Out Frwd Pwr HVPS Limit | kW |  | rf_klys.db |
| `$(S):KLYSOUTFRWD:POWER:MIN` | ao | setpoint | Klys Out Frwd Pwr TUNR Limit | kW |  | rf_klys.db |
| `$(S):KLYSOUTFRWD:POWER:NORM` | ao | setpoint | Klys Out Frwd Pwr Normal | kW |  | rf_klys.db |
| `$(S):STNRIPPLE:LOOP:AMPL` | sub | computed | Ripple Lp DC Coefficient | V |  | rf_klys.db |

### 5.5. Cavity (73 signals)

**Cavity-level signals - RF power, coupling, cavity strength, frequency offset, tuner stepper motor control, vacuum, temperature, window IR monitoring.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(R):STN:CAV1:SEQ` | seq | processing | RFP Module CAV1 DAC Seq |  |  | rfp_dacs.db |
| `$(R):STN:CAV2:SEQ` | seq | processing | RFP Module CAV2 DAC Seq |  |  | rfp_dacs.db |
| `$(R):STN:CAV3:SEQ` | seq | processing | RFP Module CAV3 DAC Seq |  |  | rfp_dacs.db |
| `$(R):STN:CAV4:SEQ` | seq | processing | RFP Module CAV4 DAC Seq |  |  | rfp_dacs.db |
| `$(R):STN:RFP:CAV1` | sub | computed | RFP Module CAV1 DAC Vals | Counts |  | rfp_dacs.db |
| `$(R):STN:RFP:CAV2` | sub | computed | RFP Module CAV2 DAC Vals | Counts |  | rfp_dacs.db |
| `$(R):STN:RFP:CAV3` | sub | computed | RFP Module CAV3 DAC Vals | Counts |  | rfp_dacs.db |
| `$(R):STN:RFP:CAV4` | sub | computed | RFP Module CAV4 DAC Vals | Counts |  | rfp_dacs.db |
| `$(R):STN:RFP:CAVSEL` | mbbo | setpoint |  |  |  | rfp.db |
| `$(S):$(C):BETA:CTRL` | ao | setpoint | $(C) Beta |  |  | rf_cav.db |
| `$(S):$(C):CPLG:FACTOR` | sub | computed | $(C) Coupling Factor |  |  | rf_cav.db |
| `$(S):$(C):FREQ:ERR` | sub | computed | $(C) Park Freq Phase Error | deg |  | rf_cav.db |
| `$(S):$(C):FREQ:OFFS` | sub | computed | $(C) Frequency Offset | kHz |  | rf_cav.db |
| `$(S):$(C):FREQ:OFFSHIST` | compress | history | $(C) Freq Offset History | kHz |  | rf_cav.db |
| `$(S):$(C):POWER` | sub | computed | $(C) Power | kW |  | rf_cav.db |
| `$(S):$(C):Q0:CTRL` | ao | setpoint | $(C) Q0 |  |  | rf_cav.db |
| `$(S):$(C):STRENGTH` | sub | computed | $(C) Strength | Percent |  | rf_cav.db |
| `$(S):$(C):STRENGTH:CTRL` | ao | setpoint | $(C) Desired Strength | Percent |  | rf_cav.db |
| `$(S):$(C)FRWD:DRCTVTY:DB` | ao | setpoint | $(C) Frwd Directivity dB | dB |  | rf_cav.db |
| `$(S):$(C)FRWD:DRCTVTY:PHASE` | ao | setpoint | $(C) Frwd Directivity Phase | deg |  | rf_cav.db |
| `$(S):$(C)FRWD:IQ` | sub | computed | $(C) Forward Corr IQ | Volts |  | rf_cav.db |
| `$(S):$(C)FRWD:PHASE:HIST` | compress | history | $(C) Forward Phase History | deg |  | rf_cav.db |
| `$(S):$(C)LOAD:ANGLE:ERR` | sub | computed | $(C) Load Angle Phase Err | deg | HH=5, H=180, L=-180, LL=-5 | rf_cav.db |
| `$(S):$(C)LOAD:ANGLE:OFFS` | sub | computed | $(C) Load Angle Phase Offset | deg | HH=180, H=180, L=-180, LL=-180 | rf_cav.db |
| `$(S):$(C)LOAD:ANGLE:UNADOFFS` | sub | computed | $(C) Ld Ang Phase Unadj Offs | deg | HH=180, H=180, L=-180, LL=-180 | rf_cav.db |
| `$(S):$(C)LOAD:ANGLEOFFS:HIST` | compress | history | $(C) Ld Angle Offset History | deg |  | rf_cav.db |
| `$(S):$(C)PROBE:PHASE:HIST` | compress | history | $(C) Probe Phase History | deg |  | rf_cav.db |
| `$(S):$(C)REFL:DRCTVTY:DB` | ao | setpoint | $(C) Refl Directivity dB | dB |  | rf_cav.db |
| `$(S):$(C)REFL:DRCTVTY:PHASE` | ao | setpoint | $(C) Refl Directivity Phase | deg |  | rf_cav.db |
| `$(S):$(C)REFL:IQ` | sub | computed | $(C) Reflected Corr IQ | Volts |  | rf_cav.db |
| `$(S):$(C)TUNR:INIT:FANO` | fanout | processing | $(C) Step Motor Init Fanout |  |  | rf_cav.db |
| `$(S):$(C)TUNR:LOOP:HOME` | event | processing | $(C) Tuner Loop Home |  |  | rf_cav.db |
| `$(S):$(C)TUNR:LOOP:RESET` | event | processing | $(C) Tuner Loop Reset |  |  | rf_cav.db |
| `$(S):$(C)TUNR:LOOP:STATE` | mbbo | setpoint | $(C) Tuner Loop State |  |  | rf_cav.db |
| `$(S):$(C)TUNR:LOOP:STATUS` | mbbo | setpoint | $(C) Tuner Loop Status |  |  | rf_cav.db |
| `$(S):$(C)TUNR:LOOP:STRING` | stringout | setpoint | $(C) Tuner Loop Stat String |  |  | rf_cav.db |
| `$(S):$(C)TUNR:LOOPMEAS:READY` | event | processing | $(C) Tuner Loop Meas Ready |  |  | rf_cav.db |
| `$(S):$(C)TUNR:PHASEERR:HIST` | compress | history | $(C) Phase Error History | deg |  | rf_cav.db |
| `$(S):$(C)TUNR:POSN:CTRL` | ao | setpoint | $(S)$(C)SM Tuner Des Posn | mm |  | rf_cav.db |
| `$(S):$(C)TUNR:POSN:DELTA` | sub | computed | $(C) Tuner Loop Delta Posn | mm |  | rf_cav.db |
| `$(S):$(C)TUNR:POSN:HIST` | compress | history | $(C) Tuner Position History | mm |  | rf_cav.db |
| `$(S):$(C)TUNR:POSN:LOOP` | ao | setpoint | $(C) Tuner Loop Desired Posn | mm |  | rf_cav.db |
| `$(S):$(C)TUNR:POSN:ONHOME` | ao | setpoint | $(C) Tuner ON Home Posn | mm |  | rf_cav.db |
| `$(S):$(C)TUNR:POSN:PARKHOME` | ao | setpoint | $(C) Tuner PARK Home Posn | mm |  | rf_cav.db |
| `$(S):$(C)TUNR:STEP:CHCK` | calc | computed | $(C) Step Card Stat Chg |  | HH=1.5, H=0.5 | rf_cav.db |
| `$(S):$(C)TUNR:STEP:CHCKINIT` | calc | computed | $(C) Step Init Check |  | HH=1.5, H=0.5 | rf_cav.db |
| `$(S):$(C)TUNR:STEP:DISA` | calc | computed | $(C) Step Motor Disable |  | L=0.5, LL=0.5 | rf_cav.db |
| `$(S):$(C)TUNR:STEP:INIT` | seq | processing | $(C) Step Motor Init Seq |  |  | rf_cav.db |
| `$(S):$(C)TUNR:STEP:MOTOR` | steppermotor | output | $(S)$(C)SM Tuner Step Motor | mm | HH=0.03175, H=0.015875, L=-0.015875, LL=-0.03175 | rf_cav.db |
| `$(S):$(C)TUNR:STEP:STOP` | seq | processing | $(C) Step Motor Stop Seq |  |  | rf_cav.db |
| `$(S):CAV:FREQ:OFFS` | calc | computed | Cavity Average Freq Offset | kHz | HH=0 | rf_stn_cav.db |
| `$(S):CAV:FREQOFFS:SMOO` | ao | setpoint | Cav Freq Offset Smoothing |  |  | rf_stn_cav.db |
| `$(S):CAV:STRENGTH:DIFF` | ao | setpoint | Cav Strength Allowable Diff | Percent |  | rf_stn_cav.db |
| `$(S):CAV:VACM:MAX` | ao | setpoint | Cavity Vacuum Limit | Torr |  | rf_stn_cav.db |
| `$(S):CAV:VOLT:MAX` | ao | setpoint | Cavity Voltage Limit | kV |  | rf_stn_cav.db |
| `$(S):CAVLOAD:ANGLE:CTRL` | bo | setpoint | Load Angle Offset Enable |  | 0=OFF 1=ON | rf_stn_cav.db |
| `$(S):CAVLOAD:ANGLE:EMAXNEG` | calc | computed | Load Angle Error Neg Max | deg |  | rf_stn_cav.db |
| `$(S):CAVLOAD:ANGLE:ERRMAX` | ao | setpoint | Load Angle Error Maximum | deg |  | rf_stn_cav.db |
| `$(S):CAVLOAD:ANGLE:FORGET` | ao | setpoint | Load Angle Offset Forget |  |  | rf_stn_cav.db |
| `$(S):CAVLOAD:ANGLE:K` | ao | setpoint | Load Angle Offset K | deg/Per |  | rf_stn_cav.db |
| `$(S):CAVLOAD:ANGLE:SELMAX` | sel | computed | Load Angle Maximum Select | deg |  | rf_stn_cav.db |
| `$(S):CAVLOAD:ANGLE:SELMIN` | sel | computed | Load Angle Minimum Select | deg |  | rf_stn_cav.db |
| `$(S):CAVTUNR:LOOP:CTRL` | bo | setpoint | Cavity Tuner Loop Enable |  | 0=OFF 1=ON | rf_stn_cav.db |
| `$(S):CAVTUNR:LOOP:GAIN` | ao | setpoint | Cavity Tuner Loop Gain |  |  | rf_stn_cav.db |
| `$(S):CAVTUNR:LOOP:READY` | event | processing | Cavity Tuner Loop Ready |  |  | rf_stn_cav.db |
| `$(S):CAVTUNR:LOOP:SEQ` | seq | processing | Cavity Tuner Loop Sequence |  |  | rf_stn_cav.db |
| `$(S):CAVTUNR:LOOPON:HOME` | event | processing | Cavity Tuner Loop ON Home |  |  | rf_stn_cav.db |
| `$(S):CAVTUNR:LOOPON:RESET` | event | processing | Cavity Tuner Loop ON Reset |  |  | rf_stn_cav.db |
| `$(S):CAVTUNR:LOOPPARK:HOME` | event | processing | Cavity Tuner Loop PARK Home |  |  | rf_stn_cav.db |
| `$(S):CAVTUNR:LOOPPARK:RESET` | event | processing | Cavity Tuner Loop PARK Reset |  |  | rf_stn_cav.db |
| `$(S):CAVTUNR:STEP:STOP` | seq | processing | Tuner Step Motor Stop Seq |  |  | rf_stn_cav.db |
| `$(S):CAVVACM:CHECK` | calc | computed | Cavity Vacuum Limit Check |  | HH=0.5 | rf_stn_cav.db |
| `$(S):CAVVOLT:CHECK` | calc | computed | Cavity Voltage Limit Check |  | HH=0.5 | rf_stn_cav.db |

### 5.6. Feedback (58 signals)

**Feedback loop control - DAC loop (tune/on/GFF), direct loop, comb loop, ripple loop, TAXI link status, loop ready events.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(R):STN:COMB:SEQ` | seq | processing | RFP Module COMB DAC Seq |  |  | rfp_dacs.db |
| `$(R):STN:DIRECT:SEQ` | seq | processing | RFP Module DIRECT DAC Seq |  |  | rfp_dacs.db |
| `$(R):STN:GVF:GFFLOOP` | bo | setpoint |  |  | 0=Off 1=On | gvf.db |
| `$(R):STN:GVF:LFBLOOP` | bo | setpoint |  |  | 0=Off 1=On | gvf.db |
| `$(R):STN:RFP:ARIPPLELOOP` | bo | setpoint | Analog Ripple Loop |  | 0=Not Active 1=Active | rfp.db |
| `$(R):STN:RFP:COMB` | sub | computed | RFP Module COMB DAC Vals | Counts |  | rfp_dacs.db |
| `$(R):STN:RFP:COMBLOOP` | bo | setpoint |  |  | 0=Off 1=On | rfp.db |
| `$(R):STN:RFP:DIRECT` | sub | computed | RFP Module DIRECT DAC Vals | Counts |  | rfp_dacs.db |
| `$(R):STN:RFP:DIRECTLOOP` | bo | setpoint |  |  | 0=Off 1=On | rfp.db |
| `$(R):STN:RFP:RIPPLELOOP` | bo | setpoint |  |  | 0=Off 1=On | rfp.db |
| `$(S):STN:DAC:LOAD` | seq | processing | Station DAC Load |  |  | rf_fbck.db |
| `$(S):STN:GFF:CTRL` | bo | setpoint | Gap Adaption Enable |  | 0=OFF 1=ON | rf_fbck.db |
| `$(S):STN:GFF:INIT` | ao | setpoint | Stn GFF Init Cnts | Counts |  | rf_fbck.db |
| `$(S):STN:GFF:IQ` | sub | computed | Station GFF I and Q | Counts |  | rf_fbck.db |
| `$(S):STN:GFF:RESET` | sel | computed | Station GFF Mode Reset | Counts |  | rf_fbck.db |
| `$(S):STN:GFF:SEQ` | seq | processing | Station GFF State Seq |  |  | rf_fbck.db |
| `$(S):STN:GFF:UPDATE` | seq | processing | Station GFF Update |  |  | rf_fbck.db |
| `$(S):STN:GFFDLON:INIT` | calc | computed | Stn GFF DL ON Init Cnts | Counts |  | rf_fbck.db |
| `$(S):STN:GFFFAST:INIT` | ao | setpoint | Stn GFF Fast Init Cnts | Counts |  | rf_fbck.db |
| `$(S):STN:LFB:CTRL` | bo | setpoint | LFB Woofer Enable |  | 0=OFF 1=ON | rf_fbck.db |
| `$(S):STN:ON:CTRL` | bo | setpoint | Station ON DAC Loop Enable |  | 0=OFF 1=ON | rf_fbck.db |
| `$(S):STN:ON:INIT` | ao | setpoint | Stn ON Init Cnts | Counts |  | rf_fbck.db |
| `$(S):STN:ON:IQ` | sub | computed | Station ON I and Q | Counts |  | rf_fbck.db |
| `$(S):STN:ON:RESET` | seq | processing | Station ON Mode Reset |  |  | rf_fbck.db |
| `$(S):STN:ON:UPDATE` | seq | processing | Station ON Update |  |  | rf_fbck.db |
| `$(S):STN:ONDLON:INIT` | calc | computed | Stn ON DL ON Init Cnts | Counts |  | rf_fbck.db |
| `$(S):STN:ONFAST:INIT` | ao | setpoint | Stn ON Fast Init Cnts | Counts |  | rf_fbck.db |
| `$(S):STN:TAXILINK:STAT` | sel | computed | Station Taxi Link Status |  | HH=0.5 | rf_fbck.db |
| `$(S):STN:TUNE:CTRL` | bo | setpoint | Station TUNE DAC Loop Enable |  | 0=OFF 1=ON | rf_fbck.db |
| `$(S):STN:TUNE:INIT` | ao | setpoint | Stn TUNE Init Counts | Counts |  | rf_fbck.db |
| `$(S):STN:TUNE:IQ` | sub | computed | Station Tune I and Q | Counts |  | rf_fbck.db |
| `$(S):STN:TUNE:RESET` | seq | processing | Station TUNE Mode Reset |  |  | rf_fbck.db |
| `$(S):STN:TUNE:UPDATE` | seq | processing | Station Tune Update |  |  | rf_fbck.db |
| `$(S):STNCOMB:LOOP:COUNTS` | sub | computed | Comb Loop Gain | Counts |  | rf_fbck.db |
| `$(S):STNCOMB:LOOP:CTRL` | bo | setpoint | Comb Loop Enable |  | 0=OFF 1=ON | rf_fbck.db |
| `$(S):STNCOMB:LOOP:IQ` | sub | computed | Comb Loop I and Q | Counts |  | rf_fbck.db |
| `$(S):STNCOMB:LOOP:RESET` | seq | processing | Comb Loop Reset Seq |  |  | rf_fbck.db |
| `$(S):STNCOMB:LOOP:RESETCONT` | seq | processing | Comb Loop Reset Seq |  |  | rf_fbck.db |
| `$(S):STNCOMB:LOOP:UPDATE` | seq | processing | Comb Loop Update |  |  | rf_fbck.db |
| `$(S):STNCOMB:LOOPTRNS:SEQ` | seq | processing | Comb Loop ON Transit Seq |  |  | rf_fbck.db |
| `$(S):STNDAC:LOOP:READY` | event | processing | Station DAC Loop Ready |  |  | rf_fbck.db |
| `$(S):STNDAC:LOOP:STATUS` | mbbo | setpoint | Station DAC Loop Status |  |  | rf_fbck.db |
| `$(S):STNDAC:LOOP:STRING` | stringout | setpoint | Stn DAC Loop Status String |  |  | rf_fbck.db |
| `$(S):STNDIRECT:INTCOMP:CTRL` | bo | setpoint | Integral Compensation Enable |  | 0=OFF 1=ON | rf_fbck.db |
| `$(S):STNDIRECT:LEADCOMP:CTRL` | bo | setpoint | Lead Compensation Enable |  | 0=OFF 1=ON | rf_fbck.db |
| `$(S):STNDIRECT:LOOP:COUNTS` | sub | computed | Direct Loop Gain | Counts |  | rf_fbck.db |
| `$(S):STNDIRECT:LOOP:CTRL` | bo | setpoint | Direct Loop Enable |  | 0=OFF 1=ON | rf_fbck.db |
| `$(S):STNDIRECT:LOOP:IQ` | sub | computed | Direct Loop I and Q | Counts |  | rf_fbck.db |
| `$(S):STNDIRECT:LOOP:TRACK` | bo | setpoint | Direct Loop Tracking Ctrl |  | 0=OFF 1=ON | rf_fbck.db |
| `$(S):STNDIRECT:LOOP:UPDATE` | seq | processing | Direct Loop Update |  |  | rf_fbck.db |
| `$(S):STNDIRECT:LOOPOFF:FANO` | fanout | processing | Direct Loop OFF Fanout |  |  | rf_fbck.db |
| `$(S):STNDIRECT:LOOPOFF:SEQ` | seq | processing | Direct Loop OFF Seq |  |  | rf_fbck.db |
| `$(S):STNDIRECT:LOOPREST:SEQ` | seq | processing | Direct Loop Restore Seq |  |  | rf_fbck.db |
| `$(S):STNDIRECT:LOOPTRNS:SEQ` | seq | processing | Direct Loop ON Transit Seq |  |  | rf_fbck.db |
| `$(S):STNDRIV:PWRREST:SEQ` | seq | processing | Drive Power Restore Seq |  |  | rf_fbck.db |
| `$(S):STNRIPPLE:LOOP:LOAD` | seq | processing | Ripple Lp Ampl Setpoint Load |  |  | rf_fbck.db |
| `$(S):STNRIPPLE:LOOP:READY` | event | processing | Ripple Loop Gain Ready |  |  | rf_fbck.db |
| `$(S):STNRIPPLE:LOOP:TRACK` | bo | setpoint | Ripple Lp Gain Tracking Ctrl |  | 0=OFF 1=ON | rf_fbck.db |

### 5.7. Iqa (29 signals)

**I/Q Amplitude detector signals - phase, power, amplitude calculations, gap voltage derivation, amplitude fault logic, calibration and scaling.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(R):STN:IQA$(M):AMPFLTSTT` | mbbiDirect | derived |  |  |  | iqa.db |
| `$(R):STN:IQA$(M):AMPMODE` | bo | setpoint |  |  | 0=1_chan 1=8_chan | iqa.db |
| `$(R):STN:IQA$(M):IFMODE` | bo | setpoint |  |  | 0=8 chan 1=1 chan | iqa.db |
| `$(R):STN:IQA$(M):INTACK` | mbboDirect | setpoint |  |  |  | iqa.db |
| `$(R):STN:IQA$(M):INTSTATE` | mbbiDirect | derived |  |  |  | iqa.db |
| `$(R):STN:IQA$(M):MODU` | p2RfIqa | readback |  |  |  | iqa.db |
| `$(S):$(C)$(Q):$(QS)` | sub | computed | $(C) $(D) $(QS) | $(E) | HH=$(H), H=$(H), L=-1E30, LL=-1E30 | rf_iqa.db |
| `$(S):$(C)$(Q):$(QS):FRST` | bi | derived | $(C) $(D) $(QS) Fault |  | 0=OK 1=FAULT | rf_iqa.db |
| `$(S):$(C)$(Q):$(QS):LTCH` | bi | derived | $(C) $(D) $(QS) Fault |  | 0=OK 1=FAULT | rf_iqa.db |
| `$(S):$(C)$(Q):A:RAW` | calc | computed | $(C) $(D) Raw A | Volts |  | rf_iqa_scale.db |
| `$(S):$(C)$(Q):A:SCALE` | calc | computed | $(C) $(D) A Scale | $(AE)/V |  | rf_iqa_scale.db |
| `$(S):$(C)$(Q):A:SMOO` | ao | setpoint | $(C) $(D) Smooth Fac |  |  | rf_iqa.db |
| `$(S):$(C)$(Q):C:SCALE` | calc | computed | $(C) $(D) C Scale |  |  | rf_iqa_scale.db |
| `$(S):$(C)$(Q):CAL:SEQ` | seq | processing | $(C) $(D) Calib |  |  | rf_iqa_scale.db |
| `$(S):$(C)$(Q):CAL:SEQC` | seq | processing | $(C) $(D) Calib |  |  | rf_iqa_scale.db |
| `$(S):$(C)$(Q):IQ:SCALE` | calc | computed | $(C) $(D) IQ Scale | $(AE)/V |  | rf_iqa_scale.db |
| `$(S):$(C)$(Q):PHASE` | sub | computed | $(C) $(D) Phase | deg |  | rf_iqa.db |
| `$(S):$(C)$(Q):PHASE:OFFS` | ao | setpoint | $(C) $(D) Phase Offset | deg |  | rf_iqa.db |
| `$(S):$(C)$(Q):SCLIQ` | sub | computed | $(C) $(D) SclIQ | Volts |  | rf_iqa_scale.db |
| `$(S):$(C)$(Q):ULIM:SEQ` | seq | processing | $(C) $(D) Limit Upd |  |  | rf_iqa_scale.db |
| `$(S):$(C)$(Q):VOLT:ULIM` | sub | computed | $(C) $(D) Volt Limit | V |  | rf_iqa_scale.db |
| `$(S):STN:$(IQA):DRDY` | mbbiDirect | readback | $(IQA) Data Ready Bits |  |  | rf_iqa_module.db |
| `$(S):STN:$(IQA):FRST` | mbbiDirect | readback | $(IQA) Amplitude Latch Bits |  |  | rf_iqa_module.db |
| `$(S):STN:$(IQA):GET` | sub | computed | $(IQA) Get Fresh IQ Values |  |  | rf_iqa_module.db |
| `$(S):STN:$(IQA):LTCH` | mbbiDirect | readback | $(IQA) Amplitude Latch Bits |  |  | rf_iqa_module.db |
| `$(S):STN:$(IQA):OVFL` | mbbiDirect | readback | $(IQA) Data Overflow Bits |  |  | rf_iqa_module.db |
| `$(S):STN:$(IQA):OVWR` | mbbiDirect | readback | $(IQA) Data Overwrite Bits |  |  | rf_iqa_module.db |
| `$(S):STN:$(IQA):SEL` | calc | computed | $(IQA) Channel Select |  |  | rf_iqa_module.db |
| `$(S):STN:$(IQA):SEQ` | seq | processing | $(IQA) Channel Select Seq |  |  | rf_iqa_module.db |

### 5.8. Rf Processor (23 signals)

**RF Processor (RFP) module signals - DAC values, coefficients, run mode, RF enable, modulation control, lead compensation.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(R):STN:RFP:CALMSG` | stringin | derived |  |  |  | rfp.db |
| `$(R):STN:RFP:CALSTATUS` | mbbo | setpoint | last calibration status |  |  | rfp.db |
| `$(R):STN:RFP:CALTIME` | stringin | derived |  |  |  | rfp.db |
| `$(R):STN:RFP:DACS` | bo | setpoint | Dacs Output On/Off Control |  | 0=Off 1=On | rfp.db |
| `$(R):STN:RFP:DINJ` | bo | setpoint | Dacs Output Control |  | 0=Noise 1 1=Noise 2 | rfp.db |
| `$(R):STN:RFP:DOODCALIB` | bo | setpoint | Calibrate button |  | 0=Calibrate 1=Abort | rfp.db |
| `$(R):STN:RFP:FBSIG` | mbbo | setpoint | Feedback Signal Mux Ctrl |  |  | rfp.db |
| `$(R):STN:RFP:INTACK` | mbboDirect | setpoint |  |  |  | rfp.db |
| `$(R):STN:RFP:INTCOMP` | bo | setpoint |  |  | 0=Off 1=On | rfp.db |
| `$(R):STN:RFP:INTSTATE` | mbbiDirect | derived |  |  |  | rfp.db |
| `$(R):STN:RFP:LEADCOMP` | bo | setpoint |  |  | 0=Off 1=On | rfp.db |
| `$(R):STN:RFP:MODU` | p2RfRfp | readback | RFP Module |  |  | rfp.db |
| `$(R):STN:RFP:RFENABLE` | bo | setpoint |  |  | 0=OFF 1=ON | rfp.db |
| `$(R):STN:RFP:RFSTATUS` | mbbiDirect | derived |  |  |  | rfp.db |
| `$(R):STN:RFP:RUNMODE` | bo | setpoint |  |  | 0=Tune 1=Operate | rfp.db |
| `$(R):STN:RFP:SSCONT` | bo | setpoint | RF Run Mode |  | 0=Single Shot 1=Continuous | rfp.db |
| `$(R):STN:RFP:STATE` | mbbo | setpoint | RF Operating Mode |  |  | rfp.db |
| `$(R):STN:RFP:TUNE` | sub | computed | RFP Module TUNE DAC Vals | Counts |  | rfp_dacs.db |
| `$(R):STN:TUNE:SEQ` | seq | processing | RFP Module TUNE DAC Seq |  |  | rfp_dacs.db |
| `$(S):STN:$(TYPE):SEQ` | seq | processing | RFP Module $(TYPE) DAC Seq |  |  | rf_rfp_fourdacs.db |
| `$(S):STN:$(TYPE):SEQ` | seq | processing | RFP Module $(TYPE) DAC Seq |  |  | rf_rfp_twodacs.db |
| `$(S):STN:RFP:$(TYPE)` | sub | computed | RFP Module $(TYPE) DAC Vals | Counts |  | rf_rfp_fourdacs.db |
| `$(S):STN:RFP:$(TYPE)` | sub | computed | RFP Module $(TYPE) DAC Vals | Counts |  | rf_rfp_twodacs.db |

### 5.9. Arc Interlock (9 signals)

**Arc Interlock Module (AIM) signals - fast arc detection, station enable/disable, fault latching.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(R):CRATE:1P5:VOLT` | ai | derived | VXI Crate +5 Voltage | V | HH=5.5, H=5.35, L=4.65, LL=4.5 | aim.db |
| `$(R):CRATE:M12:VOLT` | ai | derived | VXI Crate -12 Voltage | V | HH=-10.8, H=-11.16, L=-12.84, LL=-13.2 | aim.db |
| `$(R):CRATE:M24:VOLT` | ai | derived | VXI Crate -24 Voltage | V | HH=-21.6, H=-22.32, L=-25.68, LL=-26.4 | aim.db |
| `$(R):CRATE:M2:VOLT` | ai | derived | VXI Crate -2 Voltage | V | HH=-1.80, H=-1.86, L=-2.14, LL=-2.20 | aim.db |
| `$(R):CRATE:M5:VOLT` | ai | derived | VXI Crate -5 Voltage | V | HH=-4.68, H=-4.83, L=-5.57, LL=-5.72 | aim.db |
| `$(R):CRATE:P12:VOLT` | ai | derived | VXI Crate +12 Voltage | V | HH=13.2, H=12.84, L=11.16, LL=10.8 | aim.db |
| `$(R):CRATE:P24:VOLT` | ai | derived | VXI Crate +24 Voltage | V | HH=26.4, H=25.68, L=22.32, LL=21.6 | aim.db |
| `$(R):CRATE:P5:VOLT` | ai | derived | VXI Crate +5 Voltage | V | HH=5.5, H=5.35, L=4.65, LL=4.5 | aim.db |
| `$(R):CRATE:VXI:TEMP` | ai | derived | VXI Crate Temp | C | HH=45, H=36, L=25, LL=20 | aim.db |

### 5.10. Analog Io (21 signals)

**PLC analog input signals - filament voltage/current, solenoid voltage/current, circulator current, vacuum, ion pump, tuner block power supply.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(S):$(C)$(Q)` | ai | readback | $(C) $(D) | $(E) | HH=$(HH), H=$(HI), L=$(LW), LL=$(LL) | rf_analog.db |
| `$(S):$(C)$(Q)` | sub | computed | $(C) $(D) | $(E) | HH=$(HH), H=$(HI), L=$(LW), LL=$(LL) | rf_analog_log.db |
| `$(S):$(C)$(Q):FRST` | calc | computed | $(C) $(D) |  |  | rf_analog.db |
| `$(S):$(C)$(Q):FRST` | calc | computed | $(C) $(D) |  |  | rf_analog_log.db |
| `$(S):$(C)$(Q):LLIM` | ai | readback | $(C) $(D) | $(E) |  | rf_analog.db |
| `$(S):$(C)$(Q):LLIM` | calc | computed | $(C) $(D) | $(E) |  | rf_analog_log.db |
| `$(S):$(C)$(Q):LTCH` | calc | computed | $(C) $(D) |  |  | rf_analog.db |
| `$(S):$(C)$(Q):LTCH` | calc | computed | $(C) $(D) |  |  | rf_analog_log.db |
| `$(S):$(C)$(Q):ULIM` | ai | readback | $(C) $(D) | $(E) |  | rf_analog.db |
| `$(S):$(C)$(Q):ULIM` | calc | computed | $(C) $(D) | $(E) |  | rf_analog_log.db |
| `$(S):$(C)$(Q)LLIM:FRST` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_analog.db |
| `$(S):$(C)$(Q)LLIM:FRST` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_analog_log.db |
| `$(S):$(C)$(Q)LLIM:LTCH` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_analog.db |
| `$(S):$(C)$(Q)LLIM:LTCH` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_analog_log.db |
| `$(S):$(C)$(Q)LOG` | ai | readback | $(C) $(D) | log$(E) |  | rf_analog_log.db |
| `$(S):$(C)$(Q)LOG:LLIM` | ai | readback | $(C) $(D) | Log$(E) |  | rf_analog_log.db |
| `$(S):$(C)$(Q)LOG:ULIM` | ai | readback | $(C) $(D) | Log$(E) |  | rf_analog_log.db |
| `$(S):$(C)$(Q)ULIM:FRST` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_analog.db |
| `$(S):$(C)$(Q)ULIM:FRST` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_analog_log.db |
| `$(S):$(C)$(Q)ULIM:LTCH` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_analog.db |
| `$(S):$(C)$(Q)ULIM:LTCH` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_analog_log.db |

### 5.11. Digital Io (2 signals)

**PLC digital I/O signals - module status, non-interlocked binary inputs, HVPS digital status.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(S):$(C)$(Q)` | bi | readback | $(C) $(D) |  | 0=$(ZN) 1=$(ON) | rf_digital_plc.db |
| `$(S):$(C)$(Q):MODU` | bi | derived | $(C) $(Q) Mod Status |  | 0=OK 1=FAULT | rf_digital_modu.db |

### 5.12. Interlocks (8 signals)

**Interlock signals - PLC interlocked digital inputs, VXI module interlocks, arc fault detection.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(S):$(C)$(Q):FRST` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_interlock.db |
| `$(S):$(C)$(Q):FRST` | bi | derived | $(C) $(D) |  | 0=OK 1=FAULT | rf_interlock_arc.db |
| `$(S):$(C)$(Q):FRSTC` | calc | computed | $(C) $(D) |  |  | rf_interlock_arc.db |
| `$(S):$(C)$(Q):LTCH` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_interlock.db |
| `$(S):$(C)$(Q):LTCH` | bi | derived | $(C) $(D) |  | 0=FAULT 1=OK | rf_interlock_arc.db |
| `$(S):$(C)$(Q):LTCHC` | calc | computed | $(C) $(D) |  |  | rf_interlock_arc.db |
| `$(S):$(C):$(Q):FRST` | bi | derived | $(C) $(D) |  | 0=OK 1=FAULT | rf_interlock_vxi.db |
| `$(S):$(C):$(Q):LTCH` | bi | derived | $(C) $(D) |  | 0=OK 1=FAULT | rf_interlock_vxi.db |

### 5.13. Temperature (4 signals)

**Temperature monitoring signals from thermocouple inputs via Allen-Bradley PLC.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(S):$(C)$(Q):TEMP` | ai | readback | $(C) $(D) | C | HH=$(HH), H=$(HI), L=$(LW), LL=$(LL) | rf_temp.db |
| `$(S):$(C)$(Q):TEMP:FRST` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_temp.db |
| `$(S):$(C)$(Q):TEMP:LTCH` | bi | readback | $(C) $(D) |  | 0=OK 1=FAULT | rf_temp.db |
| `$(S):$(C)$(Q):TEMP:ULIM` | ai | readback | $(C) $(D) | C |  | rf_temp.db |

### 5.14. Allen Bradley (4 signals)

**Allen-Bradley PLC adapter and DCM data communication signals.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(S):$(C)$(Q):MODU` | bi | readback | $(C) $(Q) Mod Status |  | 0=OK 1=FAULT | rf_ab_module.db |
| `$(S):$(C):A$(A):MODU` | mbbi | readback | AB Adapter $(A) Status |  |  | ab_adapter.db |
| `$(S):$(C):A$(A)C$(CD):MODU` | mbbi | readback | Adptr $(A) Card $(CD) Stat |  |  | ab_adapter_card.db |
| `$(S):STNDCM:T$(T):STAT` | mbbi | readback | Stn DCM Table $(T) Status |  |  | ab_dcm_table.db |

### 5.15. Summary Alarm (270 signals)

**Summary and alarm rollup signals - fanout processing chains, alarm aggregation, station/subsystem status.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(S):$(C)$(Q):SUMY:PLC` | bi | readback | $(C) PLC Status Sum |  | 0=FAULT 1=OK | rf_sumy_plc.db |
| `$(S):$(C):SUMY:FRST` | calc | computed | $(C) Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C):SUMY:FRST` | calc | computed | $(C) Status Sum |  |  | rf_sumy_wg.db |
| `$(S):$(C):SUMY:LTCH` | calc | computed | $(C) Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C):SUMY:LTCH` | calc | computed | $(C) Status Sum |  |  | rf_sumy_wg.db |
| `$(S):$(C):SUMY:MODU` | calc | computed | $(C) Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C):SUMY:SEVR` | calc | computed | $(C) Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C):SUMY:SEVR` | calc | computed | $(C) Status Sum |  |  | rf_sumy_wg.db |
| `$(S):$(C)BD:TEMP` | sel | computed | $(C) Body Temp Maximum | C |  | rf_sumy_cav.db |
| `$(S):$(C)BDINT:TEMP` | sel | computed | $(C) Body Temp Int Maximum | C |  | rf_sumy_cav.db |
| `$(S):$(C)BDTEMP:SUMY:FRST` | calc | computed | $(C) Body Temp Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)BDTEMP:SUMY:LTCH` | calc | computed | $(C) Body Temp Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)BDTEMP:SUMY:SEVR` | calc | computed | $(C) Body Temp Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)BDTEMPI:SUMY:FRST` | calc | computed | $(C) Body Temp Int Stat Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)BDTEMPI:SUMY:LTCH` | calc | computed | $(C) Body Temp Int Stat Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)BDTEMPI:SUMY:SEVR` | calc | computed | $(C) Body Temp Int Stat Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)IQA:SUMY:FRST` | calc | computed | $(C) IQA Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)IQA:SUMY:FRST` | calc | computed | $(C) IQA Status Sum |  |  | rf_sumy_wg.db |
| `$(S):$(C)IQA:SUMY:LTCH` | calc | computed | $(C) IQA Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)IQA:SUMY:LTCH` | calc | computed | $(C) IQA Status Sum |  |  | rf_sumy_wg.db |
| `$(S):$(C)IQA:SUMY:SEVR` | calc | computed | $(C) IQA Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)IQA:SUMY:SEVR` | calc | computed | $(C) IQA Status Sum |  |  | rf_sumy_wg.db |
| `$(S):$(C)TEMP:SUMY:FRST` | calc | computed | $(C) Temp Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TEMP:SUMY:FRST` | calc | computed | $(C) Temp Status Sum |  |  | rf_sumy_wg.db |
| `$(S):$(C)TEMP:SUMY:LTCH` | calc | computed | $(C) Temp Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TEMP:SUMY:LTCH` | calc | computed | $(C) Temp Status Sum |  |  | rf_sumy_wg.db |
| `$(S):$(C)TEMP:SUMY:MODU` | calc | computed | $(C) TC Mod Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TEMP:SUMY:SEVR` | calc | computed | $(C) Temp Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TEMP:SUMY:SEVR` | calc | computed | $(C) Temp Status Sum |  |  | rf_sumy_wg.db |
| `$(S):$(C)TUNR:SUMY:FRST` | calc | computed | $(C) Tuner Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TUNR:SUMY:LTCH` | calc | computed | $(C) Tuner Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TUNR:SUMY:MODU` | calc | computed | $(C) Tuner Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TUNR:SUMY:SEVR` | calc | computed | $(C) Tuner Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TUNRTEMP:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_cav.db |
| `$(S):$(C)TUNRTEMP:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_cav.db |
| `$(S):$(C)TUNRTEMP:SUMY:FRST` | calc | computed | $(C) Tuner Temp Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TUNRTEMP:SUMY:LTCH` | calc | computed | $(C) Tuner Temp Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)TUNRTEMP:SUMY:SEVR` | calc | computed | $(C) Tuner Temp Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)VACM:SUMY:FRST` | calc | computed | $(C) Vacuum Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)VACM:SUMY:LTCH` | calc | computed | $(C) Vacuum Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)VACM:SUMY:MODU` | calc | computed | $(C) Vacuum Status Sum |  |  | rf_sumy_cav.db |
| `$(S):$(C)VACM:SUMY:SEVR` | calc | computed | $(C) Vacuum Status Sum |  |  | rf_sumy_cav.db |
| `$(S):AREATEMP:SUMY:SEVR` | calc | computed | Area Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAV1:ARC:FRST` | calc | computed | CAV1 Arc Status Sum |  |  | rf_sumy_arc_2CV.db |
| `$(S):CAV1:ARC:FRST` | calc | computed | CAV1 Arc Status Sum |  |  | rf_sumy_arc_4CV.db |
| `$(S):CAV1:ARC:FRST` | calc | computed | CAV1 Arc Status Sum |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):CAV1:ARC:LTCH` | calc | computed | CAV1 Arc Status Sum |  |  | rf_sumy_arc_2CV.db |
| `$(S):CAV1:ARC:LTCH` | calc | computed | CAV1 Arc Status Sum |  |  | rf_sumy_arc_4CV.db |
| `$(S):CAV1:ARC:LTCH` | calc | computed | CAV1 Arc Status Sum |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):CAV2:ARC:FRST` | calc | computed | CAV2 Arc Status Sum |  |  | rf_sumy_arc_2CV.db |
| `$(S):CAV2:ARC:FRST` | calc | computed | CAV2 Arc Status Sum |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):CAV2:ARC:LTCH` | calc | computed | CAV2 Arc Status Sum |  |  | rf_sumy_arc_2CV.db |
| `$(S):CAV2:ARC:LTCH` | calc | computed | CAV2 Arc Status Sum |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):CAV3:ARC:FRST` | calc | computed | CAV3 Arc Status Sum |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):CAV3:ARC:LTCH` | calc | computed | CAV3 Arc Status Sum |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):CAV4:ARC:FRST` | calc | computed | CAV4 Arc Status Sum |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):CAV4:ARC:LTCH` | calc | computed | CAV4 Arc Status Sum |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):CAV:FREQOFFSHIST:FANO` | fanout | processing | Cavity History Fanout |  |  | rf_sumy_2CV.db |
| `$(S):CAV:FREQOFFSHIST:FANO` | fanout | processing | Cavity History Fanout |  |  | rf_sumy_4CV.db |
| `$(S):CAV:STRENGTH:FANO` | fanout | processing | Cavity Strength Fanout |  |  | rf_sumy_2CV.db |
| `$(S):CAV:STRENGTH:FANO` | fanout | processing | Cavity Strength Fanout |  |  | rf_sumy_4CV.db |
| `$(S):CAV:SUMY:FRST` | calc | computed | CAV Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAV:SUMY:LTCH` | calc | computed | CAV Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAV:SUMY:MODU` | calc | computed | CAV Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAV:SUMY:SEVR` | calc | computed | CAV Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVARC:SUMY:FRST` | calc | computed | CAV Arc Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVARC:SUMY:LTCH` | calc | computed | CAV Arc Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVFLOW:SUMY:FRST` | calc | computed | CAV Flow Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVFLOW:SUMY:LTCH` | calc | computed | CAV Flow Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVIQA:SUMY:FRST` | calc | computed | CAV IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVIQA:SUMY:LTCH` | calc | computed | CAV IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVIQA:SUMY:SEVR` | calc | computed | CAV IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVLDANGERR:SUMY:SEVR` | calc | computed | CAV Ld Angle Err Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVLOAD:ANGLE:EMAXSEQ` | seq | processing | Load Angle Error Max Seq |  |  | rf_sumy_2CV.db |
| `$(S):CAVLOAD:ANGLE:EMAXSEQ` | seq | processing | Load Angle Error Max Seq |  |  | rf_sumy_4CV.db |
| `$(S):CAVLOAD:ANGLE:FANO` | fanout | processing | Ld Angle Offset Enable Fano |  |  | rf_sumy_2CV.db |
| `$(S):CAVLOAD:ANGLE:FANO` | fanout | processing | Ld Angle Offset Enable Fano |  |  | rf_sumy_4CV.db |
| `$(S):CAVTEMP:SUMY:FRST` | calc | computed | CAV Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVTEMP:SUMY:LTCH` | calc | computed | CAV Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVTEMP:SUMY:MODU` | calc | computed | CAV Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVTEMP:SUMY:SEVR` | calc | computed | CAV Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVTUNR:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_2CV.db |
| `$(S):CAVTUNR:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):CAVTUNR:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_2CV.db |
| `$(S):CAVTUNR:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):CAVTUNR:SUMY:FRST` | calc | computed | CAV Tuner Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVTUNR:SUMY:LTCH` | calc | computed | CAV Tuner Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVTUNR:SUMY:MODU` | calc | computed | CAV Tuner Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVTUNR:SUMY:SEVR` | calc | computed | CAV Tuner Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVTUNRCARD:SUMY:MODU` | calc | computed | CAV Tuner Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVVACM:SUMY:FRST` | calc | computed | CAV Vacuum Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVVACM:SUMY:LTCH` | calc | computed | CAV Vacuum Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVVACM:SUMY:MODU` | calc | computed | CAV Vacuum Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CAVVACM:SUMY:SEVR` | calc | computed | CAV Vacuum Status Sum |  |  | rf_sumy_stn.db |
| `$(S):CIRC:SUMY:FRST` | calc | computed | CIRC Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRC:SUMY:LTCH` | calc | computed | CIRC Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRC:SUMY:MODU` | calc | computed | CIRC Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRC:SUMY:SEVR` | calc | computed | CIRC Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRCFLOW:SUMY:FRST` | calc | computed | CIRC Water Flow Stat Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRCFLOW:SUMY:LTCH` | calc | computed | CIRC Water Flow Stat Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRCHCWTEMP:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_circ.db |
| `$(S):CIRCHCWTEMP:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_circ.db |
| `$(S):CIRCIQA:SUMY:FRST` | calc | computed | CIRC IQA Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRCIQA:SUMY:LTCH` | calc | computed | CIRC IQA Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRCIQA:SUMY:SEVR` | calc | computed | CIRC IQA Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRCTEMP:SUMY:FRST` | calc | computed | CIRC Temp Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRCTEMP:SUMY:LTCH` | calc | computed | CIRC Temp Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRCTEMP:SUMY:MODU` | calc | computed | CIRC Temp Status Sum |  |  | rf_sumy_circ.db |
| `$(S):CIRCTEMP:SUMY:SEVR` | calc | computed | CIRC Temp Status Sum |  |  | rf_sumy_circ.db |
| `$(S):FBCK:SUMY:SEVR` | calc | computed | Feedback Loop Severity Sum |  |  | rf_sumy_stn_pep.db |
| `$(S):FBCK:SUMY:SEVR` | calc | computed | Feedback Loop Severity Sum |  |  | rf_sumy_stn_spr.db |
| `$(S):FILAMENT:SUMY:FRST` | calc | computed | KLYS Filament Status Sum |  |  | rf_sumy_klys.db |
| `$(S):FILAMENT:SUMY:LTCH` | calc | computed | KLYS Filament Status Sum |  |  | rf_sumy_klys.db |
| `$(S):FILAMENT:SUMY:SEVR` | calc | computed | KLYS Filament Status Sum |  |  | rf_sumy_klys.db |
| `$(S):HVPS:SUMY:FRST` | calc | computed | HVPS Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):HVPS:SUMY:LTCH` | calc | computed | HVPS Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):HVPS:SUMY:SEVR` | calc | computed | HVPS Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):HVPSCONTACT:SUMY:STAT` | calc | computed | HVPS Contactor Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):HVPSDCM:SUMY:MODU` | calc | computed | HVPS DCM Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):HVPSOFF:SUMY:STAT` | calc | computed | HVPS Stn OFF Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):HVPSSCR:SUMY:STAT` | calc | computed | HVPS Contactor Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):HVPSSTN:SUMY:LTCH` | calc | computed | HVPS Latch Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):HVPSSTN:SUMY:STAT` | calc | computed | HVPS Misc Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):HVPSTEMP:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_hvps.db |
| `$(S):HVPSTEMP:SUMY:LTCH` | calc | computed | HVPS Temp Latch Status Sum |  |  | rf_sumy_hvps.db |
| `$(S):KLYS:SUMY:FRST` | calc | computed | KLYS Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYS:SUMY:LTCH` | calc | computed | KLYS Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYS:SUMY:MODU` | calc | computed | KLYS Module Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYS:SUMY:SEVR` | calc | computed | KLYS Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSAIDI:SUMY:MODU` | calc | computed | KLYS AI/DI Mod Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD01:SUMY:FRST` | calc | computed | KLYS BD01 Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD01:SUMY:LTCH` | calc | computed | KLYS BD01 Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD01:SUMY:SEVR` | calc | computed | KLYS BD01 Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD01TEMP:SUMY:FRST` | calc | computed | KLYS BD01 Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD01TEMP:SUMY:LTCH` | calc | computed | KLYS BD01 Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD01TEMP:SUMY:SEVR` | calc | computed | KLYS BD01 Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD02:SUMY:FRST` | calc | computed | KLYS BD02 Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD02:SUMY:LTCH` | calc | computed | KLYS BD02 Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD02:SUMY:SEVR` | calc | computed | KLYS BD02 Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD02TEMP:SUMY:FRST` | calc | computed | KLYS BD02 Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD02TEMP:SUMY:LTCH` | calc | computed | KLYS BD02 Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD02TEMP:SUMY:SEVR` | calc | computed | KLYS BD02 Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD03:SUMY:FRST` | calc | computed | KLYS BD03 Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD03:SUMY:LTCH` | calc | computed | KLYS BD03 Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD03:SUMY:SEVR` | calc | computed | KLYS BD03 Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD03TEMP:SUMY:FRST` | calc | computed | KLYS BD03 Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD03TEMP:SUMY:LTCH` | calc | computed | KLYS BD03 Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD03TEMP:SUMY:SEVR` | calc | computed | KLYS BD03 Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD:SUMY:FRST` | calc | computed | KLYS Body Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD:SUMY:LTCH` | calc | computed | KLYS Body Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBD:SUMY:SEVR` | calc | computed | KLYS Body Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBDFLOW:SUMY:FRST` | calc | computed | KLYS Body Flow Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBDFLOW:SUMY:LTCH` | calc | computed | KLYS Body Flow Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBDTEMP:SUMY:FRST` | calc | computed | KLYS Body Temp Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBDTEMP:SUMY:LTCH` | calc | computed | KLYS Body Temp Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSBDTEMP:SUMY:SEVR` | calc | computed | KLYS Body Temp Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSCOLL:SUMY:FRST` | calc | computed | KLYS Coll Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSCOLL:SUMY:LTCH` | calc | computed | KLYS Coll Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSCOLL:SUMY:SEVR` | calc | computed | KLYS Coll Wtr Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSCOLLTEMP:SUMY:FRST` | calc | computed | KLYS Coll Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSCOLLTEMP:SUMY:LTCH` | calc | computed | KLYS Coll Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSCOLLTEMP:SUMY:SEVR` | calc | computed | KLYS Coll Wtr Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSFLOW:SUMY:FRST` | calc | computed | KLYS Flow Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSFLOW:SUMY:LTCH` | calc | computed | KLYS Flow Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSIQA:SUMY:FRST` | calc | computed | KLYS IQA Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSIQA:SUMY:LTCH` | calc | computed | KLYS IQA Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSIQA:SUMY:SEVR` | calc | computed | KLYS IQA Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSTEMP:SUMY:FRST` | calc | computed | KLYS Temp Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSTEMP:SUMY:LTCH` | calc | computed | KLYS Temp Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSTEMP:SUMY:SEVR` | calc | computed | KLYS Temp Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSTEMPDI:SUMY:MODU` | calc | computed | KLYS TC/DI Mod Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSWATRTEMP:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_klys.db |
| `$(S):KLYSWATRTEMP:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_klys.db |
| `$(S):KLYSWNDW:SUMY:FRST` | calc | computed | KLYS Wndw Air Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSWNDW:SUMY:LTCH` | calc | computed | KLYS Wndw Air Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSWNDW:SUMY:SEVR` | calc | computed | KLYS Wndw Air Status Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSWNDWTEMP:SUMY:FRST` | calc | computed | KLYS Wndw Air Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSWNDWTEMP:SUMY:LTCH` | calc | computed | KLYS Wndw Air Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):KLYSWNDWTEMP:SUMY:SEVR` | calc | computed | KLYS Wndw Air Temp Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):SOLNBUCK:SUMY:FRST` | calc | computed | KLYS BUCK Solenoid Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):SOLNBUCK:SUMY:LTCH` | calc | computed | KLYS BUCK Solenoid Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):SOLNBUCK:SUMY:SEVR` | calc | computed | KLYS BUCK Solenoid Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):SOLNMAIN:SUMY:FRST` | calc | computed | KLYS MAIN Solenoid Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):SOLNMAIN:SUMY:LTCH` | calc | computed | KLYS MAIN Solenoid Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):SOLNMAIN:SUMY:SEVR` | calc | computed | KLYS MAIN Solenoid Stat Sum |  |  | rf_sumy_klys.db |
| `$(S):STN:AIM:ARCFRSTFANO` | fanout | processing | AIM Arc Latch Fanout |  |  | rf_sumy_arc_2CV.db |
| `$(S):STN:AIM:ARCFRSTFANO` | fanout | processing | AIM Arc Latch Fanout |  |  | rf_sumy_arc_4CV.db |
| `$(S):STN:AIM:ARCFRSTFANO` | fanout | processing | AIM Arc Latch Fanout |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):STN:AIM:ARCFRSTFANO2` | fanout | processing | AIM Arc Latch Fanout |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):STN:AIM:ARCLTCHFANO` | fanout | processing | AIM Arc Latch Fanout |  |  | rf_sumy_arc_2CV.db |
| `$(S):STN:AIM:ARCLTCHFANO` | fanout | processing | AIM Arc Latch Fanout |  |  | rf_sumy_arc_4CV.db |
| `$(S):STN:AIM:ARCLTCHFANO` | fanout | processing | AIM Arc Latch Fanout |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):STN:AIM:ARCLTCHFANO2` | fanout | processing | AIM Arc Latch Fanout |  |  | rf_sumy_arc_4CVAll.db |
| `$(S):STN:AIM:FRST` | mbbiDirect | readback | AIM State Latch Bits |  |  | rf_sumy_stn.db |
| `$(S):STN:AIM:FRSTFANO` | fanout | processing | AIM State Latch Fanout |  |  | rf_sumy_stn.db |
| `$(S):STN:AIM:LTCH` | mbbiDirect | readback | AIM State Latch Bits |  |  | rf_sumy_stn.db |
| `$(S):STN:AIM:LTCHFANO` | fanout | processing | AIM State Latch Fanout |  |  | rf_sumy_stn.db |
| `$(S):STN:AIM:STAT` | mbbiDirect | readback | AIM Status Bits |  |  | rf_sumy_stn.db |
| `$(S):STN:AIM:STATFANO` | fanout | processing | AIM Status Fanout |  |  | rf_sumy_stn.db |
| `$(S):STN:AIMARC:LTCH` | mbbiDirect | readback | AIMARC Arc Latch Bits |  |  | rf_sumy_stn.db |
| `$(S):STN:IQA1:IQFANO` | fanout | processing | IQA1 IQ Data Fanout |  |  | rf_sumy_2CV.db |
| `$(S):STN:IQA1:IQFANO` | fanout | processing | IQA1 IQ Data Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STN:IQA1:LTCHFANO` | fanout | processing | IQA1 Ampl Latch Fanout |  |  | rf_sumy_2CV.db |
| `$(S):STN:IQA1:LTCHFANO` | fanout | processing | IQA1 Ampl Latch Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STN:IQA2:IQFANO` | fanout | processing | IQA2 IQ Data Fanout |  |  | rf_sumy_2CV.db |
| `$(S):STN:IQA2:IQFANO` | fanout | processing | IQA2 IQ Data Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STN:IQA2:LTCHFANO` | fanout | processing | IQA2 Ampl Latch Fanout |  |  | rf_sumy_2CV.db |
| `$(S):STN:IQA2:LTCHFANO` | fanout | processing | IQA2 Ampl Latch Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STN:IQA3:IQFANO` | fanout | processing | IQA3 IQ Data Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STN:IQA3:LTCHFANO` | fanout | processing | IQA3 Ampl Latch Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STN:STATE:FANO` | fanout | processing | Station State Fanout |  |  | rf_sumy_2CV.db |
| `$(S):STN:STATE:FANO` | fanout | processing | Station State Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STN:SUMY:FRST` | calc | computed | Station Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STN:SUMY:LTCH` | calc | computed | Station Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STN:SUMY:MODU` | calc | computed | Station Status Sum |  |  | rf_sumy_stn_pep.db |
| `$(S):STN:SUMY:MODU` | calc | computed | Station Status Sum |  |  | rf_sumy_stn_spr.db |
| `$(S):STN:SUMY:SEVR` | calc | computed | Station Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNAB:SUMY:MODU` | calc | computed | Station AB Module Stat Sum |  |  | rf_sumy_stn.db |
| `$(S):STNARC:SUMY:FRST` | calc | computed | Station Arc Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNARC:SUMY:LTCH` | calc | computed | Station Arc Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNDCM:SUMY:MODU` | calc | computed | Station DCM Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNFLOW:SUMY:FRST` | calc | computed | Station Flow Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNFLOW:SUMY:LTCH` | calc | computed | Station Flow Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNFLOW:SUMY:MODU` | calc | computed | Station Flow Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNHCW1FLOW:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_circ.db |
| `$(S):STNHCW1FLOW:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_circ.db |
| `$(S):STNHCW2FLOW:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STNHCW2FLOW:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STNHCWTEMP:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_2CV.db |
| `$(S):STNHCWTEMP:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STNHCWTEMP:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_2CV.db |
| `$(S):STNHCWTEMP:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):STNIQA:SUMY:FRST` | calc | computed | Station IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNIQA:SUMY:LTCH` | calc | computed | Station IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNIQA:SUMY:MODU` | calc | computed | Station IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNIQA:SUMY:SEVR` | calc | computed | Station IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNMPS:SUMY:FRST` | calc | computed | Station MPS Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNMPS:SUMY:LTCH` | calc | computed | Station MPS Status Sum |  |  | rf_sumy_stn_pep.db |
| `$(S):STNMPS:SUMY:LTCH` | calc | computed | Station MPS Status Sum |  |  | rf_sumy_stn_spr.db |
| `$(S):STNMPS:SUMY:SEVR` | calc | computed | Station MPS Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNOFF:SUMY:STAT` | calc | computed | Station OFF Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNON:SUMY:STAT` | calc | computed | Station ON Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNPARK:SUMY:STAT` | calc | computed | Station PARK Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNPLC:SUMY:MODU` | calc | computed | Station PLC Module Stat Sum |  |  | rf_sumy_stn.db |
| `$(S):STNREF:POWER:FANO` | fanout | processing | Severity Fanout |  |  | rf_sumy_stn.db |
| `$(S):STNTEMP:SUMY:FRST` | calc | computed | Station Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNTEMP:SUMY:LTCH` | calc | computed | Station Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNTEMP:SUMY:MODU` | calc | computed | Station Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNTEMP:SUMY:SEVR` | calc | computed | Station Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNVACM:SUMY:FRST` | calc | computed | Station Vacuum Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNVACM:SUMY:LTCH` | calc | computed | Station Vacuum Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNVACM:SUMY:MODU` | calc | computed | Station Vacuum Status Sum |  |  | rf_sumy_stn.db |
| `$(S):STNVACM:SUMY:SEVR` | calc | computed | Station Vacuum Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WG02HCWTEMP:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):WG02HCWTEMP:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):WG:SUMY:FRST` | calc | computed | WG Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WG:SUMY:LTCH` | calc | computed | WG Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WG:SUMY:SEVR` | calc | computed | WG Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WGAIR:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_2CV.db |
| `$(S):WGAIR:FANO:FRST` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):WGAIR:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_2CV.db |
| `$(S):WGAIR:FANO:LTCH` | fanout | processing | Severity Fanout |  |  | rf_sumy_4CV.db |
| `$(S):WGFLOW:SUMY:FRST` | calc | computed | WG Flow Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WGFLOW:SUMY:LTCH` | calc | computed | WG Flow Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WGIQA:SUMY:FRST` | calc | computed | WG IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WGIQA:SUMY:LTCH` | calc | computed | WG IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WGIQA:SUMY:SEVR` | calc | computed | WG IQA Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WGTEMP:SUMY:FRST` | calc | computed | WG Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WGTEMP:SUMY:LTCH` | calc | computed | WG Temp Status Sum |  |  | rf_sumy_stn.db |
| `$(S):WGTEMP:SUMY:SEVR` | calc | computed | WG Temp Status Sum |  |  | rf_sumy_stn.db |

### 5.16. Beam (9 signals)

**Beam current and status signals for SPEAR ring.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(R):HVPSOIL:TEMPHIGH` | calcout | computed | HIGH Alarm Limit |  |  | rf_beam_spr.db |
| `$(R):HVPSOIL:TEMPHIHI` | calcout | computed | HIHI Alarm Limit |  |  | rf_beam_spr.db |
| `$(R):RF:CUTOFF` | ao | setpoint | SPEAR Beam Curr Limit | mA |  | rf_beam_spr.db |
| `$(R):STN:BEAM:CURR` | ai | derived | $(RING)ER Beam Current | mA |  | rf_beam.db |
| `$(R):STN:BEAM:CURR` | ai | derived | SPEAR Beam Current | mA |  | rf_beam_spr.db |
| `$(R):STN:BEAM:STAT` | bi | derived | $(RING)ER Beam Avail |  | 0=OFF 1=ON | rf_beam.db |
| `$(R):STN:BEAM:STAT` | bi | derived | SPEAR Beam Avail |  | 0=OFF 1=ON | rf_beam_spr.db |
| `$(R):STN:BEAM:STATINP` | calc | computed | SPEAR Beam Curr Compare |  |  | rf_beam_spr.db |
| `$(R):STN:DCCT:SUMY` | calc | computed | BIC or VMS DCCT |  |  | rf_beam.db |

### 5.17. Comb Filter (2 signals)

**Comb Filter module signals - PEP-II only, not active in SPEAR3.**

| PV Pattern | Type | Dir | Description | EGU | Limits (HIHI/HIGH/LOW/LOLO) | Source |
|------------|------|-----|-------------|-----|----------------------------|--------|
| `$(R):STNCF2:SUMY:MODU` | calc | computed | SEVR aggregator |  |  | cf2.db |
| `$(R):STNCFM$(M):SUMY:MODU` | calc | computed | CFM$(M) Status Summary |  |  | cfm.db |

## 6. Sequencer State Machines

The SNL (State Notation Language) sequencer programs run as real-time tasks on the IOC,
implementing closed-loop control and station state management.

### 6.1. `rf_calib.st` (57 PVs)

**Calibration sequencer - manages I/Q calibration of comb filter and RF processor coefficients for each cavity.**

| Variable | PV Pattern | Resolved Example |
|----------|------------|------------------|
| `calAbort` | `{STN}:STN:RFP:CALABORT` | `SRF1:STN:RFP:CALABORT` |
| `doCalib` | `{STN}:STN:RFP:DOODCALIB` | `SRF1:STN:RFP:DOODCALIB` |
| `calMsg` | `{STN}:STN:RFP:CALMSG` | `SRF1:STN:RFP:CALMSG` |
| `lod` | `{STN}:STN:RFP:MODU.LOD` | `SRF1:STN:RFP:MODU.LOD` |
| `dlod` | `{STN}:STN:RFP:MODU.DLOD` | `SRF1:STN:RFP:MODU.DLOD` |
| `rfEnb` | `{STN}:STN:RFP:RFENABLE` | `SRF1:STN:RFP:RFENABLE` |
| `dacs` | `{STN}:STN:RFP:DACS` | `SRF1:STN:RFP:DACS` |
| `dirLp` | `{STN}:STN:RFP:DIRECTLOOP` | `SRF1:STN:RFP:DIRECTLOOP` |
| `cmbLp` | `{STN}:STN:RFP:COMBLOOP` | `SRF1:STN:RFP:COMBLOOP` |
| `ripLp` | `{STN}:STN:RFP:RIPPLELOOP` | `SRF1:STN:RFP:RIPPLELOOP` |
| `ldComp` | `{STN}:STN:RFP:LEADCOMP` | `SRF1:STN:RFP:LEADCOMP` |
| `intComp` | `{STN}:STN:RFP:INTCOMP` | `SRF1:STN:RFP:INTCOMP` |
| `ssCont` | `{STN}:STN:RFP:SSCONT` | `SRF1:STN:RFP:SSCONT` |
| `rfpStt` | `{STN}:STN:RFP:STATE` | `SRF1:STN:RFP:STATE` |
| `cavSel` | `{STN}:STN:RFP:CAVSEL` | `SRF1:STN:RFP:CAVSEL` |
| `fbSig` | `{STN}:STN:RFP:FBSIG` | `SRF1:STN:RFP:FBSIG` |
| `amplSetpt` | `{STN}:STN:RFP:MODU.AMSP` | `SRF1:STN:RFP:MODU.AMSP` |
| `lodAmsp` | `{STN}:STN:RFP:MODU.LDAS` | `SRF1:STN:RFP:MODU.LDAS` |
| `lodDsp` | `{STN}:STN:RFP:MODU.LDSP` | `SRF1:STN:RFP:MODU.LDSP` |
| `runMode` | `{STN}:STN:RFP:RUNMODE` | `SRF1:STN:RFP:RUNMODE` |
| `gvffi` | `{STN}:STN:GVF:MODU.IREF` | `SRF1:STN:GVF:MODU.IREF` |
| `gvffq` | `{STN}:STN:GVF:MODU.QREF` | `SRF1:STN:GVF:MODU.QREF` |
| `gvffState` | `{STN}:STN:GVF:STATE` | `SRF1:STN:GVF:STATE` |
| `klysDriveI` | `{STN}:STN:IQA1:MODU.IDT4` | `SRF1:STN:IQA1:MODU.IDT4` |
| `klysDriveQ` | `{STN}:STN:IQA1:MODU.QDT4` | `SRF1:STN:IQA1:MODU.QDT4` |
| `RfDspFile` | `{STN}:STN:RFP:MODU.DSPE` | `SRF1:STN:RFP:MODU.DSPE` |
| `calStatus` | `{STN}:STN:RFP:CALSTATUS` | `SRF1:STN:RFP:CALSTATUS` |
| `calTime` | `{STN}:STN:RFP:CALTIME` | `SRF1:STN:RFP:CALTIME` |
| `timeOfDay` | `{STN}:TIMEOFDAY` | `SRF1:TIMEOFDAY` |
| `calStt` | `{STN}:STN:RFP:CALIBSTATUS` | `SRF1:STN:RFP:CALIBSTATUS` |
| `cavSel` | `{STN}:STN:RFP:CAVSEL` | `SRF1:STN:RFP:CAVSEL` |
| `doCalib` | `{STN}:STN:RFP:DOODCALIB` | `SRF1:STN:RFP:DOODCALIB` |
| `calStt` | `{STN}:STN:RFP:CALIBSTATUS` | `SRF1:STN:RFP:CALIBSTATUS` |
| `lod` | `{STN}:STN:RFP:MODU.LOD` | `SRF1:STN:RFP:MODU.LOD` |
| `dlod` | `{STN}:STN:RFP:MODU.DLOD` | `SRF1:STN:RFP:MODU.DLOD` |
| `dnio` | `{STN}:STN:RFP:MODU.DNIO` | `SRF1:STN:RFP:MODU.DNIO` |
| `dnqo` | `{STN}:STN:RFP:MODU.DNQO` | `SRF1:STN:RFP:MODU.DNQO` |
| `rfEnb` | `{STN}:STN:RFP:RFENABLE` | `SRF1:STN:RFP:RFENABLE` |
| `dacs` | `{STN}:STN:RFP:DACS` | `SRF1:STN:RFP:DACS` |
| `dirLp` | `{STN}:STN:RFP:DIRECTLOOP` | `SRF1:STN:RFP:DIRECTLOOP` |
| `cmbLp` | `{STN}:STN:RFP:COMBLOOP` | `SRF1:STN:RFP:COMBLOOP` |
| `ripLp` | `{STN}:STN:RFP:RIPPLELOOP` | `SRF1:STN:RFP:RIPPLELOOP` |
| `ldComp` | `{STN}:STN:RFP:LEADCOMP` | `SRF1:STN:RFP:LEADCOMP` |
| `intComp` | `{STN}:STN:RFP:INTCOMP` | `SRF1:STN:RFP:INTCOMP` |
| `ssCont` | `{STN}:STN:RFP:SSCONT` | `SRF1:STN:RFP:SSCONT` |
| `rfpStt` | `{STN}:STN:RFP:STATE` | `SRF1:STN:RFP:STATE` |
| `fbSig` | `{STN}:STN:RFP:FBSIG` | `SRF1:STN:RFP:FBSIG` |
| `cavSel` | `{STN}:STN:RFP:CAVSEL` | `SRF1:STN:RFP:CAVSEL` |
| `amplSetpt` | `{STN}:STN:RFP:MODU.AMSP` | `SRF1:STN:RFP:MODU.AMSP` |
| `lodAmsp` | `{STN}:STN:RFP:MODU.LDAS` | `SRF1:STN:RFP:MODU.LDAS` |
| `lodDsp` | `{STN}:STN:RFP:MODU.LDSP` | `SRF1:STN:RFP:MODU.LDSP` |
| `runMode` | `{STN}:STN:RFP:RUNMODE` | `SRF1:STN:RFP:RUNMODE` |
| `gvffi` | `{STN}:STN:GVF:MODU.IREF` | `SRF1:STN:GVF:MODU.IREF` |
| `gvffq` | `{STN}:STN:GVF:MODU.QREF` | `SRF1:STN:GVF:MODU.QREF` |
| `gvffState` | `{STN}:STN:GVF:STATE` | `SRF1:STN:GVF:STATE` |
| `klysDriveI` | `{STN}:STN:IQA1:MODU.IDT4` | `SRF1:STN:IQA1:MODU.IDT4` |
| `klysDriveQ` | `{STN}:STN:IQA1:MODU.QDT4` | `SRF1:STN:IQA1:MODU.QDT4` |

### 6.2. `rf_dac_loop_pvs.h` (33 PVs)

**DAC loop PV definitions - defines all PVs used by the DAC feedback loop (tune/on/GFF drive power ramping).**

| Variable | PV Pattern | Resolved Example |
|----------|------------|------------------|
| `station_state` | `{STN}:STN:STATE:RBCK` | `SRF1:STN:STATE:RBCK` |
| `loop_tune_ctrl` | `{STN}:STN:TUNE:CTRL` | `SRF1:STN:TUNE:CTRL` |
| `loop_on_ctrl` | `{STN}:STN:ON:CTRL` | `SRF1:STN:ON:CTRL` |
| `loop_ready` | `{STN}:STNDAC:LOOP:READY` | `SRF1:STNDAC:LOOP:READY` |
| `loop_delay` | `{STN}:HVPS:LOOP:DELAY` | `SRF1:HVPS:LOOP:DELAY` |
| `ripple_loop_ready` | `{STN}:STNRIPPLE:LOOP:READY` | `SRF1:STNRIPPLE:LOOP:READY` |
| `loop_status` | `{STN}:STNDAC:LOOP:STATUS` | `SRF1:STNDAC:LOOP:STATUS` |
| `loop_status_c` | `{STN}:STNDAC:LOOP:STRING` | `SRF1:STNDAC:LOOP:STRING` |
| `phase` | `{STN}:STN:PHASE:CALC` | `SRF1:STN:PHASE:CALC` |
| `ripple_loop_ampl` | `{STN}:STNRIPPLE:LOOP:AMPL` | `SRF1:STNRIPPLE:LOOP:AMPL` |
| `direct_loop_phase` | `{STN}:STNDIRECT:LOOP:PHASE` | `SRF1:STNDIRECT:LOOP:PHASE` |
| `comb_loop_phase` | `{STN}:STNCOMB:LOOP:PHASE` | `SRF1:STNCOMB:LOOP:PHASE` |
| `direct_loop_ampl` | `{STN}:STNDIRECT:LOOP:COUNTS` | `SRF1:STNDIRECT:LOOP:COUNTS` |
| `comb_loop_ampl` | `{STN}:STNCOMB:LOOP:COUNTS` | `SRF1:STNCOMB:LOOP:COUNTS` |
| `rf_processor_sevr` | `{STN}:STN:RFP:MODU.SEVR` | `SRF1:STN:RFP:MODU.SEVR` |
| `gvf_module_sevr` | `{STN}:STN:GVF:MODU.SEVR` | `SRF1:STN:GVF:MODU.SEVR` |
| `gv_error_stat` | `{STN}:STN:VOLT:ERR.STAT` | `SRF1:STN:VOLT:ERR.STAT` |
| `dp_error_stat` | `{STN}:KLYSDRIVFRWD:POWER:ERR.STAT` | `SRF1:KLYSDRIVFRWD:POWER:ERR.STAT` |
| `direct_loop` | `{STN}:STN:RFP:MODU.DLE` | `SRF1:STN:RFP:MODU.DLE` |
| `tune_counts` | `{STN}:STN:TUNE:IQ.A` | `SRF1:STN:TUNE:IQ.A` |
| `on_counts` | `{STN}:STN:ON:IQ.A` | `SRF1:STN:ON:IQ.A` |
| `gff_counts` | `{STN}:STN:GFF:IQ.A` | `SRF1:STN:GFF:IQ.A` |
| `tune_proc_counts` | `{STN}:STN:TUNE:IQ.PROC` | `SRF1:STN:TUNE:IQ.PROC` |
| `on_proc_counts` | `{STN}:STN:ON:IQ.PROC` | `SRF1:STN:ON:IQ.PROC` |
| `gff_proc_counts` | `{STN}:STN:GFF:IQ.PROC` | `SRF1:STN:GFF:IQ.PROC` |
| `rfp_dac_proc` | `{STN}:STNDIRECT:LOOP:IQ.PROC` | `SRF1:STNDIRECT:LOOP:IQ.PROC` |
| `ripple_loop_load` | `{STN}:STNRIPPLE:LOOP:LOAD.PROC` | `SRF1:STNRIPPLE:LOOP:LOAD.PROC` |
| `tune_delta_counts` | `{STN}:KLYSDRIVFRWD:DAC:DELTA` | `SRF1:KLYSDRIVFRWD:DAC:DELTA` |
| `on_rfp_delta_counts` | `{STN}:KLYSDRIVFRWD:ODAC:DELTA` | `SRF1:KLYSDRIVFRWD:ODAC:DELTA` |
| `on_gff_delta_counts` | `{STN}:KLYSDRIVFRWD:GFF:DELTA` | `SRF1:KLYSDRIVFRWD:GFF:DELTA` |
| `on_delta_counts` | `{STN}:STNVOLT:DAC:DELTA` | `SRF1:STNVOLT:DAC:DELTA` |
| `gff_delta_counts` | `{STN}:STNVOLT:GFF:DELTA` | `SRF1:STNVOLT:GFF:DELTA` |
| `hist_proc` | `{STN}:STN:VOLT:HIST.PROC` | `SRF1:STN:VOLT:HIST.PROC` |

### 6.3. `rf_hvps_loop_pvs.h` (29 PVs)

**HVPS voltage loop PV definitions - defines all PVs used by the HVPS voltage feedback loop.**

| Variable | PV Pattern | Resolved Example |
|----------|------------|------------------|
| `station_state` | `{STN}:STN:STATE:RBCK` | `SRF1:STN:STATE:RBCK` |
| `hvps_loop_ctrl` | `{STN}:HVPS:LOOP:CTRL` | `SRF1:HVPS:LOOP:CTRL` |
| `hvps_loop_state` | `{STN}:HVPS:LOOP:STATE` | `SRF1:HVPS:LOOP:STATE` |
| `hvps_loop_status` | `{STN}:HVPS:LOOP:STATUS` | `SRF1:HVPS:LOOP:STATUS` |
| `hvps_loop_delay` | `{STN}:HVPS:LOOP:DELAY` | `SRF1:HVPS:LOOP:DELAY` |
| `hvps_loop_status_c` | `{STN}:HVPS:LOOP:STRING` | `SRF1:HVPS:LOOP:STRING` |
| `hvps_loop_ready` | `{STN}:HVPS:LOOP:READY` | `SRF1:HVPS:LOOP:READY` |
| `rf_processor_severity` | `{STN}:STN:RFP:MODU.SEVR` | `SRF1:STN:RFP:MODU.SEVR` |
| `direct_loop` | `{STN}:STN:RFP:MODU.DLE` | `SRF1:STN:RFP:MODU.DLE` |
| `klystron_forward_power` | `{STN}:KLYSOUTFRWD:POWER` | `SRF1:KLYSOUTFRWD:POWER` |
| `max_klystron_forward_power` | `{STN}:KLYSOUTFRWD:POWER:MAX` | `SRF1:KLYSOUTFRWD:POWER:MAX` |
| `cavity_vacuum_sevr` | `{STN}:CAVVACM:SUMY:SEVR.SEVR` | `SRF1:CAVVACM:SUMY:SEVR.SEVR` |
| `cavity_vacuum_check` | `{STN}:CAVVACM:CHECK` | `SRF1:CAVVACM:CHECK` |
| `gap_voltage_sevr` | `{STN}:STN:VOLT.SEVR` | `SRF1:STN:VOLT.SEVR` |
| `gv_error_stat` | `{STN}:STN:VOLT:ERR.STAT` | `SRF1:STN:VOLT:ERR.STAT` |
| `dp_error_stat` | `{STN}:KLYSDRIVFRWD:POWER:ERR.STAT` | `SRF1:KLYSDRIVFRWD:POWER:ERR.STAT` |
| `gap_voltage_check` | `{STN}:CAVVOLT:CHECK` | `SRF1:CAVVOLT:CHECK` |
| `requested_hvps_voltage` | `{STN}:HVPS:VOLT:CTRL` | `SRF1:HVPS:VOLT:CTRL` |
| `readback_hvps_voltage` | `{STN}:HVPS:VOLT` | `SRF1:HVPS:VOLT` |
| `history_hvps_voltage` | `{STN}:HVPS:VOLT:LOOP` | `SRF1:HVPS:VOLT:LOOP` |
| `reset_hvps_voltage_history` | `{STN}:HVPS:LOOP:VOLTHIST.RES` | `SRF1:HVPS:LOOP:VOLTHIST.RES` |
| `allowed_hvps_voltage_diff` | `{STN}:HVPS:LOOP:VOLTDIFF` | `SRF1:HVPS:LOOP:VOLTDIFF` |
| `min_hvps_voltage` | `{STN}:HVPS:VOLT:MIN` | `SRF1:HVPS:VOLT:MIN` |
| `max_hvps_voltage` | `{STN}:HVPS:VOLT:CTRL.DRVH` | `SRF1:HVPS:VOLT:CTRL.DRVH` |
| `delta_proc_voltage_down` | `{STN}:HVPS:LOOP:VOLTDOWN` | `SRF1:HVPS:LOOP:VOLTDOWN` |
| `delta_proc_voltage_up` | `{STN}:HVPS:LOOP:VOLTUP` | `SRF1:HVPS:LOOP:VOLTUP` |
| `delta_on_voltage_severity` | `{STN}:KLYSDRIVFRWD:HVPS:DELTA.SEVR` | `SRF1:KLYSDRIVFRWD:HVPS:DELTA.SEVR` |
| `delta_on_voltage` | `{STN}:KLYSDRIVFRWD:HVPS:DELTA` | `SRF1:KLYSDRIVFRWD:HVPS:DELTA` |
| `delta_tune_voltage` | `{STN}:STNVOLT:HVPS:DELTA` | `SRF1:STNVOLT:HVPS:DELTA` |

### 6.4. `rf_msgs.st` (21 PVs)

**Message handler and TAXI monitoring - handles HVPS reset, filament, solenoid, contactor sequencing, GVF TAXI overflow recovery, LFB resync.**

| Variable | PV Pattern | Resolved Example |
|----------|------------|------------------|
| `hvps_reset` | `{STN}:HVPS:RESET:CTRL` | `SRF1:HVPS:RESET:CTRL` |
| `filament_timer` | `{STN}:FILAMENT:TIMEBYP:PLC` | `SRF1:FILAMENT:TIMEBYP:PLC` |
| `filament` | `{STN}:STN:AIM:FILAMENT` | `SRF1:STN:AIM:FILAMENT` |
| `station_sumy` | `{STN}:STNPARK:SUMY:STAT.SEVR` | `SRF1:STNPARK:SUMY:STAT.SEVR` |
| `filament_sumy` | `{STN}:FILAMENT:SUMY:PLC` | `SRF1:FILAMENT:SUMY:PLC` |
| `filament_status` | `{STN}:FILAMENT:ON:PLC` | `SRF1:FILAMENT:ON:PLC` |
| `station` | `{STN}:STN:AIM:SOLENOID` | `SRF1:STN:AIM:SOLENOID` |
| `hvps12kv` | `{STN}:HVPS12KV:VOLT:STAT` | `SRF1:HVPS12KV:VOLT:STAT` |
| `hvpsenerfast` | `{STN}:HVPSENERFAST:ON:STAT` | `SRF1:HVPSENERFAST:ON:STAT` |
| `hvpsenerslow` | `{STN}:HVPSENERSLOW:START:STAT` | `SRF1:HVPSENERSLOW:START:STAT` |
| `hvpssupplyon` | `{STN}:HVPSSUPPLY:ON:STAT` | `SRF1:HVPSSUPPLY:ON:STAT` |
| `hvpsscr1` | `{STN}:HVPSSCR1:ON:STAT` | `SRF1:HVPSSCR1:ON:STAT` |
| `hvpsscr2` | `{STN}:HVPSSCR2:ON:STAT` | `SRF1:HVPSSCR2:ON:STAT` |
| `contactor` | `{STN}:HVPSCONTACT:CLOSE:CTRL` | `SRF1:HVPSCONTACT:CLOSE:CTRL` |
| `station_state` | `{STN}:STN:STATE:CTRL` | `SRF1:STN:STATE:CTRL` |
| `gvfstat1` | `{STN}:STN:GVF:MODU.GST1` | `SRF1:STN:GVF:MODU.GST1` |
| `gvfstate` | `{STN}:STN:GVF:STATE` | `SRF1:STN:GVF:STATE` |
| `gvfwoof` | `{STN}:STN:GVF:LFBLOOP` | `SRF1:STN:GVF:LFBLOOP` |
| `taxichk` | `{STN}:STN:GVF:MODU.TMCK` | `SRF1:STN:GVF:MODU.TMCK` |
| `ring` | `{STN}:STN:RING:PLC` | `SRF1:STN:RING:PLC` |
| `ler_ring` | `{STN}:STN:RING:PLC` | `SRF1:STN:RING:PLC` |

### 6.5. `rf_states.st` (92 PVs)

**Main station state machine - controls station ON/OFF/RESET/PARK transitions, manages HVPS voltage ramp sequences, RF enable/disable.**

| Variable | PV Pattern | Resolved Example |
|----------|------------|------------------|
| `ctrl` | `{STN}:STN:STATE:CTRL` | `SRF1:STN:STATE:CTRL` |
| `rbck` | `{STN}:STN:STATE:RBCK` | `SRF1:STN:STATE:RBCK` |
| `stn_reset` | `{STN}:STN:RESET:CTRL` | `SRF1:STN:RESET:CTRL` |
| `reset_count` | `{STN}:STN:RESET:COUNTER` | `SRF1:STN:RESET:COUNTER` |
| `fault_noon` | `{STN}:STNON:SUMY:STAT.SEVR` | `SRF1:STNON:SUMY:STAT.SEVR` |
| `park_noon` | `{STN}:STNPARK:SUMY:STAT.SEVR` | `SRF1:STNPARK:SUMY:STAT.SEVR` |
| `panel_onoff` | `{STN}:STN:LOCAL:ON.SEVR` | `SRF1:STN:LOCAL:ON.SEVR` |
| `forced_fault` | `{STN}:STN:FORCED:LTCH` | `SRF1:STN:FORCED:LTCH` |
| `vacuum_err1` | `{STN}:STNVACM:SUMY:LTCH` | `SRF1:STNVACM:SUMY:LTCH` |
| `vacuum_err2` | `{STN}:STNVACM:SUMY:SEVR` | `SRF1:STNVACM:SUMY:SEVR` |
| `fault_stnoff` | `{STN}:STNOFF:SUMY:STAT.SEVR` | `SRF1:STNOFF:SUMY:STAT.SEVR` |
| `contactor_noon` | `{STN}:HVPSCONTACT:SUMY:STAT.SEVR` | `SRF1:HVPSCONTACT:SUMY:STAT.SEVR` |
| `fba` | `{STN}:STN:AIM:FRCBMABT` | `SRF1:STN:AIM:FRCBMABT` |
| `rba` | `{STN}:STN:AIM:MODU.RBA` | `SRF1:STN:AIM:MODU.RBA` |
| `rstf` | `{STN}:STN:AIM:MODU.RSTF` | `SRF1:STN:AIM:MODU.RSTF` |
| `state_string` | `{STN}:STN:STATE:STRING` | `SRF1:STN:STATE:STRING` |
| `hvpstrig` | `{STN}:HVPSSCR:ON:CTRL` | `SRF1:HVPSSCR:ON:CTRL` |
| `rfswitch` | `{STN}:STN:RFP:RFENABLE` | `SRF1:STN:RFP:RFENABLE` |
| `runmode` | `{STN}:STN:RFP:RUNMODE` | `SRF1:STN:RFP:RUNMODE` |
| `hvpsrdefault` | `{STN}:HVPS:VOLT:MIN` | `SRF1:HVPS:VOLT:MIN` |
| `hvpswdefault` | `{STN}:HVPS:VOLT:CTRL.VAL` | `SRF1:HVPS:VOLT:CTRL.VAL` |
| `aimon` | `{STN}:STN:AIM:MODU.HVPS` | `SRF1:STN:AIM:MODU.HVPS` |
| `dacfctl` | `{STN}:STN:RFP:STATE` | `SRF1:STN:RFP:STATE` |
| `daconoff` | `{STN}:STN:RFP:DACS` | `SRF1:STN:RFP:DACS` |
| `sscont` | `{STN}:STN:RFP:SSCONT` | `SRF1:STN:RFP:SSCONT` |
| `fmtype` | `{STN}:STN:FMTYPE:CTRL` | `SRF1:STN:FMTYPE:CTRL` |
| `clock_resync` | `{STN}:STN:CLK:MODU.RSYN` | `SRF1:STN:CLK:MODU.RSYN` |
| `cavtunehome` | `{STN}:CAVTUNR:LOOPON:RESET.PROC` | `SRF1:CAVTUNR:LOOPON:RESET.PROC` |
| `cavtunepark` | `{STN}:CAVTUNR:LOOPPARK:RESET.PROC` | `SRF1:CAVTUNR:LOOPPARK:RESET.PROC` |
| `directlpon` | `{STN}:STN:RFP:DIRECTLOOP` | `SRF1:STN:RFP:DIRECTLOOP` |
| `directlpoff` | `{STN}:STNDIRECT:LOOPOFF:SEQ.PROC` | `SRF1:STNDIRECT:LOOPOFF:SEQ.PROC` |
| `directlptransit` | `{STN}:STNDIRECT:LOOPTRNS:SEQ.PROC` | `SRF1:STNDIRECT:LOOPTRNS:SEQ.PROC` |
| `directlprestore` | `{STN}:STNDIRECT:LOOPREST:SEQ.PROC` | `SRF1:STNDIRECT:LOOPREST:SEQ.PROC` |
| `drivepwrrestore` | `{STN}:STNDRIV:PWRREST:SEQ.PROC` | `SRF1:STNDRIV:PWRREST:SEQ.PROC` |
| `volt_err_sevr` | `{STN}:STN:VOLT:ERR.SEVR` | `SRF1:STN:VOLT:ERR.SEVR` |
| `directlpcontrol` | `{STN}:STNDIRECT:LOOP:CTRL` | `SRF1:STNDIRECT:LOOP:CTRL` |
| `directlpgainoff` | `{STN}:STNDIRECT:LOOP:COUNTS.C` | `SRF1:STNDIRECT:LOOP:COUNTS.C` |
| `directlpgaindelta` | `{STN}:STNDIRECT:LOOP:COUNTS.H` | `SRF1:STNDIRECT:LOOP:COUNTS.H` |
| `volt_settle_time` | `{STN}:STN:VOLT:SETTLE` | `SRF1:STN:VOLT:SETTLE` |
| `ramp_settle_time` | `{STN}:STN:RAMP:SETTLE` | `SRF1:STN:RAMP:SETTLE` |
| `leadcomp` | `{STN}:STN:RFP:LEADCOMP` | `SRF1:STN:RFP:LEADCOMP` |
| `leadcompcontrol` | `{STN}:STNDIRECT:LEADCOMP:CTRL` | `SRF1:STNDIRECT:LEADCOMP:CTRL` |
| `intcomp` | `{STN}:STN:RFP:INTCOMP` | `SRF1:STN:RFP:INTCOMP` |
| `intcompcontrol` | `{STN}:STNDIRECT:INTCOMP:CTRL` | `SRF1:STNDIRECT:INTCOMP:CTRL` |
| `comblponoff` | `{STN}:STN:RFP:COMBLOOP` | `SRF1:STN:RFP:COMBLOOP` |
| `comblptransit` | `{STN}:STNCOMB:LOOPTRNS:SEQ.PROC` | `SRF1:STNCOMB:LOOPTRNS:SEQ.PROC` |
| `comblpreset` | `{STN}:STNCOMB:LOOP:RESET.PROC` | `SRF1:STNCOMB:LOOP:RESET.PROC` |
| `comblpcontrol` | `{STN}:STNCOMB:LOOP:CTRL` | `SRF1:STNCOMB:LOOP:CTRL` |
| `comblpgainoff` | `{STN}:STNCOMB:LOOP:COUNTS.C` | `SRF1:STNCOMB:LOOP:COUNTS.C` |
| `comblpgaindelta` | `{STN}:STNCOMB:LOOP:COUNTS.H` | `SRF1:STNCOMB:LOOP:COUNTS.H` |
| `gfflp` | `{STN}:STN:GVF:GFFLOOP` | `SRF1:STN:GVF:GFFLOOP` |
| `gfflpcontrol` | `{STN}:STN:GFF:CTRL` | `SRF1:STN:GFF:CTRL` |
| `lfblp` | `{STN}:STN:GVF:LFBLOOP` | `SRF1:STN:GVF:LFBLOOP` |
| `lfblpcontrol` | `{STN}:STN:LFB:CTRL` | `SRF1:STN:LFB:CTRL` |
| `ripplelpreset` | `{STN}:STNRIPPLE:LOOP:AMPL.J` | `SRF1:STNRIPPLE:LOOP:AMPL.J` |
| `hvpsvoltfaston` | `{STN}:HVPS:VOLT:FASTON` | `SRF1:HVPS:VOLT:FASTON` |
| `fastoncontrol` | `{STN}:STN:FASTON:CTRL` | `SRF1:STN:FASTON:CTRL` |
| `gvf_module_sevr` | `{STN}:STN:GVF:MODU.SEVR` | `SRF1:STN:GVF:MODU.SEVR` |
| `zeroiqtune` | `{STN}:STN:TUNE:IQ.A` | `SRF1:STN:TUNE:IQ.A` |
| `setiqtune` | `{STN}:STN:TUNE:RESET.PROC` | `SRF1:STN:TUNE:RESET.PROC` |
| `zeroiqoper` | `{STN}:STN:ON:IQ.A` | `SRF1:STN:ON:IQ.A` |
| `setiqoper` | `{STN}:STN:ON:RESET.PROC` | `SRF1:STN:ON:RESET.PROC` |
| `setiqoperseln` | `{STN}:STN:ON:RESET.SELN` | `SRF1:STN:ON:RESET.SELN` |
| `zeroiqgff` | `{STN}:STN:GFF:IQ.A` | `SRF1:STN:GFF:IQ.A` |
| `setiqgff` | `{STN}:STN:GFF:RESET.PROC` | `SRF1:STN:GFF:RESET.PROC` |
| `setiqgffseln` | `{STN}:STN:GFF:RESET.SELN` | `SRF1:STN:GFF:RESET.SELN` |
| `ri400` | `{STN}:STN:FM400HZ:IFILE` | `SRF1:STN:FM400HZ:IFILE` |
| `rq400` | `{STN}:STN:FM400HZ:QFILE` | `SRF1:STN:FM400HZ:QFILE` |
| `ri1000` | `{STN}:STN:FM1000HZ:IFILE` | `SRF1:STN:FM1000HZ:IFILE` |
| `rq1000` | `{STN}:STN:FM1000HZ:QFILE` | `SRF1:STN:FM1000HZ:QFILE` |
| `wdirf` | `{STN}:STN:RFP:MODU.DIRF` | `SRF1:STN:RFP:MODU.DIRF` |
| `wdqrf` | `{STN}:STN:RFP:MODU.DQRF` | `SRF1:STN:RFP:MODU.DQRF` |
| `ldir` | `{STN}:STN:RFP:MODU.LDIR` | `SRF1:STN:RFP:MODU.LDIR` |
| `ldqr` | `{STN}:STN:RFP:MODU.LDQR` | `SRF1:STN:RFP:MODU.LDQR` |
| `dist` | `{STN}:STN:RFP:MODU.DIST` | `SRF1:STN:RFP:MODU.DIST` |
| `dqst` | `{STN}:STN:RFP:MODU.DQST` | `SRF1:STN:RFP:MODU.DQST` |
| `tickle` | `{STN}:STN:TICKLE:CTRL` | `SRF1:STN:TICKLE:CTRL` |
| `tifile` | `{STN}:STN:TICKLE:IFILE` | `SRF1:STN:TICKLE:IFILE` |
| `tqfile` | `{STN}:STN:TICKLE:QFILE` | `SRF1:STN:TICKLE:QFILE` |
| `faultnum` | `{STN}:STN:FAULT:NUM` | `SRF1:STN:FAULT:NUM` |
| `faultanum` | `{STN}:STN:FAULT:ANUM` | `SRF1:STN:FAULT:ANUM` |
| `faultctrl` | `{STN}:STN:FAULT:CTRL` | `SRF1:STN:FAULT:CTRL` |
| `faultfsize` | `{STN}:STN:FAULT:FSIZE` | `SRF1:STN:FAULT:FSIZE` |
| `cf2histrec` | `{STN}:STN:CF2:HISTREC` | `SRF1:STN:CF2:HISTREC` |
| `cf2diagrec` | `{STN}:STN:CF2:DIAGREC` | `SRF1:STN:CF2:DIAGREC` |
| `cf2state` | `{STN}:STN:CF2:STATE` | `SRF1:STN:CF2:STATE` |
| `cfm1state` | `{STN}:STN:CFM1:STATE` | `SRF1:STN:CFM1:STATE` |
| `cfm2state` | `{STN}:STN:CFM2:STATE` | `SRF1:STN:CFM2:STATE` |
| `gvfstate` | `{STN}:STN:GVF:STATE` | `SRF1:STN:GVF:STATE` |
| `faultnum` | `{STN}:STN:FAULT:NUM` | `SRF1:STN:FAULT:NUM` |
| `cfm1state` | `{STN}:STN:CFM1:STATE` | `SRF1:STN:CFM1:STATE` |
| `cfm2state` | `{STN}:STN:CFM2:STATE` | `SRF1:STN:CFM2:STATE` |

### 6.6. `rf_tuner_loop_pvs.h` (29 PVs)

**Tuner loop PV definitions - defines all PVs used by the cavity tuner position feedback loop.**

| Variable | PV Pattern | Resolved Example |
|----------|------------|------------------|
| `loop_ctrl` | `{STN}:CAVTUNR:LOOP:CTRL` | `SRF1:CAVTUNR:LOOP:CTRL` |
| `loop_reset` | `{STN}:CAV{CAV}TUNR:LOOP:RESET` | `SRF1:CAV1TUNR:LOOP:RESET` |
| `loop_home` | `{STN}:CAV{CAV}TUNR:LOOP:HOME` | `SRF1:CAV1TUNR:LOOP:HOME` |
| `loop_reset_on` | `{STN}:CAVTUNR:LOOPON:RESET` | `SRF1:CAVTUNR:LOOPON:RESET` |
| `loop_home_on` | `{STN}:CAVTUNR:LOOPON:HOME` | `SRF1:CAVTUNR:LOOPON:HOME` |
| `loop_reset_park` | `{STN}:CAVTUNR:LOOPPARK:RESET` | `SRF1:CAVTUNR:LOOPPARK:RESET` |
| `loop_home_park` | `{STN}:CAVTUNR:LOOPPARK:HOME` | `SRF1:CAVTUNR:LOOPPARK:HOME` |
| `loop_ready` | `{STN}:CAVTUNR:LOOP:READY` | `SRF1:CAVTUNR:LOOP:READY` |
| `meas_ready` | `{STN}:CAV{CAV}TUNR:LOOPMEAS:READY` | `SRF1:CAV1TUNR:LOOPMEAS:READY` |
| `loop_state` | `{STN}:CAV{CAV}TUNR:LOOP:STATE` | `SRF1:CAV1TUNR:LOOP:STATE` |
| `loop_status` | `{STN}:CAV{CAV}TUNR:LOOP:STATUS` | `SRF1:CAV1TUNR:LOOP:STATUS` |
| `loop_status_string_c` | `{STN}:CAV{CAV}TUNR:LOOP:STRING` | `SRF1:CAV1TUNR:LOOP:STRING` |
| `station_state` | `{STN}:STN:STATE:RBCK` | `SRF1:STN:STATE:RBCK` |
| `posn_ctrl` | `{STN}:CAV{CAV}TUNR:POSN:CTRL` | `SRF1:CAV1TUNR:POSN:CTRL` |
| `phase_offset_proc` | `{STN}:CAV{CAV}LOAD:ANGLE:UNADOFFS.PROC` | `SRF1:CAV1LOAD:ANGLE:UNADOFFS.PROC` |
| `posn` | `{STN}:CAV{CAV}TUNR:POSN` | `SRF1:CAV1TUNR:POSN` |
| `posn_mdel` | `{STN}:CAV{CAV}TUNR:POSN.MDEL` | `SRF1:CAV1TUNR:POSN.MDEL` |
| `posn_new` | `{STN}:CAV{CAV}TUNR:POSN:LOOP` | `SRF1:CAV1TUNR:POSN:LOOP` |
| `posn_delta` | `{STN}:CAV{CAV}TUNR:POSN:DELTA` | `SRF1:CAV1TUNR:POSN:DELTA` |
| `posn_park_home` | `{STN}:CAV{CAV}TUNR:POSN:PARKHOME` | `SRF1:CAV1TUNR:POSN:PARKHOME` |
| `posn_on_home` | `{STN}:CAV{CAV}TUNR:POSN:ONHOME` | `SRF1:CAV1TUNR:POSN:ONHOME` |
| `sm_posn` | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.RBV` | `SRF1:CAV1TUNR:STEP:MOTOR.RBV` |
| `sm_drvh` | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.DRVH` | `SRF1:CAV1TUNR:STEP:MOTOR.DRVH` |
| `sm_drvl` | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.DRVL` | `SRF1:CAV1TUNR:STEP:MOTOR.DRVL` |
| `sm_dmov` | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.DMOV` | `SRF1:CAV1TUNR:STEP:MOTOR.DMOV` |
| `sm_rdbd` | `{STN}:CAV{CAV}TUNR:STEP:MOTOR.RDBD` | `SRF1:CAV1TUNR:STEP:MOTOR.RDBD` |
| `klys_frwd_pwr` | `{STN}:KLYSOUTFRWD:POWER` | `SRF1:KLYSOUTFRWD:POWER` |
| `klys_frwd_pwr_min` | `{STN}:KLYSOUTFRWD:POWER:MIN` | `SRF1:KLYSOUTFRWD:POWER:MIN` |
| `load_angle_sevr` | `{STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR` | `SRF1:CAV1LOAD:ANGLE:ERR.SEVR` |

## 7. VXI Crate Slot Map

13-slot VXI crate (Elma) at location B132-101-11-24:

| Slot | Module | EPICS Record Type | Description |
|------|--------|-------------------|-------------|
| 0 | KSC V152 CPU | — | IOC processor (B132-IOCRF) |
| 1 | AB Scanner | abDcm | Allen-Bradley PLC scanner interface |
| 2 | Clock | p2RfClk | RF timing and reference generation |
| 3 | (empty) | p2RfGvf (software only) | GVF hardware not installed; software active for TAXI monitoring |
| 4 | RF Processing | p2RfRfp | Core RF signal processor with DSP |
| 5 | MPS Shutoff | — | Machine Protection System interface |
| 6 | Link Passthru | — | Serial link pass-through |
| 7 | IQA1 | p2RfIqa | I/Q Amplitude Detector — forward signals |
| 8 | (empty) | — | — |
| 9 | IQA2 | p2RfIqa | I/Q Amplitude Detector — reflected signals |
| 10 | (empty) | — | — |
| 11 | IQA3 | p2RfIqa | I/Q Amplitude Detector — cavity probe signals |
| 12 | Arc Interlock | p2RfAim | Arc Interlock Module — fast fault detection |

## 8. Station Configuration

### 8.1 IOC Startup (st.cmd)

The IOC loads the following database files via `srf1.substitutions`:

```
file rf_ab_4CV.db           {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_analog_All.db       {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_analog_4CV.db       {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_beam_spear.db       {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1, PS=RF-SOLN-MAIN}}
file rf_dac.db              {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_digital_All.db      {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_digital_4CV.db      {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_iqa_All.db          {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_iqa_4CV.db          {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_stn_All.db          {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1, PS=RF-SOLN-MAIN}}
file rf_stn_4CVAll.db       {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1, PS=RF-SOLN-MAIN}}
file rf_temp_All.db         {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_temp_4CV.db         {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_vxi_modules_All.db  {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_vxi_modules_4CV.db  {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
```

### 8.2 Sequencer Programs Loaded

| Program | Macro | Description |
|---------|-------|-------------|
| `rf_states` | `STN=SRF1` | Station state machine (ON/OFF/RESET/PARK) |
| `rf_msgs` | `STN=SRF1` | Message handler and TAXI monitoring |
| `rf_calib` | `STN=SRF1` | I/Q calibration sequencer |
| `rf_dac_loop` | `STN=SRF1` | DAC feedback loop (tune/on/GFF drive) |
| `rf_hvps_loop` | `STN=SRF1` | HVPS voltage feedback loop |
| `rf_tuner_loop` (×4) | `STN=SRF1,CAV=1..4` | Per-cavity tuner position loop |

### 8.3 Allen-Bradley Configuration

Three AB adapters communicate with the SLC/PLC:

| Adapter | Component | Cards | Function |
|---------|-----------|-------|----------|
| 1 | HVPSDCM | 0-14 | HVPS PLC analog/digital I/O |
| 2 | CAVTUNR | 0-6 | Cavity tuner position and control |
| 3 | STNDCM | 0 | Station-level PLC data |

---

## Appendix: Signal Direction Legend

| Direction | Meaning |
|-----------|---------|
| `readback` | Hardware measurement read from VXI/PLC |
| `derived` | Software-derived from other signals (soft input) |
| `setpoint` | Operator-settable control value (soft output) |
| `output` | Hardware output written to VXI/PLC |
| `computed` | Calculation record deriving values from inputs |
| `processing` | Fanout/sequence record triggering other records |
| `history` | Circular buffer compress record for trend data |
| `state` | State variable record |

---

*This document was auto-generated from source code analysis of `spear-rf-code-legacy/rfApp/`.*
*Companion machine-readable file: `SIGNAL_CATALOG.json`*