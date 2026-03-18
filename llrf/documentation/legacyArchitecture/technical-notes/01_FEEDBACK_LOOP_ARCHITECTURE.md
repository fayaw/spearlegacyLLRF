# PEP-II / SPEAR3 LLRF Feedback Loop Architecture — Detailed Technical Reconstruction

**Document Number**: LLRF-REF-002
**Version**: 1.0
**Date**: 2026-03-18
**Classification**: Engineering Technical Reference
**Reconstructed From**: SLAC-PUB-8498 (Corredoura 1999), arXiv:physics/0007029 (Corredoura 2000), Phys. Rev. ST Accel. Beams 13:052802 (Fox 2010), Phys. Rev. ST Accel. Beams 10:022801 (Rivetta 2007), Legacy source code (`llrf/legacyLLRF/`)
**Cross-Reference PDF**: `feedbackLoopDescriptionps3403305200.pdf` (8 pages) — believed to document this content in the original SLAC drawing format

---

## 1. Overview: Multi-Loop Feedback Architecture

The PEP-II LLRF system implements **seven distinct feedback/control loops** operating at different timescales. This architecture was directly adopted for SPEAR3.

### 1.1 Master Block Diagram

Reconstructed from Corredoura SLAC-PUB-8498, Fig. 3 and arXiv:physics/0007029:

```
                        ┌─────────────────────────────────────────────────┐
                        │          FEEDBACK LOOP ARCHITECTURE              │
                        │                                                  │
  Station    ┌──────┐   │   ┌──────────┐                                  │
  Reference ─┤ IQ   ├───┼──▶│ Direct   │                                  │
  (476 MHz)  │ Demod│   │   │ Loop     │  ┌────────┐                      │
             └──────┘   │   │ (error)  ├─▶│ Σ      │   ┌────────────┐    │
                        │   └──────────┘  │(summing)├──▶│ Baseband   │    │
  Cavity     ┌──────┐   │                 │ node   │   │ Modulator  │    │
  Probes ────┤Vector├───┼─────────────────▶│        │   │ (klystron  │    │
  (×4)       │ Sum  │   │                 └───┬────┘   │ gain comp) │    │
             │ IQ   │   │   ┌──────────┐     │        └─────┬──────┘    │
             │ Demod│   │   │ Comb     │     │              │           │
             └──────┘   │   │ Loop     ├─────┘              ▼           │
                        │   │ (1-turn  │            ┌──────────────┐    │
                        │   │  delay)  │            │ IQ RF        │    │
                        │   └──────────┘            │ Modulator    │    │
                        │                           │ (476 MHz     │    │
                        │   ┌──────────┐            │  carrier)    │    │
                        │   │ Ripple   │────────────▶│              │    │
                        │   │ Loop     │            └──────┬───────┘    │
                        │   └──────────┘                   │           │
                        │                                  ▼           │
                        │                     ┌──────────────────┐     │
                        │                     │ Drive Amplifier  │     │
                        │                     │ (120 W solid     │     │
                        │                     │  state)          │     │
                        │                     └────────┬─────────┘     │
                        │                              │               │
                        └──────────────────────────────┼───────────────┘
                                                       ▼
                                              ┌──────────────┐
                                              │  KLYSTRON    │
                                              │  (1.2 MW)    │
                                              └──────┬───────┘
                                                     │
                                    ┌────────────────┼────────────────┐
                                    ▼                ▼                ▼
                              ┌──────────┐    ┌──────────┐    ┌──────────┐
                              │ Cavity 1 │    │ Cavity 2 │... │ Cavity 4 │
                              └──────────┘    └──────────┘    └──────────┘
                                    │                                │
                                    └────── Beam ────────────────────┘

  SLOW LOOPS (EPICS):
  ═══════════════════
  ┌──────────┐    ┌──────────┐    ┌──────────┐
  │ DAC Loop │    │ HVPS Loop│    │Tuner Loop│
  │ (~1 Hz)  │    │ (~0.5 Hz)│    │(~0.1 Hz) │
  │ setpoint │    │ cathode  │    │ stepper  │
  │ adjust   │    │ voltage  │    │ motor    │
  └──────────┘    └──────────┘    └──────────┘
```

---

## 2. Direct (Wideband) RF Feedback Loop

### 2.1 Purpose and Theory

The direct loop is the **primary impedance reduction loop**. Without feedback, the cavity fundamental impedance seen by the beam is:

```
Z_eff = R_s / (1 + j·2·Q_L·Δω/ω₀)

where R_s = 3.9 MΩ (shunt impedance per cavity)
```

With direct feedback at gain G, the effective impedance is reduced:

```
Z_eff(closed loop) ≈ Z_eff(open loop) / (1 + G)
```

For G ≈ 100 (40 dB), the impedance is reduced from 3.9 MΩ to ~39 kΩ per cavity. This reduction is critical for:
- Suppressing Robinson instability (growth rate ∝ Z_eff)
- Reducing coupled-bunch mode growth rates
- Improving cavity field stability against beam current fluctuations

### 2.2 Implementation Details

The direct loop operates entirely at **IQ baseband**:

```
 I_ref ──(+)──▶ Gain_I ──┐
          (-)              │     ┌──────────────┐
           ▲               ├────▶│ 2×2 Matrix   │──▶ I_drive
           │               │     │ (phase/gain  │
 I_cav ────┘               │     │  rotation)   │──▶ Q_drive
                           │     └──────────────┘
 Q_ref ──(+)──▶ Gain_Q ──┘          ▲
          (-)                        │
           ▲                    Phase Adjust
           │                    (compensate for
 Q_cav ────┘                     loop delay)
```

**Key design choices (from Corredoura 2000)**:

1. The **baseband modulator** uses four Gilbert-cell analog multipliers (rated ±1V max input) in a 2×2 matrix configuration to implement gain and phase rotation. This allows compensation for klystron gain/phase variations.

2. **Phase alignment** of the loop is critical. The total loop delay (cavity → demodulator → gain → modulator → drive amp → klystron → cavity) must be compensated to ensure negative feedback. Incorrect phase causes positive feedback and immediate instability.

3. **Dynamic range management**: The baseband voltages must stay within the ±1V multiplier range. Exceeding this range causes polarity inversion → positive feedback → catastrophic instability.

### 2.3 Gain Tracking (Klystron Saturation Compensation)

As klystron cathode voltage changes, its gain varies by up to 7 dB. The baseband modulator gain must be decreased proportionally:

```
Modulator Gain × Klystron Gain = Constant (loop gain)
```

This is implemented by the **quad DAC** in the RFP module, which sets the 2×2 matrix coefficients (I-I, I-Q, Q-I, Q-Q).

**Source Code Reference**: `rf_dac_loop.st` — the DAC loop adjusts these coefficients; `rf_calib.st` performs the initial calibration.

### 2.4 Limiting Circuits (Post-Commissioning Addition)

From Corredoura 2000, two limiting circuits were added:

1. **Baseband limiter**: Back-to-back Schottky diodes (1N4157) across a 50kΩ feedback resistor in the gain stage, with 100Ω series resistor forming a "soft" limiter at ±1V. Prevents multiplier overdrive.

2. **Drive power limiter**: Uses existing IQA module linear detector to detect drive power. If power exceeds a programmable setpoint, both I and Q drive signals are reduced proportionally (maintaining phase) to prevent klystron saturation.

**Cross-ref PDF**: `ps3403305503.pdf` (4 pages) — likely contains the drive chain schematic with limiting circuits.

---

## 3. Comb (Narrowband) RF Feedback Loop

### 3.1 Purpose

The comb loop provides **additional gain at revolution frequency harmonics** where coupled-bunch modes exist. The direct loop, while wideband, has finite gain that may not fully suppress all modes. The comb loop's high-Q notch characteristic provides >>20 dB additional gain at each revolution harmonic.

### 3.2 Implementation

Implemented in **dedicated VXI Comb Filter modules** (separate modules for I and Q channels):

```
                      ┌───────────────────────────────┐
  Error ──▶──────────▶│     Comb Filter               │
  Signal               │                               │
                       │  ┌─────┐   ┌─────┐           │
                       │  │Delay│──▶│  Σ  │──┐        │──▶ Output
                       │  │1 rev│   │     │  │        │
                       │  │turn │   └──┬──┘  │        │
                       │  └─────┘      │     │        │
                       │      ▲        │     ▼        │
                       │      └────────┘  ┌─────┐     │
                       │                  │Gain │     │
                       │                  │  g  │     │
                       │                  └─────┘     │
                       └───────────────────────────────┘

Transfer Function: H(z) = g / (1 - z^(-N))
where N = samples per revolution turn
      g = programmable gain

Frequency response peaks at: f = n × f_rev (n = 0, 1, 2, ...)
```

### 3.3 Key Parameters

| Parameter | PEP-II HER | PEP-II LER | SPEAR3 |
|-----------|-----------|-----------|---------|
| Revolution frequency | 136.3 kHz | 136.3 kHz | 1.2808 MHz |
| Revolution period | 7.34 μs | 7.34 μs | 0.781 μs |
| Comb teeth spacing | 136.3 kHz | 136.3 kHz | 1.2808 MHz |
| Maximum harmonics in bandwidth | ~3700 | ~3700 | ~390 |

### 3.4 Comb Loop Calibration

`rf_calib.st` contains the calibration sequence for the comb filter:
- `ZeroCombMults` state: Zeros the comb filter multiplier weights
- Iterative offset nulling to minimize DC offsets
- Load/Run/Gain control via PVs

**Cross-ref PDF**: `ps3403305600.pdf` (4 pages) — likely comb filter module specification.

---

## 4. Ripple Loop

### 4.1 Purpose

The HVPS uses SCR (thyristor) switching, producing ripple at:
- **360 Hz** fundamental (6-pulse rectifier × 60 Hz)
- Harmonics up to **~50 kHz**

This ripple modulates klystron cathode voltage → gain/phase modulation of RF output → cavity field perturbation.

### 4.2 Implementation Evolution

**Original Design**: DSP-based digital ripple cancellation. However, the significant delay in the digital IQ receiver combined with the 50 kHz bandwidth requirement proved challenging.

**Operational Implementation**: Analog integrator within the direct feedback loop path. This provides broadband ripple rejection but with trade-offs:

```
Analog Integrator Approach:
  Error signal ──▶ Integrator ──▶ Adds to direct loop output
                   (1/s)

  Benefit: Broadband rejection of HVPS ripple
  Risk: Integrator adds phase lag → reduces direct loop phase margin
        → instability risk at high beam currents (>2A per Corredoura)
```

**Post-commissioning upgrade** (proposed in Corredoura 2000): Dedicated analog wideband "ripple loop" separate from the direct loop, to avoid compromising direct loop stability.

### 4.3 Source Code Reference

`rf_dac_loop.st`:
- `ripple_loop_ampl` PV: Ripple loop amplitude setpoint
- `ripple_loop_load` PV: Trigger to load ripple loop coefficients
- `ripple_loop_ready_ef` event flag: Gain tracking at slower rate than main DAC loop

**Cross-ref PDF**: `ps3403305800.pdf` (4 pages) — likely ripple loop specification.

---

## 5. Lead and Integral Compensation

### 5.1 Purpose

These analog compensation networks improve the direct loop's frequency response:

- **Lead compensation**: Adds phase lead at the loop crossover frequency to improve phase margin. Without lead comp, the group delay through the klystron and cavity would erode phase margin.

- **Integral compensation**: Adds high gain at low frequencies for zero steady-state error. Ensures the cavity field tracks the reference exactly at DC.

### 5.2 Implementation

Implemented in the **RFP module** as analog circuits:

```
Lead Compensation:     H_lead(s) = (1 + s·τ_lead) / (1 + s·τ_lead/α)
                       where α > 1 provides phase lead

Integral Compensation: H_int(s) = 1 + 1/(s·τ_int)
                       Adds integrator at low frequencies
```

### 5.3 Source Code Reference

`rf_states.st`:
- Lead compensation is enabled/disabled during state transitions
- `INTCOMP` (integral compensation) is turned OFF in the OFF state (per Laznovsky 2004 modification)
- Lead comp enable/disable: Part of ON_CW state entry sequence

**Cross-ref PDF**: `ps3403305700.pdf` (2 pages) — likely lead/integral compensation specification.

---

## 6. Tuner Loop (Mechanical Frequency Control)

### 6.1 Purpose

The cavity mechanical tuner adjusts the resonant frequency to optimize the impedance match. The optimal detuning angle depends on beam current:

```
Optimal detuning: Δf = -(f_RF / 2·Q_L) × (I_b·R_s·sin(φ_s)) / V_gap

where φ_s = synchronous phase angle
      I_b = beam current
```

At zero beam current, the cavity should be tuned to resonance (Δf = 0). As beam current increases, the tuner moves to compensate for the reactive beam loading.

### 6.2 Implementation

**Hardware**: SLO-SYN stepper motors (Superior Electric) driving cavity tuning plungers. Each cavity has an independent tuner.

**Control**: EPICS sequence `rf_tuner_loop.st` running per-cavity instances (via `CAV` macro).

**States**: `loop_init` → `loop_unknown` → `loop_off` / `loop_on` / `loop_reset`

**Key logic** (from source code analysis):
- Monitors phase angle between forward power and cavity voltage
- Adjusts tuner position to minimize phase error (bring to target detuning)
- Respects motor deadband (`RDBD`) to prevent hunting
- Handles "bad load angle" conditions (tuner at wrong position)
- Reset and set-home procedures for calibration

### 6.3 Tuner in SPEAR3 Upgrade Context

The SPEAR3 upgrade replaces the SLO-SYN stepper system with a **Galil DMC-4143** motion controller:
- Commissioned August 2025
- EPICS motor record integration
- Integration with LLRF9 phase feedback loop

**Cross-ref PDF**: `ps3403306001.pdf` (5 pages) — likely tuner loop specification.
**Cross-ref source**: `rf_tuner_loop.st`, `rf_tuner_loop_defs.h`, `rf_tuner_loop_macs.h`, `rf_tuner_loop_pvs.h`

---

## 7. DAC Loop (Setpoint Adjustment)

### 7.1 Purpose

The DAC loop is the **outer supervisory loop** that adjusts the IQ reference setpoints (via Octal DACs on the RFP module) to maintain the desired drive power or gap voltage.

### 7.2 Operating Modes

From `rf_dac_loop.st`:

| Station State | DAC Loop Mode | Adjusts | Target |
|--------------|---------------|---------|--------|
| OFF/PARK/ON_FM | loop_off | Nothing | — |
| TUNE | loop_tune | RFP tune-mode DACs | Drive power |
| ON_CW (direct off) | loop_on | GFF references or RFP DACs | Drive power |
| ON_CW (direct on, GVF available) | loop_on | GFF I/Q references | Gap voltage |
| ON_CW (direct on, GVF unavailable) | loop_on | RFP diff node DACs | Gap voltage |

### 7.3 Control Algorithm

From `rf_dac_loop_macs.h` — the `DAC_LOOP_SET` macro:

1. Check if RF processor module is online
2. If loop control is OFF, only process phase changes
3. Otherwise: read current DAC counts, get delta_counts from error calculation
4. Apply delta (with minimum delta threshold of 0.5 counts)
5. Clamp to ±2047 counts (12-bit DAC range)
6. Write new setpoint
7. Update status

**Key parameters**:
- Maximum DAC counts: 2047 (12-bit, signed)
- Minimum delta: 0.5 counts (prevents hunting)
- Maximum interval: 10 seconds (guaranteed update even without trigger)
- Loop period: ~0.5 seconds (driven by EPICS database scan rate)

**Cross-ref PDF**: `ps3403305300.pdf` (4 pages) — likely DAC loop specification.

---

## 8. HVPS Loop (Klystron Voltage Regulation)

### 8.1 Purpose

Controls the klystron cathode voltage to regulate either:
- **Processing mode**: Gradually ramps voltage while conditioning cavities (monitoring vacuum, reflected power, and klystron forward power)
- **Operating mode**: Adjusts voltage to maintain constant drive power (in TUNE) or gap voltage (in ON_CW with direct loop)

### 8.2 Implementation

From `rf_hvps_loop.st`:

**Processing Mode** (`proc` state):
```
Every cycle (~0.5s):
  IF klystron forward power > max setpoint → decrease voltage
  IF cavity gap voltage > max setpoint → decrease voltage
  IF cavity vacuum > limit → decrease voltage
  ELSE → increase voltage (by delta_proc_voltage_up)
```

**Operating Mode** (`on` state):
```
Every cycle (~0.5s):
  IF station in ON_CW AND direct loop on:
    delta = -delta_on_voltage (gap voltage feedback)
  ELSE:
    delta = delta_tune_voltage (gap voltage via HVPS)
  
  IF increasing AND any cavity voltage at max → limit (cavv_lim)
  ELSE → apply delta to HVPS setpoint
```

### 8.3 Key Parameters

From `rf_hvps_loop_defs.h`:
- Maximum loop idle interval: 10 seconds
- Voltage tolerance count: 10 cycles before declaring out-of-tolerance
- HVPS states: OFF (0), PROC (1), ON (2)
- Loop controls: OFF (0), PROC (1), ON (2)

**Cross-ref PDF**: `ps3403305400.pdf` (2 pages) — likely HVPS loop specification.
**Cross-ref source**: `rf_hvps_loop.st`, `rf_hvps_loop_defs.h`, `rf_hvps_loop_macs.h`, `rf_hvps_loop_pvs.h`

---

## 9. Gap Voltage Feed-Forward (GVF/GFF)

### 9.1 Purpose

The Gap Voltage Feed-Forward module provides:
1. **I/Q reference values** for the gap voltage setpoint (used by direct loop as the reference target)
2. **LFB woofer interface** — a fiber optic link from the longitudinal multi-bunch feedback system that provides a low-frequency "kick" signal to be summed into the station drive

### 9.2 LFB Woofer (Longitudinal Feedback Integration)

From Corredoura SLAC-PUB-8498:

> "A wideband fiber optic connection to the longitudinal feedback system allows a RF station to operate as a powerful 'sub-woofer' to damp residual low order coupled bunch motion."

The longitudinal feedback system (designed by Fox, Teytelman et al.) operates bunch-by-bunch at high bandwidth. For low-order modes (modes 0-10), the feedback system sends a signal via fiber optic to the LLRF, which modulates the station's drive to provide additional damping.

### 9.3 TAXI Error Recovery

The GVF module includes TAXI (serial data link) error monitoring. A TAXI error indicates loss of synchronization with the fiber optic link. From `rf_msgs.st`:

```
kludge sequence to monitor the state of the taxi error bit
and resync the LFB if it's set
```

**Cross-ref PDF**: `ps3403305900.pdf` (7 pages) — likely GVF module specification.

---

## 10. Loop Stability Analysis

### 10.1 Open-Loop Transfer Function

The overall direct loop transfer function (simplified):

```
G_OL(s) = G_gain × G_klystron(s) × G_cavity(s) × G_demod(s) × G_delay(s)

where:
  G_gain      = Adjustable baseband gain (set via Quad DAC)
  G_klystron  = Klystron transfer function (nonlinear, depends on V_cathode)
  G_cavity    = Cavity response: R_s / (1 + j·2·Q_L·Δω/ω₀)
  G_demod     = IQ demodulator response (essentially flat to ~5 MHz)
  G_delay     = e^(-s·τ_total) where τ_total ≈ 1 μs (cable + processing delays)
```

### 10.2 Stability Margins

The total loop delay (τ_total ≈ 1 μs) limits the achievable bandwidth:

```
Maximum stable bandwidth ≈ 1 / (4 × τ_total) ≈ 250 kHz
```

With lead compensation, the actual crossover frequency can be pushed higher (~1 MHz) while maintaining adequate phase margin (>30°).

### 10.3 Rivetta Simulation Model

Rivetta et al. (2007) developed a comprehensive time-domain simulation that captures:
- Nonlinear klystron saturation characteristics
- Multiple cavity dynamics
- Beam-cavity interaction (macrobunch model)
- All LLRF feedback loops
- Power supply ripple
- Fill pattern transients

This model validated the LLRF design and explored stability limits at higher currents. Key finding: the ultimate current limit is set by the interaction between the direct loop phase margin and the comb loop gain at low-order revolution harmonics.

**Reference**: Rivetta, C. et al., Phys. Rev. ST Accel. Beams 10, 022801 (2007).

---

## 11. Cross-Reference to Legacy PDFs

| PDF File | Pages | Likely Content (Reconstructed) |
|----------|-------|-------------------------------|
| `feedbackLoopDescriptionps3403305200.pdf` | 8 | Complete feedback loop description — this document reconstructs its content |
| `ps3403305200.pdf` | 8 | Same as above (duplicate or revision) |
| `ps3403305100.pdf` | 11 | Main LLRF system specification (signal flow, module interconnection) |
| `ps3403305300.pdf` | 4 | DAC loop specification |
| `ps3403305400.pdf` | 2 | HVPS loop specification |
| `ps3403305503.pdf` | 4 | Drive chain / baseband modulator specification |
| `ps3403305600.pdf` | 4 | Comb filter module specification |
| `ps3403305700.pdf` | 2 | Lead/integral compensation specification |
| `ps3403305800.pdf` | 4 | Ripple loop specification |
| `ps3403305900.pdf` | 7 | GVF module specification |
| `ps3403306001.pdf` | 5 | Tuner loop specification |
| `ps3403306102.pdf` | 13 | Complete system test/commissioning procedure |
| `bd3403300000.pdf` | 1 | System block diagram (top level) |
| `bd3403300100.pdf` | 1 | Subsystem block diagram |
| `blockDiagrambd3403290100-1.pdf` | 1 | Additional block diagram (possibly VXI crate layout) |

---

*See also: `02_VXI_HARDWARE_MODULE_REFERENCE.md` for hardware details.*
*See also: `05_CROSS_REFERENCE_INDEX.md` for complete topic mapping.*
