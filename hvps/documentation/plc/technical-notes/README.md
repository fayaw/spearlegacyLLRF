# SPEAR RF Klystron HVPS — PLC Technical Notes

## Overview

These technical notes document the PLC control system for the **SPEAR RF Klystron High Voltage Power Supply (HVPS)** at SSRL (Stanford Synchrotron Radiation Lightsource). The system uses an **Allen-Bradley SLC 500** processor programmed in RSLogix 500 ladder logic (program identifier: **SSRLV6-4-05-10**).

The PLC manages all aspects of the HVPS including power sequencing, voltage/current regulation, crowbar protection, transformer interlocks, emergency shutdown, and communication with the EPICS control system via a VXI crate.

> ## ⚠ Verification status — PARTIALLY VERIFIED (revised 28 September 2026)
>
> **The earlier claim that this note set "passed without correction" was too strong and has been withdrawn.** The September 2026 audit checked *structure* — slot map, rung numbers, register assignments, thermocouple channel mapping, interlock logic — all against `CasselPLCCode.pdf`, and all of it held up. What it did **not** check was the *function name attached to each individual I/O bit*, because those names cannot be derived from the ladder listing alone. A follow-up pass on 28 September 2026 compared them against the master wiring diagram `wd7307900206.pdf` (WD-730-790-02-C6) and found several wrong in [02](02-hardware-io-configuration.md) — including two bits that carry no ladder reference and no symbol at all, and one input described as an output. See the correction list at the top of that note.
>
> **Lesson.** Being written from a machine-readable source made the *structural* content of these notes reliable, but it also meant the per-point names were filled in from inference rather than from the drawing, which is image-only. Machine-readability predicts which claims were checked, not which claims are true.
>
> **How the structural check was done.** `CasselPLCCode.pdf` is machine-readable, so an independent rung index was built directly from the listing (program **SSRLV6-4-05-10**, printed Wednesday 23 June 2021; LAD 2 = 120 rungs / 5557 bytes, LAD 3 "COPY" = 6 rungs / 108 bytes, LAD 4 "SCALE" = 5 rungs / 159 bytes) and every checkable claim in these notes was compared against it. The slot map, rung numbers, register assignments, thermocouple channel mapping and interlock logic all matched, and that result still stands.
>
> Independently, the derived control-loop analysis in [05](05-control-algorithms.md) was cross-checked against J. Sebek's original `plcNotesR1.docx`. The two agree exactly, including the derived filter time constant:
>
> $$\tau = \frac{-T}{\ln(1-\alpha)} = \frac{-0.08}{\ln 0.9} = 0.759\ \text{s}$$
>
> with α = 0.1 and T = 80 ms. Sebek's document also confirms that **N7:10 is the "Reference Out" register loaded into output 0 of the AB-1746-NIO4V in slot 8, and is connected to EL1, the reference input to the regulator card** — which in turn is confirmed from the regulator side by `EnerproVoltageandCurrentRegulatorBoardNotes.docx` (the reference enters at J4-1/J4-7, and the schematic's "POS. VOLTAGE LIMIT COMMAND" label for that pin is a misnomer). The analog chain in [02](02-hardware-io-configuration.md) was re-confirmed rung by rung on 28 September 2026 (rungs 76, 78, 80, 81, 82, 88, 112, 113) and is correct.
>
> **Still unchecked**: the `O:1` DCM status-bit table in [02](02-hardware-io-configuration.md) beyond three spot-checked rows. Notes [04](04-ladder-logic-analysis.md), [06](06-safety-interlock-systems.md) and [09](09-binary-bit-registers.md) repeated the same per-bit names and were swept against the corrected [02](02-hardware-io-configuration.md) on 28 September 2026; each now carries its own correction header. Notes [07](07-vxi-epics-communications.md) and [08](08-analog-registers-calibration.md) reference only DCM registers, N7 registers and analog channels — no discrete-input names — and were checked to need no change.
>
> **Internal contradictions that should have caught this earlier.** Two were found by comparing the notes against each other rather than against a source:
>
> - [02](02-hardware-io-configuration.md) called `I:2/1` "A Phase Reference Voltage" while [04](04-ladder-logic-analysis.md) correctly read rungs 38 and 39 as `I:2/1 → 12kV On` / `12kV Off`.
> - [04](04-ladder-logic-analysis.md) described rungs 0071/0072 with the wrong input conditions and with the `B3:5` SCR status bits swapped, while [02](02-hardware-io-configuration.md), [07](07-vxi-epics-communications.md) and [09](09-binary-bit-registers.md) all had them right. Three notes against one, and the odd one out was wrong.
>
> Both disagreements sat in the same directory through the whole September audit. Cross-checking the notes against each other is cheap, needs no drawings, and would have flagged both.

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

