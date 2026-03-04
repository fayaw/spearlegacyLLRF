# regulatorEnerproTestingNotes

> **Source:** `hvps/architecture/designNotes/regulatorEnerproTestingNotes.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## Regulator and Enerpro Work

April 4, 2022
## Regulator Board

Based on past data, we suspected that the regulator board was not functioning properly.  In previous shifts we had found that the monitor of the regulator output, TP7, stayed at an output of , independent of the HVPS output.
The regulator output combines with the output from the PLC (AB-1746-NIO4V, Slot 8, Number 1, memory register N7:11) to create the SIGHI control voltage for the Enerpro.  The PLC output connects to SIGHI through a  resistor and the regulator board output connects to SIGHI through a  resistor.  The SIGHI input of the Enerpro sees a Thevenin source voltage of

The Enerpro sees a Thevenin resistance of

The regulator output is limited by a  Zener diode, which limits the positive output value at  and the negative output value at .  Based on the voltage setpoint sent by the control system, the PLC generates a voltage based on the scaling of .  The PLC adds a programmable offset to this value.  The previous value of the offset was .  With this setting, at the higher desired HVPS output values, the PLC voltage exceeded the required SIGHI, so the regulator saturated at its lower diode limit.  Reducing the offset from  to  counts lowered the voltage from the PLC by , which, in turn, enabled the regulator to operate between , well within its linear range.  Figures 1 – 3 show the values of the contributions to SIGHI for various HVPS output voltages before and after the offset was adjusted.  Note that the range of SIGHI for the Enerpro is likely .

Figure :  PLC DAC counts used to control Enerpro SIG HI

Figure :  Regulator board output control

Figure :  HVPS output voltage vs SIG HI with contributions from PLC and regulator board
## Enerpro Timing

We monitored various test points on the Enerpro board in order to better understand its timing and operation.  We had to set the hold-off on the scope to  in order to lock the CK1 signal from TP4.






> **Note:** This document contains embedded images that cannot be directly converted to text.
> Please refer to the original DOCX file for visual content.
