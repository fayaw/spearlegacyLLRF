# 08 — Analog Registers & Calibration Data

## N7 Register Map — Complete

> Compiled from `hvpsPlcLabels.xlsx` (analog registers sheet) and source analysis.

### Monitored Values (Inputs / Computed)

| Register | Label | Function | Sample Value | Rungs Used |
|----------|-------|----------|-------------|------------|
| N7:0 | Requested DC Volts | Scaled output reference (display kV) | 7080 | 106, 107 |
| N7:1 | Phase Angle | Scaled phase angle (display degrees) | 442 | 110, 111 |
| N7:2 | Regulator Voltage | Scaled regulator voltage (display kV) | 7497 | 84, 85, 87 |
| N7:3 | Phase Angle Monitor | Scaled phase angle monitor | 354 | 88, 89 |
| N7:4 | AC Amps | AC current (display amps) | 1036* | 90, 91, 92, 93 |
| N7:5 | Volt Monitor 1 | Scaled voltage monitor 1 (display kV) | ~7500* | — |
| N7:6 | Volt Monitor 2 | Scaled voltage monitor 2 (display kV) | 7399 | — |
| N7:7 | DC Amps | DC current (display amps) | 2187 | — |
| N7:8 | Power | Calculated power (display kW) | 1783 | — |

> (*) Values marked with * appear to have display formatting errors per original notes.

### Raw Analog Inputs (Offset Corrected)

| Register | Label | Function | Sample Value | Source | Rungs |
|----------|-------|----------|-------------|--------|-------|
| N7:9 | AC Amp Offset | Offset correction for AC current | −117 | Fixed | 78 |
| N7:12 | Feedback Voltage | Voltage from regulator card (J3-1) + offset | 24375 | Slot 8 IN 0 | 76, 77, 84 |
| N7:13 | Phase Ang Monitor | SIG HI readback from Enerpro | 11585 | Slot 8 IN 1 | 88 |
| N7:14 | AC Current Monitor | AC current from regulator (J3-2) + offset | 7374 | Slot 9 IN 0 | 78, 79, 90, 93 |
| N7:15 | Voltage Monitor 1 | HVPS output voltage (to reg J1-1) | 24438 | Slot 9 IN 1 | 80, 86, 92, 95, 98 |
| N7:16 | Voltage Monitor 2 | HVPS output voltage (redundant) | 24215 | Slot 9 IN 2 | 81, 100 |
| N7:17 | DC Current Monitor | Danfysik current transformer | 14330 | Slot 9 IN 3 | 82, 83, 92, 94, 95, 102 |
| N7:18 | Power Calculation | V × I product | 10724 | Calculated | 95, 96, 97, 114 |
| N7:19 | Offset Feedback | Feedback voltage offset | −122 | Fixed | 76 |

### Control Registers (Setpoints / References)

| Register | Label | Function | Sample Value | Rungs |
|----------|-------|----------|-------------|-------|
| N7:10 | Reference Out | Voltage reference to regulator EL1 | 23167 | 11, 92, 104, 105, 106, 108, 112 |
| N7:11 | Phase Out | Phase angle to Enerpro SIG HI | 14488 | 11, 108, 109, 110, 113 |
| N7:30 | External Reference | Setpoint from EPICS (filtered target) | 23134 | 104 |
| N7:31 | Internal Reference | Minimum reference value | 100 | 104, 105 |
| N7:32 | Max Internal Reference | Maximum voltage reference | 32000 | 92, 105 |
| N7:33 | Max External Reference | External max from EPICS | 26869 | 92, 104 |
| N7:43 | Delta | Current ramp delta (N7:30 − N7:10)/10 | 0 | 104 |

### Scaling Multipliers

| Register | Label | Value | Used For | Rungs |
|----------|-------|-------|----------|-------|
| N7:20 | Output Reference Multiplier | 10000 | N7:0 = N7:10 × 10000 / 32767 | 106 |
| N7:21 | Phase Angle Multiplier (display) | 1000 | N7:1 = N7:11 × 1000 / 32767 | 110 |
| N7:22 | Voltage Multiplier | 10075 | N7:2 = N7:12 × 10075 / 32767 | 84 |
| N7:23 | Phase Angle Monitor Multiplier | 1000 | N7:3 = N7:13 × 1000 / 32767 | 88 |
| N7:24 | AC Current Multiplier | 4600 | N7:4 = N7:14 × 4600 / 32767 | 90 |
| N7:25 | Voltage Monitor 1 Multiplier | 10000 | N7:5 = N7:15 × 10000 / 32767 | — |
| N7:26 | Voltage Monitor 2 Multiplier | 10000 | N7:6 = N7:16 × 10000 / 32767 | — |
| N7:27 | DC Current Multiplier | 5000 | N7:7 = N7:17 × 5000 / 32767 | — |
| N7:29 | Power Multiplier | 6 | N7:8 = N7:18 × 6 / 32767 | — |

### Phase Angle Control Constants

| Register | Label | Value | Function |
|----------|-------|-------|----------|
| N7:40 | Phase Angle Multiplier | 12000 | N7:11 = N7:10 × 12000 / 32767 + 6000 |
| N7:41 | Add Offset | 6000 | Minimum phase angle offset |
| N7:42 | Max Phase Angle | 18000 | Maximum N7:11 value |

### Display Divisors

| Register | Label | Value | Function |
|----------|-------|-------|----------|
| N7:44 | Div Plot Volts | 43 | Plot scaling |
| N7:45 | Div Plot Current | 7 | Plot scaling |
| N7:46 | Div Plot Power | 260 | Plot scaling |
| N7:47 | Div Meter Volts | 320 | Meter gauge scaling |
| N7:48 | Div Meter Current | 198 | Meter gauge scaling |
| N7:49 | Div Meter Power | 162 | Meter gauge scaling |

### Startup Constants (loaded in Rung 105)

| Register | Label | Value | Loaded To | Function |
|----------|-------|-------|-----------|----------|
| N7:71 | Max Voltage | 32000 | N7:32 | Maximum internal voltage reference |
| N7:72 | Max Phase Angle | 18000 | N7:42 | Maximum phase angle |
| N7:73 | Internal Reference | 100 | N7:31 | Minimum reference value |

### Ratio Tracking Registers (Rung 105)

| Register | Label | Calculation |
|----------|-------|-------------|
| N7:74 | Max V / Ref Out | N7:71 / N7:10 × 32767 |
| N7:75 | Int Ref / Ref Out | N7:73 / N7:10 × 32767 |

### Display Values

| Register | Label | Value |
|----------|-------|-------|
| N7:34 | Plot Volts | 174 |
| N7:35 | Plot Current | 148 |
| N7:36 | Plot Power | 10075 |
| N7:37 | Display Volts | 76 |
| N7:38 | Display Current | 72 |
| N7:39 | Display Power | 66 |

### Thermocouple Readings

| Register | Label | Sample Value (°C) |
|----------|-------|-------------------|
| N7:100 | TC Ch 0 (Phase Upper) | 55 |
| N7:101 | TC Ch 1 (Phase Lower) | 56 |
| N7:102 | TC Ch 2 (Crowbar Tank) | 40 |
| N7:103 | TC Ch 3 (Control Cabinet) | 32 |

### Fuel Gauge Display Values

| Parameter | Value |
|-----------|-------|
| Volts kV | 74.97 |
| Amps DC | 21.91 |
| Amps Line AC | 103.6 |

---

## Regulator Test Point Measurements

> From `hvpsMeasurements20220314.xlsx` — measurements taken March 14, 2022.

### Raw Measurement Data

| vGap (V) | vHvps (kV) | N7:30 | N7:10 | N7:11 | N7:13 | N7:15 | TP4 (V) | TP7 (V) |
|-----------|-----------|-------|-------|-------|-------|-------|---------|---------|
| 2000 | 60.01 | 19570 | 19570 | 13167 | 10548 | 19702 | 6.010 | −0.3047 |
| 2200 | 61.62 | 19932 | 19932 | 13300 | 10655 | 20190 | 6.162 | −0.3045 |
| 2400 | 62.94 | 20266 | 20266 | 13422 | 10750 | 20655 | 6.291 | −0.3043 |
| 2600 | 64.42 | 20616 | 20616 | 13550 | 10851 | 21104 | 6.439 | −0.3044 |
| 2800 | 65.88 | 20980 | 20980 | 13683 | 10955 | 21540 | 6.585 | −0.3044 |
| 3000 | 67.37 | 21350 | 21350 | 13819 | 11062 | 22068 | 6.726 | −0.3046 |
| 3200 | 68.74 | 21721 | 21721 | 13955 | 11170 | 22543 | 6.871 | −0.3044 |

### Constants Used in Measurement Analysis

| Parameter | Value |
|-----------|-------|
| N7:40 (Phase Angle Multiplier) | 12000 |
| N7:41 (Add Offset) | 6000 |

### Derived Relationships

**N7:11 (Phase Out) calculation verification:**

```
N7:11 = (N7:10 × 12000) / 32767 + 6000

Example (vGap = 2000):
  N7:11 = (19570 × 12000) / 32767 + 6000
        = 234840000 / 32767 + 6000
        = 7168 + 6000 = 13168  (measured: 13167 ✓)
```

**N7:15 (Voltage Monitor) vs vHvps:**

The relationship between N7:15 and the physical HVPS voltage is approximately:
```
vHvps (kV) ≈ N7:15 × 0.00305
```

**TP4 (Test Point 4) vs vGap:**

TP4 appears to scale linearly with vGap:
```
TP4 ≈ vGap × 0.003 + some_offset
```

**TP7 (Test Point 7):**

TP7 is approximately constant at −0.3045 V across all operating points, suggesting it is a fixed reference or offset voltage.

### EPICS Scale Factors (for DCM-Signed values)

| Signal | ESLO | Example Calculation |
|--------|------|---------------------|
| HVPS Voltage | 0.00305 | 0xDCD3 (56531 decimal) × 0.00305 ≈ 172.4... but offset by 32768 → (56531−32768) × 0.00305 ≈ 72.4 kV |
| HVPS Current | 0.00153 | 0xB81E (47134) → (47134−32768) × 0.00153 ≈ 21.98 A |
| Regulator Voltage | 0.00305 | 0xDC83 (56451) → (56451−32768) × 0.00305 ≈ 72.2 kV |
| AC Current | 0.01526 | 0x9D09 (40201) → (40201−32768) × 0.01526 ≈ 113.5 A |
| RF PLC Voltage | 0.02442 | 0x1B0A (6922) → 6922 × 0.02442 ≈ 169... (13-bit) |
| RF PLC Current | 0.01221 | 0x1711 (5905) → 5905 × 0.01221 ≈ 72.1... (13-bit) |

> Note: AB-SLC500DCM-Signed values appear to be offset binary (unsigned + 32768 offset), while AB-1771DCM values use a 13-bit raw format.

