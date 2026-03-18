# Complete File Inventory — 253 Files with Upgrade Verdicts

**Document**: 01 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis

**Verdict Key**: **REMOVE** = No equivalent needed | **REFERENCE** = Behavior spec for new code | **RECREATE** = Must rewrite | **ADAPT** = Modify existing | **KEEP** = Reuse as-is

---

## Summary by Verdict

| Verdict | Files | Lines | % of Codebase |
|---------|-------|-------|---------------|
| REMOVE | 132 | ~41,000 | 50% |
| REFERENCE | 45 | ~22,000 | 27% |
| RECREATE | 52 | ~14,000 | 17% |
| ADAPT / KEEP | 24 | ~5,430 | 6% |
| **Total** | **253** | **~82,430** | **100%** |

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

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `devP2RfCf2.c` | 2,970 | REFERENCE | Largest device support. InitRecord/Action/ColdInit/WarmInit/ISR. Comb filter coefficient loading, DDF management, multiple filter banks. |
| `devP2RfRfp.c` | 2,389 | REFERENCE | RFP: octal DAC loading, DSP comm (ripple params: AMSP, PHSG, DACO, PHARM, AHARM), signal RAM read/write, mode transitions (RESET→LOAD→RUN). SpawnLdDsp, SpawnReset. |
| `devP2RfGvf.c` | 2,350 | REFERENCE | GVF: feed-forward DSP, waveform RAM, TAXI link monitoring, LFB woofer control. |
| `devP2RfIqa.c` | 2,260 | REFERENCE | IQA: I/Q register reads, DDF filter loading (F/FC/H sections), history memory capture, amplitude/phase processing. |
| `devP2RfAim.c` | 1,982 | REFERENCE | AIM: 12-channel arc detection, fast interlock chain, fault file system (NUMFFILES=11), DAS instruction execution, filament monitoring. |
| `devP2RfCfm.c` | 1,487 | REFERENCE | CFM: v1 comb filter, IIR coefficient loading from table files. |
| `devP2RfClk.c` | 957 | REFERENCE | CLK: PLL initialization, clock status monitoring. Simplest device support. |

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

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `rf_calib.st` | 3,345 | RECREATE | Largest SNL program. Octal DAC offset nulling, cavity modulator calibration, RF switch calibration. Heavy macro usage. |
| `rf_states.st` | 2,227 | RECREATE | Master state machine: OFF→INITIALIZE→STANDBY→ON_CW→FAULT→FAULT_CLEAR. Controls all other subsystems. AIM fault file handling. |
| `rf_tuner_loop.st` | 555 | RECREATE | Tuner motor control. 4 concurrent instances (C1-C4). States: IDLE→TRACKING→MOVING→SETTLING. |
| `rf_msgs.st` | 352 | RECREATE | TAXI error monitoring, event logging, heartbeat. |
| `rf_hvps_loop.st` | 343 | RECREATE | HVPS supervisory: voltage regulation, crowbar, contactor, fault monitoring via AB SLC-500. |
| `rf_dac_loop.st` | 290 | RECREATE | Drive power ramping, gap voltage regulation, DAC loop control. |

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

## 3. DSP Firmware (rfApp/src/dsp/)

### 3.1 RFP DSP (ripple rejection loop)

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

## 4. Allen-Bradley PLC Subsystem (allenBradley/)

### 4.1 Core Driver

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `drvAb.c` | 2,039 | EVALUATE | Core AB serial communication driver. If AB PLCs remain → ADAPT (community driver may exist). If PLCs replaced → REMOVE. |
| `drvAb.h` | 76 | EVALUATE | Driver API. |
| `drvAB.dbd` | 4 | EVALUATE | Driver registration. |
| `allenBradley.dbd` | 76 | EVALUATE | Combined DBD. |

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

## 5. Stepper Motor Subsystem (stepper/)

| File | Lines | Verdict | Notes |
|------|-------|---------|-------|
| `steppermotorRecord.c` | 959 | EVALUATE | Custom record type. Consider replacing with standard EPICS motor record. |
| `drvCompuSm.c` | 872 | EVALUATE | Compumotor driver — may not be used at SPEAR3. |
| `drvOms.c` | 705 | EVALUATE | Oregon Micro Systems driver — may not be used at SPEAR3. |
| `devSmCompumotor1830.c` | 82 | EVALUATE | Compumotor 1830 device support stub. |
| `devSmOms6Axis.c` | 83 | EVALUATE | OMS 6-axis device support stub. |
| `drvOms.h` | 74 | EVALUATE | OMS driver header. |
| `steppermotor.h` | 66 | EVALUATE | Stepper motor record header. |
| `steppermotorRecord.dbd` | 307 | EVALUATE | Record and device support definitions (307 lines — large). |
| `Makefile` | 24 | EVALUATE | Build. |

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

