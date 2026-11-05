# optLLRF study code

All code used by the study. The physics model lives in the repository's `spear3rf` package. The study scripts import it from `spear3rf/src` and don't copy it.

## Python (`python/`)

Run from this folder with Python 3.9+ and numpy, scipy and matplotlib. Live captures also need pyvisa; EPICS snapshots need pyepics. Outputs go to `../../results/`.

| Script | Purpose | Inputs | Outputs |
|---|---|---|---|
| `optllrf.py` | Shared module: station models (`eff`, `lag`, `prop`), jitter, drive transfers, capture analysis (line-masked Lorentzian with ±3 HWHM and Fano cross-checks, line comb, beam share, line area to beam motion) | spear3rf | none |
| `predict_ramp.py` | Theory for the 0–500 mA ramp: σ, f_coh, Q, jitter per source, lag-side phase margins, klystron-compression sensitivity, tuner lag, 360 Hz crossings | none | `ramp_*.csv`, `ramp_*.png` |
| `predict_scan.py` | Expected values for every scan point, stop thresholds (σ ratio and flags of plan §11), source signatures (motion variance), conditioning of the source fit | none | `scan_expected.csv`, `scan_identifiability.csv`, `scan_signatures.png` |
| `lines_near_fcoh.py` | Line comb near the synchrotron line: beam share, beam motion, currents at which a fill crosses each line | FSW capture plus paired snapshot | `lines_<capture>.csv/.png` |
| `analyze_line.py` | Per-point analysis of the scan: one capture to one row of the run log (`--demo`: the 8 Oct captures) | FSW capture, snapshot | `runlog_<tag>.csv` |
| `analyze_closed_loop.py` | Closed-loop record (Measure Direct Closed dumps): fit over 18.8–382 kHz, integral corner within ±25 kHz at ≤ 100 mA, beam pole near ±f_s, compressed-klystron fit above 300 mA (`--demo`: two runs of 2 Oct) | `DIRECT_[IQ]_CLOSED<tag>`, noise reference | `closed_loop_<tag>.csv` |
| `fit_sources.py` | Separates klystron and measurement/reference noise from the gain scan (`--synthetic`: self-test) | run log | printed table |
| `analyze_iq.py` | I/Q record analysis: AM/PM spectra, sideband Lorentzian and Fano fits over 6–10 kHz and within ±3 HWHM, AM/PM content of each harmonic (`--synthetic`: fit errors for each of the four sources against the model's pole) | `.npz`/`.mat` with `iq`, `fs` | `iq_<name>.csv/.png`, `iq_synthetic_bias.csv` |
| `fsw_iq_capture.py` | **Draft, not yet run on the instrument.** I/Q capture on the FSW, with the instrument state saved and restored (`--dry-run` prints the SCPI) | FSW | `../../data/iq/FSW_IQ_<time>.npz` |
| `fsw_iq_capture_guarded.py` | The same I/Q capture with stricter guards: nothing is changed unless the state save reports no error, the channel list is verified after the restore, FORM is left as found. **Run on 3 Nov 2026 without beam** (restore verified) | FSW; EPICS caget | `../../data/iq/FSW_IQ_<time>.npz` |
| `fsw_nobeam_capture.py` | Swept probe spectra: the three set-ups of `fsw_matrix.py` plus 3 Hz-RBW comb set-ups at ±(7–11) kHz, centred on SPEAR:RFFreq; state saved, restored and verified. Run on 3 Nov 2026 without beam | FSW; EPICS caget | `spear3rf/data/spectra/FSW_cavA_nobeam_<time>.json` |
| `nobeam_baseline.py` | No-beam baseline against the 492 mA capture: station state, swept and I/Q spectra, mains-tracked AM/PM of every harmonic, loop rejection, line-driven beam motion at 500 mA, gain and phase predictions. All numbers of [the 3 Nov review](../SPEAR3_Synchrotron_Oscillation_Review.md) | the captures above, snapshots, `data/epics/` | `nobeam_20261103.log`, `nobeam_20261103_lines.csv`, `nobeam_20261103_*.png` |
| `fill_crossing.py` | HVPS harmonics along the fill: ripple per harmonic inferred at 492 mA (phase or amplitude hypothesis), beam motion and probe level against current, crossings, sensitivity to a loop-phase lag, ripple per degree of motion | lines CSV of `lines_near_fcoh.py`, ramp tables | `fill_crossing_*.csv`, `fill_crossing.png` |
| `probe_sysid.py` | Probe-only methods: mains frequency and harmonic regression, SSI of the I/Q envelope (beam pole without a lineshape model), joint sideband fit (`--synthetic`: all methods against the model's pole with the HVPS comb; `--ram`: 25.6 ms records with and without the comb) | `.npz`/`.mat` with `iq`, `fs` | `probe_sysid_*.csv/.png` |
| `fault_postmortem.py` | RF fault records: field modulation at 5–11 kHz before the trip, its growth, the beam phase it bounds | `FAULTRfp*`, `FAULTIqa*` folder | `fault_postmortem_<folder>.csv` |
| `sysid_multisine.py` | Loop identification: two-channel multisine designs and RFP DAC files (`--write-dac`), widely linear station model, simulation with the measured noise, H1/H2 estimation, block decomposition (controller, plant, klystron), network and plant fits, gray-box comparison with one-channel excitation; `--selftest` (shots in the RFP file format), `--analyze DIR` (real shots) | designs; shots of `optllrf_sysid_acquire.m` | `sysid_*.csv/.png`, `../../data/sysid_dac/` |

Spectra in the swept format come from `spear3rf/scripts/fsw_matrix.py`, and Python snapshots from `spear3rf.live.read_snapshot()`. `analyze_closed_loop.py` reuses the closed-loop models and fits of Doc P (`spear3rf/scripts/analyze_measure_direct.py`), and Doc P's `spear3rf/scripts/docP_noise.py` (section 6b) uses `optllrf.analyze_capture` for the beam motion it quotes.

The spear3rf modules used:
- `system`: beam loading, impedances, loop.
- `stability`: characteristic equation.
- `quadrature`: the two-quadrature model with klystron g_A and k_AP and the noise drive.
- `timedomain`: independent simulation, including `simulate_noise`.
- `live`: read-only EPICS snapshot.

## MATLAB (`matlab/`)

| File | Purpose | Writes PVs? |
|---|---|---|
| `optllrf_snapshot.m` | Snapshot of the study PVs (same list and JSON format as `spear3rf.live`); `.json` + `.mat` | No (lcaGet only) |
| `optllrf_wait_settled.m` | Waits until load angles, voltage, drive, HVPS and PHASE.L are steady after a setting change | No (lcaGet only) |
| `optllrf_measure_closed_safe.m` | Runs RFgui Measure Direct Closed and restores the RFP settings it changes on every exit path, including early returns and errors | Only values read before the run (DACS first) |
| `optllrf_sysid_acquire.m` | **Untested on the machine.** Plays the multisine designs through the RFP DACs and records TOTAL (signal RAM) and one probe (cavity RAM) per shot, for every design, cavity and shot, plus an optional drive shot; restores the RFP state on every exit | RMSZ, RUNMODE, DAC/RAM file names, SSCONT, DACS, FBSIG, CAVSEL, STATE; all but the file names restored |

Settings (COUNTS.A, PHASE.C, tracking, integral path) are changed by the operator from the usual panels, not by these scripts.

`matlab/original/` holds verbatim copies of the operations routines the study uses. They are copied from `matlab_operations_prod` at commit 9348e0a for reference and annotation; the live versions stay in `matlab_operations_prod`.

| File | Source | Role in the study |
|---|---|---|
| `measure_direct_closed.m` | RFgui | Closed-loop response (noise through the RFP DACs, summed feedback record); wrapped by `optllrf_measure_closed_safe.m` |
| `save_RFP_mux.m`, `restore_RFP_mux.m` | RFtoolbox | Mux save/restore used by the routine; restore also sets DACS 0 and SSCONT 1 |
| `loadrfstates.m`, `cyclerfstates.m`, `caShell.m`, `get_RFP_noise_gain.m` | RFtoolbox | Helpers called by the routine |
| `configure_direct.m` | RFguiInvasive | Open-loop measurement that sets the loop phase and gain and writes PHASE.B (invasive; not used during the scan) |
| `cavityfit.m`, `compute_loop.m`, `rftfresponse.m`, `find_direct_margins.m` | RFgui(Invasive) | Resonator-times-delay fit and the RFP loop models (lead 944 kHz/2.39 MHz, lag 3.19/0.26 kHz) |
| `measure_beam_phase.m` | RFgui | PEP-II beam-phase measurement through spare RFP channels; precedent for a direct beam-phase signal (not used in the plan) |
