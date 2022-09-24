variable "namespace" {
  type = string
}

variable "vpc_id" {
  type = any
}

variable "subnet_ids" {
  type = any
}

variable "eks_user_role" {
  type = string
}