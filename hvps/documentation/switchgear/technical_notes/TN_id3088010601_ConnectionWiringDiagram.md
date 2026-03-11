Technical Note: 12.47KV Vacuum Contactor Controller
Electrical Connection Wiring Diagram


Source Document: id3088010601.pdf
Document Type: Technical Note – Circuit Schematic Analysis
Purpose: Detailed extraction of design information from circuit schematic for AI-assisted design reconstruction


────────────────────────────────────────────────────────────


# 1. Document Identification

## 1.1 Title Block Information

- Title: 12.47K VAC CNTOR CONTROLLER – ELECTRICAL CONNECTION WIRING DIAGRAM
- Drawing Number: ID-308-801-06-C1 (CAD version)
- Original Drawing: ID-308-801-06 R0 (manual drawing, superseded)
- Organization: Stanford Linear Accelerator Center (SLAC)
- Affiliated: U.S. Department of Energy / Stanford University, Stanford, California
- Project: Positron Electron Project 2 (PEP-II)
- Scale: None (do not scale drawing)
- SLAC Release: V:\MDCAD\DocumentControl\Images\Incoming\SLAC\PEP2 VCC1.dgn.tif
- Release date: 9/25/2006 12:04:54 PM
## 1.2 Revision History

- Original: Manual drawing ID-308-801-06 R0
- C1: Redrawn to CAD and resized drawing from 'D' to 'E' size, revised per as-built, CoDCS
- Date: 09/25 (September 2006)
## 1.3 Reference Drawings

- GP-439-704-02: PEP2, ELECT SYSTEMS, 12.47KV OUTDOOR SWGR & VAC CNTOR, SCHEMATIC DIAGRAM
- Ross Engineering DWG #713203: Vacuum contactor/driver schematic
# 2. Drawing Overview

This is the physical connection wiring diagram for the 12.47 kV vacuum contactor controller system. Unlike the schematic diagram (GP-439-704-02) which shows circuit logic, this drawing shows the actual physical wiring connections between equipment sections. It depicts the switchgear cabinet layout including the rear compartment, front view, swinging panel, and all inter-equipment wiring. The drawing documents how components are physically interconnected using terminal blocks, wire numbers, and cable routing between the switchgear, vacuum contactor driver, and external equipment.

# 3. Physical Layout Sections

## 3.1 Rear Compartment

- 12.47KV incoming line connections (OA, OB, OC phases)
- #4-15KV cable connections
- 120VAC source connection
- Incoming line enters from rear compartment
## 3.2 Front View

- Contains main switchgear control panel
- Current transformer connections
- Protection relay panel
- Terminal blocks TB3, TB4
- Wire name column for identification
## 3.3 Swinging Panel (Rear View)

- Houses switchgear door interlocks
- Door interlocks shown in door 'CLOSED' position
- Mounted on MTD (mounted on swinging panel) - SPEAR ONLY designation
- Contains vacuum contactor driver (see Ross Engineering DWG #713203)
- Panel reference: SD-1
# 4. Main Power Connections

## 4.1 Incoming 12.47KV Line

- Phases: OA, OB, OC
- Cable: #4-15KV rated
- Feed from 120VAC source for control circuits
- 600A, 13.8KV switch rating
## 4.2 Load Side Connections

- Surge arrestors: Connected to each phase on load side
- Fuses: Protection on load side
- Output to RF power supply transformer
## 4.3 Current Transformers

- CT ratio: 50/5
- CTs on each phase: X1, X2 secondaries
- X1a, X1b, X1c - Phase CT primaries
- X2a-P, X2e-P, X2-P - Phase CT secondaries with polarity markings
- CT secondary connections routed to protection relays via terminal blocks
- Current test block provided for maintenance testing
# 5. Terminal Block Wiring Details

## 5.1 TB3 - Main Switchgear Terminal Block

- TB3 serves as the main interconnection point in the switchgear
- Wire name column identifies each conductor
- Numbered terminals: 1 through 22+
- Connections to all relay panels, CTs, and external equipment
## 5.2 TB4 - Power/Auxiliary Terminal Block

- TB4 terminals: Numbered 1-20+
- TB4 carries CT secondary wiring
- Connections to protection relay panel
- MC contacts (MC3, MC4, MC5, MC7) for lockout relay and motor circuits
## 5.3 TB2 - Vacuum Contactor Terminal Block

- TB2 terminals on vacuum contactor unit
- Inter-wiring between TB2 and TB3
- Wire name identification for each conductor
## 5.4 TBD - External/RFPS Terminal Block

- TBD-1 through TBD-9: External connections to RF power supply
- TBD-7: Oil pressure relief / overtemp monitoring
- TBD-8: 86-L (BR) lockout relay external connection
- TBD-9: RF power supply transformer connection
- Connections to Ross Engineering DWG #713203
# 6. Protection and Control Panel Wiring

## 6.1 Relay Panel Connections

- 27 - Undervoltage relay
- TX - Tripping relay
- CR1 - Control relay 1
- N - Neutral connection
- OC, OB, OA - Phase designations
- EE (RR) - Remote reset relay connections
- CC - Control circuit identifiers
- BB2 - Bus bar/terminal connections
## 6.2 Door Interlock Circuit

- Switchgear door interlocks shown in 'CLOSED' position
- SD-1 designation for door interlock switches
- Multiple interlock contacts in series for safety
- Wired to control circuit via dedicated terminals
## 6.3 Control Switches and Indicators

- TRIP/RESET switch: Two-position control
- 86L - Lockout relay contact
- NOT READY / READY indicators
- OPEN / CLOSE position indicators
- K3 relay connections for current sensing
# 7. Vacuum Contactor Section

## 7.1 Contactor Wiring

- Vacuum contactor phases: C00, C31, C21, C11 (DC designations)
- Phase capacitors: C32, C22, C12
- Motor contacts: MC7, MC5, MC3, MC1 on each phase
- 4 sets of vacuum contactor poles shown (phases + spare)
- Each pole: Terminals 1-10 with MC connections
## 7.2 Driver Section (Front View on Swinging Panel)

- Driver for vacuum contactor: See Ross Engineering DWG #713203
- Mounted on swinging panel (SPEAR ONLY)
- Pressure switch connections
- Temperature sensor connections
- 86L contact connections (BB1, BB2)
- 125V DC power connection
- MC3, MC4 motor contactor connections
- Terminal block for external connections
## 7.3 Lockout Relay and Motor Contactors

- MC3: Motor contactor 3 - connected via TB3-10
- MC4: Motor contactor 4
- MC5: Motor contactor 5 - lockout relay
- MC7: Motor contactor 7 - lockout relay
- TB3-10, TB3-12 connections to lockout relay
- AMG (6 connections) on term block box
# 8. Wire Numbering and Routing

## 8.1 Wire Name System

- Wire names assigned in dedicated column on drawing
- Numbered wire system (1-22+) for main control wiring
- Alpha designations: CC, BB, EE, RR, SS for circuit functions
- Cross-reference between terminal blocks using wire numbers
## 8.2 Major Wire Runs

- TB3 to TB4: CT secondary and power connections
- TB3 to TB2: Control wiring to vacuum contactor
- TB3 to TBD: External connections to RFPS
- Swinging panel to fixed panel: Door interlock wiring
- CTs to relay panel: Current measurement wiring
# 9. Special Features

## 9.1 Space Heater

- Space heater installed in switchgear enclosure
- Connected via K4 relay
- Prevents condensation in outdoor enclosure
## 9.2 Cabinet Temperature Sensor

- Note: 'TO BE ADDED LATER' designation
- Planned sensor for monitoring cabinet temperature
- Connection points pre-wired
## 9.3 Oil Pump Transformer

- Oil pump transformer connected in circuit
- Associated with RFPS cooling system
- Connected through TBD terminal block
# 10. Notes from Drawing

- This drawing supersedes manual drawing ID-308-801-06 R0
- Reference: GP-439-704-02 PEP2, ELECT SYSTEMS, 12.47KV OUTDOOR SWGR & VAC CNTOR, SCHEMATIC DIAGRAM
- Driver for vacuum contactor: See Ross Engineering Co. DWG #713203
- Swinging panel designation: MTD ON SWINGING PANEL (SPEAR ONLY)
- Cabinet temperature sensor noted as 'TO BE ADDED LATER'
# 11. Operating Principles Summary

This connection wiring diagram documents the physical implementation of the 12.47 kV vacuum contactor controller system for SLAC's PEP-II accelerator. The drawing translates the circuit logic shown in the schematic diagram (GP-439-704-02) into actual wiring connections between three main equipment sections: the switchgear cabinet (with TB3 and TB4 terminal blocks), the vacuum contactor and its driver unit (with TB2 terminal block, mounted on a swinging panel), and the external RF power supply transformer (with TBD terminal block). The incoming 12.47 kV three-phase power enters through the rear compartment via #4-15KV cable, passes through current transformers (50/5 ratio) for protection relay measurement, and is switched by the vacuum contactor to the load. Protection is implemented through overcurrent relays (50-51) connected via a current test block, undervoltage relay (27), and a lockout relay system using motor contactors MC3/MC4/MC5/MC7. The vacuum contactor driver (Ross Engineering design) is mounted on a swinging panel for maintenance access and includes pressure switches, temperature monitoring, and 125VDC control power. Door interlocks ensure safe access to all compartments, with the energy storage capacitors automatically discharging when doors are opened. The 600A, 13.8KV rated switch provides the main disconnection capability for the system.

