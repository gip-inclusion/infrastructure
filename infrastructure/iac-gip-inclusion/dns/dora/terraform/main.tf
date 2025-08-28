terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.55.0"
    }
  }
  required_version = ">= 1.10"
}

module "dns-dora" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region = var.scw_region
  scw_zone   = var.scw_zone

  records = {
    "ns0" = {
      name = "dora"
      data = "ns0.dom.scw.cloud."
      type = "NS"
      ttl  = 1800
    },
    "ns1" = {
      name = "dora"
      data = "ns1.dom.scw.cloud."
      type = "NS"
      ttl  = 1800
    },
    "prod-website" = {
      name = "dora"
      data = "dora-front-prod.osc-secnum-fr1.scalingo.io."
      type = "ALIAS"
      ttl = 300
    },
    "staging-website" = {
      name = "staging.dora"
      data = "dora-front-staging.osc-secnum-fr1.scalingo.io."
      type = "CNAME"
      ttl = 300
    },
    "prod-api" = {
      name = "api.dora"
      data = "dora-back-prod.osc-secnum-fr1.scalingo.io."
      type = "CNAME"
      ttl = 300
    },
    "staging-api" = {
      name = "api.staging.dora"
      data = "dora-back-staging.osc-secnum-fr1.scalingo.io."
      type = "CNAME"
      ttl = 300
    },
  }
}
