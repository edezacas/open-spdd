# Plan: First-run onboarding flow (guide + model bootstrap + dedicated-layer offer)

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: all section headings, labels, and body content are in English.

**Status:** Verified
> Implemented: 2026-09-07 · Verified: 2026-09-07 (spdd-verify; targeted evals 97–100 added for the uncovered Safeguards edge cases)
**Depends on:** none
**Shared touchpoints:** none — this plan is the only one for this change; all files below belong to it exclusively.

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — all of them, this is a single-plan change):

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | First-run detection (Step 1, existing) | The existing completeness check's "file doesn't exist" classification now also routes to the onboarding flow |
| Step | First-run guide (new) | Brief flow explanation in the conversation's language, shown before the model-choice questions |
| Step | Model bootstrap (existing, unchanged) | `spdd-agent/assets/model-bootstrap.md`'s first-run section runs exactly as today, inside the onboarding |
| Question | Dedicated-layer offer (new) | One `AskUserQuestion`: run `spdd-install` now? (recommended: yes) — fired only when the host has a subagent mechanism and the dedicated files for the current host aren't all well-formed |
| Invocation | `spdd-install`, foreground inline (new) | On accept: load the `spdd-install` skill via the host's skill mechanism, or read its installed `SKILL.md` and execute inline; on completion continue to Step 2; if unreachable, report and continue without |
| Transparency | Per-phase one-liners (new, first run only) | One short line per phase launch (Steps 4, 6, 7, 8) explaining the phase, in the conversation's language |
| Fallback | Per-phase detection (existing, unchanged) | Non-first runs: Dedicated/Isolated/Inline detection with silent fallback, byte-identical to today |
| Eval | New `spdd-agent` eval cases | Onboarding accept / decline / no-mechanism-skip / already-present-skip / non-first-run-silent / direct-route-lean / config-request-stop |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- First-run detection — `spdd-agent/SKILL.md` Step 1's completeness check (Existing): the "file doesn't exist" classification becomes the onboarding trigger; no new signal is invented
- First-run onboarding flow — `spdd-agent/SKILL.md`, routed from Step 1's first-run case (New)
- First-run asset — `spdd-agent/assets/first-run.md` (New): guide text, offer mechanics, `spdd-install` invocation + unavailability fallbacks, and the per-phase one-liner templates — lazy-loaded only on the first-run case
- `spdd-install` skill — `spdd-install/SKILL.md` (Existing): description + intro wording only; Steps 1–6 untouched
- Model-bootstrap asset — `spdd-agent/assets/model-bootstrap.md` (Existing, unchanged): the onboarding wraps its first-run section, never duplicates it
- Dedicated agent files — `~/.claude/agents/spdd-<phase>.md` · `~/.config/opencode/agents/spdd-<phase>.md` (Existing, runtime): detection targets for the offer condition only; written only by `spdd-install`, never by `spdd-agent`
- Mirror docs — `CLAUDE.md` · `AGENTS.md` (Existing)
- README — `README.md` (Existing)
- `spdd-agent` evals — `spdd-agent/evals/evals.json` (Existing): new cases 90–96
- Living specs — `spdd/specs/spdd-agent.md` · `spdd/specs/spdd-install.md` (Existing, read-only for this plan — `spdd-verify` folds into them later, not touched here)

**Structure — files to create or modify:**

```
spdd-agent/SKILL.md                    # Step 1 "Everything else": first-run case routed to assets/first-run.md (all other not-complete classifications unchanged); one conditional first-run one-liner instruction; frontmatter description + metadata.version 1.15 → 1.16
spdd-agent/assets/first-run.md         # NEW — guide text, offer mechanics, spdd-install invocation + fallbacks, per-phase one-liner templates
spdd-agent/evals/evals.json            # new cases 90–96; expected_output prose of 32 and 46 extended (confirmed 2026-09-07 — see Implementation notes); their assertions untouched
spdd-install/SKILL.md                  # frontmatter description + intro sentence reworded to admit the first-run entry point; Steps 1–6 untouched; metadata.version 1.1 → 1.2
CLAUDE.md                              # Overview stale sentence fixed; spdd-agent + spdd-install auto-trigger rows updated; Structure section: first-run.md line + evals coverage comment (shared section — byte-identical with AGENTS.md, same pass)
AGENTS.md                              # same updates; shared sections byte-identical with CLAUDE.md's
README.md                              # opt-in fast-path bullet + "Optional dedicated subagents" callout reworded; first-run onboarding sentence added to the spdd-agent description
```

---

## Implementation notes

### Where the onboarding hooks in (`spdd-agent/SKILL.md`) — no new step

The canvas delegates exact step numbering to this phase. Decision: keep Steps 0–9 intact — inserting a step would renumber Steps 2–9 and invalidate the step cross-references living in the wrapper templates, the specs, and both mirror docs. Three changes to the file, the first two in the Instructions body:

1. **Step 1, "Everything else" paragraph — first-run carve-out.** Only the file-doesn't-exist classification (the resolved confirmation: first run = config-absent case) routes to `assets/first-run.md`; repair, migration, malformed/unparseable, and explicit-change keep today's direct routing to `model-bootstrap.md`, byte-identical — no guide, no offer, no one-liners on any of them. The carve-out sentence states the routing and nothing more; the guide, offer, and invocation mechanics are never restated in `SKILL.md` (canvas Norm: lazy-load pattern). Step 1's continuation rule is unchanged: ordinary feature flow → Step 2; explicit config request → report the resulting config and stop.
2. **One conditional one-liner instruction, placed once** — in the "AskUserQuestion and decision transparency" preamble (which already owns all transparency-line phrasing), not repeated inside Steps 4/6/7/8: if the first-run onboarding ran earlier in this same run, each phase launch (Steps 4, 6, 7, 8) is preceded by one short line in the conversation's language saying what the phase does and what will come back, alongside the existing `[automatic decision]` lines — first run only. The four one-liner templates live in `first-run.md`; `SKILL.md` carries only the conditional sentence. "First run" is conversation-scoped state (the onboarding ran earlier in this run), never a file — this is what keeps the interrupted-onboarding case stateless and idempotent.
3. **Frontmatter:** `description` gains a mention of the first-run onboarding and the optional `spdd-install` invocation (the existing auto-trigger sentence stays intact so routing is unaffected); `metadata.version` 1.15 → 1.16.

Steps 2, 3, 3-alt, 3-dedicated, and 4–8 are otherwise untouched: per-phase detection, silent fallback, the never-block rule string (byte-identical — `scripts/check-agent-sync.sh` must keep passing without modification), and the phase invocation contracts stay exactly as shipped (canvas Out of scope). After an accepted `spdd-install` run, Dedicated mode needs no extra wiring — Step 2's detection is per-phase and late-bound, so phases that just gained wrappers are found naturally later in the same run.

### `spdd-agent/assets/first-run.md` (NEW) — sequence and ownership

The asset owns, in order:

1. **Guide** (shown before any model-choice question): brief, in the conversation's language — what the canvas → design → implement → verify flow does, that it pauses at foreground checkpoints to resolve `⚠️ Confirm:` lines, and where artifacts are written (`spdd/changes/<id>/`, `spdd/specs/<domain>.md`). A short paragraph plus the two paths — not a manual.
2. **Bootstrap hand-off:** apply `model-bootstrap.md`'s "First-run bootstrap" section exactly as today — that file stays the sole owner of every bootstrap `AskUserQuestion` mechanic and the config write; `first-run.md` delegates to it, never restates it.
3. **Dedicated-layer offer**, fired only when both conditions hold: (a) the host exposes a subagent mechanism — the same mechanism Step 2's Isolated levels test for (Claude Code's `Agent` tool, opencode's Task tool with a `subagent_type`, or the equivalent), checked the same way; (b) not all four dedicated `spdd-<phase>.md` files in the current host's agent directory are well-formed — reusing Step 2's exact well-formedness definition (parseable frontmatter, required fields present, non-empty body) and its strictly per-host directory rule; no new definition is invented. One `AskUserQuestion` — run the `spdd-install` flow now? — with "yes" pre-marked as recommended, preceded by one or two lines explaining the optional dedicated layer. Inline-only hosts (no subagent mechanism at all) skip the offer entirely while the guide still shows; all-four-files-already-well-formed skips the offer silently — per-phase Dedicated detection and the opencode divergence check then behave exactly as today against the freshly bootstrapped config values, report-only. Some-but-not-all four well-formed still fires the offer (partial install).
4. **On accept:** invoke `spdd-install` in the foreground — via the host's skill-loading mechanism, or by reading its installed `SKILL.md` and executing it inline (same fallback shape as Inline mode) — then continue to Step 2 (or, on the config-request path, report the resulting config and stop). `spdd-agent` performs none of the installation writes and restates none of `spdd-install`'s steps; `spdd-install`'s own per-host `AskUserQuestion` confirmations remain the only write gate. Fallbacks, from the canvas's edge cases: if `spdd-install`'s Step 1 hard guard fires (config ended up incomplete — e.g. an interrupted bootstrap), report the guard's message, never retry, never bypass, and continue the feature flow in Isolated/Inline mode; if the skill can't be loaded and its `SKILL.md` is unreachable (per-skill symlink install skipped it), report that the installer skill isn't available — pointing at README's manual-install step — write nothing, and continue without the dedicated layer.
5. **On decline:** note that the layer stays available via explicit `/spdd-install` at any time, and continue in Isolated/Inline mode exactly as today.
6. **Per-phase one-liner templates** for Steps 4/6/7/8 — one line each, in the conversation's language, first run only.

The asset also states the two boundaries the canvas pins: project-level setup stays lazy (the onboarding never touches the target project — no guard hook, no `subagentPromptCacheTtl`, no `spdd/` scaffolding, no `spdd/norms.md`; the phase skills keep offering those themselves), and onboarding text never leaks into artifacts — guide and one-liners exist only in the orchestrator's foreground conversation, while canvas/plans/specs stay English per the language norm.

### `spdd-install/SKILL.md` — wording only

Frontmatter `description` and the intro sentence (currently "It never runs as part of `spdd-agent`'s feature-build flow — it is reached only by explicit `/spdd-install` invocation.") reworded per the canvas's frontmatter-changes table: reached only by explicit `/spdd-install`, or by `spdd-agent`'s first-run onboarding — offered once, confirmation-gated — while keeping "never auto-triggers, never mid-flow". Steps 1–6 untouched. `metadata.version` 1.1 → 1.2.

### Mirror docs (`CLAUDE.md`, `AGENTS.md`) and `README.md`

- **Overviews (audience-specific — each file keeps its own voice):** fix the stale pre-v1.15 sentences — CLAUDE.md's "there is no `.claude/agents/*.md` layer — orchestration is 100% inside `spdd-agent/SKILL.md`…" and AGENTS.md's "there is no separate agent-file layer for any host…" — to state the actual v1.15+ shape: orchestration lives in `spdd-agent/SKILL.md` with ad-hoc/inline as the zero-setup default, plus an optional dedicated per-phase layer installed via `/spdd-install` (offered once at `spdd-agent`'s first run).
- **Auto-trigger rows (audience-specific):** the `spdd-agent` row gains the first-run onboarding (guide + confirmation-gated `/spdd-install` offer); the `spdd-install` row drops "never offered or triggered from inside `spdd-agent`'s feature-build flow" in favor of the carve-out wording — never auto-triggers on its own; reached by explicit `/spdd-install`, or offered once (confirmation-gated) by `spdd-agent`'s first-run onboarding.
- **Structure section (shared — byte-identical in both files, landed in the same pass):** add a `spdd-agent/assets/first-run.md` line with its lazy-load comment (the same treatment `model-bootstrap.md` received when it was created — precedent: SPDD-2026-09-01-0857 plan-01), and append "first-run onboarding" to the `spdd-agent/evals/evals.json` line's coverage comment. No Gotchas or Conventions edits — the canvas asks for none, and the existing lazy-load Gotcha already states the pattern generically.
- **README:** reword the "never invoked automatically from `spdd-agent`'s own flow" claim in the "Optional dedicated subagents" callout, and the opt-in phrasing in the "No vendor lock-in" fast-path bullet, to the carve-out shape (offered once at first run, confirmation-gated; otherwise explicit `/spdd-install` only; never mid-flow), and add a first-run onboarding sentence to the `spdd-agent` description. The manual `ln -s` install instructions stay untouched — the unreachable-installer fallback points at them.

### Evals (`spdd-agent/evals/evals.json`) — ids 90–96

The file currently tops out at id 81, so 90+ is free as the canvas states. Seven new cases, one per bullet in the canvas's Eval operation, following the existing case shape (`id`, `prompt`, `expected_output`, `setup`, `assertions`) and language conventions (Spanish prompts, English expected_output/assertions). Each setup pins all three determinism inputs: `~/.config/spdd/config.json` absence, host subagent-mechanism presence, and dedicated-files state:

- **90 — offer accepted:** guide appears before the model-choice questions; bootstrap completes; offer accepted; `spdd-install` invoked in the foreground with its own confirmations as the only write gate; phases launch in Dedicated mode later in the same run; guide and one-liners appear only in the orchestrator's conversation, never inside the canvas or plans.
- **91 — offer declined:** nothing written beyond config.json; the "available via `/spdd-install` at any time" note appears; the flow continues in Isolated/Inline mode.
- **92 — host without subagent mechanism:** the offer is skipped entirely; the guide still shows; the flow continues inline.
- **93 — dedicated files already present:** the offer is skipped; per-phase Dedicated detection and the opencode divergence check behave exactly as today against the freshly bootstrapped config values, report-only.
- **94 — non-first run (fast path):** no guide, no offer, no per-phase one-liners; behavior byte-identical to today.
- **95 — direct-route first use:** no onboarding, no bootstrap, no offer — lean as today (the existing "model bootstrap does not block the direct route" norm).
- **96 — config-request first use:** the onboarding (guide + offer) fires with the bootstrap, and the run still ends after reporting the resulting config; no feature flow starts.

Confirmed 2026-09-07 (foreground): extend the `expected_output` prose of existing cases 32 and 46 with one clause each, acknowledging the onboarding that now surrounds the first-run bootstrap — their setups exercise exactly that case (32: first-run bootstrap under both host-detection branches; 46: first-run bootstrap after complete-route routing). Their assertions were re-checked against the new flow and remain true as written — `model-bootstrap.md` is still read before any model-selection `AskUserQuestion`, and routing still precedes the bootstrap — so the assertions stay untouched. Without the prose extension, 32/46 would describe a first run that silently omits the new guide/offer while new case 90 describes the same scenario including them.

Ids 97+ stay free for `spdd-verify`'s targeted edge-case tests (guard fires mid-onboarding, installer unreachable, partially-installed dedicated files, fresh-config marker divergence, onboarding text leaking into artifacts, interrupted-onboarding idempotency), per the canvas's Safeguards.

---

## Out of scope for this plan

- `spdd/specs/spdd-agent.md` and `spdd/specs/spdd-install.md` — fold-back at `spdd-verify` time only, never during implementation (canvas Entities)
- `spdd-install/SKILL.md` Steps 1–6 — untouched; only its description, intro sentence, and version change
- `spdd-agent/assets/model-bootstrap.md` — unchanged; the onboarding wraps its first-run section, never duplicates it
- The 8 wrapper templates and the never-block rule string in Step 3 — untouched; `scripts/check-agent-sync.sh` must keep passing without modification
- Project-level setup (guard hook, `subagentPromptCacheTtl`, `spdd/` scaffolding, `spdd/norms.md`) — stays per-project lazy in the phase skills
- Runtime writes to `~/.config/spdd/config.json`, the dedicated agent files, or `~/.claude/settings.json` — this change ships markdown only; those remain owned by `model-bootstrap.md`'s flow and `spdd-install` respectively
- Automatic `spdd-install` offers on non-first runs — the opencode divergence check stays report-only, pointing at `/spdd-install`
