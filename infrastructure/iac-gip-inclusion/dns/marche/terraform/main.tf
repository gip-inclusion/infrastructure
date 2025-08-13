terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.55.0"
    }
  }
  required_version = ">= 1.10"
}

module "dns-marche" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region = var.scw_region
  scw_zone   = var.scw_zone

  records = {
    "brevo-code" = {
      name = ""
      data = "brevo-code:96720ae72c4b9e35f0b138dac0f441c4"
      type = "TXT"
    },
    "website" = {
      name = "lemarche"
      data = "domain.par.clever-cloud.com."
      type = "CNAME"
    }
  }
}
