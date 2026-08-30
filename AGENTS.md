# open-spdd

## Overview
Structured Prompt-Driven Development (SPDD) skills. Each skill is a directory with a `SKILL.md` file following the agentskills.io format. `spdd-agent` orchestrates the full canvas → design → implement → verify flow from a single feature description; there is no separate agent-file layer for any host — orchestration lives entirely in `spdd-agent/SKILL.md`, which asks the host for an ad-hoc subagent per phase when the host supports launching one, and runs the phase inline otherwise.

## Stack
- Skills: Markdown (`SKILL.md`) — no build step, agentskills.io format

## Auto-triggers

| Skill | When to activate |
|-------|-----------------|
| `spdd-agent` | User describes a new feature in plain language, without naming a specific `/spdd-*` command — the only skill that auto-triggers the canvas → design → implement → verify flow |
| `spdd-canvas` | Never auto-triggers on its own. Invoked manually via `/spdd-canvas`, or delegated by `spdd-agent` as the first phase of its flow |
| `spdd-design` | Never auto-triggers on its own. Invoked manually via `/spdd-design`, or delegated by `spdd-agent`, after a canvas is confirmed |
| `spdd-implement` | Never auto-triggers on its own. Invoked manually via `/spdd-implement`, or delegated by `spdd-agent`, once a plan exists |
| `spdd-verify` | Never auto-triggers on its own. Invoked manually via `/spdd-verify`, or delegated by `spdd-agent`, once implementation is done |
| `spdd-sync` | User refactored code that already has a living spec, outside the SPDD flow, and the spec no longer matches the code's shape — auto-triggers independently |
| `spdd-migrate` | Project still has canvases under the old `docs/prompts/` layout and needs a one-time move to `spdd/` — auto-triggers independently |

## Structure
```
spdd-agent/SKILL.md                   # orchestrates canvas → design → implement → verify from one feature description
spdd-agent/evals/evals.json           # evals 31–38: config request, bootstrap, invalid-config repair, never-block rule, checkpoint gate, dependency order, divergence reopen, inline fallback
spdd-canvas/SKILL.md                  # REASONS canvas generator — /spdd-canvas
spdd-canvas/assets/template-reasons.md
spdd-canvas/assets/template-norms.md  # starting template for a target project's spdd/norms.md
spdd-canvas/evals/evals.json          # evals 1–3, 9–10, 48–50: guard, generation quality, hook, applicability guard, spec read, freshness check, global norms
spdd-design/SKILL.md                  # Canvas → independent implementation plans — /spdd-design
spdd-design/assets/template-plan.md
spdd-design/evals/evals.json          # evals 11–14, 29: single plan, split plans, dependencies, shared touchpoints, existing-plan guard
spdd-implement/SKILL.md               # Canvas/plan-driven implementer — /spdd-implement
spdd-implement/evals/evals.json       # evals 4–8: unresolved items, missing-plan guard, divergence, unmet dependency, final state
spdd-verify/SKILL.md                  # Verifies, tests, folds into spec, archives — /spdd-verify
spdd-verify/evals/evals.json          # evals 15–19, 30–36, 51: missing op, untested safeguard, single-plan archive, partial-plan hold, norm violation, spec dedup on fold-back, diff-to-canvas check, global-norms violation
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
- `spdd/norms.md` (in a target project) holds team-wide, non-negotiable Norms/Safeguards read by `spdd-canvas` (injected into every new canvas) and `spdd-verify` (checked against the implemented diff). No skill creates or edits it — team-maintained, read-only from the skills' side

## Gotchas
- `evals/workspace/` is gitignored; eval results stay local
- `spdd/changes/` canvases/plans with `Status: Draft`, `Confirmed`, or `Implemented` (but not yet `Verified`) are works in progress
- No backward-compat shim for the old `docs/prompts/` layout — projects on the previous version should run `/spdd-migrate` once, which moves canvases to `spdd/changes/`, reformats them to `WHEN/THEN`, and updates the guard hook to the new path automatically
