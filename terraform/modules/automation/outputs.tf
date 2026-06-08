output "automation_account_name" {
  description = "Automation account name."
  value       = azurerm_automation_account.main.name
}

output "automation_principal_id" {
  description = "System-assigned principal ID for Automation Account."
  value       = azurerm_automation_account.main.identity[0].principal_id
}
