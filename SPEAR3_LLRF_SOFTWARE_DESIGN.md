# SPEAR3 LLRF Upgrade Software Design
**Version 3.0 - LLRF9 Integration Architecture**  
**Date: February 2026**  
**Author: J. Sebek / Codegen AI Assistant**

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [LLRF9 Hardware Integration](#3-llrf9-hardware-integration)
4. [Python Coordinator Architecture](#4-python-coordinator-architecture)
5. [EPICS Integration Layer](#5-epics-integration-layer)
6. [Station State Machine](#6-station-state-machine)
7. [HVPS Control Interface](#7-hvps-control-interface)
8. [Tuner Control System](#8-tuner-control-system)
9. [Interface Chassis](#9-interface-chassis)
10. [Waveform Buffer and Slow Power Monitor Chassis](#10-waveform-buffer-and-slow-power-monitor-chassis)
11. [MPS Integration](#11-mps-integration)
12. [Operator Interface Design](#12-operator-interface-design)
13. [Configuration Management](#13-configuration-management)
14. [Fault Detection and Logging](#14-fault-detection-and-logging)
15. [Implementation Plan](#15-implementation-plan)
16. [Testing and Commissioning Strategy](#16-testing-and-commissioning-strategy)
17. [Documentation Requirements](#17-documentation-requirements)
18. [Open Questions Requiring Resolution](#18-open-questions-requiring-resolution)

---

## 1. Executive Summary

### 1.1 Project Overview

The SPEAR3 RF system provides approximately 1.2 MW of RF power at 476 MHz to four cavities driven by a single klystron. The LLRF upgrade transitions from a legacy VxWorks/SNL-based control system with an analog RF Processor (RFP) module to a modern distributed architecture leveraging two Dimtel LLRF9 digital hardware controllers with a Python-based EPICS supervisory coordinator.

The legacy system consists of approximately 8,280 lines of SNL (State Notation Language) code running on a VxWorks IOC, plus the RFP analog module. The LLRF9 absorbs all fast analog processing and many slow-loop functions into hardware/FPGA, while the Python coordinator handles high-level supervisory control, HVPS management, and tuner motor coordination. The result is a dramatic reduction in custom software complexity and a large improvement in reliability and maintainability.

### 1.2 Key Design Principles

- **Hardware-Accelerated Processing**: LLRF9 handles all real-time RF control (270 ns direct loop delay, I/Q demodulation, phase measurement, interlocks, setpoint profiles), eliminating the legacy analog RFP module and much of the SNL code.

- **Distributed Responsibility Model**: Clear separation between hardware-accelerated RF processing (LLRF9), programmable logic controllers (HVPS PLC, MPS PLC), motion controllers (tuner motors), and supervisory coordination (Python/EPICS).

- **Native EPICS Integration**: The LLRF9 runs a built-in Linux EPICS IOC, enabling seamless integration with the existing SPEAR3 control infrastructure via Channel Access.

- **Modular Architecture**: Loosely-coupled modules allow incremental development and commissioning, critical given the 1-week Dimtel on-site commissioning support window.

- **Operational Continuity**: The upgraded system preserves the same station modes (OFF, PARK, TUNE, ON_CW), operator workflows, and PV naming conventions wherever possible, minimizing retraining requirements.

### 1.3 Legacy vs. Upgraded System Comparison

| Metric | Legacy System | LLRF9 System | Notes |
|--------|---------------|--------------|-------|
| **Custom Software** | ~8,280 lines SNL (6 sequences) | ~1,500-2,500 lines Python | Estimate; LLRF9 absorbs fast control |
| **Fast Feedback** | RFP analog module | LLRF9 FPGA (270 ns loop) | Digital; eliminates analog drift |
| **Interlock Response** | Software (~ms) | Hardware (~us, 17.4 ns timestamps) | 1000x faster |
| **RF Channels** | Custom analog | 18 channels across 2 LLRF9 units | Digital calibration included |
| **Phase Resolution** | Analog-limited | Digital (4.4 Hz BW, 10 Hz readout) | Improved accuracy |
| **Waveform Capture** | VxWorks buffers | LLRF9: 16k samples/ch + external chassis | Built-in + supplemental |
| **Tuner Control** | Allen-Bradley 1746-HSTP1 (obsolete) | Modern motion controller (TBD) | Higher micro-step resolution |
| **HVPS Control** | SLC-500 PLC (obsolete) | CompactLogix PLC | Modern, supported |
| **MPS** | PLC-5 (obsolete) | ControlLogix 1756 | Already built |
| **Maintenance** | Analog drift, obsolete parts | Digital stability, supported parts | Reduced downtime |

---

## 2. System Architecture Overview

### 2.1 SPEAR3 RF System Physical Layout

SPEAR3 operates with a single RF station:
- **1 klystron** powered by a high-voltage power supply (HVPS)
- A **circulator** that isolates the klystron from reflected power
- **3 magic-tee power dividers** that split power equally to 4 cavities
- **4 RF cavities** (A, B, C, D), each with a moveable tuner
- **3 waveguide loads** absorbing reflected power from the magic tees
- A **drive amplifier** between the LLRF output and the klystron input

Each cavity has at minimum: a probe signal, forward power signal, and reflected power signal. Additional signals include klystron forward/reflected, circulator load forward/reflected, and waveguide load forward/reflected powers.

### 2.2 Fundamental Architecture Change

The upgrade changes the control architecture from a **software-centric** model (VxWorks SNL sequences doing everything through an analog RFP module) to a **distributed hardware-accelerated** model:

**Legacy System (single VxWorks IOC + analog RFP):**
- `rf_states.st` — Station state machine, direct/comb loop sequencing, fault files
- `rf_dac_loop.st` — Gap voltage and drive power DAC control
- `rf_hvps_loop.st` — HVPS voltage regulation
- `rf_tuner_loop.st` x4 — Cavity tuner feedback (one per cavity)
- `rf_calib.st` — Calibration (~3,345 lines, most complex module)
- `rf_msgs.st` — Message logging, HVPS fault monitoring
- RFP analog module — Fast I/Q processing, direct/comb loop analog feedback

**Upgraded System (distributed):**
- **Dimtel LLRF9 x2** — Fast RF control, I/Q demodulation, direct/integral loops, gap voltage fast regulation, phase measurement for tuners, interlocks, calibration, network analyzer, waveform capture
- **CompactLogix PLC (HVPS)** — HVPS voltage regulation, contactor control, HVPS interlocks, Enerpro gate drivers
- **ControlLogix PLC (MPS)** — Fault summary, permit management, external interlock monitoring
- **Interface Chassis** — Central permit hub between LLRF9, HVPS, MPS, SPEAR MPS, orbit interlock, arc detectors
- **Waveform Buffer / Slow Power Monitor Chassis** — Additional 6+ RF channels, 4 HVPS signals, comparator trips, klystron collector power protection
- **Motion Controller (TBD)** — 4-axis stepper motor control for cavity tuners
- **Python/EPICS Coordinator (this design)** — Station state machine, HVPS supervisory control, tuner position management, load angle offset loop, fault logging, operator interface

### 2.3 Two-Unit LLRF9 Configuration for Four Cavities

Per LLRF9 manual Section 8.4 ("One station, four cavities, single power source"), SPEAR3 requires **two LLRF9 units**:

**LLRF9 Unit #1 (Field Control Unit):**
- Runs the active field control feedback loop
- Board 1: Cavity A probe + Cavity B probe (vector sum for feedback) + reference
- Board 2: Cavity C probe + Cavity D probe (vector sum, monitoring/tuner) + reference
- Board 3: Klystron forward power + additional monitoring + reference
- Drives the klystron via the drive amplifier
- Provides phase measurements for all 4 tuner loops
- **9 RF inputs**: 4 cavity probes, 4 cavity forward powers, 1 klystron forward

**LLRF9 Unit #2 (Monitoring Unit):**
- Monitors reflected power signals and additional channels
- Board 1: Cavity A reflected + Cavity B reflected + reference
- Board 2: Cavity C reflected + Cavity D reflected + reference  
- Board 3: Klystron reflected + circulator load forward + reference
- Provides interlock protection on reflected power
- **9 RF inputs**: 4 cavity reflected, klystron reflected, circulator load fwd/refl, + 2 spare

**Note:** The exact channel mapping between physical signals and LLRF4.6 board inputs must be finalized during commissioning. The LLRF9 uses configurable EPICS database substitution files to map physical channels to logical channels.

Both units share a single interlock chain via the interface chassis: a reflected power event detected by either unit will disable the drive output.

### 2.4 Signals NOT Covered by LLRF9

The 18 RF channels across the two LLRF9 units do not cover all legacy monitoring points. The following signals require the separate **Waveform Buffer / Slow Power Monitor Chassis** (see Section 10):

- Waveguide Load 1 Forward Power
- Waveguide Load 1 Reflected Power
- Waveguide Load 2 Forward Power  
- Waveguide Load 2 Reflected Power
- Waveguide Load 3 Forward Power
- Waveguide Load 3 Reflected Power
- Station Reference Power (if not assigned to LLRF9)
- Klystron Drive Power (monitored by drive amplifier output)
- 4 HVPS signals (voltage, current, transformer voltages)


### 2.5 Hardware/Software Responsibility Partitioning

This is the **most critical design decision**. The table below maps every legacy function to its new owner:

| Legacy Function | Legacy Owner | New Owner | Interface | Notes |
|----------------|-------------|-----------|-----------|-------|
| Fast I/Q demodulation | RFP analog | **LLRF9** | Internal FPGA | Core LLRF9 function |
| Direct loop feedback | RFP analog + SNL | **LLRF9** | Config via EPICS | LLRF9 proportional + integral loops |
| Comb loop / ripple suppression | RFP analog + SNL | **LLRF9** | Config via EPICS | LLRF9 internal |
| Lead/Integral compensation | SNL (rf_states.st) | **LLRF9** | Config via EPICS | LLRF9 internal |
| Gap voltage fast regulation | SNL (rf_dac_loop.st) | **LLRF9** | Setpoint via EPICS | LLRF9 closes fast loop; Python sets total gap voltage setpoint |
| Drive power monitoring | SNL (rf_dac_loop.st) | **LLRF9 + Python** | LLRF9 measures; Python reads | Python uses for HVPS decisions |
| HVPS voltage setpoint | SNL (rf_hvps_loop.st) | **Python/EPICS** | CA to CompactLogix | Python sends voltage setpoints to PLC at ~1 Hz |
| HVPS vacuum processing | SNL (rf_hvps_loop.st) | **Python/EPICS** | CA to CompactLogix | Python implements ramp-up/ramp-down |
| Station state machine | SNL (rf_states.st) | **Python/EPICS** | CA to all subsystems | Python coordinates OFF/PARK/TUNE/ON_CW |
| Turn-on sequencing | SNL (rf_states.st) | **Python/EPICS** | CA to all subsystems | Python orchestrates turn-on/turn-off |
| Tuner phase measurement | SNL (rf_tuner_loop.st) | **LLRF9** | LLRF9 measures probe-forward phase | LLRF9 computes phase difference |
| Tuner motor commands | SNL (rf_tuner_loop.st) | **Python/EPICS** | EPICS motor record | Python receives phase error from LLRF9 and commands motor controller |
| Load angle offset loop | SNL (rf_tuner_loop.st) | **Python/EPICS** | CA | Python adjusts phase setpoints to balance cavity powers |
| Tuner home/reset/stop-init | SNL (rf_tuner_loop.st) | **Python/EPICS** | EPICS motor record | Python manages home positions and step-counter alignment |
| Calibration | SNL (rf_calib.st) | **LLRF9 + Python** | LLRF9 internal + Python orchestration | LLRF9 has built-in calibration; Python manages workflow |
| Fault file capture | SNL (rf_states.st) | **LLRF9 + Python** | LLRF9 waveform capture + Python archival | LLRF9 hardware-triggered capture; Python archives |
| Message logging | SNL (rf_msgs.st) | **Python/EPICS** | Python logging framework | Modern structured logging |
| RF interlock (reflected power) | RFP + AIM module | **LLRF9** | Hardware interlock chain | 17.4 ns timestamp resolution |
| Slow ADC interlocks | VxWorks | **LLRF9** | 8-channel baseband ADC interlocks | Window comparator mode |
| External interlocks (SPEAR MPS, orbit) | VxWorks | **Interface Chassis** | Opto-isolated + fiber optic | Hardware permit logic |
| Slow power monitoring | VxWorks | **Waveform Buffer Chassis** | ADC + comparators | MCL ZX47-40LN+ detectors |
| Klystron collector protection | Operational limits | **Waveform Buffer Chassis + MPS PLC** | Analog computation + PLC trip | New safety function |

---

## 3. LLRF9 Hardware Integration

### 3.1 LLRF9 Capabilities Relevant to SPEAR3

The Dimtel LLRF9 (per the LLRF9 Technical User Manual, Rev 1.5) provides:

**RF Signal Processing:**
- 9 RF input channels per unit, 6 MHz bandwidth at 476 MHz center frequency
- Full-scale input level: +2 dBm
- 3 LLRF4.6 boards, each with 4 ADC + 2 DAC channels, Xilinx Spartan-6 FPGA
- Digital downconversion to baseband, 4.4 Hz bandwidth, 10 Hz readout rate
- Vector sum of 2 cavity probes for field control
- Proportional + integral feedback loops with 270 ns direct loop delay

**Setpoint Profiles:**
- 512-point arbitrary profiles for voltage and phase ramping
- Time per step: 70 us to 37 ms
- Software or hardware trigger (external opto-isolated inputs)

**Tuner Support:**
- Phase comparison of probe and forward signals for cavity tuning
- Interface to motor controllers via RS-485 or Ethernet
- Field balancing loops for multi-cell cavities (applicable to load angle offset)

**Interlocks:**
- 9 RF input peak amplitude interlocks (overvoltage comparator)
- 8 baseband ADC window comparator interlocks
- 1 external opto-isolated interlock input (daisy-chain)
- All sources OR-ed in hardware; result disables DAC drive + opens RF switch
- Interlock output available on rear panel
- Timestamp resolution: 17.4 ns (35 ns per spec table)
- Automated event sequencing in EPICS

**Diagnostics:**
- 16,384 samples per channel waveform capture (hardware/software trigger)
- Adjustable pre-trigger/post-trigger split
- 10 waveforms/second in software trigger mode
- Built-in network analyzer (swept sinusoidal excitation, transfer function measurement)
- Built-in spectrum analyzer (zero excitation mode)
- Source multiplexer: ADC, cavity sum, loop error, drive

**Housekeeping:**
- Thermally stabilized RF compartment (3 TEC modules)
- Voltage, current, temperature, fan speed monitoring
- LO power monitoring

**Built-in EPICS IOC:**
- Linux SBC (mini-ITX) running EPICS
- SSH remote access for configuration
- Setup program for timezone, network, device name
- Configurable PV prefix (e.g., LLRF1:, LLRF2:)

### 3.2 LLRF9 EPICS PV Interface

The Python coordinator communicates with LLRF9 exclusively via EPICS Channel Access. Key PV categories:

**Configuration PVs** (set during commissioning, rarely changed):
- Channel mapping (physical to logical)
- Feedback loop gains and phase offsets
- Interlock thresholds
- Calibration parameters
- LO and clock configuration

**Operational PVs** (set by Python coordinator during operation):
- Total gap voltage setpoint
- Phase setpoint
- Setpoint profile tables
- Tuner phase setpoint offsets (for load angle balancing)
- Feedback loop enable/disable
- Interlock enable/disable

**Readback PVs** (monitored by Python coordinator):
- 9-channel amplitude and phase readings (10 Hz)
- Gap voltage readback
- Drive power readback
- Phase measurements for each cavity (probe vs. forward)
- Interlock status and timestamps
- Loop status indicators
- Housekeeping data (temperatures, voltages, fan speeds)

**Waveform PVs** (triggered on fault or periodic):
- 16k-sample waveforms per channel
- Network analyzer transfer function data
- Spectrum analyzer data

### 3.3 LLRF9 Calibration

The LLRF9 includes built-in calibration capabilities that replace most of the legacy `rf_calib.st` (3,345 lines). The legacy calibration sequence performed:
- RF channel amplitude calibration
- RF channel phase calibration
- I/Q offset compensation for each channel
- Loop phase optimization
- Drive power calibration

The LLRF9 handles these through its FPGA-based digital signal processing, which does not suffer from the analog drift that required frequent recalibration in the legacy system. The Python coordinator's role in calibration is:
1. Orchestrate the calibration workflow (e.g., set LLRF9 to calibration mode)
2. Verify calibration results are within acceptable limits
3. Store calibration records and history
4. Provide operator interface for manual calibration steps if needed

---

## 4. Python Coordinator Architecture

### 4.1 Design Philosophy

The Python coordinator is a **supervisory** layer that orchestrates the operation of hardware subsystems. It does NOT perform any real-time RF signal processing. Its responsibilities are:

1. **Station State Machine**: Coordinate transitions between OFF, PARK, TUNE, and ON_CW modes
2. **HVPS Supervisory Control**: Monitor drive power and adjust HVPS voltage setpoint (~1 Hz)
3. **Tuner Motor Management**: Receive phase errors from LLRF9, compute motor moves, command motion controller
4. **Load Angle Offset Loop**: Adjust individual cavity phase setpoints to balance power
5. **Fault Management**: Log faults, capture waveforms, coordinate recovery
6. **Operator Interface**: Provide modern interface to all system functions

### 4.2 Module Structure

```
spear3_llrf/
    coordinator/
        station_state_machine.py    # Station state control (replaces rf_states.st)
        hvps_controller.py          # HVPS supervisory loop (replaces rf_hvps_loop.st)
        tuner_manager.py            # Tuner control for 4 cavities (replaces rf_tuner_loop.st)
        load_angle_offset.py        # Power balancing loop
        dac_controller.py           # Gap voltage setpoint management (replaces rf_dac_loop.st)
        calibration_manager.py      # Calibration orchestration (replaces rf_calib.st)
        fault_handler.py            # Fault detection, logging, waveform capture
        message_logger.py           # Structured logging (replaces rf_msgs.st)
    epics_interface/
        pv_definitions.py           # All PV names and types
        channel_access.py           # pyepics wrapper with error handling
        alarm_handler.py            # Alarm severity processing
    config/
        station_config.yaml         # Station-specific configuration
        tuner_config.yaml           # Tuner parameters and limits
        hvps_config.yaml            # HVPS parameters and limits
        interlock_config.yaml       # Interlock thresholds
    tests/
        test_state_machine.py
        test_hvps_controller.py
        test_tuner_manager.py
        ...
```

### 4.3 Core Dependencies

- **pyepics**: EPICS Channel Access Python interface
- **PyYAML**: Configuration file management
- **numpy**: Numerical computations (e.g., phase calculations)
- **logging**: Structured logging with rotation
- **asyncio** or **threading**: Concurrent loop execution


---

## 5. EPICS Integration Layer

### 5.1 PV Naming Convention

To maintain compatibility with the existing SPEAR3 EPICS infrastructure, the upgraded system uses the following PV naming structure:

- **LLRF9 Unit #1**: `LLRF1:*` (field control unit)
- **LLRF9 Unit #2**: `LLRF2:*` (monitoring unit)
- **Station PVs**: `SRF1:*` (preserves legacy naming where possible)
- **HVPS PLC**: `SRF1:HVPS:*`
- **MPS PLC**: `SRF1:MPS:*`
- **Tuner Motors**: `SRF1:CAV{A,B,C,D}TUNR:*`

### 5.2 Gateway and Access Control

The Python coordinator accesses all subsystem PVs through the EPICS Channel Access network. A Channel Access Gateway may be used to:
- Provide access control and security
- Buffer high-frequency data for operator displays
- Isolate the LLRF9 internal IOCs from the broader SPEAR3 network

---

## 6. Station State Machine

### 6.1 Station Modes

The upgraded system preserves the four primary station modes from the legacy system:

| Mode | Description | Active Loops | LLRF9 State |
|------|-------------|-------------|-------------|
| **OFF** | Station completely off | None | Interlock output low; tuners at park home |
| **PARK** | HVPS off, tuners at park position | Tuner feedback (optional) | Drive output disabled |
| **TUNE** | Low-power testing mode | Tuner feedback, DAC loop (drive power) | Drive output enabled, low power |
| **ON_CW** | Full-power operation | All loops active | Full operation |

**Note:** The legacy ON_FM mode (cavity processing) is rarely used at SPEAR3 and may be omitted from the initial implementation.

### 6.2 State Transition Rules

The legal state transitions mirror the legacy system:

```
From \ To   OFF    PARK    TUNE    ON_CW
OFF          -      Y       Y       Y
PARK         Y      -       -       -
TUNE         Y      -       -       Y
ON_CW        Y      -       Y       -
```

### 6.3 Turn-On Sequence (OFF -> ON_CW)

This is the most complex state transition, derived from the legacy `rf_states.st` turn-on logic and Jim Sebek's operational document. The sequence must be executed in order:

1. **Verify preconditions**:
   - No active faults (fault_noon, panel_onoff severity == NO_ALARM)
   - HVPS contactor status OK
   - MPS permit active
   - SPEAR MPS permit active
   - Orbit interlock permit active

2. **Move tuners to ON home position**:
   - Command all 4 tuner motors to their `POSN:ONHOME` positions
   - Wait for all motors to reach position (with timeout)

3. **Initialize HVPS**:
   - Set HVPS voltage to turn-on minimum (`HVPS:VOLT:MIN`, ~50 kV)
   - Enable HVPS SCR triggers
   - Wait for HVPS to stabilize

4. **Initialize LLRF9 drive**:
   - Set LLRF9 gap voltage setpoint to initial low value
   - Enable LLRF9 drive output (RF switch closed)
   - Verify measurable RF power in cavities (few hundred kV gap voltage)

5. **Engage direct loop feedback**:
   - Close the direct loop (proportional + integral feedback)
   - **Critical**: This causes a transient in drive power (legacy: ~45 W before settling to ~10 W)
   - The HVPS voltage is intentionally low so this transient produces only ~50 kW klystron output, preventing damage
   - Wait for transient to settle (configurable, legacy: several seconds)

6. **Ramp to operational power**:
   - Slowly increase gap voltage setpoint (DAC loop)
   - Simultaneously ramp HVPS voltage to maintain target drive power
   - Both ramps proceed at ~1 Hz update rate for 10-20 seconds
   - Enable HVPS supervisory loop and DAC control loop

7. **Enable remaining loops**:
   - Enable comb/ripple loop (if applicable)
   - Enable lead/integral compensation
   - Enable tuner feedback loops
   - Enable load angle offset loop

8. **Reset beam abort**:
   - Wait for gap voltage to reach setpoint within tolerance
   - Restore drive power settings
   - Reset beam abort (AIM module equivalent)

9. **Log completion**:
   - Log "In ON_CW. Direct/Comb loops on." message
   - Update station state PVs

### 6.4 Turn-Off Sequence (ON_CW -> OFF)

1. Force beam abort (if applicable)
2. Set LLRF9 drive output to zero
3. Disable all feedback loops
4. Set HVPS voltage to zero
5. Disable HVPS SCR triggers
6. Open HVPS contactor (if required)
7. Move tuners to park home position
8. Write fault files (if fault-triggered)
9. Update station state PVs

### 6.5 Fault-Triggered Shutdown

When a fault is detected:
1. LLRF9 hardware interlock immediately zeros DAC output and opens RF switch (~us)
2. Interface chassis propagates trip to HVPS (removes SCR ENABLE)
3. Python coordinator detects fault via EPICS PV monitoring
4. Python triggers fault file capture (LLRF9 waveforms + external chassis data)
5. Python transitions station to OFF state
6. Python logs fault details including LLRF9 interlock timestamps
7. Auto-retry logic (configurable number of retries, legacy: limited retries with counter)

### 6.6 Automatic Reset/Restart

The legacy system includes automatic reset/restart logic with a retry counter. The Python coordinator preserves this:
- Configurable retry count (station_config.yaml)
- Retry delay between attempts
- Counter decrements on each retry; when zero, requires manual intervention
- HVPS contactor status must be OK before retrying
- Vacuum status must be OK before retrying

---

## 7. HVPS Control Interface

### 7.1 HVPS System Overview

The HVPS provides high voltage to the klystron. Its gain is a function of the output voltage. The LLRF system must coordinate the HVPS voltage setpoint with the drive power to maintain stable operation.

**Key HVPS parameters:**
- Turn-on voltage: `HVPS:VOLT:MIN` (~50 kV)
- Maximum voltage: determined by operational limits
- Voltage setpoint: `HVPS:VOLT:CTRL.VAL` (set by Python coordinator)
- Voltage readback: `HVPS:VOLT:RBCK`
- Contactor control: `HVPSCONTACT:CLOSE:CTRL`
- SCR trigger control: `HVPSSCR:ON:CTRL`

### 7.2 Two-Loop Interaction: DAC Loop + HVPS Loop

This is a critical coordination that must be preserved from the legacy system:

**DAC Loop** (now mostly in LLRF9 + Python setpoint):
- In TUNE mode: adjusts drive amplitude to control drive power
- In ON_CW mode with direct loop OFF: adjusts drive amplitude for drive power
- In ON_CW mode with direct loop ON: LLRF9 controls gap voltage; Python sets the setpoint

**HVPS Loop** (Python coordinator):
- Monitors the klystron drive power
- Goal: keep drive power at its desired operating point
- When drive power exceeds setpoint (because DAC loop increased it to raise gap voltage), the HVPS loop increases HVPS voltage
- Higher HVPS voltage increases klystron gain, so less drive power is needed for the same output power
- This returns drive power to its setpoint

The interaction works as follows:
1. Beam current changes -> gap voltage drifts
2. LLRF9 fast loop adjusts drive to maintain gap voltage -> drive power changes
3. Python's HVPS loop detects drive power change
4. Python adjusts HVPS voltage to bring drive power back to setpoint
5. Process continues at ~1 Hz

### 7.3 HVPS Loop States

The HVPS loop has three states, mirroring the legacy `rf_hvps_loop.st`:

- **OFF**: Station is OFF or PARK. HVPS loop inactive.
- **PROC** (Processing): Cavity vacuum processing mode. Ramps HVPS voltage up/down based on cavity vacuum, gap voltage limits, and klystron forward power.
- **ON**: Normal operation. Adjusts HVPS voltage to maintain drive power at setpoint.

### 7.4 HVPS Safety Checks

Before adjusting HVPS voltage, the Python coordinator verifies:
- RF processor is functional (LLRF9 PVs not in INVALID alarm)
- Klystron forward power is reading valid data
- Cavity gap voltage is reading valid data
- Cavity vacuums are within limits
- HVPS voltage readback is valid
- Cavity voltages are below maximum before increasing

### 7.5 CompactLogix PLC Interface

The HVPS CompactLogix PLC communicates with the Python coordinator via EtherNet/IP. The PLC handles:
- Internal HVPS MPS (overcurrent, arc detection in termination tank and transformer)
- Contactor control
- Enerpro gate driver management
- SCR firing timing
- Crowbar thyristor control

Software commands from Python to PLC:
- Open/close 12.47 kV contactor
- Enable power supply (remove Enerpro fast/slow inhibits)
- Supply output voltage setpoint (no faster than 1 Hz)

PLC reports back:
- All analog data (voltage, current, temperatures)
- All digital status bits
- Fault status

---

## 8. Tuner Control System

### 8.1 Tuner System Overview

Each of the 4 cavities has a moveable cylindrical tuner that adjusts the cavity resonant frequency. The resonant frequency must be kept slightly below the RF frequency (fRF = 476 MHz) to provide stability against the Robinson instability.

**Mechanical system per cavity:**
- Stepper motor: Superior Electric Slo-Syn M093-FC11 (200 steps/rev)
- Pulley gear ratio: 1:2 (one motor revolution = 1/2 lead screw revolution)
- Lead screw: 1/2-10 Acme thread (10 turns/inch)
- One motor revolution moves tuner 0.05 inches = 1.27 mm
- Linear potentiometer for approximate position measurement (no encoder)
- Typical total travel during startup: ~2.5 mm (one lead screw revolution)
- Typical operational motion: ~0.2 mm

### 8.2 Control Partitioning: LLRF9 vs. Python

**LLRF9 responsibilities:**
- Measures phase difference between cavity probe and forward power signals (10 Hz)
- Computes tuner position delta based on phase error and tuning setpoint
- Publishes phase error and suggested delta-move via EPICS PVs

**Python coordinator responsibilities:**
- Reads phase error / delta-move from LLRF9 EPICS PVs
- Applies deadband, step-size limits, and rate limits
- Commands the motion controller via EPICS motor record
- Monitors motor done-moving (DMOV) status
- Implements load angle offset adjustments
- Manages home positions, stop-and-init, and reset functions
- Enforces drive limits (DRVH, DRVL) and detects hardware limit switches

**TBD: Whether LLRF9 directly drives tuner motors via RS-485/Ethernet.** The LLRF9 manual indicates it can interface to motor controllers directly. However, per Jim Sebek's operational document: "We will need to understand the LLRF9 software control to properly partition the control between the LLRF9 and our EPICS driver." The current design assumes the Python coordinator handles motor commands, with LLRF9 providing only phase measurement. This should be confirmed with Dimtel.

### 8.3 Tuner Feedback Loop

The tuner feedback loop operates at approximately 1 Hz:

1. LLRF9 measures phase(probe) - phase(forward) for each cavity
2. LLRF9 compares to tuning setpoint
3. Phase error published to EPICS PV
4. Python reads phase error
5. Python checks preconditions:
   - Loop enabled (`CAVTUNR:LOOP:CTRL` == ON)
   - Motor not moving (`STEP:MOTOR.DMOV` == 1)
   - Sufficient RF power present (`KLYSOUTFRWD:POWER` > minimum)
   - Valid phase measurement (no INVALID severity)
   - Station not in OFF mode
6. Python computes new motor position: `new_pos = current_pos + delta`
7. Python checks drive limits
8. Python commands motor to new position
9. Wait for motor to complete move

### 8.4 Load Angle Offset Loop

Per Jim Sebek's document: "A system design decision was made to have a slow feedback loop slightly change the tuning angle of each cavity in order to equalize the gap voltage in each cavity."

This loop runs slower than the tuner feedback (every few seconds):

1. Read individual cavity probe amplitudes from LLRF9
2. Compare each cavity's fraction of total gap voltage to its target fraction
3. If a cavity has too much voltage: increase its tuning offset (detune further)
4. If a cavity has too little voltage: decrease its tuning offset
5. The offset is applied to the cavity's phase setpoint, which in turn affects the tuner loop target

The target fraction per cavity is set by operator PV (e.g., `SRF1:CAV1:STRENGTH:CTRL`), typically 0.25 for equal power sharing.

### 8.5 Stop-and-Init Function

The legacy system has a "stop and init" feature that aligns the internal step counter with the potentiometer reading without moving the tuner. This is necessary because:
- There are no encoders on the stepper motors
- The step counter can drift from the actual position over time
- After a power loss, the step counter resets but the tuner hasn't moved

The Python coordinator implements this as:
1. Read current potentiometer position
2. Read current step counter position
3. Calculate the discrepancy
4. Reset the step counter to match the potentiometer-derived position
5. Do NOT move the tuner

### 8.6 Tuner Home Positions

Two home positions per cavity:
- **ON home** (`POSN:ONHOME`): Position used when starting the RF station
- **PARK home** (`POSN:PARKHOME`): Position used when station is parked/off

During turn-on, tuners move to ON home. During shutdown, tuners move to PARK home.

The home positions can be set by the operator ("set home" button sets current position as the new home).

### 8.7 Motion Controller Selection

The legacy Allen-Bradley 1746-HSTP1 controllers and Superior Electric Slo-Syn SS2000MD4-M PWM drivers are obsolete. Candidate replacements:

**Option 1: Galil DMC-4143**
- 4-axis motion controller
- Higher micro-step resolution (16 or 64 micro-steps/step vs. legacy 2)
- Ethernet interface
- Well-supported EPICS driver available
- Programmable acceleration/deceleration profiles

**Option 2: Solution from Domenico / Mike Dunning**
- Motion control solutions already developed at SLAC
- May have proven reliability with similar applications

**Option 3: LLRF9-direct control via RS-485**
- LLRF9 manual states tuner motor control via RS-485 or Ethernet
- Would simplify architecture but reduce Python coordinator visibility
- Need to evaluate with Dimtel

The legacy system only uses uniform pulse rates (no acceleration profiles). The new system should test acceleration/deceleration profiles on the actual cavity to determine best motion parameters.

The stepper motor (M093-FC11) has 200 steps/rev. With a Galil controller at 64 micro-steps/step, resolution increases from 800 to 12,800 micro-steps per lead screw revolution, or 0.002 mm per micro-step (vs. legacy 0.032 mm).


---

## 9. Interface Chassis

### 9.1 Purpose

The interface chassis is the central hardware permit hub that connects all RF subsystems. It ensures that a fault in any subsystem results in a coordinated, fast shutdown of the entire RF system.

### 9.2 Inputs

| Signal | Source | Type | Level |
|--------|--------|------|-------|
| LLRF9 Status | LLRF9 rear panel | Electrical (opto-isolated) | 5 VDC active, low on fault |
| HVPS STATUS | HVPS controller | Fiber optic (HFBR-2412) | Illuminated when ready |
| MPS Summary Permit | RF MPS PLC | Electrical (digital) | Active high |
| MPS Heartbeat | RF MPS PLC | Electrical (digital) | Periodic pulse |
| SPEAR MPS Permit | SPEAR MPS | Electrical (opto-isolated) | 24 VDC active |
| Orbit Interlock Permit | SPEAR orbit system | Electrical (opto-isolated) | 24 VDC active |
| Power Signal Permit | Slow power monitor | Electrical (opto-isolated) | Active high |
| Arc Detector Permit | MicroStep-MIS system | Electrical or dry contacts | Active high |
| Expansion Port 1 | TBD | TTL (50 ohm terminated) | Active high |
| Expansion Port 2 | TBD | TTL | Active high |
| Expansion Port 3 | TBD | 24 VDC (opto-isolated) | Active high |
| Expansion Port 4 | TBD | 24 VDC (opto-isolated) | Active high |
| MPS External Reset | RF MPS PLC | Electrical (digital) | Pulse to reset |

### 9.3 Outputs

| Signal | Destination | Type | Level |
|--------|------------|------|-------|
| LLRF9 Enable | LLRF9 interlock input | Electrical (opto-isolated) | >= 3.2 VDC, >= 8 mA |
| HVPS SCR ENABLE | HVPS controller | Fiber optic (HFBR-1412) | Illuminated = enable |
| HVPS KLYSTRON CROWBAR | HVPS controller | Fiber optic (HFBR-1412) | Illuminated = inhibit crowbar |
| Digital status (all I/O) | RF MPS PLC | Multi-conductor cable | Digital levels |
| First-fault status | RF MPS PLC | Multi-conductor cable | Digital levels |

### 9.4 Key Design Requirements

Per the llrfInterfaceChassis.docx:

- **First-fault circuit**: Identifies the first fault when multiple faults occur simultaneously
- **Latching**: All inputs latch when they fault
- **External reset**: All faults simultaneously resetable via MPS reset signal
- **Electrical isolation**: All external signals opto-isolated from internal chassis ground using Broadcom ACSL-6xx0 opto-couplers (min ON current 8 mA, max 15 mA, max forward voltage 1.8 VDC)
- **Fiber optic components**: HFBR-1412 transmitters, HFBR-2412 receivers (Broadcom)
- **Processing delay**: Order of microseconds (standard electronic/electro-optical components)
- **Status reporting**: All input and output states reported to MPS PLC via digital lines

### 9.5 Logic Considerations

The LLRF9 Status output will go low whenever the interface chassis removes the LLRF9 Enable (because the external interlock is one of the OR-ed sources). The system must be designed so that after a fault is cleared:
1. Verify HVPS is off (STATUS from HVPS controller goes inactive)
2. Return the LLRF9 Enable
3. Allow normal turn-on sequence to proceed

This requires coordination between the interface chassis hardware logic and the Python coordinator's state machine.

---

## 10. Waveform Buffer and Slow Power Monitor Chassis

### 10.1 Purpose

This chassis provides:
1. Monitoring of RF signals NOT covered by the two LLRF9 units
2. Monitoring of HVPS electrical signals
3. Comparator-based trip circuits for slow power monitoring
4. Klystron collector power protection
5. Waveform buffer capture for fault diagnosis

### 10.2 RF Signal Monitoring (8 channels)

RF signals processed through Mini-Circuits ZX47-40LN+ power detectors:
- Waveguide Load 1 Forward Power
- Waveguide Load 1 Reflected Power
- Waveguide Load 2 Forward Power
- Waveguide Load 2 Reflected Power
- Waveguide Load 3 Forward Power
- Waveguide Load 3 Reflected Power
- Klystron Drive Power (for redundant measurement)
- Klystron Forward Power (for collector power calculation)

**Detector specifications (ZX47-40LN+):**
- Output range: 0.2 to 2.2 VDC into 100 ohm load
- Rise time: several hundred nanoseconds
- Input attenuators as needed for signal level matching

**Signal conditioning:**
- Op-amp stage for inversion/amplification to match ADC input range
- 12-bit ADC (sufficient resolution)
- Sample rate: ~1 MHz
- Buffer size: 64k samples per channel

### 10.3 HVPS Signal Monitoring (4 channels)

- HVPS Output Voltage
- HVPS Output Current
- Transformer 1 voltage (firing circuit timing)
- Transformer 2 voltage (firing circuit timing)

**Signal conditioning:**
- Voltage dividers to reduce high-voltage signals to ADC-compatible levels
- Sample rate: ~10 kHz (sufficient for HVPS dynamics)
- Buffer size: adjustable, minimum 10 ms of data (100 samples at 10 kHz), preferably 64k samples

### 10.4 Comparator Trip Circuits

Each monitored RF signal has an analog comparator:
- Adjustable threshold (potentiometer or remotely settable)
- Latching output on threshold exceeded
- Individual fault indicators
- Combined summary permit output to interface chassis

### 10.5 Klystron Collector Power Protection

The SLAC B-Factory klystrons used at SPEAR3 are NOT full-power collector tubes. The collector cannot absorb the full DC beam power. Protection is required:

**Calculation:**
- Collector Power = HVPS DC Power - RF Output Power
- HVPS DC Power = HVPS Voltage x Beam Current (from HVPS monitoring channels)
- RF Output Power = measured from klystron forward power detector

**Implementation options:**
1. **Analog computation in chassis**: Multiply HVPS voltage x current, subtract RF power, trip if excessive
2. **Digital computation in MPS PLC**: Buffer HVPS voltage, current, and RF power to PLC; PLC computes and trips
3. **Redundant**: Both analog and digital paths

The signal from the klystron forward power detector and HVPS signals are buffered to the MPS PLC for this calculation.

### 10.6 Data Interface

- Averaged signal values available to EPICS at ~1 Hz for archival and display
- Waveform buffers frozen on fault trigger (from interface chassis trip signal)
- Frozen buffers readable by Python coordinator for fault analysis and archival
- Communication to EPICS via soft IOC or dedicated ADC IOC

---

## 11. MPS Integration

### 11.1 MPS System Overview

The RF Machine Protection System (MPS) has been rebuilt using ControlLogix 1756 hardware (replacing legacy PLC-5). The MPS:
- Monitors temperatures, water flows, vacuum, power supplies for klystron, cavities, and high-power components
- Provides a global permit to the interface chassis
- Reads all digital status from the interface chassis (input and output states, first-fault indicators)
- Communicates with the Python coordinator via EPICS (EtherNet/IP to EPICS gateway)

### 11.2 MPS Interfaces

**Inputs to MPS:**
- Temperatures (klystron, cavities, waveguides, cooling water)
- Water flow rates
- Vacuum levels (cavity vacuums)
- Power supply voltages and currents
- Digital status from interface chassis
- Klystron collector power data (from waveform buffer chassis)

**Outputs from MPS:**
- Global RF permit to interface chassis
- Heartbeat signal to interface chassis
- Fault reset signal to interface chassis
- Status to EPICS for operator display

### 11.3 SPEAR3 MPS and Orbit Interlock

- SPEAR3 MPS provides 24 VDC permit directly to interface chassis
- SPEAR3 orbit interlock provides 24 VDC permit directly to interface chassis
- Beamline MPS communicates through SPEAR3 MPS (satellite configuration)
- No hardware feedback from RF system to SPEAR3 MPS required

---

## 12. Operator Interface Design

### 12.1 Interface Philosophy

The operator interface should:
- Present familiar workflows to SPEAR3 operators
- Provide modern web-based displays alongside traditional EPICS screens
- Support both routine operations and diagnostic troubleshooting
- Include mobile-friendly status views for on-call monitoring

### 12.2 Key Operator Screens

**Main RF Station Screen** (equivalent to legacy rf_station_4CVSPR.edl):
- Station mode and state
- Total gap voltage setpoint and readback
- Individual cavity voltages
- Klystron forward/reflected power
- HVPS voltage and current
- All feedback loop status indicators
- Alarm summary

**RF Feedback Screen**:
- Direct loop gain and phase settings
- Comb/ripple loop parameters
- Loop transfer function (from LLRF9 network analyzer)
- Spectrum display (from LLRF9 spectrum analyzer)

**Gap Voltage Control Screen**:
- DAC counts / setpoint
- Drive power setpoint and readback
- Gap voltage error

**HVPS Control Screen**:
- HVPS voltage setpoint and readback
- HVPS current
- HVPS loop status
- Contactor status
- SCR trigger status

**Tuner Summary Screen**:
- All 4 cavity tuner positions
- Phase errors
- Loop status for each cavity
- Load angle offsets

**Tuner Detail Screen** (per cavity):
- Tuner position (potentiometer and step counter)
- Phase error
- Motor parameters (step size, deadband, limits)
- Home positions
- Stop-and-init controls

**Interlock and Fault Screen**:
- All interlock sources with timestamps
- First-fault identification
- Fault history
- Waveform display (post-mortem)

---

## 13. Configuration Management

### 13.1 Configuration Files

All operational parameters stored in YAML configuration files:

**station_config.yaml:**
```yaml
station:
  name: SRF1
  rf_frequency: 476.315e6  # Hz
  num_cavities: 4
  gap_voltage_setpoint: 3.2  # MV (example)
  turn_on_gap_voltage: 0.3   # MV (initial low value)
  drive_power_setpoint: 10.0 # W (target drive power)
  max_klystron_forward_power: 300.0  # kW
  auto_restart_retries: 3
  auto_restart_delay: 30  # seconds
```

**hvps_config.yaml:**
```yaml
hvps:
  turn_on_voltage: 50.0  # kV
  max_voltage: 80.0      # kV
  voltage_step_up: 0.5   # kV per update
  voltage_step_down: 1.0 # kV per update
  update_rate: 1.0       # Hz
  loop_delay: 10         # seconds after fast turnon
```

**tuner_config.yaml:**
```yaml
tuner:
  num_cavities: 4
  update_rate: 1.0        # Hz
  deadband: 5             # micro-steps (legacy: 5)
  max_step_size: 100      # micro-steps per move
  min_klystron_power: 5.0 # kW (minimum power for tuning)
  home_tolerance_factor: 2 # multiplied by position MDEL
  cavities:
    A:
      on_home: 10.5       # mm
      park_home: 8.0      # mm
      strength_fraction: 0.25
    B:
      on_home: 10.3       # mm
      park_home: 8.2      # mm
      strength_fraction: 0.25
    C:
      on_home: 10.7       # mm
      park_home: 7.8      # mm
      strength_fraction: 0.25
    D:
      on_home: 10.1       # mm
      park_home: 8.1      # mm
      strength_fraction: 0.25
```

---

## 14. Fault Detection and Logging

### 14.1 Fault Sources

| Source | Detection Method | Response Time |
|--------|-----------------|---------------|
| LLRF9 RF interlock | Hardware peak detection | ~100 ns |
| LLRF9 baseband ADC interlock | Hardware window comparator | ~9-72 us |
| External interlock (interface chassis) | Hardware opto-isolated | ~us |
| Slow power comparator trip | Analog comparator | ~us |
| Arc detector trip | MicroStep-MIS optical | ~us |
| SPEAR MPS trip | 24 VDC removal | ~us |
| Orbit interlock trip | 24 VDC removal | ~us |
| HVPS internal fault | PLC detection | ~ms |
| Software-detected fault | Python coordinator | ~100 ms |

### 14.2 Fault Capture

On fault event, the following data is captured:

**LLRF9 data (automatic, hardware-triggered):**
- 16k-sample waveforms for all 9 channels (pre/post trigger adjustable)
- Interlock source identification with timestamps (17.4 ns resolution)
- First 10 interlock events ordered by timestamp
- Trip channel names and trip values

**Waveform buffer chassis data:**
- Frozen circular buffers for 8 RF channels and 4 HVPS channels
- Buffer contents readable by Python coordinator

**Python coordinator data:**
- Fault timestamp (EPICS timestamp)
- Station state at time of fault
- All PV values snapshot
- Fault sequence analysis (correlating LLRF9 timestamps with other sources)

### 14.3 Fault File Storage

The legacy system stores fault files numbered 1-10 (circular). The Python coordinator extends this:
- Fault files stored in a configurable directory
- Automatic numbering and rotation
- Metadata file with fault analysis
- Data files in HDF5 or binary format for waveforms
- Integration with SPEAR3 data archival system

### 14.4 Fault Correlation

The Python coordinator correlates faults across multiple systems using timestamps:
- LLRF9 hardware timestamps (17.4 ns resolution)
- EPICS timestamps (~ms resolution)
- PLC fault timestamps
- Correlation window: configurable, default 1 ms

This analysis identifies the root cause of cascading fault sequences (e.g., arc in cavity -> reflected power spike -> LLRF9 interlock -> HVPS shutdown -> beam dump).

---

## 15. Implementation Plan

### 15.1 Development Phases

**Phase 1: Core Infrastructure (Months 1-2)**
- Python coordinator framework
- EPICS integration layer (pyepics wrapper)
- Configuration management system
- Basic station state machine (OFF/TUNE/ON_CW transitions)
- LLRF9 communication interface
- Structured logging system

**Phase 2: Control Loops (Months 3-4)**
- HVPS supervisory control loop
- Tuner feedback loop (all 4 cavities)
- Load angle offset loop
- Gap voltage setpoint management
- Fault detection and capture

**Phase 3: System Integration (Months 5-6)**
- Interface chassis hardware build and integration
- Waveform buffer chassis hardware build and integration
- MPS system integration testing
- Motion controller integration (depending on selection)
- Full turn-on/turn-off sequencing

**Phase 4: Operator Interface and Testing (Months 7-8)**
- Operator display development
- Alarm and notification system
- Comprehensive testing (fault injection, performance validation)
- Operator training materials
- Documentation completion

### 15.2 Resource Requirements

**Software Development:**
- Senior Python / EPICS developer: 8 months
- EPICS specialist (PV database, displays): 3 months
- Test engineer: 3 months

**Hardware Integration:**
- Controls engineer: 6 months (interface chassis, waveform chassis, motion controller)
- Electrical technician: 4 months (fabrication, wiring)
- Mechanical support: 1 month (chassis fabrication)

**Commissioning:**
- Dimtel on-site support: 1 week (LLRF9 commissioning)
- System integration testing: 2 weeks
- Beam-based commissioning: 2 weeks

### 15.3 Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| LLRF9 integration complexity | Leverage Dimtel 1-week commissioning support; prototype already tested on SPEAR3 |
| Motion controller reliability | Prototype testing with candidate controllers on spare cavity and booster tuners |
| HVPS interface timing | Test stand validation (Test Stand 18) before SPEAR3 installation |
| Interface chassis design delay | Start design early; leverage llrfInterfaceChassis.docx specifications |
| Schedule overrun | Parallel development of independent modules; incremental commissioning |
| Tuner control partitioning uncertainty | Early discussion with Dimtel to clarify LLRF9 tuner interface capabilities |

---

## 16. Testing and Commissioning Strategy

### 16.1 Test Stand Development

**HVPS Test Stand (Test Lab, Test Stand 18):**
- Commission new CompactLogix HVPS controller
- Validate PLC-to-EPICS interface
- Test Enerpro gate driver boards
- Verify fiber optic interlock system
- Test HVPS ramp-up/ramp-down sequences

**LLRF9 Prototype Testing (already completed):**
- Prototype LLRF system previously commissioned on SPEAR3
- Validated basic RF processing and feedback control
- Results inform detailed commissioning plan

**Tuner Motion Testing:**
- Build test stand with candidate motion controller
- Test on spare cavity and/or booster tuners
- Validate motion profiles, step reliability, and communication robustness
- Test stop-and-init procedure

### 16.2 Commissioning Sequence

**Week 1: LLRF9 Hardware Commissioning (with Dimtel Support)**
- LLRF9 installation and RF signal routing
- Channel mapping and calibration
- Basic RF processing validation
- Feedback loop tuning (transfer function measurements with network analyzer)
- EPICS IOC configuration and PV verification

**Week 2: Python Coordinator Integration**
- Station state machine testing (OFF/TUNE/ON_CW)
- HVPS interface validation
- Tuner system integration (all 4 cavities)
- MPS interface testing
- Interface chassis integration

**Week 3: System Integration Testing**
- Full turn-on/turn-off sequences
- Fault injection testing (simulate interlock trips)
- Auto-restart testing
- Performance validation (gap voltage stability, phase stability)
- Load angle offset loop tuning

**Week 4: Production Transition**
- Parallel operation with legacy system (if feasible)
- Performance comparison
- Operator training
- Final documentation

### 16.3 Acceptance Criteria

**Performance:**
- RF amplitude stability: within specification (TBD with Dimtel)
- RF phase stability: within specification (TBD with Dimtel)
- State transition time (OFF -> ON_CW): < 60 seconds
- Fault response time (hardware interlock): < 1 us
- Fault response time (software detection): < 1 second

**Reliability:**
- System availability during commissioning: demonstrate stable operation
- Fault detection coverage: all legacy fault types detected
- Automatic recovery: demonstrated for common fault types

---

## 17. Documentation Requirements

### 17.1 Documentation Package

**Technical Documentation:**
- This software design document
- EPICS PV database documentation (all PVs, types, descriptions)
- Configuration parameter reference guide
- API documentation for Python coordinator modules
- Interface control documents for each hardware interface

**Operator Documentation:**
- Operator interface user guide
- Standard operating procedures (turn-on, turn-off, fault recovery)
- Emergency response procedures
- Alarm response guide

**Maintenance Documentation:**
- Troubleshooting procedures
- Calibration procedures
- Hardware replacement procedures
- Software update procedures

### 17.2 Code Standards

- All Python code uses type hints
- Comprehensive docstrings for all classes and methods
- Unit tests for all control logic
- Integration tests for subsystem communication
- Configuration parameter documentation in YAML comments

---

## 18. Open Questions Requiring Resolution

### 18.1 Resolved from Documentation Review

| Question | Resolution | Source |
|----------|-----------|--------|
| LLRF9 communication protocol | EPICS Channel Access via built-in IOC | LLRF9 manual, Section 3.3 |
| LLRF9 operating frequency | 476 MHz configuration (LLRF9/476) | LLRF9 manual, Table 2 |
| Interface chassis interlock levels | 3.2 VDC / 8 mA minimum for LLRF9 input; 5 VDC / 60 mA output | LLRF9 manual p.14 + llrfInterfaceChassis.docx |
| Opto-coupler selection | Broadcom ACSL-6xx0 family (e.g., ACSL-6300-50TE) | llrfInterfaceChassis.docx |
| Fiber optic components | HFBR-1412 transmitter, HFBR-2412 receiver (Broadcom) | llrfInterfaceChassis.docx |
| Additional RF monitoring hardware | MCL ZX47-40LN+ detectors (~$1,100 for 10 units) | WaveformBuffersforLLRFUpgrade.docx |
| HVPS monitoring needs | 4 channels: voltage, current, 2 transformer voltages | WaveformBuffersforLLRFUpgrade.docx |
| Klystron collector protection | Required; klystrons are NOT full-power collector tubes | WaveformBuffersforLLRFUpgrade.docx |
| Tuner mechanical parameters | 200 steps/rev, 1:2 gear, 1/2-10 Acme, 0.05 in/rev | LLRFOperation_jims.docx |

### 18.2 Remaining Open Questions

1. **LLRF9 tuner interface details**: Does LLRF9 directly send motor move commands (via RS-485/Ethernet), or does it only provide phase measurement data for external software to compute moves? Must be confirmed with Dimtel.

2. **Motion controller final selection**: Galil DMC-4143 vs. Domenico/Mike Dunning solution vs. LLRF9 direct control. Selection depends on prototype testing results and reliability evaluation.

3. **HVPS PLC EPICS driver**: Use pycomm3, OPC-UA, or custom EtherNet/IP driver for CompactLogix communication? Depends on existing SLAC infrastructure preferences.

4. **Slow power monitor ADC hardware**: What specific ADC hardware will digitize the MCL detector outputs? Needs board/chassis design.

5. **LLRF9 calibration detailed workflow**: What are the exact manual steps required for LLRF9 calibration? How does the operator interact? Needs Dimtel documentation.

6. **Arc detector integration**: MicroStep-MIS system mechanical interface details need design work. Estimated $20k total cost.

7. **Waveform buffer chassis ADC selection**: 12-bit ADC at 1 MHz for RF, 10 kHz for HVPS. Specific ADC chip/board selection needed.

8. **LLRF9 two-unit channel mapping**: Exact assignment of physical signals to LLRF4.6 board inputs on each unit. Finalize during commissioning.

9. **Motion profile optimization**: Legacy uses uniform pulse rates only. Should test acceleration/deceleration profiles on actual cavity before finalizing.

10. **Interface chassis PCB design**: Specifications are defined but detailed circuit design and PCB layout have not started.

11. **Reduction gear decision**: If the new motion controller has sufficient micro-step resolution, should the 1:2 reduction gear be retained or removed? Removing simplifies mechanics but halves resolution per step.

---

**Document Status**: Version 3.0 - Updated based on comprehensive review of all project documentation  
**Last Updated**: February 2026  
**Sources**: LLRF9 Technical Manual Rev 1.5, LLRFOperation_jims.docx, LLRFUpgradeTaskListRev3.docx, WaveformBuffersforLLRFUpgrade.docx, llrfInterfaceChassis.docx, legacy SNL source code (legacyLLRF/)
