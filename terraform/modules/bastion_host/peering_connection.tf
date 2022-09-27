resource "aws_vpc_peering_connection" "bastion-non_prod-vpc" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = var.non_prod_networking.vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "bastion-non_prod-vpc"
  }
}

resource "aws_vpc_peering_connection" "bastion-prod-vpc" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = var.prod_networking.vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "bastion-prod-vpc"
  }
}

resource "aws_vpc_peering_connection" "default-prod-vpc" {
  vpc_id      = aws_default_vpc.default.id
  peer_vpc_id = var.prod_networking.vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "default-prod-vpc"
  }
}

resource "aws_vpc_peering_connection" "default-non-prod-vpc" {
  vpc_id      = aws_default_vpc.default.id
  peer_vpc_id = var.non_prod_networking.vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "default-prod-vpc"
  }
}
