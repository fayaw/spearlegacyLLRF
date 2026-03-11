# 05 — Operating Procedures

> **Sources**: `OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.pdf`, `OP-0102_FCOG6100_Op_Manual.pdf`, `FCOG1200 Auto Balance.pdf`, `E640_L FCOG1200 Schematic (03-01-21).pdf`, `enerproDiscussion07072022.docx`

## Initial Setup and Configuration

### Pre-Installation Checklist

#### Power Supply Verification
- **Input Voltage**: Verify 24 VAC, single phase available
- **Power Rating**: Ensure 24 VA minimum capacity
- **Isolation**: Confirm proper isolation from high-voltage circuits
- **Grounding**: Establish proper ground reference

#### Application Configuration
- **Converter vs. Controller**: Determine required phase shift (0° or 30°)
- **Frequency**: Confirm mains frequency (50 Hz or 60 Hz)
- **Gate Pulse Profile**: Select burst mode (30° dual or 120° single)
- **Auto-Balance**: Choose balance method (manual, on-board, external)

### Component Configuration for Applications

#### Converter Applications (30° Phase Shift)
**Component Settings**:
- **RN4**: 120 kΩ resistor network
- **C17-C22**: 0.033 μF film capacitors (5% tolerance)
- **Result**: 30° lagging phase shift for converter operation

**Verification**:
1. Connect oscilloscope to TP5 (reference comparator output)
2. Compare with line voltage waveform
3. Verify 30° lagging relationship

#### Controller Applications (0° Phase Shift)

**Option 1 - Capacitor Change**:
- **RN4**: 120 kΩ resistor network (unchanged)
- **C17-C22**: Change to 0.01 μF film capacitors
- **Result**: Approximately 0° phase shift

**Option 2 - Resistor Change** (Recommended):
- **RN4**: Change to 33 kΩ resistor network
- **C17-C22**: Keep 0.033 μF film capacitors
- **Advantage**: Same capacitors, only resistor network changes

**Verification**:
1. Connect oscilloscope to TP5
2. Compare with line voltage waveform  
3. Verify minimal phase shift (< 5°)

### Frequency Selection Configuration

#### 60 Hz Operation (Default)
**Component Settings**:
- **RN4**: 120 kΩ (converter) or 33 kΩ (controller)
- **C23**: 0.27 μF (matched ±1% with C29)
- **C29**: 0.27 μF (matched ±1% with C23)
- **J5 Jumper**: P5 on pins 1-2

**Verification**:
1. Check TP2 for 5.0 VDC reference
2. Verify proper gate pulse timing at 60 Hz

#### 50 Hz Operation
**Component Settings**:
- **RN4**: 150 kΩ (converter) or adjust proportionally (controller)
- **C23**: 0.33 μF (matched ±1% with C29)
- **C29**: 0.33 μF (matched ±1% with C23)
- **J5 Jumper**: Move P5 to pins 2-3

**Verification**:
1. Check TP2 maintains 5.0 VDC reference
2. Verify proper gate pulse timing at 50 Hz
3. Confirm phase relationships remain correct

---

## Auto-Balance System Configuration

### Manual Balance Setup

#### Component Configuration
- **Install**: R11 (25 kΩ trimpot)
- **Omit**: JU4, JU5, R48, R49, U12
- **Application**: Simple systems not requiring automatic balancing

#### Adjustment Procedure
1. **Initial Setup**: Set R11 to center position
2. **Current Monitoring**: Install current transformers on both bridge outputs
3. **Load Application**: Apply rated load to converter
4. **Balance Adjustment**: 
   - Monitor current in both bridges
   - Adjust R11 to equalize currents
   - Fine-tune for minimum current difference
5. **Verification**: Confirm balanced operation across load range

### On-Board Auto-Balance Setup

#### Component Configuration
- **Install**: U12 (MC14070BCP), R48 (10.0kΩ), R49 (10.0kΩ)
- **Omit**: R11, JU4, JU5
- **Application**: Automatic balancing without external control

#### Circuit Operation
The on-board auto-balance circuit:
1. **Current Sensing**: Monitors current difference between bridges
2. **Signal Generation**: Generates 6×fmains square wave (360 Hz at 60 Hz)
3. **Phase Modulation**: Injects square wave into VCO summing amplifier
4. **Automatic Correction**: 
   - Increases delay angle of high-current bridge
   - Decreases delay angle of low-current bridge
   - Continuously adjusts for optimal balance

#### Verification Procedure
1. **TP18 Monitoring**: Connect oscilloscope to TP18 (auto-balance output)
2. **Current Monitoring**: Install current transformers on both bridges
3. **Load Variation**: Vary load and observe automatic correction
4. **Balance Quality**: Verify current difference < 5% across load range

### External Auto-Balance Setup

#### Component Configuration
- **Install**: JU4, JU5, R48 (10.0kΩ)
- **Omit**: R11, R49, U12
- **Application**: Integration with external control systems

#### Interface Connections
- **J6 Pin 14**: High-frequency output from external auto-balance circuit
- **J6 Pin 15**: CK2 signal available for external circuit
- **J6 Pin 13**: CK2# (inverted) signal available for external circuit

#### External Circuit Requirements
1. **Input Signals**: Current feedback from both bridges
2. **Processing**: Calculate current difference and generate correction signal
3. **Output**: 6×fmains square wave to J6 pin 14
4. **Amplitude**: ±5V typical for full correction range

---

## Gate Pulse Profile Configuration

### Two 30° Burst Mode (Default)

#### Component Configuration
- **Install**: JU1 and JU2 jumpers
- **Result**: Two 30°-wide bursts per 180° period
- **Profile**: Initial hard-firing pulse + sustaining picket fence pulses

#### Applications
- **Normal Inductance Loads**: Standard motor drives, most converters
- **Advantages**: Reliable turn-on with minimal gate power
- **Waveform**: Two distinct 30° bursts separated by 60°

#### Verification
1. **Gate Output Monitoring**: Connect oscilloscope to gate outputs
2. **Timing Verification**: Confirm two 30° bursts per half-cycle
3. **Pulse Quality**: Verify hard-firing pulse followed by picket fence
4. **SCR Conduction**: Confirm reliable SCR turn-on

### Single 120° Burst Mode

#### Component Configuration
- **Omit**: JU1 and JU2 jumpers
- **Result**: Single 120°-wide burst per 180° period
- **Profile**: Initial hard-firing pulse + continuous picket fence

#### Applications
- **High Inductance Loads**: Large motors, high-power converters
- **Advantages**: Continuous gating for difficult turn-on conditions
- **Waveform**: Single continuous 120° burst

#### Verification
1. **Gate Output Monitoring**: Connect oscilloscope to gate outputs
2. **Timing Verification**: Confirm single 120° burst per half-cycle
3. **Pulse Quality**: Verify continuous picket fence throughout burst
4. **SCR Conduction**: Confirm reliable turn-on with high inductance

---

## System Commissioning Procedures

### Phase Reference Connection and Verification

#### High-Power Phase Reference Setup
1. **Safety First**: Ensure all high-voltage circuits are de-energized
2. **Connection Verification**: 
   - Connect six-phase references to appropriate terminals
   - Verify proper phase sequence (A-B-C, A-B-C with 30° shift)
   - Check insulation and wire routing
3. **Power-Up Sequence**:
   - Apply 24 VAC control power first
   - Verify LED indicators (PD3 green = power on)
   - Apply phase reference voltages
   - Monitor phase loss LED (PD1 should be OFF)

#### Phase Reference Verification
1. **Oscilloscope Setup**: Use isolated oscilloscope or differential probes
2. **Test Points**: Monitor TP3-TP6 for phase reference signals
3. **Waveform Verification**:
   - Confirm six distinct phases
   - Verify 60° spacing within each group
   - Confirm 30° shift between groups
   - Check amplitude and symmetry

### SIG HI Command Interface Setup

#### Voltage Command Configuration
1. **Range Verification**: Confirm R25 setting (249kΩ or 150kΩ)
2. **Input Impedance**: Verify R40 = 10.0kΩ
3. **Signal Source**: Connect control voltage source
4. **Calibration**:
   - Apply minimum command voltage
   - Verify minimum firing angle (typically 5°)
   - Apply maximum command voltage
   - Verify maximum firing angle (typically 165°)
   - Check linearity across range

#### Current Command Configuration
1. **R40 Selection**: Calculate and install appropriate R40 value
2. **Current Source**: Connect 4-20 mA current source
3. **Calibration**:
   - Apply 4 mA minimum current
   - Verify minimum firing angle
   - Apply 20 mA maximum current
   - Verify maximum firing angle
   - Check linearity and accuracy

### Gate Drive Interface Setup

#### Gate Circuit Connections
1. **Isolation Verification**: Confirm proper isolation between control and power
2. **Gate Resistor Check**: Verify gate current limiting resistors installed
3. **SCR Compatibility**: Confirm gate drive current adequate for SCR type
4. **Protection**: Verify overcurrent protection (fuses, circuit breakers)

#### Gate Drive Verification
1. **No-Load Testing**: Test gate outputs with SCRs disconnected
2. **Pulse Verification**:
   - Monitor gate pulse timing
   - Verify pulse amplitude and width
   - Check pulse spacing (30° for FCOG1200, 60° for FCOG6100)
3. **Load Testing**: Connect SCRs and verify proper firing

---

## Operational Verification Procedures

### Phase Loss Detection Testing

#### Simulated Phase Loss Test
1. **Setup**: Normal operation with balanced three-phase input
2. **Baseline**: Verify PD1 (Phase Loss LED) is OFF
3. **Phase Loss Simulation**: 
   - Disconnect one phase reference
   - Verify immediate PD1 LED ON
   - Confirm gate pulse inhibition
4. **Recovery Test**:
   - Reconnect phase reference
   - Verify PD1 LED OFF
   - Confirm soft-start operation
   - Verify normal operation restored

#### Phase Imbalance Testing
1. **Voltage Imbalance**: Create 10% voltage imbalance
2. **Threshold Testing**: Gradually increase imbalance
3. **Trip Point**: Determine phase loss trip threshold
4. **Recovery**: Verify proper recovery when balance restored

### Auto-Balance System Testing (FCOG1200)

#### Manual Balance Verification
1. **Current Monitoring**: Install current transformers on both bridges
2. **Load Application**: Apply varying loads
3. **Balance Adjustment**: Adjust R11 for current equalization
4. **Performance**: Verify balance maintained across load range

#### On-Board Auto-Balance Verification
1. **Automatic Operation**: Apply load and observe automatic balancing
2. **Response Time**: Measure time to achieve balance
3. **Stability**: Verify no oscillation or hunting
4. **Load Variation**: Test response to load changes

### Performance Verification

#### Firing Angle Accuracy
1. **Calibrated Input**: Apply known SIG HI voltages
2. **Angle Measurement**: Measure actual firing angles
3. **Linearity Check**: Verify linear relationship
4. **Accuracy**: Confirm ±1° accuracy specification

#### Frequency Response
1. **Step Response**: Apply step changes to SIG HI
2. **Settling Time**: Measure time to reach final value
3. **Overshoot**: Verify no excessive overshoot
4. **Stability**: Confirm stable operation

---

## Troubleshooting Procedures

### No Gate Pulses

#### Systematic Diagnosis
1. **Power Supply Check**:
   - Verify 24 VAC input present
   - Check +12V, +5V, +30V outputs
   - Confirm LED indicators
2. **Phase Reference Check**:
   - Verify phase reference voltages present
   - Check phase loss LED status
   - Monitor TP15, TP16 for phase summing signals
3. **SIG HI Check**:
   - Verify SIG HI voltage within range
   - Check TP7 for buffered signal
   - Confirm input impedance

### Erratic Operation

#### Common Causes and Solutions
1. **Phase Reference Noise**:
   - Check for harmonic distortion
   - Verify proper grounding
   - Consider additional filtering
2. **SIG HI Noise**:
   - Use shielded cable
   - Check ground loops
   - Install C31 if needed
3. **Power Supply Issues**:
   - Check regulation under load
   - Verify adequate VA rating
   - Check for voltage transients

### Auto-Balance Problems

#### Balance Circuit Diagnosis
1. **Configuration Check**: Verify correct component installation
2. **Signal Monitoring**: Check TP18 for auto-balance signal
3. **Current Feedback**: Verify current sensing circuits
4. **Load Conditions**: Confirm adequate load for balance operation

---

## Maintenance Procedures

### Routine Maintenance

#### Visual Inspection
- **Component Condition**: Check for overheating, discoloration
- **Connector Integrity**: Verify tight connections
- **PCB Condition**: Check for cracks, corrosion
- **LED Status**: Confirm proper indicator operation

#### Electrical Testing
- **Power Supply Voltages**: Verify regulation within specifications
- **Gate Pulse Quality**: Check pulse amplitude and timing
- **Phase Reference**: Verify proper phase relationships
- **Auto-Balance**: Test balance circuit operation

### Preventive Maintenance

#### Component Replacement Schedule
- **Electrolytic Capacitors**: Replace every 5-10 years
- **Trimpots**: Replace if adjustment range limited
- **Connectors**: Clean and inspect annually
- **Fuses**: Replace if blown, investigate cause

#### Calibration Verification
- **Firing Angle Accuracy**: Annual calibration check
- **Phase Relationships**: Verify proper timing
- **Auto-Balance**: Test balance performance
- **Protection Circuits**: Verify phase loss detection

### Documentation and Records

#### Maintenance Log
- **Date and Time**: Record all maintenance activities
- **Measurements**: Document voltage and timing measurements
- **Component Changes**: Record all component replacements
- **Performance**: Note any performance changes

#### Configuration Record
- **Component Settings**: Document all jumper and component settings
- **Calibration Data**: Record calibration values and dates
- **Modifications**: Document any field modifications
- **Troubleshooting**: Record problems and solutions
