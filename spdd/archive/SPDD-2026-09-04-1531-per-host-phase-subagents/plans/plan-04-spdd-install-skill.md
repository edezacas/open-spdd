# Plan: `spdd-install` skill (install/resync of dedicated phase agents)

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-04
> Verified: 2026-09-04
**Depends on:** plan-01-wrapper-templates
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Skill | `spdd-install` — install/resync | Reads config.json (requires it already complete — else tells the user to run `spdd-agent` first) and the 8 wrapper templates from each phase skill's own `assets/`; writes them, confirmation-gated, into `~/.claude/agents/` / `~/.config/opencode/agents/`; on opencode, stamps the phase model from config.json into the agent file's frontmatter; on Claude Code, merges the 4 `permissions.deny` entries into `~/.claude/settings.json` |
| Skill | `spdd-install` — divergence remediation | When re-run (resync), compares the agent file's `spdd-install:model-source` marker (not its `model:` field) against config.json's current raw value; on a mismatch, offers a confirmation-gated rewrite of both `model:` (re-translated) and the marker toward config.json's value using the documented alias→ID mapping table; warns (never fails) when a value cannot be translated |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-install` skill — `spdd-install/SKILL.md` (New)
- Dedicated phase agents (user-level, Claude Code) — `~/.claude/agents/spdd-{canvas,design,implement,verify}.md` (New, outside the repo, written only at runtime)
- Dedicated phase agents (user-level, opencode) — `~/.config/opencode/agents/spdd-{canvas,design,implement,verify}.md` (New, outside the repo, written only at runtime)
- Claude Code auto-delegation deny rules — `~/.claude/settings.json` (`permissions.deny`, Existing, modified, outside the repo, written only at runtime)

`spdd-install/evals/evals.json` is **not** owned by this plan — same as `spdd-agent/evals/evals.json` is never populated by plan-02, eval coverage for every skill this feature touches is exclusively plan-03's job (canvas Norm: each skill's `evals.json` is the single source of truth for its own coverage).

**Structure — files to create or modify:**

```
spdd-install/SKILL.md                        # new: install/resync flow
CLAUDE.md                                     # register spdd-install in the shared Structure section and the Auto-triggers table
AGENTS.md                                     # same Structure row, same pass (byte-identical shared section, spdd/specs/spdd-agent.md Norms); Auto-triggers row too, matching every other phase skill
```

---

## Implementation notes

### `spdd-install/SKILL.md` — overall shape

- Frontmatter follows the same shape as the other phase skills (`name`, `description`, `license`, `compatibility`, `allowed-tools`, `metadata`). `description` states plainly that this is a manual, explicit provisioning step — never auto-triggers, mirroring `spdd-canvas`/`spdd-design`/`spdd-implement`/`spdd-verify` (canvas Norm: "Provisioning ... never lives inside `spdd-agent`'s feature-build flow").
- `allowed-tools`: `Read Write Edit Bash AskUserQuestion` — no `Agent`/delegation tool, since this skill never launches subagents itself.
- Register it in `CLAUDE.md`'s skill list, `Structure` block, and `Auto-triggers` table (row: "Never auto-triggers on its own. Invoked manually via `/spdd-install`.") — same table shape as the other four phase skills. `Structure` is one of the sections `spdd/specs/spdd-agent.md`'s Norms require byte-identical across `CLAUDE.md` and `AGENTS.md` ("Shared sections of the mirror docs — Structure, Conventions, Gotchas — must stay byte-identical... A shared-section edit is applied to both files in the same pass"), so add the same row to `AGENTS.md`'s `Structure` in the same pass — never edit only one. `Auto-triggers` is technically an audience-specific section under that same Norm (free to differ), but keep it in sync between the two files anyway, matching the existing convention already visible for every other phase skill's row there.

### Step 1 — Guard: config.json must already be complete

- Read `~/.config/spdd/config.json`. Detect the Claude Code host the same way `spdd-agent` Step 1 does (`Bash`: `echo "$CLAUDECODE"`) to pick the applicable section (`claude.models` vs. flat `models`).
- Completeness definition: reuse `spdd-agent` Step 1's own definition exactly — the applicable section must have **all six** phase keys (`canvas`, `design`, `implement`, `verify`, `sync`, `migrate`) present as non-empty strings. Do not invent a second, four-key notion of "complete" here — the guard's job is only to confirm `spdd-agent`'s bootstrap has already run, and six-of-six is how `spdd-agent` itself defines that.
- If the file doesn't exist, fails to parse, or the applicable section is missing any of those six keys: stop immediately with a message pointing the user at `spdd-agent` (or an explicit "view/change the model config" request) to bootstrap it first. Do not install anything, do not open or duplicate any part of `spdd-agent/assets/model-bootstrap.md` (canvas Out of scope, canvas Pending confirmation #5). This is a hard guard, not a confirmation-gated question — there is nothing to confirm yet.
- Once the guard passes, this skill itself only ever *reads* `canvas`, `design`, `implement`, `verify` from the six — `sync`/`migrate` are loaded (as part of the six-key check) but never used past the guard, same as `spdd-agent` Steps 4–8 never touch them either (canvas Out of scope).

### Step 2 — Read the 8 wrapper templates

- Read `spdd-{canvas,design,implement,verify}/assets/agent-claude-code.md` and `spdd-{canvas,design,implement,verify}/assets/agent-opencode.md` (8 files total) directly from the repo. This is the one skill in this repo allowed to reference asset files outside its own folder (canvas Norm exception, mirroring how `spdd-agent` already references the other four skills by name).
- If any of the 8 template files is missing, stop with a clear error — this plan depends on plan-01 having shipped them.

### Step 3 — Confirm and install (Claude Code)

- Show what will be written: the 4 target paths (`~/.claude/agents/spdd-{canvas,design,implement,verify}.md`) and, separately, the 4 `permissions.deny` entries to merge into `~/.claude/settings.json`. Ask via `AskUserQuestion` — a real side-effect action (canvas "Decision transparency" convention, reused here since this skill IS the provisioning step).
- On confirmation:
  - Write each of the 4 Claude Code agent files verbatim from its template (the templates already carry `model: sonnet` as a static fallback — this skill does not rewrite the Claude Code `model:` field, since the per-invocation param from config.json always wins at runtime; canvas field table).
  - Merge `permissions.deny: ["Agent(spdd-canvas)", "Agent(spdd-design)", "Agent(spdd-implement)", "Agent(spdd-verify)"]` into `~/.claude/settings.json`'s `permissions.deny` array — create the file/array if absent, append without removing or duplicating unrelated existing entries (canvas Safeguard: resync must not clobber pre-existing entries).
- If the user declines, do not write anything for Claude Code; still proceed independently with the opencode step below (the two hosts are confirmed separately, since a user may only use one).

### Step 4 — Confirm and install (opencode)

- Show what will be written: the 4 target paths (`~/.config/opencode/agents/spdd-{canvas,design,implement,verify}.md`) and the phase model that will be stamped into each (from config.json). Ask via `AskUserQuestion`.
- On confirmation, for each of the 4 opencode agent files, write from its template with two things filled in from config.json's raw value for that phase:
  - `model:` — the value translated through the documented alias→ID mapping table (canvas Pending confirmation #4) when the config.json value is in tier style rather than already a provider-qualified id; warn (do not fail) when a value can't be translated and fall back to writing it verbatim into `model:`.
  - The `<!-- spdd-install:model-source=<raw-config-value> -->` body comment (right after the frontmatter, per plan-01's template placeholder) — the **untranslated** config.json value, verbatim, even when the translation above fell back to writing it verbatim into `model:` too. This marker is what `spdd-agent` (plan-02) and this skill's own Step 5 below compare against later — never `model:` itself — so a raw-string comparison never needs to repeat the alias→ID translation.

### Step 5 — Resync (re-running over existing files)

- If a target agent file already exists: read its `<!-- spdd-install:model-source=<value> -->` marker and compare it — as a plain string — against config.json's current raw value for that phase. If the marker is missing (a file installed before this marker existed, or hand-edited), treat it the same as a divergence rather than skipping the check, since this skill is the one place equipped to fix it.
  - No divergence: silently treat as up to date (or offer a plain re-write with the same content — no behavior change either way).
  - Divergence (or missing marker): report it, then offer (via `AskUserQuestion`) a confirmation-gated rewrite of **both** the `model:` field (re-translated) and the marker toward config.json's current raw value — never silent, and never update one without the other (canvas Acceptance criteria: "opencode divergence warning, detection vs. remediation split"; canvas Safeguard).
- The Claude Code side has no per-file divergence concept (frontmatter `model:` is always a static fallback, never the source of truth, and carries no marker) — resync there is just "rewrite the 4 files from the current templates," confirmation-gated same as first install.
- `permissions.deny` resync: re-run the same merge as Step 3 — idempotent, never duplicates entries already present.

### Dependency note

Depends on plan-01 only: this plan reads plan-01's 8 template files and writes derived copies at runtime. It has no dependency on plan-02's `spdd-agent/SKILL.md` changes to function on its own (you could technically run `/spdd-install` before plan-02 ships), though the whole feature is only useful once both are implemented.

---

## Out of scope for this plan

- The 8 wrapper template files themselves (plan-01)
- `spdd-agent/SKILL.md` Step 2/3 changes — detection and invocation stay in `spdd-agent`, this plan only provisions what Step 2 later detects (plan-02)
- `spdd-agent/evals/evals.json`, `spdd-install/evals/evals.json`, and `scripts/check-agent-sync.sh` (plan-03)
- Bootstrapping, repairing, or migrating `~/.config/spdd/config.json` — that stays exclusively `spdd-agent/assets/model-bootstrap.md`'s job; this plan only reads an already-complete config (canvas Out of scope, canvas Pending confirmation #5)
