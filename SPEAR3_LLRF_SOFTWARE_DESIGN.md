# SPEAR3 LLRF Upgrade Software Design
**Version 2.0 - LLRF9 Integration Architecture**  
**Date: February 2026**  
**Author: Codegen AI Assistant**

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
9. [MPS Integration](#9-mps-integration)
10. [Operator Interface Design](#10-operator-interface-design)
11. [Configuration Management](#11-configuration-management)
12. [Fault Detection & Logging](#12-fault-detection--logging)
13. [Implementation Plan](#13-implementation-plan)
14. [Testing & Commissioning Strategy](#14-testing--commissioning-strategy)
15. [Documentation Requirements](#15-documentation-requirements)

---

## 1. Executive Summary

### 1.1 Project Overview

The SPEAR3 LLRF upgrade transitions from a legacy VxWorks/SNL-based system to a modern distributed architecture leveraging the Dimtel LLRF9 hardware controller with a Python-based supervisory coordinator. This design eliminates ~90% of legacy SNL code complexity while providing enhanced performance, reliability, and maintainability.

### 1.2 Key Design Principles

**Hardware-Accelerated Processing**: LLRF9 handles all real-time RF control (270 ns direct loop, calibration, phase measurement), eliminating complex analog drift compensation.

**Distributed Responsibility Model**: Clear separation between hardware-accelerated RF processing (LLRF9) and supervisory control (Python coordinator).

**Native EPICS Integration**: Built-in LLRF9 EPICS IOC provides seamless integration with existing SPEAR3 control infrastructure.

**Modular Architecture**: Loosely-coupled modules enable incremental development and commissioning during the 1-week Dimtel support window.

### 1.3 Performance Improvements

| Metric | Legacy System | LLRF9 System | Improvement |
|--------|---------------|---------------|-------------|
| **Calibration Time** | ~20 minutes | ~3 minutes | 85% reduction |
| **Code Complexity** | 2800+ lines SNL | ~300 lines Python | 90% reduction |
| **Interlock Response** | Software (~ms) | Hardware (~µs) | 1000x faster |
| **Phase Resolution** | Analog limited | Digital precision | Improved accuracy |
| **Maintenance** | Analog drift issues | Digital stability | Reduced downtime |

---

## 2. System Architecture Overview

### 2.1 Fundamental Architecture Change

The upgrade fundamentally changes the control architecture from a **software-centric** model (VxWorks SNL doing everything) to a **distributed hardware-accelerated** model:

```
LEGACY SYSTEM                          UPGRADED SYSTEM
==============                         ================

  VxWorks IOC (one box)                 Multiple specialized subsystems
  ├── rf_states.st (state machine)      ├── Dimtel LLRF9 (fast RF control)
  ├── rf_dac_loop.st (gap voltage)      │   ├── Fast analog I/Q processing
  ├── rf_hvps_loop.st (HVPS control)    │   ├── Direct loop feedback
  ├── rf_tuner_loop.st x4 (tuners)     │   ├── Comb loop feedback
  ├── rf_calib.st (calibration)         │   ├── Gap voltage regulation
  ├── rf_msgs.st (messages)             │   ├── Phase measurement for tuners
  └── RFP analog module                 │   └── Drive power monitoring
                                        │
                                        ├── CompactLogix PLC (HVPS control)
                                        │   ├── Voltage regulation
                                        │   ├── HVPS interlocks
                                        │   └── Contactor control
                                        │
                                        ├── CompactLogix PLC (MPS)
                                        │   ├── Fault summary
                                        │   ├── Permit management
                                        │   └── External interlocks
                                        │
                                        ├── Motion Controller (tuner motors)
                                        │   └── 4-axis stepper motor control
                                        │
                                        └── Python/EPICS Coordinator (this design)
                                            ├── Station state machine
                                            ├── HVPS supervisory control
                                            ├── Tuner position management
                                            ├── Load angle offset loop
                                            ├── Slow power monitoring
                                            ├── Fault logging & diagnostics
                                            └── Operator interface
```

### 2.2 Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OPERATOR INTERFACE LAYER                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Web Interface │  │  EPICS Screens  │  │  Mobile Apps    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                 PYTHON COORDINATOR LAYER                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Station State   │  │ HVPS Controller │  │ Tuner Manager   │ │
│  │ Machine         │  │ Interface       │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Fault Logger    │  │ Config Manager  │  │ MPS Interface   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                   HARDWARE CONTROL LAYER                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ LLRF9 Unit #1   │  │ LLRF9 Unit #2   │  │ MPS Controller  │ │
│  │ (Built-in IOC)  │  │ (Built-in IOC)  │  │ (ControlLogix)  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ HVPS Controller │  │ Motion Control  │  │ Arc Detection   │ │
│  │ (CompactLogix)  │  │ (Galil/etc)     │  │ (Microstep-MIS) │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Communication Architecture

```
                    ┌──────────────────────────────┐
                    │    Python/EPICS Coordinator    │
                    │    (Linux Soft IOC + Python)   │
                    └──────┬───┬───┬───┬───┬───────┘
                           │   │   │   │   │
              ┌────────────┘   │   │   │   └────────────┐
              │                │   │   │                 │
              ▼                ▼   │   ▼                 ▼
    ┌─────────────┐  ┌──────────┐ │ ┌──────────┐  ┌──────────┐
    │  Dimtel     │  │ HVPS PLC │ │ │ MPS PLC  │  │ Slow Pwr │
    │  LLRF9      │  │ Compact  │ │ │ Compact  │  │ Monitor  │
    │             │  │ Logix    │ │ │ Logix    │  │ (ADC)    │
    │ Ethernet/   │  │ EtherNet │ │ │ EtherNet │  │          │
    │ EPICS       │  │ /IP      │ │ │ /IP      │  │          │
    └──────┬──────┘  └────┬─────┘ │ └────┬─────┘  └──────────┘
           │              │       │      │
           │              │       │      │
    ┌──────┴──────┐   ┌───┴──┐   │  ┌───┴────────────────────┐
    │ 4 Cavities  │   │ HVPS │   │  │ Interface Chassis      │
    │ + Klystron  │   │      │   │  │ ├─ LLRF9 permit I/O    │
    │ + Waveguide │   └──────┘   │  │ ├─ HVPS fiber optic    │
    └─────────────┘              │  │ ├─ Arc detectors        │
                                 │  │ └─ External interlocks  │
                    ┌────────────┘  └────────────────────────┘
                    ▼
            ┌──────────────┐
            │Motion Ctrl   │
            │(Galil/other) │
            │ 4-axis       │
            │ Ethernet     │
            └──────┬───────┘
                   │
            ┌──────┴───────┐
            │ 4 Stepper    │
            │ Motors +     │
            │ Potentiomtrs │
            └──────────────┘
```

**EPICS Network Backbone**: All components communicate via EPICS Channel Access, leveraging existing SPEAR3 infrastructure.

**Ethernet-Based**: LLRF9 units, Python coordinator, and external controllers use standard Ethernet connectivity.

**Fiber Optic Interlocks**: Critical safety signals use fiber optic links for noise immunity and electrical isolation.

### 2.4 Hardware/Software Responsibility Partitioning

This is the **most critical design decision**. The table below maps every legacy function to its new owner:

#### **Function Assignment Matrix**

| Legacy Function | Legacy Owner | New Owner | Interface | Notes |
|----------------|-------------|-----------|-----------|-------|
| **Fast I/Q demodulation** | RFP analog | **LLRF9** | Internal | Core LLRF9 function |
| **Direct loop feedback** | RFP analog + SNL | **LLRF9** | Config via Ethernet | LLRF9 handles loop closure |
| **Comb loop feedback** | RFP analog + SNL | **LLRF9** | Config via Ethernet | LLRF9 handles comb filtering |
| **Lead/Integral compensation** | SNL (rf_states.st) | **LLRF9** | Config via Ethernet | LLRF9 internal |
| **Gap voltage regulation** | SNL (rf_dac_loop.st) | **LLRF9 + Python** | LLRF9 fast loop; Python supervisory setpoint | LLRF9 closes fast amplitude/phase loop around its setpoint. Python implements slow supervisory loop (~1 Hz) that adjusts LLRF9 amplitude setpoint based on measured total gap voltage error (equivalent to legacy DAC loop). The legacy 4-way branching (direct loop on/off x GVF available/not) is simplified because LLRF9 always handles the inner loop. |
| **Drive power monitoring** | SNL (rf_dac_loop.st) | **LLRF9 + Python** | LLRF9 measures; Python monitors | Python reads LLRF9 data for HVPS decisions |
| **HVPS voltage control** | SNL (rf_hvps_loop.st) | **Python/EPICS** | EtherNet/IP to PLC | Python sends voltage setpoints to PLC |
| **HVPS vacuum processing** | SNL (rf_hvps_loop.st) | **Python/EPICS** | EtherNet/IP to PLC | Python implements process ramp |
| **Station state machine** | SNL (rf_states.st) | **Python/EPICS** | Channel Access to all subsystems | Python coordinates all subsystem states |
| **Tuner phase control** | SNL (rf_tuner_loop.st) | **LLRF9** | Delta-move commands to Python | LLRF9 measures phase; sends move commands |
| **Tuner motor control** | SNL (rf_tuner_loop.st) | **Python/EPICS** | EPICS motor record to controller | Python/motor record drives Galil |
| **Load angle offset** | SNL (rf_tuner_loop.st) | **Python/EPICS** | Channel Access | Python adjusts phase setpoints for power balance |
| **Tuner home/reset** | SNL (rf_tuner_loop.st) | **Python/EPICS** | EPICS motor record | Python manages home positions |
| **Calibration** | SNL (rf_calib.st) | **LLRF9 + Python** | LLRF9 internal cal + Python orchestration | LLRF9 has its own calibration; Python manages workflow |
| **Fault file capture** | SNL (rf_states.st) | **Python/EPICS** | Read LLRF9 buffers | Python captures waveforms on fault |
| **Message logging** | SNL (rf_msgs.st) | **Python/EPICS** | Standard Python logging | Modern logging framework |
| **MPS interface** | Direct hardware | **MPS PLC** | EtherNet/IP to Python | PLC handles fast faults; Python monitors |
| **HVPS contactor** | SNL (rf_states.st) | **HVPS PLC** | Command via EtherNet/IP | PLC controls contactor; Python commands open/close |
| **Beam abort control** | SNL (rf_states.st) | **LLRF9 + MPS** | Hardware interlock | Fast path through LLRF9 permit |
| **Slow power monitoring** | Legacy analog | **External ADC + Python** | ADC → EPICS | New MCL ZX47-40LN detectors |
| **Arc detection** | None (broken) | **Microstep-MIS → MPS PLC** | Optocoupler to MPS | New capability |

#### **Key Design Principle: LLRF9 is the Inner Loop**

The LLRF9 handles ALL time-critical RF control. Python/EPICS is the **supervisory layer**:

```
  Python/EPICS Responsibility          LLRF9 Responsibility
  ─────────────────────────            ────────────────────
  Station state coordination           Fast I/Q processing (μs)
  HVPS voltage setpoints (~1 Hz)       Direct loop feedback (kHz)
  Tuner motor positioning (~1 Hz)      Comb loop feedback
  Load angle offset (~0.1 Hz)          Gap voltage fast regulation
  Fault logging & diagnostics          Drive power measurement
  Operator interface                   Cavity phase measurement
  Permit management (via MPS)          RF enable/disable
  Configuration management             Internal calibration
  Turn-on/shutdown sequencing          Transient management
```

---

## 3. LLRF9 Hardware Integration

### 3.1 LLRF9 Configuration for SPEAR3

**Hardware Specifications**:
- **Model**: LLRF9/476 (476 ± 2.5 MHz operation, covers SPEAR3's 476.3 MHz)
- **Quantity**: **2 LLRF9 units required for operation** (4 units procured total: 2 operational + 2 complete spares, per Upgrade Task List)
- **RF Channels per unit**: 9 inputs (3 LLRF4.6 boards × 3 signal channels, with 1 reference per board), 2 interlocked drive outputs, 2 direct outputs
- **Configuration**: "One station, four cavities, single power source" (Manual Section 8.4)
- **Built-in EPICS IOC**: Linux-based SBC (mini-ITX), Ethernet connectivity, configurable device name (PV format: `{DEVICE}:HW:CONFIG`)
- **Thermal stabilization**: Internal cold plate with 3 TEC modules under PID control

**Dual-LLRF9 Architecture**:

The SPEAR3 system uses **two LLRF9 units** because each LLRF4.6 board dedicates one of its four ADC channels to the RF reference signal, leaving 3 signal channels per board (9 signal channels per LLRF9). With 4 cavity probes plus additional monitoring signals (forward power, reflected power, etc.), two units are needed.

Each LLRF4.6 board that performs real-time cavity field control can handle at most 2 cavity probe signals in its vector sum. For SPEAR3's 4-cavity configuration, the cavity probes are split across the two units.

**Channel Assignment** (approximate — final assignment to be confirmed during commissioning):
```
LLRF9 Unit #1 (Primary — handles vector sum and drive output):
  Board 1: ADC0=Cavity 1 probe, ADC1=Cavity 2 probe, ADC2=Forward power, ADC3=Reference
  Board 2: ADC4=Cavity 3 probe, ADC5=Cavity 4 probe, ADC6=Reflected power, ADC7=Reference
  Board 3: ADC8=Circulator reflected, ADC9=Klystron drive fwd, ADC10=Spare, ADC11=Reference
  DAC0: Klystron drive output (amplified, filtered, interlocked)
  DAC1: Spare/calibration output

LLRF9 Unit #2 (Secondary — additional monitoring, interlocks, spare capacity):
  Additional RF monitoring channels for redundancy and diagnostics
  Independent interlock chain (Note: stations share interlock chain per unit)
  Spare drive output capability for redundancy
```

**Note**: The exact channel assignment depends on the SPEAR3-specific LLRF9 firmware configuration from Dimtel. The key constraint is that cavity probes forming a vector sum must be on the same LLRF4.6 board.

**Additional RF Monitoring** (per Upgrade Task List):
- LLRF9 units monitor 18 RF inputs total
- 6 additional monitoring points needed from legacy system → handled by external MCL ZX47-40LN-S+ power detectors in slow power monitoring chassis
- 1 additional input for klystron collector power → for MPS system

### 3.2 LLRF9 Capabilities Utilized

**Real-Time RF Processing**:
- **Vector Sum Control**: Combines cavity probes (ADC0 + ADC1) with configurable gains
- **Direct Loop**: 270 ns latency proportional feedback for fast disturbance rejection
- **Integral Loop**: Long-term error correction and steady-state accuracy
- **Phase Measurement**: 10 Hz cavity probe vs. forward phase comparison for tuner feedback

**Built-in Calibration System**:
- **Automatic I/Q Balance**: CORDIC-based processing eliminates manual coefficient calibration
- **Network Analyzer**: Integrated swept-sine excitation for loop characterization
- **Digital Processing**: Eliminates analog DAC drift compensation (major legacy complexity)

**Hardware Interlocks**:
- **RF Input Interlocks**: Fast overvoltage detection with ±35 ns timestamp resolution
- **Daisy-Chain Support**: Hardware interlock distribution to other systems
- **Event Timestamping**: ±17.4 ns uncertainty for precise fault sequencing

### 3.3 EPICS Process Variables

The LLRF9 built-in IOC provides native EPICS PVs:

**Control PVs**:
```
LLRF9:STATION1:AMPLITUDE_SP     # Amplitude setpoint
LLRF9:STATION1:PHASE_SP         # Phase setpoint
LLRF9:STATION1:DIRECT_GAIN      # Direct loop gain
LLRF9:STATION1:INTEGRAL_GAIN    # Integral loop gain
LLRF9:STATION1:ENABLE           # RF output enable
```

**Monitoring PVs**:
```
LLRF9:STATION1:AMPLITUDE_RB     # Amplitude readback
LLRF9:STATION1:PHASE_RB         # Phase readback
LLRF9:STATION1:CAVITY_PHASE     # Cavity phase for tuner feedback
LLRF9:STATION1:FORWARD_POWER    # Forward power measurement
LLRF9:STATION1:REFLECTED_POWER  # Reflected power measurement
```

**Interlock PVs**:
```
LLRF9:STATION1:RF_PERMIT        # RF permit status
LLRF9:STATION1:FAULT_STATUS     # Fault status word
LLRF9:STATION1:FAULT_TIMESTAMP  # Last fault timestamp
```

---

## 4. Python Coordinator Architecture

### 4.1 Core Design Philosophy

The Python Coordinator serves as the "brain" of the SPEAR3 LLRF system, providing high-level supervisory control while leveraging LLRF9 hardware for real-time RF processing. It implements the station state machine, coordinates with external systems (HVPS, MPS, tuners), and provides modern operator interfaces.

### 4.2 Modular Class Architecture

```python
# Core System Architecture
class SPEAR3_LLRF_Coordinator:
    """Main coordinator class orchestrating all LLRF subsystems"""
    
    def __init__(self):
        self.station_manager = StationStateManager()
        self.hvps_interface = HVPSControlInterface()
        self.tuner_manager = TunerControlManager()
        self.mps_interface = MPSInterface()
        self.fault_logger = FaultLogger()
        self.config_manager = ConfigurationManager()
        self.web_interface = WebInterface()
        
    def initialize_system(self):
        """Initialize all subsystems and establish communications"""
        
    def run_main_loop(self):
        """Main control loop - 10 Hz update rate"""
```

### 4.3 Station State Manager

```python
class StationStateManager:
    """Implements the 5-state station control logic"""
    
    STATES = {
        'OFF': 'System completely disabled',
        'PARK': 'Safe state, HVPS off, RF off',
        'TUNE': 'Tuning mode, low power RF for cavity tuning',
        'ON_CW': 'Normal CW operation',
        'ON_FM': 'Fast modulation operation'
    }
    
    def __init__(self):
        self.current_state = 'OFF'
        self.target_state = 'OFF'
        self.state_transition_timer = 0
        self.interlock_status = {}
        
    def request_state_change(self, target_state):
        """Request transition to new state with safety checks"""
        
    def update_state_machine(self):
        """Execute state machine logic - called at 10 Hz"""
        
    def check_transition_conditions(self, target_state):
        """Verify all conditions are met for state transition"""
        
    def execute_state_transition(self):
        """Perform actual state transition with proper sequencing"""
```

### 4.4 HVPS Control Interface

```python
class HVPSControlInterface:
    """Interface to CompactLogix HVPS controller"""
    
    def __init__(self):
        self.hvps_pv_prefix = "HVPS:STATION1"
        self.voltage_setpoint = 0.0
        self.current_voltage = 0.0
        self.hvps_status = {}
        self.ramp_rate = 1000.0  # V/s maximum ramp rate
        
    def set_voltage_setpoint(self, voltage, ramp_rate=None):
        """Set HVPS voltage with controlled ramp rate"""
        
    def enable_hvps(self):
        """Enable HVPS with proper sequencing"""
        
    def disable_hvps(self):
        """Disable HVPS safely"""
        
    def monitor_hvps_status(self):
        """Monitor HVPS health and status"""
        
    def handle_hvps_fault(self, fault_info):
        """Handle HVPS fault conditions"""
```

### 4.5 Tuner Control Manager

```python
class TunerControlManager:
    """Coordinates 4-cavity tuner system using LLRF9 phase feedback"""
    
    def __init__(self):
        self.tuner_controllers = {}  # 4 tuner motor controllers
        self.phase_feedback = {}     # Phase data from LLRF9
        self.tuner_positions = {}    # Current tuner positions
        self.pid_controllers = {}    # PID control for each tuner
        
    def initialize_tuners(self):
        """Initialize all 4 tuner motor controllers"""
        
    def update_tuner_control(self):
        """Update tuner positions based on LLRF9 phase feedback"""
        
    def home_all_tuners(self):
        """Execute homing sequence for all tuners"""
        
    def balance_cavity_fields(self):
        """Implement field balancing for multi-cell cavities"""
        
    def handle_tuner_fault(self, tuner_id, fault_info):
        """Handle individual tuner faults"""
```

---

## 5. EPICS Integration Layer

### 5.1 Process Variable Architecture

The EPICS integration layer provides a unified namespace for all SPEAR3 LLRF control and monitoring functions:

**Station Control PVs**:
```
SPEAR3:LLRF:STATION:STATE           # Current station state
SPEAR3:LLRF:STATION:STATE_CMD       # Commanded state change
SPEAR3:LLRF:STATION:PERMIT          # Overall station permit
SPEAR3:LLRF:STATION:FAULT_STATUS    # Station fault summary
```

**RF Control PVs**:
```
SPEAR3:LLRF:RF:AMPLITUDE_SP         # Gap voltage amplitude setpoint
SPEAR3:LLRF:RF:PHASE_SP             # Gap voltage phase setpoint
SPEAR3:LLRF:RF:AMPLITUDE_RB         # Gap voltage amplitude readback
SPEAR3:LLRF:RF:PHASE_RB             # Gap voltage phase readback
SPEAR3:LLRF:RF:FORWARD_POWER        # Forward power measurement
SPEAR3:LLRF:RF:REFLECTED_POWER      # Reflected power measurement
```

**HVPS Control PVs**:
```
SPEAR3:LLRF:HVPS:VOLTAGE_SP         # HVPS voltage setpoint
SPEAR3:LLRF:HVPS:VOLTAGE_RB         # HVPS voltage readback
SPEAR3:LLRF:HVPS:CURRENT_RB         # HVPS current readback
SPEAR3:LLRF:HVPS:STATUS             # HVPS status word
SPEAR3:LLRF:HVPS:ENABLE             # HVPS enable command
```

**Tuner Control PVs**:
```
SPEAR3:LLRF:TUNER1:POSITION_SP      # Tuner 1 position setpoint
SPEAR3:LLRF:TUNER1:POSITION_RB      # Tuner 1 position readback
SPEAR3:LLRF:TUNER1:PHASE_ERROR      # Tuner 1 phase error
SPEAR3:LLRF:TUNER1:STATUS           # Tuner 1 status
# ... similar for TUNER2, TUNER3, TUNER4
```

### 5.2 EPICS Database Structure

```python
class EPICSIntegrationLayer:
    """Manages all EPICS process variables and database records"""
    
    def __init__(self):
        self.pv_database = {}
        self.calculation_records = {}
        self.alarm_limits = {}
        
    def create_pv_database(self):
        """Create EPICS database with all required PVs"""
        
    def setup_calculation_records(self):
        """Setup EPICS calc records for derived quantities"""
        
    def configure_alarms(self):
        """Configure alarm limits and severity levels"""
        
    def update_pv_values(self, data_dict):
        """Update PV values from Python coordinator"""
```

---

## 6. Station State Machine

### 6.1 State Definitions and Transitions

The station state machine implements the same 5-state logic as the legacy system but with improved safety interlocks and cleaner transitions:

```python
class StationStateMachine:
    """Enhanced 5-state machine with LLRF9 integration"""
    
    def __init__(self):
        self.states = {
            'OFF': self._state_off,
            'PARK': self._state_park,
            'TUNE': self._state_tune,
            'ON_CW': self._state_on_cw,
            'ON_FM': self._state_on_fm
        }
        self.current_state = 'OFF'
        self.transition_table = self._build_transition_table()
        
    def _build_transition_table(self):
        """Define allowed state transitions with conditions.
        
        Based on legacy rf_states.st state transition matrix (lines 63-77):
        
          From\To   OFF   PARK  TUNE  ON_FM  ON_CW
          OFF         -     Y     Y     Y      Y
          PARK        Y     -     -     -      -
          TUNE        Y     -     -     -      Y
          ON_FM       Y     -     Y     -      -
          ON_CW       Y     -     Y     -      -
        
        Note: OFF can transition directly to any operational state (not 
        restricted to going through PARK first). This matches SPEAR3 
        operational practice where operators often go OFF→TUNE→ON_CW.
        ON_FM and ON_CW can only step back to TUNE (not directly to PARK).
        PARK can only go to OFF (it was designed for PEP-II and is rarely 
        used at SPEAR3).
        """
        return {
            'OFF':   ['PARK', 'TUNE', 'ON_FM', 'ON_CW'],  # Can go to any state from OFF
            'PARK':  ['OFF'],                               # Can only go to OFF from PARK
            'TUNE':  ['OFF', 'ON_CW'],                     # Can go to OFF or ON_CW from TUNE
            'ON_FM': ['OFF', 'TUNE'],                      # Can go to OFF or TUNE from ON_FM
            'ON_CW': ['OFF', 'TUNE']                       # Can go to OFF or TUNE from ON_CW
        }
```

### 6.2 State Implementation Details

**OFF State**:
- All systems disabled; LLRF9 RF output disabled
- HVPS triggers off, HVPS voltage zeroed
- Tuners moved to park position
- All feedback loops disabled (DAC, HVPS, tuner, direct, comb)
- Beam abort forced; no permits issued
- **Fault detection**: If a fault caused the transition to OFF, auto-reset logic may attempt recovery (configurable retry count, typically 3 attempts)

**PARK State**:
- Legacy state originally designed for PEP-II operation when an RF station was down
- **Rarely used at SPEAR3** — primarily exists for compatibility
- HVPS contactor may remain energized
- Limited fault monitoring active
- Can only transition to OFF
- **Note**: Different from TUNE — PARK does not enable RF output

**TUNE State**:
- Low-power RF for cavity tuning and system testing
- **Critical first step**: Tuners moved to TUNE/ON Home position (`SRF1:CAV1TUNR:POSN:ONHOME`)
- HVPS set to Turn-On Voltage (`SRF1:HVPS:VOLT:MIN`, typically ~50 kV)
- DAC set to initial low value (~100 counts), producing a few watts of drive power
- Sufficient field to start measuring RF parameters and enabling LLRF controls
- Tuner feedback loops active (phase-based control)
- HVPS loop OFF (user manually controls voltage in TUNE)
- DAC loop adjusts for drive power (not gap voltage)
- Used to test new equipment (e.g., refurbished HVPS or new klystron)
- May need to adjust Direct Loop Phase for new klystron phase differences

**ON_CW State**:
- Normal continuous wave operation — **primary operational mode for SPEAR3**
- Full turn-on sequence (see Section 6.3):
  1. Direct loop closure (adds integrator, causes controlled power transient)
  2. Wait for transient to settle (10-20 seconds)
  3. DAC and HVPS control loops become active
  4. Coordinated ramp to full power (~50W drive, ~3.2 MV gap voltage, ~1 MW klystron)
- All feedback loops active: DAC loop (gap voltage), HVPS loop (drive power), tuner loops (cavity frequency), direct/comb/ripple loops
- Drive power setpoint maintained by HVPS supervisory loop
- Total gap voltage maintained by DAC supervisory loop
- Tickle capability for beam tune measurement

**ON_FM State**:
- **Cavity vacuum processing mode** (NOT "fast modulation" for normal operation)
- Designed for processing cavities after a vacuum incident to remove foreign particles
- Loads I/Q modulation files (400 Hz or 1 kHz) into RFP module
- HVPS PROCESS mode: slowly ramps voltage while monitoring vacuum, decreases if vacuum degrades
- **Rarely used at SPEAR3** — Jim's doc notes they have only had one vacuum incident and successfully processed using ON_CW mode with varying gap voltage instead
- Transition path: ON_FM → TUNE → OFF (cannot go directly to ON_CW)

### 6.3 Turn-On Sequence (TUNE to ON_CW)

The turn-on sequence is the most complex state transition. Based on the legacy rf_states.st implementation and Jim's operational document:

**Pre-Conditions (checked before transition begins)**:
- All interlocks satisfied
- HVPS contactor energized and ready
- Tuners at TUNE/ON Home positions (verified via potentiometer)

**Sequence Steps**:

| Step | Action | Detail |
|------|--------|--------|
| 1 | Set HVPS to Turn-On Voltage |  (typically ~50 kV) |
| 2 | Set DAC to Fast-On Counts |  (~200 counts) for ON_CW |
| 3 | Enable RF Output | LLRF9 permit set; produces a few watts of drive power |
| 4 | Close Direct Loop | Analog switch closes integrator; **causes controlled power transient** |
| 5 | Wait for Transient | 10-20 seconds for power transient to settle |
| 6 | Enable DAC Control Loop | Begins adjusting amplitude to maintain gap voltage |
| 7 | Enable HVPS Control Loop | HVPS supervisory loop begins drive power regulation |
| 8 | Coordinated Ramp | DAC increases gap voltage; HVPS tracks to maintain drive power setpoint |
| 9 | Reach Full Power | ~50W drive power, ~3.2 MV total gap voltage, ~1 MW klystron output |
| 10 | Reset Beam Abort | Only after gap voltage stable above threshold ( timeout ~30s) |

**Fast Turn-On Mode**: The system includes a fast turn-on capability (controlled by ). This jumps to predetermined "safe" DAC and HVPS values rather than ramping from minimum, reducing turn-on time from minutes to seconds. Requires careful calibration of fast-on values.

### 6.4 Auto-Reset Logic

The legacy system implements automatic fault recovery (from  lines 56-58):



### 6.5 Interlock Integration

```python
class InterlockManager:
    """Manages all interlock conditions for state transitions"""
    
    def __init__(self):
        self.interlock_sources = {
            'SPEAR3_MPS': False,
            'ORBIT_INTERLOCK': False,
            'RF_MPS': False,
            'LLRF9_PERMIT': False,
            'HVPS_READY': False,
            'TUNER_READY': False,
            'ARC_DETECTION': False
        }
        
    def check_all_interlocks(self):
        """Check all interlock conditions"""
        return all(self.interlock_sources.values())
        
    def get_failed_interlocks(self):
        """Return list of failed interlocks"""
        return [name for name, status in self.interlock_sources.items() if not status]
```

---

## 7. HVPS Control Interface

### 7.1 CompactLogix PLC Interface

The HVPS control interface manages communication with the upgraded CompactLogix PLC controller (75% specified in task list):

```python
class HVPSControlInterface:
    """Interface to CompactLogix HVPS controller with fiber optic interlocks"""
    
    def __init__(self):
        self.plc_ip_address = "192.168.1.100"  # CompactLogix IP
        self.fiber_optic_interface = FiberOpticInterface()
        self.voltage_limits = {
            'minimum': 0.0,
            'maximum': 50000.0,  # 50 kV maximum
            'ramp_rate': 1000.0   # 1 kV/s maximum ramp
        }
        
    def initialize_hvps_interface(self):
        """Initialize PLC communication and fiber optic links"""
        
    def set_voltage_with_ramp(self, target_voltage, ramp_rate=None):
        """Set HVPS voltage with controlled ramp rate"""
        if ramp_rate is None:
            ramp_rate = self.voltage_limits['ramp_rate']
            
        # Implement ramping logic at 10 Hz update rate
        current_voltage = self.get_current_voltage()
        voltage_step = ramp_rate * 0.1  # 10 Hz update rate
        
        if abs(target_voltage - current_voltage) > voltage_step:
            if target_voltage > current_voltage:
                next_voltage = current_voltage + voltage_step
            else:
                next_voltage = current_voltage - voltage_step
        else:
            next_voltage = target_voltage
            
        self.send_voltage_setpoint(next_voltage)
```


### 7.2 HVPS Supervisory Feedback Loop (Critical Addition)

The legacy `rf_hvps_loop.st` implements a **critical supervisory feedback loop** that adjusts the HVPS voltage setpoint based on drive power measurements. The CompactLogix PLC handles low-level voltage regulation and safety, but **the higher-level decision about what voltage to request** must be implemented in the Python coordinator. Without this loop, the system cannot maintain proper drive power levels during normal operation.

**Three Operating Modes** (from legacy `rf_hvps_loop.st`):

1. **OFF Mode** (`HVPS_LOOP_CONTROL_OFF`):
   - No voltage adjustments
   - Used when station is OFF or PARK
   - Tracks current readback voltage passively

2. **PROCESS Mode** (`HVPS_LOOP_CONTROL_PROC`) -- Vacuum Conditioning:
   - Used after cavity maintenance to remove particles
   - **Algorithm**: Every ~0.5 seconds:
     - **Decrease voltage** if ANY of: klystron forward power > max, cavity gap voltage > setpoint, cavity vacuum too high
     - **Increase voltage** if all conditions are good
   - Slowly ramps voltage while vacuum system removes particles
   - Critical for cavity conditioning after vacuum incidents

3. **ON Mode** (`HVPS_LOOP_CONTROL_ON`) -- Normal Drive Power Regulation:
   - Maintains klystron drive power at its setpoint
   - **Algorithm**: As DAC loop increases amplitude, drive power increases. HVPS loop increases cathode voltage, giving higher klystron gain, so drive power returns to setpoint with higher RF output.
   - **Dual behavior** depending on station mode:
     - **ON_CW + Direct Loop ON**: Uses drive power error to compute HVPS delta (inverted sign: `delta_hvps = -delta_on_voltage`)
     - **TUNE or Direct Loop OFF**: Uses gap voltage error to compute HVPS delta
   - Includes cavity voltage limit checking: if any cavity voltage above max AND delta would increase HVPS voltage, the increase is blocked

```python
class HVPSSupervisoryLoop:
    """Supervisory HVPS voltage control loop.
    
    Equivalent to legacy rf_hvps_loop.st. Adjusts the HVPS voltage SETPOINT 
    sent to the CompactLogix PLC. The PLC handles actual voltage regulation. 
    This loop runs at ~1 Hz.
    """
    
    MODES = {
        'OFF': 0,       # No voltage control
        'PROCESS': 1,   # Vacuum processing/conditioning
        'ON': 2         # Normal drive power regulation
    }
    
    def __init__(self):
        self.mode = 'OFF'
        self.update_rate = 1.0  # Hz (~0.5s in legacy)
        self.voltage_setpoint = 0.0
        self.prev_voltage_setpoint = 0.0
        
        # Configurable parameters
        self.delta_proc_voltage_up = 100.0    # V per step during processing
        self.delta_proc_voltage_down = -200.0  # V per step during processing
        self.min_voltage = 0.0
        self.max_voltage = 90000.0  # 90 kV max
        self.voltage_tolerance = 500.0  # V readback vs requested tolerance
        
    def update(self, station_state, direct_loop_on, measurements):
        """Main supervisory loop update, called at ~1 Hz"""
        
        if self.mode == 'OFF':
            self.prev_voltage_setpoint = measurements['hvps_voltage_readback']
            return
            
        # Safety checks first (priority order from legacy code)
        if self._check_module_health(measurements) != 'OK':
            return  # Don't adjust if hardware is unhealthy
            
        if self.mode == 'PROCESS':
            self._process_mode_update(measurements)
        elif self.mode == 'ON':
            self._on_mode_update(station_state, direct_loop_on, measurements)
    
    def _process_mode_update(self, m):
        """Vacuum conditioning: ramp up unless problems detected"""
        if (m['klystron_fwd_power'] > m['max_klystron_fwd_power'] or
            m['gap_voltage_above_setpoint'] or
            m['cavity_vacuum_too_high']):
            delta = self.delta_proc_voltage_down
        else:
            delta = self.delta_proc_voltage_up
        self._apply_voltage_delta(delta, m['hvps_voltage_readback'])
    
    def _on_mode_update(self, station_state, direct_loop_on, m):
        """Normal operation: maintain drive power setpoint"""
        if station_state == 'ON_CW' and direct_loop_on:
            delta = -m['drive_power_delta']  # Inverted sign
        else:
            delta = m['gap_voltage_delta']
        
        # Block voltage increase if any cavity above max
        if m['any_cavity_above_max'] and delta > 0:
            return
            
        self._apply_voltage_delta(delta, m['hvps_voltage_readback'])
    
    def _apply_voltage_delta(self, delta, readback):
        """Apply voltage change with readback tolerance checking"""
        if abs(readback - self.prev_voltage_setpoint) < self.voltage_tolerance:
            new_voltage = max(self.min_voltage,
                            min(self.max_voltage, self.voltage_setpoint + delta))
            self.voltage_setpoint = new_voltage
            self.prev_voltage_setpoint = new_voltage
            caput('SPEAR3:LLRF:HVPS:VOLTAGE_SP', new_voltage)
```



### 7.3 Fiber Optic Interlock System

```python
class FiberOpticInterface:
    """Manages fiber optic interlock signals with HVPS controller"""
    
    def __init__(self):
        self.fiber_channels = {
            'MPS_CROWBAR_INHIBIT': 'Prevents MPS from firing crowbar thyristors',
            'PHASE_CONTROL_ENABLE': 'Allows phase control thyristors to fire',
            'HVPS_READY_STATUS': 'HVPS ready to output high voltage'
        }
        
    def send_mps_crowbar_inhibit(self, inhibit_state):
        """Send crowbar inhibit signal to HVPS controller"""
        
    def send_phase_control_enable(self, enable_state):
        """Send phase control enable signal to HVPS controller"""
        
    def receive_hvps_ready_status(self):
        """Receive HVPS ready status from controller"""
```

### 7.4 Enerpro Gate Driver Integration

The task list specifies upgrading to new Enerpro controller boards (~$4000 for 5 boards):

```python
class EnerproInterface:
    """Interface to Enerpro thyristor gate driver boards"""
    
    def __init__(self):
        self.gate_driver_status = {}
        self.firing_angle_limits = {
            'minimum': 0.0,
            'maximum': 180.0
        }
        
    def configure_gate_drivers(self):
        """Configure Enerpro boards for SPEAR3 operation"""
        
    def monitor_gate_driver_health(self):
        """Monitor gate driver board status and faults"""
```

---

## 8. Tuner Control System

### 8.1 Modern Motion Controller Integration

The task list indicates investigation of motion control solutions developed by Domenico and Mike Dunning. The design accommodates various motion controller options:

```python
class TunerMotionController:
    """Abstracted interface for tuner motion controllers"""
    
    def __init__(self, controller_type='galil'):
        self.controller_type = controller_type
        self.tuner_count = 4
        self.position_feedback = {}
        self.motion_profiles = {}
        
        # Initialize specific controller
        if controller_type == 'galil':
            self.controller = GalilController()
        elif controller_type == 'domenico':
            self.controller = DomenicoController()
        else:
            raise ValueError(f"Unsupported controller type: {controller_type}")
```

### 8.2 LLRF9 Phase Feedback Integration

```python
class TunerPhaseFeedback:
    """Integrates LLRF9 10 Hz phase measurements for tuner control"""
    
    def __init__(self):
        self.phase_measurements = {}
        self.phase_setpoints = {}
        self.pid_controllers = {}
        self.tuning_deadband = 0.1  # degrees
        
    def update_phase_feedback(self):
        """Get latest phase measurements from LLRF9"""
        for cavity_id in range(1, 5):
            pv_name = f"LLRF9:STATION1:CAVITY{cavity_id}_PHASE"
            self.phase_measurements[cavity_id] = caget(pv_name)
            
    def calculate_tuner_corrections(self):
        """Calculate required tuner movements based on phase errors"""
        corrections = {}
        for cavity_id in range(1, 5):
            phase_error = (self.phase_setpoints[cavity_id] - 
                          self.phase_measurements[cavity_id])
            
            if abs(phase_error) > self.tuning_deadband:
                pid = self.pid_controllers[cavity_id]
                correction = pid.update(phase_error)
                corrections[cavity_id] = correction
            else:
                corrections[cavity_id] = 0.0
                
        return corrections
```

### 8.3 Field Balancing for Multi-Cell Cavities

```python
class FieldBalancingController:
    """Implements field balancing using differential tuner motion"""
    
    def __init__(self):
        self.cavity_field_measurements = {}
        self.balancing_algorithms = {
            'differential_tuning': self._differential_tuning,
            'iterative_correction': self._iterative_correction
        }
        
    def _differential_tuning(self, cavity_id):
        """Use differential tuner motion to balance cavity cells"""
        # Implementation for dual-tuner differential motion
        
    def balance_cavity_fields(self):
        """Execute field balancing for all cavities"""
        for cavity_id in range(1, 5):
            if self._field_imbalance_detected(cavity_id):
                self._differential_tuning(cavity_id)
```

### 8.4 Critical Tuner Control Features from Legacy System

The following features from the legacy tuner control system (`rf_tuner_loop.st` and Jim's operational document) MUST be preserved in the upgraded system:

#### 8.4.1 Stop-and-Init Feature

The legacy controller has a "stop and init" feature that **realigns the internal step counter with the measured potentiometer position without moving the tuner**. Since our system has no encoders (only linear potentiometers for position indication), drift can occur between the commanded step count and actual physical position. This feature is critical for recovering from:
- Power loss to the motion controller
- Communication interruption
- Accumulated step count errors

```python
class TunerStopAndInit:
    """Implements the stop-and-init feature for tuner step counter realignment."""
    
    def stop_and_init(self, tuner_id):
        """Realign step counter with potentiometer reading without moving tuner."""
        pot_voltage = caget(f'SPEAR3:LLRF:TUNER{tuner_id}:POT_RB')
        pot_position_mm = self.voltage_to_position(pot_voltage)
        current_step_count = caget(f'SPEAR3:LLRF:TUNER{tuner_id}:STEP_COUNT')
        new_step_count = self.position_to_steps(pot_position_mm)
        caput(f'SPEAR3:LLRF:TUNER{tuner_id}:STEP_COUNT', new_step_count)
```

#### 8.4.2 Home Position Management

Each tuner has TWO home positions that depend on the station operating mode:
- **TUNE/ON Home** (`SRF1:CAV1TUNR:POSN:ONHOME`): Position used during normal RF operation
- **PARK Home** (`SRF1:CAV1TUNR:POSN:PARKHOME`): Position used when station is parked/off

During turn-on, tuners are moved to their TUNE/ON Home position BEFORE any RF is applied. The homing sequence uses the potentiometer to verify position within tolerance (`RDBD * LOOP_RESET_TOLS`), making multiple attempts (`LOOP_RESET_COUNT = 5`) with delays between tries.

#### 8.4.3 Load Angle Offset Loop

Per Jim's document: "The load angle offset loop seems to be best suited for our EPICS application rather than LLRF9."

This is a **slow secondary loop** that adjusts the phase setpoints of individual cavity tuner loops to equalize gap voltage contribution across all 4 cavities:
- User sets desired fraction per cavity via `SRF1:CAV1:STRENGTH:CTRL` (e.g., 0.25 for equal distribution)
- Loop measures actual gap voltage in each cavity
- Adjusts individual tuner phase setpoints to redistribute power
- Runs slower than the primary phase control loop (~0.1 Hz)

#### 8.4.4 Power Interlock for Tuner Control

The tuner control loop is **disabled when cavity power is too low** (from `rf_tuner_loop.st`):
- Checks `klys_frwd_pwr` against `klys_frwd_pwr_min`
- If klystron forward power is bad (INVALID severity) or below minimum threshold, tuner loop reports `LOOP_POWR_LOW_STATUS` and does not attempt to move the tuner
- This prevents erroneous tuner movements when phase measurements are unreliable due to low signal levels

#### 8.4.5 Tuner Mechanical Specifications (for motion profile design)

From Jim's document and drawing SA-341-392-61:
- **Stepper Motor**: Superior Electric Slo-Syn M093-FC11 (NEMA 34D), 200 steps/rev
- **Controller Resolution**: 2 microsteps/step = 400 microsteps/rev (legacy); modern controllers offer 16-64 microsteps/step
- **Gear Ratio**: 15:30 timing belt pulleys = 1:2 (motor:leadscrew)
- **Lead Screw**: 1/2-10 Acme thread = 0.1"/turn = 2.54 mm/turn
- **Linear Resolution**: 400 microsteps / (2 leadscrew revs) = 0.003175 mm/microstep (legacy)
- **Deadband**: 5 microsteps (legacy `RDBD`)
- **Typical Startup Motion**: ~2.5 mm (1 leadscrew turn, 2 motor turns)
- **Typical Normal Operation Motion**: ~0.2 mm
- **Motion Profiles**: Legacy system used uniform pulse rates only. Jim recommends testing acceleration/deceleration profiles on the actual cavity.

#### 8.4.6 Tuner Startup and Recovery Requirements

Per Jim's document, the EPICS driver must handle:
1. **Power loss recovery**: If the motion controller loses power, it must recover gracefully
2. **Communication loss**: If communication with the control system is lost, the controller should hold position (not free-run)
3. **Worst case**: May need to inform LLRF9 of communication failure, potentially triggering station shutdown if cavity goes far out of tune
4. **Update rate**: Small steps at approximately 1 Hz rate
5. **Reliability**: The upgrade task list notes persistent reliability issues with previous controller candidates



---

## 9. MPS Integration

### 9.1 Interface with Existing MPS System

The task list indicates the MPS system is already complete. The Python coordinator interfaces with this existing system:

```python
class MPSInterface:
    """Interface to existing ControlLogix MPS system"""
    
    def __init__(self):
        self.mps_pv_prefix = "MPS:RF:STATION1"
        self.interlock_inputs = {
            'LLRF9_FAULT': False,
            'HVPS_FAULT': False,
            'ARC_DETECTION': False,
            'POWER_MONITOR_FAULT': False,
            'SPEAR3_MPS': False,
            'ORBIT_INTERLOCK': False
        }
        
    def update_mps_status(self):
        """Update MPS status from all interlock sources"""
        
    def send_rf_permit(self, permit_state):
        """Send RF permit status to MPS system"""
        
    def handle_mps_trip(self, trip_source):
        """Handle MPS trip conditions"""
```

### 9.2 Arc Detection Integration

The task list specifies Microstep-MIS optical arc detectors (~$20k total cost):

```python
class ArcDetectionInterface:
    """Interface to Microstep-MIS optical arc detection system"""
    
    def __init__(self):
        self.arc_sensors = {
            'CAVITY1_AIR': 'Cavity 1 air side window',
            'CAVITY1_VACUUM': 'Cavity 1 vacuum side window',
            'CAVITY2_AIR': 'Cavity 2 air side window',
            'CAVITY2_VACUUM': 'Cavity 2 vacuum side window',
            'CAVITY3_AIR': 'Cavity 3 air side window',
            'CAVITY3_VACUUM': 'Cavity 3 vacuum side window',
            'CAVITY4_AIR': 'Cavity 4 air side window',
            'CAVITY4_VACUUM': 'Cavity 4 vacuum side window',
            'CIRCULATOR': 'Circulator monitoring',
            'KLYSTRON_WINDOW': 'Klystron window (if accessible)'
        }
        
    def monitor_arc_detection(self):
        """Monitor all arc detection sensors"""
        
    def handle_arc_detection(self, sensor_id):
        """Handle arc detection event with fast response"""
```

### 9.3 Slow Power Monitoring

The task list specifies ~8 channels of slow power monitoring using Minicircuits detectors:

```python
class SlowPowerMonitoring:
    """Monitors slow RF power levels using Minicircuits detectors"""
    
    def __init__(self):
        self.power_channels = {
            'CIRCULATOR_REFLECTED': 'Circulator reflected power',
            'LOAD1_REFLECTED': 'Load 1 reflected power',
            'LOAD2_REFLECTED': 'Load 2 reflected power',
            'LOAD3_REFLECTED': 'Load 3 reflected power',
            'LOAD4_REFLECTED': 'Load 4 reflected power',
            'FORWARD_POWER': 'Forward power monitoring',
            'KLYSTRON_COLLECTOR': 'Klystron collector power',
            'SPARE_CHANNEL': 'Spare monitoring channel'
        }
        self.power_limits = {}
        self.trip_levels = {}
        
    def monitor_power_levels(self):
        """Monitor all slow power channels"""
        
    def check_power_trip_levels(self):
        """Check if any power levels exceed trip thresholds"""
```

---

## 10. Operator Interface Design

### 10.1 Modern Web-Based Interface

The operator interface transitions from legacy EPICS screens to a modern web-based system:

```python
class WebInterface:
    """Modern web-based operator interface using Flask/React"""
    
    def __init__(self):
        self.flask_app = Flask(__name__)
        self.socketio = SocketIO(self.flask_app)
        self.dashboard_components = {
            'station_status': StationStatusWidget(),
            'rf_control': RFControlWidget(),
            'hvps_control': HVPSControlWidget(),
            'tuner_control': TunerControlWidget(),
            'fault_display': FaultDisplayWidget()
        }
        
    def create_dashboard(self):
        """Create responsive dashboard with real-time updates"""
        
    def setup_realtime_updates(self):
        """Setup WebSocket connections for real-time data"""
        
    def create_mobile_interface(self):
        """Create mobile-friendly interface for operators"""
```

### 10.2 Dashboard Components

**Station Status Widget**:
- Current state display with visual indicators
- State transition controls with safety confirmations
- Interlock status summary with detailed fault information
- System health overview

**RF Control Widget**:
- Amplitude and phase setpoint controls
- Real-time waveform displays from LLRF9
- Loop gain adjustments
- Calibration status and controls

**HVPS Control Widget**:
- Voltage setpoint with ramping controls
- Current and power monitoring
- Thyristor status display
- Safety interlock status

**Tuner Control Widget**:
- Individual tuner position displays
- Phase error monitoring
- Automatic tuning controls
- Field balancing status

### 10.3 Alarm and Notification System

```python
class AlarmSystem:
    """Comprehensive alarm and notification system"""
    
    def __init__(self):
        self.alarm_levels = {
            'INFO': 'Informational messages',
            'WARNING': 'Warning conditions',
            'ALARM': 'Alarm conditions requiring attention',
            'CRITICAL': 'Critical faults requiring immediate action'
        }
        self.notification_channels = {
            'web_interface': True,
            'email': True,
            'sms': False,
            'slack': True
        }
        
    def process_alarm(self, alarm_data):
        """Process and distribute alarm notifications"""
        
    def create_alarm_log(self):
        """Create searchable alarm log with filtering"""
```

---

## 11. Configuration Management

### 11.1 Centralized Configuration System

```python
class ConfigurationManager:
    """Centralized configuration management for all LLRF parameters"""
    
    def __init__(self):
        self.config_file = "spear3_llrf_config.yaml"
        self.config_data = {}
        self.parameter_limits = {}
        self.default_values = {}
        
    def load_configuration(self):
        """Load configuration from YAML file with validation"""
        
    def save_configuration(self):
        """Save current configuration with backup"""
        
    def validate_parameters(self, config_dict):
        """Validate all parameters against defined limits"""
        
    def create_configuration_backup(self):
        """Create timestamped configuration backup"""
```

### 11.2 Parameter Categories

**RF Parameters**:
```yaml
rf_parameters:
  amplitude_setpoint: 1000.0  # kV
  phase_setpoint: 0.0         # degrees
  direct_loop_gain: 10.0
  integral_loop_gain: 1.0
  calibration_interval: 3600  # seconds
```

**HVPS Parameters**:
```yaml
hvps_parameters:
  voltage_setpoint: 45000.0   # V
  current_limit: 2.0          # A
  ramp_rate: 1000.0          # V/s
  crowbar_threshold: 3.0      # A
```

**Tuner Parameters**:
```yaml
tuner_parameters:
  phase_setpoints: [0.0, 0.0, 0.0, 0.0]  # degrees
  pid_gains: [[1.0, 0.1, 0.01], [1.0, 0.1, 0.01], [1.0, 0.1, 0.01], [1.0, 0.1, 0.01]]
  deadband: 0.1               # degrees
  max_step_size: 100          # steps
```

---

## 12. Fault Detection & Logging

### 12.1 Enhanced Fault Detection

```python
class FaultDetectionSystem:
    """Advanced fault detection leveraging LLRF9 timestamps"""
    
    def __init__(self):
        self.fault_sources = {
            'LLRF9_HARDWARE': 'LLRF9 internal faults',
            'HVPS_CONTROLLER': 'HVPS controller faults',
            'ARC_DETECTION': 'Optical arc detection',
            'POWER_MONITORING': 'RF power limit violations',
            'TUNER_SYSTEM': 'Tuner motor faults',
            'INTERLOCK_SYSTEM': 'External interlock faults'
        }
        self.fault_correlator = FaultCorrelator()
        
    def process_fault_event(self, fault_data):
        """Process fault with nanosecond timestamp correlation"""
        
    def analyze_fault_sequence(self, fault_list):
        """Analyze fault sequence to determine root cause"""
```

### 12.2 Fault Correlation and Analysis

```python
class FaultCorrelator:
    """Correlates faults across multiple systems using precise timestamps"""
    
    def __init__(self):
        self.timestamp_resolution = 17.4e-9  # LLRF9 timestamp resolution
        self.correlation_window = 1e-3       # 1 ms correlation window
        
    def correlate_faults(self, fault_events):
        """Correlate faults within timing window"""
        
    def determine_fault_sequence(self, correlated_faults):
        """Determine causal sequence of fault events"""
        
    def generate_fault_report(self, fault_analysis):
        """Generate comprehensive fault analysis report"""
```

### 12.3 Logging and Data Archival

```python
class DataLogger:
    """Comprehensive data logging and archival system"""
    
    def __init__(self):
        self.log_channels = {
            'rf_data': 10,      # 10 Hz RF measurements
            'hvps_data': 10,    # 10 Hz HVPS data
            'tuner_data': 1,    # 1 Hz tuner positions
            'fault_events': 0,  # Event-driven fault logging
            'operator_actions': 0  # Event-driven operator logs
        }
        
    def setup_data_archival(self):
        """Setup data archival to SPEAR3 data systems"""
        
    def create_shift_reports(self):
        """Generate automated shift reports"""
```

---

## 13. Implementation Plan

### 13.1 Development Phases

**Phase 1: Core Infrastructure (Months 1-2)**
- Python coordinator framework development
- EPICS integration layer implementation
- Basic station state machine
- LLRF9 communication interface
- Configuration management system

**Phase 2: Subsystem Integration (Months 3-4)**
- HVPS control interface development
- MPS system integration
- Tuner control system implementation
- Arc detection interface
- Slow power monitoring integration

**Phase 3: Operator Interface (Months 5-6)**
- Web-based dashboard development
- Mobile interface creation
- Alarm and notification system
- Data logging and archival
- Documentation completion

### 13.2 Resource Requirements

**Software Development**:
- Senior Python developer: 6 months
- EPICS specialist: 3 months
- Web developer: 2 months
- Testing engineer: 2 months

**Hardware Integration**:
- Controls engineer: 4 months
- Electrical technician: 3 months
- Mechanical support: 1 month

### 13.3 Risk Mitigation

**Technical Risks**:
- LLRF9 integration complexity → Leverage Dimtel's 1-week commissioning support
- Motion controller selection → Prototype testing with candidate controllers
- HVPS interface timing → Test stand validation before SPEAR3 installation

**Schedule Risks**:
- Parallel development of independent modules
- Early prototype testing and validation
- Incremental commissioning approach

---

## 14. Testing & Commissioning Strategy

### 14.1 Test Stand Development

**HVPS Test Stand (Test Lab)**:
- Commission new HVPS controller in Test Stand 18
- Validate CompactLogix PLC interface
- Test Enerpro gate driver boards
- Verify fiber optic interlock system

**LLRF9 Prototype Testing**:
- Leverage existing SPEAR3 prototype experience
- Validate Python coordinator interface
- Test all control loops and interlocks
- Verify calibration procedures

### 14.2 Commissioning Sequence

**Week 1: LLRF9 Hardware Commissioning (with Dimtel Support)**
- LLRF9 installation and RF signal routing
- Basic RF processing validation
- Calibration system commissioning
- EPICS IOC configuration

**Week 2: Python Coordinator Integration**
- Station state machine testing
- HVPS interface validation
- Tuner system integration
- MPS interface testing

**Week 3: System Integration Testing**
- Full system operation testing
- Fault injection testing
- Performance validation
- Operator training

**Week 4: Production Transition**
- Legacy system parallel operation
- Performance comparison
- Final system validation
- Documentation completion

### 14.3 Acceptance Criteria

**Performance Requirements**:
- RF amplitude stability: ±0.1%
- RF phase stability: ±0.1°
- Calibration time: <5 minutes
- State transition time: <30 seconds
- Fault response time: <1 second

**Reliability Requirements**:
- System availability: >99.5%
- Mean time between failures: >1000 hours
- Fault detection coverage: >95%
- Automatic recovery capability: >90%

---

## 15. Documentation Requirements

### 15.1 Software Documentation Package

**Technical Documentation**:
- Software architecture document (this document)
- API reference documentation
- Configuration parameter guide
- Troubleshooting procedures
- Maintenance procedures

**Operator Documentation**:
- Operator interface user guide
- Standard operating procedures
- Emergency response procedures
- Alarm response guide
- Training materials

**Engineering Documentation**:
- System design specifications
- Interface control documents
- Test procedures and results
- Commissioning procedures
- As-built documentation

### 15.2 Code Documentation Standards

```python
class DocumentationStandards:
    """
    All Python code must follow these documentation standards:
    
    - Comprehensive docstrings for all classes and methods
    - Type hints for all function parameters and return values
    - Inline comments for complex logic
    - Configuration parameter documentation
    - Error handling documentation
    """
    
    def example_method(self, parameter: float) -> bool:
        """
        Example method demonstrating documentation standards.
        
        Args:
            parameter: Description of parameter with units and range
            
        Returns:
            Boolean indicating success/failure
            
        Raises:
            ValueError: If parameter is out of range
            ConnectionError: If EPICS communication fails
        """
        pass
```

### 15.3 Version Control and Change Management

**Git Repository Structure**:
```
spear3-llrf-upgrade/
├── src/
│   ├── coordinator/          # Python coordinator modules
│   ├── epics/               # EPICS database files
│   ├── web_interface/       # Web interface code
│   └── tests/               # Unit and integration tests
├── config/
│   ├── default_config.yaml  # Default configuration
│   └── test_config.yaml     # Test configuration
├── docs/
│   ├── architecture/        # Architecture documentation
│   ├── api/                 # API documentation
│   └── procedures/          # Operating procedures
└── scripts/
    ├── deployment/          # Deployment scripts
    └── maintenance/         # Maintenance scripts
```

**Change Management Process**:
- All changes require code review
- Automated testing before deployment
- Configuration changes require approval
- Emergency change procedures defined
- Change log maintenance

---

## Conclusion

This software design provides a comprehensive architecture for the SPEAR3 LLRF upgrade, leveraging the LLRF9 hardware capabilities while maintaining operational familiarity for SPEAR3 operators. The modular design enables incremental development and commissioning, reducing risk and ensuring successful deployment within the project timeline and budget constraints.

The key innovation is the clear separation of responsibilities: LLRF9 handles all real-time RF processing with hardware acceleration, while the Python coordinator provides high-level supervisory control and modern operator interfaces. This architecture eliminates ~90% of legacy SNL code complexity while providing enhanced performance, reliability, and maintainability.

**Next Steps**:
1. Review and approve this software design document
2. Begin Phase 1 development (Python coordinator framework)
3. Establish development environment and version control
4. Initiate HVPS test stand commissioning
5. Schedule Dimtel commissioning support for LLRF9 integration

---

**Document Version**: 2.0  
**Last Updated**: February 2026  
**Status**: Ready for Implementation

---

## 16. Open Questions Requiring Resolution

1. **LLRF9 API details**: What is the exact communication protocol? EPICS Channel Access, custom TCP, or REST API?
2. **LLRF9 tuner interface**: Does LLRF9 provide delta-move commands or absolute position targets for tuners?
3. **Motion controller selection**: Galil DMC-4143 vs. Domenico/Mike Dunning solution — final decision needed
4. **Motion profiles**: Jim's doc notes legacy only used uniform pulse rates. Need to test acceleration/deceleration profiles on actual cavity.
5. **HVPS PLC EPICS driver**: Use pycomm3, opcua, or custom EtherNet/IP driver for CompactLogix?
6. **Slow power monitor ADC**: What ADC hardware will digitize the MCL detector outputs?
7. **LLRF9 calibration workflow**: What manual steps are required? How does operator interact?
8. **Fault buffer format**: What is the format/size of LLRF9 fault history buffers?

---

**Document Status**: Consolidated from UPGRADE_SOFTWARE_DESIGN.md + SPEAR3_LLRF_SOFTWARE_DESIGN.md  
**Merge Date**: February 2026  
**Ready for**: Implementation Phase 1
