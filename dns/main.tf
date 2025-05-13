terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

resource "scaleway_domain_zone" "zone" {
  domain    = "inclusion.gouv.fr"
  subdomain = ""
}

resource "scaleway_domain_record" "main" {
  for_each = var.records

  dns_zone = scaleway_domain_zone.zone.domain
  name     = each.value.name
  data     = each.value.data
  type     = each.value.type
  ttl      = each.value.ttl
  priority = each.value.priority
}
