<<<<<<< HEAD
/*resource "aws_subnet" "myapp-subnet" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: var.env_prefix
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  #vpc_id = var.vpc_id
  vpc_id = aws_vpc.myapp-vpc.id
  tags = { 
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  #default_route_table_id = var.default_route_table_id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = { 
    Name = "${var.env_prefix}-main-rtb"
  }
}


resource "aws_default_security_group" "default-sg" {
  #vpc_id = var.vpc_id.id
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.env_prefix]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = [ ]
  }

  tags = { 
      Name = "${var.env_prefix}-default-sg"
  }

}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image_name]
    #values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "frontend-instance" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = module.myapp-subnet.subnet.id
  vpc_security_group_ids = [aws_default_security_group.default_sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entryscrpit.sh")

  /*user_data = <<-EOF
    #!/bin/bash
    cd /var/www/html
    git clone https://github.com/Abbeyo01/spring-boot-react-example.git
    cd frontend
    npm install
    npm run build
  EOF

  tags = { 
    Name = "${var.env_prefix}-SpringBootFrontend"
  }
}
*/



/////////////////////

provider "aws" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source                 = "./modules/subnet"
  vpc_cidr_block = var.vpc_cidr_block
  subnet_cidr_block      = var.subnet_cidr_blocks
  avail_zone             = var.avail_zone
  env_prefix             = var.env_prefix
  vpc_id                 = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  #default_route_table_id = module.vpc.default_route_table_id
  #vpc_id = aws_vpc.myapp-vpc.id

}

module "ec2_instance" {
  source            = "./modules/ec2_instance"
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  my_ip = var.my_ip
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  subnet_id = module.myapp-subnet.subnet
  image_name = var.image_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type
}


module "rds" {
  source             = "./modules/rds"
  my_ip = var.my_ip
  vpc_id = aws_vpc.myapp-vpc.id
  env_prefix = var.env_prefix
  engine             = var.engine
  instance_class     = var.instance_class
  allocated_storage  = var.allocated_storage
  db_name            = var.db_name
  username           = var.username
  password           = var.password
  subnet_id = module.myapp-subnet.subnet

}

module "cloudwatch" {
  source         = "./modules/cloudwatch"
  #monitored_instance_ids = [module.ec2_instance.frontend-instance.instance_id]
  env_prefix = var.env_prefix
  #instance_id = module.ec2_instance.frontend-instance_id
  frontend_instance_id = module.ec2_instance.frontend_instance_id
  backend_instance_id = module.ec2_instance.backend_instance_id
  jenkins_instance_id = module.ec2_instance.jenkins_instance_id
  rds_instance_id = module.rds.rds_instance_id
  #DBInstanceIdentifier = module.rds.aws_db_instance
  

=======
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

  site_config {
    always_on = true
    
    application_stack {
        docker_image_name = var.docker_registry_url != "" ? "${trimsuffix(var.docker_registry_url, "/")}/${var.docker_username}/${var.docker_backend_image}" : "${var.docker_username}/${var.docker_backend_image}"
      docker_registry_url = var.docker_registry_url != "" ? "https://${trimsuffix(var.docker_registry_url, "/")}" : "https://index.docker.io"
    }

    cors {
      allowed_origins     = ["*"]
      support_credentials = false
    }

    ip_restriction {
      action      = "Allow"
      ip_address  = "0.0.0.0/0"
      name        = "Allow all"
      priority    = 100
      headers {
        x_azure_fdid      = []
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }
    }

    scm_ip_restriction {
      action      = "Allow"
      ip_address  = "0.0.0.0/0"
      name        = "Allow all SCM"
      priority    = 100
      headers {
        x_azure_fdid      = []
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  auth_settings {
    enabled = true
    default_provider = "AzureActiveDirectory"
    active_directory {
      client_id     = var.azure_client_id
      client_secret = var.azure_client_secret
    }
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
       docker_image_name = var.docker_registry_url != "" ? "${trimsuffix(var.docker_registry_url, "/")}/${var.docker_username}/${var.docker_frontend_image}" : "${var.docker_username}/${var.docker_frontend_image}"
      docker_registry_url = var.docker_registry_url != "" ? "https://${trimsuffix(var.docker_registry_url, "/")}" : "https://index.docker.io"
    }
  }
}

resource "azurerm_role_assignment" "webapp_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_web_app.backend.identity[0].principal_id
}

# Assign roles to user groups
resource "azurerm_role_assignment" "user_roles" {
  for_each             = toset(["27df6cf9-31dc-4045-84a0-1b241c36d64a"])
  principal_id         = each.value
  role_definition_name = "Reader"
  scope                = azurerm_resource_group.rg.id
}

# Assign roles to admin groups
resource "azurerm_role_assignment" "admin_roles" {
  for_each             = toset(["fe94c441-321d-442a-a76c-92831ea49178"])
  principal_id         = each.value
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.rg.id
}

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "log-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                = "PerGB2018"
  retention_in_days  = 30
  tags               = var.tags
}

# Enable diagnostic settings for the backend Linux Web App
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

//Configure autoscale settings for the App Service Plan
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
        time_grain        = "PT1M"
        statistic         = "Average"
        time_window       = "PT5M"
        time_aggregation  = "Average"
        operator          = "GreaterThan"
        threshold         = var.scale_up_threshold
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
        time_grain        = "PT1M"
        statistic         = "Average"
        time_window       = "PT5M"
        time_aggregation  = "Average"
        operator          = "LessThan"
        threshold         = var.scale_down_threshold
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

# Create Network Security Group
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
    source_port_range         = "*"
    destination_port_range    = "443"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "80"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
>>>>>>> origin/main
}
