terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
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

resource "scaleway_account_project" "do_not_use" {
  name        = "do-not-use"
  description = <<EOT
    ${var.managed}
    This project should not have any resources, it is only intended to be
    Scaleway’s console default project.
    Use Terraform https://github.com/gip-inclusion/infrastructure to manage
    resources.
    EOT
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
