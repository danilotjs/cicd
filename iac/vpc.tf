# ---------------------------------------------------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  tags = {
    Name = "${var.stack}-VPC"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PUBLIC SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.stack}-Public-Subnet"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PRIVATE SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.stack}-Private-Subnet-${count.index + 1}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# INTERNET GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.stack}-IGW"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE FOR PUBLIC SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "public_rt" {
 vpc_id = aws_vpc.main.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
 }
 
 tags = {
   Name = "Public Route"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.public_rt.id
}

## ---------------------------------------------------------------------------------------------------------------------
## ELASTIC IPS
## ---------------------------------------------------------------------------------------------------------------------
#
#resource "aws_eip" "eip" {
#  count      = var.az_count
#  domain     = "vpc"
#  depends_on = [aws_internet_gateway.igw]
#  tags = {
#    Name = "${var.stack}-eip"
#  }
#}
#
#
## ---------------------------------------------------------------------------------------------------------------------
## NAT GATEWAY
## ---------------------------------------------------------------------------------------------------------------------
#
#resource "aws_nat_gateway" "nat" {
#  count         = var.az_count
#  subnet_id     = element(aws_subnet.public.*.id, count.index)
#  allocation_id = element(aws_eip.eip.*.id, count.index)
#  tags = {
#    Name = "${var.stack}-NatGateway-${count.index + 1}"
#  }
#}
#
## ---------------------------------------------------------------------------------------------------------------------
## PRIVATE ROUTE TABLE
## ---------------------------------------------------------------------------------------------------------------------
#
#resource "aws_route_table" "private-route-table" {
#  count  = var.az_count
#  vpc_id = aws_vpc.main.id
#
#  route {
#    cidr_block     = "0.0.0.0/0"
#    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
#  }
#  tags = {
#    Name = "${var.stack}-PrivateRouteTable"
#  }
#}
#
#
#
#