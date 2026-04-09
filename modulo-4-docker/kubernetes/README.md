# Kubernetes — Introduction

## What is Kubernetes?

Kubernetes manages containers at scale across multiple machines.

- **Docker** → runs one container
- **Docker Compose** → runs multiple containers on one machine
- **Kubernetes** → manages containers across many machines

## Key Concepts

**Node** — a machine (physical, virtual, or container) where Kubernetes runs pods.

**Pod** — the smallest unit in Kubernetes. One or more containers running together.

**Deployment** — tells Kubernetes "always keep X replicas of this pod running". If one dies, Kubernetes creates another automatically. This is called self-healing.

**Service** — exposes a pod to the outside world. Types:
- ClusterIP: only accessible inside the cluster
- NodePort: accessible from the local network
- LoadBalancer: for cloud environments, creates a public load balancer

## Commands

```bash
# Check cluster nodes
kubectl get nodes

# Run a pod
kubectl run my-pod --image=nginx

# List pods
kubectl get pods

# Create a deployment with replicas
kubectl create deployment my-nginx --image=nginx --replicas=2

# List deployments
kubectl get deployments

# Expose a pod
kubectl expose pod my-pod --port=80 --type=NodePort

# List services
kubectl get services

# Forward a local port to a pod
kubectl port-forward pod/my-pod 8888:80

# Delete a pod
kubectl delete pod my-pod

# Delete a deployment
kubectl delete deployment my-nginx
```

## Pod vs Deployment

| | Pod | Deployment |
|---|---|---|
| Dies | Gone forever | Kubernetes creates another |
| Deleted | Gone forever | Kubernetes creates another |
| Replicas | 1 | As many as you define |

In production, always use Deployments — never standalone Pods.

## Real World Example

The New York Times runs almost 100% of their customer-facing apps on Kubernetes (GKE).
Deployments that used to take 45 minutes now take seconds.
Each team has their own cluster and deploys independently, daily.

## Local Setup (Minikube)

Minikube simulates a Kubernetes cluster using Docker on a single machine.
In production, a cluster has multiple worker nodes across different servers.
