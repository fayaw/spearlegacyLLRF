# RF Non-Ionizing Radiation Safety Procedure

| Field | Value |
|-------|-------|
| **Document Number** | PS-340-330-61-R2 |
| **Title** | RF Non-Ionizing Radiation Safety Procedure |
| **Author** | H.S. (Heinz Schwarz) & J.J., 4/19/99 |
| **Submitted by** | Heinz Schwarz, RF Engineer |
| **Approved by** | Alan Hill, Area Manager |
| **Organization** | Stanford Linear Accelerator Center |
| **Date** | July 21, 1999 (R2 revision: 4/19/99) |
| **Pages** | 13 |
| **Source PDF** | `ps3403306102.pdf` |

---

## RF Non-Ionizing Radiation Safety Procedure

### 1) Background

The PEP-II RF system operates at **476 MHz**. This microwave frequency presents a potential non-ionizing radiation hazard wherever high power RF energy is transported through the waveguide network. The primary concern is leakage at waveguide joints and connections.

### 2) Applicability

This procedure applies to all PEP-II RF stations in both the High Energy Ring (HER) and Low Energy Ring (LER).

### 3) Radiation Limits

- Maximum allowable RF radiation level at 100 kW: **0.1 mW/cm²** at any accessible waveguide joint
- Maximum allowable RF radiation level at full power (1.2 MW): **1.5 mW/cm²**
- Ionizing radiation limit at klystron surface: **< 5 mR/hr** at 30 cm distance
- Ionizing radiation limit on contact: **< 100 mR/hr**

### 4) Responsibilities

The RF Group is responsible for ensuring compliance with non-ionizing radiation safety requirements. RP Field Operations Group provides support for ionizing radiation surveys.

### 5) Cables and Connections

All RF cables and connections shall be properly secured before any RF operation. The standard RF coax cables used in the system (1/4 inch Heliax and SMA pigtails) should be checked to verify that they are present and that the cables should not be disconnected while power is on.

### 6) Assembly and Installation

During assembly and installation of the waveguide components all flange bolts shall be torqued to **30 ft-lbs** and all field assembled waveguide joints shall be tested by pressurization to **0.25 psig** and checked for bubbles with "Snoop".

After installation, the inspector shall measure the torque on a minimum of **six bolts chosen at random** on each flange. If the torque exceeds **25 ft-lbs** the flange passes inspection, if not all the bolts on the flange are to be re-torqued to 30 ft-lbs.

### 7) RF Field Survey

After the requirements for bolt torquing and gas leak checking are satisfied, a check for RF leakage around each accessible flange using a calibrated RF field meter shall be made with the klystron output at about **100 kW**. The RF leakage shall nowhere exceed the prorated allowable limit of **0.1 mW/cm²** at 100 kW.

The coax connectors at the klystron drive amplifier, at the directional coupler and at the input to the klystron will also be surveyed for leakage at this time.

### 8) Gas Pressurization System

Each waveguide network will be pressurized with regulated **0.25 psig** instrument air which has been processed through an air drier. Since the volumetric supply rate is limited, a leak in the waveguide will cause a drop in pressure, actuation of a pressure switch and shut down of the RF station together with a beam abort.

After a leak is repaired a radiation measurement with the klystron operating at about a 100 kW power level is to be performed to check if the repair was successful. When the 0.25 psig pressure in the waveguide is restored and the RF radiation survey shows no leakage above 0.1 mW/cm² normal ring operation may resume.

Pressurization mainly guards against operation with a missing piece of waveguide or an improperly assembled flange joint. Proper torquing of all flanges to 30 ft-lbs is a necessity to prevent RF leakage at the waveguide flanges.

### 9) Klystron Removal

Before a klystron can be removed from the waveguide network the high voltage power supply has to be locked off using proper **LOCK-AND-TAG** procedures to prevent exposure to high voltage and accidental operation of the klystron.

If a klystron is to remain disconnected from the waveguide network it is required to bolt a cover over the open end of the waveguide. The cover will be properly torqued and inspected and the waveguide pressurized before any RF systems can be operated and a beam stored in the respective PEP ring.

### 10) Re-certification Annually and After Major Repair or Downtime

RF radiation surveys shall be performed on all stations at least **once per year** and are the responsibility of the RF Group.

After each opening of a waveguide network or major downtime of the machine an inspection of the systems checking completeness and readiness for turn-on shall be performed including a RF radiation survey at 100 kW klystron power.

A RF radiation survey shall also be performed on all stations at full beam current to verify compliance with beam induced power at higher frequencies.

### 11) Waveguide Pressure Interlock Check

Verification of waveguide pressure interlocks shall be performed on all stations at least **once per year** or after a major downtime. Proceed as follows:

Locate the waveguide pressure switches below the circulator loads. There are two sets of switches and one pressure gauge for each of the two zones. Locate the input air Tee to switches (see diagram below).

```
         Pressure Gauge
              |
          (A)   (B)
              |
           O--- Input Tee
```

With a wrench, loosen the compression fitting on the 3/8 copper tubing supply to the Tee. Gently pull the tubing out of the compression fitting socket while watching the pressure gauge. Carefully dip the gauge pressure down to **3 inches**. Verify Local Panel Waveguide Pressure LED has tripped to Red. Verify on the EPICS Panel (WAVEGUIDE) that both the Local Pressure Switch has tripped and the NIRP Output for that station has tripped. Hit Reset and repeat as necessary. When satisfied re-connect and re-tighten air supply.

---

## Page 8: Typical Cross-Sectional Layout of RF Station

*[Diagram showing cross-sectional view of RF station including:]*
- Circulator
- High Voltage Power Supply
- RF Surface Building (16' × 12' door)
- Low-level RF and Control Racks
- LCW (Low-Conductivity Water)
- HCW (High-Conductivity Water)
- Water Rack
- Magic-Tee, 1.2 MW Loads
- Penetration to tunnel
- Cavities (LER and HER)

> *This diagram is identical to the one in PS-340-330-51 page 7.*

---

## Page 9: RF Station Layout Drawing

*[Detailed engineering layout drawing — refer to original PDF]*

---

## 12) Waveguide Safety Work Control Procedure

For purposes of working on the PEP-II waveguide system a **Waveguide Safety Work Control Form (WSWCF)** has been generated. There are two general occasions for usage:

### I. Waveguide Component Work (No RF Power Required)

For any waveguide component removal, repair, klystron/circulator repair or removal. This requires **PEP-II Bend Magnet Chopper Supplies in Region 8 (Building 685) to be Locked Off**. This prevents stored beam from inducing RF in the cavities that could propagate up the waveguide.

After component(s) has been removed and waveguide system shorting plates installed; if necessary, the waveguide air pressure system will make-up and PEP-II Bend Magnet Chopper Supplies can be released — Lock & Tags removed.

**Procedure:**

1. Prepare Waveguide Safety Work Control Form for ADSO office (MCC).
2. PEP-II Bend Magnet Chopper Supplies in Region 8 (Building 685) Locked Off by Person Responsible and people performing work — Lock & Tag. PEP-II Area Manager or EOIC after hours will Lock Off Bend Supplies first. See Figure 1.
   - **LER Ring:** Lock Off (+) and (−) Feeder Rectifier Supplies.
   - **HER Ring:** Lock Off (+) and (−) Feeder Rectifier Supplies.
3. Waveguide Safety Work Control Form Signatures Required:
   - Person Responsible (Engineer, RF Group)
   - Area Manager (PEP-II Area or PEP-II RF Area)
   - ADSO
4. Lock and Tag RF station HVPS off.
5. Requirements After Completing Work: W.G Pressure Relay Test. See section 11 of PS-340-330-61-R0. Close out WSWCF in ADSO office.

There are no sign-offs necessary for RHP, PPS Bypass in this situation.

### II. Station Commissioning / Full Power Testing (RF Power Required)

For station commissioning or testing HVPS, klystron, or circulator that requires klystron full power without RF cavities. This requires installing a waveguide shorting plate on the circulator output. To run the station requires **HVPS PPS Bypass** and sign-off by RHP. This requires a **Radiation Safety Work Control Form (RSWCF)**.

**Procedure:**

1. Prepare Waveguide Safety Work Control Form and Radiation Safety Work Control Form for ADSO office.
2. PEP-II Bend Magnet Chopper Supplies in Region 8 (Building 685) Locked Off by Person Responsible and people performing work — Lock & Tag. PEP-II Area Manager or EOIC after hours will Lock Off Bend Supplies first. See Figure 1.
   - **LER Ring:** Lock Off (+) and (−) Supplies.
   - **HER Ring:** Lock Off (+) and (−) Supplies.
3. RHP or ADSO padlocks waveguide shorts in place and signs off Radiation Safety Work Control Form for HVPS PPS Bypass.
4. Have HVPS PPS system bypassed for station.
5. *(Step 5 not present in original)*
6. Radiation Safety Work Control Form Signatures Required:
   - Person Responsible (Engineer, RF Group)
   - Area Manager (PEP-II Area or PEP-II RF Area)
   - ADSO
   - RHP
   - PPS
7. Remove waveguide bellows after circulator and install two waveguide shorting plates — one on each side of opening. Install waveguide short locking covers.
8. Requirements After Completing Work: W.G Pressure Relay Test. See section 11 of PS-340-330-61-R0. Close out WSWCF and RSWCF in ADSO office.

---

## Page 12: Figure 1 — Feeder Rectifier Location

Located in Building 685 (Region 8 RF Support Building), adjacent to Rack # B685-08CM25.

- **Feeder Rectifier** — Lock Off (+) and (−) Supplies (LER Ring)
- **Feeder Rectifier** — Lock Off (+) and (−) Supplies (HER Ring)

*[Photograph/diagram of the feeder rectifier lock-off location — refer to original PDF]*

---

## Page 13: PEP-II RF Waveguide Safety Work Control Form

### Accelerator Department — PEP-II RF Waveguide Safety Work Control Form

| Field | Entry |
|-------|-------|
| Area | ____ |
| Form # | ____ |
| Date | ____ |

**Section 1: Description of Work to be Done** (include item or CATER number, job title, etc.)

☐ Repair or Replace ☐ Install ☐ Remove ☐ Reinstall ☐ Bypass ☐ Unbypass

*EXAMPLE*

| Role | Signature/Date |
|------|---------------|
| Person Responsible (RF Engineer) | ____ |
| Area Manager (RF Area Mngr. or PEP-II Area Mngr.) | ____ |

**Section 2a: Requirements Before Starting Work** (ADSO completes this section)

**Section 2b: Requirements After Completing Work** (ADSO checks required boxes)

☐ W.G. Pressure Relay Test ☐ Operations ☐ Other (describe)

| Role | Signature/Date |
|------|---------------|
| ADSO | ____ |

**Section 3: Signoffs Indicating Requirements are Complete** (ADSO checks required boxes)

| Item | Signature/Date |
|------|---------------|
| ☐ Requirements Before Starting Work Completed (See Section 2a) | ____ |
| ☐ Removed or Bypassed (Operations, or Person Responsible) | ____ |
| ☐ Reinstalled or Unbypassed (Operations, or Person Responsible) | ____ |
| ☐ Work complete (Person Responsible or Area Manager) | ____ |
| ☐ Operations | ____ |
| ☐ Other | ____ |

**Section 4: Signoff indicating Readiness for Beam to:**

| Role | Signature/Date |
|------|---------------|
| ADSO | ____ |
| EOIC | ____ |

---

> **Transcription Note**: This markdown was generated via OCR (Tesseract 5.3.0 at 300 DPI) from the scanned image-based PDF `ps3403306102.pdf` (13 pages). Text content on pages 1–7 and 10–13 is high confidence. Pages 8–9 contain facility layout diagrams with limited extractable text; the original PDF should be consulted for these pages. This is revision R2 of the original document.

