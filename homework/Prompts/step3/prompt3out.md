# GitHub Actions Instructions for Lab3 Terraform on Azure

This repository uses the workflow in `.github/workflows/terraform-azure.yml` to validate, plan, and apply Terraform for the Azure environment defined under `terraform/`.

## What the Workflow Does

- Pull requests to `main` that change Terraform or the workflow run a quality gate.
- The quality gate runs:
  - `terraform fmt -check -recursive`
  - `terraform init -backend=false`
  - `terraform validate`
  - `tfsec --minimum-severity HIGH`
- After the quality gate passes, the workflow runs `terraform plan` for the selected environment.
- The generated plan is uploaded as an artifact and a readable plan excerpt is published to the workflow summary.
- Applies do not run on pull requests.
- Applies run on:
  - pushes to `main` for `staging`
  - `workflow_dispatch` for a selected environment (`dev`, `staging`, or `prod`)
- The apply job is bound to the matching GitHub Environment, so approval rules can block deployment before `terraform apply`.

## Environment and File Mapping

- Default automated environment: `staging`
- Terraform root: `terraform/`
- Backend file pattern: `terraform/environments/<environment>/backend.hcl`
- Variable file pattern: `terraform/environments/<environment>/terraform.tfvars`
- Current active staging backend file: `terraform/environments/staging/backend.hcl`

## Required Repository Variables

Create these GitHub repository variables under Settings > Secrets and variables > Actions > Variables:

| Variable | Purpose |
|---|---|
| `AZURE_CLIENT_ID` | Client ID of the Azure application or user-assigned managed identity that has the federated credential |
| `AZURE_TENANT_ID` | Microsoft Entra tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID used for Lab3 |

These are identifiers, not secrets, so store them as repository variables instead of encrypted secrets.

## Secrets

No Azure client secret is required.

Do not add:
- `AZURE_CLIENT_SECRET`
- long-lived service principal passwords
- backend storage account keys
- any Terraform secrets committed to source control

If future notifications are added, store notification webhooks as GitHub secrets.

## Required GitHub Environment Protection

Create a GitHub Environment named `staging`.

Recommended protection rules for `staging`:
- required reviewers enabled
- deployment branch restriction to `main`
- optional wait timer if you want a cooling-off period before apply

If you use manual deployments for `dev` or `prod`, create matching environments with their own approval policy.

## Azure OIDC Trust Configuration

The workflow authenticates with `azure/login` using GitHub OIDC. Configure Azure workload identity federation instead of client secrets.

Minimum Azure setup:
- Create or reuse an application registration or user-assigned managed identity.
- Add a federated credential that trusts this GitHub repository.
- Use least-privilege Azure RBAC scoped as narrowly as possible.
- Avoid `Owner` unless there is a hard technical reason.

Recommended federated credential subjects:
- `repo:<owner>/<repo>:ref:refs/heads/main` for push-based staging applies
- `repo:<owner>/<repo>:pull_request` if you want PR plans to authenticate in Azure
- `repo:<owner>/<repo>:environment:staging` if you want tighter binding to the protected GitHub Environment

Use the subject format that matches your governance model, but keep it as narrow as possible.

## How to Run the Workflow Manually

1. Open the Actions tab in GitHub.
2. Select `terraform-azure`.
3. Choose `Run workflow`.
4. Select the target environment.
5. Start the run.

The workflow will:
- validate Terraform
- scan Terraform for high-severity issues
- create a plan
- wait for environment approval before apply
- apply the saved plan artifact

## How to Review Plan Output Before Apply

For pull requests:
- open the workflow run
- check the workflow summary for the rendered plan excerpt
- download the `tfplan-<environment>` artifact if you need the full generated files
- review the diff before merging to `main`

For pushes to `main` or manual runs:
- open the plan job summary
- verify the environment and backend file paths
- approve the deployment only after the plan looks correct

## Security Notes

- Remote state stays in Azure Blob Storage through the AzureRM backend.
- OIDC avoids storing Azure secrets in GitHub.
- `tfsec` blocks high-severity IaC findings before plan/apply.
- State locking remains enabled during normal plan/apply execution.
- The workflow is structured so `dev` and `prod` can be added without redesigning the pipeline.

## Operational Notes

- PR plans default to `staging`.
- Pushes to `main` plan and apply `staging`.
- Manual dispatch allows `dev`, `staging`, or `prod`.
- If PRs come from untrusted forks, OIDC-based Azure plan execution may need additional repository policy decisions.