#!/usr/bin/env bash
# Diffs the never-block rule text across the 8 wrapper agent templates
# (spdd-{canvas,design,implement,verify}/assets/agent-{claude-code,opencode}.md)
# and spdd-agent/SKILL.md's own copy (Step 3's "The never-block rule, verbatim").
# Fails with a clear message if any wrapper's copy has drifted from the SKILL.md's.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SKILL_FILE="$REPO_ROOT/spdd-agent/SKILL.md"

WRAPPER_FILES=(
  "$REPO_ROOT/spdd-canvas/assets/agent-claude-code.md"
  "$REPO_ROOT/spdd-canvas/assets/agent-opencode.md"
  "$REPO_ROOT/spdd-design/assets/agent-claude-code.md"
  "$REPO_ROOT/spdd-design/assets/agent-opencode.md"
  "$REPO_ROOT/spdd-implement/assets/agent-claude-code.md"
  "$REPO_ROOT/spdd-implement/assets/agent-opencode.md"
  "$REPO_ROOT/spdd-verify/assets/agent-claude-code.md"
  "$REPO_ROOT/spdd-verify/assets/agent-opencode.md"
)

extract_rule() {
  # Prints the never-block rule blockquote line, with any leading whitespace
  # and the "> " marker stripped, or nothing if no such line exists.
  local file="$1"
  grep -m1 '^[[:space:]]*> You do not have `AskUserQuestion`' "$file" \
    | sed -E 's/^[[:space:]]*> //'
}

status=0

if [ ! -f "$SKILL_FILE" ]; then
  echo "check-agent-sync: $SKILL_FILE does not exist"
  exit 1
fi

skill_rule="$(extract_rule "$SKILL_FILE")"
if [ -z "$skill_rule" ]; then
  echo "check-agent-sync: never-block rule not found in $SKILL_FILE"
  exit 1
fi

for file in "${WRAPPER_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "check-agent-sync: wrapper template not found: $file"
    status=1
    continue
  fi

  wrapper_rule="$(extract_rule "$file")"
  if [ -z "$wrapper_rule" ]; then
    echo "check-agent-sync: never-block rule not found in $file"
    status=1
    continue
  fi

  if [ "$wrapper_rule" != "$skill_rule" ]; then
    echo "check-agent-sync: never-block rule differs between $SKILL_FILE and $file"
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  echo "check-agent-sync: OK — never-block rule is byte-identical across spdd-agent/SKILL.md and all 8 wrapper templates"
fi

exit "$status"
