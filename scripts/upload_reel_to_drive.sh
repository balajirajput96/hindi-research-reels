#!/usr/bin/env bash
# Upload a QC-passed reel bundle to an existing Drive batch folder and verify
# every returned file ID. This script performs Drive writes; invoke only after
# an explicit upload confirmation in the active task.
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <batch-folder-id> <reel-id> <reel-directory> <receipt-path>" >&2
  exit 2
fi

batch_folder_id="$1"
reel_id="$2"
reel_dir="$(cd "$3" && pwd)"
receipt_path="$4"

for required in "script.md" "captions.srt" "metadata.json" "reel.mp4"; do
  if [[ ! -s "$reel_dir/$required" ]]; then
    echo "Missing required QC-passed artifact: $reel_dir/$required" >&2
    exit 1
  fi
done

upload_and_verify() {
  local source_path="$1"
  local content_type="$2"
  local payload response file_id verified
  payload="$(jq -nc --arg name "$(basename "$source_path")" --arg parent "$batch_folder_id" '{name:$name,parents:[$parent]}')"
  response="$(gws drive files create --upload "$source_path" --upload-content-type "$content_type" --json "$payload")"
  file_id="$(printf '%s' "$response" | jq -r '.id // empty')"
  if [[ -z "$file_id" ]]; then
    echo "Drive upload did not return an ID for $source_path" >&2
    exit 1
  fi
  verified="$(gws drive files get --params "$(jq -nc --arg id "$file_id" '{fileId:$id,fields:"id,name,mimeType,size,parents,trashed,webViewLink"}')")"
  if [[ "$(printf '%s' "$verified" | jq -r '.id // empty')" != "$file_id" ]]; then
    echo "Drive verification failed for $source_path" >&2
    exit 1
  fi
  printf '%s' "$verified"
}

video="$(upload_and_verify "$reel_dir/reel.mp4" "video/mp4")"
script="$(upload_and_verify "$reel_dir/script.md" "text/markdown")"
captions="$(upload_and_verify "$reel_dir/captions.srt" "application/x-subrip")"
metadata="$(upload_and_verify "$reel_dir/metadata.json" "application/json")"

jq -n \
  --arg reel_id "$reel_id" \
  --arg batch_folder_id "$batch_folder_id" \
  --arg uploaded_at "$(date -u +%FT%TZ)" \
  --argjson video "$video" \
  --argjson script "$script" \
  --argjson captions "$captions" \
  --argjson metadata "$metadata" \
  '{reel_id:$reel_id,batch_folder_id:$batch_folder_id,uploaded_at:$uploaded_at,files:{video:$video,script:$script,captions:$captions,metadata:$metadata}}' > "$receipt_path"

printf 'drive_upload=verified reel=%s video_id=%s\n' "$reel_id" "$(printf '%s' "$video" | jq -r '.id')"
