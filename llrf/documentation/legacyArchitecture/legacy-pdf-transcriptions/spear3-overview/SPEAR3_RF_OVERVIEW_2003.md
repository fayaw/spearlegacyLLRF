# SPEAR3 RF System Overview (2003 Presentation Transcription)

**Document ID**: Rnt-OVERVIEW-2003  
**Original Source**: spear3RF_overview_2003.pdf (transcribed from image-based PDF using pdftotext and pdfimages)  
**Version**: 1.0  
**Date**: 2026-03-27  
**Status**: DRAFT — AI-assisted transcription  
**Location**: llrf/documentation/legacyArchitecture/legacy-pdf-transcriptions/spear3-overview/SPEAR3_RF_OVERVIEW_2003.md  
**Author**: Codegen AI (transcription), original by Sam Park (11/06/2003)  
**Tier**: 1 — High-Level System Overview  

---

## Revision History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | 2026-03-27 | Initial transcription from image-based PDF. Text extracted with pdftotext -layout. Images extracted as PPM/PBM files and moved to subdirectory. |

---

## Notes on Transcription

- This is a transcription of a 2003 presentation by Sam Park on the SPEAR3 RF system.
- The PDF is image-based, so text extraction preserves layout as much as possible.
- Images (diagrams, photos) have been extracted and saved as individual files in the `spear3-overview/` directory (e.g., spear3RF_overview_2003-000.ppm).
- Inline image references are added where diagrams appear in the original slides.
- Some formatting (e.g., bullet points, tables) may have minor artifacts due to OCR-like extraction.
- For precise diagrams, refer to the extracted image files.

---

## Slide 1: Title Slide

Spear3 RF System

• RF Requirement  
• Overall System  
• High Power Components  
• Operation and Control  

Spear3 RF System             Sam Park   11/06/2003  

![Slide Title](spear3RF_overview_2003-000.ppm)

---

## Slide 2: SPEAR 3 History

1996       Low emittance lattices explored  
1996       SPEAR 3 proposed  
11/97      SPEAR 3 design study team formed  
11/97      Director's Review  
07/98      DOE Lehman Review  
FY99       DOE BES and NIH discuss joint funding  
11/98      Active cavity and WG arcing  
01/99      Additional funding for NEW RF (476.3 MHz)  
04/99      Active RFHVPS failure.  
01/00      Cavities ordered (Received 05/03)  
03/00      Klystron ordered (Received 08/01, Repaired 05/03)  
05/01      2.5 MW PS ordered (Received 01/02)  
11/01      Circulator ordered (Received 11/01)  
02/02      WG parts ordered (Receive 04/02)  
03/02      LLRF work in progress  
04/03      Installation (6 months)  
12/03      Commissioning (3 months)  
03/04      User Beam (3.0 GeV, 100 mA, 18 nm-rad)  

Spear3 RF System                 Sam Park                11/06/2003  

![SPEAR 3 History](spear3RF_overview_2003-001.ppm)

---

## Slide 3: Electron Beam Energy Loss due to Synchrotron Radiation

Energy loss at bend magnets  
U0-bend (keV/turn) = 88.5*(Eb/GeV)^4/(ρ/m)  

Energy loss at insertion device  
U0-ID (keV/turn) = 0.633*(Eb/GeV)^2*< (B/T)^2 >*(L/m)^2  
where <B> is the rms magnetic field of the pole  
and L is the insertion device length  

With beam energy Eb=3.0GeV, bend radius ρ=7.86m,  
total beam power loss is 1.16MV*500mA=510 kW  
in 2003, and 1.33MV*500mA=665 kW in 2012  
as the insertion devices are added on.  

Spear3 RF System              Sam Park            11/06/2003  

![Electron Beam Energy Loss](spear3RF_overview_2003-002.ppm)

---

## Slide 4: Spear 3 Beam Lifetime

[Diagram of beam lifetime vs. current]

Spear3 RF System           Sam Park   11/06/2003  

![Spear 3 Beam Lifetime](spear3RF_overview_2003-003.ppm)

---

## Slide 5: SPEAR 3 RF Installation

[Diagram of RF installation layout]

Spear3 RF System                Sam Park     11/06/2003  

![SPEAR 3 RF Installation](spear3RF_overview_2003-004.ppm)

---

## Slide 6: SPEAR 3 Overall System

[Overall system block diagram]

Spear3 RF System           Sam Park   11/06/2003  

![SPEAR 3 Overall System](spear3RF_overview_2003-005.ppm)

---

## Slide 7: Klystron (Repaired Marconi)

• Maximum RF Power : Prf = 1.2 MW  
• Beam Power : Pb = Vb*Ib= 82 kV * 23.5 A = 1.93 MW  
• Microperveance µP = Ib/Vb^1.5 * 10^6 = 1.00  
• Efficiency η = Prf/Pb = 62%  
• Gain A = 10*Log10 (Prf / Pdrive) = 45 dB  

• Drive amplifier power Pdrive = 40 W  
• Cathode heater power Ph = 110Vac*5.2A = 570 W  
• Focusing magnet power Pm = 70.2V*47.5A = 3.33kW  
• No bucking coil power  
• LCW flow for 1.5MW : 275 gpm, 150 psi, 32 ±1 °C  
• 2 VacIon pumps, 8 L/s each  

Spear3 RF System                               Sam Park   11/06/2003  

![Klystron Specifications](spear3RF_overview_2003-006.ppm)

---

## Slide 8: SPEAR 3 Klystron

• Spear3 klystron from Marconi  
• That klystron was loaned to PEP2  
• The klystron failed, and rebuilt by PCI  
• SLAC Klystron Dept to produce 4 klystrons  
• Those SLAC klystrons have higher power capability  

Philips/EEV/Marconi Klystron Experience at SLAC  

No.    Klystron    Date failed Fil. Hrs Failure type          Remedy  
1    Philips #5   09/25/00    14,102   Heater short          Rebuilt at CPI  
2    Philips #5   03/29/01    13,895   Anode dislocation  
3    Philips #5   05/22/01     5,740   Anode dislocation     Rebuilt at SLAC  
Vacuum leak (up to  
4    Marconi #3   07/17/01     1,350   10 mA pump current)   Rebuilt at CPI  
Vacuum leak (up to  
5    Marconi #2   07/26/01     4,730   60 mA pump current)   Rebuilt at CPI  

Spear3 RF System                               Sam Park                         11/06/2003  

![SPEAR 3 Klystron](spear3RF_overview_2003-007.ppm)

---

## Slide 9: Marconi Klystron

[Photo of Marconi klystron]

Spear3 RF System             Sam Park   11/06/2003  

![Marconi Klystron](spear3RF_overview_2003-008.ppm)

---

## Slide 10: ATF Circulator Specification

☐ Type: Y-Junction 3-port Circulator  
☐ Frequency : 476 ± 10 MHz  
☐ Forward Power : 1.2 MW cw  
☐ Reverse Power : 1.2 MW cw  
☐ Insertion Loss : < 0.1 dB (VSWR <1.1, power reflection <0.25% )  
☐ Isolation : > 26 dB (>14 dB in ± 10 MHz)  
☐ Cooling LCW : >26 gpm (150 psig, 25~40°C, nominal 35 ± 1°C)  
☐ Mounting Orientation : any  

Spear3 RF System              Sam Park             11/06/2003  

![ATF Circulator Specification](spear3RF_overview_2003-009.ppm)

---

## Slide 11: AFT Circulator

[Photo of AFT circulator]

Spear3 RF System          Sam Park   11/06/2003  

![AFT Circulator](spear3RF_overview_2003-010.ppm)

---

## Slide 12: Water Load Specification

☐ Coolant : HCW (0.75% Corr-Shield by volume to LCW)  

☐ Coolant supply : 150 psig, 10~70 °C  

☐ Coolant return : 15 psig, <80°C  

☐ Coolant duct : Teflon tubing  

☐ Frequency : 476 ±10 MHz  

☐ Power : <1.2 MW average (<2.0 MW peak for 100 µs)  

☐ VSWR : <1.05 (reflected power < 0.06%)  

☐ RF Leakage : < 0.1 mW/cm²  

☐ Length : 9.5 feet overall  

☐ Air pressure : <0.5 psig (0.25 psig nominal)  

Spear3 RF System              Sam Park          11/06/2003  

![Water Load Specification](spear3RF_overview_2003-011.ppm)

---

## Slide 13: Water Load

[Photo of water load]

Spear3 RF System          Sam Park   11/06/2003  

![Water Load](spear3RF_overview_2003-012.ppm)

---

## Slide 14: HCW Station behind Booster

[Photo of HCW station]

Spear3 RF System           Sam Park         11/06/2003  

![HCW Station](spear3RF_overview_2003-013.ppm)

---

## Slide 15: RFHV Power Supply Specification

☐ Output DC power : 90 kV* 27A=2.43 MW  
Corresponds to microperveance of 1.00  
and 2.43 * 0.62 = 1.50 MW RF power  

☐ Input AC power : 12.47 kV line-to-line, 127 A per phase  
Power supply efficiency = 2430/(1.73*127*12.47) = 0.89  
Lower efficiency at lower output voltage/power  

☐ New filtering capacitors by General Atomics  

☐ Light triggered crowbar SCR's  

☐ Less than 0.5 Joules to the klystron in case of arcing  
at 80 kV per swinging ball test of crowbar  

Spear3 RF System             Sam Park             11/06/2003  

![RFHV Power Supply Specification](spear3RF_overview_2003-014.ppm)

---

## Slide 16: RFHV Power Supply Schematic

[Schematic diagram]

Spear3 RF System          Sam Park         11/06/2003  

![RFHV Power Supply Schematic](spear3RF_overview_2003-015.ppm)

---

## Slide 17: Spear3 RFHV Power Supply

[Photo of RFHV PS]

Spear3 RF System                 Sam Park     11/06/2003  

![Spear3 RFHV Power Supply](spear3RF_overview_2003-016.ppm)

---

## Slide 18: Spear3 RFHV Power Supply Grounding Tank

[Photo of grounding tank]

Spear3 RF System            Sam Park            11/06/2003  

![Grounding Tank](spear3RF_overview_2003-017.ppm)

---

## Slide 19: RFHV PS Swinging Ball Test

[Photo of swinging ball test]

Spear3 RF System                Sam Park        11/06/2003  

![Swinging Ball Test](spear3RF_overview_2003-018.ppm)

---

## Slide 20: Spear3 RF Cavity Characteristics

☐ Frequency 476.3 MHz (different from PEP2 476.0 MHz)  
☐ Shunt Impedance Ra = Vg²/Prf = 7.62 MΩ (95 kW for 0.85 MV)  
☐ Acceleration field ~ 3.9 MV/m  
☐ Coupling β = 1+Pb/Pc = 3.8 (high reflection at lower current)  
☐ Window power <410 kW, Wall power < 80 W/cm²  
☐ 3 high power HOM loads at each of 4 cavities  
☐ One HOM filter per cavity at the waveguide coupler  
Similar filters were used at Spear2  
☐ One movable tuner per cavity  
☐ Coupler window temperature is monitored by IR sensor  
☐ Q ~ 30,000 at operating temperature (Fill time is Q/ ω ~10 µs)  
☐ If RF is turned off on orbit interlock trip, beam is lost in ~300 µs  

Spear3 RF System                   Sam Park                 11/06/2003  

![RF Cavity Characteristics](spear3RF_overview_2003-019.ppm)

---

## Slide 21: Spear3 RF Cavity Assembly

[Photo of cavity assembly]

Spear3 RF System          Sam Park       11/06/2003  

![Cavity Assembly 1](spear3RF_overview_2003-020.ppm)

---

## Slide 22: Spear3 RF Cavity Assembly

[Another photo of cavity assembly]

Spear3 RF System          Sam Park       11/06/2003  

![Cavity Assembly 2](spear3RF_overview_2003-021.ppm)

---

## Slide 23: Cavities in the West Straight

[Photo of cavities in tunnel]

Spear3 RF System            Sam Park         11/06/2003  

![Cavities in West Straight 1](spear3RF_overview_2003-022.ppm)

---

## Slide 24: Cavities in the West Straight

[Another photo]

Spear3 RF System            Sam Park         11/06/2003  

![Cavities in West Straight 2](spear3RF_overview_2003-023.ppm)

---

## Slide 25: HOM Load

Matrix of 1.0 inch square ferrite  
tiles. They are soft- soldered onto a  
copper plate.  
Cooling channels were drilled out  
from a solid copper plate.  

HOM load plate, water-cooled  

HOM load at E- and H-mitre  
LCW flow is 6 gallons per minute. No appreciable ΔT is detected,  
but the flow is interlocked.  

Spear3 RF System                   Sam Park                      11/06/2003  

![HOM Load](spear3RF_overview_2003-024.ppm)

---

## Slide 26: Movable Tuner below the Cavity

[Photo of tuner]

Spear3 RF System           Sam Park           11/06/2003  

![Movable Tuner](spear3RF_overview_2003-025.ppm)

---

## Slide 27: Movable Tuner Tuning Range

[Graph: Resonance Shift (MHz) vs. Tuner Position (mm)]

y = 3.4769E-06x³ + 3.8603E-04x² + 1.9154E-02x - 2.2649E-01  
R² = 9.9982E-01, y = δfres , x = tuner position  

Spear3 RF System                                                      Sam Park                          11/06/2003  

![Tuning Range Graph](spear3RF_overview_2003-026.ppm)

---

## Slide 28: Waveguide Network & Phasing

• Magic Tees : Divide RF power evenly.  

• Magic tee loads are to compensate for any mismatch  

and absorbs reflected power (two arms are 90 degree apart)  

• Bellow lengths are adjusted to match the RF phase in cavities  

• Guided wavelength λg = λ0/[1-(λ0 /2a)²]^1/2, λg = c/f  

• Waveguide sections are positively pressurized with dry air  

to ensure that there is no mechanical gap (no RF leakage)  

and no moisture enters into the system  

• Window at the klystron is cooled by forced air  

Spear3 RF System               Sam Park               11/06/2003  

![Waveguide Network](spear3RF_overview_2003-027.ppm)

---

## Slide 29: Magic-T and Bellow Network

[Diagram of magic-T and bellows]

Spear3 RF System         Sam Park       11/06/2003  

![Magic-T Network](spear3RF_overview_2003-028.ppm)

---

## Slide 30: LLRF in Room 101, Bldg 132

[Photo of LLRF setup]

Spear3 RF System         Sam Park       11/06/2003  

![LLRF Setup](spear3RF_overview_2003-029.ppm)

---

## Slide 31: Connections to Klystron

[Diagram of connections]

Spear3 RF System           Sam Park   11/06/2003  

![Klystron Connections 1](spear3RF_overview_2003-030.ppm)

---

## Slide 32: Connections to Klystron

[Another diagram]

Spear3 RF System           Sam Park   11/06/2003  

![Klystron Connections 2](spear3RF_overview_2003-031.ppm)

---

*End of transcription. Additional slides may follow in the full extraction if the output was truncated. For complete text, refer to the pdftotext raw output. Images are available in the directory for insertion into the main document.*

