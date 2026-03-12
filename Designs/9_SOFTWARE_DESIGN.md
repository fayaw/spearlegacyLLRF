# SPEAR3 LLRF Upgrade — Software Design Document

**Document ID**: SPEAR3-LLRF-SDD-001
**Revision**: R0
**Date**: March 2026
**Author**: LLRF Upgrade Team
**Classification**: Software Architecture & Implementation Blueprint
**Status**: Design Phase

---

## Purpose and Scope

This document defines the overall software architecture for the SPEAR3 LLRF Upgrade Project. It is the authoritative reference for all software to be developed as part of the upgrade, covering the Python/EPICS coordinator application and its integration with all hardware subsystem IOCs.

This software design is derived directly from the Physical Design Report (`0_PHYSICAL_DESIGN_REPORT.md`) and the detailed subsystem design documents (`3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md`, `4_HVPS_Engineering_Technical_Note.md`, `5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md`, `8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md`, `11_INTERFACE_CHASSIS_DESIGN.md`). Every software requirement is traceable to a physical design requirement or legacy behavior documented in those sources.

**Scope**:
- Python/EPICS coordinator application (Layer 4 supervisory software)
- EPICS IOC configuration and integration for all subsystems
- Operator interface framework
- Testing and deployment strategy

**Out of scope**:
- LLRF9 FPGA firmware (Layer 1 — Dimtel)
- Interface Chassis hardware logic (Layer 2 — custom hardware)
- PLC application code for Kly MPS and HVPS (Layer 3 — Rockwell/AB)
- PPS system software (separate safety domain)

---

## Table of Contents

1. [Design Philosophy and Guiding Principles](#1-design-philosophy-and-guiding-principles)
2. [System Context and Software Boundary](#2-system-context-and-software-boundary)
3. [Software Architecture Overview](#3-software-architecture-overview)
4. [Module Decomposition](#4-module-decomposition)
5. [EPICS Integration Layer](#5-epics-integration-layer)
6. [Station State Machine](#6-station-state-machine)
7. [HVPS Supervisory Controller](#7-hvps-supervisory-controller)
8. [Tuner Control Manager](#8-tuner-control-manager)
9. [Load Angle Balancer](#9-load-angle-balancer)
10. [Fault Management System](#10-fault-management-system)
11. [Heater Controller Interface](#11-heater-controller-interface)
12. [Waveform Buffer Interface](#12-waveform-buffer-interface)
13. [MPS Coordination Module](#13-mps-coordination-module)
14. [Configuration Management](#14-configuration-management)
15. [Logging and Diagnostics](#15-logging-and-diagnostics)
16. [Operator Interface](#16-operator-interface)
17. [Calibration and Commissioning Tools](#17-calibration-and-commissioning-tools)
18. [Testing Strategy](#18-testing-strategy)
19. [Deployment Architecture](#19-deployment-architecture)
20. [PV Namespace and Interface Catalog](#20-pv-namespace-and-interface-catalog)
21. [Risk and Mitigation](#21-risk-and-mitigation)
22. [Appendix: Legacy-to-Upgrade Traceability](#22-appendix-legacy-to-upgrade-traceability)

---

## 1. Design Philosophy and Guiding Principles

### 1.1 Core Principles

| Principle | Rationale |
|-----------|-----------|
| **Safety delegation** | The Python coordinator is NOT in the fast safety path. All safety-critical protection is handled by hardware (Interface Chassis, Layer 2) and PLCs (Kly MPS, Layer 3). The coordinator handles sequencing and coordination only. |
| **Separation of concerns** | Each software module has a single, well-defined responsibility. Modules communicate through defined interfaces, not shared global state. |
| **Hardware abstraction** | All hardware interactions go through the EPICS PV layer. No module directly accesses hardware registers, serial ports, or network sockets to hardware. |
| **Configuration-driven** | All operational parameters — setpoints, thresholds, PV names, timing constants — are externalized to YAML configuration files. No magic numbers in code. |
| **Fail-safe software behavior** | If the coordinator crashes, the hardware protection chain (Layers 1–3) continues to function. The coordinator must detect its own partial failures and degrade gracefully. |
| **Testability** | Every hardware interface has a mock/simulated implementation. The entire coordinator can run in a test harness without any live hardware. |
| **Observability** | Every control action, state transition, fault event, and PV read/write is logged with structured metadata. Operators and engineers can reconstruct system behavior from logs alone. |

### 1.2 What the Software Does NOT Do

These functions are handled entirely by hardware or firmware and require NO Python implementation:

| Function | Handled By | Software Role |
|----------|-----------|---------------|
| Fast I/Q demodulation | LLRF9 FPGA | None |
| Vector sum feedback (270 ns) | LLRF9 FPGA | Configure rotator gains/phases at startup |
| RF overvoltage interlocks | LLRF9 FPGA + hardware | Set thresholds, read status after events |
| Hardware permit AND-logic | Interface Chassis | Monitor status via MPS PLC readback |
| First-fault latching | Interface Chassis | Read first-fault register via MPS PLC |
| Crowbar firing | HVPS hardware | Monitor status |
| PPS safety chain | Dedicated PPS hardware | No interaction whatsoever |

### 1.3 Technology Stack

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Language | Python | ≥3.10 | Core application language |
| EPICS client | PyEPICS (pyepics) | ≥3.5 | Channel Access interface |
| EPICS server | caproto | ≥1.1 | Local coordinator PVs (optional) |
| Configuration | YAML (PyYAML/ruamel.yaml) | — | All configuration files |
| Logging | Python logging + structured JSON | — | Structured event logging |
| Data | NumPy | ≥1.24 | Numerical computations |
| Testing | pytest + pytest-asyncio | — | Unit/integration testing |
| Process management | systemd | — | Service management on Linux host |
| Operator interface | EDM panels (legacy-compatible) | — | Primary operator displays |
| Web dashboard | FastAPI + HTMX (optional) | — | Supplementary monitoring |

---

## 2. System Context and Software Boundary

### 2.1 Four-Layer Protection Architecture

The SPEAR3 RF system implements a strict layered protection model. The Python coordinator operates exclusively at Layer 4:

```
┌─────────────────────────────────────────────────────────────────────┐
│ LAYER 1: LLRF9 FPGA (<1 µs)                                        │
│   • Fast I/Q feedback (270 ns direct loop)                          │
│   • RF overvoltage interlocks (9 per board)                         │
│   • Baseband window comparators (8 per unit)                        │
│   • DAC zeroing + RF switch activation on fault                     │
│   • Interlock timestamping (±17.4 ns resolution)                    │
│   • 16k-sample waveform capture on trigger                          │
├─────────────────────────────────────────────────────────────────────┤
│ LAYER 2: Interface Chassis (<1 µs)                                  │
│   • Hardware AND-gate of all permit inputs                          │
│   • First-fault detection and latching                              │
│   • Fiber-optic HVPS SCR ENABLE/CROWBAR control                     │
│   • LLRF9 external enable control                                   │
│   • Status reporting to Kly MPS PLC                                 │
├─────────────────────────────────────────────────────────────────────┤
│ LAYER 3: Kly MPS PLC (~ms scan rate)                                │
│   • Fault aggregation from Interface Chassis status                 │
│   • External permit management (SPEAR MPS, Orbit)                   │
│   • Summary Permit + Heartbeat → Interface Chassis                  │
│   • Reset signal → Interface Chassis (clears all latched faults)    │
│   • Event logging with timestamps                                   │
│   • Collector power redundant verification                          │
├─────────────────────────────────────────────────────────────────────┤
│ LAYER 4: Python Coordinator (~1 Hz)  ← THIS SOFTWARE                │
│   • Station state machine (OFF/PARK/TUNE/ON_CW/FAULT)              │
│   • HVPS supervisory loop (voltage setpoint management)             │
│   • Tuner management (×4 cavities, 10 Hz phase data → 1 Hz motor)  │
│   • Load angle balancing (power distribution equalization)          │
│   • Fault logging, diagnostics, waveform readout                    │
│   • Configuration management and save/restore                       │
│   • Operator interface coordination                                 │
│   • Heater controller sequencing                                    │
│   • Calibration and commissioning tools                             │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Software Interaction Map

The Python coordinator interacts with every hardware subsystem exclusively through EPICS Channel Access:

```
                    ┌──────────────────────────────────┐
                    │      PYTHON COORDINATOR           │
                    │                                    │
                    │  state_machine ─── hvps_ctrl      │
                    │       │               │            │
                    │  tuner_mgr ──── fault_mgr         │
                    │       │               │            │
                    │  load_angle ── config_mgr         │
                    │       │               │            │
                    │  heater_ctrl ─ wfbuf_mgr          │
                    │       │               │            │
                    │  mps_coord ── diag_logger         │
                    └───────┬──────────────┬────────────┘
                            │ EPICS CA     │
          ┌─────────────────┼──────────────┼─────────────────┐
          │                 │              │                  │
    ┌─────┴─────┐    ┌─────┴─────┐  ┌─────┴─────┐    ┌──────┴─────┐
    │ LLRF9 #1  │    │ LLRF9 #2  │  │ HVPS PLC  │    │  MPS PLC   │
    │ LLRF1:*   │    │ LLRF2:*   │  │SRF1:HVPS:*│    │SRF1:MPS:*  │
    └───────────┘    └───────────┘  └───────────┘    └────────────┘
          │                 │              │                  │
    ┌─────┴─────┐    ┌─────┴─────┐  ┌─────┴─────┐    ┌──────┴─────┐
    │ Motor Ctrl│    │ Waveform  │  │  Heater   │    │    Arc      │
    │SRF1:MTR:* │    │  Buffer   │  │  Ctrl     │    │  Detector  │
    │           │    │SRF1:WFBUF:│  │SRF1:HTR:* │    │ (via MPS)  │
    └───────────┘    └───────────┘  └───────────┘    └────────────┘
```

### 2.3 Timing Budget

| Function | Target Rate | Latency Budget | Source Data Rate |
|----------|-------------|---------------|-----------------|
| State machine main loop | 1 Hz | <200 ms per cycle | All subsystem status |
| HVPS supervisory loop | ≤1 Hz | <500 ms | LLRF9 scalar readbacks (10 Hz) |
| Tuner control loops (×4) | 1 Hz | <200 ms per cavity | LLRF9 phase data (10 Hz) |
| Load angle balancing | 0.1 Hz | <1 s | LLRF9 amplitude data (10 Hz) |
| Fault detection callback | Event-driven | <100 ms from PV change | Interlock PVs |
| Waveform readout | On fault trigger | <2 s for full capture | 16k samples × N channels |
| Configuration save/restore | On demand | <10 s | 550+ PVs per LLRF9 unit |
| Log flush | ≤1 Hz | <50 ms | Local disk I/O |


---

## 3. Software Architecture Overview

### 3.1 Process Architecture

The coordinator runs as a single Python process with internal threading for concurrent control loops:

```
┌─────────────────────────────────────────────────────────────────┐
│                  spear3_rf_coordinator (process)                 │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Main Thread   │  │ HVPS Thread  │  │ Tuner Thread (×4)    │  │
│  │ • State machine│  │ • ≤1 Hz loop │  │ • 1 Hz per cavity    │  │
│  │ • Fault handler│  │ • Voltage    │  │ • Phase → motor      │  │
│  │ • Cmd dispatch │  │   regulation │  │ • Load angle (0.1Hz) │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ EPICS Monitor │  │ Log Writer   │  │ Heater Sequencer     │  │
│  │ Thread        │  │ Thread       │  │ Thread               │  │
│  │ • PV callbacks│  │ • JSON logs  │  │ • Warm-up/cool-down  │  │
│  │ • Alarm queue │  │ • Disk flush │  │ • Power regulation   │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                   Shared State (thread-safe)              │   │
│  │  • SystemStatus dataclass (read by all, written by main)  │   │
│  │  • PVCache (updated by monitor thread, read by all)       │   │
│  │  • FaultQueue (written by monitor, consumed by main)      │   │
│  │  • CommandQueue (written by operator, consumed by main)   │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Design rationale**: A single process with threads (vs. multiple processes) is chosen because:
1. All modules need access to shared PV data and system status
2. Thread-safe queues provide simple, reliable inter-module communication
3. GIL contention is minimal — most time is spent in EPICS I/O (which releases the GIL)
4. A single process is simpler to deploy, monitor, and restart via systemd

### 3.2 Directory Structure

```
spear3_rf_coordinator/
├── pyproject.toml                    # Package metadata, dependencies
├── config/
│   ├── station.yaml                  # Master station configuration
│   ├── pv_map.yaml                   # Complete PV name mapping
│   ├── state_machine.yaml            # State transitions, timeouts
│   ├── hvps.yaml                     # HVPS control parameters
│   ├── tuners.yaml                   # Per-cavity tuner parameters
│   ├── heater.yaml                   # Heater sequences and limits
│   ├── interlocks.yaml               # Interlock thresholds
│   └── profiles/                     # Named operational profiles
│       ├── commissioning.yaml
│       ├── 500mA_operation.yaml
│       └── low_current.yaml
├── src/
│   ├── __init__.py
│   ├── main.py                       # Application entry point
│   ├── coordinator.py                # Top-level coordinator class
│   │
│   ├── epics_layer/                  # EPICS integration
│   │   ├── __init__.py
│   │   ├── pv_manager.py             # PV connection management & caching
│   │   ├── llrf9_interface.py        # LLRF9 PV abstraction (per unit)
│   │   ├── hvps_interface.py         # HVPS PLC PV abstraction
│   │   ├── mps_interface.py          # MPS PLC PV abstraction
│   │   ├── motor_interface.py        # Motor controller PV abstraction
│   │   ├── waveform_buffer_interface.py  # Waveform buffer PV abstraction
│   │   ├── heater_interface.py       # Heater controller PV abstraction
│   │   └── coordinator_pvs.py        # Coordinator's own published PVs
│   │
│   ├── state_machine/                # Station state machine
│   │   ├── __init__.py
│   │   ├── states.py                 # State enum and state classes
│   │   ├── transitions.py            # Transition logic and guards
│   │   ├── engine.py                 # State machine execution engine
│   │   └── sequences.py              # Turn-on, shutdown, fault sequences
│   │
│   ├── controllers/                  # Control loop implementations
│   │   ├── __init__.py
│   │   ├── hvps_controller.py        # HVPS supervisory loop
│   │   ├── tuner_controller.py       # Single-cavity tuner controller
│   │   ├── tuner_manager.py          # Manages all 4 tuner controllers
│   │   ├── load_angle_controller.py  # Load angle offset balancing
│   │   └── heater_controller.py      # Heater sequencing
│   │
│   ├── fault_management/             # Fault handling
│   │   ├── __init__.py
│   │   ├── fault_detector.py         # Fault detection from PV callbacks
│   │   ├── fault_classifier.py       # Fault type classification
│   │   ├── recovery_sequencer.py     # Automated recovery sequences
│   │   └── fault_logger.py           # Structured fault event logging
│   │
│   ├── diagnostics/                  # Diagnostics and waveform tools
│   │   ├── __init__.py
│   │   ├── waveform_capture.py       # LLRF9 waveform readout
│   │   ├── waveform_buffer_reader.py # Waveform buffer data readout
│   │   ├── system_health.py          # Subsystem health monitoring
│   │   └── performance_monitor.py    # Control loop timing metrics
│   │
│   ├── config_management/            # Configuration
│   │   ├── __init__.py
│   │   ├── config_loader.py          # YAML configuration loading
│   │   ├── config_validator.py       # Configuration validation
│   │   ├── save_restore.py           # LLRF9 PV save/restore wrapper
│   │   └── profile_manager.py        # Named profile management
│   │
│   ├── calibration/                  # Commissioning tools
│   │   ├── __init__.py
│   │   ├── vector_sum_setup.py       # Port of vector_sum_setup.m
│   │   ├── phase_nulling.py          # Port of null_phases.m
│   │   ├── loop_tuning.py            # Feedback loop optimization
│   │   └── channel_calibration.py    # RF channel calibration
│   │
│   └── logging_utils/                # Logging infrastructure
│       ├── __init__.py
│       ├── structured_logger.py      # JSON structured logging
│       └── event_types.py            # Event type definitions
│
├── tests/
│   ├── conftest.py                   # Shared fixtures, mock hardware
│   ├── mocks/
│   │   ├── mock_llrf9.py             # Simulated LLRF9 IOC
│   │   ├── mock_hvps.py              # Simulated HVPS PLC
│   │   ├── mock_mps.py               # Simulated MPS PLC
│   │   └── mock_motors.py            # Simulated motor controller
│   ├── unit/
│   │   ├── test_state_machine.py
│   │   ├── test_hvps_controller.py
│   │   ├── test_tuner_controller.py
│   │   ├── test_load_angle.py
│   │   ├── test_fault_management.py
│   │   └── test_config_management.py
│   └── integration/
│       ├── test_full_startup.py
│       ├── test_fault_recovery.py
│       └── test_mode_transitions.py
│
├── edm/                              # EDM operator panels
│   ├── rf_station_top.edl            # Top-level station overview
│   ├── state_machine.edl             # State machine control
│   ├── hvps_control.edl              # HVPS supervisory panel
│   ├── tuner_overview.edl            # 4-cavity tuner status
│   ├── fault_summary.edl             # Fault status and history
│   ├── diagnostics.edl               # Waveform and diagnostic displays
│   └── heater_control.edl            # Heater panel
│
└── scripts/
    ├── start_coordinator.sh          # Startup script
    ├── stop_coordinator.sh           # Shutdown script
    └── setup_epics_env.sh            # EPICS CA environment setup
```

---

## 4. Module Decomposition

### 4.1 Module Dependency Graph

```
                         ┌───────────────┐
                         │  coordinator   │
                         │   (main.py)    │
                         └───────┬────────┘
                                 │ owns all modules
          ┌──────────┬───────────┼────────────┬──────────────┐
          │          │           │            │              │
    ┌─────┴─────┐ ┌──┴───┐ ┌────┴────┐ ┌────┴────┐ ┌───────┴──────┐
    │  state    │ │ hvps │ │  tuner  │ │  fault  │ │   config     │
    │  machine  │ │ ctrl │ │  mgr    │ │  mgr    │ │   mgr        │
    └─────┬─────┘ └──┬───┘ └────┬────┘ └────┬────┘ └───────┬──────┘
          │          │           │            │              │
          └──────────┴───────────┴────────────┴──────────────┘
                                 │
                         ┌───────┴────────┐
                         │  epics_layer   │
                         │  (PV manager   │
                         │   + interfaces)│
                         └────────────────┘
```

### 4.2 Module Responsibilities

| Module | Responsibility | Inputs | Outputs | Rate |
|--------|---------------|--------|---------|------|
| `coordinator` | Top-level orchestration, thread management, startup/shutdown | Command queue | Module coordination | 1 Hz |
| `state_machine` | Station state transitions (OFF→PARK→TUNE→ON_CW), guards, sequencing | All subsystem status | State commands to all modules | 1 Hz |
| `hvps_controller` | Monitor klystron drive power, adjust HVPS voltage setpoint | LLRF9 kly fwd power, HVPS readbacks | HVPS voltage setpoint | ≤1 Hz |
| `tuner_manager` | Coordinate 4 independent tuner controllers | LLRF9 phase data (10 Hz) | Motor commands | 1 Hz |
| `tuner_controller` | Single-cavity phase→motor feedback | Cavity probe phase | Step commands | 1 Hz |
| `load_angle_controller` | Balance gap voltage across 4 cavities | 4 cavity amplitudes | Tuner offset adjustments | 0.1 Hz |
| `fault_manager` | Detect, classify, log faults; coordinate recovery | Interlock PVs, MPS status | Fault events, recovery commands | Event-driven |
| `mps_coordinator` | Interface with MPS PLC permits and reset | MPS PVs | Reset commands, permit queries | Event-driven |
| `heater_controller` | Automated warm-up/standby/cool-down sequences | Heater PVs | SCR setpoint, enable/disable | As needed |
| `waveform_buffer_mgr` | Read waveform data, configure thresholds | WF buffer PVs | Waveform data, collector power | Event-driven |
| `config_manager` | Load/save/validate configurations | YAML files, PV values | Configuration parameters | On demand |
| `diagnostics` | System health monitoring, performance metrics | All PVs | Health reports, alerts | 1 Hz |


---

## 5. EPICS Integration Layer

### 5.1 PV Manager (`pv_manager.py`)

The PV Manager is the single point of contact for all EPICS Channel Access operations:

```python
class PVManager:
    """Central EPICS Channel Access manager.
    
    Responsibilities:
    - Maintain connection pool to all IOCs
    - Cache latest PV values (thread-safe)
    - Set up monitors (subscriptions) for critical PVs
    - Batch read/write operations
    - Handle connection timeouts and reconnections
    """
    
    def __init__(self, pv_map: dict, ca_config: dict):
        self.pv_map = pv_map          # From pv_map.yaml
        self.cache = PVCache()         # Thread-safe value cache
        self.monitors = {}             # Active CA monitor subscriptions
        self.callbacks = {}            # User-registered callbacks
        
    def connect_all(self) -> dict:
        """Connect to all PVs in pv_map, return connection status."""
        
    def get(self, logical_name: str) -> Any:
        """Read cached value by logical name (e.g., 'llrf1.brd1.fb.aset')."""
        
    def put(self, logical_name: str, value: Any, wait: bool = False):
        """Write value by logical name."""
        
    def monitor(self, logical_name: str, callback: Callable):
        """Subscribe to PV changes with callback."""
        
    def batch_get(self, names: list[str]) -> dict:
        """Read multiple PVs efficiently."""
        
    def batch_put(self, values: dict):
        """Write multiple PVs efficiently."""
```

### 5.2 LLRF9 Interface (`llrf9_interface.py`)

Abstraction for a single LLRF9 unit. Two instances are created — one for Unit 1 (field control) and one for Unit 2 (monitoring):

```python
class LLRF9Interface:
    """Interface to one LLRF9 unit via EPICS Channel Access.
    
    Provides typed, validated access to all LLRF9 PVs with logical
    names that hide the raw PV naming convention.
    """
    
    def __init__(self, pv_mgr: PVManager, unit_prefix: str):
        # unit_prefix = "LLRF1" or "LLRF2"
        self.prefix = unit_prefix
        self.pv = pv_mgr
    
    # --- Feedback Control (Unit 1 only) ---
    def set_amplitude_setpoint(self, board: int, value: float): ...
    def set_phase_setpoint(self, board: int, value: float): ...
    def set_feedback_mode(self, board: int, mode: str): ...
    def enable_dac(self, board: int, enable: bool): ...
    
    # --- Scalar Readbacks (both units) ---
    def get_cavity_amplitude(self, cavity: int) -> float: ...
    def get_cavity_phase(self, cavity: int) -> float: ...
    def get_all_amplitudes(self) -> dict[int, float]: ...
    def get_all_phases(self) -> dict[int, float]: ...
    
    # --- Rotator Configuration (Unit 1, BRD1) ---
    def configure_vector_sum(self, cav1_gain, cav1_phase,
                              cav2_gain, cav2_phase): ...
    def configure_proportional_loop(self, gain, phase): ...
    
    # --- Tuner PVs ---
    def get_tuner_phase(self, cavity: int) -> float: ...
    def set_tuner_offset(self, cavity: int, offset: float): ...
    def set_tuner_loop_state(self, cavity: int, closed: bool): ...
    
    # --- Interlocks ---
    def get_interlock_status(self) -> dict: ...
    def get_system_interlock(self) -> bool: ...
    
    # --- Waveform Acquisition ---
    def trigger_waveform_capture(self, board: int): ...
    def get_waveform_data(self, board: int) -> dict: ...
    
    # --- Setpoint Profiles ---
    def load_ramp_profile(self, board: int, amp_profile, 
                          phase_profile, time_profile): ...
    def trigger_ramp(self, board: int): ...
    
    # --- Save/Restore ---
    def save_configuration(self, filename: str): ...
    def restore_configuration(self, filename: str): ...
    
    # --- Housekeeping ---
    def get_temperatures(self) -> dict: ...
    def get_fan_speeds(self) -> dict: ...
    def get_revision(self) -> str: ...
```

### 5.3 HVPS Interface (`hvps_interface.py`)

```python
class HVPSInterface:
    """Interface to HVPS CompactLogix PLC via EPICS."""
    
    def __init__(self, pv_mgr: PVManager):
        self.pv = pv_mgr
    
    def set_voltage_setpoint(self, voltage_kv: float): ...
    def get_voltage_readback(self) -> float: ...
    def get_current_readback(self) -> float: ...
    def get_status_ready(self) -> bool: ...
    def get_interlocks(self) -> dict: ...
    def command_contactor(self, on: bool): ...
    def get_contactor_status(self) -> bool: ...
    def get_temperatures(self) -> dict: ...
```

### 5.4 MPS Interface (`mps_interface.py`)

```python
class MPSInterface:
    """Interface to Kly MPS ControlLogix PLC via EPICS."""
    
    def __init__(self, pv_mgr: PVManager):
        self.pv = pv_mgr
    
    def get_permit_status(self) -> bool: ...
    def get_active_faults(self) -> int: ...
    def get_first_fault(self) -> str: ...
    def get_fault_count(self) -> int: ...
    def command_reset(self): ...
    def get_all_status(self) -> dict: ...
```


---

## 6. Station State Machine

### 6.1 State Definitions

The station state machine replaces the legacy `rf_states.st` (2,227 lines of SNL). The upgraded states are:

```
     ┌──────┐
     │ OFF  │ ← Power off, all subsystems idle
     └──┬───┘
        │ cmd: PARK (requires: heater ready, MPS permit, HVPS ready)
        ▼
     ┌──────┐
     │ PARK │ ← Tuners at park position, HVPS off, heater warm
     └──┬───┘
        │ cmd: TUNE (requires: PARK complete)
        ▼
     ┌──────┐
     │ TUNE │ ← Tuners moving to ON positions, HVPS ramping to turn-on voltage
     └──┬───┘
        │ cmd: ON (requires: tuners at ON position, HVPS at turn-on voltage)
        ▼
     ┌───────┐
     │ ON_CW │ ← Full RF operation: feedback closed, HVPS at operating voltage
     └───┬───┘
         │ any fault → FAULT
         ▼
     ┌───────┐
     │ FAULT │ ← Fault condition: hardware protection active, software logging
     └───────┘
         │ cmd: RESET (requires: fault cleared, MPS permit restored)
         │ → returns to PARK or OFF depending on fault severity
```

### 6.2 State Machine Implementation

```python
from enum import Enum, auto
from dataclasses import dataclass
from typing import Optional
import time

class StationState(Enum):
    OFF = auto()
    PARK = auto()
    TUNE = auto()
    ON_CW = auto()
    FAULT = auto()

@dataclass
class TransitionGuard:
    """Conditions that must be met for a state transition."""
    name: str
    check: callable    # Returns (bool, str) — (passed, reason)
    
@dataclass  
class StateTransition:
    """Defines a valid state transition with guards and actions."""
    from_state: StationState
    to_state: StationState
    command: str
    guards: list[TransitionGuard]
    entry_action: callable     # Executed on entering new state
    timeout_seconds: float     # Max time for transition completion

class StateMachineEngine:
    """Executes the station state machine.
    
    Called once per main loop cycle (~1 Hz). Evaluates guards,
    executes transitions, and manages timeout monitoring.
    """
    
    def __init__(self, transitions: list[StateTransition],
                 fault_manager, logger):
        self.current_state = StationState.OFF
        self.transitions = transitions
        self.fault_mgr = fault_manager
        self.logger = logger
        self.transition_start_time = None
        self.pending_transition = None
        
    def request_transition(self, command: str) -> tuple[bool, str]:
        """Request a state transition by command name.
        Returns (accepted, reason)."""
        
    def tick(self):
        """Called every main loop cycle.
        Checks guards, monitors timeouts, handles fault injection."""
        # 1. Check for fault conditions (always, regardless of state)
        if self.fault_mgr.has_active_fault():
            self._enter_fault_state()
            return
        # 2. If transition pending, check completion guards
        if self.pending_transition:
            self._check_transition_progress()
        # 3. Execute state-specific periodic logic
        self._execute_state_logic()
```

### 6.3 State Entry/Exit Actions

| State | Entry Actions | Periodic Actions | Exit Actions |
|-------|--------------|------------------|-------------|
| **OFF** | Verify all subsystems idle; disable all control loops | Monitor subsystem health | None |
| **PARK** | Enable heater warm-up; command tuners to park positions; verify MPS permit | Monitor heater temp, tuner positions, MPS | Stop heater if going to OFF |
| **TUNE** | Command tuners to ON positions; ramp HVPS to turn-on voltage (~50 kV); configure LLRF9 vector sum; close LLRF9 feedback in open-loop at low power | Monitor tuner convergence, HVPS voltage, phase errors | Stop HVPS ramp if aborting |
| **ON_CW** | Trigger LLRF9 setpoint ramp profile; close feedback loop; enable HVPS supervisory loop; enable tuner loops; enable load angle balancing | Run all control loops; monitor all parameters | Disable all loops; zero LLRF9 DAC |
| **FAULT** | Log fault event; capture waveforms; disable control loops; record first-fault | Display fault info; await operator reset | Clear fault on reset |

### 6.4 Turn-On Sequence Detail (TUNE → ON_CW)

This replaces the multi-step turn-on in legacy `rf_states.st`. The LLRF9's setpoint profile system handles the critical ramp:

```
Step 1: Verify prerequisites
  - All 4 tuners at ON position (phase error < deadband)
  - HVPS at turn-on voltage (~50 kV)
  - LLRF9 Unit 1 BRD1 feedback in closed-loop
  - MPS permit active
  - Interface Chassis all permits OK (via MPS readback)

Step 2: Load LLRF9 setpoint profile
  - Load 512-point amplitude ramp into LLRF1:BRD1:RAMP:PROFILE
  - Configure step time (e.g., 1 ms per step → 512 ms total ramp)
  - Set RAMP:ASTART to current low-power setpoint
  - Set RAMP:AEND to operating amplitude setpoint

Step 3: Enable HVPS supervisory loop
  - Start hvps_controller thread
  - Initial target: maintain drive power within ±deadband

Step 4: Trigger LLRF9 ramp
  - caput LLRF1:BRD1:RAMP:TRIGEN 1
  - LLRF9 FPGA executes the profile autonomously (70 µs to 37 ms/step)
  - Monitor LLRF1:BRD1:FB:ASET readback to track ramp progress

Step 5: Ramp HVPS to operating voltage
  - Coordinate with HVPS PLC: increase voltage setpoint in steps
  - Each step: wait for HVPS readback to settle, then increment
  - Target: ~74.7 kV at 500 mA beam current

Step 6: Enable all supervisory loops
  - Enable 4 tuner control loops
  - Enable load angle balancing
  - System is now in ON_CW steady state
```


---

## 7. HVPS Supervisory Controller

### 7.1 Purpose

Replaces legacy `rf_hvps_loop.st` (343 lines). Maintains klystron drive power within target range by adjusting HVPS voltage setpoint. This is a slow (~1 Hz) coordination loop between the LLRF9 (which controls RF field) and the HVPS PLC (which controls cathode voltage).

### 7.2 Control Algorithm

```python
class HVPSController:
    """HVPS supervisory voltage regulation loop.
    
    Reads klystron forward power from LLRF9 Unit 1.
    Adjusts HVPS voltage setpoint to maintain drive power
    within the target range defined in configuration.
    
    Replaces legacy rf_hvps_loop.st.
    """
    
    def __init__(self, llrf1: LLRF9Interface, hvps: HVPSInterface, 
                 config: dict):
        self.llrf1 = llrf1
        self.hvps = hvps
        self.enabled = False
        # From config/hvps.yaml:
        self.power_target = config['power_target']        # Target drive power
        self.power_deadband = config['power_deadband']    # ±deadband
        self.max_delta_v = config['max_delta_v_per_step'] # Max voltage step/cycle
        self.voltage_min = config['voltage_min']          # ~50 kV (turn-on)
        self.voltage_max = config['voltage_max']          # ~90 kV (absolute max)
        self.collector_power_limit = config['collector_power_limit']
    
    def tick(self):
        """Called once per control cycle (≤1 Hz)."""
        if not self.enabled:
            return
        
        # 1. Read klystron forward power from LLRF9
        kly_fwd_power = self.llrf1.get_klystron_forward_power()
        
        # 2. Read HVPS voltage and current
        hvps_voltage = self.hvps.get_voltage_readback()
        hvps_current = self.hvps.get_current_readback()
        
        # 3. Check collector power protection (DC power - RF power)
        dc_power = abs(hvps_voltage) * hvps_current
        collector_power = dc_power - kly_fwd_power
        if collector_power > self.collector_power_limit:
            self._reduce_voltage(hvps_voltage, emergency=True)
            return
        
        # 4. Adjust voltage to maintain drive power in target range
        power_error = kly_fwd_power - self.power_target
        
        if abs(power_error) < self.power_deadband:
            return  # Within deadband, no action
        
        if power_error > 0:  # Drive power too high
            delta_v = -self.max_delta_v  # Reduce voltage
        else:  # Drive power too low
            delta_v = +self.max_delta_v  # Increase voltage
        
        new_voltage = hvps_voltage + delta_v
        new_voltage = max(self.voltage_min, min(self.voltage_max, new_voltage))
        
        self.hvps.set_voltage_setpoint(new_voltage)
```

### 7.3 HVPS-LLRF9 Coordination During Recovery

When recovering from a fault, the HVPS and LLRF9 must be re-enabled through the Interface Chassis in the correct sequence (see Section 10 — Fault Management for the full recovery sequence).

---

## 8. Tuner Control Manager

### 8.1 Purpose

Replaces legacy `rf_tuner_loop.st` (555 lines). Manages 4 independent cavity tuner control loops using LLRF9 10 Hz phase measurements to command stepper motors via the Galil DMC-4143 controller.

### 8.2 Architecture

```python
class TunerManager:
    """Manages all 4 cavity tuner controllers.
    
    Coordinates tuner operations (parking, homing, ON positioning)
    and delegates per-cavity phase feedback to TunerController instances.
    """
    
    def __init__(self, llrf1: LLRF9Interface, motors: MotorInterface,
                 config: dict):
        self.tuners = [
            TunerController(cavity=i+1, llrf1=llrf1, motors=motors,
                          config=config['cavities'][i])
            for i in range(4)
        ]
        self.load_angle = LoadAngleController(llrf1, self.tuners, config)
    
    def park_all(self):
        """Command all tuners to park (retracted) positions."""
        for t in self.tuners: t.move_to_park()
    
    def home_all(self):
        """Move all tuners to ON home positions."""
        for t in self.tuners: t.move_to_on_position()
    
    def enable_loops(self):
        """Enable phase-feedback loops on all tuners."""
        for t in self.tuners: t.enable_loop()
    
    def disable_loops(self):
        """Disable all tuner feedback loops."""
        for t in self.tuners: t.disable_loop()
    
    def tick(self):
        """Called once per control cycle (1 Hz)."""
        for t in self.tuners:
            t.tick()
        self.load_angle.tick()  # Runs at 0.1 Hz internally


class TunerController:
    """Single-cavity tuner phase feedback controller.
    
    Reads cavity probe phase from LLRF9 (10 Hz), computes
    motor command, sends steps to Galil motor controller.
    
    Control law: PI controller on phase error.
    """
    
    def __init__(self, cavity: int, llrf1: LLRF9Interface,
                 motors: MotorInterface, config: dict):
        self.cavity = cavity
        self.llrf1 = llrf1
        self.motors = motors
        self.enabled = False
        # From config/tuners.yaml:
        self.phase_setpoint = config['phase_setpoint']    # Target phase (deg)
        self.deadband = config['deadband']                # Phase deadband (deg)
        self.gain_p = config['gain_p']                    # Proportional gain
        self.gain_i = config['gain_i']                    # Integral gain
        self.min_forward_power = config['min_forward_power']
        self.max_steps_per_cycle = config['max_steps']
        self.integral_sum = 0.0
    
    def tick(self):
        if not self.enabled:
            return
        
        # Read phase from LLRF9
        phase = self.llrf1.get_tuner_phase(self.cavity)
        fwd_power = self.llrf1.get_cavity_forward_power(self.cavity)
        
        # Only control when RF is on
        if fwd_power < self.min_forward_power:
            self.integral_sum = 0.0
            return
        
        # Phase error
        phase_error = phase - self.phase_setpoint
        # Wrap to [-180, 180]
        phase_error = (phase_error + 180) % 360 - 180
        
        if abs(phase_error) < self.deadband:
            return  # Within deadband
        
        # PI control
        self.integral_sum += phase_error
        command = self.gain_p * phase_error + self.gain_i * self.integral_sum
        
        # Clamp and command motor
        steps = int(max(-self.max_steps_per_cycle,
                       min(self.max_steps_per_cycle, command)))
        if steps != 0:
            self.motors.move_relative(self.cavity, steps)
```

---

## 9. Load Angle Balancer

### 9.1 Purpose

Balances gap voltage across all 4 cavities by adjusting individual tuner phase offsets. Extracted from legacy `rf_tuner_loop.st` load angle computation. Runs at ~0.1 Hz.

### 9.2 Algorithm

```python
class LoadAngleController:
    """Balances power distribution across 4 cavities.
    
    Reads all 4 cavity probe amplitudes from LLRF9,
    computes amplitude imbalance, and adjusts individual
    tuner phase offset PVs to redistribute power.
    """
    
    def __init__(self, llrf1: LLRF9Interface, tuners: list, config: dict):
        self.llrf1 = llrf1
        self.tuners = tuners
        self.enabled = False
        self.cycle_count = 0
        self.period = config.get('period_cycles', 10)  # Run every N ticks
        self.tolerance = config['amplitude_tolerance']
        self.offset_step = config['offset_step_degrees']
    
    def tick(self):
        self.cycle_count += 1
        if self.cycle_count < self.period or not self.enabled:
            return
        self.cycle_count = 0
        
        # Read all 4 cavity amplitudes
        amps = self.llrf1.get_all_amplitudes()
        target = sum(amps.values()) / 4.0  # Target = average
        
        for cav_id, amp in amps.items():
            error = amp - target
            if abs(error) > self.tolerance:
                # Adjust tuner phase offset to redistribute power
                delta_offset = -self.offset_step if error > 0 else self.offset_step
                current_offset = self.llrf1.get_tuner_offset(cav_id)
                self.llrf1.set_tuner_offset(cav_id, current_offset + delta_offset)
```

---

## 10. Fault Management System

### 10.1 Fault Detection

Faults are detected through EPICS PV monitor callbacks on critical interlock and status PVs:

```python
class FaultDetector:
    """Monitors interlock PVs and generates fault events.
    
    Sets up CA monitors on all interlock-related PVs. When any
    PV transitions to a faulted state, a FaultEvent is queued
    for processing by the main thread.
    """
    
    MONITORED_PVS = [
        'LLRF1:ILOCK:ALL',           # LLRF9 Unit 1 aggregate interlock
        'LLRF2:ILOCK:ALL',           # LLRF9 Unit 2 aggregate interlock
        'SRF1:MPS:PERMIT',           # MPS summary permit
        'SRF1:MPS:FAULTS:FIRST',     # First-fault from Interface Chassis
        'SRF1:HVPS:STATUS:READY',    # HVPS ready status
        'SRF1:HVPS:INTLK:SUMMARY',   # HVPS interlock summary
        'SRF1:WFBUF:TRIP:SUMMARY',   # Waveform buffer trip
    ]
```

### 10.2 Fault Classification

| Fault Type | Source | Severity | Auto-Recovery | Action |
|-----------|--------|----------|---------------|--------|
| RF arc (cavity) | Arc detector → Interface Chassis → MPS | HIGH | Yes (after cooldown) | Capture waveforms, wait, auto-reset |
| RF overvoltage | LLRF9 FPGA interlock | HIGH | Yes | Capture waveforms, wait, auto-reset |
| HVPS overcurrent | HVPS PLC | HIGH | No | Capture waveforms, operator intervention |
| HVPS crowbar | HVPS hardware | CRITICAL | No | Full shutdown, operator intervention |
| MPS permit lost | External (SPEAR MPS) | HIGH | Yes (when permit returns) | Hold in FAULT, auto-recover on permit |
| Collector power | Waveform Buffer | HIGH | No | Reduce HVPS voltage, operator review |
| Tuner fault | Motor controller | MEDIUM | Yes | Re-home tuner, resume |
| Heater fault | Heater controller | MEDIUM | Depends | Evaluate heater status |
| Communication loss | EPICS CA timeout | LOW | Yes | Retry connections, degrade gracefully |

### 10.3 Recovery Sequencing

The recovery sequencer handles the critical LLRF9-HVPS feedback loop problem identified in the Interface Chassis design (`11_INTERFACE_CHASSIS_DESIGN.md`, Section 7):

```python
class RecoverySequencer:
    """Coordinates fault recovery across all subsystems.
    
    Handles the Interface Chassis LLRF9-HVPS feedback loop:
    When IC removes enables, both LLRF9 and HVPS status go low,
    creating additional 'consequential' fault inputs. Recovery
    must follow strict sequencing to break this loop.
    """
    
    def execute_standard_recovery(self):
        """Standard fault recovery sequence.
        
        Follows the 5-step recovery specified in the
        Interface Chassis design document.
        """
        # Step 1: Confirm HVPS is off
        self._wait_for_hvps_off()
        
        # Step 2: Verify HVPS STATUS reflects actual state
        self._verify_hvps_status_consistent()
        
        # Step 3: Request MPS reset (clears Interface Chassis latches)
        self.mps.command_reset()
        
        # Step 4: Verify LLRF9 Enable restored
        self._wait_for_llrf9_enable()
        
        # Step 5: Verify HVPS SCR ENABLE restored
        self._wait_for_hvps_scr_enable()
        
        # Step 6: Transition state machine back to PARK
        self.state_machine.request_transition('PARK')
```


---

## 11. Heater Controller Interface

Replaces the legacy motor-driven variac system. The Python module manages automated warm-up, standby, and cool-down sequences for the SCR-based heater controller.

**Key PVs**: `SRF1:HTR:VOLT:SET`, `SRF1:HTR:VOLT:RBK`, `SRF1:HTR:CURR:RBK`, `SRF1:HTR:POWER:RBK`, `SRF1:HTR:ENABLE`, `SRF1:HTR:STATUS`

**Sequences**: Warm-up (controlled ramp over 3–5 minutes), Standby (reduced power), Cool-down (gradual reduction), Emergency off (immediate disable).

**Coordination**: Heater must be at operating temperature before HVPS enable is permitted (state machine guard). HVPS must be off before heater cool-down begins.

---

## 12. Waveform Buffer Interface

Interfaces with the new Waveform Buffer System for extended RF monitoring, HVPS signal monitoring, and enhanced collector power protection.

**Key PVs**: `SRF1:WFBUF:CHn:DATA` (waveform arrays), `SRF1:WFBUF:CHn:THRESHOLD`, `SRF1:WFBUF:TRIP:SUMMARY`, `SRF1:WFBUF:COLL:POWER`, `SRF1:WFBUF:COLL:LIMIT`

**Functions**: Configure comparator thresholds, read circular buffer waveforms on fault trigger, monitor collector power calculation, read pre-fault data (~100 ms).

---

## 13. MPS Coordination Module

Interfaces with the Kly MPS ControlLogix PLC for permit management, fault status readback, and reset coordination.

**Key PVs**: `SRF1:MPS:PERMIT`, `SRF1:MPS:FAULTS:ACTIVE`, `SRF1:MPS:FAULTS:FIRST`, `SRF1:MPS:FAULTS:COUNT`, `SRF1:MPS:RESET`

**Responsibilities**: Query permit status before state transitions, read first-fault identification from Interface Chassis (via MPS), issue reset commands to clear Interface Chassis latched faults, read arc detection sensor identification (5-bit latch via MPS).

---

## 14. Configuration Management

### 14.1 Configuration File Structure

All operational parameters are externalized to YAML files:

```yaml
# config/station.yaml — Master configuration
station:
  name: "SPEAR3 RF Station"
  llrf9_unit1_prefix: "LLRF1"
  llrf9_unit2_prefix: "LLRF2"
  hvps_prefix: "SRF1:HVPS"
  mps_prefix: "SRF1:MPS"
  motor_prefix: "SRF1:MTR"
  wfbuf_prefix: "SRF1:WFBUF"
  heater_prefix: "SRF1:HTR"

epics:
  ca_addr_list: "192.168.1.10 192.168.1.11 192.168.1.20 192.168.1.30"
  ca_max_array_bytes: 26000000
  ca_auto_addr_list: "NO"
  connection_timeout: 5.0
  monitor_rate_hz: 10

# config/hvps.yaml — HVPS control parameters
hvps:
  power_target: 50.0          # W (klystron drive power target)
  power_deadband: 2.0         # W
  max_delta_v_per_step: 0.5   # kV per control cycle
  voltage_min: 50.0           # kV (turn-on voltage)
  voltage_max: 90.0           # kV (absolute maximum)
  voltage_operating: 74.7     # kV (nominal at 500 mA beam)
  collector_power_limit: 800  # kW
  ramp_time_constant: 0.76    # seconds (legacy τ = 0.76 s)

# config/tuners.yaml — Per-cavity tuner parameters
tuners:
  cavities:
    - name: "Cavity A"
      phase_setpoint: 0.0
      deadband: 1.0           # degrees
      gain_p: 0.5
      gain_i: 0.05
      min_forward_power: 10.0  # W
      max_steps: 100
      on_position: 10.3       # mm
      park_position: 0.0      # mm
    - name: "Cavity B"
      # ... similar for B, C, D
  load_angle:
    period_cycles: 10          # Run every 10 ticks (= 0.1 Hz)
    amplitude_tolerance: 0.01  # Relative amplitude tolerance
    offset_step_degrees: 0.1   # Phase offset step per adjustment
```

### 14.2 LLRF9 Save/Restore

Wraps the LLRF9's built-in CWget/CWput mechanism:

```python
class SaveRestoreManager:
    """Manages LLRF9 configuration save/restore with versioning."""
    
    def save_snapshot(self, name: str, description: str):
        """Save current LLRF9 PV values to named snapshot."""
        
    def restore_snapshot(self, name: str):
        """Restore LLRF9 PVs from named snapshot."""
        
    def list_snapshots(self) -> list[dict]:
        """List all available snapshots with metadata."""
        
    def compare_snapshots(self, name1: str, name2: str) -> dict:
        """Compare two snapshots, return differences."""
```

---

## 15. Logging and Diagnostics

### 15.1 Structured Event Logging

All events are logged as structured JSON for machine-parseable analysis:

```json
{
  "timestamp": "2026-03-12T10:30:45.123Z",
  "event_type": "STATE_TRANSITION",
  "severity": "INFO",
  "module": "state_machine",
  "data": {
    "from_state": "TUNE",
    "to_state": "ON_CW",
    "trigger": "operator_command",
    "duration_seconds": 12.5
  }
}
```

### 15.2 Fault Event Records

```json
{
  "timestamp": "2026-03-12T10:45:12.456Z",
  "event_type": "FAULT",
  "severity": "HIGH",
  "module": "fault_detector",
  "data": {
    "fault_type": "RF_ARC",
    "first_fault_source": "ARC_DETECTOR_CAV_A",
    "mps_permit": false,
    "llrf1_interlock": true,
    "llrf2_interlock": true,
    "hvps_status": false,
    "waveform_captured": true,
    "waveform_file": "/data/waveforms/2026-03-12_104512_arc.h5"
  }
}
```

---

## 16. Operator Interface

### 16.1 EDM Panel Hierarchy

```
rf_station_top.edl          ← Primary operator display
  ├── state_machine.edl     ← State control + status
  ├── hvps_control.edl      ← HVPS voltage/power
  ├── tuner_overview.edl    ← 4-cavity tuner status
  │   └── tuner_detail.edl  ← Per-cavity tuner detail
  ├── fault_summary.edl     ← Active faults + history
  ├── heater_control.edl    ← Heater sequences
  └── diagnostics.edl       ← Waveforms + health
```

### 16.2 Coordinator-Published PVs

The coordinator publishes its own PVs for operator display:

| PV | Type | Description |
|----|------|-------------|
| `SRF1:COORD:STATE` | ENUM | Current station state |
| `SRF1:COORD:STATE:MSG` | STRING | State description text |
| `SRF1:COORD:FAULT:ACTIVE` | BINARY | Fault condition active |
| `SRF1:COORD:FAULT:FIRST` | STRING | First-fault identification |
| `SRF1:COORD:FAULT:MSG` | STRING | Fault description |
| `SRF1:COORD:HVPS:LOOP` | BINARY | HVPS loop enabled |
| `SRF1:COORD:TUNER:n:LOOP` | BINARY | Per-cavity tuner loop enabled |
| `SRF1:COORD:LOADANGLE:LOOP` | BINARY | Load angle loop enabled |
| `SRF1:COORD:HEALTH` | ENUM | Overall system health |
| `SRF1:COORD:UPTIME` | REAL | Coordinator uptime (seconds) |

---

## 17. Calibration and Commissioning Tools

### 17.1 Vector Sum Setup (`vector_sum_setup.py`)

Python port of the MATLAB `vector_sum_setup.m` algorithm (see `3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md`, Section 10.4):

1. Set Cavity 1 rotation gain to 1.0, phase to 0.0
2. Read scalar amplitude ratios of both cavities
3. Adjust `ROT:CAV2:GAIN` to match amplitude ratio
4. Scale `ROT:P_OL:GAIN` to match reference signal
5. Trim `ROT:P_OL:PHASE` for correct phase alignment
6. Copy proportional loop settings to closed-loop rotators
7. Adjust phase offsets for readback consistency

### 17.2 Phase Nulling (`phase_nulling.py`)

Port of `null_phases.m`. Adjusts `CHn:PH_OFFSET` PVs to zero out systematic phase offsets.

### 17.3 Loop Tuning (`loop_tuning.py`)

Uses the LLRF9 built-in RTNA (Real-Time Network Analyzer) for automated loop optimization:
1. Configure RTNA sweep parameters
2. Measure open-loop transfer function
3. Fit cavity response model (Lorentzian)
4. Calculate optimal proportional and integral gains
5. Apply and verify closed-loop stability

---

## 18. Testing Strategy

### 18.1 Testing Levels

| Level | Scope | Hardware Required | Tools |
|-------|-------|-------------------|-------|
| Unit tests | Individual module logic | None (mocked) | pytest |
| Integration tests | Multi-module interactions | None (simulated IOCs) | pytest + caproto |
| Hardware-in-loop | Full coordinator + real IOCs | LLRF9 units, PLCs | Live EPICS CA |
| System tests | Complete RF station | All subsystems | Operational procedures |

### 18.2 Mock Hardware

Each hardware interface has a mock implementation using caproto simulated IOCs:

```python
# tests/mocks/mock_llrf9.py
class MockLLRF9(caproto.server.PVGroup):
    """Simulated LLRF9 IOC for testing.
    Provides all PVs used by the coordinator with configurable responses.
    """
    amplitude = pvproperty(value=0.0, name='BRD1:CH0:AMP')
    phase = pvproperty(value=0.0, name='BRD1:CH0:PHASE')
    interlock = pvproperty(value=0, name='ILOCK:ALL')
    # ... all monitored PVs
```

---

## 19. Deployment Architecture

### 19.1 Runtime Environment

- **Host**: Dedicated Linux server in Building B132 (co-located with LLRF9 units)
- **OS**: Rocky Linux 9 (or RHEL equivalent, per SLAC standard)
- **Python**: System Python 3.10+ or conda environment
- **Process management**: systemd service unit
- **Log storage**: Local disk + EPICS Archiver for PV history

### 19.2 systemd Service

```ini
[Unit]
Description=SPEAR3 RF Station Coordinator
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=rfoper
WorkingDirectory=/opt/spear3_rf_coordinator
ExecStart=/opt/spear3_rf_coordinator/venv/bin/python -m src.main
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```


---

## 20. PV Namespace and Interface Catalog

### 20.1 Complete PV Namespace

| IOC | Prefix | Source | PV Count (approx) | Update Rate |
|-----|--------|--------|--------------------|-------------|
| LLRF9 Unit 1 | `LLRF1:` | Built-in Linux IOC | 550+ (config) + 100+ (readback) | 10 Hz (scalars) |
| LLRF9 Unit 2 | `LLRF2:` | Built-in Linux IOC | 550+ (config) + 100+ (readback) | 10 Hz (scalars) |
| HVPS CompactLogix | `SRF1:HVPS:` | External EPICS gateway | ~30 | ~1 Hz |
| Kly MPS ControlLogix | `SRF1:MPS:` | External EPICS gateway | ~20 | ~1 Hz |
| Motor Controller | `SRF1:MTR:` | EPICS motor record IOC | ~40 (10/axis × 4) | On demand |
| Waveform Buffer | `SRF1:WFBUF:` | Dedicated IOC | ~50 | ~1 Hz / event |
| Heater Controller | `SRF1:HTR:` | Dedicated IOC | ~20 | 10 Hz |
| Python Coordinator | `SRF1:COORD:` | caproto server | ~20 | ~1 Hz |

### 20.2 Critical PV Cross-Reference

**PVs read by State Machine:**

| Logical Name | EPICS PV | Source | Purpose |
|-------------|----------|--------|---------|
| mps_permit | `SRF1:MPS:PERMIT` | MPS PLC | Gate all state transitions |
| hvps_ready | `SRF1:HVPS:STATUS:READY` | HVPS PLC | Gate TUNE→ON_CW |
| hvps_voltage | `SRF1:HVPS:VOLT:RBCK` | HVPS PLC | Monitor during ramp |
| llrf1_interlock | `LLRF1:ILOCK:ALL` | LLRF9 #1 | Detect RF faults |
| llrf2_interlock | `LLRF2:ILOCK:ALL` | LLRF9 #2 | Detect reflected power faults |
| heater_ready | `SRF1:HTR:STATUS` | Heater IOC | Gate OFF→PARK |
| first_fault | `SRF1:MPS:FAULTS:FIRST` | MPS PLC (from IC) | Fault diagnosis |

**PVs written by HVPS Controller:**

| Logical Name | EPICS PV | Destination | Purpose |
|-------------|----------|-------------|---------|
| hvps_setpoint | `SRF1:HVPS:VOLT:CTRL.VAL` | HVPS PLC | Voltage regulation |

**PVs read by Tuner Controller (per cavity):**

| Logical Name | EPICS PV (Cav A example) | Source | Purpose |
|-------------|--------------------------|--------|---------|
| probe_phase | `LLRF1:BRD1:CH0:PHASE` | LLRF9 #1 | Tuner feedback |
| probe_amp | `LLRF1:BRD1:CH0:AMP` | LLRF9 #1 | Load angle balancing |
| fwd_power | `LLRF1:BRD1:CH2:AMP` | LLRF9 #1 | Min power threshold |

**PVs written by Tuner Controller:**

| Logical Name | EPICS PV (Cav A example) | Destination | Purpose |
|-------------|--------------------------|-------------|---------|
| tuner_offset | `LLRF1:TUNER:C1:OFFSET` | LLRF9 #1 | Phase setpoint |
| tuner_close | `LLRF1:TUNER:C1:CLOSE` | LLRF9 #1 | Loop open/close |
| motor_move | `SRF1:MTR:C1.VAL` | Galil DMC-4143 | Motor position |

---

## 21. Risk and Mitigation

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Software is on critical path for Phase 3/4** | Critical | Begin framework and mock-interface development immediately; do not wait for hardware |
| **EPICS CA communication latency spikes** | Medium | Use monitors (not polling); implement timeout handling; validated during LLRF9 commissioning |
| **Interface Chassis recovery loop complexity** | High | Implement and test recovery sequencer with mock IC before hardware is ready |
| **Tuner motor controller reliability** | High | Test Galil on booster tuners first; implement motor fault detection and auto-retry |
| **Legacy SNL logic not fully understood** | Medium | Cross-reference legacy code comments and Jim Sebek's operational notes; build comprehensive test suite |
| **PV naming not finalized for all subsystems** | Medium | Use configuration-driven PV names (`pv_map.yaml`); update config without code changes |
| **Coordinator crash during RF operation** | Low (by design) | Hardware protection continues; systemd auto-restart in 5 seconds; all state is recoverable |
| **Configuration drift between environments** | Medium | Version-controlled YAML configs; named profiles; automated validation on startup |

---

## 22. Appendix: Legacy-to-Upgrade Traceability

### 22.1 SNL Program → Python Module Mapping

| Legacy SNL Program | Lines | Upgrade Python Module(s) | Notes |
|--------------------|-------|-------------------------|-------|
| `rf_states.st` | 2,227 | `state_machine/` (states, transitions, engine, sequences) | Core state machine; ON_FM state eliminated |
| `rf_hvps_loop.st` | 343 | `controllers/hvps_controller.py` | Simplified: PLC handles low-level regulation |
| `rf_tuner_loop.st` | 555 | `controllers/tuner_controller.py`, `tuner_manager.py`, `load_angle_controller.py` | Split into per-cavity + balancing modules |
| `rf_dac_loop.st` | 290 | **Eliminated** | LLRF9 handles drive power via FPGA; no software DAC loop needed |
| `rf_calib.st` | 2,800+ | `calibration/` (vector_sum_setup, phase_nulling, loop_tuning, channel_calibration) | Digital calibration replaces analog offset nulling; much faster |
| `rf_msgs.st` | 352 | `logging_utils/`, `fault_management/fault_logger.py` | TAXI error monitoring eliminated (no CAMAC); structured logging replaces message strings |

### 22.2 Eliminated Legacy Functions

| Function | Legacy Implementation | Why Eliminated |
|----------|----------------------|---------------|
| Ripple rejection loop | Analog CFM module | LLRF9 digital feedback inherently rejects power-line ripple |
| Comb filter loop | CFM module in VXI | LLRF9 FPGA handles multi-bunch stabilization |
| Gap voltage feedback (GVF) | Analog GVF module via CAMAC | LLRF9 vector sum feedback provides this |
| 4-way branching (DAC loop) | `rf_dac_loop.st` | LLRF9 controls all via single vector sum |
| TAXI error monitoring | `rf_msgs.st` | No CAMAC bus in upgrade; all Ethernet |
| Analog offset calibration | `rf_calib.st` (~20 min) | LLRF9 digital calibration stored in EEPROM; minutes, not 20 min |
| LFB resynchronization | `rf_msgs.st` (randomized delay) | No separate Low Frequency Bypass system; LLRF9 handles directly |

### 22.3 Source Document Cross-References

| Software Design Section | Source Documents |
|------------------------|------------------|
| §1 Design Philosophy | `0_PHYSICAL_DESIGN_REPORT.md` §14 (Control Software), §17 (Protection Chain) |
| §2 System Context | `0_PHYSICAL_DESIGN_REPORT.md` §2 (System Architecture), §15 (Control Loops) |
| §5 EPICS Layer | `3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` §2–3 (IOC, PV Architecture) |
| §6 State Machine | `0_PHYSICAL_DESIGN_REPORT.md` §14, legacy `rf_states.st` |
| §7 HVPS Controller | `4_HVPS_Engineering_Technical_Note.md` §14, legacy `rf_hvps_loop.st` |
| §8 Tuner Manager | `3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` §5, legacy `rf_tuner_loop.st` |
| §9 Load Angle | `3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` §5.2, §10.4 |
| §10 Fault Management | `11_INTERFACE_CHASSIS_DESIGN.md` §7 (Feedback Loop), `0_PHYSICAL_DESIGN_REPORT.md` §17 |
| §11 Heater Controller | `5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md` §3 |
| §12 Waveform Buffer | `0_PHYSICAL_DESIGN_REPORT.md` §11 |
| §13 MPS Coordination | `0_PHYSICAL_DESIGN_REPORT.md` §7 |
| §17 Calibration Tools | `3_LLRF9_SYSTEM_AND_SOFTWARE_REPORT.md` §10 (MATLAB toolkit) |

---

**End of Document**
