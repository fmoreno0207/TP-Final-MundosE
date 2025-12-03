Trabajo Final MundosE
Deploy de aplicación Next.js + Grafana + Prometheus en AWS ECS con Terraform y CI/CD GitHub Actions

Autor: Fernando Moreno

1. Introducción

Este proyecto implementa:

Infraestructura como código (Terraform)

Pipelines de CI/CD con GitHub Actions

Contenedores desplegados en AWS ECS Fargate

Registro de imágenes en Amazon ECR

Observabilidad mediante Prometheus y Grafana

Escaneo de seguridad con ESLint, Snyk y generación de SBOM

El despliegue se realiza automáticamente ante un push en la rama main.

2. Arquitectura del Proyecto
                         +----------------------+
                         |     GitHub Repo      |
                         +----------+-----------+
                                    |
                                    | push/main
                                    v
                          +-----------------------+
                          |     GitHub Actions    |
                          |  - ESLint             |
                          |  - Snyk               |
                          |  - SBOM               |
                          |  - Docker Build       |
                          |  - ECS Deploy         |
                          +----------+------------+
                                    |
                                    v
                         +--------------------------+
                         |    Amazon ECR Registry   |
                         +-----------+--------------+
                                     |
                                     v
                           +---------------------+
                           |   AWS ECS Fargate   |
                           | - Frontend (Next)   |
                           | - Grafana           |
                           | - Prometheus        |
                           +-----------+---------+
                                       |
                                       v
                           +---------------------+
                           |   CloudWatch Logs   |
                           +---------------------+
3. Tecnologías Utilizadas
Infraestructura

AWS ECS Fargate

AWS ECR

AWS VPC + Subnets + Security Groups

AWS IAM Roles

Terraform

Aplicación

Next.js 14

React 18

TailwindCSS

Observabilidad

Grafana (dashboard personalizado)

Prometheus (scraping + métricas personalizadas)

Seguridad

ESLint

Snyk (dependencias + Docker)

SBOM CycloneDX

DevOps

GitHub Actions

Docker Buildx

4. Infraestructura – Terraform

La infraestructura se encuentra en:

terraform/ecs-deploy/


Incluye:

VPC

Subredes

Security Groups

Repositorios ECR

ECS Cluster

ECS Services (Frontend, Grafana, Prometheus)

Task Definitions

Roles IAM

Variables y outputs

Comandos principales
terraform init
terraform apply


Salida esperada: URL pública del Load Balancer y nombres de servicios ECS.

5. Pipeline CI/CD – GitHub Actions

El pipeline ejecuta:

Detección de cambios por carpeta

ESLint (solo si hay cambios en frontend)

Snyk (dependencias y Docker)

Generación de SBOM

Build & Push a ECR

Deploy automático en ECS via update-service

Ejemplo del comando de redeploy:

aws ecs update-service --cluster x --service y --force-new-deployment

6. Seguridad – ESLint, Snyk, SBOM
ESLint

Analiza el código del frontend:

npm run lint


Se ejecuta automáticamente en el pipeline solo cuando hay cambios.

Snyk

Escanea dependencias npm:

snyk test --severity-threshold=high


Escanea la imagen Docker:

snyk test --docker image:latest --severity-threshold=high


En CI/CD se usa:

|| true


para evitar que el pipeline falle por vulnerabilidades externas no corregibles.

SBOM (CycloneDX)

Se genera con:

npx cyclonedx-bom -o sbom.json


El pipeline guarda el SBOM como artefacto descargable.

7. Monitoring – Grafana y Prometheus

Prometheus:

Expone métricas desde /api/metrics (Next.js)

Scrapea targets definidos en prometheus.yml

Grafana:

Se despliega como servicio ECS independiente

Incluye dashboards preconfigurados (JSON en monitoring/grafana/provisioning)

8. Capturas Requeridas

Agregar estas capturas en la entrega final:

8.1 Pipeline corriendo
[Imagen del workflow ejecutándose]

8.2 Servicios en ECS
[Imagen del cluster ECS y tareas]

8.3 Repositorios ECR
[Imagen mostrando imágenes latest]

8.4 Dashboard en Grafana
[Imagen del dashboard de métricas]

8.5 SBOM generado
[Imagen mostrando sbom.json]

9. Costos Aproximados en AWS

| Servicio              | Costo estimado mensual |
| --------------------- | ---------------------- |
| ECS Fargate (3 tasks) | 5–9 USD                |
| ECR                   | 0.10 USD por GB        |
| CloudWatch Logs       | 0.50–1 USD             |
| VPC / SG              | Sin costo              |
| Total                 | 6–12 USD               |

10. Cómo Ejecutar el Proyecto
1. Provisionar infraestructura
cd terraform/ecs-deploy
terraform init
terraform apply

2. Push a la rama main

GitHub Actions:

Construye imágenes

Corre ESLint

Corre Snyk

Genera SBOM

Publica imágenes

Actualiza ECS

3. Ver aplicación

Abrir la URL pública del Load Balancer (output de Terraform).

11. Contribuciones

Las mejoras y pull requests son bienvenidas.

12. Licencia

Trabajo práctico educativo para MundosE.