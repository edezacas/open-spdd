# Spec: spdd-agent

> Living spec for the `spdd-agent` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**Scenario: ruta directa se activa y se anuncia**
- WHEN el usuario describe un cambio que toca 1-2 archivos, es mecánico o de alcance evidente, y no hay ambigüedad de negocio ni de arquitectura
- THEN `spdd-agent` muestra la línea `Ruta directa: <motivo> → implemento sin canvas.` antes de ejecutar, implementa el cambio directamente sin generar canvas ni plan, y no invoca `spdd-canvas`/`spdd-design`/`spdd-verify`

**Scenario: ruta completa por defecto ante duda**
- WHEN el cambio toca 3+ archivos, requiere entender varias partes del sistema, hay cualquier ambigüedad de negocio/arquitectura, o el agente no está seguro de cuál ruta aplica
- THEN `spdd-agent` sigue el flujo completo canvas → design → implement → verify tal como existe hoy, sin excepción — la duda siempre resuelve a favor de la ruta completa

**Scenario: el bootstrap de modelos no bloquea la ruta directa**
- WHEN la decisión de enrutamiento resulta en ruta directa
- THEN `spdd-agent` NO dispara el bootstrap de `~/.config/spdd/config.json` antes de implementar, porque la ruta directa no lanza subagentes ni necesita esa configuración; el chequeo de routing se evalúa siempre antes del Step 1 de bootstrap de modelos, y el bootstrap solo se dispara si la decisión final es ruta completa

**Scenario: ruta directa exige tests en verde antes de tocar la spec**
- WHEN `spdd-agent` implementa por ruta directa
- THEN corre el test suite del área afectada antes de anotar el resumen en `spdd/specs/<domain>.md`; si algún test falla, no anota nada en la spec, reporta el fallo concreto al usuario, y no revierte el código automáticamente — deja la decisión de revertir o corregir al humano

**Scenario: cobertura de evals de la regla de enrutamiento**
- WHEN se da la mejora de enrutamiento por completada
- THEN existen en `spdd-agent/evals/evals.json` casos que cubren: ruta directa activada, ruta completa activada, el caso límite de 2 vs. 3 archivos con módulo compartido, ambigüedad de negocio en un cambio de 1 archivo, fallo de tests en ruta directa sin auto-revert, fallback de dominio a `spdd/specs/general.md`, y bootstrap de primera vez combinado con ruta completa

**Scenario: ruta directa sin dominio inferible**
- WHEN el cambio no permite inferir un dominio claro (no sigue convención de carpetas tipo `src/<domain>/`)
- THEN usa `spdd/specs/general.md` como fallback, igual que ya hace `spdd-canvas`

**Out of scope (deliberado):**
- No se añade verificación automática de que la ruta elegida ("directa" vs. "completa") fue "la correcta" — es deliberadamente heurística y falible; el control de calidad real vive en una mejora separada (diff vs. canvas en `spdd-verify`, aún no implementada).

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| Sección "Routing" (Step 0) | `spdd-agent/SKILL.md` | Evalúa ruta directa vs. completa antes de cualquier otro paso |
| Config de modelos | `~/.config/spdd/config.json` | Bootstrap condicional: solo se dispara si la ruta elegida es "completa" |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Classify change scope" (Step 0, routing decision) | Decide ruta directa vs. completa según nº de archivos y presencia de ambigüedad de negocio/arquitectura, antes de invocar cualquier fase |
| Route | Ruta directa | Implementa sin canvas ni plan, corre el test suite del área afectada, anota resumen en `spdd/specs/<domain>.md` solo si los tests pasan |
| Route | Ruta completa | canvas → design → implement → verify, sin cambios respecto al flujo preexistente |
| Output | Línea de transparencia | `Ruta directa: <motivo> → implemento sin canvas.` — se muestra siempre que se elige ruta directa, antes de ejecutar cualquier cambio |

---

## Norms

- Ante la duda entre ruta directa y completa, elegir SIEMPRE la ruta completa.
- No añadir verificación automática de que la ruta elegida fue "la correcta".
- Incrementar `metadata.version` de `spdd-agent/SKILL.md` en cualquier edición de sus instrucciones.
