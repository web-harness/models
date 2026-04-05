# models

Mirror of browser-safe GGUF model artifacts used for wllama integration in Omni.

## Purpose

This directory exists to keep runtime model delivery under our control instead of depending on live third-party downloads at application startup. For supply-chain purposes, we treat these files as mirrored build artifacts, not as first-party model releases.

GitHub rejects individual blobs above 100 MB, so mirrored model payloads are stored here as split ZIP parts instead of raw `.gguf` binaries. The ZIP archives use `STORE` mode only, with compression disabled. Restored local `.gguf` files are ignored by Git.

## Upstream provenance

The current mirrored files were sourced from Hugging Face on 2026-04-05:

- `LFM2-1.2B-Q4_K_M.gguf`
	- upstream publisher: `LiquidAI`
	- upstream repository: `LiquidAI/LFM2-1.2B-GGUF`
	- upstream file: `LFM2-1.2B-Q4_K_M.gguf`
	- note: an older catalog entry referenced `lmstudio-community/LFM2-1.2B-GGUF`, but that path no longer resolved at download time
- `DeepSeek-R1-Distill-Qwen-1.5B-Q3_K_M.gguf`
	- upstream publisher: `bartowski`
	- upstream repository: `bartowski/DeepSeek-R1-Distill-Qwen-1.5B-GGUF`
	- upstream file: `DeepSeek-R1-Distill-Qwen-1.5B-Q3_K_M.gguf`

## Hosting and supply-chain posture

We host these exact GGUF artifacts from this repository so application consumers fetch a pinned local copy rather than resolving a mutable upstream URL at runtime.

This improves supply-chain control in these ways:

- runtime availability does not depend on Hugging Face being reachable
- upstream repository renames, removals, or file swaps do not immediately change what the application serves
- releases can review and promote a known file set instead of downloading models ad hoc on end-user machines

## Artifact layout

- raw `.gguf` files are wrapped in `.gguf.zip` archives using ZIP `STORE`
- mirrored payloads are stored as `*.gguf.zip.part-*`
- `models/SHA256SUMS` records the expected SHA-256 for the restored raw `.gguf` files
- `scripts/pack_models.sh` wraps raw `.gguf` files in ZIP `STORE` archives, splits the archives into sub-100 MB parts, refreshes `SHA256SUMS`, and removes the raw `.gguf` files from the working tree
- `scripts/unpack_models.sh` reassembles the split parts, extracts the ZIP archives, and verifies the restored files against `SHA256SUMS`

## Disclaimers

- These models are third-party artifacts. Mirroring them here does not imply we authored, trained, or audited them.
- Local hosting reduces operational and dependency risk, but it is not a complete software supply-chain guarantee by itself.
- Unless hashes or signatures are recorded elsewhere in release metadata, this repository alone does not provide cryptographic provenance.
- Upstream model behavior, quality, safety characteristics, and licensing remain the responsibility of the original publishers.
- Any model update should be treated as a supply-chain event: re-verify source, license, file name, size, and hashes before replacing the mirrored artifact.

## Restoring local model files

Run:

```sh
bash scripts/unpack_models.sh
```

This requires the `unzip` CLI to be installed locally.

## Repacking model files

If you restore the raw `.gguf` files locally and need to regenerate the mirrored artifacts, run:

```sh
bash scripts/pack_models.sh
```

This repackages both models into ZIP `STORE` archives, splits each archive into sub-100 MB parts, updates `models/SHA256SUMS`, and deletes the restored raw `.gguf` files afterward.
