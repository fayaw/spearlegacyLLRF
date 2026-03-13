# SPEAR3 HVPS System Specifications - Complete Documentation Review

> **Comprehensive analysis of all HVPS documentation for accurate simulation implementation**

## Executive Summary

Based on comprehensive review of all HVPS documentation, the SPEAR3 High Voltage Power Supply is a sophisticated **12-pulse thyristor phase-controlled rectifier** system delivering **-77 kV DC @ 22 A (1.7 MW)** to power SPEAR3 storage ring klystrons. The system is based on proven PEP-II architecture with advanced multi-layer arc protection.

## System Architecture Overview

### **Power Flow Topology**
```
12.47 kV 3φ AC → Phase-Shift Transformer (T0) → Rectifier Transformers (T1,T2) 
→ 12-Pulse SCR Bridges → LC Filter → Secondary Rectifiers → -77 kV DC Output
```

### **Key System Characteristics**
- **Power Rating**: 1.7 MW nominal, 2.5 MW maximum capability
- **Output**: -77 kV DC @ 22 A (negative polarity for klystron cathode)
- **Configuration**: 2-unit system (SPEAR1 active, SPEAR2 warm spare)
- **Topology**: 12-pulse thyristor phase-controlled rectifier with star point controller
- **Protection**: 4-layer arc protection system with single-fault tolerance
- **Location**: Building 514 (power equipment), Building 118 (control systems)

## Detailed Component Specifications

### **1. Input Power System**
- **Source**: SLAC Substation 507, Circuit Breaker 160
- **Voltage**: 12.47 kV RMS, 3-phase, 60 Hz
- **Power**: 2.5 MVA maximum capability
- **Protection**: 3×50A fuses, vacuum contactor, disconnect switch

### **2. Phase-Shifting Transformer (T0)**
- **Rating**: 3.5 MVA, oil-immersed
- **Primary**: 12.47 kV delta connection
- **Secondary**: Dual wye configuration with ±15° phase shift
- **Purpose**: Creates 12-pulse rectification (reduces harmonics)
- **Cooling**: Oil circulation with temperature monitoring

### **3. Rectifier Transformers (T1, T2)**
- **Rating**: 1.5 MVA each, oil-immersed
- **Primary**: Open wye connection (floating neutral for star point control)
- **Secondary**: Dual wye, center-tapped configuration
- **Voltage**: 12.5 kV primary, variable secondary (0-30 kV)
- **Phase Shift**: T1 at +15°, T2 at -15° (relative to input)

### **4. Thyristor Control System**
- **Total SCR Stacks**: 12 stacks for phase control
- **SCR Type**: Powerex T8K7 series (8 kV, 700 A rating)
- **Stack Configuration**: 14 SCRs per stack in series (168 SCRs total)
- **Control Method**: Phase angle control (0° to 180°)
- **Firing System**: Enerpro FCOG1200 12-pulse firing board

### **5. Filter System (Critical for T1 AC Current Analysis)**
- **Primary Inductors (L1, L2)**: 0.3H each, 85A rated, 1,084J stored energy
- **Filter Capacitor**: 8 μF total capacitance
- **Isolation Resistors**: 500Ω (PEP-II innovation for arc protection)
- **Cable Termination Inductors (L3, L4)**: 200μH each
- **Energy Storage**: ~24 kJ at full voltage

### **6. Secondary Rectification**
- **Configuration**: 4 diode bridges in series (24 diodes total)
- **Main Bridge**: 30 kV, 30 A rating (primary power conversion)
- **Filter Bridge**: 30 kV, 3 A rating (5% extension for filtering)
- **Total Capability**: 120 kV, 22 A continuous
- **Cooling**: Forced air with temperature monitoring

## Control System Specifications

### **Control Performance Requirements**
- **Voltage Range**: 0 to -90 kV DC output
- **Control Resolution**: 16-bit DAC (0.1% resolution)
- **Response Time**: <10 ms for voltage changes
- **Regulation**: ±0.5% at voltages >65 kV
- **Ripple**: <1% peak-to-peak, <0.2% RMS ← **CRITICAL SPECIFICATION**

### **Control System Hierarchy**
```
EPICS IOC ↔ VXI Crate & DCM ↔ PLC SLC-5/03 ↔ Regulator Card PC-237-230 ↔ Enerpro FCOG1200
```

### **Key Control Components**
- **EPICS Interface**: VxWorks-based IOC with MEDM operator screens
- **VXI Crate**: Embedded controller with DCM module for PLC interface
- **PLC**: Allen-Bradley SLC-5/03 with SSRLV6-4-05-10 program
- **Regulator Card**: PC-237-230-14-C0 for voltage/current feedback conditioning
- **Firing Board**: Enerpro FCOG1200 for 12-pulse SCR gate pulse generation

## Protection System Architecture

### **Multi-Layer Arc Protection (4 Layers)**
1. **Layer 1**: Primary crowbar (4 SCR stacks, 100 kV, 80 A each)
2. **Layer 2**: Secondary protection circuits
3. **Layer 3**: Control system interlocks and fault detection
4. **Layer 4**: Cable termination inductors (200μH) for discharge current reduction

### **Protection Characteristics**
- **Single-fault tolerance**: System survives primary crowbar failure
- **Response time**: ~1μs fiber-optic trigger delay
- **Energy handling**: Designed for full capacitor bank discharge (24 kJ)

## Critical Findings for Simulation

### **12-Pulse Rectification Characteristics**
- **Fundamental ripple frequency**: 720 Hz (12 × 60 Hz)
- **Harmonic cancellation**: ±15° phase shift eliminates 5th and 7th harmonics
- **Input ripple**: ~0.5% @ 720 Hz (before filtering)
- **Expected output ripple**: <1% P-P, <0.2% RMS (after LC filtering)

### **T1 AC Current Waveform Analysis**
Based on documentation review, the T1 AC current should exhibit:
- **12-pulse characteristics**: 720 Hz ripple frequency
- **Near-sinusoidal shape**: Due to excellent filtering (LC + cable inductors)
- **Balanced 3-phase operation**: Confirmed by waveform documentation
- **Low harmonic content**: Due to 12-pulse harmonic cancellation

### **Filter Design Validation**
- **L1, L2**: 0.3H each (confirmed from multiple sources)
- **Capacitor**: 8μF total (confirmed, not 345μF as calculated)
- **Resonant frequency**: ~103 Hz (well below 720 Hz ripple)
- **Theoretical attenuation**: ~48x at 720 Hz

## Simulation Implementation Requirements

### **Critical Parameters for Accurate Modeling**
1. **12-pulse rectifier**: Must model true harmonic cancellation, not dual 6-pulse
2. **Filter components**: L=0.3H, C=8μF, R=500Ω (exact values confirmed)
3. **Ripple specifications**: 720 Hz fundamental, <1% P-P output
4. **Voltage regulation**: -77 kV ±0.5% at >65 kV
5. **Control system**: Phase angle control 0°-180° with 16-bit resolution

### **System Integration Requirements**
- **Star point controller topology**: Floating neutral configuration
- **Protection system integration**: Multi-layer arc protection modeling
- **Control system dynamics**: <10 ms response time
- **Thermal management**: Temperature monitoring for all major components

## Documentation Sources Reviewed

### **Architecture Documentation**
- ✅ `00-spear3-hvps-legacy-system-design.md` - Complete system overview
- ✅ `01-pepii-power-supply-architecture.md` - Historical PEP-II reference
- ✅ `02-power-supply-schematics-analysis.md` - Waveform analysis
- ✅ `03-detailed-schematic-analysis.md` - 24-page schematic review
- ✅ `04-regulator-board-design.md` - Control system details
- ✅ `05-system-integration-notes.md` - Integration requirements

### **Controls Documentation**
- ✅ Enerpro FCOG1200 documentation and schematics
- ✅ Control system wiring and fiber optic connections
- ✅ Regulator board testing notes and specifications

### **Technical Procedures**
- ✅ Stack assembly procedures and specifications
- ✅ Safety procedures and hazard documentation
- ✅ Maintenance procedures and checklists
- ✅ Validated operational procedures

## Conclusion

The documentation review confirms that the SPEAR3 HVPS is a sophisticated **12-pulse thyristor phase-controlled rectifier** with advanced filtering and protection systems. The T1 AC current discrepancy identified by the user is directly related to the **12-pulse harmonic cancellation** that creates near-sinusoidal current waveforms, contrasting with the square-wave characteristics that would be seen in simpler rectifier topologies.

**Key simulation requirements**:
1. **True 12-pulse modeling** (not dual 6-pulse)
2. **Exact component values** (L=0.3H, C=8μF, R=500Ω)
3. **720 Hz ripple frequency** with proper harmonic cancellation
4. **Multi-layer protection system** integration
5. **Star point controller topology** with floating neutral

This comprehensive specification provides the foundation for accurate simulation implementation and validation.

