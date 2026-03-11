# 04 — Ladder Logic Analysis

> Complete rung-by-rung analysis of LAD 2 (120 rungs, 5557 bytes) from `CasselPLCCode.pdf`.

## RSLogix 500 Instruction Reference

Before reviewing the rungs, here are the key instructions used:

| Instruction | Name | Description |
|-------------|------|-------------|
| XIC | Examine If Closed | True if bit is HIGH (1) |
| XIO | Examine If Open | True if bit is LOW (0) |
| OTE | Output Energize | Sets bit HIGH while rung is true; goes LOW when false |
| OTL (L) | Output Latch | Sets bit HIGH and retains until explicitly unlatched |
| OTU (U) | Output Unlatch | Clears a latched bit (sets to LOW) |
| TON | Timer On Delay | Starts timing when rung goes true; DN bit goes high after preset |
| TOF | Timer Off Delay | Starts timing when rung goes false; DN bit goes low after preset |
| MOV | Move | Copies source value to destination |
| COP | Copy | Copies a block of contiguous data |
| ADD | Add | Adds two values |
| SUB | Subtract | Subtracts source B from source A |
| MUL | Multiply | Multiplies two values (32-bit result in S:13/S:14) |
| DIV | Divide | Divides source A by source B |
| DDV | Double Divide | Divides the 32-bit math register (S:13:S:14) by source |
| GRT | Greater Than | True if A > B |
| LES | Less Than | True if A < B |
| EQU | Equal | True if A = B |
| NEG | Negate | Negates a value |
| OSR | One Shot Rising | Triggers once on positive transition |

---

## Rungs 0000–0011: Power Sequencing & Initialization

### Rung 0000 — Overflow Bit Reset
- Unlatches S:5/0 (Overflow Bit)
- Keeps math overflow cleared every scan

### Rung 0001 — Reset Button Momentary
- **Condition:** T4:0/TT (momentary reset timer is timing)
- **Actions:**
  - Sets B3:0/10 (RESET) — OTE
  - Unlatches B3:0/14 (ALARM RESET)
  - Unlatches B3:5/3 (_ENERPRO_PHASE_LOSS)
- Timer T4:0 creates a brief reset pulse

### Rung 0002 — Contactor Close/Open Latch String
- **Conditions (all must be true to close contactor):**
  - T4:8/DN — System Ready delay complete
  - I:6/9 — Manual Ground Switch closed (1746-IB16)
  - B3:0/6 — Enable
  - B3:0/5 — Panel Open Bit (NOT open = closed)
  - I:1/48 — Remote On/Off (from DCM/EPICS)
  - T4:9/TT or T4:15/TT — Momentary remote or panel contactor close
  - I:7/2 — Contactor already closed (holding contact)
- **Blocking conditions (any prevents close):**
  - B3:0/8 — Contactor Latch (already latched)
  - I:7/15 — Regulator Current Trip
  - I:7/1 — Contactor Over Current
  - B3:0/15 — Contactor Ready fault
  - B3:3/2 — Open Load Latch
  - B3:4/10 — Crowbar Latch
  - B3:0/12 — Crowbar Lockout
- **Outputs:**
  - O:5/1 — Close Contactor (1746-OX8)
  - B3:0/8 — Contactor Latch (latches on)

### Rung 0003 — System Ready / Crowbar Enable
- **Conditions:**
  - T4:16/DN — Contactor closed delay done
  - T4:13/DN — Time off delay done
  - O:5/4 — Crowbar Enable active
  - I:6/1 — Crowbar Enable Fiber Drive
- **Outputs:**
  - B3:1/13 — System Ready
  - O:1/117 — System Ready to DCM
  - O:2/2 — 240V Power enable
  - O:5/0 — Control System Enable (SCR Enable)
  - T4:13 — Turn off delay timer (TON, 0.01s × 10 = 100 ms)

### Rung 0004 — SCR On/Off Chain
- **Conditions to turn SCR on:**
  - B3:0/1 — Off Bit (NOT off)
  - B3:0/8 — Contactor Latch (contactor is closed)
  - O:2/3 — Ground Switch Relay energized
  - B3:1/13 — System Ready
  - T4:16/DN — Contactor closed delay complete
  - I:6/0 — SCR Disable Fiber (NOT disabled)
  - I:1/64 — Control Enable from DCM
  - T4:10/TT or B3:0/3 — Remote SCR on momentary or panel on bit
- **Blocking conditions:**
  - I:7/1 — Contactor Over Current
  - I:7/14 — Over Voltage Trip
  - I:7/15 — Regulator Current Trip
  - O:5/3 — Crowbar Forced On
  - B3:4/10 — Crowbar Latch
- **Outputs:**
  - B3:0/4 — SCR On Latch
  - O:1/116 — Supply Ready to DCM
  - T4:16 — Contactor closed delay timer (TON, 0.01s × 300 = 3 seconds)

### Rung 0005 — Contactor Push Button Closed Momentary
- **Condition:** B3:0/7 (Contactor Button Bit)
- **Output:** T4:9 (TON, 0.01s × 100 = 1 second momentary)

### Rung 0006 — Contactor Close Remote Momentary
- **Condition:** I:1/48 (Remote On/Off from DCM)
- **Output:** T4:15 (TON, 0.01s × 100 = 1 second momentary)

### Rung 0007 — Open Load Latch
- **Condition:** T4:17/DN (Open Load Delay timer done)
- **Actions:**
  - B3:3/2 — Open Load Latch (latches on, reset by B3:0/11)
  - B3:0/14 — Alarm Bit (latches on)
  - O:1/121 — Remote Open Load to DCM

### Rung 0008 — Open Load Detector
Detects open load condition when voltage is high but current is low:
- **Conditions (all must be true):**
  - N7:17 (DC Current Monitor) < N7:77 (threshold ~10)
  - N7:14 (AC Current Monitor) < N7:79 (threshold ~30)
  - N7:15 (Voltage Monitor #1) > N7:76 (threshold ~5000)
  - N7:16 (Voltage Monitor #2) > N7:78 (threshold ~5000)
- **Output:** T4:17 (Open Load Delay, TON, 0.01s × 100 = 1 second)

### Rung 0009 — Remote SCR Control Momentary
- **Condition:** I:1/64 (Control Enable from DCM)
- **Output:** T4:10 (TON, 0.01s × 50 = 0.5 second momentary)

### Rung 0010 — Turn Off Sequence
- **Condition:** B3:0/4 (SCR On Latch)
- **Actions:**
  - T4:5 — Enable Delay timer (TON, 0.01s × 300 = 3 seconds)
  - Latches B3:0/13 (Fast Inhibit)
  - When T4:5/DN: sets B3:0/2 (Regulator On)

### Rung 0011 — Reference Voltage Initialization
- **Condition:** B3:0/2 (Regulator On) is FALSE (XIO — inverted)
- **Actions:**
  - MOV 0 → N7:10 (Reference voltage to zero)
  - MOV 0 → N7:11 (Phase angle to zero)
  - When T4:14/DN: Unlatches B3:0/13 (Fast Inhibit)
- **Purpose:** Zeros the reference outputs when the regulator is off

---

## Rungs 0012–0018: Fast Inhibit, Crowbar, Emergency, Enable

### Rung 0012 — Fast Inhibit Output
- **Condition:** T4:14/DN AND B3:0/13 (Fast Inhibit latched)
- **Outputs:**
  - O:5/6 — Fast Inhibit to Enerpro (1746-OX8)
  - O:1/108 — Fast Inhibit status to DCM

### Rung 0013 — Crowbar Latching with Reset
- **Logic:** Crowbar Latch (B3:4/10) is set when:
  - Crowbar Enable Fiber Drive (I:6/1) or Crowbar Enable (I:6/2) active
  - Fast Inhibit (O:5/6) active
  - T4:13/DN (turn-off delay done)
- **Reset:** B3:0/10 (Reset) clears the latch

### Rung 0014 — Emergency Off
- **Conditions:**
  - I:6/13 — Emergency Off switch active (inverted — closed = OK)
  - I:6/14 — PPS-1 OK
  - I:6/9 — Grounding Switch closed
- **Actions:**
  - B3:1/0 — Emergency Off Latch
  - B3:3/11 — Emergency Off Alarm
  - O:1/107 — Emergency Off to DCM
  - Latches B3:0/14 (Alarm Bit)
- **Reset:** B3:0/10 AND B3:1/11 (Contactor Closed)

### Rung 0015 — PPS Status
- **Conditions:** I:6/14 (PPS-1) AND I:6/15 (PPS-2)
- **Outputs:**
  - B3:1/1 — PPS On display
  - O:1/120 — PPS Status to DCM

### Rung 0016 — Off Display / Grounding Switch
- **Conditions:** I:6/12 (Key Enable), I:6/14 (PPS-1), I:6/15 (PPS-2), I:6/9 (Ground Switch)
- **Outputs:**
  - B3:0/0 — Off Display
  - When I:7/2 (Contactor Closed): O:2/3 — Ground Switch Relay

### Rung 0017 — Enable Chain
- **Conditions:** I:6/12 (Key Enable), B3:1/0 (Emergency Off clear), B3:0/0 (Not off)
- **Outputs:**
  - B3:0/6 — Enable
  - O:5/2 — Crowbar On (1746-OX8)
  - B3:1/9 — Enable Display

### Rung 0018 — System Ready Time Delay
- **Conditions:** B3:0/0 (Off clear), O:2/2 (240V Power), B3:0/6 (Enable)
- **Output:** T4:8 — System Ready Timer (TON, 0.01s × 500 = 5 seconds)

---

## Rungs 0019–0029: Alarm System

### Rung 0019 — Alarm Summary
- B3:0/14 (Alarm Bit) → B3:3/0 (Alarm)

### Rung 0020 — Contactor Alarm
- **Condition:** I:7/3 (Contactor Ready) is FALSE while T4:16/DN (contactor should be closed)
- **Output:** B3:3/8 (Contactor Alarm Latch), B3:0/14 (Alarm Bit)

### Rung 0021 — Transformer Alarm
- **Condition:** B3:2/1 (Transformer Latched OK) is FALSE
- **Output:** B3:3/7 (Transformer Alarm), B3:0/14 (Alarm Bit)

### Rung 0022 — Regulator Over Current
- **Condition:** I:7/15 (Current Trip) active
- **Output:** B3:3/5 (Regulator Over Current), B3:0/14 (Alarm Bit)

### Rung 0023 — Regulator Over Voltage
- **Condition:** I:7/14 (Voltage Trip) active
- **Output:** B3:3/6 (Regulator Over Voltage), B3:0/14 (Alarm Bit)

### Rung 0024 — Contactor Over Current
- **Condition:** I:7/1 (Contactor Over Current) active
- **Output:** B3:3/12 (Contactor Over Current Alarm), B3:0/14 (Alarm Bit)

### Rung 0025 — SCR Driver Monitor (H1 Lower)
- **Conditions:** I:6/4 (SCR Driver Bit Lower), I:6/0 (SCR Disable clear), B3:0/2 (Reg On), B3:2/13 (SCR Drive Bit), T4:18/DN
- **Outputs:**
  - B3:3/14 — SCR Driver Latch
  - B3:0/14 — Alarm Bit
  - O:1/124 — H1_SCR_LATCH to DCM

### Rung 0026 — SCR Driver Monitor (H2 Upper)
- **Conditions:** I:6/6 (SCR Driver Upper), same conditions as Rung 25
- **Outputs:**
  - B3:3/15 — SCR Driver Up Latch
  - B3:0/14 — Alarm Bit
  - O:1/125 — H2_SCR_LATCH to DCM

### Rung 0027 — Crowbar Force
- **Condition:** T4:16/TT (Contactor close delay timing) AND (B3:3/15 OR B3:3/14)
- **Output:** O:5/3 — Crowbar Forced On (AB Crowbar)

### Rung 0028 — Auxiliary Power Alarm
- **Condition:** B3:1/8 (Aux Pwr) FALSE while B3:0/4 (SCR On)
- **Output:** B3:3/10 (Aux Power Alarm), B3:0/14 (Alarm Bit)

### Rung 0029 — Regulator Trip
- **Condition:** I:7/12 (Current Limit) AND B3:0/2 (Regulator On)
- **Output:** B3:3/9 (Regulator Trip Bit), B3:0/14 (Alarm Bit)

---

## Rungs 0030–0040: Status Display

### Rung 0030 — Contactor Ready/Enable
- B3:2/1 (Xformer OK) → B3:2/2 (Contactor OK) → B3:0/15 (Contactor Ready)
- O:1/102 — Contactor Enable to DCM

### Rung 0031 — Contactor Open Display
- I:7/2 (inverted — contactor NOT closed) → B3:1/3, O:1/103

### Rung 0032 — Contactor Closed Display
- I:7/2 → B3:1/11, Latches O:5/4 (Crowbar Enable), O:1/101

### Rung 0033 — Crowbar Off Delay
- I:6/1 (Crowbar Trigger), T4:12/DN → Unlatches O:5/4
- T4:12 — Crowbar Off Delay (TON, 0.01s × 800 = 8 seconds)

### Rung 0034 — System Not Ready
- B3:1/13 (inverted) → B3:1/5 (System Not Ready)

### Rung 0035 — Slow Start
- O:5/0 (SCR Enable) → O:5/5 (Slow Start), O:1/109 (Enerpro Slow Start to DCM)

### Rung 0036 — Current Trip Timer (TOF)
- **Conditions:** B3:0/13 (Fast Inhibit) AND any of: I:7/15, I:7/1, I:7/0
- **Output:** T4:14 — TOF timer (0.01s × 300 = 3 seconds)
- After all conditions go LOW for 3s, T4:14/DN goes HIGH

### Rung 0037 — Crowbar On Display
- I:6/2 (Crowbar On) AND B3:4/10 (Crowbar Latch) → B3:1/7, B3:3/1
- During T4:16/TT (close delay): Latches B3:0/14 (Alarm)
- O:1/105 — Crowbar On to DCM

### Rungs 0038–0040 — 12 kV and Contactor Status
- **0038:** I:2/1 → B3:1/12 (12kV On), O:1/97
- **0039:** I:2/1 (inverted) → B3:1/4 (12kV Off)
- **0040:** I:7/3 AND I:7/2 → B3:1/10 (Contactor Ctrl Pwr), O:1/104

---

## Rungs 0041–0061: Transformer & Power Interlocks

### Rungs 0041–0046 — Transformer Protection (Latching NC Contacts)

All follow the pattern: Reset clears latch; interlock condition sets latch.

| Rung | Interlock | Input | Latch Bit | DCM Output |
|------|-----------|-------|-----------|------------|
| 0041 | Pressure | I:7/4 | B3:4/0 | O:1/119 |
| 0042 | Vacuum | I:7/5 | B3:5/12 | O:1/126 |
| 0043 | Over Temperature | I:7/6 + TC limits | B3:4/1 | O:1/111, O:1/112 |
| 0044 | SCR/Crowbar Oil Level | I:6/10, I:6/11 | B3:4/2 | — |
| 0045 | Low Oil | I:7/7 | B3:4/3 | O:1/110 |
| 0046 | Sudden Pressure | I:7/8 | B3:4/4 | O:1/118 |

### Rung 0043 — Temperature Interlock Detail
- In addition to I:7/6 digital input, checks:
  - N7:100 < N7:108 (TC Ch 0 below 800 threshold)
  - N7:101 < N7:109 (TC Ch 1 below 800 threshold)

### Rungs 0047–0052 — AC & DC Power Interlocks

| Rung | Interlock | Input | Latch Bit | Notes |
|------|-----------|-------|-----------|-------|
| 0047 | Oil Pump Flow | I:7/9 | B3:4/7 | Only when SCR On (B3:0/4) |
| 0048 | Klystron Crowbar | I:6/3 (Arc), I:6/0, I:6/1 | B3:2/6 | Also disables O:5/0 |
| 0049 | Klystron SCR Bit | I:6/0 | B3:2/5 | — |
| 0050 | Water Flow | I:7/10 | B3:2/7 | — |
| 0051 | Phase Loss | I:7/11 | B3:2/3 | Only when SCR On |
| 0052 | Ground Tank Oil | I:6/8 | B3:4/14 | — |

### Rungs 0053–0058 — Overcurrent/Overvoltage Latching

| Rung | Interlock | Input | Latch Bit | DCM Output |
|------|-----------|-------|-----------|------------|
| 0053 | AC Overcurrent | I:7/1, I:7/15 | B3:4/11 | O:1/99 |
| 0054 | Overvoltage | I:7/14 | B3:4/12 | O:1/113 |
| 0055 | Klystron Arc Trip | I:6/3, I:7/2 (open) | B3:4/13 | O:1/100 |
| 0056 | Klystron Crowbar | I:6/7 | B3:2/4 | O:1/123 (DCM_BIT) |
| 0057 | Transformer Arc | I:6/5, I:7/2 (open) | B3:4/15 | O:1/122 |
| 0058 | Contactor Current Fault | I:7/0, I:7/1 | B3:4/5 | — |

### Rungs 0059–0061 — DC Power & Transformer Composite

- **0059:** DC Power Fault (B3:4/6) — Set when B3:1/8 (Aux Pwr) off while B3:0/0 (Off clear)
- **0060:** Transformer Latched OK (B3:2/1) — All of: Pressure, Oil Temp, SCR Oil, Low Oil, Water Flow clear
- **0061:** No Transformer Fault (B3:0/9) — All of: I:7/4, I:7/5, I:7/6, I:7/7, I:7/8, I:6/10, I:6/11, I:6/8 OK

---

## Rungs 0062–0075: Extended Display & Status

- **0062:** O:2/128 — Enable Control Power when B3:0/6 (Enable)
- **0063:** B3:1/8 — Aux Power On Display, O:1/106
- **0064:** B3:1/2 — Disable Display
- **0071:** B3:4/8, B3:5/10 — SCR 1 Latch/Status, O:1/114
- **0072:** B3:4/9, B3:5/11 — SCR 2 Latch/Status, O:1/115
- **0073:** B3:2/0 — Ground Switch Open
- **0074:** B3:1/15 (Supply On), B3:1/14 (SCR On)
- **0075:** B3:1/6 — SCR Off

---

## Rungs 0076–0102: Analog Signal Processing

### Rungs 0076–0083 — Analog Input Processing

| Rung | Input | Offset | Destination | Notes |
|------|-------|--------|-------------|-------|
| 0076 | Slot 8 IN 0 | +N7:19 | N7:12 | Feedback voltage (with offset) |
| 0077 | — | — | — | Additional processing |
| 0078 | Slot 9 IN 0 | +N7:9 | N7:14 | AC current (with offset) |
| 0079 | — | — | — | Additional processing |
| 0080 | Slot 9 IN 1 | — | N7:15 | Voltage Monitor 1 (negated) |
| 0081 | Slot 9 IN 2 | — | N7:16 | Voltage Monitor 2 (negated) |
| 0082 | Slot 9 IN 3 | ×1 | N7:17 | DC Current (multiply by 1) |
| 0083 | — | — | — | Zero N7:17 if bit 15 set (overflow/negative) |

### Rungs 0084–0102 — Display Value Scaling

These rungs scale raw 16-bit values to engineering units for display using multipliers:

| Register | Multiplier Register | Multiplier Value | Scaled Output | Engineering Unit |
|----------|---------------------|-----------------|---------------|------------------|
| N7:12 → N7:2 | N7:22 | 10,075 | Regulator Voltage | kV (×10⁻²) |
| N7:13 → N7:3 | N7:23 | 1,000 | Phase Angle Monitor | degrees (×10⁻¹) |
| N7:14 → N7:4 | N7:24 | 4,600 | AC Current | A (×10⁻¹) |
| N7:15 → N7:5 | N7:25 | 10,000 | Voltage Monitor 1 | kV (×10⁻²) |
| N7:16 → N7:6 | N7:26 | 10,000 | Voltage Monitor 2 | kV (×10⁻²) |
| N7:17 → N7:7 | N7:27 | 5,000 | DC Current | A (×10⁻¹) |
| N7:15,N7:17 → N7:18 | N7:29 | 6 | Power | kW |

---

## Rung 0092 — Periodic Data Transfer

**Timing:** Executes every 160 ms (S:4/3 period), gated by OSR B3:5/8.

**Operations (executed in sequence):**

1. MOV N7:4 → O:1.1 — AC Current to DCM Register 1
2. COP I:3.0 → N7:100 (length 8) — Thermocouple data to N7:100–N7:107
3. MOV N7:10 → O:1.2 — Reference voltage to DCM Register 2
4. MOV N7:15 → O:1.3 — Voltage Monitor 1 to DCM Register 3
5. MOV N7:17 → O:1.4 — DC Current to DCM Register 4
6. MOV N7:32 → O:1.5 — Max Volt Reference to DCM Register 5
7. If N7:32 > N7:33: MOV N7:33 → O:1.5 — Use external max if lower
8. MOV I:1.2 → N7:33 — Load external max reference from DCM

---

## Rungs 0104–0113: Control Algorithm Core

See **[05 — Control Algorithms](05-control-algorithms.md)** for detailed mathematical analysis.

### Rung 0104 — Voltage Reference Ramping (N7:10)
Single-pole low-pass digital filter ramping N7:10 toward N7:30 (External Reference).

### Rung 0105 — Constant Loading
Loads operating constants:
- N7:71 (32000) → N7:32 (Max Internal Reference)
- N7:72 (18000) → N7:42 (Max Phase Angle)
- N7:73 (100) → N7:31 (Internal Reference minimum)
- Performs N7:71/N7:10 and N7:73/N7:10 calculations (ratio tracking)

### Rungs 0106–0107 — Output Reference Scaling
- MUL N7:10 × N7:20 (10000) → N7:0
- DDV by 32767 → N7:0 (scaled output)
- If N7:0 negative → N7:0 = 0

### Rungs 0108–0109 — Phase Angle Calculation (N7:11)
- MOV N7:10 → N7:11
- MUL N7:11 × N7:40 (12000) → 32-bit result
- DDV by 32767 → N7:11
- ADD N7:11 + N7:41 (6000) → N7:11
- If N7:11 > N7:42 (18000): N7:11 = 18000

### Rungs 0110–0111 — Phase Angle Display Scaling
- MUL N7:11 × N7:21 (1000)
- DDV by 32767 → N7:1 (Phase Angle display)
- If N7:1 negative or overflow: N7:1 = 0

### Rungs 0112–0113 — DAC Output
- MOV N7:10 → O:8.0 (Reference voltage to regulator EL1)
- MOV N7:11 → O:8.1 (Phase angle to Enerpro SIG HI)

---

## Rungs 0114–0120: Miscellaneous & Subroutines

### Rung 0114 — Power Calculation
- Computes V × I product for display

### Rungs 0115–0118 — Status Bit Mapping to DCM
- Various status bits mapped to O:1 DCM output words
- Uses OSR-gated timing

### Rung 0119–0120 — Subroutine Calls
- JSR U:3 — COPY subroutine (I/O to B3)
- JSR U:4 — SCALE subroutine

---

## Subroutine: COPY (LAD 3, 6 rungs)

Copies I/O module data to B3 register array for touch panel display and interlock evaluation.

## Subroutine: SCALE (LAD 4, 5 rungs)

Scales analog values using multipliers for display purposes.

