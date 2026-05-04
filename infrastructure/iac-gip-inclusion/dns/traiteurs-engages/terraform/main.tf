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
