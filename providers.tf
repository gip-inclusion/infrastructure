terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

provider "github" {
  owner = "gip-inclusion"
}

provider "scaleway" {
  alias           = "terraform-ci"
  region          = var.scw_default_region
  zone            = var.scw_default_zone
  organization_id = var.scw_organization_id
  project_id      = var.scw_organization_id
  access_key      = var.scw_access_key
  secret_key      = var.scw_secret_key
}
