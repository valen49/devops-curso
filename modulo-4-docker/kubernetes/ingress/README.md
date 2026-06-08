# Ingress

## Key Concepts

Ingress is a Kubernetes object that acts as a reverse proxy — a single entry point that routes incoming traffic to different Services based on path or domain.

Without Ingress, each app needs its own NodePort (a fixed port between 30000-32767). With Ingress, all traffic enters through port 80 and is routed internally.

Ingress has two components:

Ingress Controller — the pod that actually processes traffic (nginx, traefik, haproxy). Without a Controller installed, the Ingress object does nothing.

Ingress — the YAML object that defines the routing rules. The Controller reads these rules and applies them automatically.

## Files

- apps.yaml — two Deployments (app-one, app-two) with their ClusterIP Services
- ingress.yaml — Ingress routing /app-one and /app-two to their respective Services

## Why Each Deployment Needs a Service

Ingress does not communicate with pods directly. It communicates with Services. Pods die and get new IPs; the Service IP stays fixed. Ingress routes to that stable IP.

## Key Annotations

nginx.ingress.kubernetes.io/rewrite-target: / — strips the path prefix before forwarding the request to the Service. Without this, /app-one would be forwarded as-is and the app would not recognize the path.

## Commands

kubectl apply -f apps.yaml — create both apps and their Services

kubectl apply -f ingress.yaml — create the Ingress rules

kubectl get ingress — list Ingress objects and their ADDRESS

curl http://<ADDRESS>/app-one — test routing to app-one

curl http://<ADDRESS>/app-two — test routing to app-two

kubectl delete -f . — delete all resources in the directory

## Observed Behavior

Both apps responded correctly through port 80 with path-based routing. The Ingress Controller assigned the host IP (192.168.68.117) as the ADDRESS since Minikube runs with --driver=none directly on the host.
