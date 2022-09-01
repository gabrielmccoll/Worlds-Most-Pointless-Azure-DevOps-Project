resource "azuredevops_project" "tool" {
  name               = var.toolProject
  version_control    = "git"
  work_item_template = "Agile"
  visibility         = "private"
}

resource "azuredevops_project" "target" {
  name               = var.targetProject
  version_control    = "git"
  work_item_template = "Agile"
  visibility         = "private"
}