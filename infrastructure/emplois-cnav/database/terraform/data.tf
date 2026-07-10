data "scaleway_account_project" "emplois_cnav" {
  name     = "emplois-cnav"
  provider = scaleway.tmp
}

data "scaleway_vpc_private_network" "kubernetes_private_network" {
  name = "emplois-cnav-kubernetes-private-network"
}

data "scaleway_secret" "api_relay_cnav_database" {
  for_each = var.database_environments

  name = "api-relay-database-${each.key}"
}

data "scaleway_secret" "api_relay_cnav_database_connection" {
  for_each = var.database_environments

  name = "api-relay-database-connection-${each.key}"
}
