# PEP-II / SPEAR3 LLRF — Literature Synthesis and Operational Insights

**Document Number**: LLRF-REF-005
**Version**: 1.0
**Date**: 2026-03-18

---

## 1. Source Literature Overview

This document synthesizes key findings from the published literature on the PEP-II LLRF system and its adaptation to SPEAR3.

| # | Reference | Year | Key Contribution |
|---|-----------|------|-----------------|
| 1 | Corredoura, SLAC-PUB-8498 (PAC 1999) | 1999 | Definitive architecture description |
| 2 | Corredoura et al. (EPAC 2000), arXiv:physics/0007029 | 2000 | High-current operational experience |
| 3 | Fox et al., Phys. Rev. ST AB 13:052802 | 2010 | Comprehensive lessons learned |
| 4 | Rivetta et al., Phys. Rev. ST AB 10:022801 | 2007 | Time-domain simulation and stability |
| 5 | McIntosh, SLAC-PUB-10083 (PAC 2003) | 2003 | 476 MHz cavity processing for SPEAR3 |
| 6 | McIntosh, SLAC-PUB-11017 | 2005 | SPEAR3 RF system configuration |
| 7 | Schwarz & Rimmer (PAC 1994) | 1994 | Original PEP-II RF system design |
| 8 | Park & Corbett (IPAC 2010) | 2010 | SPEAR3 booster RF upgrade |
| 9 | Pedersen, SLAC-400 (1992) | 1992 | RF cavity feedback theory |
| 10 | Allison & Claus (PAC 1997) | 1997 | EPICS operator interface |

---

## 2. Corredoura SLAC-PUB-8498 (1999) — Architecture Paper

### Key Insights

1. **VXI-based modular design** using EPICS IOC on VxWorks. The system is "fully programmable" with "EPICS based sequences make the entire system a turn-key operation requiring minimal operator intervention."

2. **IQ baseband processing** with both analog (RFP module) and digital (IQA modules) techniques. The analog domain handles fast feedback loops; the digital domain provides precision measurement and diagnostics.

3. **Built-in diagnostics**: Each station incorporates a network analyzer (sweeps loop transfer functions in-situ) and arbitrary waveform generator (for FM cavity processing). Matlab interface enables automated loop configuration.

4. **Transient recorders**: Circular history buffers capture RF signals during normal operation. On fault, buffers freeze and data is saved to disk files. This "post-mortem analysis capability has proven to be extremely beneficial."

5. **Wideband fiber optic link**: Connects to the longitudinal feedback system for "sub-woofer" operation — the RF station provides additional damping of low-order coupled-bunch modes.

6. **Cavity tuner management**: Special attention to ion clearing gap transients — tuner detuning must be optimized differently for HER (matched gaps) and LER (unmatched gaps due to shorter ring).

### Architecture Figures Referenced

- **Fig. 1**: VXI crate topology (slot assignments, signal connections) — corresponds to `bd3403300000.pdf`
- **Fig. 3**: Complete feedback loop block diagram — corresponds to `feedbackLoopDescriptionps3403305200.pdf`

---

## 3. Corredoura et al. (EPAC 2000) — High-Current Experience

### Key Operational Findings

1. **Station cycle time reduction**: Original "slow turn-on" took 3 minutes. Fast turn-on (< 20 seconds) was developed by presetting tuner positions, loop gains, and IQ references to no-beam values, then applying klystron voltage directly. Critical for recovering from beam aborts at > 300 mA.

2. **Baseband voltage problem**: Gilbert-cell multipliers in the baseband modulator can invert output polarity when over-driven (> ±1V input). This caused "positive feedback around the direct RF feedback loop" during fast turn-on attempts.

   **Solution**: Soft limiter circuit — back-to-back 1N4157 Schottky diodes across 50kΩ feedback resistor with 100Ω series resistor.

3. **Klystron gain tracking trade-off**: In the LER, klystron power ranges from 250 kW (no beam) to 1.2 MW (full beam) — a 7 dB range. The baseband modulator gain must compensate, but this forces higher multiplier input voltages, reducing headroom for transient handling.

   **Quantified**: At maximum modulator gain (no-beam), IQ voltages should be at half-scale. During saturation events, drive power could exceed 4× desired value.

4. **Klystron overdrive protection**: Proposed drive power limiting circuit using IQA linear detector. If detected power exceeds programmable setpoint, both I and Q signals are reduced proportionally (maintaining phase) to keep klystron below saturation curve peak.

5. **Ripple loop limitation**: DSP-based digital ripple cancellation was intended but proved challenging (delay + 50 kHz bandwidth). Analog integrator in direct loop works but "simulations show it will cause instability as beam currents reach 2A."

6. **Measured klystron saturation curves**: Fig. 7 in the paper shows measured saturation curves at different cathode voltages (55, 60, 65 kV), with suggested operating points well below the saturation knee.

---

## 4. Fox et al. (Phys. Rev. 2010) — Lessons Learned

### Key Findings

1. **Growth rates exceeded design**: PEP-II ended operation with "longitudinal instability growth rates roughly 5X in excess of the original design estimates." The feedback systems had to be continuously adapted.

2. **DSP filter design evolution**: The longitudinal feedback uses 6-tap FIR filters optimized per-bunch. The filter provides ~35 dB gain at the synchrotron frequency (6.5 kHz for HER) with 90° net phase shift including system delays. Gain at DC (720 Hz) is ~28 dB below operating gain.

3. **Unanticipated signal**: Impulsive RF power supply noise (or phase reference noise) at amplitudes of "a few A/D counts" excited barycentric motion (mode zero) at high amplitude, saturating the broadband feedback channel. This was identified through the transient recorder fault file system.

4. **Mode zero saturation**: The broadband feedback system's fixed gain meant that large mode-zero excitation (from power supply transients) could saturate the DAC output, reducing available gain for other modes. This was a key limiting factor at highest currents.

5. **Nonlinear processing elements**: The significance of saturation effects, limiting circuits, and nonlinear klystron gain was much greater than originally anticipated. The Rivetta simulation model (see below) was essential for understanding these effects.

6. **Ultimate performance**: PEP-II achieved 1.2×10³⁴ luminosity — 4× design. The LLRF and longitudinal feedback systems were critical enablers, but required continuous adaptation beyond the original design.

---

## 5. Rivetta et al. (Phys. Rev. 2007) — Simulation Model

### Model Description

A **time-domain dynamic simulation** capturing:
- Beam represented as macrobunches
- Multiple RF stations → one or two "macrocavities"
- Cavity dynamics (including detuning, coupling, beam loading)
- LLRF loops: direct, comb, ripple, tuner
- Klystron nonlinearity (saturation curve)
- Signal processing chain (including limiting circuits)
- HVPS ripple

### Key Results

1. **Validated LLRF design**: Simulation growth rates matched measured growth rates from PEP-II operation.

2. **Stability limits explored**: At increased currents, the ultimate limit is set by the interaction between:
   - Direct loop phase margin (eroded by increased gain requirements)
   - Comb loop gain at low-order revolution harmonics
   - Nonlinear effects in the klystron and signal processing

3. **Control strategy comparison**: Different feedback configurations were compared, showing that the combination of direct + comb loops is essential; neither alone provides sufficient stability at PEP-II currents.

4. **Imperfection sensitivity**: The simulation revealed that small imperfections in LLRF signal processing (offsets, gain imbalances, delay mismatches) can significantly reduce stability margins at high currents.

---

## 6. McIntosh (2003, 2005) — SPEAR3 RF System

### Key Information for SPEAR3

1. **Configuration**: SPEAR3 RF system is "essentially a PEP-II high energy ring (HER) RF station operating at 476.3 MHz and 3.2 MV (or 800 kV/cavity)."

2. **Cavity specifications**: 
   - PEP-II type single-cell copper cavities
   - HOM-damped design
   - Tuned to 476.3 MHz (slightly higher than PEP-II's 476.0 MHz)
   - Manufactured by ACCEL Instruments GmbH (Germany)

3. **Cavity processing**: Each cavity is RF-processed at SLAC's test facility:
   - FM processing first (frequency sweep across cavity resonance)
   - CW processing up to 850 kV gap voltage
   - Automated LabVIEW control for conditioning
   - Vacuum activity monitoring

4. **System installation**: Completed November 2003; 3.2 MV achieved "very rapidly" after installation.

5. **Klystron**: 1.2 MW CW klystron powering 4 cavities via WR2100 waveguide network with circulator.

---

## 7. Broader Context: RF Cavity Feedback Theory

### Pedersen (1992) — Foundational Theory

F. Pedersen's SLAC-400 report (1992) provides the theoretical foundation for the PEP-II LLRF design:

1. **Robinson instability**: Occurs when the beam-loaded generator impedance has a negative real part at the synchrotron frequency. The growth rate is proportional to:
   ```
   τ⁻¹ ∝ I_b × Re[Z_eff(ω_s)]
   ```

2. **Impedance reduction via feedback**: Direct RF feedback reduces the effective impedance:
   ```
   Z_eff = Z_cav / (1 + G)
   ```
   where G is the open-loop gain.

3. **Optimal detuning**: For minimum transient excitation from the ion clearing gap, the cavity should be detuned such that the reactive beam loading is minimized. The optimal detuning angle depends on beam current.

4. **Coupled-bunch modes**: At revolution harmonics, the cavity impedance drives coupled-bunch instabilities. The comb feedback provides additional suppression at these specific frequencies.

---

## 8. Design Trade-offs and Known Limitations

### 8.1 Analog vs Digital Processing

| Aspect | Analog (PEP-II VXI) | Digital (LLRF9 replacement) |
|--------|---------------------|-----------------------------|
| Bandwidth | ~1 MHz (direct loop) | ~1 MHz (FPGA processing) |
| Latency | ~1 μs (analog) | Comparable (FPGA pipeline) |
| Dynamic range | Limited (±1V multiplier range) | 14-bit ADC (>80 dB) |
| Flexibility | Fixed architecture | Fully reconfigurable |
| Diagnostics | Built-in IQA + network analyzer | Per-channel waveform recording |
| Calibration | Manual (rf_calib.st, ~3 min) | Automatic/built-in |
| Reliability | Aging components, limited spares | Modern, supported |

### 8.2 Operational Risk Summary

| Risk | Severity | Mitigation |
|------|----------|------------|
| Multiplier overdrive → positive feedback | Critical | Limiting diodes (1N4157) |
| Cavity probe signal loss → drive saturation | Critical | Drive power limiter |
| Klystron saturation → loop instability | High | Gain tracking + saturation loop |
| HVPS ripple → field modulation | Medium | Ripple loop (analog integrator) |
| Comb filter misconfiguration | Medium | Automated calibration (rf_calib.st) |
| TAXI link failure → LFB disconnect | Low | TAXI error recovery (rf_msgs.st) |
| Tuner motor failure → detuning drift | Medium | Load angle monitoring + fault alarm |

### 8.3 PEP-II to SPEAR3 Adaptation Notes

- SPEAR3 operates at **significantly lower beam current** (500 mA vs 1.8–3.0 A), so beam loading effects are less severe
- **Single-station operation** means no inter-station coordination is needed, but also no redundancy
- The **revolution frequency is higher** (1.28 MHz vs 136.3 kHz), which affects comb filter delay requirements
- **Fill pattern** (276 bunches in 4 groups + camshaft) creates different transient characteristics than PEP-II
- **Top-off injection** mode (every 5 minutes) creates periodic beam current perturbations

---

## 9. Operational Insights from SPEAR3 System Documentation

> **Source**: `llrf/documentation/LLRFOperation_jims.docx` (J. Sebek — SPEAR3 RF Station Operation); `llrf/documentation/fiberOpticCableSignalControlRev3.docx`

### 9.1 Control Hierarchy and Modes

The SPEAR3 LLRF system operates in four modes: **ON_CW** (normal), **TUNE** (testing), **PARK** (unused, PEP-II heritage), and **ON_FM** (cavity processing, never used at SPEAR3).

**Normal operation (ON_CW)** involves three nested control loops:

1. **Fast analog control** (RFP module, ~MHz bandwidth): IQ decomposition of 4 cavity probe signals, error correction, RF drive reconstruction — almost entirely analog signal processing
2. **DAC Control Loop** (VxWorks, ~1 Hz update): Monitors total gap voltage (sum of 4 cavities), adjusts `SRF1:STN:ON:IQ` to control RFP output amplitude. Ultimate goal: maintain total gap voltage at setpoint.
3. **HVPS Loop** (VxWorks, ~0.5 Hz update): Monitors `SRF1:KLYSDRIVFRWD:POWER`. When drive power exceeds setpoint (e.g., `SRF1:KLYSDRIVFRWD:POWER:ON`), increases `SRF1:HVPS:VOLT:CTRL.VAL` to raise klystron gain and reduce required drive power.

**TUNE mode** disables the DAC control loop and most feedback loops. Used for bringing up the system after klystron replacement or HVPS refurbishment. Key step: may need to adjust `SRF1:STNDIRECT:LOOP:PHASE.C` to compensate for phase differences between old and new klystrons.

### 9.2 RF Station Turn-On Sequence

From Jim Sebek's operational notes, the turn-on sequence proceeds:

1. **Tuners positioned**: Move to `SRF1:CAV1TUNR:POSN:ONHOME` (TUNE/ON Home position)
2. **HVPS powered**: Set to Turn-On Voltage `SRF1:HVPS:VOLT:MIN` (typically 50 kV)
3. **DAC initialized**: Set to `SRF1:STN:ONFAST:INIT` (typically 100 counts) → few watts of drive power → few hundred kV gap voltage
4. **Tuner feedback starts**: Phase difference between forward power and cavity probe now measurable → tuner loop can regulate
5. **DAC increases to ~200**: Slightly raises drive power
6. **Direct loop closed**: Analog integrator switch engaged → causes transient (drive power spikes to ~45 W before settling to ~10 W). This is done at low HVPS voltage so klystron output peaks at only ~50 kW (safe level)
7. **Slow loops activated**: DAC and HVPS control loops start ramping over 10–20 seconds
8. **Steady-state reached**: Gap voltage at setpoint, drive power at setpoint, HVPS voltage adjusted for operating point

**Critical parameters during turn-on**:
- `SRF1:STNDIRECT:LOOP:COUNTS.A` — Loop Gain (amplitude feedback)
- `SRF1:STNDIRECT:LOOP:PHASE.C` — Loop Phase (compensates electronic delays)

### 9.3 Tuner Operation Details

The cavity tuner system keeps each cavity resonant at the desired frequency (slightly below f_RF for Robinson stability). Key operational characteristics:

- **Sensing**: Phase difference between forward power coupler signal and cavity probe signal
- **Total tuner travel**: ~2.5 mm from home to ON position (1 revolution of lead screw = 2 motor revolutions)
- **Normal operation motion**: ~0.2 mm (fine adjustments due to thermal drift, beam current changes)
- **Position sensing**: Linear potentiometers provide approximate position readback (not in any feedback loop)
- **"Stop and init" feature**: Aligns internal step counter with potentiometer reading without moving tuner
- **No encoders**: Legacy system has no absolute position feedback — relies on step counting from a reference position

### 9.4 HVPS Protection Philosophy

From `fiberOpticCableSignalControlRev3.docx`, the HVPS protection design philosophy is:

1. **Primary protection**: Inhibit SCR triggers (removes power source) — response time ~100 ms to <10% power
2. **Secondary protection**: Fire crowbar (dissipates stored energy in capacitors) — needed only for arc conditions
3. **Passive protection**: 2Ω series resistors on output capacitors + series inductors in termination tank limit peak fault currents to safe levels even without crowbar

**Key insight**: The PEP-II HVPS was designed with sufficient passive protection that the klystron is safe even if the crowbar completely fails. The crowbar reduces delivered energy from ~16 J to ~4 J, both well below the 20 J damage threshold. This defense-in-depth approach provides very high reliability for klystron protection.

### 9.5 Known Limitations and Design Compromises

1. **Tuner reliability**: Stepper motors (M093-FC11) and PWM drivers (SS2000MD4-M) are obsolete. No encoders means position knowledge depends on step counting — any lost steps accumulate as error.
2. **Communication bottleneck**: All AB communication passes through a single serial chain. Failure of any DCM module can isolate downstream controllers.
3. **Arc detection**: Original PEP-II fiber optic arc detectors were never commissioned. System has operated for 20+ years without waveguide arc protection.
4. **Collector power protection**: Current software-based monitoring (~1 Hz in EPICS) is much slower than the thermal time constant of collector damage. The LLRF9 + Waveform Buffer upgrade addresses this with hardware-speed monitoring.

---

## 9a. Quantitative Operational Data from Legacy Procedures (Transcription Cross-Reference)

The following quantitative data is extracted from the newly available legacy PDF transcriptions (v2, 450 DPI OCR). These values represent the actual PEP-II operational parameters and calibration constants.

### 9a.1 Cavity Low Power Calibration Constants (PS-340-330-53)

| Parameter | Value | Notes |
|-----------|-------|-------|
| Nominal probe coupling | **99.6 dB** | Modified by per-cavity low-power test data |
| Sampling loop power formula | Ps/Pinc = −51.8 dB + 10·log(Q₀/30000) + 10·log[4β/(1+β)²] + 0.6 dB | At 150 kW wall dissipation |
| Example (Q₀=34000, β=4.0) | Ps/Pinc = **−52.6 dB** | |
| Tightening compensation | **−0.5 dB** | Added before loop tightening |
| Acceptable variation | **±0.3 dB** | After tightening |
| Temperature correction | **−7.95 kHz/°C** | Correction to 35°C reference |
| Vacuum correction | **+124 kHz** | Correction for vacuum vs N₂ atmosphere |
| Target resonant frequency | **476,000 + 100 kHz** at 35°C & vacuum | |
| Fixed tuner sensitivity | **30 kHz/mm** | ±2/−3 mm nominal range |
| Movable tuner nominal position | **8 mm insertion** | Operating set point |
| Teststand calibration | **−51.2 dB** | Gives 1.14 W at probe for 150 kW at Q₀=30000 |

> **Source**: `legacy-pdf-transcriptions/operational-procedures/PS-340-330-53_RF_Cavity_Low_Power_Calibration.md`

### 9a.2 Signal Path Calibration Data (PS-340-330-56)

Nominal coupling and loss values for all RF signal paths at 476 MHz:

| Signal Path | Coupling (dB) | Cable Loss (dB) | IQ Conversion Loss (dB) |
|-------------|:---:|:---:|:---:|
| Cavity probe | 99.6 | 1.0 | 13.15 |
| Cavity forward coupler | 60.0 | 1.0 | 13.15 |
| Cavity reflected coupler | 60.0 | 1.0 | 13.15 |
| Klystron forward coupler | 30.0 | 1.0 | 13.15 |
| Klystron reflected coupler | 60.0 | 1.0 | 13.15 |
| Circulator load forward | 60.0 | 4.0 | 13.15 |
| Circulator load reflected | 60.0 | 4.0 | 13.15 |
| Magic Tee load forward/reflected | 60.0 | 1.0–4.0 | 13.15 |
| Klystron drive forward | 30.0 | 1.0 | 13.15 |

**Measurement method**: HP 8648 signal generator with 10 dB matching attenuator → 0 dBm through Heliax cable → HP 435 power meter at far end.

> **Source**: `legacy-pdf-transcriptions/operational-procedures/PS-340-330-56_RF_Station_Coupling_Cable_Calibration.md`

### 9a.3 Safety and Radiation Limits (PS-340-330-54, PS-340-330-55, PS-340-330-57, PS-340-330-61)

| Parameter | Limit | Standard/Reference |
|-----------|-------|-------------------|
| Non-ionizing RF radiation (at 100 kW) | **< 0.1 mW/cm²** | ANSI C95.1-1982 |
| Non-ionizing RF radiation (at full 1.2 MW) | **< 1.5 mW/cm²** | ANSI C95.1-1982 (personnel hazard threshold) |
| Ionizing radiation (klystron, at 30 cm) | **< 5 mR/hr** | SLAC standard |
| Ionizing radiation (klystron, on contact) | **< 100 mR/hr** | Per PS-340-330-55-R3 |
| Waveguide flange torque | **> 25 ft-lbs** (cert.), **30 ft-lbs** (NIR proc.) | On 6 random accessible bolts |
| Waveguide pressurization | **0.25 psig** | Interlock threshold |
| Annual re-certification | Required | After major repair or downtime |
| Personnel requirement during certification | **RWT-I certified** | All personnel in klystron radiation area |

> **Sources**: `legacy-pdf-transcriptions/operational-procedures/PS-340-330-54_RF_Station_Safety_Certification.md`, `PS-340-330-55_RF_Station_Safety_Survey.md`, `PS-340-330-57_RF_Station_Full_Power_Test.md`, `PS-340-330-61_RF_Non_Ionizing_Radiation_Safety.md`

### 9a.4 Station Turn-On Parameters (PS-340-330-59)

| Parameter | Value |
|-----------|-------|
| Filament warmup timer | **30 min** (interlocks can be cleared after timer expires) |
| Park frequency offset | **+340 kHz** from resonance |
| Auto reset tries (max) | **25 resets** |
| Beam operation loop sequence | Ripple Loop → Direct Loop → Comb Loop (automatic) |
| HVPS manual reset interlocks | Crowbar, transformer overtemp, waveguide pressure, beam abort |
| Manual reset location | HVPS SMART TOUCH panel, rack 2 |

> **Source**: `legacy-pdf-transcriptions/operational-procedures/PS-340-330-59_RF_Station_Turn_On_Procedure.md`

### 9a.5 Cavity Phasing Parameters (PS-340-330-58, PS-340-330-60)

| Parameter | Value |
|-----------|-------|
| PEP waveguide electrical spacing | **27.6 inches** (PEP standard) |
| Bellow adjustment sensitivity | **0.085 inch/degree** |
| Phase correction rule (positive ΔPhase) | Make bellow **shorter** |
| Phase correction rule (negative ΔPhase) | Make bellow **longer** |
| Load Angle Offset min beam current | Per "Min Beam Curr (mA)" panel setting |
| Tuner position range | −30.000 to +20.000 mm |
| Typical fixed tuner temperature | 36–38°C (operating) |
| Typical movable tuner temperature | 33–39°C (operating) |

> **Note**: Bellow #1 adjustment for cavity C also shifts cavity D — counter-adjustment of bellow #3 is required.

> **Sources**: `legacy-pdf-transcriptions/operational-procedures/PS-340-330-58_RF_Station_Cavity_Phasing.md`, `PS-340-330-60_Bellow_Cavity_Phasing.md`

### 9a.6 Full Power Test Configuration (PS-340-330-57)

For full-power klystron testing: a **SHORT** circuit plate is installed between the circulator and first Magic-Tee. All 1.2 MW klystron power is reflected into the circulator load. This configuration produces **no RF power in cavities** and therefore **no ionizing radiation in the tunnel**. The test validates:
- HVPS operation up to 1.2 MW
- Klystron full-power performance
- Circulator load thermal capacity
- Waveguide integrity under full power

> **Source**: `legacy-pdf-transcriptions/operational-procedures/PS-340-330-57_RF_Station_Full_Power_Test.md`

## 10. Published Literature Reference List

### 10.1 Primary PEP-II LLRF References

| Ref | Authors | Title | Source | Year |
|-----|---------|-------|--------|------|
| [1] | Corredoura, P.L. | Architecture and Performance of the PEP-II Low-Level RF System | SLAC-PUB-8498 | 1999 |
| [2] | Corredoura et al. | Experience with the PEP-II RF System at High Beam Currents | arXiv:physics/0007029 | 2000 |
| [3] | Fox, J. et al. | Lessons Learned from PEP-II LLRF and Longitudinal Feedback | Phys. Rev. ST Accel. Beams 13, 052802 | 2010 |
| [4] | Rivetta, C. et al. | Modeling and Simulation of Longitudinal Dynamics for LER-HER at PEP-II | Phys. Rev. ST Accel. Beams 10, 022801 | 2007 |
| [5] | Teytelman, D. | Beam Loading Compensation for Super B-Factories | PAC 2005, TOAC002 | 2005 |
| [6] | Cassel, R. & Nguyen, M. | A Unique Power Supply for the PEP-II Klystron at SLAC | SLAC-PUB-7591 | 1997 |

### 10.2 Foundational Theory

| Ref | Authors | Title | Source | Year |
|-----|---------|-------|--------|------|
| [7] | Robinson, K.W. | Stability of Beam in Radiofrequency System | CEA-11, Cambridge Electron Accelerator | 1964 |
| [8] | Wilson, P.B. | Fundamental-Mode RF Design in e+e- Storage Ring Factories | SLAC-PUB-6062 | 1993 |

### 10.3 SPEAR3 System References

| Ref | Authors | Title | Source | Year |
|-----|---------|-------|--------|------|
| [9] | McIntosh, P. | The SPEAR3 RF System | SLAC-PUB-11017 | 2005 |
| [10] | Hettel, R. et al. | SPEAR 3 Design Report | SLAC-R-609 | 2002 |
| [11] | Park, S. & Corbett, J. | Booster Synchrotron RF System Upgrade for SPEAR3 | IPAC 2010 | 2010 |

---

*See also: `00_PEP-II_SPEAR3_LLRF_SYSTEM_REFERENCE.md` for system overview.*
*See also: `01_FEEDBACK_LOOP_ARCHITECTURE.md` for loop details and mathematical framework.*
*See also: `02_VXI_HARDWARE_MODULE_REFERENCE.md` for hardware architecture including upgrade subsystems.*
