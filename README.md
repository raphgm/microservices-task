
# Cloud-Native Spring Boot & React Application with CI/CD Documentation

## Project Overview
This cloud-native solution implements automated CI/CD pipelines and infrastructure as code (IaC) using Docker Hub for container management. The architecture supports secure deployments with monitoring and auto-scaling capabilities.

### Key Features
- **Multi-environment CI/CD pipelines** for frontend (React) and backend (Spring Boot)
- **Terraform-provisioned Azure infrastructure** with auto-scaling
- **Docker Hub integration** for container management
- **Azure SQL Database** for persistent storage
- **Integrated monitoring** with Azure Monitor

## Architecture
![High-Level Architecture](docs/architecture-dockerhub.png)

### Core Components
| Component              | Technology Stack      | Description                                                                 |
|------------------------|-----------------------|-----------------------------------------------------------------------------|
| **Frontend**           | React + Docker        | Served via Azure App Service with Docker Hub images                        |
| **Backend**            | Spring Boot + Docker  | REST API with Azure SQL integration                                         |
| **Database**           | Azure SQL Database    | Managed relational database with auto-scaling                              |
| **Registry**           | Docker Hub            | Public/private Docker image storage                                        |
| **Infrastructure**     | Terraform             | IaC implementation for Azure resource provisioning                        |

---

## Implementation Details

### 1. Infrastructure as Code (Terraform)
**Key Resources:**
```terraform
# database
resource "azurerm_mssql_server" "main" {
  name                = "app-db-server"
  resource_group_name = azurerm_resource_group.main.name
  location            = "westeurope"
  version             = "12.0"
}

# app-service
resource "azurerm_app_service_plan" "main" {
  name                = "app-service-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true
  
  sku {
    tier = "Standard"
    size = "S1"
  }
}
```

### 2. CI/CD Pipeline Design
**Pipeline Structure:**
```
├── .github
│   ├── workflows
│   │   ├── frontend-ci.yml
│   │   ├── backend-ci.yml
│   │   └── infra-cd.yml
```

## Image Push to Container Registry
This was implemented following the guide that requires everything to be done automatically and therefore the script was created to implement this, the snippet below shows part relevant to the image deployment to docker hub
```
# ---------------------
#  Azure Authentication
# ---------------------
echo "🔐 Authenticating with Azure..."
az login --use-device-code --output none
az account set --subscription "$SUBSCRIPTION_ID"

# ----------------------
#  Docker Setup
# ----------------------
echo "🐳 Authenticating with Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# ---------------------
#  Build Applications
# ---------------------
echo "🏗️ Building Docker images..."
docker buildx create --use >/dev/null

build_and_push() {
  local context=$1
  local image_name=$2
  local log_file="$BASE_DIR/${image_name}-build.log"
  
  echo "📦 Building $image_name..."
  docker buildx build \
    --platform linux/amd64 \
    -t "$DOCKER_USERNAME/$image_name:latest" \
    --push \
    "$context" > "$log_file" 2>&1
}
```

**Key Pipeline Stages:**
1. **Image Management:**
   - Docker image builds with multi-stage builds
   - Semantic version tagging ( `latest`)
  

2. **Deployment Strategy:**
   - Backend docker file
   - frontend dockerile
   

**Sample Frontend Pipeline:**
```yaml
name: Frontend CI/CD

on:
  push:
    branches: [ main ]
    paths: [ 'frontend/**' ]

jobs:
  build-push:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
    
    - name: Build and Push
      uses: docker/build-push-action@v3
      with:
        context: frontend
        push: true
        tags: |
          ${{ secrets.DOCKERHUB_USERNAME }}/frontend:latest
          ${{ secrets.DOCKERHUB_USERNAME }}/frontend:${{ github.sha }}
```

---

## Deployment Guide

### Prerequisites
- Azure account with Contributor permissions
- Docker Hub account
- Terraform v1.3+
- Node.js 18.x & Java 17

### 1. Repository Setup
```bash
git clone https://github.com/raphgm/microservices-task.git
cd cloud-native-app
```

### 2. Docker Hub Configuration
1. Create access token in Docker Hub:
   - Navigate to Account Settings → Security → New Access Token
2. Store credentials in GitHub Secrets:
   - `DOCKERHUB_USERNAME`: Your Docker ID
   - `DOCKERHUB_TOKEN`: Generated access token

### 3. Infrastructure Deployment
```bash
cd infra/terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Application Configuration
**Backend Database Settings:**
```properties
# application-prod.yml
spring:
  datasource:
    url: jdbc:sqlserver://${DB_HOST}:1433;database=${DB_NAME}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
```

**Frontend Environment Variables:**
```env
# .env.production
REACT_APP_API_URL=https://api-prod.azurewebsites.net
REACT_APP_ENV=production
```

---

## Monitoring & Operations

### Key Monitoring Components
1. **Azure Application Insights**
   - Application performance monitoring
   - End-to-end transaction tracing
2. **Azure Monitor**
   - Infrastructure metrics (CPU, memory, storage)
   - Alert rules for critical thresholds


### Audit Controls
- Terraform state file versioning
- Azure Activity Log integration

---

## Security Implementation

### Container Security
1. **Image Best Practices:**
   - Non-root user in Dockerfiles
   - Minimal base images (e.g., `node:18-alpine`)
   - Regular vulnerability scanning
2. **Secrets Management:**
   - use of Environment Variables 
   - Docker Hub access tokens with limited permissions

### Network Security
- Azure SQL firewall rules
- App Service access restrictions
- TLS 1.2 enforcement

---

## Cost Optimization

### Key Strategies
1. **Auto-scaling Configuration:**
   ```terraform
   resource "azurerm_monitor_autoscale_setting" "frontend" {
     name                = "frontend-autoscale"
     resource_group_name = azurerm_resource_group.main.name
     target_resource_id  = azurerm_app_service_plan.main.id

     profile {
       name = "default"
       
       capacity {
         default = 2
         minimum = 1
         maximum = 5
       }
     }
   }
   ```
2. **Docker Hub Cost Management:**
   - Use public repositories for non-sensitive images
   - Implement image retention policies
   - Regularly clean up unused tags

---

## Disaster Recovery

### Backup Strategy
1. **Database Backups:**
   - Azure SQL automated backups (7-35 day retention)
   - Geo-redundant storage option
2. **Infrastructure Recovery:**
   - Terraform state backups to Azure Storage
   

### Rollback Procedure
1. **Application Rollback:**
   ```bash
   docker pull $DOCKERHUB_USERNAME/frontend:previous-stable
   az webapp config container set \
     --name frontend-app \
     --resource-group myResourceGroup \
     --docker-custom-image-name $DOCKERHUB_USERNAME/frontend:previous-stable
   ```
2. **Infrastructure Rollback:**
   ```bash
   terraform apply -var "docker_tag=previous-version"
   ```

---

## Team Collaboration

### Development Workflow
1. **Feature Branches:**
   ```bash
   git checkout -b feature/new-endpoint
   # Develop and test locally
   git push origin feature/new-endpoint
   ```
2. **PR Process:**
   - Required status checks:
     - Unit tests
     - Container builds
     - Terraform validation
   - Code review + approval required

### Environment Strategy
| Environment | Purpose          | Deployment Trigger       |
|-------------|------------------|--------------------------|
| Dev         | Feature testing  | Push to feature branch   |
| Staging     | Integration test | Merge to main            |
| Production  | Live traffic     | Manual approval required |

---

## Maintenance & Updates

### Dependency Management
1. **Frontend:**
   ```bash
   cd frontend
   npm outdated
   npm update
   ```
2. **Backend:**
   ```bash
   mvn versions:display-dependency-updates
   mvn versions:use-latest-versions
   ```

### Terraform Updates
```bash
terraform init -upgrade
terraform plan -out=tfplan
terraform apply tfplan
```

---

## Troubleshooting Guide

### Common Docker Hub Issues
| Symptom                  | Resolution                                                                 |
|--------------------------|---------------------------------------------------------------------------|
| Rate limit exceeded      | Upgrade Docker Hub plan or use authenticated pulls                        |
| Authentication failures  | Verify token permissions and expiration date                              |
| Image pull errors        | Check tag existence and repository visibility settings                    |

### Azure Deployment Issues
| Error Message                          | Resolution Steps                                                                 |
|----------------------------------------|---------------------------------------------------------------------------------|
| "Invalid container image"             | Verify Docker Hub image path and tags                                           |
| "Database connection refused"         | Check Azure SQL firewall rules and connection strings                           |
| "Insufficient instance count"         | Validate autoscale settings and subscription quotas                             |

---

## Issues encountered.
- implementing this project using a MacBook would require that the image be built with reference to the platform
- building for AWS and changing to Azure will leave deposits of AWS especially when its a mac, windows is always recommended.
  

## Project Evolution

### Future Roadmap
1. **Multi-cloud Support:**
   - Add AWS/GCP deployment options
   - Move the application from Azure App Services to AKS
   - Use of Key Vault instead of Environment Variables
  

2. **Serverless Components:**
   - Azure Functions for background processing
   - Event-driven architecture
