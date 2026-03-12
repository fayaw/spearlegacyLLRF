# SPEAR3 LLRF Upgrade - Complete System Architecture Analysis

**Document ID**: SPEAR3-LLRF-ARCH-001  
**Date**: March 12, 2026  
**Author**: LLRF Upgrade Software Team  
**Status**: Comprehensive Architecture Review  

---

## Executive Summary

This document provides a complete system architecture analysis for the SPEAR3 LLRF Upgrade, with particular focus on the **Interface Chassis software integration requirements** that were initially overlooked. The Interface Chassis is a critical new hardware subsystem that fundamentally changes the system architecture from a 3-layer to a **4-layer protection hierarchy**.

---

## 1. Complete System Architecture

### 1.1 Corrected 4-Layer Protection Hierarchy

| Layer | Subsystem | Response Time | Function | Software Interface |
|-------|-----------|---------------|----------|-------------------|
| **Layer 1** | LLRF9 FPGA Interlocks | <1 μs | RF-specific protection | Monitor via EPICS PVs |
| **Layer 2** | **Interface Chassis** | <1 μs | **Central interlock coordination** | **Monitor via MPS PLC** |
| **Layer 3** | MPS PLC | ~ms | System-level fault aggregation | Direct EPICS interface |
| **Layer 4** | Python Coordinator | ~1 Hz | Supervisory control | All subsystem coordination |

### 1.2 Interface Chassis - The Missing Critical Component

The **Interface Chassis** is a completely new hardware subsystem that serves as the **central interlock coordination hub**:

**Key Functions:**
- **Hardware AND-logic** of all permit signals (<1 μs response)
- **First-fault detection** and latching
- **Electrical isolation** via optocouplers and fiber-optics
- **Centralized reset control** from MPS PLC
- **Status reporting** to MPS PLC for software monitoring

**Critical Insight:** The Interface Chassis operates in **pure hardware** for fast response, but requires **comprehensive software interface** for monitoring, diagnostics, and control.

---

## 2. Interface Chassis Software Integration Requirements

### 2.1 Interface Chassis ↔ MPS PLC Communication

The Interface Chassis communicates with the MPS PLC via **multi-conductor digital cables**:

**MPS → Interface Chassis (Control Signals):**
- `Kly MPS Summary Permit` - Global RF permit
- `Kly MPS Heartbeat` - Watchdog signal  
- `Kly MPS Reset` - Clears all latched faults

**Interface Chassis → MPS (Status Signals):**
- `All input permit states` - Status of every IC input
- `All output permit states` - Status of every IC output  
- `First-fault register` - Identifies initiating fault source

### 2.2 Required Software Modules for Interface Chassis

**New Module Required:**
```python
# software_architecture/interface_chassis_monitor.py
class InterfaceChassisMonitor:
    """Monitor Interface Chassis status via MPS PLC interface."""
    
    def __init__(self, mps_interface):
        self.mps = mps_interface
        
    def get_input_states(self):
        """Read all Interface Chassis input permit states."""
        return {
            'llrf9_status': self.mps.get('SRF1:MPS:IC:LLRF9_STATUS'),
            'hvps_status': self.mps.get('SRF1:MPS:IC:HVPS_STATUS'),
            'spear_mps_permit': self.mps.get('SRF1:MPS:IC:SPEAR_MPS'),
            'orbit_interlock': self.mps.get('SRF1:MPS:IC:ORBIT_PERMIT'),
            'arc_detection': self.mps.get('SRF1:MPS:IC:ARC_PERMIT'),
            'waveform_buffer': self.mps.get('SRF1:MPS:IC:WFBUF_PERMIT'),
            'expansion_ports': self.mps.get('SRF1:MPS:IC:EXPANSION')
        }
        
    def get_output_states(self):
        """Read all Interface Chassis output permit states."""
        return {
            'llrf9_enable': self.mps.get('SRF1:MPS:IC:LLRF9_ENABLE'),
            'hvps_scr_enable': self.mps.get('SRF1:MPS:IC:HVPS_SCR_EN'),
            'hvps_crowbar': self.mps.get('SRF1:MPS:IC:HVPS_CROWBAR')
        }
        
    def get_first_fault(self):
        """Read first-fault register from Interface Chassis."""
        return self.mps.get('SRF1:MPS:FAULTS:FIRST')
        
    def request_reset(self):
        """Request MPS to send reset signal to Interface Chassis."""
        self.mps.put('SRF1:MPS:RESET:CMD', 1)
```

### 2.3 Required EPICS PVs for Interface Chassis

**MPS PLC PVs (SRF1:MPS: namespace):**

**Interface Chassis Input Status:**
```
SRF1:MPS:IC:LLRF9_STATUS      # LLRF9 status input state
SRF1:MPS:IC:HVPS_STATUS       # HVPS STATUS fiber state  
SRF1:MPS:IC:SPEAR_MPS         # SPEAR MPS permit state
SRF1:MPS:IC:ORBIT_PERMIT      # Orbit interlock permit state
SRF1:MPS:IC:ARC_PERMIT        # Arc detection permit state
SRF1:MPS:IC:WFBUF_PERMIT      # Waveform Buffer permit state
SRF1:MPS:IC:EXPANSION         # Expansion port states (array)
```

**Interface Chassis Output Status:**
```
SRF1:MPS:IC:LLRF9_ENABLE      # LLRF9 Enable output state
SRF1:MPS:IC:HVPS_SCR_EN       # HVPS SCR ENABLE fiber state
SRF1:MPS:IC:HVPS_CROWBAR      # HVPS CROWBAR fiber state
```

**Interface Chassis Control & Diagnostics:**
```
SRF1:MPS:FAULTS:FIRST         # First-fault register (ENUM)
SRF1:MPS:RESET:CMD            # Reset command to Interface Chassis
SRF1:MPS:IC:HEARTBEAT         # MPS heartbeat to Interface Chassis
SRF1:MPS:IC:SUMMARY_PERMIT    # MPS summary permit to Interface Chassis
```

---

## 3. Updated Software Module Requirements

### 3.1 Modified Existing Modules

**State Machine Module (state_machine.py):**
- Add Interface Chassis status monitoring
- Include IC fault conditions in state transitions
- Coordinate IC reset during fault recovery

**Fault Manager Module (fault_manager.py):**
- Monitor all Interface Chassis input/output states
- Process first-fault register for root-cause analysis
- Log Interface Chassis fault events with timestamps

**HVPS Controller Module (hvps_controller.py):**
- Monitor HVPS STATUS fiber via Interface Chassis
- Coordinate HVPS recovery with Interface Chassis reset
- Verify Interface Chassis permits before HVPS enable

### 3.2 New Required Modules

**Interface Chassis Monitor (interface_chassis_monitor.py):**
- Monitor all Interface Chassis inputs and outputs
- Provide first-fault analysis capabilities
- Handle Interface Chassis reset coordination

**Interlock Coordinator (interlock_coordinator.py):**
- Coordinate between all protection layers
- Manage fault recovery sequences involving Interface Chassis
- Provide comprehensive interlock status to operators

---

## 4. Interface Chassis Integration Points

### 4.1 System Startup Sequence

```python
def startup_sequence(self):
    """Complete system startup including Interface Chassis verification."""
    
    # 1. Verify Interface Chassis is operational
    ic_status = self.interface_chassis.get_input_states()
    if not all(ic_status.values()):
        raise StartupError("Interface Chassis inputs not ready")
    
    # 2. Verify MPS permits are active
    if not self.mps.get('SRF1:MPS:PERMIT'):
        raise StartupError("MPS permit not active")
    
    # 3. Proceed with subsystem startup
    self.llrf9.initialize()
    self.hvps.initialize()
    # ... etc
```

### 4.2 Fault Recovery Sequence

```python
def fault_recovery(self):
    """Fault recovery including Interface Chassis reset."""
    
    # 1. Analyze first-fault register
    first_fault = self.interface_chassis.get_first_fault()
    self.logger.info(f"First fault source: {first_fault}")
    
    # 2. Clear subsystem faults
    self.clear_subsystem_faults()
    
    # 3. Request Interface Chassis reset
    self.interface_chassis.request_reset()
    
    # 4. Verify Interface Chassis permits restored
    ic_outputs = self.interface_chassis.get_output_states()
    if not all(ic_outputs.values()):
        raise RecoveryError("Interface Chassis permits not restored")
    
    # 5. Resume normal operation
    self.state_machine.transition_to('STANDBY')
```

---

## 5. Critical Software Design Implications

### 5.1 Interface Chassis is Hardware-Only for Fast Response

**Key Principle:** The Interface Chassis operates in **pure hardware** (<1 μs) for safety-critical functions. Software interaction is **supervisory only**:

- ✅ **Monitor** Interface Chassis status via MPS PLC
- ✅ **Request** Interface Chassis reset via MPS PLC  
- ✅ **Analyze** first-fault register for diagnostics
- ❌ **Never** in the fast interlock path
- ❌ **Never** direct control of Interface Chassis logic

### 5.2 MPS PLC as Interface Chassis Gateway

The **MPS PLC serves as the gateway** between software and Interface Chassis:
- All Interface Chassis status is read via MPS PLC PVs
- All Interface Chassis control is via MPS PLC commands
- No direct software-to-Interface Chassis communication

### 5.3 First-Fault Analysis Capability

The Interface Chassis provides **hardware first-fault detection** that enables sophisticated software diagnostics:
- Identify root cause in cascading fault scenarios
- Provide operators with precise fault analysis
- Enable automated fault recovery procedures

---

## 6. Implementation Priority

### 6.1 Critical Path Items

1. **Interface Chassis Design/Fabrication** - Hardware prerequisite
2. **MPS PLC Integration** - Define Interface Chassis status PVs
3. **Interface Chassis Monitor Module** - Software interface
4. **Updated Fault Manager** - First-fault analysis integration
5. **Modified State Machine** - Interface Chassis status integration

### 6.2 Development Approach

**Phase 1:** Develop Interface Chassis Monitor with **simulated** Interface Chassis I/O
**Phase 2:** Integrate with actual MPS PLC when Interface Chassis is available
**Phase 3:** Full system integration testing with Interface Chassis hardware

---

## 7. Conclusion

The **Interface Chassis represents a fundamental architectural component** that was missing from the initial software design analysis. It serves as the **central nervous system** for all hardware interlocks and requires comprehensive software integration for:

- **Monitoring** all interlock states
- **Diagnostics** via first-fault analysis  
- **Control** via reset coordination
- **Fault recovery** procedures

**The software design must be updated to include proper Interface Chassis integration as a core requirement, not an afterthought.**

---

**Next Steps:**
1. Update Software Design Document to include Interface Chassis integration
2. Define complete MPS PLC PV namespace for Interface Chassis
3. Develop Interface Chassis Monitor module
4. Integrate Interface Chassis status into all relevant software modules
5. Create comprehensive testing plan for Interface Chassis software integration
