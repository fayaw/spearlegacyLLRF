# LLRF9 System & Software Comprehensive Report
## For SPEAR3 LLRF Upgrade Software Design

**Version**: 1.0
**Date**: 2026-03-02
**Purpose**: Comprehensive reference for designing the upgrade LLRF control software based on LLRF9

---

## Table of Contents

1. [LLRF9 Hardware Architecture](#1-llrf9-hardware-architecture)
2. [LLRF9 Built-in EPICS IOC & Software](#2-llrf9-built-in-epics-ioc--software)
3. [EPICS PV Architecture & Naming](#3-epics-pv-architecture--naming)
4. [Feedback Control System](#4-feedback-control-system)
5. [Tuner Control System](#5-tuner-control-system)
6. [Interlock System](#6-interlock-system)
7. [Acquisition & Diagnostics](#7-acquisition--diagnostics)
8. [Setpoint Profiles & Ramp System](#8-setpoint-profiles--ramp-system)
9. [State Machine & HVPS Interface](#9-state-machine--hvps-interface)
10. [MATLAB Signal Processing Toolkit](#10-matlab-signal-processing-toolkit)
11. [EDM Operator Interface](#11-edm-operator-interface)
12. [Configuration Save/Restore System](#12-configuration-saverestore-system)
13. [Two-Unit SPEAR3 Configuration](#13-two-unit-spear3-configuration)
14. [Software Design Implications for Upgrade](#14-software-design-implications-for-upgrade)
15. [PV Reference Catalog](#15-pv-reference-catalog)

---

## 1. LLRF9 Hardware Architecture

### 1.1 Overall Topology

The LLRF9 is a 9-channel digital LLRF controller manufactured by Dimtel, Inc. It is designed for lepton storage rings and boosters, supporting multiple RF station configurations. The LLRF9/476 variant is used for SPEAR3, operating at 476 +/- 2.5 MHz.

**Physical Components:**

| Component | Description |
|-----------|-------------|
| **3 x LLRF4.6 boards** | Each with Xilinx Spartan-6 FPGA, 4 high-speed ADC channels + 2 DAC channels |
| **LO/Interconnect module** | Local oscillator synthesis, RF reference distribution, output amplification/filtering, interlock logic |
| **Linux SBC** | mini-ITX form factor single-board computer running the built-in EPICS IOC |
| **Thermal stabilization** | Aluminum cold plate with 3 TEC (thermoelectric cooler) modules under PID control |
| **Power supply** | 90-264 VAC input, auto-ranging |
| **3U 19" rack chassis** | With front air intakes and rear exhaust |

### 1.2 LLRF4.6 Board Architecture

Each LLRF4.6 board provides:

- **4 ADC input channels**: High-speed digitizers for RF signals
- **2 DAC output channels**: For drive signal generation
- **Xilinx Spartan-6 FPGA**: Handles all real-time digital signal processing
- **Channel allocation**: 1 channel dedicated to RF reference, 3 for measurement signals
- **Phase measurement**: All measurements on 3 measurement channels are relative to the reference channel on that board, rejecting LO and clock drifts

**Across 3 boards**: 9 RF input channels total (3 reference + 6 measurement). Only boards 1 and 2 have thermally stabilized output filtering, interlock, and amplification chains. Board 3 output is rear-panel only without these features.

### 1.3 LO Signal Generation (LLRF9/476)

The LO module uses a divide-and-mix topology for low phase noise:

| Signal | Ratio to f_rf | Frequency (MHz) | Purpose |
|--------|--------------|------------------|---------|
| Reference (f_rf) | 1 | 476.000 | Station RF frequency |
| IF | 1/12 | 39.667 | Intermediate frequency |
| Local Oscillator | 11/12 | 436.333 | Downconversion |
| ADC Clock | 11/48 | 109.083 | Sampling clock |
| DAC Clock | 11/24 | 218.167 | Output clock |

The IF frequency (f_rf/12) is critical: all digital signal processing happens at this intermediate frequency. The ADC samples at f_rf * 11/48, giving 4 samples per IF cycle which enables digital I/Q demodulation.

### 1.4 Auxiliary Hardware

**Slow ADC (8 channels)**:
- 12-bit resolution
- Selectable ranges: 0-5V, 0-10V, +/-5V, +/-10V per channel
- Galvanically isolated from chassis ground
- DA-15 connector on rear panel
- Can be configured with window comparator interlocks

**Digital I/O**:
- Interlock input: opto-isolated, configurable for 3.3V/5V/24V logic
- Interlock output: +4.75V high, <0.1V tripped, 220 ohm impedance
- Two trigger inputs: opto-isolated
- Spare output (default: HVPS interlock)
- LEMO connectors

**12 x Slow DAC outputs (AD5644)**:
- Accessible via EPICS PVs (`AD5644CH0` through `AD5644CH11`)
- Used for analog monitoring outputs and auxiliary control

**AD9512 Clock Distribution**:
- Per-board programmable delays for ADC/DAC clock alignment
- Configurable dividers and output levels

### 1.5 Housekeeping

The LLRF9 monitors its own health:

| Monitored Parameter | Count | Purpose |
|---------------------|-------|---------|
| Voltages | LLRF4.6 bulk supply | Power integrity |
| Currents | FPGA core current | Power integrity |
| Temperatures | 3 digital + 6 NTC + 1 IOC CPU = 10 | Thermal management |
| Fan speeds | 3 chassis blowers + 1 IOC CPU = 4 | Cooling verification |
| TEC coolers | 3 TEC modules with PID control | Phase stability |

Temperature trip threshold is configurable via `TEMP:TRIP` PV per board.


---

## 2. LLRF9 Built-in EPICS IOC & Software

### 2.1 IOC Architecture

The LLRF9 runs a Linux-based EPICS IOC on its internal single-board computer. This is NOT a traditional accelerator IOC running on a VME crate --- it is an embedded system within the LLRF9 chassis.

**Key characteristics:**
- **EPICS Base**: Version 3.14 (libraries included in the iGp distribution)
- **Communication**: Channel Access (CA) over Ethernet, default ports 5064/5065
- **Max array size**: 26 MB (`EPICS_CA_MAX_ARRAY_BYTES=26000000`)
- **Discovery**: IOC addresses stored in `config/epics_addr_list` file
- **PV naming**: `{SYSTEM}:{BOARD}:{PARAMETER}` hierarchy

### 2.2 iGp Software Distribution

The LLRF9 client software is packaged as the "iGp" distribution (LLRF9/iGp/). This provides everything needed to interface with the LLRF9 from a control room workstation:

```
LLRF9/iGp/
├── base/lib/          # EPICS 3.14 libraries (linux-x86 and linux-x86_64)
├── bin/               # EPICS tools (caget, caput, camonitor, edm) + scripts
├── dl_8/              # EDM panels for iGp 8-channel variant
├── dl_12/             # EDM panels for iGp 12-channel variant
├── dl_12H/            # EDM panels for iGp 12H variant
├── dl_llrf/           # EDM panels for LLRF9 (revision >= 9)
├── extensions/edm/    # EDM configuration, help files
├── extensions/labca/  # MATLAB-EPICS interface (labCA)
├── matlab/iGp/        # MATLAB tools for iGp operations
├── matlab/llrf/       # MATLAB tools for LLRF operations
├── envSet.sh          # Environment setup script
└── config/            # IOC address list, runtime config
```

### 2.3 Environment Setup

The `envSet.sh` script initializes the complete working environment:

1. Sets `IGPTOP` to the installation directory
2. Detects 32/64-bit architecture (`linux-x86` or `linux-x86_64`)
3. Configures EPICS CA variables (address list, ports, max array size)
4. Sets EDM paths for display panels and preferences
5. Configures MATLAB paths for labCA and iGp/llrf tools
6. Sets library paths for EPICS runtime
7. Starts `caRepeater` process (kills existing instance first)

**Software design implication**: The upgrade Python software should replicate this environment setup, particularly the EPICS CA configuration and the IOC address list management.

### 2.4 IOC Registration (IOC_add Script)

The `IOC_add` script registers a new LLRF9 IOC:

1. Pings the IOC IP to verify connectivity
2. Reads the FPGA/system revision PV (`{sys}:{dev}:REVISION`)
3. Determines system type:
   - Revision >= 9: LLRF mode (uses `dl_llrf/` panels, system-level PV naming)
   - Revision >= 3: iGp12 mode
   - Otherwise: iGp8 mode
4. Adds IP to the CA address list
5. Creates PV save/restore file from template

**Critical for upgrade software**: When revision >= 9 (LLRF mode), PV naming uses `{sys}` as the prefix instead of `{sys}:{dev}`. For SPEAR3, this means PVs like `LLRF:BRD1:...` rather than `IGPF:TEST:...`.

### 2.5 Client Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `caget` | Read a single PV | `caget LLRF:BRD1:CH0:AMP` |
| `caput` | Write a single PV | `caput LLRF:BRD1:FB:ASET 800` |
| `camonitor` | Monitor PV changes | `camonitor LLRF:BRD1:CH0:AMP` |
| `CWget` | Read multiple PVs (save config) | `CWget pvs/LLRF.pvs sr/LLRF/config1` |
| `CWput` | Write multiple PVs (restore config) | `CWput sr/LLRF/config1` |
| `edm` | Extensible Display Manager | GUI operator panels |
| `iGp_display` | Launch iGp top-level panel | Auto-detects revision |
| `llrf_display` | Launch LLRF top-level panel | For LLRF9 units |
| `sweep.sh` | EPICS parameter sweep | Sweeps one PV while recording another |


---

## 3. EPICS PV Architecture & Naming

### 3.1 PV Naming Convention

For LLRF9 in LLRF mode (revision >= 9), the PV naming follows:

```
{SYSTEM}:{DOMAIN}:{PARAMETER}
```

Where:
- **SYSTEM**: Top-level system identifier (e.g., `LLRF` for SPEAR3)
- **DOMAIN**: Functional domain:
  - `BRD1`, `BRD2`, `BRD3` --- Individual LLRF4.6 boards
  - `TUNER` --- Cavity tuner control
  - `STATE` --- State machine
  - `HVPS` --- HVPS interface
  - `HW` --- Hardware configuration
  - `PANEL` --- GUI control
  - `SR` --- Save/restore
  - `ILOCK` --- System-level interlocks
  - `C1T1`, `C1T2`, `C2T1`, `C2T2` --- Individual motor drives (Cavity/Tuner)

### 3.2 Board-Level PV Categories

Each board (`BRDn`) exposes the following PV groups:

| Category | PV Pattern | Purpose |
|----------|-----------|---------|
| **Clock/Timing** | `AD9512:*` | Clock distribution, delay, dividers |
| **ADC Enable** | `ADC0EN` - `ADC3EN` | Enable/disable individual ADC channels |
| **DAC Enable** | `DACEN`, `DAC1SEL` | Enable DAC output, select source |
| **Feedback** | `FB:*` | Amplitude/phase setpoints, control mode, bypass |
| **Rotators** | `ROT:*` | Vector rotation gain/phase for cavity combining and loop shaping |
| **Channel Config** | `CH0:*` - `CH2:*` | Threshold, dBFS, coupling, phase offset, units, power/amplitude switch |
| **Acquisition** | `ACQ:*` | Waveform capture enable, trigger, selection, post-trigger length |
| **Network Analyzer** | `RTNA:*` | Sweep acquisition, averaging, input mux, amplitude, span |
| **Integrator** | `INT:*` | Open/closed loop integrator coefficients |
| **Ramp** | `RAMP:*` | Setpoint profile control |
| **DAC Outputs** | `AD5644CH*` | 12-channel slow DAC outputs |
| **Reference DDS** | `REF:DDS:FREQ` | Reference frequency for DDS |
| **TEC** | `TEC:*` | Thermal stabilization PID parameters |
| **Diagnostics** | `DIAGSEL` | Diagnostic signal multiplexer |
| **Interlock** | `ILOCKMODE`, `INTERLOCK` | Board-level interlock configuration |
| **Klystron Phase** | `KLYPH:*` | Klystron phase tracking |
| **Slow ADC** | `MAX1270:*`, `MCP3208:*` | 8-ch slow analog readouts with interlock config |
| **Scalar Readback** | `SCALAR:*` | Processed amplitude/phase readbacks |
| **Setpoint** | `SETPT:*` | Amplitude and phase setpoints |
| **Spectrum** | `SP:AVG`, `FFTLEN` | Spectrum analyzer config |
| **Waveform Display** | `ACQ:DISP:*` | Enable/disable waveform display channels |
| **Housekeeping** | `BOARD_LED`, `CHASSIS_LED`, `LED_MODE`, `SYNC_MODE`, `TEMP:TRIP`, `SPI_MODE` | System management |

### 3.3 Feedback PVs (Critical for Upgrade Software)

The feedback system PVs are the most important for the upgrade:

```
LLRF:BRD1:FB:ASET          # Amplitude setpoint (field magnitude)
LLRF:BRD1:FB:PSET          # Phase setpoint
LLRF:BRD1:FB:CTRL          # Feedback control mode (open/closed)
LLRF:BRD1:FB:BYPASS        # Bypass feedback
LLRF:BRD1:FB:REF_TRACK     # Reference tracking mode
LLRF:BRD1:FB:ONE_CAV_MODE  # Single cavity mode
LLRF:BRD1:FB:DELAY         # Loop delay
LLRF:BRD1:FB:P_SHIFT       # Proportional gain shift
LLRF:BRD1:FB:I_SHIFT       # Integral gain shift
LLRF:BRD1:FB:INT:RADIUS    # Integrator saturation radius
LLRF:BRD1:FB:INT:SPAN      # Integrator span
LLRF:BRD1:FB:INT:SETSEL    # Integrator setpoint selection
```

### 3.4 Vector Rotation PVs

The rotator system enables vector sum computation and loop gain/phase control:

```
# Cavity vector combining
LLRF:BRD1:ROT:CAV1:GAIN    # Cavity 1 rotation gain
LLRF:BRD1:ROT:CAV1:PHASE   # Cavity 1 rotation phase
LLRF:BRD1:ROT:CAV2:GAIN    # Cavity 2 rotation gain
LLRF:BRD1:ROT:CAV2:PHASE   # Cavity 2 rotation phase

# Proportional loop (direct loop)
LLRF:BRD1:ROT:P_OL:GAIN    # Proportional open-loop gain
LLRF:BRD1:ROT:P_OL:PHASE   # Proportional open-loop phase
LLRF:BRD1:ROT:P_CL:GAIN    # Proportional closed-loop gain
LLRF:BRD1:ROT:P_CL:PHASE   # Proportional closed-loop phase

# Integral loop
LLRF:BRD1:ROT:I_OL:GAIN    # Integral open-loop gain
LLRF:BRD1:ROT:I_OL:PHASE   # Integral open-loop phase
LLRF:BRD1:ROT:I_CL:GAIN    # Integral closed-loop gain
LLRF:BRD1:ROT:I_CL:PHASE   # Integral closed-loop phase
```

**Software design implication**: The upgrade Python coordinator needs to manage these rotation gains carefully during startup and vector sum configuration. The `vector_sum_setup.m` MATLAB script (see Section 10) provides the algorithm.


---

## 4. Feedback Control System

### 4.1 FPGA Feedback Architecture

The LLRF9 implements a dual-loop feedback system entirely in the FPGA:

**Proportional (Direct) Loop**:
- 270 ns total loop delay (ADC -> FPGA processing -> DAC)
- Fast transient response
- Configured via `ROT:P_OL:GAIN/PHASE` (open-loop) and `ROT:P_CL:GAIN/PHASE` (closed-loop)
- Gain shift via `FB:P_SHIFT` (bit shifts for coarse gain adjustment)

**Integral Loop**:
- Provides long-term tracking and steady-state error rejection
- Configured via `ROT:I_OL:GAIN/PHASE` and `ROT:I_CL:GAIN/PHASE`
- Saturation radius: `FB:INT:RADIUS`
- Gain shift via `FB:I_SHIFT`
- Integrator coefficient: `INT:OL:A1` (open-loop) and `INT:CL:A1` (closed-loop)

### 4.2 Vector Sum Computation

For multi-cavity configurations (SPEAR3 uses 4 cavities with 2 per LLRF9 board), the FPGA computes a weighted vector sum of cavity probe signals:

```
Vector_Sum = ROT_CAV1_GAIN * exp(j * ROT_CAV1_PHASE) * Cavity1_IQ 
           + ROT_CAV2_GAIN * exp(j * ROT_CAV2_PHASE) * Cavity2_IQ
```

The feedback then regulates this vector sum to match the setpoint (`FB:ASET` for amplitude, `FB:PSET` for phase).

### 4.3 Rotator Implementation (from MATLAB `rot.m`)

The vector rotation is implemented as a 2-tap FIR filter in the FPGA. From the MATLAB reference implementation:

```matlab
function vec = set_rot(gain, phase, theta)
  gain_scale_inv = 1/sin(theta);
  vec = [1 -cos(theta) * gain_scale_inv; 0 gain_scale_inv] * gain * ...
        [cos(-phase/180*pi); sin(-phase/180*pi)];
```

Where `theta = 2*pi * f_IF / f_s` is the phase advance per sample at the IF frequency. This produces a 2-element vector that is used as FIR coefficients in the FPGA.

### 4.4 Feedback Control Modes

The `FB:CTRL` PV selects the feedback operating mode:
- **Open loop**: Drive signal is independent of cavity probe (for commissioning)
- **Closed loop**: Full proportional + integral feedback active

The `FB:BYPASS` PV provides an additional bypass mechanism.

### 4.5 Channel Attributes

Each measurement channel (CH0-CH2 on each board) has these configurable attributes:

| PV | Purpose | Software Interaction |
|----|---------|---------------------|
| `CHn:THRESHOLD` | Interlock threshold (dBFS) | Set during configuration |
| `CHn:dBFS` | Full-scale power calibration | Set from calibration data |
| `CHn:COUPLING` | AC/DC coupling | Hardware setting |
| `CHn:PWRSW` | Power vs. amplitude display | 'Power' squares the amplitude |
| `CHn:PH_OFFSET` | Phase offset correction | Set by `null_phases.m` algorithm |
| `CHn:UNITS` | Engineering units label | Display only |
| `CHn:SCALE` | Amplitude scaling factor | Calibration-dependent |
| `CHn:LABEL` | Channel label text | Display only |
| `CHn:HWPH` | Hardware phase offset | Factory calibration |
| `CHn:AMP` | Current amplitude readback | Read-only |
| `CHn:PHASE` | Current phase readback | Read-only |

### 4.6 Scalar Readbacks

The IOC computes 10 Hz scalar readbacks from the DDC (digital downconverter) processing:

- `SCALAR:RAW:AMPn` --- Raw amplitude for channel n
- `SCALAR:RAW:PHASEn` --- Raw phase for channel n
- Processed versions include calibration and phase offset corrections

These 10 Hz readbacks are the primary data source for the Python tuner loops.

---

## 5. Tuner Control System

### 5.1 Built-in Tuner Loop

The LLRF9 includes a built-in tuner control system that measures cavity phase and drives stepper motors. PVs for each cavity tuner (C1 through C4):

```
LLRF:TUNER:Cn:GAIN_P       # Proportional gain
LLRF:TUNER:Cn:GAIN_I       # Integral gain
LLRF:TUNER:Cn:GAIN_D       # Derivative gain
LLRF:TUNER:Cn:GAIN_W       # Anti-windup gain
LLRF:TUNER:Cn:DEADBAND     # Phase deadband (degrees)
LLRF:TUNER:Cn:MINFWD       # Minimum forward power for loop operation
LLRF:TUNER:Cn:OFFSET       # Phase offset (detuning setpoint)
LLRF:TUNER:Cn:CLOSE        # Loop open/close control
LLRF:TUNER:Cn:SIGN         # Phase direction sign
LLRF:TUNER:Cn:LOOP.U       # Control output (motor command)
LLRF:TUNER:Cn:TYPE         # Tuner type selector
```

### 5.2 Load Angle Balancing

The LLRF9 also provides per-cavity balance control for gap voltage equalization:

```
LLRF:TUNER:Cn:BALANCE:RATIO     # Target amplitude ratio
LLRF:TUNER:Cn:BALANCE:DEADBAND  # Balance deadband
LLRF:TUNER:Cn:BALANCE:GAIN      # Balance loop gain
LLRF:TUNER:Cn:BALANCE:CLOSE     # Balance loop enable
LLRF:TUNER:Cn:BALANCE:SIGN      # Balance direction
```

### 5.3 Motor Drive PVs

Individual motor drives are configured via:

```
LLRF:CnTm:ENABLE           # Motor enable (Cavity n, Tuner m)
LLRF:CnTm:DRIVE.DRVH       # Maximum drive output
LLRF:CnTm:DRIVE.DRVL       # Minimum drive output
```

The LLRF9 IOC supports EPICS motor record interface for motor controllers connected via RS-485 or Ethernet. Motor records expose standard PVs:

```
{sys}:{dev}.VAL     # Commanded position
{sys}:{dev}.RBV     # Readback value
{sys}:{dev}.VELO    # Velocity
{sys}:{dev}.ACCL    # Acceleration
{sys}:{dev}.RMP     # Ramp
{sys}:{dev}.CNEN    # Enable
{sys}:{dev}.TDIR    # Direction
{sys}:{dev}.RLV     # Relative move value
{sys}:{dev}.RAIN    # Rain (resolution)
```

### 5.4 Phase Measurement for Tuners

The tuner loop uses the 10 Hz synchronized phase comparison between cavity probe and forward power signals. The phase error drives the PID controller which commands motor steps. Key parameters:

- Phase data comes from `CHn:PHASE` (probe relative to reference)
- Forward power phase from the corresponding channel
- Difference gives detuning angle
- `MINFWD` threshold ensures loop only operates when RF is on

**Software design implication**: The upgrade Python coordinator should use LLRF9's 10 Hz phase readbacks as input to its tuner management algorithm, commanding motors via EPICS motor records to the Galil controller.


---

## 6. Interlock System

### 6.1 RF Input Interlocks

Each of the 9 RF input channels has an overvoltage interlock:
- Threshold set via `CHn:THRESHOLD` (in dBFS)
- Worst-case error: -0.09 dB
- Trip response: zeros DAC output AND activates physical RF switch (>= 40 dB isolation)
- All sources timestamped with +/- 17.4 ns resolution (35 ns between two events)

### 6.2 Baseband ADC Interlocks

The 8-channel slow ADC (MAX1270/MCP3208) supports window comparator interlocks:

```
LLRF:BRDn:MAX1270:CFG0-CFG7     # Per-channel configuration
LLRF:BRDn:MAX1270:PCH0-PCH7     # Physical channel readbacks with .DESC
LLRF:BRDn:HVPS:MASK:0-7         # Per-channel HVPS interlock mask
```

The HVPS interlock output is specifically designed for klystron protection --- it trips only on slow ADC events and uses a separate output connector.

### 6.3 Interlock Daisy-Chain

LLRF9 supports hardware daisy-chaining:
- **Input**: Opto-isolated, accepts external interlock signal
- **Output**: Active high (+4.75V) when system is healthy, pulled low (<0.1V) on trip
- External interlock combines with internal sources in hardware
- This is the mechanism by which two LLRF9 units (and the Interface Chassis) chain together

### 6.4 Interlock Event Sequencing

When an interlock trips, the IOC automatically:
1. Timestamps all active interlock sources (17.4 ns resolution)
2. Captures waveform data if configured for hardware trigger
3. Updates interlock status PVs
4. Makes first-fault identification possible through timestamp comparison

**PVs for interlock status:**
```
LLRF:BRDn:INTERLOCK           # Board-level interlock status (alarm PV)
LLRF:BRDn:INTERLOCK:HVPS      # HVPS-specific interlock
LLRF:BRDn:EXT:INTERLOCK       # External interlock input status
LLRF:ILOCK:ALL                # System-wide interlock aggregate
```

### 6.5 Interlock Mode

```
LLRF:BRDn:ILOCKMODE           # Interlock mode configuration
```

**Software design implication**: The Interface Chassis connects to LLRF9 interlock I/O. The Python coordinator reads interlock status PVs for logging and fault diagnosis, but never needs to be in the fast interlock path.

---

## 7. Acquisition & Diagnostics

### 7.1 Waveform Acquisition

The LLRF9 captures 16,384 samples per channel with configurable pre/post-trigger:

```
LLRF:BRDn:ACQ:EN              # Acquisition enable
LLRF:BRDn:ACQ:SINGLE          # Single-shot mode
LLRF:BRDn:ACQ:TRIG_SEL        # Trigger source: software, interlock, external, ramp
LLRF:BRDn:ACQ:TRIG_MUX        # Trigger multiplexer
LLRF:BRDn:ACQ:SEL             # Signal source: ADC raw, cavity sum, loop error, drive
LLRF:BRDn:ACQ:POSTLEN         # Post-trigger samples
LLRF:BRDn:ACQ:DISP:ADCn:EN   # Display enable per ADC channel
LLRF:BRDn:ACQ:DISP:MAGn:EN   # Display enable per magnitude channel
```

**Waveform data PVs** (from `read_waveforms.m`):
```
{sys}:{dev}:ACQ:ADC0-ADC3     # Raw ADC data arrays (16k samples each)
{sys}:{dev}:ACQ:TSC           # Timestamp counter array
```

Acquisition rate: 10 waveforms/second in software trigger mode.

### 7.2 Real-Time Network Analyzer (RTNA)

The built-in network analyzer performs swept measurements around the RF frequency:

```
LLRF:BRDn:RTNA:ACQ_EN         # RTNA acquisition enable
LLRF:BRDn:RTNA:ACQ_SINGLE     # Single sweep
LLRF:BRDn:RTNA:AVG            # Number of averages
LLRF:BRDn:RTNA:INPUT          # Input multiplexer (Cavity 1&2, loop error, drive, loopback)
LLRF:BRDn:RTNA:PTSUM          # Points to sum per frequency
LLRF:BRDn:RTNA:PTSUM_MAX      # Maximum points
LLRF:BRDn:RTNA:PTWAIT         # Wait time between points
LLRF:BRDn:RTNA:AMPL           # Excitation amplitude (6 dB steps, 0 to -78 dB)
LLRF:BRDn:RTNA:SPAN           # Frequency span (+/- 25 kHz max)
```

**RTNA data PVs** (from `read_rtna.m`):
```
{sys}:{dev}:RTNA:MAG1, MAG2     # Magnitude data (two halves of spectrum)
{sys}:{dev}:RTNA:PHASE1, PHASE2 # Phase data
{sys}:{dev}:RTNA:FREQ1, FREQ2   # Frequency points
{sys}:{dev}:RTNA:ASUB.VALO      # CIC integration cycles
```

The RTNA is 1024 points total. When excitation amplitude is zero, it becomes a spectrum analyzer.

### 7.3 Spectrum Analyzer

```
LLRF:BRDn:SP:AVG              # Spectrum averaging count
LLRF:BRDn:FFTLEN              # FFT length
```

**Software design implication**: The Python coordinator should use RTNA data for automated loop tuning during commissioning, and waveform capture with interlock trigger for post-mortem fault analysis.

---

## 8. Setpoint Profiles & Ramp System

### 8.1 Profile Ramping

The LLRF9 supports 512-point arbitrary setpoint profiles for amplitude and phase:

```
LLRF:BRDn:RAMP:TRIGEN         # Trigger enable (software/hardware)
LLRF:BRDn:RAMP:MODE           # Ramp mode
LLRF:BRDn:RAMP:LENGTH         # Profile length (up to 512 points)
LLRF:BRDn:RAMP:ASTART         # Amplitude start value
LLRF:BRDn:RAMP:AEND           # Amplitude end value
LLRF:BRDn:RAMP:PH_BASE        # Phase base value
LLRF:BRDn:RAMP:PH_DELTA       # Phase delta
LLRF:BRDn:RAMP:PROFILE        # Profile data array
LLRF:BRDn:RAMP:AMPRATE        # Amplitude ramp rate
LLRF:BRDn:RAMP:PHASERATE      # Phase ramp rate
```

**Timing**: Each step can be 70 us to 37 ms, giving total ramp times from 70 us to 18.9 seconds.

**Waveform PVs for profile data:**
```
{sys}:{dev}:RAMP:AMP           # Amplitude profile waveform
{sys}:{dev}:RAMP:AMP:HW        # Hardware amplitude profile
{sys}:{dev}:RAMP:PHASE          # Phase profile waveform
{sys}:{dev}:RAMP:PHASE:HW       # Hardware phase profile
{sys}:{dev}:RAMP:TIME            # Time profile waveform
```

### 8.2 Feedback State Sequencer

The IOC includes a feedback state sequencer for automated startup/shutdown:

```
LLRF:BRDn:FBS:ENABLE            # Sequencer enable
LLRF:BRDn:FBS:TRIG_IN_SEL       # Trigger input selection
LLRF:BRDn:FBS:n:SETSEL          # Step n setpoint selection (n=0-7)
LLRF:BRDn:FBS:n:SG              # Step n signal generator
LLRF:BRDn:FBS:n:CHAN_ON         # Step n channel enable
LLRF:BRDn:FBS:n:DRV0-DRV2      # Step n drive outputs
LLRF:BRDn:FBS:n:TIME            # Step n duration
```

This provides up to 8 programmable states, each with independent drive, setpoint, and timing configuration.

**Software design implication**: The ramp system replaces the legacy SNL turn-on sequence. The Python coordinator loads the appropriate profile and triggers the ramp, rather than implementing step-by-step timing in software.


---

## 9. State Machine & HVPS Interface

### 9.1 Built-in State Machine

The LLRF9 IOC includes state machine support with PVs for two stations:

```
LLRF:STATE:STn:TUNE_LIMIT      # Tuner phase limit for state transitions
LLRF:STATE:STn:VSET_OFF1       # Voltage setpoint offset 1
LLRF:STATE:STn:VSET_OFF2       # Voltage setpoint offset 2
LLRF:STATE:STn:VSET_GOAL       # Target voltage setpoint
LLRF:STATE:STn:PSET_GOAL       # Target phase setpoint
LLRF:STATE:STn:VSET_OL         # Open-loop voltage setpoint
LLRF:STATE:STn:TIMEOUT         # State transition timeout
LLRF:STATE:STn:DUMP_RATE       # Power dump rate
```

### 9.2 HVPS Interface PVs

The LLRF9 exposes HVPS-related PVs for the Python coordinator:

```
LLRF:HVPS:POWER:ON             # HVPS on threshold
LLRF:HVPS:POWER:HIGH           # HVPS high power threshold
LLRF:HVPS:POWER:DEADBAND       # Power control deadband
LLRF:HVPS:GAIN                 # HVPS voltage-to-power gain
LLRF:HVPS:MAX_DELTA            # Maximum voltage step per cycle
LLRF:HVPS:KLYFWD:HIGH          # Maximum klystron forward power
LLRF:HVPS:KLYFWD:HYST          # Klystron power hysteresis
LLRF:HVPS:PCOLL_MAX            # Maximum collector power
LLRF:HVPS:MODE                 # HVPS control mode
```

### 9.3 Save/Restore PVs

```
LLRF:SR:STATE                   # Save/restore state: 0=idle, 1=save, 2=restore
LLRF:SRFILEIN                   # Input filename for save/restore
```

### 9.4 Hardware Configuration

```
LLRF:HW:CONFIG                  # Hardware configuration register
```

**Software design implication**: The LLRF9's built-in state machine and HVPS PVs provide the parameters that the Python coordinator uses. The Python state machine reads these setpoints and orchestrates transitions. The HVPS supervisory loop in Python reads `HVPS:*` parameters to manage voltage ramping via the external CompactLogix PLC.

---

## 10. MATLAB Signal Processing Toolkit

### 10.1 Overview

The LLRF9 distribution includes comprehensive MATLAB tools that define the signal processing algorithms. These are critical references for the upgrade software because they contain the proven algorithms that must be replicated or interfaced to.

### 10.2 LLRF-Specific Tools (`matlab/llrf/`)

| File | Purpose | Key Algorithms |
|------|---------|---------------|
| `read_waveforms.m` | Read 4-ch acquisition from IOC | lcaGet for ADC0-3 + TSC, collects calibration data (f_s, f_IF, scale, ph_offset, hwph) |
| `ddc_waveforms.m` | Digital downconversion | Calls `reconstruct.m` for I/Q, applies FIR filter, computes phase relative to reference ch4 |
| `reconstruct.m` | Doolittle I/Q reconstruction | `I = sum(Idet.*[x(n) x(n+1)], 2)/sin(theta)` --- extracts I and Q from undersampled data |
| `read_rtna.m` | Read network analyzer data | Reads MAG/PHASE/FREQ arrays, computes H = 10^(mag/20)*exp(j*phase), calculates CIC bandwidth |
| `plot_rtna.m` | Plot RTNA data | Splits at gap, plots magnitude and phase vs frequency offset |
| `direct_fit.m` | Fit open-loop cavity response | Three-stage fitting: magnitude-only, phase-only, then joint optimization for G, sigma, wr, tau, phi |
| `direct_ol.m` | Cavity transfer function model | `H = -j*sigma*G*w / (w^2 - j*sigma*w - wr^2) * exp(-j*(w-wrf)*tau - phi)` with optional interpolator and rotator response |
| `dac_ol.m` | DAC output response model | Zero-order hold + LC lowpass (120nH, 47pF, 50 ohm) |
| `rot.m` | Vector rotation coefficients | Converts gain/phase to 2-tap FIR coefficients for FPGA |
| `null_phases.m` | Null I/Q phase offsets | Reads current phases, adjusts PH_OFFSET PVs to null readbacks |
| `phase_noise.m` | Phase noise spectrum | Welch method, converts to L(f) in dBc/Hz |
| `vector_sum_setup.m` | Configure vector sum | Iterative procedure: set cavity ratios, match rotated signals, trim reference, match phases |
| `value_adjust.m` | Incremental PV adjustment | Read-modify-write with optional phase wrapping |
| `spec2ssb.m` | Extract SSB spectrum | Averages upper and lower sidebands, converts to L(f) |
| `rd_strip.m` | Read StripTool dumps | Parses tab-delimited files with timestamps |
| `ph_trim.m` | Phase range normalization | Wraps phase to -180 to +180 |

### 10.3 iGp Tools (`matlab/iGp/`)

| File | Purpose |
|------|---------|
| `get_data.m` | Trigger and read waveform data from IOC |
| `iGp_read.m` | Read iGp/LLRF9 data with proper scaling |
| `iGp_plt.m` | Plot acquired data |
| `iGp_load_data.m` | Load data from files |
| `sinfit.m` | Robust sine wave fitting (for ADC characterization) |
| `sin_err.m` | Error function for sine fitting |
| `adc_single_tone.m` | Full ADC characterization (SNR, SINAD, SFDR, ENOB) |
| `adctest.m` | Online ADC testing via IOC |
| `phase_servo.m` | Phase servo implementation |
| `shaper.m` / `shaper_optimize.m` | DAC output pulse shaping optimization |
| `dac_analyze.m` | DAC timing sweep analysis |
| `multiple_sets.m` | Batch data collection |
| `tune_avg.m` / `tune_fit.m` / `tune_plots.m` | Beam tune measurement and analysis |
| `measure_bunch_tunes.m` / `proc_bunch_tunes.m` | Bunch-by-bunch tune measurement |

### 10.4 Key Algorithm: Vector Sum Setup

The `vector_sum_setup.m` algorithm is critical for SPEAR3. It configures the 2-cavity vector sum on a single LLRF4.6 board:

1. Set cavity 1 rotation gain to 1, phase to 0
2. Read scalar amplitude ratios of both cavities
3. Read rotated cavity signals via diagnostic multiplexer
4. Adjust `ROT:CAV2:GAIN` to match amplitude ratio Vc2/Vc1
5. Read reference signal, scale `ROT:P_OL:GAIN` to match
6. Trim `ROT:P_OL:PHASE` to match reference phase to cavity 1 rotated phase
7. Copy to closed-loop: `ROT:P_CL:PHASE`
8. Match cavity 2 phase to cavity 1
9. Adjust `CH0:PH_OFFSET` and `CH1:PH_OFFSET` to match readback phases to setpoint

**Software design implication**: This algorithm must be implemented in the Python coordinator for automated commissioning. It uses the `DIAGSEL` multiplexer PV and `SCALAR:RAW:*` readbacks.

### 10.5 Key Algorithm: I/Q Reconstruction (Doolittle Method)

From `reconstruct.m`, the fundamental signal recovery algorithm:

```
theta = 2*pi * f_IF / f_s;    % Phase advance per sample
D = sin(theta);                % Normalization factor

% For each pair of consecutive samples x[n], x[n+1]:
I[n] = (sin((n+1)*theta)*x[n] - sin(n*theta)*x[n+1]) / D
Q[n] = (-cos((n+1)*theta)*x[n] + cos(n*theta)*x[n+1]) / D
```

This extracts baseband I and Q from the undersampled IF data. The FPGA implements this in real-time; the MATLAB code replicates it for offline analysis.

### 10.6 Key Algorithm: Cavity Response Fitting

The `direct_fit.m` / `direct_ol.m` cavity model:

```
H(w) = -j * sigma * G * w / (w^2 - j*sigma*w - wr^2) * exp(-j*((w-wrf)*tau - phi))
```

Parameters:
- `G`: Peak gain
- `sigma`: Bandwidth (half-bandwidth at half-max)
- `wr`: Resonant frequency
- `tau`: Group delay
- `phi`: Phase offset
- `Q = wr / sigma`: Quality factor

This model is used for loop tuning and cavity characterization via the RTNA.


---

## 11. EDM Operator Interface

### 11.1 Panel Hierarchy (dl_llrf/)

The LLRF9 EDM panels provide complete operational control:

| Panel File | Purpose | Key Controls |
|------------|---------|-------------|
| `top.edl` | Top-level overview | Links to all sub-panels, system status |
| `top_four_cav.edl` | 4-cavity station overview | SPEAR3 primary view |
| `top_two_cav.edl` | 2-cavity station overview | Per-LLRF9 unit view |
| `main.edl` | Board-level main panel | NA/SA, Inputs, Interlocks, Save/Restore |
| `feedback.edl` | Feedback loop control | FB:CTRL, gain shifts, integrator |
| `rotators.edl` | Vector rotation settings | All ROT:* gains and phases |
| `integrator.edl` | Integrator detail | INT coefficients, radius, span |
| `channel.edl` | Single channel detail | Threshold, dBFS, offset, scale, units |
| `all_channels.edl` | All channels overview | Amplitude/phase readbacks for all 3 channels |
| `scalar.edl` | Scalar readbacks | Processed amplitude/phase values |
| `scalar_low_level.edl` | Raw scalar readbacks | Unprocessed measurements |
| `wform.edl` | Waveform display | Triggered waveform capture |
| `wform_ctrl.edl` | Waveform control | Trigger, acquisition settings |
| `tuner.edl` | Tuner loop panel | Per-cavity PID, deadband, offset, balance |
| `tuner_galil.edl` | Galil motor panel | Motor record interface |
| `tuner_mdrive.edl` | MDrive motor panel | Alternative motor interface |
| `tuner_soloist.edl` | Soloist motor panel | Alternative motor interface |
| `tuner_motorRecord.edl` | Generic motor record | Standard EPICS motor |
| `motor.edl` / `motor_galil.edl` | Motor detail | Position, velocity, limits |
| `state_machine.edl` | State machine control | State transitions, parameters |
| `hvps.edl` | HVPS control | Voltage setpoints, power thresholds |
| `interlocks.edl` | Interlock status | All interlock sources and status |
| `interlock_summary.edl` | Interlock summary | Quick interlock overview |
| `ramp.edl` | Ramp/profile control | Amplitude/phase profile editing |
| `delay.edl` | Clock delay settings | AD9512 delay programming |
| `ad9512.edl` | Clock chip detail | Full AD9512 configuration |
| `ad5644.edl` | DAC outputs | 12-channel slow DAC |
| `envmon.edl` | Environment monitoring | Temperatures, fans, voltages |
| `ds1822.edl` | Digital temperature | DS1822 temp sensor readouts |
| `max1270.edl` | Slow ADC readout | 8-channel analog inputs |
| `max1270interlock.edl` | Slow ADC interlocks | Window comparator config |
| `mcp3208.edl` | Alternative ADC | MCP3208 readouts |
| `kly_phase.edl` | Klystron phase tracking | Phase alignment |
| `io.edl` | Digital I/O status | Input/output states |
| `saverest.edl` | Save/restore | Configuration management |
| `versions.edl` | Version information | Firmware/software versions |
| `gwStats.edl` | Gateway statistics | CA gateway performance |
| `vs_servo_setup.edl` | Vector sum servo | Commissioning tool |
| `probe_balance.edl` | Probe signal balancing | Multi-probe cavity support |
| `int_gen.edl` | Internal generator | Test signal generation |
| `switch.edl` / `switch_small.edl` | RF switch control | Output switch status |

### 11.2 Panel Macros

EDM panels use macro substitution for multi-instance support:
- `$(sys)` --- System name (e.g., `LLRF`)
- `$(dev)` --- Device/board name (e.g., `BRD1`)
- `$(data)` --- Data directory path
- `$(stn)` --- Station number
- `$(tuner)` --- Tuner identifier (e.g., `C1`)

### 11.3 Alarm Integration

EDM panels use `alarmPv` properties for color-coded status:
- `$(sys):BRDn:INTERLOCK` --- Board interlock alarm
- `$(sys):ILOCK:ALL` --- System-wide interlock alarm
- `$(sys):SR:STATE` --- Save/restore alarm
- `$(sys):TUNER:Cn:CTRL` --- Tuner loop alarm
- `$(sys):PANEL:BG` --- Background color alarm PV

---

## 12. Configuration Save/Restore System

### 12.1 PVS Template Files

The LLRF9 uses template-based configuration management:

- `dl_llrf/pvs/_SR_TEMPLATE_` --- Master template with `$(SYS)` macros
- `dl_llrf/pvs/LLRF.pvs` --- Instantiated PV list for a specific system

The `.pvs` files list every saveable PV for the system. For SPEAR3's LLRF system, `LLRF.pvs` contains approximately **500+ PVs** covering all 3 boards, tuners, state machine, and HVPS.

### 12.2 Save/Restore Mechanism

**Save**: `CWget pvs/LLRF.pvs sr/LLRF/{filename}` reads all PVs and writes to file
**Restore**: `CWput sr/LLRF/{filename}` writes all values back to IOC

This is also accessible via EDM panel buttons which execute:
```
caput LLRF:SR:STATE 1; CWput {data}/sr/LLRF/`caget -t LLRF:SRFILEIN`; caput LLRF:SR:STATE 0
caput LLRF:SR:STATE 2; CWget {pvs}/LLRF.pvs {data}/sr/LLRF/`caget -t LLRF:SRFILEIN`; caput LLRF:SR:STATE 0
```

**Software design implication**: The Python coordinator should implement its own configuration management that wraps this mechanism, adding versioning, validation, and named configuration profiles.

---

## 13. Two-Unit SPEAR3 Configuration

### 13.1 Unit Roles

Per LLRF9 manual Section 8.4 and the upgrade system design:

**LLRF9 Unit 1 --- Field Control & Tuners**:

| Board | CH0 (Probe) | CH1 (Probe) | CH2 (Forward) | CH3 (Reference) | DAC |
|-------|-------------|-------------|---------------|-----------------|-----|
| BRD1 | Cav 1 probe | Cav 2 probe | Cav 1 forward | Station ref | Klystron drive |
| BRD2 | Cav 3 probe | Cav 4 probe | Cav 2 forward | Station ref | (spare) |
| BRD3 | Cav 3 fwd | Cav 4 fwd | Kly forward | Station ref | (rear panel only) |

- Runs vector sum feedback on BRD1 (Cav 1+2) and BRD2 (Cav 3+4)
- Provides klystron drive output from BRD1 (thermally stabilized)
- Measures all 8 probe/forward phases for tuner loops
- 10 Hz synchronized phase data for all 4 tuners

**LLRF9 Unit 2 --- Monitoring & Interlocks**:

| Board | CH0 | CH1 | CH2 | CH3 (Reference) | Purpose |
|-------|-----|-----|-----|-----------------|---------|
| BRD1 | Cav 1 reflected | Cav 2 reflected | Circ load fwd | Station ref | Reflected monitoring |
| BRD2 | Cav 3 reflected | Cav 4 reflected | Circ load rev | Station ref | Reflected monitoring |
| BRD3 | Kly reflected | (spare) | (spare) | Station ref | Additional monitoring |

- Monitors cavity reflected signals for fast interlock protection
- Interlock chain: reflected event on Unit 2 trips Unit 1's drive via daisy-chain
- No drive output required

### 13.2 Inter-Unit Communication

The two units communicate through:
1. **Hardware interlock daisy-chain**: Direct electrical connection via LEMO connectors
2. **EPICS Channel Access**: Both units on same Ethernet network, Python coordinator reads/writes to both
3. **Interface Chassis**: Coordinates interlock signals between units and external systems

### 13.3 PV Naming for Two Units

For SPEAR3, the two LLRF9 units will have different system prefixes:

```
# Unit 1 (Field Control)
LLRF1:BRD1:FB:ASET            # Amplitude setpoint
LLRF1:BRD1:CH0:AMP            # Cavity 1 probe amplitude

# Unit 2 (Monitoring)
LLRF2:BRD1:CH0:AMP            # Cavity 1 reflected amplitude
LLRF2:BRD1:INTERLOCK           # Unit 2 interlock status
```

**Note**: The exact PV prefixes need to be confirmed with Dimtel during commissioning. The IOC_add script configures these during installation.


---

## 14. Software Design Implications for Upgrade

### 14.1 What LLRF9 Handles Internally (No Python Needed)

The following are fully handled by LLRF9 FPGA/IOC and require only configuration from the Python coordinator:

| Function | LLRF9 Component | Python Role |
|----------|-----------------|-------------|
| Fast I/Q demodulation | FPGA DDC | None (set f_IF via DDS:FREQ) |
| Vector sum computation | FPGA rotators | Configure ROT:CAV gains/phases |
| Direct loop feedback (270 ns) | FPGA P+I loops | Set gain shifts, rotator gains/phases |
| Integral feedback | FPGA integrator | Set coefficients, radius, span |
| RF interlock detection | FPGA + hardware | Set thresholds, read status |
| Interlock timestamping | IOC | Read timestamps after event |
| Waveform acquisition (16k) | FPGA + IOC | Configure trigger, read data |
| Network/spectrum analyzer | FPGA + IOC | Set parameters, read data |
| Scalar readback (10 Hz) | FPGA DDC + IOC | Read amplitude/phase values |
| TEC thermal control | FPGA PID + IOC | Set temperature setpoint |
| Calibration | IOC | Trigger, monitor completion |
| Setpoint profiles/ramps | FPGA | Load profile, trigger ramp |
| Save/restore config | IOC (CWget/CWput) | Trigger save/restore operations |

### 14.2 What the Python Coordinator Must Implement

These functions are NOT in the LLRF9 and require implementation in the upgrade software:

| Function | Source Data | Output | Rate |
|----------|------------|--------|------|
| **Station state machine** | LLRF9 readbacks + HVPS status + MPS status + Interface Chassis | State transitions, operator commands | ~1 Hz |
| **HVPS supervisory loop** | LLRF9 drive power (SCALAR:RAW:AMP) | HVPS voltage setpoint to CompactLogix PLC | <= 1 Hz |
| **Tuner management** (x4) | LLRF9 phase readbacks (CHn:PHASE, 10 Hz) | Motor commands to Galil (EPICS motor record) | ~1 Hz |
| **Load angle offset** | 4 cavity amplitudes (CHn:AMP) | Per-cavity TUNER:Cn:OFFSET adjustments | ~0.1 Hz |
| **MPS coordination** | ControlLogix PLC status | Permit signals, fault acknowledgment | Event-driven |
| **Interface Chassis monitoring** | First-fault registers | Fault logging, diagnostics | Event-driven |
| **Waveform Buffer management** | Waveform Buffer System EPICS PVs | Configuration, data readout, collector protection | ~1 Hz / event |
| **Fault logging & diagnostics** | All subsystem status PVs | Structured logs, fault analysis | Event-driven |
| **Operator interface** | All PVs | EDM panels, web dashboard | On demand |
| **Configuration management** | PV save/restore | Named profiles, version control | On demand |

### 14.3 Python-to-LLRF9 Interface Design

The Python coordinator communicates with LLRF9 exclusively through EPICS Channel Access. The interface should be structured as:

```python
class LLRF9Interface:
    """Interface to a single LLRF9 unit via EPICS Channel Access."""
    
    def __init__(self, system_prefix: str):  # e.g., "LLRF1" or "LLRF2"
        self.prefix = system_prefix
    
    # === Feedback Control ===
    def set_amplitude_setpoint(self, board: int, value: float): ...
    def set_phase_setpoint(self, board: int, value: float): ...
    def set_feedback_mode(self, board: int, mode: str): ...
    def get_scalar_readbacks(self, board: int) -> dict: ...
    
    # === Tuner ===
    def get_tuner_phase(self, cavity: int) -> float: ...
    def set_tuner_offset(self, cavity: int, offset: float): ...
    def set_tuner_loop_state(self, cavity: int, closed: bool): ...
    
    # === Interlocks ===
    def get_interlock_status(self) -> dict: ...
    def get_interlock_timestamps(self) -> dict: ...
    def reset_interlocks(self): ...
    
    # === Diagnostics ===
    def trigger_waveform_capture(self, board: int): ...
    def get_waveform_data(self, board: int) -> dict: ...
    def configure_rtna(self, board: int, **params): ...
    def get_rtna_data(self, board: int) -> dict: ...
    
    # === Ramp/Profile ===
    def load_setpoint_profile(self, board: int, amp_profile, phase_profile, time_profile): ...
    def trigger_ramp(self, board: int): ...
    
    # === Configuration ===
    def save_configuration(self, filename: str): ...
    def restore_configuration(self, filename: str): ...
    
    # === Housekeeping ===
    def get_temperatures(self) -> dict: ...
    def get_fan_speeds(self) -> dict: ...
```

### 14.4 Critical PVs for Each Upgrade Function

**For State Machine:**
```
LLRF1:BRD1:FB:CTRL             # Feedback open/close
LLRF1:BRD1:FB:ASET             # Amplitude setpoint
LLRF1:BRDn:DACEN               # DAC enable (RF drive on/off)
LLRF1:BRDn:INTERLOCK            # Interlock status
LLRF1:STATE:STn:*               # State parameters
```

**For HVPS Loop:**
```
LLRF1:BRD3:SCALAR:RAW:AMP2     # Klystron forward power
LLRF1:HVPS:*                    # HVPS parameters (gain, max_delta, etc.)
# Plus CompactLogix PLC PVs for voltage setpoint/readback
```

**For Tuner Management (per cavity):**
```
LLRF1:BRDn:CHm:PHASE            # Cavity probe phase (10 Hz)
LLRF1:BRDn:CHm:AMP              # Cavity probe amplitude
LLRF1:TUNER:Cn:OFFSET           # Detuning phase offset
LLRF1:TUNER:Cn:CLOSE            # Loop state
LLRF1:TUNER:Cn:MINFWD           # Minimum forward power
# Plus motor record PVs for Galil controller
```

**For Load Angle Offset:**
```
LLRF1:BRD1:CH0:AMP              # Cavity 1 amplitude
LLRF1:BRD1:CH1:AMP              # Cavity 2 amplitude
LLRF1:BRD2:CH0:AMP              # Cavity 3 amplitude
LLRF1:BRD2:CH1:AMP              # Cavity 4 amplitude
LLRF1:TUNER:Cn:BALANCE:*        # Balance loop parameters
```

### 14.5 EPICS Communication Best Practices

Based on the LLRF9 software distribution:

1. **Use monitors, not polling**: Set up CA monitors for frequently-read PVs (amplitudes, phases, interlock status) using `epics.ca.create_subscription()`
2. **Batch reads**: Use `lcaGet` pattern (multiple PVs at once) rather than individual caget calls
3. **Rate limiting**: The IOC updates scalar readbacks at 10 Hz --- don't poll faster
4. **Max array size**: Set `EPICS_CA_MAX_ARRAY_BYTES=26000000` for waveform data
5. **Address list**: Maintain the CA address list with both LLRF9 unit IPs plus all other IOCs
6. **Timeout handling**: The LLRF9 IOC may occasionally restart; handle CA disconnections gracefully

### 14.6 Specifications Summary

From the LLRF9 manual specifications tables:

| Parameter | Value |
|-----------|-------|
| RF input channels | 9 (3 per LLRF4.6 board) |
| RF input range | 0 to -30 dBm |
| RF input impedance | 50 ohm |
| ADC resolution | 12-bit (LLRF4.6) |
| Direct loop delay | 270 ns |
| Setpoint profile points | 512 |
| Setpoint step time | 70 us to 37 ms |
| Waveform samples/channel | 16,384 |
| Waveform acquisition rate | 10/s (software trigger) |
| Network analyzer points | 1024 |
| Scalar readback rate | 10 Hz |
| Scalar readback bandwidth | 4.4 Hz |
| Phase readback resolution | Sub-degree |
| Interlock timestamp resolution | +/- 17.4 ns (35 ns between events) |
| RF interlock type | Overvoltage |
| RF interlock error | -0.09 dB worst case |
| Baseband interlock type | Window comparator |
| Slow ADC channels | 8 per unit |
| Slow ADC resolution | 12-bit |
| Slow DAC channels | 12 per unit (AD5644) |
| Digital inputs | Interlock + 2 triggers (opto-isolated) |
| Digital outputs | Interlock + spare/HVPS |
| TEC coolers | 3 per unit |
| Temperature sensors | 10 per unit |
| Fan speed sensors | 4 per unit |
| Communication | Ethernet/EPICS Channel Access |
| EPICS base version | 3.14 |
| IOC platform | Linux SBC (mini-ITX) |

---

## 15. PV Reference Catalog

### 15.1 Complete PV Count by Category

Based on the `LLRF.pvs` save/restore template:

| Category | Approx. Count | Example |
|----------|--------------|---------|
| AD9512 clock config | ~45 (15/board x 3) | `LLRF:BRDn:AD9512:DELAY` |
| Feedback control | ~36 (12/board x 3) | `LLRF:BRDn:FB:ASET` |
| Rotators | ~24 (8/board x 3) | `LLRF:BRDn:ROT:P_OL:GAIN` |
| Channel config | ~45 (15/board x 3) | `LLRF:BRDn:CHm:PH_OFFSET` |
| Acquisition | ~30 (10/board x 3) | `LLRF:BRDn:ACQ:EN` |
| RTNA | ~24 (8/board x 3) | `LLRF:BRDn:RTNA:AVG` |
| DAC outputs | ~42 (14/board x 3) | `LLRF:BRDn:AD5644CHn` |
| Ramp/Profile | ~30 (10/board x 3) | `LLRF:BRDn:RAMP:LENGTH` |
| Integrator | ~6 (2/board x 3) | `LLRF:BRDn:INT:OL:A1` |
| Interlock | ~30 (10/board x 3) | `LLRF:BRDn:ILOCKMODE` |
| Klystron phase | ~18 (6/board x 3) | `LLRF:BRDn:KLYPH:SETPT` |
| Slow ADC config | ~48 (16/board x 3) | `LLRF:BRDn:MAX1270:CFGn` |
| HVPS masks | ~24 (8/board x 3) | `LLRF:BRDn:HVPS:MASK:n` |
| Housekeeping | ~18 (6/board x 3) | `LLRF:BRDn:TEMP:TRIP` |
| Tuner loops (x4) | ~52 | `LLRF:TUNER:Cn:GAIN_P` |
| Tuner balance (x4) | ~28 | `LLRF:TUNER:Cn:BALANCE:RATIO` |
| Motor drives | ~12 | `LLRF:CnTm:ENABLE` |
| State machine | ~16 | `LLRF:STATE:STn:VSET_GOAL` |
| HVPS interface | ~10 | `LLRF:HVPS:GAIN` |
| System config | ~5 | `LLRF:HW:CONFIG` |
| **Total** | **~550+** | |

### 15.2 Read-Only Readback PVs (Not in .pvs but essential)

These PVs are generated by the IOC and read by the Python coordinator:

```
LLRF:BRDn:CHm:AMP              # Amplitude readback (10 Hz)
LLRF:BRDn:CHm:PHASE            # Phase readback (10 Hz)
LLRF:BRDn:SCALAR:RAW:AMPm      # Raw scalar amplitude
LLRF:BRDn:SCALAR:RAW:PHASEm    # Raw scalar phase
LLRF:BRDn:ACQ:ADCm             # Waveform data arrays (16k)
LLRF:BRDn:ACQ:TSC              # Waveform timestamp counter
LLRF:BRDn:RTNA:MAG1/MAG2       # RTNA magnitude data
LLRF:BRDn:RTNA:PHASE1/PHASE2   # RTNA phase data
LLRF:BRDn:RTNA:FREQ1/FREQ2     # RTNA frequency data
LLRF:BRDn:INTERLOCK             # Interlock status
LLRF:BRDn:EXT:INTERLOCK         # External interlock status
LLRF:BRDn:INTERLOCK:HVPS        # HVPS interlock status
LLRF:ILOCK:ALL                  # Aggregate interlock
LLRF:BRDn:REVISION              # FPGA revision
LLRF:BRDn:GW_TYPE               # Gateware type
LLRF:BRDn:FSAMP                 # Sampling frequency readback
LLRF:BRDn:MAX1270:PCHn          # Slow ADC readbacks
LLRF:TUNER:Cn:LOOP.U            # Tuner control output
LLRF:BRDn:TEC:*                 # TEC readbacks
```

---

## Appendix: Source File Index

| Path | Type | Description |
|------|------|-------------|
| `LLRF9/llrf9_manual_print.pdf` | PDF | Dimtel LLRF9 Technical Manual v1.5 (44 pages) |
| `LLRF9/iGp/README.iGp` | Text | iGp distribution overview |
| `LLRF9/iGp/envSet.sh` | Shell | Environment setup |
| `LLRF9/iGp/bin/IOC_add` | Shell | IOC registration |
| `LLRF9/iGp/bin/iGp_display` | Shell | iGp GUI launcher |
| `LLRF9/iGp/bin/llrf_display` | Shell | LLRF GUI launcher |
| `LLRF9/iGp/bin/sweep.sh` | Shell | Parameter sweep tool |
| `LLRF9/iGp/dl_llrf/*.edl` | EDM | ~50 operator interface panels |
| `LLRF9/iGp/dl_llrf/pvs/LLRF.pvs` | Text | Complete PV save list (500+ PVs) |
| `LLRF9/iGp/matlab/llrf/*.m` | MATLAB | 17 LLRF signal processing scripts |
| `LLRF9/iGp/matlab/iGp/*.m` | MATLAB | 20+ iGp analysis scripts |
| `LLRF9/iGp/extensions/labca/` | Binary | MATLAB-EPICS interface libraries |
| `LLRF9/iGp/base/lib/` | Binary | EPICS 3.14 runtime libraries |

