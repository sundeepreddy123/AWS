# ------------------------------
# VPC
# ------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

# ------------------------------
# Public Subnets
# ------------------------------
resource "aws_subnet" "public" {
  count             = length(var.az_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone = element(var.az_zones, count.index)
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
    Tier = "Public"
    #  "kubernetes.io/role/elb" = "1"
    #  "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

# ------------------------------
# Private Subnets
# ------------------------------
resource "aws_subnet" "private" {
  count             = length(var.az_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 3)
  availability_zone = element(var.az_zones, count.index)
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
    Tier = "Private"
    # "kubernetes.io/role/internal-elb" = "1"
    # "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

# ------------------------------
# Internet Gateway
# ------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

# ------------------------------
# Elastic IPs for NAT
# ------------------------------
resource "aws_eip" "nat" {
  count  = length(var.az_zones)
  domain = "vpc"
  tags = {
    Name = "${var.env}-nat-eip-${count.index + 1}"
  }
}


# ------------------------------
# NAT Gateways
# ------------------------------
resource "aws_nat_gateway" "nat" {
  count         = length(var.az_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.env}-nat-${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.igw]
}

# ------------------------------
# Route Tables
# ------------------------------
# Public RT (shared by all public subnets)
resource "aws_route_table" "public" {
  count  = length(var.az_zones)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-public-rt-${count.index + 1}"
  }
}
# Default route from public RT to IGW
resource "aws_route" "public_internet_access" {
  count                  = length(var.az_zones)
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
# Associate all public subnets → public RT
resource "aws_route_table_association" "public" {
  count          = length(var.az_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}
# Private RTs (one per AZ → -> NAT in same AZ)
resource "aws_route_table" "private" {
  count  = length(var.az_zones)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-private-rt-${count.index + 1}"
  }
}
# Default route from private RT → NAT
resource "aws_route" "private_nat_gateway" {
  count                  = length(var.az_zones)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}
# Associate private subnets → private RT per AZ
resource "aws_route_table_association" "private" {
  count          = length(var.az_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}