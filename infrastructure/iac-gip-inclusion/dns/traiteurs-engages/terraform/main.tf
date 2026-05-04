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

    # Emails
    "staging-brevo-code" : {
      name = "staging.traiteurs-engages"
      data = "brevo-code:96720ae72c4b9e35f0b138dac0f441c4"
      type = "TXT"
    },
    "staging-spf" : {
      name = "staging.traiteurs-engages"
      data = "v=spf1 include:spf.brevo.com -all"
      type = "TXT"
    },
    "staging-dkim" : {
      name = "mail._domainkey.staging.traiteurs-engages"
      data = "k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDeMVIzrCa3T14JsNY0IRv5/2V1/v2itlviLQBwXsa7shBD6TrBkswsFUToPyMRWC9tbR/5ey0nRBH0ZVxp+lsmTxid2Y2z+FApQ6ra2VsXfbJP3HE6wAO0YTVEJt1TmeczhEd2Jiz/fcabIISgXEdSpTYJhb0ct0VJRxcg4c8c7wIDAQAB"
      type = "TXT"
    },
  }
}
