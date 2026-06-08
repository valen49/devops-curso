# Namespaces

## Key Concepts

Namespace is a logical partition inside a Kubernetes cluster. Every resource — pods, deployments, services, configmaps, secrets — lives inside a Namespace.

Namespaces do not provide network isolation by default. A pod in qa can communicate with a pod in production unless Network Policies are explicitly configured. Isolation is logical, not physical.

## Default Namespaces

default — where resources go if no Namespace is specified

kube-system — internal cluster components (apiserver, scheduler, etcd, coredns)

kube-public — public cluster information

kube-node-lease — node heartbeats

## Commands

kubectl get namespaces — list all Namespaces

kubectl apply -f namespaces.yaml — create Namespaces from manifest

kubectl get all -n qa — list all resources in a specific Namespace

kubectl get all --all-namespaces — list all resources across all Namespaces

kubectl create deployment nginx-demo --image=nginx:1.25 --replicas=1 -n qa — create a resource in a specific Namespace

kubectl delete deployment nginx-demo -n qa — delete a resource from a specific Namespace

kubectl delete -f namespaces.yaml — delete Namespaces defined in a manifest

## Key Observation

The same resource name can exist in multiple Namespaces without conflict. nginx-demo in qa and nginx-demo in production are completely independent resources. This is the foundation for promoting applications across environments in a real CI/CD flow.
