# Fault records of station SRF1

All fault records of the station's present klystron are kept here. That tube was installed on 7 September 2020, after the previous one failed on 3 September 2020. Records of earlier tubes do not belong here.

| Folder | Records | What they are | Used by |
|--------|---------|---------------|---------|
| `2021/` | 15 (10 files each) | Station trips in 2021 | `Studies/Coupled-System Identification/code/csi_trips.py`, `spear3rf/scripts/analyze_old_rf_data.py` (Doc P), `Studies/optLLRF/code/python/fault_postmortem.py` |
| `2026/` | 15 (8 files each) | Captures of 27 October–4 November 2026; not real faults or arcs (RF group) | Not used |

All analysis is offline; nothing here talks to the station.

## `2021/`: trip records

At each trip the RFP and IQ&A memories freeze. The IOC's fault-file state set (`rf_statesFF`; Doc I, sec. `aim-snl-files`) then writes the files.

The records were first copied to `OldData/SRF1/` on 13 November 2025 and moved here with `git mv`. Their file dates are that copy date; the records carry no time stamp of their own.

The 10 files of record `n`, each with a short text header followed by 51 200 big-endian words, newest sample first:

- `FAULTRfpSI_n`, `FAULTRfpSQ_n`: RFP signal RAM. Multiplexer code 3 (FBSIG 3) is the klystron drive I/Q.
- `FAULTRfpCI_n`, `FAULTRfpCQ_n`: RFP cavity RAM. Code 3 is CAVSEL 3, the cavity 4 probe I/Q.
- `FAULTIqa1Amp_n`: IQ&A-1 channel 0, klystron output forward amplitude.
- `FAULTIqa2Amp_n`, `FAULTIqa3Amp_n`: channel 1 of IQ&A-2 and IQ&A-3, cavity 1 and cavity 3 reflected.
- `FAULTGvf_n`, `FAULTCmbI_n`, `FAULTCmbQ_n`: PEP-II modules (GVF, comb filter), inactive at SPEAR3.

Format details:

- **Sampling:** 10.24 MS/s (8 samples per turn), so each record covers 5.0 ms ending at the fault.
- **RFP words:** int16 after a 16-byte header. The two low bits hold the multiplexer code. The stored I/Q are the complex conjugate of the physical envelope.
- **IQ&A words:** uint16 after a 21-byte header. The three low bits hold the channel. Each module records one channel at the full rate. The amplitude is √(I² + Q²), linear in RF amplitude (Doc L, sec. `iqa-map`).

Content:

| Records | Content |
|---------|---------|
| 5–12, 14, 15 | Normal operation up to the fault. Records 5, 7, 8 and 11 are at full klystron output; 6, 9, 10, 12, 14 and 15 at about half that power with the same drive. |
| 1–4 | RFP memories hold no RF; IQ&A-1 shows the klystron output. |
| 13 | No RF in any module. |

## `2026/`: captures of October–November 2026

Each capture `n` has 8 files:

- `FAULTRfpSI_n`, `FAULTRfpSQ_n`, `FAULTRfpCI_n`, `FAULTRfpCQ_n`: 2^18 samples (25.6 ms) with a once-per-turn marker bit. Signal RAM code 3 is the drive; cavity RAM code 0 is cavity 1.
- `FAULTIqa1Amp_n`, `FAULTIqa2Amp_n`, `FAULTIqa3Amp_n`: all eight channels interleaved round-robin, 1.28 MS/s per channel.
- `FAULTAim_n`: the AIM history buffer.

The file dates run from 27 October to 4 November 2026. These files were acquired in a different mode from the trip records: full RAM length, every IQ&A channel, and the AIM buffer.

According to the RF group they are not real faults or arcs, so the identification study does not use them. Eight of them contain a large 6–7 kHz amplitude oscillation of the cavity field.
