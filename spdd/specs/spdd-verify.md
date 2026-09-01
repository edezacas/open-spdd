# Spec: spdd-verify

> Living spec for the `spdd-verify` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team using `spdd-verify`, I want verification to compare the real code diff
against the Operations and Norms of the source canvas/plan before folding into the spec, so that
a passing test can't hide a silent divergence between what was agreed and what was implemented.

**Scenario: diff matches the canvas — proceeds without friction**
- WHEN the real diff of the files modified in the implementation covers exactly the Operations declared in the canvas/plan, without touching files/modules not mentioned
- THEN `spdd-verify` reports the check as passed in a short line and continues to fold-to-spec (Step 8) without asking for confirmation

**Scenario: the diff touches a file not declared in the canvas — blocks**
- WHEN the real diff includes changes to a file or module that doesn't appear in Structure, Shared touchpoints, or Operations of the canvas/plan being verified
- THEN `spdd-verify` stops the process before the fold, shows the concrete discrepancy (file touched vs. what the canvas declares) and does not mark the scope as `Verified` or fold anything into `spdd/specs/<domain>.md`

**Scenario: a canvas Operation has no corresponding code in the diff — blocks**
- WHEN an Operation listed in the canvas/plan has no corresponding change in the real diff (code "connected to nothing" or outright missing)
- THEN `spdd-verify` stops the process before the fold, names the Operation with no real implementation, and does not mark the scope as `Verified`

**Scenario: discrepancy confirmed as intentional by the human — the fold proceeds**
- WHEN a discrepancy is detected (undeclared file or Operation with no code) and the human explicitly confirms, in a session with a live turn, that it is intentional
- THEN `spdd-verify` uses `AskUserQuestion` to ask for that confirmation, and if confirmed, continues to fold-to-spec, annotating the accepted discrepancy as a note in the fold (e.g. an Operation out of scope for this iteration, documented as such)

**Scenario: discrepancy detected while running as a background subagent under spdd-agent**
- WHEN `spdd-verify` runs as a background subagent delegated by `spdd-agent` (no live user turn, no `AskUserQuestion` usefully available) and the Diff-to-canvas check finds a discrepancy
- THEN `spdd-verify` does not stay blocked waiting for a reply that can't arrive — it treats the discrepancy the same as a Step 6 (Structural check/tests) failure: it stops the process, leaves the plan/canvas as is, does not fold or archive anything, reports the concrete gap, and adds a `⚠️ Confirm:` line to the plan/canvas for `spdd-agent`'s foreground checkpoint to resolve later

**Scenario: `spdd-verify` writes new prose to the spec or discrepancy notes**
- WHEN `spdd-verify` folds a change into `spdd/specs/<domain>.md` (Step 8, "Fold back and
  archive") or writes a discrepancy/`⚠️ Confirm:` note during the Diff-to-canvas check (Step 7)
- THEN that new prose (not just content copied from the source canvas/plan) is written in
  English, consistent with the rest of the document it's added to

**Scenario: verification scope includes a `SKILL.md` with its own `evals/evals.json`**
- WHEN the scope being verified (Step 4, "Put the implementation to the test") includes a `SKILL.md` file that ships its own `evals/evals.json`
- THEN `spdd-verify` either runs that eval suite, or — in a foreground session — asks via `AskUserQuestion` whether a lighter diff-based check is acceptable; in background (no `AskUserQuestion` available), it defaults to running the suite when the change is non-trivial, or leaves a `⚠️ Confirm:` note if running it isn't feasible — it never silently treats a diff read as equivalent to re-running the evals (wording made host-generic in v1.9: the repo-specific `CLAUDE.md` pointer now lives in this repo's own `CLAUDE.md` "Evaluating skills" section)

**Scenario: eval-harness branch does not fire on non-`SKILL.md` scope**
- WHEN the verification scope contains no `SKILL.md` file at all
- THEN Step 4 behaves exactly as before this change — no eval harness is considered and no question is raised about it

**Scenario: verify reads the canvas even when verifying a plan**
- WHEN `spdd-verify` verifies a plan (a `plans/` folder exists)
- THEN Step 2 reads the chosen plan AND `canvas.md` in full — Requirements, Norms, and Safeguards live in the canvas and apply to every plan (with no `plans/` folder, the canvas alone is the scope) — so canvas-only Norms are checked and canvas-only Safeguard edge cases get targeted tests; no canvas-only content is silently skipped because the plan does not mention it (v1.9)

**Out of scope (deliberate):**
- Improvement 4 (`spdd/norms.md` as an additional verification source) — the Diff-to-canvas check validates only against the source canvas/plan, not against project-wide norms.
- No static code analysis is introduced (linters, AST, etc.) — the diff-vs-canvas comparison relies on the agent's own reasoning when reading the diff, the same way `spdd-canvas` already does to generate the canvas.
- The pre-existing Step 3 (Structural check) doesn't change — the new Step 7 complements it using the real git diff instead of just reading declared paths.

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| "Diff-to-canvas check" section | `spdd-verify/SKILL.md` | Step 7, between Step 6 (Mark status) and Step 8 (Fold back and archive) |
| Language note | `spdd-verify/SKILL.md` | Placed right after the Diff-to-canvas check gates (Step 7) and before "Fold back and archive" (Step 8) — covers new prose written in both steps |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Diff-to-canvas check" (Step 7, between Step 6 "Mark status" and Step 8 "Fold back and archive") | Gets the real diff of the files modified in this implementation (`git diff` for uncommitted changes; `git log -p`/`git log --stat` over the paths declared in Structure/Shared touchpoints of the plan/canvas if already committed) and compares it point by point against the Operations and Norms of the canvas/plan being verified |
| Branch | Eval-suite check (Step 4, end) | If scope includes its own eval suite (e.g. a `SKILL.md` with `evals/evals.json`): run it, or (foreground) ask via `AskUserQuestion` whether a lighter diff-based check suffices; (background) run the suite if non-trivial, else leave `⚠️ Confirm:` — never silently diff-equivalent |
| Step | "Ensure the SPDD hook and subagent cache TTL" (Step 9, Claude Code only) | Lazy-loaded since v1.8: inline grep check against `.claude/settings.local.json`; asks before any write; merges from the skill's own `assets/hook-setup.md` only when something is missing |
| Check | Operations coverage | Every Operation in the canvas/plan must have corresponding code in the diff; if any is missing, it's a blocking discrepancy |
| Check | Diff scope | No file/module touched in the diff may fall outside Structure, Shared touchpoints, or Operations of the canvas/plan; if it does, it's a blocking discrepancy — except test files that `spdd-verify`'s own Step 4 created during this same verification, which are exempt from the check since they're an expected byproduct of verification, not of the original implementation diff |
| Gate | Discrepancy in a session with a live turn (foreground) | Uses `AskUserQuestion` to ask the human whether the discrepancy is intentional; if confirmed, continues to the fold, annotating the accepted discrepancy; if not confirmed or answered without clarity, stops the process without folding |
| Gate | Discrepancy in a background subagent (delegated by `spdd-agent`) | Doesn't use `AskUserQuestion` (no live user turn) — treats the discrepancy the same as a Step 6 failure: stops the process, doesn't fold, reports the gap, leaves a `⚠️ Confirm:` line in the plan/canvas |
| Report | Concrete discrepancy | Format: "Canvas declares: `<Operation or path>` → Actual code: `<what the diff shows, or its absence>`" — never a generic "doesn't match" |
| Note | Language note in `spdd-verify/SKILL.md` (near Steps 7–8) | States that any new prose written during the Diff-to-canvas check (discrepancy notes, `⚠️ Confirm:` lines) or during Fold back and archive (new scenarios/Norms added to the spec, fold annotations) must be in English, regardless of the user's conversation language — the canvas/plan/spec documents are always in English; conversational replies to the user follow the conversation's language settings |

---

## Norms

- Simplicity First: the Diff-to-canvas check introduces no static analysis or external tools — only diff reading and the agent's own reasoning.
- The Diff-to-canvas check (Step 7) complements Step 3 (Structural check) without duplicating it: Step 3 still checks declared-path coverage; Step 7 uses the real git diff as objective evidence.
- Increment `metadata.version` in `spdd-verify/SKILL.md` on any edit to its instructions (currently at 1.9, cumulative across changes).
- Never fold into `spdd/specs/<domain>.md` while an unresolved discrepancy exists — neither in foreground without explicit confirmation, nor in background under `spdd-agent`.
- New prose `spdd-verify` writes during the Diff-to-canvas check (Step 7) or the fold-to-spec step (Step 8) must be in English, regardless of the conversation's language.
- "Non-trivial" (for the background default on the eval-harness branch) means anything beyond a single-sentence/single-line prose edit with no new decision logic, branch, or exact string added/removed.
