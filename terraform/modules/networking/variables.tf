variable "namespace" {
  type = string
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
  default = []
}

variable "availability_zones" {
  type = list(string)
}