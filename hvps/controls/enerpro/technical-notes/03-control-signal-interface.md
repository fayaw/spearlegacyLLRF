# 03 — Control Signal Interface

## SIG HI Command Input

The SIG HI signal is the primary delay angle command input that controls the firing angle of the thyristors. Both FCOG1200 and FCOG6100 boards accept flexible command formats.

### Voltage Command Mode (Default)

#### Standard Range (Default Configuration)
- **Input Range**: 0.9 to 5.9 VDC
- **Component Setting**: R25 = 249 kΩ
- **Input Impedance**: 10.0 kΩ (R40)
- **Application**: Most common configuration for industrial control

#### Alternative Voltage Range
- **Input Range**: 0 to 5 VDC  
- **Component Setting**: R25 = 150 kΩ
- **Input Impedance**: 10.0 kΩ (R40)
- **Application**: Standard 0-5V industrial control signals

### Current Command Mode (Optional)

#### Standard Current Range
- **Input Range**: 4 to 20 mA
- **Maximum Current**: 50 mA absolute maximum
- **Component Selection**: Select R40 to achieve SIG HI = +6.0V at maximum current
- **Application**: Industrial process control, long-distance transmission

#### Current Mode Configuration
When configured for current input:
- **R40 Selection**: Calculate for desired voltage drop
- **Example**: For 20 mA max, R40 = 300Ω gives 6.0V drop
- **Input Protection**: Built-in current limiting

### Signal Conditioning Circuit

#### Input Stage
```
SIG HI Input → R40 (Input Impedance) → Buffer Amplifier → ASIC Processing
```

#### Buffer Amplifier (U7A/U8C)
- **Function**: High-impedance input buffering
- **Gain**: Unity gain buffer
- **Output**: Drives ASIC control inputs
- **Protection**: Overvoltage and reverse polarity protection

#### Optional Bandwidth Limiting
- **Component**: C31 (optional)
- **Function**: Reduces firing circuit bandwidth in conjunction with SIG HI source resistance
- **Application**: Noise reduction in high-EMI environments

---

## Phase Reference Inputs

The firing boards require phase reference signals to synchronize thyristor firing with the AC mains voltage.

### High-Power Phase References (Normal Operation)

#### Six-Phase Input Configuration
- **Input Requirement**: Two sets of three-phase voltages, 30° phase shifted
- **Voltage Level**: Line voltage level (120V, 240V, 480V typical)
- **Connection**: Direct connection to transformer secondary windings
- **Automatic Adaptation**: Board automatically detects and adapts to phase sequence

#### Phase Reference Processing
1. **Attenuation**: High voltage reduced to logic levels via resistor networks
2. **Filtering**: First-order RC lowpass filters condition the signals
3. **Comparison**: Comparators generate square wave timing references
4. **ASIC Input**: Processed signals feed custom ASICs for firing pulse generation

#### Phase Sequence Adaptation
- **a-b-c Sequence**: Automatic detection and processing
- **a-c-b Sequence**: Automatic detection and processing  
- **30° Phase Shift**: Automatic detection of +30° or -30° shift between bridge sets
- **No Manual Adjustment**: System automatically adapts to mains configuration

### Low-Power Test References (J7 Connector)

#### Test Signal Specifications
- **Voltage Level**: 5 VPP (peak-to-peak)
- **Frequency**: 50 Hz or 60 Hz
- **Phase Relationship**: Two sets of three-phase, 30° shifted
- **Connector**: 8-position MTA header (J7)

#### J7 Pin Assignments
| Pin | Function | Description |
|-----|----------|-------------|
| 1 | Phase A1 | First three-phase set, Phase A |
| 2 | Phase B1 | First three-phase set, Phase B |
| 3 | Phase C1 | First three-phase set, Phase C |
| 4 | Phase A2 | Second three-phase set, Phase A (30° shifted) |
| 5 | Phase B2 | Second three-phase set, Phase B (30° shifted) |
| 6 | Phase C2 | Second three-phase set, Phase C (30° shifted) |
| 7 | Common | Circuit common connection |
| 8 | +15VDC | Unregulated 15V supply (10 mA max) |

#### Test Reference Applications
- **Laboratory Testing**: Checkout without high-voltage connections
- **System Development**: Prototype and development work
- **Troubleshooting**: Isolated testing of firing board functionality
- **External References**: Special applications requiring off-board phase references

---

## Phase Reference Filtering and Shifting

### Filter Configuration for Application Type

#### Converter Applications (30° Lagging Shift)
- **RN4**: 120 kΩ resistor network
- **C17-C22**: 0.033 μF film capacitors (5% tolerance)
- **Phase Shift**: 30° lagging for converter operation
- **Transfer Function**: First-order RC lowpass with ωRC >> 1

#### Controller Applications (0° Shift)

**Option 1 (Capacitor Change)**:
- **RN4**: 120 kΩ resistor network
- **C17-C22**: 0.01 μF film capacitors
- **Phase Shift**: Approximately 0°

**Option 2 (Resistor Change)**:
- **RN4**: 33 kΩ resistor network  
- **C17-C22**: 0.033 μF film capacitors
- **Phase Shift**: Approximately 0°
- **Advantage**: Same capacitor values, only resistor network changes

### Filter Benefits

#### Harmonic Attenuation
The integrating-type reference filters (ωRC >> 1) provide excellent harmonic rejection:

| Harmonic | Attenuation (dB) |
|----------|------------------|
| **5th** | 13.9 |
| **7th** | 17.0 |
| **Higher Order** | Increasing attenuation |

#### Frequency Stability
- **Phase Shift Change**: Only 1.1° for 60 Hz to 50 Hz frequency change
- **Component Tolerance**: ±5% capacitor tolerance = ±0.3° phase shift tolerance
- **Temperature Stability**: Minimal drift with temperature

---

## Phase Loss Detection System

### Detection Principle

The phase loss circuit monitors the balance of the six-phase input voltages and instantly inhibits SCR gating if phases are imbalanced or missing.

#### Phase Summing Signals
- **TP15 (X Signal)**: Sum of one set of three phases
- **TP16 (Y Signal)**: Sum of second set of three phases  
- **Comparator (U6)**: Monitors both signals against upper and lower thresholds

#### Detection Thresholds
- **Upper Threshold**: U6 pin 9
- **Lower Threshold**: U6 pin 10
- **Normal Operation**: Both TP15 and TP16 remain within thresholds
- **Phase Loss**: Either signal exceeds threshold limits

### Phase Loss Response

#### Immediate Actions
1. **Gating Inhibition**: All SCR gate pulses immediately stopped
2. **LED Indication**: Phase Loss LED (PD1) turns ON
3. **Status Output**: Phase loss status available for external monitoring
4. **Protection**: Prevents erratic converter operation

#### Recovery Sequence
1. **Fault Clearance**: Phase voltages return to balanced condition
2. **Soft-Start**: Board automatically initiates soft-start sequence
3. **Gradual Ramp**: Firing angle gradually returns to commanded value
4. **Normal Operation**: Full operation restored smoothly

#### Initial Power-Up Protection
- **Power-Up Delay**: Phase loss circuit active during initial power application
- **Voltage Stabilization**: Gating inhibited until power supply voltages stabilize
- **Transient Immunity**: Prevents erratic response to power-up transients

---

## Additional Control Signals

### I1# and I2# Control Inputs

#### I1# Signal (J6 Pin 4)
- **Function**: Additional control input
- **Voltage Level**: +12V logic levels
- **Application**: External enable/disable control
- **Default State**: Pulled to appropriate logic level

#### I2# Signal (J6 Pin 12)  
- **Function**: Secondary control input
- **Voltage Level**: +12V logic levels
- **Application**: Soft-start control (with R37 = 1.5kΩ)
- **Configuration**: Connect I2# to +12V for soft-start enable

### Clock and Timing Signals

#### CK2/CK2# Signals (J6 Pins 13, 15)
- **Function**: Internal clock signals for auto-balance
- **Frequency**: 6 × fmains (360 Hz at 60 Hz mains)
- **Application**: Auto-balance circuit synchronization
- **Availability**: Accessible for external auto-balance control

#### Auto-Balance Interface (J6 Pin 14)
- **Signal**: Ixy/B (Auto-balance control)
- **Function**: Current balance adjustment signal
- **Input/Output**: Bidirectional depending on configuration
- **Voltage Range**: ±5V typical

---

## Signal Waveforms and Timing

### SIG HI Response Characteristics

#### Delay Angle Relationship
- **Linear Response**: Delay angle proportional to SIG HI voltage
- **Range**: Typically 5° to 165° firing angle range
- **Resolution**: Limited by ASIC internal resolution
- **Accuracy**: ±1° typical over temperature and supply variations

#### Dynamic Response
- **Bandwidth**: Determined by PLL characteristics and optional C31
- **Settling Time**: Typically 2-3 AC cycles for step changes
- **Stability**: No oscillation or hunting under normal conditions

### Phase Reference Waveforms

#### Input Waveforms (High Power)
- **Voltage Level**: Line voltage (sinusoidal)
- **Frequency**: 50 Hz or 60 Hz
- **Phase Relationships**: Six phases, 60° spacing, two groups 30° apart

#### Processed Reference Waveforms
- **Attenuated Signals**: Reduced to logic levels (RN4 networks)
- **Filtered Signals**: RC filtered for harmonic rejection
- **Comparator Outputs**: Square waves at zero crossings
- **ASIC Inputs**: Clean digital timing references

### Gate Output Waveforms

#### FCOG1200 (12-Pulse)
- **Pulse Count**: 12 pulses per AC cycle
- **Spacing**: 30° between pulses
- **Pulse Width**: Selectable (30° bursts or 120° continuous)
- **Current Capability**: High current for reliable thyristor triggering

#### FCOG6100 (6-Pulse)  
- **Pulse Count**: 6 pulses per AC cycle
- **Spacing**: 60° between pulses
- **Pulse Width**: Similar profile options to FCOG1200
- **Current Capability**: High current for reliable thyristor triggering

---

## Interface Design Guidelines

### SIG HI Signal Source Requirements

#### Voltage Source Characteristics
- **Output Impedance**: Low impedance preferred (< 1kΩ)
- **Noise Immunity**: Use shielded cable for long runs
- **Grounding**: Single-point ground to avoid ground loops
- **Protection**: Consider input protection for harsh environments

#### Current Source Characteristics
- **Compliance Voltage**: Must exceed maximum R40 voltage drop
- **Current Accuracy**: ±1% for best firing angle accuracy
- **Loop Resistance**: Account for cable resistance in long runs
- **Isolation**: Consider isolation for safety in high-voltage applications

### Phase Reference Interface

#### High-Power Connections
- **Wire Sizing**: Adequate for reference current (typically low)
- **Insulation**: Appropriate for line voltage levels
- **Routing**: Separate from high-current power circuits
- **Protection**: Fusing recommended for safety

#### Low-Power Test Connections
- **Signal Generators**: Standard function generators adequate
- **Cable Types**: Standard instrumentation cables
- **Grounding**: Common ground reference required
- **Synchronization**: Maintain proper phase relationships between channels

### System Integration Considerations

#### Control System Interface
- **Signal Levels**: Match control system output capabilities
- **Update Rate**: Consider control loop bandwidth requirements
- **Isolation**: Electrical isolation may be required for safety
- **Diagnostics**: Provide access to test points for troubleshooting

#### Protection System Integration
- **Phase Loss Output**: Interface to protection system
- **Emergency Stop**: Coordinate with overall system emergency stop
- **Status Monitoring**: Provide status signals to control system
- **Fault Reporting**: Clear indication of fault conditions and causes

