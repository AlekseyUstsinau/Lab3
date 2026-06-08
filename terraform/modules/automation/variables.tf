variable "resource_group_name" {
  description = "Resource Group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "automation_account_name" {
  description = "Automation account name."
  type        = string
}

variable "automation_runbook_name" {
  description = "Automation runbook name."
  type        = string
}

variable "timezone" {
  description = "Timezone for schedules."
  type        = string
}

variable "scale_down_cron" {
  description = "Cron schedule to scale down."
  type        = string
}

variable "scale_up_cron" {
  description = "Cron schedule to scale up."
  type        = string
}

variable "scale_down_start_time" {
  description = "Computed RFC3339 start time for the scale-down schedule."
  type        = string
}

variable "scale_up_start_time" {
  description = "Computed RFC3339 start time for the scale-up schedule."
  type        = string
}

variable "target_resource_group_name" {
  description = "Target resource group containing Container App."
  type        = string
}

variable "target_container_app_name" {
  description = "Target Container App name."
  type        = string
}

variable "business_hours_min_replicas" {
  description = "Min replicas during business hours."
  type        = number
}

variable "off_hours_min_replicas" {
  description = "Min replicas during off-hours."
  type        = number
}

variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
