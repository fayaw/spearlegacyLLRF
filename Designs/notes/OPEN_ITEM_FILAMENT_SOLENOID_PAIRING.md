# Open Item: Which Request Line FILAMENT_ON and SOLENOID_ON Reach

- **Status**: Resolved 9 November 2026 as **case A** (Section 5): the fiber cable is straight and
  WD-340-330-29 has its two labels at the Fast IC end swapped. The repository copy of the drawing
  carries a note (F. Wang). The Doc M baseline test I0-T1 still confirms the pairing on the hardware.
- **Was tracked as**: Doc C O4 and Doc M O3 (pairing clauses removed on resolution); numbered
  O5 and O4 until the renumbering of 10 November 2026.
- **Needed before**: the Interface Chassis board design (I2).
- **Prepared by**: F. Wang, 8 November 2026.
- **Basis**: the drawings, the decoded RF MPS PLC-5 program and the legacy EPICS sources listed in
  Section 9.

---

## 1. The Question

Two VXI commands, FILAMENT_ON and SOLENOID_ON, travel from the AIM through the Fast Interlock
Chassis, two fibers and the RF Local Display Panel to two 24 V request lines that the panel sends
to the PLC-5 through cross-connect X530:

| Panel line | Panel schematic name | Cross-connect label (WD-340-330-02) | PLC-5 input (WD-340-330-23) | What the PLC-5 does with it |
| --- | --- | --- | --- | --- |
| J2-21 | FILAMENT_REQ24 | Filament PS On/Off | I:031/1, FIL ON/OFF | Starts the filament warm-up, switches the heater on (FILAMENT_ON, O:031/3) and enables the main-focus and bucking-coil supply outputs |
| J2-18 | SOLENOID_REQ24 | Online/Offline Request | I:031/3, KLY FOCUSING | Combined (AND) with the online key switch (I:031/7, from J2-25) into the station-online bit; while that bit is clear, the klystron and interlock groups are bypassed in the global interlock sum |

**Which J15 command pin drives which of these two lines today?**

## 2. Why It Matters

- The Interface Chassis replaces both the Fast Interlock Chassis and the panel at I2. The fibers
  between them disappear: the chassis takes the AIM cable on J15 and drives J2 directly, so it must
  reproduce today's pairing of J15 pin and J2 line.
- If the chassis gets it wrong, the two EPICS commands swap their effects from I2 to I7: the
  station online/offline command would switch the filament, and the filament command would only
  change the station-online bit. A filament dropped by mistake costs a full warm-up (2100 s).
- From I8 the chassis IOC issues the commands by function (Doc C IC-27), so the question concerns
  only the J15 period, I2 to I7.

## 3. The Chain, Step by Step

Each column follows the signal that starts as that command in EPICS.

| Step | From → to | FILAMENT command | SOLENOID command | Source | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | EPICS record → AIM register bit | `SRF1:STN:AIM:FILAMENT` → bit 2 | `SRF1:STN:AIM:SOLENOID` → bit 0 | aim.db, devP2RfAim.c, p2RfAimDef.h | Documented |
| 2 | AIM register bit → AIM output net | FILAMENT_ON (FPGA pin 71) | SOLENOID_ON (FPGA pin 70) | AIM FPGA XCS40XL, loaded from PROM XC18V512 (SD-340-309-01 pages 6-7) | Assumed from the names; FPGA design not in the workspace (Section 7.3) |
| 3 | AIM output net → AIM J3 | J3 pin 1 | J3 pin 14 | SD-340-309-01, page 18 (through an inverting buffer) | Documented |
| 4 | AIM J3 → Fast IC J15 | J15 pin 1 | J15 pin 14 | 25-pin cable; no drawing found | Assumed pin to pin |
| 5 | Fast IC J15 → fiber port | J45 | J46 | SD-340-308-02 pages 1-2 (inverter to J101 pins 25 and 27), SD-340-308-01 (transmitters U1, U2) | Documented |
| 6 | Fiber port → panel receiver | **U13** | **U14** | WD-340-330-29 | Documented; **crosses the names** likely on the right side |
| 7 | Panel receiver → J2 | U13 "solenoid on" → J2-18 | U14 "filament on" → J2-21 | SD-340-311-01 pages 1-2 (drivers OUT1, OUT2) | Documented |
| 8 | J2 → PLC-5 input | I:031/3 | I:031/1 | WD-340-330-02, -23; Doc M tab:plc5-panel | Documented by name; pin numbers disagree (Doc M O2, Doc C O5) |

Taken literally, the drawings give **J15 pin 1 (FILAMENT_ON) → J2-18 (station-online bit)** and
**J15 pin 14 (SOLENOID_ON) → J2-21 (filament)**. Every step keeps the names except step 6.

## 4. Evidence

### 4.1 For a crossed pairing

- WD-340-330-29 is the only drawing of the fiber cables themselves. It connects the Fast IC's
  FILAMENT fiber to U13 and its SOLENOID fiber to U14.

### 4.2 For a straight pairing

- **Panel schematic**: the panel's designer named receiver U13 "solenoid on" and U14 "filament on",
  that is, expected the SOLENOID fiber on U13.
- **PLC-5**: the input fed from J2-18, I:031/3, is tagged KLY_FOC_DI in the program and KLY
  FOCUSING on WD-340-330-23; the solenoid is the focusing coil. The input fed from J2-21, I:031/1,
  is FIL_ON_OFF.
- **Legacy software** (`rf_msgs.st`, S. Allison), which describes the whole chain from EPICS to the
  PLC-5:
  - Revision of 28 October 1999: "Replace solenoid on/off with station online/offline". The SOLENOID
    command has since been logged as the station going online or offline.
  - It prints "Filament OFF due to fault" when `SRF1:FILAMENT:ON:PLC` (the PLC-5's copy of the
    filament-request input I:031/1) drops while `SRF1:STN:AIM:FILAMENT` is on. It therefore expects
    the FILAMENT command to drive I:031/1.

### 4.3 What WD-340-330-29 agrees with

Its labels for the two receivers, U13 "station online request" and U14 "filament and focus
request", match what the PLC-5 does with J2-18 and J2-21. Only its labels at the Fast IC end,
FILAMENT on U13 and SOLENOID on U14, are crossed.

## 5. Possible Explanations

| Case | What is true | J15 pin 1 drives | Chassis wiring |
| --- | --- | --- | --- |
| A | The fiber cable is straight; WD-340-330-29 swaps its two labels at the Fast IC end | J2-21, filament | J15 pin 1 → J2-21; pin 14 → J2-18 |
| B | The fiber cable is crossed as drawn, and an undocumented swap upstream (the AIM FPGA, step 2, or the AIM-to-J15 cable, step 4) undoes it, so EPICS sees straight behavior | J2-18, station online | J15 pin 1 → J2-18; pin 14 → J2-21 |
| C | The fiber cable is crossed as drawn and nothing undoes it; the software's expectations are wrong | J2-18, station online | J15 pin 1 → J2-18; pin 14 → J2-21 |

- **A** needs one drawing error. **B** needs the drawing to be right plus an undocumented swap that
  compensates for it. **C** means that the EPICS filament command has set the station-online bit
  since 1999 without anyone noticing: the warm-up would not start on the filament command, and
  "Filament OFF due to fault" would be printed whenever the station went offline. C is unlikely.
- **A is the most likely, but A and B call for opposite chassis wiring and look the same from
  EPICS.** Only a check at the chassis boundaries, J15 and J2, or of the fiber itself, separates them.

## 6. What the Documents Say Now

Case A throughout. Doc C: V1 (FILAMENT_ON, J15 pin 1) → P12 (J2-21, filament request) and V2
(SOLENOID_ON, J15 pin 14) → P9 (J2-18, station-online bit), with the swapped labels explained after
the X530 table. Doc M: the fiber table pairs U13 with SOLENOID_ON and U14 with FILAMENT_ON, with a
note on the drawing. Doc L and Doc I: the AIM bit tables pair bit 2 (FILAMENT) with the filament and
focus request and bit 0 (SOLENOID) with the station online request. J. Sebek's LLRF documentation
notes copy the drawing's labels and carry the same swap.

## 7. How to Settle It

### 7.1 Decisive (either one)

1. **Trace the fibers**, with no power needed: at the panel, find the fiber that enters receiver
   U13 and follow it to the Fast Interlock Chassis, to port J45 (FILAMENT_ON) or J46 (SOLENOID_ON).
   With the two chassis schematics (steps 5 and 7) this fixes the J15-to-J2 pairing.
2. **Toggle and observe** (I0-T1), with the high voltage off, the filament already off (an unwanted
   filament drop costs a warm-up) and K1 in online:
   - Switch on `SRF1:STN:AIM:FILAMENT` alone. Note which lamp on the Fast Interlock Chassis front
     panel lights, DS-1 FILAMENT ON or DS-2 SOLENOID ON (this checks steps 1 to 4), and which line
     goes to 24 V at the panel's J2, pin 18 or pin 21 (steps 5 to 7).
   - Repeat with `SRF1:STN:AIM:SOLENOID` alone.
   - Record both pairings: EPICS command → J15 pin, and J15 pin → J2 line.
   - The EPICS readbacks agree if X530 is wired as drawn: `SRF1:FILAMENT:ON:PLC` follows J2-21, and
     `SRF1:STN:LOCAL:ON` follows J2-18 while K1 is in online. They pass through X530, whose pin
     numbers are themselves open (Doc C O5), so for the chassis the voltage on the J2 pin counts.

### 7.2 Supporting, not decisive

- **Archive**, with no hardware: if the records are archived, see whether `SRF1:FILAMENT:ON:PLC`
  changed together with `SRF1:STN:AIM:FILAMENT` or with `SRF1:STN:AIM:SOLENOID` at past turn-ons
  and turn-offs. This separates case C from A and B, but not A from B.

### 7.3 Step 2, the AIM FPGA

- **Not checkable from the workspace.** The EPICS code defines only the register: Fast Interlock
  Control, A16 offset 0x20, bit 0 SOLENOID and bit 2 FILAMENT (`p2RfAimDef.h`). The AIM schematic
  shows the six command lines as pins of a Xilinx XCS40XL (SOLENOID_ON 70, FILAMENT_ON 71, ABORT
  72, FAULT_RESET 74, FILAMENT_TIMEOUT 76, HVPS_ON 77), loaded at power-up from an XC18V512
  configuration PROM. Which register bit drives which pin is set inside that configuration. A
  search of the workspace for FPGA sources and bitstreams found only those of the KSC V152 module
  and the LLRF9. The AIM's own front-panel LEDs (VXI, FLT, FORCED, ARC, A/B, INV OP, ABORT, RESET)
  do not show the commands.
- **How it could be checked:**
  - Ask for the AIM FPGA design. The schematic was redrawn in Altium in December 2018 (title
    block: D. Brown, T. Phan); the register definitions are R. Claus's (1997) and the 12-channel
    AIM is M. Laznovsky's (2003).
  - In hardware, toggle one EPICS command and watch the Fast Interlock Chassis lamps DS-1 FILAMENT
    ON and DS-2 SOLENOID ON. This checks steps 1 to 4 together (Section 7.1, item 2).
  - Reading the PROM back through the AIM's JTAG header is possible, but decoding the bitstream is
    not practical.
- **Why it would help:** with steps 2 and 4 confirmed straight, case B is ruled out, and the
  archive check of Section 7.2 decides between A and C from the desk. The chassis wiring itself
  depends only on steps 5 to 7.

## 8. Fallback

If neither decisive check can be done before the board design, route V1 and V2 to P9 and P12
through a jumper block on the board (straight or crossed), set at installation from the I0-T1
result. A wrong guess then costs a jumper move, not a board change.

Related but separate: the active levels of the J15 lines (inverted by the AIM's output buffer and
again by the Fast IC's Schmitt triggers) are the other half of Doc C O4.

## 9. Sources

Drawings:

- AIM schematic SD-340-309-01, page 18 (J3 front-panel connector):
  [sd3403090102.pdf](../../llrf/documentation/legacyInterfaceModules/sd3403090102.pdf)
- Fast Interlock Chassis SD-340-308-02, page 1 (J15, display lamps DS-1 to DS-6) and page 2
  (command inverters to J101): [SD-340-308-02-R1.pdf](../../llrf/documentation/legacyInterfaceModules/SD-340-308-02-R1.pdf)
- Fast Interlock Chassis SD-340-308-01 (fiber transmitters, ports J45 to J50):
  [SD-340-308-01-R1-1of1.pdf](../../llrf/documentation/legacyInterfaceModules/SD-340-308-01-R1-1of1.pdf)
- WD-340-330-29, control fiber-optic cables of the panel:
  [wd3403302900.pdf](../../llrf/documentation/mpsWiringDiagrams/wd3403302900.pdf)
- RF Local Display Panel SD-340-311-01, page 1 (drivers, J2) and page 2 (fiber receivers U10 to U16):
  [sd3403110100.pdf](../../llrf/documentation/localPanel/sd3403110100.pdf)
- WD-340-330-02, panel cross-connects:
  [wd3403300200.pdf](../../llrf/documentation/mpsWiringDiagrams/wd3403300200.pdf)
- WD-340-330-23, PLC-5 1771-IBN digital inputs:
  [wd3403302300.pdf](../../llrf/documentation/mpsWiringDiagrams/wd3403302300.pdf)

PLC-5 program, decoded 2012 file
([20120206_SP3RF_MODIFIED_FOCUS1_LOWER_VOLT_LIMIT.txt](../../llrf/allenBradley/decoded/20120206_SP3RF_MODIFIED_FOCUS1_LOWER_VOLT_LIMIT.txt)):

```text
001  XIC(I:031/7 <ONLINE>) XIC(I:031/3 <KLY_FOC_DI>) OTE(N21:12/5 <ONLINE_L>)
000  XIC(I:031/1 <FIL_ON_OFF>) OTE(N22:0/2 <FIL_ON_OFF_>)
001  XIC(N22:0/2 <FIL_ON_OFF_>) XIO(N21:8/3 <KLY_FIL_I_UL_L>) XIO(N21:8/1 <KLY_FIL_V_UL_L>) TON(T4:0 <FIL_ON_LOW_TMR>, ...)
000  XIC(I:031/1 <FIL_ON_OFF>) XIO(N21:8/5 <FOCUS_1_V_UL_L>) BST OTE(O:031/1 <FOCUS_1_DO>) NXB OTE(N22:0/9 <FOCUS_1_DO_>) BND
041  XIC(<CAV_SUM_GLOB>) BST XIC(<KLY_SUM_GLOB>) NXB XIO(<ONLINE_L>) BND XIC(<WG_SUM_GLOB>)
     BST XIC(<ILOCK_SUM_GLOB>) NXB XIO(<ONLINE_L>) BND ... OTE(N22:0/0 <GLOBAL_STATUS>)   (abbreviated)
```

Legacy EPICS sources (RCS head revisions):

- [aim.db,v](../../spear-rf-code-legacy/rfApp/Db/aim.db,v): `STN:AIM:FILAMENT` writes `MODU.FOO`,
  `STN:AIM:SOLENOID` writes `MODU.SOO`.
- [devP2RfAim.c,v](../../spear-rf-code-legacy/rfApp/src/db/devP2RfAim.c,v) and
  [p2RfAimDef.h,v](../../spear-rf-code-legacy/rfApp/src/db/p2RfAimDef.h,v): FOO → bit 2
  (AIM_V_FILAMENT), SOO → bit 0 (AIM_V_SOLENOID).
- [rf_msgs.st,v](../../spear-rf-code-legacy/rfApp/src/seq/rf_msgs.st,v): the 1999 rename, `station`
  assigned to `STN:AIM:SOLENOID`, `filament` to `STN:AIM:FILAMENT`, and the "Filament OFF due to
  fault" check against `FILAMENT:ON:PLC`.
- [rf_digital_All.substitutions,v](../../spear-rf-code-legacy/rfApp/Db/rf_digital_All.substitutions,v):
  `STN:LOCAL:ON` ("Online/Offline") = word 16 bit 5 = N21:12/5, ONLINE_L (bits 3 and 4 of the
  same word are HV and RF detected, N21:12/3 and /4); `FILAMENT:ON:PLC` = word 35 bit 2 = N22:0/2,
  the copy of I:031/1 (bit 1 of the same word is RESET, N22:0/1; bits 9 and 10 are the focus
  outputs, N22:0/9 and /10).
