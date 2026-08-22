#!/usr/bin/env python3
"""Validate the persistent state and asset contract for Hindi research reels."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

REQUIRED_QC_GATES = {
    "claim_to_source_match",
    "content_production",
    "drive_upload",
}


def fail(message: str) -> None:
    raise ValueError(message)


def validate(root: Path, require_drive: bool) -> dict[str, object]:
    state_path = root / "catalog" / "production_state.json"
    try:
        state = json.loads(state_path.read_text())
    except FileNotFoundError:
        fail(f"missing state file: {state_path}")
    except json.JSONDecodeError as exc:
        fail(f"invalid JSON in state file: {exc}")

    if state.get("project") != "3000_HINDI_RESEARCH_REELS":
        fail("unexpected project identifier")
    if state.get("catalog", {}).get("total_reels") != 3000:
        fail("catalog must declare exactly 3000 reels")
    if state.get("catalog", {}).get("batch_size") != 30:
        fail("catalog must use batches of 30 reels")
    if state.get("catalog", {}).get("batch_count") != 100:
        fail("catalog must declare 100 batches")

    reels = state.get("reels")
    if not isinstance(reels, dict) or not reels:
        fail("state must contain at least one reel record")

    for reel_id, record in reels.items():
        if not isinstance(reel_id, str) or len(reel_id) != 4 or not reel_id.isdigit():
            fail(f"invalid reel identifier: {reel_id}")
        if not isinstance(record, dict):
            fail(f"reel {reel_id} is not an object")
        for key in ("batch", "track", "working_title_hi", "status", "research_file", "qc"):
            if not record.get(key):
                fail(f"reel {reel_id} missing {key}")
        research_path = root / str(record["research_file"])
        if not research_path.is_file():
            fail(f"reel {reel_id} research file is missing: {research_path}")
        qc = record["qc"]
        if not isinstance(qc, dict) or not REQUIRED_QC_GATES.issubset(qc):
            fail(f"reel {reel_id} has an incomplete QC record")
        if record["status"] == "complete":
            if qc.get("content_production") != "passed" or qc.get("drive_upload") != "passed":
                fail(f"complete reel {reel_id} does not have passed production and upload QC")
            if not record.get("drive_file_id") or not record.get("drive_metadata_file_id"):
                fail(f"complete reel {reel_id} lacks verified Drive IDs")
        if require_drive and record["status"] != "complete":
            fail(f"reel {reel_id} has not completed required Drive delivery")

    checkpoint = state.get("last_checkpoint", {})
    if checkpoint.get("current_reel") not in reels:
        fail("checkpoint current_reel must be present in the reel records")
    return {
        "reels_tracked": len(reels),
        "current_reel": checkpoint["current_reel"],
        "drive_required": require_drive,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--require-drive", action="store_true")
    args = parser.parse_args()
    try:
        result = validate(args.root.resolve(), args.require_drive)
    except ValueError as exc:
        print(f"reel_state=failed: {exc}", file=sys.stderr)
        return 1
    print(json.dumps({"reel_state": "passed", **result}, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
