data "scaleway_account_project" "emplois_cnav" {
  name     = "emplois-cnav"
  provider = scaleway.tmp
}

data "scaleway_vpc_private_network" "private_network" {
  name = "emplois-cnav-vpc-private-network"
}
