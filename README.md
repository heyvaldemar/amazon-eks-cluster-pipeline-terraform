# Amazon EKS Cluster Pipeline with Terraform

The Terraform script performs the following operations to set up an Amazon Elastic Kubernetes Service (EKS) cluster:

1. **IAM Role Creation for EKS Cluster**: The script defines an IAM role with permissions that the EKS service can assume. The IAM role name is derived from a provided variable, eks_cluster_1_name.

2. **EKS Cluster Policy Attachment**: It attaches the Amazon-managed policy, AmazonEKSClusterPolicy, to the previously created IAM role. This policy provides the necessary permissions for managing Kubernetes resources on EKS.

3. **EKS Cluster Creation**: It creates an EKS cluster using the provided variables for cluster name and version. The cluster leverages the IAM role created and attached previously. Encryption for Kubernetes secrets is enabled with a specific KMS key. It also sets up public and private access to the cluster API server.

4. **IAM Role Creation for EKS Node Group**: It sets up another IAM role with permissions that allow EC2 instances (which will serve as Kubernetes nodes) to join the EKS cluster.

5. **EKS Node Group Policy Attachments**: Multiple policies, such as AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly, and AmazonEBSCSIDriverPolicy, are attached to the IAM role created for the EKS node group. These policies collectively provide permissions needed by the Kubernetes nodes for networking, accessing the container registry, and using the EBS CSI driver.

6. **EKS Node Group Creation**: The script creates an EKS node group associated with the EKS cluster. The node group uses the IAM role and subnet IDs provided, along with other node-specific configurations such as capacity type, instance types, and scaling configurations.

7. **Amazon EBS CSI Driver Installation**: Lastly, it installs the Amazon EBS CSI driver using a Helm chart. This CSI driver allows the EKS cluster to interact with Amazon EBS for persistent volumes. The installation is performed in the kube-system namespace and the Helm chart version is provided via a variable.

# Requirements

Install kubectl by following the [guide](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html).

Install AWS CLI by following the [guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

Configure AWS CLI by following the [guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

Install Terraform by following the [guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

Install pre-commit by following the [guide](https://pre-commit.com/#install)

Install tflint by following the [guide](https://github.com/terraform-linters/tflint)

Install tfsec by following the [guide](https://github.com/aquasecurity/tfsec)

Install tfupdate by following the [guide](https://github.com/minamijoyo/tfupdate)

# Pre-commit Hooks

`.pre-commit-config.yaml` is useful for identifying simple issues before submission to code review. Pointing these issues out before code review, allows a code reviewer to focus on the architecture of a change while not wasting time with trivial style nitpicks. Make sure you have all tools from the requirements section installed for pre-commit hooks to work.

# Manual Installation

Make sure you have all tools from the requirements section installed.

You may change variables in the `00-variables.tf` to meet your requirements.

Initialize a working directory containing Terraform configuration files using the command:

`terraform init`

Run the pre-commit hooks to check for formatting and validation issues:

`pre-commit run --all-files`

Review the changes that Terraform plans to make to your infrastructure using the command:

`terraform plan`

Deploy using the command:

`terraform apply -auto-approve`

Create or update a kubeconfig file for your cluster using the command:

`aws eks --region region-code update-kubeconfig --name my-cluster`

Replace `region-code` with the AWS Region that your cluster is in and replace `my-cluster` with the name of your cluster.

Test your configuration using the command:

`kubectl get svc`

# Backend for Terraform State

The `backend` block in the `01-providers.tf` must remain commented until the bucket and the DynamoDB table are created.

After all your resources will be created, you will need to replace empty values for `region` and `bucket` in the `backend` block of the `01-providers.tf` since variables are not allowed in this block.

For `region` you need to specify the region where the S3 bucket and DynamoDB table are located. You need to use the same value that you have in the `00-variables.tf` for the `region` variable.

For `bucket` you will get its values in the output after the first run of `terraform apply -auto-approve`.

After your values are set, you can then uncomment the `backend` block and run again `terraform init` and then `terraform apply -auto-approve`.

In this way, the `terraform.tfstate` file will be stored in an S3 bucket and DynamoDB will be used for state locking and consistency checking.

# GitHub Actions

`.github` is useful if you are planning to run a pipeline on GitHub and implement the GitOps approach.

Remove the `.example` part from the name of the files in `.github/workflow` for the GitHub Actions pipeline to work.

Note, that you will need to add variables such as AWS_ACCESS_KEY_ID, AWS_DEFAULT_REGION, and AWS_SECRET_ACCESS_KEY in your GitHub projects CI/CD settings section to run your pipeline.

Therefore, you will need to create a service user in advance, using AWS Identity and Access Management (IAM) to get values for these variables and assign an access policy to the user to be able to operate with your resources.

You can delete `.github` if you are not planning to use the GitHub pipeline.

1. **Terraform Unit Tests**

This workflow executes a series of unit tests on the infrastructure code and is triggered by each commit. It begins by running [terraform fmt]( https://www.terraform.io/cli/commands/fmt) to ensure proper code formatting and adherence to terraform best practices. Subsequently, it performs [terraform validate](https://www.terraform.io/cli/commands/validate) to check for syntactical correctness and internal consistency of the code.

To further enhance the code quality and security, two additional tools, tfsec and tflint, are utilized:

tfsec: This step checks the code for potential security issues using tfsec, an open-source security scanner for Terraform. It helps identify any security vulnerabilities or misconfigurations in the infrastructure code.

tflint: This step employs tflint, a Terraform linting tool, to perform additional static code analysis and linting on the Terraform code. It helps detect potential issues and ensures adherence to best practices and coding standards specific to Terraform.

2. **Terraform Plan / Apply**

This workflow runs on every pull request and on each commit to the main branch. The plan stage of the workflow is used to understand the impact of the IaC changes on the environment by running [terraform plan](https://www.terraform.io/cli/commands/plan). This report is then attached to the PR for easy review. The apply stage runs after the plan when the workflow is triggered by a push to the main branch. This stage will take the plan document and [apply](https://www.terraform.io/cli/commands/apply) the changes after a manual review has signed off if there are any pending changes to the environment.

3. **Terraform Drift Detection**

This workflow runs on a periodic basis to scan your environment for any configuration drift or changes made outside of terraform. If any drift is detected, a GitHub Issue is raised to alert the maintainers of the project.

If you have paid version of GitHub and you wish to have the approval process implemented, please refer to the provided [guide](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment#creating-an-environment) to create an environment called production and uncomment this part in the `02-terraform-plan-apply.yml`:

```
on:
  push:
    branches:
    - main
  pull_request:
    branches:
    - main
```

And comment out this part in the `02-terraform-plan-apply.yml`:

```
on:
  workflow_run:
    workflows: [Terraform Unit Tests]
    types:
      - completed
```

Once the production environment is created, set up a protection rule and include any necessary approvers who must approve production deployments. You may also choose to restrict the environment to your main branch. For more detailed instructions, please see [here](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-protection-rules).

If you have a free version of GitHub no action is needed, but approval process will not be enabled.

# GitLab CI/CD

`.gitlab-ci.yml` is useful if you are planning to run a pipeline on GitLab and implement the GitOps approach.

Remove the `.example` part from the name of the file `.gitlab-ci.yml` for the GitLab pipeline to work.

Note, that you will need to add variables such as AWS_ACCESS_KEY_ID, AWS_DEFAULT_REGION, and AWS_SECRET_ACCESS_KEY in your GitLab projects CI/CD settings section to run your pipeline.

Therefore, you will need to create a service user in advance, using AWS Identity and Access Management (IAM) to get values for these variables and assign an access policy to the user to be able to operate with your resources.

You can delete `.gitlab-ci.yml` if you are not planning to use the GitLab pipeline.

1. **Terraform Unit Tests**

This workflow executes a series of unit tests on the infrastructure code and is triggered by each commit. It begins by running [terraform fmt]( https://www.terraform.io/cli/commands/fmt) to ensure proper code formatting and adherence to terraform best practices. Subsequently, it performs [terraform validate](https://www.terraform.io/cli/commands/validate) to check for syntactical correctness and internal consistency of the code.

To further enhance the code quality and security, two additional tools, tfsec and tflint, are utilized:

tfsec: This step checks the code for potential security issues using tfsec, an open-source security scanner for Terraform. It helps identify any security vulnerabilities or misconfigurations in the infrastructure code.

tflint: This step employs tflint, a Terraform linting tool, to perform additional static code analysis and linting on the Terraform code. It helps detect potential issues and ensures adherence to best practices and coding standards specific to Terraform.

2. **Terraform Plan / Apply**

To ensure accuracy and control over the changes made to your infrastructure, it is essential to manually initiate the job for applying the configuration. Before proceeding with the application, it is crucial to carefully review the generated plan. This step allows you to verify that the proposed changes align with your intended modifications to the infrastructure. By manually reviewing and approving the plan, you can confidently ensure that only the intended modifications will be implemented, mitigating any potential risks or unintended consequences.

# Committing Changes and Triggering Pipeline

Follow these steps to commit changes and trigger the pipeline:

1. **Install pre-commit hooks**: Make sure you have all tools from the requirements section installed.

2. **Clone the Git repository** (If you haven't already):

`git clone <repository-url>`

3. **Navigate to the repository directory**:

`cd <repository-directory>`

4. **Create a new branch**:

`git checkout -b <new-feature-branch-name>`

5. **Make changes** to the Terraform files as needed.

6. **Run pre-commit hooks**: Before committing, run the pre-commit hooks to check for formatting and validation issues:

`pre-commit run --all-files`

7. **Fix any issues**: If the pre-commit hooks report any issues, fix them and re-run the hooks until they pass.

8. **Stage and commit the changes**:

`git add .`

`git commit -m "Your commit message describing the changes"`

9. **Push the changes** to the repository:

`git push origin <branch-name>`

Replace `<branch-name>` with the name of the branch you are working on (e.g., `new-feature-branch-name`).

10.  **Monitor the pipeline**: After pushing the changes, the pipeline will be triggered automatically. You can monitor the progress of the pipeline and check for any issues in the CI/CD interface.

11.  **Merge Request**: If the pipeline is successful and the changes are on a feature branch, create a Merge Request to merge the changes into the main branch. If the pipeline fails, investigate the issue, fix it, and push the changes again to re-trigger the pipeline. Once the merge request is created, your team can review the changes, provide feedback, and approve or request changes. After the merge request has been reviewed and approved, it can be merged into the main branch to apply the changes to the production infrastructure.

# Author

I’m Vladimir Mikhalev, the [Docker Captain](https://www.docker.com/captains/vladimir-mikhalev/), but my friends can call me Valdemar.

🌐 My [website](https://www.heyvaldemar.com/) with detailed IT guides\
🎬 Follow me on [YouTube](https://www.youtube.com/channel/UCf85kQ0u1sYTTTyKVpxrlyQ?sub_confirmation=1)\
🐦 Follow me on [Twitter](https://twitter.com/heyValdemar)\
🎨 Follow me on [Instagram](https://www.instagram.com/heyvaldemar/)\
🐘 Follow me on [Mastodon](https://mastodon.social/@heyvaldemar)\
🧊 Follow me on [Bluesky](https://bsky.app/profile/heyvaldemar.bsky.social)\
🎸 Follow me on [Facebook](https://www.facebook.com/heyValdemarFB/)\
🎥 Follow me on [TikTok](https://www.tiktok.com/@heyvaldemar)\
💻 Follow me on [LinkedIn](https://www.linkedin.com/in/heyvaldemar/)\
🐈 Follow me on [GitHub](https://github.com/heyvaldemar)

# Communication

👾 Chat with IT pros on [Discord](https://discord.gg/AJQGCCBcqf)\
📧 Reach me at ask@sre.gg

# Give Thanks

💎 Support on [GitHub](https://github.com/sponsors/heyValdemar)\
🏆 Support on [Patreon](https://www.patreon.com/heyValdemar)\
🥤 Support on [BuyMeaCoffee](https://www.buymeacoffee.com/heyValdemar)\
🍪 Support on [Ko-fi](https://ko-fi.com/heyValdemar)\
💖 Support on [PayPal](https://www.paypal.com/paypalme/heyValdemarCOM)
