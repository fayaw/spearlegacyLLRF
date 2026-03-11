Technical Note: Ross Engineering Primary Energy Storage
LLRF/MODE System Schematic


Source Document: DOC041421-04142021114320.pdf / rossEngr713203.pdf (identical drawings)
Document Type: Technical Note – Circuit Schematic Analysis
Purpose: Detailed extraction of design information from circuit schematic for AI-assisted design reconstruction


────────────────────────────────────────────────────────────


# 1. Document Identification

## 1.1 Title Block Information

- Title: PRIMARY ENERGY STORAGE LLRF/MODE SYSTEM SCHEMATIC
- Drawing Number: 713203
- Company: Ross Engineering Corp.
- Address: 590 Westchester Dr., Campbell, CA 95008
- Part/Model Number: P/N B20360
- Associated Panel: HCA-1-A (HVPS Control Assembly)
- Date Received: APR 14, 2021
- Received By: AZ (initials)
- File Reference: Vault CFTATOR / BT BIOS
## 1.2 Revision History (Corrections and Additions Block)

- Rev A: Initial release (date: 3/5 approx.)
- Rev B: Customer Change (date: 1/5 approx.)
- Rev C: Added terminal numbers, equipment ratings (date: unknown)
- Rev D: See ECN #3110, dated 2/2-83 (Engineering Change Notice)
# 2. Circuit Overview

This schematic depicts a High-Voltage (HV) Energy Storage system used for closing a vacuum contactor. The circuit is designed by Ross Engineering Corp. and is a primary energy storage system for an LLRF/MODE (Low-Level RF/Mode) application. The system stores energy in capacitors and releases it to close a high-voltage vacuum contactor used in switchgear. The design includes control circuitry for open/close operations, safety interlocks, voltage sensing, and operational status indication.

# 3. Power Supply Section

## 3.1 AC Input

- AC Input Voltage: 115 VAC (from line)
- The AC input feeds the control power transformer and energy storage rectifier
- HV AC connection present for main vacuum contactor line contacts
## 3.2 DC Energy Storage

- Energy storage capacitors charged to approximately 300-800 VDC
- Discharge time to 80V is approximately 5 minutes (if not automatic)
- Discharge time to 40V is approximately 10 minutes (if not automatic)
- The DC holding coil operates from stored DC energy
- Voltage sensor monitors capacitor charge level
- Voltage sensor location: connected to +350 VDC rail
## 3.3 Transformer

- Control transformer: 35-180 VA rating
- Output: 120V secondary
- Powers control circuitry and charging circuit
# 4. Component List

## 4.1 Relays and Contactors

- MX - Remote Close Relay (main close command relay)
- K1 - Main operating relay
- K2 - Ready relay (indicates energy storage ready for closing)
- K3 - Current sensing relay (monitors holding coil current)
- R2 - Relay (Allen Bradley Size 1 contactor)
- R3 - Relay
- CR1 - Control relay
- CR2 - Control relay
- BR - Blocking relay
- TX - Local tripping relay / Aux tripping relay
## 4.2 Indicators and Counters

- READY IND. - Ready indicator (local)
- NOT READY IND. - Not ready indicator
- OPEN IND. - Open indicator light
- CLOSE IND. - Close indicator
- OPERATIONS COUNTER - Counts close operations (600V rated)
- MED COUNTER - Operations counter (metered)
## 4.3 Protection Components

- Fuses: 6 AMP, 800V rated
- Voltage Sensor: Connected to +350 VDC bus
- OT-100 (5A) - Overcurrent protection device
- INTLK - Interlock (25A rated)
- Door interlocks on energy storage driver
- Remote safety discharge interlocks
## 4.4 Coils and Solenoids

- HOLDING COIL (L1) - DC holding and dropout coil for vacuum contactor
- CLOSE COIL (L2) - Energy storage closing coil
- FAM - 8/ip AMP rated
- SLD BLO - Solenoid block
## 4.5 Motor/Drive Components

- Allen Bradley Size 1 contactor (R2 associated)
- Motor rated at 120V, 1/2 or 3 AMPS
- Operating at 300 VDC to 800+ VDC
# 5. Circuit Topology and Connections

## 5.1 Main Power Path

- AC line input → Line contacts (HV VAC) → Load
- The vacuum contactor controls the main HV power path
- Line contacts are NO (Normally Open) type
## 5.2 Control Circuit

- MX relay (remote close command) initiates closing sequence
- Current sensing relay K3 verifies holding coil current
- When K3 confirms current, and K2 (ready) is closed, K1 energizes
- K1 applies stored energy from capacitors to closing coil L2
- L2 solenoid closes toggle mechanism which closes HV contacts
- Holding coil L1 maintains contactor in closed position
## 5.3 Energy Storage and Charging

- AC power is rectified and charges energy storage capacitors
- Voltage sensor monitors charge level on +350 VDC bus
- When capacitors reach sufficient voltage, K2 (ready relay) closes
- Ready indicator illuminates to show system is ready to close
## 5.4 Opening Sequence

- MX opened (or TX local off, or interlocks open) starts opening
- DC current to L1 holding coil is interrupted
- L1 drops out within 1 cycle, dropping toggle base
- HV vacuum contactor opens and clears in ~1/2 to 1 cycle
- Toggle breaks and resets L1 and L2 for reclosing
# 6. Safety and Interlock Systems

## 6.1 Door Interlocks

- Safety door interlocks (S1, S2) shown with door closed position
- Both energy storage capacitors discharge within 5 seconds when door is opened
- Door interlock on energy storage driver unit automatically discharges capacitors
## 6.2 Remote Safety

- Remote safety circuit provides external discharge path
- Vacuum discharge interlocks present
- Cap dump circuit available for manual capacitor discharge
## 6.3 Blocking Relay (BR)

- If BR blocking relay closed by excessive fault, MX and TX local off are bypassed
- Contactor cannot open immediately if AC is lost while BR stays closed
- With loss of AC control voltage, contactor holds for at least 170 milliseconds
# 7. Terminal and Connector Details

## 7.1 Identified Terminals

- LOAD terminals for external connection
- LINE 1 input terminal
- HV AC connections
- Control voltage terminals (115 VAC, 120V)
- DC bus terminals (+350 VDC)
## 7.2 Interconnection Notes

- Suggested interconnections by user for field wiring
- Temperature sensor (TEMP) connection point
- Door lock connections (RO-R13)
- Cap dump connections
- Remote safety connections
# 8. Design Notes and Cautions

- CAUTION: This is a HV energy storage device operating at 300 to 800+ VDC
- Discharge time to 80V is approximately 5 minutes
- Discharge time to 40V is approximately 10 minutes if not automatic
- Before touching live parts, remove power and wait at least 5 minutes, then short both capacitors
- Close circuits should be wired with at least #14 wire
- If there is considerable distance between breaker, energy storage supply, or close relay, at least #12 wire should be used
- 115 VAC power requirement is 1/2 AMP continuous
- Safety door interlocks S1 and S2 shown with door closed; both energy storage capacitors are discharged within 5 seconds when door is opened
- Contactor should be de-energized in normal (default) position
- Remote safety: closed = driver door closed and de-energized
# 9. Operating Principles Summary

This circuit is a high-voltage energy storage closing system for a vacuum contactor. The system charges capacitors to approximately 350 VDC through a rectifier powered by the control transformer. When a close command is received (via MX relay), the system verifies that energy storage is adequate (via K2 ready relay) and that holding coil current is present (via K3 current sensing relay). Upon verification, stored energy is applied to the closing coil (L2), which mechanically closes the vacuum contactor's HV contacts through a toggle mechanism. The holding coil (L1) then maintains the contactor in the closed state using DC power. To open, the holding coil current is interrupted, causing the toggle to release and open the HV contacts within ~1 cycle. Multiple safety interlocks prevent unauthorized operation, and door interlocks automatically discharge the capacitors when the cabinet is opened. The blocking relay (BR) provides fault ride-through capability by preventing premature opening during excessive fault conditions.

