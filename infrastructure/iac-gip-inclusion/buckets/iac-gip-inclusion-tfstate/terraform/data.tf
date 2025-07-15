data "scaleway_account_project" "terraform" {
  name = "terraform"
}

data "scaleway_iam_application" "terraform_ci" {
  name = "terraform-ci"
}
