resource "azuredevops_build_definition" "useless" {
  project_id = azuredevops_project.useless.id
  name       = azuredevops_project.useless.name
  path       = "\\UselessFolder"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.useless.id
    branch_name = azuredevops_git_repository.useless.default_branch
    yml_path    = ".pipelines/rootpipeline.yml"
  }

}

resource "azuredevops_resource_authorization" "useless" {
  authorized = true
  project_id = azuredevops_project.useless.id
  definition_id = azuredevops_build_definition.useless.id
  resource_id = azuredevops_serviceendpoint_azurerm.useless.id
}