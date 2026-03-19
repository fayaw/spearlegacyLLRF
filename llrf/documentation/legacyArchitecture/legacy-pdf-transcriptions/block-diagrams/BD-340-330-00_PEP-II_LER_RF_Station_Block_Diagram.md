# PEP-II LER RF Station — Block Diagram

| Field | Value |
|-------|-------|
| **Document Number** | BD-340-330-00-R0 |
| **Title** | PEP-II LER RF Station — Block Diagram |
| **Author** | P. Corredoura, 1/28/99 |
| **Organization** | Stanford Linear Accelerator Center, U.S. Department of Energy |
| **Date** | January 28, 1999 |
| **Pages** | 1 |
| **Source PDF** | `bd3403300000.pdf` |
| **Drawing Standard** | ASME Y14.5M-1994 |

---

## Description

This is a comprehensive block diagram of a complete PEP-II Low Energy Ring (LER) RF station showing the interconnection of all major components from the control system through the klystron to the beam cavities.

## Key Components Identified (from OCR)

### Control System
- **Allen Bradley PLC-5 processor** — process logic control
  - Analog output: 64 channels
  - Analog input: 32 channels
  - Thermocouple input: 122 channels
- **Fiber optic links** — fiber receiver, LED signals
- **Allen Bradley control hardware** — remote I/O

### RF Chain
- **476 MHz** input signal
- **RF MODULATOR** / **AMPLIFIER** — drive chain
- **KLYSTRON** — 1.2 MW max output
- **CIRCULATOR** — klystron protection from reflected power
- **LOAD** — high power termination
- **Magic-Tee** power splitters

### Cavity Systems
- **Cavity 1** and **Cavity 2** (station LR44)
- Cavity probe, sampling loop
- Stepping motor controllers — tuner control

### Low-Level RF (VXI Crate)
- **VXI crate** — SIC-300 system
- **Tuner controls**
- **Windows** — Windows-based control workstation
- **EPICS** control system interface
- **Longitudinal feedback** — fiber optic link
- **476 MHz tuner motor controller** — translator to stepper motors and limit switches (×2)

### Interlocks and Safety
- PPS (Personnel Protection System)
- HVPS beam abort
- Emergency off, +24V hardwired
- High voltage trigger control — fiber optic
- Crowbar protection
- Air pressure monitoring
- Water delta temperature monitoring

### Support Systems
- Primary air source, secondary air source
- HVPS (High Voltage Power Supply)
- Focus supply #1 and #2 (voltage and current)
- Filament supply (voltage, current, on/current limit, full current)
- Water cooling (local panel high P sensor)

### Monitoring
- EPICS workstation (ethernet)
- Serial link — GPIB translator
- ASCII terminal monitor
- Power supply monitoring

---

## Title Block

| Field | Value |
|-------|-------|
| Drawing | BD-340-330-00 R0 |
| Title | PEP2 LER RF STATION — BLOCK DIAGRAM |
| Designed by | Paul Corredoura |
| Approved by | Paul Corredoura |
| Status | Draft |
| Scale | Do Not Scale Drawing |

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `bd3403300000.pdf`. This is a single-page engineering block diagram; OCR text extraction from complex signal flow diagrams has limited reliability. The component list above identifies elements recognizable from OCR output. **The original PDF should be consulted for accurate signal routing, connections, and component labels.**

