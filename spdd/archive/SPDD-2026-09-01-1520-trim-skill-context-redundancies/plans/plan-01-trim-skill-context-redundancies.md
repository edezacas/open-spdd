# Plan: Trim skill context redundancies

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-01
**Depends on:** none
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Edit | `spdd-migrate/SKILL.md` | Consolidate the two Language notes into one top-level note; delete Step 2 point 6; bump version to 2.1 |
| Edit | `spdd-design/SKILL.md` | Replace Step 7's `Depends on:`/`Shared touchpoints:` bullets with a pointer to the template's guidance; inline the change-lookup sentence in Step 1 (drop the `spdd-implement` cross-reference); bump version to 1.5 |
| Edit | `spdd-agent/assets/model-bootstrap.md` | Compress lines 3–8 to a ≤2-sentence scope note; remove the line-36 flat-key sentence (keep line 75's); remove the line-22 parenthetical |
| Edit | `spdd-canvas/SKILL.md` | Replace Step 9's bash block with a one-sentence check (same grep targets); trim Step 10's trailing rationale sentence; bump version to 2.10 |
| Edit | `spdd-implement/SKILL.md` | Replace Step 5's bash block with a one-sentence check; bump version to 2.6 |
| Edit | `spdd-verify/SKILL.md` | Inline the change-lookup sentence in Step 1 (drop the cross-reference); replace Step 9's bash block with a one-sentence check; bump version to 2.0 |
| Edit | `spdd-canvas/assets/hook-setup.md` | Align line 17 with the per-copy phrasing decided at the checkpoint |
| Edit | `AGENTS.md` + `CLAUDE.md` | Update the "inlines the grep check" gotcha sentence to match the new one-sentence check, mirrored in both files |
| Version bumps | all edited `SKILL.md` files | `metadata.version` increments per each domain spec's Norm (agent bumps for the asset edit: 1.12 → 1.13) |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- `spdd-migrate/SKILL.md` (v2.0 → 2.1)
- `spdd-design/SKILL.md` (v1.4 → 1.5)
- `spdd-agent/assets/model-bootstrap.md`
- `spdd-canvas/SKILL.md` (v2.9 → 2.10)
- `spdd-implement/SKILL.md` (v2.5 → 2.6)
- `spdd-verify/SKILL.md` (v1.9 → 2.0)
- `spdd-canvas/assets/hook-setup.md`
- `AGENTS.md` / `CLAUDE.md` gotcha sentence (mirrored pair)

**Structure — files to create or modify:**

```
spdd-migrate/SKILL.md
spdd-design/SKILL.md
spdd-agent/assets/model-bootstrap.md
spdd-canvas/SKILL.md
spdd-implement/SKILL.md
spdd-verify/SKILL.md
spdd-canvas/assets/hook-setup.md
AGENTS.md
CLAUDE.md
```

Confirmed checkpoint decisions that scope the edits (from the canvas's "Confirmed at checkpoint"):
1. The one-sentence hook check names both targets verbatim (`SPDD`, `"subagentPromptCacheTtl"`) and the file `.claude/settings.local.json`.
2. All three `hook-setup.md` copies use the per-copy phrasing ("This phase can run several turns inside one subagent call…").

> Plan correction (implement time, user-confirmed): the line-17 edit targets `spdd-canvas/assets/hook-setup.md` — the only copy still carrying the shared phrasing; the `spdd-implement` and `spdd-verify` copies already use the per-copy phrasing and stay untouched.
