# Model bootstrap, repair, and migration instructions

Opened only by `spdd-agent` Step 1, and only when the applicable config section (`claude.models` under Claude Code, flat top-level `models` otherwise) is not already complete or a value change was explicitly requested. It documents every non-fast-path branch — first-run bootstrap, repair, migration, malformed/unparseable config, and the explicit-config-request "change" flow — plus the JSON shape examples; the fast path is handled inline in `SKILL.md` without ever opening this file.

## JSON shapes

Non-Claude-Code hosts read/write the flat top-level key exactly as before:

```json
{
  "models": {
    "canvas": "opus", "design": "opus", "implement": "sonnet", "verify": "opus"
  }
}
```
Claude Code hosts read/write a `claude` namespace instead, wrapping the same `models` shape:

```json
{
  "claude": {
    "models": {
      "canvas": "opus", "design": "opus", "implement": "sonnet", "verify": "opus"
    }
  }
}
```
`claude` is a top-level key sibling to any future host namespace.

These four keys are the only phases `spdd-agent` ever dispatches as subagents (Steps 4–8). `spdd-sync` and `spdd-migrate` run standalone via their own auto-trigger, outside this orchestrator, and never take a model override — they have no entry in this config.

Each value is a free-text model identifier — not a fixed enum. On Claude Code that's `opus` / `sonnet` / `haiku` / `fable`, and it's genuinely applied: Step 3 passes it as the `Agent` tool's `model` param on every phase call. This skill never validates the string against a host-specific list — it only checks that a value is present and non-empty.

**opencode has no per-call model override at all** (confirmed against opencode's own docs: an ad-hoc subagent always runs at the model of the primary agent that invoked it — there is no model field on the Task tool). Bootstrap still asks for and stores four values on opencode for config-shape consistency across hosts, but say so plainly when bootstrapping under opencode: on their own, these values are **not** applied — every phase will run at whatever model the current conversation itself is using. The fix is `SKILL.md`'s Step 2b: it detects when opencode's dedicated agent files are missing or stale and offers to run `assets/install-opencode-agents.sh`, which pins each phase's value into a named agent file's frontmatter — the one form of model selection opencode's Task tool actually honors.

## Default tiers

| Phase | Suggested tier | Fixed-alias example (Claude Code) |
|---|---|---|
| `canvas` | high-reasoning | `opus` |
| `design` | high-reasoning | `opus` |
| `implement` | fast/cheap | `sonnet` |
| `verify` | high-reasoning | `opus` |

Tier rationale: canvas/design/verify favor high-reasoning (ambiguity detection, architectural calls, edge-case/Norms checking); implement favors fast/cheap (executing an already-validated plan).

The last column is one worked example, not the framework's default — any host with its own fixed alias set (present or future) maps `Suggested tier` to that set the same way.

## First-run bootstrap (file doesn't exist)

Before touching the user's feature request, propose a default model per phase (table above) via `AskUserQuestion`, grouped into 1–2 calls of up to 4 questions each. The choice of options depends on the host's capability, not its identity: on Claude Code, offer the fixed alias set (`opus`/`sonnet`/`haiku`/`fable`) with the table's suggested tier pre-marked "(Recommended)" — these values are genuinely applied per phase. On opencode (or any host confirmed to have no per-call model override), still ask and store the four values the same way, but say plainly, once, before the questions: on their own, ad-hoc dispatch cannot apply these — every phase runs at this conversation's own model — until Step 2b's dedicated-agent check offers to pin them via `assets/install-opencode-agents.sh`. Write the confirmed selections to `~/.config/spdd/config.json` (create `~/.config/spdd/` if needed) — under the `claude` namespace if Claude Code was detected, under the flat top-level `models` key otherwise.

## Repair (file exists, one or more of the four values missing/empty/not-a-string)

Check the applicable section's four values; treat a missing, empty, or non-string value as absent and re-ask only for that phase (same `AskUserQuestion` mechanism), then write the corrected file back to that same section — the other values, and any unrelated top-level keys, stay untouched.

This also applies when the JSON parses but matches neither the flat nor the `claude`-namespaced schema for the four phase values (e.g. a hand-edited file with a `claude` key that isn't an object): re-ask only for what's unresolvable from the file, without overwriting unrelated valid top-level keys.

## Malformed or unparseable file

If `~/.config/spdd/config.json` exists but fails to parse as JSON, or is a zero-byte file: treat this the same as the repair case above, except nothing can be trusted from the file — ask for all four values via `AskUserQuestion`, and warn the user the existing file couldn't be parsed before writing over it.

## Migration (flat `models` complete, Claude Code detected, no `claude` namespace yet)

If Claude Code is detected and the file has a flat top-level `models` key with all four values but no `claude` namespace yet, this is a one-time migration, not ordinary repair. Writing it is a side effect — per "Decision transparency" in `SKILL.md`, propose it via a real foreground `AskUserQuestion` (copy the flat key's four values into a new `claude.models` namespace; leave the flat key untouched) and only write once confirmed. Never perform this write silently, and never delete or modify the original flat key.

If both a flat `models` key and a `claude` namespace are already present, read only from `claude` — never merge or delete the flat key (this is the ordinary fast path handled inline in `SKILL.md`, not a migration case).

## Explicit config request — changing values

When the user asked to change one or more phase values (Step 0's config-request path, regardless of whether the config was already complete): read the current file from the applicable section, then ask only for the phases the user wants changed via `AskUserQuestion`, using the same host-capability-based options (fixed alias set vs. free text) as first-run bootstrap above. Write the file back to that same section, leaving the other values and unrelated top-level keys untouched. Report the resulting config and stop — do not proceed to Step 2.
