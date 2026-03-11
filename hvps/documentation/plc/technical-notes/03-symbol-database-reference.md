# 03 — Symbol Database Reference

> Extracted from `CasselSymbolDatabase.pdf` — SSRLV6-4-05-10, dated June 24, 2021.

## Binary Registers (B3)

### B3:0 — Main Control Bits

| Address | Symbol | Description |
|---------|--------|-------------|
| B3:0/0 | | Off Display |
| B3:0/1 | | Off Bit |
| B3:0/2 | | Regulator On |
| B3:0/3 | | Panel On Bit |
| B3:0/4 | | SCR On Latch |
| B3:0/5 | | Panel Open Bit |
| B3:0/6 | ENABLE | Enable |
| B3:0/7 | CLOSE CONTACTOR | Close Contactor button bit |
| B3:0/8 | | Contactor Latch |
| B3:0/9 | NO XFORMER FAULT | No Transformer Fault |
| B3:0/10 | RESET | Master Reset |
| B3:0/11 | RESET BIT | Reset Bit |
| B3:0/12 | CROWBAR LOCKOUT | Crowbar Lockout |
| B3:0/13 | | Fast Inhibit |
| B3:0/14 | | Alarm Bit (Alarm Reset) |
| B3:0/15 | | Contactor Ready |

### B3:1 — Status Display Bits

| Address | Symbol | Description |
|---------|--------|-------------|
| B3:1/0 | | Emergency Off Latch |
| B3:1/1 | | PPS On |
| B3:1/2 | | Disable Display |
| B3:1/3 | | Contactor Open Display |
| B3:1/4 | | 12 kV Off |
| B3:1/5 | | System Not Ready |
| B3:1/6 | | SCR Off |
| B3:1/7 | | Crowbar On |
| B3:1/8 | | Aux Pwr On Display |
| B3:1/9 | KEY ON | Enable Display |
| B3:1/10 | | Contactor Ctrl Pwr Display |
| B3:1/11 | | Contactor Closed Display |
| B3:1/12 | | 12 kV On |
| B3:1/13 | | System Ready |
| B3:1/14 | | SCR On |
| B3:1/15 | | Supply On |

### B3:2 — Interlock Status Bits

| Address | Symbol | Scope | Description |
|---------|--------|-------|-------------|
| B3:2/0 | | | Ground Switch Open |
| B3:2/1 | XFORMER LATCHED OK | | Transformer Latched OK |
| B3:2/2 | CONTACTOR OK | | Contactor OK |
| B3:2/3 | | | Phase Loss |
| B3:2/4 | _KLYSTRON_CROWBAR | Global | Klystron Crowbar |
| B3:2/5 | | | Klystron SCR Bit |
| B3:2/6 | | | Klystron Crowbar Latch |
| B3:2/7 | H20_FLOW_SWITCH | Global | Water Flow Switch |
| B3:2/8 | | | |
| B3:2/9 | CURRENT LIMIT | | Current Limit |
| B3:2/12 | | | |
| B3:2/13 | SCR DRIVE BIT | | SCR Drive Bit |
| B3:2/14 | | | |
| B3:2/15 | | | |

### B3:3 — Alarm Latch Bits

| Address | Symbol | Description |
|---------|--------|-------------|
| B3:3/0 | | Alarm |
| B3:3/1 | | Crowbar |
| B3:3/2 | | Open Load Latch |
| B3:3/3 | CROWBAR BIT | Crowbar Bit |
| B3:3/5 | | Regulator Over Current |
| B3:3/6 | | Regulator Over Voltage |
| B3:3/7 | | Transformer Alarm |
| B3:3/8 | | Contactor Alarm |
| B3:3/9 | REGULATOR TRIP BIT | Regulator Trip Bit |
| B3:3/10 | | Aux Power Alarm |
| B3:3/11 | | Emergency Off Alarm |
| B3:3/12 | CONTACTOR OVER CURRENT ALARM | Contactor Over Current Alarm |
| B3:3/13 | TRIGGER CURRENT LIMIT | SCR Driver Latch |
| B3:3/14 | | SCR Driver Latch (H1) |
| B3:3/15 | | SCR Driver Up Latch (H2) |

### B3:4 — Fault Latch Bits

| Address | Symbol | Description |
|---------|--------|-------------|
| B3:4/0 | | Pressure Latch |
| B3:4/1 | | Oil Temp Latch |
| B3:4/2 | SCR OIL TANK LEVEL | SCR Oil Tank Level |
| B3:4/3 | | Low Oil Latch |
| B3:4/4 | | Sudden Pressure |
| B3:4/5 | | Over Current Trip Latch |
| B3:4/6 | | DC Power Fault |
| B3:4/7 | VOLTAGE REFERANCE MAX | Oil Pump Flow |
| B3:4/8 | | SCR 1 Latch |
| B3:4/9 | | SCR 2 Latch |
| B3:4/10 | | Crowbar Latch |
| B3:4/11 | | Over Current Latch |
| B3:4/12 | | Over Voltage Latch |
| B3:4/13 | | Klystron Arc Trip |
| B3:4/14 | | Ground Tank Oil Level |
| B3:4/15 | | Transformer Arc Trip |

### B3:5 — Miscellaneous Bits

| Address | Symbol | Scope | Description |
|---------|--------|-------|-------------|
| B3:5/0 | | | (OSR bit for Rung 104) |
| B3:5/1 | | | (OSR bit for Rung 86) |
| B3:5/2 | | | (OSR bit for Rung 87) |
| B3:5/3 | _ENERPRO_PHASE_LOSS | Global | Enerpro Phase Loss |
| B3:5/4 | | | (OSR bit for Rung 93) |
| B3:5/5 | | | (OSR bit for Rung 94) |
| B3:5/6 | | | (OSR bit for Rung 96) |
| B3:5/7 | | | (OSR bit for Rung 97) |
| B3:5/8 | | | (OSR bit for Rung 92) |
| B3:5/9 | | | (OSR bit for Rung 105) |
| B3:5/10 | | | SCR 1 Status |
| B3:5/11 | | | SCR 2 Status |
| B3:5/12 | VACUUM_LATCH | Global | Vacuum Latch |

### B9:0 — Unused Array

| Address | Notes |
|---------|-------|
| B9:0/0 – B9:0/11 | Defined but no instances found in the program |

---

## Input Addresses (I:)

### I:1 — 1747-DCM-FULL

| Address | Symbol | Description |
|---------|--------|-------------|
| I:1.0 | | DCM input bank 0 |
| I:1/32 | | |
| I:1/48 | | Remote On/Off |
| I:1/64 | | Control Enable |
| I:1/80 | | Control Reset |
| I:1/96–I:1/119 | | DCM status/data bits |

### I:2 — 1746-IO8

| Address | Symbol | Description |
|---------|--------|-------------|
| I:2/111 | CONTROL POWER ON | Control Power On |

### I:3 — Thermocouple Module

| Address | Description |
|---------|-------------|
| I:3/0 – I:3/15 | Thermocouple channels (copied to N7:100+) |

### I:4 — Touch Panel Input

| Address | Symbol | Description |
|---------|--------|-------------|
| I:4/1 | RESET BIT | Touch panel reset |

### I:6 — 1746-IB16

| Address | Symbol | Description |
|---------|--------|-------------|
| I:6/7 | KLYSTRON_CROWBAR (Global) | Klystron Crowbar signal |
| I:6/8 | GRN TANK OIL LEVEL | Ground Tank Oil Level |
| I:6/9 | Grounding Switch closed | Grounding Switch closed |
| I:6/10 | CROWBAR OIL LEVEL | Crowbar Oil Level |
| I:6/11 | SCR OIL LEVEL | SCR Oil Level |

### I:7 — 1746-IV16

| Address | Symbol | Description |
|---------|--------|-------------|
| I:7/0 | CONTACTOR LOCKOUT | Contactor Lockout |
| I:7/1 | CONTACTOR OVER CURRENT | Contactor Over Current |
| I:7/3 | CONTACTOR READY | Contactor Ready |
| I:7/10 | WATER_FLOW_SWITCH (Global) | Water Flow Switch |
| I:7/11 | PHASE LOSS | Phase Loss |

---

## Output Addresses (O:)

### O:1 — 1747-DCM-FULL

| Address | Symbol | Scope | Description |
|---------|--------|-------|-------------|
| O:1/123 | DCM_BIT | Global | Signal from F.O. Crowbar Enable from LLRF |
| O:1/124 | H1_SCR_LATCH | Global | H1 SCR Latch status |
| O:1/125 | H2_SCR_LATCH | Global | H2 SCR Latch status |
| O:1/126 | VACUUM_ALARM | Global | Vacuum Alarm |

### O:2 — 1746-IO8

| Address | Symbol | Description |
|---------|--------|-------------|
| O:2.0 | VOLTAGE REFERANCE | Voltage Reference (analog word) |
| O:2.1 | PHASE ANGL BIAS | Phase Angle Bias (analog word) |
| O:2/3 | GRD SWITCH RELAY | Ground Switch Relay |
| O:2/34 | 120 VOLTS | 120V power enable |
| O:2/35 | 240 VOLTS | 240V power enable |
| O:2/128 | ENABLE CONTROL POWER | Enable Control Power |

### O:5 — 1746-OX8

| Address | Symbol | Description |
|---------|--------|-------------|
| O:5/0 | CONTROL SYSTEM ENABLE | Control System / SCR Enable |
| O:5/3 | CROWBAR FORCED ON | Crowbar Forced On |
| O:5/4 | CROWBAR ENABLE | Crowbar Enable |
| O:5/5 | slow start | Enerpro Slow Start |
| O:5/6 | FAST INHIBIT | Enerpro Fast Inhibit |

---

## Integer Registers (N7)

| Address | Symbol | Description |
|---------|--------|-------------|
| N7:4 | AC CURRENT MONITOR | AC Current Monitor (display) |
| N7:15 | VOLTAGE MONITOR #1 | Voltage Monitor #1 |
| N7:16 | VOLTAGE MONITOR #2 | Voltage Monitor #2 |
| N7:17 | DC CURRENT MONITOR | DC Current Monitor |
| N7:18 | VOLTAGE X CURRENT | Power (V × I) calculation |

---

## System Registers (S:)

| Address | Symbol | Description |
|---------|--------|-------------|
| S:0 | Arithmetic Flags | Carry, Overflow, Zero, Sign |
| S:1 | Processor Mode | Mode bits, forces, faults, first pass |
| S:3 | Scan Time | Current/Watchdog scan time |
| S:4 | Time Base | Timing bits (10 ms base, 50% duty cycle) |
| S:5/0 | Overflow Trap | Math overflow trap bit |
| S:13 | Math Register (LSW) | 32-bit math register — low word |
| S:14 | Math Register (MSW) | 32-bit math register — high word |

---

## Timer Registers (T4)

| Address | Symbol | Description |
|---------|--------|-------------|
| T4:0 | MOMENTARY RESET | Momentary reset timer |
| T4:5 | | Enable delay (3s TON) |
| T4:8 | SYSTEM READY TIME DELAY | System ready delay (5s TON) |
| T4:9 | CONTACTOR ON BUTTON | Contactor on button momentary (1s TON) |
| T4:10 | | Remote momentary SCR on (0.5s TON) |
| T4:12 | | Crowbar off delay (8s TON) |
| T4:13 | | Turn off delay (0.1s TON) |
| T4:14 | | Current trip TOF (3s) |
| T4:15 | MOMENTARY ON REMOTE | Panel remote on momentary (1s TON) |
| T4:16 | Contactor Closed delay | Contactor closed delay (3s TON) |
| T4:17 | OPEN LOAD DELAY | Open load detection delay (1s TON) |
| T4:18 | | SCR off delay |

### Subroutine References

| Address | Symbol | Description |
|---------|--------|-------------|
| U:3 | COPY I/O TO B3 SBR | Subroutine — copies I/O to B3 array |
| U:4 | SCALE VALUES SBR | Subroutine — scales analog values |

