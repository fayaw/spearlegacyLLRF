"""Performance-matrix spectra from the dedicated R&S FSW on the cavity-A probe.

Saves the complete instrument state, takes RMS-detector, power-averaged traces in three set-ups,
restores the saved state, checks the restore against the original settings and returns the
instrument to local control. Writes data/spectra/FSW_cavA_matrix_<start>.json.

usage: python scripts/fsw_matrix.py [--snapshot NAME]     (about 50 s of remote control)
"""
import argparse
import json
import time
from pathlib import Path

import pyvisa

RES = "TCPIP::172.22.245.99::inst0::INSTR"
STATE = r"C:\R_S\INSTR\USER\spear3rf_tmp_state.dfl"
OUT = Path(__file__).resolve().parents[1] / "data" / "spectra"
CHECK = (("center_Hz", "FREQ:CENT?"), ("span_Hz", "FREQ:SPAN?"), ("rbw_Hz", "BAND?"), ("vbw_Hz", "BAND:VID?"),
         ("vbw_auto", "BAND:VID:AUTO?"), ("ref_level", "DISP:TRAC:Y:RLEV?"), ("points", "SWE:POIN?"),
         ("sweep_time_s", "SWE:TIME?"), ("sweep_time_auto", "SWE:TIME:AUTO?"), ("sweep_type", "SWE:TYPE?"),
         ("continuous", "INIT:CONT?"), ("detector", "DET?"), ("trace1_mode", "DISP:TRAC1:MODE?"),
         ("sweep_count", "SWE:COUN?"), ("avg_type", "AVER:TYPE?"), ("format", "FORM?"), ("application", "INST?"))
SETUPS = (
    # name, span, RBW, VBW, points, averages (centre: the operator's centre, i.e. f_RF)
    ("robinson", 20e3, 30.0, 300.0, 10001, 100),
    ("lines", 2.2e3, 3.0, 30.0, 4401, 20),
    ("wide", 3.0e6, 1e3, 10e3, 6001, 50),
)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--snapshot", default="", help="name of the paired EPICS snapshot, stored with the data")
    args = ap.parse_args()
    rm = pyvisa.ResourceManager("@py")
    inst = rm.open_resource(RES, timeout=20000)
    inst.read_termination = inst.write_termination = "\n"
    q = lambda c: inst.query(c).strip()  # noqa: E731
    info = {"start": time.strftime("%Y-%m-%dT%H:%M:%S"), "signal": "cavity A probe (station SRF1)",
            "method": "RMS detector, power trace averaging over the sweep count; instrument state saved "
                      "before and restored after the capture", "paired_epics_snapshot": args.snapshot, "setups": {}}
    t0 = time.time()
    try:
        info["original"] = {k: q(c) for k, c in CHECK}
        info["errors_before"] = q("SYST:ERR:ALL?")
        inst.write(f"MMEM:STOR:STAT 1,'{STATE}'")
        q("*OPC?")
        centre = float(info["original"]["center_Hz"])
        for cmd in ("INIT:CONT OFF", "DET RMS", "DISP:TRAC1:MODE AVER", "AVER:TYPE POW", "SWE:TIME:AUTO ON"):
            inst.write(cmd)
        for name, span, rbw, vbw, pts, navg in SETUPS:
            for cmd in (f"FREQ:CENT {centre:.3f}", f"FREQ:SPAN {span:.3f}", f"BAND {rbw}", f"BAND:VID {vbw}",
                        f"SWE:POIN {pts}", f"SWE:COUN {navg}"):
                inst.write(cmd)
            t1 = time.time()
            inst.timeout = 300000
            inst.write("INIT:IMM")
            q("*OPC?")
            inst.timeout = 20000
            setup = {k: q(c) for k, c in CHECK if k not in ("application", "format")}
            setup["start_Hz"], setup["stop_Hz"] = q("FREQ:STAR?"), q("FREQ:STOP?")
            setup["acq_s"] = round(time.time() - t1, 1)
            setup["trace_dBm"] = [round(float(x), 2) for x in q("TRAC:DATA? TRACE1").split(",")]
            info["setups"][name] = setup
            print(name, "done in", setup["acq_s"], "s")
        info["errors_during"] = q("SYST:ERR:ALL?")
    finally:
        try:
            inst.timeout = 60000
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
    info["restore_differences"] = {k: (info["original"][k], info.get("restored", {}).get(k)) for k, _ in CHECK
                                   if info["original"][k] != info.get("restored", {}).get(k)}
    OUT.mkdir(parents=True, exist_ok=True)
    name = OUT / ("FSW_cavA_matrix_" + info["start"].replace("-", "").replace(":", "") + ".json")
    json.dump(info, open(name, "w", encoding="utf-8"), indent=0)
    print("errors before/during/after:", info.get("errors_before"), "|", info.get("errors_during"), "|",
          info.get("errors_after"))
    print("restore differences:", info["restore_differences"] or "none")
    print("remote session", info["remote_session_s"], "s; device_local", info["device_local_error"], "->", name)


if __name__ == "__main__":
    main()
