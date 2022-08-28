terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.20.0"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
      version = "0.2.2"
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



resource "azurerm_resource_group" "devops" {
    name = "testdev"
    location = "uksouth"
  
}