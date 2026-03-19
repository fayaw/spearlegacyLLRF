# Signal Processing & Physics Algorithms

**Document**: 08 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**(Rev 4 — corrected systematic +1 line number offset in all 11 subSys.c function references; lines now point to function signatures)**
**(Rev 3 — formula-level audit: corrected 13 formula/description errors against source code)**

---

## UPGRADE CONTEXT

subIQ.c and subSys.c contain **pure-math functions** with no hardware dependencies. These are the most directly reusable components in the codebase.

**Evaluation question**: Which of these functions are needed in the upgrade EPICS softIOC and high-level Python applications?

- Functions that compute quantities the **LLRF9 now handles internally** (I/Q processing, phase detection, amplitude calculation) may be redundant — the LLRF9 provides these as PV readbacks.
- Functions that compute **system-level quantities** (klystron gain, reflected power ratio, beam loading) are likely still needed in the coordinator or MATLAB tools.
- Functions that compute **calibration parameters** may be handled by Dmitry's LLRF9 calibration software.

The coordinator operates at ~1 Hz and reads LLRF9 PVs (10 Hz scalars, 16k waveforms). It does NOT need to reimplement fast-loop algorithms.

---

## 1. Overview

The signal processing layer consists of two C source files containing pure-math subroutine record functions. These are the **most directly reusable** components in the entire codebase — they have no hardware dependencies and can be ported to any EPICS version with minimal changes.

---

## 2. subIQ.c — I/Q Signal Processing (965 lines, 23 functions)

### 2.1 Function Catalog

> **Rev 3 note**: Seven entries in this table were corrected after formula-level audit against the actual C source code. Corrections marked with ✦.

| Function | Line | Inputs | Output | Equation |
|----------|------|--------|--------|----------|
| `subIQinit` | 111 | — | OK | Initialization (no-op) |
| `subIQphase` | 123 | A=I, B=Q | degrees | `atan2(Q, I) × 180/π` |
| `subIQampl` | 149 | A=I, B=Q, C=scale | scaled amp | `sqrt(I² + Q²) × scale` |
| ✦ `subIQampl2conv` | 175 | A=ref_ampl(counts), B=prev_const, C=gap_voltage(kV), D=severity, E=loop_gain, F=min_voltage | Counts/kV | `A / (C × (1 + E))` — RF drive calibration constant. Returns previous value (B) if inputs invalid. |
| ✦ `subIQamplStn` | 207 | A–D = cavity probe voltages (kV) | station kV | `A + B + C + D` — arithmetic sum of in-phase cavity voltages |
| ✦ `subIQamplCplg` | 218 | A=fwd_ampl(kV), B=refl_ampl(kV), C=min_fwd(kV), D=max_ratio | coupling | VSWR formula: `(1 + r) / (1 − r)` where `r = B/A` (reflected/forward amplitude ratio). Guarded: requires A ≥ C and r < D. |
| ✦ `subIQampl2loss` | 245 | A=amplitude(V), B=severity, C=prev_loss, D=multiplier(20), E=power_conv(0.31623), F=calib_power(mW), G=station_state | dB | `D × log10(E × sqrt(F) / A)` — calibrated RF detector conversion loss. Requires station OFF (G<0.0001), valid amplitude (B<2.5), and non-zero inputs. Returns previous loss (C) if invalid. |
| `subIQampl2iq` | 274 | A=value, B=phase(°), C=conv_factor, D=roundoff_flag | I, Q counts | `VAL = A×C`, `I = VAL×cos(B×π/180)`, `Q = VAL×sin(B×π/180)` with count-limit checking |
| ✦ `subIQpower` | 308 | A=I, B=Q, C=IQ_scale, E=power_conv, F=state, G=meas_ampl, H=ampl_scale, J=smoothing | power or ampl | State-dependent: if ON_FM uses measured amplitude (G×H), else computes `sqrt(A²+B²)×C`. Applies exponential smoothing (J). If E>0: outputs `(smoothed/E)²` (power); else outputs smoothed amplitude directly. |
| `subIQpowerNet` | 352 | A=Pfwd, B=Prefl | net power | `Pfwd − Prefl` |
| `subIQpowerEff` | 368 | A=Pout, B=Pin | efficiency | `Pout / Pin × 100` |
| `subIQpower2gain` | 386 | A=Pout, B=Pin | gain dB | `10 × log10(Pout/Pin)` |
| ✦ `subIQpower2ampl` | 413 | A=scale, B=state, C=ON_FM_input, F=power_conv, G=default_input, H=max_volt_flag, I=alarm_pct | amplitude (V) | State-dependent input selection: J=C if ON_FM and C>0, else J=G. Alarm limits: K=J×I/100, L=J×(100+I)/200. If H<0.0001: power mode (F>0) gives `VAL=(F×sqrt(J))/A`, amplitude mode gives `VAL=J/A`, enforced within HOPR/LOPR. If H≥0.0001: `VAL=H` (max voltage override). |
| `subIQphaseOffsU` | 467 | A=phase, B=offset, C=flag | unadj phase | Phase offset calculation with wrapping |
| `subIQphaseOffs` | 542 | A=phase, B=offset | adj phase | `phase + offset` (with ±180° wrap) |
| `subIQphaseErr` | 566 | A=measured, B=setpoint | error | `measured − setpoint` (with ±180° wrap) |
| `subIQphase2posn` | 586 | A=phase, B=gain, C=offs | position | `phase × gain + offset` |
| `subIQdac` | 620 | A=ampl, B=phase, C=mode | DAC counts | I/Q matrix DAC calculation |
| ✦ `subIQcounts` | 653 | A=gain(0–1), B=actual(kV/W), C=desired(kV/W), D=conv_factor, E=deadband, F=max_delta, G=min_threshold, H=loop_gain | delta counts | Proportional controller: `VAL = A × (C−B) × D×(1+H)`. Only applied when B>G and |error|>E. Clamped to ±F. Outputs K=error, L=adjusted conversion factor. |
| `subIQcorrected` | 698 | A=raw_I, B=raw_Q, corrections | corrected I,Q | Directivity correction matrix application |
| `subIQscaled` | 731 | A=raw_I(counts), B=raw_Q(counts), I=conv_loss_factor | scaled V | `J = A×IQ2VOLTS×I`, `K = B×IQ2VOLTS×I`. Returns ERROR if data not ready or overflowed. |
| `subIQgetInit` | 769 | record fields | OK | One-time init for IQ data acquisition |
| `subIQget` | 817 | record fields | OK | Read I/Q data from hardware |

### 2.2 Key Physics Formulas

> **Rev 3 note**: Coupling factor formula corrected from power-based to VSWR voltage-based per source code audit.

**Phase from I/Q**:
```c
phase = atan2(Q, I) * 180.0 / PI;
// Range: -180° to +180°
```

**Amplitude from I/Q**:
```c
amplitude = sqrt(I*I + Q*Q) * scale_factor;
```

**Power from I/Q** (state-dependent — see subIQpower):
```c
// If NOT in ON_FM state:
raw_ampl = sqrt(I*I + Q*Q);
scaled_ampl = raw_ampl * IQ_scale;
// If in ON_FM state: use measured amplitude instead
smoothed = scaled_ampl * (1 - J) + prev_smoothed * J;  // exponential filter
if (power_mode)
    power = (smoothed / E) * (smoothed / E);
else
    output = smoothed;  // amplitude mode
```

**Coupling Factor** (VSWR-based, subIQamplCplg):
```c
// Voltage Standing Wave Ratio formula:
r = reflected_amplitude / forward_amplitude;   // r = B/A
coupling = (1.0 + r) / (1.0 - r);             // VSWR
// Guarded: only computed if forward > minimum and r < max_ratio
```

**RF Detector Conversion Loss** (subIQampl2loss):
```c
// Computed during calibration (station OFF):
intermediate = power_conv_factor * sqrt(calib_power_mW) / amplitude_V;
loss_dB = 20.0 * log10(intermediate);
// Returns previous loss if inputs invalid
```

**Gain in dB**:
```c
gain_dB = 10.0 * log10(P_out / P_in);
```

**Phase Wrapping**:
```c
// Ensure phase is within [-180°, +180°]
while (phase > 180.0)  phase -= 360.0;
while (phase < -180.0) phase += 360.0;
```

**DAC Value Calculation** (subIQdac):
```c
// 2×2 I/Q matrix rotation for cavity coupling
DAC_II = amplitude * cos(phase) * cos(rotation);
DAC_IQ = amplitude * cos(phase) * sin(rotation);
DAC_QI = amplitude * sin(phase) * cos(rotation);
DAC_QQ = amplitude * sin(phase) * sin(rotation);
```

**Proportional Controller** (subIQcounts):
```c
// Computes DAC count change for gap voltage or drive power regulation
error = desired - actual;                         // K = C - B
conv_factor = D * (1 + loop_gain);                // L = D * (1 + H)
if (actual > min_threshold && |error| > deadband)
    delta_counts = gain * error * conv_factor;    // VAL = A * K * L
    // Clamped to ±max_delta (F)
else
    delta_counts = 0;
```

### 2.3 EPICS Subroutine Record Interface

Each function follows the standard interface:
```c
static long subIQphase(struct subRecord *psub) {
    // Inputs: psub->a through psub->l (up to 12 inputs)
    // Output: psub->val (single floating point result)
    // Additional outputs: psub->i through psub->l (if needed)
    
    double I = psub->a;
    double Q = psub->b;
    psub->val = atan2(Q, I) * 180.0 / PI;
    return OK;
}
```

Registration (via epicsRegisterFunction):
```c
epicsRegisterFunction(subIQinit);
epicsRegisterFunction(subIQphase);
epicsRegisterFunction(subIQampl);
// ... etc
```

---

## 3. subSys.c — System-Level Calculations (464 lines, 11 functions)

### 3.1 Function Catalog

> **Rev 3 note**: Six entries corrected after source-code audit. `subSysBeamCurr` removed (phantom — does not exist in source). `subSysInit` added as the actual 11th function.
> **Rev 4 note**: All 11 line numbers corrected (+1 each). Previous values pointed to the closing `*/` of the multi-line doc comment block above each function, not the `static long subSys*()` signature line. Now corrected to reference the function definition line.

| Function | Line | Description |
|----------|------|-------------|
| ✦ `subSysInit` | 110 | Initialization (no-op, returns OK) |
| ✦ `subSysFreqOff` | 115 | Polynomial frequency offset estimate from tuner position and cavity voltage: `K = p0 + p1×ΔPos + p2×ΔPos² + p3×ΔPos³ + t1×V²` where ΔPos = current − home tuner position. Applies exponential smoothing. |
| ✦ `subSysFreqErr` | 147 | Cavity park frequency error with Q-dependent scaling: `VAL = A × B × (C − D)` where A=90/(476e3×4) deg/kHz, B=loaded_Q, C=desired_park_freq, D=frequency_offset |
| `subSysFreqOAvg` | 164 | Average of 4 cavity frequency offsets: `VAL = (A+B+C+D)/4` |
| ✦ `subSysPhaseTot` | 178 | Total direct loop phase with rate-limited delta tracking: Computes delta phase from frequency offset `K = −0.000360 × group_delay × freq_offset × conv_const` (when loop and tracking on). Tracks total as `L = L + rate_limited(C + D + K − L)`, with ±180° wrap and first-time initialization. |
| `subSysPhaseCmb` | 227 | Total comb loop phase: `K = −B×C` (delta from direct loop), `VAL = A + D + K` with ±180° wrap |
| `subSysPhaseStn` | 248 | Station phase with rate-limited tracking: `VAL = L + rate_limited(A + C + D − L)` with ±180° wrap and first-time initialization |
| ✦ `subSysDCcoeff` | 277 | Ripple loop DC gain coefficient tracking: Adjusts DC coefficient based on klystron gain deviation `(desired_gain − actual_gain)`. Uses `delta = D×10^((I+L)/20) − G` with deadband limiting. Tracks gain state (on/off transitions), resets on beam abort. |
| `subSysDrivSel` | 354 | Drive power setpoint selection: Returns 1 (low beam current) or 2 (high beam current) based on klystron forward power with hysteresis |
| ✦ `subSysLog` | 387 | Logarithmic-to-linear conversion for vacuum/ion pump readings: `VAL = B × 10^A`. Also manages EPICS monitor/archive delta propagation. |
| `subSysABreset` | 430 | Allen-Bradley PLC reset: calls `ab_reset()` directly |

### 3.2 Key Algorithms

> **Rev 3 note**: All three algorithm descriptions rewritten to match actual source code.

**Frequency Offset Estimation** (subSysFreqOff):
```c
// Polynomial model from tuner position (NOT phase differentiation):
delta_pos = current_tuner_pos - home_pos;               // I = G - F
poly_term = p0 + p1*delta_pos + p2*delta_pos^2 + p3*delta_pos^3;  // J
raw_offset = poly_term + temp_coeff * cavity_voltage^2;  // K = J + E*H*H
// Exponential smoothing:
VAL = raw_offset * (1 - smoothing) + prev_VAL * smoothing;
```

**DC Gain Coefficient Tracking** (subSysDCcoeff):
```c
// Tracks ripple loop DC coefficient based on klystron gain deviation:
// Step 1: Compute current delta gain from coefficient ratio
I = log10(current_coeff / max_coeff) * 20.0;          // dB
// Step 2: Compute needed correction, limited by deadband
L = desired_gain - actual_gain - I;                     // dB
L = clamp(L, -deadband, +deadband);
// Step 3: Convert to coefficient delta
L = max_coeff * 10^((I + L)/20) - current_coeff;       // volts
L = clamp(L, -max_delta, +max_delta);
// Step 4: Apply (if tracking on, no beam abort, gain reasonable)
if (tracking_on && !beam_abort && gain > 0.1)
    VAL = current_coeff + L;
else if (tracking was just turned off)
    VAL = initial_coeff;                                // reset
VAL = clamp(VAL, LOPR, HOPR);
```

**AB Reset** (subSysABreset):
```c
// Single function call — no multi-step sequence:
epicsPrintf("Allen-Bradley reset started\n");
ab_reset();
return(OK);
```

### 3.3 Hardware Dependencies

Most subSys functions are pure math. The exceptions:
- `subSysABreset` — calls `ab_reset()` (Allen-Bradley driver function; isolate for upgrade)
- `subSysLog` — pure math (`B × 10^A`) with EPICS monitor/archive delta management; trivially portable

---

## 4. Shared Constants (from p2RfLib.h)

| Constant | Value | Description |
|----------|-------|-------------|
| `P2RF_K_RFFREQ` | 476,000,000 | RF frequency in Hz (476 MHz) |
| `P2RF_K_HARMNO(2)` | 372 | SPEAR3 harmonic number |
| `P2RF_K_HARMNO(other)` | 3,492 | PEP-II harmonic number |
| `P2RF_K_SAMPFACT` | 72 | 10 MHz sampling factor |
| `P2RF_K_HERCAVCNT` | 4 | Number of HER cavities |
| `P2RF_K_LERCAVCNT` | 2 | Number of LER cavities |
| `P2RF_K_BUFSIZE` | 256 | Message buffer size |
| `P2RF_K_BLKSIZE` | 1,024 | Minimum history block size |
| `PI` | `4.0 * atan(1.0)` | Mathematical constant π |

### 4.1 Conversion Block (P2RfCvtBlk)

Used for coefficient value range checking and conversion:
```c
typedef struct {
    float   fMin;       // Minimum floating point value
    short   iMin;       // Corresponding integer value
    float   fMax;       // Maximum floating point value
    short   iMax;       // Corresponding integer value
    short   iOff;       // Offset to apply
    short (*cvtRtn)();  // Conversion routine
    void   *cvtArg;     // Conversion argument
} P2RfCvtBlk;
```

### 4.2 Digital Data Filter (P2RfDdf)

Used for IQA filter definitions:
```c
typedef struct {
    int             fcCnt;      // Coefficient count (1-257)
    unsigned short  f;          // F_REGISTER
    P2RfFc          fc[257];    // Coefficient pairs (lo,hi) — up to 512 taps
    unsigned short  h1;         // H_REGISTER1
    unsigned short  h2;         // H_REGISTER2
} P2RfDdf;
```

---

## 5. Upgrade Path

### 5.1 Direct Reuse (subIQ.c)

1. Copy `subIQ.c` to new IOC application
2. Update includes if EPICS API changed (unlikely — subRecord interface is stable)
3. Register functions in new `.dbd` file
4. Link subroutine records in new database to same function names
5. **Done** — no algorithm changes needed

### 5.2 Direct Reuse (subSys.c)

1. Copy `subSys.c` to new IOC application
2. Isolate `subSysABreset` — replace with new PLC reset if needed
3. All other functions: direct reuse (all are pure math)
4. **Done** — minimal changes

### 5.3 Physics Constants

The constants in `p2RfLib.h` should be preserved in a new shared header:
- `P2RF_K_RFFREQ = 476000000` — this is a physical constant of the RF system
- `P2RF_K_HARMNO(2) = 372` — this is the SPEAR3 harmonic number
- These values are independent of the control system implementation

---

## Appendix: Rev 3 Correction Log

The following errors were identified during a formula-level audit of the C source code and corrected in this revision:

### Catastrophic Errors (completely wrong purpose or formula)
1. **subSysLog** — Was: "Write message to EPICS event log." Actual: computes `VAL = B × 10^A` (logarithmic-to-linear conversion for vacuum readings)
2. **subIQampl2conv** — Was: `sqrt(I²+Q²)×conv+offs`. Actual: `A/(C×(1+E))` (RF drive calibration constant, units: Counts/kV)
3. **subSysBeamCurr** — Listed as 11th function but **does not exist** in source. The actual 11th function is `subSysInit` (no-op initialization)
4. **subSysFreqOff** — Was: phase-to-frequency `Δphase/(360×Δt)`. Actual: polynomial frequency offset estimation from tuner position and cavity voltage

### Major Formula Errors
5. **subIQamplCplg** — Was: power-based `2×Pf/(Pf+Pc-Pr)`. Actual: VSWR voltage-based `(1+r)/(1-r)` where `r = reflected_ampl / forward_ampl`
6. **subIQamplStn** — Was: RMS `sqrt(Σ amp²)`. Actual: scalar sum `A+B+C+D` (in-phase cavity voltage addition)
7. **subIQampl2loss** — Was: `20×log10(ampl2/ampl1)`. Actual: calibrated conversion loss `D×log10(E×sqrt(F)/A)` with 7 inputs including severity, calibration power, and station state
8. **subIQcounts** — Was: linear transform `(value-offs)/scale`. Actual: proportional controller `Gain × Error × ConvFactor` with deadband, gain limiting, and loop gain correction

### Significant Oversimplifications
9. **subIQpower** — Was: `(I²+Q²)/Zscale`. Actual: state-dependent (ON_FM vs other), exponential smoothing, power vs. amplitude mode selection
10. **subIQpower2ampl** — Was: `sqrt(power×Zscale)`. Actual: state-dependent input selection, power/amplitude mode branching, alarm limit generation (K, L outputs), maximum voltage override, scale factor division
11. **subSysFreqErr** — Was: `f_measured - f_setpoint`. Actual: `A×B×(C-D)` with loaded-Q scaling (not a simple subtraction)
12. **subSysPhaseTot** — Was: `Σ Φ_cavity[i]`. Actual: rate-limited delta-phase tracking with initialization and ±180° wrapping
13. **subSysDCcoeff** — Was: "coupling matrix element" with 2×2 I/Q matrix description. Actual: ripple loop DC gain coefficient tracking based on klystron gain deviation
