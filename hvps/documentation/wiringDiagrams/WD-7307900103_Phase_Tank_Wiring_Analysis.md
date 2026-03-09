# WD-7307900103 Phase Tank Trigger Wiring Diagram Technical Analysis

**Document**: WD-7307900103  
**Title**: Phase Tank Trigger Wiring Diagram  
**Revisions**: C1, C2, C3 (Revised for correctness)  
**Engineers**: WSG  
**Checker**: JO, RC  
**Dates**: 08/3, 09/23, 10/23  

## 1. Overview

The WD-7307900103 wiring diagram details the internal wiring of the phase tank, including thyristor stack connections, trigger wiring, monitoring systems, and protection interfaces. This diagram is critical for understanding the physical implementation of the HVPS control and protection systems.

## 2. Thyristor Stack Wiring

### 2.1 Stack Configuration
- **Multiple Thyristor Stacks**: Arranged in series for high voltage operation
- **Stack Numbering**: Sequential numbering system for identification
- **Position Identification**: Physical location mapping within phase tank

### 2.2 Trigger Wire Color Coding
Based on OCR analysis, the following color codes are identified:
- **RED/BLK**: Trigger signal wiring
- **BLU/BLK**: Secondary trigger connections  
- **GRN/BLK**: Ground reference connections
- **WHT/BLK**: Common connections
- **ORG/BLK**: Control signal wiring

### 2.3 Gate Drive Connections
- **SCR Gate Connections**: Individual gate drive for each thyristor
- **Cathode Connections**: Common cathode connections per stack
- **Isolation**: Proper isolation between stacks

## 3. Control System Interfaces

### 3.1 PLC Interface Connections
- **PPS (Personnel Protection System)**: Safety interlock connections
- **PPS-1**: Primary protection channel
- **PPS-2**: Secondary protection channel  
- **PPS COM**: Common reference for protection systems

### 3.2 Contactor Control
- **Contactor Ready**: Status feedback signal
- **Contactor Closed**: Position confirmation signal
- **Contactor Enable**: Control command signal
- **Disconnect Control**: High-voltage disconnect operation

## 4. Monitoring and Sensing Systems

### 4.1 Temperature Monitoring
- **Thermocouple Connections**: BLK 20-1305 thermocouple wiring
- **Temperature Sensors**: Multiple temperature monitoring points
- **Oil Temperature**: Top oil temperature monitoring
- **Thermal Protection**: Overtemperature trip systems

### 4.2 Oil Level Monitoring
- **Oil Level Sensors**: Multiple level detection points
- **Level Switches**: High/low level alarm contacts
- **Oil System Protection**: Low oil level protection

### 4.3 Arc Detection
- **Arc Monitors**: Multiple arc detection systems
- **XFMR ARC**: Transformer arc detection
- **Arc Protection**: Fast arc fault clearing

## 5. Protection System Wiring

### 5.1 Crowbar System
- **Crowbar SCR**: Emergency crowbar thyristor connections
- **Crowbar Drivers**: Gate drive for crowbar operation
- **Crowbar Trigger**: Multiple trigger sources for crowbar activation

### 5.2 Overcurrent Protection
- **Current Transformers**: Current sensing for protection
- **Overcurrent Relays**: Protection relay connections
- **Trip Circuits**: Protection system trip logic

### 5.3 Personnel Protection System (PPS)
- **PPS Interfaces**: Dual-channel safety system
- **Safety Interlocks**: Multiple safety interlock points
- **Emergency Stops**: Emergency shutdown capabilities

## 6. Cable and Connector Specifications

### 6.1 Cable Types
- **BELDEN 88761**: Shielded twisted pair for control signals
- **BELDEN 89719**: 18 AWG Teflon insulated for high-temperature applications
- **BELDEN 83715**: 15C multi-conductor for complex signal routing
- **COAX RG-58**: Coaxial cable for RF/high-frequency signals

### 6.2 Connector Systems
- **Terminal Blocks**: Numbered terminal connections
- **Plug/Socket Connections**: Removable connections for maintenance
- **Barrier Strips**: Organized connection points
- **Junction Boxes**: Protected connection enclosures

## 7. Signal Routing and Distribution

### 7.1 Control Signal Distribution
- **Gate Signals**: Distribution to individual thyristor stacks
- **Status Signals**: Feedback to control systems
- **Command Signals**: Control commands from PLC/control system

### 7.2 Power Distribution
- **Auxiliary Power**: 24VDC/120VAC auxiliary power distribution
- **Control Power**: Power for control circuits and relays
- **Protection Power**: Power for protection systems

## 8. Grounding and Shielding

### 8.1 Grounding System
- **Equipment Grounding**: Comprehensive equipment grounding
- **Signal Grounding**: Proper signal reference grounding
- **Safety Grounding**: Personnel safety grounding
- **Shield Grounding**: Cable shield grounding points

### 8.2 Electromagnetic Compatibility
- **Shielded Cables**: Extensive use of shielded cables
- **Twisted Pairs**: Twisted pair cables for noise immunity
- **Separation**: Proper separation of power and signal cables

## 9. Maintenance and Testing Points

### 9.1 Test Points
- **Signal Test Points**: Access points for signal testing
- **Voltage Test Points**: Safe voltage measurement points
- **Current Test Points**: Current measurement access

### 9.2 Maintenance Access
- **Removable Connections**: Connections designed for maintenance
- **Test Jacks**: Dedicated test connection points
- **Isolation Points**: Points for safe isolation during maintenance

## 10. Safety Features

### 10.1 Physical Safety
- **Insulation Coordination**: Proper insulation levels throughout
- **Clearances**: Adequate clearances for safety
- **Barriers**: Physical barriers for personnel protection

### 10.2 Electrical Safety
- **Ground Fault Protection**: Ground fault detection and protection
- **Arc Flash Protection**: Arc flash mitigation measures
- **Lockout/Tagout**: Provisions for safe maintenance procedures

## 11. Interface Documentation

### 11.1 External Interfaces
- **Control Room Interface**: Connections to control room systems
- **Protection System Interface**: Connections to protection relays
- **Monitoring System Interface**: Connections to monitoring systems

### 11.2 Internal Interfaces
- **Stack-to-Stack Connections**: Inter-stack wiring
- **Control-to-Power Interfaces**: Control system to power system connections
- **Monitoring Interfaces**: Sensor to monitoring system connections

## 12. Wire and Cable Schedule

### 12.1 Wire Identification
- **Color Coding**: Comprehensive color coding system
- **Wire Numbers**: Numerical identification system
- **Cable Marking**: Cable identification and routing

### 12.2 Connection Lists
- **Terminal Lists**: Complete terminal connection documentation
- **Cable Lists**: Cable routing and connection documentation
- **Connector Pinouts**: Detailed connector pin assignments

## 13. Troubleshooting Guide

### 13.1 Common Issues
- **Connection Problems**: Loose or corroded connections
- **Insulation Issues**: Insulation breakdown or contamination
- **Grounding Problems**: Poor grounding connections

### 13.2 Diagnostic Procedures
- **Continuity Testing**: Wire and connection continuity checks
- **Insulation Testing**: Insulation resistance measurements
- **Signal Tracing**: Signal path verification procedures

## 14. Upgrade and Modification Notes

### 14.1 Cable Upgrades
- **Modern Cable Types**: Upgraded cable specifications
- **Improved Insulation**: Enhanced insulation materials
- **Better Shielding**: Improved electromagnetic shielding

### 14.2 Connection Improvements
- **Modern Connectors**: Upgraded connector systems
- **Improved Terminals**: Enhanced terminal block systems
- **Better Organization**: Improved cable management

---

**Document Status**: Technical analysis based on wiring diagram WD-7307900103  
**Analysis Date**: March 2026  
**Confidence Level**: High (based on OCR extraction and wiring analysis)  
**Key Features**: Comprehensive thyristor wiring, protection system interfaces, monitoring systems

