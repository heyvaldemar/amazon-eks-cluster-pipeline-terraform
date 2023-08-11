output "bucket_1_name" {
  description = "The name of the S3 bucket that is being used to store the Terraform state file"
  value       = aws_s3_bucket.bucket_1.bucket
}

output "log_bucket_1_name" {
  description = "The name of the S3 bucket that is being used to store the Terraform state file"
  value       = aws_s3_bucket.log_bucket_1.bucket
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster_1.name
}
