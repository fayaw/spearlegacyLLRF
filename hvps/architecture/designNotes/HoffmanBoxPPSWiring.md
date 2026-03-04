# HoffmanBoxPPSWiring

> **Source:** `hvps/architecture/designNotes/HoffmanBoxPPSWiring.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## HVPS PPS Interlocks

## PPS Connections in the HVPS Controller

The wiring involved in the PPS system goes through several connectors and terminal strips in the HVPS controller (ref. WD-730-790-02-C6).
### PPS GOB12-88PNE

This was a Burndy circular 8 pin connector.  Is it now a Souriau Trim Trio part?  If so, what is the part number?  The connector likely comes from the locked PPS box installed securely on the HVPS controller.  The pin names, wire colors, functions, and terminations are listed in Table 1.

| Pin | Wire Color | Function | Termination |
| --- | --- | --- | --- |
| A | Red/Black | Contactor controls | TS-5 15 (PPS) |
| B | Red | Contactor controls | TS-5 14 |
|  |  | PPS1 Green LED Anode | AMP-8Pin  J2 1 |
| C | Orange | Ground Relay | TS-6 12 |
| D | Green/Black | Ground Relay | TS-6 11 |
|  | Blue | PPS2 Green LED Anode | AMP-8Pin  J2 3 |
| E | Green | Permits | TS-8 1 |
|  |  | PPS 1 | Slot 6  AB-1746-IB16  In 14 |
|  |  | PPS4 Red LED Anode | AMP-8Pin  J2 7 |
|  | White | Local Panel  Emergency Off | Key switch 1A |
| F | Black | Contactor controls  PPS common | TS-5 3 |
| G | Blue | Permits | TS-8 3 |
|  |  | PPS 2 | Slot 6  AB-1746-IB16  In 15 |
|  | White | PPS3 Red LED Anode | AMP-8Pin  J2 5 |
|  | Blue | PPS LED in Local Panel | PPS LED1 Anode |
| H | White | Permits common | TS-8 6 |
|  | Green | Contactor controls common | TS-5 1,8 |
|  |  | Control power supply, Grounding tank, etc., common | TS-2 2,4,6, TS-6 2, etc. |
|  | Red/Black | PPS1 Green LED Cathode | AMP-8Pin  J2 2 |
|  | White/Black | PPS3 Red LED Cathode | AMP-8Pin  J2 6 |
|  | Green/Black | PPS4 Red LED Cathode | AMP-8Pin  J2 8 |
|  | Black | PPS2 Green LED Cathode (TS-2 4) | AMP-8Pin  J2 4 |
|  | Green | Local Panel diode cathodes (except for On and Off) | Internal panel wiring |

Table 1:  Connection information from input PPS Burndy connector.
I assume, without proof (must check with Tracy) that the PPS 1 and 2 enables are sourced between pins E – F and G – H, respectively, and that the PPS looks for closed contacts between A – B and C – D.
### AMP 8Pin

There is an AMP 8 pin connector that connects to the four LEDs, two each green and two each red, that display the PPS status on the outside of the Hoffman box.
## Switchgear PPS

The PPS logic inside of the switchgear is documented on several drawings.  GP 439-704-02-C1 is a relatively old drawing with some information, but few details.  It shows the auxiliary contacts as being wires 20, 21, and 22 connected to TB3-22, TB3-23, and TB3-24.  It is not clear that this drawing is current.
rossEngr713203 is the internal Ross Engineering system schematic drawing from 1978.  It includes the drawing for the controller driver, P/N 820360, and the Vacuum Contactor, P/N 813203.  The interest of this drawing is that it contains the drawing for TB2 in the vacuum contactor and relays S1 – S5 in the vacuum contactor assembly.
GP 439-704-02-C1 and rossEngr713203 interface with the wiring diagram ID 308-801-06-C1.  On this wiring diagram, wires 20, 21, and 22 are terminated on terminals 18, 19, and 20 on TB2.  The NO contact is shown across terminals 18 and 19; the NC contact is shown across terminals 19 and 20.  These are all consistent with the labeling on rossEngr713203.  ID 308-801-06-C1 is difficult for me to interpret and may contain errors.  We may need to consult with an expert on this drawing to understand it correctly.
WD-730-790-01-C3 may be more current documentation.  It contains both TS-5 in the Hoffman Box, listed as Contactor Controls, and TB2 in the Contactor Disconnect panel in the HVPS.  The part of this wiring diagram relevant to just the interface between the Hoffman Box and the Contactor Disconnect is self-contained in WD-730-794-02-C0.  This latter diagram has more details about the function of the wires on TS-5, the Contactor Controls in the Hoffman Box.  From now on I will just refer to the latter document.

| TS-5 | Wire Color | Function | Termination |
| --- | --- | --- | --- |
| 1 | Green | Common | System common from AMP-8PIN, PPS Trim Trio, Local Control Panel, Transformer Interlocks, Control Power, Enerpro, Regulator Board, etc. |
| 2 | Red | Contactor On/Off | Slot 5  AB-1746-OX8-3  OUT 1 |
| 3 | Black | PPS Common | PPS GOB12-88PNE  F |
| 4 | Black | Contactor Enable | Slot 5  AB-1746-OX8-5  OUT 2 |
| 5 | N/C | Reset |  |
| 6 | N/C | ?? |  |
| 7 | Brown | Blocking | Slot 7  AB-1746-IV16-0  IN 0 |
| 8 | Green | Common | System common (tied to 1) |
| 9 | Red | Overcurrent | Slot 7  AB-1746-IV16-1  IN 1 |
| 10 | ?? | Contactor Open | TS-8 8  Local Panel LED Off cathode |
| 11 | Orange | Contactor Closed Contactor OK | Slot 7  AB-1746-IV16-2  IN 2 TS-8 7  Local Panel LED On cathode |
| 12 | N/C | ?? |  |
| 13 | Blue | Contactor Ready | Slot 7  AB-1746-IV16-3  IN 3 |
| 14 | Red | PPS | PPS GOB12-88PNE  B AMP-8Pin 1 PPS1 Green LED anode |
| 15 | Red/Black | ?? | PPS GOB12-88PNE  B |

Table 2:  Wiring documentation for Contactor Controls input in the Hoffman Box as shown on WD-730-790-02-C6
I include two tables for TS-5, the Contactor Controls terminal strip in the Hoffman Box.  Table 2 summarizes the documentation from the point of view of the Hoffmann Box and WD-730-790-02-C6.  It looks at the terminations, sources and/or destinations, of the signals from within the Hoffman Box.  It assumes that a trunk cable goes from TS-5 to the HVPS but gives no details of this trunk cable.
The second table, table 3, summarizes the wiring from the point of view of TB2 in the HVPS, using WD-730-794-02-C0.  We track the connection from TS-5 to TB2 by matching the wire colors in the wire bundle that connects the two strips.  We use as the function name in table 3 the names assigned to TS-5 in WD-730-794-02-C0, recognizing that those names are different from those listed in table 2, which are copied from the labels in WD-730-790-02-C6.

| TS-5 | Wire Color | TB2 | Function | Termination |
| --- | --- | --- | --- | --- |
| 1 | Green/White | CC1 | Common | MX On/Off relay coil |
| 2 | Red/Black | BB | On | MX On/Off relay coil |
| 3 | White | CC | PPS Common | RR (PPS) and K-4 (Reset) coil |
| 4 | Black | 11? | PPS Permit | K-4 (Reset) coil  (Drawing error?) |
| 5 | Red/White | EE | Reset | RR (PPS) coil  (Drawing error?) |
| 6 | Blue/White | 10 | Auxiliary Trip | Overcurrent Relay S2-3 NC (Drawing error?) |
| 7 | Blue/Black | 7 | Overcurrent NC | Blocking Relay S1-3 NC (Drawing error?) |
| 8 | Green/Black | 9 | Interlock Common | Common Contactor Ready S4-2, Contactor S3-2, Overcurrent S2-2, Blocking Relay S1-2 |
| 9 | Black/White | 8 | Overcurrent NO | Overcurrent S2-1 NO |
| 10 | White/Black | DD | Contactor Closed | Contactor S3-3 NC |
| 11 | Orange | W | Contactor Open | Contactor S3-1 NO |
| 12 | Orange/Black | 14 | Contactor Ready NO | Contactor Ready S4-1 NO |
| 13 | Blue | 16 | Contactor Ready NC | Contactor Ready S4-3 NC |
| 14 | Green | 22 | PPS Monitor Common | Contacts PPS S5-3 NC (Labeling error?) |
| 15 | Red | 21 | PPS Monitor | Contacts PPS S5-2 Common (Labeling error?) |

Table 3:  Wiring documentation for Contactor Interface inside of the HVPS as shown on WD-730-794-02-C0
## Switchgear Controller Theory of Operation and the Effect of the PPS System on it

There are some inconsistencies in the current documentation so, until we complete some field inspections, we are unsure of the exact interface between the PPS and the switchgear.  Based on the existing documentation I will investigate two possible interpretations of how the PPS system controls the switchgear.
### General Contactor Operation and Permits

I include here, for at least my own information, the basic theory of operation of the switchgear controller.  I use GP 439-704-02-C1 as the basis for this analysis.  The primary purpose of the schematic is to show the internal logic and workings of the controller.  In addition to the schematic the document also has text, very useful for troubleshooting, to describe the sequence of operation.  For our purposes, I am more interested in the general input/output operation of the controller and how it relates to external controls, including the effect of the PPS control on the contactor operation.  For this part, we are interested primarily in the far-left hand side and far-right hand side of the document.
The vacuum contactor control consists of two coils, one, L2, that requires a high-power input to initially close the contactor and another, lower power coil, L1, that holds the closed contactor in that position.  rossEngr713203 shows these coils and labels.  GP 439-704-02-C1 mislabels L1 as L2, identifying two different contactor coils with the same name.  In order to energize the high-power coil L2, K1 must be energized which requires, among other conditions, that the auxiliary external control contactor MX be energized.  In order to energize the holding coil L1, MX must continue to be energized and the auxiliary tripping relay, TX, must be de-energized.
The logic for the TX relay is seen on the left-hand side of the schematic.  The main inputs are from the four MCO protection relays, one for each phase and one for neutral, that will trip, and close their interlock contact, on either an instantaneous overcurrent fault (50) or a time overcurrent fault (51).  The function of the TX relay is to summarize these various faults and remove the permit from the hold-in coil.  The TX coil has another input chain.  This chain consists of the RR relay NC contact, the TX NO contact and a manual reset switch.  If the TX coil is energized and the RR coil is not energized, the TX coil latches.  It will only clear if all the MCO relays have no faults, and either the RR coil is energized, or the local reset switch is depressed.
K4 is another relay that controls operation of the contactor.  (For this discussion I rely on GP 439-704-02-C1 and assume, without justification, that this diagram is correct.  I will point out differences between this diagram and others when I find them.)  K4 has two NO contacts.  One interrupts the control voltage downstream of the MCO protective relays.  Removal of this voltage removes the voltages that energize the time delay relay block as well as relays K1, K2, and eventually K3.  All these relays, except for K3, should open quickly.  K3, which is energized by the voltage on a large storage capacitor may take some time to open.  However, on the 24V DC controls section of this schematic we see that a second K4 NO contact is inserted between wire name BB and one side of the MX coil.  (An NC contact from an 86-lockout relay is also in series with this MX coil.)  Neither of these contacts is shown in WD-730-794-02-C0.  Another potential error on this drawing is the labeling of the functions of the RR and K4 relays.  The drawing labels RR as the PPS relay and K4 as the RESET relay.  These labels may be swapped from the actual functions of these relays.  A NO contact of the MX coil is in series with the L1 coil that holds the contactor in place after it has closed.  De-energizing K4 in turn de-energizes MX which opens the contactor.
### Assumption that RR Coil is the PPS Control

The RR coil is energized via a signal from the Contactor Enabled line, Output 2 on pin 5 of the 1746-0X8 in Slot 5.  However, I do not see how the RR coil either prevents the vacuum contactor from turning on or removes the permit from the contactor once it is on.  It seems its sole function is to prevent the TX relay from latching on an MCO overcurrent fault.  The RR relay seems to act as a reset of the TX relay after it has latched.
### Assumption that K4 Coil is the PPS Control

The K4 relay controls, through the MX relay, the hold-in current for the L1 coil of the contactor.  K4 also removes all control power to the contactor controller.  This will cause the stored energy in the contactor controller to dissipate.  The controller will take some time after K4 is re-energized to build up sufficient voltage in C6 to re-energize K3 and place the controller in a “ready” state so that the contactor can be re-closed.  This explains why it takes several seconds to re-close the contactor after it has been opened by removing the PPS enable.
### Conclusion

In summary, it appears that the labeling of the RR and K4 relays on WD-730-794-02-C0 is in error; the two labels should be swapped.  The RR relay can act as a reset, but K4 is the relay that is used to open the contactor and disable the controller on a PPS fault.  Also, the K4 NO and 86 NC contacts should be placed between the BB input and the MX coil on that wiring diagram.  Based on the documentation in WD-730-790-00-C6, the signal to the K4 relay on WD-730-794-02-C0 is sourced from an output of the PLC and not directly from the external PPS signals.
The readback for the signals labeled PPS monitor on WD-730-794-02-C0 are connected to the auxiliary contact S5 on the vacuum contactor.
## Grounding Tank PPS

We use the wiring diagrams of the Hoffman Box, WD-730-790-02-C6, and the Grounding Tank, WD-790-794-06-C0, and the schematic diagram of the Grounding Tank, SD-730-790-05-C1, to document the PPS wiring to the Grounding Tank.
Tables 4 and 5 summarize the details of the wiring connections from the Hoffman Box through to the final terminations in the Grounding Tank.

| TS-6 | Wire Color | Function | Termination |
| --- | --- | --- | --- |
| 1 | Red; White | DC Current | Slot-9 AB-1746-NI4 9  In3+;  Voltage Monitor TS-3 10 |
| 2 | Black;  Green? | DC Common | Slot-9 AB-1746-NI4 10  In3-;  SOLA PS-6 P1-2 Common;  Control Power Supply TS-2  2, and others |
| 3 | Green?; Blue | -12 V (-15 V?) | Voltage Monitor TS-3  8;  SOLA PS-6 P1-3  -V DC |
| 4 | Red | 12 V (15 V?) | Voltage Monitor TS-3  9;  SOLA PS-6 P1-1 +V DC |
| 5 | Red | Status + | Control Power Supply TS-2  5, and others |
| 6 | NC | Status – Transductor |  |
| 7 | Red | +12 V | TS-6 5, 7, 9, 15, 17 and others |
| 8 | Red | Ground Tank Oil | Slot-6 AB-1746-IB16  IN8  8 |
| 9 | Red | +12 V | TS-6 5, 7, 9, 15, 17 and others |
| 10 | Gray | Ground Switch NC | Slot-6 AB-1746-IB16  IN9  9 |
| 11 | Green/Black; Blue | Ground Relay NC | PPS GOB12-88PNE  D;  AMP-8Pin 3 |
| 12 | Orange | Ground Relay NC | PPS GOB12-88PNE  C |
| 13 | Black | Ground Relay Coil | Slot-2 AB-1746-IO8  OUT3  5 |
| 14 | White | Ground Relay Coil | Slot-2 AB-1746-IO8  AC Common  10 |
| 15 | Red | +12 V | TS-6 5, 7, 9, 15, 17 and others |
| 16 | Violet | Crowbar Tank Oil | Slot-6 AB-1746-IB16  IN10  10 |
| 17 | Red | +12 V | TS-6 5, 7, 9, 15, 17 and others |
| 18 | Yellow | SCR Tank Oil | Slot-6 AB-1746-IB16  IN11  11 |
| 19 | Black | Ground Relay NO | Transformer Interlocks TS-4 3, Slot-7 AB-1746-IV16  IN13  13 |
| 20 | BNC signal | Shunt + | BNC-12 signal |
| 21 | BNC shield | Shunt Common | BNC-12 shield |

Table 4:  Wiring to TS-6 in the Hoffman Box.

| TS-6 | Wire Color | LEV-3; P5(J1?); J2 | Function | Termination |
| --- | --- | --- | --- | --- |
| 1 | Black | J2-6 | DC Current Output | Danfysik Output |
| 2 | Green | J2-4 | DC Common | Danfysik Ground |
| 3 | Blue | J2-5 | -15 V | Danfysik -15 VDC |
| 4 | Red | J2-9 | 15 V | Danfysik +15 VDC |
| 5 | White | J2-8 | Status + | Danfysik Status + |
| 6 | NC | J2-3 | Status – Transductor | Danfysik Status - |
| 7 | ? | LEV-3 1 | +12 V | Oil Level NC Dry Contact |
| 8 | ? | LEV-3 2 | Ground Tank Oil | Oil Level NC Dry Contact |
| 9 | Black | P5-C | +12 V (NO?) | Manual Ground Switch Aux NC |
| 10 | White/Black | P5-D | Manual Ground Switch Common | Manual Ground Switch Aux Common |
| 11 | Orange | P5-J | Ground Relay NC | Ross Ground Relay Aux Common |
| 12 | Red/Black | P5-H | Ground Relay NC | Ross Ground Relay Aux NC |
| 13 | Blue | P5-F | Ground Relay Coil | Ross Ground Relay Coil |
| 14 | Green | P5-E | Ground Relay Coil | Ross Ground Relay Coil |
| 15 | NC |  | +12 V | TS-6 5, 7, 9, 15, 17 and others |
| 16 | NC |  | Crowbar Tank Oil | Slot-6 AB-1746-IB16  IN10  10 |
| 17 | NC |  | +12 V | TS-6 5, 7, 9, 15, 17 and others |
| 18 | NC |  | SCR Tank Oil | Slot-6 AB-1746-IB16  IN11  11 |
| 19 | Green/Black | P5-I | Ground Relay NO | Ross Ground Relay Aux NO |
| 20 | Red | P5-A | Shunt + | 15 A/50 mV Shunt + |
| 21 | White | P5-B | Shunt Common | 15 A/50 mV Shunt Common |

Table 5:  Wiring from TS-6 in the Hoffman Box to the Grounding Tank connections.
TS-6 in the Hoffman Box carries the wiring to the Grounding Tank.  This wiring is distributed to three different connectors in the Grounding Tank, each corresponding to different equipment.  Terminals 1 – 6 carry the signals to the Danfysik UltraStab DC current transducer used to measure the HVPS output current to the klystron.  This connector is labeled J2 on WD-730-794-06-C0.  The Danfysik has an internal DB9 connector to which these wires are connected.  It requires external  supplies.  (The wiring diagram for the Hoffman Box has inconsistent values for these supplies.)  These voltages are supplied by a SOLA supply that also provides analog voltages for the Monitor Board, SD-730-793-12.  (It does not, but it could, also provide power to the Regulator Card, SD-237-230-14-C0.)    The Danfysik analog output is between terminals 1 – 2 on TS-6.  This voltage is connected to both the analog Input 3 of the Slot-9 AB-1746-NI4 module and the current input of the PS Monitor Board.
Terminals 7 – 8 connect to the NC dry contact of an oil level sensor in the Grounding Tank.  The Hoffman Box sources 12 VDC to terminal 7 and terminal 8 is monitored by Input 8 of the Slot-6 AB-1746-IB16 module.
Terminals 9 – 14 and 19 – 21 are connected to some of the pins of the connector labeled P5 on WD-730-794-06-C0 and labeled J1 on SD-730-790-05-C1.  Terminals 20 – 21 are on opposite sides of a 	 current-measuring shunt; terminal 21 is referenced to the earth of the Grounding Tank.  The voltage drop across these two pins measures the current in the HVPS return cable. 
The connections to terminals 9 – 14 and 19 provide control to a Ross Grounding Switch and monitor the status of the two, manual and electrical, grounding switches in the Grounding Tank.
Terminals 9 and 10 monitor the status of the manual grounding (“mushroom”) switch via its auxiliary dry contacts.  The Hoffman Box sources 12 VDC control voltage to the NC contact and the voltage on the common terminal is sensed by the Slot-6 AB-1746-IB16 module on its IN9, pin 9.  (The documentation on this dry contact is inconsistent.  WD-730-794-06-C0 shows this as NO; SD-730-790-05-C1 shows this as NC.  We need to determine the correct value.)
Terminals 13 and 14 energize the coil of the Ross switch.  This is driven by the voltage across Slot-2 AB-1746-IO8 Output 3 to AC Common.  (We should document the specification for the Ross Grounding Switch coil.)  The Ross switch has an auxiliary contact with common, NO, and NC connections on terminals 11, 12, and 19, respectively.
WD-730-794-06-C0 and SD-730-790-05-C1 also document a coaxial cable that is sourced by a  Pearson CT 110 wide bandwidth current transformer.  This cable is used to monitor the HVPS output cable for transients that signify klystron arcs and initiate a crowbar trigger when it senses a large enough transient.  It is not part of the PPS connection.  Rather it feeds J1 of the Left Side Trigger Interconnect Board, SD-730-793-08-C1.
Finally, there are four terminals on TS-6, 15 – 18, that monitor the oil levels in the SCR phase tank and crowbar tank.  The connections to the control voltage and PLC inputs in the Hoffman box are documented on WD-730-790-02-C6.  The connections to the NC dry contacts in the appropriate HVPS tanks are shown on WD-730-790-01-C3.
## PLC Code for the PPS

The HVPS controller has an intelligent SLC-500 based programmable logic controller (PLC).  This PLC currently is part of the PPS logic.  The external PPS interface chassis inputs PPS 1 and PPS 2 control signals to the PLC via the Slot-6 AB-1746-IB16 Inputs 14 and 15, respectively.  The relevant PLC outputs are Slot 5  AB-1746-OX8-5  OUT 2 to energize the coil of the K4 relay in the HVPS (Contactor Enable) and Slot-2 AB-1746-IO8  OUT3  5 to energize the coil of the Ross Grounding Switch.
### PPS 1 Input

PPS 1 input is read into Slot-6 AB-1746-IB16 Input 14.  In the PLC code this appears in rungs
- 0014  To set emergency off bits
- 0015  In parallel with PPS 2 input to set B3:1 for PPS ON
- 0016  In series with PPS 2 (and others) to energize the Ross Ground Switch Relay Coil
### PPS 2 Input

PPS 2 input is read into Slot-6 AB-1746-IB16 Input 15.  In the PLC code this appears in rungs
- 0015  In parallel with PPS 1 input to set B3:1 for PPS ON
- 0016  In series with PPS 1 (and others) to energize the Ross Ground Switch Relay Coil
- 0068  In series with touch panel key enable to enable the Bias Power (120 VAC to Kepko power supplies)
### Contactor Enable

The output of Slot 5  AB-1746-OX8-5  OUT 2 energizes the coil of the K4 relay in the HVPS.  It appears in rungs
- 0002  In series with master ready to Close Contactor O:5 1  (Is this Contactor On/Off or Contactor Enable?)
- 0017  In series with Touch Panel Enable and Emergency Off Clear, 1746-OX8 2 is called Crowbar On.  Is this really Contactor Enable that energizes the coil of the K4 relay?
I think, but am not sure, that I understand how the coil of the K4 relay is energized and how the contactor is closed.  I think that rung 0017 is mis-labeled and that it really controls Contactor Enable.  This, in turn, energizes the coil of the K4 relay (I also assume other wiring diagrams have labeling errors).  After the K4 relay has been energized, the MX relay can be energized, which enables the HV vacuum contactor controller to close the vacuum contactor.
Energizing the K4 relay is done using an AB-1746-OX8, which operates relay contacts.  The input of this pair of contacts is the PPS 1 signal that is sourced from the PPS GOB12-88PNE connector.  Therefore, even if the PLC fails, this signal fails safe.  If the PPS GOB12-88PNE connector does not source the 24 VDC control voltage a closed contact on the AB-1746-OX8 cannot energize the K4 relay coil.
### Energize Ross Grounding Switch

The output of Slot-2 AB-1746-IO8 OUT3  5 energizes the coil of the Ross Grounding Switch.  It appears in rungs
- 0016  If both PPS 1 and PPS 2 are enabled, energize the coil of the Ross Ground Switch Relay.
A possible fault scenario is that the PLC fails and sources the 120 VAC signal to the coil of the Ross Ground Switch Relay with no command given by the PPS system.
## PPS Readbacks

As stated above, I assume that the external PPS interface chassis is looking for closed contacts between pins A – B and pins C – D of the GOB12-88PNE connector.
### A – B Pins

Pin A connects to TS-5 15, which connects to the common of auxiliary contacts S5 on the HV vacuum contactor (ref. WD-730-794-02-C0).  Pin B connects to TS-5 14, which connects to the NC contact of the S5 auxiliary contacts.  When the HV vacuum contactor is open, the external PPS interface chassis will see a closed circuit and when the HV vacuum contactor closes, the external PPS interface chassis will see an open circuit.
### C – D Pins

Pin C connects to TS-6 12, which connects to the NC contact of the auxiliary contacts of the Ross Grounding Switch (ref. SD-730-790-05-C1).  Pin D connects to TS-6 11, which connects to the common of the auxiliary contacts.  When the Ross Grounding Switch is in its normal, closed, position, the auxiliary contacts are also closed, and the external PPS interface chassis will see a closed circuit.  When the switch is energized to allow power to reach the klystron, the external PPS interface chassis will see an open circuit.
### Monitoring of PPS Readbacks

There are local LEDs on a PPS box on top of the Hoffman box that monitor the condition of the signals sent from and to the PPS interface chassis.  There is no such monitoring in the PLC chassis.
## Existing Hand Drawing

Figure 1 is an existing sketch of some relevant PPS connections in the HVPS.  Much of it is correct but, based on my reading of the schematics and wiring diagrams, I think that there are some trivial errors in the sketch.  Pin A should connect to TS-5 15 and B to TS-5 14, not TS-4 14 and TS-4 15.


Figure 1:  Sketch of PPS interface
## Field Inspection of HVPS Contactor Controller

In order to resolve some open questions concerning the wiring and documentation of the PPS connections to the HVPS contactor controller, high voltage electricians Edwin Viray and Constantin Brotoiu and I opened up several sections of the HVPS contactor controller and traced wiring.  We did not use a multimeter to verify connections but rather relied on the labeling of the wires in the controller.  We verified this wiring to the terminals of all of the relevant relays.  The only exception to this statement is that we did not open up the cover on the Ross Engineering vacuum contactor assembly, shown as part number 813203 in Ross Engineering drawing number 713203 E-1.  We verified the connections to TB2 and then verified the wire labels on the wires leading from TB2 to the inside of the contactor assembly.
Note that the Ross Engineering schematic labeling of contacts is unconventional.  Near the drawings of the contacts, those shown as two parallel lines are labeled NC (normally closed) and contacts shown as two parallel lines with a diagonal line through the two are labeled NO (normally open).  This notation disagrees with normal contact notation.  However, when wires from those contacts are extended to TB2, the labeling on TB2 conforms to normal contact notation.
### TB3

Terminal block 3 is located in an enclosure on the outside of the HVPS switchgear.  The enclosure consists of TB3 and another identical terminal block.  Connections from outside of the HVPS connect to wires on TB3.  Those wires are then connected to the second TB.  Wires leading to the controller are connected to the second TB.  The wire labels are identical on the two terminal blocks.
TB3 has 34 terminals.  Not all are connected and/or labeled.  Table 6 details this terminal block.

| Position | Function | Source | Wire Color | Wire Name | Dest. | Comment |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Phase B | 208 VAC | Blue | X1 | K4-1 | 120 VAC to TB1-1 |
| 2 | Neutral |  | White | N |  | Tie to 4 |
| 3 | Phase C | 208 VAC | Red | X |  |  |
| 4 | Neutral |  | White | Y |  | Tie to 2,6 |
| 5 | Phase A | 208 VAC | Black | MI17 | K4-7,9 | Oil pump AC |
| 6 | Neutral |  | White | MI16 | Pump Com | Tie to 4 |
| 7 | Contactor On | TS5-2 | Red/BlkS | BB | K4-3 | Enable MX |
| 8 | PPS Ctrl Com | TS5-3 | White | CC | K4, RR Com |  |
| 9 | Reset | TS5-5 | Red/WhiS | EE | RR Coil |  |
| 10 |  |  | - | - |  |  |
| 11 |  |  | - | 5 |  |  |
| 12 | Intrlk Com |  | Green/BlkS | 6 |  | Tie to 15 |
| 13 | OverCurr NC | TS5-7 | Blue/BlkS | 7 | ? | Cannot find 7 |
| 14 | OverCurr NO | TS5-9 | Black/WhiS | 8 | TX-13 | Mixed with 16? |
| 15 | Intrlk Com |  | Green/BlkS | 9 | TX-3,9 | Tie to 12,21 |
| 16 | Aux Trip | TS5-6 | Blue/WhiS | 10 | TX-7 | Mixed with 14? |
| 17 |  |  | - | AA |  |  |
| 18 | Cont Open | TS5-11 | Orange | W | MX-1 |  |
| 19 | Cont Closed | TS5-10 | White/BlkS | DD | TB2-17 | Cont Aux NC |
| 20 | Cont Ready NO | TS5-12 | Orange/BlkS | 14 | 27-4 | 27 NO |
| 21 | Intrlk Com |  | Green/BlkS | 15 | 27-3 | Tie to 15,26 |
| 22 | Cont Ready NC | TS5-13 | Blue | 16 | 27-5 | 27 NC |
| 23 |  |  | - | 17 |  |  |
| 24 |  |  | - | 18 |  |  |
| 25 |  |  | - | 19 |  |  |
| 26 | Intrlk Com | TS5-8 | Green/BlkS | NN |  | Tie to 21 |
| 27 |  |  | - | W1 |  |  |
| 28 | Cont On Com | TS5-1 | Green/WhiS | CC1 | MX Com |  |
| 29 | PPS Permit On | TS5-4 | Black | II | K4 Coil |  |
| 30 |  |  | - | 20 |  |  |
| 31 | PPS Monitor | TS5-15 | Red | 21 | TB2-19 | Aux S5 Com |
| 32 | PPS Mon Com | TS5-14 | Green | 22 | TB2-20 | Aux S5 NC |
| 33 |  |  | - | 23 |  |  |
| 34 |  |  | - | 24 |  |  |

Table 6:  TB3 in HVPS Controller
Note that the numbering of the TB3 terminals verified in HVPS2 differs from that given in ID 308-801-06-C1.
### K4 Relay Operation

The K4 relay is the relay used by the PPS system to permit the contactor to close.  It is located in the rear of the swinging door panel.  It is energized by sourcing 24 VDC on the PPS Permit line that connects to wire II in the controller.  CC is the PPS Common.  K4 controls four sets of NO contacts.  Phase C connects to K4-1.  When K4 is energized, it provides 120 VAC control power to TB1-1, via the wire labeled 0X.  Two pairs of K4 contacts, K4-7 to K4-8 and K4-9 to K4-10 power the M1 oil pump, using Phase A.  The fourth pair of contacts, K4-3 to K4-4, carries the 24 VDC “ON” control from BB to BB1.  This line then passes through the NC contacts of the lockout relay, 86L-11 to 86L-13, to further carry the voltage from BB1 to BB2.
#### Documentation Errors

- Two labels on WD 730-794-02-C0 are incorrect.  The RR relay should be labeled RESET and the K4 relay should be labeled PPS.
- The connection to the MX relay should not be just BB and CC1.  The connection should be BB to BB1 through K4 and BB1 to BB2 through the 86L lockout relay.
#### Other Errors

- We should verify that K4 is rated to share the M1 current between its two sets of contacts.
### MX Relay Operation

The purpose of the MX relay is to energize and close the vacuum contactor.  It is located in the rear of the swinging door panel above the K4 relay.  It is energized when K4 is energized, the 86L relay is clear, and the “ON” control is given by the HVPS controller.  The MX relay controls four sets of NO contacts, only three of which are wired.  MX-1 to MX-2 connects Contactor Open to TB2-15 in the Ross Engineering vacuum contactor controller.  This is the NO contact of the S4 auxiliary contact on the vacuum contactor.  MX-7 to MX-8 provides a path from the rectified low voltage controller source through the normally closed TX contacts TX-4 and TX-6 to the L1 holding coil of the vacuum contactor.  MX-9 to MX-10 connects TB2-3 and TB2-11 in the vacuum contactor controller.  This connects the NC contact of the S2 auxiliary contact to the common of the NC S1B auxiliary contact.  I am not very sure of this function, but it may be what removes the power from the high voltage “close” circuitry required to close the contactor and lets the low voltage “hold” circuitry keep the contactor closed.
#### Documentation Errors

- Wire W1 is not connected to anything.  In particular it does not connect to the MX coil.  Wire and label B2 on ID 308-801-06-C1 and label 3 should be removed.
- WD 730-794-02-C0 labels Contactor Open as coming from the S3 auxiliary contact of the vacuum contactor.

> **Note:** This document contains embedded images that cannot be directly converted to text.
> Please refer to the original DOCX file for visual content.
