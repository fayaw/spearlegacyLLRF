"""Physics-structured closed-loop model of the SPEAR3 RF station with beam (two-quadrature form).

Every RF envelope perturbation is a real 2-vector (I, Q) in the *cavity frame*, the frame in which the steady
total gap voltage is real. A complex-coefficient transfer function F(s) is the real matrix
[[F_r, -F_i], [F_i, F_r]], F_r = (F(s) + conj F(conj s))/2, F_i = (F(s) - conj F(conj s))/2j; blocks with a
real impulse response (delay, lead and lag networks, amplifier pole) are scalars times the identity.

Loop (the noise n is injected into the klystron drive after the controller; the record is the controller
output x = TOTAL):
    d = x + n
    I_g = K c(s) d / R_L                    klystron (two-quadrature) and real-impulse chain c(s)
    v_k = Z_k (I_g - I_b1 b Dphi)           cavity k, Z_k = R_L w/(s + w - j dw_k), w = w_RF/(2 Q_L)
    D_inc(s) Dphi = kappa1 p^T sum_k v_k     rigid-bunch dipole motion, D_inc = s^2 + 2 a_rad s + w_s^2
    x = -G R(theta) sum_k w_k v_k           controller gain and loop phase (theta: + = lead)
with b = (-sin phi_s, -cos phi_s), p = (cos phi_s, -sin phi_s), kappa1 = alpha_c w_RF/((E/e) T_rev)
(Doc P App. C).  Eliminating Dphi gives the beam-loaded plant
    P_b = Z_m - (kappa1 I_b1/D_open) Z_m b p^T Z_sum,  D_open = D_inc + kappa1 I_b1 p^T Z_sum b,
the loop matrix M = G c(s) R(theta) P_b K / R_L, and the closed-loop response x = -(1 + M)^-1 M n.
For noise along the angle alpha (cavity frame) the recorded transfer function is
    H(f) = e^{-j alpha} [(T11 c + T12 s) + j (T21 c + T22 s)],  c = cos alpha, s = sin alpha,
which equals H1 + H2 e^{-2 j alpha} in widely-linear notation.  With K = 1 and no beam, H = -L/(1+L) with
L = G e^{j theta} c(s) Z_m/R_L, the complex-linear model of Doc P eq. (gol-explicit).

The klystron is memoryless about its operating point: K = R(theta_g) [[g_A, 0], [k_AP, 1]] R(-theta_g),
theta_g the angle of the steady generator current in the cavity frame (computed from beam loading), g_A the
small-signal amplitude gain relative to the phase gain, k_AP the AM/PM conversion (rad per unit relative
amplitude).
"""
from __future__ import annotations

import math
from dataclasses import dataclass, field, replace

import numpy as np

# ------------------------------------------------------------------ fixed physics (Doc P sec. 1-2)
E0_EV = 3.0e9
HARMONIC = 372
F_RF = 476.3039e6
W_RF = 2 * math.pi * F_RF
T_REV = HARMONIC / F_RF
ALPHA_C = 1.18e-3
U0_EV = 1.09e6
J_S = 2.0 + (1.79 - 2.0) * 0.912e6 / U0_EV          # dipoles (1.79) + insertion devices (2): 1.82
ALPHA_RAD = J_S * U0_EV / (2 * E0_EV * T_REV)         # 424 1/s
R_OVER_Q = 116.6                                      # ohm per cavity, circuit convention
N_CAV = 4
KAPPA1 = ALPHA_C * W_RF / (E0_EV * T_REV)             # 1/(V s^2)

# RFP networks of the RFgui loop models (RFgui/compute_loop.m), as in Doc P sec. 6.2
LEAD_FZ = 1 / (2 * math.pi * 301 * 560e-12)                       # 944 kHz
LEAD_FP = 1 / (2 * math.pi * (196 * 301 / 497) * 560e-12)         # 2.39 MHz
LAG_FZ = 1 / (2 * math.pi * 499 * 0.1e-6)                         # 3.19 kHz
LAG_FP = 1 / (2 * math.pi * (499 + 5620) * 0.1e-6)                # 0.26 kHz
F_AMP = 2.5e6


@dataclass(frozen=True)
class Station:
    """Parameters of one operating condition. Angles in degrees, frequencies in Hz, delay in s."""

    I_b: float = 0.5                  # DC beam current [A]
    V_total: float = 2.85e6           # total gap voltage [V]
    G: float = 1.0                    # loop gain (phase path) at an on-tune resonance
    theta: float = 0.0                # loop phase error, + = lead
    tau: float = 625e-9
    Q_L: float = 6700.0
    df: float = 0.0                   # mean detuning f_r - f_RF [Hz]
    df_spread: float = 0.0            # cavities at df + df_spread * (-1.5, -0.5, 0.5, 1.5)/1.5
    g_A: float = 1.0
    k_AP: float = 0.0
    alpha: float = 45.0               # noise direction in the cavity frame
    theta_g: float | None = None      # klystron frame; None: steady generator-current angle from beam loading
    f_amp: float = F_AMP
    lead: bool = True
    lag: bool = True
    f_lag_zero: float = LAG_FZ
    f_lag_pole: float = LAG_FP
    beam: bool = True                 # include the dipole motion
    alpha_c: float = ALPHA_C
    U0: float = U0_EV
    kappa_scale: float = 1.0          # scale of the beam coupling kappa1 I_b1 alone (omega_s unchanged); diagnostic
    # measurement chain outside the loop (DAC filters, recording): H -> H exp(c1 x + c2 x^2), x = f/400 kHz
    mc1r: float = 0.0
    mc1i: float = 0.0
    mc2r: float = 0.0
    mc2i: float = 0.0

    def with_(self, **kw) -> "Station":
        return replace(self, **kw)

    # ---------------------------------------------------------------- steady state
    @property
    def phi_s(self) -> float:
        return math.acos(self.U0 / self.V_total)

    @property
    def V_cav(self) -> float:
        return self.V_total / N_CAV

    @property
    def R_L(self) -> float:
        return R_OVER_Q * self.Q_L

    @property
    def w_half(self) -> float:
        return W_RF / (2 * self.Q_L)

    @property
    def I_b1(self) -> float:
        return 2.0 * self.I_b

    @property
    def detunings(self) -> np.ndarray:
        return self.df + self.df_spread * np.array([-1.5, -0.5, 0.5, 1.5]) / 1.5

    @property
    def w_s(self) -> float:
        return math.sqrt(self.alpha_c * W_RF * self.V_total * math.sin(self.phi_s) / (E0_EV * T_REV))

    @property
    def kappa1(self) -> float:
        return self.alpha_c * W_RF / (E0_EV * T_REV)

    def optimum_detuning(self) -> float:
        return -R_OVER_Q * self.I_b1 * math.sin(self.phi_s) * F_RF / (2 * self.V_cav)

    def steady(self) -> dict:
        """Generator current and gap voltages for the vector sum held at V_cav (equal weights)."""
        z0 = self.R_L / (1 - 1j * 2 * math.pi * self.detunings / self.w_half)        # Z_k(0)
        ib0 = self.I_b1 * np.exp(-1j * self.phi_s)
        ig0 = self.V_cav / z0.mean() + ib0
        vk = z0 * (ig0 - ib0)
        return dict(I_g0=ig0, V_k=vk, V_sum=vk.sum(), theta_g=float(np.angle(ig0 / vk.sum())))


# ------------------------------------------------------------------ 2x2 helpers on arrays (n, 2, 2)
def _scalar(z):
    z = np.asarray(z, dtype=complex)
    out = np.zeros(z.shape + (2, 2), dtype=complex)
    out[..., 0, 0] = z
    out[..., 1, 1] = z
    return out


def _rot(th: float) -> np.ndarray:
    c, s = math.cos(th), math.sin(th)
    return np.array([[c, -s], [s, c]])


def _resonator(s, R_L, w, dw):
    """Real-structure matrix of R_L w/(s + w - j dw)."""
    a = R_L * w / (s + w - 1j * dw)
    b = R_L * w / (s + w + 1j * dw)          # conj Z(conj s)
    fr, fi = (a + b) / 2, (a - b) / 2j
    out = np.empty(np.shape(s) + (2, 2), dtype=complex)
    out[..., 0, 0], out[..., 0, 1], out[..., 1, 0], out[..., 1, 1] = fr, -fi, fi, fr
    return out


def _inv2(A):
    det = A[..., 0, 0] * A[..., 1, 1] - A[..., 0, 1] * A[..., 1, 0]
    out = np.empty_like(A)
    out[..., 0, 0], out[..., 1, 1] = A[..., 1, 1] / det, A[..., 0, 0] / det
    out[..., 0, 1], out[..., 1, 0] = -A[..., 0, 1] / det, -A[..., 1, 0] / det
    return out, det


def chain(st: Station, s):
    """Real-impulse part of the loop: lead, lag (integral) network, amplifier pole, delay."""
    c = np.exp(-s * st.tau)
    if st.lead:
        c = c * (1 + s / (2 * math.pi * LEAD_FZ)) / (1 + s / (2 * math.pi * LEAD_FP))
    if st.lag:
        wz, wp = 2 * math.pi * st.f_lag_zero, 2 * math.pi * st.f_lag_pole
        c = c * (1 + (wz - wp) / (s + wp))
    if st.f_amp:
        wa = 2 * math.pi * st.f_amp
        c = c * wa / (s + wa)
    return c


def klystron_matrix(st: Station) -> np.ndarray:
    th = st.steady()["theta_g"] if st.theta_g is None else math.radians(st.theta_g)
    return _rot(th) @ np.array([[st.g_A, 0.0], [st.k_AP, 1.0]]) @ _rot(-th)


@dataclass
class Blocks:
    s: np.ndarray
    Z_sum: np.ndarray
    Z_m: np.ndarray
    P_b: np.ndarray
    D_open: np.ndarray
    M: np.ndarray
    K: np.ndarray


def blocks(st: Station, s) -> Blocks:
    s = np.atleast_1d(np.asarray(s, dtype=complex))
    w = st.w_half
    zk = [_resonator(s, st.R_L, w, 2 * math.pi * d) for d in st.detunings]
    z_sum = sum(zk)
    z_m = z_sum / N_CAV
    ps = st.phi_s
    b = np.array([-math.sin(ps), -math.cos(ps)])
    p = np.array([math.cos(ps), -math.sin(ps)])
    if st.beam and st.I_b > 0:
        kc = st.kappa1 * st.I_b1 * st.kappa_scale
        d_inc = s * s + 2 * ALPHA_RAD * s + st.w_s ** 2
        pzb = np.einsum("i,nij,j->n", p, z_sum, b)
        d_open = d_inc + kc * pzb
        zb = np.einsum("nij,j->ni", z_m, b)
        pz = np.einsum("i,nij->nj", p, z_sum)
        p_b = z_m - (kc / d_open)[:, None, None] * np.einsum("ni,nj->nij", zb, pz)
    else:
        d_open = np.full(s.shape, np.nan + 0j)
        p_b = z_m
    K = klystron_matrix(st)
    c = chain(st, s)
    M = (st.G * c / st.R_L)[:, None, None] * np.einsum("ij,njk,kl->nil", _rot(math.radians(st.theta)), p_b, K)
    return Blocks(s, z_sum, z_m, p_b, d_open, M, K)


def closed_loop_matrix(st: Station, f) -> np.ndarray:
    """T(f) = -(1 + M)^-1 M, the 2x2 response of TOTAL to the injected noise (cavity frame)."""
    bl = blocks(st, 2j * np.pi * np.asarray(f, dtype=float))
    inv, _ = _inv2(np.eye(2) + bl.M)
    return -np.einsum("nij,njk->nik", inv, bl.M)


def measured_tf(st: Station, f) -> np.ndarray:
    """Transfer function the routine records for noise injected along st.alpha (with the measurement chain)."""
    f = np.asarray(f, dtype=float)
    T = closed_loop_matrix(st, f)
    a = math.radians(st.alpha)
    ca, sa = math.cos(a), math.sin(a)
    h = np.exp(-1j * a) * ((T[:, 0, 0] * ca + T[:, 0, 1] * sa) + 1j * (T[:, 1, 0] * ca + T[:, 1, 1] * sa))
    if st.mc1r or st.mc1i or st.mc2r or st.mc2i:
        x = f / 400e3
        h = h * np.exp((st.mc1r + 1j * st.mc1i) * x + (st.mc2r + 1j * st.mc2i) * x * x)
    return h


def widely_linear(st: Station, f) -> tuple[np.ndarray, np.ndarray]:
    """(H1, H2): x(f) = H1 n(f) + H2 conj n(-f)."""
    T = closed_loop_matrix(st, f)
    a, b, c, d = T[:, 0, 0], T[:, 0, 1], T[:, 1, 0], T[:, 1, 1]
    return (a + d + 1j * (c - b)) / 2, (a - d + 1j * (c + b)) / 2


def char_det(st: Station, s) -> np.ndarray:
    """det(1 + M(s)) D_open(s): its zeros are the closed-loop poles, the coupled beam mode among them."""
    bl = blocks(st, s)
    _, det = _inv2(np.eye(2) + bl.M)
    return det * (bl.D_open if (st.beam and st.I_b > 0) else 1.0)


def coupled_mode(st: Station, steps: int = 30, s0: complex | None = None) -> complex:
    """Track the synchrotron root of det(1+M) D_open from zero current to st.I_b (Newton continuation)."""
    a, ws = ALPHA_RAD, st.with_(I_b=1e-9).w_s
    s = complex(-a, math.sqrt(ws * ws - a * a)) if s0 is None else s0
    path = np.linspace(0.0, 1.0, steps + 1)[1:] if s0 is None else [1.0]
    for lam in path:
        sub = st.with_(I_b=max(st.I_b * lam, 1e-9))
        for _ in range(100):
            h = 1e-3 * (1 + abs(s))
            f0 = complex(char_det(sub, np.array([s]))[0])
            d = (complex(char_det(sub, np.array([s + h]))[0]) - complex(char_det(sub, np.array([s - h]))[0])) / (2 * h)
            step = f0 / d
            s -= step
            if abs(step) < 1e-9 * (1 + abs(s)):
                break
        else:
            raise RuntimeError("coupled-mode Newton iteration did not converge")
    return s


def open_loop_mode(st: Station) -> complex:
    """Root of D_open (Pedersen's beam-loaded cavity without feedback), tracked from zero current."""
    return coupled_mode(st.with_(G=0.0))
