data "scaleway_account_project" "terraform" {
  name     = "terraform"
  provider = scaleway.tmp
}

data "scaleway_iam_application" "terraform_ci" {
  name = "terraform-ci"
}
