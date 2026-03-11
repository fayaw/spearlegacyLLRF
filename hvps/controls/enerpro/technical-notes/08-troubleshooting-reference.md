# 08 — Troubleshooting & Maintenance Reference

> **Sources**: `OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.pdf`, `OP-0102_FCOG6100_Op_Manual.pdf`, `E640_L FCOG1200 Schematic (03-01-21).pdf`, `E128_R_Schematic_11-14.pdf`, `FCOG1200 Auto Balance.pdf`

## Test Points and Signal Monitoring

### Oscilloscope Test Points

| Test Point | Signal Description | Normal Waveform | Troubleshooting Use |
|------------|-------------------|------------------|---------------------|
| **TP1** | Buffer amplifier output | Clean DC level | SIG HI signal verification |
| **TP2** | 5.0 VDC reference | Stable 5.0V DC | Power supply regulation check |
| **TP3** | Phase Ax reference | Square wave at zero crossing | Phase reference timing |
| **TP4** | Phase Bx reference | Square wave, 60° from TP3 | Phase sequence verification |
| **TP5** | Phase Cx reference | Square wave, 120° from TP3 | Phase reference completeness |
| **TP6** | Phase Ay reference | Square wave, 30° shift from TP3 | 30° phase shift verification |
| **TP7** | SIG HI buffered | Follows input command | Input signal integrity |
| **TP8-TP13** | Gate drive signals | High-current pulses | Gate output verification |
| **TP14** | Auto-balance signal | Modulated signal | Balance circuit operation |
| **TP15** | X phase summing | Sinusoidal, balanced amplitude | Phase loss detection |
| **TP16** | Y phase summing | Sinusoidal, balanced amplitude | Phase loss detection |
| **TP18** | Auto-balance output | 6×fmains square wave | Auto-balance monitoring |

### LED Status Indicators

| LED | Color | Normal State | Fault Indication | Troubleshooting Action |
|-----|-------|--------------|------------------|------------------------|
| **PD1** | Red | OFF | ON = Phase Loss | Check phase reference voltages |
| **PD2** | Red | OFF | ON = Inhibit Active | Check enable signals and faults |
| **PD3** | Green | ON | OFF = No Power | Check 24VAC input and power supply |

---

## Common Fault Conditions and Solutions

### No Gate Pulses Output

#### Symptom
- No output pulses on any gate drive channel
- SCRs do not fire
- System remains in off state

#### Systematic Diagnosis

**Step 1: Power Supply Check**
1. **24VAC Input**: Verify 24VAC present at input terminals
2. **DC Voltages**: Check +30V, +12V, +5V outputs
3. **LED Status**: Verify PD3 (green) is ON
4. **Fuses**: Check any input fuses or circuit breakers

**Step 2: Phase Reference Check**
1. **Phase Voltages**: Verify six-phase voltages present
2. **Phase Loss LED**: Check PD1 status (should be OFF)
3. **Test Points**: Monitor TP15, TP16 for phase summing signals
4. **Reference Waveforms**: Check TP3-TP6 for square wave outputs

**Step 3: Control Signal Check**
1. **SIG HI Voltage**: Verify command signal within range (0.9-5.9V)
2. **TP7 Monitoring**: Check buffered SIG HI signal
3. **Input Impedance**: Verify 10kΩ input impedance (R40)
4. **Signal Source**: Check control signal source operation

**Step 4: Enable Signal Check**
1. **I1#, I2# Signals**: Verify enable signals present
2. **Inhibit Status**: Check PD2 LED (should be OFF)
3. **External Interlocks**: Verify no external inhibit signals

#### Common Solutions
- **Power Supply**: Replace blown fuses, check 24VAC source
- **Phase Loss**: Restore missing phase references
- **SIG HI**: Verify control signal source and wiring
- **Enable Signals**: Check interlock circuits and enable logic

### Erratic Gate Pulse Timing

#### Symptom
- Irregular firing angles
- Inconsistent SCR conduction
- Variable output voltage

#### Diagnosis Procedure

**Step 1: Phase Reference Quality**
1. **Harmonic Distortion**: Check for distorted phase reference waveforms
2. **Noise**: Look for electrical noise on reference signals
3. **Grounding**: Verify proper grounding of reference circuits
4. **Filtering**: Check phase reference filter components (C17-C22)

**Step 2: SIG HI Signal Quality**
1. **Noise**: Check for noise on SIG HI command signal
2. **Ground Loops**: Verify single-point grounding
3. **Cable Shielding**: Use shielded cable for long SIG HI runs
4. **Bandwidth Limiting**: Consider installing C31 for noise reduction

**Step 3: Power Supply Stability**
1. **Regulation**: Check voltage regulation under load
2. **Ripple**: Measure ripple on DC supply voltages
3. **Transients**: Look for voltage transients during operation
4. **Loading**: Verify adequate VA rating for load

#### Solutions
- **Filtering**: Add additional filtering to noisy signals
- **Grounding**: Improve ground system design
- **Shielding**: Use proper cable shielding and routing
- **Power Supply**: Upgrade to higher capacity or better regulated supply

### Phase Loss False Trips

#### Symptom
- PD1 LED turns ON intermittently
- Gate pulses inhibited during normal operation
- System shuts down unexpectedly

#### Diagnosis Steps

**Step 1: Threshold Analysis**
1. **TP15, TP16 Monitoring**: Check phase summing signal amplitudes
2. **Threshold Levels**: Verify thresholds at U6 pins 9, 10
3. **Margin Analysis**: Determine margin above trip threshold
4. **Load Dependency**: Check if trips occur at specific load levels

**Step 2: Signal Quality Check**
1. **Harmonic Content**: Analyze harmonic distortion in phase references
2. **Transients**: Look for voltage transients causing false trips
3. **Imbalance**: Check for actual phase voltage imbalance
4. **Hysteresis**: Verify comparator hysteresis (C33-C38 in Rev K+)

#### Solutions
- **Threshold Adjustment**: Adjust phase loss thresholds if possible
- **Hysteresis**: Add hysteresis capacitors (C33-C38) if not present
- **Filtering**: Improve phase reference filtering
- **Power Quality**: Address power system quality issues

### Auto-Balance System Problems

#### Poor Current Balance

**Symptoms**:
- Bridge currents differ by >5%
- High harmonic content in output
- Visible ripple on DC output

**Diagnosis**:
1. **Configuration Check**: Verify correct auto-balance configuration
2. **Current Sensing**: Check current transformer accuracy and connections
3. **TP18 Monitoring**: Verify auto-balance signal present
4. **Load Conditions**: Ensure adequate load for balance operation

**Solutions**:
- **Reconfigure**: Verify component installation per configuration
- **CT Calibration**: Check and calibrate current transformers
- **Signal Path**: Verify auto-balance signal path integrity
- **Load Increase**: Ensure minimum load for balance circuit operation

#### Auto-Balance Oscillation

**Symptoms**:
- Hunting or oscillation in bridge currents
- Unstable operation
- Audible noise from converter

**Diagnosis**:
1. **Loop Gain**: Check auto-balance loop gain settings
2. **Stability**: Analyze loop stability margins
3. **Noise**: Check for noise in current feedback signals
4. **Component Values**: Verify R48, R49, R50, R51 values

**Solutions**:
- **Gain Reduction**: Reduce loop gain (increase R48, R49 values)
- **Filtering**: Add filtering to current feedback signals
- **Damping**: Add damping to reduce oscillation tendency
- **Component Check**: Replace any out-of-tolerance components

---

## Waveform Analysis and Verification

### Normal Operating Waveforms

#### Phase Reference Waveforms (TP3-TP6)
**Normal Characteristics**:
- **Amplitude**: Logic level square waves (0V to +5V)
- **Frequency**: 50 Hz or 60 Hz matching mains
- **Phase Relationships**: 60° spacing within groups, 30° between groups
- **Duty Cycle**: Approximately 50% duty cycle
- **Rise/Fall Times**: Clean transitions without ringing

**Abnormal Indications**:
- **Distorted Waveforms**: Indicates harmonic distortion in phase references
- **Missing Pulses**: Phase reference circuit failure
- **Wrong Timing**: Incorrect phase relationships
- **Noise**: Electrical interference in reference circuits

#### Gate Output Waveforms (TP8-TP13)
**Normal Characteristics**:
- **Pulse Spacing**: 30° for FCOG1200, 60° for FCOG6100
- **Pulse Width**: 30° bursts or 120° continuous per configuration
- **Amplitude**: High current capability for reliable SCR triggering
- **Timing**: Precise timing relative to phase references

**Abnormal Indications**:
- **Missing Pulses**: Gate drive circuit failure
- **Wrong Timing**: Firing circuit malfunction
- **Low Amplitude**: Insufficient gate drive current
- **Irregular Spacing**: ASIC or timing circuit problems

#### Auto-Balance Waveforms (TP18)
**Normal Characteristics**:
- **Frequency**: 6×fmains (360 Hz at 60 Hz, 300 Hz at 50 Hz)
- **Amplitude**: Variable based on current imbalance
- **Waveform**: Square wave modulation
- **Response**: Changes with load and current imbalance

**Abnormal Indications**:
- **No Signal**: Auto-balance circuit not functioning
- **Wrong Frequency**: Timing circuit problems
- **Excessive Amplitude**: Loop instability or oscillation
- **No Response**: Current sensing or feedback problems

### Measurement Techniques

#### Oscilloscope Setup
1. **Isolation**: Use isolated oscilloscope or differential probes
2. **Grounding**: Establish proper ground reference
3. **Bandwidth**: Adequate bandwidth for pulse measurements
4. **Triggering**: Stable triggering on mains frequency

#### Timing Measurements
1. **Phase Relationships**: Measure phase angles between signals
2. **Pulse Width**: Measure gate pulse durations
3. **Frequency**: Verify all frequencies match specifications
4. **Jitter**: Check for timing jitter or instability

---

## Component Testing and Replacement

### Critical Component Testing

#### Custom ASICs (U3, U4, U5)
**Testing Method**:
- **Functional Test**: Verify proper gate pulse generation
- **Supply Voltages**: Check +5V supply to ASICs
- **Input Signals**: Verify proper input signals present
- **Output Verification**: Check all ASIC outputs

**Replacement Considerations**:
- **Exact Part Numbers**: Must use exact Enerpro part numbers
- **Programming**: ASICs may require factory programming
- **Availability**: Contact Enerpro for replacement parts
- **Board Replacement**: May require complete board replacement

#### Voltage Regulator (U2)
**Testing Method**:
1. **Input Voltage**: Verify proper input from bridge rectifier
2. **Output Voltage**: Check +12V output regulation
3. **Load Test**: Test regulation under load
4. **Temperature**: Check operation over temperature range

**Replacement Procedure**:
1. **Power Off**: Ensure all power removed
2. **Heat Sink**: Remove heat sink if present (TO-220 package)
3. **Desoldering**: Carefully desolder old regulator
4. **Installation**: Install new regulator with proper orientation
5. **Testing**: Verify proper operation before full power-up

#### Precision Resistors (R25, R40, R47)
**Testing Method**:
- **Resistance Measurement**: Use precision ohmmeter
- **Tolerance Check**: Verify within specified tolerance
- **Temperature Coefficient**: Check stability over temperature
- **Power Rating**: Verify adequate power rating for application

**Replacement Guidelines**:
- **Precision**: Use 1% tolerance or better
- **Temperature Coefficient**: ±50 ppm/°C or better
- **Power Rating**: Adequate for application (typically 1/4W)
- **Type**: Metal film resistors preferred

### Electrolytic Capacitor Replacement

#### Power Supply Capacitors (C1, C2, C3, C5, C6)
**Failure Symptoms**:
- **Increased Ripple**: Higher ripple on DC voltages
- **Poor Regulation**: Voltage regulation degraded
- **Physical Signs**: Bulging, leakage, or discoloration
- **ESR Increase**: Increased equivalent series resistance

**Replacement Procedure**:
1. **Discharge**: Safely discharge all capacitors
2. **Removal**: Carefully remove old capacitors
3. **Cleaning**: Clean PCB of any electrolyte residue
4. **Installation**: Install new capacitors with correct polarity
5. **Testing**: Verify proper operation and ripple levels

**Specifications**:
- **Voltage Rating**: At least 25% above operating voltage
- **Temperature Rating**: 105°C minimum for reliability
- **ESR**: Low ESR types preferred for switching applications
- **Lifetime**: High-reliability, long-life types

### Connector Maintenance

#### Gate/Cathode Connectors (J1-J4)
**Inspection Points**:
- **Contact Condition**: Check for corrosion or burning
- **Mechanical Integrity**: Verify secure mating
- **Keying**: Ensure keying prevents incorrect connection
- **Wire Condition**: Check connected wires for damage

**Maintenance Procedure**:
1. **Power Off**: Ensure all power removed
2. **Disconnection**: Carefully disconnect all connectors
3. **Cleaning**: Clean contacts with appropriate contact cleaner
4. **Inspection**: Inspect for damage or wear
5. **Replacement**: Replace if damaged or worn
6. **Reconnection**: Reconnect with proper torque

---

## Preventive Maintenance Schedule

### Monthly Inspections

#### Visual Inspection
- **LED Status**: Check all LED indicators for proper operation
- **Connector Security**: Verify all connectors properly seated
- **Component Condition**: Look for signs of overheating or damage
- **PCB Condition**: Check for cracks, corrosion, or contamination

#### Electrical Checks
- **Supply Voltages**: Verify +30V, +12V, +5V within specifications
- **Gate Pulse Quality**: Check gate pulse amplitude and timing
- **Phase Reference**: Verify proper phase reference signals
- **Current Balance**: Check bridge current balance (if applicable)

### Quarterly Maintenance

#### Performance Verification
- **Firing Angle Accuracy**: Verify firing angle vs. command signal
- **Phase Relationships**: Check all phase timing relationships
- **Auto-Balance**: Test auto-balance system operation
- **Protection Circuits**: Test phase loss detection

#### Component Testing
- **Electrolytic Capacitors**: Check ESR and capacitance values
- **Precision Resistors**: Verify resistance values within tolerance
- **Connectors**: Clean and inspect all connectors
- **Test Points**: Verify accessibility and condition

### Annual Maintenance

#### Comprehensive Testing
- **Full Functional Test**: Complete system checkout
- **Calibration Verification**: Verify all calibrations current
- **Harmonic Analysis**: Measure harmonic content and THD
- **Temperature Testing**: Verify operation over temperature range

#### Documentation Update
- **Maintenance Records**: Update all maintenance records
- **Configuration Documentation**: Verify configuration documentation current
- **Performance Trends**: Analyze performance trends over time
- **Spare Parts**: Update spare parts inventory

---

## Troubleshooting Tools and Equipment

### Essential Test Equipment

#### Oscilloscope
**Requirements**:
- **Bandwidth**: Minimum 100 MHz for pulse measurements
- **Channels**: 4-channel minimum for multi-phase measurements
- **Isolation**: Isolated inputs or differential probes required
- **Storage**: Digital storage for waveform analysis

#### Multimeter
**Requirements**:
- **Accuracy**: 0.1% or better for precision measurements
- **AC/DC**: True RMS for AC measurements
- **Frequency**: Frequency measurement capability
- **Safety**: CAT III rating for industrial use

#### Current Measurement
**Requirements**:
- **Current Transformers**: Precision CTs for current balance measurement
- **AC Current Meters**: True RMS meters for accurate AC current
- **Clamp Meters**: For non-intrusive current measurement
- **Power Analyzer**: For harmonic analysis and power quality

### Specialized Equipment

#### Harmonic Analyzer
**Applications**:
- **THD Measurement**: Total harmonic distortion analysis
- **Individual Harmonics**: Measurement of specific harmonic components
- **Power Quality**: Overall power quality assessment
- **Compliance**: Verification of harmonic standards compliance

#### Function Generator
**Applications**:
- **Test Signals**: Generation of test phase reference signals
- **SIG HI Testing**: Variable command signal generation
- **Frequency Testing**: 50/60 Hz testing capability
- **Waveform Generation**: Various waveform types for testing

### Safety Equipment

#### Personal Protective Equipment
- **Safety Glasses**: Eye protection required
- **Insulated Gloves**: Electrical protection
- **Arc Flash Protection**: Appropriate for voltage levels
- **Safety Shoes**: Electrical hazard protection

#### Test Equipment Safety
- **Isolation**: Proper isolation for high-voltage measurements
- **Grounding**: Proper grounding of test equipment
- **Lockout/Tagout**: Energy isolation procedures
- **Emergency Procedures**: Emergency shutdown procedures

---

## Documentation and Record Keeping

### Maintenance Records

#### Required Documentation
- **Maintenance Log**: Date, time, and description of all maintenance
- **Test Results**: Record all test measurements and results
- **Component Replacements**: Log all component changes with part numbers
- **Configuration Changes**: Document any configuration modifications

#### Performance Tracking
- **Trend Analysis**: Track performance parameters over time
- **Failure Analysis**: Document and analyze any failures
- **Improvement Opportunities**: Identify potential improvements
- **Spare Parts Usage**: Track spare parts consumption

### Troubleshooting Database

#### Problem Documentation
- **Symptom Description**: Clear description of observed problems
- **Diagnosis Steps**: Document diagnostic procedures used
- **Root Cause**: Identify root cause of problems
- **Solution**: Document effective solutions

#### Knowledge Base
- **Common Problems**: Database of frequently encountered issues
- **Solutions**: Proven solutions for common problems
- **Lessons Learned**: Document lessons learned from troubleshooting
- **Best Practices**: Develop and document best practices

### Configuration Management

#### As-Built Documentation
- **Component Lists**: Current component installation
- **Jumper Settings**: All jumper and switch positions
- **Calibration Data**: Current calibration values and dates
- **Modifications**: Any field modifications or changes

#### Change Control
- **Change Authorization**: Proper authorization for changes
- **Change Documentation**: Complete documentation of changes
- **Testing**: Verification testing after changes
- **Update Records**: Update all affected documentation
