Technical Note: 12.47KV Outdoor Switchgear
Vacuum Contactor Electrical Schematic Diagram


Source Document: gp4397040201.pdf
Document Type: Technical Note – Circuit Schematic Analysis
Purpose: Detailed extraction of design information from circuit schematic for AI-assisted design reconstruction


────────────────────────────────────────────────────────────


# 1. Document Identification

## 1.1 Title Block Information

- Title: 12.47KV OUTDR SWGR, VAC CNTOR – ELECTRICAL SCHEMATIC DIAGRAM
- Drawing Number: GP-439-704-02-C1 (CAD redraw)
- Original Drawing: GP-439-704-02 R0 (manual drawing, superseded)
- Organization: Stanford Linear Accelerator Center (SLAC)
- Affiliated: U.S. Department of Energy / Stanford University, Stanford, California
- Project: Positron Electron Project 2 (PEP-II)
- Engineer: A.A. Cheng
- Approved by: William DQ (initials)
- Scale: None (not to scale)
- SLAC Release: V:\MDCAD\DocumentControl\Images\Incoming\SLAC\PEP2 VCC2.dgn.tif
- Release date: 9/25/2006 12:06:00 PM
- Proprietary: Data of Stanford University and/or U.S. Department of Energy
## 1.2 Revision History

- Original: Manual drawing GP-439-704-02 R0
- C1: Redrawn to CAD as shown and revised per as-built conditions (date: 09/25)
# 2. Circuit Overview

This is the detailed electrical schematic diagram for the 12.47 kV outdoor switchgear vacuum contactor system used in the PEP-II accelerator at SLAC. It provides the complete circuit logic for all control, protection, and power supply subsystems. The drawing is organized into functional blocks covering: overcurrent protection and ground trip, vacuum contactor open/close circuitry, energy storage closing, DC voltage sensing, internal HV and LV DC power supplies, and the interface to the RF power supply transformer. This is the most detailed schematic in the switchgear documentation set and is the primary reference for understanding circuit operation.

**System Architecture Diagram:**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   12.47 kV      │    │   SWITCHGEAR    │    │      HVPS       │
│   Utility       │────│   Vacuum        │────│   Transformer  │
│   Supply        │    │   Contactor     │    │   Primary       │
│   3-Phase       │    │   HQ3 15kV/400A │    │   Input         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                       ┌──────▼──────┐
                       │  Protection │
                       │   System    │
                       │ 50-51, 27   │
                       │ BR, Lockout │
                       └─────────────┘
```

**Power Flow and Control Hierarchy:**
```
Primary Power:    12.47kV ──▶ CT ──▶ HQ3 Contactor ──▶ HVPS Transformer

Control Power:    115VAC ──▶ Internal Supplies ──▶ 125VDC + 350VDC
                                    │
                                    ▼
Protection:       50-51 Relays ──▶ Control Logic ──▶ Trip/Close Commands
                  27 Relay
                  BR Relay

Energy Storage:   350VDC ──▶ 3500mF Capacitor ──▶ Closing Coil (214 Joules)
```

# 3. Functional Block Diagram (as shown on schematic)

## 3.1 Block Layout (Left to Right)

- OVER CURRENT / GROUND TRIP: Overcurrent protection with 50-51 relays
- OPEN CONT / VAC CONT TRIP CIRCUITRY: Opening/tripping logic
- VAC CONT 'OPEN/CLOSE' CIRCUITRY: Vacuum contactor control logic
- "CLOSE" IF READY INDICATOR CIRCUITRY: Ready-to-close verification
- DC VOLTAGE CIRCUITRY: DC bus voltage monitoring
- INDICATOR: Status indication circuits
- INTERNAL HV DC POWER SUPPLY: High-voltage DC supply for energy storage
- INTERNAL LV DC POWER SUPPLY: Low-voltage DC supply for control circuits
## 3.2 Additional Blocks

- UNDER VOLTAGE (BLOCK 1) CIRCUITRY: Undervoltage detection and protection
- FAST DROPOUT: Fast de-energization circuitry for rapid contactor opening
- NEUTRAL connection: System neutral reference
- VACUUM CONTACTOR/DRIVER CIRCUITRY: On switchgear control circuitry section
# 4. Detailed Component List

## 4.1 Relays and Control Devices

- MX - Remote close relay (main command relay for closing sequence)
- TX - Local tripping relay / Aux tripping relay (15, connected to TB1-17)
- K1 - Main operating relay (controls stored energy application)
- K2 - Ready relay (K2A, K2B contacts, indicates energy storage ready)
- K3 - Current sensing relay (monitors holding coil current, Telemecanique type)
- K4 - Control voltage interlock relay (HOT on TB1-1)
- CR1 - Control relay 1 (part of door interlock/cap dump circuit)
- CR2 - Control relay 2 (part of sensing/protection circuit)
- BR - Blocking relay (activated by excessive fault current >2000A)
- RR - Remote reset relay (3.2A rating)
- TD1 - Time delay relay (Telemecanique auxiliary time delay)
## 4.2 Overcurrent Protection

- 50A - Phase A overcurrent relay
- 50B - Phase B overcurrent relay
- 50C - Phase C overcurrent relay
- 50N - Neutral overcurrent relay
- 51A, 51B, 51C, 51N - Time-overcurrent elements (combined 50-51 function)
- CT200/5 - Current transformers, ratio 200:5, on each phase (H1/X1 connections)
## 4.3 Vacuum Contactor (Model HQ3)

- S1A, S1B - Interlock switches (mechanically sealed-in position sensors)
- S2 - Limit switch on contactor (TB2-S2, TB2-S2B - LIMIT indication)
- S3A - Indicating switch (TB2-S3A - INDIC)
- S3B - Indicating switch (TB2-S3B - INDIC)
- L1 - Holding coil/solenoid (DC holding, drops out within 1 cycle)
- L2 - Closing coil/solenoid (receives stored energy for closing, L2-22)
- P - Vacuum contactor terminal (TB2-5, TB3-18)
- Operating mechanism: Toggle-based with high closing force
## 4.4 Energy Storage and Power Supply Components

- C1 - Closing energy storage capacitor (3500mF, 25W charge resistor)
- C7 - DC bus filter capacitor (40,000mF, rated 40V)
- Charging resistor: 10M ohm, 25W (for C7 slow charge)
- Voltage sensor: Monitors +350 VDC on energy storage bus
- D1 - Diode (in K1/K2 circuit path for energy storage)
- 6/10A fuse - DC power supply protection
- 50f, 100W resistor - Power supply load/bleeder
- 330K, 250K resistors - Voltage divider for sensing
- 1W, 2W resistors - Associated with MX circuit
- R5 - Resistor in TB3 circuit
- 220 ohm, 50W resistor - Discharge/bleeder resistor for energy storage
- 10n capacitor (C1 area) - Snubber/filter capacitor
- 56K resistor - In MX/BB circuit
- BB1, BB2 - Terminal/bus bar connections
## 4.5 Indicators and Status

- NEON indicator - Ready status (neon lamp)
- READY indicator - Shows K2 relay status (energy storage sufficient)
- NOT READY indicator - Shows insufficient stored energy
- OPEN/CLOSE indicators via S3A/S3B switch positions
- Operations counter
## 4.6 External Equipment Interfaces

- RFPS TRANSFORMER: RF Power Supply Transformer connection
- MCO - Main contactor output (connected to TBD-3, TBD-4)
- 50/51 test block connections (A, B, C phases)
- F200 fuses (3x) - Protection fuses for RFPS circuit
- LOCKOUT RELAY - Connected to TB3-10, TB3-12 (MC5, MC7 contacts)
# 5. Terminal Block Assignments (Detailed)

## 5.1 TB1 - HCA Driver Box Terminal Block

- TB1-1: K4 (HOT) - Control voltage interlock
- TB1-2: Neutral / VAC CONT connection
- TB1-4: Vacuum contactor Zo connection
- TB1-6: Vacuum contactor connection
- TB1-7: 51A, 51B, 51C, 51N relay power (multiple connections)
- TB1-8: CR1/Door interlocks cap dump
- TB1-9: Closing energy circuit (3500mF capacitor, 25W)
- TB1-10: CR2/K1 circuit
- TB1-11: MX/Remote close relay connection (MTL contactor)
- TB1-12: K1 circuit
- TB1-15: Door interlocks cap dump (shown with door closed)
- TB1-17: TX/VAC CONT connection
- TB1-18: MX/GRE circuit
- TB1-19: CR2 connection
- TB1-20: Internal HV DC power supply
- TB1-21: CRI/30A fuse connection
## 5.2 TB2 - HQ3 Vacuum Contactor Terminal Block

- TB2-1: Fast dropout / DC holding / 6A-600V
- TB2-2: C7 capacitor (40,000mF) / R5 / TX circuit
- TB2-3: Local ready / NEON
- TB2-4: CR2/RR sensing circuit
- TB2-5: P terminal / vacuum contactor
- TB2-6: Voltage sensor connection
- TB2-9: S2 limit switch
- TB2-11: S2B limit switch
- TB2-12: Local reset / PB
- TB2-14: MTL contactor
- TB2-S2: Limit indication
- TB2-S2B: Limit indication
- TB2-S3A: Open/close indication (INDIC)
- TB2-S3B: Open/close indication (INDIC)
## 5.3 TB3 - Switchgear Terminal Block

- TB3-5: 27 relay (AG circuit)
- TB3-6: Closing energy relay (20G circuit)
- TB3-7: R5 circuit
- TB3-8: 10M/TBS circuit
- TB3-9: MX/GRE / TX circuit (10 wire name)
- TB3-10: BR/CR2 / lockout relay connection
- TB3-11: BR circuit
- TB3-12: 17 wire / lockout relay
- TB3-13: CC/FF circuit
- TB3-14: Internal LV DC power supply
- TB3-15: RR / K4 circuit (CC connection)
- TB3-16: BO / vacuum contactor
- TB3-17: Vacuum contactor
- TB3-18: P / vacuum contactor (DD)
- TB3-20: BB1 / K4 connection
- TB3-21: K1/CC1 / S1A / 6A-600V
- TB3-22: 56K / BB2 / MX connection
- TB3-24: CR2 / MTL connection
## 5.4 TB4 - Power/CT Terminal Block

- TB4-6: Phase connections (21B, 22) for incoming line CTs
## 5.5 TBD - RFPS/External Terminal Block

- TBD-1, TBD-2: External connections
- TBD-3: MCO connection
- TBD-4: MCO connection
- TBD-5: External (AM circuit)
- TBD-6: External connection
- TBD-7: Oil pressure relief / overtemp
- TBD-8: 86-L (BR) lockout relay external
- TBD-9: RF power supply transformer
- TBD-11: RF power supply transformer
# 6. Sequence of Operation (Verbatim from Drawing)

## 6.1 Energy Storage Closing – Vacuum Contactor/Driver Model #HQ3

The following sequence describes the complete closing and opening operation of the vacuum contactor system:

## 6.2 TO CLOSE

- 1. MX CLOSED TO START SEQUENCE OF CLOSING HV VACUUM CONTACTOR.
- 2. CURRENT SENSING RELAY TO CHECK VOLTAGE IN HOLDING COIL. CHECK K3 VOLTAGE IN CLOSING COIL.
- 3. WHEN FULL CURRENT IS REACHED IN HOLDING COIL, K3 CLOSES AND IF K2 READY RELAY IS CLOSED, WITH FULL ENERGY AVAILABLE AND HOLDING COIL IS MECHANICALLY SEALED-IN THUS ACTUATING INTERLOCK S1, K1 THEN CLOSES APPLYING STORED ENERGY TO CLOSING COIL L2. (BLOCK 1)
- 4. L2 SOLENOID THEN CLOSES TOGGLE WHICH CLOSES HV CONTACTS WITH HIGH CLOSING FORCE.

**Closing Sequence Timing Diagram:**
```
Time:     0ms    50ms   100ms  150ms  200ms  250ms  300ms
          │      │      │      │      │      │      │
MX Cmd:   ┌──────┴──────────────────────────────────────
          │
K3 Check: ──────┐      ┌─────────────────────────────────
                └──────┘

K2 Ready: ────────────────────────────────────────────── (Stays high)

K1 Apply: ──────────────┐      ┌─────────────────────────
                        └──────┘ (~100ms pulse)

L2 Close: ──────────────┐  ┌─┐  ┌─────────────────────────
                        └──┘ └──┘ (High force, then hold)

HV Ctcts: ────────────────────┐  ┌─────────────────────────
                              └──┘ (Closed position)

L1 Hold:  ──────────────────────┐ ┌─────────────────────
                                └─┘ (DC holding current)
```

## 6.3 TO OPEN

- 5. MX OPENED TO START UPON SEQUENCE OF VACUUM CONTACTOR (OR TX, LOCAL OFF, OR INTERLOCKS OPEN). (IF BR BLOCKING RELAY CLOSED BY EXCESSIVE FAULT, MX AND TX LOCAL OFF ARE BYPASSED AND CONTACTOR CANNOT OPEN IMMEDIATELY EVEN IF AC IS LOST AND AS LONG AS BR STAYS CLOSED UNTIL CG DECAYS. WITH LOSS OF AC CONTROL VOLTAGE, CONTACTOR WILL HOLD IN FOR AT LEAST 170 MILLISECONDS BEFORE DROPPING OUT).
- 6. WHEN DC CURRENT IS SHUTOFF TO L1 HOLDING COIL, L1 HOLDING SOLENOID DROPS OUT WITHIN 1 CYCLE DROPPING TOGGLE BASE AND OPENING HV VACUUM CONTACTOR WHICH THEN CLEARS IN APPROXIMATELY 1/2 TO 1 CYCLE. (HV CONTACTS NOMINALLY AT THE FIRST CURRENT ZERO AFTER CONTACTS PART).
- 7. AS SOON AS L1 DROPS OUT AND OPENS HV VACUUM CONTACTS TOGGLE BREAKS AND RESETS L1 AND L2. THIS THEN ALLOWS RECLOSING, AFTER ENERGY STORAGE CLOSING CAPACITOR IS RECHARGED IN A FEW SECONDS TO A LEVEL SENSED BY THE DRIVER VOLTAGE SENSOR WHICH THEN CLOSES K2 READY RELAY.
- 8. READY INDICATOR THEN INDICATES WHETHER VOLTAGE ON ENERGY STORAGE CLOSING CAPACITOR IS SUFFICIENT FOR POSITIVE CLOSING AND ALSO ALLOWS CLOSING SEQUENCE TO START IF MX AND REMAINDER OF CLOSING CIRCUIT IS CLOSED AT RESET. ANTIPUMP RELAY MAY BE NECESSARY, HOWEVER, RECHARGE TIME REDUCES PUMPING RATE. USING TX IN A RESET CIRCUIT SUFFICES FOR POSITIVE ANTIPUMP.
- 9. DOOR INTERLOCKS ON THE ENERGY STORAGE DRIVER UNIT AUTOMATICALLY DISCHARGE CAPACITORS WHEN DRIVER DOOR IS OPENED. EXTERNAL TERMINALS ARE ALSO PROVIDED TO TEST OR DISCHARGE CAPACITORS WITHOUT OPENING DOOR.

**Opening Sequence Timing Diagram:**
```
Time:     0ms    20ms   40ms   60ms   80ms   100ms  120ms
          │      │      │      │      │      │      │
MX Cmd:   ┌──────┐
          └──────┴──────────────────────────────────────

L1 Hold:  ┌──────┐      ┌─────────────────────────────────
          └──────┴──────┘ (Drops within 1 cycle)

HV Ctcts: ┌─────────────┐      ┌─────────────────────────
          └─────────────┴──────┘ (Opens at current zero)

Toggle:   ┌─────────────────────┐      ┌─────────────────
          └─────────────────────┴──────┘ (Resets mechanism)

Recharge: ──────────────────────────────┐ ┌─────────────
                                        └─┘ (Few seconds)

K2 Ready: ────────────────────────────────┐ ┌───────────
                                          └─┘ (Ready again)
```

**Fault Ride-Through (BR Blocking Relay Active):**
```
Fault Current > 2000A:
BR Relay:     ────┐                    ┌─────────────────
                  └────────────────────┘ (Min 170ms hold)

MX Command:   ┌───┐ ← Ignored while BR active
              └───┘

L1 Holding:   ──────────────────────────┐ ┌─────────────
                                        └─┘ (Held by BR)

HV Contacts:  ──────────────────────────┐ ┌─────────────
                                        └─┘ (Stays closed)

Fault Decay:  ████████████████████████████ ┌─────────────
              High Current               └─┘ Normal Level
```
## 6.4 CAUTION

AC MUST BE OFF BEFORE EXTERNAL DISCHARGE OF CAPACITORS IS DONE TO PREVENT BLOWING AC FUSES.

# 7. Protection System Details

## 7.1 Overcurrent Protection

- Phase overcurrent (50-51 A, B, C): CT ratio 200/5, connected via test block
- Neutral/ground overcurrent (50-51N): Separate neutral CT
- Blocking relay (BR): Activated when fault current exceeds 2000A; prevents contactor opening during fault
- Lockout relay: Connected to MC5, MC7 via TB3-10, TB3-12
## 7.2 Undervoltage Protection

- 27 relay: Undervoltage detection (Block 1 circuitry)
- Connected to AG circuit (TB3-5)
- Monitors incoming 12.47kV line voltage
## 7.3 DC Voltage Monitoring

- Voltage sensor on +350 VDC energy storage bus
- K2 ready relay indicates sufficient stored energy for closing
- 330K and 250K resistor divider for voltage sensing
- Fast dropout circuitry: 6A-600V rated for rapid de-energization
## 7.4 Fault Ride-Through (BR Blocking Relay)

- BR closes when fault current exceeds 2000 AMPS
- While BR is closed: MX and TX local off commands are bypassed
- Contactor maintains closed position even if AC is lost
- Contactor holds for at least 170 ms before dropout (loss of AC control voltage)
- Contactor opens only after CG (capacitor group) energy decays below holding level
# 8. Internal Power Supplies

## 8.1 Internal HV DC Power Supply

- Supplies +350 VDC for energy storage capacitors
- C1: Main energy storage capacitor (3500mF, charged through 25W resistor)
- Voltage output monitored by voltage sensor circuit
- Protected by 6/10A fuse
- Feed-through resistors: 50f, 100W for controlled charging
- Connected to TB1-20
## 8.2 Internal LV DC Power Supply

- Supplies low-voltage DC for control relay operation
- Connected to TB3-14
- H 125VDC power bus for switchgear control
- FU-A: 30A fuse protection
- Powers door interlock circuits, relay coils, and indicator lamps
## 8.3 Fast Dropout Circuit

- Provides rapid de-energization of holding coil
- 6A-600V rated components
- DC holding coil dropout within 1 cycle
- 600V rated energy dissipation
# 9. Wire Names and Circuit Identifiers

- Wire name assignments visible on drawing (column: WIRE NAME)
- Numbered wire identifiers: 15, 17, 21, 22, 23, 28, etc.
- Circuit identifiers: AG, BB, CC, CC1, DD, EE, FF, GG, HH, SS
- Terminal-to-terminal wire tracing documented via TB1/TB2/TB3/TB4/TBD cross-references
# 10. Notes from Drawing

- This drawing supersedes manual drawing GP-439-704-02 R0
- TB1: Terminal block on HCA driver box
- TB2: Terminal block on HQ3 vacuum contactor
- TB3: Terminal block on switchgear
- Reference: ID-308-801-06 PEP2, 12.47KV VAC CNTOR CONTROLLER, ELECTRICAL, CONN WIRING DIAG
# 11. Operating Principles Summary

This schematic represents the complete electrical control system for a 12.47 kV vacuum contactor used in the SLAC PEP-II accelerator's RF power distribution. The system operates on the stored-energy closing principle: a 3500mF capacitor bank is charged to approximately 350 VDC through an internal HV DC power supply. When a close command is initiated (MX relay), a sequence of checks verifies holding coil energization (K3 current sensing), adequate stored energy (K2 ready relay), and proper interlock status (S1). Upon verification, relay K1 connects the charged capacitor to closing coil L2, which actuates a toggle mechanism that closes the vacuum contactor's HV contacts with high force. The holding coil L1 then maintains the closed position using DC power from the internal supply. Opening requires interruption of the L1 holding coil current, which causes the toggle to release within approximately 1 power cycle. The system includes comprehensive protection: overcurrent relays (50-51) on all three phases and neutral with CT ratios of 200:5, undervoltage protection (27 relay), and a blocking relay (BR) that prevents premature opening during fault conditions exceeding 2000A. The 125VDC switchgear control bus provides power for the protection and control circuits, with safety interlocks on all access doors that automatically discharge energy storage capacitors when opened.
