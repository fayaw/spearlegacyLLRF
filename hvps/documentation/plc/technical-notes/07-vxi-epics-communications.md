# 07 — VXI/EPICS Communications

## Overview

The PLC communicates with the EPICS control system through:

```
SLC 500 PLC  ←→  1747-DCM (Slot 1)  ←→  VXI Crate  ←→  EPICS IOC
```

The **1747-DCM (Direct Communication Module, FULL mode)** provides:
- **8 × 16-bit input words** (I:1.0 – I:1.7) — data from EPICS to PLC
- **8 × 16-bit output words** (O:1.0 – O:1.7) — data from PLC to EPICS
- **Status/control bits** mapped into the upper bit ranges of I:1 and O:1

---

## Input Data from EPICS (I:1 Bank)

### Analog Registers

| Register | Address | Function | Used In |
|----------|---------|----------|---------|
| I:1 Register 1 | I:1.1 | External Reference (voltage setpoint from EPICS IOC) | Rung 104 → N7:30 |
| I:1 Register 2 | I:1.2 | Maximum External Reference | Rung 92 → N7:33 |

### Control Bits

| Address | Function | Used In |
|---------|----------|---------|
| I:1/48 | Remote On/Off (Contactor control) | Rungs 2, 6 |
| I:1/64 | Control Enable (SCR on/off) | Rungs 4, 9 |
| I:1/80 | Control Reset | Rung 115 |

---

## Output Data to EPICS (O:1 Bank)

### Analog Registers

| Register | Address | Source | Function | Update Rate |
|----------|---------|--------|----------|-------------|
| O:1 Register 1 | O:1.1 | N7:4 | AC Current Monitor | 160 ms |
| O:1 Register 2 | O:1.2 | N7:10 | Reference Out (Voltage to EL1) | 160 ms |
| O:1 Register 3 | O:1.3 | N7:15 | HVPS Voltage Monitor 1 | 160 ms |
| O:1 Register 4 | O:1.4 | N7:17 | HVPS Current Monitor (Danfysik) | 160 ms |
| O:1 Register 5 | O:1.5 | N7:32 or N7:33 | Max Voltage Reference (whichever is lower) | 160 ms |

> All analog registers are updated in **Rung 92**, which executes every 160 ms (gated by S:4/3 with OSR B3:5/8).

### Status/Alarm Bits (O:1 bit field)

| O:1 Bit | Address | Signal | Source Rung |
|---------|---------|--------|-------------|
| 96 | O:1/96 | Overflow / Valid indicator | 104 |
| 97 | O:1/97 | 12 kV On | 38 |
| 98 | O:1/98 | AC Aux Power On | 62 |
| 99 | O:1/99 | AC Current Trip | 53 |
| 100 | O:1/100 | Klystron Arc Trip | 55 |
| 101 | O:1/101 | Contactor Closed | 32 |
| 102 | O:1/102 | Contactor Enable | 30 |
| 103 | O:1/103 | Contactor Open | 31 |
| 104 | O:1/104 | Contactor Ready | 40 |
| 105 | O:1/105 | Crowbar On | 37 |
| 106 | O:1/106 | Auxiliary Power | 63 |
| 107 | O:1/107 | Emergency Off | 14 |
| 108 | O:1/108 | Enerpro Fast Inhibit | 12 |
| 109 | O:1/109 | Enerpro Slow Start | 35 |
| 110 | O:1/110 | Low Oil | 45 |
| 111 | O:1/111 | Oil Overtemp | 43 |
| 112 | O:1/112 | Overtemp | 43 |
| 113 | O:1/113 | Over Voltage Latch | 54 |
| 114 | O:1/114 | SCR 1 Status | 72 |
| 115 | O:1/115 | SCR 2 Status | 71 |
| 116 | O:1/116 | Supply Ready | 4 |
| 117 | O:1/117 | System Ready | 3 |
| 118 | O:1/118 | Sudden Pressure | 46 |
| 119 | O:1/119 | Pressure Alarm | 41 |
| 120 | O:1/120 | PPS Status | 15 |
| 121 | O:1/121 | Remote Open Load | 7 |
| 122 | O:1/122 | Transformer Arc Trip | 57 |
| 123 | O:1/123 | DCM Bit (F.O. Crowbar Enable from LLRF) | 56 |
| 124 | O:1/124 | H1 SCR Latch | 25 |
| 125 | O:1/125 | H2 SCR Latch | 26 |
| 126 | O:1/126 | Vacuum Alarm | 42 |

---

## EPICS Process Variable Mapping

> From `hvpsPlcLabels.xlsx` — "SPEAR RF Klystron HVPS EPICS" sheet.

### Analog Process Variables

| EPICS Label | Value (Sample) | Device Type | Raw Hex | Scale Factor (ESLO) | Description |
|-------------|----------------|-------------|---------|---------------------|-------------|
| RF PLC Voltage | 72.4 kV | AB-1771DCM AI-13 bit raw | 0x1B0A | 0.02442 | Voltage from PLC |
| RF PLC Current | 22.09 A | AB-1771DCM AI-13 bit raw | 0x1711 | 0.01221 | Current from PLC |
| HVPS Current | 21.92 A | AB-SLC500DCM-Signed | 0xB81E | 0.00153 | DC current (Danfysik) |
| HVPS Voltage | 72.47 kV | AB-SLC500DCM-Signed | 0xDCD3 | 0.00305 | Output voltage |
| Regulator Voltage | 72.28 kV | AB-SLC500DCM-Signed | 0xDC83 | 0.00305 | Regulator voltage readback |
| Max Voltage Rbck | 82 kV | AB-SLC500DCM-Signed | 0xE8F5 | 0.00305 | Max voltage readback |
| AC Current | 113.29 A | AB-SLC500DCM-Signed | 0x9D09 | 0.01526 | AC line current |

### Calculated Values

| EPICS Label | Value (Sample) | Source |
|-------------|----------------|--------|
| Klys Output Pwr | 747 kW | IQA Module 1 Calc |
| Klys Coll Pwr | 843 kW | Calculated |
| Klys Efficiency | 46.94% | Calculated |
| RF PLC Coll Pwr | 973 kW | Calculated |
| Klys Perveance | 1.13 μPerv | Calculated |
| HVPS Power | 1589 kW | Calculated |

### Binary Status Process Variables

| EPICS Label | State (Sample) | Device Type | Raw Hex | Mask |
|-------------|----------------|-------------|---------|------|
| Contactor Closed | CLOSED | AB-16 bit BI | 0x20 | 0x20 |
| Contactor Open | CLOSED | AB-16 bit BI | 0x0 | 0x80 |
| Contactor Status | ON | AB-16 bit BI | 0x40 | 0x40 |
| Contactor Ready | READY | AB-16 bit BI | 0x100 | 0x100 |
| Max Volt Status | ACTIVE | AB-16 bit BI | 0x1 | 0x1 |
| Over Voltage | OK | AB-16 bit BI | 0x2 | 0x2 |
| Klystron Arc | OK | AB-16 bit BI | 0x10 | 0x10 |
| Transformer Arc | OK | AB-16 bit BI | 0x400 | 0x400 |
| Crowbar | OK | AB-16 bit BI | 0x0 | 0x200 |
| Crowbar from RF | OK | AB-16 bit BI | 0x800 | 0x800 |
| Emergency Off | OK | AB-16 bit BI | 0x0 | 0x800 |
| AC Current | OK | AB-16 bit BI | 0x8 | 0x8 |
| Over Temperature | OK | AB-16 bit BI | 0x1 | 0x1 |
| Oil Level | OK | AB-16 bit BI | 0x4000 | 0x4000 |
| Transformer Press | OK | AB-16 bit BI | 0x40 | 0x40 |
| Transfmr Vac/Press | OK | AB-16 bit BI | 0x80 | 0x80 |
| Open Load | OK | AB-16 bit BI | 0x0 | 0x200 |
| 12 kV Available | AVAIL | AB-16 bit BI | 0x2 | 0x2 |
| AC Auxiliary Pwr | ON | AB-16 bit BI | 0x4 | 0x4 |
| DC Auxiliary Pwr | ON | AB-16 bit BI | 0x400 | 0x400 |
| Enerpro Fast Inhibit | ON | AB-16 bit BI | 0x1000 | 0x1000 |
| Enerpro Slow Start | ACTIVE | AB-16 bit BI | 0x0 | 0x2000 |
| Supply Status | ON | AB-16 bit BI | 0x10 | 0x10 |
| Supply Ready | READY | AB-16 bit BI | 0x20 | 0x20 |
| PPS | PERMIT | AB-16 bit BI | 0x0 | 0x100 |
| SCR 1 | ON | AB-16 bit BI | 0x4 | 0x4 |
| SCR 2 | ON | AB-16 bit BI | 0x8 | 0x8 |

---

## Data Flow Summary

### EPICS → PLC (Commands)

```
1. Voltage setpoint     → I:1.1 → N7:30 → Low-pass filter → N7:10 → O:8.0 → Regulator EL1
2. Maximum voltage      → I:1.2 → N7:33 → Clamp limit for N7:10
3. Remote On/Off        → I:1/48 → Contactor control chain
4. Control Enable       → I:1/64 → SCR on/off chain
5. Control Reset        → I:1/80 → Reset logic
```

### PLC → EPICS (Readbacks)

```
1. AC Current (N7:4)        → O:1.1 → EPICS
2. Reference Out (N7:10)    → O:1.2 → EPICS
3. Voltage Monitor (N7:15)  → O:1.3 → EPICS
4. DC Current (N7:17)       → O:1.4 → EPICS
5. Max Volt Ref             → O:1.5 → EPICS
6. 31 status/alarm bits     → O:1/96–O:1/126 → EPICS
```

