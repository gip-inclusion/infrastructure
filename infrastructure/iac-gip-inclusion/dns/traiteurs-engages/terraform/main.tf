terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

module "dns-traiteurs-engages" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region     = var.scw_region
  scw_zone       = var.scw_zone
  scw_project_id = data.scaleway_account_project.iac_gip_inclusion.project_id

  records = {
    "staging" = {
      name = "staging.traiteurs-engages"
      data = "traiteurs-engages-staging.osc-fr1.scalingo.io."
      type = "CNAME"
    },
    "prod" = {
      name = "traiteurs.engages"
      data = "proxy.applicatif.net."
      type = "CNAME"
    },
  }
}

import {
  to = module.dns-traiteurs-engages.scaleway_domain_record.records["staging"]
  id = "inclusion.gouv.fr/e0d64f79-928e-4c44-9758-5211f9bb8cd6"
}

import {
  to = module.dns-traiteurs-engages.scaleway_domain_record.records["prod"]
  id = "inclusion.gouv.fr/ea9b0c4a-6f6a-4658-9326-5d3a3fb6d8f9"
}
