# GITHUB_APP_PEM_FILE env var must be set with the GitHub App private key content
provider "github" {
  owner = "gip-inclusion"

  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
  }
}
