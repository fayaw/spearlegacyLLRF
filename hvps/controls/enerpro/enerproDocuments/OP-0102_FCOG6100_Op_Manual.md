# OP-0102_FCOG6100_Op_Manual

> **Source:** `hvps/controls/enerpro/enerproDocuments/OP-0102_FCOG6100_Op_Manual.pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 10


---
## Page 1

http://www.enerpro-inc.com
info@enerpro-inc.com
99 Aero Camino Operations Manual: OP-0102
Goleta, California 93117 May 2018
Operating Manual: Six-SCR General Purpose Gate Firing Board
FCOG6100 Revision R
Introduction
This manual describes the salient features and specifications of the FCOG6100 firing board, including
typical firing circuit signal waveforms and a checkout procedure.
Product Description
1.0 Application
The firing board responds to a voltage or current delay angle command signal (SIG HI) to
produce a delayed set of six isolated, 60°-spaced high-current SCR gate firing pulses. Different
configurations are available for various types of SCR controllers or converters.
2.0 ASIC-Based Firing Circuit
All firing circuit logic is contained in a custom 24-pin ASIC. Additional detail on the firing circuit
theory is contained in a separate engineering society paper1.
3.0 Board Mounted Connectors
The firing board is connectorized to simplify maintenance and troubleshooting.
3.1. Gate/Cathode Connectors
The SCR gate/cathode interface is provided by 8-position Mate-N-Lok™ right-angle connectors2
J1 and J2. The connectors are keyed to prevent incorrect installation or reversal of the mating
plugs. Connector J1 accesses the gates and cathodes of the three SCRs having load-connected
cathodes when the SCRs are arranged in the in-line ac controller or bridge converter
configurations. Similarly, connector J2 accesses the gates and cathodes of the three SCRs
having line-connected cathodes. Plug P1 or P2 and the associated cable are omitted if the firing
board is used with 3-SCR/3-diode circuits.
3.2. Control Signal Connector
The firing board connects to the gate delay command and inhibit controls through a 12-position
Mate-N-Lok™ connector J3. This connector also accesses the output of the 24 Vac board
mounted transformer (if specified), the unregulated 30 VDC supply, and the regulated +12/+5
VDC outputs.
3.3. Optional Power Supply Excitation
The optional board-mounted 24 VA power supply transformer is normally energized by on-board
connection to two of the three mains voltages phases appearing at positions 5 and 8 of J2. When
the SCRs are powered from non-standard voltages, the user may energize the board-mounted
power supply transformer through the optional 5-position Mate-N-Lok™ connector J4. The 24 Vac
and 30 VDC connections on J3 permit the board to be powered from an external source if no
onboard transformer is specified. With the board-mounted transformer installed, approximately 10
watts are available on the 24 Vac and 30 VDC lines (via J3) to power lamps or control relays.
3.4. Optional Phase Reference Connector
In certain applications, the ac mains voltage may not be present at the SCR cathodes or the ac
voltage may go to zero during load faults3. In these cases, or when galvanic isolation is required
between power and control circuits, external phase reference voltages are applied through
optional Mate-N-Lok™ connector J5 and voltage sensing resistors R6, R7 and R8. These
1 Bourbeau, F. J., “Phase Control Thyristor Firing Circuit: Theory and Applications”, Power Quality ’89, Long Beach, California.
2 Vertical connectors are available upon request.
3 For example, in a 6-SCR interphase transformer converter or an arc welder converter.
Enerpro Document No: OP-0102, Rev. B Page 1 of 10 ECO #18-10957; Release Date: 05/15/2018


---
## Page 2

components are installed on the board space normally occupied by power supply transformer T1.
Board power is then obtained externally from 24 Vac or 30 VDC applied through J3.
3.5. Phase Reference Test Signal Input Connector
For low-power testing, users may connect low-level (5 V ) three-phase test reference signals to
PP
the three-position MTA header J7. Users may alternatively connect off-board phase reference
resistors at J7; this is a useful option if an onboard transformer is required and power may not be
derived from the SCR cathodes at J2 (see 3.4).
3.6. Auxiliary Regulator Board Connector
Several firing board signals are available at the 20-position ribbon cable connector J6 to facilitate
connection to a variety of standoff-mounted or “piggyback” regulator boards. These regulator
boards can provide various closed-loop functions (torque, speed, position voltage, power, etc.)
and diagnostic circuitry. The 20-position connector also facilitates board testing.
4.0 Gate Delay Command
The delay command signal, SIG HI, may be configured either as a 4 to 20 mA current command
or one of several voltage commands. The default SIG HI range is 0 to 5 Volts. The input
resistance presented to the delay command signal SIG HI is determined by resistor R42. This
value is selected as 10.0 kΩ when the control signal is designated as a control voltage. The
buffer amplifier resistance table below lists the resistor values associated with different command
signal levels. See also schematic diagram E128.
Table 1. SIG HI Range vs. Buffer Amplifier Component Values
SIG HI Resistance (in kΩ unless noted) Zener Voltage
Range R20 R32 R33 R34 R42 D6
0 to 5 V 100 130 46.4 1.00M 10.0 6.2
0.85 to 5.85 V 100 196 46.4 1.00M 10.0 6.2
0 to 10 V 100 omit 90.9 750 10.0 11
0 to 2 V 274 78.7 47.5 1.00M 10.0 6.2
4 to 20 mA 100 130 46.4 1.00M 249Ω 6.2
5.0 Gate Inhibits
SCR gating is inhibited by pulling either the instant inhibit, I¯ or soft inhibit, I¯ signal to ground.
1 2
These signals are located at J3 pin 4 and J3 pin 12, respectively.
The instant inhibit signal I¯ is normally pulled to ground through resistor R38 (1.50 kΩ). The user
1
typically connects the I¯ signal to +12 VDC to enable firing. This arrangement ensures that SCR
1
gating is inhibited if plug P3 is inadvertently disconnected. A jumper may be installed between
pins 4 and 6 of P3 to hold I¯ at +12 VDC at all times in applications where the instant inhibit is not
1
needed.
The soft inhibit signal I¯ is normally pulled to +12 VDC through resistor R37 (1.50 kΩ). The user
2
then grounds I¯ to soft-stop SCR firing. In this mode, the delay angle is ramped from the setpoint
2
value determined by SIG HI to the largest angle possible, after which firing is completely inhibited.
This is termed the soft-stop shutdown mode. When user opens the connection at I¯ , gating is
2
enabled with the delay angle set to the maximum limit. The delay angle then ramps to the value
determined by SIG HI. The soft-stop and soft-start time constants are independently configurable
via two timing resistors (R28 and R36 respectively) and a capacitor (C11).
6.0 Phase Loss Inhibit
The FCOG6100’s phase loss circuit instantly inhibits SCR gating if the mains voltage phases are
grossly imbalanced or, in the extreme case, if one or more phase voltages are missing. This
feature also eliminates the possibility of erratic response associated with voltage imbalance or
transients when the three-phase mains are initially connected to the SCRs. After any phase loss
Enerpro Document No: OP-0102; Rev. B Page 2 of 10 ECO #18-10957; Release Date: 05/15/2018


### Table 1

| SIG HI Range | Resistance (in kΩ unless noted) |  |  |  |  | Zener Voltage |
| --- | --- | --- | --- | --- | --- | --- |
|  | R20 | R32 | R33 | R34 | R42 | D6 |
| 0 to 5 V | 100 | 130 | 46.4 | 1.00M | 10.0 | 6.2 |
| 0.85 to 5.85 V | 100 | 196 | 46.4 | 1.00M | 10.0 | 6.2 |
| 0 to 10 V | 100 | omit | 90.9 | 750 | 10.0 | 11 |
| 0 to 2 V | 274 | 78.7 | 47.5 | 1.00M | 10.0 | 6.2 |
| 4 to 20 mA | 100 | 130 | 46.4 | 1.00M | 249Ω | 6.2 |


---
## Page 3

fault, the board soft-starts when the fault is cleared. It should also be noted that the phase loss
circuit featured on the Revision R is immune to line frequency variations and transient voltages on
the SIG HI line.
Figure 1. Phase Loss Circuit Signals – No Phase Loss4
Channels: 1. Digital A Phase Reference Signal, U6 P11
2. Digital B Phase Reference Signal, U6 P9
3. A and B logic signal, TP8
4. P¯L Signal, U6 P1
Figure 2. Phase Loss Circuit Signals – Phase Loss
Channels: 1. Digital A Phase Reference Signal, U6 P11
2. Digital B Phase Reference Signal, U6 P9
3. A and B logic signal, TP8
4. P¯L Signal, U6 P1
7.0 Phase Reference Shift Selection
A first-order RC lowpass filter (formed by RN6 and capacitors C17-19) shifts the mains phase
references by 0° (for controller applications) or by 30° lagging (for converter applications).
4 All waveforms contained in this document were obtained with the FCOG6100 revision R firing board connected to 240 Vac, 60 Hz,
balanced 3-phase power via sockets 2, 5, and 8 of plug P2. The time base of each screenshot has been calibrated for phase
measurements as noted at 60 Hz. All component designations refer to drawing E128, revision R.
Enerpro Document No: OP-0102; Rev. B Page 3 of 10 ECO #18-10957; Release Date: 05/15/2018


---
## Page 4

For 30° lagging references, the previously referenced capacitors are 0.033 μF film capacitors and
RN6 is a 120 kΩ, three-position, isolated SIP resistor network.
Figure 3. Thirty-degree shifted phase references, Phase A
Channel: 4. Phase A Line-to-Neutral Voltage
1. Attenuated and Filtered Mains Voltage at RN6-3
3. Reference Comparator Output, TP5
For 0° references, 0.01 μF film capacitors may be installed with RN6 = 120 kΩ. Alternatively,
0.033 μF film capacitors may be used with a 33 kΩ resistor network installed at RN6 for 0° shifted
references. This is an optimal scheme if the same firing board may be used to fire controllers or
converters, as the user may then simply change RN6 (typically supplied in a socket in this case)
to achieve the required phase shift.
Figure 4. Zero-degree shifted phase references, Phase A
Channel: 4. Phase A Line-to-Neutral Voltage
1. Attenuated and Filtered Mains Voltage at RN6-3
3. Reference Comparator Output, TP5
Enerpro Document No: OP-0102; Rev. B Page 4 of 10 ECO #18-10957; Release Date: 05/15/2018


---
## Page 5

8.0 Gate Pulse Generation
Two-position jumper JU1 enables gate pulse profile selection. With JU1 installed, the pulse profile
is two 30°-wide bursts, each with an initial hard-firing gate pulse and followed by sustaining
“picket fence” pulses. With the jumper omitted, the gate pulse profile changes to a single 120°-
wide burst with the same hard-firing initial pulse. The initial hard-firing pulse and sustaining pulses
ensure continuous SCR conduction over the required period.
Figure 5. 2-30° Gate Pulse Profile (Into 1Ω) 5.
Figure 6. 120° Gate Pulse Profile (Into 1Ω).
5 Current waveforms obtained using a Pearson model 2877 current transformer with 4 primary turns. The current transformer is
terminated by the scope’s 1.0 MΩ input impedance.
Enerpro Document No: OP-0102; Rev. B Page 5 of 10 ECO #18-10957; Release Date: 05/15/2018


---
## Page 6

Figure 7. Initial pulse profile detail (Into 1Ω).
The firing circuit uses a phase-locked loop (PLL) to lock the firing pulses to the three mains
phases. A series of counters divide the PLL’s oscillator output and a decoder section then
generates six 120°- wide delayed logic signals. For the 120° single burst profile, the 120°-wide
delayed logic signals are modulated by the PLL’s voltage controlled oscillator (VCO) output signal
which operates at 384 times the ac line frequency. The two 30°-burst profile is formed by
modulating the 120°-wide delayed logic signals with the VCO output and the output of a divide-
by-64 counter.
Figure 8. Phase Detector Signals, Phase A: α=15°
Channels: 1. Phase A Reference, TP5
2. Delayed Ring Counter Output, TP6
3. Phase Detector Output, TP3
Enerpro Document No: OP-0102; Rev. B Page 6 of 10 ECO #18-10957; Release Date: 05/15/2018


---
## Page 7

Figure 9. Phase Detector Signals, Phase A: α=150°
Channels: 1. Phase A Reference, TP5
2. Delayed Ring Counter Output, TP6
3. Phase Detector Output, TP3
Figure 10. PLL Summing Amplifier Signals: α=15°
Channels: 1. A Phase Detector Output, TP3 (U3 P15)
2. B Phase Detector Output, U3 P14
3. C Phase Detector Output, U3 P13
4. Summing Amplifier Output, TP2
Enerpro Document No: OP-0102; Rev. B Page 7 of 10 ECO #18-10957; Release Date: 05/15/2018


---
## Page 8

Figure 11. PLL Summing Amplifier Signals: α=150°
Channels: 1. A Phase Detector Output, TP3 (U3 P15)
2. B Phase Detector Output, U3 P14
3. C Phase Detector Output, U3 P13
4. Summing Amplifier Output, TP2
Each gate logic signal drives the gate of an IRFD110 MOSFET (Q1-Q6) which in turn excite each
primary winding of six isolated pulse modules. The primary winding of each pulse transformer is
also connected to a current-limiting resistor (R3-R5) and a speed-up capacitor (C2-C4); this
provides an initial hard-firing gate pulse followed by sustaining, lower amplitude picket fence
pulses.
Each pulse module consists of a 2:1 ratio pulse transformer tested for 3500 V isolation, two
RMS
secondary diodes, noise suppression resistors across the primary and across the gate drive
output, and a fusible link in series with the output. Each pulse module is potted in a silicone
insulating material.
The DDFO6100 (delay determinator fiber optic) is a version of the FCOG6100 with fiber optic
outputs replacing the pulse transformers. Six FO1024 modules are installed which feature Avago
HFBR-1412Z fiber optic transmitters in lieu of the EP1024 modules. The transmitters feature ST
(bayonet) style connectors, operate at 820 nm and are directly compatible with the MVTB series
of medium voltage trigger boards. Each module has an LED to indicate that the fiber optic
transmitter is operational. Please specify this configuration on your ordering documents or contact
Enerpro for additional information.
9.0 50/60 Hz Operation
The FCOG6100 revision R features a new compensation circuit that reduces delay angle
variance with respect to frequency. The gate drive angle decreases approximately 5° for a
frequency change from 60 to 50 Hz, whereas the delay angle of previous revisions decreased
12.5° over the same frequency range.
For operation with line frequencies in the range of 45 to 65 Hz, no modification to the frequency
compensation circuit is required. For variable-frequency applications, Enerpro’s FCOVF6100
provides similar functionality as the FCOG6100, but is tailored for operation between 30 and 150
Hz.
Enerpro Document No: OP-0102; Rev. B Page 8 of 10 ECO #18-10957; Release Date: 05/15/2018


---
## Page 9

10.0 Electrical Specifications
Table 2. Specifications.
Maximum Ratings
AC mains voltage 600 Vac
Pulse transformer hipot 3500 Vac (60 seconds)
Operating temperature range -5 C to 85 C
Board ac supply voltage 28 Vac (24 Vac nominal)
12 V regulator output current 20 mA (30 VDC supply)
5 V reference output current 5 mA (30 VDC supply)
Auxiliary control power output from 24 Vac/30 VDC 10 W
Delay angle range 6° ≤ α ≤ 174°
Electrical Characteristics
Delay angle command signal, SIG HI Voltage: 0-5, 0.85-5.85, 0-10, 0-2 V
Current: 4-20 mA
Or per customer specification
Delay angle reference phase shift 0° or -30° (application-specific)
Control signal isolation from ground 653 kΩ (For higher isolation, use transformer
coupled phase references)
Gate delay steady-state transfer function Delay angle decreases as SIG HI increases
Gate delay dynamic transfer function bandwidth -3 dB at 119 Hz, phase shift -45° at 68 Hz
Gate drive phase balance ±1° (max)
Delay angle variance Δ(α)/Δ(f) = 0.5°/Hz
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
2-30° bursts, 30° spaced
Gate pulse burst frequency 384 times line frequency
Gate pulse width, 50 Hz 20-22 μs
Gate pulse width, 60 Hz 24-26 μs
Initial gate pulse open circuit voltage 15 V (30 VDC supply)
Sustaining gate pulse open circuit voltage 7.0 V (30 VDC supply)
Peak gate drive short circuit current 2.0 A (30 VDC supply, 1.0 Ω gate load)
Sustaining gate drive short circuit current 0.5 A (30 VDC supply, 1.0 Ω gate load)
Short-circuit gate drive current rise time 1.0 A/μs (30 VDC supply, 1.0 Ω gate load)
Board dimensions 191 x 152 x 35 mm (L x W x D)
Minimum creepage distance to ac mains
With onboard phase references 13 mm
With phase references entering on J5 5.0 mm
Conformal coating per MIL-1-46058, Type UR
Enerpro Document No: OP-0102; Rev. B Page 9 of 10 ECO #18-10957; Release Date: 05/15/2018


### Table 1

| Maximum Ratings |  |
| --- | --- |
| AC mains voltage | 600 Vac |
| Pulse transformer hipot | 3500 Vac (60 seconds) |
| Operating temperature range | -5 C to 85 C |
| Board ac supply voltage | 28 Vac (24 Vac nominal) |
| 12 V regulator output current | 20 mA (30 VDC supply) |
| 5 V reference output current | 5 mA (30 VDC supply) |
| Auxiliary control power output from 24 Vac/30 VDC | 10 W |
| Delay angle range | 6° ≤ α ≤ 174° |
| Electrical Characteristics |  |
| Delay angle command signal, SIG HI | Voltage: 0-5, 0.85-5.85, 0-10, 0-2 V Current: 4-20 mA Or per customer specification |
| Delay angle reference phase shift | 0° or -30° (application-specific) |
| Control signal isolation from ground | 653 kΩ (For higher isolation, use transformer coupled phase references) |
| Gate delay steady-state transfer function | Delay angle decreases as SIG HI increases |
| Gate delay dynamic transfer function bandwidth | -3 dB at 119 Hz, phase shift -45° at 68 Hz |
| Gate drive phase balance | ±1° (max) |
| Delay angle variance | Δ(α)/Δ(f) = 0.5°/Hz |
| Mains voltage distortion effect | Firing not affected by zero crossing; phase reference filter attenuation is 12.8 dB relative to fundamental at 5th harmonic |
| Lock acquisition time | 30 ms (typ) |
| Soft-start/stop time (independently configurable) | 0.05 – 20.0 s (typical) |
| Phase rotation effect | None |
| Phase loss inhibit | Automatic |
| Power-on inhibit | Automatic |
| Instant/soft inhibit/enable inputs | Dry contact |
| SCR gate pulse waveform (jumper selectable) | 120° burst or 2-30° bursts, 30° spaced |
| Gate pulse burst frequency | 384 times line frequency |
| Gate pulse width, 50 Hz | 20-22 μs |
| Gate pulse width, 60 Hz | 24-26 μs |
| Initial gate pulse open circuit voltage | 15 V (30 VDC supply) |
| Sustaining gate pulse open circuit voltage | 7.0 V (30 VDC supply) |
| Peak gate drive short circuit current | 2.0 A (30 VDC supply, 1.0 Ω gate load) |
| Sustaining gate drive short circuit current | 0.5 A (30 VDC supply, 1.0 Ω gate load) |
| Short-circuit gate drive current rise time | 1.0 A/μs (30 VDC supply, 1.0 Ω gate load) |
| Board dimensions | 191 x 152 x 35 mm (L x W x D) |
| Minimum creepage distance to ac mains With onboard phase references With phase references entering on J5 | 13 mm 5.0 mm |
| Conformal coating | per MIL-1-46058, Type UR |


---
## Page 10

11.0 Installation and Checkout
The following procedure should be followed to ensure proper operation prior to the application of
mains power to the SCR unit. An EP1032A transformer (240V/480Vac) T1 and 0-5V SIG HI delay
angle command signal is assumed.
11.1. Ensure that the power is off. Wire a plug, P2, with mains voltage connected to sockets 2,
5, and 8. Insert plug P2 into connector J2.
11.2. If the FCOG6100 board is set up to obtain board power from the SCR cathodes proceed
to step 12.3. If not, connect the appropriate power to J4; J4-1 and J4-5 for 480Vac or J4-3 and
J4-5 for 240Vac board power.
11.3. Install plug P3 with a 0-5 Vdc SIG HI delay command signal, signal common, and
instant/soft inhibit controls wired to the plug.
11.4. Energize the mains voltage; this will energize the FCOG6100 board. (Alternatively,
energize the mains voltage and then energize the FCOG6100 with the appropriate ac voltage on
J4, or with 24 Vac, 30 VDC on J3).
11.5. Verify the presence of regulated +12 VDC ± 5% at J3-6 and regulated +5 VDC ±5% at
J3-7 with a multimeter.
11.6. Verify that the PLL is in lock and the mains voltages are balanced by noting the Phase
Loss LED is not lit.
11.7. Verify that the DC level of the VCO control voltage at TP2 is approximately 5.0 VDC. This
voltage is factory-set by selection of the VCO timing select resistor.
11.8. Determine the PLL gate delay angle from the pulse width of the A-phase detector output
at TP3: Calibrate the oscilloscope time-base at 20°/div (0.926 ms/div at 60 Hz). Read the gate
delay angle directly from the TP3 pulse off the horizontal axis.
11.9. Vary the delay command voltage from 0 VDC to 5.0 VDC. Observe that the gate delay
angle at TP3 has the desired minimum and maximum values.
Enerpro Document No: OP-0102; Rev. B Page 10 of 10 ECO #18-10957; Release Date: 05/15/2018
