# SPEAR3 LLRF Upgrade - Interface Chassis Software Integration

This directory contains the software architecture design for Interface Chassis integration in the SPEAR3 LLRF Upgrade project.

## Critical Discovery

The Interface Chassis is a **completely new hardware subsystem** that serves as the central interlock coordination hub. It was initially missing from the software design analysis but is absolutely critical for proper system operation.

## Key Components

### 1. Complete System Architecture Analysis
- **File**: `COMPLETE_SYSTEM_ARCHITECTURE.md`
- **Purpose**: Documents the corrected 4-layer protection hierarchy including Interface Chassis
- **Key Insight**: Interface Chassis operates in pure hardware (<1 μs) but requires comprehensive software interface

### 2. Interface Chassis Monitor Module
- **File**: `interface_chassis_monitor.py` (to be created)
- **Purpose**: Software interface to Interface Chassis via MPS PLC gateway
- **Functions**: Monitor IC status, process first-fault register, coordinate reset

### 3. Enhanced Fault Manager
- **File**: `enhanced_fault_manager.py` (to be created)  
- **Purpose**: Fault management with Interface Chassis first-fault analysis
- **Features**: Root-cause analysis, cascading fault detection, recovery coordination

### 4. Interlock Coordinator
- **File**: `interlock_coordinator.py` (to be created)
- **Purpose**: Coordinate between all 4 protection layers
- **Functions**: Multi-layer fault recovery, comprehensive status monitoring

### 5. EPICS PV Namespace Design
- **File**: `mps_interface_chassis_pvs.yaml` (to be created)
- **Purpose**: Complete PV namespace for Interface Chassis integration
- **Scope**: All IC inputs, outputs, control, and diagnostic PVs

## 4-Layer Protection Hierarchy

| Layer | Subsystem | Response Time | Software Interface |
|-------|-----------|---------------|-------------------|
| **Layer 1** | LLRF9 FPGA Interlocks | <1 μs | Monitor via EPICS PVs |
| **Layer 2** | **Interface Chassis** | <1 μs | **Monitor via MPS PLC** |
| **Layer 3** | MPS PLC | ~ms | Direct EPICS interface |
| **Layer 4** | Python Coordinator | ~1 Hz | All subsystem coordination |

## Critical Software Requirements

### Interface Chassis ↔ Software Communication
- **Hardware-only fast path** (<1 μs) - no software in safety loop
- **Software monitoring** via MPS PLC gateway  
- **Status monitoring** of all IC inputs/outputs
- **First-fault analysis** for root-cause diagnostics
- **Reset coordination** via MPS PLC commands

### Required EPICS PVs
```
SRF1:MPS:IC:LLRF9_STATUS      # LLRF9 status input
SRF1:MPS:IC:HVPS_STATUS       # HVPS STATUS fiber
SRF1:MPS:IC:ARC_PERMIT        # Arc detection permit
SRF1:MPS:FAULTS:FIRST         # First-fault register
SRF1:MPS:RESET:CMD            # IC reset command
```

## Implementation Status

- ✅ **System Architecture Analysis** - Complete
- 🔄 **Interface Chassis Monitor** - Design complete, implementation needed
- 🔄 **Enhanced Fault Manager** - Design complete, implementation needed  
- 🔄 **Interlock Coordinator** - Design complete, implementation needed
- 🔄 **PV Namespace Design** - Design complete, implementation needed
- ❌ **Hardware Integration** - Waiting for Interface Chassis fabrication

## Next Steps

1. **Complete software module implementation**
2. **Integrate with MPS PLC when Interface Chassis available**
3. **Update Software Design Document with IC requirements**
4. **Create comprehensive testing plan**
5. **Develop IC simulation for software development**

---

**This Interface Chassis integration is CRITICAL for the SPEAR3 LLRF Upgrade and represents a fundamental architectural component that was initially overlooked.**
