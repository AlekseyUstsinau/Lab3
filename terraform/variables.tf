variable "application_name" {
  description = "Short application name used in naming and tagging."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.application_name))
    error_message = "application_name must be 2-20 chars, lowercase letters, digits, or hyphen."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], lower(var.environment))
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location cannot be empty."
  }
}

variable "region_short" {
  description = "Short region token used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,5}$", var.region_short))
    error_message = "region_short must be 2-5 lowercase letters or digits."
  }
}

variable "instance_number" {
  description = "Three-digit instance suffix for uniqueness."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[0-9]{3}$", var.instance_number))
    error_message = "instance_number must be 3 digits, for example 001."
  }
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}

variable "cost_center" {
  description = "Cost center tag value."
  type        = string
}

variable "managed_by" {
  description = "ManagedBy tag value."
  type        = string
  default     = "IaC"
}

variable "tags" {
  description = "Additional tags merged with mandatory tags."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Optional override for Resource Group name."
  type        = string
  default     = null
}

variable "vnet_cidr" {
  description = "Address space for VNet."
  type        = string
  default     = "10.30.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vnet_cidr))
    error_message = "vnet_cidr must be a valid CIDR block."
  }
}

variable "aca_subnet_cidr" {
  description = "Subnet CIDR delegated to Azure Container Apps environment."
  type        = string
  default     = "10.30.1.0/23"

  validation {
    condition     = can(cidrnetmask(var.aca_subnet_cidr))
    error_message = "aca_subnet_cidr must be a valid CIDR block."
  }
}

variable "private_endpoint_subnet_cidr" {
  description = "Subnet CIDR used for private endpoints."
  type        = string
  default     = "10.30.4.0/24"

  validation {
    condition     = can(cidrnetmask(var.private_endpoint_subnet_cidr))
    error_message = "private_endpoint_subnet_cidr must be a valid CIDR block."
  }
}

variable "allowed_inbound_cidrs" {
  description = "CIDRs allowed to reach the container app ingress endpoint."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.allowed_inbound_cidrs : can(cidrnetmask(cidr))])
    error_message = "allowed_inbound_cidrs must contain valid CIDR values."
  }
}

variable "acr_name" {
  description = "Optional ACR name override."
  type        = string
  default     = null
}

variable "acr_sku" {
  description = "Azure Container Registry SKU."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

variable "acr_public_network_access_enabled" {
  description = "Whether ACR public endpoint is enabled."
  type        = bool
  default     = true
}

variable "image_repository" {
  description = "Container image repository (for example nginx)."
  type        = string
  default     = "nginx"
}

variable "image_tag" {
  description = "Pinned image tag. Do not use latest."
  type        = string
  default     = "1.27.0-alpine"

  validation {
    condition     = lower(var.image_tag) != "latest"
    error_message = "image_tag must be pinned and cannot be latest."
  }
}

variable "container_app_environment_name" {
  description = "Optional Container Apps environment name override."
  type        = string
  default     = null
}

variable "container_app_name" {
  description = "Optional Container App name override."
  type        = string
  default     = null
}

variable "container_port" {
  description = "Container port exposed by ingress."
  type        = number
  default     = 80

  validation {
    condition     = var.container_port > 0 && var.container_port < 65536
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "container_cpu" {
  description = "CPU cores per replica."
  type        = number

  validation {
    condition     = var.container_cpu > 0
    error_message = "container_cpu must be greater than 0."
  }
}

variable "container_memory" {
  description = "Memory per replica. Example: 1Gi."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?Gi$", var.container_memory))
    error_message = "container_memory must use Gi format, for example 0.5Gi or 1Gi."
  }
}

variable "revision_mode" {
  description = "Container App revision mode."
  type        = string
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be Single or Multiple."
  }
}

variable "ingress_external_enabled" {
  description = "Expose Container App publicly."
  type        = bool
  default     = true
}

variable "min_replicas" {
  description = "Minimum replicas during business hours."
  type        = number

  validation {
    condition     = var.min_replicas >= 0
    error_message = "min_replicas must be 0 or greater."
  }
}

variable "max_replicas" {
  description = "Maximum replicas for autoscaling."
  type        = number

  validation {
    condition     = var.max_replicas >= var.min_replicas
    error_message = "max_replicas must be greater than or equal to min_replicas."
  }
}

variable "target_concurrency" {
  description = "Target concurrent HTTP requests per replica."
  type        = number

  validation {
    condition     = var.target_concurrency > 0
    error_message = "target_concurrency must be greater than 0."
  }
}

variable "enable_private_ingress" {
  description = "Restrict ingress to private mode when true."
  type        = bool
  default     = false
}

variable "enable_zone_redundancy" {
  description = "Enable zone redundancy for the Container Apps environment when region supports it."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_name" {
  description = "Optional Log Analytics workspace name override."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Log retention days for Log Analytics."
  type        = number

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730."
  }
}

variable "alert_action_group_name" {
  description = "Optional Action Group name override."
  type        = string
  default     = null
}

variable "alert_email" {
  description = "Email receiver for monitor alerts."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be a valid email format."
  }
}

variable "cpu_alert_threshold_percent" {
  description = "CPU alert threshold in percent."
  type        = number
  default     = 80
}

variable "memory_alert_threshold_percent" {
  description = "Memory alert threshold in percent."
  type        = number
  default     = 80
}

variable "key_vault_name" {
  description = "Optional Key Vault name override."
  type        = string
  default     = null
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft-delete retention for Key Vault."
  type        = number
  default     = 7
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable Key Vault purge protection."
  type        = bool
  default     = false
}

variable "key_vault_public_network_access_enabled" {
  description = "Enable public network access for Key Vault."
  type        = bool
  default     = true
}

variable "key_vault_allowed_ip_rules" {
  description = "Optional list of allowed public IP rules for Key Vault."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.key_vault_allowed_ip_rules : can(cidrnetmask(cidr))])
    error_message = "key_vault_allowed_ip_rules must contain valid CIDR values."
  }
}

variable "enable_night_schedule" {
  description = "Enable night scale-down/morning scale-up automation."
  type        = bool
  default     = true
}

variable "scale_down_cron" {
  description = "Night scale-down cron in NCRONTAB format."
  type        = string
  default     = "0 0 22 * * 1-5"
}

variable "scale_up_cron" {
  description = "Morning scale-up cron in NCRONTAB format."
  type        = string
  default     = "0 0 7 * * 1-5"
}

variable "off_hours_timezone" {
  description = "Timezone used by automation schedules."
  type        = string
  default     = "UTC"
}

variable "off_hours_min_replicas" {
  description = "Minimum replicas during off-hours schedule."
  type        = number
  default     = 0

  validation {
    condition     = var.off_hours_min_replicas >= 0
    error_message = "off_hours_min_replicas must be 0 or greater."
  }
}

variable "business_hours_min_replicas" {
  description = "Minimum replicas restored during business hours schedule."
  type        = number
  default     = 1

  validation {
    condition     = var.business_hours_min_replicas >= 0
    error_message = "business_hours_min_replicas must be 0 or greater."
  }
}

variable "automation_account_name" {
  description = "Optional Automation Account name override."
  type        = string
  default     = null
}

variable "automation_runbook_name" {
  description = "Optional Automation runbook name override."
  type        = string
  default     = null
}

variable "pipeline_principal_object_id" {
  description = "Object ID of GitHub OIDC principal for least-privilege RG Contributor assignment."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.pipeline_principal_object_id))
    error_message = "pipeline_principal_object_id must be a GUID."
  }
}
