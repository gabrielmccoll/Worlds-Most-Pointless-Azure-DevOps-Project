resource "azurerm_resource_group" "funccode" {
  name     = "funccode_ev_storage${random_integer.suffix.result}"
  location = var.location
}

resource "azurerm_storage_account" "funccode" {
  name                     = "funccodeev${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.funccode.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "funccode_ev" {
  storage_account_name = azurerm_storage_account.funccode.name
  name                 = "funccodeev${random_integer.suffix.result}"

}

data "archive_file" "funccode_ev" {
  type        = "zip"
  source_dir  = "FunctionsCode/TechnicalTests"
  output_path = "envvend.zip"
}

resource "azurerm_storage_blob" "funccode_ev" {
  name                   = "${filesha256(data.archive_file.funccode_ev.output_path)}.zip"
  storage_account_name   = azurerm_storage_account.funccode.name
  storage_container_name = azurerm_storage_container.funccode_ev.name
  type                   = "Block"
  source                 = data.archive_file.funccode_ev.output_path
}

resource "azurerm_role_assignment" "funccode_sa_ev" {
  scope                = azurerm_storage_account.funccode.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_function_app.envv_fa.identity[0].principal_id
}


