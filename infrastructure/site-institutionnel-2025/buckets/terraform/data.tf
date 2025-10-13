data "scaleway_account_project" "site_institutionnel_2025" {
  name     = "site-institutionnel-2025"
  provider = scaleway.tmp
}

data "scaleway_iam_application" "site_institutionnel_2025" {
  name = "site-institutionnel-2025"
}

data "scaleway_iam_application" "terraform_ci" {
  name = "terraform-ci"
}
