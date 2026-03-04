# LLRFUpgradeTaskListRev0

> **Source:** `hvps/architecture/designNotes/LLRFUpgradeTaskListRev0.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## LLRF Upgrade Task List

## LLRF Controls

We have purchased an LLRF9 control system from Dimtel.  Two LLRF9 units are required for operation.  We have purchased four units in order to have a complete set of spares.
### Interfaces

The rest of our control system will have one input and one output interface with the LLRF9.
#### Input

Our input will be a permit for the LLRF9 to produce an RF input to the drive amplifier.
#### Output

The LLRF9 output will be a permit for our MPS system to tell us that the LLRF9 has detected a fault and has zeroed its input to the drive amplifier.
## MPS System

We have designed and built a replacement for the legacy PLC-5 Rockwell Automation control system.  The upgrade has been designed to migrate the PLC-5 1771 hardware to ControlLogix 1756 using the Rockwell Automation conversion kit.  The system hardware has been assembled and the software has been written.  We still need to test the system with actual hardware and verify that it is functional.  There likely may be some modifications of the software that will be required.
### Interfaces

We will need to build an interface chassis that connects the MPS system to the rest of the RF system and to SPEAR3 as a whole.  It will have several inputs, both from within the RF system – the LLRF, the HVPS controller, another custom module that will detect some RF powers and generate a fault if the measured RF powers are exceeded, and possibly some optical arc detectors (Microstep-MIS) – and external faults from SPEAR3 such as SPEAR3 MPS, orbit interlock, and other as yet undefined permits.
#### Inputs

- One electrical input from LLRF9 to an optocoupler
- One fiber optic input from the HVPS controller
- One summary electrical input from the RF power detector to an optocoupler
- One summary electrical input from Microstep-MIS optical arc detectors to an optocoupler
- One 24 VDC input from the SPEAR3 MPS to an optocoupler
- One 24 VDC input from the SPEAR3 orbit interlock to an optocoupler
- Two spare inputs to an optocouplers
#### Outputs

- One electrical output to the LLRF9 to tell it to disable its output
- One fiber optic output to the HVPS controller to enable the phase control thyristors
- One fiber optic output to the HVPS controller to prevent the MPS system from firing the crowbar thyristors
## HVPS Controller

### Upgrade Tasks

- Reverse engineer code for programmable logic controller (PLC) of Rockwell Automation SLC-500 (ML)
- Write code for Rockwell Automation CompactLogix controller (ML)
- Work with controls to complete interface between CompactLogix and EPICS (ML, SC)
- Design CompactLogix hardware system to replace SLC-500 hardware (ML)
- Modify PPS interface to meet current standards (ML, JS, MC)
- Specify power supplies required in upgraded controller (ML, JS)
- Specify any modifications to layout in upgraded controller (ML)
- Verify existing documentation of controller and HVPS interfaces (ML, JS)
- Document existing analog controller architecture (JS)
- Upgrade to new Enerpro controller (JS)
- Design new regulator and interface boards (JS)
- Layout, fabricate, and test new regulator and interface boards (?)
- Troubleshoot and repair three broken windings in HVPS1 (ML, SJ)
- Build test stand with new hardware (ML)
- Test new design in test lab (ML, JS, JE)
- Build two new controllers for HVPS1 and HVPS2 (ML)
- Complete documentation (ML, ?)
### Maintenance Tasks (Not part of the upgrade project but included here for downtime schedule purposes)

- Replace oil pump in HVPS1 (SJ) (Replace oil pump in HVPS2 at next opportunity)
- Replace phase control thyristor stacks (SJ)
- Replace crowbar stacks (SJ)
### Interfaces

There will be software and hardware interfaces for this system.  The software interfaces will be between CompactLogix and EPICS.  The PLC will report back all of its analog data and digital status.  It will receive software instructions to
- Open/close the 12.47 kV contactor
- Enable the power supply to turn on (remove Enerpro fast and slow inhibits)
- Supply an output voltage set point at a rate no faster than 1 Hz.
There will also be a hardware interface between the HVPS PLC and the MPS controller for the RF system.  (There needs to be no direct hardware communication between the HVPS controller and LLRF9).
#### Inputs

- Fiber optic permit that says MPS does not want to fire the output filter crowbar thyristors.
- Fiber optic permit that allows the phase control thyristors to fire.
#### Output

- Fiber optic permit that tells the MPS that the HVPS controller is ready to turn on the phase control thyristors and ready to output high voltage.