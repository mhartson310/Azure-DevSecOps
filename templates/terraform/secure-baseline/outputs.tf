output "resource_group_name" {
  description = "The name of the resource group."
  value       = var.resource_group_name
}

output "log_analytics_workspace_id" {
  description = "The ID of the deployed Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.la.id
}

output "log_analytics_workspace_name" {
  description = "The name of the deployed Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.la.name
}

output "key_vault_id" {
  description = "The ID of the deployed Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  description = "The URI of the deployed Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}

output "key_vault_name" {
  description = "The name of the deployed Key Vault."
  value       = azurerm_key_vault.kv.name
}

output "storage_account_id" {
  description = "The ID of the deployed Storage Account."
  value       = azurerm_storage_account.st.id
}

output "storage_account_name" {
  description = "The name of the deployed Storage Account."
  value       = azurerm_storage_account.st.name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary Blob service endpoint for the Storage Account."
  value       = azurerm_storage_account.st.primary_blob_endpoint
}
