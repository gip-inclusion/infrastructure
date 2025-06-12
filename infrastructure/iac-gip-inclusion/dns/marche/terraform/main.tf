terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 1.10"
}

module "dns-marche" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region = var.scw_region
  scw_zone   = var.scw_zone

  records = {
    "brevo-code-marche" = {
      name = ""
      data = "brevo-code:96720ae72c4b9e35f0b138dac0f441c4"
      type = "TXT"
    },
  }
}
