# 06 — Control Theory & Algorithms

> **Sources**: `bourbeauIEEE1983_04504257.pdf`, `PHASE CONTROL THEORY.PDF`, `OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.pdf`, `Closing the Loop.pdf`, `FCOG1200 Auto Balance.pdf`, `enerproBoardHvps.docx`

## Phase-Locked Loop (PLL) Fundamentals

The Enerpro firing boards utilize a sophisticated phase-locked loop architecture to achieve frequency-independent delay angle control. This approach provides significant advantages over traditional RC delay circuits.

### PLL Architecture Overview

#### Basic PLL Components
1. **Phase Detector**: Compares input phase references with VCO output
2. **Loop Filter**: Smooths phase detector output and sets loop dynamics
3. **Voltage-Controlled Oscillator (VCO)**: Generates timing signals
4. **Frequency Divider**: Divides VCO output to match input frequency
5. **Digital Countdown**: Provides precise firing pulse timing

#### Signal Flow
```
Phase References → Phase Detector → Loop Filter → VCO → 
Frequency Divider → Digital Countdown → Gate Pulses
                ↑                                    ↓
                ←─── Feedback Path ──────────────────
```

### Mathematical Analysis (From IEEE Paper - Bourbeau 1983)

#### Delay Angle Equation
The steady-state delay angle is given by:
```
α = α₀ + (E/12) × R3/(R1+R2) × 180°
```

Where:
- **α₀** = minimum delay angle = 30R3/(R6 × Vdd) × 180°
- **E** = control voltage (SIG HI)
- **R1, R2** = summing amplifier input resistors
- **R3** = feedback resistor
- **R6** = bias resistor
- **Vdd** = supply voltage

#### Key Advantages
- **Frequency Independence**: Delay angle independent of mains frequency
- **Temperature Stability**: No RC drift with temperature
- **Precision**: Resistance ratios determine accuracy, not absolute values
- **Automatic Adaptation**: Self-adjusting to phase sequence changes

### VCO and Timing Generation

#### VCO Specifications
- **Free-Running Frequency**: 384 × 60 Hz = 23,040 Hz (at 60 Hz mains)
- **Control Voltage Range**: Vdd/2 ± 5V (typically 6.0 ± 5V)
- **Timing Components**: R8 and C4 set nominal frequency
- **Modulation**: 360 Hz ripple from 6-pulse rectification

#### Digital Countdown Operation
- **Input Frequency**: 23,040 Hz from VCO
- **Division Ratio**: Programmable based on desired pulse spacing
- **Output Timing**: Precise gate pulse generation
- **Synchronization**: Locked to AC mains zero crossings

---

## Transfer Function Analysis

### Loop Filter Design

#### Amplifier-Filter Configuration
The summing amplifier presents an input impedance:
```
Zin = (R1 + R2)(sT2 + 1) / (sT1 + 1)
```

Where:
- **T1** = R1 × C1
- **T2** = R1 × R2 × C1 / (R1 + R2)

#### Feedback Impedance
The feedback path consists of:
```
Zfb = 1 / (sC2) || [R7 + 1/(sC3)]
```

Where:
- **C2** = integrating capacitor
- **R7** = feedback resistor
- **C3** = ripple filter capacitor

### Frequency Response Characteristics

#### Measured Performance (60 Hz System)
From IEEE paper analysis:
- **Gain Peak**: 0.81 dB at 60 rad/s
- **-3dB Frequency**: 415 rad/s
- **Phase Margin**: -45° at 339 rad/s
- **DC Gain**: Unity (0 dB)

#### Stability Analysis
- **Phase Margin**: Adequate for stable operation
- **Gain Margin**: Sufficient for load variations
- **Bandwidth**: Appropriate for power conversion applications
- **Settling Time**: 2-3 AC cycles for step changes

### Transient Response

#### Step Response Characteristics
From regenerative converter testing:
- **Inverting to Rectifying**: ~3.5 ms (2 × 1/6 cycle pulses)
- **Rectifying to Inverting**: ~5.0 ms
- **Instantaneous Gating Frequency**: ~110 Hz during transition
- **Overshoot**: Minimal with proper compensation

#### Compensation Effects
- **With Lead-Lag Compensation (C1)**: Faster response, controlled overshoot
- **Without Compensation**: Slower response (~8.0 ms), potential oscillation
- **Optimal Design**: Balance between speed and stability

---

## Thyristor Firing Theory

### Phase Control Principles

#### Delay Angle Control
The firing angle α determines the conduction angle of the thyristor:
- **α = 0°**: Maximum conduction (full output)
- **α = 90°**: 50% average output (resistive load)
- **α = 180°**: Minimum conduction (near zero output)

#### Output Voltage Relationship
For a resistive load:
```
Vavg = (Vm/π) × [1 + cos(α)]
```

Where:
- **Vavg** = average output voltage
- **Vm** = peak input voltage
- **α** = firing delay angle

### 12-Pulse Rectification Theory

#### Harmonic Elimination
12-pulse rectification eliminates specific harmonics:
- **5th Harmonic**: Virtually eliminated
- **7th Harmonic**: Virtually eliminated
- **Remaining Harmonics**: 11th, 13th, 23rd, 25th, etc.
- **THD Reduction**: Significant improvement over 6-pulse

#### Mathematical Basis
The 30° phase shift between bridge groups creates:
- **Harmonic Cancellation**: 5th and 7th harmonics cancel
- **Ripple Frequency**: 12 × fline (720 Hz at 60 Hz)
- **Ripple Amplitude**: Reduced by factor of 2

#### Current Balancing Requirements
For optimal harmonic cancellation:
- **Bridge Currents**: Must be equal within ±5%
- **Phase Shift**: Must be exactly 30° ± 1°
- **Voltage Balance**: Bridge voltages must be matched

---

## Auto-Balance Control Theory

### Current Balancing Principle

#### Problem Statement
In parallel 12-pulse converters:
- **Transformer Imperfections**: Unequal leakage inductances
- **Voltage Unbalance**: Small open-circuit voltage differences
- **Phase Shift Errors**: Deviation from ideal 30° shift
- **Result**: Unequal bridge currents, harmonic content

#### Auto-Balance Solution
The auto-balance circuit:
1. **Monitors**: Current difference between bridges
2. **Generates**: Correction signal at 6 × fmains
3. **Modulates**: VCO control voltage
4. **Adjusts**: Firing angles to equalize currents

### Control Algorithm

#### Signal Processing
```
Current Difference → Error Amplifier → 6×fmains Modulator → 
VCO Summing Point → Phase Angle Adjustment
```

#### Mathematical Relationship
- **High Current Bridge**: α_high = α_nominal + Δα
- **Low Current Bridge**: α_low = α_nominal - Δα
- **Correction**: Δα proportional to current difference
- **Frequency**: 6 × fmains for optimal response

#### Stability Considerations
- **Loop Gain**: Set for stable operation without oscillation
- **Response Time**: Fast enough for load changes, slow enough for stability
- **Load Range**: Effective over full load range
- **Disturbance Rejection**: Immune to line voltage variations

---

## Advanced Control Features

### Phase Loss Detection Algorithm

#### Detection Method
The phase loss circuit uses vector summation:
1. **X Vector**: Sum of phases A, B, C (first group)
2. **Y Vector**: Sum of phases A, B, C (second group, 30° shifted)
3. **Magnitude Check**: Both vectors must exceed minimum threshold
4. **Balance Check**: Vector magnitudes must be approximately equal

#### Mathematical Analysis
For balanced three-phase:
- **Vector Sum**: Ideally zero for balanced system
- **Unbalanced System**: Non-zero vector indicates imbalance
- **Threshold Setting**: Set above noise but below minimum acceptable imbalance

#### Response Characteristics
- **Detection Time**: Instantaneous (within one AC cycle)
- **Recovery**: Soft-start prevents output transients
- **Sensitivity**: Adjustable via threshold settings
- **False Trip Immunity**: Hysteresis prevents noise-induced trips

### Soft-Start/Soft-Stop Control

#### Soft-Start Operation
1. **Initial State**: Firing angle set to maximum (minimum output)
2. **Ramp Rate**: Gradual decrease in firing angle
3. **Final Value**: Reaches commanded firing angle
4. **Time Constant**: Adjustable via R36 (soft-start time)

#### Soft-Stop Operation
1. **Stop Command**: Initiated by control signal or fault
2. **Ramp Rate**: Gradual increase in firing angle
3. **Final State**: Maximum firing angle (minimum output)
4. **Time Constant**: Adjustable via R28 (soft-stop time)

#### Benefits
- **Inrush Current Limitation**: Prevents excessive startup currents
- **Mechanical Stress Reduction**: Gradual torque buildup in motor drives
- **System Protection**: Controlled shutdown during faults
- **Load Protection**: Prevents sudden load changes

---

## Frequency Adaptation

### 50/60 Hz Operation

#### Component Scaling
For different frequencies, timing components scale proportionally:
- **60 Hz**: RN4 = 120 kΩ, C23/C29 = 0.27 μF
- **50 Hz**: RN4 = 150 kΩ, C23/C29 = 0.33 μF
- **Scaling Factor**: 60/50 = 1.2

#### VCO Frequency Scaling
- **60 Hz**: 384 × 60 = 23,040 Hz
- **50 Hz**: 384 × 50 = 19,200 Hz
- **Pulse Width**: Maintains constant pulse width in degrees
- **Timing Accuracy**: Preserved across frequency range

### Automatic Frequency Tracking

#### PLL Frequency Lock
The PLL automatically tracks mains frequency variations:
- **Lock Range**: Typically ±5% of nominal frequency
- **Lock Time**: 2-3 AC cycles for frequency steps
- **Accuracy**: Maintains timing accuracy over frequency range
- **Stability**: Stable operation over industrial frequency variations

---

## Performance Optimization

### Loop Compensation Design

#### Design Objectives
- **Stability**: Adequate phase and gain margins
- **Speed**: Fast response to command changes
- **Accuracy**: Minimal steady-state error
- **Disturbance Rejection**: Immunity to line voltage variations

#### Component Selection
- **C1**: Lead-lag compensation capacitor
- **R1, R2**: Input resistor ratio sets gain
- **R3**: Feedback resistor sets span
- **C2**: Integration time constant

#### Tuning Procedure
1. **Open Loop**: Measure open-loop response
2. **Compensation**: Add lead-lag compensation as needed
3. **Closed Loop**: Verify closed-loop stability
4. **Performance**: Optimize for application requirements

### Noise Immunity Enhancement

#### Input Filtering
- **SIG HI**: Optional C31 for bandwidth limiting
- **Phase References**: RC filtering for harmonic rejection
- **Power Supply**: Multiple filter stages

#### Ground System Design
- **Single Point Ground**: Minimize ground loops
- **Ground Plane**: Solid ground plane for EMI reduction
- **Isolation**: High-voltage isolation between control and power

#### Component Selection
- **Precision Resistors**: Low noise, stable values
- **Film Capacitors**: Low dielectric absorption
- **Op-Amps**: Low noise, high CMRR
- **Comparators**: Hysteresis for noise immunity

---

## System Integration Considerations

### Control System Interface

#### Command Signal Characteristics
- **Bandwidth**: Match to control system capabilities
- **Resolution**: Adequate for application requirements
- **Noise Immunity**: Robust to industrial environment
- **Isolation**: Electrical isolation for safety

#### Feedback Signals
- **Status Outputs**: Phase loss, ready, fault indications
- **Analog Outputs**: Firing angle feedback, current balance
- **Digital Outputs**: Gate pulse confirmation, timing signals

### Protection System Integration

#### Fault Detection
- **Phase Loss**: Immediate detection and response
- **Overcurrent**: Integration with external protection
- **Overvoltage**: Coordination with system protection
- **Emergency Stop**: Fast response to emergency conditions

#### Fault Response
- **Immediate**: Gate pulse inhibition
- **Controlled**: Soft-stop for non-critical faults
- **Recovery**: Automatic restart after fault clearance
- **Indication**: Clear fault indication and logging

### Performance Monitoring

#### Key Parameters
- **Firing Angle Accuracy**: ±1° over operating range
- **Current Balance**: ±5% between bridges (12-pulse)
- **Harmonic Content**: THD < 5% typical
- **Response Time**: 2-3 cycles for step changes

#### Diagnostic Capabilities
- **Test Points**: Accessible for oscilloscope monitoring
- **LED Indicators**: Visual status indication
- **Signal Access**: Key signals available for monitoring
- **Waveform Documentation**: Reference waveforms for comparison
