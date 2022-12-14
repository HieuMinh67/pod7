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

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = var.eks_user_role
      username = "eks-user"
      groups   = ["system:masters"]
    },
  ]

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    egress_self_all = {
      description = "Node to node"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "egress"
      self        = true
    }
  }
}
