# J. Sebek's Questions on I4 (RF MPS) and I5 (Heater): Our Understanding

- **Subject**: Doc M R0 (draft), integrations I4 (RF MPS) and I5 (klystron heater supply).
- **From**: J. Sebek, comments received November 2026.
- **Prepared by**: F. Wang, 6 November 2026.
- **Basis**: the legacy EPICS sources (RCS head revisions in `spear-rf-code-legacy/`), the RF MPS
  PLC-5 program files of 2011 and 2012 (`llrf/allenBradley/`), the RF MPS wiring diagrams, the
  heater chassis drawing and J. Sebek's notes (Section 9). Nothing here has been tested on the
  hardware, and Doc M has not been changed.
- **Update**: the PLC-5 program files answer the program questions left open in the first version
  (Sections 4.6, 5.1 and 5.3). They predate the 2021 filament changes, so the program in service
  still has to be compared (Section 6).

---

## 1. Jim's Message

> I am not sure about I4 and I5 before the total switch.
>
> I4: If we replace the PLC-5, we alter Stephanie's reading of values from the MPS. The MPS gives
> a hardware permit through the local display and fast interlock. Dehong's chassis will solve
> that, but software readings out of MPS may also be required for the system to stay on. I am not
> sure if she trips something off if either she does not see data from the MPS or if she faults if
> some values are outside of limits. Certainly, even if the station does not trip off, the panel
> will light up red with all sorts of alarms. That would require some software intervention.
>
> On a PAMM we could remove the serial connections from those chassis and see what lights up. We
> can first see if we could reconfigure the serial connection out to the HVPS to bypass the PLC-5
> and stepper motor controls and then, if we are very bold with our fingers on many emergency off
> buttons, we could see if we can turn on the HVPS at a low value. I don't know if the PLC-5 can
> stand alone and provide the permits even if not connected to the VXI crate. It may.
>
> I5: I have to also look at the filament control. Currently that is also done by the PLC-5. We
> could replace the supply and control the filament. I have to see if there are any hardware
> interlocks on the MPS tied to the current and voltage readbacks on the system. If there are,
> they are likely meter readings tied to cables. If so, we could build another chassis with meters
> and outputs that would read the Genesys supply and report back to whatever MPS system is in
> operation. We likely may want that monitor for the final system with the Genesys anyway.

## 2. The Questions

- **Q0.** Should I4 and I5 happen before the total switch (I8)?
- **Q1.** If the PLC-5 is replaced, does the legacy IOC software turn the station off when it no
  longer sees PLC-5 data?
- **Q2.** Does it turn the station off when a PLC-5 value is outside its limits?
- **Q3.** Will the displays fill with alarms, so that the software has to be changed?
- **Q4.** Can the PLC-5 stand alone and give its permits without the VXI crate?
- **Q5.** On a PAMM: take the serial (Remote I/O) link off the PLC-5 and the stepper chassis, run
  the link to the HVPS only, and try the HVPS at a low voltage.
- **Q6.** I5: does the MPS have hardware interlocks on the filament voltage and current
  readbacks? If they are meter readings on cables, a new chassis with meters could report the
  Genesys output to whichever MPS is in service.

## 3. Short Answers

| Question | Understanding | Section |
| --- | --- | --- |
| Q0 | Both are possible before I8. I4 needs a legacy database change, and Jim's PAMM test should come first. I5 can be decoupled from I4 with the monitor chassis. | 4.8, 5.2 |
| Q1 | No while the IOC runs: the PLC-5 values freeze. After an IOC reboot without the PLC-5, the station cannot be turned on. | 4.4 |
| Q2 | Only through the PLC-5's own decision, its global interlock sum, which EPICS sees as the station summary bit and, through the AIM, as the AB summary; and through a few named records. EPICS alarm limits light the displays but do not trip the station. | 4.3, 4.5, 4.6 |
| Q3 | While the IOC runs: HWERROR on the station status and alarms on the link status; the values are stale, not red. After a reboot: every PLC-5 channel INVALID. The fix is a database change; no SNL program changes. | 4.4, 4.8 |
| Q4 | Yes. EPICS writes nothing to the PLC-5, and the program neither uses the data it reads back from the DCM nor watches the transfers. The heartbeat is a 50 ms timer that stops only on an error from the PLC-5's own analog or thermocouple modules. | 4.6 |
| Q5 | Feasible. The program predicts no change on the PLC-5 side; the test confirms this on the program in service. Predicted outcome and cautions are listed. | 4.7 |
| Q6 | Yes, inside the PLC-5: low and high trips on the meters' DC outputs on J1. A high trip switches the filament off; a low trip drops the filament summary. No relay contacts are used. The monitor chassis works with either PLC. | 5.1, 5.2 |

## 4. I4: The Legacy IOC and the PLC-5

### 4.1 "Stephanie's" Software

The RCS headers name Stephanie Allison (author code `saa`) as the author of the IOC start-up script
(`st.cmd`, 13 November 2002), the database substitution files, the message logger `rf_msgs.st`
(1997) and the SLC-500 DCM device support.

### 4.2 How the IOC Reads the PLC-5

- One Remote I/O link leaves the scanner in VXI slot 1. It runs to the PLC-5's 1771-DCM (rack 3,
  first node), the SLC-500 tuner chassis 340-315 (rack 2), a terminal box above the HVPS
  termination tank, and on the long-haul cable to the HVPS SLC-500 in B118 (rack 1, last node).
  The second PLC-5 crate hangs on the main crate's own link (`config.ab`; J. Sebek, LLRF notes R2).
- The record `SRF1:STN:DCM:MODU` reads the PLC-5's eight 64-word tables by block transfer about
  every 0.5 s. It is processed from the rack-3 adapter-status record, which scans at 0.5 s.
- 232 template instances (temperatures, interlock bits, analog channels, summaries, module status)
  read words or bits from these tables. All are I/O Intr records: they process only when their
  word changes.
- **EPICS writes nothing to the PLC-5.** No record uses the DCM output device support and no record
  addresses rack 3. The PLC-5 reads a 64-word block back from the DCM every cycle, but no rung uses
  it (Section 4.6). Commands from the VXI side reach the PLC-5 as hardwired lines from the AIM,
  through the Fast Interlock Chassis, the panel fibers and cross-connect X530. The panel lines into
  the PLC-5 are reset, local/remote, filament on/off, filament-timer bypass, klystron focusing
  on/off and online/offline mode (WD-340-330-23).

### 4.3 What the State Machine Needs from the PLC-5

| Record | Source in the PLC-5 | Read by | Effect of a fault |
| --- | --- | --- | --- |
| `SRF1:STN:SUMY:PLC` | Global interlock sum (N22:0/0), table 6, word 35, bit 0 | Off and on summaries (`STNOFF:SUMY:STAT`, `STNON:SUMY:STAT`) | Station off; turn-on refused |
| `SRF1:STN:LOCAL:ON` | Online bit (N21:12/5): the online/offline-mode and klystron-focusing lines both on; table 6, word 16, bit 5 | Off summary; turn-on and auto-reset checks in `rf_states` | Station off; turn-on refused ("Key station ON from local panel first.") |
| `SRF1:STN:ABSUMY:LTCH` | The same global interlock sum on output O:031/00, hardwired through the panel, the Fast Interlock Chassis and the AIM | Off and on summaries | Station off; turn-on refused |
| `SRF1:FILAMENT:SUMY:PLC` | Filament summary (N22:1/5), table 6, word 36, bit 5 | `rf_msgs` | HVPS contactor opened |
| `SRF1:CAVn:VACM` | Cavity vacuum, analog | HVPS loop, through `CAVVACM:SUMY:SEVR` and `CAVVACM:CHECK` | Loop stops ("Bad vacuum") or lowers the HVPS voltage |
| `SRF1:CAVnTUNR:POSN` | Tuner potentiometers, analog | Legacy tuner loops (home and park moves) | No home move on a bad position; unused after I3 |

The state machine acts on the alarm severity of the two summaries, not on values. In an on state,
any alarm on the off summary turns the station off. A request to turn on is refused unless the on
summary and `STN:LOCAL:ON` are free of alarms. The other inputs of the off summary are the VXI latch
and the HVPS off summary, which uses only HVPS SLC-500 data.

All other PLC-5 data (temperatures, flows, filament, focus and bucking supplies, ion pumps,
collector power) feed only the alarm summaries and the station status display.

### 4.4 When the PLC-5 Data Stop

- **IOC running.** The DCM record has a field, LOCA ("loss of communication acknowledgement"), that
  reprocesses every table word when the link status changes. It is set nowhere in the application,
  so it stays at NO; the support documentation warns that setting it "will cause alarm storms".
  With LOCA off, a lost link leaves the data records untouched: they keep their last values and
  alarm states. The rack-3 adapter, card and DCM records go to MAJOR, and the station status
  (`SRF1:STN:SUMY:STAT`) shows HWERROR within about a second. Nothing trips and the station can
  still be run, but the PLC-5 values on the screens are stale.
- **IOC rebooted without the PLC-5 node.** The data records never receive data and stay undefined,
  which EPICS reports as INVALID. `STN:SUMY:PLC` and `STN:LOCAL:ON` are then INVALID, the state
  machine refuses to turn the station on ("Key station ON from local panel first."), and every
  PLC-5 channel shows INVALID. This is the "panel lights up red" case.
- **HVPS node, for comparison.** The scanner driver reprocesses discrete and analog records when an
  adapter goes on or off line, so the HVPS records go INVALID and the HVPS off summary turns the
  station off. Doc M §4.3 states this behavior for every node; it holds for the HVPS node but not
  for the PLC-5.

### 4.5 Values Outside Limits

The off and on summaries contain only the PLC-5's own decision, its global interlock sum, read
twice (as the station summary bit and as the AB summary line), and the online status. EPICS alarm
limits on PLC-5 channels light the displays and the alarm handler but do not turn the station off.
Two exceptions act on the station: cavity vacuum above its limit makes the HVPS loop lower the
voltage, and a filament summary fault makes `rf_msgs` open the HVPS contactor.

### 4.6 Can the PLC-5 Stand Alone?

Yes. The EPICS side already pointed that way:

- EPICS writes nothing to the PLC-5 (Section 4.2), so nothing it needs comes over the link.
- Its trip limits and the filament warm-up timer are in the PLC-5; EPICS only reads the limits back
  (`FILAMENT:VOLT:ULIM` and others). The 2021 increase of the warm-up time from 1600 s to 2100 s was
  made in the PLC-5; `rf_klys.db` revision 1.7 only adjusted the EPICS display limits.
- The Allen-Bradley support was designed on the rule "The PLC must assume that the EPICS system may
  be down and thus is not currently reading."

The PLC-5 program settles it. `llrf/allenBradley/` holds four RSLogix 5 projects: an undated one
with the address descriptions, and edits saved on 9 and 10 November 2011 and 6 February 2012. They
were decoded with `llrf/allenBradley/rsp_decode.py` into the listings in
`llrf/allenBradley/decoded/`; rungs are cited here as file:rung. The logic is the same in all four,
apart from the cavity-window infrared trip, raised from 85 °C to 100 °C in November 2011, and a
main-focus low-voltage limit edit in the 2012 file that was saved but not accepted.

- **DCM link.** The PLC-5 writes its eight 64-word pages to the DCM in turn (files 20 to 27). Word
  3 of each page holds the page number, which is the table number EPICS reads. The page counter
  advances only after a transfer ends without error; after an error the same page is sent again
  (2:11 to 2:20). The block the PLC-5 reads back from the DCM (15:0) is used by no rung. No output,
  latch, summary or heartbeat depends on these transfers: a lost link stops the updates and nothing
  else.
- **Heartbeat.** A 50 ms timer runs while none of the 16 analog and thermocouple modules has
  reported a block-transfer read error. When it expires, output O:031/05, "A/B HEARTBEAT", turns on
  for one scan and the timer restarts (6:33, 6:34): a one-scan pulse every 50 ms plus a scan or two.
  A module error stops the pulses until the panel's reset line clears the error counters. The DCM
  is not in this logic, so the heartbeat does not stop when the IOC stops reading. The pulse width
  is set by the scan time, so the measurement in Doc M O4 is still needed for the Interface Chassis
  watchdog.
- **Station summary and AB summary.** They are one bit, the global interlock sum (18:41). EPICS
  reads it as `STN:SUMY:PLC`, and output O:031/00, "GLOBAL INTERLOCK SUM", drives it out. The panel
  receives it on J3-09, "AB Summary24" ("Interlock Sum" in the cross-connect map), and passes it to
  the AIM. The sum is on when:
  - the four cavity summaries are good (temperatures, window infrared, vacuum contacts and water
    flow);
  - the three waveguide loads, the waveguide air pressure and the circulator are good;
  - the input labelled "MPS" on WD-340-330-23 has not dropped since the last reset;
  - and, while the online bit is set, the klystron group (klystron water flows, temperatures,
    vacuum and air flow; filament; focus; collector power) and the flow, vacuum and temperature
    summaries are good.

  In offline mode, or with klystron focusing off, the online bit is clear and these last groups are
  bypassed; `STN:LOCAL:ON` then blocks the turn-on in EPICS (Section 4.3).
- **Latches.** Every fault latches and clears only on the panel's reset line, once the condition
  has gone.
- **Version.** The files predate the 2021 filament changes (Section 5.1), so the program in service
  differs at least in its filament constants. The logic above is assumed unchanged until the
  program in service is compared (Section 6).

### 4.7 The PAMM Test

Expected from the code and the program:

- no software trip when the PLC-5 and tuner nodes come off the link;
- HWERROR on the station status, and alarms on the rack-2 and rack-3 status records;
- PLC-5 values frozen on the screens;
- no change on the PLC-5 side: the global interlock sum and the heartbeat carry on, the PLC-5 keeps
  retrying its current page to the DCM, and the panel lamps stay as they were;
- the HVPS still controllable through its own node, as long as the IOC is not rebooted.

The test confirms the PLC-5 side on the program in service. Watch the AIM latches
`SRF1:STN:ABSUMY:LTCH` and `SRF1:STN:ABHEART:LTCH`, which EPICS reads from the AIM in the VXI crate
rather than over the link, and the summary lamps on the RF Local Display Panel. The DCM shares rack
1 with the two analog input modules. Whether a stalled DCM transfer can delay their reads cannot be
told from the program; the heartbeat latch would show it.

Cautions:

1. Do not reboot the IOC while the PLC-5 is off the link (Section 4.4). `config.ab` is read only at
   boot and does not need to change; the scanner will report racks 2 and 3 as not responding.
2. Keep the trunk continuous and terminated. Opening the link at the PLC-5 DCM terminals also drops
   the tuner and HVPS nodes, and the HVPS records then go INVALID. The cables have to be joined
   through to the long-haul cable before the HVPS step.
3. Check `SRF1:STN:DCM:MODU.LOCA` before starting; it should read NO. A save/restore file could in
   principle set it.
4. While the PLC-5 is off the link, EPICS does not see its faults: the HVPS loop does not see the
   cavity vacuum and `rf_msgs` does not act on a filament fault. The PLC-5's hardwired outputs still
   protect the station.
5. With the tuner node off the link, the I3 fallback (motor cables back to the SS2000 drivers) is
   not available.
6. Leave the PLC-5's own racks alone. A read error from any of its 16 analog or thermocouple
   modules stops the heartbeat until a reset (Section 4.6).

Suggested order:

1. Baseline: record the off and on summaries, the AIM latches, the DCM status
   (`SRF1:STN:DCM:MODU`, which reads "Success" when the link is good) and the panel lamps.
2. Take the tuner node off the link (lowest risk).
3. Take the PLC-5 node off the link; watch the AIM latches and the panel for the PLC-5's response.
4. With the HVPS node on the link and the emergency-off buttons manned, turn the HVPS on at its
   minimum voltage.
5. Restore the link; check that the DCM status returns to "Success" and the data update.

### 4.8 Doing I4 Before the Total Switch

- No SNL program needs to change; the legacy database does.
- Doc M's plan re-points the legacy records to the new IOC through Channel Access, so the SNL
  programs keep reading the same names. This changes the failure mode. With maximize-severity
  links, a stopped ControlLogix IOC or a lost connection makes `STN:SUMY:PLC` and `STN:LOCAL:ON`
  INVALID, which turns the station off and blocks turn-on. Today a lost link only freezes the
  values. SW5 has to make this choice on purpose.
- The hardware permits are covered from I2 on by the Interface Chassis (D. Zhang), which takes the
  PLC-5's summaries, AB summary and heartbeat.
- The ControlLogix program has to keep the global interlock sum as it is, including the online
  bypass, and the heartbeat with its gating by module errors (Section 4.6; Doc M O8).
- The alternative is to keep the PLC-5 until the total switch (I8). That needs no legacy database
  work, but makes I8 a larger single change and keeps the station on the PLC-5 longer.

## 5. I5: Filament Control

### 5.1 What the PLC-5 Does with the Filament

- **Readbacks.** Drawing WD-340-330-21 (A-B Analog Input #1) wires channel 11 "FILAMENT V" from
  heater chassis J1-E and channel 12 "FILAMENT I" from J1-G, through X610, X525 and X516. On the
  chassis (SD-340-311-00 E2) these are the DC outputs of the panel voltmeter and ammeter. The
  drawing wires only the meters' inputs, power and DC outputs; no relay contacts are used. So there
  is no separate hardwired interlock: the interlocks are in the PLC-5.
- **In the PLC-5** (file 11, with the trips in file 8; values from the 2012 file):
  - The filament on/off line from the panel starts the first timer (1000 s) and turns on output
    O:031/03, "FILAMENT ON/OFF", which is FILAMENT_ON on J1, as long as neither high-trip latch is
    set.
  - During the first timer, output O:031/04, "FILAMENT CURRENT UP", which is MOTOR-UP, is on while
    the voltage is below 100.0 V and the current below 5.20 A (Section 5.3).
  - A second timer (600 s) follows. `FILAMENT:TIME` is 1600 s minus the time elapsed. The 2021
    change made the total 2100 s; how it is split between the two timers is not known.
  - Trip limits: 90.0 to 110.0 V and 4.00 to 6.00 A in the file; 62.4 to 76.2 V and 5.24 to
    9.77 A live, read back into EPICS. Each crossing latches.
  - The filament summary `FILAMENT:SUMY:PLC` is on when the warm-up is done or bypassed and neither
    low-trip latch is set. The bypass line latches only while the filament is on.
  - Output O:031/11 runs the klystron window-air blower while the filament is on and for 600 s
    after.
  - Status bits: `FILAMENT:ON:PLC` is the request line as the PLC-5 receives it, `:LOW:PLC` the
    FILAMENT_ON output, `:HIGH:PLC` the MOTOR-UP output and `:TIMEBYP:PLC` the bypass latch.
- **Scaling.** EPICS scales the two readbacks to 150 V and 10 A full scale over 13 bits. With this
  scaling the 2012 limits and ramp constants come out at round values, which confirms the reading.
- **On a fault.**
  - A high trip (over-voltage or over-current) turns FILAMENT_ON off at once and resets both
    timers; after the reset the warm-up starts again from zero.
  - A low trip leaves the filament on and drops the filament summary. The low latches also set at
    every cold start, because the readbacks start at zero, so a reset is needed once the filament
    is up.
  - The filament summary is in the klystron group of the global interlock sum, so a filament fault
    drops the station summary and the AB summary while the station is online (Section 4.6).
  - `rf_msgs` then opens the HVPS contactor. J. Sebek's fiber note adds: "If the filament trips
    off, the MPS will ultimately inhibit the thyristor triggers."

### 5.2 Jim's Monitor Chassis

- It works if its outputs match the meters' DC outputs in level and scale. The PLC-5 ends the ramp
  and applies its trips on these signals, so a scale error moves the operating point. Measure
  J1-E/F and J1-G/H at 68 V and 7.3 A before the change, and settle the T1 ratio (heater notes,
  open point 1).
- It serves either PLC. The ControlLogix conversion kit reuses the 1771 field-wiring arms, so the J1
  wiring lands on whichever PLC is in service.
- It decouples I5 from I4.
- It is what Doc 0 already specifies for the final system: the analog V/I meters stay and feed the
  MPS analog inputs, independent of the network.
- As a separate chassis it leaves the variac chassis intact as the fallback. Doc M I5 now puts the
  Genesys inside the variac chassis while naming that same chassis as the fallback.

### 5.3 The Ramp

The variac rises only while the PLC-5 holds MOTOR-UP, and it runs back to zero when FILAMENT_ON
drops. The program (11:7) holds MOTOR-UP during the first timer while the voltage and the current
are both below fixed constants, 100.0 V and 5.20 A in the 2012 file. If either falls back below
its constant during that time, MOTOR-UP comes on again; after it, never. The constants are in the
ladder, not in EPICS. They must have changed for the klystron installed in 2020, since 100 V is
above today's 76.2 V high trip, so today's values are not known (Section 6).

Two ways to drive the Genesys while the PLC-5 is in service:

1. The heater IOC ramps the Genesys over Ethernet, with FILAMENT_ON wired as the supply's hardware
   enable and MOTOR-UP unused. The program does not check that the voltage rises only with
   MOTOR-UP, so the PLC-5 does not fault; it only applies its trips. The ramp has to end inside the
   trip limits.
2. The new chassis turns MOTOR-UP into a slow rise of the Genesys program voltage, holds it when
   MOTOR-UP drops, and turns FILAMENT_ON off into zero. The PLC-5 then stops the ramp at its
   constants as it does with the variac, and later the ControlLogix running the legacy-faithful
   program does the same with no program change. The warm-up does not depend on the network.

## 6. Open Items

The PLC-5 program files close the first item of the earlier list: the DCM link handling, the
heartbeat, the filament ramp and the faults that drop the station and AB summaries (Sections 4.6,
5.1 and 5.3).

| Item | Needed for |
| --- | --- |
| Get the program in service (an upload from the processor, or the file of J. Sebek's 2021 change) and compare it with the 2012 file: ramp constants, timer split, filament limits and the logic of Section 4.6 | I5 chassis; PAMM test; legacy-faithful program (Doc M O8) |
| Read `SRF1:STN:DCM:MODU.LOCA` on the running IOC | PAMM test |
| Measure the heartbeat's period and duty cycle at the panel (Doc M O4) | Interface Chassis watchdog |
| Measure the J1 voltage and current monitor outputs at the operating point; settle the T1 ratio | Monitor chassis |
| Write the PAMM test procedure (Section 4.7) | I4 |

## 7. Proposed Doc M Changes (Not Made)

1. §4.3: replace "a node that stops answering sends its records to INVALID" with the behavior in
   Section 4.4: the PLC-5 values freeze while the IOC runs and are undefined after a reboot; the
   HVPS records go INVALID.
2. Table "SNL Bindings Relevant to the Migration": add `STN:SUMY:PLC`, `STN:LOCAL:ON`,
   `FILAMENT:SUMY:PLC` and the cavity vacuum records.
3. I4: make the PAMM node-removal test on the station (no IOC reboot) the entry test, and keep the
   test IOC for rehearsing the database change. State the Channel Access severity choice in SW5.
4. I5: add the monitor chassis; replace the hard prerequisite I4 with the PLC-5 filament logic
   (Section 5.1) and the ramp constants of the program in service; update the sequence table and
   figure.
5. O5 and O9: record what the program shows: the heartbeat's form and gating, the global interlock
   sum and the DCM handling. O5 keeps the measurement, O9 the comparison with the program in
   service.

## 8. Side Findings

1. Before an automatic reset, `rf_states` is meant to wait for the vacuum to pump down when the
   station vacuum summaries are in alarm. It reads the values of `STNVACM:SUMY:LTCH` and
   `STNVACM:SUMY:SEVR`, which are calc records with CALC "0". Their value is always 0, so the wait
   never runs; the alarm is carried in their severity, not their value.
2. `rf_msgs` logs "Filament OFF due to fault" when `FILAMENT:ON:PLC` drops while the AIM still
   requests the filament. That bit is the request line as the PLC-5 receives it, not the filament
   output, so the message reports the request lost between the AIM and the PLC-5. A PLC-5 high
   trip shows on `FILAMENT:LOW:PLC` instead.
3. Some PLC-5 inputs carry no interlock. The bucking-coil internal contact (input 026 on
   WD-340-330-23) is wired but not used, and the filament, degas and gauge inputs of the four
   cavity vacuum controllers are disabled by always-false rungs. The analog cavity-vacuum trips,
   eight pressure steps with delays from 900 s down to 1 s (files 31 to 34), latch bits that only
   EPICS reads; they are not in the global interlock sum.

## 9. Sources

| Source | Location |
| --- | --- |
| Off and on summaries | `spear-rf-code-legacy/rfApp/Db/rf_sumy_stn.db,v` |
| State machine: turn-on check, trip, vacuum wait | `spear-rf-code-legacy/rfApp/src/seq/rf_states.st,v` (near lines 1053, 1163, 1329) |
| DCM record, station reset, station status | `spear-rf-code-legacy/rfApp/Db/rf_stn.db,v` |
| DCM record support (LOCA) | `spear-rf-code-legacy/allenBradley/allenBradleyApp/1771DCMSrc/abDcmRecord.c,v` and `abDcmRecord.dbd,v` |
| Scanner driver | `spear-rf-code-legacy/allenBradley/allenBradleyApp/basicSrc/drvAb.c,v` |
| Allen-Bradley support documentation | `spear-rf-code-legacy/allenBradley/documentation/allenBradley.html,v` |
| PLC-5 bit, analog and adapter maps | `spear-rf-code-legacy/rfApp/Db/rf_digital_All.substitutions,v`, `rf_analog_All.substitutions,v`, `rf_ab_4CV.substitutions,v` |
| Message logger | `spear-rf-code-legacy/rfApp/src/seq/rf_msgs.st,v` |
| HVPS loop and cavity vacuum check | `spear-rf-code-legacy/rfApp/src/seq/rf_hvps_loop.st,v`, `rf_hvps_loop_pvs.h,v`; `rfApp/Db/rf_stn_cav.db,v` |
| AIM registers | `spear-rf-code-legacy/rfApp/src/db/p2RfAimDef.h,v`, `devP2RfAim.c,v` |
| Start-up and scanner configuration | `spear-rf-code-legacy/iocBoot/b132-iocrf/st.cmd,v`, `config.ab,v` |
| Filament warm-up change | `spear-rf-code-legacy/rfApp/Db/rf_klys.db,v`, revision 1.7 |
| RF MPS PLC-5 program, RSLogix 5 projects of 2011 and 2012; decoder and decoded listings | `llrf/allenBradley/*.RSP`, `rsp_decode.py`, `decoded/` |
| DCM analog scaling (13 bits) | `spear-rf-code-legacy/allenBradley/allenBradleyApp/1771DCMSrc/devAiAbDcmi2f.c,v` |
| RF MPS analog input #1, digital input #1 and digital output #1 | `llrf/documentation/mpsWiringDiagrams/wd3403302100.pdf`, `wd3403302300.pdf`, `wd3403302500.pdf` |
| Panel J3 to cross-connect map | `llrf/documentation/LocalPanelToXConnectMapping.xlsx` |
| Heater chassis and notes | `llrf/documentation/filamentHeater/sd3403110002.pdf`, `FILAMENT_HEATER_TECHNICAL_NOTES.md` |
| J. Sebek, LLRF documentation notes R2 (link cabling, AIM J15) | `llrf/documentation/LLRFDocumentationNotesR2.docx` |
| J. Sebek, fiber-optic signal control note Rev3 | `llrf/documentation/fiberOpticCableSignalControlRev3.docx` |
| Doc M: §4.3, I4, I5, SNL bindings table | `Designs/tex/docM-integration-migration/body.tex` |
| Doc 0: heater architecture | `Designs/tex/doc0-system-design/body.tex` |
