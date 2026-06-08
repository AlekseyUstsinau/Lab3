output "vnet_id" {
  description = "Virtual network ID."
  value       = azurerm_virtual_network.main.id
}

output "aca_subnet_id" {
  description = "Delegated subnet ID for Container Apps."
  value       = azurerm_subnet.aca.id
}

output "private_endpoint_subnet_id" {
  description = "Subnet ID used by private endpoints."
  value       = azurerm_subnet.private_endpoints.id
}
