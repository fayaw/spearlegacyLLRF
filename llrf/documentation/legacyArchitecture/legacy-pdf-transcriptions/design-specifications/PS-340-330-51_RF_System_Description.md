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

---

## PEP-II RF System Description

See Nominal Parameter list and RF system layouts.

The RF system for the High Energy Ring (HER) consists of 5 RF stations providing a nominal RF acceleration voltage of 14 MV. Three stations are located in support building B685 in region 8 (stations 8HR1, 8HR3, 8HR5) and two stations are located in support building B725 in region 12 (stations 12HR1, 12HR3) with the station with the lowest number being the first one in line of the beam, i.e. stations 8HR1 and 12HR1.

Each HER RF station drives four single cell cavities, located in the tunnel, with peripheral equipment like 3 higher order mode loads per cavity, one movable tuner, one input ceramic window and one 400 l/sec VACION vacuum pump per cavity.

Located in the support building are the 1.2 MW klystrons which are powered by 2 MW (90 kV, 23 A) high voltage power supplies (HVPS) located outside the building.

Following each klystron is the waveguide network, first a circulator for protection of the klystron from reflected power and then the power splitting network with 3 Magic-tees followed by 4 waveguides through the penetrations into the tunnel. Each Magic-tee is terminated at its fourth port into 1.2 MW high power loads which absorb most of the reflected power from the cavities.

Each station has a set of 6 racks in the support building containing station breakers, emergency off button, local control and monitor panels for the HVPS and the overall station including safety key switches and a red warning beacon indication that the klystron high voltage is ON. The Process Logic Control system providing temperature readback and most interlock functions is located in these racks as well as klystron filament and focus supplies, cavity ion gauge readouts and ion pump supplies for klystron and cavities.

A smaller air-conditioned blue rack at each station contains the low-level RF modules. The Low-level RF system provides control of amplitude, phase and tuning of the cavity including the fast feedback system to stabilize the interaction of the cavity with the beam to dampen multibunch oscillations and dealing with the ion clearing gap in the beam.

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
| Energy Loss / Turn / Ring | V₁ | MV | — | — |
| Number of Cavities | n | — | 20 | 4 |
| Number of Cavities / Klystron | m | — | 4 | 2 |
| Number of Idling Stations | x | — | 0 | 0 |
| Beam Current | I₀ | A | — | — |
| Shunt Impedance / Cavity | Z₀ | MΩ | — | — |
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
| Actual Beta | β | — | — | — |
| Synchronous Phase Angle | φ | degrees | 75.0 | 76.10 |
| Detuning Angle | ψ | degrees | -66.0 | -74.52 |
| Change in Resonant Frequency | Δf | kHz | -78.9 | -126.7 |
| Unloaded Q | Q₀ | — | — | — |
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

> **Note**: Pages 5 through 11 of this document contain engineering drawings, schematics, and facility layouts that are image-based. Due to OCR limitations on complex diagrams, the text content from these pages is minimal and unreliable. The original PDF should be consulted for accurate interpretation of these drawings.

### Page 5: HER RF System Layout — Region 8 (B685)
*[Engineering drawing — stations 8HR1, 8HR3, 8HR5 layout]*

### Page 6: HER RF System Layout — Region 12 (B725)
*[Engineering drawing — stations 12HR1, 12HR3 layout]*

### Page 7: Typical Cross-Sectional Layout of RF Station

Key elements identified from OCR:
- Circulator
- High Voltage Power Supply
- RF Surface Building (16' × 12' door)
- Low-level RF and Control Racks
- LCW (Low-Conductivity Water)
- HCW (High-Conductivity Water)
- Water Rack
- Magic-Tee
- 1.2 MW Loads
- Penetration (from surface building to tunnel)
- Cavities in tunnel
- LER and HER rings

### Pages 8–11: Additional Layout Drawings
*[Additional facility layout and wiring diagrams — refer to original PDF for accurate interpretation]*

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `ps3403305100.pdf`. Text content on pages 1–4 is high confidence. Pages 5–11 are primarily engineering drawings with minimal extractable text; the original PDF should be consulted for these pages.

