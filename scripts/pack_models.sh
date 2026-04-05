#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
model_dir="$repo_root/models"
part_size_bytes=99614720

command -v zip >/dev/null 2>&1 || {
  echo "zip is required" >&2
  exit 1
}

command -v split >/dev/null 2>&1 || {
  echo "split is required" >&2
  exit 1
}

cd "$repo_root"

sha256sum models/*.gguf > models/SHA256SUMS

find "$model_dir" -maxdepth 1 -type f -name '*.gguf.zip.part-*' -delete
find "$model_dir" -maxdepth 1 -type f -name '*.gguf.zip' -delete
find "$model_dir" -maxdepth 1 -type f -name '*.gguf.br.part-*' -delete
find "$model_dir" -maxdepth 1 -type f -name '*.gguf.br' -delete

find "$model_dir" -maxdepth 1 -type f -name '*.gguf' | sort | while read -r model_path; do
  archive_path="$model_path.zip"
  echo "packing $(basename "$model_path")"
  rm -f "$archive_path"
  (
    cd "$model_dir"
    zip -q -0 "$(basename "$archive_path")" "$(basename "$model_path")"
  )
  split -d -a 3 -b "$part_size_bytes" "$archive_path" "$archive_path.part-"
  rm -f "$archive_path"
done

find "$model_dir" -maxdepth 1 -type f -name '*.gguf' -delete