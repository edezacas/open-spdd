# SPDD hook and subagent cache TTL

Merge the applicable piece(s) into `.claude/settings.local.json` and write it back:

- **Guard hook** — into `hooks.PreToolUse` (create the key if absent):
  ```json
  {
    "matcher": "Edit|Write",
    "hooks": [
      {
        "type": "command",
        "command": "unresolved=$(grep -rl '⚠️ Confirm:' spdd/changes/*/canvas.md spdd/changes/*/plans/*.md 2>/dev/null); if [ -n \"$unresolved\" ]; then echo \"SPDD WARNING: unresolved canvas/plan items in: $unresolved — review before editing code.\"; fi"
      }
    ]
  }
  ```
- **Subagent cache TTL** — top-level (not under `hooks`): `"subagentPromptCacheTtl": "1h"`. Set this so that `spdd-implement` and `spdd-verify` — which can run several turns inside one subagent call — keep their prompt cache alive; without the TTL setting, Claude Code caps it at 5 minutes regardless of plan.
