variable "resource_group_name" {
  description = "Name of the resource group where network resources will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region where network resources will be deployed."
  type        = string
}

variable "resource_prefix" {
  description = "A prefix to apply to resource names."
  type        = string
  default     = "netsec"
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

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string
  default     = "" # If empty, generated from prefix
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network (e.g., [\"10.0.0.0/16\"])."
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "subnets" {
  description = "A map of subnet configurations. Key is the subnet name."
  type = map(object({
    address_prefix = string
    # Add other subnet specific settings if needed, e.g., service_endpoints
  }))
  default = {
    "default" = { address_prefix = "10.100.1.0/24" }
    # Example: "app"     = { address_prefix = "10.100.2.0/24" }
    # Example: "db"      = { address_prefix = "10.100.3.0/24" }
  }
}

variable "default_nsg_rules" {
  description = "Default NSG rules applied to all subnets unless overridden. Set to null to disable default rules."
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string # Inbound or Outbound
    access                     = string # Allow or Deny
    protocol                   = string # Tcp, Udp, Icmp, *
    source_port_range          = string # *, 80, 80-90
    destination_port_range     = string # *, 443, 22
    source_address_prefix      = string # *, VirtualNetwork, AzureLoadBalancer, Internet, IP address/CIDR
    destination_address_prefix = string # *, VirtualNetwork, IP address/CIDR
  }))
  default = [
    # Example: Allow SSH from a specific Bastion/Jumpbox subnet (replace CIDR)
    # { name = "AllowSSHInbound", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "22", source_address_prefix = "10.1.0.0/24", destination_address_prefix = "*" },
    { name = "AllowVnetOutbound", priority = 100, direction = "Outbound", access = "Allow", protocol = "*", source_port_range = "*", destination_port_range = "*", source_address_prefix = "VirtualNetwork", destination_address_prefix = "VirtualNetwork" },
    { name = "AllowInternetOutbound", priority = 200, direction = "Outbound", access = "Allow", protocol = "*", source_port_range = "*", destination_port_range = "*", source_address_prefix = "*", destination_address_prefix = "Internet" }, # Consider restricting this if using Azure Firewall
    # Default Deny rules are implicit but can be made explicit if desired
    # { name = "DenyAllInbound", priority = 4090, direction = "Inbound", access = "Deny", protocol = "*", source_port_range = "*", destination_port_range = "*", source_address_prefix = "*", destination_address_prefix = "*" },
    # { name = "DenyAllOutbound", priority = 4090, direction = "Outbound", access = "Deny", protocol = "*", source_port_range = "*", destination_port_range = "*", source_address_prefix = "*", destination_address_prefix = "*" },
  ]
}

variable "enable_azure_firewall" {
  description = "Deploy Azure Firewall and required subnet/resources."
  type        = bool
  default     = false
}

variable "firewall_address_prefix" {
  description = "Address prefix for the AzureFirewallSubnet (must be /26 or larger)."
  type        = string
  default     = "10.100.254.0/26" # Example, ensure it doesn't overlap
}

variable "enable_bastion" {
  description = "Deploy Azure Bastion and required subnet/resources."
  type        = bool
  default     = false
}

variable "bastion_address_prefix" {
  description = "Address prefix for the AzureBastionSubnet (must be /26 or larger, recommended /26)."
  type        = string
  default     = "10.100.255.0/26" # Example, ensure it doesn't overlap
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace to send diagnostic logs to (NSG Flow Logs, Firewall Logs)."
  type        = string
  default     = null # Required if enabling diagnostics
}
