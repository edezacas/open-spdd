# Plan: Claude Code model config namespace

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-08-31
> Verified: 2026-08-31
**Depends on:** none
**Shared touchpoints:** none — this is a single-plan change; `spdd-agent/SKILL.md`, `spdd-agent/evals/evals.json`, `CLAUDE.md`, and `AGENTS.md` are all fully owned by this one plan.

**Note on scope:** all four Structure files below belong to one skill (`spdd-agent`) and one cohesive behavior change (host detection → namespace choice → config read/write). `spdd-design` follows the "do not force a split" rule: the eval cases in `evals.json` directly test the exact wording landing in `SKILL.md`'s Step 1, and the `CLAUDE.md`/`AGENTS.md` Gotchas note is a one-line mirror describing the same confirmed schema — none of these are separable into independently implementable or independently reviewable units, so they stay one plan (consistent with this repo's own precedent in `spdd/archive/SPDD-2026-08-30-1220-documentos-en-ingles/plans/plan-01-spdd-canvas.md`, which likewise kept a single skill's `SKILL.md` + `evals.json` + `CLAUDE.md` + `AGENTS.md` edits together in one plan, splitting only across *different* skill directories).

---

## Operations

Subset of the canvas's Operations that belong to this plan (copied verbatim from `canvas.md`'s Operations table — this plan covers all of them):

| Type | Identifier | Description |
|------|-----------|-------------|
| Step (new) | "Detect Claude Code host" | New sub-step inserted at the start of Step 1, before the existing file-exists check — determines Claude-Code vs. other, per ⚠️ Confirm (1) |
| Step (modified) | "Load or bootstrap the model configuration" (Step 1.1, bootstrap) | Writes to `claude` namespace when detected, flat top-level `models` otherwise |
| Step (modified) | "Load or bootstrap the model configuration" (Step 1.2, existing file) | Reads from `claude` namespace when detected and present; triggers migration path when detected but only flat is present, per ⚠️ Confirm (3) |
| Step (modified) | "Explicit config request" | Same namespace branch as bootstrap/read, so view/change requests resolve consistently |
| Config write | `claude` namespace bootstrap | `{"claude": {"models": {"canvas": ..., ...}}}` (exact shape per ⚠️ Confirm (2)) |
| Config write | Legacy flat fallback | `{"models": {"canvas": ..., ...}}` — unchanged, used whenever Claude Code is not detected |
| Eval case (new/modified) | evals 31–38 | Extend to cover: bootstrap under detected Claude Code, bootstrap under non-Claude-Code host, read of existing nested config, read/migration of existing flat config while Claude Code is detected, explicit view/change request against each namespace |

All ⚠️ Confirm (N) references above point to the "Confirmed decisions" section of `../canvas.md` — every one of them is already resolved there (detection signal, nested schema shape, migration path). None are open for this plan.

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Model config file — `~/.config/spdd/config.json` (Existing, schema change — gains an optional `claude` namespace; this plan does not perform a live write against the real file, only changes the instructions that would produce one at runtime)
- "Load or bootstrap the model configuration" (Step 1) — `spdd-agent/SKILL.md` (Existing, modified — gains the host-detection sub-step)
- "Detect subagent support" (Step 2) — `spdd-agent/SKILL.md` (Existing, reference only — not modified by this plan; cited in `SKILL.md` only as the precedent this feature deliberately diverges from, per ⚠️ Confirm (1) in the canvas)
- Config bootstrap/repair evals — `spdd-agent/evals/evals.json` (evals 31–38) (Existing, modified)

Not owned by this plan: "Living spec" (`spdd/specs/spdd-agent.md`) — per the canvas, that file is updated later by `spdd-verify` once this change is implemented and verified, not created or edited here.

**Structure — files to create or modify:**

```
spdd-agent/SKILL.md                    # Step 1: add "Detect Claude Code host" sub-step (Bash check of CLAUDECODE env var, per canvas ⚠️ Confirm 1); branch bootstrap/read/explicit-config-request on claude vs. flat namespace per ⚠️ Confirm 2/3; keep the actual config-file write gated behind a real foreground AskUserQuestion, same as Step 1's existing side-effect pattern; increment metadata.version
spdd-agent/evals/evals.json            # evals 31-38: update fixtures/assertions for the new namespace; add cases for detection (Claude Code / non-Claude-Code / inconclusive), nested-present read, flat-only migration path, and explicit config view/change request against each namespace
CLAUDE.md                              # Gotchas: update the "this repo's own ~/.config/spdd/config.json is flat" note to reflect the new claude-namespaced schema, per the "AGENTS.md mirrors CLAUDE.md" convention — documentation text only, no live config file write
AGENTS.md                              # Mirror the same Gotchas edit verbatim, per the "AGENTS.md mirrors CLAUDE.md" convention (user memory: feedback_agents-md-mirrors-claude-md.md)
```

**Open items:** none pending for this plan — the canvas this plan is derived from is fully `Confirmed` with zero unresolved items. The only remaining gate is procedural, not a content decision: per the canvas's own Safeguards ("Production rollback"), the actual filesystem edits to the four files above, and any real write/migration of a live `~/.config/spdd/config.json`, must still go through `spdd-implement`'s normal foreground side-effect confirmation when it runs on a real machine — this plan does not perform any of those writes itself.
