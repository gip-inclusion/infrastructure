terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 1.10"
}

module "dns-emplois" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region = var.scw_region
  scw_zone   = var.scw_zone

  records = {
    "emplois-brevo-code" : {
      name = "emplois"
      data = "brevo-code:7a18495fb1b2ffa39ca7ad0c1e70adcb"
      type = "TXT"
    },
    "emplois-website" = {
      name = "emplois"
      data = "domain.par.clever-cloud.com."
      type = "ALIAS"
    }
  }
}
