# Trabajo Final MundosE  
## Deploy Profesional de Aplicación Next.js + Grafana + Prometheus en AWS ECS/Fargate con Terraform y CI/CD GitHub Actions  
**Autor:** Fernando Moreno  

---

# 0. Backend Remoto de Terraform (S3 + DynamoDB)

Antes de desplegar cualquier recurso en AWS, se configura un **backend remoto** donde Terraform guardará su estado (`terraform.tfstate`) evitando corrupción, habilitando CI/CD y permitiendo locking para evitar ejecuciones simultáneas.

Ubicación del módulo:

```
terraform/backend-bootstrap/
```

El módulo crea:

- Bucket S3 con versionado  
- Tabla DynamoDB para locking  
- Encriptación SSE-S3  

### Inicialización

```bash
cd terraform/backend-bootstrap
terraform init
terraform apply
```

Luego el archivo `terraform/ecs-deploy/backend.tf` debe configurarse así:

```hcl
terraform {
  backend "s3" {
    bucket         = "nombre-del-bucket"
    key            = "ecs-deploy/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "nombre-tabla-lock"
    encrypt        = true
  }
}
```

---

# 1. Introducción

Este trabajo implementa un **entorno de despliegue profesional** compuesto por:

- Infraestructura como código (Terraform)  
- Pipeline CI/CD automatizado en GitHub Actions  
- Contenedores Docker ejecutándose en AWS ECS Fargate  
- Registro de imágenes en ECR  
- Observabilidad completa con Prometheus + Grafana  
- Seguridad mediante ESLint, Snyk y SBOM (CycloneDX)  
- Deploy automático ante cambios detectados

El entorno está diseñado siguiendo buenas prácticas de DevOps y Cloud Engineering.

---

# 2. Arquitectura General del Proyecto

```
                          ┌──────────────────────────┐
                          │        GitHub Repo        │
                          └─────────────┬─────────────┘
                                        │ push/main
                                        ▼
                          ┌──────────────────────────┐
                          │      GitHub Actions       │
                          │  - ESLint                 │
                          │  - Snyk NPM + Docker      │
                          │  - SBOM (CycloneDX)       │
                          │  - Docker Build & Push    │
                          │  - ECS Deployment         │
                          └─────────────┬─────────────┘
                                        │
                                        ▼
                          ┌──────────────────────────┐
                          │        Amazon ECR         │
                          └─────────────┬─────────────┘
                                        │
                                        ▼
                ┌────────────────────────────────────────────────┐
                │                    AWS ECS Fargate             │
                │                                                │
                │  - Frontend (Next.js)                          │
                │  - Grafana                                     │
                │  - Prometheus                                  │
                └──────────────────────────┬─────────────────────┘
                                           │
                                           ▼
                                ┌──────────────────────┐
                                │   CloudWatch Logs    │
                                └──────────────────────┘
```

---

# 3. Componentes Tecnológicos

## Infraestructura  
- AWS ECS Fargate  
- AWS ECR  
- AWS VPC (subredes públicas y privadas)  
- AWS IAM (roles, políticas, ejecución de tareas)  
- Terraform  

## Aplicación  
- Next.js 14  
- React 18  
- TailwindCSS  

## Seguridad  
- ESLint  
- Snyk (dependencias + contenedores)  
- SBOM CycloneDX  

## Observabilidad  
- Grafana  
- Prometheus  

---

# 4. Infraestructura con Terraform

La infraestructura principal se encuentra en:

```
terraform/ecs-deploy/
```

Componentes desplegados:

### Red
- VPC  
- Subnets privadas  
- Security Groups  

### Registro de contenedores
- Repositorios ECR para:
  - Frontend  
  - Grafana  
  - Prometheus  

### Cluster y servicios ECS Fargate
- Task Definitions  
- Servicios ECS con auto-deploy  
- Roles IAM para ejecución  

### Despliegue

```bash
cd terraform/ecs-deploy
terraform init
terraform apply
```

---

# 5. Dockerfile Multi‑Stage (Frontend)

El Dockerfile está dentro de:

```
frontend/Dockerfile
```

Optimizado:

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000
CMD ["npm", "start"]
```

---

# 6. Pipeline CI/CD – GitHub Actions

El pipeline ejecuta:

1. **Detección de cambios** (solo construye lo necesario)  
2. **ESLint** (solo si cambia frontend/)  
3. **Snyk NPM**  
4. **Snyk Docker**  
5. **Build & Push de imágenes a ECR**  
6. **Force new deployment en ECS**  
7. **Mensaje final de éxito**

Actualiza automáticamente el servicio ECS sin detenciones.

---

# 7. Seguridad

## 7.1 ESLint

Analiza la calidad y estilo del código:

```bash
npm run lint
```

## 7.2 Snyk – Dependencias

```bash
snyk test --file=package.json --package-manager=npm
```

## 7.3 Snyk – Imágenes Docker

```bash
snyk test --docker repo/image:latest
```

## 7.4 SBOM (CycloneDX)

Generación:

```bash
npx @cyclonedx/cyclonedx-npm -o sbom.json
```

---

# 8. Observabilidad – Grafana y Prometheus

Grafana incluye dashboards preconfigurados:

```
monitoring/grafana/provisioning/
```

Prometheus recopila métricas y expone `/metrics`.

---

# 9. Capturas del Proyecto

### Dashboard Grafana
![Grafana](Scree-grafana.png)

### Vista Prometheus
![Prometheus](Screeen-prometheus.png)

---

# 10. Costos Aproximados

| Servicio             | Costo estimado |
|---------------------|----------------|
| ECS Fargate         | 5–9 USD        |
| ECR Storage         | 0.10 USD/GB    |
| CloudWatch Logs     | 0.50–1 USD     |
| **Total estimado**  | **6–12 USD**   |

---

# 11. Ejecución del Proyecto

## 1. Inicializar backend remoto

```bash
cd terraform/backend-bootstrap
terraform apply
```

## 2. Crear infraestructura ECS

```bash
cd terraform/ecs-deploy
terraform init
terraform apply
```

## 3. Activar pipeline CI/CD

```bash
git add .
git commit -m "deploy"
git push
```

## 4. Obtener URL pública

```bash
terraform output
```

---

# 12. Troubleshooting (Guía Rápida)

### Problema: ECS no actualiza imagen  
Solución:
```bash
aws ecs update-service --force-new-deployment
```

### Problema: error en build de Docker  
Revisar:
- COPY incorrecto  
- Contexto de build  

### Problema: Snyk no detecta proyecto  
Verificar:
- working-directory correcto  
- Archivo package.json presente  

---

Trabajo práctico educativo para MundosE.
