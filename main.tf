# Arquivo main.tf

# Provider AWS
provider "aws" {
  region = "us-east-1" # Defina sua região AWS aqui
}


# Security group
resource "aws_security_group" "eks_sg" {
vpc_id = "vpc-005f8c7fbcaf140d8"
name   = "eks_sg"

  # Regras de entrada
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regras de saída
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Recurso EKS
resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = ["subnet-0976e430aa2640363","subnet-09e3e7080c4b28af7"] # Use as subnets públicas
    security_group_ids = [aws_security_group.eks_sg.id]
  }
}

# Recurso IAM role para EKS
resource "aws_iam_role" "eks_role" {
  name = "my-eks-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}
