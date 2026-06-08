# DevOps AI Education - Final Project

This repository contains a production-style, Azure-only Terraform codebase for a simple containerized Hello service.

The implementation is optimized for staging: it uses Azure Container Apps for serverless compute, Azure Container Registry for images, private networking for platform services, and scheduled shutdown/startup automation to minimize cost outside working hours.

## Repository Layout

```text
devops-ai-edu/
├── README.md
├── homework/
└── terraform/
    ├── README.md
    ├── versions.tf
    ├── providers.tf
    ├── locals.tf
    ├── variables.tf
    ├── main.tf
    ├── outputs.tf
    ├── modules/
    │   ├── compute/
    │   ├── iam/
    │   ├── network/
    │   ├── security/
    │   └── storage/
    └── envs/
        ├── dev/
        ├── staging/
        └── prod/
```

## Azure Architecture

The stack is built around these Azure services:

- Azure Container Apps for the web service and its autoscaling runtime.
- Azure Container Registry for image storage and pull authorization.
- Azure Log Analytics and Application Insights for observability.
- Azure Key Vault for future secret management.
- Azure Automation for scheduled scale-down and morning scale-up.
- Azure Virtual Network with a delegated Container Apps subnet and a private endpoint subnet.

## Environment Separation

Each environment is isolated through:

- Separate `terraform.tfvars` files under `terraform/envs/<env>/`.
- Separate backend configuration files under `terraform/envs/<env>/backend.hcl`.
- Environment-specific naming, address space, and schedule settings.

## Remote State

Because this is an Azure-only repository, the remote backend uses Azure Blob Storage via the `azurerm` backend.

State locking is handled by Azure Blob leases, which is the Azure equivalent of a remote lock table.

## Deployment

```bash
cd terraform
terraform init -backend-config=envs/dev/backend.hcl
terraform plan -var-file=envs/dev/terraform.tfvars
terraform apply -var-file=envs/dev/terraform.tfvars
```

Use `envs/staging` or `envs/prod` for the other environments.

To destroy an environment:

```bash
terraform destroy -var-file=envs/staging/terraform.tfvars
```

## Notes

- All resources are tagged with `Project`, `Environment`, `Owner`, and `ManagedBy = Terraform`.
- The backend storage account is intentionally managed outside the main application state so the environment can be destroyed without deleting its state store.

