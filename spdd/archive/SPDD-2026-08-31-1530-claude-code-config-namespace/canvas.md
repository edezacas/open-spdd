# REASONS: Claude Code model config namespace

> Generated on 2026-08-31 15:30. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Confirmed

---

## Requirements

**User story:**
As a user of `spdd-agent` running under Claude Code, I want the per-phase model configuration to live under a `claude`-specific namespace when the framework detects it is running in that host, so that Claude Code's config is clearly host-scoped and won't collide with settings meant for other hosts (opencode, codex, etc.), while every other host keeps using today's flat structure unchanged.

**Acceptance criteria:**

- **[NEW]** Scenario: host detection runs before Step 1 reads the config
  - WHEN `spdd-agent` reaches Step 1 ("Load or bootstrap the model configuration") on the complete route
  - THEN it first determines whether the current host is Claude Code, using the signal defined in ⚠️ Confirm (1) below, before deciding which section of `~/.config/spdd/config.json` to read or write

- **[NEW]** Scenario: Claude Code detected, nested config already present
  - WHEN the host is detected as Claude Code and `~/.config/spdd/config.json` already contains a `claude` namespace with all six phase values non-empty
  - THEN Step 1 reads model values from that `claude` namespace and proceeds exactly as today, using those six values for Steps 4–8

- **[NEW]** Scenario: Claude Code detected, only legacy flat config present
  - WHEN the host is detected as Claude Code and the config file exists with a top-level flat `models` key but no `claude` namespace
  - THEN `spdd-agent` follows the migration path defined in ⚠️ Confirm (3) below rather than silently reading the flat key as if it were Claude-Code-scoped

- **[NEW]** Scenario: non-Claude-Code host uses the current flat shape
  - WHEN the host is detected as anything other than Claude Code (opencode, codex, or detection is inconclusive)
  - THEN Step 1 reads/writes the top-level flat `models` key exactly as it does today — no behavior change for non-Claude-Code hosts

- **[NEW]** Scenario: first-run bootstrap under Claude Code writes the nested shape
  - WHEN `~/.config/spdd/config.json` does not exist yet and the host is detected as Claude Code
  - THEN the bootstrap flow (Step 1.1) writes the new nested `claude` namespace (shape per ⚠️ Confirm (2)) instead of the flat top-level `models` key

- **[MODIFIED]** Scenario: explicit config view/change request resolves against the detected namespace — CONFIRMED: same host detection applied consistently, generalization is intentional
  - WHEN the user asks to view or change the per-phase model configuration ("qué modelo usa implement", "cambia verify a sonnet") while running under Claude Code
  - THEN `spdd-agent` reads and writes the `claude` namespace instead of the flat top-level key, using the same host detection as the rest of this feature

**Out of scope:**
- Giving opencode, codex, or any other host their own umbrella key — see ⚠️ Confirm (4). This canvas only adds the `claude` namespace and preserves the flat shape as the fallback for everything else.
- Actually detecting the host or migrating this repo's own live `~/.config/spdd/config.json` — that file lives outside the repo and outside this canvas's artifacts; any such write is a real side effect and is explicitly deferred to a real foreground `AskUserQuestion` at implementation time, never assumed or executed here (see Safeguards → Production rollback).
- Changing `spdd-verify`'s or `spdd-sync`'s own trigger conditions — this feature only touches the model-config section of `spdd-agent`.

---

## Entities

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| Model config file | `~/.config/spdd/config.json` | Existing (schema change) | Currently flat `{"models": {...}}`; gains an optional `claude` namespace per ⚠️ Confirm (2) |
| "Load or bootstrap the model configuration" (Step 1) | `spdd-agent/SKILL.md` | Existing (modified) | Gains a host-detection sub-step before reading/writing the config |
| "Detect subagent support" (Step 2) | `spdd-agent/SKILL.md` | Existing (reference only) | Closest existing precedent for host/capability detection in this codebase; not itself modified by this feature — it detects subagent *capability*, not Claude-Code *identity*, so it cannot be reused verbatim (see ⚠️ Confirm (1)) |
| Config bootstrap/repair evals | `spdd-agent/evals/evals.json` (evals 31–38) | Existing (modified) | Currently assert against the flat schema; need cases for both namespaces plus the migration path |
| Living spec | `spdd/specs/spdd-agent.md` | Existing (updated later) | Not edited by this canvas — `spdd-verify` folds the final Requirements/Entities/Operations/Norms into it once this change is implemented and verified |

---

## Approach

Select the main pattern and briefly justify why:

- [ ] Full CRUD (model + repository + service + controller/handler)
- [ ] Endpoint/handler only (on an existing entity)
- [x] Service/internal logic only (no presentation layer)
- [ ] Async worker / job
- [ ] External service integration — specify: ___
- [ ] UI component / page

**Rationale:**
There is no application code in this repo — `spdd-agent` is a markdown-driven skill whose "logic" is a set of instructions an LLM agent follows, plus a small amount of `Bash` it's allowed to run (`allowed-tools: Read Write Edit Bash AskUserQuestion Agent`). This closest maps to "service/internal logic only": Step 1's instructions change, a possible `Bash`-driven detection check is added, and no new files, endpoints, or UI surfaces are introduced.

---

## Structure

Files to create or modify, with real project paths:

```
spdd-agent/SKILL.md                    # Step 1: add host-detection sub-step, branch config read/write on claude vs. flat namespace
spdd-agent/evals/evals.json            # evals 31-38: update fixtures/assertions for the new namespace; add cases for detection + migration
CLAUDE.md                              # Gotchas: update the "this repo's own ~/.config/spdd/config.json is flat" note once the schema changes (documentation only, no live file write)
AGENTS.md                              # Mirror the same Gotchas edit per the "AGENTS.md mirrors CLAUDE.md" convention
```

---

## Operations

Define each concrete action and its mechanism (instruction step, config read/write, eval case):

| Type | Identifier | Description |
|------|-----------|-------------|
| Step (new) | "Detect Claude Code host" | New sub-step inserted at the start of Step 1, before the existing file-exists check — determines Claude-Code vs. other, per ⚠️ Confirm (1) |
| Step (modified) | "Load or bootstrap the model configuration" (Step 1.1, bootstrap) | Writes to `claude` namespace when detected, flat top-level `models` otherwise |
| Step (modified) | "Load or bootstrap the model configuration" (Step 1.2, existing file) | Reads from `claude` namespace when detected and present; triggers migration path when detected but only flat is present, per ⚠️ Confirm (3) |
| Step (modified) | "Explicit config request" | Same namespace branch as bootstrap/read, so view/change requests resolve consistently |
| Config write | `claude` namespace bootstrap | `{"claude": {"models": {"canvas": ..., ...}}}` (exact shape per ⚠️ Confirm (2)) |
| Config write | Legacy flat fallback | `{"models": {"canvas": ..., ...}}` — unchanged, used whenever Claude Code is not detected |
| Eval case (new/modified) | evals 31–38 | Extend to cover: bootstrap under detected Claude Code, bootstrap under non-Claude-Code host, read of existing nested config, read/migration of existing flat config while Claude Code is detected, explicit view/change request against each namespace |

---

## Norms

Mandatory project conventions for this feature:

- [x] Increment `metadata.version` in `spdd-agent/SKILL.md` on any edit to its instructions — from `spdd/specs/spdd-agent.md` → Norms (existing project spec).
- [x] Mirror any Structure/Conventions/Gotchas edit into both `CLAUDE.md` and `AGENTS.md` — from user's global memory (`feedback_agents-md-mirrors-claude-md.md`).
- [x] Capability-not-identity precedent: per `spdd-agent/SKILL.md`'s own "A note on AskUserQuestion" section, host-specific behavior elsewhere in this skill is gated on what the host can *do* (e.g. subagent mechanism in Step 2), not what it's *named* — flagged as a tension against this feature's literal ask ("detect if I'm using Claude Code") in ⚠️ Confirm (1).
- ⚠️ `spdd/norms.md` does not exist in this project yet, so there are no team-wide global norms to carry over into this canvas beyond the two above (both sourced from existing project docs/memory, not from `spdd/norms.md`).

---

## Safeguards

**Tests to write:**
- [ ] Full happy path: Claude Code detected, nested config already correct, all six values read.
- [ ] Invalid input validation: nested `claude.models` present but missing/empty value for one phase — re-ask/re-fill only that phase, same as today's flat-config repair behavior.
- [ ] Edge cases: see below.

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted test for each one not already covered):**

- Scenario: detection is inconclusive (signal absent, ambiguous, or the detection mechanism itself errors)
  - WHEN Step 1's new detection sub-step cannot confidently determine the host
  - THEN `spdd-agent` falls back to the flat top-level `models` shape — never guesses `claude` on uncertain evidence, since guessing wrong on a *write* would corrupt the file for whichever host is actually running

- Scenario: config file has both a flat `models` key and a `claude` namespace (partially migrated, or hand-edited)
  - WHEN Claude Code is detected and both keys are present
  - THEN Step 1 reads only from the `claude` namespace and leaves the flat key untouched — does not merge or delete it automatically. CONFIRMED — no merge, `claude` takes precedence unconditionally

- Scenario: migration writes to `~/.config/spdd/config.json` while another process holds it open (bootstrap or explicit-config-request racing with a concurrent `spdd-agent` invocation)
  - WHEN two `spdd-agent` invocations both trigger the migration path at roughly the same time
  - THEN out of scope for this canvas — no new concurrency safeguard is added beyond whatever (if any) already exists for the flat-file bootstrap/write path today

- Scenario: user has already hand-edited the file to something that is neither valid flat nor valid nested shape
  - WHEN the JSON parses but matches neither the flat nor the `claude`-namespaced schema
  - THEN treat it the same as today's "missing or empty value" repair path — re-ask only for what's unresolvable, do not overwrite unrelated valid keys

**Production rollback:**
Nothing in this canvas performs a live filesystem write outside its own artifact (this `canvas.md`). Every action with a real side effect — installing/updating the SPDD guard hook, writing or migrating `~/.config/spdd/config.json` (including this repo's own live copy, confirmed flat and all-sonnet as of this canvas), editing `spdd-agent/SKILL.md`/`evals.json`/`CLAUDE.md`/`AGENTS.md` — is deferred to the foreground checkpoint and requires an explicit human confirmation before `spdd-design`/`spdd-implement` executes it. Rollback, if needed post-implementation, is a straightforward revert of the `SKILL.md`/`evals.json`/`CLAUDE.md`/`AGENTS.md` diff plus (if migration already ran on a real machine) restoring the config file's pre-migration flat shape from a backup — ⚠️ Confirm (3) below should settle whether the migration step itself writes such a backup.

---

## Confirmed decisions (formerly open questions)

- **Detection signal — CONFIRMED.** `Bash` checks the `CLAUDECODE` environment variable (e.g. `bash -c 'echo "$CLAUDECODE"'` returning `1`) to determine the current host. If the check errors, returns empty, or `Bash` is unavailable, the host is treated as "not detected" and the flat legacy shape is used. This intentionally generalizes: a future host gets its own equivalent env-var check under the same pattern. Accepted despite the tension with Step 2's capability-not-identity precedent, since distinguishing *which* host is running is unavoidably an identity check.

- **Nested schema shape — CONFIRMED.** `{"claude": {"models": {"canvas": ..., "design": ..., "implement": ..., "verify": ..., "sync": ..., "migrate": ...}}}` — `claude` is a top-level host-namespace key sibling to any future host key, wrapping the same `models` object shape used today.

- **Migration path for an existing flat config — CONFIRMED.** On first Step-1 execution where Claude Code is detected and the file has a flat `models` key but no `claude` key, auto-migrate non-destructively: write the `claude`-nested shape (values copied from the flat key) and leave the original flat key untouched. This remains a config-write action with a real side effect per this skill's own escalation rules — implementation must still gate the actual write behind a real foreground `AskUserQuestion`, per Step 1's existing pattern for side-effect actions; only the *design* of what that write does is confirmed here.

- **Other hosts' umbrella keys — CONFIRMED, out of scope.** Only `claude` is added. Every other host keeps reading/writing the flat top-level `models` key indefinitely, no forward-compatibility guarantee promised. A future host namespace would need its own canvas.
