

resource "azuredevops_git_repository_file" "diagrampy" {
    repository_id = azuredevops_git_repository.useless.id
    branch = "refs/heads/main"
    commit_message =   "initial useless seed"
    file = "diagram.py"
    content = file("${path.module}/../project_files/diagram.py")
}