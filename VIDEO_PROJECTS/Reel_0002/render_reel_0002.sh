#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ASSETS="$ROOT/ASSETS/generated"
PROJECT="$ROOT/VIDEO_PROJECTS/Reel_0002"
OUT="$PROJECT/renders/Reel_0002_habit_formation_60s.mp4"
mkdir -p "$PROJECT/renders"

for image in \
  reel_0002_scene_01_habit_reference.png \
  reel_0001_scene_01_reference.png \
  reel_0001_scene_05_variability.png \
  reel_0001_scene_02_skills.png \
  reel_0001_scene_03_research_networks.png \
  reel_0001_scene_06_takeaway.png; do
  test -s "$ASSETS/$image" || { echo "Missing generated scene: $image" >&2; exit 1; }
done

ffmpeg -y \
  -loop 1 -t 9.5 -i "$ASSETS/reel_0002_scene_01_habit_reference.png" \
  -loop 1 -t 9.5 -i "$ASSETS/reel_0001_scene_01_reference.png" \
  -loop 1 -t 9.5 -i "$ASSETS/reel_0001_scene_05_variability.png" \
  -loop 1 -t 9.5 -i "$ASSETS/reel_0001_scene_02_skills.png" \
  -loop 1 -t 9.5 -i "$ASSETS/reel_0001_scene_03_research_networks.png" \
  -loop 1 -t 9.5 -i "$ASSETS/reel_0001_scene_06_takeaway.png" \
  -i "$PROJECT/audio/narration.wav" \
  -filter_complex "\
    [0:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00045,1.12)':d=285:s=720x1280:fps=30[v0];\
    [1:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00040,1.12)':d=285:s=720x1280:fps=30[v1];\
    [2:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00042,1.12)':d=285:s=720x1280:fps=30[v2];\
    [3:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00042,1.12)':d=285:s=720x1280:fps=30[v3];\
    [4:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00040,1.12)':d=285:s=720x1280:fps=30[v4];\
    [5:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00038,1.12)':d=285:s=720x1280:fps=30[v5];\
    [v0][v1][v2][v3][v4][v5]concat=n=6:v=1:a=0,subtitles='$PROJECT/reel_0002_captions.ass'[video]" \
  -map "[video]" -map 6:a -shortest \
  -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -movflags +faststart \
  -c:a aac -b:a 160k "$OUT"

ffprobe -v error -show_entries stream=codec_name,codec_type,width,height -show_entries format=duration -of json "$OUT"
