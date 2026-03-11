# 01 — System Overview

## Purpose

The PLC controls a **SPEAR RF Klystron High Voltage Power Supply (HVPS)** used to power klystron amplifiers for the SPEAR3 storage ring at SSRL. The PLC handles:

- Power-up and power-down sequencing
- Voltage reference generation and ramping
- Phase angle control for the Enerpro SCR drive
- Crowbar protection system management
- Comprehensive safety interlock monitoring
- Communication with the EPICS control system via VXI crate

---

## Hardware Architecture

### PLC Chassis — Allen-Bradley SLC 500

| Slot | Module | Function |
|------|--------|----------|
| 0 | SLC 500 CPU | Main processor |
| 1 | 1747-DCM (DCM-FULL) | Direct Communication Module — VXI/EPICS interface |
| 2 | 1746-IO8 | 8-point digital I/O combo (12 kV, 240V power, GRD switch relay) |
| 3 | Thermocouple Module | 8-channel temperature sensing (N7:100–N7:107) |
| 5 | 1746-OX8 | 8-point relay output (SCR enable, contactor, crowbar, fast inhibit) |
| 6 | 1746-IB16 | 16-point 24V DC digital input (fiber optic signals, oil levels, PPS) |
| 7 | 1746-IV16 | 16-point 24V DC digital input (contactor status, transformer interlocks) |
| 8 | AB-1746-NIO4V | 4-channel analog I/O (voltage reference output, phase angle readback) |
| 9 | AB-1746-NI4 | 4-channel analog input (AC current, voltage monitors, DC current) |
| 10 | Input module | Additional inputs (12 channels) |
| 11 | Input module | Additional inputs |
| 13 | Output module | Additional outputs (4 channels) |

### System Block Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   EPICS IOC     │◄──►│   VXI Crate     │◄──►│ 1747-DCM (Slot1)│◄──►│  SLC 500 PLC    │
│                 │    │                 │    │                 │    │                 │
│ • Setpoints     │    │ • Data routing  │    │ • 8×16-bit I:1  │    │ • Ladder Logic  │
│ • Commands      │    │ • Protocol      │    │ • 8×16-bit O:1  │    │ • Safety Logic  │
│ • Status        │    │   conversion    │    │ • Status bits   │    │ • Control Algs  │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           HVPS HARDWARE CONTROL                                    │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────────────┤
│   CONTACTORS    │   SCR DRIVES    │   CROWBAR       │      MONITORING             │
│                 │                 │                 │                             │
│ • Main Power    │ • Enerpro       │ • Protection    │ • Voltage/Current           │
│ • Sequencing    │ • Phase Control │ • Arc Detection │ • Temperature               │
│ • Interlocks    │ • Firing Angle  │ • Fast Trip     │ • Oil Levels               │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────────────┘
                                        │
                                        ▼
                        ┌─────────────────────────────┐
                        │     KLYSTRON AMPLIFIER     │
                        │                             │
                        │ • High Voltage Power        │
                        │ • RF Amplification          │
                        │ • SPEAR3 Storage Ring       │
                        └─────────────────────────────┘
```

### PLC Chassis Layout

```
SLC 500 Chassis (13 slots)
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│  0  │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │ 10  │ 11  │ 13  │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│ CPU │ DCM │ IO8 │ TC  │ --- │ OX8 │IB16 │IV16 │NIO4V│ NI4 │ IN  │ IN  │ OUT │
│     │FULL │     │     │     │     │     │     │     │     │     │     │     │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘

Legend:
• CPU    = SLC 500 Processor
• DCM    = 1747-DCM-FULL (VXI/EPICS Interface)
• IO8    = 1746-IO8 (8-pt Digital I/O Combo)
• TC     = Thermocouple Module (8 channels)
• OX8    = 1746-OX8 (8-pt Relay Output)
• IB16   = 1746-IB16 (16-pt 24V Input)
• IV16   = 1746-IV16 (16-pt 24V Input)
• NIO4V  = AB-1746-NIO4V (4-ch Analog I/O)
• NI4    = AB-1746-NI4 (4-ch Analog Input)
• IN/OUT = Additional I/O modules
```

### Control Signal Flow

```
VOLTAGE REFERENCE PATH (N7:10)
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ EPICS IOC   │───►│ I:1 Reg 1   │───►│   N7:30     │───►│   N7:10     │
│ Setpoint    │    │ (DCM Input) │    │ Ext. Ref.   │    │ Ref. Out    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                             │                   │
                                             ▼                   ▼
                                    ┌─────────────┐    ┌─────────────┐
                                    │ Low-Pass    │    │ O:8.0 DAC   │
                                    │ Filter      │    │ (EL1 Input) │
                                    │ τ ≈ 0.76s   │    │ Regulator   │
                                    └─────────────┘    └─────────────┘

PHASE ANGLE PATH (N7:11)
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   N7:10     │───►│ × 12000     │───►│ + 6000      │───►│   N7:11     │
│ Ref. Out    │    │ ÷ 32767     │    │ (offset)    │    │ Phase Out   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                 │
                                                                 ▼
                                                        ┌─────────────┐
                                                        │ O:8.1 DAC   │
                                                        │ (SIG HI)    │
                                                        │ Enerpro SCR │
                                                        └─────────────┘

SAFETY INTERLOCK CHAIN
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Emergency   │───►│ Transformer │───►│ Contactor   │───►│ SCR Enable  │
│ Off / PPS   │    │ Interlocks  │    │ Control     │    │ Chain       │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ I:6/13,14,15│    │ I:7/4,5,6,7 │    │ I:7/0,1,2,3 │    │ O:5/0,6     │
│ (Digital In)│    │ (Digital In)│    │ (Digital In)│    │ (Relay Out) │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

---

## Program Structure

The PLC program (**SSRLV6-4-05-10**) consists of three program files:

| File | Name | Type | Rungs | Bytes | Description |
|------|------|------|-------|-------|-------------|
| 2 | (Main) | LADDER | 120 | 5,557 | Main control logic |
| 3 | COPY | LADDER | 6 | 108 | I/O to B3 copy subroutine |
| 4 | SCALE | LADDER | 5 | 159 | Value scaling subroutine |

### Execution Timing

- **Estimated scan time:** ~5 ms per cycle (0.9 ms/kB × 5.5 kB)
- **Timing control:** S:4 register bits provide fixed-period timing (10 ms base)
- **OSR-gated rungs** limit execution frequency for specific operations (see [Control Algorithms](05-control-algorithms.md))

#### PLC Scan Cycle with OSR Timing

```
Time →  0ms    80ms   160ms   240ms   320ms   640ms   1280ms  2560ms
        │      │      │       │       │       │       │       │
S:4/2   ████   ████   ████    ████    ████    ████    ████    ████  (80ms period)
S:4/3   ████████      ████████        ████████        ████████      (160ms period)
S:4/5   ████████████████              ████████████████              (640ms period)
S:4/6   ████████████████████████████████                            (1280ms period)
S:4/7   ████████████████████████████████████████████████████████    (2560ms period)

Rung Execution:
104     ▲      ▲      ▲       ▲       ▲       ▲       ▲       ▲     N7:10 Filter (80ms)
92             ▲              ▲               ▲               ▲     DCM Transfer (160ms)
105                                           ▲                     Constants (640ms)
117                                                   ▲             Status (1280ms)
118                                                           ▲     Status (2560ms)

Legend: ████ = S:4 bit HIGH,  ▲ = OSR-triggered rung execution
```

---

## Functional Block Overview

### Power Sequencing (Rungs 0–18)

1. **Overflow reset** (Rung 0) — Clears S:5 overflow bit on reset
2. **Momentary reset** (Rung 1) — Resets alarms and Enerpro phase loss latch
3. **Contactor close/open** (Rung 2) — Main contactor control with safety interlocks
4. **System ready** (Rung 3) — Sets system ready status, enables crowbar and 240V power
5. **SCR on/off chain** (Rung 4) — SCR enable with 3-second contactor delay
6. **Momentary buttons** (Rungs 5–6) — Panel and remote contactor close
7. **Open load detection** (Rungs 7–8) — Voltage/current mismatch detection
8. **Remote SCR control** (Rung 9) — Remote momentary SCR enable
9. **Turn-off sequence** (Rung 10) — Fast inhibit latch and regulator enable with 3s delay
10. **Reference initialization** (Rung 11) — Zero N7:10 and N7:11 when regulator is off
11. **Fast inhibit** (Rung 12) — Enerpro fast inhibit output control
12. **Enable chain** (Rungs 16–18) — Touch panel key, PPS, grounding switch checks

#### Power-Up Sequence Diagram

```
Time →  0s     5s     8s     11s    14s    17s
        │      │      │      │      │      │
        ▼      ▼      ▼      ▼      ▼      ▼

┌─────────────────────────────────────────────────────────────┐
│ 1. ENABLE CHAIN                                             │
│    Key + PPS + E-Stop + Ground Switch ──────────────────────┤ ✓ Continuous
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 2. SYSTEM READY DELAY (T4:8)                               │
│    5-second delay ──────────────────────────────────────────┤ ████████
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 3. CONTACTOR CLOSE                                          │
│    Manual/Remote command ───────────────────────────────────┤      ✓
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 4. CONTACTOR CLOSED DELAY (T4:16)                          │
│    3-second delay ──────────────────────────────────────────┤        ████
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 5. SCR ENABLE                                               │
│    SCR firing enabled ──────────────────────────────────────┤           ✓
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 6. FAST INHIBIT DELAY (T4:5)                               │
│    3-second inhibit ────────────────────────────────────────┤           ████
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 7. REGULATOR ON                                             │
│    Voltage regulation active ───────────────────────────────┤              ✓
└─────────────────────────────────────────────────────────────┘

Legend: ████ = Timer active,  ✓ = State active
```

### Safety & Alarms (Rungs 13–15, 19–61)

- Crowbar latching and reset (Rung 13)
- Emergency off with alarm latch (Rung 14)
- PPS status monitoring (Rung 15)
- Alarm summary (Rung 19)
- Contactor alarm (Rung 20)
- Transformer alarm (Rung 21)
- Regulator overcurrent/overvoltage (Rungs 22–23)
- Contactor overcurrent (Rung 24)
- SCR driver monitoring (Rungs 25–26)
- Transformer interlocks (Rungs 41–46)
- AC/DC power interlocks (Rungs 47–61)

### Display Status (Rungs 30–40, 62–75)

- Contactor open/closed/ready status bits
- 12 kV on/off display
- Supply on/off, SCR on/off display
- Auxiliary power status

### Analog Processing (Rungs 76–102)

- Voltage monitor offset and scaling (Rungs 76–77)
- AC current offset and scaling (Rungs 78–79)
- Voltage monitor 1 & 2 readback (Rungs 80–81)
- DC current monitor (Rungs 82–83)
- Display value scaling (Rungs 84–102)

### Control Algorithms (Rungs 104–113)

- **Voltage reference ramping** (Rung 104) — Single-pole low-pass filter
- **Constant loading** (Rung 105) — Load max voltage, max phase, internal ref
- **Output reference calculation** (Rungs 106–107) — Scaled reference output
- **Phase angle calculation** (Rungs 108–111) — N7:11 phase angle computation
- **DAC output** (Rungs 112–113) — Write N7:10 and N7:11 to analog outputs

### Periodic Data Transfer (Rung 92)

- Copies AC current, voltage reference, voltage monitor, DC current, and max volts to DCM outputs
- Copies thermocouple inputs to N7:100–N7:107
- Executes every 160 ms (gated by S:4/3 and OSR B3:5/8)

### Additional Functions (Rungs 114–120)

- Power calculation
- PLC-to-DCM status bit mapping
- Subroutine calls (COPY, SCALE)
