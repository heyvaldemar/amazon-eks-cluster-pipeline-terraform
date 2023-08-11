# AWS Infrastructure Variables
variable "region" {
  description = "The AWS region in which the infrastructure will be deployed"
  type        = string
  default     = "eu-west-1"
}

# Virtual Private Cloud Variables
variable "vpc_1_cidr" {
  description = "The IP range for the Virtual Private Cloud (VPC) that will be created"
  type        = string
  default     = "10.0.0.0/16"
}

# Private Subnet Variables
variable "private_subnet_1a_cidr" {
  description = "The IP range for the first private subnet that will be created within the VPC"
  type        = string
  default     = "10.0.0.0/19"
}

variable "private_subnet_1b_cidr" {
  description = "The IP range for the second private subnet that will be created within the VPC"
  type        = string
  default     = "10.0.32.0/19"
}

# Public Subnet Variables
variable "public_subnet_1a_cidr" {
  description = "The IP range for the first public subnet that will be created within the VPC"
  type        = string
  default     = "10.0.64.0/19"
}

variable "public_subnet_1b_cidr" {
  description = "The IP range for the second public subnet that will be created within the VPC"
  type        = string
  default     = "10.0.96.0/19"
}

# Route Variables
variable "private_route_1_cidr" {
  description = "The IP range for the private route that will be created within the VPC"
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_route_1_cidr" {
  description = "The IP range for the public route that will be created within the VPC"
  type        = string
  default     = "0.0.0.0/0"
}

# EKS Cluster Variables
variable "eks_cluster_1_name" {
  description = "The name of the EKS cluster that will be created"
  type        = string
  default     = "zeus"
}

variable "eks_cluster_version" {
  description = "The version of EKS to use for the cluster. This should be a float or integer value, such as 1.21 or 1.25."
  type        = number
  default     = 1.25
}

# EKS Node Group Variables
variable "eks_node_group_1_name" {
  description = "The name of the node group that will be created within the EKS cluster"
  type        = string
  default     = "private-node-group-eks-1"
}

variable "eks_node_group_1_capacity_type" {
  description = "The capacity type for the node group that will be created within the EKS cluster"
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_node_group_1_instance_types" {
  description = "The instance types of the EKS node group"
  type        = string
  default     = "t2.xlarge"
}

variable "eks_node_group_1_desired_size" {
  description = "The desired number of worker nodes in the EKS cluster"
  type        = number
  default     = 1
}

variable "eks_node_group_1_max_size" {
  description = "The maximum number of worker nodes in the EKS cluster"
  type        = number
  default     = 5
}

variable "eks_node_group_1_min_size" {
  description = "The minimum number of worker nodes in the EKS cluster"
  type        = number
  default     = 1
}

variable "eks_node_group_1_max_unavailable" {
  description = "The maximum number of worker nodes that can be unavailable during a deployment update"
  type        = number
  default     = 1
}

variable "eks_node_group_1_labels" {
  description = "A map of key-value pairs used to label the worker nodes in the EKS cluster"
  type        = map(string)
  default = {
    role = "general"
  }
}

# KMS Variables
variable "kms_key_1_default_retention_days" {
  description = "The default retention period in days for keys created in the KMS keyring"
  type        = number
  default     = 10
}

variable "kms_key_2_default_retention_days" {
  description = "The default retention period in days for keys created in the KMS keyring"
  type        = number
  default     = 10
}

variable "kms_key_3_default_retention_days" {
  description = "The default retention period in days for keys created in the KMS keyring"
  type        = number
  default     = 10
}

# DynamoDB Variables
variable "dynamodb_terraform_state_lock_1_billing_mode" {
  description = "The billing mode for the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "PAY_PER_REQUEST"
}

# Helm Variables
variable "helm_ebs_csi_driver_version" {
  description = "The version of the AWS EBS CSI Driver Helm chart to deploy"
  type        = string
  default     = "2.18.0"
}

variable "helm_timeout_seconds" {
  type        = number
  description = "Helm chart deployment can sometimes take longer than the default 5 minutes"
  default     = 800
}
