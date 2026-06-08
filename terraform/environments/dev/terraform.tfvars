application_name = "nginxsvc"
environment      = "dev"
location         = "westeurope"
region_short     = "we"
instance_number  = "001"
owner            = "devops-team"
cost_center      = "cc-1001"
managed_by       = "IaC"

container_cpu      = 0.25
container_memory   = "0.5Gi"
min_replicas       = 0
max_replicas       = 1
target_concurrency = 25
container_port     = 80
image_repository   = "nginx"
image_tag          = "1.27.0-alpine"

ingress_external_enabled = true
enable_private_ingress   = false
enable_zone_redundancy   = false

log_retention_days             = 30
alert_email                    = "alerts@example.com"
cpu_alert_threshold_percent    = 80
memory_alert_threshold_percent = 80

enable_night_schedule       = true
scale_down_cron             = "0 0 22 * * 1-5"
scale_up_cron               = "0 0 7 * * 1-5"
off_hours_timezone          = "UTC"
off_hours_min_replicas      = 0
business_hours_min_replicas = 1

pipeline_principal_object_id = "00000000-0000-0000-0000-000000000000"

vnet_cidr                    = "10.30.0.0/16"
aca_subnet_cidr              = "10.30.2.0/23"
private_endpoint_subnet_cidr = "10.30.4.0/24"

key_vault_soft_delete_retention_days    = 7
key_vault_purge_protection_enabled      = false
key_vault_public_network_access_enabled = true
key_vault_allowed_ip_rules              = []

acr_sku                           = "Basic"
acr_public_network_access_enabled = true

tags = {
  Environment = "dev"
  Application = "nginxsvc"
  CostCenter  = "cc-1001"
  Owner       = "devops-team"
  ManagedBy   = "IaC"
}
