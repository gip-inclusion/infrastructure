data "scaleway_account_project" "emplois_cnav" {
  provider = scaleway.tmp
  name     = "emplois-cnav"
}

data "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
}
