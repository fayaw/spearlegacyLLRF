# HVPS Technical Notes and Documentation

This directory contains comprehensive technical documentation for the SPEAR3 High Voltage Power Supply (HVPS) system, extracted from circuit schematics and engineering analyses. All documentation is now in Markdown format with enhanced circuit diagrams and visual representations.

## 📋 Document Index

### 🎯 Master Overview Document
- **[00_HVPS_SYSTEM_OVERVIEW.md](00_HVPS_SYSTEM_OVERVIEW.md)** - Complete system design overview covering all aspects of the HVPS from system architecture to individual circuit boards

### 📊 Detailed Technical Notes (Markdown)
Circuit-by-circuit technical analysis with Mermaid diagrams, component tables, and comprehensive documentation:

| File | Drawing | Description |
|------|---------|-------------|
| **[sd7307900101.md](sd7307900101.md)** | SD-730-790-01-C1 | **HVPS System Overview** — 12-pulse power conversion, 12.5KV→-77KV |
| **[sd7307900501.md](sd7307900501.md)** | SD-730-790-05-C1 | **Grounding Tank** — HV filter (350µHY, 30NFD), Danfysik sensing |
| **[sd2372301299.md](sd2372301299.md)** | SD-237-230-12 | **ENERPRO Firing Circuit** — Reference document (existing) |
| **[sd2372301401.md](sd2372301401.md)** | SD-237-230-14-C1 | **Voltage/Current Regulator** — INA117/MC34074/CD4044B control |
| **[sd7307930304.md](sd7307930304.md)** | SD-730-793-03-C4 | **SCR Driver Board** — CD4047B/CD4528, IXFH12N90, 50µS pulses |
| **[sd7307930402.md](sd7307930402.md)** | SD-730-793-04-C2 | **SCR Crowbar Driver** — Single-shot, MIC-4427 optical |
| **[sd7307930702.md](sd7307930702.md)** | SD-730-793-07-C2 | **Right Side Trigger Interconnect** — 6-phase control, arc detection |
| **[sd7307930801.md](sd7307930801.md)** | SD-730-793-08-C1 | **Left Side Trigger Interconnect** — Mirror board, 24V fault bus |
| **[sd7307931203.md](sd7307931203.md)** | SD-730-793-12-C3 | **Monitor Board** — NMH2415S, BUF634, 10kV/V & 5A/V outputs |
| **[sd7307931301.md](sd7307931301.md)** | SD-730-793-13-C1 | **HV Power Circuit Mod** — 6N-139 optocoupler variant |
| **[sd7307940400.md](sd7307940400.md)** | SD-730-794-04-C0 | **SCR Crowbar Trigger** — IRFDP120, ferrite filtering, +15V |

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
