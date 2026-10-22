"""Parameter sets for the SPEAR3 RF system.

Defaults are the Doc P values; the trailing comment gives the source.
"""
from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np


@dataclass(frozen=True)
class Ring:
    energy_eV: float = 3.0e9        # Doc P sec. 1.2, [R1]
    harmonic: int = 372             # [R1]
    f_rf: float = 476.3e6           # nominal; SPEAR:RFFreq read 476.304062 MHz on 6 Oct 2026
    alpha_c: float = 1.18e-3        # Doc P; SSRL parameter page [R3] quotes 1.1e-3
    U0_eV: float = 1.09e6           # dipoles + IDs; Oct 2026 power balance gave 1.086 MeV at 497 mA
    U0_dipole_eV: float = 0.912e6   # bare lattice: tau_s 2.87 ms, tau_y 5.14 ms [R1]
    J_s_dipole: float = 1.79        # tau_y/tau_s of the bare lattice [R1]

    @property
    def J_s(self) -> float:
        """Longitudinal partition number; ID radiation (no dispersion) enters with J_s = 2."""
        return 2.0 + (self.J_s_dipole - 2.0) * self.U0_dipole_eV / self.U0_eV

    @property
    def T_rev(self) -> float:
        return self.harmonic / self.f_rf

    @property
    def f_rev(self) -> float:
        return self.f_rf / self.harmonic

    @property
    def w_rf(self) -> float:
        return 2.0 * math.pi * self.f_rf

    @property
    def w_rev(self) -> float:
        return 2.0 * math.pi * self.f_rev

    @property
    def alpha_rad(self) -> float:
        """Radiation damping rate of the synchrotron amplitude, J_s U0 / (2 E T0) [1/s]."""
        return self.J_s * self.U0_eV / (2.0 * self.energy_eV * self.T_rev)


@dataclass(frozen=True)
class Cavity:
    """One PEP-II cavity, circuit convention R_s = V^2 / (2 P_wall)."""

    R_over_Q: float = 116.6         # ohm = 3.73 MOhm / 32000, Schwarz PS-340-330-51 [R6]
    Q0: float = 32000.0             # [R6]
    beta: float = 3.78              # Doc P operating point; [R6] lists 3.72 for PEP-II

    @property
    def Rs(self) -> float:
        return self.R_over_Q * self.Q0

    @property
    def QL(self) -> float:
        return self.Q0 / (1.0 + self.beta)

    @property
    def RL(self) -> float:
        return self.Rs / (1.0 + self.beta)


@dataclass(frozen=True)
class Loop:
    """Cavity-field (direct) loop referred to the cavity.

    L(s) = C(s) * A(s) * exp(-s*delay) * Z_meas(s) / R_L, so for a tuned cavity with
    the integral path off L(0) = gain * exp(j*phase).  ``phase_deg`` is the error from
    ideal negative feedback (+ = lead).  The integral path is
    gi * exp(j*phase_i) * wi / (s + w_leak); with gi = gain it equals the proportional
    path in magnitude at offset fi_hz.
    """

    gain: float = 0.0
    phase_deg: float = 0.0
    delay: float = 270e-9
    gi: float = 0.0
    fi_hz: float = 0.0
    phase_i_deg: float = 0.0
    f_leak_hz: float = 0.0
    f_amp_hz: float | None = None           # one-pole bandwidth of drive amp + klystron
    lead_hz: tuple[float, float] | None = None   # (zero, pole) of a lead network

    @property
    def active(self) -> bool:
        return self.gain != 0.0 or self.gi != 0.0

    def controller(self, s):
        """C(s) A(s) exp(-s delay): everything in the loop except the cavity."""
        s = np.asarray(s, dtype=complex)
        c = self.gain * np.exp(1j * np.deg2rad(self.phase_deg)) * np.ones_like(s)
        if self.gi:
            wi, wl = 2 * np.pi * self.fi_hz, 2 * np.pi * self.f_leak_hz
            c = c + self.gi * np.exp(1j * np.deg2rad(self.phase_i_deg)) * wi / (s + wl)
        if self.lead_hz is not None:
            wz, wp = 2 * np.pi * self.lead_hz[0], 2 * np.pi * self.lead_hz[1]
            c = c * (1 + s / wz) / (1 + s / wp)
        if self.f_amp_hz:
            wa = 2 * np.pi * self.f_amp_hz
            c = c * wa / (s + wa)
        return c * np.exp(-s * self.delay)
