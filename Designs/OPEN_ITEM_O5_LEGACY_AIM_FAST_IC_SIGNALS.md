# Open Item O4 (was O5): Legacy AIM and Fast Interlock Chassis Signals

- **Status**: Partly resolved, 10 November 2026. The sense and loading of every J15 line and the
  use of the 17 other J15 lines follow from the schematics. The detector connections are confirmed
  by a cable check (F. Wang): rear J31 "RF AMPL." and J32 "RF INPUT" are cabled; the front BNC J16
  "DETECTED KLYSTRON POWER" has no cable. Still open: the pulse widths of the strobed commands, the
  detector's input level and transfer curve, and the Fast IC spare-fault input and the AIM arc
  cable (Section 7). Doc C was updated on 10 November 2026 (Section 10).
- **Tracked as**: Doc C O4. Related: Doc M O3 (Fast Interlock Chassis functions), Doc C O6 and
  Doc M O4 (heartbeat). These were Doc C O5 and O7 and Doc M O4 and O5 until 10 November 2026,
  when the beam-abort items (Doc C O4, Doc M O2) were closed and the later items renumbered.
- **Needed before**: the Interface Chassis production design (I2).
- **Prepared by**: F. Wang, 9 November 2026.
- **Basis**: the drawings, the decoded PLC-5 program, the legacy EPICS sources and the front-panel
  photo listed in Section 11.

---

## 1. The Item

Doc C O4 asks for three things:

1. The levels and sense of the J15 lines (six commands from the AIM, AB summary and heartbeat
   back to it).
2. The 17 other lines on J15 and how the Fast Interlock Chassis terminates them.
3. Which output of the Fast IC's klystron forward-power detector (J16 or J31) feeds the PLC-5, and
   the detector's input level and transfer curve.

## 2. Summary

| Question | Answer from the drawings | Still needed |
| --- | --- | --- |
| Sense of the six commands | Low = request, high or open = no request | Confirm in I0-T1 |
| Sense of the beam abort (pin 15) | Low = no abort, high or open = abort | Confirm in I0-T1 |
| Sense of AB summary (pin 10) | Low = no fault, high = fault | Confirm in I0-T1 |
| Sense of heartbeat (pin 23) | Low during each PLC-5 heartbeat pulse | Period and width (Doc C O6) |
| Pulse widths of strobed commands | Set inside the AIM FPGA; HVPS_ON is held | Measure at J15 |
| The 17 other lines | 3 AIM supply outputs, 2 grounds, 12 trip-test lines | Nothing; a design rule |
| Detector output to the PLC-5 | J31, the rear Burndy "RF AMPL.", pin A | Confirmed by the cable check |
| Detector input level and curve | Source chain known; detector model not on the drawing | Measure (bench or archive) |
| New: spare fault and arc cable | Spare-fault input in use; arc cable connected | Trace; read AIM fault enables |

## 3. J15 at Both Ends

The AIM's J3 ("status and test signals to Fast Interlock Chassis") is cabled to the Fast IC's J15,
pin for pin.

| Pin | Fast IC name | AIM name | Direction | Function |
| --- | --- | --- | --- | --- |
| 1 | FILAMENT_ON | FILAMENT_ON | AIM to Fast IC | Command (filament and focus request) |
| 14 | SOLENOID_ON | SOLENOID_ON | AIM to Fast IC | Command (station online request) |
| 2 | HVPS_ON | HVPS_ON | AIM to Fast IC | Command (HVPS on request) |
| 15 | BEAM_ABORT | ABORT (FPGA net ABORT-bar, inverted by the buffer) | AIM to Fast IC | VXI beam abort |
| 3 | FILAMENT_TIMEOUT | FILAMENT_TIMEOUT | AIM to Fast IC | Command (timeout bypass) |
| 16 | FAULT_RESET | FAULT_RESET | AIM to Fast IC | Command (reset) |
| 10 | AB_SUMMARY | AB_SUMMARY_FLT (FPGA net active low) | Fast IC to AIM | PLC-5 global interlock sum |
| 23 | HEART_BEAT | HEARTBEAT | Fast IC to AIM | PLC-5 heartbeat |
| 4 | +12V_I | FUSED_+12V | AIM to Fast IC | Supply |
| 5 | -12V_I | FUSED_-12V | AIM to Fast IC | Supply |
| 6 | +5V_I | FUSED_VDD | AIM to Fast IC | Supply |
| 17, 18 | GND | AGND, GND | Common | Ground |
| 19, 7, 20, 8, 21, 9, 22, 11, 24, 12, 25, 13 | TEST_CH1 to TEST_CH12 | TT0 to TT11 | AIM to Fast IC | Arc trip tests |

## 4. Levels and Sense

### 4.1 The commands (pins 1, 14, 2, 3, 16)

- **AIM**: the FPGA's outputs FILAMENT_ON, SOLENOID_ON, HVPS_ON, FILAMENT_TIMEOUT and FAULT_RESET
  leave through a 74ALS540 inverting buffer.
- **Fast IC input**: each line has a 2 kΩ pull-up to +5 V (the AIM's own +5 V, pin 6), a 74LS14
  Schmitt inverter towards the transmitter board, and a 74LS123 one-shot (200 kΩ, 3.3 µF) with a
  74F08 gate for its front-panel lamp.
- **Fast IC transmitter**: an SN75451B AND driver shunts the HFBR-1414 LED. The LED is lit while
  the driver's input, the 74LS14 output, is high, that is while the J15 line is **low**.
- **Panel**: the receivers read light as the request ("light = filament on", "light = solenoid on",
  "light = HVPS on request", "light = bypass timeout", "light = reset").
- **Result**: **low = request**; high or open (pulled up by the 2 kΩ) = no request. The Fast IC
  lamps DS-1 to DS-6 light while the line is low and stay lit about 0.25 s after a short low pulse.

### 4.2 The beam abort (pin 15)

- Same input stage and transmitter as the commands, so the fiber is lit while the line is low.
- **Panel**: "no light = abort" (receiver U10).
- **AIM**: the FPGA net is ABORT-bar (low on abort); the 74ALS540 inverts it, so the pin is high on
  abort. J. Sebek's name for this pin, ABORT_BAR, is the AIM's internal net name.
- **Result**: **low = no abort; high or open = abort**, fail-safe. The Fast IC lamp marked BEAM
  ABORT is lit while there is **no** abort (it mirrors the fiber).

### 4.3 AB summary (pin 10) and heartbeat (pin 23)

- **Panel transmitters**: the PLC-5's 24 V lines, through a 3.83 kΩ and 1 kΩ divider, drive the same
  SN75451B shunt circuit: the fiber is lit while the line is at 24 V. The panel marks the summary
  "light = no fault" and the heartbeat "normally pulsing".
- **Fast IC receivers**: HFBR-2412 with open-collector outputs and 1.0 kΩ pull-ups to +5 V; the
  output is low while light is received.
- **AIM inputs**: 10.0 kΩ to ground and a 74LS14 Schmitt inverter on each; pin 10 also has 1.0 µF
  to ground. The FPGA nets are AB_SUMMARY_FLT-bar (low on fault) and HEARTBEAT.
- **Result**: pin 10 **low = no fault, high = fault**; pin 23 is **low during each heartbeat pulse**.
  The chain is consistent end to end: a dark fiber gives a high pin and a fault at the AIM.
- **Caution**: with the J15 cable unplugged, the AIM's pull-down reads pin 10 low, that is no fault,
  so the AB summary latch (`STN:ABSUMY:LTCH`, which trips the station) stays clear. The heartbeat
  stops instead, and the AIM latches an AB heartbeat fault (`STN:ABHEART:LTCH`, a major alarm,
  not in the station's trip summary).

### 4.4 Strobed and held commands

- The device support (`devP2RfAim.c`) writes four control bits as strobes, 1 then 0: HVPS,
  FILTMOOVRD (timeout bypass), FLTRESET and RSTBMABT.
- The SNL can only write 1 to HVPS ("can only write 1"): the FPGA holds HVPS_ON on until its own
  fault logic clears it. So pin 2 is a held level.
- How long FAULT_RESET and FILAMENT_TIMEOUT stay low on J15 is set inside the FPGA, whose
  configuration is not in the workspace. The PLC-5 must see them for at least one scan, so they
  are long enough today; the Interface Chassis must not filter out the shortest of them.

### 4.5 Consequences for the Interface Chassis

- Command inputs: reproduce the Fast IC's load (2 kΩ pull-up to +5 V on the AIM side, Schmitt
  input), so that an open line reads as no request and an open pin 15 as abort.
- Outputs on pins 10 and 23: open-collector, or equivalent, with a 1.0 kΩ pull-up to +5 V, low
  for no fault, able to drive the AIM's 10 kΩ and, on pin 10, 1.0 µF (rise time about 1 ms).
- The AIM-side +5 V for these circuits can come from the chassis's own isolated supply, or from
  pin 6 as the Fast IC does; this is a design choice.

## 5. The 17 Other Lines

| Pins | What they are | Fast IC use | Interface Chassis |
| --- | --- | --- | --- |
| 4, 5, 6 | The AIM's fused supply outputs: +12 V, -12 V, +5 V (fuses F2, F3, F4 on the AIM) | Power the whole Fast IC, including its detector and amplifier; it has no supply of its own | Not connected, never back-fed (pin 6 only if chosen in 4.5) |
| 17, 18 | AIM grounds (AGND, GND) | Ground | Reference for the isolated J15 circuits |
| 7, 8, 9, 11, 12, 13, 19, 20, 21, 22, 24, 25 | AIM trip-test lines TT0 to TT11: active-low pulses from a 74HC154 decoder through 74ALS541 buffers | Lamps DS-7 to DS-18 and fiber transmitters J33 to J44 that send test light into the legacy arc fibers | Not needed; may be left unloaded (TTL outputs) |

So "terminated as the Fast Interlock Chassis terminates them" (Doc C IC-26) should become: supply
pins open, grounds as reference, trip-test lines unloaded.

A bench test of the spare Fast IC needs +12 V, -12 V and +5 V applied on J15 pins 4, 5 and 6.

## 6. Klystron Forward-Power Detector

### 6.1 RF source

- SD-340-330-01: klystron forward coupler (XKLY-CPLR FWD) → in-line 30 dB test coupler → 1/2 in
  Heliax → patch panel X700 J15 → 3 dB splitter X700-KLY → IQA channel 1 and, over 1/4 in Heliax,
  the Fast IC's RF input J32 (X310 RF_IN).
- The 2021 patch-panel record (`b132R11PatchPanel.xlsx`) adds two-way splitters (MCL
  ZAPD-900-5W-N+) to five signals, the klystron forward among them, for the LLRF9. Where that
  splitter sits relative to the legacy 3 dB split decides the level at J32.

### 6.2 Inside the Fast IC (SD-340-308-02, sheet 2)

- The detector is a separate module (B1, "RF_BOX"); its model is not on the drawing. It gives
  0 to -10 V.
- An AD712 inverting stage (1.0 kΩ, 1.0 kΩ, gain -1) gives 0 to +10 V:
  - to the rear Burndy connector J31 ("RF AMPL."), pin A signal and pin B ground, through 1.0 kΩ;
  - through a follower and another 1.0 kΩ to the front BNC J16 ("DETECTED KLYSTRON POWER").
- The detector and amplifier run on the AIM's ±12 V from J15 (Section 5).

### 6.3 Which output feeds the PLC-5

- WD-340-330-22: analog input #2 (rack 4, slot 10), channel 12 "RF PWR LEVEL", comes from
  "X7-ARC-RFAMP" pin A through cross-connects X513-01 and X517-012. That is **J31**.
- The front-panel photo shows no cable on J16, which is a monitor output. The cable check of
  10 November 2026 confirms it: J31 "RF AMPL." and J32 "RF INPUT" on the rear are cabled, and the
  front BNC J16 "DETECTED KLYSTRON POWER" is not used.

### 6.4 What the PLC-5 assumes

- The program computes P = (0.017 c)² kW for c counts. With 4095 counts at 10 V this is
  V = 0.144 √P, P in kW: 3.2 V at 500 kW, 4.5 V at 1 MW, 5.6 V at 1.5 MW. RF counts as detected
  above 175 counts (0.43 V, about 9 kW).
- EPICS carries the raw count as `SRF1:KLYSPLC:POWER` (counts, PLC-5 analog input #2 channel 12)
  and the PLC-5's collector power as `SRF1:KLYSCOLLPLC:POWER`. The IOC's own calibrated klystron
  forward power is `SRF1:KLYSOUTFRWD:POWER`.

### 6.5 Still unknown, and how to get it

- The detector model, the RF level at J32 and the actual transfer curve, with its temperature
  stability.
- **Archive, no hardware**: plot `SRF1:KLYSPLC:POWER` against `SRF1:KLYSOUTFRWD:POWER` over turn-ons
  and ramps. This gives the curve from klystron power to counts, which is what the replacement
  detector must reproduce (Doc C IC-35).
- **Bench**: the spare Fast IC with its supplies on J15 (Section 5), a 476 MHz source on J32 and a
  voltmeter on J31; plus one power-meter reading on the J32 cable at a known klystron power.

## 7. New Sub-item: Spare-Fault Input and the Arc Cable

- **Arc cable**: the Fast IC's J2 (37-pin) is cabled to the AIM's J4 ("arc signals from Fast
  Interlock Chassis"). It carries 12 differential arc signals ARC±0 to ARC±11 to the AIM, the
  spare-fault line SPARE_FLT (pin 34) to the AIM, and the AIM's fused +5 V (pin 36) to the Fast IC.
  The front-panel photo shows this cable connected.
- **Spare-fault input**: the Fast IC's front LEMO "SPARE FAULT" (J1) drives a 6N138 optocoupler.
  It trips on a low input (0.5 to 40 mA, at most 24 V); its output, with a 270 Ω pull-up, makes
  SPARE_FLT high on a fault. The AIM pulls the line up with 10.0 kΩ and reads it through a 74LS14
  as SPARE_FLT-bar. **The photo shows a cable on the SPARE FAULT connector**; its source is not
  documented anywhere in the workspace.
- **Consequence at I2**: removing the Fast IC leaves the AIM's J4 open. The AIM's pull-up then
  reads a spare fault, and the arc inputs float. If the spare or any arc channel is enabled in the
  AIM's fault-enable register, the legacy station trips (the AIM drops HVPS_ON). Whatever drives the
  spare input also loses its path to the AIM.
- **Needed**:
  1. Trace the cable on SPARE FAULT and record what it carries.
  2. Read the AIM's fault-enable state (the "Arc Fault Enable Status" of the AIM record).
  3. Decide: either bring that source into the Interface Chassis as an expansion permit (X3 or X4)
     and disable the AIM's spare and arc channels before I2, or have the chassis present J2 to the
     AIM in the no-arc, no-fault state.
- This overlaps Doc M O3 ("whether any AIM input depends on the chassis; which AIM arc channels are
  enabled").

## 8. Corrections Found in Other Documents

- Doc L (the paragraph on the klystron and the caption of the Fast IC front-panel figure) and Doc I
  (the external-interfaces table and the Fast IC description) called J16 an input. It is the front
  monitor output of the detector; the RF input is J32 at the rear. Both corrected on 10 November
  2026, together with Doc I's list of the front panel, which named lamps as buttons.
- Doc I had the Fast IC make the arc decision: analog comparators, a "status word" to the AIM, a
  reflected-power input, a front-panel FAULT RESET button and an on-board fast ADC. The schematics
  put the comparators, their DAC thresholds, the latches and the fast ADC on the AIM; the Fast IC
  sends peak-detected analog signals over the 37-pin cable, has no reflected-power input, and its
  FAULT RESET is a lamp. Doc I also read the forced fault as a hard-arc latch; it is set from
  EPICS (`STN:AIM:FRCFLT`). All corrected in Doc I on 10 November 2026 (new reference R32).
- J. Sebek's LLRF notes say "the AB Summary status is a low frequency pulsed signal". On the panel
  it is the heartbeat that pulses; the summary is lit for no fault.
- The AIM schematic marks HEARTBEAT "(2Hz)". The PLC-5 program pulses it after a 50 ms timer (one
  scan wide, about every 50 ms plus a scan). This belongs to Doc C O6 and Doc M O4.

## 9. Measurements for I0

1. Levels of all eight functional J15 lines in each station state, with a breakout at the Fast IC.
2. Widths of the FAULT_RESET and FILAMENT_TIMEOUT pulses on J15; HVPS_ON held until a fault.
3. Period and width of the heartbeat on pin 23 (with Doc C O6).
4. Continuity from J31 to PLC-5 analog input #2, channel 12.
5. RF power at the J32 cable at a known klystron power; the archive comparison of Section 6.5.
6. The spare-fault cable and the AIM fault-enable state (Section 7).

## 10. Updates to Doc C (applied 10 November 2026)

- J15 table: an "active on J15" column with the senses of Section 4, and rows for the supply pins,
  the grounds and the trip-test lines.
- IC-25: the loads and senses of Section 4; IC-26: supply pins not connected, grounds as reference,
  trip-test lines not used; a paragraph on the Fast IC connections that are not taken over and on
  disabling the AIM's arc channels and spare fault before I2.
- Electrical classes, TTL in and TTL out: the loads of Section 4.5.
- IC-35: output for the J31 cable (pin A signal, pin B ground), 0 to +10 V through 1 kΩ,
  0.144 V per √kW on the PLC-5's scale; no front monitor output.
- X530: only the lines that the panel's logic, fibers, analog buffers and key switches use are
  taken over, renumbered P1 to P12; the lines the panel only shows on its LEDs (main focus on,
  filament, timeout, HV detected, bucking coil on, RF detected, the other 13 area summaries and the
  spares) are not connected, since the PLC-5 reports them to EPICS.
- O5: narrowed to the hardware confirmation, the pulse widths, the detector input level and curve,
  and the spare-fault input with the AIM's enables.

## 11. Sources

Drawings:

- Fast Interlock Chassis receiver board SD-340-308-02, sheet 1 (J15, J2, display block with J16,
  J31, J32) and sheet 2 (command inputs, AB summary and heartbeat receivers, spare-fault input,
  detector amplifier): [SD-340-308-02-R1.pdf](../llrf/documentation/legacyInterfaceModules/SD-340-308-02-R1.pdf)
- Fast Interlock Chassis transmitter board SD-340-308-01 (SN75451B and HFBR-1414 transmitters,
  J45 to J50 commands, J33 to J44 test channels):
  [SD-340-308-01-R1-1of1.pdf](../llrf/documentation/legacyInterfaceModules/SD-340-308-01-R1-1of1.pdf)
- AIM SD-340-309-01, page 18 (J3 and J4 connectors, 74ALS540 and 74ALS541 drivers, 74LS14 input
  receivers, fuses F2 to F4), pages 6 and 7 (FPGA and its configuration PROM), page 15 (front-panel
  LEDs): [sd3403090102.pdf](../llrf/documentation/legacyInterfaceModules/sd3403090102.pdf)
- RF Local Display Panel SD-340-311-01, sheet 2 (fiber receivers) and sheet 8 (fiber
  transmitters): [sd3403110100.pdf](../llrf/documentation/localPanel/sd3403110100.pdf)
- WD-340-330-22, PLC-5 analog input #2:
  [wd3403302200.pdf](../llrf/documentation/mpsWiringDiagrams/wd3403302200.pdf)
- WD-340-330-29, panel fibers:
  [wd3403302900.pdf](../llrf/documentation/mpsWiringDiagrams/wd3403302900.pdf)
- SD-340-330-01, coax cable plant: [sd3403300100.pdf](../llrf/documentation/coaxCables/sd3403300100.pdf)
- B132-11 patch panel, 2021: [b132R11PatchPanel.xlsx](../llrf/calibrations/b132R11PatchPanel.xlsx)
- Fast IC front-panel photo: [interlocak_chassis_front.jpg](tex/common/photos/interlocak_chassis_front.jpg)

Programs and records:

- PLC-5 program, decoded 2012 file (RF power `CPT` with 0.017, HV and RF detection thresholds,
  heartbeat timer T4:19, base 0.01 s, preset 5):
  [20120206_SP3RF_MODIFIED_FOCUS1_LOWER_VOLT_LIMIT.txt](../llrf/allenBradley/decoded/20120206_SP3RF_MODIFIED_FOCUS1_LOWER_VOLT_LIMIT.txt)
- [devP2RfAim.c,v](../spear-rf-code-legacy/rfApp/src/db/devP2RfAim.c,v) (strobed bits) and
  [rf_states.st,v](../spear-rf-code-legacy/rfApp/src/seq/rf_states.st,v) ("aimon ... can only
  write 1").
- [rf_analog_All.substitutions,v](../spear-rf-code-legacy/rfApp/Db/rf_analog_All.substitutions,v)
  (`KLYSPLC:POWER`, counts) and [rf_klys.db,v](../spear-rf-code-legacy/rfApp/Db/rf_klys.db,v)
  (`KLYSCOLLPLC:POWER`, `KLYSCOLL:POWER`, `KLYSOUTFRWD:POWER`).

Notes:

- J. Sebek, LLRF documentation notes R2 (`llrf/documentation/LLRFDocumentationNotesR2.docx`): J15
  and J2 of the Fast IC, J16 and J31 as front and rear detector outputs.
- J. Sebek, RF power detector chassis (`llrf/architecture/rfPowerDetector.docx`): the planned
  replacement detector.
