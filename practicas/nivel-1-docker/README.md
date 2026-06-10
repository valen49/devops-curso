# Nivel 1 — Docker

## Objetivo

Construir una imagen Docker propia basada en nginx:alpine, servirla con Docker Compose y aplicar buenas prácticas básicas.

## Stack

- nginx:alpine — servidor web, imagen minimal
- Docker Compose — orquestación local

## Archivos

- Dockerfile — construye la imagen copiando index.html en nginx
- index.html — contenido estático servido por nginx
- docker-compose.yml — define el servicio, puertos y política de reinicio

## Conceptos aplicados

- Imagen minimal: nginx:alpine en vez de nginx full (62MB vs 190MB)
- build: . en Compose para construir imagen propia desde Dockerfile
- restart: unless-stopped para reinicio automático ante fallos
- Mapeo de puertos host:contenedor (8082:80)

## Comandos

docker build -t mi-app:v1 . — construir la imagen manualmente

docker compose up -d — levantar el servicio en background

docker compose down — bajar el servicio

curl http://localhost:8082 — verificar que sirve contenido
