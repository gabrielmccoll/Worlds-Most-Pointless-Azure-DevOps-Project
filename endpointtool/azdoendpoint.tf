resource "azuredevops_serviceendpoint_azurerm" "tool" {
  project_id            = azuredevops_project.tool.id
  service_endpoint_name = var.toolProject
  description           = "Overengineered and useless"
  credentials {
    serviceprincipalid  = azuread_service_principal.tf.application_id
    serviceprincipalkey = azuread_application_password.tf.value
  }
  azurerm_spn_tenantid      = var.tenantId
  azurerm_subscription_id   = var.subscriptionId
  azurerm_subscription_name = var.subscriptionName
}
