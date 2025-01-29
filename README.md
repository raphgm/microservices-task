```markdown
# Cloud-Native Spring Boot & React Application with CI/CD

This repository contains a cloud-native application built with Spring Boot (backend) and React (frontend), deployed using Azure cloud services and modern DevOps practices. It demonstrates infrastructure as code (IaC), CI/CD pipelines, containerization, and monitoring.

## Project Overview

### User Stories Addressed
- **CI/CD Pipeline for Application**: 
  - Build, test, and deploy the application across environments.
  - Build and push Docker containers.
- **Infrastructure as Code (IaC)**:
  - Deploy cloud infrastructure using Terraform.
  - Enable monitoring, auditing, and multi-account support.
- **Bonus**: 
  - Separate backend/frontend pipelines.
  - Use Azure SQL Database (replaces in-memory DB).
  - Pipeline cleanup/destroy functionality.

## Architecture

![High-Level Architecture](docs/architecture.png)

### Key Components
- **Frontend**: React app served via Docker container (Azure App Service).
- **Backend**: Spring Boot API with Azure SQL Database.
- **Infrastructure**: Terraform-provisioned Azure resources:
  - **Resource Group**: Logical container for all resources.
  - **Azure Container Registry (ACR)**: Stores Docker images.
  - **App Service Plan**: Hosts frontend/backend containers.
  - **Azure SQL Database**: Persistent relational storage.
  - **Log Analytics**: Centralized logging and monitoring.
- **CI/CD Pipelines**:
  - **Application Pipeline**: Builds, tests, and deploys containers.
  - **Infrastructure Pipeline**: Provisions/destroys cloud resources.

## Getting Started

### Prerequisites
- Azure account with contributor permissions.
- Docker, Terraform, and Azure CLI installed locally.
- Fork this repository.

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/spring-boot-react-example.git
cd spring-boot-react-example
```

### 2. Configure Environment
1. **Backend**:
   - Update `backend/src/main/resources/application.properties`:
     ```properties
     spring.datasource.url=jdbc:sqlserver://<azure-sql-server>.database.windows.net:1433;database=<db-name>
     spring.datasource.username=<username>
     spring.datasource.password=<password>
     ```
2. **Frontend**:
   - Set `REACT_APP_API_URL` in `frontend/.env`:
     ```env
     REACT_APP_API_URL=https://api.your-app.azurewebsites.net
     ```

### 3. Deploy Infrastructure
```bash
cd infra/terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Run CI/CD Pipelines
- **Infrastructure Pipeline** (Terraform): Triggers on `infra/` changes.
- **Application Pipeline** (GitHub Actions/Azure DevOps): 
  - Builds Docker images on push to `main`.
  - Deploys to staging/production via environment approvals.

## Monitoring & Auditing
- **Azure Monitor**: View metrics/LOGs in Azure Portal.
- **Application Insights**: Integrated with Spring Boot for APM.
- **Audit Logs**: Track resource changes via Azure Activity Log.

## Cleanup
```bash
terraform destroy -auto-approve  # Destroys all cloud resources
```

## Common Errors & Fixes

### Error: Backend JAR Not Found
- **Fix**: 
  ```bash
  cd backend && mvn clean package  # Rebuild JAR
  ```

### Error: Node.js Dependency Issues
- **Fix**:
  ```bash
  cd frontend && rm -rf node_modules && npm install
  ```

### Error: Database Connection Refused
- **Fix**:
  - Whitelist your IP in Azure SQL firewall settings.
  - Verify credentials in Azure Key Vault.

## Conclusion

This project modernizes a monolithic application by:
- **Decomposing** into microservices (React + Spring Boot).
- **Containerizing** with Docker for portability.
- **Automating** deployments via CI/CD pipelines.
- **Leveraging Azure** for scalable, managed services.

---

**Repository Mirroring**: To push changes to GitLab:
```bash
git remote set-url --push origin https://github.com/raphgm/srbe.git
git push --mirror
```