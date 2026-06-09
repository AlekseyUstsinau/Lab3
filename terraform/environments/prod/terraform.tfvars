application_name = "nginxsvc"
environment      = "prod"
location         = "northeurope"
region_short     = "ne"
instance_number  = "001"
owner            = "devops-team"
cost_center      = "cc-1001"
managed_by       = "IaC"

container_cpu      = 1.0
container_memory   = "2Gi"
min_replicas       = 2
max_replicas       = 6
target_concurrency = 100
container_port     = 80
image_repository   = "nginx"
image_tag          = "1.27.0-alpine"

ingress_external_enabled = true
enable_private_ingress   = false
enable_zone_redundancy   = true

log_retention_days             = 30
alert_email                    = "alerts@example.com"
cpu_alert_threshold_percent    = 80
memory_alert_threshold_percent = 80

enable_night_schedule       = false
scale_down_cron             = ""
scale_up_cron               = ""
off_hours_timezone          = "UTC"
off_hours_min_replicas      = 2
business_hours_min_replicas = 2

pipeline_principal_object_id = "00000000-0000-0000-0000-000000000000"

vnet_cidr                    = "10.31.0.0/16"
aca_subnet_cidr              = "10.31.2.0/23"
private_endpoint_subnet_cidr = "10.31.4.0/24"

key_vault_soft_delete_retention_days    = 14
key_vault_purge_protection_enabled      = true
key_vault_public_network_access_enabled = false
key_vault_allowed_ip_rules              = []

acr_sku                           = "Premium"
acr_public_network_access_enabled = false
acr_admin_enabled                 = true

tags = {
  Environment = "prod"
  Application = "nginxsvc"
  CostCenter  = "cc-1001"
  Owner       = "devops-team"
  ManagedBy   = "IaC"
}
