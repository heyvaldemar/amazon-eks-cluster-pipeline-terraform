# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.0] - 2026-10-08

### Changed

- **The default EKS version is now `"1.36"`, one AWS still supports.**
  `eks_cluster_version` defaulted to `1.25`, which left EKS extended support on
  2025-05-01, so a new cluster from the defaults could no longer be created.
  `1.36` is in standard support until 2027-08-02. The variable is now a
  string: as a number, `1.30` would have reached AWS as `1.3`. If you set it
  in a `.tfvars` file, quote it.

  **If your cluster was built from the default and you never set
  `eks_cluster_version`,** this release changes the version your next plan
  asks for. EKS upgrades one minor version at a time and never downgrades.
  Before you apply, set `eks_cluster_version` in your `.tfvars` to the version
  the cluster runs today (`aws eks describe-cluster --name <name> --query
  cluster.version --output text`), quoted, and move up from there one minor
  version per apply.

  **Not verified on 1.36:** the EBS CSI driver Helm chart stays pinned at
  `2.18.0` (`helm_ebs_csi_driver_version`). Its compatibility with Kubernetes
  1.36 has not been tested. Check it before you rely on it, or set a current
  chart version.

### Fixed

- **`update.sh` stops on a `.tfvars` it cannot read, before the checkout.** Every value in it used to read as missing; now it names the file, its owner and mode, and changes nothing.

## [1.2.1] - 2026-10-02

### Changed

- **`hashicorp/aws` 6.66.0 → 6.67.0.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.

### Security

- **`hashicorp/terraform:1.16` was rebuilt upstream**; the pin moved from `sha256:985cdc6c1d9b…` to `sha256:c7926feace05…`. Same version, same tag, a rebuilt binary — the one that formats, validates and lints this configuration.

## [1.2.0] - 2026-09-26

### Added

- **A test of what the configuration promises, and proof that the test can fail.** `tests/posture.tftest.hcl` plans the configuration with its default variables against mocked providers and makes 16 assertions about what it would build; `tests/plant_violations.py` breaks them 13 ways on a copy and requires the test to notice each. Both run in CI on every push. The README's Testing section also lists, plainly, what the defaults do not promise.

## [1.1.5] - 2026-09-25

### Changed

- **`hashicorp/aws` 6.65.0 → 6.66.0.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.

### Security

- **`hashicorp/terraform:1.16` was rebuilt upstream**; the pin moved from `sha256:c9a9d991c113…` to `sha256:985cdc6c1d9b…`. Same version, same tag, a rebuilt binary — the one that formats, validates and lints this configuration.

## [1.1.4] - 2026-09-18

### Changed

- **`hashicorp/aws` 6.64.0 → 6.65.0.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.

### Security

- **`hashicorp/terraform:1.16` was rebuilt upstream**; the pin moved from `sha256:c3308fcbb530…` to `sha256:c9a9d991c113…`. Same version, same tag, a rebuilt binary — the one that formats, validates and lints this configuration.

## [1.1.3] - 2026-09-14

### Changed

- **`hashicorp/tls` 4.4.0 → 4.4.1.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.
- **`hashicorp/random` 3.9.0 → 3.9.1.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.
- **`hashicorp/aws` 6.63.0 → 6.64.0.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.

## [1.1.2] - 2026-09-09

### Changed

- **Terraform 1.10 → 1.16 in CI.** The same binary that formats, validates and lints this configuration; `terraform validate` ran against it before this landed.

## [1.1.1] - 2026-09-09

### Changed

- **`hashicorp/tls` 4.3.0 → 4.4.0.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.
- **`hashicorp/helm` 3.2.0 → 3.3.0.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.
- **`hashicorp/aws` 6.62.0 → 6.63.0.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.

## [1.1.0] - 2026-09-08

### Added

- **`update.sh`: move between release tags, then plan.** It updates to the latest release (a combination this repository's CI has formatted, initialised, validated and linted), refuses to cross a major version unattended, refuses to run over local changes, and names any variable that became required since your version before anything has moved. It never applies: it prints the plan and stops, because applying against live infrastructure is a decision.
- **A daily freshness check on every pin.** Each provider in `.terraform.lock.hcl` is compared against the registry, both pinned CI images against what their tags resolve to now, and the Terraform line against the latest release. A provider that moved is a provider whose new and removed arguments this configuration has not been validated against yet.

## [1.0.0] - 2026-09-02

First semver release. Brings this configuration to the fleet standard.

### Fixed

- **`terraform validate` failed on a fresh clone**: the helm provider block used the 2.x nested `kubernetes {}` syntax, which the pinned 3.x line rejects. Now the 3.x `kubernetes = {}` attribute.

### Changed

- `required_version` relaxed from an exact `1.9.2` pin (which rejected
  every other Terraform binary) to `>= 1.9.2, < 2.0.0`.
- AWS provider constraint moved to `~> 6.62.0`; personal domain
  defaults replaced with `example.com` placeholders.

### Added

- **`.terraform.lock.hcl`** locking every provider to exact builds and
  checksums for four platforms.
- **Terraform Verification workflow**: `fmt -check`, `init
  -lockfile=readonly`, `validate`, `tflint`, actionlint, on every push,
  pull request, and weekly.
- MIT `LICENSE`, `SECURITY.md`, and a README that says what gets
  created, what must be changed before the first apply, and what CI
  does and does not prove.

[Unreleased]: https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/compare/v1.1.5...HEAD
[1.1.5]: https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/heyvaldemar/amazon-eks-cluster-pipeline-terraform/releases/tag/v1.0.0
