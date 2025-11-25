terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.57.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_account_project" "iac_gip_inclusion" {
  name = "iac-gip-inclusion"
}

moved {
  from = scaleway_account_project.default
  to   = scaleway_account_project.iac_gip_inclusion
}

resource "scaleway_account_project" "terraform" {
  name        = "terraform"
  description = var.managed
}

resource "scaleway_account_project" "emplois_cnav" {
  name        = "emplois-cnav"
  description = var.managed
}

resource "scaleway_account_project" "site_institutionnel_2025" {
  name        = "site-institutionnel-2025"
  description = var.managed
}
