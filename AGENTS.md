# open-spdd

## Overview
Structured Prompt-Driven Development (SPDD) skills. Each skill is a directory with a `SKILL.md` file following the agentskills.io format.

## Stack
- Skills: Markdown (`SKILL.md`) — no build step, agentskills.io format

## Structure
```
spdd-canvas/SKILL.md                  # REASONS canvas generator — /spdd-canvas
spdd-canvas/assets/template-reasons.md
spdd-canvas/evals/evals.json          # evals 1–3, 9–10: guard, generation quality, hook, applicability guard, spec read
spdd-design/SKILL.md                  # Canvas → independent implementation plans — /spdd-design
spdd-design/assets/template-plan.md
spdd-design/evals/evals.json          # evals 11–14, 29: single plan, split plans, dependencies, shared touchpoints, existing-plan guard
spdd-implement/SKILL.md               # Canvas/plan-driven implementer — /spdd-implement
spdd-implement/evals/evals.json       # evals 4–8: unresolved items, missing-plan guard, divergence, unmet dependency, final state
spdd-verify/SKILL.md                  # Verifies, tests, folds into spec, archives — /spdd-verify
spdd-verify/evals/evals.json          # evals 15–19, 30: missing op, untested safeguard, single-plan archive, partial-plan hold, norm violation, spec dedup on fold-back
spdd-sync/SKILL.md                    # Code → living spec sync, behavior-preserving only — /spdd-sync
spdd-sync/evals/evals.json            # evals 20–23: clean refactor sync, behavior-change rejection, ambiguous case, missing spec
spdd-migrate/SKILL.md                 # One-time docs/prompts/ → spdd/ migration — /spdd-migrate
spdd-migrate/evals/evals.json         # evals 24–28: draft migration, implemented preserved, idempotency, hook rewrite, nothing to migrate
evals/workspace/                      # gitignored — local eval results go here
```

## Conventions
- `SKILL.md` files are pure Markdown — no agent-specific syntax
- SPDD change folders (in a *target* project, not here) follow the naming pattern `spdd/changes/SPDD-YYYY-MM-DD-HHMM-slug/`, each holding `canvas.md` and a `plans/` folder produced by `spdd-design`
- Acceptance criteria and Safeguards edge cases are written as `WHEN/THEN` scenarios, not freeform checkboxes
- Unresolved canvas/plan items are marked `⚠️ Confirm:` and must be resolved before implementation
- `spdd/specs/<domain>.md` is the living, cumulative source of truth per domain in a target project — `spdd-verify` writes to it once every plan in a change is verified; `spdd-sync` may later update its Entities/Structure/Operations/Norms (never Requirements) to match a behavior-preserving refactor

## Gotchas
- `evals/workspace/` is gitignored; eval results stay local
- `spdd/changes/` canvases/plans with `Status: Draft`, `Confirmed`, or `Implemented` (but not yet `Verified`) are works in progress
- No backward-compat shim for the old `docs/prompts/` layout — projects on the previous version should run `/spdd-migrate` once, which moves canvases to `spdd/changes/`, reformats them to `WHEN/THEN`, and updates the guard hook to the new path automatically
