# SPEAR3 Direct-Loop Noise / Damping Decoupling Measurement

*Accelerator Physics study plan — gain scan with frequency-offset tracking off, cavity-probe spectrum as the beam signal*

Draft for discussion | SSRL RF | Companion to Doc P §8

---

## 1. Purpose

The stored beam shows larger synchrotron oscillation than in earlier years, largest near 200 mA. The oscillation amplitude depends on two things the direct loop sets at the same time: the **RF field noise that drives the dipole mode** and the **damping of that mode**. Changing loop gain moves both in opposite directions, so a single amplitude measurement cannot say which one to fix.

This study separates the two at several beam currents. At each current the direct-loop gain is stepped over a small set of values with the loop phase held fixed and frequency-offset tracking off. From the cavity-probe spectrum alone we extract, at every point, the damping rate $\sigma$, the coherent frequency $f_{coh}$ and the drive spectral density $S_{eff}$. A closed-loop response measurement at the same point gives the loop transfer needed to identify where the drive noise originates.

**Deliverable:** for each current, the noise and damping contributions to the oscillation amplitude versus gain, the dominant noise source, and the gain that minimizes beam motion while keeping the Robinson margin of Doc P §8.8 ($Q \le 35$).

---

## 2. Measurement principle

### 2.1 The dipole mode as a driven, damped oscillator

With an external RF phase error $\psi(t)$ and relative amplitude error $a(t)$ at the gap, the dipole ($n = 0$) motion obeys

$$
\ddot{\Delta\phi} + 2\sigma\,\dot{\Delta\phi} + \omega_{coh}^2\,\Delta\phi = \omega_s^2\,n_{eff}(t),
\qquad n_{eff} = \psi + a\cot\phi_s \tag{1}
$$

$\sigma$ and $\omega_{coh}$ are the root of the characteristic equation of Doc P Eq. (8.3); they contain the cavities, the loop and the beam current. $n_{eff}$ is the RF error that does not come from the beam motion itself. At $\phi_s = 67.5^\circ$, $\cot\phi_s = 0.41$: the beam responds to the combination of phase and amplitude noise in Eq. (1), not to either separately.

For broadband drive the motion is a Lorentzian line of full width $\sigma/\pi$ centred at $f_{coh}$, with variance

$$
\langle\Delta\phi^2\rangle = \frac{\omega_s^4}{8\,\omega_{coh}^2}\,\frac{S_{eff}(f_{coh})}{\sigma} \tag{2}
$$

Equation (2) is the decoupling relation: the beam motion is the drive density at the line divided by the damping rate. $Q_s = \omega_{coh}/2\sigma$ is the quality factor of the beam line, not of the cavity.

### 2.2 What the cavity-probe spectrum contains

The probe sees the total gap field. Near $f_{coh}$ that field is the RF noise that drives the beam plus the field the oscillating beam induces through the closed-loop impedance $Z_b = Z_{cav}/(1+G_{OL})$. Because the beam motion is itself driven by $n_{eff}$, the two add coherently:

$$
S_{probe}(f) = S_{eff}(f)\,\bigl|1 + K(f)\,H_b(f)\bigr|^2 + S_{inst}(f) \tag{3}
$$

$H_b$ is the beam response of Eq. (1), $K \propto I_{b1} Z_b / V_{gap}$ couples beam motion back into the field, and $S_{inst}$ is the analyzer floor. Three properties make the probe a complete beam signal:

- **Away from the line** ($|f - f_{coh}| \gg \sigma/2\pi$), $H_b \to 0$ and the spectrum is the drive itself: the local floor measures $S_{eff}$ directly.
- **The line shape** gives $\sigma$ (width) and $f_{coh}$ (centre). Because $K H_b$ is complex, the line can be asymmetric (Fano shape); the fit must allow this rather than assume a pure Lorentzian.
- **The line strength** relative to the floor is $|K H_b|$, i.e. the beam response times $I_{b1}|Z_b|$. Dividing by $I_{b1}|Z_b(f_{coh})|$ gives the beam phase motion. This step needs $|1+G_{OL}(f_{coh})|$ from the closed-loop measurement, because $Z_b$ changes with gain.

> **Consequence.** From one probe record we obtain $\sigma$, $f_{coh}$, the drive $S_{eff}$ (floor) and the beam motion (line strength). Equation (2) must then hold between them. If the measured beam motion exceeds the value predicted from the RF floor, the excess is driven by something outside the RF field (injection, fill changes, other sources).

### 2.3 Separating noise and damping

Between any setting $k$ and the baseline $0$ at the same current, Eq. (2) splits the change in beam motion exactly:

$$
\ln\frac{\langle\Delta\phi^2\rangle_k}{\langle\Delta\phi^2\rangle_0}
= \underbrace{\ln\frac{S_{eff,k}}{S_{eff,0}}}_{\text{noise}}
- \underbrace{\ln\frac{\sigma_k}{\sigma_0}}_{\text{damping}}
- 2\ln\frac{\omega_{coh,k}}{\omega_{coh,0}} \tag{4}
$$

The first term is the noise contribution, the second the damping contribution, the third a small frequency term. Only ratios enter, so the absolute probe calibration cancels.

### 2.4 Identifying the noise source from the gain scan

The drive at the gap is the sum of noise entering upstream of the cavity, suppressed by the loop, and noise entering at the sensor or reference, passed by the closed loop $T = G_{OL}/(1+G_{OL})$:

$$
S_{eff,k}(f_{coh}) = \frac{S_{up}}{\bigl|1+G_{OL,k}(f_{coh})\bigr|^2} + S_{sens}\,\bigl|T_k(f_{coh})\bigr|^2 \tag{5}
$$

With four or five gains and $|1+G_{OL}|$, $|T|$ taken from the closed-loop fit at the same setting, a linear fit of Eq. (5) returns $S_{up}$ (klystron, HVPS lines above the ripple-loop band, drive chain) and $S_{sens}$ (probe, demodulator, reference DAC). Raising gain helps only against $S_{up}$.

---

## 3. Configuration

### 3.1 Why frequency-offset tracking is off

With tracking on, the applied loop phase is `PHASE.L = PHASE.C + φ_tr`, where $\phi_{tr}$ is computed from the IOC tuner model. On 7 October 2026 $\phi_{tr}$ was $+11.6^\circ$, against $+7.2^\circ$ implied by the physical detuning, and it drifted by $3$–$6^\circ$ during 8 October (Doc P §8.7). During a gain scan this term would change the phase uncontrollably and alias into the damping result. With tracking off, the applied phase is the commanded `PHASE.C` and is identical at every point of a current's gain scan.

Cost: without tracking, the loop delay rotates the phase seen at the operating detuning by up to about $+8^\circ$ (towards lead) at 500 mA (Doc P §8.4, rule 4). Lead is the damping-safe direction; the shift is recorded and included in the model comparison.

### 3.2 Phase setting

- **Phase set A (primary):** `PHASE.C` chosen so the fitted loop phase is $\theta \approx 0$ at low current. Table 25 of Doc P puts this near $-19^\circ$; confirm with a closed-loop measurement at the first current and hold the value for the whole study.
- **Phase set B (optional, 200 and 500 mA):** about $5^\circ$ more lead (`PHASE.C` ≈ −24°), gains 0, −3 and +1.5 dB only. This checks that phase moves mainly $\sigma$ while gain moves mainly $S_{eff}$.

### 3.3 Switching tracking off

1. Do this at the lowest study current, where the detuning and therefore $\phi_{tr}$ are smallest.
2. Record `PHASE.L`, `PHASE.C`, the tracking state and `FREQ:OFFS` of all four cavities.
3. Turn tracking off. The total-phase record is rate-limited (`subSysPhaseTot`), so `PHASE.L` ramps rather than steps; wait until it settles.
4. Set `PHASE.C` to the phase-set-A value in ≤ 2° steps and verify that `PHASE.L` follows.
5. Restore the original `PHASE.C` and tracking state at the end of the study, in reverse order.

### 3.4 Held fixed throughout

| Item | Condition |
|---|---|
| Integral / lead compensation | Operating states (`INTCOMP` and `LEADCOMP` on); record |
| Ripple loop and gain tracking | On, as in operation; record DC coefficient |
| Tuner loops | On; wait for load-angle errors < 1° after each change |
| DAC and HVPS loops | On; wait for status GOOD |
| Gap voltage | Operating 2.85 MV |
| Fill pattern | Operational pattern, unchanged within a current |
| Top-off | Paused during records, or injection times logged and excluded |

---

## 4. Scan matrix

### 4.1 Currents

**100, 200, 350 and 500 mA.** 200 mA carries the largest observed oscillation and is the first priority; 100 mA has the smallest natural damping; 500 mA is the operating point. Each current is held by stopping top-off and letting the beam decay slowly through the measurement window, or by topping off between records.

### 4.2 Gain steps

Steps are relative to the operating setting `COUNTS.A` = 1.3 dB. A ±1 dB span is too small: it changes $1/|1+G|^2$ and $\sigma$ by only 15–20 %, comparable with the 7 % repeatability of $\sigma$ (8 October: 1086 vs 1160 s⁻¹).

| Step | ΔCOUNTS.A | Absolute | Condition |
|---|---|---|---|
| 1 | 0 | 1.3 dB | Baseline |
| 2 | −1.5 dB | −0.2 dB | — |
| 3 | −3 dB | −1.7 dB | Field regulation in tolerance; 360/720 Hz lines < +10 dB from baseline |
| 4 | 0 | 1.3 dB | Repeat: drift and repeatability |
| 5 | +1.5 dB | 2.8 dB | Line $Q \le 35$ at step 4 |
| 6 | +3 dB | 4.3 dB | Only if step 5 gives $Q \le 30$. Exceeds the Doc P §8.8 guidance of $G \le 3$ dB at 500 mA; skip at 500 mA unless margin is measured |
| 7 | 0 | 1.3 dB | Closing repeat |

Lower gain is taken first because it raises damping. Gain changes are made in ≤ 0.5 dB increments. On the legacy RFP, `COUNTS.A` also scales the integral path and the IOC conversion constant $(1 + \text{COUNTS.L})$, so the DAC loop re-settles after each step.

---

## 5. Procedure at each point

| # | Action | Detail |
|---|---|---|
| 1 | Set `COUNTS.A` | ≤ 0.5 dB increments |
| 2 | Settle | DAC/HVPS status GOOD, load-angle errors < 1°, drive power and gap voltage steady (≈ 1–2 min) |
| 3 | Snapshot | `COUNTS.A/.L`, `PHASE.C/.L`, tracking state, current, fill, $f_{RF}$, four cavity voltages, tuner positions, `FREQ:OFFS`, load angles, drive and forward power, HVPS voltage, klystron gain, ripple DC coefficient |
| 4 | Probe record, line | Three records, Section 6 settings, both sidebands |
| 5 | Probe record, wide | One ±50 kHz record for the floor shape; one 3 Hz RBW record of the 360/720 Hz lines |
| 6 | Closed-loop response | After the probe records (noise injection disturbs the line). Save raw `DIRECT_I/Q_CLOSED` records |
| 7 | Probe record, check | One line record to confirm the state is unchanged after injection |
| 8 | Stop-criteria check | Section 8, before the next step |

About 6–8 minutes per point; seven points per current; about one hour per current, 4–5 hours for four currents plus phase set B.

---

## 6. Probe-spectrum acquisition

- **Signal:** cavity-A probe into the R&S FSW, as used on 8 October. If a vector-sum or second probe signal can be connected, record it as well; the beam responds to the vector sum, and one cavity can carry its own tuner or microphonic noise.
- **Preferred mode, I/Q capture:** complex baseband around $f_{RF}$, ≥ 100 kS/s, ≥ 10 s per record. Demodulate to phase and relative-amplitude time series, form their spectra, and form $n_{eff} = \psi + a\cot\phi_s$ directly. This separates AM and PM and keeps the phase of the beam term needed for the Fano fit.
- **Fallback, swept spectrum:** 20 kHz span centred on each sideband $f_{RF} \pm f_{coh}$, 30 Hz RBW, RMS detector, ≈ 100 power-averaged sweeps, as on 8 October. Gives combined AM+PM only.
- **Resolution:** at $\sigma \approx 1100$ s⁻¹ the line FWHM is ≈ 350 Hz; at $Q = 35$ it is ≈ 250 Hz. 30 Hz resolution or better is adequate. Record length must be long compared with $1/\sigma$ and short compared with current decay.
- **Reference:** note how the FSW is referenced. Master-oscillator phase noise at $f_s$ is part of the drive; if the FSW is locked to the master oscillator, that component is partly removed from the measurement.
- **Analyzer floor:** record $S_{inst}$ once per session with the input terminated, at the same settings.

---

## 7. Analysis

### 7.1 Per record

1. Convert to dBc/Hz relative to the carrier (or to phase and amplitude PSDs for I/Q data); subtract $S_{inst}$.
2. Fit Eq. (3) over $f_{coh} \pm 5$ kHz, each sideband separately: free parameters $S_{eff}$ (flat or linear over the window), coupling amplitude and phase of $K H_b$, $\sigma$ and $f_{coh}$. Report the fit residual.
3. Flag narrow spikes on the line (a line drive near $f_{coh}$: Eq. (2) no longer applies, use the narrow-line form) and non-Lorentzian broadening ($f_{coh}$ not steady during the record: the width overestimates $\sigma$).
4. Average the three repeats; their scatter is the error.

### 7.2 Per point

1. From the closed-loop record, fit the full loop model (lead and lag networks, klystron $s$, $\kappa$ at ≥ 350 mA) within ±25 kHz of the carrier — not the RFgui window, which blanks ±18 kHz — and evaluate $|1+G_{OL}|$ and $|T|$ at $\pm f_{coh}$. Also fit the beam pole pair for an independent $\sigma$, $f_{coh}$.
2. Beam motion from line strength:
   $$\langle\Delta\phi^2\rangle \propto \frac{|K H_b|^2}{I_{b1}^2\,|Z_b(f_{coh})|^2}$$
3. Beam motion predicted from the floor: Eq. (2) with $S_{eff}$ and $\sigma$. Compare with item 2.

### 7.3 Per current

1. Normalize all quantities to the baseline step and apply Eq. (4): noise, damping and frequency contributions versus gain.
2. Fit Eq. (5) to obtain $S_{up}$ and $S_{sens}$.
3. Compare $\sigma(G)$ and $f_{coh}(G)$ with the Doc P §8.2 model at the measured settings.
4. Find the gain minimizing $S_{eff}/\sigma$ subject to $Q \le 35$.

---

## 8. Stop criteria

Return to the baseline gain and stop the scan at that current if any of the following occur:

- Line $Q > 35$, or $Q$ increases by more than 30 % in one step.
- Sideband growing, splitting, or $f_{coh}$ moving towards the incoherent 10 kHz.
- Beam loss, RF trip precursors or MPS warnings.
- Gap DAC above 0.95 of full scale, drive approaching the saturation setting, or forward power at the IOC limit (99 % on 7 October).
- At low gain: field regulation out of tolerance, or 360/720 Hz lines more than 10 dB above baseline.

---

## 9. Interpreting the results

| Result | Meaning and action |
|---|---|
| $S_{eff} \propto 1/\lvert 1+G_{OL}\rvert^2$ | Upstream noise dominates. Raise gain as far as damping allows; reduce the source (klystron, HVPS) |
| $S_{eff}$ flat or rising with gain | Sensor or reference noise. More gain does not help; locate and reduce the source |
| Beam motion > Eq. (2) prediction from the floor | Non-RF drive (injection, fill). Look outside the LLRF |
| Motion tracks $1/\sigma$, $S_{eff}$ constant | Damping-limited. Optimize phase and gain for $\sigma$ |
| Narrow spike on the line | Line drive near $f_{coh}$; check whether $f_{coh}$ crosses it as current changes |
| Phase set B moves $\sigma$ but not $S_{eff}$ | Confirms the separation; phase is the damping knob, gain the noise knob |

The same analysis answers the open question from the SPARK comparison with 2014: whether the larger present oscillation is mainly more drive or less damping. The measured damping has roughly halved since 2021, which for broadband drive accounts for about a factor $\sqrt{2}$ in amplitude, not the factor 3 observed.

---

## 10. Preparation and open issues

1. Test the FSW I/Q capture and the Eq. (3) fit on existing 8 October data and on a dry run at low current.
2. Write the ±25 kHz closed-loop fitting script with the integral path and the klystron $s$, $\kappa$ model.
3. Write the snapshot script (Section 5, step 3).
4. Verify that the closed-loop routine restores the mux, DAC and acquisition states on every exit path; the present source returns early on several errors without cleanup.
5. Confirm the tracking-off procedure and `PHASE.L` behaviour with the RF group before the AP.
6. Agree the stop criteria and top-off handling with operations and with J. Safranek, so SPARK data can be taken in parallel as an independent check.
