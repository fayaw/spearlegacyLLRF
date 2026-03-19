# Cross-Reference Index — PEP-II / SPEAR3 LLRF Documentation

**Document Number**: LLRF-REF-006
**Version**: 1.0
**Date**: 2026-03-18
**Purpose**: AI-ready topic-to-source mapping for the complete PEP-II/SPEAR3 LLRF knowledge base

---

## 1. Master Topic Cross-Reference Matrix

### 1.1 System Architecture

| Topic | Legacy PDF | Published Paper | Source Code | This Package |
|-------|-----------|----------------|-------------|--------------|
| Overall LLRF block diagram | `bd3403300000.pdf` | Corredoura 1999, Fig. 1 | — | `00_...REFERENCE.md` §2.1 |
| VXI crate topology | `bd3403300000.pdf`, `bd3403300100.pdf` | Corredoura 1999, Fig. 1 | — | `02_...HARDWARE.md` §1 |
| VXI module interconnection | `bd3403300100.pdf` | — | — | `02_...HARDWARE.md` §3 |
| RF station layout (power) | `blockDiagrambd3403290100-1.pdf` | McIntosh 2005 | — | `00_...REFERENCE.md` §2.1 |
| IQ signal processing philosophy | `ps3403305100.pdf` | Corredoura 1999 | — | `00_...REFERENCE.md` §1.5 |

### 1.2 Feedback Loops

> **Note**: All feedback loop design details are contained in a single source document: `feedbackLoopDescriptionps3403305200.pdf` (PS-340-330-52-R0). No standalone module-level specification documents for individual loops exist in the legacy PDF archive. Published papers provide additional theoretical context.

| Topic | Legacy PDF | Published Paper | Source Code | This Package |
|-------|-----------|----------------|-------------|--------------|
| Complete loop architecture | `feedbackLoopDescriptionps3403305200.pdf` | Corredoura 1999, Fig. 3 | All `.st` | `01_...LOOPS.md` §1 |
| Direct (wideband) loop | `feedbackLoopDescriptionps3403305200.pdf` pp. 3-4 | Corredoura 1999; Fox 2010 §II | `rf_states.st` | `01_...LOOPS.md` §3 |
| Comb (narrowband) loop | `feedbackLoopDescriptionps3403305200.pdf` p. 5 | Corredoura 1999; Fox 2010 §III | `rf_calib.st` | `01_...LOOPS.md` §4 |
| Ripple loop | `feedbackLoopDescriptionps3403305200.pdf` p. 6 | Corredoura 2000 §6 | `rf_dac_loop.st` | `01_...LOOPS.md` §5 |
| Lead compensation | `feedbackLoopDescriptionps3403305200.pdf` p. 4 | — | `rf_states.st` | `01_...LOOPS.md` §6 |
| Integral compensation | `feedbackLoopDescriptionps3403305200.pdf` p. 4 | — | `rf_states.st` | `01_...LOOPS.md` §6 |
| Tuner loop | `feedbackLoopDescriptionps3403305200.pdf` p. 5 | Corredoura 1999 | `rf_tuner_loop.st` | `01_...LOOPS.md` §7 |
| DAC loop (setpoint) | `feedbackLoopDescriptionps3403305200.pdf` p. 6 | — | `rf_dac_loop.st` | `01_...LOOPS.md` §8 |
| HVPS loop (voltage) | `feedbackLoopDescriptionps3403305200.pdf` p. 6 | — | `rf_hvps_loop.st` | `01_...LOOPS.md` §9 |
| GVF / feed-forward | `feedbackLoopDescriptionps3403305200.pdf` pp. 6-7 | Corredoura 1999 (woofer) | `rf_msgs.st` (TAXI) | `01_...LOOPS.md` §10 |
| Loop stability analysis | `feedbackLoopDescriptionps3403305200.pdf` | Rivetta 2007; Fox 2010 | — | `01_...LOOPS.md` §11 |

### 1.3 Hardware Modules

| Topic | Legacy PDF | Published Paper | Source Code | This Package |
|-------|-----------|----------------|-------------|--------------|
| RFP module | `ps3403305100.pdf` | Corredoura 1999 | `rf_calib.st` (p2RfRfpDef.h — PEP-II file, not in repo) | `02_...HARDWARE.md` §2.1 |
| IQA modules | — | Ziomek & Corredoura 1995 | — | `02_...HARDWARE.md` §2.2 |
| Comb filter modules | `feedbackLoopDescriptionps3403305200.pdf` p. 5 | Corredoura 1999 | `rf_calib.st` | `02_...HARDWARE.md` §2.3 |
| GVF module | `feedbackLoopDescriptionps3403305200.pdf` pp. 6-7 | Corredoura 1999 | `rf_dac_loop.st`, `rf_msgs.st` | `02_...HARDWARE.md` §2.4 |
| CLK/RF distribution | — | — | — | `02_...HARDWARE.md` §2.5 |
| ARC/Interlock (AIM) | — | — | `rf_states.st`, `rf_msgs.st` | `02_...HARDWARE.md` §2.6 |
| Drive chain / modulator | — (no standalone spec; `ps3403305503.pdf` is a safety survey) | Corredoura 2000, Figs. 4-6 | — | `02_...HARDWARE.md` §4 |
| Interface chassis | `legacyInterfaceModules/*.pdf` | — | — | `03_...CATALOG.md` §3.1 |

### 1.4 Operational Procedures

| Topic | Legacy PDF | Published Paper | Source Code | This Package |
|-------|-----------|----------------|-------------|--------------|
| NIR safety procedure | `ps3403306102.pdf` (PS-340-330-61-R2) | — | — | — |
| Calibration sequences | `ps3403305300.pdf` (PS-340-330-53), `ps3403305600.pdf` (PS-340-330-56) | — | `rf_calib.st` | `A_LEGACY_...DESIGN.md` |
| State machine (startup) | — | Allison & Claus 1997 | `rf_states.st` | `A_LEGACY_...DESIGN.md` |
| Fault recovery | — | Corredoura 2000 §2 | `rf_states.st`, `rf_msgs.st` | `04_...SYNTHESIS.md` §3 |
| Fast turn-on | — | Corredoura 2000 §2 | `rf_states.st` | `04_...SYNTHESIS.md` §3 |

### 1.5 SPEAR3 Specifics

| Topic | Legacy PDF | Published Paper | Source Code | This Package |
|-------|-----------|----------------|-------------|--------------|
| SPEAR3 RF system config | — | McIntosh 2005 | — | `00_...REFERENCE.md` §1.2, §4 |
| 476 MHz cavity processing | — | McIntosh 2003 | — | `04_...SYNTHESIS.md` §6 |
| Booster RF upgrade | — | Park & Corbett 2010 | — | `04_...SYNTHESIS.md` §6 |
| LLRF9 replacement system | — | — | — | `3_LLRF9_...REPORT.md` |
| SPEAR3 operating parameters | — | SSRL website | — | `00_...REFERENCE.md` §1.3 |

---

## 2. Source Code File Index

| File | Lines | Primary Function | Related Loops |
|------|-------|-----------------|---------------|
| `rf_states.st` | 2227 | Master state machine (OFF→PARK→TUNE→ON_FM→ON_CW) | All loops |
| `rf_dac_loop.st` | 290 (+426 in headers) | DAC setpoint control, gap voltage / drive power | DAC, ripple |
| `rf_hvps_loop.st` | 343 (+351 in headers) | Klystron voltage regulation | HVPS |
| `rf_tuner_loop.st` | 555 (+306 in headers) | Cavity tuner motor control (per-cavity) | Tuner |
| `rf_calib.st` | 3345 | Automated calibration sequences | All (Octal DAC, comb, offsets) |
| `rf_msgs.st` | 352 | Message logging, TAXI recovery, filament | GVF (TAXI) |

Supporting files:
- `rf_loop_defs.h` — Common definitions
- `rf_loop_macs.h` — Common macros (severity checking)
- `rf_*_defs.h` — Per-loop definitions
- `rf_*_macs.h` — Per-loop macros
- `rf_*_pvs.h` — Per-loop PV declarations

---

## 3. Published Paper Citation Index

| Short Name | Full Citation | DOI/Link | Key Figures |
|-----------|--------------|----------|-------------|
| Corredoura 1999 | P.L. Corredoura, "Architecture and Performance of the PEP-II Low-Level RF System," SLAC-PUB-8498, PAC 1999 | DOI: 10.2172/10204 | Fig. 1 (VXI topology), Fig. 3 (loops) |
| Corredoura 2000 | P. Corredoura et al., "Experience with the PEP-II RF System at High Beam Currents," EPAC 2000 | arXiv:physics/0007029 | Figs. 4-9 (drive chain, saturation) |
| Fox 2010 | J. Fox et al., Phys. Rev. ST Accel. Beams 13, 052802 (2010) | DOI: 10.1103/PhysRevSTAB.13.052802 | Figs. 1-10 (growth rates, DSP, faults) |
| Rivetta 2007 | C. Rivetta et al., Phys. Rev. ST Accel. Beams 10, 022801 (2007) | DOI: 10.1103/PhysRevSTAB.10.022801 | Simulation model, stability analysis |
| McIntosh 2003 | P. McIntosh, SLAC-PUB-10083, PAC 2003 | DOI: 10.2172/815601 | Cavity processing results |
| McIntosh 2005 | P. McIntosh, SLAC-PUB-11017 (2005) | DOI: 10.2172/839730 | SPEAR3 RF system |
| Schwarz 1994 | H. Schwarz, R. Rimmer, PAC 1994 | OSTI: 10194040 | Original PEP-II RF design |
| Pedersen 1992 | F. Pedersen, SLAC-400 (1992) | — | Beam loading theory |
| Allison 1997 | S. Allison, R. Claus, PAC 1997 | — | EPICS interface |
| Ziomek 1995 | C. Ziomek, P. Corredoura, PAC 1995 | — | IQA digital demodulator |

---

## 4. Glossary

| Term | Definition |
|------|-----------|
| AIM | Arc/Interlock Module — VXI module for arc detection and interlocks |
| Baseband | Signal representation at zero center frequency (after demodulation from RF carrier) |
| CFM | Comb Filter Module — ⚠️ **PEP-II ONLY, not used in SPEAR3** |
| Comb loop | Narrowband feedback loop with gain peaks at revolution harmonics — ⚠️ **PEP-II ONLY** |
| Coupled-bunch instability | Collective beam oscillation driven by cavity impedance at revolution harmonics |
| Direct loop | Wideband feedback loop that reduces effective cavity impedance |
| DSP | Digital Signal Processor — used in ripple loop (PEP-II: also comb filter) |
| EPICS | Experimental Physics and Industrial Control System — distributed control framework |
| GVF/GFF | Gap Voltage Feed-Forward — ⚠️ **PEP-II ONLY, not used in SPEAR3**. Module providing voltage reference and LFB interface |
| HVPS | High Voltage Power Supply — provides klystron cathode voltage (up to 90 kV, nominal 74.7 kV at 500 mA) |
| IQ | In-phase / Quadrature — two-component representation of RF signal amplitude and phase |
| IQA | IQ/Amplitude detector — VXI digital demodulation module |
| LFB | Longitudinal Feedback — bunch-by-bunch feedback system for coupled-bunch damping |
| LLRF | Low-Level RF — the feedback and control electronics for the RF system |
| LO | Local Oscillator — 471.1 MHz reference for IQ demodulation |
| PEP-II | Positron-Electron Project II — SLAC asymmetric B-Factory collider (1999-2008) |
| RFP | RF Processor — central VXI module containing analog feedback processing |
| Robinson instability | Instability from beam-cavity interaction when impedance has wrong sign |
| SCR | Silicon Controlled Rectifier (thyristor) — used in HVPS switching |
| SNL | State Notation Language — EPICS real-time sequencer programming language |
| SPEAR3 | Stanford Positron Electron Asymmetric Ring 3rd generation — 3 GeV light source |
| SSRL | Stanford Synchrotron Radiation Lightsource |
| TAXI | Serial data link interface for fiber optic communication (GVF ↔ LFB) — ⚠️ **PEP-II ONLY, not connected at SPEAR3** |
| VXI | VMEbus eXtensions for Instrumentation — modular instrument bus standard |
| Woofer | Low-frequency damping via RF station, driven by LFB system |

| LLRF9 | Dimtel LLRF9/476 — FPGA-based LLRF controller replacing VXI system |
| Interface Chassis | New centralized hardware interlock hub (microsecond response) |
| DMC-4143 | Galil 4-axis motion controller — replaces AB 1746-HSTP1 for tuner control |
| PDR | Physical Design Report — `Designs/0_PHYSICAL_DESIGN_REPORT.md` |
| Waveform Buffer | New subsystem for slow RF + HVPS signal monitoring (8 RF + 4 HVPS channels) |
| HCPL-2400 | Broadcom optocoupler used in Interface Chassis (1 μs propagation) |
| HFBR-1412/2412 | Broadcom fiber optic transceivers for HVPS controller link |
| Enerpro FCOG6100 | HVPS SCR firing circuit board (VCO-based trigger generation) |
| Microstep-MIS | Commercial waveguide arc detector (replacing non-functional PEP-II design) |
| ZX47 | Mini-Circuits RF power detector used in Waveform Buffer |

---

## 5. Document Source Matrix (Version 2.0)

### 5.1 Engineering Design Documents (docx)

| Source File | Location | Author/Date | Content | Used In |
|-------------|----------|-------------|---------|---------|
| LLRFOperation_jims.docx | llrf/documentation/ | J. Sebek | Turn-on procedure, control hierarchy, tuner mechanics | Doc 01 §2.9, Doc 04 §9.1–9.3 |
| LLRFUpgradeTaskListRev3.docx | llrf/documentation/ | — | Project task list, procurement status | Doc 00 §1.3 |
| LLRFDocumentationNotesR2.docx | llrf/documentation/ | J. Sebek, Nov 2021 | AB communication chain, Local Panel, Fast Interlock Chassis | Doc 02 §5.1–5.2 |
| fiberOpticCableSignalControlRev3.docx | llrf/documentation/ | Rev 3, Jun 2022 | Three fiber optic signals, crowbar energy analysis, HVPS protection | Doc 02 §5.3, Doc 04 §9.4 |
| llrfInterfaceChassis.docx | llrf/architecture/ | — | Complete Interface Chassis specification | Doc 02 §6.1–6.4 |
| WaveformBuffersforLLRFUpgrade.docx | llrf/architecture/ | J. Sebek, Jan 2026 | Waveform buffer design, 24 RF signal distribution, magic tee loads | Doc 02 §8.1–8.2 |
| arcDetectorHardwareOptions.docx | llrf/architecture/ | — | Microstep-MIS sensor selection, MDC-45300 viewport mounting | Doc 02 §9.1–9.3 |
| rfPowerDetector.docx | llrf/architecture/ | — | Mini-Circuits ZX47 power detector specifications | Doc 02 §8.3 |
| analogDesignComponents.docx | llrf/architecture/ | — | OPA189, BUF634A, optocoupler selection | Doc 02 §10.1 |
| RFSystemMPSRequirements.docx | hvps/architecture/designNotes/ | — | Protection philosophy, 5 crowbar trigger sources | Doc 02 §7.2, Doc 04 §9.4 |
| interfacesBetweenRFSystemControllers.docx | hvps/architecture/designNotes/ | — | Interface Chassis interfaces, optocoupler specs (HCPL-2400) | Doc 02 §6.1–6.3 |
| controllerFiberOpticConnections.docx | hvps/architecture/designNotes/ | J. Sebek, May 2022 | Enerpro trigger chain, driver board analysis, COMMANDS bus | Doc 02 §7.1–7.3 |
| enerproBoardHvps.docx | hvps/controls/enerpro/ | J. Sebek | FCOG6100 Rev K, FCOAUX60, phase reference inputs, SIGHI | Doc 02 §7A.7 |
| enerproDiscussion07072022.docx | hvps/controls/enerpro/ | Call with Enerpro (Rivera/Prince) | 3-resistor adapter, J7 connector, amplitude matching | Doc 02 §7A.7 |
| EnerproVoltageandCurrentRegulatorBoardNotes.docx | hvps/architecture/designNotes/ | — | Regulator board INA117, divider scale factor, TP analysis | Doc 02 §7A.3, §7A.6 |
| regulatorEnerproTestingNotes.docx | hvps/architecture/designNotes/ | — | SIGHI Thevenin model, TP7 measurements | Doc 02 §7A.3 |
| plcNotesR1.docx | hvps/documentation/plc/ | — | PLC rung analysis, LPF, phase calculation | Doc 02 §7A.4–7A.5 |
| HoffmanBoxPPSWiring.docx | pps/ | J. Sebek | PPS Burndy connector, switchgear cross-references | Doc 02 §7A.8 |
| cavityTunerInspections20230613.docx | llrf/tuners/ | J. Sebek, Jun 2023 | Set screw failure mode, limit switches, mechanical details | Doc 02 §7B.1–7B.3 |
| GalilCommissioning.docx | llrf/tuners/galil/ | — | DMC-4143 specs, motor ratings, firmware rev | Doc 02 §7B.1 |

### 5.2 Spreadsheet Data Sources (xlsx)

| Source File | Location | Content | Used In |
|-------------|----------|---------|---------|
| RfSystemDocumentIndexR3.xlsx | llrf/documentation/ | 62 LLRF + 33 HVPS document entries with descriptions | Doc 02 §11.1–11.2 |
| LocalPanelToXConnectMapping.xlsx | llrf/documentation/ | Pin-by-pin J2/J3 connector mapping to cross-connect X530 | Doc 02 §5.2 |
| hvpsPlcLabels.xlsx | hvps/documentation/plc/ | 38 binary inputs + 12 binary outputs, full PLC I/O map | Doc 02 §7A.2 |
| hvpsMeasurements20220314.xlsx | hvps/documentation/plc/ | Regulator test point calibration data (March 2022) | Doc 02 §7A.6 |
| hvpsMonitorConnections.xlsx | hvps/documentation/wiringDiagrams/ | Monitor winding resistance measurements (HVPS1 + HVPS2) | Doc 02 §7A.7 |
| reflectedPowerCalibrations.xlsx | llrf/calibrations/ | Reflected power trip setpoints (measured Feb 2021) | Doc 02 §7C.1 |
| tuneModeDacCalibration.xlsx | llrf/calibrations/ | Tune mode DAC-to-power mapping | Doc 02 §7C.2 |
| b132R11PatchPanel.xlsx | llrf/calibrations/ | 16 RF signal paths with coupler/cable losses | Doc 02 §7C.3 |
| klystronCouplerDriveAmpCalibrations.xlsx | llrf/calibrations/ | Waveguide coupler 61.3 dB, frequency sweep | Doc 02 §7C.4 |

### 5.3 Design Reports (Designs/*.md)

| Source File | Location | Lines | Content | Used In |
|-------------|----------|-------|---------|---------|
| 0_PHYSICAL_DESIGN_REPORT.md | Designs/ | 1,405 | Complete SPEAR3 LLRF upgrade design (Rev 1) | Doc 00 §1.3/1.5, Doc 01 §2.8/2.9, Doc 02 §6–9, Doc 04 §9.5 |
| 4_HVPS_Engineering_Technical_Note.md | Designs/ | 1,877 | Complete HVPS system engineering reference | Doc 02 §7A (extensively) |
| 3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md | Designs/ | 1,277 | LLRF9 system and software | Doc 00 §1.5 |
| 10_SOFTWARE_DESIGN_DOCUMENT.md | Designs/ | 1,561 | EPICS/Python control software architecture | — |
| 11_INTERFACE_CHASSIS_DESIGN.md | Designs/ | 446 | Interface Chassis schematic-level design | Doc 02 §6 |
| 5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md | Designs/ | 415 | Klystron heater control upgrade | — |
| 8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md | Designs/ | 868 | PPS interface box design | Doc 02 §7A.8 |
| A_LEGACY_LLRF_CONTROL_SYSTEM_TECHNICAL_DESIGN.md | Designs/ | 1,424 | Legacy SNL/EPICS source code analysis | Doc 01 §8, Doc 05 §2 |

### 5.4 Legacy PDFs (legacyArchitecture/)

| PDF File | Document Number | Content | Used In |
|----------|----------------|---------|---------|
| bd3403300000.pdf | BD-340-330-00 | Overall block diagram | Doc 02 §5.1, Doc 05 §5.1 |
| bd3403300100.pdf | BD-340-330-01 | LLRF block diagram | Doc 00 §1.2 |
| feedbackLoopDescriptionps3403305200.pdf | PS-340-330-52-R0 | Feedback loop description | Doc 01 §3–11 |
| ps3403305100.pdf | PS-340-330-51-R0 | RF system description | Doc 00 §1.1 |
| ps3403305300.pdf | PS-340-330-53-R0 | Cavity calibration procedure | Doc 03 |
| ps3403305503.pdf | PS-340-330-55-R3 | Safety survey | Doc 03 |
| ps3403305600.pdf | PS-340-330-56-R0 | Coupling & cable calibration | Doc 03 |
| ps3403305700.pdf | PS-340-330-57-R0 | Full power test | Doc 03 |
| ps3403305800.pdf | PS-340-330-58-R0 | Cavity phasing | Doc 03 |
| ps3403305900.pdf | PS-340-330-59-R0 | Turn-on procedure | Doc 03 |
| ps3403306001.pdf | PS-340-330-60-R1 | Bellow cavity phasing | Doc 03 |
| ps3403306102.pdf | PS-340-330-61-R2 | Non-ionizing radiation safety | Doc 03 |

### 5.5 Published Literature

See Doc 04, Section 10 for the complete bibliography with DOIs and OSTI identifiers.

---

### 5.6 Legacy PDF Transcriptions (v2.2 — NEW)

All 15 legacy PDFs have been transcribed to searchable markdown. Located in `legacy-pdf-transcriptions/`:

| Transcription File | Source PDF | Category | Key Data Added to Technical Notes |
|--------------------|-----------|----------|----------------------------------|
| `design-specifications/PS-340-330-51_RF_System_Description.md` | `ps3403305100.pdf` | Design Spec | PEP-II nominal parameter table (Doc 00 §1.4a), equipment inventory (Doc 00 §1.4b), station configuration, cooling systems |
| `design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md` | `feedbackLoopDescriptionps3403305200.pdf` | Design Spec | Direct loop sub-functions (Doc 01 §3.2a), alternate modes (Doc 01 §3.2b), optimized station phasing (Doc 01 §10a), loop summary table |
| `block-diagrams/BD-340-330-00_PEP-II_LER_RF_Station_Block_Diagram.md` | `bd3403300000.pdf` | Block Diagram | PLC-5 I/O configuration (Doc 02 §13), DH-485 peripherals, interlock inputs, HVPS safety interfaces |
| `block-diagrams/BD-340-330-01_PEP-II_Low_Level_RF_Configuration.md` | `bd3403300100.pdf` | Block Diagram | Signal level budget (Doc 02 §12), VXI module architecture, DSP1610 ripple loop, comb filter topology |
| `block-diagrams/PEP-II_Low_Level_RF_Block_Diagram.md` | `blockDiagrambd3403290100-1.pdf` | Block Diagram | HER LLRF configuration (cross-reference to LER BD-340-330-01) |
| `operational-procedures/PS-340-330-53_RF_Cavity_Low_Power_Calibration.md` | `ps3403305300.pdf` | Oper. Proc. | Cavity calibration constants (Doc 04 §9a.1): probe coupling formula, temp/vacuum corrections |
| `operational-procedures/PS-340-330-54_RF_Station_Safety_Certification.md` | `ps3403305400.pdf` | Oper. Proc. | Safety limits (Doc 04 §9a.3): flange torque, radiation limits |
| `operational-procedures/PS-340-330-55_RF_Station_Safety_Survey.md` | `ps3403305503.pdf` | Oper. Proc. | Annual survey requirements (Doc 04 §9a.3): ionizing/non-ionizing limits |
| `operational-procedures/PS-340-330-56_RF_Station_Coupling_Cable_Calibration.md` | `ps3403305600.pdf` | Oper. Proc. | Signal path calibration data (Doc 04 §9a.2): all coupling/loss values |
| `operational-procedures/PS-340-330-57_RF_Station_Full_Power_Test.md` | `ps3403305700.pdf` | Oper. Proc. | Full power test config (Doc 04 §9a.6): SHORT plate method |
| `operational-procedures/PS-340-330-58_RF_Station_Cavity_Phasing.md` | `ps3403305800.pdf` | Oper. Proc. | Phasing parameters (Doc 04 §9a.5): waveguide spacing, phase tables |
| `operational-procedures/PS-340-330-59_RF_Station_Turn_On_Procedure.md` | `ps3403305900.pdf` | Oper. Proc. | Turn-on parameters (Doc 04 §9a.4), processing limits (Doc 01 §10b), EPICS panels (Doc 02 §14) |
| `operational-procedures/PS-340-330-60_Bellow_Cavity_Phasing.md` | `ps3403306001.pdf` | Oper. Proc. | Bellow adjustment (Doc 04 §9a.5): 0.085 inch/degree conversion |
| `operational-procedures/PS-340-330-61_RF_Non_Ionizing_Radiation_Safety.md` | `ps3403306102.pdf` | Oper. Proc. | NIR safety (Doc 04 §9a.3): waveguide pressurization, ANSI limits |

---

*This cross-reference index is designed for AI retrieval. Query any topic above to find its authoritative sources across legacy documents, published papers, source code, and extracted engineering notes.*
