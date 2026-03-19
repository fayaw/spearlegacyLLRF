# SLAC-PUB-7591 — Transcription

**Original Document:** `slac-pub-7591.pdf`
**Document Type:** Published Technical Paper (5 pages)
**Transcription Method:** Combined pymupdf text extraction and Tesseract OCR

---

## Page 1 — Title Page

SLAC-PUB-7591
July 1997

### A Unique Power Supply for the PEP II Klystron at SLAC*

R. Cassel and M. N. Nguyen

Stanford Linear Accelerator Center
Stanford University, Stanford, CA 94309

Presented at the 17th IEEE Particle Accelerator Conference: Accelerator Science, Technology and Applications, Vancouver, B.C., Canada,

5/12/97–5/16/97

*Work supported by Department of Energy contract DE-AC03–76SF00515.

---

## Page 2 — Abstract Page

SLAC-PUB-7591
July 1997

### A UNIQUE POWER SUPPLY FOR THE PEP II KLYSTRON AT SLAC

R. Cassel & M.N. Nguyen
Stanford Linear Accelerator Center, Stanford University, Stanford CA 94309

#### Abstract

Each of the eight 1.2 MW RF klystrons for the PEP-II storage rings require a 2.5 MVA DC power supply of 83 Kv at 23 amps. The design for the supply was based on three factors: low cost, small size to fit existing substation pads, and good protection against damage to the klystron including klystron gun arcs. The supply uses a 12 pulse 12.5 KV primary thyristor "star point controller" with primary filter inductor to provide rapid voltage control, good voltage regulation, and fast turn off during klystron tube faults. The supply also uses a unique secondary rectifier, filter capacitor configuration to minimize the energy available under a klystron fault. The voltage control is from 0-90 KV with a regulation of < 0.1% and voltage ripple of < 1% P-P, (< 0.2% RMS.) above 60 KV. The supply utilizes a thyristor crowbar, which under a klystron tube arc limits the energy in the klystron arc to < 5 joules. If the thyristor crowbar is disabled the energy supplied is < 40 joules into the arc. The size of the supply was reduced small enough to fit the existing PEP transformer yard pads. The cost of the power supply was < $140 per KVA.

Submitted to 1997 Particle Accelerator Conference Proceedings

---

## Page 3 — Main Paper (Left and Right Columns)

### A UNIQUE POWER SUPPLY FOR THE PEPII KLYSTRON AT SLAC

R. Cassel & M. N. Nguyen †, Stanford Linear Accelerator Center

#### Abstract

Each of the eight 1.2 MW RF klystrons for the PEP-II storage rings require a 2.5 MVA DC power supply of 83 Kv at 23 amps. The design for the supply was based on three factors: low cost, small size to fit existing substation pads, and good protection against damage to the klystron including klystron gun arcs. The supply uses a 12 pulse 12.5 KV primary thyristor "star point controller" with primary filter inductor to provide rapid voltage control, good voltage regulation, and fast turn off during klystron tube faults. The supply also uses a unique secondary rectifier, filter capacitor configuration to minimize the energy available under a klystron fault. The voltage control is from 0-90 KV with a regulation of <0.1% and voltage ripple of < 1% P-P, (< 0.2% RMS.) above 60 KV. The supply utilizes a thyristor crowbar, which under a klystron tube arc limits the energy in the klystron arc to < 5 joules. If the thyristor crowbar is disabled the energy supplied is < 40 joules into the arc. The size of the supply was reduced small enough to fit the existing PEP transformer yard pads. The cost of the power supply was < $140 per KVA.

#### 1.0 Design Considerations

The SLAC PEP-II storage rings require eight 1.2 MW RF klystrons powered by eight 2.5 MVA DC power supply at 83 Kv, 23 amps. The design consideration besides low cost were: 1) Small size so as to fit on existing PEP transformer pads. 2) Good protection against damage to the klystron from RF and klystron gun arcs. 3) Rapid Voltage adjustment to accommodate changes in beam loading and rapid conditioning of the cavities. 4) Good voltage regulation for stability with the stored beam. In addition the power supply was designed to accommodate a Depressed Collector Klystron if it were to be developed for power efficiency reasons.

#### 1.2 Configuration Selection

The supply configuration chosen was the use of a Primary SCR controlled rectifier operating at 12.5kV the existing site wide distribution voltage. This choice reduces the size of the Power supply over more conventional WT adjusted power supplies as well as provides for fast voltage adjustment and fault protection. The SCR's were configured in the so-called star point controller configuration with the filter inductor in the primary. A configuration commonly used in Europe in fusion research [1]. This configuration is ideally suited for an inductive capacitor filtered supply where bypassing of the stored energy in the filter inductor is important.

The rectifier configuration is a unique arrangement which prevents/reduces the dumping of the stored energy in the filter capacitor into the klystron under a klystron arc Figure 1.

> **[Figure 1: Power supply schematic]**
> *Block diagram showing the complete power supply configuration from 12.5KV 3-phase input through disconnect & breaker, phase shifting transformer, SCR phase controlled rectifier, filter inductor, rectifier transformer, power rectifiers, filter rectifiers, filter capacitors with resistors, SCR crowbar, to klystron output at 90KV 27 amps.*

The primary 12.5Kv enters without a Manual Load breaker disconnect used for Safety lock and tag disconnection for maintenance. The supply is energized by way of a full fault rated Vacuum breaker used as a contactor. The breaker has independent overcurrent relaying and transformer sudden pressure lockout in case of a transformer or SCR fault. To reduce the amount of power line harmonics to meet the industrial standards a 12-phase configuration was chosen. To accomplish the 12-phase operation with a Wye connected primary controller a phase shifting transformer is used. The use of a delta with extension windings to produce the ±15° was selected because the phase shifted output voltages are only 4% larger than the incoming line voltages. The nominal size of the phase shifting transformer is less

† *Work supported by DOE, contract DE-AC03-76SF00515*

---

## Page 4 — Continued Paper (Left and Right Columns)

than 15% of the full load MVA. The rectifier transformers consist of two, open Wye primary dual Wye secondaries, transformers used to step up the voltage. The SCR controller is connected to the open Wye, with the filter inductor on the primary side. The secondary windings are tapped with main power rectifier connected in a full wave bridge configuration to the full current rated taps. The 5% voltage extension is used by the filtering rectifier which is a low current full wave bridge configuration. The filter rectifier is loaded by the filter capacitor, which is coupled to the output load by way of high ohmage resistors which limits the current in the filter rectifier to approximately 1 amp maximum. This is enough current to bleed off the voltage on the filter capacitor to allow for complete voltage filtering of the supply at 60Kv output voltage.

Figures 2 & Figure 3 show the output voltage, filter inductor ripple voltage, and the secondary transformers line to line voltage waveforms.

> **[Figure 2: Output ripple at 85Kv]**
> *Oscilloscope capture labeled "KLYSTRON POWER SUPPLY" showing:*
> - *DC Ripple Voltage waveform at top*
> - *Filter Inductor Voltage waveform in middle*
> - *Transformer Line Voltage waveform at bottom*
> - *Time scale: 2 ms/div*

> **[Figure 3: Output ripple at 60KV]**
> *Oscilloscope capture labeled "KLYSTRON POWER SUPPLY" showing:*
> - *DC Ripple Voltage waveform at top*
> - *Filter Inductor Voltage waveform in middle*
> - *Transformer Line Voltage waveform at bottom*
> - *Time scale: 2 ms/div*

The output voltage ripple is greater at 60kv due to the larger ripple voltage across the filter inductor caused by phasing back the SCR's. The ripple voltage is still less than the specifications of 1% Peak to Peak voltage ripple.

A SCR Crowbar is connected across the output rectifier to crowbar the supply in the event of a klystron arc.

#### 1.3 Klystron Arc Protection

Protection of the klystron tube under a klystron arc is extremely important. The klystron is very expensive and will probably arc at some time. To protect the klystron under arc condition the joules delivered by the power supply should not exceed 60 Joules or an I²t of 40 amp²seconds [2]. In conventional supplies this is accomplished by use of fast crowbar and a series resistor. The series resistor is typically 10-50 ohms which results in very large power losses at high voltages. If the crowbar fails in anyway the klystron would be destroyed because of the large amount of energy involved.

With the new design although there is a slower SCR crowbar, failure of the crowbar or any other single point failure will not result in the destruction of the klystron. The main stored energy from the capacitor bank is isolated by use of the filter capacitor and isolating resistors which in the event of a crowbar failure results in only 50 amps for 4 milliseconds and a I²t of <15 amp²seconds with less than 40 Joules in an arc to the klystron. The Primary star point control with filter inductor allows for the bypass of the filter inductor's energy under klystron fault conditions by turning on both SCR's in one phase and turning off all the other SCR's. The result is the isolating of the load from the power line and the discharge of the energy in the filter inductor into its resistance. The result of an arc is seen in Figure 4 on the klystron and Figure 5 on the primary line current.

> **[Figure 4: Klystron Arc current & voltage]**
> *Oscilloscope capture labeled "KLYSTRON ARC VOLTAGE/CURRENT" showing:*
> - *KLYSTRON ARC VOLTAGE: Scale 10kV/div, showing voltage collapse from ~40kV*
> - *KLYSTRON ARC CURRENT: showing current spike*
> - *Time scale: ~10us/div to 80 μs range*
> - *Annotation: ~19.8us, 10us/div*

The distribution cable discharge current is reduced as well as a forced current zero by the use of small 200 μhy inductors in the termination tank. With the crowbar, this

---

## Page 5 — Final Page (Left and Right Columns)

combination allows less than 5 joules to reach the klystron and less than 20 joules without the crowbar operating. The crowbar has a delay time of approximately 10 microseconds before it conducts current.

> **[Figure 5: Klystron arc line current]**
> *Oscilloscope capture labeled "AC CURRENT WITH KLYSTRON ARC" showing:*
> - *0V reference line*
> - *100kV scale indication*
> - *AC CURRENT: 10kV/Div*
> - *KLYSTRON VOLTAGE: 10KV/DIV*
> - *Time scale: 2.5 ms/div*
> *Shows the primary current response during a klystron arc event, with current rise limited by filter inductor.*

When the klystron arcs the primary current rate of rise is limited by the primary filter inductor until the inductor is bypassed and the primary SCR's are turned off. The complete interruption of current on the primary side lasts from 4 to 8 milliseconds depending on the exact time of the arc with respect to the firing of the SCR's. As you can see the primary current only doubles under this fault condition for 2 milliseconds.

#### 1.4 Power Supply Size

Because of size constraints and the fact that all the components would be at high voltage and high power the SCR Primary controller and SCR Crowbar were mounted in the transformer oil tank in isolated oil tanks. The tanks have oil to oil high voltage feed through to prevent cross contamination of the oil in the event a crowbar or SCR stack would need maintenance.

The crowbar tank consists of 4 SCR stacks with snubber network to match the output cable impedance. In addition there are two voltage dividers to monitor the high voltage output.

The SCR Primary control tank consists of 12 SCR stacks with 12 snubber networks to limit the rate of rise of voltage and damp the stray capacitance ringing.

The transformer tank contains two filter inductors, two power transformers, one phase shifting transformer, 4 filter diode rectifier stacks, 4 filter capacitors, 8 filter resistor loads, and 4 power diode rectifier stacks. See Figure 6.

> **[Figure 5 (as labeled in document): Internal power supply tank parts]**
> *Photograph showing the internal components of the power supply tank prior to assembly.*

> **[Figure 6: Power supply installation]**
> *Photograph showing the completed power supply installation on an outdoor transformer pad.*

The power supply transformers, rectifiers, and transformers tank were manufactured by NWL Transformer. The SCR Primary controller and the SCR crowbar was manufactured and tested by SLAC and installed by NWL into their transformer tanks.

#### REFERENCES

[1] 'HV-Power Supply for Neutral-Injection Experiments Wendelstein VII and ASDEX' by D. Hrabal, R. Kunze, W. Weigand, Proceedings of the 8th Symposium on Engineering Problems of Fusion Research, IEEE Pub No. 79CH1441-5 NPS. Page 1005-1009

[2] 'Installing and Operating Klystron YK1360' PHILIPS manual, Issue #1 May 1996, Rev. Sept 1996 page 11.

