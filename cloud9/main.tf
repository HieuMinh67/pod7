resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnet" "this" {
  availability_zone = "${var.region}a"
  state = "available"
  vpc_id = aws_default_vpc.default.id
  default_for_az = true
}

resource "aws_cloud9_environment_ec2" "this" {
  instance_type = "t3.small"
  name          = "pod7-terraform"

  subnet_id = data.aws_subnet.this.id
}

data "aws_instance" "cloud9_instance" {
  filter {
    name = "tag:aws:cloud9:environment"
    values = [aws_cloud9_environment_ec2.this.id]
  }
}

output "cloud9_url" {
  value = "https://${var.region}.console.aws.amazon.com/cloud9/ide/${aws_cloud9_environment_ec2.this.id}"
}

resource "aws_iam_role" "this" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.this.name
}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this.name
  name = "eksworkshop-admin"
}
