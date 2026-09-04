# Spec: spdd-install

> Living spec for the `spdd-install` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As an SPDD framework user, I want an explicit, manual skill that installs and resyncs the
dedicated per-phase subagent files for Claude Code and opencode, so that `spdd-agent` can use
them in Dedicated mode without provisioning logic living inside the feature-build flow itself.

**Scenario: config.json must already be complete**
- WHEN `/spdd-install` runs and the applicable section of `~/.config/spdd/config.json` (`claude.models` under Claude Code, flat `models` otherwise) is missing, incomplete, or the file doesn't exist
- THEN it stops immediately, points the user at `spdd-agent` to bootstrap the config first, and installs nothing — it never bootstraps, repairs, or migrates the config itself, and never opens or duplicates `spdd-agent/assets/model-bootstrap.md`. Completeness reuses `spdd-agent` Step 1's own six-key definition exactly. This "applicable section" governs only the guard — it does not determine which config section feeds which *target* host's agent files (see the next scenario)

**Scenario: target-host config section is independent of the running host**
- WHEN Steps 3–5 read per-phase model values to write into a target host's agent files
- THEN Claude Code target files always read `claude.models`; opencode target files (Step 4's initial write and Step 5's divergence check) always read the flat top-level `models` key — regardless of which host `/spdd-install` itself is running under. Running it from Claude Code does not mean opencode's values come from `claude.models`; they never do (`spdd-agent/assets/model-bootstrap.md`'s JSON shapes: the flat key is what opencode and every non-Claude-Code host actually reads/writes)

**Scenario: fresh install writes both hosts, confirmed separately**
- WHEN `/spdd-install` runs with no dedicated agent files installed yet
- THEN it reads the 8 wrapper templates from `spdd-{canvas,design,implement,verify}/assets/`, then confirms Claude Code and opencode installation separately via `AskUserQuestion` (a user may only use one host) — declining one still lets the other proceed independently. Claude Code files are written verbatim from their templates (the static `model: sonnet` fallback is never rewritten); opencode files get `model:` and the `spdd-install:model-source` marker stamped in from config.json

**Scenario: opencode model translation via a documented alias table**
- WHEN writing or resyncing an opencode agent file's `model:` field, using the flat `models` key's raw value for that phase (never `claude.models`, per the scenario above)
- THEN a raw value that already looks provider-qualified (contains `/`) is used verbatim; a Claude Code tier alias (`opus`/`sonnet`/`haiku`/`fable`) is translated through this skill's own alias→id table; an untranslatable value only warns, never fails, and falls back to writing the raw value verbatim. The `spdd-install:model-source` marker always holds the untranslated raw value — never `model:` itself — so later divergence comparisons (here and in `spdd-agent`) never need to repeat this translation

**Scenario: resync detects and offers to remediate opencode divergence**
- WHEN `/spdd-install` re-runs over an existing opencode agent file whose `spdd-install:model-source` marker differs from config.json's current raw value, or has no marker at all (pre-marker or hand-edited file)
- THEN it reports the divergence (missing marker counts as one, never silently skipped) and offers, via a confirmation-gated `AskUserQuestion`, to rewrite both `model:` (re-translated) and the marker together toward config.json's current value — never one without the other, never silent or automatic

**Scenario: Claude Code side has no divergence concept**
- WHEN resyncing Claude Code agent files
- THEN there is nothing to compare — the frontmatter `model:` is always a static fallback, never the source of truth, and carries no marker; resync is just a confirmation-gated rewrite of the 4 files from the current templates

**Scenario: permissions.deny merge preserves unrelated entries**
- WHEN installing or resyncing on Claude Code
- THEN the 4 entries `Agent(spdd-canvas)`, `Agent(spdd-design)`, `Agent(spdd-implement)`, `Agent(spdd-verify)` are merged into `~/.claude/settings.json`'s `permissions.deny` array — creating the file/key/array if absent, appending only entries not already present, and never removing, duplicating, or altering any unrelated existing entry

**Scenario: eval coverage**
- WHEN this skill is considered complete
- THEN `spdd-install/evals/evals.json` (evals 82–89) covers: fresh install, missing-config guard, idempotent resync including the tier-alias-vs-translated-id non-divergence case, opencode divergence remediation offer, missing-marker-as-divergence, `permissions.deny` merge non-destructiveness, independent per-host confirmation (declining one doesn't block the other), and target-host config section independence (opencode targets always read the flat `models` key even when running under Claude Code)

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| `spdd-install` skill | `spdd-install/SKILL.md` | New. `allowed-tools: Read Write Edit Bash AskUserQuestion` — no `Agent`/delegation tool, since it never launches subagents itself. Never auto-triggers; reached only by explicit `/spdd-install` |
| Guard: config.json completeness | `spdd-install/SKILL.md` (Step 1) | Reuses `spdd-agent` Step 1's six-key completeness definition exactly (`canvas`, `design`, `implement`, `verify`, `sync`, `migrate`); a hard guard, not a question — nothing to confirm until it passes |
| Dedicated phase agents (user-level, Claude Code) | `~/.claude/agents/spdd-{canvas,design,implement,verify}.md` | Written only at runtime, confirmation-gated; outside the repo |
| Dedicated phase agents (user-level, opencode) | `~/.config/opencode/agents/spdd-{canvas,design,implement,verify}.md` | Written only at runtime, confirmation-gated; carries `model:` + `spdd-install:model-source` marker, both derived from config.json |
| Claude Code auto-delegation deny rules | `~/.claude/settings.json` (`permissions.deny`) | 4 entries, one per wrapper; merged non-destructively |
| Alias → opencode model-id table | `spdd-install/SKILL.md` (Step 4) | Owned and maintained by this skill only — `spdd-agent`'s divergence check never needs a copy, since it only ever compares raw strings against the marker |
| `spdd-install` eval coverage | `spdd-install/evals/evals.json` (evals 82–89) | Fresh install, missing-config guard, idempotent resync, divergence remediation, missing-marker handling, `permissions.deny` non-destructive merge, independent per-host confirmation, target-host config section independence |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Guard: config.json must already be complete" (Step 1) | Detects the Claude Code host the same way `spdd-agent` Step 1 does; stops with a pointer to `spdd-agent` if the applicable section isn't complete |
| Step | "Read the 8 wrapper templates" (Step 2) | Reads `spdd-{canvas,design,implement,verify}/assets/agent-{claude-code,opencode}.md` directly — the one skill allowed to reference asset files outside its own folder |
| Step | "Confirm and install (Claude Code)" (Step 3) | Confirmation-gated write of the 4 CC agent files verbatim from template, plus the `permissions.deny` merge |
| Step | "Confirm and install (opencode)" (Step 4) | Confirmation-gated write of the 4 opencode agent files with `model:` (translated) and `spdd-install:model-source` (raw) filled in per phase |
| Step | "Resync" (Step 5) | Claude Code: unconditional confirmation-gated rewrite from templates. opencode: per-file marker-vs-config.json comparison; on mismatch or missing marker, confirmation-gated rewrite of both `model:` and the marker together |
| Step | "Report" (Step 6) | Which of the 8 files were written/unchanged, whether the `permissions.deny` merge ran, any divergences found and their resolution |

---

## Norms

- This skill never bootstraps, repairs, or migrates `~/.config/spdd/config.json` — that stays exclusively `spdd-agent/assets/model-bootstrap.md`'s job; it only reads an already-complete config.
- Never invoked or offered from inside `spdd-agent`'s feature-build flow (Steps 0–9) — reached only by explicit `/spdd-install`, matching how `spdd-canvas`/`spdd-design`/`spdd-implement`/`spdd-verify` never auto-trigger either.
- The one skill in the repo allowed to read another skill's `assets/` files directly (`spdd-{canvas,design,implement,verify}/assets/agent-*.md`) — cross-skill provisioning is its entire purpose.
- The `spdd-install:model-source` marker, not the translated `model:` field, is always the value compared for divergence — both here and in `spdd-agent` Step 2 — so a raw-string comparison never needs the alias→id table repeated elsewhere.
- A `permissions.deny` merge (or any resync write) never removes or alters an entry it didn't add.
- The config section used for the Step 1 completeness guard (`claude.models` vs. flat `models`, based on the *running* host) is never the same decision as which section feeds a *target* host's agent files: Claude Code targets always read `claude.models`, opencode targets always read the flat `models` key, independent of which host is running `/spdd-install` (fixed 2026-09-04 after a live run wrote Claude Code's `claude.models` values into opencode's agent files).
