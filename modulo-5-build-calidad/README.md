# Módulo 5 — Build & Package Tools, Harbor, Calidad

## Encuentros

- [x] Encuentro 24 — Build & Package Manager Tools
- [x] Encuentro 25 — Harbor
- [x] Encuentro 26 — Calidad
- [ ] Encuentro 27 — Práctica Profesional 5

## Encuentro 24 — Build & Package Manager Tools

**Nota:** este encuentro resultó más denso de digerir que el resto del módulo. Quedó cubierto a nivel conceptual, pero sin la misma solidez que Harbor o Calidad — candidato a repaso si hace falta más adelante.

### Key Concepts

- **Build vs empaquetado vs publicación**: tres pasos distintos del ciclo de vida de un artefacto — compilar/generar el artefacto, empaquetarlo en un formato distribuible, y publicarlo en un repositorio accesible para otros.
- **SemVer**: versionado semántico (`MAJOR.MINOR.PATCH`) como convención para comunicar el impacto de un cambio.
- **Lockfiles**: archivo que fija las versiones exactas de dependencias resueltas, para builds reproducibles.
- **SBOM y licencias**: Software Bill of Materials — inventario de todos los componentes (y sus licencias) que integran un artefacto.
- **Firmas (Sigstore/cosign)**: mecanismo de firma criptográfica de artefactos para verificar autenticidad e integridad.
- **SLSA**: framework de niveles de madurez para la seguridad de la cadena de suministro de software (supply chain).
- **Repositorios de artefactos**: almacenamiento centralizado y versionado de artefactos generados (paquetes, imágenes, librerías).
- **Promoción sin rebuild**: mover un mismo artefacto ya construido entre entornos (ej. QA → producción) sin reconstruirlo, para garantizar que lo que se probó es exactamente lo que se despliega.

## Encuentro 25 — Harbor

### Key Concepts

- **Registro privado de imágenes con gobernanza**: Harbor organiza imágenes en proyectos, con RBAC (control de acceso basado en roles) y escaneo de vulnerabilidades con umbrales configurables que pueden bloquear imágenes inseguras.
- **Arquitectura en Kubernetes**: Harbor se compone de varios servicios — Core/API (lógica y API principal), Registry (almacenamiento de imágenes), Jobservice (tareas asíncronas como escaneo y replicación), DB y Redis (estado y cache).
- **Replicación vs proxy cache**: replicación copia imágenes activamente entre instancias de Harbor (o hacia/desde otro registro); proxy cache actúa como intermediario que cachea imágenes de un registro externo (ej. Docker Hub) bajo demanda, sin duplicar todo el contenido de antemano.
- **Promoción por digest**: promover imágenes entre entornos usando el digest (`@sha256:...`), no el tag, para garantizar inmutabilidad — el mismo principio ya visto en el Bloque 7 del plan de refuerzo conceptual, aplicado acá al flujo de Harbor.

## Encuentro 26 — Calidad

### Key Concepts

- **QA vs QC**: QA (Quality Assurance) es el proceso que previene defectos (cómo se construye); QC (Quality Control) es la verificación del producto ya construido (encontrar defectos).
- **Calidad como código**: los quality gates (umbrales de calidad que un cambio debe pasar) se versionan en el propio repo, igual que cualquier otro artefacto de configuración — no viven como criterio informal o manual.
- **Análisis estático y deuda técnica**: el análisis estático de código detecta code smells; la deuda técnica se puede tratar como métrica objetiva y medible en el tiempo, no como juicio subjetivo.
- **SCA vs SAST vs DAST**: SCA (Software Composition Analysis) analiza dependencias de terceros; SAST (Static Application Security Testing) analiza el código fuente propio sin ejecutarlo; DAST (Dynamic Application Security Testing) analiza la aplicación en ejecución.
- **4 tipos de pruebas de rendimiento**: carga (comportamiento bajo tráfico esperado), estrés (comportamiento en el límite y más allá), picos/spike (comportamiento ante subas abruptas de tráfico), soak/endurance (comportamiento sostenido en el tiempo, detecta problemas como memory leaks).

## Encuentro 27 — Práctica Profesional 5

Pendiente, no arrancado.
