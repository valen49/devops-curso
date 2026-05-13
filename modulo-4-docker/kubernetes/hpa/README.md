# Horizontal Pod Autoscaler (HPA)

Demonstrates automatic scaling based on CPU utilization.

## Files

- deployment.yaml — nginx Deployment with resource requests defined
- service.yaml — ClusterIP Service to expose the Deployment internally
- hpa.yaml — HPA configured to scale between 1 and 5 replicas at 50% CPU threshold

## Key Concepts

HPA monitors Pod metrics in real time and adjusts the number of replicas automatically. It requires the Metrics Server installed in the cluster and resource requests defined in the Deployment.

Scale up happens when average CPU exceeds the target utilization. Scale down happens after a cooldown period of 5 minutes by default, to avoid constant fluctuation.

## Commands

kubectl apply -f deployment.yaml — apply the deployment

kubectl apply -f service.yaml — apply the service

kubectl apply -f hpa.yaml — apply the HPA

kubectl get hpa -w — watch HPA metrics and replicas in real time

kubectl top pods — view current CPU and memory usage per Pod

kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://hpa-demo; done" — generate load to trigger scale up

kubectl delete pod load-generator — stop load generation

## Observed Behavior

At 0% CPU the HPA maintained 1 replica. When CPU reached 97% the HPA scaled to 2 replicas. After load stopped and CPU dropped to 0%, the HPA scaled back to 1 replica after the cooldown period.
