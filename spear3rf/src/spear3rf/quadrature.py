"""Two-quadrature small-signal model of the station: klystron anisotropy and RF noise.

Doc P, Appendix C.  Every RF envelope is the real vector (I, Q), and every complex-coefficient
transfer function F(s) the real matrix [[F_r, -F_i], [F_i, F_r]] with F_r = (F + Fb)/2,
F_i = (F - Fb)/2j and Fb(s) = conj(F(conj s)).  A klystron near saturation passes a drive
change along the steady generator current with gain ``amp_gain`` and turns it into output
phase with ``am_pm`` rad per unit relative amplitude:
K = R(th_g) [[amp_gain, 0], [am_pm, 1]] R(-th_g), as in timedomain.simulate.

    Z_b   = P_sum (1 + F_fw P_meas)^-1                      closed-loop impedance (2 x 2)
    D0    = s^2 + 2 a_rad s + w_s^2 + 2 kappa p^T Z_b b     p = (cos, -sin) phi_s, b = (-sin, -cos) phi_s
    n_eff = p^T Z_b [dI_kly - F_fw (dV_meas - dV_ref)] / (V sin phi_s)   beam held fixed
    dphi  = chi n_eff,   chi = w_s^2 / D0

F_fw is the forward path from the error voltage to the generator current (controller, amplifier,
delay, klystron).  With amp_gain = 1 and am_pm = 0, D0 equals stability.char_fn for mu = 0.
"""
from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np

from .stability import Mode
from .system import RFSystem

SOURCES = ("klystron_AM", "klystron_PM", "drive_AM", "drive_PM", "measurement_AM", "measurement_PM")
_trapz = getattr(np, "trapezoid", None) or np.trapz


def _rot(th: float) -> np.ndarray:
    c, s = math.cos(th), math.sin(th)
    return np.array([[c, -s], [s, c]])


def real_matrix(F, s) -> np.ndarray:
    """Real-structure matrix of a complex-coefficient transfer function, shape s.shape + (2, 2)."""
    s = np.asarray(s, dtype=complex)
    fs = np.broadcast_to(np.asarray(F(s), dtype=complex), s.shape)
    fb = np.conj(np.broadcast_to(np.asarray(F(np.conj(s)), dtype=complex), s.shape))
    fr, fi = (fs + fb) / 2, (fs - fb) / 2j
    return np.stack([np.stack([fr, -fi], -1), np.stack([fi, fr], -1)], -2)


def sidebands(v) -> tuple[np.ndarray, np.ndarray]:
    """Power gains from a real input to the upper and lower sideband of an (I, Q) response."""
    v = np.asarray(v)
    return np.abs(v[..., 0] + 1j * v[..., 1]) ** 2, np.abs(v[..., 0] - 1j * v[..., 1]) ** 2


def frequency_grid(f_max: float = 2e6) -> np.ndarray:
    """Integration grid [Hz]: 1 Hz steps from 1 to 30 kHz, logarithmic below and above."""
    return np.unique(np.concatenate([np.geomspace(0.1, 1e3, 1500), np.arange(1e3, 30e3, 1.0),
                                     np.geomspace(30e3, f_max, 3000)]))


@dataclass(frozen=True)
class Response:
    f: np.ndarray
    D0: np.ndarray
    chi: np.ndarray            # beam phase per unit drive, w_s^2 / D0
    drive: dict                # source -> n_eff per unit source, beam held fixed
    probe: dict                # source -> (I, Q) envelope of the probed cavity per unit source, beam fixed [V]
    beam_to_probe: np.ndarray  # (I, Q) envelope of the probed cavity per radian of beam phase [V]
    open_loop: np.ndarray      # complex G_OL of the linear loop, for the scalar comparison


class Quadrature:
    """Coherent dipole mode (mu = 0) and its drive, for a klystron that may treat AM and PM differently.

    Sources are relative amplitude (``*_AM``) or phase in rad (``*_PM``): ``klystron_*`` at the
    klystron output (frame of the steady generator current), ``drive_*`` ahead of the klystron,
    ``measurement_*`` on the vector sum (frame of the measured voltage).  Reference noise acts as
    measurement noise of the opposite sign.
    """

    def __init__(self, system: RFSystem, amp_gain: float = 1.0, am_pm: float = 0.0, probe: int = 0):
        self.system, self.amp_gain, self.am_pm, self.probe = system, amp_gain, am_pm, probe
        z0 = system.z_cavities(0.0)
        ib0 = system.I_b1 * np.exp(-1j * system.phi_s)
        self.I_g0 = complex(system.V_total / z0.sum() + ib0)
        self.V_k0 = z0 * (self.I_g0 - ib0)
        self.V_m0 = complex(self.V_k0 @ system.vector_sum_weights)
        self.th_g, self.th_m = float(np.angle(self.I_g0)), float(np.angle(self.V_m0))
        self.K = _rot(self.th_g) @ np.array([[amp_gain, 0.0], [am_pm, 1.0]]) @ _rot(-self.th_g)
        ps = system.phi_s
        self.b_hat = np.array([-math.sin(ps), -math.cos(ps)])
        self.p_hat = np.array([math.cos(ps), -math.sin(ps)])
        self._V_sin = system.V_total * math.sin(ps)

    def _blocks(self, s):
        sy = self.system
        s = np.asarray(s, dtype=complex)
        zk = [real_matrix(lambda z, k=k: sy.z_cavities(z)[..., k], s) for k in range(sy.n_cav)]
        p_sum = sum(zk)
        p_meas = sum(w * z for w, z in zip(sy.vector_sum_weights, zk))
        if sy.loop.active:
            f_fw = self.K @ real_matrix(sy.loop.controller, s) / sy.cavity.RL
        else:
            f_fw = np.zeros_like(p_sum)
        inv = np.linalg.inv(np.eye(2) + f_fw @ p_meas)
        return zk, p_sum, f_fw, inv

    def char_fn(self, s, coupling: float = 1.0):
        sy = self.system
        s = np.asarray(s, dtype=complex)
        _, p_sum, _, inv = self._blocks(s)
        beam = np.einsum("i,...ij,j->...", self.p_hat, p_sum @ inv, self.b_hat)
        return s * s + 2.0 * sy.ring.alpha_rad * s + sy.w_s ** 2 + 2.0 * coupling * sy.K * beam

    def mode(self, steps: int = 24) -> Mode:
        """Track the synchrotron root from zero beam coupling to the full value."""
        a, ws = self.system.ring.alpha_rad, self.system.w_s
        s = complex(-a, math.sqrt(max(ws * ws - a * a, 0.0)))
        for lam in np.linspace(0.0, 1.0, steps + 1)[1:]:
            for _ in range(80):
                h = 1e-6 * (1.0 + abs(s))
                d = (complex(self.char_fn(s + h, lam)) - complex(self.char_fn(s - h, lam))) / (2.0 * h)
                step = complex(self.char_fn(s, lam)) / d
                s -= step
                if abs(step) <= 1e-12 * (1.0 + abs(s)):
                    break
            else:
                raise RuntimeError("Newton iteration did not converge")
        return Mode(s)

    def response(self, f_hz) -> Response:
        """Frequency responses at offsets ``f_hz`` from the carrier (s = j 2 pi f)."""
        sy = self.system
        f = np.atleast_1d(np.asarray(f_hz, dtype=float))
        s = 2j * np.pi * f
        zk, p_sum, f_fw, inv = self._blocks(s)
        zb = p_sum @ inv
        d0 = s * s + 2.0 * sy.ring.alpha_rad * s + sy.w_s ** 2 + 2.0 * sy.K * np.einsum(
            "i,nij,j->n", self.p_hat, zb, self.b_hat)
        row = np.einsum("i,nij->nj", self.p_hat, zb) / self._V_sin
        ug = _rot(self.th_g) * abs(self.I_g0)
        um = _rot(self.th_m) * abs(self.V_m0)
        currents = {"klystron_AM": ug[:, 0], "klystron_PM": ug[:, 1],
                    "drive_AM": self.K @ ug[:, 0], "drive_PM": self.K @ ug[:, 1]}
        za = zk[self.probe]
        drive = {k: row @ u for k, u in currents.items()}
        probe = {k: np.einsum("nij,njk,k->ni", za, inv, u) for k, u in currents.items()}
        for tag, col in (("measurement_AM", 0), ("measurement_PM", 1)):
            drive[tag] = -np.einsum("nj,njk,k->n", row, f_fw, um[:, col])
            probe[tag] = -np.einsum("nij,njk,nkl,l->ni", za, inv, f_fw, um[:, col])
        b2p = -np.einsum("nij,njk,k->ni", za, inv, self.b_hat) * sy.I_b1
        gol = sy.open_loop(s) if sy.loop.active else np.zeros_like(s)
        return Response(f, d0, sy.w_s ** 2 / d0, drive, probe, b2p, np.asarray(gol))


def beam_variance(q: Quadrature, source: str, f_hz=None) -> tuple[float, float]:
    """<dphi^2> [rad^2] and <(dE/E0)^2> per unit one-sided white spectral density of ``source``."""
    f = frequency_grid() if f_hz is None else np.asarray(f_hz, dtype=float)
    r = q.response(f)
    y = np.abs(r.chi * r.drive[source]) ** 2
    ring = q.system.ring
    return float(_trapz(y, f)), float(_trapz(y * (2.0 * np.pi * f / (ring.alpha_c * ring.w_rf)) ** 2, f))
