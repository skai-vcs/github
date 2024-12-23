locals {
  common_repo_settings = {
    protected_branch_list                = [
      # "main", 
      # "staging"
    ]
    required_status_checks               = [
    ]
    bypass_pull_request_allowances_teams = [
      "global-devops",
      "global-teaamleads",
    ]
    merge_allowances_teams               = [
      "global-teaamleads"
    ]
    enforce_admins                       = false
  }

  repositories = {
    github = {
      merge_allowances_teams             = [
        "global-teaamleads",
        "global-devops",
      ]
    },
    infrastructure = {},
    ops-actions-workflows = {},
    ops-actions-components = {}
  }
    
  flattened_repositories = merge([
    for repo_key, repo_values in local.repositories : {
      for branch in try(repo_values.protected_branch_list, local.common_repo_settings.protected_branch_list) : "${repo_key}-${branch}" => {
        repo_name                            = repo_key
        branch                               = branch
        bypass_pull_request_allowances_teams = try(repo_values.bypass_pull_request_allowances_teams, local.common_repo_settings.bypass_pull_request_allowances_teams)
        required_status_checks               = try(repo_values.required_status_checks == []? [] : concat(local.common_repo_settings.required_status_checks, repo_values.required_status_checks), local.common_repo_settings.required_status_checks)
        enforce_admins                       = try(repo_values.enforce_admins, local.common_repo_settings.enforce_admins)
        merge_allowances_teams               = try(repo_values.merge_allowances_teams, local.common_repo_settings.merge_allowances_teams)
      }
    }
  ]...)
}