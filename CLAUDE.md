# open-spdd

## Overview
Structured Prompt-Driven Development (SPDD) skills for Claude Code. Provides automatic and slash-command skills loaded via symlinks into `~/.claude/skills/`. `spdd-agent` orchestrates the full canvas → design → implement → verify flow from a single feature description; there is no `.claude/agents/*.md` layer — orchestration is 100% inside `spdd-agent/SKILL.md`, which asks the host for an ad-hoc subagent (Claude Code: the `Agent` tool) per phase instead of relying on any pre-registered agent file.

## Stack
- Skills: Markdown (`SKILL.md`) — no build step, agentskills.io format

## Evaluating skills

Each skill has an `evals/evals.json` following the [agentskills.io evaluation format](https://agentskills.io/skill-creation/evaluating-skills). The file defines test cases with prompts, expected outputs, and verifiable assertions.

To run evals, load the `evals.json`, execute each prompt against your project (with and without the skill), grade the assertions, and record results in `evals/workspace/` (gitignored). See the agentskills.io docs for the full workspace structure and grading format.

## Structure
```
spdd-agent/SKILL.md                   # orchestrates canvas → design → implement → verify from one feature description
spdd-agent/evals/evals.json           # evals 31–38: config request, bootstrap, invalid-config repair, never-block rule, checkpoint gate, dependency order, divergence reopen, inline fallback
spdd-canvas/SKILL.md                  # REASONS canvas generator — /spdd-canvas
spdd-canvas/assets/template-reasons.md
spdd-canvas/assets/template-norms.md  # starting template for a target project's spdd/norms.md
spdd-canvas/evals/evals.json          # evals 1–3, 9–10, 48–50: guard, generation quality, hook, applicability guard, spec read, freshness check, global norms
spdd-design/SKILL.md                  # canvas → independent implementation plans — /spdd-design
spdd-design/assets/template-plan.md
spdd-design/evals/evals.json          # evals 11–14, 29: single plan, split plans, dependencies, shared touchpoints, existing-plan guard
spdd-implement/SKILL.md               # canvas/plan-driven implementer — /spdd-implement
spdd-implement/evals/evals.json       # evals 4–8: unresolved items, missing-plan guard, divergence, unmet dependency, final state
spdd-verify/SKILL.md                  # verifies, tests, folds into spec, archives — /spdd-verify
spdd-verify/evals/evals.json          # evals 15–19, 30–36, 51: missing op, untested safeguard, single-plan archive, partial-plan hold, norm violation, spec dedup on fold-back, diff-to-canvas check, global-norms violation
spdd-sync/SKILL.md                    # code → living spec sync, behavior-preserving only — /spdd-sync
spdd-sync/evals/evals.json            # evals 20–23: clean refactor sync, behavior-change rejection, ambiguous case, missing spec
spdd-migrate/SKILL.md                 # one-time docs/prompts/ → spdd/ migration — /spdd-migrate
spdd-migrate/evals/evals.json         # evals 24–28: draft migration, implemented preserved, idempotency, hook rewrite, nothing to migrate
evals/workspace/                      # gitignored — local eval results go here
```

## Gotchas
- `evals/workspace/` is gitignored; results stay local.
- SPDD change folders (in a *target* project, not here) follow `spdd/changes/SPDD-YYYY-MM-DD-HHMM-slug/`, each holding `canvas.md` and a `plans/` folder produced by `spdd-design`.
- Unresolved canvas/plan items are marked `⚠️ Confirm:` and must be resolved before implementation.
- SPDD skills always generate document content (canvas, plans, specs, and inline notes) in English, regardless of the language of the feature description or conversation — this reduces reasoning token consumption for downstream skill steps that read these documents as context. Conversational responses to the user follow the conversation's language setting (e.g. your `CLAUDE.md` "Responses in Spanish").
- `spdd/specs/<domain>.md` is the living, cumulative source of truth per domain in a target project — `spdd-verify` writes to it once every plan in a change is verified; `spdd-sync` may later update its Entities/Structure/Operations/Norms (never Requirements) to match a behavior-preserving refactor.
- `spdd/norms.md` (in a target project) holds team-wide, non-negotiable Norms/Safeguards read by `spdd-canvas` (injected into every new canvas) and `spdd-verify` (checked against the implemented diff). No skill creates or edits it — team-maintained, read-only from the skills' side.
- `scripts/check-hook-sync.sh` diffs the hook/TTL block that's duplicated verbatim across `spdd-canvas/SKILL.md`, `spdd-implement/SKILL.md`, and `spdd-verify/SKILL.md`, and fails if any copy has drifted — run it after editing any of those three blocks; it's repo tooling only, never read by a `SKILL.md` at execution time.
- This repo's own `~/.config/spdd/config.json` intentionally runs `canvas`/`design`/`verify` at `sonnet` — one tier below `spdd-agent`'s documented `opus` default — for cost reasons while dogfooding these skills on themselves; `implement` runs at `sonnet`, already matching the framework's own recommended tier. This is a deliberate, revisable cost tradeoff, not unmaintained drift from the framework's own advice.

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
| `spdd-migrate` | Project still has canvases under the old `docs/prompts/` layout and needs a one-time move to `spdd/` — auto-triggers independently, same as today |

### SPDD guard hook

Configured in the *target* project's `.claude/settings.local.json`, not in this repo. Runs before every `Edit` or `Write` and warns if any canvas or plan under `spdd/changes/` has unresolved `⚠️ Confirm:` items.

To install it in a new project, invoke `spdd-canvas`, `spdd-implement`, or `spdd-verify` — all three offer to add it automatically. `spdd-design` doesn't check or install it — by the time it runs, `spdd-canvas` has already offered it. `spdd-sync` never touches `spdd/changes/`, so it doesn't install or check this hook either. `spdd-migrate` rewrites an existing hook that still points at the old `docs/prompts/` path, but doesn't install one from scratch.

When a phase runs as a background subagent under `spdd-agent`, it never installs the hook itself — installing it is a side-effect action, and a background subagent has no `AskUserQuestion` to confirm it with. It leaves a `⚠️ Confirm:` note instead; `spdd-agent`'s foreground checkpoint gate is what actually asks the user and installs it.
