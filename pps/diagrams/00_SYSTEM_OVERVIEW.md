# SPEAR HVPS PPS System — Master Overview

> **Source**: 6 schematic PDFs from `pps/` + HoffmanBoxPPSWiring.docx analysis
> **Purpose**: AI-readable text representation of all PPS (Personnel Protection System) schematics for the SPEAR High Voltage Power Supply system at SLAC/SSRL.

---

## System Architecture

```mermaid
graph TB
    subgraph EXT["External Systems"]
        PPS_CHASSIS["PPS Interface Chassis<br/>(Personnel Protection System)<br/>GOB12-88PNE Connector"]
        GRID["12.47 kV Utility Power"]
        KLYSTRON["Klystron Load"]
    end

    subgraph HOFFMAN["Hoffman Box (B118 Controller) — 34x42<br/>wd7307900206"]
        PLC["Allen-Bradley SLC-500 PLC<br/>(Slots 1-9)"]
        TS5["TS-5: Contactor Controls"]
        TS6["TS-6: Grounding Tank"]
        TS3["TS-3: PPS LEDs"]
        PS["Power Supplies<br/>(Kepko, SOLA, ENERPRO)"]
        MON_BD["PS Monitor Board<br/>SD-730-793-12"]
        TRIG_L["Left Trigger Interconnect<br/>SD-730-793-08"]
        TRIG_R["Right Trigger Interconnect<br/>SD-730-793-07"]
    end

    subgraph SWITCHGEAR["Contactor Disconnect Panel (HVPS)<br/>gp4397040201 + rossEngr713203"]
        CONTROLLER["Vacuum Contactor Controller<br/>(Switchgear Logic)"]
        VAC_CONT["HV Vacuum Contactor<br/>Ross Eng. Model HQ3"]
        TB2_SW["TB2 (Contactor)"]
        K4["K4 Relay (PPS Control)"]
        MX["MX Relay (External Control)"]
        TX["TX Relay (Tripping)"]
        RR["RR Relay (Reset)"]
        L1["L1 Holding Coil"]
        L2["L2 Closing Coil"]
        S5["S5 Auxiliary Contact<br/>(PPS Readback)"]
    end

    subgraph GROUNDING["Grounding (Termination) Tank<br/>sd7307900501"]
        ROSS_SW["Ross Grounding Switch"]
        MANUAL_SW["Manual Grounding Switch<br/>(Mushroom Switch)"]
        DANFYSIK["Danfysik DC-CT<br/>Current Transducer"]
        PEARSON["Pearson CT-110<br/>Arc Fault Monitor"]
        OIL_LEVEL["Oil Level Sensor"]
        SHUNT["15A/50mV Current Shunt"]
    end

    %% Power Flow
    GRID -->|"12.47 kV"| VAC_CONT
    VAC_CONT -->|"HV Output"| GROUNDING
    GROUNDING -->|"To Grid"| KLYSTRON

    %% PPS Chain 1: Contactor
    PPS_CHASSIS -->|"PPS Enable 1&2<br/>Pins E-F, G-H"| PLC
    PLC -->|"Slot-5 OX8 OUT2<br/>Contactor Enable"| TS5
    TS5 -->|"Belden 83715<br/>15C #16 Teflon"| K4
    K4 -->|"Energize"| MX
    MX -->|"Hold Permit"| L1
    S5 -->|"NC Aux Contact<br/>PPS Readback A-B"| TS5
    TS5 -->|"Readback"| PPS_CHASSIS

    %% PPS Chain 2: Ross Ground Switch
    PLC -->|"Slot-2 IO8 OUT3<br/>120 VAC"| TS6
    TS6 -->|"Belding 83709<br/>9C #16 Teflon"| ROSS_SW
    ROSS_SW -->|"NC Aux Contact<br/>PPS Readback C-D"| TS6
    TS6 -->|"Readback"| PPS_CHASSIS

    %% Monitoring
    DANFYSIK -->|"Analog Current"| TS6
    TS6 -->|"To Slot-9 NI4<br/>Input 3"| PLC
    PEARSON -->|"Coax BNC"| TRIG_L
    OIL_LEVEL -->|"NC Dry Contact"| TS6
```

---

## Drawing Cross-Reference Map

| Drawing ID | Type | Title | Primary Subsystem | Key Interfaces |
|---|---|---|---|---|
| `gp4397040201` | Schematic | 12.47kV Vacuum Contactor Controller | Switchgear Logic | TB1, TB2, TB3 → Hoffman Box TS-5 |
| `rossEngr713203` | Schematic | Ross Eng. Vacuum Contactor/Driver | Contactor Hardware | TB2 (S1-S5 contacts), L1/L2 coils |
| `sd7307900501` | Schematic | Grounding (Termination) Tank | Safety/Grounding | J1 (MS3102R18-1P) → Hoffman Box TS-6 |
| `wd7307900103` | Wiring Diagram | Interconnection: B118 ↔ Contactor + Tank | Cable Routing | TS-1 thru TS-7, Belden 83715 cables |
| `wd7307900206` | Wiring Diagram | HVPS Controller (Hoffman Box) | PLC & Power | PLC Slots 1-9, all TS, PPS connector |
| `wd7307940600` | Wiring Diagram | Interconnection: B118 ↔ Termination Tank | Cable Routing | TS-6, Belding 83709, J1/P5 connectors |

---

## PPS Safety Chain — Two Independent Paths

```mermaid
flowchart LR
    subgraph CHAIN1["PPS Chain 1: HV Contactor"]
        direction TB
        PPS1_IN["PPS 1 Enable<br/>GOB12-88PNE Pin E→F"] --> SLOT6_IN14["PLC Slot-6<br/>IB16 Input 14"]
        SLOT6_IN14 --> RUNG0015["PLC Rung 0015<br/>Set B3:1 PPS ON"]
        RUNG0015 --> SLOT5_OUT2["PLC Slot-5<br/>OX8 OUT 2<br/>(Contactor Enable)"]
        SLOT5_OUT2 --> K4_COIL["K4 Relay Coil<br/>(in Switchgear)"]
        K4_COIL --> MX_COIL["MX Relay<br/>(via K4 NO + 86 NC)"]
        MX_COIL --> L1_HOLD["L1 Holding Coil<br/>(Vacuum Contactor)"]

        S5_NC["S5 NC Aux Contact<br/>(Contactor Open = Closed Circuit)"] --> TS5_14_15["TS-5 Pins 14,15"]
        TS5_14_15 --> PPS_AB["GOB12-88PNE<br/>Readback Pins A-B"]
    end

    subgraph CHAIN2["PPS Chain 2: Ross Grounding Switch"]
        direction TB
        PPS2_IN["PPS 2 Enable<br/>GOB12-88PNE Pin G→H"] --> SLOT6_IN15["PLC Slot-6<br/>IB16 Input 15"]
        SLOT6_IN15 --> RUNG0016["PLC Rung 0016<br/>PPS1 AND PPS2"]
        RUNG0016 --> SLOT2_OUT3["PLC Slot-2<br/>IO8 OUT 3<br/>(120 VAC)"]
        SLOT2_OUT3 --> ROSS_COIL["Ross Grounding<br/>Switch Coil"]

        ROSS_AUX["Ross Switch NC Aux<br/>(Normal = Closed Circuit)"] --> TS6_11_12["TS-6 Pins 11,12"]
        TS6_11_12 --> PPS_CD["GOB12-88PNE<br/>Readback Pins C-D"]
    end
```

### PPS Fail-Safe Design Note

The Contactor Enable uses an **AB-1746-OX8** relay output module. The input side of these relay contacts is the **PPS 1 signal from the GOB12-88PNE connector** (24 VDC). Therefore:
- Even if the **PLC fails**, the signal fails safe
- If the PPS connector does not source 24 VDC, a closed OX8 contact **cannot** energize K4
- **Known concern**: The Ross Ground Switch (Chain 2) is driven by PLC output via IO8. A PLC failure *could* source 120 VAC to the Ross switch coil without PPS command.

---

## Signal Flow Summary

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PPS INTERFACE CHASSIS                            │
│  GOB12-88PNE (8-pin circular connector)                            │
│                                                                     │
│  Pin E ─── PPS 1 Enable (24VDC source) ──→ PLC Slot-6 IN14        │
│  Pin F ─── PPS 1 Enable return                                     │
│  Pin G ─── PPS 2 Enable (24VDC source) ──→ PLC Slot-6 IN15        │
│  Pin H ─── PPS 2 Enable return                                     │
│                                                                     │
│  Pin A ←── PPS Readback 1 (S5 NC aux) ←── TS-5 pin 15             │
│  Pin B ←── PPS Readback 1 common     ←── TS-5 pin 14              │
│  Pin C ←── PPS Readback 2 (Ross NC)  ←── TS-6 pin 12              │
│  Pin D ←── PPS Readback 2 common     ←── TS-6 pin 11              │
│                                                                     │
│  Readback Logic:                                                    │
│    Pins A-B: CLOSED = contactor OPEN (safe)                        │
│    Pins C-D: CLOSED = Ross switch CLOSED/grounded (safe)           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Physical Location Map

```
                    Building B118
┌─────────────────────────────────────────────────┐
│                                                   │
│  ┌─────────────────────┐                         │
│  │  Hoffman Box 34x42  │ ◄── HVPS Controller    │
│  │  (wd7307900206)     │                         │
│  │  Contains:          │                         │
│  │   - PLC SLC-500     │                         │
│  │   - Power Supplies  │                         │
│  │   - Terminal Strips │                         │
│  │   - PPS Connector   │                         │
│  │   - Monitor Board   │                         │
│  │   - Trigger Boards  │                         │
│  └────────┬────────────┘                         │
│           │                                       │
│   Belden 83715 cables                            │
│   (wd7307900103)                                 │
│           │                                       │
│  ┌────────┴────────────┐                         │
│  │ Contactor Disconnect│ ◄── 12.47kV Switchgear │
│  │ (gp4397040201)      │                         │
│  │ (rossEngr713203)    │                         │
│  │ Contains:           │                         │
│  │  - Vacuum Contactor │                         │
│  │  - Controller Logic │                         │
│  │  - MCO Relays       │                         │
│  └─────────────────────┘                         │
│                                                   │
│   Belding 83709 cables                           │
│   (wd7307940600)                                 │
│           │                                       │
│  ┌────────┴────────────┐                         │
│  │ Grounding Tank      │ ◄── Termination Tank   │
│  │ (sd7307900501)      │                         │
│  │ Contains:           │                         │
│  │  - Ross Grnd Switch │                         │
│  │  - Manual Grnd SW   │                         │
│  │  - Danfysik DC-CT   │                         │
│  │  - Pearson CT-110   │                         │
│  │  - Oil Level Sensor │                         │
│  └─────────────────────┘                         │
│                                                   │
│           │ HV Cable                              │
│           ▼                                       │
│      ┌──────────┐                                │
│      │ Klystron │                                │
│      └──────────┘                                │
└─────────────────────────────────────────────────┘
```

