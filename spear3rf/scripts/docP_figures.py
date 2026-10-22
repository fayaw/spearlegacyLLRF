"""Numbers and pgfplots data for Doc P (synchrotron damping section and the U0 update).

Writes Designs/tex/docP-rf-physics/data/*.dat and prints every value quoted in the text.
"""
import math
import sys
from dataclasses import replace
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "spear3rf" / "src"))
from spear3rf import live  # noqa: E402
from spear3rf.params import Loop, Ring  # noqa: E402
from spear3rf.stability import beam_mode, count_rhp_zeros, loop_margins, sideband_estimate, static_ratio  # noqa: E402
from spear3rf.system import RFSystem  # noqa: E402
from spear3rf.timedomain import simulate  # noqa: E402

OUT = ROOT / "Designs" / "tex" / "docP-rf-physics" / "data"
OUT.mkdir(parents=True, exist_ok=True)
TAU_LEGACY = 625e-9          # legacy total loop delay (MeasDirCls, Oct 2026)
F_AMP = 2.5e6                # drive amplifier + klystron one-pole bandwidth
SNAP = ROOT / "spear3rf" / "data" / "snapshots" / "SRF1_20261006T145238.json"


def p_loop(g_db, phase=0.0, tau=TAU_LEGACY, **kw):
    return Loop(gain=10 ** (g_db / 20), phase_deg=phase, delay=tau, f_amp_hz=F_AMP, **kw)


def write(name, header, rows):
    with open(OUT / name, "w") as f:
        f.write(" ".join(header) + "\n")
        for r in rows:
            f.write(" ".join("nan" if (isinstance(v, float) and not math.isfinite(v)) else f"{v:.6g}" for v in r) + "\n")
    print("wrote", OUT / name)


s0 = RFSystem()
r, c = s0.ring, s0.cavity
print("== ring / cavity")
print(f"U0 {r.U0_eV/1e6:.3f} MeV  phi_s {math.degrees(s0.phi_s):.2f} deg  cos {math.cos(s0.phi_s):.4f}  sin {math.sin(s0.phi_s):.4f}")
print(f"f_s {s0.w_s/2/math.pi:.1f} Hz  nu_s {s0.w_s/r.w_rev:.5f}  J_s {r.J_s:.4f}  alpha_rad {r.alpha_rad:.1f}/s  tau_s {1e3/r.alpha_rad:.3f} ms")
print(f"bare lattice: tau_s {1e3*2*r.energy_eV*r.T_rev/(r.J_s_dipole*r.U0_dipole_eV):.3f} ms")
print(f"Rs {c.Rs/1e6:.4f} MOhm  RL {c.RL/1e3:.1f} kOhm  QL {c.QL:.0f}  half-bw {s0.w_half/2/math.pi:.1f} Hz  K {s0.K:.1f}")

print("== beam loading, 500 mA")
a = s0.I_b1 * c.Rs * math.cos(s0.phi_s) / s0.V_cav
b = s0.I_b1 * c.Rs * math.sin(s0.phi_s) / s0.V_cav
print(f"tan psi0 {-b:.3f}  tan psiL {-b/(1+c.beta):.4f}  psiL {math.degrees(math.atan(-b/(1+c.beta))):.2f}")
print(f"df_opt {s0.optimum_detuning_hz():.1f} Hz  slope {s0.optimum_detuning_hz()/500:.2f} Hz/mA")
print(f"a {a:.4f}  b {b:.4f}  P_wall {s0.P_wall/1e3:.2f} kW  P_beam/cav {s0.P_beam_per_cav/1e3:.2f} kW")
pgen = s0.P_wall + s0.P_beam_per_cav
g2 = float(s0.reflection()[0])
print(f"P_gen/cav {pgen/1e3:.2f} kW  total {4*pgen/1e3:.1f} kW  headroom {100*(1-4*pgen/1.5e6):.1f} %")
print(f"|G|^2 floor {100*g2:.2f} %  P_fwd/cav {pgen/(1-g2)/1e3:.1f} kW  total {4*pgen/(1-g2)/1e3:.1f} kW")
print(f"beta_opt {1+a:.3f}  I_match {0.5*(c.beta-1)/a*1e3:.0f} mA  Vb,res {s0.I_b1*c.RL/1e6:.3f} MV")
I_g = s0.V_cav / c.RL + s0.I_b1 * math.cos(s0.phi_s)
print(f"phasor: V/RL {s0.V_cav/c.RL:.4f} A  Ib1 cos {s0.I_b1*math.cos(s0.phi_s):.4f}  Ig {I_g:.4f} A  "
      f"I_t = {s0.V_cav/c.RL:.4f} + j{s0.I_b1*math.sin(s0.phi_s):.4f}")


def gamma2(I_mA, df_hz):
    s = s0.with_(I0=I_mA / 1e3, detuning_hz=df_hz)
    p = s.P_wall + s.P_beam_per_cav
    g = float(s.reflection()[0])
    return 100 * g, p / (1 - g) / 1e3, p / 1e3


dfo = s0.optimum_detuning_hz()
print("== transient table (detuning error, |G|^2 %, P_fwd kW/cav, P_absorbed kW/cav)")
for tag, I, df in (("steady", 500, dfo), ("top-off +5 mA", 505, dfo), ("circumference 4 kHz", 500, dfo + 4e3),
                   ("fill, tuner on res", 500, 0.0), ("beam loss, still detuned", 0, dfo), ("no beam on res", 0, 0.0)):
    print(f"  {tag:28s} {gamma2(I, df)}")
print(f"  top-off detuning step {dfo*5/500:.0f} Hz")

print("== Robinson, 500 mA")
for tag, lp in (("open", Loop()), ("G 0 dB", p_loop(0)), ("G 6 dB", p_loop(6)), ("G 10 dB", p_loop(10)),
                ("G 15 dB", p_loop(15))):
    s = s0.with_(loop=lp)
    m, e = beam_mode(s), sideband_estimate(s)
    print(f"  {tag:8s} f {m.frequency:7.0f} Hz  sigma {m.damping:7.0f}/s  Q {m.Q:5.1f}  |  first-order f {e.frequency:7.0f}"
          f"  sigma {e.damping:7.0f}  static {static_ratio(s):.3f}  mu=-1 growth {r.alpha_rad - beam_mode(s, -1).damping:+.1f}/s")

lo, hi = 0.5, 2.0
for _ in range(60):
    mid = 0.5 * (lo + hi)
    lo, hi = (mid, hi) if static_ratio(s0.with_(I0=mid)) > 0 else (lo, mid)
print(f"open-loop static limit at optimum detuning {lo:.3f} A")

print("== maximum P gain for 45 deg phase margin at 500 mA (ideal phase, 2.5 MHz amp pole)")
rows = []
for tau in (270e-9, 500e-9, TAU_LEGACY, 700e-9, 870e-9):   # 870 ns: LLRF9 estimate (625 - 30 + 270)
    lo, hi = 0.5, 50.0
    for _ in range(50):
        mid = math.sqrt(lo * hi)
        pm = loop_margins(s0.with_(loop=Loop(gain=mid, delay=tau, f_amp_hz=F_AMP)), n=200_001).phase_margin_deg
        lo, hi = (mid, hi) if pm > 45 else (lo, mid)
    s = s0.with_(loop=Loop(gain=lo, delay=tau, f_amp_hz=F_AMP))
    mg = loop_margins(s, n=200_001)
    m = beam_mode(s)
    gamp = math.pi / (4 * s0.w_half * tau)
    print(f"  tau {tau*1e9:4.0f} ns  G_max {20*math.log10(lo):5.1f} dB ({lo:.2f})  Gamp pi/(4 w tau) {20*math.log10(gamp):5.1f} dB"
          f"  f_c {max(abs(x) for x in mg.crossovers_hz)/1e3:5.0f} kHz  GM {mg.gain_margin_db:4.1f} dB  sigma {m.damping:5.0f}/s")
    rows.append((tau * 1e9, 20 * math.log10(lo), m.damping))

print("== Robinson vs current (tuner tracking optimum detuning)")
rows = []
for I in np.concatenate([np.arange(10, 100, 10), np.arange(100, 801, 25)]):
    s = s0.with_(I0=I / 1e3)
    row = [I]
    for lp in (Loop(), p_loop(0), p_loop(15)):
        m = beam_mode(s.with_(loop=lp))
        row += [m.frequency / 1e3, m.damping]
    row += [s.w_s / 2 / math.pi / 1e3, r.alpha_rad]
    rows.append(row)
write("robinson_vs_current.dat",
      ["I", "f_open", "s_open", "f_g0", "s_g0", "f_g15", "s_g15", "f_inc", "a_rad"], rows)
for row in rows:
    if row[0] in (100, 300, 500, 700, 800):
        print("  ", " ".join(f"{v:8.2f}" for v in row))

print("== Robinson vs gain and phase error at 500 mA (nan where the RF loop itself is unstable)")
phases = (-30, -15, 0, 15, 30)
crit = {}
for ph in phases:
    gm = loop_margins(s0.with_(loop=p_loop(0, ph)), n=200_001).gain_margin_db
    crit[ph] = gm
    print(f"  phase {ph:+3d}: RF loop unstable above {gm:.1f} dB")
rows = []
for g_db in np.arange(-12, 20.01, 1.0):
    row = [g_db]
    for ph in phases:
        row.append(beam_mode(s0.with_(loop=p_loop(g_db, ph))).damping if g_db < crit[ph] else float("nan"))
    rows.append(row)
write("robinson_vs_gain.dat", ["G"] + [f"p{p:+d}".replace("+", "p").replace("-", "m") for p in phases], rows)
for row in rows:
    if row[0] in (-6, 0, 6, 10, 15):
        print("  ", " ".join(f"{v:8.0f}" for v in row))

print("== integral path (P 0 dB, legacy delay), 500 mA: damping; |1+L| at 360/720 Hz")
for fi in (0.0, 300.0, 1e3, 2e3, 3e3, 10e3):
    out = []
    for rot in (0.0, 45.0, 90.0):
        lp = p_loop(0, gi=1.0 if fi else 0.0, fi_hz=fi, phase_i_deg=rot)
        s = s0.with_(loop=lp)
        out.append(beam_mode(s).damping)
    rej = [20 * math.log10(abs(complex(s0.with_(loop=p_loop(0, gi=1.0 if fi else 0.0, fi_hz=fi)).open_loop(2j * math.pi * f)) + 1))
           for f in (-720, -360, 360, 720)]
    print(f"  f_i {fi/1e3:4.1f} kHz  sigma (I-path rot 0/+45/+90) {out[0]:7.0f} {out[1]:7.0f} {out[2]:7.0f}"
          f"  rejection {np.round(rej, 1)}")

print("== shared-phase 3 kHz integral path: scan of the common loop phase (P 0 dB, legacy delay, 500 mA)")
for ph in range(-90, 91, 15):
    s = s0.with_(loop=p_loop(0, ph, gi=1.0, fi_hz=3e3, phase_i_deg=ph))   # Loop.phase_i_deg is absolute
    if count_rhp_zeros(lambda z: 1.0 + s.open_loop(z)):
        print(f"  theta {ph:+4d}: RF loop unstable")
        continue
    print(f"  theta {ph:+4d}: sigma {beam_mode(s).damping:7.0f}/s")

print("== Robinson damping vs loop phase at 0 dB, optimum detuning per current (nan: RF loop unstable)")
currents = (100, 200, 300, 400, 500)
rows = []
for ph in range(-90, 91, 2):
    row = [ph]
    for I in currents:
        s = s0.with_(I0=I / 1e3, loop=p_loop(0, ph))
        row.append(float("nan") if count_rhp_zeros(lambda z: 1.0 + s.open_loop(z)) else beam_mode(s).damping)
    rows.append(row)
write("robinson_vs_phase.dat", ["theta"] + [f"s{I}" for I in currents], rows)
for row in rows:
    if row[0] in (-90, -60, -45, -30, -16, -10, 0, 10, 30, 60, 90):
        print("  ", " ".join(f"{v:8.0f}" for v in row))
for j, I in enumerate(currents, start=1):
    col = np.array([r[j] for r in rows])
    th = np.array([r[0] for r in rows])
    lo = th[(col >= 2 * r.alpha_rad)].min() if np.any(col >= 2 * r.alpha_rad) else float("nan")
    print(f"  {I} mA: sigma(0) {col[th == 0][0]:.0f}, max {np.nanmax(col):.0f} at {th[np.nanargmax(col)]:+.0f} deg, "
          f"sigma >= 2 alpha_rad for theta >= {lo:+.0f} deg, min {np.nanmin(col):.0f} at {th[np.nanargmin(col)]:+.0f} deg")

print("== live legacy operating point")
st = live.analyze(live.Snapshot.load(SNAP))
print(f"  I {st.I0*1e3:.1f} mA  V {st.V_total/1e3:.0f} kV  U0 {st.U0/1e6:.3f} MeV  beta {st.cavity.beta:.2f}  QL {st.cavity.QL:.0f}")
print(f"  phi per cav {np.round(np.degrees(st.phi), 1)}  df_phys {np.round(st.df_physics/1e3, 1)}  df_poly {np.round(st.df_poly/1e3, 1)}")
print(f"  refl % {np.round(100*st.gamma2, 2)}  vswr-beta {np.round(st.beta, 2)}  P_fwd sum {st.P_fwd.sum()/1e3:.0f} kW")
for tag, lp in (("open", Loop()), ("P-only legacy", st.legacy_loop())):
    ss = st.to_system(loop=lp)
    m = beam_mode(ss)
    print(f"  {tag:14s} f_inc {ss.w_s/2/math.pi:.0f}  f {m.frequency:.0f}  sigma {m.damping:.0f}  Q {m.Q:.1f}  alpha {ss.ring.alpha_rad:.0f}")

print("== synchrotron line, 8 October 2026: cavity-A probe spectra against the model at the paired snapshots")
F_I = 1.0e3          # effective integral corner that reproduces the measured damping (shared loop phase)
TH_497 = -5.3        # loop phase fitted at 497 mA, 2 Oct 2026, integral path in the model (scripts/analyze_measure_direct.py)
PHASE_SCALE = 1.28   # loop phase per degree of PHASE.C (2 Oct scan); a more positive setting is a lag
EFF_497 = dict(G=0.431, theta=-5.8, tau=680e-9, QL=4805.0)    # effective loop fitted at 497 mA (proportional only)
# RFP compensation networks from the RFgui loop models (compute_loop.m, rftfresponse.m); the closed- and open-loop
# measurements (scripts/analyze_measure_direct.py, analyze_old_rf_data.py) indicate that the lag network is installed
LEAD = (1 / (2 * math.pi * 301 * 560e-12), 1 / (2 * math.pi * (196 * 301 / 497) * 560e-12))
LAG_ZERO, LAG_POLE = 1 / (2 * math.pi * 499 * 0.1e-6), 1 / (2 * math.pi * (499 + 5620) * 0.1e-6)
MEAS = (("SRF1_20261008T133240.json", 8790.0, 1160.0), ("SRF1_20261008T153755.json", 8826.0, 1086.0))
for name, f_m, sig_m in MEAS:
    st = live.analyze(live.Snapshot.load(ROOT / "spear3rf" / "data" / "snapshots" / name))
    excess = st.tracking_phase(float(np.mean(st.df_poly))) - st.tracking_phase(float(np.mean(st.df_physics)))
    print(f"  {name}: I {st.I0*1e3:.1f} mA, measured f {f_m:.0f} Hz sigma {sig_m:.0f}/s Q {math.pi*f_m/sig_m:.1f}"
          f" ({sig_m/st.to_system().ring.alpha_rad:.2f} alpha_rad); tracking excess {excess:+.1f} deg")
    for th in (0.0, TH_497):
        for fi in (0.0, 0.8e3, 0.9e3, F_I):
            lp = st.legacy_loop(delay=TAU_LEGACY, phase_deg=th, gi=1.0 if fi else 0.0, fi_hz=fi, phase_i_deg=th)
            m = beam_mode(st.to_system(loop=lp))
            print(f"    theta {th:+4.1f}  f_i {fi/1e3:3.1f} kHz: f {m.frequency:5.0f} Hz ({100*(m.frequency/f_m-1):+.1f}%)"
                  f"  sigma {m.damping:5.0f}/s ({100*(m.damping/sig_m-1):+.0f}%)  Q {m.Q:4.1f}")
    th = -PHASE_SCALE * excess
    s_ref, s_tr = (beam_mode(st.to_system(loop=st.legacy_loop(delay=TAU_LEGACY, phase_deg=x, gi=1.0, fi_hz=F_I,
                                                              phase_i_deg=x))).damping for x in (0.0, th))
    print(f"    tracking excess as a lag (theta {th:+.1f}): sigma {s_ref:.0f} -> {s_tr:.0f}/s ({100*(s_tr/s_ref-1):+.0f}%)")
    base = st.to_system()
    cav = replace(base.cavity, beta=base.cavity.Q0 / EFF_497["QL"] - 1)
    fis = np.linspace(0.5e3, 3.0e3, 26)
    for th in (EFF_497["theta"], 0.0):
        sig = np.array([beam_mode(base.with_(cavity=cav, loop=replace(
            st.legacy_loop(delay=EFF_497["tau"], phase_deg=th, gi=1.0, fi_hz=fi, phase_i_deg=th),
            gain=EFF_497["G"], gi=EFF_497["G"]))).damping for fi in fis])
        print(f"    effective 497 mA loop (G {EFF_497['G']}, Q_L {EFF_497['QL']:.0f}, theta {th:+.1f}):"
              f" f_i for the measured damping {np.interp(sig_m, sig[::-1], fis[::-1])/1e3:.2f} kHz")
    m = beam_mode(base.with_(cavity=cav, loop=replace(st.legacy_loop(delay=EFF_497["tau"], phase_deg=EFF_497["theta"]),
                                                      gain=EFF_497["G"])))
    print(f"    effective 497 mA loop, proportional: f {m.frequency:.0f} Hz, sigma {m.damping:.0f}/s")
print("  INTCOMP off/on test at reduced current (G 1, theta 0, optimum detuning): sigma (1/s) and Q")
for I in (100, 200, 300, 500):
    mp = beam_mode(s0.with_(I0=I / 1e3, loop=p_loop(0)))
    mi = beam_mode(s0.with_(I0=I / 1e3, loop=p_loop(0, gi=1.0, fi_hz=F_I)))
    ml = beam_mode(s0.with_(I0=I / 1e3, loop=p_loop(0, gi=1.0, fi_hz=LAG_ZERO - LAG_POLE, f_leak_hz=LAG_POLE)))
    print(f"    {I} mA: proportional {mp.damping:5.0f} (Q {mp.Q:4.1f}, f {mp.frequency:5.0f})"
          f"  with f_i 1 kHz {mi.damping:5.0f} (Q {mi.Q:4.1f}, f {mi.frequency:5.0f})"
          f"  with the lag network {ml.damping:5.0f} (Q {ml.Q:4.1f}, f {ml.frequency:5.0f})")

print("== closed-loop response of the direct loop (fig closed-loop-tf)")
G_LOW = 0.875        # loop gain fitted at 20-22 mA with the integral path in the model, 2 Oct 2026
print(f"  RFP lead network: zero {LEAD[0]/1e3:.0f} kHz, pole {LEAD[1]/1e3:.0f} kHz;"
      f" lag network: zero {LAG_ZERO:.0f} Hz, pole {LAG_POLE:.0f} Hz, DC boost {20*math.log10(LAG_ZERO/LAG_POLE):.1f} dB"
      f" -> f_i {LAG_ZERO - LAG_POLE:.0f} Hz, leak {LAG_POLE:.0f} Hz")
LAG = dict(gi=1.0, fi_hz=LAG_ZERO - LAG_POLE, f_leak_hz=LAG_POLE)
cases = (("low", s0.with_(detuning_hz=0.0, loop=p_loop(20 * math.log10(G_LOW), lead_hz=LEAD))),
         ("lowi", s0.with_(detuning_hz=0.0, loop=p_loop(20 * math.log10(G_LOW), lead_hz=LEAD, **LAG))),
         ("p500", s0.with_(loop=p_loop(0, lead_hz=LEAD))),
         ("i500", s0.with_(loop=p_loop(0, lead_hz=LEAD, **LAG))))


def closed_loop(f_hz):
    s = 2j * math.pi * np.where(f_hz == 0, 1e-6, f_hz)
    out = {}
    for tag, sy in cases:
        L = sy.open_loop(s)
        out[tag] = L / (1 + L)
    return out


def tf_rows(f_hz):
    cols = [f_hz / 1e3]
    i0 = int(np.argmin(np.abs(f_hz)))
    for t in closed_loop(f_hz).values():
        ph = np.degrees(np.unwrap(np.angle(t)))
        cols += [20 * np.log10(np.abs(t)), ph - 360 * np.round(ph[i0] / 360)]
    return np.column_stack(cols)


hdr = ["f"] + [f"{k}_{q}" for k in ("low", "lowi", "p500", "i500") for q in ("db", "ph")]
write("closed_loop_tf.dat", hdr, tf_rows(np.arange(-300e3, 300e3 + 1, 1e3)))
write("closed_loop_tf_zoom.dat", hdr, tf_rows(np.arange(-12e3, 12e3 + 1, 50.0)))
fg = np.arange(-400e3, 400e3 + 1, 10.0)
for tag, t in closed_loop(fg).items():
    a = np.abs(t)
    k = int(np.argmax(a))
    i0 = int(np.argmin(np.abs(fg)))
    lo_ = fg[:i0][a[:i0] < a[i0] / math.sqrt(2)]
    hi_ = fg[i0:][a[i0:] < a[i0] / math.sqrt(2)]
    ph = np.degrees(np.angle(t))
    print(f"  {tag:5s} peak {a[k]:.3f} ({20*math.log10(a[k]):+.1f} dB) at {fg[k]/1e3:+6.2f} kHz; |T(0)| {a[i0]:.3f};"
          f" 3 dB below |T(0)| at {lo_.max()/1e3 if lo_.size else float('nan'):+.1f}/{hi_.min()/1e3 if hi_.size else float('nan'):+.1f} kHz;"
          f" |T| -/+8.8 kHz {a[np.argmin(np.abs(fg + 8.8e3))]:.3f}/{a[np.argmin(np.abs(fg - 8.8e3))]:.3f}"
          f" phase {ph[np.argmin(np.abs(fg + 8.8e3))]:+.1f}/{ph[np.argmin(np.abs(fg - 8.8e3))]:+.1f} deg;"
          f" -/+150 kHz {a[np.argmin(np.abs(fg + 150e3))]:.3f}/{a[np.argmin(np.abs(fg - 150e3))]:.3f}")
for tag, sy in cases:
    print(f"  {tag}: |1/(1+L)| at -720/-360/-60/+60/+360/+720 Hz (dB) "
          + " ".join(f"{-20*math.log10(abs(1 + sy.open_loop(2j*math.pi*x))):+.1f}" for x in (-720, -360, -60, 60, 360, 720)))
    mg = loop_margins(sy, n=200_001)
    print(f"    unity-gain crossings {np.round(np.array(mg.crossovers_hz)/1e3, 2)} kHz, phase margin {mg.phase_margin_deg:.0f} deg,"
          f" gain margin {mg.gain_margin_db:.1f} dB")

print("== RFgui-model lag network as the integral path (shared phase), 500 mA, lead on")
for th in (0.0, 20.0, 40.0):
    for tag, lp in (("lag network", p_loop(0, th, gi=1.0, fi_hz=LAG_ZERO - LAG_POLE, f_leak_hz=LAG_POLE, phase_i_deg=th,
                                           lead_hz=LEAD)),
                    ("f_i 1 kHz", p_loop(0, th, gi=1.0, fi_hz=F_I, phase_i_deg=th, lead_hz=LEAD)),
                    ("proportional", p_loop(0, th, lead_hz=LEAD))):
        sy = s0.with_(loop=lp)
        if count_rhp_zeros(lambda z: 1.0 + sy.open_loop(z)):
            print(f"  theta {th:+4.0f} {tag:12s}: RF loop unstable")
            continue
        m = beam_mode(sy)
        print(f"  theta {th:+4.0f} {tag:12s}: f {m.frequency:5.0f} Hz  sigma {m.damping:6.0f}/s  Q {m.Q:6.1f}")
st = live.analyze(live.Snapshot.load(ROOT / "spear3rf" / "data" / "snapshots" / MEAS[1][0]))
base = st.to_system()
lp = replace(st.legacy_loop(delay=EFF_497["tau"], phase_deg=EFF_497["theta"], gi=1.0, fi_hz=LAG_ZERO - LAG_POLE,
                            phase_i_deg=EFF_497["theta"]), gain=EFF_497["G"], gi=EFF_497["G"], f_leak_hz=LAG_POLE)
m = beam_mode(base.with_(cavity=replace(base.cavity, beta=base.cavity.Q0 / EFF_497["QL"] - 1), loop=lp))
print(f"  lag network with the effective 497 mA loop, {MEAS[1][0]}: f {m.frequency:.0f} Hz sigma {m.damping:.0f}/s"
      f" (alpha_rad {base.ring.alpha_rad:.0f}/s)")

print("== Robinson mode at 497 mA: gain setting of 2 Oct (0.9 dB) vs 8 Oct (1.3 dB), and klystron anisotropy (time domain)")
G_09 = 0.875                                  # fitted at 0.9 dB with the integral path
for gdb in (0.9, 1.3):
    G = G_09 * 10 ** ((gdb - 0.9) / 20)
    m1 = beam_mode(s0.with_(I0=0.497, loop=p_loop(20 * math.log10(G), gi=G, fi_hz=F_I)))
    ml = beam_mode(s0.with_(I0=0.497, loop=p_loop(20 * math.log10(G), gi=G, fi_hz=LAG_ZERO - LAG_POLE, f_leak_hz=LAG_POLE)))
    print(f"  COUNTS.A {gdb} dB (G {G:.3f}): f_i 1 kHz: f {m1.frequency:.0f} Hz sigma {m1.damping:.0f}/s;"
          f" lag network: f {ml.frequency:.0f} Hz sigma {ml.damping:.0f}/s")
sy = s0.with_(I0=0.497, loop=p_loop(20 * math.log10(G_09), gi=G_09, fi_hz=LAG_ZERO - LAG_POLE, f_leak_hz=LAG_POLE))
print("  lag network, G 0.875, theta 0; klystron amplitude gain s and AM/PM kappa (rad per unit relative amplitude):")
for s_amp, kap in ((1.0, 0.0), (0.75, 0.0), (0.5, 0.0), (1.0, 0.6), (1.0, 1.2), (0.6, 1.2)):
    m = simulate(sy, t_end=6e-3, skip=0.5e-3, klystron_amp_gain=s_amp, klystron_am_pm=kap).fit
    print(f"    s {s_amp:.2f} kappa {kap:.1f}: f {m.frequency:5.0f} Hz sigma {m.damping:5.0f}/s")
print("  measured in normal operation, s 0.40 (kappa 0 and 0.15), lag network, theta 0, phase-path gain G:")
for G in (1.0, 1.3):
    syg = s0.with_(I0=0.497, loop=p_loop(20 * math.log10(G), gi=G, fi_hz=LAG_ZERO - LAG_POLE, f_leak_hz=LAG_POLE))
    out = [simulate(syg, t_end=6e-3, skip=0.5e-3, klystron_amp_gain=0.40, klystron_am_pm=k).fit for k in (0.0, 0.15)]
    print(f"    G {G}: " + "; ".join(f"kappa {k}: f {m.frequency:5.0f} Hz sigma {m.damping:5.0f}/s" for k, m in zip((0.0, 0.15), out)))
