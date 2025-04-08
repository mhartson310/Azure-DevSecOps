# Terraform Azure Secure Baseline Template 🛡️🏗️

This Terraform template deploys a set of foundational Azure resources configured with security best practices in mind. It serves as a secure starting point for new Azure projects or environments.

**Deployed Resources:**

* [Azure Resource Group](https://learn.microsoft.com/azure/azure-resource-manager/management/overview#resource-groups) (Optionally managed by this template or use existing)
* [Azure Log Analytics Workspace](https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-workspace-overview) (For collecting logs and monitoring)
* [Azure Key Vault](https://learn.microsoft.com/azure/key-vault/general/overview) (Securely store secrets, keys, certs)
    * Configured with Purge Protection (optional)
    * Configured for RBAC Data Plane Authorization (optional, recommended)
    * Network ACLs default to "Deny" (prefer Private Endpoints)
* [Azure Storage Account](https://learn.microsoft.com/azure/storage/common/storage-account-overview) (General purpose v2)
    * Minimum TLS version set to 1.2
    * Public network access disabled by default (prefer Private Endpoints)
    * Nested items cannot be public
* [Azure Monitor Diagnostic Settings](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings) (Connecting Key Vault & Storage logs to Log Analytics)
* [Azure Policy Assignment](https://learn.microsoft.com/azure/governance/policy/overview) (Optionally assigns Azure Security Benchmark initiative)

[![Terraform Validate](https://github.com/your-repo/your-project/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/your-repo/your-project/actions/workflows/terraform-validate.yml) ![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)

---

## 🎯 Purpose & Real-World Scenarios

This template aims to accelerate the deployment of core Azure infrastructure while ensuring essential security controls are configured from the start.

**Use Cases:**

* **New Project Foundation:** Quickly establish a secure baseline for a new application environment in Azure.
* **Standardization:** Enforce consistent security configurations across multiple subscriptions or projects.
* **Compliance:** Help meet baseline security requirements often found in compliance frameworks by enabling logging, secure configurations, and policy assignments.
* **Learning:** Understand how to configure secure settings for core Azure services using Terraform.

---

##  Prerequisites 🛠️

1.  **Terraform:** Install Terraform (version >= 1.0 recommended). [Download Terraform](https://www.terraform.io/downloads.html)
2.  **Azure Account:** An active Azure subscription.
3.  **Authentication:** Authenticate Terraform to Azure. Recommended methods:
    * [Azure CLI Login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli) (`az login`)
    * [Service Principal & Client Secret/Certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
    * [Service Principal & OpenID Connect (OIDC)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc) (Ideal for CI/CD)
    * [Managed Identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_identity) (When running Terraform from Azure services like VMs or Azure DevOps)
    * **Avoid** embedding credentials directly in code.

---

## 🚀 Implementation Guidance

1.  **Clone Repository:** Clone this repository to your local machine.
2.  **Navigate:** Change directory into `terraform/secure-baseline/`.
3.  **Customize Variables:**
    * Create a `terraform.tfvars` file (recommended) or prepare command-line arguments (`-var="key=value"`) for required variables like `resource_group_name` and `location`.
    * Review `variables.tf` and adjust defaults (e.g., `resource_prefix`, `environment`, security toggles) as needed.

    **Example `terraform.tfvars`:**
    ```hcl
    resource_group_name = "rg-secure-baseline-dev-uksouth"
    location            = "uksouth"
    resource_prefix     = "myapp-sbsln"
    environment         = "development"
    common_tags = {
      owner       = "team-alpha"
      costCenter  = "12345"
      application = "MySecureApp"
    }
    # Override specific names if needed (otherwise they are generated)
    # key_vault_name    = "myapp-kv-dev-unique123"
    # storage_account_name = "myappsadevunique123"

    # Toggle security features
    enable_key_vault_purge_protection = true
    enable_key_vault_rbac           = true
    assign_security_benchmark_policy= true
    ```

4.  **Initialize Terraform:** Run `terraform init`. This downloads the required Azure provider plugin.
5.  **Plan:** Run `terraform plan -out=tfplan`. Review the execution plan to see what resources will be created or modified.
6.  **Apply:** Run `terraform apply tfplan`. Confirm the prompt by typing `yes`. Terraform will deploy the resources to Azure.
7.  **Destroy (Optional):** To remove the deployed resources, run `terraform destroy`.

---

## ⚙️ Inputs (Variables)

| Variable Name                      | Description                                                                | Type        | Default        | Required |
| :--------------------------------- | :------------------------------------------------------------------------- | :---------- | :------------- | :------- |
| `resource_group_name`              | Name of the **existing** resource group to deploy into.                    | `string`    | -              | **Yes** |
| `location`                         | Azure region for deployment.                                               | `string`    | -              | **Yes** |
| `resource_prefix`                  | Prefix for generated resource names.                                       | `string`    | `"sbsln"`      | No       |
| `environment`                      | Environment tag (e.g., dev, qa, prod).                                     | `string`    | `"dev"`        | No       |
| `common_tags`                      | Map of common tags to apply.                                               | `map(string)` | `{}`           | No       |
| `log_analytics_workspace_name`     | Specific name for Log Analytics. (Generated if empty)                      | `string`    | `""`           | No       |
| `log_analytics_sku`                | SKU for Log Analytics Workspace.                                           | `string`    | `"PerGB2018"`  | No       |
| `log_analytics_retention_days`     | Data retention period (days).                                              | `number`    | `90`           | No       |
| `key_vault_name`                   | Specific name for Key Vault (must be globally unique). (Generated if empty) | `string`    | `""`           | No       |
| `key_vault_sku`                    | Key Vault SKU (standard/premium).                                          | `string`    | `"standard"`   | No       |
| `enable_key_vault_purge_protection`| Enable Key Vault Purge Protection.                                         | `bool`      | `true`         | No       |
| `enable_key_vault_rbac`            | Enable RBAC data plane authorization (recommended).                        | `bool`      | `true`         | No       |
| `storage_account_name`             | Specific name for Storage Account (globally unique). (Generated if empty)  | `string`    | `""`           | No       |
| `storage_account_tier`             | Storage Account Tier (Standard/Premium).                                   | `string`    | `"Standard"`   | No       |
| `storage_account_replication_type` | Storage Account Replication (LRS/GRS/ZRS).                                 | `string`    | `"LRS"`        | No       |
| `assign_security_benchmark_policy` | Assign Azure Security Benchmark policy initiative.                         | `bool`      | `true`         | No       |

---

## 📤 Outputs

| Output Name                           | Description                                     |
| :------------------------------------ | :---------------------------------------------- |
| `resource_group_name`                 | Name of the resource group.                     |
| `log_analytics_workspace_id`          | ID of the Log Analytics Workspace.              |
| `log_analytics_workspace_name`        | Name of the Log Analytics Workspace.            |
| `key_vault_id`                        | ID of the Key Vault.                            |
| `key_vault_uri`                       | URI of the Key Vault.                           |
| `key_vault_name`                      | Name of the Key Vault.                          |
| `storage_account_id`                  | ID of the Storage Account.                      |
| `storage_account_name`                | Name of the Storage Account.                    |
| `storage_account_primary_blob_endpoint` | Primary Blob service endpoint for Storage Account. |

---

## 🤔 FAQ

1.  **Why disable public network access on the Storage Account by default?**
    * It significantly improves security by preventing accidental or intentional public exposure of data. Access should ideally be granted via [Private Endpoints](https://learn.microsoft.com/azure/storage/common/storage-private-endpoints) from within your virtual networks. If specific public access is needed, configure the Storage Account firewall rules carefully.
2.  **Why enable Key Vault RBAC instead of Access Policies?**
    * [RBAC (Role-Based Access Control)](https://learn.microsoft.com/azure/key-vault/general/rbac-guide) provides more granular permission control per-secret/key/certificate and aligns with the standard Azure RBAC model used for management plane operations, simplifying permission management. Access Policies are vault-wide.
3.  **How do I grant permissions to the Key Vault using RBAC?**
    * After deployment, assign roles like "Key Vault Secrets Officer" (manage secrets) or "Key Vault Secrets User" (read secrets) to users, groups, or service principals at the Key Vault scope (or individual secret scope) using Azure Portal, CLI, or separate Terraform resources (`azurerm_role_assignment`).
4.  **How can I extend this template?**
    * You can add more resources (e.g., databases, compute) to `main.tf`, referencing outputs like the Key Vault URI or Log Analytics ID. Consider structuring larger deployments using [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules).
5.  **What does the Azure Security Benchmark policy assignment do?**
    * It assigns a [built-in Azure Policy initiative](https://learn.microsoft.com/azure/governance/policy/samples/azure-security-benchmark) containing numerous policies that audit your environment against security best practices. This template only assigns it; reviewing compliance and configuring remediation (which may require parameters or managed identities) is a separate task.

---

**Disclaimer:** This template provides a baseline. Always review and adapt configurations to your specific security requirements and compliance needs. Test thoroughly in a non-production environment.
