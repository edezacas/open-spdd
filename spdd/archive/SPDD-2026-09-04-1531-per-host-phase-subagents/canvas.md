# REASONS: Per-host dedicated phase subagents for SPDD

> Generated on 2026-09-04. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Confirmed

---

## Requirements

**User story:**
As an SPDD framework user, I want an optional per-host layer of dedicated subagent definitions (one per phase, for Claude Code and opencode), installed and resynced through a dedicated `spdd-install` skill, so that every phase runs with the right model, a deterministically preloaded skill, and structurally scoped tools — without the orchestrator rebuilding a long ad-hoc prompt on every call, and without provisioning logic living inside the feature-build flow itself.

**Acceptance criteria:**

*(NEW = behavior that doesn't exist yet; MODIFIED = changes something already in `spdd/specs/spdd-agent.md`.)*

- **[NEW]** Scenario: dedicated phase subagent is used when present
  - WHEN `spdd-agent` (complete route) reaches Step 2 and a dedicated agent definition for the phase exists in the host's agent directory (Claude Code: `~/.claude/agents/spdd-<phase>.md`; opencode: `~/.config/opencode/agents/spdd-<phase>.md`)
  - THEN each phase (canvas, design, implement, verify) launches via that dedicated `subagent_type`, and the per-call prompt shrinks to the phase context only — the never-block rule and the report contract live in the wrapper's body, not repeated per invocation
- **[MODIFIED]** Scenario: Step 2 detection becomes four-level *(confirmed by user — intentional; `spdd-agent` acts as the sole orchestrator of the dedicated phase agents, which are never auto-delegated; see Pending confirmations #1)* — dedicated → ad-hoc isolated with model override → ad-hoc isolated without override → inline, with a new transparency line for the dedicated case
  - WHEN Step 2 runs on the complete route
  - THEN it first checks for a dedicated per-phase agent file; if absent it falls back to today's ad-hoc isolated contract (with or without model override), and if the host has no subagent mechanism at all, inline mode — hosts without agent files keep byte-identical current behavior
- **[NEW]** Scenario: Claude Code model precedence preserved
  - WHEN a dedicated Claude Code phase agent is invoked via the `Agent` tool
  - THEN the orchestrator passes the per-invocation `model` param taken from `~/.config/spdd/config.json` (per host docs, it overrides the agent file's frontmatter `model`), so config.json remains the single source of truth for per-phase models and the frontmatter value is only a fallback
- **[NEW]** Scenario: opencode per-phase model restored
  - WHEN a dedicated opencode phase agent is invoked via the Task tool (which has no model field)
  - THEN the phase model from config.json has already been written into the agent file's frontmatter by `spdd-install` at install/resync time, restoring the per-phase model selection that today's "isolated without model override" mode loses
- **[NEW]** Scenario: opencode divergence warning, detection vs. remediation split
  - WHEN a dedicated opencode phase agent is effectively running a different model than config.json's current value for that phase (per the marker-based comparison in the scenario below), at the moment `spdd-agent` is about to invoke it
  - THEN `spdd-agent` only detects and reports the divergence before launching (the run proceeds with the agent file's model, since Task cannot override it) and points the user at `/spdd-install` to resync — `spdd-agent` never rewrites the agent file itself; the confirmation-gated rewrite toward config.json's value is `spdd-install`'s job, run separately
- **[NEW]** Scenario: divergence comparison never needs the alias→ID mapping table outside `spdd-install`
  - WHEN `spdd-agent` (Step 2) or `spdd-install` (resync) needs to know whether a dedicated opencode agent's model is in sync with config.json
  - THEN they compare config.json's current raw value against a provenance marker `spdd-install` embeds in the agent file at write time (`<!-- spdd-install:model-source=<raw-config-value> -->`, right after the frontmatter) — a plain string comparison, never a translated-ID comparison. This exists because config.json commonly stores tier aliases (`sonnet`, the bootstrap default) while the agent file's `model:` field always stores the already-translated provider-qualified ID; comparing the alias directly against the translated ID would report a false divergence on every run on any machine using tier-style values. Only `spdd-install` (which owns the alias→ID table) ever performs the translation — `spdd-agent` never needs a copy of that table, since it only compares raw strings against the marker
- **[NEW]** Scenario: deterministic skill preload in Claude Code
  - WHEN a dedicated Claude Code phase agent declares its phase skill in the `skills:` frontmatter field
  - THEN the full SKILL.md content is preloaded into the subagent's context at launch (no runtime skill discovery), while the wrapper body still references the phase's installed `SKILL.md` path as the load instruction — the wrapper adds no logic, so `SKILL.md` stays the single behavioral authority
- **[NEW]** Scenario: wrappers are hidden and orchestrator-invoked only
  - WHEN the 8 wrapper agent definitions are installed (4 phases × 2 hosts)
  - THEN they are reachable only through `spdd-agent`'s orchestration, never picked proactively for unrelated work: opencode hides them from the `@` menu via `hidden: true` in the agent file itself; Claude Code has no such frontmatter field, so it relies on the `description` forbidding auto-delegation, reinforced by four `permissions.deny: ["Agent(spdd-<phase>)"]` entries that `spdd-install` writes to the user-level `~/.claude/settings.json` — never inside the agent file's own frontmatter, which has no `permissions.deny` field (confirmed)
- **[NEW]** Scenario: per-phase structural tool scoping
  - WHEN each wrapper is defined
  - THEN its frontmatter restricts tools to what that phase needs (proposed defaults in the Structure section; `spdd-design` finalizes the exact lists)
- **[NEW]** Scenario: installing and resyncing the dedicated agents is a separate, explicit skill
  - WHEN a user wants to provision or update the 8 wrapper files (and, on Claude Code, the 4 `permissions.deny` entries)
  - THEN they invoke `/spdd-install` directly — it is never offered, triggered, or mentioned mid-flow by `spdd-agent`'s feature-build flow (Steps 0–9), matching this repo's existing pattern where `spdd-canvas`/`spdd-design`/`spdd-implement`/`spdd-verify` never auto-trigger and are reached only by explicit invocation or delegation; see Pending confirmations #2 for why this shape was chosen over folding it into `spdd-agent`

**Out of scope:**
- `spdd-agent` itself getting a dedicated agent wrapper — structurally impossible, not just unscoped: `spdd-agent` must hold the live foreground turn to run its checkpoint gates (Steps 5/6/8) with a real, blocking `AskUserQuestion`. Every subagent (dedicated or ad-hoc) runs in the background under the never-block rule, with no `AskUserQuestion` at all — turning `spdd-agent` into a subagent would strip it of the one capability that makes it the orchestrator. `spdd-agent` always runs as the top-level skill, invoked directly (`/spdd-agent` or auto-trigger) in the main conversation, never delegated to.
- `sync` and `migrate` phases — wrappers cover only the four flow phases (canvas, design, implement, verify)
- Other hosts (codex, etc.) — the ad-hoc/inline fallback continues to serve them unchanged
- Any change to `~/.config/spdd/config.json`'s schema or its role as single source of truth
- Host extras unrelated to this feature (Claude Code agent `memory`/`isolation: worktree`, agent teams, opencode `temperature`/`color`)
- Auto-invoking wrappers outside `spdd-agent`'s orchestration
- `spdd-install` duplicating `spdd-agent/assets/model-bootstrap.md`'s first-run bootstrap / repair / migration logic — `spdd-install` requires `~/.config/spdd/config.json` to already be complete (the applicable section has all six phase values) and, if it isn't, tells the user to run `spdd-agent` first instead of bootstrapping it itself
- `spdd-agent/assets/model-bootstrap.md` — untouched by this feature entirely; its config.json bootstrap/repair/migration flow has no overlap with `spdd-install`'s job

---

## Entities

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| Dedicated phase agents (user-level, Claude Code) | `~/.claude/agents/spdd-{canvas,design,implement,verify}.md` | New | 4 files; YAML frontmatter + thin body referencing the installed SKILL.md; written by `spdd-install` |
| Dedicated phase agents (user-level, opencode) | `~/.config/opencode/agents/spdd-{canvas,design,implement,verify}.md` | New | 4 files; opencode markdown agent format (`mode: subagent`, `hidden: true`); written by `spdd-install` |
| Wrapper templates (repo source) | `spdd-{canvas,design,implement,verify}/assets/agent-{claude-code,opencode}.md` | New | 8 template files, one pair per phase skill — same duplication pattern as `assets/hook-setup.md` (skills install and run independently; no cross-folder references) |
| `spdd-install` skill | `spdd-install/SKILL.md` | New | Installs/resyncs the 8 wrapper files into the two host agent directories and the 4 Claude Code `permissions.deny` entries; invoked manually via `/spdd-install` only, never auto-triggers, never delegated to by `spdd-agent` |
| `spdd-install` eval coverage | `spdd-install/evals/evals.json` | New | Install, resync, divergence-remediation, missing-config-guard, and permissions.deny-merge cases |
| "Detect subagent support" (Step 2) | `spdd-agent/SKILL.md` | Existing (modified) | Gains the dedicated-agent detection level, its transparency line, and read-only divergence reporting |
| "Phase invocation contract" (Step 3) | `spdd-agent/SKILL.md` | Existing (modified) | Dedicated branch: prompt carries phase context only; never-block rule and report contract come from the wrapper body |
| Model config | `~/.config/spdd/config.json` | Existing | Unchanged schema; remains the single source of truth for per-phase models; read (never written) by `spdd-install` |
| Claude Code auto-delegation deny rules (user-level) | `~/.claude/settings.json` (`permissions.deny`) | Existing (modified) | 4 entries, one per Claude Code wrapper: `Agent(spdd-<phase>)` — written by `spdd-install`; not a per-agent frontmatter field, since none exists |
| Eval coverage — orchestrator | `spdd-agent/evals/evals.json` | Existing (modified) | New cases for the detection levels, model precedence, divergence *detection and reporting*, and fallback guarantees — remediation cases live in `spdd-install/evals/evals.json` instead |
| Drift check | `scripts/check-agent-sync.sh` | New | Fails if any wrapper template's never-block string is not byte-identical to `spdd-agent/SKILL.md`'s — repo tooling only, never read by a `SKILL.md` at execution time. Required by this change (plan-03 builds it; it's what `spdd-verify` exercises for the drift-detection Safeguard below), not optional |

**Main fields of the new entity (wrapper frontmatter, both hosts):**

| Field | Claude Code | opencode | Notes |
|-------|-------------|----------|-------|
| identity | `name: spdd-<phase>` | filename `spdd-<phase>.md` | Same four ids on both hosts |
| description | `description:` forbidding auto-delegation | `description:` (required) | "Orchestrator-invoked only — part of the SPDD flow; never delegate proactively" |
| model | `model:` fallback tier | `model: <provider/model-id>` + a `<!-- spdd-install:model-source=<raw-config-value> -->` body comment | Fallback only on Claude Code (per-invocation param wins); on opencode, `spdd-install` writes the translated id into `model:` and the untranslated config.json value into the marker comment, so later divergence checks compare raw strings against the marker instead of needing the alias→ID table again |
| tools | `tools:` per-phase whitelist | `permission:` per-phase keys | Restrict to phase needs (opencode docs deprecate `tools` in favor of `permission`) |
| hidden | resolved — description wording + `permissions.deny` in `~/.claude/settings.json` (no such frontmatter field exists) | `hidden: true` | opencode: hidden from `@` menu, still Task-invocable; Claude Code subagents are Agent-tool-invoked by nature and gain no frontmatter-level hiding — the deny rule lives outside the agent file |
| mode | n/a (all `.claude/agents/*.md` are subagents) | `mode: subagent` | opencode requires `subagent` mode for `hidden` to apply |
| skills preload | `skills: [<phase-skill>]` | n/a — body instructs reading the installed SKILL.md | Claude Code-only deterministic preload; opencode wrappers keep the read-the-file instruction |

---

## Approach

- [x] Service/internal logic only (no presentation layer) — adapted to this repo: static template assets, a new install/resync skill, plus orchestration-logic edits in `spdd-agent/SKILL.md`; no new user-facing flow steps inside the feature-build flow
- [ ] Full CRUD (model + repository + service + controller/handler) — not applicable (skills framework, no backend)
- [ ] Endpoint/handler only — not applicable
- [ ] Async worker / job — not applicable
- [ ] External service integration — not applicable
- [ ] UI component / page — not applicable

**Rationale:**
Dedicated agent files are the documented per-host extension point (Claude Code: `~/.claude/agents/*.md` with per-invocation model precedence and a `skills:` preload field; opencode: `~/.config/opencode/agents/*.md` with `model`, `permission`, and `hidden` options). Wrapping — not rewriting — the phase skills keeps `SKILL.md` as the single behavioral authority, and the layered fallback preserves today's behavior wherever the layer is absent, which makes the whole change additive and rollback-cheap. Provisioning them lives in its own `spdd-install` skill, mirroring the separation a more mature multi-host SDD framework (`gentle-ai`, a compiled installer CLI) uses between its `install`/`sync` commands and its per-flow orchestrator content — same shape (provisioning kept out of the build flow, triggered only by explicit user action), adapted to this repo's skills-only architecture (no compiled binary, so the equivalent is a dedicated skill rather than a CLI subcommand). Expected gains motivating the feature: per-phase model selection restored in opencode (lost today), deterministic skill preload and structural tool scoping in Claude Code, shorter orchestrator prompts per call, and an `spdd-agent/SKILL.md` that stays focused on orchestrating the build flow rather than growing installer logic.

---

## Structure

Files to create or modify, with real project paths:

```
spdd-canvas/assets/agent-claude-code.md      # wrapper template → ~/.claude/agents/spdd-canvas.md
spdd-canvas/assets/agent-opencode.md         # wrapper template → ~/.config/opencode/agents/spdd-canvas.md
spdd-design/assets/agent-claude-code.md
spdd-design/assets/agent-opencode.md
spdd-implement/assets/agent-claude-code.md
spdd-implement/assets/agent-opencode.md
spdd-verify/assets/agent-claude-code.md
spdd-verify/assets/agent-opencode.md
spdd-install/SKILL.md                        # new: install/resync flow for the 8 wrapper files + permissions.deny entries
spdd-install/evals/evals.json                # new: install/resync/divergence/guard eval cases
spdd-agent/SKILL.md                          # Step 2: dedicated-agent detection level + transparency line + read-only divergence report; Step 3: dedicated branch of the invocation contract
spdd-agent/evals/evals.json                  # new eval cases (detection/invocation only — remediation cases live in spdd-install)
scripts/check-agent-sync.sh                  # never-block rule drift check (repo tooling only)
CLAUDE.md                                    # register spdd-install in the shared Structure section and the Auto-triggers table
AGENTS.md                                    # mirror: Structure is a byte-identical shared section (spdd/specs/spdd-agent.md Norms) — must gain the same row in the same pass; Auto-triggers also kept in sync by existing convention
```

User-level install targets (outside the repo, written only by `/spdd-install`, only after explicit user confirmation): `~/.claude/agents/spdd-{canvas,design,implement,verify}.md`, `~/.config/opencode/agents/spdd-{canvas,design,implement,verify}.md`, and — Claude Code only — four `permissions.deny` entries added to `~/.claude/settings.json` (`Agent(spdd-canvas)`, `Agent(spdd-design)`, `Agent(spdd-implement)`, `Agent(spdd-verify)`).

Proposed per-phase tool scoping (defaults; `spdd-design` finalizes):

- **canvas**: read/search tools + `Write` (canvas file only) + `Bash` for date/git checks — no `Edit`
- **design**: read/search tools + `Write` (plan files only)
- **implement**: read/search tools + `Write`, `Edit`, `Bash` (full implementation)
- **verify**: read/search tools + `Bash` (tests) + `Edit` (spec fold-back, archive moves)

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Detect subagent support" (Step 2, modified) | Level 0: dedicated `spdd-<phase>` agent file exists in the host's agent dir → Dedicated mode. Levels 1–2: ad-hoc isolated with / without model override (today's behavior). Level 3: inline. Each announced with its own `[automatic decision]` transparency line. On opencode, also detects and reports (never rewrites) a model divergence between the agent file's `spdd-install:model-source` marker and config.json's current raw value — a plain string comparison, no alias→ID translation performed here |
| Contract | Dedicated invocation — Claude Code | `Agent` call with `subagent_type: "spdd-<phase>"` and `model:` from config.json; the per-invocation `model` overrides the frontmatter fallback; the wrapper's `skills:` field preloads the phase SKILL.md |
| Contract | Dedicated invocation — opencode | Task tool with `subagent_type: "spdd-<phase>"`; no model field exists — the phase model is applied via the agent file's frontmatter |
| Prompt | Dedicated-mode subagent prompt | Phase context only (the exact context listed for the phase in `spdd-agent` Steps 4–8, plus the routing-already-decided note for canvas); never-block rule and report contract carried by the wrapper body, not repeated per call |
| Asset | 8 wrapper templates | Thin body: load and follow the phase's installed SKILL.md, never-block rule verbatim, report back per the phase skill's own Report step |
| Skill | `spdd-install` — install/resync | Reads config.json (requires it already complete — else tells the user to run `spdd-agent` first) and the 8 wrapper templates from each phase skill's own `assets/`; writes them, confirmation-gated, into `~/.claude/agents/` / `~/.config/opencode/agents/`; on opencode, stamps the phase model from config.json into the agent file's frontmatter *and* the untranslated raw value into a `spdd-install:model-source` body marker; on Claude Code, merges the 4 `permissions.deny` entries into `~/.claude/settings.json` |
| Skill | `spdd-install` — divergence remediation | When re-run (resync), compares the agent file's `spdd-install:model-source` marker (not its `model:` field) against config.json's current raw value; on a mismatch, offers a confirmation-gated rewrite of both `model:` (re-translated) and the marker toward config.json's value using the documented alias→ID mapping table; warns (never fails) when a value cannot be translated |
| Eval | `spdd-agent/evals/evals.json` | New cases: dedicated used / fallback to ad-hoc / inline preserved / Claude Code model precedence / opencode divergence *detected and reported* / no-agent-files host unchanged |
| Eval | `spdd-install/evals/evals.json` | New cases: fresh install / resync updates existing files / divergence remediation offer / missing-config guard / permissions.deny merge without clobbering unrelated entries |

---

## Norms

*(No `spdd/norms.md` exists in this repo — feature-specific norms below come from `AGENTS.md` and `spdd/specs/spdd-agent.md`.)*

- SPDD document content is always in English, regardless of the language of the feature description or conversation.
- `SKILL.md` files stay pure Markdown (agentskills.io format); wrapper agent files are host configuration, not skills, and add no logic of their own.
- The never-block rule quoted in `spdd-agent` Step 3 is an exact string — wrapper bodies must carry it byte-identical; drift is caught by repo tooling (`scripts/check-agent-sync.sh`), never checked at skill execution time.
- Per the `assets/hook-setup.md` precedent: each phase skill owns its own wrapper-template copies; nothing references an asset outside its own skill folder — **except `spdd-install`**, whose entire purpose is cross-skill provisioning, so it is the one skill in this repo allowed to read `spdd-{canvas,design,implement,verify}/assets/agent-*.md` directly (the same class of exception `spdd-agent` already has for referencing the other four phase skills by name).
- `scripts/` is repo tooling — no `SKILL.md` may reference it at execution time.
- `spdd-agent/evals/evals.json` is the single source of truth for `spdd-agent`'s own eval coverage; `spdd-install/evals/evals.json` is the single source of truth for `spdd-install`'s; eval ids are never restated elsewhere.
- The change is strictly additive: with no agent files installed, every host's behavior is unchanged.
- Provisioning (install/resync of host-level agent files and permission rules) never lives inside `spdd-agent`'s feature-build flow (Steps 0–9) — it is `spdd-install`'s sole responsibility, reached only by explicit invocation, matching how `spdd-canvas`/`spdd-design`/`spdd-implement`/`spdd-verify` never auto-trigger either.
- Registering `spdd-install` touches `CLAUDE.md`'s and `AGENTS.md`'s **Structure** section — one of the sections `spdd/specs/spdd-agent.md`'s Norms require to stay byte-identical across the two mirror docs — so the new row is added to both files in the same pass, never just one. The Auto-triggers table (technically an audience-specific section per that same spec, free to differ) is kept in sync between the two files anyway, matching the existing convention already visible for every other phase skill's row.

---

## Safeguards

**Tests to write:** *(this repo's test mechanism is the eval suite; CI statically validates eval assets)*

- [ ] Full happy path: complete route with all four dedicated agents present on each host — every phase launches via its wrapper with the right model, reports flow back, and the Step 5/6/7/8 checkpoints stay intact
- [ ] Invalid input validation: malformed agent file (unparseable frontmatter, missing required fields, empty body) → graceful fallback with a warning, never a hard failure
- [ ] `spdd-install` run against an incomplete/missing `~/.config/spdd/config.json` → guard message pointing to `spdd-agent`, no install attempted
- [ ] Edge cases: divergence, auto-delegation guard, drift detection, no-files host (scenarios below)

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted test for each one not already covered):**

- Scenario: dedicated agent file is present but malformed
  - WHEN Step 2 finds `spdd-<phase>.md` but its frontmatter is unparseable or required fields are missing
  - THEN the orchestrator warns, skips Dedicated mode, and falls back to the ad-hoc contract — the flow never blocks or crashes
- Scenario: non-orchestrator context tries to use the wrapper
  - WHEN a primary agent considers the wrapper's description outside `spdd-agent`'s flow
  - THEN the description's forbid-auto-delegation wording prevents proactive delegation on both hosts; opencode additionally hides it via `hidden: true`, and Claude Code additionally hard-blocks it via the `permissions.deny: ["Agent(spdd-<phase>)"]` entries in `~/.claude/settings.json` — the wrapper is reachable only through `spdd-agent`'s invocation
- Scenario: opencode agent-file model diverges from config.json
  - WHEN a dedicated opencode agent's `spdd-install:model-source` marker differs from the phase's current config.json value (compared as raw strings — never the translated `model:` field against a raw config value, which would false-positive on every run wherever config.json stores tier aliases)
  - THEN `spdd-agent` reports the divergence before launching and proceeds with the agent file's model (Task cannot override it) — it does not rewrite anything; running `/spdd-install` separately offers the confirmation-gated rewrite toward config.json's value
- Scenario: `spdd-install` run before config.json is complete
  - WHEN `/spdd-install` runs and the applicable section of `~/.config/spdd/config.json` is missing, incomplete, or the file doesn't exist
  - THEN `spdd-install` does not bootstrap it and does not install anything — it tells the user to run `spdd-agent` (or an explicit model-config request) first
- Scenario: wrapper body drifts from the verbatim never-block rule
  - WHEN `scripts/check-agent-sync.sh` runs (CI or manual) on modified wrapper templates
  - THEN it fails if any wrapper's never-block string is not byte-identical to `spdd-agent/SKILL.md`'s
- Scenario: host has a subagent mechanism but no SPDD agent files
  - WHEN Step 2 finds no dedicated agent file for the phase
  - THEN behavior is byte-identical to today (ad-hoc isolated or inline) — the fallback path is untouched
- Scenario: only one host's wrappers are installed
  - WHEN only Claude Code wrappers exist and the flow runs in opencode (or vice versa)
  - THEN that host falls back per the no-files case — detection is per-host, never cross-host leakage
- Scenario: `spdd-install` re-run (resync) over already-installed files
  - WHEN `/spdd-install` runs and the 8 files (and/or the 4 `permissions.deny` entries) already exist
  - THEN it updates them in place (confirmation-gated) rather than duplicating entries or failing — the `permissions.deny` merge preserves any unrelated pre-existing entries in `~/.claude/settings.json`

**Production rollback:**
Delete the 8 installed wrapper files from the host agent directories (or set `disable: true` on the opencode agents), and remove the 4 `permissions.deny` entries from `~/.claude/settings.json`; Step 2's dedicated-detection level stops matching and every host silently returns to today's ad-hoc/inline behavior. `~/.config/spdd/config.json` is not touched by this feature's runtime path, so no config rollback is needed. Repo-side, remove the template assets, delete `spdd-install/`, and revert the `spdd-agent/SKILL.md` edits.

---

## Pending confirmations

*(All resolved at the `spdd-agent` checkpoint gate on 2026-09-04 — recorded here with the confirmed value. Items 2, 3, and 5 were revised later the same day during canvas review, after a factual check against Claude Code's real subagent schema and a look at how a more mature multi-host SDD framework (`gentle-ai`) separates provisioning from orchestration.)*

1. ✅ **Confirmed** (user, after clarification): Step 2's four-level detection intentionally replaces the three-mode contract in `spdd/specs/spdd-agent.md` — dedicated → ad-hoc with override → ad-hoc without override → inline. User's added constraint: `spdd-agent` is the sole orchestrator — dedicated phase agents act only under its invocation, never auto-delegated.
2. ✅ **Confirmed, revised 2026-09-04**: install/resync flow for the 8 agent files lives in a new, dedicated `spdd-install` skill — invoked manually via `/spdd-install` only, never offered or triggered from inside `spdd-agent`'s feature-build flow. (Original default was for `spdd-agent`'s own bootstrap to offer this inline; revised after checking that `spdd-agent` Step 1's fast path skips `model-bootstrap.md` whenever config.json is already complete, meaning an offer buried there would in practice almost never fire — and after seeing `gentle-ai` keep its `install`/`sync` commands fully separate from its per-flow orchestrator content.) `spdd-install` requires config.json already complete; the repo ships the 8 templates in each phase skill's `assets/`.
3. ✅ **Confirmed, revised 2026-09-04** (first after a factual check against Claude Code's actual subagent frontmatter schema — no `permissions.deny` field exists there; then re-homed into `spdd-install`): hidden mode on Claude Code — forbid auto-delegation via description wording ("orchestrator-invoked only"), reinforced with four `permissions.deny: ["Agent(spdd-<phase>)"]` entries written to the user-level `~/.claude/settings.json` (not the agent file's own frontmatter), by `spdd-install`'s confirmation-gated install/resync flow.
4. ✅ **Confirmed** (default): opencode model-ID translation — `spdd-install` owns a documented alias→ID mapping table and warns (without failing) when a value cannot be translated. Note recorded at the gate: this machine's freshly created config.json already stores full provider-qualified IDs (`opencode-go/glm-5.3` etc.), so in practice the table serves cross-host values written in tier style.
5. ✅ **Confirmed, added 2026-09-04**: `spdd-agent/assets/model-bootstrap.md` stays untouched by this feature — `spdd-install` neither extends it nor duplicates its first-run/repair/migration logic; it only reads the config.json values it produces, and requires them to already be complete.
