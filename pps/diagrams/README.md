# PPS Schematic Diagrams — AI-Readable Text Representations

> **System**: SPEAR HVPS (High Voltage Power Supply) PPS Interlocks
> **Location**: SLAC/SSRL, Building B118
> **Generated from**: 6 PDF schematic drawings in `pps/`

## Purpose

These Mermaid and ASCII text diagrams are **AI-readable representations** of the original engineering schematics. They are designed to allow AI systems to understand the HVPS PPS design for:
- Design review and analysis
- Safety system verification
- System documentation
- Troubleshooting guidance
- Upgrade planning (replacing obsolete hardware)

## Document Index

| # | File | Source PDF | Description |
|---|------|-----------|-------------|
| 0 | [00_SYSTEM_OVERVIEW_CORRECTED.md](00_SYSTEM_OVERVIEW_CORRECTED.md) | All + docx | **2nd validation pass** — Master system architecture with corrections |
| 1 | [01_gp4397040201_vacuum_contactor_controller.md](01_gp4397040201_vacuum_contactor_controller.md) | `gp4397040201.pdf` | Vacuum contactor controller relay logic, closing/opening sequences |
| 2 | [02_rossEngr713203_vacuum_contactor_driver.md](02_rossEngr713203_vacuum_contactor_driver.md) | `rossEngr713203.pdf` | Ross Engineering driver & contactor, TB2 pinout, auxiliary contacts |
| 3 | [03_sd7307900501_grounding_tank.md](03_sd7307900501_grounding_tank.md) | `sd7307900501.pdf` | Grounding tank schematic, Ross switch, Danfysik, arc fault |
| 4 | [04_wd7307900206_hoffman_box_wiring.md](04_wd7307900206_hoffman_box_wiring.md) | `wd7307900206.pdf` | Hoffman Box (HVPS controller), PLC I/O map, all terminal strips |
| 5 | [05_wd7307900103_interconnection_full.md](05_wd7307900103_interconnection_full.md) | `wd7307900103.pdf` | Full interconnection: Hoffman Box ↔ Contactor ↔ Tank |
| 6 | [06_wd7307940600_interconnection_grounding_tank.md](06_wd7307940600_interconnection_grounding_tank.md) | `wd7307940600.pdf` | Detailed TS-6 to Grounding Tank wiring |
| 7 | [07_PLC_CODE_AND_LOGIC.md](07_PLC_CODE_AND_LOGIC.md) | docx analysis | PLC ladder logic rungs, fault scenarios |
| 8 | [08_CORRECTED_HAND_DRAWING.md](08_CORRECTED_HAND_DRAWING.md) | docx Figure 1 | **Hand drawing corrected** — PPS interface with TS-4→TS-5 fix |

## Quick Reference

### PPS Two-Chain Safety System
- **Chain 1**: PPS Enable → PLC → OX8 Relay → K4 → MX → L1 → Vacuum Contactor
- **Chain 2**: PPS Enable → PLC → IO8 Relay → Ross Grounding Switch

### Key Connectors
- **GOB12-88PNE**: 8-pin PPS interface (Burndy/Souriau Trim Trio)
- **MS3102R18-1P**: Grounding tank connector (J1/P5)
- **AMP 8-Pin**: PPS status LEDs

### Key Terminal Strips
- **TS-5**: Contactor controls (Hoffman ↔ Switchgear)
- **TS-6**: Grounding tank (Hoffman ↔ Termination Tank)

### Known Documentation Issues (2nd Validation Pass)
1. **K4/RR relay labels swapped** on WD-730-794-02-C0 — K4 is PPS control, RR is reset ✓
2. **L1/L2 coil labels incorrect** on GP-439-704-02-C1 — Both labeled as L2 ✓
3. **Manual grounding switch contact type** (NO vs NC) inconsistent — Field verification needed ⚠️
4. **Rung 0017 mislabeled** as "Crowbar On" — Should be "Contactor Enable" ✓
5. **Hand drawing error** — Pin A→TS-4 pin 14, Pin B→TS-4 pin 15 — Should be TS-5 pins 15,14 ✓

### Original PDF Images
PNG renderings uploaded to: `codegen-artifacts-store` branch under `pps-analysis/`
