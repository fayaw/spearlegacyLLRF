# hoffmanTestingNotes

> **Source:** `hvps/architecture/designNotes/hoffmanTestingNotes.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## Test of Hoffman Box, Enerpro, and Regulator Board

## Enerpro

We have several versions of the Enerpro schematic.  We have Rev. R of the FCOG6100, E0128R, and Revs. F, K, and L of the FCOG1200, E640K.  The former is made for a six pulse rectifier and the latter for a twelve pulse rectifier.
We use as reference the SLAC WD-730-790-02-C6.  We want to locate and measure on the Enerpro
- The entrance of the external phase references.  These enter on J5, pins 1, 3, and 5.  These are sourced from 120 VAC instrument transformers T0A and T0C, as shown on WD-730-794-05-C3.  The location of these transformers is shown on EI-730-790-00-C0.  The FCOG1200 may be designed to use the phases from the two open star transformers to give the correct phasing for all 12 SCRs.  Can we work with the FCOG1200 to just use the three phases we already have and not use the other six?  Do we have the other six phases from the open star transformers available?  If we use them, do we give up some diagnostics that we need or are useful?
- Verify voltage amplitudes and waveforms for these other signals
- We also want to verify the order of the phases and the relative phase shifts between the various signals, using the A phase, TS-7 1, as the reference.  This is also the reference for J5-1 on the Enerpro and AB Slot 3, Input 1.
- Determine how the Enerpro signals get to the daughter board for the 30 degree delayed triggering.  This is the main change we would have to make to the circuit if we want to replace the existing pair of boards with the FCOG1200 board.  Or do we need to continue to use the FCOG6100 and the FCOAUX60?
- See if we can get to various test points on the Enerpro without having to remove any conformal coating.  Interesting test points are
- TP1 for response of input
- TP2 for input to PLL
- TP3 for delay output (TP7 and TP12 for FCOG1200 board)
- TP5 for attenuation and phase shift
- TP6 for AD?
- TP8 for phase loss (TP15 and TP16 for FCOG1200 board)
## Regulator Board  SD-237-230-14-C1

- The voltage readback is J5.  The shield of J5 is directly connected to the shield of the return line.
- TP4 is the buffered voltage readback isolated by a 1 kOhm resistor.
- J3A has another buffered version of this signal.
- TP5 is the output of the error amplifier.
- J6 is the (AC?) current readback.  The shield of J6 is directly connected to the return line from the current readback.
- TP1 is the buffered current readback isolated by a 1 kOhm resistor.
- J3B has another buffered version of this signal.
- TP3 is the output of the error amplifier.
- TP10 is the overvoltage trip setting of the board.
- TP11 is the overcurrent trip setting of the board.
- TP9 is the test point to monitor the voltage input set point.
- TP12 is the test point to monitor the current input set point.
- TP7 monitors the output sent to SIG HI of the Enerpro through a 7.5 kOhm resistor.
For normal monitoring we would like to change the voltage setpoint through EPICS, then monitor and trigger that setpoint on TP9, while we also monitor the SIG HI command on TP7 and the voltage readback command on TP4.  We may also monitor either TP1 or TP3 to understand how these signals behave.
We should perform several step changes at various output voltages to see how the behavior changes for small steps at the various normal operating points.  Hopefully it will be sufficient to do this with EPICS commands.  We could set up a software loop with an appropriate period, that would create a square wave to generate this step function.  If this is unsatisfactory, we would have disconnect EL1 and apply a function generator at that point. 
We also would like to capture the startup of the supply under normal conditions, turning the HVPS on from EPICS.  This will tell us the startup times.
We should verify the current limit IL1 command on TP12 and TP3 to ensure that we are far from using this path to control the feedback loop.
## Monitor Board  SD-730-793-12-C3

Since the Monitor Board is not included in the Trigger Enclosure Wiring Diagram, WD-730-790-02, we should trace out the connections so that we can updated the wiring diagram.
- BNC1 is the isolated output of the second voltage monitor.  We should cross-calibrate it with the readings from TP4 on the Regulator Board.
- BNC2 is the isolated current output (from the Danfysik?).
- J2H and J2G are the outputs of the reference voltage.