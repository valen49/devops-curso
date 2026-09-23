# PP5 — Pipeline Node.js completo (Docker multi-stage, CI/CD, Trivy, Apache Bench)

## Objetivo

Construir un proyecto Node.js/Express completo siguiendo el manual guiado de 37 pasos, con imagen Docker multi-stage, registro local, pipeline CI/CD de 8 etapas, escaneo de seguridad con Trivy y prueba de performance con Apache Bench.

## Stack

- Node 20-alpine
- Express
- Jest + Supertest (testing)
- ESLint (linting)
- Docker (multi-stage build)
- Registro local (`registry:2`, `localhost:5000`)
- Trivy (escaneo de vulnerabilidades)
- Apache Bench (`ab`, prueba de performance)

## Archivos

- `app/package.json` — dependencias (Express) y devDependencies (ESLint, Jest, Supertest)
- `app/index.js` — app Express con rutas `/` y `/healthz`
- `app/app.test.js` — 3 tests con Supertest (`/`, `/healthz`, 404 en ruta inexistente)
- `app/.eslintrc.js` — reglas ESLint (`eslint:recommended` + indent/quotes/semi/linebreak-style)
- `app/jest.config.js` — `testEnvironment: node`
- `app/package-lock.json` — lockfile real, versionado para reproducibilidad
- `app/Dockerfile` — build multi-stage
- `app/scripts/pipeline.sh` — pipeline inicial de 6 pasos (lint, test, build, registry push, deploy, health check)
- `app/pipeline_final.sh` — pipeline final de 8 pasos (suma security scan con Trivy y performance test con Apache Bench)

## Conceptos aplicados

- **Multi-stage build real, con evidencia propia**: comparación de tamaños medida entre la imagen multi-stage y una versión single-stage — 200MB vs 447MB, -55% de uso de disco. No quedó en teoría, se midió.
- **Fix de seguridad aplicado (mismo patrón que en PP7)**: el `Dockerfile` elimina explícitamente `npm`, `npx`, `corepack` y `yarn` de la imagen final (`RUN rm -rf ...` en la etapa de producción) porque esas herramientas solo hacen falta durante el build, no en runtime. Este fix bajó las vulnerabilidades Node.js de 29 (1 CRITICAL, 19 HIGH) a 0.
- **"Instalar dependencias" vs "copiar el resultado ya instalado"**: la etapa `builder` corre `npm install --omit=dev` una sola vez; la etapa de producción no vuelve a instalar nada — copia `node_modules` ya resuelto desde el builder (`COPY --from=builder ... /app/node_modules`).
- **Usuario no-root en runtime**: la imagen final crea y usa el usuario `nodejs` (`USER nodejs`), no corre como root.
- **HEALTHCHECK de Dockerfile**: definido contra el endpoint `/healthz`, mismo patrón conceptual ya visto en el Bloque 4 del plan de refuerzo conceptual.
- **Evolución del pipeline**: `scripts/pipeline.sh` (versión de 6 pasos, sin seguridad ni performance) y `pipeline_final.sh` (versión de 8 pasos) documentan dos momentos distintos del mismo laboratorio — el segundo agrega Security Scan (Trivy) y Performance Test (Apache Bench) sobre la base del primero.

## Resultados observados

- Pipeline de 8 etapas (`pipeline_final.sh`) corriendo sin fallos: Linting → Testing (3/3 tests) → Build → Security Scan → Registry Push → Deploy → Health Check → Performance Test.
- 0 vulnerabilidades críticas/altas en dependencias Node tras el fix de la imagen final (partiendo de 29: 1 CRITICAL, 19 HIGH).
- Performance con Apache Bench: ~1000-1600 req/sec.
- Quedan ~50 CVEs irreducibles de la capa base Alpine (sin ninguno CRITICAL) — no atribuibles al código ni a las dependencias Node del proyecto.
