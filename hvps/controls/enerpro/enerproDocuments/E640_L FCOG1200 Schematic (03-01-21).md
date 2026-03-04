# E640_L FCOG1200 Schematic (03-01-21)

> **Source:** `hvps/controls/enerpro/enerproDocuments/E640_L FCOG1200 Schematic (03-01-21).pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 2


---
## Page 1

5 4 3 2 1
PHASE LOSS DETECTION PHASE SEQUENCE SWITCHING
& REFERENCE COMPARATORS
D D
C C
B B
A A
5 4 3 2 1
SEDOHTAC
/ SETAG
ROTSIRYHT
OT
BUFFER AMPLIFIER
+5 REFERENCE
AUTO BALANCE
<- 10mA Max MANUAL BALANCE <- 2mA Max
10mA Max ->
SLANGIS
LORTNOC
REMOTSUC
+12 +5 RRREEEVVVIIISSSIIIOOONNNSSS
+12
+12 RRREEEVVV... DDDEEESSSCCCRRRIIIPPPTTTIIIOOONNN DDDAAATTTEEE AAAPPPPPPDDD U EP 5 1016 L R E e C p O l a # c 2 e 1 - U 1 7 1 C 3 0 w 4 ith U12D, Add JU6. 07-09-19
9 N
RN2C
1 5 6 47K
4 8 RN2D 7 15 Ax 2 2 PM1 47K C34 220pF 4 EP1024-1 J1 1 4 3 14 Bx 3 3 2 3 P P 1 2 G 5 +AX 4 C18 R K 0.033uF 1
+5 13 Cx 4 4 5
+BX 6
12 5 Ay 5 KEY PIN 2 7
11 6
+12 By 6 2 +CX 8
+12 10 Cy 7 7 1 J2 -AX L1 J6.9 +12 U7A 1 8 GND 2 2 - MC34074 CTRL KEY PIN 3
+12/PL# 1 3 4 + +30 -BX 5
CR3 +12
3 6 1N914 7
I1# 3 +30 -CX 8 +5 +12 PM7
EP1024-1 CR4 1 4 1N914 2 3 P P 1 2 G 5 +AY I2# J6.9 R K
KEY PIN 7 CR6
SOFT-START 1N914 7 TP7 +BY R8 2
RN3C +30 10
5 6
100K +12 5
+CY
4 C15 0.33uF O R M 52 IT +12 PM10
R24 60Hz 1 EP1024-1 4
13 - 100K +12 50Hz C16 0.33uF 2 3 P P R 1 2 G K 5 -AY SIGHI 14 +12 TP14 +5 12 + U7D R40 8 MC34074 +30 10.0K R46 -BY +12 OMIT
9 R45 2 R .6 2 7 3 K P E M P1 1 0 2 24-1 KEY PIN 6
475K 1 4
Iy/B 2 3 P P 1 2 G 5 -CY R K +12 +5
6 PLL SUMMING AMP +12 Ix/CK2 J7
R51 +12 1 100K 2
CK2# U12B +5 3
I14070B +12 +12 5 +5 4 TEST PHASE 4 REFERENCES +5 +5 +30 6 5
+12 6
+12 5 RN6C 6 7
+15 15K
+30 R10 +15 8
200 COM1 24VAC
+ C1 + C6
1000uF 470uF
GGGOOOLLLEEETTTAAA,,, CCCAAA
24VAC AAApppppprrrooovvvaaalllsss DDDaaattteee TTTiiitttllleee
COM +5 DDDrrraaawwwnnn:::JJJMMM 000777---000999---111999 111222---PPPUUULLLSSSEEE FFFIIIRRRIIINNNGGG BBBOOOAAARRRDDD COM VVVeeerrriiifffiiieeeddd:::<<<vvveeerrr>>> mmmmmm---dddddd---yyyyyy
DDDrrraaawwwiiinnnggg NNNuuummmbbbeeerrr EEE NNNuuummmbbbeeerrr RRReeevvv
FFFCCCOOOGGG111222000000 EEE666444000 LLL
DDDaaattteee::: MMMooonnndddaaayyy,,, MMMaaarrrccchhh 000111,,, 222000222111 SSShhheeeeeettt 111 ooofff 222
61
CCV
RN1A RN5A 2 1 1 2 3.3K 15K
3 RN2B 4 TP5 47K
C17 0.033uF PM2
EP1024-1 1 4
C36 220pF C19 2 P1 G 0.033uF 3 P2 5
R K PM3 C20 EP1024-1 0.033uF 1 4
10 RN4E 5 2 P1 G
120K 3 P2 5 C38 220pF R K
R29 9 RN4F 6 C11 0.33uF 20.0K 120K J6 8 RN4G 7 R2 120K 250 9 C12 0.33uF R43 R3
5 10.0K 250 C13 0.33uF
JU2 1 2 TP9 U3
4 JU1 EP1014 1 2 23 6 R41 17 I +A 7 1.50K 12 A +B 8
R42 CR5 11 9 C B + - C A 1 2 9 0 1 J3 1.50K N -B 18 12 R22 1N914 22 5 CK2 -C 100 2
100K Ad 1 R9 C32 C2
+ C4 3 22uF 220pF C27 680pF 4
15 2 8
R25 3 RN3B 4 1 1 3 4 D D b a C R 1 1 2 6 4 R35 5 249K 100K 3 Dc H 4
21 Vc GND 6
10 CK1 J5 TP12 VCC 1
2
3 10 R26 R20 R31 TP13 U11 47.5K 8.87K 8.87K ULN2004A 9 1 16 2 15 3 14
4 13 5 12
6 11
7 10 14 8 R50 U12A
100K
I14070B 1 JU6 15 3 1 2
2 U8A
3 +
13 1 25K
2 6 JU5 R11 - 1 2 MC34074 RN6A 7 1 2 15K
+ C3 3 RN6B 4
15K 2.2uF
3
U12E COM 1 I14070B
2
8 11 7
VSS
41
RN5C 5 6
15K
RN1D
7 8 3.3K PD3 TP10 PWR ON
R1 C21
250
0.033uF PM4 EP1024-1 1 4 C22 2 P1 G 0.033uF 3 P2 5 TP17 R K
R34
750K PM6 EP1024-1 1 4
2 P1 G 3 P2 5 R K
C39 OMIT R6
J4 TP3 U4 250 1
EP1015 9 - 8 R47 21 1 CK1 I2 1 2 6 4 2 10 47.5K 2 Adx BPo 3 3 + MC34 U 0 8 7 C 4 22 9 A A x dy BPi 4 + C31 15 N 6 22uF 1 1 3 4 D D b a + + A B 7 8 5
17 Dc +C 20 12 A -A 19
11 B -B 18 7
23 C -C 5 R 3 3 .6 2 K 6 - 7 I1 10 8 5 VCC + U8B
MC34074
5 4 CK2GND
U7E MC34074
VDD
+ C2
2.2uF
4
11
+V
-V
U6E I1239N 3
21
+V
-V
TP15
U6B I1239N + 5 RN5B 2 3 4
4 15K 5 RN1C 6 - C33 220pF
3.3K
U6D I1239N + 11 13
10 -
RN9D 8 7 47K
U9B
I14073BCP C26 3 R7 4 6 0.1uF 5 10
R28 TP8 10.0K
R37 TP6
R5
250
PM11 EP1024-1 1 4 C28 0.01uF 2 P1 G 3 P2 5 R K
R33 23.2K
1 JU4 2 U8D
12 + 14 13
- MC34074
R44 2.00K
U9D I14073BCP
CR1
15V
41
VDD
7
U9A I14073BCP
1 2 9 8
U8E MC34074
VSS
4
11
+V
-V
PD2
INHIBIT
R4
250
RN9E 10 9 47K
U2
2
PHASE LOSS 2 RN2A 1 RN1B 47K 3 4 PL# + C5
3.3K PD1 C23 2.2uF 0.27uF
U6A RN4A
I 1 1239N - 6 C25 N 14 120K 1 7 0.15uF + TP16 2 RN9A 1 13 RN4B 2 47K 120K 3 RN9B 4 C35 220pF 47K
RN9C RN4C
5 6 12 3 47K 120K
+7 U6C
I1239N - 8 C24 11 R 12 N 0 4 K D 4 14 C29 + 9 0.1uF 0.27uF C37 220pF
R30 34.0K
R21 CR2 1N914 1.50K JU3 2 1 PM5
EP1024-1 1 4 Ix# 2 P1 G 3 P2 5
R K
4 RN7B 3 CK2 U10 33K ULN2004A
RN7A 2 1 9 33K RN7C 5 6 CK2# 1 16 33K 2 15 3 14
U9C I14073BCP 4 13 11 N 5 12 6 - 12 10 Iy# TP4 6 11 7 13 7 10 J6.9 R39 5 8
10.0K + MC3 U 4 7 0 B 74 PM8 EP1024-1
1 4 2 P1 G 3 P2 5 R K
PM9
C14 0.33uF EP1024-1 R27 1 4 32.4K 2 P1 G
TP1 2 RN3A 1 3 P2 5
100K R K
C30 5 RN8C 6
0.27uF 100K RN8B 3 4 100K 2 RN8A 1 R36 100K 115K TP11
TP18
TP2 R48 10.0K U12D I14070B CK2 12
11 13 R49
10.0K R38 34.0K CK2#
CK2# CK2
U12C I14070B
8
10
U1 3 IN OUT 1 9 4 + 3
GND
9 -
2 1 8
- 10 + U7C MC34074


### Table 1

| 5 4 3 2 1 PHASE LOSS DETECTION PHASE SEQUENCE SWITCHING +12 +5 RRREEEVVVIIISSSIIIOOONNNSSS TP15 & REFERENCE COMPARATORS +12 +12 RRREEEVVV... DDDEEESSSCCCRRRIIIPPPTTTIIIOOONNN DDDAAATTTEEE AAAPPPPPPDDD U EP 5 1016 L R E e C p O l a # c 2 e 1 - U 1 7 1 C 3 0 w 4 ith U12D, Add JU6. 07-09-19 61 RN1A RN5A 2 1 1 2 3.3K 15K U6B I1239N + 5 RN5B 2 3 4 PHASE LOSS 2 RN2A 1 RN1B 47K 3 4 PL# + C5 9 N CCV 3 RN2B 4 TP5 47K RN5C 5 6 4 15K 5 RN1C 6 - C33 220pF 3.3K PD1 C23 2.2uF 0.27uF RN2C 15K 3.3K 1 5 6 47K RN1D PD2 U6A RN4A D 4 8 RN2D 7 15 Ax 2 2 PM1 47K C34 220pF 4 EP1024-1 J1 1 4 3 14 Bx 3 3 2 3 P P 1 2 G 5 +AX 4 C18 R K 0.033uF 1 C17 0.033uF PM2 7 8 3.3K PD3 TP10 PWR ON U6D I1239N + 11 13 INHIBIT I 1 1239N - 6 C25 N 14 120K 1 7 0.15uF + TP16 2 RN9A 1 13 RN4B 2 47K 120K 3 RN9B 4 C35 220pF 47K RN9C RN4C +5 13 Cx 4 4 5 EP1024-1 1 4 10 - 5 6 12 3 47K 120K +BX 6 C36 220pF C19 2 P1 G 0.033uF 3 P2 5 RN9D 8 7 47K +7 U6C 12 5 Ay 5 KEY PIN 2 7 R K PM3 C20 EP1024-1 0.033uF 1 4 I1239N - 8 C24 11 R 12 N 0 4 K D 4 14 C29 + 9 0.1uF 0.27uF C37 220pF 11 6 10 RN4E 5 2 P1 G +12 By 6 2 +CX 8 120K 3 P2 5 C38 220pF R K R1 C21 R30 34.0K 250 +12 10 Cy 7 7 1 J2 -AX L1 J6.9 +12 U7A 1 8 GND 2 2 - MC34074 CTRL KEY PIN 3 R29 9 RN4F 6 C11 0.33uF 20.0K 120K J6 8 RN4G 7 R2 120K 250 9 C12 0.33uF R43 R3 0.033uF PM4 EP1024-1 1 4 C22 2 P1 G 0.033uF 3 P2 5 TP17 R K U9B U9A I14073BCP R21 CR2 1N914 1.50K JU3 2 1 PM5 +12/PL# 1 3 4 + +30 -BX 5 5 10.0K 250 C13 0.33uF I14073BCP C26 3 R7 4 6 0.1uF 5 10 1 2 9 8 EP1024-1 1 4 Ix# 2 P1 G 3 P2 5 CR3 +12 R34 R K SEDOHTAC 3 6 1N914 7 JU2 1 2 TP9 U3 750K PM6 EP1024-1 1 4 R28 TP8 10.0K 4 RN7B 3 CK2 U10 33K ULN2004A C / SETAG I1# 3 +30 -CX 8 +5 +12 PM7 4 JU1 EP1014 1 2 23 6 R41 17 I +A 7 1.50K 12 A +B 8 2 P1 G 3 P2 5 R K RN7A 2 1 9 33K RN7C 5 6 CK2# 1 16 33K 2 15 3 14 ROTSIRYHT EP1024-1 CR4 1 4 1N914 2 3 P P 1 2 G 5 +AY I2# J6.9 R K R42 CR5 11 9 C B + - C A 1 2 9 0 1 J3 1.50K N -B 18 12 R22 1N914 22 5 CK2 -C 100 2 U9C I14073BCP 4 13 11 N 5 12 6 - 12 10 Iy# TP4 6 11 7 13 7 10 J6.9 R39 5 8 KEY PIN 7 CR6 100K Ad 1 R9 C32 C2 R37 TP6 10.0K + MC3 U 4 7 0 B 74 PM8 EP1024-1 OT SLANGIS SOFT-START 1N914 7 TP7 +BY R8 2 + C4 3 22uF 220pF C27 680pF 4 R4 1 4 2 P1 G 3 P2 5 R K RN3C +30 10 250 5 6 15 2 8 PM9 LORTNOC 100K +12 5 R25 3 RN3B 4 1 1 3 4 D D b a C R 1 1 2 6 4 R35 5 249K 100K 3 Dc H 4 R5 C14 0.33uF EP1024-1 R27 1 4 32.4K 2 P1 G +CY 21 Vc GND 6 250 TP1 2 RN3A 1 3 P2 5 REMOTSUC 4 C15 0.33uF O R M 52 IT +12 PM10 10 CK1 J5 TP12 VCC 1 C39 OMIT R6 100K R K R24 60Hz 1 EP1024-1 4 2 J4 TP3 U4 250 1 C30 5 RN8C 6 BUFFER AMPLIFIER 13 - 100K +12 50Hz C16 0.33uF 2 3 P P R 1 2 G K 5 -AY SIGHI 14 +12 TP14 +5 12 + U7D R40 8 MC34074 +30 10.0K R46 -BY +12 OMIT 3 10 R26 R20 R31 TP13 U11 47.5K 8.87K 8.87K ULN2004A 9 1 16 2 15 3 14 EP1015 9 - 8 R47 21 1 CK1 I2 1 2 6 4 2 10 47.5K 2 Adx BPo 3 3 + MC34 U 0 8 7 C 4 22 9 A A x dy BPi 4 + C31 15 N 6 22uF 1 1 3 4 D D b a + + A B 7 8 5 PM11 EP1024-1 1 4 C28 0.01uF 2 P1 G 3 P2 5 R K 0.27uF 100K RN8B 3 4 100K 2 RN8A 1 R36 100K 115K TP11 9 R45 2 R .6 2 7 3 K P E M P1 1 0 2 24-1 KEY PIN 6 4 13 5 12 17 Dc +C 20 12 A -A 19 R33 23.2K TP18 475K 1 4 6 11 11 B -B 18 7 Iy/B 2 3 P P 1 2 G 5 -CY R K +12 +5 7 10 14 8 R50 U12A 23 C -C 5 R 3 3 .6 2 K 6 - 7 I1 10 8 5 VCC + U8B 1 JU4 2 U8D TP2 R48 10.0K U12D I14070B CK2 12 100K MC34074 +5 REFERENCE 6 PLL SUMMING AMP +12 Ix/CK2 J7 I14070B 1 JU6 15 3 1 2 5 4 CK2GND 12 + 14 13 11 13 R49 R51 +12 1 100K 2 2 U8A - MC34074 RN9E 10 9 47K 10.0K R38 34.0K CK2# AUTO BALANCE 3 + CK2# U12B +5 3 13 1 25K CK2# CK2 <- 10mA Max MANUAL BALANCE <- 2mA Max I14070B +12 +12 5 +5 4 TEST PHASE 4 REFERENCES +5 +5 +30 6 5 2 6 JU5 R11 - 1 2 MC34074 RN6A 7 1 2 15K +12 6 + C3 3 RN6B 4 +12 5 RN6C 6 7 15K 2.2uF R44 2.00K U12C I14070B +15 15K 8 +30 R10 +15 8 3 U2 10 10mA Max -> 200 COM1 24VAC U12E COM 1 I14070B 41 U7E MC34074 4 U6E I1239N 3 U9D I14073BCP 41 U8E MC34074 4 U1 3 IN OUT 1 9 4 + 3 VDD +V +V VDD +V GND + C1 + C6 + C2 CR1 2 1000uF 470uF 2.2uF -V -V 15V -V GGGOOOLLLEEETTTAAA,,, CCCAAA VSS VSS 9 - 24VAC AAApppppprrrooovvvaaalllsss DDDaaattteee TTTiiitttllleee 2 2 1 8 COM +5 DDDrrraaawwwnnn:::JJJMMM 000777---000999---111999 111222---PPPUUULLLSSSEEE FFFIIIRRRIIINNNGGG BBBOOOAAARRRDDD COM VVVeeerrriiifffiiieeeddd:::<<<vvveeerrr>>> mmmmmm---dddddd---yyyyyy 8 11 7 11 21 7 11 - 10 + U7C MC34074 DDDrrraaawwwiiinnnggg NNNuuummmbbbeeerrr EEE NNNuuummmbbbeeerrr RRReeevvv FFFCCCOOOGGG111222000000 EEE666444000 LLL DDDaaattteee::: MMMooonnndddaaayyy,,, MMMaaarrrccchhh 000111,,, 222000222111 SSShhheeeeeettt 111 ooofff 222 5 4 3 2 1 | 5 |  | 4 | 3 |  |  | 2 | 1 |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  | RRREEEVVVIIISSSIIIOOONNNSSS |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  | RRREEEVVV... | DDDEEESSSCCCRRRIIIPPPTTTIIIOOONNN |  |  |  |  | DDDAAATTTEEE | AAAPPPPPPDDD |
|  |  |  |  |  |  |  |  |  |  | L | Replace U7C with U12D, Add JU6. ECO #21-11304 |  |  |  |  | 07-09-19 |  |
|  |  |  |  |  |  |  |  |  | GGGOOOLLLEEETTTAAA,,, CCCAAA |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  | AAApppppprrrooovvvaaalllsss | DDDaaattteee |  | TTTiiitttllleee 111222---PPPUUULLLSSSEEE FFFIIIRRRIIINNNGGG BBBOOOAAARRRDDD |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  | DDDrrraaawwwnnn:::JJJMMM | 000777---000999---111999 |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  | VVVeeerrriiifffiiieeeddd:::<<<vvveeerrr>>> | mmmmmm---dddddd---yyyyyy |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  | DDDrrraaawwwiiinnnggg NNNuuummmbbbeeerrr FFFCCCOOOGGG111222000000 |  | EEE NNNuuummmbbbeeerrr EEE666444000 |  |  | RRReeevvv LLL |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  | DDDaaattteee::: MMMooonnndddaaayyy,,, MMMaaarrrccchhh 000111,,, 222000222111 |  |  | SSShhheeeeeettt 111 ooofff 222 |  |  |
|  | 5 |  | 4 | 3 |  |  | 2 | 1 |  |  |  |  |  |  |  |  |  |


### Table 2

|  |
| --- |
|  |


### Table 3

|  |  |  |  |  |  |  |  |  |  |  |  |  | N CC |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  | 15 | V Ax 2 |  |  |
|  |  |  |  |  |  |  |  |  |  |  | 14 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  | 14 | Bx 3 |  |  |
|  |  |  |  |  |  |  |  |  |  |  | 13 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  | 13 | Cx 4 |  |  |
|  |  |  |  |  |  |  |  |  |  |  | 12 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  | 12 | Ay 5 |  |  |
|  |  |  |  |  |  |  |  |  |  |  | 11 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  | 11 | By 6 |  |  |
|  |  |  |  |  |  |  |  |  |  |  | 10 |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  | 10 | Cy 7 GND CTRL |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  | TP4 |  |  |  |  | 17 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  | 12 |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  | 11 |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  | N 9 |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  | 5 |  |
|  |  |  |  |  |  |  |  | TP6 |  |  |  |  |  | 22 |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | C32 220pF 15 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 14 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 13 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |


### Table 4

| 7 |  |  |  |
| --- | --- | --- | --- |
|  |  |  |  |
| 10 |  |  | +5 +7 |


### Table 5

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 | P1 G P2 R K | +BY 5 4 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |  |
| 14 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| 13 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| 12 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 2 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 3 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  | 5 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  | 6 |  |  |  |  |  |  |


### Table 6

| C35 220pF C18 0.033uF 4 |
| --- |
| C36 220pF C19 0.033uF 5 |
| C37 220pF C20 0.033uF 6 |
| C38 220pF C21 0.033uF 7 |


### Table 7

|  | 5 |
| --- | --- |


### Table 8

| 7 | 2 |
| --- | --- |
| 8 | 3 |
| 20 | 4 |
| 19 | 5 |
| 18 | 6 |
|  | 7 |


### Table 9

| 7 2 |
| --- |
| 8 3 |
| 20 4 |
| 19 5 |
| 18 6 |


### Table 10

| 6 |  |
| --- | --- |


### Table 11

| 9 |  |
| --- | --- |


---
## Page 2

5 4 3 2 1
PART PART NUMBER STOCK NUMBER
U1 W02M D1BRW02M
U2 LM78L12CZL T2VLM78L12
U3 EP1014 I11014D
U4 EP1015 I11015
U5 EP1016 I11016
U6 LM239N I1239N
D D
U7 MC34074BC I134074P
U8 MC34074BC I134074P
U9 MC14073BCP I14073BCP
U10-U11 ULN2004A I12004A NOTES:
U12 MC14070BCP I14070B 1- Match C23 & C29 to +/- 1%.
CR1 1N5352B(15V) D1N5352B 2- Mount R1-R6 flush to the board
CR2-CR6 1N914B D1N914B 3- Install JU1 and JU2 for 2-30 gate pulse bursts.
PD1-PD2 LN21RPH (RED) D1LN21RPH Use this pulse profile for rectifiers with normal
PD3 LN31GPH (GRN) D1LN31GPH load inductance; otherwise, gating is 1-120 burst mode.
RN1 750-83-R3.3K R1S08I332 4- For 50 Hz operation:
RN2 750-83-R47K R1S08I473 - move P5 to pins 2 & 3 of J5
RN3 750-63-R100K R1S06I104 - change RN4 to 150kOhm
RN4 760-3-R120K R1D14I124 4 - change C23 & C29 to 0.33ufd (matched 1%)
RN5-RN6 750-63-R15K R1S06I153 5- Factory selected resistance.
RN7 750-63-R33K R1S06I333 6- For manual auto balance:
RN8 750-63-R100K R1S06I104 - Install R11
RN9 750-103-R47K R1S10I473 - Omit JU6, R48, R49, JU4 & JU5
C R1-R6 RS2B-R250 OHM R1W03W250 For off-board auto balance: C
R7-R8 CW2C-R10 OHM R1W03W010 - Install JU4, JU5, & R48
R9 CW2C-R100 OHM R1W03W100 - Omit JU6, R11, & R49
R10 CW5-R200 OHM R1W05W200 - Jumper R49
R11 93PR25K R1P93P253 For on-board auto balance:
R20-R52 RN60 (see table) - Install JU6, R48, & R49
C1 ECEA1JU102 C1EL063102 - Omit R11, JU4, & JU5
C2-C3 ECSF1CE225K C1TN016225 7- Optional 1.5k pull-down resistor R37, connect I2 to +12V
C4 ECSF1CE226K C1TN016226 for soft-start. R42 must be omitted.
C5 ECSF1CE225K C1TN016225 8- For current signal input, select R40 to give SIG HI = +6.0V
C6 ECEA1JU471 C1EL050471 with maximum signal current.
C11-C16 MKC4-0.33uF 10% C1FL063334 9- Select C31 capacitance in conjunction with SIG HI source resistance
C17-C22 MKS3-0.033uF 5% C1FL250333 to reduce the firing circuit bandwidth (optional).
C23 MKS3-0.27uF 10% C1FL063274 4 1
C24 MKS3-0.1uF 10% C1FL100104
C25 MKS3-0.15uF 10% C1FL100154
C26 MKS3-0.1uF 10% C1FL100104
C27 FKC3-0.00068uF 5% C1FL160681 RN60 RESISTORS (KOhms)
B C28 MKS3-0.01uF 10% C1FL100103 R20 8.87 R37 7 B
C29 MKS3-0.27uF 10% C1FL063274 4 1 R21 1.50 R38 34.0
C30 MKS3-0.27uF 10% C1FL063274 R22 100 R39 10.0 8
C31 ECSF1CE226K (optional) C1TN016226 9 R23 2.67 R40 10.0
C32 FKC3-0.00022uF 5% C1FL160221 R24 100 R41 1.50
C33-C38 FKC3-0.00022uF 5% C1FL160221 R25 249 R42 1.50
C39 OMIT OMIT R26 47.5 R43 10.0
PM1-PM12 EP1024-1 (R=2.00M) T1PM10241 R27 32.4 R44 2.00
641828-1 (each keyed R28 10.0 R45 475
J1-J4 C2MNLVPH08
uniquely) R29 20.0 R46 OMIT
P1-P4 640582-1 C2MNLPLG08 R30 34.0 R47 47.5
J5 68024-103 C2MSCH03 R31 8.87 R48 10.0 6
P5 65474-001 C2MSCJ03 R32 53.6 R49 10.0 6
J6 350714-1 C2MNLVPH15 R33 23.2 R50 100
P6 350736-1 C2MNLPLG15 R34 750 R51 100
KEY PLUG 1-640415-0 C2KP94V0 R35 SEL R52 OMIT
J7 640456-8 C2MTAVPH08 R36 115
A JU1-JU6 923345-01-C (optional) W1J01 A
TP1-TP18 TP-104-01-02 T3TP104
COM W1JCOMM (COMMON JUMPER) W1JCOMM
Contacts 350536-1 C2CS3505361
Sockets GGGOOOLLLEEETTTAAA,,, CCCAAA
DDDooocccuuummmeeennnttt NNNuuummmbbbeeerrr RRReeevvv
EEE666444000 --- FFFCCCOOOGGG111222000000 LLL
DDDaaattteee::: WWWeeedddnnneeesssdddaaayyy,,, JJJuuulllyyy 111000,,, 222000111999 SSShhheeeeeettt 222 ooofff 222
5 4 3 2 1


### Table 1

| 5 4 3 2 1 PART PART NUMBER STOCK NUMBER U1 W02M D1BRW02M U2 LM78L12CZL T2VLM78L12 U3 EP1014 I11014D U4 EP1015 I11015 U5 EP1016 I11016 U6 LM239N I1239N D U7 MC34074BC I134074P U8 MC34074BC I134074P U9 MC14073BCP I14073BCP U10-U11 ULN2004A I12004A NOTES: U12 MC14070BCP I14070B 1- Match C23 & C29 to +/- 1%. CR1 1N5352B(15V) D1N5352B 2- Mount R1-R6 flush to the board CR2-CR6 1N914B D1N914B 3- Install JU1 and JU2 for 2-30 gate pulse bursts. PD1-PD2 LN21RPH (RED) D1LN21RPH Use this pulse profile for rectifiers with normal PD3 LN31GPH (GRN) D1LN31GPH load inductance; otherwise, gating is 1-120 burst mode. RN1 750-83-R3.3K R1S08I332 4- For 50 Hz operation: RN2 750-83-R47K R1S08I473 - move P5 to pins 2 & 3 of J5 RN3 750-63-R100K R1S06I104 - change RN4 to 150kOhm RN4 760-3-R120K R1D14I124 4 - change C23 & C29 to 0.33ufd (matched 1%) RN5-RN6 750-63-R15K R1S06I153 5- Factory selected resistance. RN7 750-63-R33K R1S06I333 6- For manual auto balance: RN8 750-63-R100K R1S06I104 - Install R11 RN9 750-103-R47K R1S10I473 - Omit JU6, R48, R49, JU4 & JU5 C R1-R6 RS2B-R250 OHM R1W03W250 For off-board auto balance: R7-R8 CW2C-R10 OHM R1W03W010 - Install JU4, JU5, & R48 R9 CW2C-R100 OHM R1W03W100 - Omit JU6, R11, & R49 R10 CW5-R200 OHM R1W05W200 - Jumper R49 R11 93PR25K R1P93P253 For on-board auto balance: R20-R52 RN60 (see table) - Install JU6, R48, & R49 C1 ECEA1JU102 C1EL063102 - Omit R11, JU4, & JU5 C2-C3 ECSF1CE225K C1TN016225 7- Optional 1.5k pull-down resistor R37, connect I2 to +12V C4 ECSF1CE226K C1TN016226 for soft-start. R42 must be omitted. C5 ECSF1CE225K C1TN016225 8- For current signal input, select R40 to give SIG HI = +6.0V C6 ECEA1JU471 C1EL050471 with maximum signal current. C11-C16 MKC4-0.33uF 10% C1FL063334 9- Select C31 capacitance in conjunction with SIG HI source resistance C17-C22 MKS3-0.033uF 5% C1FL250333 to reduce the firing circuit bandwidth (optional). C23 MKS3-0.27uF 10% C1FL063274 4 1 C24 MKS3-0.1uF 10% C1FL100104 C25 MKS3-0.15uF 10% C1FL100154 C26 MKS3-0.1uF 10% C1FL100104 C27 FKC3-0.00068uF 5% C1FL160681 RN60 RESISTORS (KOhms) C28 MKS3-0.01uF 10% C1FL100103 R20 8.87 R37 7 C29 MKS3-0.27uF 10% C1FL063274 4 1 R21 1.50 R38 34.0 C30 MKS3-0.27uF 10% C1FL063274 R22 100 R39 10.0 8 C31 ECSF1CE226K (optional) C1TN016226 9 R23 2.67 R40 10.0 C32 FKC3-0.00022uF 5% C1FL160221 R24 100 R41 1.50 C33-C38 FKC3-0.00022uF 5% C1FL160221 R25 249 R42 1.50 C39 OMIT OMIT R26 47.5 R43 10.0 PM1-PM12 EP1024-1 (R=2.00M) T1PM10241 R27 32.4 R44 2.00 641828-1 (each keyed R28 10.0 R45 475 J1-J4 C2MNLVPH08 uniquely) R29 20.0 R46 OMIT P1-P4 640582-1 C2MNLPLG08 R30 34.0 R47 47.5 J5 68024-103 C2MSCH03 R31 8.87 R48 10.0 6 P5 65474-001 C2MSCJ03 R32 53.6 R49 10.0 6 J6 350714-1 C2MNLVPH15 R33 23.2 R50 100 P6 350736-1 C2MNLPLG15 R34 750 R51 100 KEY PLUG 1-640415-0 C2KP94V0 R35 SEL R52 OMIT J7 640456-8 C2MTAVPH08 R36 115 JU1-JU6 923345-01-C (optional) W1J01 TP1-TP18 TP-104-01-02 T3TP104 COM W1JCOMM (COMMON JUMPER) W1JCOMM Contacts 350536-1 C2CS3505361 Sockets GGGOOOLLLEEETTTAAA,,, CCCAAA DDDooocccuuummmeeennnttt NNNuuummmbbbeeerrr RRReeevvv EEE666444000 --- FFFCCCOOOGGG111222000000 LLL DDDaaattteee::: WWWeeedddnnneeesssdddaaayyy,,, JJJuuulllyyy 111000,,, 222000111999 SSShhheeeeeettt 222 ooofff 222 5 4 3 2 1 | 5 |  |  | 4 |  |  | 3 |  |  |  | 2 |  |  |  | 1 |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  | GGGOOOLLLEEETTTAAA,,, CCCAAA |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  | DDDooocccuuummmeeennnttt NNNuuummmbbbeeerrr EEE666444000 --- FFFCCCOOOGGG111222000000 |  |  |  |  |  |  | RRReeevvv LLL |
|  |  |  |  |  |  |  |  |  |  | DDDaaattteee::: WWWeeedddnnneeesssdddaaayyy,,, JJJuuulllyyy 111000,,, 222000111999 |  |  |  | SSShhheeeeeettt 222 ooofff 222 |  |  |  |
|  | 5 |  |  | 4 |  |  | 3 |  |  |  | 2 |  |  |  | 1 |  |  |


### Table 2

| PART | PART NUMBER | STOCK NUMBER |
| --- | --- | --- |
| U1 | W02M | D1BRW02M |
| U2 | LM78L12CZL | T2VLM78L12 |
| U3 | EP1014 | I11014D |
| U4 | EP1015 | I11015 |
| U5 | EP1016 | I11016 |
| U6 | LM239N | I1239N |
| U7 | MC34074BC | I134074P |
| U8 | MC34074BC | I134074P |
| U9 | MC14073BCP | I14073BCP |
| U10-U11 | ULN2004A | I12004A |
| U12 | MC14070BCP | I14070B |
| CR1 | 1N5352B(15V) | D1N5352B |
| CR2-CR6 | 1N914B | D1N914B |
| PD1-PD2 | LN21RPH (RED) | D1LN21RPH |
| PD3 | LN31GPH (GRN) | D1LN31GPH |
| RN1 | 750-83-R3.3K | R1S08I332 |
| RN2 | 750-83-R47K | R1S08I473 |
| RN3 | 750-63-R100K | R1S06I104 |
| RN4 | 760-3-R120K | R1D14I124 4 |
| RN5-RN6 | 750-63-R15K | R1S06I153 |
| RN7 | 750-63-R33K | R1S06I333 |
| RN8 | 750-63-R100K | R1S06I104 |
| RN9 | 750-103-R47K | R1S10I473 |
| R1-R6 | RS2B-R250 OHM | R1W03W250 |
| R7-R8 | CW2C-R10 OHM | R1W03W010 |
| R9 | CW2C-R100 OHM | R1W03W100 |
| R10 | CW5-R200 OHM | R1W05W200 |
| R11 | 93PR25K | R1P93P253 |
| R20-R52 | RN60 (see table) |  |
| C1 | ECEA1JU102 | C1EL063102 |
| C2-C3 | ECSF1CE225K | C1TN016225 |
| C4 | ECSF1CE226K | C1TN016226 |
| C5 | ECSF1CE225K | C1TN016225 |
| C6 | ECEA1JU471 | C1EL050471 |
| C11-C16 | MKC4-0.33uF 10% | C1FL063334 |
| C17-C22 | MKS3-0.033uF 5% | C1FL250333 |
| C23 | MKS3-0.27uF 10% | C1FL063274 4 1 |
| C24 | MKS3-0.1uF 10% | C1FL100104 |
| C25 | MKS3-0.15uF 10% | C1FL100154 |
| C26 | MKS3-0.1uF 10% | C1FL100104 |
| C27 | FKC3-0.00068uF 5% | C1FL160681 |
| C28 | MKS3-0.01uF 10% | C1FL100103 |
| C29 | MKS3-0.27uF 10% | C1FL063274 4 1 |
| C30 | MKS3-0.27uF 10% | C1FL063274 |
| C31 | ECSF1CE226K (optional) | C1TN016226 9 |
| C32 | FKC3-0.00022uF 5% | C1FL160221 |
| C33-C38 | FKC3-0.00022uF 5% | C1FL160221 |
| C39 | OMIT | OMIT |
| PM1-PM12 | EP1024-1 (R=2.00M) | T1PM10241 |
| J1-J4 | 641828-1 (each keyed uniquely) | C2MNLVPH08 |
| P1-P4 | 640582-1 | C2MNLPLG08 |
| J5 | 68024-103 | C2MSCH03 |
| P5 | 65474-001 | C2MSCJ03 |
| J6 | 350714-1 | C2MNLVPH15 |
| P6 | 350736-1 | C2MNLPLG15 |
| KEY PLUG | 1-640415-0 | C2KP94V0 |
| J7 | 640456-8 | C2MTAVPH08 |
| JU1-JU6 | 923345-01-C (optional) | W1J01 |
| TP1-TP18 | TP-104-01-02 | T3TP104 |
| COM | W1JCOMM (COMMON JUMPER) | W1JCOMM |
| Contacts Sockets | 350536-1 | C2CS3505361 |


### Table 3

| RN60 RESISTORS (KOhms) |  |  |  |
| --- | --- | --- | --- |
| R20 | 8.87 | R37 | 7 |
| R21 | 1.50 | R38 | 34.0 |
| R22 | 100 | R39 | 10.0 8 |
| R23 | 2.67 | R40 | 10.0 |
| R24 | 100 | R41 | 1.50 |
| R25 | 249 | R42 | 1.50 |
| R26 | 47.5 | R43 | 10.0 |
| R27 | 32.4 | R44 | 2.00 |
| R28 | 10.0 | R45 | 475 |
| R29 | 20.0 | R46 | OMIT |
| R30 | 34.0 | R47 | 47.5 |
| R31 | 8.87 | R48 | 10.0 6 |
| R32 | 53.6 | R49 | 10.0 6 |
| R33 | 23.2 | R50 | 100 |
| R34 | 750 | R51 | 100 |
| R35 | SEL | R52 | OMIT |
| R36 | 115 |  |  |
