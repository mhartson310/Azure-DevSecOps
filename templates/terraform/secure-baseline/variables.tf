variable "resource_group_name" {
  description = "Name of the resource group to deploy resources into."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
}

variable "resource_prefix" {
  description = "A prefix to apply to resource names for uniqueness and identification."
  type        = string
  default     = "sbsln" # Secure BaseLiNe
}

variable "environment" {
  description = "Environment tag (e.g., dev, qa, prod)."
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_name" {
  description = "Name for the Log Analytics Workspace."
  type        = string
  default     = "" # If empty, generated from prefix
}

variable "log_analytics_sku" {
  description = "SKU for the Log Analytics Workspace (e.g., PerGB2018, Free, Standalone)."
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Retention period in days for Log Analytics data."
  type        = number
  default     = 90 # Align with Sentinel's typical free retention
}

variable "key_vault_name" {
  description = "Name for the Azure Key Vault (must be globally unique)."
  type        = string
  default     = "" # If empty, generated from prefix
}

variable "key_vault_sku" {
  description = "SKU for the Key Vault (standard or premium)."
  type        = string
  default     = "standard"
}

variable "enable_key_vault_purge_protection" {
  description = "Enable Purge Protection on the Key Vault (recommended)."
  type        = bool
  default     = true
}

variable "enable_key_vault_rbac" {
  description = "Enable RBAC authorization for Key Vault data plane (recommended over Access Policies)."
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = "Name for the Storage Account (must be globally unique, lowercase alphanumeric)."
  type        = string
  default     = "" # If empty, generated from prefix
}

variable "storage_account_tier" {
  description = "Tier for the Storage Account (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Replication type for the Storage Account (e.g., LRS, GRS, ZRS)."
  type        = string
  default     = "LRS"
}

variable "assign_security_benchmark_policy" {
  description = "Assign the Azure Security Benchmark built-in policy initiative to the resource group."
  type        = bool
  default     = true
}
