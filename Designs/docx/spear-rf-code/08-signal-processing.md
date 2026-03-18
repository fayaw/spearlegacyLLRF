# Signal Processing & Physics Algorithms

**Document**: 08 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**(Rev 2 — added reuse evaluation for upgrade EPICS coordinator)**

---

## UPGRADE CONTEXT

subIQ.c and subSys.c contain **pure-math functions** with no hardware dependencies. These are the most directly reusable components in the codebase.

**Evaluation question**: Which of these functions are needed in the upgrade Python/EPICS coordinator?

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

| Function | Line | Inputs | Output | Equation |
|----------|------|--------|--------|----------|
| `subIQinit` | 111 | — | OK | Initialization (no-op) |
| `subIQphase` | 123 | A=I, B=Q | degrees | `atan2(Q, I) × 180/π` |
| `subIQampl` | 149 | A=I, B=Q, C=scale | scaled amp | `sqrt(I² + Q²) × scale` |
| `subIQampl2conv` | 175 | A=I, B=Q, C=conv, D=offs | converted | `sqrt(I² + Q²) × conv + offs` |
| `subIQamplStn` | 207 | A-D=cavity amps | station amp | `sqrt(Σ amp²)` |
| `subIQamplCplg` | 218 | A=Pc, B=Pf, C=Pr | coupling | `2×Pf / (Pf + Pc - Pr)` |
| `subIQampl2loss` | 245 | A=ampl1, B=ampl2 | loss dB | `20 × log10(ampl2/ampl1)` |
| `subIQampl2iq` | 274 | A=ampl, B=phase | I, Q | `I=A×cos(B×π/180)`, `Q=A×sin(B×π/180)` |
| `subIQpower` | 308 | A=I, B=Q, C=Zscale | watts | `(I² + Q²) / Zscale` |
| `subIQpowerNet` | 352 | A=Pfwd, B=Prefl | net power | `Pfwd - Prefl` |
| `subIQpowerEff` | 368 | A=Pout, B=Pin | efficiency | `Pout / Pin × 100` |
| `subIQpower2gain` | 386 | A=Pout, B=Pin | gain dB | `10 × log10(Pout/Pin)` |
| `subIQpower2ampl` | 413 | A=power, B=Zscale | amplitude | `sqrt(power × Zscale)` |
| `subIQphaseOffsU` | 467 | A=phase, B=offset, C=flag | unadj phase | Phase offset calculation with wrapping |
| `subIQphaseOffs` | 542 | A=phase, B=offset | adj phase | `phase + offset` (with ±180° wrap) |
| `subIQphaseErr` | 566 | A=measured, B=setpoint | error | `measured - setpoint` (with ±180° wrap) |
| `subIQphase2posn` | 586 | A=phase, B=gain, C=offs | position | `phase × gain + offset` |
| `subIQdac` | 620 | A=ampl, B=phase, C=mode | DAC counts | I/Q matrix DAC calculation |
| `subIQcounts` | 653 | A=value, B=scale, C=offs | counts | `(value - offs) / scale` |
| `subIQcorrected` | 698 | A=raw, B=dirCorr, C=offs | corrected | Directivity correction |
| `subIQscaled` | 731 | A=raw, B=scale, C=offs | scaled | `raw × scale + offset` |
| `subIQgetInit` | 769 | record fields | OK | One-time init for IQ data acquisition |
| `subIQget` | 817 | record fields | OK | Read I/Q data from hardware |

### 2.2 Key Physics Formulas

**Phase from I/Q**:
```c
phase = atan2(Q, I) * 180.0 / PI;
// Range: -180° to +180°
```

**Amplitude from I/Q**:
```c
amplitude = sqrt(I*I + Q*Q) * scale_factor;
```

**Power from I/Q** (with impedance scaling):
```c
power_watts = (I*I + Q*Q) / Z_scale;
// Z_scale accounts for directional coupler, cable loss, etc.
```

**Coupling Factor**:
```c
coupling = 2.0 * P_forward / (P_forward + P_cavity - P_reflected);
```

**Loss in dB**:
```c
loss_dB = 20.0 * log10(amplitude_out / amplitude_in);
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

### 2.3 EPICS Subroutine Record Interface

Each function follows the standard interface:
```c
static long subIQphase(struct subRecord *psub) {
    // Inputs: psub->a through psub->l (up to 12 inputs)
    // Output: psub->val (single floating point result)
    // Additional outputs: psub->vala through psub->vall (if needed)
    
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

| Function | Line | Description |
|----------|------|-------------|
| `subSysFreqOff` | — | Frequency offset from IQA measurements: `f_off = Δphase / (360 × Δt)` |
| `subSysFreqErr` | — | Frequency error: `f_err = f_measured - f_setpoint` |
| `subSysFreqOAvg` | — | Frequency offset averaging (running average filter) |
| `subSysPhaseTot` | — | Total phase across all cavities: `Φ_total = Σ Φ_cavity[i]` |
| `subSysPhaseCmb` | — | Phase combining from multiple cavities (weighted average) |
| `subSysPhaseStn` | — | Station-level phase computation |
| `subSysDCcoeff` | — | DC coefficient for compensation loop (coupling matrix element) |
| `subSysDrivSel` | — | Drive source selection logic (choose between drive sources) |
| `subSysLog` | — | Write message to EPICS event log |
| `subSysABreset` | — | Allen-Bradley PLC reset sequence |
| `subSysBeamCurr` | — | Beam current processing |

### 3.2 Key Algorithms

**Frequency Offset** (subSysFreqOff):
```c
// From phase change rate (dφ/dt):
freq_offset_Hz = (phase_new - phase_old) / (360.0 * dt_seconds);
```

**DC Coefficient** (subSysDCcoeff):
```c
// Computes coupling matrix element from I/Q measurements:
// Takes IQA measurements from forward, reflected, and cavity probes
// Computes the 2×2 matrix coefficient that maps drive signal to cavity response
// Used by RFP direct loop for proper feedback operation
DC_coeff = f(I_fwd, Q_fwd, I_refl, Q_refl, I_cav, Q_cav);
```

**AB Reset** (subSysABreset):
```c
// Sequence to reset Allen-Bradley PLC communication:
// 1. Set AB reset flag
// 2. Wait for acknowledgment
// 3. Clear reset flag
// 4. Verify communication restored
```

### 3.3 Hardware Dependencies

Most subSys functions are pure math. The exceptions:
- `subSysABreset` — references AB PLC (isolate for upgrade)
- `subSysLog` — references EPICS logging API (trivial to update)

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
3. Update `subSysLog` if logging API changed
4. All other functions: direct reuse
5. **Done** — minimal changes

### 5.3 Physics Constants

The constants in `p2RfLib.h` should be preserved in a new shared header:
- `P2RF_K_RFFREQ = 476000000` — this is a physical constant of the RF system
- `P2RF_K_HARMNO(2) = 372` — this is the SPEAR3 harmonic number
- These values are independent of the control system implementation
