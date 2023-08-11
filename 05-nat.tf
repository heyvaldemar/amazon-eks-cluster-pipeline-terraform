# Elastic IP allocation
resource "aws_eip" "eks_nat_eip_1" {
  domain = "vpc"

  tags = {
    Name = "nat-eip-eks-1"
  }

  depends_on = [aws_vpc.eks_vpc_1]
}

# Public NAT creation
resource "aws_nat_gateway" "eks_nat_1" {
  allocation_id = aws_eip.eks_nat_eip_1.id
  subnet_id     = aws_subnet.eks_public_subnet_1a.id

  tags = {
    Name = "nat-eks-1"
  }

  depends_on = [
    aws_internet_gateway.eks_igw_1,
    aws_eip.eks_nat_eip_1,
    aws_subnet.eks_public_subnet_1a
  ]
}
