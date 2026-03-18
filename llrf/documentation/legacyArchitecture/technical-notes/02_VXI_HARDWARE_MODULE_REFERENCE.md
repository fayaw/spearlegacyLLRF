# PEP-II / SPEAR3 LLRF VXI Hardware Module Reference

**Document Number**: LLRF-REF-003
**Version**: 1.0
**Date**: 2026-03-18
**Reconstructed From**: Corredoura SLAC-PUB-8498, arXiv:physics/0007029, Legacy source code, Legacy PDF file metadata

---

## 1. VXI Crate Module Inventory

The PEP-II LLRF system is housed in a standard VXI mainframe. For SPEAR3 (single station, HER configuration), the typical module complement is:

### 1.1 Module List

| Slot | Module | Drawing Prefix | Function |
|------|--------|---------------|----------|
| 0 | Slot 0 μProcessor | — | VXI bus controller, EPICS IOC host (VxWorks RTOS) |
| 1 | CLK/RF Distribution | — | Master clock, LO generation (471.1 MHz), RF reference distribution |
| 2 | RFP (RF Processor) | ps340330** | Central feedback processing module |
| 3 | IQA-1 (IQ/AMP Detector) | — | Digital IQ demodulator + amplitude detector |
| 4 | IQA-2 (IQ/AMP Detector) | — | Digital IQ demodulator + amplitude detector |
| 5 | IQA-3 (IQ/AMP Detector) | — | Digital IQ demodulator + amplitude detector |
| 6 | Comb Filter (I) | — | Digital comb filter for I-channel |
| 7 | Comb Filter (Q) | — | Digital comb filter for Q-channel |
| 8 | GVF (Gap Voltage Feed-Forward) | — | Gap voltage reference + LFB woofer interface |
| 9 | ARC/Interlock Detector | — | Arc detection, interlock management, beam abort |
| 10-12 | Spare | — | Available for expansion |

**Source**: Corredoura SLAC-PUB-8498, Fig. 1 (VXI crate topology)
**Cross-ref PDF**: `bd3403300000.pdf`, `bd3403300100.pdf`, `blockDiagrambd3403290100-1.pdf`

### 1.2 RF Signal Inputs (24 total per station)

From Corredoura 2000 Fig. 1, the station has:
- **476 MHz reference** input
- **Cavity probes (×4)** — one per cavity
- **Station RF inputs (24)** — various monitor points throughout the RF chain
- **HVPS trigger** output
- **RF output** to drive amplifier
- **Interlocks** — multiple hardware interlock signals
- **471.1 MHz LO** distribution
- **Fiber optic links** — to/from longitudinal feedback (TAXI interface)

---

## 2. Module Detailed Descriptions

### 2.1 RFP (RF Processor) Module

The RFP module is the **heart of the LLRF system**. It contains:

**Analog Signal Processing**:
- IQ demodulators for cavity probe signals
- Vector summing network (sums 4 cavity IQ signals)
- Direct loop error amplifier and gain stage
- Lead compensation network
- Integral compensation network
- Baseband modulator (4 × Gilbert-cell multipliers in 2×2 matrix)
- IQ RF modulator (upconversion to 476 MHz)

**Digital Control**:
- Octal DACs (12-bit, ±2048 counts) for:
  - Tune mode IQ setpoints
  - Operate mode IQ setpoints (difference node)
  - GFF (Gap Feed-Forward) IQ reference values
  - Klystron modulator matrix coefficients (I-I, I-Q, Q-I, Q-Q)
  - Ripple loop coefficients
- Mode control: TUNE / OPERATE switching
- RF switch: Enable/disable RF output
- DSP interface for ripple loop
- Built-in history buffer (circular buffer, freeze on fault)

**Source Code Interface PVs** (from `rf_dac_loop_pvs.h`, `rf_calib.st`):
```
{STN}:RFP:TUNESTPT:I     — Tune mode I setpoint (Octal DAC)
{STN}:RFP:TUNESTPT:Q     — Tune mode Q setpoint (Octal DAC)
{STN}:RFP:DIFFNODE:I     — Operate mode I offset (Octal DAC)
{STN}:RFP:DIFFNODE:Q     — Operate mode Q offset (Octal DAC)
{STN}:RFP:RFSWITCH        — RF output enable/disable
{STN}:RFP:RUNMODE         — TUNE/OPERATE mode select
{STN}:RFP:DIRECTLOOP      — Direct loop enable/disable
{STN}:RFP:LEADCOMP        — Lead compensation enable/disable
{STN}:RFP:INTCOMP         — Integral compensation enable/disable
{STN}:RFP:COMBLOOP        — Comb loop enable/disable
```

**Cross-ref PDF**: `ps3403305100.pdf` (11 pages) — likely the main RFP module specification

### 2.2 IQA (IQ/Amplitude Detector) Modules

Three IQA modules provide precision digital measurement of RF signals:

**Function**: Digital IQ demodulation (down-conversion + filtering) producing:
- I component (in-phase)
- Q component (quadrature)
- Amplitude = √(I² + Q²)
- Phase = arctan(Q/I)

**Technology**: Custom digital down-converter ASIC/FPGA. From Ziomek & Corredoura, "Digital I/Q Demodulator," PAC 1995.

**Channel allocation** (typical):
- IQA-1: Klystron drive power monitoring
- IQA-2: Cavity probe signals (multiplexed or summed)
- IQA-3: Additional monitor points

**Key Features**:
- High accuracy phase/amplitude measurement
- Linear detector output (used for drive power limiting)
- Part of the built-in network analyzer system

### 2.3 Comb Filter Modules (I and Q)

Two identical comb filter modules, one for each IQ component:

**Architecture**:
- FIFO memory for one-revolution-turn delay
- Accumulator/feedback path
- Programmable gain
- Load/Run control modes
- History buffer

**Key Parameters**:
- Delay length: Programmable (must match revolution period)
- Gain: Software-adjustable via PV
- Bandwidth per tooth: Determined by gain setting

### 2.4 GVF (Gap Voltage Feed-Forward) Module

**Functions**:
1. Store and output IQ reference values for gap voltage target
2. Interface to longitudinal feedback (LFB) via fiber optic TAXI link
3. LFB "woofer" signal summing into station drive
4. TAXI error monitoring and resync capability

**Source Code Interface**: Referenced in `rf_dac_loop_pvs.h` as `gvf_module_sevr` for module health monitoring.

### 2.5 CLK/RF Distribution Module

**Functions**:
- Generate Local Oscillator (471.1 MHz for PEP-II)
- Distribute 476 MHz reference
- Provide sampling clocks to IQA modules
- Master timing reference

### 2.6 ARC/Interlock Detector Module (AIM)

From `rf_states.st` and `rf_msgs.st`:

**Functions**:
- Beam abort force/reset interface
- Filament control
- HVPS permissive signals
- Fault history buffers (written to disk files on fault)
- Station fault word monitoring

**Fault file capability** (from Corredoura):
> "In the event of a fault, fast history buffers throughout the system write selected rf signals to disk files which can be viewed later to help diagnose problems."

Fault file types (from `rf_states.st`):
```
/dat/FAULTI_        — I-channel history
/dat/FAULTQ_        — Q-channel history
/dat/FAULTCmbI_     — Comb filter I history
/dat/FAULTCmbQ_     — Comb filter Q history
```

---

## 3. Interconnection Summary

### 3.1 RF Signal Path

```
476 MHz Reference ──▶ CLK/RF Dist ──▶ RFP (reference input)
                                   └──▶ IQA modules (reference)

Cavity Probes (×4) ──▶ RFP (vector sum) ──▶ Direct Loop Error
                   └──▶ IQA modules (individual cavity measurement)

RFP RF Output ──▶ Drive Amplifier (120W) ──▶ Klystron Input
```

### 3.2 Digital/Control Path

```
VXI Bus ◄──▶ All modules (register access, data transfer)
Ethernet ◄──▶ Slot 0 μProcessor ◄──▶ EPICS Channel Access
Fiber Optic ◄──▶ GVF Module ◄──▶ Longitudinal Feedback System
HVPS Trigger ◄──▶ AIM ──▶ HVPS SCR Gate Control
Interlocks ◄──▶ AIM ──▶ Machine Protection System
```

### 3.3 Cross-Reference to Legacy Interface Module PDFs

| PDF File | Content |
|----------|---------|
| `SD-340-308-01-R1-1of1.pdf` | Interface module schematic (sheet 1) |
| `SD-340-308-02-R1.pdf` | Interface module schematic (sheet 2) |
| `sd3403090102.pdf` | Interface module pinout/connector |

Located in: `llrf/documentation/legacyInterfaceModules/`

---

## 4. Drive Chain Details

### 4.1 Analog Drive Chain (from Corredoura 2000, Fig. 4 and Fig. 6)

```
                                    ┌──────────────────┐
  Octal DAC  ──▶ Quad DAC Gain ──▶│ Baseband         │
  (I/Q setpts)                     │ Modulator        │
                                   │ (4× Gilbert-cell │
  Direct Loop ─▶ Gain Stage ──────▶│  multipliers)    │──▶ Voltage-to-
  Error Signal   (with limiter)    │                  │    Current Amp
                                   │ I-I  I-Q         │
  Phase Adjust ─▶ Rotation ──────▶│ Q-I  Q-Q         │     │
  (Quad DAC)     Matrix            └──────────────────┘     │
                                                            ▼
                                                    ┌──────────────┐
                 ┌──── Fixed Attenuators ◄──────────┤ IQ RF        │
                 │                                   │ Modulator    │
                 │                                   │ (476 MHz)    │
                 ▼                                   └──────────────┘
         ┌──────────────┐                                   │
         │ 120 W Power  │◄──────────────────────────────────┘
         │ Amplifier    │
         │ (solid state)│
         └──────┬───────┘
                │
                ▼
           To Klystron
```

### 4.2 Key Component Specifications

| Component | Specification | Critical Limit |
|-----------|--------------|----------------|
| Gilbert-cell multipliers | ±1V max input | Overdrive causes polarity inversion |
| Quad DAC (gain tracking) | 12-bit | Sets 2×2 modulator matrix |
| Octal DAC (setpoints) | 12-bit, ±2048 counts | I/Q reference values |
| Drive amplifier | 120 W solid state | Fixed gain |
| Fixed attenuators | Station-specific | Set operating point on klystron curve |
| Limiting diodes | 1N4157 Schottky | Soft limiter at ±1V |

---

*See also: `01_FEEDBACK_LOOP_ARCHITECTURE.md` for loop details.*
*See also: `03_LEGACY_PDF_CATALOG.md` for complete PDF inventory.*
