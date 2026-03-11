# 01 — PEP II Klystron Power Supply Architecture

> **Source**: `slac-pub-7591.pdf` - "A Unique Power Supply for the PEP II Klystron at SLAC" (R. Cassel & M.N. Nguyen, July 1997)

## Executive Summary

This document analyzes the foundational architecture of the PEP II klystron power supply system as documented in SLAC-PUB-7591. This 1997 publication describes the design of eight 2.5 MVA DC power supplies (83kV at 23A) for the 1.2 MW RF klystrons used in the PEP-II storage rings at SLAC.

## System Specifications

### **Primary Requirements**
- **Power Rating**: 2.5 MVA DC power supply
- **Output Voltage**: 83 kV at 23 amps DC continuous (SLAC-PUB-7591)
  - *Note: PowerPoint presentation shows 27A DC continuous, indicating possible system uprating*
- **Voltage Control Range**: 0-90 kV
- **Regulation**: < 0.1% above 60 kV (SLAC-PUB-7591)
  - *Note: PowerPoint shows < ±0.5% @ >65kV, indicating specification variance*
- **Voltage Ripple**: < 1% peak-to-peak (< 0.2% RMS) above 60 kV
- **Arc Protection**: < 5 joules energy delivery during klystron arc (< 20 joules without crowbar)

### **Design Constraints**
1. **Low Cost**: Target < $140 per kVA
2. **Compact Size**: Must fit existing PEP transformer yard pads
3. **Klystron Protection**: Critical protection against klystron gun arcs

## Architecture Overview

### **Primary Control System: 12-Pulse Thyristor Star Point Controller**

The power supply uses a unique **12-pulse, 12.5 kV primary thyristor "star point controller"** configuration:

```
                    ┌─────────────────────────────────────────┐
                    │        PRIMARY CONTROL SYSTEM          │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   12-Pulse Thyristor            │    │
                    │  │   Star Point Controller         │    │
                    │  │                                 │    │
                    │  │   • 12.5 kV Primary            │    │
                    │  │   • 12 SCR Stacks              │    │
                    │  │   • Snubber Networks            │    │
                    │  └─────────────────────────────────┘    │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Primary Filter Inductor       │    │
                    │  │                                 │    │
                    │  │   • Rapid Voltage Control       │    │
                    │  │   • Current Rate Limiting       │    │
                    │  │   • Fast Turn-off Capability    │    │
                    │  └─────────────────────────────────┘    │
                    └─────────────────────────────────────────┘
```

**Key Features:**
- **Rapid Voltage Control**: Primary-side control provides fast response
- **Good Voltage Regulation**: Maintains < 0.1% regulation above 60 kV
- **Fast Turn-off**: Critical for klystron fault protection
- **Current Limiting**: Primary filter inductor limits fault current rise rate

### **Secondary Rectifier System: Unique Dual-Bridge Configuration**

The secondary system employs a novel rectifier and filter configuration:

```
                    ┌─────────────────────────────────────────┐
                    │       SECONDARY RECTIFIER SYSTEM       │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Rectifier Transformers        │    │
                    │  │                                 │    │
                    │  │   • Two Open Wye Primary        │    │
                    │  │   • Dual Wye Secondaries        │    │
                    │  │   • Voltage Step-up             │    │
                    │  └─────────────────────────────────┘    │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Main Power Rectifier          │    │
                    │  │                                 │    │
                    │  │   • Full Wave Bridge            │    │
                    │  │   • Full Current Rating         │    │
                    │  │   • Connected to Full Taps      │    │
                    │  └─────────────────────────────────┘    │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Filter Rectifier (5% Ext.)    │    │
                    │  │                                 │    │
                    │  │   • Low Current Bridge (~1A)    │    │
                    │  │   • 5% Voltage Extension Taps   │    │
                    │  │   • Filter Capacitor Loading    │    │
                    │  │   • High Ohmage Resistor Coupling │  │
                    │  └─────────────────────────────────┘    │
                    └─────────────────────────────────────────┘
```

**Unique Design Elements:**
- **Dual Rectifier Architecture**: Main power rectifier + separate filter rectifier
- **5% Voltage Extension**: Filter rectifier uses 5% higher voltage taps
- **Limited Filter Current**: Filter rectifier limited to ~1A maximum
- **High Ohmage Coupling**: Filter capacitor coupled through high resistance
- **Energy Minimization**: Configuration minimizes energy available during faults

## Arc Protection System

### **SCR Crowbar Protection**

The system includes a sophisticated thyristor crowbar for klystron protection:

```
                    ┌─────────────────────────────────────────┐
                    │         ARC PROTECTION SYSTEM           │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   SCR Crowbar                   │    │
                    │  │                                 │    │
                    │  │   • 4 SCR Stacks               │    │
                    │  │   • Snubber Networks            │    │
                    │  │   • Output Cable Impedance      │    │
                    │  │     Matching                    │    │
                    │  │   • ~10 μs Response Time        │    │
                    │  └─────────────────────────────────┘    │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Voltage Monitoring            │    │
                    │  │                                 │    │
                    │  │   • Two Voltage Dividers        │    │
                    │  │   • High Voltage Output         │    │
                    │  │     Monitoring                  │    │
                    │  └─────────────────────────────────┘    │
                    └─────────────────────────────────────────┘
```

**Protection Performance:**
- **Energy Limitation**: < 5 joules delivered to klystron arc with crowbar
- **Backup Protection**: < 20 joules without crowbar operation
- **Response Time**: ~10 microseconds crowbar delay
- **Current Limiting**: Primary inductor limits fault current rise
- **Complete Interruption**: 4-8 milliseconds primary current interruption
- **Fault Current**: 50 amps for 4 milliseconds during crowbar failure
- **I²t Protection**: ~15 amp²seconds protection value

### **Fault Response Characteristics**

During a klystron arc event:

1. **Primary Current Rise**: Limited by primary filter inductor
2. **Crowbar Activation**: SCR crowbar fires within ~10 μs
3. **Primary Turn-off**: SCR controller turns off primary thyristors
4. **Current Interruption**: Complete primary current interruption for 4-8 ms
5. **Energy Delivery**: Total arc energy < 5 joules (with crowbar)

**Key Protection Features:**
- Primary current only doubles during fault (vs. unlimited rise)
- Fast primary turn-off capability
- Dual-level protection (crowbar + primary control)
- Impedance-matched crowbar design

## Mechanical Design Considerations

### **Compact Installation**

To meet size constraints, critical components are oil-immersed:

```
                    ┌─────────────────────────────────────────┐
                    │        TRANSFORMER OIL TANK            │
                    │                                         │
                    │  ┌─────────────────┐  ┌─────────────┐   │
                    │  │ SCR Primary     │  │ SCR Crowbar │   │
                    │  │ Controller      │  │ Tank        │   │
                    │  │                 │  │             │   │
                    │  │ • 12 SCR Stacks │  │ • 4 SCR     │   │
                    │  │ • 12 Snubbers   │  │   Stacks    │   │
                    │  │ • Oil Isolated  │  │ • Snubbers  │   │
                    │  └─────────────────┘  │ • Voltage   │   │
                    │                       │   Dividers  │   │
                    │  ┌─────────────────┐  └─────────────┘   │
                    │  │ Oil-to-Oil      │                    │
                    │  │ Feed-through    │                    │
                    │  │ • Prevents      │                    │
                    │  │   Cross-        │                    │
                    │  │   contamination │                    │
                    │  └─────────────────┘                    │
                    └─────────────────────────────────────────┘
```

**Design Benefits:**
- **Space Efficiency**: High voltage components in oil tank
- **Isolation**: Separate oil tanks prevent cross-contamination
- **Maintenance Access**: Oil-to-oil feed-throughs allow service
- **Existing Infrastructure**: Fits on existing transformer pads

### **Transformer Tank Contents**

The main transformer tank contains:
- **Two filter inductors**
- **Two power transformers** (open Wye primary, dual Wye secondaries)
- **One phase shifting transformer** (< 15% of full load MVA)
- **4 filter diode rectifier stacks**
- **4 filter capacitors**
- **8 filter resistor loads**
- **4 power diode rectifier stacks**

### **Crowbar Tank Components**

- **4 SCR stacks** with snubber networks
- **Impedance matching** to output cable
- **Two voltage dividers** for high voltage monitoring
- **200 μH inductors** in termination tank for cable discharge current reduction

### **Primary Control Tank Components**

- **12 SCR stacks** for primary control
- **12 snubber networks** to limit dV/dt and damp capacitance ringing

## Performance Characteristics

### **Voltage Regulation**

The system achieves excellent regulation through primary control:

| **Output Voltage** | **Regulation** | **Ripple (P-P)** | **Ripple (RMS)** |
|-------------------|----------------|------------------|------------------|
| 60-90 kV | < 0.1% | < 1% | < 0.2% |
| Below 60 kV | Degraded | Higher | Higher |

### **Load Characteristics**

- **Full Load**: 83 kV at 23 A (2.5 MVA)
- **Continuous Operation**: Designed for 100% duty cycle
- **Load Regulation**: Excellent due to primary control
- **Dynamic Response**: Fast due to primary-side regulation

### **Efficiency Considerations**

- **12-Pulse Operation**: Reduces harmonic content
- **Primary Control**: Minimizes secondary losses
- **Filter Design**: Optimized for efficiency vs. protection

## Cost Analysis (1997 Baseline)

### **Target Cost Achievement**
- **Achieved Cost**: < $140 per kVA
- **Total System Cost**: < $350,000 per 2.5 MVA supply
- **Cost Drivers**: Compact design, oil-immersed components

### **Cost Optimization Strategies**
1. **Standardized Components**: Use of standard SCR stacks
2. **Compact Design**: Reduced installation costs
3. **Simplified Control**: Primary-side regulation reduces complexity
4. **Existing Infrastructure**: Utilizes existing transformer pads

### **Manufacturing and Installation**

**Primary Manufacturer:**
- **NWL Transformer**: Power supply transformers, rectifiers, and transformer tank
- **SLAC**: SCR Primary controller and SCR crowbar (manufactured and tested)
- **Integration**: SLAC components installed by NWL into transformer tanks

## Design Innovation Summary

### **Unique Technical Contributions**

1. **Primary Thyristor Control**: 12-pulse star point controller for fast response
2. **Dual Rectifier Architecture**: Separate main and filter rectifiers
3. **Energy-Limited Protection**: Unique secondary configuration minimizes arc energy
4. **Compact Oil-Immersed Design**: High voltage components in transformer tank
5. **Impedance-Matched Crowbar**: SCR crowbar matched to cable impedance

### **Performance Achievements**

- **Regulation**: < 0.1% (exceeds typical power supply performance)
- **Arc Protection**: < 5 joules (critical for expensive klystron protection)
- **Size**: Fits existing infrastructure (major cost savings)
- **Cost**: < $140/kVA (competitive for high voltage supplies)

## Relationship to Current HVPS Systems

### **Architectural Influence**

This PEP II design established several principles used in current HVPS systems:

1. **Primary Control Philosophy**: Fast primary-side regulation
2. **Arc Protection Strategy**: Energy-limited fault response
3. **Compact Design Approach**: Oil-immersed high voltage components
4. **12-Pulse Configuration**: Harmonic reduction techniques

### **Evolution to Current Systems**

The principles documented in this 1997 publication form the foundation for:
- Current SPEAR3 HVPS implementations
- Enerpro firing board integration strategies
- Modern arc protection systems
- Compact power supply designs

## Technical Specifications Summary

| **Parameter** | **Specification** | **Notes** |
|---------------|------------------|-----------|
| **Power Rating** | 2.5 MVA | 83 kV × 23 A |
| **Voltage Range** | 0-90 kV | Continuous control |
| **Regulation** | < 0.1% | Above 60 kV |
| **Ripple (P-P)** | < 1% | Above 60 kV |
| **Ripple (RMS)** | < 0.2% | Above 60 kV |
| **Arc Energy** | < 5 J | With crowbar |
| **Arc Energy (Backup)** | < 20 J | Without crowbar |
| **Crowbar Delay** | ~10 μs | Response time |
| **Primary Voltage** | 12.5 kV | Thyristor rating |
| **Pulse Count** | 12 | Harmonic reduction |
| **Cost Target** | < $140/kVA | 1997 dollars |

---

**Document Status**: Complete technical analysis of SLAC-PUB-7591  
**Related Documents**: PowerPoint schematics, detailed circuit drawings, design notes  
**Application**: Foundation for understanding current HVPS architecture evolution
