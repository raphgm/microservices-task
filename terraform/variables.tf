variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "myEKSCluster"
}

variable "eks_node_group_name" {
  description = "The name of the EKS node group"
  type        = string
  default     = "example-node-group"
}

variable "db_instance_class" {
  description = "The instance class for the RDS database"
  type        = string
  default     = "db.t2.micro"
}

variable "db_name" {
  description = "The name of the RDS database"
  type        = string
  default     = "myDbInstance"
}

variable "db_username" {
  description = "The username for the RDS database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  default     = "Password123*"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet1_cidr_block" {
  description = "The CIDR block for the first subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet2_cidr_block" {
  description = "The CIDR block for the second subnet"
  type        = string
  default     = "10.0.2.0/24"
}