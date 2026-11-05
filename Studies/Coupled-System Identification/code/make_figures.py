"""Figures of the paper (PDF, Physical Review Accelerators and Beams sizes).

usage: python make_figures.py [names...]   (default: all)
Figures read the result files written by run_global.py, run_trip_constrained.py, run_identifiability.py,
validate_beam_mode.py, run_crossval.py and csi_trips.py; data-only figures read the measurement files directly.
"""
from __future__ import annotations

import json
import math
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402

import csi_beam as cb  # noqa: E402
import csi_data as cd  # noqa: E402
import csi_fit as cf  # noqa: E402
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


# ------------------------------------------------------------------ data overview
def fig_data():
    show = [("10/02 09:47:00", "22 mA"), ("11/03 17:07:42", "242 mA"), ("10/02 13:44:49", "363 mA"),
            ("10/02 17:20:30", "395 mA"), ("10/02 13:51:53", "497 mA (2 Oct)"), ("11/03 17:27:29", "497 mA (3 Nov)")]
    fig, ax = plt.subplots(2, 2, figsize=(COL2, 4.1))
    for lab, txt in show:
        r = rec_by_label(lab)
        c = CMAP(min(r.mA / 520, 0.95))
        ls = "--" if r.date == "20261103" and r.mA > 400 else "-"
        sp = cf.spectrum(r, 8192, 1.3e3, 420e3)
        k = np.abs(sp.f) > 15e3
        f, H = sp.f, sp.H
        for side in (f < -15e3, f > 15e3):
            ax[0, 0].plot(f[side] / 1e3, 20 * np.log10(np.abs(H[side])), ls, color=c, lw=0.7,
                          label=f"{txt}" if side[-1] else None)
            ax[1, 0].plot(f[side] / 1e3, np.degrees(np.angle(-H[side] * np.exp(2j * np.pi * f[side] * 630e-9))), ls,
                          color=c, lw=0.7)
        sp2 = cf.spectrum(r, 2 ** 15, 0.5e3, 20e3)
        ax[0, 1].plot(sp2.f / 1e3, 20 * np.log10(np.abs(sp2.H)), ls, color=c, lw=0.7)
    for lab in ("11/03 17:27:29", "11/03 17:28:53", "11/03 17:29:32"):
        r = rec_by_label(lab)
        sp2 = cf.spectrum(r, 2 ** 15, 0.5e3, 20e3)
        ax[1, 1].plot(sp2.f / 1e3, 20 * np.log10(np.abs(sp2.H)), lw=0.7,
                      label=f"{r.counts_db:+.1f} dB, $\\phi_C$ {r.phase_c:+.0f}$^\\circ$")
    ax[0, 0].set_ylabel(r"$|H|$ (dB)")
    ax[1, 0].set_ylabel(r"$\arg(-H\,e^{j\omega\,630\,\mathrm{ns}})$ (deg)")
    ax[1, 0].set_xlabel("offset from $f_\\mathrm{RF}$ (kHz)")
    ax[0, 1].set_ylabel(r"$|H|$ (dB)")
    ax[1, 1].set_ylabel(r"$|H|$ (dB)")
    ax[1, 1].set_xlabel("offset from $f_\\mathrm{RF}$ (kHz)")
    for a in ax[:, 0]:
        a.set_xlim(-420, 420)
    for a in ax[:, 1]:
        a.set_xlim(-20, 20)
        a.set_ylim(-32, 16)
    ax[0, 0].legend(ncol=2, loc="lower center")
    ax[1, 1].legend(loc="lower center", title="497 mA, 3 Nov", title_fontsize=6.5)
    for a, s in zip(ax.ravel(), "acbd"):
        panel(a, f"({s})")
    fig.tight_layout(h_pad=0.4, w_pad=0.8)
    save(fig, "data_overview")


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
    ax[2].axhspan(g - gs, g + gs, color="C1", alpha=0.22, lw=0, label="trip records, 50--200 kHz")
    ax[2].axhline(s["g_A_high"][0], color="C1", ls=":", lw=0.9, label="trip records, 0.2--1.5 MHz")
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
    J = _json("joint_fits.json")
    eff = J["results"]["J_lin_eff_ac"]["records"]
    sel = J["results"][SELECTED]
    fig, ax = plt.subplots(1, 3, figsize=(COL2, 2.2))
    for rj in eff:
        g_norm = rj["G"] / 10 ** ((rj["counts_db"] - 0.9) / 20)
        mk = "s" if rj["label"].startswith("11/03") else "o"
        c = "C1" if rj["label"].startswith("11/03") and rj["mA"] > 400 and rj["counts_db"] != 1.3 else (
            "C2" if rj["label"].startswith("11/03") and rj["mA"] > 400 else "C0")
        ax[0].plot(rj["mA"], g_norm, mk, ms=3.5, mfc="none", color=c)
        ax[1].plot(rj["mA"], rj["tau"] * 1e9, mk, ms=3.5, mfc="none", color=c)
        ax[2].plot(rj["mA"], rj["Q_L"], mk, ms=3.5, mfc="none", color=c)
    g0 = sel["globals"]["G"][0]
    ax[0].axhline(g0, color="k", lw=0.8, ls="--")
    ax[1].axhline(sel["globals"]["tau"][0] * 1e9, color="k", lw=0.8, ls="--")
    ax[2].axhline(sel["globals"]["Q_L"][0], color="k", lw=0.8, ls="--")
    ax[2].axhspan(6100, 7020, color="0.85", lw=0, zorder=0)
    ax[0].set_ylabel(r"$G_\mathrm{eff}$ at 0.9 dB")
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
    styles = {"one record, wideband only": ("C2", "-", "1 record, routine band"),
              "one record": ("C3", ":", "1 record, both bands"),
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
    for k, (band, c) in enumerate((("wide", "C0"), ("beam", "C3"))):
        vals = []
        for name, _ in order:
            b = np.array(J["results"][name]["band_chi2"])
            vals.append(b[:, k].sum() / b[:, 2 + k].sum())
        ax[0].bar(xs + (k - 0.5) * 0.38, vals, 0.38, color=c, label=f"{band}band" if band == "wide" else "beam band")
    ax[0].axhline(1, color="k", lw=0.6, ls=":")
    ax[0].set_yscale("log")
    ax[0].set_ylim(0.6, 40)
    ax[0].set_xticks(xs, [o[1] for o in order], fontsize=5.8)
    ax[0].set_ylabel(r"$\chi^2/\nu$")
    ax[0].legend(loc="upper right")
    # normalized residuals pooled over all records (wideband), per frequency bin
    recs_all = [rec_by_label(x["label"]) for x in J["results"][SELECTED]["records"]]
    for name, c, txt in (("J_lin_shared_ac", "C7", "one station, linear"), ("J_lin_eff_ac", "C1", "effective"),
                         (ONE_KLY, "C2", "one klystron"), (SELECTED, "C0", "per operating point (selected)")):
        acc, fgrid = None, None
        for r, rj in zip(recs_all, J["results"][name]["records"]):
            sp = cf.spectrum(r, 8192, 15e3, 400e3)
            res = np.abs((cf.model_on(_station(rj), sp) - sp.H) / sp.sigma) ** 2 / 2
            o = np.argsort(sp.f)
            acc = res[o] if acc is None else acc + res[o]
            fgrid = sp.f[o]
        acc /= len(recs_all)
        k = 9
        sm = np.convolve(acc, np.ones(k) / k, "same")
        for side in (fgrid < 0, fgrid > 0):
            ax[1].semilogy(fgrid[side] / 1e3, sm[side], color=c, lw=0.7, label=txt if side[-1] else None)
    ax[1].axhline(1, color="k", lw=0.6, ls=":")
    ax[1].set_xlabel("offset from $f_\\mathrm{RF}$ (kHz)")
    ax[1].set_ylabel(r"$\langle|r|^2\rangle/2$ (18 records)")
    ax[1].set_ylim(top=300)
    ax[1].legend(loc="upper right", fontsize=6)
    panel(ax[0], "(a)")
    panel(ax[1], "(b)")
    fig.tight_layout(w_pad=0.8)
    save(fig, "model_comparison")


def fig_fits():
    J = _json("joint_fits.json")["results"][SELECTED]
    labs = [("10/02 09:47:00", "22 mA"), ("11/03 17:07:42", "242 mA"), ("10/02 13:44:49", "363 mA"),
            ("11/03 17:27:29", "497 mA, +1.3 dB"), ("11/03 17:29:32", "494 mA, $-0.2$ dB")]
    fig, ax = plt.subplots(3, len(labs), figsize=(COL2, 4.2), sharey="row")
    for j, (lab, txt) in enumerate(labs):
        r = rec_by_label(lab)
        rj = next(x for x in J["records"] if x["label"] == lab)
        st = _station(rj)
        sp = cf.spectrum(r, 8192, 15e3, 400e3)
        o = np.argsort(sp.f)
        f, H = sp.f[o], sp.H[o]
        ff = np.linspace(-400e3, 400e3, 1601)
        ff = ff[np.abs(ff) >= 15e3]
        Hm = cm.measured_tf(st, ff)
        for side in (f < 0, f > 0):
            ax[0, j].plot(f[side] / 1e3, 20 * np.log10(np.abs(H[side])), ".", ms=0.8, color="0.55")
            ax[1, j].plot(f[side] / 1e3, np.degrees(np.angle(-H[side] * np.exp(2j * np.pi * f[side] * 630e-9))), ".",
                          ms=0.8, color="0.55")
        for side in (ff < 0, ff > 0):
            ax[0, j].plot(ff[side] / 1e3, 20 * np.log10(np.abs(Hm[side])), "C0-", lw=0.8)
            ax[1, j].plot(ff[side] / 1e3, np.degrees(np.angle(-Hm[side] * np.exp(2j * np.pi * ff[side] * 630e-9))),
                          "C0-", lw=0.8)
        bs = cb.beam_spectrum(r)
        fine = np.linspace(-16e3, 16e3, 2001)
        fine = fine[np.abs(fine) >= 3e3]
        mb = cf.model_on(st, cf.Spectrum(r, fine, fine * 0, fine * 0 + 1, fine * 0, bs.nfft, True, bs.kern_off, bs.kern_w))
        for side in (bs.f < 0, bs.f > 0):
            ax[2, j].plot(bs.f[side] / 1e3, 20 * np.log10(np.abs(bs.H[side])), ".", ms=1.5, color="0.55")
        for side in (fine < 0, fine > 0):
            ax[2, j].plot(fine[side] / 1e3, 20 * np.log10(np.abs(mb[side])), "C3-", lw=0.8)
        ax[0, j].set_title(txt, fontsize=7.5)
        ax[2, j].set_xlabel("offset (kHz)")
        for a in (ax[0, j], ax[1, j]):
            a.set_xlim(-420, 420)
            a.set_xticks([-300, 0, 300])
        ax[2, j].set_xlim(-16, 16)
        ax[2, j].set_xticks([-10, 0, 10])
    ax[0, 0].set_ylabel(r"$|H|$ (dB)")
    ax[1, 0].set_ylabel("phase (deg)")
    ax[2, 0].set_ylabel(r"$|H|$ (dB), beam band")
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
    for rows, mk, c, lab in ((L, "v", "C7", "wideband only, linear (effective)"),
                             (W, "^", "C1", "wideband only, compressed"),):
        if rows is None:
            continue
        ax[0].plot([x["sigma_pred"] for x in rows], [x["f_pred"] / 1e3 for x in rows], mk, ms=3.2, color=c, mfc="none",
                   label=lab)
    rows = W
    ax[0].errorbar([x["sigma_free"] for x in rows], [x["f_free"] / 1e3 for x in rows],
                   xerr=[x["dsigma_free"] for x in rows], yerr=[x["df_free"] / 1e3 for x in rows], fmt="ko", ms=3,
                   lw=0.6, label="measured (model-free pole)")
    ax[0].plot([pred[x["tag"]][1] for x in rows], [pred[x["tag"]][0] / 1e3 for x in rows], "C0s", ms=3.2,
               label=r"joint model, $f_s$ identified")
    ax[0].set_xlabel(r"damping rate $\sigma$ (s$^{-1}$)")
    ax[0].set_ylabel(r"coherent frequency $f_c$ (kHz)")
    ax[0].legend(fontsize=6, loc="upper right")
    # versus current and gain
    gain_cols = {1.3: "C0", 0.3: "C2", 0.0: "C1", -0.2: "C3"}
    shown = set()
    for x in rows:
        nov500 = x["label"].startswith("11/03") and x["mA"] > 400
        c = gain_cols.get(round(x["counts_db"], 1), "k") if nov500 else "k"
        lab = (f"3 Nov, {x['counts_db']:+.1f} dB" if nov500 else "other records") if c not in shown else None
        shown.add(c)
        ax[1].errorbar(x["mA"], x["sigma_free"], yerr=x["dsigma_free"], fmt="o", ms=3, color=c, lw=0.6, label=lab)
        ax[1].plot(x["mA"] + 7, pred[x["tag"]][1], "s", ms=3, color=c, mfc="none")
    ax[1].plot([], [], "s", ms=3, color="0.3", mfc="none", label="joint model")
    ax[1].legend(fontsize=5.8, loc="upper left", bbox_to_anchor=(0.07, 0.99))
    ax[1].set_xlabel("beam current (mA)")
    ax[1].set_ylabel(r"$\sigma$ (s$^{-1}$)")
    ax[1].axhline(424, color="0.6", lw=0.6, ls=":")
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
