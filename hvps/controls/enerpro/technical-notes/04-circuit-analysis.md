# 04 — Circuit Analysis & Schematics

## Schematic Evolution Overview

The FCOG1200 firing board has undergone continuous development over 25+ years, with three major documented revisions showing progressive improvements in stability, manufacturability, and functionality.

### Revision Timeline

| Revision | Date | Drawing | Key Changes |
|----------|------|---------|-------------|
| **F** | August 13, 1996 | E640_F | Initial auto-balance circuit introduction |
| **K** | September 30, 2009 | E640_K | Stability improvements, regulator upgrade |
| **L** | March 1, 2021 | E640_L | Latest production design, comprehensive updates |

---

## Revision F (1996) — Initial Auto-Balance Implementation

### Key Circuit Blocks

#### Power Supply Section
- **Bridge Rectifier**: W02M full-wave bridge
- **Voltage Regulator**: LM340LAH-12 (TO-220 package)
- **Filter Capacitors**: C1 (1000μF), C2-C3 (2.2μF)
- **Generated Voltages**: +30V (unregulated), +12V (regulated), +5V (regulated)

#### ASIC-Based Firing Logic
- **U3**: EP1014B/C (Primary firing ASIC)
- **U4**: EP1015 (Secondary firing ASIC)  
- **U5**: EP1016 (Support ASIC)
- **Coordination**: Three ASICs work together for 12-pulse timing

#### Phase Reference Processing
- **Attenuation**: RN1 (3.3kΩ) networks reduce line voltages
- **Filtering**: C17-C22 (0.033μF) with RN4 (120kΩ) for phase shifting
- **Comparison**: U6 (LM239N) quad comparator generates square waves
- **Phase Loss**: Basic phase loss detection circuit

#### Auto-Balance Circuit (New in Rev F)
- **Manual Adjustment**: R11 (25kΩ trimpot) for manual balance
- **Current Sensing**: Basic current feedback for balance adjustment
- **Integration**: First implementation of 12-pulse current balancing

### Circuit Limitations (Rev F)
- **Temperature Stability**: TO-220 regulator package thermal issues
- **Noise Susceptibility**: Limited filtering and grounding
- **Component Availability**: Some components becoming obsolete
- **Manufacturing Issues**: Layout not optimized for production

---

## Revision K (2009) — Stability and Reliability Improvements

### Major Circuit Changes

#### Power Supply Improvements
- **Voltage Regulator**: LM78L12CZL (TO-92 package) replaces LM340LAH-12
- **Thermal Performance**: Better heat dissipation with TO-92 package
- **Reliability**: Improved long-term stability
- **Cost Reduction**: Lower-cost regulator with better availability

#### Enhanced Filtering and Stability
- **C5**: 2.2μF added for additional power supply filtering
- **C6**: 470μF added for improved regulation
- **C39**: Additional stability capacitor
- **Ground Plane**: Corrected ground plane for better EMI performance

#### Phase Reference Comparator Improvements
- **C33-C38**: Hysteresis capacitors added to phase reference comparators
- **Function**: Reduces noise sensitivity and improves switching thresholds
- **Stability**: Eliminates false triggering from noise and harmonics
- **Performance**: More reliable phase reference processing

#### Auto-Balance Circuit Refinements
- **Component Values**: Optimized resistor and capacitor values
- **U12**: MC14070BCP XOR gate for auto-balance logic
- **R48, R49**: 10.0kΩ resistors for auto-balance signal processing
- **R50, R51**: 100kΩ feedback resistors for balance control

### Circuit Analysis (Rev K)

#### Phase Loss Detection Enhancement
```
Phase Inputs → Attenuation (RN1) → Filtering (RN4/C17-C22) → 
Comparators (U6) → Hysteresis (C33-C38) → ASIC Processing
```

#### Auto-Balance Signal Flow
```
Current Feedback → U12 (XOR Logic) → R48/R49 (Signal Conditioning) → 
Summing Amplifier → VCO Control → Phase Adjustment
```

#### Power Supply Regulation
```
24VAC Input → W02M Bridge → C1 Filter → LM78L12CZL Regulator → 
C5/C6 Additional Filtering → +12V Output
```

---

## Revision L (2021) — Modern Production Design

### Latest Design Features

#### Component Modernization
- **All Components**: Updated to current production parts
- **Stock Numbers**: Complete parts list with current stock numbers
- **Availability**: Ensured long-term component availability
- **Quality**: Industrial-grade components throughout

#### Enhanced Auto-Balance Options
Three distinct auto-balance configurations:

**1. Manual Balance Configuration**:
- **Install**: R11 (25kΩ trimpot)
- **Omit**: JU4, JU5, R48, R49, U12
- **Application**: Manual adjustment via potentiometer

**2. On-Board Auto-Balance Configuration**:
- **Install**: U12, R48, R49
- **Omit**: R11, JU4, JU5  
- **Function**: Automatic 6×fmains square wave injection

**3. External Auto-Balance Configuration**:
- **Install**: JU4, JU5, R48
- **Omit**: R11, R49, U12
- **Interface**: External control via J6 pin 14

#### Manufacturing Improvements
- **ECO #21-11304**: Engineering change order dated 07-09-19
- **Layout Optimization**: Improved PCB layout for manufacturing
- **Test Access**: Enhanced test point accessibility
- **Documentation**: Complete assembly and test procedures

### Advanced Circuit Analysis (Rev L)

#### Auto-Balance Circuit Operation

**On-Board Auto-Balance Mode**:
```
3φ "X" Currents → Current Sensing → Difference Amplifier → 
6×fmains Square Wave Generator (U12) → VCO Summing Amplifier → 
Phase Angle Adjustment → Current Equalization
```

**Mathematical Relationship**:
- **High Current Bridge**: Delay angle increased (α + Δα)
- **Low Current Bridge**: Delay angle decreased (α - Δα)  
- **Result**: Current equalization between parallel bridges

#### Phase-Locked Loop Analysis

**PLL Components**:
- **Phase Detector**: ASIC-based phase comparison
- **VCO**: Voltage-controlled oscillator for timing generation
- **Loop Filter**: R-C networks for stability and response
- **Frequency Divider**: Digital countdown for pulse timing

**Transfer Function**:
The delay angle α is given by:
```
α = α₀ + (E/12) × R3/(R1+R2) × 180°
```
Where:
- α₀ = minimum delay angle
- E = control voltage (SIG HI)
- R1, R2, R3 = summing amplifier resistors

---

## Gate Drive Circuit Analysis (E128_R Schematic)

### Gate Drive Architecture

#### Power Stage
- **Q1-Q6**: IRF110 MOSFETs for high-current gate drive
- **Q7-Q8**: 2N2222 bipolar transistors for drive amplification
- **Q9-Q11**: BS170 MOSFETs for logic level interface
- **Q12**: IRF110 for additional drive capability

#### Current Limiting and Protection
- **R1-R6**: Gate current limiting resistors (250Ω, 2W)
- **R7-R8**: Current sensing resistors (10Ω, 2W)
- **Fusing**: CP1, CP2 (0.5A) for overcurrent protection

#### Pulse Transformer Interface
- **T1**: Pulse transformer for isolation
- **Primary**: Low-power drive from firing board
- **Secondary**: High-current gate drive to SCRs
- **Isolation**: High-voltage isolation between control and power

### Gate Pulse Characteristics

#### Pulse Profile Options
**Two 30° Burst Mode** (JU1 installed):
- **Initial Pulse**: Hard-firing pulse for reliable turn-on
- **Sustaining Pulses**: "Picket fence" pulses at 23,040 Hz (60 Hz mains)
- **Duration**: Two 30° bursts per 180° period
- **Application**: Normal inductance loads

**Single 120° Burst Mode** (JU1 omitted):
- **Initial Pulse**: Same hard-firing pulse
- **Sustaining Pulses**: Continuous picket fence for 120°
- **Duration**: Single 120° burst per 180° period  
- **Application**: High inductance loads

#### Timing Precision
- **Pulse Spacing**: 30° for FCOG1200, 60° for FCOG6100
- **Accuracy**: ±1° typical over temperature and supply variations
- **Jitter**: Minimal jitter due to ASIC-based timing
- **Synchronization**: Locked to AC mains frequency

---

## Component Analysis by Function

### Critical Analog Components

#### Operational Amplifiers (U7, U8: MC34074BC)
- **Configuration**: Quad op-amp packages
- **Function**: Signal conditioning, summing amplifier, buffer stages
- **Specifications**: Rail-to-rail operation, low offset
- **Applications**: SIG HI buffering, auto-balance processing, VCO control

#### Comparators (U6: LM239N)
- **Configuration**: Quad comparator package
- **Function**: Phase reference processing, threshold detection
- **Features**: Open-collector outputs, hysteresis capability
- **Applications**: Phase loss detection, reference signal conditioning

#### Voltage References
- **+5V Reference**: Precision reference for ASIC operation
- **+12V Regulation**: LM78L12CZL three-terminal regulator
- **Stability**: ±1% regulation over line and load variations

### Digital Logic Components

#### Custom ASICs (U3, U4, U5)
- **Technology**: Custom LSI circuits
- **Function**: Complete firing logic implementation
- **Advantages**: Reduced component count, improved reliability
- **Features**: Phase-locked loop, digital countdown, pulse generation

#### Standard Logic (U9, U12)
- **U9**: MC14073BCP (Triple 3-input AND gates)
- **U12**: MC14070BCP (Quad XOR gates)
- **Function**: Auto-balance logic, signal processing
- **Technology**: CMOS for low power consumption

#### Driver Circuits (U10, U11: ULN2004A)
- **Configuration**: Darlington driver arrays
- **Function**: High-current drive for gate circuits
- **Specifications**: 500mA per channel, 50V breakdown
- **Protection**: Built-in flyback diodes

### Passive Component Analysis

#### Precision Resistors
- **R25**: SIG HI range setting (249kΩ or 150kΩ, 1% tolerance)
- **R40**: Input impedance setting (10.0kΩ, 1% tolerance)
- **R47**: Signal conditioning (47.5kΩ, 1% tolerance)
- **Function**: Critical for firing angle accuracy

#### Timing Capacitors
- **C23, C29**: Frequency compensation (matched ±1%)
- **C17-C22**: Phase reference filtering (5% tolerance)
- **Function**: Determine phase shift and frequency response

#### Power Components
- **R1-R6**: Gate current limiting (250Ω, 2W carbon composition)
- **R7-R8**: Current sensing (10Ω, 2W wire wound)
- **Function**: Protect gate drive circuits, provide current feedback

---

## Circuit Performance Analysis

### Frequency Response Characteristics

#### Phase-Locked Loop Response
From IEEE paper analysis (Bourbeau 1983):
- **Gain Peak**: 0.81 dB at 60 rad/s
- **-3dB Point**: 415 rad/s
- **Phase Margin**: -45° at 339 rad/s
- **Stability**: Stable over full operating range

#### Control Bandwidth
- **SIG HI Response**: 2-3 AC cycles settling time
- **Phase Reference**: Tracks mains frequency variations
- **Auto-Balance**: 6×fmains update rate (360 Hz at 60 Hz mains)

### Temperature Stability

#### Component Drift Analysis
- **ASIC Circuits**: Minimal drift with temperature
- **Precision Resistors**: ±50 ppm/°C typical
- **Timing Capacitors**: ±100 ppm/°C film capacitors
- **Overall Accuracy**: ±1° over industrial temperature range

#### Thermal Design
- **Power Dissipation**: Distributed across multiple components
- **Heat Sinking**: TO-92 regulator package adequate for power levels
- **Airflow**: Natural convection cooling sufficient

### Noise Immunity

#### EMI Considerations
- **Ground Plane**: Solid ground plane (improved in Rev K)
- **Filtering**: Input and output filtering for conducted emissions
- **Shielding**: PCB layout minimizes radiated emissions
- **Isolation**: High-voltage isolation between control and power

#### Signal Integrity
- **Phase Reference**: Hysteresis prevents false triggering
- **SIG HI Input**: Input filtering reduces noise sensitivity
- **Gate Outputs**: High drive current ensures reliable SCR triggering
- **Power Supply**: Multiple filter stages reduce ripple and noise

---

## Design Trade-offs and Optimization

### Performance vs. Cost
- **ASIC Integration**: Higher development cost, lower production cost
- **Component Selection**: Industrial grade vs. commercial grade
- **PCB Complexity**: Multi-layer board for performance vs. cost

### Flexibility vs. Simplicity
- **Configuration Options**: Multiple jumper settings vs. fixed configuration
- **Auto-Balance**: Three methods vs. single method
- **Test Access**: Multiple test points vs. minimal access

### Reliability vs. Features
- **Component Count**: More features require more components
- **Complexity**: Advanced features increase potential failure modes
- **Redundancy**: Dual ASICs provide some redundancy

### Manufacturing Considerations
- **Component Availability**: Long-term availability vs. latest technology
- **Assembly Complexity**: Automated assembly vs. manual assembly
- **Test Requirements**: Comprehensive testing vs. minimal testing
- **Documentation**: Complete documentation vs. minimal documentation

