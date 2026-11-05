"""I/Q capture of the cavity-A probe on the R&S FSW, with full state save/restore and verification.

Guarded version of Studies/optLLRF/code/python/fsw_iq_capture.py (draft).  Additions:
  * the channel list (INST:LIST?) and active channel are recorded and verified after the restore;
  * the station state is not touched (EPICS caget only, for f_RF and the beam current);
  * nothing is changed unless the state save reports no error; every exit path deletes the temporary
    I/Q channel, reloads the saved state, verifies it, deletes the state file and returns to local;
  * FORM is not changed: the transfer needs REAL,32, which the operator's setting was (the draft sets it, and a
    state reload may not restore this remote-interface setting).

As run on 3 Nov 2026, 09:45, without beam (17 s of remote control, restore verified, no SCPI errors):
data/iq/FSW_IQ_20261103T094550.npz.  It centres on the operator's view, which is centred on the carrier as the
analyzer sees it (its time base is not locked to the master oscillator).

usage: python fsw_iq_capture_guarded.py [--seconds 16] [--fs 50e3] [--snapshot NAME]
"""
import argparse
import json
import time
from pathlib import Path

import epics
import numpy as np
import pyvisa

RES = "TCPIP::172.22.245.99::inst0::INSTR"
STATE = r"C:\R_S\INSTR\USER\optllrf_tmp_state.dfl"
CHANNEL = "OPTLLRF_IQ"
OUT = Path(__file__).resolve().parents[2] / "data" / "iq"
CHECK = (("center_Hz", "FREQ:CENT?"), ("span_Hz", "FREQ:SPAN?"), ("rbw_Hz", "BAND?"), ("vbw_Hz", "BAND:VID?"),
         ("ref_level", "DISP:TRAC:Y:RLEV?"), ("points", "SWE:POIN?"), ("sweep_time_s", "SWE:TIME?"),
         ("detector", "DET?"), ("trace1_mode", "DISP:TRAC1:MODE?"), ("continuous", "INIT:CONT?"),
         ("sweep_count", "SWE:COUN?"), ("avg_type", "AVER:TYPE?"), ("format", "FORM?"), ("application", "INST?"),
         ("channels", "INST:LIST?"), ("rf_atten_dB", "INP:ATT?"), ("rf_atten_auto", "INP:ATT:AUTO?"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seconds", type=float, default=16.0)
    ap.add_argument("--fs", type=float, default=50e3)
    ap.add_argument("--snapshot", default="")
    a = ap.parse_args()
    n = int(round(a.seconds * a.fs))
    f_rf = float(epics.caget("SPEAR:RFFreq", timeout=3.0)) * 1e6
    beam_mA = float(epics.caget("SRF1:STN:BEAM:CURR", timeout=3.0))

    inst = pyvisa.ResourceManager("@py").open_resource(RES, timeout=20000)
    inst.read_termination = inst.write_termination = "\n"
    q = lambda c: inst.query(c).strip()  # noqa: E731
    info = {"start": time.strftime("%Y-%m-%dT%H:%M:%S"), "signal": "cavity A probe (station SRF1)",
            "f_rf_Hz": f_rf, "beam_current_mA": beam_mA, "paired_epics_snapshot": a.snapshot, "fs": a.fs,
            "samples": n}
    iq, saved, created = None, False, False
    t0 = time.time()
    try:
        info["errors_before"] = q("SYST:ERR:ALL?")
        info["original"] = {k: q(c) for k, c in CHECK}
        print("original:", json.dumps(info["original"]))
        if CHANNEL in info["original"]["channels"]:
            raise SystemExit(f"a channel named {CHANNEL} already exists: abort")
        inst.write(f"MMEM:STOR:STAT 1,'{STATE}'")
        q("*OPC?")
        err = q("SYST:ERR:ALL?")
        if not err.startswith("0"):
            raise SystemExit(f"state save reported {err!r}: abort before changing anything")
        saved = True
        # the operator's view is centred on the carrier as the analyzer sees it (its OCXO is not locked
        # to the master oscillator); use that centre so the carrier sits at zero offset
        centre, ref = float(info["original"]["center_Hz"]), float(info["original"]["ref_level"])
        inst.write(f"INST:CRE:NEW IQ, '{CHANNEL}'")
        q("*OPC?")
        created = True
        for c in (f"FREQ:CENT {centre:.3f}", f"TRAC:IQ:SRAT {a.fs:.6g}", f"TRAC:IQ:RLEN {n}",
                  f"DISP:TRAC:Y:SCAL:RLEV {ref:.2f}", "INIT:CONT OFF", "TRAC:IQ:DATA:FORM IQP"):
            inst.write(c)
        q("*OPC?")
        err = q("SYST:ERR:ALL?")
        if not err.startswith("0"):
            raise RuntimeError(f"I/Q set-up reported {err!r}")
        info["settings"] = {"center_Hz": q("FREQ:CENT?"), "srate": q("TRAC:IQ:SRAT?"), "rlen": q("TRAC:IQ:RLEN?"),
                            "ref_level": q("DISP:TRAC:Y:SCAL:RLEV?"),
                            "format": q("FORM?"), "iq_format": q("TRAC:IQ:DATA:FORM?")}
        print("I/Q settings:", info["settings"])
        inst.timeout = int(1000 * (a.seconds + 60))
        inst.write("INIT:IMM")
        q("*OPC?")
        inst.timeout = 180000
        if not info["settings"]["format"].upper().startswith("REAL"):
            raise RuntimeError("FORM is not REAL,32: not changing it; abort the transfer")
        raw = inst.query_binary_values(f"TRAC:IQ:DATA:MEM? 0,{n}", datatype="f", is_big_endian=False,
                                       container=np.array)
        iq = (raw[0::2] + 1j * raw[1::2]).astype(np.complex64)
        info["errors_during"] = q("SYST:ERR:ALL?")
        print("captured", iq.size, "samples; mean |iq|", float(np.abs(iq).mean()))
    finally:
        try:
            inst.timeout = 60000
            if created:
                try:
                    inst.write(f"INST:DEL '{CHANNEL}'")
                    q("*OPC?")
                except Exception as exc:  # noqa: BLE001
                    info["delete_channel_error"] = str(exc)
            if saved:
                inst.write(f"MMEM:LOAD:STAT 1,'{STATE}'")
                q("*OPC?")
                info["restored"] = {k: q(c) for k, c in CHECK}
                inst.write(f"MMEM:DEL '{STATE}'")
                q("*OPC?")
                info["errors_after"] = q("SYST:ERR:ALL?")
        finally:
            sess = inst.visalib.sessions[inst.session]
            info["device_local_error"] = sess.interface.device_local(int(sess.link), 0, 1000, 5000)
            inst.close()
            info["remote_session_s"] = round(time.time() - t0, 1)
    info["restore_differences"] = {k: (info["original"][k], info.get("restored", {}).get(k)) for k, _ in CHECK
                                   if info["original"][k] != info.get("restored", {}).get(k)}
    print("errors before/during/after:", info.get("errors_before"), "|", info.get("errors_during"), "|",
          info.get("errors_after"))
    print("restore differences:", info["restore_differences"] or "none", "| device_local",
          info["device_local_error"], "| remote", info["remote_session_s"], "s")
    if iq is None or iq.size != n:
        raise SystemExit(f"capture failed: {json.dumps(info)[:2000]}")
    OUT.mkdir(parents=True, exist_ok=True)
    name = OUT / ("FSW_IQ_" + info["start"].replace("-", "").replace(":", "") + ".npz")
    np.savez_compressed(name, iq=iq, fs=a.fs, center_Hz=float(info["settings"]["center_Hz"]), meta=json.dumps(info))
    print("->", name)


if __name__ == "__main__":
    main()
