# Spec: spdd-agent

> Living spec for the `spdd-agent` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**Scenario: direct route activates and is announced**
- WHEN the user describes a change that touches 1-2 files, is mechanical or of evident scope, and there is no business or architectural ambiguity
- THEN `spdd-agent` shows the line `Direct route: <reason> → implementing without a canvas.` before executing, implements the change directly without generating a canvas or plan, and does not invoke `spdd-canvas`/`spdd-design`/`spdd-verify`

**Scenario: complete route by default when in doubt**
- WHEN the change touches 3+ files, requires understanding multiple parts of the system, there is any business/architectural ambiguity, or the agent is not sure which route applies
- THEN `spdd-agent` follows the complete canvas → design → implement → verify flow exactly as it exists today, with no exception — doubt always resolves in favor of the complete route

**Scenario: model bootstrap does not block the direct route**
- WHEN the routing decision resolves to direct route
- THEN `spdd-agent` does NOT trigger the `~/.config/spdd/config.json` bootstrap before implementing, because the direct route does not launch subagents and does not need that configuration; the routing check is always evaluated before Step 1's model bootstrap, and bootstrap only triggers if the final decision is the complete route

**Scenario: direct route requires passing tests before touching the spec**
- WHEN `spdd-agent` implements via the direct route
- THEN it runs the test suite for the affected area before annotating the summary in `spdd/specs/<domain>.md`; if any test fails, it does not annotate anything in the spec, reports the concrete failure to the user, and does not revert the code automatically — the decision to revert or fix is left to the human

**Scenario: eval coverage for the routing rule**
- WHEN the routing improvement is considered complete
- THEN `spdd-agent/evals/evals.json` contains cases covering: direct route activated, complete route activated, the 2-vs-3-files boundary case with a shared module, business ambiguity in a 1-file change, test failure on the direct route without auto-revert, domain fallback to `spdd/specs/general.md`, and first-run bootstrap combined with the complete route

**Scenario: direct route with no inferable domain**
- WHEN the change doesn't allow a clear domain to be inferred (doesn't follow a folder convention like `src/<domain>/`)
- THEN it uses `spdd/specs/general.md` as a fallback, the same as `spdd-canvas` already does

**Out of scope (deliberate):**
- No automatic verification is added that the chosen route ("direct" vs. "complete") was "the correct one" — it is deliberately heuristic and fallible; real quality control lives in a separate improvement (diff vs. canvas in `spdd-verify`, not yet implemented).

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| "Routing" section (Step 0) | `spdd-agent/SKILL.md` | Evaluates direct vs. complete route before any other step |
| Model config | `~/.config/spdd/config.json` | Conditional bootstrap: only triggers if the chosen route is "complete" |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Classify change scope" (Step 0, routing decision) | Decides direct vs. complete route based on number of files and presence of business/architectural ambiguity, before invoking any phase |
| Route | Direct route | Implements without a canvas or plan, runs the test suite for the affected area, annotates a summary in `spdd/specs/<domain>.md` only if tests pass |
| Route | Complete route | canvas → design → implement → verify, unchanged from the pre-existing flow |
| Output | Transparency line | `Direct route: <reason> → implementing without a canvas.` — shown whenever the direct route is chosen, before executing any change |

---

## Norms

- When in doubt between direct and complete route, ALWAYS choose the complete route.
- Do not add automatic verification that the chosen route was "the correct one".
- Increment `metadata.version` in `spdd-agent/SKILL.md` on any edit to its instructions.
