# Plan: notas defensivas de idioma en spdd-verify y spdd-sync

> Parte del canvas en [../canvas.md](../canvas.md) — Requirements, Norms y Safeguards viven ahí y también aplican a este plan; no se duplican aquí. `spdd-implement` y `spdd-verify` siempre leen ambos archivos juntos.
> Language: traducir todos los encabezados de sección, etiquetas y contenido del cuerpo al idioma detectado del usuario.

**Status:** Verified
> Implemented: 2026-08-30
> Verified: 2026-08-30

**Depends on:** none
**Shared touchpoints:** none

---

## Operations

Subconjunto de las Operations del canvas que pertenecen a este plan (copiado verbatim de la tabla Operations de `canvas.md`):

| Type | Identifier | Description |
|------|-----------|-------------|
| Note | Nota defensiva de idioma en `spdd-design`, `spdd-verify`, `spdd-sync` | Recuerda, en el punto donde cada skill redacta prosa nueva propia (no copiada del canvas/plan de origen), que esa prosa también debe quedar en inglés |

*(Nota: la fila "Note" del canvas cubre tres skills; este plan solo implementa la parte de `spdd-verify/SKILL.md` y `spdd-sync/SKILL.md` — la parte de `spdd-design` vive en `plan-03-spdd-design.md`.)*

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Nota defensiva de idioma (nueva) — `spdd-verify/SKILL.md` — cerca del Step "Fold back and archive" y del Step "Diff-to-canvas check"
- Nota defensiva de idioma (nueva) — `spdd-sync/SKILL.md` — cerca del Step "Update the spec"

**Structure — files to create or modify:**

```
spdd-verify/SKILL.md                  (nueva nota defensiva de idioma cerca de los Steps "Diff-to-canvas check" y "Fold back and archive"; incrementar metadata.version)
spdd-sync/SKILL.md                    (nueva nota defensiva de idioma cerca del Step "Update the spec"; incrementar metadata.version)
```
