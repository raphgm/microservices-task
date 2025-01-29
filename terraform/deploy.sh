#!/bin/bash

# Source environment variables
source ./env.sh

# Build and push Docker images
echo "Building and pushing Docker images..."
docker build -t $FRONTEND_IMAGE ./frontend
docker build -t $BACKEND_IMAGE ./backend
docker push $FRONTEND_IMAGE
docker push $BACKEND_IMAGE

# Create Kubernetes secret for Docker Hub credentials
echo "Creating Kubernetes secret for Docker Hub credentials..."
kubectl create secret docker-registry my-dockerhub-secret \
  --docker-username=$DOCKER_USERNAME \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL

# Initialize and apply Terraform configuration
echo "Initializing and applying Terraform configuration..."
cd terraform
terraform init
terraform apply -auto-approve

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f eks-manifes.yml

# Get the URL for the frontend service
echo "Getting the URL for the frontend service..."
FRONTEND_SERVICE_URL=$(kubectl get svc frontend -n $KUBERNETES_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Deployment complete. You can view the frontend application at: http://$FRONTEND_SERVICE_URL"