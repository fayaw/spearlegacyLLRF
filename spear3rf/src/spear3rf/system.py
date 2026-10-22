"""Steady-state beam loading and small-signal impedances of the SPEAR3 RF station.

Conventions (Doc P): phi_s from the crest, V cos(phi_s) = U0; detuning
df = f_r - f_rf (negative below RF); tan(psi_L) = 2 Q_L df / f_rf.  Small-signal
quantities are baseband transfer functions of s, the Laplace variable of the RF
envelope, so s = j*2*pi*f_offset on the frequency axis.
"""
from __future__ import annotations

import math
from dataclasses import dataclass, field, replace

import numpy as np

from .params import Cavity, Loop, Ring


@dataclass(frozen=True)
class RFSystem:
    """One power source driving ``n_cav`` cavities, with beam and field loop.

    All cavities receive the same generator current (per-cavity normalisation).  The
    loop measures the weighted vector sum ``weights`` (default: every cavity, equal
    weight; LLRF9 uses only two probes).
    """

    ring: Ring = field(default_factory=Ring)
    cavity: Cavity = field(default_factory=Cavity)
    loop: Loop = field(default_factory=Loop)
    n_cav: int = 4
    V_total: float = 2.85e6
    I0: float = 0.5
    form_factor: float = 1.0
    detuning_hz: tuple[float, ...] | float | None = None   # None: optimum for I0
    weights: tuple[float, ...] | None = None

    def with_(self, **kw) -> "RFSystem":
        return replace(self, **kw)

    # ------------------------------------------------------------ steady state
    @property
    def phi_s(self) -> float:
        return math.acos(self.ring.U0_eV / self.V_total)

    @property
    def V_cav(self) -> float:
        return self.V_total / self.n_cav

    @property
    def I_b1(self) -> float:
        """Fundamental RF component of the bunched beam current [A]."""
        return 2.0 * self.form_factor * self.I0

    @property
    def w_half(self) -> float:
        """Loaded half-bandwidth w_r / (2 Q_L) [rad/s]."""
        return self.ring.w_rf / (2.0 * self.cavity.QL)

    def optimum_detuning_hz(self, I0: float | None = None) -> float:
        """Detuning that cancels the reactive beam loading (Doc P eq. df-opt)."""
        I_b1 = 2.0 * self.form_factor * (self.I0 if I0 is None else I0)
        return (-self.cavity.R_over_Q * I_b1 * math.sin(self.phi_s) * self.ring.f_rf
                / (2.0 * self.V_cav))

    @property
    def detuning(self) -> np.ndarray:
        if self.detuning_hz is None:
            return np.full(self.n_cav, self.optimum_detuning_hz())
        d = np.asarray(self.detuning_hz, dtype=float)
        return np.broadcast_to(d, (self.n_cav,)).copy()

    @property
    def tan_psi_L(self) -> np.ndarray:
        return 2.0 * self.cavity.QL * self.detuning / self.ring.f_rf

    @property
    def Y(self) -> float:
        """Beam-loading parameter I_b1 R_L / V_cav (Pedersen's Y)."""
        return self.I_b1 * self.cavity.RL / self.V_cav

    @property
    def w_s(self) -> float:
        """Incoherent synchrotron angular frequency in the total gap voltage."""
        r = self.ring
        return math.sqrt(r.alpha_c * r.w_rf * self.V_total * math.sin(self.phi_s)
                         / (r.energy_eV * r.T_rev))

    @property
    def K(self) -> float:
        """Beam-cavity coupling alpha_c w_rf (I_b1/2) / (E T0) [1/(ohm s^2)]."""
        r = self.ring
        return r.alpha_c * r.w_rf * 0.5 * self.I_b1 / (r.energy_eV * r.T_rev)

    @property
    def P_wall(self) -> float:
        return self.V_cav ** 2 / (2.0 * self.cavity.Rs)

    @property
    def P_beam_per_cav(self) -> float:
        return self.I0 * self.ring.U0_eV / self.n_cav

    def reflection(self) -> np.ndarray:
        """|Gamma|^2 at each coupler with the field held at V_cav (Doc P eq. gamma)."""
        c = self.cavity
        a = self.I_b1 * c.Rs * math.cos(self.phi_s) / self.V_cav
        b = self.I_b1 * c.Rs * math.sin(self.phi_s) / self.V_cav
        t = 2.0 * c.Q0 * self.detuning / self.ring.f_rf
        return ((c.beta - 1 - a) ** 2 + (t + b) ** 2) / ((c.beta + 1 + a) ** 2 + (t + b) ** 2)

    # -------------------------------------------------------- small signal
    @property
    def vector_sum_weights(self) -> np.ndarray:
        w = np.ones(self.n_cav) if self.weights is None else np.asarray(self.weights, float)
        return w / w.sum()

    def z_cavities(self, s) -> np.ndarray:
        """Baseband impedance of each cavity, shape s.shape + (n_cav,) [ohm]."""
        s = np.asarray(s, dtype=complex)[..., None]
        dw = 2.0 * np.pi * self.detuning
        return self.cavity.RL * self.w_half / (s + self.w_half - 1j * dw)

    def z_total(self, s):
        """Open-loop impedance of all cavities in series along the beam."""
        return self.z_cavities(s).sum(axis=-1)

    def z_measured(self, s):
        return self.z_cavities(s) @ self.vector_sum_weights

    def open_loop(self, s):
        """L(s); the RF loop alone is stable if 1 + L has no right-half-plane zeros."""
        return self.loop.controller(s) * self.z_measured(s) / self.cavity.RL

    def z_beam(self, s):
        """Impedance seen by the beam with the field loop closed: Z_total / (1 + L)."""
        z = self.z_total(s)
        if not self.loop.active:
            return z
        return z / (1.0 + self.open_loop(s))
