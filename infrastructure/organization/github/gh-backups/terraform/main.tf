terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.55.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
  required_version = ">= 1.10"
}

resource "github_repository" "github_backups" {
  name = var.github_repository
}

resource "github_repository_environment" "prod" {
  environment = "Prod"
  repository  = github_repository.github_backups.name
}

resource "github_actions_environment_variable" "github_organization_name" {
  repository    = github_repository.github_backups.name
  environment   = github_repository_environment.prod.environment
  variable_name = "GH_ORG_NAME"
  value         = var.github_owner
}

resource "github_actions_environment_variable" "github_bucket_name" {
  repository    = github_repository.github_backups.name
  environment   = github_repository_environment.prod.environment
  variable_name = "S3_BUCKET_NAME"
  value         = data.scaleway_object_bucket.github_backups.name
}

resource "github_actions_environment_variable" "github_s3_endpoint" {
  repository    = github_repository.github_backups.name
  environment   = github_repository_environment.prod.environment
  variable_name = "S3_ENDPOINT"
  value         = data.scaleway_object_bucket.github_backups.endpoint
}

resource "github_actions_environment_variable" "github_s3_region" {
  repository    = github_repository.github_backups.name
  environment   = github_repository_environment.prod.environment
  variable_name = "S3_REGION"
  value         = data.scaleway_object_bucket.github_backups.region
}

resource "github_actions_environment_secret" "github_s3_access_key" {
  repository      = github_repository.github_backups.name
  environment     = github_repository_environment.prod.environment
  secret_name     = "S3_ACCESS_KEY"
  plaintext_value = local.github_backups_api_key.access_key
}

resource "github_actions_environment_secret" "github_s3_secret_key" {
  repository      = github_repository.github_backups.name
  environment     = github_repository_environment.prod.environment
  secret_name     = "S3_SECRET_KEY"
  plaintext_value = local.github_backups_api_key.secret_key
}
