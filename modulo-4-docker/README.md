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
