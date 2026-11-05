"""Data access for the coupled-system identification study.

Offline only: every function reads files already in the repository. Nothing here talks to EPICS or
to an instrument.

Closed-loop records (RFgui "Measure Direct Closed", matlab_operations_prod/RFgui/measure_direct_closed.m), all in
matlab_operations_prod/Measurement/ClosedLoopTF/<yyyy-mm-dd>/ (one folder per measurement day):
  DIRECT_[IQ]_CLOSED<tag>: RFP signal RAM, FBSIG 0 (TOTAL = summed feedback signal), recorded while the
  noise sequence NOISE_[IQ]_BL (Measurement/OldData/testdata) is played through the RFP DACs into the klystron
  drive. 16-byte header, 2^18 big-endian int16 words, scaled ((w/16)*2 + 1)/4095, eight samples per turn
  (10.24 MS/s). tag = v<kV>i<mA>g<p|m><COUNTS.A x10>p<p|m><PHASE.C x10>d<yyyymmddhhmmss>; no record carries the
  HVPS voltage or the klystron drive and output power.
  The routine's transfer function is conj(tfestimate(reference/10, record)); Doc P (sec. 8.8) showed that
  this convention gives a positive loop delay and a cavity detuned below f_RF at high current, i.e. the
  physical envelope convention used by every model of this study.

Trip records of the present klystron (matlab_operations_prod/Measurement/FaultFiles/2021; installed Sep 2020),
frozen together at each trip of 2021, 51 200 samples (5.0 ms) at 10.24 MS/s ending at the fault:
  FAULTRfpS[IQ]_n  RFP signal RAM (mux code in the two low bits; 3 = klystron drive), newest sample first
  FAULTRfpC[IQ]_n  RFP cavity RAM, one cavity probe (mux code 3 = CAVSEL 3, cavity 4), newest sample first
  FAULTIqa{1,2,3}Amp_n  IQ&A amplitude histories (21-byte header, uint16, channel in the three low bits), one channel
                        each at full rate; IQ&A-1 channel 0 = klystron output forward
"""
from __future__ import annotations

import math
import re
from dataclasses import dataclass
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[3]
MEAS = ROOT / "matlab_operations_prod" / "Measurement"
CLOSED_LOOP = MEAS / "ClosedLoopTF"
RUN_DIRS = tuple(sorted(p for p in CLOSED_LOOP.iterdir() if p.is_dir()))
FAULT_DIR = MEAS / "FaultFiles" / "2021"
NOISE_DIRS = {"testdata": MEAS / "OldData" / "testdata", "SRF1": MEAS / "OldData" / "SRF1"}
STUDY = Path(__file__).resolve().parents[1]
RESULTS = STUDY / "results"
FIGS = STUDY / "paper" / "figures"

F_RF = 476.3039e6            # SPEAR:RFFreq, Oct-Nov 2026 (476.30396-476.30479 MHz)
HARMONIC = 372
FS = 8 * F_RF / HARMONIC     # signal-RAM sample rate, 10.243 MS/s
NOISE_GAIN = 10.0            # get_RFP_noise_gain: the reference is divided by 10

TAG_RE = re.compile(r"v(\d+)i(\d+)g([pm])(\d+)p([pm])(\d+)d(\d{8})(\d{6})")


@dataclass(frozen=True)
class Record:
    tag: str
    path_i: Path
    mA: float
    counts_db: float
    phase_c: float
    date: str
    time: str

    @property
    def label(self) -> str:
        return f"{self.date[4:6]}/{self.date[6:]} {self.time}"

    @property
    def stamp(self) -> str:
        return f"{self.date}T{self.time.replace(':', '')}"


def parse_tag(tag: str) -> dict:
    m = TAG_RE.search(tag)
    if m is None:
        raise ValueError(f"unrecognised tag {tag}")
    v, i, gs, g, ps, p, day, tod = m.groups()
    return dict(kV=int(v), mA=float(i), counts_db=(1 if gs == "p" else -1) * int(g) / 10,
                phase_c=(1 if ps == "p" else -1) * int(p) / 10, date=day, time=f"{tod[:2]}:{tod[2:4]}:{tod[4:]}")


def records() -> list[Record]:
    out = []
    for d in RUN_DIRS:
        for p in sorted(d.glob("DIRECT_I_CLOSED*")):
            tag = p.name.replace("DIRECT_I_CLOSED", "")
            m = parse_tag(tag)
            out.append(Record(tag, p, m["mA"], m["counts_db"], m["phase_c"], m["date"], m["time"]))
    out.sort(key=lambda r: r.date + r.time)
    return out


def ram(path) -> np.ndarray:
    return np.frombuffer(Path(path).read_bytes()[16:], dtype=">i2").astype(float)


def scale(x: np.ndarray) -> np.ndarray:
    return ((x / 16) * 2.0 + 1.0) / 4095


def closed_loop_dump(rec: Record) -> np.ndarray:
    y = scale(ram(rec.path_i)) + 1j * scale(ram(str(rec.path_i).replace("DIRECT_I_", "DIRECT_Q_")))
    return y - y.mean()


def noise_reference(which: str = "testdata", n: int | None = None) -> np.ndarray:
    d = NOISE_DIRS[which]
    ni, nq = ram(d / "NOISE_I_BL.out"), ram(d / "NOISE_Q_BL.out")
    x = (scale(ni) + 1j * scale(nq)) / NOISE_GAIN
    return x[:n] if n else x


def hann(n: int) -> np.ndarray:
    """MATLAB hanning(n) (no zero end points)."""
    return 0.5 * (1 - np.cos(2 * np.pi * np.arange(1, n + 1) / (n + 1)))


@dataclass
class TF:
    f: np.ndarray        # offset from the carrier [Hz], ascending
    H: np.ndarray        # transfer function, physical envelope convention
    coh: np.ndarray      # magnitude-squared coherence
    var: np.ndarray      # variance of the complex estimate, E|H_hat - H|^2
    n_avg: float         # effective number of averages
    Sxx: np.ndarray
    Syy: np.ndarray
    nfft: int
    window: np.ndarray


def welch_tf(y: np.ndarray, x: np.ndarray, nfft: int, overlap: float = 0.5, fs: float = FS) -> TF:
    """H1 estimate with Hann windows, returned in the routine's (conjugated) convention.

    var = |H|^2 (1 - coh) / (coh n_eff) is the standard H1 random error (Bendat & Piersol), with n_eff the
    number of segments reduced for the overlap of Hann windows (0.947 n at 50 %).
    """
    w = hann(nfft)
    step = int(nfft * (1 - overlap))
    starts = range(0, y.size - nfft + 1, step)
    X = np.array([np.fft.fft(w * x[s:s + nfft]) for s in starts])
    Y = np.array([np.fft.fft(w * y[s:s + nfft]) for s in starts])
    sxx, syy = np.mean(np.abs(X) ** 2, 0), np.mean(np.abs(Y) ** 2, 0)
    sxy = np.mean(Y * np.conj(X), 0)
    n = X.shape[0]
    if n > 1 and overlap > 0:
        rho = np.abs(np.sum(w[:nfft - step] * w[step:]) / np.sum(w * w)) ** 2
        n_eff = n / (1 + 2 * rho)
    else:
        n_eff = float(n)
    H = np.conj(sxy / sxx)
    coh = np.clip(np.abs(sxy) ** 2 / (sxx * syy), 1e-12, 1.0)
    var = np.abs(H) ** 2 * (1 - coh) / (coh * n_eff)
    f = np.fft.fftfreq(nfft, 1 / fs)
    o = np.argsort(f)
    return TF(f[o], H[o], coh[o], var[o], n_eff, sxx[o], syy[o], nfft, w)


# ------------------------------------------------------------------ fault records
def fault_numbers() -> list[int]:
    return sorted(int(p.name.split("_")[-1]) for p in FAULT_DIR.glob("FAULTRfpCI_*"))


def fault_rfp(kind: str, n: int, folder: Path = FAULT_DIR) -> tuple[int, np.ndarray]:
    """kind 'S' (signal RAM) or 'C' (cavity RAM): (mux code, complex record, oldest sample first)."""
    parts = []
    for q in ("I", "Q"):
        w = np.frombuffer((folder / f"FAULTRfp{kind}{q}_{n}").read_bytes()[16:], dtype=">i2").astype(np.int64)
        parts.append((int(w[0] & 3), np.fix(w / 16) / 2048))
    return parts[0][0], (parts[0][1] + 1j * parts[1][1])[::-1]


def fault_iqa(module: int, n: int, folder: Path = FAULT_DIR) -> tuple[int, np.ndarray]:
    """IQ&A amplitude history: (channel, amplitude in full-scale units, oldest sample first)."""
    w = np.frombuffer((folder / f"FAULTIqa{module}Amp_{n}").read_bytes()[21:], dtype=">u2").astype(np.int64)
    return int(w[0] & 7) + 1, (np.fix((w - 32768) / 16) / 2048)[::-1]


def save_csv(path: Path, header: list[str], rows: list[list]) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as fo:
        fo.write(",".join(header) + "\n")
        for r in rows:
            fo.write(",".join(_fmt(v) for v in r) + "\n")
    return path


def _fmt(v) -> str:
    if isinstance(v, float):
        return "nan" if not math.isfinite(v) else f"{v:.6g}"
    return str(v)
