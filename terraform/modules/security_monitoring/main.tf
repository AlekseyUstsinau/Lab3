resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

resource "azurerm_key_vault" "main" {
  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  soft_delete_retention_days    = var.key_vault_soft_delete_retention_days
  public_network_access_enabled = var.key_vault_public_network_access_enabled
  tags                          = var.tags

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.key_vault_allowed_ip_rules
  }
}

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "pdzvnl-kv"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = var.private_dns_zone_vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-kv"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }
}

resource "azurerm_monitor_action_group" "main" {
  name                = var.alert_action_group_name
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(var.alert_action_group_name, "-", ""), 0, 12)
  tags                = var.tags

  email_receiver {
    name          = "email-primary"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_activity_log_alert" "auth_failures" {
  name                = "activity-auth-failures"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = ["/subscriptions/${data.azurerm_subscription.current.subscription_id}"]
  description         = "Unauthorized or failed operations in the subscription activity log."
  tags                = var.tags

  criteria {
    category = "Administrative"
    level    = "Error"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

data "azurerm_subscription" "current" {}
