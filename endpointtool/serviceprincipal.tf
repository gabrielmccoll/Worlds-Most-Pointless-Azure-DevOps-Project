

resource "azuread_application" "tf" {
  display_name = var.toolProject
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

resource "azurerm_role_assignment" "storage" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = azuread_service_principal.tf.id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "time_rotating" "tf" {
  rotation_days = 7
}

# resource "time_rotating" "fast" {
#   # rotation_days = 7
#  rotation_minutes = 1
  
# }

resource "azuread_application_password" "tf" {
  application_object_id = azuread_application.tf.object_id
  rotate_when_changed = {
    rotation = time_rotating.tf.id
  }
  display_name = "uselesstf"
  lifecycle {
    create_before_destroy = true
  }

}