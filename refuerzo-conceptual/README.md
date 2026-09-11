# Plan de refuerzo conceptual — Docker + Kubernetes

Plan de 7 bloques para cubrir vacíos de Docker I/II y Kubernetes I/II que son
objetivos explícitos de los encuentros oficiales pero que nunca se cubrieron
en el repo. No es repaso: es contenido nuevo, anclado en los manuales
oficiales del curso.

Orden por coherencia conceptual (de lo más fundamental a lo más aplicado), no
por orden de encuentros. Un bloque por vez; no se avanza al siguiente hasta
cerrar el anterior.

**Estado: Bloques 1-7 completos. Plan de refuerzo conceptual cerrado.**

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

### Bloque 3: Docker volumes + K8s PV/PVC/StorageClass — 🔶 En curso (concepto cubierto, falta práctica)

**Concepto — Docker volumes (los 3 tipos):**
- Los containers son descartables por diseño; todo lo escrito sin volumen vive en la capa copy-on-write y se pierde con `docker rm`.
- Anónimo (`-v /datos`): Docker asigna ID críptico, sirve para persistencia sin importar identificación ni reutilización.
- Bind mount (`-v /host/ruta:/container/ruta`): conecta 1 a 1 una ruta real del host, sin copia. Probado en cx-server: al borrar la carpeta del host con el container corriendo, nginx quedó "Up" pero devolviendo 403 Forbidden — el container no se cae, pero pierde acceso al contenido real sin aviso. Dato de troubleshooting: útil para diagnosticar "container corriendo pero sirviendo errores" sin cambios de código/imagen.
- Nombrado (`-v nombre:/datos`): gestionable, identificable, reutilizable entre containers. Probado en cx-server: escribimos un archivo, borramos el container por completo (`docker rm -f`), levantamos un container nuevo con distinto nombre montando el mismo volumen nombrado, y el archivo seguía intacto — confirma que el volumen vive independiente del ciclo de vida de cualquier container puntual.

**Concepto — Kubernetes PV/PVC/StorageClass:**
- Mismo patrón que el volumen nombrado de Docker, escalado a nivel cluster: los datos no pueden depender del ciclo de vida de un Pod específico (los Pods son aún más descartables que los containers).
- PersistentVolume (PV): el recurso de almacenamiento real, existe independiente de cualquier Pod.
- PersistentVolumeClaim (PVC): la solicitud que hace un Pod ("necesito X GB, con tal modo de acceso"). El Pod habla con el PVC, no directo con el PV.
- StorageClass: define parámetros del backend (tipo de disco, proveedor) y permite provisión dinámica de PVs cuando aparece un PVC que los pide, sin crearlos a mano de antemano.
- Confirmado conceptualmente (sin práctica aún): un Pod nuevo que reemplaza a uno caído, si declara el mismo PVC, se reconecta a los mismos datos del PV asociado.

**PENDIENTE — retomar en la próxima sesión:**
- Práctica real en Minikube: crear un PVC + Pod, escribir datos, borrar el Pod, recrear con el mismo PVC, confirmar persistencia (mismo patrón que se hizo con volumen nombrado en Docker).
- No cubierto todavía: modos de acceso (ReadWriteOnce/ReadWriteMany/ReadOnlyMany), reclaim policy (Retain/Delete/Recycle), volúmenes efímeros vs emptyDir.
- Ejercicio de troubleshooting del bloque: no realizado.

- [x] **Bloque 4 — Healthchecking**: `HEALTHCHECK` de Dockerfile + probes de Kubernetes (liveness/readiness/startup).

### Bloque 4: HEALTHCHECK + K8s probes (liveness/readiness/startup) — ✅ Completo

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

**Práctica realizada en cx-server:**
- Docker HEALTHCHECK: container nginx con `--health-cmd="curl -f http://localhost/healthz || exit 1"` sobre un bind mount. Confirmado ciclo completo con evidencia real: borrar el archivo `healthz` → `docker ps` muestra `(unhealthy)` en ~10s (interval 5s × retries 2); recrear el archivo → vuelve a `(healthy)`.
- Kubernetes readiness vs liveness, contraste directo en Minikube: dos Pods nginx idénticos, cada uno con un probe tipo `exec` (`cat /usr/share/nginx/html/healthz`) — uno como readinessProbe, otro como livenessProbe. Sin el archivo, resultado observado:
  - Pod con readinessProbe: `Running`, `0` restarts, pero **sin Endpoints** en el Service creado con `kubectl expose` (confirmado con `kubectl get endpoints` vacío) — el Pod queda excluido de tráfico sin reiniciarse.
  - Pod con livenessProbe: entró en `CrashLoopBackOff` con restarts crecientes. Confirmado con `kubectl describe pod` el evento explícito del kubelet: "Container nginx failed liveness probe, will be restarted".
- Startup probe: no se hizo demo hands-on — Valen decidió saltarlo por ser conceptualmente redundante con el mismo mecanismo ya demostrado en readiness/liveness (probe que falla → Kubernetes reacciona).
- Namespace de prueba (`probes-demo`) limpiado al final con `kubectl delete namespace`.

- [x] **Bloque 5 — Modelo de objetos K8s**: ReplicaSet (Pod→ReplicaSet→Deployment) + objeto Endpoint.

### Bloque 5: Modelo de objetos K8s — ReplicaSet + Endpoint — ✅ Completo (solo concepto, sin práctica hands-on)

**Concepto:**
- Un Pod es frágil por sí solo: si desaparece por completo (nodo caído, borrado manual), nadie lo repone — a diferencia de un container reiniciado por el kubelet (ej. liveness probe fallido del Bloque 4), que ocurre DENTRO del mismo Pod, con el mismo nombre.
- ReplicaSet: controlador que compara constantemente "cuántos Pods con cierta label existen" contra un número declarado (`replicas: N`). Solo actúa cuando el número real cae por debajo del declarado — no hace nada mientras coincide. Cuando repone un Pod, crea uno NUEVO con nombre distinto (sufijo generado), nunca reutiliza el nombre del Pod perdido.
- Deployment envuelve al ReplicaSet y agrega rolling updates (reemplazo gradual de Pods al actualizar la imagen), algo que ReplicaSet solo no sabe hacer — por eso en la práctica casi nunca se crea un ReplicaSet directamente.
- Objeto Endpoint: lista viva de IPs de Pods que un Service considera válidas para recibir tráfico ahora mismo, mantenida por un controlador separado que vigila el estado de `Ready` de cada Pod (mismo campo que gestionan los readiness probes del Bloque 4). Ya visto en la práctica del Bloque 4 sin nombrarlo formalmente entonces (`kubectl get endpoints` vacío mientras el Pod no era Ready).

**Nota:** no se hizo práctica hands-on (crear Deployment de 3 réplicas, borrar un Pod a mano y ver el ReplicaSet reponerlo con nombre nuevo) ni el ejercicio de troubleshooting (Service con Endpoints incompletos por mismatch de labels/selector) — quedaron explicados pero no ejecutados, por decisión de Valen.

- [x] **Bloque 6 — Estrategias de despliegue**: RollingUpdate a fondo, Canary, Blue-Green.

### Bloque 6: Estrategias de despliegue — RollingUpdate, Recreate, Canary, Blue/Green — ✅ Completo (solo concepto, sin práctica hands-on)

**Concepto:**
- Recreate: apaga todas las réplicas viejas antes de levantar las nuevas. Ventana de indisponibilidad total, pero evita que versiones incompatibles convivan. Usar cuando el cambio (ej. de esquema de datos) es incompatible entre versiones.
- RollingUpdate (default de Deployment): reemplazo gradual, viejas y nuevas conviven — requiere que las versiones sean compatibles entre sí (mismo Service enruta a ambas sin distinguir versión). Dos parámetros clave: `maxSurge` (capacidad extra temporal permitida por encima de las réplicas declaradas) y `maxUnavailable` (cuántas réplicas del total declarado se toleran no disponibles durante la transición). `minReadySeconds` evita falsos positivos de readiness durante el warm-up. Kubernetes guarda historial de ReplicaSets, permitiendo rollback.
- Canary: se dirige un porcentaje chico de tráfico real (ej. 5%) a la versión nueva, monitoreando métricas (errores, latencia) antes de escalar gradualmente el porcentaje. Permite detectar problemas que solo aparecen con tráfico real de producción, a costa de exponer a una fracción de usuarios reales durante la prueba. Rollback es gradual (hay que desescalar).
- Blue/Green: dos entornos completos y paralelos (Blue = versión actual en producción, Green = versión nueva en preparación, sin tráfico real hasta el switch). Switch instantáneo de todo el tráfico de una vez. Ningún usuario expuesto durante la preparación, pero problemas que solo aparecen con tráfico real de producción se detectan recién en el switch completo (a exposición total). Rollback instantáneo porque Blue nunca se apaga. Costo: recursos duplicados durante la convivencia.

**Nota:** no se hizo práctica hands-on ni ejercicio de troubleshooting para este bloque — quedó cubierto solo a nivel conceptual, por decisión de Valen.

- [x] **Bloque 7 — Gaps restantes de Docker I**: ARG vs ENV, sintaxis de naming de imágenes, anti-patrones.

### Bloque 7: Gaps restantes de Docker I — ARG vs ENV, naming de imágenes, anti-patrones — ✅ Completo (solo concepto, sin práctica hands-on)

**Concepto:**
- ARG vs ENV: ARG es un valor disponible solo durante el build (`docker build`), no persiste en la imagen final. ENV persiste en runtime, disponible mientras el container corre. Nunca usar ENV para secretos (quedan visibles en la imagen final vía `docker inspect`/`docker history`); ARG es la opción correcta para valores efímeros de build (tokens de descarga, flags de compilación, etc.).
- Sintaxis de naming: `[REGISTRY/]USUARIO/REPO[:TAG]`. Sin REGISTRY se asume docker.io; sin TAG se asume `latest`. `latest` es una etiqueta móvil que el mantenedor reapunta a la versión más reciente — dos pulls en momentos distintos pueden traer bits distintos sin que nadie cambie nada del lado del usuario. Alternativas: tag semántico (`1.29.0`, legible pero técnicamente reapuntable) o digest (`@sha256:...`, inmutable matemáticamente). Patrón recomendado: versionar doblemente — tag semántico para legibilidad humana (Dockerfile, docs), digest resuelto para garantías de inmutabilidad en pipelines de despliegue automatizado a producción.
- Anti-patrón 1 — `docker exec` para modificar containers en producción: rompe la inmutabilidad (el cambio vive solo en la capa RW efímera, se pierde al recrear el container) y genera drift silencioso entre réplicas de un mismo Deployment que deberían ser idénticas.
- Anti-patrón 2 — montar `/var/run/docker.sock` sin justificación: le da al container acceso directo al Docker daemon del host, permitiendo lanzar containers `--privileged` con acceso al filesystem raíz del host — rompe todo el aislamiento de namespaces/NetworkPolicy visto en Bloques 1 y 2.
- Anti-patrón 3 — dejar containers detenidos sin limpiar: además de ocupar disco, genera ruido que dificulta distinguir problemas reales actuales de basura acumulada al monitorear (ejemplo real propio: `nginx-proxy` y `juice-shop`, muertos por OOM hacía 2 semanas, encontrados en el inventario de cx-server). Usar `--rm` en containers descartables o limpieza periódica (`docker system prune`).

**Nota:** no se hizo práctica hands-on para este bloque — quedó cubierto solo a nivel conceptual, por decisión de Valen.

## Pendientes fuera del plan de refuerzo

- Prácticas Profesionales (PP1-PP5): no documentadas en el repo. Identificadas como gap en MEMORIA.md, sin contenido materializado. Pendiente de decisión sobre si se abordan como parte del curso o se dejan fuera del alcance de devops-curso.

---

Plan de refuerzo conceptual completo (Bloques 1-7). Próximo paso: avance oficial del curso (Módulo 5, Encuentro 24 — Build & Package Tools) o los pendientes sueltos documentados en "Pendientes fuera del plan de refuerzo" (Jenkins, Prácticas Profesionales).
