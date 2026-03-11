# SPEAR RF Klystron HVPS — PLC Technical Notes

## Overview

These technical notes document the PLC control system for the **SPEAR RF Klystron High Voltage Power Supply (HVPS)** at SSRL (Stanford Synchrotron Radiation Lightsource). The system uses an **Allen-Bradley SLC 500** processor programmed in RSLogix 500 ladder logic (program identifier: **SSRLV6-4-05-10**).

The PLC manages all aspects of the HVPS including power sequencing, voltage/current regulation, crowbar protection, transformer interlocks, emergency shutdown, and communication with the EPICS control system via a VXI crate.

---

## Technical Notes Index

| # | Document | Description |
|---|----------|-------------|
| 01 | [System Overview](01-system-overview.md) | High-level architecture, hardware modules, and system block diagram |
| 02 | [Hardware & I/O Configuration](02-hardware-io-configuration.md) | I/O module slots, binary inputs/outputs, analog channels |
| 03 | [Symbol Database Reference](03-symbol-database-reference.md) | Complete PLC address-to-symbol mapping |
| 04 | [Ladder Logic Analysis](04-ladder-logic-analysis.md) | Detailed rung-by-rung analysis of the 120-rung main program |
| 05 | [Control Algorithms — N7:10 & N7:11](05-control-algorithms.md) | Voltage reference (N7:10), phase angle (N7:11), digital low-pass filter |
| 06 | [Safety & Interlock Systems](06-safety-interlock-systems.md) | Crowbar protection, transformer interlocks, emergency off, fault latching |
| 07 | [VXI/EPICS Communications](07-vxi-epics-communications.md) | DCM module interface, EPICS PV mappings, status bit definitions |
| 08 | [Analog Registers & Calibration](08-analog-registers-calibration.md) | N7 register map, scaling multipliers, measurement data |
| 09 | [Binary Bit Register Reference](09-binary-bit-registers.md) | Detailed B3:0–B3:5 bit maps with labels and rung cross-references |

---

## Source Documents

These notes were derived from the following source documents in `hvps/documentation/plc/`:

| File | Type | Description |
|------|------|-------------|
| `CasselPLCCode.pdf` | PDF (47 pp) | Full ladder logic listing — portrait orientation |
| `Cassel_land.pdf` | PDF (47 pp) | Full ladder logic listing — landscape orientation (identical content to CasselPLCCode.pdf) |
| `CasselSymbolDatabase.pdf` | PDF (8 pp) | Complete address/symbol database |
| `PLC software discusion 1.docx` | DOCX | Walkthrough of N7:10 & N7:11 signal flow and ladder logic instruction set |
| `plcNotesR1.docx` | DOCX | Technical analysis of timing, digital filter, rung-by-rung analysis |
| `hvpsPlcLabels.xlsx` | XLSX | Label database: binary I/O, bit registers, analog registers, EPICS interface |
| `hvpsMeasurements20220314.xlsx` | XLSX | Regulator test-point measurements (March 14, 2022) |

> **Note:** `CasselPLCCode.pdf` and `Cassel_land.pdf` contain identical content in different page orientations (portrait vs. landscape).

---

## System Identification

- **Program Name:** SSRLV6-4-05-10
- **Processor:** Allen-Bradley SLC 500
- **Programming Software:** RSLogix 500
- **Program Date:** Wednesday, June 23, 2021
- **Program Size:** ~5.5 kB (estimated scan time ~5 ms/cycle)
- **Main Ladder File:** LAD 2 — 120 rungs, 5557 bytes
- **Subroutines:**
  - COPY (LAD 3) — 6 rungs, 108 bytes — I/O to B3 copy
  - SCALE (LAD 4) — 5 rungs, 159 bytes — Value scaling

