# BEGIN GENERATED LOCALSss
# END GENERATED LOCALS

resource "github_team" "teams" {
  for_each = local.teams

  name        = each.value.name
  description = lookup(each.value, "description", null)
  privacy     = lookup(each.value, "privacy", "closed")

  create_default_maintainer = false
}

resource "github_team_repository" "access" {
  for_each = local.team_repositories

  team_id    = github_team.teams[each.value.team].id
  repository = github_repository.repos[each.value.repository].name
  permission = each.value.permission
}
