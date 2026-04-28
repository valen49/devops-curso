# Kubernetes I — Introduction

## What is Kubernetes?

Kubernetes manages containers at scale across multiple machines.

- **Docker** → runs one container
- **Docker Compose** → runs multiple containers on one machine
- **Kubernetes** → manages containers across many machines

## Architecture

A Kubernetes cluster has two types of nodes:

**Control Plane** — the brain. Decides where to run pods, watches for failures, applies desired state.

**Worker Nodes** — the muscles. Run the actual pods. In production there are multiple workers; in Minikube there is one node that acts as both.

```
Control Plane
├── API Server      ← receives all kubectl commands
├── Scheduler       ← decides which node runs each pod
├── etcd            ← cluster state database
└── Controller      ← reconciliation loop (desired vs actual state)

Worker Node
├── kubelet         ← runs and monitors pods on this node
├── kube-proxy      ← handles network routing
└── container runtime (Docker, containerd)
```

## Key Concepts

**Node** — a machine (physical, virtual, or container) where Kubernetes runs pods.

**Pod** — the smallest unit in Kubernetes. One or more containers running together, sharing network and storage. Each pod gets its own IP inside the cluster.

**Deployment** — tells Kubernetes "always keep X replicas of this pod running". If one dies, Kubernetes creates another automatically. This is called self-healing.

**Service** — stable endpoint that exposes pods. Pods die and get new IPs; the Service IP stays fixed. Types:
- `ClusterIP` — only accessible inside the cluster (default)
- `NodePort` — accessible from the local network via a fixed port (30000–32767)
- `LoadBalancer` — for cloud environments, creates a public load balancer

**Labels and Selectors** — the glue between resources. A Deployment creates pods with labels; a Service uses a selector to find those pods.

```yaml
# Deployment stamps every pod with:
labels:
  app: mi-nginx

# Service targets pods matching:
selector:
  app: mi-nginx
```

If the label and selector don't match, the Service has no pods to route to.

## YAML Manifests

Working with YAML is the standard way to interact with Kubernetes. Every resource follows the same structure:

```yaml
apiVersion: apps/v1   # API group and version for this resource type
kind: Deployment      # resource type
metadata:
  name: mi-nginx      # name used by kubectl commands
spec:                 # desired state
  replicas: 2
  selector:
    matchLabels:
      app: mi-nginx   # must match template.metadata.labels
  template:           # pod template
    metadata:
      labels:
        app: mi-nginx
    spec:
      containers:
      - name: mi-nginx
        image: nginx
        ports:
        - containerPort: 80
```

Apply a manifest:
```bash
kubectl apply -f deployment.yaml   # create or update
kubectl delete -f deployment.yaml  # delete everything defined in the file
```

`apply` is idempotent — running it twice is safe. It compares the file against the current cluster state and only applies the diff.

The demo manifests for this module are in [demo/](demo/).

## Commands

```bash
# --- Cluster ---
kubectl get nodes                        # list nodes and their status
kubectl get all                          # overview of all resources in the namespace

# --- Pods ---
kubectl run my-pod --image=nginx         # create a standalone pod (not for production)
kubectl get pods                         # list running pods
kubectl get pods -o wide                 # include node and IP columns
kubectl describe pod my-pod             # full detail: events, conditions, env vars
kubectl logs my-pod                      # container stdout/stderr
kubectl logs my-pod -f                   # stream logs in real time
kubectl exec -it my-pod -- bash          # open a shell inside the container

# --- Deployments ---
kubectl create deployment my-nginx --image=nginx --replicas=2
kubectl get deployments
kubectl describe deployment my-nginx

# --- Services ---
kubectl expose pod my-pod --port=80 --type=NodePort
kubectl get services
kubectl port-forward pod/my-pod 8888:80  # forward local port to pod (dev only)

# --- Apply from YAML (recommended) ---
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl delete -f deployment.yaml

# --- Cleanup ---
kubectl delete pod my-pod
kubectl delete deployment my-nginx
kubectl delete service my-nginx
```

## Pod vs Deployment

| | Pod | Deployment |
|---|---|---|
| Dies | Gone forever | Kubernetes creates another |
| Deleted | Gone forever | Kubernetes creates another |
| Replicas | 1 | As many as you define |

In production, always use Deployments — never standalone Pods.

## Local Setup (Minikube)

Minikube simulates a Kubernetes cluster using Docker on a single machine.
In production, a cluster has multiple worker nodes across different servers.

```bash
minikube start          # start the cluster
minikube status         # check it's running
minikube ip             # get the cluster IP (needed for NodePort access)
minikube stop           # stop the cluster
minikube delete         # delete the cluster entirely
```

## Real World Example

The New York Times runs almost 100% of their customer-facing apps on Kubernetes (GKE).
Deployments that used to take 45 minutes now take seconds.
Each team has their own cluster and deploys independently, daily.
