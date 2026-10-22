"""Fits of measured loop responses and synchrotron sidebands.

The loop model is the baseband form of Dimtel's ``direct_ol.m``
(llrf/llrf9/iGp/matlab/llrf): H = G e^{j phi} e^{-j 2 pi f tau} / (1 + j 2 Q (f - f_r)/f_rf),
with f the offset from the RF carrier and f_r the cavity resonance offset.
"""
from __future__ import annotations

import numpy as np
from scipy.optimize import least_squares


def open_loop_response(f, gain, q_loaded, f_res, delay, phase_deg, f_rf=476.3e6):
    f = np.asarray(f, dtype=float)
    return (gain * np.exp(1j * np.deg2rad(phase_deg)) * np.exp(-2j * np.pi * f * delay)
            / (1.0 + 2j * q_loaded * (f - f_res) / f_rf))


def closed_loop_response(f, gain, q_loaded, f_res, delay, phase_deg, kind="T", f_rf=476.3e6):
    """kind 'T' = L/(1+L) (reference to field), 'S' = 1/(1+L) (reference to error)."""
    L = open_loop_response(f, gain, q_loaded, f_res, delay, phase_deg, f_rf)
    return L / (1.0 + L) if kind == "T" else 1.0 / (1.0 + L)


def fit_loop_response(f, H, kind=None, p0=(1.0, 6700.0, 0.0, 500e-9, 0.0), f_rf=476.3e6):
    """Fit (gain, Q_L, f_res, delay, phase_deg); kind None = open loop, else 'T' or 'S'."""
    f = np.asarray(f, dtype=float)
    H = np.asarray(H, dtype=complex)

    def model(p):
        if kind is None:
            return open_loop_response(f, *p, f_rf=f_rf)
        return closed_loop_response(f, *p, kind=kind, f_rf=f_rf)

    def res(p):
        d = (model(p) - H) / np.maximum(np.abs(H), 1e-12)
        return np.concatenate([d.real, d.imag])

    scale = [1.0, 1e3, 1e4, 1e-7, 10.0]
    sol = least_squares(res, p0, x_scale=scale, xtol=1e-13, ftol=1e-13, max_nfev=20000)
    keys = ("gain", "q_loaded", "f_res", "delay", "phase_deg")
    return dict(zip(keys, sol.x), cost=float(sol.cost))


def resonator_through_loop(gain: float, q_loaded: float, kind: str = "T"):
    """Peak value and Q of the closed-loop response of a tuned cavity, no delay.

    A proportional loop of gain G turns a resonator of loaded Q into one of
    Q/(1+G) with peak G/(1+G) ('T') or 1/(1+G) ('S').
    """
    peak = gain / (1.0 + gain) if kind == "T" else 1.0 / (1.0 + gain)
    return peak, q_loaded / (1.0 + gain)


def lorentzian_db(f, f0, q, peak_dbc, floor_dbc):
    """Power Lorentzian of FWHM f0/q on a floor, in dB."""
    x = 2.0 * q * (np.asarray(f, float) - f0) / f0
    p = 10 ** (peak_dbc / 10) / (1 + x * x) + 10 ** (floor_dbc / 10)
    return 10 * np.log10(p)


def fit_lorentzian_db(f, p_dbc, p0):
    """Fit lorentzian_db to a sideband; p0 = (f0, q, peak_dbc, floor_dbc)."""
    f, p_dbc = np.asarray(f, float), np.asarray(p_dbc, float)
    sol = least_squares(lambda p: lorentzian_db(f, *p) - p_dbc, p0,
                        x_scale=[1e2, 1.0, 1.0, 1.0], max_nfev=20000)
    return dict(zip(("f0", "q", "peak_dbc", "floor_dbc"), sol.x))
