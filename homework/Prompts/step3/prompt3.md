You are a senior Build engineer who designs secure GitHub Actions pipelines for Terraform on Azure.

Use the context from these files before generating anything:
- `homework/task3.md`
- `homework/CIS/cis_azure.md`
- `homework/CIS/cis_terraform.md`
- all documents in `homework/structurization/`

The repository already contains Terraform for Azure in `terraform/` and an existing workflow in `.github/workflows/terraform-azure.yml`.

Your task is to create or improve GitHub Actions instructions and workflow code for this Lab3 repository.

## Goal

Build a production-style CI/CD workflow for the Azure staging environment that:
- validates Terraform
- runs Terraform plan automatically
- applies Terraform through a controlled GitHub Actions flow
- uses GitHub OIDC to authenticate to Azure
- follows Azure and Terraform security best practices from the CIS files

## Architecture Context You Must Use

Use the design already defined in `homework/structurization/`:
- Azure platform
- Terraform IaC
- Azure Container Apps for the Nginx service
- Azure Container Registry
- Azure Monitor + Log Analytics
- Key Vault
- GitHub Actions as the CI/CD platform
- GitHub OIDC with Microsoft Entra workload identity federation

Use the current Terraform repository layout exactly as implemented:
- root Terraform folder: `terraform/`
- environment folders: `terraform/environments/dev`, `terraform/environments/staging`, `terraform/environments/prod`
- staging backend file: `terraform/environments/staging/backend.hcl`
- staging variables file: `terraform/environments/staging/terraform.tfvars`

Use the current repository reality from the structurization session:
- active environment is `staging`
- Azure region is `northeurope`
- backend uses AzureRM remote state with OIDC
- Terraform version is `1.9.x`
- AzureRM provider is `~> 4.0`

## Mandatory Pipeline Requirements

Implement instructions and workflow behavior for all of the following:

1. Pull request pipeline
- Trigger on pull requests that change Terraform or workflow files.
- Run `terraform fmt -check -recursive`.
- Run `terraform init -backend=false` for syntax and provider initialization checks where appropriate.
- Run `terraform validate`.
- Run a Terraform plan for the staging environment.
- Upload the generated plan as an artifact.
- Publish a readable plan summary to the workflow summary or PR comment.

2. Controlled apply pipeline
- Do not auto-apply on pull requests.
- Use either push to the protected main branch or `workflow_dispatch` for apply.
- Require a GitHub Environment approval gate for staging before apply.
- Re-run `terraform init` with the real backend config before apply.
- Apply only the previously generated plan or regenerate a plan in a controlled apply job.

3. Azure authentication
- Use `azure/login` with OIDC.
- Do not use service principal secrets or client secrets.
- Use repository secrets or variables only for non-secret identifiers such as:
	- `AZURE_CLIENT_ID`
	- `AZURE_TENANT_ID`
	- `AZURE_SUBSCRIPTION_ID`
- Explain that Azure RBAC for the federated identity must be least privilege and scoped narrowly.

4. Security and compliance
- Include IaC security scanning with either `tfsec` or `checkov`.
- Fail the pipeline on high-severity Terraform security findings.
- Do not hardcode secrets, credentials, subscription-specific secrets, or backend credentials.
- Keep Terraform state remote in Azure Blob backend.
- Preserve state locking and normal locking behavior.

5. Environment awareness
- Support at least `staging` now.
- Structure the workflow so it can be extended later for `dev` and `prod` without redesign.
- Reference the correct environment-specific backend and tfvars files.

6. Documentation
- Create concise instructions that explain:
	- what the workflow does
	- required GitHub repository secrets and variables
	- required GitHub Environment protection rules for staging
	- how OIDC trust must be configured in Azure
	- how to run the workflow manually
	- how to review plan output before apply

## Best-Practice Constraints

Follow these rules from the CIS guidance and structurization documents:
- least privilege RBAC only
- no Owner role unless explicitly justified
- no secrets in source control
- prefer managed identities and workload federation
- use reusable, maintainable workflow structure
- keep staging simple, secure, and cheap
- avoid unnecessary complexity

## Existing Workflow Review Requirement

Review the existing `.github/workflows/terraform-azure.yml` and improve it where needed.
Do not create a second overlapping workflow unless there is a clear reason.
Prefer upgrading the existing workflow to align with the task requirements.

## Expected Output

Generate the following:

1. Updated GitHub Actions workflow file:
- `.github/workflows/terraform-azure.yml`

2. A short documentation file describing setup and usage:
- recommended location: `homework/Prompts/step3/prompt3out.md` or another clearly appropriate markdown file in the repository

3. The workflow should include, where appropriate:
- checkout
- Terraform setup
- Azure OIDC login
- fmt
- validate
- security scan
- plan
- plan artifact upload
- approval-gated apply

## Quality Bar

The result must be repository-ready, realistic for Azure, and aligned with the existing Lab3 Terraform structure.
If something in the current workflow is weak or missing, improve it instead of describing it abstractly.