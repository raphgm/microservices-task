provider "aws" {
  region = var.aws_region
}

# Create an EKS Cluster
resource "aws_eks_cluster" "example" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSVPCResourceController,
  ]
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# Autoscaling Group for EKS Worker Nodes
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.example1.id, aws_subnet.example2.id]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Create Multiple Users and Groups
resource "aws_iam_user" "example_users" {
  count = 3
  name  = "example-user-${count.index + 1}"
}

resource "aws_iam_group" "example_group" {
  name = "example-group"
}

resource "aws_iam_group_membership" "example" {
  name  = "example-group-membership"
  users = aws_iam_user.example_users[*].name
  group = aws_iam_group.example_group.name
}

# Create an RDS Database
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

# Monitoring and Audit Solution (CloudWatch and CloudTrail)
resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/eks/example-cluster/logs"
}

resource "aws_cloudtrail" "example" {
  name                          = "example-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.example.id
  include_global_service_events = true
}

resource "aws_s3_bucket" "example" {
  bucket = "example-cloudtrail-bucket"
  # acl attribute removed as it is deprecated
}

# VPC and Subnets
resource "aws_vpc" "example" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "example1" {
  vpc_id     = aws_vpc.example.id
  cidr_block = var.subnet1_cidr_block
}

resource "aws_subnet" "example2" {
  vpc_id     = aws_vpc.example.id
  cidr_block = var.subnet2_cidr_block
}