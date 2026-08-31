# Plan: Trim spdd-design/SKILL.md language note and Step 1 lookup prose

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
**Depends on:** none
**Shared touchpoints:** none — the language-note row below also appears in `plan-04-spdd-implement.md`, `plan-05-spdd-verify.md`, and `plan-06-spdd-sync.md`; each plan applies it only to its own file, no cross-file read/write.

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Trim | Language-note paragraphs (`spdd-design` Step 7, `spdd-implement` Step 0, `spdd-verify` Step 7, `spdd-sync` Step 5) | Each restates "write new content in English" with a different rationale clause. The one-line operative instruction ("write all new content in English") must stay in each — a background subagent's prompt (per `spdd-agent` Step 3) carries only the skill call + never-block rule, not the full project `CLAUDE.md`, so the rule can't be assumed inherited. **Confirmed:** drop the varying rationale clause everywhere, keep one uniform short instruction line per file |
| Trim | `spdd-verify` Step 1 already cross-references "same lookup pattern as `spdd-implement` Step 1" in prose (not a file read); `spdd-design` Step 1 spells the same change-listing lookup out in full | **Confirmed:** apply the same short textual cross-reference style to `spdd-design` Step 1, for consistency with the precedent already used in `spdd-verify` |

## Implementation notes

### Language note (this file's occurrence)

Current text (blockquote near the top of Step 7, verbatim):
> **Language note:** The plan content you generate (plan names, section headings, all prose in Operations/Entities/Structure descriptions, and any notes you add) must be in English, regardless of the language of the canvas you read or the user's conversation language. The canvas is already in English as of this version; maintain that English-only rule in any new content you write.

**Confirmed** (foreground checkpoint, 2026-08-31): wording approved as-is.

> **Language note:** Write all new plan content (names, headings, prose) in English, regardless of the conversation's language.

Drop the "The canvas is already in English... maintain that rule" sentence — it's rationale, not instruction.

### Step 1 lookup cross-reference

Current text (verbatim):
> If a change folder or canvas path was provided, use that. Otherwise, list recent changes:
>
> List the directories in `spdd/changes/` matching `SPDD-*`, sorted by name (most recent first).
>
> If empty, stop and tell the user to run `spdd-canvas` first. If multiple exist and no argument was given, ask which one to use.

`spdd-verify` Step 1's precedent (verbatim, current file, for reference — do not copy into `spdd-design`, just match its *style*):
> If a change folder or plan path was provided, use that. Otherwise, list recent changes in `spdd/changes/` matching `SPDD-*`, sorted by name (most recent first), same lookup pattern as `spdd-implement` Step 1.

Apply the same fold-in style to `spdd-design` Step 1. Suggested replacement:
> If a change folder or canvas path was provided, use that. Otherwise, list recent changes in `spdd/changes/` matching `SPDD-*`, sorted by name (most recent first), same lookup pattern as `spdd-implement` Step 1.
>
> If empty, stop and tell the user to run `spdd-canvas` first. If multiple exist and no argument was given, ask which one to use.

This removes the separate "List the directories..." sentence by folding it into the first line, matching `spdd-verify`'s existing precedent. The empty/multiple-matches branching logic (second paragraph) is operative and must stay unchanged.

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-design SKILL.md` — 59 lines, leanest file, already cross-references `spdd-canvas`'s hook offer in prose (no file read) instead of restating it

**Structure — files to create or modify:**

```
spdd-design/SKILL.md
```

## Norm compliance for this plan

- Bump `metadata.version` in `spdd-design/SKILL.md` frontmatter (currently `"1.1"`) once the trim is applied — instructions changed.
- Re-run `spdd-design/evals/evals.json` after the edit (evals 11–14, 29); no assertion is expected to reference the removed rationale wording or the exact old Step 1 phrasing, but verify — eval 29 in particular covers the existing-plan guard near Step 1/2.
- Verify `allowed-tools:` frontmatter still matches actual tool usage after the edit (expected: no change needed).
