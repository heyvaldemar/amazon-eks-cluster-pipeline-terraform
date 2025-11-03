terraform {

  /*#
The "backend" block in the "01-providers.tf" must remain commented until the bucket and the DynamoDB table are created.

After all your resources will be created, you will need to replace empty values
for "region" and "bucket" in the "backend" block of the "00-providers.tf" since variables are not allowed in this block.

For "region" you need to specify the region where the S3 bucket and DynamoDB table are located.
You need to use the same value that you have in the "00-variables.tf" for the "region" variable.

For "bucket" you will get its values in the output after the first run of "terraform apply -auto-approve".

After your values are set, you can then uncomment the "backend" block and run again "terraform init" and then "terraform apply -auto-approve".

In this way, the "terraform.tfstate" file will be stored in an S3 bucket and DynamoDB will be used for state locking and consistency checking.
*/

  /*#
  backend "s3" {
    region         = ""
    bucket         = ""
    key            = "state/terraform.tfstate"
    kms_key_id     = "alias/terraform-bucket-key-eks-1"
    dynamodb_table = "dynamodb-terraform-state-lock-eks-1"
    encrypt        = true
  }
*/

  # Terraform version (replace with yours)
  required_version = "1.9.2"

  # Terraform providers
  required_providers {
    aws = {
      source = "hashicorp/aws"

      # Provider versions
      version = "~> 6.19.0"
    }

    tls = {
      source = "hashicorp/tls"

      # Provider versions
      version = "~> 4.1.0"
    }

    random = {
      source = "hashicorp/random"

      # Provider versions
      version = "~> 3.7.2"
    }

    helm = {
      source = "hashicorp/helm"

      # Provider versions
      version = "~> 3.0.1"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster_1" {
  name = aws_eks_cluster.eks_cluster_1.name
}

data "aws_eks_cluster_auth" "cluster_1_auth" {
  name = aws_eks_cluster.eks_cluster_1.name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster_1.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_1.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster_1_auth.token
  }
}
