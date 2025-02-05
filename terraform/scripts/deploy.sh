#!/bin/bash
set -e

# ---------------------------
# 1. Environment Setup
# ---------------------------
BASE_DIR=$(pwd)
TF_DIR="$BASE_DIR/terraform"
BACKEND_DIR="$BASE_DIR/backend"
FRONTEND_DIR="$BASE_DIR/frontend"
TFVARS_FILE="$TF_DIR/terraform.tfvars"

# Load environment variables
source .env

# ---------------------------
# 2. Dependency Checks
# ---------------------------
echo "🔍 Checking dependencies..."
command -v az >/dev/null 2>&1 || { echo >&2 "Azure CLI required but not installed. Aborting."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo >&2 "Docker required but not installed. Aborting."; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo >&2 "Terraform required but not installed. Aborting."; exit 1; }

# ---------------------------
# 3. Configuration Validation
# ---------------------------
echo "✅ Validating configuration..."
[ -z "${SUBSCRIPTION_ID}" ] && { echo "SUBSCRIPTION_ID not set"; exit 1; }
[ -z "${DOCKER_USERNAME}" ] && { echo "DOCKER_USERNAME not set"; exit 1; }
[ -z "${DOCKER_PASSWORD}" ] && { echo "DOCKER_PASSWORD not set"; exit 1; }

# ---------------------
# 4. Azure Authentication
# ---------------------
echo "🔐 Authenticating with Azure..."
az login --use-device-code --output none
az account set --subscription "$SUBSCRIPTION_ID"

# ----------------------
# 5. Docker Setup
# ----------------------
echo "🐳 Authenticating with Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# ---------------------
# 6. Build Applications
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

build_and_push "$BACKEND_DIR" "backend"
build_and_push "$FRONTEND_DIR" "frontend"

# ---------------------------
# 7. Generate Terraform Config
# ---------------------------
echo "📝 Generating terraform.tfvars..."
cat > "$TFVARS_FILE" << EOF
# Core Configuration
subscription_id     = "$SUBSCRIPTION_ID"
location            = "$LOCATION"
project_name        = "$PROJECT_NAME"
environment         = "${ENVIRONMENT:-dev}"

# Docker Configuration
docker_username          = "$DOCKER_USERNAME"
docker_backend_image     = "backend"
docker_frontend_image    = "frontend"
docker_image_tag         = "latest"
docker_registry_url      = "docker.io"
docker_registry_username = "$DOCKER_USERNAME"
docker_registry_password = "$DOCKER_PASSWORD"

# SQL Configuration
sql_admin_username = "$SQL_ADMIN_USERNAME"
sql_admin_password = "$SQL_ADMIN_PASSWORD"

# Azure AD Integration
azure_client_id     = "$AZURE_CLIENT_ID"
azure_client_secret = "$AZURE_CLIENT_SECRET"
azure_tenant_id     = "$AZURE_TENANT_ID"

# Tags
tags = {
  Environment = "${ENVIRONMENT:-dev}"
  Project     = "$PROJECT_NAME"
}
EOF

# ---------------------------
# 8. Terraform Execution
# ---------------------------
cd "$TF_DIR"
echo "🚀 Initializing Terraform..."
terraform init

echo "🛠️ Applying infrastructure configuration..."
terraform apply -auto-approve

# ---------------------------
# 9. Deployment Output
# ---------------------------
echo "🌐 Deployment complete! Access URLs:"
terraform output -raw frontend_url
terraform output -raw backend_url

# ---------------------------
# 10. Cleanup Option
# ---------------------------
read -p "❓ Do you want to destroy all resources? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "🧹 Destroying resources..."
    terraform destroy -auto-approve
    echo "✅ Cleanup complete!"
fi

echo "🎉 All operations completed!"