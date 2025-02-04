variable "instance_type" {
  description = "Type of EC2 instance"
  default     = "t2.micro"
}

variable "frontend_ami" {
  description = "AMI ID for the frontend instance"
}

variable "backend_ami" {
  description = "AMI ID for the backend instance"
}

variable "jenkins_ami" {
  description = "AMI ID for the Jenkins instance"
}

variable "bucket_name" {
  description = "S3 bucket name"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type = list(string)
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type = list(string)
}

variable "instance_class" {
  description = "RDS instance class"
}

variable "my_ip" {
  description = "Your IP for SSH access"
}

variable "public_key_location" {
  description = "Location of your public SSH key"
}
variable "image_name" {}
variable "env_prefix" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}

variable subnet_cidr_block {}
variable avail_zone {}
variable vpc_id {}
variable default_route_table_id {}
variable subnet_id {}