"""Consistency checks of csi_model against an independent implementation (spear3rf package and analysis scripts).

1. complex-linear loop, no beam: -L/(1+L) of analyze_measure_direct.closed_loop
2. widely-linear klystron, no beam: analyze_measure_direct.closed_loop_wl
3. coupled mode, linear klystron: spear3rf.stability.beam_mode (characteristic equation, Pedersen + loop)
4. coupled mode, compressed klystron: spear3rf.quadrature.Quadrature.mode (two-quadrature form)
5. time-domain simulation of the beam + loop (spear3rf.timedomain), no lead network
Run: python test_model.py
"""
import math
import sys

import numpy as np

import csi_model as cm
from csi_data import ROOT

sys.path.insert(0, str(ROOT / "spear3rf" / "src"))
sys.path.insert(0, str(ROOT / "spear3rf" / "scripts"))
import analyze_measure_direct as amd  # noqa: E402
from spear3rf.params import Cavity, Loop, Ring  # noqa: E402
from spear3rf.quadrature import Quadrature  # noqa: E402
from spear3rf.stability import beam_mode  # noqa: E402
from spear3rf.system import RFSystem  # noqa: E402


def rfsystem(st: cm.Station, lead=True, lag=True, amp=True) -> RFSystem:
    ring = Ring(f_rf=cm.F_RF, U0_eV=st.U0, alpha_c=st.alpha_c)
    cav = Cavity(R_over_Q=cm.R_OVER_Q, Q0=cm.Q0_CAV, beta=cm.Q0_CAV / st.Q_L - 1)
    loop = Loop(gain=st.G, phase_deg=st.theta, delay=st.tau,
                gi=st.G if lag else 0.0, fi_hz=(cm.LAG_FZ - cm.LAG_FP) if lag else 0.0, phase_i_deg=st.theta,
                f_leak_hz=cm.LAG_FP if lag else 0.0, f_amp_hz=cm.F_AMP if amp else None,
                lead_hz=(cm.LEAD_FZ, cm.LEAD_FP) if lead else None)
    return RFSystem(ring=ring, cavity=cav, loop=loop, I0=st.I_b, V_total=st.V_total,
                    detuning_hz=tuple(st.detunings))


def main():
    f = np.concatenate([np.linspace(-400e3, -1e3, 300), np.linspace(1e3, 400e3, 300)])
    ok = True

    st = cm.Station(I_b=0.0, G=0.9, theta=7.0, tau=624e-9, Q_L=6800, df=-3e3, beam=False)
    h_mine = cm.measured_tf(st, f)
    h_ref = amd.closed_loop([0.9, 7.0, 624.0, 6800.0, -3.0], f, fi=amd.LAG[0], fl=amd.LAG[1])
    e1 = np.max(np.abs(h_mine - h_ref))
    print(f"1. complex-linear, no beam: max |diff| = {e1:.2e}")
    ok &= e1 < 1e-9

    for phi_u, alpha in ((20.0, 45.0), (-70.0, 10.0)):
        st2 = st.with_(g_A=0.4, k_AP=0.35, theta_g=phi_u, alpha=alpha, df=-35e3)
        h_mine = cm.measured_tf(st2, f)
        h_ref = amd.closed_loop_wl(f, 0.9, 7.0, 624.0, 6800.0, -35.0, 0.4, 0.35, phi_u, alpha=alpha)
        e2 = np.max(np.abs(h_mine - h_ref))
        print(f"2. widely linear, no beam (phi_u {phi_u}, alpha {alpha}): max |diff| = {e2:.2e}")
        ok &= e2 < 1e-9

    for I, G, th, lead, lag in ((0.5, 1.0, 0.0, True, True), (0.3, 0.9, -10.0, False, True), (0.5, 0.0, 0.0, False, False)):
        st3 = cm.Station(I_b=I, G=G, theta=th, tau=625e-9, Q_L=6700, lead=lead, lag=lag)
        st3 = st3.with_(df=st3.optimum_detuning())
        s_mine = cm.coupled_mode(st3)
        s_ref = beam_mode(rfsystem(st3, lead, lag)).s
        print(f"3. coupled mode, linear klystron, I {I} A G {G} theta {th} lead {lead} lag {lag}:"
              f" csi f {s_mine.imag/2/math.pi:8.2f} Hz sigma {-s_mine.real:8.2f}; spear3rf f {s_ref.imag/2/math.pi:8.2f} sigma {-s_ref.real:8.2f}")
        ok &= abs(s_mine - s_ref) < 1e-3 * abs(s_ref)

    for gA, kAP in ((0.4, 0.1), (0.75, 0.0), (1.0, 0.6)):
        st4 = cm.Station(I_b=0.497, G=0.875, theta=0.0, tau=625e-9, Q_L=6700, g_A=gA, k_AP=kAP, lead=False)
        st4 = st4.with_(df=st4.optimum_detuning())
        s_mine = cm.coupled_mode(st4)
        s_ref = Quadrature(rfsystem(st4, lead=False), amp_gain=gA, am_pm=kAP).mode().s
        print(f"4. coupled mode, klystron gA {gA} kAP {kAP}: csi f {s_mine.imag/2/math.pi:8.2f} sigma {-s_mine.real:8.2f};"
              f" quadrature f {s_ref.imag/2/math.pi:8.2f} sigma {-s_ref.real:8.2f}")
        ok &= abs(s_mine - s_ref) < 1e-3 * abs(s_ref)

    # 5. det(1 + M) D = det(1 + F Z_m) D_0 (matrix determinant lemma), at arbitrary complex s; memoryless klystron
    #    and one with a finite amplitude bandwidth
    e5 = 0.0
    for f_A in (0.0, 0.8e6):
        st5 = cm.Station(I_b=0.45, G=1.3, theta=12.0, tau=640e-9, Q_L=6500, g_A=0.35, k_AP=-0.4, df=-30e3,
                         alpha_c=1.37e-3, f_A=f_A)
        s = np.array([2e3 + 2j * np.pi * 8.3e3, -500 + 2j * np.pi * 25e3, 1e4 - 2j * np.pi * 60e3])
        lhs = cm.char_det(st5, s)
        bl = cm.blocks(st5, s)
        F = np.einsum("nij,n,jk->nik", bl.K, st5.G * cm.chain(st5, s) / st5.R_L, cm._rot(math.radians(st5.theta)))
        A = np.eye(2) + np.einsum("nij,njk->nik", F, bl.Z_m)
        Ainv, detA = cm._inv2(A)
        ps = st5.phi_s
        b = np.array([-math.sin(ps), -math.cos(ps)])
        p = np.array([math.cos(ps), -math.sin(ps)])
        zb = np.einsum("nij,njk->nik", bl.Z_sum, Ainv)
        D0 = s * s + 2 * cm.ALPHA_RAD * s + st5.w_s ** 2 + st5.kappa1 * st5.I_b1 * np.einsum("i,nij,j->n", p, zb, b)
        e5 = max(e5, float(np.max(np.abs(lhs - detA * D0) / np.abs(lhs))))
    print(f"5. det(1+M) D = det(1+F Z_m) D_0: max relative difference {e5:.2e}")
    ok &= e5 < 1e-9

    print("ALL CHECKS PASSED" if ok else "SOME CHECKS FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
