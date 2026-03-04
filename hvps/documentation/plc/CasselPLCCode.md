# CasselPLCCode

> **Source:** `hvps/documentation/plc/CasselPLCCode.pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 47


---
## Page 1

SSRLV6-4-05-10
Program File List
Name Number Type Rungs Debug Bytes
[SYSTEM] 0 SYS 0 No 0
1 SYS 0 No 0
2 LADDER 120 No 5557
COPY 3 LADDER 6 No 108
SCALE 4 LADDER 5 No 159
Page 1 Wednesday, June 23, 2021 - 14:35:01


### Table 1

| Name | Number | Type | Rungs | Debug | Bytes |
| --- | --- | --- | --- | --- | --- |


### Table 2

| [SYSTEM] |  |  | 0 | SYS | 0 |  | No |  | 0 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 |  |  |  | SYS | 0 |  | No |  | 0 |
| 2 |  |  |  | LADDER |  | 120 |  | No | 5557 |
| COPY | 3 |  |  | LADDER |  | 6 | No |  | 108 |
| SCALE |  | 4 |  | LADDER |  | 5 | No |  | 159 |


---
## Page 2

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
OVERFLOW
BIT
S:5
0000 U
0
RESET BUTTON MOMENTARY
MOMENTARY
RESET RESET
T4:0 B3:0
0001
TT 10
ALARM
RESET
B3:0
U
14
_ENERPRO_PHASE_LOSS
B3:5
U
3
Page 1 Wednesday, June 23, 2021 - 14:35:01


### Table 1

| 0000 |  | OVERFLOW |  |
| --- | --- | --- | --- |
|  |  | BIT |  |
|  |  | S:5 |  |
|  | U 0 | U 0 |  |
| 0001 | RESET BUTTON MOMENTARY MOMENTARY RESET RESET T4:0 B3:0 |  |  |
|  | TT 10 ALARM RESET B3:0 U 14 _ENERPRO_PHASE_LOSS B3:5 U 3 |  |  |


### Table 2

| MOMENTARY |
| --- |
| RESET |
| T4:0 |
| TT |


### Table 3

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 4

| ALARM |
| --- |
| RESET |
| B3:0 |
| U 14 |


### Table 5

| _ENERPRO_PHASE_LOSS |
| --- |
| B3:5 |
| U 3 |


---
## Page 3

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
CONTACTOR CLOSE/ OPEN LATCH STRING
SYSTEM MANUAL GRN REMOTE
READY SWITCH ENABLE PANEL OPEN BIT ON/OFF
T4:8 I:6 B3:0 B3:0 I:1
0002
DN 9 6 5 48
1746-IB16 1747-DCM-FULL
CONTACTOR
REGULATOR OVER CONTACTOR
MOMENTARY REMOTE ON CURRENT TRIP CURRENT READY
T4:9 I:7 I:7 B3:0
TT 15 1 15
1746-IV16 1746-IV16
PANEL REMOTE ON
T4:15
TT
CONTACTOR CONTACTOR
CLOSED LATCH
I:7 B3:0
2 8
1746-IV16
OPEN LOAD CROWBAR CLOSE
LATCH LATCH CONTACTOR
B3:3 B3:4 O:5
2 10 1
1746-OX8
CROWBAR
LOCKOUT CONTACTOR
B3:0 LATCH
B3:0
12
8
Page 2 Wednesday, June 23, 2021 - 14:35:01


### Table 1

| 0002 | CONTACTOR CLOSE/ OPEN LATCH STRING SYSTEM MANUAL GRN REMOTE READY SWITCH ENABLE PANEL OPEN BIT ON/OFF T4:8 I:6 B3:0 B3:0 I:1 DN 9 6 5 48 1746-IB16 1747-DCM-FULL CONTACTOR REGULATOR OVER CONTACTOR MOMENTARY REMOTE ON CURRENT TRIP CURRENT READY T4:9 I:7 I:7 B3:0 TT 15 1 15 1746-IV16 1746-IV16 PANEL REMOTE ON T4:15 TT CONTACTOR CONTACTOR CLOSED LATCH I:7 B3:0 2 8 1746-IV16 OPEN LOAD CROWBAR CLOSE LATCH LATCH CONTACTOR B3:3 B3:4 O:5 2 10 1 1746-OX8 CROWBAR LOCKOUT CONTACTOR B3:0 LATCH B3:0 12 8 |
| --- | --- |


### Table 2

| SYSTEM |  | MANUAL GRN |  | ENABLE PANEL OPEN BIT B3:0 B3:0 | REMOTE |  |
| --- | --- | --- | --- | --- | --- | --- |
| READY |  | SWITCH |  |  | ON/OFF |  |
| T4:8 |  | I:6 |  |  | I:1 |  |
| DN |  |  | 9 |  |  | 48 |
|  |  | 1746-IB16 |  |  | 1747-DCM-FULL |  |


### Table 3

| ENABLE |
| --- |
| B3:0 |
| 6 |


### Table 4

| PANEL OPEN BIT |
| --- |
| B3:0 |
| 5 |


### Table 5

|  |  |
| --- | --- |


### Table 6

| CONTACTOR |
| --- |
| OVER |
| CURRENT |
| I:7 |
| 1 |
| 1746-IV16 |


### Table 7

| REGULATOR |  |
| --- | --- |
| CURRENT TRIP |  |
| I:7 |  |
|  | 15 |
| 1746-IV16 |  |


### Table 8

| CONTACTOR |
| --- |
| READY |
| B3:0 |
| 15 |


### Table 9

| MOMENTARY REMOTE ON |
| --- |
| T4:9 |
| TT |


### Table 10

| TT PANEL REMOTE ON T4:15 |
| --- |
| TT CONTACTOR CONTACTOR CLOSED LATCH I:7 B3:0 |


### Table 11

| PANEL REMOTE ON |
| --- |
| T4:15 |
| TT |


### Table 12

| CONTACTOR |  |
| --- | --- |
| CLOSED |  |
| I:7 |  |
| 2 |  |
| 1746-IV16 |  |


### Table 13

| CONTACTOR |
| --- |
| LATCH |
| B3:0 |
| 8 |


### Table 14

|  |  |  |
| --- | --- | --- |
|  | OPEN LOAD |  |
|  | LATCH |  |
|  | B3:3 |  |
|  | 2 |  |


### Table 15

|  |  |
| --- | --- |
| CROWBAR |  |
| LATCH |  |
| B3:4 |  |
| 10 |  |


### Table 16

| CLOSE |  |
| --- | --- |
| CONTACTOR |  |
| O:5 |  |
|  | 1 |
| 1746-OX8 |  |


### Table 17

| CROWBAR |
| --- |
| LOCKOUT |
| B3:0 |


### Table 18

| CONTACTOR |
| --- |
| LATCH B3:0 |
| 8 |


---
## Page 4

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
CONTACTOR
CLOSED
DELAY
T4:16
0003
DN
CROWBAR ENABLE
CROWBAR FIBER DR SYSTEM
TIME OFF ENABLE READY
T4:13 O:5 I:6 B3:1
DN 4 1 13
1746-OX8 1746-IB16
SYSTEM
READY
O:1
117
1747-DCM-FULL
CONTROL
SYSTEM
240V PWR ENABLE
O:2 O:5
2 0
1746-IO8 1746-OX8
TURN OFF
DELAY
TTOONN
Timer On Delay EN
Timer T4:13
Time Base 0.01 DN
Preset 10<
Accum 0<
Page 3 Wednesday, June 23, 2021 - 14:35:02


### Table 1

| 0003 |  | CONTACTOR |
| --- | --- | --- |
|  |  | CLOSED |
|  |  | DELAY |
|  |  | T4:16 |
|  |  | DN |


### Table 2

| CROWBAR ENABLE |
| --- |
| FIBER DR |
|  |
| I:6 |
| 1 |
| 1746-IB16 |


### Table 3

| CROWBAR |  |
| --- | --- |
| ENABLE |  |
| O:5 |  |
|  | 4 |
| 1746-OX8 |  |


### Table 4

| SYSTEM |
| --- |
| READY |
| B3:1 |
| 13 |


### Table 5

| TIME OFF |
| --- |
| T4:13 |
| DN |


### Table 6

| SYSTEM |  |
| --- | --- |
| READY |  |
| O:1 |  |
|  | 117 |
| 1747-DCM-FULL |  |


### Table 7

| CONTROL |  |
| --- | --- |
| SYSTEM |  |
| ENABLE |  |
| O:5 |  |
|  | 0 |
| 1746-OX8 |  |


### Table 8

| 240V PWR |  |
| --- | --- |
| O:2 |  |
|  | 2 |
| 1746-IO8 |  |


### Table 9

| TURN OFF |
| --- |
| DELAY |


### Table 10

| Time Base 0.01 Preset 10 |  |
| --- | --- |
| Accum | 0 |


---
## Page 5

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
SCR ON/OFF CHAIN
CONTACTOR
OFF BIT LATCH GRD SWITCH RELAY
B3:0 B3:0 O:2
0004
1 8 3
1746-IO8
CONTACTOR
SYSTEM CLOSED SCR DISABLE CONTROL
READY DELAY FIBER DR ENABLE
B3:1 T4:16 I:6 I:1
13 DN 0 64
1746-IB16 1747-DCM-FULL
CONTACTOR OVER
REMOTE ON OVER VOLTAGE REGULATOR
MOMENTARY SCR CURRENT TRIP CURRENT TRIP
T4:10 I:7 I:7 I:7
TT 1 14 15
1746-IV16 1746-IV16 1746-IV16
PANEL ON BIT
B3:0
3
SCR ON LATCH
B3:0
4
CROWBAR CROWBAR SCR
FORCED ON LATCH ON LATCH
O:5 B3:4 B3:0
3 10 4
1746-OX8
SUPPLY
READY
O:1
116
1747-DCM-FULL
Contactor Closed
delay
TTOONN
Timer On Delay EN
Timer T4:16
Time Base 0.01 DN
Preset 300<
Accum 0<
Page 4 Wednesday, June 23, 2021 - 14:35:02


### Table 1

| 0004 | SCR ON/OFF CHAIN CONTACTOR OFF BIT LATCH GRD SWITCH RELAY B3:0 B3:0 O:2 1 8 3 1746-IO8 CONTACTOR SYSTEM CLOSED SCR DISABLE CONTROL READY DELAY FIBER DR ENABLE B3:1 T4:16 I:6 I:1 13 DN 0 64 1746-IB16 1747-DCM-FULL CONTACTOR OVER REMOTE ON OVER VOLTAGE REGULATOR MOMENTARY SCR CURRENT TRIP CURRENT TRIP T4:10 I:7 I:7 I:7 TT 1 14 15 1746-IV16 1746-IV16 1746-IV16 PANEL ON BIT B3:0 3 SCR ON LATCH B3:0 4 CROWBAR CROWBAR SCR FORCED ON LATCH ON LATCH O:5 B3:4 B3:0 3 10 4 1746-OX8 SUPPLY READY O:1 116 1747-DCM-FULL Contactor Closed delay TTOONN Timer On Delay EN Timer T4:16 Time Base 0.01 DN Preset 300< Accum 0< |
| --- | --- |


### Table 2

| CONTACTOR |
| --- |
| LATCH |
| B3:0 |
| 8 |


### Table 3

| OFF BIT |
| --- |
| B3:0 |
| 1 |


### Table 4

| GRD SWITCH RELAY |  |
| --- | --- |
| O:2 |  |
|  | 3 |
| 1746-IO8 |  |


### Table 5

|  |  |
| --- | --- |


### Table 6

| CONTACTOR |
| --- |
| CLOSED |
| DELAY |
| T4:16 |
| DN |


### Table 7

| SYSTEM |
| --- |
| READY |
| B3:1 |
| 13 |


### Table 8

| SCR DISABLE |
| --- |
| FIBER DR |
| I:6 |
| 0 |
| 1746-IB16 |


### Table 9

| CONTROL |  |
| --- | --- |
| ENABLE |  |
| I:1 |  |
| 6 | 4 |
| 1747-DCM-FULL |  |


### Table 10

| REMOTE ON MOMENTARY SCR T4:10 |  |  |  |
| --- | --- | --- | --- |
|  | CONTACTOR |  |  |
|  | OVER |  |  |
|  | CURRENT |  |  |
|  | I:7 |  |  |
|  | 1 |  |  |
|  | 1746-IV16 |  |  |


### Table 11

| OVER |  |
| --- | --- |
| VOLTAGE |  |
| TRIP |  |
| I:7 |  |
|  | 14 |
| 1746-IV16 |  |


### Table 12

| REMOTE ON |
| --- |
| MOMENTARY SCR |
| T4:10 |
| TT |


### Table 13

| REGULATOR |  |
| --- | --- |
| CURRENT TRIP |  |
| I:7 |  |
|  | 15 |
| 1746-IV16 |  |


### Table 14

| PANEL ON BIT |
| --- |
| B3:0 |
| 3 |


### Table 15

| SCR ON LATCH |
| --- |
| B3:0 |
| 4 |


### Table 16

|  |  |  |
| --- | --- | --- |
|  | CROWBAR |  |
|  | FORCED ON |  |
|  | O:5 |  |
|  |  | 3 |
|  | 1746-OX8 |  |


### Table 17

|  |  |
| --- | --- |
| SCR |  |
| ON LATCH |  |
| B3:0 |  |
| 4 |  |


### Table 18

| CROWBAR |
| --- |
| LATCH |
| B3:4 |
| 10 |


### Table 19

| SUPPLY |  |
| --- | --- |
| READY |  |
| O:1 |  |
| 1 | 16 |
| 1747-DCM-FULL |  |


### Table 20

| Contactor Closed |
| --- |
| delay |


### Table 21

| Time Base 0.01 Preset 300 |  |
| --- | --- |
| Accum | 0 |


---
## Page 6

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
CONTACTOR PUSH BUTTON CLOSED MOMENTARY
MOMENTARY ON BUTTON
CONTACTOR CONTACTOR
BUTTON BIT
B3:0 TTOONN
0005 Timer On Delay EN
7 Timer T4:9
Time Base 0.01 DN
MOMENTARY REMOTE ON Preset 100<
T4:9 Accum 0<
TT
CONTACTOR CLOSE REMOTE MOMENTARY
REMOTE
ON/OFF MOMENTARY ON REMOTE
I:1 TTOONN
0006 Timer On Delay EN
48 Timer T4:15
1747-DCM-FULL Time Base 0.01 DN
Preset 100<
PANEL REMOTE ON Accum 0<
T4:15
TT
OPEN LOAD
OPEN LOAD DELAY LATCH
T4:17 B3:3
0007
DN 2
RESET BIT ALARM BIT
B3:3 B3:0 B3:0
2 11 14
REMOTE OPEN LOAD
O:1
121
1747-DCM-FULL
Page 5 Wednesday, June 23, 2021 - 14:35:02


### Table 1

| 0005 | CONTACTOR PUSH BUTTON CLOSED MOMENTARY MOMENTARY ON BUTTON CONTACTOR CONTACTOR BUTTON BIT B3:0 TTOONN Timer On Delay EN 7 Timer T4:9 Time Base 0.01 DN MOMENTARY REMOTE ON Preset 100< T4:9 Accum 0< TT |  |  |
| --- | --- | --- | --- |
| 0006 | CONTACTOR CLOSE REMOTE MOMENTARY REMOTE ON/OFF MOMENTARY ON REMOTE I:1 TTOONN Timer On Delay EN 48 Timer T4:15 1747-DCM-FULL Time Base 0.01 DN Preset 100< PANEL REMOTE ON Accum 0< T4:15 TT |  |  |
| 0007 | OPEN LOAD DELAY T4:17 | OPEN LOAD |  |
|  |  | LATCH |  |
|  |  | B3:3 |  |
|  | DN 2 RESET BIT ALARM BIT B3:3 B3:0 B3:0 2 11 14 REMOTE OPEN LOAD O:1 121 1747-DCM-FULL | 2 |  |


### Table 2

| MOMENTARY ON BUTTON |
| --- |
| CONTACTOR |
|  |


### Table 3

| CONTACTOR |
| --- |
| BUTTON BIT |
| B3:0 |


### Table 4

| T4:9 |
| --- |
| TT |


### Table 5

| REMOTE |
| --- |
| ON/OFF |
| I:1 |
| 48 |


### Table 6

| Time Base 0.01 Preset 100 |  |
| --- | --- |
| Accum | 0 |


### Table 7

| PANEL REMOTE ON |
| --- |
| T4:15 |
| TT |


### Table 8

| OPEN LOAD DELAY |
| --- |
| T4:17 |
| DN |


### Table 9

| RESET BIT |
| --- |
| B3:0 |
| 11 |


### Table 10

| ALARM BIT |
| --- |
| B3:0 |
| 14 |


### Table 11

| B3:3 |
| --- |
| 2 |


### Table 12

| REMOTE OPEN LOAD |  |
| --- | --- |
| O:1 |  |
|  | 121 |
| 1747-DCM-FULL |  |


---
## Page 7

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
OPEN LOAD DETECTOR IF VOLTAGE > N7:76,78 AND CURRENT LESS THAN N7:77,79
DC CURRENT VOLTAGE
MONITOR MONITOR #1
LLEESS GGRRTT
0008 Less Than (A<B) Greater Than (A>B)
Source A N7:17 Source A N7:15
11< 1<
Source B N7:77 Source B N7:76
10< 5000<
AC CURRENT VOLTAGE
MONITOR MONITOR #2
LLEESS GGRRTT
Less Than (A<B) Greater Than (A>B)
Source A N7:14 Source A N7:16
0< 0<
Source B N7:79 Source B N7:78
30< 5000<
OPEN LOAD DELAY
TTOONN
Timer On Delay EN
Timer T4:17
Time Base 0.01 DN
Preset 100<
Accum 0<
SCR ON/OFF CONTROLS MOMENTARY
CONTROL REMOTE MOMENTARY ON
ENABLE SCR'S
I:1 TTOONN
0009 Timer On Delay EN
64 Timer T4:10
1747-DCM-FULL Time Base 0.01 DN
Preset 50<
Accum 0<
Page 6 Wednesday, June 23, 2021 - 14:35:02


### Table 1

| 0008 | OPEN LOAD DETECTOR IF VOLTAGE > N7:76,78 AND CURRENT LESS THAN N7:77,79 |
| --- | --- |
| 0009 | SCR ON/OFF CONTROLS MOMENTARY CONTROL REMOTE MOMENTARY ON ENABLE SCR'S I:1 TTOONN Timer On Delay EN 64 Timer T4:10 1747-DCM-FULL Time Base 0.01 DN Preset 50< Accum 0< |


### Table 2

| DC CURRENT |
| --- |
| MONITOR |


### Table 3

| VOLTAGE |
| --- |
| MONITOR #1 |


### Table 4

| Source A |  | N7:17 |
| --- | --- | --- |
|  | 11 |  |
| Source B |  | N7:77 |
|  | 10 |  |


### Table 5

| Source A |  | N7:15 |
| --- | --- | --- |
|  | 1 |  |
| Source B |  | N7:76 |
|  | 5000 |  |


### Table 6

| AC CURRENT |
| --- |
| MONITOR |


### Table 7

| VOLTAGE |
| --- |
| MONITOR #2 |


### Table 8

| Source A |  | N7:14 |
| --- | --- | --- |
|  | 0 |  |
| Source B |  | N7:79 |
|  | 30 |  |


### Table 9

| Source A |  | N7:16 |
| --- | --- | --- |
|  | 0 |  |
| Source B |  | N7:78 |
|  | 5000 |  |


### Table 10

| Time Base 0.01 Preset 100 |  |
| --- | --- |
| Accum | 0 |


### Table 11

|  | CONTROL |
| --- | --- |
|  | ENABLE |
|  | I:1 |
|  | 64 |


### Table 12

| REMOTE MOMENTARY ON |
| --- |
| SCR'S |


### Table 13

| Time Base 0.01 Preset 50 |  |
| --- | --- |
| Accum | 0 |


---
## Page 8

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
TURN OFF SEQUENCE
ENABLE
SCR ON LATCH DELAY
B3:0 TTOONN
0010 Timer On Delay EN
4 Timer T4:5
Time Base 0.01 DN
Preset 300<
Accum 0<
FAST
INHIBIT
B3:0
L
13
ENABLE REGULATOR
DELAY ON
T4:5 B3:0
DN 2
REFERANCE VOLTAGE OR MAXIMUM
REGULATOR REFERANCE
ON CONTROL
B3:0 MMOOVV
0011 Move
2 Source 0
0<
Dest N7:10
0<
PHASE
ANGLE
CONTROL
MMOOVV
Move
Source 0
0<
Dest N7:11
0<
FAST
INHIBIT
T4:14 B3:0
U
DN 13
Page 7 Wednesday, June 23, 2021 - 14:35:02


### Table 1

| 0010 | TURN OFF SEQUENCE ENABLE SCR ON LATCH DELAY B3:0 TTOONN Timer On Delay EN 4 Timer T4:5 Time Base 0.01 DN Preset 300< Accum 0< FAST INHIBIT B3:0 L 13 ENABLE REGULATOR DELAY ON T4:5 B3:0 DN 2 |
| --- | --- |
| 0011 | REFERANCE VOLTAGE OR MAXIMUM REGULATOR REFERANCE ON CONTROL B3:0 MMOOVV Move 2 Source 0 0< Dest N7:10 0< PHASE ANGLE CONTROL MMOOVV Move Source 0 0< Dest N7:11 0< FAST INHIBIT T4:14 B3:0 U DN 13 |


### Table 2

| ENABLE |
| --- |
| DELAY |


### Table 3

| SCR ON LATCH |
| --- |
| B3:0 |


### Table 4

| Time Base 0.01 Preset 300 |  |
| --- | --- |
| Accum | 0 |


### Table 5

| FAST |
| --- |
| INHIBIT |
| B3:0 |
| L 13 |


### Table 6

| ENABLE |
| --- |
| DELAY |
| T4:5 |
| DN |


### Table 7

| REGULATOR |
| --- |
| ON |
| B3:0 |
| 2 |


### Table 8

| REGULATOR |
| --- |
| ON |
| B3:0 |
| 2 |


### Table 9

| REFERANCE |
| --- |
| CONTROL |


### Table 10

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:10 |
|  | 0 |  |


### Table 11

| PHASE |
| --- |
| ANGLE |
| CONTROL |


### Table 12

| Source |  |  | 0 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Dest |  | N7:11 |  |
|  | 0 |  |  |


### Table 13

| FAST |
| --- |
| INHIBIT |
| B3:0 |
| U 13 |


### Table 14

| T4:14 |
| --- |
| DN |


---
## Page 9

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
FAST
INHIBIT
T4:14 O:5
0012
DN 6
1746-OX8
FAST
INHIBIT ENERPRO
B3:0 FAST
INHIBIT
13 O:1
108
1747-DCM-FULL
CROWBAR LATCHING WITH RESET AND OVERIDE
CROWBAR ENABLE
FIBER DR CROWBAR CROWBAR
RESET ENABLE LATCH
B3:0 I:6 I:6 B3:4
0013
10 1 2 10
1746-IB16 1746-IB16
CROWBAR
LATCH FAST
B3:4 INHIBIT
O:5
10
6
1746-OX8
T4:13
DN
EMERGENCY EMERGENCY
OFF PPS-1 OK OFF LATCH
I:6 I:6 B3:1
0014
13 14 0
1746-IB16 1746-IB16
CONTACTOR EMERGENCY
Grounding Switch CLOSED OFF ALARM
closed B3:1 B3:3
I:6
11 11
9
1746-IB16 EMERGENCY
OFF
RESET EMERGENCY OFF LATCH O:1
B3:0 B3:1
107
10 0 1747-DCM-FULL
ALARM BIT
ON
B3:0
L
14
Page 8 Wednesday, June 23, 2021 - 14:35:03


### Table 1

| 0012 | T4:14 |  |  |  |  | FAST |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  | INHIBIT |  |  |
|  |  |  |  |  |  | O:5 |  |  |
|  | DN 6 1746-OX8 FAST INHIBIT ENERPRO B3:0 FAST INHIBIT 13 O:1 108 1747-DCM-FULL |  |  |  |  |  | 6 |  |
|  |  |  |  |  |  | 1746-OX8 |  |  |
| 0013 | CROWBAR LATCHING WITH RESET AND OVERIDE CROWBAR ENABLE FIBER DR CROWBAR CROWBAR RESET ENABLE LATCH B3:0 I:6 I:6 B3:4 |  |  |  |  |  |  |  |
|  | 10 1 2 10 1746-IB16 1746-IB16 CROWBAR LATCH FAST B3:4 INHIBIT O:5 10 6 1746-OX8 T4:13 DN |  |  |  |  |  |  |  |
| 0014 |  | EMERGENCY |  | PPS-1 OK I:6 | EMERGENCY |  |  |  |
|  |  | OFF |  |  | OFF LATCH |  |  |  |
|  |  | I:6 |  |  | B3:1 |  |  |  |
|  | 13 14 0 1746-IB16 1746-IB16 CONTACTOR EMERGENCY Grounding Switch CLOSED OFF ALARM closed B3:1 B3:3 I:6 11 11 9 1746-IB16 EMERGENCY OFF RESET EMERGENCY OFF LATCH O:1 B3:0 B3:1 107 10 0 1747-DCM-FULL ALARM BIT ON B3:0 L 14 |  | 13 |  | 0 |  |  |  |
|  |  | 1746-IB16 |  |  |  |  |  |  |


### Table 2

| T4:14 |
| --- |
| DN |


### Table 3

| FAST |
| --- |
| INHIBIT |
| B3:0 |


### Table 4

| ENERPRO |  |
| --- | --- |
| FAST |  |
| INHIBIT O:1 |  |
|  | 108 |
| 1747-DCM-FULL |  |


### Table 5

| CROWBAR ENABLE |
| --- |
| FIBER DR |
|  |
| I:6 |
| 1 |
| 1746-IB16 |


### Table 6

| CROWBAR |  |
| --- | --- |
| ENABLE |  |
| I:6 |  |
|  | 2 |
| 1746-IB16 |  |


### Table 7

| CROWBAR |
| --- |
| LATCH |
| B3:4 |
| 10 |


### Table 8

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 9

| 1 2 1746-IB16 1746-IB16 FAST INHIBIT O:5 |
| --- |
| 6 1746-OX8 T4:13 |


### Table 10

| CROWBAR |
| --- |
| LATCH |
| B3:4 |


### Table 11

| FAST |  |
| --- | --- |
| INHIBIT O:5 |  |
|  | 6 |
| 1746-OX8 |  |


### Table 12

| T4:13 |
| --- |
| DN |


### Table 13

| PPS-1 OK |  |
| --- | --- |
| I:6 |  |
|  | 14 |
| 1746-IB16 |  |


### Table 14

| 0 CONTACTOR EMERGENCY CLOSED OFF ALARM B3:1 B3:3 |
| --- |
| 11 11 EMERGENCY OFF O:1 |
| 107 1747-DCM-FULL ALARM BIT ON B3:0 |


### Table 15

| CONTACTOR |
| --- |
| CLOSED |
| B3:1 |


### Table 16

| EMERGENCY |
| --- |
| OFF ALARM |
| B3:3 |


### Table 17

| Grounding Switch |  |
| --- | --- |
| closed I:6 |  |
|  | 9 |
| 1746-IB16 |  |


### Table 18

| EMERGENCY |
| --- |
| OFF |
| O:1 |
| 107 1747-DCM-FULL |


### Table 19

| RESET B3:0 |
| --- |
| 10 |


### Table 20

| EMERGENCY OFF LATCH B3:1 |
| --- |
| 0 |


### Table 21

| ALARM BIT |
| --- |
| ON |
| B3:0 |
| L 14 |


---
## Page 10

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
PPS-1 ON PPS ON
I:6 B3:1
0015
14 1
1746-IB16
PPS
PPS-2 ON STATUS
I:6 O:1
15 120
1746-IB16 1747-DCM-FULL
TOUCH PANEL MANUAL GRN
(KEY) ENABLE PPS-1 OK PPS-2 OK SWITCH
I:6 I:6 I:6 I:6
0016
12 14 15 9
1746-IB16 1746-IB16 1746-IB16 1746-IB16
OFF
DISPLAY
B3:0
0
CONTACTOR
CLOSED GRD SWITCH RELAY
I:7 O:2
2 3
1746-IV16 1746-IO8
TOUCH PANEL EMERGENCY
(KEY) ENABLE OFF OFF ENABLE
I:6 B3:1 B3:0 B3:0
0017
12 0 0 6
1746-IB16
CROWBAR
0N
O:5
2
1746-OX8
ENABLE DISPLAY
B3:1
9
SYSTEM
READY
TIME DELAY
OFF 240V PWR ENABLE
B3:0 O:2 B3:0 TTOONN
0018 Timer On Delay EN
0 2 6 Timer T4:8
1746-IO8 Time Base 0.01 DN
Preset 500<
Accum 0<
Page 9 Wednesday, June 23, 2021 - 14:35:03


### Table 1

| 0015 |  |  | PPS-1 ON |  |  |  |  |  |  | PPS ON |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  | I:6 |  |  |  |  |  |  | B3:1 |  |
|  | 14 1 1746-IB16 PPS PPS-2 ON STATUS I:6 O:1 15 120 1746-IB16 1747-DCM-FULL |  |  |  | 14 |  |  |  |  | 1 |  |
|  |  |  | 1746-IB16 |  |  |  |  |  |  |  |  |
| 0016 |  | TOUCH PANEL |  |  |  | PPS-1 OK PPS-2 OK I:6 I:6 |  |  | MANUAL GRN |  |  |
|  |  | (KEY) ENABLE |  |  |  |  |  |  | SWITCH |  |  |
|  |  | I:6 |  |  |  |  |  |  | I:6 |  |  |
|  |  |  |  | 12 |  |  |  |  | 9 |  |  |
|  |  | 1746-IB16 |  |  |  |  |  |  | 1746-IB16 |  |  |
| 0017 |  | TOUCH PANEL |  |  |  |  | EMERGENCY | OFF ENABLE B3:0 B3:0 |  |  |  |
|  |  | (KEY) ENABLE |  |  |  |  | OFF |  |  |  |  |
|  |  | I:6 |  |  |  |  | B3:1 |  |  |  |  |
|  | 12 0 0 6 1746-IB16 CROWBAR 0N O:5 2 1746-OX8 ENABLE DISPLAY B3:1 9 |  |  | 12 |  |  | 0 |  |  |  |  |
|  |  | 1746-IB16 |  |  |  |  |  |  |  |  |  |
| 0018 | SYSTEM READY TIME DELAY OFF 240V PWR ENABLE B3:0 O:2 B3:0 TTOONN Timer On Delay EN 0 2 6 Timer T4:8 1746-IO8 Time Base 0.01 DN Preset 500< Accum 0< |  |  |  |  |  |  |  |  |  |  |


### Table 2

| PPS |  |
| --- | --- |
| STATUS |  |
| O:1 |  |
|  | 120 |
| 1747-DCM-FULL |  |


### Table 3

| PPS-2 ON |  |
| --- | --- |
| I:6 |  |
|  | 15 |
| 1746-IB16 |  |


### Table 4

| PPS-1 OK |  |
| --- | --- |
| I:6 |  |
|  | 14 |
| 1746-IB16 |  |


### Table 5

| PPS-2 OK |  |
| --- | --- |
| I:6 |  |
|  | 15 |
| 1746-IB16 |  |


### Table 6

| FF |
| --- |
| ISPLAY |
| B3:0 |
| 0 |


### Table 7

| CONTACTOR |  |
| --- | --- |
| CLOSED |  |
| I:7 |  |
|  | 2 |
| 1746-IV16 |  |


### Table 8

| GRD SWITCH RELAY |  |
| --- | --- |
| O:2 |  |
| 3 |  |
| 1746-IO8 |  |


### Table 9

| OFF |
| --- |
| B3:0 |
| 0 |


### Table 10

| ENABLE |
| --- |
| B3:0 |
| 6 |


### Table 11

| 6 CROWBAR 0N O:5 |
| --- |
| 2 1746-OX8 ENABLE DISPLAY B3:1 |


### Table 12

| CROWBAR |  |
| --- | --- |
| 0N |  |
| O:5 |  |
|  | 2 |
| 1746-OX8 |  |


### Table 13

| ENABLE DISPLAY |
| --- |
| B3:1 |
| 9 |


### Table 14

| SYSTEM |
| --- |
| READY |
| TIME DELAY |
|  |


### Table 15

| OFF |
| --- |
| B3:0 |


### Table 16

| 240V PWR |
| --- |
| O:2 |
| 2 |


### Table 17

| ENABLE |
| --- |
| B3:0 |


### Table 18

| Time Base 0.0 Preset 50 |  |
| --- | --- |
| Accum |  |


---
## Page 11

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
ALARM BIT ALARM
B3:0 B3:3
0019
14 0
CONTACTOR
CONTACTOR CLOSED CONTACTOR
READY DELAY ALARM
I:7 T4:16 B3:3
0020
3 DN 8
1746-IV16
ALARM BIT
CONTACTOR ON
ALARM B3:0
LATCH L
RESET BIT 14
B3:3 B3:0
8 11
XFORMER
LATCHED XFORMER
OK ALARM
B3:2 B3:3
0021
1 7
ALARM BIT
ON
B3:0
L
14
REGULATOR
CURRENT OVER
TRIP CURRENT
I:7 B3:3
0022
15 5
1746-IV16
ALARM BIT
ON
B3:0
L
14
REGULATOR
VOLTAGE OVER
TRIP VOLTAGE
I:7 B3:3
0023
14 6
1746-IV16
ALARM BIT
ON
B3:0
L
14
Page 10 Wednesday, June 23, 2021 - 14:35:03


### Table 1

| 0019 |  | ALARM BIT |  |  |  |  |  | ALARM |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | B3:0 |  |  |  |  |  | B3:3 |  |  |
|  | 14 0 | 14 |  |  |  |  |  | 0 |  |  |
| 0020 | CONTACTOR READY I:7 |  |  |  | CONTACTOR | CONTACTOR ALARM B3:3 |  |  |  |  |
|  |  |  |  |  | CLOSED |  |  |  |  |  |
|  |  |  |  |  | DELAY |  |  |  |  |  |
|  |  |  |  |  | T4:16 |  |  |  |  |  |
|  | 3 DN 8 1746-IV16 ALARM BIT CONTACTOR ON ALARM B3:0 LATCH L RESET BIT 14 B3:3 B3:0 8 11 |  |  |  | DN |  |  |  |  |  |
| 0021 |  | XFORMER | XFORMER ALARM B3:3 |  |  |  |  |  |  |  |
|  |  | LATCHED |  |  |  |  |  |  |  |  |
|  |  | OK |  |  |  |  |  |  |  |  |
|  |  | B3:2 |  |  |  |  |  |  |  |  |
|  | 1 7 ALARM BIT ON B3:0 L 14 | 1 |  |  |  |  |  |  |  |  |
| 0022 | CURRENT TRIP I:7 |  |  |  |  |  | REGULATOR |  |  |  |
|  |  |  |  |  |  |  | OVER |  |  |  |
|  |  |  |  |  |  |  | CURRENT |  |  |  |
|  |  |  |  |  |  |  | B3:3 |  |  |  |
|  | 15 5 1746-IV16 ALARM BIT ON B3:0 L 14 |  |  |  |  |  | 5 |  |  |  |
| 0023 | VOLTAGE TRIP I:7 |  |  |  |  |  | REGULATOR |  |  |  |
|  |  |  |  |  |  |  | OVER |  |  |  |
|  |  |  |  |  |  |  | VOLTAGE |  |  |  |
|  |  |  |  |  |  |  | B3:3 |  |  |  |
|  | 14 6 1746-IV16 ALARM BIT ON B3:0 L 14 |  |  |  |  |  | 6 |  |  |  |


### Table 2

| CONTACTOR |  |
| --- | --- |
| READY |  |
| I:7 |  |
| 3 |  |
| 1746-IV16 |  |


### Table 3

| CONTACTOR |
| --- |
| ALARM |
| B3:3 |
| 8 |


### Table 4

| ALARM BIT |
| --- |
| ON |
| B3:0 L |
| 14 |


### Table 5

| CONTACTOR |
| --- |
| ALARM |
| LATCH |
| B3:3 |
| 8 |


### Table 6

| B3:0 |
| --- |
| 11 |


### Table 7

| XFORMER |
| --- |
| ALARM |
| B3:3 |
| 7 |


### Table 8

| ALARM BIT |
| --- |
| ON |
| B3:0 |
| L 14 |


### Table 9

| CURRENT |  |
| --- | --- |
| TRIP |  |
| I:7 |  |
|  | 15 |
| 1746-IV16 |  |


### Table 10

| ALARM BIT |
| --- |
| ON |
| B3:0 |
| L 14 |


### Table 11

| VOLTAGE |  |
| --- | --- |
| TRIP |  |
| I:7 |  |
|  | 14 |
| 1746-IV16 |  |


### Table 12

| ALARM BIT |
| --- |
| ON |
| B3:0 |
| L 14 |


---
## Page 12

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
CONTACTOR
CONTACTOR OVER
OVER CURRENT
CURRENT ALARM
I:7 B3:3
0024
1 12
1746-IV16
ALARM BIT
ON
B3:0
L
14
SCR DRIVER SCR DISABLE REGULATOR
BIT LOWER FIBER DR ON SCR DRIVE BIT SCR OFF DELAY
I:6 I:6 B3:0 B3:2 T4:18
0025
4 0 2 13 DN
1746-IB16 1746-IB16
SCR DRIVER
LATCH RESET
B3:3 B3:0
14 10
SCR DRIVER
LATCH
B3:3
14
ALARM BIT
ON
B3:0
L
14
H1_SCR_LATCH
O:1
124
1747-DCM-FULL
Page 11 Wednesday, June 23, 2021 - 14:35:03


### Table 1

| 0024 | CONTACTOR OVER CURRENT I:7 |  |  |  |  |  | CONTACTOR |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  | OVER |  |
|  |  |  |  |  |  |  | CURRENT |  |
|  |  |  |  |  |  |  | ALARM |  |
|  |  |  |  |  |  |  | B3:3 |  |
|  | 1 12 1746-IV16 ALARM BIT ON B3:0 L 14 |  |  |  |  |  | 12 |  |
| 0025 |  | SCR DRIVER |  | SCR DISABLE |  | REGULATOR |  |  |
|  |  | BIT LOWER |  | FIBER DR |  | ON |  |  |
|  |  | I:6 |  | I:6 |  | B3:0 |  |  |
|  |  | 4 |  | 0 |  | 2 |  |  |
|  |  | 1746-IB16 |  | 1746-IB16 |  |  |  |  |


### Table 2

| CONTACTOR |
| --- |
| OVER |
| CURRENT |
| I:7 |
| 1 |
| 1746-IV16 |


### Table 3

| ALARM BIT |
| --- |
| ON |
| B3:0 |
| L 14 |


### Table 4

| SCR DRIVE BIT |
| --- |
| B3:2 |
| 13 |


### Table 5

| SCR OFF DELAY |
| --- |
| T4:18 |
| DN |


### Table 6

| SCR DRIVER |
| --- |
| LATCH |
| B3:3 |
| 14 |


### Table 7

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 8

|  |  |
| --- | --- |
|  | SCR DRIVER |
|  | LATCH |
|  | B3:3 |
|  | 14 |


### Table 9

| ALARM BIT |
| --- |
| ON |
| B3:0 |
| L 14 |


### Table 10

| H1_SCR_LATCH |  |
| --- | --- |
| O:1 |  |
|  | 124 |
| 1747-DCM-FULL |  |


---
## Page 13

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
SCR DRIVER SCR DISABLE REGULATOR
UPPER FIBER DR ON SCR DRIVE BIT SCR OFF DELAY
I:6 I:6 B3:0 B3:2 T4:18
0026
6 0 2 13 DN
1746-IB16 1746-IB16
SCR DRIVER
UP LATCH RESET
B3:3 B3:0
15 10
SCR DRIVER
UP LATCH
B3:3
15
ALARM BIT
ON
B3:0
L
14
H2_SCR_LATCH
O:1
125
1747-DCM-FULL
CONTACTOR CLOSE
DELAY AB CROWBAR
T4:16 O:5
0027
TT 3
1746-OX8
SCR DRIVER
UP LATCH
B3:3
15
SCR DRIVER
LATCH
B3:3
14
AUX PWR ON AUX PWR
DISPLAY SCR ON LATCH ALARM
B3:1 B3:0 B3:3
0028
8 4 10
AUX PWR ALARM BIT
LATCH RESET ON
B3:3 B3:0 B3:0
L
10 10 14
Page 12 Wednesday, June 23, 2021 - 14:35:03


### Table 1

| 0026 |  | SCR DRIVER |  |  |  | SCR DISABLE |  |  |  | REGULATOR |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | UPPER |  |  |  | FIBER DR |  |  |  | ON |  |  |
|  |  | I:6 |  |  |  | I:6 |  |  |  | B3:0 |  |  |
|  |  |  | 6 |  |  | 0 |  |  |  | 2 |  |  |
|  |  | 1746-IB16 |  |  |  | 1746-IB16 |  |  |  |  |  |  |
| 0027 |  | CONTACTOR CLOSE |  |  |  |  | AB CROWBAR O:5 |  |  |  |  |  |
|  |  | DELAY |  |  |  |  |  |  |  |  |  |  |
|  |  | T4:16 |  |  |  |  |  |  |  |  |  |  |
|  | TT 3 1746-OX8 SCR DRIVER UP LATCH B3:3 15 SCR DRIVER LATCH B3:3 14 | TT |  |  |  |  |  |  |  |  |  |  |
| 0028 |  | AUX PWR ON |  |  | SCR ON LATCH B3:0 |  |  |  |  |  | AUX PWR |  |
|  |  | DISPLAY |  |  |  |  |  |  |  |  | ALARM |  |
|  |  | B3:1 |  |  |  |  |  |  |  |  | B3:3 |  |
|  | 8 4 10 AUX PWR ALARM BIT LATCH RESET ON B3:3 B3:0 B3:0 L 10 10 14 | 8 |  |  |  |  |  |  |  |  | 10 |  |


### Table 2

| SCR DRIVE BIT |
| --- |
| B3:2 |
| 13 |


### Table 3

| SCR OFF DELAY |
| --- |
| T4:18 |
| DN |


### Table 4

| SCR DRIVER |
| --- |
| UP LATCH |
| B3:3 |
| 15 |


### Table 5

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 6

|  |  |
| --- | --- |
|  | SCR DRIVER |
|  | UP LATCH |
|  | B3:3 |
|  | 15 |


### Table 7

| ALARM BIT |
| --- |
| ON |
| B3:0 |
| L 14 |


### Table 8

| H2_SCR_LATCH |  |
| --- | --- |
| O:1 |  |
| 1 | 25 |
| 1747-DCM-FULL |  |


### Table 9

| AB CROWBAR |  |
| --- | --- |
| O:5 |  |
|  | 3 |
| 1746-OX8 |  |


### Table 10

| TT SCR DRIVER UP LATCH B3:3 |
| --- |
| 15 SCR DRIVER LATCH B3:3 |


### Table 11

| SCR DRIVER |
| --- |
| UP LATCH |
| B3:3 |
| 15 |


### Table 12

| SCR DRIVER |
| --- |
| LATCH |
| B3:3 |
| 14 |


### Table 13

| SCR ON LATCH |
| --- |
| B3:0 |
| 4 |


### Table 14

| AUX PWR |
| --- |
| LATCH |
| B3:3 |
| 10 |


### Table 15

| ALARM BIT |
| --- |
| ON |
| B3:0 |
| L 14 |


### Table 16

| RESET |
| --- |
| B3:0 |
| 10 |


---
## Page 14

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
CURRENT REGULATOR REGULATOR
LIMIT ON TRIP BIT
I:7 B3:0 B3:3
0029
12 2 9
1746-IV16
ALARM BIT
REGULATOR ON
TRIP BIT RESET B3:0
B3:3 B3:0 L
14
9 10
XFORMER
LATCHED
OK CONTACTOR CONTACTOR
OK READY
B3:2 B3:2 B3:0
0030
1 2 15
CONTACTOR
ENABLE
O:1
102
1747-DCM-FULL
CONTACTOR CONTACTOR OPEN
OPEN DISPLAY
I:7 B3:1
0031
2 3
1746-IV16
CONTACTOR
OPEN
O:1
103
1747-DCM-FULL
CONTACTOR
CONTACTOR CLOSED
CLOSED DISPLAY
I:7 B3:1
0032
2 11
1746-IV16
CROWBAR
ENABLE
O:5
L
4
1746-OX8
CONTACTOR
CLOSED
O:1
101
1747-DCM-FULL
Page 13 Wednesday, June 23, 2021 - 14:35:04


### Table 1

| 0029 |  |  | CURRENT |  |  |  |  |  | REGULATOR |  |  | REGULATOR |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  | LIMIT |  |  |  |  |  | ON |  |  | TRIP BIT |  |
|  |  |  | I:7 |  |  |  |  |  | B3:0 |  |  | B3:3 |  |
|  | 12 2 9 1746-IV16 ALARM BIT REGULATOR ON TRIP BIT RESET B3:0 B3:3 B3:0 L 14 9 10 |  |  |  | 12 |  |  |  | 2 |  |  | 9 |  |
|  |  |  | 1746-IV16 |  |  |  |  |  |  |  |  |  |  |
| 0030 |  | XFORMER |  |  |  | CONTACTOR CONTACTOR OK READY B3:2 B3:0 |  |  |  |  |  |  |  |
|  |  | LATCHED |  |  |  |  |  |  |  |  |  |  |  |
|  |  | OK |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | B3:2 |  |  |  |  |  |  |  |  |  |  |  |
|  | 1 2 15 CONTACTOR ENABLE O:1 102 1747-DCM-FULL | 1 |  |  |  |  |  |  |  |  |  |  |  |
| 0031 |  | CONTACTOR |  |  |  |  |  |  |  |  | CONTACTOR OPEN |  |  |
|  |  | OPEN |  |  |  |  |  |  |  |  | DISPLAY |  |  |
|  |  | I:7 |  |  |  |  |  |  |  |  | B3:1 |  |  |
|  | 2 3 1746-IV16 CONTACTOR OPEN O:1 103 1747-DCM-FULL |  |  | 2 |  |  |  |  |  |  | 3 |  |  |
|  |  | 1746-IV16 |  |  |  |  |  |  |  |  |  |  |  |
| 0032 | CONTACTOR CLOSED I:7 |  |  |  |  |  |  |  |  |  |  | CONTACTOR |  |
|  |  |  |  |  |  |  |  |  |  |  |  | CLOSED |  |
|  |  |  |  |  |  |  |  |  |  |  |  | DISPLAY |  |
|  |  |  |  |  |  |  |  |  |  |  |  | B3:1 |  |
|  | 2 11 1746-IV16 CROWBAR ENABLE O:5 L 4 1746-OX8 CONTACTOR CLOSED O:1 101 1747-DCM-FULL |  |  |  |  |  |  |  |  |  |  | 11 |  |


### Table 2

| ALARM BIT |
| --- |
| ON |
| B3:0 L |


### Table 3

| REGULATOR |
| --- |
| TRIP BIT B3:3 |
| 9 |


### Table 4

| RESET B3:0 |
| --- |
| 10 |


### Table 5

| CONTACTOR |
| --- |
| OK |
| B3:2 |
| 2 |


### Table 6

| CONTACTOR |
| --- |
| READY |
| B3:0 |
| 15 |


### Table 7

| CONTACTOR |  |
| --- | --- |
| ENABLE |  |
| O:1 |  |
|  | 102 |
| 1747-DCM-FULL |  |


### Table 8

| CONTACTOR |  |
| --- | --- |
| OPEN |  |
| O:1 |  |
|  | 103 |
| 1747-DCM-FULL |  |


### Table 9

| CONTACTOR |  |
| --- | --- |
| CLOSED |  |
| I:7 |  |
|  | 2 |
| 1746-IV16 |  |


### Table 10

| 11 CROWBAR ENABLE O:5 L |
| --- |
| 4 1746-OX8 CONTACTOR CLOSED O:1 |


### Table 11

| CROWBAR |  |
| --- | --- |
| ENABLE |  |
| O:5 L |  |
|  | 4 |
| 1746-OX8 |  |


### Table 12

| CONTACTOR |  |
| --- | --- |
| CLOSED |  |
| O:1 |  |
|  | 101 |
| 1747-DCM-FULL |  |


---
## Page 15

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
CROWBAR CROWBAR CROWBAR
TRIGGER OFF DELAY ENABLE
I:6 T4:12 O:5
0033 U
1 DN 4
1746-IB16 1746-OX8
CROWBAR
OFF DELAY
TTOONN
Timer On Delay EN
Timer T4:12
Time Base 0.01 DN
Preset 800<
Accum 0<
SYSTEM SYSTEM NOT
READY READY
B3:1 B3:1
0034
13 5
SCR ENABLE SLOW START
O:5 O:5
0035
0 5
1746-OX8 1746-OX8
ENERPRO
SLOW START
O:1
109
1747-DCM-FULL
FAST
INHIBIT
B3:0 TTOOFF
0036 Timer Off Delay EN
13 Timer T4:14
Time Base 0.01 DN
CURRENT Preset 300<
TRIP Accum 300<
I:7
15
1746-IV16
CONTACTOR
OVER
CURRENT
I:7
1
1746-IV16
BLOCKING
OVER"I"
I:7
0
1746-IV16
Page 14 Wednesday, June 23, 2021 - 14:35:04


### Table 1

| 0033 |  | CROWBAR |  |  |  |  |  | CROWBAR |  |  | CROWBAR |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | TRIGGER |  |  |  |  |  | OFF DELAY |  |  | ENABLE |  |  |  |  |  |
|  |  | I:6 |  |  |  |  |  | T4:12 |  |  | O:5 U |  |  |  |  |  |
|  | 1 DN 4 1746-IB16 1746-OX8 CROWBAR OFF DELAY TTOONN Timer On Delay EN Timer T4:12 Time Base 0.01 DN Preset 800< Accum 0< |  |  | 1 |  |  |  | DN |  |  |  |  |  | 4 |  |  |
|  |  | 1746-IB16 |  |  |  |  |  |  |  |  | 1746-OX8 |  |  |  |  |  |
| 0034 |  | SYSTEM |  |  |  |  |  |  |  |  |  | SYSTEM NOT |  |  |  |  |
|  |  | READY |  |  |  |  |  |  |  |  |  | READY |  |  |  |  |
|  |  | B3:1 |  |  |  |  |  |  |  |  |  | B3:1 |  |  |  |  |
|  | 13 5 | 13 |  |  |  |  |  |  |  |  |  | 5 |  |  |  |  |
| 0035 |  | SCR ENABLE |  |  |  |  |  |  |  | SLOW START |  |  |  |  |  |  |
|  |  | O:5 |  |  |  |  |  |  |  | O:5 |  |  |  |  |  |  |
|  | 0 5 1746-OX8 1746-OX8 ENERPRO SLOW START O:1 109 1747-DCM-FULL |  |  | 0 |  |  |  |  |  |  |  |  | 5 |  |  |  |
|  |  | 1746-OX8 |  |  |  |  |  |  |  | 1746-OX8 |  |  |  |  |  |  |
| 0036 |  |  | FAST |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | INHIBIT |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | B3:0 |  |  |  |  |  |  |  |  |  |  |  |  |  |


### Table 2

| CROWBAR |
| --- |
| OFF DELAY |


### Table 3

| Time Base 0.01 Preset 800 |  |
| --- | --- |
| Accum | 0 |


### Table 4

| ENERPRO |  |
| --- | --- |
| SLOW START |  |
| O:1 |  |
| 1 | 09 |
| 1747-DCM-FULL |  |


### Table 5

| 13 CURRENT TRIP I:7 |
| --- |
| 15 1746-IV16 CONTACTOR OVER CURRENT I:7 |
| 1 1746-IV16 BLOCKING OVER"I" I:7 |


### Table 6

| Time Base 0.01 Preset 300 |  |
| --- | --- |
| Accum | 300 |


### Table 7

| TRIP |  |
| --- | --- |
| I:7 |  |
|  | 15 |
| 1746-IV16 |  |


### Table 8

| CONTACTOR |  |
| --- | --- |
| OVER |  |
| CURRENT |  |
| I:7 |  |
|  | 1 |
| 1746-IV16 |  |


### Table 9

| BLOCKING |  |
| --- | --- |
| OVER"I" |  |
| I:7 |  |
|  | 0 |
| 1746-IV16 |  |


---
## Page 16

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
CROWBAR CROWBAR
ON ON
I:6 B3:1
0037
2 7
1746-IB16
CROWBAR
CROWBAR B3:3
LATCH
B3:4 1
10 CLOSE ALARM BIT
DELAY ON
T4:16 B3:0
L
TT 14
CROWBAR
ON
O:1
105
1747-DCM-FULL
12KV VOLTS 12KV ON
I:2 B3:1
0038
1 12
1746-IO8
12KV ON
O:1
97
1747-DCM-FULL
12KV OFF 12KV OFF
I:2 B3:1
0039
1 4
1746-IO8
CONTACTOR
CONTACTOR CNTRL PWR
READY DISPLAY
I:7 B3:1
0040
3 10
1746-IV16
CONTACTOR
CONTACTOR READY
CLOSED O:1
I:7
104
2 1747-DCM-FULL
1746-IV16
Page 15 Wednesday, June 23, 2021 - 14:35:04


### Table 1

| 0037 |  |  | CROWBAR |  |  |  |  |  | CROWBAR |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  | ON |  |  |  |  |  | ON |  |  |  |  |
|  |  |  | I:6 |  |  |  |  |  | B3:1 |  |  |  |  |
|  | 2 7 1746-IB16 CROWBAR CROWBAR B3:3 LATCH B3:4 1 10 CLOSE ALARM BIT DELAY ON T4:16 B3:0 L TT 14 CROWBAR ON O:1 105 1747-DCM-FULL |  | 2 |  |  |  |  |  | 7 |  |  |  |  |
|  |  |  | 1746-IB16 |  |  |  |  |  |  |  |  |  |  |
| 0038 |  | 12KV VOLTS |  |  |  |  |  |  |  | 12KV ON |  |  |  |
|  |  | I:2 |  |  |  |  |  |  |  | B3:1 |  |  |  |
|  | 1 12 1746-IO8 12KV ON O:1 97 1747-DCM-FULL |  |  | 1 |  |  |  |  |  | 12 |  |  |  |
|  |  | 1746-IO8 |  |  |  |  |  |  |  |  |  |  |  |
| 0039 |  | 12KV OFF |  |  |  |  |  |  |  |  | 12KV OFF |  |  |
|  |  | I:2 |  |  |  |  |  |  |  |  | B3:1 |  |  |
|  | 1 4 1746-IO8 |  |  | 1 |  |  |  |  |  |  | 4 |  |  |
|  |  | 1746-IO8 |  |  |  |  |  |  |  |  |  |  |  |
| 0040 | CONTACTOR READY I:7 |  |  |  |  |  |  | CONTACTOR |  |  |  |  |  |
|  |  |  |  |  |  |  |  | CNTRL PWR |  |  |  |  |  |
|  |  |  |  |  |  |  |  | DISPLAY |  |  |  |  |  |
|  |  |  |  |  |  |  |  | B3:1 |  |  |  |  |  |
|  | 3 10 1746-IV16 CONTACTOR CONTACTOR READY CLOSED O:1 I:7 104 2 1747-DCM-FULL 1746-IV16 |  |  |  |  |  |  | 10 |  |  |  |  |  |


### Table 2

| 7 CROWBAR B3:3 |
| --- |
| 1 CLOSE ALARM BIT DELAY ON T4:16 B3:0 |
| L TT 14 CROWBAR ON O:1 |


### Table 3

| CROWBAR |
| --- |
| B3:3 |


### Table 4

| CROWBAR |
| --- |
| LATCH B3:4 |
| 10 |


### Table 5

| DELAY |
| --- |
| T4:16 |
| TT |


### Table 6

| ON |
| --- |
| B3:0 |
| L 14 |


### Table 7

| CROWBAR |  |
| --- | --- |
| ON |  |
| O:1 |  |
| 1 | 05 |
| 1747-DCM-FULL |  |


### Table 8

| 12KV ON |  |
| --- | --- |
| O:1 |  |
| 9 | 7 |
| 1747-DCM-FULL |  |


### Table 9

| CONTACTOR |  |
| --- | --- |
| READY |  |
| I:7 |  |
|  | 3 |
| 1746-IV16 |  |


### Table 10

| CONTACTOR |
| --- |
| READY |
| O:1 |
| 104 1747-DCM-FULL |


### Table 11

| CONTACTOR |  |
| --- | --- |
| CLOSED I:7 |  |
|  | 2 |
| 1746-IV16 |  |


---
## Page 17

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
TRANSFORMER INTERLOCKS WHICH ARE LATCHING NORMALY CLOSED CONTACTS RESET PWR UP
XFORMER PRESSURE PRESSURE
RESET ALARM LATCH
B3:0 I:7 B3:4
0041
10 4 0
1746-IV16
PRESSURE PRESSURE
LATCH ALARM
B3:4
O:1
0
119
1747-DCM-FULL
TRANSFORMER VACUUM
XFORMER
RESET VACUUM VACUUM_LATCH
B3:0 I:7 B3:5
0042
10 5 12
1746-IV16
VACUUM_LATCH VACUUM_ALARM
B3:5 O:1
12 126
1747-DCM-FULL
XFORMER
OVER
RESET TEMP
B3:0 I:7 LLEESS LLEESS
0043 Less Than (A<B) Less Than (A<B)
10 6 Source A N7:100 Source A N7:101
1746-IV16 0< 0<
OIL TEMP Source B N7:108 Source B N7:109
LATCH 800< 800<
B3:4
1
OIL TEMP
B3:4
1
OIL OVERTEMP
O:1
111
1747-DCM-FULL
OVERTEMP
O:1
112
1747-DCM-FULL
Page 16 Wednesday, June 23, 2021 - 14:35:04


### Table 1

| 0041 | TRANSFORMER INTERLOCKS WHICH ARE LATCHING NORMALY CLOSED CONTACTS RESET PWR UP XFORMER PRESSURE PRESSURE RESET ALARM LATCH B3:0 I:7 B3:4 |  |  |
| --- | --- | --- | --- |
|  | 10 4 0 1746-IV16 PRESSURE PRESSURE LATCH ALARM B3:4 O:1 0 119 1747-DCM-FULL |  |  |
| 0042 | TRANSFORMER VACUUM XFORMER RESET VACUUM VACUUM_LATCH B3:0 I:7 B3:5 |  |  |
|  | 10 5 12 1746-IV16 VACUUM_LATCH VACUUM_ALARM B3:5 O:1 12 126 1747-DCM-FULL |  |  |
| 0043 | RESET B3:0 | XFORMER |  |
|  |  | OVER |  |
|  |  | TEMP |  |
|  |  | I:7 |  |
|  |  |  | 6 |
|  |  | 1746-IV16 |  |


### Table 2

| XFORMER PRESSURE |  |  | PRESSURE |
| --- | --- | --- | --- |
| ALARM |  |  | LATCH |
| I:7 |  |  | B3:4 |
| 4 |  |  | 0 |
| 1746-IV16 |  |  |  |


### Table 3

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 4

| PRESSURE |
| --- |
| LATCH |
| B3:4 |


### Table 5

| PRESSURE |  |
| --- | --- |
| ALARM |  |
| O:1 |  |
|  | 119 |
| 1747-DCM-FULL |  |


### Table 6

| XFORMER |  |
| --- | --- |
| VACUUM |  |
| I:7 |  |
|  | 5 |
| 1746-IV16 |  |


### Table 7

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 8

| VACUUM_LATCH |
| --- |
| B3:5 |
| 12 |


### Table 9

| VACUUM_LATCH |
| --- |
| B3:5 |
| 12 |


### Table 10

| VACUUM_ALARM |  |
| --- | --- |
| O:1 |  |
| 1 | 26 |
| 1747-DCM-FULL |  |


### Table 11

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 12

|  | 0 |  |
| --- | --- | --- |
| Source B |  | N7:108 |
|  | 800 |  |


### Table 13

|  | 0 |  |
| --- | --- | --- |
| Source B |  | N7:109 |
|  | 800 |  |


### Table 14

| OIL TEMP |
| --- |
| LATCH |
|  |
| B3:4 |
| 1 |


### Table 15

|  |  |
| --- | --- |
|  | OIL TEMP |
|  | B3:4 |
|  | 1 |


### Table 16

| 1 OIL OVERTEMP O:1 |
| --- |
| 111 1747-DCM-FULL OVERTEMP O:1 |


### Table 17

| OIL OVERTEMP |  |
| --- | --- |
| O:1 |  |
|  | 111 |
| 1747-DCM-FULL |  |


### Table 18

| OVERTEMP |  |
| --- | --- |
| O:1 |  |
|  | 112 |
| 1747-DCM-FULL |  |


---
## Page 18

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
CROWBAR SCR OIL SCR OIL
RESET OIL LEVEL LEVEL TANK LEVEL
B3:0 I:6 I:6 B3:4
0044
10 10 11 2
1746-IB16 1746-IB16
SCR OIL
TANK LEVEL
B3:4
2
LOW OIL
RESET LEVEL LOW OIL
B3:0 I:7 B3:4
0045
10 7 3
1746-IV16
LOW OIL LOW OIL
LATCH O:1
B3:4
110
3 1747-DCM-FULL
XFRMER SUDDEN SUDDEN
RESET PRESSURE PRESSURE
B3:0 I:7 B3:4
0046
10 8 4
1746-IV16
SUDDEN SUDDEN
PRESSURE PRESSURE
B3:4 O:1
4 118
1747-DCM-FULL
AC INTERLOCKS LATCHING WITH RESET AND OVERRIDE
OIL PUMP OIL PUMP
RESET FLOW FLOW
B3:0 I:7 B3:4
0047
10 9 7
1746-IV16
OIL PUMP
FLOW ON
B3:4 LATCH
B3:0
7
4
Page 17 Wednesday, June 23, 2021 - 14:35:04


### Table 1

| 0044 | RESET B3:0 |  |  | CROWBAR |  |  |  | SCR OIL |  |  |  |  | SCR OIL |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  | OIL LEVEL |  |  |  | LEVEL |  |  |  |  | TANK LEVEL |  |  |
|  |  |  |  | I:6 |  |  |  | I:6 |  |  |  |  | B3:4 |  |  |
|  | 10 10 11 2 1746-IB16 1746-IB16 SCR OIL TANK LEVEL B3:4 2 |  |  |  |  | 10 |  |  |  | 11 |  |  | 2 |  |  |
|  |  |  |  | 1746-IB16 |  |  |  | 1746-IB16 |  |  |  |  |  |  |  |
| 0045 | RESET B3:0 | LOW OIL |  |  |  | LOW OIL B3:4 |  |  |  |  |  |  |  |  |  |
|  |  | LEVEL |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | I:7 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 10 7 3 1746-IV16 LOW OIL LOW OIL LATCH O:1 B3:4 110 3 1747-DCM-FULL |  |  |  | 7 |  |  |  |  |  |  |  |  |  |  |
|  |  | 1746-IV16 |  |  |  |  |  |  |  |  |  |  |  |  |  |
| 0046 | RESET B3:0 |  | XFRMER SUDDEN |  |  |  |  |  |  |  |  | SUDDEN |  |  |  |
|  |  |  | PRESSURE |  |  |  |  |  |  |  |  | PRESSURE |  |  |  |
|  |  |  | I:7 |  |  |  |  |  |  |  |  | B3:4 |  |  |  |
|  | 10 8 4 1746-IV16 SUDDEN SUDDEN PRESSURE PRESSURE B3:4 O:1 4 118 1747-DCM-FULL |  |  |  |  | 8 |  |  |  |  |  | 4 |  |  |  |
|  |  |  | 1746-IV16 |  |  |  |  |  |  |  |  |  |  |  |  |
| 0047 | AC INTERLOCKS LATCHING WITH RESET AND OVERRIDE OIL PUMP OIL PUMP RESET FLOW FLOW B3:0 I:7 B3:4 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 10 9 7 1746-IV16 OIL PUMP FLOW ON B3:4 LATCH B3:0 7 4 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |


### Table 2

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 3

| SCR OIL |
| --- |
| TANK LEVEL |
| B3:4 |
| 2 |


### Table 4

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 5

| LOW OIL |
| --- |
| B3:4 |
| 3 |


### Table 6

| LOW OIL |
| --- |
| LATCH B3:4 |
| 3 |


### Table 7

| LOW OIL |
| --- |
| O:1 |
| 110 1747-DCM-FULL |


### Table 8

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 9

| SUDDEN |
| --- |
| PRESSURE |
| B3:4 |
| 4 |


### Table 10

| SUDDEN |  |
| --- | --- |
| PRESSURE |  |
| O:1 |  |
| 1 | 18 |
| 1747-DCM-FULL |  |


### Table 11

| OIL PUMP |  |  | OIL PUMP |
| --- | --- | --- | --- |
| FLOW |  |  | FLOW |
| I:7 |  |  | B3:4 |
|  | 9 |  | 7 |
| 1746-IV16 |  |  |  |


### Table 12

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 13

| OIL PUMP |
| --- |
| FLOW |
| B3:4 |


### Table 14

| ON |
| --- |
| LATCH B3:0 |
| 4 |


---
## Page 19

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
KLYSTRON
SCR DISABLE CROWBAR
RESET FIBER DR LATCH
B3:0 I:6 B3:2
0048
10 0 6
1746-IB16
KLYSTRON
CROWBAR CROWBAR ENABLE
LATCH FIBER DR
B3:2
I:6
6
1
1746-IB16
SCR ENABLE
O:5
0
1746-OX8
ARC TRIP
KLYSTRON
I:6
3
1746-IB16
SCR DISABLE KLYSTRON
FIBER DR SCR BIT
I:6 B3:2
0049
0 5
1746-IB16
RESET WATER_FLOW_SWITCH H20_FLOW_SWITCH
B3:0 I:7 B3:2
0050
10 10 7
1746-IV16
H20_FLOW_SWITCH
B3:2
7
DC POWER INTERLOCKS
RESET PHASE LOSS PHASE LOSS
B3:0 I:7 B3:2
0051
10 11 3
1746-IV16
PHASE LOSS
B3:2 ON
LATCH
3 B3:0
4
Page 18 Wednesday, June 23, 2021 - 14:35:05


### Table 1

| 0048 | SCR DISABLE RESET FIBER DR B3:0 I:6 |  |  |  |  |  |  | KLYSTRON |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  | CROWBAR |  |
|  |  |  |  |  |  |  |  | LATCH |  |
|  |  |  |  |  |  |  |  | B3:2 |  |
|  | 10 0 6 1746-IB16 KLYSTRON CROWBAR CROWBAR ENABLE LATCH FIBER DR B3:2 I:6 6 1 1746-IB16 SCR ENABLE O:5 0 1746-OX8 ARC TRIP KLYSTRON I:6 3 1746-IB16 |  |  |  |  |  |  | 6 |  |
| 0049 | SCR DISABLE KLYSTRON FIBER DR SCR BIT I:6 B3:2 |  |  |  |  |  |  |  |  |
|  | 0 5 1746-IB16 |  |  |  |  |  |  |  |  |
| 0050 |  | RESET |  | WATER_FLOW_SWITCH |  |  | H20_FLOW_SWITCH |  |  |
|  |  | B3:0 |  | I:7 |  |  | B3:2 |  |  |
|  | 10 10 7 1746-IV16 H20_FLOW_SWITCH B3:2 7 | 10 |  |  | 10 |  | 7 |  |  |
|  |  |  |  | 1746-IV16 |  |  |  |  |  |
| 0051 | DC POWER INTERLOCKS RESET PHASE LOSS PHASE LOSS B3:0 I:7 B3:2 |  |  |  |  |  |  |  |  |
|  | 10 11 3 1746-IV16 PHASE LOSS B3:2 ON LATCH 3 B3:0 4 |  |  |  |  |  |  |  |  |


### Table 2

| SCR DISABLE |  |
| --- | --- |
| FIBER DR |  |
| I:6 |  |
|  | 0 |
| 1746-IB16 |  |


### Table 3

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 4

| 0 1746-IB16 CROWBAR ENABLE FIBER DR I:6 |
| --- |
| 1 1746-IB16 SCR ENABLE O:5 |
| 0 1746-OX8 ARC TRIP KLYSTRON I:6 |


### Table 5

| KLYSTRON |
| --- |
| CROWBAR |
| LATCH |
| B3:2 |


### Table 6

| CROWBAR ENABLE |  |
| --- | --- |
| FIBER DR |  |
| I:6 |  |
|  | 1 |
| 1746-IB16 |  |


### Table 7

| SCR ENABLE |  |
| --- | --- |
| O:5 |  |
|  | 0 |
| 1746-OX8 |  |


### Table 8

| ARC TRIP |  |
| --- | --- |
| KLYSTRON |  |
| I:6 |  |
| 3 |  |
| 1746-IB16 |  |


### Table 9

| SCR DISABLE |  |  | KLYSTRON |
| --- | --- | --- | --- |
| FIBER DR |  |  | SCR BIT |
| I:6 |  |  | B3:2 |
|  | 0 |  | 5 |
| 1746-IB16 |  |  |  |


### Table 10

| H20_FLOW_SWITCH |
| --- |
| B3:2 |
| 7 |


### Table 11

| RESET |  | PHASE LOSS I:7 |  |  | PHASE LOSS |
| --- | --- | --- | --- | --- | --- |
| B3:0 |  |  |  |  | B3:2 |
| 10 |  |  | 11 |  | 3 |


### Table 12

| PHASE LOSS |
| --- |
| B3:2 |


---
## Page 20

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
GRN TANK GRN TANK
RESET OIL LEVEL OIL LEVEL
B3:0 I:6 B3:4
0052
10 8 14
1746-IB16
GRN TANK
OIL LEVEL
B3:4
14
CONTACTOR OVER
OVER REGULATOR CURRENT
RESET CURRENT CURRENT TRIP LATCH
B3:0 I:7 I:7 B3:4
0053
10 1 15 11
1746-IV16 1746-IV16
OVER AC CURRENT
CURRENT TRIP
LATCH O:1
B3:4
99
11 1747-DCM-FULL
T4:2
TT
OVER
VOLTAGE OVER VOLT
RESET TRIP LATCH
B3:0 I:7 B3:4
0054
10 14 12
1746-IV16
OVER VOLT OVER VOLT
LATCH LATCH
B3:4 O:1
12 113
1747-DCM-FULL
T4:2
TT
KLYSTRON ARC
ARC TRIP KLYSTRON
RESET KLYSTRON ARC TRIP
B3:0 I:6 B3:4
0055
10 3 13
1746-IB16
KLYSTRON ARC TRIP
ARC TRIP CONTACTOR O:1
B3:4 OPEN
I:7 100
13 1747-DCM-FULL
2
1746-IV16
Page 19 Wednesday, June 23, 2021 - 14:35:05


### Table 1

| 0052 | RESET B3:0 |  | GRN TANK |  |  |  |  |  | GRN TANK |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  | OIL LEVEL |  |  |  |  |  | OIL LEVEL |  |  |
|  |  |  | I:6 |  |  |  |  |  | B3:4 |  |  |
|  | 10 8 14 1746-IB16 GRN TANK OIL LEVEL B3:4 14 |  |  |  | 8 |  |  |  | 14 |  |  |
|  |  |  | 1746-IB16 |  |  |  |  |  |  |  |  |
| 0053 | RESET B3:0 | CONTACTOR |  |  |  |  | REGULATOR CURRENT TRIP I:7 | OVER |  |  |  |
|  |  | OVER |  |  |  |  |  | CURRENT |  |  |  |
|  |  | CURRENT |  |  |  |  |  | LATCH |  |  |  |
|  |  | I:7 |  |  |  |  |  | B3:4 |  |  |  |
|  | 10 1 15 11 1746-IV16 1746-IV16 OVER AC CURRENT CURRENT TRIP LATCH O:1 B3:4 99 11 1747-DCM-FULL T4:2 TT |  |  |  | 1 |  |  | 11 |  |  |  |
|  |  | 1746-IV16 |  |  |  |  |  |  |  |  |  |
| 0054 | RESET B3:0 |  |  | OVER |  | OVER VOLT LATCH B3:4 |  |  |  |  |  |
|  |  |  |  | VOLTAGE |  |  |  |  |  |  |  |
|  |  |  |  | TRIP |  |  |  |  |  |  |  |
|  |  |  |  | I:7 |  |  |  |  |  |  |  |
|  | 10 14 12 1746-IV16 OVER VOLT OVER VOLT LATCH LATCH B3:4 O:1 12 113 1747-DCM-FULL T4:2 TT |  |  |  | 14 |  |  |  |  |  |  |
|  |  |  |  | 1746-IV16 |  |  |  |  |  |  |  |
| 0055 | KLYSTRON ARC ARC TRIP KLYSTRON RESET KLYSTRON ARC TRIP B3:0 I:6 B3:4 |  |  |  |  |  |  |  |  |  |  |
|  | 10 3 13 1746-IB16 KLYSTRON ARC TRIP ARC TRIP CONTACTOR O:1 B3:4 OPEN I:7 100 13 1747-DCM-FULL 2 1746-IV16 |  |  |  |  |  |  |  |  |  |  |


### Table 2

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 3

| GRN TANK |
| --- |
| OIL LEVEL |
| B3:4 |
| 14 |


### Table 4

| REGULATOR |
| --- |
| CURRENT TRIP |
| I:7 |
| 15 |
| 1746-IV16 |


### Table 5

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 6

| 10 OVER CURRENT LATCH B3:4 |
| --- |
| 11 T4:2 |


### Table 7

| OVER |
| --- |
| CURRENT |
| LATCH B3:4 |
| 11 |


### Table 8

| AC CURRENT |
| --- |
| TRIP |
| O:1 |
| 99 1747-DCM-FULL |


### Table 9

| T4:2 |
| --- |
| TT |


### Table 10

| OVER VOLT |
| --- |
| LATCH |
| B3:4 |
| 12 |


### Table 11

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 12

| 10 OVER VOLT LATCH B3:4 |
| --- |
| 12 T4:2 |


### Table 13

| OVER VOLT |
| --- |
| LATCH |
| B3:4 |
| 12 |


### Table 14

| OVER VOLT |  |
| --- | --- |
| LATCH |  |
| O:1 |  |
|  | 113 |
| 1747-DCM-FULL |  |


### Table 15

| T4:2 |
| --- |
| TT |


### Table 16

| ARC TRIP |  | KLYSTRON |
| --- | --- | --- |
| KLYSTRON |  | ARC TRIP |
| I:6 |  | B3:4 |
| 3 |  | 13 |
| 1746-IB16 |  |  |


### Table 17

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 18

| KLYSTRON |
| --- |
| ARC TRIP B3:4 |


### Table 19

| ARC TRIP |
| --- |
| O:1 100 |


### Table 20

| CONTACTOR OPEN I:7 |
| --- |
| 2 |
| 1746-IV16 |


---
## Page 21

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
KLYSTRON CROWBAR
RESET KLYSTRON_CROWBAR _KLYSTRON_CROWBAR
B3:0 I:6 B3:2
0056
10 7 4
1746-IB16
_KLYSTRON_CROWBAR DCM_BIT
B3:2 O:1
4 123
1747-DCM-FULL
TRANSFORMER ARC
XFORMER XFORMER
RESET ARC ARC TRIP
B3:0 I:6 B3:4
0057
10 5 15
1746-IB16
XFORMER O:1
ARC TRIP CONTACTOR
B3:4 OPEN 122
I:7 1747-DCM-FULL
15
2
1746-IV16
VACUUM CONTACTOR CURRENT FAULT LATCHING
OVER
CONTACTOR CURRENT
CONTACTOR OVER TRIP
LOCKOUT CURRENT LATCH
I:7 I:7 B3:4
0058
0 1 5
1746-IV16 1746-IV16
CONTACTOR CONTACTOR
READY OK
I:7 B3:2
3 2
1746-IV16
CONTACTOR
CLOSED
I:7
2
1746-IV16
DC POWER INTERLOCKS LATCHING LATCH RESET
AUX PWR ON DC POWER
RESET FAULT
B3:0 B3:1 B3:4
0059
10 8 6
DC POWER OFF
LATCH B3:0
B3:4
0
6
Page 20 Wednesday, June 23, 2021 - 14:35:05


### Table 1

| 0056 | KLYSTRON CROWBAR |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | RESET |  |  | KLYSTRON_CROWBAR |  |  |  | _KLYSTRON_CROWBAR |  |  |
|  |  | B3:0 |  |  | I:6 |  |  |  | B3:2 |  |  |
|  | 10 7 4 1746-IB16 _KLYSTRON_CROWBAR DCM_BIT B3:2 O:1 4 123 1747-DCM-FULL | 10 |  |  | 7 |  |  |  | 4 |  |  |
|  |  |  |  |  | 1746-IB16 |  |  |  |  |  |  |
| 0057 | TRANSFORMER ARC XFORMER XFORMER RESET ARC ARC TRIP B3:0 I:6 B3:4 |  |  |  |  |  |  |  |  |  |  |
|  | RESET B3:0 |  |  | XFORMER |  |  |  |  |  | XFORMER |  |
|  |  |  |  | ARC |  |  |  |  |  | ARC TRIP |  |
|  |  |  |  | I:6 |  |  |  |  |  | B3:4 |  |
|  | 10 5 15 1746-IB16 XFORMER O:1 ARC TRIP CONTACTOR B3:4 OPEN 122 I:7 1747-DCM-FULL 15 2 1746-IV16 |  |  | 5 |  |  |  |  |  | 15 |  |
|  |  |  |  | 1746-IB16 |  |  |  |  |  |  |  |
| 0058 | VACUUM CONTACTOR CURRENT FAULT LATCHING |  |  |  |  |  |  |  |  |  |  |
|  | CONTACTOR CONTACTOR OVER LOCKOUT CURRENT I:7 I:7 |  |  |  |  |  |  |  |  | OVER |  |
|  |  |  |  |  |  |  |  |  |  | CURRENT |  |
|  |  |  |  |  |  |  |  |  |  | TRIP |  |
|  |  |  |  |  |  |  |  |  |  | LATCH |  |
|  |  |  |  |  |  |  |  |  |  | B3:4 |  |
|  | 0 1 5 1746-IV16 1746-IV16 CONTACTOR CONTACTOR READY OK I:7 B3:2 3 2 1746-IV16 CONTACTOR CLOSED I:7 2 1746-IV16 |  |  |  |  |  |  |  |  | 5 |  |
| 0059 | DC POWER INTERLOCKS LATCHING LATCH RESET AUX PWR ON DC POWER RESET FAULT B3:0 B3:1 B3:4 |  |  |  |  |  |  |  |  |  |  |
|  | RESET B3:0 |  |  | AUX PWR ON |  |  |  |  |  |  | DC POWER |
|  |  |  |  |  |  |  |  |  |  |  | FAULT |
|  |  |  |  | B3:1 |  |  |  |  |  |  | B3:4 |
|  | 10 8 6 DC POWER OFF LATCH B3:0 B3:4 0 6 |  |  | 8 |  |  |  |  |  |  | 6 |


### Table 2

| _KLYSTRON_CROWBAR |
| --- |
| B3:2 |
| 4 |


### Table 3

| DCM_BIT |  |
| --- | --- |
| O:1 |  |
|  | 123 |
| 1747-DCM-FULL |  |


### Table 4

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 5

| XFORMER ARC TRIP |
| --- |
| B3:4 |


### Table 6

| O:1 |
| --- |
| 122 1747-DCM-FULL |


### Table 7

| OPEN I:7 |  |
| --- | --- |
|  | 2 |
| 1746-IV16 |  |


### Table 8

| CONTACTOR |  |
| --- | --- |
| OVER |  |
| CURRENT |  |
| I:7 |  |
|  | 1 |
| 1746-IV16 |  |


### Table 9

| CONTACTOR |  |
| --- | --- |
| LOCKOUT |  |
| I:7 |  |
|  | 0 |
| 1746-IV16 |  |


### Table 10

| CONTACTOR |
| --- |
| READY |
| I:7 |
| 3 |
| 1746-IV16 |


### Table 11

| CONTACTOR |
| --- |
| OK |
| B3:2 |
| 2 |


### Table 12

| CONTACTOR |
| --- |
| CLOSED |
| I:7 |
| 2 |
| 1746-IV16 |


### Table 13

| RESET |
| --- |
| B3:0 |
| 10 |


### Table 14

| DC POWER |
| --- |
| LATCH B3:4 |
| 6 |


### Table 15

| OFF |
| --- |
| B3:0 |


---
## Page 22

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
OIL TEMP XFORMER
PRESSURE LATCH SCR OIL LOW OIL LATCHED
LATCH TANK LEVEL LATCH H20_FLOW_SWITCH OK
B3:4 B3:4 B3:4 B3:4 B3:2 B3:2
0060
0 1 2 3 7 1
XFORMER
XFORMER PRESSURE XFORMER OVER LOW OIL XFRMER SUDDEN
ALARM VACUUM TEMP LEVEL PRESSURE
I:7 I:7 I:7 I:7 I:7
0061
4 5 6 7 8
1746-IV16 1746-IV16 1746-IV16 1746-IV16 1746-IV16
CROWBAR SCR OIL NO XFORMER
OIL LEVEL LEVEL WATER_FLOW_SWITCH FAULT
I:6 I:6 I:7 B3:0
10 11 10 9
1746-IB16 1746-IB16 1746-IV16
120V AC AC AUX PWR
CTRL PWR ON
I:2 O:1
0062
0 98
1746-IO8 1747-DCM-FULL
120V AC AUX PWR ON
CTRL PWR 240V PWR 120V PWR DISPLAY
I:2 O:2 O:2 B3:1
0063
0 2 1 8
1746-IO8 1746-IO8 1746-IO8
AUX POWER
O:1
106
1747-DCM-FULL
KEY ENABLE
DISABLE
KEY ON DISPLAY
B3:1 B3:1
0064
9 2
Page 21 Wednesday, June 23, 2021 - 14:35:05


### Table 1

| 0060 | PRESSURE LATCH B3:4 |  |  |  | OIL TEMP | SCR OIL LOW OIL TANK LEVEL LATCH H20_FLOW_SWITCH B3:4 B3:4 B3:2 |  |  |  |  | XFORMER |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  | LATCH |  |  |  |  |  | LATCHED |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  | OK |  |  |  |
|  |  |  |  |  | B3:4 |  |  |  |  |  | B3:2 |  |  |  |
|  | 0 1 2 3 7 1 |  |  |  | 1 |  |  |  |  |  | 1 |  |  |  |
| 0061 | XFORMER PRESSURE XFORMER ALARM VACUUM I:7 I:7 |  |  |  |  |  | XFORMER |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | OVER |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | TEMP |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | I:7 |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  | 6 |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 1746-IV16 |  |  |  |  |  |  |  |
| 0062 |  | 120V AC |  |  |  |  |  |  |  | AC AUX PWR |  |  |  |  |
|  |  | CTRL PWR |  |  |  |  |  |  |  | ON |  |  |  |  |
|  |  | I:2 |  |  |  |  |  |  |  | O:1 |  |  |  |  |
|  | 0 98 1746-IO8 1747-DCM-FULL |  | 0 |  |  |  |  |  |  |  |  | 98 |  |  |
|  |  | 1746-IO8 |  |  |  |  |  |  |  | 1747-DCM-FULL |  |  |  |  |
| 0063 |  | 120V AC |  | 240V PWR 120V PWR O:2 O:2 |  |  |  |  | AUX PWR ON |  |  |  |  |  |
|  |  | CTRL PWR |  |  |  |  |  |  | DISPLAY |  |  |  |  |  |
|  |  | I:2 |  |  |  |  |  |  | B3:1 |  |  |  |  |  |
|  | 0 2 1 8 1746-IO8 1746-IO8 1746-IO8 AUX POWER O:1 106 1747-DCM-FULL |  | 0 |  |  |  |  |  | 8 |  |  |  |  |  |
|  |  | 1746-IO8 |  |  |  |  |  |  |  |  |  |  |  |  |
| 0064 | KEY ENABLE DISABLE KEY ON DISPLAY B3:1 B3:1 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 9 2 |  |  |  |  |  |  |  |  |  |  |  |  |  |


### Table 2

| PRESSURE |
| --- |
| LATCH |
| B3:4 |
| 0 |


### Table 3

| SCR OIL |
| --- |
| TANK LEVEL |
| B3:4 |
| 2 |


### Table 4

| LOW OIL |
| --- |
| LATCH |
| B3:4 |
| 3 |


### Table 5

| H20_FLOW_SWITCH |
| --- |
| B3:2 |
| 7 |


### Table 6

| XFORMER PRESSURE |
| --- |
| ALARM |
| I:7 |
| 4 |
| 1746-IV16 |


### Table 7

| XFORMER |  |
| --- | --- |
| VACUUM |  |
| I:7 |  |
|  | 5 |
| 1746-IV16 |  |


### Table 8

| LOW OIL |  |
| --- | --- |
| LEVEL |  |
| I:7 |  |
|  | 7 |
| 1746-IV16 |  |


### Table 9

| XFRMER SUDDEN |
| --- |
| PRESSURE |
| I:7 |
| 8 |
| 1746-IV16 |


### Table 10

|  |  |  |
| --- | --- | --- |
|  | CROWBAR |  |
|  | OIL LEVEL |  |
|  | I:6 |  |
|  |  | 10 |
|  | 1746-IB16 |  |


### Table 11

| SCR OIL |  |
| --- | --- |
| LEVEL |  |
| I:6 |  |
|  | 11 |
| 1746-IB16 |  |


### Table 12

| NO XFORMER |
| --- |
| FAULT |
| B3:0 |
| 9 |


### Table 13

| WATER_FLOW_SWITCH |
| --- |
| I:7 |
| 10 |
| 1746-IV16 |


### Table 14

| 240V PWR |  |
| --- | --- |
| O:2 |  |
|  | 2 |
| 1746-IO8 |  |


### Table 15

| 120V PWR |  |
| --- | --- |
| O:2 |  |
|  | 1 |
| 1746-IO8 |  |


### Table 16

| AUX POWER |  |
| --- | --- |
| O:1 |  |
|  | 106 |
| 1747-DCM-FULL |  |


### Table 17

| DISABLE |
| --- |
| DISPLAY |
| B3:1 |
| 2 |


### Table 18

| KEY ON |
| --- |
| B3:1 |
| 9 |


---
## Page 23

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
120V AC NO XFORMER MOMENTARY
CTRL PWR FAULT RESET REG RESET
I:2 B3:0 T4:0 O:5
0065
0 9 TT 7
1746-IO8 1746-OX8
POWER UP CONTACTS
T4:7
TT
POWER UP
RESET
TTOONN
Timer On Delay EN
Timer T4:7
Time Base 0.01 DN
Preset 300<
Accum 0<
TURN ON SEQUENCE
120V AC TURN ON
CTRL PWR DELAY
I:2 TTOONN
0066 Timer On Delay EN
0 Timer T4:1
1746-IO8 Time Base 0.01 DN
Preset 1000<
Accum 0<
30V DELAY RESET
DELAY
T4:1 TTOONN
0067 Timer On Delay EN
DN Timer T4:2
Time Base 0.01 DN
Preset 300<
Accum 0<
OFF BIAS ON
B3:0 T4:2 TTOONN
0068 Timer On Delay EN
0 DN Timer T4:3
Time Base 0.01 DN
TOUCH PANEL Preset 300<
PPS-2 ON (KEY) ENABLE Accum 0<
I:6 I:6
15 12 GRD SWITCH RELAY BIAS PWR
1746-IB16 1746-IB16 O:2 O:2
3 0
1746-IO8 1746-IO8
Page 22 Wednesday, June 23, 2021 - 14:35:05


### Table 1

| 0065 |  | 120V AC |  |  |  |  | NO XFORMER |  | MOMENTARY | REG RESET O:5 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | CTRL PWR |  |  |  |  | FAULT |  | RESET |  |
|  |  | I:2 |  |  |  |  | B3:0 |  | T4:0 |  |
|  | 0 9 TT 7 1746-IO8 1746-OX8 POWER UP CONTACTS T4:7 TT POWER UP RESET TTOONN Timer On Delay EN Timer T4:7 Time Base 0.01 DN Preset 300< Accum 0< |  |  | 0 |  |  | 9 |  | TT |  |
|  |  | 1746-IO8 |  |  |  |  |  |  |  |  |
| 0066 | TURN ON SEQUENCE 120V AC TURN ON CTRL PWR DELAY I:2 TTOONN Timer On Delay EN 0 Timer T4:1 1746-IO8 Time Base 0.01 DN Preset 1000< Accum 0< |  |  |  |  |  |  |  |  |  |
| 0067 |  | 30V DELAY |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
|  |  | T4:1 |  |  |  |  |  |  |  |  |
| 0068 |  |  | OFF |  |  | BIAS ON |  |  |  |  |
|  |  |  | B3:0 |  |  | T4:2 |  |  |  |  |


### Table 2

| REG RESET |  |
| --- | --- |
| O:5 |  |
| 7 |  |
| 1746-OX8 |  |


### Table 3

| POWER UP CONTACTS |
| --- |
| T4:7 |
| TT |


### Table 4

| POWER UP |
| --- |
| RESET |


### Table 5

| Time Base 0.01 Preset 300 |  |
| --- | --- |
| Accum | 0 |


### Table 6

| 120V AC |
| --- |
| CTRL PWR |
| I:2 |
| 0 |


### Table 7

| TURN ON |
| --- |
| DELAY |


### Table 8

| Time Base 0.01 Preset 1000 |  |
| --- | --- |
| Accum | 0 |


### Table 9

| RESET |
| --- |
| DELAY |


### Table 10

| Time Base 0.01 Preset 300 |  |
| --- | --- |
| Accum | 0 |


### Table 11

| Time Base 0.01 Preset 300 |  |
| --- | --- |
| Accum | 0 |


### Table 12

| PPS-2 ON |  |
| --- | --- |
| I:6 |  |
|  | 15 |


### Table 13

| (KEY) ENABLE |
| --- |
| I:6 |
| 12 |


### Table 14

| O:2 |
| --- |
| 3 |
| 1746-IO8 |


### Table 15

| O:2 |  |
| --- | --- |
|  | 0 |
| 1746-IO8 |  |


---
## Page 24

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
120V
T4:3 TTOONN
0069 Timer On Delay EN
DN Timer T4:4
Time Base 0.01 DN
Preset 300<
Accum 0<
120VDC AC
O:2
1
1746-IO8
240V 240VDC AC
T4:4 O:2
0070
DN 2
1746-IO8
#1 SCR LATCHING WITH RESET AND OVERRIDE
SCR DRIVER SCR1 LATCH
UPPER BIT
B3:3 B3:4
0071
15 8
SCR 2
SCR TRIG#2 STATUS
I:6 O:1
6 115
1746-IB16 1747-DCM-FULL
SCR 2 STATUS
B3:5
11
#2 SCR LATCHING WITH RESET AND OVERRIDE
SCR DRIVER SCR2 LATCH
LOWER BIT
B3:3 B3:4
0072
14 9
SCR 1
SCR TRIG#1 STATUS
I:6 O:1
4 114
1746-IB16 1747-DCM-FULL
SCR 1 STATUS
B3:5
10
Page 23 Wednesday, June 23, 2021 - 14:35:06


### Table 1

| 0069 |  | 120V |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- |
|  |  | T4:3 |  |  |  |  |
| 0070 |  | 240V |  | 240VDC AC |  |  |
|  |  | T4:4 |  | O:2 |  |  |
|  | DN 2 1746-IO8 | DN |  |  | 2 |  |
|  |  |  |  | 1746-IO8 |  |  |
| 0071 | #1 SCR LATCHING WITH RESET AND OVERRIDE SCR DRIVER SCR1 LATCH UPPER BIT B3:3 B3:4 |  |  |  |  |  |
|  | 15 8 SCR 2 SCR TRIG#2 STATUS I:6 O:1 6 115 1746-IB16 1747-DCM-FULL SCR 2 STATUS B3:5 11 |  |  |  |  |  |
| 0072 | #2 SCR LATCHING WITH RESET AND OVERRIDE SCR DRIVER SCR2 LATCH LOWER BIT B3:3 B3:4 |  |  |  |  |  |
|  | 14 9 SCR 1 SCR TRIG#1 STATUS I:6 O:1 4 114 1746-IB16 1747-DCM-FULL SCR 1 STATUS B3:5 10 |  |  |  |  |  |


### Table 2

| Time Base 0.0 Preset 30 |  |
| --- | --- |
| Accum |  |


### Table 3

| 120VDC AC |  |
| --- | --- |
| O:2 |  |
|  | 1 |
| 1746-IO8 |  |


### Table 4

| SCR DRIVER |  | SCR1 LATCH |
| --- | --- | --- |
| UPPER BIT |  |  |
| B3:3 |  | B3:4 |
| 15 |  | 8 |


### Table 5

| SCR 2 |  |
| --- | --- |
| STATUS |  |
| O:1 |  |
|  | 115 |
| 1747-DCM-FULL |  |


### Table 6

| SCR TRIG#2 |  |
| --- | --- |
| I:6 |  |
|  | 6 |
| 1746-IB16 |  |


### Table 7

| SCR 2 STATUS |
| --- |
| B3:5 |
| 11 |


### Table 8

| SCR DRIVER |  | SCR2 LATCH |
| --- | --- | --- |
| LOWER BIT |  |  |
| B3:3 |  | B3:4 |
| 14 |  | 9 |


### Table 9

| SCR 1 |  |
| --- | --- |
| STATUS |  |
| O:1 |  |
|  | 114 |
| 1747-DCM-FULL |  |


### Table 10

| SCR TRIG#1 |  |
| --- | --- |
| I:6 |  |
|  | 4 |
| 1746-IB16 |  |


### Table 11

| SCR 1 STATUS |
| --- |
| B3:5 |
| 10 |


---
## Page 25

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
GROUNDING
GROUND SW SWITCH
OPEN OPEN
I:7 B3:2
0073
13 0
1746-IV16
SCR TRIG#1 SUPPLY ON
I:6 B3:1
0074
4 15
1746-IB16
SCR OFF DELAY
SCR TRIG#2 TTOOFF
I:6 Timer Off Delay EN
Timer T4:18
6 Time Base 0.01 DN
1746-IB16 Preset 5<
Accum 5<
SCR ON
B3:1
14
SCR ON SCR OFF
B3:1 B3:1
0075
14 6
FEEDBACK VOLTAGE
OFFSET
FEEDBACK
AADDDD
0076 Add
Source A I:8.0
97<
Source B N7:19
-122<
Dest N7:12
1<
VOLTAGE FEEDBACK
FEEDBACK
N7:12 MMOOVV
0077 Move
15 Source 0
0<
Dest N7:12
1<
Page 24 Wednesday, June 23, 2021 - 14:35:06


### Table 1

| 0073 | GROUND SW OPEN I:7 |  |  |  |  |  | GROUNDING |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  | SWITCH |  |  |  |
|  |  |  |  |  |  |  | OPEN |  |  |  |
|  |  |  |  |  |  |  | B3:2 |  |  |  |
|  | 13 0 1746-IV16 |  |  |  |  |  | 0 |  |  |  |
| 0074 |  |  | SCR TRIG#1 |  |  | SUPPLY ON |  |  |  |  |
|  |  |  | I:6 |  |  | B3:1 |  |  |  |  |
|  | 4 15 1746-IB16 SCR OFF DELAY SCR TRIG#2 TTOOFF I:6 Timer Off Delay EN Timer T4:18 6 Time Base 0.01 DN 1746-IB16 Preset 5< Accum 5< SCR ON B3:1 14 |  | 4 |  |  | 15 |  |  |  |  |
|  |  |  | 1746-IB16 |  |  |  |  |  |  |  |
| 0075 |  | SCR ON |  |  |  |  |  | SCR OFF |  |  |
|  |  | B3:1 |  |  |  |  |  | B3:1 |  |  |
|  | 14 6 | 14 |  |  |  |  |  | 6 |  |  |
| 0076 | FEEDBACK VOLTAGE OFFSET FEEDBACK AADDDD Add Source A I:8.0 97< Source B N7:19 -122< Dest N7:12 1< |  |  |  |  |  |  |  |  |  |
| 0077 | VOLTAGE FEEDBACK FEEDBACK N7:12 MMOOVV Move 15 Source 0 0< Dest N7:12 1< |  |  |  |  |  |  |  |  |  |


### Table 2

| GROUND SW |
| --- |
| OPEN |
| I:7 |
| 13 |
| 1746-IV16 |


### Table 3

| SCR TRIG#2 I:6 |
| --- |
| 6 1746-IB16 |


### Table 4

| Time Base 0.01 Preset 5 |  |
| --- | --- |
| Accum | 5 |


### Table 5

| SCR ON |
| --- |
| B3:1 |
| 14 |


### Table 6

| OFFSET |
| --- |
| FEEDBACK |


### Table 7

| Source A |  |  | I:8.0 |
| --- | --- | --- | --- |
|  | 97 |  |  |
| Source B |  |  | N7:19 |
|  | -122 |  |  |
| Dest |  | N7:12 |  |
|  | 1 |  |  |


### Table 8

| N7:12 |
| --- |
| 15 |


### Table 9

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:12 |
|  | 1 |  |


---
## Page 26

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
AC CURRENT
MONITOR
AADDDD
0078 Add
Source A I:9.0
136<
Source B N7:9
-117<
Dest N7:14
0<
AC CURRENT
AC CURRENT
MONITOR
N7:14 MMOOVV
0079 Move
15 Source 0
0<
Dest N7:14
0<
VOLTAGE MONITOR #1
VOLTAGE
MONITOR #1
MMOOVV
0080 Move
Source I:9.1
-1<
Dest N7:15
1<
VOLTAGE
MONITOR #1
NNEEGG
Negate
Source N7:15
1<
Dest N7:15
1<
OVERFLOW
BIT
S:5
U
0
Page 25 Wednesday, June 23, 2021 - 14:35:06


### Table 1

| 0078 | AC CURRENT MONITOR AADDDD Add Source A I:9.0 136< Source B N7:9 -117< Dest N7:14 0< |
| --- | --- |
| 0079 | AC CURRENT AC CURRENT MONITOR N7:14 MMOOVV Move 15 Source 0 0< Dest N7:14 0< |
| 0080 | VOLTAGE MONITOR #1 VOLTAGE MONITOR #1 MMOOVV Move Source I:9.1 -1< Dest N7:15 1< VOLTAGE MONITOR #1 NNEEGG Negate Source N7:15 1< Dest N7:15 1< OVERFLOW BIT S:5 U 0 |


### Table 2

| AC CURRENT |
| --- |
| MONITOR |


### Table 3

| Source A |  |  | I:9.0 |
| --- | --- | --- | --- |
|  | 136 |  |  |
| Source B |  |  | N7:9 |
|  | -117 |  |  |
| Dest |  | N7:14 |  |
|  | 0 |  |  |


### Table 4

| AC CURRENT |
| --- |
| MONITOR |


### Table 5

| N7:14 |
| --- |
| 15 |


### Table 6

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:14 |
|  | 0 |  |


### Table 7

| VOLTAGE |
| --- |
| MONITOR #1 |


### Table 8

| Source |  |  | I:9.1 |
| --- | --- | --- | --- |
|  | -1 |  |  |
| Dest |  | N7:15 |  |
|  | 1 |  |  |


### Table 9

| VOLTAGE |
| --- |
| MONITOR #1 |


### Table 10

| Source |  |  | N7:15 |
| --- | --- | --- | --- |
|  | 1 |  |  |
| Dest |  | N7:15 |  |
|  | 1 |  |  |


### Table 11

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


---
## Page 27

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
VOLTAGE MONITOR #2
VOLTAGE
MONITOR #2
MMOOVV
0081 Move
Source I:9.2
15<
Dest N7:16
0<
VOLTAGE
MONITOR #2
NNEEGG
Negate
Source N7:16
0<
Dest N7:16
0<
OVERFLOW
BIT
S:5
U
0
DC CURRENT MONITOR
DC CURRENT
MONITOR
MMUULL
0082 Multiply
Source A I:9.3
1<
Source B 1
1<
Dest N7:17
11<
DC CURRENT MONITOR
DC CURRENT CURRENT
MONITOR MONITOR
N7:17 MMOOVV
0083 Move
15 Source 0
0<
Dest N7:17
11<
Page 26 Wednesday, June 23, 2021 - 14:35:06


### Table 1

| 0081 | VOLTAGE MONITOR #2 VOLTAGE MONITOR #2 MMOOVV Move Source I:9.2 15< Dest N7:16 0< VOLTAGE MONITOR #2 NNEEGG Negate Source N7:16 0< Dest N7:16 0< OVERFLOW BIT S:5 U 0 |
| --- | --- |
| 0082 | DC CURRENT MONITOR DC CURRENT MONITOR MMUULL Multiply Source A I:9.3 1< Source B 1 1< Dest N7:17 11< |
| 0083 | DC CURRENT MONITOR DC CURRENT CURRENT MONITOR MONITOR N7:17 MMOOVV Move 15 Source 0 0< Dest N7:17 11< |


### Table 2

| VOLTAGE |
| --- |
| MONITOR #2 |


### Table 3

| Source |  |  | I:9.2 |
| --- | --- | --- | --- |
|  | 15 |  |  |
| Dest |  | N7:16 |  |
|  | 0 |  |  |


### Table 4

| VOLTAGE |
| --- |
| MONITOR #2 |


### Table 5

| Source |  |  | N7:16 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Dest |  | N7:16 |  |
|  | 0 |  |  |


### Table 6

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 7

| DC CURRENT |
| --- |
| MONITOR |


### Table 8

| Source A |  |  | I:9.3 |
| --- | --- | --- | --- |
|  | 1 |  |  |
| Source B |  |  | 1 |
|  | 1 |  |  |
| Dest |  | N7:17 |  |
|  | 11 |  |  |


### Table 9

| DC CURRENT |
| --- |
| MONITOR |
| N7:17 |
| 15 |


### Table 10

| CURRENT |
| --- |
| MONITOR |


### Table 11

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:17 |
|  | 11 |  |


---
## Page 28

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
VOLTAGE MONITOR #1
VOLTAGE #1
MMUULL
0084 Multiply
Source A N7:12
1<
Source B N7:22
10075<
Dest N7:2
0<
OVERFLOW
BIT
S:5
U
0
DDDDVV
Double Divide
Source 32767
32767<
Dest N7:2
0<
NEG DETECT
N7:2 MMOOVV
0085 Move
15 Source 0
0<
Dest N7:2
0<
DISPLAY VOLTAGE
DISPLAY
Time Base VOLTAGE
S:4 B3:5 DDIIVV
0086 OSR Divide
2 1 Source A N7:15
1<
Source B N7:47
320<
Dest N7:37
0<
PLOT VOLTAGE
PLOT VOLTS
Time Base
S:4 B3:5 DDIIVV
0087 OSR Divide
2 2 Source A N7:2
0<
Source B N7:44
43<
Dest N7:34
0<
Page 27 Wednesday, June 23, 2021 - 14:35:06


### Table 1

| 0084 | VOLTAGE MONITOR #1 VOLTAGE #1 MMUULL Multiply Source A N7:12 1< Source B N7:22 10075< Dest N7:2 0< OVERFLOW BIT S:5 U 0 DDDDVV Double Divide Source 32767 32767< Dest N7:2 0< |  |
| --- | --- | --- |
| 0085 |  | NEG DETECT |
|  |  |  |
|  |  | N7:2 |
|  |  | 15 |
| 0086 | DISPLAY VOLTAGE DISPLAY Time Base VOLTAGE S:4 B3:5 DDIIVV OSR Divide 2 1 Source A N7:15 1< Source B N7:47 320< Dest N7:37 0< |  |
| 0087 | PLOT VOLTAGE PLOT VOLTS Time Base S:4 B3:5 DDIIVV OSR Divide 2 2 Source A N7:2 0< Source B N7:44 43< Dest N7:34 0< |  |


### Table 2

| Source A |  | N7:12 |
| --- | --- | --- |
|  | 1 |  |
| Source B |  | N7:22 |
|  | 10075 |  |
| Dest | N7:2 |  |
|  | 0 |  |


### Table 3

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 4

| Source |  | 32767 |
| --- | --- | --- |
|  | 32767 |  |
| Dest | N7:2 |  |
|  | 0 |  |


### Table 5

| 0 |  |
| --- | --- |
|  | N7:2 |
| 0 |  |


### Table 6

| DISPLAY |
| --- |
| VOLTAGE |


### Table 7

| Time Base |
| --- |
| S:4 |
| 2 |


### Table 8

| B3:5 |
| --- |
| OSR 1 |


### Table 9

|  | 1 |  |  |
| --- | --- | --- | --- |
| Source B |  |  | N7:47 |
|  | 320 |  |  |
| Dest |  | N7:37 |  |
|  | 0 |  |  |


### Table 10

| PLOT VOLTS |
| --- |
|  |


### Table 11

| Time Base |
| --- |
| S:4 |
| 2 |


### Table 12

| B3:5 |
| --- |
| OSR 2 |


### Table 13

|  | 0 |  |  |
| --- | --- | --- | --- |
| Source B |  |  | N7:44 |
|  | 43 |  |  |
| Dest |  | N7:34 |  |
|  | 0 |  |  |


---
## Page 29

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
PHASE ANGLE MONITOR
PHASE
MONITOR
MMOOVV
0088 Move
Source I:8.1
373<
Dest N7:13
21<
PHASE ANGL
VOLTAGE
MMUULL
Multiply
Source A N7:13
21<
Source B N7:23
1000<
Dest N7:3
1<
OVERFLOW
BIT
S:5
U
0
DDDDVV
Double Divide
Source 32767
32767<
Dest N7:3
1<
PHASE ANGLE VOLTAGE
NEG DETECT
N7:3 MMOOVV
0089 Move
15 Source 0
0<
Dest N7:3
1<
Page 28 Wednesday, June 23, 2021 - 14:35:07


### Table 1

| 0088 | PHASE ANGLE MONITOR |
| --- | --- |
| 0089 | PHASE ANGLE VOLTAGE NEG DETECT N7:3 MMOOVV Move 15 Source 0 0< Dest N7:3 1< |


### Table 2

| PHASE |
| --- |
| MONITOR |


### Table 3

| Source |  |  | I:8.1 |
| --- | --- | --- | --- |
|  | 373 |  |  |
| Dest |  | N7:13 |  |
|  | 21 |  |  |


### Table 4

| PHASE ANGL |
| --- |
| VOLTAGE |


### Table 5

| Source A |  |  | N7:13 |
| --- | --- | --- | --- |
|  | 21 |  |  |
| Source B |  |  | N7:23 |
|  | 1000 |  |  |
| Dest |  | N7:3 |  |
|  | 1 |  |  |


### Table 6

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 7

| Source |  |  | 32767 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Dest |  | N7:3 |  |
|  | 1 |  |  |


### Table 8

|  | NEG DETECT |
| --- | --- |
|  |  |
|  | N7:3 |
|  | 15 |


### Table 9

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:3 |
|  | 1 |  |


---
## Page 30

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
CURRENT MONITOR #1
AC CURRENT
MONITOR
MMUULL
0090 Multiply
Source A N7:14
0<
Source B N7:24
4600<
Dest N7:4
0<
OVERFLOW
BIT
S:5
U
0
AC CURRENT
MONITOR
DDDDVV
Double Divide
Source 32767
32767<
Dest N7:4
0<
STORE POWER
AC CURRENT AC CURRENT
MONITOR MONITOR
N7:4 MMOOVV
0091 Move
15 Source 0
0<
Dest N7:4
0<
Page 29 Wednesday, June 23, 2021 - 14:35:07


### Table 1

| 0090 | CURRENT MONITOR #1 AC CURRENT MONITOR MMUULL Multiply Source A N7:14 0< Source B N7:24 4600< Dest N7:4 0< OVERFLOW BIT S:5 U 0 AC CURRENT MONITOR DDDDVV Double Divide Source 32767 32767< Dest N7:4 0< |
| --- | --- |
| 0091 | STORE POWER AC CURRENT AC CURRENT MONITOR MONITOR N7:4 MMOOVV Move 15 Source 0 0< Dest N7:4 0< |


### Table 2

| AC CURRENT |
| --- |
| MONITOR |


### Table 3

| Source A |  |  | N7:14 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Source B |  |  | N7:24 |
|  | 4600 |  |  |
| Dest |  | N7:4 |  |
|  | 0 |  |  |


### Table 4

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 5

| AC CURRENT |
| --- |
| MONITOR |


### Table 6

| Source |  |  | 32767 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Dest |  | N7:4 |  |
|  | 0 |  |  |


### Table 7

| AC CURRENT |
| --- |
| MONITOR |
| N7:4 |
| 15 |


### Table 8

| AC CURRENT |
| --- |
| MONITOR |


### Table 9

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:4 |
|  | 0 |  |


---
## Page 31

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
KLY VOLTAGE DISPLAY
Time Base AC CURRENT
S:4 B3:5 MMOOVV
0092 OSR Move
3 8 Source N7:4
0<
Dest O:1.1
0<
CCOOPP
Copy File
Source #I:3.0
Dest #N7:100
Length 8
REG VOLTS
MMOOVV
Move
Source N7:10
0<
Dest O:1.2
0<
MONITOR
VOLTAGE
MMOOVV
Move
Source N7:15
1<
Dest O:1.3
1<
DC CURRENT
MMOOVV
Move
Source N7:17
11<
Dest O:1.4
11<
MAX VOLT
REFERANCE
MMOOVV
Move
Source N7:32
32000<
Dest O:1.5
0<
Page 30 Wednesday, June 23, 2021 - 14:35:07


### Table 1

| 0092 | KLY VOLTAGE DISPLAY Time Base AC CURRENT S:4 B3:5 MMOOVV OSR Move 3 8 Source N7:4 0< Dest O:1.1 0< CCOOPP Copy File Source #I:3.0 Dest #N7:100 Length 8 REG VOLTS MMOOVV Move Source N7:10 0< Dest O:1.2 0< MONITOR VOLTAGE MMOOVV Move Source N7:15 1< Dest O:1.3 1< DC CURRENT MMOOVV Move Source N7:17 11< Dest O:1.4 11< MAX VOLT REFERANCE MMOOVV Move Source N7:32 32000< Dest O:1.5 0< |  |  |  |
| --- | --- | --- | --- | --- |
|  | OSR 3 8 |  |  |  |
|  |  |  |  |  |
|  |  | Wednesday, June 23, 2021 - 14: | 35: | 07 |


### Table 2

| Time Base |
| --- |
| S:4 |
| 3 |


### Table 3

| B3:5 |
| --- |
| OSR 8 |


### Table 4

|  | 0 |  |
| --- | --- | --- |
| Dest |  | O:1.1 |
|  | 0 |  |


### Table 5

| Source |  | #I:3.0 |
| --- | --- | --- |
| Dest | #N7:100 |  |
| Length |  | 8 |


### Table 6

| Source |  |  | N7:10 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Dest |  | O:1.2 |  |
|  | 0 |  |  |


### Table 7

| MONITOR |
| --- |
| VOLTAGE |


### Table 8

| Source |  |  | N7:15 |
| --- | --- | --- | --- |
|  | 1 |  |  |
| Dest |  | O:1.3 |  |
|  | 1 |  |  |


### Table 9

| Source |  |  | N7:17 |
| --- | --- | --- | --- |
|  | 11 |  |  |
| Dest |  | O:1.4 |  |
|  | 11 |  |  |


### Table 10

| MAX VOLT |
| --- |
| REFERANCE |


### Table 11

| Source |  |  | N7:32 |
| --- | --- | --- | --- |
|  | 32000 |  |  |
| Dest |  | O:1.5 |  |
|  | 0 |  |  |


### Table 12

| Page 30 |  |
| --- | --- |


---
## Page 32

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
MAX VOLT
REFERANCE
GGRRTT MMOOVV
Greater Than (A>B) Move
Source A N7:32 Source N7:33
32000< 0<
Source B N7:33 Dest O:1.5
0< 0<
MMOOVV
Move
Source I:1.2
19660<
Dest N7:33
0<
TRANSMIT DATA
PLOT
Time Base CURRENT
S:4 B3:5 DDIIVV
0093 OSR Divide
2 4 Source A N7:4
0<
Source B N7:45
7<
Dest N7:35
0<
AC CURRENT
MMOOVV
Move
Source N7:14
0<
Dest O:1.1
0<
DISPLAY CURRENT
DISPLAY
Time Base CURRENT
S:4 B3:5 DDIIVV
0094 OSR Divide
2 5 Source A N7:17
11<
Source B N7:48
198<
Dest N7:38
0<
Page 31 Wednesday, June 23, 2021 - 14:35:07


### Table 1

| LAD 2 - --- | Total Rungs in File = 120 |
| --- | --- |


### Table 2

|  |  |  |  |
| --- | --- | --- | --- |
|  | MAX VOLT REFERANCE GGRRTT MMOOVV Greater Than (A>B) Move Source A N7:32 Source N7:33 32000< 0< Source B N7:33 Dest O:1.5 0< 0< MMOOVV Move Source I:1.2 19660< Dest N7:33 0< |  |  |
| 0093 | TRANSMIT DATA PLOT Time Base CURRENT S:4 B3:5 DDIIVV OSR Divide 2 4 Source A N7:4 0< Source B N7:45 7< Dest N7:35 0< AC CURRENT MMOOVV Move Source N7:14 0< Dest O:1.1 0< |  |  |
| 0094 | DISPLAY CURRENT DISPLAY Time Base CURRENT S:4 B3:5 DDIIVV OSR Divide 2 5 Source A N7:17 11< Source B N7:48 198< Dest N7:38 0< |  |  |


### Table 3

| MAX VOLT |
| --- |
| REFERANCE |


### Table 4

| Source A |  | N7:32 |
| --- | --- | --- |
|  | 32000 |  |
| Source B |  | N7:33 |
|  | 0 |  |


### Table 5

| Source |  |  | N7:33 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Dest |  | O:1.5 |  |
|  | 0 |  |  |


### Table 6

| Source |  |  | I:1.2 |
| --- | --- | --- | --- |
|  | 19660 |  |  |
| Dest |  | N7:33 |  |
|  | 0 |  |  |


### Table 7

| PLOT |
| --- |
| CURRENT |


### Table 8

| Time Base |
| --- |
| S:4 |
| 2 |


### Table 9

| B3:5 |
| --- |
| OSR 4 |


### Table 10

|  | 0 |  |  |
| --- | --- | --- | --- |
| Source B |  |  | N7:45 |
|  | 7 |  |  |
| Dest |  | N7:35 |  |
|  | 0 |  |  |


### Table 11

| Source |  |  | N7:14 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Dest |  | O:1.1 |  |
|  | 0 |  |  |


### Table 12

| DISPLAY |
| --- |
| CURRENT |


### Table 13

| Time Base |
| --- |
| S:4 |
| 2 |


### Table 14

| B3:5 |
| --- |
| OSR 5 |


### Table 15

|  | 11 |  |  |
| --- | --- | --- | --- |
| Source B |  |  | N7:48 |
|  | 198 |  |  |
| Dest |  | N7:38 |  |
|  | 0 |  |  |


---
## Page 33

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
VOLTAGE X
CURRENT
MMUULL
0095 Multiply
Source A N7:15
1<
Source B N7:17
11<
Dest N7:18
0<
OVERFLOW
BIT
S:5
U
0
VOLTAGE X
CURRENT
DDDDVV
Double Divide
Source 32767
32767<
Dest N7:18
0<
POWER METER
PLOT
Time Base METER
S:4 B3:5 DDIIVV
0096 OSR Divide
2 6 Source A N7:18
0<
Source B N7:49
162<
Dest N7:39
0<
DISPLAY POWER
DISPLAY
Time Base POWER
S:4 B3:5 DDIIVV
0097 OSR Divide
2 7 Source A N7:18
0<
Source B N7:46
260<
Dest N7:36
0<
Page 32 Wednesday, June 23, 2021 - 14:35:07


### Table 1

| 0095 | VOLTAGE X CURRENT MMUULL Multiply Source A N7:15 1< Source B N7:17 11< Dest N7:18 0< OVERFLOW BIT S:5 U 0 VOLTAGE X CURRENT DDDDVV Double Divide Source 32767 32767< Dest N7:18 0< |
| --- | --- |
| 0096 | POWER METER PLOT Time Base METER S:4 B3:5 DDIIVV OSR Divide 2 6 Source A N7:18 0< Source B N7:49 162< Dest N7:39 0< |
| 0097 | DISPLAY POWER DISPLAY Time Base POWER S:4 B3:5 DDIIVV OSR Divide 2 7 Source A N7:18 0< Source B N7:46 260< Dest N7:36 0< |


### Table 2

| VOLTAGE X |
| --- |
| CURRENT |


### Table 3

| Source A |  |  | N7:15 |
| --- | --- | --- | --- |
|  | 1 |  |  |
| Source B |  |  | N7:17 |
|  | 11 |  |  |
| Dest |  | N7:18 |  |
|  | 0 |  |  |


### Table 4

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 5

| VOLTAGE X |
| --- |
| CURRENT |


### Table 6

| Source |  |  | 32767 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Dest |  | N7:18 |  |
|  | 0 |  |  |


### Table 7

| PLOT |
| --- |
| METER |


### Table 8

| Time Base |
| --- |
| S:4 |
| 2 |


### Table 9

| B3:5 |
| --- |
| OSR 6 |


### Table 10

|  | 0 |  |  |
| --- | --- | --- | --- |
| Source B |  |  | N7:49 |
|  | 162 |  |  |
| Dest |  | N7:39 |  |
|  | 0 |  |  |


### Table 11

| DISPLAY |
| --- |
| POWER |


### Table 12

| Time Base |
| --- |
| S:4 |
| 2 |


### Table 13

| B3:5 |
| --- |
| OSR 7 |


### Table 14

|  | 0 |  |  |
| --- | --- | --- | --- |
| Source B |  |  | N7:46 |
|  | 260 |  |  |
| Dest |  | N7:36 |  |
|  | 0 |  |  |


---
## Page 34

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
VOLTAGE MONITOR #2
VOLTAGE
MONITOR #2
MMUULL
0098 Multiply
Source A N7:15
1<
Source B N7:25
10000<
Dest N7:5
0<
OVERFLOW
BIT
S:5
U
0
DDDDVV
Double Divide
Source 32767
32767<
Dest N7:5
0<
DC CURRENT
N7:5 MMOOVV
0099 Move
15 Source 0
0<
Dest N7:5
0<
AC VOLTAGE
AC VOLTAGE
MMUULL
0100 Multiply
Source A N7:16
0<
Source B N7:26
10000<
Dest N7:6
0<
OVERFLOW
BIT
S:5
U
0
DDDDVV
Double Divide
Source 32767
32767<
Dest N7:6
0<
Page 33 Wednesday, June 23, 2021 - 14:35:07


### Table 1

| 0098 | VOLTAGE MONITOR #2 VOLTAGE MONITOR #2 MMUULL Multiply Source A N7:15 1< Source B N7:25 10000< Dest N7:5 0< OVERFLOW BIT S:5 U 0 DDDDVV Double Divide Source 32767 32767< Dest N7:5 0< |
| --- | --- |
| 0099 | DC CURRENT N7:5 MMOOVV Move 15 Source 0 0< Dest N7:5 0< |
| 0100 | AC VOLTAGE AC VOLTAGE MMUULL Multiply Source A N7:16 0< Source B N7:26 10000< Dest N7:6 0< OVERFLOW BIT S:5 U 0 DDDDVV Double Divide Source 32767 32767< Dest N7:6 0< |


### Table 2

| VOLTAGE |
| --- |
| MONITOR #2 |
|  |


### Table 3

| Source A |  |  | N7:15 |
| --- | --- | --- | --- |
|  | 1 |  |  |
| Source B |  |  | N7:25 |
|  | 10000 |  |  |
| Dest |  | N7:5 |  |
|  | 0 |  |  |


### Table 4

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 5

| Source |  |  | 32767 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Dest |  | N7:5 |  |
|  | 0 |  |  |


### Table 6

| DC CURRENT |
| --- |
|  |


### Table 7

| N7:5 |
| --- |
| 15 |


### Table 8

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:5 |
|  | 0 |  |


### Table 9

| AC VOLTAGE |
| --- |
|  |


### Table 10

| Source A |  |  | N7:16 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Source B |  |  | N7:26 |
|  | 10000 |  |  |
| Dest |  | N7:6 |  |
|  | 0 |  |  |


### Table 11

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 12

| Source |  |  | 32767 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Dest |  | N7:6 |  |
|  | 0 |  |  |


---
## Page 35

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
N7:6 MMOOVV
0101 Move
15 Source 0
0<
Dest N7:6
0<
CURRENT #2
DC
CURRENT #2
MMUULL
0102 Multiply
Source A N7:17
11<
Source B N7:27
5000<
Dest N7:7
0<
OVERFLOW
BIT
S:5
U
0
DDDDVV
Double Divide
Source 32767
32767<
Dest N7:7
0<
NEG DETECT
N7:7 MMOOVV
0103 Move
15 Source 0
0<
Dest N7:7
0<
Page 34 Wednesday, June 23, 2021 - 14:35:08


### Table 1

| 0101 |  | N7:6 |
| --- | --- | --- |
|  |  | 15 |
| 0102 | CURRENT #2 DC CURRENT #2 MMUULL Multiply Source A N7:17 11< Source B N7:27 5000< Dest N7:7 0< OVERFLOW BIT S:5 U 0 DDDDVV Double Divide Source 32767 32767< Dest N7:7 0< |  |
| 0103 |  | NEG DETECT |
|  |  |  |
|  |  | N7:7 |
|  |  | 15 |


### Table 2

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:6 |
|  | 0 |  |


### Table 3

| DC |
| --- |
| CURRENT #2 |


### Table 4

| Source A |  |  | N7:17 |
| --- | --- | --- | --- |
|  | 11 |  |  |
| Source B |  |  | N7:27 |
|  | 5000 |  |  |
| Dest |  | N7:7 |  |
|  | 0 |  |  |


### Table 5

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 6

| Source |  |  | 32767 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Dest |  | N7:7 |  |
|  | 0 |  |  |


### Table 7

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:7 |
|  | 0 |  |


---
## Page 36

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
REGULATOR
ON RATE SINGLE SHOT
B3:0 S:4 B3:5
0104 OSR
2 2 0
VOLTAGE
REFERANCE
MMOOVV
Move
Source I:1.1
0<
Dest N7:30
100<
VOLTAGE
REFERANCE
GGRRTT MMOOVV
Greater Than (A>B) Move
Source A N7:31 Source N7:31
100< 100<
Source B N7:30 Dest N7:30
100< 100<
SSUUBB
Subtract
Source A N7:30
100<
Source B N7:10
0<
Dest N7:43
-3<
DDIIVV
Divide
Source A N7:43
-3<
Source B 10
10<
Dest N7:43
-3<
AADDDD
Add
Source A N7:10
0<
Source B N7:43
-3<
Dest N7:10
0<
Page 35 Wednesday, June 23, 2021 - 14:35:08


### Table 1

| 0104 |  | REGULATOR |
| --- | --- | --- |
|  |  | ON |
|  |  | B3:0 |
|  |  | 2 |


### Table 2

| RATE |
| --- |
| S:4 |
| 2 |


### Table 3

| SINGLE SHOT |
| --- |
| B3:5 |
| OSR 0 |


### Table 4

| VOLTAGE |
| --- |
| REFERANCE |


### Table 5

|  |  |  |
| --- | --- | --- |
|  |  |  |
| Wednesday, June 23, 2021 - 14: | 35: | 08 |


### Table 6

| Source |  |  | I:1.1 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Dest |  | N7:30 |  |
|  | 100 |  |  |


### Table 7

| VOLTAGE |
| --- |
| REFERANCE |


### Table 8

| Source A |  | N7:31 |
| --- | --- | --- |
|  | 100 |  |
| Source B |  | N7:30 |
|  | 100 |  |


### Table 9

| Source |  |  | N7:31 |
| --- | --- | --- | --- |
|  | 100 |  |  |
| Dest |  | N7:30 |  |
|  | 100 |  |  |


### Table 10

| Source A |  |  | N7:30 |
| --- | --- | --- | --- |
|  | 100 |  |  |
| Source B |  |  | N7:10 |
|  | 0 |  |  |
| Dest |  | N7:43 |  |
|  | -3 |  |  |


### Table 11

| Source A |  |  | N7:43 |
| --- | --- | --- | --- |
|  | -3 |  |  |
| Source B |  |  | 10 |
|  | 10 |  |  |
| Dest |  | N7:43 |  |
|  | -3 |  |  |


### Table 12

| Source A |  |  | N7:10 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Source B |  |  | N7:43 |
|  | -3 |  |  |
| Dest |  | N7:10 |  |
|  | 0 |  |  |


### Table 13

| Page 35 |  |
| --- | --- |


---
## Page 37

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
OVERFLOW
BIT
S:5
U
0
O:1
L
96
1747-DCM-FULL
REFERANCE
CONTROL
EEQQUU MMOOVV
Equal Move
Source A N7:43 Source N7:30
-3< 100<
Source B 0 Dest N7:10
0< 0<
REFERANCE
CONTROL
GGRRTT MMOOVV
Greater Than (A>B) Move
Source A N7:10 Source N7:32
0< 32000<
Source B N7:32 Dest N7:10
32000< 0<
O:1
U
96
1747-DCM-FULL
GGRRTT GGRRTT
Greater Than (A>B) Greater Than (A>B)
Source A N7:33 Source A N7:10
0< 0<
Source B 0 Source B N7:33
0< 0<
REFERANCE
CONTROL
MMOOVV
Move
Source N7:33
0<
Dest N7:10
0<
Page 36 Wednesday, June 23, 2021 - 14:35:08


### Table 1

| LAD | 2 - --- Total Rungs in File = 120 |
| --- | --- |


### Table 2

|  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- |
|  | OVERFLOW BIT S:5 U 0 O:1 L 96 1747-DCM-FULL REFERANCE CONTROL EEQQUU MMOOVV Equal Move Source A N7:43 Source N7:30 -3< 100< Source B 0 Dest N7:10 0< 0< REFERANCE CONTROL GGRRTT MMOOVV Greater Than (A>B) Move Source A N7:10 Source N7:32 0< 32000< Source B N7:32 Dest N7:10 32000< 0< O:1 U 96 1747-DCM-FULL GGRRTT GGRRTT Greater Than (A>B) Greater Than (A>B) Source A N7:33 Source A N7:10 0< 0< Source B 0 Source B N7:33 0< 0< REFERANCE CONTROL MMOOVV Move Source N7:33 0< Dest N7:10 0< | OVERFLOW BIT S:5 |  |  |  |  |
|  |  | U 0 O:1 L |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  | Wednesday, June 23, 2021 | - 14:35: |  | 08 |


### Table 3

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 4

| O:1 L |  |
| --- | --- |
|  | 96 |
| 1747-DCM-FULL |  |


### Table 5

| REFERANCE |
| --- |
| CONTROL |


### Table 6

| Source A |  | N7:43 |
| --- | --- | --- |
|  | -3 |  |
| Source B |  | 0 |
|  | 0 |  |


### Table 7

| Source |  |  | N7:3 |
| --- | --- | --- | --- |
|  | 10 |  |  |
| Dest |  | N7:1 |  |
|  |  |  |  |


### Table 8

| REFERANCE |
| --- |
| CONTROL |


### Table 9

| Source A |  | N7:10 |
| --- | --- | --- |
|  | 0 |  |
| Source B |  | N7:32 |
|  | 32000 |  |


### Table 10

| Source |
| --- |
|  |
| Dest |
|  |


### Table 11

| O:1 U |  |
| --- | --- |
|  | 96 |
| 1747-DCM-FULL |  |


### Table 12

| Source A |  | N7:33 |
| --- | --- | --- |
|  | 0 |  |
| Source B |  | 0 |
|  | 0 |  |


### Table 13

| Source A |  | N7:10 |
| --- | --- | --- |
|  | 0 |  |
| Source B |  | N7:33 |
|  | 0 |  |


### Table 14

|  |  |  |  |
| --- | --- | --- | --- |


### Table 15

| REFERANCE |
| --- |
| CONTROL |


### Table 16

| Source |
| --- |
|  |
| Dest |
|  |


### Table 17

| Page 36 |  |
| --- | --- |


---
## Page 38

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
O:1
U
96
1747-DCM-FULL
Page 37 Wednesday, June 23, 2021 - 14:35:08


### Table 1

| LAD 2 - --- Total Rungs in Fi | le = 120 |
| --- | --- |


### Table 2

|  |  |  |  |
| --- | --- | --- | --- |
|  | O:1 U 96 1747-DCM-FULL | O:1 U |  |


### Table 3

| O:1 U |  |
| --- | --- |
|  | 96 |
| 1747-DCM-FULL |  |


---
## Page 39

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
MAX
Time Base VOLTAGE
S:4 B3:5 MMOOVV
0105 OSR Move
5 9 Source N7:71
32000<
Dest N7:32
32000<
MMOOVV
Move
Source N7:72
18000<
Dest N7:42
18000<
MMOOVV
Move
Source N7:73
100<
Dest N7:31
100<
DDIIVV
Divide
Source A N7:71
32000<
Source B N7:10
0<
Dest N7:74
32767<
MMUULL
Multiply
Source A N7:74
32767<
Source B 32767
32767<
Dest N7:74
32767<
DDIIVV
Divide
Source A N7:73
100<
Source B N7:10
0<
Dest N7:75
32767<
Page 38 Wednesday, June 23, 2021 - 14:35:09


### Table 1

| 0105 | MAX Time Base VOLTAGE S:4 B3:5 MMOOVV OSR Move 5 9 Source N7:71 32000< Dest N7:32 32000< MMOOVV Move Source N7:72 18000< Dest N7:42 18000< MMOOVV Move Source N7:73 100< Dest N7:31 100< DDIIVV Divide Source A N7:71 32000< Source B N7:10 0< Dest N7:74 32767< MMUULL Multiply Source A N7:74 32767< Source B 32767 32767< Dest N7:74 32767< DDIIVV Divide Source A N7:73 100< Source B N7:10 0< Dest N7:75 32767< |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
|  | OSR 5 9 |  |  |  |  |
|  |  |  |  |  |  |
|  |  | Wed | nesday, June 23, 2021 - 14: | 35: | 09 |


### Table 2

| MAX |
| --- |
| VOLTAGE |


### Table 3

| Time Base |
| --- |
| S:4 |
| 5 |


### Table 4

| B3:5 |
| --- |
| OSR 9 |


### Table 5

|  | 32000 |  |
| --- | --- | --- |
| Dest |  | N7:32 |
|  | 32000 |  |


### Table 6

| Source |  |  | N7:72 |
| --- | --- | --- | --- |
|  | 18000 |  |  |
| Dest |  | N7:42 |  |
|  | 18000 |  |  |


### Table 7

| Source |  |  | N7:73 |
| --- | --- | --- | --- |
|  | 100 |  |  |
| Dest |  | N7:31 |  |
|  | 100 |  |  |


### Table 8

| Source A |  |  | N7:71 |
| --- | --- | --- | --- |
|  | 32000 |  |  |
| Source B |  |  | N7:10 |
|  | 0 |  |  |
| Dest |  | N7:74 |  |
|  | 32767 |  |  |


### Table 9

| Source A |  |  | N7:74 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Source B |  |  | 32767 |
|  | 32767 |  |  |
| Dest |  | N7:74 |  |
|  | 32767 |  |  |


### Table 10

| Source A |  |  | N7:73 |
| --- | --- | --- | --- |
|  | 100 |  |  |
| Source B |  |  | N7:10 |
|  | 0 |  |  |
| Dest |  | N7:75 |  |
|  | 32767 |  |  |


### Table 11

| Page 38 |  |
| --- | --- |


---
## Page 40

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
MMUULL
Multiply
Source A N7:75
32767<
Source B 32767
32767<
Dest N7:75
32767<
VOLTAGE REFERANCE
VOLTAGE
REFERANCE
MMUULL
0106 Multiply
Source A N7:10
0<
Source B N7:20
10000<
Dest N7:0
0<
OVERFLOW
BIT
S:5
U
0
DDDDVV
Double Divide
Source 32767
32767<
Dest N7:0
0<
NEG DETECT
N7:0 MMOOVV
0107 Move
15 Source 0
0<
Dest N7:0
0<
Page 39 Wednesday, June 23, 2021 - 14:35:09


### Table 1

| LAD 2 - --- Total Rungs in File = | 120 |
| --- | --- |


### Table 2

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
|  | MMUULL Multiply Source A N7:75 32767< Source B 32767 32767< Dest N7:75 32767< |  |  |  |
| 0106 | VOLTAGE REFERANCE VOLTAGE REFERANCE MMUULL Multiply Source A N7:10 0< Source B N7:20 10000< Dest N7:0 0< OVERFLOW BIT S:5 U 0 DDDDVV Double Divide Source 32767 32767< Dest N7:0 0< |  |  |  |
| 0107 |  | NEG DETECT |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  | N7:0 |  |  |
|  |  | 15 |  |  |


### Table 3

| Source A |  |  | N7:75 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Source B |  |  | 32767 |
|  | 32767 |  |  |
| Dest |  | N7:75 |  |
|  | 32767 |  |  |


### Table 4

| VOLTAGE |
| --- |
| REFERANCE |


### Table 5

| Source A |  |  | N7:10 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Source B |  |  | N7:20 |
|  | 10000 |  |  |
| Dest |  | N7:0 |  |
|  | 0 |  |  |


### Table 6

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 7

| Source |  |  | 32767 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Dest |  | N7:0 |  |
|  | 0 |  |  |


### Table 8

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:0 |
|  | 0 |  |


---
## Page 41

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
PHASE ANGLE CONTROL LIMIT
PHASE
ANGLE
SAMPLING CONTROL
B3:5 MMOOVV
0108 Move
0 Source N7:10
0<
Dest N7:11
0<
PHASE
ANGLE
MULTIPLIER
MMUULL
Multiply
Source A N7:11
0<
Source B N7:40
12000<
Dest N7:11
0<
OVERFLOW
BIT
S:5
U
0
DDDDVV
Double Divide
Source N7:11
0<
Dest N7:11
0<
ADD OFFSET
AADDDD
Add
Source A N7:11
0<
Source B N7:41
6000<
Dest N7:11
0<
OVERFLOW
BIT
S:5
U
0
Page 40 Wednesday, June 23, 2021 - 14:35:09


### Table 1

| 0108 | PHASE ANGLE CONTROL LIMIT PHASE ANGLE SAMPLING CONTROL B3:5 MMOOVV Move 0 Source N7:10 0< Dest N7:11 0< PHASE ANGLE MULTIPLIER MMUULL Multiply Source A N7:11 0< Source B N7:40 12000< Dest N7:11 0< OVERFLOW BIT S:5 U 0 DDDDVV Double Divide Source N7:11 0< Dest N7:11 0< ADD OFFSET AADDDD Add Source A N7:11 0< Source B N7:41 6000< Dest N7:11 0< OVERFLOW BIT S:5 U 0 |
| --- | --- |


### Table 2

| PHASE |
| --- |
| ANGLE |
| CONTROL |


### Table 3

| SAMPLING |
| --- |
| B3:5 |
| 0 |


### Table 4

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:11 |
|  | 0 |  |


### Table 5

| PHASE |
| --- |
| ANGLE |
| MULTIPLIER |


### Table 6

| Source A |  |  | N7:11 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Source B |  |  | N7:40 |
|  | 12000 |  |  |
| Dest |  | N7:11 |  |
|  | 0 |  |  |


### Table 7

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 8

| Source |  |  | N7:11 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Dest |  | N7:11 |  |
|  | 0 |  |  |


### Table 9

| Source A |  |  | N7:11 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Source B |  |  | N7:41 |
|  | 6000 |  |  |
| Dest |  | N7:11 |  |
|  | 0 |  |  |


### Table 10

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


---
## Page 42

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
PHASE ANGLE INPUT
PHASE
ANGLE
CONTROL
GGRRTT MMOOVV
0109 Greater Than (A>B) Move
Source A N7:11 Source N7:42
0< 18000<
Source B N7:42 Dest N7:11
18000< 0<
PHASE ANGLE DISPLAY
PHASE
ANGLE
MMUULL
0110 Multiply
Source A N7:11
0<
Source B N7:21
1000<
Dest N7:1
0<
OVERFLOW
BIT
S:5
U
0
DDDDVV
Double Divide
Source 32767
32767<
Dest N7:1
0<
NEG DETECT
N7:1 MMOOVV
0111 Move
15 Source 0
0<
Dest N7:1
0<
MMOOVV
0112 Move
Source N7:10
0<
Dest O:8.0
0<
MMOOVV
0113 Move
Source N7:11
0<
Dest O:8.1
15425<
Page 41 Wednesday, June 23, 2021 - 14:35:09


### Table 1

| 0109 | PHASE ANGLE INPUT PHASE ANGLE CONTROL GGRRTT MMOOVV Greater Than (A>B) Move Source A N7:11 Source N7:42 0< 18000< Source B N7:42 Dest N7:11 18000< 0< |  |
| --- | --- | --- |
| 0110 | PHASE ANGLE DISPLAY PHASE ANGLE MMUULL Multiply Source A N7:11 0< Source B N7:21 1000< Dest N7:1 0< OVERFLOW BIT S:5 U 0 DDDDVV Double Divide Source 32767 32767< Dest N7:1 0< |  |
| 0111 |  | NEG DETECT |
|  |  |  |
|  |  | N7:1 |
|  |  | 15 |
| 0112 | MMOOVV Move Source N7:10 0< Dest O:8.0 0< |  |
| 0113 | MMOOVV Move Source N7:11 0< Dest O:8.1 15425< |  |


### Table 2

| PHASE |
| --- |
| ANGLE |
| CONTROL |


### Table 3

| Source A |  | N7:11 |
| --- | --- | --- |
|  | 0 |  |
| Source B |  | N7:42 |
|  | 18000 |  |


### Table 4

| Source |  |  | N7:42 |
| --- | --- | --- | --- |
|  | 18000 |  |  |
| Dest |  | N7:11 |  |
|  | 0 |  |  |


### Table 5

| PHASE |
| --- |
| ANGLE |


### Table 6

| Source A |  |  | N7:11 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Source B |  |  | N7:21 |
|  | 1000 |  |  |
| Dest |  | N7:1 |  |
|  | 0 |  |  |


### Table 7

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 8

| Source |  |  | 32767 |
| --- | --- | --- | --- |
|  | 32767 |  |  |
| Dest |  | N7:1 |  |
|  | 0 |  |  |


### Table 9

|  | 0 |  |
| --- | --- | --- |
| Dest |  | N7:1 |
|  | 0 |  |


### Table 10

| Source |  |  | N7:10 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Dest |  | O:8.0 |  |
|  | 0 |  |  |


### Table 11

| Source |  |  | N7:11 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Dest |  | O:8.1 |  |
|  | 15425 |  |  |


---
## Page 43

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
DISPLAY POWER
DISPLAY
POWER
DDIIVV
0114 Divide
Source A N7:18
0<
Source B N7:29
6<
Dest N7:8
0<
OVERFLOW
BIT
S:5
U
0
RESET CONTROLS ON POWER UP AND RESET BIT RESETS. TEMPERATURE MONITORS RESET
MOMENTARY
RESET
RESET BIT DELAY
B3:0 TTOONN
0115 Timer On Delay EN
11 Timer T4:0
Time Base 0.01 DN
CONTROL Preset 100<
RESET Accum 0<
I:1
80 B3:12 CCOOPP
1747-DCM-FULL OSR Copy File
8 Source #N7:90
POWER UP CONTACTS Dest #O:3.0
T4:7 Length 4
TT
First Pass
S:1
15
ENERPRO PHASE LOSS - CONTACTOR CLOSED
CONTACTOR
CLOSED PHASE LOSS _ENERPRO_PHASE_LOSS
B3:1 I:7 B3:5
0116 L
11 11 3
1746-IV16
1280 mS Time Base COPY I/0 TO B3 SBR
S:4 B3:17 JJSSRR
0117 OSR Jump To Subroutine
6 0 SBR File Number U:3
2560 mS Time Base SCALE VALUES SBR
S:4 B3:17 JJSSRR
0118 OSR Jump To Subroutine
7 1 SBR File Number U:4
Page 42 Wednesday, June 23, 2021 - 14:35:10


### Table 1

| 0114 | DISPLAY POWER DISPLAY POWER DDIIVV Divide Source A N7:18 0< Source B N7:29 6< Dest N7:8 0< OVERFLOW BIT S:5 U 0 |  |
| --- | --- | --- |
| 0115 | RESET CONTROLS ON POWER UP AND RESET BIT RESETS. TEMPERATURE MONITORS RESET MOMENTARY RESET RESET BIT DELAY B3:0 TTOONN Timer On Delay EN 11 Timer T4:0 Time Base 0.01 DN CONTROL Preset 100< RESET Accum 0< I:1 80 B3:12 CCOOPP 1747-DCM-FULL OSR Copy File 8 Source #N7:90 POWER UP CONTACTS Dest #O:3.0 T4:7 Length 4 TT First Pass S:1 15 |  |
| 0116 | ENERPRO PHASE LOSS - CONTACTOR CLOSED CONTACTOR CLOSED PHASE LOSS _ENERPRO_PHASE_LOSS B3:1 I:7 B3:5 |  |
|  | L 11 11 3 1746-IV16 |  |
| 0117 |  | 1280 mS Time Base |
|  |  | S:4 |
|  |  | 6 |
| 0118 |  | 2560 mS Time Base |
|  |  | S:4 |
|  |  | 7 |


### Table 2

| DISPLAY |
| --- |
| POWER |


### Table 3

| Source A |  |  | N7:18 |
| --- | --- | --- | --- |
|  | 0 |  |  |
| Source B |  |  | N7:29 |
|  | 6 |  |  |
| Dest |  | N7:8 |  |
|  | 0 |  |  |


### Table 4

| OVERFLOW |
| --- |
| BIT |
| S:5 |
| U 0 |


### Table 5

| MOMENTARY |
| --- |
| RESET |
| DELAY |


### Table 6

| RESET BIT |
| --- |
| B3:0 |


### Table 7

| 11 CONTROL RESET I:1 |
| --- |
| 80 1747-DCM-FULL POWER UP CONTACTS T4:7 |
| TT First Pass S:1 |


### Table 8

| Time Base 0.01 Preset 100 |  |
| --- | --- |
| Accum | 0 |


### Table 9

| RESET |
| --- |
| I:1 |
| 80 |


### Table 10

| POWER UP CONTACTS |
| --- |
| T4:7 |
| TT |


### Table 11

| Dest | #O:3.0 |
| --- | --- |


### Table 12

| First Pass |
| --- |
| S:1 |
| 15 |


### Table 13

| CONTACTOR |
| --- |
| CLOSED |
| B3:1 |
| 11 |


### Table 14

| PHASE LOSS |
| --- |
| I:7 |
| 11 |
| 1746-IV16 |


### Table 15

| _ENERPRO_PHASE_LOSS |
| --- |
| B3:5 |
| L 3 |


### Table 16

| B3:17 |
| --- |
| OSR 0 |


### Table 17

| B3:17 |
| --- |
| OSR 1 |


---
## Page 44

SSRLV6-4-05-10
LAD 2 - --- Total Rungs in File = 120
0119 END
Page 43 Wednesday, June 23, 2021 - 14:35:10


### Table 1

| 0119 |  |  |  |
| --- | --- | --- | --- |
|  | END |  |  |


---
## Page 45

SSRLV6-4-05-10
LAD 3 - COPY - COPY O0 AND I1 WORDS TO B3 FOR QUICKPANEL DISPLAY --- Total Rungs in File = 6
COPY I/O DATA FILE WORDS TO B3
INPUT MODULE SLOT 2
CCOOPP
0000 Copy File
Source #I:2.0
Dest #B3:12
Length 1
INPUT MODULE SLOT 6
CCOOPP
0001 Copy File
Source #I:6.0
Dest #B3:13
Length 1
INPUT MODULE SLOT 7
CCOOPP
0002 Copy File
Source #I:7.0
Dest #B3:14
Length 1
OUTPUT MODULE SLOT 2
CCOOPP
0003 Copy File
Source #O:2.0
Dest #B3:15
Length 1
OUTPUT MODULE SLOT 5
CCOOPP
0004 Copy File
Source #O:5.0
Dest #B3:16
Length 1
0005 END
Page 1 Wednesday, June 23, 2021 - 14:35:10


### Table 1

| 0000 | COPY I/O DATA FILE WORDS TO B3 INPUT MODULE SLOT 2 CCOOPP Copy File Source #I:2.0 Dest #B3:12 Length 1 |  |  |
| --- | --- | --- | --- |
| 0001 | INPUT MODULE SLOT 6 CCOOPP Copy File Source #I:6.0 Dest #B3:13 Length 1 |  |  |
| 0002 | INPUT MODULE SLOT 7 CCOOPP Copy File Source #I:7.0 Dest #B3:14 Length 1 |  |  |
| 0003 | OUTPUT MODULE SLOT 2 CCOOPP Copy File Source #O:2.0 Dest #B3:15 Length 1 |  |  |
| 0004 | OUTPUT MODULE SLOT 5 CCOOPP Copy File Source #O:5.0 Dest #B3:16 Length 1 |  |  |
| 0005 |  |  |  |
|  | END |  |  |


### Table 2

| Source |  | #I:2.0 |
| --- | --- | --- |
| Dest | #B3:12 |  |
| Length |  | 1 |


### Table 3

| Source |  | #I:6.0 |
| --- | --- | --- |
| Dest | #B3:13 |  |
| Length |  | 1 |


### Table 4

| Source |  | #I:7.0 |
| --- | --- | --- |
| Dest | #B3:14 |  |
| Length |  | 1 |


### Table 5

| Source |  | #O:2.0 |
| --- | --- | --- |
| Dest | #B3:15 |  |
| Length |  | 1 |


### Table 6

| Source |  | #O:5.0 |
| --- | --- | --- |
| Dest | #B3:16 |  |
| Length |  | 1 |


---
## Page 46

SSRLV6-4-05-10
LAD 4 - SCALE - SCALE THERMOCOUPLE VALUES FOR QUICKPANEL DISPLAY --- Total Rungs in File = 5
SCALE THERMOCOUPLE VALUES FOR QUICKPANEL DISPLAY
TC1 - SCR TOP OIL
SSCCPP
0000 Scale w/Parameters
Input N7:100
0<
Input Min. 0
0<
Input Max. 999
999<
Scaled Min. 0
0<
Scaled Max. 9999
9999<
Output N7:110
0<
TC2 - SCR BOTTOM OIL
SSCCPP
0001 Scale w/Parameters
Input N7:101
0<
Input Min. 0
0<
Input Max. 999
999<
Scaled Min. 0
0<
Scaled Max. 9999
9999<
Output N7:111
0<
TC3 - CROWBAR OIL
SSCCPP
0002 Scale w/Parameters
Input N7:102
192<
Input Min. 0
0<
Input Max. 999
999<
Scaled Min. 0
0<
Scaled Max. 9999
9999<
Output N7:112
0<
Page 1 Wednesday, June 23, 2021 - 14:35:11


### Table 1

| 0000 | SCALE THERMOCOUPLE VALUES FOR QUICKPANEL DISPLAY TC1 - SCR TOP OIL SSCCPP Scale w/Parameters Input N7:100 0< Input Min. 0 0< Input Max. 999 999< Scaled Min. 0 0< Scaled Max. 9999 9999< Output N7:110 0< |
| --- | --- |
| 0001 | TC2 - SCR BOTTOM OIL SSCCPP Scale w/Parameters Input N7:101 0< Input Min. 0 0< Input Max. 999 999< Scaled Min. 0 0< Scaled Max. 9999 9999< Output N7:111 0< |
| 0002 | TC3 - CROWBAR OIL SSCCPP Scale w/Parameters Input N7:102 192< Input Min. 0 0< Input Max. 999 999< Scaled Min. 0 0< Scaled Max. 9999 9999< Output N7:112 0< |


### Table 2

| Input |  | N7:100 |  |  |  |
| --- | --- | --- | --- | --- | --- |
|  | 0 |  |  |  |  |
| Input Min. |  |  |  | 0 |  |
|  | 0 |  |  |  |  |
| Input Max. |  |  |  | 999 |  |
|  | 999 |  |  |  |  |
| Scaled Min. |  |  |  |  | 0 |
|  | 0 |  |  |  |  |
| Scaled Max. |  |  |  |  | 9999 |
|  | 9999 |  |  |  |  |
| Output |  |  | N7:110 |  |  |
|  | 0 |  |  |  |  |


### Table 3

| Input |  | N7:101 |  |  |  |
| --- | --- | --- | --- | --- | --- |
|  | 0 |  |  |  |  |
| Input Min. |  |  |  | 0 |  |
|  | 0 |  |  |  |  |
| Input Max. |  |  |  | 999 |  |
|  | 999 |  |  |  |  |
| Scaled Min. |  |  |  |  | 0 |
|  | 0 |  |  |  |  |
| Scaled Max. |  |  |  |  | 9999 |
|  | 9999 |  |  |  |  |
| Output |  |  | N7:111 |  |  |
|  | 0 |  |  |  |  |


### Table 4

| Input |  | N7:102 |  |  |  |
| --- | --- | --- | --- | --- | --- |
|  | 192 |  |  |  |  |
| Input Min. |  |  |  | 0 |  |
|  | 0 |  |  |  |  |
| Input Max. |  |  |  | 999 |  |
|  | 999 |  |  |  |  |
| Scaled Min. |  |  |  |  | 0 |
|  | 0 |  |  |  |  |
| Scaled Max. |  |  |  |  | 9999 |
|  | 9999 |  |  |  |  |
| Output |  |  | N7:112 |  |  |
|  | 0 |  |  |  |  |


---
## Page 47

SSRLV6-4-05-10
LAD 4 - SCALE - SCALE THERMOCOUPLE VALUES FOR QUICKPANEL DISPLAY --- Total Rungs in File = 5
TC4 - CONTROL CABINET AIR TEMPERATURE
SSCCPP
0003 Scale w/Parameters
Input N7:103
287<
Input Min. 0
0<
Input Max. 999
999<
Scaled Min. 0
0<
Scaled Max. 9999
9999<
Output N7:113
0<
0004 END
Page 2 Wednesday, June 23, 2021 - 14:35:11


### Table 1

| 0003 | TC4 - CONTROL CABINET AIR TEMPERATURE SSCCPP Scale w/Parameters Input N7:103 287< Input Min. 0 0< Input Max. 999 999< Scaled Min. 0 0< Scaled Max. 9999 9999< Output N7:113 0< |  |  |
| --- | --- | --- | --- |
| 0004 |  |  |  |
|  | END |  |  |


### Table 2

| Input |  | N7:103 |  |  |  |
| --- | --- | --- | --- | --- | --- |
|  | 287 |  |  |  |  |
| Input Min. |  |  |  | 0 |  |
|  | 0 |  |  |  |  |
| Input Max. |  |  |  | 999 |  |
|  | 999 |  |  |  |  |
| Scaled Min. |  |  |  |  | 0 |
|  | 0 |  |  |  |  |
| Scaled Max. |  |  |  |  | 9999 |
|  | 9999 |  |  |  |  |
| Output |  |  | N7:113 |  |  |
|  | 0 |  |  |  |  |
