# Manifiestos — prácticas hands-on del plan de refuerzo conceptual

| Archivo | Bloque | Qué demuestra |
|---|---|---|
| `netpol-solo-backend.yaml` | Bloque 2 | NetworkPolicy que restringe el acceso al Pod db solo a Pods con label `tier: backend`, usado para confirmar bloqueo/permiso de tráfico con Calico. |
| `pod-readiness.yaml` | Bloque 4 | Pod con readiness probe que chequea la existencia de un archivo; usado para confirmar que un Pod no-Ready sale de los Endpoints de un Service sin reiniciarse. |
| `pod-liveness.yaml` | Bloque 4 | Mismo Pod pero con livenessProbe en vez de readinessProbe; usado para confirmar que Kubernetes mata y reinicia el container en CrashLoopBackOff cuando falla este tipo de probe (a diferencia de readiness). |
