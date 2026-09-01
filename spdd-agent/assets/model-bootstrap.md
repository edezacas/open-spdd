# Model bootstrap, repair, and migration instructions

Opened only by `spdd-agent` Step 1, and only when the applicable config section (`claude.models` under Claude Code, flat top-level `models` otherwise) is not already complete or a value change was explicitly requested. It documents every non-fast-path branch — first-run bootstrap, repair, migration, malformed/unparseable config, and the explicit-config-request "change" flow — plus the JSON shape examples; the fast path is handled inline in `SKILL.md` without ever opening this file.

## JSON shapes

Non-Claude-Code hosts read/write the flat top-level key exactly as before:

```json
{
  "models": {
    "canvas": "opus", "design": "opus", "implement": "sonnet",
    "verify": "opus", "sync": "sonnet", "migrate": "sonnet"
  }
}
```
Claude Code hosts read/write a `claude` namespace instead, wrapping the same `models` shape:

```json
{
  "claude": {
    "models": {
      "canvas": "opus", "design": "opus", "implement": "sonnet",
      "verify": "opus", "sync": "sonnet", "migrate": "sonnet"
    }
  }
}
```
`claude` is a top-level key sibling to any future host namespace.

Only `canvas`, `design`, `implement`, and `verify` are ever used by `spdd-agent`'s own flow (Steps 4–8) — `sync` and `migrate` keep their independent auto-trigger and run standalone, outside this orchestrator.

Each value is a free-text model identifier in whatever form the current host's subagent mechanism accepts — not a fixed enum. On Claude Code that's `opus` / `sonnet` / `haiku` / `fable`; on a host like opencode it's a provider-qualified id (e.g. `anthropic/claude-sonnet-4-5`, `openai/gpt-5`) or whatever string that host's model-override field expects. This skill never validates the string against a host-specific list — it only checks that a value is present and non-empty, and passes it through verbatim to the subagent call in Step 3.

## Default tiers

| Phase | Suggested tier | Fixed-alias example (Claude Code) |
|---|---|---|
| `canvas` | high-reasoning | `opus` |
| `design` | high-reasoning | `opus` |
| `implement` | fast/cheap | `sonnet` |
| `verify` | high-reasoning | `opus` |
| `sync` | fast/cheap | `sonnet` |
| `migrate` | fast/cheap | `sonnet` |

Tier rationale: canvas/design/verify favor high-reasoning (ambiguity detection, architectural calls, edge-case/Norms checking); implement/sync/migrate favor fast/cheap (executing an already-validated plan, mechanical spec sync, mechanical layout migration).

The last column is one worked example, not the framework's default — any host with its own fixed alias set (present or future) maps `Suggested tier` to that set the same way.

## First-run bootstrap (file doesn't exist)

Before touching the user's feature request, propose a default model per phase (table above) via `AskUserQuestion`, grouped into 1–2 calls of up to 4 questions each. The choice of options depends on the host's capability, not its identity: if the host's model-override field accepts a small fixed set of named aliases (e.g. Claude Code's `opus`/`sonnet`/`haiku`/`fable`), offer that set as options with the table's suggested tier pre-marked "(Recommended)". If the host instead takes an arbitrary model-identifier string, offer the table's suggested tier as the recommended free-text default and let the user type the exact identifier they want via `AskUserQuestion`'s "Other". Write the confirmed selections to `~/.config/spdd/config.json` (create `~/.config/spdd/` if needed) — under the `claude` namespace if Claude Code was detected, under the flat top-level `models` key otherwise.

## Repair (file exists, one or more of the six values missing/empty/not-a-string)

Check the applicable section's six values; treat a missing, empty, or non-string value as absent and re-ask only for that phase (same `AskUserQuestion` mechanism), then write the corrected file back to that same section — the other five values, and any unrelated top-level keys, stay untouched.

This also applies when the JSON parses but matches neither the flat nor the `claude`-namespaced schema for the six phase values (e.g. a hand-edited file with a `claude` key that isn't an object): re-ask only for what's unresolvable from the file, without overwriting unrelated valid top-level keys.

## Malformed or unparseable file

If `~/.config/spdd/config.json` exists but fails to parse as JSON, or is a zero-byte file: treat this the same as the repair case above, except nothing can be trusted from the file — ask for all six values via `AskUserQuestion`, and warn the user the existing file couldn't be parsed before writing over it.

## Migration (flat `models` complete, Claude Code detected, no `claude` namespace yet)

If Claude Code is detected and the file has a flat top-level `models` key with all six values but no `claude` namespace yet, this is a one-time migration, not ordinary repair. Writing it is a side effect — per "Decision transparency" in `SKILL.md`, propose it via a real foreground `AskUserQuestion` (copy the flat key's six values into a new `claude.models` namespace; leave the flat key untouched) and only write once confirmed. Never perform this write silently, and never delete or modify the original flat key.

If both a flat `models` key and a `claude` namespace are already present, read only from `claude` — never merge or delete the flat key (this is the ordinary fast path handled inline in `SKILL.md`, not a migration case).

## Explicit config request — changing values

When the user asked to change one or more phase values (Step 0's config-request path, regardless of whether the config was already complete): read the current file from the applicable section, then ask only for the phases the user wants changed via `AskUserQuestion`, using the same host-capability-based options (fixed alias set vs. free text) as first-run bootstrap above. Write the file back to that same section, leaving the other values and unrelated top-level keys untouched. Report the resulting config and stop — do not proceed to Step 2.
