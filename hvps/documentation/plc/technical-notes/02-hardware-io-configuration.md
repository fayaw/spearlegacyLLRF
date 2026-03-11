# 02 — Hardware & I/O Configuration

## Binary Inputs

### Slot 2 — 1746-IO8 (Combo I/O)

| PLC Address | Function | Normal State |
|------------|----------|--------------|
| I:2/0 | 120 VAC Control Power | On |
| I:2/1 | A Phase Reference Voltage | On |
| I:2/2 | Filter Inductor 1 | Off |
| I:2/3 | Filter Inductor 2 | Off |

### Slot 6 — 1746-IB16 (16-point Digital Input)

| PLC Address | Function | Normal State |
|------------|----------|--------------|
| I:6/0 | SCR Disable Fiber Drive | Off |
| I:6/1 | Crowbar Enable Fiber Drive | Off |
| I:6/2 | Crowbar Monitor | On |
| I:6/3 | Klystron Arc Monitor | On |
| I:6/4 | SCR Trigger 1 | Off |
| I:6/5 | Transformer Arc Monitor | On |
| I:6/6 | SCR Trigger 2 | Off |
| I:6/7 | RF Crowbar (Klystron Crowbar) | On |
| I:6/8 | Ground Tank Oil Level | On |
| I:6/9 | Ground Tank Switch (Grounding Switch closed) | On |
| I:6/10 | Crowbar Oil Level | On |
| I:6/11 | SCR Oil Level | On |
| I:6/12 | Key/Emergency Off Switch (Touch Panel Key Enable) | On |
| I:6/13 | Emergency Off | On |
| I:6/14 | PPS 1 | On |
| I:6/15 | PPS 2 | On |

### Slot 7 — 1746-IV16 (16-point Digital Input)

| PLC Address | Function | Normal State |
|------------|----------|--------------|
| I:7/0 | Contactor Blocking Relay (Lockout) | Off |
| I:7/1 | Contactor Overcurrent Relay | Off |
| I:7/2 | Contactor Closed | On |
| I:7/3 | Contactor Ready | Off |
| I:7/4 | Transformer Pressure | On |
| I:7/5 | Transformer Vacuum | On |
| I:7/6 | Transformer Over Temperature | On |
| I:7/7 | Transformer Oil Level (Low Oil Level) | On |
| I:7/8 | Transformer Sudden Pressure | On |
| I:7/9 | Oil Pump On (Flow) | Off |
| I:7/10 | Water Flow Switch (Spare) | On |
| I:7/11 | Enerpro Phase Loss | On |
| I:7/12 | Regulator Current Limit | Off |
| I:7/13 | Ground Tank Relay | On |
| I:7/14 | Regulator Voltage Trip (Over Voltage Trip) | Off |
| I:7/15 | Regulator Current Trip | Off |

### Slot 1 — 1747-DCM-FULL (Inputs from VXI/EPICS)

| PLC Address | Function |
|------------|----------|
| I:1/48 | Remote On/Off |
| I:1/64 | Control Enable |
| I:1/80 | Control Reset |
| I:1 Register 1 | External Reference (16-bit setpoint from IOC) |
| I:1 Register 2 | Maximum External Reference from VXI DCM |

---

## Binary Outputs

### Slot 2 — 1746-IO8 (Combo I/O Outputs)

| PLC Address | Function | Normal State |
|------------|----------|--------------|
| O:2/0 | AC Bias Power Supply | On |
| O:2/1 | 120 VDC Power Supply | On |
| O:2/2 | 240 VDC Power Supply | On |
| O:2/3 | Ground Tank Relay Coil (GRD Switch Relay) | On |

### Slot 5 — 1746-OX8 (8-point Relay Output)

| PLC Address | Function | Normal State |
|------------|----------|--------------|
| O:5/0 | SCR Enable (Control System Enable) | On |
| O:5/1 | Contactor On (Close Contactor) | On |
| O:5/2 | Contactor Enable (Crowbar On) | On |
| O:5/3 | Force Crowbar (Crowbar Forced On) | Off |
| O:5/4 | Crowbar Off (Crowbar Enable) | On |
| O:5/5 | Enerpro Slow Start | Off |
| O:5/6 | Enerpro Fast Inhibit | On |
| O:5/7 | Regulator Reset | Off |

---

## Analog Inputs

### Slot 8 — AB-1746-NIO4V (4-channel Analog I/O)

| Channel | Function | PLC Destination | Rung |
|---------|----------|-----------------|------|
| IN 0 | Output voltage monitor from regulator card (J3-1) | N7:12 (via N7:19 offset) | 76 |
| IN 1 | Readback of phase control voltage to Enerpro (SIG HI) | N7:13 | 88 |

### Slot 9 — AB-1746-NI4 (4-channel Analog Input)

| Channel | Function | PLC Destination | Rung |
|---------|----------|-----------------|------|
| IN 0 | Input AC current monitor from regulator card (J3-2) | N7:14 (via N7:9 offset) | 78 |
| IN 1 | Output voltage monitor 1 from HVPS (splits to J1-1 of regulator) | N7:15 | 80 |
| IN 2 | Output voltage monitor 2 from HVPS (redundant) | N7:16 | 81 |
| IN 3 | Output DC current monitor (Danfysik) from grounding tank | N7:17 | 82 |

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

| Register | Function |
|----------|----------|
| I:1 Register 1 | External Reference from VXI DCM (16-bit setpoint) |
| I:1 Register 2 | Maximum External Reference from VXI DCM |

### Outputs to VXI DCM (O:1 bank)

| Register | Function |
|----------|----------|
| O:1 Register 1 | AC Current (N7:4) |
| O:1 Register 2 | Reference Out Voltage to EL1 (N7:10) |
| O:1 Register 3 | HVPS Voltage Monitor 1 (N7:15) |
| O:1 Register 4 | HVPS Current Monitor — Danfysik (N7:17) |
| O:1 Register 5 | Maximum Internal Voltage Reference (N7:32 or N7:33) |

---

## Thermocouple Module (Slot 3)

Thermocouple inputs are copied into N7:100–N7:107 via COP instruction in Rung 92.

| Register | Channel | Suspected Function |
|----------|---------|-------------------|
| N7:100 | TC Ch 0 | Phase Upper Thermocouple |
| N7:101 | TC Ch 1 | Phase Lower Thermocouple |
| N7:102 | TC Ch 2 | Crowbar Tank |
| N7:103 | TC Ch 3 | Control Cabinet |
| N7:104–N7:107 | TC Ch 4–7 | Additional sensors |

Temperature thresholds used in oil temperature interlock (Rung 43):
- N7:108 = 800 (upper limit, Ch 0)
- N7:109 = 800 (upper limit, Ch 1)

