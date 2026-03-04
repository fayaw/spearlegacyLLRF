# Spear1Tests20220817

> **Source:** `hvps/maintenance/Spear1Tests20220817.xlsx`
> **Format:** XLSX (converted to Markdown for AI readability)


## Sheet: Sheet1

| Spear 2 Crowbar Stack Testing |  | Test Date: 7/28/2018 |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stacks removed July 06, 2018 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| All data @ 30 minutes | LC @ 25KV | Temps | Overvolts | Light |  |  |  |  |  |  |  |
| HV applied | mA | Deg. C | Self-Fire KV | Trigger |  |  |  |  |  |  |  |
|  |  | Time= 30 mins | Pass/Fail | Pass/Fail |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Crowbar 1 | 0.891+ | 28.2-32.4 | P43.3KV | Pass |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Crowbar 2 | 0.862 | 28.4-35.2 | P 42.8KV | Pass |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Crowbar 3 | 0.888 | 29.1-35.6 | P43.25KV | Pass |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Crowbar 4 | 0.911+ | 28.2-37.9 | P 43.4KV | Pass |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| All 4 stacks removed from Spear 2 RF HVPS on July 6, 2018 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Conclusions:  Stack 4 has high leakage current (nominal should be < .890 mA) and is likely a culprit in sagging output volts.  Stack 1 leakage current creaping upward slowly and is marginal.  Stacks 2+3 appear to be good:  leakage current was steady over 1/2 hour test period. |  |  |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet2

| Spear 2 Crowbar Stack Testing |  | Test Date: 8/4/2018 |  |  |  |
| --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |
| Stacks removed from Spear 2  August 03, 2018 |  |  |  |  |  |
|  |  |  |  |  |  |
| All data @ 30 minutes | LC @ 25KV |  | Overvolts | Light |  |
| HV applied | mA |  | Self-Fire KV | Trigger |  |
|  |  |  | Pass/Fail | Pass/Fail |  |
|  |  |  |  |  |  |
| Crowbar 1 | 0.857 | 1.12 mA | Failed @ 43KV | Pass |  |
|  |  |  |  |  |  |
| Crowbar 2 | 0.891 |  | Pass @ 43.55KV | Pass |  |
|  |  |  |  |  |  |
| Crowbar 3 | 0.861 |  | Pass @ 44.2 KV | Pass |  |
|  |  |  |  |  |  |
| Crowbar 4 | 0.887 |  | Pass @ 43.05 | Pass |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
| Conclusions:  Stack 1 functioned normally with good, stable leakage current.  One SCR (#3 in stack 1) failed with self-fire @ 43 KV.  The stack was good during ops.  It is not normal for a stack to self-fire--the crowbar ckt operates with a trigger pulse.  Leakage after failed SCR was 1.1 mA and stable @ 25KV.  The other 5 SCRs in the stack are good. Stack 2 leakage @ 30 minutes was a little high, but appears to function correctly.  Stacks 3+4 are good with stable leakage current @ 25 KVDC.  It's possible over a longer operational period at higher temperatures in the crowbar tank than in free air the stacks started to partially self-fire (possibly stack 2).  But from the uncertainty of this limited testing, it is warranted to test the main tank rectifiers and filter circuits and to replace the main tank rectifiers and filter caps and to perform a thorough inspection of wiring and bushings. |  |  |  |  |  |


## Sheet: Sheet3

| Spear 2 RF HVPS Individual SCR Tests |  |  |  |  | 2018-08-08 00:00:00 |  |  |  |  | Spear 2 RF HVPS Individual SCR Tests |  |  |  |  | 2018-08-15 00:00:00 |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Set 2 Crowar Stacks removed 3 August 2018 |  |  |  |  |  |  |  |  |  | Set 1 Crowar Stacks removed 6 July 2018 |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 1 | SCR # | Serial # | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  | Stack 1 | SCR # | Serial # | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 1 | 2436 | 10.1 | 17.7 | Good | 7.7 KV | Yes |  |  |  | 1 | 2326 | 154.2+ | 495+ | Good | 7.35 | No |  |  |
|  | 2 | 2364 | 28.8 | 49.2 | Good | 7.3 KV | Yes |  |  |  | 2 | 2322 | 34.6 | 71 | Good | 7.8 | Yes |  |  |
|  | 3 | 2362 | 23.4 | 64.2 | Good | Fail! | No |  |  |  | 3 | 2319 | 20.5 | 43 | Good | Fail! | No |  |  |
|  | 4 | 2357 | 25.5 | 42.4 | Good | 7.3 KV | Yes |  |  |  | 4 | 2428 | 81.6+ | 143.5+ | Good | 7.8 | No |  |  |
|  | 5 | 2361 | 11.6 | 21.5 | Good | 7.2 KV | Yes |  |  |  | 5 | 2429 | 99.3+ | 276.5+ | Good | 7.4 | No |  |  |
|  | 6 | 5636 | 57.4 + | 94.2 + | Good | 7.5 KV | No |  |  |  | 6 | 2350 | 9.3 | 24.7 | Good | 7.5 | Yes |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 2 | SCR # | Serial # | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  | Stack 2 | SCR # | Serial # | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 1 | 6219 | 51 | 416 | Good | Fail! | No |  |  |  | 1 | 3174 | 24.6 | 39.7 | Good | 7 | Yes |  |  |
|  | 2 | 6272 | 92 + | 279 + | Good | 7.72 KV | No |  |  |  | 2 | 6230 | 45+ | 85.7+ | Good | 7.8 | No |  |  |
|  | 3 | 6114 | 80 + | 220 + | Good | 7.75 | No |  |  |  | 3 | 6239 | 11.3 | 26.7 | Good | 7.7 | Yes |  |  |
|  | 4 | 6217 | 41.8 | 181 | Good | 7.8 | Yes |  |  |  | 4 | 5000 | 29.9 | 97.7 | Good | 7.5 | Yes |  |  |
|  | 5 | 6171 | 26.4 | 61.8 | Good | 7.825 | Yes |  |  |  | 5 | 6235 | 18 | 32.3 | Good | 7.8 | Yes |  |  |
|  | 6 | 6227 | 11.8 | 28.8 | Good | 7.85 | Yes |  |  |  | 6 | 6228 | 21.9 | 46.2 | Good | 7.8 | Yes |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 3 | SCR # | Serial # | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  | Stack 3 | SCR # | Serial # | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 1 | 6285 | 97 | 195 | Good | 7.75 | Yes |  |  |  | 1 | 6000 | 27.2+ | 150+ | Good | 7.7 | No |  |  |
|  | 2 | 6222 | 42 + | 140 + | Good | 7.8 | No |  |  |  | 2 | 6461 | 15 | 58.5 | Good | 7.6 | Yes |  |  |
|  | 3 | 6284 | 10.5 | 31.7 | Good | 7.75 | Yes |  |  |  | 3 | 6001 | 88.7 | 521+ | Good | 7.7 | No |  |  |
|  | 4 | 6287 | 13.2 | 34.5 | Good | 7.68 | Yes |  |  |  | 4 | 6002 | 16.1 | 72.6 | Good | 7.4 | Yes |  |  |
|  | 5 | 6286 | 29.2 | 162 | Good | 7.8 | Yes |  |  |  | 5 | 3292 | 32 | 79.5 | Good | 7.8 | Yes |  |  |
|  | 6 | 6220 | 15.7 | 31.5 | Good | 7.8 | Yes |  |  |  | 6 | 6003 | 63.4+ | 127.8+ | Good | 7.5 | No |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 4 | SCR # | Serial # | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  | Stack 4 | SCR # | Serial # | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 1 | 6260 | 18.4 | 45 | Good | 7.75 | Yes |  |  |  | 1 | 2731 | 18.5 | 62.6 | Good | 7.2 | Yes |  |  |
|  | 2 | 6264 | 101 + | 286 + | Good | 7.72 | No |  |  |  | 2 | 3502 | 22.9 | 35.8 | Good | 7.2 | Yes |  |  |
|  | 3 | 6263 | 26.9 | 45.2 | Good | 7.7 | Yes |  |  |  | 3 | 3356 | 22.5 | 38.8 | Good | 7.6 | Yes |  |  |
|  | 4 | 6262 | 84.7 + | 413 + | Good | 7.7 | No |  |  |  | 4 | 2874 | 20.4 | 51 | Good | 7 | Yes |  |  |
|  | 5 | 6294 | 29.3 | 162 | Good | Fail! | No |  |  |  | 5 | 2969 | 366+ | 633.2+ | Good | 7.7 | No |  |  |
|  | 6 | 3501 | 15.7 | 31.5 | Good | Fail! | No |  |  |  | 6 | 2928 | 27.8 | 43.8 | Good | 7.6 | Yes |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Note:  " + " symbol after a leakage current # = current creeping upwards.  Bad sign device will eventually |  |  |  |  |  |  |  |  |  | Note:  " + " symbol after a leakage current # = current creeping upwards.  Bad sign device will eventually |  |  |  |  |  |  |  |  |  |
| break down under voltage in crowbar tank. |  |  |  |  |  |  |  |  |  | break down under voltage in crowbar tank. |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  | Conclusions |  |  |  |  |  |  |  |  |  |  | Conclusions |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stacks 2 + 4 were bad.  Believe these 2 be the culprit in the second Spear 2 failure (< 2 days run time). |  |  |  |  |  |  |  |  |  |  | Stack 1 had 3 SCRs with high leakage current and a 4th SCR that failed on over-volts self-fire. |  |  |  |  |  |  |  |  |
| Stack 4 had 4 devices marginal or failed at self-fire (permanent short with one shot). |  |  |  |  |  |  |  |  |  |  | Stack 3 has 3 SCRs with high leakage current.  Both stack 1 + 3 indicate likely strong candidates for |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  | Spear 2 failure on July 06, 2018. |  |  |  |  |  |  |  |  |
| Stacks 1 + 3 are decent--not great though.  Overall, found 10 devices out of 24  either marginal or failed. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  | Stacks 2 + 4 are reasonably good. |  |  |  |  |  |  |  |  |
| It is apparent the previous 2 failures were due to crowbar stack failures.  At this point, will construct and test |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| best possible stacks with each device tested for leakage, fiber optic triggering and ability to withstand |  |  |  |  |  |  |  |  |  |  | It strongly appears both sets of crowbar stacks installed in Spear 2 led to the failures seen on Spear 2 over |  |  |  |  |  |  |  |  |
| over-voltage self-firing.  Testing the whole stack and calling that stack good is obviously not the way to go. |  |  |  |  |  |  |  |  |  |  | the short run times due to the inability of at least 2 stacks in each set being unable to hold off the |  |  |  |  |  |  |  |  |
| Previously, we tested the whole stack--it the overall leakage was under .890 and stable and passed trigger |  |  |  |  |  |  |  |  |  |  | necessary voltage to allow full power supply output. |  |  |  |  |  |  |  |  |
| testing, we declared it good.  From now on, we will test each device thoroughly and individually and use |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| the whole stack tests after a stack is assembled to make sure it works as a unit. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet4

| Spare SCR tests to rebuild Spear 2 Crowbar Stacks. |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |
|  |  |  | 2018-08-11 00:00:00 |  |  |  |
|  |  |  |  |  |  |  |
| Spare # | Serial # | uA @ 4.2 KV | uA @ 6.5 KV | Fiber Optic | OV Self-Fire | Good/Bad |
|  |  |  |  |  |  |  |
| 1 | 5654 | 32.7 + | 66.4 + | Pass | 7.8 KV | Bad |
| 2 | 5640 | 11.6 | 40.2 | Pass | 7.75 | Good |
| 3 | 2363 | 23.3 | 37.8 | Pass | 7.1 | Good |
| 4 | 6224 | 13.8 | 30.1 | Pass | 7.795 | Good |
| 5 | 3359 | 10.6 | 17.5 | Pass | 7.05 | Good |
| 6 | 3381 | 15.4 + | 42.1 + | Pass | 6.95 | Marginal |
| 7 | 3175 | 9.8 | 16.6 | Pass | 7 | Good |
| 8 | 2998 | 11.4+ | 45.6+ | Pass | 7.1 | Marginal |
| 9 | 6279 | 10.7 | 20.5 | Pass | 7.8 | Good |
| 10 | 2360 | 8.7 | 16.2 | Pass | 7 | Good |
| 11 | 3186 | 25.2 | 47.2 | Pass | 7 | Good |
| 12 | 3360 | 4.5 | 9.5 | Pass | 7 | Good |
| 13 | 3219 | 20.5+ | 40.1+ | Pass | 7.4 | Marginal |
| 14 | 3172 | 84.3+ | 138.1+ | Pass | 7.2 | Marginal |
| 15 | 5653 | 6.2 | 15 | Pass | 7.45 | Good |
| 16 | 6234 | 11.1 | 24.4 | Pass | 7.8 | Good |
| 17 | 6239 | 9.5 | 18.8 | Pass | 7.6 | Good |
| 18 | 6244 | 6.7 | 19.6 | Pass | 7.6 | Good |
| 19 |  |  |  |  |  |  |
| 20 |  |  |  |  |  |  |
| 21 |  |  |  |  |  |  |
| 22 |  |  |  |  |  |  |
| 23 |  |  |  |  |  |  |
| 24 |  |  |  |  |  |  |
| 25 |  |  |  |  |  |  |
| 26 |  |  |  |  |  |  |
| 27 |  |  |  |  |  |  |
| 28 |  |  |  |  |  |  |
| 29 |  |  |  |  |  |  |
| 30 |  |  |  |  |  |  |
| 31 |  |  |  |  |  |  |
| 32 |  |  |  |  |  |  |
| 33 |  |  |  |  |  |  |
| 34 |  |  |  |  |  |  |


## Sheet: Sheet5

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| New Set of Crowbar Stacks for Spear 2 RF HVPS  18 Aug 2018 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 1 | SCR S/N | Stack Leakage @ 25 KVDC | Fiber Optic Trig Test | Pass/Fail |  | Old # |  |  |  |  |  |
| Cell 1 | 6239 |  |  |  |  |  |  |  |  |  |  |
| Cell 2 | 3359 |  |  |  |  |  |  |  |  |  |  |
| Cell 3 | 6461 | 0.846 uA | Pass | Pass |  | 0.85 |  |  |  |  |  |
| Cell 4 | 6279 |  |  |  |  |  |  |  |  |  |  |
| Cell 5 | 3175 |  |  |  |  |  |  |  |  |  |  |
| Cell 6 | 2350 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 2 |  |  |  |  |  |  |  |  |  |  |  |
| Cell 1 | 2360 |  |  |  |  |  |  |  |  |  |  |
| Cell 2 | 2322 |  |  |  |  |  |  |  |  |  |  |
| Cell 3 | 3502 | .859 uA | Pass | Pass |  |  |  |  |  |  |  |
| Cell 4 | 2731 |  |  |  |  |  |  |  |  |  |  |
| Cell 5 | 3186 |  |  |  |  |  |  |  |  |  |  |
| Cell 6 | 5653 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 3 |  |  |  |  |  |  |  |  |  |  |  |
| Cell 1 | 6239 |  |  |  |  |  |  |  |  |  |  |
| Cell 2 | 2361 |  |  |  |  |  |  |  |  |  |  |
| Cell 3 | 2874 | .848 uA | Pass | Pass |  | 0.868 |  |  |  |  |  |
| Cell 4 | 3292 |  |  |  |  |  |  |  |  |  |  |
| Cell 5 | 2436 |  |  |  |  |  |  |  |  |  |  |
| Cell 6 | 6244 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 4 |  |  |  |  |  |  |  |  |  |  |  |
| Cell 1 | 6234 |  |  |  |  |  |  |  |  |  |  |
| Cell 2 | 3356 |  |  |  |  |  |  |  |  |  |  |
| Cell 3 | 5000 | .851 uA | Pass | Pass |  |  |  |  |  |  |  |
| Cell 4 | 6220 |  |  |  |  |  |  |  |  |  |  |
| Cell 5 | 6284 |  |  |  |  |  |  |  |  |  |  |
| Cell 6 | 3360 |  |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet6

| Ohm Tests for New Spear 2 Crowbar Stacks |  |  |  |  | 2018-08-21 00:00:00 |  |  |  |  | Ohm Tests for New Spear 2 Crowbar Stacks |  |  |  |  | 2018-08-21 00:00:00 |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  | Updated |  |  |  |  |  |  |  |  |  | Updated |  |  |  |  |  |  |  |  |  |  |
| Fwd Direction |  | Ohms | Volts | Current | 2018-08-22 00:00:00 |  |  |  |  | Reverse Direction |  | Ohms | Volts | Current | 2018-08-22 00:00:00 |  |  |  |  |  |  |  |  |  |  |
|  |  | M Ohms |  | uA /mA |  |  |  |  |  |  |  | M Ohms |  | uA /mA |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | Old #s |  |  |  |  |  |  |  |  |  | Old #s |  |  |  |  |  |  |  |  |
| Stack 1 | Replace S/N | 29.3 | 10488 | 355 uA |  | 27.3 | 10489 | 394 uA |  | Stack 1 | Replace S/N | 29.5 | 10488 | 356 uA |  | 27.4 | 10489 | 383 uA |  |  |  |  |  |  |  |
| 1 |  | 4.78 | 5233 | 1.09 |  |  |  |  |  | 1 |  | 4.79 | 5232 | 1.09 |  |  |  |  |  |  |  |  |  |  |  |
| 2 | 3359 | 4.98 | 5234 | 1.05 |  | 4.7 | 5232 | 1.11 |  | 2 | 3359 | 4.99 | 5235 | 1.05 |  | 4.5 | 5231 | 1.16 |  |  |  |  |  |  |  |
| 3 |  | 4.76 | 5232 | 1.1 |  |  |  |  |  | 3 |  | 4.67 | 5231 | 1.12 |  |  |  |  |  |  |  |  |  |  |  |
| 4 | 6279 | 4.96 | 5233 | 1.06 |  | 4.7 | 5232 | 1.11 |  | 4 | 6279 | 4.92 | 5235 | 1.07 |  | 4.81 | 5232 | 1.09 |  |  |  |  |  |  |  |
| 5 | 3175 | 4.92 | 5233 | 1.06 |  | 4.55 | 5231 | 1.15 |  | 5 | 3175 | 4.92 | 5234 | 1.06 |  | 4.19 | 5230 | 1.25 |  |  |  |  |  |  |  |
| 6 |  | 4.9 | 5232 | 1.07 |  | Replaced SCRs 2,4, 5 in stack 1. |  |  |  | 6 |  | 4.87 | 5233 | 1.09 |  | Replaced SCRs 2,4, 5 in stack 1. |  |  |  |  |  |  |  |  |  |
|  |  |  | AVG: | 1.071666666666667 |  | Test results updated. |  |  |  |  |  |  | AVG: | 1.08 |  | Test results updated. |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 2 |  | 29.3 | 10491 | 358 uA |  |  |  |  |  | Stack 2 |  | 29.3 | 10490 | 358 uA |  |  |  |  |  |  |  |  |  |  |  |
| 1 |  | 4.94 | 5234 | 1.06 |  |  |  |  |  | 1 |  | 4.95 | 5234 | 1.06 |  |  |  |  |  |  |  |  |  |  |  |
| 2 |  | 4.75 | 5233 | 1.1 |  |  |  |  |  | 2 |  | 4.84 | 5233 | 1.08 |  |  |  |  |  |  |  |  |  |  |  |
| 3 |  | 4.9 | 5235 | 1.07 |  |  |  |  |  | 3 |  | 4.91 | 5234 | 1.07 |  |  |  |  |  |  |  |  |  |  |  |
| 4 |  | 4.89 | 5235 | 1.07 |  |  |  |  |  | 4 |  | 4.89 | 5234 | 1.07 |  |  |  |  |  |  |  |  |  |  |  |
| 5 |  | 4.85 | 5233 | 1.08 |  |  |  |  |  | 5 |  | 4.85 | 5233 | 1.08 |  |  |  |  |  |  |  |  |  |  |  |
| 6 |  | 4.97 | 5235 | 1.05 |  |  |  |  |  | 6 |  | 4.96 | 5234 | 1.06 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | AVG: | 1.0716666666666668 |  |  |  |  |  |  |  |  | AVG: | 1.07 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | Old #'s |  |  |  |  |  |  |  |  |  | Old #'s |  |  |  |  |  |  |  |  |
| Stack 3 |  | 29.5 | 10495 | 356 uA |  | 28.1 | 10489 | 374 uA |  | Stack 3 |  | 29.4 | 10494 | 357 uA |  | 27.9 | 10491 | 376 uA |  |  |  |  |  |  |  |
| 1 |  | 4.96 | 5235 | 1.06 |  |  |  |  |  | 1 |  | 4.89 | 5234 | 1.07 |  |  |  |  |  |  |  |  |  |  |  |
| 2 | 2361 | 4.97 | 5235 | 1.05 |  | 4.5 | 5232 | 1.16 mA |  | 2 | 2361 | 4.67 | 5233 | 1.12 |  | 4.67 | 5233 | 1.12 |  |  |  |  |  |  |  |
| 3 |  | 4.78 | 5233 | 1.1 |  |  |  |  |  | 3 |  | 4.96 | 5235 | 1.06 |  |  |  |  |  |  |  |  |  |  |  |
| 4 |  | 4.84 | 5233 | 1.08 |  |  |  |  |  | 4 |  | 4.65 | 5232 | 1.13 |  |  |  |  |  |  |  |  |  |  |  |
| 5 | 2436 | 4.97 | 5235 | 1.05 |  | 4.65 | 5232 | 1.12 |  | 5 | 2436 | 4.8 | 5233 | 1.05 |  | 4.8 | 5233 | 1.09 |  |  |  |  |  |  |  |
| 6 |  | 4.94 | 5234 | 1.06 |  | Replaced SCRs 2 + 5.  Test results |  |  |  | 6 |  | 4.87 | 5233 | 1.07 |  | Replaced SCRs 2 + 5.  Test results |  |  |  |  |  |  |  |  |  |
|  |  |  | AVG: | 1.0666666666666667 |  | updated. |  |  |  |  |  |  | AVG: | 1.0833333333333335 |  | updated. |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack 4 |  | 29.5 | 10493 | 355 uA |  |  |  |  |  | Stack 4 |  | 27.7 | 10489 | 378 uA |  |  |  |  |  |  |  |  |  |  |  |
| 1 |  | 4.92 | 5235 | 1.06 |  |  |  |  |  | 1 |  | 4.88 | 5234 | 1.07 |  |  |  |  |  |  |  |  |  |  |  |
| 2 |  | 4.92 | 5235 | 1.06 |  |  |  |  |  | 2 |  | 4.92 | 5235 | 1.06 |  |  |  |  |  |  |  |  |  |  |  |
| 3 |  | 4.83 | 5234 | 1.08 |  |  |  |  |  | 3 |  | 4.75 | 5233 | 1.1 |  |  |  |  |  |  |  |  |  |  |  |
| 4 |  | 4.91 | 5235 | 1.07 |  |  |  |  |  | 4 |  | 4.82 | 5234 | 1.08 |  |  |  |  |  |  |  |  |  |  |  |
| 5 |  | 4.95 | 5236 | 1.06 |  |  |  |  |  | 5 |  | 4.71 | 5233 | 1.11 |  |  |  |  |  |  |  |  |  |  |  |
| 6 |  | 4.98 | 5236 | 1.05 |  |  |  |  |  | 6 |  | 4.98 | 5235 | 1.05 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | AVG: | 1.0633333333333332 |  |  |  |  |  |  |  |  | AVG: | 1.0783333333333334 |  |  |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet7

| 2018-08-31 00:00:00 |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  | SCRs sent to Infineon for analysis |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
| Number | S/N | Date Code |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
| 1 | 2969 | 26R9 |  |  |  |  |  |  |  |  |
| 2 | 6001 | 20U9 |  |  |  |  |  |  |  |  |
| 3 | 3501 | 25S5 |  |  |  |  |  |  |  |  |
| 4 | 6114 | 20U9 |  |  |  |  |  |  |  |  |
| 5 | 6294 | 20U9 |  |  |  |  |  |  |  |  |
| 6 | 2429 | 13R2 |  |  |  |  |  |  |  |  |
| 7 | 2319 | ? |  |  |  |  |  |  |  |  |
| 8 | 6219 | 20U9 |  |  |  |  |  |  |  |  |
| 9 | 6272 | 20U9 |  |  |  |  |  |  |  |  |
| 10 | 2326 | ? |  |  |  |  |  |  |  |  |
| 11 | 6225 | 20U9 |  |  |  |  |  |  |  |  |
| 12 | 6223 | 20U9 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
| SCRs 11 + 12 are tested out of box, but unused in field. |  |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet8

| Spear 2 RF HVPS Hipot Test Results |  |  |  |  | 16 Aug 2018 + 24 Aug 2018 |  |  |  |  |  |  |  | Spear 2 RF HVPS Hipot Test Results |  |  |  |  | 7 Sept. 2018 |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| 2018-08-16 00:00:00 |  | Volts KV | Leakage I | Start/Stop |  |  |  |  |  |  |  |  |  |  | Volts KV | Leakage I | Start/Stop |  |  |  |
|  |  |  | mA |  |  |  |  |  |  |  |  |  |  |  |  | mA |  |  |  |  |
| Stage 1 | Begin | 25.5 | 5.2 | 1142 |  |  |  |  |  |  |  |  | Stage 1 | Begin | 25.5 | 5.85 | 0940 |  |  |  |
|  | 10 mins. | 26 | 5.2 | 1152 |  |  |  |  |  |  |  |  |  | 5 mins. | 25.3 | 5.82 | 0945 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stage 2 | Begin | 25 | 4.6 | 1158 |  |  |  |  |  |  |  |  | Stage 2 | Begin | 25.2 | 5.25 | 0954 |  |  |  |
|  | 10 mins. | 25.8 | 4.6 | 1208 |  |  |  |  |  |  |  |  |  | 5 mins. | 25.1 | 5.23 | 0959 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stage 3 | Begin | 25 | 6.6 | 1214 |  |  |  |  |  |  |  |  | Stage 3 | Begin | 25.4 | 4.33 | 1006 |  |  |  |
|  | 10 mins. | 25.5 | 6.55 | 1225 |  |  |  |  |  |  |  |  |  | 5 mins. | 25.4 | 4.32 | 1011 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stage 4 | Begin | 16 | 3 | 1227 |  |  |  |  |  |  |  |  | Stage 4 | Begin | 16.1 | 3.5 | 1017 |  |  |  |
|  | 10 mins. | 16 | 3 | 1237 |  |  |  |  |  |  |  |  |  | 5 mins. | 16 | 3.5 | 1022 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stage 1 to Stage 3: |  |  |  |  |  |  |  |  |  |  |  |  | Stage 1 to Stage 3: |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Not performed. |  |  |  |  |  |  |  |  |  |  |  |  | Begin | 80.5 | 4.85 | 1057 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  | 10 mins. | 80.5 | 4.7 | 1107 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| 2018-08-24 00:00:00 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stage 1 to Stage 4: |  |  |  |  |  |  |  |  |  |  |  |  | Stage 1 to Stage 4: |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Begin | 81.5 | 4.2 | 1120 |  |  |  |  |  |  |  |  |  | Begin | 89 | 4 | 1120 |  |  |  |
|  | 10 mins. | 80.5 | 4.15 | 1130 |  |  |  |  |  |  |  |  |  | 10 mins. | 89 | 4 | 1130 |  |  |  |


## Sheet: Sheet9

| Test of Spear 2 RF HVPS Main Rectifier Stack #3 vs Spare Main Rectifier Stack |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | from Building 725 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  | 8 Sept. 2018 |  |  |  |  |  |  |  | 8 Sept. 2018 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Hipot leakage currents stage to stage from August 16, 2018 |  |  |  |  |  |  |  |  | Spare Main Rectifier Diode Stack and Filter Box Diode Hipot Tests |  |  |  |  |  |  |  | Spear 2 RF HVPS Main Rectifier Diode Stack and Filter Box Diode Hipot Tests |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Volts KV | Leakage I | Start/Stop |  |  |  |  | Neg Rail | Volts | Leakage I | Dwell Time |  |  |  |  | Neg Rail | Volts | Leakage I | Dwell time |  |  |  |  |
|  |  |  | mA |  |  |  |  |  |  | KV | mA |  |  |  |  |  |  | KV | mA |  |  |  |  |  |
| Stage 1 | Begin | 25.5 | 5.2 | 1142 |  |  |  |  | A- | 25 | 4.7 | 1 Min. |  |  |  |  | A- | 25 | 7.32 | 1 Min. |  |  |  |  |
|  | 10 mins. | 26 | 5.2 | 1152 |  |  |  |  | B- | 25 | 4.9 | 1 Min. |  |  |  |  | B- | 25 | 8.04 | 1 Min. |  |  |  |  |
|  |  |  |  |  |  |  |  |  | C- | 25 | 4.7 | 1 Min. |  |  |  |  | C- | 25 | 7.38 | 1 Min. |  |  |  |  |
| Stage 2 | Begin | 25 | 4.6 | 1158 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 10 mins. | 25.8 | 4.6 | 1208 |  |  |  |  | Pos Rail | Volts | Leakage I | Dwell Time |  |  |  |  | Pos Rail | Volts | Leakage I | Dwell Time |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  | KV | mA |  |  |  |  |  |  | KV | mA |  |  |  |  |  |
| Stage 3 | Begin | 25 | 6.6 | 1214 |  |  |  |  | A+ | 25 | 4.9 | 1 Min. |  |  |  |  | A+ | 25 | 7.45 | 1 Min. |  |  |  |  |
|  | 10 mins. | 25.5 | 6.55 | 1225 |  |  |  |  | B+ | 25 | 5.3 | 1 Min. |  |  |  |  | B+ | 25 | 7.4 | 1 Min. |  |  |  |  |
|  |  |  |  |  |  |  |  |  | C+ | 25 | 4.9 | 1 Min. |  |  |  |  | C+ | 25 | 7.95 | 1 Min. |  |  |  |  |
| Stage 4 | Begin | 16 | 3 | 1227 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 10 mins. | 16 | 3 | 1237 |  |  |  |  |  | Filter Box Diodes, Spare Stack |  |  |  |  |  |  |  | Filter Box Diodes, #3 Rectifier Stack |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  | Neg Rail | Volts | Leakage I | Dwell Time |  |  |  |  | Neg Rail | Volts | Leakage I | Dwell Time |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  | KV | uA |  |  |  |  |  |  | KV | uA |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  | A- | 10 | 86 | 1 Min. |  |  |  |  | A- | 10 | 82 | 1 Min. |  |  |  |  |
|  |  |  |  |  |  |  |  |  | B- | 10 | 85 | 1 Min. |  |  |  |  | B- | 10 | 74 | 1 Min. |  |  |  |  |
|  |  |  |  |  |  |  |  |  | C- | 10 | 85 | 1 Min. |  |  |  |  | C- | 10 | 73 | 1 Min. |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  | Pos Rail | Volts | Leakage I | Dwell Time |  |  |  |  | Pos Rail | Volts | Leakage I | Dwell Time |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  | KV | uA |  |  |  |  |  |  | KV | uA |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  | A+ | 10 | 95 | 1 Min. |  |  |  |  | A+ | 10 | 77.5 | 1 Min. |  |  |  |  |
|  |  |  |  |  |  |  |  |  | B+ | 10 | 88 | 1 Min. |  |  |  |  | B+ | 10 | 80.2 | 1 Min. |  |  |  |  |
|  |  |  |  |  |  |  |  |  | C+ | 10 | 86 | 1 Min. |  |  |  |  | C+ | 10 | 81 | 1 Min. |  |  |  |  |


## Sheet: Sheet10

|  | Leakage Tests of SCRs Removed From LER 4-4 (Sept. 13-14, 2018) + 2 Stacks From Spear 2 (Oct. 26, 2012) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Spear 2 Crowbar Stack removed Oct. 26, 2012 |  |  |  |  |  |  |  |  |  |  |  | LER 4-4 Crowbar Stack SCRs removed 13+14 Sept. 2018 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 1 | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  |  |  |  | Stack 1 | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  |  |  |  |  |  |
|  | 1 | 2510 | 8.5 | 19.6 | Good | 6.9 | Y | Y |  |  |  |  | 1 | 5311 | 7.2 | 21 | Good | 7.1 | Y | Y |  |  |  |  |  |  |
|  | 2 | 2491 | 90.4 | 155.3 | Good | 9+ No SF | N | N |  |  |  |  | 2 | 5313 | 6.7 | 13.2 | Good | 7.1 | Y | Y |  |  |  |  |  |  |
|  | 3 | 2503 | 6 | 11 | Good | 6.9 | Y | Y |  |  |  |  | 3 | 5312 | 10.4 | 25.8 | Good | 7 | Y | Y |  |  |  |  |  |  |
|  | 4 | 2515 | 30.5 | 53.1 | Good | 6.9 | Y | Y |  |  |  |  | 4 | 5314 | 6 | 10.2 | Good | 7.1 | Y | Y |  |  |  |  |  |  |
|  | 5 | 2511 | 14.7 | 38.8 | Good | 7 | Y | Y |  |  |  |  | 5 | 5392 | 9.5 | 31 | Good | 7 | Y | Y |  |  |  |  |  |  |
|  | 6 | 2335 | 35 | 98.5 | Good | 6.9 | Y | Y |  |  |  |  | 6 | 5393 | 14.4 | 42.2 | Good | 7 | Y | Y |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 2 | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  |  |  |  | Stack 2 | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  |  |  |  |  |  |
|  | 1 | 3503 | 24.6 | 38.2 | Good | 6.85 | Y | Y |  |  |  |  | 1 | 5328 | 7 | 16 | Good | 7 | Y | Y |  |  |  |  |  |  |
|  | 2 | 3500 | 28.9 | 47.2 | Good | 7.1 | Y | Y |  |  |  |  | 2 | 5330 | 12.5 | 27.2 | Good | 7 | Y | Y |  |  |  |  |  |  |
|  | 3 | 3528 | 76.8+ | 113+ | Good | 7 | Marg. | N |  |  |  |  | 3 | 5331 | 18 | 38.8 | Good | 7.3 | Y | Y |  |  |  |  |  |  |
|  | 4 | 3461 | 1268+ | 4000+ | Good | Short SF | N | N |  |  |  |  | 4 | 5329 | 46.7+ | 98.5+ | Good | 7 | Marg. | N |  |  |  |  |  |  |
|  | 5 | 3523 | 87.5+ | 875+ | Good | 6.8 | Marg. | N |  |  |  |  | 5 | 5386 | 31.5 | 198 | Good | 6.85 | Y | Y |  |  |  |  |  |  |
|  | 6 | 3504 | 12.2 | 21.9 | Good | 6.8 | Y | Y |  |  |  |  | 6 | 5387 | 20.3+ | 84+ | Good | 6.95 | Marg. | N |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | Stack 3 | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 1 | 5409 | 61.7 | 208.3 | Good | 7 | Marg. | N |  |  |  |  |  |  |
|  | Note 1:  all currents listed on this sheet are in microamps (uA). |  |  |  |  |  |  |  |  |  |  |  | 2 | 5410 | 11.4 | 20.2 | Good | 7.1 | Y | Y |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 3 | 5241 | 10.9 | 23.6 | Good | 7.1 | Y | Y |  |  |  |  |  |  |
|  | Note 2:  "+" symbol after a leakage current number denotes creeping current. |  |  |  |  |  |  |  |  |  |  |  | 4 | 5161 | 202.5+ | 334+ | Good | 7 | Marg. | N |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 5 | 5154 | 990 | 3100+ | Good | 7.1 | N | N |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 6 | 5244 | 43+ | 163+ | Good | 7.7 | Marg. | N |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | Stack 4 | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 1 | 5255 | 14 | 45.6 | Good | 7.6 | Y | Y |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 2 | 5407 | 19.2 | 41.8 | Good | 7 | Y | Y |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 3 | 5253 | 21.9 | 41.7 | Good | 7 | Y | Y |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 4 | 3634 | 920 | 2700 | Good | 7 | N | N |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 5 | 5388 | 20.7 | 37 | Good | 7 | Y | Y |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | 6 | 5389 | 25 | 124.5 | Good | 7 | Y | Y |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | LER 4-4 Phase Stack SCRs removed 13+14 Sept. 2018 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 A- | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  | S1 C- | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  | S2 B- | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |
|  | 1 | 5272 | 20.7 | 50.4 | Good | 6.9 | Y | Y |  | 1 | 5658 | 6.8 | 20 | Good | 7.6 | Y | Y |  | 1 | 5316 | 8.3 | 31.2 | Good | 7.1 | Y | Y |
|  | 2 | 5292 | 31 | 221.3 | Good | 6.9 | Y | Y |  | 2 | 5657 | 8.5 | 34.2 | Good | 7.5 | Y | Y |  | 2 | 5317 | 5.9 | 11.6 | Good | 7.3 | Y | Y |
|  | 3 | 5297 | 7 | 26.1 | Good | 6.9 | Y | Y |  | 3 | 5678 | 6.1 | 19.7 | Good | 7.7 | Y | Y |  | 3 | 5315 | 8.4 | 17.4 | Good | 7 | Y | Y |
|  | 4 | 5271 | 39+ | 116+ | Good | 7 | Marg. | N |  | 4 | 5680 | 8.8 | 48.3 | Good | 7.5 | Y | Y |  | 4 | 5339 | 5.3 | 16.2 | Good | 7 | Y | Y |
|  | 5 | 5301 | 32.8+ | 208+ | Good | 7 | Marg. | N |  | 5 | 5656 | 16.2 | 67.4 | Good | 7.6 | Y | Y |  | 5 | 5338 | 7.9 | 16.2 | Good | 7.1 | Y | Y |
|  | 6 | 5293 | 27.4 | 78.8 | Good | 6.85 | Marg. | N |  | 6 | 5681 | 5.5 | 11 | Good | 7.65 | Y | Y |  | 6 | 5337 | 6.2 | 15.7 | Good | 7.1 | Y | Y |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 A+ | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  | S1 C+ | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  | S2 B+ | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |
|  | 1 | 5249 | 4.7 | 9.8 | Good | 7 | Y | Y |  | 1 | 5341 | 6.5 | 16.3 | Good | 7 | Y | Y |  | 1 | 5275 | 4.5 | 8.1 | Good | 7.2 | Y | Y |
|  | 2 | 5186 | 6.4 | 14.1 | Good | 6.9 | Y | Y |  | 2 | 5273 | 89.5 | 878 | Good | 7 | Marg. | N |  | 2 | 5294 | 49.3+ | 800+ | Good | 7 | Marg. | N |
|  | 3 | 5296 | 6.8 | 17.5 | Good | 6.9 | Y | Y |  | 3 | 5279 | 28.6 | 41.1 | Good | 7 | Marg. | N |  | 3 | 5268 | 16.1 | 31.2 | Good | 6.9 | Y | Y |
|  | 4 | 5280 | 24.9 | 36.5 | Good | 6.9 | Marg. | N |  | 4 | 5340 | 7.1 | 17.6 | Good | 7.2 | Y | Y |  | 4 | 5267 | 21.4 | 44 | Good | 6.9 | Y | Y |
|  | 5 | 5284 | 70+ | 1048 | Good | 6.8 | Marg. | N |  | 5 | 5342 | 4.9 | 9.7 | Good | 6.95 | Y | Y |  | 5 | 5290 | 4.5 | 13 | Good | 6.9 | Y | Y |
|  | 6 | 5299 | 16.9 | 36.7 | Good | 7 | Y | Y |  | 6 | 5343 | 4.4 | 8.8 | Good | 6.9 | Y | Y |  | 6 | 5298 | 13.1 | 23.3 | Good | 7.1 | Y | Y |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 B- | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  | S2 A- | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  | S2 C- | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |
|  | 1 | 5239 | 6.1 | 24.2 | Good | 7.6 | Y | Y |  | 1 | 5385 | 10.8 | 40.6 | Good | 6.9 | Y | Y |  | 1 | 5307 | 11.4 | 32 | Good | 7 | Y | Y |
|  | 2 | 5304 | 7 | 16 | Good | 7 | Y | Y |  | 2 | 5384 | 9.5 | 46.2 | Good | 6.9 | Y | Y |  | 2 | 5308 | 10 | 19.4 | Good | 7 | Y | Y |
|  | 3 | 5269 | 25.8 | 106.5 | Good | 6.9 | Y | Y |  | 3 | 5383 | 8.8 | 30 | Good | 6.9 | Y | Y |  | 3 | 5309 | 11.4 | 31.2 | Good | 7.1 | Y | Y |
|  | 4 | 5234 | 8.8 | 14.1 | Good | 7.6 | Y | Y |  | 4 | 5382 | 4.9 | 9.8 | Good | 7 | Y | Y |  | 4 | 5310 | 18 | 32.2 | Good | 7.2 | Y | Y |
|  | 5 | 5281 | 19 | 29.2 | Good | 6.85 | Y | Y |  | 5 | 5336 | 6.4 | 20.3 | Good | 7.3 | Y | Y |  | 5 | 5667 | 11 | 34.8 | Good | 7 | Y | Y |
|  | 6 | 5240 | 8.4 | 13.3 | Good | 7.2 | Y | Y |  | 6 | 5659 | 5.1 | 11 | Good | 7.6 | Marg | N |  | 6 | 5668 | 5 | 9.7 | Good | 7.5 | Y | Y |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 B+ | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  | S2 A+ | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |  | S2 C+ | S/N | I @ 4.2 KV | I @ 6.5 KV | F.O. | S. F. KV | Pass? | Re-Use? |
|  | 1 | 5289 | 5 | 10.6 | Good | 7 | Y | Y |  | 1 | 5424 | 7.2 | 18.1 | Good | 7 | Y | Y |  | 1 | 5238 | 4 | 9.6 | Good | 7 | Y | Y |
|  | 2 | 5236 | 5.6 | 11 | Good | 7.65 | Y | Y |  | 2 | 5424 | 8.8 | 17.2 | Good | 7.4 | Y | Y |  | 2 | 5266 | 6.6 | 13.3 | Good | 7.1 | Y | Y |
|  | 3 | 5306 | 132.2 | 2000 | Good | 7 | Marg. | N |  | 3 | 5425 | 13.5 | 41.7 | Good | 7.35 | Y | Y |  | 3 | 5295 | 31.7 | 98 | Good | 7 | Y | Y |
|  | 4 | 5274 | 10.2 | 20 | Good | 7 | Y | Y |  | 4 | 5426 | 18.8 | 49 | Good | 7.2 | Y | Y |  | 4 | 5288 | 20 | 145 | Good | 7.6 | Y | Y |
|  | 5 | 5278 | 14.3 | 21.8 | Good | 6.8 | Marg. | N |  | 5 | 5264 | 112.2 | 978 | Good | 7 | Marg. | N |  | 5 | 5258 | 13.9 | 47.5 | Good | 7.1 | Y | Y |
|  | 6 | 5303 | 9.9 | 24.3 | Good | 7 | Y | Y |  | 6 | 5270 | 6.2 | 16.7 | Good | 7 | Y | Y |  | 6 | 5283 | 6.3 | 13.3 | Good | 6.85 | Y | Y |


## Sheet: Sheet11

| New Spare Crowbar Stack Sets for Spear 1+2. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| SCRs are from LER 4-4 which were removed 14 Sept. 2018 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Set 1 | Date:  Oct 2, 2018 |  |  |  |  |  |  | Set 2 | Date:  Oct 6, 2018 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 1 | SCR S/N | Stack Leakage @ 25 KVDC | Fiber Optic Trig Test | SF KV | Pass/Fail |  |  | Stack 1 | SCR S/N | Stack Leakage @ 25 KVDC | Fiber Optic Trig Test | SF KV | Pass/Fail |  |
|  | Cell 1 | 5389 |  |  |  |  |  |  | Cell 1 | 5289 |  |  |  |  |  |
|  | Cell 2 | 5281 |  |  |  |  |  |  | Cell 2 | 5270 |  |  |  |  |  |
|  | Cell 3 | 5311 | .850 mA | Good | 40.56 | Pass |  |  | Cell 3 | 5424 | .841 mA | Good | 40.05 | Pass |  |
|  | Cell 4 | 2335 |  |  |  |  |  |  | Cell 4 | 5336 |  |  |  |  |  |
|  | Cell 5 | 5240 |  |  |  |  |  |  | Cell 5 | 5385 |  |  |  |  |  |
|  | Cell 6 | 5304 |  |  |  |  |  |  | Cell 6 | 5383 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 2 |  |  |  |  |  |  |  | Stack 2 |  |  |  |  |  |  |
|  | Cell 1 | 5307 |  |  |  |  |  |  | Cell 1 | 5343 |  |  |  |  |  |
|  | Cell 2 | 5393 |  |  |  |  |  |  | Cell 2 | 5186 |  |  |  |  |  |
|  | Cell 3 | 5288 | .855 mA | Good | 41.07 | Pass |  |  | Cell 3 | 5317 | .836 mA | Good | 40.04 | Pass |  |
|  | Cell 4 | 2503 |  |  |  |  |  |  | Cell 4 | 5303 |  |  |  |  |  |
|  | Cell 5 | 2511 |  |  |  |  |  |  | Cell 5 | 5337 |  |  |  |  |  |
|  | Cell 6 | 5309 |  |  |  |  |  |  | Cell 6 | 5382 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 3 |  |  |  |  |  |  |  | Stack 3 |  |  |  |  |  |  |
|  | Cell 1 | 5283 |  |  |  |  |  |  | Cell 1 | 5290 |  |  |  |  |  |
|  | Cell 2 | 5330 |  |  |  |  |  |  | Cell 2 | 5297 |  |  |  |  |  |
|  | Cell 3 | 5295 | .857 mA | Good | 41.08 | Pass |  |  | Cell 3 | 5423 | .837 mA | Good | 40 | Pass |  |
|  | Cell 4 | 5238 |  |  |  |  |  |  | Cell 4 | 5384 |  |  |  |  |  |
|  | Cell 5 | 5269 |  |  |  |  |  |  | Cell 5 | 5236 |  |  |  |  |  |
|  | Cell 6 | 5255 |  |  |  |  |  |  | Cell 6 | 5249 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 4 |  |  |  |  |  |  |  | Stack 4 |  |  |  |  |  |  |
|  | Cell 1 | 5314 |  |  |  |  |  |  | Cell 1 | 5339 |  |  |  |  |  |
|  | Cell 2 | 5392 |  |  |  |  |  |  | Cell 2 | 5296 |  |  |  |  |  |
|  | Cell 3 | 5331 | .856 mA | Good | 41.21 | Pass |  |  | Cell 3 | 5341 | .836 mA | Good | 40.34 | Pass |  |
|  | Cell 4 | 5407 |  |  |  |  |  |  | Cell 4 | 5340 |  |  |  |  |  |
|  | Cell 5 | 2510 |  |  |  |  |  |  | Cell 5 | 5275 |  |  |  |  |  |
|  | Cell 6 | 5239 |  |  |  |  |  |  | Cell 6 | 5342 |  |  |  |  |  |


## Sheet: Sheet12

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | Spear 2 RF HVPS Individual SCR Tests |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Crowbar Stacks removed from Spear 1 on 26 Feb, 2019 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  | Cold Tests @ 22 deg. C |  |  |  |  |  |  |  |  |  |  |  | Hot Tests @ approx. 50 deg. C |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 1 | SCR # | Serial # | Date Code | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  |  | Stack 1 | SCR # | Serial # | Date Code | uA @ 4.2 KV | uA @ 6.5KV | AnodeTemp |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 1 | 3506 | 20S4 | 20.8 | 33.94 | G | 7.32 | Y |  |  |  |  | 1 | 3506 | 20S4 | 133.7+ | 226.5+ | 50.35 |
|  |  | 2 | 3006 | 02S4 | 13.6 | 26.2 | G | 7.24 | Y |  |  |  |  | 2 | 3006 | 02S4 | 220.5+ | 375+ | 50.75 |
|  |  | 3 | 3205 | 02S4 | 34 | 65 | G | 7.2 | Y |  |  |  |  | 3 | 3205 | 02S4 | 319+ | 586+ | 51.25 |
|  |  | 4 | 3290 | 25S5 | 28.4 | 68.4 | G | 7.4 | Y |  |  |  |  | 4 | 3290 | 25S5 | 146.5+ | 322.2+ | 51.3 |
|  |  | 5 | 3170 | 02S4 | 3.1 | 5.1 | G | 7.12 | Y |  |  |  |  | 5 | 3170 | 02S4 | 52.1+ | 101.1+ | 51.8 |
|  |  | 6 | 3209 | 02S4 | 38.1 | 73.3 | G | 7.84 | Y |  |  |  |  | 6 | 3209 | 02S4 | 344+ | 609+ | 50.55 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 2 | SCR # | Serial # |  | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  |  | Stack 2 | SCR # | Serial # |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 1 | 2502 | 24R3 | 13.6 | 27.9 | G | 7.1 | Y |  |  |  |  | 1 | 2502 | 24R3 | 91.2+ | 182.6+ | 51.5 |
|  |  | 2 | 3507 | 25S5 | 24.7 | 41 | G | 7.2 | Y |  |  |  |  | 2 | 3507 | 25S5 | 122.2+ | 273.6+ | 50.55 |
|  |  | 3 | 3187 | 02S4 | 12.3 | 23.3 | G | 8.2 | Y |  |  |  |  | 3 | 3187 | 02S4 | 153.6+ | 287.9+ | 50.75 |
|  |  | 4 | 2509 | 24R3 | 5.8 | 10.5 | G | 7.1 | Y |  |  |  |  | 4 | 2509 | 24R3 | 58.8+ | 115.2+ | 50.05 |
|  |  | 5 | 2492 | 24R3 | 42.1 | 84.2 | G | 8.1 | Y |  |  |  |  | 5 | 2492 | 24R3 | 205.5+ | 395.2+ | 51.5 |
|  |  | 6 | 2508 | 24R3 | 5.2 | 10.8 | G | 7 | Y |  |  |  |  | 6 | 2508 | 24R3 | 105.1+ | 440.6+ | 50.05 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 3 | SCR # | Serial # |  | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  |  | Stack 3 | SCR # | Serial # |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 1 | 5718 | 06U2 | 25.1 | 138.5 | G | 7.2 | Y |  |  |  |  | 1 | 5718 | 06U2 | 63.9+ | 128.4+ | 50.3 |
|  |  | 2 | 2351 | 08U2 | 6.5 | 11.8 | G | 8.24 | Y |  |  |  |  | 2 | 2351 | 08U2 | 551+ | 1015+ | 50.25 |
|  |  | 3 | 5685 | 18R2 | 162+ | 219+ | G | 6.92 | N |  |  |  |  | 3 | 5685 | 18R2 | 641+ | 1104+ | 50.3 |
|  |  | 4 | 5637 | 06U2 | 36 | 104 | G | 7.64 | Y |  |  |  |  | 4 | 5637 | 06U2 | 259.1+ | 548+ | 49.95 |
|  |  | 5 | 5670 | 06U2 | 65+ | Shorted | G | 7.6 | N |  |  |  |  | 5 | 5670 | 06U2 | N/A | N/A |  |
|  |  | 6 | 5650 | 06U2 | 5.1 | 9.2 | G | 7.68 | Y |  |  |  |  | 6 | 5650 | 06U2 | 45.5+ | Shorted | 50.45 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack 4 | SCR # | Serial # |  | uA @ 4.2 KV | uA @ 6.5KV | F.O. Trigs | OV Self-Fire | Re-Use? |  |  |  | Stack 4 | SCR # | Serial # |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 1 | 3015 | 02S4 | 86 | 153 | G | 7.12 | Y |  |  |  |  | 1 | 3015 | 02S4 | 464.4+ | 895+ | 50.25 |
|  |  | 2 | 3230 | 02S4 | 16 | 40 | G | 7.08 | Y |  |  |  |  | 2 | 3230 | 02S4 | 218.1+ | 371.2+ | 50.6 |
|  |  | 3 | 3233 | 02S4 | 192+ | 1402+ | G | 7.12 | N |  |  |  |  | 3 | 3233 | 02S4 | 985+ | 1985+ | 50.2 |
|  |  | 4 | 3203 | 02S4 | 68 | 115 | G | 7.08 | Y |  |  |  |  | 4 | 3203 | 02S4 | 359.5+ | 757+ | 50.5 |
|  |  | 5 | 3204 | 02S4 | 70 | 108 | G | 7 | Y |  |  |  |  | 5 | 3204 | 02S4 | 607+ | 1139+ | 51.3 |
|  |  | 6 | 3232 | 02S4 | 51.4 | 117 | G | 7.2 | Y |  |  |  |  | 6 | 3232 | 02S4 | 280.5+ | 651+ | 50.6 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Note:  " + " symbol after a leakage current # = current creeping upwards. |  |  |  |  |  |  |  |  |  |  |  | Note:  " + " symbol after a leakage current # = current creeping upwards. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | Anode temperature probe located on top of anode casing. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Overall Conclusions: |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | 1 device (Stack 3, #5 shorted when testing over-volts self-fire (no triggers) during "cold test" @ room temp.  1 device (Stack 3 #6) shorted when testing over-volts self-fire (no triggers) during "hot test" @ 50.4 deg. C. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Stack 3 had 3 devices that were marginal during ops.  All 4 stacks lasted for approx. 4.5 years running every 6 months.  Stack 4 had 1 device (cold) that has high leakage current.  Consider that device marginal.    All 4 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | stacks were good in the cold tests, although I don't know if stack 3 would have run very much longer with 3 marginal devices.  Leakage currents during "hot" tests @ 50 deg. C climbed considerably.  Also, the rate of current climb increased during higher temperature tests. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Don't know how these stacks were affected during HV ops in the crowbar tank @ 50 deg. C.  We may want to consider going to a higher wattage, lower resistance voltage balancing resistor across each SCR.  The current resistor is a 5 meg ohm, 5 watt 10 KV resistor. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Keep in mind, the heat used to get the device anode to 50 deg. C under HV is directly blown onto device via regulated heat gun.  A stack sitting in temperature regulated oil and constantly under HV may be affected differently. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | I am going to discontinue testing the self-firing feature in these devices.  The 2 shorted devices were working fine until I self-fired them by over-voltage.  Most devices work fine with this test, but occasionally get some that fail at first self-trigger. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet13

| Spear 3 RF HVPS:  conventional phase stack SCR inventory and testing. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  | Wednesday, July 17, 2019 thru July |  |  |  |  |  |  |  |  |  |  |  |  |
| Order = SLAC PO #193884, Powerex PO #523726 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Quantity:  200 SCRs, Powerex part # T8K7383503DHAJQ |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | All measurements made between 22-29 deg. C. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  | 3700 Volt Test | in Milliamps |  |  |  |  |
| SCR # | Date Code | Batch # | Serial # | I @ 1KV | I @ 2KV | I @ 2.5 KV |  |  |  |  |  |  |  |  |  |
|  |  |  |  | uA | uA | uA |  |  |  |  |  |  |  |  |  |
| 1 | 1925 | 333870 | 163 | 4.1 | 5.3 | 6 |  |  |  |  |  |  |  |  |  |
| 2 | 1925 | 333870 | 225 | 2.9 | 4.9 | 17.6 |  |  |  |  |  |  |  |  |  |
| 3 | 1925 | 333870 | 183 | 8.8 | 12.2 | 13.9 |  |  |  |  |  |  |  |  |  |
| 4 | 1925 | 333870 | 174 | 3.5 | 4.5 | 5 |  |  |  |  |  |  |  |  |  |
| 5 | 1925 | 333870 | 168 | 2.5 | 10.3 | 28.3 |  |  |  |  |  |  |  |  |  |
| 6 | 1925 | 333870 | 186 | 2.1 | 3.1 | 3.5 |  |  |  |  |  |  |  |  |  |
| 7 | 1925 | 333870 | 204 | 2.4 | 3.7 | 4.5 |  |  |  |  |  |  |  |  |  |
| 8 | 1925 | 333870 | 202 | 3.4 | 5 | 5.6 |  |  |  |  |  |  |  |  |  |
| 9 | 1925 | 333870 | 166 | 3.6 | 5.3 | 6.1 |  |  |  |  |  |  |  |  |  |
| 10 | 1925 | 333870 | 002 | 3 | 4.1 | 4.6 |  |  |  |  |  |  |  |  |  |
| 11 | 1925 | 333870 | 228 | 2.7 | 3.8 | 4.8 |  |  |  |  |  |  |  |  |  |
| 12 | 1925 | 333870 | 184 | 2.2 | 3.1 | 3.4 |  |  |  |  |  |  |  |  |  |
| 13 | 1925 | 333870 | 034 | 2.1 | 3 | 3.3 |  |  |  |  |  |  |  |  |  |
| 14 | 1925 | 333870 | 027 | 2.5 | 3.3 | 3.9 |  |  |  |  |  |  |  |  |  |
| 15 | 1925 | 333870 | 171 | 1.9 | 2.7 | 3.1 |  |  |  |  |  |  |  |  |  |
| 16 | 1925 | 333870 | 226 | 2.4 | 3.2 | 3.8 |  |  |  |  |  |  |  |  |  |
| 17 | 1925 | 333870 | 194 | 2.8 | 10.6 | 68.4 |  |  |  |  |  |  |  |  |  |
| 18 | 1925 | 333870 | 198 | 3.6 | 4.9 | 5.4 |  |  |  |  |  |  |  |  |  |
| 19 | 1925 | 333870 | 173 | 3.6 | 5 | 5.6 |  |  |  |  |  |  |  |  |  |
| 20 | 1925 | 333870 | 017 | 5.8 | 12.7 | 16.3 |  |  |  |  |  |  |  |  |  |
| 21 | 1925 | 333870 | 019 | 2.7 | 5 | 6.9 |  |  |  |  |  |  |  |  |  |
| 22 | 1925 | 333870 | 208 | 2.8 | 3.9 | 4.4 |  |  |  |  |  |  |  |  |  |
| 23 | 1925 | 333870 | 015 | 4.6 | 9.5 | 11.7 |  |  |  |  |  |  |  |  |  |
| 24 | 1925 | 333870 | 199 | 2.7 | 3.6 | 4.3 |  |  |  |  |  |  |  |  |  |
| 25 | 1925 | 333870 | 007 | 3.2 | 4.6 | 5.3 |  |  |  |  |  |  |  |  |  |
| 26 | 1925 | 333870 | 021 | 3.8 | 4.8 | 5.6 |  |  |  |  |  |  |  |  |  |
| 27 | 1925 | 333870 | 159 | 3.5 | 5 | 5.7 |  |  |  | 3700 Volts |  |  |  |  |  |
| 28 | 1925 | 333870 | 200 | 2.9 | 3.8 | 4.4 |  |  |  |  |  |  |  |  |  |
| 29 | 1925 | 333870 | 195 | 2.5 | 3.3 | 3.9 |  |  |  |  |  |  |  |  |  |
| 30 | 1925 | 333870 | 022 | 3.4 | 4.6 | 5.1 |  |  |  |  |  |  |  |  |  |
| 31 | 1925 | 333870 | 024 | 4.4 | 7.9 | 9.8 | 1 min | 15 min | 30 min | 45 min | 1 hr | 1.5 hr | 2.0 hr | 2.5 hr |  |
| 32 | 1925 | 333870 | 036 | 73.7 | 194.2 | 298+ | 0.832 | 0.941 | 1.03 | 1.027 | 1.025 | 1.05 | 1.089 | 1.115 |  |
| 33 | 1925 | 333870 | 185 | 4.3 | 9.1 | 12.5 | 1 min | 15 min | 30 min | 45 min | 1 hr | 1.5 hr | 2.0 hr | 2.5 hr |  |
| 34 | 1925 | 333870 | 013 | 2.8 | 137.6 | 533+ | 1.425 | 1.336 | 1.328 | 1.306 | 1.3 | 1.353 | 1.351 | 1.366 |  |
| 35 | 1925 | 333870 | 201 | 4 | 5.3 | 6.3 |  |  |  |  |  |  |  |  |  |
| 36 | 1925 | 333870 | 207 | 2.8 | 3.8 | 4.5 |  |  |  |  |  |  |  |  |  |
| 37 | 1925 | 333870 | 011 | 3.6 | 6 | 7.5 |  |  |  |  |  |  |  |  |  |
| 38 | 1925 | 333870 | 003 | 3.4 | 4.1 | 4.6 |  |  |  |  |  |  |  |  |  |
| 39 | 1925 | 333870 | 087 | 3.6 | 4.9 | 5.4 |  |  |  | 3700 Volts |  |  |  |  |  |
| 40 | 1925 | 333870 | 078 | 4.8 | 6.5 | 7.3 |  |  |  |  |  |  |  |  |  |
| 41 | 1925 | 333870 | 176 | 2.8 | 3.8 | 4.4 | 1 min | 15 min | 30 min | 45 min | 1 hr | 1.5 hr | 2.0 hr | 2.5 hr |  |
| 42 | 1925 | 333870 | 075 | 41.9+ | 538+ | 766+ | 1.88 | 2.32 | 2.34 | 2.278 | 2.191 | 2.187 | 2.22 | 2.267 |  |
| 43 | 1925 | 333870 | 160 | 3.6 | 10.6 | 14.4 |  |  |  |  |  |  |  |  |  |
| 44 | 1925 | 333870 | 206 | 3.5 | 5.3 | 6.1 |  |  |  |  |  |  |  |  |  |
| 45 | 1925 | 333870 | 094 | 20.9 | 36.8 | 46.9 |  |  |  |  |  |  |  |  |  |
| 46 | 1925 | 333870 | 060 | 3.2 | 5.2 | 6.5 |  |  |  |  |  |  |  |  |  |
| 47 | 1925 | 333870 | 172 | 3.2 | 4.3 | 4.9 |  |  |  |  |  |  |  |  |  |
| 48 | 1925 | 333870 | 211 | 2.7 | 3.4 | 3.9 |  |  |  |  |  |  |  |  |  |
| 49 | 1925 | 333870 | 014 | 4.7 | 6.7 | 7.8 |  |  |  |  |  |  |  |  |  |
| 50 | 1925 | 333870 | 018 | 3.4 | 5.2 | 17.6 |  |  |  |  |  |  |  |  |  |
| 51 | 1925 | 333870 | 177 | 2.6 | 3.6 | 4.2 |  |  |  |  |  |  |  |  |  |
| 52 | 1925 | 333870 | 077 | 8.6 | 16.7 | 24.6 |  |  |  |  |  |  |  |  |  |
| 53 | 1925 | 333870 | 076 | 4.3 | 5.7 | 6.4 |  |  |  |  |  |  |  |  |  |
| 54 | 1925 | 333870 | 175 | 3.5 | 4.8 | 5.7 |  |  |  |  |  |  |  |  |  |
| 55 | 1925 | 333870 | 179 | 3.1 | 4.2 | 4.8 |  |  |  |  |  |  |  |  |  |
| 56 | 1925 | 333870 | 065 | 2.8 | 3.8 | 4.3 |  |  |  |  |  |  |  |  |  |
| 57 | 1925 | 333870 | 108 | 4.2 | 5.4 | 5.9 |  |  |  |  |  |  |  |  |  |
| 58 | 1925 | 333870 | 016 | 2.7 | 4 | 4.6 |  |  |  |  |  |  |  |  |  |
| 59 | 1925 | 333870 | 161 | 4.1 | 6 | 7.1 |  |  |  |  |  |  |  |  |  |
| 60 | 1925 | 333870 | 080 | 4.5 | 6.2 | 7.3 |  |  |  |  |  |  |  |  |  |
| 61 | 1925 | 333870 | 222 | 5.1 | 6.6 | 7.3 |  |  |  |  |  |  |  |  |  |
| 62 | 1925 | 333870 | 079 | 3.5 | 4.8 | 5.3 |  |  |  |  |  |  |  |  |  |
| 63 | 1925 | 333870 | 020 | 3.7 | 5 | 5.7 |  |  |  |  |  |  |  |  |  |
| 64 | 1925 | 333870 | 170 | 2.3 | 5.2 | 6.5 |  |  |  |  |  |  |  |  |  |
| 65 | 1925 | 333870 | 178 | 8 | 12.5 | 14.7 |  |  |  |  |  |  |  |  |  |
| 66 | 1925 | 333870 | 219 | 5.1 | 6.9 | 7.8 |  |  |  |  |  |  |  |  |  |
| 67 | 1925 | 333870 | 081 | 3.5 | 5.2 | 6.1 |  |  |  |  |  |  |  |  |  |
| 68 | 1925 | 333870 | 205 | 4.6 | 6.2 | 7 |  |  |  |  |  |  |  |  |  |
| 69 | 1925 | 333870 | 025 | 4.7 | 6.5 | 7.2 |  |  |  |  |  |  |  |  |  |
| 70 | 1925 | 333870 | 164 | 4 | 5.5 | 6.3 |  |  |  |  |  |  |  |  |  |
| 71 | 1925 | 333870 | 101 | 4.3 | 6.5 | 7.4 |  |  |  |  |  |  |  |  |  |
| 72 | 1925 | 333870 | 213 | 2.3 | 2.9 | 3.3 |  |  |  |  |  |  |  |  |  |
| 73 | 1925 | 333870 | 093 | 2.7 | 3.9 | 4.7 |  |  |  |  |  |  |  |  |  |
| 74 | 1925 | 333870 | 134 | 2.6 | 3.9 | 4.4 |  |  |  |  |  |  |  |  |  |
| 75 | 1925 | 333870 | 136 | 2.8 | 3.7 | 4.2 |  |  |  |  |  |  |  |  |  |
| 76 | 1925 | 333870 | 061 | 2.8 | 4.7 | 5.4 |  |  |  |  |  |  |  |  |  |
| 77 | 1925 | 333870 | 190 | 2.7 | 3.8 | 4.2 |  |  |  |  |  |  |  |  |  |
| 78 | 1925 | 333870 | 140 | 3.4 | 4.8 | 5.8 |  |  |  |  |  |  |  |  |  |
| 79 | 1925 | 333870 | 064 | 2.6 | 3.6 | 4 |  |  |  |  |  |  |  |  |  |
| 80 | 1925 | 333870 | 203 | 3 | 5.2 | 6.6 |  |  |  |  |  |  |  |  |  |
| 81 | 1925 | 333870 | 143 | 3 | 3.9 | 4.5 |  |  |  |  |  |  |  |  |  |
| 82 | 1925 | 333870 | 089 | 3.2 | 4.3 | 4.7 |  |  |  |  |  |  |  |  |  |
| 83 | 1925 | 333870 | 042 | 3.5 | 5 | 6 |  |  |  |  |  |  |  |  |  |
| 84 | 1925 | 333870 | 095 | 2.5 | 3.4 | 3.9 |  |  |  |  |  |  |  |  |  |
| 85 | 1925 | 333870 | 006 | 3.4 | 4.4 | 4.8 |  |  |  |  |  |  |  |  |  |
| 86 | 1925 | 333870 | 055 | 3 | 6 | 9.1 |  |  |  |  |  |  |  |  |  |
| 87 | 1925 | 333870 | 084 | 2.6 | 4 | 4.9 |  |  |  |  |  |  |  |  |  |
| 88 | 1925 | 333870 | 137 | 3.1 | 4.5 | 5.3 |  |  |  |  |  |  |  |  |  |
| 89 | 1925 | 333870 | 069 | 3.3 | 4.6 | 5.3 |  |  |  |  |  |  |  |  |  |
| 90 | 1925 | 333870 | 141 | 2.3 | 3.4 | 4 |  |  |  |  |  |  |  |  |  |
| 91 | 1925 | 333870 | 191 | 3.9 | 5.1 | 5.7 |  |  |  |  |  |  |  |  |  |
| 92 | 1925 | 333870 | 071 | 2.7 | 3.7 | 4.2 |  |  |  | 3700 Volts |  |  |  |  |  |
| 93 | 1925 | 333870 | 165 | 3.2 | 6 | 8.1 |  |  |  |  |  |  |  |  |  |
| 94 | 1925 | 333870 | 046 | 2.4 | 3.4 | 3.9 | 1 min | 15 min | 30 min | 45 min | 1 hr | 1.5 hr | 2.0 hr | 2.5 hr |  |
| 95 | 1925 | 333870 | 072 | 3.7 | 25.3 | 337+ | 1.004 | 1.216 | 1.249 | 1.283 | 1.265 | 1.29 | 1.3 | 1.297 |  |
| 96 | 1925 | 333870 | 040 | 3.2 | 4.3 | 4.9 |  |  |  |  |  |  |  |  |  |
| 97 | 1925 | 333870 | 001 | 5.5 | 7.5 | 8.5 |  |  |  | 3700 Volts |  |  |  |  |  |
| 98 | 1925 | 333870 | 144 | 3.4 | 7.2 | 59.6 |  |  |  |  |  |  |  |  |  |
| 99 | 1925 | 333870 | 218 | 2.3 | 3.3 | 3.8 | 1 min | 15 min | 30 min | 45 min | 1 hr | 1.5 hr | 2.0 hr | 2.5 hr |  |
| 100 | 1925 | 333870 | 224 | 3.6 | 171.2+ | 960+ | 3.76 | 3.65 | 3.52 | 3.44 | 3.41 | 3.43 | 3.37 | 3.33 |  |
| 101 | 1925 | 333870 | 058 | 4.3 | 7.4 | 9.2 |  |  |  |  |  |  |  |  |  |
| 102 | 1925 | 333870 | 126 | 4.1 | 5.7 | 6.5 |  |  |  |  |  |  |  |  |  |
| 103 | 1925 | 333870 | 217 | 3.5 | 5.1 | 7.2 |  |  |  |  |  |  |  |  |  |
| 104 | 1925 | 333870 | 142 | 3.7 | 5.1 | 5.9 |  |  |  |  |  |  |  |  |  |
| 105 | 1925 | 333870 | 154 | 10.1 | 13.7 | 15.4 |  |  |  |  |  |  |  |  |  |
| 106 | 1925 | 333870 | 046 | 6.1 | 8.8 | 10.1 |  |  |  |  |  |  |  |  |  |
| 107 | 1925 | 333870 | 149 | 3.4 | 4.8 | 5.6 |  |  |  |  |  |  |  |  |  |
| 108 | 1925 | 333870 | 074 | 3.1 | 4.3 | 4.9 |  |  |  |  |  |  |  |  |  |
| 109 | 1925 | 333870 | 146 | 3.7 | 5 | 5.7 |  |  |  |  |  |  |  |  |  |
| 110 | 1925 | 333870 | 130 | 3.2 | 4.3 | 4.9 |  |  |  |  |  |  |  |  |  |
| 111 | 1925 | 333870 | 026 | 3.5 | 4.7 | 5.2 |  |  |  |  |  |  |  |  |  |
| 112 | 1925 | 333870 | 039 | 23 | 36.6 | 44.4 |  |  |  |  |  |  |  |  |  |
| 113 | 1925 | 333870 | 151 | 5.4 | 7.4 | 8.5 |  |  |  |  |  |  |  |  |  |
| 114 | 1925 | 333870 | 082 | 2.9 | 4.1 | 4.8 |  |  |  |  |  |  |  |  |  |
| 115 | 1925 | 333870 | 008 | 5.2 | 7 | 7.9 |  |  |  |  |  |  |  |  |  |
| 116 | 1925 | 333870 | 070 | 4.3 | 5.8 | 6.6 |  |  |  |  |  |  |  |  |  |
| 117 | 1925 | 333870 | 169 | 6.1 | 9.1 | 10.9 |  |  |  |  |  |  |  |  |  |
| 118 | 1925 | 333870 | 083 | 3.3 | 6.7 | 22.7 |  |  |  |  |  |  |  |  |  |
| 119 | 1925 | 333870 | 028 | 5.8 | 10.6 | 11.9 |  |  |  |  |  |  |  |  |  |
| 120 | 1925 | 333870 | 187 | 3.6 | 5.1 | 5.8 |  |  |  |  |  |  |  |  |  |
| 121 | 1925 | 333870 | 167 | 4.7 | 7.2 | 9.6 |  |  |  |  |  |  |  |  |  |
| 122 | 1925 | 333870 | 215 | 4.5 | 6 | 7.2 |  |  |  |  |  |  |  |  |  |
| 123 | 1925 | 333870 | 145 | 4.1 | 5.6 | 6.4 |  |  |  |  |  |  |  |  |  |
| 124 | 1925 | 333870 | 223 | 3.2 | 4.4 | 5 |  |  |  |  |  |  |  |  |  |
| 125 | 1925 | 333870 | 012 | 4.6 | 5.6 | 6.4 |  |  |  |  |  |  |  |  |  |
| 126 | 1925 | 333870 | 031 | 3.2 | 4.2 | 4.7 |  |  |  |  |  |  |  |  |  |
| 127 | 1925 | 333870 | 009 | 1.9 | 2.8 | 35 |  |  |  |  |  |  |  |  |  |
| 128 | 1925 | 333870 | 035 | 4 | 6.6 | 9.3 |  |  |  |  |  |  |  |  |  |
| 129 | 1925 | 333870 | 212 | 3.1 | 4.2 | 4.7 |  |  |  |  |  |  |  |  |  |
| 130 | 1925 | 333870 | 068 | 3.6 | 4.8 | 5.5 |  |  |  |  |  |  |  |  |  |
| 131 | 1925 | 333870 | 188 | 3.1 | 4.2 | 4.8 |  |  |  | 3700 Volts |  |  |  |  |  |
| 132 | 1925 | 333870 | 193 | 3.2 | 4.5 | 5.3 |  |  |  |  |  |  |  |  |  |
| 133 | 1925 | 333870 | 197 | 3.5 | 4.7 | 5.4 | 1 min | 15 min | 30 min | 45 min | 1 hr | 1.5 hr | 2.0 hr | 2.5 hr |  |
| 134 | 1925 | 333870 | 209 | 3.2 | 7.3 | 694+ | 3.494 | 3.361 | 3.355 | 3.164 | 3.148 | 3.162 | 3.18 | 3.178 |  |
| 135 | 1925 | 333870 | 192 | 3.2 | 4.3 | 5 |  |  |  |  |  |  |  |  |  |
| 136 | 1925 | 333870 | 139 | 2.9 | 4.5 | 5.5 |  |  |  |  |  |  |  |  |  |
| 137 | 1925 | 333870 | 059 | 4.3 | 6.1 | 6.9 |  |  |  |  |  |  |  |  |  |
| 138 | 1925 | 333870 | 004 | 4.4 | 7 | 8.5 |  |  |  |  |  |  |  |  |  |
| 139 | 1925 | 333870 | 120 | 2.3 | 3.3 | 3.8 |  |  |  |  |  |  |  |  |  |
| 140 | 1925 | 333870 | 220 | 2.2 | 3.3 | 3.8 |  |  |  |  |  |  |  |  |  |
| 141 | 1925 | 333870 | 119 | 1.6 | 2.3 | 2.8 |  |  |  |  |  |  |  |  |  |
| 142 | 1925 | 333870 | 155 | 1.8 | 2.4 | 2.7 |  |  |  |  |  |  |  |  |  |
| 143 | 1925 | 333870 | 111 | 2.3 | 3.3 | 3.7 |  |  |  |  |  |  |  |  |  |
| 144 | 1925 | 333870 | 121 | 2.9 | 4.5 | 5.4 |  |  |  |  |  |  |  |  |  |
| 145 | 1925 | 333870 | 112 | 3.4 | 5.4 | 5.9 |  |  |  |  |  |  |  |  |  |
| 146 | 1925 | 333870 | 153 | 2 | 2.8 | 3.2 |  |  |  |  |  |  |  |  |  |
| 147 | 1925 | 333870 | 157 | 2.5 | 3.4 | 3.9 |  |  |  |  |  |  |  |  |  |
| 148 | 1925 | 333870 | 117 | 3.1 | 5.3 | 6.6 |  |  |  |  |  |  |  |  |  |
| 149 | 1925 | 333870 | 156 | 2.3 | 3.2 | 3.7 |  |  |  |  |  |  |  |  |  |
| 150 | 1925 | 333870 | 216 | 2.9 | 4 | 4.7 |  |  |  |  |  |  |  |  |  |
| 151 | 1925 | 333870 | 054 | 2.4 | 3.3 | 3.7 |  |  |  |  |  |  |  |  |  |
| 152 | 1925 | 333870 | 037 | 2.2 | 3 | 3.5 |  |  |  |  |  |  |  |  |  |
| 153 | 1925 | 333870 | 138 | 1.8 | 3 | 3.6 |  |  |  |  |  |  |  |  |  |
| 154 | 1925 | 333870 | 147 | 2.6 | 4.8 | 5.8 |  |  |  |  |  |  |  |  |  |
| 155 | 1925 | 333870 | 010 | 3.4 | 4.6 | 5.2 |  |  |  |  |  |  |  |  |  |
| 156 | 1925 | 333870 | 180 | 2 | 2.7 | 3.2 |  |  |  |  |  |  |  |  |  |
| 157 | 1925 | 333870 | 032 | 2.5 | 3.3 | 3.7 |  |  |  |  |  |  |  |  |  |
| 158 | 1925 | 333870 | 005 | 7.5 | 11.5 | 13.5 |  |  |  |  |  |  |  |  |  |
| 159 | 1925 | 333870 | 088 | 2.2 | 3.2 | 3.6 |  |  |  |  |  |  |  |  |  |
| 160 | 1925 | 333870 | 181 | 1.9 | 2.8 | 3.2 |  |  |  |  |  |  |  |  |  |
| 161 | 1925 | 333870 | 033 | 2.3 | 3.2 | 3.7 |  |  |  |  |  |  |  |  |  |
| 162 | 1925 | 333870 | 196 | 2.1 | 3.1 | 3.5 |  |  |  |  |  |  |  |  |  |
| 163 | 1925 | 333870 | 023 | 3.2 | 4.4 | 5 |  |  |  |  |  |  |  |  |  |
| 164 | 1925 | 333870 | 148 | 5 | 6.7 | 7.6 |  |  |  |  |  |  |  |  |  |
| 165 | 1925 | 333870 | 085 | 2.8 | 3.6 | 4.2 |  |  |  |  |  |  |  |  |  |
| 166 | 1925 | 333870 | 057 | 2.8 | 4.1 | 4.5 |  |  |  |  |  |  |  |  |  |
| 167 | 1925 | 333870 | 029 | 2.4 | 4.4 | 5.6 |  |  |  |  |  |  |  |  |  |
| 168 | 1925 | 333870 | 189 | 9.7 | 17.8 | 23.1 |  |  |  |  |  |  |  |  |  |
| 169 | 1925 | 333870 | 210 | 2 | 2.5 | 2.8 |  |  |  |  |  |  |  |  |  |
| 170 | 1925 | 333870 | 066 | 2.5 | 3.3 | 3.8 |  |  |  |  |  |  |  |  |  |
| 171 | 1925 | 333870 | 030 | 2.8 | 5.3 | 6.6 |  |  |  |  |  |  |  |  |  |
| 172 | 1925 | 333870 | 063 | 2.9 | 7.3 | 11.3 |  |  |  |  |  |  |  |  |  |
| 173 | 1925 | 333870 | 132 | 2.4 | 3.5 | 4.1 |  |  |  |  |  |  |  |  |  |
| 174 | 1925 | 333870 | 078 | 2.8 | 3.8 | 4.3 |  |  |  |  |  |  |  |  |  |
| 175 | 1925 | 333870 | 214 | 3.9 | 5.3 | 5.8 |  |  |  |  |  |  |  |  |  |
| 176 | 1925 | 333870 | 182 | 4.3 | 5.9 | 7.2 |  |  |  |  |  |  |  |  |  |
| 177 | 1925 | 333870 | 115 | 3.9 | 8.1 | 10.9 |  |  |  |  |  |  |  |  |  |
| 178 | 1925 | 333870 | 053 | 8 | 10.4 | 11.8 |  |  |  |  |  |  |  |  |  |
| 179 | 1925 | 333870 | 150 | 11.8 | 18.1 | 128.3 |  |  |  |  |  |  |  |  |  |
| 180 | 1925 | 333870 | 221 | 5.9 | 8 | 8.9 |  |  |  |  |  |  |  |  |  |
| 181 | 1925 | 333870 | 227 | 2.8 | 3.7 | 4.1 |  |  |  |  |  |  |  |  |  |
| 182 | 1925 | 333870 | 133 | 4.7 | 7.5 | 8.7 |  |  |  |  |  |  |  |  |  |
| 183 | 1925 | 333870 | 131 | 2.6 | 3.7 | 4.7 |  |  |  |  |  |  |  |  |  |
| 184 | 1925 | 333870 | 124 | 2.7 | 3.7 | 4.2 |  |  |  |  |  |  |  |  |  |
| 185 | 1925 | 333870 | 123 | 3.1 | 3.9 | 4.4 |  |  |  |  |  |  |  |  |  |
| 186 | 1925 | 333870 | 049 | 3 | 4 | 4.5 |  |  |  |  |  |  |  |  |  |
| 187 | 1925 | 333870 | 127 | 3 | 4.2 | 4.7 |  |  |  |  |  |  |  |  |  |
| 188 | 1925 | 333870 | 129 | 3.1 | 5 | 6 |  |  |  |  |  |  |  |  |  |
| 189 | 1925 | 333870 | 125 | 4.3 | 6.5 | 7.4 |  |  |  |  |  |  |  |  |  |
| 190 | 1925 | 333870 | 128 | 3.9 | 6.2 | 7.5 |  |  |  |  |  |  |  |  |  |
| 191 | 1925 | 333870 | 122 | 4 | 5.4 | 6.1 |  |  |  |  |  |  |  |  |  |
| 192 | 1925 | 333870 | 048 | 4.7 | 6.5 | 7.2 |  |  |  |  |  |  |  |  |  |
| 193 | 1925 | 333870 | 109 | 3.5 | 4.4 | 4.8 |  |  |  |  |  |  |  |  |  |
| 194 | 1925 | 333870 | 116 | 4 | 5.3 | 6 |  |  |  |  |  |  |  |  |  |
| 195 | 1925 | 333870 | 100 | 2.7 | 3.9 | 4.5 |  |  |  |  |  |  |  |  |  |
| 196 | 1925 | 333870 | 062 | 1.9 | 3.5 | 6.8 |  |  |  |  |  |  |  |  |  |
| 197 | 1925 | 333870 | 118 | 3.8 | 6.7 | 7.9 |  |  |  |  |  |  |  |  |  |
| 198 | 1925 | 333870 | 052 | 5.3 | 6.7 | 7.3 |  |  |  |  |  |  |  |  |  |
| 199 | 1925 | 333870 | 113 | 4.9 | 7.2 | 8.2 |  |  |  |  |  |  |  |  |  |
| 200 | 1925 | 333870 | 051 | 5.1 | 7 | 8.1 |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet14

| 2019-08-23 00:00:00 |  | Spear 1 Phase Stack SCR Replacement Log |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |
| Stack SCR Position | Serial # |  | Stack SCR Position | Serial # |  |  |  |  |  |
| Low Side Stacks |  |  | High Side Stacks |  |  |  |  |  |  |
| S1 C+ |  |  | S2 C+ |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| 1 | 21 |  | 1 | 196 |  |  |  |  |  |
| 2 | 159 |  | 2 | 181 |  |  |  |  |  |
| 3 | 144 |  | 3 | 33 |  |  |  |  |  |
| 4 | 141 |  | 4 | 180 |  |  |  |  |  |
| 5 | 100 |  | 5 | 88 |  |  |  |  |  |
| 6 | 165 |  | 6 | 147 |  |  |  |  |  |
| 7 | 71 |  | 7 | 32 |  |  |  |  |  |
| 8 | 40 |  | 8 | 138 |  |  |  |  |  |
| 9 | 218 |  | 9 | 5 |  |  |  |  |  |
| 10 | 58 |  | 10 | 10 |  |  |  |  |  |
| 11 | 69 |  | 11 | 137 |  |  |  |  |  |
| 12 | 56 |  | 12 | 54 |  |  |  |  |  |
| 13 | 137 |  | 13 | 55 |  |  |  |  |  |
| 14 | 191 |  | 14 | 213 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| S1 C- |  |  | S2  C- |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| 1 | 78 |  | 1 | 123 |  |  |  |  |  |
| 2 | 87 |  | 2 | 49 |  |  |  |  |  |
| 3 | 160 |  | 3 | 227 |  |  |  |  |  |
| 4 | 176 |  | 4 | 124 |  |  |  |  |  |
| 5 | 94 |  | 5 | 182 |  |  |  |  |  |
| 6 | 206 |  | 6 | 214 |  |  |  |  |  |
| 7 | 175 |  | 7 | 221 |  |  |  |  |  |
| 8 | 77 |  | 8 | 133 |  |  |  |  |  |
| 9 | 76 |  | 9 | 48 |  |  |  |  |  |
| 10 | 108 |  | 10 | 100 |  |  |  |  |  |
| 11 | 16 |  | 11 | 150 |  |  |  |  |  |
| 12 | 179 |  | 12 | 53 |  |  |  |  |  |
| 13 | 161 |  | 13 | 131 |  |  |  |  |  |
| 14 | 65 |  | 14 | 115 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| S1 B+ |  |  | S2 B+ |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| 1 | 80 |  | 1 | 59 |  |  |  |  |  |
| 2 | 222 |  | 2 | 30 |  |  |  |  |  |
| 3 | 79 |  | 3 | 4 |  |  |  |  |  |
| 4 | 20 |  | 4 | 189 |  |  |  |  |  |
| 5 | 7 |  | 5 | 63 |  |  |  |  |  |
| 6 | 200 |  | 6 | 148 |  |  |  |  |  |
| 7 | 24 |  | 7 | 73 |  |  |  |  |  |
| 8 | 207 |  | 8 | 132 |  |  |  |  |  |
| 9 | 185 |  | 9 | 66 |  |  |  |  |  |
| 10 | 195 |  | 10 | 57 |  |  |  |  |  |
| 11 | 22 |  | 11 | 29 |  |  |  |  |  |
| 12 | 11 |  | 12 | 23 |  |  |  |  |  |
| 13 | 201 |  | 13 | 85 |  |  |  |  |  |
| 14 | 3 |  | 14 | 210 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| S1 B- |  |  | S2 B- |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| 1 | 101 |  | 1 | 62 |  |  |  |  |  |
| 2 | 170 |  | 2 | 127 |  |  |  |  |  |
| 3 | 136 |  | 3 | 129 |  |  |  |  |  |
| 4 | 164 |  | 4 | 116 |  |  |  |  |  |
| 5 | 205 |  | 5 | 118 |  |  |  |  |  |
| 6 | 178 |  | 6 | 154 |  |  |  |  |  |
| 7 | 25 |  | 7 | 122 |  |  |  |  |  |
| 8 | 219 |  | 8 | 52 |  |  |  |  |  |
| 9 | 177 |  | 9 | 113 |  |  |  |  |  |
| 10 | 14 |  | 10 | 126 |  |  |  |  |  |
| 11 | 18 |  | 11 | 217 |  |  |  |  |  |
| 12 | 60 |  | 12 | 142 |  |  |  |  |  |
| 13 | 172 |  | 13 | 51 |  |  |  |  |  |
| 14 | 211 |  | 14 | 109 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| S1 A+ |  |  | S2 A+ |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| 1 | 81 |  | 1 | 215 |  |  |  |  |  |
| 2 | 134 |  | 2 | 12 |  |  |  |  |  |
| 3 | 93 |  | 3 | 145 |  |  |  |  |  |
| 4 | 190 |  | 4 | 112 |  |  |  |  |  |
| 5 | 140 |  | 5 | 121 |  |  |  |  |  |
| 6 | 61 |  | 6 | 120 |  |  |  |  |  |
| 7 | 203 |  | 7 | 167 |  |  |  |  |  |
| 8 | 84 |  | 8 | 223 |  |  |  |  |  |
| 9 | 6 |  | 9 | 220 |  |  |  |  |  |
| 10 | 89 |  | 10 | 187 |  |  |  |  |  |
| 11 | 95 |  | 11 | 153 |  |  |  |  |  |
| 12 | 42 |  | 12 | 216 |  |  |  |  |  |
| 13 | 143 |  | 13 | 117 |  |  |  |  |  |
| 14 | 64 |  | 14 | 156 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| S1 A- |  |  | S2 A- |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| 1 | 192 |  | 1 | 28 |  |  |  |  |  |
| 2 | 188 |  | 2 | 70 |  |  |  |  |  |
| 3 | 31 |  | 3 | 83 |  |  |  |  |  |
| 4 | 9 |  | 4 | 8 |  |  |  |  |  |
| 5 | 139 |  | 5 | 82 |  |  |  |  |  |
| 6 | 197 |  | 6 | 169 |  |  |  |  |  |
| 7 | 212 |  | 7 | 149 |  |  |  |  |  |
| 8 | 68 |  | 8 | 26 |  |  |  |  |  |
| 9 | 193 |  | 9 | 130 |  |  |  |  |  |
| 10 | 35 |  | 10 | 146 |  |  |  |  |  |
| 11 | 157 |  | 11 | 39 |  |  |  |  |  |
| 12 | 119 |  | 12 | 74 |  |  |  |  |  |
| 13 | 155 |  | 13 | 151 |  |  |  |  |  |
| 14 | 111 |  | 14 | 46 |  |  |  |  |  |


## Sheet: Sheet15

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | Crowbar Stacks removed from Spear 1 on 26 September 2019 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | Crowbar Stacks installed in Spear 1 on 26 September 2019 |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  | Set 1 from sheet 11 | Cold Tests @ 25 deg. C |  |  |  |  |  |  |  |  |  |  |  |  |  |  | Set 2 from sheet 11 | Cold Tests @ 25 deg. C |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  | mA |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Stack 1 | SCR S/N | Stack Leakage @ 25 KVDC | Fiber Optic Trig Test | SF KV | Pass/Fail |  |  |  |  |  |  |  |  |  |  | Stack 1 | SCR S/N | Stack Leakage @ 25 KVDC | Fiber Optic Trig Test | SF KV | Pass/Fail |  |
|  |  |  | Cell 1 | 5389 |  | Good | 7.36 |  |  |  |  |  |  |  |  |  |  |  | Cell 1 | 5289 |  |  |  |  |  |
|  |  |  | Cell 2 | 5281 | > 2.4 mA @ 5KV | Good | 7.2 |  |  |  |  |  |  |  |  |  |  |  | Cell 2 | 5270 |  |  |  |  |  |
|  |  |  | Cell 3 | 5311 | .980 mA | Good | 7.44 | Marginal |  |  |  |  |  |  |  |  |  |  | Cell 3 | 5424 | .841 mA | Good | 40.05 | Pass |  |
|  |  |  | Cell 4 | 2335 |  | Good | 7.4 |  |  |  |  |  |  |  |  |  |  |  | Cell 4 | 5336 |  |  |  |  |  |
|  |  |  | Cell 5 | 5240 |  | Marginal | 7.56 |  |  |  |  |  |  |  |  |  |  |  | Cell 5 | 5385 |  |  |  |  |  |
|  |  |  | Cell 6 | 5304 |  | Good | 7.2 |  |  |  |  |  |  |  |  |  |  |  | Cell 6 | 5383 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Stack 2 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | Stack 2 |  |  |  |  |  |  |
|  |  |  | Cell 1 | 5307 |  | Good | 7.28 |  |  |  |  |  |  |  |  |  |  |  | Cell 1 | 5343 |  |  |  |  |  |
|  |  |  | Cell 2 | 5393 |  | Good | 7.28 |  |  |  |  |  |  |  |  |  |  |  | Cell 2 | 5186 |  |  |  |  |  |
|  |  |  | Cell 3 | 5288 | .850 mA | Good | 8.12 | Good |  |  |  |  |  |  |  |  |  |  | Cell 3 | 5317 | .836 mA | Good | 40.04 | Pass |  |
|  |  |  | Cell 4 | 2503 |  | Good | 7.24 |  |  |  |  |  |  |  |  |  |  |  | Cell 4 | 5303 |  |  |  |  |  |
|  |  |  | Cell 5 | 2511 |  | Good | 7.24 |  |  |  |  |  |  |  |  |  |  |  | Cell 5 | 5337 |  |  |  |  |  |
|  |  |  | Cell 6 | 5309 |  | Good | 7.32 |  |  |  |  |  |  |  |  |  |  |  | Cell 6 | 5382 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Stack 3 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | Stack 3 |  |  |  |  |  |  |
|  |  |  | Cell 1 | 5283 | >1.28 mA @ 5KV | Good | 7 |  |  |  |  |  |  |  |  |  |  |  | Cell 1 | 5290 |  |  |  |  |  |
|  |  |  | Cell 2 | 5330 | > 2 mA @ 5KV | Good | 7.2 |  |  |  |  |  |  |  |  |  |  |  | Cell 2 | 5297 |  |  |  |  |  |
|  |  |  | Cell 3 | 5295 | 1.044 mA | Good | 7.12 | Marginal |  |  |  |  |  |  |  |  |  |  | Cell 3 | 5423 | .837 mA | Good | 40 | Pass |  |
|  |  |  | Cell 4 | 5238 |  | Good | 7.2 |  |  |  |  |  |  |  |  |  |  |  | Cell 4 | 5384 |  |  |  |  |  |
|  |  |  | Cell 5 | 5269 |  | Bad | 7.06 |  |  |  |  |  |  |  |  |  |  |  | Cell 5 | 5236 |  |  |  |  |  |
|  |  |  | Cell 6 | 5255 |  | Good | 7.6 |  |  |  |  |  |  |  |  |  |  |  | Cell 6 | 5249 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Stack 4 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | Stack 4 |  |  |  |  |  |  |
|  |  |  | Cell 1 | 5314 |  | Good | 7.44 |  |  |  |  |  |  |  |  |  |  |  | Cell 1 | 5339 |  |  |  |  |  |
|  |  |  | Cell 2 | 5392 |  | Good | 7.36 |  |  |  |  |  |  |  |  |  |  |  | Cell 2 | 5296 |  |  |  |  |  |
|  |  |  | Cell 3 | 5331 | .850 mA | Good | 7.68 | Good |  |  |  |  |  |  |  |  |  |  | Cell 3 | 5341 | .836 mA | Good | 40.34 | Pass |  |
|  |  |  | Cell 4 | 5407 |  | Good | 7.36 |  |  |  |  |  |  |  |  |  |  |  | Cell 4 | 5340 |  |  |  |  |  |
|  |  |  | Cell 5 | 2510 |  | Good | 7.24 |  |  |  |  |  |  |  |  |  |  |  | Cell 5 | 5275 |  |  |  |  |  |
|  |  |  | Cell 6 | 5239 |  | Good | 8.12 |  |  |  |  |  |  |  |  |  |  |  | Cell 6 | 5342 |  |  |  |  |  |


## Sheet: Sheet16

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Individual SCR fwd leakage testing of SCRs removed from Spear 1 RF HVPS on 26 September 2019 |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Comparison made to fwd leakage value from stack assembly before installation in Spear 1 crowbar tank. |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  | After Last Spear Run | Previous Measurement @ 4.2 KV | After Last Spear Run | Previous Measurement @ 6.5 KV |  |  |  |
|  |  | Stack 1 | Date Code | Serial # | uA @ 4.2 KV @ 2 mins | uA @ 4.2 KV | uA @ 6.5 KV @ 2 mins | uA @ 6.5 KV | Fiber Optic | OV Self-Fire | SCR Good/Bad |
|  |  | 1 | 21T9 | 5389 | 121.5+ | 25 | 356.2+ | 124.5 | Good | 7.58 | Marginal |
|  |  | 2 | 07T9 | 5281 | 2158+ | 19 | 5000+ | 29.2 | Good | 7.36 | Bad |
|  |  | 3 | 20T9 | 5311 | 26.5+ | 7.2 | 60+ | 21 | Good | 7.52 | Good |
|  |  | 4 | 24R3 | 2335 | 20.8 | 35 | 63.8 | 98.5 | Good | 7.6 | Good |
|  |  | 5 | 02T9 | 5240 | 22.8 | 8.4 | 48.6 | 13.3 | Bad | 7.72 | Good |
|  |  | 6 | 25T8 | 5304 | 5.7 | 7 | 14.5 | 16 | Good | 7.36 | Good |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Stack 2 |  |  |  |  |  |  |  |  |  |
|  |  | 1 | 14T9 | 5307 | 6.6 | 11.4 | 11.7 | 16 | Good | 7.48 | Good |
|  |  | 2 | 21T9 | 5393 | 22 | 14.4 | 68.9 | 42.2 | Good | 7.4 | Good |
|  |  | 3 | 06T9 | 5288 | 19.2 | 20 | 123.8 | 145 | Good | 8.32 | Good |
|  |  | 4 | 02R4 | 2503 | 5 | 6 | 9.1 | 11 | Good | 7.4 | Good |
|  |  | 5 | 24R3 | 2511 | 7 | 14.7 | 23.4 | 38.8 | Good | 7.44 | Good |
|  |  | 6 | 14T9 | 5309 | 24.2 | 11.4 | 53.7 | 31.2 | Bad | 7.48 | Good |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Stack 3 |  |  |  |  |  |  |  |  |  |
|  |  | 1 | 06T9 | 5283 | 485.2+ | 6.3 | 1148+ | 13.3 | Good | 7.48 | Bad |
|  |  | 2 | 14T9 | 5330 | 770+ | 12.5 | 1681+ | 27.2 | Good | 7.76 | Bad |
|  |  | 3 | 01T9 | 5295 | 25.8 | 31.7 | 74.1 | 98 | Good | 7 | Good |
|  |  | 4 | 02T9 | 5238 | 12.1 | 4 | 32.6 | 9.6 | Bad | 7.56 | Good |
|  |  | 5 | Unknown | 5269 | 19.6 | 25.8 | 81.4 | 106.5 | Bad | 7.44 | Good |
|  |  | 6 | 22T8 | 5255 | 57.5+ | 14 | 142.4+ | 45.6 | Good | 6.58 | Marginal |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Stack 4 |  |  |  |  |  |  |  |  |  |
|  |  | 1 | 20T9 | 5314 | 5 | 6 | 8.6 | 10.2 | Good | 7.36 | Good |
|  |  | 2 | 21T9 | 5392 | 12.7 | 9.5 | 33.9 | 31 | Good | 7.28 | Good |
|  |  | 3 | 14T9 | 5331 | 54 | 18 | 162.8 | 38.8 | Good | 7.48 | Good |
|  |  | 4 | 21T9 | 5407 | 46.4 | 19.2 | 196 | 41.8 | Good | 7.2 | Good |
|  |  | 5 | 24R3 | 2510 | 7.3 | 8.5 | 16.4 | 19.6 | Good | 7.04 | Good |
|  |  | 6 | 02T9 | 5239 | 12.1 | 6.1 | 43.2 | 24.2 | Good | 7.92 | Good |


## Sheet: Sheet17

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | Set 1 of Spare Crowbar Stacks Made From Stacks Removed From Spear 1 Sept. 26, 2019 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  | Set 1 | Date:  Oct 2, 2018 |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  | Stack 1 | Date Code | SCR S/N | Stack Leakage @ 25 KVDC | Fiber Optic Trig Test | SF KV | Pass/Fail |  |
|  |  | Cell 1 |  | 5389 |  | Good |  |  |  |
|  |  | Cell 2 |  | 5281 |  | Good |  |  |  |
|  |  | Cell 3 |  | 5311 | .842 mA | Good | 42.7 | Pass |  |
|  |  | Cell 4 |  | 2335 |  | Good |  |  |  |
|  |  | Cell 5 |  | 5240 |  | Good |  |  |  |
|  |  | Cell 6 |  | 5304 |  | Good |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  | Stack 2 |  |  |  |  |  |  |  |
|  |  | Cell 1 |  | 5307 |  | Good |  |  |  |
|  |  | Cell 2 |  | 5393 |  | Good |  |  |  |
|  |  | Cell 3 |  | 5288 | .841 mA | Good | 42 | Pass |  |
|  |  | Cell 4 |  | 2503 |  | Good |  |  |  |
|  |  | Cell 5 |  | 2511 |  | Good |  |  |  |
|  |  | Cell 6 |  | 5309 |  | Good |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  | Stack 3 |  |  |  |  |  |  |  |
|  |  | Cell 1 | 06U2 | 5681 |  | Good |  |  |  |
|  |  | Cell 2 | 22T8 | 5253 |  | Good |  |  |  |
|  |  | Cell 3 | 01T9 | 5295 | 0.845 mA | Good | 42.5 | Pass |  |
|  |  | Cell 4 | 02T9 | 5238 |  | Good |  |  |  |
|  |  | Cell 5 | Unknown | 5269 |  | Good |  |  |  |
|  |  | Cell 6 | 22T8 | 5241 |  | Good |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  | Stack 4 |  |  |  |  |  |  |  |
|  |  | Cell 1 |  | 5314 |  | Good |  |  |  |
|  |  | Cell 2 |  | 5392 |  | Good |  |  |  |
|  |  | Cell 3 |  | 5331 | 0.84 mA | Good | 42.2 | Pass |  |
|  |  | Cell 4 |  | 5407 |  | Good |  |  |  |
|  |  | Cell 5 |  | 2510 |  | Good |  |  |  |
|  |  | Cell 6 |  | 5239 |  | Good |  |  |  |


## Sheet: Sheet18

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | Spear 3 RF HVPS Spear 2 Periodic Maintenance Report During July/Aug, 2020 Downtime |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Phase Tank Snubber Ckts: |  |  | All measurements made with Fluke 289 DMM |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  | Ambient air temp of 74 deg. F |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Position | Capacitor = 15 nF, 30 KV, +/- 15% |  |  |  | Resistor = 2200 ohm, 100 watt, +/- 10% |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| S1C+ | 16.2 nF |  |  | S1C+ | 2.7881 K ohms | Replaced w/ 2.0510 K ohms |  |  |  |  |  | Hipot of positive phase stack with cell to cell voltages measured.  31 July 2020 |  |  |  |  |  |
| S1C- | 16.2 nF |  |  | S1C- | 2.8073 K ohms | Replaced w/ 2.0510 K ohms |  |  |  |  |  |  |  |  |  |  |  |
| S1B+ | 15.7 nF |  |  | S1B+ | 2.4511 K ohms |  |  |  |  |  |  | SCR # |  | Volts on top plate | Volts on bottom plate | Volts difference across SCR | SCR ohms (rounded) |
| S1B- | 16.1 nF |  |  | S1B- | 2.5623 K ohms |  |  |  |  |  |  | 1 (top) |  | 24.91 | 22.82 | 2.09 KV | 15.3  Meg Ohms |
| S1A+ | 16.3 nF |  |  | S1A+ | 2.4977 K ohms |  |  |  |  |  |  | 2 |  | 22.82 | 20.87 | 1.95 KV | 15.3 Meg Ohms |
| S1A- | 16.5 nF |  |  | S1A- | 2.6739 K ohms |  |  |  |  |  |  | 3 |  | 20.87 | 18.83 | 2.04 KV | 15 Meg Ohms |
|  |  |  |  |  |  |  |  |  |  |  |  | 4 |  | 18.83 | 16.9 | 1.93 KV | 14.1 Meg Ohms |
| S2C+ | 15.8 nF |  |  | S2C+ | 2.0699 K ohms |  |  |  |  |  |  | 5 |  | 16.9 | 14.95 | 1.95 KV | 15.3 Meg Ohms |
| S2C- | 15.4 nF |  |  | S2C- | 2.4047 K ohms |  |  |  |  |  |  | 6 |  | 14.95 | 12.96 | 1.99 KV | 14.6 Meg Ohms |
| S2B+ | 16.0 nF |  |  | S2B+ | 2.8306 K ohms | Replaced w/ 2.0775 K ohms |  |  |  |  |  | 7 |  | 12.96 | 11.12 | 1.84 KV | 13.5 Meg Ohms |
| S2B- | 15.5 nF |  |  | S2B- | 2.5274 K ohms |  |  |  |  |  |  | 8 |  | 11.12 | 9.12 | 2 KV | 14.7 Meg ohms |
| S2A+ | 15.3 nF |  |  | S2A+ | 2.5596 K ohms |  |  |  |  |  |  | 9 |  | 9.12 | 7.13 | 1.99 KV | 14.6 Meg Ohms |
| S2A- | 15.5 nF |  |  | S2A- | 2.5068 K ohms |  |  |  |  |  |  | 10 |  | 7.13 | 5.199 | 1.931 KV | 14.1 Meg Ohms |
|  |  |  |  |  |  |  |  |  |  |  |  | 11 |  | 5.199 | 3.253 | 1.946 KV | 14.3 Meg Ohms |
|  |  |  |  |  |  |  |  |  |  |  |  | 12 |  | 3.253 | 1.273 | 1.98 KV | 14.5 Meg Ohms |
|  |  |  |  |  |  |  |  |  |  |  |  | 13 |  | 1.273 | 0 | 1.273 KV | 9.3 Meg Ohms |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | Note:  hipot set is negative voltage output. |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | Current through stack @ 24.91KV = 136.51 uA in forward (conducting) direction.  Stack has 13 SCRs. |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | Overall stack resistance in SCR fwd bias direction:  24.91 KV/136.51 uA = approx. 182.5 Meg Ohms |  |  |  |  |


## Sheet: Sheet19

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |
|  | Hipot of positive phase stack with cell to cell voltages measured.  31 July 2020 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  | SCR # |  | Volts on top plate | Volts on bottom plate | Volts difference across SCR | SCR ohms (rounded) |  |  |  |
|  | 1 (top) |  | 24.91 | 22.82 | 2.09 KV | 15.3  M Ohms |  |  |  |
|  | 2 |  | 22.82 | 20.87 | 1.95 KV | 15.3 M Ohms |  |  |  |
|  | 3 |  | 20.87 | 18.83 | 2.04 KV | 15 M Ohms |  |  |  |
|  | 4 |  | 18.83 | 16.9 | 1.93 KV | 14.1 M Ohms |  |  |  |
|  | 5 |  | 16.9 | 14.95 | 1.95 KV | 15.3 M Ohms |  |  |  |
|  | 6 |  | 14.95 | 12.96 | 1.99 KV | 14.6 M Ohms |  |  |  |
|  | 7 |  | 12.96 | 11.12 | 1.84 KV | 13.5 M Ohms |  |  |  |
|  | 8 |  | 11.12 | 9.12 | 2 KV | 14.7 M ohms |  |  |  |
|  | 9 |  | 9.12 | 7.13 | 1.99 KV | 14.6 M Ohms |  |  |  |
|  | 10 |  | 7.13 | 5.199 | 1.931 KV | 14.1 M Ohms |  |  |  |
|  | 11 |  | 5.199 | 3.253 | 1.946 KV | 14.3 M Ohms |  |  |  |
|  | 12 |  | 3.253 | 1.273 | 1.98 KV | 14.5 M Ohms |  |  |  |
|  | 13 |  | 1.273 | 0 | 1.273 KV | 9.3 M Ohms |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  | Note:  hipot set is negative voltage output. |  |  |  |  |  |  |  |
|  |  | Current through stack @ 24.91KV = 136.51 uA in forward (conducting) direction.  Stack has 13 SCRs. |  |  |  |  |  |  |  |
|  |  | Overall stack resistance in SCR fwd bias direction:  24.91 KV/136.51 uA = approx. 182.5 Meg Ohms |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  | Conclusion:  12 of 13 SCRs measure right around 15 M Ohms with the exception of SCR 13 (bottom) which is less by appox 5.7 M Ohms or 38% less. |  |  |  |  |  |  |  |
|  |  | Is this indicative of SCR 13 having reduced life?  Will need a larger data set (measuring volt drops across more stacks' SCRs) to make that |  |  |  |  |  |  |  |
|  |  | determination. |  |  |  |  |  |  |  |


## Sheet: Sheet20

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Inventory of crowbar stacks installed in Spear 2 RF HVPS on Aug. 7, 2020 for PM/Downtime swap. |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  | Stack 1 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  | Cell 1 | 5389 |  |  |  |  |  |
|  |  |  |  |  | Cell 2 | 5281 |  |  |  |  |  |
|  |  |  |  |  | Cell 3 | 5311 | .850 mA | Good | 40.56 | Pass |  |
|  |  |  |  |  | Cell 4 | 2335 |  |  |  |  |  |
|  |  |  |  |  | Cell 5 | 5240 |  |  |  |  |  |
|  |  |  |  |  | Cell 6 | 5304 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  | Stack 2 | ?????????  Not sure if this is correct--SCRs from sheet 10, but no record of stack built with these SCRs. |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  | Cell 1 | 5343 |  |  |  |  |  |
|  |  |  |  |  | Cell 2 | 5186 |  |  |  |  |  |
|  |  |  |  |  | Cell 3 | 5317 | .836 mA | Good | 40.04 | Pass |  |
|  |  |  |  |  | Cell 4 | 5303 |  |  |  |  |  |
|  |  |  |  |  | Cell 5 | 5337 |  |  |  |  |  |
|  |  |  |  |  | Cell 6 | 5382 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  | Stack 3 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  | Cell 1 | 06U2 | 5681 |  | Good |  |  |
|  |  |  |  |  | Cell 2 | 22T8 | 5253 |  | Good |  |  |
|  |  |  |  |  | Cell 3 | 01T9 | 5295 | 0.845 mA | Good | 42.5 | Pass |
|  |  |  |  |  | Cell 4 | 02T9 | 5238 |  | Good |  |  |
|  |  |  |  |  | Cell 5 | Unknown | 5269 |  | Good |  |  |
|  |  |  |  |  | Cell 6 | 22T8 | 5241 |  | Good |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  | Stack 4 |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  | Cell 1 | 5314 |  |  |  |  |  |
|  |  |  |  |  | Cell 2 | 5392 |  |  |  |  |  |
|  |  |  |  |  | Cell 3 | 5331 | .856 mA | Good | 41.21 | Pass |  |
|  |  |  |  |  | Cell 4 | 5407 |  |  |  |  |  |
|  |  |  |  |  | Cell 5 | 2510 |  |  |  |  |  |
|  |  |  |  |  | Cell 6 | 5239 |  |  |  |  |  |


## Sheet: Sheet21

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | Hipot of phase stacks with cell to cell voltages measured.  All 12 stacks removed from Spear 2 RF HVPS July 23, 2020 during SPEAR downtime and from PEP 2, 8-5 July 17, 2020. |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Current measured in SCR fwd (conducting) direction. |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  | New Batch |  |  |  |  |
|  |  |  |  |  |  |  |  |  | Stack # |  |  |  |  |
| Stack Position | SCR # | Series Current A | Volts on top plate KV | Volts on bottom plate KV | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 1.48e-05 | 0 | 2066.4 | 2066.4 | 139621621.6216216 | 139.622 |  |  |  |  |  |  |
|  | 2 | 1.48e-05 | 2066.4 | 3746.7 | 1680.2999999999997 | 113533783.78378376 | 113.534 |  |  |  |  |  |  |
|  | 3 | 1.48e-05 | 3746.7 | 5313.5 | 1566.8000000000002 | 105864864.86486487 | 105.865 |  |  |  |  |  |  |
|  | 4 | 1.48e-05 | 5313.5 | 7088.2 | 1774.6999999999998 | 119912162.16216214 | 119.912 |  |  |  |  |  |  |
| Spear 2 | 5 | 1.48e-05 | 7088.2 | 8245 | 1156.8000000000002 | 78162162.16216217 | 78.162 |  |  |  | Left SCR in until next PM maintenance cycle. |  |  |
| S1 A - | 6 | 1.48e-05 | 8245 | 9404 | 1159 | 78310810.8108108 | 78.311 |  |  |  | Left SCR in until next PM maintenance cycle. |  |  |
| S/N 117 | 7 | 1.48e-05 | 9404 | 11184 | 1780 | 120270270.27027026 | 120.27 |  | 1 |  |  |  |  |
|  | 8 | 1.48e-05 | 11184 | 13136 | 1952 | 131891891.89189188 | 131.892 |  |  |  |  |  |  |
|  | 9 | 1.48e-05 | 13136 | 15164 | 2028 | 137027027.027027 | 137.027 |  |  |  |  |  |  |
|  | 10 | 1.48e-05 | 15164 | 17222 | 2058 | 139054054.05405405 | 139.054 |  |  |  |  |  |  |
|  | 11 | 1.48e-05 | 17222 | 19255 | 2033 | 137364864.86486486 | 137.365 |  |  |  |  |  |  |
|  | 12 | 1.48e-05 | 19255 | 21022 | 1767 | 119391891.89189188 | 119.392 |  |  |  |  |  |  |
|  | 13 | 1.48e-05 | 21022 | 23129 | 2107 | 142364864.86486486 | 142.365 |  |  |  |  |  |  |
|  | 14 | 1.48e-05 | 23129 | 25305 | 2176 | 147027027.027027 | 147.027 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 3.2e-05 | 25643 | 23678 | 1965 | 61406250 | 61.406 |  |  |  |  |  |  |
|  | 2 | 3.2e-05 | 23678 | 21842 | 1836 | 57375000 | 57.375 |  |  |  |  |  |  |
|  | 3 | 3.2e-05 | 21842 | 20004 | 1838 | 57437500 | 57.438 |  |  |  |  |  |  |
|  | 4 | 3.2e-05 | 20004 | 18174 | 1830 | 57187500 | 57.186 |  |  |  |  |  |  |
| Spear 2 | 5 | 3.2e-05 | 18174 | 16347 | 1827 | 57093750 | 57.094 |  |  |  |  |  |  |
| S1 B+ | 6 | 3.2e-05 | 16347 | 14592 | 1755 | 54843750 | 54.844 |  | 2 |  |  |  |  |
| S/N 119 | 7 | 3.2e-05 | 14592 | 12681 | 1911 | 59718750 | 59.719 |  |  |  |  |  |  |
|  | 8 | 3.2e-05 | 12681 | 10844 | 1837 | 57406250 | 57.406 |  |  |  |  |  |  |
|  | 9 | 3.2e-05 | 10844 | 9005 | 1839 | 57468750 | 57.469 |  |  |  |  |  |  |
|  | 10 | 3.2e-05 | 9005 | 7236 | 1769 | 55281250 | 55.281 |  |  |  |  |  |  |
|  | 11 | 3.2e-05 | 7236 | 5620 | 1616 | 50500000 | 50.5 |  |  |  | Left SCR in until next PM maintenance cycle. |  |  |
|  | 12 | 3.2e-05 | 5620 | 3761 | 1859 | 58093750 | 58.094 |  |  |  |  |  |  |
|  | 13 | 3.2e-05 | 3761 | 1860 | 1901 | 59406250 | 59.406 |  |  |  |  |  |  |
|  | 14 | 3.2e-05 | 1860 | 0 | 1860 | 58125000 | 58.125 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 2.26e-05 | 0 | 1899 | 1899 | 84026548.67256637 | 84.027 |  |  |  |  |  |  |
|  | 2 | 2.26e-05 | 1899 | 3471 | 1572 | 69557522.1238938 | 69.558 |  |  |  |  |  |  |
|  | 3 | 2.26e-05 | 3471 | 5387 | 1916 | 84778761.0619469 | 84.779 |  |  |  |  |  |  |
|  | 4 | 2.26e-05 | 5387 | 6465 | 1078 | 47699115.04424778 | 47.699 |  |  |  | Left SCR in until next PM maintenance cycle. |  |  |
| Spear 2 | 5 | 2.26e-05 | 6465 | 8470 | 2005 | 88716814.15929203 | 88.717 |  |  |  |  |  |  |
| S2 C- | 6 | 2.26e-05 | 8470 | 10597 | 2127 | 94115044.24778761 | 94.115 |  | 3 |  |  |  |  |
| S/N 116 | 7 | 2.26e-05 | 10597 | 12713 | 2116 | 93628318.5840708 | 93.628 |  |  |  |  |  |  |
|  | 8 | 2.26e-05 | 12713 | 14566 | 1853 | 81991150.44247787 | 81.991 |  |  |  |  |  |  |
|  | 9 | 2.26e-05 | 14566 | 16503 | 1937 | 85707964.60176991 | 85.708 |  |  |  |  |  |  |
|  | 10 | 2.26e-05 | 16503 | 18687 | 2184 | 96637168.14159292 | 96.637 |  |  |  |  |  |  |
|  | 11 | 2.26e-05 | 18687 | 20419 | 1732 | 76637168.14159292 | 76.637 |  |  |  |  |  |  |
|  | 12 | 2.26e-05 | 20419 | 22136 | 1717 | 75973451.32743363 | 75.973 |  |  |  |  |  |  |
|  | 13 | 2.26e-05 | 22136 | 23576 | 1440 | 63716814.159292035 | 63.717 |  |  |  |  |  |  |
|  | 14 | 2.26e-05 | 23576 | 25145 | 1569 | 69424778.76106195 | 69.425 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 7.05e-05 | 0 | 1031 | 1031 | 14624113.475177303 | 14.624 |  |  |  | 25312 | 23527 | 1785 |
|  | 2 | 7.05e-05 | 1031 | 2744 | 1713 | 24297872.34042553 | 24.298 |  |  |  |  |  |  |
|  | 3 | 7.05e-05 | 2744 | 4563 | 1819 | 25801418.43971631 | 25.801 |  |  |  |  |  |  |
|  | 4 | 7.05e-05 | 4563 | 6279 | 1716 | 24340425.53191489 | 24.34 |  |  |  |  | V applied to stack:  25312 Volts DC |  |
| Spear 2 | 5 | 7.05e-05 | 6279 | 8208 | 1929 | 27361702.12765957 | 27.362 |  |  |  |  | Stack Series I = 37.6 uA |  |
| S1 B- | 6 | 7.05e-05 | 8209 | 10008 | 1799 | 25517730.4964539 | 25518 |  | 4 |  |  |  |  |
| S/N 118 | 7 | 7.05e-05 | 10008 | 11967 | 1959 | 27787234.04255319 | 27.787 |  |  |  |  |  |  |
|  | 8 | 7.05e-05 | 11967 | 13221 | 1254 | 17787234.04255319 | 17.787 |  |  |  | 13408 | 11723 | 1685 |
|  | 9 | 7.05e-05 | 13221 | 14405 | 1184 | 16794326.24113475 | 16.794 |  |  |  | 11723 | 9853 | 1870 |
|  | 10 | 7.05e-05 | 14405 | 16402 | 1997 | 28326241.13475177 | 28.326 |  |  |  |  |  |  |
|  | 11 | 7.05e-05 | 16402 | 18576 | 2174 | 30836879.43262411 | 30.837 |  |  |  |  |  |  |
|  | 12 | 7.05e-05 | 18576 | 20605 | 2029 | 28780141.84397163 | 28.78 |  |  |  |  |  |  |
|  | 13 | 7.05e-05 | 20605 | 22802 | 2197 | 31163120.567375883 | 31.163 |  |  |  |  |  |  |
|  | 14 | 7.05e-05 | 22802 | 25170 | 2368 | 33588652.4822695 | 33.589 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 1.59e-05 | 25512 | 24706 | 806 | 50691823.899371065 | 50.692 |  |  |  | 25402 | 23329 | 2073 Volts DC |
|  | 2 | 1.59e-05 | 24706 | 22599 | 2107 | 132515723.27044025 | 132.516 |  |  |  |  |  |  |
|  | 3 | 1.59e-05 | 22599 | 20272 | 2327 | 146352201.25786164 | 146.352 |  |  |  |  |  |  |
|  | 4 | 1.59e-05 | 20272 | 18304 | 1968 | 123773584.90566038 | 123.774 |  |  |  |  | V applied to stack:  25402 Volts DC |  |
| PEP 2: 8-5 | 5 | 1.59e-05 | 18304 | 16101 | 2203 | 138553459.11949685 | 138.553 |  |  |  |  | Stack Series I = 14.4 uA |  |
| Pos Stack | 6 | 1.59e-05 | 16101 | 14152 | 1949 | 122578616.35220125 | 94.906 |  | 5 |  |  |  |  |
| S/N 101 | 7 | 1.59e-05 | 14152 | 12172 | 1980 | 124528301.88679245 | 124.528 |  |  |  |  |  |  |
|  | 8 | 1.59e-05 | 12172 | 10272 | 1900 | 119496855.34591195 | 119.497 |  |  |  |  |  |  |
|  | 9 | 1.59e-05 | 10272 | 8256 | 2016 | 126792452.83018868 | 126.792 |  |  |  |  |  |  |
|  | 10 | 1.59e-05 | 8256 | 6285 | 1971 | 123962264.1509434 | 123.962 |  |  |  |  |  |  |
|  | 11 | 1.59e-05 | 6585 | 4532 | 2053 | 129119496.8553459 | 110.252 |  |  |  |  |  |  |
|  | 12 | 1.59e-05 | 4532 | 2552 | 1980 | 124528301.88679245 | 124.528 |  |  |  |  |  |  |
|  | 13 | 1.59e-05 | 2552 | 882 | 1670 | 105031446.5408805 | 105.031 |  |  |  |  |  |  |
|  | 14 | 1.59e-05 | 882 | 0 | 882 | 55471698.11320755 | 55.472 |  |  |  | 2353 | 0 | 2353 Volts DC |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 4.03e-05 | 0 | 2249 | 2249 | 55806451.61290323 | 55.806 |  |  |  |  |  |  |
|  | 2 | 4.03e-05 | 2249 | 4464 | 2215 | 54962779.156327546 | 54.963 |  |  |  |  |  |  |
|  | 3 | 4.03e-05 | 4464 | 6677 | 2213 | 54913151.36476427 | 54.913 |  |  |  |  |  |  |
|  | 4 | 4.03e-05 | 6677 | 8987 | 2310 | 57320099.25558313 | 57.32 |  |  |  |  | V applied to stack:  25602 Volts DC |  |
| PEP 2, 8-5 | 5 | 4.03e-05 | 8987 | 11302 | 2315 | 57444168.73449132 | 57.444 |  |  |  |  | Stack Series I = 24.2 uA |  |
| Neg Stack | 6 | 4.03e-05 | 11302 | 13604 | 2302 | 57121588.08933003 | 57.122 |  | 6 |  |  |  |  |
| S/N 115 | 7 | 4.03e-05 | 13604 | 15874 | 2270 | 56327543.42431762 | 56.328 |  |  |  |  |  |  |
|  | 8 | 4.03e-05 | 15874 | 18233 | 2359 | 58535980.14888338 | 58.536 |  |  |  |  |  |  |
|  | 9 | 4.03e-05 | 18233 | 20478 | 2245 | 55707196.02977668 | 55.707 |  |  |  |  |  |  |
|  | 10 | 4.03e-05 | 20478 | 22673 | 2195 | 54466501.24069479 | 54.467 |  |  |  |  |  |  |
|  | 11 | 4.03e-05 | 22673 | 24090 | 1417 | 35161290.32258065 | Marginal |  |  |  | 21384 | 23048 | 1664 |
|  | 12 | 4.03e-05 | 24090 | 24295 | 205 | Short | Short |  |  |  | 23048 | 24408 | 1360 |
|  | 13 | 4.03e-05 | 24295 | 24319 | 24 | Short | Short |  |  |  | 24408 | 25627 | 1219 |
|  | 14 | 4.03e-05 | 24319 | 25536 | 1217 | Marginal | Marginal |  |  |  |  | Stage 14 removed due to original stack assembly error. |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  |  |  |  |
|  | 1 (top) | 0.0001267 | 0 | 2030 | 2030 | 16022099.447513813 | 16.022 |  |  |  |  |  |  |
|  | 2 | 0.0001267 | 2030 | 4058 | 2028 | 16006314.12786109 | 16.006 |  |  |  |  |  |  |
|  | 3 | 0.0001267 | 4058 | 5783 | 1725 | 13614838.20047356 | 13.615 |  |  |  |  |  |  |
|  | 4 | 0.0001267 | 5783 | 7773 | 1990 | 15706393.054459354 | 15.706 |  |  |  |  |  |  |
| Spear 2 | 5 | 0.0001267 | 7773 | 9680 | 1907 | 15051302.288871352 | 15.051 |  |  |  |  |  |  |
| S2 B- | 6 | 0.0001267 | 9680 | 11382 | 1702 | 13433307.024467247 | 13.433 |  | 7 |  |  |  |  |
| Boards On | 7 | 0.0001267 | 11382 | 13396 | 2014 | 15895816.89029203 | 15.896 |  |  |  | Stack fwd volts droppage measured with gate drive boards on due to |  |  |
| S/N 113 | 8 | 0.0001267 | 13396 | 15486 | 2090 | 16495659.037095502 | 16.496 |  |  |  | stack being repaired/refurbished prior to stage-stage testing. |  |  |
|  | 9 | 0.0001267 | 15486 | 17425 | 1939 | 15303867.403314918 | 15.304 |  |  |  |  |  |  |
|  | 10 | 0.0001267 | 17425 | 19344 | 1919 | 15146014.206787689 | 15.146 |  |  |  |  |  |  |
|  | 11 | 0.0001267 | 19344 | 21491 | 2147 | 16945540.647198107 | 16.946 |  |  |  |  |  |  |
|  | 12 | 0.0001267 | 21491 | 23533 | 2042 | 16116811.365430152 | 16.117 |  |  |  |  |  |  |
|  | 13 | 0.0001267 | 23533 | 25608 | 2075 | 16377269.13970008 | 16.377 |  |  |  |  |  |  |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  |  |  |  |
|  | 1 (top) | 2.51e-05 | 25559 | 23520 | 2039 | 81235059.76095617 | 81.235 |  |  |  |  |  |  |
|  | 2 | 2.51e-05 | 23520 | 21467 | 2053 | 81792828.68525897 | 81.793 |  |  |  |  |  |  |
|  | 3 | 2.51e-05 | 21467 | 19381 | 2086 | 83107569.72111554 | 83.108 |  |  |  |  |  |  |
|  | 4 | 2.51e-05 | 19381 | 17342 | 2039 | 81235059.76095617 | 81.235 |  |  |  |  |  |  |
| Spear 2 | 5 | 2.51e-05 | 17342 | 15367 | 1975 | 78685258.96414343 | 78.685 |  |  |  |  |  |  |
| S1 C+ | 6 | 2.51e-05 | 15367 | 13352 | 2015 | 80278884.4621514 | 80.279 |  | 8 |  |  |  |  |
| S/N 122 | 7 | 2.51e-05 | 13352 | 11385 | 1967 | 78366533.86454183 | 78.367 |  |  |  |  |  |  |
|  | 8 | 2.51e-05 | 11385 | 9487 | 1898 | 75617529.88047808 | 75.618 |  |  |  |  |  |  |
|  | 9 | 2.51e-05 | 9487 | 7574 | 1913 | 76215139.44223107 | 76.215 |  |  |  |  |  |  |
|  | 10 | 2.51e-05 | 7574 | 5626 | 1948 | 77609561.75298804 | 77.61 |  |  |  |  |  |  |
|  | 11 | 2.51e-05 | 5626 | 3874 | 1752 | 69800796.812749 | 69.801 |  |  |  |  |  |  |
|  | 12 | 2.51e-05 | 3874 | 1921 | 1953 | 77808764.94023904 | 77.809 |  |  |  |  |  |  |
|  | 13 | 2.51e-05 | 1921 | 0 | 1921 | 76533864.54183267 | 76.534 |  |  |  |  |  |  |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 7.24e-05 | 25693 | 23421 | 2272 | 31381215.46961326 | 31.381 |  |  |  |  |  |  |
|  | 2 | 7.24e-05 | 23421 | 21271 | 2150 | 29696132.596685085 | 29.696 |  |  |  |  | V applied to stack:  25401 volts DC |  |
|  | 3 | 7.24e-05 | 21271 | 19177 | 2094 | 28922651.933701657 | 28.923 |  |  |  |  | Stack Series I =  29.7 uA |  |
|  | 4 | 7.24e-05 | 19177 | 16980 | 2197 | 30345303.867403317 | 30.345 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
| PEP 2, 8-5 | 5 | 7.24e-05 | 16980 | 16978 | 2 | Shorted | Shorted |  |  |  | 17225 | 15354 | 1871 |
| Pos Stack | 6 | 7.24e-05 | 16978 | 14727 | 2251 | 31091160.220994476 | 31.091 |  | 9 |  |  |  |  |
| S/N 114 | 7 | 7.24e-05 | 14727 | 12516 | 2211 | 30538674.03314917 | 30.539 |  |  |  |  |  |  |
|  | 8 | 7.24e-05 | 12516 | 10376 | 2140 | 29558011.04972376 | 29.558 |  |  |  |  |  |  |
|  | 9 | 7.24e-05 | 10376 | 8179 | 2197 | 30345303.867403317 | 30.345 |  |  |  |  |  |  |
|  | 10 | 7.24e-05 | 8179 | 6074 | 2105 | 29074585.635359116 | 29.075 |  |  |  |  |  |  |
|  | 11 | 7.24e-05 | 6074 | 4206 | 1868 | 25801104.97237569 | 25.801 |  |  |  |  |  |  |
|  | 12 | 7.24e-05 | 4206 | 2084 | 2122 | 29309392.26519337 | 29.309 |  |  |  |  |  |  |
|  | 13 | 7.24e-05 | 2084 | 0 | 2084 | 28784530.38674033 | 28.785 |  |  |  |  |  |  |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 1.25e-05 | 0 | 1344 | 1344 | 107520000 | 107.52 |  |  |  | 0 | 1867 | 1867 |
|  | 2 | 1.25e-05 | 1344 | 1946 | 602 | 48160000 | 48.46 |  |  |  | 1867 | 3717 | 1850 |
|  | 3 | 1.25e-05 | 1946 | 3709 | 1763 | 141040000 | 141.04 |  |  |  |  |  |  |
|  | 4 | 1.25e-05 | 3709 | 5707 | 1998 | 159840000 | 159.84 |  |  |  |  | V applied to stack:  25440 volts DC |  |
| Spear 2 | 5 | 1.25e-05 | 5707 | 7590 | 1883 | 150640000 | 150.64 |  |  |  |  | Stack Series I =  9.4 uA |  |
| S1 C- | 6 | 1.25e-05 | 7590 | 9710 | 2120 | 169600000 | 169.6 |  | 10 |  |  |  |  |
| S/N 100 | 7 | 1.25e-05 | 9710 | 11930 | 2220 | 177600000 | 177.6 |  |  |  |  |  |  |
|  | 8 | 1.25e-05 | 11930 | 13200 | 1270 | 101600000 | 101.6 |  |  |  | 12250 | 14160 | 1910 |
|  | 9 | 1.25e-05 | 13200 | 15530 | 2330 | 186400000 | 186.4 |  |  |  |  |  |  |
|  | 10 | 1.25e-05 | 15530 | 17820 | 2290 | 183200000 | 183.2 |  |  |  |  |  |  |
|  | 11 | 1.25e-05 | 17820 | 18720 | 900 | 72000000 | 72 |  |  |  | 18050 | 20120 | 2070 |
|  | 12 | 1.25e-05 | 18720 | 21170 | 2450 | 196000000 | 196 |  |  |  |  |  |  |
|  | 13 | 1.25e-05 | 21170 | 23540 | 2370 | 189600000 | 189.6 |  |  |  |  |  |  |
|  | 14 | 1.25e-05 | 23540 | 25510 | 1970 | 157600000 | 157.6 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  |  |  |  |
|  | 1 (top) | 2.36e-05 | 25360 | 23350 | 2010 | 85169491.52542372 | 85.169 |  |  |  |  |  |  |
|  | 2 | 2.36e-05 | 23350 | 21350 | 2000 | 84745762.7118644 | 84.746 |  |  |  |  |  |  |
|  | 3 | 2.36e-05 | 21350 | 19370 | 1980 | 83898305.08474576 | 83.898 |  |  |  |  |  |  |
|  | 4 | 2.36e-05 | 19370 | 17360 | 2010 | 85169491.52542372 | 85.169 |  |  |  |  |  |  |
| PEP 2, 8-5 | 5 | 2.36e-05 | 17360 | 15370 | 1990 | 84322033.89830509 | 84.322 |  |  |  |  |  |  |
| Pos Stack | 6 | 2.36e-05 | 15350 | 13440 | 1910 | 80932203.3898305 | 80.932 |  | 11 |  |  |  |  |
| S/N 101 | 7 | 2.36e-05 | 13440 | 11460 | 1980 | 83898305.08474576 | 83.898 |  |  |  |  |  |  |
|  | 8 | 2.36e-05 | 11460 | 9600 | 1860 | 78813559.3220339 | 78.814 |  |  |  |  |  |  |
|  | 9 | 2.36e-05 | 9600 | 7880 | 1720 | 72881355.93220338 | 72.881 |  |  |  |  |  |  |
|  | 10 | 2.36e-05 | 7880 | 6060 | 1820 | 77118644.0677966 | 77.119 |  |  |  |  |  |  |
|  | 11 | 2.36e-05 | 6060 | 4152 | 1908 | 80847457.62711865 | 80.847 |  |  |  |  |  |  |
|  | 12 | 2.36e-05 | 4152 | 2090 | 2062 | 87372881.3559322 | 87.373 |  |  |  |  |  |  |
|  | 13 | 2.36e-05 | 2090 | 0 | 2090 | 88559322.0338983 | 88.559 |  |  |  |  |  |  |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 0.000171 | 25640 | 24005 | 1635 | 9561403.50877193 | 9.561 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 2 | 0.000171 | 24005 | 23004 | 1001 | 5853801.169590643 | 5.854 |  |  |  | 23730 | 21870 | 1860 |
|  | 3 | 0.000171 | 23004 | 20770 | 2234 | 13064327.485380117 | 13.064 |  |  |  |  |  |  |
|  | 4 | 0.000171 | 20770 | 18790 | 1980 | 11578947.368421052 | 11.579 |  |  |  |  | V applied to stack:  25540 volts DC |  |
| Spear 2 | 5 | 0.000171 | 18790 | 16710 | 2080 | 12163742.69005848 | 12.164 |  |  |  |  | Stack Series I =  129.2 uA |  |
| S1 A+ | 6 | 0.000171 | 16710 | 14410 | 2300 | 13450292.397660818 | 13.45 |  | 12 |  |  |  |  |
| S/N 112 | 7 | 0.000171 | 14410 | 13420 | 990 | 5789473.684210526 | 5.789 |  |  |  | 14460 | 12710 | 1750 |
|  | 8 | 0.000171 | 13420 | 11310 | 2110 | 12339181.286549706 | 12.339 |  |  |  |  |  |  |
|  | 9 | 0.000171 | 11310 | 9820 | 1490 | 8713450.292397661 | 8.713 |  |  |  |  |  |  |
|  | 10 | 0.000171 | 9820 | 8080 | 1740 | 10175438.596491227 | 10.175 |  |  |  |  |  |  |
|  | 11 | 0.000171 | 8080 | 6560 | 1520 | 8888888.888888888 | 8.889 |  |  |  |  |  |  |
|  | 12 | 0.000171 | 6560 | 4472 | 2088 | 12210526.315789472 | 12.211 |  |  |  |  |  |  |
|  | 13 | 0.000171 | 4472 | 2517 | 1955 | 11432748.538011696 | 11.433 |  |  |  |  |  |  |
|  | 14 | 0.000171 | 2517 | 0 | 2517 | 14719298.245614035 | 14.719 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 2.02e-05 | 25300 | 23120 | 2180 | 107920792.07920793 | 107.921 |  |  |  |  |  |  |
|  | 2 | 2.02e-05 | 23120 | 20770 | 2350 | 116336633.66336633 | 116.337 |  |  |  |  | V applied to stack:  25600 |  |
|  | 3 | 2.02e-05 | 20770 | 18630 | 2140 | 105940594.05940594 | 105.941 |  |  |  |  | I = .0000193 |  |
|  | 4 | 2.02e-05 | 18630 | 16490 | 2140 | 105940594.05940594 | 105.941 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
| Spear 2 | 5 | 2.02e-05 | 16490 | 15220 | 1270 | 62871287.12871287 | 62.871 |  |  |  | 17170 | 15160 | 2010 |
| S2 B+ | 6 | 2.02e-05 | 15220 | 14130 | 1090 | 53960396.03960396 | 53.96 |  |  |  | 15160 | 13380 | 1780 |
| S/N 103 | 7 | 2.02e-05 | 14130 | 11970 | 2160 | 106930693.06930692 | 106.931 |  | 13 |  |  |  |  |
|  | 8 | 2.02e-05 | 11970 | 9960 | 2010 | 99504950.4950495 | 99.505 |  |  |  |  |  |  |
|  | 9 | 2.02e-05 | 9960 | 7920 | 2040 | 100990099.00990099 | 100.99 |  |  |  |  |  |  |
|  | 10 | 2.02e-05 | 7920 | 6820 | 1100 | 54455445.54455446 | 54.455 |  |  |  | 7840 | 6090 | 1750 |
|  | 11 | 2.02e-05 | 6820 | 5054 | 1766 | 87425742.57425743 | 87.426 |  |  |  |  |  |  |
|  | 12 | 2.02e-05 | 5054 | 2921 | 2133 | 105594059.40594059 | 105.594 |  |  |  |  |  |  |
|  | 13 | 2.02e-05 | 2921 | 1594 | 1327 | 65693069.30693069 | 65.693 |  |  |  | 4462 | 2457 | 2005 |
|  | 14 | 2.02e-05 | 1594 | 0 | 1594 | 78910891.08910891 | 78.911 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 5.06e-05 | 25653 | 23550 | 2103 | 41561264.82213439 | 41.561 |  |  |  |  |  |  |
|  | 2 | 5.06e-05 | 23550 | 21941 | 1609 | 31798418.97233202 | 31.798 |  |  |  |  | V applied to stack:  25511 |  |
|  | 3 | 5.06e-05 | 21941 | 19974 | 1967 | 38873517.786561266 | 38.874 |  |  |  |  | I = .0000492 |  |
|  | 4 | 5.06e-05 | 19974 | 17873 | 2101 | 41521739.13043479 | 41.522 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
| Spear 2 | 5 | 5.06e-05 | 17873 | 16321 | 1552 | 30671936.75889328 | 30.672 |  |  |  |  |  |  |
| S2 C+ | 6 | 5.06e-05 | 16231 | 14439 | 1792 | 35415019.76284585 | 35.613 |  | 14 |  |  |  |  |
| S/N 102 | 7 | 5.06e-05 | 14439 | 12374 | 2065 | 40810276.6798419 | 40.81 |  |  |  |  |  |  |
|  | 8 | 5.06e-05 | 12374 | 10832 | 1542 | 30474308.300395258 | 39.368 |  |  |  |  |  |  |
|  | 9 | 5.06e-05 | 10832 | 8527 | 2305 | 45553359.68379447 | 45.553 |  |  |  |  |  |  |
|  | 10 | 5.06e-05 | 8527 | 6803 | 1724 | 34071146.24505929 | 34.071 |  |  |  |  |  |  |
|  | 11 | 5.06e-05 | 6803 | 4782 | 2021 | 39940711.46245059 | 39.941 |  |  |  |  |  |  |
|  | 12 | 5.06e-05 | 4782 | 3545 | 1237 | 24446640.316205535 | 24.447 |  |  |  | 5740 | 4020 | 1720 |
|  | 13 | 5.06e-05 | 3545 | 2246 | 1299 | 25671936.75889328 | 25.672 |  |  |  | 4020 | 2216 | 1804 |
|  | 14 | 5.06e-05 | 2246 | 0 | 2246 | 44387351.77865613 | 44.387 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 0.000378 | 25560 | 23210 | 2350 | 6216931.216931216 | 62.169 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 2 | 0.000378 | 23210 | 20770 | 2440 | 6455026.455026454 | 64.55 |  |  |  |  |  |  |
|  | 3 | 0.000378 | 20770 | 20710 | 60 | Short | Short |  |  |  | 21690 | 19550 | 2410 |
|  | 4 | 0.000378 | 20710 | 18320 | 2390 | 6322751.322751323 | 63.228 |  |  |  |  |  |  |
| PEP 2, 8-5 | 5 | 0.000378 | 18320 | 15950 | 2370 | 6269841.26984127 | 62.698 |  |  |  |  |  |  |
| Pos Stack | 6 | 0.000378 | 15950 | 13470 | 2480 | 6560846.560846561 | 65.608 |  | 15 |  |  |  |  |
| S/N 104 | 7 | 0.000378 | 13470 | 11120 | 2350 | 6216931.216931216 | 62.169 |  |  |  |  | V applied to stack:  25600 |  |
|  | 8 | 0.000378 | 11120 | 8590 | 2530 | 6693121.693121693 | 66.931 |  |  |  |  | I = .0000193 |  |
|  | 9 | 0.000378 | 8590 | 6246 | 2344 | 6201058.201058201 | 62.011 |  |  |  |  |  |  |
|  | 10 | 0.000378 | 6246 | 3851 | 2395 | 6335978.835978836 | 63.36 |  |  |  |  |  |  |
|  | 11 | 0.000378 | 3851 | 1407 | 2444 | 6465608.4656084655 | 64.656 |  |  |  |  |  |  |
|  | 12 | 0.000378 | 1407 | 0 | Short | Short | Short |  |  |  | 3574 | 1917 | 1657 |
|  | 13 | 0.000378 | 0 | 0 | Short | Short | Short |  |  |  | 1917 | 0 | 1917 |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 5.91e-05 | 0 | 220 | 220 | Short | Short |  |  |  | 0 | 1995 | 1995 |
|  | 2 | 5.91e-05 | 220 | 2411 | 2191 | 37072758.037225045 | 37.073 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 3 | 5.91e-05 | 2411 | 4390 | 1979 | 33485617.597292725 | 33.486 |  |  |  |  |  |  |
|  | 4 | 5.91e-05 | 4390 | 5496 | 1106 | 18714043.99323181 | 18.714 |  |  |  |  |  |  |
| Spear 2 | 5 | 5.91e-05 | 5496 | 7310 | 1814 | 30693739.424703892 | 30.694 |  |  |  |  |  |  |
| S2 A- | 6 | 5.91e-05 | 7310 | 9420 | 2110 | 35702199.661590524 | 35.702 |  | 16 |  |  |  |  |
| S/N 105 | 7 | 5.91e-05 | 9420 | 11650 | 2230 | 37732656.5143824 | 37.733 |  |  |  |  | V applied to stack:  25890 |  |
|  | 8 | 5.91e-05 | 11650 | 13530 | 1880 | 31810490.693739425 | 31.81 |  |  |  |  | I = .0000217 |  |
|  | 9 | 5.91e-05 | 13530 | 14980 | 1450 | Marginal | Marginal |  |  |  | 5657 | 7700 | 2043 |
|  | 10 | 5.91e-05 | 14980 | 17020 | 2040 | 34517766.49746193 | 34.518 |  |  |  |  |  |  |
|  | 11 | 5.91e-05 | 17020 | 19250 | 2230 | 37732656.5143824 | 37.733 |  |  |  |  |  |  |
|  | 12 | 5.91e-05 | 19250 | 21370 | 2120 | 35871404.39932318 | 35.871 |  |  |  |  |  |  |
|  | 13 | 5.91e-05 | 21370 | 23610 | 2240 | 37901861.252115056 | 37.902 |  |  |  |  |  |  |
|  | 14 | 5.91e-05 | 23610 | 25840 | 2230 | 37732656.5143824 | 37.733 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 3.91e-05 | 26050 | 23820 | 2230 | 57033248.08184143 | 57.033 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 2 | 3.91e-05 | 23820 | 21890 | 1930 | 49360613.810741685 | 49.361 |  |  |  |  |  |  |
|  | 3 | 3.91e-05 | 21890 | 19710 | 2180 | 55754475.7033248 | 55.754 |  |  |  |  |  |  |
|  | 4 | 3.91e-05 | 19710 | 17620 | 2090 | 53452685.42199488 | 53.453 |  |  |  |  |  |  |
| PEP2, 8-5 | 5 | 3.91e-05 | 17620 | 15630 | 1990 | 50895140.664961636 | 50.895 |  |  |  |  |  |  |
| Pos Stack | 6 | 3.91e-05 | 15630 | 13550 | 2080 | 53196930.94629156 | 53.197 |  | 17 |  |  |  |  |
| S/N 108 | 7 | 3.91e-05 | 13550 | 11600 | 1950 | 49872122.762148336 | 49.872 |  |  |  |  | V applied to stack:  25690 |  |
|  | 8 | 3.91e-05 | 11600 | 9520 | 2080 | 53196930.94629156 | 53.197 |  |  |  |  | I = .0000282 |  |
|  | 9 | 3.91e-05 | 9520 | 7340 | 2180 | 55754475.7033248 | 55.754 |  |  |  |  |  |  |
|  | 10 | 3.91e-05 | 7340 | 5245 | 2095 | 53580562.659846544 | 53.581 |  |  |  |  |  |  |
|  | 11 | 3.91e-05 | 5245 | 3235 | 2010 | 51406649.61636829 | 51.407 |  |  |  |  |  |  |
|  | 12 | 3.91e-05 | 3235 | 1270 | 1965 | 50255754.47570332 | 50.256 |  |  |  |  |  |  |
|  | 13 | 3.91e-05 | 1270 | 0 | 1270 | 32480818.41432225 | 32.481 |  |  |  | 1991 | 0 | 1991 |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  |  |  |  |
|  | 1 (top) | 2.19e-05 | 25790 | 24000 | 1790 | 81735159.8173516 | 81.735 |  |  |  |  |  |  |
|  | 2 | 2.19e-05 | 24000 | 22100 | 1900 | 86757990.8675799 | 86.758 |  |  |  |  |  |  |
|  | 3 | 2.19e-05 | 22100 | 20170 | 1930 | 88127853.88127854 | 88.128 |  |  |  |  |  |  |
|  | 4 | 2.19e-05 | 20170 | 18190 | 1980 | 90410958.90410958 | 90.411 |  |  |  |  |  |  |
| Spear 2 | 5 | 2.19e-05 | 18190 | 16100 | 2090 | 95433789.9543379 | 95.434 |  |  |  |  |  |  |
| S2 A+ | 6 | 2.19e-05 | 16100 | 14290 | 1810 | 82648401.82648401 | 82.648 |  | 18 |  |  |  |  |
| S/N 109 | 7 | 2.19e-05 | 14290 | 12760 | 1530 | 69863013.69863014 | 69.863 |  |  |  |  |  |  |
|  | 8 | 2.19e-05 | 12760 | 10900 | 1860 | 84931506.84931506 | 849.315 |  |  |  |  |  |  |
|  | 9 | 2.19e-05 | 10900 | 9350 | 1550 | 70776255.70776255 | 70.776 |  |  |  |  |  |  |
|  | 10 | 2.19e-05 | 9350 | 7370 | 1980 | 90410958.90410958 | 90.411 |  |  |  |  |  |  |
|  | 11 | 2.19e-05 | 7370 | 5714 | 1656 | 75616438.35616438 | 75.616 |  |  |  |  |  |  |
|  | 12 | 2.19e-05 | 5714 | 3994 | 1720 | 78538812.78538813 | 75.539 |  |  |  |  |  |  |
|  | 13 | 2.19e-05 | 3994 | 2024 | 1970 | 89954337.89954337 | 89.954 |  |  |  |  |  |  |
|  | 14 | 2.19e-05 | 2024 | 0 | 2024 | 92420091.32420091 | 92.42 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 6.89e-05 | 25560 | 23370 | 2190 | 31785195.936139334 | 31.785 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 2 | 6.89e-05 | 23370 | 21250 | 2120 | 30769230.76923077 | 30.769 |  |  |  |  |  |  |
|  | 3 | 6.89e-05 | 21250 | 19100 | 2150 | 31204644.412191585 | 31.205 |  |  |  |  |  |  |
|  | 4 | 6.89e-05 | 19100 | 17001 | 2099 | 30464441.219158202 | 30.464 |  |  |  |  |  |  |
| PEP 2, 8-5 | 5 | 6.89e-05 | 17001 | 14860 | 2141 | 31074020.31930334 | 31.074 |  |  |  |  |  |  |
| Pos Stack | 6 | 6.89e-05 | 14860 | 12640 | 2220 | 32220609.579100147 | 32.221 |  | 19 |  |  |  |  |
| S/N 106 | 7 | 6.89e-05 | 12640 | 10570 | 2070 | 30043541.364296082 | 30.044 |  |  |  |  | V applied to stack:  25540 |  |
|  | 8 | 6.89e-05 | 10570 | 8450 | 2120 | 30769230.76923077 | 30.769 |  |  |  |  | I = .0000387 |  |
|  | 9 | 6.89e-05 | 8450 | 6407 | 2043 | 29651669.085631352 | 29.652 |  |  |  |  |  |  |
|  | 10 | 6.89e-05 | 6407 | 4252 | 2155 | 31277213.352685053 | 31.277 |  |  |  |  |  |  |
|  | 11 | 6.89e-05 | 4252 | 2206 | 2046 | 29695210.449927434 | 29.695 |  |  |  |  |  |  |
|  | 12 | 6.89e-05 | 2206 | 0 | 2206 | 32017416.545718435 | 32.017 |  |  |  |  |  |  |
|  | 13 | 6.89e-05 | 0 | 0 | 0 | Short | Short |  |  |  | 1954 | 0 | 1954 |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  |  |  |  |
|  | 1 (top) | 3.26e-05 | 0 | 2089 | 2089 | 64079754.60122699 | 64.08 |  |  |  |  |  |  |
|  | 2 | 3.26e-05 | 2089 | 4116 | 2027 | 62177914.11042945 | 62.178 |  |  |  |  |  |  |
|  | 3 | 3.26e-05 | 4116 | 6202 | 2086 | 63987730.0613497 | 63.988 |  |  |  |  |  |  |
|  | 4 | 3.26e-05 | 6202 | 8180 | 1978 | 60674846.62576687 | 60.675 |  |  |  |  |  |  |
| PEP 2, 8-5 | 5 | 3.26e-05 | 8180 | 10130 | 1950 | 59815950.9202454 | 59.816 |  |  |  |  |  |  |
| Neg Stack | 6 | 3.26e-05 | 10130 | 12150 | 2020 | 61963190.18404908 | 61.693 |  | 20 |  |  |  |  |
| S/N 107 | 7 | 3.26e-05 | 12150 | 14070 | 1920 | 58895705.521472394 | 58.896 |  |  |  |  |  |  |
|  | 8 | 3.26e-05 | 14070 | 16190 | 2120 | 65030674.84662577 | 65.031 |  |  |  |  |  |  |
|  | 9 | 3.26e-05 | 16190 | 18160 | 1970 | 60429447.85276074 | 60.429 |  |  |  |  |  |  |
|  | 10 | 3.26e-05 | 18160 | 20130 | 1970 | 60429447.85276074 | 60.429 |  |  |  |  |  |  |
|  | 11 | 3.26e-05 | 20130 | 22010 | 1880 | 57668711.65644172 | 57.669 |  |  |  |  |  |  |
|  | 12 | 3.26e-05 | 22010 | 23730 | 1720 | 52760736.19631902 | 52.761 |  |  |  |  |  |  |
|  | 13 | 3.26e-05 | 23730 | 25780 | 2050 | 62883435.582822084 | 62.883 |  |  |  |  |  |  |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 0.000745 | 0 | 2724 | 2724 | 3656375.8389261747 | 3.656 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 2 | 0.000745 | 2724 | 5394 | 2670 | 3583892.6174496645 | 3.584 |  |  |  |  |  |  |
|  | 3 | 0.000745 | 5394 | 8040 | 2646 | 3551677.852348993 | 3.552 |  |  |  |  |  |  |
|  | 4 | 0.000745 | 8040 | 10750 | 2710 | 3637583.8926174496 | 3.368 |  |  |  |  |  |  |
| PEP 2, 8-5 | 5 | 0.000745 | 10750 | 13420 | 2670 | 3583892.6174496645 | 3.584 |  |  |  |  |  |  |
| Neg Stack | 6 | 0.000745 | 13420 | 16110 | 2690 | 3610738.255033557 | 3.611 |  | 21 |  |  |  |  |
| S/N 110 | 7 | 0.000745 | 16110 | 18800 | 2690 | 3610738.255033557 | 3.611 |  |  |  |  | V applied to stack:  26150 |  |
|  | 8 | 0.000745 | 18800 | 21500 | 2700 | 3624161.0738255032 | 3.624 |  |  |  |  | I = .0000135 |  |
|  | 9 | 0.000745 | 21500 | 21500 | 0 | Short | Short |  |  |  | 15260 | 17210 | 1950 |
|  | 10 | 0.000745 | 21500 | 23780 | 2280 | 3060402.6845637583 | 3.06 |  |  |  |  |  |  |
|  | 11 | 0.000745 | 23780 | 23780 | 0 | Short | Short |  |  |  | 18720 | 20240 | 1520 |
|  | 12 | 0.000745 | 23780 | 23780 | 0 | Short | Short |  |  |  | 20240 | 22480 | 2240 |
|  | 13 | 0.000745 | 23780 | 23780 | 0 | Short | Short |  |  |  | 22480 | 24460 | 1980 |
|  | 14 | 0.000745 | 23780 | 25990 | 2210 | 2966442.953020134 | 2.966 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 0.000138 | 0 | 2326 | 2326 | 16855072.463768117 | 16.855 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 2 | 0.000138 | 2326 | 4661 | 2335 | 16920289.855072465 | 16.92 |  |  |  |  |  |  |
|  | 3 | 0.000138 | 4661 | 6980 | 2319 | 16804347.826086957 | 16.804 |  |  |  |  |  |  |
|  | 4 | 0.000138 | 6980 | 9310 | 2330 | 16884057.971014492 | 16.884 |  |  |  |  |  |  |
| PEP 2, 8-5 | 5 | 0.000138 | 9310 | 11660 | 2350 | 17028985.50724638 | 17.029 |  |  |  |  |  |  |
| Neg Stack | 6 | 0.000138 | 11660 | 14110 | 2450 | 17753623.188405797 | 17.754 |  | 22 |  |  |  |  |
| S/N 111 | 7 | 0.000138 | 14110 | 16280 | 2170 | 15724637.681159422 | 15.725 |  |  |  |  | V applied to stack:  25760 |  |
|  | 8 | 0.000138 | 16280 | 18820 | 2540 | 18405797.101449277 | 18.406 |  |  |  |  | I = .0000298 |  |
|  | 9 | 0.000138 | 18820 | 18830 | 10 | 72463.76811594203 | Short |  |  |  | 16010 | 18010 | 2000 |
|  | 10 | 0.000138 | 18830 | 18830 | 0 | 0 | Short |  |  |  | 18010 | 19750 | 1740 |
|  | 11 | 0.000138 | 18830 | 21020 | 2190 | 15869565.217391305 | 15.87 |  |  |  |  |  |  |
|  | 12 | 0.000138 | 21020 | 23430 | 2410 | 17463768.11594203 | 17.464 |  |  |  |  |  |  |
|  | 13 | 0.000138 | 23430 | 25570 | 2140 | 15507246.376811596 | 15.507 |  |  |  |  |  |  |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 9.12e-05 | 0 | 2284 | 2284 | 25043859.649122808 | 25.044 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 2 | 9.12e-05 | 2284 | 4602 | 2318 | 25416666.666666668 | 25.417 |  |  |  |  |  |  |
|  | 3 | 9.12e-05 | 4602 | 6710 | 2108 | 23114035.0877193 | 23.114 |  |  |  |  |  |  |
|  | 4 | 9.12e-05 | 6710 | 8820 | 2110 | 23135964.912280705 | 23.136 |  |  |  |  |  |  |
| PEP 2, 8-5 | 5 | 9.12e-05 | 8820 | 11010 | 2190 | 24013157.894736845 | 24.013 |  |  |  |  |  |  |
| Neg Stack | 6 | 9.12e-05 | 11010 | 13320 | 2310 | 25328947.368421055 | 25.329 |  | 23 |  |  |  |  |
| S/N 122 | 7 | 9.12e-05 | 13230 | 15420 | 2190 | 24013157.894736845 | 24.013 |  |  |  |  | V applied to stack:  26.0 |  |
|  | 8 | 9.12e-05 | 15420 | 17760 | 2340 | 25657894.736842107 | 25.658 |  |  |  |  | I = .0000518 |  |
|  | 9 | 9.12e-05 | 17760 | 17770 | 10 | 109649.12280701756 | Short |  |  |  | 16040 | 18050 | 2010 |
|  | 10 | 9.12e-05 | 17770 | 19870 | 2100 | 23026315.789473686 | 23.026 |  |  |  |  |  |  |
|  | 11 | 9.12e-05 | 19870 | 21680 | 1810 | 19846491.228070177 | 19.846 |  |  |  |  |  |  |
|  | 12 | 9.12e-05 | 21680 | 23770 | 2090 | 22916666.666666668 | 22.917 |  |  |  |  |  |  |
|  | 13 | 9.12e-05 | 23770 | 26020 | 2250 | 24671052.63157895 | 24.671 |  |  |  |  |  |  |
|  | 14 | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. | No 14th stage. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced SCRs with previously used spare. |  |  |
|  | 1 (top) | 5.13e-05 | 25750 | 23540 | 2210 | 43079922.02729045 | 43.08 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 2 | 5.13e-05 | 23540 | 21930 | 1610 | 31384015.59454191 | 31.384 |  |  |  |  |  |  |
|  | 3 | 5.13e-05 | 21930 | 19800 | 2130 | 41520467.83625731 | 41.52 |  |  |  |  | V applied to stack:  25.840 |  |
|  | 4 | 5.13e-05 | 19800 | 17260 | 2540 | 49512670.56530214 | 49.513 |  |  |  |  | I = .0000294 |  |
| PEP 2, 8-5 | 5 | 5.13e-05 | 17260 | 17250 | 10 | 194931.7738791423 | Short |  |  |  | 17640 | 15650 | 1990 |
| Pos Stack | 6 | 5.13e-05 | 17250 | 15220 | 2030 | 39571150.09746589 | 39.571 |  | 24 |  |  |  |  |
| S/N 123 | 7 | 5.13e-05 | 15220 | 13830 | 1390 | 27095516.56920078 | 27.096 |  |  |  |  |  |  |
|  | 8 | 5.13e-05 | 13830 | 12310 | 1520 | 29629629.62962963 | 29.63 |  |  |  |  |  |  |
|  | 9 | 5.13e-05 | 12310 | 10540 | 1770 | 34502923.97660819 | 34.503 |  |  |  |  |  |  |
|  | 10 | 5.13e-05 | 10540 | 8530 | 2010 | 39181286.5497076 | 39.181 |  |  |  |  |  |  |
|  | 11 | 5.13e-05 | 8530 | 6500 | 2030 | 39571150.09746589 | 39.571 |  |  |  |  |  |  |
|  | 12 | 5.13e-05 | 6500 | 4265 | 2235 | 43567251.46198831 | 43.567 |  |  |  |  |  |  |
|  | 13 | 5.13e-05 | 4265 | 2130 | 2135 | 41617933.72319688 | 41.618 |  |  |  |  |  |  |
|  | 14 | 5.13e-05 | 2130 | 0 | 2130 | 41520467.83625731 | 41.52 |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms | SCR Ohms Rounded M Ohms |  |  |  | Replaced MOV + SCR with previously used spare. |  |  |
|  | 1 (top) | 1.16e-05 | 25870 | 23810 | 2060 | 177586206.8965517 | 17.759 |  |  |  | Top Plate | Bottom Plate | Volts Δ across SCR |
|  | 2 | 1.16e-05 | 23810 | 21800 | 2010 | 173275862.0689655 | 17.328 |  |  |  |  |  |  |
|  | 3 | 1.16e-05 | 21800 | 19690 | 2110 | 181896551.72413793 | 18.19 |  |  |  |  |  |  |
|  | 4 | 1.16e-05 | 19690 | 17450 | 2240 | 193103448.27586207 | 19.31 |  |  |  |  |  |  |
| Shop Stack | 5 | 1.16e-05 | 17540 | 15580 | 1960 | 168965517.2413793 | 16.897 |  |  |  |  |  |  |
| Pos Stack | 6 | 1.16e-05 | 15580 | 13490 | 2090 | 180172413.79310343 | 18.017 |  | 25 |  |  |  |  |
| S/N 124 | 7 | 1.16e-05 | 13490 | 11460 | 2030 | 175000000 | 17.5 |  |  |  |  |  |  |
|  | 8 | 1.16e-05 | 11460 | 9670 | 1790 | 154310344.8275862 | 15.431 |  |  |  |  |  |  |
|  | 9 | 1.16e-05 | 9670 | 7930 | 1740 | 150000000 | 15 |  |  |  |  | V applied to stack:  25.730 |  |
|  | 10 | 1.16e-05 | 7930 | 6334 | 1596 | 137586206.89655173 | 13.759 |  |  |  |  | I = .0000101 |  |
|  | 11 | 1.16e-05 | 6334 | 4726 | 1608 | 138620689.6551724 | 13.862 |  |  |  |  |  |  |
|  | 12 | 1.16e-05 | 4726 | 3974 | 752 | 64827586.20689655 | MOV Bad! |  |  |  | 5146 | 3596 | 1550 |
|  | 13 | 1.16e-05 | 3974 | 2006 | 1968 | 169655172.4137931 | 16.966 |  |  |  |  |  |  |
|  | 14 | 1.16e-05 | 2006 | 0 | 2006 | 172931034.4827586 | 17.293 |  |  |  |  |  |  |


## Sheet: Sheet22

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 1 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 2 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 3 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 4 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 5 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 6 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 7 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 8 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 9 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 10 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 11 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 12 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |


## Sheet: Sheet23

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack Removed from Spear 2 Phase Tank July 23, 2020 |  |  |  | Gate Trigger Boards Off. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 14.8 uA |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current (A) | Volts on top plate KV | Volts on bottom plate KV | Volts Δ across SCR | SCR ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 1 (top) | 1.48e-05 | 0 | 2066.4 | 2066.4 | 139621621.6216216 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 2 | 1.48e-05 | 2066.4 | 3746.7 | 1680.2999999999997 | 113533783.78378376 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 3 | 1.48e-05 | 3746.7 | 5313.5 | 1566.8000000000002 | 105864864.86486487 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 4 | 1.48e-05 | 5313.5 | 7088.2 | 1774.6999999999998 | 119912162.16216214 |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Spear 2 | 5 | 1.48e-05 | 7088.2 | 8245 | 1156.8000000000002 | 78162162.16216217 |  |  |  |  |  |  |  |  |  |  |  |  |  |
| S1 A - | 6 | 1.48e-05 | 8245 | 9404 | 1159 | 78310810.8108108 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 7 | 1.48e-05 | 9404 | 11184 | 1780 | 120270270.27027026 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 8 | 1.48e-05 | 11184 | 13136 | 1952 | 131891891.89189188 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 9 | 1.48e-05 | 13136 | 15164 | 2028 | 137027027.027027 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 10 | 1.48e-05 | 15164 | 17222 | 2058 | 139054054.05405405 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 11 | 1.48e-05 | 17222 | 19255 | 2033 | 137364864.86486486 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 12 | 1.48e-05 | 19255 | 21022 | 1767 | 119391891.89189188 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 13 | 1.48e-05 | 21022 | 23129 | 2107 | 142364864.86486486 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 14 | 1.48e-05 | 23129 | 25305 | 2176 | 147027027.027027 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Hipot of positive phase stack with cell to cell voltages measured.  31 July 2020 |  |  |  | Gate Trigger Boards Attached! |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 136.51 uA |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | SCR # | Series Current (A) | Volts on top plate KV | Volts on bottom plate KV | Volts Δ across SCR | SCR ohms (rounded) |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 1 (top) | 0.00013651 | 24.91 | 22.82 | 2.09 KV | 15.3  M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 2 | 0.00013651 | 22.82 | 20.87 | 1.95 KV | 15.3 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 3 | 0.00013651 | 20.87 | 18.83 | 2.04 KV | 15 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 4 | 0.00013651 | 18.83 | 16.9 | 1.93 KV | 14.1 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 5 | 0.00013651 | 16.9 | 14.95 | 1.95 KV | 15.3 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
| PEP II 8-5 Pos. | 6 | 0.00013651 | 14.95 | 12.96 | 1.99 KV | 14.6 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 7 | 0.00013651 | 12.96 | 11.12 | 1.84 KV | 13.5 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 8 | 0.00013651 | 11.12 | 9.12 | 2 KV | 14.7 M ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 9 | 0.00013651 | 9.12 | 7.13 | 1.99 KV | 14.6 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 10 | 0.00013651 | 7.13 | 5.199 | 1.931 KV | 14.1 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 11 | 0.00013651 | 5.199 | 3.253 | 1.946 KV | 14.3 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 12 | 0.00013651 | 3.253 | 1.273 | 1.98 KV | 14.5 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | 13 | 0.00013651 | 1.273 | 0 | 1.273 KV | 9.3 M Ohms |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Test Performed Aug 16, 2020.  Trigger boards removed. |  |  |  |  |  |  |  |  |  | Test Performed Aug 18, 2020.  Trigger boards installed. |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR Ohms | Ohms Rounded M Ohms |  |  |  |  | Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR Ohms | Ohms Rounded M Ohms |
|  | 1 (top) | 2.26e-05 | 0 | 1899 | 1899 | 84026548.67256637 | 84.027 |  |  |  |  |  | 1 (top) | 9.29e-05 | 0 | 1958 | 1958 | 21076426.26480086 | 21.076 |
|  | 2 | 2.26e-05 | 1899 | 3471 | 1572 | 69557522.1238938 | 69.558 |  |  |  |  |  | 2 | 9.29e-05 | 1958 | 3819 | 1861 | 20032292.787944026 | 20.032 |
|  | 3 | 2.26e-05 | 3471 | 5387 | 1916 | 84778761.0619469 | 84.779 |  |  |  |  |  | 3 | 9.29e-05 | 3819 | 5634 | 1815 | 19537136.70613563 | 19.537 |
|  | 4 | 2.26e-05 | 5387 | 6465 | 1078 | 47699115.04424778 | 47.699 |  |  |  |  |  | 4 | 9.29e-05 | 5634 | 7557 | 1923 | 20699677.072120562 | 20.7 |
| Spear 2 | 5 | 2.26e-05 | 6465 | 8470 | 2005 | 88716814.15929203 | 88.717 |  |  |  |  | Spear 2 | 5 | 9.29e-05 | 7557 | 9452 | 1895 | 20398277.71797632 | 20.398 |
| S2 C- | 6 | 2.26e-05 | 8470 | 10597 | 2127 | 94115044.24778761 | 94.115 |  |  |  |  | S2 C- | 6 | 9.29e-05 | 9452 | 11432 | 1980 | 21313240.04305705 | 21.313 |
|  | 7 | 2.26e-05 | 10597 | 12713 | 2116 | 93628318.5840708 | 93.628 |  |  |  |  |  | 7 | 9.29e-05 | 11432 | 13328 | 1896 | 20409041.98062433 | 20.041 |
|  | 8 | 2.26e-05 | 12713 | 14566 | 1853 | 81991150.44247787 | 81.991 |  |  |  |  |  | 8 | 9.29e-05 | 13328 | 15136 | 1808 | 19461786.86759957 | 19.462 |
|  | 9 | 2.26e-05 | 14566 | 16503 | 1937 | 85707964.60176991 | 85.708 |  |  |  |  |  | 9 | 9.29e-05 | 15136 | 16861 | 1725 | 18568353.067814857 | 18.568 |
|  | 10 | 2.26e-05 | 16503 | 18687 | 2184 | 96637168.14159292 | 96.637 |  |  |  |  |  | 10 | 9.29e-05 | 16861 | 18854 | 1993 | 21453175.457481164 | 21.453 |
|  | 11 | 2.26e-05 | 18687 | 20419 | 1732 | 76637168.14159292 | 76.637 |  |  |  |  |  | 11 | 9.29e-05 | 18854 | 20522 | 1668 | 17954790.096878365 | 17.948 |
|  | 12 | 2.26e-05 | 20419 | 22136 | 1717 | 75973451.32743363 | 75.973 |  |  |  |  |  | 12 | 9.29e-05 | 20522 | 22252 | 1730 | 18622174.3810549 | 18.622 |
|  | 13 | 2.26e-05 | 22136 | 23576 | 1440 | 63716814.159292035 | 63.717 |  |  |  |  |  | 13 | 9.29e-05 | 22252 | 23709 | 1457 | 15683530.678148547 | 15.684 |
|  | 14 | 2.26e-05 | 23576 | 25145 | 1569 | 69424778.76106195 | 69.425 |  |  |  |  |  | 14 | 9.29e-05 | 23709 | 25298 | 1589 | 17104413.347685684 | 17.104 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | S2 C- w/ no trigger boards | S2 C- without trigger boards |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | Ohms Rounded M Ohms | Ohms Rounded M Ohms |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 84.027 | 21.076 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 69.558 | 20.032 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 84.779 | 19.537 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 47.699 | 20.7 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 88.717 | 20.398 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 94.115 | 21.313 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 93.628 | 20.041 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 81.991 | 19.462 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 85.708 | 18.568 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 96.637 | 21.453 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 76.637 | 17.948 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 75.973 | 18.622 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 63.717 | 15.684 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 69.425 | 17.104 |  |  |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet24

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  | Test Performed Aug 16, 2020.  Trigger boards removed. |  |  |  |  |  |  |  |  |  | Test Performed Aug 18, 2020.  Trigger boards installed. |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack Position | SCR # | Series Current (Amps) | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR Ohms | Ohms Rounded M Ohms |  |  |  |  | Stack Position | SCR # | Series Current (Amps) | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR Ohms | Ohms Rounded M Ohms |
|  |  | 1 (top) | 2.26e-05 | 0 | 1899 | 1899 | 84026548.67256637 | 84.027 |  |  |  |  |  | 1 (top) | 9.29e-05 | 0 | 1958 | 1958 | 21076426.26480086 | 21.076 |
|  |  | 2 | 2.26e-05 | 1899 | 3471 | 1572 | 69557522.1238938 | 69.558 |  |  |  |  |  | 2 | 9.29e-05 | 1958 | 3819 | 1861 | 20032292.787944026 | 20.032 |
|  |  | 3 | 2.26e-05 | 3471 | 5387 | 1916 | 84778761.0619469 | 84.779 |  |  |  |  |  | 3 | 9.29e-05 | 3819 | 5634 | 1815 | 19537136.70613563 | 19.537 |
|  |  | 4 | 2.26e-05 | 5387 | 6465 | 1078 | 47699115.04424778 | 47.699 |  |  |  |  |  | 4 | 9.29e-05 | 5634 | 7557 | 1923 | 20699677.072120562 | 20.7 |
|  | Spear 2 | 5 | 2.26e-05 | 6465 | 8470 | 2005 | 88716814.15929203 | 88.717 |  |  |  |  | Spear 2 | 5 | 9.29e-05 | 7557 | 9452 | 1895 | 20398277.71797632 | 20.398 |
|  | S2 C- | 6 | 2.26e-05 | 8470 | 10597 | 2127 | 94115044.24778761 | 94.115 |  |  |  |  | S2 C- | 6 | 9.29e-05 | 9452 | 11432 | 1980 | 21313240.04305705 | 21.313 |
|  |  | 7 | 2.26e-05 | 10597 | 12713 | 2116 | 93628318.5840708 | 93.628 |  |  |  |  |  | 7 | 9.29e-05 | 11432 | 13328 | 1896 | 20409041.98062433 | 20.041 |
|  |  | 8 | 2.26e-05 | 12713 | 14566 | 1853 | 81991150.44247787 | 81.991 |  |  |  |  |  | 8 | 9.29e-05 | 13328 | 15136 | 1808 | 19461786.86759957 | 19.462 |
|  |  | 9 | 2.26e-05 | 14566 | 16503 | 1937 | 85707964.60176991 | 85.708 |  |  |  |  |  | 9 | 9.29e-05 | 15136 | 16861 | 1725 | 18568353.067814857 | 18.568 |
|  |  | 10 | 2.26e-05 | 16503 | 18687 | 2184 | 96637168.14159292 | 96.637 |  |  |  |  |  | 10 | 9.29e-05 | 16861 | 18854 | 1993 | 21453175.457481164 | 21.453 |
|  |  | 11 | 2.26e-05 | 18687 | 20419 | 1732 | 76637168.14159292 | 76.637 |  |  |  |  |  | 11 | 9.29e-05 | 18854 | 20522 | 1668 | 17954790.096878365 | 17.948 |
|  |  | 12 | 2.26e-05 | 20419 | 22136 | 1717 | 75973451.32743363 | 75.973 |  |  |  |  |  | 12 | 9.29e-05 | 20522 | 22252 | 1730 | 18622174.3810549 | 18.622 |
|  |  | 13 | 2.26e-05 | 22136 | 23576 | 1440 | 63716814.159292035 | 63.717 |  |  |  |  |  | 13 | 9.29e-05 | 22252 | 23709 | 1457 | 15683530.678148547 | 15.684 |
|  |  | 14 | 2.26e-05 | 23576 | 25145 | 1569 | 69424778.76106195 | 69.425 |  |  |  |  |  | 14 | 9.29e-05 | 23709 | 25298 | 1589 | 17104413.347685684 | 17.104 |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  | S2 C- w/ no trigger boards | S2 C- without trigger boards |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  | Stack Position | SCR # | Ohms Rounded M Ohms | Ohms Rounded M Ohms |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 1 (top) | 84.027 | 21.076 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 2 | 69.558 | 20.032 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 3 | 84.779 | 19.537 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 4 | 47.699 | 20.7 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  | Spear 2 | 5 | 88.717 | 20.398 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  | S2 C- | 6 | 94.115 | 21.313 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 7 | 93.628 | 20.041 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 8 | 81.991 | 19.462 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 9 | 85.708 | 18.568 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 10 | 96.637 | 21.453 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 11 | 76.637 | 17.948 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 12 | 75.973 | 18.622 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 13 | 63.717 | 15.684 |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | 14 | 69.425 | 17.104 |  |  |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet25

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | Spear 2 Phase Stack Tests Due to Spear 2 Failure on Sept. 2, 2020 |  |  |  | Klystron Replacement:  Marconi failed; Phillips/SLAC klystron installed in building 132, Spear ring. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack |  | Test Voltage KV | Series Current uA | Stack Ohms | Stack Ohms Rounded | Failed Parts (Visual) * | Gate Drive Triggers | Over Volts Test KV |  |  |
|  |  |  |  |  |  | Meg Ohms |  |  |  |  |  |
|  | S2 C- |  | 25800 | 3.62e-05 | 712707182.320442 | 712.707 | 2 board diodes stage 11. | Good | 35.9 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 C+ |  | 25320 | 0.000271 | 93431734.31734318 | 93.432 | Stage 9 SCR shorted. | Good | 30.4 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 A- |  | 25430 | 0.0001862 | 136573576.79914072 | 136.574 | None | Good | 33.3 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 A+ |  | 25400 | 6.59e-05 | 385432473.44461304 | 385.432 | Stage 6 SCR shorted. | Good | 33.9 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 B+ |  | 25640 | 0.000144 | 178055555.55555555 | 178.056 | None | Good | 32.9 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 B- |  | 25290 | 0.0002092 | 120889101.33843213 | 120.889 | Stage 10 SCR shorted. | Good | 30.6 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 B- |  | 25290 | 6.41e-05 | 394539781.59126365 | 394.54 | None | Good | 35.9 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 C+ |  | 25620 | 0.000164 | 156219512.19512194 | 156.22 | None | Good | 32.9 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 C- |  | 25610 | 0.0001158 | 221157167.53022453 | 221.157 | None | Good | 32.5 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 A+ |  | 25530 | 0.0001423 | 179409697.82150388 | 179.41 | None | Good | 35.6 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 B+ |  | 25580 | 0.0001397 | 183106657.12240514 | 183.107 | None | Good | 32.9 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 A- |  | 25400 | 0.0001507 | 168546781.6854678 | 168.547 | None | Good | 32.1 |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | * |  |  |  |  |  |  |  |  |  |


## Sheet: Sheet26

|  |  | Crowbar Stack Tests of Spear Crowbar Stacks Removed From Spear 2 RF HVPS on 6 August, 2020 |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad |  |  |
| 1 | 1 | 0.89 | 0 | 4399 | 4399 | 1.03 |  |  | Good |  |  |
| 1 | 2 | 0.89 | 4399 | 6970 | 2571 | 1.437+ |  |  | Bad |  |  |
| 1 | 3 | 0.89 | 6970 | 11370 | 4400 | 1.036 | Good | 43.4 KV | Good |  |  |
| 1 | 4 | 0.89 | 11370 | 15880 | 4510 | 1.014 |  |  | Good |  |  |
| 1 | 5 | 0.89 | 15880 | 20370 | 4490 | 1.018 |  |  | Good |  |  |
| 1 | 6 | 0.89 | 20370 | 25010 | 4640 | 1.012 |  |  | Good |  |  |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad |  |  |
| 2 | 1 | 0.875 | 0 | 4382 | 4382 | 1.013 |  |  | Good |  |  |
| 2 | 2 | 0.875 | 4382 | 8570 | 4188 | 1.02 |  |  | Good |  |  |
| 2 | 3 | 0.875 | 8570 | 11950 | 3380 | 1.220+ | Good | 42.6 KV | Bad |  |  |
| 2 | 4 | 0.875 | 11950 | 16160 | 4210 | 1.041 |  |  | Good |  |  |
| 2 | 5 | 0.875 | 16160 | 20510 | 4350 | 1.016 |  |  | Good |  |  |
|  | 6 | 0.875 | 20510 | 24920 | 4410 | 1.014 |  |  | Good |  |  |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad |  |  |
| 3 | 1 | 0.907 | 0 | 4502 | 4502 | 1.015 |  |  | Good |  |  |
| 3 | 2 | 0.907 | 4502 | 8750 | 4248 | 1.026 |  |  | Good |  |  |
| 3 | 3 | 0.907 | 8570 | 13140 | 4570 | 1.011 | Good | 41 KV | Good |  |  |
| 3 | 4 | 0.907 | 13140 | 17560 | 4420 | 1.021 |  |  | Good |  |  |
| 3 | 5 | 0.907 | 17560 | 22000 | 4440 | 1.018 |  |  | Good |  |  |
| 3 | 6 | 0.907 | 22000 | 25060 | 3060 | 1.852+ |  |  | Bad |  |  |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad |  |  |
| 4 | 1 | 0.91 | 0 | 4505 | 4505 | 1.017 |  |  | Good |  |  |
| 4 | 2 | 0.91 | 4505 | 8840 | 4325 | 1.024 |  |  | Good |  |  |
| 4 | 3 | 0.91 | 8840 | 13130 | 4290 | 1.044 | Good | 44.4 KV | Good |  |  |
| 4 | 4 | 0.91 | 13130 | 17510 | 4380 | 1.019 |  |  | Good |  |  |
| 4 | 5 | 0.91 | 17510 | 21970 | 4460 | 1.017 |  |  | Good |  |  |
| 4 | 6 | 0.91 | 21970 | 25760 | 3790 | 1.271+ |  |  | Bad |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Crowbar Stack Tests of Repaired Spear Crowbar Stacks Removed From Spear 2 RF HVPS on 6 August, 2020 |  |  |  |  |  |  |  |  |  |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad | Replacement Ser #/DC | Bad SCR S/N Removed |
| 1 | 1 | 0.848 | 0 | 4130 | 4130 | 1.034 |  |  | Good |  |  |
| 1 | 2 | 0.848 | 4130 | 8250 | 4120 | 1.015 |  |  | Good | 5315/20T9 | 3359/No DC |
| 1 | 3 | 0.848 | 8250 | 12330 | 4080 | 1.032 | Good | 44.1 | Good |  |  |
| 1 | 4 | 0.848 | 12330 | 16490 | 4160 | 1.004 |  |  | Good |  |  |
| 1 | 5 | 0.848 | 16490 | 20690 | 4200 | 1.02 |  |  | Good |  |  |
| 1 | 6 | 0.848 | 20690 | 25010 | 4320 | 1.008 |  |  | Good |  |  |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad | Replacement Ser #/DC | Bad SCR S/N Removed |
| 2 | 1 | 0.847 | 0 | 4273 | 4273 | 1.013 |  |  | Good |  |  |
| 2 | 2 | 0.847 | 4273 | 8290 | 4017 | 1.035 |  |  | Good |  |  |
| 2 | 3 | 0.847 | 8290 | 12440 | 4150 | 1.008 | Good | 43 KV | Good | 5312/20T9 | 2874/13R8 |
| 2 | 4 | 0.847 | 12440 | 16600 | 4160 | 1.037 |  |  | Good |  |  |
| 2 | 5 | 0.847 | 16600 | 20780 | 4180 | 1.007 |  |  | Good |  |  |
| 2 | 6 | 0.847 | 20780 | 25120 | 4340 | 0.994 |  |  | Good |  |  |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad | Replacement Ser #/DC | Bad SCR S/N Removed |
| 3 | 1 | 0.86 | 0 | 4273 | 4273 | 1.008 |  |  | Good |  |  |
| 3 | 2 | 0.86 | 4273 | 8290 | 4017 | 1.049 |  |  | Good |  |  |
| 3 | 3 | 0.86 | 8290 | 12440 | 4150 | 1.038 | Good | 41.6 KV | Good |  |  |
| 3 | 4 | 0.86 | 12440 | 16600 | 4160 | 1.025 |  |  | Good |  |  |
| 3 | 5 | 0.86 | 16600 | 20780 | 4180 | 1.028 |  |  | Good |  |  |
| 3 | 6 | 0.86 | 20780 | 25120 | 4340 | 1.025 |  |  | Good | 5388/21T9 | 5653/10S5 |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad | Replacement Ser #/DC | Bad SCR S/N Removed |
| 4 | 1 | 0.853 | 0 | 4255 | 4255 | 0.998 |  |  | Good |  |  |
| 4 | 2 | 0.853 | 4255 | 8330 | 4075 | 1.035 |  |  | Good |  |  |
| 4 | 3 | 0.853 | 8330 | 12380 | 4055 | 1.049 | Good | 42.8 KV | Good |  |  |
| 4 | 4 | 0.853 | 12380 | 16570 | 4190 | 1.018 |  |  | Good |  |  |
| 4 | 5 | 0.853 | 16570 | 20810 | 4240 | 1.016 |  |  | Good |  |  |
| 4 | 6 | 0.853 | 20810 | 25110 | 4300 | 1.025 |  |  | Good | 5316/20T9 | 3360/10S5 |


## Sheet: PhsStackTemplate

| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 1 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 2 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | SCR ohms (rounded) | Good/Bad |  |  |
|  | 1 (top) |  |  |  |  |  |  |  |  |
|  | 2 |  |  |  |  |  |  |  |  |
|  | 3 |  |  |  |  |  |  |  |  |
|  | 4 |  |  |  |  |  |  |  |  |
|  | 5 |  |  |  |  |  |  |  |  |
|  | 6 |  |  |  |  |  |  |  | 3 |
|  | 7 |  |  |  |  |  |  |  |  |
|  | 8 |  |  |  |  |  |  |  |  |
|  | 9 |  |  |  |  |  |  |  |  |
|  | 10 |  |  |  |  |  |  |  |  |
|  | 11 |  |  |  |  |  |  |  |  |
|  | 12 |  |  |  |  |  |  |  |  |
|  | 13 |  |  |  |  |  |  |  |  |
|  | 14 |  |  |  |  |  |  |  |  |


## Sheet: Sheet 27

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | Spear 2 Phase Stack Tests Due to Spear 2 Failure on Sept. 2, 2020 |  |  |  | Klystron Replacement:  Marconi failed; Phillips/SLAC klystron installed in building 132, Spear ring. |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | Stack |  | Test Voltage KV | Series Current uA | Stack Ohms | Stack Ohms Rounded | Failed Parts (Visual) * | Gate Drive Triggers | Over Volts Test KV |  |  |
|  |  |  |  |  |  | Meg Ohms |  |  |  |  |  |
|  | S2 C- |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 C+ |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 A- |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 A+ |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 B+ |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S2 B- |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 B- |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 C+ |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 C- |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 A+ |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 B+ |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  | S1 A- |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | * |  |  |  |  |  |  |  |  |  |


## Sheet: PhaseStacks

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | Spear 1 RF HVPS Phase Control Stack Tests and Repairs, August 17,  2022 |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 23.9 uA | 0 | 2001 | 2001 |  |  |  |  | Replaced twelve Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 20.4 uA |
|  | 2 | 23.9 uA | 2001 | 3985 | 1984 |  |  |  |  | Replaced one 2500 volt MOV in stage 10. |  |  |  |  |
|  | 3 | 23.9 uA | 3985 | 5983 | 1998 |  |  |  |  |  |  |  |  |  |
|  | 4 | 23.9 uA | 5983 | 7884 | 1901 |  |  |  |  |  |  |  |  |  |
|  | 5 | 23.9 uA | 7884 | 9810 | 1926 |  |  |  |  |  |  |  |  |  |
| S/N 111 | 6 | 23.9 uA | 9810 | 11707 | 1897 |  |  | 1 |  |  |  |  |  |  |
| S1 A- | 7 | 23.9 uA | 11707 | 13487 | 1780 |  |  |  |  |  |  |  |  |  |
|  | 8 | 23.9 uA | 13487 | 15476 | 1989 |  |  |  |  |  |  |  |  |  |
|  | 9 | 23.9 uA | 15476 | 17507 | 2031 |  |  |  |  |  |  |  |  |  |
|  | 10 | 23.9 uA | 17507 | 19056 | 1549 |  |  |  |  |  |  |  |  |  |
|  | 11 | 23.9 uA | 19056 | 20934 | 1878 |  |  |  |  |  |  |  |  |  |
|  | 12 | 23.9 uA | 20934 | 23101 | 2167 |  |  |  |  |  |  |  |  |  |
|  | 13 | 23.9 uA | 23101 | 25161 | 2060 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13 stage stack. |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 26.6 uA | 0 | 2040 | 2040 |  |  |  |  | No Repairs |  |  |  |  |
|  | 2 | 26.6 uA | 2040 | 4041 | 2001 |  |  |  |  |  |  |  |  |  |
|  | 3 | 26.6 uA | 4041 | 5988 | 1947 |  |  |  |  |  |  |  |  |  |
|  | 4 | 26.6 uA | 5988 | 7949 | 1961 |  |  |  |  |  |  |  |  |  |
|  | 5 | 26.6 uA | 7949 | 9822 | 1873 |  |  |  |  |  |  |  |  |  |
| S/N 107 | 6 | 26.6 uA | 9822 | 11728 | 1906 |  |  | 2 |  |  |  |  |  |  |
| S1 C- | 7 | 26.6 uA | 11728 | 13610 | 1882 |  |  |  |  |  |  |  |  |  |
|  | 8 | 26.6 uA | 13610 | 15677 | 2067 |  |  |  |  |  |  |  |  |  |
|  | 9 | 26.6 uA | 15677 | 17571 | 1894 |  |  |  |  |  |  |  |  |  |
|  | 10 | 26.6 uA | 17571 | 19474 | 1903 |  |  |  |  |  |  |  |  |  |
|  | 11 | 26.6 uA | 19474 | 21253 | 1779 |  |  |  |  |  |  |  |  |  |
|  | 12 | 26.6 uA | 21253 | 23016 | 1763 |  |  |  |  |  |  |  |  |  |
|  | 13 | 26.6 uA | 23016 | 25092 | 2076 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13 stage stack. |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 13.1 uA | 25172 | 23223 | 1949 |  |  |  |  | Replaced twelve Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 8.2 uA |
|  | 2 | 13.1 uA | 23223 | 21264 | 1959 |  |  |  |  | Replaced four 2500 volt MOVs in stages 5,6, 11, and 12.  Replaced 2 SCRs in stages 5 + 11. |  |  |  |  |
|  | 3 | 13.1 uA | 21264 | 19156 | 2108 |  |  |  |  |  |  |  |  |  |
|  | 4 | 13.1 uA | 19156 | 16994 | 2162 |  |  |  |  |  |  |  |  |  |
|  | 5 | 13.1 uA | 16994 | 15708 | 1286 |  |  |  |  |  |  |  |  |  |
| S/N 124 | 6 | 13.1 uA | 15708 | 14223 | 1485 |  |  | 3 |  |  |  |  |  |  |
| S1 A+ | 7 | 13.1 uA | 14223 | 12205 | 2018 |  |  |  |  |  |  |  |  |  |
|  | 8 | 13.1 uA | 12205 | 10394 | 1811 |  |  |  |  |  |  |  |  |  |
|  | 9 | 13.1 uA | 10394 | 8651 | 1743 |  |  |  |  |  |  |  |  |  |
|  | 10 | 13.1 uA | 8651 | 6862 | 1789 |  |  |  |  |  |  |  |  |  |
|  | 11 | 13.1 uA | 6862 | 5432 | 1430 |  |  |  |  |  |  |  |  |  |
|  | 12 | 13.1 uA | 5432 | 3921 | 1511 |  |  |  |  |  |  |  |  |  |
|  | 13 | 13.1 uA | 3921 | 1973 | 1948 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13.1 uA | 1973 | 0 | 1973 |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 43.2 uA | 25216 | 23649 | 1567 |  |  |  |  | Replaced five 2500 volt MOVs and 1 SCR in stage 5. |  |  |  | 10.7 uA |
|  | 2 | 43.2 uA | 23649 | 22016 | 1633 |  |  |  |  |  |  |  |  |  |
|  | 3 | 43.2 uA | 22016 | 20596 | 1420 |  |  |  |  |  |  |  |  |  |
|  | 4 | 43.2 uA | 20596 | 18573 | 2023 |  |  |  |  |  |  |  |  |  |
|  | 5 | 43.2 uA | 18573 | 18163 | 406 |  |  |  |  |  |  |  |  |  |
| S/N 122 | 6 | 43.2 uA | 18163 | 15992 | 2171 |  |  | 4 |  |  |  |  |  |  |
| S2 B+ | 7 | 43.2 uA | 15992 | 14318 | 1674 |  |  |  |  |  |  |  |  |  |
|  | 8 | 43.2 uA | 14318 | 12025 | 2293 |  |  |  |  |  |  |  |  |  |
|  | 9 | 43.2 uA | 12025 | 9988 | 2037 |  |  |  |  |  |  |  |  |  |
|  | 10 | 43.2 uA | 9988 | 7852 | 2136 |  |  |  |  |  |  |  |  |  |
|  | 11 | 43.2 uA | 7852 | 5866 | 1986 |  |  |  |  |  |  |  |  |  |
|  | 12 | 43.2 uA | 5866 | 3886 | 1980 |  |  |  |  |  |  |  |  |  |
|  | 13 | 43.2 uA | 3886 | 1735 | 2151 |  |  |  |  |  |  |  |  |  |
|  | 14 | 43.2 uA | 1735 | 0 | 1735 |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 955 uA | 25441 | 22948 | 2493 |  |  |  |  | Replaced 14 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 99.7 uA |
|  | 2 | 955 uA | 22948 | 22931 | 17 (Short) |  |  |  |  | Replaced three 2500 volt MOVs and 3 SCRs in shorted cells. |  |  |  | Boards on. |
|  | 3 | 955 uA | 22931 | 20468 | 2463 |  |  |  |  |  |  |  |  |  |
|  | 4 | 955 uA | 20468 | 20468 | 0 (Short) |  |  |  |  |  |  |  |  |  |
|  | 5 | 955 uA | 20468 | 17855 | 2613 |  |  |  |  |  |  |  |  |  |
| S/N 101 | 6 | 955 uA | 17855 | 17855 | 0 (Short) |  |  | 5 |  |  |  |  |  |  |
| S1 C+ | 7 | 955 uA | 17855 | 15305 | 2550 |  |  |  |  |  |  |  |  |  |
|  | 8 | 955 uA | 15305 | 12733 | 2572 |  |  |  |  |  |  |  |  |  |
|  | 9 | 955 uA | 12233 | 10355 | 1878 |  |  |  |  |  |  |  |  |  |
|  | 10 | 955 uA | 10355 | 7830 | 2525 |  |  |  |  |  |  |  |  |  |
|  | 11 | 955 uA | 7830 | 5350 | 2480 |  |  |  |  |  |  |  |  |  |
|  | 12 | 955 uA | 5350 | 2664 | 2686 |  |  |  |  |  |  |  |  |  |
|  | 13 | 955 uA | 2664 | 0 | 2664 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13 stage stack. |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 35.8 uA | 25178 | 23411 | 1767 |  |  |  |  | Replaced 14 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 21.6 uA |
|  | 2 | 35.8 uA | 23411 | 21585 | 1826 |  |  |  |  | Replaced 1 D54 3 amp diode on gate drive board. |  |  |  |  |
|  | 3 | 35.8 uA | 21585 | 19551 | 2034 |  |  |  |  | Replaced four 2500 volt MOVs. |  |  |  |  |
|  | 4 | 35.8 uA | 19551 | 17636 | 1915 |  |  |  |  |  |  |  |  |  |
|  | 5 | 35.8 uA | 17636 | 15488 | 2148 |  |  |  |  |  |  |  |  |  |
| S/N 109 | 6 | 35.8 uA | 15488 | 13655 | 1833 |  |  | 6 |  |  |  |  |  |  |
| S1 B+ | 7 | 35.8 uA | 13655 | 12207 | 1448 |  |  |  |  |  |  |  |  |  |
|  | 8 | 35.8 uA | 12207 | 10111 | 2096 |  |  |  |  |  |  |  |  |  |
|  | 9 | 35.8 uA | 10111 | 8451 | 1660 |  |  |  |  |  |  |  |  |  |
|  | 10 | 35.8 uA | 8451 | 6247 | 2204 |  |  |  |  |  |  |  |  |  |
|  | 11 | 35.8 uA | 6247 | 4642 | 1605 |  |  |  |  |  |  |  |  |  |
|  | 12 | 35.8 uA | 4642 | 3334 | 1308 |  |  |  |  |  |  |  |  |  |
|  | 13 | 35.8 uA | 3334 | 1337 | 1997 |  |  |  |  |  |  |  |  |  |
|  | 14 | 35.8 uA | 1337 | 0 | 1337 |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 43.7 uA | 0 | 1982 | 1982 |  |  |  |  | No Repairs |  |  |  |  |
|  | 2 | 43.7 uA | 1982 | 3987 | 2005 |  |  |  |  |  |  |  |  |  |
|  | 3 | 43.7 uA | 3987 | 5853 | 1866 |  |  |  |  |  |  |  |  |  |
|  | 4 | 43.7 uA | 5853 | 7698 | 1845 |  |  |  |  |  |  |  |  |  |
|  | 5 | 43.7 uA | 7698 | 9703 | 2005 |  |  |  |  |  |  |  |  |  |
| S/N 112 | 6 | 43.7 uA | 9703 | 11722 | 2019 |  |  | 7 |  |  |  |  |  |  |
| S1 B- | 7 | 43.7 uA | 11722 | 13562 | 1840 |  |  |  |  |  |  |  |  |  |
|  | 8 | 43.7 uA | 13562 | 15511 | 1949 |  |  |  |  |  |  |  |  |  |
|  | 9 | 43.7 uA | 15511 | 17452 | 1941 |  |  |  |  |  |  |  |  |  |
|  | 10 | 43.7 uA | 17452 | 19456 | 2004 |  |  |  |  |  |  |  |  |  |
|  | 11 | 43.7 uA | 19456 | 21391 | 1935 |  |  |  |  |  |  |  |  |  |
|  | 12 | 43.7 uA | 21391 | 23153 | 1762 |  |  |  |  |  |  |  |  |  |
|  | 13 | 43.7 uA | 23153 | 25168 | 2015 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13 stage stack. |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 24.8 uA | 25076 | 23281 | 1795 |  |  |  |  | No Repairs |  |  |  |  |
|  | 2 | 24.8 uA | 23281 | 21435 | 1846 |  |  |  |  |  |  |  |  |  |
|  | 3 | 24.8 uA | 21435 | 19579 | 1856 |  |  |  |  |  |  |  |  |  |
|  | 4 | 24.8 uA | 19579 | 17796 | 1783 |  |  |  |  |  |  |  |  |  |
|  | 5 | 24.8 uA | 17796 | 15968 | 1828 |  |  |  |  |  |  |  |  |  |
| S/N 119 | 6 | 24.8 uA | 15968 | 14238 | 1730 |  |  | 8 |  |  |  |  |  |  |
| S2 C+ | 7 | 24.8 uA | 14238 | 12352 | 1886 |  |  |  |  |  |  |  |  |  |
|  | 8 | 24.8 uA | 12352 | 10566 | 1786 |  |  |  |  |  |  |  |  |  |
|  | 9 | 24.8 uA | 10566 | 8798 | 1768 |  |  |  |  |  |  |  |  |  |
|  | 10 | 24.8 uA | 8798 | 7065 | 1733 |  |  |  |  |  |  |  |  |  |
|  | 11 | 24.8 uA | 7065 | 5522 | 1543 |  |  |  |  |  |  |  |  |  |
|  | 12 | 24.8 uA | 5522 | 3685 | 1837 |  |  |  |  |  |  |  |  |  |
|  | 13 | 24.8 uA | 3685 | 1823 | 1862 |  |  |  |  |  |  |  |  |  |
|  | 14 | 24.8 uA | 1823 | 0 | 1823 |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 41.3 uA | 0 | 1924 | 1924 |  |  |  |  | Replaced two 2500 volt MOVs. |  |  |  | 19.3 uA |
|  | 2 | 41.3 uA | 1924 | 3938 | 2014 |  |  |  |  |  |  |  |  |  |
|  | 3 | 41.3 uA | 3938 | 5706 | 1768 |  |  |  |  |  |  |  |  |  |
|  | 4 | 41.3 uA | 5706 | 7893 | 2187 |  |  |  |  |  |  |  |  |  |
|  | 5 | 41.3 uA | 7893 | 9561 | 1668 |  |  |  |  |  |  |  |  |  |
| S/N 105 | 6 | 41.3 uA | 9561 | 11396 | 1835 |  |  | 9 |  |  |  |  |  |  |
| S2 B- | 7 | 41.3 uA | 11346 | 13263 | 1867 |  |  |  |  |  |  |  |  |  |
|  | 8 | 41.3 uA | 13263 | 14363 | 1100 |  |  |  |  |  |  |  |  |  |
|  | 9 | 41.3 uA | 14363 | 15542 | 1179 |  |  |  |  |  |  |  |  |  |
|  | 10 | 41.3 uA | 15542 | 17351 | 1809 |  |  |  |  |  |  |  |  |  |
|  | 11 | 41.3 uA | 17351 | 19404 | 2053 |  |  |  |  |  |  |  |  |  |
|  | 12 | 41.3 uA | 19404 | 21346 | 1942 |  |  |  |  |  |  |  |  |  |
|  | 13 | 41.3 uA | 21346 | 23016 | 1670 |  |  |  |  |  |  |  |  |  |
|  | 14 | 41.3 uA | 23016 | 25083 | 2067 |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 22.8 uA | 0 | 2083 | 2083 |  |  |  |  | Replaced 14 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 10.6 uA |
|  | 2 | 22.8 uA | 2083 | 3585 | 1502 |  |  |  |  | Replaced four 2500 volt MOVs. |  |  |  |  |
|  | 3 | 22.8 uA | 3585 | 5607 | 2022 |  |  |  |  |  |  |  |  |  |
|  | 4 | 22.8 uA | 5607 | 7773 | 2166 |  |  |  |  |  |  |  |  |  |
|  | 5 | 22.8 uA | 7773 | 9420 | 1647 |  |  |  |  |  |  |  |  |  |
| S/N 120 | 6 | 22.8 uA | 9420 | 11411 | 1991 |  |  | 10 |  |  |  |  |  |  |
| S2 A- | 7 | 22.8 uA | 11411 | 13423 | 2012 |  |  |  |  |  |  |  |  |  |
|  | 8 | 22.8 uA | 13423 | 15404 | 1981 |  |  |  |  |  |  |  |  |  |
|  | 9 | 22.8 uA | 15404 | 17525 | 2121 |  |  |  |  |  |  |  |  |  |
|  | 10 | 22.8 uA | 17525 | 19177 | 1652 |  |  |  |  |  |  |  |  |  |
|  | 11 | 22.8 uA | 19177 | 20439 | 1262 |  |  |  |  |  |  |  |  |  |
|  | 12 | 22.8 uA | 20439 | 21974 | 1535 |  |  |  |  |  |  |  |  |  |
|  | 13 | 22.8 uA | 21974 | 23942 | 1968 |  |  |  |  |  |  |  |  |  |
|  | 14 | 22.8 uA | 23942 | 25006 | 1064 |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 15.7 uA | 0 | 1345 | 1345 |  |  |  |  | Replaced 14 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 10.6 uA |
|  | 2 | 15.7 uA | 1345 | 3104 | 1759 |  |  |  |  | Replaced three 2500 volt MOVs. |  |  |  |  |
|  | 3 | 15.7 uA | 3104 | 5061 | 1957 |  |  |  |  |  |  |  |  |  |
|  | 4 | 15.7 uA | 5061 | 6674 | 1613 |  |  |  |  |  |  |  |  |  |
|  | 5 | 15.7 uA | 6674 | 7161 | 487 |  |  |  |  |  |  |  |  |  |
| S/N 121 | 6 | 15.7 uA | 7161 | 8995 | 1834 |  |  | 11 |  |  |  |  |  |  |
| S2 C- | 7 | 15.7 uA | 8995 | 10841 | 1846 |  |  |  |  |  |  |  |  |  |
|  | 8 | 15.7 uA | 10841 | 12818 | 1977 |  |  |  |  |  |  |  |  |  |
|  | 9 | 15.7 uA | 12818 | 13887 | 1069 |  |  |  |  |  |  |  |  |  |
|  | 10 | 15.7 uA | 13887 | 15541 | 1654 |  |  |  |  |  |  |  |  |  |
|  | 11 | 15.7 uA | 15541 | 17248 | 1707 |  |  |  |  |  |  |  |  |  |
|  | 12 | 15.7 uA | 17248 | 19451 | 2203 |  |  |  |  |  |  |  |  |  |
|  | 13 | 15.7 uA | 20347 | 23078 | 2731 |  |  |  |  |  |  |  |  |  |
|  | 14 | 15.7 uA | 23078 | 25226 | 2148 |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 31.6 uA | 25040 | 23302 | 1739 |  |  |  |  | Replaced 3 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 21.5 uA |
|  | 2 | 31.6 uA | 23302 | 21055 | 2247 |  |  |  |  | Replaced three 2500 volt MOVs. |  |  |  |  |
|  | 3 | 31.6 uA | 21055 | 19063 | 1992 |  |  |  |  |  |  |  |  |  |
|  | 4 | 31.6 uA | 19063 | 17055 | 2008 |  |  |  |  |  |  |  |  |  |
|  | 5 | 31.6 uA | 17055 | 14811 | 2244 |  |  |  |  |  |  |  |  |  |
| S/N 103 | 6 | 31.6 uA | 14811 | 13429 | 1382 |  |  | 12 |  |  |  |  |  |  |
| S2 A+ | 7 | 31.6 uA | 13429 | 11233 | 2196 |  |  |  |  |  |  |  |  |  |
|  | 8 | 31.6 uA | 11233 | 9168 | 2065 |  |  |  |  |  |  |  |  |  |
|  | 9 | 31.6 uA | 9168 | 7404 | 1764 |  |  |  |  |  |  |  |  |  |
|  | 10 | 31.6 uA | 7404 | 5193 | 2211 |  |  |  |  |  |  |  |  |  |
|  | 11 | 31.6 uA | 5193 | 3403 | 1790 |  |  |  |  |  |  |  |  |  |
|  | 12 | 31.6 uA | 3403 | 1426 | 1977 |  |  |  |  |  |  |  |  |  |
|  | 13 | 31.6 uA | 1426 | 561 | 865 |  |  |  |  |  |  |  |  |  |
|  | 14 | 31.6 uA | 561 | 0 | 561 |  |  |  |  |  |  |  |  |  |


## Sheet: 2022 Phs Stack Report

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | Spear 1 RF HVPS Phase Control Stack Tests and Repairs, August 17,  2022 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 23.9 uA | 0 | 2001 | 2001 | 83723849.37238494 |  |  |  |  | Replaced twelve Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 20.4 uA |
|  | 2 | 23.9 uA | 2001 | 3985 | 1984 | 83012552.30125523 |  |  |  |  | Replaced one 2500 volt MOV in stage 10. |  |  |  |  |
|  | 3 | 23.9 uA | 3985 | 5983 | 1998 | 83598326.35983263 |  |  |  |  |  |  |  |  |  |
|  | 4 | 23.9 uA | 5983 | 7884 | 1901 | 79539748.95397489 |  |  |  |  |  |  |  |  |  |
|  | 5 | 23.9 uA | 7884 | 9810 | 1926 | 80585774.0585774 |  |  |  |  |  |  |  |  |  |
| S/N 111 | 6 | 23.9 uA | 9810 | 11707 | 1897 | 79372384.93723848 |  |  | 1 |  |  |  |  |  |  |
| S1 A- | 7 | 23.9 uA | 11707 | 13487 | 1780 | 74476987.44769874 |  |  |  |  |  |  |  |  |  |
|  | 8 | 23.9 uA | 13487 | 15476 | 1989 | 83221757.32217573 |  |  |  |  |  |  |  |  |  |
|  | 9 | 23.9 uA | 15476 | 17507 | 2031 | 84979079.49790795 |  |  |  |  |  |  |  |  |  |
|  | 10 | 23.9 uA | 17507 | 19056 | 1549 | 64811715.48117154 |  |  |  |  |  |  |  |  |  |
|  | 11 | 23.9 uA | 19056 | 20934 | 1878 | 78577405.85774058 |  |  |  |  |  |  |  |  |  |
|  | 12 | 23.9 uA | 20934 | 23101 | 2167 | 90669456.0669456 |  |  |  |  |  |  |  |  |  |
|  | 13 | 23.9 uA | 23101 | 25161 | 2060 | 86192468.61924686 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13 stage stack. |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 2.39e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 26.6 uA | 0 | 2040 | 2040 | 76691729.32330827 |  |  |  |  | No Repairs |  |  |  |  |
|  | 2 | 26.6 uA | 2040 | 4041 | 2001 | 75225563.90977444 |  |  |  |  |  |  |  |  |  |
|  | 3 | 26.6 uA | 4041 | 5988 | 1947 | 73195488.72180451 |  |  |  |  |  |  |  |  |  |
|  | 4 | 26.6 uA | 5988 | 7949 | 1961 | 73721804.5112782 |  |  |  |  |  |  |  |  |  |
|  | 5 | 26.6 uA | 7949 | 9822 | 1873 | 70413533.83458647 |  |  |  |  |  |  |  |  |  |
| S/N 107 | 6 | 26.6 uA | 9822 | 11728 | 1906 | 71654135.33834587 |  |  | 2 |  |  |  |  |  |  |
| S1 C- | 7 | 26.6 uA | 11728 | 13610 | 1882 | 70751879.69924812 |  |  |  |  |  |  |  |  |  |
|  | 8 | 26.6 uA | 13610 | 15677 | 2067 | 77706766.91729324 |  |  |  |  |  |  |  |  |  |
|  | 9 | 26.6 uA | 15677 | 17571 | 1894 | 71203007.518797 |  |  |  |  |  |  |  |  |  |
|  | 10 | 26.6 uA | 17571 | 19474 | 1903 | 71541353.38345864 |  |  |  |  |  |  |  |  |  |
|  | 11 | 26.6 uA | 19474 | 21253 | 1779 | 66879699.2481203 |  |  |  |  |  |  |  |  |  |
|  | 12 | 26.6 uA | 21253 | 23016 | 1763 | 66278195.4887218 |  |  |  |  |  |  |  |  |  |
|  | 13 | 26.6 uA | 23016 | 25092 | 2076 | 78045112.78195488 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13 stage stack. |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 2.66e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 13.1 uA | 25172 | 23223 | 1949 | 148778625.95419848 |  |  |  |  | Replaced twelve Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 8.2 uA |
|  | 2 | 13.1 uA | 23223 | 21264 | 1959 | 149541984.73282441 |  |  |  |  | Replaced four 2500 volt MOVs in stages 5,6, 11, and 12.  Replaced 2 SCRs in stages 5 + 11. |  |  |  |  |
|  | 3 | 13.1 uA | 21264 | 19156 | 2108 | 160916030.53435114 |  |  |  |  |  |  |  |  |  |
|  | 4 | 13.1 uA | 19156 | 16994 | 2162 | 165038167.9389313 |  |  |  |  |  |  |  |  |  |
|  | 5 | 13.1 uA | 16994 | 15708 | 1286 | 98167938.9312977 |  |  |  |  |  |  |  |  |  |
| S/N 124 | 6 | 13.1 uA | 15708 | 14223 | 1485 | 113358778.6259542 |  |  | 3 |  |  |  |  |  |  |
| S1 A+ | 7 | 13.1 uA | 14223 | 12205 | 2018 | 154045801.52671754 |  |  |  |  |  |  |  |  |  |
|  | 8 | 13.1 uA | 12205 | 10394 | 1811 | 138244274.8091603 |  |  |  |  |  |  |  |  |  |
|  | 9 | 13.1 uA | 10394 | 8651 | 1743 | 133053435.11450382 |  |  |  |  |  |  |  |  |  |
|  | 10 | 13.1 uA | 8651 | 6862 | 1789 | 136564885.49618322 |  |  |  |  |  |  |  |  |  |
|  | 11 | 13.1 uA | 6862 | 5432 | 1430 | 109160305.34351145 |  |  |  |  |  |  |  |  |  |
|  | 12 | 13.1 uA | 5432 | 3921 | 1511 | 115343511.45038168 |  |  |  |  |  |  |  |  |  |
|  | 13 | 13.1 uA | 3921 | 1973 | 1948 | 148702290.07633588 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13.1 uA | 1973 | 0 | 1973 | 150610687.02290076 |  |  |  |  |  |  |  |  |  |
|  |  | 1.31e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 43.2 uA | 25216 | 23649 | 1567 | 36273148.14814815 |  |  |  |  | Replaced five 2500 volt MOVs and 1 SCR in stage 5. |  |  |  | 10.7 uA |
|  | 2 | 43.2 uA | 23649 | 22016 | 1633 | 37800925.925925925 |  |  |  |  |  |  |  |  |  |
|  | 3 | 43.2 uA | 22016 | 20596 | 1420 | 32870370.37037037 |  |  |  |  |  |  |  |  |  |
|  | 4 | 43.2 uA | 20596 | 18573 | 2023 | 46828703.7037037 |  |  |  |  |  |  |  |  |  |
|  | 5 | 43.2 uA | 18573 | 18163 | 406 | 9398148.148148147 |  |  |  |  |  |  |  |  |  |
| S/N 122 | 6 | 43.2 uA | 18163 | 15992 | 2171 | 50254629.62962963 |  |  | 4 |  |  |  |  |  |  |
| S2 B+ | 7 | 43.2 uA | 15992 | 14318 | 1674 | 38750000 |  |  |  |  |  |  |  |  |  |
|  | 8 | 43.2 uA | 14318 | 12025 | 2293 | 53078703.7037037 |  |  |  |  |  |  |  |  |  |
|  | 9 | 43.2 uA | 12025 | 9988 | 2037 | 47152777.777777776 |  |  |  |  |  |  |  |  |  |
|  | 10 | 43.2 uA | 9988 | 7852 | 2136 | 49444444.44444445 |  |  |  |  |  |  |  |  |  |
|  | 11 | 43.2 uA | 7852 | 5866 | 1986 | 45972222.222222224 |  |  |  |  |  |  |  |  |  |
|  | 12 | 43.2 uA | 5866 | 3886 | 1980 | 45833333.333333336 |  |  |  |  |  |  |  |  |  |
|  | 13 | 43.2 uA | 3886 | 1735 | 2151 | 49791666.666666664 |  |  |  |  |  |  |  |  |  |
|  | 14 | 43.2 uA | 1735 | 0 | 1735 | 40162037.03703704 |  |  |  |  |  |  |  |  |  |
|  |  | 4.32e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 955 uA | 25441 | 22948 | 2493 | 2610471.2041884814 |  |  |  |  | Replaced 14 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 99.7 uA |
|  | 2 | 955 uA | 22948 | 22931 | 17 (Short) | 17801.047120418847 |  |  |  |  | Replaced three 2500 volt MOVs and 3 SCRs in shorted cells. |  |  |  | Boards on. |
|  | 3 | 955 uA | 22931 | 20468 | 2463 | 2579057.5916230367 |  |  |  |  |  |  |  |  |  |
|  | 4 | 955 uA | 20468 | 20468 | 0 (Short) | 0 |  |  |  |  |  |  |  |  |  |
|  | 5 | 955 uA | 20468 | 17855 | 2613 | 2736125.654450262 |  |  |  |  |  |  |  |  |  |
| S/N 101 | 6 | 955 uA | 17855 | 17855 | 0 (Short) | 0 |  |  | 5 |  |  |  |  |  |  |
| S1 C+ | 7 | 955 uA | 17855 | 15305 | 2550 | 2670157.068062827 |  |  |  |  |  |  |  |  |  |
|  | 8 | 955 uA | 15305 | 12733 | 2572 | 2693193.717277487 |  |  |  |  |  |  |  |  |  |
|  | 9 | 955 uA | 12233 | 10355 | 1878 | 1966492.1465968585 |  |  |  |  |  |  |  |  |  |
|  | 10 | 955 uA | 10355 | 7830 | 2525 | 2643979.057591623 |  |  |  |  |  |  |  |  |  |
|  | 11 | 955 uA | 7830 | 5350 | 2480 | 2596858.6387434555 |  |  |  |  |  |  |  |  |  |
|  | 12 | 955 uA | 5350 | 2664 | 2686 | 2812565.445026178 |  |  |  |  |  |  |  |  |  |
|  | 13 | 955 uA | 2664 | 0 | 2664 | 2789528.795811518 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13 stage stack. |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 0.000955 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 35.8 uA | 25178 | 23411 | 1767 | 49357541.89944134 |  |  |  |  | Replaced 14 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 21.6 uA |
|  | 2 | 35.8 uA | 23411 | 21585 | 1826 | 51005586.59217877 |  |  |  |  | Replaced 1 D54 3 amp diode on gate drive board. |  |  |  |  |
|  | 3 | 35.8 uA | 21585 | 19551 | 2034 | 56815642.45810056 |  |  |  |  | Replaced four 2500 volt MOVs. |  |  |  |  |
|  | 4 | 35.8 uA | 19551 | 17636 | 1915 | 53491620.11173184 |  |  |  |  |  |  |  |  |  |
|  | 5 | 35.8 uA | 17636 | 15488 | 2148 | 59999999.99999999 |  |  |  |  |  |  |  |  |  |
| S/N 109 | 6 | 35.8 uA | 15488 | 13655 | 1833 | 51201117.31843575 |  |  | 6 |  |  |  |  |  |  |
| S1 B+ | 7 | 35.8 uA | 13655 | 12207 | 1448 | 40446927.37430167 |  |  |  |  |  |  |  |  |  |
|  | 8 | 35.8 uA | 12207 | 10111 | 2096 | 58547486.03351955 |  |  |  |  |  |  |  |  |  |
|  | 9 | 35.8 uA | 10111 | 8451 | 1660 | 46368715.08379888 |  |  |  |  |  |  |  |  |  |
|  | 10 | 35.8 uA | 8451 | 6247 | 2204 | 61564245.81005586 |  |  |  |  |  |  |  |  |  |
|  | 11 | 35.8 uA | 6247 | 4642 | 1605 | 44832402.234636866 |  |  |  |  |  |  |  |  |  |
|  | 12 | 35.8 uA | 4642 | 3334 | 1308 | 36536312.849162005 |  |  |  |  |  |  |  |  |  |
|  | 13 | 35.8 uA | 3334 | 1337 | 1997 | 55782122.905027926 |  |  |  |  |  |  |  |  |  |
|  | 14 | 35.8 uA | 1337 | 0 | 1337 | 37346368.71508379 |  |  |  |  |  |  |  |  |  |
|  |  | 3.58e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 43.7 uA | 0 | 1982 | 1982 | 45354691.075514875 |  |  |  |  | No Repairs |  |  |  |  |
|  | 2 | 43.7 uA | 1982 | 3987 | 2005 | 45881006.86498856 |  |  |  |  |  |  |  |  |  |
|  | 3 | 43.7 uA | 3987 | 5853 | 1866 | 42700228.83295195 |  |  |  |  |  |  |  |  |  |
|  | 4 | 43.7 uA | 5853 | 7698 | 1845 | 42219679.63386728 |  |  |  |  |  |  |  |  |  |
|  | 5 | 43.7 uA | 7698 | 9703 | 2005 | 45881006.86498856 |  |  |  |  |  |  |  |  |  |
| S/N 112 | 6 | 43.7 uA | 9703 | 11722 | 2019 | 46201372.99771167 |  |  | 7 |  |  |  |  |  |  |
| S1 B- | 7 | 43.7 uA | 11722 | 13562 | 1840 | 42105263.15789474 |  |  |  |  |  |  |  |  |  |
|  | 8 | 43.7 uA | 13562 | 15511 | 1949 | 44599542.33409611 |  |  |  |  |  |  |  |  |  |
|  | 9 | 43.7 uA | 15511 | 17452 | 1941 | 44416475.97254005 |  |  |  |  |  |  |  |  |  |
|  | 10 | 43.7 uA | 17452 | 19456 | 2004 | 45858123.56979405 |  |  |  |  |  |  |  |  |  |
|  | 11 | 43.7 uA | 19456 | 21391 | 1935 | 44279176.201372996 |  |  |  |  |  |  |  |  |  |
|  | 12 | 43.7 uA | 21391 | 23153 | 1762 | 40320366.132723115 |  |  |  |  |  |  |  |  |  |
|  | 13 | 43.7 uA | 23153 | 25168 | 2015 | 46109839.81693364 |  |  |  |  |  |  |  |  |  |
|  | 14 | 13 stage stack. |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | 4.37e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 24.8 uA | 25076 | 23281 | 1795 | 72379032.25806452 |  |  |  |  | No Repairs |  |  |  |  |
|  | 2 | 24.8 uA | 23281 | 21435 | 1846 | 74435483.87096775 |  |  |  |  |  |  |  |  |  |
|  | 3 | 24.8 uA | 21435 | 19579 | 1856 | 74838709.67741935 |  |  |  |  |  |  |  |  |  |
|  | 4 | 24.8 uA | 19579 | 17796 | 1783 | 71895161.29032259 |  |  |  |  |  |  |  |  |  |
|  | 5 | 24.8 uA | 17796 | 15968 | 1828 | 73709677.41935484 |  |  |  |  |  |  |  |  |  |
| S/N 119 | 6 | 24.8 uA | 15968 | 14238 | 1730 | 69758064.51612903 |  |  | 8 |  |  |  |  |  |  |
| S2 C+ | 7 | 24.8 uA | 14238 | 12352 | 1886 | 76048387.09677419 |  |  |  |  |  |  |  |  |  |
|  | 8 | 24.8 uA | 12352 | 10566 | 1786 | 72016129.03225806 |  |  |  |  |  |  |  |  |  |
|  | 9 | 24.8 uA | 10566 | 8798 | 1768 | 71290322.58064516 |  |  |  |  |  |  |  |  |  |
|  | 10 | 24.8 uA | 8798 | 7065 | 1733 | 69879032.25806452 |  |  |  |  |  |  |  |  |  |
|  | 11 | 24.8 uA | 7065 | 5522 | 1543 | 62217741.93548387 |  |  |  |  |  |  |  |  |  |
|  | 12 | 24.8 uA | 5522 | 3685 | 1837 | 74072580.64516129 |  |  |  |  |  |  |  |  |  |
|  | 13 | 24.8 uA | 3685 | 1823 | 1862 | 75080645.16129032 |  |  |  |  |  |  |  |  |  |
|  | 14 | 24.8 uA | 1823 | 0 | 1823 | 73508064.51612903 |  |  |  |  |  |  |  |  |  |
|  |  | 2.48e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 41.3 uA | 0 | 1924 | 1924 | 46585956.41646489 |  |  |  |  | Replaced two 2500 volt MOVs. |  |  |  | 19.3 uA |
|  | 2 | 41.3 uA | 1924 | 3938 | 2014 | 48765133.171912834 |  |  |  |  |  |  |  |  |  |
|  | 3 | 41.3 uA | 3938 | 5706 | 1768 | 42808716.70702179 |  |  |  |  |  |  |  |  |  |
|  | 4 | 41.3 uA | 5706 | 7893 | 2187 | 52953995.157384984 |  |  |  |  |  |  |  |  |  |
|  | 5 | 41.3 uA | 7893 | 9561 | 1668 | 40387409.20096852 |  |  |  |  |  |  |  |  |  |
| S/N 105 | 6 | 41.3 uA | 9561 | 11396 | 1835 | 44430992.73607748 |  |  | 9 |  |  |  |  |  |  |
| S2 B- | 7 | 41.3 uA | 11346 | 13263 | 1867 | 45205811.138014525 |  |  |  |  |  |  |  |  |  |
|  | 8 | 41.3 uA | 13263 | 14363 | 1100 | 26634382.566585954 |  |  |  |  |  |  |  |  |  |
|  | 9 | 41.3 uA | 14363 | 15542 | 1179 | 28547215.49636804 |  |  |  |  |  |  |  |  |  |
|  | 10 | 41.3 uA | 15542 | 17351 | 1809 | 43801452.78450363 |  |  |  |  |  |  |  |  |  |
|  | 11 | 41.3 uA | 17351 | 19404 | 2053 | 49709443.09927361 |  |  |  |  |  |  |  |  |  |
|  | 12 | 41.3 uA | 19404 | 21346 | 1942 | 47021791.76755448 |  |  |  |  |  |  |  |  |  |
|  | 13 | 41.3 uA | 21346 | 23016 | 1670 | 40435835.35108959 |  |  |  |  |  |  |  |  |  |
|  | 14 | 41.3 uA | 23016 | 25083 | 2067 | 50048426.15012106 |  |  |  |  |  |  |  |  |  |
|  |  | 4.13e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 22.8 uA | 0 | 2083 | 2083 | 91359649.12280703 |  |  |  |  | Replaced 14 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 10.6 uA |
|  | 2 | 22.8 uA | 2083 | 3585 | 1502 | 65877192.98245615 |  |  |  |  | Replaced four 2500 volt MOVs. |  |  |  |  |
|  | 3 | 22.8 uA | 3585 | 5607 | 2022 | 88684210.5263158 |  |  |  |  |  |  |  |  |  |
|  | 4 | 22.8 uA | 5607 | 7773 | 2166 | 95000000 |  |  |  |  |  |  |  |  |  |
|  | 5 | 22.8 uA | 7773 | 9420 | 1647 | 72236842.10526316 |  |  |  |  |  |  |  |  |  |
| S/N 120 | 6 | 22.8 uA | 9420 | 11411 | 1991 | 87324561.40350878 |  |  | 10 |  |  |  |  |  |  |
| S2 A- | 7 | 22.8 uA | 11411 | 13423 | 2012 | 88245614.03508772 |  |  |  |  |  |  |  |  |  |
|  | 8 | 22.8 uA | 13423 | 15404 | 1981 | 86885964.91228071 |  |  |  |  |  |  |  |  |  |
|  | 9 | 22.8 uA | 15404 | 17525 | 2121 | 93026315.7894737 |  |  |  |  |  |  |  |  |  |
|  | 10 | 22.8 uA | 17525 | 19177 | 1652 | 72456140.3508772 |  |  |  |  |  |  |  |  |  |
|  | 11 | 22.8 uA | 19177 | 20439 | 1262 | 55350877.19298246 |  |  |  |  |  |  |  |  |  |
|  | 12 | 22.8 uA | 20439 | 21974 | 1535 | 67324561.40350878 |  |  |  |  |  |  |  |  |  |
|  | 13 | 22.8 uA | 21974 | 23942 | 1968 | 86315789.47368422 |  |  |  |  |  |  |  |  |  |
|  | 14 | 22.8 uA | 23942 | 25006 | 1064 | 46666666.66666667 |  |  |  |  |  |  |  |  |  |
|  |  | 2.28e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 15.7 uA | 0 | 1345 | 1345 | 85668789.80891721 |  |  |  |  | Replaced 14 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 10.6 uA |
|  | 2 | 15.7 uA | 1345 | 3104 | 1759 | 112038216.56050956 |  |  |  |  | Replaced three 2500 volt MOVs. |  |  |  |  |
|  | 3 | 15.7 uA | 3104 | 5061 | 1957 | 124649681.52866243 |  |  |  |  |  |  |  |  |  |
|  | 4 | 15.7 uA | 5061 | 6674 | 1613 | 102738853.50318472 |  |  |  |  |  |  |  |  |  |
|  | 5 | 15.7 uA | 6674 | 7161 | 487 | 31019108.28025478 |  |  |  |  |  |  |  |  |  |
| S/N 121 | 6 | 15.7 uA | 7161 | 8995 | 1834 | 116815286.62420383 |  |  | 11 |  |  |  |  |  |  |
| S2 C- | 7 | 15.7 uA | 8995 | 10841 | 1846 | 117579617.83439492 |  |  |  |  |  |  |  |  |  |
|  | 8 | 15.7 uA | 10841 | 12818 | 1977 | 125923566.8789809 |  |  |  |  |  |  |  |  |  |
|  | 9 | 15.7 uA | 12818 | 13887 | 1069 | 68089171.9745223 |  |  |  |  |  |  |  |  |  |
|  | 10 | 15.7 uA | 13887 | 15541 | 1654 | 105350318.47133759 |  |  |  |  |  |  |  |  |  |
|  | 11 | 15.7 uA | 15541 | 17248 | 1707 | 108726114.64968154 |  |  |  |  |  |  |  |  |  |
|  | 12 | 15.7 uA | 17248 | 19451 | 2203 | 140318471.33757964 |  |  |  |  |  |  |  |  |  |
|  | 13 | 15.7 uA | 20347 | 23078 | 2731 | 173949044.58598727 |  |  |  |  |  |  |  |  |  |
|  | 14 | 15.7 uA | 23078 | 25226 | 2148 | 136815286.62420383 |  |  |  |  |  |  |  |  |  |
|  |  | 1.57e-05 |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Stack Position | SCR # | Series Current | Volts on top plate | Volts on bottom plate | Volts Δ across SCR | Resistance | Good/Bad |  |  |  | Repairs |  |  |  | Series Current |
|  | 1 (top) | 31.6 uA | 25040 | 23302 | 1739 | 55031645.56962025 |  |  |  |  | Replaced 3 Z40 diodes with Z50 diodes on gate drive boards. |  |  |  | 21.5 uA |
|  | 2 | 31.6 uA | 23302 | 21055 | 2247 | 71107594.93670885 |  |  |  |  | Replaced three 2500 volt MOVs. |  |  |  |  |
|  | 3 | 31.6 uA | 21055 | 19063 | 1992 | 63037974.6835443 |  |  |  |  |  |  |  |  |  |
|  | 4 | 31.6 uA | 19063 | 17055 | 2008 | 63544303.79746835 |  |  |  |  |  |  |  |  |  |
|  | 5 | 31.6 uA | 17055 | 14811 | 2244 | 71012658.2278481 |  |  |  |  |  |  |  |  |  |
| S/N 103 | 6 | 31.6 uA | 14811 | 13429 | 1382 | 43734177.21518987 |  |  | 12 |  |  |  |  |  |  |
| S2 A+ | 7 | 31.6 uA | 13429 | 11233 | 2196 | 69493670.88607594 |  |  |  |  |  |  |  |  |  |
|  | 8 | 31.6 uA | 11233 | 9168 | 2065 | 65348101.26582278 |  |  |  |  |  |  |  |  |  |
|  | 9 | 31.6 uA | 9168 | 7404 | 1764 | 55822784.81012658 |  |  |  |  |  |  |  |  |  |
|  | 10 | 31.6 uA | 7404 | 5193 | 2211 | 69968354.43037975 |  |  |  |  |  |  |  |  |  |
|  | 11 | 31.6 uA | 5193 | 3403 | 1790 | 56645569.62025316 |  |  |  |  |  |  |  |  |  |
|  | 12 | 31.6 uA | 3403 | 1426 | 1977 | 62563291.1392405 |  |  |  |  |  |  |  |  |  |
|  | 13 | 31.6 uA | 1426 | 561 | 865 | 27373417.721518986 |  |  |  |  |  |  |  |  |  |
|  | 14 | 31.6 uA | 561 | 0 | 561 | 17753164.556962024 |  |  |  |  |  |  |  |  |  |
|  |  | 31.6e-6 |  |  |  |  |  |  |  |  |  |  |  |  |  |


## Sheet: CrowbarTemplate

|  |  | Crowbar Stack Tests of Spear Crowbar Stacks Removed From Spear 2 RF HVPS on 6 August, 2020 |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad |  |  |
| 1 | 1 |  |  |  |  |  |  |  |  |  |  |
| 1 | 2 |  |  |  |  |  |  |  |  |  |  |
| 1 | 3 |  |  |  |  |  |  |  |  |  |  |
| 1 | 4 |  |  |  |  |  |  |  |  |  |  |
| 1 | 5 |  |  |  |  |  |  |  |  |  |  |
| 1 | 6 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack # | SCR # |  |  |  |  |  |  |  |  |  |  |
| 2 | 1 |  |  |  |  |  |  |  |  |  |  |
| 2 | 2 |  |  |  |  |  |  |  |  |  |  |
| 2 | 3 |  |  |  |  |  |  |  |  |  |  |
| 2 | 4 |  |  |  |  |  |  |  |  |  |  |
| 2 | 5 |  |  |  |  |  |  |  |  |  |  |
| 2 | 6 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack # | SCR # |  |  |  |  |  |  |  |  |  |  |
| 3 | 1 |  |  |  |  |  |  |  |  |  |  |
| 3 | 2 |  |  |  |  |  |  |  |  |  |  |
| 3 | 3 |  |  |  |  |  |  |  |  |  |  |
| 3 | 4 |  |  |  |  |  |  |  |  |  |  |
| 3 | 5 |  |  |  |  |  |  |  |  |  |  |
| 3 | 6 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack # | SCR # |  |  |  |  |  |  |  |  |  |  |
| 4 | 1 |  |  |  |  |  |  |  |  |  |  |
| 4 | 2 |  |  |  |  |  |  |  |  |  |  |
| 4 | 3 |  |  |  |  |  |  |  |  |  |  |
| 4 | 4 |  |  |  |  |  |  |  |  |  |  |
| 4 | 5 |  |  |  |  |  |  |  |  |  |  |
| 4 | 6 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Crowbar Stack Tests of Repaired Spear Crowbar Stacks Removed From Spear 2 RF HVPS on 6 August, 2020 |  |  |  |  |  |  |  |  |  |
|  |  | mA |  |  |  | mA |  |  |  |  |  |
| Stack # | SCR # | Series I @ 25 KVDC | Volts on Top Plate | Volts on Bottom Plate | ∆ Volts | I @ 5 KVDC | Hi + Lo Volts Triggering | SF Volts | SCR Good/Bad | Replacement Ser #/DC | Bad SCR S/N Removed |
| 1 | 1 |  |  |  |  |  |  |  |  |  |  |
| 1 | 2 |  |  |  |  |  |  |  |  |  |  |
| 1 | 3 |  |  |  |  |  |  |  |  |  |  |
| 1 | 4 |  |  |  |  |  |  |  |  |  |  |
| 1 | 5 |  |  |  |  |  |  |  |  |  |  |
| 1 | 6 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack # | SCR # |  |  |  |  |  |  |  |  |  |  |
| 2 | 1 |  |  |  |  |  |  |  |  |  |  |
| 2 | 2 |  |  |  |  |  |  |  |  |  |  |
| 2 | 3 |  |  |  |  |  |  |  |  |  |  |
| 2 | 4 |  |  |  |  |  |  |  |  |  |  |
| 2 | 5 |  |  |  |  |  |  |  |  |  |  |
| 2 | 6 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack # | SCR # |  |  |  |  |  |  |  |  |  |  |
| 3 | 1 |  |  |  |  |  |  |  |  |  |  |
| 3 | 2 |  |  |  |  |  |  |  |  |  |  |
| 3 | 3 |  |  |  |  |  |  |  |  |  |  |
| 3 | 4 |  |  |  |  |  |  |  |  |  |  |
| 3 | 5 |  |  |  |  |  |  |  |  |  |  |
| 3 | 6 |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |
| Stack # | SCR # |  |  |  |  |  |  |  |  |  |  |
| 4 | 1 |  |  |  |  |  |  |  |  |  |  |
| 4 | 2 |  |  |  |  |  |  |  |  |  |  |
| 4 | 3 |  |  |  |  |  |  |  |  |  |  |
| 4 | 4 |  |  |  |  |  |  |  |  |  |  |
| 4 | 5 |  |  |  |  |  |  |  |  |  |  |
| 4 | 6 |  |  |  |  |  |  |  |  |  |  |
