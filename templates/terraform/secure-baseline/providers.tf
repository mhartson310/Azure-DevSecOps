terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Or your preferred up-to-date version
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
  # Recommend using authentication methods like Azure CLI, Service Principal with OIDC, or Managed Identity
  # Avoid hardcoding credentials.
}
