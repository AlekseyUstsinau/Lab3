variable "resource_group_name" {
  description = "Resource Group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "container_app_environment_name" {
  description = "Container Apps environment name."
  type        = string
}

variable "container_app_name" {
  description = "Container App name."
  type        = string
}

variable "image_repository" {
  description = "Container repository."
  type        = string
}

variable "image_tag" {
  description = "Pinned image tag."
  type        = string
}

variable "container_port" {
  description = "Ingress target port."
  type        = number
}

variable "container_cpu" {
  description = "Container CPU cores."
  type        = number
}

variable "container_memory" {
  description = "Container memory (Gi)."
  type        = string
}

variable "min_replicas" {
  description = "Minimum replicas."
  type        = number
}

variable "max_replicas" {
  description = "Maximum replicas."
  type        = number
}

variable "target_concurrency" {
  description = "HTTP concurrent request target per replica."
  type        = number
}

variable "revision_mode" {
  description = "Revision mode."
  type        = string
}

variable "ingress_external_enabled" {
  description = "Expose ingress publicly when true."
  type        = bool
}

variable "enable_private_ingress" {
  description = "Switches ingress to internal-only when true."
  type        = bool
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy where supported."
  type        = bool
}

variable "acr_name" {
  description = "Container Registry name."
  type        = string
}

variable "acr_sku" {
  description = "Container Registry SKU."
  type        = string
}

variable "acr_public_network_access_enabled" {
  description = "Enable ACR public endpoint."
  type        = bool
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID."
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "Delegated subnet for Container Apps environment."
  type        = string
}

variable "action_group_id" {
  description = "Action Group receiving metric alerts."
  type        = string
}

variable "cpu_alert_threshold_percent" {
  description = "CPU alert threshold percent."
  type        = number
}

variable "memory_alert_threshold_percent" {
  description = "Memory alert threshold percent."
  type        = number
}

variable "allowed_inbound_cidrs" {
  description = "List of CIDRs allowed by WAF/edge. Reserved for future NSG or WAF integration."
  type        = list(string)
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
