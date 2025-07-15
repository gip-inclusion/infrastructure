data "scaleway_account_project" "default" {
  name = "default"
}

data "scaleway_account_project" "terraform" {
  name = "terraform"
}

data "scaleway_account_project" "emplois_cnav" {
  name = "emplois-cnav"
}
