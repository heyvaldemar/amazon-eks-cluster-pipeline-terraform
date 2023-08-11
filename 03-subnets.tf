# Private subnet creation
resource "aws_subnet" "eks_private_subnet_1a" {
  vpc_id                  = aws_vpc.eks_vpc_1.id
  cidr_block              = var.private_subnet_1a_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = {
    "Name"                                            = "private-eks-1-${var.region}a"
    "kubernetes.io/role/internal-elb"                 = "1"
    "kubernetes.io/cluster/${var.eks_cluster_1_name}" = "owned"
  }

  depends_on = [aws_vpc.eks_vpc_1]
}

# Private subnet creation
resource "aws_subnet" "eks_private_subnet_1b" {
  vpc_id                  = aws_vpc.eks_vpc_1.id
  cidr_block              = var.private_subnet_1b_cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = {
    "Name"                                            = "private-eks-1-${var.region}b"
    "kubernetes.io/role/internal-elb"                 = "1"
    "kubernetes.io/cluster/${var.eks_cluster_1_name}" = "owned"
  }

  depends_on = [aws_vpc.eks_vpc_1]
}

# Public subnet creation
resource "aws_subnet" "eks_public_subnet_1a" {
  vpc_id            = aws_vpc.eks_vpc_1.id
  cidr_block        = var.public_subnet_1a_cidr
  availability_zone = "${var.region}a"
  #tfsec:ignore:aws-ec2-no-public-ip-subnet
  map_public_ip_on_launch = true

  tags = {
    "Name"                                            = "public-eks-1-${var.region}a"
    "kubernetes.io/role/elb"                          = "1"
    "kubernetes.io/cluster/${var.eks_cluster_1_name}" = "owned"
  }

  depends_on = [aws_vpc.eks_vpc_1]
}

# Public subnet creation
resource "aws_subnet" "eks_public_subnet_1b" {
  vpc_id            = aws_vpc.eks_vpc_1.id
  cidr_block        = var.public_subnet_1b_cidr
  availability_zone = "${var.region}b"
  #tfsec:ignore:aws-ec2-no-public-ip-subnet
  map_public_ip_on_launch = true

  tags = {
    "Name"                                            = "public-eks-1-${var.region}b"
    "kubernetes.io/role/elb"                          = "1"
    "kubernetes.io/cluster/${var.eks_cluster_1_name}" = "owned"
  }

  depends_on = [aws_vpc.eks_vpc_1]
}
