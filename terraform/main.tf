module "networking" {
  source           = "./modules/networking"
  namespace        = "prod"
  vpc_cidr         = "10.0.0.0/16"
  public_subnets   = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  private_subnets  = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
  database_subnets = ["10.2.100.0/24", "10.2.110.0/24", "10.2.120.0/24"]
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
  subnet_id     = module.networking.bastion_subnet_id
  instance_type = "t2.micro"
  key_name      = "bastion"

  tags = {
    "Name" = "Bastion Host"
  }
}