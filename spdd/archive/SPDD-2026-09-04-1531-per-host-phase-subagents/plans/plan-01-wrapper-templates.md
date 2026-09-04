# Plan: Wrapper templates (8 per-phase agent files)

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-04
> Verified: 2026-09-04
**Depends on:** none
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Asset | 8 wrapper templates | Thin body: load and follow the phase's installed SKILL.md, never-block rule verbatim, report back per the phase skill's own Report step |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Wrapper templates (repo source) — `spdd-{canvas,design,implement,verify}/assets/agent-{claude-code,opencode}.md` (New)

**Structure — files to create or modify:**

```
spdd-canvas/assets/agent-claude-code.md      # wrapper template → ~/.claude/agents/spdd-canvas.md
spdd-canvas/assets/agent-opencode.md         # wrapper template → ~/.config/opencode/agents/spdd-canvas.md
spdd-design/assets/agent-claude-code.md
spdd-design/assets/agent-opencode.md
spdd-implement/assets/agent-claude-code.md
spdd-implement/assets/agent-opencode.md
spdd-verify/assets/agent-claude-code.md
spdd-verify/assets/agent-opencode.md
```

---

## Implementation notes

### Shared wrapper shape (both hosts, all 8 files)

- Thin body only, no logic of its own (canvas Norm): a load-and-follow instruction pointing at the phase skill's installed `SKILL.md` path, the never-block rule quoted **byte-identical** to the exact string in `spdd-agent/SKILL.md` Step 3 ("The never-block rule, verbatim"), and a report-back instruction deferring to the phase skill's own Report step. Do not quote the rule from memory or from this plan — copy it from `spdd-agent/SKILL.md` at implementation time; `scripts/check-agent-sync.sh` (plan-03) diffs against that copy.
- `description` on both hosts uses the forbid-auto-delegation wording from the canvas field table: "Orchestrator-invoked only — part of the SPDD flow; never delegate proactively".
- Nothing references an asset outside the file's own skill folder (hook-setup.md precedent, canvas Norm).
- User-level install targets (`~/.claude/agents/spdd-<phase>.md`, `~/.config/opencode/agents/spdd-<phase>.md`) are **not** written by this plan — they are materialized at runtime by the separate `spdd-install` skill (plan-04) as a confirmation-gated, opt-in step (canvas Pending confirmation #2). This plan ships repo templates only.

### Claude Code variants (`agent-claude-code.md`, 4 files)

Frontmatter fields:
- `name: spdd-<phase>`
- `description:` forbid-auto-delegation wording (above)
- `model: sonnet` — static fallback tier only; `spdd-agent` passes the per-invocation `model` param from config.json, which overrides it per host docs
- `tools:` per-phase whitelist (finalized below) — Claude Code's subagent frontmatter has no `permissions.deny` field; `tools:` alone is the allowlist, `disallowedTools:` exists as a denylist but is not needed on top of an allowlist and is not used here
- `skills: [spdd-<phase>]` — deterministic preload of the phase SKILL.md at launch

### opencode variants (`agent-opencode.md`, 4 files)

Frontmatter fields:
- `description:` (required) forbid-auto-delegation wording (above)
- `mode: subagent` (required for `hidden` to apply)
- `hidden: true` (hidden from the `@` menu, still Task-invocable)
- `permission:` per-phase keys (finalized below); reads are unrestricted by design in opencode
- `model:` omitted from the template — written/refreshed from config.json by `spdd-install` (canvas field table), so no machine-specific model ID gets hardcoded in repo source
- The template's body (below the frontmatter) leaves the first line as a placeholder for `spdd-install` to insert `<!-- spdd-install:model-source=<raw-config-value> --> ` above the load-and-follow instruction — the untranslated config.json value `spdd-install` derived `model:` from, so later divergence checks (plan-02's Step 2, plan-04's resync) never need to re-run the alias→ID translation themselves (canvas Acceptance criteria: "divergence comparison never needs the alias→ID mapping table outside `spdd-install`"). The template ships with no marker line at all — `spdd-install` adds it at write time, since the repo source has no config.json value to embed.

### Finalized per-phase tool scoping (canvas delegated finalization to spdd-design)

| Phase | Claude Code `tools:` | opencode `permission:` | Notes |
|-------|----------------------|------------------------|-------|
| canvas | `Read, Glob, Grep, Write, Bash` | `edit: allow, bash: allow` | Read/search + canvas-file Write + Bash for date/git checks; no `Edit` |
| design | `Read, Glob, Grep, Write` | `edit: allow, bash: deny` | Read/search + plan-file Write; no shell needed |
| implement | `Read, Glob, Grep, Write, Edit, Bash` | `edit: allow, bash: allow` | Full implementation |
| verify | `Read, Glob, Grep, Bash, Edit, Write` | `edit: allow, bash: allow` | Bash for tests and archive moves; `Edit` for spec fold-back; `Write` for first-time creation of a domain's living spec (confirmed at the design checkpoint) |

### Content decisions confirmed at the design checkpoint

- Confirmed: verify wrapper's tool whitelist includes `Write` (the canvas's proposed default listed only read/search + `Bash` + `Edit`; `Write` is added because `spdd-verify` creates `spdd/specs/<domain>.md` when a domain has no living spec yet — fold-back into an existing file uses `Edit` only).
- Revised (factual check, 2026-09-04): Claude Code's subagent frontmatter has no `permissions.deny` field, so the auto-delegation reinforcement is not part of this plan's wrapper files at all — it's 4 `permissions.deny: ["Agent(spdd-<phase>)"]` entries written to the user-level `~/.claude/settings.json` by the `spdd-install` skill (plan-04; canvas Pending confirmation #3, canvas Entities). The wrapper's `tools:` field remains its own, unrelated allowlist.
- Confirmed: Claude Code templates ship `model: sonnet` as the static frontmatter fallback tier (matches this repo's config.json values; the per-invocation `model` param from config.json always overrides it at runtime).

---

## Out of scope for this plan

- `spdd-agent/SKILL.md` edits (plan-02)
- `spdd-install/SKILL.md` and the install/resync logic itself (plan-04)
- `spdd-agent/evals/evals.json`, `spdd-install/evals/evals.json`, and `scripts/check-agent-sync.sh` (plan-03)
- Writing any user-level agent file, or touching `~/.config/spdd/config.json`
