"""Decode RSLogix 5 project files (.RSP) into plain-text ladder listings.

usage: python rsp_decode.py [-o OUTDIR] [-s SYMBOLS.RSP] FILE.RSP [FILE.RSP ...]

Reads the "PROGRAM FILES" (ladder) and "MEM DATABASE" (symbols, descriptions, rung comments)
streams of the OLE2 project file. Needs the olefile package. The listings go to ./decoded next to
this script unless -o is given. -s fills in symbols a project lacks from another project of the
same program.
"""
import argparse
import os
import re
import struct
import zlib

import olefile

# Instruction codes inferred from the operand patterns in the SPEAR3 RF MPS projects.
MNEMONIC = {
    0x00: "XIC", 0x01: "XIO", 0x02: "OTL", 0x03: "OTU", 0x04: "OTE", 0x08: "CPT",
    0x0A: "TON", 0x9A: "TON", 0x9B: "TOF", 0x0D: "CTU", 0x0F: "RES", 0x14: "COP",
    0x15: "FLL", 0x25: "JSR", 0x27: "RET", 0x28: "BTR", 0x29: "BTW", 0x2B: "AFI",
    0x32: "ADD", 0x33: "SUB", 0x3D: "FRD", 0x3F: "EQU", 0x41: "LES", 0x42: "GRT",
    0x43: "LEQ", 0x44: "GEQ", 0x95: "END",
}
MARKERS = {0x96, 0x97, 0x98, 0x99}
VALUE_PAIRS = {0x32, 0x33, 0x3D, 0x3F, 0x41, 0x42, 0x43, 0x44}
# Index of the written operand, counted after the block-transfer labels are dropped.
DEST = {0x02: 0, 0x03: 0, 0x04: 0, 0x08: 0, 0x0A: 0, 0x9A: 0, 0x9B: 0, 0x0D: 0, 0x0F: 0,
        0x14: 1, 0x15: 1, 0x32: 4, 0x33: 4, 0x3D: 2, 0x28: 3, 0x29: 3}
STD_TAIL = bytes.fromhex("000096000000000000000000")
DEFAULT_FILE = {"O": 0, "I": 1, "S": 2}

OPERAND = re.compile(r"^#?(?:(?P<t>[A-Z]{1,2})(?P<f>\d*):(?P<e>\d+)(?:[./](?P<b>\w+))?"
                     r"|B(?P<bf>\d+)/(?P<bb>\d+))$")
DB_KEY = re.compile(rb"[A-Z]{1,3}\d{4}:\d{4}(?:/\d{2})?|DFILE:\d{5}")


def read_stream(ole, name):
    raw = ole.openstream(name).read()
    flag, _, size, _ = struct.unpack_from("<4I", raw)
    body = raw[16:16 + size]
    return zlib.decompress(body) if flag else body


class Archive:
    """Minimal reader for the MFC CArchive object stream."""

    def __init__(self, data, pos, count):
        self.d, self.p, self.count, self.classes = data, pos, count, {}

    def u8(self):
        self.p += 1
        return self.d[self.p - 1]

    def u16(self):
        self.p += 2
        return struct.unpack_from("<H", self.d, self.p - 2)[0]

    def raw(self, n):
        self.p += n
        return self.d[self.p - n:self.p]

    def s8(self):
        return self.raw(self.u8()).decode("latin-1")

    def obj(self):
        at = self.p
        tag = self.u16()
        if tag == 0xFFFF:
            self.u16()
            name = self.raw(self.u16()).decode("latin-1")
            self.classes[self.count] = name
            self.count += 1
        elif tag & 0x8000 and (tag & 0x7FFF) in self.classes:
            name = self.classes[tag & 0x7FFF]
        elif tag == 0:
            return None
        else:
            raise ValueError("unexpected object tag %04x at offset %06x" % (tag, at))
        self.count += 1
        if name not in PARSERS:
            raise ValueError("no parser for class %s at offset %06x" % (name, at))
        return PARSERS[name](self)


def p_ins(a):
    ops = [a.s8() for _ in range(a.u16())]
    assembled = a.u16()
    code = a.u16()
    if assembled == 1:
        if ops:
            a.raw(a.u16())
        else:
            a.u16()
    return ("INS", code, ops, assembled)


def p_leg(a):
    return ("LEG", [a.obj() for _ in range(a.u16())])


def p_branch(a):
    objs = [a.obj() for _ in range(a.u16())]
    return ("BRANCH", [o for o in objs if o[0] == "LEG"])


def p_rung(a):
    leg = a.obj()
    return ("RUNG", leg, a.raw(12))


def p_ladfile(a):
    num = a.u16()
    a.raw(14)  # size and flag fields, not decoded
    name = a.s8()
    desc = a.s8()
    rungs = [a.obj() for _ in range(a.u16())]
    return ("LAD", num, name, desc, rungs)


def p_progfile(a):
    num = a.u16()
    a.raw(16)  # size and flag fields, not decoded
    return ("EMPTY", num)


PARSERS = {"CIns": p_ins, "CBranchLeg": p_leg, "CBranch": p_branch, "CRung": p_rung,
           "CLadFile": p_ladfile, "CProgFile": p_progfile}


def parse_program(data):
    start = data.find(b"\x08\x00CLadFile") - 4
    if start < 0:
        raise ValueError("no ladder file in the program stream")
    # Each class defined ahead of the first ladder file carries exactly one object.
    before = re.findall(rb"\xff\xff..([\x01-\x20])\x00(C[A-Za-z0-9]+)", data[:start], re.S)
    a = Archive(data, start, 1 + 2 * len(before))
    for i, (n, name) in enumerate(before):
        a.classes[1 + 2 * i] = name[:n[0]].decode("latin-1")
    files = []
    while a.p < len(data):
        o = a.obj()
        if o is None:
            break
        files.append(o)
    if any(data[a.p:]):
        raise ValueError("program stream not fully decoded: stopped at %06x of %06x"
                         % (a.p, len(data)))
    return files


def parse_symbols(data):
    """Return {key: (symbol, description)}; an entry is key, symbol, five description lines."""
    out, p = {}, 0
    while p < len(data):
        n = data[p]
        key = data[p + 1:p + 1 + n]
        if 6 <= n <= 16 and DB_KEY.fullmatch(key):
            q, fields = p + 1 + n, []
            while len(fields) < 6 and q < len(data):
                k = data[q]
                fields.append(data[q + 1:q + 1 + k].decode("latin-1").strip())
                q += 1 + k
            if len(fields) == 6 and q <= len(data):
                out[key.decode()] = (fields[0], " ".join(f for f in fields[1:] if f))
                p = q
                continue
        p += 1
    return out


def parse_comments(data):
    """Return {key: text} for rung comments, which are keyed by the rung's output address."""
    out = {}
    for m in re.finditer(rb"[\x20-\x7e]{21,}", data):
        s, e = m.span()
        for t0 in (s, s + 1):
            n = data[e + 1] if e + 1 < len(data) else 0
            key = data[e + 2:e + 2 + n]
            if data[t0 - 1] == e - t0 and data[e:e + 1] == b"\x00" and DB_KEY.fullmatch(key):
                out[key.decode()] = data[t0:e].decode("latin-1")
    return out


def display(key):
    if key.startswith("DFILE:"):
        return "file %d" % int(key[6:])
    t, f, e, b = re.match(r"([A-Z]{1,3})(\d{4}):(\d{4})(?:/(\d{2}))?$", key).groups()
    if t in ("I", "O"):
        s = "%s:%s" % (t, e[1:])
    elif t == "S":
        s = "S:%d" % int(e)
    else:
        s = "%s%d:%d" % (t, int(f), int(e))
    return s if b is None else "%s/%s" % (s, b.lstrip("0") or "0")


def db_keys(op):
    """Database keys for an operand, bit-level first, e.g. I:031/1 -> I0001:0031/01, I0001:0031."""
    m = OPERAND.match(op)
    if not m:
        return []
    if m.group("bf"):
        n = int(m.group("bb"))
        return ["B%04d:%04d/%02d" % (int(m.group("bf")), n // 16, n % 16)]
    t, f, b = m.group("t"), m.group("f"), m.group("b")
    fnum = int(f) if f else DEFAULT_FILE.get(t)
    if fnum is None:
        return []
    word = "%s%04d:%s" % (t, fnum, m.group("e").zfill(4))
    return ([word + "/" + b.zfill(2)] if b and b.isdigit() else []) + [word]


def symbol_of(op, symbols):
    for k in db_keys(op):
        if symbols.get(k, ("", ""))[0]:
            return symbols[k][0]
    return ""


def addr(op, symbols):
    s = symbol_of(op, symbols)
    return "%s <%s>" % (op, s) if s else op


def render_ins(ins, symbols, names):
    _, code, ops, assembled = ins
    name = MNEMONIC.get(code, "OP%02X" % code)
    ops = [o for o in ops if o not in ("Generic Block Transfer", "Setup Screen")]
    if code in VALUE_PAIRS and len(ops) % 2 == 0:
        args = ["%s [%s]" % (addr(o, symbols), v) if ":" in o else o
                for o, v in zip(ops[0::2], ops[1::2])]
    elif code == 0x08 and len(ops) == 3:
        args = ["%s [%s]" % (addr(ops[0], symbols), ops[1]), ops[2]]
    elif code in (0x0A, 0x9A, 0x9B) and len(ops) == 4:
        args = [addr(ops[0], symbols), "base %s" % ops[1], "PRE %s" % ops[2], "ACC [%s]" % ops[3]]
    elif code == 0x0D and len(ops) == 3:
        args = [addr(ops[0], symbols), "PRE %s" % ops[1], "ACC [%s]" % ops[2]]
    elif code in (0x28, 0x29) and len(ops) >= 7:
        args = ["rack %s group %s module %s" % tuple(ops[0:3]), addr(ops[3], symbols), ops[4],
                "length %s" % ops[5], "continuous %s" % ops[6]]
    elif code == 0x25 and ops:
        n = ops[0].split(":")[-1]
        target = names.get(int(n)) if n.isdigit() else None
        args = ["%s <%s>" % (ops[0], target) if target else ops[0]]
    else:
        args = [addr(o, symbols) for o in ops if o]
    text = name + ("(" + ", ".join(args) + ")" if args else "")
    return text + (" [unassembled]" if assembled == 0 and ops else "")


def render_leg(leg, symbols, names):
    parts = []
    for e in leg[1]:
        if e[0] == "BRANCH":
            legs = [render_leg(sub, symbols, names) for sub in e[1]]
            parts.append("BST " + " NXB ".join(legs) + " BND")
        elif e[1] not in MARKERS:
            parts.append(render_ins(e, symbols, names))
    return " ".join(parts)


def output_keys(leg):
    """Database keys of the addresses a rung writes."""
    keys = set()
    for e in leg[1]:
        if e[0] == "BRANCH":
            for sub in e[1]:
                keys |= output_keys(sub)
        elif e[1] in DEST:
            ops = [o for o in e[2] if o not in ("Generic Block Transfer", "Setup Screen")]
            if len(ops) > DEST[e[1]]:
                keys |= set(db_keys(ops[DEST[e[1]]]))
    return keys


def decode(path, out_path, borrowed=None):
    ole = olefile.OleFileIO(path)
    try:
        files = parse_program(read_stream(ole, "PROGRAM FILES/ObjectData"))
        mem = read_stream(ole, "MEM DATABASE/ObjectData")
    finally:
        ole.close()
    own = {k: v for k, v in parse_symbols(mem).items() if v[0] or v[1]}
    symbols = dict(borrowed[1]) if borrowed else {}
    symbols.update(own)
    comments = parse_comments(mem)
    used = set()
    names = {f[1]: f[2] for f in files if f[0] == "LAD"}
    n_rungs = sum(len(f[4]) for f in files if f[0] == "LAD")
    lines = [
        "RSLogix 5 project %s, decoded by rsp_decode.py." % os.path.basename(path),
        "",
        "Notation: rungs are numbered from 0; BST ... NXB ... BND is a parallel branch;",
        "ADDRESS <SYMBOL>; [value] is the data-table value saved in the file",
        "(a snapshot, not live); [unassembled] marks an edit saved but not accepted.",
        "",
        "Program files (%d ladder rungs):" % n_rungs,
    ]
    if borrowed and set(borrowed[1]) - set(own):
        note = "Symbols and descriptions this file lacks are taken from %s." % borrowed[0]
        lines[5:5] = ["", note]
    for f in files:
        if f[0] == "LAD":
            lines.append("  %3d  %-12s %4d rungs%s" % (f[1], f[2], len(f[4]),
                                                        "  " + f[3] if f[3] else ""))
        else:
            lines.append("  %3d  (empty)" % f[1])
    for f in files:
        if f[0] != "LAD":
            continue
        lines += ["", "=== File %d %s (%d rungs)" % (f[1], f[2], len(f[4]))]
        for i, rung in enumerate(f[4]):
            for key in sorted(output_keys(rung[1]) & set(comments)) if rung[1] else ():
                lines.append("       ; %s" % comments[key])
                used.add(key)
            text = render_leg(rung[1], symbols, names) if rung[1] else ""
            flag = "" if rung[2] == STD_TAIL else "   ; rung in an edit zone"
            lines.append("  %03d  %s%s" % (i, text, flag))
    if set(comments) - used:
        lines += ["", "Rung comments not matched to a rung:"]
        lines += ["  %-14s %s" % (display(k), comments[k]) for k in sorted(set(comments) - used)]
    lines += ["", "Symbols and descriptions (standard status-file descriptions omitted):"]
    for key, (sym, desc) in symbols.items():
        if key.startswith("S0002") and not sym:
            continue
        lines.append("  %-14s %-16s %s" % (display(key), sym, desc))
    with open(out_path, "w", encoding="utf-8", newline="\n") as fo:
        fo.write("\n".join(lines) + "\n")
    return len(names), n_rungs


def load_symbols(path):
    ole = olefile.OleFileIO(path)
    try:
        mem = read_stream(ole, "MEM DATABASE/ObjectData")
    finally:
        ole.close()
    return os.path.basename(path), {k: v for k, v in parse_symbols(mem).items() if v[0] or v[1]}


def main():
    ap = argparse.ArgumentParser(description="Decode RSLogix 5 .RSP projects to text listings.")
    ap.add_argument("files", nargs="+", help=".RSP project files")
    ap.add_argument("-o", "--outdir",
                    default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "decoded"))
    ap.add_argument("-s", "--symbols", help="take missing symbols and descriptions from this .RSP")
    args = ap.parse_args()
    os.makedirs(args.outdir, exist_ok=True)
    borrowed = load_symbols(args.symbols) if args.symbols else None
    for path in args.files:
        out = os.path.join(args.outdir, os.path.splitext(os.path.basename(path))[0] + ".txt")
        n_files, n_rungs = decode(path, out, borrowed)
        print("%s -> %s (%d ladder files, %d rungs)" % (path, out, n_files, n_rungs))


if __name__ == "__main__":
    main()
