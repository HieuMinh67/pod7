module "prod_networking" {
  source             = "./modules/networking"
  namespace          = "prod"
  vpc_cidr           = "10.2.0.0/16"
  public_subnets     = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  private_subnets    = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
  database_subnets   = ["10.2.100.0/24", "10.2.110.0/24", "10.2.120.0/24"]
  availability_zones = data.aws_availability_zones.az.names
}

module "non_prod_networking" {
  source             = "./modules/networking"
  namespace          = "non-prod"
  vpc_cidr           = var.non_prod_cidr
  public_subnets     = ["10.3.0.0/24", "10.3.1.0/24", "10.3.2.0/24"]
  private_subnets    = ["10.3.10.0/24", "10.3.11.0/24", "10.3.12.0/24"]
  database_subnets   = ["10.3.100.0/24", "10.3.110.0/24", "10.3.120.0/24"]
  availability_zones = data.aws_availability_zones.az.names
}

module "non_prod_cluster" {
  source     = "./modules/eks"
  namespace  = "non-prod"
  vpc_id     = module.non_prod_networking.vpc.vpc_id
  subnet_ids = module.non_prod_networking.private_subnets
  #  eks_user_role = aws_iam_policy.describe_eks_policy.arn
  eks_user_role = aws_iam_role.describe_eks_role.arn
}

module "prod_cluster" {
  source     = "./modules/eks"
  namespace  = "prod"
  vpc_id     = module.prod_networking.vpc.vpc_id
  subnet_ids = module.prod_networking.private_subnets
  #  eks_user_role = aws_iam_policy.describe_eks_policy.arn
  eks_user_role = aws_iam_role.describe_eks_role.arn
}


module "bastion_host" {
  source                     = "./modules/bastion_host"
  non_prod_networking        = module.non_prod_networking
  prod_networking            = module.prod_networking
  bastion_ingress_cidr_block = "10.1.0.0/16"
  prod_kubectl_config        = module.prod_cluster.kubeconfig
  non_prod_kubectl_config    = module.non_prod_cluster.kubeconfig
  eks_cidr                   = var.non_prod_cidr
  prod_eks_sg_id             = module.prod_cluster.sg_id
  non_prod_eks_sg_id         = module.non_prod_cluster.sg_id
  availability_zones         = data.aws_availability_zones.az.names

  access_key     = var.access_key
  default_region = var.region
  secret_key     = var.secret_key
  eks_user_role  = aws_iam_instance_profile.bastion_profile.arn
}

module "prod_db_user" {
  source    = "./modules/secrets_manager"
  namespace = "prod"
}

module "non_prod_db_user" {
  source    = "./modules/secrets_manager"
  namespace = "dev"
}

module "prod_db" {
  source     = "./modules/database"
  depends_on = [module.prod_db_user]
  namespace  = "prod"
  vpc        = module.prod_networking.vpc
  sg         = module.prod_networking.sg
}

module "non_prod_db" {
  source     = "./modules/database"
  depends_on = [module.non_prod_db_user]
  namespace  = "dev"
  vpc        = module.non_prod_networking.vpc
  sg         = module.non_prod_networking.sg
}
