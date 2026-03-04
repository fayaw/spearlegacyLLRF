# E640_K FCOG1200 Schematic (09-30-09)

> **Source:** `hvps/controls/enerpro/enerproDocuments/E640_K FCOG1200 Schematic (09-30-09).pdf`
> **Format:** PDF (converted to Markdown for AI readability)
> **Pages:** 2


---
## Page 1

PWBARTWORK REVISIONS RN1
2 1 +12 3.3K LTR DESCRIPTION DATE APPD. PHASE LOSS 3 4 F Add current auto balance circuit 08-13-96 fjb
PD1 INHIBIT G-J Unreleased revisions (Enerpro'sinternal revision changes) 0 0 1 6 - - 2 0 4 4 - - 0 0 5 8 fjb
5 6 PWR ON PD2 e Ax K R hy e s p t l e a r c e e s i 1 s 2 c V a p re a g c u it l o a r t s or C ( 3 n 3 e - w C 3 T 8 O . - A 9 d 2 d P C K 5 G , ) C . 6 A , d a d n p d h C a 3 se 9 . r C ef o e r r r e e n c c t e g r c o o u m nd p a p r l a a t n o e r . 09-30-09 srs
7 8
PD3 e Bx J1 P1 3
+Ax 1
e Cx
e Ay
P6 J6
L1 9 100 10 U10 7 e By
R9 1.50K 20.0K +12
R21 CR2 R29
+12 e JU3 0.10 Cy 2 +12/PL 5 10.0K C26 - U7A 1 SS 1
R43 3 + 2 U9B 9 8 750K
R34
10.0K
R28 I1 4 2 33K 1 1.50K R41 CR3 +5
+12 1.50K 6 - R42 CR4 CR5 U7B 7 I2 12 10.0K 100K 5 +
R39 R22 + C4 CR6
SOFT START 22µ
R37
+12 249K 32.4K
R25 R27
OMIT
R52 100K 9 R24 - TP1 U8C 8 47.5K 13 - SIG HI 10 47.5K 10 + R47 U7D 14 8.87K
R26 +5 12 + BUFFER R31 C31
10.0K 22 AMPLIFIER
R40
Iy/B 14 10.0K
R48 100K 12+ R50 U8D 14
Ix/CK2 15 10.0K 13 - R49 100K R51
13
10mAmax +12 6 +12
2mAmax +5 7 +5 +C3
2.2µ
+30 3
+12 24 Vac +30 1 ac + 200 U2
BUR11 R10 Approvals Date 24 Vac 2 ac - + C1 CR1 COM 12-PULSE FIRING BOARD COM 1000 15V dwn:fjb 06-03-92 8
ver:kca/srs 09-30-09 PWBPNFCOG1200 E640K
COM
11
SIZE: B SHEET 1 OF 2
SLANGIS LORNOC
REMOTSUC
U5 N
TP17
SS I1 3 4 6 Ix U9A 5
U3 I +12 33K A RN7B B C
+12 33K N TP4 RN7C 11 12 10 CK2
U9C TP6 13 Ad
C32 TP7 220p
RN3
5 1 0 0 K 6 DAx 15 DA
3 4 DBx DB
2 1 DCx DC
TP12 RN8 VC 5 6 DAy 100K CK1 3 4 DBy TP3 2 1 DCy 21CK1 U4
1 Adx
+12 OMIT 2 Ax
TP18 R46 TP11 22 Ady
C28 9 CK2 Ixy+CK2 Ixy N 475K
R45 23.2K 15DA 1 R33 14 DB
U12A 3 53.6K 6 - TP2 13 DC 2 R32 U8B 7 Ay 17 A AUTO- +5 5 + PLL By 12 B
BALANCE SUMMING Cy 11 C AMP 23 I1
CK2 CK2
9 - U7C 8 5 CK2 MANUAL BALANCE +5 10 +
+30
2.0K
R44 +15 3 1
+ C2 2.2
SEDOHTAC/ETAG
ROTSIRYHTOT
PHASE LOSS DETECTION PHASE SEQUENCE SWITCHING +5 RN5
TP15 & REFERENCE COMPARATORS 1 1 5 K 2 RN2 PL 2 U6A +55 C23 2 3 47K 1 4 9 220p 5 3 6 4
-64 1 TP5 RN4
4 0.27µ 5 6 15 Ax 2 C33 14 1 2 0 K 1 -56 8 7 N 220p .033
1 4
U6B +67 TP16 C24 0. C 15 2 µ 5 14Bx 3 C34 C17 13 2 P1PM1 G g
13 +511 0.10µ 2 R 47 N K 9 1 220p .033 P R 2 K nc 4 k
U6C -610
+5
C
0.
2
2
9
7µ
3
5
4
6 TP10
13 Cx 4 C
22
3
0
5
p .
C
03
1
3
8 12 3
P P 1 2 PM2 G K +Bx 5 6
2 KEY
-58 +7 8 7 12 Ay 5 C36 C19 11 4 R
14
U6D R30 220p .033
+69 34.0K +12 P1PM3 G 7
+Cx 11 By 6 C37 C20 10 5 P2 K 8
220p .033 R
J2 P2
10 Cy 7 C38 C21 9 6 P1PM4 G 1 -Ax .033 2 P2 K 2 8 nc 8 7 nc 250 R
1 C22 C11 .33 R1 P1PM5 G 4 3 KEY 250 -Bx .33 P2 K 5
C12 R2 R
TP8 250 nc 6
3 23 6 +Ax .33 R3 P1PM6 G 7 +A C13 -Cx RN7A 4 3 3 JU2 CK2 B C A x x x 1 1 1 1 2 7 + + -A B C 7 2 8 0 + + -A B C x x x +30 +3 9 0 U 1 1 R 0 0 7 TP9 P P R 1 2 PM7 G K J3 8 1 P3 g
5 6 JU1 CK2 N 9 - - B C 1 1 9 8 - - B C x x 1 2 1 1 6 5 P R 2 K +Ay 2 k 5 Iy 3 14
PM8 7 P1 G 3 22 4 13 P2 K +By 4
5 12 R 7 KEY
nc 8
6 11 P1PM9 G 5
2 +Cy 14 C2 C27 8 P2 K 6
13 C11 680p 2 R
C39(omit) +30 10 250 J4 P4
0.27µ 2 3 1 R12 1 4 6 R35 5 R8 .33 R4 P P 1 2 PM10G K -Ay 1 2 C30 H J5P5 C14 250 R nc 3 1 4 .33 R5 8.87K I224 +12 60HZ 2 P1PM11G 4
8 R20 Adx BPo 16 nc 50HZ 3 C .3 1 3 5 250 P2 K -By 5
9 0.01µ Ax BPi 3 +12 115K R6 R 6 KEY
R36 C16 P1PM12G 7
TP13 9 TP14 P2 K -Cy 8 +30 U11
JU4 2.67K +A 6 +Ay 1 16 R Ixy R23 +B 7 +By 2 15 eAx J7 1 P7
8 +Cy 3 14 eBx 2 Vc +C 20 -Ay 4 13 eCx 3 6 -A eAy 4 TEST
CK2 -B 19 -By 5 12 eBy 5 P R H EF A E S R E ENCES -C 18 -Cy 6 11 eCy 6
25K 7 10 nc +5 RN6 7
R11 8 1 1 5 K 2 +15 8 3 4 10mAmax JU5 5 6
CK2 5 +5 REFERENCE
4
6 U12B nc 34.0K 10 47K 9 +12
+12 +12 +12 +12 +12 +12 +12 +12 8 10 R38 RN9 9 U12B nc
10 10 16 3 4 4 14 14 3 + C6 2 U3 U4 U5 + 2 C . 5 2µ U6 U7 U8 U9 U12 1 1 2 3 U12B 11 nc + U8A 1 +5 470 4 4 8 1 12 11 11 7 7 2 -


### Table 1

| PWBARTWORK REVISIONS RN1 PHASE LOSS DETECTION PHASE SEQUENCE SWITCHING +5 RN5 2 1 +12 3.3K LTR DESCRIPTION DATE APPD. PHASE LOSS 3 4 F Add current auto balance circuit 08-13-96 fjb U5 N TP15 & REFERENCE COMPARATORS 1 1 5 K 2 RN2 PL 2 U6A +55 C23 2 3 47K 1 4 9 220p 5 3 6 4 PD1 INHIBIT G-J Unreleased revisions (Enerpro'sinternal revision changes) 0 0 1 6 - - 2 0 4 4 - - 0 0 5 8 fjb -64 1 TP5 RN4 5 6 PWR ON PD2 e Ax K R hy e s p t l e a r c e e s i 1 s 2 c V a p re a g c u it l o a r t s or C ( 3 n 3 e - w C 3 T 8 O . - A 9 d 2 d P C K 5 G , ) C . 6 A , d a d n p d h C a 3 se 9 . r C ef o e r r r e e n c c t e g r c o o u m nd p a p r l a a t n o e r . 09-30-09 srs 4 0.27µ 5 6 15 Ax 2 C33 14 1 2 0 K 1 -56 8 7 N 220p .033 7 8 1 4 PD3 e Bx J1 P1 3 U6B +67 TP16 C24 0. C 15 2 µ 5 14Bx 3 C34 C17 13 2 P1PM1 G g +Ax 1 13 +511 0.10µ 2 R 47 N K 9 1 220p .033 P R 2 K nc 4 k e Cx U6C -610 C 2 9 3 4 13 Cx 4 C 3 5 C 1 8 12 3 2 KEY +5 0. 2 7µ 5 6 TP10 22 0 p . 03 3 P P 1 2 PM2 G K +Bx 5 6 e Ay -58 +7 8 7 12 Ay 5 C36 C19 11 4 R 14 U6D R30 220p .033 P6 J6 +69 34.0K +12 P1PM3 G 7 L1 9 100 10 U10 7 e By +Cx 11 By 6 C37 C20 10 5 P2 K 8 R9 1.50K 20.0K +12 220p .033 R R21 CR2 R29 J2 P2 +12 e JU3 0.10 Cy 2 +12/PL 5 10.0K C26 - U7A 1 SS 1 TP17 10 Cy 7 C38 C21 9 6 P1PM4 G 1 -Ax .033 2 P2 K 2 8 nc 8 7 nc 250 R R43 3 + 2 U9B 9 8 750K SS I1 3 4 6 Ix U9A 5 SEDOHTAC/ETAG 1 C22 C11 .33 R1 P1PM5 G 4 3 KEY 250 -Bx .33 P2 K 5 R34 C12 R2 R 10.0K TP8 250 nc 6 R28 I1 4 2 33K 1 1.50K R41 CR3 +5 U3 I +12 33K A RN7B B C ROTSIRYHTOT 3 23 6 +Ax .33 R3 P1PM6 G 7 +A C13 -Cx RN7A 4 3 3 JU2 CK2 B C A x x x 1 1 1 1 2 7 + + -A B C 7 2 8 0 + + -A B C x x x +30 +3 9 0 U 1 1 R 0 0 7 TP9 P P R 1 2 PM7 G K J3 8 1 P3 g +12 1.50K 6 - R42 CR4 CR5 U7B 7 I2 12 10.0K 100K 5 + +12 33K N TP4 RN7C 11 12 10 CK2 5 6 JU1 CK2 N 9 - - B C 1 1 9 8 - - B C x x 1 2 1 1 6 5 P R 2 K +Ay 2 k 5 Iy 3 14 R39 R22 + C4 CR6 U9C TP6 13 Ad PM8 7 P1 G 3 22 4 13 P2 K +By 4 SOFT START 22µ R37 C32 TP7 220p 5 12 R 7 KEY RN3 nc 8 +12 249K 32.4K 5 1 0 0 K 6 DAx 15 DA 6 11 P1PM9 G 5 R25 R27 3 4 DBx DB 2 +Cy 14 C2 C27 8 P2 K 6 2 1 DCx DC 13 C11 680p 2 R OMIT C39(omit) +30 10 250 J4 P4 R52 100K 9 R24 - TP1 U8C 8 47.5K 13 - SIG HI 10 47.5K 10 + R47 U7D 14 8.87K SLANGIS LORNOC TP12 RN8 VC 5 6 DAy 100K CK1 3 4 DBy TP3 2 1 DCy 21CK1 U4 0.27µ 2 3 1 R12 1 4 6 R35 5 R8 .33 R4 P P 1 2 PM10G K -Ay 1 2 C30 H J5P5 C14 250 R nc 3 1 4 .33 R5 8.87K I224 +12 60HZ 2 P1PM11G 4 R26 +5 12 + BUFFER R31 C31 1 Adx 8 R20 Adx BPo 16 nc 50HZ 3 C .3 1 3 5 250 P2 K -By 5 10.0K 22 AMPLIFIER +12 OMIT 2 Ax 9 0.01µ Ax BPi 3 +12 115K R6 R 6 KEY R40 REMOTSUC TP18 R46 TP11 22 Ady R36 C16 P1PM12G 7 Iy/B 14 10.0K C28 9 CK2 Ixy+CK2 Ixy N 475K TP13 9 TP14 P2 K -Cy 8 +30 U11 R48 100K 12+ R50 U8D 14 R45 23.2K 15DA 1 R33 14 DB JU4 2.67K +A 6 +Ay 1 16 R Ixy R23 +B 7 +By 2 15 eAx J7 1 P7 Ix/CK2 15 10.0K 13 - R49 100K R51 U12A 3 53.6K 6 - TP2 13 DC 2 R32 U8B 7 Ay 17 A AUTO- +5 5 + PLL By 12 B 8 +Cy 3 14 eBx 2 Vc +C 20 -Ay 4 13 eCx 3 6 -A eAy 4 TEST 13 BALANCE SUMMING Cy 11 C AMP 23 I1 CK2 -B 19 -By 5 12 eBy 5 P R H EF A E S R E ENCES -C 18 -Cy 6 11 eCy 6 10mAmax +12 6 +12 CK2 CK2 25K 7 10 nc +5 RN6 7 2mAmax +5 7 +5 +C3 9 - U7C 8 5 CK2 MANUAL BALANCE +5 10 + R11 8 1 1 5 K 2 +15 8 3 4 10mAmax JU5 5 6 2.2µ +30 CK2 5 +5 REFERENCE 4 +30 3 2.0K 6 U12B nc 34.0K 10 47K 9 +12 +12 24 Vac +30 1 ac + 200 U2 R44 +15 3 1 +12 +12 +12 +12 +12 +12 +12 +12 8 10 R38 RN9 9 U12B nc BUR11 R10 Approvals Date 24 Vac 2 ac - + C1 CR1 COM 12-PULSE FIRING BOARD COM 1000 15V dwn:fjb 06-03-92 8 + C2 2.2 10 10 16 3 4 4 14 14 3 + C6 2 U3 U4 U5 + 2 C . 5 2µ U6 U7 U8 U9 U12 1 1 2 3 U12B 11 nc + U8A 1 +5 470 4 4 8 1 12 11 11 7 7 2 - ver:kca/srs 09-30-09 PWBPNFCOG1200 E640K COM 11 SIZE: B SHEET 1 OF 2 | PWBARTWORK REVISIONS |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | LTR |  | DESCRIPTION |  |  |  | DATE | APPD. |
|  | F |  | Add current auto balance circuit |  |  |  | 08-13-96 | fjb |
|  |  |  |  |  | SIZE: B | SHEET 1 OF 2 |  |  |


### Table 2

| RN5 |
| --- |
| 1 5 K |
|  |


### Table 3

| RN2 |  |
| --- | --- |
| 2 47K 3 5 8 | 47K |


### Table 4

| 3 | 4 |
| --- | --- |
| 5 | 6 |


### Table 5

|  |  |  |  |  |  |  |  |  |  |  | U5 N Ax |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | TP10 |  |  |  |  |  |  |  | 14 13 12 | Bx | 3 C34 C17 13 220p .033 4 C35 C18 12 220p .033 5 C36 C19 11 |  |  |  | 4 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  | Cx Ay |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | U6D R30 +69 34.0K +12 1.50K 20.0K +12 R21 CR2 R29 0.10 2 - C26 U7A 1 SS 1 TP17 3 + 2 U9B 9 SS I1 3 8 4 U9A 6 Ix 750K 5 R34 10.0K R28 3 2 33K 1 CK2 |  |  |  |  |  |  |  |  | 11 10 | By Cy | 220p .033 6 C37 C20 220p .033 7 C38 C21 |  |  | 10 9 |  | 5 e By 6 e Cy |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  | .033 2 8 nc 8 7 nc 250 1 C22 C11 .33 R1 250 .33 C12 R2 TP8 250 U3 23 I +A 6 +Ax C13 .33 R3 Ax +30 10 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | R 3 P1PM5 G 4 -Bx P2 K 5 R nc 6 P1PM6 G 7 -Cx P2 K 8 |
| 1.50K RN7A +12 4 R 3 N 3 7 K B 3 JU2 R41 CR3 3 +5 +12 1 R .5 4 0 2 K CR4 CR5 6 - U7B 7 +12 5 R 3 N 3 7 K C 6 11 JU1 CK2 2 10.0K 100K 5 + 12 10 Iy 7 R39 R22 + C4 13 U9C CR6 SOFT START 22µ R37 TP7 RN3 +12 249K 32.4K 5 1 0 0 K 6 R25 R27 3 4 2 1 OMIT C39(omit) TP12 R52 100K 0.27µ 5 R N 8 6 100K R24 |  |  |  |  |  |  | 17 A Bx 12 B Cx 11 C N 9 N TP4 5 C TP6 22A C32 220p DAx 15 D DBx 14 D DCx 13D 3 V DAy 21 C |  |  |  |  |  | +B +C -A -B -C K2 d A B C2 C C1 C R1 K1 H | 7 +Bx R7 8 +Cx 9 TP9 20 -Ax +30 U10 1 16 19 -Bx 18 -Cx 2 15 3 14 4 13 5 12 6 11 2 C27 8 1 680p 2 +30 10 250 24 .33 R8 R4 16 R35 5 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | DAx DBx DCx DAy |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| 9 - TP1 C30 3 4 0 47.5K 10 + U8C 8 4 R 7. 4 5 7 K 13 - U7D 14 8.87K 8.87K 2 1 8 R26 +5 12 + BUFFER R20 R31 C31 10.0K 22 9 AMPLIFIER +12 OMIT 0.01µ R40 R46 TP18 C28 CK2 Ixy+CK2 Ixy 4 10.0K 475K R48 1 0 0 K 12+ JU4 R45 2 3. 2 K 2 .6 7 K R 5 0 U8D 14 Ixy 1 R 3 3 R 2 3 5 1 R 0. 4 0 9 K 100K 13 - 2 U12A 3 5 R 3. 3 6 2 K 6 5 - U8B 7 TP2 Vc R51 AUTO- 6 +5 + PLL BALANCE SUMMING 3 AMP 10mAmax +12 CK2 25K CK2 R11 2mAmax +5 MANUAL BALANCE + |  |  | D D B C y y TP 2 3 1CK1 U4 I224 60HZ J5 1 P5 4 C .3 1 3 4 25 R 0 5 +12 2 Adx 1 Adx BPo 16 nc 50HZ 3 C .3 1 3 5 250 Ax 2 Ax BPi 3 +12 115K R6 TP11 22 Ady R36 C16 9 N TP13 +30 9 U11 TP14 15DA +A 6 +Ay 1 16 14 DB +B 7 +By 2 15 13 DC 8 +Cy 3 14 Ay 17 +C A By 12 -A 20 -Ay 4 13 B Cy 11 C -B 19 -By 5 12 23 18 -Cy 6 11 I1 -C 7 10 nc +5 RN6 9 - 8 1 1 5 K 2 U7C 8 5 CK2 3 4 +5 10 + 5 6 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |


### Table 6

| C29 +5 0.27µ +7 | 3 5 8 |
| --- | --- |


---
## Page 2

PART PART NUMBER STOCK NUMBER PART PART NUMBER STOCK NUMBER PWBARTWORK REVISIONS
U1 W02M D1BRW02M C1 ECEA1JU102 C1EL063102 LTR DESCRIPTION DATE APPD.
U2 LM78L12CZL T2VLM78L12 C2-C3 ECSF1CE225K C1TN016225 F Add current auto balance circuit 08-13-96 fjb
U3 EP1014 I11014D C4 ECSF1CE226K C1TN016226 G-J Unreleased revisions (Enerpro'sinternal revision changes) 0 0 1 6 - - 2 0 4 4 - - 0 0 5 8 fjb
U4 EP1015 I11015 C5 ECSF1CE225K C1TN016225 K R hy e s p t l e a r c e e s i 1 s 2 c V a p re a g c u it l o a r t s or C ( 3 n 3 e - w C 3 T 8 O . - A 9 d 2 d P C K 5 G , ) C . 6 A , d a d n p d h C a 3 se 9 . r C ef o e r r r e e n c c t e g r c o o u m nd p a p r l a a t n o e r . 09-30-09 srs
U5 EP1016 I11016
C6 ECEA1JU471 C1EL050471
U6 LM239N I1239N
C11-C16 MKC4-.33uF10% C1FL063334
U7 MC34074BC I134074P
C17-C22 MKS3-.033uF5% C1FL250333
U8 MC34074BC I134074P
U9 MC14073BCP I14073BCP C23 MKS3-.27uF10% C1FL063274 1 4
U10-U11 ULN2004A I12004A C24 MKS3-.1uF10% C1FL100104
U12 MC14070BCP I14070B C25 MKS3-.15uF10% C1FL100154
CR1 1N5352B(15V) D1N5352B C26 MKS3-.1uF10% C1FL100104
CR2-CR6 1N914B D1N914B C27 FKC3-.00068uF5% C1FL160681
PD1-PD2 LN21RPH(RED) D1LN21RPH
C28 MKS3-.01uF10% C1FL100103
PD3 LN31GPH(GRN) D1LN31GPH
C29 MKS3-.27uF10% C1FL063274 1 4
RN1 750-83-R3.3K R1S08I332
C30 MKS3-.27uF10% C1FL063274
RN2 750-83-R47K R1S08I473
C31 ECSF1CE226K(optional) C1TN016226 9
RN3 750-63-R100K R1S06I104
C32 FKC3-.00022uF5% C1FL160221
RN4 760-3-R120K R1D14I124 4
C33-C38 FKC3-.00022uF5% C1FL160221 NOTES
RN5-RN6 750-63-R15K R1S06I153
C39 OMIT OMIT NO. DESCRIPTION
RN7 750-63-R33K R1S06I333
PM1-PM12 EP1024-1 (R=2.00M) T1PM10241 1 MatchC23&C29to 1%.
RN8 750-63-R100K R1S06I104
RN9 750-103-R47K R1S10I473 J1-J4 641828-1 (each keyed uniquely) C2MNLVPH08 2 Mount R1-R6 flush to the board.
P1-P4 640582-1 C2MNLPLG08
R1-R6 RS2B-R250OHM R1W03W250 3 InstallJU1andJU2for 2-30 gate pulse bursts. Use this pulse profile for rectifiers with normal load inductance; otherwise, gating is 1-120 burst mode.
R7-R8 CW2C-R10OHM R1W03W010 J5 68024-103 C2MSCH03 For 50 Hz operation:
R9 CW2C-R100OHM R1W03W100 P5 65474-001 C2MSCJ03 moveP5to pins 2 & 3 ofJ5
4
changeRN4to150k
R10 CW5-R200OHM R1W05W200 J6 350714-1 C2MNLVPH15
changeC23&C29to0.33ufd(matched 1%)
R11 93PR25K R1P93P253 P6 350736-1 C2MNLPLG15
5 Factory selected resistance.
R20-R52 RN60(see table) KEY PLUG 1-640415-0 C2KP94V0
For manual auto balance:
J7 640456-8 C2MTAVPH08 InstallR11
RN60 RESISTORS (K ) JU1-JU5 923345-01-C (optional) W1J01 OmitU12,R48,R49,JU4&JU5
R20 8.87 R37 7 TP1-TP18 TP-104-01-02 T3TP104 For off-board auto balance:
R21 1.50 R38 34.0 COM W1JCOMM(COMMON W1JCOMM 6 InstallJU4,JU5, &R48
JUMPER) OmitU12,R11, & R49
R22 100 R39 10.0
Contact
R23 2.67 R40 10.0 8 Sockets 350536-1 C2CS3505361 For on-board auto balance:
InstallU12,R48, &R49
R24 100 R41 1.50 OmitR11,JU4, &JU5.
R25 249 R42 1.50
R26 47.5 R43 10.0 7 Optional1.5k pull-down resistorR37, connectI2to +12V for soft-start. R42must be omitted.
8 For current signal input, selectR40to give SIG HI = +6.0Vwith maximum signal current.
R27 32.4 R44 2.00
9 SelectC31capacitance in conjunction with SIG HI source resistance to reduce the firing circuit bandwidth (optional).
R28 10.0 R45 475
R29 20.0 R46 OMIT
R30 34.0 R47 47.5
R31 8.87 R48 10.0 6
R32 53.6 R49 10.0 6
R33 23.2 R50 100
R34 750 R51 100
R35 SELECT R52 OMIT
R36 115
Approvals Date
12-PULSE FIRING BOARD
dwn:fjb 06-03-92
ver:kca/srs 09-30-09 PWBPNFCOG1200 E640K
SIZE: B SHEET 2 OF 2


### Table 1

|  |
| --- |
|  |
|  |


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
| PD1-PD2 | LN21RPH(RED) | D1LN21RPH |
| PD3 | LN31GPH(GRN) | D1LN31GPH |
| RN1 | 750-83-R3.3K | R1S08I332 |
| RN2 | 750-83-R47K | R1S08I473 |
| RN3 | 750-63-R100K | R1S06I104 |
| RN4 | 760-3-R120K | R1D14I124 4 |
| RN5-RN6 | 750-63-R15K | R1S06I153 |
| RN7 | 750-63-R33K | R1S06I333 |
| RN8 | 750-63-R100K | R1S06I104 |
| RN9 | 750-103-R47K | R1S10I473 |
| R1-R6 | RS2B-R250OHM | R1W03W250 |
| R7-R8 | CW2C-R10OHM | R1W03W010 |
| R9 | CW2C-R100OHM | R1W03W100 |
| R10 | CW5-R200OHM | R1W05W200 |
| R11 | 93PR25K | R1P93P253 |
| R20-R52 | RN60(see table) |  |


### Table 3

| PART | PART NUMBER | STOCK NUMBER |
| --- | --- | --- |
| C1 | ECEA1JU102 | C1EL063102 |
| C2-C3 | ECSF1CE225K | C1TN016225 |
| C4 | ECSF1CE226K | C1TN016226 |
| C5 | ECSF1CE225K | C1TN016225 |
| C6 | ECEA1JU471 | C1EL050471 |
| C11-C16 | MKC4-.33uF10% | C1FL063334 |
| C17-C22 | MKS3-.033uF5% | C1FL250333 |
| C23 | MKS3-.27uF10% | C1FL063274 1 4 |
| C24 | MKS3-.1uF10% | C1FL100104 |
| C25 | MKS3-.15uF10% | C1FL100154 |
| C26 | MKS3-.1uF10% | C1FL100104 |
| C27 | FKC3-.00068uF5% | C1FL160681 |
| C28 | MKS3-.01uF10% | C1FL100103 |
| C29 | MKS3-.27uF10% | C1FL063274 1 4 |
| C30 | MKS3-.27uF10% | C1FL063274 |
| C31 | ECSF1CE226K(optional) | C1TN016226 9 |
| C32 | FKC3-.00022uF5% | C1FL160221 |
| C33-C38 | FKC3-.00022uF5% | C1FL160221 |
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
| JU1-JU5 | 923345-01-C (optional) | W1J01 |
| TP1-TP18 | TP-104-01-02 | T3TP104 |
| COM | W1JCOMM(COMMON JUMPER) | W1JCOMM |
| Contact Sockets | 350536-1 | C2CS3505361 |


### Table 4

| PWBARTWORK REVISIONS |  |  |  |
| --- | --- | --- | --- |
| LTR | DESCRIPTION | DATE | APPD. |
| F | Add current auto balance circuit | 08-13-96 | fjb |
| G-J | Unreleased revisions (Enerpro'sinternal revision changes) | 01-24-05 06-04-08 | fjb |
| K | Replace 12V regulator (new TO-92PKG). Add phase reference comparator hysteresiscapacitorsC33-C38. AddC5,C6, andC39. Correct ground plane. | 09-30-09 | srs |


### Table 5

| NO. | DESCRIPTION |
| --- | --- |
| 1 | MatchC23&C29to 1%. |
| 2 | Mount R1-R6 flush to the board. |
| 3 | InstallJU1andJU2for 2-30 gate pulse bursts. Use this pulse profile for rectifiers with normal load inductance; otherwise, gating is 1-120 burst mode. |
| 4 | For 50 Hz operation: moveP5to pins 2 & 3 ofJ5 changeRN4to150k changeC23&C29to0.33ufd(matched 1%) |
| 5 | Factory selected resistance. |
| 6 | For manual auto balance: InstallR11 OmitU12,R48,R49,JU4&JU5 For off-board auto balance: InstallJU4,JU5, &R48 OmitU12,R11, & R49 For on-board auto balance: InstallU12,R48, &R49 OmitR11,JU4, &JU5. |
| 7 | Optional1.5k pull-down resistorR37, connectI2to +12V for soft-start. R42must be omitted. |
| 8 | For current signal input, selectR40to give SIG HI = +6.0Vwith maximum signal current. |
| 9 | SelectC31capacitance in conjunction with SIG HI source resistance to reduce the firing circuit bandwidth (optional). |


### Table 6

| R20 | 8.87 |  | 7 |
| --- | --- | --- | --- |
| R21 | 1.50 | R38 | 34.0 |
| R22 | 100 | R39 | 10.0 |
| R23 | 2.67 | R40 | 10.0 8 |
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
| R35 | SELECT | R52 | OMIT |
| R36 | 115 |  |  |


### Table 7

|  |  |  |  |
| --- | --- | --- | --- |
| Approvals | Date | 12-PULSE FIRING BOARD |  |
| dwn:fjb | 06-03-92 |  |  |
| ver:kca/srs | 09-30-09 | PWBPNFCOG1200 | E640K |
|  |  | SIZE: B | SHEET 2 OF 2 |
