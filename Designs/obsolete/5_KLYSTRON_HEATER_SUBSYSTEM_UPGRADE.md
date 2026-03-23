# Klystron Heater Subsystem Upgrade Technical Note

**Document ID**: SPEAR3-LLRF-TN-004  
**Title**: Commercial Programmable AC Supply for Klystron Cathode Heater Control System Upgrade  
**Author**: LLRF Upgrade Team  
**Date**: March 2026  
**Version**: 2.0  
**Status**: Design Phase  

---

## Executive Summary

This technical note documents the design and implementation requirements for upgrading the SPEAR3 klystron cathode heater control system from the current aged variac/motor-based system to a modern **commercial programmable AC supply**. The upgrade is part of the comprehensive LLRF9 system modernization and addresses reliability, precision, and integration requirements for the next generation RF control system.

**Key Upgrade Features**:
- Commercial programmable AC supply with <100ms response time
- Clean sine wave output (no custom filtering required)
- True RMS voltage and current monitoring
- Full EPICS integration with automated control sequences
- Enhanced safety features and fault protection
- **COTS solution** (no custom fabrication required)

**Design Philosophy**: Rather than developing a custom SCR-based controller, the upgrade leverages a commercial off-the-shelf (COTS) programmable AC supply. This approach reduces development risk, eliminates custom fabrication costs, and provides proven reliability with >50,000 hour MTBF.

---

## 1. Current System Analysis

### 1.1 Legacy PEP-II Era System

**Reference Documentation**: `llrf/documentation/filamentHeater/FILAMENT_HEATER_TECHNICAL_NOTES.md` provides comprehensive technical analysis of the legacy system (SD-349-311-20 Rev E2).

The current klystron heater control system is inherited from the PEP-II era and consists of:

**Legacy System Architecture**:
```
                    LEGACY SYSTEM (PEP-II Era)
                         SD-349-311-20

┌─────────────────────────────────────────────────┐
│              CONTROL METHOD                     │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │ Allen-Bradley   │  │ Motor-Driven    │       │
│  │ PLC             │►│ Variac          │       │
│  │ (Limited I/O)   │  │ (Mechanical)    │       │
│  └─────────────────┘  └─────────────────┘       │
│                                                 │
│              POWER STAGE                        │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │ 120 VAC         │  │ SS Relay        │       │
│  │ Phase C         │►│ ON/OFF Only     │       │
│  │                 │  │                 │       │
│  └─────────────────┘  └─────────────────┘       │
│           │                    │                │
│           ▼                    ▼                │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │ Variac V1       │  │ Toroidal        │       │
│  │ 1 KVA           │►│ Transformer     │       │
│  │ 0-140 VAC       │  │ 10:1 Ratio      │       │
│  └─────────────────┘  └─────────────────┘       │
│           │                    │                │
│           ▼                    ▼                │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │ Motor M1        │  │ ~6.8 V RMS     │       │
│  │ UP/DOWN         │  │ ~73 A           │       │
│  │ Limit Switches  │  │ to Cathode      │       │
│  └─────────────────┘  └─────────────────┘       │
│                                                 │
│              MONITORING                         │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │ Texmate CT      │  │ Front Panel     │       │
│  │ Analog Meters   │  │ LEDs DS1/DS2    │       │
│  │ Hours Counter   │  │ Manual Switches │       │
│  └─────────────────┘  └─────────────────┘       │
└─────────────────────────────────────────────────┘
```

**Current Specifications** (verified from SD-349-311-20):
```
Input Power: 120VAC, Phase C (from Hoffman Box B118)
Output: ~6.8V RMS / ~73A actual operational
Power Rating: ~500W actual operation (1000W max capability)
Isolation: Transformer isolated for HV safety (up to 90 kV)
Control: J1 connector → Fiber Optic → Allen-Bradley PLC → EPICS
Variac: 1.00 KVA, 0-140 VAC motor-driven (V1)
Transformer: 10:1 ratio, 3-turn primary toroidal (T1)
Monitoring: Texmate CT, voltage divider, front panel meters
```

### 1.2 System Limitations

**Performance Issues**:
- **Slow Response**: Motor-driven variac requires seconds to minutes for adjustment
- **Limited Precision**: Mechanical variac resolution ~±1% of full scale
- **Aging Components**: 25+ year old system with increasing failure rates
- **Manual Operation**: Requires operator intervention for power adjustments

**Integration Deficiencies**:
- **Poor EPICS Integration**: Limited monitoring and control capabilities
- **No Automated Sequences**: Manual warm-up and cool-down procedures
- **Minimal Diagnostics**: No real-time power, voltage, or current monitoring
- **Limited Safety Features**: Basic overcurrent protection only

**Maintenance Challenges**:
- **Mechanical Wear**: Motor and variac components require regular maintenance
- **Obsolete Parts**: Replacement components difficult to source
- **Calibration Drift**: Mechanical systems require frequent recalibration
- **Reliability Issues**: Increasing downtime due to component failures

---

## 2. Klystron Heater Requirements

### 2.1 Electrical Specifications

**SPEAR3 Klystron Heater Requirements** (based on 25+ years operational data):
```
Heater Voltage: 6.8V RMS (actual operational)
Heater Current: 73A (actual operational)
Power Rating: 500W nominal operation
Regulation: ±0.1% (improved from current ±1%)
Isolation: Up to 90 kV (HVPS cathode voltage)
Response Time: <100ms (vs. seconds for variac)
```

**Industry Standard Comparison**:
| Parameter | SPEAR3 | Typical Range | Notes |
|-----------|--------|---------------|-------|
| Heater Voltage | 6.8V actual | 5-30V | Depends on cathode type |
| Heater Current | 73A actual | 20-50A | CW operation |
| Power | 500W actual | 100-1500W | Varies by klystron size |
| Regulation | ±0.1% | ±0.3% | Stability requirement |
| Isolation | 90 kV | Up to 130 kV | High voltage cathode |

### 2.2 Thermal Considerations

**Cathode Heating Characteristics**:
- **Heating Time Constant**: 3-5 minutes for full warm-up
- **Temperature Stability**: ±1°C for consistent emission
- **Thermal Cycling**: Controlled ramp rates prevent cathode damage
- **Operating Temperature**: ~1000°C cathode surface temperature

**Operational Requirements**:
- **Soft Start**: Controlled ramp-up prevents thermal shock
- **Standby Mode**: Reduced power for cathode maintenance
- **Emergency Shutdown**: Immediate power removal capability
- **Cool-down Control**: Gradual power reduction for safe shutdown

---

## 3. Commercial Programmable AC Supply Solution

### 3.1 COTS Approach Advantages

**Design Philosophy** (from SPEAR3-LLRF-PDR-001):
> "The parts cost is higher but there is no fabrication cost or effort — a fully COTS solution."

**Key Benefits**:
- **No Custom Fabrication**: Eliminates design, development, and manufacturing costs
- **Proven Reliability**: Commercial units typically >50,000 hour MTBF
- **Clean Sine Wave Output**: No harmonic filtering required
- **Built-in Protection**: Overcurrent, overvoltage, thermal protection
- **Standard Interfaces**: Ethernet, RS-485, analog I/O options
- **Vendor Support**: Technical support, spare parts, documentation

### 3.2 Commercial AC Supply Architecture

**Complete Commercial AC Supply System Architecture**:
```
                        SPEAR3 KLYSTRON HEATER UPGRADE ARCHITECTURE
                              (Commercial AC Supply Design)

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              CONTROL LAYER                                          │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                 │
│  │ EPICS IOC       │    │ Python          │    │ Operator        │                 │
│  │ Process         │◄──►│ Coordinator     │◄──►│ Interface       │                 │
│  │ Variables       │    │ Automated       │    │ (CSS/EDM)       │                 │
│  │ (PV Database)   │    │ Sequences       │    │                 │                 │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘                 │
│           │                       │                       │                        │
└───────────┼───────────────────────┼───────────────────────┼────────────────────────┘
            │ (Ethernet/EPICS)      │                       │
            ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                             POWER CONTROL LAYER                                     │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                 │
│  │ Commercial      │    │ Ethernet/       │    │ RF MPS          │                 │
│  │ Programmable    │    │ RS-485          │    │ Integration     │                 │
│  │ AC Supply       │◄──►│ Interface       │◄──►│ (Permit Logic)  │                 │
│  │ (COTS Unit)     │    │ Module          │    │                 │                 │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘                 │
│           │                       │                       │                        │
│           ▼                       ▼                       ▼                        │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                 │
│  │ True RMS        │    │ Safety          │    │ Status          │                 │
│  │ Monitoring      │    │ Interlocks      │    │ Indicators      │                 │
│  │ (Built-in)      │    │ (Hardware)      │    │ (Local/Remote)  │                 │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘                 │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼ (Clean AC Power)
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              POWER CONDITIONING                                     │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                 │
│  │ 120 VAC         │    │ Isolation       │    │ 6.8V/73A Output │                 │
│  │ Input           │───►│ Transformer     │───►│ Precise         │                 │
│  │ (Phase C)       │    │ (Retained from  │    │ Regulation      │                 │
│  │                 │    │ Legacy System)  │    │                 │                 │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘                 │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Key Design Considerations

**Commercial AC Supply Selection Criteria**:
- **Power Rating**: ≥1000W (2x operational requirement for headroom)
- **Voltage Range**: 0-150V AC (covers full operational range)
- **Current Capability**: ≥10A (adequate for primary side of 10:1 transformer)
- **Regulation**: ±0.1% or better
- **Response Time**: <100ms for setpoint changes
- **Communication**: Ethernet and/or RS-485 interface
- **Protection**: Built-in overcurrent, overvoltage, thermal protection

**Integration Features**:
- **EPICS Compatibility**: Standard communication protocols
- **Remote Monitoring**: Voltage, current, power, status via network
- **Automated Sequences**: Programmable ramp profiles
- **Fault Reporting**: Detailed fault codes and status
- **Safety Interlocks**: Hardware and software protection layers

---

## 4. System Integration

### 4.1 RF MPS Integration

**Heater Controller Role in RF MPS** (from PDR):
> "Heater controller is part of RF MPS — klystron does not receive a permit to operate unless the heater has reached power level and timed out."

**Integration Points**:
- **Permit Logic**: Heater "ready" status required for RF permit
- **Hardware Monitoring**: RMS voltage and current monitored by MPS
- **Fault Response**: Heater faults trigger RF system protective actions
- **Emergency Shutdown**: MPS emergency stop triggers immediate heater shutdown

### 4.2 HVPS Coordination

**Critical Interlocks**:
- **Startup Sequence**: Heater must be at operating temperature before HVPS enable
- **Shutdown Sequence**: HVPS must be off before heater cooldown begins
- **Fault Coordination**: HVPS faults trigger heater standby mode
- **Status Sharing**: Heater status available to HVPS control logic

### 4.3 EPICS Integration

**Process Variables (PVs)**:
```
# Monitoring PVs
SRF1:HTR:VOLT:RMS      # RMS voltage readback (V)
SRF1:HTR:CURR:RMS      # RMS current readback (A)
SRF1:HTR:PWR:RMS       # Calculated power (W)
SRF1:HTR:STATUS        # System status
SRF1:HTR:FAULT         # Fault conditions

# Control PVs
SRF1:HTR:ENABLE        # System enable/disable
SRF1:HTR:VOLT:SP       # Voltage setpoint (V)
SRF1:HTR:RAMP:RATE     # Voltage ramp rate (V/s)
SRF1:HTR:RAMP:START    # Start ramp sequence
SRF1:HTR:RAMP:STOP     # Stop ramp sequence
SRF1:HTR:EMERGENCY     # Emergency shutdown
```

---

## 5. Operational Modes and Sequences

### 5.1 Operating Modes

**1. OFF**: System disabled, no power to heater
- Heater Power: 0W
- Status: DISABLED
- Permit: Not available

**2. STANDBY**: Reduced power for cathode maintenance
- Heater Power: 125W (25% of nominal)
- Purpose: Maintain cathode temperature above ambient
- Status: STANDBY

**3. WARMUP**: Controlled ramp to operating power
- Heater Power: Ramping from 125W to 500W
- Ramp Rate: Programmable (typically 2-5 minutes)
- Status: WARMING

**4. OPERATING**: Full operational power
- Heater Power: 500W (100% of nominal)
- Status: READY
- Permit: Available for RF operation

**5. COOLDOWN**: Controlled power reduction
- Heater Power: Ramping from 500W to 125W
- Status: COOLING

### 5.2 Automated Sequences

**Startup Sequence**:
```python
def heater_startup():
    set_mode("STANDBY")
    wait_for_stable_power(125W, timeout=60s)
    
    set_mode("WARMUP")
    ramp_power(125W → 500W, rate=2W/s)
    
    if heater_stable() and temp_in_range():
        set_mode("OPERATING")
        log_event("Heater startup complete")
```

**Shutdown Sequence**:
```python
def heater_shutdown():
    if hvps_enabled():
        raise Exception("HVPS must be disabled before heater shutdown")
    
    set_mode("COOLDOWN")
    ramp_power(500W → 125W, rate=1W/s)
    
    wait_for_stable_power(125W, timeout=300s)
    set_mode("STANDBY")
    log_event("Heater shutdown complete")
```

**Emergency Shutdown**:
```python
def emergency_shutdown():
    disable_output()
    set_mode("OFF")
    send_alarm("HEATER_EMERGENCY_SHUTDOWN")
```

---

## 6. Implementation Plan

### 6.1 Hardware Procurement

**Commercial AC Supply Specifications**:
- **Vendor Options**: Evaluate suppliers (e.g., Magna-Power, Sorensen, TDK-Lambda)
- **Power Rating**: 1000W minimum
- **Voltage Range**: 0-150V AC
- **Communication**: Ethernet + RS-485
- **Protection**: Comprehensive built-in protection

### 6.2 Integration Timeline

**Phase 1: Procurement and Testing**
- Commercial AC supply procurement
- Bench testing with dummy load
- Communication interface development

**Phase 2: Software Development**
- EPICS IOC development
- Python coordinator integration
- Automated sequence programming

**Phase 3: System Integration**
- Installation in test environment
- Integration with RF MPS
- HVPS coordination testing

**Phase 4: Commissioning**
- Installation at SPEAR3
- System commissioning
- Operational validation

---

## 7. Conclusion

The commercial programmable AC supply approach for the SPEAR3 klystron heater upgrade provides significant advantages over both the legacy variac system and custom SCR-based alternatives:

**Key Benefits**:
- **Proven Reliability**: Commercial units with >50,000 hour MTBF
- **No Development Risk**: COTS solution eliminates custom design risks
- **Clean Power Output**: No harmonic filtering required
- **Fast Response**: <100ms vs. seconds for legacy system
- **Full Integration**: Complete EPICS integration with automated sequences
- **Cost Effective**: Higher parts cost offset by elimination of development effort

**Performance Improvements**:
- **Response Time**: Seconds-Minutes → <100ms (100-1000x improvement)
- **Regulation**: ±1% → ±0.1% (10x improvement)
- **Reliability**: Mechanical wear → Solid-state (significant improvement)
- **Integration**: Limited EPICS → Full automation (complete transformation)

This approach aligns with the overall LLRF upgrade philosophy of leveraging proven commercial solutions where possible while ensuring seamless integration with the modernized control system.

---

## 8. References

1. SPEAR3 LLRF Team, "SPEAR3 LLRF Upgrade System Physical Design Report," SPEAR3-LLRF-PDR-001 Rev 1, March 2026
2. SPEAR3 LLRF Team, "Comprehensive SPEAR3 Klystron Filament Heater System Technical Documentation," llrf/documentation/filamentHeater/FILAMENT_HEATER_TECHNICAL_NOTES.md, March 2026
3. P. Corredoura, "PEP2 RF KLY FILAMENT SCHEMATIC," SD-349-311-20 Rev E2, Stanford Linear Accelerator Center
4. SPEAR3 LLRF Team, "Software Design Document," Designs/10_SOFTWARE_DESIGN_DOCUMENT.md, March 2026
5. SPEAR3 LLRF Team, "Interface Chassis Design," Designs/11_INTERFACE_CHASSIS_DESIGN.md, March 2026

---

**Document History**:
- **Version 1.0**: Initial SCR-based design concept
- **Version 2.0**: Updated to commercial programmable AC supply approach per PDR specifications
