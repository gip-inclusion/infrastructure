data "scaleway_account_project" "traiteurs_engages" {
  name     = "traiteurs-engages"
  provider = scaleway.tmp
}

data "scaleway_iam_application" "traiteurs_engages" {
  name = "traiteurs-engages"
}

data "scaleway_iam_application" "terraform_ci" {
  name = "terraform-ci"
}
