# First-run onboarding (guide, bootstrap hand-off)

Opened only by `spdd-agent` Step 1, and only when the completeness check classifies the run as the file-doesn't-exist case — a first run. It owns the first-run sequence: guide → bootstrap hand-off. Everything here runs in the foreground of the orchestrator's conversation. The asset is never opened for the repair, migration, malformed/unparseable, or explicit-change cases — those go straight to [model-bootstrap.md](model-bootstrap.md), with no guide and no per-phase one-liners.

"First run" is conversation-scoped state — the onboarding ran earlier in this same run — never a file or marker on disk. If a run aborts before the onboarding finishes, nothing partial is left behind beyond what was explicitly confirmed, and the next run re-enters this asset only if `~/.config/spdd/config.json` is still missing.

## 1. Guide (before any model-choice question)

Present, in the conversation's language, a short paragraph — not a manual — covering:

- What the flow does: `spdd-agent` runs one feature description through canvas → design → implement → verify, delegating each phase and pausing at foreground checkpoints between them.
- What it will ask: every `⚠️ Confirm:` item and every side-effecting action (writing config, installing files) is a real question that waits for an answer; routine choices are announced as one-line `[automatic decision]` transparency lines instead.
- Where artifacts are written: `spdd/changes/<change-id>/` (canvas + plans) and `spdd/specs/<domain>.md` (the living spec, filled in at verification).

Show the guide before the first model-choice question of the bootstrap below, and keep it to a few lines.

## 2. Bootstrap hand-off

Apply [model-bootstrap.md](model-bootstrap.md)'s "First-run bootstrap" section exactly as documented there — that file stays the sole owner of every bootstrap `AskUserQuestion` mechanic and of the config write; this asset neither restates nor duplicates them. When its first-run section finishes, continue below.

Step 1's continuation rule applies unchanged from here: for the ordinary feature flow, proceed to Step 2; for an explicit config request, report the resulting config and stop — do not proceed to Step 2.

## 3. Per-phase one-liners (first run only)

If the onboarding ran earlier in this same run, precede each phase launch (Steps 4, 6, 7, 8) with one short line in the conversation's language, alongside the existing `[automatic decision]` lines. Templates — adapt, don't copy verbatim:

- **Canvas (Step 4):** "Launching the canvas phase: it writes the feature's REASONS canvas under `spdd/changes/<change-id>/` and comes back with any `⚠️ Confirm:` items to resolve."
- **Design (Step 6):** "Launching the design phase: it turns the confirmed canvas into one or more implementation plans under the same change folder."
- **Implement (Step 7):** "Launching the implement phase: it implements the plan's Operations step by step and reports what changed."
- **Verify (Step 8):** "Launching the verify phase: it checks the implementation against the canvas, tests uncovered edge cases, and folds the result into the living spec."

Show these on the first run only — never again on later runs, which behave exactly as the pre-onboarding flow did.

## Boundaries

- Project-level setup stays lazy: this onboarding never touches the target project — no guard hook, no `subagentPromptCacheTtl`, no `spdd/` scaffolding, no `spdd/norms.md`. The phase skills keep offering those themselves, as they always have.
- Onboarding text never leaks into artifacts: the guide and the one-liners exist only in the orchestrator's foreground conversation. Canvas, plans, and specs stay in English per the language norm, with no onboarding content inside them.
