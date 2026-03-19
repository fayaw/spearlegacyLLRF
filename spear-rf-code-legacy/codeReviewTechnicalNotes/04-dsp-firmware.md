# DSP Firmware Analysis — TMS320C16xx Assembly

**Document**: 04 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**(Rev 3 — corrected file/line counts against actual source; ALL DSP firmware ELIMINATED by LLRF9)**

---

## UPGRADE CONTEXT — ALL ELIMINATED

**All DSP firmware is ELIMINATED in the upgrade.** The Dimtel LLRF9/476 FPGA (270 ns direct loop delay) replaces all DSP functions. Per PDR §15.7:
- **Ripple rejection loop**: "LLRF9 digital feedback inherently rejects power-line ripple"
- **GVF feed-forward**: "used for PEP-II, not SPEAR3" (GVF module not installed in SPEAR3 crate)
- **Comb filter (CFM)**: "used for PEP-II multi-bunch stabilization, not applicable to SPEAR3"

**No DSP algorithm migration is needed.** These files serve only as historical documentation of what the legacy system did. The LLRF9 implements its own algorithms designed by Dimtel (Dmitry).

---

## 1. Overview

The VXI modules use on-board TI TMS320C16xx fixed-point DSPs for real-time signal processing at rates too fast for the EPICS IOC (which scans at ~1 Hz). All DSP code is written in assembly language and loaded at boot time via the VXI A24 bus.

**Total DSP firmware**: ~16,763 lines across 4 subdirectories (rfpDsp, gvfDsp, obsDsp, genDsp) plus shared files in the parent dsp/ directory, totaling 102 files.

**Status**: ALL ELIMINATED — LLRF9 FPGA handles all fast processing with 270 ns loop delay vs. legacy ~43 µs DSP cycle. No migration needed.

---

## 2. RFP DSP — Ripple Rejection Loop

### 2.1 Purpose

Cancels AC mains harmonics (60 Hz × N) from the RF system. The HVPS uses a 6-pulse SCR bridge rectifier, injecting 360 Hz ripple (and harmonics) onto the klystron beam voltage, which modulates the RF field amplitude and phase.

### 2.2 Algorithm (from ripple.s / sp3ripple.s comments)

**Loop Rate**: ~23 kHz (ripple clock frequency)

**Per-Cycle Processing**:

```
1. READ I/Q SIGNALS (interlaced ADC reads)
   ─────────────────────────────────────────
   Qref ← ADC channel (reference Q)
   Qkly ← ADC channel (klystron Q)  
   Ikly ← ADC channel (klystron I)
   Iref ← ADC channel (reference I)
   Format: 16-bit two's complement

2. COMPUTE PHASE AND AMPLITUDE
   ─────────────────────────────────────────
   PhaseRef = atan2(Qref, Iref)    // q13 format [-π, +π]
   PhaseKly = atan2(Qkly, Ikly)    // q13 format [-π, +π]
   AmpRef   = sqrt(Iref² + Qref²)  // unsigned
   AmpKly   = sqrt(Ikly² + Qkly²)  // unsigned

3. COMPUTE ERRORS
   ─────────────────────────────────────────
   PhaseErr = PhaseRef - PhaseKly
   AmpErr   = AmpRef - AmpKly  (or AmpSetpoint - AmpKly)

4. HARMONIC ESTIMATION (dual-rate)
   ─────────────────────────────────────────
   "Fast" harmonics (N = 6, processed every cycle at 23 kHz):
     For each harmonic h[n]:
       h[n].I_accum += PhaseErr * cos(2π * n * f_ripple * t)
       h[n].Q_accum += PhaseErr * sin(2π * n * f_ripple * t)
   
   "Slow" harmonics (N = 8, round-robin at ~23kHz/8 ≈ 3 kHz):
     Process one slow harmonic per cycle
     Effective bandwidth ~1.5 kHz

5. ACCUMULATE CORRECTIONS (q11 format [-16.0, +16.0])
   ─────────────────────────────────────────
   DacI_correction = Σ h[n].I_accum * gain[n]
   DacQ_correction = Σ h[n].Q_accum * gain[n]

6. APPLY TO DAC OUTPUTS
   ─────────────────────────────────────────
   DacI_out = DacI_base + DacI_correction
   DacQ_out = DacQ_base + DacQ_correction
   Write to DAC hardware registers
```

### 2.3 sp3ripple.s — SPEAR3 Variant

Key differences from PEP-II version:
- Harmonic number: 372 (SPEAR3) vs 3492 (PEP-II)
- Adapted sampling factors
- Otherwise same algorithm

### 2.4 Phase Offset Variant (ripple_phaseoff.s)

Adds a configurable phase offset to the feedback:
- Allows operator to trim the feedback phase
- Phase offset loaded via CMD_K_PHSG command from CPU
- Applied as: `PhaseErr = (PhaseRef + PhaseOffset) - PhaseKly`

### 2.5 Fixed-Point Arithmetic

| Format | Range | Resolution | Used For |
|--------|-------|------------|----------|
| q13 | [-1.0, +1.0) | 2⁻¹³ ≈ 1.2×10⁻⁴ | Phase/angle (maps to [-π, +π]) |
| q11 | [-16.0, +16.0) | 2⁻¹¹ ≈ 4.9×10⁻⁴ | Accumulators (extra headroom) |
| q15 | [-1.0, +1.0) | 2⁻¹⁵ ≈ 3.1×10⁻⁵ | Gain coefficients |
| unsigned 16-bit | [0, 65535] | 1 | Amplitude, square root results |

### 2.6 Square Root Functions

**lusqrt.s** (1,064 lines) — Unsigned square root:
- Input: 32-bit unsigned (high:low word pair)
- Output: 16-bit unsigned root
- Method: Lookup table with linear interpolation
- The table is generated offline and embedded in the code

**sqlu.s** (1,024 lines) — Alternate implementation:
- Similar algorithm, different precision/range tradeoffs

### 2.7 DAC Control Functions

| File | Lines | Function |
|------|-------|----------|
| `loadDacs.s` | 183 | Load DAC values from memory table to hardware |
| `rampDacs.s` | 188 | Gradual ramp (klystron protection during transitions) |
| `constDacs.s` | 153 | Output constant DAC values |
| `zeroDacs.s` | 151 | Zero all DAC outputs safely |

Ramp sequence:
1. Read current DAC values
2. Compute step size = (target - current) / ramp_steps
3. Each cycle: current += step
4. Write to DAC
5. Until target reached

### 2.8 DSP Interrupt Handling

**Vector Table** (vecTbl.s, 113 lines):
```assembly
.sect    ".text"
_vectors:
    B       _c_int0         ; Reset vector
    B       _int1           ; INT1 - external interrupt 1
    B       _int2           ; INT2 - external interrupt 2
    B       _int3           ; INT3 - timer interrupt
    B       _trap           ; TRAP - software trap
    ; ... more vectors
```

**BIO (Branch on I/O) Bits**:
| BIO | Function | Type |
|-----|----------|------|
| BIO0 | Message to DSP | Edge-triggered → ISR flag |
| BIO1 | Open/Close Ripple Loop | Level-sensitive → polled |
| BIO2 | Ripple Clock | Edge-triggered → ISR flag |
| BIO3 | Rear Panel Trigger | Edge-triggered → ISR flag |

### 2.9 Communications Block (comBlk.s, 147 lines)

Template for the shared-memory communication block:
```assembly
.sect    ".comm"
_comBlk:
    .word    0x0001          ; blkId
    .word    0x0001          ; vers
    .word    0x0000          ; chkSum
    .word    0x0000          ; status
    .word    0,0,0,0,0,0,0,0 ; sttArg[8]
    .word    0x0000          ; dspMsg
    .word    0x0000          ; dspArg
    .word    0x0000          ; cpuMsg
    .word    0x0000          ; cpuArg
    .word    17              ; comLen (block size in words)
```

---

## 3. GVF DSP — Feed-Forward

### 3.1 gvff.s (1,199 lines)

Gap voltage feed-forward core algorithm:
- Receives gap timing information from TAXI link
- Computes correction waveform anticipating beam loading changes
- Outputs correction to DAC for feed-forward injection

### 3.2 wave_out.s (1,298 lines)

Waveform output controller:
- Reads waveform data from external RAM table
- Outputs sequential samples to DAC at clock rate
- Supports single-shot and continuous modes
- Used for arbitrary waveform generation (drives, noise injection, sweeps)

### 3.3 GVF Communications Block (comBlk.s, 389 lines)

Larger than RFP version — includes additional fields for:
- Waveform table pointers
- Feed-forward gain parameters
- TAXI link status

---

## 4. Observer DSP — Monitoring & Adaptive Filtering

### 4.1 takeDat.s (450 lines)

Primary data acquisition loop:
- Reads I/Q data from ADCs
- Processes through configurable filter chain
- Stores results in circular buffer
- Generates interrupts when buffer full

### 4.2 Signal Processing Chain

```
ADC Input → iqTOap.s (I/Q to Amp/Phase) → dspSos.s (IIR filter)
         → adapt.s (adaptive filter)     → Equaliz.s (equalization)
         → averPhas.s (phase averaging)  → ldCirBuf.s (store to buffer)
```

### 4.3 Coordinate Transforms

**iqTOap.s** (195 lines): I/Q → Amplitude/Phase
```
Amplitude = sqrt(I² + Q²)
Phase     = atan2(Q, I)      // using atan.s lookup table
```

**apTOiq.s** (218 lines): Amplitude/Phase → I/Q
```
I = Amplitude * cos(Phase)   // using sin.s/cos.s lookup tables
Q = Amplitude * sin(Phase)
```

### 4.4 Arctangent (atan.s, 184 lines)

Fixed-point atan2 implementation:
- Quadrant detection via sign bits
- Table lookup for primary octant
- Linear interpolation between table entries
- Result in q13 format

### 4.5 Adaptive Filter (adapt.s, 115 lines)

LMS (Least Mean Squares) adaptive filtering:
- Updates filter coefficients based on error signal
- Convergence rate controlled by step-size parameter
- Used for system identification and adaptive cancellation

---

## 5. Generic Shared Functions

### 5.1 Trigonometric Functions

**sin.s** (92 lines) + **cos.s** (96 lines):
- 256-entry lookup table covering [0, 2π)
- Linear interpolation between entries
- Input: q13 angle, Output: q15 result

### 5.2 Square Root (sqrt2.s, 153 lines)

Signed square root:
- Handles negative inputs (returns magnitude of complex number)
- Lookup table with interpolation
- 16-bit precision

### 5.3 Shared Headers

| Header | Lines | Defines |
|--------|-------|---------|
| `dspCmdDef.h` | 64 | Command codes (CMD_K_*) — matches base/dspCmdDef.h |
| `dspDef.h` | 76 | DSP memory map, stack sizes, memory regions |
| `comDef.h` | 62 | Communications block field offsets |
| `funcs.h` | 95 | Function prototypes (assembly labels) |
| `intDef.h` | 116 | Interrupt enable/disable macros, vector offsets |
| `jtgDef.h` | 55 | JTAG test/debug definitions |
| `pioDef.h` | 90 | Programmable I/O definitions (ADC/DAC addresses) |
| `sttDef.h` | 69 | Status code definitions |
| `timDef.h` | 79 | Timer configuration (prescaler, period) |
| `macros.h` | 24 | Assembly utility macros |

---

## 6. FPGA Implementation Mapping

For the upgrade, each DSP algorithm maps to an FPGA module:

| DSP Algorithm | FPGA Implementation | Complexity |
|--------------|---------------------|------------|
| Ripple rejection loop | Pipelined I/Q processor with harmonic estimators | **High** — timing-critical, multi-rate |
| Square root | CORDIC or lookup table in block RAM | **Medium** |
| Arctangent | CORDIC or lookup table | **Medium** |
| Sin/Cos | CORDIC or lookup table | **Low** |
| Feed-forward waveform | DMA from block RAM to DAC interface | **Low** |
| Waveform output | Sequential block RAM read + DAC write | **Low** |
| Adaptive filter | FIR/LMS engine with coefficient update | **Medium** |
| SOS (IIR) filter | Biquad cascade in direct form II | **Medium** |
| DAC ramp | Linear interpolator with configurable rate | **Low** |
| Communications block | Register file accessible via AXI/PCIe | **Low** |

**Key Timing Constraint**: The ripple loop must complete all processing within one ripple clock period (~43 µs at 23 kHz). With FPGA clock rates of 100-250 MHz, this is easily achievable with pipelining.
