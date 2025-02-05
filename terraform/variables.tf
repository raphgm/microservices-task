variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure service principal client ID"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure service principal client secret"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags for Azure resources"
  type        = map(string)
  default     = {}
}

variable "docker_username" {
  description = "Docker Hub username or repository namespace"
  type        = string
  default     = ""
}

variable "docker_backend_image" {
  description = "Backend Docker image name"
  type        = string
}

variable "docker_frontend_image" {
  description = "Frontend Docker image name"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "docker_registry_url" {
  description = "Custom Docker registry URL"
  type        = string
  default     = ""
}

variable "docker_registry_username" {
  description = "Docker registry username"
  type        = string
  default     = ""
}

variable "docker_registry_password" {
  description = "Docker registry password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "allowed_ip_range" {
  description = "Allowed IP range for backend access"
  type        = string
  default     = "*"
}

variable "sql_admin_username" {
  description = "SQL Server admin username"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}

variable "default_instance_count" {
  description = "Default number of App Service instances"
  type        = number
  default     = 1
}

variable "min_instance_count" {
  description = "Minimum number of App Service instances"
  type        = number
  default     = 1
}

variable "max_instance_count" {
  description = "Maximum number of App Service instances"
  type        = number
  default     = 3
}

variable "scale_up_threshold" {
  description = "CPU threshold percentage to scale up"
  type        = number
  default     = 70
}

variable "scale_down_threshold" {
  description = "CPU threshold percentage to scale down"
  type        = number
  default     = 30
}

variable "scale_cooldown_minutes" {
  description = "Cooldown period (minutes) between scaling operations"
  type        = number
  default     = 5
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string
}

variable "sql_server_name" {
  description = "SQL Server Name"
  type        = string
}

variable "sql_database_name" {
  description = "SQL Database Name"
  type        = string
}

variable "service_plan_name" {
  description = "The name of the service plan"
  type        = string
}

variable "service_plan_location" {
  description = "The location of the service plan"
  type        = string
}

variable "service_plan_os_type" {
  description = "The OS type of the service plan"
  type        = string
}

variable "service_plan_tier" {
  description = "The tier of the service plan"
  type        = string
  default     = "PremiumV2"
}

variable "service_plan_size" {
  description = "The size of the service plan"
  type        = string
  default     = "P1v2"
}

variable "sp_object_id" {
  description = "The object ID of the service principal."
  type        = string
}