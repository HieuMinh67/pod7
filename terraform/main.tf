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

module "baston_networking" {
  source          = "./modules/networking"
  namespace       = "bastion"
  vpc_cidr        = "10.1.0.0/16"
  public_subnets  = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
}

resource "aws_vpc_peering_connection" "baston-non_prod-vpc" {
  vpc_id      = module.baston_networking.vpc_id
  peer_vpc_id = module.non_prod_networking.vpc_id
  auto_accept = true

  tags = {
    Name = "baston-non_prod-vpc"
  }
}

resource "aws_vpc_peering_connection" "baston-prod-vpc" {
  vpc_id      = module.baston_networking.vpc_id
  peer_vpc_id = module.prod_networking.vpc_id
  auto_accept = true

  tags = {
    Name = "baston-prod-vpc"
  }
}

module "non_prod_cluster" {
  source     = "./modules/eks"
  namespace  = "prod"
  vpc_id     = module.prod_networking.vpc_id
  subnet_ids = module.prod_networking.private_subnets
}

module "prod_cluster" {
  source     = "./modules/eks"
  namespace  = "prod"
  vpc_id     = module.prod_networking.vpc_id
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
  subnet_id     = module.baston_networking.private_subnets[0]
  instance_type = "t2.micro"

  tags = {
    "Name" = "Bastion Host"
  }
}