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