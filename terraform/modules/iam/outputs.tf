output "pipeline_rg_contributor_assignment_id" {
  description = "Role assignment ID for pipeline Contributor access on target RG."
  value       = try(azurerm_role_assignment.pipeline_rg_contributor[0].id, null)
}

output "app_acr_pull_assignment_id" {
  description = "Role assignment ID for app AcrPull on ACR."
  value       = azurerm_role_assignment.app_acr_pull.id
}
