# PEP-II / SPEAR3 Klystron Filament Heater — Comprehensive Technical Notes

**Source Drawing**: SD-349-311-20, Rev E2 (`sd3403110002.pdf`)  
**Alternate Reference**: SD-340-311-00 (appears in some drawing references)  
**Title**: PEP2 RF KLY FILAMENT SCHEMATIC  
**Original Designer**: P. Corredoura, Stanford Linear Accelerator Center  
**Organization**: Stanford University / U.S. Department of Energy  
**Document Date**: Technical notes compiled March 2026  
**Status**: Legacy system documentation — active reference for SPEAR3 LLRF Upgrade  

---

## 1. Executive Summary

This document provides a comprehensive technical analysis of the SPEAR3 klystron cathode filament heater system, as documented in SLAC drawing SD-349-311-20 Rev E2. The filament heater is a critical subsystem of the RF station that provides controlled AC power to the klystron cathode, enabling thermionic electron emission necessary for klystron operation.

The system was originally designed for the PEP-II B-Factory program at SLAC (circa 1997–1999) by P. Corredoura and the PEP-II LLRF group, and was subsequently adapted for use in the SPEAR3 storage ring RF system at the Stanford Synchrotron Radiation Lightsource (SSRL). It has been in continuous service for over 25 years.

**Key Design Characteristics**:
- Motor-driven variac providing continuously variable AC voltage
- 10:1 step-down toroidal isolation transformer (T1)
- Solid-state relay (SSR) for on/off switching
- Comprehensive monitoring: AC voltmeter, AC ammeter, current transformer (Texmate CT), and elapsed-time meter
- Remote control interface via Allen-Bradley (A/B) PLC digital/analog I/O
- Front-panel indicators (DS1, DS2 green LEDs) and local metering

**Power Supply Capabilities**:
| Parameter | Value |
|-----------|-------|
| AC Input | 120 VAC, 60 Hz |
| Maximum Power Rating | ~1 kW (1000 W) |
| Nominal Operating Power | ~500 W (actual sustained operation) |
| Nominal Operating Voltage | 68 V (AC, at transformer input) |
| Nominal Operating Current | 7.3 A |
| Transformer Ratio | 10:1 step-down |
| Secondary Output (Post-Transformer) | ~6.8 V RMS at 73 A |
| Maximum Rating | 14.0 V RMS @ 71 A |
| Thermal Headroom | 2:1 (500W nom / 1000W max) |

---

## 2. System Context — SPEAR3 RF Station

### 2.1 Role in the RF System

The SPEAR3 RF station provides 476 MHz RF power to the storage ring via a single high-power klystron operating at approximately 1 MW. The klystron cathode heater is an essential auxiliary system that must be energized and at operating temperature **before** the High Voltage Power Supply (HVPS) can be enabled.

**System Hierarchy (CURRENT LEGACY SYSTEM)**:
```
                           SPEAR3 RF STATION ARCHITECTURE
                              (476 MHz, ~1 MW Output)

                    ┌─────────────────────────────────────────┐
                    │         SPEAR3 Storage Ring             │
                    │      (4 Single-Cell Cavities)          │
                    └─────────────────┬───────────────────────┘
                                      │ 476 MHz RF Power
                                      │
    ┌─────────────────────────────────┼─────────────────────────────────┐
    │                    RF STATION (Building B132)                     │
    │                                 │                                 │
    │  ┌─────────────────┐    ┌──────▼──────┐    ┌─────────────────┐   │
    │  │ LLRF Controller │    │ Klystron    │    │ Waveguide       │   │
    │  │ (VXI Legacy)    │───►│ ~1 MW       │───►│ Distribution    │   │
    │  │                 │    │ 476 MHz     │    │ Network         │   │
    │  └─────────────────┘    └─────────────┘    └─────────────────┘   │
    │           │                      ▲                               │
    │           │                      │                               │
    │           ▼                      │                               │
    │  ┌─────────────────┐    ┌──────────────┐                        │
    │  │ Drive Amplifier │    │ HVPS         │                        │
    │  │ ~50 W           │    │ up to 90 kV  │                        │
    │  │ 476 MHz         │    │ (B118)       │                        │
    │  └─────────────────┘    └──────────────┘                        │
    │           │                      ▲                               │
    │           │              ┌───────┴───────┐                       │
    │           │              │               │                       │
    │           ▼              ▼               ▼                       │
    │  ┌─────────────────┐  ┌─────────────┐ ┌─────────────────┐       │
    │  │ Allen-Bradley   │  │ Kly MPS     │ │ **CATHODE       │       │
    │  │ PLC System      │  │ (Machine    │ │ HEATER**        │       │
    │  │ (B118)          │  │ Protection) │ │ (This Document) │       │
    │  └─────────────────┘  └─────────────┘ └─────────────────┘       │
    │           │                      │                               │
    │           ▼                      ▼                               │
    │  ┌─────────────────┐    ┌─────────────────┐ ┌─────────────────┐ │
    │  │ Fiber Optic     │    │ Arc Detection   │ │ Cavity Tuner    │ │
    │  │ Interface       │    │ System          │ │ Controllers     │ │
    │  │ (B118 ↔ B132)   │    │ (Optical)       │ │ (4 Cavities)    │ │
    │  └─────────────────┘    └─────────────────┘ └─────────────────┘ │
    └─────────────────────────────────────────────────────────────────┘

                              CRITICAL DEPENDENCIES
    
    Startup Sequence:  Heater → HVPS → RF Drive → Klystron → Cavities
    Normal Shutdown: RF Off → HVPS Off → Heater REMAINS ON (for quick recovery)
    Maintenance Shutdown: RF Off → HVPS Off → Heater Cooldown (extended outages only)
    Protection Chain:  System Fault → MPS → Emergency shutdown (heater may trip independently)
```

### 2.2 Operational Sequence

The filament heater plays a critical role in the klystron startup/shutdown sequence:

1. **Pre-Heat** (Cold Start): Filament heater energized; cathode temperature ramps to ~1000°C over 30 minutes
2. **Ready State**: Heater at nominal power; "FILAMENT ON" status reported to MPS
3. **HVPS Enable**: Only permitted when heater status = READY (MPS interlock)
4. **Normal Operation**: Heater maintains cathode temperature during RF operation
5. **Shutdown**: HVPS must be de-energized before filament heater cooldown begins
6. **Cooldown**: Gradual heater power reduction to prevent cathode thermal shock

### 2.3 Physical Location

The filament heater controller is physically located in the RF station equipment area:
- **Building**: B132, Room 11 (RF station area at SSRL)
- **Power Source**: 120 VAC Phase C from Hoffman NEMA enclosure
- **Control Interface**: Fiber-optic link to local panel, then to Allen-Bradley PLC in B118

---

## 3. Detailed Circuit Analysis

### 3.1 Power Path — Block Diagram

```
                    SPEAR3 KLYSTRON FILAMENT HEATER POWER PATH
                              (SD-349-311-20 Rev E2)

Facility Power                                                    Klystron Cathode
     │                                                                    │
     ▼                                                                    ▼
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ 120 VAC     │    │ 10A Fuse/   │    │ SS Relay    │    │ Variac V1   │    │ Toroidal    │
│ Phase C     │───►│ Breaker      │───►│ (FILAMENT_  │───►│ 1.00 KVA    │───►│ Xfmr T1     │
│ (Hoffman    │    │ (TB1)        │    │ ON control) │    │ 0-140 VAC   │    │ 10:1 ratio  │
│ Box B118)   │    │              │    │              │    │ Motor Drive │    │ 3-turn pri  │
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                  │                    │
                                                                  ▼                    ▼
                                                          ┌─────────────┐    ┌─────────────┐
                                                          │ Motor M1    │    │ Filament    │
                                                          │ UP/DOWN     │    │ Output      │
                                                          │ Limit SW    │    │ ~6.8 V RMS  │
                                                          │ (A/B PLC)   │    │ ~73 A       │
                                                          └─────────────┘    │ to Cathode  │
                                                                             └─────────────┘
                                                                                    │
                                                                                    ▼
                                                                             ┌─────────────┐
                                                                             │ Current     │
                                                                             │ Monitoring  │
                                                                             │ (Texmate CT)│
                                                                             └─────────────┘

MONITORING POINTS (per PDF schematic):
┌─────────────┐                                          ┌─────────────┐
│ [V] Voltage │◄─── Measured at transformer input ──────│ 68V @ 7.3A  │
│ Monitor     │     (variac output)                      │ (nominal)   │
│ (via J1)    │                                          │             │
└─────────────┘                                          └─────────────┘
                                                                │
                                                                ▼
                                                         ┌─────────────┐
                                                         │ [A] Current │
                                                         │ Monitor     │
                                                         │ (Texmate CT)│
                                                         │ ~73A sec    │
                                                         │ (via J1)    │
                                                         └─────────────┘
```

**Signal Flow Summary**:
- **AC Power**: 120 VAC Phase C → 10A Protection → SS Relay → Variac → Transformer → Cathode
- **Control**: A/B PLC → Local Panel (Fiber) → J1 Connector → FILAMENT_ON, MOTOR-UP
- **Monitoring**: Voltage/Current Sensors → A/B PLC → EPICS/VXI System

### 3.2 AC Input Section

**Input Terminal Block (TB1)**:
- 120 VAC, 60 Hz, single-phase supply from Hoffman box
- Phase C of the facility AC distribution
- Protected by 10A fuse or circuit breaker

**Input Connections at TB1**:
| Terminal | Signal | Description |
|----------|--------|-------------|
| AC1 | Line | 120 VAC hot |
| AC2 | Neutral/Return | AC return |
| — | OC REGULATED | DC regulated control power |
| — | CTRL | Control bus |
| — | GND | System ground reference |

### 3.3 Solid-State Relay (SS Relay)

The solid-state relay provides the primary on/off switching function for the filament heater:

- **Function**: Switches 120 VAC power to the variac primary
- **Control Signal**: `FILAMENT_ON` from A/B PLC digital output
- **Type**: AC solid-state relay (likely zero-crossing type for reduced EMI)
- **Rating**: ≥10A at 120 VAC (matches fuse rating)
- **Advantages over electromechanical relay**:
  - No contact bounce or arcing
  - Longer operational life (no mechanical wear)
  - Zero-crossing switching minimizes inrush transients
  - Faster switching response

### 3.4 Variac (V1) — Motor-Driven Autotransformer

The variac is the central voltage control element, providing continuously variable AC output:

**Specifications**:
| Parameter | Value |
|-----------|-------|
| Type | Motor-driven variable autotransformer |
| Rating | 1.00 KVA |
| Input | 120 VAC, 60 Hz |
| Output Range | 0–140 VAC (continuously variable) |
| Control | Bidirectional DC motor (M1) |

**Motor Drive Circuit**:
- **Motor M1**: DC drive motor mechanically coupled to variac wiper
- **Direction Control**: Two A/B PLC digital outputs — `MOTOR-UP` and implicit motor-down
- **Limit Switches**:
  - **UP LIMIT**: Prevents over-travel at maximum voltage position
  - **DOWN LIMIT (SW)**: Prevents over-travel at minimum voltage position
- **Limit Switch Configuration**: Normally Closed (N/C) contacts in series with motor drive
  - When limit is reached, N/C contact opens, de-energizing motor in that direction
  - Motor can still be driven in the opposite direction

**Motor Control Logic**:
```
MOTOR-UP command (from A/B) AND (UP LIMIT N/C = closed)
    → Motor drives variac wiper toward higher voltage
    
Motor-DOWN (implied) AND (DOWN LIMIT N/C = closed)
    → Motor drives variac wiper toward lower voltage
```

### 3.5 Isolation Transformer (T1) — Toroidal Step-Down

The toroidal transformer T1 is a critical safety and functional component:

**Specifications**:
| Parameter | Value |
|-----------|-------|
| Type | Toroidal (wound on toroid core) |
| Turns Ratio | 10:1 step-down |
| Primary Winding | 3 turns through toroid (Note 5 on drawing) |
| Secondary Winding | ~30 turns (implied by 10:1 ratio, 3-turn primary) |
| KVA Rating | 1.00 KVA (shared with variac rating) |
| Expected Secondary Voltage | 4.84 V RMS (at nominal variac setting) |
| Maximum Secondary Voltage | 14.0 V RMS (at maximum variac output) |

**Design Notes**:
- The 3-turn-through-toroid primary is an unconventional but effective construction for high-current, low-voltage transformation
- A toroidal core provides:
  - Low magnetic leakage flux (important near sensitive RF equipment)
  - High efficiency (>95% typical for toroidal transformers)
  - Compact form factor
  - Low acoustic noise
- The 10:1 ratio steps down 120 VAC variac output to the ~5–14 V range needed for klystron cathode heating
- **Galvanic isolation**: T1 provides essential electrical isolation between facility AC mains and the klystron cathode, which operates at up to ~90 kV (HVPS cathode voltage)

**Voltage Relationship**:
```
V_secondary = V_variac_output / 10

At nominal: V_sec = 48.4 V (variac) / 10 = 4.84 V RMS
At maximum: V_sec = 140 V (variac) / 10 = 14.0 V RMS
```

### 3.6 Current Transformer and Texmate Meter

**Current Transformer (CT)**:
- **Type**: Toroidal current transformer integrated with Texmate digital panel meter
- **Function**: Non-invasive measurement of filament heater current
- **Location**: Secondary (load) side of transformer T1
- **Signal Output**: Proportional analog signal to Texmate meter and A/B analog input

**Texmate CT Panel Meter**:
- **Manufacturer**: Texmate Inc. (USA-based industrial panel meter manufacturer)
- **Function**: Digital display of AC current on front panel
- **Features**:
  - True RMS measurement capability
  - Configurable display scaling
  - Analog output for remote monitoring
  - Known for reliability in industrial/accelerator environments (>32 million units deployed globally)

### 3.7 Switch Configurations (S1, S2)

The schematic shows two switch positions associated with the meters:

- **S1, S2**: Selector switches for meter functions
  - **LOCK**: Normal operating position — meters display live readings
  - **HOLD**: Freezes current display reading
  - **TEST**: Meter self-test mode
- These are standard features on industrial panel meters allowing operators to verify meter operation without disrupting the system

---

## 4. Monitoring and Instrumentation

### 4.1 AC Voltage Monitoring

**AC Volt Meter (Front Panel)**:
- **Type**: Analog or digital AC voltmeter
- **Measurement Point**: Secondary side of transformer T1
- **Display**: Front panel mounted for local operator visibility
- **Remote Signal**: `V_MON+` / `V_MON-` analog output to A/B PLC
  - Routed through J1 connector to "TO A/B ANALOG IN SIGNAL" and "TO A/B ANALOG IN RETURN"

### 4.2 AC Current Monitoring

**AC Ammeter (Front Panel)**:
- **Full Scale**: 1.0 A
- **Type**: Analog panel ammeter with current transformer
- **Note**: The 1.0A full scale on the primary side corresponds to much higher current on the secondary (10:1 transformer ratio means 1A primary ≈ 0.1A secondary contribution, but the CT may be on the secondary measuring the full ~20A load current)
- **Remote Signal**: `A_MON+` / `A_MON-` analog output to A/B PLC

### 4.3 Elapsed Time Meter (M2)

**Time Meter**:
- **Type**: Non-resettable elapsed time meter (hours counter)
- **Display**: Front panel — shows total accumulated filament-on hours
- **Label**: `8F_MS HOURS`
- **Function**: Tracks total operational hours for:
  - Klystron cathode lifetime estimation
  - Preventive maintenance scheduling
  - Warranty and service records
- **Industry Standard**: Elapsed time meters are standard practice for klystron installations — cathode life is strongly correlated with total heater hours

### 4.4 Front Panel LED Indicators

| Indicator | Color | Label | Function |
|-----------|-------|-------|----------|
| DS1 | Green | FILAMENT ON | Illuminated when SS relay is energized and AC power is applied to variac |
| DS2 | Green | MOTOR-UP | Illuminated when variac motor is being driven in the "up" (increasing voltage) direction |

**Note**: Drawing Note 4 confirms "LED's DS1 and DS2 located on front panel."

### 4.5 Complete Front Panel Layout

```
┌──────────────────────────────────────────────────┐
│                  FRONT PANEL                      │
│                                                   │
│  [DS1 ●]         [DS2 ●]                         │
│  FILAMENT ON     MOTOR-UP                         │
│                                                   │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐      │
│  │ AC VOLT  │   │ AC AMP   │   │  HOURS   │      │
│  │  METER   │   │  METER   │   │  METER   │      │
│  │          │   │ 1.0A FS  │   │  (M2)    │      │
│  └──────────┘   └──────────┘   └──────────┘      │
│                                                   │
│  [LOCK/HOLD/TEST]  [LOCK/HOLD/TEST]              │
│     S1 (Volts)        S2 (Amps)                   │
└──────────────────────────────────────────────────┘
```

---

## 5. Control Interface

### 5.1 External I/O Connector (J1)

The J1 connector provides the interface between the filament heater chassis and the Allen-Bradley PLC system via the local panel fiber-optic link.

**Digital Outputs FROM A/B PLC (control commands)**:

| J1 Pin | Signal | Function |
|--------|--------|----------|
| — | FROM A/B DIGITAL OUT CONTROL | FILAMENT_ON command |
| — | FROM A/B DIGITAL OUT RETURN | Return for FILAMENT_ON |
| — | FROM A/B DIGITAL OUT CONTROL | MOTOR-UP command |
| — | FROM A/B DIGITAL OUT RETURN | Return for MOTOR-UP |

**Analog Inputs TO A/B PLC (monitoring signals)**:

| J1 Pin | Signal | Function |
|--------|--------|----------|
| — | TO A/B ANALOG IN SIGNAL | V MON+ (voltage monitor positive) |
| — | TO A/B ANALOG IN RETURN | V MON- (voltage monitor return) |
| — | TO A/B ANALOG IN SIGNAL | A MON+ (current monitor positive) |
| — | TO A/B ANALOG IN RETURN | A MON- (current monitor return) |

### 5.2 Output Terminal Block (TB2)

The TB2 terminal block provides the power output and monitoring connections:

| TB2 Pin | Signal | Description |
|---------|--------|-------------|
| 14 | AC POWER 1 COMMON | AC power common/neutral |
| 15 | DC OUT / V_MON+ | DC voltage monitoring output (positive) |
| — | DC OUT / V_MON- | DC voltage monitoring output (negative) |
| — | AC POWER 2 | Second AC power connection |
| 17 | DC OUT / A_MON+ | DC current monitoring output (positive) |
| — | DC OUT / A_MON- | DC current monitoring output (negative) |
| — | GROUND_TAB | Safety ground connection |

### 5.3 Allen-Bradley PLC Integration

The filament heater interfaces with the Allen-Bradley (A/B) PLC system that controls the overall RF station:

**Complete Control Interface Architecture**:
```
                    SPEAR3 FILAMENT HEATER CONTROL INTERFACE
                              (Multi-Level Isolation)

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            BUILDING B118 (HVPS Area)                                │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                 │
│  │ VXI/LLRF        │    │ Allen-Bradley   │    │ Hoffman Box     │                 │
│  │ Controller      │───►│ PLC System      │───►│ 120 VAC         │                 │
│  │ (Legacy)        │    │ Digital I/O     │    │ Distribution    │                 │
│  │                 │    │ Analog I/O      │    │                 │                 │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘                 │
│                                  │                                                  │
└──────────────────────────────────┼──────────────────────────────────────────────────┘
                                   │ (Fiber Optic Link)
                                   │ HFBR-2414T/2416T Transceivers
                                   │ Complete Galvanic Isolation
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           BUILDING B132 (RF Station)                                │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                 │
│  │ Local Panel     │    │ Filament Heater │    │ Klystron        │                 │
│  │ SD-340-311-01   │───►│ Chassis         │───►│ Cathode         │                 │
│  │ Fiber→24V Logic │    │ SD-349-311-20   │    │ (~90 kV HV)     │                 │
│  │ Signal Conditioning │ │ J1 Connector    │    │                 │                 │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘                 │
└─────────────────────────────────────────────────────────────────────────────────────┘

                              J1 CONNECTOR PINOUT
                         (Filament Heater ↔ Local Panel)

    Digital Commands (FROM A/B PLC):                Analog Monitoring (TO A/B PLC):
    ┌─────────────────────────────┐                ┌─────────────────────────────┐
    │ FILAMENT_ON                 │                │ V_MON+ (Voltage Monitor)    │
    │ FILAMENT_ON_RETURN          │                │ V_MON- (Voltage Return)     │
    │ MOTOR-UP                    │                │ A_MON+ (Current Monitor)    │
    │ MOTOR-UP_RETURN             │                │ A_MON- (Current Return)     │
    └─────────────────────────────┘                └─────────────────────────────┘
```

**Digital Outputs (PLC → Heater)**:
1. `FILAMENT_ON`: Energizes the solid-state relay, applying AC power to the variac
2. `MOTOR-UP`: Drives the variac motor to increase output voltage

**Analog Inputs (Heater → PLC)**:
1. `V_MON` (differential): Scaled DC voltage proportional to filament RMS voltage
2. `A_MON` (differential): Scaled DC voltage proportional to filament RMS current

**Local Panel Interface (SD-340-311-01)**:
From the OCR analysis of the local panel schematic:
- `FILAMENT_REQUEST` signal from VXI/PLC through fiber-optic receiver (HFBR-2416T)
- Signal conditioning converts fiber-optic to 24V logic for driving the heater chassis
- Status signals returned through fiber-optic transmitters

---

## 6. Wiring Specifications

### 6.1 Wire Gauge Standards

Per drawing Notes 1 and 2:

| Wiring Type | Gauge | Usage |
|-------------|-------|-------|
| **Bold wiring** (on schematic) | #16 AWG | Power circuits — AC mains, variac primary, motor drive |
| **Non-bold wiring** (on schematic) | #18 AWG | Control circuits — relay coils, meter connections, signal wiring |

**Wire Gauge Justification**:
- **#16 AWG**: Rated for 10A in chassis wiring (NEC Table 310.16) — adequate for 120 VAC input at 10A fuse rating
- **#18 AWG**: Rated for 5A in chassis wiring — adequate for control signals and meter circuits

### 6.2 Component Locations

Per drawing Notes 3 and 4:
- **J1, TB1, and TB2**: Located on rear panel (for external connections)
- **DS1 and DS2 (LEDs)**: Located on front panel (for operator visibility)

---

## 7. Safety and Protection Features

### 7.1 Overcurrent Protection

- **10A Fuse/Breaker**: Primary protection against short circuits and overloads on the AC input
- **SS Relay**: Provides fast electronic disconnection of AC power on `FILAMENT_ON` de-assertion

### 7.2 Mechanical Over-Travel Protection

- **UP LIMIT Switch**: Prevents variac wiper from exceeding maximum voltage position
- **DOWN LIMIT Switch (SW)**: Prevents variac wiper from going below minimum position
- Both use Normally Closed contacts that open at the limit, interrupting motor drive power in that direction

### 7.3 Electrical Isolation

- **Transformer T1**: Provides galvanic isolation between AC mains and the klystron cathode circuit
- **Critical**: The klystron cathode operates at up to ~90 kV relative to ground (HVPS voltage). The isolation transformer must withstand this potential difference. In the PEP-II/SPEAR3 design, the filament power is delivered through the HVPS oil-filled tank via appropriate high-voltage feedthroughs
- **Fiber-optic isolation**: Control signals from the A/B PLC pass through fiber-optic transceivers (HFBR-2414T/2416T) in the local panel, providing complete galvanic isolation of the control interface

### 7.4 Ground Safety

- **GROUND_TAB**: Dedicated safety ground connection on TB2 ensures the chassis and all exposed metal parts are properly grounded
- **GND**: System ground reference on TB1

### 7.5 MPS Integration

The filament heater status contributes to the Klystron Machine Protection System:
- `FILAMENT ON` status is a prerequisite for HVPS enable permission
- Loss of filament current triggers MPS fault response
- Heater "ready" status required in the RF permit chain

---

## 8. Klystron Cathode Heater — Physics and Engineering Background

### 8.1 Purpose of the Cathode Heater

The klystron is a vacuum electron tube that generates high-power RF energy. At its core is a thermionic cathode — a specially coated electrode that emits electrons when heated to high temperature (~1000°C). The filament heater provides the thermal energy to maintain this emission temperature.

**Thermionic Emission (Richardson-Dushman Equation)**:
```
J = A₀ T² exp(-φ / kT)

where:
  J = emission current density (A/m²)
  A₀ = Richardson constant (~120 A/cm²·K²)
  T = cathode temperature (K)
  φ = work function of cathode material (eV)
  k = Boltzmann constant (8.617 × 10⁻⁵ eV/K)
```

Even small changes in cathode temperature cause exponential changes in electron emission. This is why heater voltage regulation is critical:
- A 1% change in heater voltage → ~2% change in cathode temperature → ~10% change in emission current
- Excessive temperature shortens cathode life; insufficient temperature limits klystron performance

### 8.2 Typical Klystron Heater Specifications

Based on industry data and accelerator facility experience:

| Parameter | PEP-II/SPEAR3 | European XFEL (Thales TH1801) | European XFEL (CPI VKL8301) |
|-----------|---------------|-------------------------------|------------------------------|
| Heater Voltage | ~5 V | 8.5 V | 24 V |
| Heater Current | ~20 A | 40 A | 22.5 A |
| Power | ~100 W | ~340 W | ~540 W |
| Isolation Voltage | ~90 kV | 130 kV | 130 kV |
| Regulation | ±1–2% (variac) | ±0.3% | ±0.3% |

*Data sources: SLAC system documentation; DESY/Budker INP PAC09 paper (TU6RFP016)*

### 8.3 Cathode Lifetime Considerations

Klystron cathode lifetime is primarily determined by:

1. **Heater voltage/temperature**: Operating at rated voltage maximizes emission while balancing cathode life. Over-voltage accelerates evaporation of the cathode coating (barium oxide or similar dispenser cathode material).

2. **Thermal cycling**: Frequent on/off cycles create thermal stress that can crack the cathode or cause coating delamination. Controlled ramp rates (provided by the motor-driven variac) mitigate this.

3. **Total accumulated hours**: Industry typical cathode life is 30,000–100,000 hours depending on klystron type and operating conditions. The elapsed time meter (M2) on the heater front panel tracks this critical parameter.

4. **Poisoning**: Cathode coating can be contaminated by residual gases if the klystron vacuum degrades. This is a system-level concern, not directly related to heater design.

### 8.4 Comparison with Other Approaches

| Approach | Used At | Advantages | Disadvantages |
|----------|---------|------------|---------------|
| **Motor-driven variac** (this design) | PEP-II, SPEAR3 | Simple, reliable, smooth voltage control, inherent current limiting | Slow response (seconds), mechanical wear, size |
| **SCR phase-angle control** | Many facilities | Fast response, compact, no moving parts | Harmonic generation, EMI, complex gate drive |
| **SCR zero-crossing** | Proposed SPEAR3 upgrade | Low harmonics, fast, solid-state | Discrete power levels, requires filtering |
| **Switch-mode (HF inverter)** | European XFEL | Highest efficiency, compact, precise | Complex design, high-frequency EMI, cost |
| **Linear regulated DC** | Small klystrons | Excellent regulation, low noise | Low efficiency at high power, heat dissipation |

---

## 9. Drawing Revision History

The drawing SD-349-311-20 has undergone multiple revisions:

| Rev | Description | Notes |
|-----|-------------|-------|
| — | Initial release | Original PEP-II design by P. Corredoura |
| — | Added graphics to sections | Enhanced documentation clarity |
| — | C5 & C6, Motor UP was full LS, Current | Modified motor limit switch and current circuit |
| E2 | Current revision | Active version for SPEAR3 operations |

**Designer**: P. Corredoura — a key member of the PEP-II LLRF group at SLAC, responsible for the architecture and performance of the PEP-II Low-Level RF System. His design philosophy emphasized programmable, VXI-based systems with EPICS integration, which was groundbreaking for its era.

---

## 10. Relationship to SPEAR3 LLRF Upgrade

### 10.1 Current System Limitations

The motor-driven variac system, while proven and reliable, has several limitations that motivate the planned upgrade:

| Limitation | Impact | Upgrade Solution |
|------------|--------|-----------------|
| Slow response (seconds to minutes) | Cannot implement fast cathode protection | SCR control with <100 ms response |
| Mechanical wear | Increasing maintenance burden | Solid-state — no moving parts |
| Limited EPICS integration | Manual operation required | Full EPICS IOC with PV database |
| No automated sequences | Operator-dependent warm-up/cooldown | Python/EPICS automated sequences |
| Precision ~1–2% | Suboptimal cathode temperature control | ±0.1% digital regulation |
| Obsolete components | Difficult to source replacements | Modern, commercially available parts |
| No harmonic filtering | Potential RF interference | LC low-pass filter at 120–180 Hz |

### 10.2 Planned Upgrade Architecture

The upgrade retains the fundamental design intent (provide regulated, isolated AC power to the klystron cathode heater) while modernizing the implementation:

```
Legacy (this document):
  120VAC → SS Relay → Motor-Driven Variac → 10:1 Toroid Xfmr → Cathode

Upgrade:
  120VAC → SCR Controller → LC Low-Pass Filter → Isolation Xfmr → Cathode
                ↕                                       ↕
           EPICS IOC                              RMS Monitoring
           (Python Coordinator)                   (AD637 True RMS)
```

Key upgrade references:
- `Designs/5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md` — Detailed SCR upgrade design
- `Designs/0_PHYSICAL_DESIGN_REPORT.md` — Section 13: Klystron Cathode Heater

### 10.3 Elements Retained from Legacy Design

Several design principles from the original PEP-II schematic carry forward to the upgrade:
1. **120 VAC single-phase input** — same facility power infrastructure
2. **Isolation transformer** — essential for HV safety (up to 90 kV)
3. **Voltage and current monitoring** — upgraded to true RMS (AD637)
4. **MPS interlock integration** — heater "ready" status required for RF permit
5. **Elapsed time tracking** — critical for cathode lifetime management

---

## 11. Related Documents

### 11.1 Within This Repository

| Document | Path | Relevance |
|----------|------|-----------|
| Physical Design Report | `Designs/0_PHYSICAL_DESIGN_REPORT.md` | Top-level system architecture, Section 13 |
| Klystron Heater Upgrade Design | `Designs/5_KLYSTRON_HEATER_SUBSYSTEM_UPGRADE.md` | SCR-based replacement design |
| Local Panel Schematic | `llrf/documentation/localPanel/sd3403110100.pdf` | Fiber-optic interface to filament heater |
| LLRF Operation Notes | `llrf/documentation/LLRFOperation_jims.docx` | Operational procedures |
| MPS Wiring Diagrams | `llrf/documentation/mpsWiringDiagrams/` | Protection system integration |
| Fiber Optic Signal Control | `llrf/documentation/fiberOpticCableSignalControlRev3.docx` | Communication link details |
| HVPS Architecture | `hvps/architecture/` | HVPS integration and coordination |
| Hoffman Box Wiring | `pps/HoffmanBoxPPSWiring.docx` | AC power distribution |
| HVPS PLC Interface | `Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` | Control system integration |
| Software Design | `Designs/9_SOFTWARE_DESIGN.md` | EPICS/Python control software |
| Legacy Architecture Diagrams | `llrf/documentation/legacyArchitecture/` | System block diagrams |

### 11.2 External References

1. **P. Corredoura et al.**, "Experience with the PEP-II RF System at High Beam Currents," EPAC 2000. [arXiv:physics/0007029](https://export.arxiv.org/pdf/physics/0007029v1.pdf)
2. **P. Corredoura et al.**, "Architecture and Performance of the PEP-II Low-Level RF System," SLAC, 1999. [OSTI:10204](https://www.osti.gov/biblio/10204)
3. **R. Cassel, M.N. Nguyen**, "A unique power supply for the PEP-II klystron at SLAC," IEEE, 1997.
4. **P. Bak et al.**, "Klystron Cathode Heater Power Supply System Based on the High-Voltage Gap Transformer," PAC09, TU6RFP016. [DESY](https://bib-pubdb1.desy.de/record/91620/files/tu6rfp016.pdf)
5. **Z. Wu et al.**, "Design of the klystron filament power supply control system for EAST LHCD," AIP Advances 6, 095301 (2016).
6. **G. Caryotakis**, "High Power Klystrons: Theory and Practice at SLAC," SLAC-PUB-10620 (2004).
7. **SPEAR 3 Design Report**, SLAC, December 2002. [OSTI:808721](https://www.osti.gov/biblio/808721)
8. **S. Park**, "SSRL RF System Upgrade," EPAC (2000). [CERN](https://cds.cern.ch/record/394334/files/wep43.pdf)
9. **Texmate Inc.**, Panel Meter Product Documentation. [texmate.com](https://www.texmate.com/products/)

---

## 12. Appendix A — Complete OCR Transcript of SD-349-311-20

The following is the raw OCR extraction from the scanned drawing, provided for reference and searchability:

```
Drawing Title: PEP2 RF KLY FILAMENT SCHEMATIC
Drawing Number: SD-349-311-20 E2
Next Assemblies: SD-340-311-00

Title Block:
  STANFORD LINEAR ACCELERATOR CENTER
  U.S. DEPARTMENT OF ENERGY
  STANFORD UNIVERSITY STANFORD, CALIFORNIA
  PROPRIETARY DATA OF STANFORD UNIVERSITY AND/OR U.S. DEPARTMENT OF
  ENERGY. RECIPIENT SHALL NOT PUBLISH THE INFORMATION WITHIN UNLESS
  GRANTED SPECIFIC PERMISSION OF STANFORD UNIVERSITY.
  Designer: P CORREDOURA
  Type: SCHEMATIC
  Scale: NONE — DO NOT SCALE DRAWING
  CAD FILENAME: sd340311002

Dimensioning and Tolerancing:
  UNLESS OTHERWISE SPECIFIED
  DIMENSIONS ARE IN INCHES.
  TOLERANCES:
    BREAK EDGES .005-.015
    INTERNAL CORNERS R.015 MAX
    FRACTIONS ±
    .XX ±
    .XXX ±

Notes:
  1. ALL BOLD WIRING IS #16 GAUGE
  2. ALL NON-BOLD WIRING IS #18 GAUGE
  3. J1, TB1, AND TB2 LOCATED ON [rear panel]
  4. LED'S DS1 AND DS2 LOCATED ON FRONT PANEL
  5. PRIMARY ON T1 IS 3 TURNS THROUGH TOROID

Key Components (from schematic):
  TB1 — Input terminal block (120 VAC)
  SS RELAY — Solid-state relay (FILAMENT_ON control)
  V1 — Variac (1 KVA, motor-driven)
  T1 — Toroidal transformer (10:1, 3-turn primary)
  M1 — Drive motor (variac positioning)
  M2 — Elapsed time meter (hours)
  CT — Current transformer (Texmate)
  J1 — External I/O connector (A/B PLC interface)
  TB2 — Output/monitoring terminal block
  DS1 — Green LED (FILAMENT ON)
  DS2 — Green LED (MOTOR-UP)
  S1, S2 — Meter function switches (LOCK/HOLD/TEST)
  AC VOLT METER — Front panel voltage display
  AC AMMETER — Front panel current display (1.0A FS)

Expected Values (annotated on drawing):
  Secondary voltage: 4.84 V RMS (at terminal block 35)
  Maximum capacity: 14.0 V RMS, 1.00 KVA
  
Note: Enhanced OCR analysis confirms "140 RMS" on drawing refers to 
maximum variac output of 140 VAC, which becomes 14.0 V RMS at secondary.

Control I/O (J1):
  FROM A/B DIGITAL OUT CONTROL → FILAMENT_ON
  FROM A/B DIGITAL OUT RETURN
  FROM A/B DIGITAL OUT CONTROL → MOTOR-UP
  FROM A/B DIGITAL OUT RETURN
  TO A/B ANALOG IN SIGNAL → V MON+
  TO A/B ANALOG IN RETURN → V MON-
  TO A/B ANALOG IN SIGNAL → A MON+
  TO A/B ANALOG IN RETURN → A MON-

TB2 Output Connections:
  Pin 14: AC POWER 1 COMMON
  Pin 15: DC OUT (V_MON+, A_MON+)
  Pin 17: DC OUT (V_MON-, A_MON-)
  AC POWER 2
  GROUND_TAB
```

---

## 13. Appendix B — Component Cross-Reference

| Ref Des | Component | Function | Specifications |
|---------|-----------|----------|----------------|
| TB1 | Terminal Block | AC Input connections | 120 VAC, multi-position |
| TB2 | Terminal Block | Output/monitoring | Multi-position, pins 14/15/17 identified |
| V1 | Variac | Variable autotransformer | 1.00 KVA, 0–140 VAC output |
| T1 | Transformer | Step-down isolation | Toroidal, 10:1 ratio, 3-turn primary |
| M1 | Motor | Variac drive | DC motor, bidirectional |
| M2 | Time Meter | Elapsed hours counter | Non-resettable hours meter |
| SS RELAY | Solid-State Relay | AC power switching | ≥10A at 120 VAC |
| CT | Current Transformer | Current sensing | Texmate integrated CT |
| J1 | Connector | External I/O | A/B PLC digital/analog interface |
| DS1 | LED (Green) | FILAMENT ON indicator | Front panel |
| DS2 | LED (Green) | MOTOR-UP indicator | Front panel |
| S1 | Switch | Voltmeter function select | LOCK/HOLD/TEST |
| S2 | Switch | Ammeter function select | LOCK/HOLD/TEST |
| — | AC Volt Meter | Voltage display | Front panel, AC reading |
| — | AC Ammeter | Current display | Front panel, 1.0A full scale |
| — | Fuse/Breaker | Overcurrent protection | 10A rating |
| UP LIMIT | Limit Switch | Motor over-travel protection | N/C contact |
| DOWN LIMIT (SW) | Limit Switch | Motor over-travel protection | N/C contact |

---

**Document Control**:
- **Source**: SD-349-311-20 Rev E2 (sd3403110002.pdf)
- **Technical Notes Created**: March 2026
- **Created By**: Codegen (automated extraction and analysis)
- **Classification**: Internal Technical Reference — SPEAR3 LLRF Upgrade Project
