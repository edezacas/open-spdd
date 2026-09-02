# Spec: spdd-migrate

> Living spec for the `spdd-migrate` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
As a team maintaining `open-spdd`, we want `spdd-migrate` to state each rule exactly once, so that
every agent run loads fewer tokens without changing any observable behavior.

**Scenario: single top-level language note (replaces the two per-step blockquotes)**
- WHEN `spdd-migrate/SKILL.md` instructs about output language
- THEN a single top-level language note (top of Instructions) covers both the `WHEN/THEN` reformatting prose (Step 2) and the newly authored spec prose (Step 3) — reformatting and spec-fold outputs remain English in all cases (v2.1 trim)

**Scenario: non-destructive default stated once**
- WHEN the migration flow runs
- THEN Step 4 keeps forbidding deletion of `docs/prompts/*.md` and `docs/features/*.md` outside the explicit Step 7 cleanup — the former Step 2 point 6 restatement is gone (v2.1 trim)

> Fold note (2026-09-01): the `spdd/specs/spdd-migrate.md` sync edit present in the same working tree was a user-accepted diff-scope discrepancy — `spdd-sync` ran before the v2.1 trim per the canvas freshness gate.

**Scenario: closed canvas routes to the archive as `Verified`** *(hand-authored 2026-09-02 from `spdd-migrate/SKILL.md` v2.1, Step 2 point 5 — audit-driven exception, not a fold-back)*
- WHEN a `docs/prompts/SPDD-*.md` canvas is closed (`Status: Implemented`, or a paired `docs/features/<slug>.md` exists)
- THEN it is written to `spdd/archive/SPDD-<same-date-slug>/canvas.md` with `Status: Verified`, preserving an existing `> Implemented: YYYY-MM-DD` line — mirroring `spdd-verify`'s invariant that only `Verified` material lives in `spdd/archive/`

**Scenario: active canvas routes to `spdd/changes/` with its status preserved** *(hand-authored 2026-09-02 from `spdd-migrate/SKILL.md` v2.1, Step 2 point 5 — audit-driven exception, not a fold-back)*
- WHEN a `docs/prompts/SPDD-*.md` canvas is still active (`Draft` or `Confirmed`) with no paired feature doc
- THEN it is written to `spdd/changes/SPDD-<same-date-slug>/canvas.md` keeping its original `Status` exactly as it was, and is never folded into `spdd/specs/` at migrate time — folding happens later via `spdd-verify`

**Scenario: closed feature docs fold into the living spec with a source marker** *(hand-authored 2026-09-02 from `spdd-migrate/SKILL.md` v2.1, Step 3 — audit-driven exception, not a fold-back)*
- WHEN a `docs/features/<slug>.md` is paired with a canvas archived in Step 2, or orphaned (no matching old canvas at all)
- THEN its prose is converted into Requirements/Entities/Operations/Norms of `spdd/specs/<domain>.md` — domain inferred from the paired canvas's Structure, else the doc's "Technical notes" paths, else `spdd/specs/general.md` — synthesized only from the doc's own prose with name/identifier dedupe before appending, and the `<!-- spdd-migrate source: docs/features/<slug>.md -->` marker is added next to what was folded in; a paired doc whose canvas stayed in `spdd/changes/` is skipped (unfinished work has nothing to fold yet)

**Scenario: migration is idempotent** *(hand-authored 2026-09-02 from `spdd-migrate/SKILL.md` v2.1, Step 2 point 3 and Step 3 point 1 — audit-driven exception, not a fold-back)*
- WHEN a canvas whose `spdd/changes|archive/SPDD-<same-slug>/canvas.md` target already exists, or a feature doc whose source marker already appears in the target spec, is encountered again
- THEN that file is skipped and noted as already migrated — the explicit HTML-comment marker exists because folded content isn't byte-for-byte deterministic across runs, so name/identifier dedupe alone isn't enough

**Scenario: the guard hook is rewritten to the current pattern** *(hand-authored 2026-09-02 from `spdd-migrate/SKILL.md` v2.1, Step 5 — audit-driven exception, not a fold-back)*
- WHEN the migration runs as Claude Code and `.claude/settings.local.json` still points the SPDD guard hook at `docs/prompts/SPDD-*.md`
- THEN the hook's `command` is rewritten to scan `spdd/changes/*/canvas.md` and `spdd/changes/*/plans/*.md` for unresolved `⚠️ Confirm:` lines; a missing hook is left uninstalled (the other SPDD skills offer to install it on first use), and the whole step is skipped on non-Claude-Code hosts

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| Language note (×1) | `spdd-migrate/SKILL.md` (top of Instructions) | Single note covering reformat and spec-fold prose; replaced the two per-step blockquotes (v2.1 trim) |
| Route decision (closed vs. active) | `spdd-migrate/SKILL.md` (Step 2, point 5) | Closed (`Status: Implemented` or paired `docs/features/<slug>.md`) → `spdd/archive/` as `Status: Verified`; active (`Draft`/`Confirmed`) → `spdd/changes/` with the original status preserved |
| Idempotency markers | `spdd-migrate/SKILL.md` (Step 2, point 3; Step 3, point 1) | Existence check of `spdd/changes\|archive/SPDD-<same-slug>/canvas.md` for canvases; `<!-- spdd-migrate source: docs/features/<slug>.md -->` HTML comment for folded feature docs |
| Domain inference | `spdd-migrate/SKILL.md` (Step 3, point 2) | Same folder-convention heuristic as `spdd-canvas`; prefers the paired canvas's Structure, then the doc's "Technical notes" paths, else falls back to `spdd/specs/general.md` |
| Hook rewrite | `spdd-migrate/SKILL.md` (Step 5, Claude Code only) | Rewrites the guard hook's `command` from the old `docs/prompts/SPDD-*.md` pattern to the current `spdd/changes/` pattern; a missing hook is left uninstalled |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Note | Language note at the top of Instructions | All newly authored content (reformatted Acceptance Criteria/Safeguards, spec sections, `⚠️ Confirm:` lines) is written in English, regardless of the conversation's language |
| Route | Closed canvas → `spdd/archive/SPDD-<same-date-slug>/canvas.md` with `Status: Verified` | Preserves an existing `> Implemented:` line; mirrors `spdd-verify`'s invariant that only `Verified` material lives in `spdd/archive/` |
| Route | Active canvas → `spdd/changes/SPDD-<same-date-slug>/canvas.md` with the original `Status` unchanged | Never folded into `spdd/specs/` at migrate time — folding happens later via `spdd-verify` |
| Check | Idempotency (canvases and feature docs) | Skips any file whose target already exists or whose source marker is already present, noting it as already migrated |
| Fold | `docs/features/<slug>.md` → `spdd/specs/<domain>.md` (Requirements, Entities, Operations, Norms) | Synthesizes only from the doc's own prose; name/identifier dedupe before appending; source marker added next to folded content |
| Guard | Non-destructive default (Step 4) | Originals are never deleted during migration; unmatched leftovers are listed in the report; deletion only via Step 7 with explicit confirmation |

---

## Norms

- Simplicity First: the language rule is a fixed, unconditional instruction — no conditional logic or per-project configuration.
- The authoritative version of a skill is the `metadata.version` in its own `SKILL.md` frontmatter — spec Norms never restate a version counter (removed 2026-09-02 after the counter drifted: spdd-agent said 1.13, skill was 1.14).
- Content copied verbatim from the source file (not reformatted) is not translated as a side effect — the rule applies only to newly authored prose.
- Migration is non-destructive by default — originals are never deleted during Steps 2–4; deletion happens only in Step 7 after explicit confirmation.
- Never invent detail the source prose doesn't support — ambiguous rewrites and lossy mappings become `⚠️ Confirm:` lines instead of guesses.
