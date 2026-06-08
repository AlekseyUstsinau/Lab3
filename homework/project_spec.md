# Project Specification: Azure Infrastructure for Small Service (Empty Nginx)

## 1. Objective
Build a simple, secure, and low-cost Azure staging environment for a small service based on an empty Nginx container image. The environment must be easy to deploy, scale horizontally, and tear down.

## 2. Inputs Used
- task1.md requirements: high availability, horizontal scaling, low cost, auto-stop at night, Azure, CI/CD support.
- cis_azure.md guidance: Azure Well-Architected priorities, least privilege, managed identities, private networking where feasible, monitoring, and IaC with Terraform.

## 3. Scope
- One Azure staging environment for an Nginx service.
- Infrastructure as Code with Terraform.
- CI/CD pipeline for infra and service deployment.
- Basic observability and security baseline.

Out of scope:
- Production hardening beyond staging needs.
- Custom business application logic.

## 4. High-Level Architecture
- Resource Group: isolated staging resource group.
- Azure Container Registry (ACR): stores pinned Nginx image.
- Azure Container Apps (ACA): runs stateless Nginx container with autoscaling.
- Log Analytics Workspace + Azure Monitor: logs, metrics, alerts.
- Key Vault: secret storage for any future app secrets.
- Optional VNet integration for ACA environment if private access is required.
- GitHub Actions pipeline using OIDC federation for passwordless Azure auth.

## 5. Service Design (Simple)
- Workload: single container app (`nginx`) serving default response.
- Compute: minimal ACA workload profile/resources.
- Scaling:
  - Min replicas: 1 (for availability).
  - Max replicas: 2-3 (for small horizontal scale test).
  - Scale trigger: HTTP concurrency.
- Image policy: pinned image tag (no `latest`).

## 6. Security Design (Secure)
- Identity:
  - Use GitHub OIDC federated credentials for CI/CD.
  - Use Managed Identity for runtime where applicable.
- Access control:
  - Least-privilege RBAC at resource group scope.
  - No Owner role for pipeline identity.
- Secrets:
  - No secrets in code or tfvars committed to source control.
  - Store sensitive values in Key Vault.
- Network:
  - Restrict inbound traffic to required ports only.
  - Prefer private endpoints/private networking for stateful services (future expansion).
- Container security:
  - Minimal trusted image.
  - Image vulnerability scanning in CI.
  - Run as non-root when image supports it.
- Platform protections:
  - TLS in transit.
  - Encryption at rest (Azure defaults).
  - Activity logs and security-relevant alerts enabled.

## 7. Cost Design (Cheap)
- Prefer managed PaaS services to reduce operations overhead.
- Keep staging resources small and autoscaled.
- Night auto-stop strategy:
  - Schedule min replicas to 0 during off-hours (where allowed), or
  - Apply scheduled scale-down to the smallest allowed capacity.
- Use short log retention in staging (for example 7-14 days).
- Keep max replicas low and avoid overprovisioning.

## 8. Reliability and Availability
- Target availability: platform-backed high availability for single-region staging.
- Horizontal scaling enabled via ACA autoscaling.
- Health probes configured (liveness/readiness).
- Recovery approach: redeploy from Terraform + pipeline.
- RTO (staging): <= 1 hour.
- RPO (staging): near-zero for stateless service.

## 9. Terraform Requirements
- Use reusable modules and environment parameterization.
- Support at least `staging` (optional extension: dev/test/prod).
- Apply consistent naming:
  - `<resource-type>-<application>-<environment>-<region>-<instance>`
- Mandatory tags on all resources:
  - `Environment`, `Application`, `CostCenter`, `Owner`, `ManagedBy=IaC`
- Remote state stored in Azure Storage backend.

## 10. Required Parameters
- Global:
  - `application_name`
  - `environment` (staging)
  - `location`
  - `owner`
  - `cost_center`
- Container app:
  - `container_image`
  - `container_cpu`
  - `container_memory`
  - `min_replicas`
  - `max_replicas`
  - `target_concurrency`
- Monitoring:
  - `log_retention_days`
  - `alert_email` or alert action group settings
- Scheduling/cost control:
  - `scale_down_cron`
  - `scale_up_cron`
  - `off_hours_timezone`

## 11. CI/CD Requirements
- Platform: GitHub Actions.
- Auth: OIDC to Azure (no client secret).
- Pipeline stages:
  1. Lint/validate Terraform.
  2. Terraform plan.
  3. Security checks (IaC + container scan).
  4. Manual approval for apply (staging).
  5. Terraform apply.
  6. Deploy/update Nginx container app.
- Rollback:
  - Re-deploy previous image tag.
  - Terraform state-based rollback for infra changes when needed.

## 12. Monitoring and Alerts
- Enable container logs and platform metrics.
- Minimum alerts:
  - Service unavailable/high 5xx.
  - High CPU/memory.
  - Failed deployments.
  - Security or unauthorized access events.
- Include dashboard for staging health and recent deployments.

## 13. Acceptance Criteria
- Infrastructure deploys successfully from Terraform.
- Nginx service is reachable and returns default response.
- Autoscaling behavior is demonstrable.
- Night cost-control schedule is active.
- No hardcoded secrets in repository.
- CI/CD deploys changes without manual portal configuration.
- Logs and alerts are visible in Azure Monitor.

## 14. Recommended Minimal Azure Resource Set
- `azurerm_resource_group`
- `azurerm_container_registry`
- `azurerm_log_analytics_workspace`
- `azurerm_container_app_environment`
- `azurerm_container_app`
- `azurerm_key_vault`
- `azurerm_role_assignment` (least privilege for identities)
- Optional: automation/scheduled scaling resources based on chosen approach

## 15. Final Notes
This specification intentionally favors a low-complexity staging setup while preserving security and operational best practices from the CIS guidance. It is suitable for short-lived testing and straightforward cleanup.

## 16. Terraform Parameter Set for Multiple Environments

### 16.1 Variable Catalog (Recommended)
| Name | Type | Required | Example | Notes |
|---|---|---|---|---|
| application_name | string | Yes | nginxsvc | Short app identifier used in naming convention |
| environment | string | Yes | dev, staging, prod | Controls sizing, schedules, and tags |
| location | string | Yes | westeurope | Azure region |
| region_short | string | Yes | we | Short region token for names |
| owner | string | Yes | devops-team | Tag value |
| cost_center | string | Yes | cc-1001 | Tag value for cost reporting |
| managed_by | string | No | IaC | Default IaC |
| container_image | string | Yes | nginx:1.27.0-alpine | Use pinned image tag, never latest |
| container_port | number | No | 80 | Default Nginx port |
| container_cpu | number | Yes | 0.25, 0.5, 1.0 | Per environment sizing |
| container_memory | string | Yes | 0.5Gi, 1Gi, 2Gi | Per environment sizing |
| min_replicas | number | Yes | 0, 1, 2 | Cost vs availability tradeoff |
| max_replicas | number | Yes | 1, 3, 6 | Horizontal scaling cap |
| target_concurrency | number | Yes | 25, 50, 100 | ACA HTTP scaler target |
| log_retention_days | number | Yes | 7, 14, 30 | Lower for non-production cost control |
| alert_email | string | Yes | alerts@example.com | Alert action receiver |
| scale_down_cron | string | Yes | 0 0 22 * * 1-5 | Scale down at night on weekdays |
| scale_up_cron | string | Yes | 0 0 7 * * 1-5 | Scale up in the morning on weekdays |
| off_hours_timezone | string | Yes | UTC | Timezone for schedule rules |
| enable_private_ingress | bool | No | false | Keep simple by default |
| enable_zone_redundancy | bool | No | false for dev/staging, true for prod | Reliability toggle |
| tags | map(string) | Yes | Environment, Application, CostCenter, Owner, ManagedBy | Mandatory tags for all resources |

### 16.2 Environment Matrix
| Parameter | Dev | Staging | Prod |
|---|---|---|---|
| environment | dev | staging | prod |
| location | westeurope | westeurope | westeurope |
| container_image | nginx:1.27.0-alpine | nginx:1.27.0-alpine | nginx:1.27.0-alpine |
| container_cpu | 0.25 | 0.5 | 1.0 |
| container_memory | 0.5Gi | 1Gi | 2Gi |
| min_replicas | 0 | 1 | 2 |
| max_replicas | 1 | 3 | 6 |
| target_concurrency | 25 | 50 | 100 |
| log_retention_days | 7 | 14 | 30 |
| enable_private_ingress | false | false | true |
| enable_zone_redundancy | false | false | true |
| scale_down_cron | 0 0 22 * * 1-5 | 0 0 22 * * 1-5 | not-used |
| scale_up_cron | 0 0 7 * * 1-5 | 0 0 7 * * 1-5 | not-used |
| off_hours_timezone | UTC | UTC | UTC |

### 16.3 Sample tfvars Values

dev.tfvars

application_name      = "nginxsvc"
environment           = "dev"
location              = "westeurope"
region_short          = "we"
owner                 = "devops-team"
cost_center           = "cc-1001"
container_image       = "nginx:1.27.0-alpine"
container_port        = 80
container_cpu         = 0.25
container_memory      = "0.5Gi"
min_replicas          = 0
max_replicas          = 1
target_concurrency    = 25
log_retention_days    = 7
alert_email           = "alerts@example.com"
scale_down_cron       = "0 0 22 * * 1-5"
scale_up_cron         = "0 0 7 * * 1-5"
off_hours_timezone    = "UTC"
enable_private_ingress = false
enable_zone_redundancy = false
tags = {
  Environment = "dev"
  Application = "nginxsvc"
  CostCenter  = "cc-1001"
  Owner       = "devops-team"
  ManagedBy   = "IaC"
}

staging.tfvars

application_name      = "nginxsvc"
environment           = "staging"
location              = "westeurope"
region_short          = "we"
owner                 = "devops-team"
cost_center           = "cc-1001"
container_image       = "nginx:1.27.0-alpine"
container_port        = 80
container_cpu         = 0.5
container_memory      = "1Gi"
min_replicas          = 1
max_replicas          = 3
target_concurrency    = 50
log_retention_days    = 14
alert_email           = "alerts@example.com"
scale_down_cron       = "0 0 22 * * 1-5"
scale_up_cron         = "0 0 7 * * 1-5"
off_hours_timezone    = "UTC"
enable_private_ingress = false
enable_zone_redundancy = false
tags = {
  Environment = "staging"
  Application = "nginxsvc"
  CostCenter  = "cc-1001"
  Owner       = "devops-team"
  ManagedBy   = "IaC"
}

prod.tfvars

application_name      = "nginxsvc"
environment           = "prod"
location              = "westeurope"
region_short          = "we"
owner                 = "devops-team"
cost_center           = "cc-1001"
container_image       = "nginx:1.27.0-alpine"
container_port        = 80
container_cpu         = 1.0
container_memory      = "2Gi"
min_replicas          = 2
max_replicas          = 6
target_concurrency    = 100
log_retention_days    = 30
alert_email           = "alerts@example.com"
scale_down_cron       = ""
scale_up_cron         = ""
off_hours_timezone    = "UTC"
enable_private_ingress = true
enable_zone_redundancy = true
tags = {
  Environment = "prod"
  Application = "nginxsvc"
  CostCenter  = "cc-1001"
  Owner       = "devops-team"
  ManagedBy   = "IaC"
}

### 16.4 Provisioning Command Pattern
- terraform init
- terraform plan -var-file=environments/dev.tfvars
- terraform apply -var-file=environments/dev.tfvars
- terraform plan -var-file=environments/staging.tfvars
- terraform apply -var-file=environments/staging.tfvars
- terraform plan -var-file=environments/prod.tfvars
- terraform apply -var-file=environments/prod.tfvars

### 16.5 Security Notes for Parameters
- Do not store secrets in tfvars files committed to source control.
- Keep sensitive values in Azure Key Vault and reference them via runtime identity.
- If any sensitive Terraform variables are required later, mark them as sensitive and pass via pipeline secrets.
