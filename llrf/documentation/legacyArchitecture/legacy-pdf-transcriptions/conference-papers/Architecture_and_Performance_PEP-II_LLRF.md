# Architecture and Performance of the PEP-II Low-Level RF System

| Field | Value |
|-------|-------|
| **Title** | Architecture and Performance of the PEP-II Low-Level RF System |
| **Author** | P. Corredoura |
| **Organization** | Stanford Linear Accelerator Center, Stanford, CA 94309, USA |
| **Conference** | 19th Annual Particle Accelerator Conference (PAC 99), New York City, NY, March 29 – April 2, 1999 |
| **Publication Number** | SLAC-PUB-8124 |
| **Date** | March 1999 |
| **Pages** | 5 |
| **Source PDF** | `architecture-and-performance-of-the-pep-ii-low-level-rf.pdf` |
| **Funding** | Work supported by Department of Energy, contract DE-AC03-76SF00515 |
| **Contact** | plc@slac.stanford.edu |

> **See also:** [Operator Interface for the PEP-II LLRF Control System](Operator_Interface_PEP-II_LLRF_Control_System.md) — companion paper describing the EPICS-based operator interface for this LLRF system.

---

## Abstract

Heavy beam loading in the PEP-II B Factory along with large ring circumferences places unique requirements upon the low-level RF (LLRF) system. RF feedback loops must reduce the impedance observed by the beam while ignoring the cavity transients caused by the ion clearing gap. Special attention must be placed on the cavity tuner loops to allow matching the ion clearing gap transients in the high energy ring and the low energy ring. A wideband fiber optic connection to the longitudinal feedback system allows a RF station to operate as a powerful "sub-woofer" to damp residual low order coupled bunch motion.

This paper describes the design and performance of the VXI based, EPICS controlled, PEP-II low-level RF system(s). Baseband in-phase and quadrature (IQ) signal processing using both analog and modern digital techniques are used throughout the system. A family of digital down converters provide extremely accurate measurements of many RF signals throughout the system. Each system incorporates a built-in network analyzer and arbitrary RF function generator which interface with Matlab to provide a wide range of functions ranging from automated configuration of each feedback loop to cavity FM processing. EPICS based sequences make the entire system a turn-key operation requiring minimal operator intervention. In the event of a fault, fast history buffers throughout the system write selected RF signals to disk files which can be viewed later to help diagnose problems. Actual data from commissioning runs of PEP-II is presented.

---

## 1. Introduction

Both the high energy ring (HER) and the low energy ring (LER) of the PEP-II B factory are longitudinally unstable due to interaction between the beam and the fundamental mode of the RF cavities. Growth rate from the accelerating mode is determined by the difference of the total real impedance observed by the beam at the synchrotron sidebands corresponding to the mode in question (Equation 1).

### Equation 1. Growth Rate for Fundamental Cavity Mode [1]

$$
\frac{1}{\tau} = \left( \frac{I_0 \eta f_{rf}}{2 \nu_s \beta^2 \frac{E}{e}} \right) R_{cb}
$$

| Symbol | Definition |
|--------|-----------|
| I_0 | Average DC beam current |
| eta | Momentum compaction |
| beta | Particle velocity factor |
| nu_s | Synchrotron tune |
| E | Particle energy |
| e | Electron charge |
| f_rf | RF frequency |
| R_cb | Total real(Z_upper - Z_lower) |

### Figure 1. Cavity Impedance, Beam Revolution Harmonics, Synchrotron Sidebands

> **Description:** Plot of real cavity impedance (kOhms) vs. revolution harmonics from 476 MHz. The x-axis spans -2.5 to +2.5 revolution harmonics from 476 MHz. The y-axis spans 0 to 800 kOhms. The cavity impedance shows a peaked resonance centered near the RF frequency. Synchrotron sidebands are labeled with mode numbers: +2, +1, 0, -1, -2 on both sides of the central peak. Diamond markers indicate the sideband positions relative to the cavity impedance curve.

For storage rings with large circumference, like PEP-II, several revolution harmonics interact strongly with the accelerating mode of the RF cavities. The cavity detuning required to store the high beam currents create a worst case scenario where the peak cavity impedance actually crosses the first revolution harmonic (Figure 1). Evaluating Equation 1 for these conditions produces longitudinal growth rates less than one revolution period. This drove the system design to include several RF feedback loops to reduce the impedance observed by the beam (Figure 2) [1].

The direct RF feedback loop is a simple proportional controller operating on the complex RF vector using the cavities as the bandwidth limiting element(s). The gain of this loop is limited by the system delay and was the driving force for the procurement of wide band (short delay) klystrons. With the 150 ns group delay klystrons we achieved <500 ns total loop group delay and apply 15 dB of direct loop gain. The measured impedance reduction is shown (Figure 3). Notice the peak impedance is reduced as expected but the driving impedance for other modes has actually increased. This effect is caused by the loop delay.

To further reduce the growth rates digital comb filters operate in parallel to the direct loop to apply additional gain at the synchrotron sidebands of the low-order revolution harmonics. Since the combs only have gain over a narrow bandwidth near each synchrotron sideband, they are not limited by the group delay and can contribute an additional 20 dB of impedance reduction. To allow maximum comb gain the variation in group delay beyond the direct loop bandwidth is compensated for with a group delay equalizer filter. The equalized comb correction is digitally delayed to be applied on the next beam revolution. The effect of the comb loop on the cavity impedance is also plotted (Figure 3).

---

## Figure 2. Block Diagram of RF Feedback Loops

> Block diagram of RF feedback loops used in the PEP-II low-level RF system. Multi-cavities not shown.

```
                                         ┌───────────────┐     ┌──────┐
                                         │ klys sat. loop │────▶│ HVPS │
                                         └───────────────┘     └──┬───┘
                                         ┌───────────────┐        │
                                         │  ripple loop   │        │
                                         └───────┬───────┘        │
                                                 │                 │
    station                                      ▼                 ▼
    reference ──────┐               ┌──────────────────┐    ┌──────────┐
                    │               │    klystron       │───▶│   RF     │
    gap loop ──┐    │   ┌───┐      │                   │    │ cavities │
       error ──┤    ├──▶│ Σ │──┬──▶│                   │    └────┬─────┘
               │    │   └───┘  │   └──────────────────┘         │
     ┌─────┐   │    │    + -   │                                 │
     │ mod.│◀──┘    │          │                          ┌──────┴──────┐
     └──┬──┘        │    ┌─────┘                          │ tuner loop  │
        │           │    │                                └─────────────┘
   RF   │     ┌─────┘  ┌─┴────┐
   ref──┘     │        │ mod. │
              │        └──────┘
   fiber ─────┤
   optic      │   ┌─────────────────┐
   link       │   │  direct RF loop │
              │   └─────────────────┘
   band       │   ┌──────────┬────────────┬──────────┐
   limited    │   │ 1 turn   │ delay      │ comb     │      beam ──▶
   kick   ────┘   │ delay    │ equal.     │ filters  │
   signal         └──────────┴────────────┴──────────┘      ┌──────┐
                                                             │  RF  │
              ┌──────────────────────────────────────┐      │  BPM │
              │ longitudinal multi-bunch              │◀─────┴──────┘
              │ feedback system                       │
              └──────────────────┬─────────────────────┘
                                 │
                    to wideband feedback system kicker
```

---

## Figure 3. Measured Real Cavity Impedance

> Measured real cavity impedance with no feedback, direct RF feedback, and also equalized comb feedback.

| Frequency Range | 475 – 477 MHz |
|-----------------|---------------|
| Y-axis | Real Impedance (kOhms), range -100 to 800 |

```
800 ┤
    │        ◇ ← cavity without feedback
700 ┤       ╱ ╲
    │      ╱   ╲
600 ┤     ╱     ╲
    │    ╱       ╲
500 ┤   ╱         ╲
    │  ╱           ╲
400 ┤ ╱             ╲
    │╱               ╲
300 ┤                 ╲
    │  ← direct &     ╲
200 ┤   comb feedback   ╲
    │                     ╲
100 ┤  ◁──── direct        ╲
    │       feedback only   ╲
  0 ┤ "+" marks synchrotron sidebands
    │
-100┤
    └─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┤
        475  475.2  475.4  475.6  476  476.2  476.4  476.6  477
                            frequency — MHz
```

**Key observations:**
- Without feedback, peak cavity impedance reaches ~750 kOhms
- Direct RF feedback reduces the peak impedance but increases impedance at other modes (due to loop delay)
- Combined direct + comb feedback provides the greatest impedance reduction at the synchrotron sidebands

---

## 2. RF Feedback Details

All RF feedback loops use baseband In-phase and Quadrature (IQ) techniques which permit the use of the VXI local bus lines to pass information between modules. This significantly reduces the cable plant, lowers cost and improves reliability. IQ signals are the real and imaginary components of a complex vector and are the equivalent to defining a vector in terms of its X and Y cartesian coordinates as opposed to the polar coordinates, amplitude and phase (Figure 4). The IQ signals are bipolar, uniquely mapping a vector anywhere in the four quadrant system. All the information contained in the modulation of the original RF vector is preserved in the IQ signals. A signal with frequency above the carrier frequency will map to a vector rotating counter clockwise on the complex IQ plane. Signals lower than the carrier frequency become negative frequencies which rotate clockwise. Another advantage of IQ techniques is the electronics for the I and Q channels are identical. This is not true for amplitude and phase based RF control systems.

### Figure 4. IQ vs. Phase/Amplitude Mapping

```
                imaginary axis
                     Q
                     │
              RF     │
           ╱  A      │    angle = θ
         ╱            │  ╱
       ╱              │╱
  ────────────────────┼────────────── real axis I
                      │
```

| Conversion | Formula |
|-----------|---------|
| I component | I = A cos θ |
| Q component | Q = A sin θ |
| Amplitude | A = sqrt(I² + Q²) |
| Phase | Φ = atan2(Q, I) |

### Baseband IQ Modulator

To provide adjustable gain and phase shifts of IQ vectors a baseband IQ modulator is used. This circuit is an analog representation of a scaled rotation matrix. An input vector can be scaled and rotated by any amount determined by the four multiplier weights (Equation 2). Also note that any phase procession can be made without step discontinuities (unlike RF phase shifters).

### Equation 2. Matrix Form of a Baseband IQ Modulator

```
┌       ┐       ┌                  ┐ ┌      ┐
│ I_out │       │ cos θ    -sin θ  │ │ I_in │
│       │ = A * │                  │ │      │
│ Q_out │       │ sin θ     cos θ  │ │ Q_in │
└       ┘       └                  ┘ └      ┘
```

### Figure 5. Block Diagram of One IQ Baseband Modulator

> Constructing a baseband analog IQ modulator requires four 4-quadrant multipliers and two summing amplifiers to perform the matrix mathematics.

```
    I to I weight ──▶[X]◀── I input ──┐
                                       │  +
                                       ├──▶[Σ]──▶ I output
                                       │  -
    Q to I weight ──▶[X]◀── Q input ──┘

    I to Q weight ──▶[X]◀── I input ──┐
                                       │  +
                                       ├──▶[Σ]──▶ Q output
                                       │  +
    Q to Q weight ──▶[X]◀── Q input ──┘
```

> **Note:** Each output receives contributions from **both** I and Q inputs. The minus sign on the Q-to-I path into the I output corresponds to the −sin θ term in the rotation matrix (Equation 2).

Digital to analog converters (DACs) are used to produce the multiplier weights. Note that if the sign for the -sin θ term is handled as part of the summing circuit, only two weight values are required. We choose to use an individual DAC channel for each modulator weight to allow the multiplier offsets to be corrected for as part of each DAC weight.

The PEP-II Baseband IQ modulators use four AD834 [13] multipliers and two EL2073 [14] wideband op-amps to achieve <5 ns group delay, >40 MHz full power bandwidth and >50 dB dynamic range. A total of 7 baseband IQ modulators were used in the system requiring 28 DAC channels. Additional channels were used to null analog offsets. A total of 56 "slow" DAC channels were used. AD7805 8 channel, 12-bit DACs [13] were used to achieve the density and resolution required.

### IQ Demodulation and Cavity Signal Processing

RF signals from each of the cavity probes (4 in HER, and 2 in LER) are converted to analog IQ baseband signals using high level (+13 dBm) IQ demodulators [11]. The mixer outputs are AC coupled into 50 ohms, providing a good match and lowpass filtered (Fc = 225 MHz) to remove any RF. Video amplifiers provide sufficient gain (17 dB) to produce 1 volt maximum IQ signals for 0 dBm RF inputs. This level is fixed by the input specification for the AD834 multipliers [13] used in the IQ baseband modulators throughout the system.

Each demodulated cavity probe signal passes through a programmable combining network consisting of four IQ baseband modulators and two summing amplifiers. By setting the proper DAC values for each modulator, the resulting IQ signals represent the total accelerating RF vector for the station. Another baseband modulator operating on the vector sum allows adjusting the gain and phase of the direct RF feedback loop (Figure 2). This modulator is also used to maintain loop phase as the cavities detune.

The output of the direct loop modulator is compared to the station IQ reference by a pair of difference amplifiers, producing IQ error signals which are then amplified 15 dB. The error signals are used by the "gap loop" DSP to generate the station IQ references which may vary on a one-turn time frame to track any shape of ion clearing gap transient [3]. The adaption rate is set for 100 ms. When converged the IQ error signals (klystron drive) are constant.

### Direct Loop Compensation

Since the signals are all baseband, applying additional compensation to the direct loop is a simple way to achieve superior performance. Lead-lag compensation is used to provide increased phase margin when the cavities are detuned for full beam current. This decreases the closed loop translation of imaginary to real cavity impedance, further reducing the peak driving impedances by 25%.

Integral compensation provides large gains at frequencies close to the RF carrier. With a 30 kHz bandwidth integrator, large modulation caused by the switching aspect of the klystron high voltage power supply ripple is rejected.

### Ripple Loop and Gain Tracking

As beam is injected, the klystron output is increased by raising the cathode voltage. The resulting phase shift is corrected for by a DSP based "ripple" loop observing the IQ error signals and the klystron output [7]. Correction is applied to another baseband modulator at a 23 kHz rate. A slow (2 Hz) EPICS loop writes a set point in the ripple loop to maintain constant gain through the forward path of the direct RF feedback loop as the klystron output rises.

### Drive Signal Path

The error signals are limited with diode clamping circuits to prevent over-driving the solid state drive amplifier or klystron during transients. Finally the IQ drive signals are converted to currents and up-converted by an IQ RF modulator [11]. This high level modulator uses a +23 dBm LO and can produce enough power (+8 dBm) to directly drive the 120 W klystron drive amplifier.

### Comb Filters

The comb filters AC couple to the direct loop just after the direct loop modulator so the cavity frequency offset tracking applies to both loops. The IQ signals are digitized and filtered in second order IIR digital filters (Equation 3). The comb filter response peaks at synchrotron sidebands and has a zero at the revolution harmonics [1].

### Equation 3. Dual Peak Comb Filter Transfer Function

```
         G(Z⁰ - Z⁻⁷²)
H(z) = ──────────────────────────────────────
        1 - 2K cos(2π ν_s) Z⁻⁷² + K² Z⁻¹⁴⁴
```

| Symbol | Definition |
|--------|-----------|
| G | Forward gain |
| Z⁻⁷² | 1 turn delay |
| nu_s | Synchrotron tune |
| K | Reverse gain |

### Group Delay Equalization

The digital output from each comb filter is next filtered by 32 tap FIR filters. These filters perform both group delay equalization and bandwidth limiting. The equalizer is designed for the worst-case of full cavity detuning and keeps phase linear to <10 degrees over a 4 MHz bandwidth (Figure 6). Filter gain roll-off begins at 1.1 MHz.

### Figure 6. Measured Response Without/With Equalization

> **Description:** "Measured Deviation from Linear Phase — Raw and Equalized". Plot of error from linear phase (degrees) vs. baseband frequency (kHz). X-axis: -2000 to +2000 kHz. Y-axis: -60 to +80 degrees. The raw non-equalized response (dash-dot line) shows phase deviations exceeding 60 degrees at the band edges. The equalized response (solid line) maintains phase error within approximately ±10 degrees over the 4 MHz bandwidth.

After the equalizer filters a partial turn delay is added to make the total delay for the comb path exactly one turn. Shift registers running at four times the comb sample rate provide vernier delay adjustment in 25 ns steps. Once adjusted, the phase response repeats at every revolution harmonic. The IQ digital outputs are then converted to analog voltages and summed to the direct loop output.

### LFB Sub-Woofer

The final RF feedback loop is the "sub-woofer". A band limited (4 MHz) kick signal from the LFB system is sent over dedicated 10 bit fiber optic links running at 10 MHz. The data is group delay equalized and delayed (just as the comb filters) before modulating the station IQ reference phase. High loop gains (30 dB) and very strong damping is achieved for the low-order (|n|<10) longitudinal modes.

---

## 3. Hardware Details

The PEP-II LLRF system [2] is based on 6 types of custom VXI modules, an off-the-shelf slot 0 controller/processor and an Allen Bradley (AB) VME scanner (Figure 7). The processor is a National Instruments 68030 running the VxWorks real-time operating system which is supported by EPICS [5]. The AB scanner supports a serial communication link with the Allen Bradley hardware used for slow interlocks (temperatures, water flows, power supply monitoring), control of cavity tuner stepper motors and control of the klystron high voltage power supply (HVPS).

The clock/RF distribution module generates a 471.1 MHz LO and several digital system clocks. Special attention is paid to resynchronizing the PLL divider counters with a turn clock fiducial so the digital IQ detectors restore phases after a system reboot. The arc/interlock module detects window arcs, VXI faults and handshakes with the HVPS triggers and beam abort system [4].

### Figure 7. PEP-II LLRF System VXI Crate Topology (HER)

> VXI crate slot assignment for the HER LLRF system.

| Slot | Module | Key Connections |
|------|--------|-----------------|
| 1 | Slot 0 Microprocessor | Ethernet |
| 2 | AB Scanner | To AB system (serial link) |
| 3 | Clock/RF Distribution | 476 MHz reference in; 471.1 MHz LO out |
| 4 | Gap Voltage Feed-Forward | Multi-bunch "kick" (fiber optic) |
| 5 | RFP Module | Cavity probes (4), RF out, direct/comb out, drive |
| 6 | Comb Filter (I) | — |
| 7 | Comb Filter (Q) | — |
| 8 | IQ/Amp Detector 1 | Station RF inputs (24) |
| 9 | IQ/Amp Detector 2 | — |
| 10 | IQ/Amp Detector 3 | — |
| 11 | Arc/Interlock Detector | Interlocks, HVPS trigger |
| 12–13 | Spare (2) | — |

**External connections:**
- 476 MHz reference input
- Cavity probes (4 for HER)
- Station RF inputs (24 channels)
- Multi-bunch "kick" signal (fiber optic link)
- Ethernet (to EPICS network)
- AB system serial link (to Allen-Bradley PLC hardware)
- HVPS trigger output
- Interlocks

### RF Processing Module (RFP)

The RF Processing module (RFP) contains hardware to down convert the cavity probe signals, implement the direct and ripple loops, interface with the gap and comb modules and generate the low-level klystron drive. In addition a built-in 10 MHz baseband arbitrary IQ function generator/recorder forms a very inexpensive programmable network analyzer capable of performing a wide range of functions (Figure 8). This feature has proven to be extremely useful if not essential. It provides the ability to automatically configure and remotely monitor the system through Matlab application scripts calling EPICS [9]. The network analyzer can be placed in continuous mode to catch RF faults or inject dynamic IQ reference signals from files to FM process the cavities.

### Figure 8. Block Diagram of the Baseband Network/Spectrum Analyzer

> Maximum resolution for FFT's is 18 Hz/bin.

```
    cavity probes (4) ──▶ I ADC ──▶ 512 K ──┐
                         Q ADC ──▶ 512 K    │
                                             │
    direct out ─────────▶ I ADC ──▶ 512 K    ├──── VXI bus
    comb out                                 │
    drive ──────────────▶ Q ADC ──▶ 512 K    │
    injected signal                          │
                                             │
                         512 K ──▶ I DAC ──▶ I out
                         512 K ──▶ Q DAC ──▶ Q out
                                             │
                         state machine ──────┘
```

### IQA Detector Modules

The IQA detector modules are 8 channel RF receivers using a digital down conversion technique for precise narrow-band measurements (Figure 9) [6]. Each RF input is mixed with the LO to produce 4.9 MHz IF. A single ADC samples all eight IF's in a sequence which measures I, Q, -I, -Q for each channel. The -I and -Q samples are inverted to cancel out any mixer offsets. Programmable decimating digital filters (DDF) lowpass each IQ sample and provide 16 bit outputs [12]. This detection technique provides phase accuracy of <0.1 degree over a 50 dB dynamic range. All IQ measurements are transmitted to the EPICS database at a 2 Hz rate for station RF displays and the "slow" feedback loops (cavity tuners, cathode voltage control and direct loop gain tracking). Channel one of IQA module #1 measures the klystron output and interfaces to a serial link to support the ripple loop.

### Figure 9. Block Diagram of IQ Digital Down Conversion

```
    476 MHz RF ──────────────────────────────── clock module
    reference                                   471.1 MHz LO
                                                    │
    476 MHz RF                        VXI backplane │  turn clock
    signal ──▶[X mixer]──▶[BP filter]──▶[gain]──┐  clock    fiducial
    (unknown)    │         4.9 MHz              │  19.6 MHz
                 │                              │     │
              471.1 MHz LO                      │  ┌──┴──┐
                                                ▼  │     │
                                        ┌───────────┐    │
                                        │  mux 8:1  │    │
                                        └─────┬─────┘    │
                                              │          │
                                        ┌─────▼─────┐   │
                                        │  ADC       │   │
                                        │  12 bit    │◀──┘
                                        └─────┬─────┘
                                              │ I,Q,-I,-Q
                                        ┌─────▼──────────┐
                                        │ multiplier and │
                                        │ demux           │
                                        └──┬──────────┬──┘
                                (2 of 16)  │          │
                                      I,-(-I)    Q,-(-Q)
                                           │          │
                                    ┌──────▼──┐ ┌─────▼───┐
                                    │ Harris  │ │ Harris  │
                                    │ DDF     │ │ DDF     │
                                    │ filter I│ │ filter Q│
                                    └────┬────┘ └────┬────┘
                                         │           │
                                   measured I   measured Q
                                    16 bit       16 bit
```

### Linear Diode Detectors and Fault Recording

Linear diode detectors in the IQA (amplitude) modules are used for wide-band amplitude detection required for hardwired RF interlocks. A single 10 MHz ADC records any of the wideband outputs into a 512K circular buffer which is frozen and written to a file after a system fault (Figure 10). Similar transient recorders exist in the comb filters, RFP and the gap module which provide a method to "see" faults which occur when no one is watching.

### Figure 10. Automatically Recorded Cavity Reflected Power Transient

> IQA Module #2 Fault File — Cavity A Reflected, Feb 09, 1999 15:41:40

| Parameter | Value |
|-----------|-------|
| Event | Aborting a 500 mA beam in the HER |
| Time span | 13.3 – 13.35 ms |
| Peak reflected power | ~250 kW (raw), ~200 kW (filtered) |
| Trip level | Indicated on plot as horizontal reference line |
| Traces shown | Raw (solid), Filtered (dashed), Trip level (dotted) |

---

## 4. Coupler Directivity

The shape of the beam phase transient caused by the 5% ion clearing gap must be matched in the two rings to keep the collisions centered in the BaBar detector. Errors in cavity tuning can alter the shape of the transients and lower luminosity. The high power couplers before each cavity were found to have 20 dB of directivity, insufficient for the stringent cavity tuning requirements. A Matlab script using the built-in network analyzer, programmable tuner controls and RF measurements from the IQA modules was written. It determines the complex directivity of each coupler and generates a correction matrix (Equation 4) which is written into the EPICS based tuner control loop.

### Equation 4. Matrix Formula to Correct Coupler Directivity

```
┌              ┐     ┌                       ┐⁻¹  ┌                   ┐
│ forward RF   │     │  1          D_reflected│    │ forward_measured  │
│              │  =  │                        │    │                   │
│ reflected RF │     │  D_forward    1        │    │ reflected_measured│
└              ┘     └                       ┘    └                   ┘
```

The procedure operates the klystron at constant power and phase while taking nine measurements as the cavities are tuned over a +/-100 kHz range. The network analyzer measures the exact resonant frequency at each point while the IQA module provides the complex forward, reflected and probe vectors. The data are fit to a model, directivities extracted and the correction matrices in IQ format are written to the EPICS tuner database. Phase errors were reduced to <1 degree (Figure 11). This is an excellent example of the flexibility and performance of a modular LLRF system topology with instrumentation built-in.

### Figure 11. Raw and Directivity Corrected Forward RF Vector

> "Cavity Forward Directivity Measurements"

**Upper plot — Magnitude:**
- X-axis: cavity offset frequency, -100 to +100 kHz
- Y-axis: magnitude, 1.05 to 1.20
- Three traces: measured (diamonds), corrected (circles), model (plus signs)
- Raw measured data shows ~10% magnitude variation across the tuning range
- Corrected data closely matches the model with magnitude variation <1%

**Lower plot — Phase:**
- X-axis: cavity offset frequency, -100 to +100 kHz
- Y-axis: phase, -4 to +4 degrees
- Raw measured data shows up to ±3 degree phase errors
- Corrected data shows phase errors reduced to <1 degree

---

## 5. Beam Phase Detector

The LER RF stations have only two klystrons/cavities so each LER RFP module has two unused analog IQ detector channels driving 12 bit ADC's and 512 K memories. We connected two unused channels to HER and LER BPM's through a pair of high Q 476 MHz bandpass filters to form online beam phase detectors for each ring. Data from the detectors are synchronized to the turn clock, allowing gap transients to be compared. A Matlab script called by EPICS provides modal analysis at the touch of a button (Figure 12). Motion is 0-mode <0.5 degrees attributed to the master oscillator which has since been improved [10].

### Figure 12. Longitudinal Modes in the LER with 350 mA Beam

> "Spectral Analysis of 32 Samples per Turn — LER (20-Jan-1999 05:51)"

- Measured with on-line beam phase detector
- Shows spectral analysis of longitudinal modes
- 0-mode motion: <0.5 degrees (attributed to master oscillator)

---

## 6. Conclusion

To date the HER and LER have stored >750 mA and >1100 mA respectively, limited by heating in temporary vacuum chambers. All RF feedback loops perform as designed to damp longitudinal coupled bunch modes strongly driven by the accelerating mode of the RF cavities. The PEP-II RF system has proven to be reliable, flexible and easy to operate. The use of EPICS state sequences has reduced the operation of the complex system to an on/off button for the users. Development of the EPICS summoned Matlab scripts has formed an expert system, allowing the very complicated configuration and testing tasks to be completed quickly by non-expert users.

---

## Acknowledgements

I would like to thank everyone who worked on this project, especially Flemming Pedersen of CERN who conveyed his expertise of RF feedback to us early in the project. I would also like to express appreciation to the PEP-II management for giving us carte blanche to build a system which incorporates many new techniques.

---

## 7. References

1. F. Pedersen, "RF Cavity Feedback", SLAC-400, November 1992.
2. P. Corredoura et al, "Low Level System Design for the PEP-II B Factory", PAC 95.
3. W. Ross, R. Claus, L. Sapozhnikov, "Gap Voltage Feed-Forward Module for the PEP-II Low-Level RF System", PAC 97.
4. R. Tighe, "Arc Detection and Interlock Module for the PEP-II Low Level RF System", PAC 97.
5. S. Allison, R. Claus, "Operator Interface for the PEP-II Low Level RF Control System", PAC 97.
6. C. Ziomek, P. Corredoura, "Digital I/Q Demodulator", PAC 95.
7. P. Corredoura, "Development of Digital Control for the PEP-II Klystrons", SLAC PEP-II Tech Note #60, 1994.
8. J. Fox et al, "Bunch-by-Bunch Longitudinal Feedback System for PEP-II", EPAC 94.
9. P. Corredoura et al, "Commissioning Experience with the PEP-II Low-Level RF System", PAC 97.
10. R. Tighe, "A Sampled Master Oscillator for the PEP-II B Factory", PAC 99 (this conference).
11. Pulsar Microwave Corporation, Clifton, NJ 07012.
12. Harris Semiconductor HSP43220, Melbourne, FL 32919.
13. Analog Devices, Norwood, MA 02062.
14. Elantec Semiconductor, Milpitas, CA 95035.
