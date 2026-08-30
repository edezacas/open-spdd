# Plan: Diff-to-canvas check en spdd-verify

> Part of the canvas at [../canvas.md](../canvas.md) — Requirements, Norms, and Safeguards live there and apply to this plan too; do not duplicate them here. `spdd-implement` and `spdd-verify` always read both files together.

**Status:** Verified
> Implemented: 2026-08-30
> Verified: 2026-08-30
**Depends on:** none
**Shared touchpoints:** none — este cambio es de un único plan; `spdd-verify/SKILL.md` y `spdd-verify/evals/evals.json` están íntegramente dentro de este plan.

---

## Operations

Subset of the canvas's Operations that belong to this plan (copy verbatim from `canvas.md`'s Operations table — do not paraphrase):

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Diff-to-canvas check" (nuevo Step 7, entre el Step 6 actual "Mark status" y el Step 7 actual "Fold back and archive") | Obtiene el diff real de los archivos modificados en esta implementación (`git diff` para cambios sin commitear; `git log -p`/`git log --stat` sobre las rutas declaradas en Structure/Shared touchpoints del plan/canvas si ya están commiteados) y lo compara punto por punto contra las Operations y Norms del canvas/plan en verificación |
| Check | Cobertura de Operations | Cada Operation del canvas/plan debe tener código correspondiente en el diff; si falta alguna, es una discrepancia bloqueante |
| Check | Alcance del diff | Ningún archivo/módulo tocado en el diff puede quedar fuera de Structure, Shared touchpoints u Operations del canvas/plan; si lo hace, es una discrepancia bloqueante — excepto los archivos de test que el propio Step 4 de `spdd-verify` creó durante esta misma verificación, que quedan exentos del chequeo por ser un subproducto esperado de la verificación, no del diff de implementación original |
| Gate | Discrepancia en sesión con turno en vivo (foreground) | Usa `AskUserQuestion` para preguntar al humano si la discrepancia es intencional; si confirma, continúa al fold anotando la discrepancia aceptada; si no confirma o no responde con claridad, detiene el proceso sin foldear |
| Gate | Discrepancia en subagente background (delegado por `spdd-agent`) | No usa `AskUserQuestion` (no hay turno de usuario en vivo) — trata la discrepancia igual que un fallo del Step 6: detiene el proceso, no folda, reporta el gap, deja una línea `⚠️ Confirm:` en el plan/canvas |
| Report | Discrepancia concreta | Formato: "Canvas declara: `<Operation o ruta>` → Código real: `<lo que el diff muestra o su ausencia>`" — nunca un genérico "no coincide" |

---

## Entities & Structure

**Entities this plan owns** (from the canvas's Entities section):
- Sección "Diff-to-canvas check" en `spdd-verify/SKILL.md` (New) — nuevo Step 7, insertado entre el actual Step 6 (Mark status) y el actual Step 7 (Fold back and archive, que pasa a ser Step 8; los actuales Steps 8-9 pasan a 9-10)
- `spdd/specs/spdd-verify.md` — **no** pertenece a este plan: la canvas la marca como creada la primera vez que este propio cambio se folde vía `spdd-verify` (Step 8 tras esta mejora), no durante esta fase de implementación. No crear este archivo aquí.

**Structure — files to create or modify:**

```
spdd-verify/SKILL.md          (insertar nuevo Step 7 "Diff-to-canvas check"; renumerar el Step 7 actual "Fold back and archive" -> 8, el Step 8 actual "Ensure the SPDD hook is present" -> 9, el Step 9 actual "Report back" -> 10; actualizar toda referencia interna a esos números de step, p. ej. la mención a "Step 8 (SPDD hook installation)" en el frontmatter `compatibility`; incrementar metadata.version de "1.0" a "1.1")
spdd-verify/evals/evals.json  (añadir al menos 4 casos nuevos: diff coherente con canvas [pasa sin fricción], diff con archivo no declarado [bloquea y reporta], Operation del canvas sin código correspondiente [bloquea y reporta], discrepancia confirmada como intencional por el humano en foreground [continúa el fold]; opcionalmente un quinto caso para discrepancia en background bajo spdd-agent [detiene sin bloquear, deja ⚠️ Confirm:, no folda] y un sexto para archivos de test del propio Step 4 exentos del chequeo de alcance, cubriendo así los 6 escenarios WHEN/THEN listados en Safeguards del canvas)
```
