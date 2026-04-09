# Module 3 — CI/CD

## Overview

This module covers Continuous Integration using three different tools,
all implemented in the weather-dashboard project.

## Tools

### GitHub Actions
Cloud-based CI runner provided by GitHub. Triggered on every push to any branch.
No infrastructure needed — GitHub manages the runners.

**Pipeline:** `.github/workflows/ci.yml`
- Job 1: Unit tests with pytest
- Job 2: E2E tests with Playwright (runs after unit tests pass)

### Jenkins
Self-hosted CI server running as a Docker container on a local Ubuntu server (cx-server).
Uses Docker agents — each stage spins up a fresh container and destroys it when done.

**Pipeline:** `Jenkinsfile`
- Stage 1: Checkout — clones the repository
- Stage 2: Unit tests — runs inside a `python:3.11` Docker container
- Stage 3: E2E tests — runs inside `mcr.microsoft.com/playwright/python:v1.58.0-noble`

### CircleCI
Cloud-based CI tool. Studied theoretically as part of the course.

## Key Concepts

- **CI (Continuous Integration):** automatically run tests on every code change
- **Pipeline:** sequence of stages that code goes through before being merged
- **Docker agent:** ephemeral container that runs a pipeline stage and is destroyed after
- **depends_on / needs:** define execution order between jobs or stages

## Infrastructure

- Jenkins runs on cx-server (Ubuntu 24.04, local network)
- Jenkins image: custom `jenkins-python` with Docker support
- Docker socket mounted to allow Jenkins to spin up Docker agents
- Portainer used for container management
- Nginx Proxy Manager for reverse proxy

## Known Technical Debt

- Node.js is installed on every E2E run in Jenkins (slow, should be baked into image)
- No webhook configured from GitHub to Jenkins (manual trigger only)
