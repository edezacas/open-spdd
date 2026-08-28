# Plan: migración de SPDD a `open-spdd`

> Creado: 2026-08-28
> Estado: Draft — pendiente de confirmación antes de ejecutar
> Alcance: SOLO desacoplar las skills SPDD de `agent-skills` y trasladarlas a este repo. Agentes con modelo por fase, skill orquestadora y demás capa de framework quedan fuera de este plan — se abordarán en un plan aparte más adelante.

## Objetivo

1. Mover las 6 skills SPDD (`spdd-canvas`, `spdd-design`, `spdd-implement`, `spdd-verify`, `spdd-sync`, `spdd-migrate`) desde `agent-skills` a este repo, preservando su historial de git.
2. Dejar `agent-skills` únicamente con `angular-conventions` e `init-project`.
3. Actualizar los symlinks en `~/.claude/skills/` para que apunten al nuevo repo.

## Alcance

**Se mueve a `open-spdd`:**
- `spdd-canvas/`, `spdd-design/`, `spdd-implement/`, `spdd-verify/`, `spdd-sync/`, `spdd-migrate/` (incluye `assets/` y `evals/` de cada una)
- La documentación SPDD en `agent-skills/CLAUDE.md` (tablas de estructura, auto-triggers, tool permissions, sección "SPDD guard hook") se traslada y adapta a un `CLAUDE.md`/`README.md` propio de `open-spdd`

**Se queda en `agent-skills`:**
- `angular-conventions/`, `init-project/`
- `CLAUDE.md` reescrito para reflejar solo estas dos skills

**Fuera de este plan (pendiente, plan futuro):**
- Agentes `.claude/agents/spdd-*-agent.md` con modelo fijado por fase
- Skill orquestadora que encadena canvas→design→implement→verify desde un único prompt

## Paso 1 — Migrar con historial preservado

Usar `git filter-repo` sobre un clon temporal de `agent-skills` para extraer solo los 6 directorios SPDD con su historial, y traerlo como remoto a `open-spdd`:

```bash
git clone /home/eduarddeza/Sites/edezacas/agent-skills /tmp/.../agent-skills-spdd-extract
cd /tmp/.../agent-skills-spdd-extract
git filter-repo --path spdd-canvas --path spdd-design --path spdd-implement \
  --path spdd-verify --path spdd-sync --path spdd-migrate

cd /home/eduarddeza/Sites/edezacas/open-spdd
git remote add spdd-extract /tmp/.../agent-skills-spdd-extract
git fetch spdd-extract
git merge spdd-extract/master --allow-unrelated-histories
git remote remove spdd-extract
```

Resultado: los commits que tocan SPDD aparecen en `open-spdd` con autoría y fechas originales.

## Paso 2 — Limpiar `agent-skills`

- `git rm -r spdd-canvas spdd-design spdd-implement spdd-verify spdd-sync spdd-migrate`
- Reescribir `agent-skills/CLAUDE.md`: quitar todas las filas SPDD de las tablas de estructura, auto-triggers, tool permissions y la sección "SPDD guard hook"
- Commit en `agent-skills` explicando el split

## Paso 3 — Actualizar symlinks

```bash
for s in spdd-canvas spdd-design spdd-implement spdd-verify spdd-sync spdd-migrate; do
  rm ~/.claude/skills/$s
  ln -s /home/eduarddeza/Sites/edezacas/open-spdd/$s ~/.claude/skills/$s
done
```

## Paso 4 — Documentación mínima de `open-spdd`

- `README.md`: qué es, instalación (symlinks), lista de las 6 skills y el flujo canvas→design→implement→verify (sync/migrate como ramas laterales)
- `CLAUDE.md`: mismo formato que tenía en `agent-skills` (auto-triggers, tool permissions, SPDD guard hook), adaptado a este repo

## Orden de ejecución

Todos los pasos son mecánicos y de bajo riesgo — se revisa el resultado de cada uno antes de comitear. No hay decisiones de diseño nuevas en este plan.
