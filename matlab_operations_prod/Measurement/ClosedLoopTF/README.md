# Closed-loop transfer-function measurements of station SRF1

All closed-loop transfer-function measurements of the direct loop are kept here, one folder per measurement day. They were made with the RFgui routine "Measure Direct Closed" (`matlab_operations_prod/RFgui/measure_direct_closed.m`).

| Folder | Klystron | Content |
|--------|----------|---------|
| `2020-05-04/` | previous tube (failed 3 September 2020) | The routine's figure only: no beam, COUNTS.A 5.1 dB, PHASE.C −33°. The other diagnostics of that day stay in `../OldData/diags20200504/`. |
| `2025-11-10/` | present tube (in service since 7 September 2020) | 1 record, 485 mA |
| `2026-10-02/` | present tube | 10 records and the routine's figures |
| `2026-11-03/` | present tube | 8 records and the routine's figures |

## File names

- `DIRECT_I_CLOSED<tag>` and `DIRECT_Q_CLOSED<tag>`: the records.
- `measureDirect<tag>.fig`: the routine's figure.

The tag has the form `v<kV>i<mA>g<p|m><COUNTS.A ×10>p<p|m><PHASE.C ×10>d<yyyymmddhhmmss>`, where `p` is plus and `m` is minus. For example, `v2850i494gm002pm0350d20261103172932` means:

- station voltage 2.85 MV;
- 494 mA;
- COUNTS.A −0.2 dB;
- PHASE.C −35.0°;
- 3 November 2026, 17:29:32.

## Record format

- **Header:** 16 bytes ("RFP Signal I RAM").
- **Data:** 2^18 big-endian int16 words, scaled as ((w/16)·2 + 1)/4095.
- **Signal:** RFP signal memory with FBSIG 0, i.e. TOTAL, the summed feedback signal (the controller output).
- **Rate:** 8 samples per turn (10.24 MS/s), 25.6 ms per record.

The routine's transfer function from the injected noise to the record is `conj(tfestimate(reference/10, record))` with 8192-point Hann windows. It gives a positive loop delay and cavities below f_RF at high current, the physical convention.

## Noise reference, needed for every transfer function

- **Location:** `../OldData/testdata/NOISE_I_BL.out` and `NOISE_Q_BL.out`, divided by 10.
- **One-dimensional excitation:** I and Q carry the same sequence (correlation 0.9998).
- **Do not use the `OldData/SRF1` copy:** it differs and does not match the records.
- **Open-loop record:** the Configure Direct routine's open-loop record `DIRECT_[IQ]_OPEN_SP`, with its reference `NOISE_[IQ]_BL_SMALL.out`, stays in `OldData/testdata`.

## Not recorded

The records carry the station voltage, beam current, COUNTS.A, PHASE.C and time. They do not carry:

- the HVPS (cathode) voltage;
- the klystron drive and output power;
- the frequency-offset tracking correction, and with it the total loop phase PHASE.L.

The klystron's gain and compression depend on the HVPS voltage. The HVPS loop changes that voltage with the beam current while holding the drive at 28 W. The station snapshots of 2026 (`spear3rf/data/snapshots`) give 67.2 kV without beam and 75.2 kV at about 500 mA. The identification study estimates the voltage of each operating point from the power balance (paper, Table IV).

Record the HVPS voltage, the klystron drive and output power, and PHASE.L with every future measurement.

## Records

| Date | Time | V_RF (MV) | I_b (mA) | COUNTS.A (dB) | PHASE.C (deg) | Figure |
|------|------|-----------|----------|---------------|---------------|--------|
| 2025-11-10 | 13:07 | 2.85 | 485 | +0.9 | −14.0 | no |
| 2026-10-02 | 09:33 | 2.85 | 22 | +0.9 | −14.0 | yes |
| 2026-10-02 | 09:41 | 2.85 | 22 | +0.9 | −17.0 | yes |
| 2026-10-02 | 09:47 | 2.85 | 22 | +0.9 | −20.0 | yes |
| 2026-10-02 | 09:49 | 2.85 | 22 | +0.9 | −23.0 | yes |
| 2026-10-02 | 10:09 | 2.85 | 22 | +0.9 | −23.0 | yes |
| 2026-10-02 | 13:44 | 2.85 | 363 | +0.9 | −23.0 | yes |
| 2026-10-02 | 13:49 | 2.85 | 494 | +0.9 | −23.0 | yes |
| 2026-10-02 | 13:51 | 2.85 | 497 | +0.9 | −20.0 | yes |
| 2026-10-02 | 13:58 | 2.85 | 20 | +0.9 | −20.0 | yes |
| 2026-10-02 | 17:20 | 2.85 | 395 | +0.9 | −20.0 | yes |
| 2026-11-03 | 17:07 | 2.85 | 242 | +1.3 | −20.0 | yes |
| 2026-11-03 | 17:22 | 2.85 | 497 | +1.3 | −30.0 | yes |
| 2026-11-03 | 17:26 | 2.85 | 499 | +1.3 | −35.0 | yes |
| 2026-11-03 | 17:27 | 2.85 | 497 | +1.3 | −35.0 | yes |
| 2026-11-03 | 17:28 | 2.85 | 495 | +0.3 | −35.0 | yes |
| 2026-11-03 | 17:29 | 2.85 | 494 | −0.2 | −35.0 | yes |
| 2026-11-03 | 17:30 | 2.85 | 500 | +0.0 | −35.0 | yes |
| 2026-11-03 | 17:31 | 2.85 | 498 | +0.3 | −35.0 | yes |

## Copies not moved

`OldData/SRF1/` holds `DIRECT_[IQ]_CLOSED`, `DIRECT_[IQ]_CLSD` and `DIRECT_[IQ]_OPEN`. These are untagged IOC working files with no date or conditions, part of that directory dump. The `CLOSED` pair matches none of the records above.

## Used by

- `Studies/Coupled-System Identification` (`code/csi_data.py`): every dated record. The paper uses the 18 records of 2026.
- `spear3rf/scripts/analyze_measure_direct.py` (Doc P): `2025-11-10/` and `2026-10-02/`.
- `spear3rf/scripts/analyze_old_rf_data.py`: the figure in `2020-05-04/`.
- `Studies/optLLRF/code/python/analyze_closed_loop.py` and `sysid_multisine.py`: `2026-10-02/`, through `analyze_measure_direct.RUNS`.
