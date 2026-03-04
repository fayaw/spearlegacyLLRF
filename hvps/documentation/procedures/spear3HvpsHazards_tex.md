# SPEAR3 High Voltage Power Supply Hazards

> **Source:** `hvps/documentation/procedures/spear3HvpsHazards.tex`
> **Author:** J. Sebek
> **Format:** LaTeX (converted to Markdown for AI readability)
> **Also available as:** `spear3HvpsHazards.pdf`

---

## Introduction

This note documents the hazards in the SPEAR3 high voltage power supply (HVPS) and then addresses the discharge of potential stored energy in the system.  The high level specifications of the HVPS can be found in the specification for the supply [citation], although not all details of the HVPS design are contained in that document.  Using this note as a reference, a procedure can be developed to safely measure zero voltage both on the HVPS output and also its internal components, if required.  The requirements for dealing with potential electrical hazards, although not discussed in this document, are given in the latest version of the National Fire Protection Association (NFPA) 70E standard [citation].

## HVPS Architecture

The purpose of the HVPS is to provide direct current (DC) power to a 1.5 MW klystron.  The source of its input power is the three-phase 12.47 kV RMS line.  The HVPS is rated to output up to -90 kV, 27 A, or 2.5 MW of power to the klystron.  Figure [ref] gives a high level schematic of the HVPS.

> *[Figure - see original document]*

The power supply specification gives 350 kV A as the rating for the input phase-shifting transformer.  However this number does not seem to be correct, especially since the output rating of the power supply is 2.5 MW.  A figure in the specification gives the input power rating of the source as 2.5 \megaVA and the rating of each of the two rectifier transformers as 1.5 \megaVA each.  Figure [ref], a later HVPS schematic gives the input power rating of the source as 3.0 \megaVA.  Based on these other numbers, I assume that the number given as the rating in the specification likely is a typographical error that has a missing zero.  I therefore assume that the correct rating of the phase-shifting transformer is 3.5 \megaVA.  For this rating, the full load current for each phase is
```
equation 
	I_\Phi = 3500{3\cdot 12.47 = 162 A.
equation
```

The phase-shifting transformer is an extended delta configuration that creates two three-phase waveforms from the 12.47 kV RMS line, one advanced by 15 ° and one retarded by 15 °.  Each has a phase-to-phase amplitude of 12.91 kV RMS.  (The specification also carries along the error of using 12.47 kV RMS instead of 12.91 kV RMS, even though the correct value of the shifted voltages is shown in a figure in the specification.  The specification does give a tolerance of $\pm5\

The phase-shifted waveforms are applied to the primary legs of two open wye transformers, labeled T1 and T2 in Fig. [ref], each rated at 1.5 \megaVA.  Each of these transformers feed two wye secondaries.  Both of the T1 secondaries, T1-S1 and T1-S2, have phase-to-phase voltages of  21.0 kV RMS.  One of the T2 secondaries, T2-S1, also has a voltage of 21.0 kV RMS, while the other, T2-S2, only has half of that voltage, 10.5 kV RMS.

Each open wye primary feeds a six-pulse thyristor rectifier stack.  The load of each of these stacks is a 0.3 H inductor.  No individual thyristor can hold off the required voltage from the open-wye primary.  Therefore each thyristor stack is comprised of 14 individual Powerex T8K7 thyristors. There are energy storage devices, capacitors, that are associated with these stacks.  Each thyristor has a 0.047 μF capacitor in a snubber across it and each stack has an additional snubber with a 0.015 μF capacitor.

The four secondaries of the two transformers feed rectifiers that convert the voltage to DC.  Each secondary has a main output which feeds its main diode rectifier stack.  The secondary also has a tap set at $105\

## Potential Electrical Hazards

### HVPS Input

The input power to the HVPS is three phase AC line with a phase to phase voltage of 12.47 kV RMS.  Nominal rated maximum current is 162 A, although typical input current is about 113 A.  This voltage is entirely contained within the metal enclosed switchgear, which is the responsibility of the facilities and operations group.  All work performed on this switchgear is performed by them.

### HVPS Output

The output power of the HVPS can range to -90 kV, 27 A, although its nominal value at full 500 mA SPEAR operation is -74.7 kV and 22.0 A.

### Control Power

The HVPS and its associated switchgear has two sources of control power.  DC control power, at 125 V DC is used for control of the local contactor controller in the switchgear.  This power is sourced from Substation 507.  In addition to providing power for its internal logic, the controller uses this voltage for part of its local machine protection system (MPS) to ensure that there has been no excessive pressure in the transformer main tank, the main tank oil temperature is at an acceptable level, and the low conductivity cooling water is flowing through the appropriate oil cooling radiators.

Three phases of 208 V AC control power is used in the HVPS.  One phase is used to provide power for the contactor controller, another phase is used to power the oil pump inside of the main tank, and the third phase provides power to the light used to illuminate the switchgear compartment.

### Trigger Pulses

The HVPS controller sends trains of 16 \micros pulses in 15 ° bursts to fire the thyristors in the phase control stacks.  The amplitude of the first pulse is 240 V; the amplitudes of the later pulses are 120 V.  Similar voltages are used to fire the crowbar thyristors in the event of a potential arc in either the klystron or the HVPS output.

### HVPS Stored Energy

#### Filter Inductors

Each of the HVPS rectifer transformers has an inductor that is fed by and filters the current from the thyristors in the open wye primary.  The inductance of each inductor is 0.3 H and its full load current is 85 A.  The stored energy in each inductor is
```
equation
	E_{L = 1{2LI^{2 = \left(1{2\right)0.3 \left(85\right)^{2 = 1084 J.
equation
```

#### Phase Control Thyristor Stack Snubber Capacitors

Each rectifier transformer open wye primary has six phase control thyristor stacks.  The phase to phase transformer voltage is 12.91 kV RMS.  The maximum voltage on any of the snubber capacitors is therefore
```
equation
	V_{\max = 2\cdot 12.91 kV = 18.26 kV.
equation
```
Each stack as an R-C series snubber circuit in which the capacitance is 0.015 μF.  The largest amount of stored energy in any of these capacitors is
```
equation
	E_{C=1{2CV^{2=\left(1{2\right)0.015\cdot 10^{-6 \left(18.26\cdot 10^{3\right)^{2 = 2.5 J.
equation
```
Note that the instantaneous stored energy is different in each snubber capacitor.  The voltage drop across each capacitor will be different, ranging from zero in the conducting legs of the bridge to the maximum value given in Eqn. [ref].

Each of the fourteen thyristors in each stack has a 0.047 μF snubber capacitor.  Assuming equal voltage sharing across the thyristors, the maximum energy stored in each of these snubber capacitors will be
```
equation
	E_{C=\left(1{2\right) 0.047\cdot 10^{-6 \left(18.26\cdot 10^{3{14\right)^{2 = 40 \milliJ.
equation
```

#### Main Filter Capacitors

The output section of the HVPS includes a filter, discussed on page S:filterDiscussion in Section [ref].  The total stored energy in these capacitors, at full DC voltage, is
```
equation
	E_{C = \left(1{2\right)8\cdot 10^{-6\left(3\cdot 26^{2 + 13^{2\right)10^{6 = 8788 J.
equation
```
(Note that there is a small, $6\
```
equation
	E_{C = \left(1{2\right)2\cdot 10^{-6\left(91^{2\right)10^{6 = 8281 J.
equation
```
instead of the value calculated in Eqn. [ref].)

### Additional Output Filter Capacitor

Not shown in Fig. [ref] is an additional 0.22 μF filter capacitor across the HVPS output.  The stored energy in this capacitor is 911 J.

### Output Cables

The output cables used to carry the HVPS to the klystron are Mil-C-17/81-0001 cable, formerly known as RG~220.  Their capacitance per unit length is listed as either 103 \pF/\meter for Mil-C-17/81-0001 or 101 \pF/\meter for RG~220.  The cable lengths from the HVPS to the transfer tank is about 10 \meter and that from the transfer tank to the termination tank is less than 50 \meter.  At full output voltage, the stored energy in the cables is about 4.2 J and 21 J, respectively.  The total stored energy in all of the output capacitance is approximately 9824 J.

## Discharge of Stored Energy

Before working on the HVPS we must ensure that we have both eliminated any input sources of energy and have discharged any stored energy within the supply.  This section discusses the engineered methods used to discharge the various elements that store energy and measures and/or calculates the appropriate time constants of the circuits and the times until the voltages of the capacitors are below the hazardous levels.  We will discuss the various discharge time constants for normal, controlled turn-offs of the HVPS as well as for those for abnormal turn-offs of the HVPS where there may be some unexpected system failure.

### Normal HVPS Shutdown

By far, most of the shutdowns of the high power radio frequency (RF) system and the HVPS are as designed, even if the cause of the shutdown is not desired.  The normal situation occurs when the RF system is operating as designed and there is a request to turn off the RF system.  The source of the request can be programmatic; operations wants to dump the SPEAR electron beam.  Or the source can be a request from either the SPEAR personnel protection system (PPS) or either the RF or SPEAR machine protection systems (MPS) because a system fault has been detected.  In both of these cases there is a well-defined turn off procedure.  The beam is dumped and the RF station turns off.  When the station turns off, it instructs the HVPS controller to turn off the HVPS output.  The controller removes the triggers from the phase control thyristors in a manner that both discharges the stored current in the filter inductors and prevents further voltage from being impressed on the secondaries of the rectifier transformers.

#### Filter Inductors

As described above, there is an 0.3 H filter inductor in the center of each of the wyes of the two primary rectifier transformers.  When the HVPS controller is commanded to turn off the HVPS, it removes the thyristor firing triggers from all but the $B^{+$ and $B^{-$ stacks of the thyristor bridge.

This action servers two purposes.  First, it disables the rectification function of the thyristor bridge.  Second, by latching on the thyristors in the $B^{+$ and $B^{-$ stacks, it provides a short circuit path in which the stored current in the inductors can flow and dissipate.

Figure [ref] shows the inductor voltage during a beam dump.  One can see the inductor voltage discharge while the $B$ stacks are conducting.  The voltage reaches its final zero value after about 10 \ms.  This discharge time is significantly less than the time constant calculated from just the 0.38 Ω resistance of the inductor.  The additional resistance of the thyristors in their conducting state is responsible for the decrease in the $L/R$ time constant.  The discharge through the thyristor stacks also discharges the stored energy on the snubber capacitors in these thyristor stacks. 

> *[Figure - see original document]*

#### Output Capacitors

The devices that connect stored energy directly to the output are the capacitances of the output filters and cables.  During normal operation this energy is quickly dissipated through the klystron.  The Child-Langmuir law gives the non-linear relation between the cathode voltage and current as
```
equation
	I = P\cdot V^{3{2
equation
```
where $I$ is the beam current, $V$ is the beam voltage, and $P$ is the perveance of the cathode which, for the SPEAR3 klystron is about $10^{-6$.  We numerically solve the non-linear equation
```
equation
	q{C = Rdq{dt - P^{-2{3\left(-dq{dt\right)^{2{3
equation
```
where $q$ is the charge on the capacitor $C=2 μF$, $R=1000 \Omega$ is the resistance between the capacitor and the klystron, and $P$ is the perveance of the klystron.  The result, plotted in Fig. [ref], shows that the output voltage decays below 50 V within 250 \ms.  This time is consistent with the observed voltage decay out of HVPS when the system is turned off, as shown in Fig. [ref].

> *[Figure - see original document]*

> *[Figure - see original document]*

#### HVPS Output Voltage

Even when the RF station and its HVPS are turned off, the HVPS output with the normal klystron load is about 1.3 kV and not zero volts.  Even with the phase control thyristors not firing, there is still some leakage from the primary to the secondary of the rectifier transformers that is rectified by the output rectifiers.  The control system is able to measure this voltage.  It can be seen live on the local controller and/or EPICS displays; the voltages are archived in the History buffers.

Figure [ref] plots the HVPS voltage and current during a normal turn-off of the RF system.  At 20:07 the RF station was turned off.  The HVPS output voltage and current data, each sampled every two seconds, show that they both decreased from their operating voltage to near zero together as the HVPS was turned off.  Note that the measured HVPS output voltage is about 1.3 kV.  This shows that our voltage diagnostic is still accurately measuring the output voltage after the station is turned off.

Most unexpected beam losses are caused by transient errors.  There may be a dip in the input 12.47 kV RMS voltage, a magnet power supply may trip, there may be a ring vacuum fault, etc.  In these cases the goal is to refill beam as quickly as possible.  Once the transient fault is cleared, beam will be reinjected into SPEAR.  For these cases the HVPS output will remain at this ``low'' 1.3 kV value.

However other beam losses may be caused by PPS faults or access into the ring is required.  In both of these cases the input AC contactor is opened, removing the 12.47 kV RMS from the input of the phase shifting transformer.  Since there is now no AC line voltage on the HVPS input, there is no AC voltage on the secondaries of the rectifier transformers and no DC output voltage from the HVPS.  Shortly before 20:13 in Fig. [ref] the contactor was opened to gain access into SPEAR, causing the HVPS output to go from its ``low'' value to zero.

> *[Figure - see original document]*

### Abnormal HVPS Shutdown

The high power RF system can fail in abnormal ways.  For example, the klystron could short or open, as could the high voltage cables from the HVPS to the klystron.  Also, there could be internal damage to some HVPS components that either shorts or opens some of the internal circuitry.  We will not discuss all possible errors that can occur within the HVPS.  If there is evidence that a normal shutdown did not occur, the HVPS subject matter experts (SME) will need to develop a specific plan to work on the internals of the HVPS.  This plan will include the removal of stored hazardous energy.

#### Filter Inductors

During normal operation, at full load, the current in the filter inductors is 85 A.  If the circuit attempts to stop this current flow a large voltage, proportional to the derivative of the current, will develop across the inductor.  Metal oxide varistors (MOV) are placed in parallel with each thyristor in each phase stack to enforce voltage sharing among the thyristors.  The voltage developed across the filter inductor will force these MOVs to conduct.  Once this conduction begins, a fraction of the MOV current is shunted to the gate of the thyristor.  This fraction is sufficient to trigger the thyristor and begin conduction.  This process discharges the stored energy in the inductor.

#### Thyristor Stack Capacitors

MOVs and other associated circuitry are used to share the voltage among the 14 thyristors in an individual stack.  The typical resistance across each thyristor is approximately 20 \megaΩ, for a total impedance of 280 \megaΩ aross the stack.

The voltage on a capacitor in an R-C circuit decays exponentially with a time constant $\tau = RC$.  The voltage, as a function of time, on this capacitor is
```
equation
	v\left(t\right) = V_{0e^{-t{RC = V_{0e^{-t{\tau.
equation
```
The capacitor voltage will decrease below 50 V after a time
```
equation
	t_{50 = \tau\cdot\log\left(V_{0{50\right).
equation
```

For the stack as a whole, using the values of $C = 0.015 μF$ and $R = 280 \megaΩ$, the time constant of the stack circuit is $\tau = 4.2 s$.  Using this value and $V_{0 = 18.26 kV$ in Eqn. [ref], the time for the stack snubber capacitor to reach 50 V is $t =24.8 s$.

Repeating the same calculation for each individual thyristor in the stack, in which $C = 0.047 μF$, $R = 20 \megaΩ$, $\tau = 0.94 s$ and $V_{0 = 1.304 kV$, we find the time for each snubber capacitor across each individual thyristor to reach 50 V is $t =3.07 s$.

Both of these times are extremely short compared to the time it would take to both lock off the HVPS and remove the cover from the HVPS phase control tank.

#### Output Filter Capacitors

In section [ref] we have already calculated and measured the discharge time, measured in a fraction of a second, of the filter capacitors with a normal klystron load.  There may be faults in which the klystron load is not normal if, for example, the connection between the HVPS and klystron opens.  This section calculates the finite, but much slower, bleed down times of the filter capacitors for these abnormal situations.  Since the output is a series of four stages, we will perform these calculations for a single stage.

Looking outward from the filter capacitors in Fig. [ref] we see three stages with resistive discharge paths, the filter rectifiers, the main rectifiers, and the crowbar thyristor stacks.  Not shown in Fig. [ref] are two parallel, equivalent voltage dividers that are used by the HVPS controller to monitor the HVPS output voltage.

##### Filter Rectifiers

Each filter rectifier bridge is comprised of six rectifier stacks which, in turn, are each comprised of multiple diode packs.  Each of these packs has a parallel R-C circuit in shunt with the diodes in order to force voltage sharing among the diodes.  The measured resistance of each stack is 120 \megaΩ.  The configuration of the rectifier bridge is two stacks in series for each phase and three of these double stacks in parallel to rectify all three phases.  The total shunt resistance of each filter rectifier is $R_{S = 2{3120 \megaΩ = 80 \megaΩ$.

Just including these rectifiers, the time constant for the filter capacitor discharge is $\tau = 640 s$ and the time to reach 12.5 V is $t_{12.5 = 4890 s = 81.5 \minute$.  (We calculated the discharge time to 12.5 V instead of 50 V so that the sum of the voltage across all four capacitors is less than 50 V.)  Note that if these filter rectifiers are disconnected from the capacitor, the capacitor will be removed from the circuit.  Any stored energy in the capacitors will be isolated from all circuit components downstream of the capacitors.  If the HVPS requires repair that involves opening the main tank, one should definitely inspect the configuration of the output to ensure that the capacitors are at least connected to the filter rectifiers in order to determine what, if any, shunt resistance is across the capacitors.

##### Main Rectifiers

If the 500 Ω filter resistors in Fig. [ref] are not open, the resistance of the main rectifier bridges will also contribute to the time constant of the capacitor circuit.  Each of the six stacks in a bridge is also built using multiple diode packs with shunt resistors that enforce voltage sharing across each pack.  The resistance across each stack is 5 \megaΩ; the total resistance across a bridge is 3.3 \megaΩ.  The time constant due to just the resistors in the main bridge is $\tau = 26.7 s$ and the time to reach 12.5 V is $t_{12.5 = 204 s$.

##### Crowbar Thyristors

Each capacitor has a crowbar thyristor stack to discharge the capacitors in the event of an arc in either the klystron or the HVPS transformer.  Each stack is comprised of six thyristors, each in parallel with a 5 \megaΩ voltage sharing resistor.  The total resistance in the stack is 30 \megaΩ and the time constant due to just these resistors is $\tau = 240 s$.

##### Output Voltage Dividers

The HVPS has two identical voltage dividers across its output that are used to measure the HVPS output for purposes of control and monitoring.  The total resistance of each divider is 100 \megaΩ.  As configured with the designed HVPS controller terminations, the controller measures the voltage across the bottom 10 \kiloΩ of the divider to measure 9.1 V at the full HVPS output of 91 kV.

In order to be consistent with the earlier calculations, we use $1{4$ of the total resistance values to obtain a shunt resistance for the two dividers of 12.5 \megaΩ.  The time constant due to these dividers is $\tau = 100 s$.

##### Total Resistive Time Constant

If only the klystron is removed from the circuit, the total resistive time constant seen by the filter capacitors is determined by the parallel combination of the five different resistive loads.
```
IEEEeqnarray*{rCl
	
	
	R_{Tot^{-1 & = &1{80\times 10^{6 + 1{3.3\times 10^{6 + 1{30\times 10^{6 + 1{25\times 10^{6 + 1{25\times 10^{6\\
	R_{Tot & = &2.348 \megaΩ.
IEEEeqnarray*
```
The total time constant is $\tau = 18.79 s$ and the voltage of each capacitor decreases below 12.5 V in 144 s.

If we include the additional 0.22 μF of the additional output filter capacitor and 0.0061 μF across the entire output and quadruple the sum of these two values in order to partition these capacitances into sections across each of the large filter capacitors, the total effective capacitance is 8.90 μF.  The time constant for the output is $\tau = 20.9 s$ and the total output voltage decreases below 50 V in 160 s.

## Summary

In this note we have identified the voltage sources to the HVPS involved in producing the HVPS output.  We have also listed the design parameters for the full load currents and voltages, starting from the input 12.47 kV RMS and extending to the 90 kV DC output voltage.

We have also calculated the maximum stored energy in the reactive components of the HVPS.  From both calculations and measurements we see that the stored energy is quickly dissipated in the normal turn-off of the HVPS.

Even if there is a failure in the HVPS, output cable, or klystron that causes the output circuit to open, the stored energy inside the HVPS will be dissipated in a few minutes, much shorter than the time it takes to access the HVPS.

The only possible cause for concern is if there is an internal failure of the HVPS in which the large filter capacitors are disconnected from the main rectifiers.  In this case the dissipation of the capacitor energy to a safe level is calculated to be 81.5 \minute.  Such a failure will require careful inspection of the supply and proper planning before coming into contact with any component in the HVPS output section.

The results of the calculations performed in this note are summarized in Table [ref].

> *[Table - see original document for formatted table]*