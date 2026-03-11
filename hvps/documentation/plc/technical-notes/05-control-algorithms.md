# 05 — Control Algorithms: N7:10 & N7:11

> Derived from `plcNotesR1.docx` and `PLC software discusion 1.docx`.

## Overview

The two critical control registers are:

| Register | Name | Function | DAC Output |
|----------|------|----------|------------|
| **N7:10** | Reference Out | Voltage setpoint sent to regulator card EL1 input | O:8.0 (Slot 8, OUT 0) |
| **N7:11** | Phase Out | Phase angle bias sent to Enerpro SIG HI input | O:8.1 (Slot 8, OUT 1) |

Both are 16-bit signed integers (range: −32768 to +32767). The maximum useful value is 32000 (N7:32).

---

## N7:10 — Voltage Reference with Digital Low-Pass Filter

### Signal Path

```
EPICS IOC → VXI Crate → 1747-DCM → I:1 Register 1 → N7:30 (External Reference)
                                                            ↓
                                      N7:10 (Reference Out) ← Low-pass filter (Rung 104)
                                                            ↓
                                      O:8.0 → Regulator Card EL1 Input
```

### Rung 104 — Low-Pass Filter Implementation

**Timing:** Executes every 80 ms (gated by S:4/2 and OSR B3:5/0).

**Condition:** B3:0/2 (Regulator On) must be true.

**Step-by-step logic:**

```
1. MOV I:1.1 → N7:30           // Load setpoint from EPICS into External Reference
2. IF N7:31 > N7:30:           // Enforce minimum reference
      MOV N7:31 → N7:30        // N7:30 = max(N7:30, N7:31)    [N7:31 = 100]
3. SUB N7:30 - N7:10 → N7:43   // Calculate delta: N7:43 = N7:30 - N7:10
4. DIV N7:43 / 10 → N7:43      // Scale to 1/10 of delta
5. ADD N7:10 + N7:43 → N7:10   // Update reference: N7:10 += N7:43
6. (Clear overflow, set valid bit O:1/96)
7. IF N7:43 == 0:              // When delta rounds to zero...
      MOV N7:30 → N7:10        // Force exact match
8. IF N7:10 > N7:32:           // Clamp to max internal reference
      MOV N7:32 → N7:10        // N7:10 = min(N7:10, 32000)
9. IF N7:33 > 0 AND N7:10 > N7:33:  // Clamp to external max
      MOV N7:33 → N7:10        // N7:10 = min(N7:10, N7:33)
```

### Low-Pass Filter Mathematics

The filter implements a discrete single-pole low-pass step response. At each iteration *n* (period *T* ≈ 80 ms):

```
N7:10[n+1] = N7:10[n] + (N7:30 - N7:10[n]) / 10
```

This is equivalent to:

```
error[n] = setpoint - actual[n]
actual[n+1] = actual[n] + α × error[n]
```

where **α = 1/10 = 0.1**.

#### Continuous-Time Equivalent

The step response is:

```
V(t) = V_final × (1 - (1 - α)^(t/T))
     = V_final × (1 - 0.9^(t/0.08))
```

This is a digital implementation of:

```
V(t) = V_final × (1 - e^(-t/τ))
```

where the equivalent time constant is:

```
τ = -T / ln(1 - α) = -0.08 / ln(0.9) ≈ 0.76 seconds
```

**For the HVPS:** With α = 0.1 and T = 80 ms → **τ ≈ 0.76 s**.

The reference voltage reaches:
- 63% of target in ~0.76 s
- 95% of target in ~2.3 s
- 99% of target in ~3.5 s

#### Integer Truncation Handling

Because N7:43 = (N7:30 − N7:10) / 10 uses integer division, when the remaining difference is less than 10, N7:43 truncates to 0. Step 7 forces `N7:10 = N7:30` when this occurs, ensuring the reference always reaches its exact target value.

### Initialization (Rung 11)

When the regulator is off (B3:0/2 = 0):
- N7:10 = 0
- N7:11 = 0

This ensures the voltage reference starts from zero on power-up.

### Clamping

Two maximum limits are enforced:

| Limit | Register | Typical Value | Source |
|-------|----------|---------------|--------|
| Max Internal Reference | N7:32 | 32000 | Loaded from N7:71 in Rung 105 |
| Max External Reference | N7:33 | Variable | From I:1 Register 2 via DCM |

```
N7:10 = min(N7:10, N7:32)
if N7:33 > 0: N7:10 = min(N7:10, N7:33)
```

---

## N7:11 — Phase Angle Control

### Signal Path

```
N7:10 (Reference Out)
    ↓
    × N7:40 (12000)    // Phase Angle Multiplier
    ↓ (32-bit result)
    ÷ 32767             // DDV (Double Divide)
    ↓
    + N7:41 (6000)      // Add Offset
    ↓
    clamp to N7:42 (18000)  // Maximum Phase Angle
    ↓
N7:11 (Phase Out)
    ↓
O:8.1 → Enerpro SIG HI Input (via 1 kΩ summing resistor)
```

### Rung 108 — Phase Angle Calculation

```
1. MOV N7:10 → N7:11                    // Copy reference voltage
2. MUL N7:11 × N7:40 → N7:11           // N7:11 = N7:10 × 12000
   (If product > 32767: S:13/S:14 hold  // 32-bit result; N7:11 = 32767
    full result)
3. (Unset S:5 overflow bit)
4. DDV (S:13:S:14) / 32767 → N7:11      // Scale back to 16-bit range
5. ADD N7:11 + N7:41 → N7:11            // Add 6000 offset
6. (Unset S:5 overflow bit)
```

### Rung 109 — Phase Angle Clamping

```
IF N7:11 > N7:42 (18000):
    MOV N7:42 → N7:11                   // N7:11 = min(N7:11, 18000)
```

### Effective Transfer Function

For the phase angle calculation:

```
N7:11 = (N7:10 × 12000) / 32767 + 6000
```

Simplifying:

```
N7:11 ≈ 0.3662 × N7:10 + 6000
```

Clamped to maximum of 18000.

This means:
- When N7:10 = 0: N7:11 = 6000 (minimum phase)
- When N7:10 = 32000: N7:11 ≈ 0.3662 × 32000 + 6000 = 17718
- Maximum N7:11 = 18000

### Physical Meaning

The analog output O:8.1 (Slot 8, OUT 1) drives the **SIG HI** input on the Enerpro SCR phase control board. It is summed with the regulator board's output signal using resistors:
- **Regulator output** through 7.5 kΩ
- **PLC output (N7:11)** through 1 kΩ

The offset of 6000 provides a minimum firing angle, and the slope ties the phase angle to the voltage reference to maintain proper SCR firing throughout the operating range.

---

## N7:0 — Display Reference Voltage

### Rung 106 — Scaled Output

```
1. MUL N7:10 × N7:20 (10000) → N7:0
2. (Check overflow)
3. DDV (S:13:S:14) / 32767 → N7:0       // N7:0 = N7:10 × 10000 / 32767
```

### Rung 107 — Negative Detect

```
IF N7:0 != 0 (or negative): MOV 0 → N7:0
```

Comment says "NEG DETECT" — zeros N7:0 if negative/invalid.

Effective calculation:
```
N7:0 ≈ 0.3052 × N7:10     (in display units)
```

---

## N7:1 — Display Phase Angle

### Rung 110 — Phase Angle Display Scaling

```
1. MUL N7:11 × N7:21 (1000) → 32-bit result
2. (Unset S:5)
3. DDV / 32767 → N7:1                   // N7:1 = N7:11 × 1000 / 32767
```

### Rung 111 — Validity Check

```
IF N7:1 negative or overflow: MOV 0 → N7:1
```

---

## Rung 105 — Constant Loading and Ratio Tracking

**Timing:** Executes every 640 ms (S:4/5 with OSR B3:5/9).

```
1. MOV N7:71 (32000) → N7:32          // Max Internal Reference
2. MOV N7:72 (18000) → N7:42          // Max Phase Angle
3. MOV N7:73 (100) → N7:31            // Internal Reference minimum
4. DIV N7:71 / N7:10 → N7:74          // Ratio: 32000 / Reference Out
5. MUL N7:74 × 32767 → N7:74          // Scale ratio
6. DIV N7:73 / N7:10 → N7:75          // Ratio: 100 / Reference Out
7. MUL N7:75 × 32767 → N7:75          // Scale ratio
```

> **Known Issue:** If N7:10 = 0, steps 4 and 6 will cause a divide-by-zero fault. The minimum value enforced by N7:31 (100) in Rung 104 should prevent this during normal operation, but startup conditions may be vulnerable.

---

## Timing Summary

| Rung | Gate | Period | Function |
|------|------|--------|----------|
| 92 | S:4/3, B3:5/8 | 160 ms | Data transfer to DCM |
| 104 | S:4/2, B3:5/0 | 80 ms | Voltage reference ramping |
| 105 | S:4/5, B3:5/9 | 640 ms | Constant loading |
| 86 | S:4/2, B3:5/1 | 80 ms | Analog processing |
| 87 | S:4/2, B3:5/2 | 80 ms | Analog processing |
| 93 | S:4/2, B3:5/4 | 80 ms | Analog processing |
| 94 | S:4/2, B3:5/5 | 80 ms | Analog processing |
| 96 | S:4/2, B3:5/6 | 80 ms | Analog processing |
| 97 | S:4/2, B3:5/7 | 80 ms | Analog processing |
| 117 | S:4/6, B3:17/0 | 1280 ms | Status update |
| 118 | S:4/7, B3:17/1 | 2560 ms | Status update |

---

## Open Questions from Original Analysis

1. **Divide-by-zero in Rung 105:** Is N7:10 always guaranteed to be non-zero when Rung 105 executes?
2. **N7:74 railing:** The ratio calculation in Rung 105 appears to rail at 2¹⁵−1 — is this intentional?
3. **Rung 92 GRT logic:** Why does the conditional `N7:32 > N7:33` override the max volts output? (Likely sends the lower of the two limits to EPICS.)
4. **N7:33 loading:** The external max reference loaded from I:1.2 may have race conditions with the limit check in Rung 104.
5. **MUL × 1 in Rung 82:** Why multiply DC current by 1 instead of using MOV? (Possibly to populate the 32-bit math register for subsequent operations.)

