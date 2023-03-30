terraform {
  required_version = ">= 1.3.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "TFSTATE_RESOURCE_GROUP_NAME"
    storage_account_name = "STORAGE_ACCOUNT_NAME"
    container_name       = "STORAGE_CONTAINER_NAME"
    key                  = "TFSTATE_FILENAME"
  }
}

provider "azurerm" {
  features {}
}
