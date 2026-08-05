# BEGIN GENERATED LOCALS
# END GENERATED LOCALS

resource "github_organization_settings" "this" {
  name                                                         = local.org_settings.name
  description                                                  = local.org_settings.description
  blog                                                         = local.org_settings.blog
  location                                                     = local.org_settings.location
  billing_email                                                = local.org_settings.billing_email
  default_repository_permission                                = local.org_settings.default_repository_permission
  members_can_create_repositories                              = local.org_settings.members_can_create_repositories
  members_can_create_public_repositories                       = local.org_settings.members_can_create_public_repositories
  members_can_create_private_repositories                      = local.org_settings.members_can_create_private_repositories
  members_can_create_internal_repositories                     = local.org_settings.members_can_create_internal_repositories
  members_can_fork_private_repositories                        = local.org_settings.members_can_fork_private_repositories
  dependabot_alerts_enabled_for_new_repositories               = local.org_settings.dependabot_alerts_enabled
  dependabot_security_updates_enabled_for_new_repositories     = local.org_settings.dependabot_security_updates_enabled
  dependency_graph_enabled_for_new_repositories                = local.org_settings.dependency_graph_enabled
  secret_scanning_enabled_for_new_repositories                 = local.org_settings.secret_scanning_enabled
  secret_scanning_push_protection_enabled_for_new_repositories = local.org_settings.secret_scanning_push_protection_enabled
  web_commit_signoff_required                                  = local.org_settings.web_commit_signoff_required
}

resource "github_organization_ruleset" "rulesets" {
  for_each = local.org_rulesets

  name        = each.key
  target      = each.value.target
  enforcement = lookup(each.value, "enforcement", "active")

  dynamic "conditions" {
    for_each = lookup(each.value, "conditions", null) != null ? [each.value.conditions] : []
    content {
      ref_name {
        include = lookup(conditions.value, "ref_include", ["~DEFAULT_BRANCH"])
        exclude = lookup(conditions.value, "ref_exclude", [])
      }
      dynamic "repository_name" {
        for_each = lookup(conditions.value, "repository_include", null) != null ? [1] : []
        content {
          include = lookup(conditions.value, "repository_include", [])
          exclude = lookup(conditions.value, "repository_exclude", [])
        }
      }
    }
  }

  rules {
    creation                = lookup(each.value.rules, "creation", false)
    deletion                = lookup(each.value.rules, "deletion", false)
    non_fast_forward        = lookup(each.value.rules, "non_fast_forward", false)
    required_signatures     = lookup(each.value.rules, "required_signatures", false)
    required_linear_history = lookup(each.value.rules, "required_linear_history", false)

    dynamic "pull_request" {
      for_each = lookup(each.value.rules, "pull_request", null) != null ? [each.value.rules.pull_request] : []
      content {
        required_approving_review_count   = lookup(pull_request.value, "required_approving_review_count", 1)
        dismiss_stale_reviews_on_push     = lookup(pull_request.value, "dismiss_stale_reviews_on_push", true)
        require_code_owner_review         = lookup(pull_request.value, "require_code_owner_review", false)
        require_last_push_approval        = lookup(pull_request.value, "require_last_push_approval", false)
        required_review_thread_resolution = lookup(pull_request.value, "required_review_thread_resolution", false)
      }
    }

    dynamic "required_status_checks" {
      for_each = lookup(each.value.rules, "required_status_checks", null) != null ? [each.value.rules.required_status_checks] : []
      content {
        strict_required_status_checks_policy = lookup(required_status_checks.value, "strict", false)
        dynamic "required_check" {
          for_each = lookup(required_status_checks.value, "checks", [])
          content {
            context        = required_check.value.context
            integration_id = lookup(required_check.value, "integration_id", null)
          }
        }
      }
    }
  }
}
