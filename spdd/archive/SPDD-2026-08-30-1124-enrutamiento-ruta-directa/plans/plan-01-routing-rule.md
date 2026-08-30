# Plan: Regla de enrutamiento (ruta directa vs. flujo completo)

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.
> Language: translate all section headings, labels, and body content to the language detected from the user.

**Status:** Verified
> Implemented: 2026-08-30
> Verified: 2026-08-30

**Depends on:** none
**Shared touchpoints:** none

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Classify change scope" (nuevo Step, antes del Step 1 actual) | Decide ruta directa vs. completa según nº de archivos y presencia de ambigüedad de negocio/arquitectura |
| Route | Ruta directa | Implementa sin canvas ni plan, corre el test suite del área afectada, anota resumen en `spdd/specs/<domain>.md` |
| Route | Ruta completa | Comportamiento actual sin cambios: canvas → design → implement → verify |
| Output | Línea de transparencia | `Ruta directa: <motivo> → implemento sin canvas.` — se muestra siempre que se elige ruta directa, antes de ejecutar cualquier cambio |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Sección "Routing" (`spdd-agent/SKILL.md`) — New
- Config de modelos (`~/.config/spdd/config.json`) — Existing; su bootstrap pasa a ser condicional (solo se dispara si la ruta es "completa")

**Structure — files to create or modify:**

```
spdd-agent/SKILL.md          (nueva sección "Routing"; reordena el Step 1 actual detrás de ella)
spdd-agent/evals/evals.json  (nuevos casos: ruta directa, ruta completa, caso límite 2 vs 3 archivos)
```
