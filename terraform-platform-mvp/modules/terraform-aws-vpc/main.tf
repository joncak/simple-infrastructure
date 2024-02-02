# tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "self" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.self.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]

  tags = {
    Name                     = "${var.name_prefix}-public-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.self.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name                              = "${var.name_prefix}-private-${count.index}"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_internet_gateway" "self" {

  vpc_id = aws_vpc.self.id

  tags = {
    Name = "${var.name_prefix}-internet-gateway"
  }
}

resource "aws_eip" "self" {
  count      = var.enable_nat_gateway ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.self]

  tags = {
    Name = "${var.name_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "self" {
  count         = var.enable_nat_gateway ? 1 : 0
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.self[count.index].id

  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }
  depends_on = [aws_internet_gateway.self]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.self.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.self.id
  }
  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.self.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.self[0].id
  }
  tags = {
    Name = "${var.name_prefix}-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}