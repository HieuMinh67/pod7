variable "region" {
  type    = string
  default = "us-west-2"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "non_prod_cidr" {
  type = string
  default = "10.3.0.0/16"
}