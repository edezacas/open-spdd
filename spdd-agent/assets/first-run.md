# First-run onboarding (guide, bootstrap hand-off, dedicated-layer offer)

Opened only by `spdd-agent` Step 1, and only when the completeness check classifies the run as the file-doesn't-exist case — a first run. It owns the first-run sequence: guide → bootstrap hand-off → dedicated-layer offer → optional `spdd-install` invocation. Everything here runs in the foreground of the orchestrator's conversation. The asset is never opened for the repair, migration, malformed/unparseable, or explicit-change cases — those go straight to [model-bootstrap.md](model-bootstrap.md), with no guide, no offer, and no per-phase one-liners.

"First run" is conversation-scoped state — the onboarding ran earlier in this same run — never a file or marker on disk. If a run aborts before the onboarding finishes, nothing partial is left behind beyond what was explicitly confirmed, and the next run re-enters this asset only if `~/.config/spdd/config.json` is still missing.

## 1. Guide (before any model-choice question)

Present, in the conversation's language, a short paragraph — not a manual — covering:

- What the flow does: `spdd-agent` runs one feature description through canvas → design → implement → verify, delegating each phase and pausing at foreground checkpoints between them.
- What it will ask: every `⚠️ Confirm:` item and every side-effecting action (writing config, installing files) is a real question that waits for an answer; routine choices are announced as one-line `[automatic decision]` transparency lines instead.
- Where artifacts are written: `spdd/changes/<change-id>/` (canvas + plans) and `spdd/specs/<domain>.md` (the living spec, filled in at verification).

Show the guide before the first model-choice question of the bootstrap below, and keep it to a few lines.

## 2. Bootstrap hand-off

Apply [model-bootstrap.md](model-bootstrap.md)'s "First-run bootstrap" section exactly as documented there — that file stays the sole owner of every bootstrap `AskUserQuestion` mechanic and of the config write; this asset neither restates nor duplicates them. When its first-run section finishes, continue below.

## 3. Dedicated-layer offer (conditional)

Fire the offer only when **both** conditions hold:

1. The host exposes a subagent mechanism — the same check Step 2's Isolated levels perform (Claude Code's `Agent` tool, opencode's Task tool with a `subagent_type`, or the equivalent). On a host with no subagent mechanism at all, skip the offer entirely — dedicated wrappers would be unusable — while the guide above still shows and the flow continues inline.
2. Not all four dedicated `spdd-<phase>.md` files in the current host's agent directory (`~/.claude/agents/` under Claude Code, `~/.config/opencode/agents/` under opencode) are well-formed — reusing Step 2's exact well-formedness definition (parseable frontmatter, required fields present, non-empty body) and its strictly per-host directory rule; never invent a new definition and never check the other host's directory. Some-but-not-all well-formed still fires the offer (partial install); all four well-formed skips the offer silently.

When both hold, precede the question with one or two lines in the conversation's language explaining the optional dedicated layer (a dedicated per-phase subagent file — deterministic skill preload, per-phase model selection restored on opencode, tools scoped per phase — provisioned by `spdd-install`), then ask via `AskUserQuestion`:

> Run the `/spdd-install` flow now to install the optional dedicated per-phase subagent layer? (Recommended: yes)

Nothing is ever written by this onboarding itself — installing is a side-effect action gated solely by `spdd-install`'s own per-host confirmations.

### On accept

Invoke `spdd-install` in the foreground: through the host's skill-loading mechanism if it has one, otherwise by reading the skill's installed `SKILL.md` and executing it inline (same fallback shape as Inline mode). `spdd-agent` performs none of the installation writes and restates none of `spdd-install`'s steps — its per-host `AskUserQuestion` confirmations remain the only write gate. Phases that just gained dedicated files are picked up naturally later in the same run: Step 2's Dedicated detection is per-phase and late-bound, needing no extra wiring.

Fallbacks:

- If `spdd-install`'s Step 1 hard guard fires (the config ended up incomplete — e.g. an interrupted bootstrap): report the guard's message, never retry and never bypass it, and continue the feature flow in Isolated/Inline mode.
- If the skill cannot be loaded and its `SKILL.md` is unreachable (a per-skill symlink install skipped it): report that the installer skill isn't available — pointing at `README.md`'s manual-install step — write nothing, and continue without the dedicated layer.

### On decline

Note that the dedicated layer stays available via an explicit `/spdd-install` at any time, and continue in Isolated/Inline mode exactly as any non-first run would.

Whether the offer was accepted, declined, or skipped, Step 1's continuation rule applies unchanged from here: for the ordinary feature flow, proceed to Step 2; for an explicit config request, report the resulting config and stop — do not proceed to Step 2.

## 4. Per-phase one-liners (first run only)

If the onboarding ran earlier in this same run, precede each phase launch (Steps 4, 6, 7, 8) with one short line in the conversation's language, alongside the existing `[automatic decision]` lines. Templates — adapt, don't copy verbatim:

- **Canvas (Step 4):** "Launching the canvas phase: it writes the feature's REASONS canvas under `spdd/changes/<change-id>/` and comes back with any `⚠️ Confirm:` items to resolve."
- **Design (Step 6):** "Launching the design phase: it turns the confirmed canvas into one or more implementation plans under the same change folder."
- **Implement (Step 7):** "Launching the implement phase: it implements the plan's Operations step by step and reports what changed."
- **Verify (Step 8):** "Launching the verify phase: it checks the implementation against the canvas, tests uncovered edge cases, and folds the result into the living spec."

Show these on the first run only — never again on later runs, which behave exactly as the pre-onboarding flow did.

## Boundaries

- Project-level setup stays lazy: this onboarding never touches the target project — no guard hook, no `subagentPromptCacheTtl`, no `spdd/` scaffolding, no `spdd/norms.md`. The phase skills keep offering those themselves, as they always have.
- Onboarding text never leaks into artifacts: the guide and the one-liners exist only in the orchestrator's foreground conversation. Canvas, plans, and specs stay in English per the language norm, with no onboarding content inside them.
