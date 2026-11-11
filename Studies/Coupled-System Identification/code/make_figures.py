"""Figures of the paper (PDF, Physical Review Accelerators and Beams sizes).

usage: python make_figures.py [names...]   (default: all)
Figures read the result files written by run_refit.py, run_identifiability.py, validate_beam_mode.py, run_crossval.py
and csi_trips.py; data-only figures read the measurement files directly.
"""
from __future__ import annotations

import json
import math
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from scipy.ndimage import median_filter  # noqa: E402

import csi_beam as cb  # noqa: E402
import csi_data as cd  # noqa: E402
import csi_fit as cf  # noqa: E402
import csi_lpm as lp  # noqa: E402
import csi_model as cm  # noqa: E402

SELECTED = "J_wl_group_ac_ktrip"      # compression per operating point, AM/PM from the trip records
ONE_KLY = "J_wl_global_ac_ktrip"      # one klystron for every current, AM/PM from the trip records
COL1, COL2 = 3.375, 7.0
plt.rcParams.update({
    "font.family": "serif", "font.serif": ["STIXGeneral", "Times New Roman", "DejaVu Serif"], "mathtext.fontset": "stix",
    "font.size": 8, "axes.labelsize": 8, "axes.titlesize": 8, "legend.fontsize": 6.5, "xtick.labelsize": 7,
    "ytick.labelsize": 7, "axes.linewidth": 0.6, "lines.linewidth": 0.9, "xtick.major.width": 0.5,
    "ytick.major.width": 0.5, "xtick.direction": "in", "ytick.direction": "in", "xtick.top": True, "ytick.right": True,
    "pdf.fonttype": 42, "savefig.bbox": "tight", "savefig.pad_inches": 0.02, "legend.frameon": False,
    "axes.grid": True, "grid.alpha": 0.25, "grid.linewidth": 0.4,
})
CMAP = plt.get_cmap("viridis")


def save(fig, name):
    cd.FIGS.mkdir(parents=True, exist_ok=True)
    fig.savefig(cd.FIGS / f"{name}.pdf")
    fig.savefig(cd.RESULTS / f"fig_{name}.png", dpi=150)
    plt.close(fig)
    print("wrote", name)


def rec_by_label(label):
    return next(r for r in cd.records() if r.label == label)


def panel(ax, s):
    ax.text(0.02, 0.97, s, transform=ax.transAxes, va="top", ha="left", fontsize=8, fontweight="bold")


def signed(x, nd=1):
    """Signed number with a typographic minus."""
    return f"{x:+.{nd}f}".replace("-", "\u2212")


# ------------------------------------------------------------------ data overview
def full_band(r):
    """Full-band LPM estimate of one record (cells), sorted in frequency, through the carrier."""
    sp = cf.lpm_spectrum(r, cf.F_LO, cf.F_HI)
    return sp.f, sp.H, sp.sigma


LIN_KHZ = 0.5      # linear part of the offset axis around the carrier (kHz)


def symlog_axis(a, lim=cf.F_HI / 1e3, ticks=(-100, -10, -1, 0, 1, 10, 100)):
    a.set_xscale("symlog", linthresh=LIN_KHZ, linscale=0.3)
    a.set_xlim(-lim, lim)
    a.set_xticks(list(ticks))
    a.set_xticklabels([signed(t, 0).lstrip("+") if t else "0" for t in ticks])


def noise_level_db(sigma):
    """Standard deviation of the complex estimates in dB, a running median over five points for display."""
    return 20 * np.log10(median_filter(np.sqrt(2) * sigma, size=5, mode="nearest"))


def fig_data():
    show = [("10/02 09:47:00", "22 mA"), ("11/03 17:07:42", "242 mA"), ("10/02 13:44:49", "363 mA"),
            ("10/02 17:20:30", "395 mA"), ("10/02 13:51:53", "497 mA (I)"), ("11/03 17:27:29", "497 mA (II)")]
    noise_shown = ("10/02 09:47:00", "11/03 17:27:29")
    fig, ax = plt.subplots(2, 2, figsize=(COL2, 4.1), gridspec_kw=dict(width_ratios=[1.35, 1]))
    for lab, txt in show:
        r = rec_by_label(lab)
        c = CMAP(min(r.mA / 520, 0.95))
        ls = "--" if r.date == "20261103" and r.mA > 400 else "-"
        f, H, sig = full_band(r)
        ax[0, 0].plot(f / 1e3, 20 * np.log10(np.abs(H)), ls, color=c, lw=0.6, label=txt)
        ax[1, 0].plot(f / 1e3, np.degrees(np.angle(-H * np.exp(2j * np.pi * f * 630e-9))), ls, color=c, lw=0.6)
        near = np.abs(f) < 20e3
        ax[0, 1].plot(f[near] / 1e3, 20 * np.log10(np.abs(H[near])), ls, color=c, lw=0.7)
        if lab in noise_shown:
            cd_ = tuple(0.7 * np.array(c[:3]))          # darker shade: the dotted lines must stay visible
            ax[0, 0].plot(f / 1e3, noise_level_db(sig), ":", color=cd_, lw=0.9)
            ax[0, 1].plot(f[near] / 1e3, noise_level_db(sig)[near], ":", color=cd_, lw=0.9)
    ax[0, 0].plot([], [], ":", color="0.3", lw=0.9, label="noise level")
    for lab in ("11/03 17:27:29", "11/03 17:28:53", "11/03 17:29:32"):
        r = rec_by_label(lab)
        f, H, sig = full_band(r)
        near = np.abs(f) < 20e3
        c = GAIN_COLS[round(r.counts_db, 1)]
        ax[1, 1].plot(f[near] / 1e3, 20 * np.log10(np.abs(H[near])), lw=0.7, color=c,
                      label=f"loop gain {signed(r.counts_db - 1.3)} dB")
        if lab == "11/03 17:27:29":
            ax[1, 1].plot(f[near] / 1e3, noise_level_db(sig)[near], ":", color=c, lw=0.9, label="noise level")
    ax[0, 0].set_ylabel(r"$|H|$ (dB)")
    ax[1, 0].set_ylabel(r"$\arg(-H\,e^{j\omega\,630\,\mathrm{ns}})$ (deg)")
    ax[1, 0].set_xlabel("offset from $f_\\mathrm{RF}$ (kHz)")
    ax[0, 1].set_ylabel(r"$|H|$ (dB)")
    ax[1, 1].set_ylabel(r"$|H|$ (dB)")
    ax[1, 1].set_xlabel("offset from $f_\\mathrm{RF}$ (kHz)")
    for a in ax[:, 0]:
        symlog_axis(a)
    ax[0, 0].set_ylim(-64, 16)
    ax[1, 0].set_ylim(-200, 200)
    for a in ax[:, 1]:
        a.set_xlim(-20, 20)
        a.set_ylim(-32, 16)
    ax[0, 0].legend(ncol=4, loc="lower center", fontsize=5.6, columnspacing=1.0, handlelength=1.8)
    ax[1, 1].legend(loc="lower center", title="497 mA (II)", title_fontsize=6.5, ncol=2, fontsize=5.8,
                    columnspacing=1.0)
    for a, s in zip(ax.ravel(), "acbd"):
        panel(a, f"({s})")
    fig.tight_layout(h_pad=0.4, w_pad=0.8)
    save(fig, "data_overview")


GAIN_COLS = {1.3: "C0", 0.3: "C2", 0.0: "C1", -0.2: "C3"}


# ------------------------------------------------------------------ trip records of the present klystron (2021)
def fig_trip_klystron():
    """(a) klystron output against drive amplitude by frequency, (b) AM/PM from the drive-to-probe ratio,
    (c) compression: trip records against the closed-loop identification."""
    T = _json("trip_klystron.json")
    J = _json("joint_fits.json")
    s = T["summary"]
    used = [r for r in T["records"] if "gain" in r]
    col = {"full": "C0", "reduced": "C1"}
    fig, ax = plt.subplots(1, 3, figsize=(COL2, 2.35), gridspec_kw=dict(width_ratios=[1.2, 1, 1.15]))
    edges = np.geomspace(2e3, 1.5e6, 36)
    for r in used:
        sp = r["gain"]["spectrum"]
        f, h = np.asarray(sp["f"]), np.asarray(sp["h1"])
        idx = np.digitize(f, edges)
        keep = [i for i in range(1, len(edges)) if np.any(idx == i)]
        fc = np.array([math.sqrt(edges[i - 1] * edges[i]) for i in keep])
        hm = np.array([np.median(h[idx == i]) for i in keep])
        ax[0].semilogx(fc / 1e3, hm, color=col[r["kind"]], lw=0.7, alpha=0.9)
    ax[0].plot([], [], color="C0", label=f"full output ({s['n_full']})")
    ax[0].plot([], [], color="C1", label=f"{100 * s['power_ratio']:.0f}% of full ({s['n_reduced']})")
    ax[0].axvspan(50, 200, color="0.9", lw=0, zorder=0)
    ax[0].set_xlim(2, 1500)
    ax[0].set_ylim(0, 0.7)
    ax[0].set_xlabel("frequency (kHz)")
    ax[0].set_ylabel(r"$|\delta\ln A_\mathrm{out}/\delta\ln A_\mathrm{drive}|$")
    ax[0].legend(loc="lower left")
    for r in used:
        ax[1].plot(r["n"], r["ratio"]["k_AP"], "o", ms=3.5, color=col[r["kind"]], mfc="none")
    m, sd = s["k_AP"]
    ax[1].axhspan(m - sd, m + sd, color="0.88", lw=0, zorder=0)
    ax[1].axhline(m, color="k", lw=0.8)
    free = J["results"]["J_wl_group_ac"]["free"]
    kf = [v for k, (v, e) in free.items() if k.startswith("k_AP")]
    ax[1].plot([16.6] * len(kf), kf, "x", ms=4, color="0.35", label="closed loop, $k_\\mathrm{AP}$ free")
    ax[1].axhline(0, color="0.6", lw=0.5, ls=":")
    ax[1].set_xlim(4, 17.5)
    ax[1].set_ylim(-0.6, 0.7)
    ax[1].set_xlabel("trip record")
    ax[1].set_ylabel(r"AM/PM $k_\mathrm{AP}$")
    ax[1].legend(loc="lower left")
    sel, one = J["results"][SELECTED], J["results"][ONE_KLY]
    groups = J["groups"]
    for k in range(max(groups) + 1):
        mA = np.mean([rj["mA"] for rj, g in zip(sel["records"], groups) if g == k])
        v, e = sel["free"][f"g_A[g{k}]"]
        ax[2].errorbar(mA, v, yerr=max(e, 0.005), fmt="s", ms=3.5, color="C3", capsize=1.5, lw=0.7,
                       label="closed loop, per operating point" if k == 0 else None)
    ax[2].axhline(one["globals"]["g_A"][0], color="C2", ls="--", lw=0.9, label="closed loop, one klystron")
    g, gs = s["g_A"]
    ax[2].axhspan(g - gs, g + gs, color="C1", alpha=0.22, lw=0, label="trip records, 50\u2013200 kHz")
    ax[2].axhline(s["g_A_high"][0], color="C1", ls=":", lw=0.9, label="trip records, 0.2\u20131.5 MHz")
    ax[2].set_xlim(-20, 540)
    ax[2].set_ylim(0, 0.75)
    ax[2].set_xlabel("beam current (mA)")
    ax[2].set_ylabel(r"compression $g_A$")
    ax[2].legend(loc="lower left", fontsize=5.6)
    from make_numbers import cathode_voltage
    vk, _ = cathode_voltage()
    grid = np.linspace(-60, 600, 400)
    kv = np.array([vk(m) for m in grid])
    top = ax[2].secondary_xaxis("top", functions=(lambda m: np.interp(m, grid, kv), lambda v: np.interp(v, kv, grid)))
    top.set_xticks([68, 70, 72, 74])
    top.set_xlabel("HVPS voltage, estimated (kV)", fontsize=7)
    top.tick_params(labelsize=6)
    for a, t in zip(ax, "abc"):
        panel(a, f"({t})")
    fig.tight_layout(w_pad=0.6)
    save(fig, "trip_klystron")


FIGS = {"data": fig_data, "trips": fig_trip_klystron}


# ------------------------------------------------------------------ results figures
def _json(name):
    p = cd.RESULTS / name
    return json.loads(p.read_text()) if p.exists() else None


def _station(rj):
    keys = ("G", "theta", "tau", "Q_L", "df", "df_spread", "g_A", "k_AP", "alpha", "mc1r", "mc1i", "mc2r", "mc2i", "alpha_c")
    return cm.Station(I_b=rj["mA"] / 1e3, beam=rj.get("beam", True), **{k: rj[k] for k in keys if k in rj})


def fig_effective():
    """Effective parameters of per-record complex-linear fits against current; the station model's constants."""
    from make_numbers import G_TO_OP, OP_GAIN_DB, station_cavities
    J = _json("joint_fits.json")
    eff = J["results"]["J_lin_eff_ac"]["records"]
    sel = J["results"][SELECTED]
    fig, ax = plt.subplots(1, 3, figsize=(COL2, 2.2))
    for rj in eff:
        g_op = rj["G"] / 10 ** ((rj["counts_db"] - OP_GAIN_DB) / 20)
        two = rj["label"].startswith("11/03")
        mk = "s" if two else "o"
        c = GAIN_COLS.get(round(rj["counts_db"], 1), "k") if two and rj["mA"] > 400 else "0.3"
        ax[0].plot(rj["mA"], g_op, mk, ms=3.5, mfc="none", color=c)
        ax[1].plot(rj["mA"], rj["tau"] * 1e9, mk, ms=3.5, mfc="none", color=c)
        ax[2].plot(rj["mA"], rj["Q_L"], mk, ms=3.5, mfc="none", color=c)
    g0 = sel["globals"]["G"][0] * G_TO_OP
    ax[0].axhline(g0, color="k", lw=0.8, ls="--")
    ax[1].axhline(sel["globals"]["tau"][0] * 1e9, color="k", lw=0.8, ls="--")
    ax[2].axhline(sel["globals"]["Q_L"][0], color="k", lw=0.8, ls="--")
    q_l = station_cavities()["q_l"]
    ax[2].axhspan(q_l.min(), q_l.max(), color="0.85", lw=0, zorder=0)
    ax[0].set_ylabel(r"$G_\mathrm{eff}$ (operating loop gain)")
    ax[0].set_ylim(0.3, 1.65)
    ax[1].set_ylabel(r"$\tau_\mathrm{eff}$ (ns)")
    ax[2].set_ylabel(r"$Q_{L,\mathrm{eff}}$")
    for a, s in zip(ax, "abc"):
        a.set_xlabel("beam current (mA)")
        a.set_xlim(-20, 540)
        panel(a, f"({s})")
    ax[0].text(0.97, 0.76, "dashed: one station,\ncompressed klystron", transform=ax[0].transAxes, ha="right", va="top",
               fontsize=6.5)
    fig.tight_layout(w_pad=0.8)
    save(fig, "effective_parameters")


def fig_identifiability():
    I = _json("identifiability.json")
    fig, ax = plt.subplots(2, 1, figsize=(COL1, 4.1))
    styles = {"one record, wideband only": ("C2", "-", "1 record, loop band"),
              "one record": ("C3", ":", "1 record, full band"),
              "500 mA scan (7)": ("C0", "--", "497 mA scan (7)"),
              "all records (18)": ("k", "-", "all records (18)")}
    for name in ("one record, wideband only", "one record", "500 mA scan (7)", "all records (18)"):
        d = I.get(name)
        if d is None:
            continue
        c, ls, lab = styles[name]
        for a, key in zip(ax, ("g_A", "k_AP")):
            p = np.array(sorted(d["profile"][key]))
            a.plot(p[:, 0], p[:, 1] - d["chi_min"], ls, color=c, marker="o", ms=2.3, lw=0.9, label=lab)
    for a, lab in zip(ax, (r"klystron compression $g_A$ (497 mA)", r"AM/PM conversion $k_\mathrm{AP}$ (497 mA)")):
        a.axhline(3.84, color="0.5", lw=0.6, ls=":")
        a.set_yscale("symlog", linthresh=10)
        a.set_ylim(-0.5, 4e5)
        a.set_xlabel(lab)
        a.set_ylabel(r"$\Delta\chi^2$ (profile)")
    ax[0].legend(loc="upper center", fontsize=6, ncol=2, columnspacing=1.0, handlelength=2.2)
    panel(ax[0], "(a)")
    panel(ax[1], "(b)")
    fig.tight_layout(h_pad=0.6)
    save(fig, "identifiability")


def fig_models():
    J = _json("joint_fits.json")
    W = _json("wide_fits.json")
    order = [("J_lin_shared_ac", "one station,\nlinear"), ("J_spread_ac", "+ detuning\nspread"),
             ("J_lin_eff_ac", "effective\nper record"), ("J_wl_trip_ac", "trip-record\nklystron"),
             (ONE_KLY, "one\nklystron"), ("J_wl_group_ktrip", "design\n$\\alpha_c$"),
             ("J_wl_group_ac", "AM/PM\nfree"), (SELECTED, "selected")]
    fig, ax = plt.subplots(1, 2, figsize=(COL2, 2.5), gridspec_kw=dict(width_ratios=[1.25, 1]))
    xs = np.arange(len(order))
    for k, (band, c) in enumerate((("loop band", "C0"), ("near band", "C3"))):
        vals = []
        for name, _ in order:
            b = np.array(J["results"][name]["band_chi2"])
            vals.append(b[:, k].sum() / b[:, 2 + k].sum())
        ax[0].bar(xs + (k - 0.5) * 0.38, vals, 0.38, color=c, label=band)
    ax[0].axhline(1, color="k", lw=0.6, ls=":")
    ax[0].set_yscale("log")
    ax[0].set_ylim(0.6, 40)
    ax[0].set_xticks(xs, [o[1] for o in order], fontsize=5.8)
    ax[0].set_ylabel(r"$\chi^2/\nu$")
    ax[0].legend(loc="upper right")
    # normalized residuals per real component, averaged over all records cell by cell (the cells are common to all
    # records; only their weighted mean frequencies differ slightly)
    recs_all = [rec_by_label(x["label"]) for x in J["results"][SELECTED]["records"]]
    for name, c, txt in (("J_lin_shared_ac", "C7", "one station, linear"), ("J_lin_eff_ac", "C1", "effective"),
                         (ONE_KLY, "C2", "one klystron"), (SELECTED, "C0", "per operating point (selected)")):
        acc, fgrid = None, None
        for r, rj in zip(recs_all, J["results"][name]["records"]):
            sps = [cf.lpm_spectrum(r, cf.F_SPLIT, cf.F_HI), cf.lpm_spectrum(r, cf.F_LO, cf.F_SPLIT)]
            st = _station(rj)
            f = np.concatenate([sp.f for sp in sps])
            res = np.concatenate([np.abs((cf.model_on(st, sp) - sp.H) / sp.sigma) ** 2 / 2 for sp in sps])
            o = np.argsort(f)
            acc = res[o] if acc is None else acc + res[o]
            fgrid = f[o]
        acc /= len(recs_all)
        sm = np.convolve(acc, np.ones(5) / 5, "same")
        ax[1].plot(fgrid / 1e3, sm, color=c, lw=0.7, label=txt)
    ax[1].set_yscale("log")
    symlog_axis(ax[1])
    ax[1].axhline(1, color="k", lw=0.6, ls=":")
    ax[1].axvspan(-cf.F_SPLIT / 1e3, cf.F_SPLIT / 1e3, color="0.92", lw=0, zorder=0)
    ax[1].set_xlabel("offset from $f_\\mathrm{RF}$ (kHz)")
    ax[1].set_ylabel(r"$\chi^2$ per real component")
    ax[1].set_ylim(0.3, 300)
    ax[1].legend(loc="upper right", fontsize=6)
    panel(ax[0], "(a)")
    panel(ax[1], "(b)")
    fig.tight_layout(w_pad=0.8)
    save(fig, "model_comparison")


def model_curve(st, f):
    """The model averaged over the resolution of the estimates (nine 39-Hz bins), on a fine grid f."""
    off = (np.arange(-lp.N_HALF, lp.N_HALF + 1) * cd.FS / 2 ** 18)
    return cm.measured_tf(st, (f[:, None] + off[None, :]).ravel()).reshape(f.size, -1).mean(axis=1)


def fig_fits():
    J = _json("joint_fits.json")["results"][SELECTED]
    labs = [("10/02 09:47:00", "22 mA"), ("11/03 17:07:42", "242 mA"), ("10/02 13:44:49", "363 mA"),
            ("11/03 17:27:29", "497 mA, +0 dB"), ("11/03 17:29:32", "494 mA, $-1.5$ dB")]
    fig, ax = plt.subplots(3, len(labs), figsize=(COL2, 4.4), sharey="row")
    lin = LIN_KHZ * 1e3
    grid = np.concatenate([-np.geomspace(cf.F_HI, lin, 700), np.linspace(-lin, lin, 41)[1:-1],
                           np.geomspace(lin, cf.F_HI, 700)])
    near = np.linspace(-20e3, 20e3, 1601)
    for j, (lab, txt) in enumerate(labs):
        r = rec_by_label(lab)
        rj = next(x for x in J["records"] if x["label"] == lab)
        st = _station(rj)
        f, H, sig = full_band(r)
        Hm, Hn = model_curve(st, grid), model_curve(st, near)
        ax[0, j].plot(f / 1e3, 20 * np.log10(np.abs(H)), ".", ms=1.0, color="0.55")
        ax[1, j].plot(f / 1e3, np.degrees(np.angle(-H * np.exp(2j * np.pi * f * 630e-9))), ".", ms=1.0, color="0.55")
        nb = np.abs(f) < 20e3
        # the scatter expected of the estimates: |model| +- one standard deviation (per component)
        m_nb = np.abs(model_curve(st, f[nb]))
        s_nb = median_filter(sig[nb], size=5, mode="nearest")
        lo = 20 * np.log10(np.maximum(m_nb - s_nb, 10 ** (-40 / 20)))
        ax[2, j].fill_between(f[nb] / 1e3, lo, 20 * np.log10(m_nb + s_nb), color="C3", alpha=0.18, lw=0)
        ax[2, j].plot(f[nb] / 1e3, 20 * np.log10(np.abs(H[nb])), ".", ms=1.6, color="0.45")
        ax[0, j].plot(grid / 1e3, 20 * np.log10(np.abs(Hm)), "C0-", lw=0.8)
        ax[1, j].plot(grid / 1e3, np.degrees(np.angle(-Hm * np.exp(2j * np.pi * grid * 630e-9))), "C0-", lw=0.8)
        ax[2, j].plot(near / 1e3, 20 * np.log10(np.abs(Hn)), "C3-", lw=0.8)
        ax[0, j].set_title(txt, fontsize=7.5)
        ax[2, j].set_xlabel("offset (kHz)")
        for a in (ax[0, j], ax[1, j]):
            symlog_axis(a, ticks=(-100, -1, 1, 100))
        ax[2, j].set_xlim(-20, 20)
        ax[2, j].set_xticks([-10, 0, 10])
    ax[0, 0].set_ylabel(r"$|H|$ (dB)")
    ax[1, 0].set_ylabel("phase (deg)")
    ax[2, 0].set_ylabel(r"$|H|$ (dB)")
    ax[0, 0].set_ylim(-36, 16)
    ax[1, 0].set_ylim(-200, 200)
    ax[2, 0].set_ylim(-35, 18)
    fig.tight_layout(h_pad=0.3, w_pad=0.2)
    save(fig, "fits")


def fig_mode():
    V = _json("beam_mode_validation.json")
    J = _json("joint_fits.json")["results"][SELECTED]
    W = V.get("wl_group_ktrip") or V.get("wl_group")
    L = V.get("lin_eff")
    fig, ax = plt.subplots(1, 2, figsize=(COL2, 2.6))
    pred = {}
    for rj in J["records"]:
        if rj["mA"] < 200:
            continue
        s = cm.coupled_mode(_station(rj))
        pred[rj["tag"]] = (s.imag / 2 / np.pi, -s.real)
    for rows, mk, c, lab in ((L, "v", "C7", "loop band only, linear (effective)"),
                             (W, "^", "C1", "loop band only, compressed"),):
        if rows is None:
            continue
        ax[0].plot([x["sigma_pred"] for x in rows], [x["f_pred"] / 1e3 for x in rows], mk, ms=3.2, color=c, mfc="none",
                   label=lab)
    rows = W
    ax[0].errorbar([x["sigma_free"] for x in rows], [x["f_free"] / 1e3 for x in rows],
                   xerr=[x["dsigma_free"] for x in rows], yerr=[x["df_free"] / 1e3 for x in rows], fmt="ko", ms=3,
                   lw=0.6, label="measured (model-free pole)")
    ax[0].plot([pred[x["tag"]][1] for x in rows], [pred[x["tag"]][0] / 1e3 for x in rows], "C0s", ms=3.2,
               label=r"full-band model, $f_s$ identified")
    ax[0].set_xlabel(r"damping rate $\sigma$ (s$^{-1}$)")
    ax[0].set_ylabel(r"coherent frequency $f_c$ (kHz)")
    ax[0].legend(fontsize=6, loc="upper right")
    # versus current and gain
    shown = set()
    for x in rows:
        scan = x["label"].startswith("11/03") and x["mA"] > 400
        c = GAIN_COLS.get(round(x["counts_db"], 1), "k") if scan else "k"
        lab = (f"497 mA (II), {signed(x['counts_db'] - 1.3)} dB" if scan else "other records") if c not in shown else None
        shown.add(c)
        ax[1].errorbar(x["mA"], x["sigma_free"], yerr=x["dsigma_free"], fmt="o", ms=3, color=c, lw=0.6, label=lab)
        ax[1].plot(x["mA"] + 7, pred[x["tag"]][1], "s", ms=3, color=c, mfc="none")
    ax[1].plot([], [], "s", ms=3, color="0.3", mfc="none", label="full-band model")
    ax[1].legend(fontsize=5.8, loc="upper left", bbox_to_anchor=(0.07, 0.99))
    ax[1].set_xlabel("beam current (mA)")
    ax[1].set_ylabel(r"$\sigma$ (s$^{-1}$)")
    ax[1].axhline(cm.ALPHA_RAD, color="0.6", lw=0.6, ls=":")
    ax[1].text(300, 470, r"$\alpha_\mathrm{rad}$", fontsize=6.5, color="0.4")
    panel(ax[0], "(a)")
    panel(ax[1], "(b)")
    fig.tight_layout(w_pad=1.0)
    save(fig, "coupled_mode")


def fig_crossval():
    C = _json("crossval.json")
    tests = list(C)
    names = [("J_lin_shared_ac", "one station, linear", "C7"), ("J_lin_eff_ac", "effective, interpolated", "C1"),
             (ONE_KLY, "one klystron", "C2"), (SELECTED, "per operating point", "C0")]
    fig, ax = plt.subplots(figsize=(COL1, 2.2))
    xs = np.arange(len(tests))
    w = 0.21
    for k, (n, lab, c) in enumerate(names):
        vals = [np.mean([x["chi2_red"] for x in C[t][n]]) for t in tests]
        ax.bar(xs + (k - 1.5) * w, vals, w, color=c, label=lab)
    ins = [np.mean([x["insample"] for x in C[t][SELECTED]]) for t in tests]
    ax.plot(xs + 1.5 * w, ins, "k_", ms=8, mew=1.2, label="in-sample (selected)")
    ax.axhline(1, color="k", lw=0.5, ls=":")
    ax.set_yscale("log")
    ax.set_ylim(0.4, 300)
    short = {"A gain transfer (497 mA)": "gain\n497 mA", "B phase transfer (22 mA)": "phase\n22 mA",
             "C current transfer 242 mA": "current\n242 mA", "C current transfer 363 mA": "current\n363 mA",
             "C current transfer 395 mA": "current\n395 mA"}
    ax.set_xticks(xs, [short.get(t, t) for t in tests], fontsize=6.5)
    ax.set_ylabel(r"held-out $\chi^2/\nu$")
    ax.legend(fontsize=5.8, loc="upper center", ncol=2)
    fig.tight_layout()
    save(fig, "crossval")


FIGS.update({"effective": fig_effective, "ident": fig_identifiability, "models": fig_models, "fits": fig_fits,
             "mode": fig_mode, "crossval": fig_crossval})

if __name__ == "__main__":
    names = sys.argv[1:] or list(FIGS)
    for nme in names:
        FIGS[nme]()
