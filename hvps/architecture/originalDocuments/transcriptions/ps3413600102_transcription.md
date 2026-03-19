# PS-341-360-01-R2 — Technical Specification Transcription

**Original Document:** `ps3413600102.pdf`
**Document Type:** Scanned Technical Specification (24 pages, image-based PDF)
**Full Title:** PEP-II RF System — 2.5 MW Klystron Power Supply Technical Specification
**Transcription Method:** Tesseract OCR on 300 DPI rendered page images

---

## Page 1 — Title Page

### TECHNICAL SPECIFICATION
### PS-341-360-01-R2

### PEP-II RF SYSTEM
### 2.5 MW KLYSTRON POWER SUPPLY

**Prepared by:** Richard Cassel (Originator)
(Power Conversion Department)
Date: 1/27/04

**Reviewed by:** (Power Conversion Department)
Date: 1/27/04

**Reviewed by:** (Power Conversion Department)
Date: 1/27/04

**Reviewed by:** Paul Bellomo (Power Conversion Department)
Date: Jan 27, 04

**Approved by:**

**File name:** 34136001.PS2

**Rev:** R2

STANFORD LINEAR ACCELERATOR CENTER
Power Conversion Department
2575 Sand Hill Rd
Menlo Park, CA 94025

PS-341-360-01-R2

---

## Page 2 — Table of Contents

### Technical Specifications
### 2.5MW PEP-II Klystron Power Supply Rectifier Transformer
### PS-341-360-01-R1

#### TABLE OF CONTENTS

| Section | Title |
|---------|-------|
| 0.0 | Introduction |
| 1.0 | Scope, Service and Standards |
| 2.0 | Summary of specifications |
| 3.0 | Transformer |
| 4.0 | Rectifier Configuration and specifications |
| 5.0 | Primary SCR Controls supplied by SLAC |
| 7.0 | DC Crowbar supplied by SLAC |
| 8.0 | Insulation of complete power supply |
| 9.0 | Primary excitation |
| 10.0 | Short Circuit Conditions |
| 11.0 | Terminals |
| 12.0 | Cooling |
| 13.0 | Enclosures |
| 14.0 | Controls, Accessories and Alarms |
| 15.0 | Tests |
| 16.0 | Size |
| 17.0 | Connection & Interlocks |
| 18.0 | Color |

---

## Page 3 — Introduction

### Specifications
### 2.5 MW PEP-II Klystron Power Supply Rectifier Transformer
### PS-341-360-01-R1

#### Introduction

This specification describes the outdoor oil insulated power supply used to power the PEP-II (B-factory project) 1.2 MW 476 MHz RF SLAC klystron. The power supply shall consist of a phase shifting transformer, rectifier transformers, rectifiers, filter capacitor and inductor and SLAC provided 12 phase primary controller thyristor rectifier, and DC crowbar (powered from the SLAC 12.5 kV 3 phase 60 Hz power line) Figure 1. All of the transformers and high voltage parts of the power supply shall be totally enclosed in outdoor oil tank which is sized to fit the existing PEP transformer pads (Figure 9).

#### 0.0 Scope, Service and Standards

0.1 The scope encompasses the design, fabrication, test and delivery of the power supply system in accordance with this specification, including designing, performing thermal, stress and seismic analyses, harmonic and short circuit current calculations to demonstrate compliance with specification, and providing installation and maintenance manuals and sufficient drawings for the power supply and transformers operation and maintenance.

0.2 The vendor shall be responsible for the testing of all installed equipment and performance of all equipment supplied by the vendor.

0.3 The following equipment as a minimum shall be supplied by vendor.
1) One transformer tank with monitoring and controls enclosure.
2) One Phase shifting transformer with input current transformers.
3) Two Rectifier transformers.

PS-341-360-01-R2 — Page 3

---

## Page 4 — Scope (continued)

4) Two Filter inductors.

5) Five output Bushings.

0.4 In addition the following equipment shall be installed by the vendor.
1) Installation of the SLAC supplied Primary Control SCRs.
2) Installation of the SLAC supplied SCR crowbar.
3) Installation of the four sets of rectifiers, filter capacitors and interconnecting resistors.

0.5 The following equipment may be supplied by the vendor or can be supplied by SLAC.
1) Four sets of 6 pulse high voltage power rectifiers.
2) Four sets of 6 pulse high voltage filter rectifiers.
3) Four filter capacitors with interconnecting resistors.

0.6 The equipment furnished under this specification shall comply with the currently applicable accepted industry practice, in particular with the following:
- IEEE Std General Principles for Temperature Limits in the Rating of Electric Equipment.
- ANSI C42.100 1972 Dictionary of Electrical and Electronic Terms.
- AEC Safety & Fire Protection Bulletin #13 Electrical Safety Guides for Research, Part II.
- Title 29, Chapter XVII, Part 1910 — Occupational and Health Standards.
- National Electrical Code National Fire Protection Association Number 70
- National Electrical Safety Code, ANSI C2.
- ANSI C34.2 Practice and Requirements for Semi-Conductor Power Rectifiers.
- IEEE Std 4-1969 Techniques for Dielectric Tests.
- ANSI/IEEE C57.98-1986 Transformer impulse testing
- ANSI C57.12 Power Transformers.
- ANSI C57.18 Rectifier Transformers.
- Uniform Building Code California, Pacific Coast Building Conference.

PS-341-360-01-R2 — Page 4

---

## Page 5 — Summary of Specifications

#### 1.0 Summary of specifications

1.1 There shall be five outputs for a possible future depressed collector klystron:

| Output | Voltage | Notes |
|--------|---------|-------|
| a) Cathode #5 | 0 to -90 kV | Main cathode supply |
| b) Collector #1 | Nominal Ground | 0 to -1 kV maximum |
| c) Output #4 | 0 to -77 kV | 86% of cathode voltage |
| d) Output #3 | 0 to -52 kV | 57% of cathode voltage |
| e) Output #2 | 0 to -26 kV | 29% of cathode voltage |

1.2 The maximum output current on any output is 27 Amps. (Note: the klystron cathode beam current is 27 amps maximum and the current may return in any of the outputs or any combination of outputs)

1.3 Frequency line 60 Hz

1.4 Line voltage 12.5 kilovolts ±5% line to line

1.5 Nominal phase shifting transformer power 350 kVA (see figure 2)

1.6 Rectifier transformer primary voltage 12.5 ±5% kilovolts line to line

1.7 Each secondary voltage 21 kV RMS. line to line or 10.5 kV (T2-S2) See figure 3

1.8 Each Secondary Current 22 Amperes RMS. per phase

1.9 Nominal rectifier transformer power rating 1500 kVA (each of two transformers)

1.10 Filter choke inductance >0.3 Hy at 85 amps DC

1.11 Filter choke DC current, long term 85 Amps

#### 2.0 Transformer

2.1 The phase shifting transformer shall be connected to provide for a phase shift line to primary of 15° (±0.5°) (See figure 2).

PS-341-360-01-R2 — Page 5

---

## Page 6 — Transformer (continued) & Rectifier Specifications

2.2 The phase shifting transformer shall have a minimum of two monitor windings (for SCR synchronization) connected to the terminal box. The voltage ratio shall be approximately 100/1, i.e. 125 volts line to line for 12.5 kV line to line. The current rating shall be 5 amps RMS.

2.3 The rectifier transformers shall be Wye secondary with open Wye primary.

2.4 The secondary of the transformers shall have an additional +5% voltage tap used by the proprietary filter circuit. (See figure 3)

2.5 The secondary voltage winding shall be 21 kV RMS. line to line for T1-S1, T1-S2, T2-S1, and 10.5 kV RMS. line to line for T2-S2 with a primary voltage of 12.5 kV RMS. line to line.

2.6 The transformers secondary (they can be different) shall have a nominal leakage reactance to the primary of between 7% and 10% based on the nominal kVA rating of the transformer. The leakage reactance from phase winding to phase winding may vary within ±7.5% of the nominal leakage reactance.

2.7 The resistive impedance shall be < 2%, based on the nominal kVA rating.

#### 3.0 Rectifier Configuration and specifications

3.1 The vendor may propose his own rectifier, filter capacitor and resistor design and fabrication, as per following specification, or may install SLAC supplied rectifiers.

3.2 The supply shall have 8 sets of 6 pulse full wave rectifiers.

3.3 The 4 sets of power 6 pulse full wave rectifiers shall be rated for 30 Amps average with a junction temperature not to exceed 80° C with a 45° C ambient air temperature at full load. The individual rectifier stacks shall have a continuous reverse voltage rating of not less than 30 kV and be balanced/protected so as not to exceed the individual diode's peak inverse voltage rating with 500 Amps in the reverse direction through the protection.

PS-341-360-01-R2 — Page 6

---

## Page 7 — Rectifier Specifications (continued)

3.4 The diodes shall be rated for a fault current consistent with a bolted secondary or (crowbar) with SCRs phased full on and an 8 cycle breaker interruption. The junction temperature shall not exceed 150° C or the manufacturer's maximum operating junction temperature rating, under full load operating conditions with a 45° C ambient air temperature.

3.5 The 4 sets of filter 6 pulse full wave rectifier shall have diodes rated at >3 amp average used for ripple filtering. The junction temperature shall not exceed 80° C with a 45° C ambient air temperature at full load and at a fault current of 25 amps for 8 cycles.

3.6 The filter rectifier stacks shall have a continuous voltage rating of not less than 30 kV and shall be balanced or protected so as not to exceed the individual diode's peak inverse voltage rating with less than 50 kV per stack.

3.7 The supply shall have 4 filter capacitors of not less than 8 uF at 30 kV DC each.

3.8 The filter shall also consist of 8 resistors or resistor strings rated at 500 ohms and 1 kW in oil with energy absorption capacity of no less than 5000 Joules per resistor.

3.9 The capacitance between each secondary and shield or primary shall not exceed 0.005 uF.

3.10 The power loss, if SLAC provides the rectifiers, filter and filter resistors shall not exceed 10 kW.

#### 4.0 Primary SCR Controls supplied by SLAC

4.1 The vendor shall install, make all connection to, and test the SLAC supplied 12 phase SCR's snubbers, SCR drivers and control system. (see Figure 6). Detail drawings with dimensions will be available for the vendor two weeks before the required vendors design review. The pre-tested parts shall be available from SLAC at least 4 weeks before the required installation.

PS-341-360-01-R2 — Page 7

---

## Page 8 — SCR Controls & Insulation

4.2 The vendor shall provide adequate clearance, cooling, and support structure for the SLAC supplied SCR assemblies.

4.3 Oil to oil bushing feed throughs shall be used to connect the SCR's to the transformer primary. The bushing shall have a BIL rating consistent with the SCR's voltage rating with adequate current rating for the continuous and fault current.

#### 5.0 DC Crowbar supplied by SLAC

5.1 The vendor shall install, make all connection to, and test the SLAC supplied SCR DC Crowbar, snubbers, voltage dividers, SCR drivers and control system (see Figure 7). Detail drawings with dimensions will be available for the vendor two weeks before the required vendors design review. The pre-tested parts shall be available from SLAC at least 4 weeks before the required installation.

5.2 The vendor shall provide adequate clearance, cooling, and support structure for the SLAC supplied SCR Crowbar assemblies.

5.3 Oil to oil bushing feed throughs shall be used to connect the SCR crowbar to the transformer secondary. The bushing shall have a continuous voltage rating of 100 kV DC with adequate current rating for a peak current of 80 kA.

#### 6.0 Insulation of complete power supply

6.1 The insulation system at the primary voltage level shall be rated for a BIL of 95kV 1% – 40 uSec ANSI/IEEE C57.98-1986.

6.2 The insulation system at the secondary voltage shall be rated for 120 kV DC (to ground).

6.3 Adequate insulation coordination shall be used with the rectifiers and filter capacitors to prevent excessively high voltages being applied across the filter capacitors or diodes (50 kV maximum) in the event of a failure of a diode, resistor, capacitor, bus or ground fault in the transformer tank. Analysis of these failure modes in the rectifier system shall be provided during the design review.

PS-341-360-01-R2 — Page 8

---

## Page 9 — Primary Excitation & Short Circuit

#### 7.0 Primary excitation

7.1 The transformer shall be designed for a maximum excitation of 0.03% of rated primary current at rated voltage and frequency. This means that the total exciting current for the phase shifting transformer and each of the two rectifier transformers shall not exceed 0.03% of the rated primary current at nominal voltage and frequency.

#### 8.0 Short Circuit Conditions

8.1 The transformer and other equipment covered in this specification shall be designed to withstand the short circuit conditions existing in the system, including a bolted fault at the output bushings with the primary SCR's phased fully on. In the event of a crowbar discharge the current shall be limited to less than 80 kA by the transformer impedance.

8.2 The maximum fault duration shall be based on an eight cycle primary breaker interruption.

#### 9.0 Terminals

9.1 The power supply shall be designed for and supplied with 15kV class outdoor rated primary terminals.

9.2 The primary terminals shall be of a 3 phase throat type configuration, suitable for connecting to a 12.5 kV 3 phase power cable system.

9.3 The DC high voltage output terminal shall be of the bushing type for connection to the DC high voltage cables. Bushings shall be rated for a minimum of 120 kV DC and 30 Amps continuous service.

PS-341-360-01-R2 — Page 9

---

## Page 10 — Primary Excitation & Short Circuit (continued)

7.4 The other rectifier transformer secondary shall have an 85 kV DC voltage superimposed on the 10-21 kV AC voltage and therefore shall have a DC high pot of 150 kV DC and/or 120 kV with rectifier in place.

#### 8.0 Primary excitation

8.1 The phase shifting transformer shall be designed for continuous operation with 12.5 kV ±5% RMS at 60 Hz.

8.2 The SCR's in the open Wye will control the primary excitation voltage on the rectifier transformers so as not to exceed the equivalent of a 13 kV 60 Hz line to line excitation under all conditions. The vendor shall design the rectifier transformers for an excitation (Volt-seconds) equivalent to 13 kV RMS 60 Hz Line to line. (12.5 kV/21 kV for turns ratio) {NOTE DC in primary winding will be limited to 0.5 Amp}. The total core losses (eddy currents and hysteresis) under SCR primary control shall be assumed by the vendor to be not more 10% greater than the total core losses experienced under 13 kV RMS 60 Hz excitation (without the SCR primary control, non-grounded wye, no zero sequence current).

#### 9.0 Short Circuit Conditions

9.1 The transformer shall be designed for continuous full load operation.

9.2 The transformers shall withstand an external 3 phase secondary short circuits at the transformer terminals for 5 cycles without appreciable damage or parameter change.

9.3 The transformers shall be designed for frequent crowbars (secondary short circuits) with interruption time from the primary SCR's of less than one cycle. The number of crowbars will not exceed 10,000 with no more than (10) in any one day.

PS-341-360-01-R2 — Page 10

---

## Page 11 — Terminals, Cooling

#### 10.0 Terminals

10.1 The primary line terminal shall be made compatible with SLAC's existing disconnect and vacuum contactor enclosure utilizing a weatherproof throat connection. Final dimensions and placement to be determined before design review.

10.2 The open Wye terminals, filter inductor terminals, and SCR crowbar terminals (supplied by SLAC) are to be connected by the vendor. The terminals shall be leak tight oil to oil feed through. The details will be made available before the vendors required design review.

10.3 The rectifier transformer secondary terminals, consisting of the 3 phases of each Wye and the three +5% taps on each Wye, shall be terminated to the rectifier diodes on insulators in such a way that tools or debris will not fall into the transformers if dropped when working on the rectifiers.

10.4 The five DC Output terminals shall be sealed oil tight with cable termination for RG-220 Cable. The low voltage terminals shall be Isolation Design Inc. Model D-130-02 and the High voltage terminal Model D-117-BA or SLAC approved equal.

#### 11.0 Cooling and oil

11.1 The power supply shall be forced oil/convection air cooling (FO) using an oil pump to insure adequate cooling for the transformers and the rectifiers and SCR at the top of the tank.

11.2 The oil pump(s) shall be designed to allow for oil flow in the air cooled radiators without the pump(s) being on. Pump(s) shall be arranged to enable removal and maintenance on the pumps without draining the oil from the tank.

11.3 The average winding temperature rise of all transformers and filter inductors shall be 65°C maximum with a hot spot temperature rise of 80°C maximum above 40°C ambient.

11.4 The transformers and inductors shall comply with the loading guide for 65° oil transformers NEMA standards.

PS-341-360-01-R2 — Page 11

---

## Page 12 — Oil & Enclosures

11.5 The oil used in the transformer shall be Sontex® X-ray oil (Drakeol® 10 LT mineral Oil NF) or approved equal.

#### 12.0 Enclosures

12.1 The transformers enclosure shall be of the vendor's standard design. It shall however meet industrial standards for transformer tank design. It shall have sufficient space for all of the vendor supplied equipment as well as for the SCR phase controllers and crowbar enclosures supplied by SLAC.

12.2 The transformer enclosure shall be capable of withstanding a full vacuum for oil filling and processing. The SCR enclosures will be vented into the main tank for oil overflow and vacuum oil filling.

12.3 The diode rectifier section shall be located on the top (figure 4) of the transformer and shall be a minimum of 48" W × 82" L × 24" H. This will contain the rectifier diodes, filter capacitors, and filter resistors. The rectifier section shall be separated from the rectifier transformers so that it can be installed and maintained without draining the tank oil and designed in such a way that tools or debris will not lodge in the transformers if dropped from the diode or filter.

12.4 The space shall be provided for the SLAC supplied SCR controller shall be a minimum of 54" W × 36" H × 19" D inside the tank with a flange of at least 2" wide at the top (see figure 6). The SLAC supplied SCR controller will come as a unit and shall be installed in such a way that it can be removed easily and quickly as a unit without draining the main tank oil.

12.5 The space shall be provided for the SLAC supplied SCR crowbar shall be a minimum of 54" W × 36" H × 19" D inside the tank with a flange of at least 2" wide at the top (see figure 7).

PS-341-360-01-R2 — Page 12

---

## Page 13 — Controls, Accessories and Alarms

The SLAC supplied SCR crowbar will come as a unit and shall be installed in such a way that it can be removed easily and quickly as a unit without draining the main tank oil.

12.6 The transformer enclosure shall be designed to have a removable "cat walk" used for personnel safety during installation and subsequent maintenance of the rectifiers and SCR units.

#### 13.0 Controls, Accessories and Alarms

13.1 The voltage control shall be provided by the SCR primary control. All of the system controls except those listed in 13.4 will be provided by SLAC.

13.2 The crowbar shall be triggered from the SLAC provided control system.

13.3 Each of the primary bushings shall have current transformers type 300/5 with ASA accuracy classes 1.2 and be wired to a terminal box on the outside of the transformer.

13.4 The following alarm devices shall be furnished and wired to a weatherproof terminal box. Each device shall have at least one NO and one NC contact.

A) Pressure relief devices with two independent sets of contacts, Qualitrol Series 208 or SLAC approved equal.
B) Top oil temperature for main tank Qualitrol Series 165 or SLAC approved equal.
C) Oil level gauge for main tank Qualitrol Series 032-35 or SLAC approved equal.
D) Pressure / Vacuum alarm.
E) Oil flow Indicator.

#### 14.0 Tests

14.1 The following factory tests shall be performed on the power supply or transformers in accordance with IEEE and ANSI standards.

14.2 Resistance measurement.

14.3 Transformer turns ratio tests.

PS-341-360-01-R2 — Page 13

---

## Page 14 — Tests (continued), Size, Connections

14.4 Polarity & phase relationship.

14.5 Impedance.

14.6 Induced potential tests.

14.7 AC high pot test on the primary.

14.8 DC high pot test on the secondary and rectifier system.

14.9 Temperature rise tests. (one unit)

14.10 BIL test 95 kV full wave 1%–40 usec on the primaries ANSI/IEEE C57.98-1986 (first unit)

14.11 Incremental inductance vs. current for filter inductors at 360 Hz

#### 15.0 Size

15.1 The overall size of the transformer shall not exceed 144" wide × 94" deep × 144" high, with pad area not to exceed 130" wide × 84" deep (See Figures 4 & 9).

15.2 The detail size and design of the SCR and Crowbar enclosure will be mutually agreed upon before the required vendor design review.

15.3 Details dimension of the 12 kV throat and the DC terminations will be mutually agreed upon during the design stage.

15.4 Provision shall be made to lift and handle the transformer complete with oil by a crane.

15.5 Anchoring for earthquake protection shall also be provided.

#### 16.0 Connection & Interlocks

This section covers the interlocks and connections required.

16.1 All of the power connections shall be totally enclosed in metal and secured by either welding or at least 4 bolts, 1/4" or greater adequate for outdoor service and for personal safety.

16.2 All 15 kV class terminals and connections shall conform with the ASA and NEMA standards where they apply.

PS-341-360-01-R2 — Page 14

---

## Page 15 — Color & Documentation

#### 17.0 Color

17.1 The transformers shall have a final color of "Home Spun Brown" as supplied by Tnemec Company of Napa, California color #16794 or SLAC approved equivalent.

#### 18.0 Documentation

The vendor shall submit the below listed documentation with each Power Supply in an electronic file format (.dxf, .dwg or .dgn).

18.1 All assembly and sub-assembly drawings and schematics.

18.2 A complete parts list with manufacturer's name and model/part number.

18.3 Test procedures and test results.

18.4 Installation and Maintenance Manuals.

18.5 This requirement is deleted.

18.6 This requirement is deleted.

18.7 Vendors in house technical specifications.

PS-341-360-01-R2 — Page 15

---

## Page 16 — Figure 1: Power Supply Schematic

> **[FIGURE 1 — Power Supply Schematic Diagram]**
>
> Full system schematic of the PEP-II Klystron Power Supply showing:
>
> **Input Section:**
> - 12.5KV 3PH, 2500 KVA input
> - DISCONNECT & BREAKER (Not part of contract)
>
> **Phase Shifting & Control:**
> - 2× 8BA PHASE SHIFTING TRANSFORMER
> - SCR PHASE CONTROLLED RECTIFIER (supplied by SLAC) — 8 pulse
> - Not part of contract designation noted
>
> **Transformer & Rectifier Section:**
> - 2× 8BA RECTIFIER TRANSFORMER
> - FILTER INDUCTOR
> - 4× 8BA GP FILTER DIODE RECTIFIERS — 30KV 3A AVE
> - RECTIFIERS — 40KV 30 AMPS (4 each)
> - 4× 8BA FILTER CAPACITORS — 8uFD 30KV
> - 8× EACH RESISTORS — 500 OHMS 1KW
>
> **Output/Protection:**
> - SCR CROWBAR (supplied by SLAC) — SCR #2
> - BUSHINGS — 5 EACH, 90KV, 27A
> - Output voltages: -90KV, -77KV, -52KV, -26KV
>
> **Load:**
> - KLYSTRON — 90KV, 27 AMPS (Not part of contract)
>
> **Title:** Kly Pwr Supply Spec. / POWER SUPPLY

PS-341-360-01-R2 — Page 16

---

## Page 17 — Figure 2: Phase Shifting Transformer

> **[FIGURE 2 — Phase Shifting Transformer Diagram]**
>
> **Title:** PHASE SHIFTING TRANSFORMER
>
> **Electrical specifications:**
> - PRIMARY WINDING CURRENT (H1-H2) < 10 AMPS RMS
> - INPUT (H) 127 AMPS RMS, OUTPUTS (X & Y) < 71 AMPS RMS
>
> **Voltage values:**
> - Input: 12.5KV 3 PHASE, 127 AMPS
> - Phase shift: ± 15 DEGREES
> - Voltage components: 1.03kV, 1.93kV
>
> **Connection diagram showing:**
> - Input terminals H1, H2, H3
> - Output terminals X1, X2, X3 (and Y1, Y2, Y3)
> - Winding H1-H3 configuration
> - Delta with extension windings for ±15° phase shift
>
> **Waveform plot:**
> - X-axis: TIME SECONDS (0 to 0.0083 to 0.0167)
> - Y-axis: Voltage scale -100 to +100
> - Shows phase-shifted output voltage waveform relative to input

PS-341-360-01-R2 — Page 17

---

## Page 18 — Figure 3: Transformer Connection Diagram

> **[FIGURE 3 — Transformer Connection Diagram]**
>
> **Title:** TRANSFORMER CONNECTION DIAGRAM
>
> **Input:** 12.5KV RMS L-L 3 PHASE
>
> **Phase Shifting Transformer:**
> - AUTO-TRANSFORMER +15° / -15°
> - 12.5 KV / 13 KV
> - Terminals: A1, H4, H5, H1, H2, H3
>
> **Rectifier Transformer Connections:**
> - Terminals: X1, X2, X3 (primary connections to each transformer)
>
> **Transformer Ratings:**
> | Transformer | Rating | Voltage | Current | Phases |
> |------------|--------|---------|---------|--------|
> | T1 S1 | 750 KVA | 21KV | 22 AMPS | 3 PHASE |
> | T1 S2 | 750 KVA | 21KV | 22 AMPS | 3 PHASE |
> | T2 S1 | 750 KVA | 21KV | 22 AMPS | 3 PHASE |
> | T2 S2 | 375 KVA | 10.5KV | 22 AMPS | 3 PHASE |
>
> **Title:** Kly Pwr Supply Spec.

PS-341-360-01-R2 — Page 18

---

## Page 19 — Figure 4: Power Supply Layout

> **[FIGURE 4 — PEP-II 2.5 MW Klystron Power Supply Layout]**
>
> **Title:** PEP-II 2.5 MW KLYSTRON POWER SUPPLY LAYOUT
>
> **Cut-away view showing internal arrangement:**
>
> **Top Level (visible from above):**
> - Output Bushings (5 total)
> - Diode & Capacitor section
> - Control box
>
> **SLAC-supplied components:**
> - SCR's supplied by SLAC (×2 locations noted)
> - Crowbar supplied by SLAC (with cut-away view)
>
> **Internal components (visible in cut-away):**
> - Phase shifting transformer
> - Rectifier Transformers (×2)
> - Filter Inductors (×2)
> - Diodes & capacitors (upper section)
> - CT (Current Transformers)
>
> **Views:** Multiple cut-away perspectives showing component arrangement within the oil-filled tank

PS-341-360-01-R2 — Page 19

---

## Page 20 — Figure 5: Rectifier & Filter Capacitor

> **[FIGURE 5 — Rectifier & Filter Capacitor Assembly]**
>
> **Title:** Rectifier & Filter Capacitor (Can be supplied by SLAC)
>
> **Assembly drawing showing:**
> - CAPACITOR — Cylindrical component
> - RECTIFIER DIODES — Stack assembly
> - Mounting and interconnection details
> - Physical arrangement of capacitor and rectifier components within the assembly
>
> **Title:** Kly Pwr Supply Spec.

PS-341-360-01-R2 — Page 20

---

## Page 21 — Figure 6: 12kV SCR Controller

> **[FIGURE 6 — 12kV SCR Controller (supplied by SLAC)]**
>
> **Title:** 12kV SCR controller supplied by SLAC
>
> **Assembly drawing showing:**
> - CUT AWAY view of the SCR controller unit
> - Dimensions: 36" height indicated
> - STEEL COVER at top
> - STEEL enclosure
> - SCR'S — arranged in stacked configuration
> - EPOXY GLASS insulating components
> - CUT AWAY section showing internal arrangement
> - Mounting flange at top for insertion into transformer tank

PS-341-360-01-R2 — Page 21

---

## Page 22 — Figure 7: SCR Crowbar

> **[FIGURE 7 — SCR Crowbar (supplied by SLAC)]**
>
> **Title:** SCR CROWBAR SUPPLIED BY SLAC
>
> **Assembly drawing showing:**
> - STEEL enclosure with STEEL COVER
> - CUT AWAY view of internal components
> - Multiple SCR stacks arranged within the enclosure
> - Snubber networks
> - Voltage dividers
> - Voltage ratings indicated: 8KV, 58KV, 10KV, 92 KV (voltage distribution across stacks)
> - Mounting arrangement for insertion into transformer tank

PS-341-360-01-R2 — Page 22

---

## Page 23 — Figure 8: Filter Inductor Characteristics

> **[FIGURE 8 — Filter Inductor: Inductance vs. Current]**
>
> **Title:** FILTER INDUCTOR — INDUCTANCE VS CURRENT
>
> **Graph showing:**
> - Y-axis: INDUCTANCE (HY) — Inductance in Henries
> - X-axis: Current (DC amps)
> - Curve showing the inductance decrease with increasing DC current
> - Demonstrates the saturation characteristics of the filter inductor
> - Key specification point: >0.3 Hy at 85 amps DC

PS-341-360-01-R2 — Page 23

---

## Page 24 — Figure 9: Power Supply Installation Layout

> **[FIGURE 9 — PEP-II Klystron Power Supply Layout (Installation Plan)]**
>
> **Title:** PEP-II KLYSTRON POWER SUPPLY LAYOUT
>
> **Plan view / overhead layout drawing showing:**
> - Overall footprint dimensions of the power supply on the transformer pad
> - Maximum dimensions: 144" wide × 94" deep per specification 15.1
> - Pad area: 130" wide × 84" deep
> - Arrangement of major components as viewed from above
> - Connection points and cable routing

PS-341-360-01-R2 — Page 24
