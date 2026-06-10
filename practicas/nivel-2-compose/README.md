# Nivel 2 — Docker Compose con base de datos

## Objetivo

Orquestar dos servicios con Docker Compose — una base de datos PostgreSQL y una UI web para gestionarla — aplicando persistencia de datos con volúmenes.

## Stack

- postgres:15 — base de datos relacional
- adminer — UI web para gestionar PostgreSQL

## Archivos

- docker-compose.yml — define ambos servicios, volumen y red

## Conceptos aplicados

- Imágenes oficiales de Docker Hub sin Dockerfile propio
- Variables de entorno para configurar postgres (POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD)
- Volumen persistente: los datos sobreviven al ciclo docker compose down / up
- depends_on: adminer espera a que postgres esté corriendo antes de arrancar
- Comunicación entre servicios por nombre: adminer se conecta a postgres usando "postgres" como hostname

## Comandos

docker compose up -d — levantar ambos servicios en background

docker compose down — bajar los servicios (el volumen persiste)

docker compose down -v — bajar los servicios y eliminar el volumen

## Acceso

Adminer: http://192.168.68.117:8083
Servidor: postgres
Usuario: admin
Contraseña: secret
Base de datos: mi-base

## Verificación de persistencia

Crear una tabla en adminer, ejecutar docker compose down y docker compose up -d, volver a entrar al adminer y verificar que la tabla sigue existiendo.
