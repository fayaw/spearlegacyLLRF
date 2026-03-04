# FCOG1200 Auto Balance

> **Source:** `hvps/controls/enerpro/enerproDocuments/FCOG1200 Auto Balance.pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 3


---
## Page 1

5780 Thornwood Drive
Goleta, California 93117 October 2, 1996
FCOG1200 REVISION F "AUTO-BALANCE" CIRCUIT
AMPLIFYING INSTRUCTIONS
Introduction
The FCOG1200 board was introduced in 1991 in order to meet the growing demand for 12-
Pulse power conversion. This demand was fueled by the increasingly stringent Total Harmonic
Distortion (THD) specifications being imposed by local utilities. The use of a 12-pulse
controller virtually eliminates the 5th and 7th harmonic and thereby lowers the systems THD.
Ideally, the phase shift transformer that powers the two 6-Pulse thyristor bridges, which make
up a 12-Pulse converter, provides two sets of three phase voltages equal in amplitude and phase
shifted by 30°. In practice, transformer imperfections cause a small open circuit voltage
unbalance, impedance unbalance, and a slight deviation from 30° phase shift. As a result,
individual bridge currents of the parallel 12-Pulse converter become unbalanced, the 5th and 7th
harmonics of the ac mains current are not completely canceled, and a dc ripple voltage at six
time the mains frequency appears on the converter output.
The upgraded FCOG1200 firing board provides three means of adjusting the nominal 30°
group delay in order to optimize the system performance. This optimization will allow you to
balance the bridge currents, thereby minimizing the ac current harmonics and dc ripple voltage.
The three methods are outlined below:
On-Board Trimpot Adjustment
This, the simplest means of control, is the default configuration of the FCOG1200 firing board.
For on-board trimpot adjustment the FCOG1200 is configured as follows:
R11 Installed (25.0kW pot.) R51 Installed (100kW )
R48 Omit U12 Omit
R49 Omit JU4 Omit
R50 Installed (100kW ) JU5 Omit
With this control method you will optimize the 12-Pulse system for operation at a particular
current level. This will ensure that the system provides balanced six phase current and minimum
THD at the optimized current level. However, as the dc current diverges from this optimum level
the transformer and firing board imperfections will cause the phase currents to diverge. This, in
turn, will cause an increased THD level on the ac mains.
Adjustment is performed by setting the dc output current at the desired level. Once you have
reached the desired level, monitor the input currents to the individual bridges and the dc output
current. Adjust the on-board trimpot, R11, as required to obtain balanced bridge input currents
(if required, adjust the command signal as necessary to maintain the desired dc output current).
On-Board Auto-Balance Control
This control method provides active control of the 30° group delay in order to optimize the
circuit at all dc output currents. Implementation of this control method requires two customer
provided current feedback signals, labeled "x" and "y" in Figure 1. These current feedback
signals may be derived from the bridge ac input currents, as shown, or from the individual
bridge output currents. The feedback signals should be of equal amplitude, approximately 1.0 -
- 1 - Version 10-2-96.


---
## Page 2

5.0Vdc. The feedback signals are then applied to J6 pins 14 and 15 on the FCOG1200 board
and the FCOG1200 board is configured as follows1:
R11 Omit R51 Installed (100kW )
R48 Installed (10.0kW ) U12 Installed (MC14070BCP)
R49 Installed (10.0kW ) JU4 Omit
R50 Installed (100kW ) JU5 Omit
J6
14 10.0k Ixy•CK2 + Ixy•CK2 TO
R48 475k SUMMING
R45 AMPLIFIER
3Ø TP18
"x"
Currents Rx 12+ Ixy
14 1
U8
13- 3
U12
2
AUTO-
100k BALANCE
R50
15 10.0k 100k
R49 R51
3Ø
"y"
Currents Ry CK2
FCOG1200 Board Configuration:
• Install U12, R48, and R49.
• Omit R11, JU4, and JU5.
Figure 1. On-Board Auto-Balance Circuit
This circuit operates by injecting a high frequency (6*fmains) square wave into the Voltage
Controlled Oscillator (VCO) summing amplifier. This square wave serves to increase the delay
angle (a ) of the high current bridge while reducing the delay angle of the low current bridge.
These delay angle adjustments will actively equalize the bridge input currents thereby ensuring
optimum system performance.
External Auto-Balance Control
The FCOG1200 Revision F firing board can also be controlled by an external auto-balance
circuit. This circuit will perform the same functions as the on-board auto-balance circuit but
could also provide regulation (closed-loop control). In this mode the FCOG1200 board is
configured as follows2:
1 The FCOG1200 board can be supplied with this configuration. Please request
that the boards be configured for "on-board auto-balance" when ordering.
2 The FCOG1200 board can be supplied with this configuration. Please request that
the boards be configured for "external auto-balance" when ordering.
- 2 - Version 10-2-96.


### Table 1

| 10.0k |
| --- |
|  |


### Table 2

|  |  |  |
| --- | --- | --- |
|  |  |  |
|  |  |  |


### Table 3

| 475k |
| --- |
|  |


### Table 4

| 100k |
| --- |
|  |


### Table 5

| 10.0k |
| --- |
|  |


### Table 6

| 100k |
| --- |
|  |


### Table 7

|  |  |  |
| --- | --- | --- |
|  |  |  |
|  |  |  |


---
## Page 3

R11 Omit R51 Omit
R48 Installed (10.0kW ) U12 Omit
R49 Jumper JU4 Installed
R50 Omit JU5 Installed
The high frequency (6*fmains) output of the external auto-balance circuit should be connected
to J6 pin 14 of the FCOG1200 board. If desired, the external circuit can obtain the CK2 and
NOT(CK2) signals at J6 pins 15 and 13, respectively.
ENERPRO INC.
5780 Thornwood Drive Phone: 805-683-2114
Goleta, California 93117 Fax: 805-964-0798
- 3 - Version 10-2-96.
