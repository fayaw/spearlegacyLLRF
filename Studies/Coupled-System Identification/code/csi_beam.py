"""The coupled beam-cavity-loop mode in the closed-loop records (3-16 kHz), model-free and model-based.

Model-free: within 3 <= |f| <= 16 kHz the recorded response is a smooth background plus the closed-loop
pole pair of the dipole mode, s = -sigma +- j w_c:
    H(f) = b0 + b1 (f/1e4) + b2 (f/1e4)^2 + r+/(j 2 pi f - p) + r-/(j 2 pi f - conj p),  p = -sigma + j w_c
(complex b's and residues), convolved with the Hann window's power kernel of the 2^15-point estimate. The
pole is common to both sidebands, as it must be for a real (I/Q-coupled) mode.

Model-based: csi_model.coupled_mode() of the station identified from the wideband response, and the
predicted response itself on the same bins.
"""
from __future__ import annotations

import math

import numpy as np
from scipy.optimize import least_squares

import csi_data as cd
import csi_fit as cf
import csi_model as cm

NFFT = 2 ** 15
BAND = (3e3, 16e3)


def beam_spectrum(rec, band=BAND, nfft=NFFT, exclude=()):
    return cf.spectrum(rec, nfft, band[0], band[1], smear=True, smooth=5, exclude=exclude)


def pole_model(q, f):
    b = (q[0] + 1j * q[1]) + (q[2] + 1j * q[3]) * (f / 1e4) + (q[4] + 1j * q[5]) * (f / 1e4) ** 2
    p = -q[6] + 2j * np.pi * q[7] * 1e3
    s = 2j * np.pi * f
    return b + (q[8] + 1j * q[9]) * 1e3 / (s - p) + (q[10] + 1j * q[11]) * 1e3 / (s - np.conj(p))


def pole_fit(sp: cf.Spectrum, f0_list=(8.0, 9.0, 10.0), sig0_list=(500.0, 1500.0)):
    fine = (sp.f[:, None] + sp.kern_off[None, :])

    def res(q):
        m = pole_model(q, fine.ravel()).reshape(fine.shape) @ sp.kern_w
        d = (m - sp.H) / sp.sigma
        return np.concatenate([d.real, d.imag])
    best = None
    for f0 in f0_list:
        for s0 in sig0_list:
            for r0 in ((1, 0), (0, 1), (-1, 0), (0, -1)):
                q0 = [np.median(sp.H.real), np.median(sp.H.imag), 0, 0, 0, 0, s0, f0, r0[0], r0[1], r0[0], -r0[1]]
                lo = [-10] * 6 + [-3000, 4.0] + [-200] * 4
                hi = [10] * 6 + [20000, 14.0] + [200] * 4
                try:
                    r = least_squares(res, q0, bounds=(lo, hi), max_nfev=4000, x_scale="jac")
                except ValueError:
                    continue
                if best is None or r.cost < best.cost:
                    best = r
    J = best.jac
    dof = 2 * sp.n - len(best.x)
    chi2 = 2 * best.cost
    cov = np.linalg.pinv(J.T @ J) * max(chi2 / dof, 1.0)
    return dict(f=best.x[7] * 1e3, sigma=best.x[6], df=math.sqrt(cov[7, 7]) * 1e3, dsigma=math.sqrt(cov[6, 6]),
                chi2_red=chi2 / dof, q=best.x)


def model_mode(st: cm.Station) -> tuple[float, float]:
    s = cm.coupled_mode(st)
    return s.imag / (2 * math.pi), -s.real
