# DB41-122m    MCO

> **Source:** `hvps/documentation/switchgear/DB41-122m    MCO.pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 2


---
## Page 1

ABB Power T&D Company Inc. Descriptive Bulletin
Relay Division 41-122M
Coral Springs, FL
Allentown, PA
August 1996 Device Number: 50/51 Type MCO
Microprocessor Time
Overcurrent Relay
Application
The MCO is a microprocessor-based single-
phase non-directional time and instantaneous
overcurrent relay. The MCO is used to sense
power system phase or ground current levels
above specific settings and is normally used to
trip a circuit breaker or other fault interrupting
device.
A primary feature of the MCO is the front panel
switch selection of seven separate tripping
characteristic curve shapes corresponding to
the following:
• Short Time (CO-2 characteristic)
• Long Time (CO-5 Characteristic)
• Definite Time (CO-6 Characteristic)
• Moderately Inverse (CO-7 Characteristic)
• Inverse (CO-8 Characteristic)
• Very Inverse (CO-9 Characteristic)
• Extremely Inverse (CO-11 Characteristic)
The MCO is available with time-overcurrent
pickup ranges of 0.1 to 2.4 amps or 0.5 to 12.0
amps. An instantaneous trip unit provides high
speed tripping for high current faults and is set
as a multiple of the time overcurrent setting, with
a range of 1 to 20 in 0.5 steps. If instantaneous
tripping is not desired, this feature can be dis-
able by simple front panel switch selection.
Features
An optional instantaneous delay characteristic
provides coordination time to allow downstream
• Front panel switch selection of seven different characteristic curve fuse clearing.
shapes
Independent contact trip outputs and separate
• Wide range of pickup setting allows single style relay for both
LED indications are provided for the instanta-
phase and ground protection in many applications
neous and time delay trip outputs. The indica-
• Optional instantaneous delay for coordination with fuses.
tion is sealed in by detection of current flow in
• Fast reset feature prevents “ratcheting effect” under repeated the tripping circuit. Indicator reset is accom-
faults in reclosing schemes plished manually.
• Very low ct burden
Non-volatile memory provides retention of the
• FT-11 Flexitest™ case construction provides in-service test and
trip indications.
isolation capability
• Trip indication (with memory) is based on actual trip current flow The microprocessor design provides automatic
self-checking of the software and hardware as
• Trip Test pushbutton
well as indication of loss of dc battery voltage.
• Reliable dc-to-dc power supply
• Monitoring circuit with contact output for automatic self-check of
hardware and software, and for loss of dc battery voltage


### Table 1

|  |  |  |  |
| --- | --- | --- | --- |
|  |  |  |  |


---
## Page 2

ABB MCO Microprocessor Time Overcurrent Relay
Specifications Input Ratings
• 5A input: 16A continous; 200A one second;
Dimensions
burden 0.3 VA @ 5A
Standard FT-11 Flexitest™ case (Refer to DB41-076 for • 1A imput: 5A continuous, 100A one second;
details) burden 0.45VA @ 1A
Shipping Weight Output Contact Ratings
9.0 lbs. (4.1 Kg) @125Vdc @250Vdc
Closing 30A 30A
Power Supply
Continuous 5A 5A
48 or 125 Vdc selectable; 250 Vdc Break 0.5A 0.25A
Frequency Standards
• ANSI C37.90
50 or 60 Hertz selectable
• IEC 255 series
Indications
Temperature Range
• Time delay trip (light emitting diode) flashes when input
• Operate: –20° to +55°C
current is above pickup setting
• Storage: –40° to +70°C
• Time overcurrent trip
Style Number Selections
• Instantaneous trip
• Monitor provided for power-on and self-check indication Time Unit DC Control Style
Range Voltage Number
Timing Characteristics
0.5 – 12A 48/125 1354D01A01
• Provides seven separate time overcurrent curves as out- 0.1 – 2.4A 48/125 1354D01A02
lined in I.L. 41-120 0.5 – 12A 250 1354D01A03
• Reset time–2 cycles 0.1 – 2.4A 250 1354D01A04
• Optional delayed instantaneous feature
For Delayed Instantaneous option, add suffix “–FUS” to style
(“–FUS” catalog suffix)
number.
Fixed Delays: 0, 0.05, 0.10 sec.
Additional Information: Instruction Book IL 41-120, Trans-
Adjustable Delay: 0.2-0.83 sec.
parent Time-current Curves.
TD
RR
Figure 1: MCO Internal Connections
AL TD IT TD/
IT
FRONT VIEW FT-11 CASE
IT
TD
MCO
IT LOGIC RR = Target Seal-In Reed Relay (Low Impedance)
IT = Instantaneous Trip
AL
TD = Time-Overcurrent Trip
RR AL = Self-Check Alarm
P/S = Power Supply
TD/
DC TO DC IT AL
P / S CHASSIS OPERATED
SHORTING SWITCH
RED HANDLE
TEST SWITCH
CURRENT
X
TEST JACK
TERMINAL
1 3 5 7 9
2 V+ 4 6 8 10 ABB Power T&D Company Inc.
Relay Division
COM
Iin 7036 Snowdrift Road
Allentown, PA 18106


### Table 1

|  |  |
| --- | --- |
|  |  |


### Table 2

|  |  |
| --- | --- |
