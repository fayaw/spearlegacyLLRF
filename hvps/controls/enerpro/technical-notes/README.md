# Enerpro SCR Firing Board Technical Documentation

> Comprehensive technical notes extracted from all PDF documentation in `hvps/controls/enerpro/enerproDocuments/`

## Document Inventory

| Document | Pages | Size | Content Type | Key Information |
|----------|-------|------|--------------|-----------------|
| **OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.pdf** | 16 | 1.01 MB | Complete operating manual | 12-pulse firing board operation, Rev. C (June 2020) |
| **OP-0102_FCOG6100_Op_Manual.pdf** | 10 | 192 KB | Operating manual | 6-pulse firing board operation, Rev. B (May 2018) |
| **FCOG1200 Brochure.pdf** | 4 | 2.46 MB | Product brochure | Marketing material and product overview |
| **PD720_FCOG6100_Prod_Gd_07-2017.pdf** | 2 | 126 KB | Product guide | FCOG6100 specifications and features |
| **E640_L FCOG1200 Schematic (03-01-21).pdf** | 2 | 180 KB | Latest schematic | Revision L (2021) - most current design |
| **E640_K FCOG1200 Schematic (09-30-09).pdf** | 2 | 119 KB | Schematic | Revision K (2009) - stability improvements |
| **E640_F FCOG1200 Schematic (08-13-96).pdf** | 2 | 71 KB | Schematic | Revision F (1996) - auto-balance introduction |
| **E128_R_Schematic_11-14.pdf** | 2 | 79 KB | Gate drive schematic | Gate drive circuit details |
| **FCOG1200 Auto Balance.pdf** | 3 | 15 KB | Application note | Auto-balance circuit configuration |
| **Closing the Loop.pdf** | 1 | 126 KB | PCIM 1999 article | 12-pulse conversion benefits |
| **bourbeauIEEE1983_04504257.pdf** | 8 | 4.36 MB | IEEE paper | LSI-based thyristor firing circuit theory |
| **PHASE CONTROL THEORY.PDF** | 11 | 1.02 MB | Theory diagrams | Phase control principles (diagrams only) |

## Product Families

### FCOG1200 — 12-Pulse Firing Board
- **Application**: 12-pulse DC converters and AC controllers
- **Output**: 12 isolated SCR gate pulses (30° spacing)
- **Key Feature**: Eliminates 5th and 7th harmonics
- **Revisions**: F (1996) → K (2009) → L (2021)
- **ASIC**: Dual custom 24-pin ASICs (U3, U4)

### FCOG6100 — 6-Pulse Firing Board  
- **Application**: 6-pulse SCR controllers and converters
- **Output**: 6 isolated SCR gate pulses (60° spacing)
- **Key Feature**: Single ASIC-based design
- **Revision**: R (documented)
- **ASIC**: Single custom 24-pin ASIC

## Technical Notes Structure

| Note | Title | Content Coverage |
|------|-------|------------------|
| [01-product-overview.md](01-product-overview.md) | Product Overview & Evolution | Product families, timeline, key features, applications |
| [02-hardware-specifications.md](02-hardware-specifications.md) | Hardware Specifications | Complete specs, connectors, power requirements, I/O |
| [03-control-signal-interface.md](03-control-signal-interface.md) | Control Signal Interface | SIG HI command, phase references, test points |
| [04-circuit-analysis.md](04-circuit-analysis.md) | Circuit Analysis & Schematics | Schematic evolution, component analysis, design changes |
| [05-operating-procedures.md](05-operating-procedures.md) | Operating Procedures | Setup, commissioning, frequency selection, configuration |
| [06-control-theory.md](06-control-theory.md) | Control Theory & Algorithms | Phase-locked loop theory, thyristor firing principles |
| [07-auto-balance-system.md](07-auto-balance-system.md) | Auto-Balance System | On-board and external auto-balance operation |
| [08-troubleshooting-reference.md](08-troubleshooting-reference.md) | Troubleshooting & Maintenance | Test points, waveforms, diagnostic procedures |

## System Integration

These Enerpro SCR firing boards are used in the SPEAR RF Klystron HVPS system to control the thyristor (SCR) firing angles for voltage regulation. The boards interface with:

- **PLC Control System**: Receives SIG HI command signals from the Allen-Bradley SLC 500 PLC
- **Phase Reference Inputs**: Connected to transformer secondary voltages for synchronization  
- **SCR Gate Drives**: Provides isolated gate firing pulses to thyristor bridges
- **Protection Systems**: Integrates with phase loss detection and crowbar protection

## Key Technical Specifications

| Parameter | FCOG1200 | FCOG6100 |
|-----------|----------|----------|
| **Gate Pulses** | 12 (30° spacing) | 6 (60° spacing) |
| **Phase Shift** | Programmable (0° or 30°) | Programmable |
| **Control Input** | 0.9-5.9V or 4-20mA | Voltage or Current |
| **Power Supply** | 24VAC, 24VA | 24VAC |
| **Output Voltages** | ±30V, ±12V, ±5V | ±30V, ±12V, ±5V |
| **ASIC-based** | Yes (dual U3, U4) | Yes (single ASIC) |
| **Phase Loss Detection** | Yes | Yes |
| **Auto-balance** | Optional (3 methods) | Not documented |
| **Frequency Range** | 50/60Hz selectable | 50/60Hz |

## Source Documents Location

All source PDFs are located in: `hvps/controls/enerpro/enerproDocuments/`

## Related Documentation

- [PLC Technical Notes](../../documentation/plc/technical-notes/README.md) — Allen-Bradley SLC 500 PLC control system
- [HVPS System Overview](../../README.md) — Complete HVPS system documentation

---

*Technical notes compiled from Enerpro documentation dated 1983-2021*

