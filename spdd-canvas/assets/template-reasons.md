# REASONS: [Feature Name]

> Generated on [DATE]. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: This canvas is written in English, regardless of the language of the feature description or conversation.

**Status:** Draft

---

## Requirements

**User story:**
As a [role], I want to [action] so that [business goal].

**Acceptance criteria:**

*(Write each as a WHEN/THEN scenario — concrete enough to become a test. Mark NEW for behavior that doesn't exist yet, MODIFIED for behavior that changes something already in `spdd/specs/`.)*

- **[NEW]** Scenario: ...
  - WHEN ...
  - THEN ...
- **[MODIFIED]** Scenario: ... ⚠️ Confirm: replaces existing behavior in `spdd/specs/<domain>.md` — confirm this is intentional
  - WHEN ...
  - THEN ...

**Out of scope:**
- ...

---

## Entities

List all models/entities/interfaces involved. State whether each is new or existing.

| Name | Path | New / Existing | Notes |
|------|------|----------------|-------|
| `MyEntity` | `src/...` | New | |
| `RelatedEntity` | `src/...` | Existing | Relation: ... |

**Main fields of the new entity:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | string | yes | |
| `status` | enum | yes | ⚠️ Confirm: enum values |

---

## Approach

Select the main pattern and briefly justify why:

- [ ] Full CRUD (model + repository + service + controller/handler)
- [ ] Endpoint/handler only (on an existing entity)
- [ ] Service/internal logic only (no presentation layer)
- [ ] Async worker / job
- [ ] External service integration — specify: ___
- [ ] UI component / page

**Rationale:**
...

---

## Structure

Files to create or modify, with real project paths:

```
[concrete project paths]
```

---

## Operations

Define each concrete action and its mechanism (endpoint, command, event, UI action):

| Type | Identifier | Description |
|------|-----------|-------------|
| `GET` | `/api/resource` | Paginated list |
| `POST` | `/api/resource` | Create |
| `PATCH` | `/api/resource/:id` | Edit |
| `DELETE` | `/api/resource/:id` | Delete |

*(Adapt columns to the stack: HTTP method, CLI command, event name, UI action, etc.)*

---

## Norms

Mandatory project conventions for this feature:

- [ ] [Convention 1 — extracted from CLAUDE.md / AGENTS.md]
- [ ] [Convention 2]
- [ ] [Convention 3]

*(If no CLAUDE.md or AGENTS.md exists, use stack-standard conventions)*

---

## Safeguards

**Tests to write:**
- [ ] Full happy path
- [ ] Invalid input validation
- [ ] Edge cases: ...

**Edge cases to consider (as WHEN/THEN scenarios — `spdd-verify` writes a targeted test for each one not already covered):**

- Scenario: [related entity] does not exist
  - WHEN ...
  - THEN ...
- Scenario: user lacks permissions
  - WHEN ...
  - THEN ...
- ...

**Production rollback:**
...
