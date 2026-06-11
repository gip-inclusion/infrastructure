terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

module "dns-email" {
  source = "../../../../_modules/dns/records/terraform"

  scw_region     = var.scw_region
  scw_zone       = var.scw_zone
  scw_project_id = data.scaleway_account_project.iac_gip_inclusion.project_id

  records = {
    # Umbrella Brevo organization, root of all Brevo sub-projects.
    "brevo-code-2d8d" = {
      name = ""
      data = "brevo-code:2d8d9f5f1d2fb27858f79eacaf64817d"
      type = "TXT"
    },
    "dkim-lasuite" = {
      name = "dimail._domainkey"
      data = "v=DKIM1; h=sha256; k=rsa; p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA2WZZhjIMYOZTCwH6ZX8ZhzA5BeytSp1//0bJdIUFCLAtvE7ycaoxL7pvLMoTpKW0mhl/8vY31QatR3PVD5UZwxW+q3fWA4n/pCXDIzfp2xdXCPK/FOWhsYOMCasHBdiAN2dd4On/OMDIndvYd6PBRHuaDpb8dNq++uTdbX7fYWVV/7Gy1BCW7ubAspZp/QtgGOQoZHxoM6q+pRKC+1aD6lsGDBsh/FgwRpacC4Pjj6xqbhnrYJdR5mraQHmFxkyjP/6Wmcv7Hu5+oZoCD6NG9w2o7xuS/QjsHVLyjb81zSiRKAjpeIX/QlJmojvJ2vt7eg9Q7zK/Yamq7y9vOoH/LRFZnpiPgQTtP5RD0o79YwYX4D5UhzVgRTgVdIRNIuiuNVPG7pHDeCxEu9IsNA/g55FgcM9WPRHa29tazq242v8768DUsoorD5vBQPSMKSNeTLJ57UjnnhtW5037zL2P+7tSa5ZUXMCiU8R0tsmZT/y7RwON3OVsO1YJfYhOPtlMqXpj0FA4BLJP+nVS7Xu50r0yXfpqun+7OGAMbaEBHfRCP9ct94jRyKVauc1FCFykivXHhvnvkq4qHwlnqL4L1rLxGBCZFbVecMaJ/lqBPuTlO/ewatXsmHN3Q53xbpYbWY3bQNnH3mq1+RAdLELFShiZg/YTHE75LkIMGERs2nMCAwEAAQ=="
      type = "TXT"
      ttl  = 10800
    },
    "dmarc" = {
      name = "_dmarc"
      data = "v=DMARC1; p=quarantine; rua=mailto:98224b9a@in.mailhardener.com,mailto:dmarc@inclusion.gouv.fr,mailto:rua@dmarc.brevo.com!10m; fo=1"
      type = "TXT"
    },
    "imap" = {
      name = "imap"
      data = "imap.ox.numerique.gouv.fr."
      type = "CNAME"
    },
    "mail-dkim" = {
      name = "mail._domainkey"
      data = "k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDeMVIzrCa3T14JsNY0IRv5/2V1/v2itlviLQBwXsa7shBD6TrBkswsFUToPyMRWC9tbR/5ey0nRBH0ZVxp+lsmTxid2Y2z+FApQ6ra2VsXfbJP3HE6wAO0YTVEJt1TmeczhEd2Jiz/fcabIISgXEdSpTYJhb0ct0VJRxcg4c8c7wIDAQAB"
      type = "TXT"
      ttl  = 10800
    },
    "mta-sts-site" = {
      name = "mta-sts"
      data = "mta-sts.osc-fr1.scalingo.io."
      type = "CNAME"
    },
    "mta-sts-txt" = {
      name = "_mta-sts"
      data = "v=STSv1; id=20260611T120200"
      type = "TXT"
      ttl  = 10800
    },
    "mx" = {
      name     = ""
      data     = "mx.ox.numerique.gouv.fr."
      type     = "MX"
      priority = 1
      ttl      = 600
    },
    "smtp" = {
      name = "smtp"
      data = "smtp.ox.numerique.gouv.fr."
      type = "CNAME"
    },
    "smtp.tls" = {
      name = "_smtp._tls"
      data = "v=TLSRPTv1; rua=mailto:98224b9a@in.mailhardener.com"
      type = "TXT"
    },
    "spf" = {
      name = ""
      data = "v=spf1 include:bnc3.mailjet.com include:spf.brevo.com include:mail.zendesk.com include:_spf.ox.numerique.gouv.fr ~all"
      type = "TXT"
    },
    "webmail" = {
      name = "webmail"
      data = "webmail.ox.numerique.gouv.fr."
      type = "CNAME"
    },
  }
}
