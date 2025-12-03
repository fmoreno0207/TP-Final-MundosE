# Trabajo Final Diplmatura DevOps  
## Deploy de aplicación Next.js + Grafana + Prometheus en AWS ECS con Terraform y CI/CD GitHub Actions  
**Autor:** Fernando Moreno y Mariano 

---

## 0. Inicialización del Backend de Terraform (S3 + DynamoDB)

Antes de crear cualquier recurso en AWS (VPC, ECS, ECR, etc.) es necesario configurar
el backend remoto de Terraform para almacenar el estado (`terraform.tfstate`) de forma
segura y centralizada.

### ¿Por qué es necesario un backend remoto?

Terraform guarda el estado de la infraestructura (qué existe, qué cambió, qué debe
actualizarse). Guardarlo localmente es inseguro y rompe un pipeline CI/CD.

Usar un backend remoto permite:

- Almacenar el estado en S3 (seguro y duradero)
- Evitar corrupción del estado
- Permitir CI/CD sin problemas
- Soportar trabajos colaborativos
- Hacer locking del estado con DynamoDB

### Estructura utilizada

El backend se crea en esta carpeta:

```
terraform/backend-bootstrap/
```

Incluye:

- main.tf
- provider.tf
- variables.tf

Este módulo crea:

1. Un bucket S3 para guardar el estado (`tfstate`)
2. Una tabla DynamoDB para el bloqueo del estado
3. Versionado habilitado en el bucket
4. Encriptación SSE-S3

### Comandos para inicializar el backend

1. Ubicarse en la carpeta:

```
cd terraform/backend-bootstrap
```

2. Inicializar e implementar el backend:

```
terraform init
terraform apply
```

3. Copiar los valores generados en:

```
terraform/ecs-deploy/backend.tf
```

Ejemplo:

```
terraform {
  backend "s3" {
    bucket         = "nombre-bucket-tfstate"
    key            = "ecs-deploy/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "nombre-tabla-lock"
    encrypt        = true
  }
}
```

---

## 1. Introducción

Este proyecto implementa:

- Infraestructura como código (Terraform)  
- Pipeline CI/CD con GitHub Actions  
- Contenedores desplegados en AWS ECS Fargate  
- Registro de imágenes en Amazon ECR  
- Observabilidad mediante Prometheus y Grafana  
- Análisis de seguridad con ESLint y Snyk  
- Generación de SBOM (CycloneDX)

El despliegue se realiza automáticamente ante un push a la rama `main`.

---

## 2. Arquitectura del Proyecto

```
                   ┌────────────────────────┐
                   │      GitHub Repo        │
                   └───────────┬────────────┘
                               │ push/main
                               ▼
                   ┌────────────────────────┐
                   │     GitHub Actions      │
                   │  - ESLint               │
                   │  - Snyk                 │
                   │  - SBOM                 │
                   │  - Docker Build         │
                   │  - Deploy ECS           │
                   └───────────┬────────────┘
                               │
                               ▼
                  ┌─────────────────────────┐
                  │   Amazon ECR Registry    │
                  └───────────┬─────────────┘
                              │
                              ▼
         ┌─────────────────────────────────────────────┐
         │                 AWS ECS Fargate             │
         │  - Frontend (Next.js)                       │
         │  - Grafana                                  │
         │  - Prometheus                               │
         └──────────────────────────┬──────────────────┘
                                    │
                                    ▼
                         ┌──────────────────┐
                         │ CloudWatch Logs  │
                         └──────────────────┘
```

---

## 3. Tecnologías Utilizadas

### Infraestructura  
- AWS ECS Fargate  
- AWS ECR  
- AWS VPC, Subnets, Security Groups  
- AWS IAM Roles  
- Terraform  

### Aplicación  
- Next.js 14  
- React 18  
- TailwindCSS  

### Observabilidad  
- Grafana  
- Prometheus  

### Seguridad  
- ESLint  
- Snyk  
- SBOM CycloneDX  

---

## 4. Infraestructura con Terraform

Todo el código se encuentra en:

```
terraform/ecs-deploy/
```

Componentes:

- VPC / Subnets  
- Security Groups  
- Repositorios ECR  
- Cluster ECS  
- Servicios ECS  
- Task Definitions  
- Roles IAM  

### Comandos principales

```
terraform init
terraform apply
```

---

## 5. CI/CD con GitHub Actions

El pipeline ejecuta:

1. Detección de cambios por carpetas  
2. ESLint (solo si hay cambios en el frontend)  
3. Snyk (npm + imágenes Docker)  
4. Generación de SBOM  
5. Build & Push a ECR  
6. Redeploy automático en ECS  

Ejemplo comando usado por el pipeline:

```
aws ecs update-service --cluster <name> --service <name> --force-new-deployment
```

---

## 6. Seguridad (ESLint + Snyk + SBOM)

### 6.1 ESLint

Corre análisis estático del código:

```
npm run lint
```

### 6.2 Snyk – Dependencias

```
snyk test --severity-threshold=high
```

### 6.3 Snyk – Docker

```
snyk test --docker image:latest --severity-threshold=high
```

### 6.4 SBOM CycloneDX

```
npx @cyclonedx/cyclonedx-npm -o sbom.json
```

---

## 7. Monitoring – Prometheus & Grafana

Prometheus:

- Scrapea métricas de Next.js  

Grafana:

- Dashboards preconfigurados en `monitoring/grafana/provisioning`

---

## 8. Capturas Requeridas

- Pipeline ejecutándose  
- Servicios en ECS  
- Repositorios en ECR  
- Dashboard de Grafana  
- Archivo SBOM generado  

---

## 9. Costos Aproximados

| Servicio | Costo estimado |
|---------|-----------------|
| ECS Fargate | 5–9 USD |
| ECR | 0.10 USD/GB |
| CloudWatch Logs | 0.50–1 USD |
| Total | 6–12 USD |

---

## 10. Ejecución del Proyecto

### 1. Inicializar backend

```
cd terraform/backend-bootstrap
terraform apply
```

### 2. Provisionar infraestructura ECS

```
cd terraform/ecs-deploy
terraform init
terraform apply
```

### 3. Ejecutar CI/CD (push a main)

```
git add .
git commit -m "deploy"
git push
```

### 4. Acceso a la aplicación

Obtener URL del Load Balancer:

```
terraform output
```

---

## 11. capturas 
![Grafana](Scree-grafana.png)
![Prometheus](Screeen-prometheus.png)

