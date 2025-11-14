variable "aws_region" {
  type    = string
  default = "us-east-1"
}


variable "environment" {
  description = "The deployment environment (dev or prod)."
  type        = string
  default     = "dev"
}


variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_group_desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2 
}

variable "node_group_max_capacity" {
  description = "Maximum number of worker nodes for auto-scaling"
  type        = number
  default     = 3
}