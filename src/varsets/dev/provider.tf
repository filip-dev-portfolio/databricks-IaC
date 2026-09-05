terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

    backend "azurerm" {
    resource_group_name   = "rg-tfworkspace-dev"
    storage_account_name  = "stdataingestiondev"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
    }
}