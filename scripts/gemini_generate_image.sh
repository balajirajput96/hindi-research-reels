#!/usr/bin/env bash
# Generate one image using an already authorized Gemini image model.
# Usage: gemini_generate_image.sh OUTPUT.png PROMPT.txt [REFERENCE.png]
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 OUTPUT.png PROMPT.txt [REFERENCE.png]" >&2
  exit 64
fi

output_path="$1"
prompt_path="$2"
reference_path="${3:-}"
model_name="${GEMINI_IMAGE_MODEL:-gemini-2.5-flash-image}"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "GEMINI_API_KEY is not available in the runtime." >&2
  exit 65
fi
if [[ ! -s "$prompt_path" ]]; then
  echo "Prompt file is missing or empty: $prompt_path" >&2
  exit 66
fi

prompt_text="$(cat "$prompt_path")"
if [[ -n "$reference_path" ]]; then
  if [[ ! -s "$reference_path" ]]; then
    echo "Reference image is missing or empty: $reference_path" >&2
    exit 67
  fi
  reference_b64="$(base64 -w 0 "$reference_path")"
  jq -n --arg prompt "$prompt_text" --arg ref "$reference_b64" '{contents:[{role:"user",parts:[{text:$prompt},{inlineData:{mimeType:"image/png",data:$ref}}]}],generationConfig:{responseModalities:["TEXT","IMAGE"],imageConfig:{aspectRatio:"9:16"}}}' > "$work_dir/request.json"
else
  jq -n --arg prompt "$prompt_text" '{contents:[{role:"user",parts:[{text:$prompt}]}],generationConfig:{responseModalities:["TEXT","IMAGE"],imageConfig:{aspectRatio:"9:16"}}}' > "$work_dir/request.json"
fi

curl -sS --fail-with-body \
  -H 'Content-Type: application/json' \
  -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/${model_name}:generateContent?key=${GEMINI_API_KEY}" \
  -d @"$work_dir/request.json" > "$work_dir/response.json"

jq -r '[.candidates[]?.content.parts[]? | select(.inlineData?.data) | .inlineData.data][0] // empty' "$work_dir/response.json" | base64 -d > "$output_path"
if [[ ! -s "$output_path" ]]; then
  echo "Gemini returned no image data. Response follows:" >&2
  cat "$work_dir/response.json" >&2
  exit 68
fi

file "$output_path"
