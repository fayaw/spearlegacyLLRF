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

## 5. Legacy Communication Architecture

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
                          │ SLC-500      │──daisy──┘     termination tank)
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
