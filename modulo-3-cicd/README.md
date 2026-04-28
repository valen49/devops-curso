# Module 3 — CI/CD

## Overview

This module covers Continuous Integration using three different tools,
all implemented in the weather-dashboard project, plus a dedicated Java/Maven
app to practice Jenkins pipelines with AWS S3 artifact publishing.

## Tools

### GitHub Actions
Cloud-based CI runner provided by GitHub. Triggered on every push to any branch.
No infrastructure needed — GitHub manages the runners.

**Pipeline:** `github-actions/ci.yml`
- Job 1: Unit tests with pytest
- Job 2: E2E tests with Playwright (runs after unit tests pass)

### Jenkins
Self-hosted CI server running as a Docker container on a local Ubuntu server (cx-server).
Uses Docker agents — each stage spins up a fresh container and destroys it when done.

**Weather-dashboard pipeline:** `jenkins/Jenkinsfile`
- Stage 1: Checkout
- Stage 2: Unit tests — `python:3.11` container
- Stage 3: E2E tests — `mcr.microsoft.com/playwright/python:v1.58.0-noble` container

**Java/Maven pipeline:** `jenkins/java-maven-app/Jenkinsfile`
- Stage 1: Checkout
- Stage 2: Build & Test — `maven:3.9-eclipse-temurin-17` container
- Stage 3: Package — generates JAR artifact, stashed for next stage
- Stage 4: Publish to S3 — `amazon/aws-cli` container, unstashes and uploads JAR

**Webhook:** `jenkins/webhooks.md`
- GitHub → ngrok tunnel → Jenkins
- Triggers pipeline automatically on every push

### GitLab CI
Cloud-based CI tool integrated into GitLab. Configured via a single `.gitlab-ci.yml` file at the repo root. GitLab manages the runners — no external infrastructure needed for the basics.

**Pipeline:** `gitlab-ci/.gitlab-ci.yml`
- Stage 1: build — creates `dist/` artifact and passes it to the next stage
- Stage 2: test — verifies output, runs after build completes
- Stage 3: deploy — runs only on `main` branch

**Key differences vs GitHub Actions:**

| | GitHub Actions | GitLab CI |
|---|---|---|
| Config file | `.github/workflows/*.yml` | `.gitlab-ci.yml` (repo root) |
| Job order | `needs:` between jobs | `stages:` list defines order |
| Pass files between jobs | `upload-artifact` + `download-artifact` | `artifacts: paths:` (automatic) |
| Branch filtering | `on: push: branches:` | `only:` / `rules:` per job |
| Runner declaration | `runs-on:` | `image:` (Docker) or `tags:` (self-hosted) |

### CircleCI
Cloud-based CI tool. Studied theoretically as part of the course.

## Key Concepts

- **CI (Continuous Integration):** automatically run tests on every code change
- **Pipeline:** sequence of stages that code goes through before being merged
- **Docker agent:** ephemeral container that runs a pipeline stage and is destroyed after
- **agent none:** each stage defines its own Docker agent independently
- **stash/unstash:** mechanism to pass files between stages running in different containers
- **Webhook:** HTTP POST sent by GitHub to trigger Jenkins automatically on push
- **ngrok:** tunneling tool that exposes a local Jenkins instance to the internet

## Pipeline Types (Jenkins)

| Type | Definition | Versionable | Flexibility |
|------|-----------|-------------|-------------|
| Freestyle | UI form | No | Low |
| Scripted | Groovy `node {}` | Yes | High |
| Declarative | Groovy `pipeline {}` | Yes | Medium |

Declarative is the current industry standard.

## Infrastructure

- Jenkins runs on cx-server (Ubuntu 24.04, local network)
- Jenkins image: custom `jenkins-python` with Docker support
- Docker socket mounted to allow Jenkins to spin up Docker agents
- Portainer used for container management
- Nginx Proxy Manager for reverse proxy
- ngrok used for webhook tunneling (free plan — URL changes on restart)

## AWS

- IAM user: `devops-valen`
- S3 bucket used for artifact storage (Jenkins II practice — deleted after use)
- Credentials stored in Jenkins as Secret Text

## Known Technical Debt

- Node.js is installed on every E2E run in Jenkins (slow, should be baked into image)
- Prometheus Plugin pending (Jenkins II — last topic)

## Prometheus Plugin

Jenkins exposes metrics at `/prometheus` endpoint, scraped by Prometheus and visualized in Grafana.

**Installation:** Manage Jenkins → Plugins → Available → Prometheus Metrics

**Endpoint:** `http://<jenkins-url>:8080/prometheus`

**Key metrics exposed:**
- `default_jenkins_builds_health_score` — health score per job (0-100)
- `default_jenkins_builds_last_build_duration_milliseconds` — last build duration per job
- `default_jenkins_builds_last_stage_duration_milliseconds_summary` — duration per stage
- `jenkins_queue_size_value` — number of builds waiting in queue
- `jenkins_executor_in_use_value` — executors currently busy

**Note:** Full Prometheus + Grafana integration covered in Module 8.
