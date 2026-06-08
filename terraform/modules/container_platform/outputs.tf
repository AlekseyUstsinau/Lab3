output "container_app_id" {
  description = "Container App ID."
  value       = azurerm_container_app.main.id
}

output "container_app_name" {
  description = "Container App name."
  value       = azurerm_container_app.main.name
}

output "container_app_url" {
  description = "Container App URL."
  value       = format("https://%s", azurerm_container_app.main.ingress[0].fqdn)
}

output "container_app_principal_id" {
  description = "System-assigned managed identity principal ID for the app."
  value       = azurerm_container_app.main.identity[0].principal_id
}

output "acr_id" {
  description = "ACR ID."
  value       = azurerm_container_registry.main.id
}

output "acr_login_server" {
  description = "ACR login server."
  value       = azurerm_container_registry.main.login_server
}
