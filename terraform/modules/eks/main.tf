
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.26.6"

  cluster_name    = "eks-${var.namespace}"
  cluster_version = "1.22"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  create_cloudwatch_log_group = true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  eks_managed_node_groups = {
    one = {
      name          = "${var.namespace}-ng"
      instance_type = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
}