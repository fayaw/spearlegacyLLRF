# HVPS Technical Notes and Documentation

This directory contains technical notes for the SPEAR3 High Voltage Power Supply (HVPS) system, derived from the scanned circuit schematics in the parent directory.

> ## ⚠ Verification status — read this first
>
> The schematic PDFs in this directory are **image-only scans with no extractable text**. Notes marked **VERIFIED** below were produced in September 2026 by rendering the drawing to an image and reading it directly. Notes **not** so marked were written *without* reading the drawing and are known to contain fabricated content — invented component values, wrong ratings, and boilerplate that has no counterpart on a power schematic. Do not rely on an unverified note.
>
> **As of 3 September 2026 every per-drawing note in this directory has been verified.** Only `00_HVPS_SYSTEM_OVERVIEW.md` remains unverified.
>
> **Three systematic errors were found and corrected:**
>
> 1. The `SD-730-793-xx` family are **printed-circuit-board schematics for trigger, interlock and monitor electronics**, not HVPS power assemblies. Several notes (and, until September 2026, `Designs/tex/L_legacy_system_architecture.pdf`) described them as filter inductors, secondary rectifiers, filter capacitors and crowbar thyristors.
> 2. **`sd2372301200.pdf` is the Enerpro FCOG6100 firing-circuit schematic**, not the "Voltage Divider Network Schematic" it had been catalogued as everywhere in this repository. **No HVPS voltage-divider drawing appears to exist here.**
> 3. **`sd7307940400.pdf` is an earlier-generation SCR Crowbar Trigger Board**, not the cable termination inductors. Those are on `sd7307900501.pdf` (Grounding Tank) and are **350 µH**, not the 200 µH design figure quoted in SLAC-PUB-7591.
>
> **Resolved September 2026 — the phase-shifting transformer rating.** NWL's own schematic `ei7307900000.pdf` (NWL # 39308) states **"INPUT 2750 KVA 3 PHASE / 12.5 KV AT 127 AMPS RMS"**, internally consistent since 2750 kVA ÷ (√3 × 12.5 kV) = 127 A. This supersedes the three figures previously in circulation across this repository — 350 kVA (PS-341-360-01, a decimal error), 3000 kVA (SD-730-790-01-C1, a rounded label) and 3.5 MVA (Sebek's estimate, made without this drawing).

## 📋 Document Index

### 🎯 Master Overview Document
- **[00_HVPS_SYSTEM_OVERVIEW.md](00_HVPS_SYSTEM_OVERVIEW.md)** — system design overview. **Not yet verified.**

### 📊 Per-drawing Technical Notes

| File | Drawing | Actual content | Verified |
|------|---------|-------------|---|
| **[ei7307900000.md](ei7307900000.md)** | **EI-730-790-00-C0 / NWL # 39308** | **NWL Transformers' own electrical schematic** for the klystron power supply — **"INPUT 2750 KVA 3 PHASE / 12.5 KV AT 127 AMPS RMS"** (settles the T0 rating question); T0/T1/T2 and chokes L1/L2; all monitor windings; **manufacturer's oil, pressure, vacuum and flow setpoints**; SCR controller and crowbar shown as "SUPPLIED BY CUSTOMER" | ✅ **VERIFIED** |
| **[sd7307900101.md](sd7307900101.md)** | SD-730-790-01-C1 | **HVPS System Schematic** — top-level power chain; input labelled "12.5KV 3PH 3000 KVA" (*a rounded label; the NWL nameplate is 2750 kVA at 127 A*), four series rectifier/filter stages, taps −26/−52/−77/−90 kV, "KLYSTRON 90KV 27 AMPS" | ✅ **VERIFIED** |
| **[sd7307900501.md](sd7307900501.md)** | SD-730-790-05-C1 | **Grounding Tank** — termination inductors L1/L2 **"350 UHY 40A"**, D1 25 kV/100 A, C3/C4 30 nF/37 kV, C1/C2 10 nF/56 kV, R1 50 Ω/90 kV; **CT1 "10A/V PERSON 110"** Pearson CT; **CT2 Danfysik DC-CT**; **S1 15 A/50 mV shunt**; SW1 manual ground sw, SW2 Ross ground sw; LEV3 oil level; J1 MS3102R18-1P | ✅ **VERIFIED** |
| **[sd2372301299.md](sd2372301299.md)** | **SD-237-230-12-R0** (PDF is `sd2372301200.pdf`) | **Enerpro General Purpose 3-Phase Firing Circuit, PCB PN FCOG6100** — Enerpro drawing E128. **This PDF is not a voltage-divider schematic**, despite having been catalogued as one; the dividers are on `wd7307940400.pdf`. | ✅ **VERIFIED** |
| **[sd2372301401.md](sd2372301401.md)** | SD-237-230-14-C1 | **Enerpro Voltage and Current Regulator Board** — J4C "SIG-HI / SCR PHASED-CONTROL OUTPUT", J4A "+EL1", J4B "+IL1"; INA114/INA117/OP77/MC34074/CD4044B; **VTL5C** opto-resistors (obsolete) | ✅ **VERIFIED** |
| **[sd7307930304.md](sd7307930304.md)** | SD-730-793-03-C4 | **12 kV SCR Driver Board** — timing 50 µs / **16 µs (adj. R2)** / 5 µs / 18 µs; P1 4DB-P107-06 (+240 V, +120 V) | ✅ **VERIFIED** |
| **[sd7307930402.md](sd7307930402.md)** | SD-730-793-04-C2 | **SCR Crowbar Trigger Board** — timing **50 ms (adj. R1)** / 5 ms / 44 µs / 3×5 µs; J1 SIP4 "Output Plug to Old Slave Trigger Bd"; **drives the new optical SCR** (R3/R37 → 78.70 kΩ for conventional SCRs) | ✅ **VERIFIED** |
| **[sd7307930702.md](sd7307930702.md)** | SD-730-793-07-C2 | **SCR Control Driver — Right Side Trigger Interconnect Bd** — J1 BNC "TRANSFORMER ARC TRIGGER", J2 HFBR-2412 "F.O SCR ENABLE" | ✅ **VERIFIED** |
| **[sd7307930801.md](sd7307930801.md)** | SD-730-793-08-C1 | **SCR Control Driver — Left Side Trigger Interconnect Bd** — J1 BNC "KLYSTRON ARC TRIGGER", J2 HFBR-2412 "F.O KLYSTRON CROWBAR", J3 HFBR-1412 "F.O STATUS" | ✅ **VERIFIED** |
| **[sd7307931203.md](sd7307931203.md)** | SD-730-793-12-C3 | **2MW Klystron PS Monitor Board** — BNC1 "+ Voltage 10 kV/V", BNC2 "+ Current 5A/V", NMH2415S isolated rails, BUF634 buffers | ✅ **VERIFIED** |
| **[sd7307931301.md](sd7307931301.md)** | SD-730-793-13-C1 | **Optical SCR Trigger Board** — 6N-139 input, CD4047B/CD4538 timing, IXFH12N90 + 60T:60T:60T pulse transformer, P1 rails +240 V / +120 V | ✅ **VERIFIED** |
| **[sd7307940400.md](sd7307940400.md)** | **SD-730-794-04-C0** | **SCR Crowbar Trigger Board, 1999 generation** (R. Cassel, 11/08/99) — +15 V logic, 6N-138 opto, discrete IRFD9120/IRFD110 gate drivers, IXYTH12N90 switches. **Not** the cable termination inductors — those are in the Grounding Tank | ✅ **VERIFIED** |

### 📝 Superseded documents (removed September 2026)

- `SD-7307900101_HVPS_System_Schematic_Analysis.md` — duplicate of `sd7307900101.md` for the same drawing; both were unverified and mutually inconsistent (one gave a "60 kV 80 A crowbar", the other "40 kV 80 A"; one claimed a "klystron 50 kV rating"; one asserted a "cathode grounded configuration"). Replaced by a single verified note.
- `SD-237-230-14_Regulator_Board_Analysis.md` — duplicate of `sd2372301401.md`. Both were unverified; **both deleted** and replaced by a single verified note.

### ⚠ Known filename mismatch

The note `sd2372301299.md` describes drawing **SD-237-230-12-R0**, whose PDF is `sd2372301200.pdf`. There is no `sd2372301299.pdf`. The note filename has been left as-is to avoid breaking existing links, but the drawing/PDF correspondence is as stated in the index above.

## 🏗 System Architecture Summary

The SPEAR3 HVPS is a **12-pulse thyristor-controlled rectifier** rated −90 kV / 27 A / 2.5 MW, converting 12.47 kV 3-phase AC to negative HV DC for the klystron cathode. Typical operation is ≈ −72 to −75 kV at 19–22 A.

> **Note**: −77 kV is an **intermediate DC stage tap** on SD-730-790-01-C1, not the operating point. It is easily mistaken for the output voltage.

### Key Subsystems:
1. **Power Conversion**: Phase-shift transformer → SCR rectifiers → HV filter
2. **Control & Regulation**: Master regulator board with precision op-amps and optocoupler isolation
3. **Protection**: Multi-layer protection including crowbar, arc detection, and PPS interlocks
4. **Monitoring**: Dual-isolated precision measurement with fiber-optic status communication

### Technology Highlights:
- **12-Pulse Configuration**: Eliminates 5th/7th harmonics, 720 Hz ripple frequency
- **Precision Control**: INA114/INA117/OP77/MC34074 op-amps, 4N32 and 6N-139 optocoupler isolation
- **Fast Protection**: crowbar conducts in ≈ 10 µs; primary current interrupted in 4–8 ms (SLAC-PUB-7591)
- **Distributed Control**: 10+ specialized circuit boards with coordinated operation
- **Known obsolescence**: VTL5C opto-coupled variable resistors on the regulator board; CD4xxx-series logic throughout

## 🔧 Document Structure

Each Markdown technical note follows a consistent enhanced structure:
1. **Document Header** — Drawing numbers, board type, generation info
2. **System Overview** — High-level function description with context
3. **Circuit Architecture** — Mermaid diagrams showing signal flow and connections
4. **Functional Description** — Detailed operational analysis
5. **Key Components** — Organized tables of ICs, power components, and specifications
6. **Performance Specifications** — Operating parameters and design limits
7. **Design Features** — Signal processing, protection systems, and key capabilities
8. **Test Points & Diagnostics** — Maintenance procedures and troubleshooting
9. **Visual Diagrams** — Enhanced ASCII and Mermaid circuit representations

## 🎯 Usage Guidelines

### For System Understanding:
1. Start with **00_HVPS_SYSTEM_OVERVIEW.md** for complete system context
2. Review individual DOCX files for detailed circuit analysis
3. Cross-reference with supporting markdown analyses

### For Design Replication:
1. Use the **Mermaid Circuit Diagrams** for understanding signal flow and connections
2. Reference **Component Tables** for detailed IC specifications and modern equivalents
3. Follow **Circuit Architecture** sections for system integration and board interconnections

### For Maintenance:
1. Use **Test Points** sections for troubleshooting access
2. Reference **Common Failure Modes** for diagnostic guidance
3. Follow **Calibration Procedures** for system adjustment

## 📚 Related Documentation

### System Engineering Documents:
- `../../Designs/4_HVPS_Engineering_Technical_Note.md` - Complete system engineering reference
- `../../Designs/8_HVPS_PPS_INTERFACE_TECHNICAL_DOCUMENT.md` - PPS interface documentation

### Original Schematics:
- `../schematics/*.pdf` - Original scanned PDF schematics (source material)

## ⚠️ Important Notes

- **Enhanced Format**: All technical notes converted to Markdown with Mermaid diagrams
- **Visual Diagrams**: Circuit architecture shown with detailed signal flow representations
- **Component Analysis**: Comprehensive IC tables with specifications and functions
- **Interactive Content**: Mermaid diagrams render in GitHub and compatible viewers
- **Maintenance Focus**: Enhanced troubleshooting and diagnostic information

## 🎨 Diagram Features

### Mermaid Circuit Diagrams
- **Signal Flow**: Clear representation of data and control paths
- **Component Hierarchy**: Logical grouping of functional blocks
- **Power Distribution**: Supply voltage routing and isolation
- **Interactive**: Clickable elements in supported viewers

### Enhanced Tables
- **Component Specifications**: Detailed IC characteristics and ratings
- **Performance Parameters**: Operating limits and design margins
- **Test Points**: Diagnostic access and measurement procedures

---

**Last Updated**: March 2026  
**Document Count**: 11 enhanced Markdown technical notes + 1 system overview + 2 supporting analyses  
**Format**: Markdown with Mermaid diagrams and enhanced visual representations  
**Coverage**: Complete HVPS system from power conversion to individual circuit boards
