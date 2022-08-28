terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.20.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.2.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.28.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.8.0"
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
