resource "azuredevops_project" "useless" {
  name               = var.projectName
  version_control    = "git"
  work_item_template = "Agile"
  visibility         = "private"
}