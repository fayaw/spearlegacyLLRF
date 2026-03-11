# Consolidated Design Specifications — Cross-Referenced Master

**Document ID:** HVPS-ORIG-004  
**Sources:** All three original documents + codebase technical notes + web research  
**Purpose:** Single authoritative specification table consolidating all original PEP-II design data, cross-referenced to source documents and validated against existing SPEAR3 documentation  
**Date:** March 2026

---

## 1. System-Level Specifications

### 1.1 Power Conversion

| Parameter | PEP-II Original | SPEAR3 Current | Source(s) | Notes |
|-----------|----------------|----------------|-----------|-------|
| Input voltage | 12.5 kV RMS, 3φ | 12.47 kV RMS, 3φ | PUB-7591 §1.0; PPTX Slide 4 | Essentially identical |
| Input power | 3000 kVA | 3.5 MVA (xfmr rated) | PPTX Slide 4; ETN §1.2 | SPEAR3 ETN uses transformer rating |
| Max output voltage | 90 kV DC | −90 kV DC | PPTX Slide 2; PUB-7591 Abstract | Negative polarity convention in SPEAR3 |
| Max output current | 27 A | 27 A | PPTX Slide 2; ETN §1.2 | Same |
| Nominal output voltage | 83 kV (PEP-II) | −74.7 kV (SPEAR3) | PUB-7591 §1.0; ETN §1.2 | SPEAR3 runs at lower voltage |
| Nominal output current | 23 A (PEP-II) | 22.0 A (SPEAR3) | PUB-7591 §1.0; ETN §1.2 | SPEAR3 runs at lower current |
| Max output power | 2.5 MW | 2.5 MW | PUB-7591; PPTX Slide 2 | Same |
| Rectifier topology | 12-pulse thyristor | 12-pulse thyristor | PUB-7591 §1.2; ETN §1.2 | Same |
| Regulation | < 0.1% | ±0.5% (load reg.) | PUB-7591 Abstract; Overview §10.2 | Different measurement methodology |
| Ripple (>60 kV) | < 1% P-P, <0.2% RMS | < 1% (720 Hz) | PUB-7591 Abstract; Overview §10.2 | Same |
| Regulation & ripple | < ±0.5% @ >65kV | — | PPTX Slide 2 | Presentation spec slightly different |
| Number of units | 8 | 2 (SPEAR1/SPEAR2) | PUB-7591 §1.0; ETN §1.2 | SPEAR3 uses 2 of original 8 |
| Cost | < $140/kVA | — | PUB-7591 Abstract | 1997 dollars |

### 1.2 Phase Shifting Transformer

| Parameter | PEP-II Original | SPEAR3 Current | Source(s) |
|-----------|----------------|----------------|-----------|
| Type | Extended delta with extension windings | Extended delta | PUB-7591 §1.2; ETN §2.1 |
| Phase shift | ±15° | ±15° | PUB-7591 §1.2; ETN §2.1 |
| Output voltage increase | 4% above input | 12.91 kV RMS φ-φ | PUB-7591 §1.2; ETN §2.1 |
| Size relative to full load | < 15% of full load MVA | 3.5 MVA | PUB-7591 §1.2; ETN §2.1 |
| Monitor windings | Not mentioned in PEP-II | Three single-phase, ~100 V P-P | ETN §2.1 |

### 1.3 Rectifier Transformers

| Parameter | PEP-II Original | SPEAR3 (T1/T2) | Source(s) |
|-----------|----------------|-----------------|-----------|
| Quantity | 2 | 2 (T1, T2) | PUB-7591 §1.2; ETN §2.2 |
| Primary | Open Wye | Open Wye | PUB-7591 §1.2; ETN §2.2 |
| Secondary | Dual Wye | Dual Wye (S1, S2) | PUB-7591 §1.2; ETN §2.2 |
| Rating | Not specified per unit | 1.5 MVA each | ETN §2.2 |
| Secondary voltage | Not specified | 21.0/10.5 kV RMS φ-φ | ETN §2.2 |
| Phase offset (T1) | +15° | +15° | PUB-7591 §1.2; ETN §2.2 |
| Phase offset (T2) | −15° | −15° | PUB-7591 §1.2; ETN §2.2 |
| Manufacturer | NWL Transformer | NWL (retained) | PUB-7591 §1.4 |

---

## 2. Power Semiconductor Specifications

### 2.1 Phase Control SCR Stacks

| Parameter | PEP-II (from PPTX) | SPEAR3 Current | Source(s) |
|-----------|--------------------|----|-----------|
| Total stacks | 12 | 12 | PUB-7591 §1.4; ETN §2.3 |
| Stacks per bridge | 6 | 6 | PUB-7591 §1.2; ETN §2.3 |
| Controlled thyristor rating | 40 kV, 80 A | — | PPTX Slide 4 |
| Devices per stack | — | 14 × Powerex T8K7 (350 A) | ETN §2.3 |
| Stack snubber capacitor | — | 0.015 µF (R-C series) | ETN §2.3 |
| Device snubber capacitor | — | 0.047 µF per device | ETN §2.3 |
| Max voltage per stack | — | 18.26 kV (√2 × 12.91 kV) | ETN §2.3 |
| Trigger pulse | — | 240/120 V, 16 µs bursts | ETN §2.3 |
| Snubber purpose | Limit dV/dt, damp stray capacitance | Same | PUB-7591 §1.4 |
| Number of snubber networks | 12 (per tank) | 12 | PUB-7591 §1.4 |

### 2.2 Crowbar SCR Stacks

| Parameter | PEP-II Original | SPEAR3 Current | Source(s) |
|-----------|----------------|----------------|-----------|
| Total stacks | 4 | 4 | PUB-7591 §1.4; ETN §2.6 |
| Rating | — | 6 thyristors per stack | ETN §2.6 |
| Crowbar rating (from PPTX) | 100 kV, 80 A | — | PPTX Slide 4 |
| Snubber matching | Matched to output cable impedance | Same | PUB-7591 §1.4 |
| Voltage dividers | 2 (for HV monitoring) | 2 | PUB-7591 §1.4; ETN |
| Trigger type (original) | Conventional SCR + tested light-triggered | Fiber-optic | PUB-7591; PPTX Slides 15–17; ETN §2.6 |
| Crowbar delay (conventional) | ~10 µs | ~10 µs | PUB-7591 §1.3 |
| Crowbar delay (light-triggered) | ~1 µs | ~1 µs (fiber-optic) | PPTX Slide 15 |

### 2.3 Main Rectifier Diodes

| Parameter | PEP-II Original | Source(s) |
|-----------|----------------|-----------|
| Rating | 30 kV, 30 A | PPTX Slide 4 |
| Configuration | Full wave bridge | PUB-7591 §1.2 |
| Quantity | 4 stacks | PUB-7591 §1.4 |

### 2.4 Filter Rectifier Diodes

| Parameter | PEP-II Original | Source(s) |
|-----------|----------------|-----------|
| Rating | 30 kV, 3 A average | PPTX Slide 4 |
| Configuration | Low current full wave bridge | PUB-7591 §1.2 |
| Quantity | 4 stacks | PUB-7591 §1.4 |
| Maximum current | ~1 A (limited by resistors) | PUB-7591 §1.2 |

---

## 3. Filter Network Specifications

### 3.1 Primary-Side Filter Inductors

| Parameter | PEP-II (PPTX) | SPEAR3 (ETN) | Source(s) |
|-----------|---------------|-------------|-----------|
| Quantity | 2 (L1, L2) | 2 (L1, L2) | PPTX Slide 20; ETN §2.4 |
| Inductance | 350 µH | 0.3 H | PPTX; ETN §2.4 |
| Current rating | 40 A | 85 A (full load) | PPTX Slide 20; ETN §2.4 |
| Stored energy | — | 1,084 J each (at full load) | ETN §2.4 |
| Location | Primary side (before transformer) | Primary side | PUB-7591 §1.2 |

> **Note:** The 350 µH vs 0.3 H discrepancy may indicate different measurement conditions or tolerance bands, or SPEAR3 may use different inductors. The PPTX value (350 µH) appears in the grounding tank wiring detail while the SPEAR3 ETN lists 0.3 H.

### 3.2 Filter Capacitors

| Component | PEP-II Original | Source |
|-----------|----------------|--------|
| Main filter caps | 8 µF, 30 kV (×4) | PPTX Slide 4; PUB-7591 §1.4 |
| HV filter caps | 10 nF, 56 kV (×2, C1 & C2) | PPTX Slide 20 |
| MV filter caps | 30 nF, 37 kV (×2, C3 & C4) | PPTX Slide 20 |
| Output capacitor | 0.22 µF | ETN §1.4 (Crowbar Tank) |

### 3.3 Filter Resistors (Capacitor Isolation)

| Component | Value | Rating | Quantity | Source |
|-----------|-------|--------|----------|--------|
| Filter resistors | 500 Ω | 1 kW | 8 | PPTX Slide 4; PUB-7591 §1.2 |
| Bleeder group (PPTX Slide 19) | 500 Ω | 10 W | ~18 | PPTX Slides 19–20 |
| Termination resistors | 50 Ω | — | ~12 | PPTX Slides 19–20 |

### 3.4 Termination Tank Inductors

| Parameter | Value | Source |
|-----------|-------|--------|
| Inductance | 200 µH | PUB-7591 §1.3 |
| Purpose | Reduce cable discharge current, force current zero | PUB-7591 §1.3 |

---

## 4. Protection System Specifications

### 4.1 Arc Energy Budget

| Condition | Energy to Klystron | I²t | Source |
|-----------|-------------------|-----|--------|
| With crowbar operating | < 5 joules | — | PUB-7591 §1.3 |
| Without crowbar (total) | < 20 joules | — | PUB-7591 §1.3 |
| Without crowbar (from cap) | < 40 joules | ~15 amp²·s | PUB-7591 §1.3 |
| Klystron limit | 60 joules | 40 amp²·s | PUB-7591 Ref [2] |

### 4.2 Fault Current Characteristics

| Parameter | Value | Source |
|-----------|-------|--------|
| Filter cap fault current (no crowbar) | ~50 A for ~4 ms | PUB-7591 §1.3 |
| Primary current doubling duration | ~2 ms | PUB-7591 §1.4 |
| Primary current interruption time | 4–8 ms | PUB-7591 §1.4 |
| Crowbar conduction delay | ~10 µs (conventional SCR) | PUB-7591 §1.3 |
| Light-triggered SCR delay | ~1 µs | PPTX Slide 15 |

### 4.3 Star Point Controller Protection Mechanism

| Step | Action | Time |
|------|--------|------|
| 1 | Klystron arc detected | t=0 |
| 2 | Both SCRs in one phase turned ON (inductor bypass) | < 1 µs (gate command) |
| 3 | All other SCRs turned OFF | < 1 µs (gate inhibit) |
| 4 | Load isolated from power line | Immediate |
| 5 | Inductor energy discharges into winding resistance | 4–8 ms |
| 6 | Primary current interrupted | 4–8 ms |
| 7 | Crowbar activated (if enabled) | ~10 µs |

### 4.4 Single-Fault Tolerance

> "Failure of the crowbar or any other single point failure will not result in the destruction of the klystron." — PUB-7591 §1.3

This claim is supported by three independent protection layers:
1. Filter capacitor isolation (passive — always active)
2. Star point controller inductor bypass (semi-active — requires gate control)
3. SCR crowbar (active — can fail without klystron damage)

---

## 5. Control System Specifications

### 5.1 Enerpro Firing Controller

| Parameter | PEP-II Original | Source |
|-----------|----------------|--------|
| Model | FCOG1200 (12-phase) | PPTX Slide 18 (EN-1B) |
| Phases | 12 (dual 6-phase bridges) | PPTX Slide 18 |
| Gate outputs | 6 positive + 6 negative | PPTX Slide 18 |
| Interface | Direct to SCR driver boards | PPTX Slide 18 |

### 5.2 Regulator Card

| Parameter | Value | Source |
|-----------|-------|--------|
| Drawing number | PC-237-230-14-C0 (SD-237-230-14) | PPTX Slide 18 |
| Designation | EN-2 | PPTX Slide 18 |
| Inputs | Voltage feedback, current feedback, error signals | PPTX Slide 18 |
| Outputs | Trip signals (current, voltage, manual), current limit | PPTX Slide 18 |
| Power requirements | +12V, +24V, +30V, ±15V | PPTX Slide 18 |

### 5.3 PLC System

| Parameter | PEP-II Original | SPEAR3 Current | Source |
|-----------|----------------|----------------|--------|
| CPU | SLC-5/03 | SLC-500 series | PPTX Slide 18 |
| Communication | DH485 + RS232 | Same | PPTX Slide 18 |
| Analog inputs | 1794-NI4 (4-ch) | — | PPTX Slide 18 |
| Analog I/O | 1794-NIO4V (4-ch) | — | PPTX Slide 18 |
| Digital inputs | 1794-IV16 (16-ch) | — | PPTX Slide 18 |
| Digital outputs | 1746-OX8 (8-ch) | — | PPTX Slide 18 |
| Thermocouple | 1794-THERMC (4-ch) | — | PPTX Slide 18 |

### 5.4 SCR Driver Board Interface (12 + 2 boards)

| Pin | Signal | Description |
|-----|--------|-------------|
| P1-1 | OUT-1 | Gate pulse output 1 |
| P1-2 | OUT-2 | Gate pulse output 2 |
| P1-3 | BIAS | Bias voltage input |
| P1-4 | GRN | Ground reference |
| P1-5 | +100V | +100V supply |
| P1-6 | +200V | +200V supply |
| P2-1 | +12V | Logic supply |
| P2-2 | COM | Common |
| P2-5 | TRIG | Trigger input |
| P2-7 | OFF | Inhibit command |
| P2-9 | PWR-C | Power collector |
| P2-10 | PWR-E | Power emitter |

### 5.5 Power Supply Units

| PS | Model | Output | Purpose |
|----|-------|--------|---------|
| PS-1 | Kepco 120V/1A | 120 VDC | SCR driver bias |
| PS-2 | Kepco 240V/0.25A | 240 VDC | High-voltage driver bias |
| PS-3 | Kepco 5V/20A | 5 VDC | Logic power |
| PS-4 | Kepco 120V/1A | 120 VDC | Additional bias |
| PS-5 | LND X-152 | Isolated | Isolation supply |
| PS-6 | Sola 85-15-2120 | 120 VAC regulated | PLC power |

---

## 6. Monitoring & Instrumentation

### 6.1 Current Monitoring

| Sensor | Model | Specification | Location | Source |
|--------|-------|--------------|----------|--------|
| CT1 | Pearson 110 | 10 A/V | Grounding tank | PPTX Slide 20 |
| CT2 | Danfysik DC-CT | DC current, ±15V powered | Grounding tank | PPTX Slide 20 |
| S1 | Shunt resistor | 15 A / 50 mV | Grounding tank | PPTX Slide 20 |

### 6.2 Voltage Monitoring

| Sensor | Type | Source |
|--------|------|--------|
| 2 voltage dividers | HV resistive dividers | PUB-7591 §1.4 (in crowbar tank) |
| R1 | 50 Ω, 90 kV (bleeder/divider) | PPTX Slide 20 |

### 6.3 Temperature Monitoring

| Channel | Location | Sensor | Source |
|---------|----------|--------|--------|
| TC-1 | SCR top oil | T20-1-509 thermocouple | PPTX Slides 18–19 |
| TC-2 | SCR bottom oil | T20-1-509 thermocouple | PPTX Slides 18–19 |
| TC-3 | Crowbar | T20-1-509 thermocouple | PPTX Slides 18–19 |
| TC-4 | Air temperature | T20-1-509 thermocouple | PPTX Slides 18–19 |

### 6.4 Oil Level Monitoring

| Sensor | Location | Source |
|--------|----------|--------|
| LEV-1 | Phase tank | PPTX Slide 19 |
| LEV-2 | Main tank | PPTX Slide 19 |
| LEV-3 | Termination tank | PPTX Slide 20 |

### 6.5 Transformer Monitoring (BNC connections)

| BNC | Signal | Source |
|-----|--------|--------|
| BNC-1 | Line Voltage A | PPTX Slide 18 |
| BNC-2 | Line Voltage B | PPTX Slide 18 |
| BNC-3 | Line Voltage C | PPTX Slide 18 |
| BNC-4 | 1st Transformer A | PPTX Slide 18 |
| BNC-5 | 1st Transformer B | PPTX Slide 18 |
| BNC-6 | 1st Transformer C | PPTX Slide 18 |
| BNC-7 | 2nd Transformer A | PPTX Slide 18 |
| BNC-8 | 2nd Transformer B | PPTX Slide 18 |
| BNC-9 | 2nd Transformer C | PPTX Slide 18 |
| BNC-10 | 1st Inductor | PPTX Slide 18 |
| BNC-11 | 2nd Inductor | PPTX Slide 18 |

---

## 7. Physical Layout & Interconnection

### 7.1 Tank Contents Summary

| Tank | Contents | Oil Type | Source |
|------|----------|----------|--------|
| Main tank | Phase-shifting xfmr, 2 rectifier xfmrs, 2 filter inductors, 4 filter diode stacks, 4 filter caps, 8 filter resistors, 4 power diode stacks | FR3 | PUB-7591 §1.4; ETN §1.4 |
| Phase tank | 12 SCR stacks, 12 snubber networks | FR3 | PUB-7591 §1.4; ETN §1.4 |
| Crowbar tank | 4 SCR stacks, snubber networks, 2 voltage dividers, 0.22 µF output cap | FR3 | PUB-7591 §1.4; ETN §1.4 |
| Grounding tank | Danfysik DC-CT, ground connections | — | ETN §1.4 |
| Termination tank | HV cable termination, Ross Engineering relay, 200 µH inductors | Mineral oil | ETN §1.4; PUB-7591 |

### 7.2 Interconnection Cable Types

| Cable | Type | Application | Source |
|-------|------|-------------|--------|
| Belding 88761 | Shielded twisted pair | Signal cables | PPTX Slide 19 |
| Belding 83715 | 15C #16 Teflon | Power/trigger cables | PPTX Slide 19 |
| Belding 83709 | 9C #16 Teflon | Crowbar cables | PPTX Slide 19 |
| RG-58 | Coaxial | Monitor signals | PPTX Slide 19 |

### 7.3 Connector Types

| Connector | Application | Source |
|-----------|-------------|--------|
| MS3108E18-1S | Multi-pin tank feedthrough | PPTX Slide 19 |
| MS3108E24-20S | Multi-pin controller | PPTX Slide 19 |
| GOB1288PNE | 8-pin monitor | PPTX Slide 18 |
| AMP-8PIN | 8-pin interface | PPTX Slide 18 |

### 7.4 Controller Enclosures

| Enclosure | Size | Contents | Source |
|-----------|------|----------|--------|
| Hoffman Box | 34×42 | PLC, power supplies, regulator card, interface boards | PPTX Slide 19 |
| Hoffman 12×10 (×2) | 12×10 | Junction boxes for cable transitions | PPTX Slide 19 |

---

## 8. Design Heritage & Evolution Notes

### 8.1 PEP-II → SPEAR3 Transition

The PEP-II HVPS was designed for the PEP-II B-Factory project at SLAC in 1996–1997. Key differences in SPEAR3 application:

| Aspect | PEP-II | SPEAR3 |
|--------|--------|--------|
| Klystron | 1.2 MW CW at 476 MHz | 1.5 MW CW at 476 MHz |
| Operating point | 83 kV, 23 A | 74.7 kV, 22 A |
| Number of stations | 8 | 2 (SPEAR1/SPEAR2) |
| Controller location | Local | Remote (B118, separate building) |
| Control bus | DH485 | DH485 (same, legacy) |
| Crowbar trigger | Electrical (with light-triggered testing) | Fiber-optic |

### 8.2 Star Point Controller Heritage

The star point controller configuration originates from European fusion research power supplies. The specific reference cited by Cassel/Nguyen is:

> Hrabal, Kunze, Weigand — "HV-Power Supply for Neutral-Injection Experiments Wendelstein VII and ASDEX," 1979

This configuration was used for neutral beam injection power supplies at:
- **Wendelstein VII** (stellarator, Max Planck Institute, Garching)
- **ASDEX** (tokamak, Max Planck Institute, Garching)

The star point controller was chosen for these fusion applications for the same reason it was selected for PEP-II: the ability to **bypass and manage stored inductor energy** during load faults. In fusion experiments, the load is the neutral beam injector which can arc similarly to a klystron.

### 8.3 NWL Transformer Company

NWL Transformer (now NWL Inc., Bordentown, NJ) manufactured the transformer tank assembly. They are a long-established manufacturer of:
- High-voltage transformers for electrostatic precipitators
- Specialty transformers for particle accelerators
- Oil-filled transformer/rectifier assemblies

NWL's capabilities in oil-to-oil feed-through isolation and integrated transformer/rectifier tanks were critical to meeting the size constraints of the PEP-II design.

---

## 9. Unresolved Items & Documentation Gaps

### 9.1 Specifications Not Available in Text Form

The following items are believed to be documented in `ps3413600102.pdf` (image-only) but have not been transcribed:

| Item | Importance | Available Elsewhere |
|------|-----------|-------------------|
| Detailed transformer winding data | High | Partially in ETN §2.1-2.2 |
| SCR stack mechanical details | Medium | Not available |
| Snubber circuit component values | High | Partially in ETN §2.3 |
| Voltage divider specifications | Medium | Not available |
| Oil-to-oil feed-through specs | Low | Not available |
| Complete bill of materials | Medium | Not available |
| Acceptance test requirements | Medium | Not available |
| Tolerance specifications | High | Not available |

### 9.2 Discrepancies Between Sources

| Parameter | PEP-II Original | SPEAR3 ETN | Resolution |
|-----------|----------------|------------|------------|
| Filter inductor | 350 µH (PPTX) | 0.3 H (ETN) | May be different units/conditions; 350 µH = 0.35 mH ≠ 0.3 H. Likely different inductors or measurement conditions. ETN value (0.3 H) appears more consistent with system analysis. |
| Filter inductor current | 40 A (PPTX) | 85 A (ETN) | 40 A may be PPTX rating; 85 A is full-load value in SPEAR3 context |
| Phase shifting xfmr rating | <15% of full load MVA (PUB-7591) | 3.5 MVA (ETN) | 15% of 2.5 MVA = 0.375 MVA — this is the phase shifting transformer ALONE; 3.5 MVA is likely the TOTAL transformer assembly rating |

### 9.3 Future Work

1. **OCR processing** of `ps3413600102.pdf` to extract all specification data
2. **Reconciliation** of inductor values between PPTX and ETN
3. **Verification** of snubber circuit values against physical hardware
4. **Update** of existing technical notes with traceable source references

---

## 10. Document Cross-Reference Matrix

| Topic | Note 01 (PUB-7591) | Note 02 (PPTX) | Note 03 (PS-341) | ETN (Designs/4) | Overview (Schematics/00) |
|-------|:---:|:---:|:---:|:---:|:---:|
| System specifications | ✓ | ✓ | (image) | ✓ | ✓ |
| Circuit topology | ✓✓ | ✓✓ | (image) | ✓ | ✓ |
| Component values | ✓ | ✓✓ | (image) | ✓✓ | ✓ |
| Waveform data | ✓ | ✓✓ | — | — | — |
| Crowbar testing | ✓ | ✓✓ | — | ✓ | ✓ |
| Control wiring | — | ✓✓✓ | (image) | ✓ | ✓ |
| Physical layout | ✓ | ✓ | (image) | ✓✓ | ✓ |
| PLC I/O | — | ✓✓✓ | — | ✓ | — |
| Protection analysis | ✓✓✓ | ✓ | — | ✓✓ | ✓ |
| Design rationale | ✓✓✓ | ✓ | — | ✓ | — |

**Legend:** ✓ = mentioned, ✓✓ = detailed, ✓✓✓ = primary source

---

**Document Status:** Complete consolidated specification  
**Confidence Level:** High for cross-referenced items, Medium for inferred content  
**Last Updated:** March 2026  
**Next Review:** When ps3413600102.pdf is OCR-processed or manually transcribed

