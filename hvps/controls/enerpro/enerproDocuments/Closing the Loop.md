# Closing the Loop

> **Source:** `hvps/controls/enerpro/enerproDocuments/Closing the Loop.pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 1


---
## Page 1

CC LL OO SS II NN GG TT HH EE LL OO OO PP
Twelve-Pulse Converter With
Auto-Balance and Integrated Mag-
netics Cuts THD
Frank Bourbeau, ENERPRO Inc., Goleta, California
L
ine-commutated-thyristor converters and con- ripple voltage in the converter output.
trollers remain a viable way to convert and control An auto-balance method provides active control of the
three-phase power. They can achieve this because 30(cid:176) group thyristor gate delay angle to equalize the two
of the thyristor(cid:146)s inherent advantages: very high short-cir- bridge currents at all ac output levels. The circuit requires
cuit ruggedness, high voltage device availability and motor- two current feedback signals, labeled ix and iy (Figure 1).
winding-friendly switching characteristics. However, These current feedback signals are scaled to about 1.0V at
increasingly stringent Total Harmonic Distortion (THD) rated current. The current signals are applied to a voltage
specifications are shifting industry demand from tradition- comparator to create the logic signal, Ixy. The Ixy signal is
al six-pulse converters to the more sophisticated 12-pulse applied along with the 360 Hz clock signal CK2 to the
designs. input of the EX-OR gate. The attenuated EX-OR output
Twelve-pulse conversion reduces the harmonic demand is summed as a bang-bang balance control signal with the
on the ac supply by virtually eliminating the 5th and 7th gate delay command at the input to the Phase-Locked
current harmonics. Proven industry standard 12-pulse Loop (PLL). The balance control signal increases the gate
thyristor firing circuits con- delay angle of the high cur-
tribute to the practicality of rent bridge and reduces the
12-pulse conversion. How- gate delay angle of the low
ever, the cost of the mag- current bridge. The balance
netics remains a major bar- signal is scaled to produce a
rier to acceptance. maximum deviation in the
Automatic balancing of the group delay angle of –2(cid:176).
phase shift transformer The auto-balance circuit
loads and the combined reduces the difference in
interphase transformer and the two bridge currents to
dc choke described below Figure 1.12-pulse converter with auto-balance and interphase trans- typically 10% or less of the
promise to diminish these former/virtual choke. total dc output current.
barriers. IPTVC, the interphase
transformer/virtual choke, serves two functions. First, it
Phase Shift Transformer Imperfec-
provides the differential-mode inductance necessary to
tions
buffer the instantaneous dc output voltages of the paral-
The parallel 12-pulse converter (Figure 1) consists of leled six-pulse bridges. Additionally, the IPTVC eliminates
two 6-pulse thyristor bridges powered from a wye/delta the need for a separate dc choke by providing the common-
secondary isolation transformer to provide phase shifted ac mode inductance necessary to reduce the DC link ripple
power to each bridge. Ideally, the two sets of three-phase voltage and current to acceptable levels.
voltages are equal in amplitude and phase shifted by 30(cid:176). The IPTVC is created by winding coils on the outer legs
In practice, unequal leakage inductances and the inability of a three-leg core. The coupling between the coils on the
to achieve the ideal EMBED Equation.DSMT4 :1 turns outer legs provides the differential-mode inductance while
ratio between delta and wye windings causes a voltage the shunt flux path of the center leg creates the common-
imbalance and a deviation from 30(cid:176) phase shift. As a result, mode inductance.
there are unbalanced currents from the paralleled bridges.
For more information about the products or services covered in this article,
This leads to unequal heating of the transformer secondar- please use the reader service inquiry card and...CIRCLE 355
ies, imperfect harmonic cancellation and residual 360 Hz E-mail questions and comments to editor@pcim.com
6666(cid:149) PCIM NOVEMBER 1999
