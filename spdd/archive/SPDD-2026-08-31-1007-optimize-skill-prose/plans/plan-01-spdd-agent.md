# Plan: Trim spdd-agent/SKILL.md rationale prose

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-08-31
> Verified: 2026-08-31
**Depends on:** none
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Trim | `spdd-agent` Step 1, model-tier table "Why" column (lines ~100–105) | Justifies each suggested model tier to a human; the AI only reads the "Suggested tier" column to act. **Confirmed:** delete the column, keep its content as a one-line footnote below the table, since it's not consulted per-invocation |
| Trim | `spdd-agent` Step 1, line ~91 ("Their entries exist in the same file only so the config surface... is uniform across all six phases") | Explains a design choice; doesn't change Step 1's behavior. Default: delete |
| Trim | `spdd-agent` Step 1, line ~107 ("The last column is one worked example, not the framework's default...") | Borderline: could be read as an operative caveat against hardcoding Claude Code aliases when extending to a new host, or as a human-only aside. **Confirmed:** keep — treated as an operative caveat |

## Implementation notes

- The third row above is **reviewed, no edit** — do not remove or shorten that line. It is listed here only so the diff-review Safeguard ("confirm every removed line matches the human-facing classification") has the full picture of what was considered for this file.
- For the "Why" column removal: the table currently reads (verbatim, current file):
  ```
  | Phase | Suggested tier | Fixed-alias example (Claude Code) | Why |
  |---|---|---|---|
  | `canvas` | high-reasoning | `opus` | Ambiguity/risk detection and REASONS drafting is the highest reasoning-density phase. |
  | `design` | high-reasoning | `opus` | Deciding one plan vs. several and mapping dependencies is an architectural call. |
  | `implement` | fast/cheap | `sonnet` | Executes a plan already validated by a human; favors speed/cost. |
  | `verify` | high-reasoning | `opus` | Finding edge cases and checking against Norms/Safeguards benefits from strong reasoning. |
  | `sync` | fast/cheap | `sonnet` | Mechanical spec↔code sync after a refactor. |
  | `migrate` | fast/cheap | `sonnet` | Mostly mechanical layout migration. |
  ```
  Drop the `Why` column (and its cell values) from the table, then add one footnote line directly below the table folding the six "Why" sentences into a compact form, e.g.: `Tier rationale: canvas/design/verify favor high-reasoning (ambiguity detection, architectural calls, edge-case/Norms checking); implement/sync/migrate favor fast/cheap (executing an already-validated plan, mechanical spec sync, mechanical layout migration).` Adjust wording for concision as needed — the goal is one footnote line, not a restatement of all six sentences.
- For the line-~91 removal: delete the sentence starting "Their entries exist in the same file only so the config surface (Step 2) is uniform across all six phases." Keep the rest of that paragraph intact (the preceding sentence about which phases are actually used by the flow is operative and must stay).
- Do not touch anything outside Step 1's model-tier block — the rest of `spdd-agent/SKILL.md` (Steps 2–8, Decision transparency section) is out of scope for this plan.

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-agent SKILL.md` — 160 lines, orchestrator, richest in rationale prose (model-tier "Why" column, config-surface justification)

**Structure — files to create or modify:**

```
spdd-agent/SKILL.md
```

## Norm compliance for this plan

- Bump `metadata.version` in `spdd-agent/SKILL.md` frontmatter (currently `"1.7"`) once the trim is applied — instructions changed.
- Re-run `spdd-agent/evals/evals.json` after the edit; no assertion is expected to reference the removed "Why" column text or the line-91 sentence, but verify.
- Verify `allowed-tools:` frontmatter still matches actual tool usage after the edit (expected: no change needed, this is a text-only trim).
