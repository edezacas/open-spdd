#!/usr/bin/env bash
# Diffs the SPDD guard-hook JSON block and the subagentPromptCacheTtl line
# across spdd-canvas/assets/hook-setup.md, spdd-implement/assets/hook-setup.md,
# and spdd-verify/assets/hook-setup.md.
# Fails with a clear message if any of the three copies has drifted.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FILES=(
  "$REPO_ROOT/spdd-canvas/assets/hook-setup.md"
  "$REPO_ROOT/spdd-implement/assets/hook-setup.md"
  "$REPO_ROOT/spdd-verify/assets/hook-setup.md"
)

extract_json_block() {
  # Prints the fenced ```json ... ``` block that contains the guard-hook
  # matcher, or nothing if no such block exists in the file.
  local file="$1"
  awk '
    /^[[:space:]]*```json[[:space:]]*$/ { in_fence=1; buf=""; next }
    /^[[:space:]]*```[[:space:]]*$/ { if (in_fence) { in_fence=0; if (buf ~ /"matcher": "Edit\|Write"/) { print buf; found=1 } }; next }
    in_fence { buf = buf $0 "\n" }
    END { if (!found) exit 1 }
  ' "$file"
}

extract_ttl_line() {
  local file="$1"
  grep -o '"subagentPromptCacheTtl": *"[^"]*"' "$file" | head -n1 || true
}

status=0
declare -a json_blocks
declare -a ttl_lines

for i in "${!FILES[@]}"; do
  file="${FILES[$i]}"

  if [ ! -f "$file" ]; then
    echo "check-hook-sync: block not found in $file (file does not exist)"
    status=1
    continue
  fi

  if ! block="$(extract_json_block "$file")"; then
    echo "check-hook-sync: block not found in $file (no fenced json block with the guard-hook matcher)"
    status=1
    continue
  fi
  json_blocks[$i]="$(printf '%s' "$block" | tr -s '[:space:]' ' ' | sed 's/^ *//; s/ *$//')"

  ttl="$(extract_ttl_line "$file")"
  if [ -z "$ttl" ]; then
    echo "check-hook-sync: block not found in $file (no subagentPromptCacheTtl line)"
    status=1
    continue
  fi
  ttl_lines[$i]="$ttl"
done

if [ "$status" -ne 0 ]; then
  exit "$status"
fi

for i in 1 2; do
  if [ "${json_blocks[$i]}" != "${json_blocks[0]}" ]; then
    echo "check-hook-sync: guard-hook JSON block differs between ${FILES[0]} and ${FILES[$i]}"
    echo "--- ${FILES[0]} ---"
    echo "${json_blocks[0]}"
    echo "--- ${FILES[$i]} ---"
    echo "${json_blocks[$i]}"
    status=1
  fi
  if [ "${ttl_lines[$i]}" != "${ttl_lines[0]}" ]; then
    echo "check-hook-sync: subagentPromptCacheTtl line differs between ${FILES[0]} (${ttl_lines[0]}) and ${FILES[$i]} (${ttl_lines[$i]})"
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  echo "check-hook-sync: OK — guard hook and subagentPromptCacheTtl are in sync across all three files"
fi

exit "$status"
