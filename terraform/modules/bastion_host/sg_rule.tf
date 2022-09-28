data "aws_security_group" "cloud9_sg" {
  filter {
    name = "Name"
    values = ["aws-cloud9-*"]
  }
}
resource "aws_security_group_rule" "default_prod_eks_https" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.prod_eks_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = data.aws_security_group.cloud9_sg[0].id
  description              = "Allow HTTPS from Cloud9"
}

resource "aws_security_group_rule" "default_non_prod_eks_https" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.non_prod_eks_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = data.aws_security_group.cloud9_sg[0].id
  description              = "Allow HTTPS from Cloud9"
}

resource "aws_security_group_rule" "prod_eks_https" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.prod_eks_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.allow_ssh.id
  description              = "Allow HTTPS from Bastion Host"
}

resource "aws_security_group_rule" "non_prod_eks_https" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.non_prod_eks_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.allow_ssh.id
  description              = "Allow HTTPS from Bastion Host"
}