# phaseTankMaintenance-20240425jjs

> **Source:** `hvps/maintenance/phaseTankMaintenance-20240425jjs.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## SPEAR3 HVPS Phase Tank Maintenance

## Revision History

### R1	Date

Original version.
## Table of Figures









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

This procedure is an outline of the steps needed to perform routine maintenance on the high voltage power supply (HVPS) phase tank.  This routine maintenance involves replacing the twelve phase control thyristor stacks with known good, tested stacks, inspecting the snubber resistors and capacitors, and general inspection of the phase tank.
In order to safely work on the phase tank, or any other part of the HVPS, the power to this system must be removed using the energy isolation plan (EIP), “SPEAR3 Removal of RF HVPS Energy Isolation”, SR-444-636-05-R1.
## Equipment Required to Execute Procedure

The following equipment is required to execute this procedure:
- One (1) each personal red LOTO lock for each worker on the phase tank.  Each worker will apply their lock to the group lockout box.
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
- Wrenches (hand and pneumatic) to remove phase tank cover.
- Wrenches to disconnect/reconnect phase tank bussing.
- Screwdrivers to disconnect/reconnect gate trigger leads.
- Grounding equipment
- Two (2) each Phenix discharge sticks rated for more than 40 kV.
- Two (2) each grounding sticks.
- Phase control stacks
- Twelve (12) each tested phase control stacks.
- Plastic containers in which to transport new stacks onto the HVPS and remove the existing stacks from the HVPS.
- General safety equipment
- Pads on which to kneel.
- Gloves to protect hands.
This equipment should be assembled before starting this procedure.
## Equipment Description

The HVPS for the SPEAR3 klystron takes as input 12.47 kVAC from the mains and converts it to an output of up to 90 kVDC at 27 A.  The output of the HVPS is controlled by twelve stacks of thyristors in the phase tank.  Each stack is shown as a single thyristor and labeled “Thyristor Controlled Rectifier” in Figure 1.  These rectifiers are at the center of the two wye rectifier transformers.
The phase tank is electrically connected to the wyes of the rectifier transformer primary windings and the filter inductors.  It is also electrically connected to the HVPS controller, located in B118, that generates the thyristor trigger pulses.  The only connection of this tank to the HVPS output and its potential stored energy is via transformer coupling between the primary and secondaries of the two rectifier transformers.

Figure 1:  Schematic diagram of SPEAR HVPS
## Potential Hazards

### Electrical Sources

#### Three Phase  kV RMS Input Voltage

The HVPS power is supplied by the  kV RMS premises power.
#### Thyristor Firing Pulses

The HVPS power is controlled by the appropriate firing of thyristors.  The voltage of the short thyristor trigger pulses ranges from 120 VDC to 240 VDC. 
### Stored Electrical Energy

There are two types of capacitive elements in the phase tank.  There are twelve 0.015 uF capacitors, one across each thyristor stack.  There are 168, each, 0.047 uF capacitors, one across each of the fourteen thyristors in each stack.
### High Voltage Oil

One hundred thirty-five gallons of FR3 high voltage oil fills the phase tank to provide electrical insulation.
### Work Platform

Work to access the phase tank requires access to the top of the HVPS.  Scaffolding with rails surrounds the HVPSs and protects against falls.  There are trip hazards on top of the HVPSs and there is the potential that the metal may be slippery from oil.
## Work in the Phase Tank

### Verify That the Input Energy to the HVPS Has Been Removed

#### Verify that SPEAR3 RF HVPS Energy Isolation Plan has been executed and join the lockout.

______  Verify that EIP SR-444-636-02-R2 has been executed.
**_____****_**  Apply a personal red CoHE lock to the group lockout box.
**_____****_**  Sign into the Complex Lockout Permit.
### Bring the Replacement Phase Stacks to the top of the HVPS

______  Coordinate with the SSRL mechanical services group (MSG) to bring the twelve replacement thyristor phase stacks up to the top of the HVPS using a forklift and lifting basket.
### Remove the Nitrogen Feed to the HVPS

______  Close the nitrogen valve, located on the south wall of B514, for the HVPS.
______  Disconnect the nitrogen feed line from the main tank.
______  Place a lockout boot on the connection on the main tank and secure that boot with an RF administrative lock.
### Pump Out the Oil from the Phase Tank

______  Set up the temporary secondary containment berm next to B514 and place a temporary storage pod inside of the berm.
______  Using the pneumatic oil pump, hoses, tubes, and quick disconnect fittings, connect a hose to the oil port on the phase tank and pump out the oil from the phase tank into the temporary storage pod.
______  Clean up any oil that has spilled during this process.
### Disconnect the Cooling Water Lines from the Phase Tank

______  Valve off first the supply and then the return LCW lines on the south wall of B514 for the HVPS.
______  Disconnect the quick disconnect water hoses from the phase tank connections ().

Figure 2. Phase Tank Plumbing Connections
______  Mop up any spilled water.
### Remove the Phase Tank Cover

______  Remove the bolts that secure the aluminum phase tank cover onto the HVPS ()

Figure 3. Tank Lid, Bolts Installed
______  As a two person job, lift the cover off of the phase tank.  Once it is above the HVPS, tilt it slightly so that oil on the radiator has a chance to drain into the phase tank.
______  Set the phase tank cover on absorbent pads in a location away from the phase tank ().

Figure 4. Lid Tilted To Drain

### Discharge and Stored Energy in the Phase Tank

For work inside the phase tank, reference the photo in .

Figure 5. Phase Tank, Lid Removed
______  Connect the two Phenix discharge sticks to earth ground on the HVPS.
______  Touch, for five seconds, one of the discharge sticks to one terminal of each of the two pairs of inductor bushings in the phase tank (upper bushings).
______  Touch, for five seconds, one of the discharge sticks to each of the six phase bushings in the phase tank (lower bushings).
______  Keeping the first discharge sticks on an inductor bushing, touch, for five seconds, the second discharge stick to the three phase bushings associated with that inductor.  Then move the first discharge stick to a bushing connected to the other inductor.  While the first stick remains on the inductor bushing, touch, for five seconds, the second discharge stick to the three phase bushings associated with that inductor.
### Disconnect the Grounding Buswork

There are two identical sets of grounding buswork, one for each of the rectifier transformers.
______  Unbolt the plated copper tubing for grounding the top of the components from the walls of the phase tank.
______  Unbolt the plated copper tubing from the insulated standoffs that hold the twelve phase control stacks.
### Disconnect the Trigger Firing Connections

______  For each of the twelve stacks, disconnect the cable pair that connects the triggers to the transformer on the top of each stack ().  Take notice of which color of each pair goes to each of the two terminals.

Figure 6. Trigger Connections, Typical
### Remove the Remaining Buswork

______  Remove the buswork that connects the stacks to the inductor bushings.
______  Remove the buswork that connects the stacks to each other.
______  Remove the buswork that connects the stacks to the input phases.
______  Remove the buswork that connects the stacks to their individual snubber circuits.
### Remove the Existing Phase Stacks from the Phase Tank

______  Unscrew the threaded phase stacks from the baseplate and place them in the plastic containers for return to the shop and testing.
### Evaluation of Snubber Circuits

______  Visually inspect the snubber resistors and capacitors for any obvious signs of wear and/or damage.
______  Measure the values of the snubber resistors and replace any that are out of tolerance.
______  Measure the values of the snubber capacitors and replace any that are out of tolerance.
## Reconfigure System to Operational Condition

Section 10 works in the reverse order of section 9 to restore the phase tank to its operational condition.
### Install the Replacement Phase Stacks into the Phase Tank

______  Screw the replacement phase stacks into the baseplate.  Ensure that when securing them to the baseplate you do not over-torque or otherwise put undue strain on the stacks.
### Attach the Electrical Buswork

______  Attach the buswork that connects the stacks to their individual snubber circuits.
______  Attach the buswork that connects the stacks to the input phases.
______  Attach the buswork that connects the stacks to each other.
______  Attach the buswork that connects the stacks to the inductor bushings.
### Connect the Trigger Firing Connections

______  For each of the twelve stacks, connect the cable pair that connects the triggers to the transformer on the top of each stack.  Take notice of which color of each pair goes to each of the two terminals to ensure that the pairs are connected properly.
### Connect the Grounding Buswork

There are two identical sets of grounding buswork, one for each of the rectifier transformers.
______  Reconnect the plated copper tubing to the insulated standoffs that hold the twelve phase control stacks.
______  Reconnect the plated copper tubing for grounding the top of the components to the walls of the phase tank.
### Secure the Phase Tank Cover

______  As a two person job, replace the phase tank cover back onto the tank.
______  Secure the bolts that connect the aluminum phase tank cover to the HVPS
### Connect the Cooling Water Lines to the Phase Tank

______  Connect the quick disconnect water hoses to the phase tank connections.
______  Valve on first the return and then the supply LCW lines on the south wall of B514 for the HVPS.
### Pump the Oil back into the Phase Tank

______  Using the pneumatic oil pump, hoses, tubes, and quick disconnect fittings, connect a hose to the oil port on the phase tank and pump the oil from the temporary storage pod back into the phase tank.
______  Clean up any oil that has spilled during this process.
______  Remove the temporary storage pod and temporary secondary containment berm from the area next to B514 and return them to their storage area under the trestle.
### Connect the Nitrogen Feed to the HVPS

______  Remove the RF administrative lock from the lockout boot and remove the boot on the connection on the main tank.
______  Connect the nitrogen feed line to the main tank.
______  Open the nitrogen valve, located on the south wall of B514, for the HVPS.
### Remove the Original Phase Stacks from the top of the HVPS

______  Coordinate with the SSRL MSG to bring the twelve original thyristor phase stacks down from the top of the HVPS using a forklift and lifting basket.

## End of Personal Lockout

______  Remove your personal LOTO red lock from the group lockout box for SR-444-636-02-R1.
______  Sign out of the Complex Lockout Permit for SR-444-636-02-R1.

> **Note:** This document contains embedded images that cannot be directly converted to text.
> Please refer to the original DOCX file for visual content.
