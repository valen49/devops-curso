# Jenkins Webhooks with ngrok

## Problem
Jenkins runs on a local network and is not accessible from the internet.
GitHub cannot reach Jenkins directly from the outside.

## Solution: ngrok
ngrok creates a tunnel from your local machine to the internet.

Flow:
GitHub → https://<ngrok-url> → tunnel → localhost:8080 (Jenkins)

Key concept:
The connection is initiated from inside (your machine outward),
so the router doesn't block it. Similar principle to a reverse shell, but legitimate.

## Setup

### 1. Install ngrok
snap install ngrok
ngrok config add-authtoken YOUR_TOKEN

### 2. Start the tunnel
ngrok http 8080

### 3. Configure Jenkins
Manage Jenkins → Security → CSRF Protection → Enable proxy compatibility

Job → Configure → Build Triggers:
- GitHub hook trigger for GITScm polling

### 4. Configure GitHub webhook
Settings → Webhooks → Add webhook

- Payload URL: https://<ngrok-url>/github-webhook/
- Content type: application/json
- Events: Just the push event

## Limitation
On the free plan, the ngrok URL changes every time you restart it.

For production:
- Use polling, or
- Deploy Jenkins on a server with a public IP

## Result
push → GitHub → ngrok → Jenkins → pipeline starts automatically
