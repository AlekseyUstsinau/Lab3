variable "resource_group_name" {
  description = "Resource Group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID."
  type        = string
}

variable "key_vault_name" {
  description = "Key Vault name."
  type        = string
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft delete retention in days."
  type        = number
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection."
  type        = bool
}

variable "key_vault_public_network_access_enabled" {
  description = "Enable Key Vault public endpoint."
  type        = bool
}

variable "key_vault_allowed_ip_rules" {
  description = "IP CIDRs allowed to public Key Vault endpoint."
  type        = list(string)
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for private endpoint resources."
  type        = string
}

variable "private_dns_zone_vnet_id" {
  description = "VNet linked to private DNS zone."
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
}

variable "log_retention_days" {
  description = "Retention days for workspace logs."
  type        = number
}

variable "alert_action_group_name" {
  description = "Action Group name for alerts."
  type        = string
}

variable "alert_email" {
  description = "Email receiver for monitor alerts."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
