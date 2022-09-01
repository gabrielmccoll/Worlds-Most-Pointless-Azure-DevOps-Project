
resource "azurerm_resource_group" "envv_rg" {
  name     = "env_vend_func${random_integer.suffix.result}"
  location = var.location
}

resource "azurerm_storage_account" "envv_sa" {
  name                     = "envvendpurpel${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.envv_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_application_insights" "envv_ai" {
  name                = "envvendpurpel${random_integer.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.envv_rg.name
  application_type    = "web"
}



resource "azurerm_service_plan" "envv_asp" {
name                = "envvendpurpel${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.envv_rg.name
  location            = var.location
  sku_name = "Y1"
  os_type = "Linux"
}


resource "azuread_application" "envvend-AAD" {
  display_name               = "envvend-AAD-TF${random_integer.suffix.result}"
 
 web {
        homepage_url  = "https://envvendpurpel${random_integer.suffix.result}"
        logout_url    = "https://envvendpurpel${random_integer.suffix.result}"
        redirect_uris = ["https://envvendpurpel${random_integer.suffix.result}.azurewebsites.net/.auth/login/aad/callback"]

        implicit_grant {
        access_token_issuance_enabled = true
        id_token_issuance_enabled     = true
        }
  }
  

}

resource "azuread_service_principal" "envvend-sp" {
  application_id = azuread_application.envvend-AAD.application_id
  tags = [
    "AppServiceIntegratedApp",
    "WindowsAzureActiveDirectoryIntegratedApp",
  ]
}


data "azurerm_key_vault_secret" "envvkv_adokey" {
  key_vault_id = azurerm_key_vault.envvkv_kv.id
  name         = "ADOkey"
  depends_on = [
  azurerm_key_vault_secret.envvkv_adokey
  ]
}

# resource "azurerm_function_app" "envv_fa" {
#   name                = "envvendpurpel${random_integer.suffix.result}"

#   resource_group_name = azurerm_resource_group.envv_rg.name
#   location            = var.location
#   app_service_plan_id = azurerm_service_plan.envv_asp.id
  
#   app_settings = {
#     "WEBSITE_RUN_FROM_PACKAGE"         = azurerm_storage_blob.funccode_ev.url,
#     "FUNCTIONS_WORKER_RUNTIME"         = "powershell",
#     "APPINSIGHTS_INSTRUMENTATIONKEY"   = azurerm_application_insights.envv_ai.instrumentation_key,
#     "adokey"                           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.envvkv_kv.vault_uri}secrets/${azurerm_key_vault_secret.envvkv_adokey.name}/${data.azurerm_key_vault_secret.envvkv_adokey.version})"
#   }

#   auth_settings {
#     enabled = true

#     active_directory {
#       client_id = azuread_application.envvend-AAD.application_id
#     }
#     default_provider = "AzureActiveDirectory"
#     issuer           = "https://sts.windows.net/${data.azurerm_subscription.current.tenant_id}/"

#   }
#   site_config {
    
#     use_32_bit_worker_process = false
#   }
#   storage_account_name       = azurerm_storage_account.envv_sa.name
#   storage_account_access_key = azurerm_storage_account.envv_sa.primary_access_key
#   version                    = "~3"
#   identity {
#     type = "SystemAssigned"
#   }
#   # lifecycle {
#   #   ignore_changes = [
#   #     app_settings["WEBSITE_RUN_FROM_PACKAGE"],
#   #   ]
#   # }
# }

resource "azurerm_linux_function_app" "envv_fa" {
  name                = "envvendpurpel${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.envv_rg.name
  location            = var.location
  service_plan_id = azurerm_service_plan.envv_asp.id
  storage_account_name       = azurerm_storage_account.envv_sa.name
  storage_account_access_key = azurerm_storage_account.envv_sa.primary_access_key
  functions_extension_version = "~3"

  site_config {
       use_32_bit_worker = false
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"         = azurerm_storage_blob.funccode_ev.url,
    "FUNCTIONS_WORKER_RUNTIME"         = "powershell",
    "APPINSIGHTS_INSTRUMENTATIONKEY"   = azurerm_application_insights.envv_ai.instrumentation_key,
    "adokey"                           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.envvkv_kv.vault_uri}secrets/${azurerm_key_vault_secret.envvkv_adokey.name}/${data.azurerm_key_vault_secret.envvkv_adokey.version})"
  }

  auth_settings {
    enabled = true

    active_directory {
      client_id = azuread_application.envvend-AAD.application_id
    }
    default_provider = "AzureActiveDirectory"
    issuer           = "https://sts.windows.net/${data.azurerm_subscription.current.tenant_id}/"

  }

}

# resource "null_resource" "envv_fa" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       az login --service-principal --username '${var.sp_appid}' -p='${var.sp_appsecret}' --tenant "${var.tenant}"
#       az functionapp update --name ${azurerm_function_app.envv_fa.name} --resource-group ${azurerm_function_app.envv_fa.resource_group_name} --set siteConfig.powerShellVersion=~7
#     EOT
#   }
#   depends_on = [azurerm_function_app.envv_fa]
#   triggers = {
#     function_change  = azurerm_function_app.envv_fa.id
#   }

# }