resource "azurerm_role_assignment" "pipeline_rg_contributor" {
  count                = var.pipeline_principal_object_id != "00000000-0000-0000-0000-000000000000" ? 1 : 0
  scope                = var.scope_resource_group_id
  role_definition_name = "Contributor"
  principal_id         = var.pipeline_principal_object_id
}

resource "azurerm_role_assignment" "app_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.container_app_principal_id
}

resource "azurerm_role_definition" "container_app_scale_operator" {
  count       = var.enable_automation_scale_role ? 1 : 0
  name        = var.automation_scale_role_name
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Least-privilege role for automation to patch Container App scale settings."

  permissions {
    actions = [
      "Microsoft.App/containerApps/read",
      "Microsoft.App/containerApps/write",
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
    not_actions = []
  }

  assignable_scopes = ["/subscriptions/${var.subscription_id}"]
}

resource "azurerm_role_assignment" "automation_scale_operator" {
  count              = var.enable_automation_scale_role ? 1 : 0
  scope              = var.scope_resource_group_id
  role_definition_id = azurerm_role_definition.container_app_scale_operator[0].role_definition_resource_id
  principal_id       = var.automation_account_principal_id
}
