# IAM role creation
resource "aws_iam_role" "eks_node_1_role" {
  name = "node-role-1-eks-1"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Node group policy attachment
resource "aws_iam_role_policy_attachment" "eks_node_1_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_1_role.name

  depends_on = [aws_iam_role.eks_node_1_role]
}

# Node group policy attachment
resource "aws_iam_role_policy_attachment" "eks_node_1_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_1_role.name

  depends_on = [aws_iam_role.eks_node_1_role]
}

# Node group policy attachment
resource "aws_iam_role_policy_attachment" "eks_node_1_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_1_role.name

  depends_on = [aws_iam_role.eks_node_1_role]
}

# Node group policy attachment for Amazon EBS CSI driver
resource "aws_iam_role_policy_attachment" "eks_node_1_role_AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_node_1_role.name

  depends_on = [aws_iam_role.eks_node_1_role]
}

# Node group creation
resource "aws_eks_node_group" "private_eks_node_group_1" {
  cluster_name    = var.eks_cluster_1_name
  node_group_name = var.eks_node_group_1_name
  node_role_arn   = aws_iam_role.eks_node_1_role.arn

  subnet_ids = [
    aws_subnet.eks_private_subnet_1a.id,
    aws_subnet.eks_private_subnet_1b.id
  ]

  capacity_type  = var.eks_node_group_1_capacity_type
  instance_types = [var.eks_node_group_1_instance_types]

  scaling_config {
    desired_size = var.eks_node_group_1_desired_size
    max_size     = var.eks_node_group_1_max_size
    min_size     = var.eks_node_group_1_min_size
  }

  update_config {
    max_unavailable = var.eks_node_group_1_max_unavailable
  }

  labels = var.eks_node_group_1_labels

  depends_on = [
    aws_eks_cluster.eks_cluster_1,
    aws_iam_role_policy_attachment.eks_node_1_role_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_1_role_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_1_role_AmazonEC2ContainerRegistryReadOnly
  ]
}
