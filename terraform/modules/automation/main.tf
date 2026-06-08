resource "azurerm_automation_account" "main" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_automation_runbook" "toggle_min_replicas" {
  name                    = var.automation_runbook_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  runbook_type            = "PowerShell"
  log_progress            = true
  log_verbose             = false

  content = <<-EOT
param(
  [Parameter(Mandatory = $true)]
  [string]$subscriptionid,

  [Parameter(Mandatory = $true)]
  [string]$resourcegroupname,

  [Parameter(Mandatory = $true)]
  [string]$containerappname,

  [Parameter(Mandatory = $true)]
  [int]$targetminreplicas
)

Connect-AzAccount -Identity | Out-Null
Set-AzContext -SubscriptionId $subscriptionid | Out-Null

$patchBody = @{
  properties = @{
    template = @{
      scale = @{
        minReplicas = $targetminreplicas
      }
    }
  }
} | ConvertTo-Json -Depth 20

$path = "/subscriptions/$subscriptionid/resourceGroups/$resourcegroupname/providers/Microsoft.App/containerApps/$containerappname?api-version=2024-03-01"
Invoke-AzRestMethod -Method PATCH -Path $path -Payload $patchBody | Out-Null
EOT
}

resource "azurerm_automation_schedule" "scale_down" {
  name                    = "schedule-scale-down"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  frequency               = "Week"
  interval                = 1
  timezone                = var.timezone
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  description             = "Scale down during off-hours. Source cron: ${var.scale_down_cron}"

  lifecycle {
    ignore_changes = [timezone]
  }
}

resource "azurerm_automation_schedule" "scale_up" {
  name                    = "schedule-scale-up"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  frequency               = "Week"
  interval                = 1
  timezone                = var.timezone
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  description             = "Scale up at business-hours start. Source cron: ${var.scale_up_cron}"

  lifecycle {
    ignore_changes = [timezone]
  }
}

resource "azurerm_automation_job_schedule" "scale_down" {
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  schedule_name           = azurerm_automation_schedule.scale_down.name
  runbook_name            = azurerm_automation_runbook.toggle_min_replicas.name

  parameters = {
    subscriptionid    = var.subscription_id
    resourcegroupname = var.target_resource_group_name
    containerappname  = var.target_container_app_name
    targetminreplicas = tostring(var.off_hours_min_replicas)
  }
}

resource "azurerm_automation_job_schedule" "scale_up" {
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  schedule_name           = azurerm_automation_schedule.scale_up.name
  runbook_name            = azurerm_automation_runbook.toggle_min_replicas.name

  parameters = {
    subscriptionid    = var.subscription_id
    resourcegroupname = var.target_resource_group_name
    containerappname  = var.target_container_app_name
    targetminreplicas = tostring(var.business_hours_min_replicas)
  }
}
