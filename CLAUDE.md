# open-spdd

## Overview
Structured Prompt-Driven Development (SPDD) skills for Claude Code. Provides automatic and slash-command skills loaded via symlinks into `~/.claude/skills/`. `spdd-agent` orchestrates the full canvas → design → implement → verify flow from a single feature description; there is no `.claude/agents/*.md` layer — orchestration is 100% inside `spdd-agent/SKILL.md`, which asks the host for an ad-hoc subagent (Claude Code: the `Agent` tool) per phase instead of relying on any pre-registered agent file.

## Stack
- Skills: Markdown (`SKILL.md`) — no build step, agentskills.io format

## Evaluating skills

Each skill has an `evals/evals.json` following the [agentskills.io evaluation format](https://agentskills.io/skill-creation/evaluating-skills). The file defines test cases with prompts, expected outputs, and verifiable assertions.

To run evals, load the `evals.json`, execute each prompt against your project (with and without the skill), grade the assertions, and record results in `evals/workspace/` (gitignored). See the agentskills.io docs for the full workspace structure and grading format.

When `spdd-verify` verifies one of this repo's own skills (its Step 4 eval-suite branch), the harness procedure to use is the one described in this section — the repo-specific pointer that used to live in `spdd-verify/SKILL.md` was relocated here (2026-09-01); in any other project, `spdd-verify`'s generic eval-suite rule applies as written in its own `SKILL.md`.

## Structure
```
spdd-agent/SKILL.md                   # orchestrates canvas → design → implement → verify from one feature description
spdd-agent/assets/model-bootstrap.md  # first-run/repair/migration/malformed model-config flows + JSON shape examples, read only when Step 1's completeness check finds the applicable section incomplete
spdd-agent/evals/evals.json           # routing, config request, bootstrap, invalid-config repair, never-block rule, checkpoint gate, dependency order, divergence reopen, inline fallback, isolated-without-model-override, malformed shape, fast path, parse failure
spdd-canvas/SKILL.md                  # REASONS canvas generator — /spdd-canvas
spdd-canvas/assets/template-reasons.md
spdd-canvas/assets/template-norms.md  # starting template for a target project's spdd/norms.md
spdd-canvas/assets/hook-setup.md      # guard-hook + cache-TTL JSON, read only when the check finds it missing
spdd-canvas/evals/evals.json          # guard, generation quality, hook, applicability guard, spec read, freshness check, global norms
spdd-design/SKILL.md                  # Canvas → independent implementation plans — /spdd-design
spdd-design/assets/template-plan.md
spdd-design/evals/evals.json          # single plan, split plans, dependencies, shared touchpoints, existing-plan guard
spdd-implement/SKILL.md               # Canvas/plan-driven implementer — /spdd-implement
spdd-implement/assets/hook-setup.md   # same as spdd-canvas/assets/hook-setup.md, duplicated for standalone install
spdd-implement/evals/evals.json       # unresolved items, missing-plan guard, divergence, unmet dependency, final state
spdd-verify/SKILL.md                  # Verifies, tests, folds into spec, archives — /spdd-verify
spdd-verify/assets/hook-setup.md      # same as spdd-canvas/assets/hook-setup.md, duplicated for standalone install
spdd-verify/evals/evals.json          # missing op, untested safeguard, single-plan archive, partial-plan hold, norm violation, spec dedup on fold-back, diff-to-canvas check, global-norms violation
spdd-sync/SKILL.md                    # Code → living spec sync, behavior-preserving only — /spdd-sync
spdd-sync/evals/evals.json            # clean refactor sync, behavior-change rejection, ambiguous case, missing spec
spdd-migrate/SKILL.md                 # One-time docs/prompts/ → spdd/changes|archive + docs/features/ → spdd/specs/ migration — /spdd-migrate
spdd-migrate/evals/evals.json         # draft stays active, closed canvas archived, idempotency, hook rewrite, nothing to migrate, spec fold, orphan fold, fold idempotency, status-agnostic routing
evals/workspace/                      # gitignored — local eval results go here
```

## Conventions
- `SKILL.md` files are pure Markdown — no agent-specific syntax
- SPDD change folders (in a *target* project, not here) follow the naming pattern `spdd/changes/SPDD-YYYY-MM-DD-HHMM-slug/`, each holding `canvas.md` and a `plans/` folder produced by `spdd-design`
- Acceptance criteria and Safeguards edge cases are written as `WHEN/THEN` scenarios, not freeform checkboxes
- Unresolved canvas/plan items are marked `⚠️ Confirm:` and must be resolved before implementation
- `spdd/specs/<domain>.md` is the living, cumulative source of truth per domain in a target project — `spdd-verify` writes to it once every plan in a change is verified; `spdd-sync` may later update its Entities/Structure/Operations/Norms (never Requirements) to match a behavior-preserving refactor
- `spdd/norms.md` (in a target project) holds team-wide, non-negotiable Norms/Safeguards read by `spdd-canvas` (injected into every new canvas) and `spdd-verify` (checked against the implemented diff). No skill creates or edits it — team-maintained, read-only from the skills' side

## Gotchas
- `evals/workspace/` is gitignored; eval results stay local
- When `spdd-verify` verifies one of this repo's own skills (its Step 4 eval-suite branch), the harness procedure to use is the one in `CLAUDE.md`'s "Evaluating skills" section — the repo-specific pointer was relocated there from `spdd-verify/SKILL.md` (2026-09-01); in any other project, `spdd-verify`'s generic eval-suite rule applies as written in its own `SKILL.md`
- `spdd/changes/` canvases/plans with `Status: Draft`, `Confirmed`, or `Implemented` (but not yet `Verified`) are works in progress
- SPDD skills always generate document content (canvas, plans, specs, and inline notes) in English, regardless of the language of the feature description or conversation — this reduces reasoning token consumption for downstream skill steps that read these documents as context. Conversational responses to the user follow the conversation's language setting (e.g. your `CLAUDE.md` "Responses in Spanish").
- No backward-compat shim for the old `docs/prompts/` layout — projects on the previous version should run `/spdd-migrate` once, which reformats old canvases to `WHEN/THEN` and routes each one by whether it's closed (`Status: Implemented`, or a paired `docs/features/<slug>.md` exists): closed goes to `spdd/archive/` as `Status: Verified`, everything else stays `Status`-preserved in `spdd/changes/`. It also folds `docs/features/<slug>.md` — the pre-rework equivalent of `spdd/specs/<domain>.md` — into the matching domain spec, and updates the guard hook to the new path automatically
- The hook/TTL setup block lives in each skill's own `assets/hook-setup.md` (`spdd-canvas/assets/hook-setup.md`, `spdd-implement/assets/hook-setup.md`, `spdd-verify/assets/hook-setup.md`) — duplicated on purpose since skills install and run independently via symlink, so nothing can reference a shared file outside its own folder. Each `SKILL.md` inlines a one-sentence presence check (grep `.claude/settings.local.json` for `SPDD` and `"subagentPromptCacheTtl"`) and reads its own `assets/hook-setup.md` when the check shows something missing, instead of always paying the block's token cost. `scripts/check-hook-sync.sh` diffs the three asset copies and fails if any has drifted — run it after editing any of them; it's repo tooling only, never read by a `SKILL.md` at execution time
- Same lazy-load pattern applies to `spdd-agent/assets/model-bootstrap.md`: Step 1 of `spdd-agent/SKILL.md` keeps host detection and a lightweight JSON completeness check inline, and only reads `model-bootstrap.md` (first-run bootstrap, repair, migration, malformed/unparseable flows, or an explicit request to change a value, plus the JSON shape examples) when that check finds the applicable section (`claude.models` under Claude Code, flat `models` otherwise) incomplete or a value change was explicitly requested. `model-bootstrap.md` is the sole owner of every `AskUserQuestion` mechanic and config write for these cases — `SKILL.md` never restates them, only routes to the asset. Unlike `hook-setup.md`, this asset has no duplicate copies — it's `spdd-agent`-only — so `check-hook-sync.sh` doesn't cover it
- This repo's own `~/.config/spdd/config.json` intentionally runs `canvas`/`design`/`verify` at `sonnet` — one tier below `spdd-agent`'s documented `opus` default — for cost reasons while dogfooding these skills on themselves; `implement` runs at `sonnet`, already matching the framework's own recommended tier. This is a deliberate, revisable cost tradeoff, not unmaintained drift from the framework's own advice. Since the claude-code-config-namespace feature, `spdd-agent`'s Step 1 nests these six values under a `claude` namespace (`{"claude": {"models": {...}}}`) whenever it detects Claude Code as the host (a `Bash` check of the `CLAUDECODE` env var); on this machine the one-time, non-destructive migration (flat key copied into `claude`, left untouched) has been run (2026-09-01) — the file now carries both the original flat `models` key and the new `claude.models` namespace, both still `sonnet` across all six phases

## Claude Code Integration

Tool permissions are declared per skill via `allowed-tools:` in its own `SKILL.md` frontmatter, not documented separately here — that keeps them portable to any agentskills.io host instead of living only in this Claude Code-specific file.

### Auto-triggers

| Skill | When to activate |
|-------|-----------------|
| `spdd-agent` | User describes a new feature in plain language, without naming a specific `/spdd-*` command — the only skill that auto-triggers the canvas → design → implement → verify flow |
| `spdd-canvas` | Never auto-triggers on its own. Invoked manually via `/spdd-canvas`, or delegated by `spdd-agent` as the first phase of its flow |
| `spdd-design` | Never auto-triggers on its own. Invoked manually via `/spdd-design`, or delegated by `spdd-agent`, after a canvas is confirmed |
| `spdd-implement` | Never auto-triggers on its own. Invoked manually via `/spdd-implement`, or delegated by `spdd-agent`, once a plan exists |
| `spdd-verify` | Never auto-triggers on its own. Invoked manually via `/spdd-verify`, or delegated by `spdd-agent`, once implementation is done |
| `spdd-sync` | User refactored code that already has a living spec, outside the SPDD flow, and the spec no longer matches the code's shape — auto-triggers independently, same as today |
| `spdd-migrate` | Project still has canvases under the old `docs/prompts/` layout or feature docs under `docs/features/` and needs a one-time move to `spdd/` — auto-triggers independently, same as today |

### SPDD guard hook

Configured in the *target* project's `.claude/settings.local.json`, not in this repo. Runs before every `Edit` or `Write` and warns if any canvas or plan under `spdd/changes/` has unresolved `⚠️ Confirm:` items.

To install it in a new project, invoke `spdd-canvas`, `spdd-implement`, or `spdd-verify` — all three offer to add it automatically. `spdd-design` doesn't check or install it — by the time it runs, `spdd-canvas` has already offered it. `spdd-sync` never touches `spdd/changes/`, so it doesn't install or check this hook either. `spdd-migrate` rewrites an existing hook that still points at the old `docs/prompts/` path, but doesn't install one from scratch.
- `spdd-migrate` routes each old canvas by whether it's closed (`Status: Implemented`, or a paired `docs/features/<slug>.md` exists) — closed canvases go to `spdd/archive/` with `Status: Verified`; everything else stays `Status`-preserved in `spdd/changes/`, same as active work from any other skill. `docs/features/<slug>.md` — the pre-rework equivalent of `spdd/specs/<domain>.md` — gets folded into the matching domain spec (paired with a closed canvas, or orphaned with no canvas at all), tagged with an HTML comment marker per source file so re-running the skill doesn't duplicate the fold.

When a phase runs as a background subagent under `spdd-agent`, it never installs the hook itself — installing it is a side-effect action, and a background subagent has no `AskUserQuestion` to confirm it with. It leaves a `⚠️ Confirm:` note instead; `spdd-agent`'s foreground checkpoint gate is what actually asks the user and installs it.
