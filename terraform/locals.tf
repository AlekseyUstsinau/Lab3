locals {
  normalized_environment = lower(var.environment)

  name_prefix = format(
    "%s-%s-%s-%s",
    var.application_name,
    local.normalized_environment,
    var.region_short,
    var.instance_number
  )

  common_tags = merge(
    {
      Environment = local.normalized_environment
      Application = var.application_name
      CostCenter  = var.cost_center
      Owner       = var.owner
      ManagedBy   = var.managed_by
    },
    var.tags
  )

  rg_name   = coalesce(var.resource_group_name, format("rg-%s", local.name_prefix))
  vnet_name = format("vnet-%s", local.name_prefix)
  cae_name  = coalesce(var.container_app_environment_name, format("cae-%s", local.name_prefix))
  aca_name  = coalesce(var.container_app_name, format("aca-%s", local.name_prefix))
  acr_name = coalesce(
    var.acr_name,
    substr(replace(format("acr%s%s%s%s", var.application_name, local.normalized_environment, var.region_short, var.instance_number), "-", ""), 0, 50)
  )
  key_vault_name          = coalesce(var.key_vault_name, substr(replace(format("kv-%s", local.name_prefix), "_", "-"), 0, 24))
  log_analytics_name      = coalesce(var.log_analytics_workspace_name, format("law-%s", local.name_prefix))
  action_group_name       = coalesce(var.alert_action_group_name, format("ag-%s", local.name_prefix))
  automation_account_name = coalesce(var.automation_account_name, format("aa-%s", local.name_prefix))
  automation_runbook_name = coalesce(var.automation_runbook_name, "toggle-container-app-min-replicas")
  container_image_full    = format("%s:%s", var.image_repository, var.image_tag)
  automation_enabled      = var.enable_night_schedule && var.scale_down_cron != "" && var.scale_up_cron != ""
  scale_down_cron_parts   = local.automation_enabled ? split(" ", var.scale_down_cron) : []
  scale_up_cron_parts     = local.automation_enabled ? split(" ", var.scale_up_cron) : []
  scale_down_start_time = local.automation_enabled ? format(
    "%sT%02d:%02d:00Z",
    formatdate("YYYY-MM-DD", timestamp()),
    tonumber(local.scale_down_cron_parts[2]),
    tonumber(local.scale_down_cron_parts[1])
  ) : null
  scale_up_start_time = local.automation_enabled ? format(
    "%sT%02d:%02d:00Z",
    formatdate("YYYY-MM-DD", timestamp()),
    tonumber(local.scale_up_cron_parts[2]),
    tonumber(local.scale_up_cron_parts[1])
  ) : null
  effective_inbound_cidrs = length(var.allowed_inbound_cidrs) > 0 ? var.allowed_inbound_cidrs : ["0.0.0.0/0"]
}
