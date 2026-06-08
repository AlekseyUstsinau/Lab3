# Improvement Report

Date: 2026-06-08
Scope: Terraform root and module refactor for code quality/performance, security hardening, and FinOps optimization.

## 1. Code Quality and Performance Improvements

### 1.1 Fixed automation schedule correctness and drift
- Added explicit schedule start times to Automation schedules so plans are deterministic and schedules are created with defined first execution timestamps.
- Files updated:
  - terraform/modules/automation/main.tf
- Concrete change:
  - Added `start_time = var.scale_down_start_time` to scale-down schedule.
  - Added `start_time = var.scale_up_start_time` to scale-up schedule.

### 1.2 Normalized timezone handling to avoid recurring plan drift
- Introduced timezone normalization at root level to map `UTC` to `Etc/UTC` before passing to module.
- Files updated:
  - terraform/locals.tf
  - terraform/main.tf
  - terraform/variables.tf
- Concrete change:
  - Added `local.normalized_off_hours_timezone`.
  - Automation module now receives normalized timezone.
  - Default timezone changed to `Etc/UTC` and validated non-empty.

### 1.3 Removed permissive fallback logic
- Removed fallback that silently expanded ingress allowlist intent to `0.0.0.0/0`.
- Files updated:
  - terraform/locals.tf
- Concrete change:
  - `effective_inbound_cidrs` now directly uses `var.allowed_inbound_cidrs`.

## 2. Security Hardening

### 2.1 Hardened Key Vault network ACL behavior
- Changed Key Vault ACL bypass from `AzureServices` to `None`, reducing broad trusted-service bypass risk.
- Files updated:
  - terraform/modules/security_monitoring/main.tf
- Vulnerability fixed:
  - Over-permissive service bypass path that could allow access outside explicit network rules/private endpoint strategy.

### 2.2 Reduced secret exposure surface in Terraform outputs
- Removed Log Analytics primary shared key output from module outputs.
- Files updated:
  - terraform/modules/security_monitoring/outputs.tf
- Vulnerability fixed:
  - Avoided accidental propagation/exposure of ingestion key through outputs/state consumers.

### 2.3 Implemented optional ingress allowlisting controls for Container Apps
- Added dynamic ingress IP security restrictions to the Container App.
- If CIDRs are provided, rules now allow only listed CIDRs and deny all others.
- Files updated:
  - terraform/modules/container_platform/main.tf
- Vulnerability fixed:
  - Lack of enforceable ingress source filtering when allowlist is configured.

### 2.4 Strengthened non-prod Key Vault security baseline
- Dev and staging now use:
  - Purge protection enabled.
  - Public network access disabled.
- Files updated:
  - terraform/environments/dev/terraform.tfvars
  - terraform/environments/staging/terraform.tfvars
- Vulnerability fixed:
  - Reduced accidental public exposure and improved resilience against malicious purge scenarios.

## 3. Cost Optimization

### 3.1 Kept Log Analytics retention at provider minimum while preserving deployability
- Attempted lower non-prod retention for additional savings, then aligned back to 30 days after provider constraint validation.
- Files updated:
  - terraform/environments/dev/terraform.tfvars
  - terraform/environments/staging/terraform.tfvars
  - terraform/variables.tf
- Constraint observed:
  - `azurerm_log_analytics_workspace.retention_in_days` requires 30-730.

### 3.2 Preserved off-hours autoscaling strategy with corrected schedule execution
- Night scale-down and morning scale-up remain active for dev/staging with deterministic schedule starts.
- Files updated:
  - terraform/modules/automation/main.tf
  - terraform/locals.tf

## 4. Validation Evidence

- Ran Terraform formatting recursively.
- Ran Terraform validation successfully.
- Command result:
  - `terraform fmt -recursive` updated formatting where needed.
  - `terraform validate` returned: `Success! The configuration is valid.`

## 5. Summary of Security Vulnerabilities Fixed

1. Key Vault broad trusted-services bypass reduced (`AzureServices` -> `None`).
2. Sensitive Log Analytics shared key output removed.
3. Ingress source restriction capability implemented for Container Apps.
4. Non-prod Key Vault defaults hardened (public disabled, purge protection enabled).
