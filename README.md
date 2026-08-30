# open-spdd

Structured Prompt-Driven Development (SPDD) skills in the [agentskills.io](https://agentskills.io) format. Work with Claude Code, OpenAI Codex, VS Code Copilot, and any compatible agent.

## Why

AI coding agents are good at writing code and bad at remembering what the system is *supposed* to do. Without a stable source of truth, every session re-derives intent from scratch, specs live only in chat history, and "add a small feature" can quietly change behavior nobody asked to change.

SPDD fixes this by making the agent write down its understanding of a feature — as concrete `WHEN/THEN` scenarios, not prose — *before* touching code, and by keeping that understanding around after the code ships:

- **Ambiguity surfaces before code, not after.** Every canvas marks unclear decisions with `⚠️ Confirm:` instead of guessing silently — you review a handful of bullet points, not a diff you have to reverse-engineer.
- **A living spec, not stale docs.** `spdd-verify` folds every shipped feature into `spdd/specs/<domain>.md`. It's what the next canvas reads to avoid contradicting what's already there, and what `spdd-sync` keeps honest when code gets refactored outside the flow.
- **Plans can run in parallel.** `spdd-design` splits independent work into separate plans with explicit `Depends on:` and `Shared touchpoints:` — safe to hand to different agents or people without stepping on each other.
- **Automation that still asks.** `spdd-agent` runs the whole canvas → design → implement → verify flow from one plain-language description, but every `⚠️ Confirm:` and every side-effecting action (installing a hook, writing config) still pauses for a real decision — it speeds up the boring parts, not the judgment calls. For a trivial, unambiguous 1–2 file change it skips the ceremony and implements directly instead, always saying so first.
- **Every autonomous call is visible.** Whenever `spdd-agent` resolves something on its own — routing a change direct instead of through the full flow, picking isolated vs. inline subagent mode — it prints a one-line "automatic decision: what, and why" before acting, so a wrong call is easy to catch and correct instead of silently baked in.
- **No vendor lock-in.** Every skill is a plain `SKILL.md` in the agentskills.io format — no Claude Code-only agent files.

## Skills

| Skill | Trigger | Description |
|---|---|---|
| `spdd-agent` | Auto (plain feature description) or `/spdd-agent` | Orchestrates canvas → design → implement → verify from a single feature description — or routes trivial, unambiguous changes straight to implementation — with a checkpoint on every `⚠️ Confirm:` |
| `spdd-canvas` | `/spdd-canvas` | Generates a REASONS canvas before writing code, after checking whether the domain's living spec is stale against recent commits |
| `spdd-design` | `/spdd-design` | Splits a canvas into one or more independent implementation plans |
| `spdd-implement` | `/spdd-implement` | Implements a feature from a plan produced by `spdd-design` |
| `spdd-verify` | `/spdd-verify` | Checks the implemented diff against the canvas's Operations/Norms, tests edge cases, folds it into the living spec, and archives it |
| `spdd-sync` | `/spdd-sync` | Syncs a behavior-preserving code refactor back into the living spec |
| `spdd-migrate` | `/spdd-migrate` | One-time migration from the old flat `docs/prompts/` layout to `spdd/` |

## Installation

```bash
npx skills add edezacas/open-spdd
```

Restart Claude Code to pick up the new skills.

<details>
<summary>Manual installation</summary>

```bash
git clone git@github.com:edezacas/open-spdd.git ~/projects/open-spdd
mkdir -p ~/.claude/skills
ln -s ~/projects/open-spdd/spdd-agent ~/.claude/skills/spdd-agent
ln -s ~/projects/open-spdd/spdd-canvas ~/.claude/skills/spdd-canvas
ln -s ~/projects/open-spdd/spdd-design ~/.claude/skills/spdd-design
ln -s ~/projects/open-spdd/spdd-implement ~/.claude/skills/spdd-implement
ln -s ~/projects/open-spdd/spdd-verify ~/.claude/skills/spdd-verify
ln -s ~/projects/open-spdd/spdd-sync ~/.claude/skills/spdd-sync
ln -s ~/projects/open-spdd/spdd-migrate ~/.claude/skills/spdd-migrate
```

</details>

## Workflow

> Canvas format based on [Structured Prompt-Driven Development](https://martinfowler.com/articles/structured-prompt-driven/) by Martin Fowler. Folder lifecycle (`specs/` → `changes/` → `archive/`) and `WHEN/THEN` requirement scenarios inspired by [OpenSpec](https://github.com/Fission-AI/OpenSpec).

```mermaid
flowchart TD
    canvas["/spdd-canvas<br/><small>generates canvas.md in spdd/changes/</small>"]
    design["/spdd-design<br/><small>decides: single plan or split</small>"]
    plan[("plans/*.md")]
    implement["/spdd-implement<br/><small>implements from a plan, step by step</small>"]
    verify["/spdd-verify<br/><small>tests Safeguards and Norms</small>"]
    specs[("spdd/specs/&lt;domain&gt;.md<br/><small>living spec</small>")]
    archive["spdd/archive/"]
    sync["/spdd-sync<br/><small>refactor outside the SPDD flow</small>"]

    canvas --> design --> plan --> implement
    implement -- diverges --> plan
    implement --> verify
    verify -- fully verified --> specs
    verify --> archive
    specs -.-> sync -. updates .-> specs
```

Describe the feature in plain language and `spdd-agent` runs the whole flow below for you, pausing on every `⚠️ Confirm:` so you can decide instead of it guessing:

```
hay que implementar la sincronización de actividades con Google Calendar
```

Or drive each phase yourself — `spdd-agent` doesn't replace the slash commands, it's an additional way in:

```
/spdd-canvas magic link authentication
```

Generates a REASONS canvas at `spdd/changes/SPDD-YYYY-MM-DD-HHMM-slug/canvas.md`, after checking `spdd/specs/` for existing related behavior and warning if that domain's spec looks stale against more recent commits. Once reviewed, run:

```
/spdd-design
```

This is a required step — `spdd-implement` never implements directly from the canvas. `spdd-design` decides internally whether the canvas's Operations are cleanly separable and need splitting into several independent plans under `plans/` (each with its own `Depends on:` and `Shared touchpoints:`, useful when you plan to hand different plans to different agents), or whether the whole canvas is simple enough to stay as a single plan. Either way, it always produces at least one plan.

```
/spdd-implement
```

Reads the canvas and the chosen plan, checks for unresolved `⚠️ Confirm:` items and unmet plan dependencies, implements step by step, and updates the canvas or plan if anything diverges. Stops and asks you to run `/spdd-design` first if no plan exists yet.

```
/spdd-verify
```

Checks every Operation is implemented, every Norm followed, and writes targeted tests for any Safeguards edge case not already covered — including a diff-to-canvas check that stops and shows you the gap if the actual code diff touches something the canvas never mentioned, or an Operation has no code behind it. Once everything for a change is verified, folds it into `spdd/specs/<domain>.md` and moves it to `spdd/archive/`.

Separately, whenever code that already has a spec gets refactored **outside** this flow (a rename, an extracted constant — no behavior change):

```
/spdd-sync
```

Compares the current code against `spdd/specs/<domain>.md` and updates Entities/Structure/Operations/Norms to match. It never touches the `WHEN/THEN` Requirements on its own — if the diff looks like it changes behavior, it stops and tells you to use `/spdd-canvas` instead.

> **Document language:** every document these skills write (`canvas.md`, `plan-*.md`, `spdd/specs/<domain>.md`) is always generated in English, regardless of the language of your feature description or conversation — it keeps downstream reasoning cheaper for every skill that later reads them as context. Conversational replies to you still follow your own language settings; this only affects what gets persisted to disk. It's forward-only — documents written before you updated to this version aren't retroactively translated.

> **Global norms:** create `spdd/norms.md` in your project root (see `spdd-canvas/assets/template-norms.md` for a starting template) to declare team-wide, non-negotiable rules — architecture, security, code conventions, decisions that shouldn't be reopened canvas by canvas. `spdd-canvas` always reads it and carries its rules into every new canvas as starting Norms/Safeguards; `spdd-verify` checks the implemented diff against it, not just against the canvas at hand. This file is the team's responsibility to keep current — no skill creates or edits it, only reads it.

> **Migrating from `docs/prompts/`:** if you installed an earlier version of these skills, run `/spdd-migrate` once in that project. It moves canvases from `docs/prompts/SPDD-*.md` into `spdd/changes/SPDD-.../canvas.md`, rewrites Acceptance Criteria/Safeguards into `WHEN/THEN`, keeps each canvas's original `Status` (an old `Implemented` canvas stays `Implemented` — run `/spdd-verify` on it whenever you want it folded into `spdd/specs/`), and updates the guard hook to the new path. It's non-destructive and idempotent: the original files are left in place unless you confirm deletion, and running it again skips whatever was already migrated.

## Other agents

Skills follow the agentskills.io format (`SKILL.md` + standard frontmatter). Place or symlink skill folders into `.agents/skills/` and any compatible agent discovers them automatically. For agents without native support (Cursor, Windsurf), paste the `SKILL.md` contents into the agent's rules file.

## License

Code in this repository is licensed under [Apache-2.0](LICENSE)
