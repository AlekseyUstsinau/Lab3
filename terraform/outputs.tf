output "resource_group_name" {
  description = "Resource Group name for the environment."
  value       = azurerm_resource_group.main.name
}

output "container_app_url" {
  description = "Public URL of the container app."
  value       = module.container_platform.container_app_url
}

output "container_app_name" {
  description = "Container app resource name."
  value       = module.container_platform.container_app_name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = module.container_platform.acr_login_server
}

output "key_vault_uri" {
  description = "Key Vault URI for secret storage."
  value       = module.security_monitoring.key_vault_uri
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = module.security_monitoring.log_analytics_workspace_id
}

output "action_group_id" {
  description = "Azure Monitor action group used for alerts."
  value       = module.security_monitoring.action_group_id
}

output "automation_account_name" {
  description = "Automation account used for off-hours scheduling."
  value       = local.automation_enabled ? module.automation[0].automation_account_name : null
}
