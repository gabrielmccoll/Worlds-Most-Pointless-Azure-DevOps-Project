resource "azurerm_resource_group" "storweb" {
  location = var.location
  name     = "${local.prefixdash}-rg-storage"
}

resource "azurerm_storage_account" "storweb" {
  name = "${local.prefixnodash}saweb123"
  resource_group_name = azurerm_resource_group.storweb.name
  location = azurerm_resource_group.storweb.location
  static_website {
      index_document = "useless.png"
  }
  enable_https_traffic_only = true
  account_kind = "StorageV2"
  account_tier = "Standard"
  access_tier = "Hot"
  account_replication_type = "LRS"
  default_to_oauth_authentication = true

}

#Add index.html to blob storage
resource "azurerm_storage_blob" "example" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.storweb.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source_content         = "<h1>This is static content coming from the Terraform</h1>"
}