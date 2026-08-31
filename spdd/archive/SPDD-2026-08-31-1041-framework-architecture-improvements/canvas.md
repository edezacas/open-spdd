# REASONS: Apply framework architecture improvements to open-spdd's own orchestration

> Generated on 2026-08-31 10:41. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Verified

---

## Requirements

**User story:**
As the maintainer of `open-spdd`, I want the five systemic gaps found in a prior architecture
review (cost-aware splitting in `spdd-design`, eval-harness coverage for `SKILL.md`-only changes
in `spdd-verify`, a missing language note in `spdd-migrate`, undocumented drift risk in the
triplicated hook/TTL block, and undocumented model-tier drift in this repo's own config) closed,
so the orchestration framework stays reliable as it is used to improve itself.

**Acceptance criteria:**

- **[NEW]** Scenario: `spdd-design` avoids over-splitting homogeneous work
  - WHEN every group found in Step 4 applies the *same* Operation type to files of the *same*
    kind (e.g. the same prose trim repeated across N `SKILL.md` files), even though their
    `Structure` paths don't overlap
  - THEN Step 5 emits a single plan with one row per file instead of one plan per file — splitting
    stays reserved for work that is genuinely separable (different operation types, or work meant
    for different people/agents)
- **[NEW]** Scenario: `spdd-verify` has an explicit mechanism for `SKILL.md`-only scope
  - WHEN the verification scope includes a `SKILL.md` file that ships its own `evals/evals.json`
  - THEN `spdd-verify` either actually runs that eval harness or explicitly asks the user
    (`AskUserQuestion`, foreground only) whether a lighter diff-based check is acceptable instead —
    it never silently treats "re-run evals" as satisfied by reading the diff alone
- **[NEW]** Scenario: `spdd-migrate` gets the language note it's missing
  - WHEN `spdd-migrate` Step 2.3 reformats Acceptance Criteria/Safeguards into `WHEN/THEN`
    scenarios (new prose, not copied verbatim from the source file)
  - THEN that reformatted content is written in English, regardless of the conversation's language
    — stated via the same `> **Language note:**` blockquote style already used by `spdd-design`,
    `spdd-verify`, and `spdd-sync`
- **[NEW]** Scenario: hook/TTL block drift across the three copies is caught automatically
  - WHEN `spdd-canvas/SKILL.md` Step 11, `spdd-implement/SKILL.md` Step 5, and
    `spdd-verify/SKILL.md` Step 9 each carry their own copy of the ~25-line hook/TTL bash+JSON
    block
  - THEN a repo-local script can extract and diff the three copies and fail if they differ, so
    drift is caught before it ships instead of relying on manual attention during unrelated edits
- **[NEW]** Scenario: this repo's own model-tier config is no longer silently divergent
  - WHEN a contributor reads `spdd-agent/SKILL.md`'s documented default model tiers and then
    inspects this repo's own `~/.config/spdd/config.json`
  - THEN a note in this repo's own docs explains the difference is intentional (cost-tuned for
    dogfooding) rather than looking like an unmaintained drift from the framework's own advice
- **[NEW]** Scenario: no behavioral regression in evals
  - WHEN each modified skill's `evals/evals.json` is re-run after these changes
  - THEN every existing assertion still passes; these changes add or refine decision logic, they
    don't break any already-covered scenario

**Out of scope:**
- Re-running or re-scoring `spdd-canvas`'s or `spdd-implement`'s own step numbering/placement for
  the language-note instruction — reviewed and found *not* to be an inconsistency worth fixing (see
  Approach below); only `spdd-migrate` actually lacked the note
- Adding brand-new eval IDs beyond what's needed to cover the new branches (no unrelated eval
  expansion)
- Actually bumping `~/.config/spdd/config.json`'s `implement` tier — default is to document the
  gap, not change the config; see ⚠️ Confirm below
- Any change to `spdd-canvas/SKILL.md`, `spdd-implement/SKILL.md`, or `spdd-agent/SKILL.md`'s own
  instructions — none of the 5 findings require editing these three files

---

## Entities

Not a data-model feature — "entities" here are the documents/scripts in scope.

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| `spdd-design SKILL.md` | `spdd-design/SKILL.md` | Existing | Step 5 gets the homogeneity criterion |
| `spdd-verify SKILL.md` | `spdd-verify/SKILL.md` | Existing | Step 4 gets the eval-harness branch; a short note near Step 7.5 documents its foreground/background branching as intentional |
| `spdd-migrate SKILL.md` | `spdd-migrate/SKILL.md` | Existing | Gets a language-note blockquote near Step 2.3, matching `spdd-design`/`spdd-verify`/`spdd-sync`'s style |
| Hook/TTL sync check | `scripts/check-hook-sync.sh` | New | Diffs the three verbatim blocks in `spdd-canvas`, `spdd-implement`, `spdd-verify` |
| `AGENTS.md` | `AGENTS.md` | Existing | Gains a Gotchas line about the sync script, and a note about this repo's own model-tier config |
| `CLAUDE.md` | `CLAUDE.md` | Existing | Same two notes mirrored, per this repo's own convention that `AGENTS.md` and `CLAUDE.md` stay in sync |
| `~/.config/spdd/config.json` | outside this repo (XDG global, not versioned) | Existing | Not modified by default — see ⚠️ Confirm below; if the user later chooses to bump it, that's a manual local edit outside this change's diff |

---

## Approach

**Rationale:**
Four of the five findings are genuine gaps: a missing splitting criterion, a missing
verification mechanism, one skill missing a language note its siblings already have, and
undocumented drift risk/config divergence. The fifth candidate — "standardize the language-note
*placement* across all skills" — was re-examined against the actual specs (`spdd/specs/spdd-canvas.md`,
`spdd/specs/spdd-implement.md`) while drafting this canvas: `spdd-canvas` and `spdd-implement`
place their language rule as an early, dedicated step (Step 3 / Step 0) because *most* of what
they generate is document content across many steps, while `spdd-design`/`spdd-verify`/`spdd-sync`
place theirs as a narrow blockquote *inside* the one step where they actually author new prose.
That's not inconsistency, it's the placement matching each skill's actual authoring surface. The
real gap was narrower than first framed: `spdd-migrate` also authors new prose (Step 2.3's
WHEN/THEN reformatting) but has no language note at all. This canvas scopes the narrower, correct
fix instead of a blanket "standardize everyone" pass.

This is a content/logic edit across existing instruction files plus one new repo-local shell
script — no new skill, no new runtime dependency.

---

## Structure

Files to create or modify:

```
spdd-design/SKILL.md
spdd-verify/SKILL.md
spdd-migrate/SKILL.md
scripts/check-hook-sync.sh   (new)
AGENTS.md
CLAUDE.md
```

Out of this change's diff (see ⚠️ Confirm below):
```
~/.config/spdd/config.json   (outside repo; not touched by default)
```

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Modify | `spdd-design` Step 5 ("Decide: one plan or many") | Add: "If every group found in Step 4 applies the same Operation type homogeneously to files of the same kind, emit a single plan with one row per file instead of splitting — even if their Structure paths don't overlap. Reserve real splitting for groups that differ in Operation type, or that are meant to be handed to different agents/people." |
| Modify | `spdd-verify` Step 4 ("Put the implementation to the test") | Add a conditional sub-step: "If the scope includes a `SKILL.md` file with its own `evals/evals.json`, either run that eval harness (see this repo's own `CLAUDE.md` 'Evaluating skills' section for the procedure) or, in a foreground session, ask via `AskUserQuestion` whether a lighter diff-based check is acceptable instead. In background (no `AskUserQuestion`), default to running the harness if the scope is non-trivial, or leave a `⚠️ Confirm:` note if running it isn't feasible in that context — never silently treat a diff read as equivalent to re-running the evals." |
| Modify | `spdd-verify` — near Step 7 ("Diff-to-canvas check") / Step 7.5 | Add one short line clarifying that the foreground/background branch there is intentional — needed to choose between a real `AskUserQuestion` and a `⚠️ Confirm:` fallback specifically for diff discrepancies — not an inconsistency versus other skills, which rely entirely on `spdd-agent`'s injected never-block rule |
| Modify | `spdd-migrate` — near Step 2, point 3 (WHEN/THEN reformatting) | Add `> **Language note:** Write the reformatted Acceptance Criteria/Safeguards content in English, regardless of the conversation's language.` — same blockquote style already used by `spdd-design`/`spdd-verify`/`spdd-sync` |
| Create | `scripts/check-hook-sync.sh` | Extracts the hook/TTL bash+JSON block from `spdd-canvas/SKILL.md` Step 11, `spdd-implement/SKILL.md` Step 5, and `spdd-verify/SKILL.md` Step 9, and fails with a clear diff if any of the three differ from the other two |
| Modify | `AGENTS.md` Gotchas | Add: reference to `scripts/check-hook-sync.sh` and what it guards; note that this repo's own `~/.config/spdd/config.json` intentionally runs one tier below `spdd-agent`'s documented defaults for cost reasons |
| Modify | `CLAUDE.md` Gotchas | Mirror the same two notes added to `AGENTS.md` (per this repo's own convention/memory: keep both files' Structure/Conventions/Gotchas in sync) |

---

## Norms

Mandatory conventions for this change:

- [ ] No `spdd/norms.md` exists in this project — using this repo's own `CLAUDE.md` / `AGENTS.md` as the applicable conventions instead of a team norms file
- [ ] SPDD document content (this canvas, and any resulting plan) stays in English
- [ ] Any `SKILL.md` whose instructions actually change must have `metadata.version` bumped in its frontmatter (`spdd-design`, `spdd-verify`, `spdd-migrate`)
- [ ] Any edit to `CLAUDE.md`'s Structure/Conventions/Gotchas must be mirrored into `AGENTS.md` (and vice versa) — both are expected to stay in sync
- [ ] `scripts/check-hook-sync.sh` must not become a new implicit runtime dependency for any `spdd-*/` skill folder — it's repo tooling for this repo's own CI/local use, never read by a `SKILL.md` at execution time (portability safeguard, same as the prior trim change's Norm)
- [ ] `allowed-tools:` frontmatter in `spdd-design`, `spdd-verify`, and `spdd-migrate` must still match what the edited instructions actually use

---

## Safeguards

**Tests to write:**
- [ ] Re-run `spdd-design/evals/evals.json` (cases 11–14, 29) — confirm the existing split/single-plan cases still pass, add a case for the new homogeneity criterion (same Operation type across N same-kind files → single plan)
- [ ] Re-run `spdd-verify/evals/evals.json` (cases 15–19, 30–36, 51) — add a case for the new eval-harness branch triggering only when scope includes a `SKILL.md` with its own `evals/evals.json`
- [ ] Re-run `spdd-migrate/evals/evals.json` (cases 24–28) — confirm reformatted output stays in English after the language note is added
- [ ] Run `scripts/check-hook-sync.sh` against the current repo state (all three blocks are already identical — script should pass with no diff reported)

**Edge cases to consider (as WHEN/THEN scenarios):**

- Scenario: the new splitting criterion accidentally merges genuinely separable work
  - WHEN two groups happen to be small but apply *different* Operation types (e.g. one is a trim, the other is a new branch of logic)
  - THEN Step 5 must still split them — the criterion requires both same Operation type *and* same file kind, not just "small enough"
- Scenario: the new eval-harness branch fires on scope that doesn't include any `SKILL.md`
  - WHEN the verification scope is pure code (no `SKILL.md` touched)
  - THEN the new branch must not trigger at all — Step 4 behaves exactly as before for non-skill scopes
- Scenario: running the full eval harness is disproportionate for a one-line trim
  - WHEN the `SKILL.md` change in scope is a single trivial sentence
  - THEN `spdd-verify` must still surface the choice to the user in foreground rather than silently skipping, and accepting "lighter check" as the answer must be a legitimate, first-class outcome — not a fallback treated as non-compliant
- Scenario: `check-hook-sync.sh` runs before all three target files exist
  - WHEN one of the three `SKILL.md` files is missing or restructured such that Step 11/5/9 no longer exists at that number
  - THEN the script must fail with a clear, specific message (e.g. "block not found in <file>"), never a raw grep/diff error
- Scenario: the model-tier note is read as an instruction to change behavior
  - WHEN a future contributor reads the new `AGENTS.md`/`CLAUDE.md` note about this repo's reduced model tier
  - THEN the note must read as descriptive (this repo currently does X, for cost reasons), not as a mandate that the tiers must always stay this way — reviewed and confirmed by the ⚠️ Confirm below

**Production rollback:**
This is a documentation/instruction-only repo change (plus one new standalone shell script) with
no runtime/deployment surface — rollback is a normal `git revert` of the specific commit(s). No
data migration, no user-facing service impact.

---

## Confirmations (resolved 2026-08-31, foreground checkpoint)

- **Model-tier drift (finding 5):** bumped `implement: haiku` → `implement: sonnet` in
  `~/.config/spdd/config.json` (outside this repo, applied directly at this checkpoint — side-effect
  action, confirmed via `AskUserQuestion`). `AGENTS.md`/`CLAUDE.md` will still gain a short note
  explaining this repo runs a reduced tier on `canvas`/`design`/`verify` relative to `spdd-agent`'s
  documented defaults, with `implement` now at parity (`sonnet`) given the precision its own
  prose-editing work requires.
- **`spdd-verify`'s background-mode default for the new eval-harness branch:** confirmed as
  proposed — run the harness if the `SKILL.md` change in scope is non-trivial, otherwise leave a
  `⚠️ Confirm:` for the foreground checkpoint. `spdd-design`/`spdd-implement` should treat "trivial"
  as: a single-sentence or single-line prose edit with no new decision logic, branch, or exact
  string added/removed — anything else counts as non-trivial and runs the harness.
