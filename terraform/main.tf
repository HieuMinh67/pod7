module "prod_networking" {
  source           = "./modules/networking"
  namespace        = "prod"
  vpc_cidr         = "10.2.0.0/16"
  public_subnets   = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  private_subnets  = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
  database_subnets = ["10.2.100.0/24", "10.2.110.0/24", "10.2.120.0/24"]
}

module "non_prod_networking" {
  source           = "./modules/networking"
  namespace        = "non-prod"
  vpc_cidr         = "10.3.0.0/16"
  public_subnets   = ["10.3.0.0/24", "10.3.1.0/24", "10.3.2.0/24"]
  private_subnets  = ["10.3.10.0/24", "10.3.11.0/24", "10.3.12.0/24"]
  database_subnets = ["10.3.100.0/24", "10.3.110.0/24", "10.3.120.0/24"]
}

# module "baston_networking" {
#   source          = "./modules/networking"
#   namespace       = "bastion"
#   vpc_cidr        = "10.1.0.0/16"
#   public_subnets  = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
#   private_subnets = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]

#   cluster_name = local.cluster_name
# }

data "aws_availability_zones" "az" {
  state = "available"

  filter {
    name   = "region-name"
    values = ["us-east-1", "us-west-2"]
  }
}

module "bastion_networking" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "bastion-vpc"

  cidr = "10.1.0.0/16"
  azs  = data.aws_availability_zones.az.names

  public_subnets  = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
}

resource "aws_vpc_peering_connection" "baston-non_prod-vpc" {
  vpc_id      = module.bastion_networking.vpc_id
  peer_vpc_id = module.non_prod_networking.vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "baston-non_prod-vpc"
  }
}

resource "aws_vpc_peering_connection" "baston-prod-vpc" {
  vpc_id      = module.bastion_networking.vpc_id
  peer_vpc_id = module.prod_networking.vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "baston-prod-vpc"
  }
}

module "non_prod_cluster" {
  source     = "./modules/eks"
  namespace  = "non-prod"
  vpc_id     = module.non_prod_networking.vpc.vpc_id
  subnet_ids = module.non_prod_networking.private_subnets
}

module "prod_cluster" {
  source     = "./modules/eks"
  namespace  = "prod"
  vpc_id     = module.prod_networking.vpc.vpc_id
  subnet_ids = module.prod_networking.private_subnets
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "ec2-bastion" {
  ami           = data.aws_ami.amazon_linux.id
  subnet_id     = module.bastion_networking.private_subnets[0]
  instance_type = "t2.micro"

  tags = {
    "Name" = "Bastion Host"
  }
}

#module "bastion_host" {
#  source = "./modules/autoscaling"
#  ssh_keypair = var.ssh_keypair
#
#  vpc = module.bastion_networking
#  sg = module.bastion_networking.sg
#}

module "prod_db_user" {
  source    = "./modules/secrets_manager"
  namespace = "prod"
}

module "non_prod_db_user" {
  source    = "./modules/secrets_manager"
  namespace = "dev"
}

module "prod_db" {
  source    = "./modules/database"
  namespace = "prod"
  vpc       = module.prod_networking.vpc
  sg        = module.prod_networking.sg
}

module "non_prod_db" {
  source    = "./modules/database"
  namespace = "dev"
  vpc       = module.non_prod_networking.vpc
  sg        = module.non_prod_networking.sg
}