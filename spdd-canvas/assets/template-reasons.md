# REASONS: [Feature Name]

> Generated on [DATE]. Review lines marked ⚠️ before generating code.
> Golden rule: if something breaks during development, fix this canvas first, then the code.
> Language: translate all section headings, labels, placeholder text, and body content to the user's configured language (see Step 1.5 in canvas/SKILL.md).

**Status:** Draft

---

## Requirements

**User story:**
As a [role], I want to [action] so that [business goal].

**Acceptance criteria:**
- [ ] ...
- [ ] ...

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

- [ ] [Convention 1 — extracted from CLAUDE.md]
- [ ] [Convention 2]
- [ ] [Convention 3]

*(If no CLAUDE.md exists, use stack-standard conventions)*

---

## Safeguards

**Tests to write:**
- [ ] Full happy path
- [ ] Invalid input validation
- [ ] Edge cases: ...

**Edge cases to consider:**
- What happens if [related entity] does not exist?
- What happens if the user lacks permissions?
- ...

**Production rollback:**
...
