terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.20.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  storage_use_azuread = true
  features {
  }
}
