# B514 SP2 HVPS SR-444-636-07 R1 (part 1) - signed

> **Source:** `hvps/documentation/procedures/B514 SP2 HVPS SR-444-636-07 R1 (part 1) - signed.pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 20


---
## Page 1

SPEAR3 RF SPEAR2 Equipment-Specific
Lockout Procedure (ELP)
SR-444-636-07-R1
1 TABLE OF CONTENTS
2 Revision History .................................................................................................................................... 2
2.1 R1 March 27, 2024 ........................................................................................................................ 2
3 Table of Figures ..................................................................................................................................... 2
4 Author/Approvers/Validators ............................................................................................................... 3
4.1 Author ........................................................................................................................................... 3
4.2 Reviewers ...................................................................................................................................... 3
4.3 Management Approval ................................................................................................................. 3
4.4 Validator ........................................................................................................................................ 3
5 Procedure Purpose................................................................................................................................ 3
6 Equipment Required to Execute Procedure ......................................................................................... 4
7 Equipment Description ......................................................................................................................... 4
8 Potential Hazards .................................................................................................................................. 6
8.1 Electrical Sources .......................................................................................................................... 6
8.1.1 Three Phase 𝟏𝟐.𝟒𝟕 kV RMS Input Voltage ........................................................................... 6
8.1.2 Thyristor Firing Pulses ........................................................................................................... 6
8.1.3 Switch-over Tank ................................................................................................................... 7
8.1.4 AC Control Power for Termination Tank HV Relay ............................................................... 8
8.1.5 AC Control Power for the Switchgear Controller .................................................................. 8
8.1.6 DC Control Power for the Switchgear Controller .................................................................. 8
8.2 Stored Electrical Energy ................................................................................................................ 9
8.3 High Voltage Oil ............................................................................................................................ 9
8.4 Elevated Work Platform .............................................................................................................. 10
9 Preparation to Work on Inactive (Idle) HVPS Supply .......................................................................... 10
9.1 Verify Initial Conditions ............................................................................................................... 10
9.1.1 Determine active HVPS ....................................................................................................... 10
Page 1 of 20


---
## Page 2

9.1.2 Verify SPEAR2 is properly locked out administratively and apply red CoHE Operations
Lockout Locks ...................................................................................................................................... 10
10 Notification of Operations of the Intent to Disable the HVPSs....................................................... 13
10.1 Verify Control Documents Exist and Obtain Authorization to Disable Supplies ......................... 13
11 Control of Hazardous Energy .......................................................................................................... 13
11.1 Control and Zero Voltage Verification of Inputs and Outputs of SPEAR2 .................................. 13
11.1.1 Remove and ZVV the 125 VDC Switchgear Control Power ................................................. 14
11.1.2 Verify the SPEAR2 Output is Grounded and Control its Termination ................................. 14
11.1.3 ZVV the Control Power for the SPEAR2 HVPS Controller .................................................... 14
12 Group Lockout Complete ................................................................................................................ 18
13 Removal of Complex Lockout ......................................................................................................... 18
13.1 Verify all work on the SPEAR2 HVPS has been completed and system is secure ....................... 18
13.1.1 SPEAR2 HVPS (B514) ........................................................................................................... 18
13.2 Invalidate Complex Lockout ........................................................................................................ 19
13.3 Remove Five (5) Red Operations Lockout Locks ......................................................................... 19
2 REVISION HISTORY
2.1 R1 MARCH 27, 2024
Original version.
3 TABLE OF FIGURES
Figure 1: Schematic diagram of SPEAR HVPS ............................................................................................... 6
Figure 2: Switch-over tank for SPEAR1 and SPEAR2. ................................................................................... 7
Figure 3: SPEAR1 switchgear door with viewing window in B514. ............................................................ 11
Figure 4: HVPS 208 VAC control power disconnect switches in B514 ....................................................... 12
Figure 5: B117 LBP breaker panel for HVPS controller 120 VAC control power. ....................................... 13
Figure 6: 125 VDC control power enclosure and circuit breakers in B514. ............................................... 15
Figure 7: Switch-over tank with SPEAR2 leads removed and shorted to ground. ..................................... 16
Figure 8: The inside of the HVPS controller enclosure in B118. ................................................................ 17
Figure 9: 120 VAC control power for HVPS controller for SPEAR1 (left) and SPEAR2 (right), both in B118.
.................................................................................................................................................................... 17
Figure 10: Complex Lockout Permit for the SPEAR3 RF SPEAR2 Isolation Plan SR-444-636-07-R1 ........... 20
Page 2 of 20


---
## Page 3

4 AUTHOR/APPROVERS/VALIDATORS
4.1 AUTHOR
__ J _ am _ e _ s _ J. _ S _ eb _ ek ______________________________ _M_a_r _27_, _2_02_4____________
James J. Sebek (Mar 27, 2024 15:53 PDT)
SSRL Technical Expert: Jim Sebek Date
4.2 REVIEWERS
__ M _ ar _ c L _ a _ rr _ us ________________________________ _M_a_r _28_,_ 2_02_4____________
Marc Larrus (Mar 28, 2024 09:27 PDT)
SSRL Technical Expert: Marc Larrus Date
_B_. _M_OR_R_IS_________________________________ _M_a_r _28_,_ 2_02_4____________
B. MORRIS (Mar 28, 2024 08:12 PDT)
Independent Reviewer: Ben Morris Date
_______________________________________ _M_a_r _27_, _2_02_4____________
Keith Jobe (Mar 27, 2024 16:59 PDT)
Electrical Safety Officer: Keith Jobe Date
4.3 MANAGEMENT APPROVAL
__ To _ ny _ B _ e _ uk _ e _ rs _______________________________ _M_ar_ 2_7_, _20_2_4____________
Tony Beukers (Mar 27, 2024 15:13 PDT)
EED-OPS Deputy Department Head: Tony Beukers Date
4.4 VALIDATOR
I have implemented this procedure in its entirety and have found it to be clear, complete, and accurate.
_______________________________________ ____________________
Technical Validator: ______________________ Date
5 PROCEDURE PURPOSE
The purpose of this document is to be an equipment-specific lockout procedure (ELP) for working on the
SPEAR High Voltage Power Supply (HVPS), SPEAR2, while the other HVPS, SPEAR1 is operational. At the
beginning of this procedure, SPEAR1 will be the operational supply for the SPEAR3 RF system and
SPEAR2 will be idle. It will have been disconnected from all energy sources and its output will have been
verified to be at 0 VDC. It is disconnected from the 12.47 kV RMS premises power, has been
disconnected from other voltage sources, and its outputs are shorted to ground. At this time the energy
sources for SPEAR2 will be locked out by an administrative lock. All of its stored energy should have
dissipated due to engineering controls in the HVPS, but the dissipation will not have been verified. The
ELP will verify that there will be no voltage at either the input or output of SPEAR2.
There is an underlined section, “______”, before each individual step to be executed in this procedure
for the lead authorized worker (LAW) to initial as they complete it. The steps within this procedure in
which lock out tag out (LOTO) locks are applied and/or zero voltage verification (ZVV) is performed have
a different underlined section, “______”, intended to alert the LAW that these steps are LOTO and/or
ZVV related.
Page 3 of 20


---
## Page 4

This procedure only provides an ELP for the SPEAR2 HVPS. It does not cover any work performed on the
HVPS. Other maintenance procedures are required to cover that work.
6 EQUIPMENT REQUIRED TO EXECUTE PROCEDURE
The following equipment is required to execute this procedure:
• Five (5) each identically keyed red locks dedicated to the execution of this ELP and referred to in
this ELP as “Operations Lockout Locks”, five (5) each Group Lockout Tags, appropriately filled out
to label the ELP and the equipment to be locked out with the Operations Lockout Locks. The
locks and tags will be applied to:
o Three of each are used to apply LOTO on the input energy sources for SPEAR2,
o One of each for the 125 VDC source common to both HVPSs,
o One of each for the Plexiglas door that contains the switch-over tank that connects the
output of SPEAR1, the active HVPS, to the klystron.
• One circuit breaker lockout device for GE 120 VAC breakers.
• Five (5) lockout hasps to apply to the devices to be locked out.
• One red personal Lockout Lock belonging to the LAW and one orange Group Master Lockout
Tag, both to be applied by the LAW on the group lockout box.
• Digital multimeter (DMM) to measure the output of 120 VAC and 125 VDC sources.
• Appropriate PPE for measuring potential 120 VAC and 125 VDC sources.
This equipment should be assembled before starting this procedure.
7 EQUIPMENT DESCRIPTION
The equipment covered by this procedure are the SPEAR3 HVPSs SPEAR1 and SPEAR2, both located in
building 514. (Henceforth we will refer to the storage ring as SPEAR so that the only numbered versions
of SPEAR in this document will refer to HVPSs.) Each HVPS has its own associated switchgear, which
includes a disconnect switch, fuses, protective relays, and a vacuum contactor. The purpose of each
HVPS is to supply DC power to the SPEAR klystron which, in turn, provides radiofrequency (RF) power to
the SPEAR cavities which accelerate the SPEAR electron beam. The maximum output rating of each
HVPS is −90 kVDC at 27 A, or 2.5 MW. A schematic diagram of the HVPS is shown in Figure 1.
SPEAR has only one klystron, so only one of the HVPSs can ever be used at a time. The other is staged as
a “warm spare”. SPEAR1 and SPEAR2 share a common three phase 12.47 kV RMS feed that comes from
breaker 160 in substation 507. The HVPSs are administratively controlled so that, at most, only one
HVPS can be energized at a time. Each has its own separate controller, but they share the input 12.47
kV RMS feed, HV output cables to the klystron, and connections to the low-level radio frequency (LLRF)
system.
There is an aluminum oil-filled switch tank located next to B514 that connects the appropriate HVPS to
the klystron. The aluminum tank is electrically grounded to earth at the tank location and the tank is
filled with FR3 dielectric oil to increase the voltage withstand between the exposed conductors and the
grounded tank. The oil is rated to exceed the IEEE C57.147 standard that specifies a breakdown of
Page 4 of 20


---
## Page 5

greater than 130 kV for distances of one inch (25.4 mm). The two output cables, high voltage and
return, of both HVPSs are terminated in the tank. The high voltage cable of the active HVPS is
connected to the high voltage cable that connects to the termination tank next to the klystron.
Similarly, the return cable of the active HVPS is connected to the return cable that connects to the
termination tank. The high voltage and return cables of the warm spare are always shorted together
and shorted to ground in one of two configurations. Either they are connected to a shorting bar inside
of the switch tank or they are shorted together and to ground outside of the switch tank. In the latter
case, a worker on the warm spare can visually see an air gap between the cables and any cables
connected either to the other supply or the klystron.
The termination tank, located next to the klystron, is of similar construction to the switch tank, in that it
is made from aluminum and electrically grounded to earth at the tank. It also uses a high voltage
dielectric oil but, for historical reasons, this oil is conventional mineral oil and not a natural ester like
FR3.
The HVPS that functions as the warm spare is administratively locked off. Its input 12.47 kV RMS
switchgear disconnect switch is locked in the open position, its three input 200 A, 50E medium voltage
fuses are removed, and the load side of the vacuum contactors, the line side of the HVPS, is grounded.
A low voltage disconnect switch is opened to interrupt the 208 VAC control power to the switchgear,
and the breaker for the 120 VAC power to the HVPS controller is opened. Administrative locks from the
RF group are placed on these two disconnect switches and the breaker to ensure that power is not
inadvertently re-introduced into the spare.
Page 5 of 20


---
## Page 6

Figure 1: Schematic diagram of SPEAR HVPS
8 POTENTIAL HAZARDS
8.1 ELECTRICAL SOURCES
8.1.1 Three Phase 𝟏𝟐.𝟒𝟕 kV RMS Input Voltage
The HVPS power is supplied by the 12.47 kV RMS premises power. Removing the premises power
removes this hazard and prevents the HVPS from generating continuous output power. The medium
voltage disconnect switch and the vacuum contactor are shown on the left side of Figure 1.
8.1.2 Thyristor Firing Pulses
The HVPS power is controlled by the appropriate firing of thyristors. The firing pulses, generated by the
HVPS controller, are in short bursts, but their amplitude may be as large as 200 V. These pulses are fully
contained within the HVPS. They pose no electrical hazard to anyone outside of the closed HVPS.
Removing a single phase 120 VAC control power to the HVPS controller by opening a breaker removes
this hazard. The two breakers enabling the control power to the two controllers are shown in Figure 5.
Page 6 of 20


---
## Page 7

8.1.3 Switch-over Tank
The switch-over tank is the oil-filled mechanical structure that is used to select which HVPS is connected
to the klystron load. This selection is made by connecting the two cables from the -90 kV output bus of
the active supply to the cables that connect to the klystron after passing through the termination tank.
The output cables of the inactive supply are mechanically connected together, and therefore electrically
shorted to each other and then to ground, external to this tank.
No access to nor manipulation of cables in the switch-over tank is required for this ELP. Since it is a part
of the HVPS to klystron configuration, we include this description and photograph for completeness.
SPEAR1 HV SPEAR1 RTN
KLYSTRON HV KLYSTRON RTN
SPEAR2 HV SPEAR2 RTN
Figure 2: Switch-over tank for SPEAR1 and SPEAR2.
Page 7 of 20


---
## Page 8

8.1.4 AC Control Power for Termination Tank HV Relay
The termination tank has a high voltage (Ross Engineering) relay that needs to be energized with 120
VAC when the HVPS is active. During the transition from making one HVPS inactive and the other one
active, the source of the 120 VAC control power is switched from one HVPS controller to the other. The
connectors that carry this control power and that are required to be handled during the switch between
HVPSs are touch safe. Removing the control power from both HVPS controllers removes this power
during the switchover procedure. The breakers enabling the control power are shown in Figure 5.
The control power for the termination tank HV relay never enters the HVPS, itself, so this is not a hazard
to working on or inside of the HVPS. This paragraph is only included in this document to show that any
potential hazard it may produce has not been ignored.
8.1.5 AC Control Power for the Switchgear Controller
The switchgear, immediately upstream of and connected to the HVPS, has its own controller to operate
its HV contactor. When its 120 VAC control power is removed from the switchgear, the 12.47 kVAC
vacuum contactor cannot be closed. In addition to controlling the contactor, this control power also
powers a service lamp in the switchgear and an oil pump in the HVPS main tank. This power is entirely
contained within the HVPS. Opening a disconnect switch, shown in Figure 4, removes this power from
the HVPS. The only potential hazard this poses to anyone working on the HVPS itself is if the oil pump
within the HVPS main tank needs to be serviced.
8.1.6 DC Control Power for the Switchgear Controller
125 VDC is used for DC control power in the switchgear. This power is sourced from a supply within
substation 507. We distribute that power to SPEAR1 and SPEAR2 through a local breaker panel in B514,
shown in Figure 6. Opening this breaker removes that power from the switchgear and associated
interlocks.
The 125 VDC control power serves several functions. First, it supplies the control power to the MX relay
coil. Activating the MX relay coil is necessary to remotely close, and keep closed, the 12.47 kVAC
contactor in the HVPS switchgear. Second the 125 VDC is used to provide power to the four each ABB
MCO protective relays and the three each phase current meters. Finally, the 125 VDC provides the
power for the 86L lockout relay and its associated circuitry. The inputs to the lockout relay are the
normally open relay contacts from the trip circuits of the MCOs as well as the normally open HVPS
machine protection system signals from tank over-pressure, oil over-temperature, and low flow of the
HVPS low conductivity water (LCW). If any of these contacts close, the 125 VDC control power energizes
the lockout relay coil. When energized, the relay opens a normally closed contact that removes the
power from the MX relay coil, opening the contactor.
Both HVPSs share a common LCW flow interlock which is connected to the 125 VDC power. During the
switch between HVPSs, a touch safe connector must be moved to connect the active HVPS. Removing
the 125 VDC control power protects against potential damage to the control hardware.
The only potential hazard the 125 VDC control power may pose is to someone working in the HVPS main
tank, near any of the HVPS MPS circuit elements that are powered by this voltage.
Page 8 of 20


---
## Page 9

8.2 STORED ELECTRICAL ENERGY
There are three types of capacitive elements closely coupled to the HVPS output. The first is a series of
four each 8 𝜇𝐹 capacitors that connect to and extend across the output through pairs of 500 Ω
resistors. The second is a single 0.22 𝜇𝐹 capacitor directly across the output. The third is the
approximately 60 m of Mil-C-17/81-0001 (RG220) cable between the HVPS output and the klystron. The
capacitance of this cable is about 6 nF. The total stored energy in these three sets of capacitors, at full
rated output voltage, is about 9 kJ.
Under normal conditions, once the HVPS is turned off, the stored energy is dissipated into the klystron
in a fraction of a second. If the measured output voltage of the HVPS is zero, there is no stored energy
in these capacitors that can be accessed from outside of the HVPS. The HVPS output voltage is
monitored by a redundant set of passive voltage dividers. The low voltage output of these dividers can
be measured in the HVPS controller, and from these redundant measurements, one can calculate the
output voltage of the supply. If, from these measurements, any potentially hazardous voltage is
calculated to be on the HVPS output, one needs to discharge this voltage using properly rated high
voltage resistive discharge sticks. Any voltage measurement directly on the HVPS output must be
performed using properly rated high voltage probes. It is imperative that one does not enter the
restricted approach boundary when measuring and/or discharging the unknown voltage on the
conductors.
Inside of the termination tank shown in Figure 1 are two shorting mechanisms. When they are shorted
together, they connect the center conductor of the -90 kV cable with the center conductor of the return
cable. One mechanism is an electro-mechanical high voltage relay controlled by the HVPS controller and
the other is a purely mechanical plunger. When either of these mechanisms short the cables, they
provide a short across the output filter capacitors in the HVPS. (Note that these mechanisms are too
detailed to be shown in the figure.)
8.3 HIGH VOLTAGE OIL
Tens of gallons of FR3 high voltage oil fills the switch-tank to provide electrical insulation. The switch-
over from the active supply to the warm spare requires manipulation of the Mil-C-17/81-0001 cables in
this tank. The oil is pumped out of the tank before the switch-over occurs and the tank is refilled after
the switch-over. The pump assembly used in this step is bulky and the barrels that are used to
temporarily store the oil are heavy when filled with the oil. Proper lifting techniques must be used,
when required. Also, good housekeeping practices should be followed to minimize and clean up any oil
spillage that could lead to slips and/or falls during this switch-over.
The HVPS contains 2600 gallons of the FR3 oil. Approximately 100 gallons is in each of the two small
tanks, the phase tank and the crowbar tank, and the rest is in the main tank. Pumping out large
fractions of the oil from the main tank requires setting up large temporary oil storage tanks in a
temporary portable secondary oil containment berm adjacent to building 514. The secondary oil
containment berm and storage tanks add potential slip and trip hazards to the work area. Care must be
taken to follow safe work practices when working in this secondary oil containment berm.
Page 9 of 20


---
## Page 10

8.4 ELEVATED WORK PLATFORM
Work to access the inside of any part of the HVPS requires access to the top of the HVPS. Both HVPSs
are enclosed by permanent scaffolding that protects the worker from falling off of the HVPS when on
top of it. That being said, the top of each HVPS has several trip hazards and the metallic surfaces may be
slippery due to oil film on them. Care must be taken to follow safe work practices when on top of the
HVPS.
9 PREPARATION TO WORK ON INACTIVE (IDLE) HVPS SUPPLY
9.1 VERIFY INITIAL CONDITIONS
The first steps of this procedure are to verify that SPEAR2, the inactive HVPS is, indeed, in a known
inactive (idle) safe state. If this is not the case, this procedure should be stopped and an appropriate
subject matter expert (SME) for the HVPS should be called in to properly secure SPEAR2.
9.1.1 Determine active HVPS
______ Write either SPEAR1 or SPEAR2 in the space at right to denote the active HVPS ________
______ Write the other HVPS name in the space at the right to denote the inactive HVPS ________. If
the inactive supply is not SPEAR2, STOP THIS PROCEDURE and contact an HVPS SME for assistance.
9.1.2 Verify SPEAR2 is properly locked out administratively and apply red CoHE Operations Lockout
Locks
SPEAR2 must be controlled to ensure that it does not have any active source during this procedure.
Three RF Group configuration locks should be controlling these sources. This series of steps ensures that
these locks are in place and will place red CoHE Operations Lockout Locks to control the hazards during
work on SPEAR2.
9.1.2.1 12.47 kVAC Input
______ Verify the 12.47 kVAC disconnect switch on the metal-enclosed switchgear of SPEAR2 in B514 is
in the open position and an RF Group configuration lock is controlling the switch. The dark blue arrow in
Figure 3 shows the location of the disconnect switch of SPEAR1. In this figure the switch is locked in the
open position. The location of the switch for SPEAR2 looks the same as that for SPEAR1.
______ Apply a red CoHE Operations Lockout Lock and an appropriately filled out Group Lockout Tag to
the open 12.47 kVAC disconnect switch of SPEAR2. The common key to this red CoHE Operations
Lockout Lock and all the other identically keyed Operations Lockout Locks shall be placed in a group
lockout box to which all affected workers shall apply their own personal red LOTO lock.
______ By looking through the window of the switchgear door, visually verify there are three air gaps in
the switchgear, one for each phase, by verifying that the three 50E 200A fuses are removed from the
switchgear. The viewing window is shown by the blue arrow in Figure 3. If you are not certain if the
fuses are removed, STOP THIS PROCEDURE and contact an HVPS SME for assistance. If you see that the
fuses are in the switchgear and have not been removed, STOP THIS PROCEDURE and contact an HVPS
SME for assistance, who will contact the facilities electricians to put this inactive HVPS input in a safe
condition.
Page 10 of 20


---
## Page 11

Figure 3: SPEAR1 switchgear door with viewing window in B514.
9.1.2.2 208 VAC Switchgear Control Power
______ Verify that the disconnect switch to the 208 VAC control power of SPEAR2 in B514 is in the open
position and an RF Group configuration lock is controlling the switch. In Figure 4, the disconnect switch
for SPEAR1 is on the right and the disconnect switch for SPEAR2 is on the left. In Figure 4 the SPEAR1
disconnect switch is in the closed position and the SPEAR2 disconnect switch is locked in the open
position with an administrative lock.
______ Apply a red CoHE Operations Lockout Lock and an appropriately filled out Group Lockout Tag to
the open 208 VAC disconnect switch for SPEAR2.
Page 11 of 20


---
## Page 12

SPEAR2 208 VAC SPEAR1 208 VAC
Figure 4: HVPS 208 VAC control power disconnect switches in B514
9.1.2.3 120 VAC HVPS Controller Control Power
______ Verify that the 120 VAC circuit breaker for the HVPS controller of SPEAR2 is in the open position
and an RF Group configuration lock is controlling the breaker. (B117 Panel LPB CB 34, the dark blue
arrow in Figure 5, for SPEAR2)
______ Apply a red CoHE Operations Lockout Lock and an appropriately filled out Group Lockout Tag to
keep the circuit breaker LPB CB 34 in the open position.
Page 12 of 20


---
## Page 13

SPEAR1 120 VAC
SPEAR2 120 VAC
Figure 5: B117 LBP breaker panel for HVPS controller 120 VAC control power.
10 NOTIFICATION OF OPERATIONS OF THE INTENT TO DISABLE THE HVPSS
10.1 VERIFY CONTROL DOCUMENTS EXIST AND OBTAIN AUTHORIZATION TO DISABLE SUPPLIES
Appropriate configuration control documents for work on the HVPS system must be entered and
approved. A CATER is required to track the work and to inform SPEAR operations about the work. The
SPEAR operations group will grant permission for this work to proceed only after the appropriate
configuration control documents are in place.
______ CATER number corresponding to the HVPS work ________
______ Obtain permission from the SPEAR operations group to proceed with the work.
11 CONTROL OF HAZARDOUS ENERGY
11.1 CONTROL AND ZERO VOLTAGE VERIFICATION OF INPUTS AND OUTPUTS OF SPEAR2
All of the voltage inputs to SPEAR2 should already be disabled and their sources locked out. Also, the
output of SPEAR2 should already be grounded. Three red CoHE Operations Lockout Locks have already
been applied to three sources, in sections 9.1.2.1, 9.1.2.2, and 9.1.2.3 above. The ZVV for the 12.47 kV
Page 13 of 20


---
## Page 14

switchgear has already been carried out in 9.1.2.1 by visually verifying an air gap in the switchgear for
each of the three phases. No ZVV has been performed on the 208 VAC disconnect switch locked out in
9.1.2.2. That voltage is normally not accessible for any work performed on the HVPS except for the
replacement of the oil pump in the main tank. If that work is to be performed, the specific work plan for
that job must include a ZVV of the control power for the pump. This section will also detail the lockout
and ZVV of another source, the 125 VDC switchgear control power. The 125 VDC passes through the
HVPS contactor interlock chain that includes an over-pressure switch on top of the HVPS main tank. This
section also includes steps to ZVV the 120 VAC control power for the HVPS controller, and control and
ZVV the high voltage output of SPEAR2.
11.1.1 Remove and ZVV the 125 VDC Switchgear Control Power
The 125 VDC control power for the switchgear passes through an enclosure in B514 that contains three
touch-safe circuit breakers. The red arrow in Figure 6 points to the main breaker, which is in the ON
position in the picture. The dark red arrow points to the breaker for SPEAR2, which is also in the ON
position. The green arrow points to the breaker for SPEAR1, which is in the OFF position. Ensure that
you do not remove the 125 VDC control power from the active HVPS, as doing so will open its contactor
and turn off the RF.
______ In the 125 VDC service enclosure, open the breaker switch for SPEAR2.
______ Perform a ZVV on the load (bottom) side of the 125 VDC breaker switch for SPEAR2.
______ Close the cover of the service enclosure that contains the 125 VDC breaker switches and apply a
red CoHE Operations Lockout Lock and an appropriately filled out Group Lockout Tag to secure the cover
of this enclosure.
11.1.2 Verify the SPEAR2 Output is Grounded and Control its Termination
As part of the switch from SPEAR2 to SPEAR1 when work is planned on SPEAR2, the negative high
voltage and return cables from SPEAR2 were removed from the switch-over tank, shown in Figure 2, and
shorted together and to ground. This step verifies this condition of the output cables and controls the
access to the output cables.
______ Verify that the negative high voltage cables from SPEAR2 are removed from the switch-over
tank, their outputs are connected to each other and to ground, as shown in Figure 7. This verification
may be visual.
______ Apply a red CoHE Operations Lockout Lock and an appropriately filled out Group Lockout Tag to
the chain keeping the doors of the switch-tank enclosure closed.
11.1.3 ZVV the Control Power for the SPEAR2 HVPS Controller
The 120 VAC breaker for the SPEAR2 HVPS controller has already been controlled with a red CoHE
Operations Lockout Lock in 9.1.2.3 above, but its output has not been verified to be zero. The inside of a
controller is shown in Figure 8.
______ Perform a ZVV on the control power for SPEAR2, shown on the right-hand side of Figure 9, on
the TS1 DIN rail connections between line (red) and neutral (white), line and ground (green), and neutral
and ground.
Page 14 of 20


---
## Page 15

MAIN SPEAR2 SPEAR1
Figure 6: 125 VDC control power enclosure and circuit breakers in B514.
Page 15 of 20


### Table 1

| MAIN | SPEAR2 | SPEAR1 |
| --- | --- | --- |


---
## Page 16

Figure 7: Switch-over tank with SPEAR2 leads removed and shorted to ground.
Page 16 of 20


---
## Page 17

VOLTAGE DIVIDERS
120 VAC
Figure 8: The inside of the HVPS controller enclosure in B118.
Figure 9: 120 VAC control power for HVPS controller for SPEAR1 (left) and SPEAR2 (right), both in B118.
Page 17 of 20


---
## Page 18

12 GROUP LOCKOUT COMPLETE
______ The LAW shall place the common key to the five Operations Lockout Locks applied in this
procedure in the group lockout box. Then they shall place their personal lock on the group lockout box
and apply the orange Group Master Lockout Tag on the box.
______ The LAW shall obtain a copy of the Complex Lockout Permit for the SPEAR3 RF SPEAR2 Energy
Isolation Plan SR-444-636-07-R1, stored in the file Spear3HVPS2ComplexLockoutPermit.xlsx and a copy
of which is displayed in Figure 10, complete Section 2 of the permit, and place it adjacent to the group
lockout box.
13 REMOVAL OF COMPLEX LOCKOUT
After work on the SPEAR2 HVPS has been completed the above Complex Lockout Permit should be
voided and the five red Operations Lockout Locks associated with this procedure should be removed.
The hazards for SPEAR2 will still be locked off, but only with RF administrative locks and not with any red
CoHE locks. These steps should only be executed if both:
1. All workers have removed their individual red CoHE locks from the group lockout box.
2. No further work is expected to be performed on SPEAR2.
13.1 VERIFY ALL WORK ON THE SPEAR2 HVPS HAS BEEN COMPLETED AND SYSTEM IS SECURE
Inspect the areas around SPEAR2 and its HVPS controller to ensure that all equipment has been secured
and the system appears to have been returned to a safe state that can be energized. If this is not the
case, this procedure should be stopped and an appropriate subject matter expert (SME) for the HVPS
should be called in to properly secure the SPEAR2 HVPS system.
13.1.1 SPEAR2 HVPS (B514)
For SPEAR2:
______ Ensure that the main tank covers are in place and bolted down.
______ Ensure that the two pressure relief valves, both slow and rapid, are bolted in place and their
electrical connections have been made up.
______ Ensure that the dry nitrogen line have been connected to the appropriate port on the main tank
lid.
______ Ensure that the phase tank lid is in place and bolted down.
______ Ensure that the Synflex water cooling hoses are connected to the phase tank lid radiator.
______ Ensure that the crowbar tank lid is in place and bolted down.
______ Ensure that the Synflex water cooling hoses are connected to the crowbar tank lid radiator.
______ Ensure that the rear doors of the switchgear are closed and locked.
Page 18 of 20


---
## Page 19

13.2 INVALIDATE COMPLEX LOCKOUT
______ The LAW shall remove the orange Group Master Lockout Tag from the group lockout box.
______ The LAW shall remove their personal lock from the group lockout box.
13.3 REMOVE FIVE (5) RED OPERATIONS LOCKOUT LOCKS
______ Remove one red operations lockout lock from service enclosure in B514 that contains the
breakers for the 125 VDC control power for the switchgear.
______ Remove one red operations lockout lock from the 208 VAC disconnect switch in B514 that
provides control power for SPEAR2.
______ Remove one red operations lockout lock from the 12.47 kVAC disconnect switch in B514 that
provides the mains power for SPEAR2.
______ Remove one red operations lockout lock from the chain keeping the doors of the switch-tank
enclosure in B514 closed.
______ Remove one red operations lockout lock from Breaker 34 in B117 LBP breaker panel that
provides control power to the SPEAR2 HVPS controller.
Page 19 of 20


---
## Page 20

COMPLEX LOCKOUT PERMIT
FOR ELPs AND GROUP LOCKOUT PAGE __1___ of __1___
SECTION 1 -- REFERENCE INFORMATION
LOTO ID or Equipment-Specific Lockout/Tagout Procedure ID:
SPEAR3 RF HVPS2 Energy Isolation Plan SR-444-636-07-R1
SECTION 2 -- LEAD AUTHORIZED WORKER - SIGN WHEN ENERGY ISOLATION INCLUDING VERIFICATION OF NON-OPERATION, ZERO ENERGY VERIFICATION, ZERO
VOLTAGE VERIFICATION, AND GROUNDS (IF APPLICABLE) IS COMPLETE, AND THE LOCKOUT IS READY FOR AUTHORIZED WORKER SIGN ON
LEAD AUTHORIZED WORKER CONTRACTOR SUPV
or OPERATIONS GROUP: (if applicable):
print sign date / time print name, sign, and print company name
SLAC AUTHORIZED WORKERS SHALL NOT SIGN ON UNTIL THE SLAC LEAD AUTHORIZED SUBCONTRACTOR WORKERS SHALL NOT SIGN ON UNTIL THE SLAC LEAD AUTHORIZED WORKER OR
WORKER OR OPERATIONS GROUP HAS SIGNED SECTION 2 OF THIS PERMIT OPERATIONS GROUP and CONTRACTOR SUPV HAS SIGNED SECTION 2 OF THIS PERMIT
SECTION 3 -- SLAC AUTHORIZED WORKER SIGN-ON AND SIGN OFF SECTION 4 -- CONTRACTOR AUTHORIZED WORKER SIGN-ON AND SIGN OFF
AUTHORIZED WORKER SIGN ON DATE / TIME A U T HORIZED WORKER SIGN OFF DATE / TIME A U THORIZED WORKER SIGN ON DATE / TIME A U T HORIZED WORKER SIGN OFF DATE / TIME
print print Apurtihnotrized Workers shall perform additional ZVVas required by their JpSrAin.t
sign sign sign sign
print print print print
sign sign sign sign
print print Tphrein stequence of removal of energy isolation locks should addressed ipnr ian tseparate JSA and tailgate meeting.
sign sign sign sign
print print print print
sign sign sign sign
print print print print
sign sign sign sign
print print print print
sign sign sign sign
print print print print
sign sign sign sign
print print print print
sign sign sign sign
print print print print
sign sign sign sign
Figure 10: Complex Lockout Permit for the SPEAR3 RF SPEAR2 Isolation Plan SR-444-636-07-R1
Page 20 of 20


### Table 1

|  |  | CONTRACTOR SUPV (if applicable): date / time |
| --- | --- | --- |
| print | sign |  |


### Table 2

| DATE / TIME A U T HORIZED WORKER SIGN OFF |  | DATE / TIME A U THORIZED WORKER SIGN ON | DATE / TIME A U T HORIZED WORKER SIGN OFF |  |
| --- | --- | --- | --- | --- |
|  | print | Apurtihnotrized Workers shall perform additional ZV sign | Vas required by their | JpSrAin.t |
|  | sign |  |  | sign |
|  | print | print sign |  | print |
|  | sign |  |  | sign |
|  | print | Tphrein stequence of removal of energy isolation lo sign | cks should addressed | ipnr ian tseparate JSA and tailgate meeting. |
|  | sign |  |  | sign |
|  | print | print sign |  | print |
|  | sign |  |  | sign |
|  | print | print sign |  | print |
|  | sign |  |  | sign |
|  | print | print sign |  | print |
|  | sign |  |  | sign |
|  | print | print sign |  | print |
|  | sign |  |  | sign |
|  | print | print sign |  | print |
|  | sign |  |  | sign |
|  | print | print sign |  | print |
|  | sign |  |  | sign |
