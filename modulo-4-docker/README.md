# Module 4 — Docker

## Key Concepts

- **Image**: static recipe that defines the environment
- **Container**: running instance of an image
- **Dockerfile**: file with instructions to build an image
- **Volume**: mapping between a host folder and a container folder to persist data

## Basic Dockerfile

```dockerfile
FROM python:3.11-slim    # base image
WORKDIR /app             # working directory inside the container
COPY app.py .            # copy file from host to container
CMD ["python", "app.py"] # command executed when the container starts
```

## Commands

```bash
# Build an image
docker build -t image-name .

# Run a container
docker run image-name

# Run with interactive terminal
docker run -it image-name bash

# Pass environment variable
docker run -e VARIABLE=value image-name

# Mount a volume
docker run -v ~/host-folder:/container-folder image-name

# Show active containers
docker ps

# Show all containers (including stopped)
docker ps -a

# Show local images
docker images

# Remove stopped containers
docker rm $(docker ps -aq --filter status=exited)
```

## Important Notes

- A container lives as long as it has a running process
- Data inside a container is lost when it dies — use volumes to persist it
- The prompt `root@ID:/` means you are inside a container
- Dockerfile layers are cached — if an instruction hasn't changed, Docker reuses it
- Never mount `/:/host` in production — it gives full access to the host filesystem

## Docker Networks

Containers communicate with each other through Docker networks.

**Default networks:**
- `bridge` — default network, containers communicate by IP only
- `host` — container shares host network directly, no isolation
- `none` — no network access

**Custom bridge network (recommended):**
Containers on the same custom bridge network can communicate by name, not just IP. This is how `app` connects to `db` in Docker Compose.

```bash
# Create a network
docker network create my-network

# Run containers on the same network
docker run -d --name app --network my-network myapp
docker run -d --name db --network my-network mydb

# app can reach db by name
docker exec app ping -c 3 db

# Cleanup
docker network rm my-network
```

**Useful commands:**
```bash
docker network ls                        # list networks
docker network inspect <network>         # inspect network details
docker network connect <network> <container>   # connect container to network
docker network disconnect <network> <container> # disconnect
```

## Docker Hub

Public registry for Docker images. The GitHub of container images.

**Workflow:**
```bash
# Build with your Docker Hub username as prefix
docker build -t username/image-name:tag .

# Login
docker login

# Push to Docker Hub
docker push username/image-name:tag

# Pull from anywhere
docker pull username/image-name:tag
```

**Key concept:** Image names follow the format `username/image-name:tag`.
Official images (nginx, python, etc.) omit the username prefix.
