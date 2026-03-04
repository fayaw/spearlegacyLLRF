# Ross Engineering 713203 — Vacuum Contactor & Driver System Schematic

> **Drawing**: `rossEngr713203.pdf`
> **Title**: Ross Engineering Corp. System Schematic
> **Parts**: P/N 820360 (Controller/Driver HCA-1-A) + P/N 813203 (Vacuum Contactor HQ3)
> **Date**: Original 1978, ECN revisions through 2021
> **Location**: 599 Westchester Dr, Campbell, CA 95008

---

## System Block Diagram

```mermaid
flowchart TB
    subgraph DRIVER["Driver Unit HCA-1-A (P/N 820360)"]
        AC_IN["115/120 VAC Input"]
        FU["Fuse"]
        FNP["FNP Relay"]
        
        subgraph POWER["Power & Energy Storage"]
            XFMR["Power Supply<br/>Transformer"]
            RECT["Rectifier<br/>(Block 1)"]
            C6["Energy Storage<br/>Capacitor<br/>+350V DC"]
            VSENSOR["Voltage Sensor<br/>(Guardian)"]
        end
        
        subgraph RELAYS["Relay Logic"]
            K1["K1 Close Relay"]
            K2["K2 Ready Relay"]
            K3["K3 Current Sensing"]
            MX["MX External Control"]
            TX["TX Tripping"]
            RR["RR Reset"]
            CR1_CR2["CR1, CR2"]
        end
        
        subgraph INDICATORS["Indicators & Controls"]
            READY_IND["Ready Indicator<br/>(Neon)"]
            OPER_CTR["Operation Counter<br/>(Allen-Bradley)"]
            DOOR_INTLK["Safety Door<br/>Interlocks"]
            LOCAL_RDY["Local Ready<br/>Indicator"]
        end
    end

    subgraph CONTACTOR["Vacuum Contactor HQ3 (P/N 813203)"]
        L1_HOLD["L1 Holding Coil<br/>(DC, Low Power)"]
        L2_CLOSE["L2 Closing Coil<br/>(Stored Energy)"]
        TOGGLE["Toggle Mechanism"]
        HV_CONTACTS["HV Vacuum Contacts"]
        
        subgraph AUX["Auxiliary Contacts TB2"]
            S1["S1 — Interlock<br/>(Mechanical seal-in)"]
            S2["S2 — Close Limit<br/>S2A: NO, S2B: indication"]
            S3["S3 — Open Indication<br/>S3A, S3B: indication"]
            S4["S4 — (Available)"]
            S5["S5 — PPS Readback<br/>COM=TB2-18, NC=TB2-19, NO=TB2-20"]
        end
    end

    AC_IN --> FU --> XFMR --> RECT --> C6
    C6 --> VSENSOR
    VSENSOR -->|"Charged"| K2
    C6 -->|"+350V stored energy"| K1
    K1 -->|"Close command"| L2_CLOSE
    L2_CLOSE --> TOGGLE
    TOGGLE --> HV_CONTACTS
    MX -->|"Permit"| L1_HOLD
    L1_HOLD -->|"Hold"| HV_CONTACTS
    HV_CONTACTS --> S1 & S2 & S3 & S5
    DOOR_INTLK -->|"Capacitor dump<br/>when door opened"| C6
```

---

## TB2 Terminal Block — Vacuum Contactor Interface

```
┌──────────────────────────────────────────────────────────────┐
│                    TB2 — VACUUM CONTACTOR                     │
│               (Ross Engineering HQ3 P/N 813203)              │
├──────┬───────────────────────────────────────────────────────┤
│ Pin  │ Function                                              │
├──────┼───────────────────────────────────────────────────────┤
│  1   │ Frame / DC Holding return                             │
│  2   │ Stored Energy (C6 connection, 40,000µF)               │
│  3   │ (Connection)                                          │
│  4   │ (Not documented)                                      │
│  5   │ S3A Auxiliary Contact                                 │
│  6   │ Current Sensing / Voltage Sensor                      │
│  7   │ (Not documented)                                      │
│  8   │ (Not documented)                                      │
│  9   │ S2 Ready Indication                                   │
│ 10   │ Contactor State                                       │
│ 11   │ S2B Limit Indication                                  │
│ 12   │ Local Reset / MT1                                     │
│ 13   │ Contactor Switch / CR7                                │
│ 14   │ MX / PPS Connection                                   │
│ 15   │ (Not documented)                                      │
│ 16   │ (Not documented)                                      │
│ 17   │ (Not documented)                                      │
│ 18   │ S5 Common (Auxiliary Contact for PPS)                 │
│ 19   │ S5 NC Contact (PPS Readback)                          │
│ 20   │ S5 NO Contact                                         │
│ S2   │ Close indication                                      │
│ S2B  │ Limit switch                                          │
│ S3A  │ Open indication                                       │
│ S3B  │ Open indication                                       │
└──────┴───────────────────────────────────────────────────────┘

PPS Readback via S5:
  Contactor OPEN  → S5 NC CLOSED  → Pins 18-19 closed circuit → SAFE
  Contactor CLOSED → S5 NC OPEN   → Pins 18-19 open circuit  → OPERATING
```

---

## Coil Specifications

```
┌──────────────────────────────────────────────────────────────────┐
│                     CONTACTOR COILS                                │
├───────────┬──────────────────────────────────────────────────────┤
│ L1        │ HOLDING COIL                                         │
│           │  - DC, Low Power                                     │
│           │  - Holds contactor closed after L2 fires             │
│           │  - Fed through MX NO contact                         │
│           │  - Fast dropout: <1 AC cycle                         │
│           │  - With AC lost: holds ≥170ms before dropout         │
├───────────┼──────────────────────────────────────────────────────┤
│ L2        │ CLOSING COIL                                         │
│           │  - High Power, Stored Energy from C6                 │
│           │  - Fires toggle mechanism to close HV contacts       │
│           │  - Energy: C6 = 40,000µF at ~350V DC                │
│           │  - Recharge time: several seconds                    │
├───────────┼──────────────────────────────────────────────────────┤
│ NOTE      │ gp4397040201 MISLABELS L1 as L2.                    │
│           │ This drawing (rossEngr713203) has CORRECT labeling.  │
└───────────┴──────────────────────────────────────────────────────┘
```

---

## Auxiliary Contact Map (S1–S5)

```mermaid
flowchart LR
    subgraph CONTACTOR_STATE["Contactor State"]
        OPEN["OPEN<br/>(De-energized)"]
        CLOSED["CLOSED<br/>(Energized)"]
    end

    subgraph S_CONTACTS["Auxiliary Switch Contacts"]
        S1["S1: Mechanical Interlock<br/>Confirms toggle sealed"]
        S2A["S2: Close Limit NO<br/>Closed when contactor closed"]
        S2B["S2B: Indication<br/>Closed when contactor closed"]
        S3A["S3A: Open Indication<br/>Closed when contactor open"]
        S3B["S3B: Open Indication<br/>Closed when contactor open"]
        S5_NC["S5 NC: PPS Readback<br/>CLOSED when open, OPEN when closed"]
        S5_NO["S5 NO: (Available)<br/>OPEN when open, CLOSED when closed"]
    end

    OPEN -->|"S1=open, S2=open<br/>S3=closed, S5NC=closed"| S_CONTACTS
    CLOSED -->|"S1=closed, S2=closed<br/>S3=open, S5NC=open"| S_CONTACTS
```

---

## Safety Cautions (from drawing)

```
⚠️  CAUTION: THIS IS A HV ENERGY STORAGE DEVICE
    Operating at 300 to 400 V DC
    Discharge time to 80V is approx. 5 MINUTES
    WAIT AT LEAST 5 MINUTES before touching live parts
    after removing power.

⚠️  CAUTION: AC MUST BE OFF before external discharge
    of capacitors to prevent blowing AC fuses.

⚠️  Safety door interlocks automatically discharge
    capacitors when driver door is opened.
    External terminals also provided for test/discharge
    without opening door.
```

---

## Interconnection Notes

```
Driver HCA-1-A (P/N 820360)
    └── Connected to Vacuum Contactor HQ3 via TB2
    └── Connected to Switchgear via TB3
    └── Powered by 115/120 VAC

Wire routing to Hoffman Box (TS-5):
    Wires 20, 21, 22 → TB3-22, TB3-23, TB3-24 (per GP-439-704-02)
    Also: TB2 pins 18, 19, 20 (S5 aux contacts for PPS readback)

    TS-5 in Hoffman Box:
        Pin 14 ← TB2-19 (S5 NC) via wire bundle
        Pin 15 ← TB2-18 (S5 COM) via wire bundle
        These connect to GOB12-88PNE Pins A and B for PPS readback
```

