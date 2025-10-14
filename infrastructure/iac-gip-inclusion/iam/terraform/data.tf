data "scaleway_account_project" "default" {
  name = "default"
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
