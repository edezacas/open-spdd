# Rewrite the 7 SKILL.md instruction bodies in the swarm-forge style

## Context

Reviewed `swarm-forge`'s role prompts (`swarmforge/roles/*.prompt`,
`swarmforge/constitution/articles/*.prompt`) and want `open-spdd`'s own
skills — `spdd-canvas`, `spdd-design`, `spdd-implement`, `spdd-verify`,
`spdd-sync`, `spdd-migrate`, `spdd-agent` — rewritten to be "mucho más
livianas, directas y precisas" (much lighter, more direct, more precise),
using that style as the model.

Today's `## Instructions` bodies are narrated as `### Step N — Title` prose:
long compound sentences, nested if/else spelled out in running text, repeated
back-references ("per Step 2's decision"), and hedge phrases ("note that",
"either way"). swarm-forge's prompts instead use short `## Category` headers
(`Owns`, `Does Not Own`, `Handoff`) with one atomic imperative rule per
bullet — no narration, no restated rationale.

The goal is not to copy swarm-forge's category-header shape verbatim — SPDD
skills are sequential procedures a reader executes in order (unlike
swarm-forge's declarative role-ownership prompts), so the `### Step N` spine
stays. What changes is the prose *inside* each step: conditionals become
bullet lists, sentences get shorter and imperative, and restated context gets
cut wherever the step order already makes it obvious.

## House style rules (apply to every file)

1. Keep `### Step N — Title` structure and step order — do not switch to
   swarm-forge's flat category-header shape.
2. Any "if X then Y, if Z then W" branch written as prose becomes a bullet
   list: one bullet per condition, condition → action, no restated setup.
3. Cut narrator phrases that add no information: "note that", "either way",
   "it's worth noting", "this determines...". State the rule directly.
4. Drop back-references to steps that are just the immediately preceding
   step — the order already implies it. Keep back-references only when
   pointing at a non-adjacent step (e.g. "the status Step 3 checks for").
5. Shorten compound sentences; prefer leading with the imperative verb.
6. Never drop a distinct rule, guardrail, condition, or edge case — this is a
   prose-density pass, not a scope cut. If a sentence is doing real
   information work, it survives, just shorter.
7. Frontmatter (`description`, `compatibility`, `allowed-tools`, `metadata`)
   is untouched — those drive host routing/matching, not this pass. Bump
   `metadata.version`'s minor number by 1 in every file touched (matches the
   repo's existing per-file bump convention, e.g. `2.11` → `2.12`).
8. Three deliberately duplicated blocks stay duplicated on purpose (documented
   in `CLAUDE.md` — skills install independently via symlink, so nothing can
   reference a shared file at runtime):
   - The "Ensure the SPDD hook..." step in `spdd-canvas` (Step 9),
     `spdd-verify` (Step 9), `spdd-implement` (Step 5). Tighten the wording
     once, then apply the *identical* tightened text to all three copies —
     do not let them drift from each other.
   - The "Language note" boilerplate in `spdd-design`, `spdd-implement`,
     `spdd-sync`, `spdd-migrate`. Tighten each individually (they already
     differ slightly per skill), but keep the underlying instruction.
9. Out of scope for this pass: `assets/*.md` templates and the constitution-
   style asset files (`model-bootstrap.md`, `first-run.md`, `hook-setup.md`).
   Only the `## Instructions` body of each `SKILL.md` changes.

## Worked example — spdd-design (smallest, self-contained, no hook-setup step)

Current (56 lines) → tightened, same meaning, bulleted conditionals:

```markdown
### Step 1 — Locate the canvas

Use the given change folder or canvas path if provided. Otherwise list
`spdd/changes/SPDD-*`, sorted by name, most recent first.

- None found → stop, tell the user to run `spdd-canvas` first.
- Multiple found, no argument given → ask which one.

### Step 2 — Check for existing plans

If `plans/` already exists for this change:

- Every plan `Status: Draft` → ask whether to regenerate or leave as-is.
- Any plan `Confirmed`, `Implemented`, or `Verified` → warn explicitly that
  regenerating discards progress. Proceed only on explicit confirmation, and
  only overwrite the plans named — never a blanket overwrite.

### Step 3 — Read the canvas

Read `canvas.md` in full.

### Step 4 — Find partition boundaries

Cross-reference Entities, Structure, and Operations: which Operations touch
which Entities, which Structure paths belong to which module. A safe
partition has non-overlapping Structure paths per group, except explicitly
shared files.

### Step 5 — One plan or many

Default to one plan. Split only when groups are genuinely separable — not
intrinsically sequential, not funneled through one shared module — **and**
differ in Operation type or are meant for different agents/people.

Same Operation type applied homogeneously across files → one plan, one row
per file, even without Structure overlap.

### Step 6 — Read the base template

Read [template-plan.md](assets/template-plan.md).

### Step 7 — Generate the plan(s)

> Write all new plan content in English, regardless of conversation language.

For each group (or the single plan), fill the template and write to
`spdd/changes/SPDD-slug/plans/plan-NN-<name>.md`. Keep `../canvas.md` as-is.
Fill in:

- The Operations subset this plan owns.
- The Entities and Structure paths this plan owns.
- `Depends on:` and `Shared touchpoints:` per the template.

Do not duplicate Requirements, Norms, or Safeguards — they stay in
`canvas.md`; `spdd-implement` reads both.

### Step 8 — Report

Show the plan breakdown (or why it stayed one plan), the dependency graph,
and any `⚠️ Confirm:` lines — before implementation starts.
```

Nothing was cut: every condition, guardrail, and instruction from the
original survives. What changed: shorter sentences, bulleted branches,
dropped narration.

## Files to rewrite, in order (small → large, `spdd-agent` last)

1. `spdd-sync/SKILL.md` (41→~35 lines) — simplest, no hook-setup step.
2. `spdd-design/SKILL.md` (56 lines) — per the worked example above.
3. `spdd-implement/SKILL.md` (64 lines) — includes one hook-setup copy.
4. `spdd-canvas/SKILL.md` (79 lines) — includes one hook-setup copy; Step 5's
   freshness-check bash block and Step 9 stay functionally identical, just
   tightened prose around them.
5. `spdd-verify/SKILL.md` (95 lines) — includes one hook-setup copy; densest
   file (Step 7's 5-part diff-to-canvas check, foreground/background split in
   Step 4 and Step 7.5) — bullet those branches carefully, this is where
   losing a condition would hurt most.
6. `spdd-migrate/SKILL.md` (89 lines) — includes the Claude-Code-only hook
   *rewrite* step (Step 5), same tightening treatment; this step's wording is
   unique to migrate, not one of the three duplicated hook-setup copies.
7. `spdd-agent/SKILL.md` (157 lines, most complex — host detection, isolated/
   inline mode, opencode dedicated-agent check, checkpoint gates). Same
   principles, but every foreground/background and host-branch condition
   must survive as a bullet, not get compressed away. This one likely shrinks
   the least in line count even though it gets more scannable.

Each file: edit only the `## Instructions` body, bump `metadata.version`
(e.g. `2.11` → `2.12`), leave frontmatter otherwise untouched.

## Verification

- After each file: re-read it end to end and check every distinct rule from
  the original is still present somewhere (no silent scope cuts) — manual
  content diff, not a test suite (prompt wording isn't something to pin with
  automated tests, per this repo's own eval-harness conventions).
- After the 3 hook-setup copies (canvas/implement/verify) are all edited,
  diff them against each other to confirm the tightened wording is byte-
  identical across the three, same intent as `scripts/check-hook-sync.sh`
  (which only covers the `assets/hook-setup.md` files, not this point, so
  the check here is manual).
- Do not run the `evals/evals.json` suites for this pass — they test
  *behavior* (routing, guardrails, checkpoint gates), which is unchanged;
  this pass only changes prose density inside already-tested logic.
- Show a before/after for at least `spdd-agent` (the largest, riskiest file)
  before considering the pass done.

## Not doing in this pass

- Not touching `assets/*.md` (templates, `model-bootstrap.md`,
  `first-run.md`, `hook-setup.md`) — flagged as a possible follow-up, not
  requested yet.
- Not committing — commits only on explicit request, per standing practice.

## Status

**6 of 7 done.** `spdd-sync`, `spdd-design`, `spdd-implement`, `spdd-canvas`,
`spdd-verify`, `spdd-migrate` rewritten and version-bumped. Word-count
reduction in each file's `## Instructions` body, measured against `HEAD`:

| File | Before | After | Reduction |
|---|---|---|---|
| `spdd-sync` | 313 | 275 | -12% |
| `spdd-design` | 497 | 334 | -33% |
| `spdd-implement` | 513 | 413 | -19% |
| `spdd-canvas` | 762 | 633 | -17% |
| `spdd-verify` | 1145 | 910 | -21% |
| `spdd-migrate` | 811 | 711 | -12% |

The three duplicated hook-setup blocks (`spdd-canvas` Step 9, `spdd-implement`
Step 5, `spdd-verify` Step 9) were verified byte-identical after tightening.
Manual re-check confirmed no rule, guardrail, or condition was dropped from
any of the six files — only prose density changed.

`spdd-agent/SKILL.md` is **not yet done** — deliberately left for last per
the plan's risk ordering. Not committed yet either way.

**Eval validation: complete.** Full suite (all 60 evals across the 6 rewritten
skills, 214/214 assertions) run and passed — 0 regressions. Details in
`evals/workspace/iteration-3-skill-style-lightening/results.md`.
