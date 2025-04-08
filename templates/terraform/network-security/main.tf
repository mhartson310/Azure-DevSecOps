locals {
  vnet_name   = var.vnet_name == "" ? "${var.resource_prefix}-vnet-${var.environment}" : var.vnet_name
  common_tags = merge(var.common_tags, {
    environment = var.environment
    created_by  = "terraform"
  })

  # Add required subnets if features are enabled
  all_subnets = merge(
    var.subnets,
    var.enable_azure_firewall ? { "AzureFirewallSubnet" = { address_prefix = var.firewall_address_prefix } } : {},
    var.enable_bastion ? { "AzureBastionSubnet" = { address_prefix = var.bastion_address_prefix } } : {},
  )
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

# Subnets
resource "azurerm_subnet" "subnet" {
  for_each = local.all_subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]

  # Add service endpoints or delegations if needed in var.subnets definition
  # service_endpoints = lookup(each.value, "service_endpoints", null)
  # delegation {}
}

# Network Security Group (one per non-gateway/firewall/bastion subnet)
resource "azurerm_network_security_group" "nsg" {
  for_each = { for k, v in var.subnets : k => v } # Only create NSGs for subnets defined in the input variable

  name                = "${var.resource_prefix}-nsg-${each.key}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.common_tags

  dynamic "security_rule" {
    for_each = var.default_nsg_rules != null ? var.default_nsg_rules : []
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = "${security_rule.value.name} default rule"
    }
  }
  # Add custom rules specific to the subnet here if needed, or manage rules separately
}

# Associate NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = azurerm_network_security_group.nsg

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = each.value.id
}

# --- Optional: Azure Firewall ---
resource "azurerm_public_ip" "firewall_pip" {
  count = var.enable_azure_firewall ? 1 : 0

  name                = "${var.resource_prefix}-fw-pip-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"] # For zone redundancy, adjust if region doesn't support
  tags                = local.common_tags
}

resource "azurerm_firewall_policy" "fw_policy" {
  count = var.enable_azure_firewall ? 1 : 0

  name                = "${var.resource_prefix}-fwpolicy-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard" # Or Premium
  tags                = local.common_tags
  # Add threat_intelligence_mode, threat_intelligence_allowlist etc. as needed
}

# Example: Allow basic outbound internet access through firewall policy
resource "azurerm_firewall_policy_rule_collection_group" "fw_rcg_default" {
  count = var.enable_azure_firewall ? 1 : 0

  name               = "DefaultRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.fw_policy[0].id
  priority           = 500

  # Allow DNS
  network_rule_collection {
    name     = "NetworkRules"
    priority = 100
    action   = "Allow"
    rule {
      name = "AllowDNSToAzureDNS"
      protocols = ["UDP"]
      source_addresses = ["*"] # Restrict to VNet CIDR if possible
      destination_addresses = ["168.63.129.16"] # Azure DNS
      destination_ports = ["53"]
    }
     rule {
      name = "AllowDNSToGoogleDNS" # Example external DNS
      protocols = ["UDP"]
      source_addresses = ["*"]
      destination_addresses = ["8.8.8.8", "8.8.4.4"]
      destination_ports = ["53"]
    }
  }

  # Allow HTTP/HTTPS
  application_rule_collection {
    name     = "AppRules"
    priority = 200
    action   = "Allow"
    rule {
      name = "AllowCommonWeb"
      protocols { type = "Http" port = 80 }
      protocols { type = "Https" port = 443 }
      source_addresses = ["*"] # Restrict to VNet CIDR if possible
      target_fqdns = ["*.microsoft.com", "*.windowsupdate.com"] # Add essential FQDNs
    }
  }
}


resource "azurerm_firewall" "firewall" {
  count = var.enable_azure_firewall ? 1 : 0

  name                = "${var.resource_prefix}-fw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard" # Match policy SKU
  firewall_policy_id  = azurerm_firewall_policy.fw_policy[0].id
  tags                = local.common_tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.firewall_pip[0].id
  }
}

# --- Optional: Azure Bastion ---
resource "azurerm_public_ip" "bastion_pip" {
  count = var.enable_bastion ? 1 : 0

  name                = "${var.resource_prefix}-bas-pip-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_bastion_host" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name                = "${var.resource_prefix}-bas-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
  # sku                 = "Standard" # Or "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion_pip[0].id
  }
}

# --- Diagnostics ---
# NSG Flow Logs
resource "azurerm_network_watcher_flow_log" "nsg_flowlog" {
  # Create one per NSG defined in var.subnets
  for_each = var.log_analytics_workspace_id != null ? azurerm_network_security_group.nsg : {}

  # Need a Network Watcher in the region - this assumes one exists named "NetworkWatcher_REGION"
  # You might need to create/reference Network Watcher explicitly
  network_watcher_name = "NetworkWatcher_${var.location}" # Adjust if your NW name differs
  resource_group_name  = data.azurerm_network_watcher.main.resource_group_name # Assuming NW is in its own RG

  network_security_group_id = each.value.id
  storage_account_id        = # REQUIRED: ID of a storage account for flow logs (can be from baseline)
  enabled                   = true
  retention_policy {
    enabled = true
    days    = 7 # Adjust retention for flow log storage
  }

  # Optional: Traffic Analytics using the Log Analytics Workspace
  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.location # Must match LA workspace region
    workspace_resource_id = var.log_analytics_workspace_id
    interval_in_minutes   = 10
  }
  tags = local.common_tags
}

# Data source to get Network Watcher RG name (assuming default naming)
data "azurerm_network_watcher" "main" {
 name                = "NetworkWatcher_${var.location}"
 resource_group_name = "NetworkWatcherRG" # Default RG name for Network Watchers
}


# Firewall Diagnostics
resource "azurerm_monitor_diagnostic_setting" "fw_diag" {
  count = var.enable_azure_firewall && var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${azurerm_firewall.firewall[0].name}-diag-la"
  target_resource_id         = azurerm_firewall.firewall[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Log Categories for Azure Firewall
  enabled_log { category = "AzureFirewallApplicationRule" }
  enabled_log { category = "AzureFirewallNetworkRule" }
  enabled_log { category = "AzureFirewallDnsProxy" }
  # Add ThreatIntel logs if using Premium SKU + Threat Intel

  // metric {
  //   category = "AllMetrics"
  //   enabled  = true
  // }
}
