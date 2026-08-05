output "team_ids" {
  description = "Map of team slugs to team IDs"
  value       = { for k, v in github_team.teams : k => v.id }
}

output "repository_names" {
  description = "List of managed repository names"
  value       = keys(local.repositories)
}

output "repository_urls" {
  description = "Map of repository names to URLs"
  value       = { for k, v in github_repository.repos : k => v.html_url }
}
