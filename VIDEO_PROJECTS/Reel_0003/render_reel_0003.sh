#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ASSETS="$ROOT/ASSETS/generated"
PROJECT="$ROOT/VIDEO_PROJECTS/Reel_0003"
OUT="$PROJECT/renders/Reel_0003_if_then_planning_60s.mp4"
mkdir -p "$(dirname "$OUT")"

choose_scene() {
  local primary="$1"
  local fallback="$2"
  if [[ -s "$primary" ]]; then
    printf '%s\n' "$primary"
  elif [[ -s "$fallback" ]]; then
    printf '%s\n' "$fallback"
  else
    echo "Neither primary nor verified fallback scene is available: $primary | $fallback" >&2
    exit 3
  fi
}

SCENES=(
  "$(choose_scene "$ASSETS/reel_0003_scene_01_if_then_reference.png" "$ASSETS/reel_0001_scene_01_reference.png")"
  "$(choose_scene "$ASSETS/reel_0003_scene_02_plan_card.png" "$ASSETS/reel_0001_scene_02_skills.png")"
  "$(choose_scene "$ASSETS/reel_0003_scene_03_cue_response.png" "$ASSETS/reel_0001_scene_03_research_networks.png")"
  "$(choose_scene "$ASSETS/reel_0003_scene_04_action_support.png" "$ASSETS/reel_0001_scene_04_mri_limitation.png")"
  "$(choose_scene "$ASSETS/reel_0003_scene_05_obstacle.png" "$ASSETS/reel_0001_scene_05_variability.png")"
  "$(choose_scene "$ASSETS/reel_0003_scene_06_takeaway.png" "$ASSETS/reel_0001_scene_06_takeaway.png")"
)

ffmpeg -y \
  -loop 1 -t 9.96 -i "${SCENES[0]}" \
  -loop 1 -t 9.96 -i "${SCENES[1]}" \
  -loop 1 -t 9.96 -i "${SCENES[2]}" \
  -loop 1 -t 9.96 -i "${SCENES[3]}" \
  -loop 1 -t 9.96 -i "${SCENES[4]}" \
  -loop 1 -t 9.96 -i "${SCENES[5]}" \
  -i "$PROJECT/audio/narration.wav" \
  -filter_complex "
    [0:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00025,1.08)':d=265:s=720x1280:fps=30[v0];
    [1:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00025,1.08)':d=265:s=720x1280:fps=30[v1];
    [2:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00025,1.08)':d=265:s=720x1280:fps=30[v2];
    [3:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00025,1.08)':d=265:s=720x1280:fps=30[v3];
    [4:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00025,1.08)':d=265:s=720x1280:fps=30[v4];
    [5:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00025,1.08)':d=265:s=720x1280:fps=30[v5];
    [v0][v1][v2][v3][v4][v5]concat=n=6:v=1:a=0,subtitles='$PROJECT/reel_0003_captions.ass':fontsdir=/usr/share/fonts/truetype/noto[v]" \
  -map "[v]" -map 6:a -t 59.76 -r 30 -c:v libx264 -crf 20 -preset medium -pix_fmt yuv420p \
  -c:a aac -b:a 160k -movflags +faststart "$OUT"

ffprobe -v error -show_entries format=duration:stream=codec_type,width,height -of json "$OUT"
