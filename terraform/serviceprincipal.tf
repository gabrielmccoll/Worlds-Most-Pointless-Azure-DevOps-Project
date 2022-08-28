

resource "azuread_application" "tf" {
  display_name = var.projectName
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "tf" {
  application_id               = azuread_application.tf.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_assignment" "tf" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = azuread_service_principal.tf.id
  role_definition_name = "Contributor"
}

resource "time_rotating" "tf" {
  rotation_days = 7
}

resource "azuread_application_password" "tf" {
  application_object_id = azuread_application.tf.object_id
  rotate_when_changed = {
    rotation = time_rotating.tf.id
  }
  display_name = "uselesstf"
}