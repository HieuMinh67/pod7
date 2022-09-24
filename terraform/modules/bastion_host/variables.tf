variable "ssh_keypair" {
  type    = string
  default = null
}

variable "bastion_ingress_cidr_block" {
  type = string
}

variable "non_prod_networking" {
  type = any
}

variable "prod_networking" {
  type = any
}

variable "kubectl_config" {
  type = any
}

variable "eks_cidr" {
  type = string
}

variable "prod_eks_sg_id" {
  type = string
}

variable "non_prod_eks_sg_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "default_region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "eks_user_role" {
  type = string
}