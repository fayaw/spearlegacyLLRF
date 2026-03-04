# enerproDiscussion07072022

> **Source:** `hvps/controls/enerpro/enerproDiscussion07072022.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## Enerpro Call  July 7, 2022

## Introduction

This is a follow-up call with Saul Rivera and David Prince from Enerpro concerning the document enerproBoardHvps.docx.
## Saul’s Email Response

1.      Phase-Reference signals applied at J5 on the original FCOG6100 REV K board.
J5 position 1 (R37) corresponds to the “A” phase.
J5 position 3 (R38) corresponds to the “B” phase
J5 position 5 (R39) corresponds to the “C” phase. 

This note is in reference to the waveforms shown in figure 2 of your document as it would seem to me that the order shown in the waveform is c-b-a instead of a-b-c. This observation is meaningless if the SCRs were identified accordingly (that is, the phase reference is the same as the SCRs labeled for that leg of the circuit).  

2.      FCOG1200 REV L
Yes, the REV L is the most current revision of this board.

3.      Small adapter resistor: 3 VS 6 resistors.
It is recommended the use of an external adapter board that will include an input connector for the three high voltage inputs and one or two output connectors for the six (or three) output connections. This standard board should:
-          Keep in consideration the minimum required safe distance between the high voltage inputs
-          I would recommend that you only three resistors as it is easier to match them in value if necessary (see item 4 below). 
-          Three signals generated from three resistors will simplify future troubleshooting
-          This board can either split each attenuated signal into two to feed at J7 or Enerpro could place jumpers underneath the FCOG1200 board at J7 between positions 1and 4, 2 and 5, and 3 and 6.

4.      Enerpro recommendation for the amplitude of the signals applied at J7
All six phase references applied at J7 1-6 (eAx, eBx, eCx, eAY, eBy, and eCy) must be biased to 5 volts by RN5and RN6 and the peak to peak voltage of the attenuated signals must be within 0-10 volts (preferably between 1 and 9 volts making the maximum recommended peak-to-peak amplitude voltage 8 Volts, and a minimum peak-to-peak amplitude of 1-1.5V. This part of the circuit is very forgiving as the range is relatively simple to achieve with three standard attenuator resistors as indicated in item 3 above. The amplitude of these signals is not critical as long as:
-          All six waveforms have a maximum of 8Vp-p and a minimum of 1Vp-p
-          All six waveforms are biased to +5V
-          All three waveforms per bridge (“X” or “Y”) must have the same amplitude with a maximum of 20-15% of each other to prevent a phase loss detection.
-          The two groups of  3 waveforms per bridge (one group is the “X” set of references and the second group is the “Y” set of references) must be within 20-15% of the amplitude of the other to prevent a phase loss detection.

5.      Header J7 (mating connector):
Connector: P7                          Enerpro P/N  C2MTAPLG08                        
                                                TE CONNECTIVITY 3-640440-8
Connector P7 COVER             Enerpro P/N C2MTACVR08 
                                                TE CONNECVITY P/N C2MTACVR08 
Note: Both connector P7 and its cover are provided by Enerpro in the accompanying connector pack for this board. 

You will need however a MTA applicator in order to crimp wire to this connector. This is one of the hand-tools recommended by TE Connectivity: P/N 58074-1
<https://www.te.com/usa-en/product-58074-1.html> https://www.te.com/usa-en/product-58074-1.html

6.      Information about the EP1016 high gain analog comparators?  Bias level of these comparators?

Yes, the RC filters for the attenuated and shifted phase references are fed into the same switches and then into six op-amps acting as comparators. The comparators don’t have a built-in bias, they just rely on the +5V bias of every signal being compared.

7.      Acceptable amplitudes of the AC sine waves.
Please refer to item 4 above.

8.      EP1016 Outputs
The ideal output of the EP1016 is a set of six  0-12V square waveforms with the same frequency as the inputs (50% duty-cycle) with the same phase as the corresponding inputs.

9.      C31 & Bandwidth
Most of our customers don’t use C31 at all, therefore you should be fine if this component is not installed in your board. I will check what the expected bandwidth should be for this board without C31. 

10.  Vco gain. 
The Vco gain should still be the same between the two boards. I will investigate this within engineering and I will inform you as soon as I have the answer.

11.   SIG HI input impedance (FCOG6100 REV K VS FCOG1200 REV K or REV L).
Note that in the FCOG1200 REV K or REV L board the input circuit for SIG HI is divided into two parts, the first one is similar to the FCOG6100 REV K  (R40=R41, R26=R49, and C31=C35) although in the FCOG1200 board C31 is after R26 (not before as in the FCOG6100 Rev K) but then this signal is fed into a buffer at U8C.  R47 in the FCOG1200, just like R49 in the FCOG6100, is then fed into the inverting input of U7D, held also at +5VDC.  

12.  SIG HI range . maximum and minimum voltages

The FCOG1200 board has a maximum input domain of 0-6VDC, in this board we don’t have a 6.2V as in the latest FCOG610 REV R. but I would recommend that you keep the voltage level of your regulator from either 0.85-5.85V, or absolute maximum of 0-6 V or 0.85-6.2V. 


Also, please consider the 5 attached waveforms that I would like to discuss with you and David over the phone next week. These waveforms were recorded using the FCOG1200 test bench in the lab, where:
-          AC 3-phase input voltage: 480Vac (495Vac measured at the time they were taken)
-          AC 3-phase line to line voltage Delta bridge: 220Vac
-          AC 3-phase line to line voltage Wye bridge: 220Vac
-          External attenuator resistors: 2- Meg Ohms.

Oscilloscope graphs:
#1        Ax-Bx input voltage (before attenuation), along with eAx (J7 pos 1) and eBx (J7 pos 2). Please note that I do have the same sequence as the one you reported in your word document.
#2        eAx (J7 pos 1) , eBx (J7 pos 2), and eCx (J7 pos 3)
#3        eAx (J7 pos 1) and eAy (J7 pos 4)
#4        eAy (J7 pos 4) , eBy (J7 pos 5), and eCy (J7 pos 6)
#5        Ay-By input voltage (before attenuation), along with eAy (J7 pos 4) and eBy (J7 pos 5)

## My Comments to Saul’s Email

- We use two quadrant, twelve pulse gating.  We have a schematic for E128 Rev I that includes P1 and P2 connectors for the first six pulses and P9 to connect to FCOAUX60 for the other six pulses.  In verifying our phase rotation in our existing system, should I set my oscilloscope reference to J5-1 and then measure U4 8 – 13 (or J8) and then U4 34 – 29 (or J9, if I can access it)?  I realize that we are likely missing the 15 degree phase rotation in this setup, but at least we can document the phase rotation.

This is correct.  One can also probe connectors J8 and J9, if those are accessible (J8 certainly should be).

How do we map J1 – J4 of the FCOG1200 to the connectors from the FCOG6100?  J1 and J2 to J1 and J2 and the two connectors from the FCOAUX60 to J3 and J4?

Yes
- We can design the adapter board so that Enerpro does not need to place any jumpers on their board.
- By just changing the bias resistors, do you have a solution that will keep both the amplitudes and offsets of the 45 degree lag and 75 degree lag signals?  Or do we need to build this circuitry in our external board?

EP1016 is a custom chip made of six identical input stages followed by two identical circuits that act on the two trios of the x and y phases.  The input stages are composed of a series resistor to limit input currents, and then high gain opamps.  The secondary circuits contain three comparators between the A, B, and C phases of each trio.  One comparator is high when , the second when , and the third when .  The purpose of the chip is to have the  digital output signals positive when each of the above conditions is satisfied.  See figures 3 and 4 of the Operating Manual: Twelve-SCR General Purpose Gate Firing Board FCOG1200 Revisions F or K, Enerpro Document No: OP-0111; Rev. C.  These outputs should ideally have a  duty cycle.  If so, the phase loss circuit will see an input as shown in figure 1 of OP-0111.  If not, the input will look like figure 2 and the phase loss circuit will trip.  The 220 pF capacitors going across EP1016 are used to provide hysteresis in the internal comparator circuits.

As stated above, the comparator circuits within EP1016 just deal with either the X or Y phase trios.  Therefore, our goal in producing the  and  phase lags are to ensure that the amplitudes and phases within each trio are identical.  All six amplitudes and phases do not have to be equal.  EP1016 ranges is operated between ground and a 12 VDC supply.  In order to keep EP1016 safely within its operational range, we want the inputs at pins 2 – 7 to be between 1 V and 11 V.  In order to maximize the noise immunity of our system we want the AC amplitude at the input pins to be as large as possible.  I will calculate the values of the input resistors needed to keep the inputs between 1 V and 11 V.

We do not need to worry about the voltage levels that we bring in on J7.  The 5 V reference voltage is generated by an MC34074 opamp capable of operating on a single supply.  David said that for any reasonable voltage, even hundreds of volts, there is no potential to damage the MC34074 as long as a resistor limits the current to the chip.  Even if we input 100 V, close to our maximum available voltage, at the  resistor, the current would be limited to .  Googling around I found estimates of  as safe values for opamp inputs and outputs.  I will limit the voltage so that it is far below 75 V.
- Please explain your answer.
- Do you recommend a 1 kOhm resistor in series with a standard 5% 6.2V Zener in our output circuit?  What family of zeners do you use to replace the mature 1N5341B?

The Enerpro considers signals between 0.8 V and 5.8 V to be valid.  We will drive the SIGHI signal with an opamp that can exceed those limits, but will not be able to exceed .  David does not think that any Zener is required to limit our input circuit if we generate such voltages.  We will not damage any electronics on the Enerpro.  All input signals first pass through R26 before reaching the non-inverting input of the U8C MC34074.  This signal would not damage the chip as the  resistor would limit the current to .  The Enerpro will also still properly function, in the sense of not behaving badly, even if the SIGHI is outside of its operating values.  If SIGHI is at -15 V, U8C can only generate an output voltage of 0.1 V, so the output of the Buffer Amplifier, U7D, is ideally 12.7 V, but likely limits to about 11 V because of the limitations of the MC34074.  If SIGHI is at +15 V, the output of U8C is limited to about 11 V and the ideal Buffer Amplifier output is -10.4 V, but the MC34074 limits this value to 0.1 V, so the system will still work.

All of the dynamics of the Enerpro loop is given by the circuitry visible between SIGHI and the output of the PLL Summing Amp.  (Note that the nominal VCO gain and phase shifting output of the EP1014 and EP1015 are assumed.)  I need to calculate these dynamics and adjust my loop gain to include these dynamics.  David also suggested that we not eliminate C31, but instead give it a small value that provides some protection against fast transients.  For example,  gives a  bandwidth of  to the input value.  I will likely reduce this bandwidth.