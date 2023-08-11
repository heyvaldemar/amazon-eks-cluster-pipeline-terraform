# IAM role creation
resource "aws_iam_role" "eks_cluster_1_role" {
  name = "eks-cluster-${var.eks_cluster_1_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# EKS cluster policy attachment
resource "aws_iam_role_policy_attachment" "eks_cluster_1_role_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_1_role.name

  depends_on = [aws_iam_role.eks_cluster_1_role]
}

# EKS cluster creation
resource "aws_eks_cluster" "eks_cluster_1" {
  name     = var.eks_cluster_1_name
  version  = var.eks_cluster_version
  role_arn = aws_iam_role.eks_cluster_1_role.arn

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.kms_key_3.arn
    }
  }

  #tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
  vpc_config {
    subnet_ids = [
      aws_subnet.eks_private_subnet_1a.id,
      aws_subnet.eks_private_subnet_1b.id,
      aws_subnet.eks_public_subnet_1a.id,
      aws_subnet.eks_public_subnet_1b.id
    ]

    #tfsec:ignore:aws-eks-no-public-cluster-access
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # Enable logging for the EKS control plane
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_subnet.eks_private_subnet_1a,
    aws_subnet.eks_private_subnet_1b,
    aws_subnet.eks_public_subnet_1a,
    aws_subnet.eks_public_subnet_1b,
    aws_iam_role_policy_attachment.eks_cluster_1_role_AmazonEKSClusterPolicy
  ]
}
