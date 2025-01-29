output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.example.id
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.example.endpoint
}

output "eks_cluster_certificate_authority" {
  description = "The certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.example.certificate_authority[0].data
}

output "eks_node_group_arn" {
  description = "The ARN of the EKS node group"
  value       = aws_eks_node_group.example.arn
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.example.endpoint
}

output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.example.id
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.example.name
}

output "cloudtrail_id" {
  description = "The ID of the CloudTrail"
  value       = aws_cloudtrail.example.id
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.example.bucket
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.example.id
}

output "subnet1_id" {
  description = "The ID of the first subnet"
  value       = aws_subnet.example1.id
}

output "subnet2_id" {
  description = "The ID of the second subnet"
  value       = aws_subnet.example2.id
}