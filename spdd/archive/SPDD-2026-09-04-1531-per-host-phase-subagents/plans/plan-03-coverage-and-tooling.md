# Plan: Coverage & tooling (eval cases + never-block drift check)

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-04
> Verified: 2026-09-04
**Depends on:** plan-01-wrapper-templates, plan-02-orchestrator-integration, plan-04-spdd-install-skill
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Eval | `spdd-agent/evals/evals.json` | New cases: dedicated used / fallback to ad-hoc / inline preserved / Claude Code model precedence / opencode divergence *detected and reported* / no-agent-files host unchanged |
| Eval | `spdd-install/evals/evals.json` | New cases: fresh install / resync updates existing files / divergence remediation offer / missing-config guard / permissions.deny merge without clobbering unrelated entries |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Eval coverage — orchestrator — `spdd-agent/evals/evals.json` (Existing, modified)
- `spdd-install` eval coverage — `spdd-install/evals/evals.json` (New — created and populated entirely by this plan, same as `spdd-agent/evals/evals.json`; plan-04 explicitly does not own it)
- Drift check — `scripts/check-agent-sync.sh` (New)

**Structure — files to create or modify:**

```
spdd-agent/evals/evals.json                  # new eval cases (detection/invocation only)
spdd-install/evals/evals.json                # new eval cases (install/resync/remediation/guard)
scripts/check-agent-sync.sh                  # never-block rule drift check (repo tooling only)
```

---

## Implementation notes

### New eval cases — `spdd-agent/evals/evals.json` (detection + invocation only)

Scope: everything `spdd-agent` Step 2/3 itself does — detecting, choosing a mode, invoking, and *reporting* a divergence. Nothing about installing or fixing files (that's `spdd-install`'s eval file, below).

- Dedicated agent used when present: complete route with all four dedicated agents on each host — every phase launches via its wrapper with the right model, reports flow back, and the Step 5/6/7/8 checkpoints stay intact.
- Fallback to ad-hoc when the dedicated file is absent — behavior byte-identical to today.
- Inline preserved on hosts with no subagent mechanism at all.
- Claude Code model precedence: per-invocation `model` from config.json overrides the agent file's frontmatter fallback.
- opencode divergence: comparing the `spdd-install:model-source` marker (not the translated `model:` field) against config.json's raw value — including the specific case of config.json holding a tier alias while the agent file's translated `model:` is a provider-qualified id, which must NOT be reported as a divergence; reported before launch via a transparency line, run proceeds with the agent file's model, `spdd-agent` does not rewrite anything and points at `/spdd-install` — never silent, never a rewrite from this skill.
- No-agent-files host: behavior unchanged.
- Malformed agent file → graceful fallback with a warning, never a hard failure.
- Auto-delegation guard already in place: with the wrappers and `permissions.deny` entries installed, a primary agent does not proactively pick `spdd-<phase>` for unrelated work (forbid-wording description on both hosts, opencode `hidden: true`, Claude Code `permissions.deny` entries in `~/.claude/settings.json`).
- Only-one-host-installed isolation: only Claude Code (or only opencode) wrappers exist — the other host falls back per the no-files case, no cross-host leakage.

### New eval cases — `spdd-install/evals/evals.json` (install, resync, remediation, guards)

- Fresh install on a machine with no `~/.claude/agents/spdd-*.md` / `~/.config/opencode/agents/spdd-*.md`: confirmation-gated, writes the 4+4 files, merges the 4 `permissions.deny` entries.
- Missing-config guard: config.json missing, malformed, or incomplete → `spdd-install` refuses to install and points at `spdd-agent`, without touching `spdd-agent/assets/model-bootstrap.md` or bootstrapping anything itself.
- Resync over already-installed files with no divergence: idempotent, no duplicate `permissions.deny` entries, no spurious rewrite prompts — including the tier-alias-vs-translated-id case (marker matches config.json's raw value even though `model:` is a different-looking translated id).
- Resync with an opencode model divergence: reports it, offers a confirmation-gated rewrite of both `model:` and the marker toward config.json's value, never silent, never automatic.
- Resync with a missing marker (pre-marker or hand-edited file): treated as a divergence needing remediation, not silently skipped.
- `permissions.deny` merge preserves unrelated pre-existing entries in `~/.claude/settings.json`.
- Declining the Claude Code confirmation still lets the opencode install proceed independently (and vice versa).

Both files follow the existing case shape (`id`, `prompt`, `expected_output`, `setup`, `assertions`) and existing language conventions. Eval ids for each skill live only in that skill's own `evals.json` (canvas Norm) — never restated in plans, other skills, or scripts.

### `scripts/check-agent-sync.sh`

- Mirrors `scripts/check-hook-sync.sh`'s role and style. Extracts the never-block rule text from each of the 8 wrapper templates and from `spdd-agent/SKILL.md` Step 3 (stripping only the `> ` blockquote marker from the SKILL.md copy), and fails with a clear message if any wrapper's copy is not byte-identical to the SKILL.md's.
- Repo tooling only — no `SKILL.md` may reference it at execution time (canvas Norm). Run manually or in CI.
- Not actually optional for this change: the canvas's Safeguards name drift detection as an edge case `spdd-verify` must be able to exercise, which presupposes the script exists — build it as a required part of this plan.

### Dependency note

Depends on all three prior plans: the `spdd-agent` eval cases exercise dedicated mode end-to-end (plan-01's wrappers + plan-02's orchestrator behavior), the `spdd-install` eval cases exercise plan-04's install/resync/guard flow, and the drift script diffs the final wrapper templates against the final `spdd-agent/SKILL.md` string.

---

## Out of scope for this plan

- The 8 wrapper template files (plan-01)
- `spdd-agent/SKILL.md` edits (plan-02)
- `spdd-install/SKILL.md` itself (plan-04) — this plan only populates its `evals/evals.json`
- Writing any user-level agent file, or touching `~/.config/spdd/config.json`
