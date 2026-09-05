# PEP-II / SPEAR3 LLRF Feedback Loop Architecture — Detailed Technical Reconstruction

**Document Number**: LLRF-REF-002
**Version**: 3.0
**Date**: 2026-03-19
**Classification**: Engineering Technical Reference
**Reconstructed From**: SLAC-PUB-8498 (Corredoura 1999), arXiv:physics/0007029 (Corredoura 2000), Phys. Rev. ST Accel. Beams 13:052802 (Fox 2010), Phys. Rev. ST Accel. Beams 10:022801 (Rivetta 2007), Legacy source code (`spear-rf-code-legacy/rfApp/src/seq/`)
**Cross-Reference PDF**: `feedbackLoopDescriptionps3403305200.pdf` (8 pages) — believed to document this content in the original SLAC drawing format

---

## 1. Overview: Multi-Loop Feedback Architecture

The PEP-II LLRF system implements **seven distinct feedback/control loops** operating at different timescales. This architecture was directly adopted for SPEAR3.

### 1.1 Master Block Diagram

Reconstructed from Corredoura SLAC-PUB-8498, Fig. 3 and arXiv:physics/0007029:

```
                        ┌──────────────────────────────────────────────────┐
                        │          FEEDBACK LOOP ARCHITECTURE              │
                        │                                                  │
  Station    ┌──────┐   │    ┌──────────┐                                  │
  Reference ─┤ IQ   ├───┼──▶│ Direct   │                                  │
  (476 MHz)  │ Demod│   │    │ Loop     │   ┌────────┐                     │
             └──────┘   │    │ (error)  ├─▶ │ Σ      │    ┌────────────┐  │
                        │    └──────────┘   │(summing)├──▶│ Baseband   │  │
  Cavity     ┌──────┐   │                   │ node   │     │ Modulator │   │
  Probes ────┤Vector├───┼─────────────────▶│        │     │ (klystron │   │
  (×4)       │ Sum  │   │                   └───┬────┘    │ gain comp) │   │
             │ IQ   │   │   ┌──────────┐        │         └─────┬──────┘   │
             │ Demod│   │   │ Comb     │        │              │           │
             └──────┘   │   │ Loop     ├────────┘              ▼           │
                        │   │ (1-turn  │             ┌──────────────┐      │
                        │   │  delay)  │             │ IQ RF        │      │
                        │   └──────────┘             │ Modulator    │      │
                        │                            │ (476 MHz     │      │
                        │   ┌──────────┐             │  carrier)    │      │
                        │   │ Ripple   │────────────▶│             │      │
                        │   │ Loop     │             └──────┬───────┘     │
                        │   └──────────┘                    │             │
                        │                                   ▼             │
                        │                     ┌──────────────────┐        │
                        │                     │ Drive Amplifier  │        │
                        │                     │ (120 W solid     │        │
                        │                     │  state)          │        │
                        │                     └────────┬─────────┘        │
                        │                              │                  │
                        └──────────────────────────────┼──────────────────┘
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
  │ (~0.1 Hz)│    │ (~1 Hz)  │    │(~1 Hz)   │
  │ setpoint │    │ cathode  │    │ stepper  │
  │ adjust   │    │ voltage  │    │ motor    │
  └──────────┘    └──────────┘    └──────────┘
```

### 1.2 Feedback and Control Loop Summary

The following table lists all feedback and control loops in the PEP-II/SPEAR3 LLRF system, organized from **highest to lowest bandwidth**. Loops marked ❌ were part of the PEP-II design but are **not used in SPEAR3** (neither in the legacy system nor the LLRF9 upgrade).

| # | Loop Name | Function | Approx. Bandwidth | Hardware / Components | SPEAR3 Status |
|---|-----------|----------|-------------------|----------------------|---------------|
| 1 | **Direct (Wideband) RF Feedback Loop** | Reduces effective cavity impedance by ~40 dB (factor of ~100), suppressing Robinson instability and coupled-bunch growth rates | ~800 kHz (with lead compensation; ~250 kHz without) | Analog: RFP module (error amplifier, lead/integral compensation, baseband modulator), IQ demodulators, IQ RF modulator | ✅ Active |
| 2 | **Comb (Narrowband) RF Feedback Loop** | Provides additional gain at revolution frequency harmonics to further suppress coupled-bunch modes beyond what the Direct loop alone achieves | ~2 MHz overall span; ~10 kHz per comb tooth | Digital: VXI Comb Filter modules (I and Q, separate), FIFO one-turn delay | ❌ PEP-II only |
| 3 | **Ripple Feedback Loop** | Cancels RF amplitude/phase modulation from HVPS switching ripple (~360 Hz fundamental, harmonics to ~50 kHz). In SPEAR3 practice, deployed primarily as a slow phase tracker compensating for klystron phase shift across cathode voltage changes | Up to ~50 kHz (design); lower effective BW in SPEAR3 slow-tracker mode | DSP: AT&T DSP1610 processor; analog integrator path | ✅ Active (as slow phase tracker) |
| 4 | **HVPS Voltage Regulation Loop** | Regulates klystron cathode voltage to maintain RF drive power or gap voltage at setpoint; includes processing mode for cavity conditioning | ~0.5–1 Hz | Software: VxWorks SNL (`rf_hvps_loop.st,v`); HVPS SCR controller, Enerpro voltage regulator board | ✅ Active |
| 5 | **DAC Control Loop** | Maintains gap voltage and RF drive power at software setpoints by adjusting baseband DAC values; compensates for slow drifts and klystron gain variation | ~0.1 Hz | Software: VxWorks SNL (`rf_dac_loop.st,v`); Octal DAC on RFP module | ✅ Active |
| 6 | **Tuner Control Loop** | Adjusts cavity resonant frequency via mechanical tuner to maintain optimal detuning angle for beam loading compensation | ~0.01–1 Hz (stepper motor limited) | EPICS: VxWorks SNL (`rf_tuner_loop.st,v`); stepper motors, mechanical tuner plungers (per cavity) | ✅ Active |
| 7 | **Gap Voltage Feed-Forward (GVF module / GFF function)** | Provides IQ reference values for gap voltage setpoint and interfaces with Longitudinal Feedback (LFB) system for low-order coupled-bunch damping. *Feed-forward path, not a feedback loop.* GVF is the hardware module; GFF is the feed-forward function on the RFP DACs. | N/A (feed-forward) | VXI GVF module; GFF IQ DACs on RFP; fiber optic TAXI link to LFB | ❌ PEP-II only (both GVF and GFF) |

> **Notes on bandwidth values:**
> - Bandwidth values are approximate and depend on operating conditions (beam current, loop gain settings, compensation parameters).
> - The Direct loop bandwidth of ~800 kHz assumes lead compensation is active (see §6). Without lead compensation, the maximum stable bandwidth is limited to ~250 kHz by the total loop delay of ~1 μs (see §11.2).
> - The Comb loop's "~2 MHz overall span" refers to the range of revolution harmonics covered; individual comb teeth have ~10 kHz bandwidth each (see §4, cross-ref PS-52 transcription).
> - The Ripple loop was originally designed for HVPS ripple cancellation but in SPEAR3 was deployed primarily as a slow phase tracker (see §5).
> - Loops 4–6 are software-based EPICS/SNL control loops running on the VxWorks IOC, not analog hardware loops.

---

## 2. RF Cavity Theory and Mathematical Framework

### 2.1 Cavity Impedance Model

The RF cavity near its fundamental resonance is characterized by:

```
R_s    = shunt impedance (linac convention, R_s = V²/2P) = 3.73 MΩ per SPEAR3 cavity
Q_0    = unloaded quality factor = 32,000
Q_ext  = external (coupling) quality factor
Q_L    = loaded quality factor = 1/(1/Q_0 + 1/Q_ext) = 6,700 (SPEAR3)
β      = coupling coefficient = Q_0/Q_ext = 4.0 (SPEAR3)
ω_0    = 2π × ~476.3 MHz (resonant angular frequency)
Δω     = ω - ω_0 (detuning from resonance)
```

The cavity transfer function (voltage response to driving current) in the Laplace domain:

```
H_cav(s) = (R_s/Q_L) × ω_0 / (s² + (ω_0/Q_L)s + ω_0²)
```

Near resonance, using the narrowband approximation (|Δω| << ω_0):

```
Z_cav(Δω) = R_s / (1 + j·2·Q_L·Δω/ω_0)
```

The cavity half-bandwidth is:

```
f_1/2 = f_0 / (2·Q_L) = 476.3 MHz / (2 × 6700) ≈ 35.5 kHz
```

This bandwidth determines the maximum rate at which cavity fields can change naturally (without feedback).

### 2.2 Beam Loading Theory

When a beam of DC current I_b passes through a cavity, each bunch deposits energy that excites the cavity fundamental mode. The beam-induced voltage in phasor notation:

```
V_b = I_b · (R_s/Q_L) · Q_L · e^(jψ) = I_b · R_s · e^(jψ)   (for β >> 1)

where ψ = detuning angle = arctan(2·Q_L · Δf/f_0)
```

The total cavity voltage is the superposition of generator-driven and beam-induced voltages:

```
V_cav = V_g + V_b

V_g = generator-induced voltage = I_g · R_s / (1 + β)
V_b = beam-induced voltage (opposes generator for above-transition energy)
```

**Phasor diagram** (beam loading compensation):
```
                    V_cav (desired)
                   ↗
                  /
                 / φ_s (synchronous phase)
    V_g ────────O──────────────── beam direction
                 \
                  \ ψ (detuning angle)
                   \
                    V_b (beam-induced, opposing)
```

**Required generator power** for a given gap voltage V_gap and beam current I_b:

```
P_gen = V_gap² / (4·R_s/Q_L·Q_L) × (1 + β)² / β × [1 + (2·Q_L·Δf/f_0)²] + I_b · V_gap · cos(φ_s)
      
        ──────────────────────────────────────────────────────────────   ───────────────────────── 
        cavity wall loss term                                             beam acceleration term
```

**Optimum detuning** (minimizes reflected power, for a given I_b and V_gap):

```
tan(ψ_opt) = -I_b · R_s · sin(φ_s) / V_gap
Δf_opt = f_0 · tan(ψ_opt) / (2·Q_L)
```

For SPEAR3 at 500 mA: I_b = 0.5 A, R_s = 3.73 MΩ, V_gap = 712 kV/cavity, φ_s ≈ 75°:
```
tan(ψ_opt) ≈ -(0.5 × 3.9e6 × sin(75°)) / 712e3 ≈ -2.64
ψ_opt ≈ -69°
Δf_opt ≈ 476.3e6 × (-2.64) / (2 × 6700) ≈ -93.9 kHz
```

> **Source**: Wilson, P.B., "Fundamental-Mode RF Design in e+e- Storage Ring Factories," SLAC-PUB-6062, 1993; `Designs/0_PHYSICAL_DESIGN_REPORT.md`

### 2.3 Robinson Instability

The Robinson instability arises from the asymmetry of the effective cavity impedance above and below the RF frequency at revolution sidebands.

**Growth/damping rate** for a single cavity:

```
1/τ_Robinson = -(I_b · α_c · ω_rev) / (4 · E_0 · ω_s) ×
               [Re{Z_eff(ω_RF + ω_s)} - Re{Z_eff(ω_RF - ω_s)}]

where:
  α_c = momentum compaction factor
  ω_rev = revolution angular frequency = 2π × ~1.2804 MHz (SPEAR3)
  ω_s = synchrotron angular frequency ≈ 2π × 8.8 kHz (SPEAR3)
  E_0 = beam energy = 3.0 GeV
```

**Stability criterion** (Robinson): For operation above transition energy, the cavity must be detuned such that:

```
Re{Z_eff(ω_RF + ω_s)} < Re{Z_eff(ω_RF - ω_s)}
```

This is achieved by tuning the cavity resonance below the RF frequency (negative detuning), which is the standard operating condition for both PEP-II and SPEAR3.

**With direct feedback**, the effective impedance at all frequencies is reduced:

```
Z_eff,fb(ω) = Z_cav(ω) / (1 + G_OL(ω))

where G_OL(ω) = open-loop gain at frequency ω
```

Since the feedback reduces Z_eff by a factor of ~100, the Robinson growth rate is reduced by the same factor, providing substantial stability margin.

### 2.4 Direct Loop Transfer Function Analysis

**Open-loop transfer function** of the direct feedback loop:

```
G_OL(s) = G_0 · H_cav(s) · H_kly(s) · e^(-τ_d·s)

where:
  G_0    = loop gain setting (adjustable via PV SRF1:STNDIRECT:LOOP:COUNTS.A)
  H_cav  = cavity transfer function (narrowband, ~35.5 kHz bandwidth)
  H_kly  = klystron transfer function (wideband, but with AM-PM conversion)
  τ_d    = total loop delay ≈ 270 ns (LLRF9) or ~1 μs (legacy VXI)
```

**Closed-loop transfer function** (cavity voltage response to reference):

```
T(s) = G_OL(s) / (1 + G_OL(s))
```

**Effective cavity impedance** (seen by the beam):

```
Z_eff(s) = Z_cav(s) / (1 + G_OL(s))
```

**Maximum stable gain** is limited by the loop delay. The phase margin condition requires:

```
|G_OL(jω_c)| = 1  at crossover frequency ω_c
∠G_OL(jω_c) > -180° + PM  (where PM = phase margin, typically 30–45°)
```

The loop delay contributes -ω·τ_d radians of phase. At crossover:

```
ω_c · τ_d < π - PM - ∠H_cav(ω_c) - ∠H_kly(ω_c)
```

For τ_d = 270 ns (LLRF9), the maximum crossover frequency is approximately:

```
f_c,max ≈ 1/(4·τ_d) ≈ 1/(4 × 270 ns) ≈ 926 kHz  (for 45° phase margin)
```

This is a significant improvement over the legacy VXI system (τ_d ≈ 1 μs → f_c,max ≈ 250 kHz).

**Phase alignment** is set by the PV `SRF1:STNDIRECT:LOOP:PHASE.C` which rotates the feedback signal to ensure negative feedback at the operating frequency. From Jim Sebek's operational notes: "The precise detuning angle is not extremely critical; at this tuning, modifying the loop gain and phase will have only minor effects on the beam stability."

> **Source**: Corredoura, SLAC-PUB-8498; `llrf/documentation/LLRFOperation_jims.docx`

### 2.5 Comb Filter Transfer Function

The comb filter provides narrow-band gain at revolution harmonics. Its z-domain transfer function:

```
H_comb(z) = a · z^(-N) / (1 - b · z^(-N))

where:
  N = number of samples per revolution period
  a = feed-forward gain coefficient (sets peak gain)
  b = feedback coefficient (sets bandwidth per tooth), |b| < 1 for stability
```

**Frequency response**: The filter has gain peaks at:

```
f_peak = n · f_rev    (n = 0, 1, 2, ...)

Peak gain = a / (1 - b)
Bandwidth per tooth ≈ (1 - b) · f_rev / π
```

For SPEAR3: f_rev ≈ 1.2804 MHz, so revolution harmonic spacing is ≈ 1.2804 MHz. For PEP-II: f_rev = 136.3 kHz, much denser spacing requiring more precise filtering.

**Note**: The comb filter was essential for PEP-II (multi-ampere beam with dense revolution harmonics) but is **not used in the current SPEAR3 legacy system** and is **eliminated in the LLRF9 upgrade** — the LLRF9's wideband digital direct loop provides sufficient coupled-bunch mode suppression for SPEAR3's moderate beam loading.

### 2.6 HVPS Ripple Spectrum

The HVPS uses a **12-pulse thyristor rectifier** (two 6-pulse bridges with ±15° phase-shift transformer). The dominant ripple harmonics are at:

```
f_ripple = 12·n·f_line = 12n × 60 Hz = 720, 1440, 2160, ... Hz

Ripple amplitude ∝ 1/n for ideal 12-pulse rectifier
Typical ripple voltage: ~0.1–0.5% of DC output (at fundamental 720 Hz)
```

This ripple modulates the klystron cathode voltage, producing:

```
ΔV_kly/V_kly ≈ ΔV_HVPS/V_HVPS
ΔP_kly/P_kly ≈ 2.5 × ΔV_kly/V_kly  (from klystron power-voltage characteristic)
```

The PEP-II system used a dedicated **ripple feedback loop** to cancel this modulation. From Corredoura 2000: "An analog integrator in the direct RF feedback loop cancels the ripple but simulations show it will cause instability as beam currents reach 2A."

In the LLRF9 upgrade, the 270 ns loop delay and digital processing bandwidth (~1 MHz) are sufficient to reject 720 Hz ripple without a dedicated loop.

### 2.7 Klystron Saturation Model

The klystron is a nonlinear amplifier characterized by:

```
P_out = P_sat × (P_in/P_in,sat) / (1 + P_in/P_in,sat)   (simplified saturation model)

Phase shift: Δφ_kly = Δφ_AM-PM × (P_in/P_in,sat)   (AM-PM conversion)
```

As beam current changes, the required klystron output power changes, and the operating point moves along the saturation curve. This changes:
1. **Small-signal gain** — varies by up to 7 dB over the operating range (from Fox 2010)
2. **AM-PM conversion** — phase shift depends on operating power level

The **gain tracking** function (baseband modulator coefficient adjustment) compensates for these variations to maintain constant loop gain:

```
G_modulator × G_klystron = G_loop (constant)

Therefore: G_modulator = G_loop / G_klystron(V_HVPS)
```

> **Source**: Corredoura, arXiv:physics/0007029; Fox et al., Phys. Rev. ST Accel. Beams 13, 052802 (2010)

### 2.8 Collector Power Protection Formula

The klystron collector must not exceed its thermal rating. The collector power is:

```
P_collector = P_DC - P_RF,forward = V_HVPS × I_HVPS - P_kly,fwd

where:
  V_HVPS = HVPS output voltage (≤ 90 kV, nominal 74 kV)
  I_HVPS = HVPS output current (nominal 22 A)
  P_kly,fwd = klystron forward output power (nominal ~800 kW)
```

If P_RF drops to zero (e.g., LLRF trip), the full DC power goes to the collector:
```
P_collector,max = V_HVPS × I_HVPS = 74 kV × 22 A = 1.63 MW
```
This exceeds the collector's continuous rating, requiring fast HVPS shutdown.

**Legacy implementation**: Software limit in `rf_hvps_loop.st,v` monitoring `klystron_forward_power` vs. `max_klystron_forward_power`, plus MPS hardware comparator.

**Upgraded implementation**: Waveform Buffer System computes P_collector = V×I - P_fwd directly, with hardware trip to Interface Chassis.

> **Source**: `Designs/0_PHYSICAL_DESIGN_REPORT.md`, Section 11.3; `llrf/documentation/fiberOpticCableSignalControlRev3.docx`

### 2.9 Tuner Control Mathematics

The cavity resonant frequency is adjusted by a mechanical plunger driven by a stepper motor:

**Detuning angle**:
```
ψ = arctan(2·Q_L · Δf/f_0)

where Δf = f_cavity - f_RF (positive = cavity above RF)
```

**Tuner mechanical parameters** (from `LLRFOperation_jims.docx`):
```
Motor: Superior Electric M093-FC11 (200 steps/revolution)
Controller: 2 microsteps/step → 400 microsteps/revolution
Gear ratio: 1:2 (pulley, motor:lead screw)
Lead screw: ½-10 Acme thread (10 TPI) → 1 revolution = 2.54 mm
Distance per microstep: 2.54 mm / (2 × 400) = 0.003175 mm = 3.175 μm

RDBD (readback deadband): 5 microsteps ≈ 0.016 mm
Typical motion during normal operation: ~0.2 mm
Total tuner travel from home to initial ON position: ~2.5 mm
```

**Upgraded controller** (Galil DMC-4143): Up to 256 microsteps/step → 51,200 microsteps/revolution → 0.05 μm/microstep (16× improvement).

**Load angle offset loop**: Balances gap voltage across 4 cavities by adjusting individual tuner phase setpoints:
```
For each cavity i:
  V_gap,i / V_gap,total = target fraction (set by SRF1:CAVi:STRENGTH:CTRL)
  
  Error = V_gap,i/V_gap,total - target_i
  Δψ_i = K_LA × Error   (K_LA = load angle gain)
  ψ_setpoint,i += Δψ_i
```

> **Source**: `llrf/documentation/LLRFOperation_jims.docx`; `Designs/0_PHYSICAL_DESIGN_REPORT.md`, Section 10.4

---

## 3. Direct (Wideband) RF Feedback Loop — Implementation Details

### 3.1 Purpose and Design

The direct loop is the **primary impedance reduction loop** (mathematical basis in Section 2.4 above). Without feedback, the cavity fundamental impedance seen by the beam is:

```
Z_eff = R_s / (1 + j·2·Q_L·Δω/ω₀)

where R_s = 3.73 MΩ (shunt impedance per cavity, linac convention)
```

With direct feedback at gain G, the effective impedance is reduced:

```
Z_eff(closed loop) ≈ Z_eff(open loop) / (1 + G)
```

For G ≈ 100 (40 dB), the impedance is reduced from 3.73 MΩ to ≈ 37 kΩ per cavity. This reduction is critical for:
- Suppressing Robinson instability (growth rate ∝ Z_eff)
- Reducing coupled-bunch mode growth rates
- Improving cavity field stability against beam current fluctuations

### 3.2 Implementation Details

The direct loop operates entirely at **IQ baseband**:

```
 I_ref ──(+)──▶ Gain_I ──┐
          (-)              │     ┌──────────────┐
           ▲               ├───▶│ 2×2 Matrix   │──▶ I_drive
           │               │     │ (phase/gain  │
 I_cav ────┘               │     │  rotation)   │──▶ Q_drive
                           │     └──────────────┘
 Q_ref ──(+)──▶ Gain_Q ──┘           ▲
          (-)                        │
           ▲                    Phase Adjust
           │                    (compensate for
 Q_cav ────┘                     loop delay)
```

**Key design choices (from Corredoura 2000)**:

1. The **baseband modulator** uses four Gilbert-cell analog multipliers (rated ±1V max input) in a 2×2 matrix configuration to implement gain and phase rotation. This allows compensation for klystron gain/phase variations.

2. **Phase alignment** of the loop is critical. The total loop delay (cavity → demodulator → gain → modulator → drive amp → klystron → cavity) must be compensated to ensure negative feedback. Incorrect phase causes positive feedback and immediate instability.

3. **Dynamic range management**: The baseband voltages must stay within the ±1V multiplier range. Exceeding this range causes polarity inversion → positive feedback → catastrophic instability.

### 3.2a Direct Loop Sub-Functions (from PS-340-330-52-R0)

The Direct Loop contains three configurable sub-functions accessible from the EPICS Feedback panel:

1. **INTEGRAL COMPENSATION**: Smooths out ripple caused by the klystron high voltage power supply. Provides steady-state error elimination.

2. **LEAD COMPENSATION**: Increases the bandwidth and gain of the direct loop. Provides additional phase margin at the gain crossover frequency.

3. **FREQUENCY OFFSET TRACKING**: Compensates for the phase shift caused by detuning of the cavities during heavy beam loading. The cavity detuning introduces a frequency-dependent phase rotation that the feedback loop must accommodate. This sub-function is primarily used as a **diagnostic** for adjusting the waveguide network and should **not normally be activated** during routine operation.

The MATLAB routine **"ConfDirect"** sets up the Direct Loop for proper loop phase, loop gain, and gain tracking. The closed-loop response can be measured in-situ using the built-in network analyzer via **"MeasDirCls"** — this measurement does **not** cause loss of stored beam.

> **Source**: `legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md`

### 3.2b Alternate Operating Modes (Direct Loop OFF)

When the Direct Loop is OFF (station in ON_CW without beam, TUNE, or ON_FM mode), the loop hierarchy changes significantly:

| Feature | Direct Loop ON | Direct Loop OFF |
|---------|:-:|:-:|
| Cavity impedance control | Direct + Comb + Woofer | None |
| Gap voltage regulation | DAC Loop → DAC reference | HVPS Loop → HVPS voltage |
| Drive power regulation | HVPS Loop → klystron voltage | DAC Loop → DAC level |
| Typical beam current | > 0 mA (stored beam) | 0 mA (no beam) |
| Comb Loop | Active | Inactive |
| Gap FF | Active | Inactive |

**HVPS Loop (Direct Loop OFF)**: Keeps the measured gap voltage equal to the requested "Station Gap Voltage" by adjusting the klystron high voltage — this is the reverse of its behavior when the Direct Loop is ON.

**DAC Loop (Direct Loop OFF)**: Keeps the drive power at the requested level by adjusting the DAC in the Gap Voltage FF module — again, the reverse of its normal role.

> **Source**: `legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md`, Section 4

### 3.3 Gain Tracking (Klystron Saturation Compensation)

As klystron cathode voltage changes, its gain varies by up to 7 dB. The baseband modulator gain must be decreased proportionally:

```
Modulator Gain × Klystron Gain = Constant (loop gain)
```

This is implemented by the **quad DAC** in the RFP module, which sets the 2×2 matrix coefficients (I-I, I-Q, Q-I, Q-Q).

**Source Code Reference**: `rf_dac_loop.st,v` — the DAC loop adjusts these coefficients; `rf_calib.st,v` performs the initial calibration.

### 3.4 Limiting Circuits (Post-Commissioning Addition)

From Corredoura 2000, two limiting circuits were added:

1. **Baseband limiter**: Back-to-back Schottky diodes (1N4157) across a 50kΩ feedback resistor in the gain stage, with 100Ω series resistor forming a "soft" limiter at ±1V. Prevents multiplier overdrive.

2. **Drive power limiter**: Uses existing IQA module linear detector to detect drive power. If power exceeds a programmable setpoint, both I and Q drive signals are reduced proportionally (maintaining phase) to prevent klystron saturation.

**Cross-ref PDF**: `ps3403305503.pdf` (4 pages) — RF Station Safety Survey (PS-340-330-55-R3). ⚠️ Note: This document is a safety survey form, not a drive chain specification. Drive chain design details come from Corredoura 2000, Figs. 4-6; no standalone drive chain spec was found in the legacy archive.

---

## 4. Comb (Narrowband) RF Feedback Loop — ⚠️ PEP-II ONLY

> ⚠️ **This loop is a PEP-II design element only. The Comb Filter Modules (CFM) were NOT used in the SPEAR3 legacy system (1999–2022) and are NOT present in the LLRF9 upgrade (2022–present). This section is retained for historical/reference purposes to document the inherited PEP-II architecture.**

### 4.1 Purpose (PEP-II)

The comb loop provides **additional gain at revolution frequency harmonics** where coupled-bunch modes exist. The direct loop, while wideband, has finite gain that may not fully suppress all modes. The comb loop's high-Q notch characteristic provides >>20 dB additional gain at each revolution harmonic.

### 4.2 Implementation

Implemented in **dedicated VXI Comb Filter modules** (separate modules for I and Q channels):

```
                       ┌───────────────────────────────┐
  Error ──▶──────────▶│     Comb Filter               │
  Signal               │                               │
                       │  ┌─────┐    ┌─────┐           │
                       │  │Delay│──▶│  Σ  │──┐        │──▶ Output
                       │  │1 rev│    │     │  │        │
                       │  │turn │    └──┬──┘  │        │
                       │  └─────┘       │     │        │
                       │      ▲         │     ▼        │
                       │      └─────────┘  ┌─────┐     │
                       │                   │Gain │     │
                       │                   │  g  │     │
                       │                   └─────┘     │
                       └───────────────────────────────┘

Transfer Function: H(z) = g / (1 - z^(-N))
where N = samples per revolution turn
      g = programmable gain

Frequency response peaks at: f = n × f_rev (n = 0, 1, 2, ...)
```

### 4.3 Key Parameters

| Parameter | PEP-II HER | PEP-II LER | SPEAR3 |
|-----------|-----------|-----------|---------|
| Revolution frequency | 136.3 kHz | 136.3 kHz | ~1.2804 MHz |
| Revolution period | 7.34 μs | 7.34 μs | 0.781 μs |
| Comb teeth spacing | 136.3 kHz | 136.3 kHz | ~1.2804 MHz |
| Maximum harmonics in bandwidth | ~3700 | ~3700 | ~390 |

### 4.4 Comb Loop Calibration

`rf_calib.st,v` contains the calibration sequence for the comb filter:
- `ZeroCombMults` state: Zeros the comb filter multiplier weights
- Iterative offset nulling to minimize DC offsets
- Load/Run/Gain control via PVs

**MATLAB Commissioning Routines** (from PS-340-330-52-R0):
- **"Config Comb"**: Configures comb filter parameters (gain, delay equalization)
- **"Make Equal"**: Sets the comb loop delay equalizer to match the one-turn delay to the actual revolution period. Critical for aligning comb teeth to revolution harmonics.
- **"Make Poly"**: Generates polynomial fit of resonant frequency vs. tuner position, used by the tuner loop for feed-forward tuning table
- **"Tune Cavs"**: Automated cavity tuning sequence
- **"ConfWoofer"**: Configures woofer (sub-woofer/GVF) loop parameters for LFB interface

> **Source**: `legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md`

**Cross-ref PDF**: `ps3403305600.pdf` (4 pages) — RF Station Coupling & Cable Calibration Procedure (PS-340-330-56-R0). ⚠️ Note: This document is a cable loss measurement procedure, not a comb filter spec. Comb loop design details come from `feedbackLoopDescriptionps3403305200.pdf` (p. 5) and Corredoura SLAC-PUB-8498.

---

## 5. Ripple Loop

### 5.1 Purpose

The HVPS uses SCR (thyristor) switching, producing ripple at:
- **720 Hz** fundamental (2x6-pulse rectifier × 60 Hz)
- Harmonics up to **~50 kHz**

This ripple modulates klystron cathode voltage → gain/phase modulation of RF output → cavity field perturbation.

### 5.2 Implementation Evolution

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

> **Actual operational use (cross-referenced with PS-340-330-52-R0)**: The original Feedback Loop Description (Schwarz/Corredoura, 1999) states that the Ripple Loop "is intended to remove amplitude and phase ripple in the klystron output power but **at the time it is only utilized to keep the low bandwidth phase across the klystron and drive amplifier constant as the klystron voltage is varied**." The Ripple Loop should be ON for all normal operation. This distinction is important: the loop as deployed served primarily as a **slow phase tracker** compensating for klystron phase shift at different operating voltages, rather than performing active wideband ripple cancellation.
> **Source**: `legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md`

**DSP Hardware**: The ripple loop DSP processing was implemented on an **AT&T DSP1610** processor with serial link and parallel bus interface, housed within the VXI crate RF modules.
> **Source**: `legacy-pdf-transcriptions/block-diagrams/BD-340-330-01_PEP-II_Low_Level_RF_Configuration.md`

### 5.3 Source Code Reference

`rf_dac_loop.st,v`:
- `ripple_loop_ampl` PV: Ripple loop amplitude setpoint
- `ripple_loop_load` PV: Trigger to load ripple loop coefficients
- `ripple_loop_ready_ef` event flag: Gain tracking at slower rate than main DAC loop

**Cross-ref PDF**: `ps3403305800.pdf` (4 pages) — RF Station Cavity Phasing Procedure (PS-340-330-58-R0). ⚠️ Note: This document is a cavity phasing procedure, not a ripple loop spec. Ripple loop design details come from `feedbackLoopDescriptionps3403305200.pdf` (p. 6) and Corredoura 2000 §6.

---

## 6. Lead and Integral Compensation

### 6.1 Purpose

These analog compensation networks improve the direct loop's frequency response:

- **Lead compensation**: Adds phase lead at the loop crossover frequency to improve phase margin. Without lead comp, the group delay through the klystron and cavity would erode phase margin.

- **Integral compensation**: Adds high gain at low frequencies for zero steady-state error. Ensures the cavity field tracks the reference exactly at DC.

### 6.2 Implementation

Implemented in the **RFP module** as analog circuits:

```
Lead Compensation:     H_lead(s) = (1 + s·τ_lead) / (1 + s·τ_lead/α)
                       where α > 1 provides phase lead

Integral Compensation: H_int(s) = 1 + 1/(s·τ_int)
                       Adds integrator at low frequencies
```

### 6.3 Source Code Reference

`rf_states.st,v`:
- Lead compensation is enabled/disabled during state transitions
- `INTCOMP` (integral compensation) is turned OFF in the OFF state (per Laznovsky 2004 modification)
- Lead comp enable/disable: Part of ON_CW state entry sequence

**Cross-ref PDF**: `ps3403305700.pdf` (2 pages) — RF Station Full Power Test & Survey (PS-340-330-57-R0). ⚠️ Note: This document is a full power test procedure, not a compensation spec. Lead/integral compensation circuit details are described only in Corredoura SLAC-PUB-8498 and the source code (`rf_states.st,v`).

---

## 7. Tuner Loop (Mechanical Frequency Control)

### 7.1 Purpose

The cavity mechanical tuner adjusts the resonant frequency to optimize the impedance match. The optimal detuning angle depends on beam current:

```
Optimal detuning: Δf = -(f_RF / 2·Q_L) × (I_b·R_s·sin(φ_s)) / V_gap

where φ_s = synchronous phase angle
      I_b = beam current
```

At zero beam current, the cavity should be tuned to resonance (Δf = 0). As beam current increases, the tuner moves to compensate for the reactive beam loading.

### 7.2 Implementation

**Hardware**: SLO-SYN stepper motors (Superior Electric) driving cavity tuning plungers. Each cavity has an independent tuner.

**Control**: EPICS sequence `rf_tuner_loop.st,v` running per-cavity instances (via `CAV` macro).

**States**: `loop_init` → `loop_unknown` → `loop_off` / `loop_on` / `loop_reset`

**Key logic** (from source code analysis):
- Monitors phase angle between forward power and cavity voltage
- Adjusts tuner position to minimize phase error (bring to target detuning)
- Respects motor deadband (`RDBD`) to prevent hunting
- Handles "bad load angle" conditions (tuner at wrong position)
- Reset and set-home procedures for calibration

### 7.3 Tuner in SPEAR3 Upgrade Context

The SPEAR3 upgrade replaces the SLO-SYN stepper system with a **Galil DMC-4143** motion controller:
- Commissioned August 2025
- EPICS motor record integration
- Integration with LLRF9 phase feedback loop

**Cross-ref PDF**: `ps3403306001.pdf` (5 pages) — Bellow Cavity Phasing Procedure (PS-340-330-60-R1). ⚠️ Note: This document is a cavity phasing procedure, not a tuner loop spec. Tuner loop design details come from `feedbackLoopDescriptionps3403305200.pdf` (p. 5) and Corredoura SLAC-PUB-8498.
**Cross-ref source**: `rf_tuner_loop.st,v`, `rf_tuner_loop_defs.h`, `rf_tuner_loop_macs.h`, `rf_tuner_loop_pvs.h`

---

## 8. DAC Loop (Setpoint Adjustment)

### 8.1 Purpose

The DAC loop is the **outer supervisory loop** that adjusts the IQ reference setpoints (via Octal DACs on the RFP module) to maintain the desired drive power or gap voltage.

### 8.2 Operating Modes

From `rf_dac_loop.st,v`:

| Station State | DAC Loop Mode | Adjusts | Target |
|--------------|---------------|---------|--------|
| OFF/PARK/ON_FM | loop_off | Nothing | — |
| TUNE | loop_tune | RFP tune-mode DACs | Drive power |
| ON_CW (direct off) | loop_on | GFF references or RFP DACs | Drive power |
| ON_CW (direct on, GVF available) | loop_on | GFF I/Q references | Gap voltage |
| ON_CW (direct on, GVF unavailable) | loop_on | RFP diff node DACs | Gap voltage |

### 8.3 Control Algorithm

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

**Cross-ref PDF**: `ps3403305300.pdf` (4 pages) — RF Cavity Low Power Calibration Procedure (PS-340-330-53-R0). ⚠️ Note: This document is a cavity calibration procedure, not a DAC loop spec. DAC loop design details come from `feedbackLoopDescriptionps3403305200.pdf` (p. 6) and the source code (`rf_dac_loop.st,v`).

---

## 9. HVPS Loop (Klystron Voltage Regulation)

### 9.1 Purpose

Controls the klystron cathode voltage to regulate either:
- **Processing mode**: Gradually ramps voltage while conditioning cavities (monitoring vacuum, reflected power, and klystron forward power)
- **Operating mode**: Adjusts voltage to maintain constant drive power (in TUNE) or gap voltage (in ON_CW with direct loop)

### 9.2 Implementation

From `rf_hvps_loop.st,v`:

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

### 9.3 Key Parameters

From `rf_hvps_loop_defs.h`:
- Maximum loop idle interval: 10 seconds
- Voltage tolerance count: 10 cycles before declaring out-of-tolerance
- HVPS states: OFF (0), PROC (1), ON (2)
- Loop controls: OFF (0), PROC (1), ON (2)

**Cross-ref PDF**: `ps3403305400.pdf` (2 pages) — RF Station Safety Certification Check-Off List (PS-340-330-54-R0). ⚠️ Note: This document is a safety certification checklist, not an HVPS loop spec. HVPS loop design details come from `feedbackLoopDescriptionps3403305200.pdf` (p. 6) and the source code (`rf_hvps_loop.st,v`).
**Cross-ref source**: `rf_hvps_loop.st,v`, `rf_hvps_loop_defs.h`, `rf_hvps_loop_macs.h`, `rf_hvps_loop_pvs.h`

---

## 10. Gap Voltage Feed-Forward (GVF) — ⚠️ PEP-II ONLY

> ⚠️ **The GVF module is PEP-II hardware only. It was NOT used in the SPEAR3 legacy system (1999–2022) and is NOT present in the LLRF9 upgrade (2022–present). In SPEAR3, gap voltage control was handled by the DAC control loop in VxWorks software, not by a dedicated GVF module. There is no LFB (Longitudinal Feedback) system at SPEAR3. This section is retained for historical/reference purposes.**

### 10.1 Purpose (PEP-II)

The Gap Voltage Feed-Forward module provides:
1. **I/Q reference values** for the gap voltage setpoint (used by direct loop as the reference target)
2. **LFB woofer interface** — a fiber optic link from the longitudinal multi-bunch feedback system that provides a low-frequency "kick" signal to be summed into the station drive

### 10.2 LFB Woofer (Longitudinal Feedback Integration) — PEP-II

From Corredoura SLAC-PUB-8498:

> "A wideband fiber optic connection to the longitudinal feedback system allows a RF station to operate as a powerful 'sub-woofer' to damp residual low order coupled bunch motion."

The longitudinal feedback system (designed by Fox, Teytelman et al.) operates bunch-by-bunch at high bandwidth. For low-order modes (modes 0-10), the feedback system sends a signal via fiber optic to the LLRF, which modulates the station's drive to provide additional damping.

### 10.3 TAXI Error Recovery — PEP-II

The GVF module includes TAXI (serial data link) error monitoring. A TAXI error indicates loss of synchronization with the fiber optic link. From `rf_msgs.st,v`:

```
kludge sequence to monitor the state of the taxi error bit
and resync the LFB if it's set
```

**Note**: This code exists in the SPEAR3 legacy software (`rf_msgs.st,v`) but the TAXI link was never connected at SPEAR3.

**Cross-ref PDF**: `ps3403305900.pdf` (7 pages) — RF Station Turn-On Procedure (PS-340-330-59-R0). ⚠️ Note: This document is a station turn-on procedure (including EPICS panel screenshots), not a GVF module spec. GVF design details come from `feedbackLoopDescriptionps3403305200.pdf` (pp. 6-7) and Corredoura SLAC-PUB-8498.

---

## 10a. Optimized Station Phasing Routine

A MATLAB optimization routine (**"Phase Stns"** button on EPICS Feedback panel) sets the correct phase for each station for maximum voltage gain. Key parameters:

| Parameter | Value |
|-----------|-------|
| Minimum beam current required | **100 mA** |
| Phase step size | **1/2 degree maximum** per iteration |
| Number of iterations | **10** |
| HER reference station | **8-3** (alternate: 12-3 if 8-3 is off) |
| LER reference station | **4-4** |

The routine equalizes the power contribution of each operational station in a ring by changing the station phase. One station per ring is designated as the fixed-phase reference. If optimum phasing is not achieved in one pass, the routine can be repeated.

> **Note**: This routine is **PEP-II multi-station specific** — it is not applicable to the SPEAR3 single-station configuration.
> **Source**: `legacy-pdf-transcriptions/design-specifications/PS-340-330-52_LLRF_Feedback_Loop_Description.md`, "Optimized Station Phasing Routine"

## 10b. Cavity Processing Procedure Parameters

From PS-340-330-59 (Turn-On Procedure), the cavity processing limits are:

| Parameter | HER FM | HER CW | LER FM | LER CW |
|-----------|--------|--------|--------|--------|
| Max Cavity Vacuum | 1×10⁻⁸ Torr | 1×10⁻⁸ Torr | 1×10⁻⁸ Torr | 1×10⁻⁸ Torr |
| Max Cavity Gap Voltage | 800 kV | 750 kV | 900 kV | 850 kV |
| Max Klystron Fwd Power | 540 kW | 450 kW | 330 kW | 290 kW |

Processing sequence: ON_FM at 1000 Hz first, then ON_CW with HVPS in PROC mode (auto voltage stepping).

> **Source**: `legacy-pdf-transcriptions/operational-procedures/PS-340-330-59_RF_Station_Turn_On_Procedure.md`

## 11. Loop Stability Analysis

### 11.1 Open-Loop Transfer Function

The overall direct loop transfer function (simplified):

```
G_OL(s) = G_gain × H_klystron(s) × H_cavity(s) × H_demod(s) × H_delay(s)

where:
  H_gain      = Adjustable baseband gain (set via Quad DAC)
  H_klystron  = Klystron transfer function (nonlinear, depends on V_cathode)
  H_cavity    = Cavity response: R_s / (1 + j·2·Q_L·Δω/ω₀)
  H_demod     = IQ demodulator response (essentially flat to ~5 MHz)
  H_delay     = e^(-s·τ_total) where τ_total ≈ 1 μs (cable + processing delays)
```

### 11.2 Stability Margins

The total loop delay (τ_total ≈ 1 μs) limits the achievable bandwidth:

```
Maximum stable bandwidth ≈ 1 / (4 × τ_total) ≈ 250 kHz
```

With lead compensation, the actual crossover frequency can be pushed higher (~1 MHz) while maintaining adequate phase margin (>30°).

### 11.3 Rivetta Simulation Model

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

## 12. Cross-Reference to Legacy PDFs

| PDF File | Pages | Verified Content (OCR-confirmed) |
|----------|-------|----------------------------------|
| `feedbackLoopDescriptionps3403305200.pdf` | 8 | **LLRF Feedback Loop Description (PS-340-330-52-R0)** — CRITICAL: describes all loops (Direct, Comb, Tuner, HVPS, DAC, Ripple, Gap FF, LFB Woofer). This document is the primary source reconstructed in this technical note |
| `ps3403305200.pdf` | 8 | Same as above (duplicate copy) |
| `ps3403305100.pdf` | 11 | **RF System Description (PS-340-330-51-R0)** — system overview, parameter tables, station layouts |
| `ps3403305300.pdf` | 4 | **Cavity Low Power Calibration Procedure (PS-340-330-53-R0)** — cold cavity measurement |
| `ps3403305400.pdf` | 2 | **Safety Certification Check-Off List (PS-340-330-54-R0)** — waveguide flange torque, interlock test |
| `ps3403305503.pdf` | 4 | **Safety Survey (PS-340-330-55-R3)** — station safety survey form |
| `ps3403305600.pdf` | 4 | **Coupling & Cable Calibration Procedure (PS-340-330-56-R0)** — cable loss data at 476 MHz |
| `ps3403305700.pdf` | 2 | **Full Power Test & Survey (PS-340-330-57-R0)** — klystron full-power test with SHORT plate |
| `ps3403305800.pdf` | 4 | **Cavity Phasing Procedure (PS-340-330-58-R0)** — cavity-to-beam phase optimization |
| `ps3403305900.pdf` | 7 | **Turn-On Procedure (PS-340-330-59-R0)** — complete startup sequence, EPICS panel screenshots |
| `ps3403306001.pdf` | 5 | **Bellow Cavity Phasing Procedure (PS-340-330-60-R1)** — fine-tune cavity phase |
| `ps3403306102.pdf` | 13 | **Non-Ionizing Radiation Safety Procedure (PS-340-330-61-R2)** — NIR survey, waveguide pressurization |
| `bd3403300000.pdf` | 1 | **PEP-II LER RF Station block diagram (BD-340-330-00)** — top-level station architecture |
| `bd3403300100.pdf` | 1 | **PEP-II Low Level RF Configuration (BD-340-330-01)** — VXI module interconnection |
| `blockDiagrambd3403290100-1.pdf` | 1 | **PEP-II Low Level RF block diagram** — RF modulator, amplifier chain, system I/Q |

> **⚠️ Important**: No standalone module-level design specifications (DAC loop, HVPS loop, comb filter, ripple loop, drive chain, lead/integral compensation) were found in this legacy PDF archive. All loop design details in this document are sourced from `feedbackLoopDescriptionps3403305200.pdf` (PS-340-330-52-R0), published papers (Corredoura 1999, 2000; Fox 2010; Rivetta 2007), and the legacy source code.

---

*See also: `02_VXI_HARDWARE_MODULE_REFERENCE.md` for hardware details.*
*See also: `05_CROSS_REFERENCE_INDEX.md` for complete topic mapping.*
