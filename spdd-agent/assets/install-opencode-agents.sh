#!/usr/bin/env bash
# Installs/resyncs the 4 dedicated opencode agent files for spdd-{canvas,design,implement,verify}.
#
# Self-contained on purpose: reads only ~/.config/spdd/config.json and writes only under
# ~/.config/opencode/agents/ — never reaches into another skill's folder. Lives inside
# spdd-agent/ (the one skill guaranteed to be installed) so it travels with the framework
# regardless of how skills are installed (npx skills add installs each skill's folder
# independently and never preserves sibling folders).
#
# opencode-only: opencode's Task tool has no per-invocation model override (confirmed against
# opencode's own docs — an ad-hoc subagent always runs at the model of the primary agent that
# invoked it). A named agent file with a static `model:` in frontmatter is the only way to pin
# a model to a phase there. Claude Code needs none of this — its Agent tool already accepts a
# per-call `model` param (see spdd-agent/SKILL.md Step 3).
#
# Callable from either host: a Claude Code session can run this to prep opencode for later use
# on the same machine. It only ever touches opencode paths.
#
# Idempotent: re-running only rewrites a file whose stored model-source marker no longer
# matches config.json's current value for that phase.
#
# Known gap: this reads only the flat top-level `models` key (deliberately never `claude.models`
# — see spdd-agent/assets/model-bootstrap.md's schema note: the two sections are independent
# per-host configs, not a fallback chain). On a machine where spdd-agent has so far only ever
# bootstrapped under Claude Code, the flat key may not exist yet, so all four phases are missing
# even though the file exists. That case is handled below as a hard failure with actionable
# guidance, not a silent no-op.

set -euo pipefail

OPENCODE_DIR="$HOME/.config/opencode"
AGENTS_DIR="$OPENCODE_DIR/agents"
CONFIG="$HOME/.config/spdd/config.json"

if [ ! -d "$OPENCODE_DIR" ]; then
  echo "opencode not detected on this machine ($OPENCODE_DIR missing) — nothing to do."
  exit 0
fi

if [ ! -f "$CONFIG" ]; then
  echo "~/.config/spdd/config.json not found — run spdd-agent first to bootstrap it." >&2
  exit 1
fi

mkdir -p "$AGENTS_DIR"

translate_model() {
  case "$1" in
    */*) echo "$1" ;; # already provider-qualified — pass through verbatim
    opus) echo "anthropic/claude-opus-5" ;;
    sonnet) echo "anthropic/claude-sonnet-5" ;;
    haiku) echo "anthropic/claude-haiku-4-5-20251001" ;;
    fable) echo "anthropic/claude-fable-5-1" ;;
    *) echo "$1" ;; # unknown alias — pass through verbatim rather than fail
  esac
}

get_value() {
  python3 -c "
import json
d = json.load(open('$CONFIG'))
print(d.get('models', {}).get('$1', ''))
"
}

skipped_count=0

write_agent() {
  local phase="$1" bash_perm="$2" raw model file

  raw=$(get_value "$phase")
  if [ -z "$raw" ]; then
    echo "warning: no '$phase' value in config.json's flat 'models' key — skipping" >&2
    skipped_count=$((skipped_count + 1))
    return
  fi

  file="$AGENTS_DIR/spdd-$phase.md"

  if [ -f "$file" ] && grep -qF "spdd-agent:model-source=$raw" "$file" 2>/dev/null; then
    echo "spdd-$phase.md up to date ($raw)"
    return
  fi

  model=$(translate_model "$raw")

  cat > "$file" <<AGENTEOF
---
description: SPDD $phase phase — dedicated subagent invoked by spdd-agent
mode: subagent
model: $model
permission: {"edit": "allow", "bash": "$bash_perm"}
---
<!-- spdd-agent:model-source=$raw -->

Load the \`spdd-$phase\` skill and follow it exactly, using only the context spdd-agent's prompt provides — nothing else from any other conversation.

You do not have AskUserQuestion — you're running in the background, with no live user turn. Never stay blocked waiting for an answer that cannot arrive. If a step asks you to confirm a content decision, take the suggested default, continue, and add a "⚠️ Confirm:" line so it gets resolved later. If it asks you to confirm an action with a side effect (writing config, installing hooks, anything outside the artifact you're generating), do not execute it or assume a default in its favor — skip it, leave it noted as a pending "⚠️ Confirm:", and don't touch the filesystem for that step.

Report back exactly as that skill's own Report step specifies: saved/updated path, short summary, pending "⚠️ Confirm:" lines.
AGENTEOF

  echo "wrote spdd-$phase.md (model: $model)"
}

write_agent canvas "allow"
write_agent design "deny"
write_agent implement "allow"
write_agent verify "allow"

if [ "$skipped_count" -eq 4 ]; then
  echo "error: config.json exists but its flat top-level 'models' key is missing or empty — nothing written." >&2
  echo "This machine likely has only ever bootstrapped spdd-agent under Claude Code (which writes 'claude.models', a separate section never used as a fallback here)." >&2
  echo "Run spdd-agent once under opencode to bootstrap the flat 'models' key, then re-run this script." >&2
  exit 1
fi
