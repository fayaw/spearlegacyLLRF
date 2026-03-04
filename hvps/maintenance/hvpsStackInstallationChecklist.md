# hvpsStackInstallationChecklist

> **Source:** `hvps/maintenance/hvpsStackInstallationChecklist.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## Proposed HVPS Pre-Turn on Checklist

J. Sebek  May 22, 2025
## Introduction

Refurbishment of the SPEAR HVPS is a necessary part of our maintenance program to avoid failures during the run.  The HVPS is a very complex, high impact piece of equipment that takes significant effort to not only maintain, but also to move in and out of operation.  Since this work is only done infrequently, it is good to have a thorough checklist of tests and procedures to be performed before we decide to switch over from one HVPS to the other.  This document is a first draft at developing such a checklist to minimize our chance of errors during this maintenance process.  Hopefully it can also help guide engineers and technicians in their work.
Note that this is a first draft.  Hopefully it covers most items, but all recipients of this email are encouraged to give their feedback on this.
## Bench Tests

This section needs to be flushed out more, with more details.
We currently check each stack that is removed from service and perform tests on it to ensure that our replacement stacks are fully functional.  These tests involve
- Cleaning stacks
- Visual inspection for damaged components
- High-pot testing of the entire stack to document current leakage
- Measurement of the voltage across each of the thyristor/MOV pairs in the stack to determine the current leakage of each pair.
- Replacing devices with high leakage current
- Verifying polarity of devices on stacks.  There are at least three distinguishing features between the positive and negative polarity stacks
- Orientation of the thyristor.  The stainless steel flange is on the cathode side of the Powerex T8K7 350A, the manufacturer’s marking is on outer ceramic diameter of the device closest to the cathode, and the gate terminal is closer to the cathode than the anode.  The positive stack has each thyristor cathode above its anode.  The negative stack has the anode above the cathode.
- The PCBs containing the gate driver circuitry are different colors for the two stacks.  The color of the board for the positive stacks is green and that for the negative stacks is blue.  (The silkscreen on the boards also has the words positive and negative, but these may be hard to see.
- The white axial capacitor on the the gate driver PCBs sits above the red rectangular capacitor on the boards for the negative stacks.  The red capacitor is higher on the board than the white capacitor on the positive stacks.
- Verifying all connections from firing boards to aluminum casting are secure
## Crowbar Tank

- Pump oil from the tank into a pod.
- Verify the oil appearance is good.
- High-pot the oil to ensure it has good voltage hold-off.
- Manually remove the cover (two-person job)
- Ground all metallic connections in the tank
- Disconnect fiber optic trigger cables
- Disconnect bus work
- Remove existing stacks
- Through the connections to the main tank, high-pot all four rectifier sections and record their leakage currents
- Measure and record the capacitance of the output capacitor
- Install crowbar stacks in place but do not yet connect them
- Disconnect output voltage dividers from highest voltage crowbar stack
- Isolate voltage dividers from ground by disconnecting the BNC connections and bottom resistors from ground
- High-pot each crowbar stack individually to 25 kV and record leakage current.  Verify these numbers match the readings taken in the shop
- High-pot each voltage divider and verify their resistances are the design values of .
- Reconnect the voltage dividers to ground and to the BNC connections.
- Connect the buswork to the crowbar stacks and connect to the bushings to the main tank.
- Connect the fiber optic trigger cables to the thyristor triggers
- Verify all connections are made-up and secure
- Manually replace the cover (two-person job)
- Refill with oil
## Phase Tank

- Pump oil from the tank into a pod.
- Verify the oil appearance is good.
- High-pot the oil to ensure it has good voltage hold-off.
- Manually remove the cover (two-person job)
- Ground all metallic connections in the tank
- Disconnect the electrical gate trigger cables
- Disconnect bus work
- Remove existing stacks
- Measure and record the resistance and capacitance of each element of the snubber circuits
- Verify the location of the positive stacks, using stampings and/or other markings on the tank
- Verify the location of the negative stacks, using stampings and/or other markings on the tank
- Verify the type (positive/negative) of each stack and install it in its appropriate location.  The location of the stacks is described in Table 1.


|  | Phase Tank Head Where | Trigger Cables Enter |  |
| --- | --- | --- | --- |
| Phase Tank Wall Nearest Center of HVPS with all HV Bushings |  |  | Phase Tank Wall Nearest Outside Wall of HVPS |
|  | High Side (S2) C+ | High Side (S2) C- |  |
|  | High Side (S2) B+ | High Side (S2) B- |  |
|  | High Side (S2) A+ | High Side (S2) A- |  |
|  | Low Side (S1) A+ | Low Side (S1) A- |  |
|  | Low Side (S1) B+ | Low Side (S1) B- |  |
|  | Low Side (S1) C+ | Low Side (S1) C- |  |

Table 1:  Layout of positive and negative phase stacks
- After all stacks are installed, high-pot each stack and record the leakage currents.  Verify these numbers match those in the shop.  (We will generate some spreadsheet that has a graphic with the location of the stacks and their polarity.  Each location will have an associated box that contains three pieces of information, the leakage current of this test and the firing/not firing records of the tests below.)
- Verify that the stacks respond to the correct triggers by repeating on each of the 12 stacks:
- Use the B015 portable trigger generator for the HVPS
- Connect the generator to the thyristor trigger cables
- Connect the high-potter to the expected polarity of the stack.
- Set the high-pot voltage to 1.5 kV (~100 V per device)
- Trigger the stack to verify that the stack turns on and discharges the high-pot HV.
- Turn-off the high-potter
- Connect the high-potter to the negative of the expected stack voltage
- Set the high-pot voltage to 1.5 kV (~100 V per device)
- Trigger the stack to verify that the stack does not turn on and discharges the high-pot HV.
- Turn-off the high-potter
- Connect all of the bus work to the stacks
- Connect all of the trigger pairs to the stack terminals, ensuring that the lugs are securely screwed to each stack.  There are two identical cable bundles, one for the high side rectifier and the other for the low side rectifier.
- The color code of the trigger wires is given in WD-730-794-03-C0
- On the positive stacks, the return from each pair has a blue color and connects to the terminal located at the smaller radius (closer to the center)
- On the negative stacks, the return from each pair has a red color and connects to the terminal located at the larger radius (further from the center)
- The color codes for the trigger wires are given in Table 1

| Positive Stack | P1 (outer term) | P2 (inner term) |  | Negative Stack | P1 (outer term) | P2 (inner term) |
| --- | --- | --- | --- | --- | --- | --- |
| C+ | Black | Blue/Black |  | C- | Red | Orange/Black |
| B+ | White | Blue/White |  | B- | Red/White | White/Black |
| A+ | Orange | Blue |  | A- | Red/Black | Black/White |

Table 2:  Color code for gate triggers
- Connect the trigger bundle ground wires to the ground busses
- Reverify that all of the positive stacks are on the positive side of the tank and all negative stacks are on the negative side.
- Verify all connections are made-up and secure
- Manually replace the cover (two-person job)
- Refill with oil