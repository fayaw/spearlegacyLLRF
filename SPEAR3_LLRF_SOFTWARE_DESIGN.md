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

### 2.1 Three-Layer Architecture

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

### 2.2 Communication Architecture

**EPICS Network Backbone**: All components communicate via EPICS Channel Access, leveraging existing SPEAR3 infrastructure.

**Ethernet-Based**: LLRF9 units, Python coordinator, and external controllers use standard Ethernet connectivity.

**Fiber Optic Interlocks**: Critical safety signals use fiber optic links for noise immunity and electrical isolation.

---

## 3. LLRF9 Hardware Integration

### 3.1 LLRF9 Configuration for SPEAR3

**Hardware Specifications**:
- **Model**: LLRF9/476 (476 ± 2.5 MHz operation)
- **RF Channels**: 9 inputs, 2 drive outputs, 2 spare outputs
- **Configuration**: "One station, four cavities, single power source" (Manual Section 8.4)
- **Built-in EPICS IOC**: Linux-based with Ethernet connectivity

**Channel Assignment**:
```
ADC0: Cavity 1 probe (primary vector sum)
ADC1: Cavity 2 probe (secondary vector sum)
ADC2: Cavity 3 probe (monitoring/interlock)
ADC3: Cavity 4 probe (monitoring/interlock)
ADC4: RF reference signal
ADC5: Forward power monitoring
ADC6: Reflected power monitoring
ADC7: Circulator reflected power
ADC8: Spare/calibration

DAC0: Klystron drive output (+8 dBm full scale)
DAC1: Spare/calibration output (-13 dBm full scale)
```

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
        """Define allowed state transitions with conditions"""
        return {
            'OFF': ['PARK'],  # Can only go to PARK from OFF
            'PARK': ['OFF', 'TUNE'],  # Can go to OFF or TUNE from PARK
            'TUNE': ['PARK', 'ON_CW'],  # Can go to PARK or ON_CW from TUNE
            'ON_CW': ['PARK', 'ON_FM'],  # Can go to PARK or ON_FM from ON_CW
            'ON_FM': ['PARK', 'ON_CW']   # Can go to PARK or ON_CW from ON_FM
        }
```

### 6.2 State Implementation Details

**OFF State**:
- All systems disabled
- LLRF9 RF output disabled
- HVPS disabled and grounded
- All tuners parked
- No permits issued

**PARK State**:
- Safe operational state
- LLRF9 enabled but RF output at minimum
- HVPS enabled but voltage = 0
- Tuners enabled for positioning
- Basic permits active

**TUNE State**:
- Low-power RF for cavity tuning
- LLRF9 amplitude setpoint = 10% of normal
- HVPS voltage = 20% of normal
- Tuner control loops active
- Automatic tuning algorithms enabled

**ON_CW State**:
- Normal continuous wave operation
- LLRF9 amplitude/phase setpoints at operational values
- HVPS voltage at operational setpoint
- All control loops active
- Full power operation

**ON_FM State**:
- Fast modulation operation
- LLRF9 configured for rapid setpoint changes
- HVPS voltage modulation enabled
- Enhanced monitoring for transient conditions

### 6.3 Interlock Integration

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

### 7.2 Fiber Optic Interlock System

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

### 7.3 Enerpro Gate Driver Integration

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
