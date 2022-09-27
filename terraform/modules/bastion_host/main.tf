module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "bastion-vpc"

  cidr = "10.1.0.0/16"
  azs  = var.availability_zones

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  create_igw      = true
  public_subnets  = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
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

  tags = {
    Terraform = "true"
    type      = "bastion"
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

  image_id             = data.aws_ami.amazon_linux.id
  iam_instance_profile = var.eks_user_role
  instance_type        = "t2.medium"
  security_groups      = [aws_security_group.allow_ssh.id]
  key_name             = aws_key_pair.main.key_name
  user_data            = templatefile("${path.module}/setup_instance.sh", {
    kubeconfig = var.kubectl_config
  })

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
