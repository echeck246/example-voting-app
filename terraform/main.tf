variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "Target AWS region"
}

variable "cluster_name" {
  type        = string
  default     = "voting-app-eks"
  description = "EKS cluster name"
}

# Fetch default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# Fetch default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

# Provision EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  create_kms_key            = false
  cluster_encryption_config = {}
  enable_irsa               = false

  vpc_id                   = aws_default_vpc.default.id
  subnet_ids               = data.aws_subnets.default.ids
  control_plane_subnet_ids = data.aws_subnets.default.ids

  eks_managed_node_groups = {
    default = {
      name                        = "voting-nodes-v2"
      use_name_prefix             = false
      ami_type                    = "AL2023_x86_64_STANDARD"
      instance_types              = ["t3.small"]
      min_size                    = 2
      max_size                    = 3
      desired_size                = 2
      associate_public_ip_address = true
    }
  }

  tags = {
    Environment = "capstone"
    Project     = "example-voting-app"
  }
}