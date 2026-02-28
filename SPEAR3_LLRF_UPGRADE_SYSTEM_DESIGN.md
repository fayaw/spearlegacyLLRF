# SPEAR3 LLRF Upgrade System Design

**Document Purpose**: Dedicated engineering design reference for the upgraded SPEAR3 LLRF control system. This document focuses exclusively on the upgrade system architecture, specifications, and design decisions. It is intended to guide detailed engineering design and implementation.

**Version**: 1.0
**Date**: 2026-02-27
**Status**: Engineering Design Reference

**Convention**: Items marked with **[TBD]** require final engineering decisions. Items marked with **[RECOMMENDED]** are optimal design suggestions based on system analysis. All other content reflects established design decisions from project documentation.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [System Architecture](#2-system-architecture)
3. [LLRF9 Controller Configuration](#3-llrf9-controller-configuration)
4. [Interface Chassis](#4-interface-chassis)
5. [Waveform Buffer System](#5-waveform-buffer-system)
6. [HVPS Control System](#6-hvps-control-system)
7. [Machine Protection System (MPS)](#7-machine-protection-system-mps)
8. [Tuner Motor Control System](#8-tuner-motor-control-system)
9. [Arc Detection System](#9-arc-detection-system)
10. [Station State Machine](#10-station-state-machine)
11. [HVPS Supervisory Control Loop](#11-hvps-supervisory-control-loop)
12. [Tuner Supervisory Control](#12-tuner-supervisory-control)
13. [Software Architecture](#13-software-architecture)
14. [Fault Management & Diagnostics](#14-fault-management--diagnostics)
15. [EPICS Process Variable Architecture](#15-epics-process-variable-architecture)
16. [Implementation Phases & Commissioning](#16-implementation-phases--commissioning)
17. [Open Engineering Decisions](#17-open-engineering-decisions)

---

## 1. System Overview

### 1.1 Scope

The SPEAR3 LLRF upgrade replaces the entire RF control electronics chain for a single RF station consisting of one klystron driving four single-cell RF cavities at 476.3 MHz. The upgrade modernizes every control subsystem while retaining the physical RF infrastructure (klystron, cavities, waveguide distribution, stepper motors, and HVPS power stage).

### 1.2 Key System Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| RF Frequency | 476.3 MHz | SPEAR3 RF frequency; LLRF9/476 supports 476 +/- 2.5 MHz |
| Total Gap Voltage | ~3.2 MV | Sum of 4 cavity gap voltages |
| Klystron Power | ~1 MW | Single klystron drives all 4 cavities |
| HVPS Voltage | up to ~90 kV | Klystron cathode voltage; turn-on voltage ~50 kV |
| Drive Power | ~50 W nominal | Input to klystron from drive amplifier |
| Number of Cavities | 4 | Single-cell cavities with individual tuners |
| Cavity Gap Voltage | ~800 kV each | Individual cavity contribution |

### 1.3 Subsystem Summary

| Subsystem | Hardware | Status |
|-----------|----------|--------|
| LLRF Controller | Dimtel LLRF9/476 x2 (+2 spares) | Procured, prototype commissioned |
| MPS | ControlLogix 1756 PLC | Hardware assembled, software written, tested without RF power; ready for EPICS development |
| HVPS Controller | CompactLogix PLC + Enerpro boards | Upgraded prototype exists; PLC replacement needed for EPICS development |
| Tuner Motor Controller | Galil DMC-4143 (ready) | Galil controller ready, can drive motor; next step: test with real cavity signal |
| Interface Chassis | Custom - optocoupler/fiber-optic hub | Interfaces specified; no chassis design |
| Waveform Buffer System | Custom - 8 RF + 4 HVPS channels | Prototype design complete, PCB fabricated; assembly and testing needed |
| Arc Detection | Microstep-MIS optical sensors | Concept exists; not yet procured |
| Control Software | Python/PyEPICS + LLRF9 built-in IOC | Conceptual design only |


---

## 2. System Architecture

### 2.1 Fundamental Design Principle

The upgrade transitions from a **software-centric** model (VxWorks SNL doing everything in a single IOC) to a **distributed hardware-accelerated** model:

- **LLRF9** handles all time-critical RF control (270 ns loop, calibration, phase measurement, interlocks)
- **Interface Chassis** handles all fast hardware interlock coordination (microsecond-scale)
- **PLCs** handle subsystem-specific regulation (HVPS voltage, MPS logic)
- **Python/EPICS** handles supervisory control, sequencing, monitoring, and operator interface (~1 Hz)

This separation means the Python coordinator never needs to be in the fast-safety path. Hardware interlocks protect the system even if the Python process is temporarily unavailable.

### 2.2 Two-Layer Architecture

The system operates on two parallel communication layers:

**Layer 1 --- Fast Hardware Interlocks (microsecond-scale)**:
- Interface Chassis coordinates all hardware interlock signals
- Direct electrical (optocoupler) and fiber-optic connections between subsystems
- First-fault detection with latching and timestamp
- No software in the path --- pure hardware logic
- Protects klystron, cavities, and HVPS from damage

**Layer 2 --- EPICS Supervisory Control (~1 Hz)**:
- Python/EPICS coordinator communicates with all subsystems via Ethernet/Channel Access
- Sets amplitude/phase setpoints, HVPS voltage, motor positions
- Manages station state transitions, turn-on/shutdown sequencing
- Reads back measurements, status, fault data
- Provides operator interface and logging

### 2.3 System Block Diagram

```
                    +--------------------------------------------------+
                    |          Python/EPICS Coordinator                 |
                    |  State Machine | HVPS Loop | Tuner Mgr | Logging |
                    +--------+-------------+-----------+--------+------+
                             |             |           |        |
                    Ethernet/EPICS Channel Access (Layer 2, ~1 Hz)
                             |             |           |        |
              +--------------+------+------+---+-------+--+     |
              |              |      |          |          |     |
     +--------v---+  +------v---+  |  +-------v------+   |  +-v----------+
     | LLRF9 #1   |  | LLRF9 #2 |  |  | Motion Ctrl  |   |  | Waveform   |
     | Field Ctrl |  | Monitor  |  |  | (TBD)        |   |  | Buffer Sys |
     | + Tuner    |  | + Intlck |  |  | 4-axis       |   |  | 8 RF + 4   |
     | Built-in   |  | Built-in |  |  | Stepper      |   |  | HVPS ch.   |
     | EPICS IOC  |  | EPICS IOC|  |  +------+-------+   |  +-----+------+
     +-----+------+  +----+-----+  |         |           |        |
           |              |        |         |           |        |
           | 5V status    |        |    4 motors    +----v-----+  | Comparator
           v              |        |         |      | HVPS PLC |  | trip
     +-----+--------------+--------+---------+------+---+------+--+------+
     |                    Interface Chassis (Layer 1, us-scale)          |
     |  First-fault detection | Fault latching | Optocoupler isolation   |
     +----+--------+--------+--------+--------+--------+--------+-------+
          |        |        |        |        |        |        |
        LLRF9    HVPS    MPS PLC   SPEAR   Orbit    Arc      Expansion
        Enable   Fiber   Permit    MPS     Intlck   Detect   Ports
        (3.2V)   Optic   +Hbeat   (24V)   (24V)    (dry)    (TTL/24V)
```

### 2.4 Hardware/Software Responsibility Matrix

| Function | Owner | Interface | Update Rate |
|----------|-------|-----------|-------------|
| Fast I/Q demodulation | LLRF9 FPGA | Internal | Continuous |
| Direct loop feedback | LLRF9 FPGA | Config via EPICS | 270 ns loop delay |
| Integral loop feedback | LLRF9 FPGA | Config via EPICS | Continuous |
| Vector sum computation | LLRF9 FPGA | Config via EPICS | Continuous |
| Gap voltage amplitude regulation | LLRF9 FPGA | Setpoint via EPICS | Continuous |
| Phase measurement for tuners | LLRF9 | Read via EPICS | 10 Hz synchronized |
| Drive power measurement | LLRF9 | Read via EPICS | 10 Hz |
| RF interlock processing | LLRF9 + Interface Chassis | Hardware | <1 us |
| Calibration | LLRF9 internal | Trigger via EPICS | On demand |
| Waveform capture | LLRF9 | Read via EPICS | On trigger |
| HVPS voltage regulation | CompactLogix PLC | Analog I/O | PLC scan rate |
| HVPS contactor control | CompactLogix PLC | Command via EPICS | On demand |
| HVPS supervisory (setpoint mgmt) | Python/EPICS | Channel Access | <=1 Hz |
| MPS fault summary | ControlLogix PLC | Digital I/O | PLC scan rate |
| Interlock coordination | Interface Chassis | Hardware | <1 us |
| First-fault detection | Interface Chassis | Read via MPS/EPICS | <1 us detect, ~1 Hz read |
| Tuner motor motion | Motor Controller | EPICS motor record | <=1 Hz command |
| Tuner phase loop | Python + LLRF9 data | Channel Access | ~1 Hz |
| Load angle offset | Python/EPICS | Channel Access | ~0.1 Hz |
| Station state machine | Python/EPICS | Channel Access | ~1 Hz |
| Turn-on/shutdown sequencing | Python + LLRF9 profiles | Channel Access + LLRF9 | Sequence-dependent |
| Fault logging & diagnostics | Python/EPICS | Channel Access | Event-driven |
| Extended RF/HVPS monitoring | Waveform Buffer System | Read via EPICS | ~1 Hz normal; frozen on fault |
| Collector power protection | Waveform Buffer System | Hardware trip | Continuous |
| Arc detection | Microstep-MIS -> Interface Chassis | Hardware | <1 us |
| Operator interface | Python/EPICS | EDM panels / CA | On demand |

---

## 3. LLRF9 Controller Configuration

### 3.1 Hardware Overview

Each Dimtel LLRF9 contains:
- **3 x LLRF4.6 boards**: Each with 4 high-speed ADC channels + 2 DAC channels, Xilinx Spartan-6 FPGA
- **LO/Interconnect module**: Local oscillator synthesis (divide-and-mix, low phase noise), RF reference distribution, output amplification/filtering, interlock logic
- **Linux SBC**: mini-ITX, runs built-in EPICS IOC
- **Thermal stabilization**: Aluminum cold plate, 3 TEC modules under PID control (critical for phase stability)
- **Interlock subsystem**: 9 RF input interlocks + 8 baseband ADC interlocks, hardware daisy-chain

### 3.2 RF Channel Architecture

Each LLRF4.6 board has 4 ADC inputs. One channel per board is dedicated to the **RF reference signal**; the remaining 3 are measurement channels. All phase measurements are relative to the reference channel on that board, rejecting phase drifts in LO and sampling clock generation.

### 3.3 LO Signal Generation (LLRF9/476)

| Signal | Ratio to f_rf | Frequency (MHz) |
|--------|--------------|------------------|
| Reference (f_rf) | 1 | 476.000 |
| IF | 1/12 | 39.667 |
| Local Oscillator | 11/12 | 436.333 |
| ADC Clock | 11/48 | 109.083 |
| DAC Clock | 11/24 | 218.167 |

### 3.4 Two-Unit Configuration

Per LLRF9 manual Section 8.4 ("One station, four cavities, single power source"):

**Unit 1 --- Field Control & Tuner Loops:**
- Runs the field control feedback loop (vector sum of two cavity probes on a single LLRF4.6 board)
- All four tuner loops use 10 Hz synchronized phase data (probe vs. forward)
- Connected to: 4 cavity probe signals + 4 cavity forward signals + 1 klystron forward power = 9 channels
- Outputs: Klystron drive signal via thermally stabilized output chain (LLRF4.6 boards 1 or 2 only)

**Unit 2 --- Monitoring & Interlocks:**
- Monitors 4 cavity reflected signals (critical for fast interlock protection against arcs, beam aborts, transient mismatch)
- Monitors additional signals: circulator load forward/reflected, klystron reflected, station reference, etc.
- Provides interlock chain: reflected power event turns off drive on Unit 1 via daisy-chained interlock
- No drive output required

**Hardware constraint**: Only LLRF4.6 modules 1 and 2 on each unit have thermally stabilized output filtering, interlock, and amplification chains. Module 3's output is rear-panel only without these features. Drive outputs must come from boards 1 or 2.

### 3.5 Channel Assignment

**Unit 1 (Field Control):**

| Channel | Signal | Board | Purpose |
|---------|--------|-------|---------|
| ADC0 | Cavity 1 probe | Board 1 | Vector sum input |
| ADC1 | Cavity 2 probe | Board 1 | Vector sum input |
| ADC2 | RF reference | Board 1 | Phase reference for Board 1 |
| ADC3 | Cavity 3 probe | Board 2 | Monitoring + tuner phase |
| ADC4 | Cavity 4 probe | Board 2 | Monitoring + tuner phase |
| ADC5 | RF reference | Board 2 | Phase reference for Board 2 |
| ADC6 | Klystron forward | Board 3 | Forward power measurement |
| ADC7 | Cavity fwd (mux) | Board 3 | Tuner phase reference |
| ADC8 | RF reference | Board 3 | Phase reference for Board 3 |
| DAC0 | Klystron drive | Board 1/2 | +8 dBm full scale output |
| DAC1 | Spare | Board 1/2 | -13 dBm full scale |

> **[RECOMMENDED]** The exact channel assignment should be verified with Dimtel during the commissioning support week. The vector sum requires both probe signals on the same LLRF4.6 board (same reference clock). The assignment above places Cavity 1 and 2 probes on Board 1 for the primary vector sum.

**Unit 2 (Monitoring):**

| Channel | Signal | Board | Purpose |
|---------|--------|-------|---------|
| ADC0 | Cavity 1 reflected | Board 1 | Arc/mismatch interlock |
| ADC1 | Cavity 2 reflected | Board 1 | Arc/mismatch interlock |
| ADC2 | RF reference | Board 1 | Phase reference |
| ADC3 | Cavity 3 reflected | Board 2 | Arc/mismatch interlock |
| ADC4 | Cavity 4 reflected | Board 2 | Arc/mismatch interlock |
| ADC5 | RF reference | Board 2 | Phase reference |
| ADC6 | Circulator load fwd | Board 3 | System monitoring |
| ADC7 | Klystron reflected | Board 3 | Klystron protection |
| ADC8 | RF reference | Board 3 | Phase reference |

### 3.6 Key Capabilities Utilized

| Capability | Specification | What It Replaces |
|------------|---------------|-----------------|
| Vector sum | 2-channel digital combining (single LLRF4.6 board) | Analog RFP I/Q summation |
| Direct loop delay | 270 ns | Analog direct loop (~us) |
| Feedback loops | Proportional + Integral | Analog P+I in RFP |
| Phase measurement | 10 Hz, synchronized across all 9 channels, +/-17.4 ns timestamp | VXI-based phase detection |
| Setpoint profiles | 512 points, 70 us -- 37 ms per step (total ramp: 70 us to 18.9 s) | No equivalent |
| Waveform capture | 16,384 samples/channel, hardware trigger, adjustable pre/post-trigger | Limited fault file dumps |
| Network analyzer | Built-in swept measurement, +/-25 kHz around RF, 1024 points | External test equipment |
| Spectrum analyzer | Zero-excitation mode of network analyzer | External test equipment |
| RF interlocks | 9 RF input (overvoltage) + 8 baseband (window comparator), +/-35 ns timestamp, daisy-chain | Distributed analog interlocks |
| Slow ADC | 8 channels, 12-bit, +/-10V/+/-5V/0-10V/0-5V, opto-isolated, window comparator | External monitoring |
| RF output interlock | Dual redundancy: FPGA zeros DAC + physical RF switch >=40 dB isolation | Single analog disable |
| Calibration | Digital (no analog drift); EEPROM for factory + installation parameters | rf_calib.st (2800 lines) |
| Housekeeping | Voltage/current monitoring, 10 temperature sensors, 4 fan speed, 3 TEC | Manual checks |

### 3.7 What LLRF9 Eliminates from Legacy

The LLRF9 completely replaces and eliminates the need for:
- Analog RF Processor (RFP) module and all fast I/Q processing
- Gap Voltage Feed-forward (GVF) module
- Cavity Field Monitor (CFM) module
- The entire calibration system (`rf_calib.st` --- 2800+ lines of analog offset nulling)
- Comb loop, direct loop, GFF loop analog processing hardware
- Ripple loop hardware (LLRF9 digital feedback inherently rejects power-line ripple)
- The DAC loop's complex 4-way branching logic (artifact of legacy hardware modularity)

---

## 4. Interface Chassis

### 4.1 Purpose

The Interface Chassis is the **central integration hub** for all fast hardware interlocks. It connects the LLRF9, MPS, HVPS controller, and external safety systems with proper electrical isolation, signal conditioning, first-fault detection, and fast interlock coordination. It is a new subsystem with no legacy equivalent.

### 4.2 Design Requirements

1. **First-fault circuit** on all inputs --- identifies the initiating fault when multiple faults cascade
2. **Fault latching** --- all inputs latch when they fault
3. **External reset** --- digital reset from MPS simultaneously clears all latched faults
4. **Status reporting** --- all input/output states plus first-fault status reported to MPS via digital control lines
5. **Electrical isolation** --- all external signals isolated from chassis digital ground using optocouplers
6. **Processing delay** --- microsecond-scale (standard electronic and electro-optical components)

### 4.3 Signal Interface Specification

| Direction | Signal | Type | Source/Destination | Notes |
|-----------|--------|------|-------------------|-------|
| **Input** | LLRF9 Status | 5 VDC, up to 60 mA | LLRF9 rear panel | Non-isolated output from LLRF9; OR of 17 internal + 1 external interlock |
| **Input** | HVPS STATUS | Fiber-optic (HFBR-1412 receiver) | HVPS Controller | Active when powered, no crowbar trigger |
| **Input** | MPS Summary Permit | Digital | RF MPS PLC | |
| **Input** | MPS Heartbeat | Digital | RF MPS PLC | Watchdog for MPS communication |
| **Input** | Power Signal Permit | Digital (optocoupler) | Waveform Buffer System | Comparator trip outputs |
| **Input** | SPEAR MPS Permit | 24 VDC (optocoupler) | SPEAR MPS | |
| **Input** | Orbit Interlock Permit | 24 VDC (optocoupler) | SPEAR orbit interlock | |
| **Input** | Arc Interlock Permit(s) | Dry contacts (optocoupler) | Microstep-MIS arc detectors | |
| **Input** | Expansion Port 1-2 | TTL (optocoupler) | External systems | |
| **Input** | Expansion Port 3-4 | 24 VDC (optocoupler) | External systems | |
| **Input** | MPS Reset | Digital | RF MPS PLC | Clears all latched faults |
| **Output** | LLRF9 Enable | 3.2 VDC @ >=8 mA (optocoupler) | LLRF9 interlock input | Removes to disable RF |
| **Output** | HVPS SCR ENABLE | Fiber-optic (HFBR-2412 driver) | HVPS Controller | Enables phase control thyristors |
| **Output** | HVPS KLYSTRON CROWBAR | Fiber-optic (HFBR-2412 driver) | HVPS Controller | Must remain illuminated to prevent crowbar |
| **Output** | Digital Status Lines | Multi-conductor cable | RF MPS PLC | All input/output states + first-fault |

### 4.4 Isolation Components

- **Optocouplers**: Broadcom ACSL-6xx0 family (max input forward voltage 1.8 VDC, recommended ON current 8 mA, max 15 mA)
- **Fiber-optic**: Broadcom HFBR-2412 (transmitter) / HFBR-1412 (receiver) for HVPS signals

### 4.5 Interlock Signal Flow

**Normal Operation:**
1. All input permits are active
2. Interface Chassis asserts LLRF9 Enable and HVPS SCR ENABLE
3. LLRF9 drives the klystron; HVPS provides high voltage
4. KLYSTRON CROWBAR fiber remains illuminated (prevents crowbar firing)

**Fault Originating from LLRF9** (e.g., reflected power interlock):
1. LLRF9 zeros its DAC output and opens its RF switch (dual redundancy)
2. LLRF9 Status output goes LOW (5V -> 0V)
3. Interface Chassis detects LLRF9 Status = OFF
4. Interface Chassis removes HVPS SCR ENABLE (fiber optic) to protect klystron collector
5. Interface Chassis reports fault to MPS via digital status lines
6. First-fault register records LLRF9 as initiating source

**Fault from External System** (e.g., SPEAR MPS removes 24V permit):
1. Interface Chassis detects permit loss, latches fault, records in first-fault register
2. Interface Chassis removes LLRF9 Enable (3.2V -> 0V)
3. LLRF9 sees external interlock trip, zeros DAC, opens RF switch
4. LLRF9 Status goes LOW (consequence, not initiating fault)
5. Interface Chassis simultaneously removes HVPS SCR ENABLE
6. MPS is notified via digital status lines

**Recovery Sequence:**
1. MPS sends external reset signal to Interface Chassis
2. All latched faults are cleared simultaneously
3. System verifies HVPS STATUS is OFF before re-enabling
4. LLRF9 Enable is restored; HVPS SCR ENABLE is restored
5. Python/EPICS coordinator manages station state transition back to operation

### 4.6 Critical Design Consideration: LLRF9 Enable/Status Loop

When the Interface Chassis removes the LLRF9 Enable, the LLRF9 Status will also go OFF (since the external interlock input is OR-ed with 17 internal interlock sources inside the LLRF9). The system must be designed so that:

1. The first-fault register correctly identifies the **external** fault as the initiator (not the resulting LLRF9 Status change)
2. Once the HVPS is confirmed off, the enable can be restored to the LLRF9 for recovery
3. The HVPS controller removes its STATUS when SCR ENABLE is removed (coordination required)

> **[RECOMMENDED]** Implement a one-shot latch on the LLRF9 Status input that captures the LLRF9 state at the moment of initial fault detection, before the cascading effects of the enable removal. This distinguishes "LLRF9 faulted first" from "LLRF9 status went off because we removed its enable."

---

## 5. Waveform Buffer System

### 5.1 Purpose

The Waveform Buffer System is a **distinct subsystem** --- separate from the LLRF9 --- providing extended signal monitoring, waveform capture, hardware trip capability, and klystron collector power protection for RF and HVPS signals not covered by the LLRF9's 18 channels. Design by J. Sebek, January 2026.

### 5.2 RF Signal Monitoring (8 channels)

The LLRF9 (2 units x 9 channels) covers the 18 most important RF signals. The Waveform Buffer monitors the remaining critical signals:

| Channel | Signal | Notes |
|---------|--------|-------|
| 1 | Klystron Output Forward Power | |
| 2 | Klystron Output Reflected Power | |
| 3 | Circulator Load Forward Power | Appreciable power at low beam current |
| 4 | Circulator Load Reflected Power | |
| 5 | Waveguide Load 1 Forward Power | Sum of reflected from all 4 cavities |
| 6 | Waveguide Load 1 Reflected Power | |
| 7 | Waveguide Load 2 Forward Power | Sum of reflected from Cavities A and B |
| 8 | Waveguide Load 2 Reflected Power | |

**Signal conditioning**: RF detectors (Mini-Circuits ZX47-40LN+, output 0.5-2.0V into 50 ohm) with possible op-amp conditioning stage.

**Digitizers**: 12-bit resolution sufficient; ~1 MHz sampling rate.

**Waveform buffers**: Kilosample circular buffers, frozen on fault trigger.

**Hardware comparators**: Analog comparator circuits with latched fault outputs feed into Interface Chassis via optocoupler.

### 5.3 HVPS Signal Monitoring (4 channels)

| Channel | Signal | Purpose |
|---------|--------|---------|
| 1 | HVPS Output Voltage | Diagnose HVPS-caused beam dumps |
| 2 | HVPS Output Current | Diagnose HVPS-caused beam dumps |
| 3 | Transformer 1 Voltage | Detect thyristor firing circuit faults |
| 4 | Transformer 2 Voltage (or Phase Current) | Detect thyristor firing circuit faults |

**Buffer requirements**: ~100 ms of data (HVPS failures can precede system trip by ~100 ms). Reduced sampling rate acceptable (averaging by ~4 to reduce buffer to ~16k samples).

**Signal conditioning**: Voltage dividers to reduce large HVPS signals to digitizer input range.

### 5.4 Klystron Collector Power Protection

This is a **critical safety function** unique to the upgrade. The klystron collector absorbs the difference between DC input power and RF output power. Since these are not "full power collector" klystrons, the collector cannot absorb the full DC beam power.

**Calculation**: Collector Power = DC Power (HVPS V x I) - RF Output Power

**Implementation**:
- Uses HVPS voltage and current channels to compute DC input power
- Uses one RF channel to measure klystron output RF power
- Trips the system if collector power exceeds safe limits
- Buffered signals also sent to MPS PLC for redundant calculation

### 5.5 Normal Operation

Averaged signals made available for archival at ~1 Hz update rate via EPICS.

> **[RECOMMENDED]** Design the Waveform Buffer digitizer interface to use standard EPICS waveform records for circular buffer readout. Consider using an FPGA-based digitizer (e.g., Red Pitaya or similar) with existing EPICS drivers to reduce custom hardware development.

---

## 6. HVPS Control System

### 6.1 Architecture

The HVPS control is split between the CompactLogix PLC (low-level regulation) and the Python/EPICS coordinator (supervisory control):

- **CompactLogix PLC**: Voltage regulation via analog output to Enerpro gate driver boards, thyristor firing angle control, contactor control, PPS interface, local safety interlocks
- **Python/EPICS**: Sends voltage setpoint (<=1 Hz), contactor open/close commands, reads back voltage/current/status

### 6.2 Hardware Interfaces

**Software interface** (PLC <-> EPICS):
- Protocol: EtherNet/IP via CompactLogix Ethernet port
- EPICS driver: **[TBD]** --- pycomm3, OPC-UA, or custom EtherNet/IP driver
- Data: Analog measurements (voltage, current), digital status, fault conditions
- Commands: Contactor control, voltage setpoint

**Hardware interlocks** (PLC <-> Interface Chassis):
- **Fiber-optic inputs from Interface Chassis**:
  - SCR ENABLE: Permits phase control thyristors to fire
  - KLYSTRON CROWBAR: Must remain illuminated to prevent crowbar thyristors from firing
- **Fiber-optic output to Interface Chassis**:
  - STATUS: Active when controller is powered and no crowbar trigger present

**No direct LLRF9-to-HVPS hardware connection** --- all interlock coordination goes through the Interface Chassis.

### 6.3 Enerpro Gate Driver Upgrade

- Replace existing gate driver boards with new Enerpro controller boards (~$4k for 5 boards)
- Redesign analog regulator board with modern components
- Test on Test Stand 18 before SPEAR3 installation

### 6.4 PLC Code Development

- Reverse-engineer existing SLC-500 PLC code
- Rewrite for CompactLogix platform
- Must handle: voltage regulation loop, contactor sequencing, over-current protection, PPS interface
- Modify PPS (Personnel Protection System) interface to current standards

### 6.5 HVPS Maintenance Item

Three broken windings in HVPS1 need to be troubleshot and repaired.

---

## 7. Machine Protection System (MPS)

### 7.1 Architecture

The MPS upgrades from legacy PLC-5 (1771 I/O) to **ControlLogix 1756** using a Rockwell Automation conversion kit.

**Status**: Hardware assembled, software written, tested on SPEAR3 without RF power.

### 7.2 MPS Inputs (via Interface Chassis)

| Input | Source | Type |
|-------|--------|------|
| LLRF9 fault | LLRF9 via Interface Chassis | Electrical (optocoupler) |
| HVPS STATUS | HVPS via Interface Chassis | Fiber-optic |
| Power signal trip | Waveform Buffer via Interface Chassis | Electrical (optocoupler) |
| Arc detection | Microstep-MIS via Interface Chassis | Electrical (optocoupler) |
| SPEAR MPS permit | SPEAR MPS via Interface Chassis | 24 VDC (optocoupler) |
| Orbit interlock | Orbit system via Interface Chassis | 24 VDC (optocoupler) |
| Spare inputs (x2) | Expansion via Interface Chassis | Configurable |

### 7.3 MPS Outputs (via Interface Chassis)

| Output | Destination | Type |
|--------|-------------|------|
| LLRF9 disable | LLRF9 via Interface Chassis | Electrical |
| HVPS SCR ENABLE | HVPS via Interface Chassis | Fiber-optic |
| HVPS KLYSTRON CROWBAR | HVPS via Interface Chassis | Fiber-optic |

### 7.4 MPS Role

- Aggregates fault status from all subsystems
- Manages overall system permit
- Sends reset signal to Interface Chassis to clear latched faults
- Reports complete status to Python/EPICS coordinator
- Provides redundant collector power calculation (from Waveform Buffer data)

---

## 8. Tuner Motor Control System

### 8.1 Physical System (Retained)

The physical tuner assemblies are retained from the legacy system:

- **Stepper Motor**: Superior Electric Slo-Syn M093-FC11 (NEMA 34D), 200 steps/rev
- **Drive Train**: Motor -> 15-groove pulley -> timing belt -> 30-groove pulley -> lead screw -> cylindrical tuner
- **Gear Ratio**: 2 motor revolutions = 1 leadscrew revolution
- **Lead Screw Pitch**: 20 TPI (0.05"/turn = 1.27 mm/turn) — verified from actual hardware.
- **Position Sensing**: Linear potentiometers provide position indication (not used in any closed-loop feedback; step counter tracks commanded position)

### 8.2 Legacy Controller (Being Replaced)

- Allen-Bradley 1746-HSTP1 controller module (obsolete)
- Superior Electric Slo-Syn SS2000MD4-M bipolar PWM driver (obsolete)
- 2 microsteps/step = 400 microsteps/rev
- Legacy used only uniform pulse rates (no acceleration/deceleration profiles)

### 8.3 Candidate Replacement Controllers **[TBD]**

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| Galil DMC-4143 | 4-axis motion controller | Industry standard, robust EPICS driver, well-proven | Cost; may be over-specified |
| Domenico/Dunning design | Custom in-house solution | Designed for accelerator applications | Previous reliability issues reported |
| Danh's design | Custom in-house solution | Designed for this application | Needs evaluation |
| MDrive Plus | Schneider Electric integrated motor/driver | Supported by LLRF9 EPICS driver with analog readback for potentiometer; RS-485 interface | Less common at SLAC |

### 8.4 Requirements

1. **EPICS motor record interface** accepting Channel Access commands
2. **Robust 1 Hz update rate** for position commands
3. **Small step sizes**: Modern controllers support up to 256 microsteps/step (vs. legacy 2)
4. **Motion profiles**: Acceleration/deceleration (legacy only used uniform pulse rates)
5. **Step limits**: Driver must prevent excessive motion causing mechanical wear
6. **"Stop and init"**: Ability to realign step counter with potentiometer without physical motion
7. **Home position management**: Define and move to home positions on startup
8. **Power loss handling**: Graceful behavior on power loss
9. **Communication loss handling**: Safe behavior if EPICS connection is lost
10. **Emergency coordination**: If communication fails AND cavity is far out of tune, must be able to signal LLRF9 to shut down

### 8.5 Resolution Calculations

**With legacy 2 microsteps/step (400 microsteps/rev):**
- 20 TPI: 1.27 mm / (2 x 400) = 0.0016 mm/microstep


**With modern controller (microsteps/step TBD):**
- Modern controllers support up to 256 microsteps/step
- 20 TPI at 256 microsteps/step: 1.27 mm / (2 x 51,200) = 0.000012 mm/microstep
- **[TBD]** Verify optimal microstepping setting for Galil controller

> **[RECOMMENDED]** Test the Galil controller with real cavity signal to verify tuner motion on actual cavity before full deployment. Determine optimal microstepping setting for the confirmed 20 TPI lead screw.

### 8.6 Typical Motion Parameters

- **Deadband**: 5 microsteps (legacy RDBD); may be adjusted with higher microstepping
- **Typical startup motion**: ~2.5 mm
- **Normal operation motion**: ~0.2 mm
- **Drive limits**: Upper and lower soft limits to prevent mechanical damage

---

## 9. Arc Detection System

### 9.1 Overview

New capability (non-functional in legacy system). Uses Microstep-MIS optical arc detection sensors.

### 9.2 Sensor Placement

- 2 sensors per cavity (air-side and vacuum-side of each window) = 8 sensors
- Additional sensors on circulator and klystron window
- Each Microstep-MIS receiver handles two sensors

### 9.3 Signal Path

Arc detected -> Microstep-MIS receiver -> dry contact output -> Interface Chassis (optocoupler isolated) -> MPS PLC + LLRF9 disable

### 9.4 Cost Estimate

| Component | Estimated Cost |
|-----------|---------------|
| Sensors | ~$4,700 |
| Receivers | ~$3,200 |
| Cables | ~$900 |
| Adapters | ~$7,000 |
| DB25 cables | ~$200 |
| **Total** | **~$20,000** |

---

## 10. Station State Machine

### 10.1 Active States

The upgrade simplifies the station state machine to **three active states**. The legacy PARK and ON_FM states are eliminated as they were PEP-II artifacts never used at SPEAR3.

| State | Description | RF | HVPS | Tuners | Loops Active |
|-------|-------------|-----|------|--------|-------------|
| **OFF** | System disabled | Output disabled | Off, voltage zeroed | Parked | None |
| **TUNE** | Low-power testing | Low amplitude (~few W drive) | Low voltage (~turn-on minimum) | Active (phase control) | DAC (drive power mode), Tuner |
| **ON_CW** | Full power operation | Full amplitude (~50 W drive, ~3.2 MV gap) | Full voltage (~80-90 kV) | Active (phase control) | All --- DAC, HVPS, Tuner, Load angle |

> **Note on legacy states**: PARK was designed for PEP-II when a station was taken offline while others ran. SPEAR3 has a single station, making PARK unnecessary. ON_FM was for cavity vacuum processing; SPEAR3 demonstrated it can process cavities by varying gap voltage in ON_CW mode (per Jim's operational document). Both can be retained as no-ops in the software for potential future use without any operational impact.

### 10.2 State Transitions

```
         +-----+
    +--->| OFF |<---+
    |    +--+--+    |
    |       |       |
    |       v       |
    |   +------+    |
    +---| TUNE |----+
    |   +--+---+    |
    |      |        |
    |      v        |
    |  +-------+    |
    +--| ON_CW |----+
       +-------+
```

**Allowed transitions:**
- OFF -> TUNE (begin bring-up)
- TUNE -> ON_CW (ramp to full power)
- TUNE -> OFF (shutdown from low power)
- ON_CW -> TUNE (reduce power, maintain tuning)
- ON_CW -> OFF (emergency or normal shutdown)
- Any state -> OFF (fault-driven --- automatic on interlock trip)

> **[RECOMMENDED]** The legacy system allowed OFF -> ON_CW directly (and OFF -> TUNE, OFF -> ON_FM, OFF -> ON_CW all permitted). For the upgrade, enforcing the sequential path OFF -> TUNE -> ON_CW is safer because it ensures tuners are at resonance before ramping to full power. However, a "fast restart" path (OFF -> ON_CW using LLRF9 setpoint profiles) should be implemented for quick recovery after transient faults where tuners haven't drifted.

### 10.3 Turn-On Sequence (OFF -> TUNE -> ON_CW)

**Phase 1: OFF -> TUNE**
1. Verify all interlocks via Interface Chassis (MPS permit, SPEAR MPS, orbit interlock)
2. Move tuners to "TUNE/ON Home" positions
3. Close HVPS contactor
4. Program HVPS to turn-on voltage (~50 kV, `SRF1:HVPS:VOLT:MIN`)
5. Enable LLRF9 RF output at low amplitude
6. Result: A few watts drive power, a few hundred kV gap voltage
7. Tuner loops begin --- sufficient signal for phase measurement

**Phase 2: TUNE -> ON_CW**
1. Verify tuners have converged to resonance (phase error within deadband)
2. Enable LLRF9 direct loop feedback
   - Causes controlled power transient (~45 W before settling to ~10 W)
   - Done at low HVPS voltage to limit klystron output to ~50 kW (safe level)
3. Ramp LLRF9 amplitude setpoint upward (10-20 seconds)
   - Use LLRF9 setpoint profiles (512 points, 70 us-37 ms per step)
4. HVPS loop activates, ramping voltage to maintain drive power at setpoint
5. System converges: ~50 W drive, ~3.2 MV gap voltage, ~1 MW klystron output
6. Enable load angle offset loop for cavity balancing

**Fast Turn-On** (for quick recovery):
- LLRF9 native setpoint profiles replace legacy manual "fast-on value" management
- Profile can ramp from TUNE to full ON_CW amplitude in a controlled trajectory
- HVPS follows via its supervisory loop

### 10.4 Shutdown Sequence (ON_CW -> OFF)

1. Ramp LLRF9 amplitude setpoint to zero (or use setpoint profile for controlled ramp-down)
2. Disable LLRF9 direct loop feedback
3. Ramp HVPS voltage to zero
4. Open HVPS contactor
5. Disable LLRF9 RF output
6. Move tuners to park positions (optional)
7. Update station state to OFF

### 10.5 Fault-Driven Transitions (Any -> OFF)

When the Interface Chassis detects a fault:
1. Hardware layer acts immediately (LLRF9 disabled, HVPS SCR removed)
2. Python coordinator detects fault via EPICS monitoring
3. Python logs fault data: LLRF9 waveform capture, Waveform Buffer frozen data, Interface Chassis first-fault register
4. Python transitions station state to OFF
5. Auto-reset logic evaluates whether to attempt restart (see Section 14.3)

### 10.6 Interlock Requirements per State

| Interlock | Required for TUNE | Required for ON_CW |
|-----------|-------------------|-------------------|
| MPS Summary Permit | Yes | Yes |
| SPEAR MPS | Yes | Yes |
| Orbit Interlock | No | Yes |
| HVPS Ready | Yes | Yes |
| LLRF9 Healthy (both units) | Yes | Yes |
| Arc Detection Clear | Yes | Yes |
| Waveform Buffer Trips Clear | No (low power) | Yes |
| Tuners at resonance | No (converging) | Yes (verify before ramp) |

---

## 11. HVPS Supervisory Control Loop

### 11.1 Purpose

The Python/EPICS HVPS supervisory loop manages the klystron high-voltage setpoint. The HVPS PLC handles low-level voltage regulation; the Python layer provides the high-level setpoint management. This loop must be reimplemented in Python because the HVPS is external to the LLRF9.

### 11.2 Operating Modes

**Mode 1: OFF**
- No voltage control
- Used when station is OFF
- HVPS voltage zeroed, contactor open

**Mode 2: PROCESS (Vacuum Processing)**
- Slowly ramps HVPS voltage while vacuum system removes particles from cavity surfaces
- **Decrease voltage** if: klystron forward power exceeds maximum, gap voltage exceeds setpoint, or cavity vacuum pressure is too high
- **Increase voltage** if all conditions are acceptable
- Used after cavity maintenance to condition surfaces
- Update rate: <=1 Hz

**Mode 3: ON (Normal Regulation)**
- Maintains drive power at setpoint by adjusting HVPS voltage
- As LLRF9 increases RF amplitude -> drive power increases -> HVPS loop increases klystron voltage -> higher klystron gain -> drive power returns to setpoint
- **Dual algorithm** (from legacy, retained for completeness):
  - ON_CW + Direct Loop ON: Regulates based on drive power error
  - TUNE or Direct Loop OFF: Regulates based on gap voltage error
- Update rate: <=1 Hz

### 11.3 Control Algorithm

```
Every ~1 second:
  1. Read drive power from LLRF9 (SRF1:KLYSDRIVFRWD:POWER)
  2. Read gap voltage from LLRF9 (sum of 4 cavity probes)
  3. Read current HVPS voltage from PLC
  4. Compute error:
     - If ON_CW + direct loop: error = drive_power - drive_power_setpoint
     - If TUNE: error = gap_voltage - gap_voltage_setpoint
  5. Apply proportional correction to HVPS voltage setpoint
  6. Enforce limits:
     - Maximum voltage (~90 kV)
     - Minimum voltage (turn-on minimum ~50 kV, or 0 if ramping down)
     - Maximum ramp rate (kV/s)
  7. Send new voltage setpoint to PLC
```

### 11.4 Key Parameters

| Parameter | Legacy PV | Value | Notes |
|-----------|-----------|-------|-------|
| Drive power setpoint (ON) | SRF1:KLYSDRIVFRWD:POWER:ON | ~50 W | Normal operation target |
| Drive power setpoint (HIGH) | SRF1:KLYSDRIVFRWD:POWER:HIGH | configurable | High-power mode |
| HVPS turn-on voltage | SRF1:HVPS:VOLT:MIN | ~50 kV | Minimum operational voltage |
| Maximum HVPS voltage | configurable | ~90 kV | Hardware safety limit |
| Voltage ramp rate | configurable | ~1-5 kV/s | Tunable for conditions |
| Max loop interval | DAC_LOOP_MAX_INTERVAL | 10 s | Timeout for update |

### 11.5 Safety Considerations

- HVPS voltage changes are rate-limited by both the Python layer and the PLC
- The PLC enforces hard voltage and current limits independently of Python
- Hardware interlocks (via Interface Chassis) can disable HVPS independently of software
- Contactor can be opened by PLC on local fault detection without Python involvement
- The HVPS PLC must **not** require continuous Python heartbeats to maintain voltage (PLC maintains last setpoint autonomously)

> **[RECOMMENDED]** Implement a software watchdog in the HVPS supervisory loop: if the Python process fails to update the HVPS setpoint within a configurable timeout (e.g., 30 seconds), the PLC should ramp voltage to a safe low value. This provides defense-in-depth beyond the hardware interlocks.

---

## 12. Tuner Supervisory Control

### 12.1 Architecture

The tuner control is distributed across three components:

1. **LLRF9 Unit 1**: Provides 10 Hz synchronized phase measurements (cavity probe vs. forward power) for all 4 cavities
2. **Python/EPICS coordinator**: Reads phase data, computes position corrections, sends motor commands
3. **Motor controller**: Receives position commands via EPICS motor record, drives stepper motors

### 12.2 Phase-Based Tuning Algorithm

```
Every ~1 second (per cavity):
  1. Read phase measurement from LLRF9 (cavity probe vs. forward)
  2. Compute phase error = phase_setpoint - phase_measured
  3. If |phase_error| < deadband: no action
  4. If |phase_error| >= deadband:
     a. Compute position correction (proportional to phase error)
     b. Check against drive limits (upper/lower soft limits)
     c. Check against load angle limits
     d. Issue position command via EPICS motor record
  5. Monitor motion completion (SM_DONE_MOVING)
  6. If motor stalled after threshold, report fault
```

### 12.3 Load Angle Offset Loop

The load angle offset loop is a **secondary** control that balances gap voltage across the 4 cavities by adjusting the individual tuner phase setpoints.

**Purpose**: Each cavity's contribution to total gap voltage depends on its tuning angle (detuning from resonance). By adjusting each cavity's phase setpoint, the controller balances the power distribution.

**Algorithm**:
- Each cavity has a "strength fraction" setpoint (e.g., SRF1:CAV1:STRENGTH:CTRL)
- The loop reads individual cavity gap voltages from LLRF9
- Computes the deviation from desired strength distribution
- Adjusts individual tuner phase setpoints to correct the balance
- Runs at a slower rate than the primary tuner loop (~0.1 Hz)

**Robinson stability**: The load angle offset must maintain Robinson-stable detuning for each cavity (beam loading drives each cavity below resonance for stability).

### 12.4 Home Position Management

**Two home positions per cavity** (retained from legacy):
- **TUNE/ON Home**: Position for powered operation (tuner near resonance)
- **PARK Home**: Position for unpowered storage

**Reset procedure** (re-alignment of step counter):
1. Read desired home position
2. Read potentiometer (position indication)
3. Calculate delta = home - current
4. If delta < tolerance: done
5. Otherwise: command motor to new position
6. Wait for motion complete; repeat up to max retry count

**"Stop and init"**: Realigns step counter with potentiometer reading without any physical motion. Useful after controller restart or step count loss.

### 12.5 Safety Interlocks for Tuners

- **Power threshold**: Disable tuning if cavity power below threshold (insufficient signal for phase measurement)
- **Drive limits**: Soft limits prevent over-travel
- **Motion timeout**: Detect stalled motors
- **Communication loss**: Motor controller must hold position (no drift) if EPICS connection drops

> **[RECOMMENDED]** Implement a "tuner health monitor" in the Python layer that periodically verifies the step counter position against the potentiometer reading. If they diverge beyond a threshold, pause tuning and alert the operator. This catches step-loss events that could otherwise drive a cavity far out of tune.

---

## 13. Software Architecture

### 13.1 Technology Stack

| Component | Technology | Notes |
|-----------|-----------|-------|
| Supervisory control | Python 3.x + PyEPICS | Station state machine, loops, coordination |
| Fast RF control | LLRF9 built-in FPGA | 270 ns feedback, calibration, interlocks |
| LLRF9 communication | LLRF9 built-in EPICS IOC | Native Channel Access on Ethernet |
| HVPS PLC communication | **[TBD]** pycomm3 / OPC-UA / EtherNet/IP driver | CompactLogix PLC interface |
| Motor control | EPICS motor record | Standard EPICS motor support for chosen controller |
| Configuration | YAML files | Station parameters, limits, tuner calibration |
| Logging | Python logging + EPICS archiver | Structured event logging + data archival |
| Operator interface | EDM panels (existing SPEAR3 infrastructure) | Modernized panels for new system |

### 13.2 Module Architecture

```
spear_llrf/
+-- src/
|   +-- control/
|   |   +-- state_machine.py         # Station state machine (OFF/TUNE/ON_CW)
|   |   +-- hvps_loop.py             # HVPS supervisory control loop
|   |   +-- tuner_manager.py         # 4-cavity tuner coordination
|   |   +-- load_angle.py            # Load angle offset loop
|   |   +-- interlock_coordinator.py # Interface Chassis coordination
|   +-- hardware/
|   |   +-- llrf9_interface.py       # LLRF9 EPICS PV interface (x2 units)
|   |   +-- hvps_interface.py        # HVPS CompactLogix PLC interface
|   |   +-- mps_interface.py         # MPS ControlLogix PLC interface
|   |   +-- motor_interface.py       # Motion controller interface
|   |   +-- waveform_buffer.py       # Waveform Buffer System interface
|   |   +-- interface_chassis.py     # Interface Chassis status monitoring
|   +-- safety/
|   |   +-- interlock_monitor.py     # System-wide interlock monitoring
|   |   +-- fault_handler.py         # Fault detection and recovery
|   |   +-- arc_detection.py         # Arc detection system interface
|   |   +-- first_fault.py           # First-fault analysis and reporting
|   |   +-- collector_protection.py  # Klystron collector power monitoring
|   +-- diagnostics/
|   |   +-- logging.py               # Structured event logging
|   |   +-- waveform_capture.py      # LLRF9 + Waveform Buffer readout
|   |   +-- performance_monitor.py   # System performance metrics
|   +-- main.py                      # Application entry point
+-- config/
|   +-- rf_station.yaml              # Station parameters
|   +-- tuner_params.yaml            # Tuner mechanical parameters
|   +-- safety_limits.yaml           # Safety interlock thresholds
|   +-- interface_chassis.yaml       # Interface Chassis configuration
|   +-- waveform_buffer.yaml         # Waveform Buffer System configuration
|   +-- arc_detection.yaml           # Arc detection system configuration
+-- tests/
|   +-- unit/                        # Unit tests for each module
|   +-- integration/                 # Integration tests
|   +-- hardware/                    # Hardware-in-loop tests
|   +-- safety/                      # Safety system validation tests
+-- docs/
    +-- api/                         # API documentation
    +-- operations/                  # Operations manual
    +-- commissioning/               # Commissioning procedures
    +-- safety/                      # Safety system documentation
```

### 13.3 Core Design Patterns

**Pattern 1: EPICS Monitor-Driven Updates**
```python
# Replace legacy SNL event flags with EPICS CA monitors
# Phase data arrives at 10 Hz from LLRF9; Python processes at ~1 Hz
class TunerManager:
    def __init__(self):
        self.phase_data = {}
        for cav in range(1, 5):
            epics.camonitor(f"LLRF9:U1:CAV{cav}:PHASE", callback=self._phase_update)

    def _phase_update(self, pvname, value, **kwargs):
        # Store latest value; main loop processes at 1 Hz
        cav_id = extract_cavity_id(pvname)
        self.phase_data[cav_id] = value
```

**Pattern 2: State-Aware Control**
```python
# All control modules check station state before acting
class HVPSLoop:
    def update(self):
        state = self.station_state
        if state == 'OFF':
            return  # No HVPS control in OFF state
        elif state == 'TUNE':
            self._regulate_gap_voltage()
        elif state == 'ON_CW':
            self._regulate_drive_power()
```

**Pattern 3: Fault-First Safety**
```python
# Every control cycle starts with safety checks
class ControlCycle:
    def execute(self):
        # 1. Check hardware health
        if not self.verify_all_interlocks():
            self.handle_fault()
            return
        # 2. Check measurement validity
        if not self.verify_measurements():
            self.report_bad_data()
            return
        # 3. Only then apply control
        self.apply_control_action()
```

**Pattern 4: Status Reporting**
```python
# All modules report structured status (matching legacy pattern)
class StatusReporter:
    def __init__(self):
        self.status_code = 'UNKNOWN'      # Machine-readable
        self.status_string = 'Unknown'     # Operator-readable
        self.previous_status = None        # Change detection
    
    def set_status(self, code, message):
        if code != self.previous_status:
            self.log_status_change(code, message)
            self.previous_status = code
        self.status_code = code
        self.status_string = message
```

### 13.4 Main Control Loop

```python
class SPEAR3_LLRF_Coordinator:
    """Main application entry point"""
    
    def run(self):
        self.initialize_all_subsystems()
        
        while self.running:
            cycle_start = time.time()
            
            # 1. Read all inputs (LLRF9, HVPS PLC, MPS, motors, Interface Chassis)
            self.read_all_inputs()
            
            # 2. Update state machine
            self.state_machine.update()
            
            # 3. Run control loops (state-dependent)
            if self.state_machine.state in ('TUNE', 'ON_CW'):
                self.tuner_manager.update()
            if self.state_machine.state == 'ON_CW':
                self.hvps_loop.update()
                self.load_angle.update()
            
            # 4. Check interlocks and faults
            self.interlock_coordinator.check()
            
            # 5. Update outputs and publish status
            self.publish_status()
            
            # 6. Sleep to maintain ~1 Hz (or 10 Hz for tuner phase)
            elapsed = time.time() - cycle_start
            time.sleep(max(0, 1.0 - elapsed))
```

> **[RECOMMENDED]** Use Python `asyncio` for the main control loop rather than a simple sleep-based loop. This allows multiple update rates (10 Hz for tuner phase processing, 1 Hz for HVPS, 0.1 Hz for load angle) without blocking, and enables clean shutdown handling. The `caproto` async EPICS client is a good fit for this pattern.

---

## 14. Fault Management & Diagnostics

### 14.1 Fault Detection Sources

| Source | Detection Speed | Mechanism |
|--------|----------------|-----------|
| LLRF9 RF interlocks | ~35 ns timestamp | Hardware comparators on all 9 RF inputs |
| LLRF9 baseband interlocks | ~35 ns timestamp | Window comparators on 8 slow ADC channels |
| Interface Chassis first-fault | ~us | Hardware latch with priority encoder |
| Waveform Buffer comparators | ~us | Analog comparators with latched output |
| Arc detection | ~us | Microstep-MIS optical sensors |
| MPS PLC | PLC scan rate (~ms) | Digital input processing |
| Python software | ~1 Hz | EPICS monitor callbacks |

### 14.2 Fault Data Capture

On any fault event, the system captures:

1. **LLRF9 waveform data** (per unit): 16,384 samples/channel with adjustable pre/post-trigger ratio. Triggered by hardware interlock event with +/-17.4 ns timestamp resolution.

2. **Waveform Buffer data**: Kilosample circular buffers for 8 RF + 4 HVPS channels, frozen on fault trigger. HVPS channels retain ~100 ms of pre-fault data.

3. **Interface Chassis first-fault register**: Identifies which input faulted first in a cascade.

4. **LLRF9 interlock event log**: Timestamped sequence of all interlock events across both units.

5. **Python-level logging**: Station state, control loop values, EPICS PV snapshots at time of fault.

### 14.3 Auto-Reset Logic

The auto-reset feature attempts automatic recovery from transient faults (beam trips, transient interlocks):

**Conditions for auto-reset:**
- Auto-reset is enabled (operator configurable)
- The fault has cleared (all interlocks restored)
- HVPS contactor status is OK (hardware safety verified)
- Retry count has not exceeded maximum (configurable)
- Configurable delay between attempts

**Exclusions:**
- No auto-reset if contactor fault (hardware safety issue)
- No auto-reset if arc detection triggered (requires investigation)
- No auto-reset if HVPS fault (requires investigation)

**Sequence:**
1. Fault detected -> station transitions to OFF
2. Wait for all interlocks to clear
3. Wait configurable delay
4. If auto-reset conditions met: begin OFF -> TUNE -> ON_CW sequence
5. If turn-on fails, increment retry counter
6. After max retries, remain in OFF and alert operator

> **[RECOMMENDED]** Implement an exponential backoff for auto-reset delays (e.g., 5s, 10s, 20s, 40s). This prevents rapid cycling on persistent faults while allowing quick recovery from truly transient events. Also log each auto-reset attempt with full fault context for post-analysis.

### 14.4 First-Fault Analysis

The Interface Chassis first-fault register, combined with LLRF9 timestamps, enables root-cause analysis:

```
Example fault sequence:
  t=0.000 us: Cavity 3 reflected power exceeds threshold (LLRF9 Unit 2)
  t=0.270 us: LLRF9 Unit 1 drive zeroed (via daisy-chain from Unit 2)
  t=0.500 us: LLRF9 Status goes LOW (Unit 1 reports fault)
  t=1.000 us: Interface Chassis records LLRF9 as first-fault source
  t=1.500 us: Interface Chassis removes HVPS SCR ENABLE
  t=2.000 us: HVPS STATUS goes LOW
  
Root cause: Cavity 3 reflected power event (possible arc or beam abort)
```

### 14.5 Diagnostic Tools

| Tool | Source | Purpose |
|------|--------|---------|
| LLRF9 network analyzer | LLRF9 built-in | Measure transfer function, identify loop instabilities |
| LLRF9 spectrum analyzer | LLRF9 built-in | Identify spectral content, noise sources |
| Waveform capture (16k) | LLRF9 | Detailed RF signal analysis around fault events |
| Waveform Buffer readout | Waveform Buffer System | Extended RF/HVPS signal analysis |
| First-fault report | Interface Chassis via MPS | Identify initiating fault in cascading events |
| Python event log | Python logging | Full operational history with timestamps |
| EPICS archiver | SPEAR3 infrastructure | Long-term trend analysis of all published PVs |

---

## 15. EPICS Process Variable Architecture

### 15.1 PV Naming Convention

The upgrade uses the existing SPEAR3 PV naming where possible for operator familiarity, with new PVs for new subsystems:

**Retained PV prefixes** (backward-compatible where practical):
- `SRF1:` --- Station-level RF PVs
- `SRF1:HVPS:` --- HVPS-related PVs
- `SRF1:CAV1:` through `SRF1:CAV4:` --- Cavity-specific PVs
- `SRF1:CAV1TUNR:` through `SRF1:CAV4TUNR:` --- Tuner-specific PVs

**New PV prefixes** for upgrade subsystems:
- `LLRF9:U1:` / `LLRF9:U2:` --- LLRF9 Unit 1 and 2 internal PVs (from built-in IOC)
- `SRF1:IC:` --- Interface Chassis status PVs
- `SRF1:WFB:` --- Waveform Buffer System PVs
- `SRF1:ARC:` --- Arc detection PVs
- `SRF1:MPS:` --- MPS status PVs

### 15.2 Key PV Groups

**Station Control:**
```
SRF1:STN:STATE              # Current station state (OFF/TUNE/ON_CW)
SRF1:STN:STATE:CMD          # Requested state change
SRF1:STN:PERMIT             # Overall station permit
SRF1:STN:FAULT              # Fault status summary
SRF1:STN:AUTORESET:ENABLE   # Auto-reset enable/disable
SRF1:STN:AUTORESET:COUNT    # Current auto-reset attempt count
```

**RF Control (via LLRF9):**
```
LLRF9:U1:AMPL:SP            # Amplitude setpoint
LLRF9:U1:AMPL:RB            # Amplitude readback
LLRF9:U1:PHASE:SP           # Phase setpoint
LLRF9:U1:PHASE:RB           # Phase readback
LLRF9:U1:DIRECT:GAIN        # Direct loop gain
LLRF9:U1:INTEG:GAIN         # Integral loop gain
LLRF9:U1:ENABLE             # RF output enable
LLRF9:U1:PERMIT             # RF permit status
```

**HVPS:**
```
SRF1:HVPS:VOLT:CTRL         # Voltage setpoint to PLC
SRF1:HVPS:VOLT:RB           # Voltage readback from PLC
SRF1:HVPS:CURR:RB           # Current readback from PLC
SRF1:HVPS:STATUS            # HVPS status word
SRF1:HVPS:CONTACTOR         # Contactor command
SRF1:HVPS:VOLT:MIN          # Turn-on voltage threshold
```

**Tuners (per cavity, x4):**
```
SRF1:CAV1TUNR:PHASE:MEAS    # Phase measurement from LLRF9
SRF1:CAV1TUNR:PHASE:SP      # Phase setpoint
SRF1:CAV1TUNR:POSN:SP       # Motor position setpoint
SRF1:CAV1TUNR:POSN:RB       # Motor position readback
SRF1:CAV1TUNR:POSN:POT      # Potentiometer reading
SRF1:CAV1TUNR:POSN:ONHOME   # ON home position
SRF1:CAV1TUNR:POSN:PARKHOME # Park home position
SRF1:CAV1TUNR:STATUS         # Tuner status
SRF1:CAV1:STRENGTH:CTRL     # Cavity strength fraction for load angle
```

**Interface Chassis:**
```
SRF1:IC:FIRSTFAULT          # First-fault register (which input faulted first)
SRF1:IC:LLRF9:STATUS        # LLRF9 status input state
SRF1:IC:HVPS:STATUS         # HVPS STATUS input state
SRF1:IC:SPEAR:MPS           # SPEAR MPS permit state
SRF1:IC:ORBIT:INTLCK        # Orbit interlock state
SRF1:IC:ARC:PERMIT          # Arc detection permit state
SRF1:IC:WFBUF:PERMIT        # Waveform Buffer permit state
SRF1:IC:LLRF9:ENABLE        # LLRF9 Enable output state
SRF1:IC:HVPS:SCRENABLE      # HVPS SCR ENABLE output state
```

**Waveform Buffer System:**
```
SRF1:WFB:RF1:POWER          # RF channel 1 averaged power
...
SRF1:WFB:RF8:POWER          # RF channel 8 averaged power
SRF1:WFB:HVPS:VOLTAGE       # HVPS voltage from buffer
SRF1:WFB:HVPS:CURRENT       # HVPS current from buffer
SRF1:WFB:COLLECTOR:POWER    # Calculated collector power
SRF1:WFB:COLLECTOR:TRIP     # Collector power trip status
SRF1:WFB:RF1:WAVEFORM       # RF channel 1 frozen waveform (on fault)
```

> **Note**: Actual LLRF9 PV names will be determined by the Dimtel IOC database configuration. The prefixes shown above are representative and should be finalized during commissioning.

---

## 16. Implementation Phases & Commissioning

### 16.1 Project Constraints

**Critical Constraint**: The SPEAR3 LLRF upgrade has **extremely limited flexibility for integration testing** since bringing systems online directly impacts SPEAR operations. This severely constrains the available testing window and requires a fundamentally different approach than typical development projects.

**Key Implications**:
- Maximum standalone subsystem testing must occur before installation
- Integration testing must be incremental and carefully planned
- Some subsystems can be brought online for limited testing without full operational impact
- Full system integration testing window is minimal

### 16.2 Current Project Status Summary

| Subsystem | Current Status | Next Critical Step |
|-----------|---------------|-------------------|
| **Tuner Motor Controller** | Galil controller ready, can drive motor | Test with real cavity signal, verify motion on actual cavity |
| **HVPS Controller** | Upgraded prototype exists | PLC replacement needed to bring system online for EPICS development |
| **MPS** | Hardware assembled, software written, tested without RF power | Bring online for EPICS software development |
| **Waveform Buffer** | Prototype design complete, PCB fabricated | Assembly and testing |
| **Interface Chassis** | Interfaces specified | Design and fabrication |
| **Arc Detection** | Concept exists | Procurement and installation |
| **Python/EPICS Software** | Conceptual design only | Development requires live subsystems |

### 16.3 Revised Implementation Strategy

**Phase 1: Maximum Standalone Development**
- **HVPS PLC Replacement**: Priority #1 — enables EPICS software development
- **MPS Online**: Bring MPS online for EPICS interface development
- **Waveform Buffer Assembly**: Complete assembly and standalone testing
- **Interface Chassis Design/Fab**: Complete design and fabrication
- **Python Framework**: Develop with simulated interfaces where live hardware unavailable

**Phase 2: Incremental Subsystem Integration**
- **Tuner Testing**: Test Galil controller with real cavity signal (can be done with minimal operational impact)
- **HVPS Integration**: Integrate HVPS PLC with Python/EPICS (can test at low voltage)
- **MPS Integration**: Integrate MPS with Python coordinator
- **Waveform Buffer Integration**: Install and test with existing RF signals

**Phase 3: Critical Path Integration**
- **Interface Chassis Installation**: Install and connect all interlock signals
- **Arc Detection Installation**: Install sensors and integrate with Interface Chassis
- **End-to-End Interlock Testing**: Verify complete interlock chain (limited RF power)

**Phase 4: LLRF9 Integration (Dimtel Support Week)**
- **LLRF9 Installation**: Install both units, connect RF signals
- **Basic RF Processing**: Verify vector sum, feedback loops, calibration
- **EPICS Integration**: Configure IOC, verify all PV interfaces
- **Limited Power Testing**: Test with reduced power levels

**Phase 5: Full Power Commissioning**
- **Incremental Power Ramp**: Gradually increase power while monitoring all systems
- **Performance Validation**: Verify meets all success criteria
- **Operator Training**: Train operators on new system
- **Documentation**: Complete commissioning report

### 16.4 Risk Mitigation Strategies

**Strategy 1: Parallel Development Paths**
- Develop Python software with simulated hardware interfaces
- Use LLRF9 bench testing for software development where possible
- Prepare all mechanical/electrical work in advance

**Strategy 2: Incremental Integration**
- Bring subsystems online individually for EPICS development
- Test interlock chains at component level before full integration
- Use existing RF signals for Waveform Buffer testing

**Strategy 3: Minimize On-Machine Time**
- Complete maximum fabrication/assembly off-machine
- Pre-test all cables, connections, and interfaces
- Have backup plans for all critical components

**Strategy 4: Staged Power Testing**
- Begin integration at lowest possible power levels
- Incrementally increase power only after verifying each subsystem
- Maintain ability to revert to legacy system if needed

### 16.5 Dimtel Commissioning Support Window

Dimtel offers **one week** of on-site commissioning support. Given the constrained testing environment, this window must be used optimally:

**Pre-Dimtel Requirements** (must be 100% complete):
- All RF cables fabricated and tested
- Interface Chassis installed and tested
- Waveform Buffer installed and tested
- Python framework tested with all available hardware
- MPS and HVPS integration complete
- All mechanical installation complete

**Dimtel Week Focus**:
1. LLRF9 installation and RF signal routing verification
2. Basic RF processing validation (vector sum, feedback loops)
3. Calibration system commissioning
4. EPICS IOC configuration and PV verification
5. Interlock system checkout with LLRF9
6. Limited power testing and loop tuning
7. Documentation of any configuration changes

### 16.6 Success Criteria

| Metric | Legacy Performance | Target |
|--------|-------------------|--------|
| Amplitude stability | < 0.1% | Same or better |
| Phase stability | < 0.1 deg | Same or better |
| Tuner resolution | ~0.002-0.003 mm/microstep | Improved (higher microstepping) |
| Control loop response | ~1 second | Same or better |
| Uptime | > 99.5% | Same or better |
| Fault diagnostics | Limited fault file capture | 16k waveform + kilosample buffers + first-fault |
| Calibration time | ~20 minutes | ~3 minutes (LLRF9 digital) |
| First-fault identification | Manual analysis | Hardware first-fault detection |

### 16.7 Critical Path Items

**Immediate Priority (blocks all software development)**:
1. HVPS PLC replacement and bring online
2. MPS bring online for EPICS development

**High Priority (required for integration)**:
3. Waveform Buffer assembly and testing
4. Interface Chassis design and fabrication
5. Tuner testing with real cavity signal

**Medium Priority (required for commissioning)**:
6. Arc detection procurement and installation
7. Python/EPICS software development
8. End-to-end interlock testing

The success of this project depends critically on maximizing standalone development and testing before the limited integration window.

---

## 17. Open Engineering Decisions

The following items require final engineering decisions before detailed design can proceed:

### 17.1 Hardware Decisions

| Item | Options | Impact | Priority |
|------|---------|--------|----------|
| **Tuner motor controller** | Galil DMC-4143 / Domenico-Dunning / Danh / MDrive Plus | Affects all tuner software, EPICS driver, reliability | High |
| **Lead screw pitch verification** | Measure actual hardware (10 TPI vs 20 TPI) | Affects all tuner resolution and motion parameters | High |
| **Waveform Buffer digitizer** | Custom PCB / FPGA-based (Red Pitaya) / commercial ADC | Affects fabrication timeline and EPICS integration | Medium |
| **Interface Chassis PCB layout** | Design from specification | Required for Phase 4 | Medium |

### 17.2 Software/Communication Decisions

| Item | Options | Impact | Priority |
|------|---------|--------|----------|
| **HVPS PLC EPICS driver** | pycomm3 / OPC-UA / custom EtherNet/IP | Affects HVPS control software development | Medium |
| **LLRF9 PV naming** | Confirm with Dimtel IOC database | Affects all Python interface code | Medium |
| **Slow power monitor ADC** | What hardware digitizes MCL detector outputs? | Affects Waveform Buffer System design | Medium |
| **LLRF9 tuner interface mode** | Delta-move commands or absolute position targets? | Affects tuner manager design | High |

### 17.3 Operational Decisions

| Item | Options | Impact | Priority |
|------|---------|--------|----------|
| **State machine: keep PARK/ON_FM?** | Keep as no-ops / Remove entirely | Minor code impact; operator familiarity | Low |
| **Auto-reset policy** | Which fault types allow auto-reset? | Affects uptime and safety | Medium |
| **Operator interface** | EDM panels / CS-Studio / Phoebus / Web | Affects development effort | Low (EDM default) |
| **LLRF9 calibration workflow** | Manual steps required? Operator interaction? | Affects operations procedures | Medium |

### 17.4 Procurement

| Item | Cost Estimate | Status |
|------|--------------|--------|
| LLRF9 units (x4) | Complete | Procured |
| MPS PLC modules | Complete | Procured |
| HVPS PLC modules | Complete | Procured |
| Enerpro boards (x5) | ~$4,000 | Needed |
| Arc detection system | ~$20,000 | Needed |
| Waveform Buffer RF detectors | ~$1,700 | Needed |
| Interface Chassis fabrication | TBD | Needed |
| Waveform Buffer fabrication | TBD | Needed |
| **Total remaining** | **< $50,000** | Fundable from operational budget |

---

## Appendix A: Legacy-to-Upgrade Function Mapping

This table provides the complete mapping of every legacy function to its upgrade-system location.

| Legacy Function | Legacy File | Upgrade Owner | Notes |
|----------------|-------------|---------------|-------|
| Fast RF feedback | RFP analog | LLRF9 FPGA | 270 ns direct loop; dual redundancy |
| DAC control loop | rf_dac_loop.st | LLRF9 setpoint + Python supervisory | 4-way branching eliminated |
| HVPS control loop | rf_hvps_loop.st | Python hvps_loop.py + CompactLogix PLC | PLC regulates; Python supervises |
| Tuner control (x4) | rf_tuner_loop.st | LLRF9 phase + Python tuner_manager + motor ctrl | 10 Hz phase; ~1 Hz motor commands |
| Load angle offset | rf_tuner_loop.st | Python load_angle.py | Balances 4-cavity gap voltage |
| Station state machine | rf_states.st | Python state_machine.py | Hardware safety in Interface Chassis |
| Fast turn-on | rf_statesFAST | LLRF9 setpoint profiles + Python | 512 pts, 70 us-37 ms/step |
| Calibration | rf_calib.st | LLRF9 internal digital | 2800 lines eliminated |
| Fault files | rf_statesFF | LLRF9 waveform capture + Waveform Buffer | 16k samples + kilosample buffers |
| Message logging | rf_msgs.st | Python logging + Interface Chassis first-fault | Structured logging |
| TAXI monitoring | rf_msgsTAXI | Eliminated | CAMAC no longer used |
| Ripple loop | Analog hardware | LLRF9 digital feedback | Inherent rejection |
| Comb/GFF loops | CFM/GVF modules | LLRF9 digital feedback | FPGA handles all |
| **NEW** Interface coordination | N/A | Interface Chassis + Python | Central interlock hub |
| **NEW** Extended monitoring | N/A | Waveform Buffer System | 8 RF + 4 HVPS channels |
| **NEW** Arc detection | N/A | Microstep-MIS -> Interface Chassis -> MPS | Optical sensors |
| **NEW** Collector protection | N/A | Waveform Buffer + MPS PLC | Redundant DC-RF calculation |

---

## Appendix B: Source Material References

| Source | Content | Key Information |
|--------|---------|-----------------|
| Docs/llrf9_manual_print.pdf | Dimtel LLRF9 Technical Manual v1.5 | Hardware specs, feedback architecture, interlock system, configurations |
| Docs/LLRFOperation_jims.docx | Jim's SPEAR3 RF Station Operation Guide | Control hierarchy, tuner mechanics, turn-on sequences, tuner gear ratios |
| Docs/LLRFUpgradeTaskListRev3.docx | LLRF Upgrade Task List Rev 3 (July 2025) | Full project scope, procurement, interface specs, cost estimates |
| Docs/WaveformBuffersforLLRFUpgrade.docx | Waveform Buffer System Design (J. Sebek, Jan 2026) | RF/HVPS monitoring, circular buffers, comparator trips, collector protection |
| Docs/llrfInterfaceChassis.docx | Interface Chassis Specification (J. Sebek) | Signal routing, isolation, first-fault detection, LLRF9/HVPS interface |
| SPEAR3_LLRF_COMPREHENSIVE_ANALYSIS.md | Full system analysis (legacy + upgrade) | Complete technical reference for both systems |
