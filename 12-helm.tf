# Amazon EBS CSI driver installation
resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  version    = var.helm_ebs_csi_driver_version
  timeout    = var.helm_timeout_seconds

  depends_on = [
    aws_eks_cluster.eks_cluster_1,
    aws_iam_role_policy_attachment.eks_node_1_role_AmazonEBSCSIDriverPolicy
  ]
}
