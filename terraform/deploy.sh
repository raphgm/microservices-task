#!/bin/bash
set -euxo pipefail

# --------------------------
# 1. Directory and Path Setup
# --------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
TFVARS_FILE="$TERRAFORM_DIR/terraform.tfvars"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"

# ----------------------
# 2. Validate Environment
# ----------------------
echo "📂 Validating environment..."
required_files=(
  "$ENV_FILE"
  "$TERRAFORM_DIR/variables.tf"
  "$BACKEND_DIR/Dockerfile"
  "$FRONTEND_DIR/Dockerfile"
)

for file in "${required_files[@]}"; do
  if [[ ! -e "$file" ]]; then
    echo "❌ Missing required file: $file"
    exit 1
  fi
done

# -----------------------------
# 3. Load Environment Variables
# -----------------------------
echo "🔄 Loading environment variables..."
source "$ENV_FILE"

# Validate critical variables
required_vars=(
  "SUBSCRIPTION_ID" "LOCATION" "PROJECT_NAME"
  "DOCKER_USERNAME" "DOCKER_PASSWORD"
  "AZURE_CLIENT_ID" "AZURE_CLIENT_SECRET" "AZURE_TENANT_ID"
  "SQL_ADMIN_USERNAME" "SQL_ADMIN_PASSWORD"
)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var}" ]]; then
    echo "❌ Missing environment variable: $var"
    exit 1
  fi
done

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
  local log_file="$SCRIPT_DIR/${image_name}-build.log"
  
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
docker_username     = "$DOCKER_USERNAME"
docker_password     = "$DOCKER_PASSWORD"
backend_image       = "$DOCKER_USERNAME/backend:latest"
frontend_image      = "$DOCKER_USERNAME/frontend:latest"

# Database Configuration
sql_admin_username = "$SQL_ADMIN_USERNAME"
sql_admin_password = "$SQL_ADMIN_PASSWORD"

# Azure AD Integration
client_id     = "$AZURE_CLIENT_ID"
client_secret = "$AZURE_CLIENT_SECRET"
tenant_id     = "$AZURE_TENANT_ID"

# Tags
tags = {
  environment = "${ENVIRONMENT:-dev}"
  project     = "$PROJECT_NAME"
  managed_by  = "terraform"
}
EOF

# ------------------------
# 8. Deploy Infrastructure
# ------------------------
cd "$TERRAFORM_DIR"

echo "🚀 Initializing Terraform..."
terraform init -upgrade

echo "🛠️ Applying Terraform configuration..."
timeout 1800 terraform apply -auto-approve

# -------------------------
# 9. Configure Applications
# -------------------------
echo "⚙️ Retrieving deployment outputs..."
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
BACKEND_APP=$(terraform output -raw backend_app_name)
FRONTEND_APP=$(terraform output -raw frontend_app_name)

configure_app() {
  local app_name=$1
  local image_name=$2
  
  echo "🔧 Configuring $app_name..."
  az webapp config container set \
    --name "$app_name" \
    --resource-group "$RESOURCE_GROUP" \
    --docker-custom-image "$DOCKER_USERNAME/$image_name:latest" \
    --docker-registry-server-url "https://index.docker.io" \
    --docker-registry-server-user "$DOCKER_USERNAME" \
    --docker-registry-server-password "$DOCKER_PASSWORD"
}

configure_app "$BACKEND_APP" "backend"
configure_app "$FRONTEND_APP" "frontend"

# ----------------------
# 10. Verify Deployment
# ----------------------
echo "✅ Verifying deployment..."
az webapp restart --name "$BACKEND_APP" --resource-group "$RESOURCE_GROUP"
az webapp restart --name "$FRONTEND_APP" --resource-group "$RESOURCE_GROUP"

echo "🌐 Backend URL: https://$(az webapp show --name "$BACKEND_APP" --resource-group "$RESOURCE_GROUP" --query defaultHostName -o tsv)"
echo "🌐 Frontend URL: https://$(az webapp show --name "$FRONTEND_APP" --resource-group "$RESOURCE_GROUP" --query defaultHostName -o tsv)"

# ---------------------
# 11. Cleanup Option
# ---------------------
read -p "❓ Destroy infrastructure? (y/N) " -n1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "⚠️ Confirm destruction (y/N) " -n1
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️ Destroying infrastructure..."
    timeout 1800 terraform destroy -auto-approve
  fi
fi

echo "🎉 Deployment process completed!"