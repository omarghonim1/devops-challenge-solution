
locals {
  eks_cluster_name = "eks-${var.environment}-cluster"
}

# eks.tf

# --- 1. IAM Role for EKS Control Plane ---
# The EKS service needs permissions to manage resources (like ENIs) in your VPC.

resource "aws_iam_role" "eks_master_role" {
  name = "eks-master-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

# Attach the required AWS managed policies to the role
resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.id
}

resource "aws_iam_role_policy_attachment" "eks_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.id
}


# --- 2. EKS Cluster Resource (Control Plane) ---

resource "aws_eks_cluster" "eks_cluster" {
  name     = local.eks_cluster_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = "1.29" # Specifies the Kubernetes version

  # Configuration for the VPC
  vpc_config {
    # Cluster endpoints are placed in the Private Subnets for security
    subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id] 
    
    # Associate the security group defined in security.tf
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    
    # Configure access endpoints:
    endpoint_private_access = true # Allow internal access (Nodes/Bastion Host)
    endpoint_public_access  = true  # Allow public access (e.g., from your machine, needs limiting later)
  }

  tags = {
    Name = local.eks_cluster_name
  }
}