# Complete File Inventory — 253 Files with Upgrade Verdicts

**Document**: 01 of 09 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**(Rev 3 — corrected legacy state machine names in rf_states.st entry)**

**Verdict Key**: **ELIMINATED** = Replaced by LLRF9 or new hardware | **PEP-II ONLY** = Not used in SPEAR3 | **SPEC-EXTRACT** = Behavior spec for upgrade software | **REFERENCE** = Behavior spec for new code | **REUSE** = Directly reusable | **DONE** = Already replaced

---

## CORRECTION NOTICE (Rev 2)

- **CFM, GVF/GFF, CF2 modules are PEP-II heritage, NOT active in SPEAR3.** The SPEAR3 VXI crate contains only: CPU, AB Scanner, Clock, RFP, 3× IQA, AIM. Software loaded GVF/CF2 databases from PEP-II template, but the physical modules are not installed.
- **DSP firmware is ELIMINATED** — the LLRF9 FPGA replaces all DSP functions. These files are reference for understanding what the LLRF9 does internally, but no migration is needed.
- **rf_dac_loop.st is ELIMINATED** — LLRF9 handles DAC/vector modulator control internally.
- **Stepper motor code is ALREADY DONE** — Galil DMC-4143 commissioned August 2025.

## Summary by Verdict (Revised)

| Verdict | Files | Lines | % | Description |
|---------|-------|-------|---|-------------|
| ELIMINATED (LLRF9/new HW) | ~80 | ~35,000 | 42% | VXI driver, active device support, DSP, custom records |
| PEP-II ONLY (not SPEAR3) | ~30 | ~10,000 | 12% | GVF, CFM, CF2 modules and associated code |
| OBSOLETE INFRASTRUCTURE | ~60 | ~15,000 | 18% | VxWorks, KSC, VXI bus, base utilities |
| SPEC EXTRACTION | ~30 | ~11,000 | 13% | SNL programs, HVPS/tuner logic, interlocks |
| REUSABLE | ~10 | ~1,500 | 2% | subIQ.c, subSys.c, state definitions |
| PV REFERENCE | 78+ | ~15,000 | 18% | EPICS databases and substitution files |
| ALREADY DONE | ~5 | ~2,700 | 3% | Stepper motor (Galil commissioned) |
| **Total** | **253** | **~82,430** | **100%** | |

---

## 1. Custom Record Types & Device Support (rfApp/src/db/)

### 1.1 Core VXI Driver

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `drvP2RfVxi.c` | 2,671 | REMOVE→REF | Central hub. P2RF_ReadVme/WriteVme, DSP loading, table I/O, interrupt dispatch. The DSP comm protocol and table format specs are REFERENCE. |
| `drvP2RfVxi.h` | 191 | REMOVE→REF | Public API: P2RF_InitModule, P2RF_LoadDsp, P2RF_LoadTblFile, P2RF_IntEnable, etc. |

### 1.2 Register Definition Headers

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `p2RfRfpDef.h` | 565 | REFERENCE | RFP registers: RFCTRL, INTCTRL, INTSTAT, octal DAC addresses. Mode bits (DIRLPENB, CMBLPENB, RIPLPENB, RFENB). Interrupt sources. Version checks. |
| `p2RfIqaDef.h` | 509 | REFERENCE | IQA registers: I/Q data, filter control, DDF configuration. Largest header — most complex module register map. |
| `p2RfCf2Def.h` | 403 | REFERENCE | CF2 registers: comb filter coefficients, group delay equalizer, filter bank control. |
| `p2RfAimDef.h` | 390 | REFERENCE | AIM registers: 12-channel arc detect, interlock chain, BATS, fault history, DAS control. |
| `p2RfGvfDef.h` | 330 | REFERENCE | GVF registers: feed-forward control, TAXI link, waveform output, LFB woofer. |
| `p2RfCfmDef.h` | 279 | REFERENCE | CFM registers: v1 comb filter, IIR coefficient loading. |
| `p2RfClkDef.h` | 271 | REFERENCE | CLK registers: PLL configuration (39 MHz, 471 MHz), clock control. ClkConsts(r,a,m,p) macro. |

### 1.3 Custom Record Implementations

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `p2RfCf2Record.c` | 366 | RECREATE | CF2 record fields: mode, coefficients, filter bank, DDF, waveform arrays. |
| `p2RfCfmRecord.c` | 334 | RECREATE | CFM record fields: similar to CF2 but fewer features. |
| `p2RfGvfRecord.c` | 307 | RECREATE | GVF record fields: feed-forward, TAXI, waveform, LFB. |
| `p2RfIqaRecord.c` | 301 | RECREATE | IQA record fields: I, Q, amplitude, phase, DDF, filter select. |
| `p2RfAimRecord.c` | 300 | RECREATE | AIM record fields: arc channels, interlock, BATS, fault files. |
| `p2RfClkRecord.c` | 299 | RECREATE | CLK record fields: PLL constants, clock status. |
| `p2RfRfpRecord.c` | 296 | RECREATE | RFP record fields: mode, loop enables, DACs, DSP params, signal RAM. |

### 1.4 Device Support Modules

**Active in SPEAR3** (replaced by LLRF9):

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `devP2RfRfp.c` | 2,389 | ELIMINATED | RFP: octal DAC loading, DSP comm, signal RAM read/write, mode transitions. **Replaced by LLRF9 FPGA.** Reference for understanding legacy RF feedback behavior. |
| `devP2RfIqa.c` | 2,260 | ELIMINATED | IQA: I/Q register reads, DDF filter loading, history memory capture. **Replaced by LLRF9 ADC/DSP.** |
| `devP2RfAim.c` | 1,982 | ELIMINATED | AIM: 12-channel arc detection, fast interlock, fault files. **Replaced by Interface Chassis + Microstep-MIS arc detection.** Reference for interlock specification. |
| `devP2RfClk.c` | 957 | ELIMINATED | CLK: PLL initialization, clock status. **Replaced by LLRF9 internal clock.** |

**PEP-II heritage — NOT active in SPEAR3**:

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `devP2RfCf2.c` | 2,970 | **PEP-II ONLY** | CF2 module not installed in SPEAR3 VXI crate (slot 5 = MPS Shutoff, not CF2). |
| `devP2RfGvf.c` | 2,350 | **PEP-II ONLY** | GVF module not installed in SPEAR3 VXI crate (slot 3 = empty). Feed-forward was PEP-II specific. Per PDR §15.7: "used for PEP-II, not SPEAR3." |
| `devP2RfCfm.c` | 1,487 | **PEP-II ONLY** | CFM comb filter module. Per PDR §15.7: "used for PEP-II multi-bunch stabilization, not applicable to SPEAR3." |

### 1.5 Shared Library & Subroutines

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `p2RfLib.h` | 126 | REFERENCE | Shared types: P2RfCvtBlk (conversion), P2RfDdf (digital filter), P2RfBufDsc (buffer). Constants: P2RF_K_RFFREQ=476MHz, harmonic numbers (PEPII=3492, SPEAR3=372). |
| `subIQ.c` | 965 | **KEEP** | 23 pure-math functions. No hardware dependency. Direct reuse. |
| `subSys.c` | 464 | **KEEP** | 11 system-level calculations. Minor hardware refs (AB reset) can be isolated. |

### 1.6 Initialization Support

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `p2RfInitClk.c` | 247 | REMOVE→REF | Pre-resman clock init via MODID/slot addressing. Writes PLL constants before VXI resource manager runs. Boot order dependency. |
| `p2RfInitHooks.c` | 128 | REMOVE→REF | EPICS initHook callbacks: clock init at initHookAtBeginning, interrupt enable at initHookAfterScanInit, V152 IACK register config. |
| `fast_lock.h` | 162 | REMOVE | VxWorks-specific fast mutual exclusion (vxTas, semMCreate). Replace with epicsMutex. |
| `rf_station_state.h` | 7 | **KEEP** | Simple #defines: STATION_OFF=0, PARK=1, TUNE=2, ON_FM=3, ON_CW=4. |

---

## 2. SNL State Machines (rfApp/src/seq/)

### 2.1 State Machine Programs

| File | Lines | Verdict | Upgrade Target | Notes |
|------|-------|---------|---------------|-------|
| `rf_states.st` | 2,227 | **SPEC-EXTRACT** | Python/EPICS coordinator | Master state machine with 5 primary states: **OFF→PARK→TUNE→ON_FM→ON_CW** (per `rf_station_state.h`: OFF=0, PARK=1, TUNE=2, ON_FM=3, ON_CW=4) and 17 transition states (s_go_off, s_go_park, s_go_tune, s_go_on_fm, s_go_on_cw, s_go_tune_to_on_cw, s_comb_ramp, s_direct_ramp, s_gv_up, s_gv_down, s_lp_check, s_faultfiles, s_go_stn_reset, s_go_tickleoff, s_go_tickleon, go_on_cw_to_tune, go_on_fm_to_tune). 3 state sets: rf_states (main), rf_statesLP (loop protection), rf_statesFF (fault files). **Primary specification for the upgrade coordinator.** |
| `rf_hvps_loop.st` | 343 | **SPEC-EXTRACT** | CompactLogix PLC code | HVPS supervisory: voltage regulation, crowbar, contactor. **Specification for new PLC ladder logic.** |
| `rf_tuner_loop.st` | 555 | **SPEC-EXTRACT** | LLRF9 tuner + Python load-angle | Tuner motor control. 4 instances. **LLRF9 has built-in tuner PVs; Python handles load-angle offset.** |
| `rf_calib.st` | 3,345 | REFERENCE | LLRF9 built-in calibration | Largest SNL. DAC offset nulling, cavity modulator calibration. **LLRF9's Dmitry software handles calibration.** Verify equivalence. |
| `rf_msgs.st` | 352 | REFERENCE | EPICS logging + LLRF9 diag | TAXI error monitoring, event logging, heartbeat. Behavior reference for upgrade diagnostics. |
| `rf_dac_loop.st` | 290 | **ELIMINATED** | LLRF9 internal | Drive power/gap voltage DAC loop. Per PDR §15.7: **"LLRF9 controls all via single vector sum"** — this loop is eliminated. |

### 2.2 SNL Support Headers

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `rf_dac_loop_macs.h` | 197 | REFERENCE | DAC_LOOP_SET macro (100+ lines) — core DAC control logic. |
| `rf_dac_loop_pvs.h` | 158 | REFERENCE | PV assignments: {STN}:STNDAC:*, {STN}:STNDRV:*, {STN}:STNGAP:*. |
| `rf_tuner_loop_pvs.h` | 136 | REFERENCE | PV assignments: {STN}:CAV{CAV}TUNR:POSN:*, {STN}:CAV{CAV}TUNR:STEP:MOTOR.*. |
| `rf_hvps_loop_pvs.h` | 135 | REFERENCE | PV assignments: {STN}:HVPS:*, {STN}:CONT:*. |
| `rf_hvps_loop_macs.h` | 135 | REFERENCE | HVPS control macros. |
| `rf_tuner_loop_macs.h` | 90 | REFERENCE | TUNER_LOOP_POSN_STATUS, TUNER_LOOP_STATE_UPDATE macros. |
| `rf_hvps_loop_defs.h` | 81 | REFERENCE | HVPS status definitions (UNKNOWN, READY, ON, OFF, FAULT). |
| `rf_tuner_loop_defs.h` | 80 | REFERENCE | Tuner loop constants: LOOP_MEAS_COUNT=3, LOOP_MOVE_COUNT=100, SM_DONE_MOVING=1. |
| `rf_dac_loop_defs.h` | 71 | REFERENCE | DAC loop status codes (15 states), max DAC counts=2047. |
| `rf_loop_defs.h` | 15 | REFERENCE | Shared loop definitions: LOOP_CONTROL_ON/OFF, LOOP_INVALID_SEVERITY. |
| `rf_loop_macs.h` | 13 | REFERENCE | Shared loop macros. |
| `rfSeq.dbd` | 6 | RECREATE | SNL registration: 6 program declarations. |
| `Makefile` | 51 | RECREATE | Build instructions for SNL programs. |

---

## 3. DSP Firmware (rfApp/src/dsp/) — ALL ELIMINATED BY LLRF9

> **NOTE**: All DSP firmware is **ELIMINATED** in the upgrade. The LLRF9 FPGA (Xilinx Spartan-6 or Artix-7) replaces all DSP functions with 270 ns loop delay digital processing. Per PDR §15.7, the ripple rejection loop is specifically eliminated because "LLRF9 digital feedback inherently rejects power-line ripple." These files serve only as historical reference for understanding what the LLRF9 does internally.

### 3.1 RFP DSP (ripple rejection loop) — ELIMINATED

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `ripple_phaseoff.s` | 1,157 | REFERENCE | Ripple loop with phase offset — most recent variant. 23 kHz loop rate, I/Q signal processing, harmonic estimation (fast+slow), DAC correction. |
| `ripple.s` | 1,144 | REFERENCE | Original ripple loop without phase offset. |
| `sp3ripple.s` | 1,103 | REFERENCE | SPEAR3-specific variant (harmonic number 372 vs PEPII 3492). |
| `lusqrt.s` | 1,064 | REFERENCE | Fixed-point unsigned square root via lookup table. |
| `sqlu.s` | 1,024 | REFERENCE | Alternate unsigned square root implementation. |
| `dspmemtest.s` | 315 | REMOVE | DSP memory test — diagnostic only. |
| `loadDacs.s` | 183 | REFERENCE | DAC loading sequence from memory tables. |
| `rampDacs.s` | 188 | REFERENCE | Gradual DAC ramp-up/ramp-down for klystron protection. |
| `constDacs.s` | 153 | REFERENCE | Constant DAC output mode. |
| `zeroDacs.s` | 151 | REFERENCE | Zero all DACs safely. |
| `comBlk.s` | 147 | REFERENCE | Communications block template — shared memory protocol between CPU and DSP. |
| `dsptest.s` | 138 | REMOVE | Diagnostic test program. |
| `dspSos.s` | 135 | REFERENCE | Second-order section (SOS) digital filter. |
| `vecTbl.s` | 113 | REFERENCE | Interrupt vector table. |
| `regInit.s` | 98 | REFERENCE | Register initialization sequence. |
| `tst.s` | 14 | REMOVE | Tiny test stub. |
| `ripple.ex` | 8 | REMOVE | Linker export file. |
| Headers: `aucDef.h`, `bioDef.h`, `comDef.h`, `dspDef.h`, `intDef.h`, `pioDef.h`, `timDef.h`, `vecDef.h` | ~485 | REFERENCE | Register/interrupt/timer definitions for TMS320C16xx. |
| `Makefile`, `Makefile.Dsp`, `qCvt.c` | ~212 | REMOVE | Build system and q-format conversion utility. |

### 3.2 GVF DSP (feed-forward)

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `wave_out.s` | 1,298 | REFERENCE | Waveform output from DAC memory. |
| `gvff.s` | 1,199 | REFERENCE | Gap voltage feed-forward calculation core. |
| `comBlk.s` | 389 | REFERENCE | GVF-specific communications block (larger than RFP). |
| `dspmemtest.s` | 315 | REMOVE | Diagnostic. |
| `dsptest.s` | 136 | REMOVE | Diagnostic. |
| `regInit.s` | 101 | REFERENCE | GVF register init. |
| `sndMsg.s` | 82 | REFERENCE | Send message from DSP to CPU. |
| `endCode.s` | 55 | REFERENCE | End-of-program marker. |
| Headers: `aucDef.h`, `bioDef.h`, `comDef.h`, `dspDef.h`, `gvff.h`, `gvffMisc.h`, `funcs.h`, `intDef.h`, `jtgDef.h`, `pioDef.h`, `sttDef.h`, `timDef.h` | ~883 | REFERENCE | GVF-specific register definitions. |
| `ifile`, `ifile_sim` | 24 | REMOVE | Linker include files. |
| `Makefile*` | ~79 | REMOVE | Build system. |

### 3.3 Observer DSP

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `takeDat.s` | 450 | REFERENCE | Data acquisition and I/Q processing loop. |
| `apTOiq.s` | 218 | REFERENCE | Amplitude/phase to I/Q conversion. |
| `ldCirBuf.s` | 202 | REFERENCE | Circular buffer loading. |
| `iqTOap.s` | 195 | REFERENCE | I/Q to amplitude/phase conversion. |
| `atan.s` | 184 | REFERENCE | Arctangent function (fixed-point). |
| `regSave.s` | 141 | REFERENCE | Register save/restore for context switching. |
| `dspSos.s` | 135 | REFERENCE | SOS filter (shared with rfpDsp). |
| `Equaliz.s` | 123 | REFERENCE | Equalization filter. |
| `adapt.s` | 115 | REFERENCE | Adaptive filtering algorithm. |
| `vecTbl.s` | 114 | REFERENCE | Interrupt vector table. |
| `averPhas.s` | 85 | REFERENCE | Phase averaging. |
| `Makefile*` | ~69 | REMOVE | Build system. |

### 3.4 Generic Shared DSP

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `sqrt2.s` | 153 | REFERENCE | Square root function (signed). |
| `sin.s` | 92 | REFERENCE | Sine via lookup table. |
| `cos.s` | 96 | REFERENCE | Cosine via lookup table. |
| `comBlk.s` | 112 | REFERENCE | Generic communications block. |
| Headers: `comDef.h`, `dspCmdDef.h`, `dspDef.h`, `funcs.h`, `intDef.h`, `jtgDef.h`, `macros.h`, `pioDef.h`, `sttDef.h`, `timDef.h` | ~612 | REFERENCE | Shared DSP definitions. |
| `Makefile` | 13 | REMOVE | Build. |

---

## 4. Allen-Bradley PLC Subsystem (allenBradley/) — ELIMINATED

> **NOTE**: ALL AB serial communication code is **ELIMINATED**. Per PDR §2.3: HVPS controller → CompactLogix PLC (Ethernet/IP), RF MPS → ControlLogix 1756 (Ethernet/IP), Tuner motors → Galil DMC-4143 (Ethernet). No AB serial scanner in the upgrade. All new PLCs communicate via Ethernet, not the VME AB scanner card.

### 4.1 Core Driver

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `drvAb.c` | 2,039 | **ELIMINATED** | AB serial communication driver. Replaced by Ethernet/IP to CompactLogix/ControlLogix. |
| `drvAb.h` | 76 | **ELIMINATED** | Driver API. |
| `drvAB.dbd` | 4 | **ELIMINATED** | Driver registration. |
| `allenBradley.dbd` | 76 | **ELIMINATED** | Combined DBD. |

### 4.2 PLC-5 / 1771-DCM Device Support

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `abDcmRecord.c` | 779 | EVALUATE | Custom DCM record type for block transfers. |
| `devAiAbDcmi2f.c` | 316 | EVALUATE | AI with integer-to-float conversion. |
| `devAoAbDcmi2f.c` | 180 | EVALUATE | AO with float-to-integer conversion. |
| `devBiAbDcm.c` | 161 | EVALUATE | Binary input. |
| `devMbbiAbDcm.c` | 160 | EVALUATE | Multi-bit binary input. |
| `devLoAbDcm.c` | 156 | EVALUATE | Long output. |
| `devBoAbDcm.c` | 155 | EVALUATE | Binary output. |
| `devAoAbDcm.c` | 155 | EVALUATE | Analog output. |
| `plcSimulate.c` | 155 | EVALUATE | PLC simulator for testing. |
| `devMbboAbDcm.c` | 154 | EVALUATE | Multi-bit binary output. |
| `devAiAbDcm.c` | 141 | EVALUATE | Analog input. |
| `devLiAbDcm.c` | 137 | EVALUATE | Long input. |
| `abDcmRecord.dbd` | 131 | EVALUATE | DCM record definition. |
| `abDcm.h` | 47 | EVALUATE | DCM header. |
| `devABDCM.dbd` | 15 | EVALUATE | Device support registration. |

### 4.3 SLC-500 Device Support

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `devABSLCDCM.c` | 563 | EVALUATE | SLC-500 data comm module driver. Used for HVPS PLC. |
| `devABSLCDCM.dbd` | 7 | EVALUATE | Registration. |
| `devABSLC500DCM.dbd` | 6 | EVALUATE | Registration. |

### 4.4 AB Binary I/O

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `devABBINARY.c` | 618 | EVALUATE | Generic AB binary I/O device support. |
| `devABBINARY.dbd` | 20 | EVALUATE | Registration. |
| `devABStatus.c` | 102 | EVALUATE | AB adapter status. |
| `devABStatus.dbd` | 4 | EVALUATE | Registration. |

### 4.5 Stepper Motor Module

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `devSmAB1746HSTP1.c` | 1,673 | EVALUATE | AB 1746-HSTP1 stepper motor module driver. Most complex AB device support. Block transfer protocol for motion control. |
| `devSmAB1746Hstp.dbd` | 3 | EVALUATE | Registration. |

---

## 5. Stepper Motor Subsystem (stepper/) — ALREADY REPLACED

> **NOTE**: The stepper motor system has been **ALREADY REPLACED** by a Galil DMC-4143 4-axis motion controller, commissioned August 2025. Per PDR §10.3: "The tuner motor controller is being replaced with a modern motion controller." The Galil uses EPICS motor records over Ethernet. All legacy stepper motor code is historical only.

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `steppermotorRecord.c` | 959 | **DONE** | Custom stepper record → replaced by standard EPICS motor record + Galil DMC-4143. |
| `devSmAB1746HSTP1.c` | 1,673 | **DONE** | AB 1746-HSTP1 driver → replaced by Galil Ethernet driver. |
| `drvCompuSm.c` | 872 | **DONE** | Compumotor driver — not used at SPEAR3, historical only. |
| `drvOms.c` | 705 | **DONE** | Oregon Micro Systems — not used at SPEAR3, historical only. |
| Other files | ~560 | **DONE** | Headers, stubs, build files — all historical. |

---

## 6. VXI Infrastructure (epvxi/)

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `drvEpvxi.c` | 4,622 | REMOVE | VXI resource manager. Largest file in codebase. Module discovery, A16/A24/A32 addressing, device tables. |
| `drvEpvxiMsg.c` | 1,529 | REMOVE | VXI word-serial messaging protocol. |
| `epvxi.h` | 532 | REMOVE | VXI framework API. |
| `drvEpvxi.h` | 474 | REMOVE | VXI driver internals. |
| `drvHp1404a.c` | 393 | REMOVE | HP 1404a VXI instrument driver (not RF-related). |
| `drvExampleVxi.c` | 240 | REMOVE | Example VXI driver. |
| `drvHp1404a.h` | 56 | REMOVE | HP 1404a header. |
| `Makefile` | 23 | REMOVE | Build. |
| `epvxi.dbd` | 1 | REMOVE | Registration. |

---

## 7. Base Utilities (rfApp/src/base/)

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `vbb.c` | 2,398 | REMOVE | VXI Bus Browser — interactive debugging utility. |
| `dlt.c` | 1,008 | REMOVE | Download Table utility. |
| `bus.c` | 855 | REMOVE | VME bus access routines. |
| `sgl.c` | 731 | REMOVE | Signaling/messaging library. |
| `lip.c` | 582 | REMOVE→REF | Load In Place — firmware loading technique. Loading concept may apply to FPGA. |
| `dld.c` | 575 | REMOVE | Download DSP utility. |
| `memTest.c` | 451 | REMOVE | Memory test routines. |
| `lstLib.c` | 285 | REMOVE | Linked list library (VxWorks-era utility). |
| `ethShow.c` | 276 | REMOVE | Ethernet diagnostics. |
| `initModule.c` | 212 | REMOVE | Module initialization helper. |
| `busMap.c` | 202 | REMOVE | Bus address mapping. |
| `rfBaseRegister.c` | 165 | REMOVE | Base function registration. |
| `mvxLib.c` | 158 | REMOVE | MV166 board-specific library. |
| `mapAdx.c` | 119 | REMOVE | Address mapping utility. |
| `bootFix.c` | 114 | REMOVE | VxWorks boot parameter fix. |
| `time.c` | 85 | REMOVE | Time utility (VxWorks-specific). |
| `sgl.msg` | 112 | REMOVE | Signal library messages. |
| `bus.msg` | 97 | REMOVE | Bus library messages. |
| `lip.msg` | 82 | REMOVE | LIP messages. |
| `dtl.msg` | 74 | REMOVE | DTL messages. |
| `dwn.msg` | 138 | REMOVE | Download messages. |
| `mtl.msg` | 65 | REMOVE | Memory test messages. |
| Headers (34 files): `DSP.h`, `busLib.h`, `dsLib.h`, `dspCmdDef.h`, `dspLib.h`, `dwnLib.h`, `e02Lib.h`, `filehdr.h`, `filter.h`, `frc40Lib.h`, `genLib.h`, `hbLib.h`, `hkv4fLib.h`, `lipDef.h`, `lipLib.h`, `lstLib-unix.h`, `memTest.h`, `mibDef.h`, `misc.h`, `modTypes.h`, `mtlLib.h`, `mv166Lib.h`, `mvxLib.h`, `params.h`, `r250.h`, `ramdata.h`, `ricDefs.h`, `scnhdr.h`, `sglLib.h`, `sglSts.h`, `time.h`, `vxiDef.h`, `vxiLib.h`, `vxiSts.h` | ~3,700 | REMOVE (mostly) | `dspCmdDef.h` (65 lines) and `dspLib.h` (278 lines) are REFERENCE — they define the CPU↔DSP command protocol. `modTypes.h` (132 lines) defines module type IDs. `filehdr.h`/`scnhdr.h` (171 lines) define COFF file format. |
| `rfBase.dbd` | 1 | REMOVE | Registration. |
| `Makefile` | 50 | REMOVE | Build. |

---

## 8. Diagnostics (rfApp/src/diag/)

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `rf_vxi_diag.c` | 2,328 | REMOVE→REF | VXI module diagnostic routines. Tests register access, interrupt generation, DSP communication, memory integrity. Reference for what diagnostics the new system needs. |

---

## 9. IOC Main & Build (rfApp/src/rf/)

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `rfMain.cpp` | 21 | RECREATE | IOC main entry point. Trivial — just calls `iocInit()`. |
| `Makefile` | 57 | RECREATE | Build configuration. |

---

## 10. EPICS Databases (rfApp/Db/) — 78 files

See **[07-epics-databases.md](07-epics-databases.md)** for full analysis. All database files are **RECREATE** — the PV names and logic must be preserved but record types and links will change.

---

## 11. IOC Boot Configuration (iocBoot/)

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `st.cmd` | ~100 | RECREATE | IOC startup script. New hardware addressing, new database loading. |
| `config.ab` | ~60 | EVALUATE | AB scanner configuration (rack/group mapping). Keep if PLCs remain. |
| `srf1.substitutions` | ~80 | RECREATE | Macro definitions for station SRF1: STN=SRF1, slot assignments, 4-cavity config. |
| 57 table files (tbl/) | varies | **KEEP** | Waveform tables, DDF filter definitions, IIR coefficients. Physics data — reusable if data format compatible. |
