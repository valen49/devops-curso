# Demo — Deployment + Service básicos

## Key Concepts

Deployment con 2 réplicas de nginx, expuesto mediante un Service tipo NodePort.
Ejemplo base de los conceptos cubiertos en el README de Kubernetes I: labels y
selectors como mecanismo de acople entre Deployment y Service, y `apply` como
forma idempotente de crear/actualizar recursos.

`spec.selector.matchLabels` del Deployment y `spec.template.metadata.labels`
deben coincidir exactamente — si no coinciden, Kubernetes rechaza el YAML al
momento del `apply`. El Service usa su propio `spec.selector` (mismo valor de
label) para encontrar los Pods que crea el Deployment.

## Files

- `deployment.yaml` — Deployment `mi-nginx`, 2 réplicas, imagen `nginx`, label `app: mi-nginx`
- `service.yaml` — Service `mi-nginx`, tipo NodePort (puerto 30001), enruta a los Pods con label `app: mi-nginx`

## Commands

```bash
kubectl apply -f deployment.yaml   # crea el Deployment y sus 2 Pods
kubectl apply -f service.yaml      # crea el Service NodePort

kubectl get deployments            # ver el Deployment y sus réplicas
kubectl get pods -o wide           # ver los Pods creados, con IP y nodo
kubectl get services               # ver el Service y su NodePort asignado

kubectl delete -f service.yaml     # borra el Service
kubectl delete -f deployment.yaml  # borra el Deployment y sus Pods
```

## Observed Behavior

`kubectl apply -f deployment.yaml` crea 2 Pods con el label `app: mi-nginx`.
`kubectl apply -f service.yaml` crea un Service NodePort que expone el
puerto 80 de esos Pods en el puerto 30001 de cada nodo del cluster. Si se
edita el label de `template.metadata.labels` sin actualizar
`selector.matchLabels` (o viceversa), el `apply` del Deployment falla de
forma explícita en vez de crear un recurso inconsistente.
