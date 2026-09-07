---
name: spdd-agent
description: Builds a new feature end-to-end from a single plain-language description — runs canvas → design → implement → verify automatically, pausing only on required confirmations. On a machine's first run it walks a short onboarding (flow guide + model bootstrap). Use when the user describes a new feature, or asks to build/add/implement something, without naming a specific /spdd-* command. Also handles requests to view or change the per-phase model configuration.
license: Apache-2.0
compatibility: Works with any agent. Subagent isolation requires any host mechanism that can launch a subagent (e.g. Claude Code's `Agent` tool, or opencode's Task tool with a `subagent_type`); per-phase model selection additionally requires that mechanism to accept a per-invocation model override. Claude Code's `Agent` tool does. opencode's Task tool does not — per opencode's own docs, an ad-hoc subagent always runs at the model of the primary agent that invoked it, with no per-call override — but `spdd-agent` can install 4 dedicated opencode agent files (`assets/install-opencode-agents.sh`, offered automatically when missing or stale) with the model pinned per phase in each file's own frontmatter, which opencode's Task tool does honor when invoked by name.
allowed-tools: Read Write Edit Bash AskUserQuestion Agent
metadata:
  author: edezacas
  version: "2.2"
---

## Instructions

### AskUserQuestion and decision transparency

"Ask via `AskUserQuestion`" (any foreground step) means the host's structured blocking question mechanism (Claude Code: the `AskUserQuestion` tool), or plain text + wait for reply if the host has none. Never applies to background subagents (Step 3) — they follow the never-block rule instead.

Resolving a choice on your own, without a blocking question → show one short line first, in the conversation's language (bracketed label fixed):

```
[automatic decision] <what it decided> — <why>
```

First-run onboarding ([first-run.md](assets/first-run.md)) ran earlier this run → precede each phase launch (Steps 4, 6, 7, 8) with one short line, in the conversation's language, on what the phase does and what comes back — the per-phase one-liners templated in that asset — alongside the `[automatic decision]` lines above. First run only.

Reserve `⚠️ Confirm:` — a real, foreground question that blocks — for:

- Business-rule ambiguity the agent can't resolve alone.
- Any action with a real side effect: installing the SPDD guard hook, writing configuration, deleting or overwriting a file.
- A diff-vs-canvas discrepancy from `spdd-verify`'s diff-to-canvas check (Step 8 below).

### Step 0 — Classify the request and route the change

Two kinds of input reach this skill:

- **A feature description** ("hay que implementar X", "add support for Y") → proceed to routing (below).
- **A request about the model configuration itself** ("usa spdd-agent para ver/cambiar el modelo de cada fase", "qué modelo usa implement", "cambia verify a sonnet") → go to Step 1, which handles viewing/changing values as part of its completeness check, stop once it reports the result. Don't start the feature flow.

**Routing decision** (feature description path only): before starting the canvas phase, decide direct route (trivial change) vs. complete route (full flow):

- **Direct route** (implement without canvas → design → verify): touches 1–2 files, mechanical or evident scope, **and** no business/architectural ambiguity. When in doubt → always choose complete, the safe default.
- **Complete route** (canvas → design → implement → verify): touches 3+ files, requires understanding multiple system parts, **or** any business/architectural ambiguity. Status quo flow (Steps 1–9).

**Direct route execution:**

1. Display the transparency line: `[automatic decision] Direct route: <reason> → implementing without a canvas.` (reason briefly explains the decision), per "Decision transparency" above.
2. Don't bootstrap the model configuration (Step 1) — direct route launches no subagents.
3. Implement the changes directly (`Write`, `Edit`, `Bash`).
4. Run the test suite for the affected area via `Bash`. Tests fail → report the failure, don't update the spec, leave revert-or-fix to the user.
5. Tests pass → annotate a summary in `spdd/specs/<domain>.md` (create the file/domain section if absent). `<domain>` from file paths (e.g., `src/<domain>/...`); fall back to `spdd/specs/general.md` if unclear.
6. Stop and report completion — don't proceed to Steps 1–9.

**Complete route execution:** proceed to Step 1 and continue through Steps 2–9.

### Step 1 — Load or bootstrap the model configuration

Config lives at `~/.config/spdd/config.json` — XDG user-config convention, global across projects, not versioned in any repo, not tied to a single host (Claude Code, opencode, codex, or any other agent reads/writes the same file).

**Detect Claude Code host.** Before reading or writing any section, run `Bash`: `echo "$CLAUDECODE"`.

- Prints `1` → host is Claude Code.
- Prints anything else, errors, or `Bash` unavailable → "not detected". Never guess `claude` on inconclusive evidence — a wrong guess on a *write* could corrupt the file for whichever host is actually running.

Display the transparency line per "Decision transparency" above: `[automatic decision] Claude Code detected — using the claude config namespace.` or `[automatic decision] Claude Code not detected — using the flat config shape.`

This sets the **applicable section**: `claude.models` under Claude Code, the flat top-level `models` key otherwise.

**Completeness check.** Read and parse `~/.config/spdd/config.json`:

- File doesn't exist → not complete (first-run bootstrap case).
- Exists but fails to parse, or zero-byte → not complete (malformed/unparseable case).
- Parses → inspect only the applicable section (never touch the other one). Complete only if it has all four keys (`canvas`, `design`, `implement`, `verify`) as non-empty strings.
- Claude Code detected, `claude.models` missing entirely, but a complete flat top-level `models` key exists → not complete (migration case, not the fast path).
- Current request is an **explicit ask to change** one or more phase values (Step 0's config-request path) → not complete, regardless of the above. A change always needs `model-bootstrap.md`'s asking mechanics, even over an already-valid section.

**Fast path.** Complete per the check above → read the four values from the applicable section directly.

- Ordinary feature flow → proceed straight to Step 2.
- Explicit config request that only wants to *view* current values → report those four values, stop, don't proceed to Step 2.

Either way, `model-bootstrap.md` is never opened, no `AskUserQuestion` call is made.

**Everything else:**

- File-doesn't-exist case (first run) → read [first-run.md](assets/first-run.md) and follow it — hands off to [model-bootstrap.md](assets/model-bootstrap.md)'s "First-run bootstrap" section.
- Every other case (repair, migration, malformed/unparseable, explicit value change) → read [model-bootstrap.md](assets/model-bootstrap.md) directly. Those assets own every `AskUserQuestion` mechanic and config write for their cases — nothing here repeats them.

Once Step 1 finishes: ordinary feature flow → proceed to Step 2. Explicit config request → report the resulting config, stop, don't proceed to Step 2.

### Step 2 — Detect subagent capability

Once per run (not per phase): does the host expose a mechanism to launch an isolated subagent — spawn a separate worker with a prompt? Claude Code: the `Agent` tool. opencode: the Task tool with `subagent_type`. Other hosts may name it differently, same shape.

A fact about the host, never inferred at runtime — check its documented capability, not whether a tool call happens to accept an extra field:

- **Claude Code** → mechanism exists, `Agent` tool takes a per-invocation `model` param → **Isolated mode** (Step 3), model from Step 1's config, passed on every call.
- **opencode** → mechanism exists (Task tool), no per-invocation model override — an ad-hoc subagent always runs at the primary agent's model. Still **Isolated mode** (Step 3), but never pass `model` to the Task tool, never claim per-phase model selection is in effect: every phase runs at this conversation's own model.
- **Any other host** → check its documentation for a per-invocation model field before assuming one; none found → treat like opencode above.
- **No subagent mechanism at all** → **Inline mode** (Step 3-alt).

Display the transparency line once, before the first phase runs, per "Decision transparency" above: `[automatic decision] Isolated mode with model override — Claude Code's Agent tool accepts a model.` or `[automatic decision] Isolated mode without model override — opencode's Task tool has no per-call model field; every phase runs at this conversation's own model.` or `[automatic decision] Inline mode — the host doesn't expose a subagent mechanism; isolation and per-phase model selection are lost.`

### Step 2b — opencode dedicated-agent check (once per run, on any host)

opencode has no per-call model override (Step 2), so pinning a model to a phase there needs a named agent file with a static `model:` in its frontmatter. Runs on **any** host — a Claude Code session can prep opencode for later use on the same machine; only ever touches opencode paths, never affects this session's own dispatch under Claude Code.

`~/.config/opencode/` doesn't exist → skip entirely, nothing to prepare.

`~/.config/opencode/` exists → check all four `~/.config/opencode/agents/spdd-<phase>.md` files: exist, well-formed (parseable frontmatter, non-empty body), and each `<!-- spdd-agent:model-source=... -->` marker matches config.json's current flat `models` value for that phase. Malformed file → treated as absent, never blocks or crashes.

Anything missing, malformed, or stale:

- Show one transparency line noting the gap.
- Ask via a real foreground `AskUserQuestion` — writes files, a side effect — whether to run `spdd-agent/assets/install-opencode-agents.sh` now (`Bash`); "yes" recommended.
- Accepted → run it, report what it wrote. Exits non-zero (e.g. flat `models` never bootstrapped because this machine has so far only run `spdd-agent` under Claude Code) → report the failure plainly, never claim the dedicated layer was installed. Either way, the feature flow continues as it would on decline.
- Declined → note it stays available to ask again next run, continue.

Current host is opencode, a phase has (or now has) a well-formed, up-to-date agent file → Step 3 dispatches that phase to it by name instead of ad-hoc.

### Step 3 — Isolated mode: phase invocation contract

Applies when Step 2 selected Isolated mode. For each phase:

- **opencode, well-formed and up-to-date `spdd-<phase>.md` from Step 2b:** call the Task tool with `subagent_type: "spdd-<phase>"` — its frontmatter carries the model; never pass a `model` field (Task tool has none). Prompt still carries the phase context below, but skip restating the never-block rule and report contract — the named agent's own body already carries both, verbatim.
- **Every other case** (Claude Code always; opencode with no well-formed file for this phase; any other host): generic `subagent_type` for ad-hoc work (Claude Code: `general-purpose`; opencode: `general`). Whenever Step 2 found the mechanism accepts a model override: **`model` set to that phase's value from config.json (Step 1) — every call, no exception.** Not conditional — if the mechanism accepts a model param, pass it, full stop.

A self-contained `prompt` always includes item 1 below; the named-agent dispatch case skips items 2–3 (the agent's own body already carries both verbatim) — every other case includes all three:

1. **The skill call**: instruct the subagent to load the named phase skill (`spdd-canvas`, `spdd-design`, `spdd-implement`, or `spdd-verify`) through its own skill-loading mechanism (e.g. a `Skill` tool) and follow it — or, with no such mechanism, read that skill's installed `SKILL.md` and execute it exactly — with the exact context listed for it in Steps 4–8 and nothing more, nothing from this conversation's history. Delegating the canvas phase → also state routing was already decided (complete route), so the canvas's applicability guard (its Step 2) is skipped.
2. **The never-block rule**, verbatim:

   > You do not have `AskUserQuestion` — you're running in the background, with no live user turn. Never stay blocked waiting for an answer that cannot arrive. If a step asks you to confirm a **content decision**, take the suggested default, continue, and add a `⚠️ Confirm:` line so it gets resolved later. If it asks you to confirm an **action with a side effect** (writing config, installing hooks, anything outside the artifact you're generating), do not execute it or assume a default in its favor — skip it, leave it noted as a pending `⚠️ Confirm:`, and don't touch the filesystem for that step.

3. **What to report back on completion**: per the phase skill's own Report step (saved/updated path, short summary, pending `⚠️ Confirm:` lines).

Subagent semantics vary by host — the report may return synchronously (opencode's Task tool, or Claude Code's foreground `Agent` call) or later as a completion notification (Claude Code's background `Agent`). Either way, treat what returns as the phase's real report — never simulate or predict it — and continue the orchestration immediately once it arrives: the Step 5 checkpoint gate after canvas, the next step after every other phase. Never end the flow after issuing the call.

### Step 3-alt — Inline mode

Applies when Step 2 found no subagent mechanism at all. Invoke `Skill(<phase>)` directly in the current context, same context scoping as Steps 4–8. Runs synchronously in the foreground — `AskUserQuestion` is available for real, the never-block rule doesn't apply, any `⚠️ Confirm:` the phase raises can be resolved immediately instead of deferred. Orchestration and checkpoints (Steps 4–8) stay the same; only isolation and per-phase model are lost. Phase finishes → return to this skill's next step (5, 6, 7, or 8) — the phase's own Report step ends the phase, not this orchestration.

### Step 4 — Canvas phase

Launch the `canvas` phase, per Step 2's decision. Context: the user's feature description, verbatim — it isn't in any file yet.

### Step 5 — Checkpoint gate: canvas

Canvas saved, contains any `⚠️ Confirm:` lines → don't advance. Resolve **every one** with a real `AskUserQuestion` call in the foreground — split across as many calls of up to 4 questions as needed, never skipped for volume. Present the phase's default as the recommended option, never as an assumed answer. Update `canvas.md` with the confirmed values, set `**Status:** Confirmed`.

Zero `⚠️ Confirm:` lines → set `**Status:** Confirmed`, skip straight to Step 6.

### Step 6 — Design phase

Launch the `design` phase, per Step 2's decision. Context: the path to the now-confirmed `canvas.md`. Apply Step 5's checkpoint gate to every `⚠️ Confirm:` line across the resulting plan(s) before advancing.

### Step 7 — Implement phase, per plan

Order the plans by their `Depends on:` field — topological order, a plan never launches before every plan it depends on reaches `Status: Implemented` (matches `spdd-implement` Step 3's dependency check). For each plan in that order, launch the `implement` phase, per Step 2's decision. Context: the path to that one plan only — not the other plans, not the canvas beyond what `spdd-implement` itself reads.

### Step 8 — Verify phase

Every plan for the change reaches `Status: Implemented` → launch the `verify` phase, per Step 2's decision, per plan (or once, if the change was never split). Context: the path to the plan (or canvas) being verified.

Verify run reports a non-trivial divergence (not a cosmetic gap) → reopen the relevant checkpoint: bring the finding to the user in the foreground via `AskUserQuestion`. Requires touching the plan or canvas → loop back to the appropriate step (5, 6, or 7) instead of forcing the divergence closed silently.

### Step 9 — Final report

Report, in one summary: the canvas path, the plan(s) produced and their dependency order, what was implemented, what got folded into `spdd/specs/` and archived, and — for each checkpoint — what was asked and what the user decided.
