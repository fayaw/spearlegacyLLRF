# 09 — Binary Bit Register Reference

> Complete B3:0–B3:5 bit maps with labels, rung cross-references, and normal operating values.

## Register Summary (Normal Operation Values)

| Register | Bit 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|----------|--------|----|----|----|----|----|----|---|---|---|---|---|---|---|---|---|
| B3:0 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 |
| B3:1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| B3:2 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 0 | 1 | 1 | 1 |
| B3:3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| B3:4 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |

> Values shown are typical for normal operation at ~500 mA, ~2850 kV.

---

## B3:0 — Main Control Register

| Bit | Hex | Label | Normal | Set In Rung | Description |
|-----|-----|-------|--------|-------------|-------------|
| 15 | 0x8000 | Contactor Ready | 1 | 30 | Transformer OK + Contactor OK |
| 14 | 0x4000 | Alarm Reset | 1 | 1, 7, 14, 20–26, 28, 29, 37 | Master alarm bit — latches on any fault |
| 13 | 0x2000 | Fast Inhibit | 1 | 10, 13 | Enerpro fast inhibit latch |
| 12 | 0x1000 | (unused) | 0 | — | — |
| 11 | 0x0800 | (unused) | 0 | — | — |
| 10 | 0x0400 | Reset | 0 | 1 | Master reset (momentary) |
| 9 | 0x0200 | No Xformer Fault | 1 | 61 | All transformer inputs OK |
| 8 | 0x0100 | Contactor Latch | 1 | 2 | Contactor is closed |
| 7 | 0x0080 | (unused) | 0 | — | — |
| 6 | 0x0040 | Enable | 1 | 17 | System enabled (key + PPS + E-stop clear) |
| 5 | 0x0020 | (Panel Open) | 0 | — | Panel open bit |
| 4 | 0x0010 | SCR On Latch | 1 | 4 | SCR firing enabled |
| 3 | 0x0008 | (Panel On Bit) | 0 | — | Panel on button |
| 2 | 0x0004 | Regulator On | 1 | 10 | Voltage regulation active |
| 1 | 0x0002 | (Off Bit) | 0 | — | Off command |
| 0 | 0x0001 | Off Display | 1 | 16 | Key + PPS + ground switch OK |

---

## B3:1 — Status Display Register

| Bit | Hex | Label | Normal | Set In Rung | Description |
|-----|-----|-------|--------|-------------|-------------|
| 15 | 0x8000 | Supply On | 1 | 74 | Supply power status |
| 14 | 0x4000 | SCR On | 1 | 74 | SCR firing status |
| 13 | 0x2000 | System Ready | 1 | 3 | All conditions met for operation |
| 12 | 0x1000 | 12 kV On | 1 | 38 | 12 kV power available |
| 11 | 0x0800 | Contactor Closed Disp | 1 | 33 | Contactor closed indication |
| 10 | 0x0400 | Contactor Ctrl Pwr Disp | 1 | 40 | Contactor control power OK |
| 9 | 0x0200 | Enable Display | 1 | 17 | Enable status display |
| 8 | 0x0100 | Aux Pwr On Display | 1 | 63 | Auxiliary power ON display |
| 7 | 0x0080 | Crowbar On | 0 | 37 | Crowbar circuit active (0 = OK) |
| 6 | 0x0040 | SCR Off | 0 | 75 | SCR not firing (0 = firing) |
| 5 | 0x0020 | System Not Ready | 0 | 34 | Inverse of system ready |
| 4 | 0x0010 | 12 kV Off | 0 | 39 | 12 kV not available |
| 3 | 0x0008 | Contactor Open Disp | 0 | 31 | Contactor open (0 = closed) |
| 2 | 0x0004 | Disable Display | 0 | 64 | System disabled display |
| 1 | 0x0002 | PPS On | 0 | 15 | PPS permit active |
| 0 | 0x0001 | Emergency Off | 0 | 14 | Emergency off latch |

---

## B3:2 — Interlock Status Register

| Bit | Hex | Label | Normal | Set In Rung | Description |
|-----|-----|-------|--------|-------------|-------------|
| 15 | — | (unused) | 0 | — | — |
| 14 | — | (unused) | 0 | — | — |
| 13 | 0x2000 | SCR Drive Bit | 1 | — | SCR driver enabled |
| 12 | — | (unused) | 0 | — | — |
| 11 | — | (unused) | 0 | — | — |
| 10 | — | (unused) | 0 | — | — |
| 9 | 0x0200 | Current Limit | 0 | — | Current limit active |
| 8 | — | (unused) | 0 | — | — |
| 7 | 0x0080 | Water Flow Switch | 1 | 50 | Water flow OK |
| 6 | 0x0040 | Klystron Crowbar Latch | 1 | 48 | Klystron crowbar latch clear |
| 5 | 0x0020 | Klystron SCR Bit | 1 | 49 | Klystron SCR OK |
| 4 | 0x0010 | Klystron Crowbar | 1 | 56 | Klystron crowbar OK |
| 3 | 0x0008 | Phase Loss | 0 | 51 | No phase loss |
| 2 | 0x0004 | Contactor OK | 1 | 58 | Contactor status OK |
| 1 | 0x0002 | Xformer Latched OK | 1 | 60 | All transformer interlocks OK |
| 0 | 0x0001 | Ground Switch Open | 1 | 73 | Ground switch status |

---

## B3:3 — Alarm Latch Register

| Bit | Hex | Label | Normal | Set In Rung | Description |
|-----|-----|-------|--------|-------------|-------------|
| 15 | 0x8000 | SCR Driver Up Latch (H2) | 0 | 26 | H2 SCR driver fault |
| 14 | 0x4000 | (unused) | 0 | — | — |
| 13 | 0x2000 | SCR Driver Latch (H1) | 0 | 25 | H1 SCR driver fault |
| 12 | 0x1000 | Contactor Over Current Alarm | 0 | 24 | Contactor overcurrent |
| 11 | 0x0800 | Emergency Off Alarm | 0 | 14 | Emergency off triggered |
| 10 | 0x0400 | Aux Power Alarm | 0 | 28 | Aux power lost during operation |
| 9 | 0x0200 | Regulator Trip | 0 | 29 | Regulator current trip |
| 8 | 0x0100 | Contactor Alarm | 1* | 20 | Contactor not ready |
| 7 | 0x0080 | Xformer Alarm | 0 | 21 | Transformer interlock fault |
| 6 | 0x0040 | Regulator Over Voltage | 0 | 23 | Overvoltage detected |
| 5 | 0x0020 | Regulator Over Current | 0 | 22 | Overcurrent detected |
| 4 | — | (unused) | 0 | — | — |
| 3 | — | (unused) | 0 | — | — |
| 2 | 0x0004 | Open Load Latch | 0 | 7 | Open load detected |
| 1 | 0x0002 | Crowbar | 0 | 37 | Crowbar fired |
| 0 | 0x0001 | Alarm | 0 | 19 | Master alarm summary |

> (*) B3:3/8 reads 1 in the sample data — may indicate a transient contactor alarm condition during measurement.

---

## B3:4 — Fault Latch Register

| Bit | Hex | Label | Normal | Set In Rung | Description |
|-----|-----|-------|--------|-------------|-------------|
| 15 | 0x8000 | Xformer Arc Trip | 1* | 57 | Transformer arc detected |
| 14 | 0x4000 | Ground Tank Oil Level | 1* | 52 | Ground tank oil low |
| 13 | 0x2000 | Klystron Arc Trip | 1* | 55 | Klystron arc detected |
| 12 | 0x1000 | Over Voltage Latch | 1* | 54 | Overvoltage fault latched |
| 11 | 0x0800 | Over Current Latch | 1* | 53 | Overcurrent fault latched |
| 10 | 0x0400 | Crowbar Latch | 1* | 13 | Crowbar fault latched |
| 9 | 0x0200 | SCR 2 Latch | 1 | 72 | SCR 2 status |
| 8 | 0x0100 | SCR 1 Latch | 1 | 71 | SCR 1 status |
| 7 | 0x0080 | Oil Pump Flow | 0 | 47 | Oil pump not flowing |
| 6 | 0x0040 | DC Power Fault | 1 | 59 | DC power fault |
| 5 | 0x0020 | Over Current Trip Latch | 1 | 58 | Current trip latched |
| 4 | 0x0010 | Sudden Pressure | 1 | 46 | Sudden pressure event |
| 3 | 0x0008 | Low Oil | 1 | 45 | Low oil level |
| 2 | 0x0004 | SCR Oil Tank Level | 1 | 44 | SCR oil level OK |
| 1 | 0x0002 | Oil Temp | 1 | 43 | Oil temperature OK |
| 0 | 0x0001 | Pressure Latch | 1 | 41 | Pressure interlock OK |

> (*) Many B3:4 bits show as 1 in the sample data. These are latching fault indicators — a 1 in some cases means the fault latch is set (fault occurred and is being held), while in others it reflects the normal state of the NC interlock chain.

---

## B3:5 — OSR and Miscellaneous Register

| Bit | Hex | Label | Normal | Set In Rung | Description |
|-----|-----|-------|--------|-------------|-------------|
| 15 | — | (unused) | — | — | — |
| 14 | — | (unused) | — | — | — |
| 13 | — | (unused) | — | — | — |
| 12 | 0x1000 | Vacuum Latch | — | 42 | Vacuum interlock latch |
| 11 | 0x0800 | SCR 2 Status | — | 71 | SCR 2 firing status |
| 10 | 0x0400 | SCR 1 Status | — | 72 | SCR 1 firing status |
| 9 | 0x0200 | (OSR for Rung 105) | — | 105 | OSR bit — 640 ms period |
| 8 | 0x0100 | (OSR for Rung 92) | — | 92 | OSR bit — 160 ms period |
| 7 | 0x0080 | (OSR for Rung 97) | — | 97 | OSR bit — 80 ms |
| 6 | 0x0040 | (OSR for Rung 96) | — | 96 | OSR bit — 80 ms |
| 5 | 0x0020 | (OSR for Rung 94) | — | 94 | OSR bit — 80 ms |
| 4 | 0x0010 | (OSR for Rung 93) | — | 93 | OSR bit — 80 ms |
| 3 | 0x0008 | Enerpro Phase Loss | — | 1, 116 | Enerpro phase loss status |
| 2 | 0x0004 | (OSR for Rung 87) | — | 87 | OSR bit — 80 ms |
| 1 | 0x0002 | (OSR for Rung 86) | — | 86 | OSR bit — 80 ms |
| 0 | 0x0001 | (OSR for Rung 104) | — | 104 | OSR bit — 80 ms |

---

## OSR Timing Cross-Reference

One Shot Rising (OSR) bits use the S:4 timing register bits to gate rung execution at fixed intervals:

| Rung | S:4 Bit | Period (ms) | OSR Word | OSR Bit | Function |
|------|---------|-------------|----------|---------|----------|
| 86 | 2 | 80 | B3:5 | 1 | Analog scaling |
| 87 | 2 | 80 | B3:5 | 2 | Analog scaling |
| 92 | 3 | 160 | B3:5 | 8 | DCM data transfer |
| 93 | 2 | 80 | B3:5 | 4 | Analog scaling |
| 94 | 2 | 80 | B3:5 | 5 | Analog scaling |
| 96 | 2 | 80 | B3:5 | 6 | Analog scaling |
| 97 | 2 | 80 | B3:5 | 7 | Analog scaling |
| 104 | 2 | 80 | B3:5 | 0 | Voltage reference filter |
| 105 | 5 | 640 | B3:5 | 9 | Constant loading |
| 115 | — | — | B3:12 | 8 | Status update |
| 117 | 6 | 1280 | B3:17 | 0 | Status update |
| 118 | 7 | 2560 | B3:17 | 1 | Status update |

**S:4 Bit Timing Formula:**

The S:4 register increments every 10 ms. Each bit *n* has period = 2^(n+1) × 10 ms, with 50% duty cycle.

| S:4 Bit | Period | Half-period (on time) |
|---------|--------|-----------------------|
| 0 | 20 ms | 10 ms |
| 1 | 40 ms | 20 ms |
| 2 | 80 ms | 40 ms |
| 3 | 160 ms | 80 ms |
| 4 | 320 ms | 160 ms |
| 5 | 640 ms | 320 ms |
| 6 | 1280 ms | 640 ms |
| 7 | 2560 ms | 1280 ms |

