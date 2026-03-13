# 00 — SPEAR3 HVPS Legacy System Design Report

> **Legacy System Documentation**: Comprehensive technical design report for the current SPEAR3 High Voltage Power Supply system (pre-upgrade)

## Executive Summary

This document provides a comprehensive design report for the current SPEAR3 High Voltage Power Supply (HVPS) legacy system operating at SLAC National Accelerator Laboratory. The system delivers −77 kV DC at 22 A (1.7 MW nominal) to power the SPEAR3 storage ring klystrons. Based on the proven PEP-II design architecture from 1997, this legacy system has been adapted for SPEAR3 operational requirements while maintaining the innovative star point controller topology and multi-layer arc protection system. This documentation serves as the baseline reference for the current system prior to planned LLRF upgrade integration.

**Key System Characteristics:**
- **Power Rating**: 1.7 MW nominal, 2.5 MW maximum capability
  - *Typical Operation*: ~1.4 MW (72.08 kVDC @ 19.4 A measured June 2020)
- **Output**: −77 kV DC @ 22 A (negative polarity for klystron cathode)
- **Configuration**: 2-unit system (SPEAR1 active, SPEAR2 warm spare)
- **Topology**: 12-pulse thyristor phase-controlled rectifier with star point controller
- **Protection**: 4-layer arc protection system with single-fault tolerance
- **Location**: Building 514 (power equipment), Building 118 (control systems)

> **Documentation Note**: This report reflects design specifications and system architecture. For detailed component-level specifications, current operational parameters, and technical analysis, refer to the [Design Notes Technical Synthesis](06-design-notes-synthesis.md) which provides comprehensive integration of all design documentation.

## System Architecture

### **Overall System Configuration**

The SPEAR3 HVPS evolution from the original PEP-II design to current operational configuration:

| **Parameter** | **Original PEP-II** | **SPEAR1 (Active)** | **SPEAR2 (Spare)** | **System Notes** |
|---------------|---------------------|---------------------|---------------------|------------------|
| **Design Era** | 1997 (8 units) | Current SPEAR3 | Current SPEAR3 | Based on PEP-II architecture |
| **Status** | Historical reference | Primary operational unit | Warm spare/backup | Operational redundancy |
| **Output** | 83 kV @ 23-27 A | −77 kV @ 22 A | −77 kV @ 22 A | Negative polarity for klystron |
| **Power** | 2.5 MW maximum | 1.7 MW nominal | 1.7 MW nominal | Lower operating point |
| **Input** | 12.5 kV 3-phase | 12.47 kV 3-phase | 12.47 kV 3-phase | Substation 507, breaker 160 |
| **Location** | PEP-II facility | Building 514 | Building 514 | Distributed control architecture |
| **Control** | Local control | Building 118 | Building 118 | EPICS/PLC based |
| **Units** | 8 independent units | 1 of 2 units | 1 of 2 units | Reduced from 8 to 2 units |

### **Power System Block Diagram**

```
Substation 507, Breaker 160
12.47 kV RMS 3φ AC
        │
   ┌────┴────┐
   │Switchgear│──── Disconnect Switch, Fuses (3×50A), Vacuum Contactor
   │ & Safety │     Ground Switch, Interlocks
   └────┬────┘
        │
  ┌─────┴──────┐
  │ Phase-Shift │  Extended Delta Transformer (3.5 MVA)
  │ Transformer │  Primary: 12.47 kV delta
  │   (T0)      │  Secondary: Dual wye ±15° phase shift
  └──┬─────┬───┘
     │     │
  ┌──┴──┐ ┌┴───┐
  │ T1  │ │ T2 │   Rectifier Transformers (1.5 MVA each)
  │(+15°)│ │(-15°)│  Primary: Open wye (floating neutral)
  │12.5kV│ │12.5kV│  Secondary: Dual wye, center-tapped
  └──┬──┘ └┬───┘
     │     │
  ┌──┴──┐ ┌┴───┐
  │6-Pulse│ │6-Pulse│   Phase Control Thyristor Bridges
  │Bridge │ │Bridge │   12 stacks total × 14 Powerex T8K7 SCRs each
  │(SCR1-6)│ │(SCR7-12)│  Star point controller configuration
  └──┬──┘ └┬───┘
     │     │ ┌─────────────────────────────────────────────┐
  ┌──┴──┐ ┌┴───┐                                          │
  │ L1  │ │ L2 │   Filter Inductors (Primary Side)        │
  │0.3H │ │0.3H│   85 A rated, 1,084 J stored energy each │
  │85A  │ │85A │   Air core, temperature monitored        │
  └──┬──┘ └┬───┘                                          │
     │     │                                              │
  ┌──┴─────┴───┐                                          │
  │  Secondary  │  4 Diode Rectifier Bridges (Series)     │
  │  Rectifiers │  Main Bridge: 30 kV, 30 A rating        │
  │  (D1-D24)   │  Filter Bridge: 30 kV, 3 A rating       │
  │             │  Total: 120 kV capability, 22 A cont.   │
  └──────┬──────┘                                          │
         │                                                │
  ┌──────┴──────┐                                          │
  │ Filter Bank │  Capacitor Bank: 8 μF total             │
  │ & Isolation │  500Ω Isolation Resistors (PEP-II)      │
  │ Resistors   │  Voltage Divider Network (1000:1)       │
  └──────┬──────┘                                          │
         │                                                │
  ┌──────┴──────┐                                          │
  │   Crowbar   │  4 SCR Stacks (Series Connected)        │
  │  Protection │  100 kV, 80 A rating each               │
  │  (SCR13-16) │  Fiber-optic trigger (~1μs delay)       │
  │             │  dV/dt snubber networks                 │
  └──────┬──────┘                                          │
         │                                                │
  ┌──────┴──────┐                                          │
  │ Cable Term. │  200μH Inductors (Layer 4 Protection)   │
  │ Inductors   │  Reduce cable discharge current         │
  │ (L3, L4)    │  Klystron interface protection          │
  └──────┬──────┘                                          │
         │                                                │
    −77 kV DC @ 22 A                                      │
    (to SPEAR3 Klystron)                                  │
                                                          │
                                                          │
    ┌─────────────────────────────────────────────────────┘
    │
    │  B118 HVPS Monitoring Signals (4 channels):
    │
    ├─── Signal 1: HVPS Output Voltage (DC voltage monitoring)
    ├─── Signal 2: HVPS Output Current (DC current monitoring)
    ├─── Signal 3: Inductor 2 Voltage (T2 firing circuit timing)
    └─── Signal 4: Transformer 1 Phase Current (T1 firing circuit health)
         │
         ▼
    ┌─────────────────┐
    │   Building 118  │  Scope/Waveform Buffer System
    │  Control Room   │  • 4-channel signal acquisition
    │                 │  • Upgraded design integration
    │  ┌─────────────┐│  • Real-time monitoring
    │  │ Oscilloscope││  • Event recording capability
    │  │ & Waveform  ││  • System diagnostics
    │  │ Buffer Sys. ││
    │  └─────────────┘│
    └─────────────────┘
```

## Power Conversion System

### **Primary Power Conversion**

**Input Power Specifications:**
- **Source**: SLAC Substation 507, Circuit Breaker 160
- **Voltage**: 12.47 kV RMS, 3-phase, 60 Hz
- **Power**: 2.5 MVA maximum capability
- **Protection**: 3×50A fuses, vacuum contactor, disconnect switch

**Phase-Shifting Transformer (T0):**
- **Rating**: 3.5 MVA, oil-immersed
- **Primary**: 12.47 kV delta connection
- **Secondary**: Dual wye configuration with ±15° phase shift
- **Purpose**: Creates 12-pulse rectification (reduces harmonics)
- **Cooling**: Oil circulation with temperature monitoring

**Rectifier Transformers (T1, T2):**
- **Rating**: 1.5 MVA each, oil-immersed
- **Primary**: Open wye connection (floating neutral for star point control)
- **Secondary**: Dual wye, center-tapped configuration
- **Voltage**: 12.5 kV primary, variable secondary (0-30 kV)
- **Phase Shift**: T1 at +15°, T2 at −15° (relative to input)

### **Thyristor Control System**

**Star Point Controller Configuration:**
- **Total SCR Stacks**: 12 stacks for phase control
- **SCR Type**: Powerex T8K7 series (8 kV, 700 A rating)
- **Stack Configuration**: 14 SCRs per stack in series
- **Control Method**: Phase angle control (0° to 180°)
- **Firing System**: Enerpro FCOG1200 12-pulse firing board

**Control Characteristics:**
- **Voltage Range**: 0 to −90 kV DC output
- **Control Resolution**: 16-bit DAC (0.1% resolution)
- **Response Time**: <10 ms for voltage changes
- **Regulation**: ±0.5% at voltages >65 kV
- **Ripple**: <1% peak-to-peak, <0.2% RMS

### **Secondary Rectification and Filtering**

**Diode Rectifier Bridges:**
- **Configuration**: 4 bridges in series (24 diodes total)
- **Main Bridge**: 30 kV, 30 A rating (primary power conversion)
- **Filter Bridge**: 30 kV, 3 A rating (5% extension for filtering)
- **Total Capability**: 120 kV, 22 A continuous
- **Cooling**: Forced air with temperature monitoring

**Filter System:**
- **Capacitor Bank**: 8 μF total capacitance
- **Isolation Resistors**: 500Ω (PEP-II innovation for arc protection)
- **Voltage Divider**: 1000:1 ratio for voltage monitoring
- **Energy Storage**: ~24 kJ at full voltage

## Control System Architecture

### **Control System Hierarchy**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   EPICS     │◄──►│ VXI Crate   │◄──►│    PLC      │◄──►│ Regulator   │◄──►│   Enerpro   │
│    IOC      │    │   & DCM     │    │  SLC-5/03   │    │    Card     │    │ FCOG1200    │
│             │    │             │    │             │    │ PC-237-230  │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       ▲                   ▲                   ▲                   ▲                   ▲
   Operator          Communication        Logic &             Analog              Firing
   Interface           Interface          Safety             Control             Control
                                         Control
                                                                                     │
                                                                                     ▼
                                                                            ┌─────────────┐
                                                                            │ SCR Gates   │
                                                                            │ 12 Stacks   │
                                                                            │ 168 SCRs    │
                                                                            └─────────────┘
```

### **Control System Components**

**EPICS Interface:**
- **IOC**: VxWorks-based Input/Output Controller
- **Database**: Process variables for voltage, current, status
- **Operator Interface**: MEDM screens for system control
- **Archiving**: Historical data storage and trending

**VXI Crate System:**
- **Chassis**: VXI mainframe with embedded controller
- **DCM Module**: Digital Communication Module for PLC interface
- **Protocol**: DH485 serial communication to PLC
- **Isolation**: Optical isolation for high voltage safety

**Programmable Logic Controller (PLC):**
- **Model**: Allen-Bradley SLC-5/03
- **Program**: SSRLV6-4-05-10 (SPEAR3 HVPS control logic)
- **I/O Modules**: Analog input/output, digital I/O
- **Safety Functions**: Interlocks, fault detection, emergency shutdown

**Regulator Card (PC-237-230-14-C0):**
- **Function**: Voltage and current feedback conditioning
- **Input**: High voltage divider signals, current transformer signals
- **Output**: Conditioned analog signals to firing board
- **Components**: Precision op-amps, isolation amplifiers, filters

**Firing Board (Enerpro FCOG1200):**
- **Function**: 12-pulse SCR gate pulse generation
- **Input**: Analog control signals from regulator card
- **Output**: Isolated gate pulses to 12 SCR stacks
- **Features**: Phase-locked loop, pulse transformer isolation

### **Power Supply System**

**Auxiliary Power Supplies (6 Kepco Units):**
- **+15V**: Analog circuits, op-amps (±1% regulation)
- **−15V**: Analog circuits, op-amps (±1% regulation)  
- **+5V**: Digital logic, PLC I/O (±2% regulation)
- **+24V**: Contactors, relays, indicators (±5% regulation)
- **+240V**: Gate drive circuits, isolation (±2% regulation)
- **+24VAC**: Cooling fans, auxiliary systems (±10% regulation)


### **Control System Implementation Details**

**PLC Hardware Configuration (Allen-Bradley SLC-500):**

| **Slot** | **Module Type** | **Function** | **I/O Points** |
|----------|-----------------|--------------|----------------|
| 0 | CPU Processor | Main control logic | - |
| 1 | 1747-DCM | VXI/EPICS interface | Communication |
| 2-13 | Various I/O | Analog/Digital I/O | 96+ points |

**Control Algorithms:**
- **Voltage Regulation**: Setpoint → N7:10 register (0-10V → 0-32767 counts)
- **Phase Control**: N7:11 register for thyristor firing angle
- **Ramp Control**: Startup/shutdown sequencing with configurable rates
- **Feedback Processing**: Real-time scaling and conditioning

**EPICS Integration:**
- **Interface**: VXI-based communication protocol
- **Update Rate**: <100 ms for real-time data
- **PV Count**: 26 EPICS Process Variables
- **Functions**: Monitoring, control, alarm management, data logging

**Signal Flow:**
```
EPICS IOC → VXI Crate → 1747-DCM → SLC-500 PLC → Analog Output → 
Regulator Card → Enerpro Firing Board → Thyristor Gates
```
## Protection Systems

### **Multi-Layer Arc Protection Architecture**

The SPEAR3 HVPS implements a sophisticated **four-layer protection system** designed with single-fault tolerance to ensure klystron survival even if the primary crowbar system fails.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MULTI-LAYER PROTECTION SYSTEM                        │
│                                                                             │
│  Layer 1: PASSIVE PROTECTION (Filter Capacitor Isolation)                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ • 500Ω Isolation Resistors (PEP-II Innovation)                     │   │
│  │ • Limits arc current to ~50 A for ~4 ms                            │   │
│  │ • Energy delivery: <40 J (within klystron tolerance)               │   │
│  │ • Response: Immediate (passive component)                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    ↓ (if insufficient)                      │
│  Layer 2: SEMI-ACTIVE PROTECTION (Inductor Bypass)                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ • Star Point Controller bypasses filter inductor energy            │   │
│  │ • Reduces stored energy contribution (1,084 J per inductor)        │   │
│  │ • Response time: 4-8 ms (thyristor turn-off)                       │   │
│  │ • Prevents inductor energy from reaching klystron                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    ↓ (if insufficient)                      │
│  Layer 3: ACTIVE PROTECTION (SCR Crowbar)                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ • 4 SCR stacks (100 kV, 80 A each) in series                       │   │
│  │ • Fiber-optic trigger system (~1μs delay)                          │   │
│  │ • Energy delivery: <5 J (primary protection target)                │   │
│  │ • dV/dt snubber networks for reliable triggering                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    ↓ (backup protection)                    │
│  Layer 4: CABLE TERMINATION (Inductors)                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ • 200μH inductors at cable termination                              │   │
│  │ • Reduces cable discharge current                                   │   │
│  │ • Final impedance matching to klystron                             │   │
│  │ • Prevents reflection and standing waves                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### **Protection System Performance**

**Design Philosophy:**
- **Single-Fault Tolerance**: Klystron survives even if crowbar fails
- **Energy Limitation**: Multiple independent energy limiting mechanisms
- **Response Time Hierarchy**: Faster systems provide backup for slower systems
- **Klystron Tolerance**: 60 J maximum (system delivers <40 J worst case)

**Protection Performance Specifications:**

| **Protection Layer** | **Response Time** | **Energy Limit** | **Mechanism** | **Reliability** |
|---------------------|------------------|------------------|---------------|-----------------|
| **Layer 1 (Passive)** | Immediate | <40 J | 500Ω resistors | 100% (passive) |
| **Layer 2 (Semi-Active)** | 4-8 ms | Variable | Inductor bypass | >99% (thyristor) |
| **Layer 3 (Active)** | ~1 μs | <5 J | SCR crowbar | >99.9% (redundant) |
| **Layer 4 (Termination)** | Immediate | N/A | Cable inductors | 100% (passive) |

### **Fault Detection and Response**

**Arc Detection Methods:**
- **dV/dt Detection**: Rapid voltage collapse detection
- **Current Monitoring**: Overcurrent detection via Danfysik DC-CT
- **Fiber-Optic Signals**: Klystron arc detection from RF system
- **Voltage Monitoring**: 9-channel voltage monitoring system

**Response Actions:**
1. **Immediate**: Crowbar trigger via fiber-optic system
2. **Fast**: Primary thyristor turn-off (star point controller)
3. **Backup**: Secondary protection systems activation
4. **Recovery**: System reset and restart sequence


### **Trigger Disable Methods and Response Times**

The HVPS protection system implements **five specific methods** to disable triggers with varying response times:

1. **Fiber Optic SCR Enable** (LLRF System)
   - **Response Time**: <1 μs
   - **Source**: LLRF system control
   - **Function**: Primary fast disable for RF system coordination

2. **Transformer Arc Detection** (Electronic Circuit)
   - **Response Time**: <10 μs  
   - **Source**: Electronic arc detection circuit
   - **Function**: High-voltage transformer protection

3. **Fiber Optic Crowbar** (LLRF System)
   - **Response Time**: <1 μs
   - **Source**: LLRF system emergency signal
   - **Function**: Ultra-fast crowbar activation

4. **Klystron Arc Detection** (Pearson Transformer)
   - **Response Time**: <10 μs
   - **Source**: Pearson current transformer
   - **Function**: Klystron arc fault detection

5. **PLC Force Crowbar** (Software Command)
   - **Response Time**: <10 ms
   - **Source**: PLC software control
   - **Function**: Manual or programmed crowbar activation

These methods provide **redundant protection layers** with fail-safe design principles, ensuring klystron survival even under multiple fault conditions.
## Monitoring and Instrumentation

### **Voltage Monitoring System**

**High Voltage Measurement:**
- **Primary Divider**: 1000:1 precision voltage divider
- **Channels**: 9 independent voltage monitoring points
- **Accuracy**: ±0.1% full scale
- **Isolation**: High voltage isolation to ground
- **Range**: 0 to −90 kV DC

**Monitoring Points:**
1. **Main Output**: Total system output voltage
2. **Bridge 1**: First rectifier bridge output
3. **Bridge 2**: Second rectifier bridge output  
4. **Bridge 3**: Third rectifier bridge output
5. **Bridge 4**: Fourth rectifier bridge output
6. **Filter**: Post-filter voltage
7. **Crowbar**: Pre-crowbar voltage
8. **Cable**: Cable termination voltage
9. **Reference**: System reference and calibration

### **Current Monitoring System**

**DC Current Measurement:**
- **Sensor**: Danfysik DC-CT (DC Current Transformer)
- **Range**: 0 to 30 A DC
- **Accuracy**: ±0.1% of reading
- **Isolation**: Magnetic isolation (no electrical connection)
- **Output**: ±10V analog signal proportional to current

### **Temperature Monitoring**

**Critical Temperature Points:**
- **Transformer Oil**: 4 thermocouples in transformer oil
- **Inductor Cores**: Air core inductor temperature monitoring
- **SCR Heat Sinks**: Thyristor junction temperature estimation
- **Ambient**: Control room and power equipment ambient temperature

**Temperature Specifications:**
- **Transformer Oil**: Normal <65°C, Alarm >80°C, Trip >95°C
- **Inductors**: Normal <85°C, Alarm >100°C
- **SCRs**: Normal <85°C, Alarm >100°C, Trip >125°C
- **Ambient**: Normal 15-25°C, Alarm >30°C

### **Oil Level Monitoring**

**Transformer Oil Systems:**
- **Sensors**: 3 oil level sensors (phase-shift transformer, 2 rectifier transformers)
- **Type**: Float-type level switches with magnetic coupling
- **Alarm Levels**: Low level alarm, critically low level trip
- **Indication**: Local and remote indication via PLC

### **B118 Waveform Buffer System**

**Advanced Signal Acquisition (4 Channels):**
The Building 118 control room houses an oscilloscope and waveform buffer system that monitors 4 critical HVPS signals for upgraded design integration and system diagnostics:

| **Channel** | **Signal Source** | **Signal Type** | **Purpose** | **Specifications** |
|-------------|------------------|-----------------|-------------|-------------------|
| **Channel 1** | HVPS output | DC Voltage | Primary power monitoring | 0 to −90 kV DC, voltage divider (1000:1 ratio) |
| **Channel 2** | HVPS output | DC Current | Load current monitoring | 0 to 30 A DC nominal (22 A typical), Danfysik DC-CT sensor with ±10V output |
| **Channel 3** | Inductor 2 (T2) | Sawtooth voltage | T2 firing circuit timing diagnosis | Sawtooth pattern indicates thyristor firing |
| **Channel 4** | Transformer 1 | AC Phase Current | T1 firing circuit health | AC waveform with thyristor commutation spikes |

**System Capabilities:**
- **Real-time Monitoring**: Continuous 100 ms rolling buffer of all 4 channels
- **Event Recording**: Automatic capture triggered on voltage loss or fault conditions
- **Waveform Analysis**: Post-event detailed analysis of causal events leading to faults
- **Integration**: Designed for upgraded control system and LLRF integration
- **Data Storage**: Historical waveform data for trend analysis and component degradation detection
- **Remote Access**: Network connectivity for remote monitoring and archive

**Applications:**
- **Arc Event Analysis**: Detailed waveform capture during klystron arcs
- **System Performance**: Monitoring voltage regulation and current stability
- **Protection Verification**: Crowbar system response time measurement
- **Predictive Maintenance**: Trend analysis for component degradation
- **System Optimization**: Performance tuning and efficiency analysis


### **EPICS Process Variables and Diagnostic Capabilities**

**EPICS PV Specifications:**
- **Total PVs**: 26 Process Variables for complete system monitoring
- **Update Rate**: <100 ms for real-time data acquisition
- **Data Types**: Analog inputs, digital status, calculated values, alarm states

**Key Monitoring Categories:**

| **Category** | **PV Examples** | **Function** | **Update Rate** |
|--------------|-----------------|--------------|----------------|
| **Voltage** | HVPS:VOLT:MEAS | High voltage measurement | <100 ms |
| **Current** | HVPS:CURR:MEAS | Load current monitoring | <100 ms |
| **Status** | HVPS:STATUS | System operational state | <100 ms |
| **Alarms** | HVPS:ALARM:* | Fault condition reporting | <100 ms |
| **Control** | HVPS:SETPOINT | Voltage/current setpoints | <100 ms |

**EDM Diagnostic Panels:**
- **Main Control Panel**: Primary operator interface with key parameters
- **Detailed Diagnostics**: Comprehensive system status and trending
- **Alarm Management**: Fault history and acknowledgment interface
- **Trend Displays**: Historical data visualization and analysis

**Real-Time Capabilities:**
- **Continuous Monitoring**: All critical parameters tracked continuously
- **Alarm Processing**: Immediate notification of fault conditions
- **Data Logging**: Historical data storage for analysis and trending
- **Remote Access**: Network-based monitoring and control capability
## Physical Layout and Installation

### **Building 514 (Power Equipment)**

**High Voltage Equipment:**
- **Transformers**: Oil-filled transformers in outdoor installation
- **Switchgear**: Indoor metal-clad switchgear (12.47 kV class)
- **Rectifiers**: Indoor installation in ventilated enclosures
- **Crowbar**: High voltage SCR assemblies in SF6 enclosures

**Layout Considerations:**
- **Clearances**: IEEE 516 high voltage clearance requirements
- **Access**: Maintenance access for all major components
- **Ventilation**: Forced air cooling for power electronics
- **Grounding**: Comprehensive grounding system for safety

### **Building 118 (Control Systems)**

**Control Equipment:**
- **EPICS IOC**: VxWorks computer system in 19" rack
- **VXI Crate**: VXI mainframe with communication modules
- **PLC**: Allen-Bradley SLC-5/03 in NEMA enclosure
- **Power Supplies**: 6 Kepco power supplies in rack mount

**Interface Connections:**
- **Fiber Optic**: High voltage isolation for critical signals
- **Shielded Cable**: Analog signals with EMI protection
- **Ethernet**: EPICS network communication
- **Serial**: DH485 PLC communication protocol

## System Performance and Specifications

### **Electrical Performance**

**Output Specifications:**
- **Voltage**: −77 kV DC nominal (−90 kV maximum)
- **Current**: 22 A nominal (30 A maximum)
- **Power**: 1.7 MW nominal (2.5 MW maximum)
- **Polarity**: Negative (klystron cathode connection)

**Regulation and Stability:**
- **Voltage Regulation**: ±0.5% at voltages >65 kV
- **Current Regulation**: ±1% at currents >10 A
- **Ripple**: <1% peak-to-peak, <0.2% RMS
- **Stability**: <0.1%/hour drift after warm-up

**Dynamic Performance:**
- **Voltage Response**: <10 ms for 10% step change
- **Current Limiting**: Programmable current limit (0-30 A)
- **Arc Recovery**: <100 ms recovery time after arc
- **Restart Time**: <30 seconds for complete system restart

### **Efficiency and Power Quality**

**System Efficiency:**
- **Overall Efficiency**: >92% at full load
- **Transformer Losses**: ~2% (copper and core losses)
- **Rectifier Losses**: ~3% (conduction and switching losses)
- **Filter Losses**: ~1% (resistive and reactive losses)

**Input Power Quality:**
- **Power Factor**: >0.95 at full load (12-pulse rectification)
- **THD**: <5% total harmonic distortion
- **Harmonics**: Meets IEEE 519 harmonic limits
- **Unbalance**: <2% phase unbalance tolerance

## Reliability and Maintenance

### **System Reliability**

**Design Life:**
- **Transformers**: 30+ years (oil-filled, conservative design)
- **Thyristors**: 20+ years (derated operation, thermal management)
- **Control Electronics**: 15+ years (industrial grade components)
- **Overall System**: 25+ years with proper maintenance

**Redundancy Features:**
- **Dual Unit Configuration**: SPEAR1 active, SPEAR2 spare
- **Protection Redundancy**: 4-layer protection system
- **Control Backup**: Manual control capability
- **Component Sparing**: Critical spare parts inventory

### **Maintenance Requirements**

**Routine Maintenance (Monthly):**
- **Visual Inspection**: All equipment for signs of deterioration
- **Oil Level Check**: Transformer oil levels and condition
- **Temperature Monitoring**: Review temperature trends
- **Cleaning**: Dust removal from air-cooled components

**Periodic Maintenance (Annual):**
- **Oil Analysis**: Transformer oil dielectric strength testing
- **Calibration**: Voltage and current monitoring calibration
- **Insulation Testing**: High voltage insulation resistance
- **Contact Inspection**: Switchgear contact condition

**Major Maintenance (5-Year):**
- **Transformer Service**: Oil replacement, internal inspection
- **Thyristor Testing**: SCR parameter verification
- **Control System Update**: Software and hardware updates
- **Protection Testing**: Arc protection system verification

### **Spare Parts and Components**

**Critical Spare Parts:**
- **SCRs**: Powerex T8K7 thyristors (complete stacks)
- **Diodes**: High voltage rectifier diodes
- **Control Cards**: Regulator and firing board assemblies
- **Fuses**: High voltage and control circuit fuses

**Component Obsolescence Management:**
- **PLC**: SLC-5/03 approaching end-of-life (replacement planning)
- **Regulator Card**: Custom SLAC design (documentation preserved)
- **Firing Board**: Enerpro FCOG1200 (manufacturer support available)
- **Power Supplies**: Kepco units (current production models)


### **Component Obsolescence and Replacement Planning**

**Critical Obsolescence Issues:**

| **Component** | **Current Status** | **Replacement Recommendation** | **Timeline** | **Impact** |
|---------------|-------------------|--------------------------------|--------------|------------|
| **Allen-Bradley SLC-5/03** | End-of-life | Modern CompactLogix PLC | 2-3 years | High - Control system |
| **Enerpro FCOG1200** | Limited support | FCOG6100 or equivalent | 3-5 years | Medium - Firing system |
| **PC-237-230 Regulator** | Custom SLAC design | SD-237-230-14-C1 documented | As needed | Medium - Regulation |
| **DC-DC Converters** | Aging components | Modern isolated converters | 2-4 years | Low - Signal conditioning |
| **ASICs/Custom ICs** | Potential obsolescence | Functional equivalents | As needed | Variable |

**Replacement Strategy:**
- **Proactive Planning**: Replace components before failure
- **Functional Equivalents**: Maintain system performance specifications
- **Documentation**: Complete replacement procedures and validation
- **Testing Protocol**: Comprehensive validation of replacement components
- **Inventory Management**: Strategic spare parts procurement

**Maintenance Timeline:**
- **Immediate (0-1 year)**: Critical spare parts inventory
- **Short-term (1-3 years)**: PLC replacement planning and implementation
- **Medium-term (3-5 years)**: Firing system and regulator updates
- **Long-term (5+ years)**: Complete control system modernization
## Safety Systems and Procedures

### **Personnel Protection System (PPS) Integration**

**High Voltage Safety:**
- **Access Control**: Keyed interlocks on high voltage areas
- **Warning Systems**: Audible and visual warnings before energizing
- **Emergency Stops**: Multiple emergency stop locations
- **Grounding**: Portable grounding equipment for maintenance

**Operational Safety:**
- **Procedures**: Detailed lockout/tagout procedures
- **Training**: Required high voltage safety training
- **PPE**: Personal protective equipment requirements
- **Permits**: High voltage work permit system

### **Environmental and Regulatory Compliance**

**Environmental Considerations:**
- **Oil Containment**: Secondary containment for transformer oil
- **EMI/RFI**: Electromagnetic compatibility compliance
- **Noise**: Acoustic noise limits for cooling systems
- **Waste Management**: Proper disposal of electronic components

**Regulatory Compliance:**
- **NEC**: National Electrical Code compliance
- **IEEE Standards**: IEEE 516 (high voltage), IEEE 519 (harmonics)
- **OSHA**: Occupational safety requirements
- **Local Codes**: California electrical and building codes

## Future Considerations and Upgrades

### **System Modernization Opportunities**

**Control System Upgrades:**
- **PLC Replacement**: Modern PLC to replace aging SLC-5/03
- **EPICS Upgrade**: Current EPICS version with improved features
- **HMI Modernization**: Modern operator interface systems
- **Network Security**: Cybersecurity improvements for control networks

**Power Electronics Improvements:**
- **IGBT Technology**: Potential upgrade from SCRs to IGBTs
- **Digital Control**: Digital firing control systems
- **Monitoring Enhancement**: Advanced diagnostic capabilities
- **Efficiency Optimization**: Power factor correction improvements

### **Long-Term Strategic Planning**

**Technology Roadmap:**
- **Component Lifecycle**: Proactive replacement of aging components
- **Performance Enhancement**: Continuous improvement opportunities
- **Reliability Improvement**: Predictive maintenance implementation
- **Documentation Updates**: Maintain current technical documentation


### **LLRF9 Integration Planning**

**Fiber Optic Interface Requirements:**
- **SCR Enable Signal**: Ultra-fast (<1 μs) trigger disable capability
- **Crowbar Signal**: Emergency protection with fail-safe design
- **Signal Isolation**: Galvanic isolation for safety and noise immunity
- **Redundancy**: Dual-path signaling for critical protection functions

**Integration Points:**
- **Right/Left Side Trigger Boards**: Logic gate integration with LLRF signals
- **Protection System Coordination**: Integration with existing 4-layer protection
- **Timing Synchronization**: Coordination with RF system timing requirements
- **Diagnostic Integration**: LLRF system status monitoring via EPICS

**Technical Requirements:**
- **Response Time**: Maintain <1 μs fiber optic response capability
- **Fail-Safe Operation**: Default to safe state on signal loss
- **Compatibility**: Maintain existing protection system functionality
- **Documentation**: Complete integration procedures and validation testing

**Implementation Considerations:**
- **Phased Approach**: Gradual integration to minimize operational impact
- **Testing Protocol**: Comprehensive validation of protection system integration
- **Backup Systems**: Maintain existing protection during transition
- **Training Requirements**: Operations staff familiarization with new interfaces
**Investment Priorities:**
1. **Control System Modernization** (highest priority)
2. **Monitoring System Enhancement** (medium priority)
3. **Power Electronics Upgrade** (long-term consideration)
4. **Infrastructure Improvements** (ongoing maintenance)

## Conclusions

The SPEAR3 HVPS represents a mature, well-engineered power supply system based on proven PEP-II design principles. The system successfully delivers reliable high voltage power to the SPEAR3 storage ring klystrons while maintaining excellent regulation, low ripple, and comprehensive arc protection.

**Key Strengths:**
- **Proven Design**: Based on successful PEP-II architecture
- **Robust Protection**: Multi-layer arc protection with single-fault tolerance
- **High Reliability**: Dual-unit configuration with comprehensive monitoring
- **Excellent Performance**: Meets all electrical specifications with margin

**Areas for Improvement:**
- **Control System Aging**: PLC and associated electronics approaching end-of-life
- **Documentation**: Continuous updates needed for current configuration
- **Monitoring Enhancement**: Opportunities for improved diagnostics
- **Efficiency Optimization**: Potential for power factor and efficiency improvements

The system is expected to continue reliable operation for many years with proper maintenance and strategic component upgrades. The comprehensive protection systems and conservative design provide excellent safety margins for both equipment and personnel.

---

**Document Status**: Comprehensive current system design report  
**Scope**: Complete SPEAR3 HVPS system as currently configured  
**Application**: System understanding, maintenance planning, and modernization guidance  
**Maintenance**: Regular updates as system evolves and improvements are implemented
