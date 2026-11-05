"""I/Q capture of the cavity probe on the R&S FSW (complex baseband around f_RF).

DRAFT -- not yet run against the instrument.  Test it on a signal generator before the study
(plan, Section 10).  It follows spear3rf/scripts/fsw_matrix.py: the instrument state is saved
first, the capture runs in a separate I/Q-analyzer channel that is deleted afterwards, the saved
state is reloaded and compared with the original, and the instrument is returned to local
control on every exit path.

Writes data/iq/FSW_IQ_<start>.npz with iq (complex64, V-like units), fs [Hz], center_Hz,
the instrument settings and the paired snapshot name; analyze_iq.py reads it.

usage: python fsw_iq_capture.py [--seconds 16] [--fs 50e3] [--snapshot NAME] [--dry-run]
"""
import argparse
import json
import time
from pathlib import Path

import numpy as np

RES = "TCPIP::172.22.245.99::inst0::INSTR"
STATE = r"C:\R_S\INSTR\USER\optllrf_tmp_state.dfl"
CHANNEL = "OPTLLRF_IQ"
OUT = Path(__file__).resolve().parents[2] / "data" / "iq"
CHECK = (("center_Hz", "FREQ:CENT?"), ("span_Hz", "FREQ:SPAN?"), ("rbw_Hz", "BAND?"), ("ref_level", "DISP:TRAC:Y:RLEV?"),
         ("detector", "DET?"), ("continuous", "INIT:CONT?"), ("application", "INST?"))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--seconds", type=float, default=16.0, help="record length (s)")
    ap.add_argument("--fs", type=float, default=50e3, help="I/Q sample rate (Hz); >= 25 kHz covers +/-12 kHz")
    ap.add_argument("--snapshot", default="", help="name of the paired EPICS snapshot")
    ap.add_argument("--dry-run", action="store_true", help="print the SCPI sequence without connecting")
    a = ap.parse_args()
    n = int(round(a.seconds * a.fs))
    seq = [f"INST:CRE:NEW IQ, '{CHANNEL}'", "FREQ:CENT {centre}", f"TRAC:IQ:SRAT {a.fs:.6g}",
           f"TRAC:IQ:RLEN {n}", "DISP:TRAC:Y:SCAL:RLEV {ref}", "INIT:CONT OFF", "FORM REAL,32",
           "TRAC:IQ:DATA:FORM IQP", "INIT:IMM;*WAI", f"TRAC:IQ:DATA:MEM? 0,{n}", f"INST:DEL '{CHANNEL}'"]
    if a.dry_run:
        print("would save the state to", STATE, "then send:")
        for c in seq:
            print("  ", c)
        print("then reload the state, verify it and return to local control")
        return

    import pyvisa
    rm = pyvisa.ResourceManager("@py")
    inst = rm.open_resource(RES, timeout=20000)
    inst.read_termination = inst.write_termination = "\n"
    q = lambda c: inst.query(c).strip()  # noqa: E731
    info = {"start": time.strftime("%Y-%m-%dT%H:%M:%S"), "signal": "cavity A probe (station SRF1)",
            "paired_epics_snapshot": a.snapshot, "fs": a.fs, "samples": n}
    iq = None
    t0 = time.time()
    try:
        info["original"] = {k: q(c) for k, c in CHECK}
        info["errors_before"] = q("SYST:ERR:ALL?")
        inst.write(f"MMEM:STOR:STAT 1,'{STATE}'")
        q("*OPC?")
        centre, ref = float(info["original"]["center_Hz"]), float(info["original"]["ref_level"])
        for c in seq[:8]:
            inst.write(c.format(centre=f"{centre:.3f}", ref=f"{ref:.2f}"))
        q("*OPC?")
        inst.timeout = int(1000 * (a.seconds + 60))
        inst.write("INIT:IMM")
        q("*OPC?")
        inst.timeout = 120000
        raw = inst.query_binary_values(f"TRAC:IQ:DATA:MEM? 0,{n}", datatype="f", is_big_endian=False,
                                       container=np.array)
        iq = (raw[0::2] + 1j * raw[1::2]).astype(np.complex64)
        info["settings"] = {"center_Hz": q("FREQ:CENT?"), "srate": q("TRAC:IQ:SRAT?"), "rlen": q("TRAC:IQ:RLEN?"),
                            "ref_level": q("DISP:TRAC:Y:SCAL:RLEV?")}
        info["errors_during"] = q("SYST:ERR:ALL?")
    finally:
        try:
            inst.timeout = 60000
            try:
                inst.write(f"INST:DEL '{CHANNEL}'")
                q("*OPC?")
            except Exception as exc:  # noqa: BLE001 - the channel may not exist if creation failed
                info["delete_channel_error"] = str(exc)
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
    if iq is None or iq.size != n:
        raise SystemExit(f"capture failed: {info}")
    OUT.mkdir(parents=True, exist_ok=True)
    name = OUT / ("FSW_IQ_" + info["start"].replace("-", "").replace(":", "") + ".npz")
    np.savez_compressed(name, iq=iq, fs=a.fs, center_Hz=float(info["settings"]["center_Hz"]),
                        meta=json.dumps(info))
    print("errors before/during/after:", info.get("errors_before"), "|", info.get("errors_during"), "|",
          info.get("errors_after"))
    print("restore differences:", info["restore_differences"] or "none")
    print(f"{iq.size} samples at {a.fs:.0f} S/s -> {name}")


if __name__ == "__main__":
    main()
