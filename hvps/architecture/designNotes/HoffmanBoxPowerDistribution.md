# HoffmanBoxPowerDistribution

> **Source:** `hvps/architecture/designNotes/HoffmanBoxPowerDistribution.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## Hoffman Box Power Distribution

## Introduction

As part of the SPEAR3 LLRF upgrade we are also upgrading the high voltage power supply (HVPS) controller.  This note documents the control power used in the current Hoffman box with the goal of seeing if any changes in this power supply configuration should be made in the upgrade.
## Power Supply Overview

We will refer to several documents in this note.  I will list those documents here in order to provide a central location for these references.

| SEDA Number | Description | PS Voltages | Source | Applications |
| --- | --- | --- | --- | --- |
| WD-730-790-02-C6 | Trigger Encl. Wiring | 120 VDC 1A | G5 | Gate pulse (H1) |
|  |  | 5 VDC | G5 | Pulse xfmr core bias |
|  |  | 240 VDC 0.25A | G5 | First gate pulse |
|  |  | 120 VDC 1A | F5 | Gate pulse (H2) |
|  | Sola 85-15-2120 | +/-15 VDC 0.2A | F8 | Analog monitors  Danisense 0.1A + 0.1A |
|  | 120VAC:24VAC, 25 VA xfmr | 24 VAC | F5 | Enerpro voltage (10W max) |
|  | LND-X-152 (2A) | 12/24 VDC | E5 | Emer Off Ctrl & Oil Flow Switches & 12 V Interlocks |
|  | AB-1747-P1 | 24 VDC | C5 | 1746-IV16 Slot 7, VDC |
| SD-730-793-03-04 | 12 kV SCR Driver Board | 240 VDC | P1-1 | First gate pulses |
|  |  | 120 VDC | P1-2 | Gate pulse amplitude |
|  |  | 5 VDC | P1-4 | Pulse xfmr core bias |
|  |  | 12 VDC | P2-1,3 | CMOS logic |
| SD-730-793-07 | Right Trigger Board | 12 VDC | P1-1 | CMOS logic |
| SD-730-793-08 | Left Trigger Board | 12 VDC | P1-1 | CMOS logic |
| SD-730-793-12 | Monitor Board | +/-15 VDC | P1G-F | Analog processing |
| SD-237-230-14-C0 | Regulator Card | +/-15 VDC | J4H-G | Analog regulator |
|  | Enerpro – MAD4030 |  |  |  |


## Trigger Enclosure Wiring

- Pulser power supplies are KEPKO-120V and KEPKO-240V PS, but headers give voltages as 100V and 200V.
- Headers for the Driver Boards have inverted pin numbers compared to those on the driver board schematics
- SOLA 85-15-2120 is a dual +/-15 VDC supply rated for 200 mA.
- This model appears to be obsolete.  Maybe we need to migrate to an Acopian, or other such supply.
- Ground tank TS-6 says this should be +/-12 VDC.  Should this be +/-15 VDC instead?
- Danfysik/Danisense, depending on the model, needs either 50 mA base current and 1/500 of the measurement current in one leg.  This is up to 100 mA, but closer to 50 mA for our normal operation.
- Klystron power supply monitor board shows +/-15 VDC.
- Are fuses in TS-1 (E5) oversized at 10 A?
- LND-X-152 is obsolete TDK/Lambda supply +/-12 or +/-15 VDC with 2 A output
- This supply is obsolete
- Don’t understand choice of supply
- +/-12 VDC configured to output +12 and +24 VDC
- There are two independent floating supplies.  The commons of these two supplies are tied together.  The -12 VDC is tied to the Hoffman box common.
- That means the PS “common” is at +12 VDC and the PS “+12 VDC” is at 24 VDC with respect to the Hoffman box common.
- This seems to place the current limit of the supply to the sum of the currents in both supplies, since the -12V output is the return for both configurations.
- Should this be replaced with one +12 and one +24 VDC supply?
- Don’t understand schematic
- TS-2 (4F) pin 1 shows 26V.  Should this be 24V?
- This feeds the 24 V to TS-8 4, which feeds 24 V to the Local Control Panel, including the Emergency Off and the Key Switch.
- TS-2, pins 2, 4, and 6 are common.
- Pin 6 is also connected to P1-4 on the power supply, labeled as -VDC.  Is this correct?
- TS-2 pin 3 does not seem to go anywhere.  Is this needed?  (This pin may be used to tie the output of the AB +12 VDC to the 24 VDC of Slot 7 AB 1746-IV16
- TS-2 pin 5 shows 12 VDC
- TS-2 pin 5 feeds TS-6 (E8), pins 5, 7, 9, 15, and 17.  Some of these lines go to the ground tank and others to oil level switches in the phase tank and the crowbar tank.  These are likely feeding 12 VDC interlock logic.
- TS-2 pin 5 also feeds pin 8 of Slot 5 1746-0X8 and output wire
- Wire is labeled +24 VDC Common (is this a mislabel for a 12 VDC signal?)
- Appears to feed P1-1 on trigger boards where it is a 12 VDC input to the Right and Left Trigger Boards
- Do not see fiber optic cable interconnects and connectors, such as to Left Side Trigger Interconnect Board
## 12 kV SCR Driver Board

- The labeling of P1 is inverted between this and the Trigger Enclosure Wiring Diagram.
- The +5 VDC input on P1-4 is listed as the Bias Supply on the Trigger Enclosure Wiring Diagram.
- This 5V was likely intended to be used to provide current to bias the core for extended volt second operation, but according to the schematic, this does not appear to be enabled.
- L1, L2, C16, and R23 are all listed as N/U.  Is this “Not Used”
- Perhaps saturation is not an issue with our current core size.
- These supplies are also not connected to the boards in either the HVPS1 or HVPS2 controllers.
- Minh is listed as the designer.  Should we contact him to get the history behind this external voltage?
- C18 is listed as rated for 200V.  This should be at least 240V.  We should correct this based on the installed capacitor.
## Right/Left Trigger Boards

- J1, J2, and J3 are not shown on the Trigger Enclosure Wiring diagram.  (Where is the third fiber optic connection to the LLRF?)
## Monitor Board

- +/-15 VDC comes in from P1G and P1F, listed on the Trigger Enclosure Wiring Diagram as TS-3 1-10 with pins 9 and 8.
- I do not see a mapping of the connectors P1 and J2 to the TS-3 on the Trigger Enclosure Wiring, so I am not sure that the +/-15 VDC are labeled on the correct pins of TS-3.  There may be wiring not shown that connects TS-3 to the connectors on the Monitor Board.
- The main amplifiers on the board are five each of the INA117 and four each of the BUF634.
- INA117 is a differential amplifier with quiescent current of 1.5 mA and maximum output current limit of 50 mA, but circuit set for much smaller output current.
- BUF634 is a high power driver with a quiescent current of 10 mA and a maximum output of 250 mA but we will set the current for a much lower value.
- The board uses the regulated output of the SOLA 15 VDC supplies as its input to a DC-DC converter system.  The 30 VDC is dropped by two 3.3 VDC 1N4728 zener diodes to create a voltage of 23.4 VDC.  It then uses two identical Murata NMH2415S DC-DC converters with isolated outputs.  These converters are rated for 2 W.  One converter provides power to most of the circuitry.  The other provides power to two INA117 differential amplifiers that supply the voltages to the remote voltage and current detection in B132.  This allows for significant differences in the grounds between B118 and B132, which is a good design choice.  The NMH2415S specify an output voltage ripple of 70 mV p-p typical and 150 mV p-p maximum.  This is not very good.  Traco makes a TIM 2 series medical grade DC-DC converter, TIM 2-2423, that has 50 mV p-p typical ripple.  The dip package NMH2415DC is scheduled to be discontinued, but the sip package, NMH2415SC, which is used is still available.
## Regulator Card

- The control power is provided through J4H (J4-8) and J4G (J4-7) by the 30 VDC output of the Enerpro.  This 30 VDC comes from the rectified output of the 120 VAC:24 VAC transformer that feeds the enerpro
- An onboard Astec 4.5 W MAD4030 DC-DC converter creates local analog +/-15 VDC voltages.
- This part is obsolete.
- Astec is now part of Artesyn
- It is not clear that Artesyn makes a pin for pin replacement for this converter
- The +5 VDC and +12 VDC references are inputs to the regulator card, but are used for signal levels and not power.
- The major potential current users on this chip are two each of the BUF634.  They can each output up to 250 mA, although they are currently not doing this.  If we want to drive a  line with 5 V, this would take 100 mA.  We will likely upgrade the BUF634 with a better, comparable chip, so we may want to budget up to 200 mA for driving the outputs.  The quiescent current for this device is around 10 mA.
- The short circuit currents are about 30 mA per opamp.  There are about seven signal processing opamps, so one could conservatively budget 210 mA for this, but most of these are likely designed to output no more than 5 mA due to the resistor networks that they are driving.  Therefore we may want to budget about 50 mA of 15 VDC for this board.
- Currently the supply is rated for 4.5 W, which is 150 mA for each of the two supplies.
