# Plan: Add hook/TTL sync-check script and document repo-level config notes

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-08-31
**Depends on:** none
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Create | `scripts/check-hook-sync.sh` | Extracts the hook/TTL bash+JSON block from `spdd-canvas/SKILL.md` Step 11, `spdd-implement/SKILL.md` Step 5, and `spdd-verify/SKILL.md` Step 9, and fails with a clear diff if any of the three differ from the other two |
| Modify | `AGENTS.md` Gotchas | Add: reference to `scripts/check-hook-sync.sh` and what it guards; note that this repo's own `~/.config/spdd/config.json` intentionally runs a reduced tier on `canvas`/`design`/`verify` relative to `spdd-agent`'s documented defaults, with `implement` at parity (`sonnet`, bumped at this canvas's checkpoint) |
| Modify | `CLAUDE.md` Gotchas | Mirror the same two notes added to `AGENTS.md` (per this repo's own convention/memory: keep both files' Structure/Conventions/Gotchas in sync) |

## Implementation notes

- `scripts/check-hook-sync.sh`: extract each of the three blocks by locating the fenced ```json code block that starts with `"matcher": "Edit|Write"` under each file's respective step heading, normalize whitespace, and diff pairwise; also verify the top-level `"subagentPromptCacheTtl": "1h"` line is present and identical in all three (it's outside the JSON fence, in the surrounding step prose). Exit non-zero with a clear message naming which file(s) diverge if any pair differs; exit non-zero with a "block not found in `<file>`" message (not a raw grep/diff error) if a file is missing or restructured such that the expected step no longer exists.
- Running the script against the current repo state should pass with no reported diff — all three blocks are already identical as of this canvas.
- The `AGENTS.md`/`CLAUDE.md` model-tier note must read as descriptive, not as a mandate — state current values and the reason (cost-tuned for this repo's own dogfooding), not "must always be this way."
- No `metadata.version` bump needed — `AGENTS.md`/`CLAUDE.md` aren't `SKILL.md` files and carry no such frontmatter field.

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Hook/TTL sync check — `scripts/check-hook-sync.sh` (new)
- `AGENTS.md` — `AGENTS.md`
- `CLAUDE.md` — `CLAUDE.md`

**Structure — files to create or modify:**

```
scripts/check-hook-sync.sh
AGENTS.md
CLAUDE.md
```
