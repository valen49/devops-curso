# Plan de refuerzo conceptual — Docker + Kubernetes

Plan de 7 bloques para cubrir vacíos de Docker I/II y Kubernetes I/II que son
objetivos explícitos de los encuentros oficiales pero que nunca se cubrieron
en el repo. No es repaso: es contenido nuevo, anclado en los manuales
oficiales del curso.

Orden por coherencia conceptual (de lo más fundamental a lo más aplicado), no
por orden de encuentros. Un bloque por vez; no se avanza al siguiente hasta
cerrar el anterior.

**Estado: Bloques 1-2 completos, Bloques 3-7 pendientes.**

Ver comandos-frecuentes.md para referencia rápida de CLI usada en los bloques.

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

- [x] **Bloque 2 — Docker networking**: los 4 drivers (bridge, host, overlay, macvlan) + Kubernetes NetworkPolicy.

### Bloque 2: Docker networking + K8s NetworkPolicy — ✅ Completo

**Concepto — Docker networking:**
- Driver bridge (default): crea la interfaz docker0, cada container recibe IP privada, DNS embebido de Docker resuelve nombre de servicio → IP.
- Riesgo de seguridad identificado: red bridge plana por default = cualquier container puede hablarle a cualquier otro sin restricción (ej. container de logging comprometido puede moverse lateralmente y llegar directo a la DB vía DNS interno).
- Mitigación en Docker Compose: múltiples redes, cada container solo en las que estrictamente necesita (least privilege aplicado a networking).
- host, overlay y macvlan quedaron como "cultura general" — no se profundizó en práctica, valorados como de uso poco frecuente en el día a día salvo casos específicos (overlay es usado indirectamente por K8s/Swarm; macvlan es nicho para legacy/IoT).

**Concepto — Kubernetes NetworkPolicy:**
- Por default, todos los Pods de un cluster K8s se hablan entre sí sin restricción (red plana, mismo problema que en Docker pero a escala de cluster).
- Las IPs de Pods son efímeras (cambian en cada recreación), por eso NetworkPolicy usa labels + selectors (mismo mecanismo que Services/Deployments) en vez de IPs fijas.
- Modelo mental: "portero con lista" — es un modelo whitelist, no blacklist. Sin política = puerta abierta. Con política aplicada a un Pod = solo entra lo explícitamente permitido, todo el resto queda bloqueado automáticamente. Borrar la política vuelve al estado original (puerta abierta), no queda "cerrado para siempre".
- Namespace de Kubernetes (organización lógica de recursos) NO es lo mismo que namespace de kernel Linux (Bloque 1) — mismo término, capas distintas. Namespace K8s por sí solo NO aísla tráfico de red entre namespaces; NetworkPolicy sí.
- Dato de troubleshooting: CoreDNS resuelve nombres de Services, no de Pods sueltos sin Service asociado (confirmado en la práctica: wget por nombre falló, por IP funcionó).

**Práctica realizada en cx-server (Minikube + Calico):**
- Minikube requirió reinstalación completa (binario no estaba presente, solo cache viejo) y recreación del cluster con `--driver=docker --cni=calico` (profile viejo usaba driver `none`, que requiere sudo y no era práctico).
- Namespace de prueba `netpol-demo` con 3 pods: `db` (label tier=db, imagen nginx), `logging` (label tier=logging, sin permiso), `backend-test` (label tier=backend, con permiso).
- Baseline sin política: logging → db, tráfico permitido (HTML de nginx recibido).
- Aplicado NetworkPolicy `solo-backend-a-db` (podSelector tier=db, ingress solo desde tier=backend).
- Resultado confirmado con Calico: logging → db bloqueado (timeout), backend-test → db permitido (HTML recibido). Ambos casos verificados con evidencia real de comandos.
- Namespace de prueba limpiado al final (`kubectl delete namespace netpol-demo`).

- [ ] **Bloque 3 — Persistencia**: 3 tipos de volumen Docker (anónimo, nombrado, bind mount) + Kubernetes PV/PVC/StorageClass.
- [ ] **Bloque 4 — Healthchecking**: `HEALTHCHECK` de Dockerfile + probes de Kubernetes (liveness/readiness/startup).

### Bloque 4: HEALTHCHECK + K8s probes (liveness/readiness/startup) — 🔶 En curso (concepto y troubleshooting cubiertos, falta práctica)

**Concepto — Docker HEALTHCHECK:**
- Un container en estado "Up" no garantiza que la aplicación funcione bien — el proceso puede estar vivo mientras la app está rota (ejemplo real: bind-demo del Bloque 3, "Up" pero devolviendo 403).
- HEALTHCHECK en el Dockerfile define un chequeo activo y periódico (intervalo, timeout, reintentos) contra un endpoint real de la app, no solo "¿el puerto responde algo?".
- Diferencia clave: chequear la raíz (`/`) solo confirma que el servidor web responde; un endpoint dedicado (`/healthz`) permite que la app verifique sus dependencias reales (DB, disco, etc.) antes de responder 200 o un error.
- Un endpoint mal diseñado que siempre devuelve 200 sin verificar nada real genera falsos positivos de salud.

**Concepto — Kubernetes probes (los 3 tipos):**
- Startup probe: "¿ya terminaste de arrancar?". Corre una sola vez al inicio con tolerancia generosa; mientras no pase, liveness y readiness no se evalúan. Evita que apps con arranque lento entren en loop de reinicios por un liveness probe con tolerancia normal (más estricta).
- Readiness probe: "¿podés atender tráfico ahora?". Si falla, el Pod sale de los Endpoints del Service (deja de recibir tráfico) pero NO se reinicia — se asume una condición temporal.
- Liveness probe: "¿seguís funcionando o estás colgado?". Si falla, Kubernetes mata y reinicia el container.
- La distinción readiness vs liveness es la clave: uno gestiona disponibilidad de tráfico, el otro gestiona si el proceso necesita reiniciarse.

**Troubleshooting aplicado:**
- Escenario: Deployment con 5 réplicas, todas `Running` y `1/1 Ready`, pero comportamiento inconsistente/lento reportado por usuarios.
- Diagnóstico: el readiness probe está dando falsos positivos — probablemente chequea un endpoint que responde 200 sin validar dependencias reales (ej. no mide latencia de DB), por lo que Kubernetes considera "listas" réplicas que en realidad están degradadas.
- Acción real: revisar la definición del readinessProbe (`kubectl describe deployment`), revisar el código del endpoint de healthcheck, y mejorarlo para que refleje el estado real de las dependencias.

**PENDIENTE — práctica hands-on acordada para la próxima sesión:**
1. Docker HEALTHCHECK: container con un endpoint de salud que se pueda romper a propósito, observar en `docker ps` el cambio de estado `(healthy)` a `(unhealthy)`.
2. K8s readiness probe: Pod con un endpoint de readiness togglable; al romperlo, confirmar con `kubectl get endpoints` que el Pod sale de los Endpoints del Service mientras `kubectl get pods` lo sigue mostrando `Running` (sin reiniciarse).
3. Mismo experimento con liveness probe en vez de readiness, para contrastar: esta vez el Pod sí se reinicia (columna RESTARTS incrementa).
4. Demo de startup probe con una app de arranque lento simulado, para ver en vivo el problema de loop de reinicios que evita.

- [ ] **Bloque 5 — Modelo de objetos K8s**: ReplicaSet (Pod→ReplicaSet→Deployment) + objeto Endpoint.
- [ ] **Bloque 6 — Estrategias de despliegue**: RollingUpdate a fondo, Canary, Blue-Green.
- [ ] **Bloque 7 — Gaps restantes de Docker I**: ARG vs ENV, sintaxis de naming de imágenes, anti-patrones.

## Pendientes fuera del plan de refuerzo

- Prácticas Profesionales (PP1-PP5): no documentadas en el repo. Identificadas como gap en MEMORIA.md, sin contenido materializado. Pendiente de decisión sobre si se abordan como parte del curso o se dejan fuera del alcance de devops-curso.
