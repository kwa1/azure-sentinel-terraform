variable "resource_group_name" {
  description = "The name of the Resource Group for Sentinel"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "workspace_name" {
  description = "The name of the Log Analytics workspace for Sentinel"
  type        = string
}

variable "retention_days" {
  description = "Retention period (in days) for the Log Analytics workspace"
  type        = number
  default     = 30
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "deploy_private_link" {
  description = "Flag to deploy Azure Private Link for secure communication"
  type        = bool
  default     = true
}

variable "private_subnet_id" {
  description = "The subnet ID for the private endpoint"
  type        = string
}
