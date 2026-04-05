#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
model_dir="$repo_root/models"

command -v unzip >/dev/null 2>&1 || {
  echo "unzip is required" >&2
  exit 1
}

find "$model_dir" -maxdepth 1 -type f -name '*.gguf.zip.part-000' | sort | while read -r first_part; do
  output_path="${first_part%.zip.part-000}"
  archive_path="$output_path.zip"
  echo "restoring $(basename "$output_path")"
  cat "${output_path}.zip.part-"* > "$archive_path"
  unzip -oq "$archive_path" -d "$model_dir"
  rm -f "$archive_path"
done

cd "$repo_root"
sha256sum -c models/SHA256SUMS