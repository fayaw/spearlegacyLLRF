# SD-7307900101 HVPS System Schematic Technical Analysis

**Document**: SD-7307900101  
**Title**: HVPS System Overview Schematic  
**Revision**: C1 (Revised per engineering changes)  
**Engineers**: WSG  
**Sheet**: 1 of 1  

## 1. System Overview

The SD-7307900101 schematic provides the top-level system architecture for the High Voltage Power Supply (HVPS) system. This schematic shows the complete power conversion chain from AC input to high-voltage DC output for klystron operation.

## 2. Power Conversion Architecture

### 2.1 Input Power System
- **Primary Input**: 12.5KV 3-phase AC input
- **Phase Shifting Transformer**: T1 - Provides phase shift for 12-pulse operation
- **Disconnect & Breaker**: Safety isolation and protection

### 2.2 Rectification System
- **Main Transformer**: T2 - High-voltage isolation transformer
- **Rectifier Configuration**: 30KV 3A average rating rectifiers
- **Thyristor Controlled Rectifier**: 40KV 80A rating
- **12-pulse Operation**: Dual 6-pulse rectifier sets for harmonic reduction

### 2.3 Output Filtering and Regulation
- **Filter Capacitors**: 8µFD 30KV rating for output filtering
- **Filter Resistors**: 500 ohms 1KW for damping and protection
- **Filter Inductors**: L-C filtering for ripple reduction

## 3. High Voltage Output System

### 3.1 Output Specifications
- **Output Voltage**: -77KV DC (negative polarity)
- **Load Current**: 27 amps to klystron
- **Load**: Klystron tube (50KV rating shown)

### 3.2 Output Protection
- **Crowbar System**: 60KV 80A crowbar thyristor for fault protection
- **Termination Resistors**: High-voltage termination for cable matching
- **Ground Reference**: System ground connection

## 4. Control and Protection Systems

### 4.1 Thyristor Control
- **SCR Control**: Precision phase control for voltage regulation
- **12-pulse Configuration**: Two 6-pulse sets with 30° phase shift
- **Gate Control**: Synchronized firing for all thyristors

### 4.2 Protection Systems
- **Crowbar Protection**: Fast-acting crowbar for fault clearing
- **Overcurrent Protection**: Current limiting and trip functions
- **Overvoltage Protection**: Voltage monitoring and limiting

## 5. System Ratings and Specifications

### 5.1 Power Ratings
- **Input Power**: 12.5KV 3-phase AC
- **Output Power**: Approximately 2MW (77KV × 27A)
- **Transformer Rating**: High-voltage isolation transformer
- **Rectifier Rating**: 30KV 3A average per device

### 5.2 Protection Ratings
- **Crowbar Rating**: 60KV 80A thyristor
- **Filter Components**: 30KV capacitors, 1KW resistors
- **System Isolation**: High-voltage isolation throughout

## 6. System Topology Analysis

### 6.1 12-Pulse Rectifier Benefits
1. **Harmonic Reduction**: Eliminates 5th and 7th harmonics
2. **Ripple Reduction**: 720Hz ripple frequency (doubled)
3. **Improved Power Quality**: Reduced input current distortion
4. **Better Regulation**: Enhanced voltage stability

### 6.2 Phase Shifting Transformer
- **Purpose**: Provides 30° phase shift between rectifier sets
- **Configuration**: Dual secondary windings
- **Isolation**: High-voltage isolation from primary system

## 7. Load Interface

### 7.1 Klystron Connection
- **Operating Voltage**: 50KV (klystron rating)
- **Operating Current**: 27 amps
- **Polarity**: Negative high voltage supply
- **Grounding**: Cathode grounded configuration

### 7.2 Cable and Termination
- **High-Voltage Cables**: Specialized HV cable systems
- **Termination**: Proper impedance matching
- **Insulation**: High-voltage insulation requirements

## 8. Safety and Isolation

### 8.1 High Voltage Safety
- **Isolation Levels**: Multiple isolation barriers
- **Grounding**: Comprehensive grounding system
- **Access Control**: Physical barriers and interlocks

### 8.2 Protection Coordination
- **Primary Protection**: Input breaker and disconnect
- **Secondary Protection**: Crowbar and current limiting
- **Tertiary Protection**: Monitoring and alarm systems

## 9. System Integration Points

### 9.1 Control Interfaces
- **Gate Control Signals**: From Enerpro firing boards
- **Protection Signals**: To/from PLC control system
- **Monitoring Signals**: Voltage and current feedback

### 9.2 Auxiliary Systems
- **Cooling Systems**: For transformers and rectifiers
- **Monitoring Systems**: Temperature and status monitoring
- **Communication**: Interface to control room systems

## 10. Design Considerations

### 10.1 Thermal Management
- **Component Ratings**: Adequate thermal derating
- **Cooling Requirements**: Forced air or liquid cooling
- **Temperature Monitoring**: Critical component monitoring

### 10.2 Electromagnetic Compatibility
- **Shielding**: High-voltage shielding requirements
- **Filtering**: EMI/RFI filtering
- **Grounding**: Comprehensive EMC grounding

## 11. Maintenance and Access

### 11.1 Service Points
- **Test Points**: High-voltage measurement points
- **Access Panels**: Safe access for maintenance
- **Isolation Points**: Multiple isolation capabilities

### 11.2 Diagnostic Capabilities
- **Voltage Monitoring**: Real-time voltage measurement
- **Current Monitoring**: Load current measurement
- **Status Indication**: System status and alarms

## 12. System Performance

### 12.1 Regulation Characteristics
- **Voltage Regulation**: Tight voltage control via SCR phase control
- **Load Regulation**: Stable output under varying load conditions
- **Transient Response**: Fast response to load changes

### 12.2 Efficiency Considerations
- **12-pulse Operation**: Improved efficiency vs 6-pulse
- **Transformer Efficiency**: High-efficiency transformer design
- **Filter Losses**: Minimized filter component losses

## 13. Upgrade and Modernization Notes

### 13.1 Component Obsolescence
- **Thyristor Technology**: Modern thyristors available
- **Control Systems**: Digital control system upgrades possible
- **Protection Systems**: Modern protection relay upgrades

### 13.2 Performance Improvements
- **Digital Control**: Enhanced precision and features
- **Advanced Protection**: Faster and more selective protection
- **Remote Monitoring**: Enhanced diagnostic capabilities

---

**Document Status**: Technical analysis based on schematic SD-7307900101  
**Analysis Date**: March 2026  
**Confidence Level**: High (based on OCR extraction and system topology analysis)  
**Key Features**: 12-pulse rectifier, 77KV output, 2MW power level, comprehensive protection

