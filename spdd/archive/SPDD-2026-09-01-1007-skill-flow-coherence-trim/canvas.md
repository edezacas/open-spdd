# REASONS: Skill-flow coherence fixes and context trim

> Generated on 2026-09-01 10:07. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.
> Freshness note: all six domain specs were stale at generation time (08-31 prose trims and hook lazy-load never folded back). The user chose to continue without running `spdd-sync` first — the fold-back of this change must reconcile those pending restructures in the affected spec sections, not only this change's own edits.

**Status:** Verified
**Spec:** spdd/specs/spdd-agent.md, spdd-canvas.md, spdd-design.md, spdd-implement.md, spdd-verify.md, spdd-sync.md (cross-domain change — fold-back targets; the Spec-field mechanism itself is deferred — see Review record, point 3)

---

## Requirements

**User story:**
As the maintainer of `open-spdd`, I want the skill flow audited so that operative incoherencies between the seven `SKILL.md` files are fixed and prose that only serves a human reader is trimmed, so that executing agents behave deterministically (no deadlocks, no unread contracts, no missing never-block defaults) and spend fewer context tokens on non-operative text.

**Acceptance criteria:**

*(Each as a WHEN/THEN scenario. MODIFIED marks behavior already spec'd in `spdd/specs/`; NEW marks behavior not yet spec'd.)*

- **[NEW]** Scenario: dependent multi-plan changes cannot deadlock the orchestrator
  - WHEN `spdd-agent` orders plans by their `Depends on:` field and a plan B depends on plan A
  - THEN the gate for launching B's implement phase is "A reached `Status: Implemented`" (matching `spdd-implement` Step 3's own dependency check), not "A finished Step 8 (verify)" — the current text at `spdd-agent/SKILL.md:136` requires A verified while Step 8 (`:140`) requires *every* plan Implemented before any verify runs, which deadlocks any split with dependencies
  - Confirmed: minimal fix — gate aligned to `Status: Implemented` (2026-09-01, foreground checkpoint; recommended default accepted).
- **[NEW]** Scenario: verify checks Norms and Safeguards even when the change was split into plans
  - WHEN `spdd-verify` verifies a plan (a `plans/` folder exists)
  - THEN it reads the plan AND the full `canvas.md` — Norms and Safeguards live only in the canvas (`template-plan.md:3` states both skills "always read both files together"), and `spdd-verify/SKILL.md:22` currently reads the plan only when a plan exists, making its own Steps 3–4 (Norm/Safeguard checks) unverifiable
- **[NEW]** Scenario: the subagent prompt contract references real context locations
  - WHEN `spdd-agent` Step 3.1 describes the prompt contents
  - THEN it points at the actual per-step context lines (Steps 4–8), not the dangling "(table in Step 4)" — no table exists at Step 4 (`spdd-agent/SKILL.md:107`)
- **[NEW]** Scenario: canvas steps that ask the user define a never-block default
  - WHEN `spdd-canvas` Step 6 (freshness) or Step 8 (layers) reaches its ask while running as a background subagent (no `AskUserQuestion` available)
  - THEN each step names its default explicitly (freshness: continue and add `⚠️ Confirm: spec stale — <detail>`; layers: single unified canvas) so the never-block rule has a default to take instead of deadlocking on "Do not generate the canvas until the human has decided" (`spdd-canvas/SKILL.md:58`, `:70`); the fix only supplies the per-step defaults — the never-block protocol itself stays owned by `spdd-agent` Step 3's injected rule and is never restated here (Review record, point 2)
- **[NEW]** Scenario: no double routing when the orchestrator already chose the route
  - WHEN `spdd-agent` delegated the canvas phase after deciding the complete route
  - THEN the subagent prompt states routing was already decided, and `spdd-canvas` Step 2 (applicability guard) is skipped — the user is never re-asked for the canvas they already requested via the orchestrator
- **[NEW]** Scenario: zero-Confirm canvases still reach `Status: Confirmed` *(hygiene-level — demoted per 2026-09-01 review, see Review record point 1)*
  - WHEN the Step 5 checkpoint gate finds zero `⚠️ Confirm:` lines in a saved canvas
  - THEN the canvas still gets `**Status:** Confirmed` before advancing to design (today the zero-Confirm branch at `spdd-agent/SKILL.md:128` skips the status update, leaving the canvas `Draft` while design reads it). Severity note from the review: no consumer branches on the field — `spdd-design` checks no canvas `Status` in any step and `spdd-implement` Step 4 sets `Confirmed` unconditionally — so this is a one-clause hygiene touch-up, not a blocking-level fix; kept because a wrong label misleads humans and future Status-reading tooling
- **[DEFERRED]** Scenario: the target spec is recorded in the artifact, not re-inferred four ways — deferred to its own SPDD change per the 2026-09-01 review: it is the only fix touching the shared template plus three skills and it changes the document schema for all past and future canvases (Review record, point 3; Out of scope). The four per-skill domain heuristics remain the status quo until then.
- **[NEW]** Scenario: trims remove only non-operative prose
  - WHEN any line, sentence, or block is removed or shortened in any `SKILL.md`
  - THEN it is prose whose sole function is explaining rationale, background, or examples to a human reader — never a decision rule, branching condition, exact string, quoted block (the never-block rule), or bash/JSON snippet the executing LLM needs verbatim; every trim must hold under the narrowest background-subagent context (no `CLAUDE.md` inheritance)
- **[MODIFIED]** Scenario: canvas language rule lives in the template, not a dedicated step — changes `spdd/specs/spdd-canvas.md` (Step 3 "Output language" entity/scenario)
  - WHEN a canvas is generated
  - THEN all content is in English, enforced by the template's own `> Language:` note (`template-reasons.md:5`) which the same agent reads while filling it, and `spdd-canvas` Step 3 is deleted as a redundant duplicate — observable output (English canvas) is unchanged
- **[MODIFIED]** Scenario: verify's Step 7.5 meta-justification note is removed — changes `spdd/specs/spdd-verify.md` (Operations row "Foreground/background branch clarification")
  - WHEN `spdd-verify` Step 7 runs
  - THEN the branch behavior (foreground `AskUserQuestion` vs. background `⚠️ Confirm:`) is unchanged, but the sentence explaining "this is not an inconsistency versus other skills" (`spdd-verify/SKILL.md:72`) is gone — it addresses a human reviewer, not the executing agent
- **[MODIFIED]** Scenario: the eval-harness rule loses its repo-specific pointer but keeps its behavior — changes `spdd/specs/spdd-verify.md` (eval-harness scenarios and Operations row)
  - WHEN the scope being verified includes a `SKILL.md` with its own `evals/evals.json`
  - THEN the behavior is unchanged (run the harness, or ask in foreground; background: run if non-trivial, else `⚠️ Confirm:` — never silently treat a diff read as equivalent), but the ~90-word paragraph including the "see this repo's own CLAUDE.md" dogfooding pointer (`spdd-verify/SKILL.md:36`) is reduced to a generic one-liner in the skill, with the dogfooding detail moved to this repo's `CLAUDE.md`/`AGENTS.md`
  - Confirmed: relocate the repo-specific pointer to `CLAUDE.md`/`AGENTS.md` (2026-09-01, foreground checkpoint; recommended default accepted).
- **[NEW]** Scenario: phase-skill descriptions cost less per session without losing the trigger contract
  - WHEN the frontmatter `description` of `spdd-canvas`, `spdd-design`, `spdd-implement`, `spdd-verify`, or `spdd-sync` is trimmed
  - THEN each description still states who triggers it (delegated by `spdd-agent` or invoked manually; never auto-triggers on its own) and what it does — descriptions sit in every session's skill list, so the savings are permanent; `spdd-migrate`'s description is left untouched; this is the only trim with recurring per-session savings and carries guaranteed trim priority — if the scope shrinks it is kept before any other trim (Review record, point 4)
  - Confirmed: scope limited to the 5 phase skills; `spdd-migrate`'s description stays untouched (2026-09-01, foreground checkpoint; recommended default accepted).

**Out of scope:**
- `spdd-migrate/SKILL.md` content (its hook block is a variant, not part of the triplicate; its domain inference stays — legacy docs carry no canvas to read a Spec field from)
- Persisting the `**Spec:**` field (former F7: `template-reasons.md` header field + `spdd-canvas` Step 9 + `spdd-verify` Step 8 + `spdd-sync` Step 1) — deferred to its own SPDD change per the 2026-09-01 review: a document-schema change affecting past and future canvases should not ride along one-phrase deadlock fixes (Review record, point 3)
- `spdd-agent/assets/model-bootstrap.md` (already lazy-loaded; its "worked example" caveat stays per the prior change's resolved Confirm)
- The triplicated `hook-setup.md` assets and their inline grep checks (intentional duplication for standalone portability)
- `spdd/` artifacts of past changes, `evals/evals.json` content (read to verify no regression; only reconciled if an assertion literally quotes trimmed wording)
- Changing any actual decision logic beyond the fixes enumerated above (F7 deferred — see Review record, point 3)

---

## Entities

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| `spdd-agent SKILL.md` | `spdd-agent/SKILL.md` | Existing | 146 lines — fixes F1, F3, F5, F6 + trims T1, T7, T8; richest in meta-prose (AskUserQuestion note `:14–22`, Decision transparency `:24–41` ≈ 20% of file) |
| `spdd-canvas SKILL.md` | `spdd-canvas/SKILL.md` | Existing | 101 lines — fixes F4, F5 (receiving side) + trims T2 (Step 3), T3 (merge Steps 6+7, removes the "same way as the next step" forward reference at `:46`) |
| `spdd-design SKILL.md` | `spdd-design/SKILL.md` | Existing | 57 lines — trim T6 (frontmatter description only) |
| `spdd-implement SKILL.md` | `spdd-implement/SKILL.md` | Existing | 71 lines — trim T6 (frontmatter description only) |
| `spdd-verify SKILL.md` | `spdd-verify/SKILL.md` | Existing | 102 lines — fix F2 + trims T4 (`:72`), T5 (`:36`), T6 |
| `spdd-sync SKILL.md` | `spdd-sync/SKILL.md` | Existing | 41 lines — trim T6 only |
| `template-reasons.md` | `spdd-canvas/assets/template-reasons.md` | Existing | 120 lines — no longer edited here (F7 deferred — Review record, point 3) |
| Repo `CLAUDE.md` / `AGENTS.md` | `CLAUDE.md`, `AGENTS.md` | Existing | Only if the T5 Confirm resolves to "relocate": receive the dogfooding eval-harness note (kept in sync per repo norm) |
| Six domain specs | `spdd/specs/spdd-{agent,canvas,design,implement,verify,sync}.md` | Existing | Fold-back targets; also reconcile the pending 08-31 restructures (see Freshness note) |

---

## Approach

Not a code pattern — a **correctness audit + targeted edit** across existing Markdown instruction files, same class as the prior `SPDD-2026-08-31-1007` change but split in two workstreams:

1. **Coherence fixes (F1–F6; F7 deferred — Review record, point 3):** operative corrections — each changes what an executing agent does (or un-blocks it). These are `NEW` behavior, implemented as minimal edits at the cited locations.
2. **Context trims (T1–T8):** non-operative prose removal under the strict classification from the prior change's canvas: rationale, worked examples, human-facing meta-explanations only. Trims never touch decision rules, branching conditions, exact strings, quoted blocks, or snippets.

**Priority (2026-09-01 review):** F1 and F2 are the blocking-level fixes (both independently verified against `spdd-implement/SKILL.md:36` and `template-plan.md:3` respectively); F6 is demoted to hygiene. Among trims, T6 is the only one with recurring per-session savings (frontmatter descriptions load in every session's skill list, used or not); T1 is second (the orchestrator file loads every turn of every complete-route run); T2–T5, T7–T8 save only when their skill executes. If scope shrinks: T6 retained first, then T1.

**Rationale:**
The prior pass already trimmed easy human-facing prose; what remains is (a) seven real incoherencies found by cross-reading the flow end to end — two of which (F1, F2) produce wrong behavior today, (b) meta-sections in `spdd-agent` that explain the skill to a reader rather than instruct the executor, and (c) cross-file duplication where one authoritative location exists (template language note, phase Report steps). Every edit is checked against the narrowest-context consumer (a background subagent holding only the skill text), which is the yardstick the prior change established.

---

## Structure

```
spdd-agent/SKILL.md                        (F1, F3, F5, F6, T1, T7, T8)
spdd-canvas/SKILL.md                       (F4, T2, T3)
spdd-verify/SKILL.md                       (F2, T4, T5, T6)
spdd-sync/SKILL.md                         (T6)
spdd-design/SKILL.md                       (T6)
spdd-implement/SKILL.md                    (T6)
CLAUDE.md, AGENTS.md                       (T5 only if its Confirm resolves to relocate)
```

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Fix | F1 — dependency gate (`spdd-agent/SKILL.md:136`) | Change "has finished Step 8" → "has reached `Status: Implemented`", aligning the orchestrator's gate with `spdd-implement` Step 3 and removing the deadlock with Step 8's "once every plan is Implemented" precondition |
| Fix | F2 — verify reads the canvas (`spdd-verify/SKILL.md:22`) | Step 2 becomes "Read the plan **and** `canvas.md` in full (Requirements, Norms, and Safeguards live there) plus the current code for every path it touches" |
| Fix | F3 — prompt-contract pointer (`spdd-agent/SKILL.md:107`) | Replace "(table in Step 4)" with "(the exact context listed in Steps 4–8)" |
| Fix | F4 — never-block defaults in canvas (`spdd-canvas/SKILL.md:58,70`) | Step 6: if running in background, do not stop — continue and add `⚠️ Confirm: spec stale — last sync <date>, <n> commits since`; Step 8: default to a single unified canvas with a `⚠️ Confirm:` if the description mentions two concerns; supplies the per-step defaults only — the never-block protocol stays owned by `spdd-agent` Step 3 and is not restated (Review record, point 2) |
| Fix | F5 — no double routing | `spdd-agent` Step 3.1: when delegating canvas, append "routing was already decided (complete route) — skip the applicability guard" |
| Fix | F6 — zero-Confirm checkpoint (`spdd-agent/SKILL.md:128`) — demoted to hygiene per review | Zero-Confirm branch also sets `**Status:** Confirmed` before advancing; one-clause edit — no current consumer branches on the field (`spdd-design` checks no `Status`; `spdd-implement` Step 4 sets it unconditionally) |
| Deferred | F7 — persist the target spec | Deferred to its own SPDD change per the 2026-09-01 review (document-schema change touching the shared template + canvas/verify/sync; see Review record, point 3) — removed from this change's scope |
| Trim | T1 — `spdd-agent` meta-sections (`:14–41`) | Compress the AskUserQuestion note + Decision transparency to ~10 lines: one sentence defining "AskUserQuestion = the host's blocking question mechanism, else plain text + wait", the `[automatic decision]` format + language rule, and the `⚠️ Confirm:` reservation list verbatim; drop the per-step enumeration (Steps 1/2 already print the literal lines) |
| Trim | T2 — canvas Step 3 (`spdd-canvas/SKILL.md:30–32`) | Delete the step; `template-reasons.md:5` is the single authoritative language instruction (the generator reads it while filling the template) |
| Trim | T3 — merge canvas Steps 6+7 (`:42–66`) | One "Context" step: infer domain → freshness check → read spec + norms + risk; removes the "infer the domain the same way as the next step" forward reference |
| Trim | T4 — verify Step 7.5 note (`spdd-verify/SKILL.md:72`) | Delete the three-line meta-justification; the branch itself (foreground/background handling) stays |
| Trim | T5 — verify Step 4 eval paragraph (`:36`) | Reduce to one generic line ("if the scope ships its own eval suite, run it or ask in foreground; never treat a diff read as equivalent"); move the repo-dogfooding pointer to `CLAUDE.md`/`AGENTS.md` (⚠️ Confirm above) |
| Trim | T6 — phase-skill descriptions — **highest trim priority** | Shorten the five frontmatter `description:` values (canvas/design/implement/verify/sync), keeping trigger contract + one-line purpose; the only recurring per-session saving — retained first if scope shrinks |
| Trim | T7 — agent Step 0 examples (`:56`) | Delete the two worked examples ("fix the typo…", "add a missing export…"); the criteria are self-sufficient |
| Trim | T8 — agent Step 3.3 report contract (`:112`) | Reduce to "per the phase skill's own Report step" — `spdd-canvas` Step 12 already specifies path + summary + `⚠️ Confirm:` lines verbatim |
| Constraint | Version bumps | Every edited `SKILL.md` gets `metadata.version` incremented in the same commit |
| Constraint | Eval reconciliation | Re-run affected evals; any assertion quoting a trimmed literal is reconciled (updated or trim reverted) before done |

---

## Norms

- No `spdd/norms.md` exists in this project — this repo's `CLAUDE.md`/`AGENTS.md` conventions apply instead of a team norms file.
- SPDD document content (this canvas, plans, fold-back prose) stays in English — per repo Gotchas.
- Increment `metadata.version` of every edited `SKILL.md` (repo convention: canvas 2.8, design 1.3, implement 2.4, verify 1.8, sync 1.2, agent 1.11 as of today).
- Mirror any `CLAUDE.md` Structure/Conventions/Gotchas edit into `AGENTS.md` (kept in sync per repo norm).
- Each `spdd-*/SKILL.md` stays independently loadable and self-contained — no new runtime file reads outside a skill's own folder (symlinked standalone installs).
- Never remove operative content: decision rules, branching conditions, exact strings, the quoted never-block rule, bash/JSON snippets, or the transparency-line requirements.
- Simplicity First: fixes are one-phrase edits at the cited locations; no restructuring of the flow beyond the deferred F7 (dropped from this change).
- Trim priority is fixed: T6 first (recurring per-session cost), then T1; the remaining trims are droppable if scope shrinks (Review record, point 4).

---

## Safeguards

**Tests to write:**
- [x] Re-run each edited skill's `evals/evals.json`: agent 31–38, 48, 67–68; canvas 1–3, 9–10, 48–50; design 11–14, 29; implement 4–8; verify 15–19, 30–36, 51; sync 20–23
- [x] New evals: background canvas freshness takes the default + `⚠️ Confirm:` (no deadlock); dependent plan B waits for A `Implemented`; verify-with-plan checks canvas Norms/Safeguards; zero-Confirm canvas ends `Confirmed`; orchestrator-delegated canvas skips the applicability guard

> Harness executed 2026-09-01 (foreground; user chose "Harness completo" over the diff-based check
> when asked per `spdd-verify` Step 4): 53 evals, 196 assertions, 0 failures — full per-eval
> `grading.json` under each skill's `evals/workspace/iteration-2/`, consolidated summary in
> `evals/workspace/iteration-2-SPDD-2026-09-01-1007/results.md`. Eval reconciliation: 0 assertions
> quote trimmed literals (no reconciling edits needed).

**Edge cases to consider (as WHEN/THEN scenarios):**

- Scenario: a trim removes something an eval asserts literally
  - WHEN an eval re-run fails because its assertion quotes removed wording
  - THEN the assertion is reconciled (updated to the new wording or the trim reverted) before the change is marked done
- Scenario: a background canvas hits the freshness stop
  - WHEN `spdd-canvas` Step 6 runs as a background subagent and finds domain commits newer than the spec
  - THEN it does not stay blocked: it continues with the default, adds `⚠️ Confirm: spec stale`, and the orchestrator's checkpoint resolves it in the foreground
- Scenario: dependent plans in the orchestrator
  - WHEN `spdd-agent` runs a change split into plans where plan B `Depends on:` plan A
  - THEN B's implement launches once A is `Status: Implemented`; verification of every plan then runs per Step 8, and the fold/archive still waits for all plans `Verified`
- Scenario: verifying a plan without reading the canvas
  - WHEN `spdd-verify` runs on a plan and the canvas contains a Safeguard edge case
  - THEN that edge case is still tested — Step 2 reads both files, so the check cannot silently skip canvas-only content
- Scenario: a description trim breaks triggering
  - WHEN a phase-skill `description` is shortened
  - THEN it still states the delegation/manual invocation contract and its purpose, so host trigger decisions and existing evals about invocation routing keep passing
- Scenario: relocated eval-harness note changes verify behavior
  - WHEN verify's Step 4 runs with a `SKILL.md`+`evals/` scope after T5
  - THEN the observable decision tree is unchanged (harness / foreground ask / background default-or-Confirm; never diff-equivalent) — only the repo-specific pointer text moved
- Scenario: metadata.version not bumped
  - WHEN any `SKILL.md` instruction text changes, even to only remove text
  - THEN its frontmatter version is incremented before the change is marked implemented

**Production rollback:**
Documentation-only repo change with no runtime surface — rollback is a normal `git revert` of the specific commits. No data migration, no user-facing service impact.

---

## Review record (2026-09-01 — external-agent feedback, resolved before design)

1. **F6 demoted to hygiene (accepted).** Evidence: `spdd-design` checks no canvas `Status` in any step, and `spdd-implement` Step 4 sets `**Status:** Confirmed` unconditionally before implementing regardless of prior Confirms — no consumer blocks on the field between checkpoint and implementation. Kept (not dropped) because the fix costs one clause and a `Draft` label after confirmation misleads humans and any future Status-reading tooling. No longer weighted like F1/F2.
2. **F4 scope confirmed, no overlap (accepted as-is).** The fix only names the per-step defaults (freshness: continue + `⚠️ Confirm:`; layers: single unified canvas) that `spdd-canvas` Steps 6/8 fail to provide; the never-block protocol itself stays owned by `spdd-agent` Step 3's injected verbatim rule and is never restated in `spdd-canvas`. The two are complementary halves: the protocol needs a "suggested default" to take, and those steps currently offer none.
3. **F7 deferred to its own SPDD change (accepted — its `⚠️ Confirm` resolved as "defer").** It is the only fix touching the shared template plus three skills, and it changes the document schema for all past and future canvases; mixing it with one-phrase fixes like F1/F2 complicates diff-to-canvas scope and the eval surface. AC scenario removed (tombstone above); the four per-skill domain heuristics stay the status quo until a dedicated change lands it.
4. **T6 given guaranteed trim priority (accepted).** It is the only trim with recurring per-session savings (frontmatter descriptions load in every session's skill list whether or not the skill runs); T1–T5/T7–T8 save only when their skill executes. If this pass must shrink, T6 is kept first, then T1 (the orchestrator file loads every turn of every complete-route run).
5. **Evidence standard noted (accepted).** F1 (deadlock) and F2 (verify never reads the canvas when a plan exists) were independently verified against `spdd-implement/SKILL.md:36` and `template-plan.md:3` — real bugs, not false positives; no re-verification needed. The remaining fixes' citations were re-checked against the same standard during this review and hold: `spdd-agent/SKILL.md:107` (no table exists at Step 4), `spdd-canvas/SKILL.md:58,70` (asks with no named default), double routing (`spdd-canvas` Step 2's guard can fire on an open-ended spike even when `spdd-agent` Step 0 already routed complete).
