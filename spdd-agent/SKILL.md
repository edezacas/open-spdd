---
name: spdd-agent
description: Builds a new feature end-to-end from a single plain-language description — runs canvas → design → implement → verify automatically, pausing only on required confirmations. Use when the user describes a new feature, or asks to build/add/implement something, without naming a specific /spdd-* command. Also handles requests to view or change the per-phase model configuration.
license: Apache-2.0
compatibility: Works with any agent. Per-phase model selection and subagent isolation require a host that can launch subagents with a model override (e.g. Claude Code's `Agent` tool, or opencode's Task tool with an `agent`/`model` field).
allowed-tools: Read Write Edit Bash AskUserQuestion Agent
metadata:
  author: edezacas
  version: "1.12"
---

## Instructions

### AskUserQuestion and decision transparency

Every foreground step that says "ask via `AskUserQuestion`" means: use the host's structured, blocking question mechanism if it has one (in Claude Code, the `AskUserQuestion` tool); otherwise ask the same question in plain text and wait for the user's reply before continuing. This never applies to background subagents (Step 3), which follow the never-block rule instead.

Whenever this skill resolves a choice on its own — without a blocking question turn — show one short line immediately before acting on it, phrased in the conversation's language (only the bracketed label stays fixed):

```
[automatic decision] <what it decided> — <why>
```

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
- If it parses: inspect only the applicable section — the other section (if present) is never inspected or touched. It's **complete** only if that section has all six keys (`canvas`, `design`, `implement`, `verify`, `sync`, `migrate`) present as non-empty strings.
- If Claude Code is detected and `claude.models` is missing entirely, but a flat top-level `models` key is present and complete → not complete (this is the migration case, not the fast path).
- If the current request is an **explicit ask to change** one or more phase values (Step 0's config-request path) → not complete, regardless of the checks above. A change always needs the asking mechanics that live in `model-bootstrap.md`, even when the applicable section was already fully valid.

**Fast path.** If complete per the check above: read the six values from the applicable section directly. For the ordinary feature flow, proceed straight to Step 2. For an explicit config request that only wants to *view* the current values, report those six values and stop — do not proceed to Step 2. Either way, `spdd-agent/assets/model-bootstrap.md` is never opened and no `AskUserQuestion` call is made.

**Everything else:** read [model-bootstrap.md](assets/model-bootstrap.md) and follow the flow documented there for the specific case (first-run bootstrap, repair, migration, malformed/unparseable, or explicit value change) — it owns every `AskUserQuestion` mechanic and every config write for these cases, so nothing here repeats it. Once it finishes: for the ordinary feature flow, proceed to Step 2; for an explicit config request, report the resulting config and stop — do not proceed to Step 2.

### Step 2 — Detect subagent support

Check whether the current host exposes a mechanism to launch an isolated subagent with a model override — in Claude Code, the `Agent` tool (`subagent_type` + `model`); in opencode, the Task tool with an `agent`/`model` field; other hosts may name this differently but the shape is the same: spawn an isolated worker, pick its model, give it a prompt. If such a mechanism exists, use **Isolated mode** (Step 3). If it doesn't, use **Inline mode** (Step 3-alt).

Display the transparency line for this choice before Step 3/3-alt runs — phrased in the conversation's language per "Decision transparency" above: `[automatic decision] Isolated mode — the host exposes a subagent mechanism with model override.` or `[automatic decision] Inline mode — the host doesn't expose an isolatable subagent mechanism; per-phase model selection is lost.`

### Step 3 — Isolated mode: phase invocation contract

For each phase, build one subagent call: generic `subagent_type` the host provides for ad-hoc work (in Claude Code, `general-purpose`), `model` from the config loaded in Step 1, and a self-contained `prompt`. The `prompt` always includes, in this order:

1. **The skill call**, naming the phase skill (`spdd-canvas`, `spdd-design`, `spdd-implement`, or `spdd-verify`) and the exact context listed for it in Steps 4–8 — nothing more, nothing from this conversation's history. When delegating the canvas phase, additionally state that routing was already decided (complete route), so the canvas's applicability guard (its Step 2) is skipped.
2. **The never-block rule**, verbatim:

   > You do not have `AskUserQuestion` — you're running in the background, with no live user turn. Never stay blocked waiting for an answer that cannot arrive. If a step asks you to confirm a **content decision**, take the suggested default, continue, and add a `⚠️ Confirm:` line so it gets resolved later. If it asks you to confirm an **action with a side effect** (writing config, installing hooks, anything outside the artifact you're generating), do not execute it or assume a default in its favor — skip it, leave it noted as a pending `⚠️ Confirm:`, and don't touch the filesystem for that step.

3. **What to report back on completion**: as specified by the phase skill's own Report step (saved/updated path, short summary, pending `⚠️ Confirm:` lines).

Each subagent call is asynchronous: this skill's turn ends when it's issued, and resumes on the completion notification. Do not simulate or predict a subagent's result — wait for the real one.

### Step 3-alt — Inline mode

If Step 2 found no subagent mechanism: invoke `Skill(<phase>)` directly in the current context, with the same context scoping listed for the phase in Steps 4–8. This runs synchronously in the foreground, so `AskUserQuestion` is available for real — the never-block rule doesn't apply, and any `⚠️ Confirm:` the phase raises can be resolved immediately instead of deferred. Orchestration and checkpoints (Steps 4–8) stay the same either way; only isolation and per-phase model are lost.

### Step 4 — Canvas phase

Launch (or run inline) the `canvas` phase. Context: the user's feature description, verbatim — it isn't in any file yet.

### Step 5 — Checkpoint gate: canvas

Once the canvas is saved, if it contains any `⚠️ Confirm:` lines, do not advance. Resolve **every one** with a real `AskUserQuestion` call in the foreground — split across as many calls of up to 4 questions as needed, never skipped for volume. Present the phase's default as the recommended option, never as an assumed answer. Update `canvas.md` with the confirmed values and set `**Status:** Confirmed`.

If the canvas has zero `⚠️ Confirm:` lines, set `**Status:** Confirmed` and skip straight to Step 6.

### Step 6 — Design phase

Launch (or run inline) the `design` phase. Context: the path to the now-confirmed `canvas.md`. Apply the same checkpoint gate as Step 5 to every `⚠️ Confirm:` line across the resulting plan(s) before advancing.

### Step 7 — Implement phase, per plan

Order the plans by their `Depends on:` field (topological order — a plan never launches before every plan it depends on has reached `Status: Implemented`, matching `spdd-implement` Step 3's dependency check). For each plan in that order, launch (or run inline) the `implement` phase. Context: the path to that one plan only — not the other plans, not the canvas beyond what `spdd-implement` itself reads.

### Step 8 — Verify phase

Once every plan for the change is `Status: Implemented`, launch (or run inline) the `verify` phase per plan (or once, if the change was never split). Context: the path to the plan (or canvas) being verified.

If a verify run reports a non-trivial divergence (not a cosmetic gap), reopen the relevant checkpoint: bring the finding to the user in the foreground via `AskUserQuestion`, and if it requires touching the plan or canvas, loop back to the appropriate step (5, 6, or 7) instead of forcing the divergence closed silently.

### Step 9 — Final report

Report, in one summary: the canvas path, the plan(s) produced and their dependency order, what was implemented, what got folded into `spdd/specs/` and archived, and — for each checkpoint — what was asked and what the user decided.
