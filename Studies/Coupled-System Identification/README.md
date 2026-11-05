# Coupled-System Identification

Paper: *Physics-informed identification of coupled beam–RF feedback dynamics from closed-loop measurements in a storage ring* ([paper/main.tex](paper/main.tex)).

This study is a grey-box (two-quadrature) identification of the beam, cavities, klystron and RFP direct loop of the SPEAR3 RF station. It uses:

- the 2026 closed-loop transfer-function records;
- the 2021 trip records of the present klystron (in service since September 2020), which supply its AM/PM conversion and an independent measurement of its compression;
- the 2026 station snapshots.

**Offline analysis only.** All inputs are files already recorded by existing routines. Nothing here reads from or writes to the live system (no `caget`/`caput`).

## Inputs (read-only)

| Data | Location |
|------|----------|
| Closed-loop records, 2 Oct and 3 Nov 2026 | `matlab_operations_prod/Measurement/ClosedLoopTF/2026-10-02`, `.../2026-11-03` (see the README there) |
| Injected noise reference | `matlab_operations_prod/Measurement/OldData/testdata/NOISE_[IQ]_BL.out` |
| Trip records of the present klystron, 2021 | `matlab_operations_prod/Measurement/FaultFiles/2021` (see the README there) |
| Station snapshots, Oct–Nov 2026 | `spear3rf/data/snapshots/SRF1_2026*.json` |

The October–November 2026 captures in `FaultFiles/2026` are not used: according to the RF group they are not real faults or arcs.

## Layout

- `code/`: model and data handling, analysis, run scripts, and the figure and number generators.
  - Model and data: `csi_model.py`, `csi_data.py`, `csi_fit.py` (estimators and fitting), `csi_families.py` (model families).
  - Analysis: `csi_beam.py` (coupled beam mode), `csi_trips.py` (trip records).
- `results/`: fit results (`*.json`), logs, PNG copies of the figures, and page renders.
- `paper/`: REVTeX 4.2 source.
  - `numbers.tex`, `table_data.tex`, `table_groups.tex` and `figures/*.pdf` are generated. Do not edit them by hand.

The selected model is `J_wl_group_ac_ktrip`: one station, compression per operating point, AM/PM conversion fixed at the trip-record value. `make_numbers.py` and `make_figures.py` name it in `SELECTED`.

## Reproducing the paper

You need Python 3.10 with numpy, scipy and matplotlib; PyMuPDF is used only for page renders. Run from `code/` with `OMP_NUM_THREADS=1`. The joint fits run in parallel (about 15 workers) and take tens of minutes.

| Step | Command | Writes |
|------|---------|--------|
| 1. Model checks against `spear3rf` and Doc P | `python test_model.py` | — |
| 2. Klystron from the trip records: compression and AM/PM | `python csi_trips.py` | `results/trip_klystron.*` (read by `csi_families.py`) |
| 3. Wideband families (15–400 kHz) | `python run_global.py --families lin_eff,lin_shared,spread,wl_global,wl_group --tag wide_fits` | `results/wide_fits.*` |
| 4. Joint wideband + beam-band families, klystron free | `python run_global.py --families J_lin_eff,J_lin_eff_ac,J_lin_shared_ac,J_spread_ac,J_wl_global_ac,J_wl_group,J_wl_group_ac,J_wl_group_ac_kap0,J_wl_group_ac_nobeam --tag joint_fits` | `results/joint_fits.*` |
| 5. Diagnostics (effective model with α_c free) | `python run_beam_diagnostics.py` | adds to `joint_fits.json` |
| 6. Families with the trip-record klystron (selected model and variants; wideband-only fit for step 7) | `python run_trip_constrained.py` | adds to `joint_fits.json` and `wide_fits.json`; `results/trip_constrained.log` |
| 7. Out-of-band prediction of the coupled mode | `python validate_beam_mode.py wide_fits` | `results/beam_mode_validation.*` |
| 8. Profile likelihoods (nested data sets, klystron free) | `python run_identifiability.py`, then `python ident_wide_one.py` | `results/identifiability.*` |
| 9. Cross-condition prediction | `python run_crossval.py` | `results/crossval.*` |
| 10. Numbers and tables quoted in the paper | `python make_numbers.py` | `paper/numbers.tex`, `paper/table_*.tex` |
| 11. Figures | `python make_figures.py` | `paper/figures/*.pdf`, `results/fig_*.png` |

Build the paper in `paper/`:

```
pdflatex main
bibtex main
pdflatex main
pdflatex main
```

`latexmk -pdf main` also works where Perl is available.
