# nodes.tf

# --- 1. IAM Role for EKS Worker Nodes ---
# The Worker Nodes need an IAM profile (role) to join the cluster,
# pull container images, and interact with AWS services.

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

# Attach required AWS managed policies
resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}


# --- 2. EKS Managed Node Group ---

resource "aws_eks_node_group" "private_nodes" {
  # References the cluster name defined in the local block in eks.tf/security.tf
  cluster_name    = local.eks_cluster_name
  node_group_name = "${var.environment}-private-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  # Nodes are placed in the Private Subnets for security
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  # Node type comes from variables.tf (e.g., t3.medium)
  instance_types = [var.node_instance_type]

  # Auto Scaling Configuration from variables.tf
  scaling_config {
    desired_size = var.node_group_desired_capacity
    max_size     = var.node_group_max_capacity
    min_size     = var.node_group_desired_capacity
  }

  # Ensure the cluster is ready before attempting to create nodes
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]

  # Tags required for Kubernetes components to discover the nodes (e.g., Load Balancers)
  tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
  }
}