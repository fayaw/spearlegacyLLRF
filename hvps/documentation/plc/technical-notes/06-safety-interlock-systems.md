# 06 — Safety & Interlock Systems

## Overview

The HVPS PLC implements multiple layers of safety protection:

1. **Crowbar Protection** — Fires a crowbar circuit to protect the klystron and transformer
2. **Transformer Interlocks** — Monitors pressure, vacuum, temperature, oil levels
3. **AC/DC Power Interlocks** — Phase loss, water flow, oil pump
4. **Overcurrent/Overvoltage Protection** — Current and voltage trip latches
5. **Emergency Off** — Personnel safety shutdown
6. **Open Load Detection** — Detects disconnected or failed load

All safety latches follow a common pattern:
- **Set** by fault condition
- **Held** by latch bit (OTL instruction)
- **Cleared** only by B3:0/10 (Master Reset)
- **Reported** to EPICS via O:1 DCM bits

---

## 1. Crowbar Protection System

### Purpose

The crowbar circuit rapidly short-circuits the HVPS output to protect the klystron from overvoltage or arc conditions. The PLC manages crowbar enable/disable, forced crowbar, and crowbar monitoring.

### Key Signals

| Signal | Address | Type | Description |
|--------|---------|------|-------------|
| Crowbar Enable Fiber Drive | I:6/1 | Input | Fiber optic enable from LLRF |
| Crowbar Monitor | I:6/2 | Input | Crowbar circuit status |
| Klystron Arc Monitor | I:6/3 | Input | Arc detection from klystron |
| RF Crowbar | I:6/7 | Input | Crowbar signal from RF system |
| Crowbar Enable | O:5/4 | Output | Enable crowbar circuit |
| Force Crowbar | O:5/3 | Output | Force crowbar on |
| Crowbar Latch | B3:4/10 | Bit | Crowbar fault latch |
| Crowbar Lockout | B3:0/12 | Bit | Crowbar lockout state |

### Crowbar Rungs

**Rung 0013 — Crowbar Latching:**
- Crowbar latch (B3:4/10) sets when crowbar fires
- Cleared by B3:0/10 (Reset)
- Conditions: Crowbar enable fibers active AND fast inhibit active AND turn-off delay done

**Rung 0027 — Forced Crowbar:**
- Forces O:5/3 (Crowbar Forced On) during contactor close delay (T4:16/TT) if either SCR driver latch (B3:3/14 or B3:3/15) is set
- Protects during power transition

**Rung 0032 — Crowbar Enable on Contactor Close:**
- Latches O:5/4 (Crowbar Enable) when contactor closes (I:7/2)

**Rung 0033 — Crowbar Off Delay:**
- When crowbar trigger (I:6/1) fires, starts T4:12 (8-second delay)
- After delay, unlatches O:5/4 (Crowbar Enable)

**Rung 0037 — Crowbar On Display:**
- Sets B3:1/7 (Crowbar On display) and B3:3/1 (Crowbar alarm)
- Reports O:1/105 to DCM

### Klystron Crowbar

**Rung 0056:**
- Monitors I:6/7 (RF Crowbar signal)
- Sets B3:2/4 (_KLYSTRON_CROWBAR)
- Reports O:1/123 (DCM_BIT) to EPICS

---

## 2. Transformer Interlocks

All transformer interlocks use latching logic with normally-closed contacts that reset on power-up.

### Interlock Matrix

| Fault | Input | Latch Bit | DCM Bit | Threshold | Rung |
|-------|-------|-----------|---------|-----------|------|
| Pressure | I:7/4 | B3:4/0 | O:1/119 | NC contact | 41 |
| Vacuum | I:7/5 | B3:5/12 | O:1/126 | NC contact | 42 |
| Over Temperature | I:7/6 + TC | B3:4/1 | O:1/111, O:1/112 | N7:108=800, N7:109=800 | 43 |
| Low Oil | I:7/7 | B3:4/3 | O:1/110 | NC contact | 45 |
| Sudden Pressure | I:7/8 | B3:4/4 | O:1/118 | NC contact | 46 |
| SCR/Crowbar Oil | I:6/10, I:6/11 | B3:4/2 | — | NC contact | 44 |

### Temperature Interlock Detail (Rung 43)

In addition to the digital input I:7/6, the temperature interlock checks thermocouple readings:

```
Fault if:  I:7/6 is LOW (over temp)
     OR    N7:100 (TC Ch 0) < N7:108 (threshold 800)
     OR    N7:101 (TC Ch 1) < N7:109 (threshold 800)
```

> Note: The LES (Less Than) check against the threshold of 800 suggests the thermocouple module outputs decrease with increasing temperature, or the threshold represents a minimum acceptable reading.

### Composite Transformer OK (Rung 60)

B3:2/1 (Transformer Latched OK) is TRUE only when ALL of these are clear:
- B3:4/0 (Pressure Latch)
- B3:4/1 (Oil Temp Latch)
- B3:4/2 (SCR Oil Tank Level)
- B3:4/3 (Low Oil Latch)
- B3:2/7 (Water Flow Switch)

### All Transformer Inputs OK (Rung 61)

B3:0/9 (No Transformer Fault) is TRUE when ALL of these are OK:
- I:7/4 (Pressure), I:7/5 (Vacuum), I:7/6 (Over Temp)
- I:7/7 (Low Oil), I:7/8 (Sudden Pressure)
- I:6/10 (Crowbar Oil), I:6/11 (SCR Oil), I:6/8 (Ground Tank Oil)

---

## 3. AC/DC Power Interlocks

| Fault | Input | Latch Bit | Condition | Rung |
|-------|-------|-----------|-----------|------|
| Oil Pump Flow | I:7/9 | B3:4/7 | Only checked when SCR On (B3:0/4) | 47 |
| Klystron Crowbar | I:6/3 | B3:2/6 | With I:6/0, I:6/1; also disables O:5/0 | 48 |
| Klystron SCR Bit | I:6/0 | B3:2/5 | — | 49 |
| Water Flow | I:7/10 | B3:2/7 | — | 50 |
| Phase Loss | I:7/11 | B3:2/3 | Only checked when SCR On | 51 |
| Ground Tank Oil | I:6/8 | B3:4/14 | — | 52 |
| DC Power | B3:1/8 | B3:4/6 | Aux power off while system not off | 59 |

---

## 4. Overcurrent / Overvoltage Protection

### Latching Faults

| Fault | Input(s) | Latch Bit | DCM Bit | Timer | Rung |
|-------|----------|-----------|---------|-------|------|
| AC Overcurrent | I:7/1, I:7/15 | B3:4/11 | O:1/99 | T4:2/TT | 53 |
| Overvoltage | I:7/14 | B3:4/12 | O:1/113 | T4:2/TT | 54 |
| Contactor Current Fault | I:7/0, I:7/1 | B3:4/5 | — | — | 58 |

### Non-Latching Alarm Bits

| Fault | Input | Alarm Bit | Rung |
|-------|-------|-----------|------|
| Regulator Over Current | I:7/15 | B3:3/5 | 22 |
| Regulator Over Voltage | I:7/14 | B3:3/6 | 23 |
| Contactor Over Current | I:7/1 | B3:3/12 | 24 |
| Regulator Trip | I:7/12 | B3:3/9 | 29 |

### SCR Driver Monitoring

| Fault | Input | Latch Bit | DCM Bit | Rung |
|-------|-------|-----------|---------|------|
| H1 SCR Driver (Lower) | I:6/4 | B3:3/14 | O:1/124 | 25 |
| H2 SCR Driver (Upper) | I:6/6 | B3:3/15 | O:1/125 | 26 |

Conditions for SCR driver fault detection:
1. SCR Disable Fiber (I:6/0) must be clear
2. Regulator On (B3:0/2) must be true
3. SCR Drive Bit (B3:2/13) must be set
4. SCR Off Delay (T4:18/DN) must be done

---

## 5. Emergency Off System

### Rung 0014 — Emergency Off Logic

**Inputs monitored:**
- I:6/13 — Emergency Off switch (NC — opens on E-stop)
- I:6/14 — PPS-1 OK (Personnel Protection System)
- I:6/9 — Grounding Switch closed

**Actions when triggered:**
1. B3:1/0 — Emergency Off Latch (holds until reset with contactor closed)
2. B3:3/11 — Emergency Off Alarm
3. O:1/107 — Emergency Off status to DCM/EPICS
4. B3:0/14 — Master Alarm Bit (latched)

**Reset conditions:**
- B3:0/10 (Reset) must be active
- B3:1/11 (Contactor Closed) must be true

### PPS Status (Rung 15)

Both PPS channels (I:6/14, I:6/15) must be active for B3:1/1 (PPS On) and O:1/120 (PPS Status to DCM).

---

## 6. Open Load Detection

### Rung 0008 — Condition Detection

Detects a condition where high voltage is present but no current flows (disconnected load):

```
IF (N7:17 < N7:77)     AND     // DC Current < threshold (~10)
   (N7:14 < N7:79)     AND     // AC Current < threshold (~30)
   (N7:15 > N7:76)     AND     // Voltage Monitor 1 > threshold (~5000)
   (N7:16 > N7:78)              // Voltage Monitor 2 > threshold (~5000)
THEN start T4:17 (Open Load Delay, 1 second)
```

### Rung 0007 — Latch and Report

When T4:17/DN goes true (1 second of open load condition):
- B3:3/2 — Open Load Latch (reset by B3:0/11)
- B3:0/14 — Alarm Bit
- O:1/121 — Remote Open Load to DCM

---

## 7. Fast Inhibit System

The fast inhibit (B3:0/13) is a critical safety mechanism that rapidly shuts down the SCR firing:

### Rung 0010 — Set Fast Inhibit
- When B3:0/4 (SCR On Latch) goes true
- Immediately latches B3:0/13 (Fast Inhibit)
- After T4:5 (3 seconds), enables B3:0/2 (Regulator On)
- Purpose: Holds SCR inhibited for 3 seconds during turn-on to allow system stabilization

### Rung 0011 — Clear Fast Inhibit
- When B3:0/2 (Regulator On) goes FALSE
- T4:14/DN clears B3:0/13
- Also zeros N7:10 and N7:11

### Rung 0012 — Output
- T4:14/DN AND B3:0/13 → O:5/6 (Fast Inhibit to Enerpro) and O:1/108 (to DCM)

### Rung 0036 — T4:14 TOF Timer
- **Conditions:** B3:0/13 (Fast Inhibit) AND any overcurrent:
  - I:7/15 (Current Trip)
  - I:7/1 (Contactor Over Current)
  - I:7/0 (Blocking Over I)
- T4:14 is a TOF (Timer Off Delay), preset 3 seconds
- When all conditions go false for 3 seconds, T4:14/DN goes true

---

## 8. Alarm Summary

### Rung 0019 — Master Alarm
- B3:0/14 (Alarm Bit) → B3:3/0 (Alarm summary)

All fault conditions that latch B3:0/14 (Alarm Bit):
- Emergency Off (Rung 14)
- Contactor Alarm (Rung 20)
- Transformer Alarm (Rung 21)
- Regulator Over Current (Rung 22)
- Regulator Over Voltage (Rung 23)
- Contactor Over Current (Rung 24)
- SCR Driver Faults (Rungs 25–26)
- Aux Power Alarm (Rung 28)
- Regulator Trip (Rung 29)
- Crowbar On during close delay (Rung 37)
- Open Load (Rung 7)

### Reset

All alarms require B3:0/10 (Reset) to clear. Reset is generated by Rung 1 via T4:0 (momentary reset timer). The alarm bit B3:0/14 is unlatched in Rung 1.

---

## Touch Panel Interlock Display

The following interlocks are displayed on the operator touch panel (all illuminated = OK during normal operation):

| PLC Tag | Interlock | Expected State |
|---------|-----------|----------------|
| 1-B3:4/11 | AC Overcurrent Fault | Illuminated (OK) |
| 1-B3:3/6 | DC Overvoltage OK | Illuminated |
| 1-B3:3/5 | DC Overcurrent OK | Illuminated |
| 1-B3:13/8 | Ground Tank Oil Fault | Illuminated |
| 1-B3:1/0 | Ground Tank E-Stop OK | Illuminated |
| 1-B3:1/7 | Crowbar OK | Illuminated |
| 1-B3:4/13 | Klystron Arc Fault | Illuminated |
| 1-B3:4/15 | Transformer Arc Fault | Illuminated |
| 1-B3:2/4 | Klystron Crowbar Fault | Illuminated |
| 1-B3:3/2 | Open Load OK | Illuminated |
| 1-B3:3/14 | H1 SCR Drivers OK | Illuminated |
| 1-B3:3/15 | H2 SCR Drivers OK | Illuminated |
| 1-B3:13/11 | SCR Oil Level Low | Illuminated |
| 1-B3:13/10 | Crowbar Oil Level Low | Illuminated |
| 1-B3:14/7 | Main Tank Oil Level Low | Illuminated |
| 1-B3:14/6 | Oil Temperature Fault | Illuminated |
| 1-B3:2/7 | Oil Flow Switch Fault | Illuminated |
| 1-B3:14/4 | Pressure Fault | Illuminated |
| 1-B3:14/8 | Relief Valve Fault (Sudden Pressure) | Illuminated |
| 1-B3:14/5 | Vacuum Fault | Illuminated |
| 1-B3:0/3 | Summary Not Ready | Illuminated |
| 1-B3:5/12 | Vacuum Fault Latched | Illuminated |
| 1-B3:4/10 | Pressure Fault Latched | Illuminated |
| 1-B3:4/1 | Oil Temperature Fault Latched | Illuminated |
| 1-B3:4/2 | SCR/Crowbar Oil Level Low Latched | Illuminated |
| 1-B3:4/3 | Main Tank Oil Level Low Latched | Illuminated |
| 1-B3:4/4 | Sudden Pressure Fault Latched | Illuminated |

