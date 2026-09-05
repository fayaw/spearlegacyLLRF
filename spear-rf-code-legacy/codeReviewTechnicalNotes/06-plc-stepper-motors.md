# PLC Integration & Stepper Motors


> **⚠ Galil status — corrected September 2026.** The Galil DMC-4143 has **not** been installed and is **not** in operation; it was in development. Test moves were performed on the existing cavity motors and worked fine, but it goes online only **when the current LLRF upgrade project is finished**. The **AB 1746-HSTP1 remains the in-service tuner controller**. Any statement below that this work is "already done" or that the Galil "replaced" the AB hardware is incorrect and has been amended.

**Document**: 06 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**(Rev 2 — corrected with upgrade context)**

---

## UPGRADE CONTEXT

| Legacy | Lines | Upgrade | Status |
|--------|-------|---------|--------|
| AB drvAb.c serial driver | 2,039 | **ELIMINATED** | All new PLCs use Ethernet/IP |
| AB SLC-500 (HVPS) | — | CompactLogix PLC (Ethernet) | PDR §6.3 |
| AB PLC-5 (RF MPS) | — | ControlLogix 1756 (Ethernet) | PDR §7.3 |
| AB 1746-HSTP1 stepper | 1,673 | **IN SERVICE** — Galil DMC-4143 planned but not installed | PDR §10.3 |
| Compumotor / OMS drivers | — | **ELIMINATED** — never used in SPEAR3 | Historical |

---

## 1. Allen-Bradley Remote I/O Architecture — ELIMINATED

### 1.1 Physical Configuration

The link is Allen-Bradley **Remote I/O (RIO)**, not Data Highway+. `iocBoot/b132-iocrf/config.ab,v` is headed "Allen-Bradley **Remote I/O** Scanner Configuration" and the VXI slot-1 card is an **AB 6008-SV1R VMEbus Remote I/O scanner** (see `allenBradley/documentation/allenBradley.html,v`, which lists models 6008-SV / 6008-SV1R / 6008-SV2R as "VMEbus Scanner Remote I/O Scanner"). The PLCs are RIO *adapters* ("racks"), reached through their DCM modules — they are not network peers.

Rack sizes, from `config.ab,v`:

```
1 0 Full
2 0 3/4
3 0 1/4
```

Adapter identity, from `rfApp/Db/rf_ab_4CV.substitutions,v` (the 4-cavity SPEAR3 configuration instantiated by `srf1.substitutions,v`):

```
Adapter 1 (Full) : HVPSDCM   — HVPS SLC-500 via 1747-DCM  (B118)
                   cards 0,2,4,6,8,10,12,14 + HVPSDCM:SUMY
Adapter 2 (3/4)  : CAVTUNR   — cavity tuner stepper chassis 340-315 (B132)
                   cards 0,2,4,6 = CAV1TUNR..CAV4TUNR + CAVTUNR:SUMY
Adapter 3 (1/4)  : STNDCM    — RF MPS PLC-5 via 1771-DCM  (B132)
                   card 0 = STN:DCM, data tables T0..T7
```

> **Note**: it is easy to mis-assign rack 1 to the RF MPS, rack 2 to the HVPS, and rack 3 to the steppers. That is wrong on all three counts. The assignment above is read directly from `rf_ab_4CV.substitutions,v`, where the `ab_adapter.db` pattern gives `{HVPSDCM, 1}`, `{CAVTUNR, 2}`, `{STNDCM, 3}`. The number of cards per adapter independently corroborates the rack sizes.

The AB scanner (VME adapter card in VXI slot 1, reached through an HP E1407A VME-to-VXI adapter) polls all three adapters at roughly 1 Hz.

### 1.2 Communication Flow

```
EPICS Records ──DSET──► AB Device Support ──► drvAb.c ──RIO──► AB 6008-SV1R Scanner
                                                                      │
                                      ┌───────────────────────────────┘
                                      │
                        ┌─────────────┼──────────────┐
                        │             │              │
                   ┌────▼────┐  ┌─────▼────┐  ┌─────▼────┐
                   │ Rack 1  │  │ Rack 2   │  │ Rack 3   │
                   │ HVPS PLC│  │ Tuners   │  │ RF MPS   │
                   │(SLC-500)│  │ (4×HSTP1)│  │ (PLC-5)  │
                   └─────────┘  └──────────┘  └──────────┘
```

---

## 2. Core AB Driver (drvAb.c — 2,039 lines)

### 2.1 Configuration API

| Function | Description |
|----------|-------------|
| `abConfigNlinks(n)` | Set number of AB serial links (typically 1) |
| `abConfigVme(link, baseAddr, intVector, intLevel)` | Configure VME adapter card |
| `abConfigScanListAscii(link, filename, verbose)` | Load scanner config from file |
| `abConfigAuto(link)` | Auto-discover devices on link |

### 2.2 Runtime Operation

The `abDrv()` task:
1. Initializes AB adapter card
2. Configures scan list from file
3. Enters polling loop:
   - For each configured adapter/group:
     - Send scan request
     - Wait for response (with timeout)
     - Copy data to/from device support buffers
   - Handle block transfers (for HSTP1 stepper modules)
   - Monitor link health
   - Retry on communication errors

### 2.3 Addressing Scheme

AB I/O is addressed by adapter (rack), group, and module (slot):
```
adapter = rack number (1-3)
group   = group number (0-3, typically 0)
module  = module slot within rack
```

### 2.4 Upgrade Consideration

**If AB PLCs are retained**: Modern EPICS has community-supported AB drivers:
- `ether_ip` — Ethernet/IP driver for ControlLogix/CompactLogix
- The existing serial AB driver is very old and specific to VME adapter cards
- Migration to Ethernet/IP would eliminate the VME scanner card entirely

**If AB PLCs are replaced**: All AB code is removed.

---

## 3. PLC-5 / 1771-DCM Device Support (~2,500 lines)

### 3.1 abDcmRecord.c (779 lines)

Custom EPICS record type for AB Data Communications Module (DCM). Supports block transfers for bulk data exchange with PLC-5.

Fields:
- Link, adapter, group, module addressing
- Block transfer size
- Data buffer (array of shorts)
- Status and error tracking

### 3.2 Standard Record Device Support

| File | Lines | Record Type | Function |
|------|-------|-------------|----------|
| `devAiAbDcmi2f.c` | 316 | ai | Analog input with integer-to-float conversion |
| `devAoAbDcmi2f.c` | 180 | ao | Analog output with float-to-integer conversion |
| `devAiAbDcm.c` | 141 | ai | Raw analog input |
| `devAoAbDcm.c` | 155 | ao | Raw analog output |
| `devBiAbDcm.c` | 161 | bi | Binary input |
| `devBoAbDcm.c` | 155 | bo | Binary output |
| `devMbbiAbDcm.c` | 160 | mbbi | Multi-bit binary input |
| `devMbboAbDcm.c` | 154 | mbbo | Multi-bit binary output |
| `devLiAbDcm.c` | 137 | longin | Long integer input |
| `devLoAbDcm.c` | 156 | longout | Long integer output |

Each device support module:
1. Parses INP/OUT link field for AB addressing (link, adapter, group, module, word, bit)
2. During init: registers with drvAb for scan list inclusion
3. During processing: reads/writes from shared memory buffer maintained by drvAb

### 3.3 PLC Simulator (plcSimulate.c — 155 lines)

A testing utility that simulates PLC responses without actual hardware. Used for lab development.

---

## 4. SLC-500 Device Support (563 lines)

### 4.1 devABSLCDCM.c

Handles communication with the Allen-Bradley SLC-500 PLC used as the HVPS controller.

The SLC-500 manages:
- **HVPS voltage regulation**: Setpoint → SCR gate driver → beam voltage
- **Crowbar protection**: Arms and monitors the crowbar circuit
- **Contactor control**: Opens/closes the HV contactor
- **Cooling system**: Monitors water flow, temperature
- **Analog I/O**: Voltage readback, current readback, temperature sensors

### 4.2 Data Mapping

AB SLC-500 data is mapped to EPICS records via the database files:
```
rf_hvps.db       — HVPS voltage, current, contactor, crowbar PVs
rf_analog.db     — PLC analog inputs (temperatures, pressures)
rf_digital_plc.db — PLC digital inputs (status bits)
rf_digital_hvps.db — HVPS-specific digital I/O
rf_interlock.db  — PLC interlock channels
```

---

## 5. AB Binary I/O (devABBINARY.c — 618 lines)

Generic Allen-Bradley binary I/O device support. Supports:
- Direct digital I/O modules
- Status word reading
- Module health monitoring

The `devABStatus.c` (102 lines) specifically reads the AB adapter status words for diagnostics.

---

## 6. Stepper Motor Module — 1746-HSTP1 (1,673 lines)

### 6.1 Purpose

Controls the Allen-Bradley 1746-HSTP1 stepper motor modules used for cavity tuner positioning. Each of the 4 cavities has one stepper motor.

### 6.2 Communication Protocol

The 1746-HSTP1 uses AB block transfers:

```
CPU → HSTP1 (command block):
  Word 0: Command code (MOVE, STOP, HOME, STATUS)
  Word 1: Target position (32-bit, split across 2 words)
  Word 2: Velocity
  Word 3: Acceleration
  Word 4: Deceleration
  Word 5: Mode (absolute/relative)

HSTP1 → CPU (status block):
  Word 0: Status bits (DONE, MOVING, FAULT, LIMIT+, LIMIT-)
  Word 1: Current position (32-bit, split across 2 words)
  Word 2: Error code
```

### 6.3 Motion Sequence

```c
// 1. Initialize
ab1746HSTP1_init(card, adapter, group, module)
  → Configure block transfer parameters
  → Set default velocity, acceleration

// 2. Start motion
ab1746HSTP1_start_trans(card, position, velocity)
  → Write command block via AB block transfer
  → Set MOVE command
  → Wait for transfer complete

// 3. Monitor
ab1746HSTP1_query(card, &status, &position)
  → Read status block via AB block transfer
  → Extract DONE flag, current position

// 4. Complete
ab1746HSTP1_end_trans(card)
  → Clean up block transfer
  → Verify final position
```

### 6.4 Integration with steppermotorRecord

The custom `steppermotorRecord.c` (959 lines) interfaces with the 1746-HSTP1 driver:

**Record Fields**:
- `VAL`: Target position (engineering units)
- `RBV`: Readback position (actual)
- `DMOV`: Done moving flag
- `DRVH` / `DRVL`: Drive limits (high/low)
- `RDBD`: Retry deadband
- `VELO`: Velocity
- `ACCL`: Acceleration

**Processing**:
1. New target position written to VAL
2. Record converts engineering units to steps
3. Calls device support start_trans()
4. Polls for done (DMOV)
5. Reads back position
6. If outside deadband: retries move
7. If at limit: sets alarm

### 6.5 Alternative Drivers (not used at SPEAR3 but present)

| Driver | Lines | Hardware | Status |
|--------|-------|----------|--------|
| `drvCompuSm.c` | 872 | Parker Compumotor 1830 | Available but not configured for SPEAR3 |
| `drvOms.c` | 705 | Oregon Micro Systems | Available but not configured for SPEAR3 |

---

## 7. Upgrade Impact

### 7.1 If AB PLCs are Retained

| Component | Action | Effort |
|-----------|--------|--------|
| drvAb.c | Replace with `ether_ip` (Ethernet/IP) | Medium — different protocol |
| 1771DCM device support | Replace with `ether_ip` device support | Medium |
| SLC-500 device support | Replace with `ether_ip` or dedicated driver | Medium |
| 1746-HSTP1 driver | Evaluate: keep custom or use community motor record | Medium |
| config.ab | Replace with Ethernet/IP configuration | Small |
| .db files | Adapt record types for new driver | Small |

### 7.2 If AB PLCs are Replaced

| Component | Action | Effort |
|-----------|--------|--------|
| All AB code | REMOVE | Zero |
| HVPS control | Rewrite for new controller | Large |
| MPS PLC | Rewrite for new PLC | Large |
| Stepper motors | Use standard EPICS motor record + new driver | Medium |

### 7.3 Stepper Motor Recommendation

The custom `steppermotorRecord` should be **replaced by the standard EPICS motor record** (`motorRecord` from the EPICS motor module). The motor record:
- Supports many driver backends
- Is actively maintained by the EPICS community
- Provides equivalent functionality (deadband, limits, backlash, etc.)
- Has standardized PV naming (.VAL, .RBV, .DMOV, .VELO, .ACCL, etc.)

If the physical stepper motors and 1746-HSTP1 modules are retained, a custom asyn driver for the motor record can replace `devSmAB1746HSTP1.c`.
