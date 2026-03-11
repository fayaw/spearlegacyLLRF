# HVPS Original Documents — Technical Notes

**Purpose:** Comprehensive technical notes derived from the original PEP-II HVPS design documents stored in `hvps/architecture/originalDocuments/`. These notes capture all engineering details from the source PDFs and PPTX files that contain scanned schematics, images, and design presentations.

## Source Documents

| File | Type | Content | Pages |
|------|------|---------|-------|
| `slac-pub-7591.pdf` | IEEE Publication | "A Unique Power Supply for the PEP II Klystron at SLAC" — R. Cassel & M.N. Nguyen, July 1997 | 5 |
| `pepII supply.pptx` | Presentation | SLAC Klystron Power Supply — detailed schematics, waveforms, component details, wiring diagrams | 24 |
| `ps3413600102.pdf` | Engineering Drawing | Original PEP-II power supply specification/schematic package (scanned, image-only) | 24 |

## Technical Notes Index

| Note | Title | Source Document(s) |
|------|-------|-------------------|
| [01](01_SLAC_PUB_7591_IEEE_Paper_Analysis.md) | SLAC-PUB-7591 IEEE Paper — Complete Technical Analysis | `slac-pub-7591.pdf` |
| [02](02_PEP_II_Power_Supply_Presentation_Analysis.md) | PEP-II Power Supply Presentation — Schematic & Design Analysis | `pepII supply.pptx` |
| [03](03_PS3413600102_Engineering_Drawing_Package.md) | PS-341-360-01-02 Engineering Drawing Package — Specification Reference | `ps3413600102.pdf` |
| [04](04_Original_Design_Consolidated_Specifications.md) | Consolidated Design Specifications — Cross-Referenced Master | All three documents |

## Relationship to Existing Documentation

These notes complement and provide traceable source material for:
- `Designs/4_HVPS_Engineering_Technical_Note.md` — System-level engineering reference
- `hvps/documentation/schematics/technical_notes/` — Circuit board-level analysis
- `hvps/controls/enerpro/technical-notes/` — Enerpro SCR controller notes
- `hvps/documentation/plc/technical-notes/` — PLC control system notes
- `hvps/architecture/designNotes/` — Design working notes (DOCX)

## Key Design Heritage

The SPEAR3 HVPS was originally designed as the **PEP-II klystron power supply** at SLAC in the mid-1990s by R. Cassel and M.N. Nguyen. The design was later adapted for SPEAR3 RF system use. Understanding the original PEP-II design intent, specifications, and unique features is critical for maintaining and upgrading the current SPEAR3 system.

