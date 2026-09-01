# Plan: Skill-flow coherence fixes and context trim

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.
**Status:** Verified
> Implemented: 2026-09-01
> Verified: 2026-09-01

**Depends on:** none
**Shared touchpoints:** none

---

## Operations

Full Operations subset from the canvas (single-plan change — nothing left out; copied verbatim from `canvas.md`):

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

**Execution order** (from the canvas's Approach priority section):

1. F1, F2 — the two blocking-level fixes.
2. F3, F4, F5, F6 — remaining coherence fixes.
3. T6 — highest trim priority; then T1, T2, T3, T4, T5, T7, T8.
4. Version bumps accompany each file's edit; eval re-runs and assertion reconciliation happen at the end, across all edited skills.

**Resolved canvas Confirms honored by this plan** (2026-09-01, foreground checkpoint):

- F1: minimal fix (gate aligned to `Status: Implemented`) — not the interleaved loop.
- T5: the repo-dogfooding pointer moves to `CLAUDE.md`/`AGENTS.md`; `spdd-verify` keeps only the generic one-liner.
- T6: scope is the 5 phase skills; `spdd-migrate`'s description stays untouched.

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):

- `spdd-agent SKILL.md` — fixes F1, F3, F5, F6 + trims T1, T7, T8
- `spdd-canvas SKILL.md` — fix F4 + trims T2, T3, T6
- `spdd-verify SKILL.md` — fix F2 + trims T4, T5, T6
- `spdd-sync SKILL.md` — trim T6
- `spdd-design SKILL.md` — trim T6
- `spdd-implement SKILL.md` — trim T6
- Repo `CLAUDE.md` / `AGENTS.md` — T5 relocation (confirmed)
- `evals/evals.json` of edited skills — only if an assertion literally quotes trimmed wording (reconciliation)

Explicitly **not** owned by this plan (per canvas): `spdd-migrate/SKILL.md`, `spdd-agent/assets/model-bootstrap.md`, the triplicated `hook-setup.md` assets, `spdd-canvas/assets/template-reasons.md` (F7 deferred).

**Structure — files to create or modify:**

```
spdd-agent/SKILL.md
spdd-canvas/SKILL.md
spdd-verify/SKILL.md
spdd-sync/SKILL.md
spdd-design/SKILL.md
spdd-implement/SKILL.md
CLAUDE.md
AGENTS.md
spdd-agent/evals/evals.json         (conditional — reconciliation only)
spdd-canvas/evals/evals.json        (conditional — reconciliation only)
spdd-design/evals/evals.json        (conditional — reconciliation only)
spdd-implement/evals/evals.json     (conditional — reconciliation only)
spdd-verify/evals/evals.json        (conditional — reconciliation only)
spdd-sync/evals/evals.json          (conditional — reconciliation only)
```
