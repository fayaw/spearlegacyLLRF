# 07 — Auto-Balance System

## Auto-Balance System Overview

The FCOG1200 firing board provides three distinct methods for balancing currents in parallel 12-pulse converter systems. This capability is essential for optimal harmonic cancellation and system performance.

### Why Auto-Balance is Needed

#### Phase Shift Transformer Imperfections
Real-world transformers have inherent imperfections that affect 12-pulse converter performance:

1. **Open Circuit Voltage Unbalance**: Small differences in secondary voltages
2. **Impedance Unbalance**: Unequal leakage inductances between windings
3. **Phase Shift Deviation**: Slight deviation from ideal 30° phase shift
4. **Manufacturing Tolerances**: Normal variations in transformer construction

#### Consequences Without Balancing
- **Unequal Bridge Currents**: Current imbalance between parallel bridges
- **Harmonic Content**: 5th and 7th harmonics not completely canceled
- **DC Ripple**: Six-times-mains-frequency ripple on converter output
- **Reduced Performance**: Higher THD and increased filter requirements

#### Benefits of Auto-Balance
- **Current Equalization**: Balanced currents between parallel bridges
- **Harmonic Minimization**: Optimal cancellation of 5th and 7th harmonics
- **Ripple Reduction**: Minimized DC output ripple
- **System Optimization**: Maximum benefit from 12-pulse configuration

---

## Method 1: Manual Balance (On-Board Trimpot)

### Configuration Requirements

#### Component Installation
- **Install**: R11 (25 kΩ trimpot)
- **Omit**: JU4, JU5, R48, R49, U12
- **Application**: Simple systems with stable load conditions

#### Circuit Description
The manual balance method uses a precision trimpot to adjust the nominal 30° group delay between the two bridge sets.

### Adjustment Procedure

#### Setup Requirements
1. **Current Monitoring**: Install current transformers on both bridge outputs
2. **Load Application**: Apply rated load to converter system
3. **Measurement Equipment**: Accurate AC current meters or oscilloscope
4. **Safety Precautions**: Ensure proper isolation and safety procedures

#### Step-by-Step Adjustment
1. **Initial Position**: Set R11 to center position (12.5 kΩ)
2. **Baseline Measurement**: Record initial current in both bridges
3. **Calculate Imbalance**: Determine current difference percentage
4. **Adjustment Direction**: 
   - If Bridge 1 > Bridge 2: Adjust R11 clockwise
   - If Bridge 2 > Bridge 1: Adjust R11 counterclockwise
5. **Fine Tuning**: Make small adjustments and monitor current balance
6. **Verification**: Confirm balance maintained across load range

#### Performance Criteria
- **Target Balance**: Current difference < 5% of average current
- **Load Range**: Balance maintained from 25% to 100% load
- **Stability**: No drift over time or temperature variations
- **Adjustment Range**: ±15° typical adjustment range

### Advantages and Limitations

#### Advantages
- **Simplicity**: No complex circuitry required
- **Cost**: Lowest cost implementation
- **Reliability**: Minimal components, high reliability
- **Control**: Direct manual control over balance adjustment

#### Limitations
- **Manual Adjustment**: Requires periodic readjustment
- **Load Dependency**: May require different settings for different loads
- **Drift**: Potential drift with temperature and component aging
- **Maintenance**: Requires skilled technician for adjustment

---

## Method 2: On-Board Auto-Balance Circuit

### Configuration Requirements

#### Component Installation
- **Install**: U12 (MC14070BCP), R48 (10.0kΩ), R49 (10.0kΩ)
- **Omit**: R11, JU4, JU5
- **Application**: Automatic balancing without external control

### Circuit Operation Principle

#### Signal Flow
```
3φ "X" Currents → Current Sensing → Difference Detection → 
6×fmains Square Wave Generator → VCO Summing Amplifier → 
Phase Angle Modulation → Current Equalization
```

#### Auto-Balance Algorithm
1. **Current Monitoring**: Continuously monitors current difference between bridges
2. **Error Detection**: Generates error signal proportional to current imbalance
3. **Modulation Signal**: Creates 6×fmains square wave (360 Hz at 60 Hz mains)
4. **Phase Adjustment**: Injects modulation into VCO summing amplifier
5. **Automatic Correction**: 
   - Increases delay angle of high-current bridge
   - Decreases delay angle of low-current bridge
   - Continuously adjusts for optimal balance

#### Mathematical Relationship
The correction algorithm implements:
```
α_high = α_nominal + Δα
α_low = α_nominal - Δα
```
Where Δα is proportional to the current difference.

### Circuit Analysis

#### U12 XOR Gate Function
The MC14070BCP quad XOR gate (U12) performs the modulation function:
- **Input 1**: Current difference signal (Ixy)
- **Input 2**: 6×fmains clock signal (CK2)
- **Output**: Modulated square wave for VCO control
- **Logic**: XOR operation creates the required modulation

#### Signal Processing Components
- **R48 (10.0kΩ)**: Input signal conditioning
- **R49 (10.0kΩ)**: Output signal conditioning  
- **R50 (100kΩ)**: Feedback resistor for loop stability
- **R51 (100kΩ)**: Feedback resistor for loop stability

#### Frequency Selection
- **6×fmains**: Optimal frequency for current balance control
- **60 Hz System**: 360 Hz modulation frequency
- **50 Hz System**: 300 Hz modulation frequency
- **Synchronization**: Locked to mains frequency for stability

### Performance Characteristics

#### Response Time
- **Initial Balance**: Typically 5-10 AC cycles
- **Load Changes**: 2-3 AC cycles for step load changes
- **Stability**: No hunting or oscillation under normal conditions
- **Accuracy**: Maintains balance within ±2% typically

#### Operating Range
- **Load Range**: Effective from 10% to 100% rated load
- **Imbalance Correction**: Can correct up to ±20% initial imbalance
- **Temperature Stability**: Maintains balance over industrial temperature range
- **Line Voltage Variations**: Immune to ±10% line voltage changes

### Verification and Testing

#### Test Points
- **TP18**: Auto-balance output signal monitoring
- **Current Monitoring**: External current transformers required
- **Oscilloscope Verification**: Monitor modulation waveform

#### Performance Verification
1. **Automatic Operation**: Apply load and observe automatic balancing
2. **Response Time**: Measure time to achieve balance after load change
3. **Stability**: Verify no oscillation or hunting behavior
4. **Load Variation**: Test response across full load range
5. **Balance Quality**: Confirm current difference < 2% at rated load

---

## Method 3: External Auto-Balance Control

### Configuration Requirements

#### Component Installation
- **Install**: JU4, JU5, R48 (10.0kΩ)
- **Omit**: R11, R49, U12
- **Application**: Integration with external control systems

### Interface Specifications

#### Input/Output Connections
- **J6 Pin 14**: High-frequency input from external auto-balance circuit
- **J6 Pin 15**: CK2 signal output (6×fmains) for external circuit
- **J6 Pin 13**: CK2# signal output (inverted 6×fmains) for external circuit

#### Signal Characteristics
- **Input Signal**: ±5V square wave at 6×fmains frequency
- **Output Signals**: Logic level CK2 and CK2# for synchronization
- **Impedance**: 10kΩ input impedance via R48
- **Bandwidth**: DC to 1 kHz typical for control signals

### External Circuit Requirements

#### Functional Requirements
1. **Current Sensing**: Monitor currents from both bridge outputs
2. **Difference Calculation**: Compute current imbalance
3. **Control Algorithm**: Generate correction signal
4. **Output Generation**: Produce 6×fmains modulated square wave
5. **Synchronization**: Use CK2/CK2# signals for timing reference

#### Typical External Circuit
```
Bridge Current Inputs → Current Transformers → Rectification/Filtering → 
Difference Amplifier → Control Algorithm → Modulator → 
6×fmains Output to J6 Pin 14
```

#### Control Algorithm Options
1. **Proportional Control**: Simple proportional correction
2. **PI Control**: Proportional-integral for zero steady-state error
3. **Adaptive Control**: Self-tuning for varying load conditions
4. **Digital Control**: Microprocessor-based advanced algorithms

### Advanced Control Capabilities

#### Closed-Loop Regulation
External auto-balance can provide:
- **Precise Current Control**: Exact current balance specification
- **Load Compensation**: Automatic adjustment for load variations
- **System Integration**: Interface with overall plant control system
- **Data Logging**: Record balance performance and trends

#### Enhanced Features
- **Multiple Converter Control**: Balance multiple 12-pulse converters
- **Harmonic Optimization**: Minimize specific harmonic components
- **Power Factor Control**: Optimize overall system power factor
- **Predictive Control**: Anticipate load changes for faster response

### Implementation Guidelines

#### External Circuit Design
1. **Current Sensing**: Use precision current transformers
2. **Signal Processing**: High-resolution A/D conversion
3. **Control Algorithm**: Implement appropriate control law
4. **Output Stage**: Generate clean 6×fmains square wave
5. **Isolation**: Provide proper isolation for safety

#### System Integration
1. **Communication**: Interface with plant control system
2. **Monitoring**: Provide status and performance data
3. **Diagnostics**: Built-in self-test and fault detection
4. **Maintenance**: Remote monitoring and adjustment capabilities

---

## Comparative Analysis of Balance Methods

### Performance Comparison

| Parameter | Manual Balance | On-Board Auto | External Auto |
|-----------|----------------|---------------|---------------|
| **Setup Complexity** | Simple | Moderate | Complex |
| **Cost** | Lowest | Moderate | Highest |
| **Accuracy** | ±5% | ±2% | ±1% |
| **Response Time** | Manual | 5-10 cycles | 2-3 cycles |
| **Load Adaptation** | Manual | Automatic | Automatic |
| **System Integration** | None | Limited | Full |
| **Maintenance** | Periodic | Minimal | Advanced |

### Selection Criteria

#### Choose Manual Balance When:
- **Simple Systems**: Single converter, stable load
- **Cost Sensitive**: Budget constraints important
- **Skilled Maintenance**: Qualified technicians available
- **Infrequent Adjustment**: Load conditions rarely change

#### Choose On-Board Auto-Balance When:
- **Automatic Operation**: Unattended operation required
- **Variable Loads**: Load conditions change frequently
- **Standard Performance**: ±2% balance adequate
- **Moderate Complexity**: Balance between cost and performance

#### Choose External Auto-Balance When:
- **Precision Required**: ±1% balance specification
- **System Integration**: Part of larger control system
- **Advanced Features**: Monitoring, logging, diagnostics needed
- **Multiple Converters**: Coordinated control of multiple units

---

## Installation and Setup Guidelines

### General Installation Requirements

#### Current Sensing
All auto-balance methods require current monitoring:
- **Current Transformers**: Precision CTs on both bridge outputs
- **Accuracy**: ±1% accuracy class minimum
- **Burden**: Match CT burden to measurement circuit
- **Safety**: Proper CT secondary grounding and protection

#### Wiring Considerations
- **Signal Cables**: Use shielded cables for current signals
- **Grounding**: Single-point grounding to avoid ground loops
- **Routing**: Separate signal cables from power cables
- **Connections**: Secure, corrosion-resistant connections

### Configuration Verification

#### Initial Setup Check
1. **Component Installation**: Verify correct components installed/omitted
2. **Jumper Settings**: Confirm JU4, JU5 positions per configuration
3. **Wiring**: Check all signal connections
4. **Power Supply**: Verify proper voltages present

#### Functional Testing
1. **No-Load Test**: Verify circuit operation without load
2. **Light Load Test**: Test balance function at reduced load
3. **Full Load Test**: Verify performance at rated load
4. **Dynamic Test**: Test response to load changes

### Troubleshooting Common Issues

#### Poor Balance Performance
**Possible Causes**:
- Incorrect component configuration
- Faulty current sensing
- Inadequate load for balance operation
- External interference

**Solutions**:
- Verify configuration against documentation
- Check current transformer connections and accuracy
- Ensure minimum load for balance circuit operation
- Improve shielding and grounding

#### Oscillation or Instability
**Possible Causes**:
- Excessive loop gain
- Poor grounding
- Noise in current signals
- Incorrect component values

**Solutions**:
- Reduce loop gain (adjust R48, R49 values)
- Improve ground system
- Add filtering to current signals
- Verify component values and installation

#### No Balance Response
**Possible Causes**:
- Missing or incorrect components
- Open circuit in signal path
- Faulty U12 (on-board auto-balance)
- No current difference signal

**Solutions**:
- Check component installation against configuration
- Verify continuity in signal paths
- Test U12 functionality
- Confirm current sensing is working

---

## Maintenance and Optimization

### Routine Maintenance

#### Performance Monitoring
- **Current Balance**: Regular measurement of bridge currents
- **Harmonic Content**: Periodic harmonic analysis
- **Response Time**: Test dynamic response to load changes
- **Stability**: Monitor for hunting or oscillation

#### Component Inspection
- **Trimpot (R11)**: Check for wear and proper adjustment range
- **Connections**: Inspect all signal connections
- **Current Transformers**: Verify CT accuracy and condition
- **PCB**: Check for component degradation or damage

### Performance Optimization

#### Fine Tuning
1. **Load Testing**: Test balance across full load range
2. **Harmonic Analysis**: Measure harmonic content and optimize
3. **Dynamic Response**: Optimize response time vs. stability
4. **Temperature Testing**: Verify performance over temperature range

#### System Integration
1. **Control System Interface**: Optimize interface with plant control
2. **Monitoring Integration**: Integrate with plant monitoring systems
3. **Alarm Integration**: Connect balance alarms to plant alarm system
4. **Data Logging**: Implement performance data logging

### Advanced Diagnostics

#### Test Equipment
- **Precision Current Meters**: For accurate current measurement
- **Harmonic Analyzer**: For harmonic content analysis
- **Oscilloscope**: For waveform analysis and timing verification
- **Data Logger**: For long-term performance monitoring

#### Diagnostic Procedures
1. **Baseline Measurement**: Establish performance baseline
2. **Trend Analysis**: Monitor performance trends over time
3. **Fault Analysis**: Analyze any balance system faults
4. **Predictive Maintenance**: Identify potential issues before failure

