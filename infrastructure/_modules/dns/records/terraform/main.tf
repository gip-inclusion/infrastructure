terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_domain_record" "records" {
  for_each = var.records

  # Ambiguous zone ID returned by the Scaleway provider
  # Refs: https://console.scaleway.com/support/tickets/1512910
  # dns_zone = data.scaleway_domain_zone.zone.id
  dns_zone = local.root_zone.id
  name     = each.value.name
  data     = each.value.data
  type     = each.value.type
  ttl      = each.value.ttl
  priority = each.value.priority
}
