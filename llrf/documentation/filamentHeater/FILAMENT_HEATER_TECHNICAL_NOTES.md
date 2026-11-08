# SPEAR3 Klystron Filament Heater Chassis — Technical Notes

- **Drawing**: SD-340-311-00 Rev E2, "PEP II RF Klystron Filament Schematic", sheet 1 of 1
  (`sd3403110002.pdf` in this folder; CAD file `sd34031100.e2`).
- **Design**: P. Corredoura (engineer, approval), J. Jue (drawn, 15 August 1996), A. Hill (checked).
- **Installed**: rack B132-15, SPEAR3 RF station.
- **Author**: Faya Wang. First issue March 2026; this issue 5 November 2026, rewritten against the
  drawing and the sources in Section 10, and updated 6 November 2026 with the RF MPS PLC-5 program
  (Section 6). Section 11 lists the corrections to the first issue.

---

## 1. Summary

The chassis switches regulated 120 VAC through a solid-state relay (S1) onto a motor-driven variac
(V1). The variac output goes to the output terminal block TB2 through a current transformer (T1) that
only feeds the ammeter. **There is no step-down or isolation transformer in the chassis**: TB2 carries
the variac voltage itself, up to 140 V RMS and 1.00 kVA.

The RF MPS PLC-5 controls the chassis with two digital lines on connector J1, `FILAMENT_ON` and
`MOTOR-UP`, and reads the voltmeter and ammeter outputs on the same connector. The variac can only be
driven up while the filament is on, and it runs down to its lower limit whenever `FILAMENT_ON` drops,
so every turn-on starts from zero. The PLC-5 raises the variac to fixed voltage and current
constants during the first part of a timed warm-up, and switches the filament off on a high-voltage
or high-current trip (Section 6).

SPEAR3 runs the heater at 68 V and 7.3 A at TB2 (about 500 W). In the upgrade (Doc M, step I5) a
TDK-Lambda Genesys AC supply replaces S1 and the variac under RF MPS control; the meters, T1, TB2 and
J1 stay.

## 2. Power Path

```text
TB1-A line ---- F1 10 A --+-- S1 SS relay ------ V1 variac ------- T1 primary ------- TB2-A output
                          |   CTRL = FILAMENT_ON  in: tap 5          P1 -> P2, 3 turns
                          |                       out: wiper 3
                          +-- K1 common (variac motor), meter and time-meter supply
TB1-B neutral ------------ V1 terminal 4, motor common --------------------------- TB2-B
TB1-C ground ------------- chassis ground ---------------------------------------- TB2-C
```

| Item | Drawing | Function |
| --- | --- | --- |
| TB1 | AC INPUT, terminals A, B, C | Line, neutral, ground; annotated "120 VAC REGULATED 1 KVA"; rear panel |
| F1 | 10 A fuse | Line fuse ahead of everything else |
| S1 | SS RELAY | Switches the line onto the variac; control input driven by `FILAMENT_ON` |
| V1 | VARIAC | Input on tap 5, neutral on terminal 4, output on wiper 3; wiper turned by the drive motor |
| T1 | TEXMATE CT, marked "10 : 1" | Current transformer for the ammeter; the output lead makes 3 turns through the toroid (Note 5) |
| TB2 | AC OUTPUT, terminals A, B, C | Output, neutral, ground; rear panel |

The drawing states "EXPECTED VALUES: 135V 4.8A RMS" (the PEP-II klystron) and "MAXIMUM CAPACITY:
140 RMS 1.00 KVA".

The cathode sits at the full HVPS voltage (about 72 kV), so an isolating heater transformer must sit
between TB2 and the cathode. It is not on this drawing.

## 3. Variac Drive

The drive motor is an AC motor with an up winding (terminal 1), a down winding (terminal 3) and a
common (terminal 2, on neutral), and a 50 µF capacitor between terminals 1 and 3. Relay K1 selects the
direction: its coil (13–14) is driven by `FILAMENT_ON`, and its common contact (11) is fed from the
fused line ahead of S1.

| `FILAMENT_ON` | `MOTOR-UP` | Motor path | Result |
| --- | --- | --- | --- |
| Off | — | K1 11–7, DOWN LIMIT switch (N/C), terminal 3 | Variac runs down until the down-limit switch opens |
| On | Off | K1 11–3, UP LIMIT switch, S2 open | Motor stopped; voltage held |
| On | On | K1 11–3, UP LIMIT switch (N/C), S2, terminal 1 | Variac runs up until `MOTOR-UP` drops or the up-limit switch opens |

Consequences:

- Every turn-on starts at zero volts.
- While the filament is on, the voltage can only be held or raised. Lowering it means switching the
  filament off, which returns the variac to zero.
- There is no wiper-position readback. Only the two limit switches and the voltage and current
  monitors show where the variac is.

## 4. Metering and Indicators

| Item | Connections | Notes |
| --- | --- | --- |
| M1, AC voltmeter | ACV+ (pin 1) at the variac wiper, ACV- (3) on neutral; DC OUT (16, 17) to `V MON+/-` on J1-E/F | Reads the output voltage (the same as TB2) |
| M2, AC ammeter | AC AMP S1/S2 (1, 3) from the T1 secondary, marked "1.0A FULL SCALE"; DC OUT (16, 17) to `A MON+/-` on J1-G/H | Reads the output current through T1 |
| U1, time meter | AC1/AC2 | Front panel; powered ahead of S1, so it counts hours of chassis power, not filament-on hours |
| DS1, green LED | `FILAMENT_ON` line | Front panel, "FILAMENT ON" |
| DS2, green LED | `MOTOR-UP` line | Front panel, "MOTOR-UP" |

Both meters take their power (AC POWER 1/2, pins 14/15) from the fused line, and each has its LOCK
pin (8) jumpered to COMMON (11). The remote voltage and current readbacks are the meters' own DC
outputs, so they need the meters and the chassis power.

**T1 scaling, to be confirmed.** The drawing marks T1 "10 : 1" and specifies a 3-turn primary, but does
not say whether 10:1 is the transformer's own ratio or the ratio with three turns.

- Read as 10:1 *with* three turns, 10 A of heater current gives 1.0 A at the ammeter. This matches the
  ammeter's 1.0 A full scale and the 10 A full scale of `SRF1:FILAMENT:CURR`; today's 7.3 A reads
  0.73 A.
- Read as the transformer's own ratio, the ammeter would see 0.3 times the heater current: 2.2 A at
  7.3 A, beyond its full scale.

Check on the hardware before T1 and the `A MON` scaling are reused.

## 5. Connectors and Drawing Notes

J1 ("CONTROL I/O", labelled `8F_MS`) has eight contacts, A to H, on the rear panel.

| J1 pin | Drawing label | Signal | Chassis side |
| --- | --- | --- | --- |
| A | FROM A/B DIGITAL OUT CONTROL | `FILAMENT_ON` | S1 control, K1 coil, DS1 |
| B | FROM A/B DIGITAL OUT RETURN | Return | Chassis ground |
| C | FROM A/B DIGITAL OUT CONTROL | `MOTOR-UP` | S2 control, DS2 |
| D | FROM A/B DIGITAL OUT RETURN | Return | Chassis ground |
| E | TO A/B ANALOG IN SIGNAL | `V MON+` | M1 DC OUT |
| F | TO A/B ANALOG IN RETURN | `V MON-` | M1 DC OUT |
| G | TO A/B ANALOG IN SIGNAL | `A MON+` | M2 DC OUT |
| H | TO A/B ANALOG IN RETURN | `A MON-` | M2 DC OUT |

TB1 and TB2 each have three terminals, A, B and C (line or output, neutral, ground).

Drawing notes:

1. All bold wiring is #16 gauge.
2. All non-bold wiring is #18 gauge.
3. J1, TB1 and TB2 are on the rear panel.
4. LEDs DS1 and DS2 are on the front panel.
5. The primary on T1 is 3 turns through the toroid.

Revision 2 (LS, 12-99) reads "ADDED GRAPHICS TO SECTIONS C5 & C6, MOTOR UP WAS FULL CURRENT": the line
now named `MOTOR-UP` was labelled FULL CURRENT before.

## 6. Interface to the RF MPS and EPICS

**Wiring.** J1 is wired through the cross-connects to the RF MPS PLC-5 in rack B132-13; there is no
fiber on this path. SPEAR3 uses the same setup as PEP-II, so the PEP-II MPS wiring diagrams give the
PLC-5 channels:

| Drawing | Module | Channels |
| --- | --- | --- |
| WD-340-330-25 | Digital output #1 (1771-OBN) | Sheet 2: point 23 "FILAMENT ON/OFF", point 24 "FILAMENT CURRENT UP", point 31 "KLYSTRON WINDOW AIR BLOWER ON/OFF". Sheet 1: point 05 "FILAMENT TIME OUT" |
| WD-340-330-23, sheet 2 | Digital input #1 | Point 21 "FILAMENT ON/OFF", point 22 "FILAMENT TIMER BYPASS" |
| WD-340-330-21 | Analog input #1 | Channel 11 "FILAMENT V" and channel 12 "FILAMENT I", from J1 pins E and G of the heater chassis (X610) |

**Operator request.** The filament request leaves the AIM VXI module, crosses the Fast Interlock
Chassis and a fiber to the RF Local Display Panel, and reaches the PLC-5 from panel connector J2:

- J2-21 "Filament Req24" is wired to the PLC-5 input "Filament PS On/Off".
- J2-22 carries the filament-timer bypass request.
- The PLC-5 returns two lines to the panel on J2-09 and J2-10, named filament on and timer bypass in
  the cross-connect map. The program has no bypass output; the matching outputs are FILAMENT ON/OFF
  and FILAMENT TIME OUT, which is on when the warm-up is done or bypassed.

The AIM-side and panel-side names of these fiber lines do not match (J. Sebek, LLRF notes R2). The
PLC-5, not the AIM, drives J1.

**PLC-5 logic.** The RF MPS program files of 2011 and 2012 (`llrf/allenBradley/`, decoded listings
in `llrf/allenBradley/decoded/`) give the filament logic in program file 11, with the trips in
file 8. The values below are from the 2012 file:

- The request starts a first timer (1000 s) and turns `FILAMENT_ON` on, unless a high-trip latch is
  set. The same request switches on the main focus and bucking-coil supplies.
- During the first timer, `MOTOR-UP` is on while the voltage is below 100.0 V and the current below
  5.20 A. The variac stops at whichever constant it reaches first, and is raised again if the
  reading falls back below it during that time. After the first timer, `MOTOR-UP` stays off.
- A second timer (600 s) follows. `SRF1:FILAMENT:TIME` is 1600 s minus the time elapsed.
- The trip limits are 90.0 to 110.0 V and 4.00 to 6.00 A. Each crossing latches until the RESET line
  clears it with the value back inside. A high trip turns `FILAMENT_ON` off and restarts the warm-up
  from zero. A low trip only drops the filament summary; the low latches also set at every cold
  start, so a reset follows the warm-up.
- The filament summary is on when the warm-up is done or bypassed and neither low latch is set.
  It is part of the klystron group of the PLC-5's global interlock sum, which EPICS reads as the
  station summary and the AIM receives as the AB summary.
- The bypass request latches only while the filament is on.
- The klystron window-air blower runs while `FILAMENT_ON` is on and for 600 s after.

The program in service differs: the 2021 change made the warm-up 2100 s, and today's high voltage
trip, 76.2 V, is below the 2012 ramp constant of 100 V (open point 5).

**EPICS** (legacy IOC):

| PV | Meaning |
| --- | --- |
| `SRF1:STN:AIM:FILAMENT` | Operator filament request (AIM) |
| `SRF1:FILAMENT:VOLT`, `SRF1:FILAMENT:CURR` | Monitors from J1; full scale 150 V and 10 A |
| `SRF1:FILAMENT:VOLT:ULIM`, `:LLIM` (same for `CURR`) | PLC-5 trip limits, read back |
| `SRF1:FILAMENT:POWER` | VOLT × CURR |
| `SRF1:FILAMENT:ON:PLC` | Filament request as the PLC-5 receives it (an input, not the output) |
| `SRF1:FILAMENT:LOW:PLC` | `FILAMENT_ON` output on |
| `SRF1:FILAMENT:HIGH:PLC` | `MOTOR-UP` output on |
| `SRF1:FILAMENT:TIMEBYP:PLC` | Warm-up bypass latched |
| `SRF1:FILAMENT:TIME` | Warm-up time left, read from the PLC-5 |
| `SRF1:FILAMENT:SUMY:PLC` | PLC-5 filament summary |

Two behaviors outside the chassis matter for the upgrade:

- J. Sebek raised the warm-up time from 1600 s to 2100 s for the klystron installed in 2020
  (`rf_klys.db` revision 1.7, January 2021).
- The sequence `rf_msgs.st` opens the HVPS contactor (`SRF1:HVPSCONTACT:CLOSE:CTRL`) when
  `SRF1:FILAMENT:SUMY:PLC` reports a fault. Its message "Filament OFF due to fault" watches
  `SRF1:FILAMENT:ON:PLC`, the request as the PLC-5 receives it. It therefore reports the request
  lost between the AIM and the PLC-5 while the AIM still asks for the filament, not a PLC-5 trip.

## 7. Operating Values

| Quantity | Voltage | Current | Source |
| --- | --- | --- | --- |
| Drawing, expected (PEP-II klystron) | 135 V | 4.8 A | SD-340-311-00 |
| Drawing, maximum capacity, 1.00 kVA | 140 V | 7.1 A at 140 V | SD-340-311-00 |
| SPEAR3 operating point, at TB2 | 68 V | 7.3 A | Live values (Doc 0 R4) |
| PLC-5 trip limits, low to high | 62.4 to 76.2 V | 5.24 to 9.77 A | Live values (Doc 0 R4) |
| PLC-5 trip limits in the 2012 program (previous klystron) | 90.0 to 110.0 V | 4.00 to 6.00 A | `llrf/allenBradley/` (Section 6) |
| PLC-5 ramp constants in the 2012 program | 100.0 V | 5.20 A | `llrf/allenBradley/` (Section 6) |
| EPICS LOLO / LOW / HIGH / HIHI | 63.8 / 66.5 / 72.1 / 76.2 V | 6.72 / 7.01 / 7.59 / 7.88 A | Live values (Doc 0 R4) |
| EPICS limits in the archived substitution file | 95 / 96 / 127 / 128 V | 4.7 / 4.8 / 6.4 / 6.5 A | `rf_analog_All.substitutions` |
| Monitor full scale (EPICS) | 150 V | 10 A | `rf_analog_All.substitutions` |

- The archived limits bracket neither today's operating point nor the drawing's 135 V, so a new
  database takes its limits from the live configuration.
- The 1.00 kVA rating corresponds to 7.1 A at 140 V. Today's 7.3 A is at that figure, and the PLC-5
  high trip (9.77 A) is above it.
- The replacement supply must be rated for both current and power. In operation it delivers 7.3 A and
  about 500 W at 68 V. It also needs margin up to the PLC-5 high trips: 9.77 A, and 76.2 V, which is
  about 620 W into today's filament resistance (9.3 Ω).

## 8. Upgrade (Doc M, Step I5)

- **Scope.** A TDK-Lambda Genesys AC programmable supply replaces S1 and the motor-driven variac
  inside the chassis. The voltmeter, ammeter, T1, TB2 and J1 stay. The supply is running on a test
  stand with a load.
- **Control.** The RF MPS enables the supply and ramps it through its analog programming input.
  Ethernet carries monitoring and enable to the heater IOC (Doc M, SW3). The voltage and current
  monitors keep feeding the RF MPS with the limits of Section 7.
- **60 Hz sync.** An external sync circuit is in design (B. Morris). J. Sebek's note
  (`TDK/Jim2Ben.txt`) proposes four stages:
  1. a low-power 120 VAC control transformer;
  2. a 60 Hz band-pass filter to clean up transients;
  3. a comparator;
  4. a monostable that gives the trigger pulse for the supply.

  In the same folder, `bpf60.m` sizes the filter resistors for a chosen capacitor and Q, and the
  LTspice files `bpf60.asc` and `bpf60.net` check the design.
- **Behavior to carry over from the legacy system:**
  - a ramp up from zero at every turn-on, which the PLC-5 ends at fixed voltage and current
    constants (Section 6);
  - a return to zero when the filament is switched off or trips high;
  - the warm-up timer and its bypass;
  - the HVPS contactor opening on a filament fault.
- **Fallback.** The variac chassis stays in place.
- **Acceptance.** Doc 0 open item O6 and the I5 tests in Doc M.

## 9. Open Points

1. T1 ratio (Section 4): 10:1 with three turns, or 10:1 per turn.
2. Ratings against today's load (Section 7): the variac's current rating against 7.3 A, and the
   Genesys AC's current and power ratings against 7.3 A and about 500 W, with margin to the PLC-5
   high trips.
3. The isolating heater transformer between TB2 and the cathode: its location, ratio and insulation
   rating. It is not on this drawing.
4. The source of the regulated 120 VAC that feeds TB1.
5. The ramp constants and the split of the 2100 s warm-up between the two timers in the program in
   service. The 2012 file has 100.0 V and 5.20 A, and 1000 s plus 600 s (Section 6).

## 10. Sources

| Source | Location |
| --- | --- |
| SD-340-311-00 Rev E2, heater chassis schematic | `llrf/documentation/filamentHeater/sd3403110002.pdf` |
| WD-340-330-21, -23 and -25, RF MPS wiring (PEP-II drawings, same setup at SPEAR3) | `llrf/documentation/mpsWiringDiagrams/wd3403302100.pdf`, `wd3403302300.pdf`, `wd3403302500.pdf` |
| RF MPS PLC-5 program, RSLogix 5 projects of 2011 and 2012, with decoded listings | `llrf/allenBradley/`, `llrf/allenBradley/decoded/` |
| RF Local Display Panel to cross-connect mapping | `llrf/documentation/LocalPanelToXConnectMapping.xlsx` |
| J. Sebek, LLRF documentation notes R2 | `llrf/documentation/LLRFDocumentationNotesR2.docx` |
| J. Sebek, 60 Hz filter note and design files | `llrf/documentation/filamentHeater/TDK/` |
| Legacy EPICS (RCS heads): `rf_analog.db`, `rf_analog_All.substitutions`, `rf_digital_All.substitutions`, `rf_klys.db`, `rf_sumy_klys.db`, `rf_msgs.st`, `RELEASE_NOTES` | `spear-rf-code-legacy/` |
| Doc 0 R4, SPEAR3 LLRF Upgrade System Design Report | `Designs/tex/doc0-system-design/0_system_design_report.pdf` |
| Doc M R0 (draft), Subsystem Integration and Migration Plan | `Designs/tex/docM-integration-migration/M_integration_migration_plan.pdf` |
| Doc L R1, Legacy System Architecture | `Designs/tex/docL-legacy-architecture/L_legacy_system_architecture.pdf` |

## 11. Corrections to the March 2026 Issue

1. The drawing is SD-340-311-00 Rev E2, not "SD-349-311-20". SD-340-311-01 is the RF Local Display
   Panel schematic.
2. T1 is the current transformer for the ammeter, not a 10:1 step-down isolation transformer. The
   values built on that reading are removed: 6.8 V at 73 A, 4.84 V expected, and 14.0 V at 71 A
   maximum. The drawing gives 135 V and 4.8 A expected, and 140 V and 1.00 kVA maximum, at TB2.
3. S1 and S2 are solid-state relays (filament power and motor up), not LOCK/HOLD/TEST meter switches.
   LOCK, HOLD and TEST are meter pins.
4. The drive motor is an AC motor, not a DC motor. There is no motor-down command; the variac runs
   down by itself when `FILAMENT_ON` drops.
5. M1 is the voltmeter, M2 the ammeter and U1 the time meter. U1 counts chassis power-on hours, not
   filament hours. `8F_MS` labels J1, not the time meter.
6. The voltmeter reads the variac output (equal to TB2), not a transformer secondary.
7. J1 goes through cross-connects to the PLC-5 in B132-13. There is no fiber link, B118 PLC or
   Hoffman box on this path. The chassis is in B132-15.
8. TB2 has terminals A, B and C. Pin numbers 14 to 17 belong to the meters.
9. The J1 pin letters A to H are added.
10. "Phase C from Hoffman Box" is removed. TB1 takes regulated 120 VAC (line, neutral, ground).
11. Generic material not taken from the drawing is removed:
    - cathode physics;
    - the heater comparison tables, including their "~5 V, ~20 A" figures;
    - the wire-gauge justification;
    - unsourced MPS claims.

    The upgrade section follows Doc 0 R4 and Doc M (Genesys AC under RF MPS control) instead of the
    superseded SCR design.
