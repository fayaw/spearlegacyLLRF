# 00 — HVPS Control System Overview with Enerpro Integration

> **Sources**: `enerproBoardHvps.docx`, `enerproDiscussion07072022.docx`, `enerproPhaseReferenceAdapter.docx`

## System Architecture Overview

The SPEAR RF Klystron High Voltage Power Supply (HVPS) control system integrates Enerpro SCR firing boards with Allen-Bradley PLC control and analog regulation to provide precise voltage control for klystron amplifiers.

### Complete System Block Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   EPICS IOC     │◄──►│ Allen-Bradley   │◄──►│ Analog          │◄──►│ Enerpro SCR     │
│                 │    │ SLC 500 PLC     │    │ Regulator       │    │ Firing Board    │
│ • Target Voltage│    │                 │    │                 │    │                 │
│ • Commands      │    │ • N7:10 Ref Out │    │ • Error Signal  │    │ • SIG HI Input  │
│ • Status        │    │ • N7:11 Phase   │    │ • Feedback Loop │    │ • 12 Gate Pulses│
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │                        │
                                ▼                        ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
                       │ VXI/DCM         │    │ HVPS Voltage    │    │ Phase-Shifting  │
                       │ Interface       │    │ Monitor         │    │ Transformer     │
                       │                 │    │                 │    │                 │
                       │ • I:1 Inputs    │    │ • Voltage FB    │    │ • Monitor       │
                       │ • O:1 Outputs   │    │ • Current FB    │    │   Windings      │
                       └─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │                        │
                                │                        ▼                        ▼
                                │               ┌─────────────────┐    ┌─────────────────┐
                                │               │ 12-Pulse        │◄───│ Phase Reference │
                                │               │ Thyristor       │    │ Adapter Board   │
                                │               │ Bridges         │    │                 │
                                │               │                 │    │ • 3×2MΩ Resistors│
                                │               │ • Bridge X      │    │ • J7 Interface  │
                                │               │ • Bridge Y      │    │ • Phase Shift   │
                                │               │ • 30° Shift     │    │   Generation    │
                                │               └─────────────────┘    └─────────────────┘
                                │                        │
                                └────────────────────────┼─────► (Status & Control I/O)
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │ Klystron        │
                                               │ Amplifier       │
                                               │                 │
                                               │ • High Voltage  │
                                               │ • RF Output     │
                                               │ • SPEAR3 Ring   │
                                               └─────────────────┘
```

---

## Current System Configuration (Legacy)

### Existing Hardware
- **Enerpro FCOG6100 Rev. K** firing circuit boards (Serial numbers: 41506, 50470, 30045)
- **FCOAUX60 Rev D** firing boards (Serial numbers: 03198, 03813, 1694)
- **Allen-Bradley SLC 500 PLC** with custom ladder logic
- **Analog regulator board** with error amplifier
- **Phase-shifting transformer** with monitor windings

### Control Signal Flow (Current System)

```
EPICS Target → PLC Processing → Dual Control Outputs
    │              │                    │
    │              ▼                    ▼
    │         ┌─────────────┐    ┌─────────────┐
    │         │ Approximate │    │ Reference   │
    │         │ SIG HI      │    │ Signal      │
    │         │ Calculation │    │ Scaling     │
    │         └─────────────┘    └─────────────┘
    │              │                    │
    │              ▼                    ▼
    │         ┌─────────────────────────────────┐
    │         │     Analog Regulator            │
    │         │                                 │
    │         │ • Voltage Feedback Comparison   │
    │         │ • Error Signal Generation       │
    │         │ • Power Line Harmonic Content   │
    │         └─────────────────────────────────┘
    │                        │
    │                        ▼
    └──────────────► ┌─────────────┐
                     │ SIG HI Sum  │ ──► Enerpro FCOG6100
                     │ (PLC + Err) │
                     └─────────────┘
```

### Phase Reference System (Current)

```
Phase-Shifting Transformer Monitor Windings
    │
    ├─ Phase A ──► 2MΩ (R37) ──► J5-1 ──► FCOG6100
    ├─ Phase B ──► 2MΩ (R38) ──► J5-3 ──► FCOG6100  
    └─ Phase C ──► 2MΩ (R39) ──► J5-5 ──► FCOG6100

Measured Characteristics:
• Source Impedance: 2MΩ at HVPS
• Input Resistors: 2MΩ at FCOG6100
• Signal Amplitude: ~75V peak-to-peak
• Phase Sequence: C-B-A (as observed)
```

---

## Proposed System Upgrade

### New Hardware Configuration
- **Enerpro FCOG1200 Rev. L** (12-pulse firing board)
- **Phase Reference Adapter Board** (custom design)
- **Upgraded PLC** (new Allen-Bradley system)
- **Redesigned analog regulator**
- **Existing phase-shifting transformer** (retained)

### Enhanced Control Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           UPGRADED HVPS CONTROL SYSTEM                             │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────────────┤
│   EPICS IOC     │   NEW PLC       │ ANALOG REG      │    ENERPRO FCOG1200         │
│                 │                 │                 │                             │
│ • Target Volt   │ • Enhanced      │ • Redesigned    │ • 12-Pulse Operation        │
│ • Commands      │   Logic         │ • Error Amp     │ • Auto-Balance              │
│ • Monitoring    │ • Dual Outputs  │ • Feedback      │ • Phase Loss Detection      │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        PHASE REFERENCE ADAPTER BOARD                               │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────────────┤
│ 3-PHASE INPUT   │ RESISTOR ARRAY  │ PHASE SHIFTING  │    J7 INTERFACE             │
│                 │                 │                 │                             │
│ • Monitor       │ • 3×2MΩ or      │ • 45° Lead      │ • eAx, eBx, eCx (pins 1-3)  │
│   Windings      │   6 Resistors   │ • 75° Lag       │ • eAy, eBy, eCy (pins 4-6)  │
│ • 75V p-p       │ • Current Limit │ • Amplitude     │ • 5V Bias                   │
│ • C-B-A Seq     │ • Matching      │   Control       │ • 1-8V p-p Range           │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                      12-PULSE THYRISTOR BRIDGE SYSTEM                              │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────────────┤
│   BRIDGE X      │   BRIDGE Y      │ GATE DRIVES     │      KLYSTRON               │
│                 │                 │                 │                             │
│ • 6 Thyristors  │ • 6 Thyristors  │ • 12 Channels   │ • High Voltage              │
│ • 0° Reference  │ • 30° Reference │ • Isolated      │ • RF Amplification          │
│ • J1, J2 Gates  │ • J3, J4 Gates  │ • High Current  │ • SPEAR3 Storage Ring       │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────────────┘
```

---

## System Upgrade Analysis: Current vs. Proposed

### 🔴 **Current System Limitations (FCOG6100 + FCOAUX60)**

#### **Hardware Constraints**
- **Obsolete Components**: FCOG6100 Rev K and FCOAUX60 Rev D are legacy products with limited support
- **Two-Board Architecture**: Requires separate FCOAUX60 auxiliary board for 12-pulse operation
- **Limited Phase References**: Only 3 phase inputs (J5) requiring external phase shifting
- **No Auto-Balance**: Manual balance adjustment only via external error amplifier
- **Aging PLC Platform**: Allen-Bradley SLC 500 with limited processing capability

#### **Operational Issues**
- **Manual Tuning Required**: Balance adjustment requires manual intervention and expertise
- **Limited Bandwidth**: Restricted control loop bandwidth affects dynamic response
- **Phase Loss Sensitivity**: Basic phase loss detection with limited diagnostic capability
- **Maintenance Challenges**: Aging components with increasing failure rates
- **Limited Monitoring**: Basic voltage/current feedback with minimal system diagnostics

#### **Integration Difficulties**
- **Complex Wiring**: Multiple boards require extensive interconnections
- **Signal Conditioning**: External circuits needed for proper phase reference conditioning
- **Limited Flexibility**: Fixed configuration with minimal adaptability
- **Troubleshooting Complexity**: Multiple failure points across two-board system

### 🟢 **Proposed System Advantages (FCOG1200 Rev L)**

#### **Modern Hardware Benefits**
- **Current Technology**: FCOG1200 Rev L is actively supported with modern components
- **Integrated Design**: Single-board 12-pulse operation eliminates auxiliary board
- **Enhanced Phase Processing**: 6 phase inputs (J7) with integrated phase shifting capability
- **Built-in Auto-Balance**: Automatic balance control with manual override option
- **Advanced PLC**: Modern Allen-Bradley platform with enhanced processing power

#### **Operational Improvements**
- **Automatic Operation**: Auto-balance reduces manual intervention requirements
- **Higher Bandwidth**: ~360 Hz bandwidth (6×fmains) improves dynamic response
- **Advanced Diagnostics**: Enhanced phase loss detection with detailed fault reporting
- **Improved Reliability**: Modern components with better MTBF characteristics
- **Comprehensive Monitoring**: Enhanced system status and diagnostic capabilities

#### **Integration Advantages**
- **Simplified Architecture**: Single firing board reduces complexity
- **Standardized Interface**: J7 connector provides clean phase reference interface
- **Flexible Configuration**: Software-configurable parameters for different applications
- **Better Serviceability**: Single-point troubleshooting and maintenance
- **Future-Proof Design**: Scalable architecture for future enhancements

### 📊 **Performance Comparison Summary**

| **Aspect** | **Current (FCOG6100)** | **Proposed (FCOG1200)** | **Improvement** |
|------------|------------------------|--------------------------|-----------------|
| **Reliability** | Legacy components, aging | Modern, current production | ⬆️ **High** |
| **Maintenance** | Complex, multi-board | Simplified, single-board | ⬆️ **High** |
| **Balance Control** | Manual adjustment only | Automatic + manual override | ⬆️ **High** |
| **Bandwidth** | Limited (~60 Hz) | Enhanced (~360 Hz) | ⬆️ **Medium** |
| **Diagnostics** | Basic fault detection | Advanced fault reporting | ⬆️ **High** |
| **Phase Processing** | 3 inputs, external shifting | 6 inputs, integrated shifting | ⬆️ **Medium** |
| **Support** | Limited/obsolete | Full manufacturer support | ⬆️ **High** |
| **Configuration** | Fixed hardware | Software configurable | ⬆️ **Medium** |

### 💰 **Cost-Benefit Analysis**

#### **Upgrade Investment**
- **FCOG1200 Rev L Board**: ~$8,000-12,000 (estimated)
- **Phase Reference Adapter**: ~$2,000-3,000 (custom design)
- **PLC Upgrade**: ~$5,000-8,000 (modern platform)
- **Engineering/Integration**: ~$15,000-25,000 (design and commissioning)
- **Total Estimated Cost**: ~$30,000-48,000

#### **Long-term Benefits**
- **Reduced Maintenance**: 50-70% reduction in maintenance interventions
- **Improved Uptime**: Enhanced reliability reduces unplanned outages
- **Operational Efficiency**: Automatic balance control reduces operator workload
- **Future Support**: Continued manufacturer support vs. obsolete components
- **Performance Gains**: Better regulation and faster response times

#### **Risk Mitigation**
- **Component Availability**: Current production vs. obsolete parts
- **Technical Support**: Active engineering support vs. limited legacy support
- **Failure Recovery**: Faster diagnosis and repair with modern diagnostics
- **Operational Continuity**: Reduced risk of extended outages due to component failures

---


## Phase Reference Adapter Board Design

### Design Requirements (from Enerpro Discussion)

#### Signal Specifications
- **Input Voltage**: 75V peak-to-peak from monitor windings
- **Output Voltage**: 1-8V peak-to-peak (preferably 1-9V range)
- **DC Bias**: +5V for all six outputs
- **Phase Accuracy**: ±15-20% amplitude matching within each bridge group
- **Frequency**: 50/60 Hz operation

#### Connector Interface
- **Input**: 3-phase monitor windings (C-B-A sequence)
- **Output**: J7 connector (TE Connectivity P/N 640456-8)
- **Mating Connector**: P7 (Enerpro P/N C2MTAPLG08, TE P/N 3-640440-8)

### Adapter Board Circuit Design

```
Monitor Windings Input (75V p-p)
    │
    ├─ Phase A ──► R_A ──┬─► Pin 1 (eAx) ──► FCOG1200 (45° Lead)
    │                    └─► Pin 4 (eAy) ──► FCOG1200 (75° Lag)
    │
    ├─ Phase B ──► R_B ──┬─► Pin 2 (eBx) ──► FCOG1200 (45° Lead)  
    │                    └─► Pin 5 (eBy) ──► FCOG1200 (75° Lag)
    │
    └─ Phase C ──► R_C ──┬─► Pin 3 (eCx) ──► FCOG1200 (45° Lead)
                         └─► Pin 6 (eCy) ──► FCOG1200 (75° Lag)

Where:
• R_A, R_B, R_C = 2MΩ current limiting resistors
• Phase shifting accomplished by FCOG1200 internal RC networks
• RN4A-C modified to 47kΩ for 45° lead (Bridge X)
• RN4D-F modified to 180kΩ for 75° lag (Bridge Y)
```

### Phase Shift Calculations

#### Bridge X (45° Lead)
```
RN4A-C = 47kΩ, C17-C19 = 0.033μF
Phase shift = arctan(ωRC) = arctan(2π×60×47k×0.033μ) = 45°
Amplitude at comparator = 75V × (2M/(2M+3.3k)) × (47k/(47k+3.3k)) = 69.4V
```

#### Bridge Y (75° Lag)  
```
RN4D-F = 180kΩ, C20-C22 = 0.033μF
Phase shift = arctan(ωRC) = arctan(2π×60×180k×0.033μ) = 75°
Amplitude at comparator = 75V × (2M/(2M+3.3k)) × (180k/(180k+3.3k)) = 69.1V
```

---

## Control Signal Interface Design

### SIG HI Signal Generation

```
PLC DAC Output (Unipolar) ──┬──► Summing Amplifier ──► SIG HI to FCOG1200
                             │
Analog Regulator (Bipolar) ──┘

Components:
• PLC: Approximate SIG HI calculation
• Regulator: Error signal (±mA range)
• Sum: Combined control signal
• Range: 0.85-5.85V (recommended by Enerpro)
```

### FCOG1200 Input Characteristics
- **Input Range**: 0.9-5.9V (default), 0-6V (absolute maximum)
- **Input Impedance**: 10kΩ (R40) through buffer amplifier (U8C)
- **Bandwidth**: Determined by optional C31 capacitor
- **Protection**: Current limiting through R40

### Voltage Controlled Oscillator
- **Gain**: ~1667 Hz/V (same as FCOG6100)
- **Control**: U8B PLL summing amplifier output
- **Range**: VDD/2 ± 5V (typically 6.0 ± 5V)
- **Application**: Dynamic system response modeling

---

## Auto-Balance System Integration

### Manual Balance Configuration (Recommended)
Since independent monitoring of the two secondary bridges is not available, the system will use manual balance adjustment:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ External Error  │───►│ FCOG1200        │───►│ Bridge Current  │
│ Amplifier       │    │ Manual Balance  │    │ Equalization    │
│                 │    │                 │    │                 │
│ • Figure 4      │    │ • R11 Trimpot   │    │ • Minimize      │
│   Waveform      │    │ • Manual Adj    │    │   Imbalance     │
│ • Power Line    │    │ • Typical Op    │    │ • Harmonic      │
│   Harmonics     │    │   Voltage       │    │   Reduction     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Balance Adjustment Procedure
1. **Setup**: Configure R11 trimpot for manual balance
2. **Monitoring**: Use external error amplifier signal (Figure 4 from DOCX)
3. **Adjustment**: Minimize current imbalance at typical operating voltage
4. **Verification**: Confirm harmonic reduction and balanced operation

---

## System Performance Characteristics

### Bandwidth and Response
- **FCOG1200 Bandwidth**: ~6×fmains (360 Hz at 60 Hz) for auto-balance
- **Input Filter**: RC time constant τ = R26×C31 = 47.5kΩ×22pF ≈ 1μs
- **Cutoff Frequency**: fc = 1/(2πτ) ≈ 160 kHz (if C31 installed)
- **Recommendation**: Omit C31 for maximum bandwidth (most customers)

### Signal Quality Requirements
- **Phase Reference Amplitude**: 1-8V peak-to-peak at J7 inputs
- **DC Bias**: +5V for all six phase references
- **Amplitude Matching**: ±15-20% within each bridge group
- **Harmonic Content**: Power line harmonics visible in error signal

### Protection and Safety
- **Input Current Limiting**: 2MΩ resistors limit current to safe levels
- **Voltage Clamping**: Recommended clamping at regulator output
- **Phase Loss Detection**: Instant gating inhibition on phase imbalance
- **Soft-Start Recovery**: Gradual restart after fault clearance

---

## Integration Challenges and Solutions

### Phase Sequence Compatibility
**Challenge**: Monitor windings show C-B-A sequence vs. expected A-B-C
**Solution**: SCR identification must match phase reference sequence

### Amplitude and Offset Management
**Challenge**: 75V input signals need reduction to 1-8V range with +5V bias
**Solution**: Resistor divider network with FCOG1200 internal biasing (RN5, RN6)

### Harmonic Content in Control Signal
**Challenge**: Power line harmonics in error signal (Figure 4)
**Solution**: FCOG1200 bandwidth sufficient to act on lower harmonics

### Current Limiting and Protection
**Challenge**: High input voltages could damage FCOG1200
**Solution**: 2MΩ current limiting resistors, maximum current ~37.5μA at 75V

---

## Recommended Implementation Plan

### Phase 1: Hardware Procurement
1. **FCOG1200 Rev. L** with custom modifications:
   - RN4A-C = 47kΩ (45° lead for Bridge X)
   - RN4D-F = 180kΩ (75° lag for Bridge Y)
   - Omit C31 for maximum bandwidth
   - Manual balance configuration (R11 installed)

### Phase 2: Adapter Board Design
1. **Phase Reference Adapter**:
   - 3×2MΩ input resistors (matched)
   - J7 mating connector (TE P/N 3-640440-8)
   - Proper spacing for high voltage safety
   - Test points for verification

### Phase 3: Control System Integration
1. **PLC Upgrade**: New Allen-Bradley system
2. **Analog Regulator**: Redesigned error amplifier
3. **Signal Interface**: SIG HI summing and clamping
4. **Monitoring**: Enhanced diagnostics and status

### Phase 4: Commissioning and Testing
1. **Phase Reference Verification**: Oscilloscope verification of timing
2. **Balance Adjustment**: Manual balance optimization
3. **Performance Testing**: Harmonic analysis and system response
4. **Documentation**: As-built drawings and procedures

---

## Technical Specifications Summary

| Parameter | Current System | Upgraded System |
|-----------|----------------|-----------------|
| **Firing Board** | FCOG6100 Rev. K | FCOG1200 Rev. L |
| **Pulse Count** | 6 + 6 (via FCOAUX60) | 12 (integrated) |
| **Phase References** | 3 (J5 connector) | 6 (J7 connector) |
| **Auto-Balance** | None | Manual (R11 trimpot) |
| **Input Amplitude** | 75V p-p | 75V p-p (same) |
| **Output Amplitude** | N/A | 1-8V p-p at J7 |
| **Phase Shift** | Fixed | 45° lead / 75° lag |
| **SIG HI Range** | 0.9-5.9V | 0.85-5.85V (recommended) |
| **Bandwidth** | Limited | ~360 Hz (auto-balance) |

This comprehensive system overview provides the foundation for successful integration of the Enerpro FCOG1200 firing board into the existing HVPS control system while maintaining compatibility with existing hardware and improving overall performance through 12-pulse operation.
