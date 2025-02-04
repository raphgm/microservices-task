output "rds_instance_id" {
  value = aws_db_instance.rds.id
}

output "aws_db_instance" {
  value = aws_db_instance.rds
}


output "db_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group
}
