terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_domain_zone" "zone_root" {
  domain    = "inclusion.gouv.fr"
  subdomain = ""
}
