"""Time-domain check: rigid bunch + N cavities + delayed I/Q field loop.

Independent of the characteristic-equation code: cavities are integrated exactly
over each step (zero-order hold), the loop delay is a ring buffer, and the beam
couples to the envelopes continuously (valid for modulation frequencies well below
f_rev, i.e. the mu = 0 mode).  Lead networks are not modelled here.

Optionally the loop correction passes a klystron whose small-signal response differs
for amplitude and phase (in the frame of the steady generator current):
x -> s Re x + j (Im x + kappa Re x), with amplitude gain s and AM/PM kappa (rad per unit
relative amplitude).  s = 1, kappa = 0 is the complex-linear loop of the characteristic
equation; other values make the loop widely linear, which only this model covers.
"""
from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np
from scipy.optimize import least_squares

from .stability import Mode
from .system import RFSystem

try:
    from numba import njit
except ImportError:  # pragma: no cover - numba is optional
    def njit(*args, **kwargs):
        if args and callable(args[0]):
            return args[0]
        return lambda f: f


@njit(cache=True)
def _kernel(n_steps, every, nd, dt, ea, cin, w, Vk, Ig0, Vref, gp, ki, wl, wa,
            RL, Ib1, phis, wrf, ac, E, T0, U0, arad, tau0, s_amp, kappa):
    n_rec = n_steps // every
    rec = np.empty(n_rec)
    buf = np.empty(nd, dtype=np.complex128)
    vm0 = 0j
    for k in range(Vk.size):
        vm0 += w[k] * Vk[k]
    for i in range(nd):
        buf[i] = vm0
    gh = Ig0 / abs(Ig0)
    p = 0
    x = 0j
    amp = 0j
    tau = tau0
    dlt = 0.0
    amp_c = 1.0 - math.exp(-wa * dt) if wa > 0.0 else 1.0
    j = 0
    for n in range(n_steps):
        e = Vref - buf[p]
        x += dt * (ki * e - wl * x)
        u = (gp * e + x) / RL
        amp += amp_c * (u - amp)
        r = amp * np.conj(gh)
        kly = (s_amp * r.real + 1j * (r.imag + kappa * r.real)) * gh
        th = phis + wrf * tau
        ib = Ib1 * (math.cos(th) - 1j * math.sin(th))
        drive = Ig0 + kly - ib
        vs = 0j
        vm = 0j
        for k in range(Vk.size):
            Vk[k] = Vk[k] * ea[k] + cin[k] * drive
            vs += Vk[k]
            vm += w[k] * Vk[k]
        gain = vs.real * math.cos(th) - vs.imag * math.sin(th)
        dlt += dt * ((gain - U0) / (E * T0) - 2.0 * arad * dlt)
        tau += dt * ac * dlt
        buf[p] = vm
        p += 1
        if p == nd:
            p = 0
        if (n + 1) % every == 0:
            rec[j] = tau
            j += 1
    return rec


@dataclass(frozen=True)
class Trace:
    t: np.ndarray
    tau: np.ndarray       # bunch arrival-time deviation [s]
    fit: Mode


def fit_damped_cosine(t: np.ndarray, x: np.ndarray) -> Mode:
    """Fit exp(-sigma t)(a cos w t + b sin w t) + c; a, b, c are solved linearly."""
    t = t - t[0]
    x = x / np.max(np.abs(x))
    z = x - x.mean()
    zc = np.nonzero(np.diff(np.sign(z)) > 0)[0]
    w0 = 2 * np.pi * (len(zc) - 1) / (t[zc[-1]] - t[zc[0]])
    half = len(t) // 2
    a1, a2 = np.abs(z[:half]).max(), np.abs(z[half:]).max()
    s0 = math.log(a1 / max(a2, 1e-30)) / t[half]

    def res(p):
        e = np.exp(-p[0] * t)
        basis = np.column_stack([e * np.cos(p[1] * t), e * np.sin(p[1] * t), np.ones_like(t)])
        coef = np.linalg.lstsq(basis, x, rcond=None)[0]
        return basis @ coef - x

    sol = least_squares(res, [s0, w0], x_scale=[abs(s0) + 10.0, w0], xtol=1e-14, ftol=1e-14)
    return Mode(complex(-sol.x[0], abs(sol.x[1])))


def simulate(system: RFSystem, t_end: float = 4e-3, dt: float = 5e-9,
             kick: float = 1e-16, record_every: int = 200, skip: float = 0.2e-3,
             klystron_amp_gain: float = 1.0, klystron_am_pm: float = 0.0) -> Trace:
    """Kick the bunch by ``kick`` seconds and fit the coherent oscillation.

    Keep w_rf * kick * exp(growth * t_end) << 1, otherwise the bucket nonlinearity
    lowers the fitted frequency of a growing mode.
    """
    lp = system.loop
    if lp.lead_hz is not None:
        raise NotImplementedError("lead network not modelled in the time domain")
    nd = max(1, int(round(lp.delay / dt)))
    cav = system.cavity
    wh = system.w_half
    a = -(wh - 1j * 2 * np.pi * system.detuning)
    ea = np.exp(a * dt)
    cin = cav.RL * wh * (ea - 1.0) / a
    z0 = system.z_cavities(0.0)
    ib0 = system.I_b1 * np.exp(-1j * system.phi_s)
    ig0 = system.V_total / z0.sum() + ib0
    vk = z0 * (ig0 - ib0)
    w = system.vector_sum_weights.astype(np.complex128)
    vref = complex(vk @ w)
    gp = lp.gain * np.exp(1j * np.deg2rad(lp.phase_deg)) if lp.active else 0j
    ki = (lp.gi * np.exp(1j * np.deg2rad(lp.phase_i_deg)) * 2 * np.pi * lp.fi_hz) if lp.gi else 0j
    wl = 2 * np.pi * lp.f_leak_hz
    wa = 2 * np.pi * lp.f_amp_hz if lp.f_amp_hz else 0.0
    r = system.ring
    n_steps = int(round(t_end / dt))
    rec = _kernel(n_steps, record_every, nd, dt, ea.astype(np.complex128), cin.astype(np.complex128),
                  w, vk.astype(np.complex128), complex(ig0), vref, complex(gp), complex(ki),
                  wl, wa, cav.RL, system.I_b1, system.phi_s, r.w_rf, r.alpha_c,
                  r.energy_eV, r.T_rev, r.U0_eV, r.alpha_rad, kick,
                  float(klystron_amp_gain), float(klystron_am_pm))
    t = (np.arange(rec.size) + 1) * record_every * dt
    keep = t >= skip
    return Trace(t, rec, fit_damped_cosine(t[keep], rec[keep]))
