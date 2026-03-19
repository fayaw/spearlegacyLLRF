# PEP-II / SPEAR3 LLRF VXI Hardware Module Reference

**Document Number**: LLRF-REF-003
**Version**: 2.0
**Date**: 2026-03-19
**Reconstructed From**: Corredoura SLAC-PUB-8498, arXiv:physics/0007029, Legacy source code, Legacy PDF file metadata

---

## 1. VXI Crate Module Inventory

The PEP-II LLRF system is housed in a standard VXI mainframe. For SPEAR3 (single station, HER configuration), the typical module complement is:

### 1.1 Module List

| Slot | Module | Drawing Prefix | Function | SPEAR3 Status |
|------|--------|---------------|----------|---------------|
| 0 | Slot 0 μProcessor | — | VXI bus controller, EPICS IOC host (VxWorks RTOS) | **Active** |
| 1 | CLK/RF Distribution | — | Master clock, LO generation (471.1 MHz), RF reference distribution | **Active** |
| 2 | RFP (RF Processor) | ps340330** | Central feedback processing module | **Active** |
| 3 | IQA-1 (IQ/AMP Detector) | — | Digital IQ demodulator + amplitude detector | **Active** |
| 4 | IQA-2 (IQ/AMP Detector) | — | Digital IQ demodulator + amplitude detector | **Active** |
| 5 | IQA-3 (IQ/AMP Detector) | — | Digital IQ demodulator + amplitude detector | **Active** |
| 6 | Comb Filter (I) | — | Digital comb filter for I-channel | ⚠️ **PEP-II ONLY — not used in SPEAR3** |
| 7 | Comb Filter (Q) | — | Digital comb filter for Q-channel | ⚠️ **PEP-II ONLY — not used in SPEAR3** |
| 8 | GVF (Gap Voltage Feed-Forward) | — | Gap voltage reference + LFB woofer interface | ⚠️ **PEP-II ONLY — not used in SPEAR3** |
| 9 | ARC/Interlock Detector | — | Arc detection, interlock management, beam abort | **Active (but not functional)** |
| 10-12 | Spare | — | Available for expansion | — |

> ⚠️ **IMPORTANT**: The Comb Filter Modules (CFM, slots 6-7) and Gap Voltage Feed-Forward module (GVF/GFF, slot 8) are **PEP-II design elements only**. These modules were **never used in the SPEAR3 RF plant** (1999–2022 legacy system) and are **not present in the LLRF9 upgrade** (2022–present). They were physically present in the VXI crate as inherited hardware but were not populated or connected in the SPEAR3 configuration. All references to comb filter loops, GVF/GFF feed-forward, and LFB woofer interfaces in this documentation describe PEP-II functionality for historical/reference purposes only.

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

Three IQA modules provide precision digital measurement of RF signals (SPEAR3/HER configuration). In the LER configuration, only **2 IQA modules** were used (2 cavities per LER station vs. 4 per HER/SPEAR3 station).

> **Source**: BD-340-330-01 (LER: 2 IQA), BD-340-329-01 (HER: 3 IQA + 1 per additional cavity pair)

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

### 2.3 Comb Filter Modules (I and Q) — ⚠️ PEP-II ONLY

> **These modules are PEP-II hardware only. They were NOT used in the SPEAR3 legacy system (1999–2022) and are NOT present in the LLRF9 upgrade. This section is retained for historical reference.**

Two identical comb filter modules, one for each IQ component:

**Architecture** (PEP-II):
- FIFO memory for one-revolution-turn delay
- Accumulator/feedback path
- Programmable gain
- Load/Run control modes
- History buffer

**Key Parameters** (PEP-II):
- Delay length: Programmable (must match revolution period — 136.3 kHz for PEP-II)
- Gain: Software-adjustable via PV
- Bandwidth per tooth: Determined by gain setting

**Why not used in SPEAR3**: SPEAR3's beam loading is moderate compared to PEP-II (500 mA vs 3 A). The direct feedback loop alone provides sufficient coupled-bunch mode suppression. The comb filter was essential for PEP-II's dense revolution harmonic spectrum.

### 2.4 GVF (Gap Voltage Feed-Forward) Module — ⚠️ PEP-II ONLY

> **This module is PEP-II hardware only. It was NOT used in the SPEAR3 legacy system (1999–2022) and is NOT present in the LLRF9 upgrade. This section is retained for historical reference.**

**Functions** (PEP-II):
1. Store and output IQ reference values for gap voltage target
2. Interface to longitudinal feedback (LFB) via fiber optic TAXI link
3. LFB "woofer" signal summing into station drive
4. TAXI error monitoring and resync capability

**Why not used in SPEAR3**: SPEAR3 is a single RF station without LFB integration. Gap voltage control is handled by the DAC control loop in the VxWorks IOC software.

**Source Code Interface**: Referenced in `rf_dac_loop_pvs.h` as `gvf_module_sevr` for module health monitoring (code present but module not connected in SPEAR3).

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

Fault file types (13 channels, from `rf_states.st`):
```
/dat/FAULTRfpSI_    — RFP station I-channel history
/dat/FAULTRfpSQ_    — RFP station Q-channel history
/dat/FAULTRfpCI_    — RFP comb I-channel history
/dat/FAULTRfpCQ_    — RFP comb Q-channel history
/dat/FAULTCf2I_     — Comb filter 2 I-channel history
/dat/FAULTCf2Q_     — Comb filter 2 Q-channel history
/dat/FAULTCmbI_     — Comb I-channel history
/dat/FAULTCmbQ_     — Comb Q-channel history
/dat/FAULTIqa1Amp_  — IQA module 1 amplitude history
/dat/FAULTIqa2Amp_  — IQA module 2 amplitude history
/dat/FAULTIqa3Amp_  — IQA module 3 amplitude history
/dat/FAULTGvf_      — GVF module history
/dat/FAULTAim_      — AIM module history
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
  Direct Loop ─▶ Gain Stage ─────▶│  multipliers)    │──▶ Voltage-to-
  Error Signal   (with limiter)    │                  │    Current Amp
                                   │ I-I  I-Q         │
  Phase Adjust ─▶ Rotation ──────▶│ Q-I  Q-Q         │     │
  (Quad DAC)     Matrix            └──────────────────┘     │
                                                            ▼
                                                    ┌──────────────┐
                 ┌──── Fixed Attenuators ◄──────────┤ IQ RF        │
                 │                                  │ Modulator    │
                 │                                  │ (476 MHz)    │
                 ▼                                  └──────────────┘
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

## 5. Legacy Communication Architecture For SPEAR3

> **Reconstructed from**: `llrf/documentation/LLRFDocumentationNotesR2.docx` (J. Sebek, November 2021)

### 5.1 Allen-Bradley Serial Communication Chain

The legacy system uses a daisy-chained serial communication architecture:

```
VXI Crate (B132)          MPS Rack (B132)              HVPS (B118)
┌──────────────┐          ┌──────────────┐             ┌──────────────┐
│ AB VME       │──serial──│ PLC-5 Main   │──serial──┐  │ SLC-500 HVPS │
│ Scanner      │          │ (1771 DCM)   │          │  │ (1747-DCM)   │
│ (VXI Slot)   │          ├──────────────┤          │  └──────┬───────┘
└──────────────┘          │ PLC-5 Lower  │          │         ▲
                          │ (direct)     │          │         │
                          └──────────────┘          │    Long-haul cable
                                                    │    (telephone term box
                          ┌──────────────┐          │     above HVPS
                          │ SLC-500      │───daisy──┘     termination tank)
                          │ Tuner Ctrl   │
                          │ (1747-DCM)   │
                          └──────────────┘
```

**Key detail**: The block diagram BD-340-330-00 shows two outputs from the scanner. In reality, there is only **one cable** from the AB scanner, which daisy-chains: VXI → PLC-5 DCM → SLC-500 tuner controller → telephone terminal box → long-haul cable to B118 → SLC-500 HVPS PLC.

The upgraded system replaces all serial communication with **Ethernet/EPICS Channel Access** for supervisory control. Hardware interlocks use dedicated fiber optic and hardwired connections through the Interface Chassis.

### 5.2 Local Panel and Fast Interlock Chassis

The **Local Panel** (SD-340-311-01-R0, located B132-12, EL 36) serves as the fiber-optic interface between the LLRF system and the HVPS controller. It contains:

- **7 fiber optic receivers** (HFBR-2414/2416, Broadcom) — soldered to PCB
- **4 fiber optic transmitters** (HFBR-1414, Broadcom) — soldered to PCB
- **Logic circuitry** — determines states of fiber optic signals to HVPS controller

The Local Panel connects to cross-connect block X530 (rack B132-14) via two DB-25 connectors (J2 and J3). The cross-connects interface to AB I/O modules.

**Fiber optic fail-safe convention**: All connections except the AB Summary status are fail-safe — fiber illumination indicates permit/active status. AB Summary uses a low-frequency pulsed signal.

The **Fast Interlock Chassis** (SD-340-308-01/02-R1) receives its input from the Local Panel via a DB-25 connector (J15) and interfaces to the VXI crate via the Arc/Interlock Detector module (J3). The chassis also contains an RF detector circuit for klystron forward power monitoring (input J32, front output J16, rear output J31).

> **Source**: `llrf/documentation/LLRFDocumentationNotesR2.docx`; `llrf/documentation/LocalPanelToXConnectMapping.xlsx`

### 5.3 Fiber Optic Connections (Legacy → HVPS)

Three fiber optic signals connect the LLRF system to the HVPS controller:

| Signal | Direction | Source | Destination | Active State | Function |
|--------|-----------|--------|-------------|-------------|----------|
| SCR ENABLE | LLRF → HVPS | Local Panel (U19) | Right Side Trigger Interconnect Board | Illuminated = permit | Enables phase control thyristor triggers |
| KLYSTRON CROWBAR | LLRF → HVPS | Local Panel (U20) | Left Side Trigger Interconnect Board | Illuminated = inhibit crowbar | Removes illumination to fire crowbar |
| STATUS | HVPS → LLRF | Left Side Trigger Interconnect Board | Local Panel (U11) → Arc Interlock Module | Illuminated = HVPS ready | Indicates control supply present + no crowbar fired |

**Transceiver specifications**:
- HVPS controller side: HFBR-1412 (transmitter), HFBR-2412 (receiver) — Broadcom
- Local Panel side: HFBR-1414 (transmitter), HFBR-2414/2416 (receiver) — Broadcom
- Cables enter Local Panel through rear slot, connect directly to PCB-mounted components

**Crowbar energy analysis** (from SLAC-PUB-7591, Cassel & Nguyen, 1997):
- With crowbar functioning: < 4 J delivered to klystron from HVPS capacitors
- Without crowbar (passive protection only): < 16 J delivered to klystron
- Klystron damage threshold: 20 J (from Philips specification)
- Protection elements: 2Ω series resistors on capacitors + series inductors in termination tank limit peak fault currents

> **Source**: `llrf/documentation/fiberOpticCableSignalControlRev3.docx`; `hvps/architecture/designNotes/controllerFiberOpticConnections.docx`

---

## 6. Interface Chassis (Upgrade — New Subsystem)

> **Reconstructed from**: `llrf/architecture/llrfInterfaceChassis.docx`; `hvps/architecture/designNotes/interfacesBetweenRFSystemControllers.docx`

### 6.1 Purpose and Architecture

The Interface Chassis is a completely new subsystem that replaces the distributed interlock wiring of the legacy system with a centralized hardware interlock coordination hub. It implements combinational logic (no processor in the critical path) with microsecond-scale response time.

### 6.2 Signal Interface Summary

**Inputs** (all permit-when-active, fail-safe):

| Input | Source | Signal Type | Logic Levels |
|-------|--------|-------------|-------------|
| LLRF Status | LLRF9 Unit 1/2 | Electrical (optocoupled) | 5V / 60 mA (from LLRF9 rear panel) |
| HVPS STATUS | HVPS controller | Fiber optic (HFBR-2412) | Illuminated = ready |
| MPS Summary Permit | RF MPS PLC | Digital | 24 VDC |
| MPS Heartbeat | RF MPS PLC | Digital (pulsed) | Watchdog signal |
| MPS Reset | RF MPS PLC | Digital | Edge-triggered |
| SPEAR MPS Permit | SPEAR MPS | 24 VDC input | Opto-isolated |
| Orbit Interlock | SPEAR orbit system | 24 VDC input | Opto-isolated |
| Arc Detection | Arc Detect Chassis | OR-gate permit + 6-bit latch | Active-high |
| Power Monitoring | Waveform Buffer | Digital comparator output | Fault = low |
| Expansion Ports | TBD | 2× TTL + 2× 24 VDC | Configurable |

**Outputs** (all permit-when-active):

| Output | Destination | Signal Type | Notes |
|--------|-------------|-------------|-------|
| LLRF Enable | LLRF9 (external interlock) | Electrical (optocoupled) | 3.2 VDC / 8 mA minimum |
| HVPS SCR ENABLE | HVPS controller | Fiber optic (HFBR-1412) | Loss = SCR triggers disabled |
| HVPS KLYSTRON CROWBAR | HVPS controller | Fiber optic (HFBR-1412) | Always illuminated (crowbar not LLRF-commanded) |
| Fault Status to MPS | RF MPS PLC | Multi-conductor digital | All input/output states + first-fault register |

### 6.3 Key Design Requirements

1. **First-fault detection**: Hardware latching circuit on all inputs identifies the initiating fault in cascade scenarios
2. **Microsecond response**: Combinational logic using standard CMOS gates and optocouplers (HCPL-2400, propagation delay ~1 μs)
3. **Electrical isolation**: All external signals isolated via optocouplers (Broadcom ACSL-6xx0 family: min ON current 8 mA, max 15 mA, max forward voltage 1.8 V) or fiber optic transceivers
4. **Fault latching**: All inputs latch when faulted until external MPS reset signal clears all simultaneously
5. **Recovery sequencing**: Must handle the feedback loop between LLRF9 status and HVPS status — removing LLRF9 enable causes LLRF9 status to go low, which could prevent re-enable. Design must ensure HVPS is confirmed off before re-enabling LLRF9.

### 6.4 Optocoupler Interface Design

From `llrf/architecture/llrfInterfaceChassis.docx`, the Interface Chassis uses Broadcom ACSL-6xx0 family optocouplers. Sample resistance calculations:

| Input Voltage | Series Resistor | Current (at 1.8V drop) |
|---------------|----------------|----------------------|
| 3.3 VDC | 150 Ω | 10 mA |
| 5.0 VDC | 320 Ω | 10 mA |
| 24 VDC | 2.2 kΩ | 10 mA |

> **Source**: `llrf/architecture/llrfInterfaceChassis.docx`, Table 1

---

## 7. HVPS Trigger System Architecture

> **Reconstructed from**: `hvps/architecture/designNotes/controllerFiberOpticConnections.docx`; `hvps/architecture/designNotes/RFSystemMPSRequirements.docx`

### 7.1 SCR Trigger Chain

The HVPS uses an **Enerpro FCOG6100** firing circuit board with FCOAUX60 daughter board (30° delayed triggering) to generate 12 thyristor trigger pulses. The Enerpro produces a picket fence of pulses from a VCO at ~720 Hz average frequency (~1.39 ms between pulses).

```
Enerpro Board → Right Side Trigger Interconnect (SD-730-793-07-C2)
                                                  ↕ 14-pin COMMANDS ribbon
             → Left Side Trigger Interconnect (SD-730-793-08-C1)
                    ↓                                    ↓
              6× SCR Driver Boards              6× SCR Driver Boards
              (SD-730-793-03-C4)                (SD-730-793-03-C4)
                    ↓                                    ↓
              6 Powerex T8K7 SCR Stacks          6 Powerex T8K7 SCR Stacks
              (14 SCRs per stack)                 (14 SCRs per stack)
```

### 7.2 Five Independent Crowbar/Disable Sources

The HVPS has five independent sources that can disable SCR triggers or fire the crowbar (defense-in-depth):

| # | Source | Input Point | Action |
|---|--------|-------------|--------|
| 1 | Fiber Optic SCR ENABLE | Right Side Interconnect Board | Loss → disables right side triggers + sends FO SCR ENABLE line to disable left side |
| 2 | TRANSFORMER ARC TRIGGER (BNC-0) | Right Side Interconnect Board | High → disables triggers + fires crowbar via SLAVE CB TRIGGER |
| 3 | Fiber Optic KLYSTRON CROWBAR | Left Side Interconnect Board | Loss → fires crowbar + disables left side + sends SLAVE CB OFF to disable right side |
| 4 | KLYSTRON ARC TRIGGER (BNC-12) | Left Side Interconnect Board | High → fires crowbar + disables triggers (same path as #3) |
| 5 | PLC FORCE CROWBAR (Slot-5 OUT3) | Right Side Interconnect Board | Active-low → disables triggers + sets SLAVE CB TRIG |

**Key design feature**: Phases B+ and B- on the right side have their OFF signals tied to common (always enabled). This allows the filter inductor to safely discharge stored energy even when all other triggers are disabled.

### 7.3 Stored Energy and Discharge

When SCR triggers are disabled, stored energy in the filter inductors (L ≈ specified value, R_winding ≈ measured) and output capacitors must dissipate safely:

- **Inductor discharge**: Through B-phase thyristors (always enabled) via secondary rectifiers. From `fiberOpticCableSignalControlRev3.docx`: discharge is faster than L/R time constant because inductor energy also dissipates into klystron load.
- **Capacitor discharge**: Through 2Ω series resistors → klystron load. If crowbar fires, discharge is faster through crowbar thyristor stacks.
- **HVPS shutdown time**: ~100 ms from SCR disable to <10% of operational power (from Fig. 1, `fiberOpticCableSignalControlRev3.docx`).

---

## 7A. HVPS Controller and Regulator System (Detailed)

> **Reconstructed from**: `Designs/4_HVPS_Engineering_Technical_Note.md`; `hvps/documentation/plc/plcNotesR1.docx`; `hvps/documentation/plc/hvpsPlcLabels.xlsx`; `hvps/architecture/designNotes/EnerproVoltageandCurrentRegulatorBoardNotes.docx`; `hvps/architecture/designNotes/regulatorEnerproTestingNotes.docx`; `hvps/controls/enerpro/enerproBoardHvps.docx`; `hvps/controls/enerpro/enerproDiscussion07072022.docx`

### 7A.1 HVPS Power Section Key Specifications

| Parameter | Value | Source |
|-----------|-------|--------|
| Input voltage | 12.47 kV RMS, 3-phase | SLAC-PUB-7591 |
| Phase-shifting transformer | 3.5 MVA, extended delta, ±15° | SLAC-PUB-7591 |
| Rectifier transformers | 2 × 1.5 MVA, open-wye primary | HVPS ETN §2.2 |
| Maximum output voltage | −90 kVDC | HVPS ETN §1.2 |
| Maximum output current | 27 A | HVPS ETN §1.2 |
| Nominal operating voltage | −74.7 kV (at 500 mA beam) | HVPS ETN §1.2 |
| Nominal operating current | 22.0 A (at 500 mA beam) | HVPS ETN §1.2 |
| Phase control stacks | 12 × 14 Powerex T8K7 (350 A) | HVPS ETN §2.3 |
| Filter inductors | 2 × 0.3 H (L1, L2), 85 A full load, 1084 J stored each | HVPS ETN §2.4 |
| Output filter caps | 4 × 8 μF (series), 0.22 μF output cap | HVPS ETN §2.6 |
| Crowbar stacks | 4 × 6 thyristors, fiber-optic triggered | HVPS ETN §2.7 |
| Output voltage dividers | 2 × 100 MΩ (5 × 20MΩ + 2×10kΩ parallel) | HVPS ETN §2.8 |
| Divider scale factor | 9.1 V at −91 kV | HVPS ETN §2.8 |
| Number of HVPSs | 2 (SPEAR1 active, SPEAR2 warm spare) | HVPS ETN §1.2 |

### 7A.2 Legacy Controller — SLC-500 PLC Slot Configuration

| Slot | Module | Function | Key Signals |
|------|--------|----------|-------------|
| CPU | AB-1747-L532 | Processor | — |
| 1 | AB-1747-DCM | Scanner (serial comm to VXI IOC) | 8 words in, 8 words out |
| 2 | AB-1746-IO8 | 8-pt digital I/O | Ross switch coil (OUT3) |
| 3 | AB-1746-THERMC | Thermocouple inputs | I:3.0–I:3.7 → N7:100–N7:107 |
| 5 | AB-1746-OX8 | 8-pt relay output | Contactor enable K4 (OUT2) |
| 6 | AB-1746-IB16 | 16 DC input | PPS 1 (IN14), PPS 2 (IN15) |
| 7 | AB-1746-IV16 | 16 DC input | Various permits |
| 8 | AB-1746-NIO4V | 4-ch analog I/O | Setpoint → regulator (OUT0), SIGHI → Enerpro (OUT1) |
| 9 | AB-1746-NI4 | 4-ch analog input | Danfysik HVPS current (IN3) |

### 7A.3 Regulator Board Signal Flow (SD-237-230-14)

The SLAC-designed regulator board provides dual voltage/current regulation with a diode-OR output:

```
PLC O:8.0 (N7:10)                       HVPS Output (−90 kV)
    │                                        │
    ▼                                    Voltage Divider
 INA117 Diff Amp ──► Trim + 24.9 kΩ     (5×20MΩ + 2×10kΩ∥)
 (reference)                              ──► INA117 Diff Amp
    │                                        │
    └──► TP9                                 └──► TP4
    │                                        │
    │         24.9 kΩ                        │    24.9 kΩ
    └──────────────► OP77 Summing ◄──────────┘
                     Junction (error amp)
                         │
                    TP7 (error)
                         │
                    Zener (±10V)
                         │
                    7.5 kΩ ──────────► SIGHI node
                                         ▲
PLC O:8.1 (N7:11) ─── 1 kΩ ──────────────┘

SIGHI = (7.5 × V_PLC + 1.0 × V_REG) / 8.5
R_thevenin = 882 Ω
```

### 7A.4 PLC Digital Low-Pass Filter (Voltage Ramp)

The PLC implements a first-order digital LPF to smoothly ramp the HVPS setpoint (Rung 104):

```
N7:43 = N7:30 - N7:10        (error = desired - actual)
N7:43 = N7:43 / 10           (α = 0.1 per step)
N7:10 = N7:10 + N7:43        (update)
if N7:43 == 0: N7:10 = N7:30 (force exact when close)
N7:10 = min(N7:10, 32000)    (upper clamp)
```

- Loop period: T = 80 ms (S:4 bit 2)
- Time constant: τ = T / α = **0.68 s** (corrected: τ = −T/ln(1−α) ≈ 0.76 s)
- Step response: V(t) = V_final × (1 − 0.9^(t/T))

### 7A.5 Phase Angle Calculation (Rungs 108–109)

```
N7:11 = (N7:10 × 12000) / 32767 + 6000   (clamped to max 18000)
```

Maps 16-bit reference (0–32000) to phase angle command range 6000–18000 counts.

### 7A.6 Measured Setpoint-to-Output Relationship

From `hvpsMeasurements20220314.xlsx` (March 14, 2022 measurements):

| Gap Voltage (kV) | HVPS Output (kV) | N7:10 (reference) | N7:11 (phase) | TP4 (V) | TP7 (V) |
|-------------------|-------------------|--------------------|----------------|---------|---------|
| 2.0 | 60.01 | 19,570 | 13,167 | 6.01 | −0.305 |
| 2.4 | 62.94 | 20,266 | 13,422 | 6.29 | −0.304 |
| 2.8 | 65.88 | 20,980 | 13,683 | 6.59 | −0.304 |
| 3.2 | 68.74 | 21,721 | 13,955 | 6.87 | −0.304 |

TP7 (error amplifier output) stays at −0.304 V across the full range — confirming the regulator is operating in its linear range.

### 7A.7 Enerpro Phase Reference Interface

From the Enerpro discussion call (July 7, 2022, with Saul Rivera and David Prince):

**Phase reference inputs (J5 on FCOG6100):**
- Pin 1 (R37, 2 MΩ): A phase reference from monitor winding
- Pin 3 (R38, 2 MΩ): B phase reference from monitor winding
- Pin 5 (R39, 2 MΩ): C phase reference from monitor winding
- Monitor winding output: ~100 Vpp at HVPS, attenuated to ~7 Vpp by external divider

**Upgrade to FCOG1200 Rev L — Phase adapter requirements:**
- Input connector: J7 on FCOG1200 (mating connector: TE 3-640440-8, Enerpro P/N C2MTAPLG08)
- 6 signals required: eAx, eBx, eCx (bridge X) and eAy, eBy, eCy (bridge Y)
- All signals biased to +5V
- Amplitude: 1–8 Vpp (preferably, 0–10 V range acceptable)
- **Amplitude matching: ±15–20% within each bridge set** (critical for phase-loss detection)
- **Recommended: Use 3 resistors, not 6** — easier to match, simpler troubleshooting
- Enerpro can place jumpers on J7 between positions 1↔4, 2↔5, 3↔6 to derive both bridge sets from 3 inputs

### 7A.8 PPS Interface in HVPS Controller

From `pps/HoffmanBoxPPSWiring.docx` (detailed analysis by J. Sebek):

**PPS connector**: Burndy GOB12-88PNE (now Souriau Trim Trio) — 8-pin circular

| Pin Pair | Function | Type |
|----------|----------|------|
| E – F | PPS 1 Enable | Sourced by PPS |
| G – H | PPS 2 Enable | Sourced by PPS |
| A – B | PPS Status (NO contact) | Monitored by PPS |
| C – D | PPS Status (NC contact) | Monitored by PPS |

**LED status display**: 4 LEDs on Hoffman Box exterior (2 green + 2 red) via AMP 8-pin connector.

**Switchgear interface**: PPS logic inside switchgear documented across multiple drawings with cross-references: GP-439-704-02-C1, rossEngr713203, ID-308-801-06-C1, WD-730-790-01-C3, WD-730-794-02-C0.

> ⚠️ **Author's note** (from J. Sebek): "ID-308-801-06-C1 is difficult for me to interpret and may contain errors. We may need to consult with an expert on this drawing to understand it correctly."

> **See also**: `Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` for the complete upgrade PPS box design.

---

## 7B. Cavity Tuner Mechanical System (Detailed)

> **Reconstructed from**: `llrf/tuners/cavityTunerInspections20230613.docx` (J. Sebek, June 14, 2023); `Docs_JS/LLRFOperation_jims.docx`; `llrf/tuners/galil/GalilCommissioning.docx`

### 7B.1 Mechanical Drive Train

```
Stepper Motor (M093-FC11)
    │
    ├── Shaft: SDP/SI 6A 3-15DF03712 (15 groove timing belt pulley)
    │
    ├── Belt: SDP/SI 6G 3-045037
    │
    └── Lead screw: SDP/SI 6A 3-30H3708 (30 groove timing belt pulley)
            │
            ├── Thread: ½-10 Acme (PF-341-392-68)
            │   → 1 motor revolution = ½ lead screw revolution
            │   → 1 motor revolution = 1.27 mm linear travel
            │
            └── Nut: Fixed to tuner body (lead screw rotates, nut translates)
```

**Motor specifications** (Superior Electric SLO-SYN M093-FC11):
- NEMA size 34D, bipolar configuration
- Rated: 2.64 V, 5.5 A, 450 oz-in holding torque
- Legacy controller: 200 steps/rev, 2 microsteps/step → 400 μsteps/rev → **3.175 μm/μstep** (DIST)
- Galil upgrade: 200 steps/rev, 16 microsteps/step → 3200 μsteps/rev → **0.397 μm/μstep**
- Deadband (legacy): 5 microsteps (RDBD = 15.9 μm)

### 7B.2 Known Failure Modes

> ⚠️ **CRITICAL**: The following failure mode was identified during the June 13, 2023 inspection (J. Sebek and M. Larrus):

**Set screw on gear shaft can back out**: The gear on the lead screw shaft is secured by a set screw fitting into a radially-drilled hole. If this set screw backs out, stepper motor rotation may not move the tuner. This is a **silent failure** — the PLC step counter continues to increment while the tuner does not move.

**Inspection recommendation**: Verify set screw engagement during all scheduled cavity maintenance.

### 7B.3 Hardware Stops and Limit Switches

Each tuner has **4 hardware stops** (2 pairs):

| Position | Limit Switch | Hard Stop | Adjustment |
|----------|-------------|-----------|------------|
| Upper travel | Engages before hard stop | Adjustable threaded bolt exposure | Bolt adjustment controls both switch and stop |
| Lower travel | Runs against metal tab | Adjustable | May require fabricating a limit switch extension if insufficient travel |

**Design intent**: Limit switch must always trigger before hard stop is reached. Bellows at top and bottom of parallel shafts must not be over-compressed or over-stretched at travel limits.

### 7B.4 Operational Ranges

| Parameter | Value | Source |
|-----------|-------|--------|
| Total travel (home → ON position) | ~2.5 mm | LLRFOperation_jims.docx Fig. 11 |
| Typical normal operation motion | ~0.2 mm | LLRFOperation_jims.docx Fig. 12 |
| Lead screw gear ratio | 2:1 (2 motor revs = 1 screw rev) | LLRFOperation_jims.docx |
| Lead screw pitch | ½-10 Acme (1.27 mm/rev) | LLRFOperation_jims.docx |
| Position feedback | Linear potentiometer (not in any control loop) | Tuner inspection doc |
| "Stop and init" feature | Aligns step counter with potentiometer reading without moving tuner | LLRFOperation_jims.docx |

---

## 7C. RF Calibration Data (Operational Reference)

> **Reconstructed from**: `llrf/calibrations/*.xlsx`

### 7C.1 Reflected Power Trip Setpoints

From `reflectedPowerCalibrations.xlsx` (February 8, 2021 measurements):

| Signal | IQA Channel | HIGH Trip (W) | HIHI Trip (W) | Notes |
|--------|------------|---------------|----------------|-------|
| KLYSOUTREFL:POWER | IQA1 Ch2 | 8.1 | 10.8 | 11.4 dBm at HIHI |
| CAV1REFL:POWER | IQA2 Ch2 | 46.5 | 81.0 | Faults at ~88.6 W |
| CAV2REFL:POWER | IQA2 Ch4 | 35.2 | 81.0 | Faults at ~87.2 W |
| CAV3REFL:POWER | IQA3 Ch2 | 35.4 | 81.0 | Faults at ~88.9 W |

### 7C.2 Tune Mode DAC Range

From `tuneModeDacCalibration.xlsx` (measured on FSW13, 8 dB fixed attenuation accounted for):

| DAC Count (SRF1:STN:TUNE:IQ.A) | Actual Power (dBm) | Power (mW) |
|---------------------------------|--------------------:|------------|
| 100 | −26.3 | 0.0023 |
| 500 | −12.0 | 0.063 |
| 1000 | −6.3 | 0.233 |
| 1500 | −3.3 | 0.467 |
| 1700 | −2.5 | 0.566 |

### 7C.3 Patch Panel RF Signal Routing (B132-11)

From `b132R11PatchPanel.xlsx` — 16 RF signal paths at patch panel:

| J# | Signal | Coupler | Coupler Loss (dB) | Cable Loss (dB) | LLRF9 CH |
|----|--------|---------|-------------------|-----------------|----------|
| J1 | Cavity A Probe | 102 | — | — | CH0 |
| J2 | Cavity A Forward | 1 | 0.42 | 2.36 | CH5 |
| J4 | Cavity B Probe | 103 | — | — | CH1 |
| J7 | Cavity C Probe | 104 | — | — | CH3 |
| J10 | Cavity D Probe | 105 | — | — | CH4 |
| J15 | Klystron Forward | 101 | 0.42 | — | CH2 |
| J16 | Klystron Reflected | 9 | 0.40 | 1.62 | — |

### 7C.4 Klystron Coupler Calibration

From `klystronCouplerDriveAmpCalibrations.xlsx` (September 14, 2020):

**Mega waveguide coupler**: Forward coupling = **61.3 dB** at 476 MHz; Reverse coupling = 61.1 dB
Coupling measured across 466–486 MHz range (±10 MHz), variation < 0.2 dB.

---

## 8. Waveform Buffer System (Upgrade — New Subsystem)

> **Reconstructed from**: `llrf/architecture/WaveformBuffersforLLRFUpgrade.docx` (J. Sebek, January 2026); `llrf/architecture/rfPowerDetector.docx`

### 8.1 RF Signal Monitoring Coverage

The 24 RF signals in the system are distributed between LLRF9 and Waveform Buffer:

| Signal Group | Count | Monitored By |
|-------------|-------|-------------|
| Cavity probes (A, B, C, D) | 4 | LLRF9 Unit 1 (A, B, C) + Unit 2 (D) |
| Cavity forward power (A, B, C, D) | 4 | LLRF9 Unit 1 (A, B, C) + Unit 2 (D) |
| Cavity reflected power (A, B, C, D) | 4 | LLRF9 Unit 2 (all 4) |
| Klystron forward + reflected | 2 | LLRF9 Unit 2 |
| Klystron drive forward | 1 | LLRF9 Unit 2 |
| Circulator load forward | 1 | LLRF9 Unit 1 |
| WG Load 2, 3 forward | 2 | LLRF9 Unit 1 |
| **Circulator load reflected** | 1 | **Waveform Buffer** |
| **Station reference** | 1 | **Waveform Buffer** |
| **WG Load 1 forward** | 1 | **Waveform Buffer** (slow only; rarely exceeds 2 kW) |
| **WG Load 1, 2, 3 reflected** | 3 | **Waveform Buffer** |
| Spare | 2 | Waveform Buffer |

### 8.2 Typical Load Power Levels

From `WaveformBuffersforLLRFUpgrade.docx`, measured power levels under various conditions:

- **Circulator Load Forward**: ~20 kW nominal with beam, increases to ~40 kW at full power without beam — most significant load signal
- **WG Load 1 Forward**: Rarely exceeds 2 kW — suitable for slow monitoring only
- **WG Load 2, 3 Forward**: ~10–20 kW when cavities are detuned (no beam)

### 8.3 RF Power Detector Selection

From `rfPowerDetector.docx`: Mini-Circuits ZX47 series connectorized RF power detectors:
- Frequency range: compatible with 476 MHz
- Output: 0–2V, linear in dBm (logarithmic in power)
- Rise time: ~μs (faster than needed for slow monitoring)
- Power supply: 5 VDC
- Signal conditioning: ×5 gain amplifier to match MPS ADC input range
- Temperature sensor included (not needed for this application)

Cables: Mini-Circuits hand-flex cables with bulkhead SMA terminations, or Bracke Manufacturing custom cables.

---

## 9. Arc Detection System (Upgrade — New Subsystem)

> **Reconstructed from**: `llrf/architecture/arcDetectorHardwareOptions.docx`

### 9.1 Original PEP-II Design (Non-functional)

The original PEP-II design placed two fiber optic arc detectors per cavity — one on the air side and one on the vacuum side of each ceramic window. The fiber optic cables were terminated at waveguide-mounted plugs with FC connectors and rubber O-rings for pressurized waveguide seal. These cables were routed to photo-detector electronics in the LLRF rack. **These arc detectors were never commissioned**, possibly due to nuisance trips.

### 9.2 Upgrade: Microstep-MIS Waveguide Arc Detectors

Commercial replacement using MicroStep-MIS (Bratislava, Slovakia) waveguide arc detector technology, originally developed at CERN for the LHC:

- **Sensors**: 6 total (4 cavity windows + 1 klystron window + 1 circulator)
- **Controller units**: Each supports 2 sensors; dry-contact relay outputs per channel
- **Mounting**: To existing MDC-45300 viewports (2.75" CF flange, ~1" lens diameter — comparable to MicroStep-MIS sensor diameter)
- **Interface**: 8 wires per controller (24 VDC power, semiconductor switch, test, reset)
- **Response**: Semiconductor switch stays closed if no arc detected; latches open on arc detection

### 9.3 Signal Architecture

See `Designs/0_PHYSICAL_DESIGN_REPORT.md`, Section 12 for the complete signal path from sensors through the Arc Detection Chassis to the Interface Chassis.

---

## 10. Analog Design Component Selection

> **Reconstructed from**: `llrf/architecture/analogDesignComponents.docx`

### 10.1 Selected Components for Upgrade Analog Circuits

| Component | Type | Key Spec | Application |
|-----------|------|----------|-------------|
| OPA189/OPA2189/OPA4189 | Precision op-amp | Zero-drift, low noise | Voltage regulation, signal conditioning |
| BUF634A | High-current buffer | 250 mA output | Cable driving, power stage buffering |
| INA851/INA823/INA849 | Instrumentation amplifier | High CMRR | HVPS monitoring |
| ACSL-6300-50TE | Quad optocoupler | ~50 ns delay | Interface Chassis digital isolation |
| 6N137A | Single high-speed opto | ~50 ns delay | Fast interlock signals |
| IL610 (NVE Corporation) | Passive digital isolator | Giant magnetoresistance | Alternative to optocouplers |
| REC6-2405DRW/H2/A | DC-DC converter (Recom) | ±5V output | Isolated power for analog sections |

> **Source**: `llrf/architecture/analogDesignComponents.docx`

---

## 11. Complete Document Index (from RfSystemDocumentIndexR3.xlsx)

### 11.1 LLRF Engineering Documents (PEP-II 340-330 Series)

| Document | Number | Description |
|----------|--------|-------------|
| Overall Block Diagram | BD-340-330-00 | Main interconnections between modules |
| LLRF Block Diagram | BD-340-330-01 | Two-cavity station (PEP-II LER) |
| RF System Description | PS-340-330-51-R0 | 11-page high-level description |
| Feedback Loop Description | PS-340-330-52-R0 | 8-page feedback loop description |
| Cavity Low Power Calibration | PS-340-330-53-R0 | Cold cavity measurement procedure |
| Safety Certification Checklist | PS-340-330-54-R0 | Klystron shielding, waveguide joints |
| Safety Survey | PS-340-330-55-R3 | Initial klystron installation survey |
| Coupling & Cable Calibration | PS-340-330-56-R0 | Cable loss measurements |
| Full Power Test & Survey | PS-340-330-57-R0 | Ionizing/non-ionizing survey |
| Cavity Phasing | PS-340-330-58-R0 | Initial cavity distance adjustment |
| Turn-on Procedure | PS-340-330-59-R0 | Standard turn-on |
| Bellow Cavity Phasing | PS-340-330-60-R1 | Fine-tune cavity phase after initial phasing |
| Non-Ionizing Radiation Safety | PS-340-330-61-R2 | SPEAR3 uses similar procedure |
| Wiring to Local Panel | WD-340-330-02-R0 | External systems → cross-connects → Local Panel |
| Cavity Junction Box | WD-340-330-03-R0 | Tuner drive, limit switches, IR sensor |
| Cavity Vacuum I&C | WD-340-330-04-R0 | Vacuum gauge/pump connections to AB |
| Waveguide Air Interlock | WD-340-330-05/06-R0 | Dwyer pressure switches to AB |
| AB TC Modules 1–14 | WD-340-330-07 through -20 | 14 thermocouple wiring diagrams |
| AB Analog Inputs 1–2 | WD-340-330-21/22-R0 | Tuner, vacuum, filament, HVPS V/I |
| AB Digital Inputs 1–2 | WD-340-330-23/24-R0 | Flow switches, vacuum, pressure |
| AB Digital Outputs 1–2 | WD-340-330-25/26-R0 | Summary interlocks |
| Cavity Tuner Motor Control | WD-340-330-27-R0 | AB → motor driver → tuner |
| Klystron Filament Control | WD-340-330-28-R0 | AB → Filament Control Chassis |
| Control Fiber Optics | WD-340-330-29-R0 | Local Panel fiber connections |
| Arc Detector Fiber Optics | WD-340-330-30-R0 | Klystron/circulator/cavity fibers |

### 11.2 HVPS Engineering Documents

| Document | Number | Description |
|----------|--------|-------------|
| Klystron PS Technical Spec | PS-341-360-01-R2 | HVPS specifications |
| SLAC-PUB-7591 | 5P014 | Crowbar energy analysis, protection design |
| HVPS Electrical Connections | EI-730-790-00-C0 | NWL schematic (complete connections) |
| HVPS High Power Schematic | SD-730-790-01-C1 | Power section |
| HVPS Grounding Tank | SD-730-790-05-C1 | Ground switch, Ross relay |
| Voltage Regulator Board | SD-237-230-14-C1 | Analog feedback controller |
| SCR Driver Board | SD-730-793-03-C4 | Low→high power pulse converter |
| Right Side Trigger Interconnect | SD-730-793-07-C2 | Trigger distribution, fiber SCR ENABLE |
| Left Side Trigger Interconnect | SD-730-793-08-C1 | Trigger distribution, fiber CROWBAR/STATUS |
| HVPS Monitor Board | SD-730-793-12-C3 | Buffered V/I signals to LLRF |

> **Source**: `llrf/documentation/RfSystemDocumentIndexR3.xlsx`

---

*See also: `01_FEEDBACK_LOOP_ARCHITECTURE.md` for loop details and mathematical framework.*
*See also: `03_LEGACY_PDF_CATALOG.md` for complete PDF inventory.*
*See also: `04_LITERATURE_SYNTHESIS.md` for published paper analysis.*
*See also: `Designs/0_PHYSICAL_DESIGN_REPORT.md` for complete upgrade system design.*

---

## 12. Signal Level Budget (from BD-340-330-01 Transcription)

The following signal level budget is reconstructed from the LER LLRF Configuration block diagram (BD-340-330-01-R0, Corredoura 1/28/98):

| Point in Chain | Signal Level | Notes |
|----------------|-------------|-------|
| 476 MHz SMA input | — | Reference frequency input |
| Amplifier Stage 1 output | +16 dBm | Pre-driver |
| Amplifier Stage 2 output | +30 dBm | 120 W max solid-state drive amplifier |
| Klystron output | 1.2 MW max | High-power RF |
| Cavity probe max | 30 dBm max | Per cavity |
| I/Q Detector input (cavity) | −10 dBm | After coupling/attenuation |
| I/Q Detector input (reference) | −6 dBm | Reference channel |
| Baseband loop signals | ±2V max | I and Q baseband |
| DAC output (baseband) | ±2V | To I/Q Modulator |

**VXI RF Module Internal Architecture**:
- **Baseband Network Analyzer**: 5 channels × 512K RAM (cav I, cav Q, sig I, sig Q, PAD), F_sample = **10 MHz**, excitation via x DAC
- **Comb Filter**: 2 modules (separate I and Q paths), each containing: I/Q modulator (sys I/Q error, ±2V reference), 1-turn delays, delay equalizers, I/Q modulator (comb adj)
- **Ripple Loop DSP**: AT&T **DSP1610** processor with serial link + parallel bus
- **Gap Feedforward**: VXI module with **lowpass filter** on output, I/Q modulator → gap module

> **Source**: `legacy-pdf-transcriptions/block-diagrams/BD-340-330-01_PEP-II_Low_Level_RF_Configuration.md`
> **HER cross-reference**: The HER counterpart (BD-340-329-01) confirms identical signal levels for the 4-cavity configuration. Additional HER details: explicit "REFL 4/7/6" reflection port labels on cavity I/Q detectors, per-cavity adjustment I/Q MOD modules (cav 1 adj through cav 4 adj), "LOWPASS" filter on Gap FF output path, and −3 dBm at circulator output.
> **Source**: `legacy-pdf-transcriptions/block-diagrams/PEP-II_Low_Level_RF_Block_Diagram.md`

## 13. PLC-5 Control System Configuration (from BD-340-330-00 Transcription)

The Allen Bradley PLC-5 provides the primary station control and interlock processing. Configuration from the LER RF Station block diagram (BD-340-330-00-R0):

### 13.1 PLC-5 I/O Capacity

| I/O Type | Channels | Notes |
|----------|----------|-------|
| Digital Output | 64 | Station control commands |
| Digital Input | 64 | Interlock status inputs |
| Thermocouple Input | 112 | Separate crate (dedicated thermocouple processor) |
| Analog Input | 32 | Voltage/current/power monitoring |

### 13.2 DH-485 Network Peripherals

The PLC communicates with the following peripherals via Allen Bradley DH-485 network:

| Peripheral | Parameters Monitored |
|------------|---------------------|
| Focus Supply #1 | Voltage, current |
| Focus Supply #2 | Voltage, current |
| Filament Supply | On/current limit, on/full current, voltage monitor, current monitor |
| Tuner Motor Power Supply | Shared supply for all cavity tuners |

### 13.3 PLC-to-HVPS Interface

| Signal Direction | Signal |
|-----------------|--------|
| PLC → HVPS | HVPS on/off request, HVPS reset, open/close contactor |
| HVPS → PLC | HVPS ready signal, contactor status, HVPS on/off status |

### 13.4 PLC-to-RF Interface

| Signal Direction | Signal |
|-----------------|--------|
| PLC → VXI | Fiber optic links, LED signals (fiber receiver) |
| VXI → PLC | Via Allen Bradley VME scanner, DCM module, Remote I/O link |

### 13.5 Interlock Inputs (from BD-340-330-00)

| Interlock | Type | Response |
|-----------|------|----------|
| Primary air source | Pressure | Station trip |
| Secondary air source | Pressure | Station trip |
| Input water temperature | Temperature | To interlocks |
| Water delta temperature | ΔT via pressure gauge | To interlocks |
| Magnet over-temperature | Temperature | To interlocks |
| High pump pressure | Local panel high-P sensor | To interlocks |
| Air/waveguide pressure | Pressure controller | Station trip |
| Beam abort | Signal | To analog monitor |
| Magnet current | Current | To analog monitor |

### 13.6 HVPS Safety Interfaces (from BD-340-330-00)

| Interface | Type | Connection |
|-----------|------|------------|
| PPS (Personnel Protection System) | Status signal | PPS → HVPS |
| Beam abort | Crowbar protection | Beam abort → HVPS crowbar |
| Emergency off | Hardwired +24V | E-stop → HVPS |
| Trigger control | Fiber optic | PLC → HVPS firing circuits |

> **Source**: `legacy-pdf-transcriptions/block-diagrams/BD-340-330-00_PEP-II_LER_RF_Station_Block_Diagram.md`

## 14. EPICS Control Panel Reference (from PS-340-330-59 Transcription)

The legacy PEP-II LLRF system uses four primary EPICS operator panels, reconstructed from the Turn-On Procedure (PS-340-330-59-R0, pages 3–6):

### 14.1 KLYSTRON Panel (Fig. 1)

Monitors: filament voltage/current, filament time left (30 min warmup), solenoid current, body current, beam voltage/current, circulator load temperature, arc detector status, per-cavity forward/reflected power, gap voltage, and vacuum.

### 14.2 RF STATION Panel (Fig. 2)

Primary operator interface with station mode controls:
- **ON_CW**: Normal beam operation (auto loop engagement: Ripple→Direct→Comb)
- **ON_FM**: Pulsed mode at 1000 Hz for cavity processing
- **OFF**: RF off, fires beam abort, tuners left in position
- **PARK**: Detunes cavities **+340 kHz** from resonance
- **OFF-LINE**: Station locked out, only essential interlocks active
- **TUNE**: Cavity tuning procedures
- Auto Reset Tries: up to **25 resets** for automatic recovery

### 14.3 HVPS Panel (Fig. 3)

HVPS voltage/current/power readback, efficiency display, voltage regulation mode (OFF/PROC/ON), contactor control. Manual reset interlocks: crowbar, transformer overtemp, waveguide pressure, beam abort.

### 14.4 FEEDBACK Panel (Fig. 4)

All loop status indicators and controls. MATLAB configuration buttons: ConfDirect, Config Comb, Tune Cavs, ConfWoofer, MeasDirCls, Make Equal, Make Poly, Phase Stns.

> **Source**: `legacy-pdf-transcriptions/operational-procedures/PS-340-330-59_RF_Station_Turn_On_Procedure.md`
