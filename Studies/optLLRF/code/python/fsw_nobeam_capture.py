"""Cavity-A probe spectra on the R&S FSW, centred on the live f_RF (no-beam / any-current baseline).

Same safety pattern as spear3rf/scripts/fsw_matrix.py: query the original settings, save the full
instrument state to a temporary file on the instrument, measure in the operator's own channel
(no new channels, reference level and input untouched), reload the saved state on every exit path,
verify it against the original settings, delete the temporary file and return to local control.

EPICS is read with caget only (SPEAR:RFFreq, SRF1:STN:BEAM:CURR).

As run on 3 Nov 2026, 09:39, without beam (73 s of remote control, restore verified, no SCPI errors after the
save): spear3rf/data/spectra/FSW_cavA_nobeam_20261103T093904.json.  The "robinson", "lines" and "wide" set-ups
are those of fsw_matrix.py; "comb_usb"/"comb_lsb" resolve the 60 Hz comb at 7-11 kHz.  Note: the set-ups are
centred on SPEAR:RFFreq, but the analyzer is not locked to the master oscillator (the carrier sat 39.5 Hz off
centre); the output prefix says "nobeam" whatever the current.

usage: python fsw_nobeam_capture.py --query-only     (read settings, return to local)
       python fsw_nobeam_capture.py --snapshot NAME  (about 2 min of remote control)
"""
import argparse
import json
import time
from pathlib import Path

import epics
import pyvisa

RES = "TCPIP::172.22.245.99::inst0::INSTR"
STATE = r"C:\R_S\INSTR\USER\spear3rf_tmp_state2.dfl"
OUT = Path(__file__).resolve().parents[4] / "spear3rf" / "data" / "spectra"
CHECK = (("center_Hz", "FREQ:CENT?"), ("span_Hz", "FREQ:SPAN?"), ("rbw_Hz", "BAND?"), ("vbw_Hz", "BAND:VID?"),
         ("vbw_auto", "BAND:VID:AUTO?"), ("ref_level", "DISP:TRAC:Y:RLEV?"), ("points", "SWE:POIN?"),
         ("sweep_time_s", "SWE:TIME?"), ("sweep_time_auto", "SWE:TIME:AUTO?"), ("sweep_type", "SWE:TYPE?"),
         ("continuous", "INIT:CONT?"), ("detector", "DET?"), ("trace1_mode", "DISP:TRAC1:MODE?"),
         ("sweep_count", "SWE:COUN?"), ("avg_type", "AVER:TYPE?"), ("format", "FORM?"),
         ("application", "INST?"), ("rf_atten_dB", "INP:ATT?"), ("rf_atten_auto", "INP:ATT:AUTO?"))
# name, centre offset from f_RF [Hz], span, RBW, VBW, points, averages
SETUPS = (
    ("robinson", 0.0, 20e3, 30.0, 300.0, 10001, 100),   # identical to the 8 Oct 2026 capture
    ("lines", 0.0, 2.2e3, 3.0, 30.0, 4401, 20),         # identical to the 8 Oct 2026 capture
    ("comb_usb", +9.0e3, 4.0e3, 3.0, 30.0, 8001, 10),   # 7-11 kHz above the carrier, resolves the 60 Hz comb
    ("comb_lsb", -9.0e3, 4.0e3, 3.0, 30.0, 8001, 10),   # 7-11 kHz below the carrier
    ("wide", 0.0, 3.0e6, 1e3, 10e3, 6001, 50),          # identical to the 8 Oct 2026 capture
)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--snapshot", default="", help="name of the paired EPICS snapshot, stored with the data")
    ap.add_argument("--query-only", action="store_true", help="read the settings and return to local")
    args = ap.parse_args()

    f_rf = float(epics.caget("SPEAR:RFFreq", timeout=3.0)) * 1e6
    beam_mA = float(epics.caget("SRF1:STN:BEAM:CURR", timeout=3.0))

    rm = pyvisa.ResourceManager("@py")
    inst = rm.open_resource(RES, timeout=20000)
    inst.read_termination = inst.write_termination = "\n"
    q = lambda c: inst.query(c).strip()  # noqa: E731
    info = {"start": time.strftime("%Y-%m-%dT%H:%M:%S"), "signal": "cavity A probe (station SRF1)",
            "f_rf_Hz": f_rf, "beam_current_mA": beam_mA,
            "method": "RMS detector, power trace averaging over the sweep count, centred on SPEAR:RFFreq; "
                      "full instrument state saved before and restored after the capture",
            "paired_epics_snapshot": args.snapshot, "setups": {}}
    t0 = time.time()
    saved = False
    try:
        info["idn"] = q("*IDN?")
        info["errors_before"] = q("SYST:ERR:ALL?")
        info["original"] = {k: q(c) for k, c in CHECK}
        print("original:", json.dumps(info["original"]))
        print("errors before:", info["errors_before"])
        if args.query_only:
            return
        if "SPEC" not in info["original"]["application"].upper():
            raise SystemExit(f"active channel is {info['original']['application']!r}, not a spectrum channel: abort")
        inst.write(f"MMEM:STOR:STAT 1,'{STATE}'")
        q("*OPC?")
        err = q("SYST:ERR:ALL?")
        if not err.startswith("0"):
            raise SystemExit(f"state save reported {err!r}: abort before changing anything")
        saved = True
        for cmd in ("INIT:CONT OFF", "DET RMS", "DISP:TRAC1:MODE AVER", "AVER:TYPE POW", "SWE:TIME:AUTO ON"):
            inst.write(cmd)
        for name, off, span, rbw, vbw, pts, navg in SETUPS:
            for cmd in (f"FREQ:CENT {f_rf + off:.3f}", f"FREQ:SPAN {span:.3f}", f"BAND {rbw}", f"BAND:VID {vbw}",
                        f"SWE:POIN {pts}", f"SWE:COUN {navg}"):
                inst.write(cmd)
            t1 = time.time()
            inst.timeout = 300000
            inst.write("INIT:IMM")
            q("*OPC?")
            inst.timeout = 20000
            setup = {k: q(c) for k, c in CHECK if k not in ("application", "format")}
            setup["offset_from_f_rf_Hz"] = off
            setup["start_Hz"], setup["stop_Hz"] = q("FREQ:STAR?"), q("FREQ:STOP?")
            setup["acq_s"] = round(time.time() - t1, 1)
            # read the trace in whatever format the operator left (FORM is not changed); R&S default byte
            # order is little-endian (SWAP), checked by the plausibility of the levels
            if info["original"]["format"].upper().startswith("REAL"):
                tr = inst.query_binary_values("TRAC:DATA? TRACE1", datatype="f", is_big_endian=False, container=list)
                if not all(-250.0 < x < 50.0 for x in tr):
                    raise RuntimeError(f"{name}: implausible binary trace values (byte order?)")
            else:
                tr = [float(x) for x in q("TRAC:DATA? TRACE1").split(",")]
            if len(tr) != pts:
                raise RuntimeError(f"{name}: {len(tr)} trace points, expected {pts}")
            setup["trace_dBm"] = [round(float(x), 2) for x in tr]
            info["setups"][name] = setup
            print(name, "done in", setup["acq_s"], "s")
        info["errors_during"] = q("SYST:ERR:ALL?")
    finally:
        try:
            inst.timeout = 60000
            if saved:
                inst.write(f"MMEM:LOAD:STAT 1,'{STATE}'")
                q("*OPC?")
                info["restored"] = {k: q(c) for k, c in CHECK}
                inst.write(f"MMEM:DEL '{STATE}'")
                q("*OPC?")
                info["errors_after"] = q("SYST:ERR:ALL?")
        finally:
            sess = inst.visalib.sessions[inst.session]     # pyvisa-py has no GTL: VXI-11 device_local
            info["device_local_error"] = sess.interface.device_local(int(sess.link), 0, 1000, 5000)
            inst.close()
            info["remote_session_s"] = round(time.time() - t0, 1)
            print("device_local", info["device_local_error"], "remote session", info["remote_session_s"], "s")
    if args.query_only:
        return
    info["restore_differences"] = {k: (info["original"][k], info.get("restored", {}).get(k)) for k, _ in CHECK
                                   if info["original"][k] != info.get("restored", {}).get(k)}
    OUT.mkdir(parents=True, exist_ok=True)
    name = OUT / ("FSW_cavA_nobeam_" + info["start"].replace("-", "").replace(":", "") + ".json")
    json.dump(info, open(name, "w", encoding="utf-8"), indent=0)
    print("errors before/during/after:", info.get("errors_before"), "|", info.get("errors_during"), "|",
          info.get("errors_after"))
    print("restore differences:", info["restore_differences"] or "none")
    print("->", name)


if __name__ == "__main__":
    main()
