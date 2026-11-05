"""Numbers and pgfplots data for Doc P: the dipole mode as a driven, damped oscillator.

Covers sec:robinson-picture, sec:robinson-noise, the measured-line paragraph of
sec:robinson-legacy and the two-quadrature form of Appendix C.  Writes
Designs/tex/docP-rf-physics/data/robinson_noise_vs_gain.dat (absolute values per unit source
spectral density, and the ratios plotted in fig:robinson-noise) and prints every value quoted
in the text.  Section 6b, the beam motion that Doc P quotes, masks the 60 Hz harmonics in the
line fit and adds the discrete harmonics near f_coh, with the analysis of the direct-loop study
(Studies/optLLRF/code/python/optllrf.py).  The time-domain noise check takes about two minutes;
skip it with --no-td.
"""
import json
import math
import sys
from dataclasses import replace
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "spear3rf" / "src"))
from spear3rf import live  # noqa: E402
from spear3rf.params import Loop  # noqa: E402
from spear3rf.quadrature import Quadrature, frequency_grid, sidebands  # noqa: E402
from spear3rf.stability import char_fn, count_rhp_zeros, static_ratio  # noqa: E402
from spear3rf.system import RFSystem  # noqa: E402
from spear3rf.timedomain import simulate, simulate_noise  # noqa: E402

OUT = ROOT / "Designs" / "tex" / "docP-rf-physics" / "data"
DATA = ROOT / "spear3rf" / "data"
TAU_LEGACY = 625e-9
F_AMP = 2.5e6
LAG_ZERO, LAG_POLE = 1 / (2 * math.pi * 499 * 0.1e-6), 1 / (2 * math.pi * (499 + 5620) * 0.1e-6)
F_I = 1.0e3                 # effective integral corner that reproduces the measured damping (tab:robinson-today)
KLY = (0.40, 0.10)          # klystron amplitude gain and AM/PM from normal-operation records (sec:robinson-open)
ENBW = 1.065                # noise bandwidth of the analyzer's resolution filter, in units of the RBW
LINE_2021 = (8.93e3, 11.1)  # synchrotron line of 2021 at 500 mA, f and Q [R4]
SOURCES = ("klystron_PM", "klystron_AM", "measurement_PM", "measurement_AM")
_trapz = getattr(np, "trapezoid", None) or np.trapz


def p_loop(g_db, phase=0.0, tau=TAU_LEGACY, **kw):
    return Loop(gain=10 ** (g_db / 20), phase_deg=phase, delay=tau, f_amp_hz=F_AMP, **kw)


def lag(gain):
    return dict(gi=gain, fi_hz=LAG_ZERO - LAG_POLE, f_leak_hz=LAG_POLE)


def write(name, header, rows):
    with open(OUT / name, "w") as f:
        f.write(" ".join(header) + "\n")
        for r in rows:
            f.write(" ".join("nan" if not math.isfinite(v) else f"{v:.6g}" for v in r) + "\n")
    print("wrote", OUT / name)


def variances(q, f=None):
    """Per unit white source spectral density: {source: (<dphi^2>, <(dE/E0)^2>)}."""
    f = frequency_grid() if f is None else f
    r = q.response(f)
    ring = q.system.ring
    w2 = (2 * np.pi * f / (ring.alpha_c * ring.w_rf)) ** 2
    out = {}
    for src in SOURCES:
        y = np.abs(r.chi * r.drive[src]) ** 2
        out[src] = (float(_trapz(y, f)), float(_trapz(y * w2, f)))
    return out


s0 = RFSystem()
ring = s0.ring
acw = ring.alpha_c * ring.w_rf
cot = 1 / math.tan(s0.phi_s)
print("== 1. conversions (500 mA)")
print(f"  phi_s {math.degrees(s0.phi_s):.2f} deg, cot {cot:.4f}: 0.1% amplitude = {math.degrees(1e-3 * cot):.4f} deg of phase")
print(f"  energy per radian at 8.8 kHz {2 * math.pi * 8.8e3 / acw:.4f};  timing per 0.1 deg {math.radians(0.1) / ring.w_rf * 1e12:.3f} ps")
print(f"  kappa {s0.K:.0f}, f_s {s0.w_s / 2 / math.pi:.1f} Hz, alpha_rad {ring.alpha_rad:.1f}/s")

print("== 2. two-quadrature form against the characteristic equation and the time domain")
rng = np.random.default_rng(1)
worst = 0.0
for lp in (Loop(), p_loop(0), p_loop(15, 20.0), p_loop(0, **lag(1.0)), p_loop(0, gi=1.0, fi_hz=F_I)):
    sy = s0.with_(loop=lp)
    q = Quadrature(sy)
    for _ in range(6):
        s = complex(rng.uniform(-3e3, 3e3), rng.uniform(-8e4, 8e4))
        worst = max(worst, abs(complex(q.char_fn(s)) / complex(char_fn(sy, s)) - 1))
print(f"  linear klystron: largest relative difference of D0 from eq rob-char {worst:.1e}")
for G, ag, kp in ((0.875, 0.75, 0.0), (0.875, 1.0, 0.6), (1.0, 0.40, 0.0), (1.3, 0.40, 0.0)):
    sy = s0.with_(I0=0.497, loop=p_loop(20 * math.log10(G), **lag(G)))
    m = Quadrature(sy, ag, kp).mode()
    t = simulate(sy, t_end=6e-3, skip=0.5e-3, klystron_amp_gain=ag, klystron_am_pm=kp).fit
    print(f"  497 mA lag network G {G:5.3f} g_A {ag:4.2f} k_AP {kp:3.1f}: two-quadrature f {m.frequency:6.0f} Hz"
          f" sigma {m.damping:6.0f}/s | time domain f {t.frequency:6.0f} Hz sigma {t.damping:6.0f}/s")
f0 = np.array([1e-4])
r_open = Quadrature(s0).response(f0)
r_int = Quadrature(s0.with_(loop=p_loop(0, gi=1.0, fi_hz=F_I))).response(f0)
print(f"  static checks: no feedback, klystron phase step -> beam {(r_open.chi * r_open.drive['klystron_PM'])[0].real:+.6f};"
      f" integral path, reference step -> beam {-(r_int.chi * r_int.drive['measurement_PM'])[0].real:+.6f},"
      f" klystron step -> {abs((r_int.chi * r_int.drive['klystron_PM'])[0]):.1e}")

print("== 3. beam response w_s^2/D0 at 500 mA (eqs rob-response, rob-var)")
F = frequency_grid()
for tag, lp in (("no feedback", Loop()), ("P 0 dB", p_loop(0)), ("P 6 dB", p_loop(6)), ("P 15 dB", p_loop(15)),
                ("P 0 dB + f_i 1 kHz", p_loop(0, gi=1.0, fi_hz=F_I))):
    q = Quadrature(s0.with_(loop=lp))
    m = q.mode()
    sig, wc, ws = m.damping, m.s.imag, s0.w_s
    chi = np.abs(q.response(F).chi)
    var = _trapz(chi ** 2, F)
    form = ws ** 4 / (8 * wc ** 2 * sig)
    peak2 = m.Q * (ws / wc) ** 2
    print(f"  {tag:20s} f_coh {wc / 2 / np.pi:6.0f} Hz sigma {sig:5.0f}/s Q {m.Q:5.1f}: |chi|max {chi.max():6.2f}"
          f" (Q (w_s/w_coh)^2 {peak2:6.2f}); integral/eq rob-var {var / form:.3f}; noise bandwidth {var / chi.max() ** 2:5.0f} Hz"
          f" (sigma/2 {sig / 2:5.0f}); chi(0) {chi[0]:.3f}, 1/static {1 / static_ratio(s0.with_(loop=lp)):.3f}")

print("== 4. drive at f_coh, 500 mA (tab:robinson-drive): closed/open for klystron noise; measurement noise vs gap")
q_open = Quadrature(s0)
m_open = q_open.mode()
ro = q_open.response(np.array([m_open.frequency]))
print(f"  no feedback: klystron AM drives {abs(ro.drive['klystron_AM'][0]) ** 2:.3f}, PM {abs(ro.drive['klystron_PM'][0]) ** 2:.3f}"
      f" per unit spectral density -> AM/PM {abs(ro.drive['klystron_AM'][0]) ** 2 / abs(ro.drive['klystron_PM'][0]) ** 2:.1f}")
for gdb in (0, 6, 15):
    q = Quadrature(s0.with_(loop=p_loop(gdb)))
    fc = q.mode().frequency
    rc, rop = q.response(np.array([fc, -fc])), q_open.response(np.array([fc]))
    L = rc.open_loop
    scalar = np.mean(1 / np.abs(1 + L) ** 2)
    tt = np.mean(np.abs(L / (1 + L)) ** 2)
    pm = abs(rc.drive["klystron_PM"][0]) ** 2 / abs(rop.drive["klystron_PM"][0]) ** 2
    am = abs(rc.drive["klystron_AM"][0]) ** 2 / abs(rop.drive["klystron_AM"][0]) ** 2
    mpm = abs(rc.drive["measurement_PM"][0]) ** 2
    mam = abs(rc.drive["measurement_AM"][0]) ** 2 / cot ** 2
    print(f"  {gdb:2d} dB: f_coh {fc / 1e3:5.2f} kHz; 1/|1+G_OL|^2 at +/-f {1 / abs(1 + L[0]) ** 2:.3f}/{1 / abs(1 + L[1]) ** 2:.3f}"
          f" mean {scalar:.3f}; klystron PM {pm:.3f}, AM {am:.3f};  |T|^2 mean {tt:.3f}, measurement PM {mpm:.3f}, AM {mam:.3f}")

print("== 5. jitter per unit white source spectral density versus gain (fig:robinson-noise)")
base_lin = variances(q_open, F)
base_kly = variances(Quadrature(s0, *KLY), F)
for src in SOURCES[:2]:
    print(f"  no feedback, {src}: <dphi^2> {base_lin[src][0]:.4g} Hz, <(dE/E)^2> {base_lin[src][1]:.4g} Hz")
rows, table = [], {}
for gdb in np.arange(-10.0, 16.01, 0.5):
    sy = s0.with_(loop=p_loop(gdb))
    if count_rhp_zeros(lambda z: 1.0 + sy.open_loop(z)):
        rows.append([gdb] + [float("nan")] * 14)
        continue
    q, qk = Quadrature(sy), Quadrature(sy, *KLY)
    m, mk = q.mode(), qk.mode()
    v, vk = variances(q, F), variances(qk, F)
    rows.append([gdb, m.frequency, m.damping]
                + [v[s][0] for s in SOURCES] + [v[s][1] for s in SOURCES]
                + [mk.damping, vk["klystron_PM"][0], vk["klystron_AM"][0], vk["klystron_PM"][1]])
    table[gdb] = (m, v, mk, vk)
# relative columns for the figure: klystron sources against no feedback, measurement sources against 0 dB
ref0 = table[0.0][1]
for row in rows:
    if not math.isfinite(row[1]):
        row += [float("nan")] * 8
        continue
    for k, src in enumerate(SOURCES):
        ref = base_lin[src] if src.startswith("klystron") else ref0[src]
        row.append(row[3 + k] / ref[0])
    for k, src in enumerate(SOURCES):
        ref = base_lin[src] if src.startswith("klystron") else ref0[src]
        row.append(row[7 + k] / ref[1])
write("robinson_noise_vs_gain.dat",
      ["G", "f_coh", "sigma", "t_kpm", "t_kam", "t_mpm", "t_mam", "e_kpm", "e_kam", "e_mpm", "e_mam",
       "sigma_kly", "t_kpm_kly", "t_kam_kly", "e_kpm_kly",
       "rt_kpm", "rt_kam", "rt_mpm", "rt_mam", "re_kpm", "re_kam", "re_mpm", "re_mam"], rows)
print("  ratios: klystron sources to no feedback, measurement sources to 0 dB (timing / energy)")
for gdb in (-6.0, 0.0, 3.0, 6.0, 10.0, 15.0):
    m, v, mk, vk = table[gdb]
    txt = f"  {gdb:5.1f} dB f {m.frequency:5.0f} sigma {m.damping:5.0f}:"
    for src in SOURCES:
        ref = base_lin[src] if src.startswith("klystron") else table[0.0][1][src]
        txt += f"  {src[0]}{src.split('_')[1]} {v[src][0] / ref[0]:5.2f}/{v[src][1] / ref[1]:5.2f}"
    txt += (f" | measured klystron: sigma {mk.damping:5.0f}, kPM {vk['klystron_PM'][0] / base_kly['klystron_PM'][0]:4.2f}"
            f"/{vk['klystron_PM'][1] / base_kly['klystron_PM'][1]:4.2f}, kAM {vk['klystron_AM'][0] / base_kly['klystron_AM'][0]:4.2f}"
            f"/{vk['klystron_AM'][1] / base_kly['klystron_AM'][1]:4.2f}, mPM {vk['measurement_PM'][0] / table[0.0][3]['measurement_PM'][0]:5.2f}")
    print(txt)
for gdb in (0.0, 6.0, 15.0):
    m, v = table[gdb][:2]
    for src in SOURCES:
        q = Quadrature(s0.with_(loop=p_loop(gdb)))
        h2 = abs(q.response(np.array([m.frequency])).drive[src][0]) ** 2
        proxy = s0.w_s ** 4 * h2 / (8 * m.s.imag ** 2 * m.damping)
        if v[src][0] > 0:
            print(f"  {gdb:4.0f} dB {src:15s}: resonant estimate / integral {proxy / v[src][0]:.3f}")

print("== 6. the measured line, 8 Oct 2026 15:35 [R40] (sec:robinson-legacy)")
d = json.load(open(DATA / "spectra" / "FSW_cavA_matrix_20261008T153523.json", encoding="utf-8"))
fits = d["analysis"]["robinson"]
rbw = float(d["setups"]["robinson"]["rbw_Hz"])
st = live.analyze(live.Snapshot.load(DATA / "snapshots" / "SRF1_20261008T153755.json"))
f_line = 0.5 * (fits["upper"]["f_Hz"] + fits["lower"]["f_Hz"])
sig_line = 0.5 * (fits["upper"]["sigma"] + fits["lower"]["sigma"])
areas, floors = {}, {}
for side in ("upper", "lower"):
    q_ = fits[side]
    a = 10 ** (q_["peak_dBc"] / 10) - 10 ** (q_["floor_dBc"] / 10)
    areas[side] = math.pi * q_["hwhm_Hz"] * a / (rbw * ENBW)
    floors[side] = 10 ** (q_["floor_dBc"] / 10) / (rbw * ENBW)
    print(f"  {side}: f {q_['f_Hz']:.0f} Hz sigma {q_['sigma']:.0f}/s Q {q_['Q']:.1f}; line {10 * math.log10(areas[side]):.1f} dBc,"
          f" floor {10 * math.log10(floors[side]):.1f} dBc/Hz")
sy_line = st.to_system()
ws_line = sy_line.w_s
print(f"  operating point {st.I0 * 1e3:.0f} mA: f_s {ws_line / 2 / np.pi:.0f} Hz; line f {f_line:.0f} Hz sigma {sig_line:.0f}/s"
      f" Q {math.pi * f_line / sig_line:.1f}: |chi|max {math.pi * f_line / sig_line * (ws_line / (2 * np.pi * f_line)) ** 2:.1f},"
      f" noise bandwidth {sig_line / 2:.0f} Hz")
lp_a = st.legacy_loop(delay=TAU_LEGACY, gi=1.0, fi_hz=F_I)
lp_b = st.legacy_loop(delay=TAU_LEGACY)
lp_b = replace(lp_b, **lag(lp_b.gain))
res = []
for tag, q in (("effective integral path (tab:robinson-today)", Quadrature(st.to_system(loop=lp_a))),
               ("lag network, klystron g_A 0.40, k_AP 0.10", Quadrature(st.to_system(loop=lp_b), *KLY))):
    m = q.mode()
    rr = q.response(np.array([fits["upper"]["f_Hz"], fits["lower"]["f_Hz"]]))
    gu, _ = sidebands(rr.beam_to_probe[:1])
    _, gl = sidebands(rr.beam_to_probe[1:])
    va = abs(q.V_k0[q.probe])
    var = {side: 2 * va ** 2 * areas[side] / g for side, g in (("upper", gu[0]), ("lower", gl[0]))}
    vm = 0.5 * (var["upper"] + var["lower"])
    dphi = math.sqrt(vm)
    res.append(dphi)
    print(f"  model: {tag}: f {m.frequency:.0f} Hz sigma {m.damping:.0f}/s; |Z_b,A| upper/lower"
          f" {math.sqrt(gu[0]) / sy_line.I_b1 / 1e3:.0f}/{math.sqrt(gl[0]) / sy_line.I_b1 / 1e3:.0f} kOhm"
          f" (V_A {va / 1e3:.0f} kV); predicted upper/lower {10 * math.log10(gu[0] / gl[0]):+.2f} dB,"
          f" measured {10 * math.log10(areas['upper'] / areas['lower']):+.2f} dB")
    print(f"     dphi_rms upper {math.degrees(math.sqrt(var['upper'])):.3f}, lower {math.degrees(math.sqrt(var['lower'])):.3f},"
          f" mean {math.degrees(dphi):.3f} deg = {dphi / ring.w_rf * 1e12:.2f} ps;"
          f" dE/E rms {2 * np.pi * f_line / acw * dphi:.2e};"
          f" drive S_n {8 * (2 * np.pi * f_line) ** 2 * sig_line * vm / ws_line ** 4:.2e} rad^2/Hz")
sn_floor = (floors["upper"] + floors["lower"]) / (2 * math.sin(sy_line.phi_s) ** 2)
print(f"  floor as uncorrelated gap noise: S_n {sn_floor:.2e} rad^2/Hz")
L3 = d["analysis"]["lines_dBc_3Hz"]
tot = sum(10 ** (v / 10) for v in L3.values())
big = sorted(L3.items(), key=lambda t: -t[1])[:4]
ph_lines = math.sqrt(tot)
print(f"  line harmonics 60-1080 Hz: {10 * math.log10(tot):.1f} dBc in total (largest {big});"
      f" as phase {math.degrees(ph_lines):.3f} deg ({ph_lines / ring.w_rf * 1e12:.2f} ps),"
      f" as amplitude {100 * ph_lines:.2f}% -> {math.degrees(ph_lines * cot):.3f} deg at the beam")
lo = math.hypot(min(res), ph_lines * cot)
hi = math.hypot(max(res), ph_lines)
print(f"  timing jitter, resonance and lines together: {math.degrees(lo):.2f}-{math.degrees(hi):.2f} deg"
      f" ({lo / ring.w_rf * 1e12:.1f}-{hi / ring.w_rf * 1e12:.1f} ps)")
f21, q21 = LINE_2021
sig21 = math.pi * f21 / q21
sig26 = 0.5 * (1160.0 + 1086.0)
f26 = 0.5 * (8790.0 + 8826.0)
print(f"  2021 line sigma {sig21:.0f}/s at {f21:.0f} Hz vs 2026 {sig26:.0f}/s at {f26:.0f} Hz: resonant variance"
      f" for the same drive x{(sig21 * f21 ** 2) / (sig26 * f26 ** 2):.2f}")

print("== 6b. the same capture with the 60 Hz harmonics masked, plus the discrete harmonics (Studies/optLLRF)")
sys.path.insert(0, str(ROOT / "Studies" / "optLLRF" / "code" / "python"))
import optllrf  # noqa: E402

cap = optllrf.analyze_capture(DATA / "spectra" / "FSW_cavA_matrix_20261008T153523.json")
fu, fw = cap["fits"][1], cap["fits"][-1]
print(f"  broadband line: f {fu['f']:.0f}/{fw['f']:.0f} Hz, sigma {fu['sigma']:.0f}/{fw['sigma']:.0f}/s,"
      f" {fu['area_dbc']:.1f}/{fw['area_dbc']:.1f} dBc (upper/lower; upper - lower {fu['area_dbc'] - fw['area_dbc']:+.1f} dB),"
      f" floor {fu['floor_dbc_hz']:.1f}/{fw['floor_dbc_hz']:.1f} dBc/Hz")
tot6b = []
for mname, mv in cap["models"].items():
    dom = [ln for ln in mv["lines"] if ln["beam_dominated"]]
    near = [ln for ln in dom if abs(abs(ln["offset"]) - cap["f_coh"]) < 1000.0]
    six = [ln for ln in near if round(abs(ln["offset"]) / 60.0) % 6 == 0]
    share = {k: sum(math.radians(ln["dphi_deg"]) ** 2 for ln in grp) / mv["var_lines"] for k, grp in
             (("near", near), ("six", six))}
    tot6b.append(math.sqrt(mv["var_total"]))
    print(f"  {mname}: beam phase broadband {mv['dphi_broadband_deg']:.3f}, beam-dominated harmonics 2-10 kHz"
          f" {mv['dphi_lines_deg']:.3f}, together {mv['dphi_total_deg']:.3f} deg ({mv['timing_total_ps']:.2f} ps);"
          f" dE/E {mv['dE_total']:.2e}; broadband drive S_n {mv['S_n_broadband']:.2e} against {mv['S_n_floor']:.2e}"
          f" rad^2/Hz from the floor; harmonics within 1 kHz of f_coh carry {100 * share['near']:.0f}% of the"
          f" harmonic variance, the 6-pulse ones {100 * share['six']:.0f}%")
lo = math.hypot(min(tot6b), ph_lines * cot)
hi = math.hypot(max(tot6b), ph_lines)
print(f"  timing jitter, line and harmonics near f_coh with the harmonics 60-1080 Hz: {math.degrees(lo):.2f}-"
      f"{math.degrees(hi):.2f} deg ({lo / ring.w_rf * 1e12:.1f}-{hi / ring.w_rf * 1e12:.1f} ps)")


def chi2_line(f_l, f0, sig):
    """|chi|^2 at a line f_l for a mode at f0 with damping sig, up to the common factor w_s^4."""
    w, wc = 2 * np.pi * f_l, 2 * np.pi * f0
    return 1.0 / ((wc ** 2 + sig ** 2 - w ** 2) ** 2 + 4 * sig ** 2 * w ** 2)


for f_l in (8640.0, 9000.0):
    r = [chi2_line(f_l, f0, s) / chi2_line(f_l, f21, sig21) for f0, s in ((8790.0, 1160.0), (8830.0, 1086.0))]
    print(f"  harmonic at {f_l:.0f} Hz: variance driven in 2026 (13:31, 15:35) against 2021, same drive:"
          f" x{min(r):.1f}-{max(r):.1f}")

if "--no-td" not in sys.argv:
    print("== 7. time-domain noise check, 500 mA, white noise at the klystron output (4 seeds x 0.25 s)")
    psd = 1e-10
    td = {}
    for tag, lp in (("no feedback", Loop()), ("P 0 dB", p_loop(0)), ("P 6 dB", p_loop(6))):
        sy = s0.with_(loop=lp)
        v = variances(Quadrature(sy), F)
        for which in ("PM", "AM"):
            vals = [simulate_noise(sy, which, psd, seed=k)[0] for k in (1, 2, 3, 4)]
            mean, err = float(np.mean(vals)), float(np.std(vals) / 2)
            fd = psd * v[f"klystron_{which}"][0]
            td[(tag, which)] = (fd, mean, err)
            print(f"  {tag:12s} {which}: frequency domain {fd:.3e}, time domain {mean:.3e} +/- {err:.1e} ({mean / fd:.3f})")
    for which in ("PM", "AM"):
        for tag in ("P 0 dB", "P 6 dB"):
            a, b = td[(tag, which)], td[("no feedback", which)]
            print(f"  {which} {tag} / no feedback: frequency domain {a[0] / b[0]:.2f}, time domain {a[1] / b[1]:.2f}"
                  f" +/- {a[1] / b[1] * math.hypot(a[2] / a[1], b[2] / b[1]):.2f}")
