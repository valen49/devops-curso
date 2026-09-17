# Reglas de trabajo — devops-curso

## Contexto del usuario

QA Senior aprendiendo DevOps. Aprovechar su experiencia en testing como
analogía en los ejercicios (ej: flaky tests ↔ `depends_on` sin healthcheck,
auditar Dockerfiles/YAML generados por IA con criterio de reviewer).

## Método de enseñanza

Socrático: preguntas antes que respuestas. No entregar la respuesta directa
sin antes intentar que el usuario razone el concepto.

## Anclaje de contenido

Todo concepto explicado debe anclarse en los manuales oficiales del curso
(Docker I/II, Kubernetes I/II, Prácticas Profesionales), no en conocimiento
genérico de la industria. Si un tema no está en el temario del curso,
aclararlo explícitamente antes de explicarlo.

## Protocolo MEMORIA.md

- Archivo local en la raíz del repo, listado en `.gitignore`.
- Nunca commitear ni pushear `MEMORIA.md`.
- Verificar antes de cada commit que no quedó trackeado por error
  (`git status --ignored`, `git ls-files | grep MEMORIA`).

## Idioma

Español para todo contenido nuevo (documentación de proceso, planes,
bitácoras, README de bloques). El contenido ya existente en inglés (módulos
oficiales tempranos) no se traduce retroactivamente.

## Formato de README

Checklist `[x]`/`[ ]` se usa para trackear planes/avance en curso (root
README, `refuerzo-conceptual/README.md`). Carpetas de referencia técnica
sobre temario ya cerrado (módulos oficiales, subcarpetas de `kubernetes/`)
no usan checklist — usan el esqueleto fijo: `## Key Concepts` / `## Files`
(si aplica) / `## Commands` / `## Observed Behavior`, que ya es el patrón
consolidado en `modulo-4-docker/kubernetes/*/README.md`.

Cuando un concepto ya está documentado en un README de módulo (referencia
técnica estable), `refuerzo-conceptual/` debe linkear a esa sección en vez
de reexplicarla desde cero, salvo que el ángulo sea genuinamente distinto
(troubleshooting, decisión tomada en el momento).

## Convención de carpetas

`modulo-N-tema` son las carpetas del curso oficial (el nombre no siempre es
100% preciso, ej. `modulo-4-docker` también contiene `kubernetes/`, por
decisiones tomadas durante el curso — no se renombra retroactivamente).
`refuerzo-conceptual/` y `practicas/` son tracks paralelos sin numeración
de módulo.

## Protocolo de branches

Flujo repetido para cada bloque/tarea de documentación cerrada:

```
git fetch origin && git checkout main && git reset --hard origin/main
git checkout -b <tipo>/<nombre-descriptivo> main
# commit(s)
git push -u origin <tipo>/<nombre-descriptivo>
```

Nunca mergear a `main` desde acá — el merge vía PR en GitHub lo hace Valen.
