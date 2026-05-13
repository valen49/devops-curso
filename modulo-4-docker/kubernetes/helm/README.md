# Helm

Helm is the package manager for Kubernetes. It simplifies the deployment and management of applications by bundling all Kubernetes manifests into a single reusable package called a Chart.

## Key Concepts

Chart is the Helm package. It contains all the Kubernetes manifests organized with a standard structure and parameterized with variables.

Values is a single values.yaml file that centralizes all configurable parameters. A change in one value propagates automatically to all templates.

Template is a Kubernetes manifest that uses variables instead of hardcoded values, referencing entries from values.yaml.

Release is an installation of a Chart in the cluster. The same Chart can be installed multiple times with different values, for example one release for QA and another for production.

## Chart Structure

Chart.yaml — chart metadata: name, version, description

values.yaml — default values for all configurable parameters

templates/ — Kubernetes manifests with variables

## Commands

helm create nginx-demo — generate a Chart with standard structure

helm install mi-nginx ./nginx-demo — install a release named mi-nginx from a local chart

helm upgrade mi-nginx ./nginx-demo --set replicaCount=3 — upgrade a release changing a value without editing any YAML

helm history mi-nginx — view revision history of a release

helm rollback mi-nginx 1 — rollback to a specific revision

helm uninstall mi-nginx — remove a release and all its resources from the cluster

## Observed Behavior

A single helm install command created a Deployment, Service, ReplicaSet and Pod automatically. Scaling from 1 to 3 replicas required only --set replicaCount=3 with no YAML changes. Rollback to revision 1 reduced replicas back to 1 immediately.
