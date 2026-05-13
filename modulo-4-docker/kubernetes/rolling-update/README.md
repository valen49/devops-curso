# Rolling Updates and Rollbacks

Demonstrates zero-downtime deployments using Kubernetes Rolling Update strategy.

## Files

- `deployment.yaml` — nginx Deployment with 3 replicas

## Key Concepts

Rolling Update updates Pods gradually, maintaining availability throughout the process. Kubernetes creates new Pods with the new version before removing old ones.

Rollback reverts to a previous version using the ReplicaSet history Kubernetes keeps automatically.

## Rolling Update Strategy

The default strategy is 25% max unavailable and 25% max surge. maxUnavailable defines the maximum number of Pods that can be down during the update. maxSurge defines the maximum number of extra Pods Kubernetes can create above the desired count.

## Commands

kubectl apply -f deployment.yaml — apply the deployment

kubectl set image deployment/rolling-demo rolling-demo=nginx:1.25 — update image, triggers rolling update

kubectl get pods -w — watch Pods in real time

kubectl rollout status deployment/rolling-demo — check rollout status

kubectl rollout history deployment/rolling-demo — view revision history

kubectl rollout undo deployment/rolling-demo — rollback to previous version

kubectl rollout undo deployment/rolling-demo --to-revision=1 — rollback to specific revision

## Observed Behavior

The update process replaces Pods one by one. At no point were all Pods unavailable simultaneously. Each new Pod must be Running before the next old Pod is terminated.
