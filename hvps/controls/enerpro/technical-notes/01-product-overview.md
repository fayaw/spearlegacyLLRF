# 01 — Product Overview & Evolution

## Product Families

### FCOG1200 — 12-Pulse General Purpose Gate Firing Board

The FCOG1200 is Enerpro's flagship 12-pulse thyristor firing board designed for high-performance power conversion applications requiring low harmonic distortion.

#### Key Features
- **12 isolated SCR gate firing pulses** spaced at 30° intervals
- **Dual custom 24-pin ASICs** (U3 and U4) containing all firing circuit logic
- **Automatic adaptation** to AC mains sequence (a-b-c or a-c-b) and 30° phase shift
- **Phase loss detection** with instant gating inhibition and soft-start recovery
- **Programmable phase reference shift** (0° for controllers, 30° for converters)
- **Auto-balance capability** for current equalization in parallel 12-pulse converters
- **Frequency selection** (50Hz/60Hz operation)

#### Applications
- 12-pulse DC converters with reduced harmonic content
- AC controllers requiring precise phase control
- High-power thyristor drives with stringent THD requirements
- Parallel converter systems requiring current balancing

#### Harmonic Reduction Benefits
12-pulse rectification provides:
- **Virtual elimination** of 5th and 7th harmonics from mains current
- **Reduced ripple current** in DC output (720 Hz ripple frequency, halved driving voltage)
- **Improved power quality** of AC mains current
- **Reduced size** of DC filter choke requirements

### FCOG6100 — 6-Pulse General Purpose Gate Firing Board

The FCOG6100 provides traditional 6-pulse thyristor control for applications where 12-pulse complexity is not required.

#### Key Features
- **6 isolated SCR gate firing pulses** spaced at 60° intervals
- **Single custom 24-pin ASIC** containing firing circuit logic
- **Similar control interface** to FCOG1200 for system compatibility
- **Phase loss detection** and protection features
- **Configurable for various SCR topologies** (controllers, converters)

#### Applications
- 6-pulse SCR controllers
- Single-bridge DC converters
- Cost-sensitive applications not requiring 12-pulse performance
- Retrofit applications for existing 6-pulse systems

---

## Product Evolution Timeline

### Revision F (August 1996)
**E640_F FCOG1200 Schematic (08-13-96)**

- **Initial auto-balance circuit introduction**
- First implementation of current balancing for 12-pulse converters
- Basic ASIC-based firing circuit architecture established
- Manual balance adjustment via on-board trimpot

**Key Components:**
- Custom ASICs U3, U4, U5 for firing logic
- LM340LAH-12 voltage regulator (TO-220 package)
- Basic phase reference filtering
- Manual balance potentiometer R11

### Revision K (September 2009)
**E640_K FCOG1200 Schematic (09-30-09)**

- **12V regulator replacement** with new TO-92 package (LM78L12CZL)
- **Added phase reference comparator hysteresis capacitors** (C33-C38)
- **Stability improvements** with additional capacitors (C5, C6, C39)
- **Ground plane corrections** for improved EMI performance
- **Enhanced auto-balance circuit** with refined component values

**Key Improvements:**
- Better temperature stability
- Reduced noise susceptibility
- Improved phase reference processing
- Enhanced auto-balance performance

### Revision L (March 2021)
**E640_L FCOG1200 Schematic (03-01-21)**

- **Latest production design** incorporating all previous improvements
- **ECO #21-11304** changes dated 07-09-19
- **Comprehensive parts list** with current stock numbers
- **Refined auto-balance options** (3 configuration methods)
- **Enhanced connector specifications** and test point access

**Modern Features:**
- Current production components
- Improved manufacturability
- Enhanced serviceability
- Complete documentation package

---

## ASIC-Based Architecture

### Design Philosophy

All Enerpro firing boards utilize **custom Application-Specific Integrated Circuits (ASICs)** rather than discrete logic components. This approach provides:

#### Advantages
- **Reduced component count** and board complexity
- **Improved reliability** through integration
- **Consistent timing** and performance characteristics
- **Proprietary protection** of firing algorithms
- **Cost reduction** in volume production
- **Enhanced noise immunity**

#### FCOG1200 Dual-ASIC Design
- **U3 ASIC**: Primary firing logic and phase detection
- **U4 ASIC**: Secondary firing logic and pulse generation
- **Coordinated operation** for 12-pulse timing precision
- **Built-in redundancy** and fault tolerance

#### FCOG6100 Single-ASIC Design
- **Single 24-pin ASIC** contains complete 6-pulse firing logic
- **Simplified design** for cost-sensitive applications
- **Compatible control interface** with FCOG1200

---

## Control Signal Interface

### SIG HI Command Input

Both product families accept flexible command input formats:

#### Voltage Command (Default)
- **Range**: 0.9 to 5.9 VDC (R25 = 249 kΩ)
- **Alternative**: 0 to 5 VDC (R25 = 150 kΩ)
- **Input Impedance**: 10.0 kΩ (R40)

#### Current Command (Optional)
- **Range**: 4 to 20 mA (maximum 50 mA)
- **Configuration**: Select R40 for desired voltage drop
- **Application**: Industrial process control compatibility

### Phase Reference Inputs

#### High-Power Operation
- **Direct connection** to transformer secondary voltages
- **Six-phase input** (two sets of three-phase, 30° shifted)
- **Automatic phase sequence detection** and adaptation

#### Low-Power Testing
- **Test connector J7** for 5 VPP three-phase references
- **Laboratory checkout** without high-voltage connection
- **External phase reference option** for special applications

---

## Power Supply Requirements

### Input Power
- **24 VAC, single phase**
- **24 VA power rating**
- **Customer-supplied external source**

### Generated Voltages
- **±30 VDC** (unregulated) for gate drive circuits
- **±12 VDC** (regulated) for logic and control circuits  
- **±5 VDC** (regulated) for ASIC and digital logic

### Power Supply Evolution
- **Revision F**: LM340LAH-12 in TO-220 package
- **Revision K/L**: LM78L12CZL in TO-92 package (improved thermal characteristics)

---

## Application-Specific Configurations

### Controller Applications (0° Phase Shift)
- **Phase reference filters**: 0.01 μF capacitors with RN4 = 120 kΩ
- **Alternative**: 0.033 μF capacitors with RN4 = 33 kΩ
- **Use case**: AC motor drives, heating controllers

### Converter Applications (30° Phase Shift)
- **Phase reference filters**: 0.033 μF capacitors with RN4 = 120 kΩ
- **30° lagging shift** for converter operation
- **Use case**: DC power supplies, battery chargers

### Frequency Selection
- **60 Hz Operation**: RN4 = 120 kΩ, C23/C29 = 0.27 μF
- **50 Hz Operation**: RN4 = 150 kΩ, C23/C29 = 0.33 μF, J5 jumper configuration

---

## Gate Pulse Profiles

### Dual 30° Burst Mode (Default)
- **JU1 and JU2 installed**
- **Two 30°-wide bursts** per cycle
- **Initial hard-firing pulse** followed by sustaining "picket fence" pulses
- **Recommended for**: Normal load inductance applications

### Single 120° Burst Mode
- **JU1 and JU2 omitted**
- **Single 120°-wide burst** per cycle
- **Same hard-firing initial pulse** structure
- **Recommended for**: High inductance loads, special applications

---

## System Integration Features

### Phase Loss Protection
- **Instant gating inhibition** on phase imbalance or loss
- **Soft-start recovery** when fault clears
- **LED indication** (PD1) of phase loss status
- **Prevents erratic operation** during power system transients

### Auto-Balance System (FCOG1200 Only)
Three configuration options for current balancing:

1. **Manual Balance**: On-board trimpot adjustment (R11)
2. **On-Board Auto-Balance**: Automatic 6×fmains injection circuit
3. **External Auto-Balance**: Interface for external control systems

### Diagnostic Features
- **Multiple test points** for oscilloscope verification
- **LED status indicators** (Phase Loss, Power On, Inhibit)
- **Accessible connector interfaces** for system integration
- **Comprehensive waveform documentation** for troubleshooting

---

## Competitive Advantages

### Versus RC Delay Circuits
- **Frequency-independent delay angle** (not proportional to frequency)
- **No phase balance adjustments** required
- **Temperature-stable operation** (no RC drift)
- **Automatic phase sequence adaptation**
- **Built-in line synchronization** for gate pulse trains

### Versus Discrete Logic Designs
- **Reduced component count** and failure modes
- **Consistent manufacturing** and performance
- **Integrated protection features**
- **Simplified troubleshooting** and maintenance
- **Cost-effective volume production**

### Industry Standards Compliance
- **Proven track record** since 1991
- **Wide industrial acceptance** for 12-pulse applications
- **Compatible with standard thyristor gate drives**
- **Meets stringent THD specifications** imposed by utilities

