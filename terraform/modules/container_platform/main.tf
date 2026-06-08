locals {
  image_full = format("%s:%s", var.image_repository, var.image_tag)
}

resource "azurerm_container_registry" "main" {
  name                          = var.acr_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.acr_sku
  admin_enabled                 = false
  public_network_access_enabled = var.acr_public_network_access_enabled
  tags                          = var.tags
}

resource "azurerm_container_app_environment" "main" {
  name                       = var.container_app_environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  infrastructure_subnet_id   = var.infrastructure_subnet_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  zone_redundancy_enabled    = var.zone_redundancy_enabled
  tags                       = var.tags

  lifecycle {
    ignore_changes = [workload_profile]
  }
}

resource "azurerm_container_app" "main" {
  name                         = var.container_app_name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = var.revision_mode
  tags                         = var.tags

  identity {
    type = "SystemAssigned"
  }

  ingress {
    external_enabled           = var.ingress_external_enabled
    target_port                = var.container_port
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "nginx"
      image  = local.image_full
      cpu    = var.container_cpu
      memory = var.container_memory

      liveness_probe {
        transport = "HTTP"
        port      = var.container_port
        path      = "/"
      }

      readiness_probe {
        transport = "HTTP"
        port      = var.container_port
        path      = "/"
      }
    }

    http_scale_rule {
      name                = "http-concurrency"
      concurrent_requests = tostring(var.target_concurrency)
    }
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = "system"
  }

  lifecycle {
    ignore_changes = [workload_profile_name]
  }
}

resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "aca-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app.main.id]
  description         = "Alert when Container App CPU usage is consistently high."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold_percent
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "memory_high" {
  name                = "aca-memory-high"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app.main.id]
  description         = "Alert when Container App memory usage is consistently high."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_alert_threshold_percent
  }

  action {
    action_group_id = var.action_group_id
  }
}
