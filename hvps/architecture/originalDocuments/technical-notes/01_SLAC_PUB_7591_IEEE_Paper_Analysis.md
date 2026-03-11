# SLAC-PUB-7591 — "A Unique Power Supply for the PEP II Klystron at SLAC"

**Document ID:** HVPS-ORIG-001  
**Source:** `hvps/architecture/originalDocuments/slac-pub-7591.pdf`  
**Original Publication:** IEEE 17th Particle Accelerator Conference, Vancouver, B.C., Canada, May 12–16, 1997  
**Authors:** R. Cassel & M.N. Nguyen, Stanford Linear Accelerator Center  
**DOI/Reference:** SLAC-PUB-7591, July 1997  
**Work Support:** Department of Energy contract DE-AC03-76SF00515

---

## 1. Abstract & Key Claims

Each of the eight 1.2 MW RF klystrons for the PEP-II storage rings requires a **2.5 MVA DC power supply** of **83 kV at 23 A**. The design was based on three factors:

1. **Low cost** (achieved: < $140 per kVA)
2. **Small size** to fit existing PEP substation transformer pads
3. **Good protection** against klystron damage including klystron gun arcs

### Key Performance Claims

| Parameter | Specification |
|-----------|--------------|
| Output voltage range | 0–90 kV DC |
| Nominal operating point | 83 kV at 23 A |
| Power rating | 2.5 MVA |
| Voltage regulation | < 0.1% |
| Voltage ripple (>60 kV) | < 1% peak-to-peak, < 0.2% RMS |
| Arc energy (with crowbar) | < 5 joules to klystron |
| Arc energy (without crowbar) | < 40 joules to klystron |
| Crowbar delay | ~10 µs |
| Cost | < $140/kVA |
| Number of units | 8 (one per klystron station) |

---

## 2. Design Considerations (Section 1.0)

The authors list four primary design drivers beyond cost:

1. **Small physical size** — must fit existing PEP transformer yard pads
2. **Klystron arc protection** — RF and gun arc damage prevention
3. **Rapid voltage adjustment** — accommodate beam loading changes and fast cavity conditioning
4. **Good voltage regulation** — stability with stored beam

**Additional design feature:** The power supply was designed to accommodate a **Depressed Collector Klystron** if one were developed for power efficiency.

> **SPEAR3 Relevance:** The SPEAR3 HVPS retains this fundamental design. The depressed collector klystron option was never exercised but the design margin remains inherent in the topology.

---

## 3. Configuration Selection (Section 1.2) — Star Point Controller

### 3.1 Topology Choice

The chosen configuration is a **Primary SCR-controlled rectifier** operating at **12.5 kV** (the existing site-wide distribution voltage).

**Advantages over conventional tap-adjusted supplies:**
- Reduced physical size
- Fast voltage adjustment
- Fast fault protection

### 3.2 Star Point Controller Configuration

The SCRs are configured in the **"star point controller"** arrangement with the **filter inductor on the primary side**. This configuration is described as "commonly used in Europe in fusion research" with reference to:

> **Reference [1]:** "HV-Power Supply for Neutral-Injection Experiments Wendelstein VII and ASDEX" by D. Hrabal, R. Kunze, W. Weigand, Proceedings of the 8th Symposium on Engineering Problems of Fusion Research, IEEE Pub No. 79CH1441-5 NPS, Pages 1005-1009.

### 3.3 Why Star Point Controller is "Ideally Suited"

The star point controller is ideally suited for an **inductive-capacitor filtered supply** where **bypassing of the stored energy in the filter inductor is important**.

**Key mechanism:** Under a klystron fault, both SCRs in one phase can be turned on simultaneously while all other SCRs are turned off. This:
- **Bypasses the filter inductor energy** into its own resistance (rather than into the load)
- **Isolates the load from the power line**
- Results in complete primary current interruption in **4 to 8 milliseconds**

> **SPEAR3 Context:** This is the foundational protection mechanism that makes the SPEAR3 HVPS inherently safe. The inductor bypass capability means that even if the crowbar fails, the energy reaching the klystron is limited.

### 3.4 12-Pulse Configuration

A **12-pulse configuration** was chosen to reduce power line harmonics to meet industrial standards. Implementation:

- **Phase shifting transformer** using a **delta with extension windings** to produce ±15° phase shift
- The phase-shifted output voltages are only **4% larger** than the incoming line voltages
- Phase shifting transformer is nominally sized at **less than 15% of full load MVA**

**Wye-connected primary controller** feeds into the phase shifting transformer.

---

## 4. Rectifier and Filter Design — The Unique Configuration

### 4.1 Rectifier Transformers

Two **open Wye primary, dual Wye secondary** transformers step up the voltage:
- SCR controller connects to the open Wye primary
- Filter inductor is on the **primary side** (before the transformers)
- Secondary windings are **tapped**

### 4.2 Main Power Rectifier

Connected in **full wave bridge configuration** to the **full current rated taps** of the secondary windings.

### 4.3 Filter Rectifier — The Unique Feature

The **5% voltage extension taps** of the secondary windings feed a separate **low current full wave bridge** — the "filtering rectifier."

- The filter rectifier is loaded by the **filter capacitor**
- The filter capacitor is coupled to the output load through **high ohmage resistors**
- These resistors limit the current in the filter rectifier to approximately **1 amp maximum**
- This is sufficient current to bleed off voltage on the filter capacitor for complete filtering at **60 kV output**

### 4.4 Why This Is Unique — Arc Energy Limitation

```
                              ┌──────────────┐
  Main Rectifier ────────────►│   LOAD        │
  (30KV 30A)                  │  (Klystron)   │
                              └───────┬───────┘
                                      │
  Filter Rectifier ──► Filter Cap ──► High-Ω Resistors ──►┘
  (30KV 3A AVE)       (8µF 30KV)    (500Ω 1kW)
```

**The critical insight:** The filter capacitor's stored energy is **isolated** from the klystron by the high-ohmage resistors. Under a klystron arc:
- The main rectifier is quickly turned off via SCR control
- The filter capacitor cannot rapidly discharge through the klystron because of the resistors
- Maximum fault current from the filter path: ~50 A for ~4 ms
- I²t from capacitor discharge: ~15 amp²·seconds
- Total energy without crowbar: < 40 joules

> **This is fundamentally different from conventional supplies** where the filter capacitor is directly connected to the load, requiring fast crowbar action to prevent klystron damage.

---

## 5. Output Voltage Ripple

### At 85 kV (Full Voltage)
- Very low ripple due to 12-pulse configuration
- 720 Hz ripple frequency (12 × 60 Hz)

### At 60 kV (Reduced Voltage)
- Greater ripple due to larger ripple voltage across the filter inductor
- Caused by phasing back the SCRs (larger conduction angles)
- Still meets specification: < 1% peak-to-peak

> **Figures 2 & 3** in the paper show oscilloscope traces of output ripple, inductor voltage, and transformer secondary line-to-line voltage at 85 kV and 60 kV respectively.

---

## 6. Klystron Arc Protection (Section 1.3)

### 6.1 Protection Requirements

Per **Reference [2]** (Philips YK1360 Klystron Manual):
- Maximum allowable arc energy: **60 Joules**
- Maximum allowable I²t: **40 amp²·seconds**

### 6.2 Conventional Approach (and its limitations)

Conventional supplies use:
- **Fast crowbar** + **series resistor** (10–50 ohms)
- Series resistor causes **very large power losses at high voltages**
- If crowbar fails → **klystron destruction** due to large stored energy

### 6.3 PEP-II Approach — Multi-Layer Protection

**Layer 1: Filter Capacitor Isolation**
- High-ohmage resistors between filter cap and load
- Limits fault current to ~50 A for ~4 ms without any active protection
- I²t: ~15 amp²·seconds (< 40 limit)
- Energy: < 40 joules (within klystron tolerance)

**Layer 2: Star Point Controller Inductor Bypass**
- Turn on both SCRs in one phase → creates primary short circuit
- Turn off all other SCRs → isolates load from power line
- Filter inductor energy discharges into its own winding resistance
- Primary current interruption: 4–8 ms

**Layer 3: SCR Crowbar**
- Thyristor crowbar across the output rectifier
- Delay time: ~10 µs before conducting
- With crowbar + isolation: < 5 joules to klystron
- With crowbar + isolation: < 20 joules total (including distribution cable discharge)

**Layer 4: Termination Tank Inductors**
- Small **200 µH inductors** in the termination tank
- Reduce distribution cable discharge current
- Force current zero during fault events

### 6.4 Key Safety Claim

> "Failure of the crowbar or any other single point failure will not result in the destruction of the klystron."

This single-fault-tolerant design is the hallmark of the PEP-II HVPS architecture.

---

## 7. AC Current Behavior During Klystron Arc (Figure 5)

When the klystron arcs:
1. Primary current **rate of rise** is limited by the primary filter inductor
2. The inductor is then **bypassed** and the primary SCRs are **turned off**
3. Complete interruption of primary current: **4–8 milliseconds** (depending on arc timing relative to SCR firing)
4. Primary current only **doubles** under fault condition for **~2 milliseconds**

---

## 8. Physical Design & Construction (Section 1.4)

### 8.1 Oil Tank Mounting Strategy

Due to size constraints and the high voltage/high power environment, the **SCR Primary Controller** and **SCR Crowbar** are mounted in the **transformer oil tank** in **isolated oil tanks**.

**Critical design detail:** The internal tanks use **oil-to-oil high voltage feed-throughs** to prevent cross-contamination of oil between sections. This allows:
- Maintenance of crowbar or SCR stacks **without contaminating transformer oil**
- Independent oil management for each section

### 8.2 Crowbar Tank Contents
- 4 SCR stacks with snubber networks
- Snubber networks matched to **output cable impedance**
- 2 voltage dividers for output HV monitoring

### 8.3 Phase Control Tank Contents
- 12 SCR stacks
- 12 snubber networks per stack
- Snubber purpose: limit dV/dt and damp stray capacitance ringing

### 8.4 Main Transformer Tank Contents
- 2 filter inductors
- 2 power transformers
- 1 phase shifting transformer
- 4 filter diode rectifier stacks
- 4 filter capacitors
- 8 filter resistor loads
- 4 power diode rectifier stacks

### 8.5 Manufacturer

| Component | Manufacturer |
|-----------|-------------|
| Transformers, rectifiers, and transformer tank | NWL Transformer |
| SCR Primary controller | SLAC (designed & tested) |
| SCR Crowbar | SLAC (designed & tested) |
| Installation of SLAC components into NWL tanks | NWL |

---

## 9. References from the Paper

1. D. Hrabal, R. Kunze, W. Weigand, "HV-Power Supply for Neutral-Injection Experiments Wendelstein VII and ASDEX," Proc. 8th Symposium on Engineering Problems of Fusion Research, IEEE Pub No. 79CH1441-5 NPS, pp. 1005-1009
2. "Installing and Operating Klystron YK1360," PHILIPS Manual, Issue #1 May 1996, Rev. Sept 1996, page 11

---

## 10. Critical Design Parameters — Cross-Reference to SPEAR3

| PEP-II (Original) | SPEAR3 (Current) | Notes |
|--------------------|-------------------|-------|
| 83 kV at 23 A | ~77 kV at ~22 A | SPEAR3 operates at lower point |
| 90 kV max | 90 kV max | Same design limit |
| 2.5 MVA | 2.5 MW | Same power rating |
| 12.5 kV input | 12.47 kV input | Essentially identical |
| 8 units | 2 units (SPEAR1/SPEAR2) | SPEAR3 uses 2 of the original design |
| SCR crowbar | Same | Retained |
| Star point controller | Same | Retained |
| NWL transformer tank | Same | Retained hardware |
| 200 µH termination inductors | Same | Retained |

> **Source traceability:** All specifications in `Designs/4_HVPS_Engineering_Technical_Note.md` Section 1.2 trace to this paper.

---

**Document Status:** Complete analysis of SLAC-PUB-7591  
**Confidence Level:** High — full text OCR with manual verification against source  
**Related Notes:** [02_PEP_II_Power_Supply_Presentation_Analysis.md](02_PEP_II_Power_Supply_Presentation_Analysis.md), [04_Original_Design_Consolidated_Specifications.md](04_Original_Design_Consolidated_Specifications.md)

