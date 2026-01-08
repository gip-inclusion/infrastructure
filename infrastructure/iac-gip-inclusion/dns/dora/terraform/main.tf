terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

module "dns-dora" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region     = var.scw_region
  scw_zone       = var.scw_zone
  scw_project_id = data.scaleway_account_project.iac_gip_inclusion.project_id

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
    },
    "help-page" = {
      name = "aide.dora"
      data = "custom.crisp.help."
      type = "CNAME"
    },
    "crisp" = {
      name = "_crisp.aide.dora"
      data = "crisp-website-id=f2839d07-9b42-477f-8bce-cf4adbda113e"
      type = "TXT"
    }
  }
}
