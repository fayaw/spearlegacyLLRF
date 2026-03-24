# SPEAR3 RF System — Operational Data Catalog

**Document ID**: Doc D  
**Version**: 1.0  
**Date**: March 24, 2026  
**Status**: DRAFT — For Engineering Review  
**Location**: `Designs/D_OPERATIONAL_DATA_CATALOG.md`  
**Author**: Faya Wang, with AI-assisted analysis  
**Architecture Reference**: `Designs/DOCUMENTATION_ARCHITECTURE_PROPOSAL.md` v6.2, §8.3

---

## Revision History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | 2026-03-24 | Initial draft: catalogs all operational data assets found in the spearlegacyLLRF repository including 50 EPICS database files (889 PV records), 18 xlsx data files, HVPS simulation configuration, and SNL source code; includes canonical parameter table with cross-document consistency analysis |

---

## Table of Contents

1. [Introduction and Purpose](#1-introduction-and-purpose)
2. [EPICS Process Variable Catalog](#2-epics-process-variable-catalog)
3. [Calibration Data](#3-calibration-data)
4. [HVPS Operational and Configuration Data](#4-hvps-operational-and-configuration-data)
5. [Reliability and Maintenance Records](#5-reliability-and-maintenance-records)
6. [Test Campaign Data](#6-test-campaign-data)
7. [System Configuration Parameters](#7-system-configuration-parameters)
8. [Safety and Lockout Procedures](#8-safety-and-lockout-procedures)
9. [SNL Source Code Inventory](#9-snl-source-code-inventory)
10. [Canonical Parameter Table](#10-canonical-parameter-table)
11. [Data Still Needed](#11-data-still-needed)
- [Appendix A — Complete EPICS Database File Catalog](#appendix-a--complete-epics-database-file-catalog)
- [Appendix B — File Manifest](#appendix-b--file-manifest)
- [Appendix C — Cross-Document Consistency Issues](#appendix-c--cross-document-consistency-issues)

---

## Reference Conventions

This document follows the conventions established in the Documentation Architecture Proposal (v6.2, §2):

- **[Rn]** — numbered reference to original source documents (see Doc P Appendix B or Doc L Appendix A)
- **[Dn]** — numbered reference internal to this document for data sources
- File paths are relative to the `spearlegacyLLRF` repository root
- EPICS PV naming: `$(STN):$(SUB):$(SIG)` macro expansion convention

---

## 1. Introduction and Purpose

### 1.1 Scope

This document is the **single index to all operational data assets** in the SPEAR3 RF system codebase. It catalogs:

- **EPICS process variables** — 889 PV records across 50 database files defining all control, monitoring, and diagnostic signals
- **Calibration data** — 6 xlsx files containing RF signal chain measurements, coupler characterizations, and DAC linearity data
- **HVPS operational data** — PLC register maps, regulator test point measurements, and monitor connection definitions
- **Reliability records** — 20 years of HVPS event logs (2005–2025) for both HVPS1 and HVPS2
- **Maintenance test data** — Multi-campaign phase tank SCR testing, crowbar stack testing, and individual SCR characterization
- **Simulation configuration** — Complete Python dataclass parameter set for HVPS system modeling
- **Safety procedures** — Lockout permit procedures for HVPS complex operations
- **SNL source code** — 6 state machine programs + 12 headers controlling the legacy RF system

### 1.2 What This Document Does NOT Contain

- **Live EPICS archiver data** — requires access to the running SPEAR3 control system (see §11)
- **Current operational setpoints** — alarm limits, tuning deadbands, trip thresholds (see §11)
- **Waveform data** — time-series captures from LLRF9 or legacy system diagnostics
- **Raw schematic data** — schematics are cataloged in Doc L §21 Source Index

### 1.3 How to Use This Document

| If you need... | Go to... |
|----------------|----------|
| A specific EPICS PV name or record type | §2 (summary) or Appendix A (complete catalog) |
| RF signal chain calibration data | §3 |
| HVPS PLC register definitions or measurement data | §4 |
| Failure history or maintenance records | §5 |
| Phase tank or crowbar SCR test results | §6 |
| HVPS subsystem parameters for simulation or design | §7 |
| Safety procedures for HVPS work | §8 |
| SNL state machine code structure | §9 |
| The authoritative value for any RF system parameter | §10 (Canonical Parameter Table) |
| What data is missing and needs to be captured | §11 |

### 1.4 Cross-References to Other Documents

| Document | Relationship to Doc D |
|----------|-----------------------|
| Doc P (`P_RF_PHYSICS_AND_PLANT.md`) | Provides physics parameters used in §10; Doc D validates against Doc P values |
| Doc L (`L_LEGACY_SYSTEM_ARCHITECTURE.md`) | Describes the systems that generate the data cataloged here; Doc D provides the measured baselines |
| Doc 0 (`0_SYSTEM_DESIGN_REPORT.md`) | Defines the upgrade requirements; Doc D provides the legacy baseline data that constrains the design |
| Architecture Proposal | Defines Doc D's place in the documentation hierarchy (Tier 2, §8.3) |


---

## 2. EPICS Process Variable Catalog

### 2.1 Overview

The legacy SPEAR3 RF control system defines **889 EPICS PV records** across **50 database files** in `spear-rf-code-legacy/rfApp/Db/`. These files use RCS version control (`.db,v` extension). The PV records implement the complete control, monitoring, diagnostic, and interlock functionality for the RF station.

> **Note**: These are the PV *definitions*. Actual runtime values require access to the running EPICS IOC. The EPICS PV names use macro substitution — the `$(STN)` macro expands to the station identifier (e.g., `RF1`) at IOC startup.

### 2.2 Summary by Subsystem

#### LLRF Core Control

| DB File | Records | Record Types | Function |
|---------|---------|-------------|----------|
| `rfp.db` | 35 | bo:22, mbbiDirect:2, mbbo:6, mbboDirect:1, p2RfRfp:1, stringin:3 | RF Processor (RFP) module control — heart of the fast feedback system |
| `rf_fbck.db` | 48 | ao:5, bo:10, calc:2, event:2, fanout:1, mbbo:1, sel:2, seq:17, stringout:1, sub:7 | Feedback loop control — 17 sequence records managing all feedback modes |
| `rfp_dacs.db` | 28 | seq:14, sub:14 | RFP DAC outputs — 14 DAC channels with set/readback pairs |
| `rf_rfp_fourdacs.db` | 2 | seq:1, sub:1 | Four-DAC simultaneous write for coordinated RFP updates |
| `rf_rfp_twodacs.db` | 2 | seq:1, sub:1 | Two-DAC simultaneous write |
| `cf2.db` | 39 | bi:3, calc:5, fanout:2, mbbiDirect:2, mbbo:18, mbboDirect:1, p2RfCf2:1, seq:5, stringin:1, timestamp:1 | Comb Filter module (PEP-II heritage, 18 mode select outputs) |
| `cfm.db` | 12 | ai:1, bi:1, bo:3, calc:1, mbbiDirect:1, mbbo:3, mbboDirect:1, p2RfCfm:1 | Comb Filter Monitor |
| `gvf.db` | 11 | bo:5, mbbiDirect:2, mbbo:2, mbboDirect:1, p2RfGvf:1 | Gap Voltage Feedback module |
| `clk.db` | 12 | bo:6, mbbiDirect:1, mbbo:3, mbboDirect:1, p2RfClk:1 | Clock module control |

#### IQ Amplitude/Phase Measurement

| DB File | Records | Record Types | Function |
|---------|---------|-------------|----------|
| `iqa.db` | 7 | bo:2, mbbiDirect:3, mbboDirect:1, p2RfIqa:1 | IQA module base control |
| `rf_iqa.db` | 6 | ao:2, bi:2, sub:2 | IQA readback and scaling |
| `rf_iqa_module.db` | 8 | calc:1, mbbiDirect:5, seq:1, sub:1 | IQA module status registers |
| `rf_iqa_scale.db` | 9 | calc:4, seq:3, sub:2 | IQA calibration and scaling factors |
| `iqCvt.db` | 5 | sub:5 | I/Q to amplitude/phase conversion subroutines |
| `iqGet.db` | 2 | bi:1, sub:1 | I/Q data acquisition trigger |

#### HVPS Control

| DB File | Records | Record Types | Function |
|---------|---------|-------------|----------|
| `rf_hvps.db` | 31 | ai:6, ao:10, bo:4, calc:2, compress:1, event:1, mbbi:1, mbbo:3, seq:2, stringout:1 | HVPS supervisory — voltage setpoint, readbacks, enable/disable, mode selection |
| `rf_digital_hvps.db` | 1 | bi:1 | HVPS digital status bit |

#### Cavity and Tuner Control

| DB File | Records | Record Types | Function |
|---------|---------|-------------|----------|
| `rf_cav.db` | 41 | ao:11, calc:3, compress:6, event:3, fanout:1, mbbo:2, seq:2, steppermotor:1, stringout:1, sub:11 | Cavity control — includes 1 stepper motor record for tuner, 6 compression records for trending |
| `rf_stn_cav.db` | 81 | ao:24, bo:4, calc:9, compress:3, event:10, sel:8, seq:8, sub:15 | Per-cavity station parameters — 4 instances via CAV macro |

#### Klystron Monitoring

| DB File | Records | Record Types | Function |
|---------|---------|-------------|----------|
| `rf_klys.db` | 30 | ai:3, ao:11, calc:1, compress:2, sel:3, sub:10 | Klystron forward/reflected power, beam current, operating parameters |

#### Interlock and Arc Detection

| DB File | Records | Record Types | Function |
|---------|---------|-------------|----------|
| `aim.db` | 74 | ai:27, bo:20, fanout:3, mbbiDirect:18, mbboDirect:3, p2RfAim:3 | Arc Interlock Module — largest single DB file; 27 analog inputs, 18 multi-bit binary inputs |
| `rf_interlock.db` | 2 | bi:2 | Top-level interlock status |
| `rf_interlock_arc.db` | 10 | bi:5, calc:5 | Arc detection logic — 5 binary inputs with 5 calculations |
| `rf_interlock_vxi.db` | 4 | bi:4 | VXI chassis interlock status |

#### Station Management

| DB File | Records | Record Types | Function |
|---------|---------|-------------|----------|
| `rf_stn.db` | 61 | abDcm:1, ao:6, bi:8, bo:4, calc:3, fanout:4, longout:1, mbbi:3, mbbo:2, seq:4, state:1, stringout:22, sub:2 | Station-level control — 22 string outputs for state/status displays, 1 state record |
| `rf_beam.db` | 3 | ai:1, bi:1, calc:1 | Beam current readback and status |
| `rf_beam_spr.db` | 6 | ai:1, ao:1, bi:1, calc:1, calcout:2 | SPEAR-specific beam parameter calculations |
| `rf_analog.db` | 9 | ai:3, bi:4, calc:2 | Analog input channels |
| `rf_analog_log.db` | 12 | ai:3, bi:4, calc:4, sub:1 | Analog input logging with calculations |
| `rf_temp.db` | 4 | ai:2, bi:2 | Temperature monitoring (2 channels) |

#### Signal Summation and Display

| DB File | Records | Record Types | Function |
|---------|---------|-------------|----------|
| `rf_sumy_stn.db` | 77 | calc:69, fanout:4, mbbiDirect:4 | Station summary — 69 calculation records aggregating all subsystem signals |
| `rf_sumy_klys.db` | 63 | calc:61, fanout:2 | Klystron summary display — 61 calculation records |
| `rf_sumy_cav.db` | 32 | calc:28, fanout:2, sel:2 | Cavity summary |
| `rf_sumy_hvps.db` | 11 | calc:10, fanout:1 | HVPS summary |
| `rf_sumy_circ.db` | 17 | calc:13, fanout:4 | Circulator summary |
| `rf_sumy_wg.db` | 9 | calc:9 | Waveguide summary |
| `rf_sumy_4CV.db` | 26 | calc:2, fanout:22, seq:1, sub:1 | 4-cavity summary/fanout |
| `rf_sumy_2CV.db` | 22 | calc:4, fanout:16, seq:1, sub:1 | 2-cavity summary/fanout |
| `rf_sumy_arc_4CV.db` | 4 | calc:2, fanout:2 | 4-cavity arc summary |
| `rf_sumy_arc_2CV.db` | 6 | calc:4, fanout:2 | 2-cavity arc summary |
| `rf_sumy_arc_4CVAll.db` | 12 | calc:8, fanout:4 | All 4-cavity arc summary |
| `rf_sumy_stn_pep.db` | 4 | calc:4 | PEP-II-specific station summary |
| `rf_sumy_stn_spr.db` | 4 | calc:4 | SPEAR-specific station summary |
| `rf_sumy_plc.db` | 1 | bi:1 | PLC communication status |

#### Allen-Bradley Communication

| DB File | Records | Record Types | Function |
|---------|---------|-------------|----------|
| `ab_adapter.db` | 1 | mbbi:1 | AB adapter module status |
| `ab_adapter_card.db` | 1 | mbbi:1 | AB adapter card status |
| `ab_dcm_table.db` | 1 | mbbi:1 | AB DCM communication table status |
| `rf_ab_module.db` | 1 | bi:1 | AB module online status |
| `rf_digital_modu.db` | 1 | bi:1 | Digital modulator status |
| `rf_digital_plc.db` | 1 | bi:1 | PLC digital communication status |

### 2.3 Record Type Distribution (All 889 Records)

| Record Type | Count | Description |
|-------------|-------|-------------|
| calc | 253 | Calculation records — signal processing, unit conversion, alarm logic |
| fanout | 72 | Fanout records — distributing updates to multiple downstream records |
| bo | 58 | Binary output — on/off control commands |
| ao | 51 | Analog output — setpoints, DAC values |
| ai | 44 | Analog input — readbacks from hardware |
| seq | 42 | Sequence records — multi-step operations, state transitions |
| sub | 41 | Subroutine records — custom C code callbacks |
| mbbiDirect | 33 | Multi-bit binary input (direct) — bit-level status registers |
| mbbo | 30 | Multi-bit binary output — mode selection, configuration |
| bi | 27 | Binary input — status bits, interlocks |
| stringout | 24 | String output — state names, status messages |
| sel | 13 | Selection records — input multiplexing |
| compress | 12 | Compression records — data trending/archiving |
| event | 11 | Event records — triggers for synchronization |
| mbboDirect | 8 | Multi-bit binary output (direct) — bit-level control registers |
| p2RfXxx | 8 | Custom PEP-II RF device support records (Aim, Cf2, Cfm, Clk, Gvf, Iqa, Rfp) |
| mbbi | 6 | Multi-bit binary input — enumerated status |
| stringin | 4 | String input — status readbacks |
| calcout | 2 | Calculation with output — conditional processing |
| longout | 1 | Long integer output |
| timestamp | 1 | Timestamp record |
| state | 1 | State record — station operating state |
| abDcm | 1 | Allen-Bradley DCM communication record |
| steppermotor | 1 | Stepper motor record — cavity tuner |

> **Total: 889 records across 50 database files**


---

## 3. Calibration Data

### 3.1 Overview

Six calibration data files are stored in `llrf/calibrations/`. These contain RF signal chain measurements performed with laboratory instruments (R&S signal generators, power meters, network analyzers). The calibrations establish the transfer functions from physical RF power levels to the digital values seen by the LLRF controller.

### 3.2 Calibration File Index

| # | File | Date | Subsystem | Measurement | Key Parameters |
|---|------|------|-----------|-------------|----------------|
| [D1] | `driveAmpCalibration.xlsx` | Nov 16, 2020 | Drive amplifier | Frequency response and gain vs. drive level at 476.306 MHz | Input power sweep; R&S SMBV 100A source; 57 rows × 18 cols |
| [D2] | `klystronCouplerDriveAmpCalibrations.xlsx` | Sep 14, 2020 | Klystron input coupler | Forward power calibration — coupler loss, cable loss, insertion loss | Power meter E4418 cal at 476.311 MHz; 72 rows × 10 cols |
| [D3] | `pulsarCouplerCalibration2049.xlsx` | Date code 2049 | Cavity probe couplers | Pulsar 20 dB directional coupler (P/N C4-08-411NMF) characterization | Lot 4619, SLAC P.O. 206568; 23 rows × 6 cols |
| [D4] | `reflectedPowerCalibrations.xlsx` | Feb 8, 2021 | Reflected power trip | Trip point measurements — IQA threshold vs. actual reflected power | Coupler loss −19.45 dB; amplitude, I, Q components; HIGH/HIHI thresholds; 31 rows × 20 cols |
| [D5] | `tuneModeDacCalibration.xlsx` | Undated | DAC/tune mode | DAC output linearity in tune mode — 8 dB fixed attenuators accounted for | Measured on FSW13; 28 rows × 5 cols |
| [D6] | `b132R11PatchPanel.xlsx` | Undated | RF signal distribution | Complete patch panel configuration at B132-11 — maps every J-connector to its signal function | Cable losses, coupler losses, attenuator values; maps legacy and LLRF9 channel assignments; 39 rows × 19 cols |

### 3.3 Signal Chain Context

The calibration data establishes the complete RF measurement chain:

```
Cavity/Klystron → Directional Coupler [D2,D3] → Cable → Patch Panel [D6] → IQA Module → EPICS PV
                                                                    ↓
                                                          Drive Amp [D1] ← RFP DAC
                                                                    ↓
                                                          Reflected Power Trip [D4]
```

The patch panel file [D6] is particularly important because it documents the complete signal routing for both the legacy system (132-14 connections) and the new LLRF9 system (CH0, CH5, etc.), enabling traceability from physical signals to EPICS PV names.

### 3.4 Calibration Data Gaps

| Missing Data | Impact | How to Capture |
|--------------|--------|----------------|
| Cable loss measurements at 476 MHz (individual cables) | Medium — cumulative cable loss affects power calibration accuracy | TDR or network analyzer sweep of each cable run |
| IQA module-to-module variation | Medium — affects per-cavity accuracy | Calibrate each IQA module individually |
| Temperature dependence of calibrations | Low — lab conditions vs. tunnel | Repeat calibrations at tunnel ambient temperature |
| LLRF9 input channel calibration (complete) | High — needed for upgrade commissioning | LLRF9 bench calibration with known sources |

---

## 4. HVPS Operational and Configuration Data

### 4.1 PLC Register Database

**Source**: `hvps/documentation/plc/hvpsPlcLabels.xlsx`

The HVPS SLC-500 PLC uses the following I/O registers. This file provides the complete symbolic name database mapping PLC addresses to physical functions.

#### 4.1.1 Binary Inputs (36 registers)

Selected key registers (from `binary inputs` sheet, 38 rows):

| PLC Tag | Identifier | Function | Normal State |
|---------|-----------|----------|--------------|
| I:2/0 | 1-B3:12/0 | 120 VAC Control Power | On |
| I:2/1 | 1-B3:12/1 | A Phase Reference Voltage | On |
| I:6/0 | 1-B3:13/0 | SCR Disable Fiber Drive | Off |
| I:6/1 | 1-B3:13/1 | Crowbar Enable | Off |
| I:6/2 | 1-B3:13/2 | Crowbar Monitor | On |
| I:6/3 | 1-B3:13/3 | Klystron Arc Monitor | On |
| I:6/5 | 1-B3:13/5 | Transformer Arc Monitor | On |
| I:6/7 | 1-B3:13/7 | RF Crowbar | On |
| I:6/8 | 1-B3:13/8 | Ground Tank Oil Level | On |
| I:6/9 | 1-B3:13/9 | Ground Tank Switch | On |

#### 4.1.2 Binary Outputs (12 registers)

| PLC Tag | Function | Normal State |
|---------|----------|--------------|
| O:2/0 | AC Bias Power Supply | On |
| O:2/1 | 120 VDC Power Supply | On |
| O:2/2 | 240 VDC Power Supply | On |
| O:2/3 | Ground Tank Relay Coil | On |
| O:5/0 | SCR Enable | On |
| O:5/1 | Contactor On | On |
| O:5/2 | Contactor Enable | On |
| O:5/3 | Force Crowbar | Off |
| O:5/4 | Crowbar Off | On |
| O:5/5 | Enerpro Slow Start | Off |
| O:5/6 | Enerpro Fast Inhibit | On |
| O:5/7 | Regulator Reset | Off |

### 4.2 Regulator Test Point Measurements (March 14, 2022)

**Source**: `hvps/documentation/plc/hvpsMeasurements20220314.xlsx` [D7]

Systematic measurements taken from regulator card test points while sweeping gap voltage. These correlate PLC register values (N7:xx) to physical voltages.

| vGap (V) | vHvps (kV) | N7:30 | N7:10 | N7:11 | N7:13 | N7:15 | TP4 (V) | TP7 (V) |
|-----------|-----------|-------|-------|-------|-------|-------|---------|---------|
| 2000 | 60.01 | 19570 | 19570 | 13167 | 10548 | 19702 | 6.010 | −0.305 |
| 2200 | 61.62 | 19932 | 19932 | 13300 | 10655 | 20190 | 6.162 | −0.305 |
| 2400 | 62.94 | 20266 | 20266 | 13422 | 10750 | 20655 | 6.291 | −0.304 |
| 2600 | 64.42 | 20616 | 20616 | 13550 | 10851 | 21104 | 6.439 | −0.304 |
| 2800 | 65.88 | 20980 | 20980 | 13683 | 10955 | 21540 | 6.585 | −0.304 |
| 3000 | 67.37 | 21350 | 21350 | 13819 | 11062 | 22068 | 6.726 | −0.305 |
| 3200 | 68.74 | 21721 | 21721 | 13955 | 11170 | 22543 | 6.871 | −0.304 |

**Key observations**:
- N7:30 = N7:10 at all points (voltage command = voltage feedback — confirms regulation loop is tracking)
- TP4 scales linearly with HVPS voltage: TP4 ≈ vHvps × 0.1 (divider ratio ~10:1)
- TP7 is essentially constant at −0.305 V (regulator error signal — indicates tight regulation)
- N7:15 scales linearly with HVPS voltage (output voltage readback register)

### 4.3 Monitor Signal Connections

**Source**: `hvps/documentation/wiringDiagrams/hvpsMonitorConnections.xlsx` [D8]

Documents the monitor winding test point connections for both HVPS1 and HVPS2, with resistance measurements:

- **HVPS1** (measured March 15, 2022): 20 rows — Main, T1, T2 monitor winding connections
- **HVPS2** (measured February 22, 2022): 20 rows — same configuration
- Reference drawings: WD-730-794-05-C3, EI-730-790-00-C0
- Typical inter-winding resistance: 0.21–0.35 Ω (all measured "open" to ground — confirms isolation)

### 4.4 Local Panel Cross-Connect Mapping

**Source**: `llrf/documentation/LocalPanelToXConnectMapping.xlsx` [D9]

Maps the SD-340-311-01 Local Panel connector pins to the WD-340-330-02 cross-connect panel (53 rows × 8 cols). Key connections include:
- HVPS Vin+/Iin+/Vout/Iout (J2-01 through J2-04)
- Main Focus Solenoid control (J2-06)
- Complete pin-by-pin traceability from HVPS to control system


---

## 5. Reliability and Maintenance Records

### 5.1 Overview

The HVPS reliability database contains **20 years of event logs** (2005–2025) for both HVPS units. This is the most comprehensive operational history dataset in the repository and provides critical baseline information for upgrade planning, spare parts inventory, and mean-time-between-failure (MTBF) analysis.

### 5.2 HVPS1 Event Log

**Source**: `hvps/maintenance/HVPSReliability.xlsx`, Sheet "HVPS1" [D10]  
**Rows**: 48 events, 7 columns (Date, Description, Resource, Comment, Lost time hrs, Length of run, Failure/Swap)  
**Date range**: November 2005 – present

#### Selected Major Events

| Date | Event | Lost Time (hrs) | Hours Since Previous | Classification |
|------|-------|-----------------|---------------------|----------------|
| 2006-06-23 | Transformer arc trip — tension rod snapped | (beam lost 06:00→restored 12:00 next day) | 220 | Failure |
| 2007-03-09 | 60 Hz ripple — tank opened, no problem found | 14 | — | Investigation |
| 2007-07-29 | Phase tank failure — one low side cap and stack shorted | 9 | 142 | Failure |
| 2009-05-19 | Crowbar tank swapout — output cap failing | 5 | 660 | Failure |
| 2012-10-15→2012-11-02 | HVPS2 commissioning period — multiple switchovers | — | — | Commissioning |
| 2020-09-02 | Marconi klystron failure; replaced with Phillips/SLAC | — | — | Equipment |

**Predominant failure modes**: Transformer arcs, phase tank component degradation (capacitors, SCR stacks), crowbar stack aging, 60 Hz ripple investigations

### 5.3 HVPS2 Event Log

**Source**: `hvps/maintenance/HVPSReliability.xlsx`, Sheet "HVPS2" [D10]  
**Rows**: 62 events, 6 columns (Date, Description, Resource, Comment, Lost time hrs, Time to failure)  
**Date range**: January 2009 – present

#### Timeline Phases

| Phase | Date Range | Description |
|-------|-----------|-------------|
| Preparation | 2009-01 → 2011-06 | Initial work on "8-3" (HVPS2 predecessor designation) |
| Final checkout | 2011-06 → 2012-08 | Internal inspection, stack installation, PPS certification |
| Commissioning | 2012-08 → 2012-11 | RF processing, multiple trips (banana plug, tracking on glastic board), switchover testing |
| Operational | 2012-11 → present | Routine operation with periodic maintenance events |

### 5.4 Reliability Analysis Potential

The HVPS reliability data supports the following analyses (not yet performed):

- **MTBF calculation**: Count failure events (marked "F" in Failure/Swap column) and compute hours between failures using "Length of run" column
- **Failure mode trending**: Categorize events by root cause and plot frequency over time
- **Spare parts forecasting**: Identify which components have been replaced most frequently (crowbar stacks, capacitors, SCR assemblies)
- **Comparison HVPS1 vs HVPS2**: Different ages and maintenance histories may reveal wear patterns

> **⏳ PLACEHOLDER**: Formal MTBF analysis, Weibull distribution fitting, and failure mode categorization are planned for a future revision of Doc D after engineering review of the raw data.

---

## 6. Test Campaign Data

### 6.1 Phase Tank SCR Testing

**Source**: `hvps/maintenance/phaseTankScrs.xlsx` [D11]  
**Sheets**: 1 sheet ("HVPS2"), 32 rows × 28 columns  
**Test dates**: July 31, 2020 and August 18, 2020

This file contains detailed voltage and current measurements across series-connected SCR stacks in the phase tank. Each stack consists of 13–14 SCRs in series, and the measurements characterize voltage sharing and leakage current distribution.

#### Sample Data — HVPS2 C+ Stack (July 31, 2020)

| SCR # (1=top) | V_top (kV) | V_bot (kV) | ΔV (kV) | R (MΩ) |
|---------------|-----------|-----------|---------|---------|
| 1 | 24.91 | 22.82 | 2.09 | 15.3 |
| 2 | 22.82 | 20.87 | 1.95 | 14.3 |
| ... | ... | ... | ... | ... |
| 13 | 1.273 | 0 | 1.273 | 9.3 |
| **Average** | | | **1.916** | **14.0** |
| **Std Dev** | | | **0.194** | **1.42** |

**Key observations**:
- Total stack voltage: 24.91 kV at 136.5 µA series current
- Stack resistance: 182.5 MΩ
- Voltage sharing is reasonably uniform (±10%) across SCR positions 1–12
- Bottom SCR (#13) carries lower voltage — expected due to grading network end effects

### 6.2 Crowbar Stack Testing

**Source**: `hvps/maintenance/Spear1Tests20220817.xlsx` [D12]  
**Sheets**: 27+ sheets covering multiple test campaigns (2018–2022)

#### Test Campaign Summary

| Sheet | Date | Test | Content |
|-------|------|------|---------|
| Sheet1 | Jul 28, 2018 | Spear 2 crowbar stack testing | 4 stacks: leakage @ 25 kV, temps, overvoltage, trigger test |
| Sheet2 | Aug 4, 2018 | Spear 2 crowbar retest | Follow-up — Crowbar 1 failed overvoltage @ 43 kV |
| Sheet3 | Aug 8, 2018 | Individual SCR tests (Set 2, removed Aug 3) | Per-SCR: µA @ 4.2 kV, µA @ 6.5 kV, fiber optic trigger, overvoltage self-fire |
| Sheet4 | Aug 11, 2018 | Spare SCR testing | 10+ spare SCRs characterized for rebuild |
| Sheet5 | Aug 18, 2018 | New crowbar stack assembly | Cell-by-cell S/N tracking, stack leakage, fiber optic trigger verification |
| Sheet6 | Aug 21–22, 2018 | Ohm tests for new stacks | Forward/reverse resistance, MΩ measurements per cell |
| Sheet7 | Aug 31, 2018 | SCRs sent to Infineon for analysis | List of SCRs with date codes sent for failure analysis |
| Sheet26 | Aug 6, 2020 | Crowbar stack tests (removed from Spear 2) | 4 stacks: series current @ 25 kV, per-SCR voltage distribution, trigger test |
| Sheet 27 | Sept 2, 2020 | Phase stack tests due to Spear 2 failure | **Also documents klystron replacement**: Marconi → Phillips/SLAC |
| PhaseStacks | Aug 17, 2022 | Spear 1 phase control stack tests | Per-SCR voltage distribution, repairs documented |
| 2022 Phs Stack Report | Aug 17, 2022 | Formal phase stack report | Same data as PhaseStacks with resistance calculations added |
| PhsStackTemplate | — | Blank test template | Template for future test campaigns |
| CrowbarTemplate | — | Blank crowbar test template | Template for future crowbar testing |

#### Individual SCR Test Acceptance Criteria

From Sheet3 data, the following criteria were used for SCR qualification:

| Parameter | Acceptable | Marginal/Reject |
|-----------|-----------|-----------------|
| Leakage @ 4.2 kV | < 30 µA | > 50 µA → reject |
| Leakage @ 6.5 kV | < 50 µA | > 100 µA → reject |
| Fiber optic trigger | "Good" | — |
| Overvoltage self-fire | > 7.0 kV | "Fail!" → reject |

### 6.3 Spear 2 Complementary Tests

**Source**: `hvps/maintenance/Spear2Tests2021.xlsx` [D13]

Complementary test data for the HVPS2 (Spear 2) unit. Structure parallels [D12] with crowbar and phase stack test data.

> **⏳ PLACEHOLDER**: Detailed sheet-by-sheet catalog to be added after data review.


---

## 7. System Configuration Parameters

### 7.1 HVPS Simulation Configuration

**Source**: `hvps/simulation/hvps_sim/config.py` [D14]  
**Size**: 305 lines, 15 Python dataclasses  
**Provenance**: Parameters derived from legacy system technical documentation (see file header for source list)

This file contains the most comprehensive single-source parameter set for the HVPS subsystem, organized into the following dataclasses:

| Dataclass | Key Parameters | Values |
|-----------|---------------|--------|
| `ACInputConfig` | Input voltage, frequency | 12.47 kV RMS L-L, 60 Hz, 3-phase |
| `PhaseShiftTransformerConfig` | T0 rating, phase shift | 3.5 MVA, ±15° dual wye secondary |
| `RectifierTransformerConfig` | T1/T2 rating | 1.5 MVA each, 12.5 kV primary/secondary |
| `ThyristorBridgeConfig` | SCR count, voltage | 6 stacks × 14 SCRs, 40 kV/stack, Powerex T8K7 |
| `FilterConfig` | L1/L2 inductors, capacitors | 0.3 H each (1,084 J stored), 8 µF, 500 Ω isolation |
| `SecondaryRectifierConfig` | Diode bridges | 4 bridges in series, 30 kV/30 A main, 30 kV/3 A filter |
| `CrowbarConfig` | Crowbar SCRs | 4 stacks in series, 100 kV rating, fiber-optic trigger |
| `PLCConfig` | PLC filter parameters | AB-1747-L532, 0.5 s filter time constant, 8-bit ADC |
| `EnerproConfig` | Firing board parameters | SIG HI: 0.9–5.9 V, 30–150° firing range, PLL BW ~66 Hz |
| `RegulatorBoardConfig` | Regulator card | SD-237-230-14-C1, INA117 unity gain, BUF634 driver |
| `OutputConfig` | Output specifications | −77 kV nominal (−90 kV max), 22 A nom (30 A max), ±0.5% reg |
| `EfficiencyConfig` | Power conversion | ~92% overall efficiency |
| `KlystronLoadConfig` | Klystron electrical load | 77 kV, 22 A = ~1.7 MW DC; klystron ~800 kW RF output |
| `InterlocksConfig` | Trip thresholds | Temperature, current, voltage limits |
| `HVPSConfig` | Top-level composite | Aggregates all above configs |

#### Critical Interlock Thresholds (from `InterlocksConfig`)

> **⏳ PLACEHOLDER**: Extract specific interlock threshold values from config.py for oil temperature, overcurrent, overvoltage, crowbar activation, and arc detection trip points. These values are defined in the Python dataclass but need verification against the as-running PLC configuration.

### 7.2 RF System Document Index

**Source**: `llrf/documentation/RfSystemDocumentIndexR3.xlsx` [D15]

Jim Sebek's master document index for the SPEAR3 RF system. Contains two sheets:

| Sheet | Rows | Content |
|-------|------|---------|
| LLRF | 62 | LLRF-related documents — drawing numbers (BD-340-330-xx, SD-340-3xx-xx), descriptions, and locations |
| HVPS | 33 | HVPS-related documents — SLAC-PUB-7591, PS-341-360-01-R2, schematics (SD-730-7xx-xx), and procedures |

This index is the authoritative catalog of engineering drawings and design documents for the RF system. File locations reference the SLAC file server paths (`/accphys/data/sebek/spear/`) and the SPEAR EPICS website (`https://www.slac.stanford.edu/grp/ssrl/spear/epics/app/rf/`).

> **Note**: Many documents listed in this index are also cataloged in Doc L §21 (Source Index) with verified repository paths. The two indexes should be cross-referenced during engineering review.

---

## 8. Safety and Lockout Procedures

### 8.1 Lockout Permit Files

**Source**: `hvps/documentation/procedures/`

Three lockout permit Excel files define the formal safety procedures for HVPS maintenance:

| File | Scope |
|------|-------|
| `Spear3HVPSComplexLockoutPermit.xlsx` | Spear3 RF HVPS complex — all high-voltage equipment |
| `Spear3Spear1HVPSComplexLockoutPermit.xlsx` | Combined Spear3/Spear1 HVPS lockout (when working on HVPS1) |
| `Spear3Spear2HVPSComplexLockoutPermit.xlsx` | Combined Spear3/Spear2 HVPS lockout (when working on HVPS2) |

These files document the equipment to be isolated, the lockout points, the verification steps, and the personnel authorization chain required before HVPS maintenance can proceed.

### 8.2 Hazard Documentation

**Source**: `hvps/documentation/procedures/spear3HvpsHazards.tex` [D16]

LaTeX-format hazard analysis document for the HVPS. Documents electrical hazards (up to 90 kV DC), stored energy hazards (filter inductors: 1,084 J each), oil hazards (transformer and tank), and radiation hazards during HVPS operation.

> **Note**: The `.tex` source is in the repository. A compiled PDF may exist on the SLAC file server but is not in the repo.

---

## 9. SNL Source Code Inventory

### 9.1 Overview

The legacy SPEAR3 RF control system is implemented in **6 SNL (State Notation Language) programs** compiled into the `rfSeq` IOC library. These programs run on a VxWorks RTOS in the VXI crate and implement all supervisory control, state management, calibration, and diagnostics functionality.

**Source directory**: `spear-rf-code-legacy/rfApp/src/seq/`

### 9.2 Program Inventory

| Program | Lines (raw) | States | Concurrent State Sets | Function | Author |
|---------|------------|--------|-----------------------|----------|--------|
| `rf_states.st` | 2,502 | 23 | 3 | Master state machine — RF station lifecycle management | R. Sass (PEP-II, 1997) |
| `rf_calib.st` | 8,606 | 28+ | — | Calibration sequences — IQA calibration, power measurements, automated test procedures | R. Claus (PEP-II) |
| `rf_tuner_loop.st` | 627 | 4+ | — | Cavity tuner stepper motor control — 4 instances via CAV macro | — |
| `rf_hvps_loop.st` | 467 | — | — | HVPS supervisory — voltage ramping, regulation mode selection | — |
| `rf_dac_loop.st` | 359 | — | — | Drive power and gap voltage DAC control (**ELIMINATED in LLRF9 upgrade**) | S. Allison (PEP-II, 1997) |
| `rf_msgs.st` | 449 | — | — | Message logging, CAMAC TAXI error monitoring | — |

> **Note**: Raw line counts include RCS version control headers embedded in `.st,v` files. Actual code content is approximately 60–70% of the raw count.

### 9.3 Header File Inventory

| Header | Lines (raw) | Function |
|--------|------------|----------|
| `rf_dac_loop_pvs.h` | 214 | PV name definitions for DAC loop |
| `rf_dac_loop_defs.h` | 127 | Constants and macros for DAC loop |
| `rf_dac_loop_macs.h` | 267 | Macro definitions for DAC loop |
| `rf_hvps_loop_pvs.h` | 191 | PV name definitions for HVPS loop |
| `rf_hvps_loop_defs.h` | 154 | Constants and macros for HVPS loop |
| `rf_hvps_loop_macs.h` | 203 | Macro definitions for HVPS loop |
| `rf_tuner_loop_pvs.h` | 192 | PV name definitions for tuner loop |
| `rf_tuner_loop_defs.h` | 136 | Constants and macros for tuner loop |
| `rf_tuner_loop_macs.h` | 168 | Macro definitions for tuner loop |
| `rf_loop_defs.h` | 92 | Shared loop constant definitions |
| `rf_loop_macs.h` | 69 | Shared loop macro definitions |

### 9.4 DSP Firmware

**Source directory**: `spear-rf-code-legacy/rfApp/src/dsp/`

The RFP module contains a TI TMS320C50 DSP that implements real-time feedback processing. Key firmware:

| File | Subdirectory | Function |
|------|-------------|----------|
| `ripple.s` | `rfpDsp/` | HVPS ripple cancellation algorithm — 360 Hz notch filter |
| `ripple_phaseoff.s` | `rfpDsp/` | Ripple filter with phase offset compensation |
| `dspSos.s` | `rfpDsp/` | Second-order section filter implementation for RFP |
| `dspSos.s` | `obsDsp/` | Second-order section filter for observer DSP |
| `dspmemtest.s` / `dsptest.s` | `rfpDsp/`, `gvfDsp/` | Memory test and diagnostics routines |
| `dspCmdDef.h` / `dspDef.h` | `genDsp/`, `rfpDsp/`, `gvfDsp/` | DSP command and configuration definitions |

> **Note**: The ripple cancellation firmware (`ripple.s`) implements the 360 Hz notch filter described in Doc P §6.4 (Ripple Loop). This is DSP assembly code for the TMS320C50 processor and will be **eliminated** in the LLRF9 upgrade (replaced by FPGA-based processing).


---

## 10. Canonical Parameter Table

This is the **highest-value section** of Doc D. It establishes the authoritative parameter values for the SPEAR3 RF system by cross-referencing all documents and data sources. Where discrepancies exist, they are flagged with both values and their provenance.

### 10.1 Storage Ring Parameters

| Parameter | Value | Source | Notes |
|-----------|-------|--------|-------|
| Energy | 3.0 GeV | Doc P §1.1 [R1] | Design energy |
| Circumference | 234.12 m | Doc P §1.1 [R1] | |
| Revolution frequency | 1.2804 MHz | Doc P §1.1 | = c/C |
| Harmonic number | 372 | Doc P §1.1 | = f_RF/f_rev |
| RF frequency | 476.3 MHz | Doc P §1.1, Doc 0 §1 | Nominal; exact: 476.305569700 MHz per calibration [D1] |
| Beam current (max) | 500 mA | Doc P §1.1, Doc 0 §1 | Top-up mode |
| Synchrotron radiation loss/turn | 912 keV | Doc P §1.1 [R1] | At 3.0 GeV |
| Synchrotron frequency | ~7.5 kHz | Doc P §4.3 | Depends on gap voltage and beam energy |
| Number of RF cavities | 4 | Doc P §1.3, Doc L, Doc 0 | Single-cell, individually tuned |

### 10.2 Cavity Parameters

| Parameter | Value | Alt. Value | Source | Alt. Source | Status |
|-----------|-------|-----------|--------|-------------|--------|
| Shunt impedance R_s | 3.73 MΩ | 3.9 MΩ | Doc P §2.1 [R6],[R7] | Doc L §5 | ⚠️ See Appendix C, §C.1 |
| Unloaded Q (Q₀) | 32,000 | 33,500 | Doc P §2.1 [R6],[R7] | Doc L §5 | ⚠️ See Appendix C, §C.1 |
| Loaded Q (Q_L) | 6,700 | — | Doc P §2.1, Doc L §5 | — | ✅ Consistent |
| Coupling coefficient β | 3.78 | 4.0 | Doc P §2.1 (derived) | Doc L §5 | ⚠️ Depends on Q₀ |
| Cavity half-bandwidth Δf₁/₂ | 35.5 kHz | — | Doc P §2.1 | — | = f_RF/(2·Q_L) |
| Total gap voltage V_gap | ~2.85 MV | — | Doc P §1.3, Doc L, Doc 0 | — | ✅ Consistent |
| Individual cavity voltage | ~712 kV | — | Doc P §1.3 | — | = V_gap/4 |
| Cavity type | Single-cell, copper | — | Doc L §8 | — | PEP-II heritage |

### 10.3 Klystron Parameters

| Parameter | Value | Source | Notes |
|-----------|-------|--------|-------|
| Original type | Marconi/CPI K3512S | Doc P §1.3 | Failed September 2020 |
| Current type | Phillips/SLAC 476 MHz CW | Doc L §6, [D12] Sheet 27 | Installed September 2020 |
| Rated power | ~1.5 MW | Doc 0 §1 | |
| Operating power | ~800 kW typical | Doc 0 §1 | At 500 mA beam |
| Drive power | ~29 W nominal | Doc 0 §1 | |
| Cathode voltage | −77 kV nominal | Doc P §7.1, config.py [D14] | See §10.4 for HVPS operating point |
| Beam current (klystron) | ~22 A nominal | config.py [D14] | |
| Gain | ~47.5 dB | Doc P §2.5 | |

### 10.4 HVPS Parameters

| Parameter | Value | Source | Notes |
|-----------|-------|--------|-------|
| Input power | 12.47 kV, 3φ, 60 Hz | config.py [D14] | From Substation 507, Breaker 160 |
| Topology | 12-pulse SCR bridge (2×6-pulse) | Doc L §9, config.py [D14] | Phase-shifted ±15° |
| Phase-shift transformer T0 | 3.5 MVA | config.py [D14] | Extended delta |
| Rectifier transformers T1/T2 | 1.5 MVA each | config.py [D14] | |
| SCR type | Powerex T8K7 | config.py [D14] | 14 per stack, 6 stacks per bridge |
| Filter inductors L1, L2 | 0.3 H each | config.py [D14] | Stored energy: 1,084 J each |
| Filter capacitors | 8 µF | config.py [D14] | |
| Nominal output voltage | −77 kV | config.py [D14] | |
| Maximum output voltage | −90 kV | config.py [D14] | |
| Nominal output current | 22 A | config.py [D14] | |
| Maximum output current | 30 A | config.py [D14] | |
| Voltage regulation | ±0.5% | config.py [D14] | |
| Measured operating voltage (June 2020) | 72.08 kV | Doc L §4.3 | At specific beam current |
| Operating voltage at 500 mA | ~74 kV | Doc 0 §1 | LLRF9 commissioning reference |
| Crowbar energy (with crowbar) | < 5 J | config.py [D14] | |
| Crowbar energy (without crowbar) | < 20 J | config.py [D14] | |
| Enerpro model | FCOG6100 Rev.K | Doc L §11 | S/N: 41506, 50470, 30045 |
| PLC processor | AB-1747-L532 | config.py [D14], Doc L §10 | SLC-500 family |

### 10.5 Feedback Loop Parameters

| Parameter | Value | Source | Notes |
|-----------|-------|--------|-------|
| Legacy loop delay | ~500 ns | Doc P §2.6 | Analog processing |
| LLRF9 loop delay | ~270 ns | Doc P §2.6, Doc 0 | FPGA-based |
| Legacy max bandwidth | ~500 kHz | Doc P §2.6 | 1/(4·τ_delay) |
| LLRF9 max bandwidth | ~926 kHz | Doc P §2.6 | 1/(4·τ_delay) |
| Direct loop bandwidth | ~100 kHz | Doc P §6.1 | Dominant fast loop |
| Ripple filter frequency | 360 Hz | Doc P §6.4, ripple.s | 6th harmonic of 60 Hz |
| Tuner loop bandwidth | ~0.1 Hz | Doc P §8.3 | Mechanical system limitation |
| HVPS regulation loop BW | ~10 Hz | Doc P §7.4 | PLC + Enerpro limitation |
| Gap voltage feedforward BW | ~10 Hz | Doc P §6.5 | Slow correction |

### 10.6 Tuner System Parameters

| Parameter | Value | Source | Notes |
|-----------|-------|--------|-------|
| Legacy stepper module | AB 1746-HSTP1 | Doc L §8 | Obsolete |
| Legacy drive | SS2000MD4-M | Doc L §8 | Superior Electric Slo-Syn PWM, obsolete |
| Current controller | Galil DMC-4143 Rev 1.3h | Doc L §17, commissioning logs | Commissioned August 2025 |
| Stepper motor | Superior Electric Slo-Syn M093-FC11 | Doc L §8 | NEMA 34D, retained in upgrade |
| Number of tuners | 4 | Doc L §8 | One per cavity |


---

## 11. Data Still Needed

The following data is **not yet available** in the repository and must be captured while the legacy system is still operational. Items are ranked by urgency.

### 11.1 Time-Critical (Must Capture Before Hardware Swap)

| # | Data Needed | Why Important | How to Capture | Priority |
|---|-------------|---------------|----------------|----------|
| 1 | Live EPICS archiver trends (2–4 hours at 500 mA) | Baseline normal operation for all PVs | Archive all RF PVs at full beam current; include amplitude/phase, HVPS V/I, klystron Pfwd/Prefl, detuning angles | 🔴 CRITICAL |
| 2 | Current operational setpoints | Document tuning parameters as-built | Interview operators; record: tuner deadbands, voltage limits, trip thresholds, alarm boundaries, safe operating envelope | 🔴 CRITICAL |
| 3 | Galil DMC-4143 configuration files | Modern tuner control parameters | Extract from Galil controller: motion profiles, limit switch settings, homing procedures, current configuration state | 🔴 HIGH |
| 4 | EPICS IOC startup scripts | Required for system restoration if needed | Capture iocBoot directory: st.cmd files, auto-start configurations, envPaths | 🔴 HIGH |
| 5 | Current PLC ladder logic | Latest safety logic — may differ from CasselPLCCode.pdf | Export SLC-500 ladder using RSLogix; compare to documented version | 🟡 MEDIUM |

### 11.2 Important (Before Final Decommissioning)

| # | Data Needed | Why Important | How to Capture |
|---|-------------|---------------|----------------|
| 6 | Cavity resonant frequency (measured) | Establish baseline for detuning analysis | Perform cavity frequency sweep at operating temperature |
| 7 | IQA module calibration state | Per-module calibration factors | Read current IQA scaling PVs and record |
| 8 | RFP module configuration registers | Legacy DSP configuration as-running | Dump RFP register contents via EPICS |
| 9 | Klystron characterization data | Current Phillips/SLAC tube performance | Measure gain curve, saturation characteristics if accessible |
| 10 | Waveguide arc detection fiber mapping | Which fibers connect to which waveguide sections | Physical trace and document |

### 11.3 Desirable (For Completeness)

| # | Data Needed | Why Important | How to Capture |
|---|-------------|---------------|----------------|
| 11 | MCC operator procedures | Institutional knowledge at risk | Document operator workflows for RF system startup, tuning, trip recovery |
| 12 | Cable loss survey at 476 MHz | Improve calibration accuracy | Network analyzer sweep of each RF cable |
| 13 | Photograph documentation | Visual record of legacy hardware | Photograph all 50+ locations identified in Doc L photo placeholders |
| 14 | Transformer oil analysis reports | HVPS transformer condition baseline | Obtain most recent DGA (dissolved gas analysis) results |

---

## Appendix A — Complete EPICS Database File Catalog

The complete list of 50 EPICS database files with record counts and type distributions. All files are located in `spear-rf-code-legacy/rfApp/Db/` with `.db,v` (RCS) extension.

| # | File | Total | Record Types |
|---|------|-------|-------------|
| 1 | ab_adapter.db | 1 | mbbi:1 |
| 2 | ab_adapter_card.db | 1 | mbbi:1 |
| 3 | ab_dcm_table.db | 1 | mbbi:1 |
| 4 | aim.db | 74 | ai:27, bo:20, fanout:3, mbbiDirect:18, mbboDirect:3, p2RfAim:3 |
| 5 | cf2.db | 39 | bi:3, calc:5, fanout:2, mbbiDirect:2, mbbo:18, mbboDirect:1, p2RfCf2:1, seq:5, stringin:1, timestamp:1 |
| 6 | cfm.db | 12 | ai:1, bi:1, bo:3, calc:1, mbbiDirect:1, mbbo:3, mbboDirect:1, p2RfCfm:1 |
| 7 | clk.db | 12 | bo:6, mbbiDirect:1, mbbo:3, mbboDirect:1, p2RfClk:1 |
| 8 | gvf.db | 11 | bo:5, mbbiDirect:2, mbbo:2, mbboDirect:1, p2RfGvf:1 |
| 9 | iqCvt.db | 5 | sub:5 |
| 10 | iqGet.db | 2 | bi:1, sub:1 |
| 11 | iqa.db | 7 | bo:2, mbbiDirect:3, mbboDirect:1, p2RfIqa:1 |
| 12 | rf_ab_module.db | 1 | bi:1 |
| 13 | rf_analog.db | 9 | ai:3, bi:4, calc:2 |
| 14 | rf_analog_log.db | 12 | ai:3, bi:4, calc:4, sub:1 |
| 15 | rf_beam.db | 3 | ai:1, bi:1, calc:1 |
| 16 | rf_beam_spr.db | 6 | ai:1, ao:1, bi:1, calc:1, calcout:2 |
| 17 | rf_cav.db | 41 | ao:11, calc:3, compress:6, event:3, fanout:1, mbbo:2, seq:2, steppermotor:1, stringout:1, sub:11 |
| 18 | rf_digital_hvps.db | 1 | bi:1 |
| 19 | rf_digital_modu.db | 1 | bi:1 |
| 20 | rf_digital_plc.db | 1 | bi:1 |
| 21 | rf_fbck.db | 48 | ao:5, bo:10, calc:2, event:2, fanout:1, mbbo:1, sel:2, seq:17, stringout:1, sub:7 |
| 22 | rf_hvps.db | 31 | ai:6, ao:10, bo:4, calc:2, compress:1, event:1, mbbi:1, mbbo:3, seq:2, stringout:1 |
| 23 | rf_interlock.db | 2 | bi:2 |
| 24 | rf_interlock_arc.db | 10 | bi:5, calc:5 |
| 25 | rf_interlock_vxi.db | 4 | bi:4 |
| 26 | rf_iqa.db | 6 | ao:2, bi:2, sub:2 |
| 27 | rf_iqa_module.db | 8 | calc:1, mbbiDirect:5, seq:1, sub:1 |
| 28 | rf_iqa_scale.db | 9 | calc:4, seq:3, sub:2 |
| 29 | rf_klys.db | 30 | ai:3, ao:11, calc:1, compress:2, sel:3, sub:10 |
| 30 | rf_rfp_fourdacs.db | 2 | seq:1, sub:1 |
| 31 | rf_rfp_twodacs.db | 2 | seq:1, sub:1 |
| 32 | rf_stn.db | 61 | abDcm:1, ao:6, bi:8, bo:4, calc:3, fanout:4, longout:1, mbbi:3, mbbo:2, seq:4, state:1, stringout:22, sub:2 |
| 33 | rf_stn_cav.db | 81 | ao:24, bo:4, calc:9, compress:3, event:10, sel:8, seq:8, sub:15 |
| 34 | rf_sumy_2CV.db | 22 | calc:4, fanout:16, seq:1, sub:1 |
| 35 | rf_sumy_4CV.db | 26 | calc:2, fanout:22, seq:1, sub:1 |
| 36 | rf_sumy_arc_2CV.db | 6 | calc:4, fanout:2 |
| 37 | rf_sumy_arc_4CV.db | 4 | calc:2, fanout:2 |
| 38 | rf_sumy_arc_4CVAll.db | 12 | calc:8, fanout:4 |
| 39 | rf_sumy_cav.db | 32 | calc:28, fanout:2, sel:2 |
| 40 | rf_sumy_circ.db | 17 | calc:13, fanout:4 |
| 41 | rf_sumy_hvps.db | 11 | calc:10, fanout:1 |
| 42 | rf_sumy_klys.db | 63 | calc:61, fanout:2 |
| 43 | rf_sumy_plc.db | 1 | bi:1 |
| 44 | rf_sumy_stn.db | 77 | calc:69, fanout:4, mbbiDirect:4 |
| 45 | rf_sumy_stn_pep.db | 4 | calc:4 |
| 46 | rf_sumy_stn_spr.db | 4 | calc:4 |
| 47 | rf_sumy_wg.db | 9 | calc:9 |
| 48 | rf_temp.db | 4 | ai:2, bi:2 |
| 49 | rfp.db | 35 | bo:22, mbbiDirect:2, mbbo:6, mbboDirect:1, p2RfRfp:1, stringin:3 |
| 50 | rfp_dacs.db | 28 | seq:14, sub:14 |

**Grand Total: 889 records**


---

## Appendix B — File Manifest

All data files referenced in this document, with repository paths. Files marked (xlsx) contain structured spreadsheet data; (py) Python source; (tex) LaTeX source; (st,v/h,v) RCS-versioned source code; (s,v) RCS-versioned assembly.

### B.1 Calibration Data Files

| Path | Type | Ref |
|------|------|-----|
| `llrf/calibrations/driveAmpCalibration.xlsx` | xlsx | [D1] |
| `llrf/calibrations/klystronCouplerDriveAmpCalibrations.xlsx` | xlsx | [D2] |
| `llrf/calibrations/pulsarCouplerCalibration2049.xlsx` | xlsx | [D3] |
| `llrf/calibrations/reflectedPowerCalibrations.xlsx` | xlsx | [D4] |
| `llrf/calibrations/tuneModeDacCalibration.xlsx` | xlsx | [D5] |
| `llrf/calibrations/b132R11PatchPanel.xlsx` | xlsx | [D6] |

### B.2 HVPS Data Files

| Path | Type | Ref |
|------|------|-----|
| `hvps/documentation/plc/hvpsMeasurements20220314.xlsx` | xlsx | [D7] |
| `hvps/documentation/plc/hvpsPlcLabels.xlsx` | xlsx | §4.1 |
| `hvps/documentation/wiringDiagrams/hvpsMonitorConnections.xlsx` | xlsx | [D8] |
| `hvps/maintenance/HVPSReliability.xlsx` | xlsx | [D10] |
| `hvps/maintenance/phaseTankScrs.xlsx` | xlsx | [D11] |
| `hvps/maintenance/Spear1Tests20220817.xlsx` | xlsx | [D12] |
| `hvps/maintenance/Spear2Tests2021.xlsx` | xlsx | [D13] |
| `hvps/simulation/hvps_sim/config.py` | py | [D14] |
| `hvps/documentation/procedures/spear3HvpsHazards.tex` | tex | [D16] |
| `hvps/documentation/procedures/Spear3HVPSComplexLockoutPermit.xlsx` | xlsx | §8.1 |
| `hvps/documentation/procedures/Spear3Spear1HVPSComplexLockoutPermit.xlsx` | xlsx | §8.1 |
| `hvps/documentation/procedures/Spear3Spear2HVPSComplexLockoutPermit.xlsx` | xlsx | §8.1 |

### B.3 LLRF Documentation

| Path | Type | Ref |
|------|------|-----|
| `llrf/documentation/LocalPanelToXConnectMapping.xlsx` | xlsx | [D9] |
| `llrf/documentation/RfSystemDocumentIndexR3.xlsx` | xlsx | [D15] |

### B.4 EPICS Database Files

50 files in `spear-rf-code-legacy/rfApp/Db/*.db,v` — see Appendix A for complete listing.

### B.5 SNL Source Code

17 files in `spear-rf-code-legacy/rfApp/src/seq/*.st,v` and `*.h,v` — see §9 for inventory.

### B.6 DSP Firmware

Files in `spear-rf-code-legacy/rfApp/src/dsp/` — see §9.4 for key files.

---

## Appendix C — Cross-Document Consistency Issues

This appendix formally registers known discrepancies between Doc P, Doc L, and Doc 0. It mirrors the content of Architecture Proposal Appendix E but is included here for self-containment.

### C.1 Cavity RF Parameter Discrepancy

| Parameter | Doc P Value (§2.1) | Doc L Value (§5) | Discrepancy |
|-----------|-------------------|------------------|-------------|
| R_s | 3.73 MΩ | 3.9 MΩ | 4.6% difference |
| Q₀ | 32,000 | 33,500 | 4.7% difference |
| β | 3.78 | 4.0 | 5.8% difference (derived from Q₀) |

**Doc P provenance**: Schwarz parameter table PS-340-330-51 [R6]; Rimmer LBL-33360 [R7] — primary measurement references for PEP-II/SPEAR3 cavities.

**Doc L provenance**: No specific source cited for these values. Possibly from a different measurement campaign or rounded from a different reference.

**Recommendation**: Adopt Doc P values as canonical (stronger provenance). During engineering review, verify against most recent cavity characterization measurements. Update Doc L to match or provide explicit source citation.

**Impact**: Affects calculation of:
- Beam loading parameter (Y_b = I_b / (V_c/R_s))
- Optimal coupling coefficient
- Robinson instability threshold
- Loop gain requirements

### C.2 Klystron Identification Timeline

| Date | Event | Source |
|------|-------|--------|
| 1997–2020 | Marconi/CPI K3512S in service | Doc P §1.3 |
| Sept 2, 2020 | Marconi klystron failure | [D12] Sheet 27 (Spear1Tests) |
| Sept 2020 | Phillips/SLAC 476 MHz CW klystron installed | [D12] Sheet 27, Doc L §6 |
| 2020–present | Phillips/SLAC tube in service | Doc L §6 |

**Recommendation**: Add timeline note to both Doc P and Doc L to avoid confusion.

### C.3 HVPS Operating Voltage Context

The HVPS output voltage is an **operational variable**, not a fixed parameter. It depends on beam current, cavity detuning, and klystron characteristics. Documents should always state the context when citing a voltage value:

| Cited Value | Context | Document |
|-------------|---------|----------|
| −77 kV | Design nominal (full beam, new klystron) | Doc P §7.1, config.py |
| −74 kV | Operating at 500 mA (LLRF9 commissioning) | Doc 0 §1 |
| −72.08 kV | Measured June 2020 (pre-klystron replacement) | Doc L §4.3 |
| 60–69 kV | Regulator test sweep (2–3.2 kV gap) | [D7] Measurements March 2022 |

---

*End of Document*

**Document Control**:
- This document should be updated whenever new operational data is captured or new calibrations are performed.
- The definitive version is `Designs/D_OPERATIONAL_DATA_CATALOG.md` in the `spearlegacyLLRF` repository.
- **Provenance**: AI-ASSISTED — structure and data inventory assembled by AI from comprehensive repository analysis; all data values extracted from actual repository files. Subject to engineering review and validation.

