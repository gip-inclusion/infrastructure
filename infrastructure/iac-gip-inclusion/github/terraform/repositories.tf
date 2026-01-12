# BEGIN GENERATED LOCALS
# END GENERATED LOCALS

resource "github_repository" "repos" {
  for_each = local.repositories

  name        = each.key
  description = lookup(each.value, "description", null)
  visibility  = lookup(each.value, "visibility", "private")

  has_issues      = lookup(each.value, "has_issues", true)
  has_wiki        = lookup(each.value, "has_wiki", false)
  has_projects    = lookup(each.value, "has_projects", false)
  has_discussions = lookup(each.value, "has_discussions", false)

  allow_merge_commit     = lookup(each.value, "allow_merge_commit", true)
  allow_squash_merge     = lookup(each.value, "allow_squash_merge", true)
  allow_rebase_merge     = lookup(each.value, "allow_rebase_merge", false)
  delete_branch_on_merge = lookup(each.value, "delete_branch_on_merge", true)

  archived           = lookup(each.value, "archived", false)
  archive_on_destroy = true

  vulnerability_alerts = lookup(each.value, "archived", false) ? null : lookup(each.value, "vulnerability_alerts", true)

  dynamic "security_and_analysis" {
    for_each = lookup(each.value, "archived", false) ? [] : [1]
    content {
      secret_scanning {
        status = lookup(each.value, "secret_scanning", false) ? "enabled" : "disabled"
      }
      secret_scanning_push_protection {
        status = lookup(each.value, "secret_scanning_push_protection", false) ? "enabled" : "disabled"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
