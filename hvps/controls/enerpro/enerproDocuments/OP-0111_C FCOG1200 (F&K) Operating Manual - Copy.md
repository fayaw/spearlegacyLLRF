# OP-0111_C FCOG1200 (F&K) Operating Manual - Copy

> **Source:** `hvps/controls/enerpro/enerproDocuments/OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 16


---
## Page 1

http://www.enerpro-inc.com
info@enerpro-inc.com
99 Aero Camino Operations Manual: OP-0111
Goleta, California 93117 June 2020
Operating Manual: Twelve-SCR General Purpose Gate Firing Board
FCOG1200 Revisions F or K
Introduction
This manual describes the salient features and specifications of the FCOG1200 firing board, including
typical firing circuit signal waveforms and a checkout procedure.
Product Description
1.0 Application
The firing board responds to a voltage or current delay angle command signal (SIG HI) to
produce two delayed sets of six isolated, 60°-spaced high-current SCR gate firing pulses, each
set is separated by 30° of each other for a total of 12 outputs for firing parallel or series
connected 12-pulse DC converters or AC controllers. The twelve gate pulses are precisely
spaced at 30° as required to eliminate the 5th and 7th harmonics of the mains current.
1.1 Advantages of twelve pulse rectification.
When used as a DC converter, the FCOG1200 automatically adapts to the sequence of the AC
mains voltage (whether a-b-c or a-c-b) and to the 30° phase shift (whether +30° or -30°) between
the two groups of three phase voltages applied to the converter input.
Twelve pulse rectification provides the benefits of reduced harmonic current into the input
transformer and reduced ripple current in the DC output (ripple frequency is doubled to 720 Hz
and ripple driving voltage is halved). The result is improved power quality of the AC mains current
and reduced size of the DC filter choke.
2.0 ASIC-Based Firing Circuit
All firing circuit logic is contained in two custom 24-pin ASIC (U3 and U4). Additional detail on the
firing circuit theory is contained in a separate engineering society paper1.
3.0 Board Mounted Connectors
The firing board is connectorized to simplify maintenance and troubleshooting.
3.1. Gate/Cathode Connectors
The SCR gate/cathode interface is provided by 8-position Mate-N-Lok™ vertical connectors2 J1
through J4, and mating plus P1 through P4. The connectors are keyed to prevent incorrect
installation or reversal of the mating plugs. Plugs P1 and P3 access the gates and cathodes of
the six SCRs having load connected cathodes when the SCRs are arranged in the in-line AC
controller or DC bridge converter configurations. Similarly, plugs P2 and P4 access the gates and
cathodes of the six SCRs having line connected cathodes.
3.2. Control Signal Connector
The firing board connects to the gate delay command and inhibit controls through a 15-position
Mate-N-Lok™ connector J6. This connector also accesses the 24Vac board power, the 30VDC
rectified input board power/ or board power, and the regulated +12/+5 VDC outputs. The 24Vac
and 30VDC connections permit the board to be powered from an external source. With 24Vac
applied (24VA minimum), approximately 10 Watts of DC power are available from J6 to power
lamps or control relays.
1 Bourbeau, F. J., “Phase Control Thyristor Firing Circuit: Theory and Applications”, Power Quality ’89, Long Beach, California.
2 Right-Angle or Horizontal connectors are not available in this board.
Enerpro Document No: OP-0111, Rev. C Page 1 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 2

3.3. Phase Reference Test Signal Input Connector
For low-power testing, users may connect 2 sets of low-level (5 V ) three-phase test reference
PP
signals, each set of three-phases must be shifted by 30°, to the first six positions of an eight-
position MTA header J7. This allows the board checkout to proceed without connection to high
voltage power. Users may alternatively connect off-board phase reference resistors at J7; this is
a useful option if the six phase references may not be derived from the SCRs. Positions 7 and 8
provide respectively a connection to circuit common and to an unregulated 15VDC supply (10mA
max) that could be optionally used to drive external circuitry.
3.4. Frequency Selection Connector
A 3-position header, J5, is used in conjunction with RN43 and capacitors C23 and C29 to select
between 50 Hz and 60 Hz operation. In 60Hz operation, RN4 is 120KΩ, C23 and C29 are 0.27µF
and R36 is connected in parallel with R35. IN 50Hz operation RN4 is 150KΩ, C23 and C29 are
0.33µF and J5 removes R36 from the circuit in order to maintain TP2 at 5.0VDC.
3.5. Control Input Voltage
The power supply on the FCOG1200 board operates from a customer-supplied external 24Vac,
24VA, single phase power source. The power supply produces unregulated 30VDC, and
regulated 12VDC and 5VDC.
4.0 Gate Delay Command
The delay command signal, SIG HI, may be configured either as a 0.9-5.9VDC, 0-5VDC, or 4 to
20 mA current command (with a maximum upper limit of 50mA). The default SIG HI range is 0.9
to 5.9 Volts as R25 is 249KΩ. The input resistance presented to the delay command signal SIG
HI is determined by resistor R40. This value is selected as 10.0 kΩ when the control signal is
designated as a control voltage. As an option, if R25 is 150KΩ, the input signal range of SIG HI
will be 0-5Vdc.
When the gate delay command is a current signal, R40 is selected to give a 5VDC level at the
maximum desired delay command signal current (without exceeding the maximum 50mA limit).
5.0 Gate Inhibits
SCR gating is inhibited by pulling either the instant inhibit, I¯ or soft inhibit, I¯ signal to ground.
1 2
These signals are located at J6 pin 4 and J6 pin 12, respectively.
The instant inhibit signal I¯ is normally pulled to ground through resistor R41 (1.50 kΩ). The user
1
typically connects the I¯ signal to +12 VDC to enable firing. This arrangement ensures that SCR
1
gating is inhibited if plug P6 is inadvertently disconnected. A jumper may be installed between
pins 4 and 6 of P6 to hold I¯ at +12 VDC at all times in applications where the instant inhibit is not
1
needed.
The soft inhibit signal I¯ is normally pulled to +12 VDC through resistor R42 (1.50 kΩ). As a
2
default, the user then grounds I¯ to soft-stop SCR firing. In this mode, the delay angle is ramped
2
from the setpoint value determined by SIG HI to the largest angle possible, after which firing is
completely inhibited. This is termed the soft-stop shutdown mode. When user opens the
connection at I¯ , gating is enabled with the delay angle set to the maximum limit. The delay angle
2
then ramps to the value determined by SIG HI. The soft-stop and soft-start time constants are
independently configurable via two timing resistors (R22 and R39 respectively) and a capacitor
(C4).
As an option the soft inhibit signal I¯ may be tied to common through resistor R37 (1.50 kΩ). In
2
this case resistor R42 is omitted and the I¯ signal is toggled exactly as the I¯ signal.
2 1
3 RN4, C23, and C29 may be placed in a component-socket for ease of installation.
Enerpro Document No: OP-0111; Rev. C Page 2 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 3

6.0 Phase Loss Inhibit
The FCOG1200’s phase loss circuit instantly inhibits SCR gating if the mains voltage phases are
grossly imbalanced or, in the extreme case, if one or more phase voltages are missing. This
feature also eliminates the possibility of erratic response associated with voltage imbalance or
transients when the two sets of three-phase mains are initially connected to the SCRs. After any
phase loss fault, the board soft-starts when the fault is cleared. The phase loss circuit is also
activated when the six-phase power is initially applied to the CSRs. Gating is inhibited until the
power supply voltage has stabilized.
Figure 1. Phase Loss Circuit Signals – No Phase Loss4
Channels: 1. Y resulting phase summing signal, TP16
2. X resulting phase summing signal, TP15
3. P¯L Signal, U6 P1
Notes:
- The Phase-Loss LED (PD1) is off.
- The two yellow markers represent the upper and lower phase-loss thresholds at U6 pin 9
and pin 10 respectively.
- Both TP15 and TP16 are well within the upper and lower phase-loss thresholds.
4 All waveforms contained in this document were obtained with the FCOG1200 revision K firing board connected to 240Vac, 60 Hz,
balanced 6-phase power via sockets 2, 5, and 8 of plugs P2 and P4. The time base of each screenshot has been calibrated for
phase measurements as noted at 60 Hz. All component designations refer to drawing E640, revision F or K.
Enerpro Document No: OP-0111; Rev. C Page 3 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 4

Figure 2. Phase Loss Circuit Signals – Phase Loss
Channels: 1. Y resulting phase summing signal, TP16
2. X resulting phase summing signal, TP15
3. P¯L Signal, U6 P1
Notes:
- The Phase-Loss LED (PD1) is ON.
- The two yellow markers represent the upper and lower phase-loss thresholds at U6 pin 9
and pin 10 respectively.
- TP15 is not within the upper and lower phase-loss thresholds.
7.0 Phase Reference Shift Selection
A first-order RC lowpass filter (formed by RN4 and capacitors C17-22) shifts the mains phase
references by 0° (for controller applications) or by 30° lagging (for converter applications).
For 30° lagging references, the previously referenced capacitors are 0.033 μF film capacitors and
RN4 is a 120 kΩ, 14-position, isolated DIP resistor network.
Figure 3. Thirty-degree shifted phase references, Phase Ax
Channel: 4. Phase Ax Line-to-Neutral Voltage
1. Attenuated and Filtered Mains Voltage at RN4-14
3. Reference Comparator Output, TP5
Enerpro Document No: OP-0111; Rev. C Page 4 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 5

For 0° references, 0.01 μF film capacitors may be installed with RN4 = 120 kΩ. Alternatively,
0.033 μF film capacitors may be used with a 33 kΩ resistor network installed at RN4 for 0° shifted
references. This is an optimal scheme if the same firing board may be used to fire controllers or
converters, as the user may then simply change RN4 (typically supplied in a socket in this case)
to achieve the required phase shift.
Figure 4. Zero-degree shifted phase references, Phase Ax
Channel: 4. Phase A Line-to-Neutral Voltage
1. Attenuated and Filtered Mains Voltage at RN4-14
3. Reference Comparator Output, TP5
8.0 Gate Pulse Generation
Two-position jumpers JU1and JU2 enable gate pulse profile selection. With JU1 and JU2
installed, the pulse profile is two 30°-wide bursts, each with an initial hard-firing gate pulse and
followed by sustaining “picket fence” pulses. With these jumpers omitted, the gate pulse profile
changes to a single 120°-wide burst with the same hard-firing initial pulse. The initial hard-firing
pulse and sustaining pulses ensure continuous SCR conduction over the required period.
Enerpro Document No: OP-0111; Rev. C Page 5 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 6

Figure 5. 2-30° Gate Pulse Profile (Into 1Ω) 5
Figure 6. 120° Gate Pulse Profile (Into 1Ω).
Figure 7. Initial pulse profile detail (Into 1Ω).
Each gate logic signal drives a primary winding of twelve isolated pulse modules. The primary
winding of each pulse transformer is also connected to a current-limiting resistor (R1-R3 and R4-
R6) and a speed-up capacitor (C11-C13 and C14-C16); this provides an initial hard-firing gate
pulse followed by sustaining, lower amplitude picket fence pulses.
Each pulse module consists of a 2:1 ratio pulse transformer tested for 3500 V isolation, two
RMS
secondary diodes, noise-suppression resistors across the primary and across the gate drive
5
Current waveforms obtained using a Pearson model 2877 current transformer with 4 primary turns. The current transformer is
terminated by the scope’s 1.0MΩ input impedance.
Enerpro Document No: OP-0111; Rev. C Page 6 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 7

output, and a fusible link in series with the output. Each pulse module is potted in a silicone
insulating material.
The DDFO1200 (delay determinator fiber optic) is a version of the FCOG1200 with fiber optic
outputs replacing the pulse transformers. Twelve FO1024 modules are installed which feature
Avago HFBR-1412Z fiber optic transmitters in lieu of the EP1024 modules. The transmitters
feature ST (bayonet) style connectors, operate at 820 nm and are directly compatible with the
MVTB series of medium voltage trigger boards. Each module has an LED to indicate that the fiber
optic transmitter is operational. Please specify this configuration on your ordering documents or
contact Enerpro for additional information.
9.0 Balancing Circuits
Ideally, the phase shift transformer that powers the two 6-Pulse Thyristor bridges, which make up
a 12-Pulse converter, provides two sets of three phase voltages equal in amplitude and phase
shifted by 30°. In practice, transformer imperfections cause a small open circuit voltage
unbalance, impedance unbalance, and a slight deviation from 30° phase shift. As a result,
individual bridge currents of the parallel 12-Pulse converter become unbalanced, the 5th and 7th
harmonics of the ac mains current are not completely canceled, and a dc ripple voltage a six time
the mains frequency appears on the converter output.
The upgraded (REV F and REV K) FCOG1200 firing board provides three means of adjusting the
nominal 30° group delay in order to optimize the system performance. This optimization will allow
the user to balance the bridge currents, thereby minimizing the ac current harmonics and dc
ripple voltage. The three methods are outlined below:
9.1 Manual Balance: On-Board Trimpot Adjustment
This, the simplest means of control, is the default configuration of the FCOG1200 firing board.
For on-board trimpot manual adjustment, the FCOG1200 is configured as follows:
R11 Installed (25.0kΩ pot.) R51 Installed (100kΩ)
R48 Omit U12 Omit
R49 Omit JU4 Omit
R50 Installed (100kΩ) JU5 Omit
With this control method you will optimize the 12-Pulse system for operation at a particular
current level. This will ensure that the system provides balanced six phase current and minimum
THD at the optimized current level. However, as the dc current diverges from this optimum level,
the transformer and firing board imperfections will cause the phase currents to diverge. This, in
turn, will cause an increased THD level on the ac mains.
Adjustment is performed by setting the dc output current at the desired level. Once you have
reached the desired level, monitor the input currents to the individual bridges and the dc output
current. Adjust the on-board trimpot, R11, as required to obtain balanced bridge input currents (if
required, adjust the command signal as necessary to maintain the desired dc output current).
9.2 On-Board Auto-Balance Control
This control method provides active control of the 30° group delay in order to optimize the circuit
at all dc output currents. Implementation of this control method requires two customer-provided
Enerpro Document No: OP-0111; Rev. C Page 7 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 8

current feedback signals, labeled “x” and “y” in Figure 8. These current feedback signals may be
derived from the bridge ac input currents, as shown, or from the individual bridge output currents.
The feedback signals should be of equal amplitude, approximately 1.0 – 5.0Vdc. The feedback
signals are then applied to J6 pins 14 and 15 on the FCOG1200 board and the FCOG1200 board
is configured as follows6:
R11 Omit R51 Installed (100kΩ)
R48 Installed (10.0kΩ) U12 Installed (MC14070BCP)
R49 Installed (10.0kΩ) JU4 Omit
R50 Installed (100kΩ) JU5 Omit
Figure 8. On-board Auto-Balance Circuit
This circuit operates by injecting a high frequency (6*f ) square wave into the Voltage
mains
Controlled Oscillator (VCO) summing amplifier. This square wave serves to increase the delay
angle (α) of the high current bridge while reducing the delay angle of the low current bridge.
These delay angle adjustments will actively equalize the bridge input currents thereby ensuring
optimum system performance.
9.3 External Auto-Balance Control
The FCOG1200 Revision F and K firing board can also be controlled by an external auto-balance
circuit. This circuit will perform the same functions as the on-board auto-balance circuit but could
6
The FCOG1200 board can be supplied with this configuration. Please request that the boards be configured for “on-board auto-
balance” when ordering.
Enerpro Document No: OP-0111; Rev. C Page 8 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 9

also provide regulation (closed-loop control). In this mode the FCOG1200 board is configured as
follows7:
R11 Omit R51 Omit
R48 Installed (10.0kΩ) U12 Omit
R49 Jumper JU4 Installed
R50 Omit JU5 Installed
The high frequency (6*f ) output of the external auto-balance circuit should be connected to J6
mains
pin 14 of the FCOG1200 board. If desired, the external circuit can obtain CK2 and NOT (CK2)
signals at J6 pins 15 and 13, respectively.
10.0 Electrical Specifications
Table 1. General Specifications.
Maximum Ratings
AC mains voltage 600 Vac
Pulse transformer hipot 3500 Vac (60 seconds)
Operating temperature range -5 C to 85 C
Board ac supply voltage 28 Vac (24 Vac nominal)
12 V regulator output current 5 mA (30 VDC supply)
5 V reference output current 5 mA (30 VDC supply)
Auxiliary control power output from 24 Vac/30 VDC 10 W
Delay angle range 10° ≤ α ≤ 170°
Electrical Characteristics
Delay angle command signal, SIG HI Voltage: 0-5, 0.85-5.85, 0-10, 0-2 V
Current: 4-20 mA
Or per customer specification
Delay angle reference phase shift 0° or -30° (application-specific)
Control signal isolation from ground 653 kΩ (For higher isolation, use transformer
coupled phase references)
Galvanic isolation provided by pulse
transformers and control power transformer
Gate delay steady-state transfer function Delay angle decreases as SIG HI increases
Gate delay dynamic transfer function bandwidth -3 dB at 119 Hz, phase shift -45° at 68 Hz
Gate drive phase balance ±1° (max)
Delay angle variance Δ(α)/Δ(f) = 0.2°/Hz
Mains voltage distortion effect Firing not affected by zero crossing; phase
reference filter attenuation is 12.8 dB relative
to fundamental at 5th harmonic
Lock acquisition time 30 ms (typ)
Soft-start/stop time (independently configurable) 0.05 – 20.0 s (typical)
Phase rotation effect None
Phase loss inhibit Automatic
Power-on inhibit Automatic
Instant/soft inhibit/enable inputs Dry contact
SCR gate pulse waveform (jumper selectable) 120° burst or
2-30° bursts, 30° spaced. Select via JU1 &
JU2.
Gate pulse burst frequency 384 times line frequency
Gate pulse width, 50 Hz 20-22 μs
Gate pulse width, 60 Hz 24-26 μs
Initial gate pulse open circuit voltage 15 V (30 VDC supply)
Sustaining gate pulse open circuit voltage 7.0 V (30 VDC supply)
Peak gate drive short circuit current 1.5 A (30 VDC supply, 1.0 Ω gate load)
Sustaining gate drive short circuit current 0.5 A (30 VDC supply, 1.0 Ω gate load)
Short-circuit gate drive current rise time 1.0 A/μs (30 VDC supply, 1.0 Ω gate load)
Board dimensions 194 x 191 x 34 mm (L x W x D)
Minimum creepage distance to ac mains 13 mm
Conformal coating per MIL-1-46058, Type UR
7
The FCOG1200 board can be supplied with this configuration. Please request that the boards be configured for “on-board auto-
balance” when ordering.
Enerpro Document No: OP-0111; Rev. C Page 9 of 16 ECO #20-11178; Release Date: 06/29/2020


### Table 1

| Maximum Ratings |  |
| --- | --- |
| AC mains voltage | 600 Vac |
| Pulse transformer hipot | 3500 Vac (60 seconds) |
| Operating temperature range | -5 C to 85 C |
| Board ac supply voltage | 28 Vac (24 Vac nominal) |
| 12 V regulator output current | 5 mA (30 VDC supply) |
| 5 V reference output current | 5 mA (30 VDC supply) |
| Auxiliary control power output from 24 Vac/30 VDC | 10 W |
| Delay angle range | 10° ≤ α ≤ 170° |
| Electrical Characteristics |  |
| Delay angle command signal, SIG HI | Voltage: 0-5, 0.85-5.85, 0-10, 0-2 V Current: 4-20 mA Or per customer specification |
| Delay angle reference phase shift | 0° or -30° (application-specific) |
| Control signal isolation from ground | 653 kΩ (For higher isolation, use transformer coupled phase references) Galvanic isolation provided by pulse transformers and control power transformer |
| Gate delay steady-state transfer function | Delay angle decreases as SIG HI increases |
| Gate delay dynamic transfer function bandwidth | -3 dB at 119 Hz, phase shift -45° at 68 Hz |
| Gate drive phase balance | ±1° (max) |
| Delay angle variance | Δ(α)/Δ(f) = 0.2°/Hz |
| Mains voltage distortion effect | Firing not affected by zero crossing; phase reference filter attenuation is 12.8 dB relative to fundamental at 5th harmonic |
| Lock acquisition time | 30 ms (typ) |
| Soft-start/stop time (independently configurable) | 0.05 – 20.0 s (typical) |
| Phase rotation effect | None |
| Phase loss inhibit | Automatic |
| Power-on inhibit | Automatic |
| Instant/soft inhibit/enable inputs | Dry contact |
| SCR gate pulse waveform (jumper selectable) | 120° burst or 2-30° bursts, 30° spaced. Select via JU1 & JU2. |
| Gate pulse burst frequency | 384 times line frequency |
| Gate pulse width, 50 Hz | 20-22 μs |
| Gate pulse width, 60 Hz | 24-26 μs |
| Initial gate pulse open circuit voltage | 15 V (30 VDC supply) |
| Sustaining gate pulse open circuit voltage | 7.0 V (30 VDC supply) |
| Peak gate drive short circuit current | 1.5 A (30 VDC supply, 1.0 Ω gate load) |
| Sustaining gate drive short circuit current | 0.5 A (30 VDC supply, 1.0 Ω gate load) |
| Short-circuit gate drive current rise time | 1.0 A/μs (30 VDC supply, 1.0 Ω gate load) |
| Board dimensions | 194 x 191 x 34 mm (L x W x D) |
| Minimum creepage distance to ac mains | 13 mm |
| Conformal coating | per MIL-1-46058, Type UR |


---
## Page 10

Table 2. Electrical and Mechanical Specifications.
The electrical specifications of the general purpose firing board are summarized in the table below. Part
numbers refer to drawing E640 (REV F or REV K)
Characteristic Performance Requirement Supporting Information
1.Line voltage reference Resistive attenuators and 60° Reference signals automatically
sensing phase shift single pole filters. interchanged for negative phase
sequence.
2. PLL reference signal phasing Application:
w.r.t. mains line-to-neutral
voltage:
a. Ref. signals in phase with a. AC controllers with high
mains voltage. power factor loads.
b. Ref. signals lagging mains b. Converters of AC Controllers
voltage by 30°, with lo power factor loads.
3. SCR gate waveform. Pulse Profile:
a. Mode 1 120° burst of 128 pulses JU1 and JU2 must be omitted
(23,040Hz carrier)
b. Mode 2 2-30° bursts of 32 pulses JU1 and JU2 must be installed
(23.040Hz carrier)
4. Input control signal. 0.9V to 5.9VDC control signal. Option 1: 0-5VDC control signal.
Load resistance is 8.33 KΩ Option 2: A shunt resistance
(R40) across input signal can be
selected for mA control.
5. Control signal isolation from 653 KΩ Produced by the six 2.0 MΩ
ground. mains voltage sense resistors,
internal to PM4-6 and PM9-12.
6. Gate delay steady-state An increase in command α and α change equally
max min
transfer function. voltage produces a proportional with changes in R (R32) and
BIAS
decrease in gate delay angle α. (α - α ) changes with
max min
respect to R (R31).
SPAN
7. Gate delay dynamic transfer Attenuation= -3dB at 119Hz Frequency response can be
function bandwidth Phase Shift= -45° at 68Hz modified by changing summing
amplifier parameters.
8. Gate delay angle balance. Gate pulses for same polarity Assumes balanced line-to-line
SCRs are displaced by 120° mains voltage. Balance
±1.0°, Gate pulses for opposite determined by reference
polarity SCRs are displaced by comparator offset and
180° ± 1.0°. attenuator/filter component
tolerances.
9. Effect of frequency. Da/Df= 1.5°/Hz. For 50 Hz Due to Type I PLL and 60°
operation, compensate by phase shift low pass reference
removing R36 and changing filters.
RN4 to 150 KΩ.
10. Effect of phase rotation. None SCR gating sequence matches
mains voltage sequence.
11. Effect of mains voltage 1. Unaffected by false reference 1. No PLL response to short-
distortion. voltage zero crossing. time false reference logic states.
2. 60° filter attenuates 5th 2. Reference filter attenuates
harmonic by 12.8 dB relative to 5th, 7th, 11th, etc. harmonics from
fundamental. 6-pulse SCR switching.
12. Lock acquisition time. Approximately 29 seconds Gating is inhibited for 20ms or
longer at power-on. Inhibit
period depends on Soft-Start
time constant.
13. Soft-Start Gating commences at α and Soft-Start time constant is set by
max
exponentially decays to the C4 and R22.
commanded delay when T=(1.5K + R22)(C4)(0.579)
(NOT[I2]) is ungrounded (J6- T=ms, R= KΩ, C= µF
12). R22 ≥ 20.0 KΩ
Enerpro Document No: OP-0111; Rev. C Page 10 of 16 ECO #20-11178; Release Date: 06/29/2020


### Table 1

| Characteristic | Performance Requirement | Supporting Information |
| --- | --- | --- |
| 1.Line voltage reference sensing | Resistive attenuators and 60° phase shift single pole filters. | Reference signals automatically interchanged for negative phase sequence. |
| 2. PLL reference signal phasing w.r.t. mains line-to-neutral voltage: a. Ref. signals in phase with mains voltage. b. Ref. signals lagging mains voltage by 30°, | Application: a. AC controllers with high power factor loads. b. Converters of AC Controllers with lo power factor loads. |  |
| 3. SCR gate waveform. a. Mode 1 b. Mode 2 | Pulse Profile: 120° burst of 128 pulses (23,040Hz carrier) 2-30° bursts of 32 pulses (23.040Hz carrier) | JU1 and JU2 must be omitted JU1 and JU2 must be installed |
| 4. Input control signal. | 0.9V to 5.9VDC control signal. Load resistance is 8.33 KΩ | Option 1: 0-5VDC control signal. Option 2: A shunt resistance (R40) across input signal can be selected for mA control. |
| 5. Control signal isolation from ground. | 653 KΩ | Produced by the six 2.0 MΩ mains voltage sense resistors, internal to PM4-6 and PM9-12. |
| 6. Gate delay steady-state transfer function. | An increase in command voltage produces a proportional decrease in gate delay angle α. | α and α change equally max min with changes in R (R32) and BIAS (α - α ) changes with max min respect to R (R31). SPAN |
| 7. Gate delay dynamic transfer function bandwidth | Attenuation= -3dB at 119Hz Phase Shift= -45° at 68Hz | Frequency response can be modified by changing summing amplifier parameters. |
| 8. Gate delay angle balance. | Gate pulses for same polarity SCRs are displaced by 120° ±1.0°, Gate pulses for opposite polarity SCRs are displaced by 180° ± 1.0°. | Assumes balanced line-to-line mains voltage. Balance determined by reference comparator offset and attenuator/filter component tolerances. |
| 9. Effect of frequency. | Da/Df= 1.5°/Hz. For 50 Hz operation, compensate by removing R36 and changing RN4 to 150 KΩ. | Due to Type I PLL and 60° phase shift low pass reference filters. |
| 10. Effect of phase rotation. | None | SCR gating sequence matches mains voltage sequence. |
| 11. Effect of mains voltage distortion. | 1. Unaffected by false reference voltage zero crossing. 2. 60° filter attenuates 5th harmonic by 12.8 dB relative to fundamental. | 1. No PLL response to short- time false reference logic states. 2. Reference filter attenuates 5th, 7th, 11th, etc. harmonics from 6-pulse SCR switching. |
| 12. Lock acquisition time. | Approximately 29 seconds | Gating is inhibited for 20ms or longer at power-on. Inhibit period depends on Soft-Start time constant. |
| 13. Soft-Start | Gating commences at α and max exponentially decays to the commanded delay when (NOT[I2]) is ungrounded (J6- 12). | Soft-Start time constant is set by C4 and R22. T=(1.5K + R22)(C4)(0.579) T=ms, R= KΩ, C= µF R22 ≥ 20.0 KΩ |


---
## Page 11

14.Soft-Stop Soft-Stop time constant is set by
C4 and R39.
T=(R39)(C4)(1.84)
T=ms, R= KΩ, C= µF
R39 ≥ 1.0 KΩ
15. Phase loss inhibit. Gate-delay angle ramps to α Gating resumes with α=α as
max max
before being inhibited when the delay angle ramps to the
(NOT[I2]) is grounded. commanded delay angle as
determined by the Soft-Start
time constant. .
16. Power-on inhibit. Loss of a mains voltage or Same delay angle response as
severe phase unbalance causes with phase loss inhibit.
gate inhibit.
17. Instantaneous inhibit. Phase loss inhibit circuit is Gate is inhibited if P6 is
activated at power-on. removed.
18. SCR gate current individual Opening the connection of <I1> Gate current ON and OFF times
pulse width. (P6-4) to +12V instantly in vary with gate delay angle
inhibits SCR gating. Closing because of 360Hz FM in the
connection of <I1> to +12V VCO output.
instantly enables SCR gating.
19. Peak gate drive open circuit T and T vary from 15µs With a 30VDC supply voltage
ON OFF
voltage. to 28µs.
20. Peak gate drive short circuit 14V Measured with a 30VDC supply
current. voltage and a 1.0Ω load resistor
21.Gate drive current rise-time 1.8A Measured with a 30VDC supply
(short circuit) voltage and a 1.0Ω load resistor
0.5A in 0.5 µs
Enerpro Document No: OP-0111; Rev. C Page 11 of 16 ECO #20-11178; Release Date: 06/29/2020


### Table 1

| 14.Soft-Stop |  | Soft-Stop time constant is set by C4 and R39. T=(R39)(C4)(1.84) T=ms, R= KΩ, C= µF R39 ≥ 1.0 KΩ |
| --- | --- | --- |
| 15. Phase loss inhibit. | Gate-delay angle ramps to α max before being inhibited when (NOT[I2]) is grounded. | Gating resumes with α=α as max the delay angle ramps to the commanded delay angle as determined by the Soft-Start time constant. . |
| 16. Power-on inhibit. | Loss of a mains voltage or severe phase unbalance causes gate inhibit. | Same delay angle response as with phase loss inhibit. |
| 17. Instantaneous inhibit. | Phase loss inhibit circuit is activated at power-on. | Gate is inhibited if P6 is removed. |
| 18. SCR gate current individual pulse width. | Opening the connection of <I1> (P6-4) to +12V instantly in inhibits SCR gating. Closing connection of <I1> to +12V instantly enables SCR gating. | Gate current ON and OFF times vary with gate delay angle because of 360Hz FM in the VCO output. |
| 19. Peak gate drive open circuit voltage. | T and T vary from 15µs ON OFF to 28µs. | With a 30VDC supply voltage |
| 20. Peak gate drive short circuit current. | 14V | Measured with a 30VDC supply voltage and a 1.0Ω load resistor |
| 21.Gate drive current rise-time (short circuit) | 1.8A | Measured with a 30VDC supply voltage and a 1.0Ω load resistor |
|  | 0.5A in 0.5 µs |  |


---
## Page 12

11.0 Installation and Checkout
The following procedure should be followed to ensure proper operation prior to the application of
mains power to the SCR unit.
11.1. Ensure that the power is off. Wire plugs, P2 and P4, with mains voltage connected to
sockets 2, 5, and 8. Insert plug P2 into connector J2 and plug P4 into connector J4.
11.2. Connect the appropriate power to J6:
11.2..1. 24Vac: J6 position 1 and J9 position 2.
11.2..2. 30VDC: J6 positon 3 for (+30) and position 8 or 11 (COM).
11.3. Install plug P6 with a 0-5VDC or 0.9-5.9VDC SIG HI delay command signal, signal
common, and instant/soft inhibit controls wired to the plug.
11.4. Energize the FCOG1200 board with the appropriate voltage on J6, with 24 Vac or 30
VDC.
11.5. Verify the presence of regulated +12 VDC ± 5% at J6 position 6 and regulated +5 VDC
±5% at J6 position 7 with a multi-meter.
11.6. Energize the mains voltage, this will remove the phase loss condition from the
FCOG1200 board. Verify that the PLL is in lock and the mains voltages are balanced by noting
the Phase Loss LED is not lit.
11.7. Verify that the DC level of the VCO control voltage at TP2 is approximately 5.0 VDC. This
voltage is factory-set by selection of the VCO timing select resistor.
11.8. Determine the PLL gate delay angle from the pulse width of the A-phase detector output
at TP7 for the X-bride and at TP12 for the Y-bridge. Calibrate the oscilloscope time-base at
20°/div (0.926 ms/div at 60 Hz). Read the gate delay angle directly from the TP7 and TP12 pulse
off the horizontal axis.
11.9. Vary the delay command voltage from 0 VDC to 5.0 VDC or from 0.9V to 5.9VDC.
Observe that the gate delay angle at TP7 and TP12 has the desired minimum and maximum
values.
11.10. To increase the minimum and maximum gate delay angles by an equal amount, increase
the value of the delay BIAS resistor, R32. To increase the difference between the maximum and
minimum delay angles, reduce the value of the delay SPAN resistor, R31.
Enerpro Document No: OP-0111; Rev. C Page 12 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 13

A.0 Appendix: Theory of Operation
A.1 Phase References
The phase references for the phase locked loop (PLL) delay angle generator are derived from the
two sets of 30° phase shifted three phase ac supply voltages that power the two SCR circuits.
These voltages are sensed at the gate trigger transformers8 on the firing board. The supply
voltages are processed by resistive attenuators, low pass filters, phasor addition circuitry, and
differential comparators.
The time constant of the low pass filter is selected to give a lagging phase shift of q = 60° at the
60 Hz operating frequency. A phasor addition technique adds a 60° phase lead, giving an
adjusted reference delay phase shift at 60 Hz of 60°-60° = 0°.
The six attenuated and filtered reference signals are applied to six voltage comparators. These
comparators are contained on LSI device U5 (EP1016). Additional circuitry is contained in U5 to
modify the comparator input signals to give correct reference phasing when the sequence of the
ac power is reversed.
A.2 Six Phase: Phase Locked Loop (PLL)
Three of the reference comparator outputs, designated as Aₓ, Bₓ, and Cₓ in Figure A.1, are
applied to three EX-OR phase detectors in LSI device U3 (EP1014). The other three reference
comparator outputs, designated as Ay, By, and Cy, are applied to the three EX-OR phase
detectors in LSI device U4 (EP1015). The other six inputs to the phase detectors are produced
by ring counters in LSI devices U3 and U4, as described below.
The outputs of the six phase detectors in U3 and U4 are summed with six 100kΩ resistors and
applied to the inverting input of the summing amplifier. The output of the summing amplifier sets
the frequency of the voltage controlled oscillator (VCO). This clock signal is designated as CK1
in Figure 1. The clock frequency is 384 (6 x 64) times the mains frequency when the PLL is in
lock. A ÷ 64 binary counter (BC) operates on CK1 to produce a second clock signal CK2 which
is six times the mains frequency. A ÷6 ring counter (RC1) outputs the three delayed phase
references for the EX-OR phase detector in U3.
An Inverter in LSI U4 produces the inverted clock signal NOT(CK2). This clock toggles a second
ring counter RC2 to produce the three delayed reference outputs A , B , and C . Because of
dy dy dy
the clock signal inversion, these references are shifted in phase by 30° from the corresponding
delayed reference signals A , B , and C in LSI device U3.
dx dx dx
The mains voltage refernces, Ax through Cy, are input into EX-NOR gates to produce the phase
detector outputs, Dax through Dcy.
The six phase detector outputs and the buffered delay command input must sum to a constant
value if the VCO frequency is to remain a fixed multiple of the mains frequency. Therefore, an
increase in the buffered delay command input must be accompanied by a corresponding
decrease in the average value of the summed phase detector outputs. Thus the dc level change
is produced by a proportional change in the delay angle between the mains frequency and the
delayed reference. A proportional relationship is enforced between the mains voltage phase
reference and the delayed phase references.
8
The value of this internal resistor (R) can be determined by the pulse module part number: All pulse modules used are EP1024-x,
where x=0 (R=OMIT), x = 1 (R=2.0MΩ, used at E>240Vac), x=2 (R = 511kΩ, used at 120Vac <E < 240Vac), and x = 3 (R = 200kΩ,
used at E < 120Vac).
Enerpro Document No: OP-0111; Rev. C Page 13 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 14

Figure A.1. 12-Pulse Gate Delay Generator Equivalent Circuit
A.3 Steady-State Transfer Function
The 0.9Vdc/5.9Vdc gate delay command signal is amplified by a factor of – 100/47.5 = 2.11 in the
buffer amplifier and applied through a pair of 8.87kΩ resistors to the inverting input of the
summing amplifier. The output voltage of the summing amplifier is at a constant average level (in
the range of 4.5Vdc to 5.5Vdc) when the PLL is in lock. This enforces the requirement that a
change in the output of the buffer amplifier be matched by a proportional and opposite change in
the average voltage at the outputs of the six EX-OR phase detectors. The factor of
proportionality is the ratio of the control signal input resistance (= 2 x 8.87kΩ = 17.74kΩ) to the
effective value of the resistance’s that sum the phase detector outputs (= 100kΩ/6 = 16.67kΩ).
Since a 180° change in the phase angle between the mains voltage phase references Aₓ through
C and the delayed phase references A through C corresponds to a 12Vdc change in each
y dx dy
EX-OR output, a change in the delay angle command, ΔSIG HI, results in a gate delay angle
change of Aα, of
Δɑ/ΔSIG HI = (100/47.5) x (16.7/17.74) x (180/12) = 29.67 °/ V
Enerpro Document No: OP-0111; Rev. C Page 14 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 15

A.4 Firing Board Frequency Response
Figure A.2. Phase Loss Circuit Signals – No Phase Loss
Note that figure A.2 shows the simplified block diagram of the PLL gate delay determinator.
Where “T” is the lead-lag time constant, “a” is scale factor relating gate delay angle to delay
command voltage, “c” is the summing amplifier gain, and “b” is the VCO integration constant.
Choosing T = 1/bc for pole-zero cancellation results in a simple lag transfer of
Enerpro Document No: OP-0111; Rev. C Page 15 of 16 ECO #20-11178; Release Date: 06/29/2020


---
## Page 16

For b = 1.5V/V and c = 300/sec.
This transfer function has 45° phase shift and -3db attenuation at w = 939 rad/sec (150Hz).
A.5 Gate Command Decoding
The delayed reference signals A , B , C and A , B , C are applied to decoding circuits in
dx dx dx dy dy dy
LSI devices U3 (EP1014) and U4 (EP1015) to produce the required 12 gate pulse signals. These
signals are precisely spaced by 30° and shifted in phase from the line-to-line voltage zero
crossings by phase angle a. The gate pulse profile is a “picket fence” of 128 pulses having a
50% duty cycle and a pulse width of 26 ms9. This profile is produced by decoding circuitry which
ANDs the 23,040 Hz clock CK1 with the 60Hz outputs of the ring counters in U3 and U4. Since
the gate pulse carrier is phased-locked to the mains frequency, the first pulse in the gate pulse
train always has a full 26 us pulse width.
A.6 Gate Pulse Amplifier
Circuitry shown in drawing E640 consisting of transistor arrays U10 and U11, resistors R1
through R8, capacitors C11 through C16, and gate pulse isolation modules PM1 through PM12
amplify and shape the Thyristor gate current pulses. Each pulse module consists of a 2:1 ratio
pulse transformer tested for 3500 V isolation, two secondary diodes, noise-suppression
rms
resistors across the primary and across the gate drive output, and a fuse in series with the output.
9 An optional pulse pattern is available consisting of: two 32 pulse, 6.5 ms wide, 6.5 ms spaced gate pulse trains.
Enerpro Document No: OP-0111; Rev. C Page 16 of 16 ECO #20-11178; Release Date: 06/29/2020
