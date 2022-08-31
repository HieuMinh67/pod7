variable "namespace" {
  type = string
}

variable "region_names" {
  type    = list(string)
  default = ["us-east-1", "us-west-2"]
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "database_subnets" {
  type    = list(string)
  default = null
}