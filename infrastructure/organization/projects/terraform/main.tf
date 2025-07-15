terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_account_project" "default" {
  name = "default"
}

resource "scaleway_account_project" "terraform" {
  name        = "terraform"
  description = var.managed
}

resource "scaleway_account_project" "emplois_cnav" {
  name        = "emplois-cnav"
  description = var.managed
}
