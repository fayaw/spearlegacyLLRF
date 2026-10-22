"""Read the live legacy RF station (caget only) and print its performance summary.

    python scripts/live_status.py                      # read live, print
    python scripts/live_status.py --save data/snapshots
    python scripts/live_status.py --load data/snapshots/<file>.json
"""
import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from spear3rf.live import Snapshot, analyze, read_snapshot, report  # noqa: E402

ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
ap.add_argument("--load", help="analyse a saved snapshot instead of reading EPICS")
ap.add_argument("--save", help="directory to store the snapshot JSON")
ap.add_argument("--timeout", type=float, default=3.0)
args = ap.parse_args()

snap = Snapshot.load(args.load) if args.load else read_snapshot(timeout=args.timeout)
if snap.missing:
    print("not connected:", ", ".join(snap.missing))
if args.save:
    name = f"{snap.station}_{snap.time.replace(':', '').replace('-', '')}.json"
    print("saved", snap.save(Path(args.save) / name))
print(report(analyze(snap)))
