resource "github_repository" "this" {
  for_each               = local.repositories
  name                   = each.key
  description            = "Repository for ${each.key}"
  allow_rebase_merge     = false
  allow_update_branch    = true
  delete_branch_on_merge = true
  vulnerability_alerts   = true
  has_wiki               = false  
  has_downloads          = true
  has_issues             = true
}

resource "github_branch" "this" {
  for_each   = local.flattened_repositories
  repository = github_repository.this[each.value.repo_name].repository
  branch     = each.value.branch
}

resource "github_branch_protection_v3" "this" {
  for_each                        = local.flattened_repositories
  repository                      = github_repository.this[each.value.repo_name].name
  branch                          = github_branch.this[each.key].branch
  enforce_admins                  = true
  require_conversation_resolution = true
  require_signed_commits          = false

  required_pull_request_reviews {
        dismiss_stale_reviews           = false
        dismissal_apps                  = []
        dismissal_teams                 = []
        dismissal_users                 = []
        require_code_owner_reviews      = false
        require_last_push_approval      = true
        required_approving_review_count = 2

        bypass_pull_request_allowances {
          apps  = []
          teams = each.value.bypass_pull_request_allowances_teams
          users = []
        }
    }

  required_status_checks {
    strict = false
    checks = try(each.value.required_status_checks, null)
  }
  restrictions {
    apps  = []
    teams = each.value.merge_allowances_teams
    users = []
  }
}

resource "github_team" "this" {
  for_each    = local.teams
  name        = each.key
  description = "Team ${each.key}"
  privacy     = each.value.privacy
}

locals {
  user_team_pairs = flatten([
    for user_key, user_value in local.users : [
      for team in user_value.teams : {
        username = user_key
        team     = team
      }
    ]
  ])

  repo_team_pairs = flatten([
    for team_key, team_value in local.teams : [
      for acces_for_repos_key, acces_for_repos_values in (try(team_value.acces_for_repos, {})) : {
        repository  = acces_for_repos_key
        team        = team_key
        permissions = acces_for_repos_values.permissions
      }
    ]
  ])
}

resource "github_team_membership" "this" {
  for_each = { for pair in local.user_team_pairs : "${pair.username}-${pair.team}" => pair }
  team_id  = github_team.this[each.value.team].id
  username = each.value.username
  role     = "member"
}

resource "github_team_repository" "this" {
  for_each   = {for value in local.repo_team_pairs : "${value.team}-${value.repository}" => value}
  team_id    = github_team.this[each.value.team].id
  repository = each.value.repository
  permission = each.value.permissions
}