# HVPS Technical Notes and Documentation

This directory contains comprehensive technical documentation for the SPEAR3 High Voltage Power Supply (HVPS) system, extracted from circuit schematics and engineering analyses.

## 📋 Document Index

### 🎯 Master Overview Document
- **[00_HVPS_SYSTEM_OVERVIEW.md](00_HVPS_SYSTEM_OVERVIEW.md)** - Complete system design overview covering all aspects of the HVPS from system architecture to individual circuit boards

### 📊 Detailed Technical Notes (DOCX)
Circuit-by-circuit technical extraction notes with complete BOMs, functional descriptions, and AI replication checklists:

| File | Drawing | Description |
|------|---------|-------------|
| **[sd7307900101.docx](sd7307900101.docx)** | SD-730-790-01-C1 | **HVPS System Overview** — 12-pulse power conversion, 12.5KV→-77KV |
| **[sd7307900501.docx](sd7307900501.docx)** | SD-730-790-05-C1 | **Grounding Tank** — HV filter (350µHY, 30NFD), Danfysik sensing |
| **[sd2372301299.docx](sd2372301299.docx)** | SD-237-230-12 | **ENERPRO Firing Circuit** — Reference document (existing) |
| **[sd2372301401.docx](sd2372301401.docx)** | SD-237-230-14-C1 | **Voltage/Current Regulator** — INA117/MC34074/CD4044B control |
| **[sd7307930304.docx](sd7307930304.docx)** | SD-730-793-03-C4 | **SCR Driver Board** — CD4047B/CD4528, IXFH12N90, 50µS pulses |
| **[sd7307930402.docx](sd7307930402.docx)** | SD-730-793-04-C2 | **SCR Crowbar Driver** — Single-shot, MIC-4427 optical |
| **[sd7307930702.docx](sd7307930702.docx)** | SD-730-793-07-C2 | **Right Side Trigger Interconnect** — 6-phase control, arc detection |
| **[sd7307930801.docx](sd7307930801.docx)** | SD-730-793-08-C1 | **Left Side Trigger Interconnect** — Mirror board, 24V fault bus |
| **[sd7307931203.docx](sd7307931203.docx)** | SD-730-793-12-C3 | **Monitor Board** — NMH2415S, BUF634, 10kV/V & 5A/V outputs |
| **[sd7307931301.docx](sd7307931301.docx)** | SD-730-793-13-C1 | **HV Power Circuit Mod** — 6N-139 optocoupler variant |
| **[sd7307940400.docx](sd7307940400.docx)** | SD-730-794-04-C0 | **SCR Crowbar Trigger** — IRFDP120, ferrite filtering, +15V |

### 📝 Supporting Analysis Documents (Markdown)
- **[SD-7307900101_HVPS_System_Schematic_Analysis.md](SD-7307900101_HVPS_System_Schematic_Analysis.md)** - System-level schematic analysis
- **[SD-237-230-14_Regulator_Board_Analysis.md](SD-237-230-14_Regulator_Board_Analysis.md)** - Regulator board detailed analysis

## 🏗️ System Architecture Summary

The SPEAR3 HVPS is a **2MW, 12-pulse thyristor-controlled rectifier** system that converts 12.5KV 3-phase AC to -77KV DC at 27A for klystron operation.

### Key Subsystems:
1. **Power Conversion**: Phase-shift transformer → SCR rectifiers → HV filter
2. **Control & Regulation**: Master regulator board with precision op-amps and optocoupler isolation
3. **Protection**: Multi-layer protection including crowbar, arc detection, and PPS interlocks
4. **Monitoring**: Dual-isolated precision measurement with fiber-optic status communication

### Technology Highlights:
- **12-Pulse Configuration**: Eliminates 5th/7th harmonics, 720Hz ripple frequency
- **Precision Control**: INA117/MC34074 op-amps, 4N32 optocoupler isolation
- **Fast Protection**: <10µS crowbar response, P3KE7 TVS arc protection
- **Distributed Control**: 10+ specialized circuit boards with coordinated operation

## 🔧 Document Structure

Each DOCX technical note follows a consistent structure:
1. **Document Identification** — Drawing numbers, revisions, engineers
2. **System Overview** — High-level function description
3. **Complete Bill of Materials** — Organized by component type
4. **Connector Pinouts** — Pin-by-pin signal assignments
5. **Functional Circuit Descriptions** — Detailed block-by-block analysis
6. **Signal Net Lists** — All named signals and connections
7. **Power Distribution** — Voltage rails and power flow
8. **Design Notes** — Key parameters and design rationale
9. **AI Replication Checklist** — Critical parameters for design reconstruction

## 🎯 Usage Guidelines

### For System Understanding:
1. Start with **00_HVPS_SYSTEM_OVERVIEW.md** for complete system context
2. Review individual DOCX files for detailed circuit analysis
3. Cross-reference with supporting markdown analyses

### For Design Replication:
1. Use the **AI Replication Checklists** in each DOCX for critical parameters
2. Reference **Component Technology Analysis** section for modern equivalents
3. Follow **Signal Flow and Interconnections** for system integration

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

- **All PDFs are image-only** (scanned schematics) - text extracted via OCR
- **Component values verified** through cross-referencing multiple sources
- **Confidence level: High** for system-level understanding and component identification
- **Recommended review**: Annual review for component availability and system performance

---

**Last Updated**: March 2026  
**Document Count**: 13 technical notes + 1 system overview  
**Coverage**: Complete HVPS system from power conversion to individual circuit boards
