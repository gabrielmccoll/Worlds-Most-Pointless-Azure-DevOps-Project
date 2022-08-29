resource "azurerm_resource_group" "vnet" {
  location = var.location
  name     = "${local.prefixdash}-rg-vnet"
}

resource "azurerm_virtual_network" "project" {
  address_space       = ["10.0.0.0/16"]
  name                = "${local.prefixdash}-vnet"
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name

}

