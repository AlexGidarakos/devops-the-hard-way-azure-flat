terraform {
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
