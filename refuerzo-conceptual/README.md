# Plan de refuerzo conceptual — Docker + Kubernetes

Plan de 7 bloques para cubrir vacíos de Docker I/II y Kubernetes I/II que son
objetivos explícitos de los encuentros oficiales pero que nunca se cubrieron
en el repo. No es repaso: es contenido nuevo, anclado en los manuales
oficiales del curso.

Orden por coherencia conceptual (de lo más fundamental a lo más aplicado), no
por orden de encuentros. Un bloque por vez; no se avanza al siguiente hasta
cerrar el anterior.

**Estado: ninguno arrancado todavía.**

## Bloques

- [ ] **Bloque 1 — Namespaces & cgroups**: aislamiento a nivel kernel Linux (qué VE el contenedor vs. cuánto USA).
- [ ] **Bloque 2 — Docker networking**: los 4 drivers (bridge, host, overlay, macvlan) + Kubernetes NetworkPolicy.
- [ ] **Bloque 3 — Persistencia**: 3 tipos de volumen Docker (anónimo, nombrado, bind mount) + Kubernetes PV/PVC/StorageClass.
- [ ] **Bloque 4 — Healthchecking**: `HEALTHCHECK` de Dockerfile + probes de Kubernetes (liveness/readiness/startup).
- [ ] **Bloque 5 — Modelo de objetos K8s**: ReplicaSet (Pod→ReplicaSet→Deployment) + objeto Endpoint.
- [ ] **Bloque 6 — Estrategias de despliegue**: RollingUpdate a fondo, Canary, Blue-Green.
- [ ] **Bloque 7 — Gaps restantes de Docker I**: ARG vs ENV, sintaxis de naming de imágenes, anti-patrones.

## Pendientes fuera del plan de refuerzo

- Prácticas Profesionales (PP1-PP5): no documentadas en el repo. Identificadas como gap en MEMORIA.md, sin contenido materializado. Pendiente de decisión sobre si se abordan como parte del curso o se dejan fuera del alcance de devops-curso.
