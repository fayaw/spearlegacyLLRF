# plcNotesR1

> **Source:** `hvps/documentation/plc/plcNotesR1.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## N7:10, N7:11 Analysis

## Timing

### Estimate

The Rockwell specifications estimates that a typical SLC 500 program takes about 0.9 ms per kB of code.  This program has about 5.5 kB, so, if there are no delays, each cycle of the program should execute in about 5 ms.
### Timers

The code uses timers and One Shot Rising (OSR) instructions in various rungs of the program to limit the speed of the program.  The S:4 register is a counter that increments every 10 ms.  The period of the square wave of bits 0-15 of S:4 is  where  is the S:4 bit number.  Bit  is on for .
### OSR Instructions in the Code


| Rung | Bit | Period (ms) | Word | Bit | OSR |
| --- | --- | --- | --- | --- | --- |
| 86 | 2 | 80 | B3:5 | 1 | Yes |
| 87 | 2 | 80 | B3:5 | 2 | Yes |
| 92 | 3 | 160 | B3:5 | 8 | Yes |
| 93 | 2 | 80 | B3:5 | 4 | Yes |
| 94 | 2 | 80 | B3:5 | 5 | Yes |
| 96 | 2 | 80 | B3:5 | 6 | Yes |
| 97 | 2 | 80 | B3:5 | 7 | Yes |
| 104 | 2 | 80 | B3:5 | 0 | Yes |
| 105 | 5 | 640 | B3:5 | 9 | Yes |
| 117 | 6 | 1280 | B3:17 | 0 | Yes |
| 118 | 7 | 2560 | B3:17 | 1 | Yes |
| 115 |  |  | B3:12 | 8 | Yes |



## N7:10

### Purpose of the N7:10

N7:10 is the Reference Out register that is loaded into output 0 of module AB-1746-NIO4V (slot 8).  It is connected to EL1, the reference input to the regulator card.  The value of N7:10 is determined by the value sent to Register 1 of the I:1 bank via the DCM module in the VXI crate.  This value is loaded into N7:30, labeled External Reference.  The PLC code has an internal loop, in Rung 104, that implements a single pole low pass digital filter that ramps the value in N7:10 from its initial value to the desired value in N7:30.  The PLC loops through its code in about .  Rung 104 uses a timer with a period of  that keeps the time between updates of the loop at about .
### Low Pass Filter Implemented in PLC Code

We consider a general low pass filter loop that has a cycle period of .  We choose a value  that is a measure of what fraction of the difference between the desired set point and the current actual value of the set point is changed each period.
We examine the evolution of the actual value as a function of the initial difference between the desired set point, , and the current value as a function, , of the iteration number  of the loop.  We define the initial difference to be .  We will calculate , the difference at the  iteration between the desired setpoint  and the current setpoint .
At the first iteration we increment  by  so that .  At the second iteration we increment  by .  This means that .  Continuing with the same reasoning, .  The voltage reference sent to the EL1 port of the regulator card from output 0 of the AB-1746-NIO4V, calculated by the PLC and stored in N7:10, has the value

This is a digital implementation of a single pole low pass filter step response , where now

For the case of the HVPS,  so that .
### Ladder Rungs Involving N7:10

- Rung 0011 (Data loaded into PLC?)
- Reference voltage enabled by B3:0
- The source is memory 0
- Updated by T4:14?
- Is this an initialization to 0?
- Rung 0092 (Value set on DAC?)
- N7:10 is moved to O:1.2 (output voltage DAC?)
- Rung 0104  B3:0.2 (Regulator On, set in Rung 10, S:4.2, B3:5.0 OSR)
- Move HVPS setpoint from VXI crate to External Reference register
- I:1.1 is moved to N7:30  (Input from VXI IOC to External Reference)
- Ensure that External Reference exceeds a minimum value stored in Internal Reference
- If N7:31 > N7:30, move N7:31 to N7:30  (set minimum value of N7:30 to N7:31)
- N7:30 = max(N7:31, N7:30)
- Find the Delta register value by subtracting the Reference Out value from the External Reference
- Subtract N7:10 from N7:30 and place the result in N7:43
- N7:43 = N7:30 – N7:10
- Scale the Delta to one tenth of the calculated difference
- Divide N7:43 by fixed value of 10 and place in N7:43
- N7:43 = N7:43/10
- Add the one tenth of the difference to the Reference Out and set appropriate status bits
- Add N7:10 to N7:43 and place in N7:10
- N7:10 = N7:10 + N7:43
- Check for overflow and unlatch the output if overflow has set it
- Set a valid bit to VXI to low indicating that the new Reference Out value is within range
- O:1.96  1747-DCM-FULL L
- If one tenth of the difference is zero, move the External Reference to the Reference Out  (This is included to force the Reference Out to the External Reference when the difference is sufficiently low that that value divided by ten truncates to zero even when the two are not equal.)
- If N7:43 equals 0, move N7:30 to N7:10
- if N7:43 == 0, N7:10 = N7:30
- If N7:10 > N7:32 (fixed 32000?), move N7:32 to N7:10 and set O:1 1747-DCM-FULL U
- N7:10 = min(N7:10, N7:32) = min(N7:10, 32000)
- If N7:33 > 0 and If N7:10 > N7:33, move N7:33 to N7:10
- If N7:33 > 0, N7:10 = min(N7:10, N7:33)
- O:1 1747-DCM-FULL U
- Rung 0105  S:4, B3:5
- Move N7:71 (32000 constant) to N7:32
- Move N7:72 (18000 constant) to N7:42
- Move N7:73 (100 constant) to N7:31
- Divide N7:71 by N7:10 and place result (non-remainder) in N7:74
- What is N7:10 at this point?  Is it set by the value set by Rung 0104?
- If N7:10 == 0, this should throw a divide by zero fault.  Does it?  Should there be a check for this?  Or is N7:10 set to a non-zero minimum?
- Destination N7:74 looks as if it has railed at 2^15 – 1, the maximum positive integer
- Multiply N7:74 by the constant 2^15 – 1 and place result in N7:74
- What does this instruction do?  It multiplies a number by the maximum number and returns the result to the original register.  Is the answer here always going to be either 2^15 – 1, 0, or -2^15?
- Divide N7:73 by N7:10 and place the result in N7:74.
- This is a parallel step to the divide of N7:71 and raises the same questions about divide by zero, etc.
- Multiply N7:75 by the constant 2^15 – 1 and place the result in N7:75
- This is a parallel step to the multiplication of N7:74 and leads to the same questions as for that step.
- Rung 0106
- Multiply N7:10 by N7:20 (is this a constant of 10000?) and place the result in N7:0
- Check for overflow
- What effect happens if the overflow exists?
- Double divide
- 32 bit math register is divided by the source, 2^15 – 1 and placed in the destination N7:0
- Is this effectively a right shift of the 32 bit math register by 15 bits?
- Rung 0107
- If N7:0 is true, move 0 to N7:0.
- The comment says NEG DETECT
- From the comment I expect that if N7:0 is non-zero, this Rung and MOV instruction zero N7:0
- Rung 0108  B3:5, Phase Angle Control Limit
- Move N7:10 to N7:11
- Multiply N7:11 by N7:40 (a constant 12000) and store the result in N7:11.  Note that if the product overflows (>=2^15-1), then 2^15-1 is stored in the destination and the 32 bit product is stored in registers S:13 (LSW) and S:14 (MSW), ready for the double divide command
- N7:11 = min(32767,N7:11*12000)
- Unset the S:5 overflow bit
- Double divide by N7:11 and store the result in N7:11
- If the multiplication did not overflow, N7:11 would have the value of the multiplication and this value would just be 1.
- If the multiplication did overflow, N7:11 would have the value 32767, and this would be almost the S14 register value.
- Add N7:11 to N7:41 (a constant 6000) and store the result in N7:11
- N7:11 = N7:11 + N7:41
- Unset the S:5 overflow bit
- Rung 0109
- If N7:11 is greater than N7:42, move N7:42 to N7:11.  This limits the value of N7:11
- If N7:11 > 18000, N7:11 = 18000
- Could this be N7:11 = min(N7:11, N7:42) = min(N7:11, 18000)
- Rung 0110  Sets register N7:1, the Phase Angle.  Is this only used on the display?
- Multiply N7:11 by N7:21 (a constant 1000)
- Unset the S:5 overflow bit
- Double divide by 2^15-1 and store the result in N7:1
- Does this rung multiply N7:11 by 1000/32767?
- Rung 0111
- If N7:1 is either negative or has an overflow, set N7:1 to 0.
- Rung 0112
- Move N7:10 to O:8.0 to the
## N7:11

- Rung 0011  (Register initialized to 0?)
- Reference voltage enabled by B3:0
- The source is memory 0
- Updated by T4:14?
- Is this an initialization to 0?
- Rung 0108  (Sets phase angle control limit.  See discussion above for N7:10.)
- Rung 0109  (Limits N7:11 to the value of N7:42 (18000)  (See above.)
- Rung 0110
## Questions to answer

- What is B3:0.2 and what enables it?  B3:0.2 is Regulator On set in Rung 10
- Is memory 0 the location of data from the IOC?  I1 register 1 is the 16 bit set point from the IOC
- What does this translate to in the new code?
- Is N7:31 a fixed minimum in the program?
- What happens in the program when the overflow bit S:5 is set as the result of an invalid mathematical operation?  I think that there never should be an illegal operation.  The instructions are to unset the overflow bit to prevent the program stopping on error.
- How does the multiply instruction work for integers.  Are the two inputs both 16 bit integers and the product a 32 bit integer?  Yes.  The 32 bits are stored as two 16 bit words.  The most significant word is stored in register S14 and the least significant word is stored in register S13.
- 2^15*2^15 gives 2^30.  Does that mean that the product can never get to 2^31?
- Are the upper 16 bits stored in the destination and all 32 bits stored in the 32 bit math register S:13 and S:14?
- Would it be preferable to divide by 2^14, which is even, and then maybe by another 2, if required?  The new PLC has floating point numbers, so we will likely not have such overflow problems.
## Analog Inputs and Outputs

### Analog Inputs

#### AB-1746-NIO4V (Slot 8)

- IN 0  Voltage monitor from regulator card  (J3-1)
- Rung 0076
- Add to N7:19 and store the sum in N7:12
- IN 1  Phase control driver to Enerpro board  (SIG HI)
- Rung 0088
- Move to N7:13
#### AB-1746-NI4  (Slot 9)

- IN 0  Input AC current monitor from regulator card  (J3-2)
- Rung 0078
- Add to N7:9 and store the sum in N7:14
- IN 1  Output voltage monitor 1 from HVPS (parallel path also goes to input J1-1 of regulator card)
- Rung 0080
- Move to N7:15
- Negate N7:15
- Overflow bit S:5
- IN 2  Output voltage monitor 2 from HVPS (redundant monitor)
- Rung 0081
- Move to N7:16
- Negate N7:16
- Overflow bit S:5
- IN 3  Output DC current monitor (Danfysik) from the grounding tank
- Rung 0082
- Multiply by 1 and store the product in N7:17
- Why not just use a MOV instruction?
- Rung 0083
- Zero N7:17 if bit 15 is 1 (overflow or negative number)
### Analog Outputs

#### AB-1746-NIO4V  (Slot 8)

- OUT 0  Reference voltage setpoint from VXI control to setpoint (EL1) of regulator board
- Rung 0112
- Move N7:10 to O:8.0
- OUT 1  Second phase control driver to Enerpro board (sum with output of regulator board (over 7.5k resistor) using 1k resistor
- Rung 0113
- Move N7:11 to O:8.1