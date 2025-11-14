# security.tf

# 1. Security Group for EKS Control Plane (API Server)
# We remove the ingress rule here to break the cycle.
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${local.eks_cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = aws_vpc.main.id 

  # Egress Rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.eks_cluster_name}-cluster-sg"
  }
}

# 2. Security Group for EKS Worker Nodes
# We remove the ingress rule that depends on the Control Plane SG.
resource "aws_security_group" "eks_node_sg" {
  name        = "${local.eks_cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  # Ingress Rule: Allow Nodes to communicate with each other (Self-Reference)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true 
  }

  # Egress Rule: Allow all outbound traffic (for pulling images via NAT GW)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "${local.eks_cluster_name}-node-sg"
  }
}

# 3. Dedicated Rules to Restore Communication and Break the Cycle
##########################################################################

# Rule A: Allow Worker Nodes (Source) to talk to the Control Plane (Target) on 443
# This replaces the original ingress rule in eks_cluster_sg.
resource "aws_security_group_rule" "allow_nodes_to_api" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id # Target SG (API)
  source_security_group_id = aws_security_group.eks_node_sg.id    # Source SG (Nodes)
}

# Rule B: Allow Control Plane (Source) to talk to the Worker Nodes (Target)
# This replaces the original ingress rule in eks_node_sg.
resource "aws_security_group_rule" "allow_api_to_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node_sg.id    # Target SG (Nodes)
  source_security_group_id = aws_security_group.eks_cluster_sg.id # Source SG (API)
}