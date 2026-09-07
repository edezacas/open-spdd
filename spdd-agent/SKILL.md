---
name: spdd-agent
description: Builds a new feature end-to-end from a single plain-language description — runs canvas → design → implement → verify automatically, pausing only on required confirmations. On a machine's first run it walks a short onboarding (flow guide + model bootstrap). Use when the user describes a new feature, or asks to build/add/implement something, without naming a specific /spdd-* command. Also handles requests to view or change the per-phase model configuration.
license: Apache-2.0
compatibility: Works with any agent. Subagent isolation requires any host mechanism that can launch a subagent (e.g. Claude Code's `Agent` tool, or opencode's Task tool with a `subagent_type`); per-phase model selection additionally requires that mechanism to accept a per-invocation model override. Claude Code's `Agent` tool does. opencode's Task tool does not — per opencode's own docs, an ad-hoc subagent always runs at the model of the primary agent that invoked it, with no per-call override — but `spdd-agent` can install 4 dedicated opencode agent files (`assets/install-opencode-agents.sh`, offered automatically when missing or stale) with the model pinned per phase in each file's own frontmatter, which opencode's Task tool does honor when invoked by name.
allowed-tools: Read Write Edit Bash AskUserQuestion Agent
metadata:
  author: edezacas
  version: "2.1"
---

## Instructions

### AskUserQuestion and decision transparency

Every foreground step that says "ask via `AskUserQuestion`" means: use the host's structured, blocking question mechanism if it has one (in Claude Code, the `AskUserQuestion` tool); otherwise ask the same question in plain text and wait for the user's reply before continuing. This never applies to background subagents (Step 3), which follow the never-block rule instead.

Whenever this skill resolves a choice on its own — without a blocking question turn — show one short line immediately before acting on it, phrased in the conversation's language (only the bracketed label stays fixed):

```
[automatic decision] <what it decided> — <why>
```

If the first-run onboarding ([first-run.md](assets/first-run.md)) ran earlier in this same run, precede each phase launch (Steps 4, 6, 7, 8) with one short line in the conversation's language saying what the phase does and what will come back — the per-phase one-liners templated in that asset — alongside the `[automatic decision]` lines above, on the first run only.

Reserve `⚠️ Confirm:` — a real, foreground question that blocks — for:

- Business-rule ambiguity the agent cannot resolve on its own.
- Any action with a real side effect: installing the SPDD guard hook, writing configuration, deleting or overwriting an existing file.
- A diff-vs-canvas discrepancy surfaced by `spdd-verify`'s diff-to-canvas check (Step 8 below).

### Step 0 — Classify the request and route the change

Two kinds of input reach this skill:

- **A feature description** ("hay que implementar X", "add support for Y") → proceed to routing (below).
- **A request about the model configuration itself** ("usa spdd-agent para ver/cambiar el modelo de cada fase", "qué modelo usa implement", "cambia verify a sonnet") → go to Step 1, which handles viewing and changing values as part of its normal completeness check, and stop there once it reports the result; do not start the feature flow.

**Routing decision** (feature description path only):

Before starting the canvas phase, analyze the user's description to determine whether this is a **direct route** (trivial change) or **complete route** (full flow):

- **Direct route** (implement without canvas → design → verify): Activates when:
  - The change touches **1–2 files**, is mechanical or of evident scope, **and** there is no business or architectural ambiguity.
  - When in doubt between direct and complete, **always choose complete** — the complete route is the safe default.

- **Complete route** (canvas → design → implement → verify): Activates when:
  - The change touches **3+ files**, requires understanding multiple system parts, **or** there is any business/architectural ambiguity.
  - This is the status quo flow (Steps 1–9 below).

**Direct route execution** (if chosen):

If the direct route is chosen:

1. Display the transparency line: `[automatic decision] Direct route: <reason> → implementing without a canvas.` (where reason briefly explains the decision), phrased in the conversation's language per "Decision transparency" above.
2. Do **not** bootstrap the model configuration (Step 1 below) — direct route does not launch subagents.
3. Implement the changes directly (using Write, Edit, and Bash as needed for this skill).
4. Run the test suite for the affected area via `Bash`. If tests fail, report the failure and do not update the spec — leave the decision to revert or fix to the user.
5. If tests pass, annotate a summary in `spdd/specs/<domain>.md` (create the file or domain section if absent). Use `<domain>` inferred from file paths (e.g., `src/<domain>/...`); fall back to `spdd/specs/general.md` if no clear domain is evident.
6. Stop and report completion — do not proceed to Steps 1–9.

**Complete route execution** (if chosen):

Proceed to Step 1 (bootstrap) and continue through Steps 2–9 as described below.

### Step 1 — Load or bootstrap the model configuration

Config lives at `~/.config/spdd/config.json` — the XDG user-config convention, global and shared across projects, not versioned in any repo, and not tied to any single host (Claude Code, opencode, codex, or any other agent reads and writes the same file).

**Detect Claude Code host.** Before deciding which section of the file to read or write, run `Bash`: `echo "$CLAUDECODE"`. If it prints `1`, the host is Claude Code. If it prints anything else, the command errors, or `Bash` is unavailable, treat the host as "not detected" — never guess `claude` on inconclusive evidence, since a wrong guess on a *write* could corrupt the file for whichever host is actually running. Display the transparency line for this decision, per "Decision transparency" above: `[automatic decision] Claude Code detected — using the claude config namespace.` or `[automatic decision] Claude Code not detected — using the flat config shape.`

This determines the **applicable section**: `claude.models` under Claude Code, the flat top-level `models` key otherwise.

**Completeness check.** Try to read and parse `~/.config/spdd/config.json`:

- If the file doesn't exist → not complete (first-run bootstrap case).
- If it exists but fails to parse as JSON, or is a zero-byte file → not complete (malformed/unparseable case).
- If it parses: inspect only the applicable section — the other section (if present) is never inspected or touched. It's **complete** only if that section has all four keys (`canvas`, `design`, `implement`, `verify`) present as non-empty strings.
- If Claude Code is detected and `claude.models` is missing entirely, but a flat top-level `models` key is present and complete → not complete (this is the migration case, not the fast path).
- If the current request is an **explicit ask to change** one or more phase values (Step 0's config-request path) → not complete, regardless of the checks above. A change always needs the asking mechanics that live in `model-bootstrap.md`, even when the applicable section was already fully valid.

**Fast path.** If complete per the check above: read the four values from the applicable section directly. For the ordinary feature flow, proceed straight to Step 2. For an explicit config request that only wants to *view* the current values, report those four values and stop — do not proceed to Step 2. Either way, `spdd-agent/assets/model-bootstrap.md` is never opened and no `AskUserQuestion` call is made.

**Everything else:** if the classification above was the file-doesn't-exist case (first run), read [first-run.md](assets/first-run.md) and follow it — it hands off to [model-bootstrap.md](assets/model-bootstrap.md)'s "First-run bootstrap" section; every other case (repair, migration, malformed/unparseable, explicit value change) reads [model-bootstrap.md](assets/model-bootstrap.md) directly, exactly as before. Those assets own every `AskUserQuestion` mechanic and every config write for their cases, so nothing here repeats them. Once Step 1 finishes: for the ordinary feature flow, proceed to Step 2; for an explicit config request, report the resulting config and stop — do not proceed to Step 2.

### Step 2 — Detect subagent capability

Once per run (not per phase): does the current host expose a mechanism to launch an isolated subagent — a way to spawn a separate worker and give it a prompt? In Claude Code, the `Agent` tool; in opencode, the Task tool with a `subagent_type`; other hosts may name it differently but the shape is the same.

This is a fact about the host, never inferred at runtime — check the host's own documented capability, not whether a tool call happens to accept an extra field:

- **Claude Code** → mechanism exists and its `Agent` tool takes a per-invocation `model` param → **Isolated mode** (Step 3), model taken from the config loaded in Step 1, passed on every call.
- **opencode** → mechanism exists (the Task tool) but it has no per-invocation model override at all — an ad-hoc subagent always runs at the model of the primary agent that invoked it. Still **Isolated mode** (Step 3), but never pass a `model` field to the Task tool, and never claim per-phase model selection is in effect: every phase runs at whatever model this conversation itself is using.
- **Any other host** → check that host's own documentation for whether its subagent mechanism accepts a per-invocation model field before assuming it does; if it doesn't, treat it the same as opencode above.
- **No subagent mechanism at all** → **Inline mode** (Step 3-alt).

Display the transparency line for this choice once, before the first phase runs — phrased in the conversation's language per "Decision transparency" above: `[automatic decision] Isolated mode with model override — Claude Code's Agent tool accepts a model.` or `[automatic decision] Isolated mode without model override — opencode's Task tool has no per-call model field; every phase runs at this conversation's own model.` or `[automatic decision] Inline mode — the host doesn't expose a subagent mechanism; isolation and per-phase model selection are lost.`

### Step 2b — opencode dedicated-agent check (once per run, regardless of which host is running this session)

opencode has no per-call model override (Step 2 above), so the only way to pin a specific model to a specific phase there is a named agent file with a static `model:` in its frontmatter. This check runs on **any** host — a Claude Code session can prep opencode for later use on the same machine; it only ever touches opencode paths and never affects this session's own dispatch when the current host is Claude Code.

If `~/.config/opencode/` exists on this machine: check whether all four `~/.config/opencode/agents/spdd-<phase>.md` files exist, are well-formed (parseable frontmatter, non-empty body), and each one's `<!-- spdd-agent:model-source=... -->` marker matches config.json's current flat `models` value for that phase. A file that exists but is malformed is treated as absent — never blocks or crashes.

If anything is missing, malformed, or stale: show one transparency line noting the gap, then ask via a real foreground `AskUserQuestion` — a side-effecting action, it writes files — whether to run `spdd-agent/assets/install-opencode-agents.sh` now (`Bash`), "yes" recommended. On acceptance, run it and report what it wrote — or, if it exits non-zero (e.g. the flat `models` key was never bootstrapped because this machine has so far only run `spdd-agent` under Claude Code), report its failure message plainly and never claim the dedicated layer was installed. Either way, the feature flow continues afterward exactly as it would have on decline. On decline, note it stays available to ask again next run, and continue. If `~/.config/opencode/` doesn't exist at all, skip this check entirely — nothing to prepare.

If the current host is opencode and a phase now has (or already had) a well-formed, up-to-date agent file, Step 3 dispatches that phase to it by name instead of ad-hoc (see below).

### Step 3 — Isolated mode: phase invocation contract

Applies when Step 2 selected Isolated mode. For each phase:

- **opencode, with a well-formed and up-to-date `spdd-<phase>.md` from Step 2b:** call the Task tool with `subagent_type: "spdd-<phase>"` — the named agent's own frontmatter carries its model; never pass a `model` field (the Task tool has none). The prompt still carries the phase context (below), but skip restating the never-block rule and report contract — the named agent's own body already carries both, verbatim.
- **Every other case** (Claude Code always; opencode with no well-formed file for this phase; any other host): generic `subagent_type` the host provides for ad-hoc work (in Claude Code, `general-purpose`; in opencode, `general`), and, unconditionally, whenever Step 2 found the mechanism accepts a model override: **`model` set to that phase's value from config.json (Step 1) — every call, no exception.** This is not a conditional step; if the mechanism accepts a model param, pass it, full stop.

A self-contained `prompt` always includes the skill call (below); the named-agent dispatch case skips items 2–3 below, since the agent's own body already carries both, verbatim — every other case includes all three:

1. **The skill call**: instruct the subagent to load the named phase skill (`spdd-canvas`, `spdd-design`, `spdd-implement`, or `spdd-verify`) through its own skill-loading mechanism (e.g. a `Skill` tool) and follow it — or, if it has no such mechanism, to read that skill's installed `SKILL.md` and execute it exactly — together with the exact context listed for it in Steps 4–8 and nothing more, nothing from this conversation's history. When delegating the canvas phase, additionally state that routing was already decided (complete route), so the canvas's applicability guard (its Step 2) is skipped.
2. **The never-block rule**, verbatim:

   > You do not have `AskUserQuestion` — you're running in the background, with no live user turn. Never stay blocked waiting for an answer that cannot arrive. If a step asks you to confirm a **content decision**, take the suggested default, continue, and add a `⚠️ Confirm:` line so it gets resolved later. If it asks you to confirm an **action with a side effect** (writing config, installing hooks, anything outside the artifact you're generating), do not execute it or assume a default in its favor — skip it, leave it noted as a pending `⚠️ Confirm:`, and don't touch the filesystem for that step.

3. **What to report back on completion**: as specified by the phase skill's own Report step (saved/updated path, short summary, pending `⚠️ Confirm:` lines).

Subagent semantics vary by host: the report may come back synchronously as the call's tool result (opencode's Task tool, or Claude Code's foreground `Agent` call) or later as a completion notification (Claude Code's background `Agent`). Either way, treat what returns as the phase's real report — never simulate or predict it — and continue the orchestration immediately once it arrives: the Step 5 checkpoint gate after canvas, the next step after every other phase. Never end the flow after issuing the call.

### Step 3-alt — Inline mode

Applies when Step 2 found no subagent mechanism at all. Invoke `Skill(<phase>)` directly in the current context, with the same context scoping listed for the phase in Steps 4–8. This runs synchronously in the foreground, so `AskUserQuestion` is available for real — the never-block rule doesn't apply, and any `⚠️ Confirm:` the phase raises can be resolved immediately instead of deferred. Orchestration and checkpoints (Steps 4–8) stay the same either way; only isolation and per-phase model are lost. When the invoked phase finishes, return to this skill's next step (5, 6, 7, or 8) — the phase's Report step ends the phase, not this orchestration.

### Step 4 — Canvas phase

Launch the `canvas` phase, per Step 2's decision (Isolated or Inline). Context: the user's feature description, verbatim — it isn't in any file yet.

### Step 5 — Checkpoint gate: canvas

Once the canvas is saved, if it contains any `⚠️ Confirm:` lines, do not advance. Resolve **every one** with a real `AskUserQuestion` call in the foreground — split across as many calls of up to 4 questions as needed, never skipped for volume. Present the phase's default as the recommended option, never as an assumed answer. Update `canvas.md` with the confirmed values and set `**Status:** Confirmed`.

If the canvas has zero `⚠️ Confirm:` lines, set `**Status:** Confirmed` and skip straight to Step 6.

### Step 6 — Design phase

Launch the `design` phase, per Step 2's decision. Context: the path to the now-confirmed `canvas.md`. Apply the same checkpoint gate as Step 5 to every `⚠️ Confirm:` line across the resulting plan(s) before advancing.

### Step 7 — Implement phase, per plan

Order the plans by their `Depends on:` field (topological order — a plan never launches before every plan it depends on has reached `Status: Implemented`, matching `spdd-implement` Step 3's dependency check). For each plan in that order, launch the `implement` phase, per Step 2's decision. Context: the path to that one plan only — not the other plans, not the canvas beyond what `spdd-implement` itself reads.

### Step 8 — Verify phase

Once every plan for the change is `Status: Implemented`, launch the `verify` phase, per Step 2's decision, per plan (or once, if the change was never split). Context: the path to the plan (or canvas) being verified.

If a verify run reports a non-trivial divergence (not a cosmetic gap), reopen the relevant checkpoint: bring the finding to the user in the foreground via `AskUserQuestion`, and if it requires touching the plan or canvas, loop back to the appropriate step (5, 6, or 7) instead of forcing the divergence closed silently.

### Step 9 — Final report

Report, in one summary: the canvas path, the plan(s) produced and their dependency order, what was implemented, what got folded into `spdd/specs/` and archived, and — for each checkpoint — what was asked and what the user decided.
