#!/usr/bin/env python3
"""Run deterministic technical QC for a rendered Hindi research reel."""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


def probe(path: Path) -> dict:
    completed = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration:stream=codec_name,codec_type,width,height", "-of", "json", str(path)],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def srt_end_seconds(path: Path) -> float:
    latest = 0.0
    for line in path.read_text(encoding="utf-8").splitlines():
        if " --> " not in line:
            continue
        _start, end = line.split(" --> ", 1)
        hh, mm, ss_ms = end.strip().split(":")
        ss, ms = ss_ms.split(",")
        latest = max(latest, int(hh) * 3600 + int(mm) * 60 + int(ss) + int(ms) / 1000)
    return latest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("video", type=Path)
    parser.add_argument("captions", type=Path)
    parser.add_argument("--min-duration", type=float, default=55.0)
    parser.add_argument("--max-duration", type=float, default=65.0)
    args = parser.parse_args()

    try:
        info = probe(args.video)
        streams = info.get("streams", [])
        video = next(s for s in streams if s.get("codec_type") == "video")
        audio = next(s for s in streams if s.get("codec_type") == "audio")
        duration = float(info["format"]["duration"])
        if video.get("height", 0) <= video.get("width", 0):
            raise ValueError("video is not portrait")
        if abs((video["width"] / video["height"]) - (9 / 16)) > 0.03:
            raise ValueError(f"video aspect ratio is not 9:16: {video['width']}x{video['height']}")
        if not args.min_duration <= duration <= args.max_duration:
            raise ValueError(f"duration outside allowed range: {duration:.3f}s")
        captions_end = srt_end_seconds(args.captions)
        if captions_end > duration + 0.25:
            raise ValueError(f"captions end after video: {captions_end:.3f}s > {duration:.3f}s")
        print(json.dumps({
            "qc": "passed",
            "duration_seconds": round(duration, 3),
            "resolution": f"{video['width']}x{video['height']}",
            "video_codec": video.get("codec_name"),
            "audio_codec": audio.get("codec_name"),
            "captions_end_seconds": captions_end,
        }, sort_keys=True))
    except (subprocess.CalledProcessError, StopIteration, KeyError, ValueError, FileNotFoundError) as exc:
        print(f"qc=failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
