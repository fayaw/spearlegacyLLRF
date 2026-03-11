Technical Note: 12.47 KV Outdoor Metal Enclosed
Combination Vacuum Contactor Controller
Schematic Diagram & General Arrangement


Source Document: gp3085000103.pdf
Document Type: Technical Note – Circuit Schematic Analysis
Purpose: Detailed extraction of design information from circuit schematic for AI-assisted design reconstruction


────────────────────────────────────────────────────────────


# 1. Document Identification

## 1.1 Title Block Information

- Title: 12.47 KV OUTDOOR METAL ENCL. COMB. VAC. CONTACTOR CONTROLLER
- Subtitle: SCHEMATIC DIAG. & GEN ARRG'MT (Schematic Diagram & General Arrangement)
- Drawing Number: GP-308-500-01-R3
- Prefix: GP, Base: 308, Suffix: 500-01, Revision: R3
- Organization: Lawrence Berkeley Laboratory (LBL)
- Project: Positron-Electron Project (PEP / PEP-II at SLAC)
- Drawn by: C. Johnson
- Checked by: L. Johnson
- Scale: Not to scale (general arrangement); dimensions in millimeters unless otherwise specified
- SLAC Release reference: V:\MDCAD\DocumentControl\images\Incoming\SLAC\PEP2 VCC1.dgn.tif
- Release date: 9/25/2006 12:04:54 PM
## 1.2 Revision History

- Rev A1: Changed capacitor connections in DC power supply, added terminal for HV time meter, identified VAC contactor aux contacts, located circuit breaker, revised VAC contactor internal wiring to suit
- Rev A2: Changed location of bus throat connection cut-out, current transformers, ammeters, added Detail 1, relays 27, MX, IR & RR
- Rev A3: Revised physical dimensions for switchgear/vacuum contactor, door-in-door arrangement (W/P)
# 2. Circuit Overview

This is a comprehensive schematic diagram and general arrangement drawing for a 12.47 kV outdoor metal-enclosed combination vacuum contactor controller system. It is part of the PEP-II (Positron-Electron Project II) at SLAC (Stanford Linear Accelerator Center) / Lawrence Berkeley Laboratory. The drawing covers the complete switchgear system including the vacuum contactor, variable voltage transformer, HV power supply, protection relays, current transformers, and the physical arrangement of all equipment within the metal enclosure. The system feeds RF power supplies via a loop feed configuration at 12.47 kV.

# 3. System Architecture

## 3.1 Power Distribution

- Input: 12.47 KV feeder for loop feed
- Cable: 3/C 350MCM EPR 220MILS insulation from area substation
- Feed configuration: Loop feed to next vacuum contactor controller
- Incoming feed: 3/C 350MCM underground conduit area
- Output feeds: To variable voltage transformer (VVT) and HV power supply (HVPS)
## 3.2 Major Equipment Sections (Physical Arrangement)

- Vacuum Contactor Compartment: Houses the 15kV 400A 3-pole vacuum contactor with heater
- Controller Section: Contains switchgear control circuitry
- Combination Power Section: Variable voltage rectifier transformer and power supply
- Bus Throat Connection: 4"C existing bus throat with throat flange (see Detail 1)
- Conduit to Building: Through building wall (by others)
## 3.3 Enclosure Specifications

- NEMAT enclosure rated: 48" × 140" MAX overall dimensions
- Configuration: Door-in-door arrangement (W/P = weatherproof)
- Base plan: Concrete pad 7' × 15'/A\
- Viewing window: Located on front panel with high voltage switch
- Gravity close mechanism on top section
- Vent: 43" with 45° opening cover (72" × 42")
- Wipe cover: 12" width, full-length BLE panels, removable
- Stress cone area adjacent to surge arrestor
# 4. Switchgear Control Schematic

## 4.1 Protection Relays

- 27 - Under Voltage Relay
- MX - Remote Control Relay, 24VDC
- IP - Interposing Relay, 24VDC
- RR - Remote Reset Relay, 24VDC
- 50-51 - Over Current Relay: 2-6A with 20-40A instantaneous attachment, Type CO-6 or equal
- 50-51N - Grounding Over Current Relay: 0.5-2.5A with 20-40A instantaneous attachment, Type CO-6 or equal
- TX - Aux Tripping Relay
- BR - Blocking Relay
- M - Main Operating and Holding Coils
## 4.2 Current Transformers

- CT ratio: 50/5 (on each phase A, B, C)
- Multiple sets of CTs for phase and neutral current measurement
- CT connections to 50-51A, 50-51B, 50-51C, and 50-51N relays
## 4.3 Control Circuit Details

- Control voltage source: 120VAC at RF panel (see panel schedule)
- Local control switch: Trip function (OL = local control switch-trip)
- Blocking relay (BR): Activated when fault current exceeds 2000 AMPS
- UZ - Blocking relay function
- Event counter for trip operations
## 4.4 Vacuum Contactor

- Rating: 15kV, 400A, 3-pole
- Type: HQ3 model (Ross Engineering)
- Heater: Typical installation on each compartment
- Surge arrester: Installed on incoming line side
- Operating mechanism: Stored energy closing with toggle mechanism
# 5. Terminal Block Assignments

## 5.1 TB1 (Main Terminal Block)

- TB1 terminals shown with numbered connections (1-20+)
- Carries control circuit wiring between switchgear sections
## 5.2 TB2 (Vacuum Contactor Terminal Block)

- TB2-1 through TB2-20+: Connections to vacuum contactor driver
- Includes connections for reset, VAC contactor, VVT, and HVPS
## 5.3 External Connections

- Input connections: L1, L2 (power), X1, X2, X3, X8 (control/aux)
- Current transformer secondaries: Connected to relay panel
- Cabinet/panel wiring: O/TEMP sensor, MX, BR relay connections
- Flexible bus by subcontractor (furnished by others)
- Installation by subcontractor for bus throat connections
# 6. Reference Drawings

- GP-308-500-03: Vacuum contactor control schematic and operation instruction
- ID-308-515-83: External wiring connections / connection diagram / layout
- ID-308-515-91: Block diagram
- ID-308-515-96: VVT & HVPS schematic diagram
- Ross Engineering DWG #713203: Vacuum contactor/driver circuitry
# 7. Physical Arrangement Notes

## 7.1 Front Elevation

- Viewing window on upper section
- High voltage switch accessible from front
- Surge arrestor location
- Bus throat connection (see Detail 1)
- Circuit breaker access
## 7.2 Side Elevation (Internal)

- Vacuum contactor compartment
- Fuse access panel
- Ground connection for protective barrier
- Provide gasket at rear barrier
- Over VAC contactor protective barrier
- Heater location below contactor
## 7.3 Rear Elevation

- Access to rear compartment
- Incoming 3/C 350MCM conduit area (underground)
- Loop feed configuration
## 7.4 Detail 1 - Throat Flange

- Bus throat connection detail (not to scale)
- Shows existing 4"C bus throat interface
- Flange mounting details for connection to building bus
- Receptacle: S/A receptacle with 32" bolt holes and 1/2" bolts
# 8. Legend and Symbols

- 27: Under voltage relay
- MX: Remote control relay - 24VDC
- IP: Interposing relay - 24VDC
- RR: Remote reset relay - 24VDC
- 50-51: Over current relay 2-6A with 20-40A instantaneous attachment, Type CO-6 or equal
- 50-51N: Grounding over current relay 0.5-2.5A with 20-40A instantaneous, Type CO-6 or equal
- OL: Local control switch - trip
- TX: Aux tripping relay
- BR: Blocking relay
- M: Main operating and holding coils
# 9. Operating Principles Summary

This 12.47 kV outdoor vacuum contactor controller system provides power switching for the PEP-II particle accelerator RF power supplies. The system receives 12.47 kV power through a loop feed configuration using 3/C 350MCM cable from the area substation. The vacuum contactor (15kV, 400A, 3-pole) serves as the main switching device, controlled by the Ross Engineering HQ3 driver unit which uses stored energy (capacitor-based) closing. Protection is provided by overcurrent relays (50-51) on all three phases plus neutral, an undervoltage relay (27), and a blocking relay (BR) that activates when fault current exceeds 2000A. The system includes local and remote control capability through MX (remote), TX (local trip), and OL (local control switch). Current transformers (CT 50/5) on each phase provide current measurement for protection and metering. The entire assembly is housed in a weatherproof NEMAT-rated metal enclosure mounted on a concrete pad, with door-in-door access and safety interlocks. The system feeds downstream to variable voltage transformers and HV power supplies that serve the accelerator RF systems.

