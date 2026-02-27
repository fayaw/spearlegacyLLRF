# SPEAR3 LLRF Upgrade — Software Design Document
## Upgraded Control System for Dimtel LLRF9 + CompactLogix Hardware

**Version**: 1.0  
**Date**: 2026-02-26  
**Based on**: Legacy code analysis, Jim's operational doc, LLRFUpgradeTaskListRev3.docx

---

## Table of Contents

1. [System Architecture Overview](#1-system-architecture-overview)
2. [Hardware/Software Responsibility Partitioning](#2-hardwaresoftware-responsibility-partitioning)
3. [Software Component Design](#3-software-component-design)
4. [Station State Machine](#4-station-state-machine)
5. [HVPS Control Interface](#5-hvps-control-interface)
6. [Tuner Control System](#6-tuner-control-system)
7. [Monitoring & Diagnostics](#7-monitoring--diagnostics)
8. [Fault Management & Safety](#8-fault-management--safety)
9. [Calibration System](#9-calibration-system)
10. [EPICS PV Database Design](#10-epics-pv-database-design)
11. [Implementation Plan](#11-implementation-plan)

---

## 1. System Architecture Overview

### 1.1 Fundamental Architecture Change

The upgrade fundamentally changes the control architecture from a **software-centric** model 
(VxWorks SNL doing everything) to a **distributed hardware-accelerated** model:

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

### 1.2 Communication Architecture

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

---

## 2. Hardware/Software Responsibility Partitioning

This is the **most critical design decision**. The table below maps every legacy function to its new owner:

### 2.1 Function Assignment Matrix

| Legacy Function | Legacy Owner | New Owner | Interface | Notes |
|----------------|-------------|-----------|-----------|-------|
| **Fast I/Q demodulation** | RFP analog | **LLRF9** | Internal | Core LLRF9 function |
| **Direct loop feedback** | RFP analog + SNL | **LLRF9** | Config via Ethernet | LLRF9 handles loop closure |
| **Comb loop feedback** | RFP analog + SNL | **LLRF9** | Config via Ethernet | LLRF9 handles comb filtering |
| **Lead/Integral compensation** | SNL (rf_states.st) | **LLRF9** | Config via Ethernet | LLRF9 internal |
| **Gap voltage regulation** | SNL (rf_dac_loop.st) | **LLRF9** | Setpoint via EPICS | LLRF9 closes fast loop; Python sets setpoint |
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

### 2.2 Key Design Principle: LLRF9 is the Inner Loop

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

### 2.3 Interface Definitions

**Python ↔ LLRF9** (Ethernet, EPICS Channel Access or Dimtel API):
- **Python reads from LLRF9**: Gap voltages (4), cavity phases (4), drive power, klystron power, loop statuses, fault buffers
- **Python writes to LLRF9**: Gap voltage setpoint, enable/disable, configuration parameters
- **LLRF9 outputs to Python**: Tuner delta-move requests (4 axes), fault status

**Python ↔ HVPS PLC** (EtherNet/IP):
- **Python reads**: HVPS voltage readback, HVPS current, contactor status, PLC fault status
- **Python writes**: Voltage setpoint (≤1 Hz), contactor open/close, enable/disable

**Python ↔ MPS PLC** (EtherNet/IP):
- **Python reads**: Fault summary, individual fault channels, permit status
- **Python writes**: Fault reset, permit acknowledge

**Python ↔ Motion Controller** (Ethernet, EPICS motor record):
- **Python reads**: Motor position (4), done-moving flags, limit switches, potentiometer readings
- **Python writes**: Move-to-position commands, velocity, acceleration profiles

---

## 3. Software Component Design

### 3.1 Directory Structure

```
spear3_llrf/
├── src/
│   ├── __init__.py
│   ├── main.py                     # Application entry point
│   │
│   ├── state_machine/
│   │   ├── __init__.py
│   │   ├── station_states.py       # State definitions & transitions
│   │   ├── station_controller.py   # Main state machine engine
│   │   ├── turn_on_sequence.py     # Turn-on orchestration
│   │   ├── shutdown_sequence.py    # Shutdown orchestration
│   │   └── fault_handler.py        # Fault response logic
│   │
│   ├── hvps/
│   │   ├── __init__.py
│   │   ├── hvps_controller.py      # HVPS supervisory control
│   │   ├── hvps_processor.py       # Vacuum processing mode
│   │   └── hvps_plc_interface.py   # PLC communication layer
│   │
│   ├── tuner/
│   │   ├── __init__.py
│   │   ├── tuner_manager.py        # Coordinate 4 tuner axes
│   │   ├── tuner_axis.py           # Single axis control
│   │   ├── load_angle_offset.py    # Power balancing loop
│   │   ├── tuner_home.py           # Home/reset procedures
│   │   └── motion_interface.py     # Motor record / Galil interface
│   │
│   ├── llrf9/
│   │   ├── __init__.py
│   │   ├── llrf9_interface.py      # LLRF9 communication
│   │   ├── llrf9_config.py         # LLRF9 configuration management
│   │   ├── llrf9_monitor.py        # Read-back monitoring
│   │   └── llrf9_calibration.py    # Calibration orchestration
│   │
│   ├── mps/
│   │   ├── __init__.py
│   │   ├── mps_interface.py        # MPS PLC communication
│   │   ├── permit_manager.py       # Permit logic
│   │   └── fault_logger.py         # Fault recording & files
│   │
│   ├── monitoring/
│   │   ├── __init__.py
│   │   ├── slow_power_monitor.py   # External power detector readouts
│   │   ├── arc_detector.py         # Microstep-MIS integration
│   │   ├── vacuum_monitor.py       # Cavity vacuum monitoring
│   │   └── diagnostics.py          # System health diagnostics
│   │
│   └── common/
│       ├── __init__.py
│       ├── pv_manager.py           # EPICS PV connection management
│       ├── config.py               # YAML configuration loader
│       ├── logging_config.py       # Structured logging setup
│       ├── safety_limits.py        # Safety parameter definitions
│       └── event_manager.py        # Event flag equivalent (pub/sub)
│
├── epics/
│   ├── db/
│   │   ├── station.db              # Station-level PVs
│   │   ├── hvps.db                 # HVPS interface PVs
│   │   ├── tuner.db                # Tuner control PVs (template)
│   │   ├── monitoring.db           # Slow monitoring PVs
│   │   └── llrf9.db                # LLRF9 interface PVs
│   ├── ioc/
│   │   ├── st.cmd                  # IOC startup script
│   │   └── envPaths               # Environment paths
│   └── protocols/
│       ├── galil.proto             # Galil stream device protocol
│       └── plc.proto               # PLC communication protocol
│
├── config/
│   ├── station.yaml                # Main station configuration
│   ├── hvps_params.yaml            # HVPS control parameters
│   ├── tuner_params.yaml           # Tuner control parameters
│   ├── safety_limits.yaml          # Safety limits and interlocks
│   ├── llrf9_config.yaml           # LLRF9 configuration
│   └── pv_mapping.yaml             # Legacy → new PV name mapping
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── simulation/                 # Simulated RF station for testing
│
└── docs/
    ├── operations/
    ├── commissioning/
    └── api/
```

### 3.2 Core Python Classes

```python
# ============================================================
# station_states.py — State Definitions
# ============================================================
from enum import IntEnum

class StationState(IntEnum):
    """Maps to legacy STATION_* defines from rf_loop_defs.h"""
    OFF   = 0
    PARK  = 1
    TUNE  = 2
    ON_FM = 3
    ON_CW = 4

# Legal transitions matrix (from rf_states.st lines 63-78)
LEGAL_TRANSITIONS = {
    StationState.OFF:   {StationState.PARK, StationState.TUNE, 
                         StationState.ON_FM, StationState.ON_CW},
    StationState.PARK:  {StationState.OFF},
    StationState.TUNE:  {StationState.OFF, StationState.ON_CW},
    StationState.ON_FM: {StationState.OFF, StationState.TUNE},
    StationState.ON_CW: {StationState.OFF, StationState.TUNE},
}

class HVPSLoopState(IntEnum):
    """Maps to legacy HVPS_LOOP_STATE_* defines"""
    OFF  = 0
    PROC = 1   # Vacuum processing
    ON   = 2   # Normal regulation

class HVPSLoopControl(IntEnum):
    """Maps to legacy HVPS_LOOP_CONTROL_* defines"""
    OFF  = 0
    PROC = 1
    ON   = 2
```

```python
# ============================================================
# station_controller.py — Main State Machine
# ============================================================
import logging
import time
from typing import Optional
from epics import PV, caput, caget

from .station_states import StationState, LEGAL_TRANSITIONS
from .turn_on_sequence import TurnOnSequence
from .fault_handler import FaultHandler
from ..common.event_manager import EventManager
from ..common.config import StationConfig

logger = logging.getLogger(__name__)

class StationController:
    """
    Master state machine for the RF station.
    Replaces rf_states.st from the legacy system.
    
    Key differences from legacy:
    - LLRF9 handles fast RF control (direct loop, comb loop, etc.)
    - This controller coordinates subsystem states
    - HVPS control goes through CompactLogix PLC
    - Tuner control through EPICS motor records
    """
    
    def __init__(self, config: StationConfig):
        self.config = config
        self.stn = config.station_name  # e.g., "SRF1"
        
        # Current and requested states
        self._current_state = StationState.OFF
        self._requested_state = StationState.OFF
        
        # Sub-controllers
        self.turn_on = TurnOnSequence(config)
        self.fault_handler = FaultHandler(config)
        self.events = EventManager()
        
        # Auto-reset parameters (from legacy rf_states.st)
        self.auto_reset_enabled = False
        self.reset_count = 0
        self.max_resets = 3
        
        # EPICS PV connections
        self._setup_pvs()
    
    def _setup_pvs(self):
        """Connect to EPICS PVs — replaces legacy CA variable assignments"""
        s = self.stn
        self.pv_ctrl       = PV(f'{s}:STN:STATE:CTRL', callback=self._on_ctrl_change)
        self.pv_rbck       = PV(f'{s}:STN:STATE:RBCK')
        self.pv_state_str  = PV(f'{s}:STN:STATE:STRING')
        self.pv_fault_noon = PV(f'{s}:STNON:SUMY:STAT.SEVR', callback=self._on_fault_change)
        self.pv_park_noon  = PV(f'{s}:STNPARK:SUMY:STAT.SEVR')
        self.pv_fault_off  = PV(f'{s}:STNOFF:SUMY:STAT.SEVR', callback=self._on_stnoff_fault)
        self.pv_panel_onoff = PV(f'{s}:STN:LOCAL:ON.SEVR')
        # LLRF9 interface
        self.pv_llrf9_enable = PV(f'{s}:LLRF9:RF:ENABLE')
        self.pv_llrf9_status = PV(f'{s}:LLRF9:STATUS')
    
    def request_transition(self, target: StationState) -> bool:
        """
        Request a state transition. Validates against:
        1. Legal transition matrix
        2. Fault/interlock status (fault_noon, park_noon, panel_onoff)
        3. LLRF9 readiness
        4. MPS permit status
        
        Returns True if transition is accepted.
        """
        if target == self._current_state:
            return True
        
        # Check legal transition
        if target not in LEGAL_TRANSITIONS.get(self._current_state, set()):
            logger.warning(f"Illegal transition: {self._current_state.name} -> {target.name}")
            return False
        
        # Check fault/interlock status for transitions from OFF
        if self._current_state == StationState.OFF:
            if target == StationState.PARK:
                if self.pv_park_noon.get() != 0:  # NO_ALARM = 0
                    logger.warning("Cannot go to PARK: park faults active")
                    return False
            elif target in (StationState.TUNE, StationState.ON_FM, StationState.ON_CW):
                if self.pv_fault_noon.get() != 0 or self.pv_panel_onoff.get() != 0:
                    logger.warning(f"Cannot go to {target.name}: station faults active")
                    return False
        
        logger.info(f"Transition accepted: {self._current_state.name} -> {target.name}")
        self._requested_state = target
        self._execute_transition(target)
        return True
    
    def _execute_transition(self, target: StationState):
        """Execute the state transition sequence"""
        # ... (detailed sequencing per state pair)
        pass
    
    def _on_ctrl_change(self, pvname, value, **kwargs):
        """Callback when operator requests a state change"""
        try:
            target = StationState(value)
            self.request_transition(target)
        except ValueError:
            logger.error(f"Invalid state requested: {value}")
    
    def _on_fault_change(self, pvname, value, **kwargs):
        """Callback when fault status changes"""
        self.fault_handler.evaluate(self._current_state, value)
    
    def _on_stnoff_fault(self, pvname, value, **kwargs):
        """
        Callback for station-off faults.
        Maps to legacy: fault_stnoff monitor in rf_states.st
        If severity != NO_ALARM, transition to OFF from any ON-state.
        """
        if value != 0 and self._current_state not in (StationState.OFF, StationState.PARK):
            logger.error(f"Station-off fault detected (severity={value}), going to OFF")
            self.fault_handler.handle_trip(self._current_state)
            self._go_to_off()
```

```python
# ============================================================
# hvps_controller.py — HVPS Supervisory Control
# ============================================================
import logging
import time
from epics import PV

from .hvps_plc_interface import HVPSPLCInterface
from ..common.config import HVPSConfig
from ..state_machine.station_states import StationState, HVPSLoopState, HVPSLoopControl

logger = logging.getLogger(__name__)

class HVPSController:
    """
    HVPS supervisory control loop.
    Replaces rf_hvps_loop.st from legacy system.
    
    Communicates with CompactLogix PLC via EtherNet/IP.
    Three modes: OFF, PROCESS (vacuum conditioning), ON (normal regulation)
    
    Key parameters from legacy rf_hvps_loop_defs.h:
    - HVPS_LOOP_MAX_INTERVAL = 10.0 seconds
    - HVPS_LOOP_MAX_VOLT_TOL = 10 iterations
    """
    
    MAX_INTERVAL = 10.0  # seconds, from HVPS_LOOP_MAX_INTERVAL
    MAX_VOLT_TOL = 10    # from HVPS_LOOP_MAX_VOLT_TOL
    
    def __init__(self, config: HVPSConfig, plc: HVPSPLCInterface):
        self.config = config
        self.plc = plc
        self.stn = config.station_name
        
        self._state = HVPSLoopState.OFF
        self._control = HVPSLoopControl.OFF
        self._prev_requested_voltage = 0.0
        self._volt_tol_count = 0
        self._cavv_lim_count = 0
        
        # PV connections
        self._setup_pvs()
    
    def _setup_pvs(self):
        s = self.stn
        # Readbacks from PLC
        self.pv_voltage_rbck = PV(f'{s}:HVPS:VOLT:RBCK')
        self.pv_voltage_ctrl = PV(f'{s}:HVPS:VOLT:CTRL.VAL')
        # Control parameters
        self.pv_min_voltage = PV(f'{s}:HVPS:VOLT:MIN')
        self.pv_max_voltage = PV(f'{s}:HVPS:VOLT:MAX')
        # LLRF9 readbacks
        self.pv_drive_power    = PV(f'{s}:KLYSDRIVFRWD:POWER')
        self.pv_klys_fwd_power = PV(f'{s}:KLYSFRWD:POWER')
        self.pv_gap_voltage    = PV(f'{s}:STNVOLT:GAP:SUM')
        # Status
        self.pv_loop_status = PV(f'{s}:HVPS:LOOP:STATUS')
        self.pv_loop_state  = PV(f'{s}:HVPS:LOOP:STATE')
    
    def update(self, station_state: StationState):
        """
        Called at ~1 Hz by the main loop.
        Implements the three-mode HVPS control from rf_hvps_loop.st.
        """
        # Check if station is off/park -> disable
        if station_state in (StationState.OFF, StationState.PARK):
            self._set_state(HVPSLoopState.OFF)
            return
        
        if self._control == HVPSLoopControl.PROC:
            self._update_process_mode(station_state)
        elif self._control == HVPSLoopControl.ON:
            self._update_on_mode(station_state)
        else:
            self._set_state(HVPSLoopState.OFF)
    
    def _update_on_mode(self, station_state: StationState):
        """
        Normal operation: adjust HVPS to maintain drive power setpoint.
        From rf_hvps_loop.st 'on' state.
        
        When direct loop is ON and station ON_CW:
          - Monitor drive power, adjust HVPS voltage inversely
          - delta = -delta_on_voltage (negative because higher HVPS = lower drive)
        When direct loop is OFF or station in TUNE:
          - delta = delta_tune_voltage (from gap voltage error)
        """
        # Read current values from LLRF9 and PLC
        readback = self.pv_voltage_rbck.get()
        drive_power = self.pv_drive_power.get()
        
        # Get delta voltage from EPICS calculation record
        # (The actual error calculation is done in EPICS calc records,
        #  preserving the legacy subroutine record approach)
        direct_loop_on = self._is_direct_loop_on()
        
        if station_state == StationState.ON_CW and direct_loop_on:
            delta = -self._get_delta_on_voltage()
        else:
            delta = self._get_delta_tune_voltage()
        
        # Check cavity voltage limit before increasing
        if self._is_gap_voltage_at_limit() and delta > 0:
            self._cavv_lim_count += 1
            if self._cavv_lim_count > self.MAX_VOLT_TOL:
                self._update_status('CAVV_LIM')
            return
        
        self._cavv_lim_count = 0
        self._apply_voltage_delta(delta)
    
    def _update_process_mode(self, station_state: StationState):
        """
        Vacuum processing mode.
        From rf_hvps_loop.st 'proc' state.
        
        Ramp voltage up slowly. If klystron power too high,
        cavity vacuum too high, or gap voltage too high, ramp down.
        """
        klys_fwd = self.pv_klys_fwd_power.get()
        max_klys = self.config.max_klystron_forward_power
        
        if klys_fwd > max_klys or self._is_gap_voltage_at_limit() or self._is_vacuum_bad():
            delta = self.config.delta_proc_voltage_down
        else:
            delta = self.config.delta_proc_voltage_up
        
        self._apply_voltage_delta(delta)
    
    def _apply_voltage_delta(self, delta: float):
        """
        Apply a voltage change with safety limits.
        Maps to HVPS_LOOP_SET_VOLTAGE macro from rf_hvps_loop_macs.h.
        """
        current = self.pv_voltage_ctrl.get()
        new_voltage = current + delta
        max_v = self.pv_max_voltage.get()
        min_v = self.pv_min_voltage.get()
        
        # Clamp to limits
        if new_voltage > max_v:
            new_voltage = max_v if delta > 0 else new_voltage
            self._update_status('VOLT_LIM')
        elif new_voltage < min_v and delta <= 0:
            new_voltage = min_v
        
        # Check readback tolerance
        readback = self.pv_voltage_rbck.get()
        if abs(readback - self._prev_requested_voltage) > self.config.allowed_voltage_diff:
            new_voltage = self._prev_requested_voltage
            self._volt_tol_count += 1
            if self._volt_tol_count > self.MAX_VOLT_TOL:
                self._update_status('VOLT_TOL')
            return
        
        self._volt_tol_count = 0
        self.plc.set_voltage(new_voltage)
        self._prev_requested_voltage = new_voltage
```

---

## 4. Station State Machine

### 4.1 Turn-On Sequence (OFF → ON_CW)

This is the most complex sequence, mapping to the legacy `go_on_cw` state in `rf_states.st`:

```
Step  Action                                    Legacy Equivalent                     New Owner
────  ──────────────────────────────────────    ──────────────────────────            ─────────
1     Validate all permits (MPS, PPS, etc.)     fault_noon check                      Python
2     Move tuners to ON home positions          cavtunehome processing                Python → Motor Record
3     Command HVPS PLC to close contactor       hvpstrig = SCRON                      Python → PLC
4     Wait for contactor confirmation           delay(HVPS_TRIG_DELAY)                Python
5     Set HVPS to minimum voltage               hvpswdefault = hvpsrdefault           Python → PLC
6     Command LLRF9 to initialize RF output     dacfctl = DACLOAD, dacs = DACON       Python → LLRF9
7     Enable LLRF9 RF output                    rfswitch = RFSWITCHON                 Python → LLRF9
8     Wait for LLRF9 to stabilize               delay(RFSWITCH_WAIT)                  Python
9     Set initial DAC counts in LLRF9           fastononcnts initialization           Python → LLRF9
10    Enable direct loop in LLRF9               directlpon sequence                   LLRF9 (Python triggers)
11    Wait for direct loop transient to settle  delay in s_direct_ramp                Python monitors LLRF9
12    Enable HVPS feedback loop                 HVPS loop starts                      Python
13    Ramp DAC counts and HVPS voltage          DAC loop + HVPS loop active           LLRF9 + Python
14    Enable comb loop (if configured)          comblp_ef handling                    LLRF9 (Python triggers)
15    Wait for gap voltage to reach setpoint    s_gv_up state                         Python monitors
16    Reset beam abort                          RESET_BMABTSUB macro                  Python → MPS
17    Log "In ON_CW" message                    MSGSUB                                Python logger
```

### 4.2 Fault Trip Sequence (any state → OFF)

```
Step  Action                                    Legacy Equivalent                     New Owner
────  ──────────────────────────────────────    ──────────────────────────            ─────────
1     Detect fault (severity change)            fault_stnoff monitor                  MPS PLC (fast) + Python
2     LLRF9 disables RF output                  Hardware permit removed               MPS → LLRF9 (hardware)
3     Force beam abort (if beam was on)         fba = 0 (force beam abort)            MPS PLC
4     Zero HVPS voltage request                 hvpswdefault = 0                      Python → PLC
5     Move tuners to PARK position              cavtunepark processing                Python → Motor Record
6     Capture fault data (waveforms)            rf_statesFF state set                 Python reads LLRF9 buffers
7     Log fault with timestamp                  faultfiles + timestamps               Python
8     Update station state to OFF               rbck = STATION_OFF                    Python
9     Start auto-reset timer (if enabled)       auto_reset logic                      Python
```

---

## 5. HVPS Control Interface

### 5.1 PLC Communication

The HVPS CompactLogix PLC (Allen-Bradley 5069-L320ER) communicates via EtherNet/IP:

```
Python/EPICS ←──EtherNet/IP──→ CompactLogix PLC ←──Analog I/O──→ HVPS Hardware
                                      │
                                      ├── 5069-OF8 (analog output) → HVPS voltage setpoint
                                      ├── 5069-IF8 (analog input) ← HVPS voltage readback
                                      ├── 5069-IY4 (analog input) ← HVPS current readback
                                      ├── 5069-IB16 (digital input) ← Status/faults
                                      ├── 5069-OX41 (relay output) → Contactor control
                                      └── Fiber optic ←→ MPS PLC
```

**From LLRFUpgradeTaskListRev3.docx, the PLC software interface requires:**
- Open/close 12.47 kV contactor
- Enable power supply (remove Enerpro fast and slow inhibits)
- Supply voltage setpoint at ≤1 Hz rate
- Report all analog data and digital status

### 5.2 HVPS Status Definitions

Preserved from legacy `rf_hvps_loop_defs.h` with additions for new hardware:

```python
class HVPSStatus(IntEnum):
    UNKNOWN   = 0   # Loop in unknown status
    GOOD      = 1   # Normal operation
    RFP_BAD   = 2   # LLRF9 not responding (was: RF Processor bad)
    CAVV_LIM  = 3   # Cavity voltage above limit
    OFF       = 4   # Loop is off
    VACM_BAD  = 5   # Bad vacuum
    POWR_BAD  = 6   # Klystron forward power bad
    GAPV_BAD  = 7   # Gap voltage bad
    GAPV_TOL  = 8   # Gap voltage out of tolerance
    VOLT_LIM  = 9   # At HVPS voltage limit
    STN_OFF   = 10  # Station is OFF or PARKed
    VOLT_TOL  = 11  # Readback differs from requested
    VOLT_BAD  = 12  # Readback HVPS voltage invalid
    DRIV_BAD  = 13  # Klystron drive power bad
    ON_FM     = 14  # Station in ON_FM mode
    DRIV_TOL  = 15  # Klystron drive power out of tolerance
    # NEW for upgrade:
    PLC_COMM  = 16  # PLC communication lost
    PLC_FAULT = 17  # PLC internal fault
```

---

## 6. Tuner Control System

### 6.1 Architecture Change: Partitioned Control

The tuner control splits between LLRF9 and Python/EPICS:

```
                 LLRF9 Domain                    Python/EPICS Domain
                 ────────────                    ───────────────────
  Cavity Probe → Phase Measurement →             
                 Phase Error Calc  →             
                 Delta Position    → [Ethernet] → Tuner Manager
                 Request                          ├── Validate delta (deadband, limits)
                                                  ├── Apply motion profile
                                                  ├── Command motor record
                                                  │   └── Motor Record → Galil → Stepper
                                                  ├── Monitor done-moving
                                                  ├── Read potentiometer
                                                  └── Load Angle Offset Loop
                                                      └── Adjust phase setpoints
```

### 6.2 Tuner Axis Class

```python
# ============================================================
# tuner_axis.py — Single Tuner Axis Control
# ============================================================
class TunerAxis:
    """
    Controls one cavity tuner stepper motor.
    Replaces one instance of rf_tuner_loop.st.
    
    Key parameters from Jim's doc:
    - 200 steps/rev motor (M093-FC11 or modern equivalent)
    - Gear ratio: 2 motor turns = 1 lead screw turn
    - Lead screw: 1/2-10 Acme → 1 turn = 2.54 mm
    - Legacy: 400 microsteps/rev (2 microsteps/step)
    - Upgraded: 3200+ microsteps/rev (16+ microsteps/step)
    - Legacy RDBD = 5 microsteps
    - DIST per microstep:
      - Legacy: 2.54mm / 800 = 3.175 µm
      - Upgrade (16 µstep): 2.54mm / 6400 = 0.397 µm
    """
    
    def __init__(self, config, cavity_num: int):
        self.cavity_num = cavity_num  # 1-4
        self.stn = config.station_name
        
        # Motion parameters
        self.deadband_usteps = config.tuner_deadband      # Default: 5 
        self.max_speed = config.tuner_max_speed            # steps/sec
        self.dist_per_ustep_mm = config.dist_per_ustep     # mm
        
        # State tracking
        self._done_moving = True
        self._meas_count = 0
        self._dmov_meas_count = 0
        self._nomov_count = 0
        self._nonfunc_count = 0
        
        self._setup_pvs()
    
    def _setup_pvs(self):
        s = self.stn
        c = self.cavity_num
        # Motor record PVs (EPICS standard motor record)
        self.pv_motor_val  = PV(f'{s}:CAV{c}TUNR:MOTOR.VAL')   # Commanded position
        self.pv_motor_rbv  = PV(f'{s}:CAV{c}TUNR:MOTOR.RBV')   # Readback position
        self.pv_motor_dmov = PV(f'{s}:CAV{c}TUNR:MOTOR.DMOV',   # Done moving
                                callback=self._on_dmov_change)
        self.pv_motor_hlm  = PV(f'{s}:CAV{c}TUNR:MOTOR.HLM')   # High limit
        self.pv_motor_llm  = PV(f'{s}:CAV{c}TUNR:MOTOR.LLM')   # Low limit
        self.pv_motor_rdbd = PV(f'{s}:CAV{c}TUNR:MOTOR.RDBD')   # Retry deadband
        
        # Potentiometer position (not motor record — separate ADC)
        self.pv_posn_pot   = PV(f'{s}:CAV{c}TUNR:POSN:POT')
        
        # Home positions
        self.pv_home_on    = PV(f'{s}:CAV{c}TUNR:POSN:ONHOME')
        self.pv_home_park  = PV(f'{s}:CAV{c}TUNR:POSN:PARKHOME')
        
        # Phase delta from LLRF9
        self.pv_phase_delta = PV(f'{s}:CAV{c}TUNR:PHASE:DELTA', 
                                  callback=self._on_phase_delta)
        
        # Status
        self.pv_loop_status = PV(f'{s}:CAV{c}TUNR:LOOP:STATUS')
        self.pv_posn_new    = PV(f'{s}:CAV{c}TUNR:POSN:NEW')
    
    def move_to_home(self, mode: str = 'on'):
        """
        Move tuner to home position.
        Replaces loop_reset state from rf_tuner_loop.st.
        Uses potentiometer for coarse positioning, then iterates.
        """
        if mode == 'park':
            home_pos = self.pv_home_park.get()
        else:
            home_pos = self.pv_home_on.get()
        
        # Iterative homing (from legacy LOOP_RESET_COUNT iterations)
        for attempt in range(3):  # LOOP_RESET_COUNT
            current_pos = self.pv_posn_pot.get()
            delta = home_pos - current_pos
            tolerance = self.pv_motor_rdbd.get() * 3  # LOOP_RESET_TOLS
            
            if abs(delta) < tolerance:
                logger.info(f"Tuner {self.cavity_num} at home position")
                return True
            
            # Calculate motor move
            motor_pos = self.pv_motor_rbv.get()
            self.pv_motor_val.put(motor_pos + delta)
            self._wait_for_move()
        
        logger.warning(f"Tuner {self.cavity_num} home position not reached")
        return False
    
    def apply_delta(self, delta_position: float):
        """
        Apply a position delta from LLRF9 tuner phase control.
        
        Implements deadband and limit checking from legacy tuner loop.
        LLRF9 sends the delta; we validate and execute.
        """
        if not self._done_moving:
            self._nomov_count += 1
            return
        
        # Deadband check (legacy: RDBD = 5 microsteps)
        if abs(delta_position) < self.deadband_usteps * self.dist_per_ustep_mm:
            return
        
        # Calculate new position
        current = self.pv_motor_rbv.get()
        new_pos = current + delta_position
        
        # Limit check
        hlm = self.pv_motor_hlm.get()
        llm = self.pv_motor_llm.get()
        if new_pos > hlm:
            new_pos = hlm
            self._update_status('DRV_LIMT')
        elif new_pos < llm:
            new_pos = llm
            self._update_status('DRV_LIMT')
        
        # Execute move
        self.pv_motor_val.put(new_pos)
        self.pv_posn_new.put(new_pos)
    
    def stop_and_init(self):
        """
        Stop and initialize: align internal counter with potentiometer.
        From Jim's doc: "does not move the tuner, rather it aligns its 
        internal step counter with the measured voltage from the potentiometer"
        """
        pot_position = self.pv_posn_pot.get()
        # Set motor record offset to align with potentiometer
        self.pv_motor_val.put(pot_position, wait=False)
        logger.info(f"Tuner {self.cavity_num} stop-and-init at pot={pot_position}")
```

### 6.3 Load Angle Offset Loop

```python
# ============================================================
# load_angle_offset.py — Cavity Power Balancing
# ============================================================
class LoadAngleOffsetLoop:
    """
    Slow loop that adjusts individual cavity tuning angles 
    to balance gap voltage across all 4 cavities.
    
    From Jim's doc: "The user sets a PV, for example 
    SRF1:CAV1:STRENGTH:CTRL, to select what fraction of the total 
    gap voltage should be contributed by each cavity. The feedback 
    loop then adjusts the phase setpoints to achieve this fraction."
    
    This loop runs in Python/EPICS (confirmed by Jim's doc as 
    "best suited for our EPICS application rather than LLRF9").
    Update rate: ~0.1 Hz (every 10 seconds)
    """
    
    def __init__(self, config):
        self.stn = config.station_name
        self._setup_pvs()
    
    def _setup_pvs(self):
        s = self.stn
        self.pv_strength_ctrl = [PV(f'{s}:CAV{i}:STRENGTH:CTRL') for i in range(1, 5)]
        self.pv_gap_voltage   = [PV(f'{s}:CAV{i}:GAP:VOLT') for i in range(1, 5)]
        self.pv_phase_offset  = [PV(f'{s}:CAV{i}TUNR:PHASE:OFFSET') for i in range(1, 5)]
    
    def update(self):
        """
        Adjust phase offsets to balance cavity contributions.
        Called every ~10 seconds during ON_CW operation.
        """
        # Read current gap voltages
        gap_voltages = [pv.get() for pv in self.pv_gap_voltage]
        total_gap = sum(gap_voltages)
        if total_gap <= 0:
            return
        
        # Read desired fractions
        desired_fractions = [pv.get() for pv in self.pv_strength_ctrl]
        frac_sum = sum(desired_fractions)
        if frac_sum <= 0:
            return
        desired_fractions = [f / frac_sum for f in desired_fractions]
        
        # Calculate errors and adjust phase offsets
        for i in range(4):
            actual_fraction = gap_voltages[i] / total_gap
            error = desired_fractions[i] - actual_fraction
            
            # Small proportional adjustment to phase offset
            # (tuning angle affects coupling and thus gap voltage)
            current_offset = self.pv_phase_offset[i].get()
            adjustment = error * self.config.load_angle_gain
            new_offset = current_offset + adjustment
            
            self.pv_phase_offset[i].put(new_offset)
```

---

## 7. Monitoring & Diagnostics

### 7.1 Slow Power Monitoring

From upgrade task list: "Need about 8 channels for slow power monitoring (circulator reflected power, load reflected powers, etc.)"

```python
class SlowPowerMonitor:
    """
    Monitors 8+ RF power channels not covered by LLRF9's 18 inputs.
    Uses MCL ZX47-40LN-S+ power detectors → ADC → EPICS.
    
    Channels:
    - Circulator reflected power
    - Load reflected powers (4 cavities)  
    - Spare channels for future use
    - Klystron collector power (for MPS)
    """
    
    CHANNELS = [
        'CIRCREFL:POWER',    # Circulator reflected
        'CAV1LOADREFL:POWER', # Cavity 1 load reflected
        'CAV2LOADREFL:POWER', # Cavity 2 load reflected
        'CAV3LOADREFL:POWER', # Cavity 3 load reflected
        'CAV4LOADREFL:POWER', # Cavity 4 load reflected
        'KLYSCOLL:POWER',     # Klystron collector (for MPS)
        'SPARE1:POWER',       # Spare
        'SPARE2:POWER',       # Spare
    ]
    
    def __init__(self, config):
        self.stn = config.station_name
        self.pvs = {ch: PV(f'{self.stn}:{ch}') for ch in self.CHANNELS}
        self.trip_levels = config.power_trip_levels
    
    def check_all(self) -> list:
        """Check all channels against trip levels. Returns list of faults."""
        faults = []
        for ch, pv in self.pvs.items():
            value = pv.get()
            if ch in self.trip_levels and value > self.trip_levels[ch]:
                faults.append((ch, value, self.trip_levels[ch]))
        return faults
```

### 7.2 Fault Data Capture

Replaces legacy `rf_statesFF` state set:

```python
class FaultDataCapture:
    """
    Captures waveform data from LLRF9 buffers on fault.
    Replaces the legacy fault file writing system from rf_states.st.
    
    Legacy captured from: RFP, CFM, GVF modules
    Upgrade captures from: LLRF9 internal buffers (history, diagnostic)
    """
    
    MAX_FAULTS = 10  # Rotating buffer
    
    def __init__(self, config):
        self.stn = config.station_name
        self.fault_dir = config.fault_data_directory
        self.fault_num = 0
    
    def capture_fault_data(self, fault_time):
        """
        Triggered when station trips. Captures:
        1. LLRF9 history buffers (I/Q waveforms for all channels)
        2. LLRF9 diagnostic buffers
        3. Current PV values snapshot
        4. Slow power monitor values
        """
        self.fault_num = (self.fault_num % self.MAX_FAULTS) + 1
        
        timestamp = fault_time.strftime('%Y%m%d_%H%M%S')
        fault_dir = f"{self.fault_dir}/fault_{self.fault_num:02d}_{timestamp}"
        os.makedirs(fault_dir, exist_ok=True)
        
        # Capture LLRF9 buffers
        self._capture_llrf9_history(fault_dir)
        self._capture_llrf9_diagnostics(fault_dir)
        
        # Capture PV snapshot
        self._capture_pv_snapshot(fault_dir)
        
        # Log fault
        logger.info(f"Fault data captured to {fault_dir}")
        
        return fault_dir
```

---

## 8. Fault Management & Safety

### 8.1 Safety Interlock Chain

```
  PPS ──────────┐
  SPEAR MPS ────┤
  Orbit Intlk ──┤
  RF MPS ───────┤──→ [MPS PLC] ──→ Permit to LLRF9 (hardware, fast)
  HVPS Fault ───┤                   Permit to HVPS PLC (fiber optic)
  Arc Detect ───┤
  LLRF9 Fault ──┘
                         │
                         └──→ [Python/EPICS] monitors all fault channels
                              Manages auto-reset, logging, operator notification
```

**Critical Design Rule**: The MPS PLC handles ALL fast fault responses through hardware interlocks. Python/EPICS is the supervisory layer that:
1. Monitors fault status
2. Logs fault events with timestamps
3. Captures diagnostic data
4. Manages auto-reset/recovery
5. Coordinates orderly shutdown sequences

### 8.2 Auto-Reset Logic

From legacy `rf_states.st` auto-reset behavior:

```python
class AutoResetManager:
    """
    Automatic fault reset and restart logic.
    From legacy rf_states.st lines 56-58: auto_reset logic.
    
    After a fault trip, if auto-reset is enabled:
    1. Wait a configurable delay
    2. Check if fault has cleared
    3. If cleared, attempt restart up to max_resets times
    4. If contactor status is bad, do NOT attempt auto-reset
       (from legacy: "Don't bother with auto-reset if the contactor
        status goes != NO_ALARM")
    """
    
    def __init__(self, config):
        self.enabled = config.auto_reset_enabled
        self.max_resets = config.max_resets  # Default: 3
        self.reset_delay = config.reset_delay  # seconds
        self.reset_count = 0
        self._last_fault_time = None
    
    def should_reset(self, fault_cleared: bool, contactor_ok: bool) -> bool:
        if not self.enabled:
            return False
        if not fault_cleared:
            return False
        if not contactor_ok:
            logger.info("Auto-reset skipped: contactor fault")
            return False
        if self.reset_count >= self.max_resets:
            logger.warning(f"Auto-reset exhausted ({self.max_resets} attempts)")
            return False
        
        elapsed = time.time() - self._last_fault_time
        if elapsed < self.reset_delay:
            return False
        
        self.reset_count += 1
        logger.info(f"Auto-reset attempt {self.reset_count}/{self.max_resets}")
        return True
```

### 8.3 Motion Controller Fault Handling

From Jim's doc: "We also need to have a well-defined startup and recovery of our stepper motor driver. We want the driver to behave properly if either it loses its power or its communication with the control system."

```python
class MotionControllerWatchdog:
    """
    Monitors communication with the motion controller.
    If communication is lost:
    1. Set tuner loop status to FAULT
    2. Notify LLRF9 (which may need to take action if cavity detuned)
    3. In worst case, initiate station shutdown
    """
    
    HEARTBEAT_INTERVAL = 2.0  # seconds
    MAX_MISSED = 3
    
    def __init__(self, config):
        self.missed_count = 0
        self.stn = config.station_name
        self.pv_comm_status = PV(f'{self.stn}:TUNR:CTRL:COMM')
    
    def check(self) -> bool:
        """Returns True if communication is OK"""
        try:
            # Ping motion controller via motor record
            status = self.pv_comm_status.get(timeout=1.0)
            if status is not None:
                self.missed_count = 0
                return True
        except Exception:
            pass
        
        self.missed_count += 1
        if self.missed_count >= self.MAX_MISSED:
            logger.error("Motion controller communication lost!")
            return False
        return True
```

---

## 9. Calibration System

### 9.1 Legacy vs Upgrade Calibration

The legacy `rf_calib.st` (2800+ lines) performed detailed octal DAC calibration for the analog RFP module. The LLRF9 has its **own internal calibration** system, so the upgrade calibration is fundamentally different:

| Calibration Type | Legacy (rf_calib.st) | Upgrade |
|-----------------|---------------------|---------|
| DAC offset nulling | SNL iterative | LLRF9 internal |
| Cavity demod coefficients | SNL (II, IQ, QI, QQ) | LLRF9 internal |
| Direct loop coefficients | SNL | LLRF9 internal |
| Comb loop coefficients | SNL | LLRF9 internal |
| Klystron modulator offsets | SNL | LLRF9 internal |
| RF modulator offsets | SNL | LLRF9 internal |
| System-level verification | Manual | **Python orchestration** |
| Power detector calibration | N/A | **Python** (new) |
| Motor position calibration | N/A | **Python** (new) |

```python
class CalibrationManager:
    """
    Orchestrates system-level calibration.
    Most detailed calibration is internal to LLRF9.
    Python handles:
    1. Triggering LLRF9 calibration sequences
    2. Verifying calibration results
    3. Calibrating external power detectors
    4. Calibrating motor positions (potentiometer alignment)
    5. Saving/restoring calibration data
    """
    
    def run_llrf9_calibration(self):
        """Trigger and monitor LLRF9 internal calibration"""
        pass
    
    def calibrate_power_detectors(self):
        """Calibrate MCL ZX47-40LN slow power detectors"""
        pass
    
    def calibrate_tuner_positions(self):
        """Align motor step counters with potentiometer readings"""
        for axis in self.tuner_axes:
            axis.stop_and_init()
```

---

## 10. EPICS PV Database Design

### 10.1 PV Naming Convention

Preserve legacy convention where possible: `SRF1:<SUBSYSTEM>:<SIGNAL>:<FIELD>`

New PVs for upgrade-specific functions use the same pattern:
- `SRF1:LLRF9:*` — LLRF9 interface PVs
- `SRF1:MPS:*` — MPS interface PVs
- `SRF1:TUNR:CTRL:*` — Motion controller PVs
- `SRF1:SLOWPWR:*` — Slow power monitoring PVs
- `SRF1:ARCDET:*` — Arc detector PVs

### 10.2 Key PV Groups

**Station State** (preserved from legacy):
```
SRF1:STN:STATE:CTRL      # Requested state (0-4)
SRF1:STN:STATE:RBCK      # Current state (0-4)
SRF1:STN:STATE:STRING     # State name string
SRF1:STN:RESET:CTRL       # Station reset command
SRF1:STN:RESET:COUNTER    # Auto-reset counter
```

**HVPS Control** (preserved + new PLC interface):
```
SRF1:HVPS:VOLT:CTRL.VAL   # Voltage setpoint to PLC
SRF1:HVPS:VOLT:RBCK       # Voltage readback from PLC
SRF1:HVPS:VOLT:MIN        # Minimum (turn-on) voltage
SRF1:HVPS:VOLT:MAX        # Maximum voltage
SRF1:HVPS:LOOP:STATUS     # Loop status (0-17)
SRF1:HVPS:LOOP:STATE      # Loop state (OFF/PROC/ON)
SRF1:HVPS:LOOP:CTRL       # Loop control mode
SRF1:HVPS:PLC:COMM        # PLC communication status (NEW)
SRF1:HVPSCONTACT:CLOSE:CTRL  # Contactor command (via PLC)
```

**Tuner Control** (template for CAV1-CAV4):
```
SRF1:CAV1TUNR:MOTOR.VAL    # Motor commanded position
SRF1:CAV1TUNR:MOTOR.RBV    # Motor readback position
SRF1:CAV1TUNR:MOTOR.DMOV   # Done moving flag
SRF1:CAV1TUNR:POSN:POT     # Potentiometer position
SRF1:CAV1TUNR:POSN:ONHOME  # ON home position
SRF1:CAV1TUNR:POSN:PARKHOME # PARK home position
SRF1:CAV1TUNR:PHASE:DELTA  # Phase delta from LLRF9
SRF1:CAV1TUNR:PHASE:OFFSET # Load angle offset
SRF1:CAV1TUNR:LOOP:STATUS  # Tuner loop status
SRF1:CAV1:STRENGTH:CTRL    # Desired gap voltage fraction
SRF1:CAV1:GAP:VOLT         # Measured gap voltage
```

**LLRF9 Interface** (new):
```
SRF1:LLRF9:RF:ENABLE       # RF output enable
SRF1:LLRF9:STATUS          # Overall LLRF9 status
SRF1:LLRF9:DIRECTLOOP:CTRL # Direct loop control
SRF1:LLRF9:COMBLOOP:CTRL   # Comb loop control
SRF1:LLRF9:GAPVOLT:SETPT   # Gap voltage setpoint
SRF1:LLRF9:DRIVPWR:RBCK    # Drive power readback
SRF1:LLRF9:COMM:STATUS     # Communication status
```

---

## 11. Implementation Plan

### 11.1 Phased Approach

```
Phase 1: Foundation (Months 1-2)
├── Set up Linux IOC platform
├── Implement EPICS PV database
├── Build Python framework (common/, config/)
├── Implement PLC communication layer (EtherNet/IP)
├── Basic LLRF9 communication interface
└── Unit test framework

Phase 2: HVPS Control (Months 2-3)
├── Implement HVPSController (all 3 modes)
├── Implement HVPS PLC interface
├── Test on B44 Test Stand (from upgrade task list)
├── Implement contactor control
└── Integration test with PLC

Phase 3: Station State Machine (Months 3-4)
├── Implement StationController
├── Implement turn-on sequence
├── Implement fault trip sequence
├── Implement auto-reset logic
├── Integration test with LLRF9 + HVPS

Phase 4: Tuner System (Months 4-6)
├── Install motion controller (Galil/other)
├── Configure EPICS motor records
├── Implement TunerAxis and TunerManager
├── Implement load angle offset loop
├── Test on spare cavity first (from upgrade task list)
├── Commission on actual cavities

Phase 5: Monitoring & Diagnostics (Months 5-6)
├── Implement slow power monitoring
├── Implement arc detection interface
├── Implement fault data capture
├── Implement structured logging
└── Operator interface integration

Phase 6: Commissioning (Months 6-8)
├── Parallel operation with legacy system
├── Performance validation
├── Operator training
├── Documentation completion
└── Full cutover
```

### 11.2 Testing Strategy

**Simulation Environment**: Build a simulated RF station in Python that mimics the behavior of the real system (cavity response, klystron gain curve, tuner mechanics). This allows full software testing without hardware.

**Hardware-in-Loop**: Test with actual hardware incrementally:
1. PLC communication → test stand
2. LLRF9 communication → bench test
3. Motion controller → spare cavity
4. Full integration → SPEAR3 (with rollback plan)

### 11.3 Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| LLRF9 API uncertainty | Early prototyping of communication interface; leverage Dimtel commissioning support |
| Motion controller selection | Test multiple candidates (Galil, Domenico/Dunning solution); have backup plan |
| PLC timing | Validate 1 Hz setpoint update rate is sufficient; test on B44 stand first |
| Real-time performance | Python + EPICS is proven for ~1 Hz loops; profile and optimize if needed |
| Rollback | Maintain legacy system in parallel; document exact rollback procedure |
| Tuner reliability | Jim's doc: "Have been unable to prove reliability"; extensive bench testing required |

### 11.4 Open Questions Requiring Resolution

1. **LLRF9 API details**: What is the exact communication protocol? EPICS Channel Access, custom TCP, or REST API?
2. **LLRF9 tuner interface**: Does LLRF9 provide delta-move commands or absolute position targets for tuners?
3. **Motion controller selection**: Galil DMC-4143 vs. Domenico/Mike Dunning solution — final decision needed
4. **Motion profiles**: Jim's doc notes legacy only used uniform pulse rates. Need to test acceleration/deceleration profiles on actual cavity.
5. **HVPS PLC EPICS driver**: Use pycomm3, opcua, or custom EtherNet/IP driver for CompactLogix?
6. **Slow power monitor ADC**: What ADC hardware will digitize the MCL detector outputs?
7. **LLRF9 calibration workflow**: What manual steps are required? How does operator interact?
8. **Fault buffer format**: What is the format/size of LLRF9 fault history buffers?

---

## Conclusion

This software design provides a complete architecture for the upgraded SPEAR3 LLRF control system. The key design principles are:

1. **LLRF9 is the inner loop** — all fast RF control delegates to hardware
2. **Python/EPICS is the coordinator** — state machine, HVPS supervision, tuner management
3. **PLCs handle safety** — MPS and HVPS interlocks are hardware-based
4. **Preserve legacy behavior** — same state machine, same control algorithms, same PV names where possible
5. **Improve where possible** — better tuner resolution, modern logging, fault capture, diagnostics

The design maps every legacy function to its new owner, preserves all operational behaviors documented in Jim's operational document, and accounts for the specific hardware upgrades described in the LLRFUpgradeTaskListRev3.
