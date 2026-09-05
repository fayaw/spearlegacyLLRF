# PPS Schematic Diagrams — AI-Readable Text Representations

> **System**: SPEAR HVPS (High Voltage Power Supply) PPS Interlocks
> **Location**: SLAC/SSRL, Buildings B118 / B514
> **Generated from**: the switchgear and wiring PDF drawings in `hvps/documentation/`

> ## ⚠ Verification status — read this first
>
> All source drawings are **image-only scans with no extractable text**. Notes marked **VERIFIED** in the index below were produced in **September 2026** by rendering each drawing to an image and reading it directly. Unmarked notes were written *without* reading the drawing and may contain invented detail.
>
> **Corrections made during the September 2026 verification pass:**
>
> 1. **`06`** routed the oil-level sensor and Danfysik through connector P5 using invented pin letters. There are three separate cable runs; P5 carries only the shunt and ground-switch circuits.
> 2. **`02`** had the S5 contact pinout with COM and NO transposed — the order is **NO / COM / NC** on ascending terminals — and dated the drawing "through 2021" when the last revision is **E, 2 Feb 1983** (the 2021 mark is a *received* stamp).
> 3. **`01`** carried a fabricated provenance string and mislabelled the ANSI 50/51 protective relays as "MCO" relays.
> 4. **`04`** omitted **Slot-0, the 1747-L532 SLC-5/03 processor**, and described the 1747-DCM as a "scanner". It is a Remote I/O **adapter**; the scanner is the 6008-SV in the VXI crate in B132.
> 5. "Belding" is a misreading throughout — the cable manufacturer is **Belden** (83709, 83715, 88761).

## Purpose

These documents provide **AI-readable analysis** of both the current legacy system and planned upgrade architecture, supporting:
- **Current system analysis** — legacy hardware and identified issues
- **Upgrade planning** — modern architecture addressing PPS compliance
- **Safety system verification** — PPS chain analysis and fail-safe mechanisms
- **Design process support** — complete technical understanding for AI assistance

## Document Index

| # | File | Source drawing | Description | Verified |
|---|------|--------|-------------|---|
| 0 | [00_SYSTEM_OVERVIEW.md](00_SYSTEM_OVERVIEW.md) | All sources | **Master overview** — current system + upgrade architecture | ❌ |
| 1 | [01_gp4397040201_vacuum_contactor_controller.md](01_gp4397040201_vacuum_contactor_controller.md) | `gp4397040201.pdf` — **GP-439-704-02-C1** | Vacuum contactor controller schematic; sequence of operation; **PPS (CONTACTOR) = TB3-22/23/24**; **≥170 ms hold-in** on loss of AC control power | ✅ |
| 2 | [02_rossEngr713203_vacuum_contactor_driver.md](02_rossEngr713203_vacuum_contactor_driver.md) | `rossEngr713203.pdf` — **713203 E-1** | Ross HCA-1-A driver + HQ3 contactor; TB2 pinout; **300–400 V DC stored energy**, 5 s door dump, 5 min manual wait | ✅ |
| 3 | [03_sd7307900501_grounding_tank.md](03_sd7307900501_grounding_tank.md) | `sd7307900501.pdf` — **SD-730-790-05-C1** | Grounding tank; Ross switch; Danfysik; Pearson 110; see also the fuller note in `hvps/documentation/schematics/technical_notes/sd7307900501.md` | ✅ (see note) |
| 4 | [04_wd7307900206_hoffman_box_wiring.md](04_wd7307900206_hoffman_box_wiring.md) | `wd7307900206.pdf` — **WD-730-790-02-C6** | **Master wiring diagram.** PLC chassis map; confirms TS-3 = Voltage Monitor, PPS LEDs on AMP-8PIN J2, TC-1…TC-4 assignments | ✅ |
| 5 | [05_wd7307900103_interconnection_full.md](05_wd7307900103_interconnection_full.md) | `wd7307900103.pdf` — **WD-730-790-01-C3** | System interconnection: Hoffman Box ↔ Contactor Disconnect ↔ Termination Tank; S1–S6 contact functions; three oil-level sensors | ✅ |
| 6 | [06_wd7307940600_interconnection_grounding_tank.md](06_wd7307940600_interconnection_grounding_tank.md) | `wd7307940600.pdf` — **WD-730-794-06-C0** | TS-6 to Grounding Tank wiring. **Caveat: a "TEST STAND" drawing with no revision entries** | ✅ |
| 7 | [07_PLC_CODE_AND_LOGIC.md](07_PLC_CODE_AND_LOGIC.md) | `CasselPLCCode.pdf` | PLC ladder logic rungs, fault scenarios | — |
| 8 | [08_CORRECTED_HAND_DRAWING.md](08_CORRECTED_HAND_DRAWING.md) | docx Figure 1 | Hand drawing corrected — PPS interface with TS-4→TS-5 fix | ❌ |

## Related notes held elsewhere

Two switchgear drawings are documented beside their source PDFs rather than here, to keep each drawing's note next to the drawing it describes. Both were verified by direct reading in September 2026:

| Drawing | Note |
|---|---|
| **ID-308-801-06-C1** — contactor controller connection wiring; supplies the middle link in the PPS readback trace | [`hvps/documentation/switchgear/technical_notes/TN_id3088010601_ConnectionWiringDiagram.md`](../../hvps/documentation/switchgear/technical_notes/TN_id3088010601_ConnectionWiringDiagram.md) |
| **GP-308-500-01-R3** — original 1977 LBL design drawing; authoritative relay legend; contactor rated 14.5 kV 400 A 3-pole; blocking relay blocks trip above 2000 A | [`hvps/documentation/switchgear/technical_notes/TN_gp3085000103_SwitchgearSchematicAndArrangement.md`](../../hvps/documentation/switchgear/technical_notes/TN_gp3085000103_SwitchgearSchematicAndArrangement.md) |

Notes 1 and 2 above have counterpart notes in the same switchgear directory — [`TN_gp4397040201_VacContSchematicDiagram.md`](../../hvps/documentation/switchgear/technical_notes/TN_gp4397040201_VacContSchematicDiagram.md) and [`TN_DOC041421_RossEngr713203_SystemSchematic.md`](../../hvps/documentation/switchgear/technical_notes/TN_DOC041421_RossEngr713203_SystemSchematic.md). Those give the drawing-by-drawing transcription; the notes here give the PPS system view. Keep them consistent.

> **On the `.docx` files in the switchgear directory**: each is a conversion **of** its same-named `.md` file, not an independent original. The only sources are the PDF drawings.

## ✅ The PPS contact readback — complete trace

Established September 2026 by cross-reading four drawings:

| Link | Drawing | Establishes |
|---|---|---|
| 1 | Ross 713203 E-1 | HQ3 auxiliary contact set **S5** on **TB2-18 (NO) / 19 (COM) / 20 (NC)** |
| 2 | ID-308-801-06-C1 | TB2-18/19/20 carry **wires 20 / 21 / 22** |
| 3 | GP-439-704-02-C1 | Wires 20/21/22 are labelled **"PPS (CONTACTOR)"** → **TB3-22/23/24** |
| 4 | WD-730-790-01-C3 | Contactor Disconnect labels one auxiliary set **"CONTACTS PPS"** |

The final hop — which **GOB1208PNE** pins carry it — remains an **unconfirmed assumption** per J. Sebek. See `Designs/tex/L_legacy_system_architecture.pdf` §13.2.1.

## Quick Reference

### PPS Two-Chain Safety System
- **Chain 1**: PPS Enable → PLC → OX8 Relay → K4 → MX → L1 → Vacuum Contactor *(fail-safe open; ≈200 ms worst case to interrupt 12.47 kV)*
- **Chain 2**: PPS Enable → PLC → IO8 Relay → Ross Grounding Switch *(fail-safe closed/grounded)*

### Relay legend (authoritative, from GP-308-500-01-R3)

| Designation | Function |
|---|---|
| 27 | Under voltage relay |
| MX | Remote control relay, 24 V DC |
| IP | Interposing relay, 24 V DC |
| RR | Remote reset relay, 24 V DC |
| TX | Auxiliary tripping relay |
| BR | Blocking relay — **prevents contactor trip above 2000 A fault current** |
| 50-51 | Overcurrent relay, 2–6 A with 20–40 A instantaneous, Westinghouse type CO-6 or equal |
| 50-51 N | Grounding overcurrent relay, 0.5–2.5 A with 20–40 A instantaneous |
| 01 / LT | Local control switch — trip |
| M | Main operating and holding coils |

### Key Connectors
- **GOB1208PNE**: PPS interface connector
- **MS3102R18-1P**: Grounding tank connector (J1 / P5)
- **AMP 8-Pin J2**: PPS status LEDs — PPS1/PPS2 green, PPS3/PPS4 red

### Key Terminal Strips
- **TS-2**: Control power common
- **TS-3**: **Voltage Monitor** — to PS Monitor Board SD-730-793-12
- **TS-4**: Transformer interlocks
- **TS-5**: Contactor controls (Hoffman ↔ Switchgear)
- **TS-6**: Grounding tank (Hoffman ↔ Termination Tank)
- **TS-7**: Transformer monitors
- **TS-8**: Permits

### Known Documentation Issues (2nd Validation Pass)
1. **K4/RR relay labels swapped** on WD-730-794-02-C0 — K4 is PPS control, RR is reset ✓
2. **L1/L2 coil labels incorrect** on GP-439-704-02-C1 — Both labeled as L2 ✓
3. **Manual grounding switch contact type** (NO vs NC) inconsistent — Field verification needed ⚠️
4. **Rung 0017 mislabeled** as "Crowbar On" — Should be "Contactor Enable" ✓
5. **Hand drawing error** — Pin A→TS-4 pin 14, Pin B→TS-4 pin 15 — Should be TS-5 pins 15,14 ✓

### Original PDF Images
PNG renderings uploaded to: `codegen-artifacts-store` branch under `pps-analysis/`
