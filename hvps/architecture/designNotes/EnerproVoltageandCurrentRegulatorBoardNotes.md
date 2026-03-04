# EnerproVoltageandCurrentRegulatorBoardNotes

> **Source:** `hvps/architecture/designNotes/EnerproVoltageandCurrentRegulatorBoardNotes.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## Enerpro Voltage and Current Regulator Board Notes

## Introduction

SLAC has designed a common regulator board, SD-237-230-14-C1, to interface with Enerpro thyristor gate firing boards.  The SLAC board is designed to work as either a current or voltage controller.  This note documents the operation and characteristics of the regulator board.
## Primary Components

The board uses several types of analog components in the circuit.  This section summarizes their descriptions and characteristics.
### INA117

The INA117 is a high performance, unity gain difference amplifier with a high common-mode input voltage rejection.  It can operate at common mode voltages of up to 200 V.  Its nominal differential input impedance is .  Any resistances in series with the inputs degrades its differential accuracy in high common-mode environments.  The INA117 uses a +/-15 VDC power supply and will output voltage up to +/-10 VDC.  It has a -3 dB bandwidth of 300 kHz.  The input-output equation for its standard application is .  In general, pins 1 and 5 should be connected to ground (8).  The chip is manufactured by Texas Instruments (TI) and is available in DIP and SOIC packages.
### 1NA114

The INA114 is another high performance instrumentation amplifier from TI.  Its architecture is three operational amplifiers with laser-trimmed resistors in a single package.  It does not have the common-mode rejection of the INA117 and cannot operate at nearly the common-mode voltages of the INA117, but it has a gain adjustable with one external resistor and a gain bandwidth product of 1 MHz.  Its input impedance is .  It is available in DIP and SOIC packages.
### OP77

The OP77 is a very high performance, with respect to offset and noise, opamp with a gain bandwidth product of 600 kHz.  It is manufactured by Analog Devices and is still commercially available in many packages.
### BUF634

The BUF634 is a high speed, high current output buffer amplifier from TI.  It has settable 3 dB bandwidths of either 30 MHz or 180 MHz and can continuously output 250 mA.  It has input offset voltages measured in the tens of mV, so its primary purpose is to be included in a feedback circuit with a high performance opamp that compensates for the errors of the BUF634.  Some versions of this chip, including DIP packages, are still commercially available, but TI recommends that new designs migrate to the upgraded version BUF634A.  The BUF634A has higher bandwidth, higher output current, and faster slew rate.  It does not come in a DIP package.  
### MC34074

The MC34074 is a good, general purpose quad amplifier that is made by ON Semiconductor.  It has a gain bandwidth product of 4.5 MHz and can work from a single supply.  The chip is still commercially available in surface mount packages.  (A comparable, but with perhaps slightly lower specifications, is the TL074 from TI.  This chip is commercially available in DIP packages.)
### 4N32

The 4N32 is an optocoupler from Vishay.  Its turn-on time is 5 us and its turn-off time is 100 us.  It is commercially available from Vishay and other sources.
### VTL5C

This is an obsolete opto-controlled variable resistor that changes its resistance from MOhms to kOhm.  The response time for this change is measured in ms to get to the low resistance and 150 ms to return to the high resistance.
### CD4044B

The CD4044B is a CMOS quad Reset/Set three state latch.  In addition to Reset and Set inputs for each of the four gates, there is a common enable for all of the latches.  A logical zero on the enable makes all four outputs open circuit.  A logical one on the Set input drives the Q output to a logical zero.  A logical one on the Reset input drives the Q output to a logical one.
### 1N3064

The 1N3064 is a small signal silicon switching diode.  It is currently obsolete.  Digikey recommends the Vishay 1N4150 as a replacement.  Vishay lists the BAW27 as the direct replacement for the 1N3064; this device has a slightly larger voltage drop for equivalent forward currents.  Both of the Vishay diodes are readily available.
### 1N4728, 1N4740, 1N4742, 1N4747

The 1N47dd is a family of Zener diodes made by Vishay.  The clamping voltages of these particular diodes are 1N4728 = 3.3 V, 1N4740 = 10 V, 1N4742 = 12 V, and 1N4747 = 20 V.
### MAD4030-B

The MAD4030-B is an obsolete  DC-DC converter, formerly made by Astec, since acquired by Artesyn.
## Operation of Circuit

At its most basic, the regulator card has two primary analog inputs, one for the negative output voltage and the other for the positive output current.  These signals are processed through identical signal processing chains and are then “combined” through a non-linear diode “summing junction” in which the anodes of two diodes are connected together.  The lower of the two voltages into the diode cathodes will determine the common anode voltage, which determines the control voltage sent to the Enerpro board.  The current from a  power supply through a  resistor ensures that the diode conducts.  The anode voltage of the diode is limited by a  Zener diode.
### Voltage Reference Input

The voltage reference set point is sourced from Output 0 of the AB Slot-8 module.  It is connected across J4-1 and J4-7 of the common regulator board.  On the trigger enclosure wiring diagram these signals are named the Reference Voltage and the Common.  (Note, however, that on the common regulator board schematic, the Reference Voltage is somewhat confusingly called the Positive Voltage Limit Command.)  The reference voltage goes into the negative input of a INA117 difference amplifier, so the difference amplifier output is a negative voltage.
The output goes through a trim resistor and then a  fixed resistor, likely to try to match the fixed  resistor coming from the voltage readback path.  This negative current is one input into the summing junction of an OP77 opamp used as an inverting error amplifier. Since the error amplifier inverts, its output is then a linear function of the difference

as will be shown in the high voltage readback section below.
#### Test Point

TP9 is the test point that measures the inverted input of the voltage reference.
### High Voltage Readback

The inputs to the Negative Voltage Sense on J1A and J1B are sourced from voltage dividers shown in the  WD-730-792-01 section of WD-730-794-04.  This shows that the two voltage dividers each have five  resistors in series before two  resistors in parallel create an equivalent single  resistor.  The voltage across this  resistor pair is the input to the regulator board.  We must also include the impedance of the sensing circuit.  This includes the  load resistor, the  capacitor, and the  differential input impedance of the INA117.  This resistance is dominated by the load resistor.  Therefore, to the voltage divider, the load looks like a parallel combination of a  resistor with a  capacitor.  To the load on the board, the divider looks like a  resistor.  Because of this relatively high source impedance, the output voltage strongly depends on the load impedance.  Therefore we view the voltage divider, to a very good approximation, as a current source with a current of  and a parallel output impedance of .  This current then gets shared across the load at a ratio of about , so that 98% of the DC current goes across the  load resistor.  I do not know why the value  was chosen over the value of , which would give a calculated input voltage value closer to .  With this resistance, the maximum input voltage would be .
The parallel combination of a  resistor with a  capacitor is a low pass filter with a time constant of .  This translates into a corner frequency of .  We will measure the resistance seen from the voltage input across J1-1 and J1-2; this should match the values given in the schematics referenced above.  For completeness we should also measure the capacitance seen across these lines, although it likely negligible in the behavior of the circuit.  The signal is brought in via a Belden 88761 shielded twisted pair cable with a nominal capacitance per foot of .  In order for the capacitance of the input line to be comparable to that of the  capacitor, the line would need to be about  feet long, so this capacitance can likely be neglected
The transfer function for the input circuit, between the output of the HVPS and the output of the difference amplifier is

where , where we have rounded the value of  to .  The DC value of our transfer function is , as expected.  This  scale factor is what we used in the above section.
The INA117 is used as the input amplifier since it is a high-performance difference amplifier that can handle inputs with a common mode input range of up to  and also has a very high common mode rejection ratio (CMRR).  Since the input appears to the INA117 as a current source, a compensating resistor needs to be placed in the input circuit to keep the impedance of the INA117 balanced (refer to Figure 4 of the INA117 data sheet) which, in turn, maintains the high CMRR of the device.  In our application, since the output of the HVPS is negative, the Return signal to the voltage divider is more positive than the Negative Voltage Sense.  The inverting input of the INA117 is connected to the low impedance Return via the  load resistor, so a matching  load resistor is used to connect the non-inverting input to Return as well.
#### Test Point

TP4 is the test point that measures the inverted voltage difference of the negative voltage sense.
### Error Amplifier

#### Transfer Function

The output of the high voltage readback difference amplifier is input to three other sections of the board.  The most important output of the difference amplifier is one input of the summing junction of the OP77 inverting error amplifier.  The resistances between the difference amplifiers and the summing junction are nominally equal, so the input current into the summing junction is .  The frequency dependent impedance between the inverting input and the output of the error amplifier is

where we have used the fact that .  The frequencies corresponding to this zero is  and the frequencies corresponding to the two poles are  and .  Since the input impedance to the summing junction from the difference amplifier is , the total transfer function due to the error amplifier is

In order to obtain the total transfer function from voltage monitor through the error amplifier, we also need to include the input low pass filter.

where, again, we have rounded the value of the input load resistor to be .
#### Analysis

The transfer function describes a Type 1 system since it includes a pure integration term, ; there will be no steady state error between the set point and the readback.  The integrator gain, also known as the ramp error coefficient, is defined as .  For the existing system, from the HVPS output to the error amplifier output, this gain is

The integrator gain sets the response time and stability of the system at very low frequencies, approaching DC.  As the frequency of interest increases, the gain due to the integrator,  decreases at 20 dB per decade.  If we are satisfied with the steady state performance of the HVPS, we likely do not want to change the integrator gain.  However, we should complete a simulation of the entire circuit to determine our optimal parameters.
In addition to the integrator pole at DC, the total transfer function has one zero and two additional poles.  The larger of these poles is at , well above any disturbance frequencies that we expect to see or that we can control.
It is curious why the zero introduced by the feedback impedance was not chosen to cancel the pole introduced by the input filter.  That choice would have simplified the transfer function.  I do not know of any disturbance sources between  and  for which this difference would compensate.
The system transfer function gain stops its decrease at the transfer function zero  and then starts to level off approaching a value of .  It never reaches this asymptote because another pole at , only an octave in frequency higher, causes it to resume its 20 dB per decade decrease further.  It decreases at this rate until  after which frequency the loop gain rolls off at  dB per decade.
#### Test Point

TP5 is the test point that measures the output of the inverting error amplifier.
### Voltage Monitor

Another output of the high voltage difference amplifier is the input to a BUF634 output buffer that is connected through a  resistor to J3-1, which is then input to the AB Slot-8 Input 0.  This provides the readback to the control system of the HVPS output voltage.  The BUF634 is likely not the correct chip for this circuit.  It is made to drive high frequency signals to low impedance receivers, with a maximum continuous output current of .  The  resistor limits the potential maximum current to .  A side-effect of the properties of the BUF364 is that its typical offset voltage is measured in tens of millivolts, much higher than that of a standard opamp.  Something like the OP77 is a better choice for an opamp to buffer out signals to the AB inputs.  If we desire a high output current, we should use a circuit that has the BUF634 within the feedback loop of a high performance opamp so that the opamp corrects the offset and other errors of the BUF634 (see, for example, Figure 9-7 of the BUF634A data sheet).
The signal out of this buffer circuit is low pass filtered at .  If we want this monitor to display better high frequency fidelity of the voltage output, we should introduce a zero in the buffer output circuit to compensate for the pole in the input circuit.
### Overvoltage Protection

The third input is to a MC34074 opamp that is used as an over-voltage sensor.  The opamp is used as a comparator, comparing the INA117 output with a DC trip level.  Its output is connected to the Set input of a CD4044B.  The trip level can be set by a potentiometer from  to , corresponding to HVPS output voltages of  to .  We should publish the value of the desired trip level and ensure that that level is set on the board.  In normal operating conditions, the output of the MC34074 is railed at its maximum output DC voltage.  This positive output sets the Q output of the CD4044B to a logical zero.  We will describe the protection circuit after we have discussed the other signal processing elements of the board.
#### Test Points

TP10 is the test point that measures the threshold setting for the overvoltage protection.  TP8 is the test point that measures the output of the overvoltage protection comparator.
## Current Measurement

This board measures the average input AC phase current.  (The HVPS output current is independently measured by a Danfysik current transducer located in the termination tank.)  The phases are sensed by  current transformers (ref EI-730-790-00-C0).  The output currents of these transformers are then rectified through individual full wave rectifiers, the outputs of which are all paralleled and terminated by a  burden resistor (ref WD-730-790-01-C3).  (We should verify the value of this burden resistor.  We may be able to measure the value between terminals 1 and 2 on TS-4.)
Once the inductors have started to conduct, the line current is essentially constant during each conduction period.  The inductors are specified to have an inductance of at least  at  but may have an inductance as large as  at lower currents.  The resistance of the inductors, measured at no AC excitation, is .  At the lowest time constant , the current will decay by only  in one period of the  waveform.
The input of the regulator board has a single pole low pass filter with a time constant of , corresponding to a cutoff frequency of .  The input signal is further conditioned by a INA114 precision instrumentation amplifier set for a negative unity gain.  This output is inverted by a INA117 difference amplifier.  (I do not understand the advantage of having these two amplifiers in series.  It seems that the INA114 alone should be sufficient.  Perhaps the original design envisioned the INA114 to be used as a gain stage for several different applications, so a provision was made for programmable gain.)
Like the output of the voltage measurement amplifier, the output of the INA117 feeds three inputs.  The first input is to a summing amplifier, configured identically, both in gain and in frequency response, to that in the voltage monitoring and control signal path.  This summing amplifier could potentially provide the control voltage for the Enerpro board if its output is less positive than that of the voltage measurement summing amplifier.  The reference value used for the AC current feedback system is input in J4-2 (IL1).  This value is sourced by the regulated  voltage reference sourced by the Enerpro board.  This  is inverted and goes through a  resistance to the inverting input of the inverting summing junction.  The typical AC current measurement, as recorded in Table 1 below as the current sense from the regulator board, is about .  The total input current into the summing junction of the error amplifier for the current difference is then approximately .  The integrator in the inverting error amplifier will saturate the output of the OP77 to its typical maximum value of .  This maximum voltage is higher than the  limit set by the Zener diode at the input to the final buffer amplifier before the output to the Enerpro.  (It is likely not good practice to keep this amplifier saturated.  If one wanted to keep this amplifier in the circuit, one should place a Zener diode at its output that would limit the output voltage.  It probably is better to just eliminate this circuit which is designed to never be used in the feedback control of the Enerpro.) 
The second input goes to a current monitor, using the same BUF634 buffer amplifier, with the same advantages and disadvantages as the buffer for the voltage monitor.  The output of the buffer goes through J3-2, which is read by In-1 of the AB Slot-9 input module.  The third input goes to an over-current detection circuit, consisting of an opamp used as a comparator which is input to a CD4044B.  We should also verify that the threshold for this overcurrent is set at the desired value.
#### Test Points

TP1 is the test point that measures the output of the current difference amplifier.  TP12 is the test point that measures the inverted reference value generated by the Enerpro board.  TP11 measures the threshold setting for the over-current comparator.  TP2 measures the output of the comparator.
## Interlocks

The board provides an interlock based on HVPS overvoltage, AC mains input overcurrent, the ability to have an external inhibit (although this circuit is not connected in the existing configuration), insufficient Enerpro board control voltage, and an inhibit command from the Enerpro board.
### Inputs

#### Overvoltage and Overcurrent

Under normal operating conditions, the monitored HVPS voltage and AC mains current are below the inhibit threshold, setting the output of an MC34074 opamp, used as a comparator, to its maximum voltage rail.  These outputs are logical one inputs to the Set inputs of CD4044B gates, which then set the corresponding Q outputs to a logical zero.
#### External Inhibit

There is an available external inhibit input that is connected to an opto-coupler on the board.  With either no input or a high input (), the output of the opto-coupler is pulled up to  and provides a logical one input to a Set input of a CD4044B gate.
#### Enerpro Undervoltage

A  control voltage is sourced from the Enerpro board.  This control voltage sources the MAD4030 on-board MAD4030-B DC to DC converter that provides the control voltage for this interface board.  The inverting input of an MC34074 is set to .  When the control voltage from the Enerpro reaches about  the opto-coupler will turn on and pull down the non-inverting input of an MC34074, forcing the output of the MC34074 to its negative rail of signal ground.
#### Enerpro Inhibit Command

The Enerpro inhibit command responds to a phase loss detection on the Enerpro board.  When phase loss is detected, the Enerpro pulls its I1 pin low and sends a logical zero to pin 23 of its U3 digital control chip.  The I1 pin is connected to J4-E on the regulator board.  When there is no inhibit and the voltage is a logical one, the opto-coupler to which it connects turns on the output transistor which allows its load resistor to be pulled up to a logical one.  When I1 goes low, the opto-coupler turns off and the load resistor goes to a logical zero.
### Action of the Inhibits

The outputs of the overvoltage, overcurrent, external inhibit, and low control voltage are connected, via the common cathodes of diodes, to the inverting input of an MC34074.  The non-inverting input of this device is held at .  When none of these four inhibits is set, the common cathode is pulled down to signal ground and the output of the MC34074 rails at .  When any of those four inhibits is set, the anode of its diode is set to  and the MC34074 output goes to signal ground.
The output of this MC34074 and the load resistor of the opto-coupler from the Enerpro inhibit command are connected, via the common anodes of diodes, to a pull-up resistor that is the input to another MC34074.  When both cathodes first see logical ones, the non-inverting input of another MC34074 is charged up to  with a time constant of about  seconds.  This opamp is configured as a voltage follower.  When the output of the follower is high, the circuit does nothing.  When the output is at signal ground, three actions are taken.  Two of the actions control VTL5C variable resistors through a 1N4728 Zener diode, setting them to relatively low values.  This action greatly decreases the feedback impedance across the OP77 opamps that send integrated outputs toward the Enerpro control voltage.  The third action of the MC34074 is to pull down the cathode of three diodes connected in a common anode configuration.  This decreases the contribution of the regulator board to the Enerpro control voltage to .
#### Test Point

TP6 is the test point that measures the output of the comparator that disables the gain of the two error amplifiers.
## Enerpro SIG HI Control

The Enerpro control voltage is typically set to extend over a range of , either from , or , depending on the configuration of the Enerpro board.
As described above, the input from the current limit amplifier operates at a voltage of about  so that its voltage will be blocked by the diode at its output.  The control voltage therefore comes from the error amplifier that acts on the difference between the voltage setpoint and readback.
The output of the final buffer amplifier, , is then combined with , Out1 of Slot 8 of the PLC, to generate the input control signal for the Enerpro (SIG HI on J3-10 of the Enerpro).  These two outputs are combined with a resistive combiner.  The resistor on the regulator board is  and a  resistor is soldered in series with the wire that originates from Out1 of Slot8.  The Thevenin equivalent circuit for this combination is a voltage source 

In series with a resistance

A typical value of  so that

Since the error amplifier output can vary over the range , the error amplifier can provide a voltage swing of .  The Enerpro input circuit downstream of its SIG Hi input has an input impedance.  Including this impedance, we need to verify that the control voltage spans the desired voltage range in order to properly control the HVPS. 
#### Test Point

TP7 is the test point that measures the buffered output of the voltage error amplifier, plus a diode voltage drop, that is the contribution of this board to the Enerpro control voltage.
## Typical Operating Parameters

Marc Larrus captured analog values for the SPEAR HVPS2 supply on June 16, 2020 with 500 mA in the ring.  (Note that the readings may differ slightly from the values recorded in History.)

| Parameter | Value | Board Connection | PLC Module | PLC Input |
| --- | --- | --- | --- | --- |
| Vout | 72.08 kVDC |  |  |  |
| Iout | 19.4 ADC |  |  |  |
| IAC line | 92.0 Arms |  |  |  |
| Voltage sense from regulator board (VOLT) | 7.183 VDC | J3-1 | Slot 8 | In 0 |
| Reg phase control out to Enerpro board (SIG HI) | 4.40 VDC | J4-3 | Slot 8 | In 1 |
| Reference from Control System to regulator (EL1) | 7.159 VDC | J4-1 | Slot 8 | Out 0 |
| 2nd  Phase Control to Enerpro (through 1 kOhm) (SIG HI) | 4.4538 VDC | J3-10 (Enerpro) | Slot 8 | Out 1 |
| Current sense from regulator board (CUR) | 2.0271 VDC | J3-2 | Slot 9 | In 0 |
| First voltage monitor (EO2) | -7.164 VDC | J1-1, TS3-1 | Slot 9 | In 1 |
| Second voltage monitor | -7.187 VDC | TS3-3 | Slot 9 | In 2 |
| DC current monitor (Ground Tank)  (1V = 5A) | 3.860 VDC | TS6-1 | Slot 9 | In 3 |

Table :  Typical parameters at full load operation.


| Location | FCOG6100 Rev | FCOG6100 S/N | FCOAUX60 Rev | FCOAUX60 S/N |
| --- | --- | --- | --- | --- |
| Bad Board | K | 30045 | D | 1694 |
| HVPS1 | K | 41504 | D | 03198 |
| HVPS2 | K | 50470 | D | 03813 |
| Test Stand | K | 49845 | D (Variant?) | 03774 |

Table :  Enerpro board revisions and serial numbers.