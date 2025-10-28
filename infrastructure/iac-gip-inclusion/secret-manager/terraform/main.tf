terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_secret" "github_backups_api_key" {
  name        = "github-backups-api-key"
  protected   = true
  description = var.managed
  type        = "key_value"
}
