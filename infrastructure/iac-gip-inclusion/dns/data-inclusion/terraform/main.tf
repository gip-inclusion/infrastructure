terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

module "dns-data-inclusion" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region     = var.scw_region
  scw_zone       = var.scw_zone
  scw_project_id = data.scaleway_account_project.iac_gip_inclusion.project_id

  records = {
    "ns0" = {
      name = "data"
      data = "ns0.dom.scw.cloud."
      type = "NS"
      ttl  = 1800
    },
    "ns1" = {
      name = "data"
      data = "ns1.dom.scw.cloud."
      type = "NS"
      ttl  = 1800
    },
  }
}
