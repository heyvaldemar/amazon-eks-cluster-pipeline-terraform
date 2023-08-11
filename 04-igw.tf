# Internet gateway creation
resource "aws_internet_gateway" "eks_igw_1" {
  vpc_id = aws_vpc.eks_vpc_1.id

  tags = {
    Name = "igw-eks-1"
  }

  depends_on = [aws_vpc.eks_vpc_1]
}
