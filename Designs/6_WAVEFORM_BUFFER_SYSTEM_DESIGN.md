# SPEAR3 Waveform Buffer System Design Report

**Document ID**: SPEAR3-LLRF-DR-006
**Title**: Waveform Buffer System --- Signal Monitoring, Circular Buffers, and Klystron Collector Protection
**Author**: LLRF Upgrade Team
**Date**: March 2026
**Version**: 1.0
**Status**: Design Phase --- PCB Fabricated, Assembly and Integration Pending

**Reference Documents**:
| Document | Location | Content |
|----------|----------|---------|
| System Overview | Designs/1_Overview of Current and Upgrade System.md | Waveform Buffer in upgrade scope (Section 4.6) |
| LLRF9 System Report | Designs/3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md | LLRF9 acquisition and interlock capabilities |
| HVPS Technical Note | Designs/4_HVPS_Engineering_Technical_Note.md | HVPS signal monitoring (Section 14.6) |
| Software Design | Designs/9_SOFTWARE_DESIGN.md | Python coordinator Waveform Buffer interface |
| Interface Chassis Design | Designs/11_INTERFACE_CHASSIS_DESIGN.md | Comparator trip integration |
| MPS Design | Designs/10_MACHINE_PROTECTION_SYSTEM_DESIGN.md | Redundant collector protection |
| Waveform Buffer Spec | Docs_JS/WaveformBuffersforLLRFUpgrade.docx | J. Sebek original specification (Jan 2026) |
| LLRF Upgrade Task List | Docs_JS/LLRFUpgradeTaskListRev3.docx | Procurement status and cost estimates |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Purpose and Rationale](#2-system-purpose-and-rationale)
3. [System Architecture Overview](#3-system-architecture-overview)
4. [RF Signal Monitoring --- 8 Channels](#4-rf-signal-monitoring--8-channels)
5. [HVPS Signal Monitoring --- 4 Channels](#5-hvps-signal-monitoring--4-channels)
6. [Signal Conditioning and ADC Architecture](#6-signal-conditioning-and-adc-architecture)
7. [Circular Buffer Design](#7-circular-buffer-design)
8. [Analog Comparator Trip Circuits](#8-analog-comparator-trip-circuits)
9. [Klystron Collector Power Protection](#9-klystron-collector-power-protection)
10. [Interface to Other Subsystems](#10-interface-to-other-subsystems)
11. [EPICS Integration and PV Database](#11-epics-integration-and-pv-database)
12. [Normal Operation Mode](#12-normal-operation-mode)
13. [Hardware Implementation](#13-hardware-implementation)
14. [Implementation Status and Next Steps](#14-implementation-status-and-next-steps)

---

## 1. Executive Summary

The Waveform Buffer System is a new subsystem in the SPEAR3 LLRF upgrade that provides extended signal monitoring, waveform capture, and hardware trip capability for RF and HVPS signals not covered by the LLRF9 controllers 18 channels (2 units x 9 channels). It is a distinct, standalone chassis --- separate from the LLRF9 --- that fills the monitoring gap left when the legacy 24-channel VXI system is retired.

The system serves three critical functions:

1. **Extended RF Signal Monitoring**: 8 channels capturing klystron output, circulator load, and waveguide load power signals with circular waveform buffers and hardware-triggered fault capture.
2. **HVPS Diagnostics**: 4 channels monitoring HVPS voltage, current, and transformer voltages to diagnose HVPS-caused beam dumps with ~100 ms pre-fault data.
3. **Klystron Collector Power Protection**: Real-time computation of collector dissipation (DC Power minus RF Power) with hardware trip on excess --- a safety-critical function protecting the non-full-power-collector klystron.

**Status**: PCB fabricated (as of design documents). Assembly, firmware development, and integration testing are pending. RF detectors (~\.7k) and chassis fabrication are outstanding procurement items.

---

## 2. System Purpose and Rationale

### 2.1 Monitoring Gap Analysis

The legacy VXI-based system monitors 24 RF signals. The two LLRF9 units cover the 18 most critical channels (9 per unit). The remaining signals --- primarily related to the klystron output, circulator, and waveguide loads --- are not monitored by the LLRF9 and require the Waveform Buffer System.

Additionally, the legacy system provides no dedicated HVPS waveform diagnostics. When the HVPS causes a beam dump, operators currently have no fast waveform data to diagnose root cause. The Waveform Buffer System addresses this by providing kilosample-depth circular buffers that freeze on fault trigger.

### 2.2 Klystron Collector Protection Need

The SPEAR3 klystron uses a non-full-power collector, meaning the collector cannot absorb the full DC beam power indefinitely. Under normal operation, most DC power is converted to RF output power. If the RF output drops (e.g., due to a fault or cavity detuning) while the HVPS remains on, the collector dissipation rises rapidly. Without protection, this can damage or destroy the klystron.

The Waveform Buffer System provides the primary hardware-based collector power protection by computing:



If Collector_Power exceeds a configurable safe limit, the system issues a hardware trip signal to the Interface Chassis, which removes the HVPS SCR ENABLE to shut down the HVPS.

---

## 3. System Architecture Overview

### 3.1 Block Diagram



### 3.2 System Parameters Summary

| Parameter | RF Channels | HVPS Channels |
|-----------|-------------|---------------|
| **Number of channels** | 8 | 4 |
| **ADC resolution** | 12-bit | 12-bit |
| **Sampling rate** | ~1 MHz | ~160 kHz (averaged by ~4 from 1 MHz) |
| **Buffer depth** | Kilosamples | ~16k samples (~100 ms at reduced rate) |
| **Signal conditioning** | RF detectors + op-amp | Voltage dividers |
| **Comparator trips** | Yes (per-channel) | Yes (per-channel) |
| **Buffer trigger** | Fault event (freeze) | Fault event (freeze) |
| **Normal operation** | Averaged data at ~1 Hz | Averaged data at ~1 Hz |

---

## 4. RF Signal Monitoring --- 8 Channels

### 4.1 Channel Assignment

| Channel | Signal | Notes |
|---------|--------|-------|
| RF-1 | Klystron Output Forward Power | Primary klystron output measurement |
| RF-2 | Klystron Output Reflected Power | Klystron load mismatch indicator |
| RF-3 | Circulator Load Forward Power | Appreciable power at low beam current |
| RF-4 | Circulator Load Reflected Power | Circulator health monitor |
| RF-5 | Waveguide Load 1 Forward Power | Sum of reflected from all 4 cavities |
| RF-6 | Waveguide Load 1 Reflected Power | Waveguide network health |
| RF-7 | Waveguide Load 2 Forward Power | Sum of reflected from Cavities A and B |
| RF-8 | Waveguide Load 2 Reflected Power | Waveguide network health |

### 4.2 RF Detectors

- **Component**: Mini-Circuits ZX47-40LN+ logarithmic RF power detector
- **Frequency range**: 10 MHz to 8 GHz (covers 476 MHz RF frequency)
- **Dynamic range**: -40 dBm to +20 dBm
- **Output voltage**: 0.5 to 2.0 V into 50 ohm load
- **Output type**: Negative-slope logarithmic (lower voltage = higher power)
- **Rise time**: < 50 ns
- **Flatness**: +/- 1 dB over frequency range

### 4.3 Signal Path

Each RF channel follows this signal path:

1. **RF coupler/pickoff** at the measurement point (existing infrastructure)
2. **Coaxial cable** to Waveform Buffer chassis
3. **ZX47-40LN+ detector** converts RF envelope to DC voltage (0.5--2.0 V)
4. **Op-amp buffer/conditioning** scales and filters the detector output for ADC input range
5. **ADC input** (12-bit, ~1 MHz sampling)
6. **Parallel path**: Detector output also feeds **analog comparator** for hardware trip

---

## 5. HVPS Signal Monitoring --- 4 Channels

### 5.1 Channel Assignment

| Channel | Signal | Purpose | Buffer Requirement |
|---------|--------|---------|--------------------|
| HVPS-1 | HVPS Output Voltage | Diagnose HVPS-caused beam dumps | ~100 ms pre-fault |
| HVPS-2 | HVPS Output Current | Diagnose HVPS-caused beam dumps | ~100 ms pre-fault |
| HVPS-3 | Transformer 1 Voltage | Detect thyristor firing circuit faults | ~100 ms pre-fault |
| HVPS-4 | Transformer 2 Voltage (or Phase Current) | Detect thyristor firing circuit faults | ~100 ms pre-fault |

### 5.2 Signal Conditioning

The HVPS signals are at high voltage and current levels that must be reduced to the ADC input range:

- **HVPS Voltage (up to ~90 kV)**: Resistive voltage divider network reduces to 0--10 V range, then scaled to ADC input range. The existing HVPS infrastructure includes a 100 Mohm voltage divider in the crowbar tank that produces a proportional low-voltage output.
- **HVPS Current (up to ~27 A)**: **Danfysik DC-CT current transducer** output (located in the grounding tank) provides an isolated, proportional voltage signal. This is the same transducer used by the legacy system for current feedback.
- **Transformer Voltages**: Monitor winding outputs from the **phase-shifting transformer** (located in B118 HVPS controller Hoffman Box) provide ~100 V peak-to-peak signals with 2 Mohm source impedance. These are conditioned through precision voltage dividers.
- **HVPS Regulation**: The **Enerpro FCOG voltage/current regulator board** provides precision feedback control for HVPS output. Monitor signals from this board may also be captured for diagnostics.

### 5.3 Longer Buffer Requirement

HVPS failures can precede the system trip by up to ~100 ms. To capture the full fault evolution:

- Raw sampling at ~1 MHz would require ~100,000 samples per channel (excessive memory)
- **Solution**: Average by a factor of ~4 to ~6, reducing effective sampling rate to ~160--250 kHz
- This yields ~16,000--25,000 samples for 100 ms, fitting within practical buffer sizes (~16k samples)
- The reduced bandwidth (~80--125 kHz) is more than adequate for HVPS dynamics (60 Hz power line, ~1 kHz ripple)

---

## 6. Signal Conditioning and ADC Architecture

### 6.1 ADC Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Resolution** | 12-bit | Sufficient for power monitoring (0.024% of full scale) |
| **Sampling rate** | ~1 MHz (RF), ~160 kHz effective (HVPS) | HVPS channels use averaging |
| **Input range** | 0--3.3 V or 0--5 V (TBD based on ADC selection) | Matched to signal conditioning output |
| **Number of channels** | 12 total (8 RF + 4 HVPS) | May use multi-channel ADC ICs |
| **Interface** | SPI or parallel to FPGA/MCU | Depends on ADC selection |

### 6.2 Op-Amp Signal Conditioning (RF Channels)

The ZX47-40LN+ detector outputs 0.5--2.0 V into 50 ohm. The op-amp conditioning stage provides:

1. **Impedance buffering**: High input impedance to avoid loading the detector
2. **Level shifting/scaling**: Map 0.5--2.0 V detector range to full ADC input range
3. **Anti-aliasing filter**: Low-pass filter at ~500 kHz (Nyquist/2 for 1 MHz sampling)
4. **Dual output**: One output to ADC, one output to analog comparator

### 6.3 Voltage Divider Conditioning (HVPS Channels)

- Precision resistor dividers with temperature-stable components
- Low-pass filtering to reject high-frequency noise
- Isolation considerations for high-voltage signals (existing infrastructure provides galvanic isolation via the Danfysik current transducer and transformer monitor windings)

---

## 7. Circular Buffer Design

### 7.1 Operating Principle

Each channel maintains a circular (ring) buffer in FPGA or MCU memory:



- **Normal operation**: Write pointer advances continuously, overwriting the oldest data
- **Fault trigger**: Write pointer stops (buffer freeze), preserving pre-fault and post-fault data
- **Post-trigger samples**: Configurable number of samples acquired after trigger before freeze
- **Readout**: After freeze, buffer contents read out via EPICS PVs

### 7.2 Buffer Sizing

| Channel Type | Sampling Rate | Buffer Depth | Time Coverage |
|--------------|---------------|--------------|---------------|
| RF channels | ~1 MHz | ~4,096 samples | ~4 ms |
| HVPS channels | ~160 kHz | ~16,384 samples | ~100 ms |

### 7.3 Trigger Sources

The buffer freeze can be triggered by:

1. **Internal comparator trip**: Any analog comparator on this chassis exceeds threshold
2. **External trigger from Interface Chassis**: System-wide fault event
3. **Software trigger**: Manual trigger from Python coordinator via EPICS PV
4. **Cross-channel trigger**: Trip on one channel freezes all channel buffers simultaneously

All triggers are OR-ed: any single trigger freezes all buffers to maintain time alignment.

---

## 8. Analog Comparator Trip Circuits

### 8.1 Design Concept

Each RF and HVPS channel includes a dedicated analog comparator circuit that provides a fast hardware trip independent of the digital processing:



### 8.2 Comparator Specifications

| Parameter | Value |
|-----------|-------|
| **Type** | Window comparator (over/under threshold) or single-threshold |
| **Response time** | < 1 microsecond |
| **Output** | Latched digital signal (remains tripped until reset) |
| **Threshold setting** | Configurable via DAC or precision potentiometer |
| **Reset** | External reset signal from Interface Chassis (via MPS) |

### 8.3 Trip Output Integration

- Each comparator latched output feeds into the Interface Chassis as a **Power Signal Permit** input
- The Interface Chassis combines these with other permit signals in its master interlock logic
- Loss of any Power Signal Permit causes the Interface Chassis to:
  - Remove LLRF9 Enable (LLRF9 zeros drive and opens RF switch)
  - Remove HVPS SCR ENABLE (HVPS thyristors stop firing)
  - Latch the fault in the first-fault register

---

## 9. Klystron Collector Power Protection

### 9.1 Protection Algorithm

The klystron collector absorbs the difference between DC input power and RF output power. For non-full-power collector tubes, this difference must be kept below a safe limit.

**Algorithm**:


### 9.2 Implementation

- **Primary path (hardware)**: Analog multiplier/computation circuit provides fast trip
- **Secondary path (firmware)**: FPGA/MCU performs the same calculation digitally and asserts a second trip output
- **Tertiary path (MPS)**: Buffered HVPS voltage, current, and RF power signals are also sent to the MPS PLC, which performs a redundant software calculation

### 9.3 Collector Limit Setting

The collector power limit is determined by klystron specifications:

| Parameter | Typical Value | Notes |
|-----------|---------------|-------|
| **Maximum DC power** | ~2.5 MW (90 kV x 27 A) | Absolute maximum HVPS output |
| **Nominal DC power** | ~1.6 MW (74.7 kV x 22 A) | At 500 mA beam current |
| **Nominal RF output** | ~1 MW | At full operating conditions |
| **Nominal collector dissipation** | ~0.6 MW | DC - RF under normal conditions |
| **Collector limit** | TBD (based on klystron datasheet) | Must include safety margin |

### 9.4 Failure Mode Analysis

| Failure | Effect | Protection |
|---------|--------|------------|
| RF output drops to zero, HVPS stays on | Full DC power on collector (~1.6 MW) | Hardware trip within microseconds |
| HVPS voltage spikes | Increased DC power, collector stress | HVPS comparator trip + collector calculation |
| One HVPS channel fails | Incorrect calculation | Redundant MPS PLC calculation from separate sensors |
| Waveform Buffer power loss | No collector protection from this system | MPS PLC provides backup; LLRF9 interlocks provide partial coverage |

---

## 10. Interface to Other Subsystems

### 10.1 Interface Chassis

| Signal | Direction | Type | Purpose |
|--------|-----------|------|---------|
| Power Signal Permit | WB -> IC | Digital (optocoupler) | Combined comparator trip status |
| Collector Power Trip | WB -> IC | Digital (optocoupler) | Dedicated collector protection trip |
| Buffer Freeze Trigger | IC -> WB | Digital | System-wide fault trigger to freeze buffers |
| Reset | IC -> WB (via MPS) | Digital | Clear latched comparator trips |

### 10.2 MPS PLC (ControlLogix 1756)

| Signal | Direction | Type | Purpose |
|--------|-----------|------|---------|
| Buffered HVPS Voltage | WB -> MPS | Analog | Redundant collector power calculation |
| Buffered HVPS Current | WB -> MPS | Analog | Redundant collector power calculation |
| Buffered RF Power | WB -> MPS | Analog | Redundant collector power calculation |
| Comparator Status | WB -> MPS | Digital | Individual channel trip status |

### 10.3 LLRF9

The Waveform Buffer System operates independently of the LLRF9 but complements it:

- LLRF9 provides 18 channels of fast RF monitoring with 16k-sample waveform capture and hardware interlocks
- Waveform Buffer provides the remaining 8 RF + 4 HVPS channels plus collector protection
- Both systems feed into the Interface Chassis interlock logic

### 10.4 Python Coordinator

The Python/EPICS coordinator interfaces with the Waveform Buffer System for:

- Configuration of comparator thresholds
- Readout of circular buffer contents after fault events
- Monitoring of averaged signal levels during normal operation
- Logging of collector power trends

---

## 11. EPICS Integration and PV Database

### 11.1 IOC Architecture

The Waveform Buffer System includes a dedicated EPICS IOC (either embedded in the chassis or running on an external Linux host) that exposes all channels and control functions as process variables.

### 11.2 Process Variable Database

**RF Channel Readbacks (per channel, n = 1--8)**:


**HVPS Channel Readbacks (per channel, n = 1--4)**:


**Collector Protection PVs**:


**System Control PVs**:


---

## 12. Normal Operation Mode

During normal RF station operation:

1. All 12 channels sample continuously at their respective rates
2. Circular buffers overwrite continuously (no freeze)
3. Averaged signal values are computed and published via EPICS PVs at ~1 Hz update rate
4. Analog comparators continuously monitor all channels against thresholds
5. Collector power is computed continuously
6. The Python coordinator reads averaged values for archival and trend monitoring
7. Comparator trip outputs remain in the permit (non-tripped) state

**Data Flow in Normal Operation**:


---

## 13. Hardware Implementation

### 13.1 Chassis

- **Form factor**: 19-inch rack-mount chassis (height TBD, likely 2U--4U)
- **Location**: B118 equipment rack alongside LLRF9 units and other upgrade hardware
- **Power**: Standard AC mains, internal power supplies for analog and digital sections
- **Cooling**: Forced-air cooling with chassis fans

### 13.2 PCB Status

- **Signal conditioning PCB**: Fabricated (per design documents)
- **Digitizer/FPGA PCB**: Fabricated (per design documents)
- **Status**: Assembly, firmware development, and testing are pending

### 13.3 Component Procurement

| Component | Status | Estimated Cost |
|-----------|--------|----------------|
| RF detectors (ZX47-40LN+ x8) | Needed | ~\,700 |
| PCB fabrication | Complete | Included in prior budget |
| Chassis and mechanical | Needed | TBD |
| FPGA/MCU and passive components | Needed | TBD |
| Connectors (BNC, SMA, power) | Needed | TBD |

---

## 14. Implementation Status and Next Steps

### 14.1 Current Status

| Item | Status |
|------|--------|
| System specification | Complete (J. Sebek, Jan 2026) |
| PCB design | Complete |
| PCB fabrication | Complete |
| Component procurement (RF detectors) | Pending (~\.7k) |
| Assembly | Not started |
| Firmware development | Conceptual only |
| EPICS IOC development | Not started |
| Signal conditioning validation | Not started |
| Integration testing | Not started |

### 14.2 Next Steps

1. **Procure RF detectors** (Mini-Circuits ZX47-40LN+ x8) and remaining components
2. **Assemble PCBs** and chassis
3. **Develop FPGA/MCU firmware** for circular buffers, comparator logic, collector power calculation
4. **Develop EPICS IOC** with PV database
5. **Bench test** all channels with signal generators and dummy loads
6. **Validate comparator trip circuits** with known-good and known-bad signals
7. **Validate collector power algorithm** against calculated test cases
8. **Integrate with Interface Chassis** (comparator trip outputs, buffer freeze trigger)
9. **Integrate with MPS PLC** (analog buffered signals for redundant calculation)
10. **System commissioning** with live RF signals

### 14.3 Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| ADC noise floor limits detection sensitivity | Medium | Medium | Careful PCB layout, shielded signal paths, filtering |
| Collector power calculation latency | High | Low | Hardware (analog) path provides microsecond response; digital path is backup |
| RF detector calibration drift | Medium | Low | Mini-Circuits ZX47 has good long-term stability; periodic calibration |
| Signal conditioning mismatch | Medium | Medium | Bench calibration of each channel before installation |
| Integration timing with other subsystems | Medium | Medium | Can be tested independently before full system integration |

---

*End of Document*
