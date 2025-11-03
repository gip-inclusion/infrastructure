data "scaleway_account_project" "default" {
  name = "default"
}

data "scaleway_object_bucket" "github_backups" {
  name       = "github-backups"
  project_id = data.scaleway_account_project.default.id
}

data "scaleway_secret_version" "github_backups_api_key" {
  secret_name = "github-backups-api-key"
  revision    = "latest_enabled"
  project_id  = data.scaleway_account_project.default.id
}
