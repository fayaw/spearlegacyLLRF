# slac-pub-7591

> **Source:** `hvps/architecture/originalDocuments/slac-pub-7591.pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 5


---
## Page 1

I :
SLAC-PUB-7591
July 1997
A Unique Power Supply for the PEP II Klystron at SLAC*
R. Case1 and M. N. Nguyen
Stanford Linear Accelerator Center
Stanford University, Stanford, CA 94309
Presented at the 17th IEEE Particle Accelerator Conference: Accelerator Science, Technology and
Applications, Vancouver, B.C., Canada,
5/12/97-5116197
*Work supported by Department of Energy contract DE-AC03-76SFOO.515.


---
## Page 2

SLAC-PUB-7591
July 1997
A UNIQUE POWER SUPPLY FOR THE PEP II KLYSTRON AT
SLAC
R. Cassel & M.N. Nguyen
Stanford Linear Accelerator Center, Stanford University, Stanford CA 94309
Abstract
Each of the eight 1.2 MW RF klystrons for the PEP-II storage rings require a 2.5
MVA DC power supply of 83 Kv at 23 amps. The design for the suply was based
on three factors: low cost, small size to fit existing substation pads, and good
protection against damage to the klystron including klystrong gun arcs. The supply
uses a 12 pulse 12.5 KV primary thyristor “star point controller” with primary filter
inductor to provide rapid voltage control, good voltage regulation, and fast turn off
during klystron tube faults. The supply also uses a unique secondary rectifier, filter
capacitor configuration to minimize the energy available under a klystron fault. The
voltage control is from O-90 KV with a regulation of < 0.1% and voltage ripple of c
1% P-P, (< 0.2% RMS.) above 60 KV. The supply utilizes a thyristor crowbar,
which under a klystron tube arc limits the energy in the klystron arc to < 5 joules.
If the thyristor crobar is disabled the energy supplied is < 40 joules into the arc.
The size of the supply was reduced small enough to fit the existing PEP transformer
yard pads. The cost of the power supply was < $140 per KVA.
Submitted to 1997 Particle Accelerator Conference Proceedings


---
## Page 3

A UNIQUE POWER SUPPLY FOR THE PEP11 KLYSTRON AT SLAC
R. Cassel & M. N. Nguyen ‘, Stanford Linear Accelerator Center
Abstract reduces the size of the Power supply over more
conventional WT adjusted power supplies as well as
Each of the eight 1.2 MW RF klystrons for the PEP-II provides for fast voltage adjustment and fault protection.
storage rings require a 2.5 h4YA DC power supply of 83 The SCR’s were configured in the so-called star point
Kv at 23 amps. The design for the supply was base on controller configuration with the filter inductor in the
three factors low cost, small size to fit existing substation primary. A configuration commonly used in Europe in
pads, and good protection against damage to the klystron fusion research [l]. This configuration is ideally suited
including klystron gun arcs. The supply uses a 12 pulse for an inductive capacitor filtered supply were bypassing
12.5 KV primary thyristor “star point controller” with of the stored energy in the filter inductor is important.
primary filter inductor to provide rapid voltage control, The rectifier configuration is a unique arrangement
good voltage regulation, and fast turn off during klystron which prevent/ reduces the dumping of the stored energy
tube faults. The supply also uses a unique secondary in the filter capacitor into the klystron under a klystron
rectifier, filter capacitor configuration to minimize the arc Figure 1.
energy available under a klystron fault. The voltage
control is from O-90 KV with a regulation of ~0.1% and
voltage ripple of < 1% P-P, (< 0.2% RMS.) above 60
KV. The supply utilizes a thyristor crowbar, which under
a klystron tube arc limits the energy in the -klystron arc to
< 5 joules. If the thyristor crowbar is disabled the energy
supplied is < 40 joules into the arc. The size of the
supply was reduced small enough to fit the existing PEP
transformer yard pads. The cost of the power supply was
< $140 per KVA.
- 1.0 De&n considerations
The SLAC PEP-II storage rings require eight 1.2 MW
RF klystrons powered by eight 2.5 MVA DC power
supply at 83 Kv, 23 amps. The design consideration Figure 1 Power supply schematic
besides low cost were: 1) Small size so as to fit on
existing PEP transformer pads. 2) Good protection The primary 12.5Kv enters without a Manual Load
against damage to the klystron from RF and klystron gun breaker disco~ect used for Safety lock and tag
arcs. 3) Rapid Voltage adjustment to accommodate disconnection for maintenance. The supply is energized
changes in beam loading and rapped conditioning of the by way of a fbll fault rated Vacuum breaker used as a
cavities. 4) Good voltage regulation for stability with the contactor. The breaker has independent overcurrent
stored beam. In addition the power supply was designed relaying and transformer sudden pressure lockout in case
to accommodate a Depressed Collector Klystron if it of a transformer or SCR fault. To reduce the amount of
were to be developed for power efficiency power line harmonics to meet the industrial standards a
reasons 12-p&e configuration was chosen. To accomplish the
12-phase operation with a Wye co~ected primary
1.2 Conjiguration Selection controller a phase shifting transformer is used. The use
of a delta with extension windings to produce the f15O
The supply ‘uxifiguration chosen was the use of a
was selected because the phase shifted output voltages
Primary SCR controlled rectitier operating at 12.5kv the
are only 4% larger than the incoming line voltages. The
existing site wide distribution voltage. This chose
nominal size of the phase shifting transformer is less
+ *Work supported by DOE, contract DE-AC03-76SF005 1


---
## Page 4

than 15% of the full load MVA. The rectitier than the specikations of 1% Peak to Peak voltage
transformers consist of two, open Wye primary dual Wye ripple.
secondaries, transformers used to step up the voltage. A SCR Crowbar is co~e~ted across the output rectifier
The SCR controller is connected to the open Wye, with to crowbar the supply in the event of a klystron arc.
the filter inductor on the primary side. The secondary
1,3 Klystron arc protection
windings are taped with main power rectifier connected
in a full wave bridge configuration to the full current Protection of the klystron tube under a klystron arc is of
rated taps The 5% voltage extension is used by the extremely important. The klystron is very expensive and
filtering rectifier which is a low current full wave bridge will probably arc at some time. To protect the klystron
configuration. The filter rectifiers is loaded by the filter under arc condition the joules delivered by the power
capacitor, which is coupled to the output load by way of supply should not exceed 60 Joules or an 14 of 40
high ohmage resistors which limits the current in the amp2seconds [2]. In conventional supplies this is
filter rectifier to approximately 1 amp maximum. This is accomplished by use of fast crowbar and a series resistor.
enough current to bleed off the voltage on the filter The series resistor is typically lo-50 ohms which results
capacitor to allow for complete voltage filtering of the in vary large power losses at high voltages. If the
supply at 6OKv output voltage. crowbar fails in anyway the klystron would be destroyed
Figures 2 & Figure 3 show the output voltage, filter because of the large amount of energy involved.
inductor ripple voltage, and the secondary transformers With the new design although there is a slower SCR
line to line voltage waveforms. crowbar, failure of the crowbar or any other single point
failure will not result in the destruction of the klystron
KLYSTRON POWER SUPPLY The main stored energy from the capacitor back is
isolated by use of the filter capacitor and isolating
85KV DC lx Ripple voltage resistors which in the event of a crowbar failure results
in only 50 amps for 4 milliseconds and a I? of ~15
amp2seconds with less than 40 Joules in a arc to the
klystron. The Primary star point control with filter
Filter Inductor Voltngs \
inductor allows for the bypass of the filter inductors
energy under klystron fault conditions by turn on both
SCR’s in one phase and turning off all the other SCR’s.
The result is the isolating of the load from the power line
and the discharge of the energy in the filter inductor into
its resistance. The result of an arc is seen in figure 4 on
the klystron and figure 5 on the primary line current.
2 msldiv
Figure 2 Output ripple 85Kv KLYSTRON ARC VOLTAGE/CURRENT
KLYSTRON POWER SUPPLY
I=” fl
IiLYSlRON ARC VOLTAGE
WV
/atv
ter Inductor Voltage
KLYSIRON ARC CURRENT
-19.9&m
Figure 3 Output ripple at 60KV Figure 4 Klystron Arc current & voltage
The output voltage ripple is greater at 60kv due to the The distribution cable discharge current is reduced as
larger ripple voltage across the filter inductor caused by well as a forced current zero by the use of small 200 uhy
phasing back the SCR’s. The ripple voltage is still less inductors in the termination tank. With the crowbar his


---
## Page 5

combination allows less than 5 joules to reach the
klystron and less than 20 joules without the crowbar
operating. The crowbar has a delay time of
approximately 10 microseconds before it conducts
current.
AC CURRENT WITH KLYSTRON ARC
0”
I
10kwDiv
AC CURRENT
1O KV/DIV I
CLYSTRON VOLTAGEt \
14
1OOkv 2.5m Jdiv _ Figure 5 Internal power supply tank parts
Figure 5 klystron arc line current
When the klystron arcs the primary current rate of rise is
limited by the primary filter inductor until the inductor is
bypassed and the primary SCR’s are turned off. The
. complete interruption of current on the primary side last
from 4 to 8 milliseconds depending on the exact time of
the arc with respect to the firing of the SCR’s. As you
can see the primary current only double under this fault
condition for 2 milliseconds.
1.4 Power supply size
Because of size constraints and the fact that all the
components would be at high voltage and high power the Figure 6 Power supply installation
SCR Primary controller and SCR Crowbar were mounted
in the transformer oil tank in isolated oil tanks. The The power supply transformers, rectifiers, and
tanks have oil to oil high voltage feed through to prevent transformers tank were manufactured by NWL
cross contamination of the oil in the event a crowbar or Transformer. The SCR Primary controller and the SCR
SCR stack would need maintenance. crowbar was manufactured and tested by SLAC and
The crowbar tank consists of 4 SCR stacks with snubber installed by NWL into their transformer tanks.
network to match the output cable impedance. In
addition there are two voltage dividers to monitor the REFERENCES
high voltage output.
[l] ‘I-IV-Power Supply for Neutral-Injection Experiments
The SCR Primary control tank consist of 12 SCR stacks
Wendelstein VII and ASDEX’ by D Hrabal, R
with 12 snubber networks to limit the rate of rise of
Kunze, W. Weigand, Proceedings of the 8*
voltage and d%mp the stray capacitance ringing. Symposium on Engineering Problems of Fusion
The transformer tank contains two filter inductors two Research, IEEE Pub No. 79CH1441-5 NPS. Page
power transformers, one phase shifting transformer, 1005-1009
4 filter diode rectifier stack, 4 filter capacitors, 8 filter [2] ‘InstaIling and Operating Klystron YK1360’
PHILIPS manual, Issue #I May 1996, Rev. Sept 1996
resistors loads, and 4 power diode rectilier- stacks. See
page 11.
figure 6
