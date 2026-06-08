# Terraform Infrastructure Parameters List

## 1. Purpose
Complete list of Terraform parameters required to provision the Azure staging architecture for a small Nginx service, including instance sizing, replica counts, storage/backends, security, and monitoring.

## 2. Global and Naming Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| application_name | string | Yes | nginxsvc | Application short name used in naming convention |
| environment | string | Yes | dev, staging, prod | Environment selector |
| location | string | Yes | westeurope | Azure region |
| region_short | string | Yes | we | Short region code for names |
| instance_number | string | Yes | 001 | Name suffix for uniqueness |
| resource_name_prefix | string | No | ngs | Optional custom naming prefix |

## 3. Tagging and Governance Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| owner | string | Yes | devops-team | Resource owner tag |
| cost_center | string | Yes | cc-1001 | Cost allocation tag |
| managed_by | string | No | IaC | Management source tag |
| business_unit | string | No | platform | Optional governance tag |
| tags | map(string) | Yes | map of mandatory tags | Tags applied to all resources |

## 4. Resource Group Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| create_resource_group | bool | No | true | Whether to create RG via this stack |
| resource_group_name | string | No | rg-nginxsvc-staging-we-001 | Override RG name if needed |

## 5. Container Registry (ACR) Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| acr_name | string | No | acrnginxsvcstgwe001 | ACR name (global uniqueness rules apply) |
| acr_sku | string | Yes | Basic | Registry tier (Basic for low cost) |
| acr_admin_enabled | bool | No | false | Keep disabled for security |
| acr_public_network_access_enabled | bool | No | true | Restrict later if private networking is used |
| acr_georeplication_locations | list(string) | No | [] | Optional geo replicas |
| image_repository | string | Yes | nginx | Container repository |
| image_tag | string | Yes | 1.27.0-alpine | Pinned image tag |

## 6. Container App Environment Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| container_app_environment_name | string | No | cae-nginxsvc-staging-we-001 | ACA environment name |
| infrastructure_subnet_id | string | No | /subscriptions/.../subnets/aca | Optional subnet for VNet integration |
| internal_load_balancer_enabled | bool | No | false | Internal-only ingress if true |
| zone_redundancy_enabled | bool | No | false | Reliability option (typically prod) |

## 7. Container App Workload Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| container_app_name | string | No | aca-nginxsvc-staging-we-001 | ACA app name |
| container_image | string | Yes | nginx:1.27.0-alpine | Image reference |
| container_port | number | Yes | 80 | Exposed service port |
| container_cpu | number | Yes | 0.5 | CPU cores per replica |
| container_memory | string | Yes | 1Gi | Memory per replica |
| revision_mode | string | No | Single | Revision strategy |
| ingress_external_enabled | bool | No | true | Public ingress toggle |
| ingress_allow_insecure_connections | bool | No | false | Keep HTTPS only |
| transport | string | No | auto | HTTP transport mode |
| target_port | number | Yes | 80 | Container target port |

## 8. Scaling Parameters (Replica Counts and Triggers)

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| min_replicas | number | Yes | 1 | Minimum replica count |
| max_replicas | number | Yes | 3 | Maximum replica count |
| scale_rule_name | string | No | http-scale | Rule identifier |
| target_concurrency | number | Yes | 50 | Requests per replica target |
| cooldown_period | number | No | 300 | Scale cooldown in seconds |

## 9. Night Cost-Control Schedule Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| enable_night_schedule | bool | Yes | true | Enable auto scale-down/up schedule |
| scale_down_cron | string | Yes | 0 0 22 * * 1-5 | Weekday night scale down |
| scale_up_cron | string | Yes | 0 0 7 * * 1-5 | Weekday morning scale up |
| off_hours_timezone | string | Yes | UTC | Timezone for cron execution |
| off_hours_min_replicas | number | Yes | 0 | Minimum replicas during off-hours |
| business_hours_min_replicas | number | Yes | 1 | Minimum replicas during business hours |

## 10. Identity and Access Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| enable_system_assigned_identity | bool | No | true | Enable managed identity for app |
| user_assigned_identity_ids | list(string) | No | [] | Optional user-assigned identities |
| pipeline_principal_object_id | string | Yes | 00000000-0000-0000-0000-000000000000 | GitHub OIDC principal object id |
| role_assignments | map(object) | No | map of role bindings | Custom role assignment definitions |
| key_vault_secrets_user_role_enabled | bool | No | true | Grant secrets read role to app identity |

## 11. Key Vault Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| key_vault_name | string | No | kv-nginxsvc-staging-we-001 | Key Vault name |
| key_vault_sku_name | string | No | standard | KV tier |
| key_vault_soft_delete_retention_days | number | No | 7 | Soft delete retention |
| key_vault_purge_protection_enabled | bool | No | false | Optional for strict protection |
| key_vault_public_network_access_enabled | bool | No | true | Restrict if private endpoint is used |
| key_vault_access_ip_rules | list(string) | No | [] | Optional IP restrictions |

## 12. Monitoring and Alerting Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| log_analytics_workspace_name | string | No | law-nginxsvc-staging-we-001 | Workspace name |
| log_retention_days | number | Yes | 14 | Log retention period |
| enable_diagnostic_settings | bool | No | true | Attach diagnostics where supported |
| alert_action_group_name | string | No | ag-nginxsvc-staging-we-001 | Alert action group |
| alert_email | string | Yes | alerts@example.com | Alert notification target |
| cpu_alert_threshold_percent | number | No | 80 | CPU alert threshold |
| memory_alert_threshold_percent | number | No | 80 | Memory alert threshold |
| availability_alert_enabled | bool | No | true | Enable availability alert |
| error_rate_alert_enabled | bool | No | true | Enable 5xx alert |

## 13. Networking Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| enable_vnet | bool | No | false | Enable custom VNet resources |
| vnet_name | string | No | vnet-nginxsvc-staging-we-001 | VNet name |
| vnet_address_space | list(string) | No | ["10.30.0.0/16"] | Address space |
| aca_subnet_name | string | No | snet-aca | ACA subnet name |
| aca_subnet_cidr | string | No | 10.30.1.0/24 | ACA subnet range |
| nsg_name | string | No | nsg-nginxsvc-staging-we-001 | NSG name |
| allowed_inbound_cidrs | list(string) | No | ["0.0.0.0/0"] | Inbound source ranges (tighten for security) |
| enable_private_endpoints | bool | No | false | Private endpoints for ACR/KV as needed |

## 14. Terraform Backend and State Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| tfstate_resource_group_name | string | Yes | rg-tfstate-shared-we-001 | Backend RG |
| tfstate_storage_account_name | string | Yes | sttfstatesharedwe001 | Backend storage account |
| tfstate_container_name | string | Yes | tfstate | Blob container for state |
| tfstate_key | string | Yes | nginxsvc/staging/terraform.tfstate | State file key path |
| backend_use_oidc | bool | No | true | OIDC auth for backend operations |

## 15. CI/CD Integration Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| github_repository | string | Yes | org/repo | Source repo |
| github_environment_name | string | Yes | staging | GitHub protected environment |
| github_oidc_subject | string | Yes | repo:org/repo:environment:staging | Federated credential subject |
| enable_manual_approval_for_apply | bool | No | true | Safety gate before apply |
| terraform_version | string | No | 1.9.8 | Terraform toolchain version |

## 16. Environment Baseline Values

| Parameter | Dev | Staging | Prod |
|---|---|---|---|
| container_cpu | 0.25 | 0.5 | 1.0 |
| container_memory | 0.5Gi | 1Gi | 2Gi |
| min_replicas | 0 | 1 | 2 |
| max_replicas | 1 | 3 | 6 |
| target_concurrency | 25 | 50 | 100 |
| log_retention_days | 7 | 14 | 30 |
| enable_night_schedule | true | true | false |
| off_hours_min_replicas | 0 | 0 | 2 |
| enable_private_endpoints | false | false | true |
| zone_redundancy_enabled | false | false | true |

## 17. Sensitive Parameters Handling
- Do not commit secrets in tfvars files.
- Mark sensitive Terraform variables with sensitive = true.
- Pass sensitive values through CI/CD secret store.
- Prefer Key Vault references and managed identity over plain secrets.

## 18. Minimum Required Set for This Assignment
If you want the smallest possible working set, provide at least:
- application_name
- environment
- location
- owner
- cost_center
- container_image
- container_port
- container_cpu
- container_memory
- min_replicas
- max_replicas
- target_concurrency
- log_retention_days
- alert_email
- scale_down_cron
- scale_up_cron
- off_hours_timezone
- tfstate_resource_group_name
- tfstate_storage_account_name
- tfstate_container_name
- tfstate_key
