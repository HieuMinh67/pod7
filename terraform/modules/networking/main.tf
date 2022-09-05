data "aws_availability_zones" "az" {
  state = "available"

  filter {
    name   = "region-name"
    values = var.region_names
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "${var.namespace}-vpc"

  cidr = var.vpc_cidr
  azs  = data.aws_availability_zones.az.names

  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  create_igw = true
  # map_public_ip_on_launch = 
}