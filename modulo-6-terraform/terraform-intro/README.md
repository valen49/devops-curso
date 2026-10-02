# Terraform I y II — Ciclo completo con provider local

## Objetivo

Practicar el ciclo completo de Terraform (`init` → `plan` → `apply` → `destroy`) sin depender de credenciales cloud, usando el provider `local`. Práctica introductoria antes de PP6 (Terraform/OpenTofu en AWS).

## Stack

- Terraform 1.16.5
- Provider `local` (hashicorp/local)

## Archivos

- `main.tf` — recurso `local_file.saludo`, genera `saludo.txt` con un mensaje parametrizado
- `variables.tf` — variable `nombre` (string, default `"Valen"`)
- `outputs.tf` — output `ruta_archivo`, expone la ruta del archivo generado

## Conceptos aplicados

- **Declarativo vs imperativo**: Terraform describe el estado final deseado (HCL declara *qué* tiene que existir); contrasta con nuestro propio `Jenkinsfile` (`practicas-profesionales/pp5/`), que es imperativo/secuencial — describe *cómo* y en qué orden ejecutar cada paso.
- **Providers como plugins por ecosistema**: cada provider (`local`, `aws`, `azurerm`, etc.) es un plugin que traduce el HCL genérico a llamadas concretas contra una API o sistema específico. Acá se usó `local` justamente para no depender de una cuenta cloud.
- **`terraform.tfstate` inspeccionado directamente**: se abrió el archivo de estado real tras el `apply` y se vio el `id` del recurso y los hashes ya resueltos — contraste directo con el `(known after apply)` que muestra el `plan` antes de ejecutar.
- **Los tres riesgos del estado local**: seguridad (el `.tfstate` puede contener valores sensibles en texto plano), concurrencia (dos personas aplicando al mismo tiempo sobre el mismo estado local corrompen el estado), pérdida de datos (si se borra el archivo local no hay forma de recuperar el estado real de la infraestructura).
- **Backends remotos (S3 + DynamoDB) como solución**: S3 almacena el estado de forma centralizada pero no resuelve concurrencia por sí solo; DynamoDB actúa como mecanismo de bloqueo/semáforo (lock) para que solo una operación de `apply` corra a la vez sobre el mismo estado.
- **HCL — bloques básicos**:
  - `resource` — crea infraestructura nueva (acá, `local_file.saludo`).
  - `variable` — parametriza valores, con `default` y override posible vía `-var`.
  - `output` — expone valores generados automáticamente tras el `apply`; mismo mecanismo conceptual que exponer la IP pública de una instancia EC2 en PP6.
  - `data` vs `resource` — `data` lee infraestructura ya existente (sin crearla ni gestionarla), `resource` crea y gestiona el ciclo de vida completo.

## Comandos

```bash
terraform init      # descarga el provider local, inicializa el working directory
terraform plan       # muestra el cambio a aplicar (local_file.saludo, known after apply)
terraform apply       # crea saludo.txt, escribe el estado en terraform.tfstate
terraform apply       # corrido de nuevo sin cambios en el .tf → "No changes" (idempotencia)
terraform apply -var="nombre=OtroNombre"   # override de variable en runtime
terraform destroy      # elimina saludo.txt y limpia el estado
```

## Resultados observados

- Ciclo completo `init` → `plan` → `apply` → `apply` (sin cambios, confirma idempotencia) → `destroy` funcionando end to end, sin errores.
- `saludo.txt` generado con el contenido esperado (`"Hola desde Terraform, Valen!"`).
- `terraform.tfstate` inspeccionado en cada etapa: con el recurso creado (id y atributos resueltos) y vacío tras el `destroy` confirmado.

## Decisión para el PIN

Se usará backend **S3 + DynamoDB real** (cuenta AWS free tier) en vez de estado local, para demostrar gestión de estado colaborativo de nivel profesional.
