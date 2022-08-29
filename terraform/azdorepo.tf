resource "azuredevops_git_repository" "useless" {
  project_id = azuredevops_project.useless.id
  name       = "uselessProjectFiles"
  default_branch = "refs/heads/main"
  initialization {
    init_type = "Clean"

  }

}


resource "azuredevops_git_repository_file" "templatesonar" {
    for_each = toset( local.azdostagefiles )
    repository_id = azuredevops_git_repository.useless.id
    branch = "refs/heads/main"
    commit_message =   "initial useless seed"
    file = ".pipelines/${each.key}"
    content = file("${path.module}/../project_files/.pipelines/${each.key}")
    overwrite_on_create = true
}


