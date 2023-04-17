terraform {
  required_version = ">= 1.3.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "alexgdevopshard-tfstate-rg"
    storage_account_name = "alexgdevopshardtfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
