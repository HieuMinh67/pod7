# TODO: refactor
data "aws_availability_zones" "az" {
  state = "available"

  filter {
    name   = "region-name"
    values = ["us-east-1", "us-west-2"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "bastion-vpc"

  cidr = "10.1.0.0/16"
  azs  = data.aws_availability_zones.az.names

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  create_igw      = true
  public_subnets  = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
}

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

resource "aws_route" "bastion_non_prod_rtb" {
  route_table_id = module.vpc.vpc_main_route_table_id
  destination_cidr_block = var.eks_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion-non_prod-vpc.id
}

resource "aws_security_group_rule" "eks-https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = var.eks_sg_id
  to_port           = 443
  type              = "ingress"
  source_security_group_id = aws_security_group.allow_ssh.id
  description = "Allow HTTPS from Bastion Host"
}

resource "aws_security_group" "allow_ssh" {
  name        = "eks-bastion"
  description = "Bastion security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "bastion-hub"
  public_key = tls_private_key.this.public_key_openssh

  provisioner "local-exec" {
    command = "rm -f ./private-key-bastion.pem"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.this.private_key_pem}' > ./private-key-bastion.pem"
  }

  provisioner "local-exec" {
    command = "chmod 400 ./private-key-bastion.pem"
  }
}

resource "aws_launch_configuration" "bastion_config" {
  name = "bastion-LC"

  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = "t2.medium"
  security_groups = [aws_security_group.allow_ssh.id]
  key_name        = aws_key_pair.main.key_name
  user_data       = <<EOF
      #! /bin/bash

      # Install Kubectl
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      kubectl version --client

      # Install Helm
      curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
      chmod 700 get_helm.sh
      ./get_helm.sh
      helm version

      # Install AWS
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      ./aws/install
      aws --version

      # Add the kube config file
      mkdir ~/.kube
      echo "${var.kubectl_config}" >> ~/.kube/config

      # Install aws-iam-authenticator
      curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
      chmod +x ./aws-iam-authenticator
      mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
      echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
      aws-iam-authenticator help
  EOF

  # Assign EIP in user_data instead
  associate_public_ip_address = "false"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = true
    encrypted             = true
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

#resource "aws_security_group" "bastion_sc" {
#  name = "bastion-SC-ELB"
#
#  vpc_id = module.vpc.vpc_id
#
#
#  ingress {
#    description = "EC2_RemoteSSH_by_ELB"
#    from_port   = "22"
#    to_port     = "22"
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#
#  }
#
#  tags = {
#    Name = "allow_ssh"
#  }
#}

resource "aws_elb" "this" {
  name                        = "bastion-elb"
  cross_zone_load_balancing   = "true"
  idle_timeout                = "4000"
  connection_draining         = "true"
  connection_draining_timeout = "30"

  security_groups = [aws_security_group.allow_ssh.id]
  subnets         = module.vpc.public_subnets

  listener {
    instance_port     = "22"
    instance_protocol = "tcp"
    lb_port           = "22"
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    timeout             = "3"
    target              = "tcp:22"
    interval            = "5"
  }
}

resource "aws_autoscaling_group" "bastion_autoscaling" {
  name     = "Bastion-AS"
  max_size = 3
  min_size = 1

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "ELB"

  launch_configuration = aws_launch_configuration.bastion_config.name
  load_balancers       = [aws_elb.this.id]

  lifecycle {
    create_before_destroy = true
  }
}