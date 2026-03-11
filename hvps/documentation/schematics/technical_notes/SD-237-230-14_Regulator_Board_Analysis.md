# SD-237-230-14 Voltage/Current Regulator Board Technical Analysis

**Document**: SD-237-230-14-C1  
**Title**: PEP II RF System Enerpro V/A Regulator  
**Revision**: C1 (Added notes for NLCTA, 5/21/03)  
**Engineers**: M. Nguyen (9-17-97), T. Phan (9-17-97)  
**Checker**: J. Olszewski (10-5-99, 9-20-02)  

## 1. Overview

The SD-237-230-14 is a precision voltage and current regulator board designed for high-voltage power supply control in the PEP II RF system. The board provides comprehensive regulation, monitoring, and protection functions for SCR-controlled power supplies.

## 2. Power Supply Architecture

### 2.1 Supply Voltages
- **+15V**: Primary positive supply rail
- **-15V**: Primary negative supply rail  
- **+30V**: High-voltage rail for output stages
- **GND/COM**: System ground reference

### 2.2 Power Distribution
- Multiple decoupling capacitors (0.1µF) throughout the circuit
- Voltage regulation using precision references (1N4728, 1N4747, 1N4742)
- Power-on indication with LED (D20, 1N4728, 3.3V green)

## 3. Operational Amplifier Configuration

### 3.1 Primary Op-Amps
- **MC34074**: Quad operational amplifier (multiple instances: U10A, U10B, U10C, U10D)
- **OP77**: Precision operational amplifier for critical signal paths
- **INA117**: Instrumentation amplifier for differential measurements
- **INA114**: Instrumentation amplifier (alternate configuration)

### 3.2 Signal Processing Stages
1. **Voltage Limit Amplifier**: Precision voltage reference and limiting
2. **Voltage Difference Amplifier**: Differential voltage measurement
3. **Current Limit Amplifier**: Overcurrent protection and limiting
4. **Current Difference Amplifier**: Differential current sensing

## 4. Control and Monitoring Circuits

### 4.1 Input Commands
- **Positive Voltage Limit Command**: Precision voltage reference input
- **Positive Current Limit Command**: Current limiting setpoint
- **SCR Gate Inhibit Command**: Emergency shutdown control
- **Manual Trip**: Manual override protection

### 4.2 Sensing and Feedback
- **Positive Voltage Sense Monitor**: Real-time voltage feedback
- **Positive Current Sense Monitor**: Real-time current feedback
- **Isolated Current Preamp**: Galvanically isolated current measurement
- **Under-voltage Lockout**: Protection against low supply conditions

### 4.3 Protection Systems
- **Over-voltage Trip**: Automatic shutdown on overvoltage conditions
- **Over-current Trip**: Automatic shutdown on overcurrent conditions
- **Manual Trip**: Operator-initiated emergency stop
- **Voltage/Current/Manual Trip and Soft-start**: Comprehensive protection logic

## 5. Output Control

### 5.1 SCR Control
- **SCR Phase-Control Output**: Precision phase angle control for SCR firing
- **SCR Gate & Inhibit**: Direct gate control and inhibit functions
- **SCR Gate Inhibit Command**: Emergency gate blocking

### 5.2 Output Specifications
- **Output Voltage Range**: Controlled by precision references and feedback
- **Phase Control**: Variable phase angle for SCR firing control
- **Inhibit Response**: Fast response inhibit for emergency conditions

## 6. Component Specifications

### 6.1 Critical Components
- **Voltage References**: 1N4728 (3.3V), 1N4747 (20V), 1N4742 (12V), 1N4740 (10V)
- **Precision Resistors**: Multiple 10.00K, 49.90K, and other precision values
- **Isolation**: 4N32 optocouplers for galvanic isolation (6 instances)
- **Capacitors**: Mix of ceramic (0.1µF, 50V) and tantalum (various values)

### 6.2 Adjustable Components
- **VR1, VR2**: Precision potentiometers for calibration
- **Multiple Jumpers**: JP1-JP12 for configuration selection
- **Test Points**: TP3, TP4, TP6, TP8, TP9, TP10 for diagnostics

## 7. Configuration Options

### 7.1 PEP II Configuration (2MW PEP II P/S)
- R20: Not used (gain of 1)
- Specific jumper settings for PIN2/PIN3 connections
- Standard component values for 2MW operation

### 7.2 NLCTA Configuration (NLCTA P/S)
- R4: Not used
- C11: 5µF, 50V
- R20: 5.6K (gain of 10)
- Modified jumper connections for NLCTA operation

## 8. Interface Connections

### 8.1 Input Interfaces
- Voltage and current command inputs
- Feedback sensing inputs
- Protection system inputs
- Manual control inputs

### 8.2 Output Interfaces
- SCR gate control outputs
- Status and alarm outputs
- Monitoring signal outputs
- Inhibit control outputs

## 9. Design Notes and Specifications

### 9.1 Operating Conditions
- Supply voltages: ±15V, +30V
- Operating temperature: Standard industrial range
- Protection: Multiple redundant protection circuits

### 9.2 Performance Characteristics
- High precision voltage and current regulation
- Fast response protection systems
- Isolated feedback for safety
- Configurable for different power levels

## 10. Maintenance and Troubleshooting

### 10.1 Test Points
- **TP3**: +15V supply monitoring
- **TP4**: Negative voltage monitoring  
- **TP6**: -15V supply monitoring
- **TP8**: Manual trip monitoring
- **TP9**: Power-on status
- **TP10**: Ground reference

### 10.2 Critical Adjustments
- Voltage limit calibration via precision potentiometers
- Current limit calibration via feedback networks
- Phase control calibration for SCR timing

## 11. Safety and Protection Features

### 11.1 Multiple Protection Layers
1. **Hardware overvoltage protection**
2. **Hardware overcurrent protection** 
3. **Manual trip capability**
4. **Automatic soft-start sequencing**
5. **Under-voltage lockout protection**

### 11.2 Isolation and Safety
- Optocoupler isolation for critical signals
- Galvanic isolation between control and power circuits
- Multiple ground references for safety

## 12. Component Obsolescence Notes

### 12.1 Potentially Obsolete Components
- **MC34074**: Standard quad op-amp, readily available
- **4N32**: Standard optocoupler, multiple sources available
- **1N4728 series**: Standard Zener diodes, widely available
- **OP77**: Precision op-amp, may require modern equivalent

### 12.2 Recommended Modern Equivalents
- Consider modern precision op-amps for new designs
- Evaluate modern optocouplers for improved performance
- Update passive components to modern standards where applicable

---

**Document Status**: Technical analysis based on schematic SD-237-230-14-C1  
**Analysis Date**: March 2026  
**Confidence Level**: High (based on OCR extraction and component identification)

