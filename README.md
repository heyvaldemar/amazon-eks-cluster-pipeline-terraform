# An EKS cluster with a node group: Terraform

[![Terraform Verification](https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/actions/workflows/terraform-verification.yml/badge.svg?branch=main)](https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/actions/workflows/terraform-verification.yml)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/14911/badge)](https://www.bestpractices.dev/projects/14911)
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

## Updating

`./update.sh` moves this checkout to the latest release tag — a combination this repository's CI has formatted, initialised against its lockfile, validated and linted — then runs `terraform init -upgrade` and prints a plan. **It never applies.** Reading the plan and running `terraform apply` is yours. It refuses to cross a major version unattended, refuses to run over local changes, and names any variable that became required since your version before anything has moved. `./update.sh --dry-run` says what would happen; `--no-plan` updates the files and stops.

Provider versions are watched daily: every provider in `.terraform.lock.hcl` is compared against the registry, and both pinned CI images against their tags. A provider that moved inside its major line is bumped through the same CI gate — `fmt`, `init` against the lockfile, `validate`, `tflint` — and released; a major is prepared on a branch for you to read.

## Supply chain trust

- **Providers are locked to exact builds** in `.terraform.lock.hcl` for `linux_amd64`, `linux_arm64`, `darwin_amd64` and `darwin_arm64`, with checksums. CI runs `terraform init -lockfile=readonly`, so a provider cannot move without the lockfile changing in the same commit, and Dependabot proposes provider bumps as pull requests that CI validates.
- **The Terraform and tflint container images CI uses are pinned by digest**, and GitHub Actions are pinned by commit SHA.
- **No credentials in the repository.** `.env`, `*.tfvars` and state files are gitignored.

See [`SECURITY.md`](SECURITY.md) for the disclosure policy.

### Verify what you deploy

Every release from v1.1.4 on carries three files made on GitHub's runner with a short-lived identity and no stored key: `amazon-eks-cluster-pipeline-terraform-<tag>.tar.gz`, a `git archive` of exactly the tree the tag points at; `amazon-eks-cluster-pipeline-terraform-<tag>.tar.gz.sigstore.json`, a keyless [Sigstore](https://www.sigstore.dev/) signature over it; and `amazon-eks-cluster-pipeline-terraform-<tag>.intoto.jsonl`, [SLSA](https://slsa.dev/) build provenance from the SLSA generator. To check them with nothing from this repository trusted:

```bash
cosign verify-blob amazon-eks-cluster-pipeline-terraform-<tag>.tar.gz \
  --bundle amazon-eks-cluster-pipeline-terraform-<tag>.tar.gz.sigstore.json \
  --certificate-identity-regexp '^https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com

slsa-verifier verify-artifact amazon-eks-cluster-pipeline-terraform-<tag>.tar.gz \
  --provenance-path amazon-eks-cluster-pipeline-terraform-<tag>.intoto.jsonl \
  --source-uri github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform
```

Add `--source-tag <tag>` for a release published after 24 September 2026, which is signed by the run that published it. The five releases before that date were signed by a run started by hand on `main`, so their provenance names the branch, not the tag; the archive is still the tag's tree, and the signature still belongs to this repository's workflow. The workflow that makes them is [`release-assets.yml`](.github/workflows/release-assets.yml).

## Production checklist

- [ ] **Move state to the remote backend** right after the bootstrap apply (see above). Local state on a laptop is how estates get lost.
- [ ] **Narrow the security groups.** Defaults open SSH/HTTP(S) to `0.0.0.0/0` so the first deploy just works; set `allowed_ip_range` (and the per-rule variables) to your addresses before anything real runs behind them.
- [ ] **`kubectl` access.** After apply: `aws eks update-kubeconfig --region <region> --name <cluster>`; the EBS CSI driver is already installed through Helm so `PersistentVolumeClaim`s work out of the box.
- [ ] **Review the region and instance sizes** in `00-variables.tf`. Defaults are sized to boot, not to serve your load.
- [ ] **Run `terraform plan` in CI on pull requests.** `.github/workflows/02-terraform-plan-apply.yml.example` and `.gitlab-ci.yml.example` show the shape; wire them to your AWS account with OIDC federation rather than static keys.
- [ ] **Watch for drift.** `00-terraform-drift-detection.yml.example` runs a nightly plan and fails when the estate no longer matches the code.

## Testing

The [Terraform Verification](https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/actions/workflows/terraform-verification.yml?query=branch%3Amain) workflow runs on every push, pull request, and weekly: `terraform fmt -check`, `terraform init -lockfile=readonly`, `terraform validate`, `tflint`, and actionlint on the workflow itself.

**What the configuration promises is tested, not just parsed.** [`tests/posture.tftest.hcl`](tests/posture.tftest.hcl) plans the configuration with its default variables against mocked providers, with no AWS account and no credentials involved, and makes 16 assertions about what that plan would build: KMS keys rotate, no bucket can be made public, buckets are encrypted with KMS and versioned, the state lock table is encrypted and recoverable to a point in time, and each resource type below it keeps its own promise. [`tests/plant_violations.py`](tests/plant_violations.py) then breaks those promises one at a time on a copy of the configuration, 13 ways listed in [`tests/plants.tsv`](tests/plants.tsv), and fails the run if the test stays green through any of them. Both run in CI on every push.

```bash
terraform init -backend=false && terraform test
TERRAFORM_IMAGE=hashicorp/terraform:1.16 python3 tests/plant_violations.py
```

What CI does not do is `apply`: this repository has no AWS account of its own, so the guarantee is about what the configuration asks AWS for, not about what AWS then does. Run the plan/apply pipeline examples against your own account for the rest.

**What the defaults do not promise, stated rather than hidden.** The test asserts only what the defaults deliver; these are the places they do not, and each is a decision to make before `apply`:

- **The EKS API endpoint is public** (`endpoint_public_access = true`), authenticated but reachable from the internet. Set it to `false` with private access on if your operators work from inside the VPC.

---

## About the maintainer

<div align="center">

**Maintained by [Vladimir Mikhalev](https://github.com/heyvaldemar)** — Docker Captain · IBM Champion · AWS Community Builder

[YouTube](https://www.youtube.com/channel/UCf85kQ0u1sYTTTyKVpxrlyQ?sub_confirmation=1) · [Blog](https://heyvaldemar.com) · [LinkedIn](https://www.linkedin.com/in/heyvaldemar/)

</div>
