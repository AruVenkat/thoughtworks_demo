data "aws_availability_zones" "az" {
  state = "available"
}

resource "aws_vpc" "eks-vpc" {
  cidr_block           = var.vpc-cidr-block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_internet_gateway" "eks-gateway" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    Name = "eks-gateway"
  }
}

resource "aws_route_table" "eks-public-route-table" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    Name    = "eks-Public-Subnet"
    Network = "Public"
  }
}

resource "aws_route_table" "eks-private-route-table-01" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    Name    = "eks-Private-Subnet-01"
    Network = "Private 01"
  }
}

resource "aws_route_table" "eks-private-route-table-02" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    Name    = "eks-Private-Subnet-02"
    Network = "Private 02"
  }
}

resource "aws_route" "eks-public-route" {
  route_table_id         = aws_route_table.eks-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks-gateway.id
}

resource "aws_route" "eks-private-route-01" {
  route_table_id         = aws_route_table.eks-private-route-table-01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat-gateway-01.id
  depends_on = [
    aws_internet_gateway.eks-gateway
  ]
}

resource "aws_route" "eks-private-route-02" {
  route_table_id         = aws_route_table.eks-private-route-table-02.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat-gateway-02.id
  depends_on = [
    aws_internet_gateway.eks-gateway
  ]
}

resource "aws_nat_gateway" "nat-gateway-01" {
  allocation_id = aws_eip.nat-gateway-eip-01.id
  subnet_id     = aws_subnet.public-subnet-01.id
  tags = {
    Name = "eks-Nat-Gateway-01"
  }
  depends_on = [
    aws_internet_gateway.eks-gateway
  ]
}

resource "aws_nat_gateway" "nat-gateway-02" {
  allocation_id = aws_eip.nat-gateway-eip-02.id
  subnet_id     = aws_subnet.public-subnet-02.id
  tags = {
    Name = "eks-Nat-Gateway-02"
  }
  depends_on = [
    aws_internet_gateway.eks-gateway
  ]
}

resource "aws_eip" "nat-gateway-eip-01" {
  vpc = true
  depends_on = [
    aws_internet_gateway.eks-gateway
  ]
}

resource "aws_eip" "nat-gateway-eip-02" {
  vpc = true
  depends_on = [
    aws_internet_gateway.eks-gateway
  ]
}

resource "aws_subnet" "public-subnet-01" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.public-subnet-block-01
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[0]
  tags = {
    Name                     = "eks-public-subnet-01"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "public-subnet-02" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.public-subnet-block-02
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[1]
  tags = {
    Name                     = "eks-public-subnet-02"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "private-subnet-01" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.private-subnet-block-01
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[0]
  tags = {
    Name                     = "eks-private-subnet-01"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "private-subnet-02" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.private-subnet-block-02
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[1]
  tags = {
    Name                     = "eks-private-subnet-02"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table_association" "public-subnet-01-RT-association" {
  subnet_id      = aws_subnet.public-subnet-01.id
  route_table_id = aws_route_table.eks-public-route-table.id
}
resource "aws_route_table_association" "public-subnet-02-RT-association" {
  subnet_id      = aws_subnet.public-subnet-02.id
  route_table_id = aws_route_table.eks-public-route-table.id
}
resource "aws_route_table_association" "private-subnet-01-RT-association" {
  subnet_id      = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.eks-private-route-table-01.id
}
resource "aws_route_table_association" "private-subnet-02-RT-association" {
  subnet_id      = aws_subnet.private-subnet-02.id
  route_table_id = aws_route_table.eks-private-route-table-02.id
}

resource "aws_security_group" "eks-sg" {
  name        = "eks-Security-Group"
  vpc_id      = aws_vpc.eks-vpc.id
  description = "Cluster communication with worked nodes"
}

resource "aws_security_group_rule" "eks-sg-rule" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks-bastion-sg.id
  security_group_id        = aws_security_group.eks-sg.id
}
