terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "sp_user_access_admin" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "User Access Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_linux_web_app" "backend" {
  name                = "backend-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = true
    
    application_stack {
      docker_image_name   = var.docker_username != "" ? "${var.docker_username}/${var.docker_backend_image}:${coalesce(var.docker_image_tag, "latest")}" : var.docker_backend_image
      docker_registry_url = var.docker_registry_url != "" ? "https://${trimsuffix(var.docker_registry_url, "/")}" : "https://docker.io"
    }

    cors {
      allowed_origins     = ["*"]
      support_credentials = false
    }

    ip_restriction {
      action      = "Allow"
      ip_address  = var.allowed_ip_range
      name        = "RestrictedAccess"
      priority    = 100
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_USERNAME"           = var.docker_registry_username
    "DOCKER_REGISTRY_PASSWORD"           = var.docker_registry_password
    "AZURE_CLIENT_ID"                    = var.azure_client_id
    "AZURE_CLIENT_SECRET"                = var.azure_client_secret
    "AZURE_TENANT_ID"                    = var.azure_tenant_id
    "AZURE_SUBSCRIPTION_ID"              = var.subscription_id
  }

  auth_settings {
    enabled = false
  }
}

resource "azurerm_linux_web_app" "frontend" {
  name                = "${var.project_name}-frontend-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = true
    application_stack {
      docker_image_name   = var.docker_username != "" ? "${var.docker_username}/${var.docker_frontend_image}:${coalesce(var.docker_image_tag, "latest")}" : var.docker_frontend_image
      docker_registry_url = var.docker_registry_url != "" ? "https://${trimsuffix(var.docker_registry_url, "/")}" : "https://docker.io"
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_USERNAME"           = var.docker_registry_username
    "DOCKER_REGISTRY_PASSWORD"           = var.docker_registry_password
  }
}

resource "azurerm_role_assignment" "webapp_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_web_app.backend.identity[0].principal_id
}

resource "azurerm_role_assignment" "user_roles" {
  for_each             = toset(["27df6cf9-31dc-4045-84a0-1b241c36d64a"])
  principal_id         = each.value
  role_definition_name = "Reader"
  scope                = azurerm_resource_group.rg.id
}

resource "azurerm_role_assignment" "admin_roles" {
  for_each             = toset(["fe94c441-321d-442a-a76c-92831ea49178"])
  principal_id         = each.value
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.rg.id
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "log-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "backend_app_diagnostic" {
  name                       = "backend-app-diagnostic-setting"
  target_resource_id         = azurerm_linux_web_app.backend.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_autoscale_setting" "app_service_auto_scale" {
  name                = "auto-scale-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_service_plan.asp.id

  profile {
    name = "defaultProfile"

    capacity {
      default = var.default_instance_count
      minimum = var.min_instance_count
      maximum = var.max_instance_count
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.asp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.scale_up_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT${var.scale_cooldown_minutes}M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.asp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.scale_down_threshold
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT${var.scale_cooldown_minutes}M"
      }
    }
  }
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-${var.project_name}-${var.environment}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "sql_database" {
  name           = "sqldb-${var.project_name}-${var.environment}"
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = "Basic"
  zone_redundant = false
}
//addition 
resource "azurerm_container_group" "frontend" {
  name                = "frontend-container-group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  container {
    name   = "frontend"
    image  = "${var.docker_username}/frontend:${var.docker_image_tag}"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      ENVIRONMENT = "production"
    }
  }

  tags = {
    environment = "production"
    project     = "springboot-react"
  }
}