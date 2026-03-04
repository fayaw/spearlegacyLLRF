# spear3HvpsHazards

> **Source:** `hvps/documentation/procedures/spear3HvpsHazards.pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 14


---
## Page 1

SPEAR3 High Voltage Power Supply Hazards
J. Sebek
March 7, 2023
1 Introduction
This note documents the hazards in the SPEAR3 high voltage power supply (HVPS) and
then addresses the discharge of potential stored energy in the system. The high level
specifications of the HVPS can be found in the specification for the supply [1], although
not all details of the HVPS design are contained in that document. Using this note as a
reference, a procedure can be developed to safely measure zero voltage both on the HVPS
output and also its internal components, if required. The requirements for dealing with
potential electrical hazards, although not discussed in this document, are given in the latest
version of the National Fire Protection Association (NFPA) 70E standard [2].
2 HVPS Architecture
The purpose of the HVPS is to provide direct current (DC) power to a 1.5MW klystron.
The source of its input power is the three-phase 12.47kV RMS line. The HVPS is rated to
output up to −90kV, 27A, or 2.5MW of power to the klystron. Figure 1 gives a high level
schematic of the HVPS.
The power supply specification gives 350kVA as the rating for the input phase-shifting
transformer. However this number does not seem to be correct, especially since the output
rating of the power supply is 2.5MW. A figure in the specification gives the input power
rating of the source as 2.5MVA and the rating of each of the two rectifier transformers as
1.5MVA each. Figure 1, a later HVPS schematic gives the input power rating of the source
as 3.0MVA. Based on these other numbers, I assume that the number given as the rating
inthespecificationlikelyisatypographicalerrorthathasamissingzero. Ithereforeassume
that the correct rating of the phase-shifting transformer is 3.5MVA. For this rating, the
full load current for each phase is
3500
I = √ = 162A. (1)
Φ
3·12.47
Thephase-shiftingtransformerisanextendeddeltaconfigurationthatcreatestwothree-
phase waveforms from the 12.47kV RMS line, one advanced by 15◦ and one retarded by
15◦. Each has a phase-to-phase amplitude of 12.91kV RMS. (The specification also carries
along the error of using 12.47kV RMS instead of 12.91kV RMS, even though the correct
value of the shifted voltages is shown in a figure in the specification. The specification does
give a tolerance of ±5% in all voltage ratings and this difference is within that tolerance.
We will use the value of 12.91kV RMS in our calculations in this note.)
1


---
## Page 2

Figure 1: High level schematic of HVPS and klystron.
2


---
## Page 3

Thephase-shiftedwaveformsareappliedtotheprimarylegsoftwoopenwyetransform-
ers, labeled T1 and T2 in Fig. 1, each rated at 1.5MVA. Each of these transformers feed
two wye secondaries. Both of the T1 secondaries, T1-S1 and T1-S2, have phase-to-phase
voltages of 21.0kV RMS. One of the T2 secondaries, T2-S1, also has a voltage of 21.0kV
RMS, while the other, T2-S2, only has half of that voltage, 10.5kV RMS.
Each open wye primary feeds a six-pulse thyristor rectifier stack. The load of each of
these stacks is a 0.3H inductor. No individual thyristor can hold off the required voltage
from the open-wye primary. Therefore each thyristor stack is comprised of 14 individual
Powerex T8K7 thyristors. There are energy storage devices, capacitors, that are associated
with these stacks. Each thyristor has a 0.047(cid:181)F capacitor in a snubber across it and each
stack has an additional snubber with a 0.015(cid:181)F capacitor.
The four secondaries of the two transformers feed rectifiers that convert the voltage to
DC. Each secondary has a main output which feeds its main diode rectifier stack. The
secondary also has a tap set at 105% of the main output. This tap feeds an 8(cid:181)F capacitor
that, along with a pair of 500Ω series resistors, filters out some of the output HVPS ripple.
Not shown in Fig. 1 is a 0.22(cid:181)F capacitor across the output.
3 Potential Electrical Hazards
3.1 HVPS Input
The input power to the HVPS is three phase AC line with a phase to phase voltage of
12.47kV RMS. Nominal rated maximum current is 162A, although typical input current
is about 113A. This voltage is entirely contained within the metal enclosed switchgear,
which is the responsibility of the facilities and operations group. All work performed on
this switchgear is performed by them.
3.2 HVPS Output
The output power of the HVPS can range to −90kV, 27A, although its nominal value at
full 500mA SPEAR operation is −74.7kV and 22.0A.
3.3 Control Power
The HVPS and its associated switchgear has two sources of control power. DC control
power, at 125VDC is used for control of the local contactor controller in the switchgear.
This power is sourced from Substation 507. In addition to providing power for its internal
logic, the controller uses this voltage for part of its local machine protection system (MPS)
to ensure that there has been no excessive pressure in the transformer main tank, the main
tank oil temperature is at an acceptable level, and the low conductivity cooling water is
flowing through the appropriate oil cooling radiators.
Three phases of 208VAC control power is used in the HVPS. One phase is used to
provide power for the contactor controller, another phase is used to power the oil pump
inside of the main tank, and the third phase provides power to the light used to illuminate
the switchgear compartment.
3


---
## Page 4

3.4 Trigger Pulses
The HVPS controller sends trains of 16(cid:181)s pulses in 15◦ bursts to fire the thyristors in the
phase control stacks. The amplitude of the first pulse is 240V; the amplitudes of the later
pulses are 120V. Similar voltages are used to fire the crowbar thyristors in the event of a
potential arc in either the klystron or the HVPS output.
3.5 HVPS Stored Energy
3.5.1 Filter Inductors
EachoftheHVPSrectifertransformershasaninductorthatisfedbyandfiltersthecurrent
from the thyristors in the open wye primary. The inductance of each inductor is 0.3H and
its full load current is 85A. The stored energy in each inductor is
(cid:18) (cid:19)
1 1
E = LI2 = 0.3(85)2 = 1084J. (2)
L
2 2
3.5.2 Phase Control Thyristor Stack Snubber Capacitors
Each rectifier transformer open wye primary has six phase control thyristor stacks. The
phase to phase transformer voltage is 12.91kV RMS. The maximum voltage on any of the
snubber capacitors is therefore
√
V = 2·12.91kV = 18.26kV. (3)
max
Each stack as an R-C series snubber circuit in which the capacitance is 0.015(cid:181)F. The
largest amount of stored energy in any of these capacitors is
(cid:18) (cid:19)
E = 1 CV2 = 1 0.015·10−6(cid:0) 18.26·103(cid:1)2 = 2.5J. (4)
C
2 2
Notethattheinstantaneousstoredenergyisdifferentineachsnubbercapacitor. Thevoltage
drop across each capacitor will be different, ranging from zero in the conducting legs of the
bridge to the maximum value given in Eqn. 4.
Eachofthefourteenthyristorsineachstackhasa0.047(cid:181)Fsnubbercapacitor. Assuming
equal voltage sharing across the thyristors, the maximum energy stored in each of these
snubber capacitors will be
(cid:18)
1
(cid:19) (cid:18) 18.26·103(cid:19)2
E = 0.047·10−6 = 40mJ. (5)
C
2 14
3.5.3 Main Filter Capacitors
The output section of the HVPS includes a filter, discussed on page 3 in Section 2. The
total stored energy in these capacitors, at full DC voltage, is
(cid:18) (cid:19)
E = 1 8·10−6(cid:0) 3·262+132(cid:1) 106 = 8788J. (6)
C
2
4


---
## Page 5

(Note that there is a small, 6%, error in the stored energy calculation if one approximates
this circuit, for the purpose of modeling the discharge time constant, as four equal stages.
In that case
(cid:18) (cid:19)
E = 1 2·10−6(cid:0) 912(cid:1) 106 = 8281J. (7)
C
2
instead of the value calculated in Eqn. 6.)
3.6 Additional Output Filter Capacitor
Not shown in Fig. 1 is an additional 0.22(cid:181)F filter capacitor across the HVPS output. The
stored energy in this capacitor is 911J.
3.7 Output Cables
The output cables used to carry the HVPS to the klystron are Mil-C-17/81-0001 cable,
formerly known as RG 220. Their capacitance per unit length is listed as either 103pF/m
for Mil-C-17/81-0001 or 101pF/m for RG 220. The cable lengths from the HVPS to the
transfer tank is about 10m and that from the transfer tank to the termination tank is
less than 50m. At full output voltage, the stored energy in the cables is about 4.2J and
21J, respectively. The total stored energy in all of the output capacitance is approximately
9824J.
4 Discharge of Stored Energy
Before working on the HVPS we must ensure that we have both eliminated any input
sources of energy and have discharged any stored energy within the supply. This section
discusses the engineered methods used to discharge the various elements that store energy
and measures and/or calculates the appropriate time constants of the circuits and the
times until the voltages of the capacitors are below the hazardous levels. We will discuss
the various discharge time constants for normal, controlled turn-offs of the HVPS as well as
for those for abnormal turn-offs of the HVPS where there may be some unexpected system
failure.
4.1 Normal HVPS Shutdown
Byfar,mostoftheshutdownsofthehighpowerradiofrequency(RF)systemandtheHVPS
are as designed, even if the cause of the shutdown is not desired. The normal situation
occurs when the RF system is operating as designed and there is a request to turn off the
RF system. The source of the request can be programmatic; operations wants to dump the
SPEAR electron beam. Or the source can be a request from either the SPEAR personnel
protection system (PPS) or either the RF or SPEAR machine protection systems (MPS)
because a system fault has been detected. In both of these cases there is a well-defined turn
off procedure. The beam is dumped and the RF station turns off. When the station turns
off, it instructs the HVPS controller to turn off the HVPS output. The controller removes
the triggers from the phase control thyristors in a manner that both discharges the stored
current in the filter inductors and prevents further voltage from being impressed on the
secondaries of the rectifier transformers.
5


---
## Page 6

4.1.1 Filter Inductors
As described above, there is an 0.3H filter inductor in the center of each of the wyes of the
two primary rectifier transformers. When the HVPS controller is commanded to turn off
the HVPS, it removes the thyristor firing triggers from all but the B+ and B− stacks of the
thyristor bridge.
This action servers two purposes. First, it disables the rectification function of the
thyristor bridge. Second, by latching on the thyristors in the B+ and B− stacks, it provides
a short circuit path in which the stored current in the inductors can flow and dissipate.
Figure 2 shows the inductor voltage during a beam dump. One can see the inductor
voltage discharge while the B stacks are conducting. The voltage reaches its final zero
value after about 10ms. This discharge time is significantly less than the time constant
calculated from just the 0.38Ω resistance of the inductor. The additional resistance of the
thyristors intheirconductingstate isresponsiblefor thedecrease intheL/R timeconstant.
The discharge through the thyristor stacks also discharges the stored energy on the snubber
capacitors in these thyristor stacks.
inductor monitor for beam dump on 20220523054817
8
6
4
2
)
V
(
r 0
o
t
in
o
m -2
r
o
t
c -4
u
d
n
i -6
-8
-10 inductor 1
inductor 2
-12
-0.09 -0.08 -0.07 -0.06 -0.05 -0.04 -0.03 -0.02 -0.01 0 0.01
time (s)
Figure 2: Measurement of the filter inductor voltage when the HVPS turns off.
6


---
## Page 7

4.1.2 Output Capacitors
The devices that connect stored energy directly to the output are the capacitances of the
outputfiltersandcables. Duringnormaloperationthisenergyisquicklydissipatedthrough
the klystron. The Child-Langmuir law gives the non-linear relation between the cathode
voltage and current as
3
I = P ·V 2 (8)
where I is the beam current, V is the beam voltage, and P is the perveance of the cathode
which,fortheSPEAR3klystronisabout10−6. Wenumericallysolvethenon-linearequation
(cid:18) (cid:19)2
q
= R
dq −P−2
3 −
dq 3
(9)
C dt dt
where q is the charge on the capacitor C = 2(cid:181)F, R = 1000Ω is the resistance between
the capacitor and the klystron, and P is the perveance of the klystron. The result, plotted
in Fig. 3, shows that the output voltage decays below 50V within 250ms. This time is
consistent with the observed voltage decay out of HVPS when the system is turned off, as
shown in Fig. 4.
4.1.3 HVPS Output Voltage
Even when the RF station and its HVPS are turned off, the HVPS output with the normal
klystron load is about 1.3kV and not zero volts. Even with the phase control thyristors
not firing, there is still some leakage from the primary to the secondary of the rectifier
transformers that is rectified by the output rectifiers. The control system is able to measure
this voltage. It can be seen live on the local controller and/or EPICS displays; the voltages
are archived in the History buffers.
Figure5plotstheHVPSvoltageandcurrentduringanormalturn-offoftheRFsystem.
At 20:07 the RF station was turned off. The HVPS output voltage and current data, each
sampled every two seconds, show that they both decreased from their operating voltage
to near zero together as the HVPS was turned off. Note that the measured HVPS output
voltage is about 1.3kV. This shows that our voltage diagnostic is still accurately measuring
the output voltage after the station is turned off.
Most unexpected beam losses are caused by transient errors. There may be a dip in the
input 12.47kV RMS voltage, a magnet power supply may trip, there may be a ring vacuum
fault, etc. In these cases the goal is to refill beam as quickly as possible. Once the transient
fault is cleared, beam will be reinjected into SPEAR. For these cases the HVPS output will
remain at this “low” 1.3kV value.
However other beam losses may be caused by PPS faults or access into the ring is
required. In both of these cases the input AC contactor is opened, removing the 12.47kV
RMSfromtheinputofthephaseshiftingtransformer. SincethereisnownoAClinevoltage
on the HVPS input, there is no AC voltage on the secondaries of the rectifier transformers
and no DC output voltage from the HVPS. Shortly before 20:13 in Fig. 5 the contactor was
opened to gain access into SPEAR, causing the HVPS output to go from its “low” value to
zero.
7


---
## Page 8

capacitor discharge through 1000 and klystron with P = 1.00 P
6
10
5
10
4
10
)
V
(
3
p 10
a
c
V
2
10
1
10
0
10
0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
time (s)
Figure3: CalculationofcapacitorvoltagedischargethroughklystronwhentheHVPSturns
off.
8


---
## Page 9

hvps data from hvpsOutput20220720133520.mat
10
5
)
V 0
(
e
d
u
t
ilp
m
-5
a
-10 output voltage
output current
inductor 1 voltage
inductor 2 voltage
-15
-90 -80 -70 -60 -50 -40 -30 -20 -10 0
time (ms)
Figure 4: Measurement of HVPS output to klystron when the HVPS turns off.
9


---
## Page 10

Figure 5: History plot of HVPS voltage and current when HVPS is first turned off and then
the contactor is opened.
10


---
## Page 11

4.2 Abnormal HVPS Shutdown
The high power RF system can fail in abnormal ways. For example, the klystron could
short or open, as could the high voltage cables from the HVPS to the klystron. Also, there
couldbeinternaldamagetosomeHVPScomponentsthateithershortsoropenssomeofthe
internal circuitry. We will not discuss all possible errors that can occur within the HVPS. If
there is evidence that a normal shutdown did not occur, the HVPS subject matter experts
(SME) will need to develop a specific plan to work on the internals of the HVPS. This plan
will include the removal of stored hazardous energy.
4.2.1 Filter Inductors
During normal operation, at full load, the current in the filter inductors is 85A. If the
circuitattemptstostopthiscurrentflowalargevoltage,proportionaltothederivativeofthe
current,willdevelopacrosstheinductor. Metaloxidevaristors(MOV)areplacedinparallel
witheachthyristorineachphasestacktoenforcevoltagesharingamongthethyristors. The
voltage developed across the filter inductor will force these MOVs to conduct. Once this
conductionbegins,afractionoftheMOVcurrentisshuntedtothegateofthethyristor. This
fraction is sufficient to trigger the thyristor and begin conduction. This process discharges
the stored energy in the inductor.
4.2.2 Thyristor Stack Capacitors
MOVs and other associated circuitry are used to share the voltage among the 14 thyristors
in an individual stack. The typical resistance across each thyristor is approximately 20MΩ,
for a total impedance of 280MΩ aross the stack.
The voltage on a capacitor in an R-C circuit decays exponentially with a time constant
τ = RC. The voltage, as a function of time, on this capacitor is
v(t) = V 0 e− R t C = V 0 e− τ t . (10)
The capacitor voltage will decrease below 50V after a time
(cid:18) (cid:19)
V
0
t = τ ·log . (11)
50
50
For the stack as a whole, using the values of C = 0.015(cid:181)F and R = 280MΩ, the time
constant of the stack circuit is τ = 4.2s. Using this value and V = 18.26kV in Eqn. 11,
0
the time for the stack snubber capacitor to reach 50V is t = 24.8s.
Repeating the same calculation for each individual thyristor in the stack, in which
C = 0.047(cid:181)F, R = 20MΩ, τ = 0.94s and V = 1.304kV, we find the time for each snubber
0
capacitor across each individual thyristor to reach 50V is t = 3.07s.
Both of these times are extremely short compared to the time it would take to both lock
off the HVPS and remove the cover from the HVPS phase control tank.
4.2.3 Output Filter Capacitors
In section 4.1.2 we have already calculated and measured the discharge time, measured in
a fraction of a second, of the filter capacitors with a normal klystron load. There may be
11


---
## Page 12

faults in which the klystron load is not normal if, for example, the connection between the
HVPS and klystron opens. This section calculates the finite, but much slower, bleed down
times of the filter capacitors for these abnormal situations. Since the output is a series of
four stages, we will perform these calculations for a single stage.
Looking outward from the filter capacitors in Fig. 1 we see three stages with resistive
discharge paths, the filter rectifiers, the main rectifiers, and the crowbar thyristor stacks.
Not shown in Fig. 1 are two parallel, equivalent voltage dividers that are used by the HVPS
controller to monitor the HVPS output voltage.
Filter Rectifiers Each filter rectifier bridge is comprised of six rectifier stacks which, in
turn, are each comprised of multiple diode packs. Each of these packs has a parallel R-C
circuit in shunt with the diodes in order to force voltage sharing among the diodes. The
measured resistance of each stack is 120MΩ. The configuration of the rectifier bridge is
two stacks in series for each phase and three of these double stacks in parallel to rectify all
three phases. The total shunt resistance of each filter rectifier is R = 2120MΩ = 80MΩ.
S 3
Just including these rectifiers, the time constant for the filter capacitor discharge is
τ = 640s and the time to reach 12.5V is t = 4890s = 81.5min. (We calculated
12.5
the discharge time to 12.5V instead of 50V so that the sum of the voltage across all
four capacitors is less than 50V.) Note that if these filter rectifiers are disconnected from
the capacitor, the capacitor will be removed from the circuit. Any stored energy in the
capacitors will be isolated from all circuit components downstream of the capacitors. If the
HVPS requires repair that involves opening the main tank, one should definitely inspect
the configuration of the output to ensure that the capacitors are at least connected to the
filter rectifiers in order to determine what, if any, shunt resistance is across the capacitors.
Main Rectifiers If the 500Ω filter resistors in Fig. 1 are not open, the resistance of the
mainrectifierbridgeswillalsocontributetothetimeconstantofthecapacitorcircuit. Each
of the six stacks in a bridge is also built using multiple diode packs with shunt resistors
that enforce voltage sharing across each pack. The resistance across each stack is 5MΩ; the
total resistance across a bridge is 3.3MΩ. The time constant due to just the resistors in
the main bridge is τ = 26.7s and the time to reach 12.5V is t = 204s.
12.5
Crowbar Thyristors Each capacitor has a crowbar thyristor stack to discharge the ca-
pacitors in the event of an arc in either the klystron or the HVPS transformer. Each stack
is comprised of six thyristors, each in parallel with a 5MΩ voltage sharing resistor. The
total resistance in the stack is 30MΩ and the time constant due to just these resistors is
τ = 240s.
OutputVoltageDividers TheHVPShastwoidenticalvoltagedividersacrossitsoutput
that are used to measure the HVPS output for purposes of control and monitoring. The
totalresistanceofeachdivideris100MΩ. AsconfiguredwiththedesignedHVPScontroller
terminations, the controller measures the voltage across the bottom 10kΩ of the divider to
measure 9.1V at the full HVPS output of 91kV.
In order to be consistent with the earlier calculations, we use 1 of the total resistance
4
values to obtain a shunt resistance for the two dividers of 12.5MΩ. The time constant due
to these dividers is τ = 100s.
12


---
## Page 13

Total Resistive Time Constant If only the klystron is removed from the circuit, the
total resistive time constant seen by the filter capacitors is determined by the parallel
combination of the five different resistive loads.
1 1 1 1 1
R−1 = + + + +
Tot 80×106 3.3×106 30×106 25×106 25×106
R = 2.348MΩ.
Tot
The total time constant is τ = 18.79s and the voltage of each capacitor decreases below
12.5V in 144s.
Ifweincludetheadditional0.22(cid:181)Foftheadditionaloutputfiltercapacitorand0.0061(cid:181)F
across the entire output and quadruple the sum of these two values in order to partition
these capacitances into sections across each of the large filter capacitors, the total effective
capacitance is 8.90(cid:181)F. The time constant for the output is τ = 20.9s and the total output
voltage decreases below 50V in 160s.
5 Summary
In this note we have identified the voltage sources to the HVPS involved in producing the
HVPS output. We have also listed the design parameters for the full load currents and
voltages, starting from the input 12.47kV RMS and extending to the 90kV DC output
voltage.
We have also calculated the maximum stored energy in the reactive components of the
HVPS. From both calculations and measurements we see that the stored energy is quickly
dissipated in the normal turn-off of the HVPS.
Even if there is a failure in the HVPS, output cable, or klystron that causes the output
circuit to open, the stored energy inside the HVPS will be dissipated in a few minutes,
much shorter than the time it takes to access the HVPS.
The only possible cause for concern is if there is an internal failure of the HVPS in
which the large filter capacitors are disconnected from the main rectifiers. In this case the
dissipation of the capacitor energy to a safe level is calculated to be 81.5min. Such a failure
will require careful inspection of the supply and proper planning before coming into contact
with any component in the HVPS output section.
The results of the calculations performed in this note are summarized in Table 1.
References
[1] R. Cassel, “PEP-II RF system 2.5 MW klystron power supply,” SLAC Technical Spec-
ification, 2004, PS-341-360-01-R2.
[2] National Fire Protection Association, NFPA 70E Standard for Electrical Safety in the
Workplace, 2021 ed. Quincy, MA: National Fire Protection Association, 2020.
13


---
## Page 14

Component Value E(J) τ(s) t (s)
Discharge
Filter inductor 0.3H 1084 <0.1 <0.1
Phase stack snubber capacitor 0.015(cid:181)F 2.5 4.2 24.8
Phase thyristor snubber capacitor 0.047(cid:181)F 0.040 0.94 3.1
Filter capacitor (normal shutdown) 2(cid:181)F 8788 <1 <1
Output capacitor (normal shutdown) 0.22(cid:181)F 911 <1 <1
Output cables (normal shutdown) 0.006(cid:181)F 25 <1 <1
Total output capacitance (normal shutdown) 2.23(cid:181)F 9824 <1 <1
Total output capacitance (output open) 2.23(cid:181)F 9824 20.9 160
Filter capacitor (internal HVPS failure) 2(cid:181)F 8788 640 4890
Table 1: Stored energy and time constants of HVPS reactive elements.
14
