resource "aws_vpc" "self" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}