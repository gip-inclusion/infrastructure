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
    "prod-website" = {
      name = "dora"
      data = "dora-front-prod.osc-secnum-fr1.scalingo.io."
      type = "ALIAS"
      ttl  = 300
    },
    "staging-website" = {
      name = "staging.dora"
      data = "dora-front-staging.osc-fr1.scalingo.io."
      type = "CNAME"
      ttl  = 300
    },
    "prod-api" = {
      name = "api.dora"
      data = "dora-back-prod.osc-secnum-fr1.scalingo.io."
      type = "CNAME"
      ttl  = 300
    },
    "staging-api" = {
      name = "api.staging.dora"
      data = "dora-back-staging.osc-fr1.scalingo.io."
      type = "CNAME"
      ttl  = 300
    },
    "metabase" = {
      name = "metabase.dora"
      data = "dora-metabase-v2.osc-secnum-fr1.scalingo.io."
      type = "CNAME"
      ttl  = 300
    }
  }
}
