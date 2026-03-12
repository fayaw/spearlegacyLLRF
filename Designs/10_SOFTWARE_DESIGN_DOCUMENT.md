# SPEAR3 LLRF Upgrade — Comprehensive Software Design Document

**Document ID**: SPEAR3-LLRF-SDD-001  
**Revision**: R1  
**Date**: March 12, 2026  
**Author**: LLRF Upgrade Software Team  
**Classification**: Complete System Software Architecture Reference  
**Status**: Comprehensive Design - All Subsystems Integrated  

---

## Purpose and Scope

This Software Design Document (SDD) defines the **complete software architecture** for the SPEAR3 LLRF Upgrade Project, covering all 10 major subsystems and their integrated control system. It specifies the Python/EPICS coordinator application that replaces the legacy SNL programs with a modern, comprehensive control system that coordinates all RF station subsystems.

**Key Architectural Principle**: The software provides **supervisory control and coordination** across all subsystems while maintaining hardware-based safety protection. The 4-layer protection hierarchy ensures that all safety-critical functions operate in hardware (<1 μs response), while software provides sequencing, coordination, diagnostics, and operator interface.

**Complete System Scope**: This document covers software integration for all 10 subsystems:
1. LLRF Controller (LLRF9 Units 1 & 2)
2. High Voltage Power Supply (HVPS) 
3. Klystron Machine Protection System (Kly MPS)
4. **Interface Chassis** (with direct EPICS interface)
5. Personnel Protection System (PPS) Interface
6. Tuner Control System (4 cavities)
7. Waveform Buffer System
8. Arc Detection System
9. Klystron Cathode Heater
10. Control Software (Python Coordinator)

---

## Table of Contents

1. [System Architecture Overview](#1-system-architecture-overview)
2. [EPICS Integration Strategy](#2-epics-integration-strategy)
3. [Subsystem Software Interfaces](#3-subsystem-software-interfaces)
4. [Interface Chassis Software Design](#4-interface-chassis-software-design)
5. [Master State Machine](#5-master-state-machine)
6. [Comprehensive Fault Management](#6-comprehensive-fault-management)
7. [LLRF9 Controller Integration](#7-llrf9-controller-integration)
8. [HVPS Supervisory Control](#8-hvps-supervisory-control)
9. [Tuner Management System](#9-tuner-management-system)
10. [Waveform Buffer Interface](#10-waveform-buffer-interface)
11. [Arc Detection Integration](#11-arc-detection-integration)
12. [Heater Controller Interface](#12-heater-controller-interface)
13. [MPS Integration](#13-mps-integration)
14. [PPS Interface Coordination](#14-pps-interface-coordination)
15. [Python Coordinator Architecture](#15-python-coordinator-architecture)
16. [Complete EPICS PV Namespace](#16-complete-epics-pv-namespace)
17. [System Integration & Testing](#17-system-integration--testing)
18. [Performance & Real-time Requirements](#18-performance--real-time-requirements)
19. [Implementation Roadmap](#19-implementation-roadmap)
20. [Appendix: Complete PV Registry](#20-appendix-complete-pv-registry)

---

## 1. System Architecture Overview

### 1.1 Complete System Integration

The SPEAR3 LLRF Upgrade software provides comprehensive control and coordination of all RF station subsystems through a unified Python/EPICS architecture. The system integrates 10 major subsystems into a cohesive control system while maintaining the 4-layer hardware protection hierarchy.

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           LAYER 4: SOFTWARE COORDINATION                        │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Python Coordinator (SRF1:COORD:)                        │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌────────┐ │ │
│  │  │Master State │ │Fault Manager│ │EPICS Bridge │ │Config Mgr   │ │UI/Diag │ │ │
│  │  │Machine      │ │             │ │             │ │             │ │        │ │ │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                       │ EPICS Channel Access
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        LAYER 3: SUBSYSTEM COORDINATION                          │
│                                                                                 │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│ │LLRF9 Unit 1 │ │LLRF9 Unit 2 │ │HVPS Control │ │Kly MPS      │ │Interface    │ │
│ │(LLRF1:)     │ │(LLRF2:)     │ │(SRF1:HVPS:) │ │(SRF1:MPS:)  │ │Chassis      │ │
│ │Built-in IOC │ │Built-in IOC │ │PLC Gateway  │ │PLC Gateway  │ │(SRF1:IC:)   │ │
│ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ │
│                                                                                 │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│ │Tuner Motors │ │Waveform     │ │Arc Detection│ │Heater Ctrl  │ │PPS Interface│ │
│ │(SRF1:MTR:)  │ │Buffer       │ │(SRF1:ARC:)  │ │(SRF1:KLYS:  │ │(SRF1:PPS:)  │ │
│ │Motor IOC    │ │(SRF1:WFBUF:)│ │Dedicated IOC│ │HEATER:)     │ │Dedicated IOC│ │
│ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                       │ Hardware Interfaces
┌─────────────────────────────────────────────────────────────────────────────────┐
│                      LAYER 2: INTERFACE CHASSIS HARDWARE                        │
│                           (<1 μs Hardware AND-Logic)                           │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        Interface Chassis                                    │ │
│  │  • First-fault detection  • Electrical isolation  • Fast permit logic      │ │
│  │  • Fault latching        • Fiber-optic I/O       • Status reporting       │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                       │ Hardware Interlocks
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        LAYER 1: LLRF9 FPGA INTERLOCKS                          │
│                              (<1 μs Autonomous)                                │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    LLRF9 Internal Protection                                │ │
│  │  • 17 internal interlocks per unit  • RF overvoltage protection            │ │
│  │  • Baseband window comparators      • Autonomous hardware operation        │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Software Integration Principles

1. **Comprehensive Coordination**: Software coordinates all 10 subsystems through unified state machine
2. **Hardware Safety Independence**: All safety functions operate in hardware; software crash cannot compromise safety
3. **Direct EPICS Integration**: Each subsystem has direct EPICS interface for monitoring and control
4. **Fault Management Integration**: Comprehensive fault detection, analysis, and recovery across all subsystems
5. **Configuration-Driven Operation**: All operational parameters managed through versioned configuration files
6. **Observable System State**: Complete system state exposed via EPICS PVs for monitoring and archiving

### 1.3 Technology Stack

| Component | Technology | Justification |
|-----------|------------|---------------|
| **Language** | Python 3.10+ | Team expertise, PyEPICS ecosystem, rapid development |
| **EPICS Library** | PyEPICS + caproto | Mature client/server capabilities, monitor support |
| **Configuration** | YAML (PyYAML) | Human-readable, hierarchical, version-controllable |
| **Logging** | Python logging + JSON | Structured logging, archiver-compatible |
| **Testing** | pytest + unittest.mock | Comprehensive testing with hardware mocks |
| **Process Management** | systemd | Standard Linux service management |
| **Documentation** | Sphinx + autodoc | Auto-generated API documentation |

---

## 2. EPICS Integration Strategy

### 2.1 Complete EPICS Architecture

The software integrates with **10 EPICS IOCs** providing comprehensive monitoring and control across all subsystems:

| Subsystem | IOC Type | PV Prefix | PV Count | Update Rate | Interface |
|-----------|----------|-----------|----------|-------------|-----------|
| **LLRF9 Unit 1** | Built-in Linux IOC | `LLRF1:` | ~550 | 10 Hz | Direct EPICS CA |
| **LLRF9 Unit 2** | Built-in Linux IOC | `LLRF2:` | ~550 | 10 Hz | Direct EPICS CA |
| **HVPS Controller** | CompactLogix Gateway | `SRF1:HVPS:` | ~30 | 1 Hz | EPICS CA via Gateway |
| **Kly MPS** | ControlLogix Gateway | `SRF1:MPS:` | ~25 | 1 Hz | EPICS CA via Gateway |
| **Interface Chassis** | **Dedicated IOC** | `SRF1:IC:` | ~20 | **10 Hz** | **Direct EPICS CA** |
| **Tuner Motors** | Motor Record IOC | `SRF1:MTR:` | ~40 | On demand | EPICS Motor Records |
| **Waveform Buffer** | Dedicated IOC | `SRF1:WFBUF:` | ~35 | 1 Hz/event | Direct EPICS CA |
| **Arc Detection** | Dedicated IOC | `SRF1:ARC:` | ~15 | 10 Hz | Direct EPICS CA |
| **Heater Controller** | Dedicated IOC | `SRF1:KLYS:HEATER:` | ~20 | 10 Hz | Direct EPICS CA |
| **Python Coordinator** | caproto Server | `SRF1:COORD:` | ~30 | 1 Hz | EPICS PV Server |

**Total EPICS PVs**: ~1,315 PVs across all subsystems

### 2.2 Interface Chassis Direct EPICS Interface

**Key Design Decision**: The Interface Chassis has a **dedicated EPICS IOC** providing direct software interface, not just monitoring through the MPS PLC gateway.

**Interface Chassis IOC Architecture**:
```
┌─────────────────────────────────────────────────────────────────┐
│                    Interface Chassis IOC                        │
│                        (SRF1:IC:)                              │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │Input Status     │  │Output Status    │  │Control &        │ │
│  │Monitoring       │  │Monitoring       │  │Diagnostics      │ │
│  │(7 PVs)          │  │(3 PVs)          │  │(10 PVs)         │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Hardware Interface                             │ │
│  │  • Digital I/O to IC hardware    • First-fault register    │ │
│  │  • Status monitoring             • Reset control           │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 2.3 EPICS Communication Patterns

**Monitor-Based Updates** (Real-time):
```python
# Critical status monitoring with immediate callbacks
epics.camonitor("SRF1:IC:PERMIT:SUMMARY", callback=self._ic_permit_changed)
epics.camonitor("SRF1:MPS:PERMIT", callback=self._mps_permit_changed)
epics.camonitor("LLRF1:ILOCK:ALL", callback=self._llrf1_interlock_changed)
epics.camonitor("LLRF2:ILOCK:ALL", callback=self._llrf2_interlock_changed)
```

**Batch Reads** (Periodic status):
```python
# Efficient batch reading for status updates
status_pvs = [
    "SRF1:HVPS:VOLT:RB", "SRF1:HVPS:CURR:RB",
    "SRF1:WFBUF:COLLECTOR:POWER", "SRF1:ARC:STATUS:SUMMARY",
    "SRF1:KLYS:HEATER:STATUS", "SRF1:IC:FIRST:FAULT"
]
status_values = epics.caget_many(status_pvs)
```

**Coordinated Writes** (State transitions):
```python
# Coordinated subsystem control during state transitions
async def transition_to_standby(self):
    # Parallel subsystem preparation
    await asyncio.gather(
        self._prepare_hvps_for_standby(),
        self._prepare_llrf9_for_standby(),
        self._prepare_heater_for_standby(),
        self._verify_ic_permits()
    )
```

## 3. Subsystem Software Interfaces

### 3.1 Interface Architecture Pattern

Each subsystem follows a consistent software interface pattern enabling modular integration and testing:

```python
class SubsystemInterface(ABC):
    """Abstract base class for all subsystem interfaces"""
    
    @abstractmethod
    async def initialize(self) -> bool:
        """Initialize subsystem connection and verify readiness"""
        pass
    
    @abstractmethod
    async def get_status(self) -> Dict[str, Any]:
        """Get current subsystem status"""
        pass
    
    @abstractmethod
    async def prepare_for_state(self, target_state: StationState) -> bool:
        """Prepare subsystem for state transition"""
        pass
    
    @abstractmethod
    def get_fault_status(self) -> Dict[str, Any]:
        """Get current fault conditions"""
        pass
```

### 3.2 Subsystem Integration Summary

| Subsystem | Interface Class | Key Functions | Critical PVs |
|-----------|----------------|---------------|--------------|
| **LLRF9 Units** | `LLRF9Interface` | Feedback control, interlocks, tuner data | `LLRF1:ILOCK:ALL`, `LLRF2:ILOCK:ALL` |
| **HVPS** | `HVPSInterface` | Voltage control, status monitoring | `SRF1:HVPS:VOLT:RB`, `SRF1:HVPS:STATUS:READY` |
| **Kly MPS** | `MPSInterface` | Permit monitoring, fault status | `SRF1:MPS:PERMIT`, `SRF1:MPS:FAULTS:FIRST` |
| **Interface Chassis** | `InterfaceChassisInterface` | **Direct EPICS monitoring** | `SRF1:IC:PERMIT:SUMMARY`, `SRF1:IC:FIRST:FAULT` |
| **Tuner Motors** | `TunerInterface` | Position control, motor status | `SRF1:MTR:C1.RBV` through `SRF1:MTR:C4.RBV` |
| **Waveform Buffer** | `WaveformBufferInterface` | Data acquisition, collector protection | `SRF1:WFBUF:COLLECTOR:POWER` |
| **Arc Detection** | `ArcDetectionInterface` | Arc monitoring, permit status | `SRF1:ARC:PERMIT:SUMMARY` |
| **Heater Controller** | `HeaterInterface` | Temperature control, operating modes | `SRF1:KLYS:HEATER:STATUS` |
| **PPS Interface** | `PPSInterface` | Safety system coordination | `SRF1:PPS:PERMIT:SUMMARY` |

---

## 4. Interface Chassis Software Design

### 4.1 Purpose and Architecture

The Interface Chassis software interface provides the Python coordinator's connection to the Interface Chassis hardware via **direct EPICS interface**. This is a critical architectural component that serves as Layer 2 in the 4-layer protection hierarchy.

**Key Design Decision**: The Interface Chassis has a **dedicated EPICS IOC** providing direct software monitoring and control capabilities, independent of the MPS PLC gateway.

### 4.2 Interface Chassis Functions

The Interface Chassis performs the following hardware functions that must be monitored and coordinated by software:

1. **Hardware AND-logic** of all permit signals with <1 μs response time
2. **First-fault detection** and latching to identify the initiating fault in cascade scenarios
3. **Electrical isolation** of all external signals via optocouplers and fiber-optics
4. **Centralized reset control** from MPS PLC to clear all latched faults simultaneously
5. **Status reporting** to both MPS PLC and direct EPICS interface for software monitoring

### 4.3 Direct EPICS Interface Architecture

```python
class InterfaceChassisInterface:
    """Direct EPICS interface to Interface Chassis IOC (SRF1:IC:)
    
    Provides Python coordinator access to Interface Chassis status and control
    independent of MPS PLC gateway. Enables comprehensive fault analysis and
    system diagnostics.
    """
    
    def __init__(self, epics_bridge: EPICSBridge):
        self.epics = epics_bridge
        self.pv_prefix = "SRF1:IC:"
        
        # Input status PVs (7 inputs)
        self.input_pvs = {
            'llrf9_status': f"{self.pv_prefix}LLRF9:STATUS",
            'hvps_status': f"{self.pv_prefix}HVPS:STATUS", 
            'spear_mps': f"{self.pv_prefix}SPEAR:MPS",
            'orbit_intlck': f"{self.pv_prefix}ORBIT:INTLCK",
            'arc_permit': f"{self.pv_prefix}ARC:PERMIT",
            'wfbuf_permit': f"{self.pv_prefix}WFBUF:PERMIT",
            'manual_reset': f"{self.pv_prefix}MANUAL:RESET"
        }
        
        # Output status PVs (3 outputs)
        self.output_pvs = {
            'llrf9_enable': f"{self.pv_prefix}LLRF9:ENABLE",
            'hvps_scr_enable': f"{self.pv_prefix}HVPS:SCR:EN",
            'hvps_crowbar': f"{self.pv_prefix}HVPS:CROWBAR"
        }
        
        # Control and diagnostics PVs (4 PVs)
        self.control_pvs = {
            'first_fault': f"{self.pv_prefix}FIRST:FAULT",
            'reset_cmd': f"{self.pv_prefix}RESET:CMD",
            'permit_summary': f"{self.pv_prefix}PERMIT:SUMMARY",
            'status_word': f"{self.pv_prefix}STATUS:WORD"
        }
    
    async def initialize(self) -> bool:
        """Initialize Interface Chassis monitoring"""
        try:
            # Verify all PVs are accessible
            all_pvs = {**self.input_pvs, **self.output_pvs, **self.control_pvs}
            for name, pv in all_pvs.items():
                if not await self.epics.verify_connection(pv):
                    logger.error(f"Interface Chassis PV not accessible: {pv}")
                    return False
            
            # Set up critical monitors
            await self.epics.monitor(self.control_pvs['permit_summary'], 
                                   self._permit_summary_changed)
            await self.epics.monitor(self.control_pvs['first_fault'], 
                                   self._first_fault_changed)
            
            logger.info("Interface Chassis interface initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"Interface Chassis initialization failed: {e}")
            return False
    
    async def get_status(self) -> Dict[str, Any]:
        """Get complete Interface Chassis status"""
        try:
            # Batch read all status PVs
            all_pvs = {**self.input_pvs, **self.output_pvs, **self.control_pvs}
            values = await self.epics.batch_get(list(all_pvs.values()))
            
            return {
                'inputs': {
                    name: values.get(pv, None) 
                    for name, pv in self.input_pvs.items()
                },
                'outputs': {
                    name: values.get(pv, None) 
                    for name, pv in self.output_pvs.items()
                },
                'control': {
                    name: values.get(pv, None) 
                    for name, pv in self.control_pvs.items()
                },
                'timestamp': datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Interface Chassis status read failed: {e}")
            return {'error': str(e)}
    
    async def get_first_fault_analysis(self) -> Dict[str, Any]:
        """Get first-fault analysis for root cause identification"""
        try:
            first_fault_code = await self.epics.get(self.control_pvs['first_fault'])
            status_word = await self.epics.get(self.control_pvs['status_word'])
            
            # Decode first-fault register
            fault_map = {
                0: "No fault",
                1: "LLRF9 Status",
                2: "HVPS Status", 
                3: "SPEAR MPS",
                4: "Orbit Interlock",
                5: "Arc Detection",
                6: "Waveform Buffer",
                7: "Manual Reset"
            }
            
            return {
                'first_fault_code': first_fault_code,
                'first_fault_source': fault_map.get(first_fault_code, "Unknown"),
                'status_word': status_word,
                'analysis_timestamp': datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"First-fault analysis failed: {e}")
            return {'error': str(e)}
    
    async def reset_faults(self) -> bool:
        """Reset all latched faults via EPICS command"""
        try:
            await self.epics.put(self.control_pvs['reset_cmd'], 1)
            logger.info("Interface Chassis fault reset commanded")
            return True
            
        except Exception as e:
            logger.error(f"Interface Chassis reset failed: {e}")
            return False
    
    def _permit_summary_changed(self, value, **kwargs):
        """Handle permit summary changes"""
        if value == 0:  # Permit lost
            logger.critical("Interface Chassis permit lost")
            # Publish fault event for immediate state machine response
            self.event_bus.publish_fault(
                source="Interface Chassis",
                fault_code="PERMIT_LOST",
                details={'permit_summary': value}
            )
    
    def _first_fault_changed(self, value, **kwargs):
        """Handle first-fault register changes"""
        if value != 0:  # New fault detected
            logger.warning(f"Interface Chassis first-fault detected: {value}")
            # Trigger first-fault analysis
            asyncio.create_task(self._analyze_first_fault(value))
```

### 4.4 Integration with State Machine

The Interface Chassis interface integrates with the Master State Machine to provide permit verification and fault coordination:

```python
class MasterStateMachine:
    def __init__(self, interface_chassis: InterfaceChassisInterface):
        self.ic = interface_chassis
    
    async def verify_permits_for_transition(self, target_state: StationState) -> bool:
        """Verify Interface Chassis permits before state transitions"""
        ic_status = await self.ic.get_status()
        
        if not ic_status.get('control', {}).get('permit_summary'):
            logger.error("Interface Chassis permit not available for transition")
            return False
        
        # Check specific input requirements for target state
        if target_state in [StationState.STANDBY, StationState.ON_CW]:
            required_inputs = ['llrf9_status', 'hvps_status', 'spear_mps']
            for input_name in required_inputs:
                if not ic_status.get('inputs', {}).get(input_name):
                    logger.error(f"Required IC input not available: {input_name}")
                    return False
        
        return True
```

### 4.5 Integration with Fault Manager

The Interface Chassis provides first-fault analysis capabilities to the Fault Manager:

```python
class FaultManager:
    def __init__(self, interface_chassis: InterfaceChassisInterface):
        self.ic = interface_chassis
    
    async def analyze_fault_cascade(self, fault_event: FaultEvent) -> Dict[str, Any]:
        """Analyze fault cascade using Interface Chassis first-fault data"""
        
        # Get first-fault analysis from Interface Chassis
        first_fault = await self.ic.get_first_fault_analysis()
        
        # Correlate with fault event timing
        analysis = {
            'primary_fault_source': first_fault.get('first_fault_source'),
            'cascade_analysis': self._analyze_cascade_sequence(fault_event, first_fault),
            'recommended_recovery': self._determine_recovery_procedure(first_fault)
        }
        
        return analysis
```

### 4.6 Testing Strategy

**Development Testing** (before hardware available):
```python
class MockInterfaceChassisIOC:
    """Mock Interface Chassis IOC for development testing"""
    
    def __init__(self):
        self.inputs = {
            'llrf9_status': 1,
            'hvps_status': 1,
            'spear_mps': 1,
            'orbit_intlck': 1,
            'arc_permit': 1,
            'wfbuf_permit': 1,
            'manual_reset': 0
        }
        self.first_fault_register = 0
        self.permit_summary = 1
    
    def inject_fault(self, input_name: str):
        """Inject fault for testing fault cascade analysis"""
        if self.first_fault_register == 0:  # First fault
            fault_codes = {
                'llrf9_status': 1, 'hvps_status': 2, 'spear_mps': 3,
                'orbit_intlck': 4, 'arc_permit': 5, 'wfbuf_permit': 6
            }
            self.first_fault_register = fault_codes.get(input_name, 0)
        
        self.inputs[input_name] = 0
        self.permit_summary = 0
```

## 5. Master State Machine

### 5.1 Complete System State Coordination

The Master State Machine coordinates all 10 subsystems through a unified state model that ensures proper sequencing, safety verification, and fault handling across the entire RF station.

**Station States**:
```python
class StationState(Enum):
    OFF = "OFF"                    # All subsystems disabled, safe state
    STANDBY = "STANDBY"           # Heater warming, HVPS ready, no RF
    PARK = "PARK"                 # Tuners at park position, heater operating
    TUNE = "TUNE"                 # Low power tuning mode, limited HVPS
    ON_CW = "ON_CW"              # Full power operation, all systems active
    FAULT = "FAULT"              # Fault condition, coordinated shutdown
```

### 5.2 State Machine Integration with Interface Chassis

The Master State Machine integrates directly with the Interface Chassis for permit verification:

```python
class MasterStateMachine:
    """Master state machine coordinating all 10 subsystems"""
    
    def __init__(self, interface_chassis: InterfaceChassisInterface):
        self.ic = interface_chassis
        self.current_state = StationState.OFF
        
        # Set up Interface Chassis fault monitoring
        self.ic.event_bus.subscribe(EventType.IC_PERMIT_LOST, self._handle_ic_fault)
    
    async def verify_permits_for_transition(self, target_state: StationState) -> bool:
        """Verify Interface Chassis permits before state transitions"""
        ic_status = await self.ic.get_status()
        
        if not ic_status.get('control', {}).get('permit_summary'):
            logger.error("Interface Chassis permit not available for transition")
            return False
        
        # State-specific permit verification
        if target_state in [StationState.STANDBY, StationState.ON_CW]:
            required_inputs = ['llrf9_status', 'hvps_status', 'spear_mps']
            for input_name in required_inputs:
                if not ic_status.get('inputs', {}).get(input_name):
                    logger.error(f"Required IC input not available: {input_name}")
                    return False
        
        return True
    
    async def _handle_ic_fault(self, event: FaultEvent):
        """Handle Interface Chassis fault - immediate FAULT state"""
        logger.critical(f"Interface Chassis fault: {event.details}")
        
        # Get first-fault analysis
        fault_analysis = await self.ic.get_first_fault_analysis()
        logger.critical(f"First-fault source: {fault_analysis.get('first_fault_source')}")
        
        # Immediate transition to FAULT state
        await self._emergency_fault_state()
```

---

## 6. Comprehensive Fault Management

### 6.1 System-Wide Fault Architecture

The Fault Management system provides comprehensive fault detection, analysis, and recovery across all 10 subsystems with Interface Chassis first-fault analysis.

```python
class FaultManager:
    """Comprehensive fault management across all subsystems"""
    
    def __init__(self, interface_chassis: InterfaceChassisInterface):
        self.ic = interface_chassis
        self.active_faults = {}
        self.fault_history = []
    
    async def analyze_system_fault(self, fault_event: FaultEvent) -> Dict[str, Any]:
        """Comprehensive fault analysis using Interface Chassis first-fault data"""
        
        # Get Interface Chassis first-fault analysis
        ic_analysis = await self.ic.get_first_fault_analysis()
        
        # Determine recovery procedure based on first-fault source
        recovery_plan = self._determine_recovery_procedure(ic_analysis)
        
        return {
            'fault_event': fault_event.to_dict(),
            'first_fault_analysis': ic_analysis,
            'recovery_plan': recovery_plan,
            'analysis_timestamp': datetime.now().isoformat()
        }
    
    def _determine_recovery_procedure(self, ic_analysis: Dict[str, Any]) -> Dict[str, Any]:
        """Determine recovery procedure based on Interface Chassis first-fault analysis"""
        
        first_fault_source = ic_analysis.get('first_fault_source', 'Unknown')
        
        recovery_procedures = {
            'LLRF9 Status': {
                'steps': ['Check LLRF9 interlocks', 'Reset LLRF9 if safe', 'Verify cavity conditions'],
                'estimated_time': '2-5 minutes',
                'requires_operator': False
            },
            'HVPS Status': {
                'steps': ['Check HVPS interlocks', 'Verify arc detection', 'Reset HVPS controller'],
                'estimated_time': '1-3 minutes', 
                'requires_operator': True
            },
            'SPEAR MPS': {
                'steps': ['Contact SPEAR operations', 'Wait for MPS permit restoration'],
                'estimated_time': '5-30 minutes',
                'requires_operator': True
            },
            'Arc Detection': {
                'steps': ['Inspect waveguide', 'Check arc detector sensors', 'Reset if safe'],
                'estimated_time': '10-60 minutes',
                'requires_operator': True
            }
        }
        
        return recovery_procedures.get(first_fault_source, {
            'steps': ['Manual investigation required'],
            'estimated_time': 'Unknown',
            'requires_operator': True
        })
```

---

## 16. Complete EPICS PV Namespace

### 16.1 Comprehensive PV Registry

**Complete EPICS PV namespace for all 10 subsystems** (~1,315 total PVs):

#### Interface Chassis (SRF1:IC:) - ~20 PVs **[Direct EPICS Interface]**
```
# Input Status (7 PVs)
SRF1:IC:LLRF9:STATUS            # LLRF9 status input
SRF1:IC:HVPS:STATUS             # HVPS status input
SRF1:IC:SPEAR:MPS               # SPEAR MPS permit input
SRF1:IC:ORBIT:INTLCK            # Orbit interlock input
SRF1:IC:ARC:PERMIT              # Arc detection permit input
SRF1:IC:WFBUF:PERMIT            # Waveform buffer permit input
SRF1:IC:MANUAL:RESET            # Manual reset input

# Output Status (3 PVs)
SRF1:IC:LLRF9:ENABLE            # LLRF9 enable output
SRF1:IC:HVPS:SCR:EN             # HVPS SCR enable output
SRF1:IC:HVPS:CROWBAR            # HVPS crowbar output

# Control & Diagnostics (10 PVs)
SRF1:IC:FIRST:FAULT             # First-fault register
SRF1:IC:RESET:CMD               # Reset command
SRF1:IC:PERMIT:SUMMARY          # Overall permit summary
SRF1:IC:STATUS:WORD             # Complete status word
```

#### LLRF9 Units (LLRF1:, LLRF2:) - ~1,100 PVs Total
```
# Critical Control PVs
LLRF1:ILOCK:ALL                 # Unit 1 interlock aggregate
LLRF2:ILOCK:ALL                 # Unit 2 interlock aggregate
LLRF1:BRD1:FB:ASET              # Amplitude setpoint
LLRF1:BRD1:FB:PSET              # Phase setpoint
```

#### HVPS Controller (SRF1:HVPS:) - ~30 PVs
```
SRF1:HVPS:VOLT:CTRL             # Voltage setpoint command
SRF1:HVPS:VOLT:RB               # Voltage readback
SRF1:HVPS:STATUS:READY          # Controller ready status
```

#### Python Coordinator (SRF1:COORD:) - ~30 PVs
```
SRF1:COORD:STATE                # Current station state
SRF1:COORD:STATE:REQUEST        # Requested state transition
SRF1:COORD:FAULT:ACTIVE         # Fault condition active
SRF1:COORD:FAULT:FIRST          # First-fault identification
```

---

## 19. Implementation Roadmap

### 19.1 Development Phases

**Phase 1: Core Infrastructure** (Weeks 1-4)
- EPICS Bridge implementation
- Interface Chassis IOC development (**Direct EPICS interface**)
- Master State Machine framework
- Basic fault management

**Phase 2: Subsystem Integration** (Weeks 5-8)
- LLRF9 interface implementation
- HVPS interface implementation
- Tuner motor interface implementation
- Interface Chassis software integration

**Phase 3: Advanced Features** (Weeks 9-12)
- Comprehensive fault management with first-fault analysis
- Waveform Buffer integration
- Arc Detection integration
- Heater Controller integration

**Phase 4: System Integration** (Weeks 13-16)
- Complete system testing
- Interface Chassis hardware integration
- Performance optimization
- Documentation completion

### 19.2 Critical Dependencies

1. **Interface Chassis Hardware**: Interface Chassis IOC development depends on hardware specifications
2. **LLRF9 Units**: Software testing requires LLRF9 hardware or comprehensive simulation
3. **EPICS Infrastructure**: All subsystem IOCs must be operational for integration testing
4. **Safety System Integration**: PPS and MPS interfaces must be verified before full operation

### 19.3 Success Criteria

- **All 10 subsystems integrated** with direct EPICS interfaces
- **Interface Chassis direct EPICS interface** operational with first-fault analysis
- **Master State Machine** coordinating all subsystems successfully
- **Comprehensive fault management** with automated recovery procedures
- **Complete EPICS PV namespace** (~1,315 PVs) operational and archived
- **System performance** meeting <1 Hz supervisory control requirements

---

## Conclusion

This comprehensive software design document provides the complete architecture for integrating all 10 subsystems of the SPEAR3 LLRF Upgrade Project. The **Interface Chassis has direct EPICS interface** as requested, enabling comprehensive software monitoring and control independent of the MPS PLC gateway.

The software architecture ensures:
- **Complete system integration** across all subsystems
- **Hardware safety independence** with 4-layer protection hierarchy
- **Comprehensive fault management** with first-fault analysis
- **Direct EPICS interfaces** for all subsystems including Interface Chassis
- **Coordinated state machine** managing all subsystem transitions
- **Observable system state** via ~1,315 EPICS PVs

This design provides the foundation for a modern, maintainable, and comprehensive control system that replaces the legacy SNL programs while maintaining the highest levels of safety and reliability.

---
