# Architecture Document: Tool Selection and Justification

## 1. Goal
Provision a temporary Azure staging environment for a small service (empty Nginx) that is:
- simple
- secure
- cheap
- horizontally scalable
- easy to tear down

## 2. Selected Toolchain

| Area | Selected Tool | Why This Tool |
|---|---|---|
| Cloud Platform | Microsoft Azure | Required by task; rich managed services for fast setup and low operations overhead |
| Infrastructure as Code | Terraform | Preferred in requirements; reusable modules, environment parameterization, and repeatable provisioning |
| CI/CD | GitHub Actions | Native with GitHub repos; easy automation for Terraform plan/apply and container deployment |
| CI/CD Authentication | GitHub OIDC + Microsoft Entra Workload Identity Federation | Secretless authentication, better security than service principal passwords |
| Container Runtime | Azure Container Apps | Simple managed container platform with autoscaling and minimal ops for small services |
| Container Registry | Azure Container Registry | Azure-native private image registry with RBAC integration |
| Secret Management | Azure Key Vault | Centralized secrets management; avoids hardcoded credentials |
| Monitoring/Logs | Azure Monitor + Log Analytics | Native metrics, logs, alerting, and operational visibility |
| Security Access Model | Azure RBAC + Managed Identity | Least privilege and no embedded credentials |
| Diagramming | diagrams.net (drawio) | Fast architecture visualization and easy submission artifact |
| AI Assistant | GitHub Copilot (GPT-5.3-Codex) | Speeds design drafting, Terraform parameter modeling, and documentation consistency |

## 3. Justification by Requirement

### 3.1 Simple
- Azure Container Apps is simpler than AKS for a small temporary service.
- Terraform keeps provisioning deterministic and easy to repeat.
- GitHub Actions provides straightforward automation without extra platform complexity.

### 3.2 Secure
- OIDC federation removes long-lived secrets in CI/CD.
- Key Vault stores sensitive values outside source control.
- Managed identity + scoped RBAC follows least privilege.
- Azure Monitor alerts improve incident visibility.

### 3.3 Cheap
- Container Apps supports right-sized CPU/memory and autoscaling.
- Night scale-down schedule reduces non-business-hour costs.
- Log retention can be shorter in staging to lower monitoring costs.
- Managed services reduce operational cost and maintenance time.

## 4. Alternatives Considered (and why not selected)

| Alternative | Why Not Primary Choice |
|---|---|
| Azure Kubernetes Service (AKS) | Overkill for a small temporary service; higher operational complexity and cost |
| Azure App Service for Containers | Valid option, but less flexible autoscaling model for this assignment compared to Container Apps |
| Azure DevOps Pipelines | Also valid, but GitHub Actions is simpler for GitHub-hosted coursework repos |
| Service Principal Client Secret auth | Less secure than OIDC due to secret lifecycle/rotation burden |

## 5. Final Recommended Stack
- Azure Resource Group
- Azure Container Registry
- Azure Container Apps Environment + Azure Container App (nginx)
- Azure Key Vault
- Azure Monitor + Log Analytics
- GitHub Actions with OIDC
- Terraform for all infrastructure definitions

## 6. Deliverable Mapping to Task
- Architecture diagram: created in architecture.drawio.
- Tool selection + justification: this document.
- Terraform infrastructure parameters: documented in project_spec.md.
