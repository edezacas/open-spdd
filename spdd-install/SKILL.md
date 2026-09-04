---
name: spdd-install
description: Install or resync the 8 dedicated per-phase SPDD subagent files (Claude Code and opencode) that spdd-agent uses in Dedicated mode, plus the Claude Code auto-delegation permissions.deny entries. Invoked manually via /spdd-install only — never auto-triggers, never offered or invoked from inside spdd-agent's feature-build flow.
license: Apache-2.0
compatibility: Works with any agent. Installs Claude Code agent files (`~/.claude/agents/`) and/or opencode agent files (`~/.config/opencode/agents/`) depending on which host(s) are present; the `permissions.deny` merge step is Claude Code only. Requires `~/.config/spdd/config.json` to already be complete — this skill never bootstraps it.
allowed-tools: Read Write Edit Bash AskUserQuestion
metadata:
  author: edezacas
  version: "1.1"
---

## Instructions

This skill provisions the optional dedicated per-phase subagent layer that `spdd-agent` uses in Dedicated mode. It never runs as part of `spdd-agent`'s feature-build flow — it is reached only by explicit `/spdd-install` invocation.

### Step 1 — Guard: config.json must already be complete

Config lives at `~/.config/spdd/config.json`, same file and shape `spdd-agent` Step 1 reads and writes.

Detect the Claude Code host the same way `spdd-agent` Step 1 does: run `Bash`: `echo "$CLAUDECODE"`. If it prints `1`, the applicable section is `claude.models`; otherwise it's the flat top-level `models` key.

Read and parse `~/.config/spdd/config.json`. It is **complete** only if the applicable section has all six phase keys (`canvas`, `design`, `implement`, `verify`, `sync`, `migrate`) present as non-empty strings — the same six-key definition `spdd-agent` Step 1 uses, not a narrower four-key one.

If the file doesn't exist, fails to parse, or the applicable section is missing any of the six keys: **stop immediately**. Tell the user to run `spdd-agent` (or make an explicit "view/change the model config" request to it) first to bootstrap the config, and do not install anything. This is a hard guard, not a question — there is nothing to confirm yet. Do not open or duplicate any part of `spdd-agent/assets/model-bootstrap.md`; this skill never bootstraps, repairs, or migrates the config itself.

Once the guard passes, only `canvas`, `design`, `implement`, and `verify` are used past this point — `sync` and `migrate` were loaded as part of the six-key check but play no further role here, same as `spdd-agent` Steps 4–8 never touch them either.

**The "applicable section" above governs only this guard.** It does not determine which config section feeds which *target* host's agent files in Steps 3–5 below: Claude Code files always use `claude.models`, and opencode files always use the flat top-level `models` key — regardless of which host `/spdd-install` itself is currently running under (per `spdd-agent/assets/model-bootstrap.md`'s JSON shapes: the flat key is what opencode and every non-Claude-Code host actually reads/writes; `claude.models` is Claude-Code-specific). Running `/spdd-install` from Claude Code does not mean opencode's values come from `claude.models` — they never do.

### Step 2 — Read the 8 wrapper templates

Read these 8 files directly from the repo (this is the one skill allowed to reference asset files outside its own folder, since cross-skill provisioning is its entire purpose):

```
spdd-canvas/assets/agent-claude-code.md      spdd-canvas/assets/agent-opencode.md
spdd-design/assets/agent-claude-code.md      spdd-design/assets/agent-opencode.md
spdd-implement/assets/agent-claude-code.md   spdd-implement/assets/agent-opencode.md
spdd-verify/assets/agent-claude-code.md      spdd-verify/assets/agent-opencode.md
```

If any of the 8 is missing, stop with a clear error — this skill depends on `spdd-canvas`/`spdd-design`/`spdd-implement`/`spdd-verify` already shipping their templates.

### Step 3 — Confirm and install (Claude Code)

Show the user what will be written: the 4 target paths (`~/.claude/agents/spdd-canvas.md`, `spdd-design.md`, `spdd-implement.md`, `spdd-verify.md`) and, separately, the 4 `permissions.deny` entries to merge into `~/.claude/settings.json`. Ask via `AskUserQuestion` — this is a real side-effect action.

On confirmation:

- Write each of the 4 Claude Code agent files **verbatim** from its template. The templates already carry `model: sonnet` as a static frontmatter fallback — do not rewrite it; the per-invocation `model` param `spdd-agent` passes from `claude.models` always wins at runtime regardless of this value.
- Merge `"permissions": {"deny": ["Agent(spdd-canvas)", "Agent(spdd-design)", "Agent(spdd-implement)", "Agent(spdd-verify)"]}` into `~/.claude/settings.json`. Create the file, the `permissions` key, or the `deny` array if any is absent. Append only the entries not already present — never duplicate an existing entry, and never remove or alter any unrelated entry already in `permissions.deny` or elsewhere in the file.

If the user declines, write nothing for Claude Code, and still proceed independently to Step 4 — the two hosts are confirmed separately, since a user may only use one.

### Step 4 — Confirm and install (opencode)

Show the user what will be written: the 4 target paths (`~/.config/opencode/agents/spdd-canvas.md`, `spdd-design.md`, `spdd-implement.md`, `spdd-verify.md`) and the phase model that will be stamped into each, read from config.json's flat top-level `models` key — **never** `claude.models`, even when `/spdd-install` is itself running under Claude Code (see the note at the end of Step 1: the host you're running under and the config section a target host's files are derived from are independent). Ask via `AskUserQuestion`.

On confirmation, for each of the 4 phases, take the flat `models` key's current raw value for that phase and derive two things from it:

- **`model:`** — the value written into the opencode agent file's frontmatter. If the raw value already looks like a provider-qualified id (contains a `/`, e.g. `anthropic/claude-sonnet-5`), use it verbatim. Otherwise, treat it as a Claude Code tier alias and translate it through the table below; if it isn't one of the four known aliases, **warn** (do not fail) that it couldn't be translated and write the raw value into `model:` verbatim anyway.
- **The `spdd-install:model-source` marker** — write `<!-- spdd-install:model-source=<raw-config-value> -->` as the first line of the file's body, immediately after the frontmatter and before the template's load-and-follow instruction, followed by a blank line. This is always the **untranslated** raw config.json value, even when translation above fell back to writing it verbatim into `model:` too — it's what later divergence checks compare against, never `model:` itself.

**Alias → opencode model-id table** (owned and maintained by this skill only — `spdd-agent` never needs a copy of it, since Step 2's divergence check there only ever compares raw strings against the marker):

| Claude Code tier alias | opencode `model:` value |
|---|---|
| `opus` | `anthropic/claude-opus-5` |
| `sonnet` | `anthropic/claude-sonnet-5` |
| `haiku` | `anthropic/claude-haiku-4-5-20251001` |
| `fable` | `anthropic/claude-fable-5-1` |

This table reflects the model family current at the time this skill was written and will drift as new models ship — that's expected and why an untranslatable value only warns, never fails.

If the user declines, write nothing for opencode. (If Step 3 was also declined, nothing is installed at all — report that and stop.)

### Step 5 — Resync (re-running over existing files)

**Claude Code side:** there is no per-file divergence concept — the frontmatter `model:` is always a static fallback, never the source of truth, and carries no marker. Resync is just "rewrite the 4 files from the current templates," confirmation-gated the same as Step 3. Re-run the `permissions.deny` merge the same way too — it's already idempotent (skips entries already present).

**opencode side:** for each of the 4 target files that already exists, read its `spdd-install:model-source` marker and compare it — as a plain string, never translated — against the flat top-level `models` key's current raw value for that phase (never `claude.models`, same rule as Step 4).

- If the marker is present and matches: up to date. Silently treat as in sync (a plain re-write with identical content is also fine — no behavior change either way).
- If the marker is missing (a file installed before this marker existed, or hand-edited) or differs from config.json's current raw value: this **is** a divergence needing remediation, never silently skipped. Report it, then offer via `AskUserQuestion` a confirmation-gated rewrite of **both** the `model:` field (re-translated per Step 4's table) and the marker, toward config.json's current raw value — never update one without the other, never rewrite silently.

### Step 6 — Report

Report which of the 8 files were written or left unchanged, whether the `permissions.deny` merge ran (and what it added, if anything), and any divergences found and their resolution (rewritten, or left as-is because the user declined). If the Step 1 guard stopped the run, report just that.
