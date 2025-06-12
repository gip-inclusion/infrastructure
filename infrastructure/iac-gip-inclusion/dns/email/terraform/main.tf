terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_domain_record" "records" {
  for_each = local.records

  dns_zone = data.scaleway_domain_zone.zone.id
  name     = each.value.name
  data     = each.value.data
  type     = each.value.type
  ttl      = try(each.value.ttl, 3600)
  priority = try(each.value.priority, 0)
}
