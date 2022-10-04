data "aws_subnet" "this" {
  availability_zone = "${var.region}a"
  state = "available"
  vpc_id = aws_default_vpc.default.id
  default_for_az = true
}
