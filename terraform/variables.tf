
variable "vpc_cidr_block" {}

variable "subnet_cidr_blocks" {
  type = list(string)
}

variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}
variable "allocated_storage" {}
variable "username" {}
variable "password" {}
variable "engine" {}
variable "db_name" {}
variable "instance_class" {}
variable "image_name" {}
#variable "instance_id" {}
# Azure Configuration
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

# Azure AD Authentication
variable "azure_client_id" {
  description = "Azure AD application client ID"
  type        = string
}

variable "azure_client_secret" {
  description = "Azure AD application client secret"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

# Project Settings
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "springboot-react"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

# Docker Configuration
variable "docker_registry_url" {
  description = "Docker registry URL"
  type        = string
  default     = "docker.io"
}

variable "docker_registry_username" {
  description = "Docker registry username"
  type        = string
}

variable "docker_registry_password" {
  description = "Docker registry password"
  type        = string
  sensitive   = true
}

variable "docker_username" {
  description = "Docker Hub username"
  type        = string
  default     = "rdgmh"
}

variable "docker_backend_image" {
  description = "Backend Docker image name"
  type        = string
  default     = "backend"
}

variable "docker_frontend_image" {
  description = "Frontend Docker image name"
  type        = string
  default     = "frontend"
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

# Auto-scaling Configuration
variable "default_instance_count" {
  description = "Default number of instances"
  type        = number
  default     = 2
}

variable "min_instance_count" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_instance_count" {
  description = "Maximum number of instances"
  type        = number
  default     = 5
}

variable "scale_up_threshold" {
  description = "CPU percentage threshold to scale up"
  type        = number
  default     = 75
}

variable "scale_down_threshold" {
  description = "CPU percentage threshold to scale down"
  type        = number
  default     = 25
}

variable "scale_cooldown_minutes" {
  description = "Cooldown period in minutes between scaling actions"
  type        = number
  default     = 5
}

# Resource Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    environment = "dev"
    project     = "springboot-react"
    managed_by  = "terraform"
  }
}

