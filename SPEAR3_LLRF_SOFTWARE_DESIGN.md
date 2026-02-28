# SPEAR3 LLRF Upgrade Software Design

**Document Purpose**: Software architecture and implementation guide for the SPEAR3 LLRF upgrade Python/EPICS coordinator. This document focuses exclusively on software design, APIs, and implementation details. For hardware specifications and system architecture, refer to `SPEAR3_LLRF_UPGRADE_SYSTEM_DESIGN.md`.

**Version**: 4.0  
**Date**: February 2026  
**Status**: Implementation Ready  
**Author**: J. Sebek / Codegen AI Assistant

---

## Table of Contents

1. [Software Architecture Overview](#1-software-architecture-overview)
2. [Python Coordinator Framework](#2-python-coordinator-framework)
3. [EPICS Integration Layer](#3-epics-integration-layer)
4. [Station State Machine](#4-station-state-machine)
5. [HVPS Supervisory Control](#5-hvps-supervisory-control)
6. [Tuner Control Manager](#6-tuner-control-manager)
7. [Fault Management System](#7-fault-management-system)
8. [Configuration Management](#8-configuration-management)
9. [Operator Interface](#9-operator-interface)
10. [Testing Framework](#10-testing-framework)
11. [Deployment and Installation](#11-deployment-and-installation)
12. [API Reference](#12-api-reference)

---

## 1. Software Architecture Overview

### 1.1 Design Philosophy

The Python/EPICS coordinator is a **supervisory control layer** that orchestrates the distributed hardware subsystems. It operates at ~1 Hz and is NOT in the fast safety path. The coordinator's core responsibilities are:

1. **Station State Management**: Coordinate OFF/PARK/TUNE/ON_CW transitions
2. **HVPS Supervisory Loop**: Monitor drive power, adjust HVPS voltage setpoint
3. **Tuner Management**: Process LLRF9 phase measurements, command motor moves
4. **Load Angle Balancing**: Adjust individual cavity phase setpoints for power balance
5. **Fault Coordination**: Log faults, trigger diagnostics, manage recovery
6. **Operator Interface**: Provide modern control and monitoring capabilities

### 1.2 Software Stack

```
┌─────────────────────────────────────────────────────────────┐
│                 Operator Interface Layer                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Web Dashboard│  │ EPICS Screens│  │ Mobile/Tablet Apps  │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Python Coordinator Application                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ State       │  │ HVPS        │  │ Tuner Manager       │ │
│  │ Machine     │  │ Controller  │  │ + Load Angle        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Fault       │  │ Config      │  │ Logging &           │ │
│  │ Manager     │  │ Manager     │  │ Diagnostics         │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                EPICS Integration Layer                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ PyEPICS     │  │ PV Cache    │  │ Alarm Handler       │ │
│  │ Interface   │  │ Manager     │  │ + Callbacks         │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Hardware Subsystems                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ LLRF9 #1    │  │ LLRF9 #2    │  │ HVPS PLC            │ │
│  │ Built-in IOC│  │ Built-in IOC│  │ CompactLogix        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ MPS PLC     │  │ Motor Ctrl  │  │ Waveform Buffer     │ │
│  │ ControlLogix│  │ (Galil/etc) │  │ System              │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Key Design Principles

**Separation of Concerns**: Each module has a single, well-defined responsibility
**Hardware Abstraction**: All hardware interfaces go through the EPICS layer
**Configuration-Driven**: All operational parameters externalized to YAML files
**Fault Tolerance**: Graceful degradation when subsystems are unavailable
**Testability**: Mock interfaces for all hardware dependencies
**Maintainability**: Clear APIs, comprehensive logging, type hints throughout

### 1.4 Technology Stack

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Core Language** | Python | 3.9+ | Main application logic |
| **EPICS Interface** | PyEPICS | 3.5+ | Channel Access client |
| **Configuration** | PyYAML | 6.0+ | YAML configuration parsing |
| **Numerical** | NumPy | 1.21+ | Phase calculations, signal processing |
| **Logging** | Python logging | Built-in | Structured logging with rotation |
| **Concurrency** | asyncio | Built-in | Async I/O for concurrent operations |
| **Testing** | pytest | 7.0+ | Unit and integration testing |
| **Type Checking** | mypy | 0.991+ | Static type analysis |
| **Web Interface** | Flask/FastAPI | TBD | REST API for web dashboard |
| **Process Management** | systemd | System | Service management on Linux |

---

## 2. Python Coordinator Framework

### 2.1 Application Structure

```
spear3_llrf/
├── coordinator/
│   ├── __init__.py
│   ├── main.py                    # Application entry point
│   ├── state_machine.py           # Station state management
│   ├── hvps_controller.py         # HVPS supervisory loop
│   ├── tuner_manager.py           # Tuner control for 4 cavities
│   ├── load_angle_controller.py   # Power balancing loop
│   ├── fault_manager.py           # Fault detection and recovery
│   └── diagnostics.py             # System diagnostics and health
├── epics_interface/
│   ├── __init__.py
│   ├── pv_manager.py              # PV definitions and caching
│   ├── channel_access.py          # PyEPICS wrapper with error handling
│   ├── alarm_handler.py           # Alarm processing and callbacks
│   └── mock_interface.py          # Mock hardware for testing
├── config/
│   ├── station_config.yaml        # Station parameters
│   ├── hvps_config.yaml           # HVPS control parameters
│   ├── tuner_config.yaml          # Tuner and motor parameters
│   ├── fault_config.yaml          # Fault detection thresholds
│   └── pv_definitions.yaml        # All PV names and properties
├── web_interface/
│   ├── __init__.py
│   ├── api.py                     # REST API endpoints
│   ├── dashboard.py               # Web dashboard backend
│   └── static/                    # Web assets (HTML, CSS, JS)
├── utils/
│   ├── __init__.py
│   ├── logging_config.py          # Logging setup and formatters
│   ├── phase_calculations.py      # RF phase and power calculations
│   └── validation.py              # Configuration validation
├── tests/
│   ├── __init__.py
│   ├── test_state_machine.py
│   ├── test_hvps_controller.py
│   ├── test_tuner_manager.py
│   ├── test_fault_manager.py
│   └── fixtures/                  # Test data and mock configurations
└── scripts/
    ├── install.py                 # Installation and setup
    ├── start_coordinator.py       # Service startup script
    └── diagnostics.py             # System diagnostic tools
```

### 2.2 Core Application Class

```python
# coordinator/main.py
import asyncio
import logging
from typing import Dict, Optional
from dataclasses import dataclass
from pathlib import Path

from .state_machine import StationStateMachine
from .hvps_controller import HVPSController
from .tuner_manager import TunerManager
from .load_angle_controller import LoadAngleController
from .fault_manager import FaultManager
from ..epics_interface import EPICSInterface
from ..config import ConfigManager
from ..utils.logging_config import setup_logging

@dataclass
class CoordinatorStatus:
    """Overall coordinator status"""
    running: bool = False
    station_state: str = "OFF"
    fault_count: int = 0
    uptime_seconds: float = 0.0
    last_update: Optional[str] = None

class SPEAR3LLRFCoordinator:
    """
    Main coordinator application for SPEAR3 LLRF upgrade.
    
    Orchestrates all supervisory control functions:
    - Station state management
    - HVPS supervisory control
    - Tuner management and load angle balancing
    - Fault detection and recovery
    """
    
    def __init__(self, config_dir: Path):
        self.config_dir = config_dir
        self.logger = logging.getLogger(__name__)
        self.status = CoordinatorStatus()
        
        # Load configuration
        self.config = ConfigManager(config_dir)
        
        # Initialize EPICS interface
        self.epics = EPICSInterface(self.config.pv_definitions)
        
        # Initialize control modules
        self.state_machine = StationStateMachine(
            self.epics, self.config.station_config
        )
        self.hvps_controller = HVPSController(
            self.epics, self.config.hvps_config
        )
        self.tuner_manager = TunerManager(
            self.epics, self.config.tuner_config
        )
        self.load_angle_controller = LoadAngleController(
            self.epics, self.config.tuner_config
        )
        self.fault_manager = FaultManager(
            self.epics, self.config.fault_config
        )
        
        # Control loop tasks
        self._tasks: Dict[str, asyncio.Task] = {}
        self._shutdown_event = asyncio.Event()
    
    async def start(self) -> None:
        """Start the coordinator application"""
        self.logger.info("Starting SPEAR3 LLRF Coordinator")
        
        try:
            # Initialize EPICS connections
            await self.epics.initialize()
            
            # Start control modules
            await self.state_machine.start()
            await self.hvps_controller.start()
            await self.tuner_manager.start()
            await self.load_angle_controller.start()
            await self.fault_manager.start()
            
            # Start control loops
            self._tasks['state_machine'] = asyncio.create_task(
                self._run_state_machine_loop()
            )
            self._tasks['hvps_control'] = asyncio.create_task(
                self._run_hvps_loop()
            )
            self._tasks['tuner_control'] = asyncio.create_task(
                self._run_tuner_loop()
            )
            self._tasks['load_angle'] = asyncio.create_task(
                self._run_load_angle_loop()
            )
            self._tasks['fault_monitoring'] = asyncio.create_task(
                self._run_fault_monitoring_loop()
            )
            
            self.status.running = True
            self.logger.info("Coordinator started successfully")
            
            # Wait for shutdown signal
            await self._shutdown_event.wait()
            
        except Exception as e:
            self.logger.error(f"Failed to start coordinator: {e}")
            raise
        finally:
            await self.shutdown()
    
    async def shutdown(self) -> None:
        """Graceful shutdown of coordinator"""
        self.logger.info("Shutting down SPEAR3 LLRF Coordinator")
        
        self.status.running = False
        
        # Cancel all tasks
        for name, task in self._tasks.items():
            if not task.done():
                self.logger.info(f"Cancelling {name} task")
                task.cancel()
                try:
                    await task
                except asyncio.CancelledError:
                    pass
        
        # Shutdown modules
        await self.fault_manager.shutdown()
        await self.load_angle_controller.shutdown()
        await self.tuner_manager.shutdown()
        await self.hvps_controller.shutdown()
        await self.state_machine.shutdown()
        await self.epics.shutdown()
        
        self.logger.info("Coordinator shutdown complete")
    
    async def _run_state_machine_loop(self) -> None:
        """Main state machine control loop (~1 Hz)"""
        while self.status.running:
            try:
                await self.state_machine.update()
                self.status.station_state = self.state_machine.current_state
                await asyncio.sleep(1.0)  # 1 Hz update rate
            except Exception as e:
                self.logger.error(f"State machine loop error: {e}")
                await asyncio.sleep(1.0)
    
    async def _run_hvps_loop(self) -> None:
        """HVPS supervisory control loop (~1 Hz)"""
        while self.status.running:
            try:
                await self.hvps_controller.update()
                await asyncio.sleep(1.0)  # 1 Hz update rate
            except Exception as e:
                self.logger.error(f"HVPS control loop error: {e}")
                await asyncio.sleep(1.0)
    
    async def _run_tuner_loop(self) -> None:
        """Tuner control loop (~1 Hz)"""
        while self.status.running:
            try:
                await self.tuner_manager.update()
                await asyncio.sleep(1.0)  # 1 Hz update rate
            except Exception as e:
                self.logger.error(f"Tuner control loop error: {e}")
                await asyncio.sleep(1.0)
    
    async def _run_load_angle_loop(self) -> None:
        """Load angle balancing loop (~0.1 Hz)"""
        while self.status.running:
            try:
                await self.load_angle_controller.update()
                await asyncio.sleep(10.0)  # 0.1 Hz update rate
            except Exception as e:
                self.logger.error(f"Load angle loop error: {e}")
                await asyncio.sleep(10.0)
    
    async def _run_fault_monitoring_loop(self) -> None:
        """Fault monitoring loop (~10 Hz)"""
        while self.status.running:
            try:
                await self.fault_manager.update()
                await asyncio.sleep(0.1)  # 10 Hz update rate
            except Exception as e:
                self.logger.error(f"Fault monitoring loop error: {e}")
                await asyncio.sleep(0.1)

# Entry point
async def main():
    """Main entry point for the coordinator application"""
    import argparse
    
    parser = argparse.ArgumentParser(description='SPEAR3 LLRF Coordinator')
    parser.add_argument('--config-dir', type=Path, 
                       default=Path('/opt/spear3_llrf/config'),
                       help='Configuration directory')
    parser.add_argument('--log-level', default='INFO',
                       choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
                       help='Logging level')
    
    args = parser.parse_args()
    
    # Setup logging
    setup_logging(level=args.log_level)
    
    # Create and start coordinator
    coordinator = SPEAR3LLRFCoordinator(args.config_dir)
    
    try:
        await coordinator.start()
    except KeyboardInterrupt:
        logging.info("Received interrupt signal")
    except Exception as e:
        logging.error(f"Coordinator failed: {e}")
        raise

if __name__ == "__main__":
    asyncio.run(main())
```


---

## 3. EPICS Integration Layer

### 3.1 PV Manager

The PV Manager provides a centralized interface to all EPICS Process Variables with caching, error handling, and type safety.

```python
# epics_interface/pv_manager.py
import logging
from typing import Dict, Any, Optional, Union, Callable, List
from dataclasses import dataclass, field
from enum import Enum
import epics
import asyncio
from threading import Lock

class PVStatus(Enum):
    """PV connection and data status"""
    DISCONNECTED = "disconnected"
    CONNECTED = "connected"
    INVALID = "invalid"
    TIMEOUT = "timeout"

@dataclass
class PVDefinition:
    """Process Variable definition"""
    name: str
    description: str
    data_type: str  # 'float', 'int', 'string', 'enum'
    units: Optional[str] = None
    precision: Optional[int] = None
    limits: Optional[tuple] = None
    enum_strings: Optional[List[str]] = None
    timeout: float = 5.0

@dataclass
class PVValue:
    """Cached PV value with metadata"""
    value: Any
    timestamp: float
    status: PVStatus
    severity: str = "NO_ALARM"
    char_value: Optional[str] = None

class PVManager:
    """
    Centralized EPICS PV management with caching and error handling.
    
    Provides:
    - Automatic connection management
    - Value caching with timestamps
    - Alarm status monitoring
    - Callback registration
    - Mock interface for testing
    """
    
    def __init__(self, pv_definitions: Dict[str, PVDefinition], mock_mode: bool = False):
        self.pv_definitions = pv_definitions
        self.mock_mode = mock_mode
        self.logger = logging.getLogger(__name__)
        
        # PV objects and cached values
        self._pvs: Dict[str, epics.PV] = {}
        self._values: Dict[str, PVValue] = {}
        self._callbacks: Dict[str, List[Callable]] = {}
        self._lock = Lock()
        
        # Mock data for testing
        self._mock_values: Dict[str, Any] = {}
        
    async def initialize(self) -> None:
        """Initialize all PV connections"""
        self.logger.info(f"Initializing PV Manager ({'mock' if self.mock_mode else 'real'} mode)")
        
        if self.mock_mode:
            await self._initialize_mock_pvs()
        else:
            await self._initialize_real_pvs()
    
    async def _initialize_real_pvs(self) -> None:
        """Initialize real EPICS PV connections"""
        for pv_name, definition in self.pv_definitions.items():
            try:
                pv = epics.PV(
                    definition.name,
                    connection_timeout=definition.timeout,
                    auto_monitor=True
                )
                
                # Wait for connection
                if not pv.wait_for_connection(timeout=definition.timeout):
                    self.logger.warning(f"PV {pv_name} failed to connect")
                    self._values[pv_name] = PVValue(
                        value=None,
                        timestamp=0.0,
                        status=PVStatus.DISCONNECTED
                    )
                else:
                    self.logger.debug(f"PV {pv_name} connected")
                    self._values[pv_name] = PVValue(
                        value=pv.value,
                        timestamp=pv.timestamp,
                        status=PVStatus.CONNECTED,
                        severity=pv.severity,
                        char_value=pv.char_value
                    )
                
                # Set up callback for value changes
                pv.add_callback(self._pv_callback, index=pv_name)
                self._pvs[pv_name] = pv
                
            except Exception as e:
                self.logger.error(f"Failed to initialize PV {pv_name}: {e}")
                self._values[pv_name] = PVValue(
                    value=None,
                    timestamp=0.0,
                    status=PVStatus.INVALID
                )
    
    async def _initialize_mock_pvs(self) -> None:
        """Initialize mock PVs for testing"""
        for pv_name, definition in self.pv_definitions.items():
            # Set default mock values based on data type
            if definition.data_type == 'float':
                mock_value = 0.0
            elif definition.data_type == 'int':
                mock_value = 0
            elif definition.data_type == 'string':
                mock_value = ""
            elif definition.data_type == 'enum':
                mock_value = 0
            else:
                mock_value = None
            
            self._mock_values[pv_name] = mock_value
            self._values[pv_name] = PVValue(
                value=mock_value,
                timestamp=asyncio.get_event_loop().time(),
                status=PVStatus.CONNECTED
            )
    
    def _pv_callback(self, pvname: str = None, value=None, timestamp=None, 
                     severity=None, char_value=None, **kwargs):
        """Callback for PV value changes"""
        if pvname in self._values:
            with self._lock:
                self._values[pvname] = PVValue(
                    value=value,
                    timestamp=timestamp,
                    status=PVStatus.CONNECTED,
                    severity=severity,
                    char_value=char_value
                )
            
            # Notify registered callbacks
            if pvname in self._callbacks:
                for callback in self._callbacks[pvname]:
                    try:
                        callback(pvname, value, timestamp, severity)
                    except Exception as e:
                        self.logger.error(f"Callback error for {pvname}: {e}")
    
    def get_value(self, pv_name: str) -> Optional[PVValue]:
        """Get cached PV value"""
        return self._values.get(pv_name)
    
    def get_raw_value(self, pv_name: str) -> Any:
        """Get just the raw value (convenience method)"""
        pv_value = self.get_value(pv_name)
        return pv_value.value if pv_value else None
    
    async def put_value(self, pv_name: str, value: Any, wait: bool = False) -> bool:
        """Set PV value"""
        if self.mock_mode:
            return await self._put_mock_value(pv_name, value)
        else:
            return await self._put_real_value(pv_name, value, wait)
    
    async def _put_real_value(self, pv_name: str, value: Any, wait: bool) -> bool:
        """Set real PV value"""
        if pv_name not in self._pvs:
            self.logger.error(f"PV {pv_name} not initialized")
            return False
        
        pv = self._pvs[pv_name]
        if not pv.connected:
            self.logger.error(f"PV {pv_name} not connected")
            return False
        
        try:
            success = pv.put(value, wait=wait)
            if success:
                self.logger.debug(f"Set {pv_name} = {value}")
            else:
                self.logger.error(f"Failed to set {pv_name} = {value}")
            return success
        except Exception as e:
            self.logger.error(f"Error setting {pv_name}: {e}")
            return False
    
    async def _put_mock_value(self, pv_name: str, value: Any) -> bool:
        """Set mock PV value"""
        if pv_name not in self._mock_values:
            self.logger.error(f"Mock PV {pv_name} not defined")
            return False
        
        self._mock_values[pv_name] = value
        
        # Update cached value and trigger callbacks
        with self._lock:
            self._values[pv_name] = PVValue(
                value=value,
                timestamp=asyncio.get_event_loop().time(),
                status=PVStatus.CONNECTED
            )
        
        # Trigger callbacks
        if pv_name in self._callbacks:
            for callback in self._callbacks[pv_name]:
                try:
                    callback(pv_name, value, asyncio.get_event_loop().time(), "NO_ALARM")
                except Exception as e:
                    self.logger.error(f"Mock callback error for {pv_name}: {e}")
        
        return True
    
    def add_callback(self, pv_name: str, callback: Callable) -> None:
        """Register callback for PV changes"""
        if pv_name not in self._callbacks:
            self._callbacks[pv_name] = []
        self._callbacks[pv_name].append(callback)
    
    def remove_callback(self, pv_name: str, callback: Callable) -> None:
        """Remove callback for PV changes"""
        if pv_name in self._callbacks:
            try:
                self._callbacks[pv_name].remove(callback)
            except ValueError:
                pass
    
    def get_connection_status(self) -> Dict[str, PVStatus]:
        """Get connection status for all PVs"""
        return {name: value.status for name, value in self._values.items()}
    
    def get_alarm_summary(self) -> Dict[str, str]:
        """Get alarm status for all PVs"""
        return {
            name: value.severity 
            for name, value in self._values.items() 
            if value.severity not in ["NO_ALARM", ""]
        }
    
    async def shutdown(self) -> None:
        """Shutdown PV manager"""
        self.logger.info("Shutting down PV Manager")
        
        if not self.mock_mode:
            for pv in self._pvs.values():
                try:
                    pv.disconnect()
                except Exception as e:
                    self.logger.error(f"Error disconnecting PV: {e}")
        
        self._pvs.clear()
        self._values.clear()
        self._callbacks.clear()
```

### 3.2 EPICS Interface

```python
# epics_interface/__init__.py
from .pv_manager import PVManager, PVDefinition, PVValue, PVStatus
from .channel_access import EPICSInterface
from .alarm_handler import AlarmHandler

__all__ = ['EPICSInterface', 'PVManager', 'PVDefinition', 'PVValue', 'PVStatus', 'AlarmHandler']

# epics_interface/channel_access.py
import logging
from typing import Dict, Any, Optional, List
from pathlib import Path
import yaml

from .pv_manager import PVManager, PVDefinition

class EPICSInterface:
    """
    High-level EPICS interface for SPEAR3 LLRF coordinator.
    
    Provides organized access to all subsystem PVs:
    - LLRF9 units (field control and monitoring)
    - HVPS controller
    - MPS system
    - Motor controllers
    - Waveform buffer system
    """
    
    def __init__(self, pv_definitions_file: Path, mock_mode: bool = False):
        self.logger = logging.getLogger(__name__)
        self.mock_mode = mock_mode
        
        # Load PV definitions
        self.pv_definitions = self._load_pv_definitions(pv_definitions_file)
        
        # Initialize PV manager
        self.pv_manager = PVManager(self.pv_definitions, mock_mode)
        
        # Organized PV access
        self.llrf9_field = LLRF9Interface(self.pv_manager, "LLRF1")
        self.llrf9_monitor = LLRF9Interface(self.pv_manager, "LLRF2")
        self.hvps = HVPSInterface(self.pv_manager)
        self.mps = MPSInterface(self.pv_manager)
        self.tuners = TunerInterface(self.pv_manager)
        self.waveform_buffer = WaveformBufferInterface(self.pv_manager)
    
    def _load_pv_definitions(self, definitions_file: Path) -> Dict[str, PVDefinition]:
        """Load PV definitions from YAML file"""
        try:
            with open(definitions_file, 'r') as f:
                data = yaml.safe_load(f)
            
            definitions = {}
            for category, pvs in data.items():
                for pv_name, pv_data in pvs.items():
                    definitions[pv_name] = PVDefinition(
                        name=pv_data['name'],
                        description=pv_data.get('description', ''),
                        data_type=pv_data.get('type', 'float'),
                        units=pv_data.get('units'),
                        precision=pv_data.get('precision'),
                        limits=pv_data.get('limits'),
                        enum_strings=pv_data.get('enum_strings'),
                        timeout=pv_data.get('timeout', 5.0)
                    )
            
            self.logger.info(f"Loaded {len(definitions)} PV definitions")
            return definitions
            
        except Exception as e:
            self.logger.error(f"Failed to load PV definitions: {e}")
            raise
    
    async def initialize(self) -> None:
        """Initialize EPICS interface"""
        await self.pv_manager.initialize()
    
    async def shutdown(self) -> None:
        """Shutdown EPICS interface"""
        await self.pv_manager.shutdown()

class LLRF9Interface:
    """Interface to LLRF9 unit PVs"""
    
    def __init__(self, pv_manager: PVManager, prefix: str):
        self.pv_manager = pv_manager
        self.prefix = prefix
    
    async def get_gap_voltage(self) -> Optional[float]:
        """Get total gap voltage (MV)"""
        return self.pv_manager.get_raw_value(f"{self.prefix}:GAP_VOLTAGE")
    
    async def set_gap_voltage_setpoint(self, voltage_mv: float) -> bool:
        """Set gap voltage setpoint (MV)"""
        return await self.pv_manager.put_value(f"{self.prefix}:GAP_VOLTAGE:SP", voltage_mv)
    
    async def get_drive_power(self) -> Optional[float]:
        """Get drive power (W)"""
        return self.pv_manager.get_raw_value(f"{self.prefix}:DRIVE_POWER")
    
    async def get_cavity_phases(self) -> List[Optional[float]]:
        """Get phase measurements for all 4 cavities (degrees)"""
        phases = []
        for cavity in ['A', 'B', 'C', 'D']:
            phase = self.pv_manager.get_raw_value(f"{self.prefix}:CAV{cavity}:PHASE")
            phases.append(phase)
        return phases
    
    async def get_cavity_amplitudes(self) -> List[Optional[float]]:
        """Get amplitude measurements for all 4 cavities (MV)"""
        amplitudes = []
        for cavity in ['A', 'B', 'C', 'D']:
            amp = self.pv_manager.get_raw_value(f"{self.prefix}:CAV{cavity}:AMPLITUDE")
            amplitudes.append(amp)
        return amplitudes
    
    async def set_cavity_phase_offset(self, cavity: str, offset_deg: float) -> bool:
        """Set phase offset for individual cavity (degrees)"""
        return await self.pv_manager.put_value(f"{self.prefix}:CAV{cavity}:PHASE_OFFSET", offset_deg)
    
    async def get_interlock_status(self) -> Dict[str, Any]:
        """Get interlock status"""
        return {
            'active': self.pv_manager.get_raw_value(f"{self.prefix}:INTERLOCK:ACTIVE"),
            'source': self.pv_manager.get_raw_value(f"{self.prefix}:INTERLOCK:SOURCE"),
            'timestamp': self.pv_manager.get_raw_value(f"{self.prefix}:INTERLOCK:TIMESTAMP")
        }

class HVPSInterface:
    """Interface to HVPS controller PVs"""
    
    def __init__(self, pv_manager: PVManager):
        self.pv_manager = pv_manager
    
    async def get_voltage(self) -> Optional[float]:
        """Get HVPS voltage (kV)"""
        return self.pv_manager.get_raw_value("SRF1:HVPS:VOLTAGE")
    
    async def set_voltage_setpoint(self, voltage_kv: float) -> bool:
        """Set HVPS voltage setpoint (kV)"""
        return await self.pv_manager.put_value("SRF1:HVPS:VOLTAGE:SP", voltage_kv)
    
    async def get_current(self) -> Optional[float]:
        """Get HVPS current (A)"""
        return self.pv_manager.get_raw_value("SRF1:HVPS:CURRENT")
    
    async def get_contactor_status(self) -> Optional[bool]:
        """Get contactor status"""
        return self.pv_manager.get_raw_value("SRF1:HVPS:CONTACTOR:STATUS")
    
    async def set_contactor(self, close: bool) -> bool:
        """Control contactor (True = close, False = open)"""
        return await self.pv_manager.put_value("SRF1:HVPS:CONTACTOR:CMD", 1 if close else 0)

class MPSInterface:
    """Interface to MPS system PVs"""
    
    def __init__(self, pv_manager: PVManager):
        self.pv_manager = pv_manager
    
    async def get_permit_status(self) -> Optional[bool]:
        """Get overall MPS permit status"""
        return self.pv_manager.get_raw_value("SRF1:MPS:PERMIT")
    
    async def get_fault_summary(self) -> Dict[str, Any]:
        """Get fault summary"""
        return {
            'active_faults': self.pv_manager.get_raw_value("SRF1:MPS:FAULTS:ACTIVE"),
            'first_fault': self.pv_manager.get_raw_value("SRF1:MPS:FAULTS:FIRST"),
            'fault_count': self.pv_manager.get_raw_value("SRF1:MPS:FAULTS:COUNT")
        }

class TunerInterface:
    """Interface to tuner motor controller PVs"""
    
    def __init__(self, pv_manager: PVManager):
        self.pv_manager = pv_manager
    
    async def get_positions(self) -> List[Optional[float]]:
        """Get all tuner positions (mm)"""
        positions = []
        for cavity in ['A', 'B', 'C', 'D']:
            pos = self.pv_manager.get_raw_value(f"SRF1:CAV{cavity}TUNR:POSITION")
            positions.append(pos)
        return positions
    
    async def move_tuner(self, cavity: str, position_mm: float) -> bool:
        """Move tuner to absolute position (mm)"""
        return await self.pv_manager.put_value(f"SRF1:CAV{cavity}TUNR:POSITION:SP", position_mm)
    
    async def get_motor_status(self, cavity: str) -> Dict[str, Any]:
        """Get motor status for cavity"""
        return {
            'moving': self.pv_manager.get_raw_value(f"SRF1:CAV{cavity}TUNR:MOVING"),
            'done': self.pv_manager.get_raw_value(f"SRF1:CAV{cavity}TUNR:DONE"),
            'limit_high': self.pv_manager.get_raw_value(f"SRF1:CAV{cavity}TUNR:LIMIT_HIGH"),
            'limit_low': self.pv_manager.get_raw_value(f"SRF1:CAV{cavity}TUNR:LIMIT_LOW")
        }

class WaveformBufferInterface:
    """Interface to waveform buffer system PVs"""
    
    def __init__(self, pv_manager: PVManager):
        self.pv_manager = pv_manager
    
    async def get_rf_powers(self) -> Dict[str, Optional[float]]:
        """Get RF power measurements (W)"""
        return {
            'wg_load1_fwd': self.pv_manager.get_raw_value("SRF1:WGLOAD1:FWD_POWER"),
            'wg_load1_refl': self.pv_manager.get_raw_value("SRF1:WGLOAD1:REFL_POWER"),
            'wg_load2_fwd': self.pv_manager.get_raw_value("SRF1:WGLOAD2:FWD_POWER"),
            'wg_load2_refl': self.pv_manager.get_raw_value("SRF1:WGLOAD2:REFL_POWER"),
            'wg_load3_fwd': self.pv_manager.get_raw_value("SRF1:WGLOAD3:FWD_POWER"),
            'wg_load3_refl': self.pv_manager.get_raw_value("SRF1:WGLOAD3:REFL_POWER"),
            'klys_drive': self.pv_manager.get_raw_value("SRF1:KLYS:DRIVE_POWER"),
            'klys_fwd': self.pv_manager.get_raw_value("SRF1:KLYS:FWD_POWER")
        }
    
    async def get_hvps_signals(self) -> Dict[str, Optional[float]]:
        """Get HVPS monitoring signals"""
        return {
            'voltage': self.pv_manager.get_raw_value("SRF1:HVPS:VOLTAGE_MON"),
            'current': self.pv_manager.get_raw_value("SRF1:HVPS:CURRENT_MON"),
            'transformer1': self.pv_manager.get_raw_value("SRF1:HVPS:XFMR1_VOLTAGE"),
            'transformer2': self.pv_manager.get_raw_value("SRF1:HVPS:XFMR2_VOLTAGE")
        }
```


---

## 4. Station State Machine

The station state machine coordinates all subsystem states and manages the complex turn-on/turn-off sequences.

```python
# coordinator/state_machine.py
import logging
import asyncio
from typing import Dict, Optional, List, Callable
from enum import Enum
from dataclasses import dataclass
import time

from ..epics_interface import EPICSInterface

class StationState(Enum):
    """Station operating states"""
    OFF = "OFF"
    PARK = "PARK"  
    TUNE = "TUNE"
    ON_CW = "ON_CW"

class StateTransition(Enum):
    """Valid state transitions"""
    OFF_TO_PARK = "OFF_TO_PARK"
    OFF_TO_TUNE = "OFF_TO_TUNE"
    OFF_TO_ON_CW = "OFF_TO_ON_CW"
    PARK_TO_OFF = "PARK_TO_OFF"
    TUNE_TO_OFF = "TUNE_TO_OFF"
    TUNE_TO_ON_CW = "TUNE_TO_ON_CW"
    ON_CW_TO_OFF = "ON_CW_TO_OFF"
    ON_CW_TO_TUNE = "ON_CW_TO_TUNE"

@dataclass
class TransitionStep:
    """Individual step in state transition sequence"""
    name: str
    description: str
    timeout_seconds: float
    execute_func: Callable
    verify_func: Optional[Callable] = None

class StationStateMachine:
    """
    SPEAR3 LLRF Station State Machine
    
    Manages station states and coordinates complex turn-on/turn-off sequences:
    - OFF: Station completely off, tuners at park position
    - PARK: HVPS off, tuners at park position (legacy compatibility)
    - TUNE: Low-power testing mode with tuner feedback
    - ON_CW: Full-power operation with all loops active
    """
    
    def __init__(self, epics: EPICSInterface, config: Dict):
        self.epics = epics
        self.config = config
        self.logger = logging.getLogger(__name__)
        
        # Current state
        self.current_state = StationState.OFF
        self.target_state = StationState.OFF
        self.transition_in_progress = False
        self.transition_start_time = 0.0
        
        # Transition sequences
        self.transition_sequences = self._build_transition_sequences()
        
        # Auto-restart parameters
        self.auto_restart_enabled = config.get('auto_restart_enabled', True)
        self.auto_restart_retries = config.get('auto_restart_retries', 3)
        self.auto_restart_delay = config.get('auto_restart_delay', 30.0)
        self.restart_counter = 0
        
        # Callbacks for state changes
        self.state_change_callbacks: List[Callable] = []
    
    async def start(self) -> None:
        """Initialize state machine"""
        self.logger.info("Starting Station State Machine")
        
        # Read current state from hardware if possible
        await self._determine_initial_state()
        
        self.logger.info(f"Initial station state: {self.current_state.value}")
    
    async def shutdown(self) -> None:
        """Shutdown state machine"""
        self.logger.info("Shutting down Station State Machine")
        
        # If not already OFF, transition to OFF
        if self.current_state != StationState.OFF:
            await self.request_state_change(StationState.OFF)
    
    async def update(self) -> None:
        """Main state machine update loop (~1 Hz)"""
        # Check for fault conditions that require immediate shutdown
        await self._check_fault_conditions()
        
        # Process any pending state transitions
        if self.transition_in_progress:
            await self._process_transition()
        
        # Update state-dependent monitoring
        await self._update_state_monitoring()
    
    async def request_state_change(self, target_state: StationState) -> bool:
        """Request state change"""
        if self.transition_in_progress:
            self.logger.warning(f"Transition already in progress, ignoring request for {target_state.value}")
            return False
        
        if target_state == self.current_state:
            self.logger.debug(f"Already in state {target_state.value}")
            return True
        
        # Validate transition
        if not self._is_valid_transition(self.current_state, target_state):
            self.logger.error(f"Invalid transition: {self.current_state.value} -> {target_state.value}")
            return False
        
        self.logger.info(f"Requesting state change: {self.current_state.value} -> {target_state.value}")
        self.target_state = target_state
        self.transition_in_progress = True
        self.transition_start_time = time.time()
        
        return True
    
    def _is_valid_transition(self, from_state: StationState, to_state: StationState) -> bool:
        """Check if state transition is valid"""
        valid_transitions = {
            StationState.OFF: [StationState.PARK, StationState.TUNE, StationState.ON_CW],
            StationState.PARK: [StationState.OFF],
            StationState.TUNE: [StationState.OFF, StationState.ON_CW],
            StationState.ON_CW: [StationState.OFF, StationState.TUNE]
        }
        
        return to_state in valid_transitions.get(from_state, [])
    
    async def _determine_initial_state(self) -> None:
        """Determine initial state from hardware status"""
        try:
            # Check HVPS status
            hvps_voltage = await self.epics.hvps.get_voltage()
            hvps_contactor = await self.epics.hvps.get_contactor_status()
            
            # Check LLRF9 status
            gap_voltage = await self.epics.llrf9_field.get_gap_voltage()
            
            # Check MPS permit
            mps_permit = await self.epics.mps.get_permit_status()
            
            # Determine state based on hardware status
            if not mps_permit or not hvps_contactor:
                self.current_state = StationState.OFF
            elif hvps_voltage and hvps_voltage > 10.0 and gap_voltage and gap_voltage > 1.0:
                self.current_state = StationState.ON_CW
            elif hvps_voltage and hvps_voltage > 10.0:
                self.current_state = StationState.TUNE
            else:
                self.current_state = StationState.OFF
                
        except Exception as e:
            self.logger.error(f"Failed to determine initial state: {e}")
            self.current_state = StationState.OFF
    
    async def _check_fault_conditions(self) -> None:
        """Check for fault conditions requiring immediate shutdown"""
        try:
            # Check MPS permit
            mps_permit = await self.epics.mps.get_permit_status()
            if not mps_permit and self.current_state != StationState.OFF:
                self.logger.warning("MPS permit lost, forcing OFF state")
                await self.request_state_change(StationState.OFF)
                return
            
            # Check LLRF9 interlock status
            llrf9_status = await self.epics.llrf9_field.get_interlock_status()
            if llrf9_status.get('active') and self.current_state in [StationState.TUNE, StationState.ON_CW]:
                self.logger.warning("LLRF9 interlock active, forcing OFF state")
                await self.request_state_change(StationState.OFF)
                return
                
        except Exception as e:
            self.logger.error(f"Error checking fault conditions: {e}")
    
    async def _process_transition(self) -> None:
        """Process current state transition"""
        transition_key = f"{self.current_state.value}_TO_{self.target_state.value}"
        
        if transition_key not in self.transition_sequences:
            self.logger.error(f"No transition sequence defined for {transition_key}")
            self.transition_in_progress = False
            return
        
        sequence = self.transition_sequences[transition_key]
        
        try:
            # Execute transition sequence
            for step in sequence:
                self.logger.info(f"Executing transition step: {step.name}")
                
                # Execute step
                success = await step.execute_func()
                if not success:
                    self.logger.error(f"Transition step failed: {step.name}")
                    await self._handle_transition_failure()
                    return
                
                # Verify step if verification function provided
                if step.verify_func:
                    verified = await step.verify_func()
                    if not verified:
                        self.logger.error(f"Transition step verification failed: {step.name}")
                        await self._handle_transition_failure()
                        return
                
                self.logger.debug(f"Transition step completed: {step.name}")
            
            # Transition completed successfully
            self.logger.info(f"State transition completed: {self.current_state.value} -> {self.target_state.value}")
            self.current_state = self.target_state
            self.transition_in_progress = False
            self.restart_counter = 0  # Reset restart counter on successful transition
            
            # Notify callbacks
            for callback in self.state_change_callbacks:
                try:
                    await callback(self.current_state)
                except Exception as e:
                    self.logger.error(f"State change callback error: {e}")
                    
        except Exception as e:
            self.logger.error(f"Transition execution error: {e}")
            await self._handle_transition_failure()
    
    async def _handle_transition_failure(self) -> None:
        """Handle transition failure"""
        self.logger.error("Transition failed, forcing OFF state")
        
        # Force to OFF state
        self.current_state = StationState.OFF
        self.target_state = StationState.OFF
        self.transition_in_progress = False
        
        # Emergency shutdown sequence
        await self._emergency_shutdown()
        
        # Consider auto-restart if enabled
        if self.auto_restart_enabled and self.restart_counter < self.auto_restart_retries:
            self.restart_counter += 1
            self.logger.info(f"Scheduling auto-restart attempt {self.restart_counter}/{self.auto_restart_retries}")
            # Schedule restart after delay (implementation depends on requirements)
    
    async def _emergency_shutdown(self) -> None:
        """Emergency shutdown sequence"""
        try:
            # Disable LLRF9 output
            await self.epics.llrf9_field.set_gap_voltage_setpoint(0.0)
            
            # Open HVPS contactor
            await self.epics.hvps.set_contactor(False)
            
            # Set HVPS voltage to zero
            await self.epics.hvps.set_voltage_setpoint(0.0)
            
            self.logger.info("Emergency shutdown completed")
            
        except Exception as e:
            self.logger.error(f"Emergency shutdown error: {e}")
    
    def _build_transition_sequences(self) -> Dict[str, List[TransitionStep]]:
        """Build all state transition sequences"""
        sequences = {}
        
        # OFF -> ON_CW (most complex transition)
        sequences["OFF_TO_ON_CW"] = [
            TransitionStep(
                name="verify_preconditions",
                description="Verify all preconditions for turn-on",
                timeout_seconds=10.0,
                execute_func=self._verify_turn_on_preconditions
            ),
            TransitionStep(
                name="move_tuners_to_on_home",
                description="Move all tuners to ON home positions",
                timeout_seconds=60.0,
                execute_func=self._move_tuners_to_on_home,
                verify_func=self._verify_tuners_at_on_home
            ),
            TransitionStep(
                name="initialize_hvps",
                description="Set HVPS to turn-on voltage and enable",
                timeout_seconds=30.0,
                execute_func=self._initialize_hvps,
                verify_func=self._verify_hvps_ready
            ),
            TransitionStep(
                name="initialize_llrf9_drive",
                description="Set initial gap voltage and enable LLRF9 output",
                timeout_seconds=10.0,
                execute_func=self._initialize_llrf9_drive,
                verify_func=self._verify_rf_power_present
            ),
            TransitionStep(
                name="engage_direct_loop",
                description="Close direct loop feedback",
                timeout_seconds=10.0,
                execute_func=self._engage_direct_loop,
                verify_func=self._verify_direct_loop_stable
            ),
            TransitionStep(
                name="ramp_to_operational_power",
                description="Ramp gap voltage and HVPS to operational levels",
                timeout_seconds=60.0,
                execute_func=self._ramp_to_operational_power,
                verify_func=self._verify_operational_power
            ),
            TransitionStep(
                name="enable_remaining_loops",
                description="Enable tuner feedback and load angle loops",
                timeout_seconds=10.0,
                execute_func=self._enable_remaining_loops
            ),
            TransitionStep(
                name="finalize_turn_on",
                description="Final checks and logging",
                timeout_seconds=5.0,
                execute_func=self._finalize_turn_on
            )
        ]
        
        # ON_CW -> OFF
        sequences["ON_CW_TO_OFF"] = [
            TransitionStep(
                name="disable_feedback_loops",
                description="Disable all feedback loops",
                timeout_seconds=5.0,
                execute_func=self._disable_feedback_loops
            ),
            TransitionStep(
                name="ramp_down_power",
                description="Ramp down gap voltage and HVPS",
                timeout_seconds=30.0,
                execute_func=self._ramp_down_power
            ),
            TransitionStep(
                name="disable_llrf9_output",
                description="Disable LLRF9 drive output",
                timeout_seconds=5.0,
                execute_func=self._disable_llrf9_output
            ),
            TransitionStep(
                name="shutdown_hvps",
                description="Set HVPS to zero and open contactor",
                timeout_seconds=10.0,
                execute_func=self._shutdown_hvps
            ),
            TransitionStep(
                name="move_tuners_to_park",
                description="Move tuners to park positions",
                timeout_seconds=60.0,
                execute_func=self._move_tuners_to_park
            )
        ]
        
        # Add other transition sequences (TUNE, PARK, etc.)
        sequences.update(self._build_simple_transitions())
        
        return sequences
    
    def _build_simple_transitions(self) -> Dict[str, List[TransitionStep]]:
        """Build simpler transition sequences"""
        sequences = {}
        
        # OFF -> TUNE
        sequences["OFF_TO_TUNE"] = [
            TransitionStep(
                name="verify_preconditions",
                description="Verify preconditions for TUNE mode",
                timeout_seconds=10.0,
                execute_func=self._verify_tune_preconditions
            ),
            TransitionStep(
                name="initialize_hvps_low_power",
                description="Initialize HVPS for low power operation",
                timeout_seconds=30.0,
                execute_func=self._initialize_hvps_low_power
            ),
            TransitionStep(
                name="enable_tune_mode",
                description="Enable TUNE mode with limited power",
                timeout_seconds=10.0,
                execute_func=self._enable_tune_mode
            )
        ]
        
        # TUNE -> ON_CW
        sequences["TUNE_TO_ON_CW"] = [
            TransitionStep(
                name="ramp_to_full_power",
                description="Ramp from TUNE to full power",
                timeout_seconds=60.0,
                execute_func=self._ramp_tune_to_full_power
            ),
            TransitionStep(
                name="enable_all_loops",
                description="Enable all feedback loops",
                timeout_seconds=10.0,
                execute_func=self._enable_remaining_loops
            )
        ]
        
        # Add other simple transitions...
        
        return sequences
    
    # Transition step implementation methods
    async def _verify_turn_on_preconditions(self) -> bool:
        """Verify all preconditions for turn-on"""
        try:
            # Check MPS permit
            mps_permit = await self.epics.mps.get_permit_status()
            if not mps_permit:
                self.logger.error("MPS permit not active")
                return False
            
            # Check HVPS contactor status
            contactor_status = await self.epics.hvps.get_contactor_status()
            if contactor_status is None:
                self.logger.error("Cannot read HVPS contactor status")
                return False
            
            # Check for active faults
            fault_summary = await self.epics.mps.get_fault_summary()
            if fault_summary.get('active_faults', 0) > 0:
                self.logger.error("Active faults present")
                return False
            
            self.logger.info("Turn-on preconditions verified")
            return True
            
        except Exception as e:
            self.logger.error(f"Error verifying preconditions: {e}")
            return False
    
    async def _move_tuners_to_on_home(self) -> bool:
        """Move all tuners to ON home positions"""
        try:
            # Get ON home positions from config
            on_home_positions = {
                'A': self.config.get('tuner_on_home_a', 10.5),
                'B': self.config.get('tuner_on_home_b', 10.3),
                'C': self.config.get('tuner_on_home_c', 10.7),
                'D': self.config.get('tuner_on_home_d', 10.1)
            }
            
            # Command all tuners to move
            for cavity, position in on_home_positions.items():
                success = await self.epics.tuners.move_tuner(cavity, position)
                if not success:
                    self.logger.error(f"Failed to command tuner {cavity} to ON home")
                    return False
            
            return True
            
        except Exception as e:
            self.logger.error(f"Error moving tuners to ON home: {e}")
            return False
    
    async def _verify_tuners_at_on_home(self) -> bool:
        """Verify all tuners reached ON home positions"""
        try:
            timeout = 60.0  # 60 second timeout
            start_time = time.time()
            
            while time.time() - start_time < timeout:
                all_done = True
                
                for cavity in ['A', 'B', 'C', 'D']:
                    status = await self.epics.tuners.get_motor_status(cavity)
                    if status.get('moving', True):  # Default to True if unknown
                        all_done = False
                        break
                
                if all_done:
                    self.logger.info("All tuners reached ON home positions")
                    return True
                
                await asyncio.sleep(1.0)  # Check every second
            
            self.logger.error("Timeout waiting for tuners to reach ON home")
            return False
            
        except Exception as e:
            self.logger.error(f"Error verifying tuners at ON home: {e}")
            return False
    
    # Additional transition step methods would be implemented here...
    # (initialize_hvps, initialize_llrf9_drive, engage_direct_loop, etc.)
    
    async def _update_state_monitoring(self) -> None:
        """Update state-dependent monitoring"""
        # Implementation depends on specific monitoring requirements
        pass
    
    def add_state_change_callback(self, callback: Callable) -> None:
        """Add callback for state changes"""
        self.state_change_callbacks.append(callback)
    
    def remove_state_change_callback(self, callback: Callable) -> None:
        """Remove state change callback"""
        try:
            self.state_change_callbacks.remove(callback)
        except ValueError:
            pass
```

