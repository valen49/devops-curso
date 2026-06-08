# ConfigMaps and Secrets

## Key Concepts

ConfigMap stores non-sensitive configuration as key-value pairs, decoupled from the application code. This allows changing the app behavior without rebuilding the image.

Secret stores sensitive data such as passwords and API keys. Values are Base64-encoded, not encrypted. Security depends on cluster access control, not on the Secret object itself.

## Files

- configmap.yaml — ConfigMap with environment, API URL and log level
- secret.yaml — Secret with database password and API key
- deployment.yaml — Deployment consuming both ConfigMap and Secret via envFrom

## Key Difference

| | ConfigMap | Secret |
|---|---|---|
| Data | Non-sensitive | Sensitive |
| Storage | Plain text | Base64 |
| Use case | URLs, env names, flags | Passwords, tokens, keys |

## Commands

kubectl apply -f configmap.yaml — create the ConfigMap

kubectl apply -f secret.yaml — create the Secret

kubectl apply -f deployment.yaml — create the Deployment

kubectl exec -it <pod> -- env — verify environment variables inside the pod

kubectl get secret app-secret -o jsonpath='{.data.DB_PASSWORD}' | base64 -d — decode a Secret value

kubectl delete -f . — delete all resources in the directory

## Key Observation

Base64 is encoding, not encryption. Any user with cluster access can decode a Secret value with a single command. In production, Secrets are complemented with tools like HashiCorp Vault or etcd encryption at rest.
