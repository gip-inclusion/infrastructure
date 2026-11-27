data "scaleway_account_project" "terraform" {
  name     = "terraform"
  provider = scaleway.tmp
}

data "scaleway_iam_application" "terraform_ci" {
  name = "terraform-ci"
}

data "scaleway_iam_group" "secu_analyse_repo_admins" {
  name = "secu-analyse-repo-admins"
}
