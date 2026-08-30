# Spec: spdd-verify

> Living spec for the `spdd-verify` domain. Folded from verified SPDD changes — kept in sync by
> `spdd-verify` (fold-back after each change) and `spdd-sync` (behavior-preserving refactors).

---

## Requirements

**User story:**
Como equipo que usa `spdd-verify`, quiero que la verificación compare el diff real de código
contra las Operations y Norms del canvas/plan de origen antes de foldear a la spec, para que
un test en verde no pueda ocultar una divergencia silenciosa entre lo acordado y lo implementado.

**Scenario: diff coherente con el canvas — continúa sin fricción**
- WHEN el diff real de los archivos modificados en la implementación cubre exactamente las Operations declaradas en el canvas/plan, sin tocar archivos/módulos no mencionados
- THEN `spdd-verify` reporta el chequeo como pasado en un renglón corto y continúa al fold-to-spec (Step 8) sin pedir confirmación

**Scenario: el diff toca un archivo no declarado en el canvas — bloquea**
- WHEN el diff real incluye cambios en un archivo o módulo que no aparece en Structure, Shared touchpoints ni Operations del canvas/plan en verificación
- THEN `spdd-verify` detiene el proceso antes del fold, muestra la discrepancia concreta (archivo tocado vs. lo declarado en el canvas) y no marca el scope como `Verified` ni folda nada a `spdd/specs/<domain>.md`

**Scenario: una Operation del canvas no tiene código correspondiente en el diff — bloquea**
- WHEN una Operation listada en el canvas/plan no tiene ningún cambio correspondiente en el diff real (código "conectado a nada" o directamente ausente)
- THEN `spdd-verify` detiene el proceso antes del fold, nombra la Operation sin implementación real y no marca el scope como `Verified`

**Scenario: discrepancia confirmada como intencional por el humano — continúa el fold**
- WHEN se detecta una discrepancia (archivo no declarado u Operation sin código) y el humano confirma explícitamente, en una sesión con turno en vivo, que es intencional
- THEN `spdd-verify` usa `AskUserQuestion` para pedir esa confirmación, y si se confirma, continúa al fold-to-spec anotando la discrepancia aceptada como nota en el fold (p. ej. una Operation fuera de alcance para esta iteración, documentada como tal)

**Scenario: discrepancia detectada corriendo como subagente en background bajo spdd-agent**
- WHEN `spdd-verify` corre como subagente en background delegado por `spdd-agent` (sin turno de usuario en vivo, sin `AskUserQuestion` disponible de forma útil) y el Diff-to-canvas check encuentra una discrepancia
- THEN `spdd-verify` no se queda bloqueado esperando una respuesta que no puede llegar — trata la discrepancia igual que un fallo del Step 6 (Structural check/tests): detiene el proceso, deja el plan/canvas como está, no folda ni archiva nada, reporta el gap concreto, y añade una línea `⚠️ Confirm:` en el plan/canvas para que el checkpoint en foreground de `spdd-agent` la resuelva después

**Scenario: `spdd-verify` writes new prose to the spec or discrepancy notes**
- WHEN `spdd-verify` folds a change into `spdd/specs/<domain>.md` (Step 8, "Fold back and
  archive") or writes a discrepancy/`⚠️ Confirm:` note during the Diff-to-canvas check (Step 7)
- THEN that new prose (not just content copied from the source canvas/plan) is written in
  English, consistent with the rest of the document it's added to

**Out of scope (deliberado):**
- Mejora 4 (`spdd/norms.md` como fuente adicional de verificación) — el Diff-to-canvas check valida solo contra el canvas/plan de origen, no contra normas globales de proyecto.
- No se introduce análisis estático de código (linters, AST, etc.) — la comparación diff-vs-canvas se hace con el propio razonamiento del agente al leer el diff, igual que ya hace `spdd-canvas` para generar el canvas.
- El Step 3 (Structural check) preexistente no cambia — el nuevo Step 7 lo complementa usando diff real de git en vez de solo lectura de rutas declaradas.

---

## Entities

| Name | Path | Notes |
|------|------|-------|
| Sección "Diff-to-canvas check" | `spdd-verify/SKILL.md` | Step 7, entre Step 6 (Mark status) y Step 8 (Fold back and archive) |
| Language note | `spdd-verify/SKILL.md` | Placed right after the Diff-to-canvas check gates (Step 7) and before "Fold back and archive" (Step 8) — covers new prose written in both steps |

---

## Operations

| Type | Identifier | Description |
|------|-----------|-------------|
| Step | "Diff-to-canvas check" (Step 7, entre Step 6 "Mark status" y Step 8 "Fold back and archive") | Obtiene el diff real de los archivos modificados en esta implementación (`git diff` para cambios sin commitear; `git log -p`/`git log --stat` sobre las rutas declaradas en Structure/Shared touchpoints del plan/canvas si ya están commiteados) y lo compara punto por punto contra las Operations y Norms del canvas/plan en verificación |
| Check | Cobertura de Operations | Cada Operation del canvas/plan debe tener código correspondiente en el diff; si falta alguna, es una discrepancia bloqueante |
| Check | Alcance del diff | Ningún archivo/módulo tocado en el diff puede quedar fuera de Structure, Shared touchpoints u Operations del canvas/plan; si lo hace, es una discrepancia bloqueante — excepto los archivos de test que el propio Step 4 de `spdd-verify` creó durante esta misma verificación, que quedan exentos del chequeo por ser un subproducto esperado de la verificación, no del diff de implementación original |
| Gate | Discrepancia en sesión con turno en vivo (foreground) | Usa `AskUserQuestion` para preguntar al humano si la discrepancia es intencional; si confirma, continúa al fold anotando la discrepancia aceptada; si no confirma o no responde con claridad, detiene el proceso sin foldear |
| Gate | Discrepancia en subagente background (delegado por `spdd-agent`) | No usa `AskUserQuestion` (no hay turno de usuario en vivo) — trata la discrepancia igual que un fallo del Step 6: detiene el proceso, no folda, reporta el gap, deja una línea `⚠️ Confirm:` en el plan/canvas |
| Report | Discrepancia concreta | Formato: "Canvas declara: `<Operation o ruta>` → Código real: `<lo que el diff muestra o su ausencia>`" — nunca un genérico "no coincide" |
| Note | Language note in `spdd-verify/SKILL.md` (near Steps 7–8) | States that any new prose written during the Diff-to-canvas check (discrepancy notes, `⚠️ Confirm:` lines) or during Fold back and archive (new scenarios/Norms added to the spec, fold annotations) must be in English, regardless of the user's conversation language — the canvas/plan/spec documents are always in English; conversational replies to the user follow the conversation's language settings |

---

## Norms

- Simplicity First: el Diff-to-canvas check no introduce análisis estático ni herramientas externas — solo lectura de diff y razonamiento del agente.
- El Diff-to-canvas check (Step 7) complementa el Step 3 (Structural check) sin duplicarlo: Step 3 sigue comprobando declaración de rutas; Step 7 usa el diff real de git como evidencia objetiva.
- Incrementar `metadata.version` de `spdd-verify/SKILL.md` al guardar cualquier edición de sus instrucciones.
- Nunca foldear a `spdd/specs/<domain>.md` mientras exista una discrepancia sin resolver — ni en foreground sin confirmación explícita, ni en background bajo `spdd-agent`.
- New prose `spdd-verify` writes during the Diff-to-canvas check (Step 7) or the fold-to-spec step (Step 8) must be in English, regardless of the conversation's language — this applies even when, as in this repo today, the surrounding spec sections were written in Spanish before this rule existed; existing content is not retranslated as a side effect.
