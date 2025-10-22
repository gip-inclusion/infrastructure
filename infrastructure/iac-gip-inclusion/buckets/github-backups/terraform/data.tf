data "scaleway_account_project" "default" {
  name     = "default"
  provider = scaleway.tmp
}

data "scaleway_iam_application" "terraform_ci" {
  name = "terraform-ci"
}

data "scaleway_iam_application" "github_backups" {
  name = "github-backups"
}
