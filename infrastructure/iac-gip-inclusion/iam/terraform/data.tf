data "scaleway_account_project" "iac_gip_inclusion" {
  name = "iac-gip-inclusion"
}

data "scaleway_account_project" "terraform" {
  name = "terraform"
}

data "scaleway_account_project" "emplois_cnav" {
  name = "emplois-cnav"
}

data "scaleway_account_project" "site_institutionnel_2025" {
  name = "site-institutionnel-2025"
}
