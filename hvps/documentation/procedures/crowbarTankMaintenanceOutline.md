# crowbarTankMaintenanceOutline

> **Source:** `hvps/documentation/procedures/crowbarTankMaintenanceOutline.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## SPEAR3 HVPS Crowbar Tank Maintenance

## Revision History

### R1	Date

Original version.
## Table of Figures

Figure 1:  Schematic diagram of SPEAR HVPS	5

## Author/Approvers/Validators

### Author

_______________________________________			____________________
SSRL Technical Expert:  Jim Sebek				Date
### Reviewers

_______________________________________			____________________
EED-OPS Technical Expert:  Marc Larrus				Date
_______________________________________			____________________
Independent Reviewer:  Ben Morris				Date
### Management Approval

_______________________________________			____________________
EED-OPS Deputy Department Head:  Tony Beukers		Date
### Validator

I have implemented this procedure in its entirety and have found it to be clear, complete, and accurate.
_______________________________________			____________________
Technical Validator:  Jim Sebek					Date
## Procedure Purpose

This procedure is an outline of the steps needed to perform routine maintenance on the high voltage power supply (HVPS) crowbar tank.  This routine maintenance involves replacing the four optical thyristor stacks with known good, tested stacks, inspecting the snubber resistors and capacitors, the output filter capacitor, and general inspection of the crowbar tank.
In order to safely work on the crowbar tank, or any other part of the HVPS, the power to this system must be removed using the energy isolation plan (EIP), “SPEAR3 Removal of RF HVPS Energy Isolation”, SR-444-636-05-R1.
## Equipment Required to Execute Procedure

The following equipment is required to execute this procedure:
- One (1) each personal red LOTO lock for each worker on the crowbar tank.  Each worker will apply their lock to the group lockout box.
- Nitrogen line
- One (1) boot to use to secure the connection to the main tank cover of the input nitrogen line.
- One (1) RF administrative lock to lock the boot that secures the nitrogen line connection.
- Oil pumping equipment
- Pneumatic oil pump
- Hoses and tubes
- Temporary oil containment pod
- Temporary secondary oil containment berm
- Absorbent pads
- Paper towels
- Mechanical tools
- Wrenches (hand and pneumatic) to remove crowbar tank cover.
- Wrenches to disconnect/reconnect crowbar tank bussing.
- Grounding equipment
- Two (2) each Phenix discharge sticks rated for more than 40 kV.
- Two (2) each grounding sticks.
- Crowbar stacks
- Four (4) each tested crowbar stacks.
- Plastic containers in which to transport new stacks onto the HVPS and remove the existing stacks from the HVPS.
- General safety equipment
- Pads on which to kneel.
- Gloves to protect hands.
This equipment should be assembled before starting this procedure.
## Equipment Description

The HVPS for the SPEAR3 klystron takes as input 12.47 kVAC from the mains and converts it to an output of up to 90 kVDC at 27 A.  The output of the HVPS is controlled by twelve stacks of thyristors in the phase tank.  Each stack is shown as a single thyristor and labeled “Thyristor Controlled Rectifier” in Figure 1.  These rectifiers are at the center of the two wye rectifier transformers.
The crowbar tank is electrically connected to the rectifier transformer secondary windings and the output filter capacitors.  It is also optically connected to the HVPS controller, located in B118, that generates the crowbar trigger pulses.  It has two voltage dividers that are used to monitor the HVPS output.  The bottom of these dividers are inputs to the HVPS controller.  The only connection to the HVPS input, the phase control stacks, and the potential stored energy in the filter inductors is via the transformer coupling between the primary and secondaries of the two rectifier transformers. 

Figure 1:  Schematic diagram of SPEAR HVPS
## Potential Hazards

### Electrical Sources

#### Three Phase  kV RMS Input Voltage

The HVPS power is supplied by the  kV RMS premises power.
### Optical Sources

#### Thyristor Firing Pulses

The HVPS crowbar is fired with optical pulses transmitted over fiber optic cables.  These cables will be disconnected when the crowbar stacks are removed and replaced. 
### Stored Electrical Energy

There are two types of capacitive elements in the phase tank.  There are four uF capacitors, one across each thyristor stack.  There is one 0.22 uF output filter capacitor that connects the HVPS output to its return.
In the HVPS main tank are four (4) each 8 uF filter capacitors.  While these are not physically in the crowbar tank, they are electrically connected to the crowbar tank bushings.
### High Voltage Oil

One hundred thirty-five gallons of FR3 high voltage oil fills the crowbar tank to provide electrical insulation.
### Work Platform

Work to access the crowbar tank requires access to the top of the HVPS.  Scaffolding with rails surrounds the HVPSs and protects against falls.  There are trip hazards on top of the HVPSs and there is the potential that the metal may be slippery from oil.
## Work in the Crowbar Tank

### Verify That the Input Energy to the HVPS Has Been Removed

#### Verify that SPEAR3 RF HVPS Energy Isolation Plan has been executed and join the lockout.

______  Verify that EIP SR-444-636-02-R2 has been executed.
**_____****_**  Apply a personal red CoHE lock to the group lockout box.
**_____****_**  Sign into the Complex Lockout Permit.
### Bring the Replacement Crowbar Stacks to the top of the HVPS

______  Coordinate with the SSRL mechanical services group (MSG) to bring the four replacement thyristor crowbar stacks up to the top of the HVPS using a forklift and lifting basket.
### Remove the Nitrogen Feed to the HVPS

______  Close the nitrogen valve, located on the south wall of B514, for the HVPS.
______  Disconnect the nitrogen feed line from the main tank.
______  Place a lockout boot on the connection on the main tank and secure that boot with an RF administrative lock.
### Pump Out the Oil from the Crowbar Tank

______  Set up the temporary secondary containment berm next to B514 and place a temporary storage pod inside of the berm.
______  Using the pneumatic oil pump, hoses, tubes, and quick disconnect fittings, connect a hose to the oil port on the crowbar tank and pump out the oil from the crowbar tank into the temporary storage pod.
______  Clean up any oil that has spilled during this process.
### Disconnect the Cooling Water Lines from the Crowbar Tank

______  Valve off first the supply and then the return LCW lines on the south wall of B514 for the HVPS.
______  Disconnect the quick disconnect water hoses from the crowbar tank connections.
______  Mop up any spilled water.
### Remove the Crowbar Tank Cover

______  Remove the bolts that secure the aluminum crowbar tank cover onto the HVPS
______  As a two person job, lift the cover off of the crowbar tank.  Once it is above the HVPS, tilt it slightly so that oil on the radiator has a chance to drain into the crowbar tank.
______  Set the crowbar tank cover on absorbent pads in a location away from the crowbar tank.
### Discharge and Stored Energy in, and Accessible to, the Crowbar Tank

______  Connect the two Phenix discharge sticks to earth ground on the HVPS.
______  Touch, for five seconds, one of the discharge sticks to the output terminal of the 0.22 uF output filter capacitor.
______  Starting with the bushing pair nominally closest to ground potential (the two bushings physically furthest from the 0.22 uF capacitor), apply, and hold for five seconds, the two discharge sticks on the adjacent pair of bushings.  Repeat this process three additional times, so that all five bushings are discharged in pairs.
### Disconnect and Measure the Value of the Output Capacitor

______  Touch, for five seconds, one of the discharge sticks to the output terminal of the 0.22 uF output filter capacitor.
______  Visually inspect the capacitor to ensure that it is not obviously damaged.
______  Remove the copper tubing that connects the 0.22 uF capacitor to the high voltage output bushing.
______  Measure and record in a log book, the actual value of the 0.22 uF capacitor.  If it is outside of its tolerance, remove the capacitor and replace it with one in tolerance.
______  Connect a shorting wire between the capacitor output and a suitable grounding point on the HVPS for the duration of the work on the crowbar tank.
### Disconnect the Trigger Firing Connections

______  For each of the four stacks, disconnect the six (6) each connectorized fiber cables that connect the triggers to the fiber optic distribution board in the crowbar tank.
### Remove the Buswork

______  Remove the buswork that connects the stacks to the output rectifier bushings.
______  Remove the buswork that connects the stacks to each other.
### Remove the Existing Crowbar Stacks from the Crowbar Tank

______  Unscrew the threaded crowbar stacks from the baseplate and place them in the plastic containers for return to the shop and testing.
### Evaluation of Snubber Circuits

______  Visually inspect the snubber resistors and capacitors for any obvious signs of wear and/or damage.
______  Measure the values of the snubber resistors and replace any that are out of tolerance.
______  Measure the values of the snubber capacitors and replace any that are out of tolerance.
## Reconfigure System to Operational Condition

Section 10 works in the reverse order of section 9 to restore the crowbar tank to its operational condition.
### Install the Replacement Crowbar Stacks into the Crowbar Tank

______  Screw the replacement phase stacks into the baseplate.  Ensure that when securing them to the baseplate you do not over-torque or otherwise put undue strain on the stacks.
### Attach the Electrical Buswork

______  Attach the buswork that connects the stacks to each other.
______  Attach the buswork that connects the stacks to the inductor bushings.
### Connect the Trigger Firing Connections

______  For each of the four stacks, connect the six (6) each connectorized fiber trigger cables from the stacks to the connectors on the distribution board in the crowbar tank.
### Reconnect the Output Capacitor

______  Remove the shorting wire from the output of the 0.22 uF capacitor.
______  Connect the output of the 0.22 uF capacitor to the HV output bushing in the crowbar tank.
### Secure the Crowbar Tank Cover

______  As a two person job, replace the crowbar tank cover back onto the tank.
______  Secure the bolts that connect the aluminum crowbar tank cover to the HVPS
### Connect the Cooling Water Lines to the Crowbar Tank

______  Connect the quick disconnect water hoses to the crowbar tank connections.
______  Valve on first the return and then the supply LCW lines on the south wall of B514 for the HVPS.
### Pump the Oil back into the Crowbar Tank

______  Using the pneumatic oil pump, hoses, tubes, and quick disconnect fittings, connect a hose to the oil port on the crowbar tank and pump the oil from the temporary storage pod back into the crowbar tank.
______  Clean up any oil that has spilled during this process.
______  Remove the temporary storage pod and temporary secondary containment berm from the area next to B514 and return them to their storage area under the trestle.
### Connect the Nitrogen Feed to the HVPS

______  Remove the RF administrative lock from the lockout boot and remove the boot on the connection on the main tank.
______  Connect the nitrogen feed line to the main tank.
______  Open the nitrogen valve, located on the south wall of B514, for the HVPS.
### Remove the Original Crowbar Stacks from the top of the HVPS

______  Coordinate with the SSRL MSG to bring the four original thyristor crowbar stacks down from the top of the HVPS using a forklift and lifting basket.

## End of Personal Lockout

______  Remove your personal LOTO red lock from the group lockout box for SR-444-636-02-R1.
______  Sign out of the Complex Lockout Permit for SR-444-636-02-R1.

> **Note:** This document contains embedded images that cannot be directly converted to text.
> Please refer to the original DOCX file for visual content.
