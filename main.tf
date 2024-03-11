# Arquivo main.tf

# Provider AWS
provider "aws" {
  region = "us-east-1" # Defina sua região AWS aqui
}

# Recurso VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" # Altere o bloco de CIDR conforme necessário
}

# Subnet pública
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24" # Altere o bloco de CIDR conforme necessário
  map_public_ip_on_launch = true
  availability_zone = ["us-east-1a","us-east-1a"] # Altere a zona de disponibilidade conforme necessário
}

# Security group
resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.my_vpc.id
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
resource "aws_eks_cluster" "my_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public_subnet.id] # Use as subnets públicas
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
