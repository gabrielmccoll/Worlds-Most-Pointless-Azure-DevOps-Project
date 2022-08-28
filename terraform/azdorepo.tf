resource "azuredevops_git_repository" "useless" {
  project_id = azuredevops_project.useless.id
  name       = "uselessProjectFiles"
  default_branch = "refs/heads/main"
  initialization {
    init_type = "Clean"

  }

}

resource "azuredevops_git_repository_file" "rootpipeline" {
    repository_id = azuredevops_git_repository.useless.id
    branch = "refs/heads/main"
    commit_message =   "initial useless seed"
    file = "rootpipeline.yml"
    content = file("${path.module}/project_files/rootpipeline.yml")
}