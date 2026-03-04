# Phase Control Theory

> **Source:** `hvps/controls/enerpro/enerproDocuments/PHASE CONTROL THEORY.PDF`
> **Type:** Comprehensive Technical Document
> **Processing Date:** 2026-03-04

## Executive Summary

This document provides comprehensive technical information extracted from the original source material. The content has been processed using advanced OCR and text extraction techniques to ensure all technical details are captured and made accessible for AI analysis and design work.

## Technical Specifications

- **Currents:** 1.0, 7, 2.0, 60, 9, 3.2, 8, 5, 1, 360
- **Power:** 180, 2
- **Voltages:** 7, 2, 0, 30, 5, 4, 15, 120, 12

## Detailed Content

### Page 1 (OCR Extracted)

GENERAL PURPOSE
THYRISTOR FIRING CIRCUIT
Frank J. Bourbeau
Enerpro Inc.
Goleta, California
U.S.A.
1. INTRODUCTION Recognizing the market need, we developed a
firing circuit in 1982 based on a technology origi-
A general purpose firing circuit board for phase _nally created for high voltage dc power transmis-
controlled thyristors provides the interface be- sion[1]. This technique, referred to variously as
tween the supervisory control element and the the “Ainsworth” or “biased detector” methods,
mains voltage portion of the power circuit. The utilizes a voltage controlled oscillator(VCO) that
availability of this firing board facilitates the de- is phase-locked to the mains frequency. The
sign of both conventional and unconventional oscillator output is counted down and split into
power supplies and motor controls with a mini- mx equidistant gate Pas commands Additional
mum of development expense. ogic circuitry was to provide features suc
P a as insensitivity to phase rotation and pulse train
This article describes the operating principle of | (“picket fence”) gating. The resulting firing
the firing circuit and details interesting applica- board design performed effectively but was too
tions in the area of induction generator control- Complex to become a viable product for general
lers, linear motor controllers, 12-pulse converters use.
and‘ cycloconverters. . ;
The timely arrival of CMOS LSI gate array tech-
Firing circuits operate in an environment of high nology offered a feasible way of reducing the
electrical noise and high voltage stress. Often, complexity of the gatedelay circuitry. As aresult,
they are exposed to high temperatures and atmos- a general purpose firing circuit could be design ed
. . with better performance and reliability in a more
pheric pollution as well. Further, the cost of the t package th ‘sting desi
firing board may be insignificant compared to the compact package than existing Cesigns.
overall cost of the power conversion equipment. The first generation firing circuit[2] incorporated
Thus the ume and expense of developing a reli- the digital elements in the LSI device. Subse-
able firing circuit may not be justified if a suitable quently, a new LSI device was designed to
alternative is readily available at a reasonable include the analog VCO along with additional
price. For these reasons, a substantial number of logic to produce a second set of six gate pulse
manufacturers of large but often limited quantity commands. These additional gate signals en-
power supplies and motor controls have standard- hanced the versatility of the firing board by ex-
ized on the Enerpro firing board. These firms tending the range of application to 4-quadrant
have purchased well over 13,000 firing boards —_—_ converters, 12-pulse converters and sequence re-
during the past five years. versing ac controllers. The second generation 40-
pin LSI device is shown in Figure 1. Figure 2
Prior to the early 1980's, available general pur- shows a 12-thyristor firing package made up of
pose firing circuit boards were based on magnetic the FCOG6100 main firing board and the
amplifier or RC charge discharge circuit technol- FCOAUX60 auxiliary firing board. The two-
ogy. These analog delay methods require com- board assembly is compact, measuring 190 mm
plex circuitry and do not provide stable balanced by 150 mm by 60 mm, and economical because
gate delay or long-term stability. only one gate delay generator is required.
Presented at the Drives/Motors/Controls Conference,
Birmingham England, Nov. 30 - Dec. 1, 1988

### Page 2 (OCR Extracted)

= ——r—“——s——M—h—h—h—h—hh— hF— .—SC—Fehshs—SsSsé—sShFmf i ircul ins its gate delay timin
rrr eee references from the mains voltages; E., E, and E,
ee — as shown in Figure 4. The outputs of the reference
a , signal processing circuit are the 180 wide, 120°
Se ~~ displaced, A-B-C logic signals which are inputs
— « = to the three EX-NOR phase detectors shown in
a a sgure 3. ne rererence signa’ P 8
/ 38 — | accomplishes the following objectives:
= —rr”~C—~—. ¢ Eliminate the need for reference sensing trans-
Figure 1. Phase Control LSI device .
tortion.
rr eee “Ce * Provide in-phase reference logic signals for ac
oe ~~ controller gating.
ee oft aR ee
lw . a os + Provide 30° lagging reference signals for con-
> ae. 2 _-_ > verter gating.
_@ ge EO” Vem — ¢ Provide proper reference phasing with positive
oh ee ae , << or negative sequence.
~~ : Pn ee ee rw The mains voltages E,, FE, and E, are attenuated by
~~ 2 llmrtrt—™ f 15/2000 by 2.0 megohm/15 kohm
~~ ae << a factor of 15/2000 by 2.0 megohm/
 & 7 oe Ce resistors to form the low level analogs of the
— 8 a a UmhmUmUr mains voltages; e,, ¢, and e.. These signals are
ka filtered by 150 kohm series resistors and .033 uF
Figure 2, 12-Thyristor Firing Package shunt capacitors, yielding the filtered phase refer-
7 DISCUSSION ence signals; e,.,e,,ande_. The RC circuits give
. 60° phase shift at 50 Hz. For 60 Hz operation, 60°
2.1 THEORY OF OPERATION phase shift is obtained by decreasing the filter
resistance to 120 kohm.
The block diagram for 12-thyristor gating is we . .
shown in Fi - yn gating A fictitious neutral signal, e., is created at the
S . common connection of three 15 kohm resistors
. . . connected to the 2.0 megohm sensing resistors.
The major elements of the firing circuit are the . . g gre
ar . The neutral signal is filtered and phase shifted by
phase reference circuit, buffer amplifier & soft .
‘rcuit. phase 1 ircuit. the vh 60° and designated ase ,
start/stop circuit, phase loss circuit, the phase- ;
locked loop delay generator, decoding circuit.
P ceray & , 6 * The 60° filter phase delay means that the refer-
gate pulse amplifiers and pulse transformers. .
ence for, say, the A phase must be derived from
2.1.1 Phase Ref Circui one of the other phases if the A phase reference is
_ to be in phase with the A phase mains voltage, as
The firing circuit utilizes phase reference signals js required to obtain 100% thyristor conduction.
derived by resistive attenuators from the three — Thereference phasor switching circuit consisting
mains voltages. This eliminates the usual refer- of the three single pole-double throw analog
ence sensing transformer and gives significant —_ switches, shown in Figure 4, is set by the phase
savings in size, weight and cost. Additional cir- sequence indicating logic signal, N, produced by
cuitry compensates for possible mains voltage _ the LSI device. These switches select the appro-
unbalance with respect to ground, thus providing _priate filtered reference signals for input to the
a balanced set of reference signals.
-2-

### Page 3 (OCR Extracted)

: +1299 :
: phase sequence signal :
: PHASE LOSS PHASE :
: INHIBIT EQUENCE AP |
CIRCUIT SENSING * 9
a sa
2 EP1011 |
= E, PHASE {+8P -
$ CONTROL : 2.
a ATTENUATORS, LSI [ 3
@ Ep LOW PASS FILTERS, DEVICE +CP | PULSE | & ae
E PHASOR SELECT Amps Ce | 5
Be] SWITCHES AND AND | ¢ a
COMPARATORS XFMRS | # =
@ Ee Cc >
© re <=
=} z: >
| eet—le!
| BxNor HE | 2
PHASE H |e
|_| DETECTORS | s
oP i |e
BUFFER AMP, SUMMING : ona
ate cela a = <3
conunend [ 7 E R
. 7? ie 3
+30 Vde | ool g
+12 Vde ‘Ky (19200 Hz) +CPi tl putse fe | S
120 Vac POWER u 7@| AMPS E 2
SUPPLY 5 Vde 48| AND {k 2
V4|XFMRS |p | =
om +6 cL Y | 8
Ill:
ae 3 ©
: Se us 2
— LE Ee |S
mt | 3
DECODE, —is E
INHIBIT P| ett. | FCOAUX6O |
bank select (P LOGIC gy AUXILIARY |
— Ls ssf FIRING |
1 Y a3 BOARD "
: lonai EC
7 FCOG6100 MAIN FIRING BOARD gy (optional) |
Figure 3. Firing Circuit Block Diagram
reference comparators. The operation of the in-phase references for ac controller gating or 30°
phase reference signal processing circuit is thus delayed references for converter gating.
unaffected by phase sequence.
The logic references for ac controller gating and
A programming plug on the firing board selects converter gating are shown in the table below:
-3-

### Page 4 (OCR Extracted)

Eq 2m @, 120k Co 7 “at ;
15k oP : > Cc ~o > C
E, ik “bf ®t i .
pul iD lice
E. i Sof : 5 ot il 5
Coed ettertp: CE ps
8 e N = 1 for neg. seq.
+5 n nf N = O for pos. seq.
7 N N
a. ac controller references b. converter references
Figure 4. Phase Reference Sensing Circuitry
reference The ohne hecked Looe
signal The phase locked loop gate delay angle genera-
tor, shown in Figure 5, consists of a summing am-
A SGNie.- €..) SGN(e..- e.) plifier, voltage controlled oscillator(VCO), di-
ian © wo? vide-by-64 counter, divide-by-6 counter/phase
B GN(E,,-€,) | SGN(e,,- &,,) splitter and three exclusive-NOR gates. The
Cc SGN(e,,-€,,) | SGN(e,,- €,,) multiple phase detectors and the single VCO
constitute a three phase PLL. This loop has
extremely fast response and achieves phase lock
A SGN(e,,- €,,.) | SGN(e,,- e,) within one cycle of the mains frequency.
B SGN(e,,-€,) | SGN(E,,- ,,)
Cc SGN SGN The VCO control voltage is the inverted sum of
(€.5- &,9) (€.5- 6,0) the three EX-NOR phase detector outputs and the
. dc signal output of the buffer amplifier. When the
Table 1. Phase Reference Selection loop is in lock, the VCO control voltage assumes
and average level which produces an average
2.1.2 Buffer Ampli - VCO output frequency equal to 64*6 = 384 times
The buffer amplifier prevents an out-of-range the mains frequency.
delay angle command signal from over-driving - . ;
the phase locked loop delay generator. The The 384*f_,,,, clock signal, designated as CK1, is
buffer amplifier operating with the SOFT- Counted down by 64 to give the O*f ain Clock
START/STOP circuit brings the thyristors into Signal, CK2. The latter clock signal is counted
conduction from a large initial gate delay angle down by 6 to equal the mains frequency and then
when gating is enabled with a contact opening or split into three 120° displaced 180° wide delayed
by application of 120 Vac power to the firing  Teference signal designated as A,, B, and C,. The
board. Similarly, when the enable contact is 4+ B,C mains voltage references and the A, B,
closed, the gate delay angle is ramped to a large and C, delayed references are input to the three
value before gating is inhibited.
-4—

### Page 5 (OCR Extracted)

EX-NOR gates to produce the phase detector — enforced between the dc input to the summing
outputs D,, D,, and D.. The phase detector out- —_ amplifier and the angular displacement between
puts are summed along with the buffered gate —_— the mains voltage phase references and the de-
delay layed phase references.
The three phase detector outputs and the buffered The minimum and maximum delay angles are
delay command inputs must sum to a constant —_Getermined by the values of the BIAS and SPAN
value if the VCO frequency is to remain a fixed resistors, shown in Figure 5a. These delay angle
multiple of the mains frequency. Therefore, an stops are selected according to the transfer char-
increase in the buffered delay command input _ acteristics of the thyristor circuit. For example, a
must be accompanied by a corresponding de- ——4_guadrant converter may require a delay angle
crease in the average value of the summed phase range of 30°to 150° to ensure reliable commuta-
detector outputs. Thus the dc level change, for tion, while an ac controller may be gated over a
example in the A-phase detector output, is pro- 175° to 5°range for 1% to 99% conduction.
duced by a proportional change in the delay angle
between the mains reference, A, andthe delayed The response time of the PLL gate delay angle
reference, A,. A proportional relationship is thus
bank select(P) 1
INHIBIT =
REFERENCE Ce od got
a noice Oe
COMPARATORS =
: =
ae iE
YYY
00k 100k 100k CK2(6*F mains”
107k 3 3 k
BIAS .068u 64 |
y
delay cmd BUFFER |10/0 V 26k 267k no ¥cCO
o/5 Vv AMPLIFIER SPAN > CK 1(384*f mains)
S
wa ae +5
a. circuit diagram
Oe _|st, +1 + S) 1 O
ST5 +1 . gumn K/S
b. block diagram for frequency response calculation
Figure 5. PLL Gate Delay Angle Generator
-5-

### Page 6 (OCR Extracted)

generator is set by the VCO integration constant, | referencesand CK1. Inthe example shown for the
K, time constants T1 andT2 of the inputhigh pass +A gate pulse:
filter and time constant T3 of the summing ampli-
fier feedback lowpass filter[3]. Typically: +A = ABsCKI.
K = 313 sec-l T1 = 166 usec Two 30° wide and 30° spaced bursts of 19,200 Hz
T2 = 1900 usec T3 = 73 usec carrier serve for converter gating. This profile
ensures that a gate pulse is present 60° after the
The frequency response of the gate delay genera-  imitial gate pulse. This is required aaa
tor is characterized by -3 dB attenuation at 129 Hz pean an discontinuous Current. us tor
and -45° phase shift at 548 Hz. A computer © +A gate logic:
program is available for computing the frequency +A = A,°B,«CK1+CK2.
response with arbitrary gain and time constants.

; ; . ‘Twelve-pulse conversion is used to eliminate the
Figure 6 shows the transient response of the firing 5th and 7th harmonics of the mains current nor-
circuit in combination with series-connected thy- mally present with 6-pulse conversion[4].
ristor and diode bridge converters operating into a
resistive load. Thedelay command voltageisa30 —_In the firing circuit under discussion, one main
Hz square wave. The gate delay angle rangais firing board and one simple slave firing board
135° to 45°. The inverting to rectifying transition provide the necessary 30° displaced sets of gate
is completed in 6.0 msec and from rectifying to Pulses. The LSI device is configured to output the
inverting in 3.0 msec. 30° displaced sets of gate pulses by simply con-

necting the 360 Hz clock to the polarity input(that
is, by making P= CK2). Thus, as shown in Figure
9d, the ° delayed double gate pulse burst
—— for the +A1 thyristor of the #1 bridge gated from
A \\\\ \ \ \ the main firing board is formed by:
eta eee
t \ \ \ V\ \ r \ \ \ \ +Al =A,°B,°CK1°P.

ae \ Laoag \ yr Likewise, the o° + 30° delayed burst for the

\ \ \ \ Ah \ - +A 2thyristor of the #2 bridge gated from the slave

\ ‘ . : \ 2 . : . .

7 \ \ \ \ \ \ firing board is derived from:
Bee ee Omput 1OOVAdiv 2.1.5 Pulse Amplifiers and Pulse Transformers
yottom trace: 30Hz delay command, 2V/div _
ime base: 5 msec/div The gate drive circuit consists of a 7-darlington
. . transistor IC, three 150 ohm/.33 uF primary volt-
Figure 6. Converter Transient Response age dropping networks, and six pulse modules.
14 fl . Each pulse module contains a 2:1 stepdown pulse
1.4 Gate Pulse Profile Selection transformer, two diodes, primary and secondary

. Deo. ; shunt resistors and an output fuse. The +A and -
‘igure 7a shows the timing diagram of the mains _ circuit, one third of the total, is shown in Figure
voltage references, delayed references, the ga. Figure 8b shows the output current pulse into
384*£ ing ClOCK(CK1), and the 6*f_ clock a 1.0 ohm load.

-CK2).
Prior to the beginning of the gate pulse burst, the
AC controller gating requires aburstof gatepulses  .33uF capacitor is discharged. Turn-on of the +A
hat is sustained for at least 120°. This pulse transistor effectively places the +30 V unregu-
rofile is produced by AND'ing the two delayed lated supply voltage across the pulse transformer
-6-

### Page 7 (OCR Extracted)

A __ owt
<- 60 120 180 240 300 360
A
B, Poo —="8
CK1 = 384*f_4,
CK2 = 6 * fans H [I] [a] __a __i i] —
a. mains voltage reference A, and delayed references A and B
e429
+A =A,°B,*CK1 | {QVEQCSLNUOUUCUEATUVILUGHIUTERIIITHE ' ' ;
b. decoding for ac controller gating
3°
ke 30
+A=A,°B, “Ck1+ Ck2 | uu rT
c. decoding for converter gating
P( = CK2) H Ca] Co co co TT]

! ! '
saveAj-8,-oKr-p Lill yyy
+A2 = A,*B,° CK1°P | UI IE

d. decoding for 12-pulse gating
Figure 7. Gate Pulse Command Decoding
' ~ ar : '
+30Vdc : 2:1 » aT : g :
+A gate : [a / : +A PULSE MODULE Su
+A gate ar | :
cmd : : K top trace: 1 A/div, 500 us/div
ileeed § Se bottom trace: 1 A/div, 2 us/div
a. circuit diagram b. current into 1.0 ohm load
Figure 8. Gate Pulse Driver Circuit
-7-

### Page 8 (OCR Extracted)

primary. This gives a load line for the initial pulse board finds its largest usage in the rectifier stage
in the burst characterized by 15 V open circuit of variable voltage input transistor inverter ac
voltage, 2.0 A short circuitcurrent. The initial gate = motor drives. Other major applications are large
current pulse rises to 1.0 A in 1.0 usec. The dc motor drives and dc power supplies for: high
average gate pulse width is 26 usec for 50 Hz — energy particle accelerator focussing magnets,
mains. During the 26 usec off time, the .33 uF vacuum arc furnaces, electro-plating and anodiz-
capacitor discharges to about 15 V. The second ing and vacuum sputterin
and succeeding pulses in the burst then have an é P 6
open circuit voltage of 15 V and a short circuit
current of 1.0 A. The lower amplitude sustaining A B Cc
gate pulses provide adequate gate drive for stable k k
operation with discontinuous load current while g g
economizing on the average gate power and dissi- ZN+A ZN+B £A+C
pation in the 150 ohm primary voltage dropping toad
resistor. kK K
g g
ZN {\-B ZN
The secondary circuit consists of a series diode to
prevent reverse gate current, a shunt diode to limit
reverse gate-cathode voltage, a 51 ohm noise +f B “A B C
suppression resistor and a fuse. The fuse prevents
Jamage to the board and cabling caused by mis- J1 J2
wired gate/cathode connections or by the unlikely FCOG6100 Firing Board
failure of a diode in the module. J3
3. APPLICATIONS +5 7 com) 17 +12
oon 4on

Modern high power thyristors employ amplifying —__F ~, off off
Zate structures. This permits the typical one Fi 9. Full Bridge Converter
ampere peak gate current pulse of the firing board sue”
o safely trigger thyristors with ratings exceeding 3.1.2 Star Rectifier
ne kiloampere. Applications of the general pur- The star rectifier, Figure 10, is often used in low
ose firing board thus extend from several kW to voltage/high current applications. An interphase
several mW. The lower power end of the range has transformer may be installed to broaden the trans-
Tended upward as bipolar and MOS transistor fomer secondary pulse from 60° to 120° to im-
levices become practical replacements for thyris- prove the transformer utilization. The trans-
Ors at higher power levels. Usage of the firing former primary is usually delta-connected to
doard is about evenly split between converters and provide a low impedance path for third harmonic
ac controllers. current.
3.1 CONVERTERS | 3.1.3 Four-Ouadrant Converter
3.1.1 Two -Ouadrant Bridge The circuit of Figure 11 consists of two independ-

Lo. oo _ nt bridges, #1 and #2. These are gated by the
lhe basic bridge converter connection diagram is main and auxiliary firing boards, respectively.
shown in Figure 9. The converter is 1-
juadrant(positive current, positive voltage) if the The four quadrant converter operates in the circu-
oad is passive or 2-quadrant(positive Current, —_—_Jating-current-free mode. Thatis, gating is inhib-
OSitive or negative voltage) if the load is active ited for an interval at each polarity transition to
and reversible. In 6-thyristor converters, the firing prevent simultaneous conduction of the #1 and

-8-

### Page 9 (OCR Extracted)

A B Cc
p____) Applications of the four-quadrant converter in-
——— clude rapid reversing dc motor drives, scrap mag-
| | a net reversing power supplies and three phase to
single phase frequency converters. Enerpro re-
cently developed a low frequency single phase
power supply for oil well stimulation using the
~¥ x * ES ~- ~*~ *& circuit of Figure 11.
octemal reeren 3.2 AC CONTROLLERS
3.2.1 In-line Controller
FCOG6100 Firing Board Figure 12 gives the connection diagram for the
basic in-line ac controller. With the addition of
13 ; I= = various regulator boards, this circuit controls:
) oat
i “Spf *resistance heating power.
Figure 10. Star Rectifier with Interphase “transformer primary voltage in high voltage or
Transformer gh current power supplies.
*starting current in reduced voltage solid-state
motor starters.
A B Cc *inrush current of wind powered asynchronous
—— generators.
aoe ae ae
en ee ee
\7 \7 v..
7X 7N as
A
XX fe] tty
= <
ZN [iN cN |
£ RESISTOR,
#1 converter #2 converter @ 8 > TRANSFORMER,
= wn MOTOR, OR
FCOG6100 -] FCOAUX60 > GENERATOR
Main = Auxillary ® N LOAD
Firing Firing Board £C la
Board ~
2 EE EY F 5 R
es
o—,. off neg 0
Figure 11. Four-Quadrant Converter = mage or
FCOG6100 Firing Board = Regulator
. . oe -{ Board
#2 bridges. An optional fixed time inhibit circuit 9 Iv € ~
can be installed on the main firing board, or a “| gon 8] I=} gon
variable time inhibit can be implemented based TH OQ Loff On off
on current or voltage sensing.
Figure 12. In-line AC Conttroller
-9_

### Page 10 (OCR Extracted)

3.2.2 Energy Saving Solid-State Starter A small amount of generator negative voltage
The reduced voltage motor starter control elec- feedback stabilizes the grid connection proc-
tronics can function with the built-in soft-start cir- ess[9].

cuit on the firing board, or aregulator board can be

added to program the motor starting current, volt- 3.2.4 Reversing and Two Speed

age or speed. Motor Controllers
The firing board and regulator board can also op- The main firing board and the auxiliary firing
erate the motor at reduced voltage at light load, © board can be arranged to gate a 10-thyristor ac
thereby improving efficiency by reducing the switch. In Figure 13, the switch output is config-
magnetizing current and associated losses[5]. ured to form a sequence reversing motor control-

ler. A minor variation of this circuit provides a
3.2.3 Induction Generator Controller two-speed motor or generator control.
The firing board has found a substantial use in In these applications, an open circuit at the polar-
wind power generation, where 1400* controllers ity signal input makes P = 1 and thus selects the
are installed with a rated capacity of about 150 main firing board to gate the thyristors designated
mW (approximately 8% of the world's grid con- as +AP, +BP, +C, -AP, -BP and -C. Similarly,
nected wind machines)[6]. connecting the P input to the circuit common
selects the auxiliary firing board to gate thyristors

The wind powered induction generator presents +AP, +BP, +C, -AP, -BP and -C.

an unusual control problem fortwo reasons; 1. the

generator must be connected and disconnected

from.the mains very frequently during light wind +P

conditions, and, 2. the generator operates a small >

fraction of its rating, and hence with higher than a S +AP
necessary magnetizing current and associated peo oa!
losses much of the time. Pepe | ‘4 |
It can be shown[7] that the fraction of the mains A be 4

voltage applied to the generator via the ac control-

ler is a function of the difference between the thy- three >
ristor gate delay angle and the generator imped- phase B ae a |

ance angle. In operation, the thyristors are gated AN

at an angle well in excess of 90°[8, 9]. When the Src

generator is rotating at less than synchronous Cae on

speed, the impedance angle is less than 90° and the 4

difference between the gate delay angle and the

impedance angle is large. The generator excitation 7 PS ==

i thus low, typically about 20% of the mains volt-
As the generator is driven by the input shaft to TAB SBP FG "AP TEP Ls
synchronous speed and above, the impedance
angle increases to more than 90° and the differ- _

ence between the gate delay angle and the power we n * 211 iS P
factor angle converges to zero, causing the gen- 1 * A ° ° pk
erator voltage to reach 100%(less the thyristor — “ial a.
on-state voltage drop). Figure 13. Ten-Thyristor AC Controller

-10-

### Page 11 (OCR Extracted)

An interesting example of a sequence reversing 5. REFERENCES
controller is shown in the photo, Figure 14. This . .
; photo, s1gu 1. J. Ainsworth, "The phase-locked oscillator -
assembly consists of 30 thyristors gated by three .
. . wae . A new control system for controlled static con-
main firing boards and three auxiliary firing- "
boards. These elements separately control the verters’, IEEE Trans. Power App, Syst, Vol.
oards. e m se ontro
parate’y Con PAS-87, pp. 859-865, Mar. 1969
forward and reverse thrust for three sections of a
large linear induction motor. These linear motors .
g din automobile and truck assembly plants 2 F: BOurbeau, "LSI based three-phase thyris-
are used in au oo.
we . . YP tor firing circuit", JEEE Trans, Ind, Appl., Vol,
tO position vehicle chassis for automated wheel
. . IA-19, pps. 571-578, Aug. 1983.
alignment and other operations.
tt .
FL 3. G. Nash, Phase-lock loop design fundamen-
a tals", Application Note AN-535, Motorola, Inc.
ee ee A 4. G. Moltgen, "Line commutated thyristor con-
- (eo ee 2 Publishing, London, 1972
_& A a a 5. F. Bourbeau, "Load responsive control system
_ | A 4 “ée - for constant speed induction motor", U.S, Patent
. ae No, 4,355,274, Oct. 19, 1982.
2  , ‘_rrrrsrs—S 6. F. Bourbeau, "Grid connection with Auto
Cc .rt~—”~—~———“ UC Synchronous Controller", ings of th
Figure 14. Triple Reversing Linear ergy Assn, Annual.Mecting,
Motor Controller San Francisco, Calif., Oct. 5-8, 1987.
7. F. Khater, D. Novotny, "Anequivalent-circuit
A CONCLUSIONS model for phase-back voltage control of ac ma-
chines", IEEE Trans, Ind. Appl, Vol.JA-22, pps.
This paper has described the operating concept 835-841, Sept./Oct. 1986.
and some major applications of a general purpose
hree phase thyristor gate firing board. 8. F. Nola, “Electrical power generating system",
ULS, Patent No, 4.388.585, June 14, 1983.
rhe firing board utilizes a technique for equidis-
ant gating that was originally developed for high 9. F. Bourbeau, "Stabilized control system and
voltage dc power transmission. The method was method for coupling an induction generator to ac
idapted and refined for purpose use and imple- power mains", U.S, Patent No. 4.656.413, Apr. 7,
nented with a CMOS gate array LSI device. The 1987.
esult is a compact, reliable and easy to apply
sroduct that been adopted by manufacturers of The author acknowledges the copywrite of In-
ower conversion and motor control equipment tertec Publications of Ventura, Calif. to portions
n a wide variety of industries. of this paper..
-11-


## Technical Analysis

This document contains important technical information for the HVPS system. The content has been extracted and processed to ensure maximum readability and accessibility for AI-driven analysis and design applications.

## System Integration

The information in this document is part of the comprehensive HVPS documentation system and should be considered in conjunction with related technical specifications, schematics, and operational procedures.
