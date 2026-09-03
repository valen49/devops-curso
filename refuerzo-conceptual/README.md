# Plan de refuerzo conceptual — Docker + Kubernetes

Plan de 7 bloques para cubrir vacíos de Docker I/II y Kubernetes I/II que son
objetivos explícitos de los encuentros oficiales pero que nunca se cubrieron
en el repo. No es repaso: es contenido nuevo, anclado en los manuales
oficiales del curso.

Orden por coherencia conceptual (de lo más fundamental a lo más aplicado), no
por orden de encuentros. Un bloque por vez; no se avanza al siguiente hasta
cerrar el anterior.

**Estado: Bloque 1 completo, Bloques 2-7 pendientes.**

## Bloques

- [x] **Bloque 1 — Namespaces & cgroups**: aislamiento a nivel kernel Linux (qué VE el contenedor vs. cuánto USA).

### Bloque 1: Namespaces & cgroups — ✅ Completo

**Concepto:**
- Namespaces aíslan la VISTA de recursos del kernel (PID, red, mount, etc.) por grupo de procesos — no limitan consumo.
- PID namespace: cada container tiene su propia numeración desde 1, independiente del PID real en el host. Si el PID 1 del namespace muere, todo el namespace (y el container) muere con él.
- Network namespace: cada container tiene su propio stack de red completo (tabla de puertos, interfaces), por eso 10 containers pueden "tener" el puerto 80 sin chocar. El mapeo -p host:container conecta el namespace de red del container con el del host.
- Cgroups limitan y contabilizan CPU/memoria/IO por grupo de procesos. Sin cgroups, un memory leak en un container puede consumir toda la RAM del host y activar el OOM Killer a nivel de todo el sistema (matando procesos al azar). Con cgroups, el OOM Killer actúa contenido dentro del cgroup específico.

**Práctica realizada en cx-server:**
- Confirmado con docker inspect + /proc/1/status: mismo proceso físico, dos PIDs distintos según namespace (host vs container).
- Confirmado OOM Killer de cgroup en acción: container con --memory=50m corriendo `stress --vm-bytes 150M` terminó en Exited, con `docker inspect --format='{{.State.OOMKilled}}'` devolviendo true.

**Troubleshooting aplicado:**
- Caso: Pod en CrashLoopBackOff con Exit Code 137 en Kubernetes.
- Diagnóstico: 137 = 128 + señal 9 (SIGKILL) = OOM Killer del kernel, no bug de código.
- Causa raíz identificada en resources.limits.memory del manifiesto YAML, no en el Dockerfile ni en el código de la app.
- Conclusión: "andaba bien en mi máquina" no contradice un OOM en cluster — el código es el mismo, el cgroup que lo rodea no.

- [ ] **Bloque 2 — Docker networking**: los 4 drivers (bridge, host, overlay, macvlan) + Kubernetes NetworkPolicy.
- [ ] **Bloque 3 — Persistencia**: 3 tipos de volumen Docker (anónimo, nombrado, bind mount) + Kubernetes PV/PVC/StorageClass.
- [ ] **Bloque 4 — Healthchecking**: `HEALTHCHECK` de Dockerfile + probes de Kubernetes (liveness/readiness/startup).
- [ ] **Bloque 5 — Modelo de objetos K8s**: ReplicaSet (Pod→ReplicaSet→Deployment) + objeto Endpoint.
- [ ] **Bloque 6 — Estrategias de despliegue**: RollingUpdate a fondo, Canary, Blue-Green.
- [ ] **Bloque 7 — Gaps restantes de Docker I**: ARG vs ENV, sintaxis de naming de imágenes, anti-patrones.

## Pendientes fuera del plan de refuerzo

- Prácticas Profesionales (PP1-PP5): no documentadas en el repo. Identificadas como gap en MEMORIA.md, sin contenido materializado. Pendiente de decisión sobre si se abordan como parte del curso o se dejan fuera del alcance de devops-curso.
