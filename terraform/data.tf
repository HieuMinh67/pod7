data "aws_availability_zones" "az" {
  state = "available"

  filter {
    name   = "region-name"
    values = [var.region]
  }
}