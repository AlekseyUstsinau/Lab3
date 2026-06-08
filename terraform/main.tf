data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = local.common_tags
}

module "networking" {
  source = "./modules/networking"

  resource_group_name          = azurerm_resource_group.main.name
  location                     = var.location
  vnet_name                    = local.vnet_name
  vnet_cidr                    = var.vnet_cidr
  aca_subnet_cidr              = var.aca_subnet_cidr
  private_endpoint_subnet_cidr = var.private_endpoint_subnet_cidr
  tags                         = local.common_tags
}

module "security_monitoring" {
  source = "./modules/security_monitoring"

  resource_group_name                     = azurerm_resource_group.main.name
  location                                = var.location
  tenant_id                               = data.azurerm_client_config.current.tenant_id
  key_vault_name                          = local.key_vault_name
  key_vault_soft_delete_retention_days    = var.key_vault_soft_delete_retention_days
  key_vault_purge_protection_enabled      = var.key_vault_purge_protection_enabled
  key_vault_public_network_access_enabled = var.key_vault_public_network_access_enabled
  key_vault_allowed_ip_rules              = var.key_vault_allowed_ip_rules
  private_endpoint_subnet_id              = module.networking.private_endpoint_subnet_id
  private_dns_zone_vnet_id                = module.networking.vnet_id
  log_analytics_workspace_name            = local.log_analytics_name
  log_retention_days                      = var.log_retention_days
  alert_action_group_name                 = local.action_group_name
  alert_email                             = var.alert_email
  tags                                    = local.common_tags
}

module "container_platform" {
  source = "./modules/container_platform"

  resource_group_name               = azurerm_resource_group.main.name
  location                          = var.location
  container_app_environment_name    = local.cae_name
  container_app_name                = local.aca_name
  image_repository                  = var.image_repository
  image_tag                         = var.image_tag
  container_port                    = var.container_port
  container_cpu                     = var.container_cpu
  container_memory                  = var.container_memory
  min_replicas                      = var.min_replicas
  max_replicas                      = var.max_replicas
  target_concurrency                = var.target_concurrency
  revision_mode                     = var.revision_mode
  ingress_external_enabled          = var.ingress_external_enabled && !var.enable_private_ingress
  enable_private_ingress            = var.enable_private_ingress
  zone_redundancy_enabled           = var.enable_zone_redundancy
  acr_name                          = local.acr_name
  acr_sku                           = var.acr_sku
  acr_public_network_access_enabled = var.acr_public_network_access_enabled
  log_analytics_workspace_id        = module.security_monitoring.log_analytics_workspace_id
  infrastructure_subnet_id          = module.networking.aca_subnet_id
  action_group_id                   = module.security_monitoring.action_group_id
  cpu_alert_threshold_percent       = var.cpu_alert_threshold_percent
  memory_alert_threshold_percent    = var.memory_alert_threshold_percent
  allowed_inbound_cidrs             = local.effective_inbound_cidrs
  tags                              = local.common_tags
}

module "automation" {
  source = "./modules/automation"
  count  = local.automation_enabled ? 1 : 0

  resource_group_name         = azurerm_resource_group.main.name
  location                    = var.location
  automation_account_name     = local.automation_account_name
  automation_runbook_name     = local.automation_runbook_name
  timezone                    = local.normalized_off_hours_timezone
  scale_down_cron             = var.scale_down_cron
  scale_up_cron               = var.scale_up_cron
  target_resource_group_name  = azurerm_resource_group.main.name
  target_container_app_name   = module.container_platform.container_app_name
  business_hours_min_replicas = var.business_hours_min_replicas
  off_hours_min_replicas      = var.off_hours_min_replicas
  subscription_id             = data.azurerm_subscription.current.subscription_id
  tags                        = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  scope_resource_group_id         = azurerm_resource_group.main.id
  acr_id                          = module.container_platform.acr_id
  container_app_principal_id      = module.container_platform.container_app_principal_id
  automation_account_principal_id = local.automation_enabled ? module.automation[0].automation_principal_id : null
  enable_automation_scale_role    = local.automation_enabled
  automation_scale_role_name      = format("ContainerAppScaleOperator-%s", local.name_prefix)
  pipeline_principal_object_id    = var.pipeline_principal_object_id
  subscription_id                 = data.azurerm_subscription.current.subscription_id
}
