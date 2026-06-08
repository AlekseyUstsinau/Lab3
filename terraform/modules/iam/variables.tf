variable "scope_resource_group_id" {
  description = "Resource Group scope where CI/CD principal gets Contributor role."
  type        = string
}

variable "acr_id" {
  description = "ACR scope for AcrPull assignment."
  type        = string
}

variable "container_app_principal_id" {
  description = "Container App managed identity principal ID."
  type        = string
}

variable "automation_account_principal_id" {
  description = "Automation Account managed identity principal ID."
  type        = string
  default     = null
}

variable "pipeline_principal_object_id" {
  description = "GitHub OIDC principal object ID."
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID for custom role definition."
  type        = string
}

variable "enable_automation_scale_role" {
  description = "Whether automation scale role resources should be created."
  type        = bool
  default     = false
}

variable "automation_scale_role_name" {
  description = "Name for the custom role used by automation to scale Container Apps. Must be unique in Entra directory."
  type        = string
  default     = "ContainerAppScaleOperator"
}
