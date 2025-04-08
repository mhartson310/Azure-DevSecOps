output "vnet_id" {
  description = "The ID of the deployed Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the deployed Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "A map of subnet names to their IDs."
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "network_security_group_ids" {
  description = "A map of subnet names to their associated NSG IDs."
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}

output "firewall_id" {
  description = "The ID of the deployed Azure Firewall (if enabled)."
  value       = var.enable_azure_firewall ? azurerm_firewall.firewall[0].id : null
}

output "firewall_public_ip" {
  description = "The public IP address of the deployed Azure Firewall (if enabled)."
  value       = var.enable_azure_firewall ? azurerm_public_ip.firewall_pip[0].ip_address : null
}

output "bastion_host_id" {
  description = "The ID of the deployed Azure Bastion host (if enabled)."
  value       = var.enable_bastion ? azurerm_bastion_host.bastion[0].id : null
}

output "bastion_host_dns_name" {
  description = "The DNS name of the deployed Azure Bastion host (if enabled)."
  value       = var.enable_bastion ? azurerm_bastion_host.bastion[0].dns_name : null
}
