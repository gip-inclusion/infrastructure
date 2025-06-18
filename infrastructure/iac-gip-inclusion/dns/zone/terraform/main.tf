terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_domain_zone" "zone" {
  domain    = "inclusion.gouv.fr"
  subdomain = ""
}
