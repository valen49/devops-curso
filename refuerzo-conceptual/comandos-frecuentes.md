# Comandos frecuentes — Bloques 1 y 2

> Este archivo no es para memorizar. Es una referencia de consulta rápida. La gramática general es: `<herramienta> <verbo: get/describe/delete/apply/run/exec> <qué> [-n namespace]`. Con eso entendido, el comando exacto se busca o se copia de acá — no hace falta tenerlo de memoria.

## Docker — inspección de containers
- `docker run -d --name X imagen` → crea y corre un container en background
- `docker inspect -f '{{.State.Pid}}' X` → PID del proceso principal del container, visto desde el HOST
- `docker exec X cat /proc/1/status` → ver status del proceso PID 1 desde ADENTRO del container (funciona aunque no haya `ps` instalado)
- `docker exec X ps -ef` → lista procesos desde adentro (ojo: no siempre está instalado, ej. en nginx oficial)
- `docker inspect X --format='{{.State.OOMKilled}}'` → confirma si el container murió por OOM Killer (true/false)
- `docker rm -f X` → borra un container a la fuerza, aunque esté corriendo

## Docker — límites de recursos
- `docker run -d --memory=50m imagen` → limita RAM del container vía cgroups

## Docker — volúmenes
- `docker run -d --name X -v /datos imagen` → volumen anónimo, Docker le asigna un ID sin ruta legible
- `docker run -d --name X -v /home/user/carpeta:/ruta/container imagen` → bind mount, conecta 1 a 1 una carpeta real del host (útil para hot-reload en desarrollo)
- `docker run -d --name X -v nombre-volumen:/ruta/container imagen` → volumen nombrado, identificable y reutilizable entre containers
- `docker exec X sh -c "comando"` → ejecuta un comando shell dentro de un container ya corriendo (útil para escribir/leer archivos de prueba)
- `docker volume ls` → lista todos los volúmenes existentes en el host
- `docker volume rm nombre-volumen` → borra un volumen (falla si algún container lo sigue usando)

## Kubernetes — básicos de consulta
- `kubectl get pods -n NAMESPACE -o wide` → lista pods con IP y nodo
- `kubectl describe pod X -n NAMESPACE` → detalle completo, incluye eventos (útil para ver OOMKilled, Exit Code, etc.)
- `kubectl get namespaces` → listar namespaces del cluster
- `kubectl create namespace X` → crear namespace nuevo
- `kubectl delete namespace X` → borra el namespace Y TODO lo que vive adentro (pods, policies, etc.)

## Kubernetes — pods de prueba rápidos
- `kubectl run NOMBRE --image=IMAGEN --labels="key=value" -n NAMESPACE -- comando` → crea un pod suelto con label, útil para pruebas (no usar así en producción, ahí van Deployments)
- `kubectl exec -n NAMESPACE POD -- comando` → ejecuta un comando dentro de un pod ya corriendo

## Kubernetes — NetworkPolicy
- `kubectl apply -f archivo.yaml` → aplica cualquier manifiesto (pod, networkpolicy, deployment, etc.)
- `kubectl get networkpolicy -n NAMESPACE` → lista policies activas en un namespace
- `kubectl describe networkpolicy X -n NAMESPACE` → detalle de qué permite/bloquea una policy

## Minikube — setup
- `minikube start --driver=docker --cni=calico` → levanta el cluster local con Calico (necesario para que NetworkPolicy funcione de verdad)
- `minikube delete` → borra el cluster/profile completo, para empezar de cero
