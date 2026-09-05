# 04 — Regulator Board Design and Component Analysis

> **Primary source**: [`../designNotes/EnerproVoltageandCurrentRegulatorBoardNotes.docx`](../designNotes/EnerproVoltageandCurrentRegulatorBoardNotes.docx) — J. Sebek's circuit analysis of SD-237-230-14-C1. **This is the authoritative document for this board**; where this note and that document differ, the docx wins.
>
> **Drawing**: [`../../documentation/schematics/sd2372301401.pdf`](../../documentation/schematics/sd2372301401.pdf) — SD-237-230-14-C1, read directly September 2026. Literal transcription in [`../../documentation/schematics/technical_notes/sd2372301401.md`](../../documentation/schematics/technical_notes/sd2372301401.md).
>
> **Verification status (3 September 2026): VERIFIED against both the drawing and the source document.** The component families named below are correct. Earlier revisions **omitted several devices that are actually on the board** — including the one component that most constrains the upgrade — and did not describe the control architecture at all. Both gaps are now filled.

## Control architecture — the three things that matter most

**1. It is a minimum-select, not a summing junction.** The voltage chain and the current chain are combined through a **non-linear diode junction with both anodes tied together**. The *lower* cathode voltage wins and sets the common anode, which becomes the SIG-HI control voltage sent to the Enerpro board. A 15 V supply through 10 kΩ biases the conducting diode; a **10 V Zener** clamps the anode.

**2. The AC current loop never takes control — by design.** Its reference at **J4-2 (IL1)** comes from the Enerpro board's own +5 V reference. Against a typical AC current sense of ≈ 2.2 V DC, the OP77 error amplifier saturates at ≈ +14 V, which is above the 10 V clamp, so the current chain can never win the diode select. Sebek's conclusion: *"it probably is better to just eliminate this circuit which is designed to never be used in the feedback control of the Enerpro."* **Treat the HVPS as voltage-regulated only.**

**3. This board senses AC input current, not HVPS output current.** The phases are sensed by **300:5 current transformers** on the transformer input (EI-730-790-00-C0), full-wave rectified, paralleled and terminated in a **0.5 Ω burden resistor** (WD-730-790-01-C3). The **HVPS output current is measured independently** by the Danfysik DC transducer in the termination tank. These two quantities are frequently conflated.

### Loop dynamics

| Element | Value |
|---|---|
| Voltage input low-pass | τ = 0.01 s ⇒ corner **15.9 Hz** |
| Error amplifier zero | **7.96 Hz** |
| Error amplifier poles | **0 Hz** (pure integrator) and **15.9 kHz** |
| System type | **Type 1** — no steady-state error between setpoint and readback |
| Integrator gain | ≈ **−5 × 10⁻³** |

Feedback components: $R_{FB1} = 10.0$ kΩ, $C_{FB1} = 2.0$ µF, $C_{FB2} = 1.0$ nF.

### HV readback scaling

The dividers (WD-730-794-04-C0, "TRANSFORMER TANK WD-730-792-01" section) are **five 20 MΩ resistors in series (100 MΩ) into two 1 MΩ in parallel (500 kΩ)**. Because the 500 kΩ bottom leg is loaded by the board's ≈ 10.5 kΩ input, the divider behaves as a **current source of 10 nA/V with 500 kΩ output impedance**; about 98% of the DC current flows in the load resistor. End-to-end DC scale factor:

$$T_{IN}(0) = \frac{R_\text{load}}{R_\text{div}} = \frac{10^4}{10^8} = 1 \times 10^{-4} \quad \Rightarrow \quad \approx 10{,}000{:}1$$

giving a maximum input of **9.0 V** at 90 kV. Signal arrives on **Belden 88761** shielded twisted pair (≈ 35 pF/ft, negligible against the 1 µF load capacitor).

## Overview

This document analyzes the SLAC-designed regulator board (SD-237-230-14-C1) that interfaces with Enerpro thyristor gate firing boards. The board is designed to work as either a current or voltage controller and represents a critical interface component in the HVPS control system.

The drawing title block reads **"PEP II RF SYSTEM — ENERPRO VOLTAGE AND CURRENT REGULATOR BOARD"**; engineer M. Nguyen 9-17-97, drafter T. Phan, checker J. Olszewski 10-5-99, revision C1 "ADDED NOTES FOR NLCTA" 5/21/03. The sheet carries **two** sets of notes and jumper tables — one for the 2 MW PEP-II supply and one for NLCTA. The SPEAR3 installation uses the PEP-II configuration.

## Connector Interface (as labelled on the drawing)

| Connector | Pin | Label |
|---|---|---|
| J1 | A / B | NEG. VOLTAGE SENSE / RETURN |
| J1 | C / D | POS. CURRENT SENSE / RETURN |
| J3 | A / B / C | POS. VOLTAGE SENSE MONITOR / POS. CURRENT SENSE MONITOR / GND |
| **J4** | **A** | **+ EL1** — labelled "POS. VOLTAGE LIMIT COMMAND" on the drawing, but this is the **reference voltage INPUT** from AB Slot-8 Output 0 (across J4-1 / J4-7). The drawing label is a misnomer |
| **J4** | **B** | **+ IL1** — current-loop reference input, from the Enerpro +5 V reference |
| **J4** | **C** | **SIG-HI** — "SCR PHASED-CONTROL OUTPUT" to the Enerpro SIG HI input |
| J4 | D / E | INH / − SIG-HI ; INH — "SCR GATE INHIBIT COMMAND" |
| J4 | F / G / H | + EL1 / IL1 (+12 V pin) ; COM ; +30 VDC |

**EL1** and **IL1** drive the **EL** and **EN** limit inputs on the Enerpro FCOG6100 (connector P6/J6, pins 17–18). **SIG-HI** is this board's contribution to the Enerpro SIG HI control input, where it is summed with the PLC feedforward term.

## Board Specifications

### **SLAC Regulator Board SD-237-230-14-C1**
- **Function**: Dual-mode current or voltage controller
- **Interface**: Enerpro thyristor gate firing boards
- **Design**: SLAC custom design for HVPS applications
- **Configuration**: Analog control with precision components

## Primary Component Analysis

### **High-Performance Analog Components**

The regulator board utilizes several categories of precision analog components, each selected for specific performance characteristics:

```
                    ┌─────────────────────────────────────────┐
                    │       REGULATOR BOARD ARCHITECTURE      │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Precision Amplifiers          │    │
                    │  │                                 │    │
                    │  │   • INA117 (Difference Amp)     │    │
                    │  │   • INA114 (Instrumentation)    │    │
                    │  │   • OP77 (High Performance)     │    │
                    │  └─────────────────────────────────┘    │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Output Drivers                │    │
                    │  │                                 │    │
                    │  │   • BUF634 (High Current)       │    │
                    │  │   • MC34074 (Quad Amp)          │    │
                    │  └─────────────────────────────────┘    │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Isolation Components          │    │
                    │  │                                 │    │
                    │  │   • 4N32 (Optocoupler)          │    │
                    │  │   • Isolation Barriers          │    │
                    │  └─────────────────────────────────┘    │
                    └─────────────────────────────────────────┘
```

## Detailed Component Specifications

### **INA117 - High Performance Difference Amplifier**

**Key Specifications:**
- **Function**: Unity gain difference amplifier
- **Common-Mode Voltage**: Up to 200V capability
- **Differential Input Impedance**: High impedance (specific value in original document)
- **Power Supply**: ±15 VDC
- **Output Range**: ±10 VDC
- **Bandwidth**: 300 kHz (-3dB)
- **Manufacturer**: Texas Instruments
- **Packages**: DIP and SOIC

**Application Notes:**
- Excellent common-mode rejection for high voltage environments
- Series input resistance degrades differential accuracy
- Pins 1 and 5 typically connected to ground
- Critical for high common-mode voltage applications

**Input-Output Relationship:**
```
Vout = (V+ - V-) × Gain
```
Where gain is unity for standard configuration.

### **INA114 - Precision Instrumentation Amplifier**

**Key Specifications:**
- **Architecture**: Three op-amp design with laser-trimmed resistors
- **Gain**: Adjustable with single external resistor
- **Gain Bandwidth Product**: 1 MHz
- **Input Impedance**: High impedance (specific value in original)
- **Manufacturer**: Texas Instruments
- **Packages**: DIP and SOIC

**Design Considerations:**
- Lower common-mode rejection than INA117
- Cannot operate at high common-mode voltages like INA117
- Excellent for applications requiring adjustable gain
- Single resistor gain setting simplifies design

### **OP77 - Ultra-Low Noise Operational Amplifier**

**Key Specifications:**
- **Performance**: Very high performance for offset and noise
- **Gain Bandwidth Product**: 600 kHz
- **Manufacturer**: Analog Devices
- **Availability**: Still commercially available in multiple packages

**Application:**
- Critical applications requiring minimal offset and noise
- Precision voltage and current measurement circuits
- High-accuracy control loop applications

### **BUF634 - High-Speed, High-Current Buffer**

**Key Specifications:**
- **Bandwidth**: Selectable 30 MHz or 180 MHz (-3dB)
- **Output Current**: 250 mA continuous
- **Input Offset**: Tens of mV (requires compensation)
- **Manufacturer**: Texas Instruments
- **Upgrade Path**: BUF634A recommended for new designs

**BUF634A Improvements:**
- **Higher Bandwidth**: Improved frequency response
- **Higher Output Current**: Increased drive capability
- **Faster Slew Rate**: Better transient response
- **Package Limitation**: No DIP package available

**Design Implementation:**
- Typically used in feedback circuits with high-performance op-amps
- Op-amp compensates for BUF634 offset errors
- Critical for driving low-impedance loads

### **MC34074 - General Purpose Quad Amplifier**

**Key Specifications:**
- **Configuration**: Quad amplifier package
- **Gain Bandwidth Product**: 4.5 MHz
- **Power Supply**: Single supply operation capability
- **Manufacturer**: ON Semiconductor
- **Availability**: Surface mount packages

**Alternative Component:**
- **TL074**: Comparable performance from Texas Instruments
- **Availability**: DIP packages available
- **Performance**: Slightly lower specifications than MC34074

### **4N32 - Optocoupler Isolation**

**Key Specifications:**
- **Turn-on Time**: 5 μs
- **Turn-off Time**: 100 μs
- **Manufacturer**: Vishay
- **Function**: Electrical isolation between circuits

**Application:**
- Critical for isolating control circuits from high voltage
- Provides safety isolation in HVPS applications
- Timing characteristics important for control response

## Circuit Design Principles

### **Voltage Controller Configuration**

When configured as a voltage controller, the board implements:

```
                    ┌─────────────────────────────────────────┐
                    │        VOLTAGE CONTROL LOOP             │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Voltage Sensing               │    │
                    │  │                                 │    │
                    │  │   • High Voltage Divider        │    │
                    │  │   • INA117 Difference Amp       │    │
                    │  │   • Common-Mode Rejection       │    │
                    │  └─────────────────────────────────┘    │
                    │                    │                    │
                    │                    ▼                    │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Error Amplification           │    │
                    │  │                                 │    │
                    │  │   • OP77 Precision Op-Amp       │    │
                    │  │   • INA114 Instrumentation      │    │
                    │  │   • Adjustable Gain             │    │
                    │  └─────────────────────────────────┘    │
                    │                    │                    │
                    │                    ▼                    │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Output Drive                  │    │
                    │  │                                 │    │
                    │  │   • BUF634 High Current         │    │
                    │  │   • Enerpro Interface           │    │
                    │  │   • 4N32 Isolation              │    │
                    │  └─────────────────────────────────┘    │
                    └─────────────────────────────────────────┘
```

### **Current Controller Configuration**

When configured as a current controller, the board implements:

```
                    ┌─────────────────────────────────────────┐
                    │        CURRENT CONTROL LOOP             │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Current Sensing               │    │
                    │  │                                 │    │
                    │  │   • Current Shunt/CT            │    │
                    │  │   • INA117 Difference Amp       │    │
                    │  │   • Precision Measurement       │    │
                    │  └─────────────────────────────────┘    │
                    │                    │                    │
                    │                    ▼                    │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Control Processing            │    │
                    │  │                                 │    │
                    │  │   • OP77 Error Amplification    │    │
                    │  │   • MC34074 Signal Processing   │    │
                    │  │   • Loop Compensation           │    │
                    │  └─────────────────────────────────┘    │
                    │                    │                    │
                    │                    ▼                    │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Thyristor Interface           │    │
                    │  │                                 │    │
                    │  │   • BUF634 Gate Drive           │    │
                    │  │   • 4N32 Isolation              │    │
                    │  │   • Enerpro Compatibility       │    │
                    │  └─────────────────────────────────┘    │
                    └─────────────────────────────────────────┘
```

## Interface Specifications

### **Enerpro Thyristor Gate Firing Board Interface**

The regulator board provides:
- **Gate Drive Signals**: Properly conditioned firing pulses
- **Isolation**: Electrical isolation for safety
- **Timing Control**: Precise firing angle control
- **Protection**: Fault detection and shutdown capability

### **Control System Integration**

The board interfaces with:
- **EPICS Control System**: Remote setpoint and monitoring
- **Local Control Panel**: Manual operation capability
- **Interlock Systems**: Safety system integration
- **Diagnostic Systems**: Performance monitoring and troubleshooting

## Performance Characteristics

### **Voltage Control Mode**
- **Accuracy**: High precision voltage regulation
- **Response Time**: Fast transient response
- **Stability**: Excellent long-term stability
- **Noise**: Low noise operation

### **Current Control Mode**
- **Accuracy**: Precise current regulation
- **Linearity**: Excellent current linearity
- **Protection**: Overcurrent protection capability
- **Dynamic Range**: Wide operating range

## Additional devices on the board

The first of these is the single most important obsolescence item on the board.

| Reference | Device | Function |
|---|---|---|
| **VR1, VR2** | **VTL5C** | **Opto-coupled variable resistor** (LED + photoresistor in one package). Resistance swings from **MΩ to kΩ**; response is milliseconds to the low resistance but **≈ 150 ms to return** to the high resistance. **Obsolete** — the component identified in the PDR as forcing a regulator redesign, with no drop-in modern equivalent. |
| U10A–U10D | **CD4044B** | Quad R/S three-state latches holding the OVER-V, OVER-I and MAN-TRIP conditions until reset |
| DC1 | **NMA1215** | Isolated DC-DC converter powering the isolated current preamp (U9) |
| DC2 | **MAD4030-B** | Obsolete 4.5 W DC-DC converter, formerly Astec, since acquired by Artesyn |
| — | **1N3064** | Small-signal switching diode, now obsolete. Digi-Key recommends Vishay **1N4150**; Vishay lists **BAW27** as the direct replacement |
| U20, U19 | INA117 | Difference amplifiers on the EL1 and IL1 paths at J4A/J4B |
| U18 | OP77 | Final amplifier driving SIG-HI through R69 (7.50 kΩ) |
| U21, U3–U8 | 4N32 | Optocouplers, turn-on 5 µs / turn-off 100 µs |

Zener clamping voltages used on the board: **1N4728 = 3.3 V, 1N4740 = 10 V, 1N4742 = 12 V, 1N4747 = 20 V**.

### Trip and reset chain

| Function | Devices |
|---|---|
| Over-voltage trip adjust | R38 5 kΩ (CW), comparator U11A (MC34074) |
| Over-current trip adjust | R43 5 kΩ (CW), comparator U14A (MC34074) |
| Trip latches | U10A–U10D (CD4044B) |
| SCR gate under-voltage lockout | U14D (MC34074), 4N32, D8 1N4747 20 V |
| Trip and soft-start | U11D (MC34074), R28 10 kΩ (CW), R52 250 kΩ, C18 10 µF |
| Auto reset | U14B (MC34074), R51 300 kΩ, C32 10 µF, jumper JP7 |

Front-panel indicators: **DS1 RED OVER CURRENT**, **DS2 RED OVER VOLTAGE**, **DS3 RED MANUAL TRIP**, **DS4 YEL CURRENT LIMIT**, a yellow VOLTAGE LIMIT lamp at U11C, and **DS19 GRN POWER ON**.

## Component Availability and Obsolescence

### **Current Status (as of documentation)**

**Obsolete — drives the redesign:**
- **VTL5C (VR1, VR2)**: opto-coupled variable resistors. No drop-in equivalent; a redesign of the surrounding loop is required.

**Still Available:**
- **OP77**: Multiple packages available (Analog Devices)
- **MC34074**: Surface mount packages (ON Semiconductor)
- **TL074**: DIP packages available (Texas Instruments alternative)
- **4N32**: Standard optocoupler (Vishay)

**Availability Concerns:**
- **BUF634**: Some versions still available, but TI recommends migration
- **INA117**: Availability status needs verification
- **INA114**: Availability status needs verification
- **CD4044B**: CMOS 4000-series latch; check current stock and lifetime status
- **NMA1215 / MAD3030-8**: isolated DC-DC modules; check current stock and lifetime status

**Recommended Upgrades:**
- **BUF634 → BUF634A**: Improved performance, no DIP package
- **Component Verification**: Regular availability checks recommended

## Design Considerations for Current Systems

### **Maintenance Strategy**
1. **Component Stockpiling**: Maintain inventory of critical components
2. **Alternative Sourcing**: Identify equivalent components
3. **Board Redesign**: Consider modern component alternatives
4. **Performance Validation**: Verify equivalent component performance

### **Upgrade Opportunities**
1. **Modern Components**: Higher performance alternatives available
2. **Digital Integration**: Hybrid analog/digital control possibilities
3. **Improved Isolation**: Enhanced safety features
4. **Diagnostic Capability**: Built-in test and monitoring features

## Integration with HVPS Architecture

### **Role in Overall System**

The regulator board serves as the critical interface between:
- **Digital Control Systems**: EPICS and local control
- **Analog Power Electronics**: Enerpro thyristor firing boards
- **High Voltage Circuits**: Primary power control
- **Safety Systems**: Protection and interlock integration

### **Relationship to Other Components**

```
                    ┌─────────────────────────────────────────┐
                    │         SYSTEM INTEGRATION              │
                    │                                         │
                    │  ┌─────────────────────────────────┐    │
                    │  │   EPICS Control System          │    │
                    │  └─────────────┬───────────────────┘    │
                    │                │                        │
                    │                ▼                        │
                    │  ┌─────────────────────────────────┐    │
                    │  │   SLAC Regulator Board          │    │
                    │  │   SD-237-230-14-C1              │    │
                    │  └─────────────┬───────────────────┘    │
                    │                │                        │
                    │                ▼                        │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Enerpro Thyristor Boards      │    │
                    │  └─────────────┬───────────────────┘    │
                    │                │                        │
                    │                ▼                        │
                    │  ┌─────────────────────────────────┐    │
                    │  │   Primary Power Control         │    │
                    │  │   (12-Pulse Thyristor)          │    │
                    │  └─────────────────────────────────┘    │
                    └─────────────────────────────────────────┘
```

## Conclusions

The SLAC regulator board SD-237-230-14-C1 represents a sophisticated analog control interface that:

1. **Provides Dual Functionality**: Both voltage and current control modes
2. **Ensures High Performance**: Precision components for accurate control
3. **Maintains Safety**: Proper isolation and protection features
4. **Enables Integration**: Compatible with both legacy and modern control systems

The detailed component analysis reveals both the sophistication of the original design and the need for ongoing attention to component availability and potential upgrades to maintain system reliability and performance.

---

**Document Status**: Complete analysis of regulator board design  
**Related Documents**: SLAC-PUB-7591, PowerPoint schematics, Hoffman box wiring  
**Application**: Critical for understanding HVPS control system interface design

