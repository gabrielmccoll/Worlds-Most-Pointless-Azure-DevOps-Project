resource "azuredevops_git_repository" "useless" {
  project_id = azuredevops_project.useless.id
  name       = "uselessProjectFiles"
  default_branch = "refs/heads/main"
  initialization {
    init_type = "Clean"
  }
}
#https://netmemo.github.io/post/tf-map-ordering/
#all the pipelines
resource "azuredevops_git_repository_file" "templatesonar" {
    for_each = { for key,rule in local.azdostagefiles : key => key }  
    repository_id = azuredevops_git_repository.useless.id
    branch = "refs/heads/main"
    commit_message =   "created by Terraform" // don't change the commit message or it reacreates every time
    file = ".pipelines/${each.key}"
    content = file("${path.module}/../project_files/.pipelines/${each.key}")
    overwrite_on_create = true
}

#the diagram and python files
resource "azuredevops_git_repository_file" "diagrampy" {
    repository_id = azuredevops_git_repository.useless.id
    branch = "refs/heads/main"
    commit_message =   "created by Terraform" // don't change the commit message or it reacreates every time
    file = "diagram.py"
    content = file("${path.module}/../project_files/diagram.py")
}

# all the terraform tfs
resource "azuredevops_git_repository_file" "terraform" {
    for_each = { for key,rule in local.projterrfiles : key => key }    
    repository_id = azuredevops_git_repository.useless.id
    branch = "refs/heads/main"
    commit_message =   "created by Terraform" // don't change the commit message or it reacreates every time
    file = "terraform/${each.key}"
    content = file("${path.module}/../project_files/terraform/${each.key}")
    overwrite_on_create = true
}

# terraform conf
resource "azuredevops_git_repository_file" "terrconf" {
    repository_id = azuredevops_git_repository.useless.id
    branch = "refs/heads/main"
    commit_message =   "created by Terraform" // don't change the commit message or it reacreates every time
    file = "terraform/backend.conf"
    content = file("${path.module}/../project_files/terraform/backend.conf")
}
