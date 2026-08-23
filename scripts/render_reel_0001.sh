#!/usr/bin/env bash
# Build Reel 0001 from AI-generated editorial stills, deterministic motion,
# final Hindi narration, and source-aligned captions. This is motion-graphics
# assembly, not a claim of full generative-video animation.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
reel_dir="$root/reels/Reel_0001"
work_dir="$reel_dir/render_work"
output="$reel_dir/reel.mp4"
caption_file="$reel_dir/captions_final.srt"
audio_file="$reel_dir/narration.wav"

mkdir -p "$work_dir"
rm -f "$work_dir"/segment_*.mp4 "$work_dir"/concat.txt "$work_dir"/visual_track.mp4

render_segment() {
  local input="$1"
  local duration="$2"
  local output_path="$3"
  local frames
  frames="$(awk -v seconds="$duration" 'BEGIN { printf "%d", seconds * 30 }')"
  ffmpeg -y -v error -loop 1 -framerate 30 -t "$duration" -i "$input" \
    -vf "scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,zoompan=z='min(zoom+0.00028,1.08)':x='iw/2-(iw/zoom/2)+sin(on/24)*6':y='ih/2-(ih/zoom/2)+cos(on/30)*4':d=${frames}:s=720x1280:fps=30,fade=t=in:st=0:d=0.28,fade=t=out:st=$(awk -v seconds="$duration" 'BEGIN { printf "%.2f", seconds - 0.28 }'):d=0.28,format=yuv420p" \
    -an -c:v libx264 -preset medium -crf 18 -movflags +faststart "$output_path"
}

render_segment "$reel_dir/visual_reference.png" 7 "$work_dir/segment_01.mp4"
render_segment "$reel_dir/visual_02_cue.png" 9 "$work_dir/segment_02.mp4"
render_segment "$reel_dir/visual_03_automaticity.png" 10 "$work_dir/segment_03.mp4"
render_segment "$reel_dir/visual_04_variability.png" 11 "$work_dir/segment_04.mp4"
render_segment "$reel_dir/visual_05_no_deadline.png" 10 "$work_dir/segment_05.mp4"
render_segment "$reel_dir/visual_06_takeaway.png" 10 "$work_dir/segment_06.mp4"

for segment in "$work_dir"/segment_*.mp4; do
  printf "file '%s'\n" "$segment"
done > "$work_dir/concat.txt"

ffmpeg -y -v error -f concat -safe 0 -i "$work_dir/concat.txt" -c copy "$work_dir/visual_track.mp4"

ffmpeg -y -v error -i "$work_dir/visual_track.mp4" -i "$audio_file" \
  -vf "subtitles=$caption_file:force_style='FontName=Noto Sans Devanagari,FontSize=36,Alignment=2,MarginV=150,Outline=3,Shadow=1,PrimaryColour=&H00FFFFFF,OutlineColour=&H90000000'" \
  -map 0:v:0 -map 1:a:0 -shortest -r 30 \
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart "$output"

printf 'rendered=%s\n' "$output"
