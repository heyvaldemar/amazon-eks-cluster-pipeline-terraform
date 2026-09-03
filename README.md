# An EKS cluster with a node group: Terraform

[![Terraform Verification](https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/actions/workflows/terraform-verification.yml/badge.svg?branch=main)](https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/actions/workflows/terraform-verification.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository deploys an Amazon EKS cluster with a managed node group in a purpose-built VPC, the IAM roles it needs, the EBS CSI driver installed through Helm, and a self-provisioned Terraform state backend. Flat, numbered `.tf` files, no modules to chase, every provider locked to an exact build.

## What it creates

| Area | Resources |
|---|---|
| Networking | `aws_vpc`, `aws_subnet` ×4, `aws_internet_gateway`, `aws_nat_gateway`, `aws_eip`, `aws_route_table` ×2, `aws_route_table_association` ×4, `aws_flow_log` |
| Kubernetes | `aws_eks_cluster`, `aws_eks_node_group`, `helm_release`, `aws_iam_role` ×2, `aws_iam_role_policy_attachment` ×5 |
| State backend and encryption | `aws_s3_bucket` ×3, `aws_s3_bucket_versioning` ×3, `aws_s3_bucket_server_side_encryption_configuration` ×3, `aws_s3_bucket_public_access_block` ×3, `aws_s3_bucket_policy` ×2, `aws_s3_bucket_logging`, `aws_dynamodb_table`, `aws_kms_key` ×3, `aws_kms_alias` ×3, `random_id` |

24 variables, 3 outputs. Every variable has a description and a default in `00-variables.tf`.

## Prerequisites

- **Terraform 1.9.2 or newer** (any 1.x; the lockfile pins the providers, not the binary). [Install guide](https://developer.hashicorp.com/terraform/install).
- **AWS CLI** configured with credentials that can create the resources above: `aws sts get-caller-identity` must answer. [Install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- **kubectl** for the cluster you are about to create. [Install guide](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html).
## Getting started

```bash
# 1. Clone
git clone https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform
cd amazon-eks-cluster-pipeline-terraform

# 2. Replace the placeholders (table below) - your region, your secrets, your domain
$EDITOR 00-variables.tf        # or put overrides into terraform.tfvars (gitignored)

# 3. Plan, then apply
terraform init
terraform plan
terraform apply
```

Values you must change before the first apply:

| Variable | Placeholder | Meaning |
|---|---|---|
| - | - | every default is a real, generic value |

No credentials are needed beyond your AWS CLI session; generated key material (SSH keys) is created by Terraform and lands in state. Treat the state bucket as sensitive, which the KMS-encrypted, versioned, access-blocked bucket this configuration creates already does.

### State backend: bootstrap, then switch

The first `apply` runs with local state and creates the S3 bucket, DynamoDB lock table and KMS key that will hold the state from then on. Once they exist, uncomment the `backend "s3"` block in `01-providers.tf`, fill in the bucket and table names from the outputs, and run `terraform init -migrate-state`. From that point every plan locks against DynamoDB and the state is versioned and encrypted.

## Supply chain trust

- **Providers are locked to exact builds** in `.terraform.lock.hcl` for `linux_amd64`, `linux_arm64`, `darwin_amd64` and `darwin_arm64`, with checksums. CI runs `terraform init -lockfile=readonly`, so a provider cannot move without the lockfile changing in the same commit, and Dependabot proposes provider bumps as pull requests that CI validates.
- **The Terraform and tflint container images CI uses are pinned by digest**, and GitHub Actions are pinned by commit SHA.
- **No credentials in the repository.** `.env`, `*.tfvars` and state files are gitignored.

See [`SECURITY.md`](SECURITY.md) for the disclosure policy.

## Production checklist

- [ ] **Move state to the remote backend** right after the bootstrap apply (see above). Local state on a laptop is how estates get lost.
- [ ] **Narrow the security groups.** Defaults open SSH/HTTP(S) to `0.0.0.0/0` so the first deploy just works; set `allowed_ip_range` (and the per-rule variables) to your addresses before anything real runs behind them.
- [ ] **`kubectl` access.** After apply: `aws eks update-kubeconfig --region <region> --name <cluster>`; the EBS CSI driver is already installed through Helm so `PersistentVolumeClaim`s work out of the box.
- [ ] **Review the region and instance sizes** in `00-variables.tf`. Defaults are sized to boot, not to serve your load.
- [ ] **Run `terraform plan` in CI on pull requests.** `.github/workflows/02-terraform-plan-apply.yml.example` and `.gitlab-ci.yml.example` show the shape; wire them to your AWS account with OIDC federation rather than static keys.
- [ ] **Watch for drift.** `00-terraform-drift-detection.yml.example` runs a nightly plan and fails when the estate no longer matches the code.

## Testing

The [Terraform Verification](https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/actions/workflows/terraform-verification.yml?query=branch%3Amain) workflow runs on every push, pull request, and weekly: `terraform fmt -check`, `terraform init -lockfile=readonly`, `terraform validate`, `tflint`, and actionlint on the workflow itself.

What CI does not do is `apply`: this repository has no AWS account of its own, so the guarantee is that the configuration is well-formed and its providers are exactly the ones tested. Run the plan/apply pipeline examples against your own account for the rest.

---

## About the maintainer

<div align="center">

**Maintained by [Vladimir Mikhalev](https://github.com/heyvaldemar)** — Docker Captain · IBM Champion · AWS Community Builder

[YouTube](https://www.youtube.com/channel/UCf85kQ0u1sYTTTyKVpxrlyQ?sub_confirmation=1) · [Blog](https://heyvaldemar.com) · [LinkedIn](https://www.linkedin.com/in/heyvaldemar/)

</div>
