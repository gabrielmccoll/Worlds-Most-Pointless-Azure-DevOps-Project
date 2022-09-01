resource "azurerm_key_vault" "tooluse" {
  tenant_id = data.azuread_client_config.current.tenant_id
  resource_group_name = azurerm_resource_group.tooluse.name
  location = azurerm_resource_group.tooluse.location
  name = "endpnttoolgm"
  enable_rbac_authorization = true
  sku_name = "standard"
}


resource "azurerm_role_assignment" "toolusekv" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = azuread_service_principal.tf.id
  role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "me" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = data.azuread_client_config.current.object_id
  role_definition_name = "Key Vault Secrets Officer"
  
}

resource "azurerm_key_vault_secret" "envvkv_adokey" {
  key_vault_id = azurerm_key_vault.envvkv_kv.id
  name         = "ADOkey"
  value        = var.adokey
  depends_on = [

    azurerm_role_assignment.me
  ]
}