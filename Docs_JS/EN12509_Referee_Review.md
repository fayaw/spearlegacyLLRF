# Referee Report — Manuscript EN12509

## Physical Review E — Regular Article

**Title:** *Humidity as a critical parameter for predicting breakdown voltage in submicrometer electrode gaps in air*

**Authors:** B. Disson, R. Dussart, S. Iseni, N. Bonifaci, O. Lesaint, C. Poulain

**Reviewer's Recommendation:** Publish after **major revisions**

---

## I. Summary of the Manuscript

This manuscript presents an experimental study of electrical breakdown voltage (V_b) in air for electrode gaps ranging from 0.10 µm to 6.00 µm, with a specific focus on the effect of gas-phase humidity — a parameter rarely controlled or documented in prior microgap breakdown studies. The authors employ gold-coated needle-plane electrodes, piezoelectric actuation for sub-micrometer positioning, a fast switching detection circuit, and a statistical methodology based on distributions of 100 breakdown events per condition. Humidity is varied from dry synthetic air (T_dew < −40 °C) to moderately humid conditions (T_dew = 10 °C, corresponding to ~39% RH at 25 °C).

The main findings are:

1. **Deviation from Paschen's law** is confirmed for gaps < 2 µm, with a quasi-linear V_b increase rather than the classical Paschen curve.
2. **Two competing breakdown mechanisms** are identified via bimodal V_b distributions — a field emission (FE) mechanism and a Townsend avalanche (A) mechanism — extending the approach of Disson et al. [1] from argon to molecular air.
3. **Counter-intuitive humidity effect:** In macroscopic discharges, humidity is known to *increase* V_b. In sub-micrometer gaps, the authors demonstrate that humidity *drastically reduces* V_b. The critical field for FE-mechanism breakdown drops from 0.86 V/nm (dry) to 0.26 V/nm (T_dew = 10 °C).
4. **Mechanistic hypotheses:** The reduction is attributed to (i) adsorbed water layers reducing the effective work function of the electrodes, enhancing field emission, and (ii) Taylor cone formation on the water film under high electric field, which locally enhances the field and reduces the effective interelectrode distance.

---

## II. Assessment of Significance and Novelty

### Strengths

This work makes a **genuinely significant contribution** to the physics of micro- and nano-scale gas discharges. The specific strengths are:

- **Under-explored parameter space:** The systematic, controlled study of humidity in sub-micrometer gaps fills a critical gap in the literature. As the authors correctly note, most previous studies either ignored humidity entirely or conducted measurements in uncontrolled atmospheric conditions. This paper demonstrates that such omission can produce large (~3×) variations in the critical electric field — a finding that retroactively calls into question a substantial body of prior literature.

- **Bi-modal statistical analysis:** The extension of the KDE-based statistical approach from argon [1] to air is convincing. The bimodal distributions clearly reveal two distinct breakdown populations (FE-mechanism and A-mechanism), and the evolution of these populations with gap distance and humidity is well documented.

- **Counter-intuitive result with physical insight:** The observation that humidity *reduces* V_b in microgaps, opposite to the well-known macroscopic trend, is striking and has significant implications for the design and reliability of MEMS/NEMS devices, RF switches, and microfabricated spark gaps.

- **Practical relevance:** The finding is directly relevant to engineers designing devices with sub-micrometer air gaps. The paper effectively argues that humidity must be treated as a first-order design parameter — not a secondary environmental perturbation.

- **Gas-independence of FE-mechanism:** The convergence of E_FE ≈ 0.86 V/nm in dry air versus 0.77 V/nm in argon supports the physical picture that field emission is controlled by the cathode surface properties rather than the gas phase — a valuable confirmation with molecular gas.

### Limitations in Novelty

- While the observation that adsorbed water modifies field emission is itself well known in the vacuum field emission community (e.g., Plšek et al., Applied Surface Science 252, 1553 (2005); Heras & Albano, Z. Phys. Chem. 129, 11 (1982)), the authors' contribution lies in demonstrating its quantitative importance in the specific context of atmospheric-pressure microgap breakdowns. The paper would benefit from more thorough citation of the prior field emission literature on water adsorption effects.

---

## III. Detailed Technical Assessment

### A. Experimental Methodology

**1. Electrode Configuration and Field Uniformity**

The 20 µm tip radius vs. 0.10–6.00 µm gap is claimed to approximate a plane-plane configuration based on both analytical and numerical simulation (Ref. [1]). However:

- **Concern:** When water layers of thickness *h* form on the electrode surfaces (the paper estimates up to several hundred nanometers based on literature values), the effective geometry is no longer cleanly defined. The water films are dielectric (ε_r ≈ 80 for bulk water), introducing substantial field distortion even before Taylor cone formation. The assumption that the needle-plane field approximation remains valid with adsorbed water layers should be explicitly discussed and, ideally, quantified via simulation including a dielectric water layer.

- **Recommendation:** Include a brief electrostatic simulation (e.g., COMSOL or analytical) showing how a 5–100 nm water film modifies the electric field distribution between the electrodes at a representative gap distance.

**2. Humidity Control**

The NaCl-based desorption method is creative and practical. However:

- **Concern:** The equilibrium assumption between NaCl desorption, gas-phase humidity, and surface adsorption is central to the experiment. The paper states a "stabilisation phase" is used (line 143–146) but does not specify its duration. Given that water adsorption/desorption equilibrium on gold can take minutes to hours depending on surface roughness and temperature, the adequacy of this stabilization should be documented.

- **Concern:** The Shaw probe measures T_dew in the gas phase. However, the local humidity at the electrode surfaces (within the ~µm gap) may differ from the bulk measurement, particularly given the strong electric field that is applied during the voltage ramp. Field-driven migration of water molecules toward the high-field region could locally enhance the effective humidity. This effect is not discussed.

- **Recommendation:** Report the stabilization time and provide evidence (e.g., time-series of V_b measurements) that steady-state has been reached at each humidity level. Discuss whether field-driven water molecule migration could locally alter the effective humidity near the gap.

**3. Voltage Ramp Rate**

A constant ramp rate of 10 V/s is used. For the smallest gaps (0.10 µm), breakdown occurs at V_b ≈ 10–50 V, meaning the ramp takes only 1–5 seconds. For larger gaps near the Paschen regime, V_b may reach several hundred volts, extending the ramp duration to tens of seconds.

- **Concern:** The longer ramp times at larger gaps could allow more water adsorption during the measurement, potentially coupling the ramp rate to the humidity effect. Have the authors verified that V_b is independent of ramp rate over a reasonable range (e.g., 1–100 V/s)?

- **Recommendation:** Either present V_b vs. ramp rate data for at least one gap distance and humidity level, or cite previous work demonstrating ramp-rate independence under these conditions.

**4. Electrode Surface Condition**

The paper mentions gold-coated electrodes but provides no characterization of the electrode surface:

- **Major Concern:** Gold surfaces are known to undergo progressive roughening during repeated breakdown events. The discharge current (limited to ~mA by the 1 kΩ ballast resistor) can still locally damage the gold coating, particularly near the needle tip. With 100 breakdowns per condition, the accumulated damage may alter the local surface morphology, work function, and water adsorption properties.

- **Recommendation:** (a) Provide SEM or AFM images of the electrode surfaces before and after a full measurement campaign. (b) Report whether the 100 consecutive measurements at a given condition show any systematic drift (e.g., plot V_b measurement number vs. V_b value). (c) Clarify how often electrodes are replaced or reconditioned.

### B. Results and Statistical Analysis

**1. Sample Size and Statistical Power**

One hundred measurements per condition is commendable and unusual for this type of study. However:

- **Concern:** The bimodal separation in the KDE distributions (e.g., Figs. 3, 4) is visually compelling but not quantitatively assessed. No formal statistical test is applied to confirm bimodality (e.g., Hartigan's dip test, or Bayesian Information Criterion for mixture models). Given the importance of the bimodality claim, this is a significant gap.

- **Recommendation:** Apply a formal statistical test for bimodality (e.g., Hartigan's dip test, Silverman's test, or a Gaussian mixture model with BIC comparison between k=1 and k=2 components). Report the p-values or BIC differences for key conditions.

**2. KDE Bandwidth Selection**

The authors use a Gaussian KDE following Botev et al. [26], which automatically selects an optimal bandwidth.

- **Concern:** The KDE bandwidth can strongly affect the apparent bimodality. If the bandwidth is too narrow, spurious modes appear; if too broad, real modes are merged. While the Botev method is generally robust, the authors should verify that the bimodal structure persists across a range of bandwidths.

- **Recommendation:** For one representative condition, show how the KDE profile changes with bandwidth (e.g., ±50% of the optimal bandwidth). This would strengthen confidence in the bimodality finding.

**3. Temperature as a Confounding Variable**

The paper states that temperature is "close to 25 °C" (line 102) for each measurement but varies somewhat.

- **Concern:** Even small temperature variations (±2 °C) can change the molar fraction x_H2O by a few percent at fixed T_dew, and more importantly, can change the equilibrium water film thickness on the electrodes. Given the extreme sensitivity of V_b to humidity demonstrated in this work, the authors should report the actual temperature range and its potential impact.

- **Recommendation:** Report the exact temperature range across all measurements and perform a sensitivity analysis: how much does V_b change for ±2 °C at fixed T_dew?

### C. Discussion and Physical Mechanisms

**1. Work Function Reduction by Adsorbed Water**

The hypothesis that adsorbed water reduces the work function of gold, thereby enhancing field emission, is well supported by the literature (Refs. [27, 28]). However:

- **Concern:** The literature values for work function reduction by water adsorption on gold span a wide range (0.1–1.5 eV) depending on the surface crystallography, cleanliness, and the number of adsorbed water monolayers. The paper does not attempt to estimate the expected work function change for their conditions.

- **Quantitative gap:** If φ drops from 5.4 eV (clean gold) to, say, 4.0 eV (with adsorbed water), one can estimate the Fowler-Nordheim current enhancement and compare it to the observed drop in E_FE from 0.86 to 0.26 V/nm. This back-of-the-envelope calculation would significantly strengthen the argument.

- **Recommendation:** Provide an order-of-magnitude Fowler-Nordheim calculation showing whether a plausible work function reduction (~1–1.5 eV) can quantitatively account for the observed factor of ~3.3 reduction in E_FE. Cite the specific adsorption studies on gold surfaces most relevant to these conditions.

**2. Taylor Cone Hypothesis**

The Taylor cone hypothesis is physically interesting but is presented largely as speculation:

- **Concern:** Taylor cone formation requires a minimum liquid volume and a critical electric field. For the very thin adsorbed water layers relevant here (1–100 nm), it is unclear whether the classical Taylor cone theory applies. The paper cites the bulk surface tension of water (72.75 mN/m) and estimates a critical field, but the surface tension of sub-nanometer water films may differ substantially from bulk due to confinement effects.

- **Concern:** The Taylor cone formation time must be compared to the voltage ramp timescale. If the cone takes milliseconds to form but the field reaches the critical value only briefly before breakdown, the hypothesis may not be self-consistent.

- **Missing physics:** Capillary condensation in the nanogap is not discussed. At relative humidities above ~30%, capillary condensation can form menisci between closely spaced surfaces, which would dramatically alter the gap geometry and the effective dielectric. This is a well-known phenomenon in AFM studies (see, e.g., Butt and Kappl, Surface Science Reports 59, 1 (2005)) and is likely relevant at sub-micrometer distances.

- **Recommendation:** (a) Estimate the Taylor cone formation timescale and compare it to the experimental timescale. (b) Discuss whether capillary condensation could play a role at the higher humidity levels studied. (c) Consider whether the thin-film surface tension (which differs from bulk) affects the critical field estimate.

**3. Interplay Between FE-Mechanism and A-Mechanism**

The paper identifies two mechanisms but does not provide a quantitative criterion for the transition between them:

- **Concern:** For intermediate gap distances (0.50–2.00 µm), the bimodal distributions suggest both mechanisms are active. What determines the probability of each mechanism? The paper implies it is stochastic, but does not model the relative probability as a function of gap distance, humidity, or electric field.

- **Recommendation:** Fit Gaussian mixture models to the bimodal distributions and plot the relative weights (mixing fractions) of the FE and A components as a function of gap distance and humidity. This would provide a quantitative picture of the competition between mechanisms.

**4. Comparison with Literature**

The comparison with Germer [10] and Torres-Dhariwal [18, 19] is valuable. However:

- **Missing comparison:** The work of Go and Pohlman [20] presents a unified framework for microscale breakdown incorporating field emission and Townsend processes. The authors cite this work but do not attempt to compare their data to the Go-Pohlman model predictions. Such a comparison would be informative.

- **Missing comparison:** The recent comprehensive review by Li et al. (Ref. [12], Physics of Plasmas 31, 040502 (2024)) should provide context for field emission physics at the microscale. The authors cite it but do not discuss how their results fit within the broader theoretical framework presented there.

- **Recommendation:** Attempt a comparison of the dry-air data with the Go-Pohlman analytical model or similar unified models that incorporate both Townsend and field emission mechanisms.

---

## IV. Presentation Quality

### Figures

- **Figure 2:** The x-axis shows both distance (µm) and p·d product. It would be helpful to add error bars (standard deviation or confidence intervals) to the average V_b values. Currently, the scatter at each point is not visible. Given that the bimodal distributions produce broad distributions, the error bars would convey the measurement variability more effectively than the average alone.

- **Figures 3 and 4:** The KDE distributions are well presented. Consider adding a small inset showing the raw histogram in at least one case, so the reader can assess the KDE smoothing.

- **Figure 6 (Schematic):** This is a critical figure that supports the Taylor cone hypothesis. The schematic is helpful but could be improved by adding approximate length scales (e.g., typical water film thickness, Taylor cone height relative to gap distance).

### Text

- **Lines 42–43:** "This also a point to address at the available literature" — grammatically awkward. Suggest revision.
- **Line 78:** "It is essential noticing that" → "It is essential to note that"
- **Line 197:** The sentence beginning "It is also important to note that the desorption of water from a metal surface..." is incomplete or unclear.
- **Line 305 region:** The discussion of the E_FE values vs. humidity could be made clearer with a summary table.

### Minor Issues

- The paper occasionally uses inconsistent notation. E_FE is used as the critical field for the FE-mechanism but is also defined as 0.86 V/nm. Clarify whether this is a fixed constant of the mechanism or a measured quantity that varies with conditions.
- Table I is informative but would benefit from an additional column showing the estimated water film thickness (from literature) at each T_dew value.

---

## V. Missing Considerations

1. **Electrode polarity:** The paper briefly mentions Bruggeman et al. [33] stating no polarity dependence, but the present study appears to use only one polarity (anode on the needle). A brief discussion of why polarity effects are expected or not expected would be valuable.

2. **Repeated use / electrode aging:** No information is provided on how many total breakdowns the electrodes sustained across all conditions. If hundreds or thousands of breakdowns occur on the same electrode pair, cumulative damage could alter results. The order in which humidity conditions are tested could also matter (e.g., testing humid conditions first could leave residual water that affects subsequent "dry" measurements).

3. **Gas purity beyond humidity:** The synthetic air is stated to have purity >99.9999%, but the NaCl-based humidity control could introduce NaCl aerosol or other contaminants into the gap. Is there evidence that only water (and not salt particles) reaches the electrodes?

4. **Dielectric breakdown of the water film:** At the very high electric fields in these experiments (hundreds of MV/m), the adsorbed water film itself could undergo dielectric breakdown or electrolysis. This could generate reactive species (OH, H, O radicals) that participate in the breakdown process. This possibility is not discussed.

---

## VI. Specific Recommendations (Ranked by Priority)

### Must Address (Major Revisions)

1. **Electrode characterization:** Provide pre/post-experiment surface analysis (SEM or AFM) to assess electrode damage and surface morphology changes.

2. **Quantitative FE analysis:** Perform a Fowler-Nordheim calculation to show whether a plausible work function reduction from adsorbed water can quantitatively explain the observed E_FE reduction from 0.86 to 0.26 V/nm.

3. **Statistical validation of bimodality:** Apply a formal statistical test (Hartigan's dip test or BIC-based mixture model comparison) to confirm the bimodal structure in the V_b distributions.

4. **Capillary condensation:** Discuss whether capillary condensation between closely spaced electrodes could contribute to the observed humidity effects, especially at gaps < 1 µm and RH > 30%.

5. **Electrode drift / aging:** Show that V_b is stable over 100 consecutive measurements (plot V_b vs. measurement index) to demonstrate no systematic drift.

### Should Address (Strengthen the Paper)

6. **Field distribution with water film:** Estimate (analytically or numerically) how a thin dielectric water film modifies the electric field in the gap.

7. **Taylor cone timescale:** Estimate the hydrodynamic timescale for Taylor cone formation in a sub-100 nm water film and compare with the experimental ramp timescale.

8. **Temperature sensitivity:** Report the actual temperature range and its potential effect on V_b.

9. **Ramp rate independence:** Verify V_b is independent of the voltage ramp rate.

10. **Mixture model analysis:** Fit Gaussian mixture models to the bimodal distributions and report the mixing fractions as a function of gap and humidity.

### Nice to Have (Optional but Valuable)

11. Comparison with Go-Pohlman unified breakdown model.
12. Summary table of E_FE values across all humidity conditions.
13. Raw histograms alongside KDE plots.
14. Discussion of electrode polarity effects.
15. Discussion of possible dielectric breakdown of the water film itself.

---

## VII. Overall Evaluation

This manuscript presents important new experimental results on the role of humidity in sub-micrometer gas breakdown — a topic of both fundamental interest and practical importance for microsystems technology. The counter-intuitive finding that humidity *reduces* breakdown voltage in microgaps is well documented and supported by a sound statistical methodology. The competing FE-mechanism and A-mechanism framework is convincing, and the proposed physical mechanisms (work function reduction and Taylor cone formation) are plausible.

However, the paper would benefit significantly from:
- More rigorous quantitative support for the proposed mechanisms (particularly a Fowler-Nordheim estimate and capillary condensation analysis),
- Formal statistical validation of the bimodal distributions,
- Evidence that electrode surface conditions remain stable throughout the measurements, and
- A more thorough discussion of confounding effects (capillary condensation, field-driven water migration, NaCl contamination).

With these revisions, the paper would represent a strong contribution to Physical Review E and would be of interest to the gas discharge, field emission, MEMS reliability, and plasma physics communities.

**Recommendation: Major Revisions**

---

## VIII. Extended R&D Commentary — Broader Scientific Context

### 8.1. The Fundamental Problem: Paschen's Law at the Nanoscale

Paschen's law, derived from Townsend theory under the assumption that electron multiplication occurs solely through gas-phase ionization and secondary emission at the cathode, has been the workhorse of electrical insulation design for over a century. The classical pd-scaling works extraordinarily well for macroscopic gaps (> 100 µm) at moderate pressures. However, as demonstrated by this manuscript and a growing body of literature [4, 5, 12, 15, 16, 18–20], the law fails systematically for gaps below ~10 µm at atmospheric pressure.

The physical reason is well understood in principle: at sub-micrometer distances, the electric field E = V/d reaches values of order 0.1–1 V/nm even for moderate voltages (10–500 V). At these field strengths, quantum-mechanical field emission from the cathode (Fowler-Nordheim tunneling through the surface potential barrier) becomes the dominant electron source, bypassing the need for gas-phase ionization to initiate the discharge. The resulting breakdown voltage increases linearly with d rather than following the pd-dependent Paschen curve — exactly as observed in this work.

What makes the present manuscript significant is the demonstration that this picture is dramatically modified by an environmental parameter — humidity — that has been largely ignored in previous microgap studies. The factor of ~3.3× reduction in E_FE from 0.86 to 0.26 V/nm is enormous and suggests that much of the scatter in previously reported microgap breakdown data may be attributable to uncontrolled humidity rather than experimental error or electrode variability.

### 8.2. Water at Metal Surfaces: A Complex Interface

The interaction of water with metal surfaces is one of the most extensively studied topics in surface science, yet it remains incompletely understood. Key relevant findings from the literature include:

- **Adsorption structure:** On close-packed gold surfaces (Au(111)), water adsorbs in a two-dimensional ice-like bilayer structure at low temperatures, transitioning to a more disordered multilayer structure at higher coverages and temperatures. At room temperature and moderate humidity, gold surfaces are typically covered by 1–5 monolayers of water (corresponding to 0.3–1.5 nm thickness).

- **Work function modification:** Water adsorption on clean gold reduces the work function by 0.5–1.5 eV, with the exact value depending on the number of adsorbed layers, surface crystallography, and defect density (Heras & Albano, 1982; Guo et al. [27]). For a polycrystalline gold film as used in this work, values of Δφ ≈ 0.8–1.2 eV are plausible.

- **Fowler-Nordheim implications:** Using the standard Fowler-Nordheim equation, a work function reduction of 1 eV (from 5.3 to 4.3 eV) at a fixed current density threshold increases the FN tunneling current by roughly 3–4 orders of magnitude. This is far more than needed to trigger breakdown, suggesting that even a partial work function reduction could explain the observed E_FE drop.

- **Field-induced desorption/restructuring:** At the extreme electric fields in these experiments, the adsorbed water layer itself is subject to field-induced restructuring, dissociation, and ion emission. This complicates the simple picture of a passive dielectric layer and could introduce time-dependent effects.

### 8.3. Capillary Condensation — The Missing Mechanism

A notable omission in the manuscript is any discussion of capillary condensation, which is arguably the most relevant phenomenon for understanding water behavior in nanogaps. The Kelvin equation predicts that, at a given relative humidity, water spontaneously condenses in confined geometries (gaps, pores, asperities) whose effective radius of curvature is below a critical value. At 39% RH (T_dew = 10 °C), the Kelvin radius is approximately:

r_K = (2γV_m) / (RT ln(1/RH)) ≈ (2 × 0.073 × 1.8×10⁻⁵) / (8.314 × 298 × ln(1/0.39)) ≈ 1.1 nm

This means that any surface asperity or gap constriction with a radius of curvature less than ~1 nm will be filled with condensed water. For the 0.10 µm (100 nm) gap, any surface roughness features on the scale of a few nanometers could serve as nucleation sites for capillary bridges that effectively short-circuit a portion of the gap.

At the smallest gaps studied (100–200 nm), capillary condensation could form a liquid water bridge spanning a significant fraction of the interelectrode distance. This would:
1. Reduce the effective gas gap (increasing the local electric field),
2. Provide a conductive pathway for ionic current,
3. Serve as a source of field-emitted ions (not just electrons), and
4. Dramatically alter the discharge initiation mechanism.

This mechanism could work in concert with or independently of the Taylor cone mechanism proposed by the authors, and may in fact be more important at the smaller gap distances.

### 8.4. Taylor Cone Formation in Sub-Nanometer Films: A Critical Assessment

The Taylor cone hypothesis, while creative, faces several challenges that the authors should address:

**Timescale considerations:** The characteristic time for capillary-wave growth on a liquid film of thickness h under electric field E is:

τ ~ (η h³) / (ε₀ E² h²) ~ η h / (ε₀ E²)

For a 10 nm water film at E = 0.5 V/nm:
τ ~ (10⁻³ Pa·s × 10⁻⁸ m) / (8.85×10⁻¹² F/m × (5×10⁸ V/m)²) ≈ 4.5 × 10⁻⁹ s ≈ 5 ns

This is much faster than the voltage ramp timescale (seconds), suggesting that if the critical field is reached, Taylor cone instability develops nearly instantaneously. This actually supports the hypothesis but raises the question: why don't all breakdowns at a given E occur via Taylor cone initiation? The stochastic nature of the bimodal distributions suggests that the water film thickness itself fluctuates, making Taylor cone formation probabilistic.

**Film thickness limitations:** At 39% RH and 25 °C, the equilibrium water film thickness on gold is approximately 0.5–2 nm (3–6 monolayers). A Taylor cone with half-angle ~49.3° on a 1 nm film would project only ~1 nm into the gap. For a 100 nm gap, this represents only 1% of the distance — seemingly insufficient to explain the large V_b reduction. However, if two opposing Taylor cones form (one on each electrode), and if the field enhancement at the cone tip is significant (factor of 5–10×), the combined effect could be substantial.

### 8.5. Implications for MEMS/NEMS Reliability and Design

The results of this study have profound implications for the design of micro- and nano-electromechanical systems:

1. **Reliability derating:** Current MEMS reliability standards typically use Paschen's law (or modified Paschen curves without humidity correction) to set safe operating voltages. The 3× reduction in breakdown field at moderate humidity suggests that current safety margins may be inadequate for devices operating in humid environments.

2. **Hermetic packaging requirements:** Devices with sub-micrometer gaps operating at voltages above ~10 V may require hermetic packaging with internal desiccation — a significant cost and complexity addition.

3. **Ultra-low-voltage spark gaps:** Conversely, the authors note (line 482–483) that the humidity-induced V_b reduction could enable the development of ultra-low-voltage spark gaps for protection circuitry or switching applications. This is an interesting application direction that could be explored further.

4. **RF MEMS switches:** Capacitive and ohmic RF MEMS switches typically have gap distances of 1–5 µm and operate in packages with controlled (but not zero) humidity. The results suggest that switching reliability could be significantly affected by package-level humidity control.

### 8.6. Recommended Future Directions

Based on this review, the following future research directions would be particularly valuable:

1. **In-situ surface characterization:** Combine breakdown measurements with real-time AFM or optical interferometry to directly observe water film evolution and electrode surface changes during the experiment.

2. **Molecular dynamics simulation:** Model the water layer structure, field-induced deformation, and ion emission at the atomic scale to provide a first-principles foundation for the Taylor cone hypothesis.

3. **Extended humidity range:** Extend measurements to very high humidity (RH > 60%) where capillary condensation becomes dominant, and to elevated temperatures where water desorption competes with adsorption.

4. **Other electrode materials:** Repeat the study with materials of very different work functions (e.g., aluminum, tungsten, platinum) to decouple the work function effect from the Taylor cone effect.

5. **AC and pulsed fields:** Investigate whether the humidity effect persists under AC or pulsed conditions, which are more representative of many practical applications.

6. **Direct work function measurement:** Use Kelvin probe or ultraviolet photoelectron spectroscopy to directly measure the work function of gold electrodes as a function of controlled humidity, providing the missing quantitative link to the FE-mechanism hypothesis.

---

*Review prepared with extensive cross-referencing to the literature cited in the manuscript and supplementary sources from the field emission, surface science, capillary condensation, and gas discharge physics communities.*

*Date: 2026-03-16*

