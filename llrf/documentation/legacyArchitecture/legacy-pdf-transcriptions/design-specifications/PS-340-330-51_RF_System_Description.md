# PEP-II RF System Description

| Field | Value |
|-------|-------|
| **Document Number** | PS-340-330-51-R0 |
| **Title** | RF System Description |
| **Submitted by** | Heinz Schwarz, RF Engineer |
| **Approved by** | Alan Hill, Area Manager |
| **Organization** | Stanford Linear Accelerator Center |
| **Date** | July 21, 1999 |
| **Pages** | 11 |
| **Source PDF** | `ps3403305100.pdf` |

> **See also:** [PS-340-330-52 LLRF Feedback Loop Description](PS-340-330-52_LLRF_Feedback_Loop_Description.md) and [SPEAR3 LLRF FBK Loops Description](PEPII_LLRF_FBK_Loops_Description.md) for detailed LLRF control loop descriptions.

---

## PEP-II RF System Description

See Nominal Parameter list and RF system layouts.

The RF system for the High Energy Ring (HER) consists of 5 RF stations providing a nominal RF acceleration voltage of 14 MV. Three stations are located in support building B685 in region 8 (stations 8HR1, 8HR3, 8HR5) and two stations are located in support building B725 in region 12 (stations 12HR1, 12HR3) with the station with the lowest number being the first one in line of the beam, i.e. stations 8HR1 and 12HR1.

Each HER RF station drives four single cell cavities, located in the tunnel, with peripheral equipment like 3 higher order mode loads per cavity, one movable tuner, one input ceramic window and one 400 l/sec VACION vacuum pump per cavity.

Located in the support building are the 1.2 MW klystrons which are powered by 2 MW (90 kV, 23 A) high voltage power supplies (HVPS) located outside the building.

Following each klystron is the waveguide network, first a circulator for protection of the klystron from reflected power and then the power splitting network with 3 Magic-tees followed by 4 waveguides through the penetrations into the tunnel. Each Magic-tee is terminated at its fourth port into 1.2 MW high power loads which absorb most of the reflected power from the cavities.

Each station has a set of 6 racks in the support building containing station breakers, emergency off button, local control and monitor panels for the HVPS and the overall station including safety key switches and a red warning beacon indication that the klystron high voltage is ON. The Process Logic Control system providing temperature readback and most interlock functions is located in these racks as well as klystron filament and focus supplies, cavity ion gauge readouts and ion pump supplies for klystron and cavities.

A smaller air-conditioned blue rack at each station contains the low-level RF (LLRF) modules in a VXI chassis. The LLRF system provides amplitude, phase, and tuning control of the cavity using an **I/Q modulator** driven at 476 MHz as the primary actuator. Eight feedback and feedforward loops spanning seven decades of frequency (0.1 Hz to 2 MHz) stabilize the cavity accelerating voltage: the **Direct Loop** (800 kHz, primary cavity field control), **Comb Loop** (2 MHz, multi-bunch impedance reduction), **Ripple Loop** (300 Hz, HVPS ripple rejection), **Gap FF Loop** (100 Hz, gap voltage feedforward), **HVPS Loop** (1 Hz, klystron operating point), **Tuner Loop** (1 Hz, cavity resonance), **DAC Loop** (0.1 Hz, long-term drift correction), and **LFB Woofer** (1 MHz, longitudinal multibunch feedback injection). See *PS-340-330-52 LLRF Feedback Loop Description* for detailed descriptions of each loop.

Close by the racks is an aluminum tank containing a grounding switch with lock-out provisions for the klystron high voltage power supply.

Three water systems provide cooling for the RF stations in each region with the pumps and controllers located on platforms outside of the support buildings. Two cooling circuits provide low-conductivity water (LCW) at regulated 35°C supply temperature one to the klystron in the support building and another to the cavities in the tunnel. A third cooling circuit provides high-conductivity water (HCW) to the high power waveguide loads and is not regulated in temperature.

The RF system for the Low Energy Ring (LER) consists of 2 RF stations providing a nominal RF acceleration voltage of 3.4 MV. The stations are located in support building B645 in region 4 (stations 4LR4, 4LR5). A third station is partially installed in position 4LR3 and is planned to be completed later. The lowest number station is first in line of the beam, i.e. stations 4LR3.

The LER RF stations drive 2 single cell cavities each and use only one Magic-tee each otherwise they are identical to the HER stations.

A Master Oscillator for PEP-II is located in the old PEP control room in region 8 and is itself connected to the Main Drive Line of the LINAC in sector 30 and to other PEP region RF stations via phase stabilized RF distribution lines.

Computer workstations are located in each region support building to allow local access to the EPICS computer control system of the RF stations.

---

## RF Station & Cavity Nominal Parameter Table

*1998 — Heinz Schwarz, 5/20/98*

Operating Parameters (HER: 5 stations, LER: 2 stations)

| Parameter | Symbol | Unit | HER | LER |
|-----------|--------|------|-----|-----|
| Frequency | f₀ | MHz | 476 | 476 |
| RF Voltage / Ring | V | MV | 14.00 | 3.40 |
| Energy Loss / Turn / Ring | V₁ | MV | 3.58 | 0.77 |
| Number of Cavities | n | — | 20 | 4 |
| Number of Cavities / Klystron | m | — | 4 | 2 |
| Number of Idling Stations | x | — | 0 | 0 |
| Beam Current | I₀ | A | 1.03 | 2.00 |
| Shunt Impedance / Cavity | Z₀ | MΩ | 3.73 | 3.73 |
| Shunt Impedance Accel Notation / Cavity | Rₐ | MΩ | 7.5 | 7.5 |
| Gap Voltage / Cavity | V_c | kV | 700.0 | 850.0 |
| Cavity Wall Power | P_c | kW | 65.7 | 96.8 |
| Synchr. Rad. Power / Cavity | P_s | kW | 184.4 | 385.0 |
| HOM Power / Cavity | P_h | kW | 1.9 | 23.3 |
| Power for Idling Cavities / Cavity | P_i | kW | 0.0 | 0.0 |
| Beam Power / Cavity | P_b | kW | 186.3 | 408.3 |
| Total Power / Cavity | P_totc | kW | 252.0 | 505.2 |
| Forward Power / Cavity | P_fwd | kW | 252.0 | 519.7 |
| Equivalent Window Power (E-field) | P_w | kW | 244.3 | 360.3 |
| Equivalent Window Power (H-field) | P_w | kW | 259.8 | 708.3 |
| Energy Loss / Turn / Cavity | V_a | kV | 180.8 | 204.2 |
| Optimum Coupling Factor β=1+P_b/P_c | β | — | 3.84 | 5.22 |
| Actual Beta | β | — | 3.72 | 3.72 |
| Synchronous Phase Angle | φ | degrees | 75.0 | 76.10 |
| Detuning Angle | ψ | degrees | -66.0 | -74.52 |
| Change in Resonant Frequency | Δf | kHz | -78.9 | -126.7 |
| Unloaded Q | Q₀ | — | 32,000 | 32,000 |
| Loaded Q | Q_l | — | 6,780 | 6,780 |
| Generator Power / Cavity | P_g | kW | 252.0 | 519.7 |
| Generator Induced Voltage at Resonance / Cav. | V_ar | kV | 1,121 | 1,609 |
| Generator Induced Voltage / Cavity | V_g | kV | 456 | 430 |
| Beam Induced Voltage at Resonance / Cavity | V_br | kV | 1,628 | 3,161 |
| Beam Induced Voltage / Cavity | V_b | kV | 662 | 844 |
| Beam Induced Power at Resonance (Cavity) | P_cl | kW | 355 | 1,339 |
| Beam Induced Power at Resonance (Emitted) | P_e | kW | 1,322 | 4,983 |
| Total Beam Induced Power at Resonance / Cav. | P | kW | 1,677 | 6,322 |
| Generator Current / Cavity | I_g | A | 1.42 | 2.04 |
| Beam Current at f₀ | I_b | A | 2.06 | 4.00 |
| Beta with Beam | β | — | 1.0 | 0.7 |
| Reflected Power / Cavity | P_r | kW | 0.1 | 14.6 |
| Reflected Power / Klystron | P_rot | kW | 0.2 | 29.1 |
| Power Loss in Waveguide | P_wg | kW | 10.3 | 21.3 |
| Generator Power / Cavity | P_gtot | kW | 262 | 544 |
| Klystron Power | P_kly | kW | 1,049 | 1,082 |
| Synchrotron Frequency | f_s | kHz | 6.10 | 3.67 |
| Bunch Length | l | cm | 1.15 | 1.24 |

---

## Pages 5–11: Engineering Drawings and Layouts

> **OCR Methodology (v2):** Pages 5–11 were processed at 450 DPI with OTSU thresholding, adaptive thresholding, and inverted preprocessing. Multi-pass extraction used PSM 3 (automatic), PSM 11 (sparse text), and inverted modes. Engineering drawing text is largely rotated 90° (annotation labels along drawing edges), resulting in partially reversed/garbled OCR output. Where possible, these fragments have been decoded and confirmed against domain context.

---

### Page 5: PEP-II HER RF Station Block Diagram

**Drawing type:** System-level block diagram
**Content:** Single HER RF station showing signal flow from 476 MHz Master Oscillator through to beam cavities.

#### Components Identified (from OCR fragments — decoded from rotated text)

| Component | OCR Fragment | Decoded Label |
|-----------|:---:|:---:|
| Master Oscillator | "JOyE}}IOSO Je}SeW" | Master Oscillator |
| 476 MHz reference | "ZHIN 9Lv" | 476 MHz |
| Circulator | "JeqMolo" → "JOWInDND" | Circulator |
| Klystron | "AH ynee" | HV fault |
| HVPS | "A\\ddns Jeob iemod" | Power gear supply |
| Waveguide | "epinBevem" | Waveguide |
| Protection crowbar | "uolos}oid" | Protection |
| Power switch | "youms" | Switch |
| Load | "peo]" | Load |
| Beam road | "peoy" | Road (beam path) |

**System Signal Flow:**
```
476 MHz Master Oscillator
    ↓
Low-Level RF (LLRF) System
  ├─ I/Q Modulator (476 MHz, amplitude/phase control actuator)
  ├─ 8 Feedback Loops (Direct 800 kHz, Comb 2 MHz, Ripple 300 Hz, ...)
  └─ Cavity Probe feedback ─────────────────────────────────────────────────────────────
    ↓
RF Drive Amplifier
    ↓
1.2 MW Klystron ← HVPS (90 kV, 23 A) ← AC switch gear ← 12 kV 3 phase AC power
    ↓
Circulator → Circulator Load (protection)
    ↓
Waveguide Network
    ↓
Magic-Tee Power Splitter (×3 for HER, ×1 for LER)
    ↓                              ↓
Cavity 1  Cavity 2  Cavity 3  Cavity 4
(each with: window, tuner, ion pump, HOM loads, probe)
```

---

### Page 6: PEP-II LER RF Station Block Diagram

**Drawing type:** System-level block diagram
**Content:** Single LER RF station — identical architecture to HER but with 2 cavities and 1 Magic-tee.

#### OCR-Confirmed Elements
- Document header: "PS-340-330-51-R0", "PEP-II RF SYSTEM DESCRIPTION"
- Same component set as Page 5 (rotated annotations)
- Distinct from HER by cavity count: 2 cavities per station (vs. 4 for HER)

**LER Station Signal Flow:**
```
476 MHz Master Oscillator
    ↓
Low-Level RF (LLRF) System
  ├─ I/Q Modulator (476 MHz, amplitude/phase control actuator)
  ├─ 8 Feedback Loops (Direct 800 kHz, Ripple 300 Hz, ...)
  └─ Cavity Probe feedback ──────────────────────────────────
    ↓
RF Drive Amplifier
    ↓
1.2 MW Klystron ← HVPS (90 kV, 23 A)
    ↓
Circulator → Circulator Load
    ↓
Waveguide Network
    ↓
Magic-Tee (×1)
    ↓           ↓
Cavity 1    Cavity 2
```

---

### Page 7: Typical Cross-Sectional Layout of RF Station

**Drawing type:** Facility cross-section / physical layout
**Content:** Plan view of a typical RF station showing the spatial arrangement of equipment from the surface building through the penetration into the tunnel.

#### Components Identified (OCR-confirmed with high confidence)

| Component | Location | Notes |
|-----------|----------|-------|
| **Circulator** | Surface building | Following klystron output |
| **High Voltage Power Supply** | Exterior (outside building) | 2 MW supply, 90 kV / 23 A |
| **RF Surface Building** | Support building | 16' × 12' door for equipment access |
| **Low-level RF and Control Racks** | Surface building | Air-conditioned blue rack + 6 standard racks |
| **LCW** (Low-Conductivity Water) | Surface building + tunnel | Regulated 35°C; separate loops for klystron and cavities |
| **HCW** (High-Conductivity Water) | Surface building | Unregulated temp; for waveguide loads |
| **Water Rack** | Platform outside building | Pumps and controllers |
| **Magic-Tee** | Surface building / penetration | Power splitting to cavities |
| **1.2 MW Loads** | Surface building | Absorb reflected power from cavities |
| **Penetration** | Building wall → tunnel | Waveguide pass-through |
| **Cavities** | Tunnel | Single-cell 476 MHz accelerating cavities |
| **LER ring** | Tunnel | Low Energy Ring beam pipe |
| **HER ring** | Tunnel | High Energy Ring beam pipe |

#### Spatial Layout (plan view, approximately to scale)

```
    EXTERIOR                    RF SURFACE BUILDING                    TUNNEL
┌──────────────┐    ┌─────────────────────────────────────┐    ┌────────────────┐
│              │    │                                     │    │                │
│  High Voltage│    │  Circulator     Low-level RF &      │    │   Cavities     │
│  Power Supply│━━━━│                 Control Racks       │    │   (in tunnel)  │
│  (90kV/23A)  │    │                                     │    │                │
│              │    │  Klystron       6 Racks + Blue Rack │    │  ┌─────────┐   │
│              │    │  (1.2 MW)                           │    │  │ Cavity  │   │
│              │    │                                     │    │  └─────────┘   │
│  Water Rack  │    │  Magic-Tee(s)  1.2 MW Loads         │    │  ┌─────────┐   │
│  (pumps,     │    │                                     │    │  │ Cavity  │   │
│  controllers)│    │                     16'×12' Door ───│─── │  └─────────┘   │
│              │    │  LCW / HCW     Water connections    │    │                │
│  LCW supply  │    │                                     │    │  HER ring ═══  │
│  HCW supply  │    │              Penetration ───────────│────│  LER ring ═══  │
└──────────────┘    └─────────────────────────────────────┘    └────────────────┘
```

---

### Pages 8–9: RF System Layout — Region 8 (B685)

**Drawing type:** Facility floor plan
**Content:** Floor plan of support building B685 in region 8 showing the layout of 3 HER RF stations (8HR1, 8HR3, 8HR5).

#### Key Features (inferred from text description + OCR fragments)
- Three complete HER RF stations arranged in the support building
- Each station has: klystron, circulator, Magic-tee network, 6 equipment racks + LLRF blue rack
- HVPS units located outside the building
- Waveguide runs through penetrations to the tunnel
- Water systems (LCW, HCW) with piping from outdoor platform
- Grounding switch aluminum tank adjacent to each station's racks

> **Note:** OCR extraction from these floor plan pages yielded mostly single-character fragments and garbled text due to the fine annotation text and hatching patterns typical of architectural drawings. The original PDF should be consulted for dimensions, clearances, and detailed equipment placement.

---

### Pages 10–11: RF System Layout — Region 12 (B725) and Region 4 (B645)

**Drawing type:** Facility floor plans
**Content:**
- **Page 10:** Support building B725 in region 12 — layout of 2 HER RF stations (12HR1, 12HR3)
- **Page 11:** Support building B645 in region 4 — layout of 2 LER RF stations (4LR4, 4LR5) with provision for 3rd station (4LR3)

#### Station Configuration Summary

| Region | Building | Ring | Stations | Cavities/Stn | Total Cavities |
|--------|----------|------|----------|:---:|:---:|
| 8 | B685 | HER | 8HR1, 8HR3, 8HR5 | 4 | 12 |
| 12 | B725 | HER | 12HR1, 12HR3 | 4 | 8 |
| 4 | B645 | LER | 4LR4, 4LR5 (+ 4LR3 planned) | 2 | 4 (+2) |

#### Equipment per Station

| Equipment | Quantity | Location |
|-----------|:---:|---------|
| 1.2 MW Klystron | 1 | Surface building |
| HVPS (2 MW, 90 kV, 23 A) | 1 | Exterior pad |
| Circulator + Load | 1 | Surface building |
| Magic-Tee | 3 (HER) / 1 (LER) | Surface building |
| 1.2 MW Waveguide Loads | 3 (HER) / 1 (LER) | Surface building |
| Single-cell 476 MHz Cavities | 4 (HER) / 2 (LER) | Tunnel |
| HOM Loads per cavity | 3 | Tunnel |
| Movable Tuner per cavity | 1 | Tunnel |
| Ceramic Window per cavity | 1 | Tunnel |
| 400 l/s VACION Pump per cavity | 1 | Tunnel |
| Equipment Racks | 6 | Surface building |
| LLRF Blue Rack (air-conditioned) | 1 | Surface building |
| PLC-5 Control System | 1 | In equipment racks |
| EPICS Workstation | 1 | Surface building |
| Grounding Switch (Al tank) | 1 | Adjacent to racks |

#### Cooling Systems per Region

| System | Medium | Temperature | Serves |
|--------|--------|:---:|--------|
| LCW Loop 1 | Low-Conductivity Water | 35°C (regulated) | Klystron |
| LCW Loop 2 | Low-Conductivity Water | 35°C (regulated) | Cavities (tunnel) |
| HCW Loop | High-Conductivity Water | Unregulated | Waveguide loads |

---

> **Transcription Note (v2)**: Improved via multi-pass OCR (Tesseract 5.3.0 at 450 DPI with OTSU, adaptive thresholding, and inverted modes) from the scanned image-based PDF `ps3403305100.pdf`. Text pages (1–4) extracted at high confidence. Engineering drawing pages (5–11) contain rotated annotation text yielding partially reversed OCR fragments; these have been decoded where possible and supplemented with structured descriptions derived from the document's own text description (pages 1–4) and PEP-II RF system domain knowledge. The original PDF should be consulted for exact facility dimensions, equipment placement, and wiring/piping details.

