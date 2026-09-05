# WD-730-790-02-C6 — HVPS Controller Wiring (Hoffman Box)

> **Drawing**: `wd7307900206.pdf`
> **Title**: PEP II RF SYSTEMS — **2.5 MW KLYSTRON PWR SPLY** — TRIGGER ENCLOSURE WIRING
> **Engineers**: R. Cassel (ENGR), W. Gorecki (DFTR), S. Lowe (CHKR)
> **CAD File**: WD730790020601.DGN, sheet 1 of 1
>
> **Verification status: VERIFIED (3 September 2026)** — read directly from the scanned drawing rendered to image.

### Revision block (as drawn)

| Rev | Description | Drafter | Checker | Engr appv | Date |
|---|---|---|---|---|---|
| C1 | REV'D FOR CORRECTNESS | WSG | D.C. | D.C. | 06/03 |
| C2 | REV'D FOR CORRECTNESS | WSG | J.O. | D.C. | 07/03 |
| C3 | REV'D PER ECO # A0764 | WSG | J.O. | D.C. | 09/03 |
| C4 | REV'D PER ECO # A0188 | WSG | J.O. | M.L. | 04/06 |
| C5 | REV'D FOR CORRECTNESS | WSG | J.O. | M.L. | 01/07 |
| C6 | REV'D FOR CORRECTNESS | A.M. | — | — | — |

> This is the **master wiring diagram for the whole B118 trigger enclosure**. It is the single most useful sheet in the HVPS documentation set, and it independently confirms several facts that were previously carried only in derived notes.

---

## What this drawing confirms

| Item | Confirmation on this sheet |
|---|---|
| **TS-3 is the Voltage Monitor strip** | TS-3 is drawn against a block titled "PEP2 RF SYSTEM KLY PS MONITOR BD **SD-730-793-12**" and is labelled **VOLTAGE MONITOR**. Its terminals read DC VOLTAGE *1, DC VOLTAGE *2, COM, VOLTS, AMPS, COM, −15 V, +15 V, **CURRENT 5A/V**. |
| **PPS status LEDs are on the AMP 8-pin connector** | Four LEDs are drawn next to the AMP-8PIN J2 / AMP-8PINH F2 connectors: **PPS1 LED1 GRN, PPS2 LED2 GRN, PPS3 LED3 RED, PPS4 LED4 RED** — two green, two red. The **PPS GOB1208PNE** connector is drawn alongside. |
| **Thermocouple channel assignment** | **TC-1 SCR TOP OIL, TC-2 SCR BOTTOM OIL, TC-3 CROWBAR, TC-4 AIR TEMP**, wired to SLOT-3. This matches ladder file LAD 4 "SCALE" in the PLC program exactly. |
| **Terminal strip roles** | TS-2 (control power), **TS-3 Voltage Monitor**, **TS-4 TRANSFORMER INTERLOCKS**, **TS-5 CONTACTOR CONTROLS**, **TS-6 GND TANK**, **TS-7 TRANSFORMER MONITORS**, **TS-8 PERMITS**. |
| **Regulator card identity** | Drawn as **PC-237-230-14-C0** with jumpers JP1–JP12 and signals CUR. LIMIT, MAN TRIP, VOLT TRIP, CURR TRIP, LOAD, STOP, RESET, EL1, SIG HI, VOLT REF, CUR REF. |
| **Enerpro board set** | **EN-1A "ENERPRO-FIRING BOARD"** (with the PP1 jumper block visible) and **EN-1B "ENERPRO-12PHASE"** — the FCOG6100 and its FCOAUX60 auxiliary board. |
| **Trigger interconnect boards** | **LEFT SIDE TRIG INTERCONNECT BD SD-730-793-08** and **RIGHT SIDE TRIG INTERCONNECT BD SD-730-793-07**, each feeding an interface board (IN1, IN2) and six gate-drive channels. |
| **Supply rating** | Title block reads "2.5 MW KLYSTRON PWR SPLY". |

---

## PLC chassis — as drawn

| Slot | Module | Notes |
|---|---|---|
| **SLOT-0** | **1747-L532** | **SLC-5/03 CPU**, RS232 and DH485 ports |
| SLOT-1 | AB-1747-DCM | Remote I/O adapter module; LNK1 / LNK2 / SHIELD |
| SLOT-2 | AB-1746-IO8 | OUT 0–3 drive AC BIAS P.S., AC 120 VDC P.S., AC 240 VAC P.S. and the **AC GND TANK RELAY COIL**; INPUT 0–3 take A PHASE TS7-1 and FILTER TS7-13 / TS7-14 |
| SLOT-3 | AB-1746-THERMC | TC-1…TC-4 (see above) |
| SLOT-5 | AB-1746-OX8 | Relay outputs |
| SLOT-6 | AB-1746-IB16 | 16 DC inputs |
| SLOT-7 | AB-1746-IV16 | 16 DC inputs |
| SLOT-8 | AB-1746-NIO4V | 4 analog in / out |
| SLOT-9 | AB-1746-NI4 | 4 analog in |
| SLOT-PS | AB-1747-P1 | Chassis power supply, +24 V / AC / COM |

> **Note**: the 1747-DCM in Slot-1 is a Remote I/O **adapter**, not a scanner — it presents this chassis to the VXI-resident 6008-SV scanner as adapter 1. The scanner is in the VXI crate in B132, not here.

---

## Hoffman Box — Master Layout

```mermaid
flowchart TB
    subgraph HOFFMAN["Hoffman Box 34x42 (Building B118)"]
        
        subgraph PLC["Allen-Bradley SLC-500 PLC"]
            SLOT0["Slot-0: AB-1747-L532<br/>(SLC-5/03 CPU)"]
            SLOT1["Slot-1: AB-1747-DCM<br/>(Remote I/O adapter)"]
            SLOT2["Slot-2: AB-1746-IO8<br/>(8 I/O Combo)"]
            SLOT3["Slot-3: AB-1746-THERMC<br/>(Thermocouple)"]
            SLOT5["Slot-5: AB-1746-OX8<br/>(8 Relay Output)"]
            SLOT6["Slot-6: AB-1746-IB16<br/>(16 DC Input)"]
            SLOT7["Slot-7: AB-1746-IV16<br/>(16 DC Input)"]
            SLOT8["Slot-8: AB-1746-NIO4V<br/>(4 Analog I/O)"]
            SLOT9["Slot-9: AB-1746-NI4<br/>(4 Analog Input)"]
            P1["AB-1747-P1<br/>(Power Supply)"]
        end

        subgraph POWER["Power Supplies"]
            SOLA["SOLA 85-10-2120<br/>(±15V, +5V, 24V)"]
            KEPKO_120["Kepko 120V/1A<br/>(×2: PS-1, PS-4)"]
            KEPKO_5["Kepko 5V/20A<br/>(PS-2)"]
            KEPKO_240["Kepko 240V/0.225A<br/>(PS-5)"]
        end

        subgraph BOARDS["Circuit Boards"]
            MON_BD["PS Monitor Board<br/>SD-730-793-12"]
            REG_BD["Regulator Card<br/>PC-237-230-14-C0"]
            TRIG_L["Left Trigger Interconnect<br/>SD-730-793-08"]
            TRIG_R["Right Trigger Interconnect<br/>SD-730-793-07"]
            INT1["Interface Board INT1"]
            INT2["Interface Board INT2"]
            FIRE_BD["ENERPRO Firing Board"]
        end

        subgraph TERMINALS["Terminal Strips"]
            TS1["TS-1"]
            TS3["TS-3: PPS Status LEDs"]
            TS5["TS-5: Contactor Controls"]
            TS6["TS-6: Grounding Tank"]
            TS7["TS-7: Power Distribution"]
            TS8["TS-8: Misc"]
        end

        subgraph CONNECTORS["External Connectors"]
            PPS_CONN["PPS GOB1208PNE<br/>(8-pin circular)"]
            AMP_8PIN["AMP 8-Pin<br/>(PPS LEDs)"]
            BNC_RACK["BNC-1 thru BNC-12<br/>(Monitor/Trigger)"]
        end

        subgraph CONTROLS["Local Control Panel"]
            SMART_TOUCH["Smart Touch Panel<br/>(Operator Interface)"]
            LEDS_PPS["PPS Permit LEDs"]
            LEDS_EMER["Emergency Off LEDs"]
            LEDS_KEY["Key Permit LEDs"]
            LEDS_WG["Waveguide LEDs"]
        end
    end
```

---

## PLC Slot Allocation — Detailed I/O Map

### Slot-1: AB-1747-DCM (Data Communications Module)
```
Scanner / communications module
Connected to: AB-1747-L532 (processor)
```

### Slot-2: AB-1746-IO8 (8-point Digital I/O Combo)

```
┌────────────────────────────────────────────────────────────────┐
│  SLOT-2: AB-1746-IO8                                           │
├──────────┬────────┬────────────────────────────────────────────┤
│ Channel  │ Dir    │ Function                                   │
├──────────┼────────┼────────────────────────────────────────────┤
│ OUT 3    │ Output │ Ross Grounding Switch Relay Coil (120VAC)  │
│          │        │ PLC Rung 0016: PPS1 AND PPS2 → energize   │
│ OUT 5    │ Output │ (Referenced in code)                       │
│ IN 1+    │ Input  │ (Connection shown)                         │
│ IN 1-    │ Input  │ (Connection shown)                         │
│ IN 2+    │ Input  │ (Connection shown)                         │
│ IN 2-    │ Input  │ (Connection shown)                         │
│ COM      │ Common │ AC Common                                  │
└──────────┴────────┴────────────────────────────────────────────┘
```

### Slot-3: AB-1746-THERMC (Thermocouple Input)
```
Thermocouple inputs for temperature monitoring
(SCR oil temps, air temps, transformer temps)
```

### Slot-5: AB-1746-OX8 (8-point Relay Output)

```
┌────────────────────────────────────────────────────────────────┐
│  SLOT-5: AB-1746-OX8                                           │
├──────────┬────────┬────────────────────────────────────────────┤
│ Channel  │ Dir    │ Function                                   │
├──────────┼────────┼────────────────────────────────────────────┤
│ OUT 2    │ Output │ *** CONTACTOR ENABLE ***                   │
│          │        │ Energizes K4 relay in switchgear           │
│          │        │ PLC Rung 0017: Touch Panel Enable          │
│          │        │   AND Emergency Off Clear                  │
│          │        │ INPUT SIDE: PPS 1 signal (24VDC from       │
│          │        │   GOB1208PNE) — HARDWARE FAIL-SAFE       │
│ OUT 1    │ Output │ Contactor On/Off (Rung 0002)              │
│ (others) │ Output │ Various control outputs                    │
└──────────┴────────┴────────────────────────────────────────────┘

⚠️  CRITICAL SAFETY NOTE:
    The OX8 module uses relay contacts.
    The INPUT side of OUT 2 relay contacts is wired to PPS 1 signal
    (24VDC from GOB1208PNE connector, not from PLC power).
    If PPS removes 24VDC, K4 CANNOT be energized even if PLC fails.
```

### Slot-6: AB-1746-IB16 (16-point DC Input)

```
┌────────────────────────────────────────────────────────────────┐
│  SLOT-6: AB-1746-IB16                                          │
├──────────┬────────────────────────────────────────────────────┤
│ Input    │ Function                                            │
├──────────┼────────────────────────────────────────────────────┤
│ IN 0     │ (Available)                                         │
│ IN 1     │ (Available)                                         │
│ IN 2     │ (Available)                                         │
│ IN 3     │ (Available)                                         │
│ IN 4     │ (Available)                                         │
│ IN 5     │ (Available)                                         │
│ IN 6     │ (Available)                                         │
│ IN 7     │ (Available)                                         │
│ IN 8     │ Grounding Tank Oil Level (LEV-3 NC contact)        │
│ IN 9     │ Manual Grounding Switch Status (aux contact)       │
│ IN 10    │ (Available)                                         │
│ IN 11    │ (Available)                                         │
│ IN 12    │ (Available)                                         │
│ IN 13    │ (Available)                                         │
│ IN 14    │ *** PPS 1 Input *** (from GOB1208PNE)            │
│          │   Rungs: 0014 (Emergency Off), 0015 (PPS ON),     │
│          │          0016 (Ross Switch Enable)                  │
│ IN 15    │ *** PPS 2 Input *** (from GOB1208PNE)            │
│          │   Rungs: 0015 (PPS ON), 0016 (Ross Switch),       │
│          │          0068 (Bias Power Enable)                   │
└──────────┴────────────────────────────────────────────────────┘
```

### Slot-7: AB-1746-IV16 (16-point DC Input)
```
Additional digital inputs (permits, status)
```

### Slot-8: AB-1746-NIO4V (4-point Analog I/O)
```
Analog voltage I/O for control signals
```

### Slot-9: AB-1746-NI4 (4-point Analog Input)

```
┌────────────────────────────────────────────────────────────────┐
│  SLOT-9: AB-1746-NI4                                           │
├──────────┬────────────────────────────────────────────────────┤
│ Input    │ Function                                            │
├──────────┼────────────────────────────────────────────────────┤
│ IN 3     │ Danfysik DC-CT analog output                       │
│          │ (HVPS output current to klystron)                   │
│          │ Connected via TS-6 pins 1-2                         │
└──────────┴────────────────────────────────────────────────────┘
```

---

## Terminal Strip Assignments

### TS-3: PPS Status LEDs
```
Connects to AMP 8-Pin connector
4 LEDs on exterior of Hoffman Box:
  - 2× GREEN (PPS OK indicators)
  - 2× RED (PPS fault indicators)
```

### TS-5: Contactor Controls

```
┌──────────────────────────────────────────────────────────────────┐
│  TS-5 — CONTACTOR CONTROLS                                       │
│  (Interface between Hoffman Box and Contactor Disconnect Panel)  │
├──────┬──────────────┬────────────────────────────────────────────┤
│ Pin  │ Wire Color   │ Function                                   │
├──────┼──────────────┼────────────────────────────────────────────┤
│  1   │              │ (Contactor control signal)                 │
│  2   │              │ (Contactor control signal)                 │
│  3   │              │ DC Voltage                                 │
│  4   │              │ (Connection)                               │
│  5   │              │ Contactor Ready                            │
│  6   │              │ (Connection)                               │
│  7   │              │ Contactor Closed indicator                 │
│  8   │              │ (Connection)                               │
│  9   │              │ Reset contact                              │
│ 10   │              │ (Connection)                               │
│ 11   │              │ PPS signal                                 │
│ 12   │              │ PPS Common                                 │
│ 13   │              │ Close/Ready                                │
│ 14   │              │ S5 NC aux (PPS Readback) → Pin B          │
│ 15   │              │ S5 COM aux (PPS Readback) → Pin A         │
├──────┼──────────────┼────────────────────────────────────────────┤
│ Cable│ Belden 83715 │ 15 conductor, #16 AWG, Teflon insulated   │
│      │              │ Routed to Contactor Disconnect Panel       │
└──────┴──────────────┴────────────────────────────────────────────┘
```

### TS-6: Grounding Tank Interface

```
┌──────────────────────────────────────────────────────────────────┐
│  TS-6 — GROUNDING TANK CONNECTIONS                                │
│  (Interface between Hoffman Box and Termination Tank)            │
├──────┬──────────────┬────────────┬───────────────────────────────┤
│ Pin  │ Wire Color   │ Dest       │ Function                      │
├──────┼──────────────┼────────────┼───────────────────────────────┤
│  1   │              │ J2/Danfysik│ Danfysik Analog Output (+)    │
│  2   │              │ J2/Danfysik│ Danfysik Analog Output (-)    │
│  3   │              │ J2/Danfysik│ Danfysik +V Supply            │
│  4   │              │ J2/Danfysik│ Danfysik -V Supply            │
│  5   │              │ J2/Danfysik│ Danfysik +15V                 │
│  6   │              │ J2/Danfysik│ Danfysik -15V                 │
│  7   │              │ P5/Oil     │ Oil Level 12VDC Source         │
│  8   │              │ P5/Oil     │ Oil Level Return → Slot6 IN8  │
│  9   │              │ P5/ManSW   │ Manual GRN SW (NO/NC*)        │
│ 10   │              │ P5/ManSW   │ Manual GRN SW Common          │
│ 11   │ GRN/BLK      │ P5/Ross   │ Ross GRN SW Aux COM           │
│      │              │            │ → Pin D of GOB1208PNE        │
│ 12   │              │ P5/Ross   │ Ross GRN SW Aux NC             │
│      │              │            │ → Pin C of GOB1208PNE        │
│ 13   │              │ P5/Ross   │ Ross GRN SW Coil (+)           │
│      │              │            │ ← Slot-2 IO8 OUT3 (120VAC)   │
│ 14   │              │ P5/Ross   │ Ross GRN SW Coil (-)           │
│      │              │            │ ← Slot-2 IO8 AC COM           │
│ 15   │              │ SCR Tank  │ SCR Phase Tank Oil Level       │
│ 16   │              │ SCR Tank  │ SCR Phase Tank Oil Level       │
│ 17   │              │ Crowbar   │ Crowbar Tank Oil Level         │
│ 18   │              │ Crowbar   │ Crowbar Tank Oil Level         │
│ 19   │              │ P5/Ross   │ Ross GRN SW Aux NO             │
│ 20   │              │ P5/Shunt  │ Return Current Shunt (+)       │
│ 21   │              │ P5/Shunt  │ Return Current Shunt (-)       │
│      │              │            │ (Earth of Grounding Tank)     │
├──────┼──────────────┼────────────┼───────────────────────────────┤
│ Cable│ Belden 83709│            │ 9 conductor, #16 AWG, Teflon  │
│      │              │            │ + Belden 83715 15C #16        │
└──────┴──────────────┴────────────┴───────────────────────────────┘
```

### TS-7: Power Distribution
```
TS7-1:  120VAC A Phase
TS7-13: Filter
TS7-14: Filter
```

---

## PPS Connector — GOB1208PNE Wiring

```mermaid
flowchart LR
    subgraph PPS_BOX["PPS Interface Chassis<br/>(Locked box on Hoffman Box)"]
        GOB["GOB1208PNE<br/>8-Pin Circular<br/>(Burndy/Souriau Trim Trio)"]
    end

    subgraph SIGNALS["Signal Routing"]
        PIN_E["Pin E: PPS 1 Enable (+)"]
        PIN_F["Pin F: PPS 1 Enable (-)"]
        PIN_G["Pin G: PPS 2 Enable (+)"]
        PIN_H["Pin H: PPS 2 Enable (-)"]
        PIN_A["Pin A: Readback 1 (from S5 COM)"]
        PIN_B["Pin B: Readback 1 (from S5 NC)"]
        PIN_C["Pin C: Readback 2 (from Ross NC)"]
        PIN_D["Pin D: Readback 2 (from Ross COM)"]
    end

    subgraph DEST["Destinations"]
        S6_IN14["Slot-6 IN14<br/>(PPS 1 to PLC)"]
        S6_IN15["Slot-6 IN15<br/>(PPS 2 to PLC)"]
        S5_OX8["Slot-5 OX8 OUT2<br/>Input Side<br/>(Hardware fail-safe)"]
        TS5_14["TS-5 Pin 14<br/>(S5 NC contact)"]
        TS5_15["TS-5 Pin 15<br/>(S5 COM contact)"]
        TS6_11["TS-6 Pin 11<br/>(Ross COM)"]
        TS6_12["TS-6 Pin 12<br/>(Ross NC)"]
    end

    PIN_E --> S6_IN14
    PIN_E --> S5_OX8
    PIN_F --> S6_IN14
    PIN_G --> S6_IN15
    PIN_H --> S6_IN15
    TS5_15 --> PIN_A
    TS5_14 --> PIN_B
    TS6_12 --> PIN_C
    TS6_11 --> PIN_D
```

---

## Power Distribution

```
120VAC Input (3-Phase + Neutral)
    │
    ├── Phase A (TS7-1) ──→ SOLA 85-10-2120
    │                        ├── +15V, -15V (Danfysik, Monitor Board)
    │                        ├── +5V (Logic)
    │                        └── +24V (Control)
    │
    ├── Phase B ──→ Kepko 120V/1A (PS-1) ──→ Crowbar Left Side
    │           ──→ Kepko 120V/1A (PS-4) ──→ Crowbar Right Side
    │
    ├── Phase C ──→ Kepko 5V/20A (PS-2) ──→ Filament/Heater
    │           ──→ Kepko 240V/0.225A (PS-5) ──→ HV Bias
    │
    └── 120V/24V Transformer ──→ 24VDC for PLC, relays, control
                              ──→ AC Bias Power Supply

    120VAC ──→ ENERPRO Firing Board ──→ SCR Gate Triggers
    120VAC ──→ AC Bias P.S. ──→ Klystron Bias
    120VAC ──→ GRN Tank Relay Coil (via Slot-2 OUT3)
    240VDC ──→ P.S. ──→ (High voltage control)
```

---

## BNC Monitor/Trigger Connections

```
┌──────────────────────────────────────────────────────┐
│  BNC Panel (Rear of Hoffman Box)                      │
├──────────┬───────────────────────────────────────────┤
│ BNC-1    │ Arc Fault (Pearson CT from Grounding Tank)│
│ BNC-2    │ Thermocouple                              │
│ BNC-3    │ (Monitor)                                  │
│ BNC-4    │ (Monitor)                                  │
│ BNC-5    │ (Monitor)                                  │
│ BNC-6    │ (Monitor)                                  │
│ BNC-7    │ (Monitor)                                  │
│ BNC-8    │ (Monitor)                                  │
│ BNC-9    │ (Monitor)                                  │
│ BNC-10   │ (Monitor)                                  │
│ BNC-11   │ (Monitor)                                  │
│ BNC-12   │ (Monitor)                                  │
│ Isolated │ (Isolated BNC)                             │
└──────────┴───────────────────────────────────────────┘
```

---

## Local Control Panel

```
┌─────────────────────────────────────────────────────────┐
│              LOCAL CONTROL PANEL                         │
│  (Front of Hoffman Box)                                  │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ PPS     │  │EMERGENCY │  │ KEY      │  │WAVEGUIDE│ │
│  │ PERMIT  │  │  OFF     │  │ PERMIT   │  │         │ │
│  │ LED(G/R)│  │ LED(G/R) │  │ LED(G/R) │  │ LED(G/R)│ │
│  └─────────┘  └──────────┘  └──────────┘  └─────────┘ │
│                                                          │
│  ┌──────────────────┐  ┌──────────────────────────────┐ │
│  │ SMART TOUCH      │  │ EMERGENCY OFF    EMERGENCY   │ │
│  │ PANEL            │  │ NC Switch        OFF NC      │ │
│  │ (Operator I/F)   │  │                  Switch      │ │
│  └──────────────────┘  └──────────────────────────────┘ │
│                                                          │
│  KEY PERMIT NO Switch                                    │
│  54VDC 4-Position Selector                               │
│                                                          │
│  CROWBAR indicators                                      │
│  SCR Bottom Oil / SCR Top Oil B                          │
│  Air Temp indicators                                     │
└─────────────────────────────────────────────────────────┘
```

---

## Weidmuller Terminal Block Parts List

```
1. QTY (2) WDK 2.5 PE  P/N 1036300000  (Ground terminal)
2. QTY (2) WDU 2.5     P/N 1020080000  (Feed-through terminal)
3. QTY (6) WDU 2.5     P/N 1020010000  (Feed-through terminal)
4. QTY (6) WDU 2.5     P/N 1020000000  (Feed-through terminal)
5. QTY (4) WSI 4/2-11/4x1/4 P/N 1880430000 (Fuse terminal)
6. QTY (1) ZQV 2.5     P/N 1693800000  (Cross connector)
7. QTY (1) ZQV 2.5     P/N 1693810000  (Cross connector)
8. QTY (1) WEW 35      P/N 1840460000  (End bracket)
```

