# Private route table creation
resource "aws_route_table" "eks_private_route_1" {
  vpc_id = aws_vpc.eks_vpc_1.id

  route {
    cidr_block     = var.private_route_1_cidr
    nat_gateway_id = aws_nat_gateway.eks_nat_1.id
  }

  tags = {
    Name = "private-route-eks-1"
  }

  depends_on = [aws_nat_gateway.eks_nat_1]
}

# Public route table creation
resource "aws_route_table" "eks_public_route_1" {
  vpc_id = aws_vpc.eks_vpc_1.id

  route {
    cidr_block = var.public_route_1_cidr
    gateway_id = aws_internet_gateway.eks_igw_1.id
  }

  tags = {
    Name = "public-route-eks-1"
  }

  depends_on = [aws_internet_gateway.eks_igw_1]
}

# Private route table association
resource "aws_route_table_association" "eks_private_subnet_1a" {
  subnet_id      = aws_subnet.eks_private_subnet_1a.id
  route_table_id = aws_route_table.eks_private_route_1.id

  depends_on = [
    aws_subnet.eks_private_subnet_1a,
    aws_route_table.eks_private_route_1
  ]
}

# Private route table association
resource "aws_route_table_association" "eks_private_subnet_1b" {
  subnet_id      = aws_subnet.eks_private_subnet_1b.id
  route_table_id = aws_route_table.eks_private_route_1.id

  depends_on = [
    aws_subnet.eks_private_subnet_1b,
    aws_route_table.eks_private_route_1
  ]
}

# Public route table association
resource "aws_route_table_association" "eks_public_subnet_1a" {
  subnet_id      = aws_subnet.eks_public_subnet_1a.id
  route_table_id = aws_route_table.eks_public_route_1.id

  depends_on = [
    aws_subnet.eks_public_subnet_1a,
    aws_route_table.eks_public_route_1
  ]
}

# Public route table association
resource "aws_route_table_association" "eks_public_subnet_1b" {
  subnet_id      = aws_subnet.eks_public_subnet_1b.id
  route_table_id = aws_route_table.eks_public_route_1.id

  depends_on = [
    aws_subnet.eks_public_subnet_1b,
    aws_route_table.eks_public_route_1
  ]
}
