#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="$ROOT/VIDEO_PROJECTS/Reel_0006/render"
ASSET_DIR="$ROOT/ASSETS/generated"
NARRATION="$ROOT/VIDEO_PROJECTS/Reel_0006/audio/narration.wav"
CAPTIONS="$ROOT/VIDEO_PROJECTS/Reel_0006/reel_0006_captions.ass"
OUT="$OUT_DIR/Reel_0006_Spaced_Repetition_60s.mp4"
mkdir -p "$OUT_DIR"

# Queued assets are nonblocking. Default is the verified local scientific fallback;
# use REEL_USE_QUEUED_IMAGES=1 only for a deliberate rerender after assets resolve.
USE_QUEUED_IMAGES="${REEL_USE_QUEUED_IMAGES:-0}"
pick_scene() {
  local preferred="$1" fallback="$2"
  if [[ "$USE_QUEUED_IMAGES" == "1" ]] && [[ -s "$ASSET_DIR/$preferred" ]] && file "$ASSET_DIR/$preferred" | grep -q 'image'; then
    printf '%s\n' "$ASSET_DIR/$preferred"
  else
    printf '%s\n' "$ASSET_DIR/$fallback"
  fi
}

S1="$(pick_scene reel_0006_scene_01_spacing_reference.png reel_0001_scene_01_reference.png)"
S2="$(pick_scene reel_0006_scene_02_separated_visits.png reel_0001_scene_02_skills.png)"
S3="$(pick_scene reel_0006_scene_03_massed_vs_spaced.png reel_0001_scene_03_research_networks.png)"
S4="$(pick_scene reel_0006_scene_04_adjustable_gap.png reel_0001_scene_04_mri_limitation.png)"
S5="$(pick_scene reel_0006_scene_05_feedback_return.png reel_0001_scene_05_variability.png)"
S6="$(pick_scene reel_0006_scene_06_calm_revisit.png reel_0001_scene_06_takeaway.png)"

ffmpeg -y \
  -loop 1 -t 10 -i "$S1" -loop 1 -t 10 -i "$S2" -loop 1 -t 10 -i "$S3" \
  -loop 1 -t 10 -i "$S4" -loop 1 -t 10 -i "$S5" -loop 1 -t 10.32 -i "$S6" \
  -i "$NARRATION" \
  -filter_complex "[0:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00055,1.12)':d=250:s=720x1280:fps=25,fade=t=in:st=0:d=0.4,fade=t=out:st=9.5:d=0.5[v0];[1:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00045,1.10)':d=250:s=720x1280:fps=25,fade=t=in:st=0:d=0.4,fade=t=out:st=9.5:d=0.5[v1];[2:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.0005,1.11)':d=250:s=720x1280:fps=25,fade=t=in:st=0:d=0.4,fade=t=out:st=9.5:d=0.5[v2];[3:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.0004,1.09)':d=250:s=720x1280:fps=25,fade=t=in:st=0:d=0.4,fade=t=out:st=9.5:d=0.5[v3];[4:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00055,1.12)':d=250:s=720x1280:fps=25,fade=t=in:st=0:d=0.4,fade=t=out:st=9.5:d=0.5[v4];[5:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00045,1.10)':d=258:s=720x1280:fps=25,fade=t=in:st=0:d=0.4,fade=t=out:st=9.82:d=0.5[v5];[v0][v1][v2][v3][v4][v5]concat=n=6:v=1:a=0,subtitles='$CAPTIONS'[v]" \
  -map "[v]" -map 6:a -t 60.32 -r 25 -c:v libx264 -pix_fmt yuv420p -crf 20 -preset medium -c:a aac -b:a 192k -movflags +faststart "$OUT"

ffprobe -v error -show_entries format=duration:stream=codec_name,width,height -of json "$OUT"
