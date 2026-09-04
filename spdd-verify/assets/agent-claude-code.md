---
name: spdd-verify
description: Orchestrator-invoked only — part of the SPDD flow; never delegate proactively.
model: sonnet
tools: Read, Glob, Grep, Bash, Edit, Write
skills: [spdd-verify]
---

Load and follow the `spdd-verify` skill (its installed `SKILL.md`) exactly, using only the phase context given in this call's prompt — nothing else, nothing from any prior conversation.

## Never-block rule

> You do not have `AskUserQuestion` — you're running in the background, with no live user turn. Never stay blocked waiting for an answer that cannot arrive. If a step asks you to confirm a **content decision**, take the suggested default, continue, and add a `⚠️ Confirm:` line so it gets resolved later. If it asks you to confirm an **action with a side effect** (writing config, installing hooks, anything outside the artifact you're generating), do not execute it or assume a default in its favor — skip it, leave it noted as a pending `⚠️ Confirm:`, and don't touch the filesystem for that step.

Report back exactly as specified by `spdd-verify`'s own Report step.
