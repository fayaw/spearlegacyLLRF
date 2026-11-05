"""Data-driven identification of the SRF1 direct loop with a designed two-channel excitation (SPEAR3_Loop_System_Identification.md).

The RFP plays the I and Q DAC files into the klystron drive, after the controller, and records the
controller output (signal RAM, FBSIG 0 = TOTAL) and one cavity probe (cavity RAM, CAVSEL) in the same
triggered shot (RFgui MeasDirCls, measure_beam_phase).  This script

  design      builds a periodic complex multisine for the two DACs: lines on the 2^16-sample grid (156 Hz),
              log-spaced from 0.16 kHz to 1.5 MHz, each line on one side of the carrier only ("non-mirrored"),
              so that the response at a line measures the direct transfer H1 and the response at its mirror the
              image transfer H2 of the widely linear station; design B mirrors design A, so A + B give H1 and H2
              at every line.  Line powers follow the noise of the 2 Oct 2026 records (more power where the
              station's own noise is high), at the rms of today's NOISE_[IQ]_BL files; crest factor reduced
              by clipping.  --write-dac writes the RFP DAC and reference files (2^19 words, 'RFP Signal I/Q RAM'
              header, 12-bit codes x 16, low nibble copied from NOISE_I_BL.out)
  simulate    the station as a widely linear closed loop: controller C (gain, phase, lag and lead networks),
              klystron (amplitude gain g_A, AM/PM k_AP, drive phase phi_u), plant P (amplifier pole, delay,
              detuned cavity), as in Doc P (analyze_measure_direct.closed_loop_wl, checked here); four shots
              of three periods per design, with the noise measured in the 2 Oct 2026 TOTAL records
  estimate    nonparametric H1, H2 of TOTAL and probe with their uncertainty, then the block decomposition at
              every line: controller C = -TOTAL/probe, klystron (g_A, k_AP) from the ratio of the image and
              direct parts of the drive-to-probe response, plant P; vector fitting of C (the loop network's
              poles and zeros) and of P (the cavity pole: Q_L and detuning)
  compare     gray-box fits of the TOTAL response from the two-channel excitation and from a one-channel
              excitation like today's (I = Q), with parameter uncertainties
Writes results/sysid_*.csv and sysid_*.png; DAC files to Studies/optLLRF/data/sysid_dac/.

usage: python sysid_multisine.py [--write-dac] [--current 497|22]      design, simulate, compare (synthetic)
       python sysid_multisine.py --selftest [--current 497]            synthetic shots in the RFP file format
       python sysid_multisine.py --analyze DIR [--phi-u DEG] [--cavity C]   shots of optllrf_sysid_acquire.m
"""
import argparse
import math
import sys
from pathlib import Path

import numpy as np
from scipy.optimize import least_squares

import optllrf as ol

sys.path.insert(0, str(ol.ROOT / "spear3rf" / "scripts"))
import analyze_measure_direct as amd  # noqa: E402

FS = amd.FS
M = 2 ** 16                     # excitation period (samples): 6.4 ms, 156 Hz lines
N_RAM, N_DAC = 2 ** 18, 2 ** 19
GAIN_FACTOR = 10.0              # get_RFP_noise_gain('SRF1'): DAC value / reference
DAC_DIR = ol.STUDY / "data" / "sysid_dac"
TRUTH = {                       # 2 Oct 2026 fits (Doc P tab:mdc-fits; analyze_closed_loop.py): G, tau, Q_L at 20-22 mA
    497: dict(G=1.26, theta=9.07, tau=618.0, QL=6921.0, df=-37.66, gA=0.40, kAP=0.10, phi_u=-114.3),
    22: dict(G=1.26, theta=1.4, tau=618.0, QL=6921.0, df=-1.1, gA=0.40, kAP=0.10, phi_u=-114.3),
}
NAMES = ("G", "theta", "tau", "QL", "df", "gA", "kAP", "phi_u")


# ----------------------------------------------------------------------------- station model (widely linear)
def blocks(f, p):
    """Controller C (loop gain and phase, RFP lag and lead networks), plant P (amplifier pole, delay, cavity),
    klystron direct and image gains kd, ki: the parameterization of analyze_measure_direct.closed_loop_wl."""
    s = 2j * np.pi * np.asarray(f, float)
    w = amd.W_RF / (2 * p["QL"])
    C = (p["G"] * np.exp(1j * math.radians(p["theta"])) * (1 + 2 * np.pi * p.get("fi", amd.LAG[0])
         / (s + 2 * np.pi * p.get("fl", amd.LAG[1]))) * (1 + s / (2 * np.pi * amd.FZ)) / (1 + s / (2 * np.pi * amd.FP)))
    P = np.exp(-s * p["tau"] * 1e-9) * amd.FA / (s / (2 * np.pi) + amd.FA) * w / (s + w - 2j * np.pi * p["df"] * 1e3)
    kd = (1 + p["gA"]) / 2 + 0.5j * p["kAP"]
    ki = ((p["gA"] - 1) / 2 + 0.5j * p["kAP"]) * np.exp(2j * math.radians(p["phi_u"]))
    return C, P, kd, ki


def wl_response(f, p):
    """Direct (H1) and image (H2) responses of TOTAL x, drive d and probe v to an excitation n summed into the
    drive: y(f) = H1(f) n(f) + H2(f) conj(n(-f)).  Returns {signal: (H1, H2)} and the mirror responses."""
    f = np.asarray(f, float)
    C, P, kd, ki = blocks(f, p)
    Cm, Pm, _, _ = blocks(-f, p)
    A, At = C * P, np.conj(Cm * Pm)
    a11, a12, a21, a22 = 1 + A * kd, A * ki, At * np.conj(ki), 1 + At * np.conj(kd)
    det = a11 * a22 - a12 * a21
    out = {}
    for tag, (b1, b2) in (("e1", (-A * kd, -At * np.conj(ki))), ("e2", (-A * ki, -At * np.conj(kd)))):
        x = (b1 * a22 - a12 * b2) / det
        xt = (a11 * b2 - a21 * b1) / det           # conj(x(-f))
        n1, n2 = (1.0, 0.0) if tag == "e1" else (0.0, 1.0)
        d, dt = x + n1, xt + n2
        yk = kd * d + ki * dt
        out[tag] = dict(x=x, xt=xt, d=d, dt=dt, v=P * yk)
    return {sig: (out["e1"][sig], out["e2"][sig]) for sig in ("x", "xt", "d", "dt", "v")}


def check_against_doc_p(p):
    f = np.linspace(-300e3, 300e3, 41)
    f = f[np.abs(f) > 1e3]
    r = wl_response(f, p)
    for alpha in (45.0, 0.0, 90.0):
        mine = r["x"][0] + r["x"][1] * np.exp(-2j * math.radians(alpha))
        ref = amd.closed_loop_wl(f, p["G"], p["theta"], p["tau"], p["QL"], p["df"], p["gA"], p["kAP"], p["phi_u"], alpha)
        assert np.allclose(mine, ref, rtol=1e-9, atol=1e-12), f"mismatch with closed_loop_wl at alpha {alpha}"
    return True


# ----------------------------------------------------------------------------- measured noise
def measured_noise(tag="v2850i497gp009pm0200d20261002135153"):
    """Two-sided spectral density of the part of the TOTAL record that the injected noise does not explain."""
    ni, nq = amd.ram(amd.TEST / "NOISE_I_BL.out"), amd.ram(amd.TEST / "NOISE_Q_BL.out")
    y = amd.dump(amd.RUNS / f"DIRECT_I_CLOSED{tag}")
    x = (amd.scale(ni[:y.size]) + 1j * amd.scale(nq[:y.size])) / GAIN_FACTOR
    f, H, coh, w = amd.tfestimate(y, x, 8192)
    st = range(0, y.size - 8192 + 1, 4096)
    Y = np.array([np.fft.fft(w * y[s:s + 8192]) for s in st])
    Syy = np.mean(np.abs(Y) ** 2, 0) / (FS * np.sum(w ** 2))
    o = np.argsort(f)
    fs_, Sn = f[o], (Syy * (1 - coh))[o]
    k = np.ones(9) / 9
    Sn = np.exp(np.convolve(np.log(Sn), k, "same"))
    return lambda ff: np.interp(ff, fs_, Sn), float(np.std(x))


# ----------------------------------------------------------------------------- excitation
def line_bins(n_lines=240, f_min=150.0, f_max=1.5e6):
    df = FS / M
    k = np.unique(np.round(np.geomspace(max(1, f_min / df), f_max / df, n_lines)).astype(int))
    keep = np.abs(k * df - 60.0 * np.round(k * df / 60.0)) > 8.0          # off the mains harmonics
    return k[keep]


def design(noise, p, rms, sign=+1, mode="2d", seed=1, dyn_db=30.0, cf=3.0, iters=60):
    """Periodic complex multisine X[bin] (line amplitudes) and one period of samples x (reference units).

    2d: line k on side sign*(-1)^i only (design B: sign = -1); 1d: x = e^{j45deg} r(t), r real (today's I = Q)."""
    rng = np.random.default_rng(seed)
    k = line_bins()
    df = FS / M
    r = wl_response(k * df, p)
    gain = np.abs(r["x"][0]) + 1e-6
    pw = noise(k * df) / gain ** 2                       # equalize the expected signal-to-noise ratio
    pw = np.clip(pw / pw.max(), 10 ** (-dyn_db / 10), 1.0)
    X = np.zeros(M, complex)
    if mode == "2d":
        sides = sign * np.where(np.arange(k.size) % 2 == 0, 1, -1)
        X[(sides * k) % M] = np.sqrt(pw) * np.exp(2j * np.pi * rng.random(k.size))
    else:
        ph = np.exp(2j * np.pi * rng.random(k.size))
        X[k % M] = np.sqrt(pw / 2) * ph
        X[(-k) % M] = np.sqrt(pw / 2) * np.conj(ph)       # r(t) real
        X *= np.exp(1j * math.pi / 4)
    exc = X != 0
    amp = np.abs(X)
    for _ in range(iters):                                 # crest factor: clip I and Q, restore the line amplitudes
        x = np.fft.ifft(X) * M
        lim = cf * np.sqrt(np.mean(x.real ** 2 + x.imag ** 2) / 2)
        if mode == "1d":
            xr = np.clip((x * np.exp(-1j * math.pi / 4)).real, -lim * math.sqrt(2), lim * math.sqrt(2))
            x = xr * np.exp(1j * math.pi / 4)
        else:
            x = np.clip(x.real, -lim, lim) + 1j * np.clip(x.imag, -lim, lim)
        Xn = np.fft.fft(x) / M
        X = np.where(exc, amp * np.exp(1j * np.angle(Xn)), 0.0)
        if mode == "1d":
            X[(-k) % M] = np.conj(X[k % M] * np.exp(-1j * math.pi / 4)) * np.exp(1j * math.pi / 4)
    x = np.fft.ifft(X) * M
    scale = rms / np.std(x)
    X, x = X * scale, x * scale
    crest = max(np.abs(x.real).max(), np.abs(x.imag).max()) / np.sqrt(np.mean(x.real ** 2 + x.imag ** 2) / 2)
    return dict(X=X, x=x, bins=np.nonzero(exc)[0], k=k, mode=mode, sign=sign, crest=float(crest))


def write_dac(des, name):
    """RFP DAC files (and identical reference files) for one design: 2^19 words, 12-bit codes x 16."""
    DAC_DIR.mkdir(parents=True, exist_ok=True)
    tmpl = {q: np.frombuffer((amd.TEST / f"NOISE_{q}_BL.out").read_bytes()[16:], dtype=">i2").astype(np.int64) & 15
            for q in "IQ"}
    x = np.tile(des["x"], N_DAC // M) * GAIN_FACTOR
    paths = []
    for q, part in (("I", x.real), ("Q", x.imag)):
        code = np.clip(np.round((4095 * part - 1) / 2), -2048, 2047).astype(np.int64)
        word = (code * 16 + tmpl[q][:N_DAC]).astype(">i2")
        hdr = f"RFP Signal {q} RAM".encode("ascii")
        for fn in (f"{name}_{q}", f"{name}_{q}.out"):
            (DAC_DIR / fn).write_bytes(hdr + word.tobytes())
            paths.append(DAC_DIR / fn)
        back = amd.scale(amd.ram(DAC_DIR / f"{name}_{q}.out")) / GAIN_FACTOR
        err = np.max(np.abs(back - part / GAIN_FACTOR))
        assert err < 2.0 / 4095 / GAIN_FACTOR, f"DAC file round trip error {err}"
    return paths


# ----------------------------------------------------------------------------- measurement simulation
def simulate(des, p, noise, shots=4, periods=3, seed=10, signals=("x", "v"), noise_ratio=None):
    """Steady-state line responses of TOTAL (x) and probe (v) for shots x periods, with the measured noise.
    The probe's noise is set to the same signal-to-noise ratio as TOTAL at each frequency."""
    rng = np.random.default_rng(seed)
    df = FS / M
    bins = np.unique(np.concatenate([des["bins"], (-des["bins"]) % M]))
    f = np.where(bins < M // 2, bins, bins - M) * df
    r = wl_response(f, p)
    X = des["X"]
    Xm = np.conj(X[(-bins) % M])
    out = {}
    for sig in signals:
        Y0 = r[sig][0] * X[bins] + r[sig][1] * Xm
        Sn = noise(f)
        if sig != "x":
            Sn = Sn * np.abs(r[sig][0]) ** 2 / np.maximum(np.abs(r["x"][0]) ** 2, 1e-12)
        sd = np.sqrt(Sn * df / 2)
        n = shots * periods
        Y = Y0[None, :] + sd * (rng.normal(size=(n, bins.size)) + 1j * rng.normal(size=(n, bins.size)))
        out[sig] = Y
    return f, bins, out


def frf(des, f, bins, Y):
    """H1 at the excited lines and H2 at their mirrors, with standard errors."""
    X = des["X"]
    Ym, Ys = Y.mean(0), Y.std(0, ddof=1) / math.sqrt(Y.shape[0])
    exc = np.isin(bins, des["bins"])
    h1 = dict(f=f[exc], H=Ym[exc] / X[bins[exc]], s=Ys[exc] / np.abs(X[bins[exc]]))
    mir = ~exc
    src = (-bins[mir]) % M
    h2 = dict(f=f[mir], H=Ym[mir] / np.conj(X[src]), s=Ys[mir] / np.abs(X[src]))
    return h1, h2


def merge(a, b):
    f = np.concatenate([a["f"], b["f"]])
    o = np.argsort(f)
    return {k: np.concatenate([a[k], b[k]])[o] for k in ("f", "H", "s")}


# ----------------------------------------------------------------------------- decomposition
def decompose(Hx1, Hx2, Hv1, Hv2, f, phi_u):
    """Blocks at every line from H1/H2 of TOTAL and probe at +f and -f (designs A and B together).

    drive d = x + n; [v1, v2] = [P kd, P ki] [[d1, d2], [dt1, dt2]]; C = -x1/v1 (strictly linear controller)."""
    idx = {round(v, 3): i for i, v in enumerate(f)}
    rows = []
    for i, fi in enumerate(f):
        j = idx.get(round(-fi, 3))
        if j is None:
            continue
        d1, d2 = Hx1[i] + 1.0, Hx2[i]
        dt1, dt2 = np.conj(Hx2[j]), np.conj(Hx1[j]) + 1.0
        D = np.array([[d1, d2], [dt1, dt2]])
        a, b = np.linalg.solve(D.T, np.array([Hv1[i], Hv2[i]]))
        C = -Hx1[i] / Hv1[i]
        C2 = -Hx2[i] / Hv2[i]
        rows.append((fi, a, b, C, C2))
    r = np.array(rows)
    out = dict(f=r[:, 0].real, a=r[:, 1], b=r[:, 2], C=r[:, 3], C_check=r[:, 4])
    rho = out["b"] / out["a"] * np.exp(-2j * math.radians(phi_u))
    gk = (1 + rho) / (1 - rho)
    out["gA"], out["kAP"] = gk.real, gk.imag
    return out


def vector_fit(f, H, n_poles, w=None, iters=12, poles0=None):
    """Vector fitting for a complex (not conjugate-symmetric) response: H(s) = sum r_i/(s - a_i) + d."""
    s = 2j * np.pi * np.asarray(f)
    w = np.ones_like(s.real) if w is None else w
    if poles0 is None:
        fr = np.geomspace(max(np.min(np.abs(f)), 10.0), np.max(np.abs(f)), n_poles)
        poles0 = -2 * np.pi * fr
    a = np.asarray(poles0, complex)
    for _ in range(iters):
        Phi = 1.0 / (s[:, None] - a[None, :])
        A = np.hstack([Phi, np.ones((s.size, 1)), -H[:, None] * Phi]) * w[:, None]
        sol = np.linalg.lstsq(A, H * w, rcond=None)[0]
        ct = sol[n_poles + 1:]
        a = np.linalg.eigvals(np.diag(a) - np.outer(np.ones(n_poles), ct))
        a = np.where(a.real > 0, -np.conj(a), a)
    Phi = 1.0 / (s[:, None] - a[None, :])
    A = np.hstack([Phi, np.ones((s.size, 1))]) * w[:, None]
    sol = np.linalg.lstsq(A, H * w, rcond=None)[0]
    r, d = sol[:n_poles], sol[n_poles]
    zeros = np.linalg.eigvals(np.diag(a) - np.outer(np.ones(n_poles), r) / d) if abs(d) > 0 else np.array([])
    fit = Phi @ r + d
    return dict(poles=a, residues=r, d=d, zeros=zeros, fit=fit, rms=float(np.sqrt(np.mean(np.abs((fit - H) * w) ** 2))))


def fit_plant(f, Pk):
    """Parametric fit of the plant block P kd: complex gain, delay, cavity Q_L and detuning (2.5 MHz amplifier pole)."""
    def model(q):
        g, tau, QL, dfk = q[0] + 1j * q[1], q[2] * 1e-9, q[3], q[4]
        s = 2j * np.pi * f
        w = amd.W_RF / (2 * QL)
        return g * np.exp(-s * tau) * amd.FA / (s / (2 * np.pi) + amd.FA) * w / (s + w - 2j * np.pi * dfk * 1e3)

    def res(q):
        e = (model(q) - Pk) / np.abs(Pk)
        return np.concatenate([e.real, e.imag])
    best = None
    for tau0 in (500.0, 650.0, 800.0):
        for df0 in (-40.0, 0.0):
            g0 = Pk[np.argmin(np.abs(f))]
            r = least_squares(res, [g0.real, g0.imag, tau0, 6500.0, df0], x_scale=[abs(g0), abs(g0), 50, 500, 5])
            best = r if best is None or r.cost < best.cost else best
    return dict(tau=best.x[2], QL=best.x[3], df=best.x[4], rms=float(np.sqrt(np.mean(best.fun ** 2))))


def fit_network(f, C, s=None, n=2):
    """The controller as an I/Q-symmetric analog network: C(s) = K prod (1 + s/z_i) / prod (1 + s/p_i), K complex,
    poles and zeros real (identical networks on I and Q).  Corners log-parameterized; several starts."""
    w = 1.0 / (np.abs(C) if s is None else np.maximum(s, 1e-3 * np.abs(C)))

    def model(q):
        K = q[0] + 1j * q[1]
        z, pp = 10 ** q[2:2 + n], 10 ** q[2 + n:2 + 2 * n]
        ss = 2j * np.pi * f
        out = K * np.ones_like(ss)
        for i in range(n):
            out = out * (1 + ss / (2 * np.pi * z[i])) / (1 + ss / (2 * np.pi * pp[i]))
        return out

    def res(q):
        e = (model(q) - C) * w
        return np.concatenate([e.real, e.imag])
    best = None
    lo = np.argmin(np.abs(f))
    for z0, p0 in (((3e3, 1e6), (300.0, 2e6)), ((1e4, 5e5), (100.0, 5e6)), ((2e3, 2e6), (500.0, 1e6))):
        K0 = C[lo]
        q0 = np.r_[K0.real, K0.imag, np.log10(z0), np.log10(p0)]
        r = least_squares(res, q0, x_scale=np.r_[abs(K0), abs(K0), [0.3] * 2 * n])
        best = r if best is None or r.cost < best.cost else best
    q = best.x
    return dict(K=q[0] + 1j * q[1], zeros=np.sort(10 ** q[2:2 + n]), poles=np.sort(10 ** q[2 + n:]),
                fit=model(q), rms=float(np.sqrt(np.mean(best.fun ** 2))))


# ----------------------------------------------------------------------------- gray-box fits
def graybox(data, p0, free, alpha=None):
    """Fit the TOTAL response.  data: list of (f, H, s, kind) with kind 'H1', 'H2' or '1d'."""
    keys = list(free)
    sc = np.array([dict(G=0.1, theta=5, tau=20, QL=300, df=2, gA=0.1, kAP=0.1, phi_u=20)[k] for k in keys])

    def params(q):
        p = dict(p0)
        p.update({k: v for k, v in zip(keys, q * sc)})
        return p

    def res(q):
        p = params(q)
        out = []
        for f, H, s, kind in data:
            r = wl_response(f, p)["x"]
            m = r[0] if kind == "H1" else r[1] if kind == "H2" else r[0] + r[1] * np.exp(-2j * math.radians(alpha))
            e = (m - H) / s
            out += [e.real, e.imag]
        return np.concatenate(out)
    start = np.array([p0[k] for k in keys]) / sc
    best = None
    for dphi in (0.0, 90.0, -90.0, 180.0):
        q0 = start.copy()
        if "phi_u" in keys:
            q0[keys.index("phi_u")] += dphi / sc[keys.index("phi_u")]
        r = least_squares(res, q0, x_scale=1.0, max_nfev=4000)
        best = r if best is None or r.cost < best.cost else best
    J = best.jac
    dof = max(1, best.fun.size - J.shape[1])
    s2 = 2 * best.cost / dof
    try:
        cov = np.linalg.inv(J.T @ J) * s2
        std = np.sqrt(np.diag(cov)) * sc
        corr = cov / np.sqrt(np.outer(np.diag(cov), np.diag(cov)))
    except np.linalg.LinAlgError:
        std, corr = np.full(len(keys), np.inf), None
    est = params(best.x)
    return dict(est={k: est[k] for k in keys}, std=dict(zip(keys, std)), chi2=s2, corr=corr, keys=keys,
                cond=float(np.linalg.cond(J)))


# ----------------------------------------------------------------------------- real shots (RFP RAM files)
def write_ram(path, z, kind="Signal"):
    """RFP RAM file pair <path>_I, <path>_Q: 16-byte header, 12-bit codes x 16 (as the station writes them)."""
    for q, part in (("I", z.real), ("Q", z.imag)):
        code = np.clip(np.round((4095 * part - 1) / 2), -2048, 2047).astype(np.int64)
        Path(f"{path}_{q}").write_bytes(f"RFP {kind} {q} RAM".encode("ascii") + (code * 16).astype(">i2").tobytes())


def read_ram(path):
    return amd.scale(amd.ram(f"{path}_I")) + 1j * amd.scale(amd.ram(f"{path}_Q"))


def shot_lines(z, bins, skip=1):
    """Complex line amplitudes in each period after the first (start-up transient): (periods, bins)."""
    P = z.size // M
    seg = z[:P * M].reshape(P, M)[skip:]
    return (np.fft.fft(seg, axis=1) / M)[:, bins]


def design_pair(noise, p, rms, seed=1):
    """The two complementary designs exactly as --write-dac writes them (same seeds)."""
    return design(noise, p, rms, +1, "2d", seed), design(noise, p, rms, -1, "2d", seed + 1)


def analyze_dir(d, p_design, phi_u=None, cavity=None, seed=1, verbose=True):
    """Shots written by optllrf_sysid_acquire.m (or --selftest): FRFs, block decomposition, network and plant fits,
    and the gray-box fit of TOTAL.  p_design: the parameters the designs were made with (only the line powers depend
    on them); phi_u: drive phase in degrees (default: from the drive shot)."""
    d = Path(d)
    noise, rms = measured_noise()
    A_, B_ = design_pair(noise, p_design, rms, seed)
    df = FS / M
    res = {}
    for des, name in ((A_, "SYSID_MS_A"), (B_, "SYSID_MS_B")):
        bins = np.unique(np.concatenate([des["bins"], (-des["bins"]) % M]))
        f = np.where(bins < M // 2, bins, bins - M) * df
        stems = sorted({q.name[: q.name.rindex("_SIG_I")] for q in d.glob(f"{name}_c*_s*_SIG_I")})
        if cavity is not None:
            stems = [s for s in stems if f"_c{cavity}_" in s]
        if not stems:
            raise SystemExit(f"no shots of {name} in {d}")
        Yx = np.vstack([shot_lines(read_ram(d / f"{s}_SIG"), bins) for s in stems])
        Yv = np.vstack([shot_lines(read_ram(d / f"{s}_CAV"), bins) for s in stems])
        res[name] = (des, f, bins, Yx, Yv, len(stems))
        if phi_u is None and (d / f"{name}_drive_SIG_I").exists():
            phi_u = math.degrees(np.angle(np.mean(read_ram(d / f"{name}_drive_SIG"))))
    if phi_u is None:
        raise SystemExit("drive phase unknown: record a drive shot ('drive', true) or give --phi-u")
    (dA, fA, bA, YxA, YvA, nA), (dB, fB, bB, YxB, YvB, nB) = res["SYSID_MS_A"], res["SYSID_MS_B"]
    hx1A, hx2A = frf(dA, fA, bA, YxA)
    hx1B, hx2B = frf(dB, fB, bB, YxB)
    hv1A, hv2A = frf(dA, fA, bA, YvA)
    hv1B, hv2B = frf(dB, fB, bB, YvB)
    Hx1, Hx2, Hv1, Hv2 = merge(hx1A, hx1B), merge(hx2A, hx2B), merge(hv1A, hv1B), merge(hv2A, hv2B)
    dec = decompose(Hx1["H"], Hx2["H"], Hv1["H"], Hv2["H"], Hx1["f"], phi_u)
    band = (np.abs(dec["f"]) > 20e3) & (np.abs(dec["f"]) < 600e3)
    net = fit_network(dec["f"], dec["C"])
    pl = fit_plant(dec["f"], dec["a"])
    free = ("G", "theta", "tau", "QL", "df", "gA", "kAP")
    p0 = dict(p_design, phi_u=phi_u)
    sel = lambda h: (np.abs(h["f"]) > 1e3) & (np.abs(h["f"]) < 600e3)
    gb = graybox([(Hx1["f"][sel(Hx1)], Hx1["H"][sel(Hx1)], Hx1["s"][sel(Hx1)], "H1"),
                  (Hx2["f"][sel(Hx2)], Hx2["H"][sel(Hx2)], Hx2["s"][sel(Hx2)], "H2")], p0, free)
    out = dict(phi_u=phi_u, shots=(nA, nB), gA=float(np.median(dec["gA"][band])), kAP=float(np.median(dec["kAP"][band])),
               network=net, plant=pl, graybox=gb, dec=dec, Hx1=Hx1, Hx2=Hx2)
    if verbose:
        print(f"{d}: {nA} + {nB} shots, {Hx1['f'].size} lines; drive phase {phi_u:+.1f} deg")
        print(f"  klystron (image/direct, 20-600 kHz): g_A {out['gA']:.3f}, k_AP {out['kAP']:+.3f}")
        print(f"  loop network: zeros {net['zeros'][0] / 1e3:.3f} / {net['zeros'][1] / 1e3:.0f} kHz, poles"
              f" {net['poles'][0] / 1e3:.3f} / {net['poles'][1] / 1e3:.0f} kHz, DC gain {abs(net['K']):.2f} at"
              f" {math.degrees(np.angle(net['K'])):+.1f} deg")
        print(f"  plant: delay {pl['tau']:.0f} ns, Q_L {pl['QL']:.0f}, detuning {pl['df']:+.2f} kHz")
        print("  gray-box (TOTAL, H1 and H2): " + ", ".join(f"{k} {gb['est'][k]:.3f}+-{gb['std'][k]:.2g}" for k in free))
    return out


def selftest(current=497, seed=1, shots=3):
    """Write synthetic shots in the RFP file format (steady state, measured noise, 12-bit quantization, probe carrier
    0.27 of full scale, a drive shot), analyze them with analyze_dir and compare with the truth."""
    import tempfile
    p = dict(TRUTH[current])
    noise, rms = measured_noise()
    rng = np.random.default_rng(seed + 100)
    tmp = Path(tempfile.mkdtemp(prefix="optllrf_sysid_"))
    df = FS / M
    fft_f = np.fft.fftfreq(N_RAM, 1 / FS)
    Sn = noise(fft_f)
    for des, name in zip(design_pair(noise, p, rms, seed), ("SYSID_MS_A", "SYSID_MS_B")):
        bins = np.arange(M)
        f = np.where(bins < M // 2, bins, bins - M) * df
        r = wl_response(np.where(f == 0, 1e-3, f), p)
        X = des["X"]
        Xm = np.conj(X[(-bins) % M])
        lines = {sig: r[sig][0] * X + r[sig][1] * Xm for sig in ("x", "v", "d")}
        lines["d"] = r["d"][0] * X + r["d"][1] * Xm
        per = {sig: np.fft.ifft(v) * M for sig, v in lines.items()}
        rel = np.abs(r["v"][0]) / np.maximum(np.abs(r["x"][0]), 1e-12)
        for c in (0,):
            for s in range(1, shots + 1):
                def noisy(sig, scale_psd):
                    W = (rng.normal(size=N_RAM) + 1j * rng.normal(size=N_RAM)) * np.sqrt(scale_psd * FS * N_RAM / 2)
                    return np.tile(per[sig], N_RAM // M) + np.fft.ifft(W)
                tot = noisy("x", Sn)
                relN = np.interp(np.abs(fft_f), np.abs(f[: M // 2]), rel[: M // 2])
                cav = 0.27 * np.exp(0.6j) + noisy("v", Sn * relN ** 2)
                write_ram(tmp / f"{name}_c{c}_s{s}_SIG", tot)
                write_ram(tmp / f"{name}_c{c}_s{s}_CAV", cav, "Cavity")
        drive = 0.48 * np.exp(1j * math.radians(p["phi_u"])) + np.tile(per["d"], N_RAM // M)
        write_ram(tmp / f"{name}_drive_SIG", drive)
        write_ram(tmp / f"{name}_drive_CAV", cav, "Cavity")
    print(f"self-test: synthetic shots in {tmp} ({current} mA truth: " + ", ".join(f"{k} {v}" for k, v in p.items()) + ")")
    out = analyze_dir(tmp, dict(TRUTH[current]), seed=seed)
    for fn in tmp.iterdir():
        fn.unlink()
    tmp.rmdir()
    return out


# ----------------------------------------------------------------------------- demo
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--current", type=int, default=497, choices=sorted(TRUTH))
    ap.add_argument("--write-dac", action="store_true")
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--analyze", default=None, help="folder of shots from optllrf_sysid_acquire.m")
    ap.add_argument("--phi-u", type=float, default=None, help="drive phase (deg) if no drive shot was recorded")
    ap.add_argument("--cavity", type=int, default=None)
    ap.add_argument("--selftest", action="store_true", help="synthetic shots in the RFP file format, then --analyze")
    a = ap.parse_args()
    if a.analyze:
        analyze_dir(a.analyze, dict(TRUTH[a.current]), a.phi_u, a.cavity, a.seed)
        return
    if a.selftest:
        selftest(a.current, a.seed)
        return
    p = dict(TRUTH[a.current])
    check_against_doc_p(p)
    print(f"widely linear station model reproduces analyze_measure_direct.closed_loop_wl (1e-9) at alpha 45/0/90 deg")
    noise, rms = measured_noise()
    df = FS / M
    A_ = design(noise, p, rms, +1, "2d", a.seed)
    B_ = design(noise, p, rms, -1, "2d", a.seed + 1)
    D1 = design(noise, p, rms, +1, "1d", a.seed + 2)
    print(f"designs: {A_['k'].size} lines, {df:.1f} Hz grid, {A_['k'][0] * df:.0f} Hz to {A_['k'][-1] * df / 1e3:.0f} kHz;"
          f" rms {rms:.5f} (as NOISE_[IQ]_BL); crest factor A {A_['crest']:.2f}, B {B_['crest']:.2f}, 1-D {D1['crest']:.2f}")
    if a.write_dac:
        for des, name in ((A_, "SYSID_MS_A"), (B_, "SYSID_MS_B")):
            ps = write_dac(des, name)
            print("  wrote", ", ".join(q.name for q in ps), "->", DAC_DIR)
    # simulated measurements: 4 shots x 3 periods each
    fA, bA, YA = simulate(A_, p, noise, seed=11)
    fB, bB, YB = simulate(B_, p, noise, seed=12)
    f1, b1, Y1 = simulate(D1, p, noise, seed=13, signals=("x",))
    hx1A, hx2A = frf(A_, fA, bA, YA["x"])
    hx1B, hx2B = frf(B_, fB, bB, YB["x"])
    hv1A, hv2A = frf(A_, fA, bA, YA["v"])
    hv1B, hv2B = frf(B_, fB, bB, YB["v"])
    Hx1, Hx2 = merge(hx1A, hx1B), merge(hx2A, hx2B)
    Hv1, Hv2 = merge(hv1A, hv1B), merge(hv2A, hv2B)
    exc1 = np.isin(b1, D1["bins"])
    H1d = dict(f=f1[exc1], H=Y1["x"].mean(0)[exc1] / D1["X"][b1[exc1]],
               s=Y1["x"].std(0, ddof=1)[exc1] / math.sqrt(Y1["x"].shape[0]) / np.abs(D1["X"][b1[exc1]]))
    truth = wl_response(Hx1["f"], p)
    e1 = np.median(np.abs(Hx1["H"] - truth["x"][0]) / np.abs(truth["x"][0]))
    print(f"nonparametric H1 of TOTAL: median relative error {100 * e1:.1f}% over {Hx1['f'].size} lines;"
          f" H2 (image) measured at {Hx2['f'].size} lines, |H2|/|H1| median {np.median(np.abs(Hx2['H']) / np.abs(Hx1['H'])):.2f}")

    # block decomposition
    dec = decompose(Hx1["H"], Hx2["H"], Hv1["H"], Hv2["H"], Hx1["f"], p["phi_u"])
    band = (np.abs(dec["f"]) > 20e3) & (np.abs(dec["f"]) < 600e3)
    print(f"klystron from the drive-to-probe response, 20-600 kHz ({band.sum()} lines): g_A {np.median(dec['gA'][band]):.3f}"
          f" (true {p['gA']}), k_AP {np.median(dec['kAP'][band]):+.3f} (true {p['kAP']}); spread"
          f" {np.std(dec['gA'][band]):.3f} / {np.std(dec['kAP'][band]):.3f}")
    Ct, Pt, kd, ki = blocks(dec["f"], p)
    cerr = np.median(np.abs(dec["C"] - Ct) / np.abs(Ct))
    print(f"controller C = -TOTAL/probe: median relative error {100 * cerr:.1f}% (0.15-1500 kHz)")
    vf = vector_fit(dec["f"], dec["C"], 2, w=1 / np.maximum(np.abs(dec["C"]), 1e-9),
                    poles0=[-2 * np.pi * 300.0, -2 * np.pi * 2e6])
    pz = sorted(vf["poles"], key=lambda z: abs(z))
    zz = sorted(vf["zeros"], key=lambda z: abs(z))
    print("  unconstrained vector fit, 2 poles: poles (kHz) " + ", ".join(f"{-z.real / 2e3 / math.pi:.3f}{z.imag / 2e3 / math.pi:+.3f}j" for z in pz)
          + "; zeros (kHz) " + ", ".join(f"{-z.real / 2e3 / math.pi:.3f}{z.imag / 2e3 / math.pi:+.3f}j" for z in zz))
    net = fit_network(dec["f"], dec["C"])
    K_true = p["G"] * np.exp(1j * math.radians(p["theta"])) * (amd.LAG[0] + amd.LAG[1]) / amd.LAG[1]
    print(f"  I/Q-symmetric network fit (real corners): zeros {net['zeros'][0] / 1e3:.3f} and {net['zeros'][1] / 1e3:.0f} kHz,"
          f" poles {net['poles'][0] / 1e3:.3f} and {net['poles'][1] / 1e3:.0f} kHz; DC gain {abs(net['K']):.2f}"
          f" at {math.degrees(np.angle(net['K'])):+.1f} deg")
    print(f"  truth: lag zero {(amd.LAG[0] + amd.LAG[1]) / 1e3:.3f} kHz, lag pole {amd.LAG[1] / 1e3:.3f} kHz, lead zero"
          f" {amd.FZ / 1e3:.0f} kHz, lead pole {amd.FP / 1e3:.0f} kHz; DC gain {abs(K_true):.2f} at {p['theta']:+.1f} deg")
    vf = dict(vf, fit=net["fit"])
    pl = fit_plant(dec["f"], dec["a"])
    print(f"plant P kd (parametric: gain, delay, 2.5 MHz amplifier pole, cavity): delay {pl['tau']:.0f} ns (true {p['tau']:.0f}),"
          f" Q_L {pl['QL']:.0f} (true {p['QL']:.0f}), detuning {pl['df']:+.2f} kHz (true {p['df']:+.2f}); rms {pl['rms']:.3f}")

    # gray-box fits: two-channel against one-channel excitation.  The loop gain G and the klystron's mean gain
    # appear only as a product in TOTAL, so the drive phase phi_u (the drive's DC value) is held at its measured value
    free = ("G", "theta", "tau", "QL", "df", "gA", "kAP")
    p0 = dict(p)
    p0.update(G=1.0, theta=0.0, tau=630.0, QL=6500.0, df=p["df"] + 2.0, gA=0.7, kAP=0.5)
    rows = []
    sel = lambda h: (np.abs(h["f"]) > 1e3) & (np.abs(h["f"]) < 600e3)
    fits = {"two-channel (A + B), H1 and H2": graybox([(Hx1["f"][sel(Hx1)], Hx1["H"][sel(Hx1)], Hx1["s"][sel(Hx1)], "H1"),
                                                      (Hx2["f"][sel(Hx2)], Hx2["H"][sel(Hx2)], Hx2["s"][sel(Hx2)], "H2")], p0, free),
            "one-channel (I = Q), today's": graybox([(H1d["f"][sel(H1d)], H1d["H"][sel(H1d)], H1d["s"][sel(H1d)], "1d")], p0, free,
                                                     alpha=45.0)}
    print("gray-box fits of TOTAL, 1-600 kHz, seven parameters free (start far from the truth), phi_u held:")
    print("  " + " ".join(f"{k:>14s}" for k in ("excitation",) + free))
    print("  " + f"{'truth':>14s} " + " ".join(f"{p[k]:14.3f}" for k in free))
    for lab, ft in fits.items():
        print(f"  {lab[:14]:>14s} " + " ".join(f"{ft['est'][k]:8.3f}+-{ft['std'][k]:<5.2g}" for k in free)
              + f"  chi2/dof {ft['chi2']:.2f}, cond {ft['cond']:.1e}")
        if ft["corr"] is not None:
            i, j = ft["keys"].index("gA"), ft["keys"].index("kAP")
            print(f"  {'':14s} correlation(g_A, k_AP) {ft['corr'][i, j]:+.3f}")
        for k in free:
            rows.append([lab, k, p[k], ft["est"][k], ft["std"][k]])
    ol.save_csv(ol.RESULTS / f"sysid_graybox_{a.current}mA.csv", ["excitation", "parameter", "truth", "estimate", "std"], rows)
    ol.save_csv(ol.RESULTS / f"sysid_blocks_{a.current}mA.csv",
                ["f_Hz", "C_re", "C_im", "C_true_re", "C_true_im", "Pkd_re", "Pkd_im", "Pki_re", "Pki_im", "gA", "kAP"],
                [[dec["f"][i], dec["C"][i].real, dec["C"][i].imag, Ct[i].real, Ct[i].imag, dec["a"][i].real, dec["a"][i].imag,
                  dec["b"][i].real, dec["b"][i].imag, dec["gA"][i], dec["kAP"][i]] for i in range(dec["f"].size)])
    plot(a.current, Hx1, Hx2, H1d, p, dec, vf, Ct)


def plot(I, Hx1, Hx2, H1d, p, dec, vf, Ct):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    fig, ax = plt.subplots(2, 2, figsize=(13, 8.5))
    ff = np.concatenate([-np.geomspace(1.5e6, 100, 600), np.geomspace(100, 1.5e6, 600)])
    tr = wl_response(ff, p)["x"]
    for sgn, ls in ((1, "-"), (-1, "--")):
        m = sgn * ff > 0
        ax[0, 0].semilogx(sgn * ff[m] / 1e3, 20 * np.log10(np.abs(tr[0][m])), "k", ls=ls, lw=0.8)
        ax[0, 0].semilogx(sgn * ff[m] / 1e3, 20 * np.log10(np.abs(tr[1][m])), "tab:red", ls=ls, lw=0.8)
        for h, c, mk in ((Hx1, "k", "o"), (Hx2, "tab:red", "s")):
            mm = sgn * h["f"] > 0
            ax[0, 0].semilogx(sgn * h["f"][mm] / 1e3, 20 * np.log10(np.abs(h["H"][mm])), mk, color=c, ms=2.5,
                              mfc="none" if sgn < 0 else c)
    ax[0, 0].set_title(f"{I} mA: TOTAL response, direct H1 (black) and image H2 (red); upper (solid/filled) and lower"
                       " (dashed/open) side", fontsize=8)
    ax[0, 0].set_xlabel("|offset| (kHz)")
    ax[0, 0].set_ylabel("dB")
    ax[0, 0].grid(alpha=0.3, which="both")
    m1 = H1d["f"] > 0
    ax[0, 1].semilogx(H1d["f"][m1] / 1e3, 20 * np.log10(np.abs(H1d["H"][m1])), "o", ms=2.5, color="tab:blue",
                      label="one-channel (I = Q): H1 + H2 e^{-j90}")
    ax[0, 1].semilogx(ff[ff > 0] / 1e3, 20 * np.log10(np.abs(tr[0][ff > 0] + tr[1][ff > 0] * np.exp(-1j * math.pi / 2))),
                      "tab:blue", lw=0.8)
    ax[0, 1].semilogx(ff[ff > 0] / 1e3, 20 * np.log10(np.abs(tr[0][ff > 0])), "k", lw=0.8, label="H1 alone")
    ax[0, 1].set_title("what one-channel noise measures: a fixed mixture of H1 and H2", fontsize=8)
    ax[0, 1].legend(fontsize=7)
    ax[0, 1].grid(alpha=0.3, which="both")
    for sgn, ls in ((1, "o"), (-1, "s")):
        m = sgn * dec["f"] > 0
        ax[1, 0].semilogx(sgn * dec["f"][m] / 1e3, 20 * np.log10(np.abs(dec["C"][m])), ls, ms=2.5, color="tab:green",
                          mfc="none" if sgn < 0 else "tab:green")
        ax[1, 0].semilogx(sgn * dec["f"][m] / 1e3, 20 * np.log10(np.abs(vf["fit"][m])), "k-", lw=0.8)
    ax[1, 0].set_title("controller C = -TOTAL/probe (the loop network), with the I/Q-symmetric network fit", fontsize=8)
    ax[1, 0].set_xlabel("|offset| (kHz)")
    ax[1, 0].set_ylabel("dB")
    ax[1, 0].grid(alpha=0.3, which="both")
    band = (np.abs(dec["f"]) > 2e3)
    ax[1, 1].semilogx(np.abs(dec["f"][band]) / 1e3, dec["gA"][band], ".", ms=3, label="g_A per line")
    ax[1, 1].semilogx(np.abs(dec["f"][band]) / 1e3, dec["kAP"][band], ".", ms=3, label="k_AP per line")
    ax[1, 1].axhline(p["gA"], color="tab:blue", lw=0.8)
    ax[1, 1].axhline(p["kAP"], color="tab:orange", lw=0.8)
    ax[1, 1].set_ylim(-0.5, 1.2)
    ax[1, 1].set_title("klystron from the image/direct ratio of the drive-to-probe response", fontsize=8)
    ax[1, 1].set_xlabel("|offset| (kHz)")
    ax[1, 1].legend(fontsize=7)
    ax[1, 1].grid(alpha=0.3, which="both")
    fig.tight_layout()
    fig.savefig(ol.RESULTS / f"sysid_{I}mA.png", dpi=130)
    print("wrote", ol.RESULTS / f"sysid_{I}mA.png")


if __name__ == "__main__":
    main()
