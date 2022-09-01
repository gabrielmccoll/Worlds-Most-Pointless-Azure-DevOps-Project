resource "azurerm_resource_group" "envvkv_rg" {

  name     = "envvend_keyvault${random_integer.suffix.result}"
  location = var.location
}

resource "azurerm_key_vault" "envvkv_kv" {
  name                       = "envvendkvpp${random_integer.suffix.result}"
  resource_group_name        = azurerm_resource_group.envvkv_rg.name
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  location                   = azurerm_resource_group.envvkv_rg.location
  enable_rbac_authorization  = true
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_subscription.current.tenant_id

}

resource "azurerm_role_assignment" "envvkv_ra" {
  scope                = azurerm_key_vault.envvkv_kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.envv_fa.identity[0].principal_id
}

