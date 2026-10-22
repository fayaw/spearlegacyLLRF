"""Coherent synchrotron modes of the beam coupled to the cavities and the field loop.

Model: rigid bunches, uniform fill, coupled-bunch mode ``mu``.  The characteristic
function is

    F(s) = s^2 + 2 a_rad s + w_s^2 - j K [Z(s') - conj Z(conj s')],  s' = s + j mu w_rev

with Z the closed-loop impedance seen by the beam (RFSystem.z_beam).  For the open
loop it reduces exactly to Pedersen's quartic, IEEE TNS NS-22 (1975) 1906, eq. (5).
"""
from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np

from .system import RFSystem


def char_fn(system: RFSystem, s, mu: int = 0, coupling: float = 1.0):
    s = np.asarray(s, dtype=complex)
    sp = s + 1j * mu * system.ring.w_rev
    w = system.z_beam(sp) - np.conj(system.z_beam(np.conj(sp)))
    return (s * s + 2.0 * system.ring.alpha_rad * s + system.w_s ** 2
            - 1j * coupling * system.K * w)


@dataclass(frozen=True)
class Mode:
    s: complex

    @property
    def frequency(self) -> float:
        return self.s.imag / (2.0 * math.pi)

    @property
    def damping(self) -> float:
        """Amplitude damping rate [1/s]; negative means growth."""
        return -self.s.real

    @property
    def Q(self) -> float:
        """omega / (2 sigma): equals f / FWHM of the power-spectrum Lorentzian."""
        return abs(self.s.imag) / (2.0 * self.damping)


def _newton(f, s: complex, tol: float = 1e-12, maxit: int = 80) -> complex:
    for _ in range(maxit):
        fs = complex(f(s))
        h = 1e-6 * (1.0 + abs(s))
        d = (complex(f(s + h)) - complex(f(s - h))) / (2.0 * h)
        step = fs / d
        s = s - step
        if abs(step) <= tol * (1.0 + abs(s)):
            return s
    raise RuntimeError("Newton iteration did not converge")


def beam_mode(system: RFSystem, mu: int = 0, steps: int = 24) -> Mode:
    """Track the synchrotron root from zero beam coupling to the full value."""
    a, ws = system.ring.alpha_rad, system.w_s
    s = complex(-a, math.sqrt(max(ws * ws - a * a, 0.0)))
    for lam in np.linspace(0.0, 1.0, steps + 1)[1:]:
        s = _newton(lambda z: char_fn(system, z, mu, lam), s)
    return Mode(s)


def sideband_estimate(system: RFSystem, mu: int = 0) -> Mode:
    """First-order (Robinson/Sands) estimate from Re and Im Z at the two sidebands."""
    ws, w0 = system.w_s, system.ring.w_rev
    zp = complex(system.z_beam(1j * (mu * w0 + ws)))
    zm = complex(system.z_beam(-1j * (mu * w0 + ws)))
    g = system.K / (2.0 * ws)
    return Mode(complex(-system.ring.alpha_rad + g * (zp.real - zm.real),
                        ws + g * (zp.imag + zm.imag)))


def static_ratio(system: RFSystem) -> float:
    """F(0)/w_s^2: the high-current (second) Robinson limit is reached at zero."""
    z0 = complex(system.z_beam(1e-9))   # s -> 0+ keeps a pure integrator finite
    return 1.0 + 2.0 * system.K * z0.imag / system.w_s ** 2


def pedersen_quartic(system: RFSystem) -> np.ndarray:
    """Pedersen (1975) eq. (5) plus radiation damping, for identical open-loop cavities.

    Uses his variables: sigma = cavity half-bandwidth, t = tan(phi_z) = -tan(psi_L),
    Y = I_b1 R_L / V_cav, cos(phi_B) -> sin(phi_s) for the crest convention.
    """
    sig, a, ws2 = system.w_half, system.ring.alpha_rad, system.w_s ** 2
    t = -float(system.tan_psi_L[0])
    k = system.Y * t / math.sin(system.phi_s)
    return np.array([1.0,
                     2 * sig + 2 * a,
                     sig ** 2 * (1 + t ** 2) + 4 * a * sig + ws2,
                     2 * a * sig ** 2 * (1 + t ** 2) + 2 * sig * ws2,
                     sig ** 2 * ws2 * (1 + t ** 2 - k)])


@dataclass(frozen=True)
class Margins:
    phase_margin_deg: float
    gain_margin_db: float               # gain increase to instability (|L| < 1 crossings)
    gain_reduction_margin_db: float     # gain decrease to instability (|L| > 1 crossings)
    modulus_margin: float               # min |1 + L| = 1 / max |S|
    crossovers_hz: tuple[float, ...]


def loop_margins(system: RFSystem, f_max: float = 6e6, n: int = 600_001) -> Margins:
    """Stability margins of the complex (I/Q) loop over both sidebands.

    With an integral path the Nyquist curve can cross the negative real axis with
    |L| > 1 (conditional stability); that is reported as a gain-reduction margin, not
    as instability.  Use count_rhp_zeros for the actual verdict.
    """
    f = np.linspace(-f_max, f_max, n)
    f = f[f != 0.0]
    L = system.open_loop(2j * np.pi * f)
    mag, ph = np.abs(L), np.angle(L)
    pm, gm, grm, xs = 360.0, math.inf, math.inf, []
    for side in (f < 0, f > 0):
        fs_, m, p, l = f[side], mag[side], ph[side], L[side]
        for i in np.nonzero(np.diff(np.sign(m - 1.0)))[0]:
            w = (1.0 - m[i]) / (m[i + 1] - m[i])
            phi = np.angle(np.exp(1j * (p[i] + w * np.angle(np.exp(1j * (p[i + 1] - p[i]))))))
            pm = min(pm, 180.0 - abs(np.degrees(phi)))
            xs.append(fs_[i] + w * (fs_[i + 1] - fs_[i]))
        for i in np.nonzero((np.diff(np.sign(l.imag)) != 0) & (l.real[:-1] < 0))[0]:
            db = 20.0 * math.log10(0.5 * (m[i] + m[i + 1]))
            if db < 0:
                gm = min(gm, -db)
            else:
                grm = min(grm, db)
    return Margins(pm if xs else math.inf, gm, grm, float(np.min(np.abs(1.0 + L))), tuple(xs))


def _arg_change(fn, a: complex, b: complex, n0: int = 2001, tol: float = 0.3,
                max_pts: int = 2_000_000) -> float:
    t = np.linspace(0.0, 1.0, n0)
    v = np.asarray(fn(a + t * (b - a)), dtype=complex)
    while True:
        d = np.angle(v[1:] / v[:-1])
        bad = np.nonzero(np.abs(d) > tol)[0]
        if bad.size == 0:
            return float(d.sum())
        if t.size + bad.size > max_pts:
            raise RuntimeError("argument principle: contour passes too close to a zero")
        tm = 0.5 * (t[bad] + t[bad + 1])
        vm = np.asarray(fn(a + tm * (b - a)), dtype=complex)
        t = np.insert(t, bad + 1, tm)
        v = np.insert(v, bad + 1, vm)


def count_rhp_zeros(fn, sigma_max: float = 2e7, omega_max: float = 2 * np.pi * 10e6,
                    eps: float = 1e-3) -> int:
    """Zeros minus poles of an analytic ``fn`` inside Re s in (eps, sigma_max), |Im s| < omega_max."""
    c = [eps - 1j * omega_max, sigma_max - 1j * omega_max,
         sigma_max + 1j * omega_max, eps + 1j * omega_max, eps - 1j * omega_max]
    total = sum(_arg_change(fn, a, b) for a, b in zip(c[:-1], c[1:]))
    return int(round(total / (2.0 * np.pi)))


def stability_report(system: RFSystem, modes=(0, -1, 1, -2, 2)) -> dict:
    """Loop margins, RHP-zero counts and the tracked beam modes in one place."""
    loop_unstable = (count_rhp_zeros(lambda s: 1.0 + system.open_loop(s))
                     if system.loop.active else 0)
    beam_unstable = count_rhp_zeros(lambda s: char_fn(system, s)) if loop_unstable == 0 else None
    return {
        "margins": loop_margins(system) if system.loop.active else None,
        "rf_loop_rhp_zeros": loop_unstable,
        "beam_mu0_rhp_zeros": beam_unstable,
        "static_ratio": static_ratio(system),
        "modes": {mu: beam_mode(system, mu) for mu in modes},
    }
