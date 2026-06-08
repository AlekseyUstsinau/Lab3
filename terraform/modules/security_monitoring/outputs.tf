output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_primary_shared_key" {
  description = "Primary shared key for workspace ingestion."
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "key_vault_id" {
  description = "Key Vault ID."
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = azurerm_key_vault.main.vault_uri
}

output "action_group_id" {
  description = "Monitor Action Group ID."
  value       = azurerm_monitor_action_group.main.id
}
