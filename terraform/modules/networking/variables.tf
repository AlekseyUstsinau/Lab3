variable "resource_group_name" {
  description = "Resource Group name hosting the network."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name."
  type        = string
}

variable "vnet_cidr" {
  description = "Virtual network CIDR."
  type        = string
}

variable "aca_subnet_cidr" {
  description = "Container Apps delegated subnet CIDR."
  type        = string
}

variable "private_endpoint_subnet_cidr" {
  description = "Private endpoint subnet CIDR."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
