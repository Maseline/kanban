terraform {
    required_providers {
        github = {
            source = "integrations/github"
            version = "5.41.0"
        }
    }
}

locals {
    repository_name = "kanban"
    github_owner = "Maseline"
}

provider "github" {
    owner = local.github_owner
}

resource "github_repository" "kanban" {
    name = local.repository_name
    description = "Taking the beam to production programatically"
    visibility = "private"
    has_issues = true
    auto_init = true
    gitignore_template = "Terraform"
    delete_branch_on_merge = false
}

variable "milestones" {
    type = map(object({
        title = string
        due_date = string
        description = string
    }))
    description = "Milestones, the biggest deliverable unit"
}

resource "github_repository_milestone" "epics" {
    depends_on = [github_repository.kanban]
    for_each = var.milestones
    owner = local.github_owner
    repository = local.repository_name
    title = each.value.title
    due_date = each.value.due_date
    description = replace(each.value.description, "\n", " ")
}

variable "labels" {
    type = map(object({
        name = string
        color = string
    }))
    description = "Labels to tag issues"
}

resource "github_issue_label" "issues_labels" {
    depends_on = [github_repository.kanban]
    for_each = var.labels
    repository = local.repository_name
    name = each.value.name
    color = each.value.color
}

variable "issues" {
    type = list(object({
        title = string
        body = string
        labels = list(string)
        milestone = string
    }))
}

resource "github_issue" "tasks" {
    count = length(var.issues)
    repository = local.repository_name
    title = var.issues[count.index].title
    body = var.issues[count.index].body 
    milestone_number = github_repository_milestone.epics[var.issues[count.index].milestone].number
    labels = [for l in var.issues[count.index].labels : github_issue_label.issues_labels[l].name]
}