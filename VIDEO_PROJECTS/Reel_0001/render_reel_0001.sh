#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/ubuntu/3000_HINDI_RESEARCH_REELS"
ASSET_DIR="$ROOT/ASSETS/generated"
PROJECT_DIR="$ROOT/VIDEO_PROJECTS/Reel_0001"
OUTPUT="$PROJECT_DIR/renders/Reel_0001_neuroplasticity_60s.mp4"
CAPTIONS="$PROJECT_DIR/reel_0001_captions.ass"
NARRATION="$PROJECT_DIR/audio/narration.wav"

SCENES=(
  "$ASSET_DIR/reel_0001_scene_01_reference.png"
  "$ASSET_DIR/reel_0001_scene_02_skills.png"
  "$ASSET_DIR/reel_0001_scene_03_research_networks.png"
  "$ASSET_DIR/reel_0001_scene_04_mri_limitation.png"
  "$ASSET_DIR/reel_0001_scene_05_variability.png"
  "$ASSET_DIR/reel_0001_scene_06_takeaway.png"
)

for scene in "${SCENES[@]}" "$CAPTIONS" "$NARRATION"; do
  if [[ ! -s "$scene" ]]; then
    echo "Required production asset is unavailable: $scene" >&2
    exit 1
  fi
done

ffmpeg -y \
  -loop 1 -t 10.1 -i "${SCENES[0]}" \
  -loop 1 -t 10.1 -i "${SCENES[1]}" \
  -loop 1 -t 10.1 -i "${SCENES[2]}" \
  -loop 1 -t 10.1 -i "${SCENES[3]}" \
  -loop 1 -t 10.1 -i "${SCENES[4]}" \
  -loop 1 -t 10.1 -i "${SCENES[5]}" \
  -i "$NARRATION" \
  -filter_complex "
    [0:v]scale=720:1280,zoompan=z='min(zoom+0.00035,1.12)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=303:s=720x1280:fps=30,setsar=1[v0];
    [1:v]scale=720:1280,zoompan=z='min(zoom+0.00030,1.10)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=303:s=720x1280:fps=30,setsar=1[v1];
    [2:v]scale=720:1280,zoompan=z='min(zoom+0.00032,1.11)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=303:s=720x1280:fps=30,setsar=1[v2];
    [3:v]scale=720:1280,zoompan=z='min(zoom+0.00028,1.10)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=303:s=720x1280:fps=30,setsar=1[v3];
    [4:v]scale=720:1280,zoompan=z='min(zoom+0.00036,1.12)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=303:s=720x1280:fps=30,setsar=1[v4];
    [5:v]scale=720:1280,zoompan=z='min(zoom+0.00030,1.10)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=303:s=720x1280:fps=30,setsar=1[v5];
    [v0][v1][v2][v3][v4][v5]concat=n=6:v=1:a=0,subtitles='$CAPTIONS'[video]
  " \
  -map "[video]" -map 6:a:0 \
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \
  -c:a aac -b:a 160k -ar 48000 -shortest \
  -movflags +faststart "$OUTPUT"

ffprobe -v error -show_entries format=duration:stream=codec_name,codec_type,width,height -of json "$OUTPUT"

