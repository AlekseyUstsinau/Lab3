# Azure Terraform Codebase (Production-Grade, Modular)

This Terraform stack implements the Azure design from task2 and structurization docs:

- Stateless Nginx on Azure Container Apps.
- Azure Container Registry with pinned image versioning.
- Log Analytics and Azure Monitor alerts.
- Key Vault with RBAC and private endpoint.
- Night cost-control automation for dev/staging.
- Least-privilege IAM assignments for runtime automation and CI/CD.
- Environment separation via `environments/dev|staging|prod`.
- Remote state via Azure Blob backend (`backend.hcl` per environment).

## Layout

```text
terraform/
├── versions.tf
├── providers.tf
├── locals.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── README.md
├── environments/
│   ├── dev/
│   │   ├── backend.hcl
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── backend.hcl
│   │   └── terraform.tfvars
│   └── prod/
│       ├── backend.hcl
│       └── terraform.tfvars
└── modules/
    ├── networking/
    ├── security_monitoring/
    ├── container_platform/
    ├── automation/
    └── iam/
```

## Prerequisites

- Terraform 1.9+
- Azure subscription with permissions to create RG-scoped resources
- Existing state storage account/container referenced in each `backend.hcl`
- GitHub OIDC app registration already configured in Azure AD (Entra ID)

## Deployment Commands

### Dev

```bash
cd terraform
terraform init -backend-config=environments/dev/backend.hcl
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Staging

```bash
cd terraform
terraform init -backend-config=environments/staging/backend.hcl
terraform plan -var-file=environments/staging/terraform.tfvars
terraform apply -var-file=environments/staging/terraform.tfvars
```

### Prod

```bash
cd terraform
terraform init -backend-config=environments/prod/backend.hcl
terraform plan -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
```

## Security Notes

- Do not commit real principal IDs or secrets to `terraform.tfvars`.
- Keep `pipeline_principal_object_id` updated per environment.
- `AcrPull` is granted only to runtime identity.
- No `Owner` role is used by this stack.

## Cost Control

- Dev/staging use weekday scale-down and scale-up schedules through Azure Automation.
- Prod disables off-hours schedules by default.

## Validation

```bash
terraform fmt -recursive
terraform validate
```
