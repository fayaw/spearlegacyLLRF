# Architecture Overview — PV Naming, Boot Sequence, Cross-Cutting Concerns

**Document**: 02 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis

---

## 1. PV Naming Convention

The PV namespace is one of the most critical aspects to preserve during the upgrade. Operators, archiver, alarm handlers, and higher-level applications all depend on specific PV names.

### 1.1 Macro Substitution Scheme

All PV names use EPICS macro substitution with the following variables:

| Macro | Example Value | Meaning |
|-------|--------------|---------|
| `STN` | `SRF1` | Station identifier (SPEAR RF station 1) |
| `CAV` | `1`-`4` | Cavity number |
| `RNG` | `SPEAR` | Ring identifier |
| `ID` | `2` | Region identifier |
| `REG` | `1` | Region number |
| `RRRS` | `SRF1` | Station identifier (redundant with STN in some templates) |
| `PS` | `RF-SOLN-MAIN` | Power supply identifier |

### 1.2 PV Name Patterns by Subsystem

**VXI Module Records** (from custom record types):
```
{STN}:RFP:*           — RF Processor
{STN}:GVF:*           — Gap Voltage Feed-Forward
{STN}:IQA1:*, IQA2:*, IQA3:*  — I/Q Amplitude Detectors (3 instances)
{STN}:AIM:*           — Arc Interlock Module
{STN}:CLK:*           — Clock Module
{STN}:CF2:*           — Comb Filter v2
{STN}:CFM:*           — Comb Filter v1
```

**Station Control** (from rf_states.st):
```
{STN}:STN:STATE:RBCK          — Station state readback (OFF=0, PARK=1, TUNE=2, ON_FM=3, ON_CW=4)
{STN}:STN:STATE:CTRL          — Station state control
{STN}:STN:RESET               — Station reset command
```

**HVPS Control** (from rf_hvps_loop_pvs.h):
```
{STN}:HVPS:VOLTS:RBCK         — HVPS voltage readback
{STN}:HVPS:VOLTS:CTRL         — HVPS voltage setpoint
{STN}:CONT:CLOSE              — Contactor close command
{STN}:CONT:OPEN               — Contactor open command
```

**Tuner Loop** (from rf_tuner_loop_pvs.h):
```
{STN}:CAVTUNR:LOOP:CTRL            — Master tuner loop control (all cavities)
{STN}:CAV{CAV}TUNR:LOOP:STATE      — Per-cavity tuner state (OFF=0, PARK=1, ON=2)
{STN}:CAV{CAV}TUNR:LOOP:STATUS     — Per-cavity tuner status code
{STN}:CAV{CAV}TUNR:LOOP:STRING     — Per-cavity status text
{STN}:CAV{CAV}TUNR:POSN            — Tuner position
{STN}:CAV{CAV}TUNR:POSN:CTRL       — Tuner position setpoint
{STN}:CAV{CAV}TUNR:POSN:DELTA      — Tuner position delta
{STN}:CAV{CAV}TUNR:POSN:LOOP       — Tuner loop output
{STN}:CAV{CAV}TUNR:POSN:PARKHOME   — Park home position
{STN}:CAV{CAV}TUNR:POSN:ONHOME     — On home position
{STN}:CAV{CAV}TUNR:STEP:MOTOR.*    — Stepper motor record fields
{STN}:CAV{CAV}TUNR:LOOPMEAS:READY  — Measurement ready flag
{STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR  — Load angle error severity
{STN}:CAV{CAV}LOAD:ANGLE:UNADOFFS.PROC — Phase offset processing trigger
```

**DAC Loop** (from rf_dac_loop_pvs.h):
```
{STN}:STNDAC:LOOP:STATUS     — DAC loop status code (15 states)
{STN}:STNDRV:*               — Station drive parameters
{STN}:STNGAP:*               — Station gap voltage parameters
```

**Measurement/Calculation PVs** (from subIQ.c subroutine records):
```
{STN}:KLYSOUTFRWD:POWER      — Klystron forward power
{STN}:KLYSOUTFRWD:POWER:MIN  — Minimum forward power threshold
{STN}:CAV{CAV}LOAD:ANGLE:*   — Load angle calculations
{STN}:CAV{CAV}:PHASE:*       — Cavity phase calculations
{STN}:CAV{CAV}:GAPV:*        — Gap voltage calculations
```

### 1.3 Upgrade Implication

**Critical**: Any upgrade must either:
1. **Preserve** all existing PV names exactly (preferred for minimal disruption to operators/archiver)
2. **Map** old names to new names via PV aliases or gateway (more work, allows cleanup)

The PV naming convention is baked into operator displays (MEDM/EDM screens), archiver configuration, alarm handler, and higher-level applications across the facility. Changing PV names is the highest-risk part of any upgrade.

---

## 2. IOC Boot Sequence

### 2.1 Normal Boot Flow

```
VxWorks kernel boot (PPC604)
    │
    ├── 1. Load application: ld < bin/vxWorks-ppc604_long/rf.munch
    │
    ├── 2. errlogInit(5000)
    │
    ├── 3. putenv() — set station macros:
    │       DATABASE_MACROS=STN=SRF1
    │       CLKMACROS=S=2          ← clock module slot number
    │       C1TUNRLOOP_MACROS=STN=SRF1,CAV=1,name=C1TUNRLOOP
    │       C2TUNRLOOP_MACROS=STN=SRF1,CAV=2,name=C2TUNRLOOP
    │       C3TUNRLOOP_MACROS=STN=SRF1,CAV=3,name=C3TUNRLOOP
    │       C4TUNRLOOP_MACROS=STN=SRF1,CAV=4,name=C4TUNRLOOP
    │
    ├── 4. dbLoadDatabase("dbd/rf.dbd")
    │       rf_registerRecordDeviceDriver(pdbbase)
    │
    ├── 5. dbLoadRecords("db/srf1.db") — loads all .db files via substitution
    │
    ├── 6. initHookAtBeginning → p2RfInitHooks():
    │       ├── Parse CLKMACROS to get clock slot number
    │       ├── Call p2RfInitClk(slot):
    │       │     ├── vxiinit() + InitVXIlibrary()
    │       │     ├── SetMODID(enable, 1<<slot)  ← address clock at LA=0xFF
    │       │     ├── Read hardware version
    │       │     ├── Write PLL constants (39MHz, 471MHz)
    │       │     ├── Write control register
    │       │     └── ClearMODID()
    │       └── (Clock must init BEFORE VXI resource manager runs)
    │
    ├── 7. abConfigNlinks(1)
    │       abConfigVme(0, 0xc00000, 0x60, 4)
    │       abConfigScanListAscii(0, "config.ab", 1)
    │
    ├── 8. VXI address space configuration:
    │       EPICS_VXI_LA_BASE  = 0x01
    │       EPICS_VXI_LA_COUNT = 13
    │       EPICS_VXI_A24_BASE = 0x00900000
    │       EPICS_VXI_A24_SIZE = 0x00100000  (1 MB)
    │       EPICS_VXI_A32_BASE = 0x90000000
    │       EPICS_VXI_A32_SIZE = 0x10000000  (256 MB)
    │
    ├── 9. iocInit() begins:
    │       ├── VXI resource manager (drvEpvxi.c) scans backplane
    │       ├── For each VXI module found:
    │       │     ├── P2RF_RegisterModule() checks make/model
    │       │     ├── P2RF_InitModule() resolves A16/A24 addresses
    │       │     └── Device support InitRecord() called:
    │       │           ├── Allocates XxxBoard structure
    │       │           ├── ColdInit(): reset module, load DSP, configure
    │       │           └── Or WarmInit(): sync DB to running hardware
    │       ├── Database links resolved
    │       ├── SNL programs started:
    │       │     rf_states, rf_calib, rf_tuner_loop ×4,
    │       │     rf_hvps_loop, rf_dac_loop, rf_msgs
    │       └── Scan tasks started
    │
    ├── 10. initHookAfterScanInit → p2RfInitHooks():
    │        ├── reset_kscIsr()       ← fix Kinetics Systems ISR
    │        ├── v152_wt_iack_ctrl()  ← set D16 IACK for interrupt level
    │        ├── P2RF_IntEnable()     ← enable all RF module interrupts
    │        └── taskDelay(2 seconds) ← wait for PVs to settle
    │
    └── 11. CA server starts — system operational
```

### 2.2 Boot Order Dependencies (Critical for Upgrade)

| Order | Action | Dependency | Upgrade Impact |
|-------|--------|------------|---------------|
| 1st | Clock module PLL init | Must happen BEFORE VXI resman | Clock init needs special early-boot handling in new system too |
| 2nd | AB scanner config | Must happen BEFORE iocInit | If PLCs retained, AB config still needed |
| 3rd | VXI resource manager | Must discover modules before records init | Replaced by new hardware discovery (e.g., PCIe/AXI enumeration) |
| 4th | Device support ColdInit | Loads DSP firmware, configures modules | DSP loading replaced by FPGA bitstream loading |
| 5th | Interrupt enable | Must be AFTER all modules initialized | New interrupt architecture (e.g., PCIe MSI) |
| 6th | SNL programs | Start after all records available | SNL programs can start same way in new system |

---

## 3. VxWorks-Specific Patterns

### 3.1 Fast Locking (fast_lock.h)

The codebase uses VxWorks-specific fast locking mechanisms:

```c
// VxWorks fast lock using vxTas (test-and-set) or semMCreate
FAST_LOCK lock;
FASTLOCKINIT(&lock);    // Initialize
FASTLOCK(&lock);        // Acquire
FASTUNLOCK(&lock);      // Release
```

**Upgrade**: Replace with EPICS `epicsMutex` API:
```c
epicsMutexId lock = epicsMutexCreate();
epicsMutexLock(lock);
epicsMutexUnlock(lock);
```

### 3.2 Interrupt Service Routines

ISRs use VxWorks APIs:
- `intConnect()` for interrupt vector registration
- `scanOnce()` to trigger EPICS record processing from ISR context
- `callbackRequest()` for deferred processing

**Upgrade**: Modern EPICS uses `devLib2` for interrupt registration, or device-specific APIs (e.g., Linux UIO, PCIe MSI). `scanOnce()` and `callbackRequest()` are still available in modern EPICS.

### 3.3 Task Management

```c
taskSpawn("tXxxReset", priority, options, stackSize, resetTask, ...)
taskDelay(sysClkRateGet() * seconds)
```

**Upgrade**: Replace with `epicsThread` API:
```c
epicsThreadCreate("tXxxReset", priority, stackSize, resetTask, arg);
epicsThreadSleep(seconds);
```

### 3.4 VME Bus Access

Direct VME bus register access using memory-mapped I/O:
```c
volatile unsigned short *reg = (volatile unsigned short *)baseAddr;
value = *reg;              // Read
*reg = value;              // Write
```

**Upgrade**: Replace with appropriate bus access for new hardware:
- PCIe: `devLib2` register access or device-specific driver
- AXI (FPGA): Memory-mapped via Linux mmap or UIO
- Network: EPICS asynDriver for Ethernet-based devices

---

## 4. Build System

### 4.1 Current Build

The application uses EPICS R3.13.x build system:
- Top-level `configure/` directory with RELEASE, CONFIG files
- Per-directory `Makefile` files
- VxWorks-specific compilation (68040/PPC604 cross-compile)
- DSP firmware built with TI TMS320C16xx toolchain (`Makefile.Dsp`)

### 4.2 Upgrade Build

Modern EPICS (3.15+/7.x) uses the same Makefile-based build but:
- Targets Linux instead of VxWorks
- Cross-compilation for embedded targets (RTEMS, etc.) is optional
- DSP toolchain is replaced by FPGA toolchain (Vivado/Quartus)
- SNL compiler (`snc`) is the same tool

---

## 5. Inter-Subsystem Dependencies

### 5.1 Dependency Graph

```
p2RfInitClk.c ──────► CLK module hardware
       │
       ▼
p2RfInitHooks.c ────► drvP2RfVxi.c ──► drvEpvxi.c ──► VXI backplane
                            │
                            ▼
                      ┌─────────────┐
                      │ Device      │──► DSP firmware (*.s files)
                      │ Support     │──► Table files (tbl/*.tbl)
                      │ (7 modules) │──► DDF files (*.rpt)
                      └──────┬──────┘
                             │
                      ┌──────▼──────┐
                      │ Custom      │
                      │ Records     │──► p2Rf*Def.h (register maps)
                      │ (7 types)   │──► p2RfLib.h (shared types)
                      └──────┬──────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
         ┌──────▼──────┐ ┌──▼──┐  ┌──────▼──────┐
         │ .db files   │ │ sub │  │ SNL         │
         │ (78+ files) │ │ IQ/ │  │ programs    │
         │             │ │ Sys │  │ (6 programs)│
         └─────────────┘ └─────┘  └──────┬──────┘
                                         │
                                  ┌──────▼──────┐
                                  │ AB PLC      │──► drvAb.c
                                  │ interface   │──► devABSLCDCM.c
                                  │             │──► devSmAB1746HSTP1.c
                                  └──────┬──────┘
                                         │
                                  ┌──────▼──────┐
                                  │ stepper     │
                                  │ motor       │
                                  │ Record      │
                                  └─────────────┘
```

### 5.2 What Changes When Hardware Changes

| If This Changes... | Then These Must Also Change... |
|---------------------|-------------------------------|
| VXI → FPGA/PCIe | drvP2RfVxi.c, all devP2Rf*.c, all p2Rf*Def.h, drvEpvxi.c, KSC driver, all base utilities |
| DSP → FPGA | All DSP firmware, DSP loading code in drvP2RfVxi.c, DSP comm protocol in device support |
| VxWorks → Linux | fast_lock.h, all ISR code, boot sequence, build system |
| EPICS 3.13 → 3.15+/7 | All custom records (field macros), device support (DSET changes), SNL (minor syntax), databases (record type changes) |
| AB PLC → new controller | drvAb.c, all 1771DCM/SLCDCM device support, AB-specific .db files, stepper motor driver |

