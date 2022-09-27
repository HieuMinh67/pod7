resource "aws_route" "bastion_non_prod_rtb" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = var.non_prod_networking.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion-non_prod-vpc.id
}

resource "aws_route" "non_prod_bastion_rtb" {
  route_table_id            = var.non_prod_networking.vpc.private_route_table_ids[0]
  destination_cidr_block    = module.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion-non_prod-vpc.id
}

resource "aws_route" "bastion_prod_rtb" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = var.prod_networking.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion-prod-vpc.id
}

resource "aws_route" "prod_bastion_rtb" {
  route_table_id            = var.prod_networking.vpc.private_route_table_ids[0]
  destination_cidr_block    = module.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion-prod-vpc.id
}

resource "aws_route" "default_prod_rtb" {
  route_table_id            = aws_default_vpc.default.default_route_table_id
  destination_cidr_block    = var.prod_networking.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default-prod-vpc.id
}

resource "aws_route" "prod_default_rtb" {
  route_table_id            = var.prod_networking.vpc.private_route_table_ids[0]
  destination_cidr_block    = aws_default_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default-prod-vpc.id
}

resource "aws_route" "default_non_prod_rtb" {
  route_table_id            = aws_default_vpc.default.default_route_table_id
  destination_cidr_block    = var.non_prod_networking.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default-prod-vpc.id
}

resource "aws_route" "non_prod_default_rtb" {
  route_table_id            = var.non_prod_networking.vpc.private_route_table_ids[0]
  destination_cidr_block    = aws_default_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default-non-prod-vpc.id
}
