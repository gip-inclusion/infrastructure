terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

module "dns-emplois" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region     = var.scw_region
  scw_zone       = var.scw_zone
  scw_project_id = data.scaleway_account_project.iac_gip_inclusion.project_id

  records = {
    "brevo-code" : {
      name = "emplois"
      data = "brevo-code:7a18495fb1b2ffa39ca7ad0c1e70adcb"
      type = "TXT"
    },
    "plateforme" = {
      name = "plateforme"
      data = "domain.par.clever-cloud.com."
      type = "ALIAS"
    }
    "plateforme-demo" = {
      name = "demo.plateforme"
      data = "domain.par.clever-cloud.com."
      type = "ALIAS"
    }
    "plateforme-pentest" = {
      name = "pentest.plateforme"
      data = "domain.par.clever-cloud.com."
      type = "ALIAS"
    }
    "website" = {
      name = "emplois"
      data = "domain.par.clever-cloud.com."
      type = "ALIAS"
    }
  }
}
