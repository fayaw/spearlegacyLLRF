# SPEAR3 LLRF Upgrade — Software Design Document

**Document ID**: SPEAR3-LLRF-SDD-001
**Revision**: R0
**Date**: March 12, 2026
**Author**: LLRF Upgrade Software Team
**Classification**: Software Architecture & Detailed Design Reference
**Status**: Initial Draft

---

## Purpose and Scope

This Software Design Document (SDD) defines the complete software architecture for the SPEAR3 LLRF Upgrade Project. It specifies the Python/PyEPICS coordinator application that replaces the six legacy SNL (State Notation Language) programs running on VxWorks with a modern, maintainable, and testable Python application communicating via EPICS Channel Access.

This document is derived from the Physical Design Report (SPEAR3-LLRF-PDR-001), the LLRF9 System & Software Report, the HVPS Engineering Technical Note, the Interface Chassis Design Report, the Klystron Heater Subsystem Upgrade, and the HVPS-PPS Interface Technical Document.

**Key Principle**: The Python coordinator is a **supervisory control layer** operating at ~1 Hz. It is explicitly **NOT** in any fast safety path. All safety-critical protection is handled by hardware: the LLRF9 FPGA interlocks (<1 μs), the Interface Chassis hardware AND-logic (<1 μs), and the Kly MPS PLC (~ms). The Python coordinator handles sequencing, coordination, diagnostics, and operator interface.

---

## Table of Contents

1. [System Context and Constraints](#1-system-context-and-constraints)
2. [Software Architecture Overview](#2-software-architecture-overview)
3. [Module Decomposition](#3-module-decomposition)
4. [Core Infrastructure](#4-core-infrastructure)
5. [Station State Machine](#5-station-state-machine)
6. [HVPS Supervisory Controller](#6-hvps-supervisory-controller)
7. [Tuner Manager](#7-tuner-manager)
8. [Load Angle Controller](#8-load-angle-controller)
9. [Fault Manager](#9-fault-manager)
10. [Waveform Buffer Interface](#10-waveform-buffer-interface)
11. [Heater Controller Interface](#11-heater-controller-interface)
12. [Calibration System](#12-calibration-system)
13. [Configuration Management](#13-configuration-management)
14. [Operator Interface](#14-operator-interface)
15. [EPICS PV Contract Reference](#15-epics-pv-contract-reference)
16. [Concurrency and Threading Model](#16-concurrency-and-threading-model)
17. [Error Handling and Recovery](#17-error-handling-and-recovery)
18. [Testing Strategy](#18-testing-strategy)
19. [Deployment and Operations](#19-deployment-and-operations)
20. [Legacy Code Mapping](#20-legacy-code-mapping)
21. [Appendix: PV Namespace Registry](#21-appendix-pv-namespace-registry)

---

## 1. System Context and Constraints

### 1.1 Software Boundary

The Python coordinator sits at **Layer 4** of the protection hierarchy and communicates exclusively via EPICS Channel Access over Ethernet:

| Protection Layer | Subsystem | Response Time | Software Role |
|------------------|-----------|---------------|---------------|
| Layer 1 | LLRF9 FPGA | <1 μs | None (autonomous hardware) |
| Layer 2 | Interface Chassis | <1 μs | None (autonomous hardware) |
| Layer 3 | Kly MPS PLC | ~ms | Monitor only (reads PVs) |
| **Layer 4** | **Python Coordinator** | **~1 s** | **Supervisory control, sequencing, diagnostics** |

**Invariant**: If the Python coordinator crashes, Ethernet fails, or any software component hangs, all hardware protection continues to function. The system enters a safe, stable state (RF drive disabled, HVPS inhibited) and waits for operator intervention.

### 1.2 Hardware Interfaces (All via EPICS)

| Subsystem | IOC Type | PV Prefix | Update Rate | Protocol |
|-----------|----------|-----------|-------------|----------|
| LLRF9 Unit 1 | Built-in Linux IOC | `LLRF1:` | 10 Hz scalars | EPICS CA |
| LLRF9 Unit 2 | Built-in Linux IOC | `LLRF2:` | 10 Hz scalars | EPICS CA |
| HVPS CompactLogix | External gateway | `SRF1:HVPS:` | ~1 Hz | EPICS CA |
| Kly MPS ControlLogix | External gateway | `SRF1:MPS:` | ~1 Hz | EPICS CA |
| Motion Controller (Galil) | Motor record IOC | `SRF1:MTR:` | On demand | EPICS CA |
| Waveform Buffer | Dedicated IOC | `SRF1:WFBUF:` | ~1 Hz / event | EPICS CA |
| Heater Controller | Dedicated IOC | `SRF1:HTR:` | 10 Hz | EPICS CA |

### 1.3 Design Constraints

1. **No safety dependency on software**: Python crash must not affect hardware protection
2. **All PV access via EPICS CA**: No direct hardware I/O, serial, or fieldbus from Python
3. **~1 Hz supervisory rate**: Do not poll faster than hardware IOC update rates
4. **EPICS CA best practices**: Use monitors (not polling) for frequently-read PVs; batch reads; `EPICS_CA_MAX_ARRAY_BYTES=26000000`
5. **Configuration-driven**: All operational parameters in YAML/JSON configuration files
6. **Testable with mocks**: Every hardware interface abstracted behind an interface class
7. **Structured logging**: All events timestamped and structured for post-mortem analysis
8. **Graceful degradation**: If a non-critical subsystem is unavailable, the system degrades gracefully

### 1.4 Legacy Software Mapping

| Legacy SNL Program | Lines | Replacement Module | Notes |
|--------------------|-------|--------------------|-------|
| `rf_states.st` | 2,227 | `state_machine.py` | Master station state machine |
| `rf_hvps_loop.st` | 343 | `hvps_controller.py` | HVPS supervisory control loop |
| `rf_tuner_loop.st` | 555 | `tuner_manager.py` | 4-cavity tuner management |
| `rf_dac_loop.st` | 290 | *Eliminated* | LLRF9 handles internally via setpoint profiles |
| `rf_calib.st` | 2,800+ | `calibration.py` | Reduced scope — LLRF9 digital calibration |
| `rf_msgs.st` | 352 | `fault_manager.py` + `event_logger.py` | Structured logging replaces CAMAC TAXI monitoring |


---

## 2. Software Architecture Overview

### 2.1 Layered Architecture

The software is organized into four layers, from hardware-facing (bottom) to operator-facing (top):

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        LAYER 4: PRESENTATION                            │
│  EDM Panels │ Web Dashboard │ CLI Tools │ EPICS Archiver Integration    │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │ PV reads/writes
┌──────────────────────────────────┴──────────────────────────────────────┐
│                      LAYER 3: COORDINATION                              │
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │ Station      │  │ HVPS         │  │ Tuner        │  │ Load Angle │  │
│  │ State Machine│  │ Controller   │  │ Manager (x4) │  │ Controller │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └─────┬──────┘  │
│         │                 │                 │                │          │
│  ┌──────┴─────────────────┴─────────────────┴────────────────┴───────┐  │
│  │                    Fault Manager (Event Bus)                      │  │
│  └──────┬─────────────────┬─────────────────┬────────────────┬───────┘  │
│         │                 │                 │                │          │
│  ┌──────┴───────┐  ┌──────┴───────┐  ┌──────┴───────┐  ┌────┴───────┐  │
│  │ Waveform Buf │  │ Heater Ctrl  │  │ Calibration  │  │ Config Mgr │  │
│  │ Interface    │  │ Interface    │  │ System       │  │            │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └────────────┘  │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │ Internal API calls
┌──────────────────────────────────┴──────────────────────────────────────┐
│                    LAYER 2: HARDWARE ABSTRACTION                        │
│                                                                         │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐            │
│  │ LLRF9Interface │  │ HVPSInterface  │  │ MPSInterface   │            │
│  │ (x2 units)     │  │                │  │                │            │
│  └────────┬───────┘  └────────┬───────┘  └────────┬───────┘            │
│  ┌────────┴───────┐  ┌────────┴───────┐  ┌────────┴───────┐            │
│  │ MotorInterface │  │ WaveformBuf    │  │ HeaterInterface│            │
│  │ (Galil x4)     │  │ Interface      │  │                │            │
│  └────────────────┘  └────────────────┘  └────────────────┘            │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │ EPICS Channel Access
┌──────────────────────────────────┴──────────────────────────────────────┐
│                     LAYER 1: EPICS COMMUNICATION                        │
│                                                                         │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │ EPICSBridge: PV connection management, monitor subscriptions,     │  │
│  │              batch reads/writes, timeout handling, reconnection    │  │
│  └────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Design Principles

1. **Separation of Concerns**: Each module has a single, well-defined responsibility
2. **Dependency Injection**: All hardware interfaces are injected, enabling mock substitution
3. **Event-Driven Communication**: Internal event bus for fault propagation and coordination
4. **Configuration-Driven**: Operational parameters loaded from versioned YAML files
5. **Defensive Programming**: All PV reads have timeouts; all state transitions are validated
6. **Idempotent Operations**: State machine transitions can be safely retried
7. **Observable State**: All internal state exposed as EPICS PVs for monitoring and archiving

### 2.3 Technology Stack

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Language | Python 3.10+ | Team expertise, PyEPICS ecosystem, rapid development |
| EPICS Library | PyEPICS (epics module) | Mature, well-tested, supports monitors and callbacks |
| Configuration | YAML (PyYAML) | Human-readable, supports comments, hierarchical |
| Logging | Python `logging` + structured JSON | Standard library, archiver-compatible |
| Testing | pytest + unittest.mock | Standard Python testing, excellent mock support |
| Process Management | systemd | Standard Linux service management |
| Documentation | Sphinx + autodoc | Auto-generated API docs from docstrings |

---

## 3. Module Decomposition

### 3.1 Directory Structure

```
spear3_llrf/
├── __init__.py
├── main.py                     # Application entry point
├── config/
│   ├── __init__.py
│   ├── schema.py               # Configuration schema definitions
│   ├── loader.py               # YAML config loader with validation
│   └── defaults/
│       ├── station.yaml        # Station-level defaults
│       ├── llrf9.yaml          # LLRF9 unit configuration
│       ├── hvps.yaml           # HVPS operating parameters
│       ├── tuners.yaml         # Tuner PID gains, limits
│       └── heater.yaml         # Heater operating profiles
├── core/
│   ├── __init__.py
│   ├── epics_bridge.py         # EPICS CA connection management
│   ├── event_bus.py            # Internal publish/subscribe event system
│   ├── base_controller.py      # Abstract base for all control modules
│   ├── base_interface.py       # Abstract base for hardware interfaces
│   ├── pv_monitor.py           # PV subscription and caching layer
│   └── types.py                # Shared enums, dataclasses, type definitions
├── interfaces/
│   ├── __init__.py
│   ├── llrf9_interface.py      # LLRF9 unit hardware abstraction
│   ├── hvps_interface.py       # HVPS CompactLogix PLC interface
│   ├── mps_interface.py        # Kly MPS ControlLogix PLC interface
│   ├── motor_interface.py      # Galil DMC-4143 motor record interface
│   ├── waveform_buf_interface.py  # Waveform Buffer System interface
│   └── heater_interface.py     # Klystron heater SCR controller interface
├── controllers/
│   ├── __init__.py
│   ├── state_machine.py        # Station state machine (replaces rf_states.st)
│   ├── hvps_controller.py      # HVPS supervisory loop (replaces rf_hvps_loop.st)
│   ├── tuner_manager.py        # 4-cavity tuner management (replaces rf_tuner_loop.st)
│   ├── load_angle_controller.py # Gap voltage balancing
│   ├── fault_manager.py        # Centralized fault detection and recovery
│   ├── heater_controller.py    # Heater sequencing and coordination
│   └── calibration.py          # System calibration (replaces rf_calib.st)
├── diagnostics/
│   ├── __init__.py
│   ├── event_logger.py         # Structured event logging
│   ├── waveform_capture.py     # Waveform readout and archival
│   ├── performance_monitor.py  # Control loop timing and health metrics
│   └── fault_analyzer.py       # Post-mortem fault sequence analysis
├── ui/
│   ├── __init__.py
│   ├── pv_server.py            # caproto-based PV server for coordinator status
│   └── edm_support.py          # EDM panel macro and display support
├── tests/
│   ├── __init__.py
│   ├── conftest.py             # Shared test fixtures and mock factories
│   ├── mocks/
│   │   ├── __init__.py
│   │   ├── mock_llrf9.py       # Simulated LLRF9 IOC responses
│   │   ├── mock_hvps.py        # Simulated HVPS PLC responses
│   │   ├── mock_mps.py         # Simulated MPS PLC responses
│   │   ├── mock_motor.py       # Simulated motor record responses
│   │   └── mock_waveform.py    # Simulated waveform buffer responses
│   ├── test_state_machine.py
│   ├── test_hvps_controller.py
│   ├── test_tuner_manager.py
│   ├── test_fault_manager.py
│   ├── test_calibration.py
│   └── test_integration.py     # End-to-end with all mocks
└── scripts/
    ├── start_coordinator.sh    # systemd-compatible startup script
    ├── status.py               # Quick system status check
    └── config_validate.py      # Configuration file validation tool
```

### 3.2 Module Dependency Graph

```
main.py
  └── Coordinator (orchestrator)
        ├── ConfigManager ──────────── config/loader.py
        ├── EPICSBridge ────────────── core/epics_bridge.py
        ├── EventBus ───────────────── core/event_bus.py
        ├── FaultManager ───────────── controllers/fault_manager.py
        │     └── EventLogger ──────── diagnostics/event_logger.py
        ├── StateMachine ───────────── controllers/state_machine.py
        │     ├── LLRF9Interface(x2) ── interfaces/llrf9_interface.py
        │     ├── HVPSInterface ────── interfaces/hvps_interface.py
        │     ├── MPSInterface ─────── interfaces/mps_interface.py
        │     └── HeaterInterface ──── interfaces/heater_interface.py
        ├── HVPSController ─────────── controllers/hvps_controller.py
        │     ├── LLRF9Interface
        │     └── HVPSInterface
        ├── TunerManager ───────────── controllers/tuner_manager.py
        │     ├── LLRF9Interface
        │     └── MotorInterface(x4) ── interfaces/motor_interface.py
        ├── LoadAngleController ────── controllers/load_angle_controller.py
        │     ├── LLRF9Interface
        │     └── TunerManager
        ├── HeaterController ───────── controllers/heater_controller.py
        │     └── HeaterInterface
        ├── WaveformBufInterface ───── interfaces/waveform_buf_interface.py
        ├── Calibration ────────────── controllers/calibration.py
        │     └── LLRF9Interface(x2)
        └── PVServer ───────────────── ui/pv_server.py
```


---

## 4. Core Infrastructure

### 4.1 EPICS Bridge (`core/epics_bridge.py`)

The EPICS Bridge provides a managed connection layer for all EPICS Channel Access communication. It handles connection management, monitor subscriptions, value caching, and graceful reconnection.

```python
class EPICSBridge:
    """Central EPICS Channel Access connection manager.
    
    Responsibilities:
    - Manage CA context and connections to all IOCs
    - Provide cached PV value access via monitors
    - Handle connection timeouts and automatic reconnection
    - Support batch PV reads and writes
    - Track connection health metrics
    """
    
    def __init__(self, config: dict):
        self.ca_addr_list: str          # IOC IP addresses
        self.ca_max_array_bytes: int    # 26000000 for waveform data
        self.connection_timeout: float  # Default 5.0 seconds
        self.pv_cache: Dict[str, PVCacheEntry]  # Cached monitor values
        self.connection_status: Dict[str, bool]  # Per-IOC connection state
    
    def connect(self) -> None: ...
    def disconnect(self) -> None: ...
    def get(self, pv_name: str, timeout: float = 5.0) -> Any: ...
    def put(self, pv_name: str, value: Any, wait: bool = False) -> None: ...
    def monitor(self, pv_name: str, callback: Callable) -> int: ...
    def get_cached(self, pv_name: str) -> Optional[Any]: ...
    def batch_get(self, pv_names: List[str]) -> Dict[str, Any]: ...
    def is_connected(self, prefix: str) -> bool: ...
```

### 4.2 Event Bus (`core/event_bus.py`)

The internal event bus enables loose coupling between modules. Events propagate asynchronously from any publisher to all registered subscribers.

```python
@dataclass
class Event:
    type: EventType          # Enum: FAULT, STATE_CHANGE, ALARM, INFO, ...
    source: str              # Module name that generated the event
    timestamp: datetime      # Event timestamp
    data: Dict[str, Any]     # Event-specific payload
    severity: Severity       # CRITICAL, WARNING, INFO

class EventBus:
    """Publish/subscribe event system for inter-module communication."""
    
    def subscribe(self, event_type: EventType, callback: Callable) -> None: ...
    def publish(self, event: Event) -> None: ...
    def publish_fault(self, source: str, fault_code: str, details: dict) -> None: ...
    def publish_state_change(self, source: str, old_state: str, new_state: str) -> None: ...
```

**Event Types**:

| Event Type | Publisher | Subscribers | Purpose |
|-----------|-----------|-------------|---------|
| `FAULT` | Any module | FaultManager, StateMachine | Hardware or software fault detected |
| `STATE_CHANGE` | StateMachine | All controllers | Station state transition |
| `HVPS_READBACK` | HVPSController | StateMachine, Diagnostics | HVPS voltage/current update |
| `TUNER_STATUS` | TunerManager | LoadAngleCtrl, Diagnostics | Per-cavity tuner status |
| `INTERLOCK_TRIP` | FaultManager | StateMachine, EventLogger | Interface Chassis interlock event |
| `MPS_PERMIT` | MPSInterface | StateMachine, FaultManager | MPS permit state change |
| `HEATER_STATUS` | HeaterController | StateMachine | Heater mode/temp update |
| `CONFIG_CHANGE` | ConfigManager | All modules | Configuration parameter updated |

### 4.3 Base Controller (`core/base_controller.py`)

All control modules inherit from a common base class that provides lifecycle management, configuration access, and event integration.

```python
class BaseController(ABC):
    """Abstract base class for all control modules."""
    
    def __init__(self, name: str, event_bus: EventBus, config: dict):
        self.name = name
        self.event_bus = event_bus
        self.config = config
        self.is_running = False
        self.cycle_count = 0
        self.last_cycle_time = 0.0
    
    @abstractmethod
    def initialize(self) -> bool: ...    # Connect to hardware, validate config
    
    @abstractmethod
    def execute_cycle(self) -> None: ...  # Single control cycle (~1 Hz)
    
    @abstractmethod
    def shutdown(self) -> None: ...       # Graceful shutdown
    
    def run(self) -> None:
        """Main loop: execute_cycle at configured rate with error handling."""
        while self.is_running:
            try:
                t0 = time.monotonic()
                self.execute_cycle()
                self.last_cycle_time = time.monotonic() - t0
                self.cycle_count += 1
                sleep(max(0, self.period - self.last_cycle_time))
            except EPICSTimeout:
                self.event_bus.publish_fault(self.name, "EPICS_TIMEOUT", {})
            except Exception as e:
                self.event_bus.publish_fault(self.name, "UNHANDLED", {"error": str(e)})
```

### 4.4 Shared Types (`core/types.py`)

```python
class StationState(Enum):
    OFF = "OFF"
    STANDBY = "STANDBY"
    PARK = "PARK"
    TUNE = "TUNE"
    ON_CW = "ON_CW"
    FAULT = "FAULT"

class HVPSState(Enum):
    OFF = "OFF"
    READY = "READY"
    RAMPING = "RAMPING"
    REGULATING = "REGULATING"
    FAULT = "FAULT"

class TunerState(Enum):
    PARKED = "PARKED"
    HOMING = "HOMING"
    TUNING = "TUNING"
    LOCKED = "LOCKED"
    FAULT = "FAULT"

class HeaterMode(Enum):
    OFF = "OFF"
    STANDBY = "STANDBY"
    WARMUP = "WARMUP"
    OPERATING = "OPERATING"
    COOLDOWN = "COOLDOWN"

@dataclass
class CavityReadback:
    """10 Hz readback data for a single cavity from LLRF9."""
    cavity_id: int               # 1-4
    probe_amplitude: float       # From CHn:AMP
    probe_phase: float           # From CHn:PHASE (degrees)
    forward_power: float         # From forward channel AMP
    reflected_power: float       # From Unit 2 reflected channel
    tuner_position: float        # From motor record RBV
    timestamp: datetime

@dataclass
class HVPSReadback:
    """~1 Hz readback from HVPS CompactLogix PLC."""
    voltage: float               # kV (negative polarity)
    current: float               # Amperes
    status_ready: bool
    contactor_closed: bool
    interlock_summary: int       # Bit field
    temperature: float           # SCR temperature
```

---

## 5. Station State Machine

### 5.1 State Definitions

The station state machine replaces the legacy `rf_states.st` (2,227 lines). It manages the RF station through well-defined operating states.

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                     FAULT (from any state)                  │
                    │  Entry: log fault, disable RF drive, record waveforms      │
                    │  Exit: operator acknowledges, MPS reset                     │
                    └────────────┬────────────────────────────────────────────────┘
                                 │ Operator Reset + MPS Clear
                                 ▼
    ┌─────────┐   enable   ┌──────────┐   park_cmd   ┌──────────┐
    │   OFF   │ ─────────► │ STANDBY  │ ───────────► │   PARK   │
    │         │ ◄───────── │          │ ◄─────────── │          │
    └─────────┘   disable  └──────────┘   standby    └────┬─────┘
                                                          │ tune_cmd
                                                          ▼
                                                     ┌──────────┐
                                                     │   TUNE   │
                                                     │          │
                                                     └────┬─────┘
                                                          │ rf_on_cmd
                                                          ▼
                                                     ┌──────────┐
                                                     │  ON_CW   │
                                                     │          │
                                                     └──────────┘
```

### 5.2 State Descriptions

| State | Description | Active Subsystems | Entry Conditions |
|-------|-------------|-------------------|------------------|
| **OFF** | All systems de-energized. Safe for maintenance. | None | Default / operator command |
| **STANDBY** | Heater warming, HVPS ready to energize. MPS permit active. | Heater (WARMUP→OPERATING), MPS monitoring | Heater available, MPS permit present |
| **PARK** | Tuners retracted to park positions. HVPS off. | Tuner motors (parking), Heater (OPERATING) | Tuners accessible, heater at operating temp |
| **TUNE** | Tuners moving to ON positions and locking to cavity phase. HVPS ramping. | Tuners (HOMING→TUNING→LOCKED), HVPS (RAMPING), LLRF9 monitoring | All tuners at park, HVPS ready |
| **ON_CW** | Full RF operation. Feedback loop closed. Beam permitted. | All subsystems active: LLRF9 feedback, HVPS regulating, tuners locked, heater operating | All tuners locked, HVPS at target, LLRF9 interlocks clear |
| **FAULT** | Fault condition. RF drive disabled by hardware. Waiting for diagnosis and reset. | Diagnostic data capture active. All control loops suspended. | Any hardware interlock trip or critical software fault |

### 5.3 State Transition Matrix

| From \ To | OFF | STANDBY | PARK | TUNE | ON_CW | FAULT |
|-----------|-----|---------|------|------|-------|-------|
| **OFF** | — | ✓ | — | — | — | — |
| **STANDBY** | ✓ | — | ✓ | — | — | ✓ |
| **PARK** | ✓ | ✓ | — | ✓ | — | ✓ |
| **TUNE** | ✓ | — | ✓ | — | ✓ | ✓ |
| **ON_CW** | ✓ | — | — | ✓ | — | ✓ |
| **FAULT** | ✓ | — | — | — | — | — |

### 5.4 Turn-On Sequence (TUNE → ON_CW)

This is the most complex transition, replacing the legacy `rf_states.st` turn-on logic:

```python
async def transition_tune_to_on_cw(self):
    """Turn on RF — replaces legacy fast-on / slow-on sequence."""
    
    # 1. Pre-checks
    assert all(t.state == TunerState.LOCKED for t in self.tuners)
    assert self.hvps.state == HVPSState.REGULATING
    assert self.mps.permit_active
    assert self.heater.mode == HeaterMode.OPERATING
    
    # 2. Configure LLRF9 Unit 1 for closed-loop operation
    self.llrf9_unit1.set_feedback_mode("BRD1", "closed")
    
    # 3. Load setpoint profile into LLRF9 ramp system
    #    (Replaces legacy fast-on DAC values from rf_states.st)
    profile = self.config["turn_on_profile"]  # 512-point amp/phase profile
    self.llrf9_unit1.load_setpoint_profile("BRD1", profile)
    
    # 4. Trigger LLRF9 ramp — hardware executes the profile
    #    Each step: 70 μs to 37 ms (total ramp: seconds)
    self.llrf9_unit1.trigger_ramp("BRD1")
    
    # 5. Monitor ramp progress via scalar readbacks
    while not self.llrf9_unit1.ramp_complete("BRD1"):
        readback = self.llrf9_unit1.get_scalar_readbacks("BRD1")
        if readback["amplitude"] < self.config["ramp_abort_threshold"]:
            raise RampAbortError("Amplitude below threshold during ramp")
        await asyncio.sleep(0.1)
    
    # 6. Verify stable operation
    await self._verify_stable_operation(duration=5.0)
    
    # 7. Enable load angle balancing
    self.load_angle_controller.enable()
    
    # 8. Transition complete
    self._set_state(StationState.ON_CW)
    self.event_bus.publish_state_change(self.name, "TUNE", "ON_CW")
```

### 5.5 Fault Entry

Any state can transition to FAULT. The fault entry is triggered by the FaultManager, not by the StateMachine directly:

```python
def handle_fault_event(self, event: Event):
    """Called by EventBus when FaultManager publishes a FAULT event."""
    previous_state = self.current_state
    self._set_state(StationState.FAULT)
    
    # Hardware has already acted (Interface Chassis removed permits)
    # Software actions:
    self.hvps_controller.suspend()
    self.tuner_manager.suspend_all()
    self.load_angle_controller.disable()
    
    # Capture diagnostic data
    self.diagnostics.capture_fault_snapshot(event)
    
    self.event_bus.publish_state_change(self.name, previous_state.value, "FAULT")
```


---

## 6. HVPS Supervisory Controller

### 6.1 Purpose

The HVPS Supervisory Controller replaces `rf_hvps_loop.st` (343 lines). It manages the HVPS voltage setpoint to maintain desired klystron drive power. The actual voltage regulation is performed by the CompactLogix PLC; this Python module provides the outer supervisory loop.

### 6.2 Control Algorithm

```python
class HVPSController(BaseController):
    """HVPS supervisory control loop (~1 Hz).
    
    Reads klystron forward power from LLRF9, computes desired HVPS voltage
    adjustment, and sends setpoint to CompactLogix PLC via EPICS.
    """
    
    def execute_cycle(self):
        # 1. Read klystron forward power from LLRF9 Unit 1, BRD3
        kly_fwd_power = self.llrf9.get_scalar_amplitude("BRD3", channel=2)
        
        # 2. Read current HVPS state
        hvps_readback = self.hvps.get_readback()
        
        # 3. Compute voltage adjustment (from legacy rf_hvps_loop.st logic)
        power_error = self.target_drive_power - kly_fwd_power
        
        if abs(power_error) > self.config["power_deadband"]:
            # Proportional adjustment (legacy: delta_proc_voltage_up/down)
            delta_v = power_error * self.config["hvps_gain"]
            delta_v = clamp(delta_v, -self.config["max_delta_v"], self.config["max_delta_v"])
            
            new_setpoint = hvps_readback.voltage + delta_v
            new_setpoint = clamp(new_setpoint, 0, self.config["max_voltage"])
            
            self.hvps.set_voltage(new_setpoint)
        
        # 4. Collector power protection check (enhanced from legacy)
        collector_power = hvps_readback.voltage * hvps_readback.current - kly_fwd_power
        if collector_power > self.config["max_collector_power"]:
            self.event_bus.publish_fault("HVPSController", "COLLECTOR_POWER_HIGH",
                {"collector_power": collector_power, "limit": self.config["max_collector_power"]})
        
        # 5. Publish readback for other modules
        self.event_bus.publish(Event(
            type=EventType.HVPS_READBACK,
            source=self.name,
            data={"voltage": hvps_readback.voltage, "current": hvps_readback.current,
                  "drive_power": kly_fwd_power, "collector_power": collector_power}
        ))
```

### 6.3 HVPS Recovery Sequence

After a fault, the HVPS requires a specific recovery sequence coordinated with the Interface Chassis (see Section 7 of Interface Chassis Design Report):

```python
async def recovery_sequence(self):
    """HVPS recovery after fault — coordinates with Interface Chassis."""
    
    # Step 1: Verify HVPS is off and safe
    assert self.hvps.get_readback().voltage < self.config["zero_threshold"]
    
    # Step 2: Request MPS reset (clears Interface Chassis latches)
    self.mps.send_reset()
    await asyncio.sleep(1.0)  # Wait for latch clear propagation
    
    # Step 3: Verify Interface Chassis permits restored
    assert self.mps.get_interface_chassis_status()["all_permits_ok"]
    
    # Step 4: Command HVPS PLC to ready state
    self.hvps.set_ready()
    await asyncio.sleep(2.0)
    
    # Step 5: Verify HVPS STATUS fiber is illuminated
    assert self.hvps.get_readback().status_ready
    
    # Step 6: Begin voltage ramp (if station state allows)
    if self.state_machine.current_state in (StationState.TUNE, StationState.ON_CW):
        self.hvps.set_voltage(self.config["initial_voltage"])
```

---

## 7. Tuner Manager

### 7.1 Purpose

The Tuner Manager replaces `rf_tuner_loop.st` (555 lines). It manages all 4 cavity tuners using 10 Hz phase data from the LLRF9 and motor commands to the Galil DMC-4143 motion controller.

### 7.2 Architecture

```python
class TunerManager(BaseController):
    """Manages 4 cavity tuners: phase-based feedback, homing, parking."""
    
    def __init__(self, ...):
        self.tuners = [
            CavityTuner(cavity_id=1, phase_pv="LLRF1:BRD1:CH0:PHASE",
                        amp_pv="LLRF1:BRD1:CH0:AMP", motor_prefix="SRF1:MTR:C1"),
            CavityTuner(cavity_id=2, phase_pv="LLRF1:BRD1:CH1:PHASE",
                        amp_pv="LLRF1:BRD1:CH1:AMP", motor_prefix="SRF1:MTR:C2"),
            CavityTuner(cavity_id=3, phase_pv="LLRF1:BRD2:CH0:PHASE",
                        amp_pv="LLRF1:BRD2:CH0:AMP", motor_prefix="SRF1:MTR:C3"),
            CavityTuner(cavity_id=4, phase_pv="LLRF1:BRD2:CH1:PHASE",
                        amp_pv="LLRF1:BRD2:CH1:AMP", motor_prefix="SRF1:MTR:C4"),
        ]

class CavityTuner:
    """Single cavity tuner controller with PID phase feedback."""
    
    def __init__(self, cavity_id, phase_pv, amp_pv, motor_prefix):
        self.state = TunerState.PARKED
        self.pid = PIDController(kp=0, ki=0, kd=0)  # Loaded from config
        self.phase_setpoint = 0.0    # Degrees
        self.deadband = 1.0          # Degrees
        self.min_forward_power = 0.0 # Minimum power for loop operation
    
    def execute_cycle(self, phase: float, amplitude: float, forward_power: float):
        """Single tuner control cycle."""
        if self.state != TunerState.TUNING:
            return
        
        if forward_power < self.min_forward_power:
            return  # Don't tune without sufficient RF power
        
        phase_error = self.phase_setpoint - phase
        if abs(phase_error) < self.deadband:
            return  # Within deadband, no action needed
        
        motor_command = self.pid.compute(phase_error)
        motor_command = clamp(motor_command, -self.max_step, self.max_step)
        self.motor.move_relative(motor_command)
```

### 7.3 Tuner Operating Modes

| Mode | Description | Motor Action |
|------|-------------|--------------|
| **PARKED** | Tuner retracted to safe park position | Move to park position, then hold |
| **HOMING** | Moving to ON-position home from park | Move to configured ON-position |
| **TUNING** | Phase-based PID feedback active | PID-controlled relative moves |
| **LOCKED** | Phase within deadband, holding position | No motion (monitoring only) |
| **FAULT** | Motor fault or excessive phase error | All motion stopped |

### 7.4 Key PV Mapping

| Function | LLRF9 PV (Read) | Motor PV (Write) | Config Parameter |
|----------|-----------------|-------------------|------------------|
| Cavity 1 phase | `LLRF1:BRD1:CH0:PHASE` | `SRF1:MTR:C1.RLV` | `tuners.c1.phase_setpoint` |
| Cavity 2 phase | `LLRF1:BRD1:CH1:PHASE` | `SRF1:MTR:C2.RLV` | `tuners.c2.phase_setpoint` |
| Cavity 3 phase | `LLRF1:BRD2:CH0:PHASE` | `SRF1:MTR:C3.RLV` | `tuners.c3.phase_setpoint` |
| Cavity 4 phase | `LLRF1:BRD2:CH1:PHASE` | `SRF1:MTR:C4.RLV` | `tuners.c4.phase_setpoint` |

---

## 8. Load Angle Controller

### 8.1 Purpose

The Load Angle Controller equalizes gap voltage across all 4 cavities by adjusting individual tuner phase offsets. It operates at ~0.1 Hz (every 10 seconds) as a slow outer loop around the tuner manager.

### 8.2 Algorithm

```python
class LoadAngleController(BaseController):
    """Balances gap voltage across 4 cavities via tuner offset adjustment.
    
    Replaces the load angle offset logic from rf_tuner_loop.st.
    """
    
    def execute_cycle(self):
        # 1. Read all 4 cavity probe amplitudes
        amplitudes = [
            self.llrf9.get_scalar_amplitude("BRD1", channel=0),  # Cavity 1
            self.llrf9.get_scalar_amplitude("BRD1", channel=1),  # Cavity 2
            self.llrf9.get_scalar_amplitude("BRD2", channel=0),  # Cavity 3
            self.llrf9.get_scalar_amplitude("BRD2", channel=1),  # Cavity 4
        ]
        
        # 2. Compute target amplitude (mean of all 4)
        target = sum(amplitudes) / 4.0
        
        # 3. For each cavity, adjust tuner offset to equalize
        for i, (amp, tuner) in enumerate(zip(amplitudes, self.tuner_manager.tuners)):
            error = target - amp
            if abs(error) > self.config["balance_deadband"]:
                # Adjust tuner phase offset to shift power distribution
                offset_delta = error * self.config["balance_gain"]
                new_offset = tuner.phase_setpoint + offset_delta
                self.llrf9.set_tuner_offset(cavity=i+1, offset=new_offset)
                tuner.phase_setpoint = new_offset
```

---

## 9. Fault Manager

### 9.1 Purpose

The Fault Manager is the central fault detection, logging, and recovery coordination module. It replaces the fault handling in `rf_states.st` and the TAXI error monitoring in `rf_msgs.st`.

### 9.2 Fault Sources

| Source | Detection Method | Severity | Response |
|--------|-----------------|----------|----------|
| Interface Chassis trip | MPS PV monitor | CRITICAL | Immediate FAULT state |
| MPS permit lost | `SRF1:MPS:PERMIT` monitor | CRITICAL | Immediate FAULT state |
| LLRF9 interlock trip | `LLRF1:ILOCK:ALL` monitor | CRITICAL | Immediate FAULT state |
| HVPS fault | `SRF1:HVPS:STATUS:READY` → 0 | CRITICAL | Immediate FAULT state |
| EPICS connection lost | EPICSBridge connection monitor | WARNING | Graceful degradation |
| Tuner phase error | Phase exceeds limit for > N cycles | WARNING | Auto-retry, then FAULT |
| Collector power high | Waveform Buffer calculation | CRITICAL | HVPS voltage reduction |
| Arc detection | Interface Chassis arc status bits | CRITICAL | Immediate FAULT state |
| Heater fault | `SRF1:HTR:FAULT` monitor | WARNING | Prevent HVPS enable |

### 9.3 First-Fault Analysis

```python
class FaultManager(BaseController):
    """Centralized fault detection, logging, and recovery coordination."""
    
    def handle_interlock_trip(self, event: Event):
        """Process an Interface Chassis interlock trip."""
        
        # 1. Read first-fault register from MPS
        first_fault = self.mps.get_first_fault()
        
        # 2. Read all Interface Chassis input states
        ic_status = self.mps.get_interface_chassis_status()
        
        # 3. Identify primary fault vs. consequential faults
        #    (LLRF9 Status and HVPS STATUS going low after IC removes
        #     permits are consequential, not primary faults)
        primary_fault = self._identify_primary_fault(first_fault, ic_status)
        
        # 4. Log structured fault event
        self.event_logger.log_fault(
            primary_fault=primary_fault,
            first_fault_register=first_fault,
            all_status=ic_status,
            timestamp=event.timestamp
        )
        
        # 5. Trigger waveform capture on all LLRF9 units
        for unit in [self.llrf9_unit1, self.llrf9_unit2]:
            unit.trigger_waveform_capture(trigger="interlock")
        
        # 6. Read Waveform Buffer frozen data
        self.waveform_buf.read_frozen_buffers()
        
        # 7. Publish fault event to state machine
        self.event_bus.publish_fault(self.name, primary_fault, ic_status)
```

### 9.4 Auto-Recovery

For transient faults (e.g., beam loss → MPS trip → restore), the fault manager supports configurable auto-recovery:

```python
def attempt_auto_recovery(self, fault_event: Event):
    """Attempt automatic recovery for transient faults."""
    
    if not self.config["auto_recovery_enabled"]:
        return
    
    if fault_event.data["fault_code"] not in self.config["auto_recoverable_faults"]:
        return
    
    if self.recovery_attempts >= self.config["max_recovery_attempts"]:
        self.logger.warning("Max auto-recovery attempts reached")
        return
    
    self.recovery_attempts += 1
    
    # Wait for configurable delay (with randomization to prevent IOC collision,
    # similar to legacy rf_msgs.st LFB resync delay)
    delay = self.config["recovery_delay"] + random.uniform(0, self.config["recovery_jitter"])
    await asyncio.sleep(delay)
    
    # Attempt recovery
    self.state_machine.request_transition(StationState.TUNE)
```

---

## 10. Waveform Buffer Interface

### 10.1 Purpose

Provides the Python coordinator's interface to the Waveform Buffer System. Reads circular buffer waveforms, configures comparator thresholds, and monitors collector power calculations.

### 10.2 Key PVs

| PV | Type | Description |
|----|------|-------------|
| `SRF1:WFBUF:RF:CH1:WAVEFORM` | Waveform | Circulator load forward power buffer |
| `SRF1:WFBUF:RF:CH3:WAVEFORM` | Waveform | Station reference power buffer |
| `SRF1:WFBUF:HVPS:VOLT:WAVEFORM` | Waveform | HVPS voltage circular buffer |
| `SRF1:WFBUF:HVPS:CURR:WAVEFORM` | Waveform | HVPS current circular buffer |
| `SRF1:WFBUF:COLLECTOR:POWER` | Float | Calculated collector power (DC - RF) |
| `SRF1:WFBUF:COLLECTOR:LIMIT` | Float | Collector power trip threshold |
| `SRF1:WFBUF:TRIP:SUMMARY` | Binary | Summary trip status to Interface Chassis |

---

## 11. Heater Controller Interface

### 11.1 Purpose

Coordinates the klystron cathode heater SCR controller with the station state machine. Manages warm-up and cool-down sequences, ensuring the heater is at operating temperature before allowing HVPS enable.

### 11.2 Coordination Logic

```python
class HeaterController(BaseController):
    """Heater sequencing coordinated with station state machine."""
    
    def on_state_change(self, event: Event):
        """React to station state changes."""
        new_state = StationState(event.data["new_state"])
        
        if new_state == StationState.STANDBY:
            # Begin warmup sequence
            self.heater.set_mode("WARMUP")
        
        elif new_state == StationState.OFF:
            # Begin cooldown, then off
            if self.heater.get_mode() == HeaterMode.OPERATING:
                self.heater.set_mode("COOLDOWN")
            else:
                self.heater.set_mode("OFF")
    
    def is_ready_for_hvps(self) -> bool:
        """Check if heater is at operating temperature."""
        return self.heater.get_mode() == HeaterMode.OPERATING
```

### 11.3 Key PVs

| PV | Direction | Description |
|----|-----------|-------------|
| `SRF1:HTR:VOLT:RMS` | Read | RMS heater voltage |
| `SRF1:HTR:CURR:RMS` | Read | RMS heater current |
| `SRF1:HTR:MODE` | Read/Write | Operating mode (OFF/STANDBY/WARMUP/OPERATING/COOLDOWN) |
| `SRF1:HTR:STATUS` | Read | System status |
| `SRF1:HTR:FAULT` | Read | Fault conditions |
| `SRF1:HTR:CTRL:SP` | Write | Power setpoint (0-100%) |

---

## 12. Calibration System

### 12.1 Purpose

Replaces `rf_calib.st` (2,800+ lines). The scope is significantly reduced because the LLRF9's digital signal processing eliminates the need for analog offset nulling and coefficient calibration that dominated the legacy system.

### 12.2 Remaining Calibration Tasks

| Task | Method | Frequency |
|------|--------|-----------|
| **Vector sum setup** | Python implementation of `vector_sum_setup.m` algorithm | Installation / configuration change |
| **Phase nulling** | Python implementation of `null_phases.m` algorithm | Installation / configuration change |
| **Power calibration** | Map ADC counts to engineering units using known reference | Annual or after cable change |
| **Tuner position cal** | Map motor steps to mm using potentiometer reference | Installation |
| **HVPS voltage cal** | Verify PLC ADC against external measurement | Annual |

### 12.3 Vector Sum Setup Algorithm

```python
def configure_vector_sum(self, unit: LLRF9Interface, board: str = "BRD1"):
    """Configure 2-cavity vector sum on LLRF9 board.
    
    Implements the algorithm from vector_sum_setup.m:
    1. Set cavity 1 rotation gain=1, phase=0
    2. Read amplitude ratios
    3. Match ROT:CAV2:GAIN to amplitude ratio
    4. Scale ROT:P_OL:GAIN to match reference
    5. Trim phases to match
    6. Copy to closed-loop rotator settings
    """
    # Step 1: Initialize
    unit.put(f"{board}:ROT:CAV1:GAIN", 1.0)
    unit.put(f"{board}:ROT:CAV1:PHASE", 0.0)
    
    # Step 2: Read amplitude ratio
    amp1 = unit.get(f"{board}:SCALAR:RAW:AMP0")
    amp2 = unit.get(f"{board}:SCALAR:RAW:AMP1")
    ratio = amp2 / amp1 if amp1 > 0 else 1.0
    
    # Step 3: Set cavity 2 gain
    unit.put(f"{board}:ROT:CAV2:GAIN", ratio)
    
    # Step 4-6: Phase matching (iterative)
    for iteration in range(10):
        # Read diagnostic signals via DIAGSEL multiplexer
        unit.put(f"{board}:DIAGSEL", 1)  # Select rotated cavity signals
        time.sleep(0.2)
        
        cav1_phase = unit.get(f"{board}:SCALAR:RAW:PHASE0")
        cav2_phase = unit.get(f"{board}:SCALAR:RAW:PHASE1")
        ref_phase = unit.get(f"{board}:SCALAR:RAW:PHASE2")
        
        # Trim cavity 2 phase to match cavity 1
        phase_error = cav1_phase - cav2_phase
        if abs(phase_error) < 0.5:  # Sub-degree convergence
            break
        unit.put(f"{board}:ROT:CAV2:PHASE", 
                 unit.get(f"{board}:ROT:CAV2:PHASE") + phase_error)
    
    # Copy open-loop settings to closed-loop
    for param in ["P_OL:GAIN", "P_OL:PHASE"]:
        value = unit.get(f"{board}:ROT:{param}")
        cl_param = param.replace("OL", "CL")
        unit.put(f"{board}:ROT:{cl_param}", value)
```


---

## 13. Configuration Management

### 13.1 Configuration File Structure

All operational parameters are stored in YAML configuration files, version-controlled alongside the source code.

```yaml
# config/defaults/station.yaml
station:
  name: "SPEAR3 RF Station 1"
  pv_prefix: "SRF1"
  
  state_machine:
    auto_recovery_enabled: true
    max_recovery_attempts: 3
    recovery_delay: 5.0       # seconds
    recovery_jitter: 2.0      # seconds (randomization)
    stable_check_duration: 5.0 # seconds to verify stable ON_CW
    
  epics:
    ca_addr_list: "10.0.0.101 10.0.0.102 10.0.0.103 10.0.0.104"
    ca_max_array_bytes: 26000000
    connection_timeout: 5.0
    monitor_rate: 10.0  # Hz

# config/defaults/hvps.yaml
hvps:
  pv_prefix: "SRF1:HVPS"
  max_voltage: 90.0           # kV
  nominal_voltage: 74.7       # kV at 500 mA beam
  initial_voltage: 50.0       # kV for ramp start
  max_delta_v: 0.5            # kV per cycle
  power_deadband: 50.0        # W
  hvps_gain: 0.001            # kV/W
  max_collector_power: 800000  # W (800 kW)
  zero_threshold: 0.5         # kV (considered "off")

# config/defaults/tuners.yaml
tuners:
  period: 1.0  # seconds (1 Hz control rate)
  
  c1:
    phase_setpoint: 0.0
    deadband: 1.0           # degrees
    kp: 0.5
    ki: 0.01
    kd: 0.0
    max_step: 100           # motor steps per cycle
    min_forward_power: 100  # W
    park_position: 0.0      # mm
    on_position: 10.3       # mm
    
  c2:
    phase_setpoint: 0.0
    deadband: 1.0
    kp: 0.5
    ki: 0.01
    kd: 0.0
    max_step: 100
    min_forward_power: 100
    park_position: 0.0
    on_position: 10.5
    
  # c3, c4 similar...
  
  load_angle:
    period: 10.0            # seconds (0.1 Hz)
    balance_gain: 0.1
    balance_deadband: 0.02  # normalized amplitude units
```

### 13.2 Configuration Save/Restore

The coordinator wraps the LLRF9 native CWget/CWput mechanism with versioning:

```python
class ConfigManager:
    """Configuration management with versioning and validation."""
    
    def save_configuration(self, name: str, description: str = "") -> str:
        """Save complete system configuration as a named snapshot."""
        snapshot = {
            "name": name,
            "timestamp": datetime.now().isoformat(),
            "description": description,
            "coordinator_config": self.current_config,
            "llrf9_unit1": self.llrf9_unit1.save_configuration(),
            "llrf9_unit2": self.llrf9_unit2.save_configuration(),
            "hvps_setpoints": self.hvps.get_all_setpoints(),
            "tuner_positions": self.tuner_manager.get_all_positions(),
        }
        filename = f"configs/{name}_{datetime.now():%Y%m%d_%H%M%S}.yaml"
        with open(filename, 'w') as f:
            yaml.dump(snapshot, f)
        return filename
    
    def restore_configuration(self, filename: str) -> bool:
        """Restore system configuration from a named snapshot."""
        with open(filename) as f:
            snapshot = yaml.safe_load(f)
        # Validate before applying
        if not self._validate_snapshot(snapshot):
            return False
        # Apply in correct order
        self.llrf9_unit1.restore_configuration(snapshot["llrf9_unit1"])
        self.llrf9_unit2.restore_configuration(snapshot["llrf9_unit2"])
        return True
```

---

## 14. Operator Interface

### 14.1 Coordinator PV Server

The Python coordinator publishes its internal state as EPICS PVs using caproto, making all coordinator data available to EDM panels, the EPICS Archiver, and alarm handlers.

**Published PVs** (prefix `SRF1:COORD:`):

| PV | Type | Description |
|----|------|-------------|
| `SRF1:COORD:STATE` | Enum | Current station state (OFF/STANDBY/PARK/TUNE/ON_CW/FAULT) |
| `SRF1:COORD:STATE:REQUEST` | Enum | Requested state transition (write by operator) |
| `SRF1:COORD:FAULT:ACTIVE` | Binary | Fault condition active |
| `SRF1:COORD:FAULT:FIRST` | String | First-fault identification |
| `SRF1:COORD:FAULT:COUNT` | Integer | Total fault count since startup |
| `SRF1:COORD:HVPS:TARGET` | Float | HVPS target drive power |
| `SRF1:COORD:HVPS:VOLTAGE` | Float | Current HVPS voltage setpoint |
| `SRF1:COORD:TUNER:C1:STATE` | Enum | Cavity 1 tuner state |
| `SRF1:COORD:TUNER:C2:STATE` | Enum | Cavity 2 tuner state |
| `SRF1:COORD:TUNER:C3:STATE` | Enum | Cavity 3 tuner state |
| `SRF1:COORD:TUNER:C4:STATE` | Enum | Cavity 4 tuner state |
| `SRF1:COORD:BALANCE:ENABLED` | Binary | Load angle balancing active |
| `SRF1:COORD:HEATER:READY` | Binary | Heater at operating temperature |
| `SRF1:COORD:UPTIME` | Float | Coordinator uptime (seconds) |
| `SRF1:COORD:CYCLE:TIME` | Float | Last main loop cycle time (ms) |
| `SRF1:COORD:VERSION` | String | Software version |

### 14.2 EDM Panel Integration

EDM panels access the coordinator PVs alongside direct LLRF9, HVPS, and MPS PVs. The upgrade preserves compatibility with the existing EDM panel infrastructure while adding new panels for coordinator-specific views.

**New EDM Panels**:

| Panel | Purpose |
|-------|---------|
| `coord_top.edl` | Top-level coordinator overview: state, faults, subsystem summary |
| `coord_state.edl` | State machine detail: transition history, current conditions |
| `coord_hvps.edl` | HVPS supervisory loop: target, readback, collector power |
| `coord_tuners.edl` | 4-cavity tuner overview: states, phases, positions, balance |
| `coord_faults.edl` | Fault history: first-fault analysis, waveform links |
| `coord_config.edl` | Configuration management: save/restore, parameter editing |

---

## 15. EPICS PV Contract Reference

### 15.1 PV Namespaces

| Namespace | Owner | Count | Description |
|-----------|-------|-------|-------------|
| `LLRF1:` | LLRF9 Unit 1 IOC | ~550 | Field control, tuner data, Unit 1 interlocks |
| `LLRF2:` | LLRF9 Unit 2 IOC | ~550 | Monitoring, reflected power, Unit 2 interlocks |
| `SRF1:HVPS:` | CompactLogix PLC | ~30 | Voltage control, status, interlocks |
| `SRF1:MPS:` | ControlLogix PLC | ~20 | MPS permit, faults, first-fault, Interface Chassis status |
| `SRF1:MTR:` | Motor record IOC | ~40 | 4 motor records (position, velocity, limits) |
| `SRF1:WFBUF:` | Waveform Buffer IOC | ~30 | Waveform data, comparator thresholds, collector power |
| `SRF1:HTR:` | Heater Controller IOC | ~15 | Heater voltage, current, mode, faults |
| `SRF1:COORD:` | Python Coordinator | ~25 | Coordinator state, faults, diagnostics |

### 15.2 Critical PV Read Set (Monitored at 10 Hz)

These PVs are set up with CA monitors for real-time tracking:

```
# LLRF9 Unit 1 — cavity amplitudes and phases (10 Hz from IOC)
LLRF1:BRD1:CH0:AMP           # Cavity 1 probe amplitude
LLRF1:BRD1:CH0:PHASE         # Cavity 1 probe phase
LLRF1:BRD1:CH1:AMP           # Cavity 2 probe amplitude
LLRF1:BRD1:CH1:PHASE         # Cavity 2 probe phase
LLRF1:BRD2:CH0:AMP           # Cavity 3 probe amplitude
LLRF1:BRD2:CH0:PHASE         # Cavity 3 probe phase
LLRF1:BRD2:CH1:AMP           # Cavity 4 probe amplitude
LLRF1:BRD2:CH1:PHASE         # Cavity 4 probe phase

# LLRF9 Unit 1 — interlock status
LLRF1:ILOCK:ALL               # System-wide interlock aggregate

# LLRF9 Unit 2 — reflected powers and interlocks
LLRF2:ILOCK:ALL               # Unit 2 interlock aggregate

# MPS permit (critical — drives state machine)
SRF1:MPS:PERMIT                # MPS permit status
SRF1:MPS:FAULTS:FIRST         # First-fault identification

# HVPS status
SRF1:HVPS:STATUS:READY        # HVPS ready indicator
SRF1:HVPS:VOLT:RBCK           # Voltage readback
```

---

## 16. Concurrency and Threading Model

### 16.1 Architecture

The coordinator uses a **single main thread** with cooperative scheduling via `asyncio`. This avoids threading complexity while supporting multiple control loops at different rates.

```python
async def main_loop(coordinator):
    """Main coordinator loop using asyncio tasks."""
    
    tasks = [
        # 1 Hz control loops
        asyncio.create_task(run_periodic(coordinator.state_machine, period=1.0)),
        asyncio.create_task(run_periodic(coordinator.hvps_controller, period=1.0)),
        asyncio.create_task(run_periodic(coordinator.tuner_manager, period=1.0)),
        asyncio.create_task(run_periodic(coordinator.heater_controller, period=1.0)),
        
        # 0.1 Hz slow loop
        asyncio.create_task(run_periodic(coordinator.load_angle_controller, period=10.0)),
        
        # Event-driven (monitors via callbacks)
        asyncio.create_task(coordinator.fault_manager.run()),
        
        # PV server
        asyncio.create_task(coordinator.pv_server.run()),
    ]
    
    await asyncio.gather(*tasks)
```

### 16.2 EPICS CA Threading

PyEPICS Channel Access callbacks execute on the CA callback thread. The design ensures thread safety by:

1. **Monitor callbacks** enqueue events to the asyncio event loop via `loop.call_soon_threadsafe()`
2. **PV cache** uses thread-safe `dict` operations (atomic in CPython)
3. **All control logic** runs in the main asyncio thread
4. **No shared mutable state** between CA callbacks and control logic

---

## 17. Error Handling and Recovery

### 17.1 Error Categories

| Category | Example | Handling |
|----------|---------|----------|
| **Hardware Fault** | Interface Chassis trip, arc detection | Hardware acts first; software enters FAULT state, logs, captures data |
| **EPICS Timeout** | IOC unreachable, PV read timeout | Retry with backoff; if persistent, degrade gracefully |
| **Software Exception** | Unexpected Python error | Catch, log, continue if non-critical; FAULT if critical |
| **Configuration Error** | Invalid parameter, missing file | Refuse to start; use last-known-good config |
| **State Violation** | Invalid transition requested | Reject transition, log warning |

### 17.2 Graceful Degradation

| Subsystem Lost | Impact | Coordinator Behavior |
|----------------|--------|---------------------|
| LLRF9 Unit 1 | No field control data | Transition to FAULT; disable all control loops |
| LLRF9 Unit 2 | No reflected power monitoring | Continue with reduced monitoring; log warning |
| HVPS PLC | No voltage control | Transition to FAULT; hardware protection continues |
| Motor controller | No tuner control | Suspend tuner loops; remain in current state if stable |
| Waveform Buffer | No extended monitoring | Continue; log warning; collector protection degraded |
| Heater controller | No heater management | Prevent transitions requiring heater; log warning |
| MPS PLC | No MPS status | Transition to FAULT; hardware MPS continues independently |

---

## 18. Testing Strategy

### 18.1 Test Pyramid

| Level | Tool | Coverage Target | Description |
|-------|------|----------------|-------------|
| **Unit Tests** | pytest | >90% | Individual module logic with mocked interfaces |
| **Integration Tests** | pytest + all mocks | Key scenarios | Multi-module interaction with simulated hardware |
| **Hardware-in-Loop** | pytest + real IOCs | Critical paths | Tests against actual LLRF9/PLC IOCs on bench |
| **System Tests** | Manual + scripts | Full commissioning | Complete system with RF power |

### 18.2 Mock Architecture

Every hardware interface has a corresponding mock that simulates realistic IOC behavior:

```python
class MockLLRF9(LLRF9Interface):
    """Simulates LLRF9 IOC responses for testing."""
    
    def __init__(self, unit_id: int = 1):
        self.pv_values = {
            "BRD1:CH0:AMP": 800.0,    # Simulated cavity 1 amplitude
            "BRD1:CH0:PHASE": 0.0,     # Simulated cavity 1 phase
            "BRD1:CH1:AMP": 795.0,     # Simulated cavity 2 amplitude
            "BRD1:CH1:PHASE": 0.5,     # Simulated cavity 2 phase
            "ILOCK:ALL": 0,            # No interlocks
            "BRD1:FB:CTRL": "open",    # Feedback mode
        }
        self.interlock_tripped = False
    
    def get(self, pv_suffix: str) -> Any:
        return self.pv_values.get(pv_suffix)
    
    def put(self, pv_suffix: str, value: Any) -> None:
        self.pv_values[pv_suffix] = value
    
    def inject_fault(self, fault_type: str):
        """Test helper: inject simulated fault conditions."""
        if fault_type == "interlock":
            self.pv_values["ILOCK:ALL"] = 1
            self.interlock_tripped = True
```

### 18.3 Key Test Scenarios

| Scenario | Modules Under Test | Assertion |
|----------|-------------------|-----------|
| Normal turn-on sequence | StateMachine, HVPS, Tuner, LLRF9 | Reaches ON_CW without errors |
| Arc fault → FAULT state | FaultManager, StateMachine | FAULT state entered, waveforms captured |
| MPS permit loss and restore | FaultManager, StateMachine, HVPS | Auto-recovery after transient |
| Tuner phase drift | TunerManager, CavityTuner | PID corrects within N cycles |
| EPICS connection loss | EPICSBridge, all controllers | Graceful degradation, no crash |
| Load angle imbalance | LoadAngleController | Amplitudes equalized within tolerance |
| HVPS-LLRF9 feedback loop | HVPSController, recovery | Correct recovery sequence executed |
| Configuration save/restore | ConfigManager, LLRF9Interface | All PVs correctly saved and restored |

---

## 19. Deployment and Operations

### 19.1 Deployment

The coordinator runs as a systemd service on a Linux workstation in Building B132:

```ini
# /etc/systemd/system/spear3-llrf-coordinator.service
[Unit]
Description=SPEAR3 LLRF Coordinator
After=network.target

[Service]
Type=simple
User=rf
WorkingDirectory=/opt/spear3_llrf
ExecStart=/opt/spear3_llrf/venv/bin/python -m spear3_llrf.main --config /opt/spear3_llrf/config/production.yaml
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 19.2 Startup Sequence

1. Load and validate configuration files
2. Initialize EPICS CA context with configured address list
3. Connect to all IOCs (with timeout and retry)
4. Verify LLRF9 IOC revision >= 9 (LLRF mode)
5. Start PV monitors for all critical PVs
6. Initialize all controller modules
7. Start PV server (caproto)
8. Enter main event loop
9. Set initial state to OFF

### 19.3 Operational Monitoring

| Metric | Source | Alert Threshold |
|--------|--------|----------------|
| Coordinator uptime | `SRF1:COORD:UPTIME` | < 60s after expected start |
| Main loop cycle time | `SRF1:COORD:CYCLE:TIME` | > 2000 ms |
| Fault count | `SRF1:COORD:FAULT:COUNT` | Any increment |
| EPICS connection status | EPICSBridge internal | Any IOC disconnected > 30s |
| Python process health | systemd watchdog | Process crash |

---

## 20. Legacy Code Mapping

### 20.1 Detailed Function Mapping

| Legacy Function (SNL) | Legacy File | New Module | New Function | Notes |
|-----------------------|-------------|-----------|--------------|-------|
| State machine states (OFF, PARK, TUNE, ON_CW) | `rf_states.st` | `state_machine.py` | `StationStateMachine` class | Simplified from PEP-II heritage; STANDBY added |
| Turn-on sequence (fast-on) | `rf_states.st` L800-1100 | `state_machine.py` | `transition_tune_to_on_cw()` | Uses LLRF9 ramp profiles instead of DAC stepping |
| Fault file capture | `rf_states.st` L1200-1500 | `fault_manager.py` | `capture_fault_snapshot()` | Structured JSON instead of flat file |
| Auto restart with delay | `rf_states.st` L1600-1700 | `fault_manager.py` | `attempt_auto_recovery()` | Configurable, with jitter |
| HVPS voltage regulation | `rf_hvps_loop.st` | `hvps_controller.py` | `execute_cycle()` | PLC handles inner loop; Python provides supervisory |
| Drive power control | `rf_hvps_loop.st` L50-150 | `hvps_controller.py` | `execute_cycle()` | Reads from LLRF9 instead of analog module |
| Collector power protection | `rf_hvps_loop.st` L200-250 | `hvps_controller.py` | `execute_cycle()` | Enhanced with Waveform Buffer DC power calculation |
| Tuner phase feedback (x4) | `rf_tuner_loop.st` L100-300 | `tuner_manager.py` | `CavityTuner.execute_cycle()` | 10 Hz LLRF9 phase data + Galil motor records |
| Tuner homing sequence | `rf_tuner_loop.st` L50-100 | `tuner_manager.py` | `CavityTuner.home()` | Galil motor record `HOMF`/`HOMR` |
| Load angle offset | `rf_tuner_loop.st` L350-500 | `load_angle_controller.py` | `execute_cycle()` | Separate 0.1 Hz module |
| DAC loop (GFF control) | `rf_dac_loop.st` | *Eliminated* | N/A | LLRF9 internal vector sum replaces |
| Analog calibration | `rf_calib.st` | `calibration.py` | `configure_vector_sum()` | LLRF9 digital calibration; minimal scope |
| TAXI error monitoring | `rf_msgs.st` L100-200 | *Eliminated* | N/A | CAMAC TAXI eliminated with VXI |
| LFB resync | `rf_msgs.st` L200-350 | *Eliminated* | N/A | Digital feedback has no analog drift |
| Message logging | `rf_msgs.st` | `event_logger.py` | `log_event()` | Structured JSON logging |

---

## 21. Appendix: PV Namespace Registry

### 21.1 Complete PV Prefix Allocation

| Prefix | System | Owner | Location |
|--------|--------|-------|----------|
| `LLRF1:BRD1:` | LLRF9 Unit 1, Board 1 | LLRF9 IOC | B132 |
| `LLRF1:BRD2:` | LLRF9 Unit 1, Board 2 | LLRF9 IOC | B132 |
| `LLRF1:BRD3:` | LLRF9 Unit 1, Board 3 | LLRF9 IOC | B132 |
| `LLRF1:TUNER:` | LLRF9 Unit 1, Tuner subsystem | LLRF9 IOC | B132 |
| `LLRF1:STATE:` | LLRF9 Unit 1, State machine | LLRF9 IOC | B132 |
| `LLRF1:HVPS:` | LLRF9 Unit 1, HVPS parameters | LLRF9 IOC | B132 |
| `LLRF1:ILOCK:` | LLRF9 Unit 1, Interlocks | LLRF9 IOC | B132 |
| `LLRF1:SR:` | LLRF9 Unit 1, Save/Restore | LLRF9 IOC | B132 |
| `LLRF2:BRD1:` | LLRF9 Unit 2, Board 1 | LLRF9 IOC | B132 |
| `LLRF2:BRD2:` | LLRF9 Unit 2, Board 2 | LLRF9 IOC | B132 |
| `LLRF2:BRD3:` | LLRF9 Unit 2, Board 3 | LLRF9 IOC | B132 |
| `LLRF2:ILOCK:` | LLRF9 Unit 2, Interlocks | LLRF9 IOC | B132 |
| `SRF1:HVPS:` | HVPS CompactLogix PLC | EPICS gateway | B118 |
| `SRF1:MPS:` | Kly MPS ControlLogix PLC | EPICS gateway | B132 |
| `SRF1:MTR:C1` | Cavity 1 tuner motor | Motor record IOC | B132 |
| `SRF1:MTR:C2` | Cavity 2 tuner motor | Motor record IOC | B132 |
| `SRF1:MTR:C3` | Cavity 3 tuner motor | Motor record IOC | B132 |
| `SRF1:MTR:C4` | Cavity 4 tuner motor | Motor record IOC | B132 |
| `SRF1:WFBUF:` | Waveform Buffer System | Dedicated IOC | B132 |
| `SRF1:HTR:` | Klystron heater controller | Dedicated IOC | B132 |
| `SRF1:COORD:` | Python Coordinator | caproto server | B132 |

### 21.2 Source Document Traceability

| SDD Section | Source Document | Source Section |
|-------------|----------------|----------------|
| 1. System Context | Physical Design Report (PDR-001) | Sections 1-2, 14-18 |
| 5. State Machine | PDR-001 Section 14; `rf_states.st` | Legacy state machine analysis |
| 6. HVPS Controller | HVPS Technical Note; `rf_hvps_loop.st` | Sections 6, 12-14 |
| 7. Tuner Manager | PDR-001 Section 10; `rf_tuner_loop.st` | Tuner control system |
| 8. Load Angle | PDR-001 Section 10.4; `rf_tuner_loop.st` | Load angle offset loop |
| 9. Fault Manager | PDR-001 Section 17; Interface Chassis Design | Protection chain architecture |
| 10. Waveform Buffer | PDR-001 Section 11 | Waveform Buffer System |
| 11. Heater Controller | Heater Subsystem Upgrade | Sections 7-8 |
| 12. Calibration | LLRF9 System Report Section 10 | MATLAB toolkit algorithms |
| 15. PV Contracts | LLRF9 System Report Sections 3, 15 | PV architecture and catalog |
| Interface Chassis | Interface Chassis Design Report | All sections |
| PPS Interface | HVPS-PPS Interface Technical Document | Sections 8-9 |

---

**End of Software Design Document**

*This document should be reviewed and updated as hardware interfaces are finalized, particularly the Interface Chassis (on critical path), Waveform Buffer System, and Heater Controller IOC PV definitions.*
