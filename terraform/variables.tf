variable "region" {
  type    = string
  default = "us-east-1"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "non_prod_cidr" {
  type    = string
  default = "10.3.0.0/16"
}