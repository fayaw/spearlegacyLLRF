# SPEAR3 Low-Level RF Feedback Loops
## Comprehensive Technical Description
### Block Diagram #1 — ON_CW Operating Mode with Direct Loop Enabled
Date: 3/20/2026

source:  From (feedbackLoopDescriptionps3403305200.pdf)

---

## 1. Overview and Purpose

This document describes the complete Low-Level RF (LLRF) feedback control system for the PEPII RF station, operating in the **ON_CW** (continuous wave) mode with the **Direct Loop** engaged. The LLRF system controls the amplitude and phase of the RF field inside the accelerating cavities by modulating a 476 MHz reference signal before it drives the high-power klystron amplifier chain.

The system implements **eight distinct feedback and feedforward loops**, each operating at a different bandwidth and serving a different control purpose:

| Loop Name | Bandwidth | Function |
|---|---|---|
| LFB Woofer | 1 MHz | Longitudinal multibunch feedback injection |
| Comb Loop | 2 MHz | Multi-bunch instability suppression |
| Direct Loop | 800 kHz | Primary cavity field (amplitude + phase) control |
| Ripple Loop | 300 Hz | Power-supply ripple rejection |
| Gap FF Loop | 100 Hz | Gap voltage feedforward correction |
| HVPS Loop | 1 Hz | Klystron operating point (drive power) control |
| Tuner Loop | 1 Hz | Cavity mechanical resonance frequency control |
| DAC Loop | 0.1 Hz | Long-term DC drift correction (station gap voltage) |

Together these loops span more than **7 decades of frequency** (0.1 Hz to 2 MHz), each targeting a different disturbance source that would otherwise degrade the amplitude and phase stability of the accelerating voltage seen by the beam.

---

## 2. Main Forward Signal Path

The primary RF signal path flows left-to-right across the top of the block diagram:

```
476 MHz Reference
      ↓
I/Q Modulator  →  Drive Amplifier  →  Klystron  →  Cavity
```

### 2.1 476 MHz Reference

The system reference frequency for PEPII RF. The nominal frequency to four significant digits is **476 MHz** (SPEAR3 476.3 Mhz, current measured value: 476.3051755 MHz ~ 20 kHz range for synchronization). All I/Q detection and modulation is performed relative to this reference.

### 2.2 I/Q Modulator

The 476 MHz reference signal enters an **I/Q (in-phase / quadrature) modulator**. This device independently adjusts the amplitude and phase of the RF signal by varying the I and Q components of the baseband drive signal fed to it from the feedback network. It is the **single actuator** through which all RF field feedback loops (Direct, Comb, Ripple, Gap FF, DAC, LFB Woofer) act on the RF drive signal.

### 2.3 Drive Amplifier

A solid-state or intermediate-power amplifier that boosts the modulated signal from milliwatt-level to the tens-of-watts level (~29 W measured for SPEAR3) needed to drive the klystron input. Shown as a triangle (standard amplifier symbol) in the diagram.

### 2.4 Klystron

The high-power RF amplifier. For SPEAR3: Driven by approximately 29 W of input, it produces approximately **800 kW** of RF output at 476 MHz (rated to ~1.5 MW). The klystron requires a high-voltage DC supply (from the HVPS, up to ~90 kV at the cathode) to operate. A separate I/Q Detector monitors the klystron drive power (`Kly Drive Pwr`) from the Drive Amplifier output.

### 2.5 Cavity

The single-cell accelerating cavity (or vector sum of all four cavities) stores the RF energy and delivers it as an accelerating voltage to the beam. Each cavity has:

- A **mechanical tuner** (driven by a stepper motor via worm gear) for resonance control
- A **forward power coupler** monitoring the klystron output forward power
- A **probe signal** port sampling the internal electric field — proportional to the gap voltage that the beam actually experiences

---

## 3. Measurement and Detection Elements

Three **I/Q Detector** blocks convert RF signals at 476 MHz into baseband amplitude and phase information that the feedback loops can process.

### 3.1 I/Q Det. — Kly Drive Pwr

| Attribute | Value |
|---|---|
| Location | Between Drive Amplifier output and the HVPS Loop summer |
| Input | Coupled sample of the RF drive power entering the klystron |
| Output | Baseband amplitude signal representing klystron input drive level |
| Used by | HVPS Loop — to regulate klystron operating point |

### 3.2 I/Q Det. — Kly Out Fwd Phase

| Attribute | Value |
|---|---|
| Location | Below the Klystron/Cavity interface, left side |
| Input | Coupled sample of the klystron RF output (forward power signal) |
| Output | Phase of the klystron forward signal relative to the 476 MHz reference (`Kly Out Fwd Phase`) |
| Used by | Ripple Loop (phase feedback) and Tuner Loop (one input to Tuner Phase summer) |

### 3.3 I/Q Det. — Probe Phase

| Attribute | Value |
|---|---|
| Location | Below the Cavity, right side |
| Input | Cavity probe signal — internal electric field of the cavity |
| Output | Phase (and amplitude) of the cavity gap voltage relative to the 476 MHz reference (`Probe Phase`) |
| Used by | Direct Loop, Comb Loop, Tuner Loop, and DAC Loop |

---

## 4. Individual Feedback Loops — Detailed Descriptions

### 4.1 Direct Loop — 800 kHz *(Primary Control Loop)*

**Purpose:** The Direct Loop is the primary, highest-bandwidth feedback loop. It directly controls the amplitude and phase of the RF field inside the cavity by comparing the cavity probe signal to a reference and correcting in real time. When this loop is active ("Direct Loop ON"), it dominates the dynamic behavior of the RF system. The **800 kHz bandwidth** means it can respond to disturbances with timescales down to approximately 1.25 microseconds.

**Signal Path:**

1. The cavity probe signal is detected by the **I/Q Det. (Probe Phase)**, producing a complex baseband error vector representing the current cavity field amplitude and phase.
2. This signal travels as a long feedback arc from the right side of the diagram (at the cavity) back to the left, arriving at a pair of summing junctions `(S)←(S)`.
3. The right-hand Σ also receives injection from the **Comb Loop** (via the Digital Comb Filter path).
4. The left-hand Σ also receives the output of the **GAP FF LOOP**, adding a feedforward correction term.
5. The summed error signal is applied directly to the **I/Q Modulator**, changing its drive amplitude and phase to reduce the error.

**Key characteristics:**

- Operates at baseband (I/Q representation of the 476 MHz signal)
- Proportional + integral (P+I) [For SPEAR3 LLRF upgrade, it will be controlled in the FPGA (LLRF9 digital implementation, Only Cavities A and B (BRD1, same board as DAC output) participate in the fastest direct proportional loop; Cavities C and D contribute via a slower integral path combined through an external power combiner]
- Loop delay of approximately  1 us for PEPII anagloy (**270 ns** (LLRF9 digital system) limits maximum achievable bandwidth)
- Activated specifically in the ON_CW operating mode

---

### 4.2 Comb Loop — 2 MHz

**Purpose:** The Comb Loop targets narrow-band disturbances at harmonics of the beam revolution frequency — specifically, the coupled-bunch instabilities driven by the HOMs (higher-order modes) of the RF cavity interacting with the circulating beam. Its name comes from the "comb" shape of its frequency response: it provides high gain only at integer multiples of the revolution frequency while leaving the response flat elsewhere.

> **Note:** The legacy comb filter (CFM module) was originally designed for PEP-II multi-bunch operation and is **not actively used in SPEAR3 operation**. 

**Signal Path:**

1. The cavity probe (Probe Phase Σ output) feeds the ** Comb Filter**.
2. The Comb Filter produces a correction with gain only at comb frequencies (harmonics of *f*_rev).
3. The filtered correction is injected at the input of the **Direct Loop right-hand Σ**, so the Comb Loop correction rides on top of the Direct Loop.
4. The combined Direct + Comb error signal then drives the I/Q Modulator.

**Key characteristics:**

- 2 MHz bandwidth — faster than the Direct Loop, needed because the comb filter output contains frequency components up to the bandwidth of the coupled-bunch modes
- The comb filter introduces a delay equal to one revolution period (*T*_rev), aligning the correction precisely to the next passage of the same bunch

---

### 4.3 Ripple Loop — 300 Hz

**Purpose:** The Ripple Loop corrects phase disturbances caused by ripple on the HVPS. Because the klystron gain and phase are sensitive to the cathode voltage, the 60 Hz (and harmonic) ripple from the 12-pulse thyristor rectifier modulates the klystron output phase at 120 Hz, 240 Hz, 360 Hz, etc. The Ripple Loop, with its **300 Hz bandwidth**, can track and cancel these periodic disturbances.

**Signal Path:**

1. The **I/Q Det. (Kly Out Fwd Phase)** measures the phase of the klystron output forward signal.
2. This phase signal feeds a pair of summing junctions at the center-left of the diagram. The right-hand Σ compares it against the **Ripple Loop Phase Ref** — a fixed reference setting the desired klystron output phase.
3. The left-hand Σ combines the ripple error with the Error signal from the Direct Loop path.
4. The correction is fed back to the **I/Q Modulator**, pre-compensating for ripple before it disturbs the cavity field.

**Key characteristics:**

- Uses the **klystron forward phase** (not the cavity probe) as its measurement point, acting upstream of the cavity for rapid correction of klystron-induced disturbances
- 300 Hz bandwidth chosen to cover the dominant ripple harmonics (120, 240 Hz) with adequate phase margin
- Provides the "Ripple Loop Phase Ref" as an internal setpoint, separate from the cavity field setpoint used by the Direct Loop

---

### 4.4 HVPS Loop — 1 Hz

**Purpose:** The HVPS Loop regulates the klystron operating point by controlling the High Voltage Power Supply output voltage. It performs slow supervisory regulation: adjusting the cathode voltage to keep the klystron drive power at the correct level set by the **ON_CW Drive Pwr** setpoint. This ensures the klystron always operates in its linear range, maintaining the correct gain and phase behavior that the faster RF feedback loops depend on.

**Signal Path:**

1. The **I/Q Det. (Kly Drive Pwr)** monitors the RF drive power at the klystron input (Drive Amplifier output).
2. The measured drive power is compared in a summing junction against the **ON_CW Drive Pwr** setpoint.
3. The error is processed by the **HVPS LOOP** controller (1 Hz bandwidth).
4. The controller output adjusts the **HVPS** DC high voltage (up to ~90 kV) on the klystron cathode.
5. Changing the cathode voltage changes the klystron perveance, shifting its gain and the amount of drive power needed for a given output.

**Key characteristics:**

- Very slow loop (1 Hz) — quasi-static operating point regulator, not a fast disturbance rejection loop
- Completely separate from the RF field feedback: controls HVPS, not the I/Q Modulator
- Protects the klystron from operating outside its rated parameters
- The HVPS has its own internal protection MPS (separate from the RF MPS system which protects the klystron and cavities)

---

### 4.5 Tuner Loop — 1 Hz

**Purpose:** The Tuner Loop keeps each RF cavity mechanically tuned to resonance at the operating frequency (476 MHz). If the cavity drifts off resonance due to thermal expansion, mechanical vibration, or beam loading, the Tuner Loop drives the **stepper motor tuner** (a mechanical plunger via 80:1 worm gear) to restore resonance. A detuned cavity presents a reactive load to the klystron and introduces amplitude and phase errors in the cavity field.

**Signal Path:**

1. The cavity probe phase (from **I/Q Det. Probe Phase**) is compared against the klystron output forward phase (from **I/Q Det. Kly Out Fwd Phase**) in the Tuner Phase summer (Σ).
2. A **Fixed Offset** is added to set the desired phase relationship between the klystron forward signal and the cavity probe, corresponding to the desired operating detuning angle.
3. The resulting phase error drives the **Tuner** actuator at ~1 Hz.
4. The Tuner mechanically adjusts the cavity volume, shifting the resonant frequency until the phase error is minimized.

**Key characteristics:**

- The **Fixed Offset** allows deliberate static detuning for beam loading compensation — the cavity is intentionally detuned so that the beam-induced voltage component adds constructively to the generator-induced voltage at the beam's phase angle
- 1 Hz bandwidth — much slower than the thermal and mechanical time constants of the cavity, but fast enough to track slow drifts
- **Independent loop for each cavity** — all four cavities have individual tuners
- For SPARE3 LLRF upgrade: LLRF9 provides dedicated tuner control PVs per cavity: `LLRF:TUNER:Cn:GAIN_P`, `GAIN_I`, `OFFSET`, `CLOSE`, `MINFWD`

---

### 4.6 Gap FF Loop — 100 Hz *(Feedforward + Feedback Hybrid)*	
**Purpose:** The Gap Feedforward (FF) Loop provides intermediate-bandwidth correction to the I/Q Modulator drive. It acts as a feedforward path that pre-compensates for predictable, systematic deviations in the cavity gap voltage — such as those caused by beam loading changes during injection, extraction, or RF power ramping. The "FF" designation indicates it anticipates rather than purely reacts to disturbances, though the closed-loop structure with an Error input means it also has a feedback component that corrects residual errors.

Provides IQ reference values for gap voltage setpoint and interfaces with Longitudinal Feedback (LFB) system for low-order coupled-bunch damping. Feed-forward path, not a feedback loop. GVF is the hardware module; GFF is the feed-forward function on the RFP DACs.

**Signal Path:**

1. The **Error** signal (output of the Ripple Loop / Direct Loop summing junctions) feeds into the **GAP FF LOOP** block.
2. The GAP FF LOOP processes this signal at up to 100 Hz bandwidth, generating a correction injected into the Direct Loop left-hand Σ — adding to the error correction going to the I/Q Modulator.
3. The GAP FF LOOP block also drives the **DAC** directly, providing a feedforward path for large, predictable corrections that bypasses the faster feedback loops.

**Key characteristics:**

- Shown as a tall box on the left side of the diagram, spanning from the Ripple/Direct loop level down to the DAC level
- 100 Hz bandwidth bridges the gap between the fast Direct Loop (800 kHz) and the very slow DAC Loop (0.1 Hz)
- The "Error" label confirms it corrects residual errors not fully handled by the faster loops

---

### 4.7 DAC Loop — 0.1 Hz

**Purpose:** The DAC Loop is the **slowest feedback loop** in the system. Its sole purpose is long-term DC drift correction: it ensures the DAC output (the baseband drive to the I/Q Modulator) accurately represents the desired station gap voltage setpoint over very long timescales (minutes to hours). Without this loop, slow thermal drifts in the analog electronics, DAC offsets, and cable parameter changes would cause the average cavity voltage to drift away from the setpoint.

**Signal Path:**

1. The cavity probe amplitude (via the Probe Phase Σ) produces a signal representing the actual station gap voltage.
2. This is compared in a summing junction against the **Stn Gap Volt** (Station Gap Voltage) setpoint — the desired total accelerating voltage in the storage ring.
3. The very slow (0.1 Hz) integrating controller drives the **DAC** output to eliminate any steady-state offset between actual and desired gap voltage.
4. The DAC output is the baseline drive signal to the I/Q Modulator, on top of which all faster feedback loops add their corrections.

**Key characteristics:**

- **Stn Gap Volt** (Station Gap Voltage) is the operator-settable parameter that determines the RF voltage seen by the beam — it sets the energy acceptance and synchrotron tune of the storage ring
- 0.1 Hz bandwidth — intentionally very slow to avoid interfering with the faster loops (Direct, Comb, Ripple)
- Provides the DC operating point; all other loops operate on top of this baseline
- The summing junction is shown at the far bottom-right of the diagram, with its output connecting all the way back to the DAC on the left

---

### 4.8 LFB Woofer — 1 MHz *(External Injection)*

**Purpose:** The LFB (Longitudinal Feedback) Woofer is an external correction signal injected from the **Longitudinal Multibunch Feedback System** — a separate, beam-based feedback system that measures the longitudinal oscillation of individual bunches using a high-bandwidth beam position monitor (BPM) and computes kick corrections.

The "Woofer" designation comes from audio engineering: in a multi-band feedback architecture, the "woofer" handles the low-frequency content of the correction (up to ~1 MHz), while a separate "tweeter" (higher-bandwidth actuator, e.g., a stripline kicker) handles higher frequencies. By injecting the woofer signal into the RF system, large-amplitude, low-frequency bunch oscillations (synchrotron motion with sidebands to ~1 MHz) are damped using the macroscopic RF voltage rather than a separate kicker.

**Signal Path:**

1. The Longitudinal Multibunch Feedback System (external) computes the required change in accelerating voltage to damp the measured longitudinal oscillation of each bunch.
2. The low-frequency component of this correction (up to 1 MHz) is the **LFB Woofer** signal.
3. It is injected directly into the **DAC** input, modulating the baseline I/Q Modulator drive at up to 1 MHz bandwidth.
4. This modulation changes the RF cavity voltage at the rate needed to damp coupled-bunch instabilities.

**Key characteristics:**

- 1 MHz bandwidth — fast enough to address the synchrotron sidebands of many coupled-bunch modes
- External to the LLRF system; the LLRF system simply receives and passes this signal to the DAC
- Works synergistically with the Comb Loop: the Comb Loop handles narrow-band instability modes at exact revolution harmonics, while the LFB Woofer provides broadband damping

---

## 5. Summing Junctions and Signal Hierarchy

The diagram shows multiple summing junctions (labeled Σ). Their roles are:

| Junction | Inputs | Output |
|---|---|---|
| **HVPS Summer** (top) | ON_CW Drive Pwr setpoint (+), Kly Drive Pwr measurement (−) | Error → HVPS Loop controller |
| **Ripple Right Σ** | Kly Out Fwd Phase (+), Ripple Loop Phase Ref (−) | Ripple phase error |
| **Ripple Left Σ** | Ripple error (+), Error from Direct/Gap FF path | Composite → I/Q Modulator |
| **Direct Right Σ** | Probe Phase error (+), Comb Loop correction | Direct + Comb combined |
| **Direct Left Σ** | Above (+), GAP FF LOOP output (+) | Full correction → I/Q Modulator |
| **Comb Σ** | Digital Comb Filter output (+), Probe Phase signal | Injects Comb correction into Direct Loop |
| **Tuner Σ** | Kly Out Fwd Phase (+), Probe Phase (−), Fixed Offset | Phase error → Tuner actuator |
| **DAC Loop Σ** (bottom right) | Probe Phase actual (−), Stn Gap Volt setpoint (+) | Slow DC error → DAC |

---

## 6. The DAC — Central Actuator for Slow Loops

The **DAC** (Digital-to-Analog Converter) block at the lower-left receives inputs from three sources:

1. **GAP FF LOOP output** — 100 Hz feedforward/feedback correction
2. **DAC LOOP output** — 0.1 Hz long-term DC regulation
3. **LFB WOOFER injection** — 1 MHz external multibunch feedback

Its output is the baseline complex (I/Q) drive signal to the I/Q Modulator, representing the slowly-varying RF amplitude and phase setpoint. The faster loops (Direct, Comb, Ripple) add their corrections on top of this baseline at the I/Q Modulator's summing input, so the DAC need only handle the slow components.

---

## 7. Loop Interactions and Hierarchy

The loops are nested by bandwidth, from innermost (fastest) to outermost (slowest):

```
┌──────────────────────────────────────────────────────────────────────┐
│  OUTERMOST — sets DC operating point                                 │
│                                                                      │
│  DAC Loop       (0.1 Hz) ─── Station gap voltage baseline            │
│  Gap FF Loop    (100 Hz) ─── Large slow corrections / beam loading   │
│  LFB Woofer     (1 MHz)  ─── External multibunch damping             │
│       ↓  [all three set the DAC / I/Q Mod baseline]                  │
│                                                                      │
│  Ripple Loop    (300 Hz) ─── Power supply ripple rejection           │
│       ↓  [rides on top of DAC baseline at I/Q Modulator]             │
│                                                                      │
│  Direct Loop    (800kHz) ─── PRIMARY cavity field control            │
│       ↓  [innermost fast loop, dominates dynamic response]           │
│                                                                      │
│  Comb Loop      (2 MHz)  ─── Injects into Direct Σ                   │
│                                                                      │
│  [Independent slow loops, parallel to above:]                        │
│  HVPS Loop      (1 Hz)   ─── Klystron HV setpoint                    │
│  Tuner Loop     (1 Hz)   ─── Cavity resonance frequency              │
│                                                                      │
│  INNERMOST — tightest cavity field control                           │
└──────────────────────────────────────────────────────────────────────┘
```

**Key design principle:** Each loop operates in a frequency band where it has sufficient gain and phase margin without interfering with adjacent loops. The bandwidth separation (typically 10× or more between adjacent loops) ensures stability of the overall nested loop system.

---

## 8. ON_CW Operating Mode — Significance

The title **"ON_CW with Direct Loop ON"** indicates two specific mode conditions:

### ON_CW
The RF station is operating in **continuous-wave (CW) mode** with beam circulating in the storage ring — the normal stored-beam operating mode, as opposed to injection, tuning, or standby modes. In ON_CW, the RF system is at full power and all loops are active. The `ON_CW Drive Pwr` setpoint shown in the diagram is the drive power target that the HVPS Loop uses to regulate the klystron operating point during this mode.

### Direct Loop ON
The **800 kHz Direct Loop** is engaged. This is the most powerful loop for cavity field regulation. Some operating modes (e.g., pulsed or low-power tuning modes) may run without the Direct Loop to simplify commissioning. The title explicitly calls out that this diagram applies to the fully-engaged, normal beam operating mode.

---

## 9. Legacy vs. Upgraded Implementation (SPEAR3 Context)

This diagram describes the **legacy analog LLRF system** based on the PEP-II RF Processor (RFP) in a VXI chassis. In the SPEAR3 LLRF Upgrade, these loops are reimplemented in the **Dimtel LLRF9/476** digital system:

| Legacy Element | LLRF9 Equivalent |
|---|---|
| I/Q Modulator (analog) | LLRF9 FPGA DAC output with I/Q baseband control |
| I/Q Detectors (analog) | LLRF9 FPGA ADC channels with digital downconversion |
| Direct Loop (~kHz analog) | LLRF9 digital Direct Loop (270 ns delay) |
| Digital Comb Filter | LLRF9 FPGA comb filter *(not used in SPEAR3)* |
| Ripple Loop (analog) | LLRF9 FPGA ripple rejection (inherent in digital feedback) |
| Gap FF Loop (SNL software) | Retained/EPICS coordinator + LLRF9 FPGA |
| DAC Loop (SNL software) | Retained/EPICS coordinator + LLRF9 slow scalar loop |
| HVPS Loop (SNL software) | Retained/EPICS coordinator + CompactLogix PLC |
| Tuner Loop (SNL software) | Retained/EPICS coordinator + LLRF9 tuner PVs + Galil DMC-4143 |

> **Note:** The Comb Loop (CFM module) and Gap Voltage Feedforward (GVF) loops from the legacy PEP-II system were **not used in SPEAR3 operation** and are eliminated in the upgrade. The LLRF9 digital feedback inherently provides superior ripple rejection and multi-bunch stabilization compared to the analog legacy implementation.

---

## 10. Summary Table

| Loop | Bandwidth | Measurement Signal | Actuator | Disturbance Rejected | Legacny SPEAR 3 Status| Upgraded SPEAR3 Status|
|---|---|---|---|---|---|---|
| LFB Woofer | 1 MHz | Beam BPM (external) | DAC → I/Q Modulator | Coupled-bunch longitudinal oscillations | No | No|
| Comb Loop | 2 MHz | Cavity probe (Probe Phase) | I/Q Modulator | HOM-driven coupled-bunch instabilities | No | No |
| Direct Loop | 800 kHz | Cavity probe (Probe Phase) | I/Q Modulator | All cavity field amplitude/phase errors | Yes - analog| Yes - LLRF9|
| Ripple Loop | 300 Hz | Klystron forward phase | I/Q Modulator | HVPS 60/120 Hz power supply ripple | Yes - analog| Yes - LLRF9 |
| Gap FF Loop | 100 Hz | Error signal | I/Q Modulator + DAC | Beam loading transients | No| No |
| HVPS Loop | 1 Hz | Klystron drive power | HVPS cathode voltage | Klystron operating point drift | Yes - EPICS| Yes - retained EPICS + HVPS PLC|
| Tuner Loop | 1 Hz | Probe vs. fwd phase + Fixed Offset | Mechanical tuner (stepper motor) | Cavity resonance frequency drift | Yes - EPICS| Yes - retained EPICS + Galil controller|
| DAC Loop | 0.1 Hz | Cavity probe amplitude | DAC output | Long-term DC drift / thermal drift | Yes - EPICS| Yes - retained EPICS|

---

*Document generated from Block Diagram #1 — feedbackLoopDescriptionps3403305200.pdf, PEPII RF Station.*
