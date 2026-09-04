# Plan: Orchestrator integration (Step 2 detection, Step 3 contract)

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-04
> Verified: 2026-09-04
**Depends on:** plan-01-wrapper-templates
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Detect subagent support" (Step 2, modified) | Level 0: dedicated `spdd-<phase>` agent file exists in the host's agent dir → Dedicated mode. Levels 1–2: ad-hoc isolated with / without model override (today's behavior). Level 3: inline. Each announced with its own `[automatic decision]` transparency line. On opencode, also detects and reports (never rewrites) a model divergence between the agent file's `spdd-install:model-source` marker and config.json's current raw value — a plain string comparison, no alias→ID translation performed here |
| Contract | Dedicated invocation — Claude Code | `Agent` call with `subagent_type: "spdd-<phase>"` and `model:` from config.json; the per-invocation `model` overrides the frontmatter fallback; the wrapper's `skills:` field preloads the phase SKILL.md |
| Contract | Dedicated invocation — opencode | Task tool with `subagent_type: "spdd-<phase>"`; no model field exists — the phase model is applied via the agent file's frontmatter |
| Prompt | Dedicated-mode subagent prompt | Phase context only (the exact context listed for the phase in `spdd-agent` Steps 4–8, plus the routing-already-decided note for canvas); never-block rule and report contract carried by the wrapper body, not repeated per call |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- "Detect subagent support" (Step 2) — `spdd-agent/SKILL.md` (Existing, modified)
- "Phase invocation contract" (Step 3) — `spdd-agent/SKILL.md` (Existing, modified)
- Model config `~/.config/spdd/config.json` — referenced only; schema and role unchanged, no write path added for it (canvas Out of scope)

**Structure — files to create or modify:**

```
spdd-agent/SKILL.md                          # Step 2: dedicated-agent detection level + transparency line + read-only divergence report; Step 3: dedicated branch of the invocation contract
```

---

## Implementation notes

### Step 2 — four-level detection (`spdd-agent/SKILL.md`)

- Level 0 (new): for the current phase, check the host's agent directory for a dedicated definition — Claude Code: `~/.claude/agents/spdd-<phase>.md`; opencode: `~/.config/opencode/agents/spdd-<phase>.md`. Presence → Dedicated mode.
- Levels 1–3 keep today's contract unchanged (ad-hoc isolated with model override / ad-hoc isolated without override / inline).
- A dedicated file that exists but is malformed (unparseable frontmatter, missing required fields, empty body) is treated as absent: warn, skip Dedicated mode, fall back to the ad-hoc contract — the flow never blocks or crashes (canvas Safeguard).
- On opencode, when Dedicated mode is selected: read the `<!-- spdd-install:model-source=<value> -->` marker from the agent file's body (written by `spdd-install`, plan-04) and compare it — as a plain string — against config.json's current raw value for that phase. **Never** compare config.json's raw value against the frontmatter `model:` field directly — `model:` always holds the already-translated provider-qualified id, while config.json commonly holds a tier alias (`sonnet`, the bootstrap default), so that comparison would report a false divergence on every single run on any machine using tier-style values (canvas Acceptance criteria: "divergence comparison never needs the alias→ID mapping table outside `spdd-install`"). If the marker is missing entirely (an agent file installed before this marker existed, or written by hand): treat as unknown/skip the check rather than guessing — do not compare against `model:`. If the marker and config.json's raw value differ, show a transparency line reporting the divergence and continue — never rewrite the file, never block. Point the reported line at `/spdd-install` as the way to resync (canvas Acceptance criteria: "opencode divergence warning, detection vs. remediation split").
- Each level gets its own `[automatic decision]` transparency line, including the new Dedicated case.
- Detection is strictly per-host — no cross-host leakage when only one host's wrappers are installed (canvas Safeguard).

### Step 3 — dedicated invocation branch (`spdd-agent/SKILL.md`)

- Claude Code: `Agent` call with `subagent_type: "spdd-<phase>"` and `model:` taken from config.json — the per-invocation param overrides the agent file's frontmatter fallback, keeping config.json the single source of truth for per-phase models.
- opencode: Task call with `subagent_type: "spdd-<phase>"`; no model field exists — the model comes from the agent file's frontmatter (already reported on above if it diverged).
- Dedicated-mode prompt carries phase context only (the exact context listed for the phase in Steps 4–8, plus the routing-already-decided note for canvas). The never-block rule and the report contract are NOT repeated per call — the wrapper body carries them.
- Constraint: the never-block rule string quoted in Step 3 stays **byte-identical** — plan-01's wrapper bodies copy it from here and plan-03's `scripts/check-agent-sync.sh` diffs against it. The Levels 1–3 fallback path must remain byte-identical in behavior (strictly additive change, canvas Norm).

### Dependency note

Depends on plan-01: the dedicated-mode prompt contract assumes the wrapper bodies (installed at runtime by the separate `spdd-install` skill, plan-04) carry the never-block rule and report contract. This plan does not install anything itself — it only detects and invokes.

---

## Out of scope for this plan

- The 8 wrapper template files (plan-01)
- Installing/resyncing the 8 agent files, writing `~/.claude/settings.json` `permissions.deny` entries, writing the opencode agent-file model, or offering the divergence rewrite — all of that is `spdd-install`'s job (plan-04), a separate skill, never folded into `spdd-agent`
- `spdd-agent/evals/evals.json` and `scripts/check-agent-sync.sh` (plan-03)
- `spdd-agent/assets/model-bootstrap.md` — untouched by this feature (canvas Out of scope, canvas Pending confirmation #5)
