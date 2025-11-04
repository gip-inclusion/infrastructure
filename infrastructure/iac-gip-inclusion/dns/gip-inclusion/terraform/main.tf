terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

module "dns-gip-inclusion" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region = var.scw_region
  scw_zone   = var.scw_zone

  records = {
    "bitwarden" = {
      name = "bitwarden"
      data = "bitwarden.inclusion.cloud-ed.fr."
      type = "CNAME"
    },
    "ciso" = {
      name = "ciso"
      data = "51.15.213.160"
      type = "A"
    },
    "cle-nir" = {
      name = "cle-nir"
      data = "calculette-nir-production.osc-fr1.scalingo.io."
      type = "CNAME"
    },
    "etudes" = {
      name = "etudes"
      data = "cname.tally.so."
      type = "CNAME"
      ttl  = 10800
    },
    # TXT record for Google Search Console auth
    "google-site-verification-eIGx2" = {
      name = ""
      data = "google-site-verification=eIGx2V2dBtT3Ix4xPGvkEicTf3BR8VP744PzOVmosLM"
      type = "TXT"
    },
    # TXT record for Riot auth
    "google-site-verification-YGht5" = {
      name = ""
      data = "google-site-verification=YGht5JTr0ujMA6cSZrZ9ysejKIn4ESV0v_ZQHL0hPqE"
      type = "TXT"
    },
    "google-workspace-key" = {
      name = "tpqsxaxytsb6"
      data = "gv-wnkxgmqxqqr3tm.dv.googlehosted.com."
      type = "CNAME"
      ttl  = 10800
    }
    "notion-dcv.pages" = {
      name = "_notion-dcv.pages"
      data = "1295f321-b604-81f8-8544-007038d42424"
      type = "TXT"
    },
    "ns0" = {
      name = ""
      data = "ns0.dom.scw.cloud."
      type = "NS"
      ttl  = 1800
    },
    "ns1" = {
      name = ""
      data = "ns1.dom.scw.cloud."
      type = "NS"
      ttl  = 1800
    },
    "pages" = {
      name = "pages"
      data = "external.notion.site."
      type = "CNAME"
    },
    "website" = {
      name = ""
      data = "site-institutionnel-2025-proxy.osc-fr1.scalingo.io."
      type = "ALIAS"
    },
  }
}
