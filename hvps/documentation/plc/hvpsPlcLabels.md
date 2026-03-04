# hvpsPlcLabels

> **Source:** `hvps/documentation/plc/hvpsPlcLabels.xlsx`
> **Format:** XLSX (converted to Markdown for AI readability)


## Sheet: binary inputs

| PLC Code Tag | Identifier | Function | Indicator  (Normal Op) |
| --- | --- | --- | --- |
| I:2/0 | 1-B3:12/0 | 120 VAC Control Power | On |
| I:2/1 | 1-B3:12/1 | A Phase Reference Voltage | On |
| I:2/2 | 1-B3:12/2 | Filter Inductor 1 | Off |
| I:2/3 | 1-B3:12/3 | Filter Inductor 2 | Off |
| I:6/0 | 1-B3:13/0 | SCR Disable Fiber Drive | Off |
| I:6/1 | 1-B3:13/1 | Crowbar Enable | Off |
| I:6/2 | 1-B3:13/2 | Crowbar Monitor | On |
| I:6/3 | 1-B3:13/3 | Klystron Arc Monitor | On |
| I:6/4 | 1-B3:13/4 | SCR Trigger 1 | Off |
| I:6/5 | 1-B3:13/5 | Transformer Arc Monitor | On |
| I:6/6 | 1-B3:13/6 | SCR Trigger 2 | Off |
| I:6/7 | 1-B3:13/7 | RF Crowbar | On |
| I:6/8 | 1-B3:13/8 | Ground Tank Oil Level | On |
| I:6/9 | 1-B3:13/9 | Ground Tank Switch | On |
| I:6/10 | 1-B3:13/10 | Crowbar Oil Level | On |
| I:6/11 | 1-B3:13/11 | SCR Oil Level | On |
| I:6/12 | 1-B3:13/12 | Key/Emergency Off Switch | On |
| I:6/13 | 1-B3:13/13 | Emergency Off | On |
| I:6/14 | 1-B3:13/14 | PPS 1 | On |
| I:6/15 | 1-B3:13/15 | PPS 2 | On |
|  |  |  |  |
| I:7/0 |  | Contactor Blocking Relay | Off |
| I:7/1 |  | Contactor Overcurrent Relay | Off |
| I:7/2 |  | Contactor Closed | On |
| I:7/3 |  | Contactor Ready | Off |
| I:7/4 |  | Transformer Pressure | On |
| I:7/5 |  | Transformer Vacuum | On |
| I:7/6 |  | Transformer Over Temperature | On |
| I:7/7 |  | Transformer Oil Level | On |
| I:7/8 |  | Transformer Sudden Pressure | On |
| I:7/9 |  | Oil Pump On | Off |
| I:7/10 |  | Spare | On |
| I:7/11 |  | Enerpro Phase Loss | On |
| I:7/12 |  | Regulator Current Limit | Off |
| I:7/13 |  | Ground Tank Relay | On |
| I:7/14 |  | Regulator Voltage Trip | Off |
| I:7/15 |  | Regulator Current Trip | Off |


## Sheet: binary outputs

| PLC Code Tag | Identifier | Function | Indicator  (Normal Op) |
| --- | --- | --- | --- |
| O:2/0 |  | AC Bias Power Supply | On |
| O:2/1 |  | 120 VDC Power Supply | On |
| O:2/2 |  | 240 VDC Power Supply | On |
| O:2/3 |  | Ground Tank Relay Coil | On |
| O:5/0 |  | SCR Enable | On |
| O:5/1 |  | Contactor On | On |
| O:5/2 |  | Contactor Enable | On |
| O:5/3 |  | Force Crowbar | Off |
| O:5/4 |  | Crowbar Off | On |
| O:5/5 |  | Enerpro Slow Start | Off |
| O:5/6 |  | Enerpro Fast Inhibit | On |
| O:5/7 |  | Regulator Reset | Off |


## Sheet: binary bits summary

| Register |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| B3:0 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 |
| B3:1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| B3:2 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 0 | 1 | 1 | 1 |
| B3:3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| B3:4 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |


## Sheet: B3_0

| Register B3:0 |  |  |  |
| --- | --- | --- | --- |
|  |  |  |  |
| Bit No. | Hex | Label | Rungs Set |
| 15 | 8000 | Contactor Ready | 30 |
| 14 | 4000 | Alarm Reset | 1,7, 14, 20, 21, 22, 23, 24, 25, 26, 28, 29, 37 |
| 13 | 2000 | Fast Inhibit | 10, 13 |
| 12 | 1000 |  |  |
| 11 | 800 |  |  |
| 10 | 400 | Reset | 1 |
| 9 | 200 | No Xformer Fault | 61 |
| 8 | 100 | Contactor Latch | 2 |
| 7 | 80 |  |  |
| 6 | 40 | Enable | 17 |
| 5 | 20 |  |  |
| 4 | 10 | SCR On Latch | 4 |
| 3 | 8 |  |  |
| 2 | 4 | Regulator On | 10 |
| 1 | 2 |  |  |
| 0 | 1 | Off Display | 16 |


## Sheet: B3_1

| Register B3:1 |  |  |  |
| --- | --- | --- | --- |
|  |  |  |  |
| Bit No. | Hex | Label | Rungs Set |
| 15 | 8000 | Supply On | 74 |
| 14 | 4000 | SCR On | 74 |
| 13 | 2000 | System Ready | 3 |
| 12 | 1000 | 12kV On | 38 |
| 11 | 800 | Contactor Closed Disp | 33 |
| 10 | 400 | Contactor Ctrl Pwr Display | 40 |
| 9 | 200 | Enable Display | 17 |
| 8 | 100 | Aux Pwr On Display | 63 |
| 7 | 80 | Crowbar On | 37 |
| 6 | 40 | SCR Off | 75 |
| 5 | 20 | System Not Ready | 34 |
| 4 | 10 | 12kV Off | 39 |
| 3 | 8 | Contactor Open Disp | 31 |
| 2 | 4 | Disable Display | 64 |
| 1 | 2 | PPS On | 15 |
| 0 | 1 | Emergency Off | 14 |


## Sheet: B3_2

| Register B3:2 |  |  |  |
| --- | --- | --- | --- |
|  |  |  |  |
| Bit No. | Hex | Label | Rungs Set |
| 15 | 8000 |  |  |
| 14 | 4000 |  |  |
| 13 | 2000 |  |  |
| 12 | 1000 |  |  |
| 11 | 800 |  |  |
| 10 | 400 |  |  |
| 9 | 200 |  |  |
| 8 | 100 |  |  |
| 7 | 80 | Water Flow Switch | 50 |
| 6 | 40 | Klystron Crowbar Latch | 48 |
| 5 | 20 | Klystron SCR Bit | 49 |
| 4 | 10 | Klystron Crowbar | 56 |
| 3 | 8 | Phase Loss | 51 |
| 2 | 4 | Contactor OK | 58 |
| 1 | 2 | Xformer Latched OK | 60 |
| 0 | 1 | Ground Switch Open | 73 |


## Sheet: B3_3

| Register B3:3 |  |  |  |
| --- | --- | --- | --- |
|  |  |  |  |
| Bit No. | Hex | Label | Rungs Set |
| 15 | 8000 | SCR Driver Up Latch | 26 |
| 14 | 4000 |  |  |
| 13 | 2000 | SCR Driver Latch | 25 |
| 12 | 1000 | Contactor Over Current Alarm | 24 |
| 11 | 800 | Emergency Off Alarm | 14 |
| 10 | 400 | Aux Power Alarm | 28 |
| 9 | 200 | Regulator Trip | 29 |
| 8 | 100 | Contactor Alarm | 20 |
| 7 | 80 | Xformer Alarm | 21 |
| 6 | 40 | Regulator Over Voltage | 23 |
| 5 | 20 | Regulator Over Current | 22 |
| 4 | 10 |  |  |
| 3 | 8 |  |  |
| 2 | 4 | Open Load Latch | 7 |
| 1 | 2 | Crowbar | 37 |
| 0 | 1 | Alarm | 19 |


## Sheet: B3_4

| Register B3:4 |  |  |  |
| --- | --- | --- | --- |
|  |  |  |  |
| Bit No. | Hex | Label | Rungs Set |
| 15 | 8000 | Xformer Arc Trip | 57 |
| 14 | 4000 | Ground Tank Oil Level | 52 |
| 13 | 2000 | Klystron Arc Trip | 55 |
| 12 | 1000 | Over Voltage Latch | 54 |
| 11 | 800 | Over Current Latch | 53 |
| 10 | 400 | Crowbar Latch | 13 |
| 9 | 200 | SCR 2 Latch | 72 |
| 8 | 100 | SCR 1 Latch | 71 |
| 7 | 80 | Oil Pump Flow | 47 |
| 6 | 40 | DC Power Fault | 59 |
| 5 | 20 | Over Current Trip Latch | 58 |
| 4 | 10 | Sudden Pressure | 46 |
| 3 | 8 | Low Oil | 45 |
| 2 | 4 | SCR Oil Tank Level | 44 |
| 1 | 2 | Oil Temp | 43 |
| 0 | 1 | Pressure Latch | 41 |


## Sheet: B3_5

| Register B3:5 |  |  |  |
| --- | --- | --- | --- |
|  |  |  |  |
| Bit No. | Hex | Label | Rungs Set |
| 15 | 8000 |  |  |
| 14 | 4000 |  |  |
| 13 | 2000 |  |  |
| 12 | 1000 | Vacuum Latch | 42 |
| 11 | 800 | SCR 2 Status | 71 |
| 10 | 400 | SCR 1 Status | 72 |
| 9 | 200 |  |  |
| 8 | 100 |  |  |
| 7 | 80 |  |  |
| 6 | 40 |  |  |
| 5 | 20 |  |  |
| 4 | 10 |  |  |
| 3 | 8 | Enerpro Phase Loss | 1, 116 |
| 2 | 4 |  |  |
| 1 | 2 |  |  |
| 0 | 1 |  |  |


## Sheet: touch panel interlocks

| PLC Code Tag | Identifier | Function  All illuminated OK during normal op |
| --- | --- | --- |
|  | 1-B3:4/11 | AC Overcurrent Fault |
|  | 1-B3:3/6 | DC Overvoltage OK |
|  | 1-B3:3/5 | DC Overcurrent OK |
|  | 1-B3:13/8 | Ground Tank Oil Fault |
|  | 1-B3:1/0 | Ground Tank E-Stop OK |
|  | 1-B3:1/7 | Crowbar OK |
|  | 1-B3:4/13 | Klystron Arc Fault |
|  | 1-B3:4/15 | Transformer Arc Fault |
|  | 1-B3:2/4 | Klystron Crowbar Fault |
|  | 1-B3:3/2 | Open Load OK |
|  | 1-B3:3/14 | H1 SCR Drivers OK |
|  | 1-B3:3/15 | H2 SCR Drivers OK |
|  | 1-B3:13/11 | SCR Oil Level Low |
|  | 1-B3:13/10 | Crowbar Oil Level Low |
|  | 1-B3:14/7 | Main Tank Oil Level Low |
|  | 1-B3:14/6 | Oil Temperature Fault |
|  | 1-B3:2/7 | Oil Flow Switch Fault |
|  | 1-B3:14/4 | Pressure Fault |
|  | 1-B3:14/8 | Relief Valve Fault (Sudden Pressure?) |
|  | 1-B3:14/5 | Vacuum Fault |
|  | 1-B3:0/3 | Summary Not Ready |
|  | 1-B3:5/12 | Vacuum Fault |
|  | 1-B3:4/10 | Pressure Fault Latched |
|  | 1-B3:4/1 | Oil Temperature Fault Latched |
|  | 1-B3:4/2 | SCR/Crowbar Oil Level Low Latched |
|  | 1-B3:4/3 | Main Tank Oil Level Low Latched |
|  | 1-B3:4/4 | Sudden Pressure Fault Latched |


## Sheet: analog registers

| PLC Code Tag | Identifier | Function | Value  (500 mA,  2850 kV) | Rungs |
| --- | --- | --- | --- | --- |
| N7:0 | 1-N7:0 | Requested DC Volts (kV) | 7080 |  |
| N7:1 | 1-N7:1 | Phase Angle | 442 |  |
| N7:2 | 1-N7:2 | Regulator Voltage | 7497 | 84, 85, 87 |
| N7:3 | 1-N7:3 | Phase Angle Monitor | 354 | 88, 89 |
| N7:4 | 1-N7:4 | AC Amps | 36, should be 1036.  Format error on display? | 90, 91, 92, 93 |
| N7:5 | 1-N7:5 | Volt Monitor 1 | 75, should be ~7500.  Format error on display? |  |
| N7:6 | 1-N7:6 | Volt Monitor 2 | 7399 |  |
| N7:7 | 1-N7:7 | DC Amps | 2187 |  |
| N7:8 | 1-N7:8 | Power | 1783 |  |
| N7:9 | 1-N7:9 | AC Amp Offset | -117 | 78 |
| N7:10 | 1-N7:10 | Reference Out  (EL1 input on regulator) | 23167 | 11, 92, 104, 105, 106, 108, 112 |
| N7:11 | 1-N7:11 | Phase Out  (PLC contribution to SIG HI) | 14488 |  |
| N7:12 | 1-N7:12 | Feedback Voltage | 24375 | 76, 77, 84 |
| N7:13 | 1-N7:13 | Phase Ang Monitor  (SIG HI input on Enerpro) | 11585 | 88 |
| N7:14 | 1-N7:14 | AC Current Monitor | 7374 | 08, 78, 79, 90, 93 |
| N7:15 | 1-N7:15 | Voltage Monitor 1 | 24438 | 08, 80, 86, 92, 95, 98 |
| N7:16 | 1-N7:16 | Voltage Monitor 2 | 24215 | 08, 81, 100 |
| N7:17 | 1-N7:17 | DC Current Monitor | 14330 | 08, 82, 83, 92, 94, 95, 102 |
| N7:18 | 1-N7:18 | Power Calculation | 10724 | 95, 96, 97, 114 |
| N7:19 | 1-N7:19 | Offset Feedback | -122 | 76 |
| N7:20 | 1-N7:20 | Output Reference Multiplier | 10000 |  |
| N7:21 | 1-N7:21 | Phase Angle Multiplier | 1000 |  |
| N7:22 | 1-N7:22 | Voltage Multiplier | 75, should be 10075.  Format error on display? | 84 |
| N7:23 | 1-N7:23 | Phase Angle Multiplier | 1000 |  |
| N7:24 | 1-N7:24 | AC Current Multiplier | 4600 |  |
| N7:25 | 1-N7:25 | Voltage Monitor 1 Multiplier | 10000 |  |
| N7:26 | 1-N7:26 | Voltage Monitor 2 Multiplier | 10000 |  |
| N7:27 | 1-N7:27 | DC Current Multiplier | 5000 |  |
| N7:28 | 1-N7:28 |  |  |  |
| N7:29 | 1-N7:29 | Power Multiplier | 6 |  |
| N7:30 | 1-N7:30 | External Reference | 23134 | 104 |
| N7:31 | 1-N7:31 | Internal Reference | 100 | 104, 105 |
| N7:32 | 1-N7:32 | Max Internal Reference | 32000 | 92, 105 |
| N7:33 | 1-N7:33 | Max External Reference | 26869 | 92, 104 |
| N7:34 | 1-N7:34 | Plot Volts | 174 |  |
| N7:35 | 1-N7:35 | Plot Current | 148 |  |
| N7:36 | 1-N7:36 | Plot Power | 10075 |  |
| N7:37 | 1-N7:37 | Display Volts | 76 |  |
| N7:38 | 1-N7:38 | Display Current | 72 |  |
| N7:39 | 1-N7:39 | Display Power | 66 |  |
| N7:40 | 1-N7:40 | Phase Angle Multiplier | 12000 |  |
| N7:41 | 1-N7:41 | Add Offset | 6000 |  |
| N7:42 | 1-N7:42 | Max Phase Angle | 18000 |  |
| N7:43 | 1-N7:43 | Delta | 0 |  |
| N7:44 | 1-N7:44 | Div Plot Volts | 43 |  |
| N7:45 | 1-N7:45 | Div Plot Current | 7 |  |
| N7:46 | 1-N7:46 | Div Plot Power | 260 |  |
| N7:47 | 1-N7:47 | Div Meter Volts | 320 |  |
| N7:48 | 1-N7:48 | Div Meter Current | 198 |  |
| N7:49 | 1-N7:49 | Div Meter Power | 162 |  |
|  |  |  |  |  |
| N7:71 |  | Maximum voltage (loaded at startup?) | 32000 | 105 |
| N7:72 |  | Maximum phase angle (loaded at startup?) | 18000 | 105 |
| N7:73 |  | Internal reference (loaded at startup?) | 100 | 105 |
| N7:74 |  | Maximum voltage divided by Reference out |  | 105 |
| N7:75 |  | Internal reference divided by Reference out |  | 105 |
|  |  |  |  |  |
|  |  |  |  |  |
| N7:110 | 1-N7:110 | Temp Sense Ch 0  (Phase Upper TC?) | 55 |  |
| N7:111 | 1-N7:111 | Temp Sense Ch 1  (Phase Lower TC?) | 56 |  |
| N7:112 | 1-N7:112 | Temp Sense Ch 2  (Crowbar Tank?) | 40 |  |
| N7:113 | 1-N7:113 | Temp Sense Ch 3  (Control Cabinet?) | 32 |  |
|  |  |  |  |  |
| Fuel Gauges |  |  |  |  |
|  |  | Volts KV | 74.97 |  |
|  |  | Amps DC | 21.91 |  |
|  |  | Amps Line AC | 103.6 |  |


## Sheet: analog inputs

| Module | Slot | Number | Function |
| --- | --- | --- | --- |
| AB-1746-NIO4V | 8 | 0 | Output voltage monitor from regulator card (J3-1) |
| AB-1746-NIO4V | 8 | 1 | Readback of phase control voltage to Enerpro input (SIG HI) |
| AB-1746-NI4 | 9 | 0 | Input AC current monitor from regulator card (J3-2) |
| AB-1746-NI4 | 9 | 1 | Output voltage monitor 1 from HVPS (splits to J1-1 of reg) |
| AB-1746-NI4 | 9 | 2 | Output voltage monitor 2 from HVPS |
| AB-1746-NI4 | 9 | 3 | Output DC current monitor (Danfysik) from grounding tank |


## Sheet: analog outputs

| Module | Slot | Number | Function |
| --- | --- | --- | --- |
| AB-1746-NIO4V | 8 | 0 | Reference voltage setpoint to regulator card input (EL1) |
| AB-1746-NIO4V | 8 | 1 | Contribution to SIG HI phase control input of Enerpro (1k res) |


## Sheet: inputs from VXI DCM

| Bank | Register | Function |
| --- | --- | --- |
| I:1 | 1 | External Reference from VXI DCM |
| I:1 | 2 | Maximum External Reference from VXI DCM |


## Sheet: outputs to VXI DCM

| Bank | Register | Function |
| --- | --- | --- |
| O:1 | 1 | AC Current to VXI DCM |
| O:1 | 2 | Reference Out Voltage to EL1 to VXI DCM |
| O:1 | 3 | HVPS Voltage Monitor 1 to VXI DCM |
| O:1 | 4 | HVPS Current Monitor (Danfysik) to VXI DCM |
| O:1 | 5 | Maximum Internal Voltage Reference to VXI DCM |


## Sheet: SPEAR RF Klystron HVPS EPICS

| Label | Value | Device Type | Raw Value | HW Mask | ESLO | VAL |  | Decimal (may include extra 32768) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Contactor Closed | CLOSED | AB-16 bit BI | 0x20 | 0x20 |  |  |  |  |
| Contactor Open | CLOSED | AB-16 bit BI | 0x0 | 0x80 |  |  |  |  |
| Contactor Status | ON | AB-16 bit BI | 0x40 | 0x40 |  |  |  |  |
| Contactor Ready | READY | AB-16 bit BI | 0x100 | 0x100 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| Klys Output Pwr | 747 | IQA Module 1 Calc |  |  |  |  |  |  |
| Klys Coll Pwr | 843 | Calc |  |  |  |  |  |  |
| Klys Efficiency | 46.94 | Calc |  |  |  |  |  |  |
| RF PLC Voltage | 72.4 | AB-1771DCM AI-13 bit raw | 0x1B0A |  | 0.02442 | 72.5 |  | 6922 |
| RF PLC Current | 22.09 | AB-1771DCM AI-13 bit raw | 0x1711 |  | 0.01221 | 22.09 |  | 5905 |
| RF PLC Coll Pwr | 973 | Calc |  |  |  |  |  |  |
| Klys Perveance | 1.13 | Calc |  |  |  |  |  |  |
| HVPS Current | 21.92 | AB-SLC500DCM-Signed | 0xB81E |  | 0.00153 | 21.92 |  | 47134 |
| HVPS Voltage | 72.47 | AB-SLC500DCM-Signed | 0xDCD3 |  | 0.00305 | 72.52 |  | 56531 |
| HVPS Power | 1589 | Calc |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| Max Volt Status | ACTIVE | AB-16 bit BI | 0x1 | 0x1 |  |  |  |  |
| Regulator Voltage | 72.28 | AB-SLC500DCM-Signed | 0xDC83 |  | 0.00305 | 72.29 |  | 56451 |
| Max Voltage Rbck | 82 | AB-SLC500DCM-Signed | 0xE8F5 |  | 0.00305 | 82 |  | 59637 |
|  |  |  |  |  |  |  |  |  |
| Over Voltage | OK | AB-16 bit BI | 0x2 | 0x2 |  |  |  |  |
| Klystron Arc | OK | AB-16 bit BI | 0x10 | 0x10 |  |  |  |  |
| Transformer Arc | OK | AB-16 bit BI | 0x400 | 0x400 |  |  |  |  |
| Crowbar | OK | AB-16 bit BI | 0x0 | 0x200 |  |  |  |  |
| Crowbar from RF | OK | AB-16 bit BI | 0x800 | 0x800 |  |  |  |  |
| Emergency Off | OK | AB-16 bit BI | 0x0 | 0x800 |  |  |  |  |
| AC Current | OK | AB-16 bit BI | 0x8 | 0x8 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| Over Temperature | OK | AB-16 bit BI | 0x1 | 0x1 |  |  |  |  |
| Oil Level | OK | AB-16 bit BI | 0x4000 | 0x4000 |  |  |  |  |
| Transformer Press | OK | AB-16 bit BI | 0x40 | 0x40 |  |  |  |  |
| Transfmr Vac/Press | OK | AB-16 bit BI | 0x80 | 0x80 |  |  |  |  |
| Open Load | OK | AB-16 bit BI | 0x0 | 0x200 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| AC Current | 113.29 | AB-SLC500DCM-Signed | 0x9D09 |  | 0.01526 | 113.43 |  | 40201 |
| 12 kV Available | AVAIL | AB-16 bit BI | 0x2 | 0x2 |  |  |  |  |
| AC Auxiliary Pwr | ON | AB-16 bit BI | 0x4 | 0x4 |  |  |  |  |
| DC Auxiliary Pwr | ON | AB-16 bit BI | 0x400 | 0x400 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| Enerpro Fast Inhibit | ON | AB-16 bit BI | 0x1000 | 0x1000 |  |  |  |  |
| Enerpro Slow Start | ACTIVE | AB-16 bit BI | 0x0 | 0x2000 |  |  |  |  |
| Supply Status | ON | AB-16 bit BI | 0x10 | 0x10 |  |  |  |  |
| Supply Ready | READY | AB-16 bit BI | 0x20 | 0x20 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| PPS | PERMIT | AB-16 bit BI | 0x0 | 0x100 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| SCR 1 | ON | AB-16 bit BI | 0x4 | 0x4 |  |  |  |  |
| SCR 2 | ON | AB-16 bit BI | 0x8 | 0x8 |  |  |  |  |


## Sheet: DCM-FULL bits

|  |  |  |  |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
| 0002, 0006 | I1 | 48 | Remote On/Off |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
| 0004, 0009 | I:1 | 64 | Control Enable |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
| 115 | I:1 | 80 | Control reset |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
| 104 | O:1 | 96 | (overflow? x3) |
| 38 | O:1 | 97 | 12kV on |
| 62 | O:1 | 98 | AC aux power on |
| 53 | O:1 | 99 | AC current trip |
| 55 | O:1 | 100 | (klystron) Arc trip |
| 32 | O:1 | 101 | Contactor closed |
| 30 | O:1 | 102 | Contactor enable |
| 31 | O:1 | 103 | Contactor open |
| 40 | O:1 | 104 | Contactor ready |
| 37 | O:1 | 105 | Crowbar on |
| 63 | O:1 | 106 | Auxiliary power |
| 14 | O:1 | 107 | Emergency off |
| 12 | O:1 | 108 | Enerpro fast inhibit |
| 35 | O:1 | 109 | Enerpro slow start |
| 45 | O:1 | 110 | Low oil |
| 43 | O:1 | 111 | Oil overtemp |
| 43 | O:1 | 112 | Overtemp |
| 54 | O:1 | 113 | Over volt latch |
| 72 | O:1 | 114 | SCR 1 status |
| 71 | O:1 | 115 | SCR 2 status |
| 4 | O:1 | 116 | Supply Ready |
| 3 | O:1 | 117 | System Ready |
| 46 | O:1 | 118 | Sudden pressure |
| 41 | O:1 | 119 | Pressure alarm |
| 15 | O:1 | 120 | PPS status |
| 7 | O:1 | 121 | Remote Open Load |
| 57 | O:1 | 122 | (xfmr arc trip) |
| 56 | O:1 | 123 | DCM bit (Signal from F.O. Crowbar Enable from LLRF) |
| 25 | O:1 | 124 | H1 SCR latch |
| 26 | O:1 | 125 | H2 SCR latch |
| 42 | O:1 | 126 | Vacuum alarm |
