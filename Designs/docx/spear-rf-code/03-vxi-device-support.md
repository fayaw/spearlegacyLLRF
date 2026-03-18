# VXI Driver & Device Support — Deep Dive

**Document**: 03 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**(Rev 2 — corrected for PEP-II modules and upgrade context)**

---

## UPGRADE CONTEXT

**All VXI device support code is ELIMINATED in the upgrade.** The Dimtel LLRF9/476 (2 units, 18 RF channels, FPGA-based with 270 ns loop delay) replaces the entire VXI system: RFP module, 3× IQA modules, Clock module, and all associated DSP firmware.

**PEP-II modules not active in SPEAR3**: GVF (slot 3 — empty in SRF1 crate), CF2 (slot 5 — MPS Shutoff in SRF1 crate), CFM (not in SRF1 crate). These device support files (devP2RfGvf.c, devP2RfCf2.c, devP2RfCfm.c) are PEP-II heritage code and are not discussed in detail here.

**Active SPEAR3 VXI modules** (the ones that actually ran): RFP (slot 4), IQA ×3 (slots 7/9/11), AIM (slot 12), Clock (slot 2).

This document remains valuable as **historical reference** for understanding what the LLRF9 must replicate functionally.

---

## 1. Core VXI Driver (drvP2RfVxi.c — 2,671 lines) — ELIMINATED

### 1.1 Purpose

Single point of hardware abstraction between EPICS device support and VXI backplane. Every register read/write, DSP operation, and memory transfer flows through this driver. **Replaced by LLRF9 internal firmware and EPICS IOC.**

### 1.2 Key Data Structures

**Module Registration Table** — tracks all known module types:
```c
struct {
    unsigned short  make;       // Manufacturer ID (0xf00 = SLAC PEP-II RF)
    unsigned short  model;      // Model code (0x101-0x107)
    char           *name;       // Human-readable name
    void          (*initFunc)();// Per-module init callback
    void          (*shutFunc)();// Shutdown callback
    void          (*isrFunc)(); // ISR callback
    void           *isrArg;    // ISR argument
};
```

**Per-Module Instance** — created for each physical VXI module:
```c
struct {
    unsigned short   la;        // VXI logical address
    volatile unsigned short *a16Base; // A16 register base pointer
    volatile unsigned short *a24Base; // A24 memory base pointer
    unsigned short   model;     // Module model code
    int              slot;      // Physical VXI slot number
    void            *devPvt;    // Device support private data
};
```

### 1.3 Register Access API

```c
Status P2RF_ReadVme(void *drvPvt, int registerIndex, unsigned short *value);
Status P2RF_WriteVme(void *drvPvt, int registerIndex, unsigned short value);
```

- `registerIndex` is a **word index** (byte address >> 1)
- Macros: `ADX2IDX(a)` = `(a) >> 1`, `STD2IDX(a)` = `ADX2IDX(a)`
- Each module header defines both byte (`*_A_*`) and index (`*_I_*`) constants

### 1.4 DSP Firmware Loading (P2RF_LoadDsp)

Full COFF executable parser and loader:

1. Opens file, reads COFF file header (`filehdr.h`: magic number, section count, symbol table offset)
2. Reads section headers (`scnhdr.h`: name, physical address, virtual address, size, flags)
3. Resets DSP (clears NOTDSPRST bit)
4. For each section (.text, .data, .ram, .comm):
   - Computes A24 memory offset from section physical address
   - Writes section data to DSP memory via A24 bus
5. Releases DSP from reset (sets NOTDSPRST bit)
6. DSP begins execution at `_c_int0`

### 1.5 DSP Communications Block Protocol

Shared memory region at top of DSP external RAM:

| Word | Field | Type | Description |
|------|-------|------|-------------|
| 0 | blkId | R | Block identifier (must be 0x0001) |
| 1 | vers | R | Version (must be 0x0001) |
| 2 | chkSum | R | Checksum |
| 3 | status | R | DSP status code |
| 4-11 | sttArg[8] | R | Status arguments |
| 12 | dspMsg | R | Message FROM DSP to CPU |
| 13 | dspArg | R | Argument from DSP |
| 14 | cpuMsg | W | Message FROM CPU to DSP |
| 15 | cpuArg | W | Argument from CPU |
| 16 | comLen | R | Block size |

**Command Protocol** (from dspCmdDef.h):

| Code | Name | Direction | Used By |
|------|------|-----------|---------|
| 0x0000 | CMD_K_NOOP | — | All |
| 0x0001 | CMD_K_READY | DSP→CPU | All — DSP reports boot complete |
| 0x0002 | CMD_K_TEST | both | Diagnostic |
| 0x0003 | CMD_K_ERROR | DSP→CPU | All — DSP error condition |
| 0x0004 | CMD_K_LDTBL | CPU→DSP | RFP, GVF — load coefficient tables |
| 0x0005 | CMD_K_SVDATA | DSP→CPU | RFP — DSP requests data save |
| 0x0006 | CMD_K_APHASE | — | RFP — save average phase |
| 0x0007 | CMD_K_LDREF | CPU→DSP | RFP — load reference tables |
| 0x0008 | CMD_K_UREF | CPU→DSP | RFP — update reference tables |
| 0x000a | CMD_K_AMSP | CPU→DSP | RFP — update ripple amplitude setpoint |
| 0x000b | CMD_K_PHSG | CPU→DSP | RFP — update ripple DC Z⁻¹ phase gain |
| 0x000c | CMD_K_DACO | CPU→DSP | RFP — load ripple DAC offsets (II,IQ,QI,QQ) |
| 0x000d | CMD_K_PHARM | CPU→DSP | RFP — ripple phase harmonic coefficients |
| 0x000e | CMD_K_AHARM | CPU→DSP | RFP — ripple amplitude harmonic coefficients |
| 0xFFFF | CMD_K_DONE | both | All — operation complete acknowledgment |

### 1.6 Table and Memory Operations

| Function | Description |
|----------|-------------|
| `P2RF_LoadTblFile()` | Load waveform/coefficient table from file into module A24 memory |
| `P2RF_LoadRegFile()` | Load register values from a text file (register_index value pairs) |
| `P2RF_LoadConsts()` | Load constant array into A24 memory |
| `P2RF_LoadCoefs()` | Load coefficient array into A24 memory |
| `P2RF_LoadDdf()` | Load Digital Data Filter definition (F, FC[257], H1, H2 registers) |
| `P2RF_RecordMemory()` | Copy A24 memory to a file (waveform capture) |
| `P2RF_CopyMemory()` | Copy A24 memory to a CPU buffer |
| `P2RF_SaveDspMemory()` | Save DSP memory range to file |

### 1.7 Interrupt Architecture

- Global enable/disable: `P2RF_IntEnable()`, `P2RF_IntDisable()`
- Per-module: `P2RF_ModIntEnable(drvPvt)`, `P2RF_ModIntDisable(drvPvt)`
- Interrupt level: `P2RF_K_INTLEVEL` (typically 5)
- ISR dispatch: `P2RF_IntServRtn()` reads interrupt status register → calls module-specific ISR

**Atomic Register Access**: The driver uses software interrupts to perform atomic read-modify-write on shared registers, avoiding the non-portable Motorola CAS2 instruction.

### 1.8 Upgrade Impact

**REMOVE** entirely. But extract these specifications for the new system:
- DSP communication protocol → new FPGA register/mailbox protocol
- Table file format → new coefficient loading mechanism
- Interrupt dispatch pattern → new interrupt architecture
- Module registration concept → new device enumeration

---

## 2. Device Support Module Pattern

All 7 modules follow an identical pattern. Understanding one deeply means understanding all.

### 2.1 Common Structure

```c
// Device Support Entry Table (DSET)
struct {
    long       number;          // 5
    DEVSUPFUN  report;          // NULL
    DEVSUPFUN  init;            // NULL
    DEVSUPFUN  init_record;     // → InitRecord()
    DEVSUPFUN  get_ioint_info;  // NULL
    DEVSUPFUN  action;          // → Action()
} devP2RfXxx;

// Per-board private data
typedef struct {
    void           *drvPvt;      // Driver private (VXI address info)
    P2RfXxxRecord  *rec;         // Back-pointer to EPICS record
    XxxRstBlk       resetBlk;    // Async reset control block
    XxxDspMsgBlk    dspMsgBlk;   // DSP message callback block
    XxxDspBlk       dspBlk;      // DSP load control block
    XxxRamBlk       getRamBlk;   // RAM read control block
    XxxRamBlk       ldRamBlk;    // RAM write control block
    unsigned int    intPrc;      // Interrupt processing counter
    // Module-specific parameters...
} XxxBoard;
```

### 2.2 Lifecycle

```
1. IOC startup
   └── InitRecord() called for each record instance
       ├── calloc(1, sizeof(XxxBoard))
       ├── P2RF_InitModule(drvPvt, slot)
       ├── Setup ISR: P2RF_RegisterIsr(drvPvt, XxxIsr, board)
       ├── Setup async callbacks: callbackSetCallback(), callbackSetUser()
       ├── if (coldStart) → ColdInit():
       │     ├── Write interrupt control register
       │     ├── Set module to LOAD mode
       │     ├── Load DSP firmware from file (rec->dspe field)
       │     ├── Load coefficient/table files
       │     ├── Configure control registers
       │     ├── Set module to RUN mode
       │     └── Boot DSP (release from reset)
       └── else → WarmInit():
             └── Read all registers, sync DB fields to hardware state

2. Normal operation
   └── Hardware interrupt fires
       └── XxxIsr():
           ├── Read interrupt status register
           ├── Update rec->istt (interrupt status field)
           ├── For DSP messages: callbackRequest(dspMsgBlk)
           ├── board->intPrc++
           └── scanOnce(rec)  ← triggers EPICS record processing

3. Record processing
   └── Action() called by EPICS scan system
       ├── if (intPrc > 0): Process interrupt-driven updates
       │     ├── Read status registers
       │     ├── Update DB fields
       │     └── Post events to monitors
       ├── Check for operator-requested changes:
       │     ├── Mode change → write control register
       │     ├── Loop enable/disable → set/clear bits
       │     ├── DAC value change → write DAC register + verify
       │     ├── DSP parameter change → write to comm block
       │     ├── DSP load request → SpawnLdDsp() (async)
       │     ├── RAM read request → SpawnGetHist() (async)
       │     └── Module reset → SpawnReset() (async)
       └── Return status
```

---

## 3. RFP Device Support (devP2RfRfp.c — 2,389 lines)

### 3.1 Operating Modes

| Mode | Value | Description | Allowed Operations |
|------|-------|-------------|-------------------|
| rfpReset | 0 | Module in reset | None — module powered down |
| rfpLoad | 1 | Load mode | Program DSP, load tables, modify DACs, configure registers |
| rfpRun | 2 | Run mode | Feedback loops active, DAC output, waveform capture |

### 3.2 Octal DAC Array

The RFP module has a 2×2 I/Q matrix of DACs per cavity, plus compensation loop and master drive:

| DAC Group | DACs | Purpose |
|-----------|------|---------|
| Cavity 1 | C1II, C1IQ, C1QI, C1QQ | Cavity 1 coupling matrix |
| Cavity 2 | C2II, C2IQ, C2QI, C2QQ | Cavity 2 coupling matrix |
| Cavity 3 | C3II, C3IQ, C3QI, C3QQ | Cavity 3 coupling matrix |
| Cavity 4 | C4II, C4IQ, C4QI, C4QQ | Cavity 4 coupling matrix |
| Comp Loop | CLCII, CLCIQ, CLCQI, CLCQQ | Compensation loop matrix |
| Master | MDRV | Master drive level (v2+ boards) |

Total: **21 DAC channels** (on v2+ boards with MDRV)

Each DAC write sequence:
1. Compute hardware value: `hwVal = (dbVal + RFP_K_OCTDACOS) << RFP_V_OCTDAC`
2. Write to DAC register: `P2RF_WriteVme(drvPvt, dacIndex, hwVal)`
3. Read back and verify: `P2RF_ReadVme(drvPvt, dacIndex, &readback)`
4. If mismatch: log error, set alarm

### 3.3 DSP Parameter Downloads

After DSP boots (reports CMD_K_READY), the DspMsgCallback loads all runtime parameters:

| Parameter | Command | Data Source | Description |
|-----------|---------|-------------|-------------|
| Amplitude Setpoint | CMD_K_AMSP | rec->amsp | Ripple rejection amplitude target |
| Phase Gain | CMD_K_PHSG | rec->phsg | DC Z⁻¹ phase gain coefficient |
| DAC Offsets | CMD_K_DACO | rec->dcoii/iq/qi/qq | 4 DAC offset values (II,IQ,QI,QQ) |
| Phase Harmonics | CMD_K_PHARM | rec->ph01-ph16 | 16 phase harmonic coefficients |
| Amplitude Harmonics | CMD_K_AHARM | rec->ah01-ah16 | 16 amplitude harmonic coefficients |

### 3.4 Signal RAM Operations

6 signal memories available for waveform capture:

| Memory | Index | Description |
|--------|-------|-------------|
| sigI | rec->sigIPrm | Signal I component |
| sigQ | rec->sigQPrm | Signal Q component |
| cavI | rec->cavIPrm | Cavity I component |
| cavQ | rec->cavQPrm | Cavity Q component |
| dacI | rec->dacIPrm | DAC I output |
| dacQ | rec->dacQPrm | DAC Q output |

Each can be read from hardware (for waveform display) or loaded from file (for injection).

---

## 4. IQA Device Support (devP2RfIqa.c — 2,260 lines)

### 4.1 DDF (Digital Data Filter) Loading

The IQA uses configurable digital filters defined in DDF files:

```
DDF File Structure:
  F register:        1 word  — filter type/mode
  FC coefficients:   1-257 pairs (lo,hi) — filter coefficients (up to 512 taps)
  H1 register:       1 word  — filter parameter 1
  H2 register:       1 word  — filter parameter 2
```

Loaded by `P2RF_LoadDdf()` which writes to IQA filter registers in A16 space.

### 4.2 Channel Multiplexing

Each IQA module has a channel select mux that chooses which RF signal to measure. Three IQA instances typically monitor:
- IQA1: Forward power
- IQA2: Reflected power  
- IQA3: Cavity probe

### 4.3 History Memory

Each IQA has onboard history memory that captures time-series I/Q data. The `GetHist` operation reads this memory for waveform display. Data is read in blocks of `P2RF_K_BLKSIZE` (1024) words.

---

## 5. AIM Device Support (devP2RfAim.c — 1,982 lines)

### 5.1 Arc Detection (12 Channels)

The AIM monitors 12 arc detection channels. Each channel has:
- Enable/disable bit
- Threshold setting
- Latched fault status
- Fault count

Board versions affect channel count:
- Version 0: Fewer channels (early boards)
- Version 1+: Full 12 channels

### 5.2 Fast Interlock Chain

The AIM participates in a daisy-chained fast interlock system:
- Input: Receives interlock signal from upstream
- Output: Passes interlock to downstream (or trips it)
- Response time: < 1 µs hardware trip

### 5.3 Fault File System

```
Configuration: aimDas0.inst, aimDas1.inst (DAS instruction files)
  — Define what data to capture on fault

Fault files: /dat/FAULTSigI_00 through /dat/FAULTSigI_10
  — Circular buffer of 11 fault dumps
  — Each contains: signal RAM (I,Q), cavity RAM, DAC RAM, metadata

Trigger: AIM interrupt → ISR sets fault flag → rf_states.st transitions to FAULT
  → fault dump sequence captures all signal memories
```

### 5.4 BATS (Beam Abort Trip Signal)

Monitors the beam abort interlock and can trigger RF shutdown if beam is dumped.

---

## 6. GVF Device Support (devP2RfGvf.c — 2,350 lines)

### 6.1 Feed-Forward Function

The GVF compensates for beam loading by anticipating changes based on gap timing:
- Receives gap timing from TAXI serial link
- DSP computes feed-forward correction waveform
- Outputs correction via DAC to modulate RF drive

### 6.2 TAXI Link Interface

The TAXI (Transparent Asynchronous Xmitter/Receiver Interface) provides:
- Serial data link between modules
- Timing synchronization
- Status monitoring (link up/down, error rate)
- Monitored by rf_msgs.st for error detection

### 6.3 LFB Woofer

Low-Frequency Bunch-by-bunch feedback woofer function:
- Provides low-frequency correction signal
- Complementary to the high-frequency bunch-by-bunch feedback system

---

## 7. CF2 Device Support (devP2RfCf2.c — 2,970 lines)

Largest device support module. Complex coefficient management:

### 7.1 Multiple Filter Banks

CF2 supports multiple filter bank configurations:
- Each bank has its own set of IIR coefficients
- Runtime bank switching allows different filter characteristics
- Coefficients loaded from table files at initialization

### 7.2 Coefficient Loading Protocol

1. Set module to LOAD mode
2. Write coefficient count to configuration register
3. Write coefficient pairs (numerator/denominator) to coefficient registers
4. Set module to RUN mode
5. Verify coefficient readback

---

## 8. Upgrade Impact Summary

| Component | Lines | What to Extract for New System |
|-----------|-------|-------------------------------|
| drvP2RfVxi.c | 2,671 | DSP comm protocol, table file formats, interrupt dispatch pattern |
| devP2RfRfp.c | 2,389 | Octal DAC loading sequence, DSP parameter list, signal RAM operations, mode transitions |
| devP2RfGvf.c | 2,350 | Feed-forward algorithm interface, TAXI link handling, LFB woofer control |
| devP2RfIqa.c | 2,260 | DDF filter structure, channel mux, history memory capture |
| devP2RfAim.c | 1,982 | Arc detection (12 channels), fault file system, DAS instruction format, BATS handling |
| devP2RfCf2.c | 2,970 | Multi-bank coefficient management, IIR filter loading protocol |
| devP2RfCfm.c | 1,487 | V1 comb filter coefficients (simpler than CF2) |
| devP2RfClk.c | 957 | PLL configuration algorithm, ClkConsts(r,a,m,p) macro |
