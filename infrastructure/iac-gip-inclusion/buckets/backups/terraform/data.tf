data "scaleway_account_project" "iac_gip_inclusion" {
  name     = "iac-gip-inclusion"
  provider = scaleway.tmp
}

data "scaleway_iam_application" "terraform_ci" {
  name = "terraform-ci"
}
