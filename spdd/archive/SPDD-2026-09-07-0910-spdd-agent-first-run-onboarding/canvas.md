# REASONS: spdd-agent first-run onboarding — guided setup + optional spdd-install invocation

> Generated on 2026-09-07. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Verified
> Confirmed: 2026-09-07 · Verified: 2026-09-07 (spdd-verify; sole plan plan-01-first-run-onboarding verified, folded into `spdd/specs/spdd-agent.md` and `spdd/specs/spdd-install.md`)

---

## Requirements

**User story:**
As a first-time SPDD user, when I describe a feature and `spdd-agent` runs for the first time on my machine, I want the skill to guide me through the whole process — what the flow does, what it will ask me, and where artifacts are written — and to invoke `spdd-install` for the optional dedicated per-phase subagent layer when it isn't installed yet, so that my very first run already uses the best available execution mode without me having to read the docs first.

**Acceptance criteria:**

- **[NEW]** Scenario: first run shows an onboarding guide before anything is asked
  - WHEN `spdd-agent` runs the complete route and Step 1's completeness check classifies the run as first-run bootstrap (`~/.config/spdd/config.json` does not exist)
  - THEN the skill presents, in the conversation's language and before the model-choice questions, a brief guide: what the canvas → design → implement → verify flow does, that the flow pauses at foreground checkpoints to resolve `⚠️ Confirm:` lines, and where artifacts are written (`spdd/changes/<id>/`, `spdd/specs/<domain>.md`); the guide's content lives in a dedicated asset read only for this case, keeping `SKILL.md` lean (same lazy-load pattern as `model-bootstrap.md`)

- **[NEW]** Scenario: first run offers the dedicated layer via spdd-install (Confirmed 2026-09-07: carve-out accepted — first-run only, confirmation-gated, `spdd-install` stays the sole writer; supersedes the v1.15 blanket norm "spdd-install is never offered or invoked from inside spdd-agent's feature-build flow" recorded in `spdd/specs/spdd-agent.md`, `spdd/specs/spdd-install.md`, `spdd-install/SKILL.md`'s description, README, and both mirror docs' auto-trigger tables)
  - WHEN the first-run case fires, the host exposes a subagent mechanism (Step 2's Isolated levels), and not all four dedicated `spdd-<phase>.md` files for the current host are well-formed
  - THEN after the model-config bootstrap completes, `spdd-agent` explains the optional dedicated layer in one or two lines and asks via `AskUserQuestion` whether to run the `spdd-install` flow now, with "yes" pre-marked as recommended — installing is a side-effect action, so nothing is written without explicit confirmation and the offer is never silent or assumed

- **[NEW]** Scenario: accepted offer invokes spdd-install in the foreground
  - WHEN the user accepts the offer
  - THEN `spdd-agent` invokes the `spdd-install` skill in the foreground — via the host's skill-loading mechanism, or by reading its installed `SKILL.md` and executing it inline (same fallback shape as Inline mode) — before continuing to Step 2; `spdd-agent` performs none of the installation writes itself and restates none of `spdd-install`'s steps; `spdd-install`'s own per-host `AskUserQuestion` confirmations remain the only gate for the actual writes; the phases that just gained wrappers use Dedicated mode later in the same run

- **[NEW]** Scenario: declined offer proceeds unchanged
  - WHEN the user declines the offer
  - THEN nothing is written for the dedicated layer, `spdd-agent` notes that the layer stays available via explicit `/spdd-install` at any time, and the flow continues in Isolated/Inline mode exactly as today

- **[NEW]** Scenario: no subagent mechanism skips the offer
  - WHEN the first-run case fires on a host with no subagent mechanism at all (Inline-mode host)
  - THEN the offer is skipped entirely — dedicated wrappers would be unusable there — while the guide still shows and the flow continues inline

- **[NEW]** Scenario: dedicated files already present skips the offer
  - WHEN the first-run case fires and all four dedicated files for the current host are already well-formed (e.g. hand-installed before any `spdd-agent` run)
  - THEN the offer is skipped; per-phase Dedicated detection and the opencode divergence check behave exactly as today against the newly bootstrapped config values, report-only

- **[MODIFIED]** Scenario: the offer exists only inside the first-run onboarding (Confirmed 2026-09-07: intentional — the existing Norms in `spdd/specs/spdd-agent.md` and `spdd/specs/spdd-install.md` are superseded by the accepted carve-out)
  - WHEN any non-first run executes (config.json already complete — fast path, repair, migration, malformed — or any later run)
  - THEN behavior is exactly as today: no guide, no offer, no per-phase one-liners; Step 2's per-phase Dedicated detection with silent fallback is unchanged; the only `/spdd-install` mentions remain the opencode divergence transparency line and the phase reports

- **[NEW]** Scenario: per-phase guidance during the first run (Confirmed 2026-09-07: one-line per-phase guidance during the first run only — the upfront guide alone is not enough)
  - WHEN the first-run case fired earlier in the same run
  - THEN as each phase launches (Steps 4, 6, 7, 8), `spdd-agent` adds one short line in the conversation's language saying what the phase does and what will come back, alongside the existing `[automatic decision]` transparency lines — first run only, never again on later runs

- **[NEW]** Scenario: direct route on first use stays lean (Confirmed 2026-09-07: first run = Step 1's "config file doesn't exist" case, wherever it fires — feature flow or explicit config request; direct-route first uses stay lean and the onboarding fires on the user's first complete-route run instead)
  - WHEN `~/.config/spdd/config.json` doesn't exist but Step 0's routing decision is direct route
  - THEN the direct route behaves exactly as today — no onboarding, no offer, no config bootstrap (per the existing "model bootstrap does not block the direct route" norm)

- **[NEW]** Scenario: project-level setup stays lazy
  - WHEN the first-run onboarding runs
  - THEN it does not touch the target project — no guard hook, no `subagentPromptCacheTtl`, no `spdd/` scaffolding, no `spdd/norms.md` — those keep their existing per-project lazy handling by the phase skills (`spdd-canvas`/`spdd-implement`/`spdd-verify` still offer the hook themselves)

- **[NEW]** Scenario: first-run case reached via an explicit config request
  - WHEN a first-time user's first interaction with `spdd-agent` is an explicit view/change model-config request and config.json doesn't exist
  - THEN the onboarding (guide + offer) fires with the bootstrap, and the run still ends after reporting the resulting config — no feature flow starts (existing Step 0 routing for config requests)

- **[NEW]** Scenario: eval coverage for the first-run flow
  - WHEN the change is considered complete
  - THEN `spdd-agent/evals/evals.json` contains new cases (next free ids: 90+) covering: first-run guide shown + offer accepted (install runs, flow continues in Dedicated mode); offer declined (flow continues, nothing written); host without subagent mechanism (offer skipped); dedicated files already present (offer skipped); non-first run (no guide, no offer); direct-route first use (lean); config-request first use (onboarding fires, run still stops)

**Out of scope:**
- Project-level onboarding — guard-hook/TTL install, `spdd/` scaffolding, `spdd/norms.md` — stays per-project lazy in the phase skills
- Any change to `spdd-install`'s Steps 1–6 (its hard config guard, per-host confirmations, alias→id table, resync logic) — only its description/intro wording changes
- Automatic `spdd-install` offers on non-first runs — the opencode divergence check stays report-only, pointing at `/spdd-install`
- Config bootstrap from anywhere other than `spdd-agent` Step 1 / `spdd-agent/assets/model-bootstrap.md` (`spdd-install`'s guard keeps pointing back at `spdd-agent`)
- Any change to the never-block rule string, the checkpoint gates, or the phase invocation contracts (Steps 3 / 3-alt / 3-dedicated)

---

## Entities

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| First-run detection | `spdd-agent/SKILL.md` — Step 1's completeness check | Existing | The existing "file doesn't exist → first-run bootstrap" classification becomes the onboarding trigger; no new signal is invented |
| First-run onboarding flow | `spdd-agent/SKILL.md` — routed from Step 1's first-run case | New | Guide → model bootstrap (existing asset) → dedicated-layer offer → optional `spdd-install` invocation; exact step numbering is the design phase's call |
| First-run asset | `spdd-agent/assets/first-run.md` | New | Guide text + offer mechanics + invocation/unavailability fallbacks, lazy-loaded only on the first-run case (same pattern as `model-bootstrap.md`); `SKILL.md` routes to it, never restates it |
| `spdd-install` skill | `spdd-install/SKILL.md` | Existing | Steps 1–6 unchanged; description + intro reworded to admit the first-run entry point while keeping "never auto-triggers, never mid-flow" |
| Model-bootstrap asset | `spdd-agent/assets/model-bootstrap.md` | Existing | Unchanged — the onboarding wraps around its first-run section, never duplicates it |
| Dedicated agent files | `~/.claude/agents/spdd-<phase>.md` · `~/.config/opencode/agents/spdd-<phase>.md` | Existing (runtime) | Detection targets for the offer condition; written only by `spdd-install`, never by `spdd-agent` |
| Mirror docs | `CLAUDE.md` · `AGENTS.md` | Existing | `spdd-agent` + `spdd-install` auto-trigger rows updated (audience-specific per file); stale pre-v1.15 Overview sentences ("there is no separate agent-file layer") corrected in both — found during canvas review, contradicted by v1.15's Dedicated mode; shared sections stay byte-identical |
| README | `README.md` | Existing | The two "never invoked automatically from `spdd-agent`'s flow" claims reworded (opt-in fast-path bullet + "Optional dedicated subagents" callout); a first-run onboarding sentence added to the `spdd-agent` description |
| `spdd-agent` evals | `spdd-agent/evals/evals.json` | Existing | New first-run cases appended (ids 90+) |
| Living specs | `spdd/specs/spdd-agent.md` · `spdd/specs/spdd-install.md` | Existing | Updated only at `spdd-verify` fold-back after verification — not during implementation |

**Frontmatter changes to existing entities:**

| Field | Entity | Required | Notes |
|-------|--------|----------|-------|
| `description` | `spdd-agent/SKILL.md` | yes | Mentions the first-run onboarding and the optional `spdd-install` invocation |
| `metadata.version` | `spdd-agent/SKILL.md` | yes | 1.15 → 1.16 |
| `description` | `spdd-install/SKILL.md` | yes | "never offered or invoked from inside spdd-agent's feature-build flow" → reached only by explicit `/spdd-install` or by `spdd-agent`'s first-run onboarding (offered once, confirmation-gated) |
| `metadata.version` | `spdd-install/SKILL.md` | yes | 1.1 → 1.2 |

---

## Approach

- [ ] Full CRUD (model + repository + service + controller/handler)
- [ ] Endpoint/handler only (on an existing entity)
- [x] Service/internal logic only (no presentation layer)
- [ ] Async worker / job
- [ ] External service integration — specify: ___
- [ ] UI component / page

**Rationale:** The change is orchestration flow expressed in skill prose plus one new markdown asset, with doc and eval updates — no code, no build step, no presentation layer. The dedicated-layer offer reuses `spdd-install` exactly as it ships; all new logic is confined to routing a first-run case through guide → bootstrap → offer → optional invocation, keeping every existing contract (guards, confirmations, fallbacks) intact.

---

## Structure

```
spdd-agent/SKILL.md                    # first-run onboarding flow routed from Step 1's first-run case; description + version 1.15 → 1.16
spdd-agent/assets/first-run.md          # NEW — guide text, offer mechanics, spdd-install invocation + unavailability fallbacks
spdd-agent/evals/evals.json             # new first-run cases (ids 90+)
spdd-install/SKILL.md                   # description + intro wording: first-run entry point admitted; Steps 1–6 untouched; version 1.1 → 1.2
CLAUDE.md                               # auto-trigger rows (spdd-agent, spdd-install); stale pre-v1.15 Overview sentence fixed
AGENTS.md                               # same updates; shared sections stay byte-identical with CLAUDE.md's
README.md                               # reword both "never invoked automatically" claims; add first-run sentence to the spdd-agent description
spdd/specs/spdd-agent.md                # fold-back at verify time: new scenarios + modified v1.15 norm
spdd/specs/spdd-install.md              # fold-back at verify time: modified "never invoked or offered" norm
```

---

## Operations

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

## Norms

- [ ] Document content (canvas, plans, specs) in English; conversational onboarding text follows the conversation's language setting
- [ ] Acceptance criteria and safeguards edge cases written as WHEN/THEN scenarios; unresolved items marked `⚠️ Confirm:`
- [ ] Lazy-load pattern: `assets/first-run.md` is read only when the first-run case fires — `SKILL.md` routes to it, never restates its content
- [ ] `spdd-install` stays the sole owner of every installation write; `spdd-agent` never writes dedicated agent files or `~/.claude/settings.json` itself — it only invokes `spdd-install`, whose per-host `AskUserQuestion` confirmations remain the only write gate
- [ ] Mirror docs: shared sections (Structure, Conventions, Gotchas) byte-identical across `CLAUDE.md` and `AGENTS.md`; audience-specific sections (Overview, per-file auto-trigger tables) may differ by design — any shared-section edit lands in both files in the same pass
- [ ] The never-block rule string in Step 3 and inside the 8 wrapper templates is byte-identical and untouched by this change (`scripts/check-agent-sync.sh` must keep passing)
- [ ] The authoritative skill version lives in each `SKILL.md`'s `metadata.version` frontmatter — bump on change (`spdd-agent` 1.16, `spdd-install` 1.2); spec Norms never restate version counters

---

## Safeguards

**Tests to write** (this repo's tests are its eval suites):

- [ ] First-run happy path, offer accepted: guide shown → models bootstrapped → offer accepted → `spdd-install`'s own confirmations run → phases launch in Dedicated mode → flow completes
- [ ] First-run, offer declined: nothing written beyond config.json; flow continues in Isolated/Inline mode; the "available via `/spdd-install` anytime" note appears
- [ ] Second run: fast path unchanged — no guide, no offer, no per-phase one-liners
- [ ] Direct-route first use: no onboarding, no bootstrap, lean as today

**Edge cases (as WHEN/THEN scenarios — `spdd-verify` writes a targeted test for each one not already covered):**

- Scenario: spdd-install's hard guard fires inside the onboarding
  - WHEN the user accepted the offer but `spdd-install`'s Step 1 guard stops it (config ended up incomplete — e.g. the model bootstrap was interrupted)
  - THEN `spdd-agent` reports the guard's message, never retries and never bypasses it, and continues the feature flow in Isolated/Inline mode
- Scenario: spdd-install is not installed on this host
  - WHEN the user accepted the offer but the `spdd-install` skill cannot be loaded and its `SKILL.md` is unreachable (per-skill symlink install skipped it)
  - THEN `spdd-agent` reports that the installer skill isn't available — pointing at README's manual-install step — writes nothing, and continues without the dedicated layer
- Scenario: partially installed dedicated files
  - WHEN some but not all four dedicated files for the current host are well-formed on first run
  - THEN the offer still fires — `spdd-install` installs the missing files and resyncs the existing ones, each behind its own confirmation
- Scenario: dedicated files present while config is freshly bootstrapped (opencode)
  - WHEN all four opencode agent files exist with `spdd-install:model-source` markers while the first-run bootstrap just wrote new config values
  - THEN per-phase divergence checks report any marker-vs-config mismatch exactly as today — report-only, never rewritten from `spdd-agent`
- Scenario: onboarding text must not leak into artifacts
  - WHEN the onboarding runs during a flow whose phases are delegated to subagents
  - THEN the guide and the per-phase one-liners exist only in the orchestrator's foreground conversation — never inside the canvas, plans, or specs, which stay in English per the language norm
- Scenario: interrupted onboarding
  - WHEN the user aborts the run before the onboarding finishes
  - THEN the next run re-enters onboarding only if config.json is still missing — the onboarding is stateless and idempotent, leaving no partial state beyond what was explicitly confirmed

**Production rollback:**

Revert the repo commit(s) — the skills are stateless markdown. User-level artifacts the onboarding may have led to (`~/.config/spdd/config.json`, the dedicated agent files, the `permissions.deny` entries) persist but are inert under the reverted `spdd-agent` (it simply no longer offers or invokes the installer); each is independently removable by hand (delete the 4 agent files, remove the 4 deny entries). No data migration, no backward-compat shim.
