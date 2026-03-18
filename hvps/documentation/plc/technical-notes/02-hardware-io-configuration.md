# 02 — Hardware & I/O Configuration

## Binary Inputs

### Slot 2 — 1746-IO8 (Combo I/O)

| PLC Address | B3 Copy Dest | Function | Normal State |
|------------|--------------|----------|--------------| 
| I:2/0 | B3:12/0 | 120 VAC Control Power | On |
| I:2/1 | B3:12/1 | A Phase Reference Voltage | On |
| I:2/2 | B3:12/2 | Filter Inductor 1 | Off |
| I:2/3 | B3:12/3 | Filter Inductor 2 | Off |

> **Note:** I:2 is copied to B3:12 by the COPY subroutine (LAD 3, Rung 0000) for QuickPanel display access.

### Slot 6 — 1746-IB16 (16-point 24V DC Digital Input)

| PLC Address | B3 Copy Dest | Function | Normal State |
|------------|--------------|----------|--------------| 
| I:6/0 | B3:13/0 | SCR Disable Fiber Drive | Off |
| I:6/1 | B3:13/1 | Crowbar Enable Fiber Drive | Off |
| I:6/2 | B3:13/2 | Crowbar Monitor | On |
| I:6/3 | B3:13/3 | Klystron Arc Monitor | On |
| I:6/4 | B3:13/4 | SCR Trigger 1 | Off |
| I:6/5 | B3:13/5 | Transformer Arc Monitor | On |
| I:6/6 | B3:13/6 | SCR Trigger 2 | Off |
| I:6/7 | B3:13/7 | RF Crowbar (Klystron Crowbar) | On |
| I:6/8 | B3:13/8 | Ground Tank Oil Level | On |
| I:6/9 | B3:13/9 | Ground Tank Switch (Grounding Switch Closed) | On |
| I:6/10 | B3:13/10 | Crowbar Oil Level | On |
| I:6/11 | B3:13/11 | SCR Oil Level | On |
| I:6/12 | B3:13/12 | Key/Emergency Off Switch (Touch Panel Key Enable) | On |
| I:6/13 | B3:13/13 | Emergency Off | On |
| I:6/14 | B3:13/14 | PPS 1 | On |
| I:6/15 | B3:13/15 | PPS 2 | On |

> **Note:** I:6 is copied to B3:13 by the COPY subroutine (LAD 3, Rung 0001).

### Slot 7 — 1746-IV16 (16-point 24V DC Digital Input)

| PLC Address | B3 Copy Dest | Function | Normal State |
|------------|--------------|----------|--------------| 
| I:7/0 | B3:14/0 | Contactor Blocking Relay (Lockout) | Off |
| I:7/1 | B3:14/1 | Contactor Overcurrent Relay | Off |
| I:7/2 | B3:14/2 | Contactor Closed | On |
| I:7/3 | B3:14/3 | Contactor Ready | Off |
| I:7/4 | B3:14/4 | Transformer Pressure | On |
| I:7/5 | B3:14/5 | Transformer Vacuum | On |
| I:7/6 | B3:14/6 | Transformer Over Temperature | On |
| I:7/7 | B3:14/7 | Transformer Oil Level (Low Oil Level) | On |
| I:7/8 | B3:14/8 | Transformer Sudden Pressure | On |
| I:7/9 | B3:14/9 | Oil Pump On (Flow) | Off |
| I:7/10 | B3:14/10 | Water Flow Switch (Spare) | On |
| I:7/11 | B3:14/11 | Enerpro Phase Loss | On |
| I:7/12 | B3:14/12 | Regulator Current Limit | Off |
| I:7/13 | B3:14/13 | Ground Tank Relay | On |
| I:7/14 | B3:14/14 | Regulator Voltage Trip (Over Voltage Trip) | Off |
| I:7/15 | B3:14/15 | Regulator Current Trip | Off |

> **Note:** I:7 is copied to B3:14 by the COPY subroutine (LAD 3, Rung 0002).

### Slot 1 — 1747-DCM-FULL (Inputs from VXI/EPICS)

| PLC Address | Function | Rungs Used |
|------------|----------|------------|
| I:1/48 | Remote On/Off | 2, 6 |
| I:1/64 | Control Enable | 4, 9 |
| I:1/80 | Control Reset | 115 |
| I:1 Register 1 | External Reference (16-bit setpoint from IOC) | 104 |
| I:1 Register 2 | Maximum External Reference from VXI DCM | 92 |

---

## Binary Outputs

### Slot 2 — 1746-IO8 (Combo I/O Outputs)

| PLC Address | B3 Copy Dest | Function | Normal State |
|------------|--------------|----------|--------------| 
| O:2/0 | B3:15/0 | AC Bias Power Supply | On |
| O:2/1 | B3:15/1 | 120 VDC Power Supply | On |
| O:2/2 | B3:15/2 | 240 VDC Power Supply | On |
| O:2/3 | B3:15/3 | Ground Tank Relay Coil (GRD Switch Relay) | On |

> **Note:** O:2 is copied to B3:15 by the COPY subroutine (LAD 3, Rung 0003).

### Slot 5 — 1746-OX8 (8-point Relay Output)

| PLC Address | B3 Copy Dest | Function | Normal State |
|------------|--------------|----------|--------------| 
| O:5/0 | B3:16/0 | SCR Enable (Control System Enable) | On |
| O:5/1 | B3:16/1 | Contactor On (Close Contactor) | On |
| O:5/2 | B3:16/2 | Contactor Enable (Crowbar On) | On |
| O:5/3 | B3:16/3 | Force Crowbar (Crowbar Forced On) | Off |
| O:5/4 | B3:16/4 | Crowbar Off (Crowbar Enable) | On |
| O:5/5 | B3:16/5 | Enerpro Slow Start | Off |
| O:5/6 | B3:16/6 | Enerpro Fast Inhibit | On |
| O:5/7 | B3:16/7 | Regulator Reset | Off |

> **Note:** O:5 is copied to B3:16 by the COPY subroutine (LAD 3, Rung 0004).

---

## Analog Inputs

### Slot 8 — AB-1746-NIO4V (4-channel Analog I/O)

| Channel | Function | PLC Destination | Rung |
|---------|----------|-----------------|------|
| IN 0 | Output voltage monitor from regulator card (J3-1) | N7:12 (via N7:19 offset addition) | 76, 77 |
| IN 1 | Readback of phase control voltage to Enerpro (SIG HI) | N7:13 | 88 |

### Slot 9 — AB-1746-NI4 (4-channel Analog Input)

| Channel | Function | PLC Destination | Rung |
|---------|----------|-----------------|------|
| IN 0 | Input AC current monitor from regulator card (J3-2) | N7:14 (via N7:9 offset addition) | 78 |
| IN 1 | Output voltage monitor 1 from HVPS (parallel path to J1-1 of regulator card) | N7:15 | 80 |
| IN 2 | Output voltage monitor 2 from HVPS (redundant monitor) | N7:16 | 81 |
| IN 3 | Output DC current monitor (Danfysik) from grounding tank | N7:17 | 82, 83 |

---

## Analog Outputs

### Slot 8 — AB-1746-NIO4V (4-channel Analog I/O)

| Channel | Function | PLC Source | Rung |
|---------|----------|------------|------|
| OUT 0 | Reference voltage setpoint to regulator card input (EL1) | N7:10 → O:8.0 | 112 |
| OUT 1 | Phase control contribution to Enerpro SIG HI input (via 1 kΩ resistor, summed with regulator output over 7.5 kΩ) | N7:11 → O:8.1 | 113 |

---

## VXI/EPICS DCM Interface

### Inputs from VXI DCM (I:1 bank)

| Register | Function | Used In Rung |
|----------|----------|--------------|
| I:1 Register 1 | External Reference from VXI DCM (16-bit setpoint) | 104 |
| I:1 Register 2 | Maximum External Reference from VXI DCM | 92 |

### Outputs to VXI DCM (O:1 bank)

| Register | Source | Function | Updated In Rung |
|----------|--------|----------|-----------------|
| O:1 Register 1 | N7:4 | AC Current (line AC amps) | 92, 93 |
| O:1 Register 2 | N7:10 | Reference Out Voltage to EL1 | 92 |
| O:1 Register 3 | N7:15 | HVPS Voltage Monitor 1 | 92 |
| O:1 Register 4 | N7:17 | HVPS Current Monitor — Danfysik | 92 |
| O:1 Register 5 | N7:32 or N7:33 | Maximum Internal Voltage Reference | 92 |

> **Note:** In Rung 92, if N7:32 > N7:33, then N7:33 is sent to O:1 Register 5 instead of N7:32. Also in Rung 92, I:1.2 (Register 2) is moved into N7:33 (Maximum External Reference from the IOC).

### DCM Status Bit Outputs (O:1 bank — individual bits)

These individual bits are set in ladder logic and sent to the VXI/EPICS IOC:

| Rung | Bank | Bit | Function |
|------|------|-----|----------|
| 104 | O:1 | 96 | Reference overflow/valid status |
| 38 | O:1 | 97 | 12 kV On |
| 62 | O:1 | 98 | AC Aux Power On |
| 53 | O:1 | 99 | AC Current Trip |
| 55 | O:1 | 100 | Klystron Arc Trip |
| 32 | O:1 | 101 | Contactor Closed |
| 30 | O:1 | 102 | Contactor Enable |
| 31 | O:1 | 103 | Contactor Open |
| 40 | O:1 | 104 | Contactor Ready |
| 37 | O:1 | 105 | Crowbar On |
| 63 | O:1 | 106 | Auxiliary Power |
| 14 | O:1 | 107 | Emergency Off |
| 12 | O:1 | 108 | Enerpro Fast Inhibit |
| 35 | O:1 | 109 | Enerpro Slow Start |
| 45 | O:1 | 110 | Low Oil |
| 43 | O:1 | 111 | Oil Overtemp |
| 43 | O:1 | 112 | Overtemp |
| 54 | O:1 | 113 | Over Voltage Latch |
| 72 | O:1 | 114 | SCR 1 Status |
| 71 | O:1 | 115 | SCR 2 Status |
| 4 | O:1 | 116 | Supply Ready |
| 3 | O:1 | 117 | System Ready |
| 46 | O:1 | 118 | Sudden Pressure |
| 41 | O:1 | 119 | Pressure Alarm |
| 15 | O:1 | 120 | PPS Status |
| 7 | O:1 | 121 | Remote Open Load |
| 57 | O:1 | 122 | Transformer Arc Trip |
| 56 | O:1 | 123 | DCM bit (Signal from F.O. Crowbar Enable from LLRF) |
| 25 | O:1 | 124 | H1 SCR Latch |
| 26 | O:1 | 125 | H2 SCR Latch |
| 42 | O:1 | 126 | Vacuum Alarm |

---

## Thermocouple Module (Slot 3)

Thermocouple inputs are copied into N7:100–N7:107 via COP instruction in Rung 92. Only 4 channels are actively scaled by the SCALE subroutine (LAD 4) for QuickPanel display:

| Register | Input | Function | Scaled Output | Scale Range |
|----------|-------|----------|---------------|-------------|
| N7:100 | TC Ch 0 | SCR Top Oil (Phase Upper TC) | N7:110 | 0–999 → 0–9999 |
| N7:101 | TC Ch 1 | SCR Bottom Oil (Phase Lower TC) | N7:111 | 0–999 → 0–9999 |
| N7:102 | TC Ch 2 | Crowbar Tank Oil | N7:112 | 0–999 → 0–9999 |
| N7:103 | TC Ch 3 | Control Cabinet Air Temperature | N7:113 | 0–999 → 0–9999 |
| N7:104–N7:107 | TC Ch 4–7 | Additional sensors (data copied but not scaled) | — | — |

Temperature thresholds used in oil temperature interlock (Rung 43):
- N7:108 = 800 (upper limit, Ch 0)
- N7:109 = 800 (upper limit, Ch 1)

### Typical Temperature Values (at operating point)

| Register | Channel | Value |
|----------|---------|-------|
| N7:110 | TC Ch 0 — SCR Top Oil | 55 |
| N7:111 | TC Ch 1 — SCR Bottom Oil | 56 |
| N7:112 | TC Ch 2 — Crowbar Tank Oil | 40 |
| N7:113 | TC Ch 3 — Control Cabinet Air | 32 |

---

## Touch Panel Interlock Indicators

The touch panel displays interlock status using B3 register bits (which mirror I/O words via the COPY subroutine). All indicators listed below are illuminated during normal operation:

| B3 Identifier | Function | Source |
|---------------|----------|--------|
| B3:4/11 | AC Overcurrent Fault | Fault latch |
| B3:3/6 | DC Overvoltage OK | Alarm latch |
| B3:3/5 | DC Overcurrent OK | Alarm latch |
| B3:13/8 | Ground Tank Oil Fault | I:6/8 copy |
| B3:1/0 | Ground Tank E-Stop OK | Status |
| B3:1/7 | Crowbar OK | Status |
| B3:4/13 | Klystron Arc Fault | Fault latch |
| B3:4/15 | Transformer Arc Fault | Fault latch |
| B3:2/4 | Klystron Crowbar Fault | Interlock |
| B3:3/2 | Open Load OK | Alarm latch |
| B3:3/14 | H1 SCR Drivers OK | — |
| B3:3/15 | H2 SCR Drivers OK | — |
| B3:13/11 | SCR Oil Level Low | I:6/11 copy |
| B3:13/10 | Crowbar Oil Level Low | I:6/10 copy |
| B3:14/7 | Main Tank Oil Level Low | I:7/7 copy |
| B3:14/6 | Oil Temperature Fault | I:7/6 copy |
| B3:2/7 | Oil Flow Switch Fault | Interlock |
| B3:14/4 | Pressure Fault | I:7/4 copy |
| B3:14/8 | Relief Valve Fault (Sudden Pressure) | I:7/8 copy |
| B3:14/5 | Vacuum Fault | I:7/5 copy |
| B3:0/3 | Summary Not Ready | Control |
| B3:5/12 | Vacuum Fault (Latched) | Misc |
| B3:4/10 | Pressure Fault Latched | Fault latch |
| B3:4/1 | Oil Temperature Fault Latched | Fault latch |
| B3:4/2 | SCR/Crowbar Oil Level Low Latched | Fault latch |
| B3:4/3 | Main Tank Oil Level Low Latched | Fault latch |
| B3:4/4 | Sudden Pressure Fault Latched | Fault latch |

---

## COPY Subroutine (LAD 3) — I/O Word Mapping

The COPY subroutine runs periodically (called from Rung 117 at 1280 ms intervals) and copies I/O word registers to B3 registers for QuickPanel touch panel display access:

| LAD 3 Rung | Source | Destination | Description |
|------------|--------|-------------|-------------|
| 0000 | #I:2.0 | #B3:12 | Input module slot 2 (1746-IO8) |
| 0001 | #I:6.0 | #B3:13 | Input module slot 6 (1746-IB16) |
| 0002 | #I:7.0 | #B3:14 | Input module slot 7 (1746-IV16) |
| 0003 | #O:2.0 | #B3:15 | Output module slot 2 (1746-IO8) |
| 0004 | #O:5.0 | #B3:16 | Output module slot 5 (1746-OX8) |
| 0005 | — | — | END |

---

## SCALE Subroutine (LAD 4) — Thermocouple Scaling

The SCALE subroutine runs periodically (called from Rung 118 at 2560 ms intervals) and converts raw thermocouple values for QuickPanel display:

| LAD 4 Rung | Input | Output | Description | Input Range | Output Range |
|------------|-------|--------|-------------|-------------|--------------|
| 0000 | N7:100 | N7:110 | TC1 — SCR Top Oil | 0–999 | 0–9999 |
| 0001 | N7:101 | N7:111 | TC2 — SCR Bottom Oil | 0–999 | 0–9999 |
| 0002 | N7:102 | N7:112 | TC3 — Crowbar Oil | 0–999 | 0–9999 |
| 0003 | N7:103 | N7:113 | TC4 — Control Cabinet Air Temp | 0–999 | 0–9999 |
| 0004 | — | — | END | — | — |

