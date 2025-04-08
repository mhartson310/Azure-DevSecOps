# Terraform Azure Network Security Template 🌐🔒

This Terraform template deploys foundational Azure network resources with a focus on security segmentation and control. It provides components like Virtual Networks (VNets), Subnets, Network Security Groups (NSGs), and optionally Azure Firewall and Azure Bastion.

**Deployed Resources:**

* [Azure Virtual Network (VNet)](https://learn.microsoft.com/azure/virtual-network/virtual-networks-overview) (The core network boundary)
* [Azure Subnets](https://learn.microsoft.com/azure/virtual-network/virtual-network-manage-subnet) (Segments within the VNet)
* [Network Security Groups (NSGs)](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview) (Stateful firewall rules applied to subnets)
    * Includes configurable default rules (e.g., allow VNet traffic, allow outbound internet)
* [Optional] [Azure Firewall](https://learn.microsoft.com/azure/firewall/overview) & [Firewall Policy](https://learn.microsoft.com/azure/firewall/policy-overview) (Centralized network traffic filtering)
    * Requires dedicated `AzureFirewallSubnet`
    * Includes basic outbound allow rules (DNS, Web) - **CUSTOMIZE THESE!**
* [Optional] [Azure Bastion](https://learn.microsoft.com/azure/bastion/bastion-overview) (Secure RDP/SSH access to VMs without public IPs)
    * Requires dedicated `AzureBastionSubnet`
* [Optional] [Network Watcher Flow Logs](https://learn.microsoft.com/azure/network-watcher/network-watcher-nsg-flow-logging-overview) & [Traffic Analytics](https://learn.microsoft.com/azure/network-watcher/traffic-analytics) (Requires existing Log Analytics Workspace & Storage Account)

[![Terraform Validate](https://github.com/your-repo/your-project/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/your-repo/your-project/actions/workflows/terraform-validate.yml) ![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)

---

## 🎯 Purpose & Real-World Scenarios

This template establishes secure network foundations, enabling segmentation and traffic control essential for protecting applications and data in Azure.

**Use Cases:**

* **Hub-Spoke Topology Foundation:** Deploy the network components for a central Hub VNet (often containing Firewall, Bastion, Gateways) or a Spoke VNet that peers to a Hub.
* **Application Environment Networking:** Set up the VNet and subnets for different application tiers (e.g., web, app, data), applying NSGs for micro-segmentation.
* **Enhanced Security Posture:** Implement centralized egress filtering with Azure Firewall or secure administrative access with Azure Bastion.
* **Standardization:** Ensure consistent network and NSG configurations across deployments.

---

##  Prerequisites 🛠️

1.  **Terraform:** Install Terraform (version >= 1.0 recommended). [Download Terraform](https://www.terraform.io/downloads.html)
2.  **Azure Account:** An active Azure subscription.
3.  **Authentication:** Authenticate Terraform to Azure (see methods in Secure Baseline README).
4.  **[Required if enabling Diagnostics]**
    * **Log Analytics Workspace ID:** The Resource ID of an existing Log Analytics Workspace (can be deployed using the `secure-baseline` template).
    * **Storage Account ID:** The Resource ID of an existing Storage Account for NSG Flow Logs (can be deployed using the `secure-baseline` template).
    * **Network Watcher:** An Azure Network Watcher must exist in the target region (usually enabled by default in a `NetworkWatcherRG`).

---

## 🚀 Implementation Guidance

1.  **Clone Repository:** Clone this repository to your local machine.
2.  **Navigate:** Change directory into `terraform/network-security/`.
3.  **Customize Variables:**
    * Create a `terraform.tfvars` file or use command-line arguments (`-var="key=value"`) for required variables (`resource_group_name`, `location`).
    * **Crucially**, configure `vnet_address_space` and the `subnets` map according to your network plan.
    * Review `default_nsg_rules` and customize them (especially source/destination restrictions). **Do not leave default rules overly permissive.**
    * Set `enable_azure_firewall = true` or `enable_bastion = true` if needed, ensuring address prefixes don't overlap.
    * Provide `log_analytics_workspace_id` and the `storage_account_id` (for NSG flow logs) if enabling diagnostics.

    **Example `terraform.tfvars`:**
    ```hcl
    resource_group_name = "rg-network-security-dev-uksouth"
    location            = "uksouth"
    resource_prefix     = "myapp-netsec"
    environment         = "development"
    common_tags = {
      owner       = "team-alpha"
      costCenter  = "12345"
    }

    vnet_address_space = ["10.200.0.0/16"]
    subnets = {
      "web" = { address_prefix = "10.200.1.0/24" }
      "app" = { address_prefix = "10.200.2.0/24" }
      "db"  = { address_prefix = "10.200.3.0/24" }
    }

    # Example customization of default rules (more restrictive)
    # default_nsg_rules = [
    #   { name = "AllowSSHFromBastion", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "22", source_address_prefix = "10.200.255.0/26", destination_address_prefix = "*" }, # Assuming Bastion is enabled and uses this prefix
    #   { name = "AllowWebInbound", priority = 110, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "443", source_address_prefix = "Internet", destination_address_prefix = "*" }, # Apply this rule selectively maybe, not default
    #   { name = "AllowVnetOutbound", priority = 100, direction = "Outbound", access = "Allow", protocol = "*", source_port_range = "*", destination_port_range = "*", source_address_prefix = "VirtualNetwork", destination_address_prefix = "VirtualNetwork" },
    #   { name = "DenyInternetOutbound", priority = 4000, direction = "Outbound", access = "Deny", protocol = "*", source_port_range = "*", destination_port_range = "*", source_address_prefix = "*", destination_address_prefix = "Internet" }, # Use if forcing traffic via Firewall
    # ]

    enable_azure_firewall = false # Set to true to deploy Firewall
    # firewall_address_prefix = "10.200.254.0/26" # Ensure no overlap

    enable_bastion = true # Set to true to deploy Bastion
    # bastion_address_prefix = "10.200.255.0/26" # Ensure no overlap

    # Required if enabling NSG Flow Logs / Firewall Diagnostics
    log_analytics_workspace_id = "/subscriptions/YOUR_SUB_ID/resourcegroups/rg-secure-baseline-dev-uksouth/providers/Microsoft.OperationalInsights/workspaces/myapp-sbsln-la-dev-xxxxxx"
    # Required for NSG Flow Logs
    # storage_account_id = "/subscriptions/YOUR_SUB_ID/resourcegroups/rg-secure-baseline-dev-uksouth/providers/Microsoft.Storage/storageAccounts/myappsadevuniquexxxxxx"
    ```

4.  **Initialize Terraform:** Run `terraform init`.
5.  **Plan:** Run `terraform plan -out=tfplan`. Carefully review the network resources and NSG rules that will be created.
6.  **Apply:** Run `terraform apply tfplan`. Confirm the prompt by typing `yes`.
7.  **Destroy (Optional):** To remove the deployed resources, run `terraform destroy`.

---

## ⚙️ Inputs (Variables)

*(See `variables.tf` for detailed descriptions and defaults)*

| Variable Name             | Description                                                | Type           | Required                                  |
| :------------------------ | :--------------------------------------------------------- | :------------- | :---------------------------------------- |
| `resource_group_name`     | Name of the resource group for network resources.          | `string`       | **Yes** |
| `location`                | Azure region for deployment.                               | `string`       | **Yes** |
| `resource_prefix`         | Prefix for generated resource names.                       | `string`       | No                                        |
| `environment`             | Environment tag.                                           | `string`       | No                                        |
| `common_tags`             | Map of common tags.                                        | `map(string)`  | No                                        |
| `vnet_name`               | Specific VNet name (generated if empty).                   | `string`       | No                                        |
| `vnet_address_space`      | List of CIDR blocks for the VNet.                          | `list(string)` | No (defaults to `["10.100.0.0/16"]`)      |
| `subnets`                 | Map defining subnets and their address prefixes.           | `map(object)`  | No (defaults to one `default` subnet)     |
| `default_nsg_rules`       | List of NSG rules applied to created NSGs.                 | `list(object)` | No (uses example defaults, **review!**)   |
| `enable_azure_firewall`   | Deploy Azure Firewall and related resources.               | `bool`         | No                                        |
| `firewall_address_prefix` | CIDR for `AzureFirewallSubnet` (required if firewall enabled). | `string`       | No                                        |
| `enable_bastion`          | Deploy Azure Bastion and related resources.                | `bool`         | No                                        |
| `bastion_address_prefix`  | CIDR for `AzureBastionSubnet` (required if bastion enabled). | `string`       | No                                        |
| `log_analytics_workspace_id`| ID of Log Analytics Workspace for diagnostics.             | `string`       | No (**Yes** if enabling diagnostics)      |
| `storage_account_id`      | ID of Storage Account for NSG Flow Logs.                   | `string`       | No (**Yes** if enabling NSG Flow Logs)    |

---

## 📤 Outputs

| Output Name                | Description                                            |
| :------------------------- | :----------------------------------------------------- |
| `vnet_id`                  | ID of the deployed VNet.                               |
| `vnet_name`                | Name of the deployed VNet.                             |
| `subnet_ids`               | Map of subnet names to their IDs.                      |
| `network_security_group_ids` | Map of subnet names to associated NSG IDs.             |
| `firewall_id`              | ID of Azure Firewall (if enabled).                     |
| `firewall_public_ip`       | Public IP of Azure Firewall (if enabled).              |
| `bastion_host_id`          | ID of Azure Bastion host (if enabled).                 |
| `bastion_host_dns_name`    | DNS name of Azure Bastion host (if enabled).           |

---

## 🤔 FAQ

1.  **Why apply NSGs to Subnets instead of Network Interfaces (NICs)?**
    * Applying NSGs at the subnet level simplifies management and ensures consistent rules for all resources within that subnet. Applying rules to individual NICs can become complex and harder to audit. You can still use Application Security Groups (ASGs) within NSG rules for granular control over specific VMs without managing NIC-level NSGs.
2.  **How do I customize NSG rules beyond the defaults?**
    * You can modify the `default_nsg_rules` variable for rules common to all subnets defined here.
    * For rules specific to *one* subnet (e.g., allowing port 1433 only to the 'db' subnet), you would typically add separate `azurerm_network_security_rule` resources outside the default loop, targeting the specific NSG (e.g., `azurerm_network_security_group.nsg["db"].id`).
3.  **When should I use Azure Firewall vs. just NSGs?**
    * **NSGs** operate at Layer 4 (TCP/UDP ports, IP addresses) and are great for basic segmentation between subnets and controlling north-south/east-west traffic based on IPs/Ports.
    * **Azure Firewall** is a managed, stateful firewall-as-a-service operating at Layers 3, 4, and 7. Use it for:
        * Centralized egress filtering (controlling outbound internet access based on FQDNs, categories).
        * Advanced threat intelligence filtering.
        * Centralized logging and policy management across multiple VNets (in a Hub-Spoke model).
        * SNAT/DNAT capabilities.
    * Often, you use both: Firewall for centralized edge security and egress control, and NSGs for internal micro-segmentation between subnets.
4.  **How do I route traffic through the Azure Firewall?**
    * You need to create [User Defined Routes (UDRs)](https://learn.microsoft.com/azure/virtual-network/virtual-networks-udr-overview) on your workload subnets (e.g., 'web', 'app', 'db') that direct default outbound traffic (0.0.0.0/0) to the Azure Firewall's private IP address as the next hop. This requires creating `azurerm_route_table` and `azurerm_route` resources and associating them with the subnets (`azurerm_subnet_route_table_association`). This is not included in this template but is a common next step when using the Firewall.
5.  **How do I connect resources deployed with the `secure-baseline` template (like Key Vault/Storage) securely to this VNet?**
    * Use [Azure Private Endpoints](https://learn.microsoft.com/azure/private-link/private-endpoint-overview). Deploy `azurerm_private_endpoint` resources within one of your subnets defined here, linking them to the Key Vault or Storage Account deployed by the baseline template. This requires appropriate DNS configuration (usually via [Azure Private DNS Zones](https://learn.microsoft.com/azure/private-link/private-endpoint-dns)).

---

**Disclaimer:** Network security is critical. Always review NSG rules, Firewall policies, and network topology carefully. **The default rules in this template may need significant modification to meet your security requirements.** Test thoroughly in a non-production environment. Ensure address spaces do not overlap if deploying multiple instances or integrating with existing networks.
