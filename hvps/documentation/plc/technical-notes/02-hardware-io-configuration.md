# 02 — Hardware & I/O Configuration

> **Verification status: VERIFIED (28 September 2026)** — every discrete I/O table below was
> checked point-by-point against three primary sources:
>
> | Tag | Source | What it gives |
> |---|---|---|
> | **[D]** | `wd7307900206.pdf` — WD-730-790-02-C6, master wiring diagram | the label printed beside each module terminal, plus wire colour |
> | **[L]** | `CasselPLCCode.pdf` — ladder printout (`SSRLV6-4-05-10`, LAD 2/3/4) | the description the program itself attaches to each bit |
> | **[S]** | `CasselSymbolDatabase.pdf` — address/symbol database | formal symbol names, where one was ever entered |
>
> **Corrections applied in this pass** (the previous revision was never reviewed):
>
> 1. `I:2/1` was "A Phase Reference Voltage". [L] calls it **12KV VOLTS / 12KV OFF** — it is the
>    12 kV present sense, used in rungs 38 and 39.
> 2. `I:2/2` and `I:2/3` were "Filter Inductor 1 / 2". **Neither bit is referenced anywhere in the
>    ladder** and neither carries a symbol in [S]; the names were unsupported and have been removed.
> 3. `I:6/1` was "Crowbar Enable Fiber Drive". [D] labels the terminal **CROWBAR TRIGGER MON** and
>    [L] calls the bit **CROWBAR TRIGGER** — it is a monitor input, not an enable output.
> 4. `I:7/13` was "Ground Tank Relay". [D] labels it **GRN RELAY OPEN** and [L] **GROUND SW OPEN** —
>    the sense (open) is the whole point of the signal and was lost.
> 5. `I:7/10` was "Water Flow Switch (Spare)". [D] labels the terminal **SPARE**; only [S] carries
>    `WATER_FLOW_SWITCH`. The point is provisioned in software but shows as spare in the field wiring.
> 6. `I:6/12` was "Key/Emergency Off Switch", conflating it with `I:6/13`. It is the **PERMIT key
>    switch** on the local control panel; Emergency Off is a separate bit.
> 7. Slot numbers were not stated for slots 0, 3 and 4. The chassis is a **10-slot rack, slots 0--9,
>    with slot 4 empty** — see the chassis table below.
>
> **Not verified**: the `O:1` DCM status-bit table. Three entries were spot-checked against [L]
> (`O:1/97` 12KV ON, `O:1/98` AC AUX PWR ON, `O:1/99` AC CURRENT TRIP) and all three matched, but the
> remaining rows have not been walked.

## Chassis

| Slot | Module | Role |
|---|---|---|
| PS | AB-1747-P1 | Chassis power supply |
| 0 | 1747-L532 | SLC-5/03 processor |
| 1 | 1747-DCM | Remote I/O **adapter** (presents this chassis to the 6008-SV scanner in the B132 VXI crate) |
| 2 | 1746-IO8 | 4 in / 4 out combo |
| 3 | 1746-THERMC | Thermocouple input |
| 4 | *(empty)* | — |
| 5 | 1746-OX8 | 8-point relay output |
| 6 | 1746-IB16 | 16-point 24 V DC input |
| 7 | 1746-IV16 | 16-point 24 V DC input |
| 8 | 1746-NIO4V | 4-channel analog in/out |
| 9 | 1746-NI4 | 4-channel analog in |

## Binary Inputs

### Slot 2 — 1746-IO8 (Combo I/O)

| PLC Address | B3 Copy Dest | Function | Source |
|------------|--------------|----------|--------|
| I:2/0 | B3:12/0 | 120 V AC control power present | [L] "120V AC CTRL PWR" (rungs 62, 63, 65, 66) |
| I:2/1 | B3:12/1 | 12 kV present / 12 kV off sense | [L] "12KV VOLTS" (rung 38), "12KV OFF" (rung 39) |
| I:2/2 | B3:12/2 | *not used* | no ladder reference, no symbol |
| I:2/3 | B3:12/3 | *not used* | no ladder reference, no symbol |

> **Note:** I:2 is copied to B3:12 by the COPY subroutine (LAD 3, Rung 0000), `COP #I:2.0 → #B3:12`, length 1 — read directly from [L].

### Slot 6 — 1746-IB16 (16-point 24V DC Digital Input)

| PLC Address | B3 Copy Dest | Terminal label [D] | Wire | Ladder description [L] |
|------------|--------------|--------------------|------|------------------------|
| I:6/0 | B3:13/0 | SCR DISABLE | YEL | SCR DISABLE FIBER DRIVER |
| I:6/1 | B3:13/1 | CROWBAR TRIGGER MON | BLU | CROWBAR TRIGGER |
| I:6/2 | B3:13/2 | CROWBAR MONITOR | GRAY | CROWBAR ON / CROWBAR ENABLE |
| I:6/3 | B3:13/3 | KLYSTRON ARC MONITOR | BLK | ARC TRIP KLYSTRON |
| I:6/4 | B3:13/4 | SCR MONITOR # 1 | RED | SCR TRIG#1 / SCR DRIVE BIT LOWER |
| I:6/5 | B3:13/5 | XFORMER ARC MONITOR | BLK | XFORMER ARC |
| I:6/6 | B3:13/6 | SCR MONITOR # 2 | RED | SCR TRIG#2 / SCR DRIVER UPPER |
| I:6/7 | B3:13/7 | KLYSTRON CB MON | BRN | `KLYSTRON_CROWBAR` [S] — "CB" is **crowbar**, not circuit breaker |
| I:6/8 | B3:13/8 | GRN TANK OIL OK | RED | GRN TANK OIL LEVEL |
| I:6/9 | B3:13/9 | GRN SWITCH CLOSED | GRAY | Grounding Switch closed [S]; MANUAL GRN SWITCH OK |
| I:6/10 | B3:13/10 | CROWBAR OIL LVL OK | VIOL | CROWBAR OIL LEVEL |
| I:6/11 | B3:13/11 | SCR OIL LEVEL OK | YEL | SCR OIL LEVEL |
| I:6/12 | B3:13/12 | KEY ENABLE | ORG | TOUCH PANEL (KEY) ENABLE — the PERMIT key switch on the local control panel |
| I:6/13 | B3:13/13 | EMERGENCY OFF | BLK | EMERGENCY OFF |
| I:6/14 | B3:13/14 | PPS # 1 | GRN | PPS-1 OK / PPS-1 ON |
| I:6/15 | B3:13/15 | PPS # 2 | BLU | PPS-2 OK / PPS-2 ON |

> Terminals 16 and 17 are DC COM [D].
>
> **Note:** I:6 is copied to B3:13 by the COPY subroutine (LAD 3, Rung 0001).
>
> Where [D] and [L] disagree on wording (I:6/2, I:6/4, I:6/6) both are given. The drawing names the
> signal at the terminal block; the ladder names the condition the program tests.

### Slot 7 — 1746-IV16 (16-point 24V DC Digital Input)

| PLC Address | B3 Copy Dest | Terminal label [D] | Wire | Ladder description [L] |
|------------|--------------|--------------------|------|------------------------|
| I:7/0 | B3:14/0 | BLOCKING RELAY | BRN | CONTACTOR LOCKOUT [S] |
| I:7/1 | B3:14/1 | OVERCURRENT RELAY | RED | CONTACTOR OVER CURRENT [S] |
| I:7/2 | B3:14/2 | CONTACTOR CLOSED | ORG | CONTACTOR CLOSED / CONTACTOR OPEN |
| I:7/3 | B3:14/3 | CONTACTOR READY | BLU | CONTACTOR READY [S] |
| I:7/4 | B3:14/4 | XFORMER PRESSURE NC | BRN | NO XFORMER PRESSURE ALARM |
| I:7/5 | B3:14/5 | XFORMER VACUUM NC | ORG | XFORMER VACUUM |
| I:7/6 | B3:14/6 | XFORMER OVER TEMP NC | YEL | XFORMER OVER TEMP |
| I:7/7 | B3:14/7 | OIL LEVEL LOW NC | BLU | LOW OIL LEVEL |
| I:7/8 | B3:14/8 | SUDDEN PRESSURE | RED | XFRMER SUDDEN PRESSURE |
| I:7/9 | B3:14/9 | OIL PUMP FLOW NC | VIOL | OIL PUMP FLOW |
| I:7/10 | B3:14/10 | **SPARE** | BLK | `WATER_FLOW_SWITCH` [S] — named in software, wired as spare |
| I:7/11 | B3:14/11 | PHASE LOSS | YEL | PHASE LOSS [S] (Enerpro) |
| I:7/12 | B3:14/12 | CURRENT LIMIT | WHT | CURRENT LIMIT (regulator) |
| I:7/13 | B3:14/13 | **GRN RELAY OPEN** | GRAY | GROUND SW OPEN |
| I:7/14 | B3:14/14 | VOLTAGE TRIP | ORG | OVER VOLTAGE TRIP (regulator) |
| I:7/15 | B3:14/15 | CURRENT TRIP | BRN | REGULATOR CURRENT TRIP |

> Terminal 16 is the 24 V DC feed (RED) and 17 is VDC+ [D].
>
> **Note:** I:7 is copied to B3:14 by the COPY subroutine (LAD 3, Rung 0002).
>
> These four contactor points (IN0--IN3) are on the **slot-7 IV16**, not on the slot-6 IB16.

### Slot 1 — 1747-DCM (Inputs from VXI/EPICS)

The ladder annotates these addresses `1747-DCM-FULL`. The module is a Remote I/O **adapter**, not a scanner — the scanner is the 6008-SV in the B132 VXI crate.

| PLC Address | Function | Rungs Used | Source |
|------------|----------|------------|--------|
| I:1/48 | Remote On/Off | 2, 6 | [L] "REMOTE ON/OFF" |
| I:1/64 | Control Enable | 4, 9 | [L] "CONTROL ENABLE" |
| I:1/80 | Control Reset | 115 | [L] "CONTROL RESET" |
| I:1 Register 1 | External Reference (16-bit setpoint from IOC) | 104 | [L] `I:1.1` |
| I:1 Register 2 | Maximum External Reference from VXI DCM | 92 | [L] `I:1.2` |

---

## Binary Outputs

### Slot 2 — 1746-IO8 (Combo I/O Outputs)

| PLC Address | B3 Copy Dest | Terminal label [D] | Ladder description [L] |
|------------|--------------|--------------------|------------------------|
| O:2/0 | B3:15/0 | AC BIAS P.S. | BIAS PWR |
| O:2/1 | B3:15/1 | AC 120 VDC P.S. | 120V PWR / 120VDC AC |
| O:2/2 | B3:15/2 | AC 240 VAC P.S. | 240V PWR / 240VDC AC |
| O:2/3 | B3:15/3 | AC GND TANK RELAY COIL | GRD SWITCH RELAY [S] |

> **Note:** O:2 is copied to B3:15 by the COPY subroutine (LAD 3, Rung 0003).
>
> **Trap:** [S] also carries entries `O:2.0 VOLTAGE REFERANCE`, `O:2.1 PHASE ANGL BIAS` and
> `O:2/32`–`O:2/35`, `O:2/128`–`O:2/135`. A 1746-IO8 is a **single-word** module (the COP in LAD 3
> copies length 1), so those addresses cannot belong to it — they are stale symbol-database entries
> from an earlier configuration. The analog reference and phase-angle outputs are on **slot 8**
> (`O:8.0`, `O:8.1`), which is what the ladder actually writes. Prefer [L] over [S] here.

### Slot 5 — 1746-OX8 (8-point Relay Output)

| PLC Address | B3 Copy Dest | Terminal label [D] | Ladder description [L] |
|------------|--------------|--------------------|------------------------|
| O:5/0 | B3:16/0 | 12V FAULT / ENABLE | SCR ENABLE; `CONTROL SYSTEM ENABLE` [S] |
| O:5/1 | B3:16/1 | CONT. ON/OFF | CLOSE CONTACTOR |
| O:5/2 | B3:16/2 | CONT. ENABLE | "CROWBAR ON" — **the rung label is wrong**; the terminal drives Contactor Enable / the K4 coil (see `pps/HoffmanBoxPPSWiring.docx`) |
| O:5/3 | B3:16/3 | PLC FORCE CROWBAR | `CROWBAR FORCED ON` [S] |
| O:5/4 | B3:16/4 | CROWBAR OFF | `CROWBAR ENABLE` [S] |
| O:5/5 | B3:16/5 | ENERPRO SLOW START | SLOW START |
| O:5/6 | B3:16/6 | ENERPRO FAST INHIBIT | `FAST INHIBIT` [S] |
| O:5/7 | B3:16/7 | REGULATOR RESET | REG RESET |

> **Note:** O:5 is copied to B3:16 by the COPY subroutine (LAD 3, Rung 0004).

---

## Analog Inputs

### Slot 8 — AB-1746-NIO4V (4-channel Analog I/O)

| Channel | Terminal label [D] | Function | PLC Destination | Rung |
|---------|--------------------|----------|-----------------|------|
| IN 0 | "V" INPUT +VOLTAGE SENSE FROM REG. CARD | Output voltage monitor from regulator card (J3-1) | N7:12 (via N7:19 offset addition) — [L] "OFFSET FEEDBACK" | 76, 77 |
| IN 1 | PHASE CONTROL DRIVER TO ENERPRO BD | Readback of phase control voltage to Enerpro (SIG HI) | N7:13 — [L] "PHASE MONITOR" | 88 |

### Slot 9 — AB-1746-NI4 (4-channel Analog Input)

| Channel | Terminal label [D] | Function | PLC Destination | Rung |
|---------|--------------------|----------|-----------------|------|
| IN 0 | "I" INPUT +CURRENT SENSE FROM REG. CARD | Input AC current monitor from regulator card (J3-2) | N7:14 (via N7:9 offset addition) — [L] "AC CURRENT MONITOR" | 78 |
| IN 1 | *(truncated on the scan)* | Output voltage monitor 1 from HVPS (parallel path to J1-1 of regulator card) | N7:15 — [L] "VOLTAGE MONITOR #1" | 80 |
| IN 2 | *(truncated on the scan)* | Output voltage monitor 2 from HVPS (redundant monitor) | N7:16 — [L] "VOLTAGE MONITOR #2" | 81 |
| IN 3 | DC CURRENT MONITOR | Output DC current monitor (Danfysik) from grounding tank | N7:17 — [L] "DC CURRENT MONITOR" | 82, 83 |

---

## Analog Outputs

### Slot 8 — AB-1746-NIO4V (4-channel Analog I/O)

| Channel | Terminal label [D] | Function | PLC Source | Rung |
|---------|--------------------|----------|------------|------|
| OUT 0 | REFERENCE FROM MCC | Reference voltage setpoint to regulator card input (EL1) | N7:10 → O:8.0 | 112 |
| OUT 1 | 2ND PHASE CONTROL DRIVER TO ENERPRO BD | Phase control contribution to Enerpro SIG HI input (via 1 kΩ resistor, summed with regulator output over 7.5 kΩ) | N7:11 → O:8.1 | 113 |

> The drawing labels the two analog output terminals **OUT 0** and **OUT 2**, while the ladder writes
> channel words **O:8.0** and **O:8.1**. Treat the drawing text as a terminal designation and the
> ladder as the channel number.

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

> **Not verified.** Only three rows were checked against [L] — `O:1/97` 12KV ON, `O:1/98` AC AUX PWR ON
> and `O:1/99` AC CURRENT TRIP — and all three matched. The rest of the table has not been walked
> rung by rung.

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

