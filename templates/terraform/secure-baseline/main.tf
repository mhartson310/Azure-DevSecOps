# Use existing Resource Group or create a new one - This example assumes it exists and its name is passed via variable.
# If you want Terraform to manage the RG lifecycle, uncomment the resource block below.
# resource "azurerm_resource_group" "rg" {
#   name     = var.resource_group_name
#   location = var.location
#   tags     = merge(var.common_tags, { environment = var.environment })
# }

locals {
  # Generate resource names if specific names are not provided
  la_workspace_name = var.log_analytics_workspace_name == "" ? "${var.resource_prefix}-la-${var.environment}-${random_string.suffix.result}" : var.log_analytics_workspace_name
  key_vault_name    = var.key_vault_name == "" ? "${var.resource_prefix}-kv-${var.environment}-${random_string.suffix.result}" : var.key_vault_name
  # Storage account names need to be globally unique, lowercase alphanumeric, 3-24 chars
  storage_account_name = var.storage_account_name == "" ? lower(replace("${var.resource_prefix}st${var.environment}${random_string.suffix.result}", "/[^a-z0-9]/", "")) : var.storage_account_name
  common_tags = merge(var.common_tags, {
    environment = var.environment
    created_by  = "terraform"
  })
}

# Used for resource name randomization if names aren't specified
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "la" {
  name                = local.la_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days
  tags                = local.common_tags
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = local.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.key_vault_sku
  soft_delete_retention_days  = 7
  purge_protection_enabled    = var.enable_key_vault_purge_protection
  enable_rbac_authorization   = var.enable_key_vault_rbac

  # Default network ACLs block all - adjust if specific public access needed, prefer Private Endpoints
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices" # Allows Azure services like Backup, Site Recovery to access
    ip_rules       = []              # Add specific allowed public IPs if necessary
    # virtual_network_subnet_ids = [] # Add subnet IDs if using VNet Service Endpoints
  }

  tags = local.common_tags
}

# Storage Account
resource "azurerm_storage_account" "st" {
  name                            = local.storage_account_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication_type
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false # Disable public access by default, prefer Private Endpoints
  allow_nested_items_to_be_public = false
  # Enable infrastructure encryption for double encryption (optional, may have cost impact)
  # infrastructure_encryption_enabled = true

  tags = local.common_tags
}

# Diagnostic Settings for Key Vault -> Log Analytics
resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name                       = "${local.key_vault_name}-diag-la"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id

  enabled_log {
    category = "AuditEvent" # Logs operations like secret access, key usage
  }
  // You can enable specific metrics as needed
  // metric {
  //   category = "AllMetrics"
  //   enabled  = true
  // }
}

# Diagnostic Settings for Storage Account -> Log Analytics (Blob operations)
resource "azurerm_monitor_diagnostic_setting" "st_diag_blob" {
  count = azurerm_storage_account.st.account_kind == "StorageV2" || azurerm_storage_account.st.account_kind == "BlobStorage" ? 1 : 0 # Only for storage types supporting blob logging

  name                       = "${local.storage_account_name}-diag-blob-la"
  target_resource_id         = azurerm_storage_account.st.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id

  # Logging V2 - Preferred
  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }

  // metric {
  //   category = "Transaction" // Basic storage metrics
  //   enabled  = true
  // }
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Assign Azure Security Benchmark policy initiative (optional)
resource "azurerm_resource_group_policy_assignment" "security_benchmark" {
  count = var.assign_security_benchmark_policy ? 1 : 0

  name                 = "azure-security-benchmark-${var.resource_group_name}"
  resource_group_id    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}" # Use data source or direct RG reference if managed here
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8" # Built-in ID for Azure Security Benchmark v3
  description          = "Assigns the Azure Security Benchmark policies to the resource group."
  display_name         = "Azure Security Benchmark"

  # Policies within this initiative might require parameters or managed identities for remediation -
  # this basic assignment won't configure those. Needs further customization if remediation is desired.
  identity {
    type = "SystemAssigned" # Needed for some policies within the initiative
  }
  location = var.location # Required for assignments with identity
}
