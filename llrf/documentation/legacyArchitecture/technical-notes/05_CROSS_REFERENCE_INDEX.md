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

| Topic | Legacy PDF | Published Paper | Source Code | This Package |
|-------|-----------|----------------|-------------|--------------|
| Complete loop architecture | `feedbackLoopDescriptionps3403305200.pdf` | Corredoura 1999, Fig. 3 | All `.st` | `01_...LOOPS.md` §1 |
| Direct (wideband) loop | `ps3403305200.pdf` pp.1-3 (est.) | Corredoura 1999; Fox 2010 §II | `rf_states.st` | `01_...LOOPS.md` §2 |
| Comb (narrowband) loop | `ps3403305600.pdf` | Corredoura 1999; Fox 2010 §III | `rf_calib.st` | `01_...LOOPS.md` §3 |
| Ripple loop | `ps3403305800.pdf` | Corredoura 2000 §6 | `rf_dac_loop.st` | `01_...LOOPS.md` §4 |
| Lead compensation | `ps3403305700.pdf` | — | `rf_states.st` | `01_...LOOPS.md` §5 |
| Integral compensation | `ps3403305700.pdf` | — | `rf_states.st` | `01_...LOOPS.md` §5 |
| Tuner loop | `ps3403306001.pdf` | Corredoura 1999 | `rf_tuner_loop.st` | `01_...LOOPS.md` §6 |
| DAC loop (setpoint) | `ps3403305300.pdf` | — | `rf_dac_loop.st` | `01_...LOOPS.md` §7 |
| HVPS loop (voltage) | `ps3403305400.pdf` | — | `rf_hvps_loop.st` | `01_...LOOPS.md` §8 |
| GVF / feed-forward | `ps3403305900.pdf` | Corredoura 1999 (woofer) | `rf_msgs.st` (TAXI) | `01_...LOOPS.md` §9 |
| Loop stability analysis | `ps3403305200.pdf` | Rivetta 2007; Fox 2010 | — | `01_...LOOPS.md` §10 |

### 1.3 Hardware Modules

| Topic | Legacy PDF | Published Paper | Source Code | This Package |
|-------|-----------|----------------|-------------|--------------|
| RFP module | `ps3403305100.pdf` | Corredoura 1999 | `rf_calib.st` (p2RfRfpDef.h) | `02_...HARDWARE.md` §2.1 |
| IQA modules | — | Ziomek & Corredoura 1995 | — | `02_...HARDWARE.md` §2.2 |
| Comb filter modules | `ps3403305600.pdf` | — | `rf_calib.st` | `02_...HARDWARE.md` §2.3 |
| GVF module | `ps3403305900.pdf` | — | `rf_dac_loop.st`, `rf_msgs.st` | `02_...HARDWARE.md` §2.4 |
| CLK/RF distribution | — | — | — | `02_...HARDWARE.md` §2.5 |
| ARC/Interlock (AIM) | — | — | `rf_states.st`, `rf_msgs.st` | `02_...HARDWARE.md` §2.6 |
| Drive chain / modulator | `ps3403305503.pdf` | Corredoura 2000, Figs. 4-6 | — | `02_...HARDWARE.md` §4 |
| Interface chassis | `legacyInterfaceModules/*.pdf` | — | — | `03_...CATALOG.md` §3.1 |

### 1.4 Operational Procedures

| Topic | Legacy PDF | Published Paper | Source Code | This Package |
|-------|-----------|----------------|-------------|--------------|
| System commissioning | `ps3403306102.pdf` | — | `rf_calib.st`, `rf_states.st` | — |
| Calibration sequences | `ps3403306102.pdf` | — | `rf_calib.st` | `A_LEGACY_...DESIGN.md` |
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
| `rf_states.st` | ~2500 | Master state machine (OFF→PARK→TUNE→ON_FM→ON_CW) | All loops |
| `rf_dac_loop.st` | ~1200 | DAC setpoint control, gap voltage / drive power | DAC, ripple |
| `rf_hvps_loop.st` | ~1100 | Klystron voltage regulation | HVPS |
| `rf_tuner_loop.st` | ~1200 | Cavity tuner motor control (per-cavity) | Tuner |
| `rf_calib.st` | ~2800 | Automated calibration sequences | All (Octal DAC, comb, offsets) |
| `rf_msgs.st` | ~1000 | Message logging, TAXI recovery, filament | GVF (TAXI) |

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
| Comb loop | Narrowband feedback loop with gain peaks at revolution harmonics |
| Coupled-bunch instability | Collective beam oscillation driven by cavity impedance at revolution harmonics |
| Direct loop | Wideband feedback loop that reduces effective cavity impedance |
| DSP | Digital Signal Processor — used in comb filter and ripple loop |
| EPICS | Experimental Physics and Industrial Control System — distributed control framework |
| GVF/GFF | Gap Voltage Feed-Forward — module providing voltage reference and LFB interface |
| HVPS | High Voltage Power Supply — provides klystron cathode voltage (up to 65 kV) |
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
| TAXI | Serial data link interface for fiber optic communication (GVF ↔ LFB) |
| VXI | VMEbus eXtensions for Instrumentation — modular instrument bus standard |
| Woofer | Low-frequency damping via RF station, driven by LFB system |

---

*This cross-reference index is designed for AI retrieval. Query any topic above to find its authoritative sources across legacy documents, published papers, and source code.*
